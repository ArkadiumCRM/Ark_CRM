---
title: "Assessment-Beispiel: ASSESS 5.0 Selektionsbericht (Interview-Leitfaden)"
type: source
created: 2026-04-17
updated: 2026-04-17
sources: ["Selektionsbericht_[Kandidatin-A]_[anonymisiert].pdf"]
tags: [assessment, assess-5-0, scheelen, selektion, interview, anonymisiert]
---

# Assessment-Beispiel: ASSESS 5.0 Selektionsbericht

Anonymisierter Selektions-Report als **Teil 3 der ASSESS 5.0 Trilogie** (8 Seiten). Enthält **Interview-Leitfragen** pro Kompetenz — dient dem Recruiter/Interviewer als Gesprächs-Leitfaden während des TI/1st/2nd Interviews.

> Original-PDF in `raw/Assessments/` — enthält Personendaten (DSGVO Art. 9).

## Report-Zweck

**Selektionsbericht** = "Welche Fragen sollte ich stellen?" (Interview-Sicht)

Ergänzt die beiden anderen Reports in der Trilogie:
| Report | Zweck | Länge |
|---|---|---|
| Bewertungsergebnisse | Matching + Persönlichkeits-Dimensionen | 38 S. |
| Entwicklungsbericht | Coaching + Reflexionsfragen | 13 S. |
| **Selektionsbericht** | **Interview-Leitfaden** | **8 S.** |

## Report-Aufbau (8 Seiten)

### 1. Titelseite + Metadaten
Label "SELEKTION" statt Bewertungsergebnisse-Label.

### 2. Gesamtübereinstimmungswert + Stärken/Entwicklungspotenzial
Identisch zu anderen zwei Reports (3 Stärken + 3 Entwicklungspotenziale).

### 3. Interview-Fragen pro Kompetenz (6 Seiten, 11 Kompetenzen)

**Pro Kompetenz**:
- Kompetenz-Name + Score + Label
- **Frage**: offene Interview-Frage (Executive-Level, STAR-Method-kompatibel)
- **Hinweis**: Beobachtungs-Kriterium für den Interviewer (2-3 Leitfragen in 2. Person: "Zeigt die Person...?")

## Interview-Fragen-Format (Beispiele)

Alle Fragen sind **verhaltensorientierte STAR-Methode-Fragen** (Situation/Task/Action/Result):

### Ergebnisorientierung
> **Frage:** Sie tragen die Gesamtverantwortung für die Unternehmensergebnisse. Erzählen Sie von einer Situation, in der Sie trotz erheblichem Gegenwind an einem ambitionierten Unternehmensziel festgehalten haben. Was hat Sie angetrieben, und wie haben Sie die Organisation dabei mitgenommen?
> **Hinweis:** Zeigt die Person strategische Ausdauer und eine kulturprägende Wirkung auf die Organisation?

### Führung
> **Frage:** Beschreiben Sie, wie Sie eine Unternehmensvision entwickelt und erfolgreich in der Organisation verankert haben.
> **Hinweis:** Inspiriert die Person durch Haltung und Vision? Gelingt es ihr, unterschiedliche Menschen hinter einem gemeinsamen Ziel zu vereinen?

### Resilienz
> **Frage:** Beschreiben Sie eine schwere Krise, durch die Sie Ihr Unternehmen führen mussten. Was hat Ihnen persönlich geholfen, handlungsfähig und stabil zu bleiben?
> **Hinweis:** Bleibt die Person in Extremsituationen handlungs- und urteilsfähig?

### Überzeugungskraft
> **Frage:** Beschreiben Sie eine Situation, in der Sie einen wichtigen Stakeholder (Aufsichtsrat/Investor/Partner) von einer unpopulären Entscheidung überzeugen mussten.
> **Hinweis:** Verfügt die Person über die Fähigkeit, auf höchster Ebene zu überzeugen?

## Positionierung der 3 Reports

```
TEST-AUSFÜLLUNG (20 Min)
            │
            ▼
┌───────────────────────────────────────┐
│     ASSESS 5.0 Rohdaten (DB)           │
│  27 Persönlichkeits-Dim + 11 Komp     │
└─────────────┬─────────────────────────┘
              │
    ┌─────────┼─────────────┐
    ▼         ▼             ▼
  38 S.     13 S.          8 S.
Bewertungs  Entwicklung   Selektion
(Matching)  (Coaching)    (Interview)
    │         │             │
    ▼         ▼             ▼
  Kunde     Coach+         Recruiter+
  (intern)  Kandidat       Interviewer
```

## ARK-CRM-Integration

### Prozess-Flow mit Report-Nutzung

| Stage | Nutzung Selektionsbericht |
|---|---|
| **CV Sent** | Report im Kunden-Package mit beilegen? |
| **TI** (Telefon-Interview) | Arkadium-CM verwendet Fragen als Briefing-Input für Kandidat-Coaching |
| **1st/2nd Interview** | Kunde nutzt Fragen im Interview mit Kandidat |
| **Debriefing** | Arkadium vergleicht Kundenfeedback mit Report-Hinweisen |

### Datenmodell-Implikation

```
fact_assessments (1 Test)
  └─ fact_assessment_reports (N Reports)
      - report_type: bewertung | development | selektion
      - report_pdf_url
      - language (DE/EN)
      - generated_at
```

## Interviewer-Leitfaden-Pattern

Alle **Hinweise** folgen dem Pattern:
1. **Verhaltens-Check**: "Zeigt die Person [Verhalten]?"
2. **Balance-Check**: "Balanciert/Kombiniert sie X und Y?"
3. **Organisations-Wirkung**: "Hat sie kulturprägende/strategische Wirkung?"

Das macht die Hinweise **direkt in Activity-Type `debriefing` übertragbar** — Arkadium-CM könnte nach dem Kunden-Debriefing die Hinweise-Checks ausfüllen.

## Key Points

- **8 Seiten** — kompakter Interview-Leitfaden
- **STAR-Method-Fragen** — alle Kompetenz-Fragen sind verhaltensbasiert
- **Hinweise = Beobachtungs-Kriterien** für Interviewer
- **Executive-Level** — Fragen zielen auf Führungs-/C-Level-Kandidaten
- **Ergänzt Briefing/Debriefing** in der ARK-CRM-Activity-Struktur

## Related

- [[assessment-beispiel-bewertungsergebnisse]] — Teil 1/3 (Matching)
- [[assessment-beispiel-entwicklungsbericht]] — Teil 2/3 (Coaching)
- [[assessment]] — Haupt-Konzept
- [[interviewguide-kandidat]] — Arkadium-internes Interview-Coaching (Kandidatenseite)
- [[referenzauskunft]] — Parallele Interview-Struktur für Referenzen
