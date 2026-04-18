---
title: "Reportings (AM / CM / TL / Hunt)"
type: source
created: 2026-04-12
updated: 2026-04-12
sources: ["General/5_Reportings/*.pdf", "General/5_Reportings/Reporting Hunt.docx"]
tags: [source, reporting, am, cm, teamleader, hunt, kpi]
---

# Reportings (AM / CM / TL / Hunt)

**Verzeichnis:** `raw/General/5_Reportings/`

## AM Reporting Fokus (PDF)

Wochentags-Matrix (Montag–Freitag) über die KW, zwei Spalten:

| Einkauf | Verkauf |
|---------|---------|
| Job & Account Hunt | Account Coaching |
| Job & Account Briefing | Update Gespräch |
| Term & Konditionen Besprechung | Debriefing |
| | Candidate Pitch |
| | Abschlussgespräch |
| | After Sales |

Je Zelle: `erreicht / nicht erreicht / AVs Total`.

## CM Reporting Fokus (PDF)

Analog für Candidate Manager:

| Einkauf | Verkauf |
|---------|---------|
| Hunt | Prelead & Go Termin |
| Doc Chase | Coaching |
| Refresh | Debriefing |
| Briefing / Debriefing | Placement Gespräch |
| Update Gespräch | After Sales |

## Team Leader Reporting (PDF)

**Monatliches Reporting mit Sektionen:**

1. **Datenbank** — Idents-Bestand am 1. Januar / Monatsbeginn / Ziel 31. Dezember + Wachstum
2. **Hunt Statistik / Quoten** — Angegangene Idents, AV, Not reachable/interested, CV Expected, CV IN, Priorisierung A/B/C, OI-Raten
3. **Fazit HUNT** — Narrativ: Massnahmen, Qualität, Schulungen, Opportunitätskosten
4. **Reminder** — Checkliste (Profile-Passung, Ident-Menge, Hunt-Timer)

## Hunt Monthly Reporting (DOCX)

**Datei:** `Reporting Hunt.docx` — Template für monatlichen Hunt-Bericht (Datenbank, Hunt-Statistik, Management Leader-Review).

## InDesign-Vorlagen (Monatsreporting CMs)

`Vorlagen_Indesigns/Monatsreporting CMs/` — grafisch aufbereitete Monats-PDFs (Februar/April 2024 Beispiele).

## CRM-Implikationen

- KPIs existieren **konzeptuell**, müssen als Dashboards im CRM materialisiert werden
- Reporting-Export: automatische PDF-Generierung aus `fact_history` + `fact_kpi_snapshots`?
- Wöchentliche AM/CM-Matrix = Aggregation über `fact_history.activity_type`
- TL Reporting = Aggregation über Mitarbeiter + Zeitraum
- Siehe [[history-system]], [[reminders]]

## Related

[[history-system]], [[reminders]], [[berechtigungen]]
