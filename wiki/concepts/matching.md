---
title: "Matching"
type: concept
created: 2026-04-08
updated: 2026-04-08
sources: ["ARK_BACKEND_ARCHITECTURE_v2_4.md", "ARK_DATABASE_SCHEMA_v1_2.md", "ARK_FRONTEND_FREEZE_v1_9.md"]
tags: [concept, matching, ai, scoring]
---

# Matching

AI-basiertes Matching zwischen [[kandidat|Kandidaten]] und [[job|Jobs]]. Kein Blackbox — alle Scores sind explainbar.

## 7 Sub-Scores (0-100)

| Dimension | Beschreibung |
|-----------|-------------|
| Sparte | ING/GT/ARC/REM/PUR Übereinstimmung |
| Function | Berufsfunktions-Match |
| Salary | Gehaltsvorstellung vs. Job-Range |
| Location | Standort + Mobilität + Arbeitsweg |
| Skills (Focus) | Fachliche Spezialisierungen |
| Availability | Verfügbarkeit + Kündigungsfrist |
| Experience | Erfahrungsjahre + Seniority |

**Gesamt-Score:** Gewichtete Kombination der 7 Sub-Scores.

## Datenbank

- `fact_match_scores` — Scores historisiert (mit `valid_from`/`valid_to`/`is_current`)
- `match_breakdown_json` — Detaillierter Breakdown pro Dimension

## Richtungen

- **Kandidat → Jobs:** Welche Jobs passen zu diesem Kandidaten? (Jobbasket Tab, AI-Vorschläge)
- **Job → Kandidaten:** Welche Kandidaten passen zu diesem Job? (Job-Detail, Longlist)

## Matching-Basis

Zieht aus dem gesamten Kandidatenprofil:
- Stammdaten (Sparte, Standort)
- [[briefing]] (Gehalt, Verfügbarkeit, Mobilität, GO/NO-GO Themen)
- Werdegang (Erfahrung, Stationen)
- [[assessment]] (DISC-Kompatibilität)
- Kompetenzen (Functions, Focus, EDV)
- [[projekt-datenmodell]] (BKP/SIA-Erfahrung)

## Frontend

### Jobbasket (Kandidat Tab 5)
- 3 AI-vorgeschlagene Jobs mit Match-Score
- Sub-Scores sichtbar (Gehalt/Funktion/Ort/DISC Match %)
- "Neu berechnen" Button
- "+ Als Prelead hinzufügen"

### Matching-Seite (/matching)
- Erreichbar via Deep Link
- Score 0-100 mit Breakdown
- Confidence Thresholds: ≥0.8 prominent, 0.5-0.8 normal, <0.5 Warning

## API-Endpunkte

- `GET /api/v1/matching/candidate-to-jobs/:candidateId`
- `GET /api/v1/matching/job-to-candidates/:jobId`
- `POST /api/v1/matching/recalculate`
- `GET /api/v1/matching/explain/:matchId`

## Related

- [[ai-system]] — Matching als AI-Feature
- [[jobbasket]] — AI-Vorschläge im Jobbasket
- [[kandidat]] — Matching-Basis: Profil, Briefing, Werdegang
- [[job]] — Matching-Ziel
