---
title: "ARK Gesamtsystem-Patch v1.4 → v1.5 · Performance-Modul"
type: spec
module: performance
version: 1.5
created: 2026-04-25
updated: 2026-04-25
status: draft
sources: [
  "Grundlagen MD/ARK_GESAMTSYSTEM_UEBERSICHT_v1_4.md",
  "specs/ARK_PERFORMANCE_TOOL_SCHEMA_v0_1.md",
  "specs/ARK_PERFORMANCE_TOOL_INTERACTIONS_v0_1.md",
  "specs/ARK_STAMMDATEN_PATCH_v1_5_to_v1_6_performance.md",
  "specs/ARK_DATABASE_SCHEMA_PATCH_v1_5_to_v1_6_performance.md",
  "specs/ARK_BACKEND_ARCHITECTURE_PATCH_v2_7_to_v2_8_performance.md",
  "specs/ARK_FRONTEND_FREEZE_PATCH_v1_12_to_v1_13_performance.md",
  "specs/ARK_HR_TOOL_SCHEMA_PATCH_v0_1_to_v0_2.md",
  "memory/project_performance_modul_decisions.md",
  "memory/feedback_phase3_modules_separate.md",
  "memory/project_phase3_erp_standalone.md"
]
tags: [gesamtsystem, patch, performance, cross-modul-analytics, decisions, markov-forecast, powerbi, hub]
---

# ARK Gesamtsystem-Patch v1.4 → v1.5 · Performance-Modul

**Scope:** Big-Picture-Sync. Performance-Modul als Cross-Modul-Analytics-Hub im ERP-Workspace, 8 Architektur-Entscheidungen 2026-04-25, Reuse-Tabellen, Markov-Forecast v0.1, Data-Pipeline via PowerBI-Materialized-Views. Eingebettet im ERP-Tools-Toggle als eigene Hub-Page.

**Append-Ziel:** TEIL 26 in `Grundlagen MD/ARK_GESAMTSYSTEM_UEBERSICHT_v1_5.md`.

---

## 1. Modul-Charakteristik

**Performance-Modul = Cross-Modul-Analytics-Hub:**
- **NICHT** HR-Reviews (die leben im HR-Modul `ark_hr.fact_performance_reviews` u.a. — Q1=C-Migration aus DB §19)
- **NICHT** E-Learning (Single-Source via Sub A-D, Performance liest nur `v_elearn_compliance`)
- **NICHT** Zeit/Commission/Billing (alles eigene Module, Performance liest read-only)
- **IST** zentraler Analytics-Hub: KPIs, Insights, Goals, Reports, Forecast quer durch alle Module
- **Read-only** auf alle Quell-Module via Live-Views + Materialized Views (Power-BI Layer)

Memory: `project_performance_modul_decisions.md`.

---

## 2. Reuse vs. Eigenes

**Reuses Stammdaten (keine Duplikation):**
- Sparten ARC/GT/ING/PUR/REM (`§8`)
- MA-Kürzel (`dim_user.label_de`, 2-Buchstaben-Display)
- Process-Stages aus `dim_process_stages` (Erweiterung um `funnel_relevance`, `avg_days_target`)
- Mandat-Typen Target/Taskforce/Time
- Activity-Types aus `dim_activity_types` (`fact_history`-Aggregation)
- Roles MA/Head/Admin/BO
- Honorar-Settings (Commission-Engine)

**Eigene Stammdaten (neu in v1.6):**
- 33 Default-Metriken in 7 Kategorien
- 15 Anomaly-Thresholds
- 15 Tile-Types
- 5 Report-Templates
- 8 PowerBI-Views

---

## 3. Cross-Modular Daten-Flüsse

| Quelle | Konsumiert von Performance via |
|--------|-------------------------------|
| CRM (`fact_process`, `fact_history`, `fact_placement`) | `v_pipeline_funnel` · `v_candidate_coverage` · `v_account_coverage` · `v_mandate_kpi_status` · `v_activity_heatmap` |
| Billing (`fact_invoice`) | `v_revenue_attribution` |
| Commission (`fact_commission_ledger`) | `v_commission_run_rate` · `v_revenue_attribution` |
| Zeit (`fact_time_entries`, `fact_absences`) | `v_zeit_utilization` |
| E-Learning (`fact_elearn_attempt`, `fact_elearn_assignment`, `fact_elearn_certificate`) | `v_elearn_compliance` |
| HR (`fact_performance_reviews`, `fact_competency_ratings`, `fact_development_plans`) | `v_hr_review_summary` |

---

## 4. 8 Architektur-Entscheidungen 2026-04-25

| ID | Entscheidung | Wert | Begründung |
|----|--------------|------|-----------|
| **Q1** | HR-Performance-Reviews vs. Performance-Modul | **C** — alle Reviews ins HR-Modul | 8 Phase-2-Stub-Tabellen aus DB §19 migriert, Domain-Konsistenz: HR = "Mensch + Vertrag", Performance = "Daten + Trends" |
| **Q2** | Goals — operativ oder strategisch? | **C** — Hybrid | Operative Performance-Goals (Quartal/Monat) im Performance-Modul (`fact_perf_goal`); strategische Karriere-Goals im HR (`fact_development_plans`) — verschiedene Lebenszyklen |
| **Q3** | Anomaly-Detector-Default | **Y** — 15 Default-Schwellen seeded | Cold-Start vermeiden, Admin pflegt Sparten-/Rollen-Overrides per UI |
| **Q4** | PowerBI-Refresh-Strategie | **D** — per-View-Cron in `dim_powerbi_view.refresh_cron` | ETL-Worker `powerbi-view-refresh.worker` per BullMQ; 3 Critical-Views hourly, andere daily/weekly/monthly |
| **Q5** | Tile-Customization | **X** — 15 Default-Tile-Types + User-Custom-Layout | `dim_dashboard_layout` mit `scope='user_custom'`; Reset → Rollen-Default |
| **Q6** | Closed-Loop-Insight-Workflow | **D** — Saga: Insight → Action → Outcome | `action-outcome-measurer.worker` verzögert (Default 7d); resolve oder Folge-Action |
| **Q7** | Report-Templates | **D** — 5 Default + Bundle-Spec | weekly_ma/weekly_head/monthly_business/quarterly_exec/yearly_review; Email via individuelles Outlook-Token (Sender konfigurierbar) |
| **Q8** | Forecast-Method | **E** — Markov-Stage-Model v0.1 | Conversion-Rate × Time-Decay; Konfidenz ±25%; ML-Upgrade Phase 3+ |

---

## 5. Statistik

```
Performance ENUMs:           11 neue
Performance Tabellen:        14 (ark_perf.*)
HR-Performance-Tabellen:      7 (migriert aus DB §19 ins ark_hr)
Gestrichen:                   3 (fact_learning_progress, dim_learning_modules, dim_skill_certifications)
Live-Views:                  10 (ark_perf.v_*)
Materialized Views:           8 (ark_perf.mv_*)
Default-Seeds:               76 Rows
Endpoints:                  ~50 Performance + ~30 HR-Reviews + 2 Power-BI-Bridge
Worker:                      12 Performance + 1 HR-Cycle
Events:                      10 Performance + 5 HR-Reviews
WS-Channels:                  5 Performance + 2 HR
Sagas:                        3 (Closed-Loop · Pre-Built-Report · Review-Cycle)
Mockup-Pages:                10 (1 Hub + 9 Sub-Pages, alle ohne App-Bar)
Tabellen total v1.6:       ~225 (215 v1.5 + 14 ark_perf + 7 ark_hr Performance-Reviews − 3 gestrichen)
```

---

## 6. Routing-Übersicht

```
Topbar-Toggle: CRM ↔ ERP

ERP-Workspace:
  /erp/zeit/*           → Zeit-Modul
  /erp/billing/*        → Billing-Modul
  /erp/elearn/*         → E-Learning-Modul (Sub A-D)
  /erp/hr/*             → HR-Modul (inkl. Performance-Reviews)
  /erp/performance/*    → Performance-Modul (NEU v1.5)
    ├── /dashboard      Performance-Cockpit (Default-Tiles + User-Override)
    ├── /insights       Insight-Loop-Inbox
    ├── /funnel         Pipeline-Funnel-Drilldown
    ├── /coverage       Schweizer Geo-Heatmap (TopoJSON-CDN)
    ├── /mitarbeiter    MA-Profil mit Reviews-Tab (v_hr_review_summary)
    ├── /team           Team-Aggregat (Head)
    ├── /revenue        Revenue-Attribution
    ├── /business       Business-Dashboard (Sparte/Modell-Vergleich)
    ├── /reports        Report-Templates + Run-Audit
    └── /admin          6-Sub-Tab Admin-Konfiguration
```

Hub-Pattern (analog HR/Zeit/E-Learning): `mockups/ERP Tools/performance/performance.html` lädt Sub-Pages via iframe; Sub-Pages haben keine App-Bar.

---

## 7. Markov-Forecast v0.1

```
P(placement) = ∏ conversion_rate(stage_i → stage_i+1) × time_decay
time_decay   = exp(-days_in_current_stage / avg_days_current_stage)
expected_revenue = honorar(expected_salary) × P(placement)
confidence_interval = expected_revenue × [0.75, 1.25]
```

`forecast-recompute.worker` läuft täglich 05:00, berechnet:
1. Conversion-Raten neu (12-Mt-Lookback per Sparte/Business-Model) → `dim_forecast_conversion_rate`
2. Pro aktivem Prozess Markov-Forecast → `fact_forecast_snapshot` mit `process_id`
3. Aggregate (User/Sparte/Global) → `fact_forecast_snapshot` mit `aggregate_scope_*`

ML-Upgrade (logistic regression, gradient boosting, neuronale Conversion-Modelle) ab Phase 3+.

---

## 8. Data-Pipeline (PowerBI als ETL-Source)

PowerBI-Materialized-Views in `ark_perf.mv_*` sind ETL-Source-of-Truth für externe BI-Tools.

| MV | Cadence | Critical |
|----|---------|----------|
| `mv_perf_pipeline_today` | hourly | ✓ |
| `mv_perf_goal_drift_critical` | hourly | ✓ |
| `mv_perf_coverage_critical` | hourly | ✓ |
| `mv_perf_revenue_monthly` | monthly | ✗ |
| `mv_perf_pipeline_funnel_daily` | daily | ✗ |
| `mv_perf_cohort_hunt_vintage` | weekly | ✗ |
| `mv_perf_activity_heatmap_weekly` | weekly | ✗ |
| `mv_perf_elearn_compliance_daily` | daily | ✗ |

Refresh via `powerbi-view-refresh.worker` (per-View-Cron in `dim_powerbi_view.refresh_cron`). Power-BI-Service-Account authentifiziert via X-API-Key (separate Auth, nicht JWT) → `GET /api/powerbi/views`.

---

## 9. Closed-Loop-Saga (Insight → Action → Outcome)

```
1. anomaly-detector.worker (Cron 06:00)
   → INSERT fact_insight (state='open')
   → emit perf_insight_detected
   → bei critical+: createReminder

2. UI/User: POST /performance/insights/:id/actions
   → atomare TX:
       INSERT fact_action_item
       UPDATE fact_insight SET state='action_planned'
       INSERT fact_reminder mit Cross-Link
       UPDATE fact_action_item SET reminder_id
   → emit perf_action_item_created

3. UI/User: PATCH /performance/actions/:id state='done'
   → emit perf_action_item_completed mit measure_after_days (Default 7)

4. action-outcome-measurer.worker (verzögert)
   → INSERT fact_action_outcome
   → effect: improved | partially_improved | no_change | worsened | inconclusive

5. UI/User: POST /performance/actions/:id/confirm-outcome
   → UPDATE fact_action_outcome SET confirmed_by_user_id, confirmed_at
   → bei effect=improved+confirmed: UPDATE fact_insight SET state='resolved'
   → bei follow_up: GOTO Step 2 (neue Action)
```

Failure-Handling: Step 2 TX rollback bei Reminder-Service-Failure → Insight bleibt acknowledged. Step 4 ohne Snapshot → effect='inconclusive', User entscheidet manuell.

---

## 10. Mockup-Inventar Phase 1 (alle erstellt)

```
mockups/ERP Tools/performance/
  performance.html              ← Hub
  performance-dashboard.html
  performance-insights.html
  performance-funnel.html
  performance-coverage.html     ← TopoJSON-CDN
  performance-mitarbeiter.html
  performance-team.html
  performance-revenue.html
  performance-business.html
  performance-reports.html
  performance-admin.html        ← 6 Sub-Tabs
```

---

## 11. Phase-Status (2026-04-25)

| Artefakt | Status |
|----------|--------|
| Mockups (10 HTMLs) | ✓ |
| Performance-Spec v0.1 (Schema) | ✓ |
| Performance-Spec v0.1 (Interactions) | ✓ |
| Mockup-Plan | ✓ |
| Stammdaten-Patch v1.5→v1.6 | ✓ |
| DB-Schema-Patch v1.5→v1.6 | ✓ |
| Backend-Patch v2.7→v2.8 | ✓ |
| HR-Tool-Schema-Patch v0.1→v0.2 | ✓ |
| Frontend-Freeze-Patch v1.12→v1.13 | ✓ (NEU dieser Patch) |
| Gesamtsystem-Patch v1.4→v1.5 | ✓ (NEU dieser Patch) |
| Grundlagen v1.6/v2.8/v1.13/v1.5 gemerged | ✓ (Sync 2026-04-25 21:15) |
| Implementation Phase-3 | ⏳ ausstehend |

---

## 12. Memory-Verweise

- `project_performance_modul_decisions.md` — 8 Architektur-Entscheidungen 2026-04-25
- `feedback_phase3_modules_separate.md` — ERP-Module separat von CRM, eigene Hub-Pages
- `project_phase3_erp_standalone.md` — Phase-3-ERP-Module sind eigenständige ARK-Produkte
- `feedback_claude_design_no_app_bar.md` — Sub-Pages haben keine App-Bar
- `feedback_mockup_first_workflow.md` — Phase-3-ERP: Spec-First (vermeidet Mockup-Iterationen)
- `project_email_kalender_architecture.md` — Outlook-Token-Pattern für Email-Versand (Reports)

---

## 13. Acceptance Criteria

- [ ] TEIL 26 in `ARK_GESAMTSYSTEM_UEBERSICHT_v1_5.md` appendet
- [ ] Sync-Matrix in `wiki/meta/spec-sync-regel.md` aktualisiert
- [ ] Memory `project_performance_modul_decisions.md` referenziert
- [ ] 8 Q-Entscheidungen dokumentiert
- [ ] Reuse-Tabelle vollständig
- [ ] Cross-Modular Daten-Flüsse mit konkreten View-Referenzen
- [ ] Markov-Formel + Time-Decay dokumentiert
- [ ] Closed-Loop-Saga 5-Step
- [ ] Routing-Übersicht inkl. Hub-Pattern
- [ ] Mockup-Inventar Phase 1
