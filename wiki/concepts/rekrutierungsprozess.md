---
title: "Rekrutierungsprozess"
type: concept
created: 2026-04-08
updated: 2026-04-08
sources: ["ARK_GESAMTSYSTEM_UEBERSICHT_v1_2.md"]
tags: [concept, process, core, business-logic]
---

# Rekrutierungsprozess

Der End-to-End-Flow einer Rekrutierung bei ARK — von der ersten Kontaktaufnahme bis zur Platzierung.

## Zwei Geschäftsmodelle

| Modell | Beschreibung | Honorar |
|--------|-------------|---------|
| **Mit Mandat** | Formeller Auftrag (Target, Taskforce, Time) | Vertragsbasiert |
| **Erfolgsbasis** | Kein Mandat, proaktive Vorstellung | Gestaffelte Tabelle |

**Prozessablauf ist bei beiden identisch.** Der Unterschied: Bei Mandaten gibt es Longlist, KPI-Tracking und Mandat-spezifische Konditionen.

## Erfolgsbasis-Staffel

| Gehalt | Honorar |
|--------|---------|
| < 90k | 21% |
| < 110k | 23% |
| < 130k | 25% |
| ≥ 130k | 27% |

Pro Prozess individuell überschreibbar.

## Der Gesamtflow

```
1. SOURCING
   Kandidat identifiziert → Check → Erstansprache → Briefing

2. QUALIFIZIERUNG
   Briefing → Premarket → CV + Diplom + Zeugnis → Active Sourcing

3. GO-PROZESS
   GO-Termin → Preleads besprechen → Mündliche GOs → Schriftliche GOs

4. JOBBASKET & VERSAND
   Assigned (Gate 1) → To Send (Gate 2) → CV Sent / Exposé Sent

5. INTERVIEW-PIPELINE (= Prozess)
   Exposé → CV Sent → TI → 1.-3. Interview → Assessment → Angebot → Platzierung

6. POST-PLACEMENT
   Onboarding Call → 30/60/90-Tage Check-ins → Garantiefrist → Closed
```

## Gate-Checks

**Gate 1 (Assigned):** Automatisch wenn:
- Schriftlicher GO vorhanden
- CV hochgeladen
- Diplom hochgeladen
- Zeugnis hochgeladen

**Gate 2 (Versand):** Buttons erscheinen wenn:
- ARK CV oder Exposé vorhanden
- AGB-Check bei Erfolgsbasis (Warnung, kein Block)

**Versand erstellt automatisch einen [[prozess]].**

## Was automatisch passiert

| Aktion | Automation |
|--------|-----------|
| Briefing speichern | Stage → Premarket |
| CV + Diplom + Zeugnis + Briefing | Stage → Active Sourcing |
| Prozess erstellt | Stage → Market Now |
| NIC/Dropped/Ghosting nach CV Expected | Stage → Refresh (unabhängig ob Mandat oder nicht) |
| Alter >60 (Batch-Job) | Stage → Inactive (nie mehr kontaktieren) |
| Email "Mündliche GOs" | Jobbasket → oral_go |
| Schriftlicher GO eingeht | Jobbasket → written_go |
| CV-Upload | Mandate Research → cv_in |
| Placement | Job → Filled, Reminders erstellt |

## Was der Consultant MANUELL tun muss

- Activity-Type bestätigen (1-Klick)
- Dokumente hochladen
- Briefing-Maske ausfüllen
- Kandidat in Jobbasket legen
- Rejection-Gründe angeben
- AI-Empfehlungen bestätigen/ablehnen

## Was der Consultant NIE manuell tun muss

- Stage-Changes
- Prozess-Erstellung nach CV Sent
- Duplikat-Erkennung
- AI-Summaries
- Zuordnung Call/Email → Kandidat
- Gate-Prüfungen
- Template-basierte Email-Klassifizierung

## Related

- [[kandidat]] — Die Stages des Kandidaten
- [[jobbasket]] — Der GO-Flow im Detail
- [[prozess]] — Die Interview-Pipeline
- [[mandat]] — Mandats-spezifische Aspekte
- [[erfolgsbasis]] — Best-Effort-Modell
- [[automationen]] — Alle Trigger im Detail
