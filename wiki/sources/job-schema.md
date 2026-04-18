---
title: "ARK Job Detailmaske Schema v0.1"
type: source
created: 2026-04-13
updated: 2026-04-13
sources: ["ARK_JOB_DETAILMASKE_SCHEMA_v0_1.md"]
tags: [source, job, schema, vakanz, matching, jobbasket, detailseite]
---

# ARK Job Detailmaske Schema v0.1

**Datei:** `specs/ARK_JOB_DETAILMASKE_SCHEMA_v0_1.md`
**Status:** v0.1 = Erstentwurf, Review ausstehend
**Begleitdokument:** [[job-interactions]] v0.1

## 6 Tabs

1. Übersicht — Stammdaten, Stellenbeschreibung (Markdown), Konditionen, Matching-Kriterien, Sichtbarkeit, Status-Abschluss
2. Jobbasket — Read-mostly Pipeline-Übersicht (operative Verwaltung lebt in Kandidat Tab 5)
3. Matching — 7-Sub-Score-Ranking (Sparte/Function/Salary/Location/Skills/Availability/Experience)
4. Prozesse — Prozesse `WHERE job_id = X`
5. Dokumente — Stellenausschreibung-Generator + Briefing-Uploads
6. History — Event-Stream inkl. Cross-Entity-Events

## Lifecycle

`scraper_proposal → vakanz → aktiv → besetzt → geschlossen` (+ `abgelehnt`)

## Schlüssel-Features

- **Scraper-Proposal-Confirmation** via amber Banner mit [Bestätigen/Ablehnen/Quelle ansehen]
- **Matching als operatives Tool** mit Radar-Chart pro Kandidat, Score-Schwelle-Slider, "+ In Jobbasket"-Bulk-Action
- **Stellenplan-Integration**: bidirektional verknüpft mit `fact_account_org_positions.linked_job_id`
- **Stellenausschreibung-Generator** als PDF mit ARK-Branding, Mehrsprachigkeit (DE/FR/IT/EN)
- **Async Matching-Recompute** bei Kriterien-Änderung mit Loading-State
- Snapshot-Bar 6 Slots (Basket/Prozesse/Matching/Gehalt/Erstellt/Placements)

## Erstellungs-Wege (4)

1. Scraper (Website-Vakanz-Detection)
2. Manuell am Account
3. Aus Mandat (Taskforce-Positionen, Target)
4. Aus Stellenplan-Position

## Neue DB-Felder

`fact_jobs` bekommt ~30 neue Felder (description_md, Matching-Kriterien, Benefits, publication_channels, etc.). `fact_candidate_matches` als N:N Tabelle mit 7 Sub-Scores.

## Verlinkte Wiki-Seiten

[[job]], [[job-interactions]], [[matching]], [[jobbasket]], [[scraper]], [[stammdaten]], [[detailseiten-guideline]]
