---
title: "ARK Billing-Modul · Schema v0.1"
type: spec
phase: 3
created: 2026-04-20
updated: 2026-04-20
status: draft
depends_on: "specs/ARK_BILLING_PLAN_v0_1.md"
sources: [
  "specs/ARK_BILLING_PLAN_v0_1.md",
  "raw/Ark_CRM_v2/Arkadium_AGB_FEB_2023.pdf",
  "raw/Ark_CRM_v2/ARK_DATABASE_SCHEMA_v1_3.md (Grundlagen-Schema)",
  "specs/ARK_COMMISSION_ENGINE_SPEC_v0_1.md",
  "wiki/meta/decisions.md (§2026-04-20 Billing-Batches 1–4 · AGB-Review · SIX-Fact-Check)"
]
grundlagen_sync_required: [
  "ARK_STAMMDATEN_EXPORT_v1_4 → v1.5 (§91 Billing-Stammdaten · alle neuen dim_*-Tabellen-Inhalte)",
  "ARK_DATABASE_SCHEMA_v1_4 → v1.5 (alle DDL unten · Views · Constraints · Indexe)",
  "ARK_BACKEND_ARCHITECTURE_v2_6 → v2.7 (Event-/Worker-/Endpoint-Liste · siehe Interactions v0.1)",
  "ARK_FRONTEND_FREEZE_v1_11 → v1.12 (Routen · UI-Patterns · siehe Interactions v0.1)",
  "ARK_GESAMTSYSTEM_UEBERSICHT_v1_3.6 → v1.4 (Changelog)"
]
tags: [spec, schema, ddl, billing, phase-3, postgresql]
---

# ARK Billing-Modul · Schema v0.1

**Komplette DDL** für Billing-Phase-3-ERP-Modul. Postgres 15+. Alle Tabellen · Views · Constraints · Indexe · Row-Level-Security · Seed-Daten · Migrations-SQL.

Grundlage: Plan v0.1 · alle 4 PO-Batches + AGB-Volltext-Review + SIX-Fact-Check.

---

## 1. Scope dieser Spec

- **IN:** DDL aller neuen Tabellen · Erweiterungen bestehender Tabellen · Views · Indexe · Constraints · Sequences · Functions (Trigger-Logik) · Seed-Daten · Migrations-Scripts
- **NICHT IN:** UI-Flows (→ Interactions v0.1) · Event-Details (→ Interactions v0.1) · Worker-Implementation (→ Interactions v0.1) · API-Endpoints (→ Interactions v0.1)

---

## 2. Namens-Konventionen

- **Tabellen:** `dim_*` (Stammdaten, überwiegend statisch) · `fact_*` (transaktional) · `bridge_*` (Many-to-Many · nicht in Billing-Modul nötig)
- **Spalten:** `snake_case` · FK-Suffix `_id` · Timestamp-Suffix `_at` · Datum-Suffix `_date` · Boolean-Präfix `is_`/`has_`
- **Enums:** als `text` mit `REFERENCES dim_*_codes(code)` (keine Postgres-Enum-Typen, besser versionierbar)
- **UUIDs:** `gen_random_uuid()` Default · keine Integer-PKs (konsistent mit Grundlagen-Schema v1.4)
- **Numeric:** CHF-Beträge `numeric(14,2)` (max 999 Mio. CHF ausreichend) · Prozente `numeric(5,2)` · Hashes `char(64)` (SHA-256 hex)

---

## 3. Neue Dim-Tabellen (Stammdaten)

### 3.1 `dim_invoice_types`

```sql
CREATE TABLE dim_invoice_types (
  code             text PRIMARY KEY,
  label_de         text NOT NULL,
  category         text NOT NULL CHECK (category IN ('invoice','refund','credit_note','cancellation')),
  affects_revenue  boolean NOT NULL DEFAULT true,
  affects_commission boolean NOT NULL DEFAULT false,
  template_variant text NOT NULL,           -- Template-Key für PDF-Generator
  requires_gf_approval boolean NOT NULL DEFAULT false,
  sort_order       smallint NOT NULL,
  is_active        boolean NOT NULL DEFAULT true,
  created_at       timestamptz NOT NULL DEFAULT now()
);

INSERT INTO dim_invoice_types (code, label_de, category, affects_revenue, affects_commission, template_variant, requires_gf_approval, sort_order) VALUES
  ('erfolg',               'Erfolgs-Rechnung',        'invoice',      true,  true,  'erfolg',               false, 10),
  ('akonto',               'Akonto-Rechnung',         'invoice',      true,  false, 'mandat_stage',         false, 20),
  ('zwischen',             'Zwischen-Rechnung',       'invoice',      true,  false, 'mandat_stage',         false, 30),
  ('schluss',              'Schluss-Rechnung',        'invoice',      true,  true,  'mandat_stage',         false, 40),
  ('mandat_time_monthly',  'Time-Mandat Monats-Rechnung', 'invoice',  true,  false, 'mandat_time',          false, 50),
  ('optionale_stage',      'Optionale Stage',         'invoice',      true,  false, 'mandat_stage_optional',true,  60),
  ('kuendigung',           'Kündigungs-Rechnung',     'invoice',      true,  false, 'kuendigung',           true,  70),
  ('assessment',           'Assessment-Rechnung',     'invoice',      true,  false, 'assessment',           false, 80),
  ('bonus_schutzfrist',    'Bonus · Schutzfrist-Verletzung', 'invoice', true, true, 'erfolg',               true,  90),
  ('refund',               'Rückerstattung',          'refund',       false, false, 'refund',               true,  100),
  ('gutschrift',           'Gutschrift',              'credit_note',  false, false, 'gutschrift',           false, 110),
  ('storno',               'Storno',                  'cancellation', false, false, 'storno',               true,  120);
```

### 3.2 `dim_invoice_status`

```sql
CREATE TABLE dim_invoice_status (
  code        text PRIMARY KEY,
  label_de    text NOT NULL,
  is_open     boolean NOT NULL,
  is_terminal boolean NOT NULL DEFAULT false,
  color_hex   text,                         -- UI-Badge-Farbe
  sort_order  smallint NOT NULL,
  is_active   boolean NOT NULL DEFAULT true
);

INSERT INTO dim_invoice_status (code, label_de, is_open, is_terminal, color_hex, sort_order) VALUES
  ('draft',                    'Entwurf',              true,  false, '#9ca3af', 10),
  ('approved',                 'Freigegeben',          true,  false, '#60a5fa', 20),
  ('issued',                   'Versendet',            true,  false, '#3b82f6', 30),
  ('partial',                  'Teilbezahlt',          true,  false, '#f59e0b', 40),
  ('paid',                     'Bezahlt',              false, true,  '#10b981', 50),
  ('overdue',                  'Überfällig',           true,  false, '#ef4444', 60),
  ('dunning_1',                'Mahnung Stufe 1',      true,  false, '#f87171', 70),
  ('dunning_2',                'Mahnung Stufe 2',      true,  false, '#dc2626', 80),
  ('dunning_3',                'Mahnung Stufe 3',      true,  false, '#b91c1c', 90),
  ('disputed',                 'Honorarstreit',        true,  false, '#c2410c', 100),
  ('gestundet',                'Gestundet',            true,  false, '#a16207', 110),
  ('collection_external',      'Inkasso extern',       true,  false, '#7c2d12', 120),
  ('debt_enforcement_pending', 'Betreibung vorbereitet', true, false, '#7c2d12', 130),
  ('payment_order_served',     'Zahlungsbefehl zugestellt', true, false, '#7c2d12', 140),
  ('legal_objection',          'Rechtsvorschlag',      true,  false, '#7c2d12', 150),
  ('rights_opening_required',  'Rechtsöffnung nötig',  true,  false, '#7c2d12', 160),
  ('cancelled',                'Storniert',            false, true,  '#6b7280', 170),
  ('refunded',                 'Rückerstattet',        false, true,  '#6b7280', 180),
  ('written_off',              'Abgeschrieben',        false, true,  '#374151', 190);
```

### 3.3 `dim_honorar_staffel`

```sql
CREATE TABLE dim_honorar_staffel (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  staffel_version text NOT NULL,                -- 'agb-feb-2023'
  valid_from      date NOT NULL,
  valid_until     date,                         -- NULL = aktiv
  salary_from_chf numeric(12,2) NOT NULL,       -- untere Grenze inklusiv
  salary_to_chf   numeric(12,2),                -- obere Grenze exklusiv · NULL = open-top
  honorar_pct     numeric(5,2) NOT NULL,
  notes           text,
  created_at      timestamptz NOT NULL DEFAULT now(),
  UNIQUE (staffel_version, salary_from_chf),
  CHECK (salary_to_chf IS NULL OR salary_to_chf > salary_from_chf),
  CHECK (honorar_pct >= 0 AND honorar_pct <= 100)
);

-- Seed: AGB FEB 2023 · §4 Honorarordnung
INSERT INTO dim_honorar_staffel (staffel_version, valid_from, salary_from_chf, salary_to_chf, honorar_pct, notes) VALUES
  ('agb-feb-2023', '2023-02-01',      0.00,  90000.00, 21.00, 'Einstieg · unter CHF 90k'),
  ('agb-feb-2023', '2023-02-01',  90000.00, 110000.00, 23.00, 'Mittel · unter CHF 110k'),
  ('agb-feb-2023', '2023-02-01', 110000.00, 130000.00, 25.00, 'Senior · unter CHF 130k'),
  ('agb-feb-2023', '2023-02-01', 130000.00, NULL,      27.00, 'Executive · ab CHF 130k');
```

### 3.4 `dim_mwst_codes`

```sql
CREATE TABLE dim_mwst_codes (
  code          text PRIMARY KEY,
  label_de      text NOT NULL,
  rate          numeric(5,2) NOT NULL,
  tax_treatment text NOT NULL CHECK (tax_treatment IN ('domestic','export','reverse_charge','exempt')),
  estv_box_code text,                           -- ESTV-Formular-Box (Ziffer 200/221/etc.)
  is_active     boolean NOT NULL DEFAULT true,
  valid_from    date NOT NULL,
  valid_until   date
);

INSERT INTO dim_mwst_codes (code, label_de, rate, tax_treatment, estv_box_code, valid_from) VALUES
  ('std_81',  'Normalsatz 8.1 %',        8.10, 'domestic',       '200', '2024-01-01'),
  ('std_77',  'Normalsatz 7.7 % (legacy)', 7.70, 'domestic',     '200', '2018-01-01'),
  ('red_26',  'Reduzierter Satz 2.6 %',  2.60, 'domestic',       '205', '2024-01-01'),
  ('lodging_38', 'Beherbergung 3.8 %',   3.80, 'domestic',       '207', '2024-01-01'),
  ('export_0','Export · 0 %',            0.00, 'export',         '221', '2010-01-01'),
  ('rc_0',    'Reverse Charge · 0 %',    0.00, 'reverse_charge', '221', '2010-01-01'),
  ('exempt',  'MwSt-befreit',            0.00, 'exempt',         '289', '2010-01-01');

UPDATE dim_mwst_codes SET valid_until = '2023-12-31' WHERE code = 'std_77';
```

### 3.5 `dim_payment_methods`

```sql
CREATE TABLE dim_payment_methods (
  code       text PRIMARY KEY,
  label_de   text NOT NULL,
  is_active  boolean NOT NULL DEFAULT true,
  sort_order smallint NOT NULL
);

INSERT INTO dim_payment_methods (code, label_de, sort_order) VALUES
  ('qr',             'QR-Überweisung',           10),
  ('bank_transfer',  'Bank-Überweisung',         20),
  ('credit_card',    'Kreditkarte',              30),
  ('twint_business', 'TWINT Business',           40),
  ('compensation',   'Verrechnung mit Gutschrift', 50),
  ('manual_journal', 'Manuelle Buchung',         60);
```

### 3.6 `dim_refund_reason_codes`

```sql
CREATE TABLE dim_refund_reason_codes (
  code            text PRIMARY KEY,
  label_de        text NOT NULL,
  business_model  text NOT NULL CHECK (business_model IN ('erfolgsbasis','mandat_target','mandat_taskforce','mandat_time','any')),
  triggers_refund boolean NOT NULL DEFAULT true,    -- false = Ersatz-Suche primär, Refund subsidiär
  staffel_pct     numeric(5,2),                     -- Refund-% bei Auto-Anwendung · NULL bei manueller Berechnung
  probezeit_phase text CHECK (probezeit_phase IN ('pre_start','month_1','month_2','month_3','post_probation','na')),
  is_active       boolean NOT NULL DEFAULT true,
  notes           text
);

INSERT INTO dim_refund_reason_codes (code, label_de, business_model, triggers_refund, staffel_pct, probezeit_phase, notes) VALUES
  ('no_start',                   'Stelle nicht angetreten',        'erfolgsbasis', true,  100.00, 'pre_start',      'AGB §8 · 100 % Refund vor Stellenantritt'),
  ('resign_month_1_probation',   'Austritt Probezeit-Monat 1',     'erfolgsbasis', true,   50.00, 'month_1',        'AGB §8'),
  ('resign_month_2_probation',   'Austritt Probezeit-Monat 2',     'erfolgsbasis', true,   25.00, 'month_2',        'AGB §8'),
  ('resign_month_3_probation',   'Austritt Probezeit-Monat 3',     'erfolgsbasis', true,   10.00, 'month_3',        'AGB §8'),
  ('resign_post_probation',      'Austritt nach Probezeit',        'erfolgsbasis', false,   0.00, 'post_probation', 'Kein Refund nach Probezeit'),
  ('mandate_early_exit',         'Mandat-Kandidat früh ausgeschieden', 'mandat_target', false, NULL, 'na',          'Ersatz-Suche primär'),
  ('mandate_early_exit_tf',      'Taskforce-Mandat früh ausgeschieden', 'mandat_taskforce', false, NULL, 'na',      'Ersatz-Suche primär'),
  ('time_exit_na',               'Time-Mandat kein Refund',        'mandat_time',  false,   0.00, 'na',             'Time-Mandat hat keine Garantie');
```

### 3.7 `dim_refund_denial_reasons`

```sql
CREATE TABLE dim_refund_denial_reasons (
  code         text PRIMARY KEY,
  label_de     text NOT NULL,
  agb_ref      text,                              -- AGB-Paragraph-Referenz
  requires_gf_override boolean NOT NULL DEFAULT false,
  is_active    boolean NOT NULL DEFAULT true
);

INSERT INTO dim_refund_denial_reasons (code, label_de, agb_ref, requires_gf_override) VALUES
  ('customer_caused_no_start',           'Kandidat kann wegen Kunden-Gründen Stelle nicht antreten', 'AGB §8', false),
  ('customer_terminated_during_probation','Kunde kündigt Kandidat während Probezeit',                'AGB §8', false),
  ('after_probation_exit',               'Austritt nach Probezeit-Ende',                              'AGB §8', false),
  ('no_notification_3d',                 '3-Tage-Meldepflicht verletzt',                              'AGB §8', true),
  ('no_cause_reported',                  'Kunde hat keine Kündigungsgründe gemeldet',                 'AGB §8', true);
```

### 3.8 `dim_credit_note_reasons`

```sql
CREATE TABLE dim_credit_note_reasons (
  code         text PRIMARY KEY,
  label_de     text NOT NULL,
  requires_gf_approval boolean NOT NULL DEFAULT true,   -- alle immer GF per PO-Decision Q8
  is_active    boolean NOT NULL DEFAULT true
);

INSERT INTO dim_credit_note_reasons (code, label_de, requires_gf_approval) VALUES
  ('error_billing',         'Rechnungs-Fehler (Betrag/Position)',   true),
  ('error_customer',        'Falscher Kunde / falsche Adresse',     true),
  ('kulanz',                'Kulanz-Gutschrift',                    true),
  ('dispute_resolved',      'Honorarstreit-Vergleich',              true),
  ('vat_correction',        'MwSt-Korrektur',                       true),
  ('duplicate_invoice',     'Doppelverrechnung',                    true),
  ('cancellation_reissue',  'Storno und Neu-Erstellung',            true),
  ('service_scope_change',  'Leistungsumfang geändert',             true);
```

### 3.9 `dim_dunning_reasons`

```sql
CREATE TABLE dim_dunning_reasons (
  code       text PRIMARY KEY,
  label_de   text NOT NULL,
  is_active  boolean NOT NULL DEFAULT true
);

INSERT INTO dim_dunning_reasons (code, label_de) VALUES
  ('late_payment',    'Zahlungsverzug'),
  ('partial_payment', 'Teilzahlung unter Soll');
```

### 3.10 `dim_account_tone_of_voice` (Enum-Tabelle)

```sql
CREATE TABLE dim_account_tone_of_voice (
  code     text PRIMARY KEY,
  label_de text NOT NULL
);

INSERT INTO dim_account_tone_of_voice (code, label_de) VALUES
  ('sie', 'Sie-Form'),
  ('du',  'Du-Form');
```

### 3.11 `dim_account_privacy_mode`

```sql
CREATE TABLE dim_account_privacy_mode (
  code       text PRIMARY KEY,
  label_de   text NOT NULL,
  sort_order smallint NOT NULL
);

INSERT INTO dim_account_privacy_mode (code, label_de, sort_order) VALUES
  ('blind_copy_only',        'Blind-Copy (Default · DSG-sicher)',   10),
  ('initials',               'Initialen (Kandidat·Datenschutz)',    20),
  ('internal_reference_only','Nur interne Referenz',                30),
  ('full_name',              'Vollname (volle Transparenz)',        40);
```

### 3.12 `dim_account_dunning_cadence_profile`

```sql
CREATE TABLE dim_account_dunning_cadence_profile (
  code        text PRIMARY KEY,
  label_de    text NOT NULL,
  days_to_l1  smallint NOT NULL,                -- T+X Tage bis Mahnung 1
  days_to_l2  smallint NOT NULL,                -- Offset von L1 bis L2
  days_to_l3  smallint NOT NULL,                -- Offset von L2 bis L3
  days_to_inkasso smallint NOT NULL,            -- Offset von L3 bis Inkasso-Eskalation
  is_active   boolean NOT NULL DEFAULT true
);

INSERT INTO dim_account_dunning_cadence_profile (code, label_de, days_to_l1, days_to_l2, days_to_l3, days_to_inkasso) VALUES
  ('standard',    'Standard-Kunde',          15, 15, 15, 5),
  ('key_account', 'Key-Account (reputationsschonend)', 30, 15, 15, 5);
```

### 3.13 `dim_qr_reference_types`

```sql
CREATE TABLE dim_qr_reference_types (
  code     text PRIMARY KEY,
  label_de text NOT NULL,
  pattern  text,                           -- Regex für Validierung
  notes    text
);

INSERT INTO dim_qr_reference_types (code, label_de, pattern, notes) VALUES
  ('QRR', 'QR-Referenz (27-stellig)',          '^[0-9]{27}$',  'Pflicht mit QR-IBAN · Modulo-10-Prüfziffer'),
  ('SCOR','Creditor Reference ISO 11649',      '^RF[0-9]{2}[A-Z0-9]{1,21}$', 'Mit klassischer IBAN · MVP-Fallback bis QR-IBAN'),
  ('NON', 'Keine Referenz',                    NULL,            'Selten · manuelle Zuordnung');
```

### 3.14 `dim_invoice_source`

```sql
CREATE TABLE dim_invoice_source (
  code     text PRIMARY KEY,
  label_de text NOT NULL
);

INSERT INTO dim_invoice_source (code, label_de) VALUES
  ('native',           'Native · im System erstellt'),
  ('migration_excel',  'Migration · aus Excel + PDF importiert');
```

---

## 4. Erweiterungen bestehender Tabellen

### 4.1 `dim_accounts`

```sql
ALTER TABLE dim_accounts ADD COLUMN IF NOT EXISTS legal_street_name     text;
ALTER TABLE dim_accounts ADD COLUMN IF NOT EXISTS legal_house_number    text;
ALTER TABLE dim_accounts ADD COLUMN IF NOT EXISTS legal_post_code       text;
ALTER TABLE dim_accounts ADD COLUMN IF NOT EXISTS legal_town_name       text;
ALTER TABLE dim_accounts ADD COLUMN IF NOT EXISTS iso_country_code      char(2) DEFAULT 'CH';
ALTER TABLE dim_accounts ADD COLUMN IF NOT EXISTS tone_of_voice         text DEFAULT 'sie' REFERENCES dim_account_tone_of_voice(code);
ALTER TABLE dim_accounts ADD COLUMN IF NOT EXISTS privacy_mode          text DEFAULT 'blind_copy_only' REFERENCES dim_account_privacy_mode(code);
ALTER TABLE dim_accounts ADD COLUMN IF NOT EXISTS dunning_cadence_profile text DEFAULT 'standard' REFERENCES dim_account_dunning_cadence_profile(code);
ALTER TABLE dim_accounts ADD COLUMN IF NOT EXISTS debtor_contact_id     uuid REFERENCES dim_contacts(contact_id);
ALTER TABLE dim_accounts ADD COLUMN IF NOT EXISTS export_status_treuhand text DEFAULT 'open' CHECK (export_status_treuhand IN ('open','exported','confirmed'));

-- Check-Constraint: bei aktiven Billing-Kunden Adress-Felder Pflicht (soft · Pre-Issue-Validator statt DB-CHECK)
-- NOTE: kein CHECK-Constraint wegen Migration-Zeit · stattdessen Pre-Issue-Validator im Rechnungs-Editor
```

### 4.2 `fact_mandate`

```sql
ALTER TABLE fact_mandate ADD COLUMN IF NOT EXISTS payment_terms_days       smallint NOT NULL DEFAULT 10;
ALTER TABLE fact_mandate ADD COLUMN IF NOT EXISTS contract_pdf_path        text;
ALTER TABLE fact_mandate ADD COLUMN IF NOT EXISTS stage_amounts_jsonb      jsonb;                                  -- {"stage_1": 10000, "stage_2": 10000, "stage_3": 15000, "optional_stage": null}
ALTER TABLE fact_mandate ADD COLUMN IF NOT EXISTS guarantee_start_policy   text NOT NULL DEFAULT 'stellenantritt' CHECK (guarantee_start_policy IN ('stellenantritt','placement_date','payment_received','custom'));
ALTER TABLE fact_mandate ADD COLUMN IF NOT EXISTS negotiated_discount_pct  numeric(5,2) NOT NULL DEFAULT 0 CHECK (negotiated_discount_pct >= 0 AND negotiated_discount_pct <= 100);
ALTER TABLE fact_mandate ADD COLUMN IF NOT EXISTS negotiated_by_user_id    uuid REFERENCES dim_mitarbeiter(mitarbeiter_id);
ALTER TABLE fact_mandate ADD COLUMN IF NOT EXISTS negotiated_at            timestamptz;

-- Time-Mandat-Felder (Weekly-Fee-Modell)
ALTER TABLE fact_mandate ADD COLUMN IF NOT EXISTS weekly_fee_chf           numeric(12,2);
ALTER TABLE fact_mandate ADD COLUMN IF NOT EXISTS time_billing_start_date  date;
ALTER TABLE fact_mandate ADD COLUMN IF NOT EXISTS time_billing_end_date    date;

-- CHECK: Time-Mandat erfordert Weekly-Fee + Start-Datum
ALTER TABLE fact_mandate ADD CONSTRAINT mandate_time_required_fields CHECK (
  business_model <> 'mandat_time' OR (weekly_fee_chf IS NOT NULL AND time_billing_start_date IS NOT NULL)
);
```

### 4.3 `fact_process_core`

```sql
ALTER TABLE fact_process_core ADD COLUMN IF NOT EXISTS negotiated_discount_pct numeric(5,2) NOT NULL DEFAULT 0 CHECK (negotiated_discount_pct >= 0 AND negotiated_discount_pct <= 100);
ALTER TABLE fact_process_core ADD COLUMN IF NOT EXISTS negotiated_by_user_id   uuid REFERENCES dim_mitarbeiter(mitarbeiter_id);
ALTER TABLE fact_process_core ADD COLUMN IF NOT EXISTS negotiated_at           timestamptz;
```

### 4.4 `fact_candidate_placement`

```sql
ALTER TABLE fact_candidate_placement ADD COLUMN IF NOT EXISTS probezeit_months smallint NOT NULL DEFAULT 3 CHECK (probezeit_months BETWEEN 1 AND 6);
ALTER TABLE fact_candidate_placement ADD COLUMN IF NOT EXISTS probezeit_end_date date GENERATED ALWAYS AS (start_date + (probezeit_months || ' months')::interval)::date STORED;
ALTER TABLE fact_candidate_placement ADD COLUMN IF NOT EXISTS guarantee_end_date date GENERATED ALWAYS AS (start_date + interval '3 months')::date STORED;
```

### 4.5 `dim_mitarbeiter`

```sql
ALTER TABLE dim_mitarbeiter ADD COLUMN IF NOT EXISTS digital_signature_img_path text;
ALTER TABLE dim_mitarbeiter ADD COLUMN IF NOT EXISTS department_code text CHECK (department_code IN ('CE&BT','ARC&REM','MS&CS','GF','BO','ADMIN'));
ALTER TABLE dim_mitarbeiter ADD COLUMN IF NOT EXISTS is_invoice_signer boolean NOT NULL DEFAULT false;
ALTER TABLE dim_mitarbeiter ADD COLUMN IF NOT EXISTS invoice_signer_priority smallint;   -- 1 = Founder, 2 = Head-of, 3 = Stv.
```

### 4.6 `dim_assessment_types` (falls noch nicht erweitert)

```sql
ALTER TABLE dim_assessment_types ADD COLUMN IF NOT EXISTS price_chf numeric(10,2);   -- Standard-Preis pro Assessment-Typ
```

---

## 5. Neue Fact-Tabellen (Transaktional)

### 5.1 `fact_invoice` (Rechnungs-Header)

```sql
CREATE TABLE fact_invoice (
  invoice_id               uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  invoice_nr               text UNIQUE NOT NULL,                  -- 'FN2026.03.0917'
  invoice_type_code        text NOT NULL REFERENCES dim_invoice_types(code),
  status_code              text NOT NULL DEFAULT 'draft' REFERENCES dim_invoice_status(code),
  source                   text NOT NULL DEFAULT 'native' REFERENCES dim_invoice_source(code),

  -- Beziehungen
  customer_id              uuid NOT NULL REFERENCES dim_accounts(account_id),
  debtor_contact_id        uuid REFERENCES dim_contacts(contact_id),
  process_id               uuid REFERENCES fact_process_core(process_id),
  mandate_id               uuid REFERENCES fact_mandate(mandate_id),
  assessment_order_id      uuid REFERENCES fact_assessment_order(assessment_order_id),
  original_invoice_id      uuid REFERENCES fact_invoice(invoice_id),   -- Storno/Gutschrift/Refund-Kette
  stage_nr                 smallint CHECK (stage_nr BETWEEN 1 AND 4),

  -- Business-Kontext
  business_model           text NOT NULL CHECK (business_model IN ('erfolgsbasis','mandat_target','mandat_taskforce','mandat_time','assessment','other')),

  -- Signatur & Sprache
  signer_primary_id        uuid NOT NULL REFERENCES dim_mitarbeiter(mitarbeiter_id),
  signer_secondary_id      uuid NOT NULL REFERENCES dim_mitarbeiter(mitarbeiter_id),
  tone_of_voice            text NOT NULL DEFAULT 'sie' REFERENCES dim_account_tone_of_voice(code),
  language                 text NOT NULL DEFAULT 'de',
  privacy_mode             text NOT NULL DEFAULT 'blind_copy_only' REFERENCES dim_account_privacy_mode(code),

  -- Vertragsreferenz
  agb_version              text NOT NULL DEFAULT 'agb-feb-2023',
  template_version         text NOT NULL,

  -- Finanzen
  currency                 char(3) NOT NULL DEFAULT 'CHF',
  amount_net               numeric(14,2) NOT NULL,
  mwst_code                text NOT NULL REFERENCES dim_mwst_codes(code),
  mwst_rate                numeric(5,2) NOT NULL,
  mwst_amount              numeric(14,2) NOT NULL,
  amount_gross             numeric(14,2) NOT NULL,
  amount_paid              numeric(14,2) NOT NULL DEFAULT 0,           -- aus fact_payment aggregiert (via Trigger)
  amount_open              numeric(14,2) GENERATED ALWAYS AS (amount_gross - amount_paid) STORED,

  -- QR-Bill
  qr_iban                  text,
  iban                     text NOT NULL,                               -- Fallback bei SCOR
  qr_reference_type        text NOT NULL DEFAULT 'SCOR' REFERENCES dim_qr_reference_types(code),
  qr_reference             text,
  qr_bill_payload_jsonb    jsonb,

  -- Kreditor (Arkadium)
  creditor_name            text NOT NULL DEFAULT 'Arkadium AG',
  creditor_address_jsonb   jsonb NOT NULL,

  -- Debitor (Kunde · Snapshot zum Rechnungs-Zeitpunkt für Revisionssicherheit)
  debtor_address_jsonb     jsonb NOT NULL,

  -- Datumsfelder
  issue_date               date,                                       -- Rechnungs-Datum
  service_date             date,                                       -- Leistungs-Datum
  due_date                 date,                                       -- Fälligkeit
  valuta_date              date,                                       -- nur bei Refund
  paid_date                date,                                       -- Erfüllt-Datum (aus letztem fact_payment)

  -- Commission-Bridge
  commission_eligibility   boolean NOT NULL DEFAULT false,              -- true wenn type ∈ (erfolg, schluss, bonus_schutzfrist)
  commission_released_at   timestamptz,

  -- Archivierung (Revisionssicherheit)
  pdf_path                 text,
  pdf_hash_sha256          char(64),
  limitation_warning_at    date GENERATED ALWAYS AS ((issue_date + interval '4 years')::date) STORED,    -- OR 128 Ziff 1 Warn-Schwelle

  -- Treuhand-Export
  export_status_treuhand   text NOT NULL DEFAULT 'open' CHECK (export_status_treuhand IN ('open','exported','confirmed')),
  exported_at              timestamptz,

  -- Dispute
  dispute_reason           text,
  disputed_since           date,

  -- Interne Notizen
  internal_note            text,

  -- Metadaten
  created_by               uuid NOT NULL REFERENCES dim_mitarbeiter(mitarbeiter_id),
  created_at               timestamptz NOT NULL DEFAULT now(),
  approved_by              uuid REFERENCES dim_mitarbeiter(mitarbeiter_id),
  approved_at              timestamptz,
  issued_by                uuid REFERENCES dim_mitarbeiter(mitarbeiter_id),
  issued_at                timestamptz,
  updated_by               uuid REFERENCES dim_mitarbeiter(mitarbeiter_id),
  updated_at               timestamptz NOT NULL DEFAULT now(),

  -- Constraints
  CONSTRAINT inv_nr_format CHECK (invoice_nr ~ '^FN[0-9]{4}\.[0-9]{2}\.[0-9]{4}$'),
  CONSTRAINT inv_amount_consistency CHECK (amount_gross = amount_net + mwst_amount),
  CONSTRAINT inv_mwst_zero_for_rc CHECK (
    (mwst_code IN ('rc_0','export_0','exempt') AND mwst_amount = 0) OR (mwst_code NOT IN ('rc_0','export_0','exempt'))
  ),
  CONSTRAINT inv_mandat_stage CHECK (
    (invoice_type_code IN ('akonto','zwischen','schluss','optionale_stage') AND stage_nr IS NOT NULL AND mandate_id IS NOT NULL)
    OR (invoice_type_code NOT IN ('akonto','zwischen','schluss','optionale_stage'))
  ),
  CONSTRAINT inv_assessment_ref CHECK (
    (invoice_type_code = 'assessment' AND assessment_order_id IS NOT NULL)
    OR (invoice_type_code <> 'assessment')
  ),
  CONSTRAINT inv_erfolg_process CHECK (
    (invoice_type_code = 'erfolg' AND process_id IS NOT NULL)
    OR (invoice_type_code <> 'erfolg')
  ),
  CONSTRAINT inv_refund_parent CHECK (
    (invoice_type_code IN ('refund','storno','gutschrift') AND original_invoice_id IS NOT NULL)
    OR (invoice_type_code NOT IN ('refund','storno','gutschrift'))
  ),
  CONSTRAINT inv_signers_different CHECK (signer_primary_id <> signer_secondary_id),
  CONSTRAINT inv_paid_le_gross CHECK (amount_paid <= amount_gross),
  CONSTRAINT inv_qr_reference_type_for_qr_iban CHECK (
    (qr_iban IS NOT NULL AND qr_reference_type = 'QRR')
    OR (qr_iban IS NULL)
  )
);
```

### 5.2 `fact_invoice_item`

```sql
CREATE TABLE fact_invoice_item (
  invoice_item_id    uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  invoice_id         uuid NOT NULL REFERENCES fact_invoice(invoice_id) ON DELETE CASCADE,
  position_no        smallint NOT NULL,
  line_type          text NOT NULL CHECK (line_type IN ('fee','discount','text','subtotal','vat_info','offener_posten')),

  -- Kandidaten-Kontext (nur bei Erfolg/Refund/Bonus)
  candidate_id       uuid REFERENCES dim_candidates(candidate_id),
  candidate_name_display text,                   -- Auflösung nach privacy_mode zum Rechnungs-Zeitpunkt
  job_role_label     text,                       -- Funktion
  sparte_code        text REFERENCES dim_sparten(code),

  -- Mandat-Stage-Kontext
  stage_no           smallint CHECK (stage_no BETWEEN 1 AND 4),
  stage_status       text CHECK (stage_status IN ('due','open_item','paid','cancelled')),

  -- Beschreibung
  description        text NOT NULL,
  quantity           numeric(10,4) NOT NULL DEFAULT 1,
  unit               text,                       -- 'Stk' / 'Wochen' / 'Monate'

  -- Preis & Rabatt
  unit_price_net     numeric(14,2) NOT NULL DEFAULT 0,
  discount_pct       numeric(5,2) NOT NULL DEFAULT 0 CHECK (discount_pct >= 0 AND discount_pct <= 100),
  honorarsatz_pct    numeric(5,2),               -- bei Erfolgsbasis · aus dim_honorar_staffel
  total_compensation numeric(14,2),              -- Basis für Erfolg-Honorar (Jahressalär + Boni + Fringe)
  total_net          numeric(14,2) NOT NULL,     -- qty × unit_price × (1 - discount_pct/100)

  -- MwSt (per Item für Mix-Rechnungen)
  mwst_code          text NOT NULL REFERENCES dim_mwst_codes(code),

  -- Zusatz-Metadaten
  meta_jsonb         jsonb,

  UNIQUE (invoice_id, position_no)
);
```

### 5.3 `fact_payment`

```sql
CREATE TABLE fact_payment (
  payment_id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  invoice_id                uuid NOT NULL REFERENCES fact_invoice(invoice_id),
  payment_date              date NOT NULL,
  valuta_date               date,
  amount                    numeric(14,2) NOT NULL,          -- negativ bei Refund-Auszahlung
  currency                  char(3) NOT NULL DEFAULT 'CHF',
  payment_method            text NOT NULL REFERENCES dim_payment_methods(code),
  qr_reference              text,
  bank_booking_jsonb        jsonb,                           -- CAMT.054-Raw-Daten
  bank_account              text,
  bank_statement_import_id  uuid,                            -- FK zu Bank-Import-Batch (optional)
  matched_confidence        numeric(5,2) CHECK (matched_confidence IS NULL OR (matched_confidence >= 0 AND matched_confidence <= 100)),
  is_auto_matched           boolean NOT NULL DEFAULT false,
  is_manual                 boolean NOT NULL DEFAULT false,
  matched_by                uuid REFERENCES dim_mitarbeiter(mitarbeiter_id),
  matched_at                timestamptz,
  reversal_of               uuid REFERENCES fact_payment(payment_id),
  created_by                uuid NOT NULL REFERENCES dim_mitarbeiter(mitarbeiter_id),
  created_at                timestamptz NOT NULL DEFAULT now()
);

-- Trigger: fact_invoice.amount_paid + status aktualisieren bei INSERT/UPDATE/DELETE auf fact_payment
CREATE OR REPLACE FUNCTION update_invoice_payment_state() RETURNS trigger AS $$
DECLARE
  target_invoice_id uuid;
  sum_paid numeric(14,2);
  inv_gross numeric(14,2);
  current_status text;
BEGIN
  IF TG_OP = 'DELETE' THEN
    target_invoice_id := OLD.invoice_id;
  ELSE
    target_invoice_id := NEW.invoice_id;
  END IF;

  SELECT COALESCE(SUM(amount), 0) INTO sum_paid FROM fact_payment WHERE invoice_id = target_invoice_id;
  SELECT amount_gross, status_code INTO inv_gross, current_status FROM fact_invoice WHERE invoice_id = target_invoice_id;

  UPDATE fact_invoice
  SET amount_paid = sum_paid,
      status_code = CASE
        WHEN sum_paid >= inv_gross AND current_status NOT IN ('cancelled','refunded','written_off') THEN 'paid'
        WHEN sum_paid > 0 AND sum_paid < inv_gross AND current_status NOT IN ('cancelled','refunded','written_off') THEN 'partial'
        ELSE current_status
      END,
      paid_date = CASE WHEN sum_paid >= inv_gross THEN (SELECT MAX(payment_date) FROM fact_payment WHERE invoice_id = target_invoice_id) ELSE paid_date END,
      updated_at = now()
  WHERE invoice_id = target_invoice_id;

  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_payment_update_invoice
  AFTER INSERT OR UPDATE OR DELETE ON fact_payment
  FOR EACH ROW EXECUTE FUNCTION update_invoice_payment_state();
```

### 5.4 `fact_dunning`

```sql
CREATE TABLE fact_dunning (
  dunning_id       uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  invoice_id       uuid NOT NULL REFERENCES fact_invoice(invoice_id) ON DELETE CASCADE,
  level            smallint NOT NULL CHECK (level BETWEEN 1 AND 3),
  issued_at        timestamptz NOT NULL,
  deadline         date NOT NULL,
  fee_amount       numeric(10,2) NOT NULL DEFAULT 0,
  interest_rate    numeric(5,2) NOT NULL DEFAULT 5.00,
  interest_amount  numeric(14,2) NOT NULL DEFAULT 0,
  reason_code      text NOT NULL DEFAULT 'late_payment' REFERENCES dim_dunning_reasons(code),
  template_version text NOT NULL,
  channel          text NOT NULL DEFAULT 'email_pdf' CHECK (channel IN ('email_pdf','post','both')),
  email_message_id text,
  pdf_path         text,
  pdf_hash_sha256  char(64),
  cancelled_at     timestamptz,                                 -- falls nach Versand Zahlung eingeht
  created_by       uuid NOT NULL REFERENCES dim_mitarbeiter(mitarbeiter_id),
  UNIQUE (invoice_id, level)
);
```

### 5.5 `fact_credit_note`

```sql
CREATE TABLE fact_credit_note (
  credit_note_id        uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  invoice_id            uuid NOT NULL REFERENCES fact_invoice(invoice_id),
  reason_code           text NOT NULL REFERENCES dim_credit_note_reasons(code),
  amount_net            numeric(14,2) NOT NULL,
  mwst_amount           numeric(14,2) NOT NULL,
  amount_gross          numeric(14,2) NOT NULL,
  issued_at             timestamptz NOT NULL,
  approved_by           uuid NOT NULL REFERENCES dim_mitarbeiter(mitarbeiter_id),
  linked_new_invoice_id uuid REFERENCES fact_invoice(invoice_id),   -- bei Storno+Neu
  pdf_path              text,
  pdf_hash_sha256       char(64),
  note                  text,
  created_at            timestamptz NOT NULL DEFAULT now(),
  CHECK (amount_gross = amount_net + mwst_amount)
);
```

### 5.6 `fact_refund`

```sql
CREATE TABLE fact_refund (
  refund_id                     uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  original_invoice_id           uuid NOT NULL REFERENCES fact_invoice(invoice_id),
  refund_invoice_id             uuid NOT NULL REFERENCES fact_invoice(invoice_id),        -- neu angelegte type=refund
  reason_process_id             uuid REFERENCES fact_process_core(process_id),
  reason_code                   text NOT NULL REFERENCES dim_refund_reason_codes(code),
  business_model                text NOT NULL,
  staffel_pct                   numeric(5,2),
  probezeit_phase_at_exit       text CHECK (probezeit_phase_at_exit IN ('pre_start','month_1','month_2','month_3','post_probation','na')),

  -- 3-Tage-Meldepflicht
  kandidat_kuendigung_date      date,
  kunden_meldung_date           date,
  meldung_within_3d             boolean,

  -- Ausschluss-Prüfung
  denial_reason_code            text REFERENCES dim_refund_denial_reasons(code),
  denied                        boolean NOT NULL DEFAULT false,

  -- Beträge
  amount_refunded_net           numeric(14,2),
  mwst_amount                   numeric(14,2),
  amount_refunded_gross         numeric(14,2),

  -- Auszahlung
  valuta_date                   date,
  customer_bank_jsonb           jsonb,                    -- Empfänger-IBAN für Arkadium-Auszahlung
  original_payment_id           uuid REFERENCES fact_payment(payment_id),

  -- Commission-Clawback
  commission_clawback_triggered boolean NOT NULL DEFAULT false,
  commission_clawback_at        timestamptz,

  -- Metadaten
  approved_by                   uuid NOT NULL REFERENCES dim_mitarbeiter(mitarbeiter_id),
  created_by                    uuid NOT NULL REFERENCES dim_mitarbeiter(mitarbeiter_id),
  created_at                    timestamptz NOT NULL DEFAULT now(),
  paid_at                       timestamptz,
  note                          text,

  CHECK (
    (denied = true AND denial_reason_code IS NOT NULL)
    OR
    (denied = false AND denial_reason_code IS NULL AND amount_refunded_gross IS NOT NULL)
  ),
  CHECK (amount_refunded_gross IS NULL OR amount_refunded_gross = amount_refunded_net + mwst_amount)
);
```

### 5.7 `fact_inkasso`

```sql
CREATE TABLE fact_inkasso (
  inkasso_id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  invoice_id         uuid NOT NULL REFERENCES fact_invoice(invoice_id),
  partner_name       text NOT NULL,
  partner_contact    text,
  handed_over_at     date NOT NULL,
  dossier_zip_path   text,                                -- Export-Paket mit Vertrag+AGB+Rechnung+Mahnungen+Korrespondenz
  expected_recovery  numeric(14,2),
  recovered          numeric(14,2) NOT NULL DEFAULT 0,
  fee_expected       numeric(14,2),
  fee_actual         numeric(14,2),
  status             text NOT NULL CHECK (status IN ('sent','in_progress','recovered','partial_recovery','written_off')),
  betreibung_nr      text,                                -- Betreibungs-Nr falls SchKG-Verfahren
  closed_at          date,
  note               text,
  created_by         uuid NOT NULL REFERENCES dim_mitarbeiter(mitarbeiter_id),
  approved_by_gf     uuid NOT NULL REFERENCES dim_mitarbeiter(mitarbeiter_id),
  created_at         timestamptz NOT NULL DEFAULT now()
);
```

### 5.8 `fact_invoice_audit`

```sql
CREATE TABLE fact_invoice_audit (
  audit_id        uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  invoice_id      uuid NOT NULL REFERENCES fact_invoice(invoice_id) ON DELETE CASCADE,
  event_type      text NOT NULL,                          -- 'created','approved','issued','sent','paid','dunning_sent','disputed','cancelled','refunded','migration_import','template_rendered','hash_verified'
  old_value_jsonb jsonb,
  new_value_jsonb jsonb,
  actor_user_id   uuid REFERENCES dim_mitarbeiter(mitarbeiter_id),
  actor_system    text,                                   -- bei System-Events (Worker-Name)
  created_at      timestamptz NOT NULL DEFAULT now()
);
```

---

## 6. Views

### 6.1 `v_invoice_open` (Aging)

```sql
CREATE VIEW v_invoice_open AS
SELECT
  inv.invoice_id,
  inv.invoice_nr,
  inv.customer_id,
  acc.name AS customer_name,
  inv.amount_open,
  inv.due_date,
  (CURRENT_DATE - inv.due_date) AS days_overdue,
  CASE
    WHEN inv.due_date >= CURRENT_DATE THEN 'not_yet_due'
    WHEN (CURRENT_DATE - inv.due_date) BETWEEN 0 AND 30 THEN 'aging_0_30'
    WHEN (CURRENT_DATE - inv.due_date) BETWEEN 31 AND 60 THEN 'aging_31_60'
    WHEN (CURRENT_DATE - inv.due_date) BETWEEN 61 AND 90 THEN 'aging_61_90'
    ELSE 'aging_90_plus'
  END AS aging_bucket,
  inv.status_code,
  inv.dispute_reason IS NOT NULL AS is_disputed
FROM fact_invoice inv
JOIN dim_accounts acc ON acc.account_id = inv.customer_id
WHERE inv.status_code NOT IN ('paid','cancelled','refunded','written_off','draft');
```

### 6.2 `v_invoice_dunning_queue`

```sql
CREATE VIEW v_invoice_dunning_queue AS
SELECT
  inv.invoice_id,
  inv.invoice_nr,
  inv.customer_id,
  acc.name AS customer_name,
  acc.dunning_cadence_profile,
  cad.days_to_l1,
  cad.days_to_l2,
  cad.days_to_l3,
  inv.due_date,
  inv.amount_open,
  inv.status_code,
  (SELECT MAX(level) FROM fact_dunning WHERE invoice_id = inv.invoice_id AND cancelled_at IS NULL) AS current_dunning_level,
  (SELECT MAX(deadline) FROM fact_dunning WHERE invoice_id = inv.invoice_id AND cancelled_at IS NULL) AS last_dunning_deadline,
  CASE
    WHEN inv.status_code = 'overdue' AND (SELECT MAX(level) FROM fact_dunning WHERE invoice_id = inv.invoice_id) IS NULL
         AND (CURRENT_DATE - inv.due_date) >= cad.days_to_l1 THEN 1
    WHEN (SELECT MAX(level) FROM fact_dunning WHERE invoice_id = inv.invoice_id) = 1
         AND (CURRENT_DATE - (SELECT MAX(deadline) FROM fact_dunning WHERE invoice_id = inv.invoice_id)) >= 0 THEN 2
    WHEN (SELECT MAX(level) FROM fact_dunning WHERE invoice_id = inv.invoice_id) = 2
         AND (CURRENT_DATE - (SELECT MAX(deadline) FROM fact_dunning WHERE invoice_id = inv.invoice_id)) >= 0 THEN 3
    WHEN (SELECT MAX(level) FROM fact_dunning WHERE invoice_id = inv.invoice_id) = 3
         AND (CURRENT_DATE - (SELECT MAX(deadline) FROM fact_dunning WHERE invoice_id = inv.invoice_id)) >= cad.days_to_inkasso THEN 99   -- Inkasso-Eskalation
    ELSE NULL
  END AS next_dunning_level_due
FROM fact_invoice inv
JOIN dim_accounts acc ON acc.account_id = inv.customer_id
JOIN dim_account_dunning_cadence_profile cad ON cad.code = acc.dunning_cadence_profile
WHERE inv.status_code IN ('overdue','dunning_1','dunning_2','dunning_3')
  AND inv.dispute_reason IS NULL;
```

### 6.3 `v_mwst_quarter`

```sql
CREATE VIEW v_mwst_quarter AS
SELECT
  date_trunc('quarter', inv.issue_date)::date AS quarter_start,
  mwst.code AS mwst_code,
  mwst.rate AS mwst_rate,
  mwst.tax_treatment,
  mwst.estv_box_code,
  COUNT(*) AS invoice_count,
  SUM(CASE WHEN inv.invoice_type_code IN ('refund','gutschrift','storno') THEN -inv.amount_net ELSE inv.amount_net END) AS net_total,
  SUM(CASE WHEN inv.invoice_type_code IN ('refund','gutschrift','storno') THEN -inv.mwst_amount ELSE inv.mwst_amount END) AS mwst_total,
  SUM(CASE WHEN inv.invoice_type_code IN ('refund','gutschrift','storno') THEN -inv.amount_gross ELSE inv.amount_gross END) AS gross_total
FROM fact_invoice inv
JOIN dim_mwst_codes mwst ON mwst.code = inv.mwst_code
WHERE inv.status_code NOT IN ('draft','approved','cancelled')
GROUP BY date_trunc('quarter', inv.issue_date), mwst.code, mwst.rate, mwst.tax_treatment, mwst.estv_box_code;
```

### 6.4 `v_customer_ledger`

```sql
CREATE VIEW v_customer_ledger AS
SELECT
  acc.account_id AS customer_id,
  acc.name AS customer_name,
  acc.dunning_cadence_profile,
  COUNT(DISTINCT inv.invoice_id) FILTER (WHERE inv.status_code NOT IN ('paid','cancelled','refunded','written_off','draft')) AS open_invoice_count,
  COALESCE(SUM(inv.amount_open) FILTER (WHERE inv.status_code NOT IN ('paid','cancelled','refunded','written_off','draft')), 0) AS open_balance,
  COALESCE(SUM(inv.amount_gross) FILTER (WHERE inv.status_code = 'paid' AND inv.issue_date >= date_trunc('year', CURRENT_DATE)), 0) AS paid_ytd,
  COALESCE(SUM(pay.amount) FILTER (WHERE pay.payment_date >= CURRENT_DATE - interval '30 days'), 0) AS payments_last_30d,
  MAX(inv.issue_date) AS last_invoice_date,
  AVG(EXTRACT(days FROM (inv.paid_date - inv.issue_date))) FILTER (WHERE inv.paid_date IS NOT NULL) AS avg_days_to_pay
FROM dim_accounts acc
LEFT JOIN fact_invoice inv ON inv.customer_id = acc.account_id
LEFT JOIN fact_payment pay ON pay.invoice_id = inv.invoice_id
GROUP BY acc.account_id, acc.name, acc.dunning_cadence_profile;
```

### 6.5 `v_refund_clawback`

```sql
CREATE VIEW v_refund_clawback AS
SELECT
  ref.refund_id,
  ref.refund_invoice_id,
  orig.invoice_nr AS original_invoice_nr,
  ref.reason_code,
  ref.amount_refunded_gross,
  ref.commission_clawback_triggered,
  ref.commission_clawback_at,
  ref.reason_process_id,
  proc.am_user_id,
  proc.cm_user_id,
  ref.paid_at
FROM fact_refund ref
JOIN fact_invoice orig ON orig.invoice_id = ref.original_invoice_id
LEFT JOIN fact_process_core proc ON proc.process_id = ref.reason_process_id
WHERE ref.denied = false AND ref.commission_clawback_triggered = false;
```

---

## 7. Indexes

```sql
-- fact_invoice
CREATE UNIQUE INDEX ux_invoice_nr ON fact_invoice(invoice_nr);
CREATE INDEX ix_invoice_customer ON fact_invoice(customer_id);
CREATE INDEX ix_invoice_process ON fact_invoice(process_id) WHERE process_id IS NOT NULL;
CREATE INDEX ix_invoice_mandate ON fact_invoice(mandate_id) WHERE mandate_id IS NOT NULL;
CREATE INDEX ix_invoice_assessment_order ON fact_invoice(assessment_order_id) WHERE assessment_order_id IS NOT NULL;
CREATE INDEX ix_invoice_original ON fact_invoice(original_invoice_id) WHERE original_invoice_id IS NOT NULL;
CREATE INDEX ix_invoice_status_due ON fact_invoice(status_code, due_date);
CREATE INDEX ix_invoice_issue_date ON fact_invoice(issue_date);
CREATE INDEX ix_invoice_limitation_warning ON fact_invoice(limitation_warning_at) WHERE status_code NOT IN ('paid','cancelled','refunded','written_off');
CREATE INDEX ix_invoice_type_status ON fact_invoice(invoice_type_code, status_code);
CREATE INDEX ix_invoice_export_pending ON fact_invoice(export_status_treuhand) WHERE export_status_treuhand = 'open';

-- fact_invoice_item
CREATE INDEX ix_invoice_item_invoice ON fact_invoice_item(invoice_id);
CREATE INDEX ix_invoice_item_candidate ON fact_invoice_item(candidate_id) WHERE candidate_id IS NOT NULL;

-- fact_payment
CREATE INDEX ix_payment_invoice ON fact_payment(invoice_id);
CREATE INDEX ix_payment_qr_ref ON fact_payment(qr_reference) WHERE qr_reference IS NOT NULL;
CREATE INDEX ix_payment_date ON fact_payment(payment_date);
CREATE INDEX ix_payment_import_batch ON fact_payment(bank_statement_import_id) WHERE bank_statement_import_id IS NOT NULL;

-- fact_dunning
CREATE INDEX ix_dunning_invoice ON fact_dunning(invoice_id);
CREATE INDEX ix_dunning_deadline ON fact_dunning(deadline) WHERE cancelled_at IS NULL;

-- fact_refund
CREATE INDEX ix_refund_original ON fact_refund(original_invoice_id);
CREATE INDEX ix_refund_process ON fact_refund(reason_process_id) WHERE reason_process_id IS NOT NULL;
CREATE INDEX ix_refund_clawback_open ON fact_refund(commission_clawback_triggered) WHERE commission_clawback_triggered = false AND denied = false;

-- fact_credit_note
CREATE INDEX ix_credit_note_invoice ON fact_credit_note(invoice_id);

-- fact_inkasso
CREATE INDEX ix_inkasso_status ON fact_inkasso(status);

-- fact_invoice_audit
CREATE INDEX ix_invoice_audit_invoice_time ON fact_invoice_audit(invoice_id, created_at DESC);
CREATE INDEX ix_invoice_audit_event ON fact_invoice_audit(event_type, created_at DESC);

-- dim_honorar_staffel lookup
CREATE INDEX ix_honorar_staffel_lookup ON dim_honorar_staffel(staffel_version, salary_from_chf, salary_to_chf) WHERE valid_until IS NULL;
```

---

## 8. Row-Level-Security

```sql
ALTER TABLE fact_invoice ENABLE ROW LEVEL SECURITY;
ALTER TABLE fact_payment ENABLE ROW LEVEL SECURITY;

-- Policy: AM/CM sehen nur eigene Kunden (über dim_accounts.owner_am_id / owner_cm_id)
CREATE POLICY invoice_read_am_cm ON fact_invoice
  FOR SELECT
  USING (
    current_setting('app.current_role', true) = 'am_cm' AND
    customer_id IN (
      SELECT account_id FROM dim_accounts
      WHERE owner_am_id::text = current_setting('app.current_user_id', true)
         OR owner_cm_id::text = current_setting('app.current_user_id', true)
    )
  );

CREATE POLICY invoice_read_backoffice ON fact_invoice
  FOR SELECT
  USING (current_setting('app.current_role', true) IN ('backoffice','gf','admin','treuhand'));

CREATE POLICY invoice_write_backoffice ON fact_invoice
  FOR INSERT WITH CHECK (current_setting('app.current_role', true) IN ('backoffice','gf'));

CREATE POLICY invoice_update_backoffice ON fact_invoice
  FOR UPDATE USING (current_setting('app.current_role', true) IN ('backoffice','gf'))
              WITH CHECK (current_setting('app.current_role', true) IN ('backoffice','gf'));

-- Payment: analog
CREATE POLICY payment_read ON fact_payment
  FOR SELECT
  USING (
    current_setting('app.current_role', true) IN ('backoffice','gf','admin','treuhand')
    OR (
      current_setting('app.current_role', true) = 'am_cm' AND
      invoice_id IN (
        SELECT inv.invoice_id FROM fact_invoice inv
        JOIN dim_accounts acc ON acc.account_id = inv.customer_id
        WHERE acc.owner_am_id::text = current_setting('app.current_user_id', true)
           OR acc.owner_cm_id::text = current_setting('app.current_user_id', true)
      )
    )
  );
```

---

## 9. Rechnungs-Nr-Sequence

```sql
-- Pro Jahr eine Sequence · Advisory-Lock für Concurrency
CREATE OR REPLACE FUNCTION generate_invoice_nr(p_year int DEFAULT EXTRACT(year FROM CURRENT_DATE)::int)
  RETURNS text AS $$
DECLARE
  seq_name text;
  next_val bigint;
  current_month int;
BEGIN
  seq_name := 'seq_invoice_' || p_year;
  current_month := EXTRACT(month FROM CURRENT_DATE)::int;

  -- Sequence anlegen falls nicht existiert (jahresweise)
  EXECUTE format('CREATE SEQUENCE IF NOT EXISTS %I START WITH 1', seq_name);

  PERFORM pg_advisory_xact_lock(hashtext(seq_name));
  EXECUTE format('SELECT nextval(%L)', seq_name) INTO next_val;

  RETURN format('FN%s.%s.%s', p_year::text, lpad(current_month::text, 2, '0'), lpad(next_val::text, 4, '0'));
END;
$$ LANGUAGE plpgsql;
```

---

## 10. QRR-Referenz-Generator

```sql
-- 27-stellige QRR mit Modulo-10-Prüfziffer
CREATE OR REPLACE FUNCTION generate_qrr_reference(p_invoice_nr text) RETURNS text AS $$
DECLARE
  digits_only text;
  padded text;
  checksum int;
  mod10_table int[] := ARRAY[0,9,4,6,8,2,7,1,3,5];
  current_digit int;
  carry int := 0;
  i int;
BEGIN
  -- Extract digits from invoice_nr (FN2026.03.0917 → 2026030917)
  digits_only := regexp_replace(p_invoice_nr, '[^0-9]', '', 'g');
  padded := lpad(digits_only, 26, '0');

  -- Modulo-10-Recursive
  FOR i IN 1..26 LOOP
    current_digit := (substring(padded FROM i FOR 1))::int;
    carry := mod10_table[((carry + current_digit) % 10) + 1];
  END LOOP;

  checksum := (10 - carry) % 10;
  RETURN padded || checksum::text;
END;
$$ LANGUAGE plpgsql IMMUTABLE;
```

---

## 11. Migrations-Scripts

### 11.1 Adress-Strukturierung Bestandskunden

```sql
-- Step 1: Backup
CREATE TABLE dim_accounts_backup_pre_billing AS SELECT * FROM dim_accounts;

-- Step 2: Regex-Parsing (heuristisch · manuelle Nachbesserung nötig)
UPDATE dim_accounts SET
  legal_street_name = trim(regexp_replace(address_line_1, '\s+\S+\s*$', '')),
  legal_house_number = COALESCE(substring(address_line_1 FROM '\s(\S+)$'), ''),
  legal_post_code = COALESCE(substring(address_line_2 FROM '^(\d{4,5})'), ''),
  legal_town_name = COALESCE(trim(substring(address_line_2 FROM '\d{4,5}\s+(.+)$')), ''),
  iso_country_code = 'CH'
WHERE legal_street_name IS NULL;

-- Step 3: Log invalid rows (manuelle Korrektur)
CREATE TEMP TABLE invalid_addresses AS
SELECT account_id, name, address_line_1, address_line_2
FROM dim_accounts
WHERE legal_street_name IS NULL OR legal_street_name = ''
   OR legal_post_code NOT SIMILAR TO '\d{4,5}';
-- → Backoffice bekommt Task pro Zeile
```

### 11.2 Altrechnungen-Import (Excel + PDF)

```sql
-- Worker billing-excel-pdf-import liest Excel-Sheets + PDFs und baut fact_invoice auf
-- Pseudo-SQL (eigentliche Logik im Worker-Code):

-- Für jede Altrechnung aus Rechnungssheet_Best Effort.xlsx:
INSERT INTO fact_invoice (
  invoice_nr, invoice_type_code, status_code, source, customer_id, business_model,
  signer_primary_id, signer_secondary_id, agb_version, template_version,
  amount_net, mwst_code, mwst_rate, mwst_amount, amount_gross,
  iban, qr_reference_type,
  creditor_name, creditor_address_jsonb, debtor_address_jsonb,
  issue_date, due_date, paid_date,
  pdf_path, pdf_hash_sha256,
  created_by, issued_at
) VALUES (
  :excel_invoice_nr,                    -- aus Excel übernommen
  :mapped_type,                          -- erfolg / akonto / zwischen / schluss / refund
  'paid',                                -- Default für Altrechnungen
  'migration_excel',
  :excel_customer_id,
  :excel_business_model,
  :nenad_stoparanovic_id,
  :head_of_by_excel,
  'agb-feb-2023',
  'migration-import',
  :excel_amount_net, :excel_mwst_code, 8.10, :excel_mwst_amount, :excel_amount_gross,
  'CH07 0077 7009 0644 7451 4', 'SCOR',
  '{"name":"Arkadium AG","street":"Maneggstrasse","house":"45","post_code":"8041","town":"Zürich","country":"CH"}'::jsonb,
  :excel_debtor_address,
  :excel_issue_date, :excel_due_date, :excel_paid_date,
  :pdf_path,
  :computed_sha256,
  :system_user_id, :excel_issue_date::timestamptz
);

-- Audit-Log
INSERT INTO fact_invoice_audit (invoice_id, event_type, actor_system, new_value_jsonb)
SELECT invoice_id, 'migration_import', 'billing-excel-pdf-import',
       jsonb_build_object('source_excel', :excel_filename, 'source_pdf', :pdf_path)
FROM fact_invoice WHERE source = 'migration_excel';
```

### 11.3 ISO-Country-Code-Pflicht

```sql
-- Nach Migration: NOT NULL Constraint
ALTER TABLE dim_accounts ALTER COLUMN iso_country_code SET NOT NULL;
ALTER TABLE dim_accounts ADD CONSTRAINT iso_country_code_format CHECK (iso_country_code ~ '^[A-Z]{2}$');
```

### 11.4 Honorar-Staffel-Version-Upgrade (Beispiel AGB-Revision)

```sql
-- Bei AGB-Revision: neue Version seeden, alte valid_until setzen
UPDATE dim_honorar_staffel SET valid_until = '2027-01-31' WHERE staffel_version = 'agb-feb-2023';

INSERT INTO dim_honorar_staffel (staffel_version, valid_from, salary_from_chf, salary_to_chf, honorar_pct, notes) VALUES
  ('agb-feb-2027', '2027-02-01',      0.00, 100000.00, 22.00, 'Revision'),
  ('agb-feb-2027', '2027-02-01', 100000.00, 140000.00, 26.00, 'Revision'),
  ('agb-feb-2027', '2027-02-01', 140000.00, NULL,      28.00, 'Revision');
```

---

## 12. Constraints & Invariants · Zusammenfassung

| Invariante | Enforcement |
|------------|-------------|
| `invoice_nr` eindeutig + Format `FN{YYYY}.{MM}.{####}` | UNIQUE + CHECK |
| `amount_gross = amount_net + mwst_amount` | CHECK |
| `mwst_amount = 0` bei Reverse-Charge/Export/Exempt | CHECK |
| Mandat-Invoice hat `stage_nr` + `mandate_id` | CHECK |
| Assessment-Invoice hat `assessment_order_id` | CHECK |
| Refund/Storno/Gutschrift hat `original_invoice_id` | CHECK |
| Signer primary ≠ secondary | CHECK |
| `amount_paid ≤ amount_gross` | CHECK + Trigger |
| QR-IBAN impliziert `reference_type = QRR` | CHECK |
| Time-Mandat erfordert `weekly_fee_chf` + `time_billing_start_date` | CHECK auf `fact_mandate` |
| Refund-denied erfordert `denial_reason_code`, Refund-approved erfordert `amount_refunded_gross` | CHECK |
| Rechnungs-Nr-Generierung transaktional über advisory-lock | `generate_invoice_nr()` Function |
| Payment-Summe triggert Invoice-Status-Update | Trigger `trg_payment_update_invoice` |
| RLS AM/CM nur eigene Kunden | Row-Level-Security-Policies |

---

## 13. Grundlagen-Sync-Checkliste (nach Schema-v0.1-Freeze)

- [ ] `ARK_STAMMDATEN_EXPORT_v1_4.md` → v1.5 · neuer §91 Billing-Stammdaten (alle `dim_*`-Kataloge mit Seed-Daten)
- [ ] `ARK_DATABASE_SCHEMA_v1_4.md` → v1.5 · alle DDL oben · Views · Constraints · Indexe · Functions · Triggers
- [ ] `ARK_BACKEND_ARCHITECTURE_v2_6.md` → v2.7 · Events/Worker/Endpoints (→ Interactions v0.1 Referenz)
- [ ] `ARK_FRONTEND_FREEZE_v1_11.md` → v1.12 · Routen + UI-Patterns (→ Interactions v0.1 Referenz)
- [ ] `ARK_GESAMTSYSTEM_UEBERSICHT_v1_3.6.md` → v1.4 · Changelog-Eintrag "Billing-Modul v0.1"

---

**Status v0.1 · Draft · Review-Ready.** Nächste Spec: `ARK_BILLING_INTERACTIONS_v0_1.md` (UI-Flows · Event-Details · Worker · Endpoints · Screen-Wireframes).
