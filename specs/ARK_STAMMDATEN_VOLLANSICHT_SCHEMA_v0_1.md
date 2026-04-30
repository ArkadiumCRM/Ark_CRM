# ARK CRM — Stammdaten Vollansicht Schema v0.1

**Stand:** 2026-04-30
**Status:** Erstentwurf — Reverse-Engineered aus Plan v0.1 + bestehendem Mockup, Review ausstehend
**Quellen:**
- `specs/ARK_STAMMDATEN_VOLLANSICHT_PLAN_v0_1.md` (Plan v0.1, alle 11 offenen Fragen mit Vorschlag beantwortet — übernommen)
- `Grundlagen MD/ARK_STAMMDATEN_EXPORT_v1_5.md` (67+ `dim_*`-Kataloge — Source-of-Truth Inhalte)
- `Grundlagen MD/ARK_DATABASE_SCHEMA_v1_6.md` (`dim_*` Tabellen-Definitionen, `fact_audit_log`)
- `Grundlagen MD/ARK_FRONTEND_FREEZE_v1_13.md` (Routing `/stammdaten`, Sidebar „System", Design-System)
- `mockups/Vollansichten/stammdaten.html` (3955 Zeilen — implementierte Referenz)
- `specs/ARK_ADMIN_VOLLANSICHT_SCHEMA_v0_1.md` (Abgrenzung Admin vs Stammdaten)
- `specs/ARK_REMINDERS_VOLLANSICHT_SCHEMA_v0_1.md` (Pattern-Vorlage Vollansicht)
- `wiki/meta/mockup-baseline.md` (UI-Token-Baseline)
- `wiki/meta/digests/stammdaten-digest.md` (Lossless-Digest aller dim-Inhalte)
- CLAUDE.md §Stammdaten-Wording-Regel · §DB-Techdetails-im-UI-Regel

**Vorrang:** Stammdaten > dieses Schema > Frontend Freeze > Mockups
**Begleitdokument:** `ARK_STAMMDATEN_VOLLANSICHT_INTERACTIONS_v0_1.md`

---

## 0. ZIELBILD

Vollseite `/stammdaten` — **konsolidierter Browse-Hub** für alle ~67 `dim_*`-Kataloge aus `ARK_STAMMDATEN_EXPORT_v1_5.md`. Read für alle Rollen, CRUD nur für `admin` (über Edit-Modus-Toggle). Single-Truth-Pflege ohne Funktions-Duplikation mit Admin-Vollansicht.

### Abgrenzung zu bestehenden Konfigurations-Oberflächen

| Oberfläche | Scope | Zweck |
|------------|-------|-------|
| **Vollansicht `/stammdaten`** (dieses Dokument) | Alle 67 `dim_*`-Kataloge (Read · Edit-Modus für admin) | Browse + Pflege simpler Stammdaten (Labels · Sort · Aktiv) |
| Admin Tab 1 (Settings) | Feature-Flags · `dim_automation_settings` (27 Keys) | Keys pflegen (Stammdaten zeigt Read-Only-Liste mit Deep-Link) |
| Admin Tab 2 (Automation-Regeln) | `dim_automation_rules` CRUD | Regeln-Editor mit Conditions/Actions (komplex — Stammdaten zeigt nur Übersicht) |
| Admin Tab 3/4/7 (Templates) | `dim_*_templates` Editor mit Body/Variablen | Volltext-Editoren (Stammdaten zeigt Übersicht + „Verwalten in Admin"-Button) |
| Admin Tab 8 (Audit-Log) | `fact_audit_log` Reader | Mutation-History (Stammdaten verlinkt aus Detail-Drawer §6.4) |
| HR-Tool Phase 2 | `dim_mitarbeiter` voller Lifecycle | Onboarding / Vertrag / Lohn / Austritt — Stammdaten zeigt nur Read-Stub mit P2-Hinweis |

**Single-Truth-Pflege:** Kataloge mit komplexem CRUD-Editor in Admin werden in Stammdaten **nur als Übersicht** angezeigt (Card mit Count + Tag `→ Admin`). Vermeidet Doppel-UI.

### Zwei UI-Modi

| Modus | Wer | Was |
|-------|-----|-----|
| **Browse** (Default) | Alle Rollen | Suche · Filter · Read-Only-Tabellen · CSV-Export · Verwendung-Stat |
| **Edit** | nur `admin` (Toggle oben rechts, audit-pflichtig) | Inline-Edit · CRUD pro Eintrag · Batch-Import · Soft-Disable · Sort-Drag |

Browse ist Default — Edit-Modus muss explizit aktiviert werden (verhindert versehentliche Mutationen). Edit-Aktivierung emittiert `audit.config.edit_mode_enabled`-Event.

### Primäre Nutzer

| Rolle | Nutzungs-Szenario | Modus |
|-------|------------------|-------|
| **AM/CM/RA/BO** (Operations) | Lookup von Stage-Codes / Activity-Types / Sektoren / Sparten — „was bedeutet `tt_telefon_interview`?" | Browse |
| **Head of** (HoD) | Übersicht der konfigurierten Pipeline-Stages für Team-Onboarding | Browse |
| **Admin (PW)** | CRUD aller dim-Kataloge: neue Stage anlegen, Label korrigieren, Sort-Order anpassen, Soft-Disable | Edit |
| **Externals (Read-Only)** | DSG-Auditor liest `dim_pii_classification`, externer Trainer schaut `dim_education` | Browse |

### Prinzipien

- **Single-Source-of-Truth:** Kataloge mit eigenem Admin-Editor werden in Stammdaten nur referenziert (Card + Deep-Link).
- **Browse-First:** Default Read-Only — Edit-Modus muss aktiv geschaltet werden.
- **Audit-Pflicht:** Jede Mutation → `fact_audit_log` mit `action='config.<dim>.create|update|delete'`.
- **Optimistic-Update:** Inline-Edit schreibt sofort, Spinner nur bei Hard-Failure-Rollback.
- **Multi-Lang-aware:** UI zeigt aktive Sprache (DE Default), Edit zeigt alle 3 (DE/EN/FR) im Drawer-Tab.
- **Verwendung-Live:** Stat „verwendet in N Records" wird live aus `fact_*` berechnet, gecacht 5 min (`stammdaten.usage.cache_ttl=300s`).
- **Locked-Markers:** External/Locked-Kataloge zeigen Schloss-Icon, Edit-Buttons disabled.
- **Deep-Link-fähig:** Direkt-Link zu Katalog/Eintrag aus Spec/Audit-Log (siehe §10 Routing).
- **Mobile:** Browse-Mode tauglich (Tabellen scroll horizontal). Edit-Mode → Hinweis „Desktop empfohlen".

---

## 1. DESIGNSYSTEM-REFERENZ

Erbt aus `wiki/meta/mockup-baseline.md` und `Grundlagen MD/ARK_FRONTEND_FREEZE_v1_13.md`.

### Modul-spezifische Tokens

| Token | Wert (Light) | Wert (Dark) | Verwendung |
|-------|--------------|-------------|-----------|
| `--cat-card-bg` | `var(--surface)` | `var(--surface-elev)` | Catalog-Card im Card-Grid |
| `--edit-banner-bg` | `var(--amber-soft)` | `var(--amber-soft)` | Edit-Modus aktiv Banner |
| `--locked-icon` | `var(--text-light)` | `var(--text-light)` | Schloss-Icon bei Locked-Katalogen |
| `--multilang-warn` | `var(--amber)` | `var(--amber)` | „Übersetzung fehlt"-Markierung |
| `--inline-edit-active` | `var(--accent-soft)` | `var(--accent-soft)` | Aktive Edit-Cell Background |

### Tag-Chip-Vokabular (auf Catalog-Cards)

| Tag | Bedeutung | Farb-Token |
|-----|-----------|------------|
| `Lossless` | Komplett dokumentiert · sollte unverändert bleiben | `var(--green-soft)` |
| `Lossy` | Großer Katalog · Digest ist verlustbehaftet | `var(--amber-soft)` |
| `External` | Extern verwaltet (ISO 3166 / 639 / DSG) — Read-Only auch für Admin | `var(--blue-soft)` |
| `Locked` | Gesperrt by law · Vier-Augen oder gar nicht | `var(--red-soft)` |
| `Admin-Edit` | Inline-Edit nur in Stammdaten möglich | `var(--accent-soft)` |
| `Multi-Lang` | DE/EN/FR-Übersetzungen pflegbar | `var(--purple-soft)` |
| `→ Admin` | Verwaltung in Admin-Vollansicht (Click-Through) | `var(--gold-soft)` |
| `P2-Stub` | Volle Verwaltung kommt mit HR-Tool Phase 2 | `var(--text-light)` |

### Status-Indikatoren

| Status | Visual | Token |
|--------|--------|-------|
| Aktiv | Default · `active=true` | `var(--text)` |
| Inaktiv | Strike-Through · `active=false` | `text-decoration:line-through; color:var(--text-light)` |
| Verwendet | Badge mit Count | `var(--accent-soft)` Hintergrund |
| Unbenutzt | Badge "0×" | `var(--text-light)` |
| Übersetzung fehlt | ⚠ Icon | `var(--amber)` |

---

## 2. LAYOUT (Variante C · Hybrid)

Plan-§2 Variant C übernommen. Tabbar mit 8 konsolidierten Kategorien + Card-Grid pro Tab + Drill-Down zur Catalog-Tabelle.

### Gesamt-Struktur

```
┌──────────────────────────────────────────────────────────────────────┐
│ Header: Brand · Breadcrumb (Stammdaten) · Theme-Toggle · CMD-Hint    │
├──────────────────────────────────────────────────────────────────────┤
│ Page-Banner: Title „Stammdaten" · Sub „67 Kataloge · ~5 200 Einträge"│
│ + Actions: [Suche...] [Edit-Modus ▾] [CSV-Export ▾]                  │
├──────────────────────────────────────────────────────────────────────┤
│ Tabbar (sticky): 8 Kategorien · aktive Tab unterstrichen             │
├──────────────────────────────────────────────────────────────────────┤
│ Tab-Pane (per Kategorie):                                            │
│ ┌─────────────────────────────────────────────────────────────────┐ │
│ │ Stat-Strip · 4 Cards (siehe §4)                                 │ │
│ ├─────────────────────────────────────────────────────────────────┤ │
│ │ Filter-Chips · Aktiv/Inaktiv/Locked/External/⚠Übers./🆕7d/🔥Top10│ │
│ ├─────────────────────────────────────────────────────────────────┤ │
│ │ Cat-Card-Grid · 1 Card pro Katalog                              │ │
│ │ ┌──────────┐ ┌──────────┐ ┌──────────┐                          │ │
│ │ │ Stages   │ │ Status   │ │ Reasons  │ ...                       │ │
│ │ │ 19 Eint. │ │ 8 Eint.  │ │ 6 Eint.  │                          │ │
│ │ │ Tags     │ │ Tags     │ │ Tags     │                          │ │
│ │ └──────────┘ └──────────┘ └──────────┘                          │ │
│ └─────────────────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────────────────┘

Click Card → Slide-In von rechts (760px) · Drill-Down zur Catalog-Tabelle
Click Tabellen-Zeile → Detail-Drawer (760px, geshared mit Drill-Down-Layer)
```

### Komponenten-Hierarchie

| Layer | Komponente | Breite |
|-------|-----------|--------|
| L0 | Page (Tabs + Stat-Strip + Card-Grid) | 100% |
| L1 | Drill-Down · Catalog-Tabelle (Slide-In) | 760px |
| L2 | Detail-Drawer · Eintrag-Details (Slide-In über L1) | 760px |
| Modal (Ausnahme) | Hard-Delete-Confirm · Batch-Import-Preview · Konflikt-Resolution | 480px max |

Drawer-Default-Regel (CLAUDE.md): Slide-In für CRUD/Multi-Step. Modal nur für Confirms/Blocker.

---

## 3. KATEGORIE-INVENTAR (8 Konsolidierte)

Konsolidiert aus 12 logischen Gruppen des Plan-§1 auf 8 UI-Tabs:

### Tab 1 — Workflow & Prozess

| Katalog | Einträge | Tags |
|---------|----------|------|
| `dim_process_stages` | 19 (9 Pipeline + 10 Analytics) | Lossless · Admin-Edit |
| `dim_process_status` | 8 | Lossless · Admin-Edit |
| `dim_kandidat_stages` | 8 | Lossless · Admin-Edit |
| `dim_mandate_research_stages` | 13 | Lossless · Admin-Edit |
| `dim_dropped_reasons` | 6 | Lossless · Multi-Lang · Admin-Edit |
| `dim_cancellation_reasons` | 9 | Lossless · Multi-Lang · Admin-Edit |
| `dim_offer_refused_reasons` | 10 | Lossless · Multi-Lang · Admin-Edit |
| `dim_vacancy_rejection_reasons` | 8 | Lossless · Admin-Edit |
| `dim_rejection_reasons_internal` | 11 | Lossless · Admin-Edit |
| `dim_jobbasket_rejection_types` | 12 | Lossless · Admin-Edit |
| `dim_rejection_reasons_candidate` | 13 | Lossless · Multi-Lang · Admin-Edit |
| `dim_rejection_reasons_client` | 16 | Lossless · Multi-Lang · Admin-Edit |
| `dim_final_outcomes_mandate` | 8 | Lossless · Admin-Edit |

**Total Tab 1:** 13 Kataloge · ~140 Einträge

### Tab 2 — Communication (Activities + Templates)

| Katalog | Einträge | Tags |
|---------|----------|------|
| `dim_activity_types` | 69 (in 11 Kategorien) | Lossless · Multi-Lang · Admin-Edit |
| `dim_reminder_templates` | 10 | → Admin (Tab 3) |
| `dim_email_templates` | 32 | → Admin (Tab 4) |
| `dim_notification_templates` | 10 | → Admin (Tab 4) |
| `dim_prompt_templates` | 7 | → Admin (Tab 4) |
| `dim_event_types` | 60+ | Lossless · Locked (System) |
| `dim_document_templates` | 38+1 | → Admin (Tab 7) |
| `dim_dossier_preferences` | 7 | Lossless · Admin-Edit |
| `dim_presentation_types` | 3 | Lossless · Admin-Edit |

**Total Tab 2:** 9 Kataloge · ~240 Einträge

### Tab 3 — Skills & Berufe

| Katalog | Einträge | Tags |
|---------|----------|------|
| `dim_edv` | 109 (in 11 Kategorien) | Lossy · Multi-Lang · Admin-Edit |
| `dim_functions` | ~190 (in ~25 Kategorien) | Lossy · Multi-Lang · Admin-Edit |
| `dim_education` | 503 | Lossy · Admin-Edit |
| `dim_focus` | ~200 (in ~25 Kategorien) | Lossy · Multi-Lang · Admin-Edit |

**Total Tab 3:** 4 Kataloge · ~1 000 Einträge

### Tab 4 — Branchen, Sparten & Geo

| Katalog | Einträge | Tags |
|---------|----------|------|
| `dim_sparte` | 5 (ARC/GT/ING/PUR/REM) | Lossless · Locked |
| `dim_sector` | 35 (in 6 Kategorien) | Lossless · Multi-Lang · Admin-Edit |
| `dim_industry_branche` | ~30 | Lossless · Admin-Edit |
| `dim_industry_subsparte` | ~20 | Lossless · Admin-Edit |
| `dim_cluster` | ~97 (in 4 Sparten-Gruppen) | Lossless · Admin-Edit |
| `dim_geo_land` | ~250 (ISO 3166) | External (Read-Only) |
| `dim_geo_kanton` | 26 | Lossless · Admin-Edit |
| `dim_geo_plz_range` | ~3 200 | Lossy · Admin-Edit |
| `dim_languages` | 20 (ISO 639) | External (Read-Only) |

**Total Tab 4:** 9 Kataloge · ~3 700 Einträge

### Tab 5 — Mitarbeiter, Rollen & Account

| Katalog | Einträge | Tags |
|---------|----------|------|
| `dim_mitarbeiter` | 12 (10 aktiv + 2 ab 01.05.) | P2-Stub · Read |
| `dim_roles` | 8 | Lossless · Admin-Edit |
| `dim_owner_teams` | ~5 | Lossless · Admin-Edit |
| `dim_mitarbeiter_sparten_link` | ~30 | Lossless · Admin-Edit |
| `dim_account_klasse` | 4 (A/B/C/Test) | Lossless · Admin-Edit |
| `dim_account_funktion` | ~10 | Lossless · Admin-Edit |
| `dim_org_functions` | 5 (vr_board · executive · hr · einkauf · assistenz) | Lossless · Admin-Edit |

**Total Tab 5:** 7 Kataloge · ~75 Einträge

### Tab 6 — Mandat, Honorar & Assessment

| Katalog | Einträge | Tags |
|---------|----------|------|
| `dim_honorar_settings` | 4 Stufen | Lossless · Admin-Edit |
| `dim_time_packages` | 3 | Lossless · Admin-Edit |
| `dim_sia_phases` | 6+12 | Lossless · Admin-Edit |
| Mandat-Typen-Enum | 3 (Target · Taskforce · Time) | Lossless · Locked |
| `dim_assessment_types` | 11 | Lossless · Admin-Edit |
| `dim_eq_dimensions` | 5 | Lossless · Locked (Methodik) |
| `dim_motivator_dimensions` | 12 (6 Achsen × 2 Pole) | Lossless · Locked (Methodik) |
| `dim_assess_competencies` | 26 | Lossless · Admin-Edit |
| `dim_assess_standard_profiles` | 11 | Lossless · Admin-Edit |
| `dim_culture_dimensions` | 6 | Lossless · Admin-Edit |

**Total Tab 6:** 10 Kataloge · ~100 Einträge

### Tab 7 — System & Scraper

| Katalog | Einträge | Tags |
|---------|----------|------|
| `dim_scraper_types` | 7 | Lossless · Admin-Edit |
| `dim_scraper_global_settings` | 14 | Lossless · → Admin (Tab 1) |
| `dim_matching_weights` | 8 | Lossless · Admin-Edit |
| `dim_matching_weights_project` | 6 | Lossless · Admin-Edit |
| `dim_automation_settings` | 27 Keys | → Admin (Tab 1) |

**Total Tab 7:** 5 Kataloge · ~62 Einträge

### Tab 8 — Governance & Naming-Conventions

| Katalog | Einträge | Tags |
|---------|----------|------|
| `dim_pii_classification` | 21 | External (DSG-Vorgabe) |
| `dim_quality_rule_types` | 9 | Lossless · Locked |
| `dim_naming_convention` | ~10 | Locked (Vier-Augen) |
| `dim_ai_write_policies` | 8 | Locked (Audit-pflichtig) |

**Total Tab 8:** 4 Kataloge · ~48 Einträge

**Gesamtsumme:** 67 Kataloge · ~5 365 Einträge

### Sonderkategorien-Definition

- **External (Read-Only auch für Admin):** `dim_geo_land`, `dim_languages`, `dim_pii_classification` — Source-Of-Truth liegt außerhalb des CRMs (ISO/DSG-Standards).
- **Locked-by-Law:** `dim_naming_convention`, `dim_ai_write_policies`, `dim_event_types`, `dim_eq_dimensions`, `dim_motivator_dimensions`, `dim_quality_rule_types`, Mandat-Typen-Enum, `dim_sparte` — Vier-Augen erforderlich, in Edit-Modus disabled (Hinweis-Tooltip „Locked · Mutation nur via Migrations-Patch").
- **→ Admin:** Templates und komplexe Settings — Stammdaten zeigt Read-Card mit Klick-Through-Button.
- **P2-Stub:** `dim_mitarbeiter` — In Stammdaten Read mit Sparten-Link, voller Lifecycle in HR-Tool Phase 2.

---

## 4. STAT-STRIP (oben in jedem Tab-Pane)

4 Cards · klickbar → setzt Filter-Chips

| Card | Inhalt | Click-Aktion |
|------|--------|--------------|
| **Kataloge** | Count der Kataloge in dieser Kategorie | kein Filter (informational) |
| **Einträge total** | Sum aller Rows aller Kataloge | filter `bulk-overview` |
| **Letztes Update** | Last-Edit-Timestamp + Actor (Kürzel z.B. `PW`) | öffnet Audit-Log mit Filter `category=<this>` |
| **Verwendet in N Entities** | „1 200 Kandidaten · 84 Mandate" — Live-Count aus `fact_*` | öffnet Verwendungs-Übersicht (Modal) |

Werte werden bei Tab-Switch frisch gefetched · Cache 5 min (Memory `stammdaten.usage.cache_ttl`).

---

## 5. CAT-CARD-GRID

Card-Grid pro Tab-Pane · 3 Spalten Desktop · 2 Tablet · 1 Mobile.

### Card-Anatomy

```
┌────────────────────────────────────────┐
│ ┌──────────────┐         [19 Einträge] │
│ │ Prozess-Stages│                       │
│ └──────────────┘                       │
│                                        │
│ 9 Pipeline-Stages + 10 Analytics-Stages│
│ mit Win-%. Master-Source für Pipeline- │
│ Pfeile und Stage-Drawer.               │
│                                        │
│ Zuletzt: 12.04.2026 (PW)               │
│ Verwendet: 47 aktive Prozesse          │
│                                        │
│ [Lossless] [Admin-Edit]                │
└────────────────────────────────────────┘
```

### Card-Felder

| Feld | Quelle | Editierbar |
|------|--------|------------|
| Title | Sprechende Bezeichnung des Katalogs (z.B. „Prozess-Stages" — **nicht** `dim_process_stages` zeigen, DB-Techdetails-Regel) | ❌ (System-Mapping in `wiki/meta/mockup-baseline.md` §16) |
| Eintrag-Count Badge | `SELECT COUNT(*) FROM dim_<x> WHERE active=true` | ❌ (Live) |
| Beschreibung | Aus `dim_<x>.description` (Tabellen-Kommentar) oder Mapping-Datei | ❌ (Pflege via Migrations) |
| Last-Edit | `MAX(updated_at)` mit Actor-Kürzel (Mitarbeiter-2-Buchstaben aus `dim_mitarbeiter`) | ❌ (Live) |
| Verwendung | `fact_*`-Count („47 aktive Prozesse") | ❌ (Live · 5min cached) |
| Tags | aus §1 Tag-Vokabular | ❌ (System-Mapping) |

### UI-Label-Vocabulary

UI **niemals** `dim_*`-Tabellen-Namen zeigen (CLAUDE.md §DB-Techdetails-im-UI-Regel). Mapping-Tabelle (Auszug, full in `wiki/meta/mockup-baseline.md` §16):

| Tabelle | UI-Label |
|---------|----------|
| `dim_process_stages` | „Prozess-Stages" |
| `dim_kandidat_stages` | „Kandidaten-Stages" |
| `dim_mandate_research_stages` | „Mandat-Research-Stages" |
| `dim_activity_types` | „Activity-Typen" |
| `dim_event_types` | „Event-Typen (System)" |
| `dim_sector` | „Sektoren" |
| `dim_sparte` | „Sparten" |
| `dim_geo_land` | „Länder (ISO)" |
| `dim_geo_kanton` | „Kantone" |
| `dim_pii_classification` | „PII-Klassifikation (DSG)" |
| `dim_org_functions` | „Org-Funktionen" |
| `dim_eq_dimensions` | „EQ-Dimensionen" |
| `dim_motivator_dimensions` | „Motivator-Dimensionen" |
| ... | (Rest siehe Mapping) |

---

## 6. DRILL-DOWN · CATALOG-TABELLE

Click auf Cat-Card → Slide-In von rechts (760px). Zeigt alle Einträge des Katalogs als Tabelle.

### Tabellen-Spalten (anpassbar pro Katalog)

| # | Spalte | Beispiel | Editierbar (admin) | Sortierbar |
|---|--------|----------|---------------------|------------|
| 1 | Code (Slug/PK) | `tt_telefon_interview` | ❌ (nach Anlage) | ✅ |
| 2 | Label DE | „Telefon-Interview" | ✅ | ✅ |
| 3 | Label EN | „Phone Interview" | ✅ | — |
| 4 | Label FR | „Entretien téléphonique" | ✅ | — |
| 5 | Beschreibung | Lange Erklärung | ✅ (Drawer-Tab) | — |
| 6 | Sort-Order | 21 | ✅ (Drag) | ✅ |
| 7 | Aktiv? | ✓ / ✗ | ✅ (Soft-Disable) | ✅ |
| 8 | Verwendet-Count | „318× in History" | ❌ (Live · 5min cached) | ✅ |
| 9 | Audit | „12.04.2026 (PW)" | ❌ | ✅ |

**Spalten-Variation pro Katalog:**
- Multi-Lang-Spalten (EN/FR) nur bei Tags `Multi-Lang` sichtbar; sonst weglassen.
- Numerische Stammdaten (z.B. `dim_honorar_settings.percent`) zeigen Wert statt Label.
- Hierarchische Kataloge (z.B. `dim_functions` mit Kategorie + Sub) zeigen Kategorie als Group-Header.

### Toolbar (oben in Tabelle)

| Element | Browse-Mode | Edit-Mode (admin) |
|---------|-------------|-------------------|
| Suche im Katalog | ✅ | ✅ |
| Filter Aktiv/Inaktiv | ✅ | ✅ |
| Filter „Übersetzung fehlt" | ✅ | ✅ |
| Sort | ✅ | ✅ |
| `+ Eintrag anlegen` | ❌ | ✅ → öffnet `#stammNewEntryDrawer` |
| `Batch-Import CSV` | ❌ | ✅ → öffnet `#stammBatchImportDrawer` |
| `Export CSV` | ✅ | ✅ |
| `Audit-Log` (für diesen Katalog) | ✅ | ✅ → öffnet `#stammAuditDrawer` |

---

## 7. DETAIL-DRAWER (Eintrag-Details)

Click auf Tabellen-Zeile → Detail-Drawer (760px, slide über Drill-Down-Layer).

### Drawer-Tabs

| # | Tab | Inhalt | Editierbar (admin) |
|---|-----|--------|---------------------|
| 1 | **Übersicht** | Code · Label DE · Sort · Aktiv · Beschreibung · Tags · Cluster (falls hierarchisch) | Inline · alle bis auf Code |
| 2 | **Verwendung** | Live-Count + Liste der referenzierenden Records (Top 50, „mehr anzeigen") | ❌ |
| 3 | **History** | Filter auf `fact_audit_log` für diesen Eintrag (Create/Update/Soft-Disable) | ❌ |
| 4 | **Übersetzungen** | DE / EN / FR Editor — nur sichtbar bei Tag `Multi-Lang` | ✅ |

### Verwendungs-Tab Details

```
Verwendet in:
- 318× fact_history (Activity-Type-Referenz)
- 47× aktive Prozesse (Stage-Setting)
- 0× geschlossene Prozesse

Top-Records:
- Aktivität #45123 · 2026-04-28 · Kandidat „Müller, Hans"
- Aktivität #45089 · 2026-04-27 · Kandidat „Weber, Petra"
- ...

[Vollständige Liste exportieren]
```

Live-Query mit Cache 5min — bei großen Zahlen (>1000) Hinweis „Hochrechnung".

---

## 8. BROWSE vs EDIT MODES

### 8.1 Toggle-UX

Top rechts in Page-Banner: `[ Browse ▾ ]` Button → Click öffnet Dropdown:

```
☐ Edit-Modus aktivieren (admin · Audit-pflichtig)
✓ Browse-Modus (Default)
```

Bei Aktivierung:
1. Confirm-Modal „Edit-Modus aktivieren? Jede Mutation wird im Audit-Log mit dir als Actor erfasst."
2. Bei OK: Mode-Switch + Banner oben „⚠ Edit-Modus aktiv · jede Änderung wird im Audit-Log erfasst (`PW` · seit 14:32)"
3. Audit-Event `audit.config.edit_mode_enabled` (mit `actor_id`, `started_at`)

Edit-Modus läuft bis User explizit deaktiviert oder Page-Reload (Session-scoped).

### 8.2 Inline-Edit-Pattern

- Click auf Zelle (z.B. Label DE) → wird zum Input
- Tab/Enter → speichert sofort (optimistic, PATCH-Endpoint)
- Esc → cancel ohne Speichern
- Bei Konflikt (gleichzeitiger Edit eines anderen Admins) → Confirm-Modal:
  > „Wert wurde von JV vor 3 min geändert (alt: 'Phone Call'). Überschreiben?"

  Optionen: `Überschreiben` · `Mein Wert verwerfen` · `Mergen` (zeigt Diff)

### 8.3 CRUD-Operations-Übersicht

| Action | Wer | Confirm? | Audit-Action |
|--------|-----|----------|--------------|
| Neuer Eintrag | admin | ❌ (in Drawer) | `config.<dim>.create` |
| Inline-Edit Label/Desc | admin | ❌ (autosave) | `config.<dim>.update` |
| Sort-Order ändern (Drag) | admin | ❌ | `config.<dim>.reorder` |
| Soft-Disable (`active=false`) | admin | ❌ | `config.<dim>.disable` |
| Reactivate (`active=true`) | admin | ❌ | `config.<dim>.enable` |
| Hard-Delete | admin | ✅ + Reason · nur wenn 0 Verwendungen | `config.<dim>.delete` |
| Batch-Import CSV | admin | ✅ + Preview-Diff | `config.<dim>.batch_import` |

### 8.4 FK-Schutz

- Hard-Delete blockiert wenn Eintrag in `fact_*` referenziert ist (FK-Check via Backend).
- Stattdessen Soft-Disable (`active=false`) → erscheint nicht mehr in Dropdowns, aber alte Records bleiben referenz-konsistent.
- UI-Hinweis: „Eintrag wird in 47 Records verwendet · Hard-Delete blockiert · Soft-Disable empfohlen".

### 8.5 Locked-Kataloge im Edit-Modus

- Auch im Edit-Modus sind Locked/External-Kataloge nicht editierbar.
- Edit-Buttons disabled mit Tooltip:
  - **External:** „Verwaltet außerhalb (ISO 3166) · Update via DB-Migration."
  - **Locked:** „Vier-Augen-Pflicht · Mutation nur via Migrations-Patch + DSG-Review."

---

## 9. SUCHE & GLOBAL-FILTER

### 9.1 Globale Suche (Header)

Suche über alle 67 Kataloge gleichzeitig:
- Match in `code`, `label_de`, `label_en`, `label_fr`, `description`
- Resultat-Liste mit Kontext: „Telefon-Interview · gefunden in Activity-Types · Kategorie Communication"
- Click → springt direkt zum Eintrag (öffnet entsprechenden Tab + Drill-Down + Detail-Drawer)
- Debounced 250ms · Min 2 Zeichen

### 9.2 Schnellfilter-Chips (pro Tab)

Chip-Reihe oben in jedem Tab-Pane (toggle-able):
- ✓ Aktiv (default on)
- ✗ Inaktiv
- 🔒 Locked
- 🌐 External
- ⚠ Übersetzung fehlt
- 🆕 Letzte 7 d geändert
- 🔥 Top 10 Verwendung

Chips sind kombinierbar (AND-Logic). Aktive Chips visually highlighted.

### 9.3 URL-State-Sync

Filter-State wird in URL persistiert:
- `/stammdaten?tab=communication&active=true&missing_translation=true`
- Bookmarkable + Shareable für Cross-Team-Pointing.

---

## 10. ROUTING

| Route | Wirkung | Default-State |
|-------|---------|----------------|
| `/stammdaten` | Tab 1 (Workflow & Prozess) | Browse, Suche leer, Active-Filter on |
| `/stammdaten/:category` | Direkt-Tab — `category` ∈ {`workflow`, `communication`, `skills`, `branchen-geo`, `mitarbeiter-account`, `mandat-honorar-assessment`, `system-scraper`, `governance`} | Browse |
| `/stammdaten/:category/:catalog` | Drill-Down-Slide geöffnet — `catalog` ist Slug (z.B. `process-stages`) | Tabelle gerendert |
| `/stammdaten/:category/:catalog/:entry` | Detail-Drawer offen — `entry` ist Slug/Code | Drawer-Tab „Übersicht" |
| `/stammdaten?search=…` | Globale Suche pre-filled, Resultat-Liste | — |
| `/stammdaten?mode=edit` | Edit-Modus pre-aktiviert (admin only · sonst 403 → fallback Browse) | — |

### Slug-Namens-Convention

- Category-Slug: kebab-case der UI-Label (z.B. „Workflow & Prozess" → `workflow`, „Branchen, Sparten & Geo" → `branchen-geo`).
- Catalog-Slug: kebab-case ohne `dim_`-Prefix (z.B. `process-stages`).
- Entry-Slug: `code` aus DB (z.B. `tt_telefon_interview`).

DB-Techdetails-Regel beachtet: kebab-case-Slugs in URL OK (technisch nötig), in UI immer sprechendes Label.

---

## 11. PERMISSIONS / VISIBILITY MATRIX

### 11.1 Rollen-Matrix

| Operation | AM/CM/RA/BO/HoD | Admin (PW) | External (DSG-Audit, etc.) |
|-----------|------------------|------------|------------------------------|
| `/stammdaten` öffnen | ✅ Browse | ✅ Browse + Edit | ✅ Browse (read-only) |
| Globale Suche | ✅ | ✅ | ✅ |
| Catalog-Drill-Down | ✅ | ✅ | ✅ (Tab 8 Governance ggf. only) |
| Inline-Edit | ❌ | ✅ (außer Locked/External) | ❌ |
| Hard-Delete | ❌ | ✅ (nach FK-Check + Confirm) | ❌ |
| Batch-Import | ❌ | ✅ | ❌ |
| CSV-Export | ✅ | ✅ | ✅ (mit DSG-Audit-Trail) |
| Audit-Log lesen | ❌ (außer eigene Edits) | ✅ | ✅ |

### 11.2 Locked-/External-Override

Admin **kann nicht** External/Locked-Kataloge editieren — nur via DB-Migration durch Backend-Lead. UI zeigt disabled Edit-Buttons mit Tooltip-Hinweis (siehe §8.5).

### 11.3 P2-Stub (`dim_mitarbeiter`)

- Phase-1: nur Read + Sparten-Toggle in Stammdaten Tab 5. Banner: „Volle Lifecycle-Verwaltung in HR-Tool (Phase 2)".
- Phase-2 (HR-Tool-Launch): `dim_mitarbeiter` wird Source-of-Truth des HR-Tools. Stammdaten-Card wird Read-Only-Mirror mit Deep-Link zu HR-Tool.

---

## 12. CROSS-LINKS ADMIN

Kataloge mit Tag `→ Admin` zeigen statt Inline-Edit-Card eine **Read-Only-Card mit Deep-Link**.

### 12.1 Card-Pattern für `→ Admin`-Kataloge

```
┌────────────────────────────────────────┐
│ E-Mail-Templates              [32 Eint.] │
│                                        │
│ Templates für E-Mail-Versand mit       │
│ Variablen-Substitution. Volltext-      │
│ Editor in Admin.                       │
│                                        │
│ [→ Admin Tab 4]   [Übersicht ansehen]  │
└────────────────────────────────────────┘
```

Click auf `[→ Admin Tab 4]` → Navigation `/admin#tab=4&template-list=email`.
Click auf `[Übersicht ansehen]` → öffnet Read-Only-Drill-Down mit Template-Liste (Subject + Last-Used) — keine Body-Anzeige (DSG: Templates können PII-Variablen enthalten).

### 12.2 Mappings Tab → Admin

| Stammdaten-Tag | Admin-Tab | Admin-URL |
|----------------|-----------|-----------|
| Reminder-Templates → Admin | Tab 3 (Templates · Reminders) | `/admin#tab=3` |
| E-Mail-Templates → Admin | Tab 4 (Templates · Communication) | `/admin#tab=4` |
| Notification-Templates → Admin | Tab 4 | `/admin#tab=4` |
| Prompt-Templates → Admin | Tab 4 | `/admin#tab=4` |
| Document-Templates → Admin | Tab 7 (Documents) | `/admin#tab=7` |
| Automation-Settings → Admin | Tab 1 (Settings) | `/admin#tab=1` |
| Scraper-Global-Settings → Admin | Tab 1 (Settings · Scraper-Sub) | `/admin#tab=1&sub=scraper` |

---

## 13. HR-TOOL-OVERLAP (P2)

Vollständige Strategie aus Plan §6 + Memory `project_zeit_modul_architecture.md`.

### 13.1 Phase-1 Verhalten (jetzt)

In Stammdaten Tab 5 (Mitarbeiter, Rollen & Account):
- `dim_mitarbeiter`-Card mit `[12 Einträge]` (10 aktiv + 2 ab 01.05.)
- Drill-Down: Tabelle mit `kuerzel` (PW/JV/LR/...), `display_name`, `sparten` (Multi-Toggle), `aktiv`
- Edit-Modus: nur `aktiv`-Toggle + Sparten-Zuordnung. **Kein** Vertrag/Lohn/Onboarding-CRUD.
- Banner oben in Drill-Down: „⚠ Volle Lifecycle-Verwaltung erfolgt im HR-Tool (Phase 2). Hier nur Sparten + Aktiv-Status."

### 13.2 Phase-2 Migration (HR-Tool-Launch)

- `dim_mitarbeiter` wird **Source-of-Truth** des HR-Tools (`/erp/hr`).
- Stammdaten Tab 5 Mitarbeiter-Card wird Read-Only-Mirror mit Deep-Link `→ HR-Tool`.
- `dim_roles`, `dim_owner_teams`, `dim_mitarbeiter_sparten_link` bleiben in Stammdaten (sind System-Stammdaten, keine HR-Daten).

### 13.3 Daten-Konsistenz-Check

Bei HR-Tool-Migration: Skript prüft `dim_mitarbeiter`-Schema gegen `hr_employees`-Schema des HR-Tools (Mapping-Datei in `specs/ARK_HR_TOOL_SCHEMA_v0_2.md` §22.4). Kein Datenverlust, nur Owner-Wechsel.

---

## 14. SYNC-PLAN

Welche Grundlagen-MD müssen gepatched werden für Stammdaten-Vollansicht?

| Grundlagen-Datei | Änderung | Grund |
|------------------|----------|-------|
| `ARK_DATABASE_SCHEMA_v1_6.md` | keine | Alle `dim_*`-Tabellen existieren bereits · keine neuen Spalten benötigt |
| `ARK_BACKEND_ARCHITECTURE_v2_8.md` | +Sektion „Stammdaten-Endpoints" (~12 GET + ~8 PATCH) | API für Catalog-Lesen + Inline-Edit + Batch-Import + Verwendungs-Stats |
| `ARK_FRONTEND_FREEZE_v1_13.md` | +Route `/stammdaten` · Sidebar-Eintrag „System" | Neuer Vollansicht-Eintrag |
| `ARK_STAMMDATEN_EXPORT_v1_5.md` | keine | Inhalte der Kataloge unverändert · Stammdaten-Vollansicht ist Browse-Layer darüber |
| `ARK_GESAMTSYSTEM_UEBERSICHT_v1_5.md` | Changelog-Eintrag „Stammdaten-Vollansicht v0.1" | Roadmap-Update |

**Patch-Files anzulegen (Folge-Session):**
- `ARK_BACKEND_ARCHITECTURE_PATCH_v2_8_to_v2_9_stammdaten.md`
- `ARK_FRONTEND_FREEZE_PATCH_v1_13_to_v1_14_stammdaten.md`
- `ARK_GESAMTSYSTEM_PATCH_v1_5_to_v1_6_stammdaten.md`

### 14.1 Helper-Tabellen (optional)

Für Performance der Verwendungs-Stats könnte `fact_catalog_usage_cache` helfen (5-min-TTL Cache in DB statt App-Memory). **Default: nicht nötig** — App-seitiger Memory-Cache reicht für Phase-1 (~67 Kataloge × 5min Refresh = vernachlässigbarer DB-Load).

Falls nötig später: Patch via DATABASE_SCHEMA_v1_6 → v1_7.

---

## 15. OFFENE FRAGEN

Plan-§11 hat 10 Fragen mit Vorschlag — alle adoptiert. Verbleibende Specs-Fragen:

| # | Frage | Vorschlag |
|---|-------|-----------|
| 1 | Sort-Order-Drag in Edit-Modus: Pro Spalte oder nur in dedizierter „Sort-Spalte"? | Dedizierte Sort-Spalte — Drag-Handle zeigt nur in Sort-Spalte (verhindert versehentlichen Reorder beim Klicken in Label-Spalten) |
| 2 | Verwendungs-Stats: Top-50-Liste oder pagination-able? | Top-50 + „Vollständig exportieren als CSV"-Button (Performance-Schutz) |
| 3 | Konflikt-Resolution Merge-Mode: 3-Wege-Diff-UI oder einfacher Text-Diff? | Einfacher Text-Diff (Old/Mine/Server in 3 Spalten · keine 3-Wege-Auto-Merge in Phase-1) |
| 4 | Batch-Import-Format: CSV nur oder auch Excel? | CSV nur Phase-1 (UTF-8 BOM-tolerant · Excel via copy-paste-Workflow) |
| 5 | Audit-Filter im Drawer-Tab History: Wie weit zurück Default? | Letzte 30 Tage default · Toggle „Alle anzeigen" für Vollhistorie |
| 6 | Edit-Modus Auto-Timeout? | Nein — Edit-Modus läuft bis explizit aus oder Reload (verhindert Daten-Verlust bei längeren Sessions) |
| 7 | Mobile-Edit-Mode: komplett deaktiviert oder reduziert? | Komplett deaktiviert mit Banner „Edit nur Desktop · zur Konfiguration bitte am Desktop einloggen" |
| 8 | Globale Suche: Min-Score für Resultat-Inclusion? | Match-Type-Reihenfolge: exact-code > exact-label > prefix-label > fuzzy-label · Cutoff bei Levenshtein > 3 |

Bei Mockup-Implementation aufkommende Fragen werden in v0.2-Patch erfasst.

---

**Ende v0.1.** Begleitdokument: `ARK_STAMMDATEN_VOLLANSICHT_INTERACTIONS_v0_1.md`. Review durch PO (PW) erforderlich vor Implementation-Start.
