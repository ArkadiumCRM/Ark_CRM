---
title: "Referenzauskunft Vorlage + Gesprächsleitfaden"
type: source
created: 2026-04-12
updated: 2026-04-12
sources: ["General/3_Candidate Management/Referenzauskunft/Vorlage_Referenzauskunft.docx", "General/3_Candidate Management/Referenzauskunft/Gesprächsleitfaden_Referenzinterview.pdf"]
tags: [source, referenz, kandidat, qualifizierung]
---

# Referenzauskunft Vorlage + Gesprächsleitfaden

**Dateien:**
- `raw/General/3_Candidate Management/Referenzauskunft/Vorlage_Referenzauskunft.docx`
- `raw/General/3_Candidate Management/Referenzauskunft/Gesprächsleitfaden_Referenzinterview.pdf`

## Zweck

Strukturierte Referenzeinholung im Mandats-Prozess zur Validierung von Interview-/Assessment-Eindrücken. Zusatzquelle, nicht Interview-Ersatz.

## 5 Kompetenzbereiche (roter Faden)

1. **Fachkompetenz** — Wissen, Erfahrung, technisches Können
2. **Methodenkompetenz** — Denken, Planen, Entscheiden
3. **Sozialkompetenz** — Zusammenarbeit, Kommunikation, Wirkung
4. **Führungskompetenz** — Zielführung, Motivation, Entwicklung (nur Leitungsfunktion)
5. **Persönliche Kompetenz** — Selbstmanagement, Integrität, Belastbarkeit

Antworten qualitativ + quantitativ (Skala / Benchmark).

## Verwendung

- Vertraulich, nur für interne Mandats-Entscheidungen
- Einholung üblicherweise in Stage 3 (Vertragswesen) der Mandatsofferte

## CRM-Implikationen

- Template `dim_dokument_templates.type = 'Referenzauskunft'`
- Erfassung über Formular mit 5 Kompetenz-Sektionen → strukturierte Ablage am Kandidaten
- Bereits Felder im Datenmodell? Prüfen ob `fact_candidate_references` existiert (siehe [[database-schema]])

## Related

[[assessment]], [[rekrutierungsprozess]], [[kandidat]], [[dokumente]]
