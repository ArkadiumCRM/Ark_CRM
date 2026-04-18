---
title: "Design System — ARK CRM Mockups"
type: concept
created: 2026-04-16
updated: 2026-04-16
tags: [design-system, conventions, ui-patterns, style-guide, reference]
---

# Design System — ARK CRM Mockups

Dieses Dokument fasst **alle Design-, Style- und Interaktions-Konventionen** zusammen, wie sie in den harmonisierten Detailmasken `accounts.html`, `candidates.html`, `mandates.html` etabliert wurden. Weitere Tabs/Masken müssen diese Conventions einhalten.

**Shared Assets**: `mockups/_shared/editorial.css` (globales CSS), `mockups/_shared/layout.js` (shared JS-Funktionen).

---

## 1. Farb-Palette

### Semantische Farbzuweisung (VERBINDLICH)

| CSS-Var | Hex (light) | Verwendung |
|---|---|---|
| `--accent` Navy | `#1A3A5C` | Primary CTAs, aktive Tabs, Hauptüberschriften, Links |
| `--gold` | `#B8860B` | **Success, Placement, AI-generated, Completion, Hervorhebung** |
| `--red` | `#C0392B` | **Errors, Overdue, Blocked, Critical, Rejected, DNC** |
| `--green` | `#1A6B4A` | **Positiv-Trend, Go-State, Matched, Hired** |
| `--amber` | `#D97706` | **Warning, Pending, At-Risk, Caution, WIP** |
| `--blue` | `#2D5F8A` | **Info, Tech, Reference, Secondary** |
| `--purple` | `#6B4A8A` | **AI/Analysis, Assessment, Messaging, Subtabs** |

**Regel**: Niemals amber für Fehler (→ red), niemals green für Warning (→ amber), niemals rot für Success (→ gold). Intent → Farbe.

### Soft-Varianten
`--X-soft` (10–15 % Transparenz) für Backgrounds, Avatare, Badge-Füllungen. Beispiel: `.chip-gold { background:var(--gold-soft); color:var(--gold); }`

---

## 2. Typografie

| Font | Verwendung |
|---|---|
| **Libre Baskerville** (serif) | H1/H2/H3/H4, KPI-Values, Card-Titles (alles Hierarchie + Zahlen) |
| **DM Sans** (sans-serif) | Body-Text, Labels, Meta, Buttons, Chips (alles andere) |

### Grössen-Hierarchie

| Element | Font / Grösse / Weight / Farbe |
|---|---|
| Page-Title h1 | Libre B · 26pt · 700 · navy |
| Drawer h2 | Libre B · 18pt · 700 · navy |
| Card-Title h3 | Libre B · 14pt · 700 · navy |
| Drawer-Section h4 | DM Sans · 10.5pt · 600 caps · text-light · letter-spacing 1.2px |
| KPI-Value | Libre B · 28pt · 700 · modifier-Farbe |
| KPI-Label | DM Sans · 10.5pt · 500 caps · text-light · letter-spacing 1.2px |
| Body-Text | DM Sans · 13–14pt · 400 · text |
| Meta/Muted | DM Sans · 11–12pt · 400 · text-light |
| Time/Number | Tabular-Nums via `font-variant-numeric:tabular-nums` |

### Letter-Spacing
- Caps-Labels: `letter-spacing: 1–1.2px`
- Section-Titles: `letter-spacing: 0.15em` / `0.2em`
- Brand-Caps (z.B. ABSTRACT): `letter-spacing: 0.4–0.6em`

---

## 3. Komponenten

### 3.1 Tab-Struktur

```html
<nav class="tabbar">
  <div class="tab active" data-tab="1" onclick="switchTab(1)"><span class="num">1</span>Übersicht</div>
  <div class="tab" data-tab="2" onclick="switchTab(2)"><span class="num">2</span>Label</div>
  <div class="tab conditional" data-tab="N" onclick="switchTab(N)"><span class="num">N</span>🏛 Konditional</div>
</nav>
<div id="tab-1" class="tab-panel active">…</div>
<div id="tab-2" class="tab-panel">…</div>
```

**Regeln**:
- Max 14 Tabs (Accounts), sonst Information-Overload
- Numbered (`.num`), aktiver Tab: navy-Text + gold-Underline, aktive Zahl: gold
- `.tab.conditional`: gold-soft bg, zeigt nur bei bestimmten Bedingungen
- Tab-Switch immer via `switchTab(n)` aus `layout.js`

### 3.2 KPI-Strip (CANONICAL)

```html
<div class="kpi-strip cols-5">
  <div class="kpi-card red">
    <div class="kpi-label">Überfällig</div>
    <div class="kpi-value">2</div>
    <div class="kpi-sub muted">sofort</div>
  </div>
</div>
```

**Modifier**:
- Spalten: `.cols-2` bis `.cols-6`
- Farben: `.red`, `.gold`, `.green`, `.amber`, `.blue`, `.purple`, `.muted` (default = accent)

**Regel**: 3-px Color-Accent-Strip oben via `::before`. Label + Value farblich gekoppelt via Modifier-Klasse.

**NIEMALS**: `style="display:grid;grid-template-columns:..."` inline, `style="color:var(--red)"` auf kpi-label/kpi-value.

### 3.2b Snapshot-Bar (CANONICAL)

**Zweck**: Schmale, **sticky** Leiste mit **6 operativen Metriken** der Entity — über allen Tabs sichtbar. Unterscheidet sich bewusst vom KPI-Strip (der pro Tab variiert).

```html
<div class="snapshot-bar" style="position:sticky;top:0;z-index:50">
  <div class="snapshot-item">
    <span class="lbl">📊 Label</span>
    <span class="val">Wert</span>
    <span class="delta up">Sub-Info / Trend</span>
  </div>
  … insgesamt 6 items …
</div>
<nav class="tabbar" style="position:sticky;top:64px;z-index:49">…</nav>
```

**Stacking** (PFLICHT): Snapshot-Bar oben (`top:0`), Tabbar darunter (`top:64px`). Z-Index 50 > 49. Snapshot zuerst, Tabs danach — „Identität vor Navigation".

**Delta-Modifier**: `.delta.up` (green), `.delta.down` (red), Default (grey).

**Progress-Bar optional** (für Mandate-Metriken mit Zielwert):
```html
<div class="snapshot-item">
  <span class="lbl">📊 Idents</span>
  <span class="val">38 / 50</span>
  <span class="delta up">76 %</span>
  <div class="ms-progress" style="margin-top:4px"><div class="bar green" style="width:76%"></div></div>
</div>
```

#### Slot-Belegung pro Entity

**Header vs. Snapshot-Regel** (CRITICAL): Snapshot-Bar-Slots dürfen **nicht duplizieren**, was bereits im Header (banner-meta, banner-chips) steht. Header = Identität/Klassifizierung/Status · Snapshot = operative Zahlen/Progress.

| Entity | 6 Slots |
|---|---|
| **Account** | Mitarbeitende · Wachstum 3J · Umsatz · Gegründet · Standorte · Kulturfit (firmografisch) |
| **Candidate** | Ø Match-Score · Im Jobbasket · Aktive Prozesse · Refresh-Due · Placements hist. · Assessments |
| **Mandate** | Idents · Calls · Shortlist · Pauschale · Time-to-Fill · Placements |
| **Group** | Gesellschaften · Mitarbeitende · Umsatz · Aktive Prozesse · Placements YTD · Arkadium-Umsatz YTD |
| **Job** | Matches ≥ 70 % · Im Jobbasket · Aktive Prozesse · Standort · TC-Range · Ø Match-Score |
| **Projekt** | Volumen · Zeitraum · BKP-Gewerke · Beteiligte Firmen · Beteiligte Kandidaten · Medien (projekttyp-agnostisch: Hoch-/Tiefbau/Infrastruktur) |

**NIEMALS in Snapshot**: Status (→ Status-Dropdown), Owner/AM (→ banner-meta), Entity-Links (→ banner-chips), Compliance-Flags (→ banner-chips).

### 3.3 Drawer

**Standard 540 px** (für Forms, Upload, Reminder, einfache Details):
```html
<div class="drawer" id="xyzDrawer">
  <div class="drawer-head">
    <div style="width:48px;height:48px;border-radius:4px;background:var(--gold-soft);color:var(--gold);display:flex;align-items:center;justify-content:center;font-size:22px;flex-shrink:0">↑</div>
    <div class="info"><h2>Titel</h2><div class="sub">Subtitel</div></div>
    <button class="drawer-close" onclick="closeDrawer('xyzDrawer')">✕</button>
  </div>
  <div class="drawer-body">…</div>
  <div class="drawer-foot">
    <button class="btn btn-sm" onclick="closeDrawer('xyzDrawer')">Abbrechen</button>
    <span class="spacer"></span>
    <button class="btn btn-sm btn-primary">Speichern</button>
  </div>
</div>
```

**Wide 760 px** (`.drawer.drawer-wide`) für Multi-Tab-Complex-Edits:
- `mandatDrawer`, `claimDrawer`, `procDrawer`, `vakanzDrawer`, `jobDrawer`, `posDrawer`, `contactDrawer` (Accounts)
- `educationDrawer`, `stationDrawer`, `werdegangProjektDrawer`, `historyDrawer` (Candidates)
- `historyDrawer` (Mandates)

**Icon-Box-Pattern** (48×48 im drawer-head):
- Upload: `↑` auf `var(--gold-soft)`
- History: `💬` oder Kategorie-Icon auf `var(--accent-soft)`
- Reminder: `⏰` auf `var(--accent-soft)`
- Document: `PDF/DOCX/XLSX`-Label auf `var(--accent-soft)`
- Mandat kündigen: `🛑` auf `var(--red-soft)`

**Drawer-Tabs im Drawer**:
```html
<div class="drawer-tabs">
  <div class="drawer-tab active" onclick="drawerTab('xyzDrawer', 0)">Übersicht</div>
  <div class="drawer-tab" onclick="drawerTab('xyzDrawer', 1)">Weitere</div>
</div>
<div class="drawer-body">
  <div class="drawer-pane" style="display:block">…</div>
  <div class="drawer-pane" style="display:none">…</div>
</div>
```

**Drawer-Body-Padding**: 18 px 22 px (540) bzw. 22 px 28 px (wide).

**Backdrop** (PFLICHT für alle Masken):
```html
<div class="drawer-backdrop" id="drawerBackdrop" onclick="closeDrawer()"></div>
```
Ohne Backdrop bricht `openDrawer()`.

### 3.4 Button-Varianten

| Klasse | Zweck | Visuell |
|---|---|---|
| `.btn` | Default | Surface bg, text-color, hover → accent |
| `.btn.btn-primary` | Primary CTA, Save, Confirm | navy bg, white text |
| `.btn.btn-sm` | Small (im Filter-Bar, Drawer-Foot) | 5 px × 10 px padding |
| `.btn.btn-danger` | Destructive secondary (Kündigen, Löschen) | red text + red border |
| `.btn.btn-danger.btn-primary` | Destructive Primary | red bg + white text |

**NIEMALS**: `style="color:var(--red)"` auf Buttons — nutze `.btn-danger`.

### 3.5 Chip-Filter & Filter-Bar

```html
<div class="filter-bar">
  <input type="search" placeholder="🔍 Suche …" style="flex:1">
  <select>…</select>
  <select>…</select>
  <span class="spacer"></span>
  <button class="btn btn-sm btn-primary">+ Action</button>
</div>
<div class="filter-bar" style="padding-top:0">
  <div class="chip-group">
    <div class="chip-tab active" onclick="filterX(this,'all')">Alle <span class="count">N</span></div>
    <div class="chip-tab" onclick="filterX(this,'key')">Label <span class="count">n</span></div>
  </div>
</div>
```

**Reihenfolge Filter-Bar**: Search → Selects → Spacer → Primary-Action-Button (rechts).
**Zweite Filter-Bar** (Chip-Tabs) separat mit `padding-top:0` für visuelle Continuity.

### 3.6 Data-Tables

```html
<table class="data-table">
  <thead><tr><th>Name</th><th>Kategorie</th><th class="right">›</th></tr></thead>
  <tbody>
    <tr onclick="openDrawer('xyzDrawer', 0)">
      <td><strong>Title</strong><div class="muted">Subtitle</div></td>
      <td><span class="chip chip-accent">Label</span></td>
      <td class="right"><button class="row-icon-btn">›</button></td>
    </tr>
  </tbody>
</table>
```

**Regeln**:
- Row-Click öffnet Detail-Drawer: `onclick="openDrawer('xyzDrawer', 0)"`
- Letzte Spalte: `.row-icon-btn` mit `›` als Affordance
- Status-Color: `style="background:color-mix(in srgb, var(--red) 6%, var(--surface));border-left:3px solid var(--red)"` für Alert-Rows

### 3.7 History-Timeline

```html
<div class="hist-timeline">
  <div class="hist-day">
    <div class="hist-day-head">Heute · 14.04.2026</div>
    <div class="hist-row [hist-warn|hist-ok]">
      <div class="hist-time">14:22</div>
      <div class="hist-cat"><span class="hist-cat-chip cat-erreicht">Erreicht</span></div>
      <div class="hist-body">
        <div class="hist-title"><strong>Update-Call · Hans Müller</strong> <span class="muted">— 42 min</span></div>
        <div class="hist-sub">CFO-Mandat Update …</div>
        <div class="hist-meta"><span class="actor">PW</span> · <a href="#">Kontakt</a></div>
      </div>
    </div>
  </div>
</div>
```

**Category-Chips** (PFLICHT, keine Freitext-Activity-Namen):
- `cat-kontakt` · `cat-erreicht` · `cat-email` · `cat-messaging` · `cat-interview` · `cat-placement` · `cat-mandat` · `cat-assessment` · `cat-refresh` · `cat-erfolgsbasis` · `cat-system`

**Row-Click öffnet historyDrawer** (Mandates + Candidates haben dies; Accounts bislang nicht).
**historyDrawer** hat kontextabhängige Tabs (Übersicht / Email-Thread / Transkript / AI-Summary / AI→Briefing / Reminders).

### 3.8 Reminder-Pattern

```html
<!-- Tab-weit -->
<div class="filter-bar">
  <div class="chip-group">
    <div class="chip-tab active" onclick="filterRemStatus(this,'all')">Alle offenen <span class="count">N</span></div>
    <div class="chip-tab" onclick="filterRemStatus(this,'overdue')"><span style="color:var(--red)">●</span> Überfällig <span class="count">n</span></div>
    <div class="chip-tab" onclick="filterRemStatus(this,'today')">Heute <span class="count">n</span></div>
    <div class="chip-tab" onclick="filterRemStatus(this,'week')">Diese Woche <span class="count">n</span></div>
    <div class="chip-tab" onclick="filterRemStatus(this,'later')">Später <span class="count">n</span></div>
    <div class="chip-tab" onclick="filterRemStatus(this,'done')">Erledigt <span class="count">n</span></div>
  </div>
</div>

<div class="rem-section" data-rem-group="overdue">…</div>
<div class="rem-section" data-rem-group="today">…</div>
<div class="rem-section" data-rem-group="week">…</div>
<div class="rem-section" data-rem-group="later">…</div>
<div class="section-head collapsed" onclick="toggleSection(this)">Erledigt (30 Tage)</div>
<div class="section-body">…</div>
```

**Erledigt** ist IMMER collapsed als `.section-head` + `.section-body`.
**Filter-Logik**: `filterRemStatus()` aus `layout.js` — scoped auf nächstes `.tab-panel`.

### 3.9 Upload-Drawer (Standard-Pattern)

Alle 3 Masken haben den exakt gleichen Upload-Drawer mit:
- **Dropzone** (dashed border, klickbar, accept=PDF/DOCX/XLSX/JPG/PNG)
- **Kategorie-Select** (entity-spezifisch, siehe `dokumente-kategorien.md`)
- **Titel** (optional, defaults zu Dateiname)
- **Notiz** (textarea)
- **Verknüpfung** (Select mit kontextuellen Optionen)
- **Urheber** (automatisch = aktueller User, read-only `<div>`)

**`+Upload`-Button** immer via `onclick="openDrawer('uploadDrawer',0)"`.

### 3.10 Form-Drawer Grid-Layout

```html
<div class="drawer-section">
  <h4>Metadaten</h4>
  <div style="display:grid;grid-template-columns:140px 1fr;gap:10px 16px;align-items:center;font-size:13px">
    <label>Titel <span style="color:var(--red)">*</span></label>
    <input type="text">
    <label>Typ</label>
    <select>…</select>
  </div>
</div>
```

**Regel**: 140 px Label-Spalte + 1 fr Input-Spalte. Required-Sterne in rot.

---

## 4. Layout & Spacing

| Kontext | Padding |
|---|---|
| `.content` (Page) | 24 px 32 px 60 px |
| `.drawer-body` | 18 px 22 px (standard) / 22 px 28 px (wide) |
| `.drawer-section` | margin-bottom 18 px, padding-bottom 16 px |
| `.card` | 20 px (standard) / 14 px 16 px (compact) |
| `.kpi-strip .kpi-card` | 14 px 16 px |
| `.filter-bar` | 12 px 16 px |
| `.data-table td` | 12 px |

**Card-Margin zwischen Karten**: 16 px.
**Grid-Gaps**: 20 px (2-col) · 14 px (3+ col) · 12 px (KPI-Strip).

---

## 5. Icon-Konventionen

### Inline-Emojis

| Emoji | Zweck |
|---|---|
| 📊 | Data/KPI |
| 📞 | Phone |
| ✉ | Email |
| 👔 | Interview |
| 🏆 | Placement |
| 📋 | Mandate/Board |
| 🛡 | Protection/Schutzfrist |
| ⚡ | AI/Auto |
| 🔥 | Hot/Urgent |
| ⚠ | Warning |
| 🎯 | Target Mandate |
| 🛑 | Destructive (Kündigen) |
| ↑ | Upload |
| ↓ | Download |
| ↗ / ↙ | Outgoing/Incoming |
| › | Open detail (row-icon-btn) |
| ✕ | Close |
| ✓ / ✗ | Confirm/Deny |

### Kategorie-Icons im History-Drawer
Werden per `HIST_CHAN_MAP` gemappt (siehe `layout.js` bzw. inline in candidates/mandates):
```js
{ 'cat-erreicht': '📞', 'cat-interview':'👔', 'cat-email':'✉', 'cat-placement':'🏆', 'cat-mandat':'📋', 'cat-assessment':'📊', 'cat-system':'⚙' }
```

---

## 6. Shared JavaScript (`layout.js`)

**IMMER** aus layout.js nutzen, niemals inline duplizieren:

| Function | Zweck |
|---|---|
| `switchTab(n)` | Tab-Switching |
| `toggleTheme()` | Dark-/Light-Mode |
| `toggleCollapse(headEl)` | Card-Collapse |
| `toggleSection(headEl)` | Section-Head-Collapse |
| `openDrawer(id, tabIdx)` | Drawer öffnen + optional Tab |
| `closeDrawer(id?)` | Drawer schliessen |
| `drawerTab(drawerId, idx)` | Drawer-interne Tab-Wechsel |
| `switchSubtab(groupId, idx)` | Subtab-Wechsel |
| `openModal(id)` / `closeModal(id)` | Modal |
| `enterEdit(linkEl)` / `saveEdit(btn)` / `cancelEdit(btn)` | Inline-Edit-Modus |
| `filterDocCat(chipEl, cat)` | Dokumente-Filter |
| `switchDocView(chipEl, mode)` | Liste/Kacheln-Toggle |
| `filterRemStatus(chipEl, group)` | Reminder-Gruppen-Filter (scoped) |
| `updateDocLinkItems(type)` | Dokument-Verknüpfungs-Select |
| `toggleTag(el)` / `syncSparteHeader(group)` | Sparten-Toggle + Header-Sync |

**Inline-JS nur für maskenspezifische Logik** (z.B. `renderDiscWheel` in candidates, `renderTimeline` in mandates).

---

## 7. Drawer-Infrastruktur-Pflicht

Jede Maske MUSS enthalten:
1. `<div class="drawer-backdrop" id="drawerBackdrop" onclick="closeDrawer()"></div>` am Ende des Body
2. `<script src="_shared/layout.js"></script>` vor `</body>`
3. `<link rel="stylesheet" href="_shared/editorial.css">` im Head

Ohne diese 3 Elemente brechen Drawer + Tabs.

---

## 8. Stammdaten-Regeln

Siehe `CLAUDE.md` · Stammdaten-Wording-Regel und `raw/Ark_CRM_v2/ARK_STAMMDATEN_EXPORT_v1_3.md`.

**Kritisch vor UI-Text**:
- History-Category-Chips = nur `dim_activity_types`-Werte
- Prozess-Stages = Expose · CV Sent · TI · 1st · 2nd · 3rd · Assessment · Offer · Placement
- Mitarbeiter = 2-Buchstaben-Kürzel (PW/JV/LR), nie Vollname
- Sparten = ARC · GT · ING · PUR · REM
- Echte Umlaute (ä/ö/ü/Ä/Ö/Ü/ß), niemals ae/oe/ue

---

## 9. Weitere Conventions

### Drawer-Default-Regel (aus CLAUDE.md)
CRUD, Bestätigungen, Multi-Step-Inputs → **immer Drawer** (540 px slide-in). Modale nur für kurze Confirms/Blocker.

### Datum-Eingabe
Alle Datums-Felder müssen Kalender-Picker UND Tastatur-Eingabe unterstützen (`<input type="date">` / `datetime-local` / `time`).

### Urheber-Feld bei Upload
**Nicht wählbar** — zeigt immer den aktuellen User (read-only `<div data-value="Upload · XX">`). 

### Dokumente-Kategorien
2 Profile (siehe `dokumente-kategorien.md`):
- **Personal-Profile** (Kandidaten): 11 Kategorien
- **Commercial-Profile** (Accounts + Mandate): 6 Kategorien

### Keine-DB-Technikdetails-im-UI
Niemals `dim_*`, `fact_*`, `_fk`-Namen in User-facing-Texten. Nutze sprechende Begriffe („Stammdaten", „Liste", „Katalog").

---

## 10. Quick-Start-Checkliste für neue Tabs

Wenn eine neue Detail-Maske oder ein neuer Tab gebaut wird:

- [ ] CSS: Nur `.kpi-strip.cols-N` + `.kpi-card.<color>` — keine inline-Grid-Styles
- [ ] Drawer: 540 px Standard, 760 px nur für Multi-Tab-Complex-Edits
- [ ] Drawer-Backdrop + layout.js-Script + editorial.css vorhanden
- [ ] Tabs: `switchTab(n)`, numeriert, Max 14
- [ ] Buttons: `.btn-sm`, `.btn-primary`, `.btn-danger` — keine inline-Farben
- [ ] Filter-Bar: Search → Selects → Spacer → Primary-Action
- [ ] Row-Click öffnet Detail-Drawer
- [ ] History-Category-Chips aus Stammdaten-Liste
- [ ] KPI-Farben semantisch korrekt (red=error, gold=success, etc.)
- [ ] Echte Umlaute, keine ae/oe/ue
- [ ] Upload-Drawer-Pattern wiederverwenden (entity-spezifische Kategorien)
- [ ] Reminder-Pattern wiederverwenden (Überfällig/Heute/Woche/Später/Erledigt)
- [ ] Kein inline-JS was `layout.js` bereits kann

---

## Verwandte Seiten

- [[dokumente-kategorien]] — 2-Profile-Schema für Dokumente
- [[interaction-patterns]] — Globale UX-Patterns (Drawer-Default, Datum-Eingabe, etc.)
- [[spec-sync-regel]] — Spec/Mockup-Sync bei Änderungen
- [[dokument-templates]] — ARK CV, Abstract, Exposé Design-Specs

## Maintenance

Bei Änderungen an Konventionen (neue Farbe, neue Icon-Semantik, neue shared Function): diese Seite aktualisieren UND die 3 Detailmasken retrofiten.
