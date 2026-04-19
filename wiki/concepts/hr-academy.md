---
title: "HR · Arkadium Academy (Ausbildungssystem)"
type: concept
created: 2026-04-19
updated: 2026-04-19
sources: [
  "hr-reglemente.md",
  "hr-arbeitsvertraege.md",
  "hr-stellenbeschreibung-progressus.md"
]
tags: [hr, phase-3, academy, ausbildung, methoden, communication-edge, m4-modell, lernkarteien]
---

# HR · Arkadium Academy

Internes Ausbildungssystem, verankert im Reglement "Generalis Provisio" §4. Die Academy ist **USP-Kern** und wird explizit als Begründung für Konkurrenzverbot und Loyalitätspflicht herangezogen.

## Aufbau

**3 Fachgebiete:**
- **A** = Arkadium (Unternehmens-DNA, Methode, Strategie)
- **B** = Branche (Bau/Baunebengewerbe/Immobilien/Architektur)
- **C** = Communication (Rhetorik, Gesprächstechniken)

**3 Ausbildungs-Teile:**
- Modular aufgebaut, interdisziplinär angewandt
- Verschiedene Wissenschaftsbereiche: Soziologie · Psychologie (Verhaltens-/Human-Psychologie) · Kommunikation · Marketing · Naturwissenschaft · Quantenphysik · Theologie · Neurowissenschaft

## Schulungsunterlagen (Kern-Module)

| Modul | Inhalt |
|-------|--------|
| **Communication Edge 1** | Kommunikations-Grundlagen |
| **Communication Edge 2** | Fragetechniken · Einwandbehandlung |
| **Communication Edge 3** | Advanced Rhetorik · Überzeugung |
| **M4 Modell** | 4-Phasen-Recruiting-Prozess · Interview · Assessment |
| **Lernkarteien 1 & 2** | Schnellreferenz-Karten für Praxis |

Im `raw/HR/2_HR On- Offboarding/10_Schulungsunterlagen/Einführungsordner/` liegen die einzelnen Module:
- M 1 1 Ident · M 1 2 Hunt · M 1 3 CV Chase · M 1 4 Briefing_RL
- M 2 1 Doc Chase · M 2 2 PreLeading · M 2 3 PreLead Presentation · M 2 4 GO Fishing
- M 3 1 Docs Generating · M 3 2 Abstract · M 3 3 Akquise/Home Run · M 3 4 CV sent
- M 4 1 TIVT Orga · M 4 2 2nd Orga · M 4 3 Offer · M 4 4 Placement

## Methoden-Themen (§4.3)

### Research · Profiling · Identifikation

- Identifikation von Konkurrenz- + Quellunternehmen
- Kandidaten-Profiling + Verifikation
- Markt-/Konkurrenzanalyse
- Berufsrelevantes Wissen aus Bildungswesen
- Biographien + Mustererkennung
- Mix-Matching: Leitbild Unternehmen × intrinsische Vision Kandidat

### Interview + Coaching

- Qualifizierte + narrative Interviews
- Beobachtungs-/Interviewprotokolle
- Eignungsbasierte Zuordnung
- Typologie-Erkennung (Myers-Briggs · Keirsey Temperament Sorter)
- Stoparanovic Development & Performance Center

### Rhetorik (§4.3.1)

- Gesprächsführung + -steuerung
- Frage-/Sagetechniken
- Argumentationsaufbau
- Einwandbehandlung
- Voice Training (Artikulation · Pausen · Betonung)
- Erstansprache-Skript + Profiling
- Stimulus-Response-Modell
- Sellcruiting (Solution Selling)
- Candidate Experience + Retention

### Marktwissen (§4.3.2)

- Grundberufe Bauwesen
- Verdeckte Marktinformation
- Standortanalyse
- Organisationsstruktur Bau
- SIA-Phasen, Hierarchien, Schnittstellen
- Netzwerk für Namedropping

### Techniken + Modelle (§4.3.3)

- NLP (Neuro Linguistische Programmierung)
- Personenzentrierter Ansatz (PCA · Carl Rogers)
- Aktualisierungstendenzen
- Klassische Konditionierung
- Erkenntnistheorie
- Sozialkognitive Lerntheorie
- Trait & Factor + RIASEC (Arbeits-/Organisationspsychologie)
- Entwicklungspsychologie
- Handlungsregulationstheorie (TOTE-Modell)

## Schutz-Status

Das Knowhow der Academy gilt als **Geschäftsgeheimnis im Sinne von Art. 321a Abs. 4 OR**. Verletzung der Geheimhaltungspflicht:
- Während AV: Disziplinarstrafe CHF 20'000/Verletzung
- Nach AV: Konventionalstrafe CHF 20'000/Verletzung
- Strafrechtlich verfolgbar

## Implementation im HR-Tool

Plan v0.1 §6.2 hat `dim_onboarding_templates` + `fact_onboarding_instances`. Die Academy ist **mehr als Onboarding** — sie ist kontinuierliche Ausbildung.

### Neue Tabellen

```sql
CREATE TABLE dim_academy_modules (
  id UUID PRIMARY KEY,
  module_code TEXT UNIQUE NOT NULL,         -- 'comm_edge_1', 'm4_modell', ...
  name_de TEXT NOT NULL,
  fachgebiet CHAR(1) CHECK (fachgebiet IN ('A','B','C')),
  part_number INT,                          -- 1, 2, 3
  duration_hours NUMERIC(5,1),
  document_urls JSONB,                      -- ['raw/HR/.../M 1 1 Ident.pdf', ...]
  prerequisites UUID[] DEFAULT '{}',
  mandatory_for_roles TEXT[],               -- ['consultant', 'researcher']
  sort_order INT
);

CREATE TABLE fact_academy_progress (
  id UUID PRIMARY KEY,
  mitarbeiter_id UUID REFERENCES dim_mitarbeiter(id),
  module_id UUID REFERENCES dim_academy_modules(id),
  started_at DATE,
  completed_at DATE,
  trainer_id UUID REFERENCES dim_mitarbeiter(id),
  self_assessment_score INT CHECK (self_assessment_score BETWEEN 1 AND 10),
  trainer_assessment_score INT CHECK (trainer_assessment_score BETWEEN 1 AND 10),
  notes TEXT,
  UNIQUE (mitarbeiter_id, module_id)
);
```

### Onboarding-Template-Seed

Consultant-Onboarding (14 Wochen):

| Phase | Module | Dauer |
|-------|--------|-------|
| Woche 1–2 | Communication Edge 1 + M 1 1 Ident | 20 h |
| Woche 3–4 | M 1 2 Hunt + M 1 3 CV Chase + M 1 4 Briefing | 40 h |
| Woche 5–6 | Communication Edge 2 + M 2 Serie | 40 h |
| Woche 7–8 | M4 Modell + M 3 Serie | 30 h |
| Woche 9–12 | Communication Edge 3 + M 4 Serie | 60 h |
| Woche 13–14 | Lernkarteien 1 & 2 · Praxis-Begleitung | 20 h |

Researcher-Onboarding (lighter, ~8 Wochen):
- Fokus M 1 Serie (Ident, Hunt, CV Chase)
- Communication Edge 1
- M4 Modell-Grundlagen
- Lernkarteien 1

## Offene Fragen

1. **Wer ist Academy-Verantwortlicher?** Head-of-Department? Peter (GL)? → RBAC-Rolle `academy_lead`
2. **Re-Zertifizierungs-Zyklus?** Jährliche Refresher auf bestimmte Module?
3. **Externe Schulungen** (z.B. MAS HRM · CAS Consulting) werden als `fact_training_requests` getrackt — Academy-intern separat.

## Related

- [[hr-vertragswerk]] · [[hr-reglemente]] (Generalis Provisio §4)
- [[hr-arbeitsvertraege]] (§9.1 als Rechtfertigung für Konkurrenzverbot)
- [[hr-stellenbeschreibung-progressus]] (Kompetenz-Anforderungen)
- [[hr-schema-deltas-2026-04-19]]
- `mockups/ERP Tools/hr.html` §Onboarding-Checkliste
