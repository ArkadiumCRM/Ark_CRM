---
title: "ARK Performance-Modul · Mockup-Plan v0.1"
type: spec
module: performance
version: 0.1
created: 2026-04-25
updated: 2026-04-25
status: draft
sources: [
  "specs/ARK_PERFORMANCE_TOOL_SCHEMA_v0_1.md",
  "specs/ARK_PERFORMANCE_TOOL_INTERACTIONS_v0_1.md",
  "memory/project_performance_modul_decisions.md"
]
tags: [spec, mockup-plan, performance, claude-design-handoff]
---

# ARK Performance-Modul · Mockup-Plan v0.1

**Pfad-Konvention:** `mockups/ERP Tools/performance/<file>.html`

**Baseline-Pattern (für Drift-Check):** `mockups/ERP Tools/commission/commission-dashboard.html` + `mockups/ERP Tools/elearn/elearn-admin-analytics.html` + `mockups/ERP Tools/hr/hr-dashboard.html`.

**Theme-Tokens:** `mockups/_shared/editorial.css` (gemeinsam mit allen ERP-Tools).

---

## 1. Mockup-Reihenfolge (Build-Order)

| Order | Datei | Priorität | Komplexität | Abhängigkeiten |
|-------|-------|-----------|-------------|-----------------|
| 1 | `performance.html` (Hub-Shell) | P0 | low | - |
| 2 | `performance-dashboard.html` | P0 | high | Tile-Library |
| 3 | `performance-insights.html` | P0 | high | Closed-Loop-Drawer |
| 4 | `performance-funnel.html` | P0 | mid | Funnel-Component |
| 5 | `performance-coverage.html` | P0 | mid | Heatmap-Component |
| 6 | `performance-mitarbeiter.html` | P0 | mid | reuse von Tiles |
| 7 | `performance-revenue.html` | P1 | high | Forecast-Drawer |
| 8 | `performance-team.html` | P1 | mid | reuse Mitarbeiter |
| 9 | `performance-business.html` | P1 | mid | reuse Bar-Charts |
| 10 | `performance-reports.html` | P1 | mid | Template-Liste |
| 11 | `performance-admin.html` | P1 | high | 6 Sub-Sections |

---

## 2. Per-Mockup-Brief

### 2.1 `performance.html` (Hub-Shell)

**Inhalt:** Top-Bar (ERP-Modus active), Sidebar-Navigation (siehe INTERACTIONS §2), Content-Frame mit iframe oder Direct-Embed der Sub-Pages.

**Komponenten:**
- Top-Bar mit ERP↔CRM-Toggle (per Memory `feedback_phase3_modules_separate.md`)
- Sidebar: 4 Sektionen (Dashboard / Analyse / Personen / Insights / Reports / Admin), Counter-Badges
- Content-Container

**Snapshot-Bar:** none (Hub-Shell)

**Drawer:** none

**Key-Interactions:** Sidebar-Click → Page-Switch via Tab-Router (analog zu hr.html Pattern)

### 2.2 `performance-dashboard.html`

**Inhalt:** Tile-Grid mit Drag-and-Drop (Customize-Mode), Filter-Bar oben, Snapshot-Bar.

**Komponenten:**
- Snapshot-Bar (6 Slots: Health-Score, Insights offen, Massnahmen überfällig, Goal-Erreichung MTD, Compliance, Forecast Q-Ende)
- Filter-Bar (Periode, Sparte, Vergleich)
- "Anpassen" Toggle-Button rechts oben
- Tile-Grid (12-Spalten-Layout, react-grid-layout-style)
- Default-Tiles je Rolle: ~10-12 Tiles
- Locked-Tiles mit Lock-Icon
- "+ Tile" Floating-Action-Button im Customize-Mode

**Drawer:** drawer-tile-add, drawer-tile-edit, drawer-tile-explain, drawer-tile-drill

**Key-Interactions:**
- Customize-Toggle aktiviert Drag-Handles
- Tile-Settings-Icon öffnet drawer-tile-edit (außer Locked)
- Tile-Hauptbereich-Click öffnet drawer-tile-drill
- "?" Icon öffnet drawer-tile-explain
- "Reset" Button löscht User-Custom-Layout

**Beispiel-Default-Tiles für Rolle "ma" (Self):**
1. Mein Pipeline-Wert (KPI-Card)
2. Meine Goals (Goal-Progress)
3. Aktivität diese Woche (Sparkline)
4. Meine offenen Insights (Anomaly-List)
5. Meine Massnahmen (Action-List)
6. Compliance-Status [LOCKED] (KPI-Card)
7. Mein Forecast Q-Ende (Forecast-Card)
8. Top-5 Kandidaten unter-touched (Top-N-List)

### 2.3 `performance-insights.html` (Closed-Loop-Hub)

**Inhalt:** Insights-Liste links, Massnahmen-Liste rechts, beide gefiltert. Switcher zwischen Open/Resolved/Archived.

**Komponenten:**
- Snapshot-Bar (6 Slots: Open, Critical, Blocker, Resolved 30d, Wirkung Ø, False-Positive-Rate)
- Filter-Bar (Severity, Scope, Owner, Period)
- 2-Spalten-Layout:
  - Links: Insights-Liste (Card-Stack mit Severity-Color-Border)
  - Rechts: Massnahmen-Liste (mit Outcome-Status-Indikator)
- Tab-Switcher: Offen / In Bearbeitung / Resolved / Archived
- Action-Bar oben: "Insight markieren als Bulk-Done", "Export"

**Drawer:** drawer-insight-detail, drawer-action-create, drawer-action-detail, drawer-action-update, drawer-outcome-confirm, drawer-action-followup

**Key-Interactions:**
- Insight-Card-Click → drawer-insight-detail
- Action-Card-Click → drawer-action-detail
- "Massnahme erstellen" aus Insight → drawer-action-create (pre-filled mit Insight-Ref)
- "Wirkung bestätigen" Button erscheint auf Action-Card wenn Outcome-Auto-Measurement vorhanden → drawer-outcome-confirm
- Bei Effect=worsened/no_change: "Folge-Massnahme" CTA → drawer-action-followup

### 2.4 `performance-funnel.html`

**Inhalt:** Pipeline-Funnel mit Drop-Off-Visualisierung, Drill-Down auf Stage-Level.

**Komponenten:**
- Snapshot-Bar (Konversionsrate, Time-to-Hire-Median, Drop-Off-Stage worst, Top/Bottom-Sparte, Pipeline-Wert)
- Filter-Bar (Periode, Sparte, Mandat-Typ, Owner)
- Funnel-Chart (Vertikal mit Stage-Labels, Counts, Conversion-Pfeile)
- Stage-Detail-Tabelle unten (Stage, Count, Conversion-Rate vs Vor-Stage, Avg-Days, Drop-Off-Count)
- "Cohort-Analysis" Button → öffnet drawer-funnel-cohort

**Drawer:** drawer-funnel-stage, drawer-funnel-process, drawer-funnel-cohort

**Key-Interactions:**
- Klick auf Funnel-Stage öffnet drawer-funnel-stage mit Prozess-Liste
- Klick auf Prozess in Liste → drawer-funnel-process (Preview, Link zu CRM-Vollansicht)
- Cohort-Analysis zeigt Hunt-Vintage-Performance über 12 Monate

### 2.5 `performance-coverage.html`

**Inhalt:** Coverage-Heatmap für Kandidaten + Accounts mit Touch-Frequenz-Indikatoren.

**Komponenten:**
- Snapshot-Bar (Kandidaten unter-touched, Kunden vernachlässigt, Coverage-Score Ø, Anteil kontaktiert 30d, Top-vernachlässigte Sparte, Hunt-Rate)
- Filter-Bar (Periode, Sparte, Owner, Stage)
- Tab-Switcher: Kandidaten-Coverage / Accounts-Coverage
- Heatmap (Owner × Sparte oder Stage × Sparte, Color-Scale: rot=schlecht, grün=gut)
- Liste der kritisch unter-touched Entities unten
- "Massenaktion" Button (Bulk-Reminder, Bulk-Reassign)

**Drawer:** drawer-coverage-candidate, drawer-coverage-account, drawer-coverage-bulk-action

**Key-Interactions:**
- Klick auf Heatmap-Cell zeigt darunter die Entities für diese Cell
- Klick auf Entity → drawer-coverage-{candidate|account} mit Touch-History + Action-CTAs
- Bulk-Action mit Multi-Select

### 2.6 `performance-mitarbeiter.html` (Self-View)

**Inhalt:** MA-Self-Dashboard mit allen eigenen Performance-Indikatoren konsolidiert.

**Komponenten:**
- Snapshot-Bar (Mein Pipeline-Wert, Goal-Erreichung, Anomalien, Aktivität, Compliance, Forecast Q-Ende)
- Tab-Layout:
  - **Übersicht:** Tile-Grid wie Dashboard, fokussiert auf eigene Daten
  - **Pipeline:** eigener Funnel mit Drill-Down
  - **Goals:** Liste aktiver + abgelaufener Goals mit Progress
  - **Aktivität:** Activity-Heatmap (Tag × Wochentag)
  - **Compliance:** E-Learning-Status, Reminder-Backlog, AI-Confirm-Rate
  - **Commission:** Run-Rate-Chart, Auszahlungs-Verlauf (read-only Mirror aus Commission-Modul)
- Kontext-Switch oben (für Head/Admin): Dropdown zur Auswahl eines anderen MA

**Drawer:** drawer-team-member (für andere MA), drawer-goal-new, drawer-goal-edit, drawer-goal-progress

**Key-Interactions:**
- Tab-Switch innerhalb Page
- Goal-Tab: "+ Goal" für Self (nur eigene), für Head Goals für Team-MA setzen
- Cross-Link zu Activity-Detail in CRM

### 2.7 `performance-revenue.html`

**Inhalt:** Revenue-Attribution + Markov-Forecast.

**Komponenten:**
- Snapshot-Bar (Revenue YTD, vs Vorjahr, Forecast Jahresende, Top-Mandant, Top-Sparte, Pipeline-Coverage-Ratio)
- Filter-Bar (Periode, Sparte, Mandat-Typ, Owner)
- 2-Spalten:
  - Links: Revenue-Verlauf-Chart (Linie, monthly), Bar-Chart pro Sparte
  - Rechts: Forecast-Card (Aggregat) + Top-5-Forecast-Prozesse-Liste
- Detail-Tabelle: Revenue pro Mandat (Soll/Ist/Forecast/Diff)

**Drawer:** drawer-revenue-attribution, drawer-forecast-explain, drawer-forecast-process, drawer-forecast-override

**Key-Interactions:**
- Klick auf Revenue-Bar-Segment → drawer-revenue-attribution
- "?" auf Forecast-Card → drawer-forecast-explain
- Klick auf Prozess in Forecast-Liste → drawer-forecast-process
- "Manuell überschreiben" (Head/Admin) → drawer-forecast-override

### 2.8 `performance-team.html` (Head-View)

**Inhalt:** Team-KPIs aggregiert, MA-Liste mit Vergleichen.

**Komponenten:**
- Snapshot-Bar (Team-Pipeline-Wert, Team-Goal-Erreichung, Team-Anomalien, Team-Aktivität, Team-Compliance, Team-Forecast)
- Filter-Bar (Periode, Sparte falls Head mehrere)
- Team-Liste (Card-Grid oder Tabelle):
  - Pro MA: Name, Rolle, Pipeline-Wert, Goal-Achievement-Mini-Bar, Compliance-Score, Anomalien-Counter
- Bar-Chart: Team-Vergleich (z.B. Placements pro MA, Calls pro MA)
- "Team-Goals setzen" Bulk-Button

**Drawer:** drawer-team-member, drawer-goal-new (Bulk-Mode für Team)

**Key-Interactions:**
- MA-Card-Click → drawer-team-member oder Direct-Navigation zu performance-mitarbeiter mit MA-Context
- Bulk-Goal-Setting für mehrere MA gleichzeitig

### 2.9 `performance-business.html`

**Inhalt:** Sparten/Markt-Sicht für strategische Entscheidungen.

**Komponenten:**
- Snapshot-Bar (Revenue/Sparte, Conversion/Sparte, Markt-Coverage, Top-Mandant Sparte, Aktive Mandate, Pipeline-Wert/Sparte)
- Filter-Bar (Periode, Vergleich)
- Sparten-Vergleichs-Tabelle (5 Sparten × 8 Spalten)
- Bar-Charts: Revenue/Sparte/Quartal, Conversion/Sparte/Quartal
- Markt-Indikatoren-Block (Cluster-Verteilung, Mandat-Typen-Mix, AGB-Status pro Sparte)
- Top-/Bottom-Mandanten-Listen pro Sparte

**Drawer:** reuse aus Funnel + Coverage + Revenue (cross-linkable)

**Key-Interactions:**
- Sparten-Row-Click → fokussiert alle Charts auf diese Sparte (Filter-Apply)
- Quick-Drill zu Funnel/Coverage/Revenue mit Sparten-Filter pre-applied

### 2.10 `performance-reports.html`

**Inhalt:** Report-Templates + Run-History + Manual-Trigger.

**Komponenten:**
- Snapshot-Bar (Reports diesen Monat, Pending Versand, Failed, Templates aktiv, Cron aktiv, Letzter Run)
- Filter-Bar (Template, Periode, Status, Empfänger)
- Tab-Switcher: Templates / Runs (History)
- **Tab Templates:**
  - Template-Karten (5 Default + ggf custom)
  - Pro Template: Cadence, nächster Run, Empfänger-Anzahl, Active-Toggle, "Manuell triggern" CTA
- **Tab Runs:**
  - Tabelle (Datum, Template, Periode, State, Empfänger, PDF-Download, Failure-Reason)
  - Failed-Runs mit "Retry" CTA

**Drawer:** drawer-report-trigger, drawer-report-run-detail, drawer-report-template-config (Admin), drawer-report-template-new (Admin)

**Key-Interactions:**
- "Manuell generieren" → drawer-report-trigger
- Run-Row-Click → drawer-report-run-detail
- Admin-only: Template-Card-Click → drawer-report-template-config

### 2.11 `performance-admin.html`

**Inhalt:** 6 Sub-Sections für komplette Admin-Konfiguration.

**Komponenten:**
- Snapshot-Bar (aktive Metriken, aktive Schwellen, PowerBI-Views fresh, stale, Worker-Lag, Snapshot-Volumen)
- Sub-Tab-Layout:
  1. **Metriken:** Liste aller Metric-Definitions, CRUD über Drawer
  2. **Anomalie-Schwellen:** Liste pro Metric+Scope, CRUD
  3. **Dashboard-Defaults:** Rollen-Layout-Editor (für jede Rolle/Page ein Default-Layout, Lock-Toggle pro Tile)
  4. **Power-BI-Views:** Liste mit Refresh-Status, Manual-Refresh, View-SQL-Edit
  5. **Worker-Health:** Live-Status aller Performance-Worker mit Lag/Failure-Rate
  6. **Forecast-Konfiguration:** Conversion-Rate-Audit, Recompute-Trigger, Methodenauswahl

**Drawer:** drawer-metric-edit, drawer-metric-new, drawer-anomaly-threshold, drawer-dashboard-default, drawer-powerbi-view, drawer-snapshot-lag

**Key-Interactions:**
- Sub-Tab-Switch
- CRUD-Drawer für jede Sub-Section
- Bulk-Operations für Metric-Definitions (Active-Toggle für mehrere, Sortierung)

---

## 3. Shared Components (cross-mockup)

| Component | Wo eingesetzt | Beschreibung |
|-----------|---------------|--------------|
| `<perf-snapshot-bar>` | alle Pages | 4-6 Slots, KPI-Tiles mit Mini-Trends |
| `<perf-filter-bar>` | alle Pages | Standard-Filter (Periode, Sparte, Team, MA, Mandat-Typ, Stage, Vergleich), URL-State |
| `<perf-tile>` | Dashboard, Mitarbeiter | Variants: kpi-card, trend-chart, bar-chart, funnel, heatmap, top-n, anomaly-list, action-list, forecast-card, sparkline-grid, iframe-powerbi |
| `<perf-funnel>` | Funnel, Mitarbeiter | SVG-Funnel mit Stage-Labels, Conversion-Arrows |
| `<perf-heatmap>` | Coverage, Mitarbeiter (Activity) | Grid mit Color-Scale, Click-Drill |
| `<perf-action-card>` | Insights | Action-Item-Card mit Severity-Border + State-Badge + Outcome-Indicator |
| `<perf-insight-card>` | Insights | Insight-Card mit Severity-Color + Threshold-Bar + Recommended-Action-Snippet |
| `<perf-forecast-card>` | Revenue, Mitarbeiter | Aggregat-Wert + Confidence-Range + Top-Contributor-Liste |
| `<perf-goal-progress>` | Mitarbeiter, Team | Bar mit Soll/Ist + Drift-Color + Periode-Restdauer |
| `<perf-drawer>` | alle Drawers | 540px slide-in mit Header + Tabs + Footer + Action-Buttons (per Drawer-Default-Regel) |

---

## 4. Claude-Design-Workflow (per Memory `Claude-Design-Workflow`)

Performance-Modul ist **Phase-3 ERP** und gross genug für Claude-Design:

**Schritt 1 (Peter in claude.ai/design):**

Prompt-Vorschlag:
```
Build a performance analytics dashboard for ARK CRM (a Swiss recruiting agency tool).
The "Dashboard" page is a customizable tile grid (12-column responsive layout) with:
- Snapshot bar at top (6 KPI cards with mini trend lines)
- Filter bar (period, division, comparison)
- Customize toggle revealing drag-handles + settings icons
- ~10 tile types: KPI-card, trend-chart, bar-chart, funnel-chart, heatmap, top-N-list, anomaly-list, action-list, forecast-card, sparkline-grid
- Locked tiles show a lock icon (admin-pinned)

Use existing ARK design language: dark theme default, gold accent #dcb479, "Libre Baskerville" headlines, "DM Sans" body, editorial card styling like commission-dashboard.

Generate HTML mockup with embedded CSS, no React needed.
```

**Schritt 2 (Iteration in claude.ai/design):**
- Zoom in auf Tile-Detail-Variants
- Insights-Page mit Closed-Loop-Drawer-Pattern
- Funnel mit Drop-Off-Animation (statisch ok für Mockup)
- Coverage-Heatmap mit Color-Scale
- Forecast-Card mit Confidence-Range

**Schritt 3 (Handoff zu Claude Code):**
Bundle einfügen, ich passe an ARK-Pattern an:
- Umlaute-Konformität
- DB-Tech-Details-Lint
- Drawer-Default (540px)
- Stammdaten-Vocabulary (Stage-Namen, Sparten, Mandat-Typen)
- Snapshot-Bar 6-Slot-Pattern
- Tab-Layout konsistent zu HR/Commission/E-Learning

**Alternative:** Direct-Build durch Claude Code ohne Claude-Design — sinnvoll wenn Pattern-Konsistenz wichtiger als Design-Innovation. Performance-Modul ist datenintensiv, Pattern-Konsistenz vermutlich höher gewichtet.

---

## 5. Test-Daten für Mockups (Sample-Data)

Pro Mockup brauchen wir realistische Sample-Daten:
- **Pipeline-Funnel:** 7 Stages × Counts realistisch (Research 240 → CV Sent 45 → Placement 8)
- **Coverage:** 50 Sample-Kandidaten mit verschiedenen Touch-Frequenzen
- **Revenue:** 12-Monats-Verlauf mit Sparten-Splits
- **Forecast:** 5 Beispiel-Prozesse mit Markov-Decomposition
- **Insights:** 8 Beispiel-Anomalien (mix aus info/warn/critical/blocker)
- **Action-Items:** 5 Beispiel-Massnahmen in verschiedenen States (pending/in_progress/done/with-outcome)
- **Goals:** 3 Beispiel-Goals pro MA (achieved, on-track, drift)

Sample-Data zentral in `mockups/_shared/perf-sample-data.js` (analog zu E-Learning-Sample-Data).

---

## 6. Drift-Check-Punkte (vs. Mockup-Baseline)

Per `mockup-drift-check`-Skill nach jedem Mockup:
- Snapshot-Bar 4-6 Slots (nicht > 6 ohne Begründung)
- Drawer-Width 540px slide-in rechts
- Tab-Layout konsistent (Tabs oben, Active-Underline #dcb479)
- Kein DB-Tech-Detail in UI-Texten
- Stage-Namen/Mandat-Typen aus Stammdaten
- Echte Umlaute überall

---

## 7. Acceptance Criteria Mockup-Phase

- [ ] 11 HTMLs erstellt + mit Sample-Daten gefüllt
- [ ] Mockup-Drift-Check grün für alle 11
- [ ] Sidebar-Navigation funktional zwischen allen Pages
- [ ] Drawer-Inventar (~30 Drawer) komplett verfügbar
- [ ] 5 Kern-Flows interaktiv klickbar (auch wenn Daten static sind)
- [ ] Lint grün (Stammdaten, DB-Tech, Drawer-Default, Datum, Umlaute)
- [ ] Responsive Mobile-View (Phase 3.2 nachgezogen, v0.1 Desktop-only ok)
