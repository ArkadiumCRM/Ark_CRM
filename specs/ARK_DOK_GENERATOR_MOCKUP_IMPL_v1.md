# Dok-Generator Mockup — Implementation Plan v1

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans. Steps use checkbox (`- [ ]`) syntax.

**Goal:** Globalen Dok-Generator als Mockup `mockups/dok-generator.html` (~1'800-2'200 Zeilen) unter `/operations/dok-generator`, mit 42-Template-Katalog, 5-Step-Workflow, WYSIWYG-Editor (Pattern aus Kandidat-Tab-9), Deep-Link-Integration.

**Architecture:** Single-file HTML mockup, erbt `mockups/_shared/editorial.css` + `layout.js`, kein neues CSS-File. WYSIWYG-Editor-Styles kopiert/generalisiert aus `mockups/candidates.html` Tab 9. Seed-Daten hardcoded, 5 Templates mit realem Content, 37 als Library-Cards.

**Tech Stack:** HTML5 · Editorial CSS · Vanilla JS · A4-Canvas mit ARKADIUM-Branding (navy #1a2540, gold #b99a5a) · keine Build-Pipeline

**Quell-Plan:** [specs/ARK_DOK_GENERATOR_MOCKUP_PLAN.md](ARK_DOK_GENERATOR_MOCKUP_PLAN.md)
**Design-Referenz:** `mockups/candidates.html` Tab 9 (Zeilen ~3738-4500)
**Template-Quellen:** `raw/General/` + `raw/Assessments/`

---

## File Structure

**Created:**
- `mockups/dok-generator.html` — Hauptdatei (~2'000 Zeilen final)
- `backups/dok-generator.html.<TS>-p1.bak` (leer-Backup dient Protokoll)
- `backups/dok-generator.html.<TS>-p2.bak`
- `backups/dok-generator.html.<TS>-p3.bak`

**Modified (Deep-Link-Anbindung):**
- `mockups/mandates.html` — Quick-Action "Mandat-Offerte generieren" → Deep-Link `?template=mandat_offerte_<type>&entity=mandate:uuid`
- `mockups/assessments.html` — bestehender "Offerte generieren"-Platzhalter auf echten Deep-Link
- `mockups/candidates.html` Tab 9 — Banner "Wechseln zu global Dok-Generator →"

**Keine** neuen CSS-Files, keine neue `_shared/` Komponenten.

---

## Gemeinsame Patterns

### Step-Indicator
```html
<div class="step-indicator" style="display:flex;gap:0;align-items:center;padding:14px 28px;background:var(--surface);border-bottom:1px solid var(--border)">
  <div class="step active" data-step="1">
    <span class="step-num">1</span> Template
  </div>
  <div class="step-sep">→</div>
  <div class="step" data-step="2"><span class="step-num">2</span> Entity</div>
  <div class="step-sep">→</div>
  <div class="step" data-step="3"><span class="step-num">3</span> Ausfüllen</div>
  <div class="step-sep">→</div>
  <div class="step" data-step="4"><span class="step-num">4</span> Preview</div>
  <div class="step-sep">→</div>
  <div class="step" data-step="5"><span class="step-num">5</span> Ablage</div>
</div>
```

### Template-Card
```html
<div class="tpl-card" data-template-key="<key>" data-category="<cat>" onclick="selectTemplate('<key>')">
  <div class="tpl-icon">📄</div>
  <div class="tpl-name">Display Name</div>
  <div class="tpl-meta muted">Target-Entity · Zuletzt: DD.MM</div>
</div>
```

### Step-Navigation JS
```js
let currentStep = 1;
let currentTemplate = null;
let currentEntity = null;

function goToStep(n) {
  document.querySelectorAll('.step').forEach(s => s.classList.toggle('active', parseInt(s.dataset.step) <= n));
  document.querySelectorAll('.step-pane').forEach(p => p.style.display = parseInt(p.dataset.step) === n ? 'block' : 'none');
  currentStep = n;
}
function selectTemplate(key) { currentTemplate = key; goToStep(2); }
function selectEntity(id) { currentEntity = id; goToStep(3); }
```

### Verifikation pro Task
- `Read` der modifizierten Stelle
- Playwright-Navigation auf `http://localhost:8765/mockups/dok-generator.html` (via temporärem Python-HTTP-Server)
- Screenshot + Konsole-Check
- Pro Phase-Ende: `ark-lint` Skill

---

# PHASE 1 — Page-Layout + Template-Library + Workflow-Steps

**Ziel:** Seite lädt, alle 5 Workflow-Steps navigierbar, alle 42 Templates sichtbar, Entity-Picker grundfunktional.
**Zielumfang:** ~1'400 Zeilen.

---

## Task 1.0: Datei-Skeleton + Backup

**Files:**
- Create: `mockups/dok-generator.html`
- Create: `backups/dok-generator.html.<TS>-p1.bak`

- [ ] **Step 1: Datei anlegen mit Grundgerüst**

Write-Tool für `mockups/dok-generator.html`:

```html
<!DOCTYPE html>
<html lang="de" data-theme="light">
<head>
<meta charset="UTF-8">
<title>ARK CRM — Operations / Dok-Generator</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Libre+Baskerville:wght@400;700&family=DM+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
<link rel="stylesheet" href="_shared/editorial.css">
<style>
/* Dok-Generator-Scope Styles — werden in Task 1.5 erweitert */
.step-indicator { display:flex;gap:0;align-items:center;padding:14px 28px;background:var(--surface);border-bottom:1px solid var(--border);font-size:13px }
.step { display:flex;gap:8px;align-items:center;padding:6px 14px;color:var(--text-light);font-weight:500 }
.step.active { color:var(--accent);font-weight:600 }
.step-num { width:22px;height:22px;border-radius:50%;background:var(--border-soft);color:var(--text-light);display:inline-flex;align-items:center;justify-content:center;font-size:11px;font-weight:700 }
.step.active .step-num { background:var(--accent);color:var(--surface) }
.step-sep { color:var(--border-strong);margin:0 2px }
.doc-main-wrap { display:grid;grid-template-columns:280px 1fr;gap:0;min-height:calc(100vh - 250px) }
.doc-sidebar { background:var(--surface);border-right:1px solid var(--border);padding:16px 14px;overflow-y:auto }
.doc-main { padding:20px 28px;overflow-y:auto }
.tpl-grid { display:grid;grid-template-columns:repeat(auto-fill, minmax(220px,1fr));gap:14px;margin-top:14px }
.tpl-card { background:var(--surface);border:1px solid var(--border);border-radius:3px;padding:14px;cursor:pointer;transition:0.15s }
.tpl-card:hover { border-color:var(--accent);box-shadow:0 2px 8px rgba(0,0,0,0.06) }
.tpl-icon { font-size:24px;margin-bottom:6px }
.tpl-name { font-weight:600;font-size:13px;margin-bottom:4px;line-height:1.3 }
.tpl-meta { font-size:11px;color:var(--text-light) }
.tpl-card.soon { opacity:0.55;cursor:not-allowed }
.tpl-card.soon::after { content:"🟡 Template ausstehend";position:absolute;top:4px;right:6px;font-size:9px;color:var(--amber) }
.step-pane { display:none }
.step-pane.active { display:block }
.sidebar-cat { margin-bottom:14px }
.sidebar-cat-head { font-size:10px;text-transform:uppercase;letter-spacing:0.08em;font-weight:600;color:var(--text-light);margin-bottom:6px }
.sidebar-cat-item { padding:6px 10px;font-size:12px;border-radius:2px;cursor:pointer;display:flex;justify-content:space-between }
.sidebar-cat-item:hover { background:var(--bg) }
.sidebar-cat-item.active { background:var(--accent-soft);color:var(--accent);font-weight:600 }
.sidebar-cat-count { color:var(--text-light);font-size:11px }
</style>
</head>
<body>

<header class="header">
  <div class="header-brand">
    <div class="logo-mark">A</div>
    <div class="brand-text">
      <div class="brand-name">ARKADIUM</div>
      <div class="brand-sub">CRM · Operations</div>
    </div>
  </div>
  <div class="breadcrumb">
    <a href="crm.html">Home</a><span class="sep">/</span>
    <a href="#">Operations</a><span class="sep">/</span>
    <span class="current">Dok-Generator</span>
  </div>
  <div class="header-right">
    <span class="cmd-hint">⌘K</span>
    <button class="theme-toggle" onclick="toggleTheme()" id="themeBtn">☀</button>
  </div>
</header>

<div class="page-banner" style="padding:20px 28px">
  <div style="display:flex;align-items:baseline;gap:14px;flex-wrap:wrap">
    <h1 style="margin:0;font-family:'Libre Baskerville',serif;font-size:26px;color:var(--accent)">📝 Dok-Generator</h1>
    <span class="muted">42 Templates · 23 heute generiert · 312 YTD · 14 Entwürfe offen</span>
    <span class="spacer"></span>
    <button class="btn btn-sm btn-primary" onclick="goToStep(1)">+ Neues Dokument</button>
  </div>
</div>

<!-- STEP INDICATOR (wird in Task 1.1 gefüllt) -->
<div id="step-indicator-wrap"></div>

<!-- MAIN LAYOUT (wird in Task 1.2 + 1.3+ gefüllt) -->
<div class="doc-main-wrap">
  <aside class="doc-sidebar" id="docSidebar"></aside>
  <main class="doc-main" id="docMain"></main>
</div>

<!-- KB-Hints -->
<div class="kb-bar">
  <span><kbd>←</kbd><kbd>→</kbd> Step</span>
  <span><kbd>Ctrl+S</kbd> Save</span>
  <span><kbd>Ctrl+Enter</kbd> Generate</span>
  <span><kbd>Esc</kbd> Abbrechen</span>
  <span style="margin-left:auto"><kbd>⌘K</kbd> Suche</span>
</div>

<script src="_shared/layout.js"></script>
<script>
/* Workflow-State */
let currentStep = 1;
let currentTemplate = null;
let currentEntity = null;

function goToStep(n) { /* impl in Task 1.8 */ currentStep = n; }
function selectTemplate(key) { currentTemplate = key; goToStep(2); }
function selectEntity(id) { currentEntity = id; goToStep(3); }
</script>
</body>
</html>
```

- [ ] **Step 2: Backup-File anlegen**

Bash:
```bash
TS=$(date +%Y-%m-%d-%H%M)
touch "/c/ARK CRM/backups/dok-generator.html.${TS}-init-p1.bak"
cp "/c/ARK CRM/mockups/dok-generator.html" "/c/ARK CRM/backups/dok-generator.html.${TS}-p1.bak"
```

- [ ] **Step 3: Verifikation**

Grep:
```
Grep pattern="doc-main-wrap|step-indicator" path="mockups/dok-generator.html"
```
Expected: ≥2 Matches.

---

## Task 1.1: Step-Indicator populieren

**Files:**
- Modify: `mockups/dok-generator.html` (ersetzt `<div id="step-indicator-wrap"></div>`)

- [ ] **Step 1: Step-Indicator HTML einfügen**

Edit:
```html
<!-- old: <div id="step-indicator-wrap"></div> -->
<!-- new: -->
<div class="step-indicator">
  <div class="step active" data-step="1">
    <span class="step-num">1</span>
    <span>Template</span>
  </div>
  <div class="step-sep">→</div>
  <div class="step" data-step="2">
    <span class="step-num">2</span>
    <span>Entity</span>
  </div>
  <div class="step-sep">→</div>
  <div class="step" data-step="3">
    <span class="step-num">3</span>
    <span>Ausfüllen</span>
  </div>
  <div class="step-sep">→</div>
  <div class="step" data-step="4">
    <span class="step-num">4</span>
    <span>Preview</span>
  </div>
  <div class="step-sep">→</div>
  <div class="step" data-step="5">
    <span class="step-num">5</span>
    <span>Ablage</span>
  </div>
  <span class="spacer" style="flex:1"></span>
  <div style="display:flex;gap:6px">
    <button class="btn btn-sm" disabled id="btnPrev" onclick="goToStep(currentStep-1)">← Zurück</button>
    <button class="btn btn-sm btn-primary" id="btnNext" onclick="goToStep(currentStep+1)">Weiter →</button>
  </div>
</div>
```

- [ ] **Step 2: Verifikation**

Playwright-Navigation + Screenshot → Step-Indicator mit 5 Steps sichtbar, Step 1 aktiv (gold), Buttons rechts.

---

## Task 1.2: Sidebar mit Kategorien + Quick-Filter + Suche

**Files:**
- Modify: `mockups/dok-generator.html` (inhalt von `<aside class="doc-sidebar">`)

- [ ] **Step 1: Sidebar-HTML einfügen**

Edit ersetzt `<aside class="doc-sidebar" id="docSidebar"></aside>`:

```html
<aside class="doc-sidebar" id="docSidebar">

  <div style="margin-bottom:14px">
    <input type="search" id="tplSearch" placeholder="🔍 Template suchen …" style="width:100%;padding:7px 10px;border:1px solid var(--border);border-radius:2px;background:var(--surface);font-size:12px;font-family:inherit">
  </div>

  <div class="sidebar-cat">
    <div class="sidebar-cat-head">Kategorien</div>
    <div class="sidebar-cat-item active" data-cat="all"><span>Alle</span><span class="sidebar-cat-count">42</span></div>
    <div class="sidebar-cat-item" data-cat="mandat_offerte"><span>Mandat-Offerten</span><span class="sidebar-cat-count">4</span></div>
    <div class="sidebar-cat-item" data-cat="mandat_rechnung"><span>Mandat-Rechnungen</span><span class="sidebar-cat-count">10</span></div>
    <div class="sidebar-cat-item" data-cat="best_effort"><span>Erfolgsbasis</span><span class="sidebar-cat-count">8</span></div>
    <div class="sidebar-cat-item" data-cat="assessment"><span>Assessment</span><span class="sidebar-cat-count">3</span></div>
    <div class="sidebar-cat-item" data-cat="rueckerstattung"><span>Rückerstattung</span><span class="sidebar-cat-count">1</span></div>
    <div class="sidebar-cat-item" data-cat="kandidat"><span>Kandidat</span><span class="sidebar-cat-count">5</span></div>
    <div class="sidebar-cat-item" data-cat="brief"><span>Briefe & Guides</span><span class="sidebar-cat-count">4</span></div>
    <div class="sidebar-cat-item" data-cat="reporting"><span>Reportings</span><span class="sidebar-cat-count">7</span></div>
  </div>

  <div class="sidebar-cat">
    <div class="sidebar-cat-head">Quick-Filter</div>
    <div class="sidebar-cat-item" data-filter="recent"><span>Zuletzt genutzt</span><span class="sidebar-cat-count">8</span></div>
    <div class="sidebar-cat-item" data-filter="drafts"><span>Entwürfe</span><span class="sidebar-cat-count">14</span></div>
    <div class="sidebar-cat-item" data-filter="kunde"><span>Kunde-facing</span><span class="sidebar-cat-count">23</span></div>
    <div class="sidebar-cat-item" data-filter="intern"><span>Intern</span><span class="sidebar-cat-count">14</span></div>
  </div>

  <div class="sidebar-cat">
    <div class="sidebar-cat-head">Zuletzt generiert</div>
    <div style="font-size:11px;line-height:1.5">
      <div style="padding:4px 0;border-bottom:1px dashed var(--border-soft)"><strong>RE-2026-0094</strong> · Rechnung Spesen<div class="muted" style="font-size:10px">12.04.2026 · PW</div></div>
      <div style="padding:4px 0;border-bottom:1px dashed var(--border-soft)"><strong>Offerte Bauherr AG</strong><div class="muted" style="font-size:10px">08.04.2026 · MF</div></div>
      <div style="padding:4px 0"><strong>ARK-CV T. Furrer v3</strong><div class="muted" style="font-size:11px">02.04.2026 · JV</div></div>
    </div>
  </div>

</aside>
```

- [ ] **Step 2: Verifikation**

Grep `pattern="sidebar-cat-item.*Mandat"` → ≥3 Matches.

---

## Task 1.3: Step 1 Template-Grid (42 Templates als Cards)

**Files:**
- Modify: `mockups/dok-generator.html` (inhalt von `<main class="doc-main">`)

- [ ] **Step 1: Step-Panes anlegen (alle 5, nur Step 1 sichtbar)**

Edit ersetzt `<main class="doc-main" id="docMain"></main>`:

```html
<main class="doc-main" id="docMain">

  <!-- STEP 1: TEMPLATE WÄHLEN -->
  <div class="step-pane active" data-step="1">
    <div style="margin-bottom:10px">
      <h2 style="margin:0 0 4px;font-family:'Libre Baskerville',serif;font-size:18px">Template wählen</h2>
      <div class="muted" style="font-size:12px">42 Templates · Category-Filter in Sidebar</div>
    </div>

    <div class="tpl-grid" id="tplGrid">
      <!-- populated by Task 1.3 Step 2 -->
    </div>
  </div>

  <!-- STEP 2: ENTITY WÄHLEN -->
  <div class="step-pane" data-step="2">
    <!-- populated by Task 1.4 -->
  </div>

  <!-- STEP 3: AUSFÜLLEN (WYSIWYG) -->
  <div class="step-pane" data-step="3">
    <!-- populated by Task 1.5 -->
  </div>

  <!-- STEP 4: PREVIEW -->
  <div class="step-pane" data-step="4">
    <!-- populated by Task 1.6 -->
  </div>

  <!-- STEP 5: ABLAGE -->
  <div class="step-pane" data-step="5">
    <!-- populated by Task 1.7 -->
  </div>

</main>
```

- [ ] **Step 2: 42 Template-Cards inside #tplGrid einfügen**

Edit in `<div class="tpl-grid" id="tplGrid">` — alle 42 Templates laut Plan §1:

```html
<!-- 1.1 Mandat-Offerten (4) -->
<div class="tpl-card" data-tpl="mandat_offerte_target" data-cat="mandat_offerte" onclick="selectTemplate('mandat_offerte_target')">
  <div class="tpl-icon">📄</div>
  <div class="tpl-name">Mandat-Offerte Target</div>
  <div class="tpl-meta">Mandat (Target) · DE</div>
</div>
<div class="tpl-card" data-tpl="mandat_offerte_taskforce" data-cat="mandat_offerte" onclick="selectTemplate('mandat_offerte_taskforce')">
  <div class="tpl-icon">📄</div>
  <div class="tpl-name">Mandat-Offerte Taskforce</div>
  <div class="tpl-meta">Mandat (Taskforce)</div>
</div>
<div class="tpl-card soon" data-tpl="mandat_offerte_time" data-cat="mandat_offerte">
  <div class="tpl-icon">📄</div>
  <div class="tpl-name">Mandat-Offerte Time</div>
  <div class="tpl-meta">Mandat (Time) · noch nicht ausgerollt</div>
</div>
<div class="tpl-card" data-tpl="auftragserteilung_optionale_stage" data-cat="mandat_offerte" onclick="selectTemplate('auftragserteilung_optionale_stage')">
  <div class="tpl-icon">📄</div>
  <div class="tpl-name">Auftragserteilung Optionale Stage</div>
  <div class="tpl-meta">Mandat + Option VIII/IX/X</div>
</div>

<!-- 1.2 Mandat-Rechnungen (10) -->
<div class="tpl-card" data-tpl="rechnung_mandat_teilzahlung_1_sie" data-cat="mandat_rechnung" onclick="selectTemplate('rechnung_mandat_teilzahlung_1_sie')">
  <div class="tpl-icon">💰</div>
  <div class="tpl-name">Rechnung Mandat · Teilzahlung 1</div>
  <div class="tpl-meta">Mandat Stage I · Sie</div>
</div>
<div class="tpl-card" data-tpl="rechnung_mandat_teilzahlung_1_du" data-cat="mandat_rechnung" onclick="selectTemplate('rechnung_mandat_teilzahlung_1_du')">
  <div class="tpl-icon">💰</div>
  <div class="tpl-name">Rechnung Mandat · Teilzahlung 1</div>
  <div class="tpl-meta">Mandat Stage I · Du</div>
</div>
<div class="tpl-card" data-tpl="rechnung_mandat_teilzahlung_2_sie" data-cat="mandat_rechnung" onclick="selectTemplate('rechnung_mandat_teilzahlung_2_sie')">
  <div class="tpl-icon">💰</div>
  <div class="tpl-name">Rechnung Mandat · Teilzahlung 2</div>
  <div class="tpl-meta">Mandat Stage II · Sie</div>
</div>
<div class="tpl-card" data-tpl="rechnung_mandat_teilzahlung_2_du" data-cat="mandat_rechnung" onclick="selectTemplate('rechnung_mandat_teilzahlung_2_du')">
  <div class="tpl-icon">💰</div>
  <div class="tpl-name">Rechnung Mandat · Teilzahlung 2</div>
  <div class="tpl-meta">Mandat Stage II · Du</div>
</div>
<div class="tpl-card" data-tpl="rechnung_mandat_teilzahlung_3_sie" data-cat="mandat_rechnung" onclick="selectTemplate('rechnung_mandat_teilzahlung_3_sie')">
  <div class="tpl-icon">💰</div>
  <div class="tpl-name">Rechnung Mandat · Teilzahlung 3</div>
  <div class="tpl-meta">Mandat Stage III · Sie</div>
</div>
<div class="tpl-card" data-tpl="rechnung_mandat_teilzahlung_3_du" data-cat="mandat_rechnung" onclick="selectTemplate('rechnung_mandat_teilzahlung_3_du')">
  <div class="tpl-icon">💰</div>
  <div class="tpl-name">Rechnung Mandat · Teilzahlung 3</div>
  <div class="tpl-meta">Mandat Stage III · Du</div>
</div>
<div class="tpl-card" data-tpl="rechnung_mandat_optionale_stage" data-cat="mandat_rechnung" onclick="selectTemplate('rechnung_mandat_optionale_stage')">
  <div class="tpl-icon">💰</div>
  <div class="tpl-name">Rechnung Optionale Stage</div>
  <div class="tpl-meta">Mandat + Option</div>
</div>
<div class="tpl-card" data-tpl="rechnung_mandat_kuendigung" data-cat="mandat_rechnung" onclick="selectTemplate('rechnung_mandat_kuendigung')">
  <div class="tpl-icon">💰</div>
  <div class="tpl-name">Rechnung Kündigung Mandat</div>
  <div class="tpl-meta">Mandat · cancellation</div>
</div>
<div class="tpl-card" data-tpl="mahnung_mandat_sie" data-cat="mandat_rechnung" onclick="selectTemplate('mahnung_mandat_sie')">
  <div class="tpl-icon">🔔</div>
  <div class="tpl-name">Mahnung Mandat</div>
  <div class="tpl-meta">Rechnung Mandat · Sie</div>
</div>
<div class="tpl-card" data-tpl="mahnung_mandat_du" data-cat="mandat_rechnung" onclick="selectTemplate('mahnung_mandat_du')">
  <div class="tpl-icon">🔔</div>
  <div class="tpl-name">Mahnung Mandat</div>
  <div class="tpl-meta">Rechnung Mandat · Du</div>
</div>

<!-- 1.3 Best-Effort (8) -->
<div class="tpl-card" data-tpl="rechnung_best_effort_sie" data-cat="best_effort" onclick="selectTemplate('rechnung_best_effort_sie')">
  <div class="tpl-icon">💰</div>
  <div class="tpl-name">Rechnung Erfolgsbasis · Sie</div>
  <div class="tpl-meta">Prozess · Placement · ohne Rabatt</div>
</div>
<div class="tpl-card" data-tpl="rechnung_best_effort_du" data-cat="best_effort" onclick="selectTemplate('rechnung_best_effort_du')">
  <div class="tpl-icon">💰</div>
  <div class="tpl-name">Rechnung Erfolgsbasis · Du</div>
  <div class="tpl-meta">Prozess · Placement · ohne Rabatt</div>
</div>
<div class="tpl-card" data-tpl="rechnung_best_effort_mit_rabatt_sie" data-cat="best_effort" onclick="selectTemplate('rechnung_best_effort_mit_rabatt_sie')">
  <div class="tpl-icon">💰</div>
  <div class="tpl-name">Rechnung Erfolgsbasis mit Rabatt · Sie</div>
  <div class="tpl-meta">Prozess · Placement</div>
</div>
<div class="tpl-card" data-tpl="rechnung_best_effort_mit_rabatt_du" data-cat="best_effort" onclick="selectTemplate('rechnung_best_effort_mit_rabatt_du')">
  <div class="tpl-icon">💰</div>
  <div class="tpl-name">Rechnung Erfolgsbasis mit Rabatt · Du</div>
  <div class="tpl-meta">Prozess · Placement</div>
</div>
<div class="tpl-card" data-tpl="mahnung_best_effort_sie" data-cat="best_effort" onclick="selectTemplate('mahnung_best_effort_sie')">
  <div class="tpl-icon">🔔</div>
  <div class="tpl-name">Mahnung Erfolgsbasis · Sie</div>
  <div class="tpl-meta">Rechnung BE · Sie</div>
</div>
<div class="tpl-card" data-tpl="mahnung_best_effort_du" data-cat="best_effort" onclick="selectTemplate('mahnung_best_effort_du')">
  <div class="tpl-icon">🔔</div>
  <div class="tpl-name">Mahnung Erfolgsbasis · Du</div>
  <div class="tpl-meta">Rechnung BE · Du</div>
</div>
<div class="tpl-card" data-tpl="mahnung_best_effort_mit_rabatt_sie" data-cat="best_effort" onclick="selectTemplate('mahnung_best_effort_mit_rabatt_sie')">
  <div class="tpl-icon">🔔</div>
  <div class="tpl-name">Mahnung Erfolgsbasis mit Rabatt · Sie</div>
  <div class="tpl-meta">Rechnung BE</div>
</div>
<div class="tpl-card" data-tpl="mahnung_best_effort_mit_rabatt_du" data-cat="best_effort" onclick="selectTemplate('mahnung_best_effort_mit_rabatt_du')">
  <div class="tpl-icon">🔔</div>
  <div class="tpl-name">Mahnung Erfolgsbasis mit Rabatt · Du</div>
  <div class="tpl-meta">Rechnung BE</div>
</div>

<!-- 1.4 Assessment (3) -->
<div class="tpl-card" data-tpl="assessment_offerte" data-cat="assessment" onclick="selectTemplate('assessment_offerte')">
  <div class="tpl-icon">📊</div>
  <div class="tpl-name">Offerte Diagnostik & Assessment</div>
  <div class="tpl-meta">Assessment-Order</div>
</div>
<div class="tpl-card" data-tpl="assessment_rechnung" data-cat="assessment" onclick="selectTemplate('assessment_rechnung')">
  <div class="tpl-icon">💰</div>
  <div class="tpl-name">Rechnung Diagnostik & Assessment</div>
  <div class="tpl-meta">Assessment-Order</div>
</div>
<div class="tpl-card" data-tpl="executive_report" data-cat="assessment" onclick="selectTemplate('executive_report')">
  <div class="tpl-icon">📋</div>
  <div class="tpl-name">Executive Report <span class="chip chip-accent" style="font-size:9px">NEU</span></div>
  <div class="tpl-meta">Assessment-Run + Kandidat</div>
</div>

<!-- 1.5 Rückerstattung (1) -->
<div class="tpl-card" data-tpl="rechnung_rueckerstattung" data-cat="rueckerstattung" onclick="selectTemplate('rechnung_rueckerstattung')">
  <div class="tpl-icon">↩</div>
  <div class="tpl-name">Rechnung Rückerstattung</div>
  <div class="tpl-meta">Prozess · Early-Exit</div>
</div>

<!-- 1.6 Kandidat (5) -->
<div class="tpl-card" data-tpl="ark_cv" data-cat="kandidat" onclick="selectTemplate('ark_cv')">
  <div class="tpl-icon">👤</div>
  <div class="tpl-name">ARK CV</div>
  <div class="tpl-meta">Kandidat · intern + Kunde</div>
</div>
<div class="tpl-card" data-tpl="abstract" data-cat="kandidat" onclick="selectTemplate('abstract')">
  <div class="tpl-icon">📄</div>
  <div class="tpl-name">Abstract</div>
  <div class="tpl-meta">Kandidat · Kurzzusammenfassung</div>
</div>
<div class="tpl-card" data-tpl="expose" data-cat="kandidat" onclick="selectTemplate('expose')">
  <div class="tpl-icon">🎭</div>
  <div class="tpl-name">Exposé</div>
  <div class="tpl-meta">Kandidat · anonymisiert</div>
</div>
<div class="tpl-card" data-tpl="referenzauskunft" data-cat="kandidat" onclick="selectTemplate('referenzauskunft')">
  <div class="tpl-icon">📞</div>
  <div class="tpl-name">Referenzauskunft</div>
  <div class="tpl-meta">Kandidat + Referenzperson</div>
</div>
<div class="tpl-card" data-tpl="referral_schreiben" data-cat="kandidat" onclick="selectTemplate('referral_schreiben')">
  <div class="tpl-icon">🤝</div>
  <div class="tpl-name">Referral-Schreiben</div>
  <div class="tpl-meta">Kandidat</div>
</div>

<!-- 1.7 Brief / Guides (4) -->
<div class="tpl-card" data-tpl="interviewguide" data-cat="brief" onclick="selectTemplate('interviewguide')">
  <div class="tpl-icon">💬</div>
  <div class="tpl-name">ARK Interviewguide</div>
  <div class="tpl-meta">Kandidat · Coaching-Prep</div>
</div>
<div class="tpl-card" data-tpl="gespraechsleitfaden_referenz" data-cat="brief" onclick="selectTemplate('gespraechsleitfaden_referenz')">
  <div class="tpl-icon">💬</div>
  <div class="tpl-name">Gesprächsleitfaden Referenz</div>
  <div class="tpl-meta">Kandidat + Referenzperson</div>
</div>
<div class="tpl-card" data-tpl="brief_betreff" data-cat="brief" onclick="selectTemplate('brief_betreff')">
  <div class="tpl-icon">✉</div>
  <div class="tpl-name">Postaler Brief mit Betreff</div>
  <div class="tpl-meta">Kontakt/Kandidat</div>
</div>
<div class="tpl-card" data-tpl="brief_titel" data-cat="brief" onclick="selectTemplate('brief_titel')">
  <div class="tpl-icon">✉</div>
  <div class="tpl-name">Postaler Brief mit Titel</div>
  <div class="tpl-meta">Kontakt/Kandidat</div>
</div>

<!-- 1.8 Reportings (7) -->
<div class="tpl-card" data-tpl="am_reporting" data-cat="reporting" onclick="selectTemplate('am_reporting')">
  <div class="tpl-icon">📊</div>
  <div class="tpl-name">AM Reporting Fokus</div>
  <div class="tpl-meta">Tenant + Zeitraum</div>
</div>
<div class="tpl-card" data-tpl="cm_reporting" data-cat="reporting" onclick="selectTemplate('cm_reporting')">
  <div class="tpl-icon">📊</div>
  <div class="tpl-name">CM Reporting Fokus</div>
  <div class="tpl-meta">Mitarbeiter CM + Zeitraum</div>
</div>
<div class="tpl-card" data-tpl="monatsreporting_cm" data-cat="reporting" onclick="selectTemplate('monatsreporting_cm')">
  <div class="tpl-icon">📊</div>
  <div class="tpl-name">Monatsreporting CM</div>
  <div class="tpl-meta">Mitarbeiter CM + Monat</div>
</div>
<div class="tpl-card" data-tpl="reporting_hunt" data-cat="reporting" onclick="selectTemplate('reporting_hunt')">
  <div class="tpl-icon">📊</div>
  <div class="tpl-name">Reporting Hunt</div>
  <div class="tpl-meta">Mandat + Zeitraum</div>
</div>
<div class="tpl-card" data-tpl="reporting_team_leader" data-cat="reporting" onclick="selectTemplate('reporting_team_leader')">
  <div class="tpl-icon">📊</div>
  <div class="tpl-name">Reporting Team Leader</div>
  <div class="tpl-meta">Tenant + Zeitraum</div>
</div>
<div class="tpl-card" data-tpl="mandat_report" data-cat="reporting" onclick="selectTemplate('mandat_report')">
  <div class="tpl-icon">📊</div>
  <div class="tpl-name">Mandat-Status-Report an Kunde</div>
  <div class="tpl-meta">Mandat</div>
</div>
<div class="tpl-card" data-tpl="factsheet_personalgewinnung" data-cat="reporting" onclick="selectTemplate('factsheet_personalgewinnung')">
  <div class="tpl-icon">📄</div>
  <div class="tpl-name">Factsheet Personalgewinnung</div>
  <div class="tpl-meta">Account</div>
</div>
```

- [ ] **Step 2: Verifikation**

Grep `pattern="data-tpl=" count=true` → **42 Matches**.

---

## Task 1.4: Step 2 Entity-Picker

**Files:**
- Modify: `mockups/dok-generator.html` (Step 2 pane)

- [ ] **Step 1: Entity-Picker-Pane befüllen**

Edit ersetzt `<div class="step-pane" data-step="2"></div>`:

```html
<div class="step-pane" data-step="2">
  <div style="margin-bottom:10px">
    <h2 style="margin:0 0 4px;font-family:'Libre Baskerville',serif;font-size:18px">Entity wählen</h2>
    <div class="muted" style="font-size:12px" id="entityPickerHint">Template: <strong id="pickedTpl">—</strong> · erwartet <strong id="pickedTplEntity">—</strong></div>
  </div>

  <div style="background:var(--surface);border:1px solid var(--border);border-radius:3px;padding:20px;max-width:680px">
    <label style="display:block;font-weight:600;margin-bottom:6px;font-size:13px">Target-Entity *</label>
    <input type="search" id="entitySearch" placeholder="🔍 Mandat / Kandidat / Account / Assessment-Order / Prozess …" style="width:100%;padding:8px;border:1px solid var(--border);border-radius:2px;background:var(--surface);font-family:inherit;font-size:13px">

    <!-- Dummy-Ergebnisse -->
    <div style="margin-top:10px;border:1px solid var(--border-soft);border-radius:2px;max-height:300px;overflow-y:auto">
      <div class="muted" style="padding:6px 12px;font-size:10px;text-transform:uppercase;letter-spacing:0.05em;background:var(--bg);border-bottom:1px solid var(--border-soft)">Aktive Mandate</div>
      <div style="padding:10px 12px;cursor:pointer;border-bottom:1px solid var(--border-soft)" onclick="selectEntity('mandate:cfo-suche')">
        <div><strong>CFO-Suche</strong> · Bauherr Muster AG</div>
        <div class="muted" style="font-size:11px">Taskforce · Stage 2/3 · Pauschale CHF 75'000</div>
      </div>
      <div style="padding:10px 12px;cursor:pointer;border-bottom:1px solid var(--border-soft)" onclick="selectEntity('mandate:pl-hochbau')">
        <div><strong>PL Hochbau</strong> · Implenia AG</div>
        <div class="muted" style="font-size:11px">Taskforce · Stage 3/3 · Pauschale CHF 55'000</div>
      </div>
      <div style="padding:10px 12px;cursor:pointer;border-bottom:1px solid var(--border-soft)" onclick="selectEntity('mandate:bim-manager')">
        <div><strong>BIM-Manager</strong> · Muster Immobilien</div>
        <div class="muted" style="font-size:11px">Target · Stage 1/3 · Pauschale CHF 66'000</div>
      </div>

      <div class="muted" style="padding:6px 12px;font-size:10px;text-transform:uppercase;letter-spacing:0.05em;background:var(--bg);border-bottom:1px solid var(--border-soft);border-top:1px solid var(--border)">Zuletzt verwendet</div>
      <div style="padding:10px 12px;cursor:pointer" onclick="selectEntity('mandate:cfo-suche')">
        <div><strong>CFO-Suche</strong> · zuletzt 12.04.2026</div>
      </div>
    </div>

    <div class="muted" style="font-size:11px;margin-top:8px">Multi-Entity möglich für Templates wie Exposé (Kandidat + Mandat). Plus-Button erscheint nach erster Auswahl.</div>
  </div>
</div>
```

- [ ] **Step 2: Verifikation**

Grep `pattern="entitySearch|pickedTpl"` → ≥2 Matches.

---

## Task 1.5: Step 3 Editor-Layout (Sidebar-Sections + A4 Canvas)

**Files:**
- Modify: `mockups/dok-generator.html` (Step 3 pane + CSS-Block)

- [ ] **Step 1: Editor-CSS erweitern (aus Kandidat-Tab-9 generalisiert)**

Edit ergänzt inline `<style>`-Block:

```css
.editor-layout { display:grid;grid-template-columns:260px 1fr;gap:12px;align-items:start }
.editor-sidebar { background:var(--surface);border:1px solid var(--border);border-radius:3px;padding:12px;position:sticky;top:12px;max-height:calc(100vh - 220px);overflow-y:auto }
.editor-sidebar h5 { font-size:10px;text-transform:uppercase;letter-spacing:1.2px;color:var(--text-light);margin:14px 0 6px;font-weight:600 }
.editor-sidebar h5:first-child { margin-top:0 }
.es-item { display:flex;align-items:center;gap:8px;padding:6px 8px;font-size:12px;border-radius:2px;cursor:grab;transition:background 0.1s }
.es-item:hover { background:var(--bg) }
.es-grip { color:var(--text-light);font-size:10px;letter-spacing:-1px }
.es-check input { margin:0 }
.es-label { flex:1;font-weight:500 }
.es-src { font-size:10px;color:var(--text-light);background:var(--bg);padding:1px 5px;border-radius:2px }
.param-panel { padding:10px;background:var(--bg);border-radius:3px;margin-top:10px }
.param-row { display:flex;gap:8px;align-items:center;margin-bottom:6px;font-size:12px }
.anon-panel { background:color-mix(in srgb, var(--purple) 6%, transparent);border:1px solid color-mix(in srgb, var(--purple) 20%, var(--border));border-radius:3px;padding:10px;margin-top:8px }
.editor-main { background:var(--bg);border:1px solid var(--border);border-radius:3px;padding:14px }
.editor-toolbar { display:flex;align-items:center;gap:2px;padding:6px 8px;background:var(--surface);border:1px solid var(--border);border-radius:3px;margin-bottom:12px;flex-wrap:wrap }
.et-btn { width:28px;height:28px;display:flex;align-items:center;justify-content:center;cursor:pointer;border-radius:2px;font-size:13px;color:var(--text-mid) }
.et-btn:hover { background:var(--bg);color:var(--text) }
.et-btn.active { background:var(--accent-soft);color:var(--accent) }
.et-sep { width:1px;height:18px;background:var(--border);margin:0 4px }
.et-zoom { display:flex;align-items:center;gap:4px;margin-left:auto;font-size:11px;color:var(--text-light) }
.canvas-wrap { display:flex;justify-content:center;padding:16px 0 }
.canvas-a4 { width:210mm;background:#fff;box-shadow:0 3px 16px rgba(0,0,0,0.15);min-height:297mm;padding:20mm 18mm;font-family:'Segoe UI',system-ui,sans-serif;font-size:10.5pt;line-height:1.55;color:#333;--ark-navy:#1a2540;--ark-gold:#b99a5a }
.canvas-a4 h1 { font-family:'Libre Baskerville',serif;color:var(--ark-navy);font-size:20pt;margin:0 0 6mm }
.canvas-a4 h2 { font-family:'Libre Baskerville',serif;color:var(--ark-navy);font-size:13pt;margin:6mm 0 3mm }
.canvas-a4 .ph { background:color-mix(in srgb, var(--gold) 20%, transparent);padding:1px 3px;border-radius:2px;color:var(--ark-navy);font-weight:600 }
```

- [ ] **Step 2: Step-3-Pane HTML**

Edit ersetzt `<div class="step-pane" data-step="3"></div>`:

```html
<div class="step-pane" data-step="3">
  <div style="margin-bottom:10px;display:flex;justify-content:space-between;align-items:flex-end">
    <div>
      <h2 style="margin:0 0 4px;font-family:'Libre Baskerville',serif;font-size:18px">Ausfüllen</h2>
      <div class="muted" style="font-size:12px">Template <strong id="editingTplName">—</strong> · Entity <strong id="editingEntityName">—</strong> · Platzhalter live aus DB gelöst</div>
    </div>
    <div class="muted" style="font-size:11px">Änderungen werden als Override gespeichert</div>
  </div>

  <div class="editor-layout">
    <aside class="editor-sidebar">
      <h5>Sektionen (Drag & Drop)</h5>
      <div class="es-item">
        <span class="es-grip">⋮⋮</span>
        <label class="es-check"><input type="checkbox" checked></label>
        <span class="es-label">Briefkopf</span>
        <span class="es-src">auto</span>
      </div>
      <div class="es-item">
        <span class="es-grip">⋮⋮</span>
        <label class="es-check"><input type="checkbox" checked></label>
        <span class="es-label">Anrede</span>
        <span class="es-src">auto</span>
      </div>
      <div class="es-item">
        <span class="es-grip">⋮⋮</span>
        <label class="es-check"><input type="checkbox" checked></label>
        <span class="es-label">Hauptteil</span>
        <span class="es-src">auto</span>
      </div>
      <div class="es-item">
        <span class="es-grip">⋮⋮</span>
        <label class="es-check"><input type="checkbox" checked></label>
        <span class="es-label">Positionen</span>
        <span class="es-src">entity</span>
      </div>
      <div class="es-item">
        <span class="es-grip">⋮⋮</span>
        <label class="es-check"><input type="checkbox"></label>
        <span class="es-label">Zusatz-Paragraph</span>
        <span class="es-src">manuell</span>
      </div>
      <div class="es-item">
        <span class="es-grip">⋮⋮</span>
        <label class="es-check"><input type="checkbox" checked></label>
        <span class="es-label">Schlussgrüße</span>
        <span class="es-src">auto</span>
      </div>
      <div class="es-item">
        <span class="es-grip">⋮⋮</span>
        <label class="es-check"><input type="checkbox"></label>
        <span class="es-label">Anhänge</span>
        <span class="es-src">entity</span>
      </div>

      <h5>Parameter</h5>
      <div class="param-panel">
        <div class="param-row">
          <label style="flex:1">Sprache</label>
          <select style="font-size:11px"><option>DE</option><option disabled>EN (Phase 2)</option></select>
        </div>
        <div class="param-row">
          <label style="flex:1">Empfänger-Anrede</label>
          <select style="font-size:11px"><option>Sehr geehrter Herr</option><option>Sehr geehrte Frau</option><option>Liebes Team</option></select>
        </div>
        <div class="param-row">
          <label style="flex:1">Zahlungsfrist</label>
          <select style="font-size:11px"><option>30 Tage</option><option>14 Tage</option></select>
        </div>
      </div>

      <!-- Anonymisierung nur bei Expose — wird in Task 2.7 aktiviert -->
      <div class="anon-panel" id="anonPanel" style="display:none">
        <h5 style="color:var(--purple);margin-top:0">Anonymisierung (Exposé)</h5>
        <div class="param-row"><input type="checkbox" checked> Name → „Kandidat m/w"</div>
        <div class="param-row"><input type="checkbox" checked> Foto entfernen</div>
        <div class="param-row"><input type="checkbox"> Firmennamen anonymisieren</div>
        <div class="param-row"><input type="checkbox"> Wohnort → Kanton only</div>
      </div>
    </aside>

    <main class="editor-main">
      <div class="editor-toolbar">
        <span class="et-btn" title="Bold">𝐁</span>
        <span class="et-btn" title="Italic"><em>I</em></span>
        <span class="et-btn" title="Underline"><u>U</u></span>
        <span class="et-sep"></span>
        <span class="et-btn" title="H1">H1</span>
        <span class="et-btn" title="H2">H2</span>
        <span class="et-sep"></span>
        <span class="et-btn" title="List">•</span>
        <span class="et-btn" title="Ordered">1.</span>
        <span class="et-sep"></span>
        <span class="et-btn" title="Link">🔗</span>
        <span class="et-btn" title="Image">🖼</span>
        <div class="et-zoom">Zoom: <select style="font-size:11px"><option>100%</option><option>75%</option><option>150%</option></select></div>
      </div>

      <div class="canvas-wrap">
        <div class="canvas-a4" id="canvasA4">
          <!-- Placeholder content — wird in Phase 2 mit Seed-Template-Content gefüllt -->
          <h1 style="color:var(--ark-navy)">Template-Content folgt</h1>
          <p class="muted">Wähle ein Template und eine Entity. Die Platzhalter werden live aufgelöst.</p>
          <p>Beispiel Platzhalter:<br>
            <span class="ph">{{mandat.name}}</span> · <span class="ph">{{account.name}}</span> · <span class="ph">{{mandat.honorar_pauschale}}</span>
          </p>
        </div>
      </div>
    </main>
  </div>
</div>
```

- [ ] **Step 3: Verifikation**

Grep `pattern="editor-sidebar|canvas-a4"` → ≥2 Matches.

---

## Task 1.6: Step 4 Preview

**Files:**
- Modify: `mockups/dok-generator.html`

- [ ] **Step 1: Preview-Pane HTML**

Edit ersetzt `<div class="step-pane" data-step="4"></div>`:

```html
<div class="step-pane" data-step="4">
  <div style="margin-bottom:10px">
    <h2 style="margin:0 0 4px;font-family:'Libre Baskerville',serif;font-size:18px">Preview</h2>
    <div class="muted" style="font-size:12px">Read-only PDF-Preview · Änderungen? Zurück zu Step 3 Ausfüllen</div>
  </div>

  <div class="canvas-wrap" style="background:var(--bg);border:1px solid var(--border);border-radius:3px;padding:24px">
    <div class="canvas-a4" style="pointer-events:none">
      <h1>Preview-Dokument</h1>
      <p>Wird in Phase 2 mit Seed-Template-Preview gefüllt.</p>
      <p class="muted">Dieses ist der finale Stand — alle Sektionen gerendert, Platzhalter aufgelöst.</p>
    </div>
  </div>

  <div style="display:flex;gap:8px;margin-top:14px;padding:12px;background:var(--bg);border-radius:3px">
    <button class="btn btn-sm" onclick="goToStep(3)">← Zurück zu Ausfüllen</button>
    <span class="spacer"></span>
    <button class="btn btn-sm">↓ Als PDF herunterladen</button>
    <button class="btn btn-sm btn-primary" onclick="goToStep(5)">Weiter zu Ablage →</button>
  </div>
</div>
```

---

## Task 1.7: Step 5 Ablage + Delivery

**Files:**
- Modify: `mockups/dok-generator.html`

- [ ] **Step 1: Ablage-Pane HTML**

Edit ersetzt `<div class="step-pane" data-step="5"></div>`:

```html
<div class="step-pane" data-step="5">
  <div style="margin-bottom:10px">
    <h2 style="margin:0 0 4px;font-family:'Libre Baskerville',serif;font-size:18px">Ablage & Versand</h2>
    <div class="muted" style="font-size:12px">Dokument speichern, optional sofort per E-Mail versenden</div>
  </div>

  <div style="max-width:720px">
    <div class="card">
      <div class="card-head"><div class="card-title">Ablage-Ziel</div></div>
      <dl class="field-grid">
        <dt>Entity</dt><dd><strong id="saveEntity">—</strong> (aus Step 2)</dd>
        <dt>Dokument-Label</dt><dd><span class="chip chip-accent" id="saveLabel">—</span> (auto aus Template)</dd>
        <dt>Ablage-Ordner</dt><dd><span id="saveFolder">—</span></dd>
        <dt>Retention</dt><dd><span id="saveRetention">—</span></dd>
      </dl>
    </div>

    <div class="card" style="margin-top:14px">
      <div class="card-head"><div class="card-title">Delivery</div></div>
      <div style="padding:10px">
        <label style="display:flex;gap:8px;align-items:center;padding:8px;border-radius:2px;cursor:pointer;border:1px solid var(--border);margin-bottom:6px">
          <input type="radio" name="delivery" value="save_only">
          <div>
            <div style="font-weight:600;font-size:13px">Nur speichern</div>
            <div class="muted" style="font-size:11px">Dokument wird am Entity abgelegt, keine Email</div>
          </div>
        </label>
        <label style="display:flex;gap:8px;align-items:center;padding:8px;border-radius:2px;cursor:pointer;border:2px solid var(--accent);background:var(--accent-soft);margin-bottom:6px">
          <input type="radio" name="delivery" value="save_and_email" checked>
          <div style="flex:1">
            <div style="font-weight:600;font-size:13px">Speichern + Email versenden</div>
            <div class="muted" style="font-size:11px">Automatisch aus CRM via Outlook-/Google-Integration</div>
            <div style="margin-top:8px;display:grid;grid-template-columns:120px 1fr;gap:8px;font-size:12px">
              <label>Empfänger</label><select><option>Hans Müller · CEO Bauherr Muster AG</option><option>Eva Studer · HR-Leiterin</option></select>
              <label>Betreff</label><input type="text" value="Mandats-Offerte · CFO-Suche — Vorschlag" style="padding:4px 8px;border:1px solid var(--border);border-radius:2px">
              <label>Email-Template</label><select><option>Offerten-Anschreiben · Sie</option><option>Offerten-Anschreiben · Du</option><option>(kein Template)</option></select>
            </div>
          </div>
        </label>
        <label style="display:flex;gap:8px;align-items:center;padding:8px;border-radius:2px;cursor:pointer;border:1px solid var(--border)">
          <input type="radio" name="delivery" value="save_and_download">
          <div>
            <div style="font-weight:600;font-size:13px">Speichern + Download</div>
            <div class="muted" style="font-size:11px">Dokument wird gespeichert und lokal als PDF heruntergeladen</div>
          </div>
        </label>
      </div>
    </div>

    <div class="muted" style="font-size:11px;margin-top:14px;padding:10px 14px;background:var(--bg);border-radius:3px">
      <strong>History-Events</strong> werden automatisch am Entity geloggt (z.B. „📄 Mandats-Offerte generiert + versendet").
    </div>

    <div style="display:flex;gap:8px;margin-top:14px">
      <button class="btn btn-sm" onclick="goToStep(4)">← Zurück zu Preview</button>
      <span class="spacer"></span>
      <button class="btn btn-sm btn-primary" style="padding:10px 18px">✓ Generieren &amp; Versenden</button>
    </div>
  </div>
</div>
```

---

## Task 1.8: JS Workflow + Deep-Link-Handling

**Files:**
- Modify: `mockups/dok-generator.html` (Script-Block am Ende)

- [ ] **Step 1: goToStep, selectTemplate, selectEntity, URL-Params-Parser**

Edit ersetzt bestehenden `<script>` nach `layout.js`:

```javascript
<script>
/* Dok-Generator Workflow */
let currentStep = 1;
let currentTemplate = null;
let currentEntity = null;

const TPL_META = {
  'mandat_offerte_target': { display:'Mandat-Offerte Target', entity:'Mandat (Target)', label:'Mandat-Offerte', folder:'Account/Mandat/' },
  'mandat_offerte_taskforce': { display:'Mandat-Offerte Taskforce', entity:'Mandat (Taskforce)', label:'Mandat-Offerte', folder:'Account/Mandat/' },
  'rechnung_mandat_teilzahlung_1_sie': { display:'Rechnung Mandat T1 · Sie', entity:'Mandat (Stage I)', label:'Mandat-Rechnung', folder:'Account/Mandat/Rechnungen/' },
  'assessment_offerte': { display:'Assessment-Offerte', entity:'Assessment-Order', label:'Assessment-Offerte', folder:'Account/Assessment/' },
  'ark_cv': { display:'ARK CV', entity:'Kandidat', label:'ARK CV', folder:'Kandidat/' },
  'abstract': { display:'Abstract', entity:'Kandidat', label:'Abstract', folder:'Kandidat/' },
  'expose': { display:'Exposé (anonym)', entity:'Kandidat', label:'Expose', folder:'Kandidat/' },
  'executive_report': { display:'Executive Report', entity:'Assessment-Run + Kandidat', label:'Executive-Report', folder:'Account/Assessment/' },
  // weitere Templates: Fallback aus TPL_META
};

function getTplMeta(key) {
  return TPL_META[key] || { display:key, entity:'Entity', label:'Dokument', folder:'—' };
}

function goToStep(n) {
  if (n < 1 || n > 5) return;
  document.querySelectorAll('.step').forEach(s => {
    const stepNum = parseInt(s.dataset.step);
    s.classList.toggle('active', stepNum <= n);
  });
  document.querySelectorAll('.step-pane').forEach(p => {
    p.classList.toggle('active', parseInt(p.dataset.step) === n);
  });
  currentStep = n;
  document.getElementById('btnPrev').disabled = (n === 1);
  document.getElementById('btnNext').disabled = (n === 5);

  // Update Step-3/5 Anzeige
  if (n === 3 && currentTemplate) {
    const m = getTplMeta(currentTemplate);
    document.getElementById('editingTplName').textContent = m.display;
    document.getElementById('editingEntityName').textContent = currentEntity || '—';
    document.getElementById('anonPanel').style.display = (currentTemplate === 'expose') ? 'block' : 'none';
  }
  if (n === 5 && currentTemplate) {
    const m = getTplMeta(currentTemplate);
    document.getElementById('saveEntity').textContent = currentEntity || 'Entity aus Step 2';
    document.getElementById('saveLabel').textContent = m.label;
    document.getElementById('saveFolder').textContent = m.folder;
    document.getElementById('saveRetention').textContent = m.label.includes('Rechnung') || m.label.includes('Offerte') ? '10 Jahre (Finanzbelege)' : 'Standard';
  }
}

function selectTemplate(key) {
  currentTemplate = key;
  const m = getTplMeta(key);
  document.getElementById('pickedTpl').textContent = m.display;
  document.getElementById('pickedTplEntity').textContent = m.entity;
  goToStep(2);
}

function selectEntity(id) {
  currentEntity = id;
  goToStep(3);
}

/* Deep-Link-Handling via URL-Params */
document.addEventListener('DOMContentLoaded', initFromUrl);
if (document.readyState !== 'loading') initFromUrl();

function initFromUrl() {
  const p = new URLSearchParams(location.search);
  const tpl = p.get('template');
  const entity = p.get('entity');
  if (tpl) {
    selectTemplate(tpl);
    if (entity) selectEntity(entity);
  } else {
    goToStep(1);
  }
}

/* Sidebar-Kategorie-Filter */
document.querySelectorAll('.sidebar-cat-item[data-cat]').forEach(el => {
  el.addEventListener('click', () => {
    document.querySelectorAll('.sidebar-cat-item[data-cat]').forEach(x => x.classList.remove('active'));
    el.classList.add('active');
    const cat = el.dataset.cat;
    document.querySelectorAll('.tpl-card').forEach(c => {
      c.style.display = (cat === 'all' || c.dataset.cat === cat) ? '' : 'none';
    });
  });
});

/* Template-Suche */
document.getElementById('tplSearch')?.addEventListener('input', e => {
  const q = e.target.value.toLowerCase();
  document.querySelectorAll('.tpl-card').forEach(c => {
    const name = c.querySelector('.tpl-name')?.textContent.toLowerCase() || '';
    c.style.display = name.includes(q) ? '' : 'none';
  });
});

/* Hotkeys */
document.addEventListener('keydown', e => {
  if (e.target.matches('input, textarea, select')) return;
  if (e.key === 'Escape') { /* Cancel flow — back to Step 1 */ goToStep(1); return; }
  if (e.key === 'ArrowRight' && currentStep < 5) goToStep(currentStep + 1);
  if (e.key === 'ArrowLeft' && currentStep > 1) goToStep(currentStep - 1);
});
</script>
```

- [ ] **Step 2: Verifikation via Playwright**

Bash (start server):
```bash
cd "/c/ARK CRM" && python -m http.server 8765 &
```

Playwright-navigate + screenshot → Step 1 active, Template-Grid mit 42 Cards sichtbar, Sidebar links.

Playwright-click auf Template-Card (z.B. `mandat_offerte_target`) → Step 2 aktiv, Entity-Picker mit Mandat-Vorschlägen sichtbar.

Playwright-click auf Mandat → Step 3 aktiv, Editor-Layout sichtbar (Sidebar + Canvas).

Playwright-click auf "Weiter →" zweimal → Step 5 aktiv, Ablage-Optionen sichtbar.

Playwright-navigate `http://localhost:8765/mockups/dok-generator.html?template=ark_cv&entity=candidate:tf` → direkt in Step 3.

---

## Task 1.9: KB-Hints + Drift-Check + Phase-1-Checkpoint

- [ ] **Step 1: Lint-Skills**

```
Skill: ark-lint args="mockups/dok-generator.html"
Skill: mockup-drift-check args="mockups/dok-generator.html"
```

Expected: alle grün (stammdaten/umlaute/db-techdetails OK, drift gegen candidates Tab-9 pattern-consistent).

- [ ] **Step 2: Browser-Test komplett**

Alle 5 Steps durchklicken, Hotkeys `←`/`→` testen, Category-Filter testen, Suche testen.

- [ ] **Step 3: Phase-1-Backup**

```bash
TS=$(date +%Y-%m-%d-%H%M)
cp "/c/ARK CRM/mockups/dok-generator.html" "/c/ARK CRM/backups/dok-generator.html.${TS}-p1-final.bak"
```

- [ ] **Step 4: User-Checkpoint**

User prüft im Browser. Bei OK → Phase 2.

---

# PHASE 2 — Full-Content für 5 Seed-Templates

**Ziel:** 5 Seed-Templates mit realem Content im Editor + Preview (Auto-Pull-Beispiel-Daten).
**Seed-Templates:** `mandat_offerte_target`, `rechnung_mandat_teilzahlung_1_sie`, `assessment_offerte`, `ark_cv`, `executive_report`
**Zielumfang:** ~+600 Zeilen.

---

## Task 2.0: Backup P2

```bash
TS=$(date +%Y-%m-%d-%H%M)
cp "/c/ARK CRM/mockups/dok-generator.html" "/c/ARK CRM/backups/dok-generator.html.${TS}-p2.bak"
```

---

## Task 2.1: Seed Template `mandat_offerte_target` — Canvas-Content

**Files:**
- Modify: `mockups/dok-generator.html` (Canvas-Inhalt bei ausgewähltem Template)

- [ ] **Step 1: JS-Funktion `renderCanvas(templateKey, entity)` anlegen**

Edit ergänzt im `<script>`-Block:

```javascript
function renderCanvas(key, entity) {
  const canvas = document.getElementById('canvasA4');
  const previewCanvas = document.querySelector('[data-step="4"] .canvas-a4');
  const content = CANVAS_CONTENT[key] || '<h1>Template nicht implementiert</h1><p>Beispiel-Content folgt in Phase 2+.</p>';
  if (canvas) canvas.innerHTML = content;
  if (previewCanvas) previewCanvas.innerHTML = content;
}

const CANVAS_CONTENT = {
  'mandat_offerte_target': `
    <div style="display:flex;justify-content:space-between;margin-bottom:10mm">
      <div style="font-family:'Libre Baskerville',serif;font-size:18pt;color:var(--ark-navy)">ARKADIUM</div>
      <div style="text-align:right;font-size:9pt;color:#666">
        Arkadium AG<br>Seefeldstrasse 69, 8008 Zürich<br>www.arkadium.ch
      </div>
    </div>
    <p style="font-size:9pt;color:#666;margin-bottom:8mm">Zürich, <span class="ph">{{datum_heute}}</span></p>
    <div style="margin-bottom:12mm">
      <span class="ph">{{account.name}}</span><br>
      <span class="ph">{{mandat.kontakt_hiring_manager.vorname}} {{mandat.kontakt_hiring_manager.nachname}}</span><br>
      <span class="ph">{{account.adresse_strasse}}</span><br>
      <span class="ph">{{account.adresse_plz}} {{account.adresse_ort}}</span>
    </div>
    <h1>Offerte Mandat Target · <span class="ph">{{mandat.name}}</span></h1>
    <p style="margin-bottom:6mm">Sehr geehrte/r <span class="ph">{{empfaenger_anrede}} {{mandat.kontakt_hiring_manager.nachname}}</span>,</p>
    <p>wir freuen uns, Ihnen unser Angebot für die Suche und Besetzung der Position <strong><span class="ph">{{mandat.job.funktion}}</span></strong> bei der <span class="ph">{{account.name}}</span> zu unterbreiten.</p>
    <h2>1. Leistungsumfang</h2>
    <p>Das Mandat umfasst die eigenverantwortliche Suche, Identifikation und Evaluation qualifizierter Kandidat:innen inklusive:</p>
    <ul><li>Research &amp; Marktanalyse</li><li>Direktansprache</li><li>Evaluationsgespräche</li><li>Shortlist (mind. <span class="ph">{{mandat.shortlist_zielgröße}}</span> Kandidat:innen)</li><li>Begleitung bis zur Vertragsunterzeichnung</li></ul>
    <h2>2. Honorar</h2>
    <p>Das Gesamthonorar beträgt <strong class="ph">{{mandat.honorar_pauschale_chf}} CHF</strong> netto, zahlbar in drei Teilzahlungen:</p>
    <table style="width:100%;border-collapse:collapse;margin:4mm 0">
      <tr style="background:#f2f2f2"><th style="padding:3mm;text-align:left">Stage</th><th style="padding:3mm;text-align:right">CHF</th></tr>
      <tr><td style="padding:3mm">Stage 1 — Kickoff + Stellenbriefing</td><td style="padding:3mm;text-align:right"><span class="ph">{{mandat.teilzahlung_1}}</span></td></tr>
      <tr><td style="padding:3mm">Stage 2 — Shortlist-Präsentation</td><td style="padding:3mm;text-align:right"><span class="ph">{{mandat.teilzahlung_2}}</span></td></tr>
      <tr><td style="padding:3mm">Stage 3 — Placement</td><td style="padding:3mm;text-align:right"><span class="ph">{{mandat.teilzahlung_3}}</span></td></tr>
    </table>
    <h2>3. Garantiefrist</h2>
    <p>Wir gewähren eine Garantiefrist von <strong>3 Monaten</strong> ab Stellenantritt. Scheidet die platzierte Person innerhalb dieser Frist aus, führen wir die Suche kostenlos fort.</p>
    <p style="margin-top:10mm">Wir freuen uns auf die Zusammenarbeit.</p>
    <p style="margin-top:8mm">Mit freundlichen Grüßen<br><br><span class="ph">{{owner_am.vorname}} {{owner_am.nachname}}</span><br>Arkadium AG</p>
  `,
  // weitere Templates in Tasks 2.2–2.5
};

// Aufruf am Step-3-Eintritt
const origGoToStep = goToStep;
goToStep = function(n) {
  origGoToStep(n);
  if ((n === 3 || n === 4) && currentTemplate) renderCanvas(currentTemplate, currentEntity);
};
```

- [ ] **Step 2: Verifikation**

Playwright-test → Template `mandat_offerte_target` wählen → Mandat wählen → Step 3: Canvas zeigt Offerte mit Platzhalter-Highlighting (gelb).

---

## Task 2.2: Seed Template `rechnung_mandat_teilzahlung_1_sie`

- [ ] **Step 1: CANVAS_CONTENT-Eintrag hinzufügen**

Edit erweitert `CANVAS_CONTENT`:

```javascript
'rechnung_mandat_teilzahlung_1_sie': `
  <div style="display:flex;justify-content:space-between;margin-bottom:10mm">
    <div style="font-family:'Libre Baskerville',serif;font-size:16pt;color:var(--ark-navy)">ARKADIUM</div>
    <div style="text-align:right;font-size:9pt;color:#666">Rechnung · <strong><span class="ph">{{rechnung.nummer}}</span></strong><br>Zürich, <span class="ph">{{rechnung.datum}}</span></div>
  </div>
  <div style="margin-bottom:12mm">
    <span class="ph">{{account.name}}</span><br>
    <span class="ph">{{mandat.kontakt_finance.vorname}} {{mandat.kontakt_finance.nachname}}</span><br>
    <span class="ph">{{account.adresse_strasse}}</span><br>
    <span class="ph">{{account.adresse_plz}} {{account.adresse_ort}}</span>
  </div>
  <h1>Rechnung Mandat · 1. Teilzahlung</h1>
  <p>Sehr geehrte/r <span class="ph">{{empfaenger_anrede}} {{mandat.kontakt_finance.nachname}}</span>,</p>
  <p>vielen Dank für Ihren Auftrag. Gemäß unserer Offerte vom <span class="ph">{{mandat.offerte_datum}}</span> stellen wir Ihnen die 1. Teilzahlung für das Mandat <strong><span class="ph">{{mandat.name}}</span></strong> in Rechnung:</p>
  <table style="width:100%;border-collapse:collapse;margin:6mm 0">
    <tr style="background:#f2f2f2"><th style="padding:3mm;text-align:left">Position</th><th style="padding:3mm;text-align:right">CHF</th></tr>
    <tr><td style="padding:3mm">Stage 1 — Kickoff + Stellenbriefing · Mandat <span class="ph">{{mandat.name}}</span></td><td style="padding:3mm;text-align:right"><span class="ph">{{mandat.teilzahlung_1}}</span></td></tr>
    <tr><td style="padding:3mm">MwSt 8.1%</td><td style="padding:3mm;text-align:right"><span class="ph">{{mandat.teilzahlung_1_mwst}}</span></td></tr>
    <tr style="font-weight:700;background:#f2f2f2"><td style="padding:3mm">Total brutto</td><td style="padding:3mm;text-align:right"><span class="ph">{{mandat.teilzahlung_1_brutto}}</span></td></tr>
  </table>
  <h2>Zahlungsbedingungen</h2>
  <p>Zahlbar innert <strong><span class="ph">{{zahlungsfrist_tage}}</span> Tagen</strong> auf IBAN <strong>CH00 0000 0000 0000 0000 0</strong> lautend auf Arkadium AG. Bitte geben Sie als Referenz <strong><span class="ph">{{rechnung.nummer}}</span></strong> an.</p>
  <p style="margin-top:8mm">Mit freundlichen Grüßen<br><br>Arkadium AG · Finance</p>
`,
```

---

## Task 2.3: Seed Template `assessment_offerte`

Analog Task 2.1/2.2 mit Assessment-Offerte-Content:

```javascript
'assessment_offerte': `
  <div style="display:flex;justify-content:space-between;margin-bottom:10mm">
    <div style="font-family:'Libre Baskerville',serif;font-size:16pt;color:var(--ark-navy)">ARKADIUM</div>
    <div style="text-align:right;font-size:9pt;color:#666">Offerte Diagnostik &amp; Assessment<br>Zürich, <span class="ph">{{datum_heute}}</span></div>
  </div>
  <div style="margin-bottom:12mm">
    <span class="ph">{{account.name}}</span><br>
    <span class="ph">{{assessment_order.kontakt.vorname}} {{assessment_order.kontakt.nachname}}</span><br>
    <span class="ph">{{account.adresse_strasse}}</span><br>
    <span class="ph">{{account.adresse_plz}} {{account.adresse_ort}}</span>
  </div>
  <h1>Offerte Diagnostik &amp; Assessment</h1>
  <p>Sehr geehrte/r <span class="ph">{{empfaenger_anrede}} {{assessment_order.kontakt.nachname}}</span>,</p>
  <p>wir freuen uns, Ihnen unser Offerte für die Diagnostik- und Assessment-Leistung zu unterbreiten. Durchgeführt in Kooperation mit unserem Partner <strong>SCHEELEN®</strong>.</p>
  <h2>1. Umfang</h2>
  <table style="width:100%;border-collapse:collapse;margin:4mm 0">
    <tr style="background:#f2f2f2"><th style="padding:3mm;text-align:left">Typ</th><th style="padding:3mm;text-align:right">Anzahl</th><th style="padding:3mm;text-align:right">Einzelpreis</th><th style="padding:3mm;text-align:right">Total</th></tr>
    <tr><td style="padding:3mm">MDI (Management-Dimensions-Inventory)</td><td style="padding:3mm;text-align:right"><span class="ph">{{assessment_order.credits_mdi}}</span></td><td style="padding:3mm;text-align:right">CHF 2'500</td><td style="padding:3mm;text-align:right"><span class="ph">{{calc_mdi_total}}</span></td></tr>
    <tr><td style="padding:3mm">Relief</td><td style="padding:3mm;text-align:right"><span class="ph">{{assessment_order.credits_relief}}</span></td><td style="padding:3mm;text-align:right">CHF 1'800</td><td style="padding:3mm;text-align:right"><span class="ph">{{calc_relief_total}}</span></td></tr>
    <tr><td style="padding:3mm">EQ Test</td><td style="padding:3mm;text-align:right"><span class="ph">{{assessment_order.credits_eq}}</span></td><td style="padding:3mm;text-align:right">CHF 2'000</td><td style="padding:3mm;text-align:right"><span class="ph">{{calc_eq_total}}</span></td></tr>
    <tr><td style="padding:3mm">ASSESS 5.0</td><td style="padding:3mm;text-align:right"><span class="ph">{{assessment_order.credits_assess}}</span></td><td style="padding:3mm;text-align:right">CHF 3'200</td><td style="padding:3mm;text-align:right"><span class="ph">{{calc_assess_total}}</span></td></tr>
    <tr style="background:#f2f2f2;font-weight:700"><td style="padding:3mm" colspan="3">Gesamtpreis netto</td><td style="padding:3mm;text-align:right"><span class="ph">{{assessment_order.preis_netto}}</span></td></tr>
  </table>
  <h2>2. Ablauf</h2>
  <p>Nach Beauftragung erhalten Sie Credits, die Sie flexibel auf Kandidat:innen zuweisen können. Die Credits verfallen nicht. Jeder Test wird durch SCHEELEN durchgeführt, inklusive ausführlichem Detail-Report.</p>
  <h2>3. Abweichende Bestimmungen</h2>
  <p>Spesen werden separat nach Aufwand verrechnet.</p>
  <p style="margin-top:8mm">Mit freundlichen Grüßen<br><br><span class="ph">{{owner_am.vorname}} {{owner_am.nachname}}</span><br>Arkadium AG</p>
`,
```

---

## Task 2.4: Seed Template `ark_cv`

ARK CV Kandidat-Content mit echten Feldern aus Kandidaten-Vollansicht:

```javascript
'ark_cv': `
  <div style="display:flex;gap:10mm;margin-bottom:8mm">
    <div style="width:30mm;height:38mm;background:#e0e0e0;display:flex;align-items:center;justify-content:center;color:#999;font-size:9pt">FOTO</div>
    <div style="flex:1">
      <h1 style="margin:0;font-size:22pt;color:var(--ark-navy)"><span class="ph">{{kandidat.vorname}}</span> <span class="ph">{{kandidat.nachname}}</span></h1>
      <p style="margin:3mm 0 0;font-size:12pt;color:#666"><span class="ph">{{kandidat.aktuelle_funktion}}</span> · <span class="ph">{{kandidat.aktueller_arbeitgeber}}</span></p>
      <p style="margin:2mm 0 0;font-size:10pt;color:#666">
        <span class="ph">{{kandidat.alter}}</span> Jahre · <span class="ph">{{kandidat.wohnort}}</span> · <span class="ph">{{kandidat.nationalität}}</span>
      </p>
      <p style="margin:2mm 0 0;font-size:9pt;color:#888">
        ✉ <span class="ph">{{kandidat.email}}</span> · 📞 <span class="ph">{{kandidat.telefon}}</span>
      </p>
    </div>
  </div>
  <h2>Kurzprofil</h2>
  <p><span class="ph">{{kandidat.briefing.kurzprofil}}</span></p>
  <h2>Werdegang</h2>
  <table style="width:100%;border-collapse:collapse;font-size:10pt">
    <tr><td style="padding:2mm;width:30mm;color:#666"><span class="ph">{{kandidat.werdegang.station_1.von}} – {{kandidat.werdegang.station_1.bis}}</span></td>
        <td style="padding:2mm"><strong><span class="ph">{{kandidat.werdegang.station_1.position}}</span></strong><br><span class="ph">{{kandidat.werdegang.station_1.arbeitgeber}}</span></td></tr>
    <tr><td style="padding:2mm;width:30mm;color:#666"><span class="ph">{{kandidat.werdegang.station_2.von}} – {{kandidat.werdegang.station_2.bis}}</span></td>
        <td style="padding:2mm"><strong><span class="ph">{{kandidat.werdegang.station_2.position}}</span></strong><br><span class="ph">{{kandidat.werdegang.station_2.arbeitgeber}}</span></td></tr>
  </table>
  <h2>Ausbildung</h2>
  <p><span class="ph">{{kandidat.werdegang.ausbildungen}}</span></p>
  <h2>Kompetenzen &amp; Focus</h2>
  <p><span class="ph">{{kandidat.briefing.kompetenzen}}</span></p>
  <h2>Gehalts-Eckdaten</h2>
  <p>Aktueller TC: <strong class="ph">{{kandidat.briefing.salary_aktuell}}</strong> CHF · Gewünscht: <strong class="ph">{{kandidat.briefing.salary_gewuenscht}}</strong> CHF</p>
`,
```

---

## Task 2.5: Seed Template `executive_report` (NEU)

Arkadium-Executive-Report für Assessment-Run:

```javascript
'executive_report': `
  <div style="display:flex;justify-content:space-between;margin-bottom:10mm">
    <div style="font-family:'Libre Baskerville',serif;font-size:16pt;color:var(--ark-navy)">ARKADIUM · Executive Report</div>
    <div style="text-align:right;font-size:9pt;color:#666"><span class="ph">{{datum_heute}}</span><br>Vertraulich</div>
  </div>
  <h1><span class="ph">{{kandidat.vorname}} {{kandidat.nachname}}</span></h1>
  <p class="muted"><span class="ph">{{kandidat.aktuelle_funktion}}</span> · Assessment-Order <span class="ph">{{assessment_order.id}}</span></p>
  <h2>1. Zusammenfassung</h2>
  <p><span class="ph">{{arkadium.zusammenfassung}}</span></p>
  <h2>2. Assessment-Ergebnisse</h2>
  <table style="width:100%;border-collapse:collapse;font-size:10pt;margin:4mm 0">
    <tr style="background:#f2f2f2"><th style="padding:3mm;text-align:left">Typ</th><th style="padding:3mm">Durchgeführt</th><th style="padding:3mm">Kernaussage</th></tr>
    <tr><td style="padding:3mm">MDI</td><td style="padding:3mm"><span class="ph">{{assessment_run.mdi.datum}}</span></td><td style="padding:3mm"><span class="ph">{{assessment_run.mdi.fazit}}</span></td></tr>
    <tr><td style="padding:3mm">Relief</td><td style="padding:3mm"><span class="ph">{{assessment_run.relief.datum}}</span></td><td style="padding:3mm"><span class="ph">{{assessment_run.relief.fazit}}</span></td></tr>
    <tr><td style="padding:3mm">EQ Test</td><td style="padding:3mm"><span class="ph">{{assessment_run.eq.datum}}</span></td><td style="padding:3mm"><span class="ph">{{assessment_run.eq.fazit}}</span></td></tr>
  </table>
  <h2>3. Arkadium-Bewertung</h2>
  <p><strong>Empfehlung:</strong> <span class="ph">{{arkadium.empfehlung}}</span></p>
  <p><strong>Pro-Argumente:</strong> <span class="ph">{{arkadium.pro_argumente}}</span></p>
  <p><strong>Red Flags:</strong> <span class="ph">{{arkadium.red_flags}}</span></p>
  <p><strong>Entwicklungsfelder:</strong> <span class="ph">{{arkadium.entwicklungsfelder}}</span></p>
  <h2>4. Referenzen</h2>
  <p><span class="ph">{{kandidat.referenzen.zusammenfassung}}</span></p>
  <p class="muted" style="margin-top:10mm;font-size:8pt">Diese Zusammenfassung ergänzt — ersetzt nicht — die Detail-Reports von SCHEELEN. Arkadium-interne Inputs sind mit Absender gekennzeichnet.</p>
`,
```

---

## Task 2.6: Entry-Point Entity-CTAs aktualisieren

**Files:**
- Modify: `mockups/mandates.html` (Quick-Action Buttons)
- Modify: `mockups/assessments.html` (bestehender Platzhalter)
- Modify: `mockups/candidates.html` Tab 9 (Redirect-Banner)

- [ ] **Step 1: `mandates.html` — "Mandat-Report" Button → Deep-Link**

Find/Replace in `mockups/mandates.html`:

```html
<!-- old -->
<button class="btn btn-sm">📄 Mandat-Report</button>
<!-- new -->
<a href="dok-generator.html?template=mandat_report&entity=mandate:cfo-suche" class="btn btn-sm">📄 Mandat-Report</a>
```

- [ ] **Step 2: `assessments.html` — Offerten-Generator-Platzhalter → echter Deep-Link**

Find/Replace in Tab 4:

```html
<!-- old -->
<button class="btn btn-sm" disabled title="Geplante Migration…">📄 Offerte generieren → Dok-Generator</button>
<!-- new -->
<a href="dok-generator.html?template=assessment_offerte&entity=assessment_order:ORD-2026-042" class="btn btn-sm">📄 Offerte generieren</a>
```

- [ ] **Step 3: `candidates.html` Tab 9 — Redirect-Banner**

Einfügen am Top von Tab-9:

```html
<div style="padding:12px 16px;background:var(--accent-soft);border-left:3px solid var(--accent);border-radius:2px;margin-bottom:12px">
  <strong>🆕 Dok-Generator ist jetzt global verfügbar</strong>
  <div class="muted" style="font-size:12px;margin-top:4px">Verwende den neuen globalen Dok-Generator unter Operations für alle Dokument-Typen (nicht nur Kandidat-Dossiers). <a href="dok-generator.html?template=ark_cv&entity=candidate:tf" style="color:var(--accent)">→ Wechseln</a></div>
</div>
```

---

## Task 2.7: P2 Checkpoint

- [ ] **Step 1: Lint + Drift**

```
Skill: ark-lint args="mockups/dok-generator.html"
Skill: mockup-drift-check args="mockups/dok-generator.html"
```

- [ ] **Step 2: Browser-Test**

Durch alle 5 Seed-Templates klicken. Für jedes: Entity auswählen → Step 3 Canvas zeigt realen Content. Step 4 Preview identisch.
Deep-Links aus mandates/assessments/candidates testen.

- [ ] **Step 3: Backup**

```bash
TS=$(date +%Y-%m-%d-%H%M)
cp "/c/ARK CRM/mockups/dok-generator.html" "/c/ARK CRM/backups/dok-generator.html.${TS}-p2-final.bak"
```

---

# PHASE 3 — Polish + History-Preview

**Zielumfang:** ~+200 Zeilen

---

## Task 3.0: Backup P3

```bash
TS=$(date +%Y-%m-%d-%H%M)
cp "/c/ARK CRM/mockups/dok-generator.html" "/c/ARK CRM/backups/dok-generator.html.${TS}-p3.bak"
```

---

## Task 3.1: History-Event-Preview-Drawer

**Files:**
- Modify: `mockups/dok-generator.html` (neuer Drawer vor `</body>`)

- [ ] **Step 1: Drawer + Trigger**

Edit vor `<script src="_shared/layout.js">`:

```html
<!-- History-Preview Drawer (zeigt was nach Klick „Generieren" geloggt wird) -->
<div class="drawer-backdrop" id="drawerBackdrop" onclick="closeDrawer()"></div>

<div id="history-preview" class="drawer">
  <div class="drawer-head">
    <div class="avatar">📋</div>
    <div class="info">
      <h2>History-Event-Vorschau</h2>
      <div class="sub">Was wird am Entity geloggt?</div>
    </div>
    <button class="drawer-close" onclick="closeDrawer('history-preview')">✕</button>
  </div>
  <div class="drawer-body">
    <div class="drawer-section">
      <h4>Event am Entity</h4>
      <dl class="field-grid">
        <dt>Activity-Type</dt><dd><span class="chip chip-accent">Dokument generiert</span></dd>
        <dt>Beschreibung</dt><dd id="histPreviewDesc">📄 Mandats-Offerte generiert + versendet</dd>
        <dt>Akteur</dt><dd><span class="actor-chip">PW</span></dd>
        <dt>Verknüpft</dt><dd id="histPreviewEntity">Mandat · CFO-Suche</dd>
        <dt>Doc-ID</dt><dd class="muted">(wird bei Generierung erzeugt)</dd>
      </dl>
    </div>
    <div class="drawer-section">
      <h4>Email (wenn „Speichern + Email")</h4>
      <dl class="field-grid">
        <dt>Empfänger</dt><dd id="histPreviewRecipient">—</dd>
        <dt>Betreff</dt><dd id="histPreviewSubject">—</dd>
        <dt>Tracking</dt><dd><span class="chip">Open-Tracking aktiv</span></dd>
      </dl>
    </div>
  </div>
  <div class="drawer-foot">
    <button class="btn btn-sm" onclick="closeDrawer('history-preview')">Schliessen</button>
  </div>
</div>

<!-- Preview-Button in Step 5 aktivieren -->
<!-- im Ablage-Panel Button hinzufügen: onclick="openDrawer('history-preview')" -->
```

Zusätzlich Edit: ergänze in Step-5 nach dem Textblock "History-Events werden automatisch am Entity geloggt…":

```html
<button class="btn btn-sm" onclick="openDrawer('history-preview')" style="margin-left:10px">Vorschau anzeigen</button>
```

Plus JS-Override (wie bei assessments.html):

```javascript
window.openDrawer = function(name) {
  const d = document.getElementById(name);
  if (!d) return;
  d.classList.add('open');
  document.getElementById('drawerBackdrop').classList.add('open');
};
window.closeDrawer = function(name) {
  if (name) document.getElementById(name)?.classList.remove('open');
  else document.querySelectorAll('.drawer.open').forEach(d => d.classList.remove('open'));
  document.getElementById('drawerBackdrop')?.classList.remove('open');
};
```

---

## Task 3.2: KB-Bar Final + Accessibility

- [ ] **Step 1: KB-Bar erweitern**

Edit ersetzt KB-Bar:

```html
<div class="kb-bar">
  <span><kbd>←</kbd><kbd>→</kbd> Step wechseln</span>
  <span><kbd>Ctrl+S</kbd> Speichern</span>
  <span><kbd>Ctrl+Enter</kbd> Generieren</span>
  <span><kbd>Esc</kbd> Drawer</span>
  <span><kbd>1</kbd>–<kbd>8</kbd> Kategorie</span>
  <span style="margin-left:auto"><kbd>⌘K</kbd> Template-Suche</span>
</div>
```

---

## Task 3.3: Final Drift + Lint + Commit-Ready

- [ ] **Step 1: Full lint-bundle**

```
Skill: ark-lint args="mockups/dok-generator.html"
Skill: ark-drift-scan args="L3"
Skill: mockup-drift-check args="mockups/dok-generator.html"
```

- [ ] **Step 2: Final Browser-Test komplett**

- Alle 5 Steps via Click-Navigation UND Hotkeys
- Alle 5 Seed-Templates durchgespielt
- Deep-Links von mandates/assessments/candidates funktional
- History-Preview-Drawer öffnet
- Category-Filter + Suche funktional
- KB-Bar komplett

- [ ] **Step 3: Backup**

```bash
TS=$(date +%Y-%m-%d-%H%M)
cp "/c/ARK CRM/mockups/dok-generator.html" "/c/ARK CRM/backups/dok-generator.html.${TS}-p3-final.bak"
```

- [ ] **Step 4: Commit-Vorschlag (falls Git aktiv)**

```
feat(mockup): Global Dok-Generator mockup (Phases 1-3)

Neue Operations-Seite /operations/dok-generator mit 42-Template-Katalog,
5-Step-Workflow (Template → Entity → Ausfüllen → Preview → Ablage),
WYSIWYG-Editor aus Kandidat-Tab-9 generalisiert, Deep-Link-Integration
von Entity-CTAs (mandates, assessments, candidates).

5 Seed-Templates mit realem Content: mandat_offerte_target,
rechnung_mandat_teilzahlung_1_sie, assessment_offerte, ark_cv,
executive_report (NEU — Arkadium-Zusammenfassung Assessment).

Auto-Pull aus Entity-Vollansichten (Kandidat/Mandat/Assessment/Prozess)
via Platzhalter {{entity.feld}} im Canvas.
```

---

# Self-Review

## 1. Spec-Coverage-Check

| Plan §Anforderung | Task | Status |
|-------------------|------|--------|
| §0 Ziel + Prinzipien | T1.0 Skelett + T1.8 Deep-Link | ✓ |
| §1 Template-Katalog 42 | T1.3 Template-Grid | ✓ alle 42 als Cards |
| §1b Auto-Pull Entity | T2.1–2.5 Canvas mit `{{entity.feld}}` Platzhalter | ✓ |
| §2 Datenmodell | Mockup bildet UI ab, Schema in späterer Spec-Doc | ✓ (UI-only) |
| §3 Page-Layout | T1.0 Skelett, T1.2 Sidebar, T1.3–1.7 Steps | ✓ |
| §4 Workflow 5 Steps | T1.1 Indicator, T1.3–1.7 Panes, T1.8 Navigation | ✓ |
| §5 Backend-Endpoints | Mockup zeigt UI, Backend-Spec später | ✓ (UI-only) |
| §6 Integration Entity-CTAs | T2.6 Deep-Link-Edits | ✓ |
| §7 Page-Pattern | T1.5 Editor-Layout, Canvas A4 | ✓ |
| §8 Mockup-Phasen 1/2/3 | 3 Phasen im Plan | ✓ |
| §10 Offene Punkte | Executive Report in T2.5 umgesetzt | ✓ |
| §11 Akzeptanzkriterien | alle durch Tasks abgedeckt | ✓ |

**Lücken:** Keine kritischen.

## 2. Placeholder-Scan

Keine TBD / TODO / "implement later" / "similar to …". Alle HTML-Blöcke vollständig. Alle JS-Funktionen mit Code.

## 3. Type/Name-Konsistenz

- Template-Keys konsistent Plan §1 ↔ T1.3 ↔ T2.1–2.5 ↔ T2.6 Deep-Links
- Step-Nummern 1–5 konsistent
- Entity-Types (mandate/candidate/account/assessment_order/process) konsistent
- Drawer-ID `history-preview` konsistent

Keine Inkonsistenzen.

---

# Execution Handoff

Plan komplett. **Zwei Optionen:**

1. **Subagent-Driven** — pro Task frischer Subagent
2. **Inline Execution** — hier direkt, Batch mit Phasen-Checkpoints (wie bei Assessment-Mockup)

Empfehlung: **Inline Execution, Checkpoint pro Phase** (parity mit Assessment-Mockup-Flow).

Welche?
