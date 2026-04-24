---
title: "Gesamtsystem-Übersicht Digest v1.4"
type: meta
created: 2026-04-17
updated: 2026-04-24
sources: ["ARK_GESAMTSYSTEM_UEBERSICHT_v1_4.md"]
tags: [digest, gesamtsystem, architektur, changelog, elearning]
---

# Gesamtsystem-Übersicht v1.4 — Digest (Stand 2026-04-24)

Kompaktes Digest von `Grundlagen MD/ARK_GESAMTSYSTEM_UEBERSICHT_v1_4.md` (v1.3 + v1.3.4 Dok-Generator + v1.3.5 Reminders + v1.3.6 Mobile/Tablet + v1.4 E-Learning-Modul 2026-04-24). Big Picture, Module, Changelog. Für Prosa-Details vollständige Quelle lesen.

## TOC (Quell-Sektionen)

- **v1.3-Kopf (§1–11):** Änderungen v1.2 → v1.3 (10 Blöcke + Referenz-Dokumente)
- **TEIL 1:** Was ist ARK? (Unternehmen, Sparten, Rollen, Consultant-Alltag)
- **TEIL 2:** Rekrutierungsprozess (Geschäftsmodelle, Mandatsarten, Longlist, Preleads, Jobbasket, Prozess-Pipeline, Post-Placement)
- **TEIL 3:** Kandidaten (Profil, Stages, Wechselmotivation/Temperatur, Kompetenzen, Briefing, Werdegang, Assessment)
- **TEIL 4:** Accounts, Kontakte, Firmengruppen
- **TEIL 5:** Jobs, Vakanzen, Mandate (inkl. Aktivierung, Shortlist-Trigger, Zusatzleistungen)
- **TEIL 6:** History & Automationen (3 Systeme, Activity-Types, Trigger-Matrix, Eskalation)
- **TEIL 7:** Email-System
- **TEIL 8:** Telefonie (3CX)
- **TEIL 9:** Dokumente
- **TEIL 10:** Reminders
- **TEIL 11:** Scraper + Market Intelligence
- **TEIL 12:** AI (+ Assessment-Import, Provisionsabrechnung, Account-Duplikat, Outlook-Ausfallsicherheit)
- **TEIL 12b:** Debuggability (Event-Timeline pro Entity)
- **TEIL 12c:** Phasen-Klarheit (Phase 1 / 1.5 / 2 / 3)
- **TEIL 13:** Stammdaten
- **TEIL 14–17:** Schema-Änderungen v1.1 → v1.2
- **TEIL 18:** Phase 2
- **TEIL 19:** Technische Architektur (Stack, RBAC, Power BI)
- **TEIL 20:** v1.3.1 Account-UI-Konsolidierung + Theme-Preference
- **TEIL 20b:** v1.3.2 Snapshot-Bar-Harmonisierung (5 Detailmasken)
- **TEIL 20c:** v1.3.3 Projekt-Detailmaske Phase A–I
- **TEIL 21:** Spec-Sync-Regel
- **TEIL 22:** v1.3.4 Globaler Dok-Generator (2026-04-17)
- **TEIL 23:** v1.3.5 Reminders-Vollansicht (2026-04-17)
- **TEIL 24 (alt):** v1.3.6 Mobile/Tablet-Support Frontend-Rewrite (2026-04-17)
- **TEIL 24 (neu):** v1.4 E-Learning-Modul (Sub A/B/C/D) (NEU 2026-04-24)

---

## System Nucleus

**Nukleus-Entitäten und Beziehungen:**

```
Kandidat  ── Briefing ──▶ Jobbasket ──▶ Prozess ──▶ Placement
   │                         ▲             │            │
   │                         │             ▼            ▼
   └── Longlist ◀── Mandat ──┴── Account/Job    Post-Placement
                     │              │                 (Reminders,
                     └─ Firmen-     └─ Vakanzen        Garantie)
                        gruppe (N:N)
```

- **Kandidat** (Stage-Machine, Temperatur, Wechselmotivation, Kompetenzen, Briefing-versioniert, Werdegang, Assessment)
- **Account** (Klassifikation, Einkaufspotenzial, AGB-Tracking, Scraping) → enthält **Kontakte** und **Vakanzen/Jobs**
- **Firmengruppe** (2-stufig flach, kein eigener Group-AM, eigene Detailseite 6 Tabs, Gruppen-Schutzfrist möglich)
- **Mandat** (Target/Taskforce/Time) → verknüpft via `bridge_mandate_accounts` (N:N, gruppenübergreifend)
- **Job** (= Stelle) unter Account; RPO/Taskforce: eine Position = ein Job
- **Prozess** (Interview-Pipeline) — Mischform `/processes` Liste + Drawer (540px) als Haupt-Arbeitsort (80%), 3-Tab-Detailseite für komplexe Fälle
- **Placement** (automatisch Job-Filled, Provisionsberechnung, Reminder-Kette)
- **Assessment** (Credits-basiert, typisiert, eigene Detailseite) — 11 Typen
- **Projekt** (3-Tier: Projekt → Gewerk (BKP) → Beteiligungen Firma+Kandidat mit SIA-Phasen)
- **Scraper** (Control-Center `/scraper`, 7 Typen, Confidence-Gating)

**Datenschichten:**
- `fact_history` (Mensch) · `fact_event_queue` (System) · `fact_audit_log` (Compliance) — kombinierte Timeline via `event-chain`-Endpoint
- `fact_candidate_presentation` + `fact_protection_window` (Schutzfrist, Scope account|group)
- `fact_mandate_billing` (Shortlist-Trigger, Kündigungs-Rechnung)

---

## Bounded Contexts / Module

**9 Detailseiten (aktive Entitäten mit eigener Maske):**

| # | Modul | Route | Status |
|---|-------|-------|--------|
| 1 | Kandidaten | `/candidates/[id]` | v1.2 aktiv |
| 2 | Accounts | `/accounts/[id]` | Schema v0.1 + Interactions v0.3 |
| 3 | Firmengruppen | `/company-groups/[id]` | v0.1 |
| 4 | Mandate | `/mandates/[id]` | Schema v0.1 + Interactions v0.3 |
| 5 | Jobs | `/jobs/[id]` | v0.1 |
| 6 | Prozesse | `/processes` + `/processes/[id]` | v0.1 (Mischform) |
| 7 | Assessments | `/assessments/[id]` | v0.2 (typisierte Credits) |
| 8 | Projekte | `/projects/[id]` | Schema v0.2 + Interactions v0.1 |
| 9 | Scraper | `/scraper` | v0.1 |

**Phase-3-ERP-Module (eigenes Produkt, via Topbar-Toggle CRM↔ERP):** Zeiterfassung · Buchhaltung/Billing · Payroll · Performance/HR · Messaging · Publishing · Doc-Generator · **E-Learning (Sub A/B/C/D, v1.4)**.

**Sparten (5):** ING (Civil Engineering) · GT (Building Technology) · ARC (Architecture) · REM (Real Estate Management) · PUR (Procurement). Jeder Kandidat/Account/Job primär einer Sparte zugeordnet.

**Rollen (6):** Head of (HoD) · Account Manager (AM) · Candidate Manager (CM) · Research Analyst (RA) · Backoffice (BO) · Admin. Eine Person kann mehrere Rollen haben (z.B. CM+AM).

**Tech-Stack:** Backend Node.js/Fastify/Railway · Frontend Next.js/React/Vercel · Electron Desktop-App · Event-driven · Dark Default + Light Mode (`dim_crm_users.theme_preference`) · ARK CI #262626/#dcb479/#196774 · Tenant-Isolation. Power BI direkt auf Supabase über Read-Only-Rolle.

**Phasen-Disziplin (§12c):**
- **Phase 1** (Launch-Blocker): 10-Tab-Masken Kandidat+Account, Jobs, Mandate, Prozesse, Jobbasket+GO-Flow, History+Activities, Reminders, Dokumente, Dashboard, Dark/Light, Suche
- **Phase 1.5** (4 Wochen post-Launch): AI-Activity-Vorschläge, Transkript-Summaries, Email-Composer+Inbox (MS Graph), 3CX, Assessment-CSV-Import, Stale-Erkennung, Post-Placement-Kette, Account-Duplikate
- **Phase 2** (3–6 Monate): RAG/Semantik, AI-Matching, WYSIWYG-Dok-Generator, Charts (D3), Kanban-D&D, Teamrad, Organigramm-Baum, Standorte-Karte, LinkedIn-Tracking, Mandate-Report-Generator
- **Phase 3** (eigenes ERP-Produkt): Zeiterfassung, Buchhaltung (Periodenabschluss-Lock zuerst!), Payroll, Performance/HR, Messaging, Publishing, **E-Learning**

---

## Key Business Rules (cross-cutting)

### Arkadium-Rolle (Headhunting-Boutique, NICHT-teilnehmend bei Interviews)

Alle Interview-Stages (TI, 1st, 2nd, 3rd, Assessment) laufen **direkt Kunde ↔ Kandidat**. Termine meist direkt zwischen Kunde und Kandidat. Interview-Durchführung ist **keine** Activity — sie steht als `fact_process_interviews.actual_date`.

**Arkadium-Touchpoints (4):**
| Touchpoint | Teilnehmer | Wann |
|---|---|---|
| **Briefing** | Arkadium ↔ Kandidat | Einmalig nach Hunt/Research (Eignungsgespräch) |
| **Coaching** | Arkadium ↔ Kandidat | VOR jedem Interview |
| **Debriefing** (beidseitig) | Arkadium ↔ Kandidat UND Arkadium ↔ Kunde (2 separate Gespräche) | NACH jedem Interview (entity_relevance=both → 2 fact_history-Einträge) |
| **Referenzauskunft** | Arkadium ↔ Referenzperson | Im Kunden-Auftrag, vor Placement |

**Nie verwechseln:** Briefing (Kandidat-Eignungsgespräch) ≠ Coaching (Interview-Vorbereitung) ≠ **Stellenbriefing** (Kunde-Seite, über Stelle).

### Schutzfrist vs. Garantiefrist (GETRENNT)

- **Garantiefrist** = 3 Monate post-Placement, Rückvergütung gestaffelt (M1 50% / M2 25% / M3 10%). Cancellation (Rückzieher nach Zusage) = 100%.
- **Schutzfrist** = **Direkteinstellungs-Schutzfrist** (AGB §6), 12 Mt default / 16 Mt bei Info-Verweigerung durch Kunden. Greift **nur wenn Prozess OHNE Placement endet**. Start: Kandidaten-Vorstellung beim Kunden. Scope: `account` ODER `group`. **AM alleine** kann Claim stellen.
- **Claim-Billing (3 Fälle):** X Mandat-identisch → Rest-Summe · Y andere Position → Staffel · Z Erfolgsbasis → Staffel

### Zwei Geschäftsmodelle

- **Mit Mandat** (Target/Taskforce/Time): formeller Auftrag, Longlist, KPI-Tracking. Aktivierung via Dokument-Upload „Mandatsofferte unterschrieben" (Status Entwurf → Aktiv).
- **Erfolgsbasis** (Best Effort): kein Mandat, gestaffelte Fee (<90k→21% · <110k→23% · <130k→25% · ≥130k→27%, pro Prozess überschreibbar). AGB-Gate-Check bei CV-Versand (Warnung, kein Block).

### Mandatsarten (v1.3-Umbenennung)

| Alt (v1.2) | Neu (v1.3) |
|---|---|
| Einzelmandat | **Target** (3-Teil-Zahlung: Vertrag / Shortlist / Placement) |
| RPO | **Taskforce** (mind. 3 Positionen, monatl. Fee + Erfolgsfee pro Position) |
| Time | Time (nur monatl. Beratungs-Fee) |

**Mandats-Kündigung (80%-Formel):** Fall A Arkadium = `80% × Gesamt − bezahlt` · Fall B Auftraggeber = `max(Stages bis laufende, 80%) − bezahlt`. Atomare TX: Status + Rechnung + Schutzfrist-Opening + Longlist-Lock + Events. AM alleine.

### Drawer-Default + UI-Patterns

- **CRUD/Confirms/Mehrschritt-Eingabe = Drawer 540px** (slide-in). Modal nur für kurze Confirms / Blocker / System-Notifications.
- **Datum-Eingabe:** Kalender-Picker UND Tastatur-Eingabe (natives `<input type="date">` etc., kein Click-only).
- **Snapshot-Bar uniform** (§20b): `.snapshot-bar` + `.snapshot-item` (lbl/val/delta) auf allen 5 Detailmasken, **über** Tabbar gestapelt (z-index 50 / 49). Dupe-Regel: Slots ≠ Header-Info. Ausnahmen (7 Slots): Assessment, Scraper, Projekt.
- **Sprachstandard:** DB-Feldnamen englisch · Status-Enums gemischt (Mandat/Job/Projekt/Kandidat deutsch · Prozess/Assessment/Scraper/Temperature englisch) · Routen alle englisch.

### Activity-Linking (Single Source of Truth)

Alle operativen UI-Felder (Check-Ins, Debriefings, Coachings, Referenzauskünfte, Stage-Transitions) sind **Projektionen von `fact_history`-Events**. Jedes UI-Feld muss auf eine `fact_history`-Row verlinken. UI-Status (✓/offen/○) aus Activity-Existenz+Status berechnet, kein separater Boolean.

### Automations-Prinzipien

- Briefing → Premarket + Longlist-Sync
- Mündliche GOs Email → Jobbasket oral_go + Longlist go_muendlich
- NIC/Dropped → Refresh + Longlist-Rejection
- CV-Upload → Longlist cv_in
- Placement → Job Filled + Onboarding/Check-in Reminders + Provisions-Berechnung
- Datenschutz → Anonymisierung; nach 1 Jahr auto → Refresh (**Sonder-Automation** mit system_override, darf terminalen Status überschreiben, audit-logged)
- Cold >6 Mt → Inactive
- Template-Email → Auto-Klassifizierung
- Shortlist-Trigger (Target) → 2. Zahlung fällig + AM-Notification
- Mandatsofferte unterschrieben (Doc-Upload) → Mandat Entwurf → Aktiv
- AI **schreibt nie direkt** — Vorschlag + Mensch-Bestätigung. AI-Bestätigungsrate = KPI.

### Stammdaten-Kataloge (kritisch, immer gegen `ARK_STAMMDATEN_EXPORT_v1_3` prüfen)

- **Prozess-Stages:** Expose · CV Sent · TI · 1st · 2nd · 3rd · Assessment · Offer · Placement
- **Prozess-Status:** Open · On Hold · Rejected · Placed · Stale · Closed · Cancelled · Dropped
- **Mandat-Status:** Entwurf → Aktiv/Abgelehnt → Abgeschlossen/Abgebrochen
- **Activity-Types:** 61+ in 11 Kategorien (Kontaktberührung 6 · Erreicht 15 · Email 11 · Messaging 3 · Interviewprozess 9 · Placementprozess 3 · Refresh 3 · Mandatsakquise 4 · Erfolgsbasis 2 · Assessment 4 · System 6). Spalte `entity_relevance` (candidate/account/both). **v1.4 erweitert auf 19 Kategorien inkl. `elearning` (+40 E-Learning Activity-Types).**
- **Kandidat-Stages:** Check · Refresh · Premarket · Active Sourcing · Market Now · Inactive · Blind · Datenschutz
- **Kompetenz-Dimensionen (5):** Cluster/Subcluster · Functions (190+) · Focus (160+, ersetzt dim_skills) · EDV (120+) · Sector. Rating 1–10 + Primary-Flag.
- **Wechselmotivation (8):** Arbeitslos · Will/muss wechseln · Wahrscheinlich wechseln · Bei gutem Angebot · Spekulativ · Intern & wartet · Absolut nicht · Nicht mit uns.
- **Temperatur:** Hot / Warm / Cold.

### Debuggability

Pro Entity (Kandidat, Account, Job, Mandat, Prozess) kombinierte Timeline-Ansicht aus `fact_history` + `fact_event_queue` + `fact_audit_log`. Endpoint `GET /api/v1/entities/:type/:id/event-chain` liefert chronologisch mit Trigger, Feld-Diffs und correlation_id.

---

## Changelog v1.2 → v1.3 (Diff-Summary)

| # | Block | Kern |
|---|-------|------|
| 1 | Mandatsarten umbenannt | Einzelmandat → **Target** · RPO → **Taskforce** · Time unverändert |
| 2 | Prozess-Mischform | v1.2 sagte Vollseite. v1.3: `/processes` Liste + 540px-Drawer (80% Fälle) + 3-Tab-Seite für komplexe Fälle |
| 3 | Firmengruppen als Entity | 2-stufig flach, kein Group-AM, `/company-groups/[id]` 6 Tabs, Schutzfrist-Scope `group`, N:N Taskforce via `bridge_mandate_accounts` |
| 4 | Assessments | Credits-basiert, typisiert (11 Typen MDI/Relief/ASSESS5.0/DISC/EQ/Scheelen6HM/DrivingForces/HumanNeeds/Ikigai/AI/Teamrad). Umwidmung nur innerhalb gleichen Typs. Eigene Detailseite. |
| 5 | Scraper-Control-Center | `/scraper` 6 Tabs, 7 Scraper-Typen, Confidence ≥85 auto · 60–84 review · <60 `needs_am_review` |
| 6 | Projekte 3-Tier | `/projects/[id]` 6 Tabs. Projekt → Gewerk (BKP) → Beteiligungen (Firmen+Kandidaten) mit SIA 6 Haupt + 12 Teil |
| 7 | Schutzfrist-System | `fact_candidate_presentation` + `fact_protection_window`. Nur konkrete Vorstellungen. Scope account|group. 12→16 Mt Auto-Extension. 3 Claim-Billing-Fälle. AM alleine. |
| 8 | Mandats-Kündigung (Exit) | 80%-Formel Fall A/B. Atomare TX mit Schutzfrist-Opening + Longlist-Lock + Bulk-Rejection offener Prozesse. AM alleine. |
| 9 | Sprachstandard & Routen | DB englisch · Status gemischt · alle Routen englisch |
| 10 | Detailseiten-Inventar | 9 Detailseiten (siehe Tabelle Module). Mitarbeiter → ERP HR. Reporting → ERP, im CRM nur Dashboard. |

**Referenz-Dokumente (v1.4-Stand):**
- `ARK_DATABASE_SCHEMA_v1_5.md` — 28 neue E-Learning-Tabellen (Sub A 15 · B 5 · C 4 · D 4) + Multi-Tenant
- `ARK_BACKEND_ARCHITECTURE_v2_7.md` — 52 E-Learning-Events, 25 Worker, 80+ Endpoints, Gate-Middleware
- `ARK_FRONTEND_FREEZE_v1_12.md` — Topbar-Toggle CRM↔ERP, 25+ E-Learning-Pages, Sidebar-Pattern
- `ARK_STAMMDATEN_EXPORT_v1_5.md` — 25 neue Enums, 40 E-Learning-Activity-Types, Kategorie `elearning`

### Nachträge

- **v1.3.1 (2026-04-14) — Account-UI-Konsolidierung:** Snapshot-Bar Slot 5+6 reine Firmografik (Gegründet/Standorte) statt Arkadium-Relation. Account Tab 1 neue Arkadium-KPI-Bar (Umsatz YTD, Placements total, Ø TTH, CV→Placement-Conversion). Kontakt-Drawer 4 Tabs (Stammdaten/Kommunikation/Prozesse/Notizen), Kommunikation zeigt NUR dieses-Kontakts-Interaktionen mit Account. Theme-Preference auf User-Ebene. Stammdaten-Ergänzungen: Owner-Teams (ARC&REM / ING&BT), `dim_dossier_preferences`.
- **v1.3.2 (2026-04-16) — Snapshot-Bar-Harmonisierung:** 5 Detailmasken vereinheitlicht auf `.snapshot-bar`. Stacking Snapshot über Tabbar. Dupe-Regel (keine Header-Duplikate). Slot-Belegung pro Entity fixiert. Ausnahmen 7 Slots: Assessment, Scraper, Projekt.
- **v1.3.3 (2026-04-16) — Projekt-Detailmaske Phase A–I:** `/projects/[id]` 676 → 2395 Zeilen. Tab-für-Tab-Ausbau (Übersicht/Gewerke-3-Tier-Akkordeon/Matching-6-Score/Galerie-Masonry/Dokumente-Profile „Projekt" 6 Kategorien/History 13 Events). 14 Drawers. Status-Dropdown 6 Werte. Projekttyp-agnostische Snapshot-Bar. Scraper-Source-Banner. `wiki/entities/projekt.md` neu.
- **v1.3.4 (2026-04-17) — Globaler Dok-Generator + Assessment-Spec-Sync v0.3:** Siehe TEIL 22 unten.
- **v1.3.5 (2026-04-17) — Reminders-Vollansicht (Tool-Maske 3):** Neue `/reminders`-Maske ergänzt Dashboard-Widget + Entity-Tabs (Kandidat §10, Account §13). Liste + Kalender, Scope `self/team/all` via `dim_mitarbeiter.vorgesetzter_id`, Saved-Views in `dashboard_config.reminders` (JSONB, max 10), Drag-to-Reschedule. DB v1.3.5: `fact_reminders.template_id` FK + `escalation_sent_at`. Backend v2.5.5: 2 Events + 1 Worker + 3 Endpoints. Siehe TEIL 23 unten.
- **v1.3.6 (2026-04-17) — Mobile/Tablet-Support Rewrite:** FRONTEND_FREEZE §24b neu — alte „Tablet Read-Only + Mobile Blocker"-Regel entfernt, voller Mobile-+-Tablet-Support. Breakpoints Desktop > 960 / Tablet 641–960 / Mobile ≤ 640. crm.html responsive-Shell (Top-Bar + Slide-Out), crm-mobile.html Device-Demo (3 iframes), editorial.css global Mobile-Rules, pro-Mockup-Fixes. Viewport-Meta in 22 Mockups. Keine DB-/Backend-Änderungen.
- **v1.4 (2026-04-24) — E-Learning-Modul Sub A/B/C/D:** Siehe TEIL 24 (neu) unten.

### TEIL 22 — v1.3.4 Globaler Dok-Generator (2026-04-17)

**22.1 Neuer globaler Dok-Generator**
- **Location:** `/operations/dok-generator` (Sidebar-Bereich Operations, Sibling zu Email-Inbox, Reminders, Scraper)
- **Ersetzt** verstreute CTAs in Entity-Detailmasken (Mandat-Offerte-Gen, Assessment-Offerte-Gen, Kandidat-Tab-9 Dok-Generator) durch zentrale Workflow-Engine
- **38 aktive Templates** (+ 1 ausstehend `mandat_offerte_time`) in 7 Kategorien: Mandat-Offerte · Mandat-Rechnung · Best-Effort · Assessment · Rückerstattung · Kandidat · Reportings
- **Neu im Katalog:** Executive Report (Arkadium-Zusammenfassung Assessment mit manuellen Feldern)
- **Du/Sie + Rabatt + Mandat-Typ = separate Templates** (nicht Parameter — ganzer Text unterscheidet sich, User-Entscheidung 2026-04-17)
- **Auto-Pull aus Entity-Vollansichten** via Platzhalter `{{entity.feld}}`
- **5-Step-Workflow:** Template → Entity → Ausfüllen → Preview → Ablage
- **Deep-Link-fähig** aus allen Entity-CTAs (`?template=<key>&entity=<type>:<id>`)
- **Kandidat-Tab-9** wird migriert: Phase 1 Redirect-Banner, Phase 3 deprecated

**22.2 Neue Grundlagen-Entries**
- **Stammdaten §56** — `dim_document_templates` Katalog mit 38+1 Templates
- **Database §14.1** — `document_label` ENUM-Erweiterung (12 neue Labels inkl. 'Executive-Report')
- **Database §14.2** — `dim_document_templates` Tabelle
- **Database §14.3** — `fact_documents` Erweiterung (5 neue Felder)
- **Backend §L** — 9 neue Endpoints unter `/api/v1/document-templates/*` + Wrapper-Mapping
- **Frontend §4e** — Neue Detailmaske-Spec `/operations/dok-generator` mit 5-Step-Workflow

**22.3 Assessment-Spec-Sync v0.2 → v0.3**
- **Order-Status `invoiced` entfernt** — Rechnungs-Bezahl-State lebt auf `fact_assessment_billing.status`
- **Phase-1-Typen-Kommentar** in Assessment-Schema §0 — Mockup/Launch nutzt nur MDI/Relief/ASSESS 5.0/EQ (SCHEELEN)

### TEIL 23 — v1.3.5 Reminders-Vollansicht (2026-04-17)

**23.1 Neue Tool-Maske `/reminders`**
- 3. Tool-Maske neben `/operations/dok-generator` und `/operations/email-kalender`
- Ergänzt — ersetzt nicht — Dashboard-Widget + Entity-Reminder-Tabs
- **Layout:** Banner · KPI-Strip (6) · Saved-Views-Chips · View-Toggle (Liste/Kalender) · Filter-Bar · Status-Chip-Tabs · Main · 2 Drawer (Detail 5-Tab, Neu)
- **View-Modi:** Liste mit Section-Groups (Überfällig/Heute/Woche/Später/Erledigt-30d) + Kalender CRM-intern (Monat/Woche, Drag-to-Reschedule)
- **Scope-Logik:** `self` / `team` / `all` via `dim_mitarbeiter.vorgesetzter_id`. Switcher nur Admin/HoD
- **Saved Views:** System-Defaults + max 10 user-defined in `dashboard_config.reminders` (JSONB)
- **Keine Bulk-Actions** (PO-Entscheidung)
- **Auto-Regeln** separat unter `/admin/reminder-rules`

**23.2 DB/Backend-Deltas**
- `fact_reminders.template_id` FK + `escalation_sent_at` (Idempotenz 48h)
- 2 Events (`reminder_reassigned`, `reminder_overdue_escalation`) + 1 Worker (hourly 08–20h) + 3 Endpoints

---

# TEIL 24 (NEU) — v1.4 E-Learning-Modul (2026-04-24)

**Quellen:** `specs/ARK_GESAMTSYSTEM_PATCH_ELEARNING_v0_1.md` (Sub A) + `SUB_B_v0_1.md` + `SUB_C_v0_1.md` + `SUB_D_v0_1.md`.

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

**Status:** alle 4 Subs (A/B/C/D) specct und in Grundlagen (v1.5 Stammdaten + v1.5 DB + v2.7 Backend + v1.12 Frontend) eingearbeitet. Implementation-Plan-Start nach Merge.

## 24.2 E-Learning Kern-Idee (cross-Sub)

**Arkadium-internes Lernsystem mit 4 Bausteinen:**

- **Sub A Kurs-Katalog:** MA bearbeiten Pflicht-Kurse + Refresher (mit Zertifikaten + Badges), Head reviewt Freitext-Antworten (LLM-gescort), Admin verwaltet Kurse/Curriculum-Templates, Import via Git-Webhook aus Content-Repo
- **Sub B Content-Generator:** LLM-basierte Pipeline R1-R5 aus PDF/DOCX/Bücher/Web-Scrapes/CRM-Queries → Entwurfs-Artefakte → Admin-Review → Publish ins Content-Repo (Loop zu Sub A). Port aus `C:\Linkedin_Automatisierung`
- **Sub C Wochen-Newsletter:** wöchentlicher Newsletter pro Sparte mit Sections aus Sub B + Pflicht-Quiz (`attempt_kind='newsletter'`), Soft/Hard-Enforcement
- **Sub D Progress-Gate:** Feature-granulare Rules + Override-System + Compliance-Dashboards · schützt CRM-Features bei Nicht-Bearbeitung

## 24.3 Workspace-Struktur (neu)

**Topbar-Toggle CRM ↔ ERP** (global, links von Avatar):
- **CRM-Modus:** Sidebar zeigt CRM-Module (Kandidaten, Accounts, Mandate, Jobs, Prozesse, Assessments, Aktivitäten, Admin)
- **ERP-Modus:** Sidebar zeigt ERP-Module (E-Learning, HR, Zeiterfassung, Commission, Billing, Doc-Generator)
- Persistenz pro User in `localStorage`

**Gemeinsame Infrastruktur beider Workspaces:** Authentifizierung (JWT, SSO) · User-Base (`dim_user`) · Event-Pipeline (`fact_event_queue`, `fact_history`, Event-Processor) · Notification-System · Audit-Logging · Design-System (Tokens, Components, Drawer-Pattern).

**Getrennt:** DB-Namespaces (CRM Recruiting-Domain vs. ERP modulspezifisch `dim_elearn_*`, `dim_hr_*`, `dim_zeit_*`) · URL-Routing (`/crm/*` vs. `/erp/<modul>/*`) · Sidebar-Items.

## 24.4 Multi-Tenant-Aspekt (neu)

E-Learning ist das **erste ARK-Modul mit konsequenter Multi-Tenant-Architektur**:
- Alle 28 neuen Tabellen tragen `tenant_id UUID NOT NULL`
- RLS-Policies auf allen Tabellen (`tenant_id = app.current_tenant_id`)
- Von Tag 1 an designt (nicht später nachgerüstet)

**Begründung:** White-Label-Option für externe Recruiting-Boutiquen. Schema-Vorbereitung jetzt ist günstiger als spätere Migration.

**Konsequenz für künftige ERP-Module:** Multi-Tenant-Pattern übernehmen (Pattern-Doku Sub-A-Backend-Patch §4).

## 24.5 Datenflüsse

### 24.5.1 Eingehende Events (E-Learning reagiert auf CRM)

| Event | E-Learning-Reaktion |
|---|---|
| `user_created` | Sub A: `elearn-onboarding-initializer` erzeugt Curriculum; Sub C: `elearn-newsletter-subscription-initializer` |
| `user_role_changed` | Sub A: `elearn-role-change-watcher` erzeugt Diff-Assignments; Sub C: Subscription-Syncer |
| `user_sparte_changed` | dito |

### 24.5.2 Ausgehende Events

52 neue `elearn_*`-Events (Sub A 16 · Sub B 12 · Sub C 12 · Sub D 12). Erscheinen in `fact_history`-Timeline eines MA unter Activity-Category `elearning`.

### 24.5.3 Inter-Sub-Daten-Flüsse

- **Sub B → Sub A (Publish-Loop):** R5-Publish-Worker committed Artefakte ins Content-Repo (`arkadium/ark-elearning-content`) → GitHub-Webhook → Sub-A `POST /api/elearn/admin/import` → parse + upsert Kurse/Module/Lessons/Fragen.
- **Sub B R1-R3 → Sub C R4b:** Newsletter-Generator nutzt Sub-B-Pipeline (Ingest/Chunk/Embed/Cluster) + eigener Runner `r4b_newsletter.py` für Newsletter-Struktur + Sections + Quiz.
- **Sub A ↔ Sub C (Quiz):** Newsletter-Quiz nutzt identische `fact_elearn_quiz_attempt`-Logik mit `attempt_kind='newsletter'`. Sub-A-`elearn-attempt-finalizer` erkennt Newsletter-Attempts + emittiert Cross-Events.
- **Sub A → Sub D (Major-Version):** `elearn-course-major-version-bumped`-Event löst `elearn-cert-revoker` aus → alle aktiven Certs dieses Kurses `status='revoked'` → Re-Cert-Assignment.
- **Sub C → Sub D (Enforcement):** Gate-Middleware liest `fact_elearn_newsletter_assignment.enforcement_mode_applied='hard'` → Gate-Page bei CRM-Feature-Zugriff.

## 24.6 Externe Integrationen (erweitert)

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
- **CRM-Daten in Newsletter:** strikt anonymisiert · Tenant-gescopt (kein Cross-Tenant-Leak via RAG)
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

## Pointer to full source

Für Prosa-Details jeweils Quelle lesen: `Grundlagen MD/ARK_GESAMTSYSTEM_UEBERSICHT_v1_4.md`:

- **Consultant-Alltag + NIE/IMMER-manuell-Listen:** §1.4
- **Longlist-Flow komplett (Research → Schriftl. GO) + Sperr-Regeln ab CV IN:** §2.3
- **Preleads + GO-Prozess-Details (5 Schritte + 3 Rejection-Typen):** §2.4
- **Jobbasket-Gates 1+2 (Assigned/Versand-Bedingungen):** §2.5
- **Interview-Terminierung + Outlook-CalendarReadWrite-Read-Only-Referenz:** §2.6
- **Post-Placement-Reminder-Kette (Onboarding/1-2-3-Mt-Checks + Rückvergütungs-Staffel):** §2.7
- **Kandidaten-Stages-Trigger-Matrix + Datenschutz-Sonder-Automation (system_override):** §3.2
- **Briefing-9-Sektionen + Werdegang-AI-Projekt-Matching:** §3.5, §3.6
- **Mandats-Aktivierung + Shortlist-Trigger + Zusatzleistungen (Ident/Dossier-Extra):** §5.3
- **Automations-Trigger-Matrix + Eskalation (24h/48h/wöchentlich):** §6.3, §6.4
- **Email-Templates (32, 4 mit Automation-Trigger) + Ausfallsicherheit:** TEIL 7
- **Dokumente + Mandate-Report-Generator (PDF):** TEIL 9
- **Reminders (alle Auto-Typen):** TEIL 10
- **AI-Details: Scheelen-Import-Dry-Run, Provisionsabrechnung-Phase1/2, Account-Duplikat-Fuzzy-Matching, Outlook-Ausfallsicherheit 5-Min-Health-Check:** TEIL 12
- **Debuggability Event-Chain-Endpoint:** TEIL 12b
- **Phasen-Details 1 / 1.5 / 2 / 3 (exakte Feature-Listen):** TEIL 12c
- **Stammdaten-Kataloge (alle dim_*-Tabellen gruppiert):** TEIL 13
- **Schema-Änderungen v1.1 → v1.2 (kompakte Einzeiler-Liste):** TEIL 14–17
- **RBAC + Power-BI-Read-Only-Rolle:** TEIL 19
- **Projekt-Detailmaske alle 6 Tabs + 14 Drawers + Header-Specials:** TEIL 20c
- **Snapshot-Bar-Harmonisierung Slot-Belegung pro Entity + Dupe-Regel:** TEIL 20b
- **Spec-Sync-Trigger-Matrix (vollständige Tabelle):** TEIL 21
- **E-Learning Sub A/B/C/D komplett (Modul-Landkarte, Datenflüsse, Cert-Lifecycle, Multi-Tenant, Sub-Interop):** TEIL 24 (neu)

**Verwandte Wiki-Konzepte:**
- [[status-enum-katalog]] · [[mandat-kuendigung]] · [[direkteinstellung-schutzfrist]] · [[optionale-stages]] · [[diagnostik-assessment]]
- [[interaction-patterns]] (§4 Drawer-Default, §14 Datum-Eingabe, §14a Briefing vs. Stellenbriefing)
- [[design-system]] (§3.2b Snapshot-Slot-Allokation)
- [[spec-sync-regel]]
- [[grundlagen-changelog]]
- [[rbac-matrix]]
