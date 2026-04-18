# ARK CRM — Stammdaten Vollansicht · Ausarbeitungsplan v0.1

**Stand:** 2026-04-18
**Status:** Plan · vor Mockup-Bau · zur Freigabe
**Quellen-Kontext:**
- `wiki/meta/digests/stammdaten-digest.md` — 67+ `dim_*`-Sektionen aus `ARK_STAMMDATEN_EXPORT_v1_3.md`
- `wiki/meta/detailseiten-inventar.md` — Stammdaten als 2. Sidebar-Eintrag „System"
- `specs/ARK_ADMIN_VOLLANSICHT_SCHEMA_v0_1.md` — Abgrenzung Admin vs Stammdaten
- `wiki/concepts/admin-system.md` — Templates-CRUD-Verteilung
- CLAUDE.md §Stammdaten-Wording-Regel — alle Begriffe lossless

**Ziel:** Eine Vollansicht `/stammdaten` als Browse-Hub für alle Stammdaten-Kataloge. Read für alle Rollen, CRUD für `admin`. Konsolidierter Single-Truth-Browser ohne Funktions-Duplikation mit Admin.

---

## 0. SCOPE & ABGRENZUNG

### Scope (im Stammdaten enthalten)

Alle `dim_*`-Tabellen aus `ARK_STAMMDATEN_EXPORT_v1_3.md` — **67+ Kataloge** in 12 Logischen Kategorien (siehe §2).

### Out-of-Scope (gehört woanders hin)

| Was | Wo |
|-----|-----|
| Feature-Flags · Settings-Keys-CRUD | Admin Tab 1 (Stammdaten zeigt nur Read-Only-Übersicht der Keys) |
| Automation-Regeln-CRUD | Admin Tab 2 (Stammdaten zeigt Read-Only-Liste · Click → Admin) |
| Reminder/Email/Notification/Document-Templates-Edit | Admin Tab 3/4/7 (Stammdaten zeigt nur „Verwaltung in Admin"-Hinweis + Deep-Link) |
| Mitarbeiter-Verwaltung (Onboarding/Vertrag/Lifecycle) | HR-Tool Phase 2 |
| Audit-Log | Admin Tab 10 |

**Single-Truth-Pflege:** Kataloge mit CRUD-Editor in Admin werden in Stammdaten **nur referenziert** (Overview-Card mit Count + „Verwalten in Admin"-Button). Vermeidet Doppel-UI.

### Zwei UI-Modi

| Modus | Wer | Was |
|-------|-----|-----|
| **Browse** | Alle Rollen (Default) | Suche · Filter · Read-Only-Tabellen · Export CSV · Verwendung-Count |
| **Edit** | `admin` (Toggle oben rechts) | Inline-Edit · CRUD pro Eintrag · Batch-Import · Deaktivieren · Sort-Order |

Browse ist Default — Edit-Modus muss explizit aktiviert werden (verhindert Versehen).

---

## 1. KATEGORISIERUNG (12 Logische Gruppen)

Basis: 67+ `dim_*`-Tabellen aus Stammdaten-Digest. Konsolidiert auf 12 Kategorien für UI-Tabs.

| # | Kategorie | Kataloge (Auswahl) | Anzahl Einträge |
|---|-----------|-------------------|-----------------|
| 1 | **Workflow & Prozess** | `dim_process_stages` (19) · `dim_process_status` (8) · `dim_kandidat_stages` (8) · `dim_mandate_research_stages` (13) · `dim_dropped_reasons` (6) · `dim_cancellation_reasons` (9) · `dim_offer_refused_reasons` (10) · `dim_vacancy_rejection_reasons` (8) · `dim_rejection_reasons_internal` (11) · `dim_jobbasket_rejection_types` (12) · `dim_rejection_reasons_candidate` (13) · `dim_rejection_reasons_client` (16) · `dim_final_outcomes_mandate` (8) | ~140 Einträge in 13 Katalogen |
| 2 | **Activities & Communication** | `dim_activity_types` (69 in 11 Kategorien) · `dim_reminder_templates` (10) · `dim_email_templates` (32) · `dim_notification_templates` (10) · `dim_prompt_templates` (7) · `dim_event_types` (60+) | ~190 Einträge in 6 Katalogen |
| 3 | **Dokumente** | `dim_document_templates` (38+1 in 7 Kategorien) · `dim_dossier_preferences` (7) · `dim_presentation_types` (3) | ~50 Einträge in 3 Katalogen |
| 4 | **Skills & Funktionen** | `dim_edv` (109 in 11 Kategorien) · `dim_functions` (~190 in ~25 Kategorien) · `dim_education` (503) · `dim_focus` (~200 in ~25 Kategorien) | ~1 000 Einträge in 4 Katalogen |
| 5 | **Branchen & Sparten** | `dim_sparte` (5: ARC/GT/ING/PUR/REM) · `dim_sector` (35 in 6 Kategorien) · `dim_industry_branche` · `dim_industry_subsparte` · `dim_cluster` (~97 in 4 Sparten-Gruppen) | ~140 Einträge in 5 Katalogen |
| 6 | **Geo & Sprachen** | `dim_geo_land` (~250 ISO 3166) · `dim_geo_kanton` (26) · `dim_geo_plz_range` (~3 200) · `dim_languages` (20) | ~3 500 Einträge in 4 Katalogen |
| 7 | **Mitarbeiter & Rollen** | `dim_mitarbeiter` (10 aktiv) · `dim_roles` (8) · `dim_owner_teams` · `dim_mitarbeiter_sparten_link` | ~30 Einträge — **überlappt mit HR-Tool P2** (siehe §6) |
| 8 | **Account & Kontakte** | `dim_account_klasse` · `dim_account_funktion` · `dim_org_functions` (5) · `dim_dossier_preferences` (7) · `dim_presentation_types` (3) | ~30 Einträge in 5 Katalogen |
| 9 | **Mandat & Honorar** | `dim_honorar_settings` (4 Stufen) · `dim_time_packages` (3) · `dim_sia_phases` (6+12) · Mandat-Typen-Enum | ~30 Einträge in 4 Katalogen |
| 10 | **Assessment** | `dim_assessment_types` (11) · `dim_eq_dimensions` (5) · `dim_motivator_dimensions` (12) · `dim_assess_competencies` (26) · `dim_assess_standard_profiles` (11) · `dim_culture_dimensions` (6) | ~70 Einträge in 6 Katalogen |
| 11 | **Scraper & Matching** | `dim_scraper_types` (7) · `dim_scraper_global_settings` (14) · `dim_matching_weights` (8) · `dim_matching_weights_project` (6) | ~35 Einträge in 4 Katalogen |
| 12 | **System & Governance** | `dim_automation_settings` (27 Keys) · `dim_ai_write_policies` (8) · `dim_pii_classification` (21) · `dim_quality_rule_types` (9) · `dim_naming_convention` | ~70 Einträge in 5 Katalogen |

**Total:** ~67 Kataloge mit ~5 200 Einträgen (dominiert von Skills/Funktionen/Geo).

### Sonderkategorien

- **Externally-Managed (Read-Only auch für Admin):** `dim_geo_land` (ISO 3166) · `dim_languages` (ISO 639) · `dim_pii_classification` (DSG-Vorgabe)
- **Locked-by-Law (gesperrt):** `dim_naming_convention` · `dim_ai_write_policies` (Audit-pflichtig, nur Vier-Augen)
- **Admin-only-CRUD (in Stammdaten Read-Only):** `dim_automation_settings` · `dim_reminder_templates` · `dim_email_templates` · `dim_notification_templates` · `dim_document_templates` · `dim_scraper_global_settings`

---

## 2. UI-LAYOUT-VORSCHLAG

### Variante A · Tabbar mit 12 Kategorien (analog Admin)

```
[Header: Stammdaten · 67 Kataloge · 5 200 Einträge]
[Suche · Filter · Edit-Modus-Toggle (admin) · CSV-Export]
[Tabbar: 12 Kategorien]
  ↓
[Tab-Pane: Card-Grid der Kataloge dieser Kategorie]
  ↓ Click Card
[Detail-View: Tabelle aller Einträge · inline editierbar (admin)]
  ↓ Click Eintrag
[Detail-Drawer: Beschreibung · Verwendung-Stats · Übersetzungen · History]
```

**Vorteil:** Konsistent mit Admin-Pattern (10 Tabs). User kennt das Pattern.
**Nachteil:** 12 Tabs sind viel — Sidebar-Tree wäre kompakter.

### Variante B · Sidebar-Tree links + Tabelle rechts

```
+--------------------+--------------------------------------+
| Kategorien         | Aktiver Katalog: dim_process_stages |
| ▼ Workflow         | Spalten: Code · DE · EN · Sort · ...|
|   ◦ Process Stages | Zeilen mit Inline-Edit              |
|   ◦ Process Status |                                     |
| ▼ Activities       |                                     |
|   ◦ Activity-Types |                                     |
| ...                |                                     |
+--------------------+--------------------------------------+
```

**Vorteil:** Skalierbar · 67 Kataloge sichtbar · IDE-ähnliche UX
**Nachteil:** Bricht aus dem 12-Tab-Pattern aus · andere Mockups arbeiten nicht so

### Variante C · Hybrid (empfohlen)

```
[Header + Suche]
[Tabbar: 8 Kategorien (konsolidiert)]
  ↓
[Tab-Pane:
  - Stat-Strip: Catalog-Count · Entry-Count · Last-Update · Used-In-Entities
  - Card-Grid: 1 Card pro Katalog (Name · Beschreibung · Eintrag-Count · Verwendet-In)
  - Click Card → Drill-Down zur Tabelle (Modal-Page-Innerhalb-Tab oder Slide-In)
]
[Drill-Down-View:
  - Breadcrumb: Stammdaten / Workflow / Process-Stages
  - Tabelle mit allen Einträgen
  - Inline-Edit (admin) oder Read-Only
  - „Zurück zur Übersicht" Button
]
```

**Konsolidierung 12→8 Kategorien:**
1. Workflow & Prozess
2. Communication (= Activities + Templates · groß)
3. Skills & Berufe
4. Branchen, Sparten & Geo
5. Mitarbeiter, Rollen & Account-Klassen
6. Mandat, Honorar & Assessment
7. System & Scraper
8. Governance & Naming-Conventions

**Vorteil:** Konsistenz + Skalierbarkeit · Card-Grid übersichtlich · Drill-Down vermeidet Tab-Bloat
**Empfehlung:** **Variante C**

---

## 3. KOMPONENTEN PRO TAB-PANE

### 3.1 Stat-Strip (oben in jedem Tab)

| Card | Inhalt |
|------|--------|
| Kataloge in dieser Kategorie | Count + Click-to-Filter |
| Einträge total | Sum aller Rows · klickbar zu Tabelle |
| Letztes Update | Last-Edit-Timestamp + Actor |
| Verwendet in N Entities | „1 200 Kandidaten · 84 Mandate" |

### 3.2 Card-Grid (Catalog-Cards)

```html
<div class="cat-card" onclick="openCatalog('process_stages')">
  <div class="cat-card-head">
    <h3>Prozess-Stages</h3>
    <span class="badge">19 Einträge</span>
  </div>
  <p class="cat-card-desc">9 Pipeline-Stages + 10 Analytics-Stages mit Win-%.
  Master-Source für Pipeline-Pfeile, Stage-Drawer, Reminder-Trigger.</p>
  <div class="cat-card-foot">
    <span>Zuletzt geändert: 12.04.2026 (PW)</span>
    <span>Verwendet: 47 aktive Prozesse</span>
  </div>
  <div class="cat-card-tags">
    <span class="tag locked">Lossless</span>
    <span class="tag admin">Admin-Edit</span>
  </div>
</div>
```

**Tag-Typen:**
- `Lossless` — komplett dokumentiert, sollte unverändert bleiben
- `Lossy` — große Kataloge mit lossy-Digest
- `External` — extern verwaltet (ISO etc.)
- `Locked` — gesperrt by law (Vier-Augen oder gar nicht)
- `Admin-Edit` — CRUD nur Admin
- `Multi-Lang` — DE/EN/FR-Übersetzungen
- `→ Admin` — Verwaltung in Admin-Vollansicht (Click-Through)

### 3.3 Drill-Down · Catalog-Tabelle

Spalten (anpassbar pro Katalog):

| # | Spalte | Beispiel | Editierbar (admin) |
|---|--------|----------|--------------------|
| 1 | Code (Primary-Key/Slug) | `tt_telefon_interview` | ❌ (nach Anlage) |
| 2 | Label DE | „Telefon-Interview" | ✅ |
| 3 | Label EN | „Phone Interview" | ✅ |
| 4 | Label FR | „Entretien téléphonique" | ✅ |
| 5 | Beschreibung | Lange Erklärung | ✅ |
| 6 | Sort-Order | 21 | ✅ |
| 7 | Aktiv? | ✓ | ✅ (Soft-Disable) |
| 8 | Verwendet-Count | 318× in `fact_history` | ❌ (Live-Stat) |
| 9 | Audit | Last-Edit + Actor | ❌ |

**Toolbar oben in Tabelle:**
- Suche im Katalog · Filter Aktiv/Inaktiv · Filter Sprache fehlt · Sort
- (Admin) `+ Eintrag anlegen` · Batch-Import CSV · Export CSV

### 3.4 Detail-Drawer (Click auf Eintrag)

Tabs im Drawer:
1. **Übersicht** — alle Felder, Übersetzungen
2. **Verwendung** — wo ist dieser Eintrag referenziert (Live-Stat)
3. **History** — alle Änderungen seit Anlage (`fact_audit_log`-Filter)
4. **Übersetzungen** — Multi-Lang-Editor (admin)

---

## 4. EDIT-MODUS · DETAILS

### 4.1 Toggle-UX

Top rechts: `[ Browse ▾ ]` Button → Click öffnet Dropdown:
- ☐ Edit-Modus aktivieren (admin · Audit-pflichtig)
- ✓ Browse-Modus (Default)

Bei Edit-Aktivierung: Banner oben „⚠ Edit-Modus aktiv · jede Änderung wird im Audit-Log erfasst"

### 4.2 Inline-Edit-Pattern

- Click auf Zelle (z.B. Label DE) → wird zum Input
- Tab/Enter → speichert sofort (optimistic)
- Esc → cancel
- Bei Konflikt (gleichzeitiger Edit) → Confirm-Modal „Wert wurde von JV vor 3 min geändert. Überschreiben?"

### 4.3 CRUD-Operations

| Action | Wer | Confirm? | Audit-Action |
|--------|-----|----------|--------------|
| Neuer Eintrag | admin | nein | CREATE |
| Inline-Edit Label/Desc | admin | nein (autosave) | UPDATE |
| Sort-Order ändern (Drag) | admin | nein | UPDATE |
| Soft-Disable (active=false) | admin | nein | UPDATE |
| Hard-Delete | admin | **ja** + Reason · nur wenn 0 Verwendungen | DELETE |
| Batch-Import CSV | admin | **ja** + Preview-Diff | CREATE × n |

### 4.4 FK-Schutz

- Hard-Delete blockiert wenn Eintrag in `fact_*` referenziert ist
- Stattdessen Soft-Disable (`active=false`) → erscheint nicht mehr in Dropdowns, aber alte Records bleiben

---

## 5. SUCHE & GLOBAL-FILTER

### 5.1 Globale Suche (Header)

Suche über alle 67 Kataloge gleichzeitig:
- Match in Code · Label DE · Label EN · Beschreibung
- Resultat-Liste mit Kontext: „Telefon-Interview · gefunden in Activity-Types · Kategorie Communication"
- Click → springt direkt zum Eintrag

### 5.2 Schnellfilter-Chips

Chip-Reihe oben:
- ✓ Aktiv · ✗ Inaktiv · 🔒 Locked · 🌐 Externally-Managed · ⚠ Übersetzung fehlt · 🆕 Letzte 7 d geändert · 🔥 Top 10 Verwendung

---

## 6. ÜBERLAPP MIT HR-TOOL (P2)

`dim_mitarbeiter` und `dim_roles` sind doppelt relevant:
- **CRM-Stammdaten:** Anzeige + Sparten-Zuordnung + Aktiv-Status + Quick-Actions (Telefon/Email anrufen)
- **HR-Tool P2:** Voller Lifecycle (Onboarding · Vertrag · Lohn · Austritt)

### Phase-1-Strategie

In Stammdaten Tab 5: Mitarbeiter-Karten mit nur Read + Sparten-Toggle (kein Lifecycle-CRUD). Hinweis-Banner „Volle Verwaltung in HR-Tool (Phase 2)".

### Phase-2-Migration

Bei HR-Tool-Launch wird `dim_mitarbeiter` zur Source-of-Truth des HR-Tools — Stammdaten zeigt dann nur noch Read-Only-Mirror mit Link.

---

## 7. ROUTING

| Route | Wirkung |
|-------|---------|
| `/stammdaten` | Default Tab 1 (Workflow & Prozess) |
| `/stammdaten/:category` | Direkt-Tab z.B. `/stammdaten/communication` |
| `/stammdaten/:category/:catalog` | Drill-Down z.B. `/stammdaten/communication/activity_types` |
| `/stammdaten/:category/:catalog/:entry` | Detail-Drawer offen z.B. `/stammdaten/communication/activity_types/tt_telefon_interview` |
| `/stammdaten?search=...` | Global-Search Pre-filled |
| `/stammdaten?mode=edit` | Edit-Modus aktiv (admin) |

---

## 8. DESIGN-SYSTEM

Erbt aus `wiki/meta/mockup-baseline.md`. Eigene Patterns:

| Pattern | Analog zu | Neu |
|---------|-----------|-----|
| Tabbar 8 Kategorien (sticky) | Admin Tabbar §17.5 | — |
| Cat-Card-Grid | Tmpl-Card §17 (Admin) | Tag-Chips · Verwendung-Foot |
| Catalog-Tabelle | dt-table §17 (Admin) | Multi-Lang-Spalten · Inline-Edit-Cells |
| Detail-Drawer Wide 760px | Admin Drawer-Wide §17.11 | Tab-Verwendung mit Live-Query |
| Edit-Mode-Banner | Admin-Warn-Banner §17.1 | Andere Farbe (amber) für Mode-Switch |

---

## 9. PRINZIPIEN

- **Single-Source-of-Truth:** Kataloge mit CRUD in Admin werden in Stammdaten **nur referenziert**. Vermeidet Doppel-Wartung.
- **Browse-First:** Default ist Read-Only. Edit-Modus muss aktiv geschaltet werden.
- **Audit-Pflicht:** Jede Mutation → `fact_audit_log` mit `action=CONFIG`.
- **Optimistic-Update:** Inline-Edit schreibt sofort, Spinner nur bei Hard-Failure.
- **Multi-Lang-aware:** UI zeigt aktive Sprache (DE Default), Edit immer alle 3 (DE/EN/FR).
- **Verwendung-Live:** Stat „verwendet in N Entities" wird live aus `fact_*` berechnet, gecacht 5 min.
- **Locked-Markers:** External/Locked-Kataloge zeigen Schloss-Icon · Edit-Buttons disabled.
- **Deep-Link-fähig:** Direkt-Link zu Katalog/Eintrag aus Spec/Audit-Log.
- **Mobile:** Browse-Mode tauglich (Tabellen scroll horizontal). Edit-Mode → Hinweis „Desktop empfohlen".

---

## 10. PHASEN

| Phase | Scope | Output |
|-------|-------|--------|
| **0 · Plan** (dieses Dokument) | Analyse + Layout-Vorschlag | Plan-Doku · Freigabe |
| **1 · Mockup-Skelett** | 8 Tabs · Cat-Card-Grid · Drill-Down statisch · 1 Catalog beispielhaft (Process-Stages) | `mockups/stammdaten.html` |
| **2 · Mockup-Vollausbau** | Alle 67 Kataloge angedeutet (Cards) · 5 Drill-Downs als Demo · Detail-Drawer · Edit-Mode-Toggle | Mockup-Update |
| **3 · Specs** | Schema + Interactions analog Admin | 2 Spec-Files |
| **4 · DB-Patch** | Falls neue Helper-Tabellen nötig (`fact_catalog_usage_cache`?) | Patch-File |
| **5 · Backend-Patch** | API-Endpoints `/api/stammdaten/*` | Patch-File |
| **6 · Migration** | Falls DB-Patch | SQL-File |

**Empfehlung:** Phase 1 + 2 in einem Schritt (Mockup komplett), Phase 3 nachgelagert (Mockup-First-Workflow gem. Memory `feedback_mockup_first_workflow.md`).

---

## 11. OFFENE FRAGEN VOR MOCKUP-START

| # | Frage | Vorschlag |
|---|-------|-----------|
| 1 | **Variante A vs B vs C?** | C (Hybrid) — Tabbar + Card-Grid + Drill-Down |
| 2 | **8 oder 12 Kategorien?** | 8 (konsolidiert) — sonst Tab-Bloat |
| 3 | **Edit-Mode Toggle vs separater Read-Only-View?** | Toggle (Edit-Mode aktivierbar) — kein zweiter Mockup |
| 4 | **Multi-Lang inline oder nur in Drawer?** | Inline DE als Default · EN/FR im Drawer-Tab „Übersetzungen" |
| 5 | **Verwendung-Count cached oder live?** | Cached 5 min (Performance) |
| 6 | **Drill-Down als Slide-In oder Inline-Replace?** | Slide-In von rechts (analog Detail-Drawer 760 px) |
| 7 | **Beispiel-Datensatz für Mockup** | Process-Stages (19 Einträge, lossless, gut bekannt) |
| 8 | **Mitarbeiter-Tab in Stammdaten oder schon HR-stub?** | In Stammdaten Tab 5 mit Phase-2-Hinweis |
| 9 | **Locked-Kataloge sichtbar oder versteckt?** | Sichtbar mit Schloss-Icon (Transparenz) |
| 10 | **Admin-only-CRUD-Kataloge in Stammdaten zeigen?** | Ja, als Read-Only-Card mit „→ Admin"-Button (kein Inline-Edit) |

---

## 12. NÄCHSTER SCHRITT

Bei Freigabe Variante C + Antworten auf §11:
1. Mockup-Skelett `mockups/stammdaten.html` mit 8 Tabs + Process-Stages-Beispiel-Drill-Down + Detail-Drawer
2. Sidebar-Eintrag in `crm.html` aktivieren (`data-src="stammdaten.html"` statt `#`)
3. Lint-Check
4. Specs nachgelagert

Geschätzter Aufwand: 2–3 h Mockup · 1–2 h Specs · 30 min Patches.
