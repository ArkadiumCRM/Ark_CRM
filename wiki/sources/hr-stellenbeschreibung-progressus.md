---
title: "HR · Stellenbeschreibung Progressus (Consultant + Research Analyst)"
type: source
created: 2026-04-19
updated: 2026-04-19
sources: [
  "raw/HR/2_HR On- Offboarding/8_Stellenbeschreibung/DRUCK_Stellenbeschreibung Consultant.docx",
  "raw/HR/2_HR On- Offboarding/8_Stellenbeschreibung/DRUCK_Stellenbeschreibung Research Analyst.docx"
]
tags: [hr, phase-3, stellenbeschreibung, progressus, consultant, research-analyst, kompetenzen]
---

# HR · Stellenbeschreibung "Progressus"

Integraler Bestandteil des Arbeitsvertrags (Arkadium-Name: "Stellen- und Kompetenzbeschreibung / Progressus"). 2 Vorlagen — je MA-Typ.

## Header-Tabelle (Standard-Struktur, 9 Felder)

| Feld | Beispiel |
|------|----------|
| Stelleninhaber | `NAME MITARBEITER` |
| Bereich / Abteilung | Executive & Professional Search / Kernbusiness / Architecture & Real Estate |
| Funktion | Consultant · Research Analyst · Team Leader REM · ... |
| Pensum | 100% |
| Direkter Vorgesetzter | Stefano Papes, Head of Architecture & Real Estate |
| Stellvertreter | Gemäss Organigramm |
| Stellenantritt | Datum |
| Zeichnungsberechtigung | Nein · Ja (je nach Funktion) |
| Stand | 1. Januar 2024 |

## §A Consultant · Zielbeschreibung

> "Als Consultant schaffst du nicht nur die Basis für eine langfristige Zusammenarbeit mit Führungskräften, sondern begleitest sie aktiv auf ihrem Weg, ihr Potenzial im richtigen Umfeld zu entfalten. [...] Durch die telefonische Direktansprache gehst du in den Markt, identifizierst relevante Persönlichkeiten und baust Schritt für Schritt eine belastbare Vertrauensbasis auf."

### Aufgabenbereich (14 Kern-Positionen)

1. Identifikation · Recherche · Profiling · Ansprache in Bau/Bauneben/Immobilien
2. Eignungsabklärungen (Eigenschafts- · Biographie- · Simulationsansatz)
3. Dokumentanalyse · systematische Referenz-Interviews · Projektauswertungen
4. Career Transition · Talent- & Leadership-Coaching
5. Arbeitsmarkt-Analyse (Wettbewerb · Jobentwicklung · Fluktuation · Gesamtvergütung)
6. Coaching bzgl. Bewerbungsdokumente/Interviews/Beratung
7. Bewerbungsverfahren-Einleitung inkl. DS-Einvernehmen + Abstract
8. Interview-Arrangement mit Kunden
9. CRM-Pflege + Social Media
10. Beratung Inserations-Management + E-Recruiting + Social Media Recruiting
11. Bedarfsbesprechungen · Konditionenverhandlungen · Nutzenwertargumentation
12. Prozess-Journal + Fazitbericht nach Mandat
13. Ansprache Entscheidungsträger Linie/HR/GL (aktive + potenzielle Kunden)
14. AGB-Vorstellung + ggf. Individualverhandlung (Rücksprache mit GL)
15. Interview-Arrangement telefonisch/Video/persönlich
16. **Debitorenmanagement** für eigene Platzierungen/Mandate (nur Consultant!)
17. **On-/Offboarding-Steuerung** beim Kunden + Kadermitarbeiter (nur Consultant!)
18. Digital Data Management

### Anforderungen Consultant

| Kategorie | Anforderung |
|-----------|-------------|
| Ausbildung | Hochschulabschluss (Psychologie · Wirtschaft · Recht · Kommunikation) · tertiäre Ausbildung mit gutem Abschluss (HRM · Marketing) |
| Weiterbildung | MAS HRM · CAS Consulting wünschenswert |
| Erfahrung | Erfolgsnachweis 2-4 J Leistungsumfeld · Headhunting/Executive-Search-Erfahrung von Vorteil · Akquisition + People Management von Vorteil · **Disziplinarische Führung von Vorteil** |
| Portfolio | CH Fach-/Führungskräfte höheres Kader · Real Estate Management · Asset/Portfolio Management · Immobilien-Vermarktung · -Bewertung · Transaction |
| Kompetenzen | Verhandlungs-/Gesprächstechniken · Rhetorik · analytische Fähigkeiten · Empathie · Sozialkompetenz · Leistungsbereitschaft |
| Sprachen | Template: "Stilsicher DE + EN zwingend" *(Legacy · reale Policy DE only)* |

**Template-Drift:** Das Progressus-Template fordert "EN zwingend" — tatsächlich wird EN bei Arkadium-Kunden + Kandidaten so gut wie nie verlangt (Peter 2026-04-19). Bei Template-Revision auf "DE zwingend, EN nice-to-have" umstellen. Siehe Memory `project_sprache_policy.md`.

## §B Research Analyst · Zielbeschreibung

> "Als Research Analyst schaffst du nicht nur die Basis einer langfristigen Zusammenarbeit mit Führungskräften, sondern begleitest sie selber auf ihrem Weg zur Potentialentfaltung. [...] Durch deine Aufgabe im Research stellst du sicher, dass hochmotivierte Führungskräfte und Fachkader in einem Umfeld platziert werden, in der sie durch das Teilen gemeinsamer Visionen nachhaltig wachsen können."

### Aufgabenbereich (5 Kern-Positionen, weniger als Consultant)

1. Identifikation · Recherche · Profiling · Ansprache → **Idents erstellen**
2. Eignungsabklärungen mit Hunt Calls + Dokumentanalyse
3. Career Transition · Talent- & Leadership-Coaching
4. Arbeitsmarkt-Analyse
5. Digital Data Management

### Delta Consultant ↔ Research Analyst

Research **hat NICHT:**
- Debitorenmanagement
- On-/Offboarding-Kunde-Steuerung
- AGB-Verhandlungen
- Prozess-Journal/Fazitbericht
- Bedarfsbesprechungen/Konditionenverhandlungen
- Ansprache Entscheidungsträger/GL
- Referenz-Interviews
- Beratung Inserations-Management
- Disziplinarische Führung (gar kein Thema)

### Anforderungen Research Analyst

Wie Consultant, **ohne** Portfolio-Anforderung und ohne disziplinarische Führung · **Zeichnungsberechtigung nicht zwingend**.

## Key Takeaways für HR-Tool

1. **`dim_job_descriptions` neue Tabelle:**
   ```sql
   CREATE TABLE dim_job_descriptions (
     id UUID PRIMARY KEY,
     code TEXT UNIQUE NOT NULL,                  -- 'consultant', 'research_analyst', 'team_leader_rem', ...
     name_de TEXT NOT NULL,
     bereich TEXT NOT NULL,                      -- 'Executive & Professional Search'
     abteilung TEXT,                             -- 'Kernbusiness'
     sparte TEXT,                                -- 'Architecture & Real Estate' (REM, ARC, INL, ENE)
     signing_authority BOOLEAN DEFAULT false,
     default_pensum INT DEFAULT 100,
     zielbeschreibung_de TEXT,
     aufgaben JSONB,                             -- Array von Aufgaben-Bullets
     anforderungen JSONB,                        -- {ausbildung, weiterbildung, erfahrung, kompetenzen, sprachen}
     version TEXT,                               -- '2024-01-01'
     valid_from DATE,
     document_url TEXT                           -- Progressus-PDF
   );
   ```

2. **`fact_employment_contracts.job_description_id` FK:** Link auf Stellenbeschreibung statt freitext `jobtitel TEXT`.

3. **Stellenbeschreibung-Editor** (Phase 3.1 oder 3.2 UI):
   - Versionierung · alte Version bleibt für Alt-Mitarbeiter gültig
   - Diff zwischen Versionen (auditierbar)
   - Bulk-Update auf neue Version (opt-in pro MA)

4. **Kompetenzen-Mapping:** `bridge_job_competencies` → `dim_competencies` (für Matching mit [[kandidat]]/[[assessment]]-Dimensionen).

## Related

- [[hr-arbeitsvertraege]] · [[hr-ma-rollen-matrix]]
- [[assessment]] (Kompetenz-Dimensionen für Matching)
- [[hr-schema-deltas-2026-04-19]]
