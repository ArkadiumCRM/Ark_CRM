---
title: "History-System"
type: concept
created: 2026-04-08
updated: 2026-04-08
sources: ["ARK_GESAMTSYSTEM_UEBERSICHT_v1_2.md", "ARK_DATABASE_SCHEMA_v1_2.md"]
tags: [concept, history, activities, tracking]
---

# History-System

Zentrale Aufzeichnung aller menschlichen Interaktionen + systemseitigen Status-Ereignisse. 64 Activity Types in 11 Kategorien (6 davon auto-logged, darunter #64 Schutzfrist Status-Änderung für Claim-Workflow).

## Tabelle

`fact_history` — verknüpft mit Kandidat, Account, Kontakt, Job, Prozess, Mandat. Enthält Call-Daten (Richtung, Transkript, Sentiment), Email-Daten (Subject, Body), AI-Felder (Summary, Action Items, Red Flags).

## 11 Kategorien (61+ Typen)

| Kategorie | Anzahl | Beispiele |
|-----------|--------|----------|
| Kontaktberührung | 6 | Anruf, Email, Nachricht |
| Erreicht | 15 | Briefing, GO, NIC (Not Interested Currently) |
| Emailverkehr | 11 | Gesendet, Empfangen, Template |
| Messaging | 3 | WhatsApp, LinkedIn, SMS |
| Interviewprozess | 7 | TI, 1.-3. Interview, Assessment |
| Placementprozess | 3 | Offer, Placement, Cancellation |
| Refresh | 3 | Kontaktpflege |
| Mandatsakquise | 4 | Erstkontakt, Präsentation, Offerte |
| Erfolgsbasis | 2 | AGB Verhandlungen, AGB bestätigt |
| Assessment | 4 | Einladung, Durchführung, Ergebnisse |
| System | 5 | Auto-generiert, Stage Change |

## Klassifizierungs-Status

| Status | Bedeutung |
|--------|-----------|
| `pending` | Noch nicht klassifiziert |
| `ai_suggested` | AI hat Vorschlag gemacht |
| `confirmed` | Mensch hat bestätigt |
| `manual` | Manuell klassifiziert |

## Eskalation bei unklassifizierten Einträgen

1. Sofort: Gelber Badge mit Zähler auf Dashboard
2. 24h: Reminder an zuständigen CM
3. 48h: Notification an Head_of
4. Wöchentlich: KPI-Report

## Related

- [[event-system]] — fact_history vs. fact_event_queue vs. fact_audit_log
- [[automationen]] — Template-Email → Auto-Klassifizierung
- [[ai-system]] — AI-Vorschläge für Activity Types
- [[debuggability]] — Kombinierte Event-Timeline
