---
title: "Longlist / Research"
type: concept
created: 2026-04-08
updated: 2026-04-08
sources: ["ARK_GESAMTSYSTEM_UEBERSICHT_v1_2.md", "ARK_DATABASE_SCHEMA_v1_2.md"]
tags: [concept, longlist, research, mandate]
---

# Longlist / Research

Die Research-Pipeline innerhalb eines [[mandat|Mandats]]. Der RA baut eine Longlist auf und arbeitet Kandidaten durch.

## Tabelle

`fact_mandate_research` — Tracking pro Kandidat pro Mandat.

## Research-Flow

```
Research → Nicht erreicht (NE) → CV Expected → CV IN → Briefing → GO mündlich → GO schriftlich
```

### Weitere Stages

- **Nicht mehr erreichbar** — Kein Kontakt mehr möglich
- **NIC** (Not Interested Currently) — Kein aktuelles Interesse
- **Dropped** — Aus der Longlist genommen
- **Ghosted** — Auto nach Fristablauf, kein Feedback
- **Rejected Oral/Written GO** — Abgelehnt

### Locking

Ab "CV IN" sind Stages **gesperrt** — nur Automationen können ändern.

## Übergreifende Synchronisierung

Alle Kandidaten in einer Longlist erhalten bei relevanten History-Einträgen automatisch Stage-Updates:

| Kandidaten-Event | Longlist-Update |
|-------------------|----------------|
| NIC | → rejected |
| Dropped | → dropped |
| CV-Upload | → cv_in |
| Briefing gespeichert | → briefing |
| Email "Mündliche GOs" | → go_muendlich |
| Schriftlicher GO | → go_schriftlich |

## Frontend (Mandat Tab 2)

- **Kanban-Board** mit 10 Spalten oder **Listenansicht**
- Drag & Drop
- **"Durchcall-Funktion"** für Researchers: Nächster höchstprioritierter Kandidat
- Bulk Actions

## KPIs

- Ident Target vs. Actual
- Call Target vs. Actual
- Shortlist-Trigger (konfigurierbar)

## Related

- [[mandat]] — Longlist gehört zu einem Mandat
- [[kandidat]] — Kandidaten in der Longlist
- [[automationen]] — Synchronisierung Kandidat ↔ Longlist
