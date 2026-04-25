---
title: "Performance-Modul · Konzept"
type: concept
created: 2026-04-25
updated: 2026-04-25
sources: [
  "Grundlagen MD/ARK_GESAMTSYSTEM_UEBERSICHT_v1_5.md",
  "Grundlagen MD/ARK_DATABASE_SCHEMA_v1_6.md",
  "Grundlagen MD/ARK_BACKEND_ARCHITECTURE_v2_8.md",
  "Grundlagen MD/ARK_FRONTEND_FREEZE_v1_13.md",
  "Grundlagen MD/ARK_STAMMDATEN_EXPORT_v1_6.md",
  "specs/ARK_PERFORMANCE_TOOL_SCHEMA_v0_1.md",
  "specs/ARK_PERFORMANCE_TOOL_INTERACTIONS_v0_1.md"
]
tags: [concept, performance, analytics, kpi, forecast, closed-loop, phase-3-erp]
---

# Performance-Modul

Cross-Modul-Analytics-Hub für die ARK CRM-Suite. Zentralisiert Pipeline-, Coverage-, Revenue-, Compliance- und Activity-Daten aus allen ERP-Tools (CRM, HR, Zeit, Commission, Billing, E-Learning) in einer einzelnen Sicht. **Nicht** HR-Reviews — die laufen weiterhin im HR-Modul (siehe Memory `project_performance_modul_decisions.md` und Q1=C-Entscheidung).

Read-only auf alle Domain-Tabellen. Schreibt nur in eigene Artefakte: Snapshots, Insights, Action-Items, Outcomes, Goals, Forecasts, Reports.

## Warum existiert das Modul?

Vor dem Performance-Modul lebten KPIs verteilt: Pipeline-Counts im CRM-Dashboard, Coverage-Heatmaps in Excel-Exports, Revenue-Run-Rate in Bexio, Compliance-Status nirgends sichtbar. Heads und Admin/GL mussten 5 Tools manuell vergleichen, um eine Quartal-Sicht zusammenzubauen — pro Sparte, pro MA, pro Mandat-Typ. Das war fehleranfällig und produzierte Reaktions-Statt-Aktion-Patterns.

Das Performance-Modul löst drei Schmerzpunkte:

1. **Single-View-Aggregation:** Alle Zahlen aus dem Gesamtsystem in einer Sicht — drei Sicht-Ebenen (System · Business · MA) plus Self-Cockpit für jeden MA.
2. **Closed-Loop-Massnahmen:** Anomalie wird nicht nur angezeigt, sondern führt zu einem Action-Item mit Owner, Due-Date und automatischer Wirkungsmessung 7 Tage später (Q6=D).
3. **Forecast statt Rückspiegel:** Markov-Stage-Model v0.1 berechnet erwarteten Quartal-Umsatz pro aktiver Pipeline — auditierbar, jede Conversion-Rate nachvollziehbar (Q8=E).

## Wer benutzt es?

| Rolle | Sicht | Use-Case |
|---|---|---|
| **MA** | `performance-mitarbeiter.html` (Self) | Eigener Cockpit · Pipeline / Goals / Compliance / Aktivität / Commission · 6-Tab |
| **Head** | `performance-team.html` + Self-Cockpit | Team-Aggregat + Per-MA-Vergleich · 1:1-Vorbereitung · Bulk-Goals |
| **Admin/GL** | `performance-business.html` + `performance-admin.html` | Sparten-Vergleich · Revenue/Forecast · Konfiguration (Schwellen, Workers, Forecast-Modell) |
| **Alle** | `performance-insights.html` | Closed-Loop · Anomalien-Triage · eigene Massnahmen |
| **PowerBI/BO** | `/api/powerbi/views` (X-API-Key) | Custom-Reports · Cross-Tenant (intern) |

Visibility-Scope wird auf der `dim_user.performance_visibility_scope`-Spalte gepflegt: `self` (MA/Researcher/CM/AM), `team` (Head), `tenant` (Admin), `admin` (Super-Admin).

## Architektur-Entscheidungen (8 Decisions vom 2026-04-25)

Acht zentrale Wahlen, alle bestätigt und in Memory `project_performance_modul_decisions.md` festgehalten. Sie definieren den Modul-Scope und sollten bei jeder Performance-Modul-Arbeit gegen-geprüft werden.

### Q1 = C · DB §19-Stubs Migration

8 HR-Performance-Stubs aus DB §19 (Phase-2-Scaffold-Block) wurden vollständig **ins HR-Modul** migriert: `fact_performance_reviews`, `fact_360_feedback`, `dim_feedback_questions`, `dim_feedback_cycles`, `fact_competency_ratings`, `dim_competency_framework`, `fact_development_plans`. Drei weitere Stubs (`fact_learning_progress`, `dim_learning_modules`, `dim_skill_certifications`) wurden gestrichen — E-Learning Sub-A ist Single-Source.

Konsequenz: Performance-Modul = Analytics-Hub. HR-Reviews = HR-Modul. Klare Modul-Trennung, Zero-Overlap.

### Q2 = C · Operative vs. Karriere-Goals

Hybrid-Lösung: **Performance-Goals** (operativ, Q2-Placements / Calls pro Woche / Coverage-Score) leben im Performance-Modul (`fact_perf_goal`). **Development-Goals** (Karriere, lang) leben im HR-Modul (`fact_development_plans`). Live-Tracking nur für operative Goals — Karriere-Goals haben Review-Cycle-Charakter.

### Q3 = C + Y · Anomalie-Severity

4-stufig: `info` / `warn` / `critical` / `blocker`. Schwellen leben in `dim_anomaly_threshold` (15 Default-Schwellen seeded, Sparten-/Rollen-Overrides via Admin). Cooldown-Logik im `anomaly-detector.worker` verhindert Flooding.

### Q4 = D · PowerBI-Update-Frequenz

Hybrid-Cron: **Nightly-Rollup** 02:00 + **Hourly-Critical** :15 für 3 Critical-Views (`mv_perf_pipeline_today` · `mv_perf_goal_drift_critical` · `mv_perf_coverage_critical`). Per-View-Cron in `dim_powerbi_view.refresh_cron`. Read-Only-Rolle `powerbi_reader`. ETL-Worker `powerbi-view-refresh.worker` per BullMQ.

### Q5 = D + X · Dashboard-Pattern

Rollen-Default + User-Override + Locked-Tiles (Compliance-Pflicht). 15 hardcoded Tile-Types (`dim_dashboard_tile_type`), Layouts via `dim_dashboard_layout` (scope `system_default` / `role_default` / `user_custom`). Reset → Rollen-Default. Tiles gefüttert aus `dim_metric_definition` (33 Default-Metriken in 7 Kategorien).

### Q6 = D · Closed-Loop für Massnahmen

`fact_insight` → `fact_action_item` (Hypothese, Owner, Due) → Auto-Reminder via Cross-Link → `fact_action_outcome` (verzögert via `action-outcome-measurer.worker`, Default 7 Tage nach `state=done`) → `state=resolved` oder Folge-Action. Saga atomar in einer TX (Insight-State-Update + Action-Insert + Reminder).

### Q7 = D · Reports

Pre-Built-Templates via Pipeline (Performance → Dok-Generator → Email + `fact_report_run`-Audit). 5 Default-Templates: `weekly_ma`, `weekly_head`, `monthly_business`, `quarterly_exec`, `yearly_review_pack`. Bundle-Spec via `data_bundle_spec_jsonb`. Email-Versand via individuelle User-Outlook-Tokens (Sender konfigurierbar). Custom-Reports laufen ausserhalb via Power-BI.

### Q8 = E · Forecast-Methode

Markov-Stage-Model v0.1 — erklärbar, jede Conversion-Rate auditierbar:

```
P(placement) = ∏ conversion_rate(stage_i → stage_i+1) × time_decay
time_decay   = exp(-days_in_current_stage / avg_days_current_stage)
expected_revenue = honorar(expected_salary) × P(placement)
confidence_interval = expected_revenue × [0.75, 1.25]
```

`forecast-recompute.worker` läuft täglich 05:00, berechnet Conversion-Raten neu (12-Monats-Lookback per Sparte/Business-Model), dann pro Prozess + Aggregate (User/Sparte/Global). ML-Upgrade (logistic regression, gradient boosting) ab Phase 3+.

## Saubere Modul-Trennung (Zero-Overlap)

| Funktion | Modul |
|----------|-------|
| Operative Pipeline (Stages, Reminders, Activities) | CRM |
| Quick-KPI-Tiles (Top-Level pro Rolle) | CRM-Dashboard |
| Tiefen-Analytics (Drill-Down, Cohorts, Funnels, Heatmaps) | **Performance** |
| Custom Reports / Ad-hoc | Power-BI (über Performance-Views) |
| Personal-Stammdaten / Verträge / Onboarding / Disziplinar | HR |
| Performance-Reviews / 360° / Goal-Cycles / Competency / Development | HR (NEU per Q1=C) |
| Lernen / Compliance / Curriculum | E-Learning |
| Provisions-Berechnung + Auszahlung | Commission |
| Stempel / Saldi / Absenzen | Zeit |
| Rechnungen / Mahnungen / Refunds | Billing |
| Periodische Reports (Pipeline) | **Performance** → Dok-Generator → Email |
| Massnahmen / Action-Items mit Wirkungsmessung | **Performance** |

## Datenquellen

Performance liest cross-modular über 10 Live-Views und 8 Materialized Views:

| Quelle | Daten | View(s) |
|---|---|---|
| `fact_history` × `dim_activity_types` | Touch-Frequenz · Activity-Heatmap · Coverage | `v_activity_heatmap`, `v_candidate_coverage`, `v_account_coverage` |
| `fact_process` × `dim_process_stages` × `dim_user` | Pipeline-Funnel · Konversionen · Stage-Days | `v_pipeline_funnel` |
| `fact_placement` + `fact_invoice` + `fact_commission_ledger` | Revenue · Time-to-Hire · Commission-Refs | `v_revenue_attribution`, `v_commission_run_rate` |
| `fact_mandate` × `fact_process` × `fact_history` × `fact_placement` | Ident-Targets · Calls · Shortlist · Revenue | `v_mandate_kpi_status` |
| `dim_account` (purchase_potential ★/★★/★★★) | Coverage-Scope auf Account-Seite | `v_account_coverage` |
| `dim_candidate` | Coverage-Scope auf Kandidaten-Seite | `v_candidate_coverage` |
| `ark_elearn.*` | Pflicht-Kurs-Compliance · Newsletter-Quizzes · Active Certs | `v_elearn_compliance` |
| `fact_time_entries` + `fact_absences` × `dim_user` | Hours-worked vs target · Sick/Vacation-Days | `v_zeit_utilization` |
| `ark_hr.*` | Performance-Reviews-Aggregat (HR-Brücke) | `v_hr_review_summary` |

```
┌─────────┐ ┌─────────┐ ┌──────────┐ ┌──────┐ ┌────┐ ┌─────────┐
│   CRM   │ │ Billing │ │ Commission│ │ Zeit │ │ HR │ │ E-Learn │
└────┬────┘ └────┬────┘ └─────┬────┘ └──┬───┘ └──┬─┘ └────┬────┘
     │           │           │           │        │        │
     └────┬──────┴────┬──────┴─────┬────┘        │        │
          ▼           ▼            ▼              ▼        ▼
       ┌──────────────────────────────────────────────────────┐
       │ Performance-Modul · ark_perf-Schema                   │
       │   v_*-Views (live) + mv_*-Views (materialized)         │
       │   fact_metric_snapshot_* (hourly→yearly)               │
       │   fact_insight · fact_action_item · fact_action_outcome│
       │   fact_perf_goal · fact_forecast_snapshot              │
       │   fact_report_run · fact_dashboard_view_log            │
       └──────────────────────────────────────────────────────┘
                              │
                ┌─────────────┼─────────────┐
                ▼             ▼             ▼
           Frontend       Power-BI       Dok-Generator
           (11 Pages)     (X-API-Key)    (Email-Versand)
```

## Datenmodell-Highlights (TEIL Q DB-Schema v1.6)

14 neue Tabellen im `ark_perf`-Schema + 7 HR-Performance-Tabellen migriert ins `ark_hr`-Schema.

**6 Stammdaten-Tabellen:**
- `dim_metric_definition` — 33 aktive Metric-Codes mit Quelle, Aggregat, Cadence
- `dim_anomaly_threshold` — 15 Default-Schwellen (info/warn/critical/blocker)
- `dim_dashboard_tile_type` — 15 Tile-Types
- `dim_dashboard_layout` — Default-Layouts pro Rolle/Page (system_default/role_default/user_custom)
- `dim_report_template` — 5 Pre-Built-Templates
- `dim_powerbi_view` — 8 Default-Views mit per-View-Cron
- `dim_forecast_conversion_rate` — Markov-Conversion-Raten (12-Mt-Lookback)

**6 Snapshot-Tabellen** (partitioniert nach Monat, append-only):
- `fact_metric_snapshot_hourly` / `daily` / `weekly` / `monthly` / `quarterly` / `yearly`

**Insight-Loop + Goals + Reports + Telemetrie:**
- `fact_perf_goal` — operative Goals mit Drift-Tracking
- `fact_insight` — Anomalien (severity / scope / threshold / state)
- `fact_action_item` — Massnahmen mit Reminder-Verknüpfung
- `fact_action_outcome` — Wirkungs-Messung (baseline → after)
- `fact_report_run` — Report-Versand-History (state-machine)
- `fact_forecast_snapshot` — Quartal-Forecasts pro Sparte/User/Global
- `fact_dashboard_view_log` — Audit-Logging für Self-Optimierung

**Erweiterungen bestehender Tabellen:**
- `dim_process_stages` + `funnel_relevance`, `avg_days_target`
- `dim_user` + `performance_visibility_scope`

**RLS:** alle `fact_perf_*` und User-bezogene `dim_perf_*` mit `tenant_id` und `FORCE ROW LEVEL SECURITY`. Visibility-Scope-Filter additiv (`self` / `team` / `tenant` / `admin`).

## Backend-Architektur (TEIL R v2.8)

~50 Performance-Endpoints unter `/api/v1/performance/*` plus 2 Power-BI-Bridge-Endpoints (`/api/powerbi/*`, X-API-Key Auth, separate von JWT).

**12 Performance-Worker + 1 HR-Cycle-Worker:**

| Worker | Cron / Trigger | Zweck |
|--------|----------------|-------|
| `metric-snapshot-hourly.worker` | `15 * * * *` | nur Metriken mit `cadence='hourly'` |
| `metric-snapshot-daily.worker` | `0 2 * * *` | Vollschnitt + Goal-Achievement-Update |
| `metric-snapshot-weekly.worker` | `0 2 * * 1` | aggregiert aus daily |
| `metric-snapshot-monthly/quarterly/yearly` | analog | rollup |
| `anomaly-detector.worker` | `0 6 * * *` | Threshold-Verletzungen → `perf_insight_detected` (Cooldown) |
| `action-outcome-measurer.worker` | event `perf_action_item_completed` (delayed) | misst Improvement nach `measure_after_days` (Default 7d) |
| `report-generator.worker` | event `perf_report_generate` | rendert PDF + Email-Versand |
| `forecast-recompute.worker` | `0 5 * * *` | Markov-Conversion-Raten + Process-Forecast + Aggregate |
| `powerbi-view-refresh.worker` | per-View-Cron | `REFRESH MATERIALIZED VIEW CONCURRENTLY` |
| `snapshot-retention-cleaner.worker` | `0 3 * * 0` | DELETE wo `retention_until < CURRENT_DATE` |
| `partition-creator.worker` | `0 0 1 * *` | erstellt Snapshot-Partitionen für nächste 3 Monate |
| `dashboard-telemetry-rollup.worker` | `0 4 * * 0` | aggregiert Tile-Usage für Self-Optimierung |
| `review-cycle-lifecycle.worker` (HR) | event `hr_review_cycle_activated` | erstellt Reviews + Reminders, eskaliert |

**10 Performance-Events + 5 HR-Review-Events** (auf dem Event-Bus):

`perf_insight_detected` · `perf_insight_acknowledged` · `perf_action_item_created` · `perf_action_item_completed` · `perf_action_outcome_measured` · `perf_goal_drift_detected` · `perf_report_generate` · `perf_report_generated` · `perf_report_failed` · `perf_powerbi_view_refresh_failed` · `perf_snapshot_lag_critical`.

**5 Performance-WS-Channels:** `perf:insights` · `perf:actions` · `perf:reports` · `perf:goals:{user_id}` · `perf:dashboard:{user_id}`.

**3 Sagas:** Closed-Loop (Insight→Action→Outcome) · Pre-Built-Report-Pipeline · HR-Review-Cycle-Lifecycle.

### Closed-Loop-Saga (Q6=D, das Herzstück)

```
[anomaly-detector.worker erkennt Schwellen-Verletzung]
  → INSERT fact_insight (state=open)
  → emit perf_insight_detected
  → Reminders-Worker erstellt fact_reminder bei critical+
  → User klickt "Massnahme erstellen"
  → atomare TX: INSERT fact_action_item + UPDATE fact_insight state=action_planned
                + INSERT fact_reminder + UPDATE fact_action_item.reminder_id
  → Owner setzt state=done
  → emit perf_action_item_completed (mit measure_after_days)
  → action-outcome-measurer.worker (delayed 7d) → INSERT fact_action_outcome
  → User bestätigt Wirkung
  → fact_insight.state=resolved
  ODER bei worsened/no_change: Folge-Massnahme
```

**Failure:** Step-2-TX rollt komplett zurück, Action nicht erstellt, Insight bleibt acknowledged. Step 4 ohne Snapshot → `effect='inconclusive'`, Owner sieht "Daten nicht verfügbar — manuell bewerten".

## Frontend-Pattern (TEIL Q Frontend-Freeze v1.13)

11 Mockups in `mockups/ERP Tools/performance/`:

| Page | Rolle | Beschreibung |
|---|---|---|
| `performance.html` | alle | Hub-Shell (iframe-Embed analog HR/Zeit/Commission) |
| `performance-dashboard.html` | alle (gefiltert) | Customizable Tile-Grid (15 Tile-Types) |
| `performance-insights.html` | alle | Closed-Loop · Anomalien + Massnahmen |
| `performance-funnel.html` | alle | Pipeline-Stage-Conversion mit Drop-Off |
| `performance-coverage.html` | alle | Schweizkarte 26 Kantone (TopoJSON-CDN) · Owner × Sparte |
| `performance-mitarbeiter.html` | MA + Head/Admin (read-only) | Self-Cockpit 6-Tab |
| `performance-team.html` | Head + Admin | 4 MA-Cards + Bulk-Goals |
| `performance-revenue.html` | Head + Admin | Revenue YTD + Markov-Forecast |
| `performance-business.html` | Admin | Sparten-Vergleich · Strategy |
| `performance-reports.html` | alle (eigene), Admin (alle) | Templates + Run-History |
| `performance-admin.html` | Admin only | 6-Sub-Tab Konfiguration |

**Konventionen (per Frontend-Freeze v1.13):**
- Hub-Shell mit Sub-Pages-iframe-Embed — Sub-Pages haben **keine eigene App-Bar** (Theme-Toggle vom Hub-Topbar)
- Snapshot-Bar 6-Slot pro Page
- Drawer-Default 540px slide-in (per CLAUDE.md Drawer-Default-Regel)
- Tab-Pattern `gold-strong`
- 6-Sub-Tab-Layout für Admin-Page
- Editorial-Tokens via `mockups/_shared/editorial.css` (canonical cool-blue Accent #1A3A5C, Gold #B8860B, Bg #F4F5F7)
- Sample-Daten zentral via `mockups/_shared/perf-sample-data.js` (`window.ARK_PERF.*`) — Backend-Connect-Migration: tausche `window.ARK_PERF.*` gegen `GET /api/v1/performance/*` (Daten-Shape kompatibel)

**Routing:**

```
Topbar-Toggle: CRM ↔ ERP

ERP-Workspace:
  /erp/performance/*
    ├── /dashboard      Performance-Cockpit
    ├── /insights       Insight-Loop-Inbox
    ├── /funnel         Pipeline-Funnel-Drilldown
    ├── /coverage       Schweizer Geo-Heatmap (TopoJSON-CDN)
    ├── /mitarbeiter    MA-Profil mit Reviews-Tab
    ├── /team           Team-Aggregat (Head)
    ├── /revenue        Revenue-Attribution + Forecast
    ├── /business       Business-Dashboard
    ├── /reports        Report-Templates + Run-Audit
    └── /admin          6-Sub-Tab Admin-Konfiguration
```

## Closed-Loop-Pattern als Kern-Wert

Ohne Closed-Loop wäre Performance nur noch ein Reporting-Tool — KPIs anschauen, vielleicht ein Excel-Export, fertig. Closed-Loop macht das Modul zum Operational-Excellence-Tool, weil jede Anomalie zu einer messbaren Massnahme führt.

Beispiel-Narrativ (typischer Q2-2026-Tag):

> Coverage ARC fällt unter 50%. Der `anomaly-detector.worker` erkennt das um 06:00 (Schwelle `critical` aus `dim_anomaly_threshold`). INSERT `fact_insight` mit severity=critical, scope=`sparte=ARC`, threshold-Ref. Event `perf_insight_detected` triggert WS `perf:insights` und Reminders-Worker erstellt einen `fact_reminder` für Head LR.
>
> Im Performance-Insights-Feed erscheint die Insight-Card. Head LR klickt "Massnahme erstellen" und tippt "Touch-Sweep für 8 ARC-Kandidaten, Owner=PW, Due=+3d". Atomare TX: `INSERT fact_action_item` + `UPDATE fact_insight state=action_planned` + Reminder verlinkt.
>
> PW arbeitet die 8 Kandidaten ab, setzt `state=done`. Event `perf_action_item_completed` mit `measure_after_days=7` queued den `action-outcome-measurer.worker`.
>
> 7 Tage später: Worker liest aktuellen Coverage-Snapshot, vergleicht gegen Baseline. Coverage ARC: 50% → 65%. INSERT `fact_action_outcome` mit `effect=improved`, `delta=+15pp`. WS `perf:actions` pusht Update zu Head und Admin.
>
> Head bestätigt Wirkung: `UPDATE fact_insight state=resolved`. Stat geht in den Wirkung-Ø der `dim_metric_definition` für Coverage-Massnahmen ein. Beim nächsten Mal weiss das System: "Touch-Sweep funktioniert für ARC-Coverage-Drift im Schnitt mit +12pp in 7 Tagen."

Das ist kein KPI-Dashboard. Das ist eine selbst-lernende Pipeline für operative Eingriffe.

## Forecast-Methodik (Markov-Stage-Model v0.1)

Pro aktivem Prozess wird die aktuelle Stage erfasst. Aus historischen Konversionsraten (`dim_forecast_conversion_rate`, 12-Monats-Lookback per Sparte/Business-Model) ergibt sich eine Placement-Wahrscheinlichkeit. Multipliziert mit dem erwarteten TC-Salär × Honorar-Fee = erwarteter Revenue. Time-Decay-Faktor zieht Prozesse, die zu lange in einer Stage hängen, ab.

Beispiel: Stage `TI` → 17.8% Placement-Wahrscheinlichkeit über 90 Tage. Stage `Offer` → 78%. Stage `Expose` → 4.2%. Aggregation aller aktiven Prozesse pro User/Sparte/Global. Konfidenz-Intervall vereinfacht ±25%.

Vorteil: erklärbar. Jede Conversion-Rate auditierbar in `dim_forecast_conversion_rate`. Wenn Forecast-Sample zu klein (< `min_sample_size`, Default 5), Fallback auf `linear_trend` oder `manual` mit Warning.

ML-Upgrade Phase 3+ geplant: Bayesian-Update-Modelle, Personalisierung pro Owner-Performance-Profil, Logistic-Regression mit Feature-Engineering (Touch-Frequenz, Mandat-Typ, Sparte, Stage-Days).

## Stammdaten-Statistik (v1.6 kumulativ)

```
Performance ENUMs:           11 neue
Performance Tabellen:        14 (ark_perf.*) + 7 HR-Performance (ark_hr.*) − 3 gestrichen
Live-Views:                  10 (ark_perf.v_*)
Materialized Views:           8 (ark_perf.mv_*)
Default-Seeds:               76 Rows (33 Metric-Defs + 15 Thresholds + 15 Tiles + 5 Templates + 8 PowerBI)
Endpoints:                  ~50 (Performance) + ~30 (HR-Reviews-Erweiterung) + 2 (Power-BI-Bridge)
Worker:                      12 Performance + 1 HR-Cycle
Events:                      10 Performance + 5 HR-Reviews
WS-Channels:                  5 Performance + 2 HR
Sagas:                        3 (Closed-Loop · Pre-Built-Report · Review-Cycle)
Mockup-Pages:                11 (1 Hub + 10 Sub-Pages, alle ohne eigene App-Bar)
```

## Cross-Links

**Specs:**
- `specs/ARK_PERFORMANCE_TOOL_SCHEMA_v0_1.md` (DDL + Worker-Defs, 1076 Z.)
- `specs/ARK_PERFORMANCE_TOOL_INTERACTIONS_v0_1.md` (UI-Interaction-Specs, 484 Z.)
- `specs/ARK_PERFORMANCE_TOOL_MOCKUP_PLAN.md` (Mockup-Inventar)

**Patches (alle v1.5 → v1.6 / v2.7 → v2.8 / v1.12 → v1.13):**
- `specs/ARK_STAMMDATEN_PATCH_v1_5_to_v1_6_performance.md`
- `specs/ARK_DATABASE_SCHEMA_PATCH_v1_5_to_v1_6_performance.md`
- `specs/ARK_BACKEND_ARCHITECTURE_PATCH_v2_7_to_v2_8_performance.md`
- `specs/ARK_FRONTEND_FREEZE_PATCH_v1_12_to_v1_13_performance.md`
- `specs/ARK_GESAMTSYSTEM_PATCH_v1_4_to_v1_5_performance.md`
- HR-Tool-Schema-Patch v0.1 → v0.2 (für Q1=C-Migration)

**Memory:**
- `project_performance_modul_decisions.md` (8 Architektur-Entscheidungen)
- `feedback_phase3_modules_separate.md` (Phase-3-ERP-Module separat von CRM)
- `project_phase3_erp_standalone.md` (Phase-3-Module sind eigenständige ARK-Produkte)
- `feedback_mockup_first_workflow.md` (Phase-3-ERP: Spec-First, nicht Mockup-First)

**Wiki-Verwandtes:**
- [[interaction-patterns]] — Drawer-Default, Snapshot-Bar, Tab-Pattern
- [[frontend-architektur]] — Hub-Shell-Pattern, Sub-Pages-iframe-Embed
- [[event-system]] — Event-Bus, fact_history vs. Performance-Events
- [[automationen]] — Worker, Cron-Trigger, Eskalation
- [[reminders]] — Cross-Modul-Reminder-Verknüpfung (Insights → Action-Items)
- [[sync-report-2026-04-25]] — Drift-Status nach Performance-Modul-Mockup-Phase

## Roadmap

- ✅ **Phase 3.1 (2026-04-25):** Mockup-Phase + Spec-Bundle + Grundlagen-Sync · 11 funktionale Mockups · 5 Grundlagen synced (v1.6 / v2.8 / v1.13 / v1.5) · 5 Digests regeneriert · Sample-Data zentralisiert · Drawers funktional · Smoke 22/22 grün
- ⏳ **Phase 3.2 (Q3 2026):** Backend-Implementation · DB-Migration · 12 Worker + Cron-Trigger · BullMQ-Queues · Initial-Snapshot-Lauf (Backfill) · Power-BI-Bridge mit X-API-Key · Frontend-Deploy · Power-BI-View-Layer-Ausbau · Custom-Tile-Builder · zusätzliche Reports
- ⏳ **Phase 3.3 (Q4 2026):** ML-Forecast-Upgrade (Bayesian-Models, Logistic-Regression) · Cross-Tenant-Benchmarking (intern) · AI-Insight-Empfehlungen · pro-Owner-Personalisierung
- ⏳ **Phase 3.4 (2027+):** Mobile-Adaption · Push-Notifications für critical+ Insights · Voice-Briefing für Self-Cockpit

## Status

**Stand 2026-04-25:** Mockup-Phase komplett (11 funktionale Mockups in `mockups/ERP Tools/performance/`). 5 Grundlagen-Files synced auf v1.6 / v2.8 / v1.13 / v1.5. 5 Digests regeneriert. Sample-Data zentralisiert in `mockups/_shared/perf-sample-data.js`. Drawer funktional (alle CRUD via 540px-Drawer per Default-Regel). Smoke-Tests 22/22 grün. **Bereit für Backend-Implementation (Phase 3.2).**
