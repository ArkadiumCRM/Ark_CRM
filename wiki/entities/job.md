---
title: "Job"
type: entity
created: 2026-04-08
updated: 2026-04-16
sources: ["ARK_GESAMTSYSTEM_UEBERSICHT_v1_2.md", "ARK_DATABASE_SCHEMA_v1_2.md", "ARK_ACCOUNT_DETAILMASKE_INTERACTIONS_v0_1.md", "ARK_JOB_DETAILMASKE_SCHEMA_v0_1.md", "ARK_JOB_DETAILMASKE_INTERACTIONS_v0_1.md"]
tags: [entity, job, vakanz, core]
---

# Job

Eine offene Stelle bei einem [[account]]. Jobs sind der zentrale Anknüpfungspunkt für [[jobbasket]], [[prozess]] und [[mandat]].

## Datenbank

**Haupttabelle:** `fact_jobs` (operativ)

**Bridge-Tabellen:** `bridge_job_cluster/functions/focus/edv/education/sector/sparte`

## Felder

- Titel, Account (FK), Sparte, Ort
- Gehalt: `salary_min`, `salary_max` (CHF, CHECK min <= max)
- Pensum (z.B. 80-100%)
- Function/Focus-Verknüpfung (AI-Vorschlag)
- Vertraulichkeit, Exklusivität
- `confirmation_status` — Bestätigungsstatus (aus Vakanz konvertiert vs. direkt erstellt)
- `source` — Herkunft (manuell, scraper, referral, LinkedIn)
- `owner_account_manager_id` — Verantwortlicher AM (nicht CM!)
- Verknüpfung zu [[mandat]]

## Status

| Status | Beschreibung |
|--------|-------------|
| **Open** | Aktiv offen |
| **Filled** | Besetzt (auto bei Placement oder manuell) |
| **On Hold** | Pausiert |
| **Cancelled** | Abgebrochen |

**Manuell Filled** = "Extern besetzt" → wird separat getrackt.

## Vakanzen

> [!info] Vakanzen sind keine separate Entity
> Vakanzen leben als unbestätigte Einträge in `fact_jobs` mit entsprechendem `confirmation_status`. Sie werden vom [[scraper]] erkannt oder manuell/via Referral/LinkedIn erfasst.

**Flow:** Vakanz erkannt → AM bestätigt → wird zum vollwertigen Job promoted.

**`fact_vacancies` ist deprecated und wird gelöscht.** Migration: Alle existierenden Vakanzen werden nach `fact_jobs` mit `confirmation_status = 'Vakanz'` migriert.

> [!warning] Schema-Anpassung ausstehend
> Die Deprecation ist in Account Interactions v0.1 entschieden, aber DB Schema v1.2 und Backend Architecture v2.4 referenzieren `fact_vacancies` noch als aktive Tabelle. Diese Dokumente müssen aktualisiert werden.

## Automationen

- Placement eines [[prozess]] → Job automatisch auf "Filled"
- AI-Vorschlag für Function/Focus-Zuordnung
- Scraper erkennt neue Stellen → Vakanz in `fact_jobs`

## Tracking

- Jobs ohne ARK-Prozess besetzt = "Extern besetzt"
- Jobs mit Prozess aber ohne Placement = "Nicht platziert"

## Mockup-Status (`mockups/jobs.html`)

**Stand 2026-04-16** — Phase A–E abgeschlossen. 7-Tab-Detailmaske voll ausgebaut, design-system-konform mit accounts/candidates/mandates/groups.

### Tab-Struktur

| Tab | Inhalt | Status |
|---|---|---|
| 1 | Übersicht | 6 Sektionen: Stammdaten · Verknüpfungen · Stellenbeschreibung · Konditionen · Matching-Kriterien · Ausschreibung |
| 2 | Matching | Score-Slider 50–95 % · 7 Sub-Scores (Sparte/Funktion/Gehalt/Location/Skills/Verfügb./Seniorität) · SVG-Radar-Mini 44×44 pro Kandidat · Bulk „+ In Jobbasket" · Recompute-Banner · Sector-Exclude |
| 3 | Jobbasket | Read-mostly — Liste + Kanban · 5-Stages-Pipeline-Bar (Prelead/GO mündl./GO schriftl./Versandt/Gate offen) · Gate-Status-Chips · operative Verwaltung in [[kandidat]] Tab 5 |
| 4 | Prozesse | Job-gefiltert (WHERE job_id) · Job-Kontext-Banner · Pipeline/Tabelle-Switch |
| 5 | Dokumente | Profile „Job" · 5 Kategorien (siehe [[dokumente-kategorien]]) · Stellenausschreibung-Generator (DE/FR/IT/EN, Logo, Verdeckt-Toggle) · Matching-Export-Snapshots · Versionierung |
| 6 | History | Job-Lifecycle-Events: `scraper_proposal_created` · `vakanz_confirmed` · `status_changed` · `matching_computed` · `jobbasket_added` · `process_created` · `placed` · `closed` + Standard-Activity-Types §14 |
| 7 | Reminders | Stage-Deadline · Vakanz-Bestätigung · Matching-Refresh · Schließungs-Check · Stellenausschreibung-Update · Follow-up |

### Header-Specials (Phase D)

- **Scraper-Proposal-Banner**: Roter Banner oben für `status=scraper_proposal` mit „✓ Vakanz bestätigen" / „✕ Ablehnen" / „Später"
- **Snapshot-Bar sticky** (6 Slots, dupe-frei zum Header): Matches ≥ 70 % · Im Jobbasket · Aktive Prozesse · Standort · TC-Range · Ø Match-Score
- **Status-Dropdown** 6 Werte: scraper_proposal · aktiv · on_hold · besetzt · geschlossen · abgelehnt
- **Mandat-Badge** klickbar zu [[mandat]]
- **Stellenplan-Referenz** Chip `📋 Stellenplan #PLN-<year>-<num>`
- **Quick-Action „📤 Kandidat vorschlagen"** (proposeDrawer — manuelle Jobbasket-Aufnahme ausserhalb Matching)

### Design-System-Konformität

- KPI-Strips: canonical `.kpi-strip.cols-N` · `.kpi-card.<color>` Modifier
- Drawer: 540px Standard + `.drawer-wide` 760px für History
- Alle Sprach-/Kategorie-Labels aus [[stammdaten]] abgeleitet
- Backup-Pattern: `backups/jobs.html.<timestamp>.bak`

## Related

- [[account]] — Job gehört zu einem Account (Tab 6: Jobs & Vakanzen)
- [[jobbasket]] — Kandidaten werden Jobs zugeordnet · operative Verwaltung in [[kandidat]] Tab 5
- [[prozess]] — Aus dem Jobbasket-Versand entsteht ein Prozess
- [[mandat]] — Jobs können unter einem Mandat laufen (Taskforce: mehrere Jobs)
- [[matching]] — AI-Matching Kandidat ↔ Job (7 Sub-Scores, Radar-Visualisierung)
- [[scraper]] — Automatische Vakanzen-Erkennung (→ Scraper-Proposal-Banner)
- [[dokumente-kategorien]] — Job-Profile (5 Kategorien)
- [[design-system]] — KPI-Strip, Drawer, Button-Patterns
- [[interaction-patterns]] — Drawer-Default, Datum-Eingabe, Terminologie
