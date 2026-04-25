---
title: "ARK Performance-Modul · Interactions v0.1"
type: spec
module: performance
version: 0.1
created: 2026-04-25
updated: 2026-04-25
status: draft
sources: [
  "specs/ARK_PERFORMANCE_TOOL_SCHEMA_v0_1.md",
  "memory/project_performance_modul_decisions.md",
  "wiki/concepts/interaction-patterns.md",
  "specs/ARK_HR_TOOL_INTERACTIONS_v0_1.md",
  "mockups/ERP Tools/commission/commission-dashboard.html",
  "mockups/ERP Tools/elearn/elearn-admin-analytics.html"
]
tags: [spec, interactions, performance, drawers, dashboards, anomaly-loop, reports, forecast, powerbi]
---

# ARK Performance-Modul · Interactions v0.1

**Schema-Referenz:** [ARK_PERFORMANCE_TOOL_SCHEMA_v0_1.md](ARK_PERFORMANCE_TOOL_SCHEMA_v0_1.md)

---

## 1. Seitenstruktur (11 Pages)

| # | Page | Datei | Beschreibung | Audience |
|---|------|-------|--------------|----------|
| 1 | Performance-Hub | `performance.html` | Sidebar-Navigation, Tool-Tab-Router | alle |
| 2 | Dashboard | `performance-dashboard.html` | Tile-Grid (customizable, Locked-Tiles) | alle |
| 3 | Pipeline-Funnel | `performance-funnel.html` | Stage-Conversion mit Drop-Off + Drill-Down | alle |
| 4 | Coverage | `performance-coverage.html` | Kandidaten/Kunden-Vernachlässigungs-Heatmap | alle |
| 5 | Revenue + Forecast | `performance-revenue.html` | Revenue-Attribution + Markov-Forecast | head/admin |
| 6 | Team-View | `performance-team.html` | Team-KPIs für Head | head/admin |
| 7 | Mitarbeiter-Self | `performance-mitarbeiter.html` | Self-View (eigene Pipeline + Goals + Compliance + Commission-Run) | ma + Spiegel im head/admin |
| 8 | Business-View | `performance-business.html` | Sparten/Markt-Sicht | head/admin |
| 9 | Insights + Massnahmen | `performance-insights.html` | Anomalie-Liste + Closed-Loop-Action-Tracking | alle (gefiltert) |
| 10 | Reports | `performance-reports.html` | Pre-Built-Templates + History + Manual-Trigger | alle (eigene), admin (alle) |
| 11 | Admin | `performance-admin.html` | Metric-Definitions + Dashboard-Defaults + PowerBI-View-Mgmt + Anomalie-Schwellen | admin only |

---

## 2. Sidebar-Layout (`performance.html`)

```
┌─ ARK Performance ─────────────────┐
│                                   │
│  ⊙ Dashboard                      │
│                                   │
│  📊 Analyse                       │
│  ├─ Pipeline-Funnel               │
│  ├─ Coverage                      │
│  ├─ Revenue + Forecast            │
│  └─ Business-View                 │
│                                   │
│  👥 Personen                      │
│  ├─ Mein Performance              │
│  └─ Team (nur Head/Admin)         │
│                                   │
│  💡 Insights                      │
│  ├─ Anomalien                     │
│  └─ Meine Massnahmen              │
│                                   │
│  📑 Reports                       │
│                                   │
│  ⚙ Admin (Admin only)             │
│  ├─ Metriken                      │
│  ├─ Anomalie-Schwellen            │
│  ├─ Dashboard-Defaults            │
│  └─ Power-BI-Views                │
│                                   │
└───────────────────────────────────┘
```

Aktive Page-Highlight + Counter-Badges (z.B. "💡 Insights · 7 offen", "📑 Massnahmen · 3 überfällig").

---

## 3. KPI-Bar (Snapshot-Bar) Slots pro Page

Pattern wie alle ARK-Vollansichten: Snapshot-Bar mit 4-6 Slots oben (siehe Mockup-Baseline).

| Page | Slot 1 | Slot 2 | Slot 3 | Slot 4 | Slot 5 | Slot 6 |
|------|--------|--------|--------|--------|--------|--------|
| Dashboard | KPI-Score (Gesamt-Health) | Insights offen | Massnahmen überfällig | Goal-Erreichung MTD | Compliance % | Forecast Q-Ende |
| Funnel | Konversionsrate gesamt | Time-to-Hire Median | Drop-Off-Stage worst | Top-Sparte | Bottom-Sparte | Pipeline-Wert |
| Coverage | Kandidaten unter-touched | Kunden vernachlässigt | Coverage-Score Ø | Anteil aktiv kontaktiert (30d) | Top-vernachlässigte Sparte | Hunt-Rate (neue/Wo) |
| Revenue | Revenue YTD | vs Vorjahr | Forecast Jahresende | Top-Mandant | Top-Sparte | Pipeline-Coverage (Ratio Forecast/Soll) |
| Team | Team-Pipeline-Wert | Goal-Erreichung Team | Anomalien Team | Aktivität diese Woche | Team-Compliance | Forecast Q-Ende Team |
| Mitarbeiter | Mein Pipeline-Wert | Meine Goal-Erreichung | Meine Anomalien | Meine Aktivität | Meine Compliance | Mein Forecast Q-Ende |
| Business | Revenue/Sparte | Conversion/Sparte | Markt-Coverage | Top-Mandant Sparte | Aktive Mandate | Pipeline-Wert/Sparte |
| Insights | Offene Insights | Critical | Blocker | Resolved (30d) | Wirkung Ø | False-Positive-Rate |
| Reports | Reports diesen Monat | Pending Versand | Failed | Templates aktiv | Cron-Jobs aktiv | Letzter Run |
| Admin | aktive Metriken | aktive Schwellen | PowerBI-Views fresh | PowerBI-Views stale | Worker-Lag max | Snapshot-Volumen (GB) |

---

## 4. Drawer-Inventar (540px slide-in rechts, per Drawer-Default-Regel)

### 4.1 Dashboard-Bereich

| Drawer-ID | Trigger | Inhalt | Schema-Entität |
|-----------|---------|--------|----------------|
| `drawer-tile-add` | "+ Tile" Button im Customize-Mode | Tile-Library-Picker, Metric-Auswahl, Filter, Position | `dim_dashboard_tile_type` + `dim_dashboard_layout` |
| `drawer-tile-edit` | Klick auf Tile-Settings-Icon | Tile-Config bearbeiten (Filter, Granularität, Compare-To) | `dim_dashboard_layout.layout_jsonb[tile]` |
| `drawer-tile-explain` | Klick auf "?" Icon einer Tile | Erklärung: Welche Metric, welche Quell-Tabelle, welche Aggregation, Drill-Down-Pfad | `dim_metric_definition` |
| `drawer-tile-drill` | Klick auf Tile-Hauptbereich | Drill-Down zur Underlying-Entity-Liste mit Filter | dynamisch |

### 4.2 Funnel-Bereich

| Drawer-ID | Trigger | Inhalt | Schema-Entität |
|-----------|---------|--------|----------------|
| `drawer-funnel-stage` | Klick auf Funnel-Stage | Liste der Prozesse in dieser Stage + Drop-Off-Analysis + Owner | `v_pipeline_funnel` |
| `drawer-funnel-process` | Klick auf einzelnen Prozess in Stage-Liste | Process-Detail-Preview (verlinkt zu CRM-Vollansicht) | `fact_process` |
| `drawer-funnel-cohort` | Klick auf "Cohort-Analysis" | Vintage-Performance über Zeit | `fact_metric_snapshot_*` cohort-aggregates |

### 4.3 Coverage-Bereich

| Drawer-ID | Trigger | Inhalt | Schema-Entität |
|-----------|---------|--------|----------------|
| `drawer-coverage-candidate` | Klick auf Kandidaten-Cell | Kandidat-Coverage-Detail: letzte Touches, Soll-Frequenz, Verlauf, Aktion-CTAs | `v_candidate_coverage` |
| `drawer-coverage-account` | Klick auf Account-Cell | Account-Coverage-Detail | `v_account_coverage` |
| `drawer-coverage-bulk-action` | "Massenaktion" Button | Bulk-Action: alle markierten unter-touched Kandidaten → Reminder/Assignment | dynamisch |

### 4.4 Revenue + Forecast

| Drawer-ID | Trigger | Inhalt | Schema-Entität |
|-----------|---------|--------|----------------|
| `drawer-revenue-attribution` | Klick auf Revenue-Bar-Segment | Detail: Welche Mandate/Placements/Invoices fliessen rein | `v_revenue_attribution` |
| `drawer-forecast-explain` | "?" auf Forecast-Card | Markov-Erklärung: jede Stage-Rate sichtbar, Conversion-Pfade, Annahmen | `fact_forecast_snapshot.computation_inputs_jsonb` |
| `drawer-forecast-process` | Klick auf einzelnen Prozess in Forecast-Liste | Per-Prozess Markov-Decomposition: 32% Placement-Wahrscheinlichkeit · CHF 22k expected · Erklärung jede Stage-Rate | `fact_forecast_snapshot` |
| `drawer-forecast-override` | "Manuell überschreiben" (Admin/Head) | User setzt manuelle Forecast-Werte mit Begründung | `fact_forecast_snapshot` (method=manual) |

### 4.5 Team / Mitarbeiter

| Drawer-ID | Trigger | Inhalt | Schema-Entität |
|-----------|---------|--------|----------------|
| `drawer-team-member` | Klick auf MA-Row in Team-Liste | MA-Performance-Snapshot: Pipeline + Goals + Aktivität + Compliance + Run-Rate | `dim_user` × diverse Views |
| `drawer-goal-new` | "+ Goal erstellen" | Metric-Auswahl, Periode, Target, Owner, Beschreibung | `fact_perf_goal` |
| `drawer-goal-edit` | Klick auf Goal | Goal anpassen (oder cancellen mit Begründung) | `fact_perf_goal` |
| `drawer-goal-progress` | Klick auf Goal-Progress-Bar | Verlauf, Snapshot-Historie, Drift-Analysis | `fact_metric_snapshot_*` |

### 4.6 Insights + Massnahmen (Closed-Loop, Q6=D)

| Drawer-ID | Trigger | Inhalt | Schema-Entität |
|-----------|---------|--------|----------------|
| `drawer-insight-detail` | Klick auf Insight-Row | Vollständige Insight-Info: Snapshot zum Detect-Zeitpunkt, Severity, Threshold, Recommended-Action, Related-Entities, Acknowledge/Dismiss/Action-Buttons | `fact_insight` |
| `drawer-action-create` | "Massnahme erstellen" aus Insight-Drawer | Action-Form: Title, Hypothese, Geplante Intervention, Owner, Due-Date | `fact_action_item` |
| `drawer-action-detail` | Klick auf Action-Item | Action-Detail: Status, Verlauf, verlinkter Insight, Outcome (wenn vorhanden) | `fact_action_item` |
| `drawer-action-update` | "Status ändern" oder "Notiz" | State-Transition (pending → in_progress → done) + Notes | `fact_action_item` |
| `drawer-outcome-confirm` | "Wirkung bestätigen" Button (erscheint nach Auto-Measurement) | Outcome-View: Baseline vs After + Effect + Confirm/Follow-Up-Buttons | `fact_action_outcome` |
| `drawer-action-followup` | "Folge-Massnahme" (bei worsened/no_change) | Pre-filled Action-Form mit Insight-Ref und Bezug zu Vorgänger-Action | `fact_action_item` (mit follow_up_action_id) |

### 4.7 Reports

| Drawer-ID | Trigger | Inhalt | Schema-Entität |
|-----------|---------|--------|----------------|
| `drawer-report-trigger` | "Manuell generieren" | Template-Wahl, Periode, Empfänger-Override | `dim_report_template` + `fact_report_run` (queued) |
| `drawer-report-run-detail` | Klick auf Report-Run in History | Run-Detail: State, Period, PDF-Download, Versand-Empfänger, Failure-Reason wenn failed | `fact_report_run` |
| `drawer-report-template-config` (Admin) | Klick auf Template | Cron-Edit, Empfänger-Override, Sender-Token-Auswahl, Active-Toggle | `dim_report_template` |
| `drawer-report-template-new` (Admin) | "+ Template" | Vollständig neue Template-Definition (data_bundle_spec_jsonb, Dok-Generator-Template-Ref, Email-Template-Ref) | `dim_report_template` |

### 4.8 Admin

| Drawer-ID | Trigger | Inhalt | Schema-Entität |
|-----------|---------|--------|----------------|
| `drawer-metric-edit` | Klick auf Metric in Admin-Liste | Metric-Definition bearbeiten (Aggregation, Target-Default, Visibility-Roles, Cadence) | `dim_metric_definition` |
| `drawer-metric-new` | "+ Metric" | Neue Metric-Definition komplett (mit SQL-Snippet falls custom) | `dim_metric_definition` |
| `drawer-anomaly-threshold` | Klick auf Threshold-Row | Schwellen-Edit: info/warn/critical/blocker pro Scope | `dim_anomaly_threshold` |
| `drawer-dashboard-default` | Klick auf Rollen-Default | Tile-Layout-Editor für Rolle/Page mit Lock-Toggle pro Tile | `dim_dashboard_layout` (scope=role_default) |
| `drawer-powerbi-view` | Klick auf View-Row | View-Edit (SQL, Refresh-Cron, Critical-Flag), Manual-Refresh-Button, Refresh-Status-Audit | `dim_powerbi_view` |
| `drawer-snapshot-lag` | Klick auf Worker-Health-Indikator | Worker-Status, Lag-Historie, Failure-Rate, Restart-Button | `fact_metric_snapshot_*` Audit + Worker-Logs |

**Total: ~30 Drawer.**

---

## 5. Kern-Flows

### 5.1 Flow A: Customize-Dashboard (Q5=D Hybrid)

```
1. User auf Dashboard, klickt "Anpassen" Toggle
2. Tiles bekommen Drag-Handles + Settings-Icons
3. User klickt "+ Tile" → drawer-tile-add
   - wählt Tile-Type aus Library
   - wählt Metric aus dim_metric_definition (gefiltert nach visibility_roles)
   - konfiguriert (Filter, Granularität, Compare-To)
   - klickt Speichern → INSERT/UPDATE dim_dashboard_layout (scope=user_custom)
4. User dragt Tiles → Position-Updates in Layout-JSONB
5. User klickt Settings-Icon → drawer-tile-edit
6. Locked-Tiles (admin-pinned) zeigen Lock-Icon, kein Settings/Drag
7. User klickt "Reset" → DELETE user_custom Layout → Fallback zu Rollen-Default
8. User klickt "Anpassen Beenden" → Toggle aus, Layout wird Read-Only
```

### 5.2 Flow B: Anomalie-Detection → Massnahme → Wirkung (Q6=D Closed-Loop)

```
Tag 0 (06:00):
  - anomaly-detector.worker läuft
  - Findet: Sparte ARC Coverage von 78% auf 62% gefallen über 4 Wochen
  - Severity = critical (gemäss dim_anomaly_threshold)
  - INSERT fact_insight
  - Emit perf_insight_detected
  - Reminders-Worker erzeugt Reminder an Head ARC

Tag 0 (User-Sicht):
  - Head ARC bekommt Reminder + WS-Notification "💡 Critical Insight: Coverage ARC"
  - Klickt im Performance-Modul auf Insights-Page → sieht Insight in Top-Position
  - Klickt → drawer-insight-detail öffnet
  - Sieht: Snapshot-Wert, Threshold, Related-Entities (Liste der unter-touched Kandidaten/Accounts), Recommended-Action
  - Klickt "Acknowledge" → state=acknowledged, audit-log
  - Klickt "Massnahme erstellen" → drawer-action-create
    - Title: "Coverage ARC heben"
    - Hypothese: "Mehr Hunting auf ARC-Kandidaten"
    - Geplante Intervention: "Researcher PW arbeitet 5h/Wo zusätzlich an ARC"
    - Owner: Head ARC
    - Due: Tag 0 + 14d
  - Klickt Erstellen → INSERT fact_action_item (state=pending)
  - System: UPDATE fact_insight SET state=action_planned
  - System: INSERT fact_reminder (Cross-Link zu action_item.id)
  - System: UPDATE fact_action_item SET reminder_id = new_reminder.id
  - drawer-insight-detail aktualisiert sich live (WS perf:insights)

Tag 0-14 (Owner arbeitet):
  - Owner sieht Reminder in Reminders-Modul ("Performance: Coverage ARC heben · 14d")
  - Klick auf Reminder → öffnet drawer-action-detail in Performance-Modul
  - Owner setzt state=in_progress (z.B. nach erstem Briefing-Termin)
  - Optional: Notes hinzufügen, Owner-Wechsel, Due verschieben (mit Begründung)

Tag 14 (Owner closed):
  - Owner setzt state=done
  - System emittiert perf_action_item_completed
  - System queued action-outcome-measurer mit measure_after_days=7

Tag 21 (Auto-Measurement):
  - action-outcome-measurer.worker läuft
  - Liest fact_metric_snapshot_daily für Metric "candidate_coverage_score" Scope=sparte/ARC
  - Vergleicht Tag 0 (62%) vs Tag 21 (z.B. 75%)
  - delta_absolute=13, delta_percentage=20.97%, effect=improved
  - INSERT fact_action_outcome
  - Emit perf_action_outcome_measured
  - WS-Notification an Owner "✓ Wirkung gemessen: Coverage ARC von 62% auf 75% gestiegen"

Tag 21 (Owner Bestätigung):
  - Owner sieht Notification, klickt → drawer-outcome-confirm
  - Sieht: Baseline 62% → After 75% → Effect: improved → Hypothese bestätigt
  - Klickt "Wirkung bestätigen" → confirmed_at, confirmed_by_user_id
  - System: UPDATE fact_insight SET state=resolved, resolved_at
  - Insight verschwindet aus Open-Liste, erscheint in Resolved-Liste mit Erfolgs-Markierung

Variation: Effect=worsened (Coverage auf 58% gefallen)
  - Owner sieht "✗ Massnahme ohne Wirkung — Coverage von 62% auf 58% gefallen"
  - Klickt "Folge-Massnahme erstellen" → drawer-action-followup
  - Pre-filled mit Insight-Ref + Vorgänger-Action-Ref
  - Owner formuliert neue Hypothese (z.B. "Hunting nicht ausreichend, Markt-Recherche nötig")
  - INSERT fact_action_item (mit follow_up_action_id auf vorherige Action)
  - Insight bleibt state=action_planned, neuer Action-Loop startet
```

### 5.3 Flow C: Goal-Setting + Auto-Tracking (Q2=C)

```
Quartal-Start (manuelle Action durch Head):
  1. Head öffnet Performance-Modul → Team-Page → MA-Row
  2. Drawer-team-member zeigt MA-Snapshot
  3. Head klickt "+ Goal" → drawer-goal-new
  4. Wählt Metric (z.B. "monthly_placements")
  5. Periode: 2026-Q3 (01.07.-30.09.)
  6. Target: 4 Placements
  7. Direction: higher
  8. Beschreibung: optional
  9. Speichern → INSERT fact_perf_goal (set_by_user_id = Head, user_id = MA)
  10. WS-Notification an MA "Neues Goal: 4 Placements bis 30.09."

Während Periode:
  - metric-snapshot-daily.worker schreibt täglich neuen Snapshot für "monthly_placements" pro User
  - Beim Snapshot: liest aktive fact_perf_goal für User+Periode → berechnet target_achievement_pct
  - MA-Self-Page zeigt Goal-Progress-Bar in Snapshot-Bar + Goal-Liste

Drift-Detection:
  - anomaly-detector.worker prüft täglich auf Goal-Drift (delta vs erwarteter Verlauf)
  - z.B. Tag 30 (33% Quartal): erwartet ~1.3 Placements, tatsächlich 0
  - Erzeugt Insight "Goal-Drift kritisch: Placements 100% unter Soll"
  - Severity je nach dim_anomaly_threshold

Periode-Ende:
  - Final-Snapshot-Wert wird gegen Target verglichen
  - target_achievement_pct ist final
  - Goal "expired" — bleibt in Historie für Vergleiche
  - Kein automatischer Goal-Renewal — Head entscheidet bewusst
```

### 5.4 Flow D: Pre-Built-Report-Generation (Q7=D)

```
Cron-Trigger (Mo 06:00 für weekly_ma_report):
  1. Performance-Modul-Cron emittiert "perf:cron:weekly_ma_report"
  2. report-generator.worker fängt Event
  3. Resolve target_audience=ma_self → für jeden aktiven MA:
     - INSERT fact_report_run (template_code=weekly_ma_report, period_start=letzte Mo, period_end=letzte So)
     - state=queued
  4. Worker arbeitet Queue ab:
     - state=rendering
     - Aggregiere Bundle: eigene Pipeline-KPIs, Goal-Status, Activity, Anomalien (eigene Scope)
     - data_bundle_jsonb = {pipeline: {...}, goals: [...], activity: {...}, insights: [...]}
     - Call Dok-Generator-Service mit Template "weekly_ma_report" + Bundle
     - Erhält PDF-Path
     - UPDATE fact_report_run SET pdf_file_path, pdf_size_bytes
  5. Email-Worker via individuelles Outlook-Token:
     - Sender = dim_report_template.sender_user_id (Default: Admin)
     - Empfänger = aktiver MA Email
     - Subject + Body aus dim_report_template.email_template_code
     - PDF als Attachment
     - Versand via MS Graph
     - UPDATE fact_report_run SET state=sent, sent_at, sent_to_emails
  6. Emit perf_report_generated → WS-Channel perf:reports
  7. MA sieht im Reports-Page: "Wochenreport vom 24.04.-25.04. · sent · PDF-Download"

Manual-Trigger (User-Action):
  1. User auf Reports-Page → "Manuell generieren" Button → drawer-report-trigger
  2. Wählt Template, Periode (Default: aktuelle Periode aus Cadence), Empfänger-Override
  3. Klickt Generieren → POST /api/v1/performance/reports/generate
  4. Same Pipeline ab Step 3 oben

Failure (z.B. Dok-Generator-Service down):
  1. Worker setzt state=failed, failure_reason
  2. Emit perf_report_failed
  3. Reminder an Admin
  4. User sieht im Reports-Page: "Wochenreport · failed · Retry-Button"
```

### 5.5 Flow E: Forecast-Drill-Down (Q8=E)

```
1. User auf Revenue-Page sieht Forecast-Card "Q3 Pipeline ~ CHF 480k"
2. Klickt "?" → drawer-forecast-explain öffnet
3. Sieht:
   - Aggregat-Forecast: 480k CHF (Konfidenz-Intervall 380k-580k)
   - 47 aktive Prozesse berücksichtigt
   - Top-5 Prozesse mit höchster Wahrscheinlichkeit (sortiert nach expected_revenue × placement_probability)
4. Klickt auf einzelnen Prozess in Liste → drawer-forecast-process
5. Sieht Markov-Decomposition:
   - Aktuell in Stage "1st Interview"
   - Verbleibende Stages: 1st → 2nd → Offer → Placement
   - Conversion-Raten: 0.65 × 0.55 × 0.32 = 11.4% Placement-Wahrscheinlichkeit
   - Expected-Honorar (basierend auf erwartetem Salary): CHF 27'500
   - Time-to-Close: ~58 Tage (Avg-Days-Sum der verbleibenden Stages)
   - Time-Decay: × 0.94 (Prozess seit 12 Tagen in dieser Stage, leichte Penalty)
   - Final: CHF 27'500 × 0.114 × 0.94 = CHF 2'945 expected
6. Klick auf Conversion-Rate → "Quelle: 142 historische Prozesse Sparte ARC × Mandat-Target letzte 12 Monate"
7. Klickt "Manuell überschreiben" (nur Head/Admin) → drawer-forecast-override
   - Gibt eigenen Forecast-Wert ein mit Begründung
   - INSERT fact_forecast_snapshot mit method=manual
   - Manuelle Override hat Vorrang bei Aggregat-Berechnung für diesen Prozess
```

---

## 6. Filter-Konventionen (alle Pages)

Jede Page hat oben eine **Filter-Bar** mit folgenden Standard-Filtern (je nach Page relevant):

- **Periode:** Quick-Picker (heute, gestern, diese Woche, dieser Monat, dieses Quartal, dieses Jahr) + Custom-Range
- **Sparte:** Multi-Select (ARC · GT · ING · PUR · REM · alle)
- **Team:** Multi-Select aus aktiven Teams
- **Mitarbeiter:** Multi-Select (gefiltert nach Visibility)
- **Mandat-Typ:** Multi-Select (Target · Taskforce · Time · Erfolgsbasis · alle)
- **Stage:** Multi-Select aus dim_process_stages
- **Vergleich:** Toggle (vs. Vorperiode · vs. Vorjahr · vs. Soll · keiner)

**Filter-State** wird in URL-Query-String persistiert für Sharing/Bookmarking. User-Default-Filter speicherbar pro Page (in `dim_dashboard_layout`).

---

## 7. Visualisierungs-Komponenten (~15 Tile-Types reuse + spezielle Components)

| Komponente | Wo eingesetzt | Library-Vorschlag |
|------------|---------------|-------------------|
| KPI-Card mit Trend-Sparkline | Dashboard, alle Pages | custom |
| KPI-Card mit Compare-Bar | Goals, Snapshots | custom |
| Funnel-Chart | Funnel-Page, Tile | custom (SVG) |
| Heatmap | Coverage, Activity | recharts oder custom |
| Bar-Chart (vertikal/horizontal) | alle Vergleiche | recharts |
| Linie-Chart | Trends, Forecasts | recharts |
| Coverage-Map | Coverage-Page | custom (Grid mit Color-Scale) |
| 9-Box-Grid | (später Phase-3.3) | custom |
| Cohort-Chart | Funnel Drill-Down | custom |
| Top-N-List | Dashboard-Tiles | custom |
| Anomaly-List | Insights-Page, Tiles | custom |
| Action-List | Insights-Page, Tiles | custom |
| Forecast-Card mit Confidence-Range | Revenue-Page | custom |
| Sparkline-Grid | Mitarbeiter-Page (mehrere Mini-KPIs) | custom |
| Power-BI-Embed | Admin + on-demand Power-User-Tiles | Power-BI-JS-SDK |

**Theme:** ARK-CI Dark Default + Light Mode (gleich wie CRM/HR/E-Learning). Akzentfarben: Gold #dcb479 für Highlights, Grün/Amber/Rot für Severity.

---

## 8. WebSocket-Channels (Konsumenten)

| Channel | Page-Subscriptions |
|---------|--------------------|
| `perf:insights` | Insights-Page (Live-Liste), Dashboard (Insights-Tile-Counter), Sidebar-Badge |
| `perf:actions` | Insights-Page (Action-Liste), Mitarbeiter-Page (eigene Actions), Sidebar-Badge |
| `perf:reports` | Reports-Page (Run-Liste) |
| `perf:goals:{user_id}` | Mitarbeiter-Page (eigene Goals), Team-Page (Team-Goals) |
| `perf:dashboard:{user_id}` | Dashboard (Tile-Refresh-Notifications nach Snapshot-Lauf) |

---

## 9. Cross-Modul-Cross-Links

| Aus Performance-Modul | Ziel | Pattern |
|-----------------------|------|---------|
| Insight-Drawer "Related Entities" | CRM-Vollansicht (Kandidat/Account/Mandat/Prozess) | Deep-Link `/candidates/{id}` mit Highlight-Param |
| Forecast-Process-Drawer | CRM-Prozess-Vollansicht | Deep-Link `/processes/{id}` |
| Goal-Drawer | (read-only Verbindung zu Mandat-KPIs wenn Metric darauf basiert) | informational Link |
| Action-Item-Drawer | Reminders-Modul (Cross-Link zu fact_reminder.source_type='performance_action_item') | Deep-Link `/reminders?source=performance_action&id={action_id}` |
| Report-PDF | Dok-Generator-History (Audit) | Deep-Link `/dok-generator/runs/{run_id}` |

| Nach Performance-Modul | Aus | Pattern |
|------------------------|-----|---------|
| Reminders-Modul Klick auf Performance-Reminder | drawer-action-detail | Deep-Link `/performance/insights?action={action_id}` |
| Mandat-Detailmaske KPI-Bar Klick auf "Forecast" | Performance-Forecast-Page mit Filter Mandat | Deep-Link `/performance/forecast?mandate={id}` |
| HR-Mitarbeiter-Page Klick auf "Performance" | Performance-Mitarbeiter-Page für diesen MA | Deep-Link `/performance/mitarbeiter/{user_id}` |
| Commission-Dashboard Klick auf "MA-Performance-Detail" | Performance-Mitarbeiter-Page | Deep-Link |

---

## 10. Berechtigungen (RBAC-Matrix UI-Sicht)

| Page | MA | CM/AM/RA | Head | Admin |
|------|-----|----------|------|-------|
| Dashboard | ✓ (eigenes) | ✓ (eigenes) | ✓ (Team-Default) | ✓ (Admin-Default) |
| Funnel | ✓ (eigene Prozesse) | ✓ (eigene) | ✓ (Team) | ✓ (alles) |
| Coverage | ✓ (eigene Kandidaten/Accounts) | ✓ | ✓ (Team) | ✓ |
| Revenue | ✗ | (limited eigene Commission) | ✓ (Team) | ✓ |
| Team | ✗ | ✗ | ✓ (eigenes Team) | ✓ |
| Mitarbeiter | ✓ (Self) | ✓ (Self) | ✓ (Team-MA + Self) | ✓ (alle) |
| Business | ✗ | ✗ | ✓ (eigene Sparte) | ✓ |
| Insights | ✓ (eigene) | ✓ | ✓ (Team) | ✓ |
| Reports | ✓ (eigene) | ✓ | ✓ (Team-Reports) | ✓ |
| Admin | ✗ | ✗ | ✗ | ✓ |

(Spalte "MA" = nur Self-Service-Sicht ohne CRM-Operative-Rechte. CM/AM/RA = aktiver Consultant.)

---

## 11. Mobile-View (Phase-3.2 ggf.)

V0.1 fokussiert Desktop. Mobile-View kommt später analog crm-mobile.html-Pattern:
- Snapshot-Bar 2-spaltig
- Tile-Grid → Stack (1-spaltig)
- Drawer → Full-Screen-Sheet
- Filter-Bar → Bottom-Sheet
- Funnel-Chart wird zu Stage-List mit Counts (kein Visual)

---

## 12. Lint + Stammdaten-Konformität

**Per CLAUDE.md Regeln:**
- **Stammdaten-Wording-Regel:** Stage-Namen aus `dim_process_stages`, Mandat-Typen aus Stammdaten (Target/Taskforce/Time/Erfolgsbasis), Sparten ARC/GT/ING/PUR/REM, MA-Kürzel 2-Buchstaben.
- **DB-Tech-Details-Regel:** Niemals Tabellen-Namen in UI (also kein "fact_insight" sondern "Insight" oder "Anomalie"). Spec-Begriffe nur im Spec/Admin-Drawer.
- **Drawer-Default-Regel:** alle CRUD/Confirms als Drawer 540px. Modal nur für Lösch-Confirms / System-Notifications.
- **Datum-Eingabe-Regel:** Goal-Periode, Action-Due-Date, Forecast-Override → native `<input type="date">` mit Picker UND Tastatur.
- **Umlaute-Regel:** echte Umlaute überall.
- **Mockup-Drift-Check:** Snapshot-Bar 4-6 Slots, Drawer 540px, Tab-Layout konsistent zu HR/Commission/E-Learning.

---

## 13. Acceptance Criteria Interactions

- [ ] 11 Pages implementiert mit Sidebar-Navigation
- [ ] ~30 Drawer funktional (CRUD-Flows komplett)
- [ ] 5 Kern-Flows end-to-end getestet (Customize-Dashboard, Closed-Loop, Goal-Setting, Report-Generation, Forecast-Drill)
- [ ] Filter-Bar konsistent über alle Pages
- [ ] WebSocket-Channels live (perf:insights, perf:actions, perf:reports, perf:goals, perf:dashboard)
- [ ] Cross-Links zu CRM/HR/Commission/Reminders funktionieren bidirektional
- [ ] RBAC-Matrix in UI durchgesetzt
- [ ] Lint-Hooks grün (Stammdaten, DB-Tech, Drawer-Default, Datum, Umlaute, Mockup-Drift)
