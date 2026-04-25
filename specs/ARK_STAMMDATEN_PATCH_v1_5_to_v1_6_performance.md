---
title: "ARK Stammdaten-Patch v1.5 → v1.6 · Performance-Modul"
type: spec
module: performance
version: 1.6
created: 2026-04-25
updated: 2026-04-25
status: draft
sources: [
  "Grundlagen MD/ARK_STAMMDATEN_EXPORT_v1_5.md",
  "specs/ARK_PERFORMANCE_TOOL_SCHEMA_v0_1.md",
  "memory/project_performance_modul_decisions.md"
]
tags: [stammdaten, patch, performance, seeds, kpi-katalog, anomaly-thresholds, report-templates]
---

# ARK Stammdaten-Patch v1.5 → v1.6 · Performance-Modul

**Scope:** Seeds für alle Performance-Modul-Stammdaten-Tabellen + Erweiterungen der bestehenden Kataloge.

**Migrationsschritte:**

1. Neue ENUM-Sektion §F (Performance-Cadence, Anomaly-Severity, etc.)
2. Neue Stammdaten-Sektionen §80-§85 (eine pro Performance-`dim_*`-Tabelle)
3. Default-Seeds (~30 Metric-Definitions, ~15 Anomaly-Thresholds, 15 Tile-Types, 5 Report-Templates, 8 PowerBI-Views)
4. Anpassung §13 `dim_process_stages` (Markierung welche Stages für Funnel-Analyse relevant sind)

---

## 1. Neue ENUMs (§F Performance)

Siehe `ARK_PERFORMANCE_TOOL_SCHEMA_v0_1.md` §3 für vollständige ENUM-Definitionen:
- `perf_cadence` (hourly/daily/weekly/monthly/quarterly/yearly)
- `anomaly_severity` (info/warn/critical/blocker)
- `insight_state` (open/acknowledged/action_planned/resolved/false_positive/archived)
- `action_item_state` (pending/in_progress/done/cancelled/overdue)
- `outcome_effect` (improved/partially_improved/no_change/worsened/inconclusive)
- `tile_type` (15 Werte)
- `forecast_method` (markov_stage/linear_trend/ml_regression/manual)
- `metric_aggregation` (count/sum/avg/median/min/max/p95/p99/rate/ratio/ytd/mtd/wtd)
- `report_cadence` (on_demand/weekly/monthly/quarterly/yearly)
- `report_run_state` (queued/rendering/sent/failed/cancelled)
- `powerbi_view_state` (fresh/stale/refreshing/failed)

---

## 2. `dim_metric_definition` Seeds (~30 Default-Metriken)

### 2.1 Pipeline-Kategorie

| code | label_de | aggregation | unit | source_module | source_table | target_default | target_direction | drill_down |
|------|----------|-------------|------|---------------|--------------|----------------|------------------|-----------|
| `pipeline_velocity_days` | Pipeline-Geschwindigkeit (Tage) | avg | days | crm | v_pipeline_funnel | 65 | lower | process |
| `time_to_hire_days` | Time-to-Hire (Median) | median | days | crm | v_pipeline_funnel | 75 | lower | process |
| `cv_to_placement_rate` | CV → Placement Conversion | rate | % | crm | v_pipeline_funnel | 18 | higher | sparte |
| `briefing_to_go_rate` | Briefing → GO Conversion | rate | % | crm | v_pipeline_funnel | 65 | higher | sparte |
| `interview_to_offer_rate` | Interview → Offer Conversion | rate | % | crm | v_pipeline_funnel | 35 | higher | sparte |
| `monthly_placements` | Placements pro Monat | count | count | crm | fact_placement | 4 | higher | user |
| `pipeline_value_chf` | Pipeline-Wert (CHF) | sum | CHF | crm | v_revenue_attribution | NULL | higher | mandate |
| `active_processes` | Aktive Prozesse | count | count | crm | fact_process | NULL | NULL | user |

### 2.2 Revenue-Kategorie

| code | label_de | aggregation | unit | source_module | source_table | target_default | target_direction | drill_down |
|------|----------|-------------|------|---------------|--------------|----------------|------------------|-----------|
| `revenue_ytd_chf` | Umsatz YTD | ytd | CHF | billing | v_revenue_attribution | NULL | higher | sparte |
| `revenue_mtd_chf` | Umsatz MTD | mtd | CHF | billing | v_revenue_attribution | NULL | higher | sparte |
| `commission_run_rate_chf` | Commission Run-Rate | sum | CHF | commission | v_commission_run_rate | NULL | higher | user |
| `forecast_pipeline_q_chf` | Forecast Q-Ende | sum | CHF | performance | fact_forecast_snapshot | NULL | higher | user |
| `placement_avg_value_chf` | Ø Placement-Wert | avg | CHF | billing | v_revenue_attribution | NULL | higher | sparte |
| `mandate_conversion_rate` | Mandat-Conversion (Entwurf→Aktiv) | rate | % | crm | fact_mandate | 65 | higher | sparte |

### 2.3 Coverage-Kategorie

| code | label_de | aggregation | unit | source_module | source_table | target_default | target_direction | drill_down |
|------|----------|-------------|------|---------------|--------------|----------------|------------------|-----------|
| `candidate_days_since_touch` | Tage seit letztem Kandidaten-Touch | avg | days | crm | v_candidate_coverage | 30 | lower | candidate |
| `candidate_coverage_score` | Kandidaten-Coverage-Score | rate | % | crm | v_candidate_coverage | 75 | higher | sparte |
| `account_days_since_touch` | Tage seit letztem Account-Touch | avg | days | crm | v_account_coverage | 60 | lower | account |
| `account_coverage_score` | Account-Coverage-Score | rate | % | crm | v_account_coverage | 70 | higher | sparte |
| `untouched_candidates_count` | Unter-touched Kandidaten | count | count | crm | v_candidate_coverage | NULL | lower | sparte |
| `untouched_accounts_count` | Vernachlässigte Accounts | count | count | crm | v_account_coverage | NULL | lower | sparte |
| `hunt_rate_weekly` | Hunt-Rate (neue Kandidaten/Wo) | count | count | crm | fact_history | NULL | higher | user |

### 2.4 Compliance-Kategorie

| code | label_de | aggregation | unit | source_module | source_table | target_default | target_direction | drill_down |
|------|----------|-------------|------|---------------|--------------|----------------|------------------|-----------|
| `elearn_compliance_pct` | E-Learning Compliance | rate | % | elearn | v_elearn_compliance | 90 | higher | user |
| `reminder_backlog_count` | Reminder-Backlog | count | count | crm | fact_reminder | 5 | lower | user |
| `ai_confirmation_rate` | KI-Bestätigungs-Quote | rate | % | crm | fact_ai_suggestion | 80 | higher | user |
| `unclassified_calls_count` | Unklassifizierte Anrufe | count | count | crm | fact_call | 0 | lower | user |
| `agb_pending_accounts` | Accounts ohne AGB | count | count | crm | dim_account | NULL | lower | sparte |

### 2.5 Activity-Kategorie

| code | label_de | aggregation | unit | source_module | source_table | target_default | target_direction | drill_down |
|------|----------|-------------|------|---------------|--------------|----------------|------------------|-----------|
| `daily_calls_count` | Calls pro Tag | count | count | crm | v_activity_heatmap | 25 | higher | user |
| `weekly_meetings_count` | Meetings pro Woche | count | count | crm | v_activity_heatmap | 8 | higher | user |
| `weekly_briefings_count` | Briefings pro Woche | count | count | crm | v_activity_heatmap | 5 | higher | user |
| `time_utilization_pct` | Zeit-Auslastung | rate | % | zeit | v_zeit_utilization | 85 | higher | user |

### 2.6 Forecast-Kategorie

| code | label_de | aggregation | unit | source_module | source_table | target_default | target_direction | drill_down |
|------|----------|-------------|------|---------------|--------------|----------------|------------------|-----------|
| `forecast_placement_probability` | Placement-Wahrscheinlichkeit (Markov) | avg | % | performance | fact_forecast_snapshot | NULL | higher | process |
| `forecast_revenue_q_chf` | Forecast Revenue Quartal | sum | CHF | performance | fact_forecast_snapshot | NULL | higher | user |
| `goal_achievement_pct` | Goal-Erreichung | rate | % | performance | fact_perf_goal | 100 | higher | user |
| `goal_drift_pct` | Goal-Drift | rate | % | performance | fact_perf_goal × snapshots | 0 | lower | user |

### 2.7 Meta-Kategorie (System-Health)

| code | label_de | aggregation | unit | source_module | source_table | target_default | target_direction | drill_down |
|------|----------|-------------|------|---------------|--------------|----------------|------------------|-----------|
| `snapshot_lag_minutes` | Snapshot-Lag (Worker-Health) | max | min | performance | fact_metric_snapshot_* | 30 | lower | NULL |
| `powerbi_view_stale_count` | Stale Power-BI-Views | count | count | performance | dim_powerbi_view | 0 | lower | NULL |
| `failed_reports_30d` | Failed Reports 30d | count | count | performance | fact_report_run | 0 | lower | NULL |
| `data_quality_score` | Datenqualitäts-Score | rate | % | performance | meta-aggregat | 95 | higher | NULL |

**Total: ~33 Default-Metriken.** Admin kann erweitern via UI.

---

## 3. `dim_anomaly_threshold` Seeds (~15 Default-Schwellen, Q3=Y)

| metric_code | scope_type | scope_value | direction | info | warn | critical | blocker | window_d | min_sample | cooldown_h |
|-------------|------------|-------------|-----------|------|------|----------|---------|----------|------------|-----------|
| `candidate_days_since_touch` | global | NULL | above | 14 | 30 | 60 | 120 | 1 | 1 | 24 |
| `account_days_since_touch` | global | NULL | above | 30 | 60 | 90 | 180 | 1 | 1 | 24 |
| `candidate_coverage_score` | global | NULL | below | 80 | 70 | 60 | 50 | 7 | 5 | 168 |
| `account_coverage_score` | global | NULL | below | 75 | 65 | 55 | 45 | 7 | 5 | 168 |
| `goal_drift_pct` | global | NULL | below | -10 | -20 | -35 | -50 | 1 | 1 | 24 |
| `pipeline_velocity_days` | global | NULL | above | 75 | 90 | 120 | 180 | 7 | 3 | 168 |
| `time_to_hire_days` | global | NULL | above | 85 | 100 | 130 | 180 | 30 | 3 | 720 |
| `elearn_compliance_pct` | role | ma | below | 90 | 80 | 70 | 60 | 1 | 1 | 168 |
| `reminder_backlog_count` | role | ma | above | 5 | 10 | 20 | 50 | 1 | 1 | 24 |
| `unclassified_calls_count` | role | ma | above | 3 | 8 | 15 | 30 | 1 | 1 | 24 |
| `cv_to_placement_rate` | global | NULL | below | 15 | 12 | 8 | 5 | 30 | 10 | 720 |
| `mandate_conversion_rate` | global | NULL | below | 60 | 50 | 40 | 30 | 30 | 5 | 720 |
| `snapshot_lag_minutes` | global | NULL | above | 30 | 60 | 240 | 1440 | 1 | 1 | 1 |
| `failed_reports_30d` | global | NULL | above | 1 | 3 | 5 | 10 | 30 | 1 | 24 |
| `data_quality_score` | global | NULL | below | 95 | 90 | 80 | 70 | 1 | 1 | 24 |

Sparten-spezifische Overrides (z.B. `account_days_since_touch` für Sparte ARC mit anderen Schwellen) per UI nachpflegen.

---

## 4. `dim_dashboard_tile_type` Seeds (15 Tile-Types, Q5=X)

| code | label_de | min_w/h | default_w/h | requires_metric | requires_drill_down |
|------|----------|---------|-------------|------------------|---------------------|
| `kpi_card` | KPI-Karte | 2/1 | 3/2 | TRUE | FALSE |
| `kpi_card_compare` | KPI vs. Ziel | 2/1 | 3/2 | TRUE | FALSE |
| `trend_chart` | Trend-Chart | 4/2 | 6/3 | TRUE | TRUE |
| `bar_chart` | Vergleichs-Balken | 4/2 | 6/3 | TRUE | TRUE |
| `funnel` | Pipeline-Funnel | 4/3 | 6/4 | FALSE | TRUE |
| `heatmap` | Wärmekarte | 6/3 | 8/4 | TRUE | TRUE |
| `coverage_map` | Coverage-Karte | 6/3 | 8/4 | FALSE | TRUE |
| `goal_progress` | Goal-Fortschritt | 3/1 | 4/2 | TRUE | FALSE |
| `top_n_list` | Top-N-Liste | 3/2 | 4/4 | TRUE | TRUE |
| `anomaly_list` | Anomalie-Liste | 3/2 | 4/4 | FALSE | TRUE |
| `action_list` | Massnahmen-Liste | 3/2 | 4/4 | FALSE | TRUE |
| `forecast_card` | Forecast-Karte | 3/2 | 4/3 | FALSE | TRUE |
| `cohort_chart` | Cohort-Analyse | 6/3 | 8/4 | TRUE | TRUE |
| `sparkline_grid` | Mini-KPI-Grid | 4/2 | 6/2 | FALSE | FALSE |
| `iframe_powerbi` | Power-BI-Embed | 6/4 | 8/5 | FALSE | FALSE |

`config_schema_jsonb` pro Tile definiert verfügbare Filter/Optionen (z.B. `kpi_card`: `compare_to: 'previous_period' | 'target' | 'last_year' | 'none'`).

---

## 5. `dim_report_template` Seeds (5 Default-Templates, Q7=D)

| code | label_de | cadence | audience | dok_template | cron | active |
|------|----------|---------|----------|--------------|------|--------|
| `weekly_ma_report` | Wochenreport (MA) | weekly | ma_self | `perf_weekly_ma_v1` | `0 6 * * 1` | TRUE |
| `weekly_head_report` | Wochenreport (Head) | weekly | head_team | `perf_weekly_head_v1` | `0 7 * * 1` | TRUE |
| `monthly_business_report` | Monatsreport (Business) | monthly | admin | `perf_monthly_business_v1` | `0 6 1 * *` | TRUE |
| `quarterly_exec_report` | Quartals-Executive-Report | quarterly | exec | `perf_quarterly_exec_v1` | `0 6 1 1,4,7,10 *` | TRUE |
| `yearly_review_pack` | Jahres-Audit-Pack | yearly | admin | `perf_yearly_audit_v1` | `0 6 1 1 *` | FALSE |

`data_bundle_spec_jsonb` definiert pro Template welche Metriken/Snapshots/Views ins Bundle kommen (siehe `ARK_DOK_GENERATOR_*`-Specs für Template-Spec-Format).

**Email-Templates** (separat in Email-Modul) mit Codes:
- `perf_weekly_ma_email`
- `perf_weekly_head_email`
- `perf_monthly_business_email`
- `perf_quarterly_exec_email`
- `perf_yearly_audit_email`

**Sender:** Default `dim_user.role_code='admin'` (Nenad). Konfigurierbar pro Template.

---

## 6. `dim_powerbi_view` Seeds (8 Default-Views, Q4=D)

| code | label_de | refresh_cadence | refresh_cron | is_critical |
|------|----------|-----------------|--------------|-------------|
| `v_perf_pipeline_today` | Pipeline-Today (Live-KPIs) | hourly | `15 * * * *` | TRUE |
| `v_perf_goal_drift_critical` | Goal-Drift Critical | hourly | `15 * * * *` | TRUE |
| `v_perf_coverage_critical` | Coverage Critical | hourly | `15 * * * *` | TRUE |
| `v_perf_revenue_monthly` | Revenue Monthly | monthly | `0 4 1 * *` | FALSE |
| `v_perf_pipeline_funnel_daily` | Pipeline-Funnel Daily | daily | `0 2 * * *` | FALSE |
| `v_perf_cohort_hunt_vintage` | Cohort: Hunt-Vintage | weekly | `0 3 * * 1` | FALSE |
| `v_perf_activity_heatmap_weekly` | Activity-Heatmap Weekly | weekly | `0 3 * * 1` | FALSE |
| `v_perf_elearn_compliance_daily` | E-Learning-Compliance Daily | daily | `0 2 * * *` | FALSE |

`sql_definition` jeder View vollständig im Schema-Patch (`ARK_DATABASE_SCHEMA_PATCH_v1_5_to_v1_6_performance.md`).

**Visibility-Roles:** Default `{admin}` für alle Power-BI-Views (Power-BI ist Admin-Tool). MA-relevante Views via Performance-UI direkt sichtbar, nicht via Power-BI-Embed.

---

## 7. Anpassung bestehender Stammdaten

### 7.1 §13 `dim_process_stages` Erweiterung

Neue Spalten (per DB-Schema-Patch):

```sql
ALTER TABLE dim_process_stages ADD COLUMN funnel_relevance VARCHAR(20) DEFAULT 'standard';
-- Werte: 'standard' | 'major_milestone' | 'drop_off_risk' | 'terminal'

ALTER TABLE dim_process_stages ADD COLUMN avg_days_target SMALLINT;
-- Soll-Verweildauer pro Stage (für Stage-Velocity-KPI)
```

Seeds:

| stage_code | funnel_relevance | avg_days_target |
|------------|------------------|-----------------|
| `expose` | drop_off_risk | 5 |
| `cv_sent` | major_milestone | 7 |
| `ti` | drop_off_risk | 14 |
| `1st` | drop_off_risk | 14 |
| `2nd` | drop_off_risk | 14 |
| `3rd` | drop_off_risk | 21 |
| `assessment` | standard | 14 |
| `offer` | major_milestone | 7 |
| `placement` | terminal | 0 |

### 7.2 §10 `dim_user` Erweiterung (für Performance-RLS)

```sql
ALTER TABLE dim_user ADD COLUMN performance_visibility_scope VARCHAR(20) DEFAULT 'self';
-- Werte: 'self' | 'team' | 'tenant' | 'admin'
```

Seeds:
- MA / Researcher: `self`
- Head-of: `team`
- Admin: `admin`

### 7.3 Activity-Types §14 (kein Update — bestehende 64 Types bleiben)

Performance-Modul liest `fact_history` aggregiert nach `activity_type` und `entity_relevance` — keine Stammdaten-Änderung nötig.

---

## 8. Migration-Reihenfolge (Stammdaten-Patch)

1. INSERT/UPDATE neue ENUM-Werte (siehe SCHEMA §3)
2. INSERT in `dim_metric_definition` (~33 Rows)
3. INSERT in `dim_dashboard_tile_type` (15 Rows)
4. INSERT in `dim_anomaly_threshold` (~15 Rows)
5. INSERT in `dim_report_template` (5 Rows)
6. INSERT in `dim_powerbi_view` (8 Rows)
7. ALTER TABLE `dim_process_stages` (funnel_relevance + avg_days_target)
8. UPDATE `dim_process_stages` SET funnel_relevance, avg_days_target
9. ALTER TABLE `dim_user` (performance_visibility_scope)
10. UPDATE `dim_user` SET performance_visibility_scope (per Rolle)
11. INSERT initialer Default-Layouts in `dim_dashboard_layout` (Rolle/Page-Defaults — kann auch via Admin-UI gemacht werden, optional)

---

## 9. Validierung

Nach Patch:

```sql
-- Anzahl Seeds prüfen
SELECT category, COUNT(*) FROM dim_metric_definition GROUP BY category;
-- Erwartet: pipeline=8, revenue=6, coverage=7, compliance=5, activity=4, forecast=4, meta=4

SELECT COUNT(*) FROM dim_anomaly_threshold;     -- 15
SELECT COUNT(*) FROM dim_dashboard_tile_type;   -- 15
SELECT COUNT(*) FROM dim_report_template;       -- 5
SELECT COUNT(*) FROM dim_powerbi_view;          -- 8

-- Foreign-Key-Integrität
SELECT * FROM dim_anomaly_threshold a
LEFT JOIN dim_metric_definition m ON a.metric_code = m.code
WHERE m.code IS NULL;  -- erwartet 0 Rows

-- Funnel-Relevance-Coverage
SELECT funnel_relevance, COUNT(*) FROM dim_process_stages GROUP BY funnel_relevance;
```

---

## 10. Lint-Konformität

- **Stammdaten-Wording-Regel:** Alle Labels Deutsch, keine Anglizismen ausser etablierte Fachterme (KPI, Pipeline, Forecast)
- **Umlaute-Regel:** echte Umlaute in label_de
- **DB-Tech-Details-Regel:** code-Spalten technisch (snake_case), label_de für UI immer sprechend

---

## 11. Acceptance Criteria

- [ ] 33 Metric-Definitions seeded + alle source_table-Refs auf existierende Tabellen/Views
- [ ] 15 Anomaly-Thresholds seeded + alle metric_code-Refs valid
- [ ] 15 Tile-Types seeded mit config_schema_jsonb
- [ ] 5 Report-Templates seeded + Cron-Strings validiert
- [ ] 8 PowerBI-Views seeded mit refresh_cron
- [ ] dim_process_stages erweitert um funnel_relevance + avg_days_target
- [ ] dim_user erweitert um performance_visibility_scope
- [ ] Migration idempotent (re-runnable ohne Duplicate-Errors)
