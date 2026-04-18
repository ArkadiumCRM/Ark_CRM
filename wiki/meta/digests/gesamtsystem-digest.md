---
title: "Gesamtsystem-Übersicht v1.3.5 — Digest"
type: meta
created: 2026-04-17
updated: 2026-04-17
sources: ["ARK_GESAMTSYSTEM_UEBERSICHT_v1_3.md"]
tags: [digest, gesamtsystem, architektur, changelog]
---

# Gesamtsystem-Übersicht v1.3.5 — Digest (Stand 2026-04-17)

Kompaktes Digest von `Grundlagen MD/ARK_GESAMTSYSTEM_UEBERSICHT_v1_3.md` (v1.3 + v1.3.4 Dok-Generator + v1.3.5 Reminders-Vollansicht 2026-04-17). Big Picture, Module, Changelog. Für Prosa-Details vollständige Quelle lesen.

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
- **TEIL 22:** v1.3.4 Globaler Dok-Generator (NEU 2026-04-17)
- **TEIL 23:** v1.3.5 Reminders-Vollansicht (NEU 2026-04-17)
- **TEIL 24:** v1.3.6 Mobile/Tablet-Support Frontend-Rewrite (NEU 2026-04-17)

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

**Nicht im CRM (→ ERP):** Mitarbeiter-HR, Performance-Reporting (nur Dashboard im CRM), Zeiterfassung, Buchhaltung, Payroll, Messaging (WhatsApp/LinkedIn), Publishing.

**Sparten (5):** ING (Civil Engineering) · GT (Building Technology) · ARC (Architecture) · REM (Real Estate Management) · PUR (Procurement). Jeder Kandidat/Account/Job primär einer Sparte zugeordnet.

**Rollen (6):** Head of (HoD) · Account Manager (AM) · Candidate Manager (CM) · Research Analyst (RA) · Backoffice (BO) · Admin. Eine Person kann mehrere Rollen haben (z.B. CM+AM).

**Tech-Stack:** Backend Node.js/Fastify/Railway · Frontend Next.js/React/Vercel · Electron Desktop-App · Event-driven · Dark Default + Light Mode (`dim_crm_users.theme_preference`) · ARK CI #262626/#dcb479/#196774 · Tenant-Isolation. Power BI direkt auf Supabase über Read-Only-Rolle.

**Phasen-Disziplin (§12c):**
- **Phase 1** (Launch-Blocker): 10-Tab-Masken Kandidat+Account, Jobs, Mandate, Prozesse, Jobbasket+GO-Flow, History+Activities, Reminders, Dokumente, Dashboard, Dark/Light, Suche
- **Phase 1.5** (4 Wochen post-Launch): AI-Activity-Vorschläge, Transkript-Summaries, Email-Composer+Inbox (MS Graph), 3CX, Assessment-CSV-Import, Stale-Erkennung, Post-Placement-Kette, Account-Duplikate
- **Phase 2** (3–6 Monate): RAG/Semantik, AI-Matching, WYSIWYG-Dok-Generator, Charts (D3), Kanban-D&D, Teamrad, Organigramm-Baum, Standorte-Karte, LinkedIn-Tracking, Mandate-Report-Generator
- **Phase 3** (eigenes ERP-Produkt): Zeiterfassung, Buchhaltung (Periodenabschluss-Lock zuerst!), Payroll, Performance/HR, Messaging, Publishing

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
- **Activity-Types:** 61+ in 11 Kategorien (Kontaktberührung 6 · Erreicht 15 · Email 11 · Messaging 3 · Interviewprozess 9 · Placementprozess 3 · Refresh 3 · Mandatsakquise 4 · Erfolgsbasis 2 · Assessment 4 · System 6). Spalte `entity_relevance` (candidate/account/both).
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

**Referenz-Dokumente (v1.3-Stand):**
- `ARK_DATABASE_SCHEMA_v1_3.md` — 28 neue Tabellen + 30+ Feld-Erweiterungen
- `ARK_BACKEND_ARCHITECTURE_v2_5.md` — 30+ Events, 18 Worker, 46 Endpunkte, WebSocket, Rate-Limiting
- `ARK_FRONTEND_FREEZE_v1_10.md` — 5 neue Detailseiten-Kap., Account-Tabs 10→13, Prozess-Mischform
- `ARK_STAMMDATEN_EXPORT_v1_3.md` — 15 neue dim_*-Tabellen

### Nachträge

- **v1.3.1 (2026-04-14) — Account-UI-Konsolidierung:** Snapshot-Bar Slot 5+6 reine Firmografik (Gegründet/Standorte) statt Arkadium-Relation. Account Tab 1 neue Arkadium-KPI-Bar (Umsatz YTD, Placements total, Ø TTH, CV→Placement-Conversion). Kontakt-Drawer 4 Tabs (Stammdaten/Kommunikation/Prozesse/Notizen), Kommunikation zeigt NUR dieses-Kontakts-Interaktionen mit Account. Theme-Preference auf User-Ebene. Stammdaten-Ergänzungen: Owner-Teams (ARC&REM / ING&BT), `dim_dossier_preferences`.
- **v1.3.2 (2026-04-16) — Snapshot-Bar-Harmonisierung:** 5 Detailmasken vereinheitlicht auf `.snapshot-bar`. Stacking Snapshot über Tabbar. Dupe-Regel (keine Header-Duplikate). Slot-Belegung pro Entity fixiert. Ausnahmen 7 Slots: Assessment, Scraper, Projekt.
- **v1.3.3 (2026-04-16) — Projekt-Detailmaske Phase A–I:** `/projects/[id]` 676 → 2395 Zeilen. Tab-für-Tab-Ausbau (Übersicht/Gewerke-3-Tier-Akkordeon/Matching-6-Score/Galerie-Masonry/Dokumente-Profile „Projekt" 6 Kategorien/History 13 Events). 14 Drawers. Status-Dropdown 6 Werte. Projekttyp-agnostische Snapshot-Bar. Scraper-Source-Banner. `wiki/entities/projekt.md` neu.
- **v1.3.4 (2026-04-17) — Globaler Dok-Generator + Assessment-Spec-Sync v0.3:** Siehe TEIL 22 unten.
- **v1.3.5 (2026-04-17) — Reminders-Vollansicht (Tool-Maske 3):** Neue `/reminders`-Maske ergänzt Dashboard-Widget + Entity-Tabs (Kandidat §10, Account §13). Liste + Kalender, Scope `self/team/all` via `dim_mitarbeiter.vorgesetzter_id`, Saved-Views in `dashboard_config.reminders` (JSONB, max 10), Drag-to-Reschedule. DB v1.3.5: `fact_reminders.template_id` FK + `escalation_sent_at`. Backend v2.5.5: 2 Events (`reminder_reassigned`, `reminder_overdue_escalation`) + 1 Worker (`reminder-overdue-escalation.worker.ts` hourly) + 3 Endpoints (`reassign`, `GET/PATCH user-preferences/reminders`). Lifecycle-Events via `fact_audit_log` `entity_updated`-Pattern. Siehe TEIL 23 unten.
- **v1.3.6 (2026-04-17) — Mobile/Tablet-Support Rewrite:** FRONTEND_FREEZE §24b neu — alte „Tablet Read-Only + Mobile Blocker"-Regel entfernt, voller Mobile-+-Tablet-Support. Breakpoints Desktop > 960 / Tablet 641–960 / Mobile ≤ 640. crm.html responsive-Shell (Top-Bar + Slide-Out), crm-mobile.html Device-Demo (3 iframes), editorial.css global Mobile-Rules, pro-Mockup-Fixes. Viewport-Meta in 22 Mockups. Keine DB-/Backend-Änderungen. Siehe TEIL 24 unten.

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
- **Database §14.3** — `fact_documents` Erweiterung (5 neue Felder: `generated_from_template_id`, `generated_by_doc_gen`, `params_jsonb`, `entity_refs_jsonb`, `delivery_mode`, `email_recipient_contact_id`)
- **Backend §L** — 9 neue Endpoints unter `/api/v1/document-templates/*` + `/api/v1/documents/generate,resolve-placeholders,regenerate,email` + `/api/v1/document-generator/recent,drafts`; Wrapper-Mapping bestehender Endpoints
- **Frontend §4e** — Neue Detailmaske-Spec `/operations/dok-generator` mit 5-Step-Workflow, 280px Sidebar, WYSIWYG-Editor

**22.3 Assessment-Spec-Sync v0.2 → v0.3**

Parallel zur Dok-Generator-Spec wurde Assessment-Detailmaske-Spec gesynct:
- **Order-Status `invoiced` entfernt** aus `fact_assessment_order.status` ENUM (`SCHEMA_v0_3` + `INTERACTIONS_v0_3`) — Rechnungs-Bezahl-State lebt auf `fact_assessment_billing.status`, nicht Order-Level
- **Phase-1-Typen-Kommentar** in Assessment-Schema §0 ergänzt — Mockup/Launch nutzt nur MDI/Relief/ASSESS 5.0/EQ Test (SCHEELEN-Produkte)
- **Database §14.3** — ENUM-Fix + Migration-Pfad (`UPDATE fact_assessment_order SET status='fully_used' WHERE status='invoiced';`)

**22.4 Spec-Sync-Status**

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

**22.5 Wiki-Einträge (ausstehend P1)**
- `wiki/concepts/dok-generator.md` — Architektur-Konzept
- `wiki/concepts/executive-report.md` — Arkadium-Assessment-Zusammenfassung
- `wiki/concepts/template-versionierung.md` — Phase 2 Semver-Pattern

**22.6 Mockup-Scope Phase 1**

5 Seed-Templates mit vollem Canvas-Content:
1. `mandat_offerte_target` (Mandat-Offerte mit Honorar-Tabelle, Garantiefrist)
2. `rechnung_mandat_teilzahlung_1_sie` (RE-2026-0118 Format)
3. `assessment_offerte` (Credits-Tabelle mit Paket-Pauschale)
4. `ark_cv` (Kandidaten-CV mit Werdegang)
5. `executive_report` (Arkadium-Auswertung mit manuellen Feldern)

33 weitere Templates als Library-Cards sichtbar, Canvas-Content Phase 2.

**22.7 Offene Folge-Tasks**

| # | Task | Phase |
|---|------|-------|
| 1 | DOCX-Template-Parser (Placeholder-Auto-Extraktion aus Ursprungs-DOCX) | 1.5 |
| 2 | PDF-Render-Engine-Wahl (WeasyPrint vs Chromium Headless) + Integration | 1.5 |
| 3 | Template-Admin-UI (CRUD `dim_document_templates`) | 2 |
| 4 | EN-Sprach-Support via LLM-Übersetzung | 2 |
| 5 | Draft-Auto-Save mit `fact_document_drafts` Tabelle | 2 |
| 6 | Template-Version-Management (Semver + Rollback) | 2 |

### Spec-Sync-Regel (TEIL 21)

Bidirektional: Änderung an 1 der 5 Grundlagendateien ↔ alle 9 Detail-Specs prüfen. Umgekehrt ebenso. Trigger-Matrix z.B. „Neues Feld in UI" → DB-Schema+Backend · „Neue ENUM-Werte" → Stammdaten+DB-Schema(CHECK) · „UI-Pattern-Änderung" → Frontend-Freeze+Gesamtsystem-Changelog. Bei PR explizite Bestätigung: „Grundlagendateien synchron? ✓/✗". Details: `wiki/meta/spec-sync-regel.md`.

---

## Pointer to full source

Für Prosa-Details jeweils Quelle lesen: `Grundlagen MD/ARK_GESAMTSYSTEM_UEBERSICHT_v1_3.md`:

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

**Verwandte Wiki-Konzepte:**
- [[status-enum-katalog]] · [[mandat-kuendigung]] · [[direkteinstellung-schutzfrist]] · [[optionale-stages]] · [[diagnostik-assessment]]
- [[interaction-patterns]] (§4 Drawer-Default, §14 Datum-Eingabe, §14a Briefing vs. Stellenbriefing)
- [[design-system]] (§3.2b Snapshot-Slot-Allokation)
- [[spec-sync-regel]]
- [[grundlagen-changelog]]
- [[rbac-matrix]]

---

### TEIL 23 — v1.3.5 Reminders-Vollansicht (2026-04-17)

**23.1 Neue Tool-Maske `/reminders`**
- 3. Tool-Maske neben `/operations/dok-generator` und `/operations/email-kalender`
- Ergänzt — ersetzt nicht — Dashboard-Widget + Entity-Reminder-Tabs (Kandidat §10, Account §13)
- **Layout:** Banner · KPI-Strip (6) · Saved-Views-Chips · View-Toggle (Liste/Kalender) · Filter-Bar · Status-Chip-Tabs (Liste-only) · Main · 2 Drawer (Detail 5-Tab, Neu)
- **View-Modi:** Liste mit Section-Groups (Überfällig/Heute/Woche/Später/Erledigt-30d) + Kalender CRM-intern (Monat/Woche, Drag-to-Reschedule)
- **Scope-Logik:** `self` (eigene) / `team` (`vorgesetzter_id`-direkte Reports) / `all` (tenant-weit). Switcher nur Admin/HoD sichtbar, AM/CM/RA/BO fix `self`
- **Saved Views:** rollen-spezifische System-Defaults + max 10 user-defined. Storage `dim_mitarbeiter.dashboard_config.reminders.saved_views[]` (JSONB, keine neue Tabelle)
- **Keine Bulk-Actions** (PO-Entscheidung — Sales würde durch-snoozen)
- **Auto-Regeln** separat unter `/admin/reminder-rules` (nicht in dieser Maske)

**23.2 Neue Grundlagen-Entries**
- **Database v1.3.5** — `fact_reminders.template_id uuid FK → dim_reminder_templates(id)` + `escalation_sent_at timestamptz` (Idempotenz 48-h-Eskalation). `dim_mitarbeiter.dashboard_config`-Kommentar mit JSONB-Substruktur für Reminders-Saved-Views
- **Backend v2.5.5** — 2 Events (`reminder_reassigned`, `reminder_overdue_escalation`) + 1 Worker (`reminder-overdue-escalation.worker.ts`, hourly 08–20h) + 3 Endpoints (`POST /reminders/:id/reassign`, `GET/PATCH /user-preferences/reminders`). Lifecycle-Events (create/complete/snooze/update) via `fact_audit_log` `entity_updated`-Pattern
- **Frontend v1.10.5** — §Reminders erweitert (Tool-Maske-Einordnung, Scope-Switcher, View-Modi, Saved-Views-Storage, Endpoints, Entity-Tab-Deep-Link-Kontrakt, Keyboard-Shortcuts N/V/E/S/R/J/K/1–6)
- **Stammdaten v1.3 unverändert** (§64 `dim_reminder_templates` passt 1:1)

**23.3 Neue Spec-Dokumente**
- `specs/ARK_REMINDERS_VOLLANSICHT_PLAN_v0_1.md` — Ausarbeitungsplan Phase 0–5 + 7 Phase-0-Entscheidungen
- `specs/ARK_REMINDERS_VOLLANSICHT_SCHEMA_v0_1.md` — Layout, Design-Tokens, Permissions, Empty-States (16 §)
- `specs/ARK_REMINDERS_VOLLANSICHT_INTERACTIONS_v0_1.md` — Flows, Events, Permissions-Matrix, Keyboard (14 §)

**23.4 Neuer Mockup**
- `mockups/reminders.html` — Liste + Kalender (Monat + Woche), Drag-to-Reschedule live, 2 Drawer (Detail 5-Tab, Neu), Keyboard-Shortcuts

**23.5 Entity-Tab-Harmonisierung (Deep-Link-Kontrakt)**
- `candidates.html` Tab 10 + `accounts.html` Tab 13 Footer: `→ Alle Reminders` → `/reminders?entity=<type>&id=<uuid>`
- `dashboard.html` Reminder-Widget-Link: `/reminders?scope=self&status=all`
- `crm.html` Sidebar: Reminders-Link aktiviert (`reminders.html`)
