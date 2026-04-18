---
title: "ARK Job Detailmaske Interactions v0.1"
type: source
created: 2026-04-13
updated: 2026-04-13
sources: ["ARK_JOB_DETAILMASKE_INTERACTIONS_v0_1.md"]
tags: [source, job, interactions, lifecycle, matching, scraper-proposal]
---

# ARK Job Detailmaske Interactions v0.1

**Datei:** `specs/ARK_JOB_DETAILMASKE_INTERACTIONS_v0_1.md`
**Status:** v0.1 = Erstentwurf, Review ausstehend
**Begleitdokument:** [[job-schema]] v0.1

## Kern-Flows

- **Scraper-Proposal-Confirmation:** Drawer mit Scraper-extrahierten Feldern → AM bestätigt → Status `vakanz`
- **Status-Pipeline:** linear mit Pflicht-Validierungen (Gehaltsrahmen, Function, Location bei `vakanz → aktiv`)
- **Matching-Recompute:** async Batch bei Kriterien-Änderung, Loading-State im Tab-Badge
- **Jobbasket-Tab = Read-Only:** operative Verwaltung bleibt in Kandidat Tab 5, hier nur Pipeline-Übersicht
- **Matching-Tab = Operatives Sourcing:** Slide-in mit Radar-Chart, "+ In Jobbasket"-Bulk-Action, "Nicht relevant" Exclusion
- **Auto-Job-Fill:** bei Prozess-Placement wird Job `besetzt`, Stellenplan-Position aktualisiert, andere offene Prozesse bekommen Warn-Banner
- **Scraper-Monitoring:** erkennt wenn Job auf Website verschwindet → Event `job_disappeared_from_source`

## Matching-Algorithmus

7 Sub-Scores × konfigurierbare Gewichte aus `dim_matching_weights`:
- Sparte, Function, Salary, Location, Skills (mit Hard-Skills-Gate), Availability, Experience
- Gesamt-Score 0–100, Default-Schwelle 60

## Event-Katalog (15)

job_created_manual / _from_scraper / _from_mandate / _from_org_position, scraper_proposal_confirmed / _rejected, status_changed, description_updated, salary_range_changed, matching_criteria_updated, matching_recomputed, candidate_proposed_via_matching, stellenausschreibung_generated, job_filled, job_closed, job_rejected_after_vakanz.

## Verknüpfungen

- Account (Parent, immer)
- Mandat (optional, 1:1 oder Taskforce N:1)
- Kandidaten via `fact_candidate_jobbasket` + `fact_process_core` + `fact_candidate_matches`
- Stellenplan-Position (bidirektional)
- Scraper (Source-Tracking)

## Verlinkte Wiki-Seiten

[[job-schema]], [[job]], [[matching]], [[jobbasket]], [[scraper]], [[event-system]], [[berechtigungen]], [[detailseiten-guideline]]
