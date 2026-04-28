---
title: "HR-Schema-Deltas aus Tier-1-Vertragswerk-Ingest (2026-04-19)"
type: analysis
created: 2026-04-19
updated: 2026-04-19
sources: [
  "hr-arbeitsvertraege.md",
  "hr-reglemente.md",
  "hr-provisionsvertraege.md",
  "hr-arbeitszeugnisse.md",
  "hr-weiterbildungsvereinbarung.md",
  "hr-stellenbeschreibung-progressus.md",
  "hr-kuendigung-aufhebung.md",
  "hr-austritt-versicherung-merkblaetter.md"
]
tags: [hr, phase-3, schema-delta, analysis, plan-erweiterung, vertragswerk, arkadium]
---

# HR-Schema-Deltas aus Vertragswerk-Ingest — 2026-04-19

Konsolidierte Ableitung für **ARK_HR_TOOL_PLAN_v0_1.md** §6 (Datenmodell) + §11 (Offene Entscheidungen) nach Ingest von 26 Tier-1-Vorlagen im `raw/HR/`-Ordner.

**Scope:** Schema-Additions + Plan-Ergänzungen + neue offene Fragen. Migration-SQL-Snippets sind Vorschläge, zur Review mit Peter.

## 1. Offene Fragen aus Plan §11 — Antworten aus Ingest

| # | Plan-Frage | Ingest-Antwort |
|---|------------|----------------|
| 1 | Bewerber-Phase im Kanban? | **Raus** bestätigt — Arkadium-Vorlagen starten bei Arbeitsvertrags-Unterzeichnung (Offer-Phase beginnt erst nach CV-Review + Interviews, die im **CRM** passieren, nicht HR) |
| 2 | Payroll-Export-Format? | **Offen** — Verträge nennen keinen Anbieter. AHV/BVG/ALV/NBUV/SUVA-Abzüge Standard, Treuhand-Anbieter im Vertrag nicht festgelegt. Bexio/Abacus-Format je nach Treuhänder. Peter klären. |
| 3 | Arbeitszeugnis-Generator Phase? | **3.0 oder 3.6** — Templates existieren + sind standardisiert (Firmenbeschreibung + Academy-Intro + Platzhalter). Technisch einfach, fachlich sensibel. Vorschlag Phase 3.6 **bleibt**. |
| 4 | Lohnausweis-Upload? | **Auto-Import aus Payroll** bestätigt — Generalis Provisio §5.2 legt Auszahlungsrhythmus fest, Lohnausweise kommen vom Treuhänder. |
| 5 | Notfallkontakt-Priorität? | **Offen** — in Vorlagen nicht spezifiziert. Plan-Vorschlag 2 (primär+sekundär) bleibt. |
| 6 | Feiertags-Kantone? | **ZH** bestätigt (Maneggstrasse 45, 8041 Zürich HQ) + **1. Mai (Kanton Zürich)** im Tempus Passio 365 §6 explizit aufgezählt. Andere Kantone nur bei MA-Wohnsitz woanders. Liste: Neujahr · Berchtoldstag · Karfreitag · Ostermontag · 1. Mai ZH · Auffahrt · Pfingstmontag · 1. August · 25./26. Dezember. |
| 7 | Sprachanforderungen? | **DE only** (Peter 2026-04-19). Progressus-Template fordert "DE + EN zwingend", aber das ist Legacy-Wording — EN wird in der Realität so gut wie nicht gebraucht. Template-Revision ausstehend. FR/IT + EN nicht nötig. |
| 8 | Arzt-Zeugnis-Pflicht? | **Nicht Tag-basiert — Dienstjahr-Staffelung:** 1. DJ Tag 1 · 2. DJ Tag 2 · ab 3. DJ Tag 3 (Generalis Provisio §3.5.2). Plan-Vorschlag 3 Tage passt nur ab 3. DJ. |
| 9 | Ferien-Übertrag-Regel? | **Bis 14 Tage nach Ostern beziehen** bestätigt (Tempus Passio §6.1). Jüngste Ansprüche zuerst. Kein 5-Tage-Deckel — voller Übertrag erlaubt aber zeitlich limitiert. Plan-Vorschlag überarbeiten. |
| 10 | Dienstjubiläums-Gratifikation? | **Nicht in Vorlagen geregelt** — keine automatische Regel dokumentiert. Peter klären. |
| 11 | Geburtstag im Team-Kalender? | **Extra-Guthaben-Mechanismus** erlaubt Geburtstag-Tag + Tag für nahestehende Person. Sichtbarkeit nicht separat geregelt. Opt-in bleibt Empfehlung. |
| 12 | Probezeit-Default-Dauer? | **3 Monate** bestätigt (alle 4 Arbeitsvertrags-Varianten). Keine 6-Mt-Variante für Senior in Vorlagen. Peter klären ob Ausnahmen existieren. |

## 2. Neue Entitäten (über Plan §6 hinaus)

### 2.1 `dim_reglemente` (Vertrags-Anhänge versioniert)

Plan §6.2 hat `fact_employment_contracts.vertrag_dokument_url TEXT` (einzeln). **Unzureichend** — Arkadium hat 3 Reglemente + 2 Zusatz-Dokumente je MA.

Siehe [[hr-vertragswerk]] §Tech-Mapping für vollständiges DDL.

### 2.2 `dim_academy_modules` + `fact_academy_progress`

Plan §6.2 hat nur `dim_onboarding_templates` + `fact_onboarding_instances`. Academy ist **kontinuierlich** (nicht nur Onboarding) und Kern-USP.

Siehe [[hr-academy]] §Implementation.

### 2.3 `dim_disciplinary_penalty_types` + `fact_disciplinary_incidents`

Plan §6.2 enthält keine Disziplinar-Strafen. Arkadium hat 6 definierte Typen mit Beträgen (CHF 3k–20k während AV) + 3 post-AV-Typen (CHF 20k–80k).

Siehe [[hr-konkurrenz-abwerbeverbot]] §Schema-Implikationen.

### 2.4 `fact_warnings` (Verwarnungs-Eskalation)

Plan §6.2 modelliert nur Stage-Transitions. Aufhebungs-/Verwarnungs-Flow ist eigener Track.

Siehe [[hr-kuendigung-aufhebung]] §1.

### 2.5 `fact_provisionsvertrag_versions`

Plan §6.2 hat `commission_rate NUMERIC(4,3)` inline auf `dim_mitarbeiter`. **Unzureichend:**
- Jährlich neu geschlossen (Praemium Victoria)
- Budget-Ziel + Fix + Variabel als separate Felder
- Historisiert (vorheriges Jahr bleibt auditierbar)
- ZEG-Staffel-Ref

Siehe [[hr-vertragswerk]] §Tech-Mapping.

### 2.6 `fact_training_agreements`

Plan §6.2 hat nur `fact_training_requests`. Weiterbildungsvereinbarung ist separat (Pensum-Impact + Rückzahlungs-Staffel).

Siehe [[hr-weiterbildungsvereinbarung]] §Key-Takeaways.

### 2.7 `dim_job_descriptions` (Progressus versioniert)

Plan §6.2 hat `jobtitel TEXT`, `funktions_stufe TEXT`. **Unzureichend** — Arkadium hat strukturierte Stellenbeschreibungen mit Aufgaben-Liste + Anforderungen + Zeichnungsberechtigung.

Siehe [[hr-stellenbeschreibung-progressus]] §Key-Takeaways.

### 2.8 `fact_role_transitions`

Plan §6.2 hat `fact_lifecycle_transitions` für Stage-Wechsel (Aktiv → Offboarding). **Rollen-Wechsel** (Researcher → Consultant) ist separater Track mit §5.3-Praemium-Victoria-Regel (3 Mt Grace-Period).

Siehe [[hr-ma-rollen-matrix]] §Implikation.

## 3. Plan §6.1 `dim_mitarbeiter`-Erweiterung — Ergänzungen

Plan §6.1 nennt bereits Person/Adresse/CH-Compliance/Lifecycle. **Zusätzlich aus Ingest:**

```sql
ALTER TABLE dim_mitarbeiter ADD COLUMN IF NOT EXISTS
  -- aus Arkadium-Praxis
  personalakte_folder_url TEXT,                             -- externer Ablage-Link (falls nicht im System)
  current_reglement_generalis_provisio_version TEXT,        -- '2024-01-01'
  current_reglement_tempus_passio_version TEXT,
  current_reglement_locus_extra_version TEXT,
  current_job_description_id UUID REFERENCES dim_job_descriptions(id),
  karenzentschaedigung_chf_mt NUMERIC(8,2),                 -- 500 Consultant / 350 Researcher
  konkurrenzverbot_aktiv_bis DATE,                          -- bei Austritt: austritt + 18 Mt
  
  -- Academy-Status
  academy_modules_completed UUID[],                         -- aggregated aus fact_academy_progress
  academy_lead_id UUID REFERENCES dim_mitarbeiter(id),     -- wer verantwortlich für Ausbildung
  
  -- Org-Struktur (Arkadium-spezifisch)
  head_of_department_id UUID REFERENCES dim_mitarbeiter(id), -- direkte Führung
  signing_authority TEXT CHECK (signing_authority IN ('none','limited','full')) DEFAULT 'none';
```

## 4. Plan §6.2 `fact_employment_contracts`-Erweiterung

Plan-Felder OK; **Ergänzungen:**

```sql
ALTER TABLE fact_employment_contracts ADD COLUMN IF NOT EXISTS
  karenzentschaedigung_chf_mt NUMERIC(8,2) NOT NULL DEFAULT 0,
  job_description_id UUID REFERENCES dim_job_descriptions(id),     -- Progressus-Link
  konkurrenzverbot_region TEXT DEFAULT 'Deutschschweiz',            -- statt km-Radius
  konkurrenzverbot_branche_scope TEXT[] DEFAULT ARRAY[
    'bau_hauptgewerbe','bau_nebengewerbe','architecture',
    'civil_engineering','real_estate_management','building_technology','energy_environmental'
  ],
  konkurrenzverbot_konventionalstrafe_min_chf NUMERIC(10,2) DEFAULT 80000,
  konkurrenzverbot_konventionalstrafe_formula TEXT DEFAULT '12 Bruttomonatslöhne inkl. Provisionen/Spesen',
  abwerbeverbot_monate INT DEFAULT 18,
  abwerbeverbot_konventionalstrafe_chf NUMERIC(10,2) DEFAULT 80000,
  nachvertragliche_geheimhaltung_konventionalstrafe_chf NUMERIC(10,2) DEFAULT 20000,
  
  -- Kündigungsfristen als JSONB (statt einzelner INT)
  kuendigungsfristen_jsonb JSONB DEFAULT '{
    "probezeit_tage": 3,
    "dj_1": 1,
    "dj_2_5": 2,
    "dj_6_plus": 3
  }'::jsonb,
  
  -- Integral-Vertragsbestandteile
  attached_reglement_ids UUID[],                                    -- FKs zu dim_reglemente
  
  -- Gehalts-Auszahlungsrhythmus
  lohn_payment_window TEXT DEFAULT '25_30_of_month',                -- aus Generalis Provisio §5.2
  
  -- Signaturen
  signed_by_head_of_department BOOLEAN DEFAULT false,
  signed_by_founder BOOLEAN DEFAULT false;
```

## 5. Plan §6.2 `fact_absences` + `dim_absence_types`-Erweiterung

### Krankheits-Arztzeugnis-Regel (Arkadium-spezifisch)

Plan-Default: `auto_approve_threshold_days INT`. Arkadium hat **Dienstjahr-Staffelung** (Generalis Provisio §3.5.2).

```sql
ALTER TABLE dim_absence_types ADD COLUMN IF NOT EXISTS
  certificate_rule_type TEXT CHECK (certificate_rule_type IN (
    'never', 'always_day_1', 'after_n_days_fixed', 'staffelung_by_dienstjahr'
  )),
  certificate_staffelung_jsonb JSONB;  -- {"dj_1": 1, "dj_2": 2, "dj_3_plus": 3} (bei sick)

-- Seed für Krankheit:
UPDATE dim_absence_types SET
  certificate_rule_type = 'staffelung_by_dienstjahr',
  certificate_staffelung_jsonb = '{"dj_1": 1, "dj_2": 2, "dj_3_plus": 3}'::jsonb
WHERE code = 'sick';
```

### CH-spezifische Absenz-Typen (Tempus Passio §6.3)

Plan-Seed hat Militär/Zivil. Arkadium-Praxis umfasst zusätzlich:

```sql
INSERT INTO dim_absence_types (code, label_de, paid, requires_certificate, requires_approval, counts_towards_vacation_balance, sort_order)
VALUES
  ('sick', 'Krankheit', true, true, false, false, 10),
  ('vacation', 'Ferien', true, false, true, true, 20),
  ('unpaid', 'Unbezahlter Urlaub', false, false, true, false, 30),
  ('maternity', 'Mutterschaft (16 Wo EO)', true, true, false, false, 40),
  ('paternity', 'Vaterschaft (2 Wo EO)', true, false, true, false, 50),
  ('military', 'Militär-/Zivildienst (EO)', true, true, false, false, 60),
  ('civil_protection', 'Zivilschutz', true, true, false, false, 61),
  ('red_cross', 'Rotkreuzdienst', true, true, false, false, 62),
  ('fire_brigade', 'Feuerwehrdienst', true, true, false, false, 63),
  ('training', 'Weiterbildung', true, false, true, false, 70),
  ('sickness_family', 'Pflege Familie', true, false, true, false, 80),
  ('holiday', 'Feiertag (Kanton ZH)', true, false, false, false, 90),
  ('birthday_self', 'Geburtstag MA (Extra-Guthaben)', true, false, false, false, 100),
  ('birthday_close', 'Geburtstag nahestehend (Extra-Guthaben)', true, false, true, false, 101),
  ('joker_day', 'Jokertag (Me Time)', true, false, false, false, 102),
  ('zeg_target_reward', 'Zielerreichung Halbjahr (Extra-Guthaben)', true, false, true, false, 103),
  ('gl_discretionary', 'GL-Ermessen Extra-Tag', true, false, true, false, 104);
```

### Ferienkürzungs-Regel (Tempus Passio §6.3)

```sql
-- Implementierung als Trigger oder periodischer Worker:
-- > 2 Monate Absenz (nicht selbstverschuldet) → 1/12 Kürzung pro weiterem vollem Monat
-- Mutterschaft bis 16 Wo: keine Kürzung
-- Selbstverschuldet: ab 1. Monat Kürzung
-- Militär/Zivil/Rotkreuz/Feuerwehr/Zivilschutz: wie Krankheit behandeln
```

## 6. Plan §6.2 `fact_vacation_balances`-Erweiterung

Plan: einfaches Konto `allocated_days / used_days / pending_days`. Arkadium hat mehrschichtiges System.

```sql
ALTER TABLE fact_vacation_balances ADD COLUMN IF NOT EXISTS
  vacation_default_days NUMERIC(4,1) DEFAULT 25.0,
  extra_birthday_self_days NUMERIC(3,1) DEFAULT 1.0,
  extra_birthday_close_days NUMERIC(3,1) DEFAULT 1.0,
  extra_joker_days NUMERIC(3,1) DEFAULT 1.0,
  extra_zeg_h1_days NUMERIC(3,1) DEFAULT 0,              -- wird gesetzt bei ≥100% H1
  extra_zeg_h2_days NUMERIC(3,1) DEFAULT 0,
  extra_gl_discretionary_days NUMERIC(3,1) DEFAULT 0,    -- GL-Ermessen 0-3

  -- Sperrfristen-Flag (für UI-Validation)
  extra_only_bezug_in_blocked_periods BOOLEAN DEFAULT true,
  
  -- Kündigungs-Verfall für a/b/c (Tempus Passio §7.1 Abs. 2)
  forfeit_on_termination BOOLEAN DEFAULT true;

-- Ostern-Deadline-Tracking (Tempus Passio §6.1):
ALTER TABLE fact_vacation_balances ADD COLUMN IF NOT EXISTS
  carry_deadline_easter_plus_14_date DATE;    -- generated per year
```

**Bezugs-Validierung als Rule-Engine oder Trigger** bei INSERT in `fact_absences`:
- Geburtstag: **start_date muss in Geburtstagswoche des MA liegen**
- Jokertag: kein zeitliches Constraint
- ZEG-Tage: nur in definierten Sperrfristen (24.12.–01.01., Sechseläuten, Knabenschiessen, Brückentage)

## 7. Plan §6.2 `fact_homeoffice_*` (neu — fehlt in Plan)

Plan nennt `home_office_days INT DEFAULT 0` auf `fact_employment_contracts`. **Unzureichend** — Arkadium hat Quota-System + Antragspflicht.

```sql
CREATE TABLE fact_homeoffice_requests (
  id UUID PRIMARY KEY,
  mitarbeiter_id UUID REFERENCES dim_mitarbeiter(id),
  requested_date DATE NOT NULL,
  request_type TEXT CHECK (request_type IN ('homeoffice','remote_work')),
  requested_48h_before TIMESTAMPTZ,             -- Constraint validation
  project_context TEXT,                          -- laut Reglement: konkrete Projekte angeben
  status TEXT DEFAULT 'pending' CHECK (status IN (
    'pending', 'approved', 'rejected', 'cancelled'
  )),
  approved_by UUID REFERENCES dim_mitarbeiter(id),
  approved_at TIMESTAMPTZ,
  rejection_reason TEXT,
  UNIQUE (mitarbeiter_id, requested_date)
);

-- Quota-Tracking:
CREATE TABLE fact_homeoffice_quota_usage (
  id UUID PRIMARY KEY,
  mitarbeiter_id UUID REFERENCES dim_mitarbeiter(id),
  year INT NOT NULL,
  homeoffice_allowance_days NUMERIC(4,1) DEFAULT 20,
  homeoffice_used_days NUMERIC(4,1) DEFAULT 0,
  remote_work_allowance_days NUMERIC(4,1) DEFAULT 10,
  remote_work_used_days NUMERIC(4,1) DEFAULT 0,
  UNIQUE (mitarbeiter_id, year)
);
```

**UI-Constraints:**
- 48h-Vorlaufzeit
- Nicht in Wochen mit Ferien/Krankheit/Unterbesetzung
- Team-Abdeckung 70% vor Ort (via Team-Kalender-Query)
- Max 1/Woche HO · Max 2/Woche Remote
- Nach Probezeit-Ende

## 8. Plan §6.2 `fact_lohn_payment_schedule` (neu)

Generalis Provisio §5.2: Lohn zwischen 25.–30. des Monats, Dezember vor Weihnachten.

```sql
-- Nicht zwingend separate Tabelle — kann in Payroll-Integration abgebildet werden.
-- Hilfreich für UI-Anzeige "Nächster Lohnlauf: 28.04." etc.
CREATE VIEW v_next_lohn_payment_date AS
SELECT
  mitarbeiter_id,
  CASE
    WHEN EXTRACT(MONTH FROM CURRENT_DATE) = 12 THEN
      (DATE_TRUNC('month', CURRENT_DATE) + INTERVAL '22 days')::DATE  -- ~23.12.
    ELSE
      (DATE_TRUNC('month', CURRENT_DATE) + INTERVAL '27 days')::DATE  -- ~28. generell
  END AS next_payment_date
FROM dim_mitarbeiter
WHERE status = 'active';
```

## 9. Plan §6.4 Events-Erweiterung

Plan hat 13 Event-Codes. **Ergänzungen aus Ingest:**

| Event-Code | Trigger | Nutzer |
|------------|---------|--------|
| `warning_issued` | Verwarnung ausgestellt (erste/letzte) | HR + Vorgesetzter |
| `warning_acknowledged` | MA bestätigt Empfang | HR |
| `warning_follow_up_deadline` | 30 Tage nach letzter Verwarnung | HR + Eskalations-Entscheidung |
| `termination_annulled` | Kündigung zurückgenommen | HR + Payroll + Audit |
| `disciplinary_incident_reported` | Disziplinar-Vorfall gemeldet | HR + Investigation-Worker |
| `disciplinary_penalty_confirmed` | Strafe bestätigt | Payroll (Verrechnung) |
| `reglement_version_published` | Neue Reglement-Version (Generalis Provisio/Tempus Passio/Locus Extra) | alle MA-Signatur-Request |
| `reglement_signed_by_ma` | MA signiert neues Reglement | HR-Audit |
| `provisionsvertrag_jahres_renewal_due` | Jährliche Erneuerung Praemium Victoria | HR + CM/AM/TL · Budget-Ziel-Setting |
| `training_agreement_repayment_due` | Weiterbildungs-Austritt triggert Rückzahlung | Payroll + Backoffice |
| `konkurrenzverbot_period_ended` | 18-Mt-Post-Austritt-Clock abgelaufen | Audit (Alumni-Status-Update) |
| `homeoffice_request_submitted` | Antrag eingereicht | Vorgesetzter |
| `homeoffice_request_decision` | Genehmigt/abgelehnt | MA |
| `academy_module_completed` | Modul abgeschlossen | Trainer + HR |
| `birthday_extra_day_eligible` | Geburtstagswoche erreicht | MA (Notification-Reminder) |
| `zeg_half_year_calculated` | ZEG H1 (31.08.) oder H2 (28.02.) | MA + Backoffice · Extra-Guthaben setzen |

## 10. Umsetzungs-Phasen — Anpassungen zum Plan §8

### Phase 3.0 · HR-Fundament — bleibt, aber erweitert

- `dim_job_descriptions` (Progressus) seeden **mit Seeds**
- `dim_reglemente` seeden (3 Reglemente × Versionen)
- `fact_contract_attachments` schema
- Karenzentschädigung-Feld + Konkurrenzverbot-Felder auf `fact_employment_contracts`
- `dim_disciplinary_penalty_types` + Seed

### Phase 3.0+ · Signatur-Flow (kleine Erweiterung)

- UI: Neuer MA-Drawer mit 4 Tabs (Basis / Vertrag / Anhänge / Review + Bundle-PDF)
- Signatur-Service-Integration (z.B. Skribble + DocuSign-Alternative)

### Phase 3.1 · Absenzen+Kalender — erweitert

- Arztzeugnis-Staffelung (Dienstjahr-basiert) als Rule
- Extra-Guthaben als separate Ferien-Konten (Geburtstag-Constraint, Jokertag, ZEG-Belohnung)
- Ferienkürzungs-Regel (> 2 Mt Absenz → 1/12/Mt)
- Sperrfristen-Validation bei Extra-Guthaben-Bezug

### Phase 3.1+ · Home-Office-Quota (neu)

- `fact_homeoffice_requests` + `fact_homeoffice_quota_usage`
- UI: Locus-Extra-Antrags-Drawer (Projekte + 48h-Check)
- Quota-Dashboard pro MA

### Phase 3.2 · Onboarding+Zertifikate — erweitert

- `dim_academy_modules` seeden (Communication Edge 1-3, M4, Lernkarteien, M 1-4 Module)
- `fact_academy_progress` tracking
- Onboarding-Template ↔ Academy-Module-Mapping (Consultant vs Researcher)

### Phase 3.3 · Dokumente+DSG-Retention — bleibt

- Zusätzliche Document-Types seeden: `aufhebungsvereinbarung_*`, `verwarnung_*`, `kuendigung_annullierung`, `reglement_*`, `provisionsvertrag_*`, `weiterbildungsvereinbarung`, `kkv_merkblatt_rücklauf`, `abredeversicherung_merkblatt_rücklauf`

### Phase 3.4 · Lifecycle+Kanban — erweitert

- **Warning/Eskalations-Sub-Flow** (Active → Under-Watch → Final-Watch → Offboarding-Branches)
- **Annullierungs-Flow** (reverse Transition)
- **Role-Transitions** (Researcher→Consultant mit §5.3-Praemium-Grace-Period)

### Phase 3.4+ · Offboarding-Checkliste (Arkadium-Seed)

15 konkrete Tasks siehe [[hr-austritt-versicherung-merkblaetter]] §Offboarding-Template-Seed.

### Phase 3.5 · Self-Service — bleibt

### Phase 3.6 · Reports+Org-Chart + Arbeitszeugnis-Generator — bleibt

- **Arbeitszeugnis-Generator** mit Textbaustein-Bibliothek (siehe offene Frage [[hr-arbeitszeugnisse]])
- **Konkurrenzverbot-Monitor** post-Austritt (Alumni-Status + 18-Mt-Countdown)

### Neu · Phase 3.7 · Disziplinar + Verwarnungs-Modul

- `fact_warnings` + `fact_disciplinary_incidents`-UI
- Workflow Verwarnung → Follow-up → Entscheidung
- Verrechnung mit Lohn (Payroll-Integration)

### Neu · Phase 3.8 · Provisionsvertrag-Renewal-Cycle

- `fact_provisionsvertrag_versions` jährliche Erneuerung
- Budget-Ziel-Setting-Workflow Q4 Vorjahr
- Integration mit Commission-Engine (Memory `project_commission_model.md`)

## 11. Neue offene Fragen aus Ingest (über Plan §11 hinaus)

1. **Reglement-Versionierung:** Bei neuer Version (z.B. Generalis Provisio 2025-01-01) — Pflicht zur Signatur aller MA vs opt-in?
2. **Karenzentschädigung bei Beförderung Researcher → Consultant:** sofort CHF 500 oder pro-rata-Anpassung?
3. **Academy-Trainer:** separate Rolle oder übernimmt Head-of-Department?
4. **Disziplinar-Verrechnung mit Lohn:** automatisch oder nur nach GL-Bestätigung?
5. **Praemium-Victoria-Jahres-Erneuerung:** Kalenderjahr oder Geschäftsjahr? (Beispiel-Vorlage zeigt 01.04.–31.12.)
6. **Honorarstreitigkeit-Sonderfall (§6.1 Praemium Victoria):** wo in Commission-Engine abgebildet — als `fact_extraordinary_revenue` separat?
7. **Annullierung der Kündigung:** wie Lifecycle-Stage-Reversal im Kanban (Offboarding → Active) UI-seitig abbilden?
8. **Alumni-Status + Konkurrenzverbot-Clock:** separater Active-Watch-Tracker für LinkedIn-Aktivitäts-Alerts (DSG-konform)?
9. **Scheelen-Zertifikate (MDI · Relief · ASSESS · EQ)** aus Plan §1 — wo eingeben (beim Onboarding-Zertifikat-Erfassen-Drawer)?
10. **Lohnzahlungs-Kalender (25.–30. Standard, Dezember pre-Xmas):** als `dim_payment_calendar` seeden oder inline?
11. **Extra-Guthaben-Verfall bei Kündigung:** Tempus Passio §7.1 — automatisch am Kündigungs-Datum oder am letzten Arbeitstag?
12. **Head-of-Department-Pflichten:** Signatur-Recht auf Provisionsverträge der Unterstellten — in `fact_provisionsvertrag_versions` abbilden?

## 12. Priorisierung für Peter

**Blocker für Schema v0.1:**
- Frage 8 (Arztzeugnis-Staffelung) → **bestätigt** aus Ingest
- Frage 12 (Probezeit-Default) → **bestätigt** 3 Mt
- Frage 9 (Ferien-Übertrag) → **neu** Ostern+14 statt Kalenderjahr

**Nice-to-have vor Schema v0.1:**
- Neue offene Frage 1 (Reglement-Versionierung) — beeinflusst UI-Flow
- Neue offene Frage 5 (Praemium-Victoria-Zyklus) — beeinflusst `fact_provisionsvertrag_versions`

**Verschieben auf Implementierung:**
- Neue offene Fragen 3, 7, 8, 10, 11 — nicht schema-relevant, UI/Workflow-Entscheidungen

## Related

- [[hr-arbeitsvertraege]] · [[hr-reglemente]] · [[hr-provisionsvertraege]] · [[hr-arbeitszeugnisse]] · [[hr-weiterbildungsvereinbarung]] · [[hr-stellenbeschreibung-progressus]] · [[hr-kuendigung-aufhebung]] · [[hr-austritt-versicherung-merkblaetter]]
- [[hr-vertragswerk]] · [[hr-academy]] · [[hr-konkurrenz-abwerbeverbot]] · [[hr-ma-rollen-matrix]]
- `specs/ARK_HR_TOOL_PLAN_v0_1.md` (Plan der erweitert wird)
- `specs/ARK_COMMISSION_ENGINE_SPEC_v0_1.md` (Commission-Engine für Praemium-Victoria-Integration)
