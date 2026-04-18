---
title: "Briefing"
type: concept
created: 2026-04-08
updated: 2026-04-08
sources: ["ARK_GESAMTSYSTEM_UEBERSICHT_v1_2.md", "ARK_KANDIDATENMASKE_SCHEMA_v1_2.md", "ARK_KANDIDATENMASKE_INTERACTIONS_v1_2.md"]
tags: [concept, briefing, kandidat, ai]
---

# Briefing

Strukturiertes Interview-Protokoll pro [[kandidat]]. Unbegrenzt versioniert — jedes neue Briefing-Gespräch erzeugt eine neue Version.

## Tabelle

`fact_candidate_briefing` — versioniert, verknüpft mit Kandidat.

## 9 Sektionen

| Sektion | Felder (Beispiele) | Synced |
|---------|--------------------|--------|
| **Gehalt & Vergütung** | Aktuell/Schmerzgrenze/Ziel, Lohnzusammensetzung (Fix, STI, LTI, Spesen), Total Compensation, Benefits | ✅ → Übersicht |
| **Arbeit & Verfügbarkeit** | Pensum aktuell/gewünscht, Anstellungssituation, Kündigungsfrist, Wechselmotivation | ✅ → Übersicht |
| **Mobilität** | Transportmittel, Arbeitsweg max, Umzugsbereitschaft, Homeoffice aktuell/gewünscht, Regionen | ✅ → Übersicht |
| **Bewertung** | A/B/C-Note, Freitext, GO-Themen, NO-GO-Themen | ✅ → Übersicht |
| **Kompetenzen** | Hardskills, Social Skills, Methodenkompetenz, Führungskompetenz | ✅ → Übersicht |
| **Persönlichkeit** | Selbstbild, Fremdbild, Intrinsische Motivation, Bedürfnisanalyse, Triggerpunkt, Moderation | |
| **Zonen-Modell** | Komfort/Lern/Wachstum/Angst-Zone + Sweet Spot | |
| **Privat** | Zivilstand, Kinder, Privates & Leidenschaft | |
| **Sonstiges** | Offene Bewerbungen, andere PDL, Verpflichtungen (Art, Betrag, Dauer) | |

Plus: **Besprochene Projekte** — verknüpft mit `dim_projects` via `bridge_briefing_projects`.

## AI Auto-Fill

Bei Briefing-Calls wird das Transkript automatisch verarbeitet:

```
Call → Transkription → AI-Summary → Auto-Fill Briefing-Felder
```

Banner: "AI hat 12 Felder aus dem Briefing-Transkript vorausgefüllt. Bitte prüfen und bestätigen."

Der Consultant **muss** die vorausgefüllten Felder bestätigen (AI schreibt nie direkt).

## Salary Benchmark

Automatisch angezeigt aus `dim_salary_benchmark` — P25/P50/P75/P90 nach Function/Cluster/Region/Experience.

## Profil-Vollständigkeit

Briefing hat das höchste Gewicht (30%) in der Profil-Vollständigkeitsberechnung:
- Stammdaten: 20%
- Verknüpfungen: 15%
- **Briefing: 30%**
- Werdegang: 20%
- Dokumente: 15%

## Automationen

- **Erstes** Briefing gespeichert → Kandidat-Stage: **Premarket** (nur wenn Kandidat noch in Check/Refresh)
- Rebriefing → Stage bleibt unverändert (Kandidat in Active Sourcing oder höher bleibt dort)
- Briefing gespeichert → Mandate Research: **briefing**
- Briefing-Felder synced → Übersicht-Tab "Briefing-Eckdaten" aktualisiert

## Section Navigation

Rechte Sidebar mit Completion % pro Sektion + Jump Links.

## Related

- [[kandidat]] — Tab 2: Briefing
- [[ai-system]] — Auto-Fill aus Transkripten
- [[telefonie-3cx]] — Call → Transkript → Briefing Pipeline
- [[automationen]] — Briefing-Trigger
- [[matching]] — Briefing-Daten als Matching-Input
