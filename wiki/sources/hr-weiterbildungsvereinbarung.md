---
title: "HR · Weiterbildungsvereinbarung (Template)"
type: source
created: 2026-04-19
updated: 2026-04-19
sources: [
  "raw/HR/2_HR On- Offboarding/7_Weiterbildungsvereinbarung/DRUCK_Weiterbildungsvereinbarung_Vorlage.docx"
]
tags: [hr, phase-3, weiterbildung, rueckzahlung, pensum-reduktion]
---

# HR · Weiterbildungsvereinbarung

Nebenvereinbarung zum Arbeitsvertrag bei längerer Weiterbildung (z.B. MAS HRM · CAS Consulting).

## Struktur

### Weiterbildungs-Fakten

- Weiterbildungs-Bezeichnung + Anbieter
- Zeitraum Beginn/Ende
- Kurs-Plan (z.B. Mo/Mi 18:00–21:15 + Sa 08:30–17:00)
- Pflicht zum vollständigen Absolvieren

### Flexibilität + Pensum

- Arkadium gewährt Flexibilität für Kurs-Besuch
- Vor-/Nachbearbeitung in **Freizeit** (nicht Arbeitszeit)
- **Pensum-Reduktion** (z.B. 100% → 95%)
- **Bruttobasisgehalt wird weiter zu 100% ausbezahlt** (AHV · PK · BVG · Spesen unverändert)

### Kostenbeteiligung Arkadium

- **CHF 2'500/Semester × 2 Semester = CHF 5'000** (Standard-Beispiel im Template)
- Auszahlung nur gegen Rechnung
- Im 3. + 4. Semester fällig (im Template-Beispiel)

### Rückzahlungsstaffel bei Austritt

Stichtag = **voraussichtlicher Weiterbildungs-Abschluss** (z.B. August 2027).

| Austritts-Zeitpunkt | Rückzahlung |
|---------------------|-------------|
| 0–12 Monate nach Abschluss | **100%** |
| 13–18 Monate | **50%** |
| 19–24 Monate | **25%** |
| 25+ Monate | **0%** (entfällt) |

### Sonderfälle

- **Abbruch aus persönlichen Gründen:** `XXX%` pro-rata-Rückerstattung (Template-Lücke)
- **Austritt während WB:** pro-rata-Rückerstattung
- **AG kündigt ohne Grund / AN kündigt aus wichtigen AG-verursachten Gründen:** Rückzahlung **entfällt**
- AG darf mit Lohnguthaben verrechnen

## Key Takeaways für HR-Tool

Plan v0.1 §6.2 hat `fact_training_requests` — Weiterbildungsvereinbarung ist aber ein **eigenes Vertrags-Dokument** mit Rückzahlungs-Staffel und Pensum-Impact.

**Erweiterungen:**

1. **Neue Tabelle `fact_training_agreements`:**
   ```sql
   CREATE TABLE fact_training_agreements (
     id UUID PRIMARY KEY,
     mitarbeiter_id UUID REFERENCES dim_mitarbeiter(id),
     training_request_id UUID REFERENCES fact_training_requests(id),
     title TEXT NOT NULL,
     provider TEXT,
     start_date DATE NOT NULL,
     expected_completion_date DATE NOT NULL,
     actual_completion_date DATE,
     pensum_reduction_percent NUMERIC(4,1),          -- z.B. 5 (für 100 → 95)
     gehalt_wird_voll_weiter_bezahlt BOOLEAN DEFAULT true,
     employer_contribution_per_semester_chf NUMERIC(10,2),
     semester_count INT,
     total_employer_contribution_chf NUMERIC(10,2) GENERATED ALWAYS AS (employer_contribution_per_semester_chf * semester_count) STORED,
     repayment_threshold_date DATE,                  -- Stichtag bei dem Staffel startet
     agreement_document_url TEXT,
     signed_at TIMESTAMPTZ,
     status TEXT DEFAULT 'active' CHECK (status IN ('planned','active','completed','aborted_personal','aborted_ag_cause')),
     cancellation_date DATE,
     cancellation_reason TEXT
   );
   ```

2. **Rückzahlungs-Regel (Rule-Engine oder View):**
   ```sql
   CREATE VIEW v_training_repayment_obligations AS
   SELECT
     ta.id,
     ta.mitarbeiter_id,
     ta.total_employer_contribution_chf,
     m.austrittsdatum,
     EXTRACT(YEAR FROM age(m.austrittsdatum, ta.actual_completion_date)) * 12 +
       EXTRACT(MONTH FROM age(m.austrittsdatum, ta.actual_completion_date)) AS months_since_completion,
     CASE
       WHEN m.austrittsdatum IS NULL THEN 0
       WHEN ta.status = 'aborted_ag_cause' THEN 0
       WHEN EXTRACT(MONTH FROM age(m.austrittsdatum, ta.actual_completion_date)) <= 12 THEN 1.0
       WHEN EXTRACT(MONTH FROM age(m.austrittsdatum, ta.actual_completion_date)) <= 18 THEN 0.5
       WHEN EXTRACT(MONTH FROM age(m.austrittsdatum, ta.actual_completion_date)) <= 24 THEN 0.25
       ELSE 0
     END * ta.total_employer_contribution_chf AS repayment_amount_chf
   FROM fact_training_agreements ta
   JOIN dim_mitarbeiter m ON m.id = ta.mitarbeiter_id;
   ```

3. **Pensum-Reduktion als separater `fact_pensum_history`-Eintrag:** während WB läuft, nicht permanent.

4. **Offboarding-Saga:** muss `v_training_repayment_obligations` abfragen + in Austritts-Verrechnung integrieren.

## Drawer-UI (Plan §7.3 erweitert)

- **Weiterbildungsvereinbarung anlegen:** 540px, Felder + Rückzahlungs-Vorschau
- **Rückzahlungs-Rechner:** Austrittsdatum-Simulation + Staffel-Anzeige

## Related

- [[hr-vertragswerk]] · [[hr-academy]]
- Plan v0.1 §6.2 `fact_training_requests`
- [[hr-schema-deltas-2026-04-19]]
