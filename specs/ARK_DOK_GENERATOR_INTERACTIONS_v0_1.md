# ARK CRM — Dok-Generator Interactions Spec v0.1

**Stand:** 2026-04-17
**Status:** Erstentwurf — Review ausstehend
**Kontext:** Verhalten, Workflow-State-Machine, CRUD-Flows, Auto-Pull-Logik, Backend-Endpoints, Events des globalen Dok-Generators `/operations/dok-generator`.
**Begleitdokument:** `ARK_DOK_GENERATOR_SCHEMA_v0_1.md`
**Vorrang:** Stammdaten > dieses Dokument > Schema > Mockups
**Globale Patterns:** 11 Global Patterns aus Kandidaten-Interactions v1.2 + `ARK_PIPELINE_COMPONENT_v1_0.md`-Drawer-Standards

---

## TEIL 0: STRUKTURELLE GRUNDENTSCHEIDUNGEN

### Workflow-Architektur

5-Step-Workflow mit State-Machine. Keine Tabs — sequenzieller Step-Flow. Step-Indicator oben, Sidebar 280px persistent, Main wechselt Inhalt.

| Step | State-Variable | Übergang |
|------|----------------|----------|
| 1 Template | `currentTemplate` wird gesetzt | `selectTemplate(key)` |
| 2 Entity | `entityList` wird gefüllt | `selectEntity(id)` oder "Weiter zu Editor" |
| 3 Ausfüllen | `sections[].on`, `params`, Editor-Content | `goToStep(4)` |
| 4 Preview | read-only Canvas | `goToStep(5)` |
| 5 Ablage | `deliveryMode`, Email-Config | `fireGenerate()` → Success-Drawer |

### Erstellungs-Wege

| Weg | Trigger | State |
|-----|---------|-------|
| Direkt | User klickt Sidebar "Dok-Generator" | Step 1 leer |
| Deep-Link | Entity-CTA mit `?template=<key>&entity=<type>:<id>` | Step 3 mit vorbefüllt |
| Wiederholen | "Weiteres Dokument erstellen" aus Success-Drawer | Step 1 leer |
| Entwurf laden | Klick auf "Entwurf" in Sidebar (Phase 2) | Step 3 mit gespeichertem State |

### Prinzipien (bestätigt User-Entscheidungen 2026-04-17)

1. **1 Template pro Dokument-Variante** — separate Templates für Du/Sie, mit/ohne Rabatt, Mandat-Typ (keine Parameter)
2. **Auto-Pull aus Entity-Vollansichten** — DB-Felder live aufgelöst, kein Abtippen
3. **Multi-Entity nur bei `expose`** — Kandidat + optional Mandat-Kontext
4. **Bulk-Mode bei Rechnungs-/Mahnungs-Templates** — N Entities auf einmal
5. **Kein Admin-UI im Mockup** — Templates via DB-Seed

---

## TEIL 1: HEADER & GLOBALE ACTIONS

### "+ Neues Dokument" Button

Resetet Workflow-State (`currentTemplate=null`, `entityList=[]`, `currentStep=1`) und navigiert zu Step 1.

### Counter-Summary

Live-Counts aus `fact_documents` + `dim_document_templates`:
- "38 Templates" = `COUNT(dim_document_templates WHERE is_active=true)`
- "23 heute generiert" = `COUNT(fact_documents WHERE generated_by_doc_gen=true AND DATE(created_at)=TODAY)`
- "312 YTD" = `COUNT(fact_documents WHERE generated_by_doc_gen=true AND YEAR(created_at)=CURRENT_YEAR)`
- "14 Entwürfe offen" = `COUNT(fact_document_drafts WHERE created_by=current_user)` (Phase 2)

---

## TEIL 2: SIDEBAR & NAVIGATION

### Kategorie-Filter

Klick auf `.sidebar-cat-item[data-cat]`:
1. Toggles `active`-Klasse
2. `document.querySelectorAll('.tpl-card')` → show/hide nach `data-cat === cat || cat === 'all'`
3. Keine URL-State-Änderung (Reload resetet Filter)

### Quick-Filter Favoriten

Click auf `.sidebar-cat-item[data-filter="favorites"]`:
1. Filter-Logik via `FAVS`-Set (Phase 1: In-Memory JS-Set, Phase 2: `dim_user_preferences.favorite_templates JSONB`)
2. Template-Grid zeigt nur Templates mit `FAVS.has(data-tpl)`
3. Counter-Badge `#favCount` live-update

### Template-Suche

`#tplSearch` Input → Filter auf Template-Cards:
```js
hit = name.includes(q) || meta.includes(q) || category.includes(q) || template_key.includes(q)
```

Kein Debounce nötig (<40 Templates, instant).

### Zuletzt generiert

Statisch Phase 1 (3 Einträge). Phase 2: Live aus `fact_documents WHERE generated_by_doc_gen=true ORDER BY created_at DESC LIMIT 5`.

---

## TEIL 3: STEP 1 — TEMPLATE WÄHLEN

### Card-Klick-Flow

```
selectTemplate(key):
  1. Validate: TPL_META[key] existiert UND card NOT .soon
  2. currentTemplate = key
  3. entityList = []  (reset)
  4. currentEntity = null
  5. Update Step-2-Hint: "Template: X · erwartet Y"
  6. filterEntityPicker(TPL_META[key].kinds)
  7. Bulk-Hint toggle: isBulkCapable(key) ? show : hide
  8. renderEntityChips()  (leer, aber setup für Multi)
  9. goToStep(2)
```

### `.soon`-Cards

`TPL_META[key].is_active=false` (DB) → `.soon` CSS-Klasse → Click noop + Tooltip "🟡 Template ausstehend". Gilt für `mandat_offerte_time`.

### Favoriten-Toggle

Star-Icon Click (`event.stopPropagation()` verhindert Card-Click):
- `FAVS.has(key)` → delete, sonst add
- Star-Klasse `.active` togglen, Gold-Farbe
- `updateFavCount()` aktualisiert Sidebar-Badge

**Phase 2:** Persist in `dim_user_preferences.favorite_templates` (UPSERT bei jedem Toggle).

---

## TEIL 4: STEP 2 — ENTITY WÄHLEN

### Entity-Group-Visibility

`filterEntityPicker(kinds)`:
```js
document.querySelectorAll('.entity-group').forEach(g => {
  g.style.display = kinds.includes(g.dataset.kind) ? '' : 'none';
});
if (shown === 0) showEmptyState();
```

### Bulk-Logik

`isBulkCapable(key)` = `/^(rechnung|mahnung)_/.test(key)`:
- Bei `true`: Bulk-Hint-Banner zeigen
- Jedes `selectEntity(id)` appent zu `entityList` (statt auto-advance)
- User entscheidet manuell "Weiter zu Editor"

### Multi-Entity (nur `expose`)

`TPL_META.expose = { kinds:['candidate','mandate'], multi:true }`:
- Erst Kandidat wählen → chip + `entity-group[data-kind=mandate]` bleibt sichtbar (weil in `kinds` Array)
- Dann optional Mandat wählen → 2. chip
- User klickt "Weiter" wenn fertig

### Entity-Chip-Rendering

```js
renderEntityChips():
  wrap.style.display = entityList.length > 0 ? 'block' : 'none';
  chips.innerHTML = entityList.map(e => `
    <span class="chip">
      ${e}
      <span onclick="removeEntity('${e}')">✕</span>
    </span>
  `);
  btnAddEntity.style.display = (multi || bulk) ? 'block' : 'none';
```

`removeEntity(id)`: Array-Filter, re-render Chips.

### Single-Entity-Auto-Advance

Bei nicht-multi, nicht-bulk Templates → `selectEntity(id)` advanced sofort zu Step 3.

### Backend-Endpoints Step 2

```
GET /api/v1/document-generator/entity-picker
  query: ?kinds=mandate,assessment_order
  response: {
    mandates: [{ id, name, account_name, stage, ...}],
    assessment_orders: [{ id, order_id, account_name, credits_mix, ...}],
    ...
  }

GET /api/v1/document-generator/entity-picker/search
  query: ?q=CFO-Suche&kinds=mandate
  response: [{ id, name, kind, display_line, ...}]
```

---

## TEIL 5: STEP 3 — EDITOR

### Sektions-Rendering

Beim Step-3-Entry `renderEditorSections(currentTemplate)`:
```js
sections = TEMPLATE_SECTIONS[key] || DEFAULT_SECTIONS;
wrap.innerHTML = sections.map(([label, source, defaultOn]) => `
  <div class="es-item">
    <span class="es-grip">⋮⋮</span>
    <label class="es-check"><input type="checkbox"${defaultOn ? ' checked' : ''}></label>
    <span class="es-label">${label}</span>
    <span class="es-src">${source}</span>
  </div>
`).join('');
```

Sektions-Toggle (Checkbox) ändert entsprechenden Canvas-Block (Phase 2: live via DOM-Visibility-Toggle).

### Drag & Drop Sektionen-Reorder

Phase 1: UI-Placeholder (⋮⋮ Grip visible, noch kein D&D).
Phase 2: HTML5 Drag & Drop API, `editor_schema_jsonb.sections` Order wird im Draft gespeichert.

### Canvas-Content

`renderCanvas()` beim Step-3 + Step-4 Entry:
```js
canvas.innerHTML = CANVAS_CONTENT[currentTemplate] || DEFAULT_PLACEHOLDER;
previewCanvas.innerHTML = CANVAS_CONTENT[currentTemplate] || DEFAULT_PLACEHOLDER;
```

Phase 1 (Mockup): 5 Seed-Templates mit hartcodiertem Content:
- `mandat_offerte_target`
- `rechnung_mandat_teilzahlung_1_sie`
- `assessment_offerte`
- `ark_cv`
- `executive_report`

Übrige 33 Templates: Placeholder "Template-Content folgt — Phase 2".

Phase 2 (React-Port): Backend rendert Template-Body aus DOCX-Source mit Platzhalter-Substitution.

### Platzhalter-Highlighting

`<span class="ph">{{entity.feld}}</span>` visuell gelber Background. Live-Auflösung (Backend):
- GET `/api/v1/document-generator/resolve-placeholders?template=X&entity_refs=[...]`
- Backend JOINs Entity-Tabellen, liefert `{ "mandat.name": "CFO-Suche", "account.name": "Bauherr Muster AG", ... }`
- Frontend substituiert live im Canvas

### Live-Zoom

`applyZoom(scale)`:
```js
canvas.style.transform = 'scale(' + scale + ')';
canvas.style.marginBottom = (scale < 1) ? (-(1-scale) * 180) + 'mm' : '';
```
Scale-Optionen: 0.5 / 0.75 / 1.0 / 1.25 / 1.5

### Page-Break

`<div class="page-break">Seite 1 / 2</div>` statisch in langem Content (Executive Report). Phase 2: Auto-Calc basierend auf Content-Height.

### Parameter-Panel

Sprache / Empfänger-Anrede / Zahlungsfrist — `<select>`-Changes werden in `currentParams`-Object gespeichert. Beim `fireGenerate()` an Backend gesendet.

### Anon-Panel (nur `expose`)

`display: (currentTemplate === 'expose') ? 'block' : 'none'` gesetzt in `goToStep(3)`.
4 Toggles für Anonymisierungs-Level. Backend verwendet bei PDF-Render.

---

## TEIL 6: STEP 4 — PREVIEW

Read-only Clone des Step-3-Canvas (via `renderCanvas()` das beide füllt).
- Kein Editor-Toolbar
- Clickable: "← Zurück" (Step 3) + "↓ PDF" (Phase 2 Direct-Export) + "Weiter zu Ablage →" (Step 5)

---

## TEIL 7: STEP 5 — ABLAGE + DELIVERY

### Ablage-Ziel auto-populiert

Bei `goToStep(5)`:
```js
const m = TPL_META[currentTemplate];
document.getElementById('saveEntity').textContent = currentEntity || '—';
document.getElementById('saveLabel').textContent = m.label;
document.getElementById('saveFolder').textContent = m.folder;
document.getElementById('saveRetention').textContent = m.retention;
```

### Delivery-Radio

3 Optionen, Default `save_and_email`:
- `save_only`
- `save_and_email` (Email-Panel zeigt Empfänger/Betreff/Template)
- `save_and_download`

### History-Event-Preview

Button "Vorschau anzeigen" → `openDrawer('history-preview')`. Zeigt:
- Activity-Type: "Dokument generiert"
- Beschreibung: `m.label + " generiert + versendet"`
- Empfänger (bei Email)
- Ablage-Ordner + Retention

### `fireGenerate()` Flow

```js
function fireGenerate() {
  // 1. Validate
  if (!currentTemplate || !currentEntity) return;
  
  // 2. Collect params
  const params = {
    sprache: getSelectValue('lang'),
    empfaenger_anrede: getSelectValue('anrede'),
    zahlungsfrist_tage: getSelectValue('frist'),
    anonymisierung: getAnonFlags()  // nur expose
  };
  
  // 3. Prepare request
  const body = {
    template_key: currentTemplate,
    entity_refs: entityList.map(parseEntityRef),
    params,
    delivery: getDeliveryMode(),
    email_options: delivery === 'save_and_email' ? {
      recipient_contact_id, subject, email_template_key
    } : null
  };
  
  // 4. Call backend (Phase 1: mock)
  POST /api/v1/documents/generate → { document_id, pdf_signed_url }
  
  // 5. Show Success-Drawer
  populate #gen-success with doc_id, template, entity, timestamp
  wire "Zum Entity" buttons to entity URL (mandates.html / assessments.html / etc.)
  openDrawer('gen-success')
}
```

### Success-Drawer (`#gen-success`)

Standard `.drawer` (540px, Gold-Akzent im Head). 4 Sektionen:

1. **Dokument-Details**: Doc-ID · Template · Entity · Folder · Timestamp · Akteur
2. **Email-Versand** (conditional): Empfänger · Betreff · Status
3. **Nachfolge-Aktionen**: 4 Buttons (Zum Entity / Weiteres Doc / PDF / Email-Kopie)
4. **History-Event-Block**: zeigt was am Entity geloggt wurde

---

## TEIL 8: AUTO-PULL AUS ENTITY-VOLLANSICHTEN

**Prinzip (User-Vorgabe 2026-04-17):** Beim Generieren werden alle Felder automatisch aus der Entity-DB gezogen. Kein manuelles Abtippen.

### 8.1 Kandidat-Dokumente

**Source:** Kandidaten-Vollansicht (`dim_candidates_profile` + abhängige Tables)

Gezogene Felder:
- **Stammdaten**: `vorname`, `nachname`, `foto_url`, `geburtsdatum → alter`, `wohnort_ort`, `wohnort_kanton`, `nationalitaet`, Sprachen (`bridge_candidate_languages`)
- **Kontakt**: `email_primary`, `phone_primary`, `linkedin_url`
- **Briefing**: aus `fact_candidate_briefing` (aktuelle Version) — `kurzprofil_text`, `salary_aktuell_chf`, `salary_gewuenscht_chf`, Kompetenzen, Bewertung-Grade
- **Werdegang**: `fact_candidate_werdegang` — Arbeitsstationen (Position/Arbeitgeber/Zeitraum), Ausbildungen, Projekte (via `project_id` FK)
- **Assessment**: letzte `fact_candidate_assessment_version` pro Typ (MDI, Relief, EQ, ASSESS)
- **Dokumente**: `fact_documents` WHERE `entity_type='candidate' AND document_label IN ('Diplom','Arbeitszeugnis','Zertifikat')` → Anhänge für ARK CV

**Anonymisierung (nur `expose`):**
- `vorname + nachname` → "Kandidat m/w"
- `foto_url` → leer
- Firmennamen in Werdegang → optional via `account_anonymize` JSONB-Mapping
- `wohnort_ort` → Kanton only

### 8.2 Mandat-Dokumente

**Source:** `/mandates/[id]` Vollansicht

Gezogene Felder:
- **Grunddaten**: `fact_mandate.mandate_name`, `mandate_type`, `kickoff_date`, `status`, `owner_am.initialen/name`
- **Honorar**: `honorar_pauschale_chf` (Target) · `monthly_fee_chf` (Taskforce) · `honorar_override_pct` · `garantie_months`
- **Account**: `fact_accounts.account_name`, `address_*`, `handelsregister_uid`, `bank_iban`
- **Hiring Manager**: `dim_account_contacts` primary, Anrede/Titel/Vorname/Nachname/Email/Phone
- **Teilzahlungen**: `fact_mandate_billing` WHERE stage_match → welche Rate aktuell fällig
- **Option IX**: `fact_mandate_option` WHERE option_type='assessment' → Assessment-Order-Referenz

### 8.3 Assessment-Dokumente

**Source:** `/assessments/[id]` Vollansicht

Gezogene Felder:
- **Auftrag**: `fact_assessment_order.id`, `package_name`, `partner`, `ordered_at`, `price_chf`
- **Credits**: `fact_assessment_order_credits` aggregated (Typ × Quantity × Einzelpreis)
- **Runs**: `fact_assessment_run` verbunden — Kandidat-Name, Typ, Termin, Status
- **Billing**: `fact_assessment_billing` — Rechnungs-Status

**Executive Report speziell:**
- Source: `fact_assessment_run` + zugehöriger Kandidat + `fact_candidate_assessment_version`
- Gezogen: aktuelle MDI/Relief/EQ/ASSESS-Versionen mit `result_data JSONB`
- **Arkadium-manuelle Felder** (im Editor frei ausfüllbar): `empfehlung_text`, `pro_argumente`, `red_flags`, `entwicklungsfelder`, `referenzen_zusammenfassung`

### 8.4 Best-Effort-Rechnungen

**Source:** `fact_process_core` mit `status='Placed'`

Gezogene Felder:
- Kandidat-Name, Job-Titel, Placement-Datum (`placed_at`), TC-Salär (`salary_candidate_actual`)
- Honorar-Staffel via `dim_honorar_settings` lookup gegen Salär
- Rabatt% (bei `_mit_rabatt` Templates) via Template-Param
- Account-Billing-Adresse aus `fact_accounts`

### 8.5 Reportings (Tenant/Mitarbeiter/Zeitraum)

**Source:** Aggregationen über mehrere Tabellen

**AM-Reporting:**
- `fact_mandate` gefiltert auf `mandate_owner_id=AM, kickoff_date BETWEEN zeitraum`
- KPI-Aggregation: Count Mandate, Count Placements, Sum Umsatz, Pipeline-Verteilung

**CM-Reporting:**
- `fact_history` WHERE `actor_id=CM, created_at BETWEEN zeitraum` — Aktivitäten-Stats
- `fact_process_core` WHERE `cm_user_id=CM` — Prozess-Stats

**Monatsreporting-CM:**
- Analog CM-Reporting, fixe Monats-Grenzen

**Hunt-Reporting:**
- `fact_mandate` + `fact_history` (Calls) + `fact_candidate_longlist` — Longlist-/Call-Stats

### 8.6 Factsheet Personalgewinnung

**Source:** `fact_accounts` + generische Arkadium-Methodik-Referenzen

Gezogene Felder:
- `account_name`, `address_*`, `branche`, `customer_class`, `sparten_labels`
- Referenz-Cases (statisch aus `dim_arkadium_case_studies` Phase 2; Phase 1 hart-codiert)

### 8.7 Technische Umsetzung

**Backend:** `POST /api/v1/documents/resolve-placeholders`
```json
{
  "template_key": "mandat_offerte_target",
  "entity_refs": [{ "type": "mandate", "id": "uuid-xyz" }]
}
→ 
{
  "placeholders": {
    "mandat.name": "CFO-Suche",
    "mandat.honorar_pauschale": "75'000",
    "account.name": "Bauherr Muster AG",
    "owner_am.vorname": "Peter",
    "owner_am.nachname": "Wiederkehr",
    ...
  },
  "missing_required": []  // Warn wenn Pflichtfeld leer
}
```

**Editor zeigt gelöste Werte** — editierbar für Einzelfall-Override (Override wird in `params_jsonb.overrides` gespeichert).

**Warn-Indicator** bei fehlenden Pflichtfeldern (z.B. Account hat kein Hiring-Manager-Kontakt) → rote Markierung im Editor an Platzhalter.

---

## TEIL 9: BACKEND-ENDPOINTS

```
GET    /api/v1/document-templates
  query: ?category=mandat_offerte&target_entity_type=mandate
  response: [{ key, display_name, category, kinds, is_active, ... }]

GET    /api/v1/document-templates/:key
  response: { ...full template with placeholders_jsonb, editor_schema_jsonb }

POST   /api/v1/documents/generate                        ← Master-Endpoint
  body:
    template_key: 'mandat_offerte_target'
    entity_refs: [{ type: 'mandate', id: 'uuid' }]
    params: { sprache: 'de', empfaenger_anrede: 'Herr', zahlungsfrist_tage: 30 }
    overrides: { 'section.custom_paragraph': 'freier Text …' }
    delivery: 'save_only' | 'save_and_email' | 'save_and_download'
    email_options: { recipient_contact_id, subject, email_template_key } (bei email)
  response:
    { document_id, pdf_signed_url, action_result: 'saved' | 'saved_and_sent' }

POST   /api/v1/documents/resolve-placeholders            ← Für Live-Canvas-Render
  body: { template_key, entity_refs }
  response: { placeholders: { "x.y": "value", ... }, missing_required: [...] }

POST   /api/v1/documents/:id/regenerate
  body: { new_template_version?, params_overrides? }
  response: { document_id, pdf_signed_url }

POST   /api/v1/documents/:id/email                       ← Nachträglicher Email-Versand
  body: { recipient_contact_id, subject, email_template_key }
  response: { email_id, status: 'sent' }

GET    /api/v1/document-generator/recent                 ← Sidebar Zuletzt
  query: ?limit=5&user_id=current
  response: [{ doc_id, display_name, entity_label, created_at, actor }]

GET    /api/v1/document-generator/drafts                 ← Sidebar Entwürfe (Phase 2)
  query: ?user_id=current
  response: [{ draft_id, template_key, entity_refs, params, updated_at }]

POST   /api/v1/document-generator/drafts                 ← Auto-Save Draft (Phase 2)
  body: { template_key, entity_refs, params, editor_state }
  response: { draft_id }
```

### Wrapper-Mapping alter Endpoints

Bestehende punktuelle Endpoints werden zu Wrappern:
- `POST /api/v1/assessments/:id/generate-quote` → intern `POST /api/v1/documents/generate` mit `template_key='assessment_offerte'`, `entity_refs=[{type:'assessment_order', id}]`
- `POST /api/v1/ai/generate-dossier` → intern `POST /api/v1/documents/generate` mit `template_key='ark_cv'` / `'abstract'` / `'expose'`

Alte Endpoints bleiben backward-compatible; neue Implementierungen sollen Master-Endpoint nutzen.

---

## TEIL 10: EVENTS & HISTORY

### Event-Katalog

| Event | Scope | Payload |
|-------|-------|---------|
| `document_generated` | Entity (aus `entity_refs`) + Dokument | `{ doc_id, template_key, params, delivery_mode }` |
| `document_emailed` | Entity + Kontakt | `{ doc_id, recipient_contact_id, email_id, subject }` |
| `document_regenerated` | Entity + Dokument | `{ doc_id, new_version, reason }` |
| `template_favorited` / `_unfavorited` | User | `{ template_key }` (Phase 2) |
| `draft_saved` | User | `{ draft_id, template_key }` (Phase 2) |

### Doppelspur-Regel

Bei Multi-Entity-Docs wird Event in **jeder** verknüpften Entity-History geloggt. Z.B. Exposé für Kandidat + Mandat-Kontext → `document_generated` in Kandidat-History UND Mandat-History.

---

## TEIL 11: DEEP-LINK-INTEGRATION

### URL-Schema

```
/operations/dok-generator?template=<template_key>&entity=<type>:<id>
```

Beispiele:
- `?template=mandat_offerte_target&entity=mandate:c41-uuid`
- `?template=ark_cv&entity=candidate:tf-uuid`
- `?template=assessment_offerte&entity=assessment_order:ord-uuid`

Multi-Entity via mehrere `entity=`-Params oder Array-Notation (Phase 2).

### initFromUrl() Logic

```js
function initFromUrl() {
  const p = new URLSearchParams(location.search);
  const tpl = p.get('template');
  const entity = p.get('entity');
  if (tpl && TPL_META[tpl]) {
    selectTemplate(tpl);
    if (entity) selectEntity(decodeURIComponent(entity));
    // → Landet auf Step 3 (falls multi) oder direkt Editor
  } else {
    goToStep(1);
  }
}
```

### Entity-CTAs in Detail-Masken

Bestehende Entity-CTAs wurden in Mockups bereits auf Deep-Links migriert:

| Mockup | Button | Deep-Link |
|--------|--------|-----------|
| `mandates.html` | 📄 Mandat-Report | `?template=mandat_report&entity=mandate:CFO-Suche` |
| `assessments.html` Tab 4 | 📄 Offerte generieren | `?template=assessment_offerte&entity=assessment_order:ORD-2026-042` |
| `candidates.html` Tab 9 | Redirect-Banner | `?template=ark_cv&entity=candidate:Tobias Furrer` |

Weitere Migration Phase 1.5:
- `accounts.html` → Factsheet-CTA
- `mandates.html` → Rechnung-Stage-N-CTAs
- `processes.html` → Best-Effort-Rechnung-CTA (bei Placement)

### Back-Link aus Success-Drawer

Nach Generate: `#gen-success` Drawer zeigt Button "🔗 Zum Entity". `fireGenerate()` wired das basierend auf `currentEntity`-String-Match:
```js
if (entityLower.includes('mandat')) entityHref = 'mandates.html';
else if (entityLower.includes('assessment')) entityHref = 'assessments.html';
// ...
```

Phase 2: URL-Mapping aus `TPL_META[key].target_entity_types` statt String-Match.

---

## TEIL 12: BERECHTIGUNGEN (Spezialfälle)

### Template-Sichtbarkeit

Alle User sehen alle Templates (keine pro-Rolle-Filter in Phase 1). Berechtigungen greifen erst beim Generate:

```
POST /api/v1/documents/generate
  → RBAC-Check:
    - User-Rolle muss `template.allowed_roles` include
    - `entity.access_control` muss User-Scope matchen (Owner-AM, etc.)
  → bei Violation: 403 + Toast "Keine Berechtigung für dieses Template/Entity"
```

### Admin-Override

Admin kann jedes Template generieren (Bypass `allowed_roles`). Audit-Log-Eintrag `document_generated_by_admin_override` mit Begründung.

### Entity-spezifische Guards

- Mandat-Offerte nur für Mandat im Status `offered` (nicht `ordered` oder höher — Änderungen via Regenerate-Flow)
- Best-Effort-Rechnung nur bei `fact_process_core.status='Placed'`
- Rückerstattung nur bei `early_exit_flag=true`
- Executive Report nur für `fact_assessment_run.status='completed'` mit `result_data IS NOT NULL`

---

## TEIL 13: VALIDIERUNGS-REGELN

| Regel | Enforcement |
|-------|------------|
| Template muss existieren und `is_active=true` | Hard (404 bei missing) |
| Entity-Refs müssen Template-Kinds matchen | Hard (400 bei mismatch) |
| Multi-Entity-Template braucht mind. 1 Entity je Kind | Hard |
| Required Params gesetzt (z.B. `sprache`) | Hard |
| Pflicht-Platzhalter alle gelöst (z.B. `mandat.name IS NOT NULL`) | Warn (rote Markierung im Editor) |
| Email-Delivery: `recipient_contact_id` muss zum Entity-Account gehören | Hard |
| PDF-Render nicht > 10 MB | Hard (413 bei Overflow) |

---

## TEIL 14: PHASE 1.5 / PHASE 2 VORMERKLISTE

| Feature | Phase |
|---------|-------|
| Template-Admin-UI (CRUD `dim_document_templates`) | 2 |
| EN-Sprach-Support via LLM-Übersetzung | 1.5 |
| Draft-Auto-Save beim Step-Wechsel | 1.5 |
| Template-Version-Management (Semver) | 2 |
| DOCX-Upload für neue Templates (automatische Placeholder-Extraktion) | 2 |
| Multi-Entity-Bulk-Generation (1 Klick → N Docs) | 1.5 |
| Template-Favoriten pro User persistent | 1.5 |
| History-Event-Preview-Drawer interaktiv (Override) | 2 |
| Real-time Collaborative Editing (2 User gleichzeitig) | 2 |
| AI-Assist für manuelle Sektionen (z.B. Executive Report Empfehlung) | 2 |

---

## TEIL 15: VERKNÜPFUNGEN

### Zum Account
- Factsheet Personalgewinnung direkt am Account
- Alle Mandat-/Assessment-/Best-Effort-Docs sind indirekt über Mandat/Order/Prozess verknüpft mit Account
- Account-Tab 12 Dokumente zeigt aggregiert alle Docs aller verknüpften Entities

### Zum Mandat
- Mandat-Offerte, Teilzahlungs-Rechnungen, Kündigung, Mahnung, Mandat-Report, Reporting-Hunt
- Mandat-Tab 6 Dokumente zeigt alle mandats-spezifischen Docs

### Zum Kandidat
- ARK CV, Abstract, Exposé, Referenzauskunft, Referral
- Kandidat-Tab 8 Dokumente zeigt alle kandidat-spezifischen Docs

### Zum Assessment
- Assessment-Offerte, -Rechnung, Executive Report
- Assessment-Tab 4 Dokumente (Order-scoped)

### Zum Prozess
- Best-Effort-Rechnung, Rückerstattung
- Prozess-Tab 3 Dokumente

---

## TEIL 16: METHODIK-REFERENZ

- Event-System wie in [[event-system]]
- Berechtigungen wie in [[berechtigungen]]
- Drawer-Pattern gem. `ARK_PIPELINE_COMPONENT_v1_0.md` Section 4 (Success-Drawer 540px, Standard-Drawer-Klassen)
- Audit-Logging für alle Generate-Aktionen + Template-Admin-Änderungen

---

## Related Specs / Wiki

- `ARK_DOK_GENERATOR_SCHEMA_v0_1.md` (Begleitdokument)
- `ARK_DOK_GENERATOR_MOCKUP_PLAN.md` + `ARK_DOK_GENERATOR_MOCKUP_IMPL_v1.md`
- `ARK_KANDIDATENMASKE_INTERACTIONS_v1_3.md` Tab 9 (wird migriert, Redirect-Banner im Mockup)
- `ARK_MANDAT_DETAILMASKE_INTERACTIONS_v0_3.md` (Deep-Link aus Mandat-Report-CTA)
- `ARK_ASSESSMENT_DETAILMASKE_INTERACTIONS_v0_3.md` (Deep-Link aus Offerte-CTA, Executive Report)
- `ARK_ACCOUNT_DETAILMASKE_INTERACTIONS_v0_3.md` (Phase 1.5 Factsheet-Deep-Link)
- `ARK_BACKEND_ARCHITECTURE_v2_5.md` → v2.6 (neue Endpoints-Sektion ausstehend)
- `ARK_FRONTEND_FREEZE_v1_10.md` → v1.11 (neue Detailmaske ausstehend)
- [[dok-generator]], [[template-versionierung]], [[auto-pull]]
- [[detailseiten-guideline]]
