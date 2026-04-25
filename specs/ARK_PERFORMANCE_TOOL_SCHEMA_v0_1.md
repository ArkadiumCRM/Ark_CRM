---
title: "ARK Performance-Modul · Schema v0.1"
type: spec
module: performance
version: 0.1
created: 2026-04-25
updated: 2026-04-25
status: draft
sources: [
  "wiki/meta/grundlagen-changelog.md",
  "Grundlagen MD/ARK_DATABASE_SCHEMA_v1_5.md",
  "Grundlagen MD/ARK_BACKEND_ARCHITECTURE_v2_7.md",
  "Grundlagen MD/ARK_GESAMTSYSTEM_UEBERSICHT_v1_4.md",
  "specs/ARK_HR_TOOL_SCHEMA_v0_1.md",
  "specs/ARK_BACKEND_ARCHITECTURE_PATCH_v2_6_to_v2_7_billing.md",
  "specs/ARK_BACKEND_ARCHITECTURE_PATCH_ELEARNING_v0_1.md",
  "memory/project_performance_modul_decisions.md"
]
tags: [spec, schema, performance, analytics, kpi, anomaly-detection, forecast, powerbi, multi-tenant, rls, phase-3-erp]
---

# ARK Performance-Modul · Database Schema v0.1

**Scope:** PostgreSQL-Schema für das Performance-ERP-Modul. Cross-Modul-Analytics-Hub mit Pre-aggregated Snapshots, Anomalie-Detection, Closed-Loop-Massnahmen, Pre-Built-Reports und Power-BI-Bridge. **READ-ONLY** auf alle Domain-Tabellen (CRM, HR, Commission, Zeit, E-Learning, Billing). Schreibt nur eigene Insight/Action/Report-Artefakte.

**Grundlagen-Sync erforderlich:** `ARK_STAMMDATEN_EXPORT_v1_5.md` · `ARK_DATABASE_SCHEMA_v1_5.md` · `ARK_BACKEND_ARCHITECTURE_v2_7.md` · `ARK_FRONTEND_FREEZE_v1_12.md` · `ARK_GESAMTSYSTEM_UEBERSICHT_v1_4.md`

**Architektur-Entscheidungen 2026-04-25** (siehe `memory/project_performance_modul_decisions.md`):
- Q1=C: 8 HR-Performance-Stubs aus DB §19 voll ins **HR-Modul** migriert (eigener HR-Patch v0.1→v0.2)
- Q2=C: Performance-Goals (operativ) HIER · Development-Goals (Karriere) im HR
- Q3=C+Y: 4-stufig (info/warn/critical/blocker) · Schwellen via `dim_anomaly_threshold`
- Q4=D: Nightly-Rollup 02:00 + Hourly-Critical :15 für Power-BI
- Q5=D+X: Hybrid Dashboard (Rollen-Default + User-Override + Locked-Tiles) · Hardcoded Tile-Library + `dim_metric_definition` Stammdaten
- Q6=D: Closed-Loop · `fact_insight` → `fact_action_item` → Auto-Reminder → `fact_action_outcome` mit Wirkungsmessung
- Q7=D: Pre-Built-Reports via Pipeline (Performance → Dok-Generator → Email) + Custom via Power-BI
- Q8=E: Markov-Stage-Model v0.1 (erklärbar, audit-fest)

---

## 1. Schema-Prinzipien

1. **READ-ONLY** auf fremde Tabellen — Performance schreibt **nie** in CRM/HR/Commission/Zeit/E-Learning/Billing.
2. **UUID-Primary-Keys** durchgängig (`gen_random_uuid()`).
3. **ENUMs** (nicht VARCHAR) für Status/Severity/Cadence-Felder.
4. **Multi-Tenant via RLS:** alle `fact_perf_*` und User-bezogene `dim_perf_*` mit `tenant_id` + `ENABLE ROW LEVEL SECURITY`. Stammdaten ohne Tenant-Scope (`dim_metric_definition`, `dim_dashboard_tile_type`, etc.) tenant-übergreifend.
5. **Snapshot-Tabellen** (`fact_metric_snapshot_*`) sind **append-only** — kein UPDATE/DELETE (Audit-Compliance, Time-Series-Integrität).
6. **`audit_trail_jsonb`** auf mutierten Fact-Tabellen (`fact_insight`, `fact_action_item`, `fact_action_outcome`).
7. **`retention_until DATE`** auf Snapshots (Default 5 Jahre, konfigurierbar pro Cadence).
8. **Soft-Delete** via `archived_at TIMESTAMPTZ` für `dim_*`-Tabellen.
9. **Materialized Views** für Power-BI-Cubes — `REFRESH MATERIALIZED VIEW CONCURRENTLY` per Worker.
10. **Live Views** (`v_perf_*`) für Drill-Downs ohne Snapshot — Direct-Query-fähig.

---

## 2. PostgreSQL Extensions

```sql
CREATE EXTENSION IF NOT EXISTS pgcrypto;     -- gen_random_uuid()
CREATE EXTENSION IF NOT EXISTS btree_gin;    -- für JSONB-Indizes auf Snapshot-Filtern
-- pgvector NICHT nötig (kein Embedding-Suche im Performance-Modul)
```

---

## 3. ENUM-Types

```sql
-- Snapshot-Cadence (Aggregations-Zeitraum)
CREATE TYPE perf_cadence AS ENUM (
    'hourly',     -- Critical-KPIs (Pipeline-Today, Goal-Drift, Coverage-Critical)
    'daily',      -- Standard-Snapshot (alle Metriken, 02:00 Cron)
    'weekly',     -- Wochen-Rollup (Mo 03:00)
    'monthly',    -- Monats-Rollup (1. 04:00)
    'quarterly',  -- Quartals-Rollup (1.1./1.4./1.7./1.10. 05:00)
    'yearly'      -- Jahres-Rollup (1.1. 06:00)
);

-- Anomalie-Severity (Q3=C: 4-stufig)
CREATE TYPE anomaly_severity AS ENUM (
    'info',       -- on-demand sichtbar, keine Eskalation
    'warn',       -- täglich aggregiert in Heads-Inbox
    'critical',   -- sofort Reminder + WS-Notification
    'blocker'     -- Auto-Eskalation an Admin (Datenqualität, Worker-Fail, View-Refresh-Fehler)
);

-- Insight-Status
CREATE TYPE insight_state AS ENUM (
    'open',           -- erkannt, noch nicht bearbeitet
    'acknowledged',   -- gesehen, noch keine Massnahme
    'action_planned', -- Massnahme erstellt
    'resolved',       -- KPI wieder im Soll-Bereich
    'false_positive', -- nicht relevant, manuell verworfen
    'archived'        -- nach Retention-Frist
);

-- Action-Item-Status
CREATE TYPE action_item_state AS ENUM (
    'pending',     -- erstellt, noch nicht gestartet
    'in_progress', -- Owner arbeitet daran
    'done',        -- erledigt, Wirkung wird gemessen
    'cancelled',   -- abgebrochen (mit Begründung)
    'overdue'      -- Due-Date überschritten ohne Done
);

-- Outcome-Effect (Wirkungs-Messung beim Re-Run)
CREATE TYPE outcome_effect AS ENUM (
    'improved',           -- KPI im Soll-Bereich oder besser
    'partially_improved', -- KPI besser, aber noch nicht im Soll
    'no_change',          -- KPI stabil, Massnahme ohne Effekt
    'worsened',           -- KPI schlechter (Massnahme kontraproduktiv?)
    'inconclusive'        -- Datenmenge zu klein für Aussage
);

-- Tile-Typ (Q5=X: Hardcoded Tile-Library, ~15 Typen)
CREATE TYPE tile_type AS ENUM (
    'kpi_card',          -- Single-Wert mit Trend-Mini-Chart
    'kpi_card_compare',  -- KPI vs Target (% Erreichung)
    'trend_chart',       -- Linien-Chart über Zeit
    'bar_chart',         -- Vergleich (z.B. Sparten)
    'funnel',            -- Pipeline-Funnel mit Drop-Off
    'heatmap',           -- 2D-Density (z.B. Activity × Wochentag)
    'coverage_map',      -- Kandidaten/Kunden-Coverage-Heatmap
    'goal_progress',     -- Ziel-Erreichungs-Bar
    'top_n_list',        -- Top-N-Ranking (z.B. Top-Mandanten)
    'anomaly_list',      -- Aktuelle Anomalien-Liste
    'action_list',       -- Offene Massnahmen-Liste
    'forecast_card',     -- Markov-Forecast mit Erklärung
    'cohort_chart',      -- Cohort-Analyse (Hunt-Vintage etc.)
    'sparkline_grid',    -- Mehrere Mini-KPIs nebeneinander
    'iframe_powerbi'     -- Eingebettetes Power-BI-Embed
);

-- Forecast-Methode (Q8=E: Markov v0.1, ML-Upgrade Phase-3+)
CREATE TYPE forecast_method AS ENUM (
    'markov_stage',  -- v0.1 Default
    'linear_trend',  -- Fallback bei zu wenig Daten
    'ml_regression', -- Phase-3+ Upgrade
    'manual'         -- User-Override (z.B. „Ich plane 8 Placements")
);

-- Aggregation-Funktion (für dim_metric_definition)
CREATE TYPE metric_aggregation AS ENUM (
    'count', 'sum', 'avg', 'median', 'min', 'max',
    'p95', 'p99', 'rate', 'ratio', 'ytd', 'mtd', 'wtd'
);

-- Report-Cadence
CREATE TYPE report_cadence AS ENUM (
    'on_demand', 'weekly', 'monthly', 'quarterly', 'yearly'
);

-- Report-Status
CREATE TYPE report_run_state AS ENUM (
    'queued', 'rendering', 'sent', 'failed', 'cancelled'
);

-- Power-BI-View-Refresh-Status
CREATE TYPE powerbi_view_state AS ENUM (
    'fresh', 'stale', 'refreshing', 'failed'
);
```

---

## 4. Dimension Tables (Stammdaten)

### 4.1 `dim_metric_definition`

KPI-Katalog. Zentraler Punkt für alle Metriken die Performance-Modul aggregiert. Admin pflegt Stammdaten, Worker liest beim Snapshot-Lauf.

```sql
CREATE TABLE dim_metric_definition (
    code                    VARCHAR(80) PRIMARY KEY,             -- 'pipeline_velocity_days'
    label_de                VARCHAR(200) NOT NULL,
    description_de          TEXT NULL,
    category                VARCHAR(40) NOT NULL,                -- 'pipeline' | 'revenue' | 'coverage' | 'compliance' | 'activity' | 'forecast' | 'meta'
    source_module           VARCHAR(40) NOT NULL,                -- 'crm' | 'hr' | 'commission' | 'zeit' | 'elearn' | 'billing'
    source_table            VARCHAR(120) NOT NULL,               -- z.B. 'fact_history' | 'v_pipeline_funnel'
    aggregation             metric_aggregation NOT NULL,
    unit                    VARCHAR(40) NULL,                    -- 'CHF' | 'days' | '%' | 'count' | 'h'
    formula_sql             TEXT NULL,                           -- Optional: SELECT-Snippet für komplexe Berechnungen
    target_default          NUMERIC(15,4) NULL,                  -- Default-Soll (kann pro User/Sparte überschrieben werden)
    target_direction        VARCHAR(10) NOT NULL DEFAULT 'higher', -- 'higher' = mehr ist besser, 'lower' = weniger ist besser
    drill_down_entity       VARCHAR(40) NULL,                    -- 'candidate' | 'account' | 'mandate' | 'process' | 'user' | 'sparte' | NULL
    visibility_roles        TEXT[] NOT NULL DEFAULT '{ma,head,admin}', -- Wer darf KPI sehen
    cadence_default         perf_cadence NOT NULL DEFAULT 'daily',
    sort_order              SMALLINT NOT NULL DEFAULT 100,
    active                  BOOLEAN NOT NULL DEFAULT TRUE,
    archived_at             TIMESTAMPTZ NULL,
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_metric_def_category ON dim_metric_definition(category) WHERE active = TRUE;
CREATE INDEX idx_metric_def_source ON dim_metric_definition(source_module, active);
```

**Kategorien (festgelegt, nicht erweiterbar ohne Schema-Patch):**
- `pipeline` — Stages, Conversion, Velocity, Funnel
- `revenue` — Umsatz, Honorar, Forecast (CHF)
- `coverage` — Kandidaten/Kunden-Touch-Frequenz, Vernachlässigungs-Indikatoren
- `compliance` — E-Learning-Quote, AGB-Status, Reminder-Backlog
- `activity` — Calls, Emails, Meetings pro MA/Tag/Sparte
- `forecast` — Vorhergesagte Werte (Markov-Output)
- `meta` — System-Health (View-Refresh-Status, Worker-Lag, Datenqualität)

### 4.2 `dim_anomaly_threshold` (Q3=Y)

Schwellwerte für Anomalie-Detection. Pro Metric-Code + optional Sparte/Team/Rolle. 4 Severity-Levels.

```sql
CREATE TABLE dim_anomaly_threshold (
    id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    metric_code             VARCHAR(80) NOT NULL REFERENCES dim_metric_definition(code) ON DELETE CASCADE,
    scope_type              VARCHAR(20) NOT NULL,                -- 'global' | 'sparte' | 'team' | 'role'
    scope_value             VARCHAR(40) NULL,                    -- 'ARC' | 'team_pw' | 'cm' | NULL bei global
    info_threshold          NUMERIC(15,4) NULL,
    warn_threshold          NUMERIC(15,4) NULL,
    critical_threshold      NUMERIC(15,4) NULL,
    blocker_threshold       NUMERIC(15,4) NULL,
    direction               VARCHAR(10) NOT NULL,                -- 'above' | 'below'
    -- Beispiel: metric=candidate_days_since_touch, direction=above, info=14, warn=30, critical=60, blocker=120
    evaluation_window_days  SMALLINT NOT NULL DEFAULT 1,         -- Lookback-Fenster (1d = aktueller Snapshot)
    min_sample_size         SMALLINT NOT NULL DEFAULT 1,         -- Anti-False-Positive (z.B. min 3 Datenpunkte)
    cooldown_hours          SMALLINT NOT NULL DEFAULT 24,        -- nicht öfter als X Stunden re-flaggen
    active                  BOOLEAN NOT NULL DEFAULT TRUE,
    notes                   TEXT NULL,
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (metric_code, scope_type, scope_value)
);

CREATE INDEX idx_anomaly_threshold_metric ON dim_anomaly_threshold(metric_code, active);
```

### 4.3 `dim_dashboard_tile_type`

Tile-Library-Katalog (Q5=X: ~15 Typen). Hardcoded Components, aber Stammdaten-Eintrag für Tile-Picker-UI.

```sql
CREATE TABLE dim_dashboard_tile_type (
    code                    tile_type PRIMARY KEY,
    label_de                VARCHAR(120) NOT NULL,
    description_de          TEXT NULL,
    icon                    VARCHAR(40) NULL,                    -- Icon-Name aus Design-System
    min_width               SMALLINT NOT NULL DEFAULT 1,         -- Grid-Spalten (1-12)
    min_height              SMALLINT NOT NULL DEFAULT 1,         -- Grid-Reihen
    default_width           SMALLINT NOT NULL DEFAULT 3,
    default_height          SMALLINT NOT NULL DEFAULT 2,
    requires_metric         BOOLEAN NOT NULL DEFAULT TRUE,       -- benötigt Metric-Ref
    requires_drill_down     BOOLEAN NOT NULL DEFAULT FALSE,
    config_schema_jsonb     JSONB NOT NULL DEFAULT '{}',         -- JSON-Schema für Tile-Config (Filter, Granularität, etc.)
    sort_order              SMALLINT NOT NULL DEFAULT 100,
    active                  BOOLEAN NOT NULL DEFAULT TRUE
);
```

### 4.4 `dim_dashboard_layout`

Rollen-Default-Layouts + User-Custom-Layouts. Q5=D Hybrid.

```sql
CREATE TABLE dim_dashboard_layout (
    id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id               UUID NOT NULL,
    layout_scope            VARCHAR(20) NOT NULL,                -- 'role_default' | 'user_custom'
    role_code               VARCHAR(40) NULL,                    -- 'ma' | 'cm' | 'am' | 'ra' | 'head' | 'admin' (NULL bei user_custom)
    user_id                 UUID NULL REFERENCES dim_user(id),   -- NULL bei role_default
    page_code               VARCHAR(40) NOT NULL,                -- 'dashboard' | 'team' | 'mitarbeiter' | 'business' | etc.
    layout_jsonb            JSONB NOT NULL,                      -- Tile-Definitions: [{tile_type, metric_code, position, config}]
    is_locked_layout        BOOLEAN NOT NULL DEFAULT FALSE,      -- bei role_default: Admin-Lock auf einzelne Tiles
    archived_at             TIMESTAMPTZ NULL,
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CHECK (
        (layout_scope = 'role_default' AND role_code IS NOT NULL AND user_id IS NULL) OR
        (layout_scope = 'user_custom'  AND user_id   IS NOT NULL)
    )
);

CREATE INDEX idx_dashboard_layout_tenant_role ON dim_dashboard_layout(tenant_id, role_code, page_code) WHERE layout_scope = 'role_default';
CREATE INDEX idx_dashboard_layout_user ON dim_dashboard_layout(tenant_id, user_id, page_code) WHERE layout_scope = 'user_custom';

-- RLS:
ALTER TABLE dim_dashboard_layout ENABLE ROW LEVEL SECURITY;
CREATE POLICY layout_tenant_isolation ON dim_dashboard_layout
    USING (tenant_id = current_setting('app.tenant_id')::uuid);
```

**`layout_jsonb`-Struktur:**
```json
{
  "tiles": [
    {
      "tile_id": "uuid",
      "tile_type": "kpi_card",
      "metric_code": "pipeline_velocity_days",
      "position": {"x": 0, "y": 0, "w": 3, "h": 2},
      "config": {"compare_to": "previous_period", "filter": {"sparte": "ARC"}},
      "locked_by_admin": false
    },
    ...
  ]
}
```

### 4.5 `dim_report_template`

Report-Vorlagen-Katalog für Pre-Built-Reports (Q7=D).

```sql
CREATE TABLE dim_report_template (
    code                    VARCHAR(80) PRIMARY KEY,
    label_de                VARCHAR(200) NOT NULL,
    description_de          TEXT NULL,
    cadence                 report_cadence NOT NULL,
    target_audience         VARCHAR(40) NOT NULL,                -- 'ma_self' | 'head_team' | 'admin' | 'exec' | 'all'
    dok_generator_template  VARCHAR(120) NOT NULL,               -- Ref auf Template im Dok-Generator
    data_bundle_spec_jsonb  JSONB NOT NULL,                      -- welche Metriken/Views/Filter in Bundle
    cron_expression         VARCHAR(40) NULL,                    -- z.B. '0 6 * * 1' (Mo 06:00) — NULL bei on_demand
    cron_active             BOOLEAN NOT NULL DEFAULT FALSE,
    email_template_code     VARCHAR(80) NULL,                    -- Ref auf Email-Template (Subject, Body)
    sender_user_id          UUID NULL REFERENCES dim_user(id),   -- mit dessen Outlook-Token versendet
    sort_order              SMALLINT NOT NULL DEFAULT 100,
    active                  BOOLEAN NOT NULL DEFAULT TRUE,
    archived_at             TIMESTAMPTZ NULL,
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

**Default-Seeds (in `ARK_STAMMDATEN_PATCH_v1_5_to_v1_6_performance.md`):**

| code | label_de | cadence | audience | cron |
|------|----------|---------|----------|------|
| `weekly_ma_report` | Wochenreport (eigene Pipeline + Goals + Anomalien) | weekly | ma_self | `0 6 * * 1` |
| `weekly_head_report` | Wochenreport (Team-KPIs + offene Massnahmen) | weekly | head_team | `0 7 * * 1` |
| `monthly_business_report` | Monatsreport (Sparten-Revenue + Conversion + Forecast) | monthly | admin | `0 6 1 * *` |
| `quarterly_exec_report` | Quartals-Executive-Report (Strategic + 9-Box + Markt) | quarterly | exec | `0 6 1 1,4,7,10 *` |
| `yearly_review_pack` | Jahres-Audit-Pack (Steuer/Strategie) | yearly | admin | `0 6 1 1 *` |

### 4.6 `dim_powerbi_view`

Materialized-View-Katalog für Power-BI-Bridge (Q4=D).

```sql
CREATE TABLE dim_powerbi_view (
    code                    VARCHAR(80) PRIMARY KEY,             -- z.B. 'v_perf_revenue_monthly'
    label_de                VARCHAR(200) NOT NULL,
    description_de          TEXT NULL,
    refresh_cadence         perf_cadence NOT NULL,               -- 'hourly' für critical, 'daily' für rest
    refresh_cron            VARCHAR(40) NOT NULL,
    is_critical             BOOLEAN NOT NULL DEFAULT FALSE,      -- TRUE = hourly Refresh
    sql_definition          TEXT NOT NULL,                       -- vollständiges CREATE MATERIALIZED VIEW SQL
    last_refresh_at         TIMESTAMPTZ NULL,
    last_refresh_state      powerbi_view_state NOT NULL DEFAULT 'stale',
    last_refresh_duration_ms INTEGER NULL,
    last_refresh_error      TEXT NULL,
    row_count_estimate      BIGINT NULL,
    powerbi_dataset_url     VARCHAR(500) NULL,                   -- Optional: Direct-Link zu Power-BI-Dataset
    visibility_roles        TEXT[] NOT NULL DEFAULT '{admin}',   -- meist nur Admin sieht View-Mgmt
    sort_order              SMALLINT NOT NULL DEFAULT 100,
    active                  BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE INDEX idx_powerbi_view_refresh ON dim_powerbi_view(refresh_cadence, is_critical, active);
```

**Default-Views (Seeds):**

| code | cadence | critical | inhalt |
|------|---------|----------|--------|
| `v_perf_pipeline_today` | hourly | TRUE | Heute eingegangene Calls, neue Prozesse, Stage-Changes |
| `v_perf_goal_drift_critical` | hourly | TRUE | Goals mit > 20% Drift |
| `v_perf_coverage_critical` | hourly | TRUE | Kandidaten/Kunden mit Coverage-Score < critical-Schwelle |
| `v_perf_revenue_monthly` | monthly | FALSE | Revenue-Attribution pro CM/AM/Sparte/Mandat |
| `v_perf_pipeline_funnel_daily` | daily | FALSE | Stage-Conversion pro Sparte |
| `v_perf_cohort_hunt_vintage` | weekly | FALSE | Hunt-Vintage Performance über 12 Monate |
| `v_perf_activity_heatmap_weekly` | weekly | FALSE | Activity × Wochentag pro MA |
| `v_perf_elearn_compliance_daily` | daily | FALSE | E-Learning Compliance pro MA + Aggregat |

---

## 5. Snapshot Tables (Time-Series, append-only)

### 5.1 `fact_metric_snapshot_hourly`

Stündliche Critical-KPI-Snapshots. Q4=D.

```sql
CREATE TABLE fact_metric_snapshot_hourly (
    id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id               UUID NOT NULL,
    metric_code             VARCHAR(80) NOT NULL REFERENCES dim_metric_definition(code),
    snapshot_at             TIMESTAMPTZ NOT NULL,                -- aufgerundet auf volle Stunde
    scope_type              VARCHAR(20) NOT NULL,                -- 'global' | 'sparte' | 'team' | 'user' | 'mandate' | 'account' | 'candidate'
    scope_value             VARCHAR(80) NULL,                    -- ID oder Code (NULL bei global)
    metric_value            NUMERIC(20,6) NOT NULL,
    metric_count            BIGINT NULL,                         -- Sample-Size (für Min-Sample-Check)
    target_value            NUMERIC(20,6) NULL,                  -- Soll zum Snapshot-Zeitpunkt
    target_achievement_pct  NUMERIC(7,4) NULL,                   -- (value/target * 100)
    metadata_jsonb          JSONB NULL,                          -- Optional: Drill-Down-Hints, Filter-Context
    retention_until         DATE NOT NULL,                       -- Default 90 Tage für hourly
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (tenant_id, metric_code, snapshot_at, scope_type, scope_value)
);

CREATE INDEX idx_snap_hourly_metric_time ON fact_metric_snapshot_hourly(metric_code, snapshot_at DESC);
CREATE INDEX idx_snap_hourly_tenant_scope ON fact_metric_snapshot_hourly(tenant_id, scope_type, scope_value, snapshot_at DESC);
CREATE INDEX idx_snap_hourly_retention ON fact_metric_snapshot_hourly(retention_until) WHERE retention_until < CURRENT_DATE;

-- Partitioniert nach Monat (Performance bei Time-Series-Queries):
-- CREATE TABLE fact_metric_snapshot_hourly_2026_04 PARTITION OF fact_metric_snapshot_hourly
--     FOR VALUES FROM ('2026-04-01') TO ('2026-05-01');

ALTER TABLE fact_metric_snapshot_hourly ENABLE ROW LEVEL SECURITY;
CREATE POLICY snap_hourly_tenant_isolation ON fact_metric_snapshot_hourly
    USING (tenant_id = current_setting('app.tenant_id')::uuid);
```

### 5.2 `fact_metric_snapshot_daily`

Täglicher Vollschnitt aller aktiven Metriken (Q4=D nightly 02:00).

```sql
CREATE TABLE fact_metric_snapshot_daily (
    id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id               UUID NOT NULL,
    metric_code             VARCHAR(80) NOT NULL REFERENCES dim_metric_definition(code),
    snapshot_date           DATE NOT NULL,
    scope_type              VARCHAR(20) NOT NULL,
    scope_value             VARCHAR(80) NULL,
    metric_value            NUMERIC(20,6) NOT NULL,
    metric_count            BIGINT NULL,
    target_value            NUMERIC(20,6) NULL,
    target_achievement_pct  NUMERIC(7,4) NULL,
    delta_vs_yesterday      NUMERIC(20,6) NULL,
    delta_vs_last_week      NUMERIC(20,6) NULL,
    delta_vs_last_month     NUMERIC(20,6) NULL,
    metadata_jsonb          JSONB NULL,
    retention_until         DATE NOT NULL,                       -- Default 2 Jahre für daily
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (tenant_id, metric_code, snapshot_date, scope_type, scope_value)
);

CREATE INDEX idx_snap_daily_metric_date ON fact_metric_snapshot_daily(metric_code, snapshot_date DESC);
CREATE INDEX idx_snap_daily_tenant_scope ON fact_metric_snapshot_daily(tenant_id, scope_type, scope_value, snapshot_date DESC);

ALTER TABLE fact_metric_snapshot_daily ENABLE ROW LEVEL SECURITY;
CREATE POLICY snap_daily_tenant_isolation ON fact_metric_snapshot_daily
    USING (tenant_id = current_setting('app.tenant_id')::uuid);
```

### 5.3 `fact_metric_snapshot_weekly` / `_monthly` / `_quarterly` / `_yearly`

Identische Struktur zu `_daily`, nur mit `snapshot_period_start DATE` + `snapshot_period_end DATE` statt `snapshot_date`. Retention: weekly 5J · monthly 10J · quarterly/yearly 20J.

```sql
-- weekly
CREATE TABLE fact_metric_snapshot_weekly (
    id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id               UUID NOT NULL,
    metric_code             VARCHAR(80) NOT NULL REFERENCES dim_metric_definition(code),
    period_start            DATE NOT NULL,
    period_end              DATE NOT NULL,
    iso_year                SMALLINT NOT NULL,
    iso_week                SMALLINT NOT NULL,
    scope_type              VARCHAR(20) NOT NULL,
    scope_value             VARCHAR(80) NULL,
    metric_value            NUMERIC(20,6) NOT NULL,
    metric_count            BIGINT NULL,
    target_value            NUMERIC(20,6) NULL,
    target_achievement_pct  NUMERIC(7,4) NULL,
    delta_vs_last_week      NUMERIC(20,6) NULL,
    delta_vs_4_weeks_ago    NUMERIC(20,6) NULL,
    delta_vs_last_year      NUMERIC(20,6) NULL,
    metadata_jsonb          JSONB NULL,
    retention_until         DATE NOT NULL,
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (tenant_id, metric_code, period_start, scope_type, scope_value)
);

ALTER TABLE fact_metric_snapshot_weekly ENABLE ROW LEVEL SECURITY;
-- analoge Indizes + RLS-Policy

-- monthly, quarterly, yearly: identisches Pattern (nur period-Granularität anders)
```

---

## 6. Goal Tracking (Q2=C operative Performance-Goals)

### 6.1 `fact_perf_goal`

Operative Ziele pro MA. Karriere-Goals leben im HR-Modul (`fact_development_plans` per Q1=C).

```sql
CREATE TABLE fact_perf_goal (
    id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id               UUID NOT NULL,
    user_id                 UUID NOT NULL REFERENCES dim_user(id),
    metric_code             VARCHAR(80) NOT NULL REFERENCES dim_metric_definition(code),
    period_start            DATE NOT NULL,
    period_end              DATE NOT NULL,
    target_value            NUMERIC(20,6) NOT NULL,
    target_direction        VARCHAR(10) NOT NULL DEFAULT 'higher', -- 'higher' = mehr ist besser
    weight                  SMALLINT NOT NULL DEFAULT 1,         -- Gewichtung (für Aggregat-Score)
    description             TEXT NULL,
    set_by_user_id          UUID NOT NULL REFERENCES dim_user(id), -- meist Head, manchmal Self
    set_at                  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    cancelled_at            TIMESTAMPTZ NULL,
    cancellation_reason     TEXT NULL,
    audit_trail_jsonb       JSONB NOT NULL DEFAULT '[]',
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CHECK (period_end > period_start)
);

CREATE INDEX idx_perf_goal_user_period ON fact_perf_goal(tenant_id, user_id, period_start, period_end) WHERE cancelled_at IS NULL;
CREATE INDEX idx_perf_goal_metric ON fact_perf_goal(metric_code, period_start) WHERE cancelled_at IS NULL;

ALTER TABLE fact_perf_goal ENABLE ROW LEVEL SECURITY;
CREATE POLICY perf_goal_visibility ON fact_perf_goal
    USING (
        tenant_id = current_setting('app.tenant_id')::uuid
        AND (
            user_id = current_setting('app.user_id')::uuid                                       -- Self
            OR EXISTS (SELECT 1 FROM dim_user u WHERE u.id = fact_perf_goal.user_id AND u.reports_to = current_setting('app.user_id')::uuid)  -- Head
            OR current_setting('app.role_code') IN ('admin')                                     -- Admin tenant-weit
        )
    );
```

**Goal-Tracking-Logik:** Snapshot-Worker liest `fact_perf_goal` für aktuelle Periode + entsprechenden Snapshot-Wert → berechnet `target_achievement_pct` → schreibt zurück in `fact_metric_snapshot_*`. Drift > Schwelle (`dim_anomaly_threshold` für `goal_drift`-Metric) → erzeugt `fact_insight`.

---

## 7. Insight + Action-Loop (Q6=D Closed-Loop)

### 7.1 `fact_insight`

Auto-detected Anomalien + manuell erstellte Insights. Snapshot des Ist-Zustands beim Erkennungs-Zeitpunkt.

```sql
CREATE TABLE fact_insight (
    id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id               UUID NOT NULL,
    metric_code             VARCHAR(80) NOT NULL REFERENCES dim_metric_definition(code),
    detected_by             VARCHAR(20) NOT NULL,                -- 'anomaly_worker' | 'manual_user' | 'scheduled_review'
    detected_by_user_id     UUID NULL REFERENCES dim_user(id),   -- bei manual
    detected_at             TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    severity                anomaly_severity NOT NULL,
    state                   insight_state NOT NULL DEFAULT 'open',
    scope_type              VARCHAR(20) NOT NULL,
    scope_value             VARCHAR(80) NULL,
    snapshot_value          NUMERIC(20,6) NOT NULL,
    snapshot_target         NUMERIC(20,6) NULL,
    threshold_breached      NUMERIC(20,6) NOT NULL,
    threshold_id            UUID NULL REFERENCES dim_anomaly_threshold(id),
    title                   VARCHAR(200) NOT NULL,               -- z.B. "Coverage Sparte ARC unter 65%"
    description             TEXT NULL,
    recommended_action      TEXT NULL,                           -- Optional: KI-/Regel-basierter Vorschlag
    related_entities_jsonb  JSONB NULL,                          -- {candidates: [uuid], accounts: [uuid], mandates: [uuid]}
    acknowledged_by_user_id UUID NULL REFERENCES dim_user(id),
    acknowledged_at         TIMESTAMPTZ NULL,
    resolved_at             TIMESTAMPTZ NULL,
    archived_at             TIMESTAMPTZ NULL,
    audit_trail_jsonb       JSONB NOT NULL DEFAULT '[]',
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_insight_state_severity ON fact_insight(tenant_id, state, severity, detected_at DESC) WHERE archived_at IS NULL;
CREATE INDEX idx_insight_metric ON fact_insight(metric_code, detected_at DESC) WHERE archived_at IS NULL;
CREATE INDEX idx_insight_scope ON fact_insight(tenant_id, scope_type, scope_value, detected_at DESC) WHERE archived_at IS NULL;

ALTER TABLE fact_insight ENABLE ROW LEVEL SECURITY;
CREATE POLICY insight_tenant_visibility ON fact_insight
    USING (tenant_id = current_setting('app.tenant_id')::uuid);
```

### 7.2 `fact_action_item`

Massnahmen aus Insights. Closed-Loop-Mittelpunkt.

```sql
CREATE TABLE fact_action_item (
    id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id               UUID NOT NULL,
    insight_id              UUID NOT NULL REFERENCES fact_insight(id) ON DELETE RESTRICT,
    title                   VARCHAR(200) NOT NULL,
    description             TEXT NULL,
    hypothesis              TEXT NULL,                           -- "Wir vermuten dass mehr Hunting in ARC die Coverage hebt"
    planned_intervention    TEXT NULL,                           -- "Researcher PW arbeitet 5h/Wo zusätzlich an ARC"
    owner_user_id           UUID NOT NULL REFERENCES dim_user(id),
    due_date                DATE NOT NULL,
    state                   action_item_state NOT NULL DEFAULT 'pending',
    started_at              TIMESTAMPTZ NULL,
    completed_at            TIMESTAMPTZ NULL,
    cancelled_at            TIMESTAMPTZ NULL,
    cancellation_reason     TEXT NULL,
    reminder_id             UUID NULL,                           -- Cross-Link zu fact_reminder (existiert in CRM)
    audit_trail_jsonb       JSONB NOT NULL DEFAULT '[]',
    created_by_user_id      UUID NOT NULL REFERENCES dim_user(id),
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_action_item_owner_state ON fact_action_item(tenant_id, owner_user_id, state, due_date) WHERE state IN ('pending', 'in_progress', 'overdue');
CREATE INDEX idx_action_item_insight ON fact_action_item(insight_id);
CREATE INDEX idx_action_item_overdue ON fact_action_item(due_date) WHERE state IN ('pending', 'in_progress');

ALTER TABLE fact_action_item ENABLE ROW LEVEL SECURITY;
CREATE POLICY action_item_visibility ON fact_action_item
    USING (
        tenant_id = current_setting('app.tenant_id')::uuid
        AND (
            owner_user_id = current_setting('app.user_id')::uuid
            OR EXISTS (SELECT 1 FROM dim_user u WHERE u.id = fact_action_item.owner_user_id AND u.reports_to = current_setting('app.user_id')::uuid)
            OR current_setting('app.role_code') IN ('admin')
        )
    );
```

### 7.3 `fact_action_outcome`

Wirkungs-Messung beim Re-Run der Anomalie-Detection (Q6=D Auto-KPI-Diff).

```sql
CREATE TABLE fact_action_outcome (
    id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id               UUID NOT NULL,
    action_item_id          UUID NOT NULL REFERENCES fact_action_item(id) ON DELETE RESTRICT,
    measured_at             TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    metric_value_baseline   NUMERIC(20,6) NOT NULL,              -- Wert beim Insight-Detect
    metric_value_after      NUMERIC(20,6) NOT NULL,              -- Wert nach Massnahmen-Ablauf
    delta_absolute          NUMERIC(20,6) NOT NULL,
    delta_percentage        NUMERIC(7,4) NOT NULL,
    effect                  outcome_effect NOT NULL,             -- improved | partially_improved | no_change | worsened | inconclusive
    confirmed_by_user_id    UUID NULL REFERENCES dim_user(id),   -- Owner bestätigt Wirkung
    confirmed_at            TIMESTAMPTZ NULL,
    notes                   TEXT NULL,
    follow_up_action_id     UUID NULL REFERENCES fact_action_item(id), -- bei worsened/no_change: Folge-Massnahme
    audit_trail_jsonb       JSONB NOT NULL DEFAULT '[]',
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_action_outcome_action ON fact_action_outcome(action_item_id, measured_at DESC);
CREATE INDEX idx_action_outcome_effect ON fact_action_outcome(tenant_id, effect, measured_at DESC);

ALTER TABLE fact_action_outcome ENABLE ROW LEVEL SECURITY;
CREATE POLICY outcome_tenant_visibility ON fact_action_outcome
    USING (tenant_id = current_setting('app.tenant_id')::uuid);
```

---

## 8. Report-Pipeline (Q7=D)

### 8.1 `fact_report_run`

Audit aller generierten Reports.

```sql
CREATE TABLE fact_report_run (
    id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id               UUID NOT NULL,
    template_code           VARCHAR(80) NOT NULL REFERENCES dim_report_template(code),
    triggered_by            VARCHAR(20) NOT NULL,                -- 'cron' | 'manual' | 'event'
    triggered_by_user_id    UUID NULL REFERENCES dim_user(id),
    period_start            DATE NOT NULL,
    period_end              DATE NOT NULL,
    state                   report_run_state NOT NULL DEFAULT 'queued',
    data_bundle_jsonb       JSONB NULL,                          -- aggregated payload für Dok-Generator
    pdf_file_path           VARCHAR(500) NULL,
    pdf_size_bytes          BIGINT NULL,
    sent_to_emails          TEXT[] NULL,
    sent_at                 TIMESTAMPTZ NULL,
    failed_at               TIMESTAMPTZ NULL,
    failure_reason          TEXT NULL,
    duration_ms             INTEGER NULL,
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_report_run_template_state ON fact_report_run(template_code, state, created_at DESC);
CREATE INDEX idx_report_run_period ON fact_report_run(tenant_id, period_start, period_end);

ALTER TABLE fact_report_run ENABLE ROW LEVEL SECURITY;
CREATE POLICY report_run_tenant_visibility ON fact_report_run
    USING (tenant_id = current_setting('app.tenant_id')::uuid);
```

---

## 9. Forecast (Q8=E Markov v0.1)

### 9.1 `dim_forecast_conversion_rate`

Auto-berechnete Stage-Conversion-Raten pro Sparte × Mandat-Typ. Vom `forecast-recompute.worker` (Cron 05:00) befüllt.

```sql
CREATE TABLE dim_forecast_conversion_rate (
    id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id               UUID NOT NULL,
    sparte                  VARCHAR(10) NOT NULL,                -- 'ARC' | 'GT' | 'ING' | 'PUR' | 'REM' | 'ALL'
    business_model          VARCHAR(20) NOT NULL,                -- 'mandat_target' | 'mandat_taskforce' | 'mandat_time' | 'erfolgsbasis' | 'ALL'
    from_stage              VARCHAR(40) NOT NULL,                -- z.B. 'cv_sent'
    to_stage                VARCHAR(40) NOT NULL,                -- z.B. 'ti'
    conversion_rate         NUMERIC(7,4) NOT NULL,               -- 0.0000 - 1.0000
    avg_days_in_stage       NUMERIC(7,2) NOT NULL,
    sample_size             INTEGER NOT NULL,                    -- Anzahl historische Prozesse
    lookback_window_days    SMALLINT NOT NULL DEFAULT 365,       -- letzten 12 Monate
    computed_at             TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (tenant_id, sparte, business_model, from_stage, to_stage)
);

CREATE INDEX idx_forecast_rate_lookup ON dim_forecast_conversion_rate(tenant_id, sparte, business_model, from_stage);
```

### 9.2 `fact_forecast_snapshot`

Pro Snapshot-Lauf (täglich) berechneter Forecast pro Prozess + Aggregat.

```sql
CREATE TABLE fact_forecast_snapshot (
    id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id               UUID NOT NULL,
    snapshot_date           DATE NOT NULL,
    method                  forecast_method NOT NULL DEFAULT 'markov_stage',
    process_id              UUID NULL,                           -- NULL bei Aggregat
    aggregate_scope_type    VARCHAR(20) NULL,                    -- 'user' | 'sparte' | 'global' (NULL bei process-level)
    aggregate_scope_value   VARCHAR(80) NULL,
    placement_probability   NUMERIC(7,4) NOT NULL,               -- 0.00-1.00
    expected_revenue_chf    NUMERIC(15,2) NOT NULL,
    expected_close_date     DATE NULL,
    confidence_interval_low  NUMERIC(15,2) NULL,                 -- 5%-Quantil
    confidence_interval_high NUMERIC(15,2) NULL,                 -- 95%-Quantil
    computation_inputs_jsonb JSONB NOT NULL,                     -- alle Conversion-Raten + Inputs für Audit
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (tenant_id, snapshot_date, method, process_id, aggregate_scope_type, aggregate_scope_value)
);

CREATE INDEX idx_forecast_snap_date ON fact_forecast_snapshot(tenant_id, snapshot_date DESC);
CREATE INDEX idx_forecast_snap_process ON fact_forecast_snapshot(process_id, snapshot_date DESC) WHERE process_id IS NOT NULL;

ALTER TABLE fact_forecast_snapshot ENABLE ROW LEVEL SECURITY;
CREATE POLICY forecast_snap_tenant_visibility ON fact_forecast_snapshot
    USING (tenant_id = current_setting('app.tenant_id')::uuid);
```

---

## 10. Dashboard-Telemetrie (optional, on-demand)

### 10.1 `fact_dashboard_view_log`

Welcher User schaut welche Tile wie oft. Hilft Tile-Library zu optimieren (welche Tiles ungenutzt = streichen).

```sql
CREATE TABLE fact_dashboard_view_log (
    id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id               UUID NOT NULL,
    user_id                 UUID NOT NULL REFERENCES dim_user(id),
    page_code               VARCHAR(40) NOT NULL,
    tile_id                 UUID NULL,                           -- NULL bei Page-Load
    metric_code             VARCHAR(80) NULL,
    interaction_type        VARCHAR(20) NOT NULL,                -- 'view' | 'drill_down' | 'filter' | 'export' | 'pin'
    duration_ms             INTEGER NULL,
    metadata_jsonb          JSONB NULL,
    occurred_at             TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    retention_until         DATE NOT NULL                        -- Default 30 Tage (kurz, telemetrie-only)
);

CREATE INDEX idx_dashboard_view_user ON fact_dashboard_view_log(tenant_id, user_id, occurred_at DESC);
CREATE INDEX idx_dashboard_view_tile ON fact_dashboard_view_log(metric_code, interaction_type, occurred_at DESC) WHERE metric_code IS NOT NULL;
CREATE INDEX idx_dashboard_view_retention ON fact_dashboard_view_log(retention_until) WHERE retention_until < CURRENT_DATE;

-- Partitioniert nach Woche
-- KEIN RLS-Bedarf — Telemetrie ist tenant-intern, jeder User sieht nur eigene Aktivität via App-Layer
```

---

## 11. Read-Only Views auf bestehende Tabellen

Das Performance-Modul **schreibt nie** in fremde Tabellen. Aggregation läuft über Views, die domain-tabellen-spezifisch sind:

| View | Quelle | Inhalt | Cadence |
|------|--------|--------|---------|
| `v_pipeline_funnel` | `fact_process` × `fact_history` × `dim_process_stages` | Stage-Conversion-Counts pro Sparte/User/Mandat | live |
| `v_candidate_coverage` | `fact_history` × `dim_candidate` | letzter Touch + Soll-Frequenz pro Kandidat | live |
| `v_account_coverage` | `fact_history` × `dim_account` | letzter Touch pro Account + Decision-Maker | live |
| `v_mandate_kpi_status` | `fact_mandate` × `fact_process` | Ident/Call/Shortlist Target vs Actual | live |
| `v_revenue_attribution` | `fact_invoice` (paid) × `fact_commission_ledger` × `fact_placement` | Revenue pro CM/AM/Sparte/Mandat | live |
| `v_activity_heatmap` | `fact_history` × `dim_activity_types` × `dim_user` | Activity-Density pro MA × Tag × Type | live |
| `v_elearn_compliance` | `fact_elearn_attempt` × `fact_elearn_assignment` × `dim_user` | Compliance-Status pro MA + Aggregat | live |
| `v_zeit_utilization` | `fact_time_entry` × `fact_absence` × `dim_user` | Auslastung + Saldi + Krank-Tage | live |
| `v_hr_review_summary` | `fact_performance_reviews` (NEU im HR per Q1=C) × `dim_user` | letzte Review-Scores pro MA | live |
| `v_commission_run_rate` | `fact_commission_ledger` × `fact_placement` | Commission-Run-Rate pro MA pro Periode | live |

**Vollständige SQL-Definitionen** in `ARK_DATABASE_SCHEMA_PATCH_v1_5_to_v1_6_performance.md`.

---

## 12. Multi-Tenant + RLS

**Alle `fact_perf_*`, `fact_insight`, `fact_action_*`, `fact_report_run`, `fact_forecast_*`, `fact_dashboard_view_log`, `fact_metric_snapshot_*` und `dim_dashboard_layout` haben:**
- `tenant_id UUID NOT NULL` als Pflichtfeld
- `ENABLE ROW LEVEL SECURITY`
- Policy: `USING (tenant_id = current_setting('app.tenant_id')::uuid)`

**Stammdaten ohne Tenant-Scope (tenant-übergreifend):**
- `dim_metric_definition`
- `dim_anomaly_threshold` (Schwellen sind ARK-übergreifend, ggf. Sparten-spezifisch)
- `dim_dashboard_tile_type`
- `dim_report_template`
- `dim_powerbi_view`
- `dim_forecast_conversion_rate` (per-tenant, weil pro Sparte/Modell unterschiedlich) — **Ausnahme: hat tenant_id**

**Sub-Visibility (innerhalb Tenant):**
- `fact_perf_goal`: Self + Head (via `reports_to`) + Admin
- `fact_action_item`: Owner + Head + Admin
- `fact_insight`, `fact_report_run`, `fact_metric_snapshot_*`: alle MA tenant-weit (lesefähig — Schreiben nur Worker via Service-Account)

---

## 13. Worker

| Worker | Cron / Trigger | Schreibt | Liest |
|--------|----------------|----------|-------|
| `metric-snapshot-hourly.worker` | `15 * * * *` | `fact_metric_snapshot_hourly` | alle Live-Views (nur kritische Metriken) |
| `metric-snapshot-daily.worker` | `0 2 * * *` | `fact_metric_snapshot_daily` | alle Live-Views (alle aktiven Metriken) |
| `metric-snapshot-weekly.worker` | `0 3 * * 1` | `fact_metric_snapshot_weekly` | `fact_metric_snapshot_daily` (Aggregat) |
| `metric-snapshot-monthly.worker` | `0 4 1 * *` | `fact_metric_snapshot_monthly` | `_weekly` |
| `metric-snapshot-quarterly.worker` | `0 5 1 1,4,7,10 *` | `fact_metric_snapshot_quarterly` | `_monthly` |
| `metric-snapshot-yearly.worker` | `0 6 1 1 *` | `fact_metric_snapshot_yearly` | `_quarterly` |
| `anomaly-detector.worker` | `0 6 * * *` | `fact_insight` | `fact_metric_snapshot_*` × `dim_anomaly_threshold` |
| `action-outcome-measurer.worker` | `30 6 * * *` | `fact_action_outcome` | `fact_action_item` (state=done) × `fact_metric_snapshot_*` |
| `report-generator.worker` | event-getriggered | `fact_report_run` | `dim_report_template` + alle Snapshots |
| `forecast-recompute.worker` | `0 5 * * *` | `dim_forecast_conversion_rate` × `fact_forecast_snapshot` | `fact_history` (12 Mt Lookback) |
| `powerbi-view-refresh.worker` | per-View-Cron aus `dim_powerbi_view.refresh_cron` | Materialized Views | `dim_powerbi_view` Definitionen |
| `snapshot-retention-cleaner.worker` | `0 3 * * 0` | DELETE FROM `fact_metric_snapshot_*` WHERE `retention_until < CURRENT_DATE` | retention_until-Spalten |
| `dashboard-telemetry-rollup.worker` | `0 4 * * 0` | aggregiertes Tile-Usage in `fact_metric_snapshot_weekly` | `fact_dashboard_view_log` |

---

## 14. Events (Event-Bus)

Performance-Modul **emittiert** folgende Events (für andere Module / WS-Channels):

| Event | Trigger | Payload | Konsumenten |
|-------|---------|---------|-------------|
| `perf_insight_detected` | `anomaly-detector.worker` neue Row in `fact_insight` | `{insight_id, severity, metric_code, scope}` | Reminders-Worker (bei critical/blocker), WS-Channel `perf:insights` |
| `perf_insight_acknowledged` | UI-Action | `{insight_id, user_id}` | WS-Channel |
| `perf_action_item_created` | UI / Insight-Auto-Convert | `{action_item_id, owner_id, due_date}` | Reminders-Worker (Auto-Reminder) |
| `perf_action_item_completed` | UI-Action | `{action_item_id}` | `action-outcome-measurer.worker` (queued zur Wirkungsmessung) |
| `perf_action_outcome_measured` | `action-outcome-measurer.worker` | `{action_item_id, effect, delta_pct}` | WS-Channel `perf:actions` |
| `perf_goal_drift_detected` | `anomaly-detector.worker` für `goal_drift`-Metric | `{goal_id, drift_pct, severity}` | Reminders bei warn+ |
| `perf_report_generated` | `report-generator.worker` finished | `{report_run_id, template_code}` | WS-Channel `perf:reports`, Email-Worker zum Versand |
| `perf_report_failed` | `report-generator.worker` errored | `{report_run_id, failure_reason}` | Reminders an Admin |
| `perf_powerbi_view_refresh_failed` | `powerbi-view-refresh.worker` errored | `{view_code, error}` | Reminders an Admin (blocker-Severity) |
| `perf_snapshot_lag_critical` | Snapshot-Worker > 30min hinter Schedule | `{worker_name, lag_minutes}` | Reminders an Admin (blocker) |

Performance-Modul **konsumiert** keine fremden Events (READ-only Pattern). Stattdessen: Worker pollen Live-Views beim Snapshot-Lauf.

---

## 15. WebSocket-Channels

| Channel | Inhalt | Visibility |
|---------|--------|------------|
| `perf:insights` | Live-Insight-Stream | tenant-weit, MA sieht eigene/Team, Head Team, Admin alles |
| `perf:actions` | Action-Item-Updates + Outcome-Measurements | wie oben |
| `perf:reports` | Report-Run-Status + Generated-Notifications | tenant-weit |
| `perf:goals:{user_id}` | Goal-Status-Updates pro User | nur Self + Head + Admin |
| `perf:dashboard:{user_id}` | Tile-Refresh-Notifications (z.B. nach Snapshot-Lauf) | nur Self |

---

## 16. Sagas (mehrstufige Workflows)

### 16.1 Saga: Insight → Action → Outcome (Closed-Loop)

```
Step 1 (anomaly-detector.worker):
  - Detect anomaly → INSERT fact_insight (state=open)
  - Emit perf_insight_detected
  - Bei critical/blocker: queue Reminder

Step 2 (User UI / Auto-Convert):
  - User klickt "Massnahme erstellen" → INSERT fact_action_item (state=pending)
  - UPDATE fact_insight SET state=action_planned, audit_trail += {action_created_at, action_id}
  - INSERT fact_reminder (source_type=performance_action_item, source_id=action_id, due_date)
  - UPDATE fact_action_item SET reminder_id = new_reminder.id
  - Emit perf_action_item_created

Step 3 (User UI):
  - Owner setzt state=in_progress → UPDATE + audit
  - Owner setzt state=done → UPDATE completed_at + audit
  - Emit perf_action_item_completed
  - Trigger: queue action-outcome-measurer mit measure_after_days = 7 (oder template-spezifisch)

Step 4 (action-outcome-measurer.worker, t+7d):
  - SELECT current snapshot value für gleiche metric+scope wie ursprünglicher Insight
  - Compare zu insight.snapshot_value → calc delta
  - Bestimme effect (improved/worsened/no_change/inconclusive)
  - INSERT fact_action_outcome
  - Emit perf_action_outcome_measured

Step 5 (User UI Bestätigung):
  - Owner sieht "Wirkung gemessen: KPI von X auf Y" Drawer
  - Bestätigt oder erstellt Folge-Massnahme (follow_up_action_id)
  - Bei improved + bestätigt: UPDATE fact_insight SET state=resolved, resolved_at=NOW()
  - Bei worsened: bleibt state=action_planned, neuer Action-Item erlaubt

Failure-Handling:
  - Reminder kann nicht erstellt werden → action_item bleibt ohne reminder_id, audit-log
  - Outcome-Worker findet keinen aktuellen Snapshot → effect=inconclusive, audit-log
```

### 16.2 Saga: Pre-Built-Report-Generation (Q7=D)

```
Step 1 (Cron oder Manual-Trigger):
  - INSERT fact_report_run (state=queued, template_code, period_start, period_end)
  - Emit cron event mit report_run_id

Step 2 (report-generator.worker):
  - UPDATE state=rendering
  - SELECT alle Metriken/Views aus dim_report_template.data_bundle_spec_jsonb
  - Aggregiere zu data_bundle_jsonb
  - UPDATE fact_report_run SET data_bundle_jsonb=...
  - Call Dok-Generator-Service mit Template + Bundle → erhält PDF-Path
  - UPDATE pdf_file_path, pdf_size_bytes

Step 3 (Email-Worker via individuelles Outlook-Token):
  - SELECT dim_report_template.sender_user_id → load Outlook-Token
  - Render Email-Body aus dim_report_template.email_template_code
  - Resolve Empfänger (target_audience → User-Liste)
  - Versand via MS Graph
  - UPDATE fact_report_run SET state=sent, sent_at, sent_to_emails

Failure (any step):
  - UPDATE state=failed, failed_at, failure_reason
  - Emit perf_report_failed
  - Reminder an Admin
```

---

## 17. Endpoints (Vorschau, Detail in BACKEND-Patch)

```
# Dashboard + Tiles
GET    /api/v1/performance/dashboard/:page_code             ← rendered Layout für aktuellen User
PATCH  /api/v1/performance/dashboard/:page_code             ← User-Custom-Layout speichern
POST   /api/v1/performance/dashboard/:page_code/reset       ← zurück zu Rollen-Default
GET    /api/v1/performance/tiles/library                    ← verfügbare Tile-Typen
GET    /api/v1/performance/tiles/:tile_id/data              ← Live-Data für eine Tile

# Metrics
GET    /api/v1/performance/metrics                          ← Liste aller verfügbaren Metriken
GET    /api/v1/performance/metrics/:code/snapshot           ← aktueller Wert + Historie
GET    /api/v1/performance/metrics/:code/drill-down         ← Drill-Down zu Underlying-Entities

# Goals
GET    /api/v1/performance/goals/me                         ← eigene Goals
GET    /api/v1/performance/goals/team                       ← Team (Head)
POST   /api/v1/performance/goals                            ← Goal erstellen (Head/Admin)
PATCH  /api/v1/performance/goals/:id                        ← anpassen
DELETE /api/v1/performance/goals/:id                        ← cancellen (Soft-Delete)

# Insights + Actions
GET    /api/v1/performance/insights                         ← Liste mit Filter (severity, scope, state)
GET    /api/v1/performance/insights/:id                     ← Detail
PATCH  /api/v1/performance/insights/:id/acknowledge         ← state=acknowledged
PATCH  /api/v1/performance/insights/:id/dismiss             ← state=false_positive
POST   /api/v1/performance/insights/:id/actions             ← Action-Item erstellen → triggert Saga
GET    /api/v1/performance/actions                          ← Liste
PATCH  /api/v1/performance/actions/:id                      ← state-Update
GET    /api/v1/performance/actions/:id/outcome              ← Wirkungsmessung
POST   /api/v1/performance/actions/:id/confirm-outcome      ← bestätigen + ggf. Follow-Up

# Reports
GET    /api/v1/performance/reports/templates                ← verfügbare Templates
POST   /api/v1/performance/reports/generate                 ← manueller Trigger
GET    /api/v1/performance/reports/runs                     ← Audit-Liste
GET    /api/v1/performance/reports/runs/:id                 ← Detail + PDF-Download

# Forecast
GET    /api/v1/performance/forecast/pipeline                ← Aggregat-Forecast
GET    /api/v1/performance/forecast/process/:process_id     ← per-Prozess mit Erklärung
GET    /api/v1/performance/forecast/conversion-rates        ← Markov-Conversion-Raten Audit

# Admin
GET    /api/v1/performance/admin/metric-definitions         ← CRUD
POST   /api/v1/performance/admin/metric-definitions
PATCH  /api/v1/performance/admin/metric-definitions/:code
GET    /api/v1/performance/admin/anomaly-thresholds         ← CRUD
POST   /api/v1/performance/admin/anomaly-thresholds
PATCH  /api/v1/performance/admin/anomaly-thresholds/:id
GET    /api/v1/performance/admin/powerbi-views              ← Liste + Refresh-Status
POST   /api/v1/performance/admin/powerbi-views/:code/refresh ← manuelle Refresh
GET    /api/v1/performance/admin/snapshot-lag               ← Worker-Health
GET    /api/v1/performance/admin/dashboard-defaults         ← Rollen-Defaults
PATCH  /api/v1/performance/admin/dashboard-defaults/:role/:page

# Power-BI-Bridge (separater Endpoint, X-API-Key Auth statt JWT)
GET    /api/powerbi/views                                   ← für Power-BI-Service-Account
GET    /api/powerbi/refresh-status
```

---

## 18. Migration-Reihenfolge (für DB-Patch)

1. CREATE EXTENSIONS
2. CREATE alle ENUMs (§3)
3. CREATE Stammdaten-Tabellen (`dim_*` aus §4)
4. CREATE Snapshot-Tabellen (§5) + Partitionen für laufenden Monat
5. CREATE Goal-Tabelle (§6)
6. CREATE Insight + Action-Tabellen (§7)
7. CREATE Report-Pipeline (§8)
8. CREATE Forecast-Tabellen (§9)
9. CREATE Telemetrie (§10)
10. CREATE Read-Only-Views (§11) — können parallel zu Stammdaten
11. CREATE Materialized Views (`v_perf_*` aus `dim_powerbi_view`)
12. INSERT Seeds (Metric-Definitions, Anomaly-Thresholds, Tile-Types, Report-Templates, PowerBI-Views) — separater Stammdaten-Patch
13. ENABLE RLS + CREATE Policies
14. CREATE Worker-Service-Accounts mit `BYPASS_RLS`-Berechtigung (nur Worker-Writes)
15. GRANT Read-Only-Rolle `powerbi_reader` für Power-BI

---

## 19. Streichung aus DB v1.5 §19

Per Q1=C werden folgende Tabellen **nicht** im Performance-Modul implementiert:
- `fact_performance_reviews` → ins **HR-Modul** (eigener Patch v0.1→v0.2)
- `fact_360_feedback` → HR
- `dim_feedback_questions` → HR
- `dim_feedback_cycles` → HR
- `fact_competency_ratings` → HR
- `dim_competency_framework` → HR
- `fact_development_plans` → HR
- `fact_learning_progress` → **gestrichen** (E-Learning Sub-A `fact_elearn_attempt` ist Single-Source, kein Migration nötig)

**Dazu:** `fact_payroll`, `dim_salary_grades`, `fact_invoices`, `fact_expenses`, `dim_cost_centers` aus §19 LOHNLAUF-Block sind Billing-/Commission-Sache (existieren teils schon) — Performance liest nur via View (`v_revenue_attribution`).

---

## 20. Open Questions (post-Spec, für v0.2)

1. **Anomalie-Detection-Logik vs ML-Anomaly-Detection** — v0.1 ist regel-basiert (Threshold). Phase-3+ ggf. seasonal-aware (z.B. Sommerflaute = nicht warn).
2. **Tile-Drag-and-Drop UX** — react-grid-layout als Library? Native HTML5?
3. **Power-BI-Embed-Token-Lifecycle** — RLS-aware oder nur Read-Only-Rolle?
4. **Forecast-Kalibrierung** — Confidence-Intervall via Bootstrap? Wie viele Samples?
5. **Action-Outcome-Measurement-Window** — fix 7d oder pro Metric-Code konfigurierbar?
6. **Insight-Deduplication** — selbe Anomalie täglich → 1 Insight mit Re-Detect-Counter, nicht n neue Insights
7. **Cross-Modul-Goal-Verknüpfung** — Performance-Goal auf Mandate-KPI-Metric → wie bei Mandate-Cancel?

---

## 21. Acceptance Criteria (für Implementation)

- [ ] Alle 14 neuen Tabellen erstellt (RLS + Indizes + Constraints)
- [ ] 8 Live-Views (`v_pipeline_funnel`, etc.) erstellen + auf Read-Only-Rolle gewährt
- [ ] 12 Worker laufen (cron-getriggert oder event-getriggert)
- [ ] 5 Default-Report-Templates seeded + cron aktiviert
- [ ] 8 Default-PowerBI-Views als Materialized Views erstellt + Refresh-Worker aktiv
- [ ] Default-Dashboard-Layouts pro Rolle (ma/cm/am/ra/head/admin × 5 Pages = 30 Defaults)
- [ ] ~30 Default-Metric-Definitions seeded (siehe Stammdaten-Patch)
- [ ] ~15 Default-Anomaly-Thresholds seeded
- [ ] Snapshot-Lag-Monitoring < 30min für hourly, < 4h für daily
- [ ] PDF-Generation < 10s p95 für Wochen-/Monatsreports
- [ ] Power-BI-Read-Only-Rolle `powerbi_reader` mit Test-Connection erfolgreich
- [ ] Markov-Forecast-Backtest gegen historische 6 Monate: avg Abweichung < 25%
