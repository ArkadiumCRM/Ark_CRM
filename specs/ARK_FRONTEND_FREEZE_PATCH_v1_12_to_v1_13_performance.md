---
title: "ARK Frontend-Freeze-Patch v1.12 → v1.13 · Performance-Modul"
type: spec
module: performance
version: 1.13
created: 2026-04-25
updated: 2026-04-25
status: draft
sources: [
  "Grundlagen MD/ARK_FRONTEND_FREEZE_v1_12.md",
  "specs/ARK_PERFORMANCE_TOOL_SCHEMA_v0_1.md",
  "specs/ARK_PERFORMANCE_TOOL_INTERACTIONS_v0_1.md",
  "specs/ARK_PERFORMANCE_TOOL_MOCKUP_PLAN.md",
  "memory/project_performance_modul_decisions.md",
  "memory/feedback_phase3_modules_separate.md"
]
tags: [frontend, patch, performance, routes, hub-pattern, snapshot-bar, drawer-default, topojson, geo-heatmap, tab-pattern]
---

# ARK Frontend-Freeze-Patch v1.12 → v1.13 · Performance-Modul

**Scope:** UI-Patterns + Routes für Performance-Modul (Phase-3 ERP). Hub-Pattern via iframe-embedded Sub-Pages, 540px Drawer-Default, 6-Slot-Snapshot-Bar, Schweizer Geo-Heatmap (TopoJSON-CDN), 6-Sub-Tab-Layout für Admin-Page, gold-strong Tab-Pattern.

**Append-Ziel:** TEIL Q in `Grundlagen MD/ARK_FRONTEND_FREEZE_v1_13.md`.

---

## 1. Routes (`/performance/*`)

| Route | Page-Datei | Audience |
|-------|-----------|----------|
| `/performance/dashboard` | `performance-dashboard.html` | alle |
| `/performance/insights` | `performance-insights.html` | alle |
| `/performance/funnel` | `performance-funnel.html` | alle |
| `/performance/coverage` | `performance-coverage.html` | alle |
| `/performance/mitarbeiter` | `performance-mitarbeiter.html` | self / head / admin |
| `/performance/team` | `performance-team.html` | head / admin |
| `/performance/revenue` | `performance-revenue.html` | head / admin |
| `/performance/business` | `performance-business.html` | head / admin |
| `/performance/reports` | `performance-reports.html` | alle (own) / admin (alle) |
| `/performance/admin` | `performance-admin.html` (6 Sub-Tabs) | admin only |

Alle als Sub-Pages des Hubs `mockups/ERP Tools/performance/performance.html`.

---

## 2. Hub-Pattern (iframe-Embed via Hub)

`performance.html` (Hub) liefert:
- Topbar mit CRM↔ERP-Toggle
- ERP-Sidebar mit Performance-Untermenü
- Tab-Router mit `<iframe src="performance-<tab>.html" id="perf-frame">`
- Theme-Sync via `_shared/theme-sync.js` (postMessage in iframe)

**Konsequenz:** Sub-Pages haben **keine** App-Bar / Topbar / Sidebar (alles vom Hub geliefert). Sub-Pages starten direkt mit Snapshot-Bar + Tab-Header + Content.

Memory-Regel: `feedback_claude_design_no_app_bar.md`.

---

## 3. Snapshot-Bar 6-Slot-Pattern

Jede Performance-Sub-Page mit fixer Snapshot-Bar (`top:0`, `z-index:50`):

```
┌─────────┬─────────┬─────────┬─────────┬─────────┬─────────┐
│ KPI     │ KPI vs  │ Trend   │ Forecast│ Anomaly │ Drift   │
│ aktuell │ Ziel    │         │         │ Count   │ /Action │
└─────────┴─────────┴─────────┴─────────┴─────────┴─────────┘
```

Slot-Inhalt page-spezifisch. Beispiel `/performance/dashboard`:
- Slot 1: aktive Prozesse
- Slot 2: Pipeline-Wert vs Quartal-Ziel
- Slot 3: Hunt-Rate Trend (7d-Sparkline)
- Slot 4: Forecast Q-Ende
- Slot 5: Offene Insights (critical+blocker)
- Slot 6: Goal-Drift average (Self oder Team)

---

## 4. Drawer-Default (540px slide-in)

CRUD, Bestätigungen, Mehrschritt-Eingaben **immer als Drawer 540px slide-in** (CLAUDE.md Drawer-Default-Regel). Modal nur für kurze Confirms / Blocker / System-Notifications.

Performance-Drawer:
- `drawer-insight-detail` — Insight + Related Actions, Acknowledge/Dismiss/Convert-Buttons
- `drawer-action-create` — neue Action-Item aus Insight (Owner, Due-Date, Hypothesis, Planned-Intervention)
- `drawer-action-edit` — Action-Status, Notes, State-Transition
- `drawer-action-confirm-outcome` — Outcome-Bestätigung + ggf. Folge-Action
- `drawer-goal-set` — Goal-Setzung Head→MA oder Self (Metric, Period, Target, Direction, Weight)
- `drawer-goal-edit` — Goal-Anpassung mit Audit-Trail
- `drawer-report-generate` — Template + Period + Recipient-Override
- `drawer-tile-customize` — User-Custom-Layout pro Tile (Position, Size, Filter-Config)
- `drawer-tile-add` — Tile aus Library hinzufügen
- `drawer-anomaly-threshold-edit` — Admin: Schwellen pro Metric × Scope
- `drawer-metric-definition-edit` — Admin: Metric anlegen/anpassen
- `drawer-forecast-override` — Head/Admin: manuelle Markov-Override pro Prozess
- `drawer-powerbi-refresh` — Admin: manuelle Refresh-Trigger + Status

---

## 5. Schweizer Geo-Heatmap (Coverage)

`/performance/coverage` zeigt Schweizer Karte mit Kanton-Aggregaten (Kandidaten/Account-Coverage-Score).

**TopoJSON-Source:** `https://cdn.jsdelivr.net/npm/swiss-maps@4/swiss.json` (oder gleichwertige `swiss-maps`-CDN-Quelle).

**Render:** D3.js + d3-geo via CDN (`d3@7`).

**Interaktion:**
- Hover: Kanton-Tooltip mit Aggregat (#Kandidaten, #Accounts, Coverage-Score, #critical)
- Click: Drill-Down-Drawer mit Liste der untergedeckten Entities (sortierbar nach Days-since-Touch)
- Filter-Bar oben: Sparte (multi-select), Owner (multi-select), Entity-Type (Candidate/Account/both)
- Color-Scale: gradient von Surface-Card (low coverage) zu gold-strong (high coverage); critical-State separat in red overlay

---

## 6. 6-Sub-Tab-Layout für Admin-Page

`/performance/admin` mit 6 Sub-Tabs (gold-strong active-underline):

| Sub-Tab | Code | Inhalt |
|---------|------|--------|
| Stammdaten | `metrics` | `dim_metric_definition` CRUD + Test-Query-Preview |
| Schwellen | `thresholds` | `dim_anomaly_threshold` CRUD mit Severity-Editor |
| Tiles | `tiles` | `dim_dashboard_tile_type` Library + Default-Layouts pro Rolle |
| Reports | `reports` | `dim_report_template` + Cron-Editor + Run-Audit |
| Power-BI | `powerbi` | `dim_powerbi_view` + Refresh-Status + Manuell-Refresh-Trigger |
| System | `system` | Snapshot-Lag-Monitor + Worker-Health + Forecast-Config + Recompute-Trigger |

URL-Pattern: `/performance/admin?tab=<code>` (kein eigenes Sub-Routing, Single-Page).

---

## 7. Tab-Pattern (gold-strong active-underline)

Alle Sub-Pages mit Tab-Header verwenden CRM-Standard:

```css
.tab-active   { color: #C4995A; border-bottom: 2px solid #C4995A; }
.tab-inactive { color: var(--text-secondary); border-bottom: 2px solid transparent; }
.tab:hover    { color: var(--text-primary); border-bottom: 1px solid var(--gray-300); }
```

ARIA: `role="tablist"` / `role="tab"` / `aria-selected="true|false"` / `aria-controls="<panel-id>"`.

---

## 8. Theme + Tokens

Wie CRM-Standard. Performance-spezifische Token:

**Severity-Colors:**
- `info` → `#0B6BCB` (blue-500)
- `warn` → `#E0A412` (amber-600)
- `critical` → `#D14343` (red-600)
- `blocker` → `#7A1D1D` (red-900)

**Coverage-State-Colors:**
- `ok` → `#1B7A47` (green-700)
- `overdue` → `#E0A412` (amber-600)
- `critical` → `#D14343` (red-600)
- `never_touched` → `#6B6258` (gray-600)

**Tile-Background:** Surface-Card mit 1px Border-Default, 8px Padding, 6px Radius. Hover: shadow-sm.

---

## 9. RBAC (UI-Sichtbarkeit)

| Element | MA | HEAD | ADMIN | BO |
|---------|-----|------|-------|-----|
| `/performance/dashboard`, `/insights` (own), `/mitarbeiter` (self) | ✓ | ✓ | ✓ | ✓ |
| `/performance/team`, `/revenue`, `/business` | ✗ | Team | ✓ | Read |
| `/performance/funnel`, `/coverage` | own | Team | ✓ | Read |
| `/performance/admin` | ✗ | ✗ | ✓ | ✗ |
| `drawer-tile-customize` | own-Layout | own-Layout | own + Role-Default | ✗ |
| `drawer-goal-set` (für andere) | ✗ | Team-MA | ✓ | ✗ |
| `drawer-forecast-override` | ✗ | Team-Prozesse | ✓ | ✗ |

---

## 10. Mockup-Inventar

```
mockups/ERP Tools/performance/
  performance.html              ← Hub mit Topbar + Sidebar + iframe-Router
  performance-dashboard.html    ← keine App-Bar
  performance-insights.html
  performance-funnel.html
  performance-coverage.html     ← TopoJSON-CDN-Heatmap
  performance-mitarbeiter.html
  performance-team.html
  performance-revenue.html
  performance-business.html
  performance-reports.html
  performance-admin.html        ← 6 Sub-Tabs
```

---

## 11. Acceptance Criteria

- [ ] 10 Mockup-HTMLs erstellt (1 Hub + 9 Sub-Pages)
- [ ] Sub-Pages ohne App-Bar / Topbar / Sidebar
- [ ] Snapshot-Bar 6-Slot-Pattern auf allen Sub-Pages
- [ ] Drawer 540px für alle CRUD-Operationen
- [ ] TopoJSON-CDN-Schweizer-Karte auf `/performance/coverage` funktional
- [ ] Admin-Page mit 6 Sub-Tabs
- [ ] Theme-Sync zwischen Hub und iframes via postMessage
- [ ] gold-strong Tab-Pattern auf allen Tab-Headers
- [ ] RBAC-Visibility implementiert (Sidebar + Page-Level)
- [ ] Lint grün (Stammdaten, DB-Tech, Drawer-Default, Datum, Umlaute, Mockup-Drift)

---

## 12. Lint-Konformität

- **Stammdaten-Wording:** "Stammdaten" / "Liste" / "Katalog" (keine `dim_*`-Namen in UI-Text)
- **DB-Tech-Details:** Admin-Page-Inhalte zeigen `code`-Spalten in Form-Feldern, aber `label_de` ist Hauptwert. Wo `dim_metric_definition` o.ä. unausweichlich (Spec-Refs in Tooltips), `<!-- ark-lint-skip -->` Marker setzen.
- **Drawer-Default:** alle Performance-Drawer 540px slide-in
- **Datum-Eingabe:** native `<input type="date">` für Period-Picker (Goal-Drawer, Report-Drawer)
- **Umlaute:** echte Umlaute in allen Labels
