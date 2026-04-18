---
title: "ARK Projekt Detailmaske Interactions v0.1"
type: source
created: 2026-04-13
updated: 2026-04-13
sources: ["ARK_PROJEKT_DETAILMASKE_INTERACTIONS_v0_1.md"]
tags: [source, projekt, interactions, gewerke, beteiligungen, matching-projekt]
---

# ARK Projekt Detailmaske Interactions v0.1

**Datei:** `specs/ARK_PROJEKT_DETAILMASKE_INTERACTIONS_v0_1.md`
**Status:** v0.1 = Erstentwurf
**Begleitdokument:** [[projekt-schema]] v0.1

## Kern-Flows

- **Gewerk hinzufügen** (BKP-Autocomplete aus ~425 Codes) → Akkordeon-Panel mit Firmen-+Kandidaten-Beteiligungen
- **Firmen-Beteiligung**: Account-Autocomplete mit Hard-Stop "Als Account anlegen", Role + Summe + SIA-Phasen + Kommentar
- **Kandidaten-Beteiligung**: mit Employer-Account zum Zeitpunkt + SIA-Phasen + Verantwortungsgrad + Kommentar, optional Sync zu Kandidaten-Werdegang
- **Werdegang-Integration (Briefing):** Autocomplete gegen Projekt-DB, Confidence-Schwellen-basierter Match, bei No-Match Mini-Drawer "Neues Projekt anlegen"
- **Duplikat-Merge-Flow** mit Kollisions-Handling pro Feld, Kandidaten-Werdegänge werden umgehängt
- **Matching** async Batch-Compute + on-demand bei Klassifikations-Änderung

## Drei Erstellungs-Wege

1. Manuell (AM)
2. Aus Kandidat-Werdegang (Briefing-Autocomplete → neue Projekt-Entity)
3. Scraper (simap / Baublatt / TEC21 / Account-Referenz-Seiten)

## Cross-Entity-Integrationen

- **Kandidat**: Werdegang-Link + Auto-Sync zu `fact_project_candidate_participations`
- **Account**: beteiligte Firmen in `fact_project_company_participations`, AM-Notizen pro Account via `fact_account_project_notes`
- **Mandat/Job (optional)**: `linked_project_id` für Kontext-Bezug
- **Scraper**: Finding-Type `project_detected` landet in Review-Queue

## Matching-Algorithmus

Gewichtete Summe aus: Cluster-Überlappung, BKP-Erfahrung, SIA-Phase-Abdeckung, Volumen-Ähnlichkeit, Geografie-Proximität, Recency-Bonus.

## 13 Events dokumentiert

Inkl. `account_project_note_added` (pro Account-Kontext), `candidate_participation_added` (mit Employer-Account-Snapshot), `bauherr_changed`.

## Verlinkte Wiki-Seiten

[[projekt-schema]], [[projekt-datenmodell]], [[stammdaten]], [[kandidat]], [[account]], [[mandat]], [[job]], [[scraper]], [[event-system]], [[detailseiten-guideline]]
