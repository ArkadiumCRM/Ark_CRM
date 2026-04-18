---
title: "Assessment"
type: concept
created: 2026-04-08
updated: 2026-04-08
sources: ["ARK_GESAMTSYSTEM_UEBERSICHT_v1_2.md", "ARK_DATABASE_SCHEMA_v1_2.md", "ARK_FRONTEND_FREEZE_v1_9.md"]
tags: [concept, assessment, personality, analytics]
---

# Assessment

Persönlichkeits- und Kompetenzanalysen für Kandidaten.

## Assessment-Typen

| Typ | Tabelle | Beschreibung |
|-----|---------|-------------|
| DISC | `fact_assessment_disc` | Persönlichkeitsprofil (D/I/S/C) |
| Motivatoren / Driving Forces | `fact_assessment_driving_forces` | 12 Antriebskräfte |
| EQ | `fact_assessment_eq` | Emotionale Intelligenz (5 Dimensionen) |
| Relief | `fact_assessment_stressoren` | Stressoren, Treiber, Coping |
| ASSESS 5.0 | `fact_assessment_outmatch` | Kompetenz-Assessment |
| Human Needs / BIP | `fact_assessment_human_needs_bip` | Bedürfnisse + BIP-Dimensionen |
| Ikigai | `fact_assessment_ikigai` | 4 Felder + Schnittmengen |
| Resilienz | `fact_assessment_resilienz` | Resilienz + Burnout-Risiko |
| Motivation | `fact_assessment_motivation` | Sinn, Motivation, Energie |

**Jeder Typ individuell versioniert.**

## Scheelen-Import

Assessment-Ergebnisse per CSV-Import:
1. Backoffice lädt CSV hoch
2. System: Dry-Run (Vorschau)
3. Backoffice bestätigt
4. Daten in Assessment-Tabellen
5. Auto History-Eintrag "Assessment - Ergebnisse erfasst"

Endpunkt: `POST /api/v1/assessments/import-scheelen`

## Visualisierungen (18 Chart-Typen)

| Library | Chart-Typen |
|---------|------------|
| Recharts | Bar, Spider/Radar, Line |
| D3/Custom SVG | Ring-Diagramm (DISC), Venn, Gauges, Teamrad, Histogramm |

## Frontend — 6 Sub-Tabs

1. **Gesamtüberblick** — Alle Ergebnisse zusammengefasst
2. **Scheelen & Human Needs** — Detailansicht
3. **App** — Assessment via App (eigenes Projekt)
4. **AI-Analyse** — Cross-Analysis über alle Assessment-Daten
5. **Vergleich** — 2-8 Kandidaten nebeneinander
6. **Teamrad** — Team-Zusammensetzungsanalyse

## Teamrad

Auch auf Account-Ebene verfügbar (Tab 10): Analyse aller platzierten Kandidaten eines Accounts. AI-Empfehlungen für Team-Ergänzungen, Gap-Analysis, PDF-Export.

## Related

- [[kandidat]] — Tab 4: Assessment
- [[account]] — Tab 10: Teamrad
- [[ai-system]] — Cross-Analysis
