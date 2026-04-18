---
title: "Assessment-Beispiel: ASSESS 5.0 Bewertungsergebnisse (Job Profile Match)"
type: source
created: 2026-04-17
updated: 2026-04-17
sources: ["Bewertungsergebnisse_[Kandidatin-A]_[anonymisiert].pdf"]
tags: [assessment, assess-5-0, scheelen, job-profile, kompetenzen, persoenlichkeitsprofil, anonymisiert]
---

# Assessment-Beispiel: ASSESS 5.0 Bewertungsergebnisse

Anonymisierter Referenz-Bericht eines realen Arkadium-Assessments (**ASSESS 5.0** von SCHEELEN®, 38 Seiten). Kandidatin-Identität wurde aus Datenschutz-Gründen entfernt — hier dokumentiert ist die **Berichtsstruktur** + **Scoring-Skala** zur späteren System-Integration.

> Original-PDF in `raw/Assessments/` — enthält Personendaten (DSGVO Art. 9). Nicht in Wiki referenzieren, nur via Admin-Zugriff.

## Report-Metadaten (Struktur)

| Feld | Typ / Beispielwert |
|---|---|
| **Job Profile** | Consultant (Arkadium-Standard-Rolle) |
| **Matching Score** | 0-10 Skala · hier 8.0 ("Gute Übereinstimmung") |
| **Benötigte Zeit** | ~20 Minuten Testausfüllung |
| **Seiten** | 38 |
| **Ansprechpartner** | Arkadium-Berater (Name + Email + Telefon) |
| **Produkt** | ASSESS 5.0 Bericht |

## Report-Aufbau

### 1. Gesamtübereinstimmungswert (Titelseite)
- Matching-Score 1-10
- Label: Schwach / Moderat / Gute Übereinstimmung / Sehr gute Übereinstimmung

### 2. Überblick Kompetenzen
- **Stärken** (Top 3 Kompetenzen mit Score ≥ 8.0)
- **Entwicklungspotenzial** (Bottom 3 Kompetenzen mit niedrigstem relativen Score)

### 3. Persönlichkeitsprofil (3 Seiten, 26 Dimensionen)

Bipolare Skalen 0-10 mit grauer Kugel-Markierung:

**Seite 1 (11):** Authentizität · Beharrlichkeit · Bescheidenheit · Denk- & Urteilsweise · Durchsetzungsfähigkeit · Ehrlichkeit-Bescheidenheit · Emotionale Selbstregulation · Emotionale Sensibilität · Extraversion · Gestaltungsüberzeugung · Gewissenhaftigkeit

**Seite 2 (11):** Handlungssicherheit · Humanistische Orientierung · Kritiktoleranz · Leistungsorientierung · Neugier · Offenheit für Erfahrungen · Proaktivität · Selbstwertgefühl · Soziale Einflussbereitschaft · Soziale Harmonie · Soziale Wahrnehmung

**Seite 3 (5):** Teamorientierung · Umgang mit Unsicherheiten · Verantwortungsübernahme · Wachstumsorientierung · Zuverlässigkeit

### 4. Job Profile Match (11 Kompetenzen)

Zentrale Kompetenz-Bewertung für die Ziel-Rolle. **Identisch mit ASSESS Standard-Kompetenzen** (`assess-jobprofile.md`):

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

Jede Kompetenz erhält:
- Score 0-10
- Label (Schwach / Moderat / Gute / Sehr gute Übereinstimmung)
- Freitext-Beschreibung (3-5 Sätze, generiert aus Persönlichkeitsdimensionen)

### 5. Detail-Kompetenzen (11 Sektionen × 2-3 Seiten)

Pro Kompetenz werden die zugrundeliegenden Persönlichkeitsdimensionen aufgeschlüsselt. Beispiel **Beziehungsmanagement** nutzt:
- Selbstwertgefühl
- Soziale Harmonie
- Ehrlichkeit-Bescheidenheit
- Proaktivität
- Emotionale Sensibilität
- Soziale Einflussbereitschaft
- Soziale Wahrnehmung
- Extraversion

Pro Dimension:
- Bipolare Skala 0-10 mit Markierung
- Freitext-Interpretation (4-6 Sätze)

## Scoring-Skala (ASSESS 5.0)

| Score | Label |
|---|---|
| 0.0-3.9 | Schwache Übereinstimmung |
| 4.0-5.9 | Moderate Übereinstimmung |
| 6.0-7.9 | Gute Übereinstimmung |
| 8.0-10.0 | Sehr gute Übereinstimmung |

## Persönlichkeitsdimensionen-Katalog (26)

Die 26 Dimensionen aus ASSESS 5.0 sind **unabhängig vom Job-Profil** und werden pro Rolle unterschiedlich gewichtet. Für Systemintegration:

| # | Dimension | Pol links | Pol rechts |
|---|---|---|---|
| 1 | Authentizität | Taktisch-Strategisch | Authentisch-Werteorientiert |
| 2 | Beharrlichkeit | Flexibel-Anpassungsfähig | Ausdauernd-Beständig |
| 3 | Bescheidenheit | Selbstbezogen-Anerkennungsorientiert | Bescheiden-Teamorientiert |
| 4 | Denk- & Urteilsweise | Intuitiv-Ganzheitlich | Analytisch-Strukturiert |
| 5 | Durchsetzungsfähigkeit | Anpassend-Harmonisch | Selbstbehauptend-Bestimmt |
| 6 | Ehrlichkeit-Bescheidenheit | Pragmatisch-Strategisch | Aufrichtig-Bescheiden |
| 7 | Emotionale Selbstregulation | Emotional-Sensibel | Emotional-Stabil |
| 8 | Emotionale Sensibilität | Unabhängig-Distanzwahrend | Beziehungsorientiert-Empathisch |
| 9 | Extraversion | Introvertiert | Extravertiert |
| 10 | Gestaltungsüberzeugung | Umfeldorientiert | Selbstbestimmt |
| 11 | Gewissenhaftigkeit | Flexibel-Spontan | Strukturiert-Diszipliniert |
| 12 | Handlungssicherheit | Unsicher | Zuversichtlich |
| 13 | Humanistische Orientierung | Pragmatisch-Nutzenorientiert | Menschenzentriert-Wertschätzend |
| 14 | Kritiktoleranz | Kritiksensibel-Defensiv | Offen-Lernorientiert |
| 15 | Leistungsorientierung | Genügsam-Ausgeglichen | Ehrgeizig-Leistungsstrebend |
| 16 | Neugier | Sicherheitsorientiert-Beständig | Neugierig-Entdeckend |
| 17 | Offenheit für Erfahrungen | Konservativ-Traditionsorientiert | Offen-Neugierig |
| 18 | Proaktivität | Reaktiv-Abwartend | Initiativ-Gestaltend |
| 19 | Selbstwertgefühl | Selbstkritisch | Selbstsicher-Selbstakzeptierend |
| 20 | Soziale Einflussbereitschaft | Zurückhaltend | Einflussnehmend |
| 21 | Soziale Harmonie | Herausfordernd-Kritisch | Kooperativ-Harmonisch |
| 22 | Soziale Wahrnehmung | Sachlich-Objektiv | Einfühlsam-Mitfühlend |
| 23 | Teamorientierung | Unabhängig-Autonom | Kooperativ-Teamorientiert |
| 24 | Umgang mit Unsicherheiten | Kontrollbedürftig | Gelassen im Unklaren |
| 25 | Verantwortungsübernahme | Unbeständig | Verantwortungsbewusst |
| 26 | Wachstumsorientierung | Stabilitätsorientiert | Entwicklungsfokussiert |
| 27 | Zuverlässigkeit | Flexibel-Ungebunden | Verlässlich-Verantwortungsbewusst |

(Tatsächlich 27 Dimensionen — "Zuverlässigkeit" wird als zusätzliche Dimension geführt.)

## ARK-CRM-Integration

### DB-Schema-Vorschlag

```
fact_assessments
  - assessment_id PK
  - candidate_id FK
  - job_profile_id FK  -- "Consultant", "Sales", etc.
  - test_product TEXT  -- "ASSESS_5.0", "TriMetrix_EQ", "RELIEF"
  - overall_match NUMERIC(3,1)  -- 0.0-10.0
  - duration_minutes INT
  - test_date DATE
  - report_pdf_url TEXT

fact_assessment_dimensions
  - assessment_id FK
  - dimension_id FK  -- dim_personality_dimensions
  - score NUMERIC(3,1)  -- 0.0-10.0

fact_assessment_competencies
  - assessment_id FK
  - competency_id FK  -- dim_competencies (26 Stk aus assess-jobprofile)
  - score NUMERIC(3,1)
  - label TEXT  -- "Gute Übereinstimmung"

dim_personality_dimensions  -- 27 Einträge fix
  - dimension_id PK
  - name, pol_left, pol_right

dim_competencies  -- 26 Einträge fix
  - competency_id PK
  - name, beschreibung
```

### Top/Flop-Logik

- **Stärken-Tab**: `ORDER BY score DESC LIMIT 3` wo score ≥ 8.0
- **Entwicklungspotential-Tab**: `ORDER BY score ASC LIMIT 3`
- **Gap-Analyse Job vs. Kandidat**: Job-Profil-Sollwerte ↔ Kandidaten-Istwerte

## Key Points

- **ASSESS 5.0** ist SCHEELENs aktuelle Hauptversion (Nachfolger ASSESS 4.x)
- Report kombiniert **Persönlichkeit (27 Dim)** + **Job-Match (11 Kompetenzen)**
- **Job-Profile** sind konfigurierbar — Arkadium nutzt u.a. "Consultant" als Standard
- Testdauer: **20 Minuten** (sehr kurz im Vergleich zu TriMetrix 45-60 Min)
- Report-Länge: **38 Seiten** (sehr ausführlich, viel Prosa-Text)

## Related

- [[assess-jobprofile]] — Standard-Job-Profile + 26-Kompetenzen-Katalog (Basis)
- [[assessment]] — Haupt-Konzept
- [[musterbericht-trimetrix-eq]] — alternative Methodik (DISC+Motivatoren+EQ)
- [[musterbericht-relief]] — Stress-Counterpart
- [[assessment-schema]] — UI-Spec Assessment-Detailmaske
- [[assessment-beispiel-entwicklungsbericht]] — Report 2/3 dieser Trilogie
- [[assessment-beispiel-selektionsbericht]] — Report 3/3 dieser Trilogie

## Offene Fragen

- Sollen Persönlichkeitsdimensionen + Kompetenzen als **Stammdaten-Katalog** im CRM hinterlegt werden?
- **Auto-Parse** aus PDF oder manuelle Eingabe der 26+11 Scores?
- Versionierung bei Re-Assessment (z.B. nach 2 Jahren): zwei Rows in `fact_assessments`?
- Job-Profil-Definition: wo werden Soll-Werte pro Rolle gepflegt?
- Trilogie (Bewertungs- + Entwicklungs- + Selektionsbericht): alle 3 separat oder als 1 Assessment-Bundle?
