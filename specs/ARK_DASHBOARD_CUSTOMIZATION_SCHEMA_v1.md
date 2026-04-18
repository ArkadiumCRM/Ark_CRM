# ARK CRM — Dashboard-Customization Schema v1.0

**Stand:** 17.04.2026
**Status:** Review ausstehend (Erstversion)
**Scope:** Pro-User-Customization des Dashboards mit Rolle-Defaults, User-Overrides, Admin-Template-Editor und Mobile-Responsive

**Quellen:**
- `mockups/dashboard.html` v1.3 (aktueller Zustand: KPI-Strip · 4 Strategic-Cards · Pending Calls/Emails Widgets · Activity-Feed)
- `raw/Ark_CRM_v2/ARK_DATABASE_SCHEMA_v1_3.md` (`dim_crm_users`, `dim_mitarbeiter`)
- `raw/Ark_CRM_v2/ARK_FRONTEND_FREEZE_v1_*.md` (UI-Patterns, Drawer-Konvention)
- Dashboard-Ausbau-Analyse vom 17.04.2026 (17 Widget-Kandidaten P0–P2)
- CLAUDE.md Drawer-Default-Regel · Datum-Eingabe-Regel · DB-Techdetails-Lint

**Vorrang:** Stammdaten > dieses Schema > Frontend Freeze > Mockups

---

## 0. ZIELBILD

Jeder Mitarbeiter sieht beim Öffnen von `/dashboard` eine **auf seine Rolle(n) zugeschnittene Ansicht**, die er optional an seine persönlichen Präferenzen anpassen kann. Doppelrollen (z.B. PW = Admin + Account Manager) werden über einen Rollen-Toggle oben rechts gewechselt.

**Drei-Ebenen-Model:**

```
Ebene 1: Rolle-Default (Template)
         - alle Rollen haben je eigenes Layout
         - Definiert in dim_dashboard_role_defaults
         - Editierbar durch Admin (Q6)

         ▼ wird überlagert von ▼

Ebene 2: User-Override
         - User kann Widgets add/remove/reorder
         - Persistiert in dim_crm_users.dashboard_layout_json
         - Multi-Device-Sync via DB

         ▼ wird modifiziert durch ▼

Ebene 3: Viewport-Adaptation (Mobile-Responsive)
         - dim_dashboard_widgets.mobile_mode entscheidet pro Widget
         - Breakpoints: Desktop ≥1280 · Tablet 768–1279 · Mobile <768
```

**Primäre Nutzer:**
- **Alle Consultants (6 Rollen)** bekommen personalisiertes Dashboard
- **Admin** zusätzlich: Template-Editor für Role-Defaults
- **Mobile-Nutzer** (iPad, unterwegs) bekommen compact-Layout

---

## 1. DESIGN-SYSTEM-REFERENZ

Erbt aus `ARK_KANDIDATENMASKE_SCHEMA_v1_3.md` §0. Dashboard-spezifische Tokens:

| Token | Wert | Verwendung |
|-------|------|-----------|
| Edit-Mode-Overlay | `rgba(0,0,0,0.04)` | Hintergrund im Edit-Modus |
| Widget-Border-Dashed | `2px dashed var(--accent)` | Active Widget im Edit-Modus |
| Drag-Handle | `⋮⋮` Icon | Top-right jeder Card im Edit-Modus |
| Widget-Close | `✕` Button | Top-right jeder Card im Edit-Modus, entfernt Widget |
| Role-Toggle-Chip | `.role-toggle` | Dropdown oben rechts mit Rollen |

**Grid-System:**

```css
.dashboard-grid {
  display: grid;
  grid-template-columns: repeat(12, 1fr);
  gap: 16px;
}
/* Widget-Size via CSS-Variable */
.widget[data-size="full"]    { grid-column: span 12; }  /* Full-width */
.widget[data-size="half"]    { grid-column: span 6;  }  /* Half (default) */
.widget[data-size="third"]   { grid-column: span 4;  }  /* Third */
.widget[data-size="quarter"] { grid-column: span 3;  }  /* Quarter */

/* Tablet-Breakpoint */
@media (max-width: 1279px) {
  .widget[data-size="quarter"] { grid-column: span 6; }
  .widget[data-size="third"]   { grid-column: span 6; }
}

/* Mobile-Breakpoint */
@media (max-width: 767px) {
  .widget                      { grid-column: span 12; }  /* Stack all */
  .widget[data-mobile="hidden"] { display: none; }
  .widget[data-mobile="link-only"] .widget-body { display: none; }
  .widget[data-mobile="link-only"] .widget-link-overview { display: block; }
}
```

---

## 2. DATENMODELL

### 2.1 `dim_dashboard_widgets` — NEUE TABELLE (Widget-Registry)

```sql
CREATE TABLE ark.dim_dashboard_widgets (
  id                   uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  widget_key           text UNIQUE NOT NULL,
    -- Kanonische Kennung: 'pending-calls', 'stale-processes', 'garantie-14d', ...
  widget_name          text NOT NULL,
    -- User-sichtbarer Name: „Pending Calls · Triage"
  description          text,
    -- Kurze Beschreibung für Widget-Katalog-Drawer
  category             text NOT NULL
    CHECK (category IN ('kpi','triage','alert','analytics','agenda','ops')),
  data_scope           text NOT NULL
    CHECK (data_scope IN ('user','team','sparte','account','global')),
    -- 'user' = nur meine Daten (z.B. meine Reminders)
    -- 'team' = alles von meinem Team (z.B. Team-Workload)
    -- 'sparte' = nach Sparte gefiltert (Admin · Head of)
    -- 'global' = alle Tenants-Daten (Admin-only KPIs)
  allowed_roles        text[] NOT NULL DEFAULT '{}',
    -- Welche Rollen dürfen dieses Widget überhaupt sehen
    -- z.B. {'Admin','AM','CM'} für Pending-Calls
    -- {'Admin'} für Circuit-Breaker-Status
  default_size         text NOT NULL DEFAULT 'half'
    CHECK (default_size IN ('full','half','third','quarter')),
  mobile_mode          text NOT NULL DEFAULT 'compact'
    CHECK (mobile_mode IN ('full','compact','hidden','link-only')),
  default_sort_order   int NOT NULL DEFAULT 100,
    -- Default-Position im Grid bei Rendering ohne User-Override
  config_schema        jsonb NULL,
    -- JSON-Schema für widget-spezifische Config (z.B. Zeitraum, Sparte-Filter)
  is_pinnable          boolean NOT NULL DEFAULT true,
    -- false = kann nicht vom User ausgeblendet werden (z.B. Blocker-Count)
  endpoint             text NULL,
    -- API-Endpoint für Daten: 'GET /api/v1/dashboard/widgets/:widget_key'
  websocket_topic      text NULL,
    -- Optional: WS-Topic für Live-Updates (z.B. 'pending-calls')
  deprecated_at        timestamptz NULL,
  created_at           timestamptz DEFAULT now()
);

CREATE INDEX idx_widgets_category ON ark.dim_dashboard_widgets(category);
CREATE INDEX idx_widgets_roles ON ark.dim_dashboard_widgets USING gin(allowed_roles);
```

### 2.2 `dim_dashboard_role_defaults` — NEUE TABELLE (Rolle-Templates)

```sql
CREATE TABLE ark.dim_dashboard_role_defaults (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       uuid NOT NULL REFERENCES ark.dim_tenants(id),
  role_key        text NOT NULL
    CHECK (role_key IN ('Admin','CM','AM','RA','BO','HoD','Combined')),
  widget_id       uuid NOT NULL REFERENCES ark.dim_dashboard_widgets(id),
  sort_order      int NOT NULL,
    -- Position im Grid (0 = top-left)
  size_override   text NULL
    CHECK (size_override IN ('full','half','third','quarter')),
    -- Überschreibt widget.default_size für diese Rolle
  config_json     jsonb NULL,
    -- Rolle-spezifische Config (z.B. AM sieht Zeitraum=7d, CM=1d)
  is_pinned       boolean NOT NULL DEFAULT false,
    -- User kann dieses Widget für diese Rolle nicht entfernen
  created_by      uuid REFERENCES ark.dim_crm_users(id),
    -- Admin der Template erstellt hat
  updated_at      timestamptz DEFAULT now(),

  UNIQUE (tenant_id, role_key, widget_id)
);

CREATE INDEX idx_role_defaults_role ON ark.dim_dashboard_role_defaults(tenant_id, role_key, sort_order);
```

### 2.3 `dim_crm_users` — ALTER (User-Override + Zusatz-Rollen)

```sql
ALTER TABLE ark.dim_crm_users
  ADD COLUMN additional_roles text[] DEFAULT '{}',
    -- Haupt-Rolle in .role, zusätzliche in additional_roles
    -- Beispiel: PW → role='Admin', additional_roles=['AM']
  ADD COLUMN dashboard_layout_json jsonb NULL,
    -- Pro User persistiert, überlagert Rolle-Defaults
  ADD COLUMN active_dashboard_view text NULL
    CHECK (active_dashboard_view IS NULL OR active_dashboard_view IN (
      'Admin','CM','AM','RA','BO','HoD','Combined'
    ));
    -- Bei Doppelrollen: welche View aktuell angezeigt (Persistierung über Sessions)
```

**`dashboard_layout_json`-Format:**

```json
{
  "version": 1,
  "views": {
    "AM": {
      "widgets": [
        {"widget_key": "pending-calls", "sort_order": 0, "size": "half", "hidden": false, "config": {"timeframe_days": 7}},
        {"widget_key": "to-send-inbox", "sort_order": 1, "size": "half", "hidden": false},
        {"widget_key": "agb-pending",   "sort_order": 2, "size": "third", "hidden": false},
        {"widget_key": "team-workload", "sort_order": 100, "hidden": true}
      ]
    },
    "Combined": {
      "widgets": [...]
    }
  },
  "last_updated": "2026-04-17T14:30:00Z"
}
```

**Merge-Regel (Rendering):**
1. Lade `role_defaults` für aktive Rolle → Basis-Layout
2. Falls `dashboard_layout_json.views.<role>` existiert: überlagere (widgets gleichen Keys werden gemerged, User-Override gewinnt pro Feld)
3. `is_pinned=true` im Default verhindert `hidden=true` in Override (User kann gepinnte nicht ausblenden)
4. Fehlende Widgets (weder in Default noch Override) werden nicht angezeigt

### 2.4 Seed-Daten

Migration seeded:
- **~20 Widget-Einträge** in `dim_dashboard_widgets`
- **~6 × 8 = 48 Rows** in `dim_dashboard_role_defaults` (6 Rollen × ~8 Widgets pro Rolle)

Detail siehe §4 und §5.

---

## 3. ROLLEN & BERECHTIGUNGEN

### 3.1 Rolle-Katalog

Basiert auf `dim_crm_users.role` CHECK (erweitert v1.0 um Granularität):

| Rolle | Key | Scope |
|-------|-----|-------|
| Admin | `Admin` | alles (System-Ops, Circuit-Breaker, Debug + alle Analytics-Widgets kombiniert) |
| Candidate Manager | `CM` | Prozesse, Kandidaten-Triage, Coaching |
| Account Manager | `AM` | Mandate, Kunden, Versand, AGB |
| Research Analyst | `RA` | Scraper, Longlist, Research |
| Backoffice | `BO` | Rechnungen, Assessments-Admin |
| Head of Sparte | `HoD` | Team-Analytics, Sparte-KPIs (neu v1.0) |
| Combined | `Combined` | Pseudo-Rolle für Doppelrollen-Merge |

### 3.2 Doppelrollen (Q1=B — Toggle)

**Szenario:** PW hat `role='Admin'` und `additional_roles=['AM']`. Beim Login:
- Default-View = `active_dashboard_view` aus letzter Session (fallback: `role`)
- Toggle oben rechts: Dropdown `Admin ▼ / Account Manager / Combined`
- Bei Wechsel: `active_dashboard_view` updated + Re-Render

**Combined-View:**
- Merge aller Widgets aus beiden (allen) Rollen
- Dedupliziert (gleiches `widget_key` nur einmal)
- Sort-Order nach `sort_order` gewichtet über Rollen
- User kann in `dashboard_layout_json.views.Combined` eigenes Layout speichern

### 3.3 Admin-Template-Editor (Q6)

Admin kann `dim_dashboard_role_defaults` direkt editieren:
- Route: `/admin/dashboard-templates` (nur Role='Admin')
- UI: pro Rolle eine Widget-Liste mit Drag-Reorder + „+ Widget" + „✕ Widget entfernen"
- „Als Default speichern" → `UPDATE dim_dashboard_role_defaults` mit `updated_at=now(), created_by=admin_user.id`
- **Nicht retroaktiv:** bestehende User-Overrides bleiben unberührt
- Bei neuen Usern oder Reset-to-default: neuer Template greift

**Audit:** Jede Template-Änderung wird in `fact_audit_log` mit `action='admin.dashboard_template.updated'` + `payload={role, added_widgets, removed_widgets, reordered}` persistiert.

---

## 4. WIDGET-KATALOG (Seed-Einträge für `dim_dashboard_widgets`)

### 4.1 KPI-Widgets (6)

| # | widget_key | Name | Scope | Roles | Size | Mobile |
|---|-----------|------|-------|-------|------|--------|
| 1 | `kpi-umsatz-ytd` | Umsatz YTD | global | Admin,AM,HoD | quarter | full |
| 2 | `kpi-placements-ytd` | Placements YTD | global | alle | quarter | full |
| 3 | `kpi-offene-mandate` | Offene Mandate | team | Admin,AM | quarter | full |
| 4 | `kpi-aktive-prozesse` | Aktive Prozesse | team | alle | quarter | full |
| 5 | `kpi-blocker-count` | Blocker-Count | user | alle | quarter | full |
| 6 | `kpi-system-health` | System-Health | global | Admin | quarter | hidden |

### 4.2 Triage-Widgets (3)

| # | widget_key | Name | Scope | Roles | Size | Mobile |
|---|-----------|------|-------|-------|------|--------|
| 7 | `pending-calls` | Pending Calls Triage | user | AM,CM,Admin | half | compact |
| 8 | `pending-emails` | Pending Emails Triage | user | AM,CM,Admin | half | compact |
| 9 | `to-send-inbox` | To-Send-Inbox (CV-Versand) | user | AM,CM | full | compact |

### 4.3 Alert-Widgets (5)

| # | widget_key | Name | Scope | Roles | Size | Mobile |
|---|-----------|------|-------|-------|------|--------|
| 10 | `garantie-ablauf-14d` | Garantie-Ablauf 14 Tage | team | CM,AM,Admin | half | link-only |
| 11 | `stale-prozesse` | Stale-Prozesse-Triage | user | CM,AM | half | compact |
| 12 | `agb-pending` | AGB-Pending Alert | account | AM,Admin | third | link-only |
| 13 | `claim-faelle-offen` | Claim-Fälle offen | account | AM,Admin | third | link-only |
| 14 | `scraper-review-queue` | Scraper-Findings Review | account | AM,RA,Admin | half | compact |

### 4.4 Ops-Widgets (3)

| # | widget_key | Name | Scope | Roles | Size | Mobile |
|---|-----------|------|-------|-------|------|--------|
| 15 | `meine-reminders` | Meine überfälligen Reminders | user | alle | half | full |
| 16 | `team-workload` | Team-Workload-Tabelle | team | Admin,HoD | half | hidden |
| 17 | `activity-feed-24h` | Activity-Feed (24h) | team | Admin | full | link-only |

### 4.5 Analytics-Widgets (5)

| # | widget_key | Name | Scope | Roles | Size | Mobile |
|---|-----------|------|-------|-------|------|--------|
| 18 | `pipeline-snapshot` | Pipeline-Snapshot | team | Admin,CM,HoD | half | compact |
| 19 | `time-to-fill-trend` | Time-to-Fill-Trend | team | HoD,Admin | half | hidden |
| 20 | `placement-rate-sparte` | Placement-Rate nach Sparte | sparte | Admin,HoD | half | hidden |
| 21 | `honorar-cashflow` | Honorar-Cashflow-Prognose | global | Admin,AM | half | hidden |
| 22 | `jobbasket-gate-backlog` | Jobbasket-Gate-Backlog | team | CM,AM | third | compact |

### 4.6 Agenda-Widgets (2)

| # | widget_key | Name | Scope | Roles | Size | Mobile |
|---|-----------|------|-------|-------|------|--------|
| 23 | `heute-agenda` | Heute · Agenda | user | alle | half | full |
| 24 | `mein-fokus-woche` | Mein Fokus diese Woche | user | alle | half | full |

**Total:** 24 Widgets im Katalog v1.0.

---

## 5. ROLLEN-DEFAULT-LAYOUTS

### 5.1 Candidate Manager

Default-Grid (nach `sort_order`):

```
Row 1: [kpi-blocker-count] [kpi-aktive-prozesse] [kpi-placements-ytd] [kpi-umsatz-ytd]
Row 2: [pending-calls           half] [pending-emails         half]
Row 3: [meine-reminders         half] [stale-prozesse         half]
Row 4: [heute-agenda            half] [garantie-ablauf-14d    half]
Row 5: [jobbasket-gate-backlog  third][pipeline-snapshot      half]
```

Pinned: `kpi-blocker-count`, `pending-calls`, `pending-emails`

### 5.2 Account Manager

```
Row 1: [kpi-umsatz-ytd] [kpi-placements-ytd] [kpi-offene-mandate] [kpi-blocker-count]
Row 2: [to-send-inbox                                             full]
Row 3: [pending-emails          half] [agb-pending              third][claim-faelle-offen third]
Row 4: [scraper-review-queue    half] [heute-agenda              half]
Row 5: [garantie-ablauf-14d     half] [honorar-cashflow          half]
```

Pinned: `to-send-inbox`, `kpi-umsatz-ytd`, `agb-pending`

### 5.3 Admin

```
Row 1: [kpi-umsatz-ytd] [kpi-placements-ytd] [kpi-blocker-count] [kpi-system-health]
Row 2: [team-workload           half] [scraper-review-queue     half]
Row 3: [claim-faelle-offen      third][garantie-ablauf-14d      third][agb-pending third]
Row 4: [heute-agenda            half] [meine-reminders          half]
Row 5: [pipeline-snapshot       half] [honorar-cashflow         half]
Row 6: [time-to-fill-trend      half] [placement-rate-sparte    half]
Row 7: [activity-feed-24h                                       full]
```

Pinned: `kpi-system-health`, `team-workload`, `claim-faelle-offen`

### 5.4 Research Analyst

```
Row 1: [kpi-aktive-prozesse] [kpi-placements-ytd] [kpi-blocker-count] [scraper-review-queue]
Row 2: [scraper-review-queue (detail) full]
Row 3: [meine-reminders         half] [heute-agenda              half]
Row 4: [pipeline-snapshot       full]
```

Pinned: `scraper-review-queue`

### 5.5 Backoffice

```
Row 1: [kpi-umsatz-ytd] [honorar-cashflow (kompakt)] [agb-pending] [kpi-blocker-count]
Row 2: [honorar-cashflow        full]
Row 3: [meine-reminders         half] [heute-agenda              half]
```

### 5.6 Head of Sparte

Kombiniert Account Manager + Analytics-Fokus:

```
Row 1: [kpi-placements-ytd] [kpi-umsatz-ytd] [placement-rate-sparte] [kpi-blocker-count]
Row 2: [team-workload           half] [pipeline-snapshot          half]
Row 3: [time-to-fill-trend      half] [honorar-cashflow           half]
Row 4: [stale-prozesse          half] [garantie-ablauf-14d        half]
```

### 5.7 Combined (Doppelrollen-Merge)

Dynamisch aus `role` + `additional_roles[]`:
- Union aller Widget-Keys aus allen Rollen-Defaults
- Deduplizierung: gleicher `widget_key` nur einmal
- Sort-Order: Minimum `sort_order` über alle Rollen
- Beispiel PW (Admin + Account Manager): alle Admin-Widgets + alle Account-Manager-Widgets, deduped

---

## 6. CUSTOMIZATION-UX (User-Edit-Modus)

### 6.1 Edit-Modus-Toggle

**Button oben rechts (neben Rollen-Toggle):** `✎ anpassen`

Klick öffnet Edit-Modus:
- Hintergrund-Overlay `rgba(0,0,0,0.04)` über Dashboard
- Jedes Widget erhält:
  - **`⋮⋮ Drag-Handle`** oben-links — ermöglicht CSS-Grid-Drag-Reorder
  - **`✕ Close-Button`** oben-rechts — entfernt Widget (außer `is_pinned=true`)
  - **Resize-Handle** unten-rechts (klein) — zwischen `quarter` / `third` / `half` / `full`
  - **`⚙ Config-Icon`** (wenn `config_schema` nicht null) — öffnet Widget-Config-Drawer
- **`+ Widget hinzufügen`** Button erscheint unten — öffnet Widget-Katalog-Drawer
- Oben rechts: `💾 Speichern` + `↺ Auf Default zurücksetzen`

### 6.2 Widget-Katalog-Drawer (540px, nach Option-B-Pattern)

Drawer-Struktur analog zum History-Drawer:

```
Drawer-Head:  „Widgets hinzufügen"
Drawer-Body:
  - Search: „🔍 Widget suchen …"
  - Kategorie-Filter-Chips: Alle · KPI · Triage · Alert · Ops · Analytics · Agenda
  - Liste (list-item pro Widget):
    - widget_name + description
    - Chips: Category · Scope · Rollen-Limit
    - „+ Hinzufügen"-Button
    - Preview-Thumbnail (optional)
Drawer-Foot:  „Schliessen" · „✓ Ausgewählte hinzufügen (N)"
```

**Filterung:**
- Nur Widgets mit aktueller Rolle in `allowed_roles`
- Bereits aktive Widgets sind ausgegraut (oder „✓ bereits aktiv")
- `is_pinnable=false` (z.B. Blocker-KPI) werden nicht gelistet (sind immer pinned)

### 6.3 Widget-Config-Drawer

Wenn Widget `config_schema` hat (JSON-Schema), generiert das UI automatisch Formular:

```json
{
  "widget_key": "pending-calls",
  "config_schema": {
    "type": "object",
    "properties": {
      "timeframe_days": { "type": "integer", "minimum": 1, "maximum": 30, "default": 1 },
      "auto_accept_threshold": { "type": "integer", "minimum": 0, "maximum": 100, "default": 90 }
    }
  }
}
```

UI: Zahl-Input (Zeitraum-Days), Slider (Auto-Accept-Threshold).

### 6.4 Save-Flow

Klick `💾 Speichern`:
1. Sammel aller aktuellen Widget-States im DOM (Reihenfolge, Sichtbarkeit, Size, Config)
2. Build `dashboard_layout_json.views[active_role].widgets[]`
3. `PATCH /api/v1/me/dashboard-layout` mit vollständigem Layout
4. Optimistisch UI-Update, Error-Rollback falls Fetch fehlschlägt
5. Exit Edit-Modus, Banner: „Layout gespeichert · Multi-Device-Sync aktiv"

### 6.5 Reset-to-Default

Klick `↺ Auf Default zurücksetzen`:
1. Confirm-Modal „Alle Anpassungen für Ansicht <role> zurücksetzen?"
2. Bei Bestätigung: `PATCH /api/v1/me/dashboard-layout` mit `{views: {<role>: null}}` → löscht override
3. Re-Render aus `dim_dashboard_role_defaults`

---

## 7. MOBILE-RESPONSIVE (Q7)

### 7.1 Breakpoints

```css
--bp-mobile: 767px;
--bp-tablet: 1279px;
--bp-desktop: 1280px;
```

### 7.2 `mobile_mode`-Behandlung pro Widget

| Mode | Desktop | Tablet | Mobile |
|------|---------|--------|--------|
| `full` | volle Card | volle Card | volle Card, full-width |
| `compact` | volle Card | volle Card | Titel + Count-Badge + „→ Details" (Tap öffnet Drawer) |
| `hidden` | volle Card | volle Card | `display:none` |
| `link-only` | volle Card | volle Card | Nur Headline + Count + Link |

**Beispiel `pending-calls` (`mobile_mode=compact`):**

- Desktop: Tabelle mit 5 Rows + Filter + Bulk-Actions
- Mobile: `📞 Unklassifizierte Anrufe · 7 pending · → Alle ansehen`
- Tap öffnet Full-Screen-Page `/mobile/pending-calls` (out of scope v1.0)

### 7.3 Layout-Anpassung

```css
@media (max-width: 767px) {
  .dashboard-grid { grid-template-columns: 1fr; gap: 12px; }
  .widget { grid-column: span 1 !important; }  /* ignoriere default_size */
  .kpi-strip { grid-template-columns: repeat(2, 1fr); } /* KPIs in 2er-Grid */
  .role-toggle { display: none; }  /* Rollen-Wechsel nur Desktop */
  .edit-mode-toggle { display: none; }  /* Edit-Modus nur Desktop */
}
```

**Grund:** Edit-Modus ist komplex, Touch-Drag-Reorder ist fehleranfällig — auf Mobile read-only.

### 7.4 Performance-Constraint

Mobile lädt nur `mobile_mode IN ('full','compact','link-only')` Widgets — `hidden` wird nicht gefetcht (Payload-Ersparnis).

---

## 8. API-ENDPOINTS

### 8.1 Dashboard-Rendering

```
GET  /api/v1/me/dashboard
  → { active_role, available_roles, widgets: [{key, data, config, layout}, ...] }

GET  /api/v1/me/dashboard?role=AM
  → Force-Rendering einer spezifischen Rolle-View (Toggle)

PATCH /api/v1/me/dashboard-layout
  Body: { views: { AM: {...} } }
  → Updatet dashboard_layout_json, returns 200 OK
```

### 8.2 Widget-Daten

```
GET /api/v1/dashboard/widgets/:widget_key
  Query: config_json=<base64>
  → Widget-spezifische Daten (je nach endpoint im Katalog)

Beispiele:
  GET /api/v1/dashboard/widgets/pending-calls?config={timeframe_days:1}
  GET /api/v1/dashboard/widgets/stale-prozesse?config={stage_filter:'Interview'}
  GET /api/v1/dashboard/widgets/garantie-ablauf-14d
```

### 8.3 Admin-Template-Editor

```
GET  /api/v1/admin/dashboard-templates              (nur Admin)
GET  /api/v1/admin/dashboard-templates/:role_key
PATCH /api/v1/admin/dashboard-templates/:role_key
  Body: { widgets: [...] }
  → Updatet dim_dashboard_role_defaults
  → Audit-Log-Entry
```

### 8.4 WebSocket Live-Updates

```
WSS /ws/tenant/:tenantId/live
  Topic: dashboard.widget.<widget_key>
  Payload: { widget_key, user_id, delta: {...} }
```

Beispiele:
- `dashboard.widget.pending-calls` — neue Pending-Calls-Row live pushen
- `dashboard.widget.kpi-blocker-count` — Count-Änderung live

---

## 9. MIGRATION

### 9.1 SQL-Migration-Script

```sql
BEGIN;

-- Schritt 1: Neue Tabellen
CREATE TABLE ark.dim_dashboard_widgets (...);
CREATE TABLE ark.dim_dashboard_role_defaults (...);

-- Schritt 2: dim_crm_users erweitern
ALTER TABLE ark.dim_crm_users
  ADD COLUMN additional_roles text[] DEFAULT '{}',
  ADD COLUMN dashboard_layout_json jsonb NULL,
  ADD COLUMN active_dashboard_view text NULL;

-- Schritt 3: Widget-Katalog seeden (24 Rows)
INSERT INTO ark.dim_dashboard_widgets (widget_key, widget_name, ...) VALUES
  ('kpi-umsatz-ytd', 'Umsatz YTD', ..., 'kpi', 'global', ARRAY['Admin','AM','HoD'], 'quarter', 'full'),
  ('pending-calls', 'Pending Calls Triage', ..., 'triage', 'user', ARRAY['AM','CM','Admin'], 'half', 'compact'),
  -- ... (22 weitere)
  ;

-- Schritt 4: Rolle-Defaults seeden (~48 Rows: 6 Rollen × ~8 Widgets)
INSERT INTO ark.dim_dashboard_role_defaults (tenant_id, role_key, widget_id, sort_order, is_pinned) VALUES
  -- CM-Template
  ((SELECT id FROM ark.dim_tenants LIMIT 1), 'CM', (SELECT id FROM ark.dim_dashboard_widgets WHERE widget_key='kpi-blocker-count'), 0, true),
  ((SELECT id FROM ark.dim_tenants LIMIT 1), 'CM', (SELECT id FROM ark.dim_dashboard_widgets WHERE widget_key='pending-calls'), 10, true),
  -- ... (6 × ~8 = 48 Rows total)
  ;

COMMIT;
```

### 9.2 Rollout-Phasen

| Phase | Dauer | Scope |
|-------|-------|-------|
| A | 1d | SQL-Migration in Staging + Seed-Check |
| B | 2d | Frontend: Widget-Registry-Loader + Role-Default-Rendering |
| C | 3d | Frontend: Edit-Modus + Drag-Reorder + Save-Flow |
| D | 2d | Frontend: Widget-Katalog-Drawer + Config-Drawer |
| E | 2d | Doppelrollen-Toggle + Combined-View |
| F | 3d | Mobile-Responsive (Breakpoints + mobile_mode) |
| G | 2d | Admin-Template-Editor Route `/admin/dashboard-templates` |

**Total:** ~15d für volle Customization-Infrastruktur.

Parallel: **Widget-Content-Ausbau** (17 neue Widgets aus Dashboard-Analyse-Report) läuft in eigenen Sprints.

### 9.3 Rollback

Alles additiv. Emergency-Rollback:

```sql
-- Disable Customization, fallback auf hardcoded Dashboard
UPDATE ark.dim_automation_settings
  SET value_bool = false
  WHERE key = 'dashboard_customization_enabled';
```

Frontend prüft Flag und rendert notfalls altes statisches Layout.

---

## 10. OPEN QUESTIONS

| # | Frage | Default-Vorschlag |
|---|-------|-------------------|
| Q1 | Widget-Cache-Strategie (API-Calls)? | Redis-Cache 60s TTL pro (user_id, widget_key) |
| Q2 | Config-Schema via JSON-Schema oder custom DSL? | **JSON-Schema** (standardisiert, Frontend-Gen) |
| Q3 | Max Widgets pro Dashboard-View? | **20** (UI-Performance) — Soft-Limit mit Warnung |
| Q4 | Widget-Lazy-Loading? | Ja — nur sichtbare Widgets beim Scroll fetchen |
| Q5 | Bei Rolle-Wechsel: sofortiger Load oder Confirm? | **Sofort** — User erwartet Schnelligkeit |
| Q6 | Konflikt: User hat Widget überlagert, Admin deprecated es im Katalog? | Widget aus User-Layout entfernt + Banner „Widget X nicht mehr verfügbar" |
| Q7 | Legacy-Dashboard ohne Customization: wann entfernen? | v1.3 Frontend-Release (Hard-Cutover) |

---

## 11. SYNC-MATRIX zu Grundlagen

| Grundlagen-Datei | Änderung | Version-Bump |
|------------------|----------|--------------|
| `ARK_DATABASE_SCHEMA_v1_3.md` | +2 Tabellen + 3 `dim_crm_users` Spalten | → v1_5 |
| `ARK_FRONTEND_FREEZE_v1_*.md` | Dashboard-Grid-System + Mobile-Breakpoints + Edit-Modus-Pattern | neue Version |
| `ARK_BACKEND_ARCHITECTURE_v2_6.md` | +Dashboard-API-Endpoints (§C neu) + WebSocket-Topic | → v2_7 |
| `ARK_GESAMTSYSTEM_UEBERSICHT_v1_*.md` | Changelog „Dashboard-Customization v1.0" | neue Version |
| `ARK_STAMMDATEN_EXPORT_v1_*.md` | Neuer §: Dashboard-Widget-Registry | → v1_5 |

**Detailmasken-Specs:** keine direkte Auswirkung (Dashboard ist eigene Route).

---

## 12. FERTIGSTELLUNGS-KRITERIEN v1.0

- [ ] SQL-Migration `002_dashboard_customization.sql` gereviewt + Staging
- [ ] `dim_dashboard_widgets` mit 24 Rows geseeded
- [ ] `dim_dashboard_role_defaults` mit ~48 Rows (6 Rollen × ~8 Widgets) geseeded
- [ ] Widget-Loader rendert Role-Defaults für alle 7 Rollen
- [ ] Edit-Modus: Drag-Reorder + Hide/Show + Resize funktional
- [ ] Widget-Katalog-Drawer mit Search/Filter/Add-Flow
- [ ] Doppelrollen-Toggle (Admin ↔ Account Manager ↔ Combined) persistiert Auswahl
- [ ] Admin-Template-Editor `/admin/dashboard-templates` mit Audit-Log
- [ ] Mobile-Responsive: 3 Breakpoints + `mobile_mode` respektiert
- [ ] Widget-Lazy-Load + Redis-Cache aktiv
- [ ] 5 Grundlagen-Dateien synchronisiert

---

## 13. MOCKUPS (zu erstellen)

| Datei | Scope | Priorität |
|-------|-------|-----------|
| `mockups/dashboard.html` | Erweitert mit Role-Toggle + Edit-Modus + Widget-Katalog-Drawer | P0 |
| `mockups/dashboard-edit-mode.html` | Fokus-Mockup für Edit-Modus-Demo (Drag-Reorder, +Widget, Resize) | P0 |
| `mockups/dashboard-mobile.html` | Mobile-Viewport-Demo (375px + 768px + 1280px) | P1 |
| `mockups/admin-dashboard-templates.html` | Admin-Template-Editor | P2 |

---

**Ende v1.0.** Review-Freigabe durch PO + Backend-Lead + mind. 2 Rollen-Vertreter (Candidate Manager + Account Manager) erforderlich vor Implementierungs-Start.
