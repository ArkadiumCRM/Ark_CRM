# Assessment-Detailmaske Mockup — Implementation Plan v1

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Bestehende `mockups/assessments.html` (638 Zeilen Stub) inkrementell in 3 Phasen auf v0.2-Parität bringen: Header-Ausbau · 4 Drawers · 5 Tabs vollständig · Order-Scope-Fix (Tab 4/5) · Typen-Katalog Phase 1.

**Architecture:** Reine HTML/CSS/JS-Mockup-Datei (single-file), erbt Design-System aus `mockups/_shared/editorial.css` + `layout.js`. Keine neuen CSS-Files. Drawer-Pattern 540px slide-in identisch zu `mockups/candidates.html` Drawers. Seed-Daten hardcoded, keine API-Integration.

**Tech Stack:** HTML5 · Editorial CSS (Libre Baskerville + DM Sans) · Vanilla JS · Keine Build-Pipeline

**Quell-Plan:** [specs/ARK_ASSESSMENT_DETAILMASKE_MOCKUP_PLAN.md](ARK_ASSESSMENT_DETAILMASKE_MOCKUP_PLAN.md)
**Quell-Specs:** `specs/ARK_ASSESSMENT_DETAILMASKE_{SCHEMA,INTERACTIONS}_v0_2.md`
**Drift-Referenzen:** `mockups/candidates.html`, `mockups/processes.html`, `mockups/mandates.html`

---

## File Structure

**Modified:**
- `mockups/assessments.html` — einzige Arbeitsdatei, von 638 → ~2'500 Zeilen

**Created pro Phase:**
- `backups/assessments.html.2026-04-17-<HHMM>-p1.bak`
- `backups/assessments.html.2026-04-17-<HHMM>-p2.bak`
- `backups/assessments.html.2026-04-17-<HHMM>-p3.bak`

**Keine neuen Files** ausser Backups.

---

## Gemeinsame Patterns (für alle Drawers referenziert)

**Drawer-Skelett** (aus `mockups/candidates.html` Pattern, 540px):
```html
<div id="drawer-<name>" class="drawer" style="display:none">
  <div class="drawer-backdrop" onclick="closeDrawer('<name>')"></div>
  <aside class="drawer-panel" style="width:540px">
    <header class="drawer-head">
      <h3>[Titel]</h3>
      <button class="drawer-close" onclick="closeDrawer('<name>')">✕</button>
    </header>
    <div class="drawer-body">
      [Content]
    </div>
    <footer class="drawer-foot">
      <button class="btn btn-sm" onclick="closeDrawer('<name>')">Abbrechen</button>
      <button class="btn btn-sm btn-primary">[Primary-Action]</button>
    </footer>
  </aside>
</div>
```

**Drawer-Toggle-JS** (global in `<script>` am Dateiende):
```js
function openDrawer(name, ctx) {
  const d = document.getElementById('drawer-' + name);
  if (!d) return;
  d.dataset.ctx = JSON.stringify(ctx || {});
  d.style.display = 'block';
}
function closeDrawer(name) {
  const d = document.getElementById('drawer-' + name);
  if (d) d.style.display = 'none';
}
```

**Verifikation pro Task:**
- `Read` der modifizierten Stelle in `assessments.html`
- Bei visuellen Änderungen: Browser-Preview via Playwright oder manuell öffnen
- Pro Phase-Ende: `ark-lint` Skill laufen lassen

---

# PHASE 1 — Kern-Workflow

**Ziel:** User-testbar Credit zuweisen → Kandidat wählen → Termin → Durchführung-Drawer → Ersetzen/Abbrechen.

**Zielumfang P1:** ~+995 Zeilen (638 → ~1'635).

---

## Task 1.0: Backup + Snapshot-Bar 7 Slots

**Files:**
- Modify: `mockups/assessments.html:74-80` (bestehender kpi-strip Tab 1)
- Create: `backups/assessments.html.2026-04-17-<HHMM>-p1.bak`

- [ ] **Step 1: Backup schreiben**

Bash:
```bash
cp "mockups/assessments.html" "backups/assessments.html.$(date +%Y-%m-%d-%H%M)-p1.bak"
```

- [ ] **Step 2: Snapshot-Bar von 5 auf 7 Slots erweitern**

Aktuell Zeilen 74–80 in `<div id="tab-1">`: `kpi-strip` mit 5 Slots. **ABER:** Die echte Snapshot-Bar muss in den **Header-Bereich** (unter `page-banner`, vor `tabbar`) — nicht in Tab 1. Tab-1-KPI-Strip bleibt, Header-Snapshot-Bar wird **neu** eingefügt.

Einfügen nach Zeile 60 (`</div>` von `page-banner`), vor `<nav class="tabbar">`:

```html
<div class="snapshot-bar" style="padding:12px 28px;background:var(--surface);border-bottom:1px solid var(--border);display:grid;grid-template-columns:repeat(7,1fr);gap:12px">
  <div class="snap-slot"><div class="snap-label muted">💰 Preis</div><div class="snap-value">CHF 28'000</div></div>
  <div class="snap-slot"><div class="snap-label muted">🎯 Credits-Mix</div><div class="snap-value">10× ASSESS · 5× EQ</div></div>
  <div class="snap-slot"><div class="snap-label muted">✅ Verbraucht</div><div class="snap-value">1</div></div>
  <div class="snap-slot"><div class="snap-label muted">⏳ Ausstehend</div><div class="snap-value">14</div></div>
  <div class="snap-slot"><div class="snap-label muted">📦 Package</div><div class="snap-value">gemischt</div></div>
  <div class="snap-slot"><div class="snap-label muted">🤝 Partner</div><div class="snap-value">SCHEELEN + ASSESS 5.0</div></div>
  <div class="snap-slot"><div class="snap-label muted">📅 Bestellt</div><div class="snap-value">01.03.2026</div></div>
</div>
```

Tab-1-KPI-Strip unverändert lassen (zeigt operative KPIs, Snapshot-Bar zeigt Order-Meta — beide haben Zweck).

- [ ] **Step 3: Typen-Daten auf Phase-1-4-Typen updaten**

Seed-Daten im Mockup aktualisieren. Datenbestand-Szenario Order ORD-2026-042:
- 2× MDI (1 completed, 1 assigned an Tobias Furrer)
- 1× Relief (scheduled für Nadine Berger, 20.04.)
- 1× ASSESS 5.0 (frei)
- 1× EQ (frei)

Chips/Labels im Tab-2 (Zeilen ~144–147) nachziehen: ersetze "ASSESS 5.0" durch gemischte Typen-Szenarien. Genaue Zeilen-Updates im Task 1.3.

- [ ] **Step 4: Verifikation**

Grep:
```
Grep pattern="snapshot-bar" path="mockups/assessments.html"
```
Expected: 1 Match.

Browser: `mockups/assessments.html` öffnen, Header-Bereich zeigt 7-Slot-Zeile zwischen Banner und Tabbar.

- [ ] **Step 5: Kein Commit** (Phase-Ende sammelt alles)

---

## Task 1.1: Credit-Progress-Bar multi-stacked pro Typ

**Files:**
- Modify: `mockups/assessments.html` (nach Snapshot-Bar)

- [ ] **Step 1: Progress-Bar-Komponente einfügen**

Nach dem neuen `<div class="snapshot-bar">` aus Task 1.0, vor `<nav class="tabbar">`:

```html
<div class="credit-progress" style="padding:10px 28px;background:var(--bg);border-bottom:1px solid var(--border)">
  <div class="muted" style="font-size:11px;margin-bottom:8px;font-weight:600;letter-spacing:0.05em;text-transform:uppercase">Credit-Verbrauch pro Typ</div>

  <!-- Pro Typ eine Zeile: [Label] [Bar] [Text] -->
  <div class="cp-row" style="display:grid;grid-template-columns:110px 1fr 200px;gap:12px;align-items:center;margin-bottom:4px">
    <div class="cp-label"><strong>MDI</strong></div>
    <div class="cp-bar" style="height:10px;background:var(--border-soft);border-radius:2px;overflow:hidden;display:flex">
      <div style="width:50%;background:var(--gold)" title="verbraucht"></div>
      <div style="width:50%;background:var(--amber)" title="zugewiesen"></div>
    </div>
    <div class="cp-text muted" style="font-size:11px">1 verbraucht · 1 scheduled · 0 frei</div>
  </div>

  <div class="cp-row" style="display:grid;grid-template-columns:110px 1fr 200px;gap:12px;align-items:center;margin-bottom:4px">
    <div class="cp-label"><strong>Relief</strong></div>
    <div class="cp-bar" style="height:10px;background:var(--border-soft);border-radius:2px;overflow:hidden;display:flex">
      <div style="width:100%;background:var(--amber)" title="zugewiesen"></div>
    </div>
    <div class="cp-text muted" style="font-size:11px">0 verbraucht · 1 scheduled · 0 frei</div>
  </div>

  <div class="cp-row" style="display:grid;grid-template-columns:110px 1fr 200px;gap:12px;align-items:center;margin-bottom:4px">
    <div class="cp-label"><strong>ASSESS 5.0</strong></div>
    <div class="cp-bar" style="height:10px;background:var(--border-soft);border-radius:2px;overflow:hidden;display:flex"></div>
    <div class="cp-text muted" style="font-size:11px">0 verbraucht · 0 scheduled · 1 frei</div>
  </div>

  <div class="cp-row" style="display:grid;grid-template-columns:110px 1fr 200px;gap:12px;align-items:center">
    <div class="cp-label"><strong>EQ Test</strong></div>
    <div class="cp-bar" style="height:10px;background:var(--border-soft);border-radius:2px;overflow:hidden;display:flex"></div>
    <div class="cp-text muted" style="font-size:11px">0 verbraucht · 0 scheduled · 1 frei</div>
  </div>
</div>
```

**Farb-Legende:** `--gold` verbraucht · `--amber` zugewiesen · `--border-soft` frei (leer)

- [ ] **Step 2: Verifikation**

Grep:
```
Grep pattern="credit-progress" path="mockups/assessments.html"
```
Expected: 1 Match mit 4 `cp-row`-Blöcken.

Browser-Preview: Bar visuell korrekt, Farben konsistent.

---

## Task 1.2: Quick-Actions + Breadcrumb-Konditional + Status-Dropdown-Confirm

**Files:**
- Modify: `mockups/assessments.html:43-48` (banner-actions)
- Modify: `mockups/assessments.html:21-26` (breadcrumb)
- Modify: `mockups/assessments.html:52` (status-dropdown)

- [ ] **Step 1: Breadcrumb-Sub für Mandat-Verknüpfung**

Nach Zeile 26 (`<span class="current">ORD-2026-042</span>`) + `</div>` → zusätzliche Sub-Zeile. Breadcrumb-Div erweitern:

```html
<div class="breadcrumb">
  <a href="accounts.html">Accounts</a><span class="sep">/</span>
  <a href="accounts.html">Bauherr Muster AG</a><span class="sep">/</span>
  <a href="#">Assessment-Orders</a><span class="sep">/</span>
  <span class="current">ORD-2026-042</span>
  <div class="breadcrumb-sub muted" style="font-size:11px;margin-top:2px">aus Mandat: <a href="mandates.html">CFO-Suche</a> · Option IX</div>
</div>
```

- [ ] **Step 2: Quick-Actions komplettieren**

Zeilen 43–48 `banner-actions` durch diesen Block ersetzen:

```html
<div class="banner-actions" style="margin-top:12px;display:flex;gap:6px;flex-wrap:wrap">
  <button class="btn btn-sm">📞 Anrufen</button>
  <button class="btn btn-sm">✉ Email</button>
  <button class="btn btn-sm">📄 Offerte ansehen</button>
  <button class="btn btn-sm" onclick="openDrawer('report-upload')">📤 Report übertragen</button>
  <button class="btn btn-sm btn-primary" onclick="openDrawer('credit-assign')">➕ Credit zuweisen <span class="muted" style="font-size:11px">(2 frei)</span></button>
</div>
```

Hinweis: Sichtbarkeits-Regeln aus Interactions §TEIL 1 sind als Kommentare dokumentiert (Mockup zeigt den "Maximal"-Zustand), echte Bedingungen später im React-Port.

- [ ] **Step 3: Status-Dropdown (Zeile 52) ausbauen**

Bestehend:
```html
<button class="status-dropdown">Ordered</button>
```

Ersetzen durch:
```html
<div class="status-menu" style="position:relative;display:inline-block">
  <button class="status-dropdown" onclick="document.getElementById('statusMenu').classList.toggle('open')">Ordered ▾</button>
  <div id="statusMenu" class="dropdown-panel" style="display:none;position:absolute;right:0;top:100%;background:var(--surface);border:1px solid var(--border);border-radius:3px;min-width:200px;z-index:10;box-shadow:0 4px 12px rgba(0,0,0,0.08)">
    <div class="dd-item muted" style="padding:8px 12px">Offered</div>
    <div class="dd-item" style="padding:8px 12px;background:var(--bg);font-weight:600">Ordered (aktuell)</div>
    <div class="dd-item muted" style="padding:8px 12px">Partially Used (auto)</div>
    <div class="dd-item muted" style="padding:8px 12px">Fully Used (auto)</div>
    <div class="dd-sep" style="border-top:1px solid var(--border)"></div>
    <div class="dd-item" style="padding:8px 12px;color:var(--red);cursor:pointer" onclick="openDrawer('cancel-order')">Cancelled …</div>
  </div>
</div>
```

**Wichtig:** Kein `Invoiced`-Status (feedback memory). Cancelled öffnet Confirm-Drawer (Implementation Phase 3).

- [ ] **Step 4: Dropdown-Toggle JS ergänzen**

Am Dateiende vor `</body>` im `<script>`-Block ergänzen:

```js
document.addEventListener('click', e => {
  if (!e.target.closest('.status-menu')) {
    const m = document.getElementById('statusMenu');
    if (m) m.classList.remove('open');
  }
});
```

- [ ] **Step 5: Verifikation**

Grep:
```
Grep pattern="Invoiced" path="mockups/assessments.html"
```
Expected: 0 Matches.

```
Grep pattern="breadcrumb-sub" path="mockups/assessments.html"
```
Expected: 1 Match.

---

## Task 1.3: Tab 1 Credits-Tabelle 4-Typen-Umbau + "+Weiteren Typ"

**Files:**
- Modify: `mockups/assessments.html:108-120` (credits card)

- [ ] **Step 1: Credits-Tabelle auf 4 Phase-1-Typen umbauen**

Zeilen 108–120 (`<div class="card"` mit Credits-Tabelle) durch diesen Block ersetzen:

```html
<div class="card" style="padding:0;overflow:hidden">
  <div class="card-head" style="padding:14px 20px;margin-bottom:0;border:none;display:flex;justify-content:space-between;align-items:center">
    <div>
      <div class="card-title">Credits (typisiert)</div>
      <span class="muted" style="font-size:11px">🔒 Gekaufte Mengen nach Ordered nicht mehr editierbar</span>
    </div>
    <button class="btn btn-sm" disabled title="Nur vor Ordered möglich">+ Weiteren Typ hinzufügen</button>
  </div>
  <table class="data-table">
    <thead><tr><th>Typ</th><th>Partner</th><th class="right">Gekauft</th><th class="right">Verbraucht</th><th class="right">Zugewiesen</th><th class="right">Frei</th><th class="right">Einzelpreis</th><th class="right">Aktion</th></tr></thead>
    <tbody>
      <tr><td><strong>MDI</strong></td><td class="muted">SCHEELEN</td><td class="right">2</td><td class="right">1</td><td class="right">1</td><td class="right">0</td><td class="right">CHF 2'500</td><td class="right"><span class="muted">alle vergeben</span></td></tr>
      <tr><td><strong>Relief</strong></td><td class="muted">SCHEELEN</td><td class="right">1</td><td class="right">0</td><td class="right">1</td><td class="right">0</td><td class="right">CHF 1'800</td><td class="right"><span class="muted">alle vergeben</span></td></tr>
      <tr><td><strong>ASSESS 5.0</strong></td><td class="muted">ASSESS 5.0</td><td class="right">1</td><td class="right">0</td><td class="right">0</td><td class="right">1</td><td class="right">CHF 3'200</td><td class="right"><button class="btn btn-sm" onclick="openDrawer('credit-assign', {type:'assess_5_0'})">+ Zuweisen</button></td></tr>
      <tr><td><strong>EQ Test</strong></td><td class="muted">SCHEELEN</td><td class="right">1</td><td class="right">0</td><td class="right">0</td><td class="right">1</td><td class="right">CHF 2'000</td><td class="right"><button class="btn btn-sm" onclick="openDrawer('credit-assign', {type:'eq'})">+ Zuweisen</button></td></tr>
    </tbody>
    <tfoot>
      <tr style="background:var(--bg);border-top:2px solid var(--border-strong)">
        <td colspan="2"><strong>Total</strong></td>
        <td class="right"><strong>5</strong></td>
        <td class="right">1</td>
        <td class="right">2</td>
        <td class="right"><strong>2</strong></td>
        <td class="right" colspan="2">—</td>
      </tr>
    </tfoot>
  </table>
</div>
```

- [ ] **Step 2: Andere Typen-Referenzen im Mockup säubern**

Grep nach alten Typen die Phase 1 nicht beinhalten:
```
Grep pattern="DISC|Motivatoren|6HM|Driving Forces|Ikigai|Teamrad" path="mockups/assessments.html"
```
Alle Treffer entfernen oder durch Phase-1-Typen ersetzen. Liste aktualisieren in:
- Tab 2 Filter-Dropdown (Zeile ~135): `<select>` nur `MDI · Relief · ASSESS 5.0 · EQ Test`
- Tab 2 Tabellen-Zeilen (Zeilen ~144–147): Chips + Namen an neue Seed-Szenarios anpassen

- [ ] **Step 3: Tab 2 Tabelle-Seed-Daten updaten**

Zeilen ~144–147 durch diese 3 Seed-Zeilen ersetzen (abgeleitet aus Credits-Seed):

```html
<tr style="cursor:pointer" onclick="openDrawer('run-detail', {runId:'r-001'})">
  <td><span class="chip chip-accent">MDI</span></td>
  <td><strong>Tobias Furrer</strong></td>
  <td><span class="chip chip-green">completed</span></td>
  <td>02.04.2026</td>
  <td>03.04.2026</td>
  <td>04.04.2026</td>
  <td>SCHEELEN</td>
  <td>✅</td>
  <td class="right"><button class="row-icon-btn">›</button></td>
</tr>
<tr style="cursor:pointer" onclick="openDrawer('run-detail', {runId:'r-002'})">
  <td><span class="chip chip-accent">MDI</span></td>
  <td><strong>Martin Stucki</strong></td>
  <td><span class="chip chip-amber">assigned</span></td>
  <td>12.04.2026</td>
  <td class="muted">—</td>
  <td class="muted">—</td>
  <td>SCHEELEN</td>
  <td class="muted">—</td>
  <td class="right"><button class="row-icon-btn">›</button></td>
</tr>
<tr style="cursor:pointer" onclick="openDrawer('run-detail', {runId:'r-003'})">
  <td><span class="chip chip-accent">Relief</span></td>
  <td><strong>Nadine Berger</strong></td>
  <td><span class="chip chip-accent">scheduled</span></td>
  <td>05.04.2026</td>
  <td>20.04.2026</td>
  <td class="muted">—</td>
  <td>SCHEELEN</td>
  <td class="muted">—</td>
  <td class="right"><button class="row-icon-btn">›</button></td>
</tr>
```

- [ ] **Step 4: Verifikation**

Grep nach verbannten Typen:
```
Grep pattern="DISC|Motivatoren|6HM|Ikigai|Teamrad" path="mockups/assessments.html"
```
Expected: 0 Matches.

Grep nach neuen Typen:
```
Grep pattern="MDI|Relief|ASSESS 5.0|EQ Test" path="mockups/assessments.html"
```
Expected: je ≥2 Matches.

---

## Task 1.4: Tab 1 Sektion 4 Status & Abschluss

**Files:**
- Modify: `mockups/assessments.html` (Tab 1, nach Credits-Tabelle)

- [ ] **Step 1: Status-&-Abschluss-Card einfügen**

Nach der Credits-Tabellen-Card aus Task 1.3, vor `<div class="card"><div class="card-head"><div class="card-title">Kandidaten mit Credit</div>` einfügen:

```html
<div class="card">
  <div class="card-head"><div class="card-title">Status &amp; Abschluss</div></div>
  <dl class="field-grid">
    <dt>Order-Status</dt><dd><span class="chip chip-amber">Ordered</span></dd>
    <dt>Credits-Fälligkeit</dt><dd><input type="date" value="" style="border:1px solid var(--border);padding:4px 8px;border-radius:2px;background:var(--surface)"> <span class="muted" style="font-size:11px">(optional, leer = kein Verfall)</span></dd>
    <dt>Notizen</dt>
    <dd><textarea rows="3" style="width:100%;border:1px solid var(--border);padding:6px 8px;border-radius:2px;background:var(--surface);font-family:inherit;font-size:13px" placeholder="Auftragsnotizen, interne Hinweise …">Mandats-bezogenes Paket. Option IX aus CFO-Mandat, Budget aus Taskforce-Fee finanziert.</textarea></dd>
    <dt>Stornieren</dt><dd><button class="btn btn-sm" style="color:var(--red)" onclick="openDrawer('cancel-order')">Auftrag stornieren …</button> <span class="muted" style="font-size:11px">(Kulanz-Refund manuell durch Admin)</span></dd>
  </dl>
</div>
```

- [ ] **Step 2: Verifikation**

Grep:
```
Grep pattern="Credits-F\\u00e4lligkeit|credits_expiry" path="mockups/assessments.html"
```
Expected: 1 Match "Credits-Fälligkeit".

---

## Task 1.5: Tab 1 Sektion 5 Verknüpfungen ausbauen

**Files:**
- Modify: `mockups/assessments.html` (Tab 1, Kandidaten-mit-Credit Card)

- [ ] **Step 1: Bestehende Kandidaten-Card erweitern**

Bestehende `<div class="card">` mit "Kandidaten mit Credit" (Zeilen ~122–128) durch **erweiterte Verknüpfungs-Card** ersetzen:

```html
<div class="card">
  <div class="card-head"><div class="card-title">Verknüpfungen</div></div>

  <div style="margin-bottom:18px">
    <div class="muted" style="font-size:11px;font-weight:600;text-transform:uppercase;letter-spacing:0.05em;margin-bottom:6px">Mandat</div>
    <div class="list-item"><div class="name"><strong><a href="mandates.html">CFO-Suche</a></strong></div><div class="meta">Taskforce · Option IX gebucht · Honorar-Gesamt CHF 95'000</div><span class="chip chip-accent">Option IX</span></div>
  </div>

  <div style="margin-bottom:18px">
    <div class="muted" style="font-size:11px;font-weight:600;text-transform:uppercase;letter-spacing:0.05em;margin-bottom:6px">Kandidaten mit Credit (3)</div>
    <div class="list-item"><div class="name"><strong><a href="candidates.html">Tobias Furrer</a></strong> · CFO-Mandat</div><div class="meta">MDI · completed 04.04.2026 · Report erhalten</div><span class="chip chip-gold">✓</span></div>
    <div class="list-item"><div class="name"><strong><a href="candidates.html">Martin Stucki</a></strong> · CFO-Mandat</div><div class="meta">MDI · assigned 12.04.2026</div><span class="chip">assigned</span></div>
    <div class="list-item"><div class="name"><strong><a href="candidates.html">Nadine Berger</a></strong> · CFO-Mandat</div><div class="meta">Relief · scheduled 20.04.2026</div><span class="chip chip-amber">scheduled</span></div>
  </div>

  <div>
    <div class="muted" style="font-size:11px;font-weight:600;text-transform:uppercase;letter-spacing:0.05em;margin-bottom:6px">Letzte 5 Events <a href="#" onclick="switchTab(5);return false" style="float:right;font-weight:400;text-transform:none">Alle in History →</a></div>
    <div class="hist-compact"><span class="muted" style="font-size:11px">14.04.</span> MDI-Credit zugewiesen · M. Stucki</div>
    <div class="hist-compact"><span class="muted" style="font-size:11px">05.04.</span> Relief-Termin gesetzt · N. Berger (20.04.)</div>
    <div class="hist-compact"><span class="muted" style="font-size:11px">04.04.</span> Report erhalten · T. Furrer MDI</div>
    <div class="hist-compact"><span class="muted" style="font-size:11px">02.04.</span> MDI-Credit zugewiesen · T. Furrer</div>
    <div class="hist-compact"><span class="muted" style="font-size:11px">01.03.</span> Order signiert</div>
  </div>
</div>
```

- [ ] **Step 2: Inline-Style `.hist-compact`**

Editorial.css hat das evtl. nicht. Minimal-Style inline im Block oder `<style>` im Head:

Füge in bestehendes `<style>` oder erstelle `<style>` nach `<link rel="stylesheet" href="_shared/editorial.css">`:

```html
<style>
.hist-compact { padding:4px 0;font-size:12px;border-bottom:1px dashed var(--border-soft); }
.hist-compact:last-child { border-bottom:none; }
</style>
```

- [ ] **Step 3: Verifikation**

Grep:
```
Grep pattern="hist-compact" path="mockups/assessments.html"
```
Expected: 6+ Matches (1 class def + 5 usages).

---

## Task 1.6: Tab 2 Filter Multi-Select + Empty-State

**Files:**
- Modify: `mockups/assessments.html` (Tab 2 filter-bar)

- [ ] **Step 1: Filter-Bar umbauen auf Multi-Select-Chips**

Bestehende Tab-2 filter-bar (Zeilen ~133–139) ersetzen:

```html
<div class="filter-bar">
  <input type="search" placeholder="🔍 Kandidat suchen …" style="flex:1 1 280px">
  <span class="spacer"></span>
  <button class="btn btn-sm btn-primary" onclick="openDrawer('credit-assign')">➕ Credit zuweisen <span class="muted" style="font-size:11px">(2 frei)</span></button>
</div>
<div class="filter-bar" style="padding-top:0">
  <div class="muted" style="font-size:11px;font-weight:600;text-transform:uppercase;letter-spacing:0.05em">Typ:</div>
  <div class="chip-group">
    <div class="chip-tab active">Alle <span class="count">3</span></div>
    <div class="chip-tab">MDI <span class="count">2</span></div>
    <div class="chip-tab">Relief <span class="count">1</span></div>
    <div class="chip-tab" style="opacity:0.4">ASSESS 5.0 <span class="count">0</span></div>
    <div class="chip-tab" style="opacity:0.4">EQ Test <span class="count">0</span></div>
  </div>
  <span class="spacer"></span>
  <div class="muted" style="font-size:11px;font-weight:600;text-transform:uppercase;letter-spacing:0.05em">Status:</div>
  <div class="chip-group">
    <div class="chip-tab active">Alle</div>
    <div class="chip-tab">assigned</div>
    <div class="chip-tab">scheduled</div>
    <div class="chip-tab">in_progress</div>
    <div class="chip-tab">completed</div>
    <div class="chip-tab">cancelled</div>
  </div>
</div>
```

- [ ] **Step 2: Empty-State einfügen**

Hinter der `</table>` (Tab 2) + `</div>` der card, vor `</div>` (tab-panel schliessen), als versteckter Block:

```html
<!-- Empty-State (JS-toggle; hier standardmässig versteckt) -->
<div class="empty-state" style="display:none;padding:40px;text-align:center;background:var(--bg);border:1px dashed var(--border);border-radius:3px">
  <div style="font-size:40px;margin-bottom:8px">🧭</div>
  <div style="font-weight:600;margin-bottom:4px">Noch kein Credit zugewiesen</div>
  <div class="muted" style="font-size:13px;margin-bottom:14px">Dieser Auftrag hat 5 Credits in 4 Typen. Weise den ersten Kandidaten zu.</div>
  <button class="btn btn-sm btn-primary" onclick="openDrawer('credit-assign')">➕ Credit zuweisen</button>
</div>
```

- [ ] **Step 3: Verifikation**

Grep:
```
Grep pattern="empty-state" path="mockups/assessments.html"
```
Expected: ≥1 Match.

---

## Task 1.7: Drawer 1 — Credit-Zuweisung (540px)

**Files:**
- Modify: `mockups/assessments.html` (neuer Drawer-Block vor `</body>`)

- [ ] **Step 1: Drawer-Container einfügen**

Vor `<script src="_shared/layout.js"></script>`:

```html
<!-- DRAWER: Credit-Zuweisung -->
<div id="drawer-credit-assign" class="drawer" style="display:none;position:fixed;inset:0;z-index:100">
  <div class="drawer-backdrop" onclick="closeDrawer('credit-assign')" style="position:absolute;inset:0;background:rgba(0,0,0,0.4)"></div>
  <aside class="drawer-panel" style="position:absolute;right:0;top:0;bottom:0;width:540px;background:var(--surface);border-left:1px solid var(--border);display:flex;flex-direction:column;box-shadow:-4px 0 12px rgba(0,0,0,0.1)">

    <header class="drawer-head" style="padding:18px 22px;border-bottom:1px solid var(--border);display:flex;justify-content:space-between;align-items:center">
      <div>
        <h3 style="margin:0;font-family:'Libre Baskerville',serif;font-size:18px">Credit zuweisen</h3>
        <div class="muted" style="font-size:12px;margin-top:2px">ORD-2026-042 · Bauherr Muster AG</div>
      </div>
      <button class="drawer-close" onclick="closeDrawer('credit-assign')" style="background:none;border:none;font-size:22px;cursor:pointer;color:var(--muted)">✕</button>
    </header>

    <div class="drawer-body" style="flex:1;overflow-y:auto;padding:22px">

      <!-- Step 1: Typ -->
      <div style="margin-bottom:22px">
        <label style="display:block;font-weight:600;margin-bottom:6px;font-size:13px">1. Assessment-Typ wählen <span style="color:var(--red)">*</span></label>
        <select id="ca-type" style="width:100%;padding:8px;border:1px solid var(--border);border-radius:2px;background:var(--surface);font-family:inherit;font-size:13px">
          <option value="">— Typ wählen —</option>
          <option value="assess_5_0">ASSESS 5.0 (1 frei)</option>
          <option value="eq">EQ Test (1 frei)</option>
          <option value="mdi" disabled>MDI (alle vergeben)</option>
          <option value="relief" disabled>Relief (alle vergeben)</option>
        </select>
        <div class="muted" style="font-size:11px;margin-top:4px">Typ-Wechsel nach Zuweisung nicht möglich. Credit-Freigabe + Neu-Kauf nötig.</div>
      </div>

      <!-- Step 2: Kandidat -->
      <div style="margin-bottom:22px">
        <label style="display:block;font-weight:600;margin-bottom:6px;font-size:13px">2. Kandidat zuweisen <span style="color:var(--red)">*</span></label>
        <input type="search" id="ca-candidate" placeholder="🔍 Name suchen oder aus Vorschlägen wählen …" style="width:100%;padding:8px;border:1px solid var(--border);border-radius:2px;background:var(--surface);font-family:inherit;font-size:13px">
        <div class="suggest-list" style="margin-top:8px;border:1px solid var(--border-soft);border-radius:2px;max-height:160px;overflow-y:auto">
          <div class="suggest-item" style="padding:8px 12px;cursor:pointer;border-bottom:1px solid var(--border-soft)"><strong>Tobias Furrer</strong> · CFO · <span class="muted">Kontakt Bauherr Muster AG</span></div>
          <div class="suggest-item" style="padding:8px 12px;cursor:pointer;border-bottom:1px solid var(--border-soft)"><strong>Martin Stucki</strong> · Head of Finance · <span class="muted">Kontakt Bauherr Muster AG</span></div>
          <div class="suggest-item" style="padding:8px 12px;cursor:pointer"><strong>Stefan Keller</strong> · CFO · <span class="muted">Kandidat · Muster Immobilien</span></div>
        </div>
        <div class="muted" style="font-size:11px;margin-top:6px">Nicht dabei? <a href="candidates.html" style="color:var(--accent)">→ Als Kandidat anlegen</a></div>
      </div>

      <!-- Step 3: Termin (optional) -->
      <div style="margin-bottom:22px">
        <label style="display:block;font-weight:600;margin-bottom:6px;font-size:13px">3. Termin (optional)</label>
        <input type="datetime-local" style="width:100%;padding:8px;border:1px solid var(--border);border-radius:2px;background:var(--surface);font-family:inherit;font-size:13px">
        <div class="muted" style="font-size:11px;margin-top:4px">Kann später gesetzt werden. Ohne Termin → Status `assigned`, mit Termin → `scheduled`.</div>
      </div>

      <!-- Duplikat-Check Warnung (ausgeblendet, conditional) -->
      <div style="display:none;padding:10px 12px;background:color-mix(in srgb, var(--amber) 15%, var(--surface));border-left:3px solid var(--amber);border-radius:2px;margin-bottom:14px">
        <strong>⚠ Duplikat-Warnung</strong>
        <div class="muted" style="font-size:12px;margin-top:4px">[Kandidat] hat bereits einen aktiven [Typ]-Credit in diesem Auftrag. Wiederholungs-Test? Dann fortfahren.</div>
      </div>

    </div>

    <footer class="drawer-foot" style="padding:14px 22px;border-top:1px solid var(--border);display:flex;gap:8px;justify-content:flex-end;background:var(--bg)">
      <button class="btn btn-sm" onclick="closeDrawer('credit-assign')">Abbrechen</button>
      <button class="btn btn-sm btn-primary">Zuweisen</button>
    </footer>

  </aside>
</div>
```

- [ ] **Step 2: Drawer-Helper-JS**

Falls noch nicht in Task 1.2 Step 4 eingefügt, am Dateiende im `<script>`-Block:

```js
function openDrawer(name, ctx) {
  const d = document.getElementById('drawer-' + name);
  if (!d) return;
  if (ctx) d.dataset.ctx = JSON.stringify(ctx);
  d.style.display = 'block';
}
function closeDrawer(name) {
  const d = document.getElementById('drawer-' + name);
  if (d) d.style.display = 'none';
}
document.addEventListener('keydown', e => {
  if (e.key === 'Escape') document.querySelectorAll('.drawer').forEach(d => d.style.display='none');
});
```

- [ ] **Step 3: Verifikation**

Grep:
```
Grep pattern="drawer-credit-assign" path="mockups/assessments.html"
```
Expected: ≥2 Matches (1 id + Trigger-Buttons).

Browser: Klick auf "➕ Credit zuweisen" öffnet 540px rechts-slide-in mit 3 Steps + Footer.

---

## Task 1.8: Drawer 2 — Run-Detail (540px)

**Files:**
- Modify: `mockups/assessments.html` (neuer Drawer)

- [ ] **Step 1: Run-Detail-Drawer einfügen**

Nach Drawer 1, gleicher Struktur:

```html
<!-- DRAWER: Run-Detail -->
<div id="drawer-run-detail" class="drawer" style="display:none;position:fixed;inset:0;z-index:100">
  <div class="drawer-backdrop" onclick="closeDrawer('run-detail')" style="position:absolute;inset:0;background:rgba(0,0,0,0.4)"></div>
  <aside class="drawer-panel" style="position:absolute;right:0;top:0;bottom:0;width:540px;background:var(--surface);border-left:1px solid var(--border);display:flex;flex-direction:column;box-shadow:-4px 0 12px rgba(0,0,0,0.1)">

    <header class="drawer-head" style="padding:18px 22px;border-bottom:1px solid var(--border);display:flex;justify-content:space-between;align-items:center">
      <div>
        <h3 style="margin:0;font-family:'Libre Baskerville',serif;font-size:18px">Durchführung · MDI</h3>
        <div class="muted" style="font-size:12px;margin-top:2px">Tobias Furrer · Run #r-001</div>
      </div>
      <button class="drawer-close" onclick="closeDrawer('run-detail')" style="background:none;border:none;font-size:22px;cursor:pointer;color:var(--muted)">✕</button>
    </header>

    <div class="drawer-body" style="flex:1;overflow-y:auto;padding:22px">

      <!-- Kandidat-Mini-Card -->
      <div style="padding:12px;background:var(--bg);border:1px solid var(--border);border-radius:3px;display:flex;gap:12px;align-items:center;margin-bottom:20px">
        <div style="width:48px;height:48px;border-radius:50%;background:var(--accent-soft);color:var(--accent);display:flex;align-items:center;justify-content:center;font-weight:700">TF</div>
        <div style="flex:1">
          <div><strong>Tobias Furrer</strong></div>
          <div class="muted" style="font-size:12px">CFO · Bauherr Muster AG</div>
        </div>
        <a href="candidates.html" class="btn btn-sm">→ Kandidat</a>
      </div>

      <!-- Timeline -->
      <div style="margin-bottom:20px">
        <div class="muted" style="font-size:11px;font-weight:600;text-transform:uppercase;letter-spacing:0.05em;margin-bottom:8px">Status-Verlauf</div>
        <div style="display:flex;gap:0;align-items:center">
          <div style="flex:1;padding:8px 10px;background:var(--gold-soft);color:var(--gold);border-radius:3px;font-size:12px;text-align:center">✓ assigned<br><span class="muted" style="font-size:10px">02.04.</span></div>
          <div style="width:8px;height:2px;background:var(--border)"></div>
          <div style="flex:1;padding:8px 10px;background:var(--gold-soft);color:var(--gold);border-radius:3px;font-size:12px;text-align:center">✓ scheduled<br><span class="muted" style="font-size:10px">03.04.</span></div>
          <div style="width:8px;height:2px;background:var(--border)"></div>
          <div style="flex:1;padding:8px 10px;background:var(--gold-soft);color:var(--gold);border-radius:3px;font-size:12px;text-align:center">✓ in_progress<br><span class="muted" style="font-size:10px">04.04.</span></div>
          <div style="width:8px;height:2px;background:var(--gold)"></div>
          <div style="flex:1;padding:8px 10px;background:var(--gold);color:var(--surface);border-radius:3px;font-size:12px;text-align:center;font-weight:600">● completed<br><span style="font-size:10px">04.04.</span></div>
        </div>
      </div>

      <!-- Felder -->
      <dl class="field-grid" style="margin-bottom:20px">
        <dt>Termin</dt><dd><input type="datetime-local" value="2026-04-03T10:00" disabled style="border:1px solid var(--border);padding:4px 8px;border-radius:2px;background:var(--bg)"></dd>
        <dt>Durchgeführt am</dt><dd>04.04.2026 · <span class="muted">SCHEELEN</span></dd>
        <dt>Notizen</dt><dd><textarea rows="2" style="width:100%;border:1px solid var(--border);padding:6px 8px;border-radius:2px;background:var(--bg);font-family:inherit;font-size:12px" disabled>Standard-Profil. Führungs-Stil „Impactful Leader".</textarea></dd>
        <dt>Report</dt><dd><a href="#" class="btn btn-sm">📄 Executive Summary</a> <a href="#" class="btn btn-sm">📑 Detail-Report</a></dd>
        <dt>Kandidat-Version</dt><dd><a href="candidates.html" style="color:var(--accent)">→ MDI-Version v1 am Kandidaten</a></dd>
      </dl>

      <!-- Actions (conditional nach Status) -->
      <div style="padding-top:14px;border-top:1px solid var(--border);display:flex;gap:6px;flex-wrap:wrap">
        <button class="btn btn-sm" disabled title="Nur ≤ scheduled">Kandidat ersetzen</button>
        <button class="btn btn-sm" disabled>Termin ändern</button>
        <button class="btn btn-sm" disabled>Als durchgeführt markieren</button>
        <button class="btn btn-sm" disabled style="color:var(--red)">Abbrechen &amp; freigeben</button>
      </div>
      <div class="muted" style="font-size:11px;margin-top:6px">Run ist abgeschlossen — alle Aktionen gesperrt. Für offene Runs: Actions aktiv.</div>

    </div>

  </aside>
</div>
```

**Hinweis:** Dieses Beispiel zeigt den **completed**-Run. Für andere Status (assigned/scheduled) sind die Action-Buttons aktiv und die Timeline zeigt weniger gefüllt. Mockup zeigt nur eine Variante; JS-Toggle je nach Context optional Phase 2+.

- [ ] **Step 2: Verifikation**

Grep:
```
Grep pattern="drawer-run-detail" path="mockups/assessments.html"
```
Expected: ≥2 Matches.

Browser: Klick auf erste Tab-2-Zeile (Tobias Furrer) öffnet Drawer.

---

## Task 1.9: Drawer 3 — Kandidat-Ersetzen (540px)

**Files:**
- Modify: `mockups/assessments.html` (neuer Drawer)

- [ ] **Step 1: Kandidat-Ersetzen-Drawer einfügen**

Nach Drawer 2:

```html
<!-- DRAWER: Kandidat ersetzen -->
<div id="drawer-candidate-replace" class="drawer" style="display:none;position:fixed;inset:0;z-index:101">
  <div class="drawer-backdrop" onclick="closeDrawer('candidate-replace')" style="position:absolute;inset:0;background:rgba(0,0,0,0.4)"></div>
  <aside class="drawer-panel" style="position:absolute;right:0;top:0;bottom:0;width:540px;background:var(--surface);border-left:1px solid var(--border);display:flex;flex-direction:column;box-shadow:-4px 0 12px rgba(0,0,0,0.1)">

    <header class="drawer-head" style="padding:18px 22px;border-bottom:1px solid var(--border);display:flex;justify-content:space-between;align-items:center">
      <div>
        <h3 style="margin:0;font-family:'Libre Baskerville',serif;font-size:18px">Kandidat ersetzen</h3>
        <div class="muted" style="font-size:12px;margin-top:2px">MDI-Credit · Run r-002</div>
      </div>
      <button class="drawer-close" onclick="closeDrawer('candidate-replace')" style="background:none;border:none;font-size:22px;cursor:pointer;color:var(--muted)">✕</button>
    </header>

    <div class="drawer-body" style="flex:1;overflow-y:auto;padding:22px">

      <!-- Confirm-Box -->
      <div style="padding:14px;background:color-mix(in srgb, var(--amber) 15%, var(--surface));border-left:3px solid var(--amber);border-radius:2px;margin-bottom:20px">
        <strong>⚠ Person tauschen — Typ bleibt erhalten</strong>
        <div class="muted" style="font-size:12px;margin-top:6px">
          Der <strong>MDI</strong>-Credit (bisher zugewiesen an <strong>Martin Stucki</strong>) wird einem neuen Kandidaten übertragen. Der Typ kann nicht geändert werden. Audit-Log: `reassigned_from = Martin Stucki`.
        </div>
      </div>

      <!-- Alt-Kandidat Read-only -->
      <div style="padding:10px;background:var(--bg);border:1px solid var(--border);border-radius:3px;margin-bottom:16px">
        <div class="muted" style="font-size:11px;margin-bottom:4px">Bisher zugewiesen</div>
        <div><strong>Martin Stucki</strong> · Head of Finance · Bauherr Muster AG</div>
        <div class="muted" style="font-size:11px">Zugewiesen 12.04.2026 · Status: assigned · kein Termin</div>
      </div>

      <!-- Neu-Kandidat Suche -->
      <div style="margin-bottom:20px">
        <label style="display:block;font-weight:600;margin-bottom:6px;font-size:13px">Neuer Kandidat <span style="color:var(--red)">*</span></label>
        <input type="search" placeholder="🔍 Name suchen …" style="width:100%;padding:8px;border:1px solid var(--border);border-radius:2px;background:var(--surface);font-family:inherit;font-size:13px">
        <div class="suggest-list" style="margin-top:8px;border:1px solid var(--border-soft);border-radius:2px;max-height:160px;overflow-y:auto">
          <div class="suggest-item" style="padding:8px 12px;cursor:pointer;border-bottom:1px solid var(--border-soft)"><strong>Stefan Keller</strong> · CFO · <span class="muted">Muster Immobilien</span></div>
          <div class="suggest-item" style="padding:8px 12px;cursor:pointer"><strong>Barbara Lüthi</strong> · Head of Controlling · <span class="muted">LGT</span></div>
        </div>
      </div>

      <!-- Notiz -->
      <div>
        <label style="display:block;font-weight:600;margin-bottom:6px;font-size:13px">Grund (optional)</label>
        <textarea rows="2" style="width:100%;padding:6px 8px;border:1px solid var(--border);border-radius:2px;background:var(--surface);font-family:inherit;font-size:12px" placeholder="z.B. Kandidat abgesprungen, ersetzt durch passenderes Profil …"></textarea>
      </div>

    </div>

    <footer class="drawer-foot" style="padding:14px 22px;border-top:1px solid var(--border);display:flex;gap:8px;justify-content:flex-end;background:var(--bg)">
      <button class="btn btn-sm" onclick="closeDrawer('candidate-replace')">Abbrechen</button>
      <button class="btn btn-sm btn-primary">Zuweisung übertragen</button>
    </footer>

  </aside>
</div>
```

- [ ] **Step 2: Verifikation**

Grep:
```
Grep pattern="drawer-candidate-replace" path="mockups/assessments.html"
```
Expected: ≥1 Match.

---

## Task 1.10: Drift-Check + Lint + Commit P1

- [ ] **Step 1: Drift-Check via Skill**

```
Skill: mockup-drift-check args="mockups/assessments.html"
```
Expected: keine kritischen Drifts vs. candidates/mandates/processes Header-Patterns, Drawer-Width 540px überall, Tab-Struktur analog.

- [ ] **Step 2: Lint-Bundle**

```
Skill: ark-lint args="mockups/assessments.html"
```
Expected: alle 4 Lints (stammdaten, umlaute, db-techdetails, mockup-drift) grün oder nur Info-Warnings.

- [ ] **Step 3: Browser-Test**

Manuell öffnen: `mockups/assessments.html`. Durchgehen:
1. Snapshot-Bar 7 Slots sichtbar
2. Credit-Progress-Bar zeigt 4 Typen
3. Tab 1 Credits-Tabelle 4 Zeilen korrekt
4. Tab 1 Status-&-Abschluss-Card vorhanden
5. Tab 1 Verknüpfungen-Card mit Mandat + Kandidaten + History-Kurz
6. Tab 2 Filter-Chips funktionieren visuell
7. Klick "➕ Credit zuweisen" → Drawer 1 öffnet (540px, 3 Steps)
8. Klick auf Tab-2-Zeile "Tobias Furrer" → Drawer 2 öffnet
9. Esc schliesst Drawer

- [ ] **Step 4: Commit P1**

Bash:
```bash
cd "C:/ARK CRM"
git add mockups/assessments.html specs/ARK_ASSESSMENT_DETAILMASKE_MOCKUP_PLAN.md specs/ARK_ASSESSMENT_DETAILMASKE_MOCKUP_IMPL_v1.md backups/assessments.html.*-p1.bak
git commit -m "$(cat <<'EOF'
feat(mockup): Assessment-Detailmaske Phase 1 — Kern-Workflow

Header-Ausbau (Snapshot-Bar 7 Slots, Credit-Progress-Bar pro Typ,
Quick-Actions, Status-Dropdown ohne Invoiced, Mandat-Sub-Breadcrumb).
Tab 1 vollständig (Credits-Tabelle Phase-1-Typen MDI/Relief/ASSESS/EQ,
Status & Abschluss, Verknüpfungen). Tab 2 Filter-Chips + Empty-State.
3 Drawers neu: Credit-Zuweisung, Run-Detail, Kandidat-Ersetzen (540px).

Plan: specs/ARK_ASSESSMENT_DETAILMASKE_MOCKUP_{PLAN,IMPL_v1}.md

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
git push
```

---

# PHASE 2 — Billing + Dokumente + Report-Upload

**Ziel:** Billing-Details, Tab 4 auf Order-Scope, Report-Upload-Drawer.
**Zielumfang P2:** ~+700 Zeilen (1'635 → ~2'335).

---

## Task 2.0: Backup P2

- [ ] **Step 1: Backup**

Bash:
```bash
cp "mockups/assessments.html" "backups/assessments.html.$(date +%Y-%m-%d-%H%M)-p2.bak"
```

---

## Task 2.1: Tab 3 Billing — Zeilen-Typen + Status-Badges + Empty-State

**Files:**
- Modify: `mockups/assessments.html` Tab 3

- [ ] **Step 1: Tab 3 komplett überarbeiten**

Bestehenden Tab-3-Block (Zeilen ~153–169) ersetzen durch:

```html
<!-- TAB 3 · BILLING -->
<div id="tab-3" class="tab-panel">

  <div class="kpi-strip" style="display:grid;grid-template-columns:repeat(4,1fr);gap:12px;margin-bottom:16px">
    <div class="kpi-card"><div class="kpi-label">Gesamt</div><div class="kpi-value">CHF 30'268</div><div class="kpi-sub muted">inkl. MwSt</div></div>
    <div class="kpi-card"><div class="kpi-label" style="color:var(--gold)">Bezahlt</div><div class="kpi-value" style="color:var(--gold)">CHF 30'268</div><div class="kpi-sub muted">15.03.2026</div></div>
    <div class="kpi-card"><div class="kpi-label">Offen</div><div class="kpi-value">CHF 0</div><div class="kpi-sub muted">—</div></div>
    <div class="kpi-card"><div class="kpi-label">Spesen (separat)</div><div class="kpi-value">CHF 340</div><div class="kpi-sub muted">1 Beleg offen</div></div>
  </div>

  <div class="muted" style="font-size:11px;margin-bottom:10px;padding:8px 12px;background:var(--bg);border-left:3px solid var(--accent);border-radius:2px">
    ℹ Die Hauptrechnung wird automatisch erstellt beim Status-Wechsel Offered → Ordered (Credits-Modell, Komplettzahlung).
  </div>

  <div class="card" style="padding:0;overflow:hidden">
    <table class="data-table">
      <thead><tr><th>Rechnung</th><th>Typ</th><th>Betrag netto</th><th>MwSt</th><th>Total brutto</th><th>Status</th><th>Fällig</th><th>Erstellt</th><th>Bezahlt</th><th class="right">›</th></tr></thead>
      <tbody>
        <tr>
          <td><a href="#">RE-2026-0081</a></td>
          <td><span class="chip chip-accent">full (Pauschale)</span></td>
          <td class="right">CHF 28'000</td>
          <td class="right">CHF 2'268</td>
          <td class="right"><strong>CHF 30'268</strong></td>
          <td><span class="chip chip-gold">✅ Bezahlt</span></td>
          <td>bei Unterschrift</td>
          <td>01.03.2026</td>
          <td>15.03.2026</td>
          <td class="right"><button class="row-icon-btn">›</button></td>
        </tr>
        <tr>
          <td><a href="#">RE-2026-0094</a></td>
          <td><span class="chip">expense (Spesen)</span></td>
          <td class="right">CHF 315</td>
          <td class="right">CHF 25</td>
          <td class="right"><strong>CHF 340</strong></td>
          <td><span class="chip chip-amber">⏳ Offen</span></td>
          <td>30.04.2026</td>
          <td>12.04.2026</td>
          <td class="muted">—</td>
          <td class="right"><button class="row-icon-btn">›</button></td>
        </tr>
      </tbody>
    </table>
  </div>

  <!-- Status-Legende -->
  <div class="muted" style="font-size:11px;margin-top:10px;padding:8px 12px">
    <strong>Status-Legende:</strong>
    <span class="chip chip-amber" style="margin-left:6px">⏳ Offen</span>
    <span class="chip chip-accent" style="margin-left:6px">📄 Rechnungsstellung</span>
    <span class="chip chip-gold" style="margin-left:6px">✅ Bezahlt</span>
    <span class="chip chip-red" style="margin-left:6px">🔴 Überfällig</span>
  </div>

</div>
```

- [ ] **Step 2: Verifikation**

Grep:
```
Grep pattern="expense \\(Spesen\\)|full \\(Pauschale\\)" path="mockups/assessments.html"
```
Expected: je 1 Match.

---

## Task 2.2: Tab 4 Dokumente — Order-Scope-Umbau

**Files:**
- Modify: `mockups/assessments.html` Tab 4 (grösster Umbau, Zeilen ~173–383)

⚠ **Destruktiver Umbau** — bestehende Account-weite Doc-Liste (Scraper-Belege anderer Accounts, fremde Mandate, Stellenbriefings) komplett entfernen. Backup aus Task 2.0 bereits vorhanden.

- [ ] **Step 1: Kompletten Tab-4-Block ersetzen**

Von `<!-- TAB 4 · DOKUMENTE -->` bis zum schliessenden `</div>` des tab-panel (Zeilen ~172–383):

```html
<!-- TAB 4 · DOKUMENTE (Order-scoped) -->
<div id="tab-4" class="tab-panel">

  <!-- KPI-Leiste (Order-spezifisch) -->
  <div class="kpi-strip" style="display:grid;grid-template-columns:repeat(4,1fr);gap:12px;margin-bottom:16px">
    <div class="kpi-card"><div class="kpi-label">Total Dokumente</div><div class="kpi-value">6</div><div class="kpi-sub muted">in diesem Auftrag</div></div>
    <div class="kpi-card"><div class="kpi-label">Reports</div><div class="kpi-value">1</div><div class="kpi-sub muted">von 5 Credits</div></div>
    <div class="kpi-card"><div class="kpi-label">Offerten/Rechnungen</div><div class="kpi-value">3</div><div class="kpi-sub muted">alle signiert</div></div>
    <div class="kpi-card"><div class="kpi-label">Zuletzt hochgeladen</div><div class="kpi-value" style="font-size:14px;padding-top:8px">04.04.2026</div><div class="kpi-sub muted">PW</div></div>
  </div>

  <!-- Action-Bar -->
  <div class="filter-bar">
    <input type="search" placeholder="🔍 Dateiname, Kategorie …" style="flex:1 1 280px">
    <select>
      <option>Alle Kategorien</option>
      <option>Offerte</option>
      <option>Executive Summary</option>
      <option>Detail-Report</option>
      <option>Rechnung</option>
      <option>Spesenbeleg</option>
      <option>Korrespondenz</option>
      <option>Sonstiges</option>
    </select>
    <select>
      <option>Alle Urheber</option>
      <option>PW</option><option>JV</option><option>LR</option>
      <option>— Doc-Generator —</option>
      <option>— Upload extern (SCHEELEN) —</option>
    </select>
    <span class="spacer"></span>
    <button class="btn btn-sm" disabled title="Globaler Dok-Generator — separates Projekt nach Assessment-Mockup-Fertigstellung">📄 Offerte generieren → Dok-Generator</button>
    <button class="btn btn-sm btn-primary" onclick="openDrawer('report-upload')">📤 Report übertragen</button>
    <button class="btn btn-sm">+ Upload</button>
  </div>

  <!-- Kategorie-Chips -->
  <div class="filter-bar" style="padding-top:0">
    <div class="chip-group">
      <div class="chip-tab active">Alle <span class="count">6</span></div>
      <div class="chip-tab">Offerte <span class="count">1</span></div>
      <div class="chip-tab">Executive Summary <span class="count">1</span></div>
      <div class="chip-tab">Detail-Report <span class="count">1</span></div>
      <div class="chip-tab">Rechnung <span class="count">2</span></div>
      <div class="chip-tab">Spesenbeleg <span class="count">1</span></div>
      <div class="chip-tab">Korrespondenz <span class="count">0</span></div>
      <div class="chip-tab">Sonstiges <span class="count">0</span></div>
    </div>
  </div>

  <!-- Doc-Liste -->
  <div class="card" style="padding:0;overflow:hidden">
    <table class="data-table">
      <thead>
        <tr>
          <th style="width:44px"></th>
          <th>Name</th>
          <th>Kategorie</th>
          <th>Verknüpft mit Run</th>
          <th>Erstellt</th>
          <th>Urheber</th>
          <th class="right">Grösse</th>
          <th class="right">›</th>
        </tr>
      </thead>
      <tbody>
        <tr style="cursor:pointer">
          <td><span class="file-type ft-pdf">PDF</span></td>
          <td><strong>Offerte Assessment-Order ORD-2026-042</strong><div class="muted" style="font-size:11px">5 Credits · CHF 28'000 · SCHEELEN + ASSESS 5.0</div></td>
          <td><span class="chip chip-gold">Offerte (signiert)</span></td>
          <td class="muted">—</td>
          <td>01.03.2026</td>
          <td><span class="actor-chip">Upload · PW</span></td>
          <td class="right">92 KB</td>
          <td class="right"><button class="row-icon-btn">›</button></td>
        </tr>
        <tr style="cursor:pointer">
          <td><span class="file-type ft-pdf">PDF</span></td>
          <td><strong>Rechnung ORD-2026-042 Pauschale</strong><div class="muted" style="font-size:11px">RE-2026-0081 · CHF 30'268 brutto</div></td>
          <td><span class="chip chip-accent">Rechnung</span></td>
          <td class="muted">—</td>
          <td>01.03.2026</td>
          <td><span class="actor-chip">Doc-Gen</span></td>
          <td class="right">76 KB</td>
          <td class="right"><button class="row-icon-btn">›</button></td>
        </tr>
        <tr style="cursor:pointer">
          <td><span class="file-type ft-pdf">PDF</span></td>
          <td><strong>Executive Summary · Tobias Furrer · MDI</strong><div class="muted" style="font-size:11px">2-seitige Zusammenfassung</div></td>
          <td><span class="chip chip-accent">Executive Summary</span></td>
          <td><a href="#">Run r-001 · T. Furrer MDI</a></td>
          <td>04.04.2026</td>
          <td><span class="actor-chip">Upload · PW</span></td>
          <td class="right">1.2 MB</td>
          <td class="right"><button class="row-icon-btn">›</button></td>
        </tr>
        <tr style="cursor:pointer">
          <td><span class="file-type ft-pdf">PDF</span></td>
          <td><strong>Detail-Report · Tobias Furrer · MDI</strong><div class="muted" style="font-size:11px">~100 Seiten SCHEELEN-Output</div></td>
          <td><span class="chip">Detail-Report</span></td>
          <td><a href="#">Run r-001 · T. Furrer MDI</a></td>
          <td>04.04.2026</td>
          <td><span class="actor-chip">Upload · PW</span></td>
          <td class="right">2.4 MB</td>
          <td class="right"><button class="row-icon-btn">›</button></td>
        </tr>
        <tr style="cursor:pointer">
          <td><span class="file-type ft-pdf">PDF</span></td>
          <td><strong>Rechnung Spesen Q1</strong><div class="muted" style="font-size:11px">RE-2026-0094 · CHF 340 brutto</div></td>
          <td><span class="chip chip-accent">Rechnung</span></td>
          <td class="muted">—</td>
          <td>12.04.2026</td>
          <td><span class="actor-chip">Doc-Gen</span></td>
          <td class="right">42 KB</td>
          <td class="right"><button class="row-icon-btn">›</button></td>
        </tr>
        <tr style="cursor:pointer">
          <td><span class="file-type ft-img">IMG</span></td>
          <td><strong>Spesenbeleg Reise SCHEELEN Köln</strong><div class="muted" style="font-weight:400;font-size:11px">Hotel + Bahn</div></td>
          <td><span class="chip">Spesenbeleg</span></td>
          <td class="muted">—</td>
          <td>08.04.2026</td>
          <td><span class="actor-chip">Upload · PW</span></td>
          <td class="right">315 KB</td>
          <td class="right"><button class="row-icon-btn">›</button></td>
        </tr>
      </tbody>
    </table>
  </div>

  <div class="muted" style="font-size:11px;margin-top:14px;padding:10px 14px;background:var(--bg);border-radius:3px">
    Nur Dokumente dieses Assessment-Auftrags. Kandidaten-Dossiers (ARK-CV, Exposé) leben in den Kandidatenmasken. Account-weite Dokumente in der Account-Detailmaske Tab 8.
    <br><br>
    <strong>Offerten-Generierung:</strong> Geplante Migration in globalen Dok-Generator (eigenständige Detailmaske unter Workflow/Operations, Projekt nach Assessment-Mockup-Fertigstellung). Button aktuell deaktiviert.
  </div>

</div>
```

- [ ] **Step 2: Verifikation**

Grep nach fremden Scoping-Hinweisen die raus sollten:
```
Grep pattern="Scraper-Beleg|Stellenbriefing|CFO-Mandat|PL Hochbau" path="mockups/assessments.html"
```
Expected: 0 Matches in Tab-4-Bereich. Restliche Matches (Tab 1/5) ok.

---

## Task 2.3: Drawer 4 — Report-Upload (540px)

**Files:**
- Modify: `mockups/assessments.html` (nach Drawer 3)

- [ ] **Step 1: Report-Upload-Drawer einfügen**

Nach Drawer 3 (Kandidat-Ersetzen):

```html
<!-- DRAWER: Report-Upload -->
<div id="drawer-report-upload" class="drawer" style="display:none;position:fixed;inset:0;z-index:100">
  <div class="drawer-backdrop" onclick="closeDrawer('report-upload')" style="position:absolute;inset:0;background:rgba(0,0,0,0.4)"></div>
  <aside class="drawer-panel" style="position:absolute;right:0;top:0;bottom:0;width:540px;background:var(--surface);border-left:1px solid var(--border);display:flex;flex-direction:column;box-shadow:-4px 0 12px rgba(0,0,0,0.1)">

    <header class="drawer-head" style="padding:18px 22px;border-bottom:1px solid var(--border);display:flex;justify-content:space-between;align-items:center">
      <div>
        <h3 style="margin:0;font-family:'Libre Baskerville',serif;font-size:18px">Report übertragen</h3>
        <div class="muted" style="font-size:12px;margin-top:2px">Assessment-Durchführung abschliessen</div>
      </div>
      <button class="drawer-close" onclick="closeDrawer('report-upload')" style="background:none;border:none;font-size:22px;cursor:pointer;color:var(--muted)">✕</button>
    </header>

    <div class="drawer-body" style="flex:1;overflow-y:auto;padding:22px">

      <!-- Step 1: Run-Auswahl -->
      <div style="margin-bottom:22px">
        <label style="display:block;font-weight:600;margin-bottom:6px;font-size:13px">1. Run auswählen <span style="color:var(--red)">*</span></label>
        <select style="width:100%;padding:8px;border:1px solid var(--border);border-radius:2px;background:var(--surface);font-family:inherit;font-size:13px">
          <option value="">— Run wählen (nur scheduled / in_progress) —</option>
          <option value="r-003">Nadine Berger · Relief · scheduled 20.04.2026</option>
          <option value="r-002">Martin Stucki · MDI · assigned 12.04.2026</option>
        </select>
      </div>

      <!-- Step 2: Exec-Summary Pflicht -->
      <div style="margin-bottom:22px">
        <label style="display:block;font-weight:600;margin-bottom:6px;font-size:13px">2. Executive Summary PDF <span style="color:var(--red)">*</span></label>
        <div style="padding:20px;border:2px dashed var(--border);border-radius:3px;text-align:center;background:var(--bg);cursor:pointer">
          <div style="font-size:32px;color:var(--muted)">📄</div>
          <div style="font-weight:600;margin-top:6px">PDF hierher ziehen oder klicken</div>
          <div class="muted" style="font-size:11px;margin-top:4px">Pflicht · Max 10 MB</div>
        </div>
      </div>

      <!-- Step 3: Detail-Report optional -->
      <div style="margin-bottom:22px">
        <label style="display:block;font-weight:600;margin-bottom:6px;font-size:13px">3. Detail-Report PDF <span class="muted">(optional)</span></label>
        <div style="padding:16px;border:2px dashed var(--border-soft);border-radius:3px;text-align:center;background:var(--bg);cursor:pointer">
          <div style="font-size:24px;color:var(--muted)">📑</div>
          <div style="font-weight:600;margin-top:4px;font-size:13px">Optional · SCHEELEN-Anhang</div>
          <div class="muted" style="font-size:11px;margin-top:4px">Max 50 MB</div>
        </div>
      </div>

      <!-- Folge-Aktionen Preview -->
      <div style="padding:12px;background:var(--bg);border-left:3px solid var(--accent);border-radius:2px">
        <div class="muted" style="font-size:11px;font-weight:600;text-transform:uppercase;letter-spacing:0.05em;margin-bottom:6px">Nach Upload automatisch</div>
        <ul style="margin:0;padding-left:18px;font-size:12px;line-height:1.6">
          <li>Run-Status → <code>completed</code> (completed_at = jetzt)</li>
          <li>Credit-Zähler <code>used_count</code> +1 für diesen Typ</li>
          <li>Versions-Eintrag am Kandidaten-Assessment-Tab</li>
          <li>History-Event <code>assessment_run_completed</code></li>
          <li>Wenn letzter Credit: Order-Status → <code>fully_used</code></li>
        </ul>
      </div>

    </div>

    <footer class="drawer-foot" style="padding:14px 22px;border-top:1px solid var(--border);display:flex;gap:8px;justify-content:flex-end;background:var(--bg)">
      <button class="btn btn-sm" onclick="closeDrawer('report-upload')">Abbrechen</button>
      <button class="btn btn-sm btn-primary">Upload &amp; Abschliessen</button>
    </footer>

  </aside>
</div>
```

- [ ] **Step 2: Verifikation**

Grep:
```
Grep pattern="drawer-report-upload" path="mockups/assessments.html"
```
Expected: ≥2 Matches (Drawer-Def + ≥2 Trigger-Buttons im Header/Tab-4).

---

## Task 2.4: Drift-Check + Lint + Commit P2

- [ ] **Step 1: Drift + Lint**

```
Skill: ark-lint args="mockups/assessments.html"
Skill: mockup-drift-check args="mockups/assessments.html"
```

- [ ] **Step 2: Browser-Test**

- Tab 3: 2 Billing-Zeilen (full + expense), Status-Legende, Info-Box zum Auto-Trigger
- Tab 4: 6 Dokumente (alle Order-gescoped), keine fremden Scraper/Stellenbriefing-Einträge
- Klick "📤 Report übertragen" → Drawer 4 öffnet, 3 Steps + Auto-Aktionen-Preview

- [ ] **Step 3: Commit P2**

```bash
cd "C:/ARK CRM"
git add mockups/assessments.html backups/assessments.html.*-p2.bak
git commit -m "$(cat <<'EOF'
feat(mockup): Assessment-Detailmaske Phase 2 — Billing/Docs/Report-Upload

Tab 3 Billing: full + expense Zeilen, Status-Legende, Auto-Trigger-Info.
Tab 4 Dokumente: Order-scoped (Offerte/Exec-Summary/Detail-Report/Rechnung/
Spesenbeleg/Korrespondenz/Sonstiges), fremde Account-weite Doc-Liste entfernt.
Offerten-Generator-CTA als Platzhalter fuer globalen Dok-Generator.
Drawer 4 Report-Upload (540px) mit Run-Auswahl + Exec-Summary/Detail-Report
Upload + Folge-Aktionen-Preview.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
git push
```

---

# PHASE 3 — History + Polish

**Ziel:** Tab 5 Order-scopen, Polish, Cancellation-Dialog.
**Zielumfang P3:** ~+300 Zeilen (2'335 → ~2'635).

---

## Task 3.0: Backup P3

- [ ] **Step 1: Backup**

```bash
cp "mockups/assessments.html" "backups/assessments.html.$(date +%Y-%m-%d-%H%M)-p3.bak"
```

---

## Task 3.1: Tab 5 History — Order-Scope + Filter

**Files:**
- Modify: `mockups/assessments.html` Tab 5 (bestehende Zeilen ~386–625)

- [ ] **Step 1: History-Block komplett ersetzen**

Von `<!-- TAB 5 · HISTORY -->` bis zum schliessenden `</div>` des Tab-Panels durch diesen Order-Scoped-Block ersetzen:

```html
<!-- TAB 5 · HISTORY (Order-scoped) -->
<div id="tab-5" class="tab-panel">

  <!-- Filter-Bar -->
  <div class="filter-bar">
    <input type="search" placeholder="🔍 Kandidat, Event, Akteur …" style="flex:1 1 280px">
    <select>
      <option>Alle Kategorien</option>
      <option>Assessment</option>
      <option>Emailverkehr</option>
      <option>Kontaktberührung</option>
      <option>System</option>
    </select>
    <select>
      <option>Alle Kandidaten (im Order beteiligt)</option>
      <option>Tobias Furrer</option>
      <option>Martin Stucki</option>
      <option>Nadine Berger</option>
    </select>
    <select>
      <option>Alle Akteure</option>
      <option>PW</option><option>JV</option><option>LR</option>
      <option>— System —</option>
    </select>
    <select>
      <option>Letzte 90 Tage</option>
      <option>Letzte 30 Tage</option>
      <option>Alles</option>
    </select>
    <span class="spacer"></span>
    <button class="btn btn-sm">↓ Export</button>
  </div>

  <div class="filter-bar" style="padding-top:0">
    <div class="chip-group">
      <div class="chip-tab active">Alle <span class="count">12</span></div>
      <div class="chip-tab">Assessment <span class="count">8</span></div>
      <div class="chip-tab">Emailverkehr <span class="count">2</span></div>
      <div class="chip-tab">System <span class="count">2</span></div>
    </div>
  </div>

  <div class="card" style="padding:24px 28px">
    <div class="hist-timeline">

      <div class="hist-day">
        <div class="hist-day-head">Heute · 14.04.2026</div>
        <div class="hist-row">
          <div class="hist-time">09:20</div>
          <div class="hist-cat"><span class="hist-cat-chip cat-assessment">Assessment</span></div>
          <div class="hist-body">
            <div class="hist-title"><strong>MDI-Credit zugewiesen · Martin Stucki</strong></div>
            <div class="hist-sub">Typ MDI · Run r-002 · kein Termin gesetzt. Ergänzung zu bereits laufendem MDI-Run Furrer.</div>
            <div class="hist-meta"><span class="actor">PW</span> · <a href="candidates.html">Kandidat · M. Stucki</a></div>
          </div>
        </div>
      </div>

      <div class="hist-day">
        <div class="hist-day-head">05.04.2026</div>
        <div class="hist-row">
          <div class="hist-time">14:12</div>
          <div class="hist-cat"><span class="hist-cat-chip cat-assessment">Assessment</span></div>
          <div class="hist-body">
            <div class="hist-title"><strong>Relief-Termin gesetzt · Nadine Berger</strong></div>
            <div class="hist-sub">Run r-003 · Termin 20.04.2026 10:00 · Status assigned → scheduled.</div>
            <div class="hist-meta"><span class="actor">PW</span> · <a href="candidates.html">Kandidat · N. Berger</a></div>
          </div>
        </div>
      </div>

      <div class="hist-day">
        <div class="hist-day-head">04.04.2026</div>
        <div class="hist-row">
          <div class="hist-time">16:42</div>
          <div class="hist-cat"><span class="hist-cat-chip cat-assessment">Assessment</span></div>
          <div class="hist-body">
            <div class="hist-title"><strong>MDI · Report erhalten · Tobias Furrer</strong></div>
            <div class="hist-sub">Exec-Summary + Detail-Report hochgeladen. Run r-001 → completed. used_count MDI: 0→1. Versions-Eintrag v1 am Kandidaten angelegt.</div>
            <div class="hist-meta"><span class="actor">PW</span> · <a href="candidates.html">Kandidat · T. Furrer</a> · Run r-001</div>
          </div>
        </div>
      </div>

      <div class="hist-day">
        <div class="hist-day-head">02.04.2026</div>
        <div class="hist-row">
          <div class="hist-time">11:30</div>
          <div class="hist-cat"><span class="hist-cat-chip cat-assessment">Assessment</span></div>
          <div class="hist-body">
            <div class="hist-title"><strong>MDI-Credit zugewiesen · Tobias Furrer</strong></div>
            <div class="hist-sub">Typ MDI · Termin 03.04.2026 10:00 (SCHEELEN) · Status scheduled.</div>
            <div class="hist-meta"><span class="actor">PW</span> · <a href="candidates.html">Kandidat · T. Furrer</a></div>
          </div>
        </div>
      </div>

      <div class="hist-day">
        <div class="hist-day-head">15.03.2026</div>
        <div class="hist-row hist-ok">
          <div class="hist-time">15:30</div>
          <div class="hist-cat"><span class="hist-cat-chip cat-system">System</span></div>
          <div class="hist-body">
            <div class="hist-title"><strong>✅ Rechnung bezahlt · RE-2026-0081</strong></div>
            <div class="hist-sub">CHF 30'268 brutto verbucht · 14 Tage nach Rechnungsdatum.</div>
            <div class="hist-meta"><span class="actor">SYS</span> · Zahlung automatisch erkannt</div>
          </div>
        </div>
      </div>

      <div class="hist-day">
        <div class="hist-day-head">01.03.2026</div>
        <div class="hist-row">
          <div class="hist-time">10:00</div>
          <div class="hist-cat"><span class="hist-cat-chip cat-assessment">Assessment</span></div>
          <div class="hist-body">
            <div class="hist-title"><strong>Assessment-Order ORD-2026-042 signiert</strong></div>
            <div class="hist-sub">5 Credits (2× MDI, 1× Relief, 1× ASSESS 5.0, 1× EQ) · CHF 28'000 netto. Rechnung RE-2026-0081 automatisch erstellt und auf "fällig" gesetzt.</div>
            <div class="hist-meta"><span class="actor">PW</span> · Order-Status Offered → Ordered</div>
          </div>
        </div>
      </div>

    </div>
  </div>

  <div class="muted" style="font-size:11px;margin-top:14px;padding:10px 14px;background:var(--bg);border-radius:3px">
    Order-scoped History: nur Events dieses Assessment-Auftrags und seiner Runs/Billing/Docs. Account-weite History in Account-Detailmaske Tab 9.
  </div>

</div>
```

- [ ] **Step 2: Verifikation**

Grep:
```
Grep pattern="Order-scoped" path="mockups/assessments.html"
```
Expected: ≥1 Match.

Grep nach Account-weiten Events die raus müssen:
```
Grep pattern="Taskforce PL Hochbau|CV Sent|Update-Call|Schutzfrist Claim" path="mockups/assessments.html"
```
Expected: 0 Matches in Tab 5.

---

## Task 3.2: Keyboard-Hints-Bar komplettieren

**Files:**
- Modify: `mockups/assessments.html` (kb-bar am Dateiende)

- [ ] **Step 1: KB-Bar ersetzen**

Bestehende `<div class="kb-bar">` (Zeilen ~629–634) durch vollständige Version ersetzen:

```html
<div class="kb-bar">
  <span><kbd>1</kbd>–<kbd>5</kbd> Tabs</span>
  <span><kbd>Z</kbd> Credit zuweisen</span>
  <span><kbd>R</kbd> Report übertragen</span>
  <span><kbd>G</kbd> Offerte generieren</span>
  <span><kbd>E</kbd> Edit-Mode (vor Ordered)</span>
  <span><kbd>Esc</kbd> Drawer schliessen</span>
  <span><kbd>T</kbd> Theme</span>
  <span style="margin-left:auto"><kbd>⌘K</kbd> Suche</span>
</div>
```

- [ ] **Step 2: Hotkey-Binding JS**

Im `<script>`-Block am Dateiende ergänzen:

```js
document.addEventListener('keydown', e => {
  if (e.target.matches('input, textarea, select')) return;
  if (e.key >= '1' && e.key <= '5') { switchTab(parseInt(e.key)); return; }
  const map = { 'z':'credit-assign', 'r':'report-upload' };
  if (map[e.key.toLowerCase()]) openDrawer(map[e.key.toLowerCase()]);
});
```

---

## Task 3.3: Cancellation-Dialog + restliche Empty-States

**Files:**
- Modify: `mockups/assessments.html` (neuer Dialog + Tab 3/4 Empty-States)

- [ ] **Step 1: Cancellation-Confirm-Drawer**

Nach Drawer 4 (Report-Upload), als 5. Drawer:

```html
<!-- DRAWER: Order stornieren -->
<div id="drawer-cancel-order" class="drawer" style="display:none;position:fixed;inset:0;z-index:102">
  <div class="drawer-backdrop" onclick="closeDrawer('cancel-order')" style="position:absolute;inset:0;background:rgba(0,0,0,0.5)"></div>
  <aside class="drawer-panel" style="position:absolute;right:0;top:0;bottom:0;width:540px;background:var(--surface);border-left:3px solid var(--red);display:flex;flex-direction:column;box-shadow:-4px 0 12px rgba(0,0,0,0.15)">

    <header class="drawer-head" style="padding:18px 22px;border-bottom:1px solid var(--border);display:flex;justify-content:space-between;align-items:center">
      <div>
        <h3 style="margin:0;font-family:'Libre Baskerville',serif;font-size:18px;color:var(--red)">⚠ Auftrag stornieren</h3>
        <div class="muted" style="font-size:12px;margin-top:2px">ORD-2026-042 · irreversibel</div>
      </div>
      <button class="drawer-close" onclick="closeDrawer('cancel-order')" style="background:none;border:none;font-size:22px;cursor:pointer;color:var(--muted)">✕</button>
    </header>

    <div class="drawer-body" style="flex:1;overflow-y:auto;padding:22px">

      <div style="padding:14px;background:color-mix(in srgb, var(--red) 10%, var(--surface));border-left:3px solid var(--red);border-radius:2px;margin-bottom:20px">
        <strong>Diese Aktion ist irreversibel.</strong>
        <ul style="margin:8px 0 0;padding-left:18px;font-size:12px;line-height:1.6">
          <li>Alle offenen Runs (<strong>3</strong>) werden auf <code>cancelled_reassignable</code> gesetzt</li>
          <li>Abgeschlossene Runs (<strong>1</strong>) bleiben erhalten</li>
          <li><strong>Kein automatischer Refund</strong> des bezahlten Betrags (CHF 30'268). Kulanz-Entscheidung durch Admin manuell.</li>
          <li>History-Event <code>assessment_order_cancelled</code> wird geloggt</li>
        </ul>
      </div>

      <div style="margin-bottom:16px">
        <label style="display:block;font-weight:600;margin-bottom:6px;font-size:13px">Begründung <span style="color:var(--red)">*</span></label>
        <textarea rows="4" style="width:100%;padding:6px 8px;border:1px solid var(--border);border-radius:2px;background:var(--surface);font-family:inherit;font-size:12px" placeholder="Pflicht — Begründung für Audit-Log …"></textarea>
      </div>

      <div style="margin-bottom:16px">
        <label style="display:flex;gap:8px;align-items:center;font-size:13px">
          <input type="checkbox"> Ich bestätige, dass der Kunde über die Nicht-Refund-Regelung informiert wurde.
        </label>
      </div>

    </div>

    <footer class="drawer-foot" style="padding:14px 22px;border-top:1px solid var(--border);display:flex;gap:8px;justify-content:flex-end;background:var(--bg)">
      <button class="btn btn-sm" onclick="closeDrawer('cancel-order')">Abbrechen</button>
      <button class="btn btn-sm" style="background:var(--red);color:white;border-color:var(--red)">Auftrag endgültig stornieren</button>
    </footer>

  </aside>
</div>
```

- [ ] **Step 2: Empty-States für Tab 3 + Tab 4**

In Tab 3 vor `</div>` tab-panel (falls noch nicht in Task 2.1 enthalten — check):

```html
<div class="empty-state-inline" style="display:none;padding:40px;text-align:center;background:var(--bg);border:1px dashed var(--border);border-radius:3px;margin-top:14px">
  <div style="font-size:32px;margin-bottom:8px">💰</div>
  <div style="font-weight:600;margin-bottom:4px">Noch keine Rechnungen</div>
  <div class="muted" style="font-size:12px">Hauptrechnung wird automatisch erstellt sobald Offerte signiert hochgeladen wird.</div>
</div>
```

In Tab 4 analog:
```html
<div class="empty-state-inline" style="display:none;padding:40px;text-align:center;background:var(--bg);border:1px dashed var(--border);border-radius:3px;margin-top:14px">
  <div style="font-size:32px;margin-bottom:8px">📄</div>
  <div style="font-weight:600;margin-bottom:4px">Noch keine Dokumente</div>
  <div class="muted" style="font-size:12px">Offerten werden über den Dok-Generator erstellt. Reports via "Report übertragen".</div>
</div>
```

---

## Task 3.4: Final Drift + Lint + Commit P3 + Push

- [ ] **Step 1: Full lint + drift**

```
Skill: ark-lint args="mockups/assessments.html"
Skill: ark-drift-scan args="L3"
Skill: mockup-drift-check args="mockups/assessments.html"
```
Expected: alle grün.

- [ ] **Step 2: Browser-Test Kompletter Durchgang**

- Hotkeys: `1`–`5` switchen Tabs, `Z` öffnet Credit-Zuweisungs-Drawer, `R` öffnet Report-Upload, `Esc` schliesst
- Status-Dropdown ohne `Invoiced`, Cancelled öffnet Cancel-Order-Drawer mit Begründungs-Pflicht
- Tab 5 zeigt nur Order-Events (6 Einträge), keine Account-weiten Events
- Keyboard-Hints-Bar zeigt alle 8 Hints

- [ ] **Step 3: Commit P3**

```bash
cd "C:/ARK CRM"
git add mockups/assessments.html backups/assessments.html.*-p3.bak
git commit -m "$(cat <<'EOF'
feat(mockup): Assessment-Detailmaske Phase 3 — History/Polish/Cancel

Tab 5 History Order-scoped (nur Events dieses Orders, Kategorien reduziert,
Filter fuer beteiligte Kandidaten). Keyboard-Hints-Bar komplett mit
Hotkey-Bindings (1-5 Tabs, Z Credit, R Report, Esc Drawer). Drawer 5
Cancel-Order mit Begruendungs-Pflicht + Refund-Hinweis. Empty-States
Tab 3 und Tab 4 final.

Assessment-Detailmaske jetzt v0.2-parity (bis auf Spec-Sync-Deltas
Invoiced-Status / Typen-Phase-1 / Dok-Generator-Migration).

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
git push
```

- [ ] **Step 4: Spec-Sync-Delta dokumentieren**

Erstelle Follow-up-Task-Datei (NICHT commiten — eigener Prozess):

```
Grundlagen MD/changelog-assessment-v0_3.md (TODO für späteren Sync)
```

Eintrag:
- Spec v0.2 → v0.3: `invoiced` Status entfernen in Schema §4.1 + Interactions §TEIL 1
- Phase-1-Kommentar zu Typen-Katalog §0
- Offerten-Generator in §8.3 als migriert-zu-Dok-Generator markieren

Dies ist Folge-Task, **kein Teil dieses Implementation-Plans**.

---

# Self-Review

## 1. Spec-Coverage-Check

| Spec-Anforderung | Task | Status |
|------------------|------|--------|
| Snapshot-Bar 7 Slots (§4.3) | T1.0 | ✓ |
| Credit-Progress-Bar multi-stacked (§4.3) | T1.1 | ✓ |
| Quick-Actions mit Sichtbarkeit (§4.4) | T1.2 | ✓ (statisch, JS-Bedingungen dokumentiert) |
| Breadcrumb-Konditional (§3) | T1.2 | ✓ |
| Status-Dropdown ohne Invoiced (§TEIL 1 + User-Feedback) | T1.2 | ✓ |
| Tab 1 Credits typisiert §5.2 Sektion 2 | T1.3 | ✓ (4 Phase-1-Typen) |
| Tab 1 "+ Weiteren Typ" §5.2 | T1.3 | ✓ |
| Tab 1 Sektion 4 Status & Abschluss | T1.4 | ✓ |
| Tab 1 Sektion 5 Verknüpfungen | T1.5 | ✓ |
| Tab 2 Filter Multi-Select §6.1 | T1.6 | ✓ |
| Tab 2 Empty-State §6.7 | T1.6 | ✓ |
| Credit-Zuweisungs-Drawer §6.5 | T1.7 | ✓ |
| Run-Drawer §6.4 | T1.8 | ✓ |
| Kandidat-Ersetzen-Drawer §6.6 | T1.9 | ✓ |
| Tab 3 Billing §7 | T2.1 | ✓ (full + expense, Status-Legende) |
| Tab 3 Empty-State §7.6 | T3.3 | ✓ |
| Tab 4 Order-scoped §8.1 | T2.2 | ✓ |
| Offerten-Generator §8.3 | T2.2 | ✓ (als Platzhalter → Dok-Generator) |
| Report-Upload-Drawer §8.4 | T2.3 | ✓ |
| Tab 5 History §9 | T3.1 | ✓ (Order-scoped) |
| Keyboard-Hints §10 | T3.2 | ✓ |
| Cancellation §TEIL 1 | T3.3 | ✓ |
| Backup-Regel | T1.0/T2.0/T3.0 | ✓ |

**Lücken:** Status-Dropdown JS-Auto-Transitions (Ordered→Partially/Fully Used bei used_count-Updates) — Mockup zeigt nur "aktueller Status", automatische Transitions werden im React-Port implementiert. Dokumentiert via Kommentar im Status-Menu-Block.

## 2. Placeholder-Scan

Kein TBD/TODO in Plan, keine "implement later"-Stellen. Alle HTML-Blöcke vollständig. Verifikations-Steps mit konkreten Grep-Patterns.

## 3. Type/Name-Konsistenz

- Drawer-Namen: `credit-assign` · `run-detail` · `candidate-replace` · `report-upload` · `cancel-order` — konsistent über alle Tasks
- Typen-Keys: `mdi` · `relief` · `assess_5_0` · `eq` — konsistent mit Stammdaten §51
- Order-Status-Werte: `offered` · `ordered` · `partially_used` · `fully_used` · `cancelled` — konsistent (kein `invoiced`)
- Run-Status: `assigned` · `scheduled` · `in_progress` · `completed` · `cancelled_reassignable` — konsistent mit Spec §6.3

Keine Inkonsistenzen gefunden.

---

# Execution Handoff

Plan komplett und gespeichert. **Zwei Optionen:**

1. **Subagent-Driven (empfohlen)** — pro Task frischer Subagent, Review zwischen Tasks, schnelle Iteration
2. **Inline Execution** — Tasks in dieser Session über `executing-plans`, Batch mit Checkpoints

Welche?
