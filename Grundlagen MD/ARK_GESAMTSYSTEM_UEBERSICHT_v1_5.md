# ARK CRM/ERP — Gesamtsystem-Übersicht v1.5

**Stand:** 2026-04-25
**Autor:** Peter Wiederkehr (Produkt-Owner) + Claude (Architektur)
**Zweck:** Vollständige Beschreibung des ARK-Systems für neue Entwickler, Reviewer und Stakeholder
**Vorgänger:** v1.4 (2026-04-24 · E-Learning + HR) / v1.3.5 (2026-04-17 · Reminders) / v1.3 (2026-04-14) / v1.2 (2026-03-30)
**Scope v1.5:** Performance-Modul (TEIL 26 · Cross-Modul-Analytics-Hub · 8 Architektur-Entscheidungen 2026-04-25 · ~33 Metriken · Markov-Forecast v0.1 · PowerBI-View-Layer · ETL-Worker-Architektur · Reuse Sparten/MA/Stage-Stammdaten)
**Scope v1.4:** E-Learning-Modul Sub A/B/C/D + Topbar-Toggle CRM↔ERP + HR-Modul (TEIL 25)

## Änderungen v1.2 → v1.3

**Ergänzung** zu v1.2 — inhaltliche Kern-Aussagen bleiben gültig, konkretisiert und aktualisiert basierend auf Komplett-Audit + 14 Entscheidungen 2026-04-14. Siehe auch **TEIL 20** (v1.3.1 Account-UI), **TEIL 20b** (v1.3.2 Snapshot-Harmonisierung 2026-04-16), **TEIL 20c** (v1.3.3 Projekt-Detailmaske Phase A–I 2026-04-16), **TEIL 21** (Spec-Sync-Regel), **TEIL 22** (v1.3.4 Globaler Dok-Generator 2026-04-17) und **TEIL 23** (v1.3.5 Reminders-Vollansicht 2026-04-17).

## Änderungen v1.3 → v1.3.4 (2026-04-17)

**Ergänzung:** Globaler Dok-Generator als eigene Detailmaske unter `/operations/dok-generator` + Assessment-Spec-Sync v0.2 → v0.3.

### 22.1 Neuer globaler Dok-Generator

- **Location:** `/operations/dok-generator` (Sidebar-Bereich Operations, Sibling zu Email-Inbox, Reminders, Scraper)
- **Ersetzt** verstreute CTAs in Entity-Detailmasken (Mandat-Offerte-Gen, Assessment-Offerte-Gen, Kandidat-Tab-9 Dok-Generator) durch zentrale Workflow-Engine
- **38 aktive Templates** (+ 1 ausstehend `mandat_offerte_time`) in 7 Kategorien: Mandat-Offerte · Mandat-Rechnung · Best-Effort · Assessment · Rückerstattung · Kandidat · Reportings
- **Neu im Katalog:** Executive Report (Arkadium-Zusammenfassung Assessment mit manuellen Feldern)
- **Du/Sie + Rabatt + Mandat-Typ = separate Templates** (nicht Parameter — ganzer Text unterscheidet sich, User-Entscheidung 2026-04-17)
- **Auto-Pull aus Entity-Vollansichten** via Platzhalter `{{entity.feld}}`
- **5-Step-Workflow:** Template → Entity → Ausfüllen → Preview → Ablage
- **Deep-Link-fähig** aus allen Entity-CTAs (`?template=<key>&entity=<type>:<id>`)
- **Kandidat-Tab-9** wird migriert: Phase 1 Redirect-Banner, Phase 3 deprecated

### 22.2 Neue Grundlagen-Entries

- **Stammdaten §56** — `dim_document_templates` Katalog mit 38+1 Templates
- **Database §14.1** — `document_label` ENUM-Erweiterung (12 neue Labels inkl. 'Executive-Report')
- **Database §14.2** — `dim_document_templates` Tabelle
- **Database §14.3** — `fact_documents` Erweiterung (5 neue Felder: `generated_from_template_id`, `generated_by_doc_gen`, `params_jsonb`, `entity_refs_jsonb`, `delivery_mode`, `email_recipient_contact_id`)
- **Backend §L** — 9 neue Endpoints unter `/api/v1/document-templates/*` + `/api/v1/documents/generate,resolve-placeholders,regenerate,email` + `/api/v1/document-generator/recent,drafts`; Wrapper-Mapping bestehender Endpoints
- **Frontend §4e** — Neue Detailmaske-Spec `/operations/dok-generator` mit 5-Step-Workflow, 280px Sidebar, WYSIWYG-Editor

### 22.3 Assessment-Spec-Sync v0.2 → v0.3

Parallel zur Dok-Generator-Spec wurde Assessment-Detailmaske-Spec gesynct:

- **Order-Status `invoiced` entfernt** aus `fact_assessment_order.status` ENUM (`SCHEMA_v0_3` + `INTERACTIONS_v0_3`) — Rechnungs-Bezahl-State lebt auf `fact_assessment_billing.status`, nicht Order-Level
- **Phase-1-Typen-Kommentar** in Assessment-Schema §0 ergänzt — Mockup/Launch nutzt nur MDI/Relief/ASSESS 5.0/EQ Test (SCHEELEN-Produkte)
- **Database §14.3** — ENUM-Fix + Migration-Pfad (`UPDATE fact_assessment_order SET status='fully_used' WHERE status='invoiced';`)

### 22.4 Spec-Sync-Status

| Datei | Vorher | Nachher | Änderung |
|-------|--------|---------|----------|
| `ARK_STAMMDATEN_EXPORT_v1_3.md` | v1.3 | v1.3.4 (append §56) | Template-Katalog |
| `ARK_DATABASE_SCHEMA_v1_3.md` | v1.3 | v1.3.4 (append §14.1–14.3) | Neue Tabelle + Enum-Fixes |
| `ARK_BACKEND_ARCHITECTURE_v2_5.md` | v2.5 | v2.5.4 (append §L) | 9 neue Endpoints |
| `ARK_FRONTEND_FREEZE_v1_10.md` | v1.10 | v1.10.4 (append §4e) | Neue Detailmaske |
| `ARK_GESAMTSYSTEM_UEBERSICHT_v1_3.md` | v1.3 | v1.3.4 | Dieser Eintrag |
| `specs/ARK_ASSESSMENT_DETAILMASKE_SCHEMA_v0_2.md` | v0.2 | **v0.3** (renamed) | Invoiced raus + Phase-1-Kommentar |
| `specs/ARK_ASSESSMENT_DETAILMASKE_INTERACTIONS_v0_2.md` | v0.2 | **v0.3** (renamed) | Invoiced raus aus State-Machine |
| `specs/ARK_DOK_GENERATOR_SCHEMA_v0_1.md` | — | **v0.1 (neu)** | Dok-Generator-Spec |
| `specs/ARK_DOK_GENERATOR_INTERACTIONS_v0_1.md` | — | **v0.1 (neu)** | Dok-Generator-Interactions |

### 22.5 Wiki-Einträge (ausstehend P1)

- `wiki/concepts/dok-generator.md` — Architektur-Konzept
- `wiki/concepts/executive-report.md` — Arkadium-Assessment-Zusammenfassung
- `wiki/concepts/template-versionierung.md` — Phase 2 Semver-Pattern

### 22.6 Mockup-Scope Phase 1

5 Seed-Templates mit vollem Canvas-Content:
1. `mandat_offerte_target` (Mandat-Offerte mit Honorar-Tabelle, Garantiefrist)
2. `rechnung_mandat_teilzahlung_1_sie` (RE-2026-0118 Format)
3. `assessment_offerte` (Credits-Tabelle mit Paket-Pauschale)
4. `ark_cv` (Kandidaten-CV mit Werdegang)
5. `executive_report` (Arkadium-Auswertung mit manuellen Feldern)

33 weitere Templates als Library-Cards sichtbar, Canvas-Content Phase 2.

### 22.7 Offene Folge-Tasks

| # | Task | Phase |
|---|------|-------|
| 1 | DOCX-Template-Parser (Placeholder-Auto-Extraktion aus Ursprungs-DOCX) | 1.5 |
| 2 | PDF-Render-Engine-Wahl (WeasyPrint vs Chromium Headless) + Integration | 1.5 |
| 3 | Template-Admin-UI (CRUD `dim_document_templates`) | 2 |
| 4 | EN-Sprach-Support via LLM-Übersetzung | 2 |
| 5 | Draft-Auto-Save mit `fact_document_drafts` Tabelle | 2 |
| 6 | Template-Version-Management (Semver + Rollback) | 2 |

---


### 1. Mandatsarten umbenannt

| Alt (v1.2) | Neu (v1.3) | Änderung |
|-----------|-----------|----------|
| Einzelmandat | **Target** | Umbenannt |
| RPO | **Taskforce** | Umbenannt (gleiche Struktur, neuer Name) |
| Time | Time | Unverändert |

Alt-Mandate laufen weiterhin unter entsprechendem `mandate_type`.

### 2. Prozess-Architektur: Mischform statt Vollseite

v1.2 sagte: "Detailansichten als Vollseiten." v1.3 Klarstellung: Prozesse sind **Mischform**:
- Listen-Modul `/processes` + **Slide-in-Drawer (540px)** als Haupt-Arbeitsort (80% Fälle)
- Schlanke 3-Tab-Detailseite `/processes/[id]` für komplexe Fälle

### 3. Firmengruppen als vollwertige Entity

- **2-stufig flach** (keine Sub-Gruppen)
- **Kein eigener Group-AM** (Founder-Level)
- Eigene Detailseite `/company-groups/[id]` mit 6 Tabs
- **Gruppen-Schutzfrist**: `fact_protection_window.scope ENUM('account','group')`
- Gruppenübergreifende Taskforces via `bridge_mandate_accounts` (N:N)

### 4. Assessments mit Credits-basiertem Auftragsmodell

Eigene Detailseite `/assessments/[id]`. 11 Assessment-Typen (MDI/Relief/ASSESS 5.0/DISC/EQ/Scheelen 6HM/Driving Forces/Human Needs/Ikigai/AI-Analyse/Teamrad-Session). **Typisierte Credits** — ein Auftrag enthält gemischte Typen, Umwidmung nur innerhalb gleichen Typs.

### 5. Scraper als Control-Center

`/scraper` mit 6 Tabs: Dashboard, Review-Queue, Runs, Configs, Alerts, History. 7 Scraper-Typen (Team-Page, Career-Page, Impressum, LinkedIn Phase 2, Jobboards, PR-Reports, Handelsregister). Confidence-Schwellen: ≥ 85% auto / 60-84% review / < 60% markiert als `needs_am_review`.

### 6. Projekte mit 3-Tier-Struktur

`/projects/[id]` mit 6 Tabs. Hierarchie: Projekt → Gewerk (BKP) → Beteiligungen (Firmen + Kandidaten mit SIA-Phasen). **SIA 6 Haupt + 12 Teil hierarchisch.**

### 7. Schutzfrist-System

- `fact_candidate_presentation` + `fact_protection_window`
- Nur konkret vorgestellte Kandidaten (nicht Longlist-Idents)
- Scope `account` ODER `group`
- Auto-Extension 12 → 16 Monate bei Info-Verweigerung
- **Claim-Billing-Logik (3 Fälle):** X Mandat-identisch → Rest-Summe, Y andere Position → Staffel, Z Erfolgsbasis → Staffel
- **AM alleine** kann Claim stellen

### 8. Mandats-Kündigung (Exit Option)

80%-Formel:
- Fall A (Arkadium): `80% × Gesamtsumme − bezahlte Stages`
- Fall B (Auftraggeber): `max(Stages bis laufende, 80%) − bezahlte Stages`

Atomare TX: Status + Rechnung + Schutzfrist-Opening + Longlist-Lock + Events. **AM alleine** kann kündigen. Offene Prozesse bulk-rejectbar.

### 9. Sprachstandard & Routen

- **DB-Feldnamen:** Englisch (`candidate_id`, `account_id`, `mandate_id`, ...)
- **Status-Enums intentional gemischt:** Mandat/Job/Projekt/Kandidat deutsch, Prozess/Assessment/Scraper/Temperature englisch
- **Routen alle englisch:** `/candidates`, `/accounts`, `/mandates`, `/jobs`, `/processes`, `/assessments`, `/company-groups`, `/projects`, `/scraper`
- Siehe `wiki/concepts/status-enum-katalog.md`

### 10. Detailseiten-Inventar (9 Entitäten)

| # | Detailseite | Route | Status |
|---|-------------|-------|--------|
| 1 | Kandidaten | `/candidates/[id]` | ✅ v1.2 |
| 2 | Accounts | `/accounts/[id]` | ✅ Schema v0.1 + Interactions v0.3 |
| 3 | Firmengruppen | `/company-groups/[id]` | ✅ v0.1 |
| 4 | Mandate | `/mandates/[id]` | ✅ Schema v0.1 + Interactions v0.3 |
| 5 | Jobs | `/jobs/[id]` | ✅ v0.1 |
| 6 | Prozesse | `/processes/[id]` + `/processes` Listen-Modul | ✅ v0.1 (Mischform) |
| 7 | Assessments | `/assessments/[id]` | ✅ v0.2 (typisierte Credits) |
| 8 | Projekte | `/projects/[id]` | ✅ Schema v0.2 + Interactions v0.1 |
| 9 | Scraper | `/scraper` | ✅ v0.1 |

**Nicht im CRM:** Mitarbeiter → ERP HR. Reporting → ERP Performance-Tool, im CRM nur Dashboard.

### 11. Referenz-Dokumente

- `ARK_DATABASE_SCHEMA_v1_3.md` — 28 neue Tabellen + 30+ Feld-Erweiterungen
- `ARK_BACKEND_ARCHITECTURE_v2_5.md` — 30+ Events, 18 Worker, 46 Endpunkte, WebSocket, Rate-Limiting
- `ARK_FRONTEND_FREEZE_v1_10.md` — 5 neue Detailseiten-Kapitel, Account-Tabs 10→13, Prozess-Mischform
- `ARK_STAMMDATEN_EXPORT_v1_3.md` — 15 neue dim_*-Tabellen

**Spec-Dokumente** in `/specs/`: 18 Dateien (Schema + Interactions) für 9 Detailseiten.

**Wiki-Konzepte:** `wiki/concepts/status-enum-katalog.md`, `mandat-kuendigung.md`, `direkteinstellung-schutzfrist.md`, `optionale-stages.md`, `diagnostik-assessment.md`.

**Audit-Reports:** `wiki/analyses/audit-2026-04-13-komplett.md`, `audit-entscheidungen-2026-04-14.md`.

---

# Original v1.2 (unverändert übernommen als Referenz)

# ARK CRM/ERP — Gesamtsystem-Übersicht v1.2 (korrigiert)

**Stand:** 2026-03-30
**Autor:** Peter Wiederkehr (Produkt-Owner) + Claude (Architektur)
**Zweck:** Vollständige Beschreibung des ARK-Systems für neue Entwickler, Reviewer und Stakeholder

---

## TEIL 1: WAS IST ARK?

### 1.1 Das Unternehmen

ARK Executive Search (Arkadium AG) ist eine Schweizer Personalberatung spezialisiert auf die Baubranche. Das Unternehmen vermittelt Fach- und Führungskräfte in den Bereichen Tiefbau, Hochbau, HLKS, Gebäudetechnik, Architektur und Bauingenieurwesen.

Die Kerndienstleistung ist "Executive Search" mit der Methode "Direct Search" — ARK sucht aktiv nach Kandidaten anstatt auf Bewerbungen zu warten. Direct Search ist keine Mandatsart, sondern die grundlegende Arbeitsmethode die ARK bei allen Auftragstypen anwendet.

### 1.2 Die fünf Sparten

| Kürzel | Name | Beschreibung |
|---|---|---|
| ING | Civil Engineering | Ingenieurwesen, Umweltingenieure, Bauphysiker, Geotechnik |
| GT | Building Technology | Gebäudetechnik, Netzthematiken, Energiesektor |
| ARC | Architecture | Architektur, Innenarchitektur und Design |
| REM | Real Estate Management | Immobilienmanagement, Entwicklung, Asset Management |
| PUR | Procurement | Einkauf, Supply Chain, Beschaffung |

Jeder Kandidat, Account und Job wird einer primären Sparte zugeordnet.

### 1.3 Die Rollen

| Rolle | Aufgabe |
|---|---|
| Head of (HoD) | Spartenleitung, strategische Steuerung, Eskalationsstufe |
| Account Manager (AM) | Kundenbetreuer, akquiriert Mandate |
| Candidate Manager (CM) | Kandidatenbetreuer, führt Briefings, steuert GO-Prozess |
| Research Analyst (RA) | Longlist-Recherche, Erstansprache, Kaltakquise |
| Backoffice (BO) | Administration, Assessment-Management |
| Admin | Systemadministration, Benutzerverwaltung |

Eine Person kann mehrere Rollen gleichzeitig haben (z.B. CM + AM).

### 1.4 Der Arbeitstag eines Consultants

Der Consultant öffnet morgens das CRM (Electron Desktop-App) und arbeitet den ganzen Tag ausschliesslich darin. Kein separates Outlook, kein Browser für LinkedIn.

Dashboard zeigt: Überfällige Reminders, unklassifizierte Anrufe/Emails (gelber Badge mit Zähler), nicht zugewiesene History-Einträge, ausstehende AI-Empfehlungen zum Bestätigen, KPIs.

Was der Consultant NIE manuell tun muss: Stage-Changes, Prozess-Erstellung nach CV Sent, Duplikat-Erkennung, AI-Summaries, Zuordnung Call/Email → Kandidat, Gate-Prüfungen, Template-basierte Email-Klassifizierung.

Was der Consultant IMMER manuell tun muss: Activity-Type bestätigen (1-Klick), Dokumente hochladen, Briefing-Maske ausfüllen, Kandidat in Jobbasket legen, Rejection-Gründe angeben, AI-Empfehlungen bestätigen/ablehnen.

---

## TEIL 2: DER REKRUTIERUNGSPROZESS

### 2.1 Zwei Geschäftsmodelle

**Mit Mandat (Einzelmandat, RPO, Time):** Formeller Auftrag mit definierten Konditionen.

**Auf Erfolgsbasis (Best Effort):** Kein formelles Mandat. Kandidaten werden proaktiv vorgestellt. Honorar nur bei Placement, nach gestaffelter Tabelle (unter 90k → 21%, unter 110k → 23%, unter 130k → 25%, ab 130k → 27%). Pro Prozess individuell überschreibbar.

Der Prozessablauf ist bei beiden identisch: Briefing → GO-Termin → Preleads → Mündliche/Schriftliche GOs → CV/Exposé versenden → Interview-Pipeline → Placement. Der Unterschied: Bei Mandaten gibt es eine Longlist, KPI-Tracking und Mandat-spezifische Konditionen. Bei Erfolgsbasis fehlt das Mandat als Struktur, AGB müssen vom Kunden bestätigt werden.

### 2.2 Mandatsarten

| Typ | Beschreibung | Zahlung |
|---|---|---|
| Einzelmandat | Exklusiver Auftrag für eine Stelle | 3 Teile: (1) Vertragsunterzeichnung, (2) Shortlist (konfigurierbare Anzahl CV Sent), (3) Placement |
| RPO | Aufbau Abteilung/Standort, mind. 3 Positionen. Jede Position = eigener Job unter dem Mandat | Monatliche Fee + Erfolgsfee pro Position |
| Time | Reine Beratungsleistung | Nur monatliche Fee |

### 2.3 Longlist / Research

Der RA baut eine Longlist auf. Research-Flow:

Research → Nicht erreicht → CV Expected → CV IN → Briefing → GO mündlich → GO schriftlich

Ab "CV IN" sind Stages gesperrt (nur Automationen können ändern). Stages: Research, Nicht erreicht (NE), Nicht mehr erreichbar, Nicht interessiert (NIC = Not Interested Currently), Dropped, CV Expected, CV IN (auto bei CV-Upload), Briefing (auto bei Briefing-Speichern), GO mündlich (auto bei Mündliche-GOs-Email), GO schriftlich (auto bei Schriftl. GO-Eingang), Ghosted (auto nach Fristablauf), Rejected Oral/Written GO.

**Synchronisierung:** Alle Kandidaten in einer Longlist erhalten bei relevanten History-Einträgen automatisch Stage-Updates auch in der Mandate Research. NIC → rejected, Dropped → dropped, CV-Upload → cv_in, etc.

### 2.4 Preleads und GO-Prozess

**Preleads** sind Unternehmen/Jobs die der CM dem Kandidaten im GO-Termin vorstellen möchte.

1. Nach GO-Termin wählt CM passende Accounts/Jobs aus → kommen als Preleads in Jobbasket
2. CM bespricht Preleads mit Kandidat
3. CM versendet Email "Mündliche GOs" mit Prelead-Liste → Kandidat soll schriftlich rückbestätigen
4. Kandidat bestätigt schriftlich welche er verfolgen möchte
5. Abgelehnte Preleads: Rejected Candidate (Kandidat will nicht), Rejected CM (CM findet sinnlos), Rejected AM (AM findet nicht passend)

### 2.5 Jobbasket und Versand

Prelead → Oral GO → Written GO → Assigned → To Send → CV Sent / Exposé Sent

Gate 1 (Assigned): Automatisch wenn Schriftl. GO + CV + Diplom + Zeugnis vorhanden.
Gate 2 (Versand): Buttons erscheinen wenn ARK CV/Exposé vorhanden. Versand erstellt automatisch einen Prozess.

### 2.6 Prozess (Interview-Pipeline)

Exposé → CV Sent → TI → 1. Interview → 2. Interview → 3. Interview → Assessment → Angebot → Platzierung

Status: Open, On Hold, Rejected, Placed, Stale, Closed, Cancelled, Dropped. Cancelled = Rückzieher nach Placement (Kandidat zieht nach Zusage zurück, 100% Rückvergütung). Stale = zu lange in gleicher Stage (konfigurierbar). Closed = regulär abgeschlossen (Garantiefrist). Dropped = Prozess kam nicht zustande. Prozesse können mit oder ohne Mandat existieren.

**Arkadium-Rolle (CLAUDE.md §Arkadium-Rolle-Regel — präzisiert 2026-04-16):** Arkadium ist Headhunting-Boutique und nimmt an **keinem** Interview teil. Alle Interview-Stages (TI, 1./2./3. Interview, Assessment) laufen direkt zwischen **Kunde und Kandidat**. Termine werden meist direkt zwischen Kunde und Kandidat vereinbart. Arkadium-Touchpoints rund um jedes Interview:

| Touchpoint | Teilnehmer | Wann | Activity-Type (Katalog §14) |
|------------|-----------|------|---------------------------|
| **Briefing** | Arkadium ↔ Kandidat | Einmalig nach Hunt/Research | `#20 Erreicht - GO Termin aus oder im Briefing` · System-Events `#62 Briefing` / `#63 Rebriefing` |
| **Coaching** | Arkadium ↔ Kandidat | VOR jedem Interview | `#65 Coaching TI` / `#36 Coaching 1st` / `#38 Coaching 2nd` / `#40 Coaching 3rd` |
| **Debriefing (beidseitig)** | Arkadium ↔ Kandidat UND Arkadium ↔ Kunde (2 separate Gespräche) | NACH jedem Interview | `#66 Debriefing TI` / `#37 Debriefing 1st` / `#39 Debriefing 2nd` / `#41 Debriefing 3rd` (entity_relevance=both → pro Set 2 fact_history-Einträge: 1× Kandidat-History + 1× Account-History) |
| **Referenzauskunft** | Arkadium ↔ Referenzperson (ehem. Vorgesetzter) | Im Kunden-Auftrag, vor Placement | `#42 Erreicht - Referenzauskunft` |

**Interview-Durchführung selbst (TI/1st/2nd/3rd/Assessment)** ist **keine** Activity — sie wird als Stage-Daten in `fact_process_interviews.actual_date` gespeichert. Timeline-Einträge dazu sind Stage-Transitions (System-Events), nicht Arkadium-Aktivitäten.

**Nicht verwechseln:** „Briefing" (Kandidat-Eignungsgespräch in Kandidatenmaske Tab 2) ≠ „Coaching" (Interview-Vorbereitung mit Kandidat) ≠ „Stellenbriefing" (Kunde-Seite, über Stelle).

**Interview-Terminierung:** Das Terminieren der Interviews macht der Kunde (nicht ARK). ARK begleitet den Kandidaten durch Coaching (vor Interview) und Debriefing (nach Interview, beidseitig). Für jedes Interview wird ein Reminder mit Datum und Prozess-Verknüpfung erstellt. Der Reminder enthält: Datum/Uhrzeit, Kandidat, Account, Ansprechpartner, Interview-Nummer (TI/1./2./3.). Über die Outlook-Kalender-Integration (CalendarReadWrite Scope) wird automatisch ein Kalendereintrag für den CM erstellt — als **Read-Only-Referenz**, nicht als Teilnahme-Signal.

Automatisch: Placement → Job auf "Filled". Shortlist-Trigger bei Einzelmandaten (siehe 5.3).

Tracking: Jobs ohne ARK-Prozess besetzt = "Extern besetzt". Jobs mit Prozess aber ohne Placement = "Nicht platziert".

### 2.7 Post-Placement

Automatische Reminders: Onboarding Call (Start − 7 Tage), 1-Mt / 2-Mt / 3-Mt-Checks (letzter = Garantiefrist-Ende). Nach 3. Monat keine weiteren Reminders.

Cancellation = Rückzieher nach Placement. 100% Rückvergütung. Rückvergütungsfristen bei regulärem Austritt: Monat 1 → 50%, Monat 2 → 25%, Monat 3 → 10%.

---

## TEIL 3: KANDIDATEN

### 3.1 Profil

Personalien, Kontaktdaten, Standort, Online-Profile, Foto. CRM-Status: Stage, Temperatur (Hot/Warm/Cold), Wechselmotivation (8 Stufen). Zuständigkeit: CM, Hunter, Team, Sparte (ING/GT/ARC/REM/PUR). Flags: Blue Collar, Fachliche Führung, 1./2. Ebene DF, VR/C-Suite, DO-NOT-CONTACT.

### 3.2 Stages

| Stage | Trigger |
|---|---|
| Check | Automatisch bei Erstellung |
| Refresh | Bei Ghosting, NIC, Dropped. Nach 1 Jahr in Datenschutz. War im Austausch mit RA. |
| Premarket | Automatisch wenn Briefing gespeichert |
| Active Sourcing | Automatisch wenn CV + Diplom + Zeugnis + Briefing vorhanden |
| Market Now | Automatisch wenn Prozess erstellt |
| Inactive | Auto: Alter >60 oder Cold >6 Monate. Oder manuell. |
| Blind | Nur manuell. Potenziell interessant in Zukunft. |
| Datenschutz | Löst Anonymisierung aus. Nach 1 Jahr auto → Refresh. Auch manuell rückstellbar. |

Bei NIC, Dropped, Nicht mehr erreichbar: Stage-Update auch in allen aktiven Longlists.

**Datenschutz-Sonderregel:** Im Backend ist Datenschutz als terminaler Status definiert (keine regulären Übergänge erlaubt). Die automatische Rückkehr nach 1 Jahr und die manuelle Rückstellung werden als **Sonder-Automation** implementiert die den Terminal-Status explizit überschreiben darf. Dies wird im Code als dedizierte Funktion mit eigener Berechtigung (system_override) gebaut, nicht über die reguläre Stage-Machine. Audit-Log dokumentiert den Override-Grund.

### 3.3 Wechselmotivation und Temperatur

**Wechselmotivation** (faktische Situation): Arbeitslos, Will/muss wechseln, Will/muss wahrscheinlich wechseln, Wechselt bei gutem Angebot, Spekulativ, Wechselt intern & wartet ab, Will absolut nicht wechseln, Will nicht mit uns zusammenarbeiten.

**Temperatur** (Dringlichkeit aus ARK-Sicht): Hot (jetzt angehen), Warm (beobachten), Cold (nicht priorisiert).

Kombination gibt Information: "Wechselt bei gutem Angebot + Hot" = jetzt vorstellen.

### 3.4 Kompetenzen

Fünf Dimensionen: Cluster/Subcluster (fachliche Kompetenz-Cluster, ca. 15 + 66 Subclusters), Functions (Berufsfunktionen, 190+), Focus (fachliche Skills, 160+ — ersetzt das alte Skill-System), EDV (Software-Kenntnisse, 120+), Sector/Branche. Jede Zuordnung mit Rating 1-10 und Primary-Flag.

### 3.5 Briefing

Unbegrenzt versioniert. 9 Sektionen: Gehalt, Verfügbarkeit, Mobilität, Bewertung (A/B/C), Kompetenzen, Persönlichkeit, Zonen-Modell, Privat, Sonstiges, Projekte (aus Briefing → AI matcht zu Werdegang-Stationen).

### 3.6 Werdegang

Vertikale Timeline: Arbeitsstellen, Ausbildungen, Lücken. Pro Station: Projekte mit Bauherr, Kosten, Team. AI matcht Briefing-Projekte automatisch zu Stationen (KPI-Eskalation bei offenen Empfehlungen).

### 3.7 Assessment

DISC, Motivatoren, EQ, Relief, ASSESS 5.0, Human Needs/BIP, Ikigai. Pro Typ individuell versioniert.

---

## TEIL 4: ACCOUNTS UND KONTAKTE

### 4.1 Accounts

Stammdaten, Klassifikation (Status, Kundenklasse A/B/C, Einkaufspotenzial ★/★★/★★★, No Hunt, Sparte ING/GT/ARC/REM/PUR), Intelligence, Scraping. Nach Scraper-Bestätigung: Auto-Erstellung/Aktualisierung von Kontakten, Vakanzen, Organigramm.

**Einkaufspotenzial:** Neues Feld `purchase_potential` auf dim_accounts mit Werten 1/2/3 (★ = 0-1 Positionen/Jahr, ★★ = 2-3, ★★★ = 3+).

**AGB-Tracking:** Pro Account wird gespeichert ob und wann der Kunde die AGB bestätigt hat (Felder: `agb_confirmed_at`, `agb_version` auf dim_accounts). **Gate-Check bei Erfolgsbasis:** Bevor ein CV/Exposé an einen Kunden ohne bestätigte AGB versendet wird, erscheint eine Warnung: "AGB für diesen Account noch nicht bestätigt. Fortfahren?" Der Versand wird nicht blockiert, aber der CM wird auf das Risiko hingewiesen.

### 4.2 Kontakte

Decision Maker, Key Contact, Champion, Blocker Flags. "Left Company" = ausgegraut, historisch erhalten. Kann gleichzeitig Kandidat sein.

### 4.3 Firmengruppen

Aggregations-Dashboard: Zusammenfassung aller Tochterunternehmen (Mitarbeiter, Mandate, Prozesse, Sparten). Eigene Felder: Gruppen-Manager, Website, LinkedIn. Details in den Accounts.

---

## TEIL 5: JOBS, MANDATE, VAKANZEN

### 5.1 Jobs

Titel, Account, Sparte, Ort, Gehalt (CHF, CHECK min<=max), Pensum. Function/Focus-Verknüpfung (AI-Vorschlag). Status: Open → Filled / On Hold / Cancelled. Auto-Filled bei Placement. Manuell Filled = "Extern besetzt" (getrackt).

### 5.2 Vakanzen

Status: Open → Filled / On Hold / Cancelled / Lost (Lost = extern besetzt, ARK hat verloren).

### 5.3 Mandate

Typen: Einzelmandat, RPO, Time. Status: Entwurf → Aktiv / Abgelehnt. Aktiv → Abgeschlossen / Abgebrochen. Tracking: Offerten-Conversion-Rate (Entwurf → Aktiv vs. Entwurf → Abgelehnt). KPIs: Ident Target/Actual, Call Target/Actual, Shortlist-Trigger (konfigurierbar). RPO: Jede Position = eigener Job.

**Mandats-Aktivierung:** Ein Mandat wird im Status "Entwurf" erstellt. Es wird automatisch auf "Aktiv" gestellt wenn in der Mandats-Detailmaske ein Dokument mit dem Label "Mandatsofferte unterschrieben" hochgeladen wird. Dieser Trigger stellt sicher dass kein Mandat aktiv wird ohne unterzeichneten Vertrag.

**Shortlist-Trigger (Einzelmandat):** Im Mandat wird eine Anzahl "CV Sent" definiert (z.B. 2 oder 3) die die 2. Zahlung auslöst. Wenn diese Anzahl erreicht wird: (a) fact_mandate_billing erstellt automatisch den 2. Zahlungs-Eintrag, (b) Notification an AM: "Shortlist für Mandat X erreicht — 2. Zahlung fällig". Wenn MEHR CVs als konfiguriert versendet werden, fragt das System: "Shortlist-Limit überschritten. Zusatzleistung fällig?" Der AM entscheidet ob eine Zusatzleistung verrechnet wird.

**Zusatzleistungen bei Einzelmandaten:** Der Kunde kann zusätzliche Idents oder Dossiers dazukaufen. Pro Mandat definierbar: Ident-Zusatzpreis (CHF pro zusätzlichem identifiziertem Kandidaten über das Ident-Target hinaus) und Dossier-Zusatzpreis (CHF pro zusätzlich erstelltem Dossier über das Shortlist-Limit hinaus). Diese werden in der Mandats-Übersicht als "Extras" mit Stückzahl und Preis aufgeführt.

---

## TEIL 6: HISTORY UND AUTOMATIONEN

### 6.1 Drei Systeme

fact_history (Mensch), fact_event_queue (System), fact_audit_log (Compliance).

### 6.2 Activity-Types (61+ in 11 Kategorien)

Kontaktberührung (6), Erreicht (15, NIC = Not Interested Currently), Emailverkehr (11), Messaging (3), Interviewprozess (9 — inkl. TI Coaching+Debriefing ergänzt 2026-04-16), Placementprozess (3), Refresh (3), Mandatsakquise (4), Erfolgsbasis (2: AGB Verhandlungen + AGB bestätigt), Assessment (4), System (6). Neue Spalte `entity_relevance` (candidate/account/both) pro Activity-Type — siehe `ARK_STAMMDATEN_EXPORT_v1_3` §14.

### 6.3 Automations-Trigger-Matrix

Briefing → Premarket + Mandate Research briefing. Mündliche GOs → Jobbasket oral_go + Mandate Research go_muendlich. NIC/Dropped → Refresh + Mandate Research rejected/dropped. CV-Upload → Mandate Research cv_in. Placement → Job Filled + Onboarding/Check-in Reminders + Provisions-Berechnung. Datenschutz → Anonymisierung + nach 1 Jahr → Refresh (Sonder-Automation). Cold >6M → Inactive. Template-Email → Auto-Klassifizierung. Shortlist-Trigger → 2. Zahlung fällig + AM-Notification (nur Einzelmandat). CV-Versand an Account ohne bestätigte AGB → Warnung (kein Block). Interview-Termin eingetragen → Kalender-Eintrag + Reminder für CM. Dokument "Mandatsofferte unterschrieben" hochgeladen → Mandats-Status Entwurf → Aktiv.

Alle Automationen greifen übergreifend: Kandidaten-Stage UND alle aktiven Longlists.

### 6.4 Eskalation

Unklassifizierte Einträge: sofort Badge → 24h Reminder → 48h Head_of → wöchentlich KPI.
AI-Empfehlungen: Dashboard-Badge, gleiche Eskalation.
Ghosting: Reminder an CM + KPI-Tracking.
Alle Fristen konfigurierbar in Admin → Automation-Settings.

---

## TEIL 7: EMAIL-SYSTEM

CRM als zentrales Kommunikationstool. 32 Standard-Templates (4 mit Automation-Trigger). Erweiterbar. Unbekannte Emails → Angebot neuen Kandidaten/Account zu erstellen. Drafts im CRM speicherbar.

**Ausfallsicherheit:** Health-Check Worker prüft Token-Status alle 5 Min. Bei Ablauf: Auto-Refresh + Admin-Alert. Bei Fehlschlag: Banner "Email-Sync unterbrochen", Consultants können temporär über Outlook arbeiten, Nachhol-Sync wenn Token wieder gültig.

---

## TEIL 8: TELEFONIE (3CX)

Click-to-Call, auto History-Eintrag, Transkription, AI-Summary, Screen-Pop bei eingehenden Anrufen.

---

## TEIL 9: DOKUMENTE

Typen: Original CV, ARK CV, Exposé, Abstract, Diplom, Arbeitszeugnis, Assessment-Dokument, Vertrag, Mandat-Report. Max 20 MB. Dok-Generator: ARK CV, Abstract, Exposé. Phase 2: Rechnungen, Assessment-Reports, Zeitreports.

**Mandate-Report-Generator:** Für Mandate-Kunden die regelmässige Status-Reports erwarten. Generiert einen professionellen PDF-Report der automatisch Daten aus dem Mandat zusammenstellt: Longlist-Status (wie viele Kandidaten in welchem Stage), Anrufstatistiken (Call-Target vs. Actual), Pipeline-Fortschritt (Prozesse und deren Stages), Timeline (Kickoff → heute). Kann manuell oder periodisch (z.B. wöchentlich) generiert und per Email an den Kunden versendet werden.

---

## TEIL 10: REMINDERS

Auto-generiert: Kandidat ohne Briefing (7d), Onboarding Call (Start−7d), Post-Placement-Checks (1./2./3. Monat), Stale Prozess (>14d), Data Retention Warnung (30d), Ghosting, Datenschutz-Reset, Interview-Termine (verknüpft mit Prozess, erstellt Outlook-Kalendereintrag für CM), Interview-Datum fehlt (wenn Prozess-Stage auf Interview wechselt aber kein Datum eingetragen wird, Default 2 Tage nach Stage-Wechsel).

---

## TEIL 11: SCRAPER + MARKET INTELLIGENCE

Monitoring Websites/LinkedIn. Approve/Reject. Nach Bestätigung: Auto-Erstellung Kontakte, Vakanzen, Organigramm-Updates.

---

## TEIL 12: AI

Schreibt nie direkt. Vorschlag → Mensch bestätigt. AI-Bestätigungsrate als KPI. Matching zieht aus gesamtem Kandidatenprofil (Stammdaten, Werdegang, Briefing, Assessment, Dokumente, History).

**Assessment-Import:** Scheelen-Assessment-Ergebnisse werden per CSV-Datei importiert. Workflow: (1) Backoffice lädt CSV hoch, (2) System führt Dry-Run durch (Vorschau was importiert wird, welche Kandidaten zugeordnet werden), (3) Backoffice bestätigt, (4) Daten werden in die Assessment-Tabellen geschrieben, (5) Automatischer History-Eintrag "Assessment - Ergebnisse erfasst". Endpunkt: POST /api/v1/assessments/import-scheelen mit Dry-Run-Modus.

**Provisionsabrechnung:** Bei jedem Placement wird die Provision automatisch berechnet basierend auf: Kandidaten-Gehalt (salary_candidate_target), Honorarsatz (aus Mandat-Konditionen oder Best-Effort-Staffel), Kommissionssätze (commission_cm_pct, commission_am_pct, commission_hunter_pct aus dim_mitarbeiter). Bei Split-Mandaten (CM ≠ AM ≠ Hunter) wird die Provision pro Rolle aufgeteilt. Pro Mitarbeiter gibt es eine Provisionsübersicht mit: offene Provisionen (Placement erfolgt, noch nicht ausgezahlt), ausgezahlte Provisionen, Gesamt pro Periode. Phase 1: Berechnung und Übersicht. Phase 2: Integration mit Payroll/Lohnlauf.

**Account-Duplikat-Erkennung:** Analog zur Kandidaten-Duplikat-Erkennung (v_candidate_duplicates) wird eine Account-Duplikat-Erkennung implementiert: Fuzzy-Matching auf Firmennamen (z.B. "Brun AG" vs. "Brun Bauunternehmung AG"), Matching auf domain_normalized (gleiche Website = wahrscheinlich gleicher Account), Matching auf Handelsregister-UID. Besonders relevant wenn der Scraper neue Accounts erstellt. Duplikat-Kandidaten erscheinen als Merge-Vorschlag im Admin-Bereich.

**Outlook-Integration Ausfallsicherheit:** Da das CRM das zentrale Kommunikationstool ist, wird die Outlook-Integration zum kritischen Pfad. Schutzmassnahmen: (1) Health-Check Worker der alle 5 Minuten den Token-Status prüft, (2) Bei ablaufendem Token (< 24h): Automatischer Refresh-Versuch + Alert an Admin, (3) Bei fehlgeschlagenem Refresh: Sofortige Notification an Admin + Banner im CRM "Email-Sync unterbrochen", (4) Consultants können in diesem Fall temporär über Outlook arbeiten — eingehende Mails werden nachsynchronisiert sobald der Token wieder gültig ist.

---

## TEIL 12b: DEBUGGABILITY — "WARUM IST DAS PASSIERT?"

Eines der grössten Risiken bei einem Event-getriebenen System ist dass niemand mehr nachvollziehen kann warum etwas passiert ist. Wenn ein Kandidaten-Stage sich automatisch ändert oder ein Prozess erstellt wird, muss der Consultant (und der Admin) jederzeit sehen können: Was war der Auslöser? Welche Events haben sich verkettet?

**Event-Timeline pro Entity:** Jede Hauptentität (Kandidat, Account, Job, Mandat, Prozess) hat eine "Was ist passiert?"-Ansicht die drei Quellen zusammenführt:

1. **fact_history** — Was hat ein Mensch getan? (Anrufe, Emails, Meetings)
2. **fact_event_queue** — Was hat das System ausgelöst? (Stage-Changes, Automationen)
3. **fact_audit_log** — Was wurde konkret geändert? (Feld-Level Änderungen)

Die Ansicht zeigt eine chronologische Timeline mit:
- Wer/Was hat den Eintrag ausgelöst (Mensch/System/Automation)
- Was war der Trigger (z.B. "Email-Template Mündliche GOs versendet → Jobbasket oral_go → Mandate Research go_muendlich")
- Welche Felder wurden geändert (alter Wert → neuer Wert)
- correlation_id zum Nachverfolgen von Event-Ketten

**Im Frontend:** Eigener Tab oder Drawer pro Entity mit der kombinierten Timeline. Filter nach Quelle (History/Events/Audit). Besonders für Admins und Head_ofs wichtig bei Eskalationen.

**Im Backend:** Endpoint `GET /api/v1/entities/:type/:id/event-chain` der alle drei Quellen zusammenführt und chronologisch sortiert zurückgibt.

---

## TEIL 12c: PHASEN-KLARHEIT

Das System ist bewusst ambitioniert. Um die Komplexität zu kontrollieren, gilt eine strikte Phasen-Trennung:

**Phase 1 — MUSS funktionieren (Launch-Blocker):**
Kandidaten (10 Tabs), Accounts (10 Tabs), Jobs, Mandate, Prozesse, Jobbasket mit GO-Flow, History mit Activity-Types, Reminders, Dokumente mit Upload/Download, Basic Dashboard mit KPIs, Dark + Light Mode, Vollseiten-Navigation, Suche (Command Palette), Benachrichtigungen.

**Phase 1.5 — Kurz nach Launch (erste 4 Wochen):**
AI Activity-Type Vorschläge, AI Transkript-Zusammenfassungen, Email-Composer im CRM (MS Graph Send), Email-Inbox (MS Graph Sync), 3CX Click-to-Call + Screen-Pop, Assessment CSV-Import, Stale-Prozess-Erkennung, Post-Placement Reminder-Kette, Account-Duplikat-Erkennung.

**Phase 2 — Mittelfristig (3-6 Monate nach Launch):**
RAG/Semantische Suche, AI Matching (Kandidat ↔ Job), WYSIWYG Dokumenten-Generator, Assessment-Charts (D3/Recharts), Kanban Drag & Drop, Teamrad-Visualisierung, Organigramm-Baumstruktur, Standorte-Karte, LinkedIn Social Tracking, Mandate-Report-Generator.

**Phase 3 — ERP (eigenes Produkt):**
Zeiterfassung, Buchhaltung (Periodenabschluss-Lock ZUERST), Payroll/Provisionsauszahlung, Performance/HR, Messaging (WhatsApp/LinkedIn), Publishing (Multi-Channel Stellenausschreibung).

**Prinzip: Complexity Budget.** Vor jedem Feature die Frage: "Macht das den Consultant messbar schneller?" Wenn nein → Phase 2 oder später.

---

## TEIL 13: STAMMDATEN

Kompetenz: dim_cluster (fachlich, mit Subclustern), dim_functions (190+), dim_focus (160+, = Skills), dim_edv (120+), dim_education (Grad + konkrete Ausbildung), dim_sector, dim_sparte (ING/GT/ARC/REM/PUR), dim_languages.

Aktivität: dim_activity_types (61+, 11 Kategorien), dim_event_types, dim_process_stages, dim_rejection_reasons_candidate/client, dim_dropped_reasons, dim_cancellation_reasons (Rückzieher nach Placement), dim_offer_refused_reasons, dim_jobbasket_rejection_types (candidate/cm/am).

Templates: dim_email_templates (32, erweiterbar), dim_prompt_templates, dim_notification_templates.

Konfiguration: dim_honorar_settings, dim_automation_settings (alle Fristen), dim_tenant_features, dim_ai_write_policies.

DEPRECATED: dim_skills_master + 9 zugehörige Tabellen (ersetzt durch dim_focus).

Views: v_candidate_duplicates (Kandidaten-Duplikat-Erkennung), v_account_duplicates (Account-Duplikat-Erkennung via Fuzzy-Matching Firmennamen, domain_normalized, Handelsregister-UID).

---

## TEIL 14–17: SCHEMA-ÄNDERUNGEN v1.1 → v1.2

Neues Feld wechselmotivation auf Kandidaten (8 Stufen). Neues Feld purchase_potential auf Accounts (1/2/3 Sterne). Neue Felder agb_confirmed_at + agb_version auf Accounts. Jobbasket: Prelead-Stage + differenzierte Rejection (candidate/cm/am). Activity-Types: 11 Kategorien. fact_history: Text-Feld entfernt, categorization_status um "pending" erweitert. Email-Templates erweitert (template_key, linked_activity_type, linked_automation_key). UNIQUE auf idempotency_key. Jobs: salary CHECK. Prozess-Status: Open, On Hold, Rejected, Placed, Stale, Closed, Cancelled, Dropped. Mandats-Status: Entwurf → Aktiv / Abgelehnt → Abgeschlossen / Abgebrochen. Neuer Status "Abgelehnt" für Mandate die nicht zustande kommen (KPI: Offerten-Conversion-Rate). Aktivierung via Dokument-Upload "Mandatsofferte unterschrieben". Datenschutz-Stage: Sonder-Automation für 1-Jahr-Reset die Terminal-Status überschreiben darf. Mandate: Zusatzleistungen-Felder (ident_extra_price, dossier_extra_price, ident_extra_qty, dossier_extra_qty). 5 neue Tabellen (dim_tenant_features, fact_email_drafts, dim_automation_settings, dim_jobbasket_rejection_types, v_account_duplicates als View). 12 neue Events (inkl. mandate.activated). 6 Indizes. Skills deprecated. Assessment-Import-Endpunkt. Provisionsübersicht-Endpunkt pro Mitarbeiter. Outlook Health-Check Worker. Power BI Read-Only-Datenbankrolle für Reporting.

---

## TEIL 18: PHASE 2

Zeiterfassung, Billing/Buchhaltung (Periodenabschluss-Lock zuerst!), Performance/HR, Messaging, Publishing, Payroll.

---

## TEIL 19: TECHNISCHE ARCHITEKTUR

Backend: Node.js/Fastify/Railway. Frontend: Next.js/React/Vercel. Dark Default + Light Mode user-umschaltbar (ARK CI #262626/#dcb479/#196774). Detailansichten als Vollseiten. Event-Driven. AI schreibt nie direkt. Tenant-Isolation.

**Berechtigungsmatrix (Rolle × Modul × Aktion):** Definiert welche Rolle welche Daten sehen und welche Aktionen ausführen darf. Beispiele: RA sieht keine Gehaltsdaten, Backoffice kann keine Kandidaten-Stages ändern, CM sieht auf dem Dashboard nur "seine" Kandidaten aber alle in der Suche. Die vollständige Matrix wird im ARK_FRONTEND_FREEZE (UI-Sichtbarkeit pro Rolle) und ARK_BACKEND_ARCHITECTURE (Endpoint-Berechtigungen pro Rolle) definiert.

**Power BI / Reporting:** Nenad (Admin) verbindet Power BI direkt auf die Supabase-Datenbank über eine Read-Only-Rolle. Dashboards (Placement-Rate, Revenue pro Sparte, Pipeline-Velocity, Consultant-Performance etc.) werden in Production manuell erstellt und angepasst — keine Vordefinition im CRM nötig. Das DB-Schema (ARK_DATABASE_SCHEMA) muss sicherstellen dass die nötigen Views und Indizes für typische Reporting-Queries performant sind.

---

## TEIL 20: NACHTRAG v1.3.1 (2026-04-14) — Account-UI Konsolidierung & Theme-Preference

- **Snapshot-Bar (alle Detailseiten):** Slots 5+6 umkonfiguriert auf reine Firmografik (Gegründet, Standorte) statt Arkadium-Beziehung
- **Account Tab 1:** Neue Arkadium-Relation-KPI-Bar (Umsatz Arkadium YTD, Placements total, Ø Time-to-Hire, Conversion CV→Placement) — ergänzend zu den 10 Stammdaten-Sektionen
- **Kontakt-Drawer:** 4-Tab-Struktur (Stammdaten / Kommunikation / Prozesse / Notizen). Kommunikations-Tab zeigt Interaktionen **dieses Kontakts** mit diesem Account (nicht Account-weit)
- **Theme-Preference:** Dark Default + Light Mode user-umschaltbar (`dim_crm_users.theme_preference`)
- **Stammdaten-Ergänzungen:** Owner-Teams (ARC & REM / ING & BT), `dim_dossier_preferences`
- Details: `ARK_ACCOUNT_DETAILMASKE_INTERACTIONS_v0_3.md` TEIL 1+2+4

---

## TEIL 20c: NACHTRAG v1.3.3 (2026-04-16) — Projekt-Detailmaske vollständig ausgebaut

Projekt-Detailmaske `/projects/[id]` von Skelett-Zustand auf Phase-A–I-komplett gebracht. Vorher: 676 Zeilen mit Tab-1-only-Inhalt und kopierten Commercial-Dokumenten. Jetzt: 2395 Zeilen mit vollem 6-Tab-Ausbau.

**Tab-für-Tab-Ausbau:**
1. **Tab 1 Übersicht** harmonisiert mit Öffentlich/Intern-Divider + `accountNoteDrawer` für AM-Notizen pro Account (Bridge `fact_account_project_notes`)
2. **Tab 2 Gewerke** als 3-Tier-Akkordeon: Projekt → Gewerk → Beteiligungen. Inline-Kommentar-Edit, Sub-Tabellen für Firmen + Kandidaten, 4 Drawers (`newGewerkDrawer`, `gewerkSettingsDrawer`, `firmaParticipationDrawer` wide/3tabs, `kandidatParticipationDrawer` wide/4tabs)
3. **Tab 3 Matching** mit 2 Sub-Sections: (A) Passende Kandidaten mit 6 Score-Dimensionen · (B) Ähnliche Projekte via Jaccard + Vol + Geo. `pitchDrawer` für AI-Match-Begründung
4. **Tab 4 Galerie** als Masonry-Grid mit 5 Medien-Typen + Lightbox (keyboard ←→ Esc). CSS-Gradient-Tiles typ-spezifisch (Foto/Render/Plan/Baustelle/After-Move-In) statt Emoji-Platzhalter
5. **Tab 5 Dokumente** mit neuem **Profile „Projekt"** (6 Kategorien: projekt-beschreibung · pressemeldungen · baublatt-simap · pitch-unterlagen · referenz-schreiben · sonstiges)
6. **Tab 6 History** mit 13 Projekt-Lifecycle-Events laut Spec §10

**Header-Specials:**
- Scraper-Source-Banner (conditional für `source='scraper'`, mit Demo-Toggle)
- Status-Dropdown 6 Werte (planung · ausschreibung · ausfuehrung · abgenommen · abgeschlossen · gestoppt)
- Snapshot-Bar 6 Slots **projekttyp-agnostisch**: 💰 Volumen · 📅 Zeitraum · 🏗 BKP-Gewerke · 🏢 Firmen · 👥 Kandidaten · 📸 Medien. Funktioniert übergreifend für Hochbau/Tiefbau/Infrastruktur — BGF/Einheiten bewusst nicht im Snapshot (wären Hochbau-spezifisch)
- Quick-Actions: ➕ Beteiligung · + BKP-Gewerk · 📄 Projekt-Report · 🔁 Matching · 🔔 Reminder

**Drawer-Inventar (14):** newGewerkDrawer · gewerkSettingsDrawer · firmaParticipationDrawer · kandidatParticipationDrawer · mediaUploadDrawer · mediaEditDrawer · uploadDrawer · pitchDrawer · projektReportDrawer · addBeteiligungDrawer · accountNoteDrawer · mergeDrawer (3-Tab Duplicate-Merge) · reminderDrawer · drawerBackdrop.

**Sync-Scope:**
- `wiki/entities/projekt.md` **NEU** erstellt (analog `job.md`)
- `wiki/concepts/dokumente-kategorien.md` §5 Projekt-Profile ergänzt (Titel auf 5 Profile)
- `wiki/concepts/design-system.md` §3.2b Projekt-Slot-Zeile ergänzt
- `specs/ARK_PROJEKT_DETAILMASKE_SCHEMA_v0_2.md` §4.4 canonical + dupe-Regel
- `ARK_FRONTEND_FREEZE_v1_10.md` §6 Slot-Allokations-Tabelle + Projekt-Header-Zeile
- Nicht betroffen: STAMMDATEN (keine neuen Enums), DATABASE_SCHEMA (keine Schema-Änderung), BACKEND_ARCHITECTURE (kein Endpunkt)

Damit sind alle 6 aktiven Detailmasken (accounts · candidates · mandates · groups · jobs · **projects**) design-system-konform und Feature-äquivalent auf Header/Snapshot/Tabbar-Pattern. Projekte bringt die komplexeste 3-Tier-Struktur, die es in keinem anderen Mockup gibt.

---

## TEIL 20b: NACHTRAG v1.3.2 (2026-04-16) — Snapshot-Bar-Harmonisierung alle 5 Detailmasken

Bei Audit der 5 Detailmasken (Account, Kandidat, Mandat, Firmengruppe, Job) wurden Inkonsistenzen in der Snapshot-Bar identifiziert:
- **Mandates** nutzte custom `.mandat-snapshot` Klasse statt `.snapshot-bar` (7 Slots)
- **Candidates** hatte gar keine Snapshot-Bar
- **Groups** stapelte Snapshot unter Tabbar (spiegelverkehrt zu Jobs)
- **Accounts** Snapshot war nicht sticky
- **Jobs** hatte 3 Dupes zum Header (Status/Mandat/Offen-seit)

**Harmonisierung (2026-04-16):**

1. **Strukturell:** Alle 5 Masken nutzen jetzt `.snapshot-bar` + `.snapshot-item` (lbl/val/delta) aus `editorial.css`. Custom `.mandat-snapshot` bleibt als Progress-Bar-Helper, aber Outer-Container ist uniform.

2. **Stacking:** Snapshot-Bar steht **ÜBER** Tabbar (`top:0, z-index:50`), Tabbar darunter (`top:64px/72px, z-index:49`) — Logik „Identität vor Navigation".

3. **Slot-Belegung (dupe-frei zum Header):**
   - Account: Mitarbeitende · Wachstum 3J · Umsatz 2025 · Gegründet · Standorte · Kulturfit
   - Kandidat: Ø Match-Score · Im Jobbasket · Aktive Prozesse · Refresh-Due · Placements hist. · Assessments
   - Mandat: Idents · Calls · Shortlist · Pauschale · Time-to-Fill · Placements (3 Slots mit Progress-Bars)
   - Firmengruppe: Gesellschaften · Mitarbeitende · Umsatz · Aktive Prozesse · Placements YTD · Arkadium-Umsatz YTD
   - Job: Matches ≥ 70 % · Im Jobbasket · Aktive Prozesse · Standort · TC-Range · Ø Match-Score

4. **Dupe-Regel (CRITICAL):** Snapshot-Slots dürfen nicht Header-Info duplizieren (Status, Mandat-Badge, Offen-seit etc.). Trennschärfe: Header = Identität/Klassifizierung, Snapshot = operative Zahlen.

5. **Ausnahmen (bleiben 7 Slots):** Assessment (Credits-Mix), Scraper (Live-KPIs), Projekt (Zeitraum).

**Sync-Scope:**
- `ARK_FRONTEND_FREEZE_v1_10` §6 Snapshot-Konvention + per-Entity-Header-Zeilen aktualisiert
- `ARK_STAMMDATEN_EXPORT_v1_3`: nicht betroffen (keine neuen Enums)
- `ARK_DATABASE_SCHEMA_v1_3`: nicht betroffen (keine Schema-Änderung)
- `ARK_BACKEND_ARCHITECTURE_v2_5`: nicht betroffen (kein Endpunkt)

Details: `wiki/concepts/design-system.md` §3.2b · Mockups: `mockups/{accounts,candidates,mandates,groups,jobs}.html`.

---

## TEIL 21: SPEC-SYNC-REGEL (2026-04-14)

**Grundsatz:** Änderungen an einer der 5 Grundlagendateien *UND* den Detailmasken-Specs müssen **immer bidirektional** synchronisiert werden.

**5 Grundlagendateien (immer aktuell halten):**
1. `ARK_STAMMDATEN_EXPORT_v1_x.md` — Stammdaten / Enums / dim_*-Tabellen
2. `ARK_DATABASE_SCHEMA_v1_x.md` — Tabellen, Spalten, Constraints, Views
3. `ARK_BACKEND_ARCHITECTURE_v2_x.md` — Endpunkte, Events, Worker, Sagas
4. `ARK_FRONTEND_FREEZE_v1_x.md` — UI-Patterns, Design-System, Routing
5. `ARK_GESAMTSYSTEM_UEBERSICHT_v1_x.md` — Gesamtbild, Entscheidungen

**Detailmasken-Specs (9 aktive, je Schema + Interactions):**
Kandidat · Account · Firmengruppe · Mandat · Job · Prozess · Assessment · Scraper · Projekt

**Bei JEDER Änderung gilt:**

| Änderungstyp in Detail-Spec | Trigger-Update in Grundlagendatei |
|---|---|
| Neues Feld in UI | DB-Schema (neue Spalte/CHECK) + Backend (ggf. Endpunkt) |
| Neue ENUM-Werte | Stammdaten (dim_*-Tabelle) + DB-Schema (CHECK) |
| Neuer Event | Backend-Architecture (Event-Katalog) |
| Neuer Worker | Backend-Architecture (§B Worker) |
| Neue Route | Backend-Architecture (§C Endpunkte) + Frontend-Freeze (Routing) |
| UI-Pattern-Änderung (Drawer, Tab-Struktur) | Frontend-Freeze + Gesamtsystem Changelog |
| Neue Rolle / RBAC-Regel | Frontend-Freeze + Backend-Architecture + wiki/meta/rbac-matrix.md |
| Architektur-Entscheidung | Gesamtsystem Changelog + betroffene Grundlagendatei |

**Und umgekehrt:** Änderungen in Grundlagendateien → alle betroffenen Detail-Specs prüfen und aktualisieren.

**Verantwortlich:** Wer auch immer Änderungen einpflegt, muss den Sync-Lauf ebenfalls ausführen. Bei Unsicherheit: Audit-Durchlauf aller 5 Grundlagen + alle 9 Detail-Specs (vgl. `wiki/analyses/audit-final-*.md`).

**Governance:** Bei PR-Freigabe muss explizit bestätigt werden: "Grundlagendateien synchron mit Spec-Änderungen? ✓/✗".

---

## TEIL 24: NACHTRAG v1.3.6 · Mobile/Tablet-Support (2026-04-17)

**Grundlegende Umstellung:** Frontend-Freeze-Regel „Tablet Read-Only + Mobile Blocker" **ersetzt** durch vollen Mobile-/Tablet-Support. Desktop bleibt Power-User-Mode, Mobile + Tablet sind vollwertig funktional.

### 24.1 Scope der Umstellung

- `mockups/crm.html` — App-Shell responsive (Top-Bar + Slide-Out-Sidebar auf Mobile, Pin-Toggle auf Tablet)
- `mockups/crm-mobile.html` (neu) — 3-Device-Frames-Demo (iPhone 375×740 · iPad 820×620 · Desktop 1100×680) mit iframe-Embed der echten App
- `mockups/_shared/editorial.css` — globale Mobile-Rules (KPI 2-col, DataTable→Card-Stack, Filter-Bar-scroll, Drawer→Full-Screen-Sheet, Tabs-scroll, Snapshot-Bar-stack)
- Pro-Mockup-Fixes: Dashboard, Reminders (Kalender horizontal scroll), Email-Kalender (3-Pane → Pane-Toggle), Dok-Generator (Sidebar → Drawer), Processes (Pipeline-Popover full-width)
- Viewport-Meta in **allen 22 Mockup-HTMLs**

### 24.2 Breakpoints (kanonisch)

| Scope | Definition |
|-------|------------|
| Desktop | `> 960 px` — primärer Power-User-Mode, Sidebar-Hover-Expand, Keyboard-Shortcuts sichtbar |
| Tablet | `641–960 px` — Sidebar collapsed + Pin-Toggle, Hover aus (Touch) |
| Mobile | `≤ 640 px` — Top-Bar 52 px + Slide-Out-Drawer, Card-Stack, Full-Screen-Sheets |

### 24.3 Änderungen in Grundlagen

| Datei | Änderung |
|-------|----------|
| `ARK_FRONTEND_FREEZE_v1_10.md` v1.10.5 → **v1.11** | §24b Responsive Policy komplett rewrite (alte Blocker-Regel raus, volle Mobile-/Tablet-Support), Prinzip 6 umformuliert („Desktop-First App mit vollem Mobile-/Tablet-Support") |
| `ARK_DATABASE_SCHEMA_v1_3.md` | unverändert |
| `ARK_BACKEND_ARCHITECTURE_v2_5.md` | unverändert (kein neuer Endpoint / Event) |
| `ARK_STAMMDATEN_EXPORT_v1_3.md` | unverändert |
| `ARK_GESAMTSYSTEM_UEBERSICHT_v1_3.md` v1.3.5 → **v1.3.6** | Dieser Eintrag (TEIL 24) |

### 24.4 Offene Phase-3-Items (Technical-Debt)

- **Touch-Gesten:** Swipe-to-Complete auf Reminder-Rows, Swipe-Back in Email-Panes
- **Accessibility-Audit:** ARIA-Labels, Focus-Management in Slide-Out-Drawers, Screen-Reader-Tests
- **Performance:** TanStack-Virtual-Config für Mobile-Scroll, Image-Lazy-Loading
- **Entity-Detailmasken Deep-Tests:** Complex Sub-Content (Projekt-Gewerke-3-Tier, Mandat-Konditionen, Kandidat-Assessment-6-Sub-Tabs) in echtem Mobile-Viewport verifizieren

### 24.5 Test-Tool

`mockups/crm-mobile.html` öffnen → 4 Tabs: „Alle 3 Viewports" (Default side-by-side) / Mobile / Tablet / Desktop. Sub-Page-Wähler wechselt in allen iframes simultan. Jeder iframe lädt echte `crm.html` mit seiner Viewport-Breite — Breakpoints greifen live.

---

## TEIL 23: NACHTRAG v1.3.5 (2026-04-17) — Reminders-Vollansicht

**Ergänzung:** Dedizierte Reminders-Tool-Maske unter `/reminders` als 3. Tool-Maske (neben `/operations/dok-generator` und `/operations/email-kalender`). Ergänzt — ersetzt **nicht** — das Dashboard-Reminders-Widget und die Entity-Reminder-Tabs (Kandidat §10 / Account §13).

### 23.1 Zielbild

Cross-entity, user-/teamzentrierte Oberfläche für alle Reminders mit:
- **Zwei View-Modi:** Liste (Section-Groups Überfällig/Heute/Woche/Später/Erledigt) + Kalender (Monat/Woche, CRM-intern, kein Outlook-Sync)
- **Scope-Switcher** (Admin/HoD sichtbar): self · team · all (team über `dim_mitarbeiter.vorgesetzter_id`)
- **Saved Views** rollen-spezifisch (Storage: `dim_mitarbeiter.dashboard_config.reminders.saved_views[]`, max 10 user-defined)
- **Drag-to-Reschedule** im Kalender-View
- **Auto-Regeln-Admin:** **separat** unter `/admin/reminder-rules` (nicht Teil dieser Maske, PO-Entscheidung)
- **Keine Bulk-Actions** (PO-Entscheidung — Sales-Team würde unüberprüft durch-snoozen)

### 23.2 Änderungen in Grundlagen

| Datei | Ergänzung |
|-------|-----------|
| `ARK_DATABASE_SCHEMA_v1_3.md` | `fact_reminders.template_id uuid REFERENCES dim_reminder_templates(id)` + `escalation_sent_at timestamptz` (Idempotenz für 48-h-Eskalation). `dim_mitarbeiter.dashboard_config`-Kommentar mit JSONB-Substruktur für Reminders-Saved-Views. |
| `ARK_BACKEND_ARCHITECTURE_v2_5.md` | v2.5.5: 2 neue Events (`reminder_reassigned`, `reminder_overdue_escalation`), 1 neuer Worker (`reminder-overdue-escalation.worker.ts`, hourly 08–20h), 1 neuer REST-Endpoint `POST /api/v1/reminders/:id/reassign`, 2 neue User-Preferences-Endpoints (`GET/PATCH /api/v1/user-preferences/reminders`). Lifecycle-Events (created/completed/snoozed/updated) werden **nicht** dediziert — via `fact_audit_log` `entity_updated`. |
| `ARK_FRONTEND_FREEZE_v1_10.md` | §Reminders erweitert: Tool-Maske-Einordnung, Scope-Switcher, View-Modi, Saved-Views-Storage, neue Endpoints, Entity-Tab-Deep-Link-Kontrakt, Keyboard-Shortcuts. |
| `ARK_STAMMDATEN_EXPORT_v1_3.md` | unverändert (§64 `dim_reminder_templates` bereits 10 Vorlagen, passt 1:1). |
| `ARK_GESAMTSYSTEM_UEBERSICHT_v1_3.md` | Dieser Eintrag (TEIL 23). |

### 23.3 Neue Spec-Dokumente

- `specs/ARK_REMINDERS_VOLLANSICHT_PLAN_v0_1.md` — Ausarbeitungsplan mit Phase 0 Entscheidungen
- `specs/ARK_REMINDERS_VOLLANSICHT_SCHEMA_v0_1.md` — Layout, Tokens, Permissions, Empty-States (16 §)
- `specs/ARK_REMINDERS_VOLLANSICHT_INTERACTIONS_v0_1.md` — Flows, Events, Permissions-Matrix, Keyboard (14 §)

### 23.4 Neuer Mockup

- `mockups/reminders.html` — Liste + Kalender (Monat + Woche), 2 Drawer (Detail mit 5 Sub-Tabs, Neu), Drag-to-Reschedule live, Keyboard-Shortcuts (N/V/E/S).

### 23.5 Wiki-Updates (Phase 4 — noch offen bei diesem Nachtrag)

- `wiki/concepts/reminders.md` — Vollansicht-Section ergänzen
- `wiki/meta/detailseiten-inventar.md` — Tool-Masken 2 → 3
- `wiki/meta/spec-sync-regel.md` — „2 Tool-Masken" → „3 Tool-Masken"
- `wiki/meta/mockup-baseline.md` §16.12 — Reminder-Typ-Labels
- `index.md` + `log.md` — neue Einträge

### 23.6 Spec-Sync-Status

| Datei | Vorher | Nachher | Änderung |
|-------|--------|---------|----------|
| `ARK_DATABASE_SCHEMA_v1_3.md` | v1.3.4 | v1.3.5 | `fact_reminders` 2 neue Spalten + `dim_mitarbeiter.dashboard_config`-Doku |
| `ARK_BACKEND_ARCHITECTURE_v2_5.md` | v2.5.4 | v2.5.5 | 2 Events + 1 Worker + 3 Endpoints |
| `ARK_FRONTEND_FREEZE_v1_10.md` | v1.10.4 | v1.10.5 | §Reminders erweitert |
| `ARK_GESAMTSYSTEM_UEBERSICHT_v1_3.md` | v1.3.4 | v1.3.5 | Dieser Eintrag |
| `specs/ARK_REMINDERS_VOLLANSICHT_PLAN_v0_1.md` | — | **v0.1 (neu)** | Ausarbeitungsplan |
| `specs/ARK_REMINDERS_VOLLANSICHT_SCHEMA_v0_1.md` | — | **v0.1 (neu)** | Schema |
| `specs/ARK_REMINDERS_VOLLANSICHT_INTERACTIONS_v0_1.md` | — | **v0.1 (neu)** | Interactions |
| `mockups/reminders.html` | — | **neu** | Mockup Liste + Kalender |

---

# TEIL 24 — v1.4 E-Learning-Modul (2026-04-24)

**Quellen:**
- `specs/ARK_GESAMTSYSTEM_PATCH_ELEARNING_v0_1.md` (Sub A)
- `specs/ARK_GESAMTSYSTEM_PATCH_ELEARNING_SUB_B_v0_1.md`
- `specs/ARK_GESAMTSYSTEM_PATCH_ELEARNING_SUB_C_v0_1.md`
- `specs/ARK_GESAMTSYSTEM_PATCH_ELEARNING_SUB_D_v0_1.md`

## 24.1 Modul-Landkarte (final)

```
Phase 1 · CRM-Core (9 Detailmasken)                   ← produktiv
Phase 2 · ERP-Light                                    ← laufend
  ├── HR-Tool
  ├── Zeiterfassung (v1.4)
  ├── Commission-Engine (Option D 2026-04-19)
Phase 3 · ERP-Vollausbau                               ← aktuell
  ├── Billing-Modul (v0.1 2026-04-22)
  ├── E-Learning                                       ← NEU v1.4
  │   ├── Sub A: Kurs-Katalog         (Specs v0.1 · 20 Patches eingearbeitet v1.4)
  │   ├── Sub B: Content-Generator    (Specs v0.1 · 20 Patches eingearbeitet v1.4)
  │   ├── Sub C: Wochen-Newsletter    (Specs v0.1 · 20 Patches eingearbeitet v1.4)
  │   └── Sub D: Progress-Gate        (Specs v0.1 · 20 Patches eingearbeitet v1.4)
  └── Doc-Generator                   (Mockup v1.3.4)
Phase 4 · Automatisierung + AI
Phase 5 · Enforcement + Gamification
```

**Status:** alle 4 Subs (A/B/C/D) specct und in Grundlagen (v1.5 Stammdaten + v1.5 DB + v2.7 Backend + v1.12 Frontend) eingearbeitet. Implementation-Plan-Start nach diesem Merge.

## 24.2 E-Learning Kern-Idee (cross-Sub)

**Arkadium-internes Lernsystem mit 4 Bausteinen:**

- **Sub A Kurs-Katalog:** MA bearbeiten Pflicht-Kurse + Refresher (mit Zertifikaten + Badges), Head reviewt Freitext-Antworten (LLM-gescort), Admin verwaltet Kurse/Curriculum-Templates, Import via Git-Webhook aus Content-Repo
- **Sub B Content-Generator:** LLM-basierte Pipeline R1-R5 aus PDF/DOCX/Bücher/Web-Scrapes/CRM-Queries → Entwurfs-Artefakte → Admin-Review → Publish ins Content-Repo (Loop zu Sub A). Port aus `C:\Linkedin_Automatisierung`
- **Sub C Wochen-Newsletter:** wöchentlicher Newsletter pro Sparte mit Sections aus Sub B + Pflicht-Quiz am Ende (attempt_kind='newsletter'), Soft/Hard-Enforcement
- **Sub D Progress-Gate:** Feature-granulare Rules + Override-System + Compliance-Dashboards · schützt CRM-Features bei Nicht-Bearbeitung von E-Learning-Pflichten

## 24.3 Workspace-Struktur (neu)

**Topbar-Toggle CRM ↔ ERP** (global, links von Avatar):
- CRM-Modus: Sidebar zeigt CRM-Module (Kandidaten, Accounts, Mandate, Jobs, Prozesse, Assessments, Aktivitäten, Admin)
- ERP-Modus: Sidebar zeigt ERP-Module (E-Learning, HR, Zeiterfassung, Commission, Billing, Doc-Generator)
- Persistenz pro User in `localStorage`

**Gemeinsame Infrastruktur beider Workspaces:**
- Authentifizierung (JWT, SSO)
- User-Base (`dim_user`)
- Event-Pipeline (`fact_event_queue`, `fact_history`, Event-Processor)
- Notification-System
- Audit-Logging
- Design-System (Tokens, Components, Drawer-Pattern)

**Getrennt:**
- DB-Namespaces (CRM: Recruiting-Domain, ERP: modulspezifisch `dim_elearn_*`, `dim_hr_*`, `dim_zeit_*`)
- URL-Routing (`/crm/*` vs. `/erp/<modul>/*`)
- Sidebar-Items

## 24.4 Multi-Tenant-Aspekt (neu)

E-Learning ist das **erste ARK-Modul mit konsequenter Multi-Tenant-Architektur**:
- Alle 28 neuen Tabellen tragen `tenant_id UUID NOT NULL`
- RLS-Policies auf allen Tabellen (`tenant_id = app.current_tenant_id`)
- Von Tag 1 an designt (nicht später nachgerüstet)

**Begründung:** White-Label-Option für externe Recruiting-Boutiquen. Schema-Vorbereitung jetzt ist günstiger als spätere Migration.

**Konsequenz für künftige ERP-Module:** Multi-Tenant-Pattern übernehmen (Pattern-Dokumentation aus Sub-A-Backend-Patch §4).

## 24.5 Datenflüsse

### 24.5.1 Eingehende Events (E-Learning reagiert auf CRM-Events)

| Event | E-Learning-Reaktion |
|---|---|
| `user_created` | Sub A: `elearn-onboarding-initializer` erzeugt Curriculum; Sub C: `elearn-newsletter-subscription-initializer` |
| `user_role_changed` | Sub A: `elearn-role-change-watcher` erzeugt Diff-Assignments; Sub C: Subscription-Syncer |
| `user_sparte_changed` | dito |

### 24.5.2 Ausgehende Events (E-Learning schreibt nach `fact_history`)

52 neue `elearn_*`-Events (Sub A: 16 · Sub B: 12 · Sub C: 12 · Sub D: 12). Erscheinen in `fact_history`-Timeline eines MA unter Activity-Category `elearning`.

### 24.5.3 Inter-Sub-Daten-Flüsse

**Sub B → Sub A:** R5-Publish-Worker committed Artefakte ins Content-Repo (`arkadium/ark-elearning-content`) → GitHub-Webhook → Sub-A `POST /api/elearn/admin/import` → parse + upsert Kurse/Module/Lessons/Fragen.

**Sub B R1-R3 → Sub C R4b:** Newsletter-Generator nutzt Sub-B-Pipeline (Ingest/Chunk/Embed/Cluster) und hängt eigenen Runner `r4b_newsletter.py` für Newsletter-Struktur + Sections + Quiz an.

**Sub A ↔ Sub C:** Newsletter-Quiz nutzt identische `fact_elearn_quiz_attempt`-Logik mit `attempt_kind='newsletter'`. Sub A `elearn-attempt-finalizer` erkennt Newsletter-Attempts und emittiert Cross-Events.

**Sub A → Sub D:** `elearn-course-major-version-bumped`-Event löst `elearn-cert-revoker` aus → alle aktiven Certs dieses Kurses `status='revoked'` → Re-Cert-Assignment.

**Sub C → Sub D:** Gate-Middleware liest `fact_elearn_newsletter_assignment.enforcement_mode_applied='hard'` → zeigt Gate-Page bei CRM-Feature-Zugriff.

## 24.6 Externe Integrationen (erweitert durch E-Learning)

| Integration | Zweck | Richtung |
|---|---|---|
| Git (Content-Repo `arkadium/ark-elearning-content`) | Kurs-Content via Webhook importieren | Eingehend (Webhook) + Ausgehend (clone/push) |
| GitHub API | PR-Creation bei `publish_mode='pr'` | Ausgehend |
| Anthropic API | LLM-Freitext-Scoring (Haiku 4.5) + Content-Generation (Sonnet 4.6) | Ausgehend HTTPS |
| OpenAI API | Embeddings (`text-embedding-3-small`, 1536 dims) | Ausgehend |
| Voyage AI API | Alt-Embeddings (`voyage-3`, 1024 dims) | Ausgehend (optional) |
| S3/Blob | Zertifikat-PDFs `ark-elearn-certs/<tenant_id>/<cert_id>.pdf` | Ausgehend Upload + Eingehend Download |
| Web-Scraping (SIA/ETH/Baublatt/Konkurrenten) | Source-Ingest Sub B | Ausgehend HTTP |
| CRM-DB (eigene) | SQL-Queries für CRM-Source-Ingest | Intern read-only Role `elearn_content_gen_reader` |

## 24.7 Phasen-Plan aktualisiert

| Phase | Fokus | E-Learning-Stand |
|---|---|---|
| 1 | CRM-Core (9 Detailmasken) | — |
| 2 | ERP-Light (HR, Zeit, Commission, Billing) | — |
| 3 | ERP-Vollausbau | **Sub A/B/C/D Specs v0.1 + Patches in Grundlagen (v1.4)** |
| 4 | Automatisierung + AI | Sub B produktiv + Newsletter-Generator Sub C |
| 5 | Enforcement + Gamification | Sub D Gate aktiv + Badge-Engine erweitert |

### Sub A Meilensteine (priorisiert)

1. Spec-Freigabe (abgeschlossen)
2. Grundlagen-Merge (aktueller Stand v1.4)
3. Implementation-Plan via `superpowers:writing-plans` (konsolidiert A+B+C+D)
4. DB-Migration (`migrations/NNN_elearn_*.sql` · 4 Dateien: sub_a / sub_b / sub_c / sub_d)
5. MA-Flows (Dashboard, Lesson, Quiz)
6. Head/Admin-Flows (Team, Freitext-Queue, Curriculum)
7. Import-Pipeline + Seed-Content
8. LLM-Freitext-Scorer + Head-Review-Workflow
9. Cert-Generator + Badge-Engine
10. Pilot mit 1-2 neuen MA
11. Roll-out an bestehende MA
12. Sub B/C/D iterativ darauf aufsetzen

## 24.8 Team-Ownership

| Rolle | E-Learning-Verantwortung |
|---|---|
| Peter | Produkt-Owner, Content-Definition, Quellen-Kuration (Bücher, Notizen, Prio-PDFs), Final-Review, Default-Rules-Policy, Enforcement-Mode-Entscheid |
| Admin/Backoffice | Kurs-Publishing, Curriculum-Templates, Massen-Zuweisungen, Import-Monitoring, Analytics, Source-Verwaltung, Scheduler-Config, Cost-Monitoring, GitHub-PAT-Rotation, Rules-Verwaltung, Override-Requests, Cert-Manual-Revokes |
| Head-of (pro Sparte) | Team-Onboarding-Kontrolle, Freitext-Review, Ad-hoc-Zuweisungen, Status-Switch Neu→Bestehend, Queue-Bearbeitung Newsletter (überfällige), Override-Setting für eigenes Team, Team-Compliance-Dashboard |
| MA | Kurse bearbeiten, Quizzes absolvieren, Certs erhalten, Newsletter lesen+Quiz bestehen, Compliance-Status-Self-View |

## 24.9 Sicherheit & Compliance

- **Tenant-Isolation:** RLS auf DB-Ebene + App-Layer-Guards + Route-Scoping
- **Audit:** alle Zuweisungen, Completions, Reviews, Revisions, Overrides in `fact_history` + `fact_elearn_import_log` + `fact_elearn_gate_event`
- **Datenschutz:** Freitext-Antworten privat · Head sieht nur Team · Admin tenant-weit (operative Notwendigkeit)
- **DSGVO-Löschung:** MA-Löschung kaskadiert Enrollments/Attempts · Certs bleiben als Audit bis Tenant-Retention (Default 10 Jahre)
- **CRM-Daten in Newsletter:** strikt anonymisiert (keine direkten Kandidaten-/Kunden-Namen) · Tenant-gescopt (kein Cross-Tenant-Leak via RAG)
- **Rule-Engine Sub D:** keine freie SQL, nur fest-codierte Trigger-Evaluatoren → SQL-Injection-sicher
- **Override-Audit:** Creation/End geloggt mit `created_by`+`reason`

## 24.10 Kosten-Management (neu)

**LLM-Kosten pro Tenant budgetierbar:**
- Default: 200 €/Monat, 5 €/Job (Tenant-konfigurierbar `elearn_b.llm_cost_cap_*`)
- `elearn-cost-monitor` (Cron täglich)
- ≥ 95 % Monats-Cap → Admin-Notification
- 100 % → Neue Jobs blockiert (manueller Reset oder Monats-Rollover)
- Newsletter-Cost zählt gegen gleiches Budget (~6-30 €/Monat bei 5 Sparten × 4 Ausgaben)

**Cost-Dashboard:** Monats-Verbrauch + Restbudget, Top-Jobs, Aggregation nach Source-Kind, separater Newsletter-Cost-Block.

## 24.11 Compliance-Konzept (Sub D)

**Simpel-Formel:**
```
score = (courses_completed + newsletters_passed + certs_active)
        / NULLIF(courses_total + newsletters_total + (certs_active + certs_expired), 0)
        * 100
```

**Interpretation:** 100 % alles erledigt · 80-99 % sehr gut · 50-79 % Handlungsbedarf · < 50 % kritisch (Head-Alarm).

Tagesbasis-Snapshots in `fact_elearn_compliance_snapshot` ermöglichen Trend-Charts.

## 24.12 Cert-Lifecycle

```
Course complete + passed → Cert issued (status='active')
                                │
                  (nach refresher_months)
                                ▼
                         status='expired'
                                │
               Automatisch neuer Refresher-Assignment
                                │
               ─────────────────────────────────
               Alternativ: course version bump (major)
                                ▼
                         status='revoked'
                                │
               Automatischer Re-Cert-Assignment
```

## 24.13 Sub-Interop-Matrix (final)

| Sub | Rolle |
|---|---|
| **Sub A Kurs-Katalog** | Liefert Assignments, Enrollments, Certs. Liest Events aus User-Admin. Emittiert `elearn_course_major_version_bumped` für Sub D |
| **Sub B Content-Generator** | Nutzt pgvector + LLM. Publisht in Content-Repo → Webhook-Loop zu Sub A. Keine Sub-D-Interaktion |
| **Sub C Newsletter** | Nutzt Sub-B-Pipeline (R1-R3) + eigenen R4b-Runner. Quiz via Sub-A-Engine (`attempt_kind='newsletter'`). Liefert `enforcement_mode_applied` für Sub D |
| **Sub D Progress-Gate** | Gate-Middleware auf allen CRM-API-Routes. Liest State aus Sub A/C. Event `elearn_course_major_version_bumped` triggert Cert-Revoke |

## 24.14 Referenz-Dokumente (28 Spec-Dateien total)

**Pro Sub:** 1× SCHEMA + 1× INTERACTIONS + 5× Grundlagen-Patches = 7 Dateien. 4 Subs = 28 Spec-Dateien.

- **Sub A:** `ARK_E_LEARNING_SUB_A_{SCHEMA,INTERACTIONS}_v0_1.md` + 5 Patches
- **Sub B:** `ARK_E_LEARNING_SUB_B_{SCHEMA,INTERACTIONS}_v0_1.md` + 5 Patches
- **Sub C:** `ARK_E_LEARNING_SUB_C_{SCHEMA,INTERACTIONS}_v0_1.md` + 5 Patches
- **Sub D:** `ARK_E_LEARNING_SUB_D_{SCHEMA,INTERACTIONS}_v0_1.md` + 5 Patches

## 24.15 Statistik nach v1.4

```
E-Learning Tabellen:      28  (Sub A 15 · Sub B 5 · Sub C 4 · Sub D 4)
E-Learning Events:        52  (Sub A 16 · Sub B 12 · Sub C 12 · Sub D 12)
E-Learning Worker:        25  (Sub A 10 · Sub B 8 · Sub C 7 · Sub D 7)
E-Learning API-Endpoints: 80+ (Sub A 30 · Sub B 15 · Sub C 15 · Sub D 12+Intern)
E-Learning Pages:         25+ (Sub A 13 · Sub B 3 · Sub C 5 · Sub D 6)
E-Learning Enums:         25  (Sub A 8 · Sub B 8 · Sub C 5 · Sub D 4)
E-Learning Activity-Types:40  (Sub A 11 · Sub B 10 · Sub C 9 · Sub D 8 · +2 Doppel-Kategorisierung)
Activity-Kategorien:      19  (18 v1.4 + 1 elearning)
Tabellen total:          ~204 (176 v1.4 + 28 E-Learning)
```

## TEIL 25: HR-Modul (v1.5 / v2.7 / v1.12, 2026-04-25)

**Spec:** `specs/ARK_HR_TOOL_SCHEMA_v0_1.md` + `specs/ARK_HR_TOOL_INTERACTIONS_v0_1.md` (Stub)
**Route:** `/erp/hr` · **Feature-Flag:** `feature_hr_tool` (locked bis Go-Live)

### 25.1 Modul-Übersicht

Das HR-Modul ist ein eigenständiges Phase-3-ERP-Tool (kein Teil des CRM). Es verwaltet den Arbeitsvertrag-Lifecycle, HR-Dokumente (inkl. Arkadium-Reglemente), Disziplinarmassnahmen, Probezeit-Tracking und Onboarding-Checklisten.

**Absenzenverwaltung lebt im Zeit-Modul** — HR zeigt nur read-only KPIs via Zeit-API.

### 25.2 Kennzahlen

```
HR Screens:            7  (hr-shell · dashboard · list · self-service · disciplinary · onboarding · provisions)
HR Drawers:           11  (4 Stammdaten · 3 Disziplinar · 4 Onboarding) + 2 Self-Service
HR API-Endpoints:     18  (CRUD contracts · documents · disciplinary · onboarding · tasks · dashboard)
HR Events:             5  (document.ready · document.signed · onboarding.task.done · commission.eligibility.changed · contract.terminated)
HR Workers:            4  (probation-alert · signature-reminder · onboarding-overdue · disciplinary-retention)
HR DB-Tabellen:       11  (3 dim · 8 fact)
HR DB-Views:           4  (active_employees · onboarding_progress · disciplinary_summary · pending_signatures)
HR ENUM-Types:        10
Tabellen gesamt:    ~215  (204 + 11)
```

### 25.3 Kern-Entitäten

| Entität | Tabelle | Lifecycle |
|---------|---------|-----------|
| Arbeitsvertrag | `fact_employment_contracts` | draft → pending_sig → active → terminated |
| HR-Dokument | `fact_employment_attachments` | pending → signed (Arkadium-Reglemente) |
| Verwarnung | `fact_disciplinary_records` | draft → issued → acknowledged/disputed → resolved → archived |
| Probezeit-Meilenstein | `fact_probation_milestones` | 1-Mt-Gespräch · 2-Mt (opt.) · Abschluss · Verlängerung |
| Onboarding-Instanz | `fact_onboarding_instances` | draft → active → completed/overdue/cancelled |

### 25.4 Cross-Module-Abhängigkeiten

| Integration | Richtung | Mechanismus |
|------------|----------|-------------|
| Dok-Generator | HR → Dok-Gen | `hr.document.ready.v1` → PDF-Worker |
| E-Learning | HR → E-Learning | `hr.onboarding.task.done.v1` (TOOL_INTRO_ELEARN) → Enrollment |
| Commission | HR → Commission | `has_provisions` Toggle → `hr.commission.eligibility.changed.v1` |
| Zeit-Modul | Zeit → HR | `fact_absence` read-only für Abwesenheits-KPIs |
| Treuhand Kunz | HR → Export | Salary-Statement-PDF + AHV-Bestätigung für Payroll |

### 25.5 Legal-Basis

- OR Art. 319–362 (Einzelarbeitsvertrag), Art. 335b (Probezeit max 3/6 Mt), Art. 335c (Kündigungsfristen), Art. 337c (fristlose Kündigung)
- revDSG Art. 25 ff. (Auskunftsrecht), Retention-Policy per Tabelle (2–10 J)
- Arkadium-Reglemente: Generalis Provisio · Progressus · Praemium Victoria · Tempus Passio 365 · Locus Extra

### 25.6 Status (2026-04-25)

- Mockups: 7 Screens ✓ (hr.html · hr-dashboard.html · hr-list.html · hr-mitarbeiter-self.html · hr-warnings-disciplinary.html · hr-onboarding-editor.html · hr-provisionsvertrag-editor.html)
- Specs v0.1: Schema ✓ + Interactions (Stub) ✓
- Grundlagen-Sync: ✓ (TEIL M DB · TEIL O Backend · §96 Stammdaten · TEIL P Freeze · TEIL 25 Gesamtsystem)
- Implementation: Phase-3 (ausstehend)

---

## 24.16 Offene Punkte / Follow-ups

- **Implementation-Plan:** konsolidiert für A+B+C+D via `superpowers:writing-plans`
- **CRM-API-Refactor:** Gate-Middleware in ALLE bestehenden API-Routes einhängen (einmaliger Refactor-Effort)
- **CI-Check:** jede neue Route muss `@gate_feature` oder `@gate_exempt` haben (Linting-Regel)
- **Pilot-Strategie Sub D:** Soft-Enforcement 4-6 Wochen, Daten beobachten, dann selektiv Hard aktivieren
- **Port-Entscheidung Sub B:** bleiben LinkedIn_Automatisierung-Files als eigenes Repo oder in ARK-CRM konsolidiert? Peter entscheidet vor Implementation-Start
- **Sparte-Wert `uebergreifend`:** globaler Sparten-Katalog-Eintrag Phase-2 wenn cross-cutting Themen in anderen Modulen auftauchen
- **Mobile-App-Gate:** falls später Mobile-App, Gate-Middleware dort ebenfalls (Phase-3)
- **Override-Request-Workflow:** MA beantragt Override, Head approved? MVP: nur Head/Admin legt direkt an. Phase-2 Request-Flow
- **Emergency-Bypass-SLA:** Admin setzt Bypass → wirksam mit nächstem Request (Cache-Invalidation sofort)

---

## TEIL 26 · Performance-Modul (v1.5 · 2026-04-25)

**Kernidee:** Cross-Modul-Analytics-Hub. Liest aggregiert aus CRM, Billing, Commission, Zeit, E-Learning und HR — schreibt nur in eigene Tabellen. Vollständiger Patch: `specs/ARK_GESAMTSYSTEM_PATCH_v1_4_to_v1_5_performance.md`. Detail-Specs: `specs/ARK_PERFORMANCE_TOOL_SCHEMA_v0_1.md` + `specs/ARK_PERFORMANCE_TOOL_INTERACTIONS_v0_1.md`. Memory: `project_performance_modul_decisions.md`.

### 26.1 Modul-Charakteristik

- **NICHT** HR-Reviews — die leben im HR-Modul (`ark_hr.fact_performance_reviews` u.a.)
- **NICHT** E-Learning — das ist Single-Source via Sub A-D
- **NICHT** Zeit/Commission/Billing — alles eigene Module
- **IST** der zentrale Analytics-Hub: KPIs, Insights, Goals, Reports, Forecast über alle Module hinweg
- **Read-only** auf alle Quell-Module via Live-Views + Materialized Views (Power-BI Layer)

### 26.2 Reuse vs. Eigenes

**Reuses Stammdaten (keine Duplikation):**
- Sparten ARC/GT/ING/PUR/REM (`§8`)
- MA-Kürzel (`dim_user.label_de`, 2-Buchstaben-Display)
- Process-Stages aus `dim_process_stages` (mit neuen Spalten `funnel_relevance`, `avg_days_target`)
- Mandat-Typen Target/Taskforce/Time (`dim_mandate.business_model`)
- Activity-Types aus `dim_activity_types` (Touch-Frequenz aus `fact_history`)
- Roles MA/Head/Admin/BO (`dim_user.role_code`)
- Honorar-Settings (Commission-Engine)

**Eigene Stammdaten (neu in v1.6):**
- 33 Default-Metriken (`dim_metric_definition`)
- 15 Anomaly-Thresholds (`dim_anomaly_threshold`)
- 15 Tile-Types (`dim_dashboard_tile_type`)
- 5 Report-Templates (`dim_report_template`)
- 8 PowerBI-Views (`dim_powerbi_view`)

### 26.3 Cross-Modular Daten-Flüsse

| Quelle | Konsumiert von Performance via |
|--------|-------------------------------|
| CRM (`fact_process`, `fact_history`, `fact_placement`) | `v_pipeline_funnel`, `v_candidate_coverage`, `v_account_coverage`, `v_mandate_kpi_status`, `v_activity_heatmap` |
| Billing (`fact_invoice`) | `v_revenue_attribution` |
| Commission (`fact_commission_ledger`) | `v_commission_run_rate`, `v_revenue_attribution` |
| Zeit (`fact_time_entries`, `fact_absences`) | `v_zeit_utilization` |
| E-Learning (`fact_elearn_attempt`, `fact_elearn_assignment`, `fact_elearn_certificate`) | `v_elearn_compliance` |
| HR (`fact_performance_reviews`, `fact_competency_ratings`) | `v_hr_review_summary` |

### 26.4 8 Architektur-Entscheidungen 2026-04-25

| ID | Entscheidung | Wert |
|----|--------------|------|
| Q1 | HR-Performance-Reviews vs. Performance-Modul | C — alle Reviews ins HR-Modul (8 Tabellen migriert aus DB §19) |
| Q2 | Goals — operativ oder strategisch? | C — operative Performance-Goals im Performance-Modul (`fact_perf_goal`); strategische Karriere-Goals im HR (`fact_development_plans`) |
| Q3 | Anomaly-Detector-Default | Y — 15 Default-Schwellen seeded; Admin pflegt Sparten-/Rollen-Overrides |
| Q4 | PowerBI-Refresh-Strategie | D — 8 Default-Views mit per-View-Cron in `dim_powerbi_view.refresh_cron`; ETL-Worker `powerbi-view-refresh.worker` per BullMQ |
| Q5 | Tile-Customization | X — 15 Default-Tile-Types; User-Custom-Layout via `dim_dashboard_layout` (scope='user_custom'); Reset → Rollen-Default |
| Q6 | Closed-Loop-Insight-Workflow | D — Saga: Insight → Action-Item → Action-Outcome (verzögert via `action-outcome-measurer.worker`); resolve oder Folge-Action |
| Q7 | Report-Templates | D — 5 Default-Templates (weekly_ma/weekly_head/monthly_business/quarterly_exec/yearly_review); Bundle-Spec via `data_bundle_spec_jsonb`; Email via individuelles Outlook-Token (Sender konfigurierbar) |
| Q8 | Forecast-Method | E — Markov-Stage-Model v0.1 (Conversion-Rate × Time-Decay); Konfidenz ±25%; ML-Upgrade Phase 3+ |

Memory-Verweis: `project_performance_modul_decisions.md`.

### 26.5 Statistik

```
Performance ENUMs:           11 neue
Performance Tabellen:        14 (ark_perf.*) + 7 HR-Performance (ark_hr.*) − 3 gestrichen
Live-Views:                  10 (ark_perf.v_*)
Materialized Views:           8 (ark_perf.mv_*)
Default-Seeds:               76 Rows (33 Metric-Defs + 15 Thresholds + 15 Tiles + 5 Templates + 8 PowerBI)
Endpoints:                  ~50 (Performance) + ~30 (HR-Reviews-Erweiterung) + 2 (Power-BI-Bridge)
Worker:                      12 Performance + 1 HR-Cycle
Events:                      10 Performance + 5 HR-Reviews
WS-Channels:                  5 Performance + 2 HR
Sagas:                        3 (Closed-Loop · Pre-Built-Report · Review-Cycle)
Mockup-Pages:                10 (1 Hub + 9 Sub-Pages, alle ohne App-Bar)
```

### 26.6 Routing-Übersicht (UI)

```
Topbar-Toggle: CRM ↔ ERP

ERP-Workspace:
  /erp/zeit/*           → Zeit-Modul
  /erp/billing/*        → Billing-Modul
  /erp/elearn/*         → E-Learning-Modul (Sub A-D)
  /erp/hr/*             → HR-Modul (inkl. Performance-Reviews)
  /erp/performance/*    → Performance-Modul (NEU v1.5)
    ├── /dashboard      Performance-Cockpit
    ├── /insights       Insight-Loop-Inbox
    ├── /funnel         Pipeline-Funnel-Drilldown
    ├── /coverage       Schweizer Geo-Heatmap (TopoJSON-CDN)
    ├── /mitarbeiter    MA-Profil mit Reviews-Tab
    ├── /team           Team-Aggregat (Head)
    ├── /revenue        Revenue-Attribution
    ├── /business       Business-Dashboard
    ├── /reports        Report-Templates + Run-Audit
    └── /admin          6-Sub-Tab Admin-Konfiguration
```

### 26.7 Markov-Forecast v0.1

Pro aktivem Prozess:
```
P(placement) = ∏ conversion_rate(stage_i → stage_i+1) × time_decay
time_decay   = exp(-days_in_current_stage / avg_days_current_stage)
expected_revenue = honorar(expected_salary) × P(placement)
confidence_interval = expected_revenue × [0.75, 1.25]
```

`forecast-recompute.worker` läuft täglich 05:00, berechnet Conversion-Raten neu (12-Mt-Lookback per Sparte/Business-Model), dann pro Prozess + Aggregate (User/Sparte/Global). ML-Upgrade (logistic regression, gradient boosting) ab Phase 3+.

### 26.8 Data-Pipeline (PowerBI als ETL-Source)

PowerBI-Materialized-Views in `ark_perf.mv_*` sind ETL-Source-of-Truth für externe BI-Tools. Refresh via `powerbi-view-refresh.worker` (per-View-Cron). 3 Critical-Views (`pipeline_today` · `goal_drift_critical` · `coverage_critical`) refreshen hourly, andere daily/weekly/monthly. Power-BI-Service-Account authentifiziert via X-API-Key (separate Auth, nicht JWT) → `GET /api/powerbi/views`.

### 26.9 Referenzen

- Detail-Schema: `specs/ARK_PERFORMANCE_TOOL_SCHEMA_v0_1.md`
- Detail-Interactions: `specs/ARK_PERFORMANCE_TOOL_INTERACTIONS_v0_1.md`
- Mockup-Plan: `specs/ARK_PERFORMANCE_TOOL_MOCKUP_PLAN.md`
- Patches: `specs/ARK_*_PATCH_*_performance.md` (Stammdaten · DB · Backend · Frontend · Gesamtsystem)
- Memory: `project_performance_modul_decisions.md` · `feedback_phase3_modules_separate.md` · `project_phase3_erp_standalone.md`

