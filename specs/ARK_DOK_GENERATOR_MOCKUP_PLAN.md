# ARK CRM — Globaler Dok-Generator Mockup Plan

**Stand:** 2026-04-17
**Status:** Review ausstehend (User)
**Location:** `/operations/dok-generator` (Sidebar-Bereich Operations, Sibling zu Billing-Inbox, Scraper-Queue, Reminders-Inbox)
**Quell-Specs:** Noch zu erstellen (v0.1 nach Mockup-Freigabe)
**Design-Pattern-Source:** `mockups/candidates.html` Tab 9 (Dok-Generator für Kandidat-Dossiers) — wird **generalisiert**, Original-Tab bleibt vorerst bestehen bis Migration abgeschlossen
**Template-Source:** `raw/General/` + `raw/Assessments/` (echte DOCX-Vorlagen)

---

## 0. Ziel

**Ein zentrales Tool** zur Generierung aller Dokumente, die Arkadium im Kundenkontakt erzeugt — statt heute verstreute CTAs in Entity-Detailmasken.

**Prinzipien (User-Vorgaben):**
- **1 Template pro Dokument-Variante** (kein dupliziertes Template für gleichen Inhalt; aber **Du/Sie als separate Templates** — User-Korrektur 2026-04-17: ganzer Text unterscheidet sich, nicht nur Anrede)
- **Auto-Pull aus Entity-Vollansicht** — Dokumente ziehen Felder automatisch aus der jeweiligen Detailmaske (Kandidat für ARK CV/Exposé/Abstract, Mandat für Offerten/Rechnungen, Assessment für Reports). Kein manuelles Abtippen.
- **Deep-Link-fähig** von Entity-CTAs (z.B. Mandat „📄 Offerte generieren" → öffnet Dok-Generator mit Template + Entity pre-selected)
- **Zentrales Template-Katalog** (`dim_document_templates`), nicht pro Entity-Modul
- **Kein Admin-UI im Mockup** — Templates via Seed-Migration, Edit via DB-Script (Phase 1)
- **WYSIWYG-Editor** übernommen aus bestehendem Kandidat-Tab-9 (Sidebar 280px + Main-Canvas mit A4-Pages, ARKADIUM-Branding navy/gold)

---

## 1. Template-Katalog (final, ~40 Templates)

**Hinweis:** Du-/Sie-Varianten sind **separate Templates** (User-Korrektur 2026-04-17: ganzer Text unterscheidet sich, nicht nur Anrede).
RPO-Offerte ist **nicht** Teil des Dok-Generators (separate Dienstleistung, eigener Prozess).

### 1.1 Mandat-Offerten (Offerte = Vertrag, gleiches Dokument laut User)

| # | Template-Key | Display-Name | Target-Entity | Source-Datei |
|---|--------------|--------------|---------------|--------------|
| 1 | `mandat_offerte_target` | Mandat-Offerte Target | Mandat (type=target) | `General/4_Account Management/Mandatsofferte/Vorlage_Mandatsofferte.docx` |
| 2 | `mandat_offerte_taskforce` | Mandat-Offerte Taskforce | Mandat (type=taskforce) | (abgeleitet aus Target-Template, eigene Klauseln) |
| 3 | `mandat_offerte_time` | Mandat-Offerte Time | Mandat (type=time) | **🟡 Template fehlt** (neue Dienstleistung, noch nicht ausgerollt) |
| 4 | `auftragserteilung_optionale_stage` | Auftragserteilung Optionale Stage | Mandat + Option (VIII/IX/X) | `Vorlage_Auftragserteilung Optionale Stage_VIII_Marketing…docx` |

### 1.2 Mandat-Rechnungen (Sie + Du-Varianten separat)

| # | Template-Key | Display-Name | Target-Entity | Source |
|---|--------------|--------------|---------------|--------|
| 5 | `rechnung_mandat_teilzahlung_1_sie` | Rechnung Mandat · 1. Teilzahlung · Sie | Mandat (Stage I) | `Vorlage_Rechnung Mandat 1. Teilzahlung.docx` |
| 6 | `rechnung_mandat_teilzahlung_1_du` | Rechnung Mandat · 1. Teilzahlung · Du | Mandat (Stage I) | `Du Vorlage_Rechnung Mandat 1. Teilzahlung.docx` |
| 7 | `rechnung_mandat_teilzahlung_2_sie` | Rechnung Mandat · 2. Teilzahlung · Sie | Mandat (Stage II) | `Vorlage_Rechnung Mandat 2. Teilzahlung.docx` |
| 8 | `rechnung_mandat_teilzahlung_2_du` | Rechnung Mandat · 2. Teilzahlung · Du | Mandat (Stage II) | `Du Vorlage_Rechnung Mandat 2. Teilzahlung.docx` |
| 9 | `rechnung_mandat_teilzahlung_3_sie` | Rechnung Mandat · 3. Teilzahlung · Sie | Mandat (Stage III) | `Vorlage_Rechnung Mandat 3. Teilzahlung.docx` |
| 10 | `rechnung_mandat_teilzahlung_3_du` | Rechnung Mandat · 3. Teilzahlung · Du | Mandat (Stage III) | `Du Vorlage_Rechnung Mandat 3. Teilzahlung.docx` |
| 11 | `rechnung_mandat_optionale_stage` | Rechnung Optionale Stage | Mandat + Option | `Vorlage_Rechnung_Mandat_Optionale Stage.docx` |
| 12 | `rechnung_mandat_kuendigung` | Rechnung Kündigung Mandat | Mandat (bei cancellation) | `Vorlage_Rechnung_Kündigung Mandat.docx` |
| 13 | `mahnung_mandat_sie` | Mahnung Mandat · Sie | Rechnung (mandat) | `Vorlage_Mahnung Mandat 1. Teilzahlung.docx` |
| 14 | `mahnung_mandat_du` | Mahnung Mandat · Du | Rechnung (mandat) | `DU-Mahnungen/…` |

### 1.3 Best-Effort-Rechnungen (Erfolgsbasis) · mit/ohne Rabatt + Du/Sie separat

| # | Template-Key | Display-Name | Target-Entity | Source |
|---|--------------|--------------|---------------|--------|
| 15 | `rechnung_best_effort_sie` | Rechnung Erfolgsbasis · Sie | Prozess (Placement) | `Vorlage_Rechnung Best Effort.docx` |
| 16 | `rechnung_best_effort_du` | Rechnung Erfolgsbasis · Du | Prozess (Placement) | `Du-Vorlage_Rechnung Best Effort.docx` |
| 17 | `rechnung_best_effort_mit_rabatt_sie` | Rechnung Erfolgsbasis mit Rabatt · Sie | Prozess | `Vorlage_Rechnung Best Effort mit Rabatt.docx` |
| 18 | `rechnung_best_effort_mit_rabatt_du` | Rechnung Erfolgsbasis mit Rabatt · Du | Prozess | `Du-Vorlage_Rechnung Best Effort mit Rabatt.docx` |
| 19 | `mahnung_best_effort_sie` | Mahnung Erfolgsbasis · Sie | Rechnung (best_effort) | `Vorlage_Mahnung Best Effort.docx` |
| 20 | `mahnung_best_effort_du` | Mahnung Erfolgsbasis · Du | Rechnung (best_effort) | `Du Vorlage_Mahnung Best Effort.docx` |
| 21 | `mahnung_best_effort_mit_rabatt_sie` | Mahnung Erfolgsbasis mit Rabatt · Sie | Rechnung (best_effort) | `Vorlage_Mahnung Best Effort mit Rabatt.docx` |
| 22 | `mahnung_best_effort_mit_rabatt_du` | Mahnung Erfolgsbasis mit Rabatt · Du | Rechnung (best_effort) | `Du Vorlage_Mahnung Best Effort mit Rabatt.docx` |

### 1.4 Diagnostik / Assessment

| # | Template-Key | Display-Name | Target-Entity | Source |
|---|--------------|--------------|---------------|--------|
| 23 | `assessment_offerte` | Offerte Diagnostik & Assessment | Assessment-Order | `Vorlage_Offerte Diagnostik & Assessment.docx` |
| 24 | `assessment_rechnung` | Rechnung Diagnostik & Assessment | Assessment-Order | `Vorlage_Rechnung_Diagnostics & Assessment.docx` |
| 25 | `executive_report` | **Executive Report** (NEU) | Assessment-Run + Kandidat | `raw/Assessments/Reporting_Curdin Cathomen.pdf` + `Reporting_Michael Vidal.pdf` + `Selektionsbericht_…pdf` als Referenz |

**Executive Report** = Arkadium-Zusammenfassung der Assessment-Ergebnisse (MDI/Relief/EQ/ASSESS) mit eigenen Inputs, Empfehlung, Red Flags. Kommt ZUSÄTZLICH zu den SCHEELEN-Detail-Reports (pro Run).

### 1.5 Rückerstattung

| # | Template-Key | Display-Name | Target-Entity | Source |
|---|--------------|--------------|---------------|--------|
| 26 | `rechnung_rueckerstattung` | Rechnung Rückerstattung | Prozess (Early-Exit) | `Vorlage_Rechnung Rückerstattung.docx` |

### 1.6 Kandidat-Dokumente (migriert/generalisiert aus Kandidat-Tab-9)

| # | Template-Key | Display-Name | Target-Entity | Source |
|---|--------------|--------------|---------------|--------|
| 27 | `ark_cv` | ARK CV | Kandidat | `raw/Ark Dokumente/` Layout |
| 28 | `abstract` | Abstract (Kurzzusammenfassung) | Kandidat | ARK Dokumente Layout |
| 29 | `expose` | Exposé (anonymisiert) | **nur Kandidat** (User: nicht Mandat) | ARK Dokumente Layout |
| 30 | `referenzauskunft` | Referenzauskunft | Kandidat + Referenzperson | `Vorlage_Referenzauskunft.docx` |
| 31 | `referral_schreiben` | Referral-Schreiben | Kandidat | `Vorlage_Refferal.docx` |

### 1.7 Interviewguide / Briefe

| # | Template-Key | Display-Name | Target-Entity | Source |
|---|--------------|--------------|---------------|--------|
| 32 | `interviewguide` | ARK Interviewguide | Kandidat (Coaching-Prep) | `Ark_Interviewguide.docx` |
| 33 | `gespraechsleitfaden_referenz` | Gesprächsleitfaden Referenz | Kandidat + Referenzperson | `Gesprächsleitfaden_Referenzinterview.pdf` |
| 34 | `brief_betreff` | Postaler Brief mit Betreff | Kontakt/Kandidat | `Vorlage_postaler Brief mit Betreff.docx` |
| 35 | `brief_titel` | Postaler Brief mit Titel | Kontakt/Kandidat | `Vorlage_postaler Brief mit Titel.docx` |

### 1.8 Reportings

| # | Template-Key | Display-Name | Target-Entity | Source |
|---|--------------|--------------|---------------|--------|
| 36 | `am_reporting` | AM Reporting Fokus | Tenant / Zeitraum | `AM Reporting Fokus.pdf` |
| 37 | `cm_reporting` | CM Reporting Fokus | Mitarbeiter (CM) + Zeitraum | `CM Reporting Fokus.pdf` |
| 38 | `monatsreporting_cm` | Monatsreporting CM | Mitarbeiter (CM) + Monat | `Monatsreporting CMs/` |
| 39 | `reporting_hunt` | Reporting Hunt | Mandat + Zeitraum | `Reporting Hunt.docx` |
| 40 | `reporting_team_leader` | Reporting Team Leader | Tenant / Zeitraum | `Reporting_Team Leader.pdf` |
| 41 | `mandat_report` | Mandat-Status-Report an Kunde | Mandat | (neu, abgeleitet aus Vorlagen) |
| 42 | `factsheet_personalgewinnung` | Factsheet Personalgewinnung | Account | `Factsheets/Personalgewinnung/` |

**Total: 42 Templates** (Du-Varianten als separate Templates, RPO-Offerte nicht enthalten).

### Parameter (Auswahl, nicht ersetzt durch separate Templates)

| Parameter | Wirkung | Betroffene Templates |
|-----------|---------|---------------------|
| `sprache` (de/en) | LLM-Übersetzung (Phase 2) oder Template-EN | alle |
| `empfaenger_anrede` (Herr/Frau/Team/Gleichgestellt) | Briefanrede im Anschreiben | alle mit Briefstruktur |
| `rechnung_zahlungsfrist_tage` | 14/30 Tage | Rechnungs-Templates |

**Entschieden gegen Parameter (stattdessen eigene Templates):**
- Du/Sie — ganzer Text unterscheidet sich (nicht nur Anrede)
- Mit/ohne Rabatt (Best-Effort) — separate Template-Variante
- Mandat-Typ Target/Taskforce/Time — Mandat-Offerte je eigener Template

---

## 1b. Auto-Pull aus Entity-Vollansichten

**Prinzip:** Beim Generieren eines Dokuments werden alle relevanten Felder automatisch aus der Quell-Entity gezogen — **kein manuelles Abtippen**.

**Auto-Pull-Tabellen pro Template-Kategorie:**

### Kandidat-Dokumente (ARK CV, Exposé, Abstract, Referenzauskunft, Referral, Interviewguide)

**Source-Entity: Kandidaten-Vollansicht** (`/candidates/[id]`)

Gezogene Felder:
- **Stammdaten** (Tab Übersicht): Vorname, Nachname, Foto, Alter, Wohnort, Kontakt
- **Personalien:** Anrede, Titel, Nationalität, Muttersprache, weitere Sprachen
- **Briefing-Eckdaten** (Tab Briefing): aktuelle Funktion, Arbeitgeber, Gehalt (nur ARK CV), Kompetenzen, Bewertung, Functions, Focus
- **Werdegang** (Tab Werdegang): Arbeitsstationen (Positionen/Dauer), Ausbildungen, Projekte, Zertifikate
- **Assessment** (Tab Assessment): Zusammenfassung aktive Analysen (MDI-Version, EQ-Profil), Scheelen-Kategorisierung
- **Dokumente** (Tab Dokumente): Diplome, Arbeitszeugnisse (für ARK CV Anhang)
- **Bewertungen:** Grade (A/B/C), Hot-Flag, Status

**Anonymisierung (nur Exposé):**
- Name/Vorname → "Kandidat m/w"
- Foto → entfernt
- Firmennamen → optional anonymisiert („Großunternehmen Bauwirtschaft")
- Wohnort → Kanton only
- Toggle-Panel in Editor-Sidebar

### Mandat-Dokumente (Offerte, Teilzahlung-Rechnungen, Mahnung, Kündigung, Mandat-Report)

**Source-Entity: Mandat-Vollansicht** (`/mandates/[id]`)

Gezogene Felder:
- **Grunddaten** (Tab Übersicht): Mandat-Name, Typ (Target/Taskforce/Time), Status, Kickoff, Zielplatzierung, Owner AM, Lead Research
- **Honorar:** Pauschale (Target/Taskforce), Monatsfee (Time), Staffel-% (Best-Effort), Garantiefrist
- **Ansprechpartner Kunde:** Hiring Manager (Anrede, Titel, E-Mail, Telefon), weitere Kontakte
- **Account:** Account-Name, Adresse (Rechnungs-Adresse), UID, Bank-Details, Sparten, Agb-Version
- **Stellenbriefing:** verlinkte Job-Positionen mit Funktion/Salary/Standort
- **Teilzahlungen:** Stage-Status (welche Rechnung dran ist), bereits bezahlte Beträge
- **Option IX/X:** wenn aktiv, Assessment-Order-Referenz

### Assessment-Dokumente (Offerte, Rechnung, Executive Report)

**Source-Entity: Assessment-Order-Vollansicht** (`/assessments/[id]`)

Gezogene Felder:
- **Auftrag:** Order-ID, Account, Mandat-Verknüpfung, Package, Partner, Ordered-Datum
- **Credits:** Credits-Tabelle (Typ × Quantity × Einzelpreis), Gesamtpreis
- **Runs:** verbundene Kandidat-Runs mit Status, Typ, Termin, Completion-Datum
- **Billing:** verbundene Rechnungen + Status

**Executive Report speziell:**
- **Source: Assessment-Run + Kandidat-Vollansicht**
- Gezogen: MDI-Version, Relief-Version, EQ-Version, ASSESS-Version vom Kandidat
- Arkadium-eigene Felder (manuell im Editor): Empfehlung, Red Flags, Pro/Contra Placement, Entwicklungsfelder
- Kandidaten-Bewertung (Grade), Prozess-Stage-Status
- Referenzberichte-Ergebnisse

### Best-Effort-Rechnungen

**Source-Entity: Prozess-Vollansicht mit Placement**

Gezogene Felder:
- **Prozess:** Kandidat-Name, Mandat/Job, Placement-Datum, TC-Gehalt
- **Honorar-Berechnung:** TC → Staffel-% → Honorar-CHF, Rabatt%, Netto
- **Garantiefrist:** Start/End-Datum (bereits aktiv)
- **Bank/Rechnungs-Daten** aus Account

### Reportings

**Source: Mitarbeiter/Tenant + Zeitraum-Aggregation**

- AM/CM-Reporting: KPIs aus Mandaten-Pipeline (Idents, Calls, Shortlist, Placements)
- Monatsreporting CM: Aktivitäten-Stats (Anrufe, Briefings, Placements)
- Hunt-Reporting: Mandate-Fortschritt gegenüber Target

### Technische Umsetzung (Mockup)

- Platzhalter im Template werden als `{{entity.feld}}` referenziert (z.B. `{{kandidat.vorname}}`, `{{mandat.honorar_pauschale}}`)
- `placeholders_jsonb` in `dim_document_templates` definiert welche Felder erwartet werden
- Backend `POST /api/v1/documents/generate` löst Platzhalter live auf (JOIN über Entity-Tabellen)
- Editor zeigt gelöste Werte — editierbar (Override möglich für Einzelfall-Anpassung)
- Nicht-gefüllte Pflichtfelder → Warn-Indicator im Editor (rote Markierung an Platzhalter)

---

## 2. Datenmodell (neu)

### 2.1 `dim_document_templates` (Stammdaten, neu)

```sql
id                       uuid PK
tenant_id                uuid FK
template_key             text UNIQUE   -- 'mandat_offerte_target', ...
display_name             text
category                 text  CHECK IN (
                           'mandat_offerte','mandat_rechnung','best_effort',
                           'assessment','kandidat','brief','reporting','factsheet','rueckerstattung')
target_entity_types      text[]        -- z.B. ['mandate'] oder ['candidate','mandate']
required_params          text[]        -- z.B. ['anrede','sprache']
placeholders_jsonb       jsonb         -- {"mandat.honorar":"CHF-Betrag","account.name":"Firma",...}
editor_schema_jsonb      jsonb         -- Sektionen-Definition für WYSIWYG (Reihenfolge, toggle-on/off)
pdf_engine               text  CHECK IN ('weasyprint','chromium','docx2pdf')
default_language         text  DEFAULT 'de'
source_docx_storage_path text          -- Referenz zum Ursprungs-DOCX (für Regen bei Template-Update)
is_system_template       boolean DEFAULT true
is_active                boolean DEFAULT true
sort_order               int
```

### 2.2 Erweiterung `fact_documents`

```sql
-- Neue Felder
generated_from_template_id  uuid REFERENCES dim_document_templates(id)
generated_by_doc_gen        boolean DEFAULT false
params_jsonb                jsonb   -- verwendete Params für Reproduzierbarkeit
entity_refs_jsonb           jsonb   -- bei Multi-Entity-Docs (z.B. Exposé: {candidate_id, mandate_id})
```

### 2.3 Erweiterung `document_label` Enum

Neue Labels (nebst bestehenden):
- `'Mandat-Offerte'`, `'Mandat-Vertrag'` (→ als Alias auf gleichem Template)
- `'Mandat-Rechnung'`, `'Assessment-Rechnung'`, `'Best-Effort-Rechnung'`
- `'Executive-Report'` (neu)
- `'Mahnung'`
- `'Referenzauskunft'`, `'Interviewguide'`, `'Referral'`
- `'Reporting'`, `'Factsheet'`

---

## 3. Page-Layout

```
┌──────────────────────────────────────────────────────────────────┐
│ Operations / Dok-Generator                           [⌘K] [Avatar]│
├──────────────────────────────────────────────────────────────────┤
│ 📝 Dok-Generator                        [Neues Dokument] ▾        │
│ 33 Templates · 23 heute generiert · 312 YTD · 14 Entwürfe offen   │
├──────────────────────────────────────────────────────────────────┤
│ STEP-INDICATOR (horizontal)                                        │
│ ● 1 Template → ● 2 Entity → ○ 3 Ausfüllen → ○ 4 Preview → ○ 5 Ablage │
├────────────────┬─────────────────────────────────────────────────┤
│ SIDEBAR (280px)│  MAIN                                             │
│                │                                                   │
│ KATEGORIEN     │  [wechselt je nach Step:                          │
│ ▸ Mandat (5)   │   Step 1: Template-Grid                           │
│ ▸ Rechnung (7) │   Step 2: Entity-Picker                           │
│ ▸ Assessment(3)│   Step 3: WYSIWYG-Editor + Sidebar-Sektionen      │
│ ▸ Kandidat (5) │   Step 4: PDF-Preview (A4 Canvas)                 │
│ ▸ Reporting(7) │   Step 5: Ablage-Optionen + Email-Senden]         │
│ ▸ Brief (2)    │                                                   │
│ ▸ …            │                                                   │
│                │                                                   │
│ QUICK-FILTER   │                                                   │
│ · Zuletzt      │                                                   │
│   genutzt (8)  │                                                   │
│ · Entwürfe(14) │                                                   │
│ · Kunde-facing │                                                   │
│ · Intern       │                                                   │
│                │                                                   │
│ SUCHE          │                                                   │
│ 🔍 Template…   │                                                   │
├────────────────┴─────────────────────────────────────────────────┤
│ KB-HINTS: ←→ Step wechseln · Ctrl+S Save · Ctrl+Enter Generate    │
└──────────────────────────────────────────────────────────────────┘
```

**Kein Tab-System** — 5 Workflow-Steps werden im Main-Bereich sequenziell dargestellt. Step-Indicator oben zeigt Fortschritt.

---

## 4. Workflow (5 Steps)

### Step 1: Template wählen

**Main-Bereich:** Grid mit Template-Cards (3–4 Spalten).

```
┌────────────────┐ ┌────────────────┐ ┌────────────────┐
│ 📄 Mandat      │ │ 💰 Rechnung    │ │ 📊 Assessment  │
│    Offerte     │ │    Mandat T1   │ │    Offerte     │
│    Target      │ │                │ │                │
│ ──             │ │ ──             │ │ ──             │
│ Mandat         │ │ Mandat, Rgs.   │ │ Assessment-Ord.│
│ Zuletzt: —     │ │ Zuletzt: 12.04.│ │ Zuletzt: 01.03.│
└────────────────┘ └────────────────┘ └────────────────┘
```

Card-Klick → Step 2 mit pre-selected Template.

**Deep-Link:** `?template=mandat_offerte_target` überspringt Step 1.

### Step 2: Target-Entity wählen

**Main-Bereich:** Entity-Picker gemäss `target_entity_types`.

Beispiele:
- Template `mandat_offerte_target` → Picker: Mandat (Autocomplete aus `fact_mandates`)
- Template `ark_cv` → Picker: Kandidat
- Template `expose` → Picker: Kandidat + **optional** Mandat (für Mandat-Kontext in Anschreiben)
- Template `rechnung_best_effort` → Picker: Prozess (mit Placement)
- Template `am_reporting` → Picker: Zeitraum (von-bis)

**Deep-Link:** `?template=…&entity=mandate:uuid` überspringt auch Step 2.

### Step 3: Ausfüllen (WYSIWYG-Editor)

**Main-Bereich:** 2-Spalten-Layout aus Kandidat-Tab-9:
- **Sidebar 280px:** Sektionen-Liste mit Checkbox + Drag-Handle (Sektionen an-/abschaltbar, umsortierbar). Anonymisierungs-Panel (nur bei `expose`). Parameter-Panel (Anrede Du/Sie, Sprache, Rabatt%).
- **Main Canvas:** A4-Seite (210mm) mit ARKADIUM-Branding (navy #1a2540, gold #b99a5a). Editor-Toolbar oben (Bold/Italic, Heading, List, Zoom). Platzhalter werden aus DB aufgelöst live.

Pro-Template-Sektionen sind in `editor_schema_jsonb` definiert (Reihenfolge, default on/off, Source-Entity-Felder).

### Step 4: Preview

**Main-Bereich:** Read-only A4-Preview (gerendertes PDF).
- Download → PDF
- Zurück zu Edit → Step 3

### Step 5: Ablage + Delivery

**Main-Bereich:** Options-Panel.

```
┌──────────────────────────────────────────────────────┐
│ ✅ DOKUMENT FERTIG                                    │
│                                                       │
│ ABLAGE                                                │
│ ○ Speichern in fact_documents                         │
│   ○ Entity: [Mandat: CFO-Suche ▾] (aus Step 2)       │
│   ○ Label: [Mandat-Offerte ▾] (auto aus Template)    │
│                                                       │
│ DELIVERY                                              │
│ ○ Nur speichern                                       │
│ ● Speichern + Email senden                            │
│   Empfänger: [Hans Müller ▾] · CEO Bauherr Muster AG │
│   Betreff: [Mandats-Offerte · CFO-Suche — Vorschlag] │
│   Template: [Offerte-Anschreiben ▾]                   │
│ ○ Speichern + Download                                │
│                                                       │
│ HISTORY-EVENT                                         │
│ ✓ Wird als „Offerte erstellt + versendet" geloggt    │
│                                                       │
│ [← Zurück zu Preview]    [✓ Generieren & Versenden]  │
└──────────────────────────────────────────────────────┘
```

**Auto-Aktionen nach Klick „Generieren":**
- `INSERT fact_documents` mit `generated_by_doc_gen=true`, `generated_from_template_id`, `params_jsonb`, `entity_refs_jsonb`
- History-Event am Entity (z.B. Mandat „📄 Mandats-Offerte generiert + versendet")
- Wenn Email: `dim_email_templates` Lookup + Versand via Outlook-/Google-Integration (Unified Communication Memory)
- Signed URL zurück für Download

---

## 5. Backend-Endpoints (neu)

```
GET    /api/v1/document-templates                    → Liste aller Templates (filter ?category, ?target_entity_type)
GET    /api/v1/document-templates/:key               → Template-Details + Placeholders + editor_schema
POST   /api/v1/documents/generate                    → Master-Endpoint
  body:
    template_key: 'mandat_offerte_target'
    entity_refs: [{ type: 'mandate', id: 'uuid' }]
    params: { anrede: 'Sie', sprache: 'de', rabatt_pct: 0 }
    overrides: { 'section.custom_paragraph': 'freier Text …' }
    action: 'preview' | 'save' | 'save_and_email' | 'save_and_download'
    email_options: { recipient_contact_id, subject, email_template_key }
  response:
    { document_id, pdf_signed_url, action_result: 'saved' | 'saved_and_sent' }

POST   /api/v1/documents/:id/regenerate              → Wenn Template-Version-Update
POST   /api/v1/documents/:id/email                   → Nachträglicher Versand aus Dokument

GET    /api/v1/document-generator/recent             → Zuletzt erzeugte Docs (sidebar)
GET    /api/v1/document-generator/drafts             → Unfertige Entwürfe (sidebar)
```

**Bestehende Endpoints werden Wrapper:**
- `POST /api/v1/assessments/:id/generate-quote` → intern `documents/generate` mit `template_key='assessment_offerte'`
- `POST /api/v1/ai/generate-dossier` → intern `documents/generate` mit `template_key='ark_cv'` oder `abstract` oder `expose`

---

## 6. Integration mit bestehenden Entity-CTAs

| Entity-Detailmaske | Bestehender Button | Deep-Link |
|--------------------|--------------------|-----------|
| Mandat-Detail | 📄 Mandat-Offerte generieren | `/operations/dok-generator?template=mandat_offerte_<type>&entity=mandate:uuid` |
| Mandat-Detail | 💰 Rechnung Stage N | `?template=rechnung_mandat_teilzahlung_<N>&entity=mandate:uuid` |
| Account-Detail | 📊 Factsheet Personalgewinnung | `?template=factsheet_personalgewinnung&entity=account:uuid` |
| Assessment-Detail | 📄 Offerte generieren | `?template=assessment_offerte&entity=assessment_order:uuid` |
| Assessment-Detail | 📊 Executive Report | `?template=executive_report&entity=assessment_run:uuid&candidate=uuid` |
| Prozess-Detail | 💰 Rechnung Erfolgsbasis | `?template=rechnung_best_effort&entity=process:uuid` |
| Kandidat-Detail Tab 9 | (WIRD MIGRIERT) | Redirect-Banner im Tab-9 „→ Dok-Generator" |

**Migration Kandidat-Tab-9:**
- Phase 1: Tab-9 bleibt, aber Banner oben „Dok-Generator ist jetzt global verfügbar → Wechseln"
- Phase 2: Tab-9-Layout wird zur Inline-Variante (Editor in Kandidat-Maske mit Redirect-Button)
- Phase 3 (React-Port): Tab-9 komplett entfernt, nur Deep-Link auf Global-Generator

---

## 7. Page-Pattern (Mockup-Skeleton)

**Datei:** `mockups/dok-generator.html` (neu)
**Zielumfang:** ~1'800–2'200 Zeilen
**Design-Referenz:** `candidates.html` Tab 9 Lines 3738–~4500 (Editor-Styles, Canvas, Sidebar-Sections)

**Seed-Daten Phase 1 (5 Templates live ausgearbeitet):**
1. `mandat_offerte_target` (Hauptanwendungsfall) — mit vollem Editor
2. `rechnung_mandat_teilzahlung_1` — Rechnungs-Template
3. `assessment_offerte` — Assessment-Offerte
4. `ark_cv` — Kandidaten-CV
5. `executive_report` — NEU, Beispiel-Content aus `raw/Assessments/Reporting_Curdin Cathomen.pdf`

**Restliche 28 Templates nur in Template-Library** als Cards sichtbar (Click öffnet Placeholder „Editor-Content Phase 2").

---

## 8. Mockup-Phasen

### Phase 1 — Page-Layout + Template-Library + Workflow-Steps (~1'400 Zeilen)

- Sidebar 280px mit Kategorien (mit counts), Quick-Filter, Suche
- Step-Indicator oben (5 Steps)
- Step 1 Template-Grid komplett (alle 33 Templates als Cards, Kategorie-Chips)
- Step 2 Entity-Picker (generisch, unterstützt Mandat/Account/Kandidat/Assessment/Prozess)
- Step 3 Editor-Layout (aus Kandidat-Tab-9 übernommen, Sektionen placeholderig für 5 Seed-Templates)
- Step 4 A4-Preview-Rendering (Dummy-PDF-Look)
- Step 5 Ablage/Delivery-Optionen

### Phase 2 — Full-Content für 5 Seed-Templates (~600 Zeilen)

- Real-data-seeded Beispiele pro Template
- Parameter-Panel voll (Anrede, Sprache, Rabatt)
- Anonymisierungs-Panel (für expose)
- Preview mit echtem Mock-Content

### Phase 3 — Polish + KB-Hints + Drawer (~200 Zeilen)

- KB-Bar komplett
- Keyboard-Shortcuts (Ctrl+S, Ctrl+Enter, ←→ Step-Wechsel)
- History-Event-Preview-Drawer
- Deep-Link-Handling (URL-Params auto-select)

---

## 9. Spec-Sync-Deltas

Bei Umsetzung müssen folgende Grundlagen-Dateien aktualisiert werden:

| Grundlage | Delta |
|-----------|-------|
| `ARK_STAMMDATEN_EXPORT_v1_3.md` | Neue Sektion `dim_document_templates` mit 33 Einträgen |
| `ARK_DATABASE_SCHEMA_v1_3.md` | `dim_document_templates` Schema + `fact_documents` Erweiterungen + `document_label` Enum-Extension |
| `ARK_BACKEND_ARCHITECTURE_v2_5.md` | Neue Endpoints §11 `POST /api/v1/documents/generate` etc., Wrapper-Mapping alter Endpoints |
| `ARK_FRONTEND_FREEZE_v1_10.md` | Neue Detailmaske `/operations/dok-generator`, Tab-9 Kandidat als Redirect dokumentiert |
| `ARK_GESAMTSYSTEM_UEBERSICHT_v1_3.md` | Changelog-Eintrag „Globaler Dok-Generator" |

**Spec-Doc** `ARK_DOK_GENERATOR_SCHEMA_v0_1.md` + `ARK_DOK_GENERATOR_INTERACTIONS_v0_1.md` zu erstellen **nach** Mockup-Freigabe.

---

## 10. Offene Klärungsfragen

| # | Punkt | Status |
|---|-------|--------|
| 1 | `mandat_offerte_time` — Template fehlt (User sagt „neue Dienstleistung noch nicht ausgerollt"). Im Mockup als Placeholder-Card mit Hinweis „Template ausstehend" | ✓ klar |
| 2 | Executive Report: exakte Sektionen? (Zusammenfassung MDI+Relief+EQ, Red Flags, Empfehlung pro/contra Placement, Entwicklungsfelder) — Vorschlag aus `raw/Assessments/Reporting_*.pdf` abgeleitet | offen, Phase 2 |
| 3 | ~~Du/Sie-Anrede als Parameter~~ | ✓ geklärt 2026-04-17: **separate Templates** (ganzer Text unterscheidet sich) |
| 4 | ~~`rabatt_pct` als Parameter~~ | ✓ geklärt 2026-04-17: **separate Templates** für mit/ohne Rabatt |
| 5 | Multi-Sprache: DE/EN. Via LLM-Übersetzung oder separate Templates pro Sprache? Empfehlung: **LLM-Übersetzung in Phase 2**, Phase 1 nur DE | Phase 2 |
| 6 | Template-Editor-UI (CRUD dim_document_templates) — User sagt B = nur Seed, kein Admin-UI. ✓ | ✓ klar |
| 7 | WYSIWYG-Editor-Library: TinyMCE, ProseMirror, Quill? — **Entscheidung im React-Port** (Mockup zeigt visual-only) | React-Port |

---

## 11. Akzeptanzkriterien (nach P1–P3)

- [ ] `mockups/dok-generator.html` existiert (~1'800–2'200 Zeilen)
- [ ] Alle 33 Templates als Cards im Step 1 sichtbar
- [ ] 5 Seed-Templates (Mandat-Offerte Target, Mandat-Rechnung T1, Assessment-Offerte, ARK CV, Executive Report) mit echtem Content gefüllt
- [ ] Step-Indicator mit 5 Steps visuell klar, Forward/Back möglich
- [ ] Entity-Picker unterstützt alle 5 Entity-Types (Mandat, Account, Kandidat, Assessment-Order, Prozess)
- [ ] WYSIWYG-Editor-Layout aus Kandidat-Tab-9 übernommen, Sidebar 280px + A4-Canvas
- [ ] Deep-Link-Handling (URL-Params template= + entity=) visuell demonstriert
- [ ] Ablage-Step mit Email-Option + History-Event-Preview
- [ ] Sidebar mit Kategorien-Counts, Quick-Filter „Zuletzt" / „Entwürfe", Suche
- [ ] KB-Hints-Bar komplett
- [ ] Alle Lint-Skills grün (stammdaten, umlaute, db-techdetails, drawer-default, mockup-drift)
- [ ] Drift-Scan gegen Kandidat-Tab-9 bestanden (Editor-Pattern konsistent)

---

## 12. Nach Plan-Freigabe

1. User reviewed Plan
2. Bei OK → `writing-plans` → detailliertes Implementation-Plan-Doc `ARK_DOK_GENERATOR_MOCKUP_IMPL_v1.md`
3. Phase 1–3 Implementation mit Checkpoints
4. Nach Mockup → Spec-Docs `ARK_DOK_GENERATOR_SCHEMA_v0_1.md` + `ARK_DOK_GENERATOR_INTERACTIONS_v0_1.md`
5. Danach Grundlagen-Sync (Stammdaten + Database + Backend + Frontend + Gesamtsystem)
