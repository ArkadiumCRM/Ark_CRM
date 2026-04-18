# ARK CRM — Dok-Generator Schema v0.1

**Stand:** 2026-04-17
**Status:** Erstentwurf — Review ausstehend
**Quellen:** Wiki [[dok-generator]], ARK_FRONTEND_FREEZE_v1_10.md §Tab-9 (Kandidat-Dok-Generator — migriert), ARK_DATABASE_SCHEMA_v1_3.md §14 (`fact_documents`), ARK_STAMMDATEN_EXPORT_v1_3.md §51 (`dim_assessment_types` als Template-Muster), `mockups/dok-generator.html` (1'321 Zeilen), `raw/General/` + `raw/Assessments/` (echte DOCX-Templates)
**Begleitdokument:** `ARK_DOK_GENERATOR_INTERACTIONS_v0_1.md`
**Plan-Referenz:** `ARK_DOK_GENERATOR_MOCKUP_PLAN.md` + `ARK_DOK_GENERATOR_MOCKUP_IMPL_v1.md`
**Vorrang:** Stammdaten > dieses Schema > Frontend Freeze > Mockups

---

## 0. ZIELBILD

Vollseite `/operations/dok-generator` — zentrales Tool zur Generierung aller Dokumente, die Arkadium im Kundenkontakt erzeugt. Ersetzt verstreute CTAs in Entity-Detailmasken (Mandat „📄 Offerte generieren", Assessment „📄 Offerte generieren", Kandidat-Tab-9 „Dok-Generator" etc.) durch ein zentrales Workflow-Tool.

**Prinzipien:**
- **1 Template pro Dokument-Variante** — keine Duplikate vom gleichen Inhalt
- **Du/Sie + Rabatt + Mandat-Typ als separate Templates** (nicht Parameter) — ganzer Text unterscheidet sich
- **Auto-Pull aus Entity-Vollansichten** — Felder werden automatisch aus Kandidat/Mandat/Assessment/Prozess gezogen, kein manuelles Abtippen
- **Deep-Link-fähig** von allen Entity-CTAs (`?template=<key>&entity=<type>:<id>`)
- **Zentrales Template-Katalog** (`dim_document_templates`) — nicht pro Entity-Modul
- **WYSIWYG-Editor** mit A4-Canvas, ARKADIUM-Branding (navy #1a2540, gold #b99a5a)

**Primäre Nutzer:**
- **AM (Account Manager):** Mandats-Offerten, Rechnungen, Stellenbriefings, Mandat-Reports
- **CM (Candidate Manager):** ARK CV, Abstract, Exposé, Referenzauskünfte, Interviewguides
- **Backoffice:** Rechnungen, Mahnungen, Spesen-Belege, Rückerstattungen
- **Admin:** Executive Reports (Assessment-Auswertungen), Reportings, Factsheets

**Abgrenzung:**
- **Kandidat-Detailmaske Tab 9** bleibt vorerst bestehen (Migrations-Banner zeigt Weg zu global Dok-Generator), Phase 2 Deprecated
- **Kein Admin-UI** im Mockup für Template-CRUD — Templates via DB-Seed, Admin editiert per SQL-Script bzw. späterer Admin-Seite

---

## 1. DESIGNSYSTEM-REFERENZ

Erbt aus [[kandidatenmaske-schema]] § 0 + Kandidat-Tab-9 Editor-Styles (generalisiert).

### Farb-Tokens

| Token | Hex | Verwendung |
|-------|-----|-----------|
| Doc-Gen-Primär | Accent (gold) `#dcb479` | Step-Active-Indicator, aktive Template-Card |
| Template-Category | Verschiedene | Icon-Farbe pro Kategorie-Badge |
| A4-Canvas-Brand-Navy | `#1a2540` | Überschriften, Branding |
| A4-Canvas-Brand-Gold | `#b99a5a` | Akzent, Platzhalter-Highlight |
| Platzhalter-Highlight | `color-mix(gold 20%)` | `<span class="ph">`-Hintergrund |
| Page-Break-Dashed | `#ccc` | Dashed-Linie bei Mehrseiten |
| Success-Gold | Gold-Akzent | Success-Drawer nach Generieren |

### Mockup-Datei

`mockups/dok-generator.html` (1'321 Zeilen, Phase 1-3 + 6 Improvements umgesetzt).

---

## 2. GESAMT-LAYOUT

```
┌──────────────────────────────────────────────────────────────────┐
│ Breadcrumb: Home / Operations / Dok-Generator                     │
├──────────────────────────────────────────────────────────────────┤
│ HEADER                                                             │
│ 📝 Dok-Generator                        [+ Neues Dokument]        │
│ 38 Templates · 23 heute · 312 YTD · 14 Entwürfe                   │
├──────────────────────────────────────────────────────────────────┤
│ STEP-INDICATOR (horizontal, 5 Steps)                              │
│ ● 1 Template → ● 2 Entity → ○ 3 Ausfüllen → ○ 4 Preview → ○ 5 Ablage│
├────────────────┬─────────────────────────────────────────────────┤
│ SIDEBAR (280px)│  MAIN                                             │
│                │                                                   │
│ 🔍 Suche       │  [wechselt je nach Step:                         │
│                │   Step 1: Template-Grid (38 Cards)               │
│ KATEGORIEN     │   Step 2: Entity-Picker (dynamisch gefiltert)    │
│ Alle (38)      │   Step 3: WYSIWYG-Editor (Sidebar + A4-Canvas)   │
│ Mandat-Off.(4) │   Step 4: PDF-Preview (read-only)                │
│ Mandat-Rech.(10)│  Step 5: Ablage + Delivery]                     │
│ Erfolgsbasis(8)│                                                   │
│ Assessment (3) │                                                   │
│ Rückerst. (1)  │                                                   │
│ Kandidat (5)   │                                                   │
│ Reportings (7) │                                                   │
│                │                                                   │
│ QUICK-FILTER   │                                                   │
│ ⭐ Favoriten   │                                                   │
│ Zuletzt genutzt│                                                   │
│ Entwürfe       │                                                   │
│ Kunde-facing   │                                                   │
│ Intern         │                                                   │
│                │                                                   │
│ ZULETZT        │                                                   │
│ RE-2026-0094   │                                                   │
│ Offerte Bauh.  │                                                   │
│ ARK-CV Furrer  │                                                   │
├────────────────┴─────────────────────────────────────────────────┤
│ KB-HINTS: ←→ Step · Ctrl+S Save · Ctrl+Enter Generate · Esc       │
└──────────────────────────────────────────────────────────────────┘
```

**Layout-Patterns:**
- Kein Tab-System — 5 Workflow-Steps sequenziell im Main-Bereich
- Step-Indicator oben sticky unter Page-Banner
- Sidebar 280px sticky, Main scrollt

---

## 3. BREADCRUMB

```
Home / Operations / Dok-Generator        🔍 Ctrl+K  [Avatar]
```

3-stufig, Home klickbar → CRM-Shell, Operations non-link.

**Alternative Einstiege (Deep-Link aus Entity):**
URL-Params `?template=<key>&entity=<type>:<id>` überspringen Step 1/2 direkt zu Step 3.

---

## 4. HEADER

### 4.1 Titel-Zeile

```
📝 Dok-Generator                            [+ Neues Dokument]
38 Templates · 23 heute generiert · 312 YTD · 14 Entwürfe offen
```

| Element | Inhalt | Interaktion |
|---------|--------|-------------|
| Titel | statisch | — |
| Counter-Summary | live | — |
| "+ Neues Dokument" | Button | `onClick` → `goToStep(1)` |

### 4.2 Keine Snapshot-Bar

Bewusst weggelassen — es gibt keine einzelne Entity mit KPIs im Kontext dieser Maske. Step-Indicator ersetzt Snapshot.

---

## 5. STEP-INDICATOR

Horizontal, 5 Steps mit Nummern-Badges. Aktiver Step goldakzent. Done-Steps grüngolden.

```
● 1 Template → ● 2 Entity → ○ 3 Ausfüllen → ○ 4 Preview → ○ 5 Ablage
                                                              [← Zurück] [Weiter →]
```

**Keyboard:** `←`/`→` navigiert Steps. Navigation-Buttons rechts.

---

## 6. STEP 1 — TEMPLATE WÄHLEN

### 6.1 Template-Grid

Auto-fill Grid (3-4 Spalten je nach Viewport), Cards `min-width:220px`.

### 6.2 Template-Card

```
┌────────────────┐
│ 📄 [Icon]    ⭐│  ← Star = Favoriten-Toggle
│ Mandat-Offerte │
│ Target         │
│ ────────────── │
│ Mandat · DE    │
└────────────────┘
```

| Element | Source |
|---------|--------|
| Icon | `category` → Emoji (📄/💰/🔔/📊/🎭/📋/👤/🤝/📞/💬/↩/✉) |
| Name | `dim_document_templates.display_name` |
| Meta-Zeile | `target_entity_types` + `default_language` |
| Star-Icon | Favoriten-State (local state / Phase 2: user pref) |
| `soon`-Label | bei `is_active=false` (z.B. `mandat_offerte_time`) |

### 6.3 Template-Katalog (38 aktive Templates Phase 1)

Siehe §14 `dim_document_templates` Seed-Daten. Gruppiert in 7 Kategorien:

| Kategorie | Count | Beispiele |
|-----------|-------|-----------|
| `mandat_offerte` | 4 | Target, Taskforce, Time (ausstehend), Auftragserteilung Opt. Stage |
| `mandat_rechnung` | 10 | Teilzahlung 1/2/3 × Du/Sie, Opt. Stage, Kündigung, Mahnung × Du/Sie |
| `best_effort` | 8 | Rechnung/Mahnung × mit/ohne Rabatt × Du/Sie |
| `assessment` | 3 | Offerte, Rechnung, Executive Report (NEU) |
| `rueckerstattung` | 1 | Rechnung Rückerstattung |
| `kandidat` | 5 | ARK CV, Abstract, Exposé, Referenzauskunft, Referral |
| `reporting` | 7 | AM/CM/Monats/Hunt/Team-Leader-Reporting, Mandat-Report, Factsheet |

### 6.4 Card-Click-Verhalten

Klick → `selectTemplate(key)`:
1. `soon`-Card blockiert (Tooltip "Template ausstehend")
2. Aktive Card: `currentTemplate = key`, `entityList = []`, filtert Entity-Picker auf `TPL_META[key].kinds`, zeigt Bulk-Hint wenn `isBulkCapable`
3. Auto-Advance zu Step 2

---

## 7. STEP 2 — ENTITY WÄHLEN

### 7.1 Entity-Picker Layout

```
┌──────────────────────────────────────────┐
│ Template: Mandat-Offerte Target          │
│ Erwartet: Mandat (Target)                │
│                                           │
│ [💡 Bulk-Modus verfügbar] (conditional)  │
│                                           │
│ Gewählte Entities (conditional):         │
│ [Mandat · CFO-Suche ✕]                   │
│ [+ Weitere Entity]    [Weiter zu Editor →]│
│                                           │
│ 🔍 Target-Entity *                        │
│ [Autocomplete-Input]                      │
│                                           │
│ ──────────── AKTIVE MANDATE ────────────  │
│ CFO-Suche · Bauherr Muster AG             │
│ Taskforce · Stage 2/3 · Pauschale 75k     │
│ ...                                       │
│                                           │
│ ──────────── ASSESSMENT-ORDERS ─────────  │
│ (gefiltert: nur wenn kinds include it)    │
└──────────────────────────────────────────┘
```

### 7.2 Entity-Groups (dynamisch gefiltert)

9 Entity-Kinds, jede als eigener HTML-Block `<div class="entity-group" data-kind="...">`:

| Kind | Source-Entities | Für Templates |
|------|-----------------|---------------|
| `mandate` | `fact_mandate` | Mandat-Offerten, -Rechnungen, -Mahnung, Mandat-Report, Reporting Hunt |
| `rechnung` | `fact_mandate_billing`/`fact_assessment_billing`/`fact_process_finance` | Mahnungen |
| `process` | `fact_process_core` (mit Placement) | Best-Effort-Rechnungen, Rückerstattung |
| `assessment_order` | `fact_assessment_order` | Assessment-Offerte, -Rechnung |
| `assessment_run` | `fact_assessment_run` | Executive Report |
| `candidate` | `dim_candidates_profile` | ARK CV, Abstract, Exposé, Referenzauskunft, Referral |
| `account` | `fact_accounts` | Factsheet Personalgewinnung |
| `mitarbeiter` | `dim_mitarbeiter` | CM-Reporting, Monatsreporting |
| `tenant` | Tenant-Level | AM-Reporting, Team-Leader-Reporting |

**Filter-Logik:** `filterEntityPicker(kinds)` zeigt nur Groups mit `data-kind in kinds`, verstickt alle anderen. Empty-State bei 0 Matches.

### 7.3 Multi-Entity + Bulk

**Multi-Entity** (Template-Flag `multi:true`):
- Nur `expose` (Exposé): Kandidat + optional Mandat-Kontext
- Nach 1. Auswahl: Chip + "+ Weitere Entity"-Button + "Weiter zu Editor"-Button

**Bulk-Mode** (via `isBulkCapable(key)` = `/^(rechnung|mahnung)_/`):
- Bulk-Hint-Banner erscheint
- Mehrere Entities via Auto-Append zu `entityList`
- User wählt explizit "Weiter zu Editor"

### 7.4 Entity-Click-Verhalten

`selectEntity(id)`:
- Single-Template: auto-advance zu Step 3
- Multi/Bulk-Template: zu `entityList` appen, Chips rendern, Weiter-Button zeigen

### 7.5 Deep-Link

URL-Param `?entity=<type>:<id>` überspringt Step 2 bei vorhandenem Template.

---

## 8. STEP 3 — EDITOR (WYSIWYG + CANVAS)

### 8.1 Layout

```
┌────────────────┬─────────────────────────────────────────────┐
│ EDITOR-SIDEBAR │ EDITOR-MAIN                                 │
│ (260px)        │                                             │
│                │ [Toolbar: B I U · H1 H2 · • 1. · 🔗 🖼  Zoom]│
│ Sektionen      │                                             │
│ (drag&drop)    │ ┌───────────────────────────────────────┐   │
│ ⋮⋮ □ Briefkopf │ │                                       │   │
│ ⋮⋮ ☑ Anrede    │ │    [A4 Canvas 210×297mm]             │   │
│ ⋮⋮ ☑ Hauptteil │ │                                       │   │
│ ...            │ │    ARKADIUM-Branding                  │   │
│                │ │    Platzhalter {{...}} highlighted    │   │
│ Parameter      │ │                                       │   │
│ Sprache [DE]   │ └───────────────────────────────────────┘   │
│ Anrede [Herr]  │                                             │
│ Frist [30 Tg]  │ [Page-Break bei langem Content]             │
│                │                                             │
│ Anon-Panel     │                                             │
│ (conditional,  │                                             │
│  nur expose)   │                                             │
│                │                                             │
└────────────────┴─────────────────────────────────────────────┘
```

### 8.2 Editor-Sidebar (260px, sticky)

**Sektionen-Liste** (dynamisch aus `TEMPLATE_SECTIONS[key]` oder `DEFAULT_SECTIONS`):
- Drag-Handle ⋮⋮ für Reihenfolge (Phase 2 echte D&D)
- Checkbox zum Ein-/Ausschalten
- Source-Tag: `auto` (System) / `entity` (aus DB) / `manuell` (Freitext)

**Parameter-Panel:**
- Sprache (DE · EN-Phase 2)
- Empfänger-Anrede (Sehr geehrter Herr / Sehr geehrte Frau / Liebes Team / Gleichgestellt)
- Zahlungsfrist (30 / 14 Tage) — nur Rechnungs-Templates

**Anon-Panel** (nur wenn `currentTemplate == 'expose'`):
- Checkboxen: Name anonymisieren · Foto entfernen · Firmennamen anonymisieren · Wohnort → Kanton only

### 8.3 Editor-Main

**Toolbar:** Bold/Italic/Underline · H1/H2 · Bullets/Ordered · Link/Image · Zoom-Select (50/75/100/125/150%)

**A4-Canvas** (`.canvas-a4`, 210mm × min-height 297mm):
- ARKADIUM-Branding Header
- Content aus `CANVAS_CONTENT[key]` gerendert (Phase 1: 5 Seed-Templates live, Rest placeholder)
- Platzhalter `{{entity.feld}}` highlighted mit `<span class="ph">` (Gold-Background)
- Page-Break-Divider (`.page-break`) für Multi-Page (Executive Report)
- Live-Zoom via `transform:scale()`

### 8.4 Platzhalter-Resolution

Im Mockup: statische Demo-Werte (Tobias Furrer, Bauherr Muster AG).
Im Produktiv-System: Backend löst `{{mandat.honorar_pauschale}}` gegen `fact_mandate.honorar_pauschale` auf.

Platzhalter-Schema siehe §14 `dim_document_templates.placeholders_jsonb`.

---

## 9. STEP 4 — PREVIEW

Read-only A4-Canvas (Clone von Step 3 Canvas ohne Toolbar).
- Klick auf "← Zurück zu Ausfüllen" → Step 3
- Klick auf "↓ Als PDF herunterladen" → Direct-PDF-Export (Phase 2)
- Klick auf "Weiter zu Ablage →" → Step 5

---

## 10. STEP 5 — ABLAGE + DELIVERY

### 10.1 Layout

```
┌──────────────────────────────────────────┐
│ ABLAGE-ZIEL                               │
│ Entity:        Mandat · CFO-Suche         │
│ Dokument-Label: [Mandat-Offerte]          │
│ Ablage-Ordner:  Account/Mandat/           │
│ Retention:      10 Jahre (Vertrag)        │
├──────────────────────────────────────────┤
│ DELIVERY                                  │
│ ○ Nur speichern                          │
│ ● Speichern + Email versenden            │
│   Empfänger: [Hans Müller · CEO ▾]      │
│   Betreff:   [Mandats-Offerte · ...]    │
│   Template:  [Offerten-Anschreiben ▾]   │
│ ○ Speichern + Download                   │
├──────────────────────────────────────────┤
│ HISTORY-EVENTS                  [Vorschau│
│ werden automatisch am Entity    anzeigen]│
│ geloggt.                                  │
├──────────────────────────────────────────┤
│ [← Zurück]          [✓ Generieren & Send]│
└──────────────────────────────────────────┘
```

### 10.2 Ablage-Ziel

Auto-populiert aus `TPL_META[currentTemplate]`:
- Entity aus `currentEntity`
- Label aus `TPL_META.label`
- Folder aus `TPL_META.folder`
- Retention aus `TPL_META.retention`

### 10.3 Delivery-Optionen (3)

| Option | Aktion Post-Generate |
|--------|---------------------|
| `save_only` | `INSERT fact_documents` nur |
| `save_and_email` | Insert + Email-Versand via Outlook/Google-Integration |
| `save_and_download` | Insert + Browser-Download-Signed-URL |

**Email-Panel** (conditional bei `save_and_email`):
- Empfänger-Dropdown aus Entity-Kontext (Account-Kontakte)
- Betreff-Input (vor-befüllt)
- Email-Template-Dropdown aus `dim_email_templates` (gefiltert auf passende Template-Category)

### 10.4 History-Event-Preview-Drawer

Button "Vorschau anzeigen" öffnet `#history-preview` Drawer (540px) mit:
- Event-Type + Beschreibung
- Empfänger + Betreff (bei Email)
- Ablage-Ordner + Retention
- Versionierung-Info

### 10.5 Generate-Button

`fireGenerate()`:
1. Generiert Doc-ID (`DOC-YYYY-NNNN`)
2. Zeigt Success-Drawer `#gen-success` (540px, Gold-Akzent)
3. Doc-Details: ID · Template · Entity · Ordner · Timestamp · Akteur
4. Email-Sektion conditional
5. 4 Nachfolge-Aktionen (Zum Entity · Weiteres Doc · PDF Download · Email-Kopie)
6. History-Event-Preview-Block

---

## 11. KEYBOARD-HINTS-BAR

**Global:** `←`/`→` Step · `Ctrl+S` Speichern · `Ctrl+Enter` Generieren · `Esc` Drawer-Close · `⌘K` Suche

**Step 1 Template:** `/` Search-Focus
**Step 3 Editor:** Ctrl+B/I/U · Ctrl+Z/Y · Ctrl+Scroll Zoom

---

## 12. RESPONSIVE

**Desktop (≥ 1280px):** Volle Darstellung mit Sidebar 280px + Editor-Sidebar 260px.
**Tablet (768–1279px):** Sidebar collapsible, Editor 1-Col (Sektionen über Canvas).
**Mobile (< 768px):** Phase 2. Step-Indicator wird Dropdown.

---

## 13. BERECHTIGUNGEN (RBAC)

| Aktion | AM | CM | Backoffice | Admin |
|--------|----|----|-----------|-------|
| Templates lesen (Step 1) | ✅ | ✅ | ✅ | ✅ |
| Mandat-Offerten/Rechnungen generieren | ✅ | ⚠ (Read) | ✅ | ✅ |
| Kandidat-Dokumente (ARK CV/Abstract/Exposé) | ⚠ | ✅ | ❌ | ✅ |
| Assessment-Offerten/Rechnungen | ✅ | ⚠ | ✅ | ✅ |
| Executive Report | ⚠ | ✅ | ❌ | ✅ |
| Reportings (AM/CM/Monats) | ✅ | ✅ (eigene) | ❌ | ✅ |
| Factsheet Personalgewinnung | ✅ | ❌ | ❌ | ✅ |
| Template-Admin-UI (Phase 2) | ❌ | ❌ | ❌ | ✅ |

---

## 14. DATENBANK-REFERENZ

### 14.1 Neue Stammdaten-Tabelle `dim_document_templates`

```sql
dim_document_templates (
  id uuid PK,
  tenant_id FK,
  template_key text UNIQUE,                -- 'mandat_offerte_target', 'ark_cv', ...
  display_name text NOT NULL,
  category text CHECK IN (
    'mandat_offerte','mandat_rechnung','best_effort',
    'assessment','rueckerstattung','kandidat','reporting'
  ),
  target_entity_types text[],              -- ['mandate'] oder ['candidate','mandate']
  multi_entity boolean DEFAULT false,       -- true bei Expose (Multi-Kind)
  bulk_capable boolean DEFAULT false,       -- true bei Rechnungs/Mahnungs-Templates
  required_params text[],                   -- z.B. ['sprache']
  placeholders_jsonb jsonb,                 -- {"mandat.honorar_pauschale":"CHF","account.name":"text",...}
  editor_schema_jsonb jsonb,                -- Sektionen-Definition (siehe §14.2)
  pdf_engine text CHECK IN ('weasyprint','chromium','docx2pdf') DEFAULT 'weasyprint',
  default_language text DEFAULT 'de',
  source_docx_storage_path text,            -- Referenz auf Original-DOCX in Blob
  source_docx_version int DEFAULT 1,
  is_system_template boolean DEFAULT true,  -- Non-editable von non-Admin
  is_active boolean DEFAULT true,
  sort_order int,
  created_at, updated_at
)
```

**Seed-Daten Phase 1:** 38 Templates gemäss `ARK_DOK_GENERATOR_MOCKUP_PLAN.md` §1. Template `mandat_offerte_time` mit `is_active=false` (noch nicht ausgerollt).

### 14.2 `editor_schema_jsonb` Struktur

```jsonc
{
  "sections": [
    { "key": "briefkopf", "label": "Briefkopf", "default_on": true, "source": "auto" },
    { "key": "anrede", "label": "Anrede", "default_on": true, "source": "auto" },
    { "key": "leistungsumfang", "label": "Leistungsumfang", "default_on": true, "source": "auto" },
    { "key": "honorar_tabelle", "label": "Honorar-Tabelle", "default_on": true, "source": "entity" },
    { "key": "garantiefrist", "label": "Garantiefrist", "default_on": true, "source": "auto" },
    { "key": "zusatz_paragraph", "label": "Zusatz-Paragraph", "default_on": false, "source": "manuell" },
    { "key": "schlussgruss", "label": "Schlussgrüße", "default_on": true, "source": "auto" }
  ]
}
```

### 14.3 Erweiterung `fact_documents`

```sql
fact_documents (bestehend, siehe DATABASE_SCHEMA v1.3 §14)
  + generated_from_template_id uuid FK NULL → dim_document_templates(id)
  + generated_by_doc_gen boolean DEFAULT false
  + params_jsonb jsonb                      -- {"sprache":"de","empfaenger_anrede":"Herr"}
  + entity_refs_jsonb jsonb                 -- [{"type":"mandate","id":"uuid"},{"type":"candidate","id":"uuid"}]
  + delivery_mode text CHECK IN ('save_only','save_and_email','save_and_download') NULL
  + email_recipient_contact_id uuid FK NULL
```

### 14.4 Erweiterung `document_label` Enum

Neue Labels (nebst bestehenden):
- `'Mandat-Offerte'` (Alias zu `'Mandatsofferte unterschrieben'`)
- `'Mandat-Rechnung'`
- `'Best-Effort-Rechnung'`
- `'Assessment-Offerte'`
- `'Assessment-Rechnung'`
- `'Executive-Report'` (NEU)
- `'Mahnung'`
- `'Referenzauskunft'`
- `'Referral'`
- `'Interviewguide'`
- `'Reporting'`
- `'Factsheet'`

---

## 15. OFFENE SPEC-PUNKTE

| # | Punkt | Priorität |
|---|-------|-----------|
| 1 | `ARK_DOK_GENERATOR_INTERACTIONS_v0_1.md` (direkt folgend) | P0 |
| 2 | Backend-Endpoints-Spec in `ARK_BACKEND_ARCHITECTURE v2_6` | P0 |
| 3 | `dim_document_templates` Seed-Migration + 38 Template-Einträge | P0 |
| 4 | WYSIWYG-Editor-Library-Wahl (TinyMCE / ProseMirror / Quill) | P1 (React-Port) |
| 5 | DOCX-Template-Parser (Placeholder-Extraktion aus `.docx`) | P1 |
| 6 | PDF-Render-Engine (WeasyPrint vs Chromium Headless) | P1 |
| 7 | Template-Admin-UI (CRUD `dim_document_templates`) | Phase 2 |
| 8 | EN-Sprach-Support via LLM-Übersetzung | Phase 2 |
| 9 | Template-Version-Management (Semver + Rollback) | Phase 2 |

---

## 16. RELATED SPECS / WIKI

- `ARK_DOK_GENERATOR_INTERACTIONS_v0_1.md` (Begleitdokument)
- `ARK_DOK_GENERATOR_MOCKUP_PLAN.md` + `ARK_DOK_GENERATOR_MOCKUP_IMPL_v1.md`
- `ARK_ACCOUNT_DETAILMASKE_SCHEMA_v0_3.md` + `INTERACTIONS_v0_3.md` (Mandat-Offerten-Gen Deep-Link aus Account)
- `ARK_MANDAT_DETAILMASKE_SCHEMA_v0_2.md` + `INTERACTIONS_v0_3.md` (Mandat-Report-Gen Deep-Link)
- `ARK_ASSESSMENT_DETAILMASKE_SCHEMA_v0_3.md` + `INTERACTIONS_v0_3.md` (Assessment-Offerte-Gen Deep-Link)
- `ARK_KANDIDATENMASKE_SCHEMA_v1_3.md` Tab 9 (wird migriert, Redirect-Banner im Mockup)
- `ARK_DATABASE_SCHEMA_v1_3.md` §14 (`fact_documents` + Erweiterungen)
- `ARK_STAMMDATEN_EXPORT_v1_3.md` (neue Sektion `dim_document_templates` ausstehend)
- `ARK_BACKEND_ARCHITECTURE_v2_5.md` (neue Endpoints ausstehend → v2.6)
- `ARK_FRONTEND_FREEZE_v1_10.md` (neue Detailmaske `/operations/dok-generator` ausstehend → v1.11)
