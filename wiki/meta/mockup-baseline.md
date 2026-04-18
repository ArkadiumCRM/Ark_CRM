---
title: "Mockup-Baseline · Canonical Copy-Paste-Reference"
type: meta
created: 2026-04-17
updated: 2026-04-17
sources: ["mockups/_shared/editorial.css", "mockups/_shared/layout.js", "mockups/candidates.html", "mockups/processes.html", "mockups/jobs.html", "mockups/mandates.html", "mockups/accounts.html", "mockups/groups.html", "mockups/projects.html", "Grundlagen MD/ARK_STAMMDATEN_EXPORT_v1_3.md"]
tags: [baseline, mockup, components, labels, vocabulary]
---

# Mockup-Baseline · Canonical Copy-Paste-Reference

Kanonische HTML/CSS/JS-Snippets zur Stopp-Drift-Garantie über die 9+ Detailmasken. Alle Snippets sind direkt aus den produktiven Mockups extrahiert und funktionieren **nur** zusammen mit `mockups/_shared/editorial.css` + `mockups/_shared/layout.js`.

**Verwendung:** Bei neuem Mockup oder neuer Detailseite **immer zuerst hier prüfen**, dann 1:1 kopieren und minimal anpassen. Niemals blind neu erfinden — jede Abweichung ist Drift.

**Verweis:** Design-System-Regeln siehe `wiki/meta/digests/frontend-freeze-digest.md` (dort: Tokens, Routing, Patterns). Diese Datei enthält ausschliesslich **Copy-Paste-Snippets**.

---

## 0. Boilerplate-Header (jede Detailseite)

**Quelle:** `_shared/editorial.css` + `_shared/layout.js` einbinden.

```html
<!DOCTYPE html>
<html lang="de" data-theme="light">
<head>
<meta charset="UTF-8">
<title>ARK CRM · …</title>
<link rel="stylesheet" href="_shared/editorial.css">
<style>
  /* Seiten-spezifisches CSS hier — NIEMALS generische Patterns duplizieren */
</style>
</head>
<body>
  <!-- Header + Banner + Snapshot-Bar + Tabbar + Content + Drawer -->
  <script src="_shared/layout.js"></script>
</body>
</html>
```

**Anti-Pattern:** Inline-Duplikate von `.drawer`, `.snapshot-bar`, `.tabbar`, `.card`, `.hist-row` — diese sind **immer** in `editorial.css`.

---

## 1. Drawer (540px Slide-in) · CLAUDE.md-Default für CRUD

**Quelle:** `_shared/editorial.css` Z. 844–912, `_shared/layout.js` Z. 54–69, `candidates.html` Z. 4803–4849.

**Regel:** CRUD, Bestätigungen, Mehrschritt-Eingaben **immer als Drawer**. Modal nur für kurze Confirms / Blocker / System-Notifications.

### 1.1 Basis-Drawer (Single-Pane, 540px)

```html
<!-- 1× pro Seite: Backdrop -->
<div class="drawer-backdrop" id="drawerBackdrop" onclick="closeDrawer()"></div>

<!-- Ein Drawer je Use-Case -->
<div class="drawer" id="neuProjektDrawer">
  <div class="drawer-head">
    <div style="width:48px;height:48px;border-radius:4px;background:var(--gold-soft);color:var(--gold);display:flex;align-items:center;justify-content:center;font-size:22px;flex-shrink:0">+</div>
    <div class="info">
      <h2>Neues Projekt anlegen</h2>
      <div class="sub">Kein passendes Projekt gefunden (&lt; 60 % Match)</div>
    </div>
    <button class="drawer-close" onclick="closeDrawer('neuProjektDrawer')">✕</button>
  </div>
  <div class="drawer-body">
    <div class="drawer-section">
      <h4>Pflichtfelder</h4>
      <dl class="field-grid">
        <dt>Projekt-Name <span style="color:var(--red)">*</span></dt>
        <dd><input type="text" placeholder="z.B. Wohnsiedlung Uetlihof" style="width:100%"></dd>
        <dt>Zeitraum von <span style="color:var(--red)">*</span></dt>
        <dd><input type="month" value="2023-04" style="width:160px"></dd>
      </dl>
    </div>
    <div class="drawer-section">
      <h4>Optional</h4>
      <!-- weitere Felder -->
    </div>
  </div>
  <div class="drawer-foot">
    <button class="btn btn-sm" onclick="closeDrawer('neuProjektDrawer')">Abbrechen</button>
    <span class="spacer"></span>
    <button class="btn btn-sm btn-primary">Speichern</button>
  </div>
</div>
```

### 1.2 Wide-Drawer mit Tabs (760px · komplexe Multi-Tab-Edits)

```html
<div class="drawer drawer-wide" id="stationDrawer">
  <div class="drawer-head">
    <div class="avatar">IM</div>
    <div class="info">
      <h2>Gesamtbauleiter Spezialtiefbau · Implenia AG</h2>
      <div class="sub">03/2023 – heute · Zürich</div>
    </div>
    <button class="drawer-close" onclick="closeDrawer('stationDrawer')">×</button>
  </div>
  <div class="drawer-tabs">
    <div class="drawer-tab active" onclick="drawerTab('stationDrawer',0)">Basis</div>
    <div class="drawer-tab" onclick="drawerTab('stationDrawer',1)">Einordnung</div>
    <div class="drawer-tab" onclick="drawerTab('stationDrawer',2)">Motivation</div>
    <div class="drawer-tab" onclick="drawerTab('stationDrawer',3)">Verknüpfungen</div>
  </div>
  <div class="drawer-body">
    <div class="drawer-pane" style="display:block"><!-- Pane 0 --></div>
    <div class="drawer-pane" style="display:none"><!-- Pane 1 --></div>
    <div class="drawer-pane" style="display:none"><!-- Pane 2 --></div>
    <div class="drawer-pane" style="display:none"><!-- Pane 3 --></div>
  </div>
  <div class="drawer-foot">
    <button class="btn btn-sm" onclick="closeDrawer('stationDrawer')">Abbrechen</button>
    <span class="spacer"></span>
    <button class="btn btn-sm btn-primary" onclick="closeDrawer('stationDrawer')">Speichern</button>
  </div>
</div>
```

### 1.3 Kritisches CSS (nicht duplizieren — in `editorial.css`)

```css
.drawer-backdrop { position:fixed; inset:0; background:rgba(0,0,0,0.35);
  opacity:0; pointer-events:none; transition:opacity 0.2s; z-index:200; }
.drawer-backdrop.open { opacity:1; pointer-events:auto; }
.drawer { position:fixed; top:0; right:0; height:100vh; width:540px;
  background:var(--surface); box-shadow:var(--shadow-lg);
  transform:translateX(100%); transition:transform 0.25s ease;
  z-index:201; display:flex; flex-direction:column; }
.drawer.open { transform:translateX(0); }
.drawer.drawer-wide { width:760px; max-width:96vw; }
.drawer-head { padding:18px 22px; border-bottom:1px solid var(--border);
  display:flex; gap:12px; align-items:flex-start; }
.drawer-body { flex:1; overflow-y:auto; padding:18px 22px; }
.drawer-foot { padding:12px 22px; border-top:1px solid var(--border);
  background:var(--bg); display:flex; gap:8px; justify-content:flex-end; }
.drawer-section { margin-bottom:18px; padding-bottom:16px;
  border-bottom:1px solid var(--border); }
.drawer-section h4 { font-size:10.5px; text-transform:uppercase;
  letter-spacing:1.2px; color:var(--text-light); margin-bottom:10px; font-weight:600; }
```

### 1.4 JS-Behaviour (`_shared/layout.js`)

```javascript
function openDrawer(id, tabIdx) {
  document.getElementById('drawerBackdrop').classList.add('open');
  document.getElementById(id).classList.add('open');
  if (tabIdx != null) drawerTab(id, tabIdx);
}
function closeDrawer(id) {
  document.getElementById('drawerBackdrop').classList.remove('open');
  if (id) document.getElementById(id).classList.remove('open');
  else document.querySelectorAll('.drawer.open').forEach(d => d.classList.remove('open'));
}
function drawerTab(drawerId, idx) {
  const drawer = document.getElementById(drawerId);
  drawer.querySelectorAll('.drawer-tab').forEach((t,i) => t.classList.toggle('active', i===idx));
  drawer.querySelectorAll('.drawer-pane').forEach((p,i) => p.style.display = (i===idx)?'block':'none');
}
```

**Empfehlung (ergänzend · aktuell nicht in `layout.js` global verdrahtet):** Escape-Handler pro Seite registrieren:

```javascript
document.addEventListener('keydown', e => {
  if (e.key === 'Escape') closeDrawer();
});
```

### 1.5 Anti-Patterns

- **Modal statt Drawer** für CRUD/Mehrschritt — verboten per CLAUDE.md §Drawer-Default.
- `.drawer` mit `width < 540px` oder `> 760px` — andere Breiten sind nicht erlaubt.
- Nested Drawer (Drawer-im-Drawer) — in Vollseite navigieren statt verschachteln.
- `openModal()` für Speichern-Formulare — nur `openDrawer()`.
- Click-Outside schliesst NICHT den Drawer direkt: Backdrop hat eigenen `onclick="closeDrawer()"`.
- Inline-CSS für `.drawer` — immer aus `editorial.css`.

---

## 2. Stage-Pipeline (9 Dots · Expose → Placement · SVG-Linie)

**Quelle:** `candidates.html` Z. 2861, 2929, 3015 (3 Varianten pro Card) + `candidates.html` Z. 6087 (`PR_STAGES`-Konstante) + `candidates.html` Z. 441–469 (CSS).

**Stages (Stammdaten §13 · Reihenfolge fest):**
`Expose · CV Sent · TI · 1st · 2nd · 3rd · Assessment · Offer · Placement`

**X-Koordinaten (viewBox `0 0 760 86`):** 36 / 122 / 208 / 294 / 380 / 466 / 552 / 638 / 724 (letzter = Diamant).

### 2.1 Default-Pipeline (2nd current, Stages 0–3 passed)

```html
<svg class="pr-pipeline-svg" viewBox="0 0 760 86" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="prg1" x1="0%" y1="0%" x2="100%" y2="0%">
      <stop offset="0%" stop-color="#4f9aa0"/>
      <stop offset="100%" stop-color="#4a8e63"/>
    </linearGradient>
  </defs>
  <!-- Ghost-Linie (volle Länge, grau) -->
  <line x1="36" y1="42" x2="724" y2="42" stroke="#e8e4d8" stroke-width="5" stroke-linecap="round"/>
  <!-- Progress-Linie (bis current-Dot, Gradient) -->
  <line x1="36" y1="42" x2="380" y2="42" stroke="url(#prg1)" stroke-width="5" stroke-linecap="round"/>

  <!-- Passed-Dots (grün, r=5.5, fill + stroke grün) -->
  <circle cx="36"  cy="42" r="5.5" fill="#4a8e63" stroke="#4a8e63" stroke-width="2" data-stage-idx="0" style="cursor:pointer" onclick="prDotClick(this)"/>
  <text   x="36"  y="64" text-anchor="middle" font-size="9" font-weight="500" fill="var(--text-mid)" font-family="DM Sans,sans-serif">Expose</text>
  <circle cx="122" cy="42" r="5.5" fill="#4a8e63" stroke="#4a8e63" stroke-width="2" data-stage-idx="1" style="cursor:pointer" onclick="prDotClick(this)"/>
  <text   x="122" y="64" text-anchor="middle" font-size="9" font-weight="500" fill="var(--text-mid)" font-family="DM Sans,sans-serif">CV Sent</text>
  <circle cx="208" cy="42" r="5.5" fill="#4a8e63" stroke="#4a8e63" stroke-width="2" data-stage-idx="2" style="cursor:pointer" onclick="prDotClick(this)"/>
  <text   x="208" y="64" text-anchor="middle" font-size="9" font-weight="500" fill="var(--text-mid)" font-family="DM Sans,sans-serif">TI</text>
  <circle cx="294" cy="42" r="5.5" fill="#4a8e63" stroke="#4a8e63" stroke-width="2" data-stage-idx="3" style="cursor:pointer" onclick="prDotClick(this)"/>
  <text   x="294" y="64" text-anchor="middle" font-size="9" font-weight="500" fill="var(--text-mid)" font-family="DM Sans,sans-serif">1st</text>

  <!-- Current-Dot (Gold r=7.5 + pulsing Ring) -->
  <circle cx="380" cy="42" r="7.5" fill="#a08749" stroke="var(--accent)" stroke-width="2" data-stage-idx="4" style="cursor:pointer" onclick="prDotClick(this)"/>
  <circle cx="380" cy="42" r="10" fill="none" stroke="#a08749" stroke-width="1.5" opacity="0.4">
    <animate attributeName="r" from="8" to="17" dur="2s" repeatCount="indefinite"/>
    <animate attributeName="opacity" from="0.5" to="0" dur="2s" repeatCount="indefinite"/>
  </circle>
  <text x="380" y="64" text-anchor="middle" font-size="9" font-weight="700" fill="#a08749" font-family="DM Sans,sans-serif">2nd</text>

  <!-- Future-Dots (r=5.5 · fill=surface · stroke=border-strong) -->
  <circle cx="466" cy="42" r="5.5" fill="var(--surface)" stroke="var(--border-strong)" stroke-width="2" data-stage-idx="5" style="cursor:pointer" onclick="prDotClick(this)"/>
  <text   x="466" y="64" text-anchor="middle" font-size="9" font-weight="500" fill="var(--text-light)" font-family="DM Sans,sans-serif">3rd</text>
  <circle cx="552" cy="42" r="5.5" fill="var(--surface)" stroke="var(--border-strong)" stroke-width="2" data-stage-idx="6" style="cursor:pointer" onclick="prDotClick(this)"/>
  <text   x="552" y="64" text-anchor="middle" font-size="9" font-weight="500" fill="var(--text-light)" font-family="DM Sans,sans-serif">Assessment</text>
  <circle cx="638" cy="42" r="5.5" fill="var(--surface)" stroke="var(--border-strong)" stroke-width="2" data-stage-idx="7" style="cursor:pointer" onclick="prDotClick(this)"/>
  <text   x="638" y="64" text-anchor="middle" font-size="9" font-weight="500" fill="var(--text-light)" font-family="DM Sans,sans-serif">Offer</text>

  <!-- Placement-Diamant (14×14 · rotate 45° · fill=surface solange nicht erreicht) -->
  <rect x="717" y="35" width="14" height="14" rx="1" transform="rotate(45 724 42)"
        fill="var(--surface)" stroke="var(--border-strong)" stroke-width="2"
        data-stage-idx="8" style="cursor:pointer" onclick="prDotClick(this)">
    <title>Platzierung · Ziel-Stage (Diamant · nur via Placement-Drawer, V1-Saga)</title>
  </rect>
  <text x="724" y="64" text-anchor="middle" font-size="9" font-weight="500" fill="var(--text-light)" font-family="DM Sans,sans-serif">Placement</text>
</svg>
```

### 2.2 Variant · Rejected (rote Linie + rot gefüllter Dot + Ghost-Dots + verkleinerter Diamant)

```html
<!-- Rote Progress-Linie (nur bis Rejection-Stage) -->
<line x1="36" y1="42" x2="294" y2="42" stroke="#c4474a" stroke-width="5" stroke-linecap="round" opacity="0.75"/>

<!-- Rejected-Dot (r=7 · rot · ersetzt den current-Dot) -->
<circle cx="294" cy="42" r="7" fill="#c4474a" stroke="#c4474a" stroke-width="2" data-stage-idx="3" style="cursor:pointer" onclick="prDotClick(this)"/>
<text   x="294" y="64" text-anchor="middle" font-size="9" font-weight="500" fill="var(--text-light)" font-family="DM Sans,sans-serif">Rejected</text>

<!-- Ghost-Dots danach (r=3 · sehr klein) -->
<circle cx="380" cy="42" r="3" fill="var(--bg)" stroke="var(--border-strong)" stroke-width="1.5" data-stage-idx="4"/>
<!-- … 466 / 552 / 638 analog -->

<!-- Verkleinerter Diamant (8×8 statt 14×14) -->
<rect x="720" y="38" width="8" height="8" transform="rotate(45 724 42)"
      fill="var(--bg)" stroke="var(--border-strong)" stroke-width="1.5" data-stage-idx="8">
  <title>Platzierung · Ziel-Stage (Diamant verkleinert nach Rejection)</title>
</rect>
```

### 2.3 Variant · Placed (volle grüne Linie + Diamant GOLD)

```html
<!-- Progress-Linie über gesamte Länge -->
<line x1="36" y1="42" x2="724" y2="42" stroke="url(#prg3)" stroke-width="5" stroke-linecap="round"/>
<!-- Alle Dots 0–7 grün (r=5.5 · fill=#4a8e63 · stroke=#4a8e63) -->
<!-- Placement-Diamant gold (fill="#a08749" stroke="var(--accent)") + pulsing Ring -->
<rect x="717" y="35" width="14" height="14" rx="1" transform="rotate(45 724 42)"
      fill="#a08749" stroke="var(--accent)" stroke-width="2" data-stage-idx="8"/>
<circle cx="724" cy="42" r="10" fill="none" stroke="#a08749" stroke-width="1.5" opacity="0.4">
  <animate attributeName="r" from="8" to="17" dur="2s" repeatCount="indefinite"/>
  <animate attributeName="opacity" from="0.5" to="0" dur="2s" repeatCount="indefinite"/>
</circle>
```

### 2.4 Debriefing-Dots (Auto-Injector zwischen Interview-Stages)

**Quelle:** `candidates.html` Z. 6116–6176. Fügt nach `DOMContentLoaded` automatisch lila Dots zwischen TI↔1st (x=251), 1st↔2nd (x=337), 2nd↔3rd (x=423), 3rd↔Assessment (x=509) ein.

- `fill="#8e5bb5"` (voll-lila) · beide Debriefings vorhanden (Kandidat + Account).
- `fill="#8e5bb5" opacity="0.5"` · nur eine Seite.
- `fill="var(--border-strong)" opacity="0.4"` · beidseitig fehlt.
- Jeder Dot hat `data-activity-type`-Attribut (Activity-Linking-Regel, CLAUDE.md).

### 2.5 Konstante + Klick-Handler

```javascript
const PR_STAGES = ['Expose','CV Sent','TI','1st','2nd','3rd','Assessment','Offer','Placement'];

// Compact-Mode: KEIN Stage-Wechsel-Popover.
function prDotClick(el) {
  event.stopPropagation();
  const toIdx = parseInt(el.getAttribute('data-stage-idx'));
  alert('Stage-Info: ' + PR_STAGES[toIdx]
        + '\n\nCompact-Mode zeigt nur Info. Stage-Wechsel mit Pflicht-Grund nur in Prozess-Detailmaske.');
}
```

### 2.6 Anti-Patterns

- **9-Kachel-Grid** statt SVG-Linie (`grid-template-columns:repeat(9,1fr)`) — verboten für compact-Pipeline.
- Stage-Reihenfolge ändern — fest aus `dim_process_stages` (Stammdaten §13).
- Placement als Circle statt Diamant — falsch. Placement = Rotated-Rect 14×14.
- Pulsing-Ring auf passed oder future Dots — nur auf current oder placed-Diamant.
- Text-Labels anders als `DM Sans,sans-serif font-size:9` — fest.
- Eigene Farben für passed/current/future — immer `#4a8e63` / `#a08749` / `var(--surface)+var(--border-strong)`.
- Freitext-Stage-Namen (z.B. „Interview" statt „1st") — verboten per Stammdaten-Wording-Regel.

---

## 3. Snapshot-Bar (6 Slots · sticky über Tabbar)

**Quelle:** `editorial.css` Z. 124–142, `candidates.html` Z. 690–721, `jobs.html` Z. 96–127.

**Regel:** Immer **6 Slots** (`grid-template-columns:repeat(6,1fr)`), sticky `top:0; z-index:50`, direkt UNTER `page-banner` und ÜBER `tabbar`.

```html
<div class="snapshot-bar" style="position:sticky;top:0;z-index:50">
  <div class="snapshot-item">
    <span class="lbl">⏱ Stage-Alter</span>
    <span class="val">3 d</span>
    <span class="delta">Stale-Schwelle 14 d</span>
  </div>
  <div class="snapshot-item">
    <span class="lbl">📅 Nächstes Interview</span>
    <span class="val">22.04 · 09:00</span>
    <span class="delta">2nd · vor Ort · 3 Teilnehmer</span>
  </div>
  <div class="snapshot-item">
    <span class="lbl">🎯 Win-Probability</span>
    <span class="val">55 %</span>
    <span class="delta up">2nd Interview · +20 p.p. ggü. 1st</span>
  </div>
  <div class="snapshot-item">
    <span class="lbl">💰 Pipeline-Wert</span>
    <span class="val" style="font-size:15px">CHF 25'000</span>
    <span class="delta">via Mandat · Stage 3</span>
  </div>
  <div class="snapshot-item">
    <span class="lbl">👥 CM / AM</span>
    <span class="val" style="font-size:14px"><span class="actor-chip">JV</span> / <span class="actor-chip">PW</span></span>
    <span class="delta">Jana Vogt / Peter Wiederkehr</span>
  </div>
  <div class="snapshot-item">
    <span class="lbl">🛡 Garantie</span>
    <span class="val muted" style="font-size:14px">—</span>
    <span class="delta">aktiv erst ab Placement</span>
  </div>
</div>
```

### 3.1 Slot-Struktur (fest)

- `.lbl` · 10px uppercase · Icon + Kurz-Label
- `.val` · 18px Libre Baskerville bold · gross (Font-Size reduzieren bei langen Werten auf 14–15px)
- `.delta` · 11px muted · Kontext-Info · optional `.up` (grün) / `.down` (rot)

### 3.2 Anti-Patterns

- **5 oder 7 Slots** — immer 6 (Grid ist fix).
- **KPI-Cards** statt Snapshot-Bar — KPI-Cards sind `.kpi` und kommen in `.content`, nicht sticky.
- Werte ohne Context (`.delta` fehlt) — jeder Slot braucht Delta-Zeile.
- **DB-Feldnamen** in `.lbl` (z.B. „Stage_age" statt „Stage-Alter") — verboten per CLAUDE.md §Keine-DB-Technikdetails.
- Icons weglassen — jede `.lbl` beginnt mit Emoji/Unicode-Icon.

---

## 4. Header-Row · Breadcrumb · Brand

**Quelle:** `editorial.css` Z. 51–91, `candidates.html` Z. 596–612, `processes.html` Z. 144–162.

```html
<header class="header">
  <div class="header-brand">
    <div class="logo-mark">A</div>
    <div class="brand-text">
      <div class="brand-name">ARKADIUM</div>
      <div class="brand-sub">CRM · Executive Search</div>
    </div>
  </div>
  <div class="breadcrumb">
    <a href="accounts.html">Accounts</a><span class="sep">/</span>
    <a href="accounts.html">Bauherr Muster AG</a><span class="sep">/</span>
    <a href="mandates.html">Mandat · CFO-Suche</a><span class="sep">/</span>
    <span class="current">Tobias Furrer · Stage V · 2nd</span>
  </div>
  <div class="header-right">
    <span class="cmd-hint">⌘K</span>
    <button class="theme-toggle" onclick="toggleTheme()" id="themeBtn">☀</button>
  </div>
</header>
```

**Regel:**
- Breadcrumb-Tiefe: 1 (Liste) → 2 (Entität) → 3 (Sub-Entität). Niemals > 4 Ebenen.
- `<span class="current">` nur für den letzten (aktiven) Knoten. Alle anderen sind `<a href>`.
- `cmd-hint` + `theme-toggle` fixer Bestandteil rechts — nicht weglassen.
- `.logo-mark` · Buchstabe „A" · Gold-Hintergrund · Libre Baskerville.

**Anti-Pattern:**
- Breadcrumb nur aus `<span>` — ohne Links nicht navigierbar.
- `theme-toggle` fehlt — Theme-Switch ist Pflicht.
- Custom-Logos / Icons im `.logo-mark` — immer Buchstabe „A".

---

## 5. Page-Banner (Entity-Header · Titel + Meta + Chips + Actions)

**Quelle:** `editorial.css` Z. 94–122, 954–962, `candidates.html` Z. 636–687.

```html
<div class="page-banner">
  <div class="banner-top">
    <!-- 96×96 Entity-Logo (Buchstaben-Initialen oder Foto) -->
    <div class="entity-logo">TF</div>

    <div class="banner-title">
      <h1>Tobias Furrer <span class="muted" style="font-size:14px;font-weight:400;margin-left:10px">47 J. · Zollikon ZH</span></h1>
      <div class="banner-meta">
        <span>✉ <a href="#">tobias.furrer@gmail.com</a></span>
        <span class="dot"></span><span>📞 +41 79 123 45 67</span>
        <span class="dot"></span><span>🔗 <a href="#">LinkedIn</a></span>
      </div>
      <!-- Chips-Zeile -->
      <div style="margin-top:8px;display:flex;gap:6px;flex-wrap:wrap">
        <span class="chip chip-accent">Active Sourcing</span>
        <span class="chip chip-red">🔥 Hot</span>
        <span class="chip chip-gold">Grade A</span>
      </div>
      <!-- Action-Buttons -->
      <div class="banner-actions" style="margin-top:12px">
        <button class="btn btn-sm btn-primary">📞 Anrufen</button>
        <button class="btn btn-sm">✉ Email</button>
        <button class="btn btn-sm">🔄 Stage ändern</button>
        <button class="btn btn-sm">🔔 Reminder</button>
      </div>
    </div>

    <!-- Rechts: Status-Dropdown + Context-Chips -->
    <div class="banner-chips" style="flex-direction:column;align-items:flex-end;gap:6px">
      <button class="status-dropdown">Status: Active</button>
      <span class="chip">CM <strong>JV</strong> · Hunter <strong>LR</strong></span>
    </div>
  </div>
</div>
```

**Regel:**
- `.entity-logo` · 96×96px · 36px Libre Baskerville · 2-Buchstaben-Initialen (Kürzel aus Stammdaten §Mitarbeiter).
- `.banner-meta` · 12.5px · Dots (3×3 Kreis) zwischen Einträgen.
- `.banner-actions` · `.btn-sm` · immer `btn-primary` für Hauptaktion (meist „Anrufen" / „Email").
- `.status-dropdown` · rechts · einzige Farbvariante grün (active) / `chip-red` (blacklisted) / `chip-amber` (prospect).

**Anti-Pattern:**
- `.entity-logo` weglassen (selbst wenn kein Foto vorhanden — dann Initialen).
- Status-Pills links im Titel statt rechts im `banner-chips`.
- Mehr als 4 Action-Buttons — Sekundär-Actions in Drawer oder Tab verschieben.

---

## 6. Tab-Navigation (sticky unter Snapshot-Bar)

**Quelle:** `editorial.css` Z. 996–1015, `candidates.html` Z. 723–734.

```html
<nav class="tabbar" style="position:sticky;top:64px;z-index:49">
  <div class="tab active" data-tab="1" onclick="switchTab(1)"><span class="num">1</span>Übersicht</div>
  <div class="tab" data-tab="2" onclick="switchTab(2)"><span class="num">2</span>Briefing</div>
  <div class="tab" data-tab="3" onclick="switchTab(3)"><span class="num">3</span>Werdegang</div>
  <!-- … bis max. 10 Tabs. Tab 10 hat num="0" für Keyboard-Shortcut '0' -->
  <div class="tab" data-tab="10" onclick="switchTab(10)"><span class="num">0</span>Reminders</div>
</nav>
```

**Content-Panels:**

```html
<div class="content">
  <div id="tab-1" class="tab-panel active">…</div>
  <div id="tab-2" class="tab-panel">…</div>
  <!-- etc. -->
</div>
```

**Regel:**
- `.tab` active-Zustand: `color:var(--accent); border-bottom-color:var(--gold)`.
- `.num` zeigt Tab-Nummer (monospace) — Keyboard-Shortcuts `1`–`9`, `0` = Tab 10.
- Conditional Tab (z.B. „Garantie"): zusätzliche Klasse `conditional` → gold-soft-Hintergrund.
- Badges: `<span class="badge">3</span>` optional nach Label.

**Anti-Pattern:**
- Mehr als 10 Tabs pro Detailseite — aufsplitten in Sub-Tabs oder separate Seiten.
- `.num` weglassen — Keyboard-Shortcuts brechen.
- Tab-Switch per Link statt `onclick="switchTab(N)"` — JS-State bricht.

---

## 7. Card-Header (Standard-Pattern)

**Quelle:** `editorial.css` Z. 1056–1074.

```html
<div class="card">
  <div class="card-head">
    <div class="card-title">📋 Stammdaten</div>
    <span class="spacer"></span>
    <a href="#" class="card-link" onclick="event.stopPropagation();enterEdit(this)">Bearbeiten</a>
  </div>
  <!-- Card-Body: field-grid / list / table / drawer-triggering rows -->
  <dl class="field-grid">
    <dt>Vorname</dt><dd>Tobias</dd>
    <dt>Nachname</dt><dd>Furrer</dd>
    <dt>Geburtsdatum</dt><dd>15.03.1978</dd>
  </dl>
</div>
```

### 7.1 Collapsible Card

```html
<div class="card collapsible">
  <div class="card-head" onclick="toggleCollapse(this)">
    <div class="card-title">🎓 Weiterbildungen</div>
    <span class="card-link">3 Einträge</span>
  </div>
  <!-- Body wird ein-/ausgeblendet -->
</div>
```

### 7.2 AI-Draft Card (gold-gerahmt)

```html
<div class="card ai-draft">
  <!-- ::before pseudo renders 'AI DRAFT'-Badge -->
  <div class="card-head"><div class="card-title">Briefing-Zusammenfassung</div></div>
  <div class="ai-confirm-bar">
    <span>Vorschlag aus Anruf generiert. Prüfen und bestätigen.</span>
    <span class="spacer"></span>
    <button class="btn btn-sm btn-primary">✓ Übernehmen</button>
    <button class="btn btn-sm">Verwerfen</button>
  </div>
</div>
```

**Anti-Pattern:**
- `.card-title` mit 15px+ → Design-System fix 15px Libre Baskerville.
- Actions direkt im Body ohne `.card-head` → Edit-Link gehört in Card-Head.
- `.card-head` ohne unteres Border → Trenner zum Body ist Pflicht.

---

## 8. Activity-Timeline (History-Tab)

**Quelle:** `editorial.css` Z. 1350–1392, `candidates.html` Z. 3094–3160.

```html
<div class="card" style="padding:24px 28px">
  <div class="hist-timeline">

    <div class="hist-day">
      <div class="hist-day-head">Heute · 14.04.2026</div>

      <div class="hist-row">
        <div class="hist-time">14:22</div>
        <div class="hist-cat"><span class="hist-cat-chip cat-erreicht">Erreicht</span></div>
        <div class="hist-body">
          <div class="hist-title"><strong>Update-Call · Hans Müller (CEO)</strong> <span class="muted" style="font-weight:400">— 42 min</span></div>
          <div class="hist-sub">CFO-Mandat Update: M. Gerber hat eher Schweiz-Affinität. Prio auf Gerber + Furrer fokussieren.</div>
          <div class="hist-meta"><span class="actor">PW</span> · <a href="#">Kontakt · H. Müller</a> · <a href="#">Mandat · CFO-Suche</a></div>
        </div>
      </div>

      <div class="hist-row">
        <div class="hist-time">09:45</div>
        <div class="hist-cat"><span class="hist-cat-chip cat-email">Emailverkehr</span></div>
        <div class="hist-body">
          <div class="hist-title"><strong>E-Mail erhalten · Eva Studer (HR-L)</strong></div>
          <div class="hist-sub">Rückmeldung zu CV T. Furrer: 1st Interview bestätigt.</div>
          <div class="hist-meta"><span class="actor">JV</span> · <a href="#">Kontakt · E. Studer</a></div>
        </div>
      </div>
    </div>

    <div class="hist-day">
      <div class="hist-day-head">Gestern · 13.04.2026</div>
      <!-- weitere hist-row … -->
    </div>
  </div>
</div>
```

### 8.1 Category-Chips (feste Stammdaten §14)

| Klasse | Kategorie (Stammdaten) | Farbe |
|---|---|---|
| `cat-kontakt` | Kontaktberührung | Blau |
| `cat-erreicht` | Erreicht | Grün |
| `cat-email` | Emailverkehr | Accent |
| `cat-messaging` | Messaging | Purple |
| `cat-interview` | Interviewprozess | Accent |
| `cat-placement` | Placementprozess | Gold |
| `cat-refresh` | Refresh Kandidatenpflege | Grau |
| `cat-mandat` | Mandatsakquise | Gold |
| `cat-erfolgsbasis` | Erfolgsbasis | Grau dashed |
| `cat-assessment` | Assessment | Purple |
| `cat-system` | System | Grau |

**Regel:**
- Grid: `60px 130px 1fr` (Time / Category-Chip / Body).
- `.hist-warn` (rot-Akzent) für Eskalations-Events; `.hist-ok` (gold-Akzent) für Placements.
- `<span class="actor">XX</span>` · 2-Buchstaben-Kürzel (`PW`, `JV`, `LR`) — niemals „Peter Wiederkehr" ausgeschrieben.
- Jede Row führt zu `fact_history`-Event (Activity-Linking-Regel) — Body-Click öffnet History-Drawer.

**Anti-Pattern:**
- Freitext-Kategorien („Call" statt „Erreicht") — fest aus §14.
- Mitarbeiter-Vollnamen statt Kürzel — CLAUDE.md §Stammdaten-Wording.
- Gruppierung ohne `.hist-day-head` — Days sind Pflicht (sortiert DESC).

---

## 9. Post-Placement-Garantie-Widget (3-Mt/Onboarding/Placement/Check-Dots)

**Quelle:** `candidates.html` Z. 2931–2983.

```html
<!-- Nur sichtbar wenn Status=Placed · innerhalb Prozess-Card -->
<div style="padding:12px 14px;background:var(--gold-soft);border:1px solid var(--gold);border-radius:3px;margin-top:10px">
  <div style="display:flex;align-items:center;gap:8px;font-size:12px;color:var(--gold);font-weight:700;margin-bottom:10px">
    🎉 Post-Placement · Garantie-Tracking
  </div>
  <svg class="pr-pipeline-svg" viewBox="0 0 760 110" xmlns="http://www.w3.org/2000/svg" style="min-height:110px">
    <defs>
      <linearGradient id="ppg" x1="0%" y1="0%" x2="100%" y2="0%">
        <stop offset="0%" stop-color="#a08749"/>
        <stop offset="100%" stop-color="#4a8e63"/>
      </linearGradient>
    </defs>
    <line x1="36" y1="54" x2="724" y2="54" stroke="#e8e4d8" stroke-width="5" stroke-linecap="round"/>
    <line x1="36" y1="54" x2="724" y2="54" stroke="url(#ppg)" stroke-width="5" stroke-linecap="round"/>

    <!-- 1: Onboarding-Call (r=7 · data-activity-type) -->
    <circle cx="36" cy="54" r="7" fill="#4a8e63" stroke="#4a8e63" stroke-width="2"
            data-activity-type="checkin_onboarding" style="cursor:pointer"
            onclick="alert('Onboarding-Call · History-Event öffnen')">
      <title>Onboarding-Call · Start −7 d</title>
    </circle>
    <text x="36" y="32" text-anchor="middle" font-size="9" font-weight="600" fill="#4a8e63" font-family="DM Sans,sans-serif">ONBOARDING ✓</text>
    <text x="36" y="76" text-anchor="middle" font-size="8.5" fill="var(--text-mid)" font-family="DM Sans,sans-serif">07.08.2024</text>

    <!-- 2: Placement (Diamant gold) -->
    <rect x="201" y="47" width="14" height="14" rx="1" transform="rotate(45 208 54)"
          fill="#a08749" stroke="var(--accent)" stroke-width="2"/>
    <text x="208" y="32" text-anchor="middle" font-size="9" font-weight="700" fill="#a08749" font-family="DM Sans,sans-serif">PLACEMENT ✓</text>
    <text x="208" y="76" text-anchor="middle" font-size="8.5" fill="var(--text-mid)" font-family="DM Sans,sans-serif">14.08.2024</text>

    <!-- 3: 1-Mt-Check -->
    <circle cx="380" cy="54" r="7" fill="#4a8e63" stroke="#4a8e63" stroke-width="2"
            data-activity-type="checkin_1m" style="cursor:pointer">
      <title>1-Monats-Check</title>
    </circle>
    <text x="380" y="32" text-anchor="middle" font-size="9" font-weight="600" fill="#4a8e63" font-family="DM Sans,sans-serif">1-MT-CHECK ✓</text>

    <!-- 4: 2-Mt-Check (analog) -->
    <circle cx="552" cy="54" r="7" fill="#4a8e63" stroke="#4a8e63" stroke-width="2" data-activity-type="checkin_2m"/>
    <text x="552" y="32" text-anchor="middle" font-size="9" font-weight="600" fill="#4a8e63" font-family="DM Sans,sans-serif">2-MT-CHECK ✓</text>

    <!-- 5: 3-Mt-Check = Garantie-Ende (Gold-Ring) -->
    <circle cx="724" cy="54" r="7.5" fill="#4a8e63" stroke="var(--gold)" stroke-width="2" data-activity-type="checkin_3m"/>
    <text x="724" y="32" text-anchor="middle" font-size="9" font-weight="700" fill="var(--gold)" font-family="DM Sans,sans-serif">3-MT · GARANTIE-ENDE ✓</text>
  </svg>

  <!-- 4-Spalten-KPI-Strip unter der Pipeline -->
  <div style="display:grid;grid-template-columns:repeat(4,1fr);gap:8px;margin-top:10px;font-size:11px">
    <div style="padding:6px 8px;background:var(--surface);border-radius:2px">
      <div class="muted" style="font-size:10px">Tage seit Placement</div>
      <strong style="font-family:'Libre Baskerville',serif;color:var(--gold)">608 T</strong>
    </div>
    <div style="padding:6px 8px;background:var(--surface);border-radius:2px">
      <div class="muted" style="font-size:10px">Garantiefrist (3 Mt)</div>
      <strong style="color:var(--green)">✓ erfolgreich durch</strong>
    </div>
    <div style="padding:6px 8px;background:var(--surface);border-radius:2px">
      <div class="muted" style="font-size:10px">Fee gebucht</div>
      <strong style="font-family:'Libre Baskerville',serif;color:var(--gold)">CHF 45k</strong>
    </div>
    <div style="padding:6px 8px;background:var(--surface);border-radius:2px">
      <div class="muted" style="font-size:10px">Prozess-Status</div>
      <strong style="color:var(--text-mid)">Closed</strong>
    </div>
  </div>

  <!-- Abgrenzungs-Hinweis (Pflicht wegen Schutzfrist-Regel) -->
  <div class="muted" style="font-size:10px;margin-top:10px;padding-top:8px;border-top:1px dashed var(--border);line-height:1.55">
    <strong>Post-Placement-Tracking nur 1./2./3. Monat</strong> — deckungsgleich mit Garantiefrist (AGB §5).
    <br>
    <strong>Direkteinstellungs-Schutzfrist</strong> (AGB §6, 12/16 Mt) ist getrennt und greift <em>nur bei NICHT-Placement</em>.
  </div>
</div>
```

**Regel (CLAUDE.md §Schutzfrist-Regel):** In diesem Widget NIE die 12-Mt-Schutzfrist darstellen — separate Ansicht in Account-Tab „Schutzfristen".

**Anti-Pattern:**
- 6-Mt oder 12-Mt-Check-Dots ergänzen — Garantiefrist ist fix 3 Mt (AGB §5).
- Schutzfrist + Garantie gemischt darstellen — zwei unabhängige Mechaniken.
- Check-Dots ohne `data-activity-type` — Activity-Linking-Regel verletzt.

---

## 10. Stage-Popover (Skip/Back + Pflicht-Grund · Detailed-Mode)

**Quelle:** `processes.html` Z. 82–139 (CSS), Z. 412–442 (HTML), Z. 2655+ (JS).

**Regel:** Nur im **Detailed-Mode** (processes.html). In compact-Pipeline-Cards → `prDotClick` zeigt nur Info-Alert.

```html
<!-- Backdrop + Popover (1× pro Seite) -->
<div id="arkPlPopBackdrop" class="ark-pl-pop-backdrop" onclick="closeStagePopover()"></div>
<div id="arkPlStagePopover" class="ark-pl-pop" role="dialog" aria-modal="true" aria-labelledby="arkPlPopTitle">
  <div class="ark-pl-pop-head">
    <span class="ark-pl-pop-title" id="arkPlPopTitle">Stage-Wechsel</span>
    <span class="spacer"></span>
    <button class="btn btn-sm" style="padding:2px 8px;font-size:10px" onclick="closeStagePopover()">✕</button>
  </div>
  <div class="ark-pl-pop-body">
    <div id="arkPlPopContent">
      <!-- dynamisch: z.B. Warn-Banner bei Skip -->
      <div class="ark-pl-pop-warn amber">
        <strong>Skip-Warnung:</strong> Stage „TI" wird übersprungen. Grund erforderlich.
      </div>
    </div>
    <div class="ark-pl-pop-field">
      <label>Datum</label>
      <div>
        <input type="date" id="arkPlPopDate">
        <div class="muted" style="font-size:10px;margin-top:2px">Nativ — Picker oder Tastatur-Eingabe (TT.MM.JJJJ)</div>
      </div>
    </div>
    <div class="ark-pl-pop-field">
      <label>Grund <span style="color:var(--red)">*</span></label>
      <div>
        <textarea id="arkPlPopReason" placeholder="Mind. 10 Zeichen — z.B. 'HM positiv, Kandidat zu 2nd eingeladen'" oninput="onStagePopoverReasonInput(this)"></textarea>
        <div class="ark-pl-pop-counter" id="arkPlPopCounter">0 / 10 Zeichen min</div>
      </div>
    </div>
  </div>
  <div class="ark-pl-pop-foot">
    <button class="btn btn-sm" onclick="closeStagePopover()">Abbrechen</button>
    <span class="spacer"></span>
    <button class="btn btn-sm btn-primary" id="arkPlPopSubmit" disabled onclick="submitStagePopover()">✓ Stage wechseln</button>
  </div>
</div>
```

### 10.1 Kritisches CSS

```css
.ark-pl-pop { position:absolute; z-index:150;
  background:var(--surface); border:1px solid var(--border); border-radius:4px;
  box-shadow:var(--shadow); min-width:380px; max-width:440px;
  padding:14px; display:none; }
.ark-pl-pop.open { display:block; }
.ark-pl-pop-warn { padding:8px 10px; border-radius:3px; margin:0 0 10px; font-size:11.5px; line-height:1.5; }
.ark-pl-pop-warn.amber  { background:color-mix(in srgb,var(--amber) 10%,var(--surface)); border-left:3px solid var(--amber); }
.ark-pl-pop-warn.red    { background:color-mix(in srgb,var(--red) 8%,var(--surface));    border-left:3px solid var(--red); }
.ark-pl-pop-warn.accent { background:color-mix(in srgb,var(--accent) 6%,var(--surface)); border-left:3px solid var(--accent); }
.ark-pl-pop textarea { width:100%; min-height:70px; padding:6px 8px; font-size:12px;
  border:1px solid var(--border); border-radius:2px; resize:vertical; font-family:inherit; }
```

### 10.2 Regeln

- Pflicht-Grund: min. 10 Zeichen (Counter valid → grün + Submit enabled).
- `<input type="date">` nativ (Kalender-Picker UND Keyboard per CLAUDE.md §Datum-Eingabe-Regel).
- Warn-Varianten: `amber` (Skip) · `red` (Rejection) · `accent` (Info) · `green` (OK).
- Positionierung: `position:absolute` · JS setzt `left/top` neben dem angeklickten Dot.

**Anti-Pattern:**
- Stage-Popover in candidates.html/compact-Mode verwenden — nur in Detail-Mode.
- `confirm()` oder `prompt()` statt strukturiertem Popover — durch diese Komponente ersetzt.
- Grund-Textarea ohne Zeichen-Counter oder < 10 Zeichen min.

---

## 11. Refund-Card (Early-Exit · 3-Pfad-Router)

**Quelle:** `processes.html` Z. 1114–1194.

**Routing (CLAUDE.md §project_refund_model_routing):** Bei Early-Exit route je nach `business_model`:
- **Erfolgsbasis** → Staffel (100/50/25/10/0 %)
- **Mandat** (Target/Taskforce) → Ersatzbesetzung
- **Time** → keine Rückvergütung

```html
<div class="card" id="refundCard" style="display:none;border-left:3px solid var(--red)">
  <div class="card-head">
    <div class="card-title">🚪 Early-Exit · <span id="refundCardModelTitle">Rückvergütung</span></div>
    <span class="chip chip-red" style="font-size:10px">aktiv · Austritt 15.07.2026</span>
  </div>

  <!-- Modell-Banner (dynamisch je nach business_model) -->
  <div id="refundCardBanner" style="padding:12px 14px;background:color-mix(in srgb,var(--red) 5%,var(--surface));border-left:3px solid var(--red);border-radius:3px;font-size:12px;margin-bottom:14px">
    <strong>Kandidat ist vor Garantiefrist-Ende ausgetreten.</strong> Rückvergütungs-Berechnung basierend auf Austritts-Monat.
  </div>

  <!-- Gemeinsame Austritts-Daten (alle Modelle) -->
  <dl class="field-grid">
    <dt>Arbeitsantritt</dt><dd>01.06.2026</dd>
    <dt>Austritts-Datum</dt><dd>15.07.2026</dd>
    <dt>Austritts-Monat</dt><dd><strong>Monat 2</strong> (innerhalb Garantiefrist)</dd>
    <dt>Fault-Side</dt><dd>
      <select>
        <option>Kandidat (Default)</option>
        <option>Kunde (Ausnahme · keine Rückvergütung)</option>
        <option>Unklar (Admin-Entscheidung)</option>
      </select>
    </dd>
  </dl>

  <!-- Path A · Erfolgsbasis · Staffel -->
  <div id="refundCardPathErfolgsbasis">
    <div class="card-head" style="margin-top:14px"><div class="card-title">Rückvergütungs-Staffel (Erfolgsbasis · AGB §5)</div></div>
    <table class="data-table">
      <thead><tr><th>Austritts-Zeitpunkt</th><th class="right">Rückvergütung</th><th>Aktueller Fall</th></tr></thead>
      <tbody>
        <tr><td>Stelle nicht angetreten</td><td class="right">100 %</td><td class="muted">—</td></tr>
        <tr><td>Austritt Monat 1</td><td class="right">50 %</td><td class="muted">—</td></tr>
        <tr style="background:color-mix(in srgb,var(--red) 5%,var(--surface));font-weight:600">
          <td>Austritt Monat 2</td><td class="right">25 %</td>
          <td><span class="chip chip-red" style="font-size:10px">✓ trifft zu</span></td>
        </tr>
        <tr><td>Austritt Monat 3</td><td class="right">10 %</td><td class="muted">—</td></tr>
        <tr><td>Nach Probezeit</td><td class="right">0 %</td><td class="muted">—</td></tr>
      </tbody>
    </table>
    <dl class="field-grid" style="margin-top:14px">
      <dt>Rückvergütung netto</dt>
      <dd><strong style="font-family:'Libre Baskerville',serif;font-size:16px;color:var(--red)">CHF 6'250</strong>
          <span class="muted" style="font-size:11px">· 25 % × CHF 25'000</span></dd>
      <dt>MwSt 8.1 %</dt><dd>CHF 506</dd>
      <dt>Rückvergütung brutto</dt><dd><strong>CHF 6'756</strong></dd>
      <dt>Aktion</dt>
      <dd><button class="btn btn-sm btn-primary" onclick="openDrawer('refundDrawer',0)">📄 Rückvergütungs-Gutschrift erstellen</button></dd>
    </dl>
  </div>

  <!-- Path B · Mandat · Ersatzbesetzung (display:none default) -->
  <div id="refundCardPathMandat" style="display:none">
    <div class="card-head" style="margin-top:14px"><div class="card-title">Ersatzbesetzung (Mandat · Target/Taskforce · AGB §5.2)</div></div>
    <div style="padding:12px 14px;background:color-mix(in srgb,var(--gold) 5%,var(--surface));border-left:3px solid var(--gold);border-radius:3px;font-size:12px;margin-bottom:12px">
      <strong>Keine Geld-Rückzahlung.</strong> Arkadium startet neue Suche — Ersatzbesetzung geschuldet.
    </div>
    <!-- Felder · analog -->
  </div>

  <!-- Path C · Time · keine Rückvergütung (display:none default) -->
  <div id="refundCardPathTime" style="display:none">
    <div class="card-head" style="margin-top:14px"><div class="card-title">Time-Mandat · Beendigung</div></div>
    <div style="padding:12px 14px;background:color-mix(in srgb,var(--accent) 5%,var(--surface));border-left:3px solid var(--accent);border-radius:3px;font-size:12px;margin-bottom:12px">
      <strong>Keine Rückvergütung, keine Ersatzbesetzung.</strong> Monatshonorar läuft zeitanteilig bis Austritt.
    </div>
  </div>
</div>
```

**Regel:**
- Nur 1 Pfad sichtbar zur Zeit (`display:none` für 2 von 3).
- `border-left:3px solid var(--red)` am Outer-Card = Early-Exit-Indikator.
- CTA immer Drawer-Trigger (nicht Modal): `openDrawer('refundDrawer',0)`.

**Anti-Pattern:**
- Alle 3 Pfade gleichzeitig rendern — JS wählt `business_model`-basierten Pfad.
- Rückvergütung bei Time oder Mandat anzeigen — falsche Routing-Entscheidung.

---

## 12. Pipeline-Bar · Compact (horizontale Prozess-Liste, Kanban-Style)

**Quelle:** `jobs.html` Z. 696–755, `mandates.html` (analog).

```html
<div id="proc-view-pipe" style="display:block">
  <div class="proc-pipeline" style="display:grid;grid-template-columns:repeat(9,minmax(180px,1fr));gap:10px;overflow-x:auto;padding-bottom:8px">

    <div class="proc-col">
      <div class="proc-col-head">
        <span class="st-label">I · Expose</span>
        <span class="count">5 <span class="muted" style="font-size:10px">(4 M · 1 EB)</span></span>
      </div>
      <div class="proc-card" onclick="openDrawer('procDrawer',0)">
        <div class="pc-top"><strong>Tobias Furrer</strong><span class="temp-dot" title="Hot"></span></div>
        <div class="pc-sub"><span class="chip chip-accent">CFO-Suche</span></div>
        <div class="pc-meta muted">seit 6 d · JV</div>
      </div>
      <!-- weitere Cards -->
    </div>

    <div class="proc-col">
      <div class="proc-col-head"><span class="st-label">II · CV Sent</span><span class="count">3</span></div>
      <div class="proc-card stale">
        <div class="pc-top">
          <strong>Andrea Koller</strong>
          <span class="temp-dot warm"></span>
          <span class="chip chip-red" style="margin-left:auto;font-size:9px">STALE</span>
        </div>
        <div class="pc-sub"><span class="chip chip-accent">CFO-Suche</span></div>
        <div class="pc-meta" style="color:var(--red)">18 d ohne Bewegung</div>
      </div>
    </div>

    <!-- III · TI / IV · 1st / V · 2nd / VI · 3rd / VII · Assessment / VIII · Offer / IX · Placement -->
  </div>
</div>
```

**Regel:**
- **Immer 9 Spalten** (auch wenn leer — Placeholder anzeigen).
- `minmax(180px,1fr)` · horizontales Scrollen bei schmalen Viewports.
- `.temp-dot` (hot/warm/cold/dead) als Status-Indikator.
- `.proc-card.stale` + `.chip.chip-red` bei > 14 d ohne Bewegung.
- Click auf Card → Drawer mit Prozess-Detail (NICHT Vollseiten-Navigation in dieser Ansicht).

**Anti-Pattern:**
- Stage-Spalten zusammenfassen („Interviews" statt 1st/2nd/3rd) — Stammdaten-Verletzung.
- Cards ohne `.temp-dot` oder Stage-Label — minimum: Name + Chip + Meta.
- Vollseiten-Navigation auf Card-Click → Drawer, damit Liste erhalten bleibt.

---

## 13. Drawer-Form-Pattern (CRUD · label + input · field-grid)

**Quelle:** `editorial.css` Z. 1076–1080, `candidates.html` Z. 4815–4848.

```html
<div class="drawer-body">
  <div class="drawer-section">
    <h4>Pflichtfelder</h4>
    <dl class="field-grid">
      <dt>Name <span style="color:var(--red)">*</span></dt>
      <dd><input type="text" placeholder="Max Muster" style="width:100%"></dd>

      <dt>E-Mail <span style="color:var(--red)">*</span></dt>
      <dd><input type="email" placeholder="max@example.com" style="width:100%"></dd>

      <dt>Geburtsdatum</dt>
      <dd><input type="date" style="width:160px"></dd>

      <dt>Sparte</dt>
      <dd>
        <div class="toggle-group">
          <div class="toggle-tag" onclick="toggleTag(this)" data-code="ARC">ARC</div>
          <div class="toggle-tag active" onclick="toggleTag(this)" data-code="GT">GT</div>
          <div class="toggle-tag" onclick="toggleTag(this)" data-code="ING">ING</div>
          <div class="toggle-tag" onclick="toggleTag(this)" data-code="PUR">PUR</div>
          <div class="toggle-tag" onclick="toggleTag(this)" data-code="REM">REM</div>
        </div>
      </dd>

      <dt>Notiz</dt>
      <dd><textarea rows="3" style="width:100%" placeholder="Optional …"></textarea></dd>
    </dl>
  </div>
</div>
```

### 13.1 Input-Typ-Tabelle

| Use-Case | Input-Type | Hinweis |
|---|---|---|
| Datum | `<input type="date">` | CLAUDE.md §Datum-Regel: nativ (Picker + Tastatur) |
| Zeit | `<input type="time">` | analog |
| Zeitstempel | `<input type="datetime-local">` | analog |
| Monat | `<input type="month">` | z.B. Werdegang-Station |
| E-Mail | `<input type="email">` | Validierung browser-nativ |
| Telefon | `<input type="tel">` | keine Masken ohne Request |
| URL | `<input type="url">` | LinkedIn etc. |
| Suche | `<input type="search">` | Account/Kandidat-Picker |
| Mehrwertauswahl | `.toggle-group` + `.toggle-tag` | aus Stammdaten-Katalog |
| Dropdown | `<select>` | nur wenn < 20 Optionen; darüber: Suche |

### 13.2 Regeln

- `.field-grid` ist 2-spaltig (`max-content 1fr`). Pflichtfeld-Stern rot.
- **Niemals** `<input type="text">` für Datum-Felder — nur nativer Typ.
- **Niemals** Click-only Kalender-Picker (z.B. flatpickr ohne Keyboard) — Datum-Regel verletzt.
- Sparten/Enums: nur aus Stammdaten-Katalog (§Stammdaten-Wording-Regel).
- Drawer-Foot: `Abbrechen` links · Spacer · `Speichern` rechts (Primary).

**Anti-Pattern:**
- Save-Button im Body statt Foot — Foot ist Pflicht.
- Textarea ohne `rows` — Browser-Default ist zu hoch.
- Mehrere Save-Buttons — immer genau 1 Primary (`btn-primary`) pro Drawer-Foot.

---

## 14. Quick-Reference · Rendering-Reihenfolge einer Detailseite

```
<header class="header">              ← Brand + Breadcrumb + Theme-Toggle
<div class="page-banner">            ← Entity-Logo + Titel + Meta + Chips + Actions
<div class="snapshot-bar">           ← 6 Slot sticky top:0 z:50
<nav class="tabbar">                 ← sticky top:64px z:49
<div class="content">
  <div id="tab-1" class="tab-panel active">
    <div class="card">               ← card-head + body
      <dl class="field-grid">        ← label + value (oder field-grid als Form in Drawer)
  <div id="tab-6">                   ← Prozesse (ggf. mit Stage-Pipeline-SVG)
    <div class="pr-card">
      <svg class="pr-pipeline-svg">  ← 9 Dots + optional Garantie-Widget
  <div id="tab-7">                   ← History (hist-timeline)
<div class="drawer-backdrop">        ← 1× global
<div class="drawer" id="…">          ← n× pro Seite
<div id="arkPlStagePopover">         ← nur bei Detail-Mode-Processes
<script src="_shared/layout.js">
```

## 15. Häufige Drift-Fallen (aus Mockup-Review 2026-04-17)

| Drift | Korrektur |
|---|---|
| `.drawer` mit `width:600px` oder `500px` | 540px (Standard) oder 760px (`drawer-wide`) |
| Stage-Pipeline als 9-Kachel-Grid | SVG-Linie mit Dots · viewBox 760×86 |
| Placement als Circle statt Diamant | Rotated-Rect 14×14 · `rotate(45 724 42)` |
| Snapshot-Bar mit 4 oder 5 Slots | exakt 6 (grid-template-columns:repeat(6,1fr)) |
| Custom Category-Chip-Farbe in Timeline | Aus fester 11-Eintrag-Klassen-Liste `cat-*` |
| „Peter Wiederkehr" ausgeschrieben | `<span class="actor-chip">PW</span>` |
| Status-Name „Interview 1" statt „1st" | Stage-Namen fest aus §13 Stammdaten |
| Modal für „Profil bearbeiten" | Drawer (CRUD = Drawer per CLAUDE.md) |
| `<input>` ohne `type="date"` für Datum | Nativ (Datum-Regel) |
| DB-Feldname sichtbar (`stage_age`, `fact_history_id`) | Sprechende UI-Begriffe |
| Pipeline-Widget ohne Schutzfrist-Abgrenzung | Hinweis „Post-Placement ≠ Schutzfrist" Pflicht |

---

## 16. UI-Label-Vocabulary · Canonical Mappings

**Kontext:** 2026-04-17 — 110 DB-Tech-Violations + Spec-Drift über alle 18 Mockups gefixt. Damit künftige Mockups konsistent bleiben, hier das kanonische Label-Mapping. **Immer diese Labels verwenden**, keine neuen Synonyme erfinden.

**Quelle-Priorität:**
1. `Grundlagen MD/ARK_STAMMDATEN_EXPORT_v1_3.md` (kanonisch für Enum-Labels)
2. Diese Tabelle (abgeleitet/ergänzt für Event-Types)
3. Bei Neuem: erst hier nachsehen, dann in Stammdaten nachtragen wenn dort fehlt.

### 16.1 Stammdaten-kanonisch — §10c Vorstellungs-Typ (`dim_presentation_types`)

| Enum-Key | UI-Label (KANONISCH) |
|----------|---------------------|
| `email_dossier` | **Dossier per E-Mail** |
| `verbal_meeting` | **Mündlich im Meeting mit Dossier-Share** (Kurz: „Mündlich im Meeting") |
| `upload_portal` | **Upload Kundenportal** |

### 16.2 Schutzfrist- / Claim-Status-Lifecycle

| Enum-Key | UI-Label |
|----------|---------|
| `active` | **Aktiv** |
| `honored` | **Erfüllt** |
| `paid` | **Bezahlt** |
| `expired` | **Abgelaufen** |
| `claim_pending` | **Claim ausstehend** |

### 16.3 Prozess-Lifecycle Events

| Event-Key | UI-Label |
|-----------|---------|
| `process_created` | **Prozess erstellt** |
| `stage_changed` | **Stage geändert** |
| `status_changed` | **Status geändert** |
| `stage_rollback` | **Stage-Rollback** |

### 16.4 Job-Lifecycle Events

| Event-Key | UI-Label |
|-----------|---------|
| `scraper_proposal` / `scraper_proposal_created` | **Scraper-Vorschlag** / **Scraper-Vorschlag erstellt** |
| `vakanz_confirmed` | **Vakanz bestätigt** |
| `matching_computed` | **Matching berechnet** |
| `jobbasket_candidate_added` / `jobbasket_added` | **Job in Jobbasket aufgenommen** (der Job landet im Jobbasket des Kandidaten, nicht umgekehrt) |
| `job_ad_generated` | **Stellenausschreibung generiert** |

### 16.5 Projekt-Lifecycle Events

| Event-Key | UI-Label |
|-----------|---------|
| `project_created_manual` | **Projekt erstellt (manuell)** |
| `project_created_werdegang` | **Projekt erstellt (Werdegang)** |
| `project_created_scraper` | **Projekt erstellt (Scraper)** |
| `bauherr_changed` | **Bauherr geändert** |
| `classification_changed` | **Klassifikation geändert** |
| `bkp_gewerk_added` / `bkp_gewerk_removed` | **BKP-Gewerk hinzugefügt/entfernt** |
| `company_participation_added/changed/removed` | **Firma-Beteiligung hinzugefügt/geändert/entfernt** |
| `candidate_participation_added/changed/removed` | **Kandidat-Beteiligung hinzugefügt/geändert/entfernt** |
| `media_uploaded` | **Medien hochgeladen** |
| `document_uploaded` | **Dokument hochgeladen** |
| `internal_notes_updated` | **Interne Notizen aktualisiert** |
| `account_project_note_added/updated` | **Account-Projekt-Notiz hinzugefügt/aktualisiert** |

### 16.6 Gruppen-Events (Firmengruppe)

| Event-Key | UI-Label |
|-----------|---------|
| `group_culture_generated` | **Gruppen-Kultur generiert** |
| `group_mandate_created` | **Gruppen-Mandat erstellt** |
| `group_framework_contract_added` | **Rahmenvertrag verlängert** |
| `group_document_uploaded` | **Gruppen-Dokument hochgeladen** |

### 16.7 Account- / Claim-Events

| Event-Key | UI-Label |
|-----------|---------|
| `account_scraper_confirmed` | **Account-Scraper bestätigt** |
| `claim_invoiced` | **Claim verrechnet** |
| `claim_context_determined` | **Claim-Kontext bestimmt** |

### 16.8 Kandidat-Scraper-Events

| Event-Key | UI-Label |
|-----------|---------|
| `candidate_scraper_werdegang_update` | **Kandidat-Scraper-Werdegang-Update** |

### 16.9 DB-Referenzen → sprechend (in User-UI)

**Regel:** Niemals `dim_*`/`fact_*`/`bridge_*` direkt zeigen. Immer diese Labels.

| Technisch | UI-Label |
|-----------|---------|
| `dim_accounts` | **Account-Stammdaten** |
| `dim_functions` | **Funktions-Katalog** |
| `dim_sector` | **Sektor-Katalog** |
| `dim_process_stages` | **Stage-Stammdaten** / **Stammdaten-Katalog** |
| `dim_activity_types` | **Activity-Types-Katalog** |
| `dim_education_level` | *(Label entfernen — nur „Bildungsgrad*")* |
| `dim_rejection_reasons_*` | **Ablehnungsgrund-Katalog** |
| `dim_reminder_templates` | **Reminder-Template-Katalog** |
| `dim_honorar_settings` | **Honorar-Staffel-Stammdaten** |
| `dim_mitarbeiter.commission_*_pct` | **Mitarbeiter-Commission-Stammdaten** |
| `dim_matching_weights_project` | **Projekt-Matching-Overlay** |
| `dim_matching_weights` | **Base-Gewichten** |
| `dim_sia_phases` | **SIA 112 · 18 Phasen (6 Haupt + 12 Teil)** |
| `dim_bkp_codes` | **SN-Katalog** / **BKP-Codes (SN-Katalog)** |
| `dim_accounts_org_chart` | **Account-Organigramm** |
| `fact_history` | **History-Event** |
| `fact_project_similarities` | **Projekt-Ähnlichkeits-Index** |
| `fact_process_events` | **Prozess-Verlauf** |
| `fact_process_interviews.actual_date` | **Interview-Datum** |
| `fact_interview.outlook_event_id` | **Outlook-Event-ID** |
| `fact_process_core` (Saga-Admin-Kontext) | *belassen · Admin-Exception · in `<!-- ark-lint-skip:begin -->` einwickeln* |
| `bridge_mandate_accounts` | *umschreiben: „Mandat → mehrere Gesellschaften"* |
| `audit-log-retention` / `audit_log_retention` | **Audit-Log-Regel** |
| `needs_am_review` | **AM-Review nötig** |
| `account.group_id` / `account_group_id` | *umschreiben: „einer Firmengruppe zugeordnet"* |
| `mandat-kuendigung` | **AGB §6 Mandats-Kündigung** |
| `presentation_type` | **Vorstellungs-Typ** |

### 16.10 Route-Placeholders → sprechend

**Regel:** Niemals `/entity/[id]` als Platzhalter-URL in User-Text. Einheitlich `-Vollansicht`.

| Route-Pattern | UI-Label |
|---------------|---------|
| `/mandates/[id]` | **Mandat-Vollansicht** |
| `/processes/[id]` | **Prozess-Vollansicht** |
| `/accounts/[id]` | **Account-Vollansicht** |
| `/candidates/[id]` | **Kandidat-Vollansicht** |
| `/jobs/[id]` | **Job-Vollansicht** |
| `/projects/[id]` | **Projekt-Vollansicht** |
| `/groups/[id]` | **Firmengruppe-Vollansicht** |
| `/assessments/[id]` | **Assessment-Vollansicht** |

### 16.11 Sonstige UI-Wording-Regeln

- **Urheber-Chips:** `Upload · PW` / `Doc-Gen · JV` / `SYS` (nie technische Feld-Namen wie `author=…`)
- **Scraper-Source-Flag:** *„Scraper-Projekte"* statt `source='scraper'`
- **Privacy:** „öffentlich" / „intern" statt `privacy='public'`
- **Mitarbeiter-Kürzel:** 2 Buchstaben `PW/JV/LR/MF/NP/NS/BT` (niemals Vollname in Chips)
- **Admin-/Debug-Sektionen:** in `<!-- ark-lint-skip:begin reason=... -->` / `<!-- ark-lint-skip:end -->` einwickeln, um `dim_*/fact_*` erlaubt zu lassen (Saga-Preview, Post-Saga-Trigger, Audit-Trail-Warnungen)

### 16.12 Reminder-Typ-Labels (dim_reminder_templates §64)

Kanonische Labels für `.rt-chip` in `mockups/reminders.html` + Entity-Reminder-Tabs. **Nicht** Template-Keys (`rt_01` etc.) oder snake_case Trigger-Strings (`start_date − 7d`, `placed_at`, `scheduled_at`, `info_requested_at`) in User-Text zeigen — immer diese Labels.

| Template-Key | UI-Label (KANONISCH) | Icon | CSS-Klasse |
|--------------|----------------------|------|-----------|
| rt_01 `onboarding_call` | Onboarding | 🎯 | `.rt-chip.onboarding` |
| rt_02 `placement_1m` | Check-In · 1 Monat | ✓ | `.rt-chip.checkin` |
| rt_03 `placement_2m` | Check-In · 2 Monate | ✓ | `.rt-chip.checkin` |
| rt_04 `placement_3m` | Check-In · 3 Monate (Garantie-Ende) | ✓ | `.rt-chip.checkin` |
| rt_05 `guarantee_end` | Garantie | ⏱ | `.rt-chip.garantie` |
| rt_06 `interview_coaching` | Interview-Coaching | 🧑‍💼 | `.rt-chip.coaching` |
| rt_07 `interview_debriefing` | Debriefing | 💬 | `.rt-chip.debriefing` |
| rt_08 `interview_date_missing` | Interview-Datum | 📅 | `.rt-chip.interview-date` |
| rt_09 `briefing_missing` | Briefing | 🎓 | `.rt-chip.briefing` |
| rt_10 `info_request_auto_extend` | Schutzfrist | 🛡 | `.rt-chip.schutzfrist` |
| — | Kandidaten-Refresh | 🔄 | `.rt-chip.refresh` |
| — | Follow-up (manuell) | 📝 | `.rt-chip.followup` |
| — | Custom (User-defined) | 🛠 | `.rt-chip.custom` |

**Auto-Badge:** Reminders mit `is_auto_generated=true` → `<span class="auto-badge">⚙ Auto</span>` + Tooltip mit Klartext-Trigger-Beschreibung (z.B. „1 Monat nach Placement" statt `placed_at + 1 Monat`). Niemals Template-Keys oder DB-Spalten-Namen im Tooltip.

**Scope-Switcher-Labels:** „Eigene" / „Team" / „Alle" (nicht `self`/`team`/`all`).

**Saved-Views-Storage:** `dim_mitarbeiter.dashboard_config.reminders.saved_views[]` — in User-UI als „Ansichten" benennen, niemals JSON-Pfad oder Feldname zeigen.

---

## 17. Admin-Vollansicht-Patterns (neu 2026-04-17)

Aus `mockups/admin.html` extrahierte Snippets für System-Vollansichten (Admin-Tool-Masken). Verwendung **nur** in Admin-Scope (Tab innerhalb `/admin`) oder ähnlichen Konfigurations-Oberflächen.

### 17.1 Admin-Only Warn-Banner

Banner oberhalb Page-Banner zur Klarstellung Admin-Scope + Audit-Pflicht.

```html
<div class="admin-warn">
  <span style="font-size:18px">🔧</span>
  <div>
    <strong>Admin-Bereich</strong>
    <span style="color:var(--text-mid);margin-left:8px">System-Konfiguration · Nur für Rolle <!-- ark-lint-skip:begin reason=admin-role-enum --><code>admin</code><!-- ark-lint-skip:end --> sichtbar. Änderungen sind revisionspflichtig und werden im Audit-Log erfasst.</span>
  </div>
  <span style="flex:1"></span>
  <span class="s-badge purple">Rolle: Admin (PW)</span>
</div>
```

```css
.admin-warn { background:color-mix(in srgb,var(--amber) 8%,var(--surface)); border-bottom:2px solid var(--amber); padding:10px 28px; font-size:12px; display:flex; align-items:center; gap:12px; }
.admin-warn strong { color:var(--amber); font-family:'Libre Baskerville',serif; font-size:13px; }
```

### 17.2 Flag-Row-Pattern (Settings-Editor)

Zentraler Editor für `dim_automation_settings`-Keys. Grid: `1fr 160px 120px 80px`.

```html
<div class="flag-row">
  <div>
    <div class="flag-key">Ghosting-Frist (Tage)
      <!-- ark-lint-skip:begin reason=admin-config-key --><code>ghosting_frist_tage</code><!-- ark-lint-skip:end -->
    </div>
    <div class="flag-desc">Beschreibung was Key bewirkt</div>
  </div>
  <div class="flag-val"><input type="number" value="14" min="1" max="90"></div>
  <div class="flag-scope">Tenant</div>
  <div class="flag-edit"><button class="btn btn-sm">Ändern</button></div>
</div>
```

**Toggle-Variante:** `<label class="toggle"><input type="checkbox"><span class="slider"></span></label>` für Boolean-Flags.

**Staffel-Preview-Variante:** Erweitertes Grid `1fr auto 120px 80px` mit `.staffel-preview`-Chips zur Inline-Anzeige der Matrix-Werte. Editor öffnet via Drawer.

### 17.3 Matrix-Editor (Drawer)

Für Mehrzeilige Strukturen (Honorar-Staffel TC-Band × Fee%, Refund-Staffel 4 Blöcke).

```html
<table class="mtx-table">
  <thead><tr><th>#</th><th>Von</th><th>Bis</th><th>Wert</th><th></th></tr></thead>
  <tbody>
    <tr>
      <td><span class="mono">1</span></td>
      <td><input type="number" value="0"></td>
      <td><input type="number" value="120000"></td>
      <td><input type="number" value="22"></td>
      <td><span class="row-drop">✕</span></td>
    </tr>
  </tbody>
</table>
<button class="mtx-add" type="button">+ Zeile hinzufügen</button>
```

**Pflicht-Sektionen im Drawer:** Bänder/Blöcke · Optionen (Calc-Mode, Rounding) · Preview-Rechner · Historie.

### 17.4 Builder-Pattern (Conditions + Actions)

Für Automation-Rule-Builder. Beliebig viele Rows mit AND/OR-Logik.

```html
<div class="builder">
  <div class="builder-head">
    <h5>Bedingungen</h5>
    <div class="builder-logic">
      <button class="active">Alle (AND)</button>
      <button>Eine (OR)</button>
    </div>
  </div>
  <div class="cond-row">
    <select><option>Payload-Variable</option></select>
    <select><option>=</option></select>
    <input type="text" value="...">
    <span class="row-drop">✕</span>
  </div>
  <button class="mtx-add" type="button">+ Bedingung hinzufügen</button>
</div>
```

**Action-Row-Variante:** `.act-row.act-expanded` mit `.act-config` Inner-Container für komplexere Einstellungen pro Action-Typ.

**12 Action-Typen-Standard:** Reminder · Email · Notification · Feld setzen · Activity loggen · Webhook · Wert berechnen · Delay · Assessment · Dokument · Andere Regel · Custom JS.

### 17.5 Sub-Tab-Navigation

Für Tabs mit eigener Sub-Hierarchie (Email mit Templates/OAuth/CodeTwo/Ignore-List/Queue).

```html
<div class="sub-tabs">
  <div class="sub-tab active" data-sub="4-1" onclick="switchSubTab('4-1')">Templates <span class="cnt">38</span></div>
  <div class="sub-tab" data-sub="4-2" onclick="switchSubTab('4-2')">OAuth-Tokens <span class="cnt">14</span></div>
</div>
<div id="sub-4-1" class="sub-pane active">…</div>
<div id="sub-4-2" class="sub-pane">…</div>
```

JS-Helper:
```js
function switchSubTab(id) {
  const pane = document.getElementById('sub-' + id);
  const parent = pane.parentElement;
  parent.querySelectorAll(':scope > .sub-pane').forEach(p => p.classList.remove('active'));
  pane.classList.add('active');
  const bar = parent.querySelector(':scope > .sub-tabs');
  bar.querySelectorAll('.sub-tab').forEach(t => t.classList.remove('active'));
  bar.querySelector('[data-sub="' + id + '"]').classList.add('active');
}
```

### 17.6 Health-Dot + Status-Badge

Live-Health-Indikator für KPI-Cards, CB-Status, OAuth-Tokens.

```html
<span class="h-dot ok"></span>   <!-- grün, static -->
<span class="h-dot warn"></span> <!-- amber, static -->
<span class="h-dot err"></span>  <!-- rot, pulse animation -->
<span class="h-dot off"></span>  <!-- grau, deaktiviert -->

<span class="s-badge ok">CLOSED</span>
<span class="s-badge warn">HALF-OPEN</span>
<span class="s-badge err">OPEN</span>
<span class="s-badge purple">Beta</span>
<span class="s-badge gold">Placement</span>
<span class="s-badge info">Auto</span>
<span class="s-badge off">Paused</span>
```

### 17.7 Circuit-Breaker-Card

```html
<div class="cb-card">
  <div class="cb-head">
    <div class="cb-name">Email-Sequence-Engine</div>
    <span class="s-badge ok">CLOSED</span>
  </div>
  <div class="cb-sub">Trip-Schwelle: 20 Fehler / 5 min · aktuell 0</div>
  <div class="cb-stats">
    <span><strong>1 204</strong> Runs</span>
    <span><strong>0</strong> Fehler</span>
    <span>Letzter Reset: nie</span>
  </div>
  <div class="cb-foot"><button class="btn btn-sm btn-danger">Manual Reset</button></div>
</div>
```

CB-Cards in Grid `repeat(auto-fill,minmax(280px,1fr))`. Tripped-Variante: `.cb-card.tripped` mit roter Border + roter Tönung.

### 17.8 Queue-Meter

Multi-Row-Progress-Bar für Worker-Queues, Email-Delivery, Notification-Buckets.

```html
<div class="q-meter">
  <div class="q-meter-row">
    <span class="lbl">Sofort versendet</span>
    <div class="bar"><div class="bar-fill" style="width:96%"></div></div>
    <span class="val">247</span>
  </div>
  <div class="q-meter-row">
    <span class="lbl">Im Queue (pending)</span>
    <div class="bar"><div class="bar-fill warn" style="width:4%"></div></div>
    <span class="val">3</span>
  </div>
</div>
```

Bar-Fill-Klassen: `.bar-fill` (accent default) · `.bar-fill.warn` (amber) · `.bar-fill.err` (rot).

### 17.9 Variable-Chips (Template-Editor)

Klick-einfügbare Variablen für Reminder-/Email-/Notification-Templates.

```html
<label>Verfügbare Variablen · Klick zum Einfügen</label>
<div class="var-chips">
  <span class="var-chip">{{candidate.name}}</span>
  <span class="var-chip">{{account.name}}</span>
  <span class="var-chip">{{stage}}</span>
  <span class="var-chip">+ Custom-Variable</span>
</div>
```

JS: Click → `navigator.clipboard.writeText(text)` + Toast „Variable kopiert" (v0.1) oder Direct-Insert am Cursor (v0.2).

### 17.10 Priority-Seg + Channel-Chips

```html
<!-- Priorität (single-select) -->
<div class="prio-seg">
  <button data-p="low">Low</button>
  <button data-p="medium">Med</button>
  <button data-p="high" class="active">High</button>
  <button data-p="urgent">Urg</button>
</div>

<!-- Kanäle (multi-select) -->
<div class="ch-chips">
  <span class="ch-chip active">In-App</span>
  <span class="ch-chip active">Push</span>
  <span class="ch-chip">Email-Digest</span>
</div>
```

Click-Logik via globalen `document.addEventListener('click')` Handler in `admin.html` script-block (single-select für `.prio-seg button`, toggle für `.ch-chip`).

### 17.11 Drawer-Wide (760px) für Builder

Standard-Drawer ist 540px (CRUD). Builder-Drawer (Rule-Builder, Fee-Staffel-Matrix, Template-Editor mit Body/Subject/Vars) nutzen 760px:

```html
<div class="drawer drawer-wide" id="ruleDrawer">…</div>
```

Class kommt aus `editorial.css`:
```css
.drawer.drawer-wide { width:760px; max-width:96vw; }
```

**Regel:** 540px für linear-CRUD (1 Eingabe-Liste). 760px für Multi-Sektion-Builder (Trigger + Conditions + Actions + Test-Run).

### 17.12 Wo verwenden / wo nicht

| Pattern | Verwenden in | Niemals in |
|---------|--------------|------------|
| Admin-Warn-Banner | `/admin/*` Seiten | Entity-Detailseiten, Tool-Masken (Email/Reminders/Dok-Generator) |
| Flag-Row | Admin Tab 1, Sub-Tabs Settings | Entity-Felder · dort `<input>` oder `<select>` direkt |
| Matrix-Editor | Admin Drawer für Staffeln | Entity-Drawer (zu schwer für 1 Feld) |
| Builder | Admin Tab 2 Rule-Builder | UI-Validation-Forms (zu komplex) |
| Sub-Tabs | Admin Tab 4/6/9/10 (5+ Sub-Inhalte) | Entity-Detailseiten (haupt-Tabs reichen) |
| Health-Dot pulse | CB-OPEN, Critical-Alert | Normaler Status (nur static-Variante) |
| CB-Card | Admin Tab 2 + 9 | Andere Karten-Inhalte |
| Queue-Meter | Worker-Queues, Email-Delivery | KPI-Cards (dort `.kpi-val` nutzen) |

---

## Related

- [[frontend-freeze-digest]] — Design-System-Tokens, Routing, Patterns (Theorie)
- [[spec-sync-regel]] — 5 Grundlagen ↔ 9 Detailmasken ↔ Mockups
- [[detailseiten-inventar]] — Welche Detailmaske hat welche Tabs/Cards
- [[detailseiten-guideline]] — Einheitliche Struktur der 9 Detailmasken
- [[lint-violations]] — Historie der DB-Tech-Drift + Resolution-Blöcke pro Mockup
- [[admin-system]] — Admin-Vollansicht Konzept · 10 Tabs · Single-Write-Entry-Point
