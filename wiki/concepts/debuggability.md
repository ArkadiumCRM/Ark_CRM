---
title: "Debuggability"
type: concept
created: 2026-04-08
updated: 2026-04-08
sources: ["ARK_GESAMTSYSTEM_UEBERSICHT_v1_2.md"]
tags: [concept, debugging, event-chain, audit]
---

# Debuggability — "Warum ist das passiert?"

Eines der grössten Risiken bei einem Event-getriebenen System: niemand kann nachvollziehen warum etwas passiert ist.

## Event-Timeline pro Entity

Jede Hauptentität (Kandidat, Account, Job, Mandat, Prozess) hat eine "Was ist passiert?"-Ansicht die drei Quellen zusammenführt:

1. **fact_history** — Was hat ein Mensch getan?
2. **fact_event_queue** — Was hat das System ausgelöst?
3. **fact_audit_log** — Was wurde konkret geändert? (Feld-Level)

## Timeline-Einträge zeigen

- Wer/Was hat ausgelöst (Mensch/System/Automation)
- Was war der Trigger (z.B. "Email-Template Mündliche GOs → Jobbasket oral_go → Mandate Research go_muendlich")
- Welche Felder geändert (alter Wert → neuer Wert)
- `correlation_id` zum Nachverfolgen von Event-Ketten

## Endpunkt

`GET /api/v1/entities/:type/:id/event-chain` — Alle drei Quellen zusammengeführt, chronologisch sortiert.

## Frontend

Eigener Tab oder Drawer pro Entity. Filter nach Quelle (History/Events/Audit). Besonders für Admins und Head_ofs bei Eskalationen.

## Related

- [[event-system]] — Die Event-Infrastruktur
- [[history-system]] — Menschliche Aktivitäten
- [[automationen]] — Was das System auslöst
