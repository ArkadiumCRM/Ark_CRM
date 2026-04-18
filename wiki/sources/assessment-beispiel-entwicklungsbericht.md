---
title: "Assessment-Beispiel: ASSESS 5.0 Entwicklungsbericht (Development)"
type: source
created: 2026-04-17
updated: 2026-04-17
sources: ["Entwicklungsbericht_[Kandidatin-A]_[anonymisiert].pdf"]
tags: [assessment, assess-5-0, scheelen, development, coaching, anonymisiert]
---

# Assessment-Beispiel: ASSESS 5.0 Entwicklungsbericht

Anonymisierter Development-Report als **Teil 2 der ASSESS 5.0 Trilogie** (13 Seiten). Basiert auf denselben Testergebnissen wie der Bewertungsergebnisse-Report, aber mit **coaching-orientiertem Fokus** statt Matching-Bewertung.

> Original-PDF in `raw/Assessments/` — enthält Personendaten (DSGVO Art. 9).

## Report-Zweck

**Bewertungsergebnisse** = "Wie gut passt die Person?" (Selektions-Sicht)
**Entwicklungsbericht** = "Wie kann die Person wachsen?" (Coaching-Sicht)

Beide nutzen dieselben 11 Kompetenzen und dieselben Scores, unterscheiden sich aber im Text-Inhalt.

## Report-Aufbau (13 Seiten)

### 1. Titelseite + Metadaten
Identisch zu Bewertungsergebnisse, Label "DEVELOPMENT" statt "IHR ASSESS BERICHT".

### 2. Gesamtübereinstimmungswert + Stärken/Entwicklungspotenzial
Identische Darstellung wie in Bewertungsergebnisse (Score, Top 3 Stärken, Top 3 Entwicklungspotenzial).

### 3. Development pro Kompetenz (11 Sektionen, je 1 Seite)

Für jede der 11 Kompetenzen (identisch wie Bewertungsergebnisse):
1. Beziehungsmanagement & Netzwerkaufbau
2. Entscheidungsfindung
3. Ergebnisorientierung
4. Führung
5. Kommunikationsfähigkeit
6. Konfliktmanagement
7. Lernagilität
8. Planungs- & Organisationsfähigkeit
9. Problemlösung
10. Resilienz
11. Überzeugungskraft

**Pro Kompetenz-Seite**:
- Kompetenz-Name + Score + Label
- **Entwicklung Tip** (2 konkrete Handlungsempfehlungen, ~80-100 Wörter)
- **Selbstreflexionsfragen** (3-4 offene Fragen, ~10-15 Wörter pro Frage)

## Beispiel-Strukturen

### Entwicklung-Tip-Format

Immer 2 Bullets à 1-2 Sätze. Ton: strategisch, executive-level (zielt auf Führungskräfte ab).

Beispiel Führung:
> Entwickeln Sie eine klare, einfache und wiederholbare Sprache für Ihre Vision. Testen Sie, ob Ihre Vision klar ist: Bitten Sie 5 Führungskräfte aus unterschiedlichen Ebenen, die Vision in eigenen Worten zu erklären.
> Führung auf höchster Ebene bedeutet, Energie und Zuversicht in die Organisation zu senden – auch in schwierigen Zeiten.

### Selbstreflexionsfragen-Format

3-4 offene Fragen pro Kompetenz. Meist in "Welche/Wie/Wann/Wo/Was"-Form, auf Führungs-/Unternehmens-Kontext bezogen.

Beispiel Kommunikation:
- Wenn Sie an Ihre letzte große Unternehmenskommunikation denken: Was war die eine zentrale Botschaft...?
- Welche Zielgruppe fällt Ihnen bei der Kommunikation am schwersten zu erreichen und warum?
- Welche wichtige Botschaft haben Sie in den letzten 6 Monaten am schwersten zu kommunizieren gefunden?

## Positionierung

- **Kein neuer Test** — nutzt dieselben Rohdaten wie Bewertungsergebnisse
- **Reiner Text-Generator-Output** — Kandidat füllt nichts Zusätzliches aus
- **Zielgruppe**: Coach + Kandidat zusammen (1:1-Gespräch)
- **Executive-Fokus**: Fragen zielen auf C-Level / Führungs-Verantwortung

## ARK-CRM-Integration

### Report-Varianten pro Assessment

Aus **1 Testdurchlauf** lassen sich mehrere Report-Varianten generieren:

| Variante | Fokus | Zielgruppe |
|---|---|---|
| Bewertungsergebnisse | Selektion/Matching | Kunde (Arkadium) |
| **Development** | Coaching | Kandidat + Coach |
| Selektion | Interview-Vorbereitung | Recruiter |

DB-Schema-Implikation: `fact_assessments` hat 1 Testdurchlauf, `fact_assessment_reports` hat N Report-Varianten (bewertung/development/selektion).

### Nutzung im CRM

- **Kandidat-Detailmaske Tab "Assessments"**: alle 3 Reports downloadbar
- **Briefing-Drawer** (nach Assessment): Development-Report-Link
- **Coaching-Activity** (`coaching` Activity-Type): Entwicklungsbericht als Gesprächs-Grundlage

## Key Points

- **13 Seiten** statt 38 — schlanker Coaching-Report
- Nutzt **gleiche Kompetenz-Struktur** wie Bewertungsergebnisse
- **Ersetzt Freitext-Dimensionsbeschreibungen** durch Tips + Reflexionsfragen
- **Executive-Sprache** deutet auf Management-Report-Tier hin

## Related

- [[assessment-beispiel-bewertungsergebnisse]] — Teil 1/3 (Matching)
- [[assessment-beispiel-selektionsbericht]] — Teil 3/3 (Interview)
- [[assessment]] — Haupt-Konzept
- [[assess-jobprofile]] — Kompetenz-Basis
