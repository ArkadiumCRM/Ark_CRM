---
title: "HR · Arbeitszeugnisse + Arbeitsbestätigung Templates"
type: source
created: 2026-04-19
updated: 2026-04-19
sources: [
  "raw/HR/2_HR On- Offboarding/6_Arbeitszeugnisse & Arbeitsbestätigungen/DRUCK_Arbeitsbestätigung.docx",
  "raw/HR/2_HR On- Offboarding/6_Arbeitszeugnisse & Arbeitsbestätigungen/DRUCK_Arbeitszeugnis Consultant.docx",
  "raw/HR/2_HR On- Offboarding/6_Arbeitszeugnisse & Arbeitsbestätigungen/DRUCK_Arbeitszeugnis Researcher.docx",
  "raw/HR/2_HR On- Offboarding/6_Arbeitszeugnisse & Arbeitsbestätigungen/Checkliste Arbeitszeugnis.pdf"
]
tags: [hr, phase-3, arbeitszeugnis, arbeitsbestaetigung, template, dokument-generator]
---

# HR · Arbeitszeugnisse + Arbeitsbestätigung

3 Output-Templates für MA-Austritt (Arbeitszeugnis-Pflicht nach OR Art. 330a). Texte sind Firmenbeschreibung + Platzhalter-Struktur, werden beim Generieren ausgefüllt.

## Templates

| Datei | Zweck | Verwendet bei |
|-------|-------|---------------|
| `DRUCK_Arbeitsbestätigung.docx` | **Kurz** — nur Bestätigung Anstellung · kein Leistungsurteil | kurze Dauer · auf Wunsch |
| `DRUCK_Arbeitszeugnis Consultant.docx` | **Voll** — Leistungs- + Verhaltensbeurteilung | Consultant-Rolle |
| `DRUCK_Arbeitszeugnis Researcher.docx` | **Voll** | Research Analyst · Junior Consultant |
| `Checkliste Arbeitszeugnis.pdf` | QA-Checkliste (PDF, **leer extrahiert** → Scan ohne Text-Layer, OCR nötig) | Review-Phase |

## Template-Struktur Arbeitszeugnis

1. **Firmenbeschreibung Arkadium** (3 Absätze: Executive Search + HQ/RPO + 4 Fachbereiche · Arbeitgebermarke · Methodenmix Direktansprache + Rhetorik)
2. **Anstellungsdaten** (Platzhalter): `NAME MITARBEITER, geboren am XX, war vom XX bis XX als FUNKTION angestellt, Beschäftigungsgrad XX%`
3. **Arkadium Academy Einführung** (interdisziplinäre Handlungskompetenzen aus Psychologie · Soziologie · Marketing · Kommunikation)
4. **Theoretisches Wissen** (Architektur · Rhetorik · Humankompetenzen · HR-Themen · Verhandlungsführung · Fragetechniken · psychologische Konzepte)
5. **Headhunting + Executive Search Einblick**
6. **AUFGABENGEBIET & Tätigkeit:** — Bullet-Liste aus Progressus
7. **Leistungs- + Verhaltensurteil** (bei Vollzeugnis; bei Arbeitsbestätigung ausgelassen)
8. **Austrittsgrund** + Wünsche
9. **Ort + Datum + Unterschrift**

## Delta Zeugnis vs Bestätigung

| Element | Zeugnis | Bestätigung |
|---------|---------|-------------|
| Firmenbeschreibung | ✓ | ✓ |
| Anstellungsdaten | ✓ | ✓ |
| Academy | ✓ (ausführlich) | ✓ (knapp) |
| Aufgabengebiet | ✓ detailliert | nicht nötig |
| Leistungsurteil | ✓ | **✗** |
| Verhaltensurteil | ✓ | **✗** |
| Austrittsgrund | ✓ | ✓ neutral |
| Wünsche | ✓ | ✓ |

**Arbeitsbestätigungs-Standardklausel:** "Aufgrund der kurzen Dauer des Arbeitsverhältnisses können wir die Leistung von XXX nicht vollständig beurteilen."

## Platzhalter im Template (Dok-Generator-Relevanz)

- `NAME MITARBEITER` / `XXX` / `[HERR / FRAU XY]`
- `FUNKTION`
- Datum von/bis
- Beschäftigungsgrad
- `SEINER / IHRER` + `SIE / ER` (Genus-Handling)
- Austrittsgrund-Textbaustein
- Direkter Vorgesetzter (Signator) + Nenad Stoparanovic (Co-Signator)

## Key Takeaways für HR-Tool + Dok-Generator

1. **Arbeitszeugnis-Generator** (Plan §7.3 Drawer **760px wide-tabs**):
   - Template-Selektor: Zeugnis vs Bestätigung
   - Rolle-Selektor: Consultant vs Researcher (je eigenes Boilerplate)
   - Auto-fill aus `dim_mitarbeiter` + `fact_employment_contracts` + `fact_onboarding_instances` (Academy-Phase) + `fact_employee_certifications`
   - Genus-Toggle (Er/Sie)
   - Leistungs-/Verhaltens-Editor (Textblöcke aus Checkliste, falls OCR-bar)
2. **Checkliste-PDF** → via OCR lesbar machen (Tesseract oder Azure Form Recognizer) · sonst manuell tippen
3. **Output:** `fact_hr_documents.document_type = 'arbeitszeugnis' | 'arbeitsbestaetigung'` (Plan §6.2 bereits)
4. **Phase-Zuordnung:** Plan v0.1 verortet Arbeitszeugnis-Generator in **Phase 3.6 (optional)**. Hauptstruktur bereits klar.

## Offene Frage

Wo wohnt die **Textbaustein-Bibliothek** für Leistungs-/Verhaltens-Formulierungen? Eigene `dim_reference_phrases` oder als Templates in Dok-Generator? → Abklärung mit Peter.

## Related

- [[hr-stellenbeschreibung-progressus]] · [[hr-academy]]
- `specs/ARK_DOK_GENERATOR_SCHEMA_v0_1.md` (Dok-Generator Framework)
- [[hr-schema-deltas-2026-04-19]]
