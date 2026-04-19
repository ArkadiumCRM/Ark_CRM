---
title: "ARK HR-Tool · Schema v0.1"
type: schema
phase: 3
created: 2026-04-19
updated: 2026-04-19
status: draft
based_on: "ARK_HR_TOOL_PLAN_v0_2.md (po-reviewed 2026-04-19)"
sources: [
  "ARK_HR_TOOL_PLAN_v0_2.md",
  "wiki/analyses/hr-schema-deltas-2026-04-19.md",
  "wiki/concepts/hr-vertragswerk.md",
  "wiki/concepts/hr-academy.md",
  "wiki/concepts/hr-konkurrenz-abwerbeverbot.md",
  "wiki/concepts/hr-ma-rollen-matrix.md",
  "raw/Ark_CRM_v2/ARK_DATABASE_SCHEMA_v1_3.md",
  "raw/HR/2_HR On- Offboarding/"
]
tags: [schema, ddl, hr, phase-3, arkadium, vertragswerk, praemium-victoria, academy]
---

# ARK HR-Tool · Schema v0.1

Komplette DDL-Definition für das HR-Tool. Basierend auf Plan v0.2 (po-reviewed) mit allen 18 finalisierten Entscheidungen. Als Migration-Skript ausführbar nach Bestätigung durch DBA + Backend-Lead.

**Konventionen** (gemäss `ARK_DATABASE_SCHEMA_v1_3.md` Naming):
- `dim_*` Stammdaten · `fact_*` Fakten · `bridge_*` N:N-Verknüpfungen · `audit_*` Audit-Trails · `v_*` Views
- UUID-PKs · `snake_case` Spalten · TIMESTAMPTZ für Zeit · CHECK-Constraints für ENUMs (keine nativen ENUM-Types)
- Soft-Delete via `deleted_at TIMESTAMPTZ` · Optimistic-Locking via `updated_at TIMESTAMPTZ`
- Sensible Felder (AHV · Pass · Gehalt): BYTEA verschlüsselt + Audit-Log-Pflicht

## TOC

- §1 Scope + Feature-Flag
- §2 Erweiterung `dim_mitarbeiter`
- §3 Vertragswerk: `dim_job_descriptions` · `dim_reglemente` · `fact_employment_contracts` · `fact_contract_attachments`
- §4 Provisionsverträge: `fact_provisionsvertrag_versions` · `fact_role_transitions`
- §5 Absenzen: `dim_absence_types` · `fact_absences` · `fact_vacation_balances` · `dim_holidays`
- §6 Home-Office: `fact_homeoffice_requests` · `fact_homeoffice_quota_usage`
- §7 Academy: `dim_academy_modules` · `fact_academy_progress`
- §8 Zertifikate + Training: `dim_certifications` · `fact_employee_certifications` · `fact_training_requests` · `fact_training_agreements`
- §9 Onboarding + Lifecycle: `dim_onboarding_templates` · `fact_onboarding_instances` · `fact_lifecycle_transitions`
- §10 Verwarnungen + Disziplinar: `fact_warnings` · `dim_disciplinary_penalty_types` · `fact_disciplinary_incidents`
- §11 Dokumente + Notfallkontakte + Audit + Kompensation: `fact_hr_documents` · `dim_emergency_contacts` · `audit_hr_access` · `fact_compensation_history` · `fact_jubilaeum_handled`
- §12 Views: `v_hr_alerts` · `v_next_lohn_payment_date` · `v_training_repayment_obligations` · `v_scheelen_certification_missing`
- §13 Config-Settings: `dim_automation_settings`-Keys
- §14 Seeds (Scheelen · Reglemente · Job-Descriptions · Academy-Module · Absence-Types · Holidays-ZH · Disciplinary-Penalties)
- §15 Indices + Performance
- §16 RBAC-Regeln
- §17 Migrations-Reihenfolge
- §18 Related + Changelog

---

## §1 Scope + Feature-Flag

**Feature-Flag:** `feature_hr_tool` in `dim_automation_settings` · Default `false` (locked bis Phase-3-Go-Live).

```sql
-- Bereits in Plan v0.1 vorhanden, hier nur Verweis:
-- INSERT INTO dim_automation_settings (key, value, description)
-- VALUES ('feature_hr_tool', 'false', 'HR-Tool Phase-3 Unlock-Flag. Unlock bei Go-Live.')
-- ON CONFLICT (key) DO NOTHING;
```

**Neue HR-Config-Keys** (siehe §13).

---

## §2 Erweiterung `dim_mitarbeiter`

```sql
ALTER TABLE dim_mitarbeiter ADD COLUMN IF NOT EXISTS
  -- Person
  geburtsdatum DATE,
  geschlecht TEXT CHECK (geschlecht IN ('w','m','d')),
  nationalitaet TEXT,
  zivilstand TEXT CHECK (zivilstand IN ('ledig','verheiratet','geschieden','verwitwet','partnerschaft')),
  muttersprache TEXT DEFAULT 'de',
  weitere_sprachen JSONB,

  -- Adresse
  adresse_strasse TEXT,
  adresse_plz TEXT,
  adresse_ort TEXT,
  adresse_kanton CHAR(2),
  adresse_land TEXT DEFAULT 'CH',

  -- CH-Compliance (sensible Felder · AES-256 + Audit-Log-Pflicht)
  ahv_nr_hash TEXT,
  ahv_nr_encrypted BYTEA,
  pass_nr_encrypted BYTEA,
  pass_gueltig_bis DATE,
  arbeitsbewilligung_typ TEXT CHECK (arbeitsbewilligung_typ IS NULL OR arbeitsbewilligung_typ IN ('CH','B','C','L','G','Grenzgaenger','andere')),
  arbeitsbewilligung_gueltig_bis DATE,
  pensionskasse_name TEXT,
  pensionskasse_nr TEXT,
  hintergrund_check_date DATE,
  hintergrund_check_result TEXT,

  -- Lifecycle-Stage (Bewerber raus · Lifecycle startet bei Offer)
  lifecycle_stage TEXT DEFAULT 'aktiv' CHECK (lifecycle_stage IN (
    'offer','vertrag','onboarding','aktiv',
    'under_watch','final_watch',
    'offboarding_amicable','offboarding_immediate','offboarding_notice','offboarding_special',
    'alumni'
  )),
  lifecycle_stage_since TIMESTAMPTZ DEFAULT now(),

  -- Vertragswerk-Version-Tracking
  current_job_description_id UUID,      -- FK wird nach §3 gesetzt
  current_reglement_generalis_provisio_version TEXT,
  current_reglement_tempus_passio_version TEXT,
  current_reglement_locus_extra_version TEXT,

  -- Org-Struktur
  head_of_department_id UUID REFERENCES dim_mitarbeiter(id),
  signing_authority TEXT CHECK (signing_authority IN ('none','limited','full')) DEFAULT 'none',

  -- Alumni-Konkurrenzverbot-Clock (wird bei Austritt gesetzt: austrittsdatum + 18 Mt)
  konkurrenzverbot_aktiv_bis DATE,

  -- Geburtstags-Sichtbarkeit (Peter-Entscheidung §11B-11: Opt-in)
  birthday_visible_in_team_calendar BOOLEAN DEFAULT false,

  -- Tier-2-Ingest-Erweiterung 2026-04-19 (aus Personalstammdaten-Formular Treuhand Kunz)
  email_private TEXT,                               -- private Email für Lohnabrechnung
  heirat_datum DATE,
  partner_erwerbstaetig BOOLEAN,
  kinder JSONB,                                     -- [{"name":"...","geburtsdatum":"YYYY-MM-DD"}]
  konfession TEXT,
  quellensteuer_pflichtig BOOLEAN DEFAULT false,
  quellensteuer_kanton CHAR(2);                     -- Kanton für Quellensteuer-Tarif

-- DEPRECATED: commission_rate (ersetzt durch fact_provisionsvertrag_versions)
-- Kein DROP in v0.1 · bleibt rückwärtskompatibel · Migration separat
COMMENT ON COLUMN dim_mitarbeiter.commission_rate IS 'DEPRECATED 2026-04-19: ersetzt durch fact_provisionsvertrag_versions. Nicht mehr schreiben. Zum Entfernen: separate Migration nach Go-Live.';
```

---

## §3 Vertragswerk

### §3.1 `dim_job_descriptions` (Progressus versioniert)

```sql
CREATE TABLE dim_job_descriptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code TEXT UNIQUE NOT NULL,
  name_de TEXT NOT NULL,
  bereich TEXT NOT NULL,
  abteilung TEXT,
  sparte TEXT,                                     -- 'ARC','REM','ING','TEC' oder mehrere
  signing_authority BOOLEAN DEFAULT false,
  default_pensum INT DEFAULT 100,
  zielbeschreibung_de TEXT,
  aufgaben JSONB,                                  -- Array von Bullets
  anforderungen JSONB,                             -- {ausbildung, weiterbildung, erfahrung, kompetenzen, sprachen}
  version TEXT NOT NULL,                           -- '2024-01-01'
  valid_from DATE NOT NULL,
  valid_until DATE,
  document_url TEXT,
  superseded_by UUID REFERENCES dim_job_descriptions(id),
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_job_descriptions_code_version ON dim_job_descriptions(code, version);
CREATE INDEX idx_job_descriptions_valid ON dim_job_descriptions(valid_from, valid_until);
```

FK nachziehen:

```sql
ALTER TABLE dim_mitarbeiter
  ADD CONSTRAINT fk_mitarbeiter_job_description
  FOREIGN KEY (current_job_description_id) REFERENCES dim_job_descriptions(id);
```

### §3.2 `dim_reglemente` (versionierte Anhänge)

```sql
CREATE TABLE dim_reglemente (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  latin_name TEXT NOT NULL CHECK (latin_name IN (
    'generalis_provisio', 'tempus_passio_365', 'locus_extra'
  )),
  name_de TEXT NOT NULL,
  description_de TEXT,
  version TEXT NOT NULL,                           -- '2024-01-01'
  valid_from DATE NOT NULL,
  valid_until DATE,
  document_draft_url TEXT,
  document_digital_url TEXT,
  document_print_url TEXT,                         -- DRUCK = kanonisch für Signatur
  changelog JSONB,
  superseded_by UUID REFERENCES dim_reglemente(id),
  -- Peter-Entscheidung §11C-1: Fall-zu-Fall
  requires_bulk_resignature BOOLEAN DEFAULT false,
  bulk_resignature_deadline DATE,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE (latin_name, version)
);

CREATE INDEX idx_reglemente_valid ON dim_reglemente(latin_name, valid_from, valid_until);
```

### §3.3 `fact_employment_contracts`

```sql
CREATE TABLE fact_employment_contracts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  mitarbeiter_id UUID NOT NULL REFERENCES dim_mitarbeiter(id),
  contract_type TEXT NOT NULL CHECK (contract_type IN (
    'unbefristet','befristet','praktikum','lehre','mandat','fix_term'
  )),
  valid_from DATE NOT NULL,
  valid_until DATE,
  pensum_percent NUMERIC(4,1) NOT NULL CHECK (pensum_percent > 0 AND pensum_percent <= 100),
  hours_per_week NUMERIC(4,2) NOT NULL,

  -- Stellenbeschreibung
  job_description_id UUID REFERENCES dim_job_descriptions(id),
  jobtitel TEXT,                                   -- Fallback wenn kein Progressus
  funktions_stufe TEXT,

  -- Arbeitsort + HO
  arbeitsort TEXT,
  home_office_allowance_days_year INT DEFAULT 20,  -- Locus Extra §
  remote_work_allowance_days_year INT DEFAULT 10,

  -- Probezeit + Kündigung (JSONB, Peter-Entscheidung §11A-8+12)
  probezeit_monate INT DEFAULT 3,
  probezeit_ende DATE GENERATED ALWAYS AS (
    valid_from + (probezeit_monate || ' months')::INTERVAL
  ) STORED,
  kuendigungsfristen_jsonb JSONB NOT NULL DEFAULT '{
    "probezeit_tage": 3,
    "dj_1_monate": 1,
    "dj_2_5_monate": 2,
    "dj_6_plus_monate": 3
  }'::jsonb,

  -- Karenzentschädigung (monatlich zum Gehalt · §11A-7 / Arbeitsvertrag)
  karenzentschaedigung_chf_mt NUMERIC(8,2) NOT NULL DEFAULT 0,

  -- Konkurrenzverbot (nachvertraglich, 18 Mt Deutschschweiz)
  konkurrenzverbot_monate INT DEFAULT 18,
  konkurrenzverbot_region TEXT DEFAULT 'Deutschschweiz',
  konkurrenzverbot_branche_scope TEXT[] DEFAULT ARRAY[
    'bau_hauptgewerbe','bau_nebengewerbe','architecture',
    'civil_engineering','real_estate_management','building_technology','energy_environmental'
  ],
  konkurrenzverbot_konventionalstrafe_min_chf NUMERIC(10,2) DEFAULT 80000,
  konkurrenzverbot_konventionalstrafe_formula TEXT DEFAULT '12 Bruttomonatslöhne inkl. Provisionen/Spesen, min CHF 80000',

  -- Abwerbeverbot
  abwerbeverbot_monate INT DEFAULT 18,
  abwerbeverbot_konventionalstrafe_chf NUMERIC(10,2) DEFAULT 80000,

  -- Nachvertragliche Geheimhaltung
  nachvertragliche_geheimhaltung_konventionalstrafe_chf NUMERIC(10,2) DEFAULT 20000,

  -- Ferien (Tempus Passio §6.1)
  ferien_tage_jahr NUMERIC(4,1) DEFAULT 25,

  -- Lohn-Auszahlungsrhythmus (Generalis Provisio §5.2)
  lohn_payment_window TEXT DEFAULT '25_30_of_month',

  -- Dokumente + Signaturen
  vertrag_dokument_url TEXT,
  signed_at TIMESTAMPTZ,
  signed_by_mitarbeiter BOOLEAN DEFAULT false,
  signed_by_head_of_department BOOLEAN DEFAULT false,
  signed_by_founder BOOLEAN DEFAULT false,

  is_active BOOLEAN GENERATED ALWAYS AS (
    (valid_until IS NULL OR valid_until >= CURRENT_DATE) AND valid_from <= CURRENT_DATE
  ) STORED,

  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  created_by UUID REFERENCES dim_mitarbeiter(id)
);

CREATE INDEX idx_contracts_mitarbeiter ON fact_employment_contracts(mitarbeiter_id);
CREATE INDEX idx_contracts_active ON fact_employment_contracts(mitarbeiter_id) WHERE is_active = true;
CREATE INDEX idx_contracts_probezeit ON fact_employment_contracts(probezeit_ende) WHERE valid_until IS NULL;
```

### §3.4 `fact_contract_attachments`

```sql
CREATE TABLE fact_contract_attachments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  contract_id UUID NOT NULL REFERENCES fact_employment_contracts(id) ON DELETE CASCADE,
  attachment_type TEXT NOT NULL CHECK (attachment_type IN (
    'reglement_generalis_provisio',
    'reglement_tempus_passio',
    'reglement_locus_extra',
    'stellenbeschreibung_progressus',
    'provisionsvertrag_praemium_victoria',
    'weiterbildungsvereinbarung',
    'other'
  )),
  reglement_id UUID REFERENCES dim_reglemente(id),
  job_description_id UUID REFERENCES dim_job_descriptions(id),
  provisionsvertrag_version_id UUID,               -- FK wird nach §4 gesetzt
  training_agreement_id UUID,                       -- FK wird nach §8 gesetzt
  other_document_url TEXT,
  signed_at TIMESTAMPTZ,
  signed_by_mitarbeiter BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_contract_attachments_contract ON fact_contract_attachments(contract_id);
CREATE INDEX idx_contract_attachments_type ON fact_contract_attachments(attachment_type);
```

---

## §4 Provisionsverträge + Rollen-Transitions

### §4.1 `fact_provisionsvertrag_versions` (Praemium Victoria)

Peter-Entscheidung §11C-5: **Kalenderjahr fix** (01.01.–31.12.) · Neu-Eintritte pro-rata. §11C-12: Beide Signaturen Pflicht.

```sql
CREATE TABLE fact_provisionsvertrag_versions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  mitarbeiter_id UUID NOT NULL REFERENCES dim_mitarbeiter(id),
  fiscal_year INT NOT NULL,
  fiscal_period_start DATE NOT NULL,               -- für Normalfall 01.01.Year · Neueintritt Eintrittsdatum
  fiscal_period_end DATE NOT NULL,                 -- 31.12.Year
  role_at_contract TEXT NOT NULL CHECK (role_at_contract IN (
    'consultant','researcher','candidate_manager','account_manager','team_leader','head_of_department'
  )),
  budget_goal_chf NUMERIC(12,2) NOT NULL,
  team_budget_goal_chf NUMERIC(12,2),              -- nur bei Team Leader + Head
  fix_salary_year_chf NUMERIC(10,2) NOT NULL,
  variable_100pct_chf NUMERIC(10,2) NOT NULL,
  spesenpauschale_chf_mt NUMERIC(8,2) DEFAULT 300,
  zeg_staffel_id UUID,                              -- wird in Commission-Engine geschrieben
  payout_advance_pct NUMERIC(5,2) DEFAULT 80.0,    -- 80/20-Split

  -- Dokumente
  document_url TEXT,

  -- Signaturen (§11C-12: alle 3 Pflicht)
  signed_at TIMESTAMPTZ,
  signed_by_mitarbeiter BOOLEAN DEFAULT false,
  signed_by_head_of_department BOOLEAN DEFAULT false,
  signed_by_founder BOOLEAN DEFAULT false,

  -- is_active nur wenn alle 3 signiert + innerhalb fiscal-Period
  is_active BOOLEAN GENERATED ALWAYS AS (
    signed_by_mitarbeiter = true
    AND signed_by_head_of_department = true
    AND signed_by_founder = true
    AND fiscal_period_start <= CURRENT_DATE
    AND fiscal_period_end >= CURRENT_DATE
  ) STORED,

  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE (mitarbeiter_id, fiscal_year)
);

CREATE INDEX idx_provisionsvertrag_active ON fact_provisionsvertrag_versions(mitarbeiter_id) WHERE is_active = true;
CREATE INDEX idx_provisionsvertrag_renewal ON fact_provisionsvertrag_versions(fiscal_period_end);

-- FK-Nachziehen für §3.4
ALTER TABLE fact_contract_attachments
  ADD CONSTRAINT fk_contract_attachments_provisionsvertrag
  FOREIGN KEY (provisionsvertrag_version_id) REFERENCES fact_provisionsvertrag_versions(id);
```

### §4.2 `fact_role_transitions` (§5.3-Praemium-Grace-Period)

Peter-Entscheidung §11C-2: **Individualverhandlung** · `new_karenzentschaedigung_chf_mt` manuell.

```sql
CREATE TABLE fact_role_transitions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  mitarbeiter_id UUID NOT NULL REFERENCES dim_mitarbeiter(id),
  from_role TEXT NOT NULL,
  to_role TEXT NOT NULL,
  effective_date DATE NOT NULL,
  reason TEXT CHECK (reason IN (
    'promotion','lateral_move','demotion','specialization','initial_assignment'
  )),
  new_karenzentschaedigung_chf_mt NUMERIC(8,2),    -- optional · manuell gesetzt
  new_contract_id UUID REFERENCES fact_employment_contracts(id),
  -- §5.3 Praemium Victoria: 3 Mt Grace-Period für alte Researcher-Vermittlungen
  provision_grace_period_months INT DEFAULT 3,
  grace_period_ends_at DATE GENERATED ALWAYS AS (
    effective_date + (provision_grace_period_months || ' months')::INTERVAL
  ) STORED,
  approved_by UUID REFERENCES dim_mitarbeiter(id),
  approved_at TIMESTAMPTZ,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_role_transitions_mitarbeiter ON fact_role_transitions(mitarbeiter_id, effective_date);
CREATE INDEX idx_role_transitions_grace ON fact_role_transitions(grace_period_ends_at) WHERE grace_period_ends_at >= CURRENT_DATE;
```

---

## §5 Absenzen

### §5.1 `dim_absence_types` (mit Arzt-Staffelung + Extra-Guthaben)

Peter-Entscheidung §11A-8: **Dienstjahr-Staffelung** für Arztzeugnis.

```sql
CREATE TABLE dim_absence_types (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code TEXT UNIQUE NOT NULL,
  label_de TEXT NOT NULL,
  paid BOOLEAN NOT NULL,
  requires_certificate BOOLEAN NOT NULL,
  certificate_rule_type TEXT CHECK (certificate_rule_type IN (
    'never','always_day_1','after_n_days_fixed','staffelung_by_dienstjahr'
  )),
  certificate_staffelung_jsonb JSONB,               -- z.B. '{"dj_1":1,"dj_2":2,"dj_3_plus":3}'
  certificate_fixed_day INT,                        -- bei after_n_days_fixed
  requires_approval BOOLEAN NOT NULL,
  auto_approve_threshold_days INT,
  counts_towards_vacation_balance BOOLEAN DEFAULT false,
  max_days_per_year INT,
  extra_guthaben_kategorie BOOLEAN DEFAULT false,   -- a/b/c: verfallen bei Kündigung (Tempus Passio §7.1)
  bezugs_constraint_jsonb JSONB,                    -- z.B. '{"only_in_birthday_week": true}' oder '{"only_in_blocked_periods": true}'
  sort_order INT
);

CREATE INDEX idx_absence_types_code ON dim_absence_types(code);
```

### §5.2 `fact_absences`

```sql
CREATE TABLE fact_absences (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  mitarbeiter_id UUID NOT NULL REFERENCES dim_mitarbeiter(id),
  absence_type_id UUID NOT NULL REFERENCES dim_absence_types(id),
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  half_day_start BOOLEAN DEFAULT false,
  half_day_end BOOLEAN DEFAULT false,
  working_days NUMERIC(5,2) NOT NULL,
  notes TEXT,
  approval_status TEXT DEFAULT 'pending' CHECK (approval_status IN (
    'pending','approved','rejected','cancelled','auto_approved'
  )),
  approved_by UUID REFERENCES dim_mitarbeiter(id),
  approved_at TIMESTAMPTZ,
  rejection_reason TEXT,
  requested_at TIMESTAMPTZ DEFAULT now(),
  requested_by UUID REFERENCES dim_mitarbeiter(id),

  -- Arztzeugnis (computed via Trigger aus dim_absence_types + Dienstjahr)
  certificate_required BOOLEAN DEFAULT false,
  certificate_uploaded_at TIMESTAMPTZ,
  certificate_document_url TEXT,

  -- Ferien-Vertretung
  stellvertretung_id UUID REFERENCES dim_mitarbeiter(id),
  outlook_autoreply BOOLEAN DEFAULT true,

  -- Cancel
  cancelled_at TIMESTAMPTZ,
  cancelled_reason TEXT,

  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_absences_mitarbeiter_dates ON fact_absences(mitarbeiter_id, start_date, end_date);
CREATE INDEX idx_absences_pending ON fact_absences(approval_status, requested_at) WHERE approval_status = 'pending';
CREATE INDEX idx_absences_type ON fact_absences(absence_type_id);
```

### §5.3 `fact_vacation_balances` (Extra-Guthaben-Konten)

Peter-Entscheidung §11A-9: **Ostermontag+14** als Carry-Deadline. §11C-11: **Ab Kündigungs-Einreichung Verfall a/b/c** mit Override-Option.

```sql
CREATE TABLE fact_vacation_balances (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  mitarbeiter_id UUID NOT NULL REFERENCES dim_mitarbeiter(id),
  year INT NOT NULL,

  -- Standard-Ferien (25 Tage / Vollzeit, pro-rata bei Teilzeit)
  vacation_default_days NUMERIC(4,1) DEFAULT 25.0,
  vacation_used_days NUMERIC(4,1) DEFAULT 0,
  vacation_pending_days NUMERIC(4,1) DEFAULT 0,

  -- Übertrag Vorjahr (bis Ostermontag+14 zu beziehen · jüngste zuerst)
  carried_from_prev_year NUMERIC(4,1) DEFAULT 0,
  carry_deadline_date DATE,                         -- gesetzt durch Easter-Worker pro Jahr

  -- Extra-Guthaben a (Geburtstag MA · 1 Tag/J)
  extra_birthday_self_days NUMERIC(3,1) DEFAULT 1.0,
  extra_birthday_self_used NUMERIC(3,1) DEFAULT 0,

  -- Extra-Guthaben b (Geburtstag nahestehend · 1 Tag/J)
  extra_birthday_close_days NUMERIC(3,1) DEFAULT 1.0,
  extra_birthday_close_used NUMERIC(3,1) DEFAULT 0,

  -- Extra-Guthaben c (Jokertag · 1 Tag/J)
  extra_joker_days NUMERIC(3,1) DEFAULT 1.0,
  extra_joker_used NUMERIC(3,1) DEFAULT 0,

  -- Extra-Guthaben d (Zielerreichung · gesetzt durch ZEG-Worker)
  extra_zeg_h1_days NUMERIC(3,1) DEFAULT 0,        -- wird Ende August gesetzt
  extra_zeg_h1_used NUMERIC(3,1) DEFAULT 0,
  extra_zeg_h2_days NUMERIC(3,1) DEFAULT 0,        -- wird Ende Februar Folgejahr gesetzt
  extra_zeg_h2_used NUMERIC(3,1) DEFAULT 0,

  -- Extra-Guthaben GL-Ermessen (0-3 Tage)
  extra_gl_discretionary_days NUMERIC(3,1) DEFAULT 0,
  extra_gl_discretionary_used NUMERIC(3,1) DEFAULT 0,

  -- Peter-Entscheidung §11C-11: Verfall-Override
  extra_abc_grant_override_at TIMESTAMPTZ,
  extra_abc_grant_override_by UUID REFERENCES dim_mitarbeiter(id),
  extra_abc_grant_override_reason TEXT,

  vacation_remaining NUMERIC(4,1) GENERATED ALWAYS AS (
    vacation_default_days + carried_from_prev_year - vacation_used_days - vacation_pending_days
  ) STORED,

  UNIQUE (mitarbeiter_id, year)
);

CREATE INDEX idx_vacation_balances_mitarbeiter ON fact_vacation_balances(mitarbeiter_id);
```

### §5.4 `dim_holidays` (Kantonale Feiertage)

Peter-Entscheidung §11A-6: **ZH initial** · Seeds in §14.

```sql
CREATE TABLE dim_holidays (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  canton CHAR(2) NOT NULL,
  year INT NOT NULL,
  date DATE NOT NULL,
  name_de TEXT NOT NULL,
  is_half_day BOOLEAN DEFAULT false,
  is_working_day_alternative BOOLEAN DEFAULT false,
  source TEXT DEFAULT 'manual',                    -- 'manual' | 'official_import'
  UNIQUE (canton, date)
);

CREATE INDEX idx_holidays_canton_year ON dim_holidays(canton, year);
```

---

## §6 Home-Office + Remote-Work (Locus Extra)

```sql
CREATE TABLE fact_homeoffice_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  mitarbeiter_id UUID NOT NULL REFERENCES dim_mitarbeiter(id),
  requested_date DATE NOT NULL,
  request_type TEXT NOT NULL CHECK (request_type IN ('homeoffice','remote_work')),
  submitted_at TIMESTAMPTZ DEFAULT now(),
  project_context TEXT,                            -- Locus Extra: konkrete Projekte angeben
  status TEXT DEFAULT 'pending' CHECK (status IN (
    'pending','approved','rejected','cancelled'
  )),
  approved_by UUID REFERENCES dim_mitarbeiter(id),
  approved_at TIMESTAMPTZ,
  rejection_reason TEXT,
  UNIQUE (mitarbeiter_id, requested_date)
);

CREATE INDEX idx_homeoffice_requests_pending ON fact_homeoffice_requests(status, submitted_at) WHERE status = 'pending';
CREATE INDEX idx_homeoffice_requests_mitarbeiter ON fact_homeoffice_requests(mitarbeiter_id, requested_date);

CREATE TABLE fact_homeoffice_quota_usage (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  mitarbeiter_id UUID NOT NULL REFERENCES dim_mitarbeiter(id),
  year INT NOT NULL,
  homeoffice_allowance_days NUMERIC(4,1) DEFAULT 20,
  homeoffice_used_days NUMERIC(4,1) DEFAULT 0,
  remote_work_allowance_days NUMERIC(4,1) DEFAULT 10,
  remote_work_used_days NUMERIC(4,1) DEFAULT 0,
  UNIQUE (mitarbeiter_id, year)
);
```

**Validation-Regeln (UI + Backend-Worker):**
- 48h-Lead-Time: `requested_date >= submitted_at + INTERVAL '2 days'`
- Probezeit-Check: `mitarbeiter_id NOT IN SELECT mitarbeiter_id FROM fact_employment_contracts WHERE probezeit_ende > CURRENT_DATE`
- Max 1/Woche HO · Max 2/Woche Remote: via COUNT-Query
- Team-Abdeckung 70% vor Ort: Team-Kalender-Query

---

## §7 Academy

Peter-Entscheidung §11C-3: **Multiple Trainer je Modul** · kein Academy_Lead-Rolle.

```sql
CREATE TABLE dim_academy_modules (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  module_code TEXT UNIQUE NOT NULL,                -- 'comm_edge_1','m4_modell','m_1_1_ident',...
  name_de TEXT NOT NULL,
  fachgebiet CHAR(1) CHECK (fachgebiet IN ('A','B','C')),
  part_number INT,
  duration_hours NUMERIC(5,1),
  document_urls JSONB,
  prerequisites UUID[] DEFAULT '{}',
  mandatory_for_roles TEXT[],
  default_trainer_ids UUID[] DEFAULT '{}',         -- §11C-3
  sort_order INT,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_academy_modules_fachgebiet ON dim_academy_modules(fachgebiet, part_number);

CREATE TABLE fact_academy_progress (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  mitarbeiter_id UUID NOT NULL REFERENCES dim_mitarbeiter(id),
  module_id UUID NOT NULL REFERENCES dim_academy_modules(id),
  started_at DATE,
  completed_at DATE,
  trainer_id UUID REFERENCES dim_mitarbeiter(id),
  self_assessment_score INT CHECK (self_assessment_score BETWEEN 1 AND 10),
  trainer_assessment_score INT CHECK (trainer_assessment_score BETWEEN 1 AND 10),
  notes TEXT,
  UNIQUE (mitarbeiter_id, module_id)
);

CREATE INDEX idx_academy_progress_mitarbeiter ON fact_academy_progress(mitarbeiter_id);
CREATE INDEX idx_academy_progress_completed ON fact_academy_progress(completed_at);
```

---

## §8 Zertifikate + Training

### §8.1 `dim_certifications` (Scheelen-Zertifikate inkl.)

Peter-Entscheidung §11C-9: **Alle 4 Scheelen (MDI · Relief · ASSESS · EQ) Pflicht für alle Rollen**.

```sql
CREATE TABLE dim_certifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name_de TEXT NOT NULL,
  issuer TEXT,
  category TEXT CHECK (category IN (
    'recruiting','assessment','soft_skills','technical','legal','other'
  )),
  typical_validity_months INT,
  renewable BOOLEAN DEFAULT true,
  is_mandatory_for_roles TEXT[],                   -- ['*'] = alle · ['consultant','researcher']
  sort_order INT,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE fact_employee_certifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  mitarbeiter_id UUID NOT NULL REFERENCES dim_mitarbeiter(id),
  certification_id UUID NOT NULL REFERENCES dim_certifications(id),
  acquired_at DATE NOT NULL,
  valid_until DATE,
  certificate_document_url TEXT,
  status TEXT GENERATED ALWAYS AS (
    CASE
      WHEN valid_until IS NULL THEN 'active'
      WHEN valid_until < CURRENT_DATE THEN 'expired'
      WHEN valid_until < CURRENT_DATE + INTERVAL '6 months' THEN 'expiring'
      ELSE 'active'
    END
  ) STORED,
  cost_chf NUMERIC(10,2),
  approved_by UUID REFERENCES dim_mitarbeiter(id)
);

CREATE INDEX idx_employee_certifications_mitarbeiter ON fact_employee_certifications(mitarbeiter_id);
CREATE INDEX idx_employee_certifications_expiring ON fact_employee_certifications(valid_until) WHERE valid_until IS NOT NULL;
```

### §8.2 `fact_training_requests` (aus Plan v0.1)

```sql
CREATE TABLE fact_training_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  mitarbeiter_id UUID NOT NULL REFERENCES dim_mitarbeiter(id),
  title TEXT NOT NULL,
  provider TEXT,
  type TEXT CHECK (type IN ('zertifizierung','seminar','konferenz','online','coaching')),
  start_date DATE,
  end_date DATE,
  duration_days NUMERIC(3,1),
  cost_chf NUMERIC(10,2),
  travel_cost_chf NUMERIC(10,2) DEFAULT 0,
  justification TEXT,
  expected_certificate BOOLEAN DEFAULT false,
  status TEXT DEFAULT 'draft' CHECK (status IN (
    'draft','submitted','approved','rejected','completed','cancelled'
  )),
  submitted_at TIMESTAMPTZ,
  approved_by UUID REFERENCES dim_mitarbeiter(id),
  approved_at TIMESTAMPTZ,
  linked_certification_id UUID REFERENCES fact_employee_certifications(id),
  created_at TIMESTAMPTZ DEFAULT now()
);
```

### §8.3 `fact_training_agreements` (Weiterbildungsvereinbarung)

```sql
CREATE TABLE fact_training_agreements (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  mitarbeiter_id UUID NOT NULL REFERENCES dim_mitarbeiter(id),
  training_request_id UUID REFERENCES fact_training_requests(id),
  title TEXT NOT NULL,
  provider TEXT,
  start_date DATE NOT NULL,
  expected_completion_date DATE NOT NULL,
  actual_completion_date DATE,
  pensum_reduction_percent NUMERIC(4,1) DEFAULT 0,
  gehalt_wird_voll_weiter_bezahlt BOOLEAN DEFAULT true,
  employer_contribution_per_semester_chf NUMERIC(10,2),
  semester_count INT,
  total_employer_contribution_chf NUMERIC(10,2) GENERATED ALWAYS AS (
    COALESCE(employer_contribution_per_semester_chf, 0) * COALESCE(semester_count, 0)
  ) STORED,
  repayment_threshold_date DATE,                   -- Stichtag ab dem Staffel startet (meist = actual_completion_date)
  agreement_document_url TEXT,
  signed_at TIMESTAMPTZ,
  status TEXT DEFAULT 'planned' CHECK (status IN (
    'planned','active','completed','aborted_personal','aborted_ag_cause'
  )),
  cancellation_date DATE,
  cancellation_reason TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- FK-Nachziehen für §3.4
ALTER TABLE fact_contract_attachments
  ADD CONSTRAINT fk_contract_attachments_training_agreement
  FOREIGN KEY (training_agreement_id) REFERENCES fact_training_agreements(id);
```

---

## §9 Onboarding + Lifecycle

```sql
CREATE TABLE dim_onboarding_templates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT,
  target_role TEXT,
  phases JSONB NOT NULL,
  academy_module_ids UUID[] DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE fact_onboarding_instances (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  mitarbeiter_id UUID NOT NULL REFERENCES dim_mitarbeiter(id),
  template_id UUID NOT NULL REFERENCES dim_onboarding_templates(id),
  started_at DATE NOT NULL,
  expected_completion_date DATE,
  actual_completion_date DATE,
  buddy_id UUID REFERENCES dim_mitarbeiter(id),
  mentor_id UUID REFERENCES dim_mitarbeiter(id),
  tasks_state JSONB,
  notes TEXT,
  status TEXT DEFAULT 'in_progress' CHECK (status IN ('in_progress','completed','abandoned')),
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_onboarding_instances_mitarbeiter ON fact_onboarding_instances(mitarbeiter_id);
```

### §9.3 `fact_lifecycle_transitions` (inkl. Annullierungen)

Peter-Entscheidung §11C-7: **Kontext-Menü-Aktion** für Annullierung, kein Drag-Rückwärts.

```sql
CREATE TABLE fact_lifecycle_transitions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  mitarbeiter_id UUID NOT NULL REFERENCES dim_mitarbeiter(id),
  from_stage TEXT,
  to_stage TEXT NOT NULL,
  transitioned_at TIMESTAMPTZ DEFAULT now(),
  transitioned_by UUID REFERENCES dim_mitarbeiter(id),
  reason TEXT CHECK (reason IN (
    'initial','promotion','demotion','probation_passed','probation_failed',
    'warning_issued','resignation','termination_ordentlich','termination_fristlos',
    'mutual_agreement','annullierung','retirement','death','special'
  )),
  warning_id UUID,                                 -- FK §10
  offboarding_template_id UUID REFERENCES dim_onboarding_templates(id),  -- ggf. Offboarding-Template
  annullierung_document_url TEXT,                  -- bei reason='annullierung'
  notes TEXT
);

CREATE INDEX idx_lifecycle_transitions_mitarbeiter ON fact_lifecycle_transitions(mitarbeiter_id, transitioned_at);
```

---

## §10 Verwarnungen + Disziplinar

### §10.1 `fact_warnings` (3-Stufen-Eskalation)

```sql
CREATE TABLE fact_warnings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  mitarbeiter_id UUID NOT NULL REFERENCES dim_mitarbeiter(id),
  warning_type TEXT NOT NULL CHECK (warning_type IN (
    'verbal','first_written','final_written','notice_fristlos'
  )),
  issued_at DATE NOT NULL,
  issued_by UUID REFERENCES dim_mitarbeiter(id),
  reason TEXT NOT NULL,
  legal_refs TEXT[],                               -- ['OR 321a','ZGB 28','StGB 173']
  document_url TEXT,
  acknowledged_at TIMESTAMPTZ,
  acknowledged_by_signature BOOLEAN DEFAULT false,
  alternative_offered TEXT,                        -- z.B. 'Aufhebungsvertrag'
  follow_up_deadline DATE,
  resolution TEXT CHECK (resolution IN (
    'compliance','termination_notice','termination_immediate','mutual_agreement','escalation'
  )),
  resolved_at DATE,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_warnings_mitarbeiter ON fact_warnings(mitarbeiter_id, issued_at);
CREATE INDEX idx_warnings_unresolved ON fact_warnings(follow_up_deadline) WHERE resolved_at IS NULL;

-- FK-Nachziehen für §9.3
ALTER TABLE fact_lifecycle_transitions
  ADD CONSTRAINT fk_lifecycle_transitions_warning
  FOREIGN KEY (warning_id) REFERENCES fact_warnings(id);
```

### §10.2 `dim_disciplinary_penalty_types`

```sql
CREATE TABLE dim_disciplinary_penalty_types (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code TEXT UNIQUE NOT NULL,
  name_de TEXT NOT NULL,
  during_employment BOOLEAN DEFAULT true,
  post_employment BOOLEAN DEFAULT false,
  default_amount_chf NUMERIC(10,2),
  amount_formula TEXT,                             -- z.B. '12 Bruttomonatslöhne, min 80000'
  legal_ref TEXT,
  sort_order INT
);
```

### §10.3 `fact_disciplinary_incidents`

Peter-Entscheidung §11C-4: **GL-Approval + 1 Mt MA-Vorankündigung** vor Payroll-Verrechnung.

```sql
CREATE TABLE fact_disciplinary_incidents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  mitarbeiter_id UUID NOT NULL REFERENCES dim_mitarbeiter(id),
  penalty_type_id UUID NOT NULL REFERENCES dim_disciplinary_penalty_types(id),
  incident_date DATE,
  reported_by UUID REFERENCES dim_mitarbeiter(id),
  reported_at TIMESTAMPTZ DEFAULT now(),
  evidence_document_urls TEXT[],
  penalty_amount_chf NUMERIC(10,2),
  status TEXT DEFAULT 'investigation' CHECK (status IN (
    'investigation','confirmed','dismissed','paid','contested_in_court'
  )),
  -- GL-Approval-Gate
  gl_approved_at TIMESTAMPTZ,
  gl_approved_by UUID REFERENCES dim_mitarbeiter(id),
  gl_approval_notes TEXT,
  -- MA-Vorankündigung (1 Mt Pflicht)
  ma_notified_at TIMESTAMPTZ,
  ma_notified_document_url TEXT,
  -- Payroll-Offset (nur erlaubt nach GL-Approval + 1 Mt Notification)
  offset_against_salary BOOLEAN DEFAULT false,
  offset_effective_date DATE,
  offset_month DATE,
  -- Constraint: Offset nur wenn gl_approved + ma_notified + ≥1 Mt seit Notification
  CHECK (
    offset_against_salary = false OR (
      gl_approved_at IS NOT NULL
      AND ma_notified_at IS NOT NULL
      AND offset_effective_date IS NOT NULL
      AND offset_effective_date >= (ma_notified_at::DATE + INTERVAL '1 month')::DATE
    )
  ),
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_disciplinary_incidents_mitarbeiter ON fact_disciplinary_incidents(mitarbeiter_id, status);
CREATE INDEX idx_disciplinary_incidents_pending ON fact_disciplinary_incidents(status) WHERE status IN ('investigation','confirmed');
```

---

## §11 Dokumente + Notfallkontakte + Audit + Kompensation + Jubiläum

### §11.1 `fact_hr_documents`

```sql
CREATE TABLE fact_hr_documents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  mitarbeiter_id UUID NOT NULL REFERENCES dim_mitarbeiter(id),
  document_type TEXT NOT NULL CHECK (document_type IN (
    'arbeitsvertrag','vertrags_nachtrag','arbeitszeugnis','zwischenzeugnis','arbeitsbestaetigung',
    'reglement_generalis_provisio','reglement_tempus_passio','reglement_locus_extra',
    'stellenbeschreibung_progressus','provisionsvertrag_praemium_victoria',
    'weiterbildungsvereinbarung',
    'aufhebungsvereinbarung_freistellung','aufhebungsvereinbarung_nach_kuendigung',
    'kuendigung_ausgesprochen','kuendigung_annullierung',
    'verwarnung_erste','verwarnung_letzte',
    'zertifikat','policy_acknowledgement','hintergrund_check','arztzeugnis',
    'passfoto','lebenslauf','referenzschreiben','lohnausweis',
    'kkv_merkblatt_rueckläufer','abredeversicherung_merkblatt_rueckläufer',
    -- Tier-2-Ingest-Erweiterung 2026-04-19:
    'personalstammdaten_formular','spesenabrechnung_monat','smarttime_export',
    'hausordnung_akzeptiert_signatur','schluesselquittung','glossary_acknowledged',
    'sonstiges'
  )),
  name TEXT NOT NULL,
  document_date DATE,
  expiry_date DATE,
  document_url TEXT NOT NULL,
  file_hash_sha256 TEXT,
  uploaded_by UUID REFERENCES dim_mitarbeiter(id),
  uploaded_at TIMESTAMPTZ DEFAULT now(),
  retention_years INT NOT NULL,
  retention_until_date DATE GENERATED ALWAYS AS (
    uploaded_at::DATE + (retention_years || ' years')::INTERVAL
  ) STORED,
  visibility TEXT DEFAULT 'hr_admin_self' CHECK (visibility IN (
    'hr_admin_self','hr_admin_only','hr_admin_self_supervisor'
  )),
  legal_hold BOOLEAN DEFAULT false,
  deleted_at TIMESTAMPTZ,
  deleted_reason TEXT
);

CREATE INDEX idx_hr_documents_mitarbeiter ON fact_hr_documents(mitarbeiter_id, document_type);
CREATE INDEX idx_hr_documents_retention ON fact_hr_documents(retention_until_date) WHERE deleted_at IS NULL;
CREATE INDEX idx_hr_documents_legal_hold ON fact_hr_documents(legal_hold) WHERE legal_hold = true;
```

### §11.2 `dim_emergency_contacts`

Peter-Entscheidung §11B-5: **Max 2** (primär + sekundär) · Pflicht ≥ 1.

```sql
CREATE TABLE dim_emergency_contacts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  mitarbeiter_id UUID NOT NULL REFERENCES dim_mitarbeiter(id),
  priority INT NOT NULL CHECK (priority IN (1, 2)),
  name TEXT NOT NULL,
  relationship TEXT NOT NULL,
  phone TEXT NOT NULL,
  phone_alt TEXT,
  email TEXT,
  last_verified_at DATE,
  UNIQUE (mitarbeiter_id, priority)
);
```

### §11.3 `audit_hr_access` (DSG-konformer Audit-Trail)

```sql
CREATE TABLE audit_hr_access (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  timestamp TIMESTAMPTZ DEFAULT now(),
  actor_id UUID NOT NULL REFERENCES dim_mitarbeiter(id),
  action TEXT NOT NULL CHECK (action IN (
    'view','reveal_sensitive','update','create','delete','export','download'
  )),
  entity_type TEXT NOT NULL CHECK (entity_type IN (
    'mitarbeiter','contract','absence','document','certification',
    'compensation','ahv','pass','background_check','emergency_contact',
    'warning','disciplinary_incident','provisionsvertrag','training_agreement'
  )),
  entity_id UUID,
  target_mitarbeiter_id UUID REFERENCES dim_mitarbeiter(id),
  field_changed TEXT,
  reason TEXT,                                     -- Begründung bei sensitive Access
  ip_address INET,
  user_agent TEXT,
  status TEXT DEFAULT 'success' CHECK (status IN ('success','blocked','error'))
);

CREATE INDEX idx_audit_hr_access_target ON audit_hr_access(target_mitarbeiter_id, timestamp);
CREATE INDEX idx_audit_hr_access_actor ON audit_hr_access(actor_id, timestamp);
CREATE INDEX idx_audit_hr_access_sensitive ON audit_hr_access(timestamp) WHERE action = 'reveal_sensitive';
```

### §11.4 `fact_compensation_history` (Read-Only-Ref)

```sql
CREATE TABLE fact_compensation_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  mitarbeiter_id UUID NOT NULL REFERENCES dim_mitarbeiter(id),
  valid_from DATE NOT NULL,
  valid_until DATE,
  base_salary_chf_annual NUMERIC(10,2) NOT NULL,
  salary_distribution INT DEFAULT 13,              -- 12 oder 13 Monate
  commission_rate NUMERIC(4,3),
  commission_model_text TEXT,
  bonus_pool_eligible BOOLEAN DEFAULT false,
  benefits JSONB,                                  -- {sbb_ga:true, handy_pauschale:80, home_office:100, ...}
  training_budget_chf NUMERIC(8,2) DEFAULT 4000,
  source TEXT DEFAULT 'payroll_system',
  last_sync_at TIMESTAMPTZ,
  is_active BOOLEAN GENERATED ALWAYS AS (
    (valid_until IS NULL OR valid_until >= CURRENT_DATE) AND valid_from <= CURRENT_DATE
  ) STORED
);

CREATE INDEX idx_compensation_history_mitarbeiter_active ON fact_compensation_history(mitarbeiter_id) WHERE is_active = true;
```

### §11.5 `fact_jubilaeum_handled` (Peter-Entscheidung §11B-10)

```sql
CREATE TABLE fact_jubilaeum_handled (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  mitarbeiter_id UUID NOT NULL REFERENCES dim_mitarbeiter(id),
  jubilaeum_year INT NOT NULL CHECK (jubilaeum_year IN (5, 10, 15, 20, 25, 30, 35, 40)),
  anniversary_date DATE NOT NULL,
  handled_at TIMESTAMPTZ DEFAULT now(),
  handled_by UUID REFERENCES dim_mitarbeiter(id),
  gesture_type_freetext TEXT,                      -- 'Blumen' · 'Geschenk CHF 500' · 'Extra-Ferientag' · ...
  notes TEXT,
  UNIQUE (mitarbeiter_id, jubilaeum_year)
);
```

---

## §12 Views

### §12.1 `v_hr_alerts` (Dashboard-Alerts)

```sql
CREATE OR REPLACE VIEW v_hr_alerts AS
-- Probezeit-Enden
SELECT 'probezeit_ending' AS alert_type, m.id AS mitarbeiter_id, m.vorname||' '||m.nachname AS name,
  (ec.probezeit_ende - CURRENT_DATE)::INT AS days_remaining, 'urgent' AS severity
FROM dim_mitarbeiter m
JOIN fact_employment_contracts ec ON ec.mitarbeiter_id = m.id AND ec.is_active
WHERE ec.probezeit_ende BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '30 days'

UNION ALL
-- Zertifikate expiring
SELECT 'certification_expiring', m.id, m.vorname||' '||m.nachname,
  (fc.valid_until - CURRENT_DATE)::INT,
  CASE WHEN fc.valid_until < CURRENT_DATE + INTERVAL '1 month' THEN 'urgent' ELSE 'warning' END
FROM dim_mitarbeiter m
JOIN fact_employee_certifications fc ON fc.mitarbeiter_id = m.id
WHERE fc.status IN ('expired','expiring')

UNION ALL
-- Ferien pending
SELECT 'vacation_approval_pending', m.id, m.vorname||' '||m.nachname,
  EXTRACT(DAY FROM (now() - fa.requested_at))::INT,
  CASE WHEN now() - fa.requested_at > INTERVAL '7 days' THEN 'warning' ELSE 'info' END
FROM dim_mitarbeiter m
JOIN fact_absences fa ON fa.mitarbeiter_id = m.id
WHERE fa.approval_status = 'pending'

UNION ALL
-- Warnings Follow-up
SELECT 'warning_follow_up_due', m.id, m.vorname||' '||m.nachname,
  (fw.follow_up_deadline - CURRENT_DATE)::INT,
  CASE WHEN fw.follow_up_deadline < CURRENT_DATE + INTERVAL '7 days' THEN 'urgent' ELSE 'warning' END
FROM dim_mitarbeiter m
JOIN fact_warnings fw ON fw.mitarbeiter_id = m.id
WHERE fw.resolved_at IS NULL
  AND fw.follow_up_deadline IS NOT NULL
  AND fw.follow_up_deadline BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '30 days'

UNION ALL
-- Home-Office-Anträge pending
SELECT 'homeoffice_approval_pending', m.id, m.vorname||' '||m.nachname,
  EXTRACT(DAY FROM (fhr.requested_date - CURRENT_DATE))::INT, 'info'
FROM dim_mitarbeiter m
JOIN fact_homeoffice_requests fhr ON fhr.mitarbeiter_id = m.id
WHERE fhr.status = 'pending'

UNION ALL
-- Alumni-Konkurrenzverbot aktiv
SELECT 'alumni_konkurrenzverbot_active', m.id, m.vorname||' '||m.nachname,
  (m.konkurrenzverbot_aktiv_bis - CURRENT_DATE)::INT, 'info'
FROM dim_mitarbeiter m
WHERE m.lifecycle_stage = 'alumni'
  AND m.konkurrenzverbot_aktiv_bis >= CURRENT_DATE

UNION ALL
-- Praemium Victoria Renewal fällig
SELECT 'provisionsvertrag_renewal_due', m.id, m.vorname||' '||m.nachname,
  EXTRACT(DAY FROM (pv.fiscal_period_end - CURRENT_DATE))::INT,
  CASE WHEN pv.fiscal_period_end < CURRENT_DATE + INTERVAL '60 days' THEN 'warning' ELSE 'info' END
FROM dim_mitarbeiter m
JOIN fact_provisionsvertrag_versions pv ON pv.mitarbeiter_id = m.id
WHERE pv.fiscal_period_end BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '90 days'

UNION ALL
-- Dienstjubiläum (5/10/15/20 J)
SELECT 'jubilaeum_upcoming', m.id, m.vorname||' '||m.nachname,
  (jubilaeum_dates.anniversary - CURRENT_DATE)::INT, 'info'
FROM dim_mitarbeiter m
CROSS JOIN LATERAL (
  SELECT (m.eintrittsdatum + (jahr || ' years')::INTERVAL)::DATE AS anniversary, jahr
  FROM unnest(ARRAY[5,10,15,20,25,30,35,40]) AS jahr
) jubilaeum_dates
WHERE jubilaeum_dates.anniversary BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '30 days'
  AND NOT EXISTS (
    SELECT 1 FROM fact_jubilaeum_handled fjh
    WHERE fjh.mitarbeiter_id = m.id AND fjh.jubilaeum_year = jubilaeum_dates.jahr
  )

UNION ALL
-- Scheelen-Zertifikat fehlt (nach 6 Mt Onboarding)
SELECT 'scheelen_certification_missing', m.id, m.vorname||' '||m.nachname,
  EXTRACT(DAY FROM (CURRENT_DATE - m.eintrittsdatum))::INT, 'warning'
FROM dim_mitarbeiter m
WHERE m.lifecycle_stage = 'aktiv'
  AND m.eintrittsdatum + INTERVAL '6 months' <= CURRENT_DATE
  AND EXISTS (
    SELECT 1 FROM dim_certifications dc
    WHERE dc.is_mandatory_for_roles @> ARRAY['*']::TEXT[]
      AND dc.name_de LIKE 'Scheelen%'
      AND NOT EXISTS (
        SELECT 1 FROM fact_employee_certifications fec
        WHERE fec.mitarbeiter_id = m.id
          AND fec.certification_id = dc.id
          AND fec.status = 'active'
      )
  );
```

### §12.2 `v_next_lohn_payment_date` (Config-basiert)

```sql
CREATE OR REPLACE VIEW v_next_lohn_payment_date AS
WITH cfg AS (
  SELECT
    (SELECT value::INT FROM dim_automation_settings WHERE key='lohnlauf_day_start') AS day_start,
    (SELECT value::INT FROM dim_automation_settings WHERE key='lohnlauf_day_end') AS day_end,
    (SELECT value::BOOLEAN FROM dim_automation_settings WHERE key='december_before_xmas') AS december_early,
    (SELECT value::BOOLEAN FROM dim_automation_settings WHERE key='avoid_weekend_holiday') AS avoid_we
)
SELECT m.id AS mitarbeiter_id,
  CASE
    WHEN EXTRACT(MONTH FROM CURRENT_DATE) = 12 AND (SELECT december_early FROM cfg) THEN
      (DATE_TRUNC('month', CURRENT_DATE) + INTERVAL '22 days')::DATE
    ELSE
      (DATE_TRUNC('month', CURRENT_DATE) + ((SELECT day_end - 1 FROM cfg) || ' days')::INTERVAL)::DATE
  END AS next_payment_date
FROM dim_mitarbeiter m
WHERE m.status = 'active';
```

### §12.3 `v_training_repayment_obligations`

```sql
CREATE OR REPLACE VIEW v_training_repayment_obligations AS
SELECT
  ta.id,
  ta.mitarbeiter_id,
  ta.total_employer_contribution_chf,
  m.austrittsdatum,
  EXTRACT(MONTH FROM age(m.austrittsdatum, ta.actual_completion_date))::INT AS months_since_completion,
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

---

## §13 Config-Settings (`dim_automation_settings`-Keys)

```sql
INSERT INTO dim_automation_settings (key, value, description, data_type) VALUES
  ('feature_hr_tool', 'false', 'HR-Tool Phase-3 Unlock-Flag', 'boolean'),
  -- Lohnlauf-Kalender (§11C-10)
  ('lohnlauf_day_start', '25', 'Erster möglicher Auszahlungstag im Monat', 'integer'),
  ('lohnlauf_day_end', '30', 'Letzter möglicher Auszahlungstag', 'integer'),
  ('december_before_xmas', 'true', 'Dezember-Lohn vor Weihnachten auszahlen', 'boolean'),
  ('avoid_weekend_holiday', 'true', 'Wenn Lohntag auf WE/Feiertag fällt, vorverlegen', 'boolean'),
  -- Scheelen-Alert-Threshold (§11C-9)
  ('scheelen_onboarding_deadline_months', '6', 'Nach wie vielen Monaten Scheelen-Alert wenn Zertifikat fehlt', 'integer'),
  -- Jubiläums-Alert-Lead (§11B-10)
  ('jubilaeum_alert_lead_days', '30', 'Wie viele Tage vor Jubiläum Alert im Dashboard', 'integer'),
  -- Absenz-Regeln
  ('sickness_family_max_days_year', '10', 'Max Tage Pflege Familie pro Jahr', 'integer'),
  ('vacation_carry_deadline_offset_days', '14', 'Carry-Deadline = Ostermontag + N Tage (Tempus Passio §6.1)', 'integer'),
  -- HO/Remote-Regeln (aus Locus Extra)
  ('homeoffice_team_coverage_min_pct', '70', 'Min. Team-Abdeckung vor Ort für HO-Genehmigung', 'integer'),
  ('vacation_team_coverage_min_pct', '50', 'Min. Team-Abdeckung vor Ort für Ferien-Genehmigung', 'integer'),
  -- Tier-2-Ingest-Erweiterung 2026-04-19 (aus Starterinfo ZH Hausordnung):
  ('arbeitsbeginn_spaetestens_uhrzeit', '08:45', 'Arbeitsbeginn-Richtzeit (Hausordnung)', 'string'),
  ('feiertags_vorabend_arbeitsschluss_uhrzeit', '17:00', 'Arbeitsschluss vor Feiertagen', 'string'),
  ('mittagspause_von_bis', '12:00-14:00', 'Mittagspausen-Fenster', 'string'),
  ('mittagspause_dauer_minuten', '60', 'Mittagspausen-Dauer', 'integer'),
  ('reportingwoche_start_dow', '2', 'Start Reportingwoche (Tag-of-Week · 2=Di)', 'integer'),
  ('reportingwoche_end_dow', '1', 'Ende Reportingwoche (Tag-of-Week · 1=Mo)', 'integer'),
  ('dresscode_client_default', 'suit_up', 'Dresscode bei Kundenterminen', 'string'),
  ('dresscode_office_default', 'business_casual', 'Dresscode im Office', 'string'),
  ('payroll_treuhaender_email', 'office@treuhand-kunz.ch', 'Treuhand Kunz · Payroll-Partner', 'string'),
  ('payroll_export_formats', '["bexio_csv","swissdec_elm"]', 'Unterstützte Payroll-Export-Formate', 'json')
ON CONFLICT (key) DO NOTHING;
```

---

## §14 Seeds

### §14.1 Scheelen-Zertifikate (alle 4 Pflicht · §11C-9)

```sql
INSERT INTO dim_certifications (name_de, issuer, category, typical_validity_months, renewable, is_mandatory_for_roles, sort_order) VALUES
  ('Scheelen MDI (INSIGHTS Discovery)', 'SCHEELEN', 'assessment', NULL, true, ARRAY['*'], 10),
  ('Scheelen RELIEF® Stressprävention', 'SCHEELEN', 'assessment', NULL, true, ARRAY['*'], 20),
  ('Scheelen ASSESS 5.0', 'SCHEELEN', 'assessment', NULL, true, ARRAY['*'], 30),
  ('Scheelen TriMetrix® EQ', 'SCHEELEN', 'assessment', NULL, true, ARRAY['*'], 40);
```

### §14.2 Reglemente (3 Reglemente · aktuelle Version 2024-01-01)

```sql
INSERT INTO dim_reglemente (latin_name, name_de, version, valid_from, document_print_url, requires_bulk_resignature) VALUES
  ('generalis_provisio', 'Allgemeine Anstellungsbedingungen', '2024-01-01', '2024-01-01',
    'raw/HR/2_HR On- Offboarding/2_Reglemente/Generalis Provisio_allg. Anstellungsbedingungen/DRUCK_Reglement Generalis Provisio_Allgemeine Anstellungsbedingungen.docx', false),
  ('tempus_passio_365', 'Arbeitszeitenreglement', '2024-01-01', '2024-01-01',
    'raw/HR/2_HR On- Offboarding/2_Reglemente/Tempus Passio_Arbeitszeitenreglement/DRUCK_Tempus Passio 365_Arbeitszeitenreglement.docx', false),
  ('locus_extra', 'Mobiles Arbeiten', '2024-01-01', '2024-01-01',
    'raw/HR/2_HR On- Offboarding/2_Reglemente/Locus Extra_mobiles Arbeiten/DRUCK_Locus Extra_mobiles Arbeiten.docx', false);
```

### §14.3 Job-Descriptions (Progressus-Seed für aktuelle Arkadium-Rollen)

```sql
INSERT INTO dim_job_descriptions (code, name_de, bereich, abteilung, sparte, signing_authority, default_pensum, version, valid_from) VALUES
  ('consultant', 'Consultant', 'Executive & Professional Search', 'Kernbusiness', NULL, false, 100, '2024-01-01', '2024-01-01'),
  ('research_analyst', 'Research Analyst & Junior Consultant', 'Executive & Professional Search', 'Kernbusiness', NULL, false, 100, '2024-01-01', '2024-01-01'),
  ('team_leader_rem', 'Team Leader Real Estate Management', 'Kernbusiness', NULL, 'REM', true, 100, '2024-01-01', '2024-01-01'),
  ('team_leader_arc', 'Team Leader Architecture', 'Kernbusiness', NULL, 'ARC', true, 100, '2024-01-01', '2024-01-01'),
  ('team_leader_ing', 'Team Leader Civil Engineering', 'Kernbusiness', NULL, 'ING', true, 100, '2024-01-01', '2024-01-01'),
  ('team_leader_tec', 'Team Leader Building Technology', 'Kernbusiness', NULL, 'TEC', true, 100, '2024-01-01', '2024-01-01'),
  ('head_of_arc_rem', 'Head of Architecture & Real Estate', 'Kernbusiness', NULL, 'ARC+REM', true, 100, '2024-01-01', '2024-01-01'),
  ('head_of_ing_tec', 'Head of Civil Engineering & Building Technology', 'Kernbusiness', NULL, 'ING+TEC', true, 100, '2024-01-01', '2024-01-01'),
  ('founder_partner', 'Partner & Founder', 'GL', NULL, NULL, true, 100, '2024-01-01', '2024-01-01'),
  ('backoffice', 'Backoffice', 'Operations', NULL, NULL, false, 100, '2024-01-01', '2024-01-01'),
  ('hr_manager', 'HR-Manager', 'GL-Assistenz/HR', NULL, NULL, true, NULL, '2024-01-01', '2024-01-01');
```

### §14.4 Academy-Module

```sql
INSERT INTO dim_academy_modules (module_code, name_de, fachgebiet, part_number, duration_hours, mandatory_for_roles, sort_order) VALUES
  ('comm_edge_1', 'Communication Edge Part I', 'C', 1, 8.0, ARRAY['consultant','research_analyst'], 10),
  ('comm_edge_2', 'Communication Edge Part II', 'C', 2, 8.0, ARRAY['consultant','research_analyst'], 11),
  ('comm_edge_3', 'Communication Edge Part III', 'C', 3, 8.0, ARRAY['consultant'], 12),
  ('m4_modell', 'M4 Modell (4-Phasen-Recruiting)', 'A', NULL, 6.0, ARRAY['consultant','research_analyst'], 20),
  ('lernkartei_1', 'Lernkartei 1', 'A', 1, 2.0, ARRAY['consultant','research_analyst'], 30),
  ('lernkartei_2', 'Lernkartei 2', 'A', 2, 2.0, ARRAY['consultant','research_analyst'], 31),
  ('m_1_1_ident', 'M 1.1 Ident', 'A', NULL, 2.0, ARRAY['consultant','research_analyst'], 40),
  ('m_1_2_hunt', 'M 1.2 Hunt', 'A', NULL, 3.0, ARRAY['consultant','research_analyst'], 41),
  ('m_1_3_cv_chase', 'M 1.3 CV Chase & Briefing', 'A', NULL, 2.0, ARRAY['consultant','research_analyst'], 42),
  ('m_1_4_briefing', 'M 1.4 Briefing', 'A', NULL, 3.0, ARRAY['consultant'], 43),
  ('m_2_1_doc_chase', 'M 2.1 Doc Chase', 'A', NULL, 2.0, ARRAY['consultant'], 50),
  ('m_2_2_preleading', 'M 2.2 PreLeading', 'A', NULL, 2.0, ARRAY['consultant'], 51),
  ('m_2_3_prelead_pres', 'M 2.3 PreLead Presentation', 'A', NULL, 2.0, ARRAY['consultant'], 52),
  ('m_2_4_go_fishing', 'M 2.4 GO Fishing', 'A', NULL, 2.0, ARRAY['consultant'], 53),
  ('m_3_1_docs_gen', 'M 3.1 Docs Generating', 'A', NULL, 2.0, ARRAY['consultant'], 60),
  ('m_3_2_abstract', 'M 3.2 Abstract', 'A', NULL, 2.0, ARRAY['consultant'], 61),
  ('m_3_3_akquise', 'M 3.3 Akquise & Home Run Call', 'A', NULL, 3.0, ARRAY['consultant'], 62),
  ('m_3_4_cv_sent', 'M 3.4 CV sent', 'A', NULL, 2.0, ARRAY['consultant'], 63),
  ('m_4_1_tivt_orga', 'M 4.1 TIVT Orga', 'A', NULL, 2.0, ARRAY['consultant'], 70),
  ('m_4_2_2nd_orga', 'M 4.2 2nd Orga', 'A', NULL, 2.0, ARRAY['consultant'], 71),
  ('m_4_3_offer', 'M 4.3 Offer', 'A', NULL, 2.0, ARRAY['consultant'], 72),
  ('m_4_4_placement', 'M 4.4 Placement', 'A', NULL, 2.0, ARRAY['consultant'], 73);
```

### §14.5 Absence-Types

```sql
INSERT INTO dim_absence_types
  (code, label_de, paid, requires_certificate, certificate_rule_type, certificate_staffelung_jsonb,
   requires_approval, counts_towards_vacation_balance, extra_guthaben_kategorie, bezugs_constraint_jsonb, sort_order) VALUES
  ('sick', 'Krankheit', true, true, 'staffelung_by_dienstjahr',
    '{"dj_1":1,"dj_2":2,"dj_3_plus":3}'::jsonb, false, false, false, NULL, 10),
  ('vacation', 'Ferien', true, false, 'never', NULL, true, true, false, NULL, 20),
  ('unpaid', 'Unbezahlter Urlaub', false, false, 'never', NULL, true, false, false, NULL, 30),
  ('maternity', 'Mutterschaft (16 Wo EO)', true, true, 'always_day_1', NULL, false, false, false, NULL, 40),
  ('paternity', 'Vaterschaft (2 Wo EO)', true, false, 'never', NULL, true, false, false, NULL, 50),
  ('military', 'Militär-/Zivildienst (EO)', true, true, 'always_day_1', NULL, false, false, false, NULL, 60),
  ('civil_protection', 'Zivilschutz', true, true, 'always_day_1', NULL, false, false, false, NULL, 61),
  ('red_cross', 'Rotkreuzdienst', true, true, 'always_day_1', NULL, false, false, false, NULL, 62),
  ('fire_brigade', 'Feuerwehrdienst', true, true, 'always_day_1', NULL, false, false, false, NULL, 63),
  ('training', 'Weiterbildung', true, false, 'never', NULL, true, false, false, NULL, 70),
  ('sickness_family', 'Pflege Familie', true, false, 'never', NULL, true, false, false, NULL, 80),
  ('holiday', 'Feiertag (Kanton ZH)', true, false, 'never', NULL, false, false, false, NULL, 90),
  ('birthday_self', 'Geburtstag MA (Extra-Guthaben)', true, false, 'never', NULL, false, false, true,
    '{"only_in_birthday_week":true}'::jsonb, 100),
  ('birthday_close', 'Geburtstag nahestehend (Extra-Guthaben)', true, false, 'never', NULL, true, false, true,
    '{"only_in_birthday_week":true}'::jsonb, 101),
  ('joker_day', 'Jokertag (Me Time, Extra-Guthaben)', true, false, 'never', NULL, false, false, true, NULL, 102),
  ('zeg_target_reward', 'Zielerreichung Halbjahr (Extra-Guthaben)', true, false, 'never', NULL, true, false, true,
    '{"only_in_blocked_periods":true}'::jsonb, 103),
  ('gl_discretionary', 'GL-Ermessen Extra-Tag', true, false, 'never', NULL, true, false, true,
    '{"only_in_blocked_periods":true}'::jsonb, 104);
```

### §14.6 Feiertage Kanton ZH (Beispiel 2026 · Worker regeneriert jährlich)

```sql
INSERT INTO dim_holidays (canton, year, date, name_de, source) VALUES
  ('ZH', 2026, '2026-01-01', 'Neujahr', 'manual'),
  ('ZH', 2026, '2026-01-02', 'Berchtoldstag', 'manual'),
  ('ZH', 2026, '2026-04-03', 'Karfreitag', 'manual'),
  ('ZH', 2026, '2026-04-06', 'Ostermontag', 'manual'),
  ('ZH', 2026, '2026-05-01', '1. Mai (Tag der Arbeit)', 'manual'),
  ('ZH', 2026, '2026-05-14', 'Auffahrt', 'manual'),
  ('ZH', 2026, '2026-05-25', 'Pfingstmontag', 'manual'),
  ('ZH', 2026, '2026-08-01', 'Bundesfeier', 'manual'),
  ('ZH', 2026, '2026-12-25', 'Weihnachten', 'manual'),
  ('ZH', 2026, '2026-12-26', 'Stephanstag', 'manual')
ON CONFLICT (canton, date) DO NOTHING;
```

### §14.7b Onboarding-Templates (Tier-2-Ingest · Consultant-14W + Researcher-8W)

```sql
INSERT INTO dim_onboarding_templates (name, description, target_role, phases) VALUES
  ('Consultant · 14 Wochen', 'Voll-Onboarding Consultant · Academy Communication Edge + M1–M4 komplett',
    'consultant',
    '[
      {"phase":"pre_arrival","week":0,"tasks":[
        {"title":"Arbeitsvertrag + 5 Anhänge signiert erhalten"},
        {"title":"Personalstammdaten an Treuhand Kunz senden","auto_email":"office@treuhand-kunz.ch"},
        {"title":"IT-Zugang beantragen (Lenny-Ticket)"}
      ]},
      {"phase":"day_1","week":1,"tasks":[
        {"title":"Starterinfo + Hausordnung lesen + Quiz"},
        {"title":"Arkadium am Markt lesen"},
        {"title":"Glossary lesen"},
        {"title":"Einführung CRM-System"},
        {"title":"Einführung Softphone (3CX) + Telefonliste"},
        {"title":"Schlüsselquittung signiert"},
        {"title":"Dresscode-Briefing"}
      ]},
      {"phase":"woche_1","week":1,"tasks":[
        {"title":"Communication Edge Part I starten","module_code":"comm_edge_1"},
        {"title":"M4 Modell Überblick","module_code":"m4_modell"},
        {"title":"Kollegiales Mittagessen mit Team"},
        {"title":"Erstes Koordinationsgespräch mit Vorgesetztem"}
      ]},
      {"phase":"woche_2_4","week":2,"tasks":[
        {"title":"Communication Edge Part I abgeschlossen","module_code":"comm_edge_1"},
        {"title":"M 1.1 Ident trainieren","module_code":"m_1_1_ident"},
        {"title":"M 1.2 Hunt trainieren","module_code":"m_1_2_hunt"},
        {"title":"Erstes eigenes Hunt-Telefonat (beobachtet)"}
      ]},
      {"phase":"monat_2","week":5,"tasks":[
        {"title":"Communication Edge Part II","module_code":"comm_edge_2"},
        {"title":"Communication Edge Anhang","module_code":"comm_edge_3"},
        {"title":"M 1.3 CV Chase","module_code":"m_1_3_cv_chase"},
        {"title":"M 1.4 Briefing","module_code":"m_1_4_briefing"},
        {"title":"M 2.1 Doc Chase","module_code":"m_2_1_doc_chase"},
        {"title":"M 2.2 PreLeading","module_code":"m_2_2_preleading"},
        {"title":"M 2.3 PreLead Presentation","module_code":"m_2_3_prelead_pres"},
        {"title":"M 2.4 GO Fishing","module_code":"m_2_4_go_fishing"},
        {"title":"Erstes eigenes Briefing-Gespräch"}
      ]},
      {"phase":"monat_3","week":9,"tasks":[
        {"title":"M 3.1 Docs Generating","module_code":"m_3_1_docs_gen"},
        {"title":"M 3.2 Abstract","module_code":"m_3_2_abstract"},
        {"title":"M 3.3 Akquise","module_code":"m_3_3_akquise"},
        {"title":"M 3.4 CV sent","module_code":"m_3_4_cv_sent"},
        {"title":"M 4.1 TIVT Orga","module_code":"m_4_1_tivt_orga"},
        {"title":"M 4.2 2nd Orga","module_code":"m_4_2_2nd_orga"},
        {"title":"M 4.3 Offer","module_code":"m_4_3_offer"},
        {"title":"M 4.4 Placement","module_code":"m_4_4_placement"},
        {"title":"Erste eigene Kundenvorstellung"},
        {"title":"Scheelen MDI-Zertifizierung starten"},
        {"title":"Scheelen Relief-Zertifizierung starten"},
        {"title":"Scheelen ASSESS-Zertifizierung starten"},
        {"title":"Scheelen EQ-Zertifizierung starten"},
        {"title":"Probezeit-Feedback-Gespräch"}
      ]}
    ]'::jsonb
  ),
  ('Research Analyst · 8 Wochen', 'Reduziertes Onboarding Researcher · Fokus M1-Serie + CE Part I + M4-Grundlagen',
    'research_analyst',
    '[
      {"phase":"pre_arrival","week":0,"tasks":[
        {"title":"Arbeitsvertrag signiert"},
        {"title":"Personalstammdaten an Treuhand Kunz"},
        {"title":"IT-Zugang"}
      ]},
      {"phase":"day_1","week":1,"tasks":[
        {"title":"Starterinfo + Hausordnung"},
        {"title":"Arkadium am Markt"},
        {"title":"Glossary"},
        {"title":"CRM-Einführung"}
      ]},
      {"phase":"woche_1_2","week":1,"tasks":[
        {"title":"Communication Edge Part I","module_code":"comm_edge_1"},
        {"title":"M4 Modell Grundlagen","module_code":"m4_modell"},
        {"title":"Lernkartei 1","module_code":"lernkartei_1"}
      ]},
      {"phase":"woche_3_5","week":3,"tasks":[
        {"title":"M 1.1 Ident","module_code":"m_1_1_ident"},
        {"title":"M 1.2 Hunt","module_code":"m_1_2_hunt"},
        {"title":"M 1.3 CV Chase","module_code":"m_1_3_cv_chase"},
        {"title":"Erstes Hunt-Telefonat"}
      ]},
      {"phase":"woche_6_8","week":6,"tasks":[
        {"title":"Scheelen MDI","module_code":"scheelen_mdi"},
        {"title":"Scheelen ASSESS","module_code":"scheelen_assess"},
        {"title":"Scheelen Relief","module_code":"scheelen_relief"},
        {"title":"Scheelen EQ","module_code":"scheelen_eq"},
        {"title":"Probezeit-Feedback"}
      ]}
    ]'::jsonb
  );
```

### §14.7 Disciplinary-Penalty-Types

```sql
INSERT INTO dim_disciplinary_penalty_types
  (code, name_de, during_employment, post_employment, default_amount_chf, amount_formula, legal_ref, sort_order) VALUES
  ('konkurrenzierung_during_av', 'Konkurrenzierung während AV', true, false, 20000, NULL, 'OR 321a', 10),
  ('abwerbung_during_av', 'Abwerbung während AV', true, false, 10000, NULL, 'OR 321a', 11),
  ('nebentaetigkeit_unauthorized', 'Nebentätigkeit ohne Zustimmung', true, false, 3000, NULL, 'Generalis Provisio §3.5.3', 12),
  ('diffamation', 'Diffamierende Äusserung', true, false, 5000, NULL, 'OR 321a · ZGB 28', 13),
  ('geheimhaltung_verletzung_during', 'Geschäftsgeheimnis-Verletzung während AV', true, false, 20000, NULL, 'OR 321a', 14),
  ('konkurrenzverbot_post_av', 'Konkurrenzverbot post-AV', false, true, 80000, '12 Bruttomonatslöhne inkl. Provisionen/Spesen, min 80000', 'OR 340b', 20),
  ('abwerbeverbot_post_av', 'Abwerbeverbot post-AV', false, true, 80000, 'pro Zuwiderhandlung', 'OR 340', 21),
  ('geheimhaltung_post_av', 'Geheimhaltungs-Verletzung post-AV', false, true, 20000, 'pro Verletzung', 'OR 340b', 22);
```

---

## §15 Indices + Performance

**Partition-Kandidaten** (bei Wachstum >100k Rows):
- `fact_absences` nach `start_date` (year)
- `audit_hr_access` nach `timestamp` (quarter)
- `fact_hr_documents` nach `uploaded_at` (year)

**BRIN-Indices** für append-only Tabellen:
```sql
CREATE INDEX idx_audit_hr_access_timestamp_brin ON audit_hr_access USING brin(timestamp);
CREATE INDEX idx_absences_start_brin ON fact_absences USING brin(start_date);
```

**Materialized Views** bei Report-Performance-Problemen:
- `mv_team_calendar_monthly` (für Team-Matrix-Dashboard)
- `mv_zeg_half_year_snapshot` (H1/H2-ZEG-Status pro MA)

---

## §16 RBAC-Regeln

Siehe `wiki/meta/rbac-matrix.md` · HR-Tool-Erweiterungen:

| Rolle | mitarbeiter read | mitarbeiter write | sensitive reveal | contracts sign | provisionsvertrag sign | warnings issue | disciplinary confirm | payroll offset trigger |
|-------|------------------|-------------------|------------------|----------------|------------------------|----------------|---------------------|------------------------|
| HR_Manager | all | all | yes (audit) | co-sign | co-sign if authorized | yes | GL-approval required | no |
| Team_Lead | team | team basic | no | sign own-team | sign own-team | team | no | no |
| Employee_Self | self | self basic (address, emergency, birthday visibility) | own only | no | co-sign own | no | no | no |
| Founder | all | all | yes (audit) | co-sign | co-sign | yes | yes (GL-approval) | approve (indirect) |
| Backoffice | all read | no | yes (payroll) | no | no | no | no | execute after approval |
| Academy_Trainer (multi-assignable) | team (via `default_trainer_ids`) | academy_progress only | no | no | no | no | no | no |

**RBAC-SQL-Constraint (Head-Signatur):**

```sql
-- Policy-Pseudocode (pg_rls oder Backend-Middleware):
-- fact_provisionsvertrag_versions UPDATE signed_by_head_of_department
-- Allowed only if:
--   current_user.role = 'head_of_department'
--   AND current_user.id = (SELECT head_of_department_id FROM dim_mitarbeiter WHERE id = ma_id)
```

---

## §17 Migrations-Reihenfolge

1. **M001** — `dim_mitarbeiter` ALTER (Person · Adresse · CH-Compliance · Lifecycle · Org)
2. **M002** — `dim_job_descriptions` CREATE + Seeds §14.3
3. **M003** — `dim_reglemente` CREATE + Seeds §14.2
4. **M004** — FK `dim_mitarbeiter.current_job_description_id`
5. **M005** — `fact_employment_contracts` CREATE
6. **M006** — `fact_contract_attachments` CREATE (ohne FK zu Provisionsvertrag · Training noch)
7. **M007** — `fact_provisionsvertrag_versions` CREATE + FK-Nachziehen
8. **M008** — `fact_role_transitions` CREATE
9. **M009** — `dim_absence_types` CREATE + Seeds §14.5
10. **M010** — `fact_absences` + `fact_vacation_balances` CREATE
11. **M011** — `dim_holidays` CREATE + Seeds §14.6
12. **M012** — `fact_homeoffice_requests` + `fact_homeoffice_quota_usage` CREATE
13. **M013** — `dim_academy_modules` CREATE + Seeds §14.4
14. **M014** — `fact_academy_progress` CREATE
15. **M015** — `dim_certifications` + Seeds §14.1 · `fact_employee_certifications` CREATE
16. **M016** — `fact_training_requests` CREATE
17. **M017** — `fact_training_agreements` CREATE + FK-Nachziehen auf contract_attachments
18. **M018** — `dim_onboarding_templates` · `fact_onboarding_instances` CREATE
19. **M019** — `fact_lifecycle_transitions` CREATE
20. **M020** — `fact_warnings` CREATE + FK-Nachziehen auf lifecycle_transitions
21. **M021** — `dim_disciplinary_penalty_types` CREATE + Seeds §14.7 · `fact_disciplinary_incidents` CREATE
22. **M022** — `fact_hr_documents` CREATE
23. **M023** — `dim_emergency_contacts` CREATE
24. **M024** — `audit_hr_access` CREATE
25. **M025** — `fact_compensation_history` CREATE
26. **M026** — `fact_jubilaeum_handled` CREATE
27. **M027** — Views §12 CREATE
28. **M028** — `dim_automation_settings` INSERT §13-Keys
29. **M029** — Indices §15

**Rollback:** Jede Migration hat `UP` + `DOWN`. Bei M001 DOWN: nur NEU-Felder DROP, keine bestehenden Spalten.

---

## §18 Related + Changelog

### Related Specs

- `ARK_HR_TOOL_PLAN_v0_2.md` — Grundlage
- `ARK_HR_TOOL_INTERACTIONS_v0_1.md` — UI-Flow-Definition (folgt)
- `ARK_DATABASE_SCHEMA_v1_3.md` — CRM-Basis-Schema
- `ARK_COMMISSION_ENGINE_SPEC_v0_1.md` — Bridge via `fact_provisionsvertrag_versions`
- `ARK_ZEITERFASSUNG_PLAN_v0_1.md` — Cross-Dep (Absenzen-Mirror aus `fact_absences`)

### Wiki

- Sources: [[hr-arbeitsvertraege]] · [[hr-reglemente]] · [[hr-provisionsvertraege]] · [[hr-arbeitszeugnisse]] · [[hr-weiterbildungsvereinbarung]] · [[hr-stellenbeschreibung-progressus]] · [[hr-kuendigung-aufhebung]] · [[hr-austritt-versicherung-merkblaetter]]
- Concepts: [[hr-vertragswerk]] · [[hr-academy]] · [[hr-konkurrenz-abwerbeverbot]] · [[hr-ma-rollen-matrix]]
- Analysis: [[hr-schema-deltas-2026-04-19]]
- Meta: [[rbac-matrix]] (muss erweitert werden)

### Changelog v0.1

**Initial Draft 2026-04-19:**

- Alle 18 PO-Review-Entscheidungen aus Plan v0.2 §11 eingearbeitet
- 28 Tabellen (12 dim · 15 fact · 1 audit)
- 4 Views
- 11 Config-Keys
- 7 Seed-Bereiche (Scheelen · Reglemente · Job-Descriptions · Academy · Absence-Types · Holidays-ZH · Disciplinary-Penalties)
- 29-Schritt-Migration
- `dim_mitarbeiter.commission_rate` als DEPRECATED markiert (kein DROP in v0.1)

**Tier-2-Erweiterung 2026-04-19 (in-place):**

- `dim_mitarbeiter` +7 Felder (Personalstammdaten-Formular Treuhand Kunz): `email_private`, `heirat_datum`, `partner_erwerbstaetig`, `kinder JSONB`, `konfession`, `quellensteuer_pflichtig`, `quellensteuer_kanton`
- `fact_hr_documents.document_type` +6 Enum-Werte: `personalstammdaten_formular`, `spesenabrechnung_monat`, `smarttime_export`, `hausordnung_akzeptiert_signatur`, `schluesselquittung`, `glossary_acknowledged`
- `dim_automation_settings` +10 Config-Keys: Arbeitsbeginn-Uhrzeit, Mittagspausen-Fenster, Reportingwoche-DOW, Dresscode-Defaults, Treuhänder-Email, Payroll-Export-Formats
- §14.7b neu: Onboarding-Template-Seeds für Consultant-14-Wochen + Researcher-8-Wochen mit JSONB-Phases (inkl. Academy-Module-Codes + Treuhand-Kunz-Auto-Email)
- Kein Breaking Change · nur ADD · bestehende v0.1-Migration M001+M022+M028 erweitert

**Offene Punkte für v0.2:**

- Trigger-Definitionen für `fact_absences.certificate_required` (computed via Dienstjahr + Duration + Absence-Type)
- Trigger für `fact_vacation_balances.carry_deadline_date` (jährlich via Ostern-Worker)
- Partial-Index-Optimierung nach Real-World-Query-Pattern
- Materialized-Views bei Performance-Bedarf
- RLS-Policies ausformulieren (Postgres Row-Level-Security für RBAC)
- Test-Data-Fixtures für alle Tabellen
