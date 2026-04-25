---
title: "ARK Zeit-Modul · Schema v0.1"
type: spec
module: zeit
version: 0.1
created: 2026-04-19
updated: 2026-04-19
status: draft
sources: [
  "wiki/sources/phase3-research/zeit/zeit-research-overview.md",
  "wiki/sources/phase3-research/zeit/zeit-research-ai2-compass.md",
  "wiki/sources/phase3-research/zeit/zeit-research-ai3-deep-spec.md",
  "wiki/sources/phase3-research/zeit/zeit-research-ai1-structured.md",
  "wiki/sources/hr-reglemente.md",
  "wiki/meta/zeit-decisions-2026-04-19.md"
]
tags: [spec, schema, zeit, arbeitszeit, absenzen, scanner, dsg]
---

# ARK Zeit-Modul · Database Schema v0.1

**Scope:** Vollständiges PostgreSQL-Schema für das Zeit-ERP-Modul. Deckt Arbeitszeiterfassung (inkl. Fingerabdruckscanner), Abwesenheitsmanagement, Ferien-/Überzeit-Konten, Monats-Lock + Treuhand-Export, Extra-Guthaben (Arkadium-spezifisch).

**Grundlagen-Sync erforderlich:** `ARK_STAMMDATEN_EXPORT_v1_4.md` · `ARK_DATABASE_SCHEMA_v1_4.md` · `ARK_BACKEND_ARCHITECTURE_v2_6.md` · `ARK_FRONTEND_FREEZE_v1_11.md`

**Legal-Basis:**
- ArG Art. 9 (45h Höchstarbeitszeit), Art. 12 (170h Jahres-Überzeit), Art. 15/15a (Pausen/Ruhezeit), Art. 46 (Aufzeichnungspflicht)
- ArGV 1 Art. 73 (Erfassungsinhalt, 5 J Aufbewahrung), Art. 73b (vereinfachte Erfassung)
- OR Art. 321c (Überstunden), Art. 324a (Lohnfortzahlung), Art. 329a-c (Ferien)
- revDSG Art. 5 Ziff. 4 (biometrische Daten = besondere Personendaten)
- BGE 4A_227/2017 (indirekte Erfassungspflicht), BGE 124 III 126 (Skalen zulässig)
- Arkadium-Reglemente: Generalis Provisio (§3.5.2, §6.2.1), Tempus Passio 365 (§2), Locus Extra

**Peter-Decisions:** [zeit-decisions-2026-04-19.md](../wiki/meta/zeit-decisions-2026-04-19.md)

---

## 1. Schema-Prinzipien

1. **UUID-Primary-Keys** durchgängig (`gen_random_uuid()`). Sequenzielle Leaks vermieden, verteilbar.
2. **ENUMs** (nicht VARCHAR) für State/Category/Kind — DB-seitige Integrität.
3. **GIST-Overlap-Prevention** (Extension `btree_gist`) auf time_entry + absence.
4. **`audit_trail_jsonb`** append-only auf allen Mutationen.
5. **`retention_until DATE`** für DSG-konforme Lösch-Jobs (Pflicht-Retention 5 J post-Gültigkeit).
6. **3-Konten-Saldo** streng getrennt: Sollzeit · OR-Überstunden · ArG-Überzeit (auch wenn bei 45h-Normalarbeitszeit OR-Zone leer, bleibt Schema für MA mit <45h-Vertrag nutzbar).
7. **Scanner-Roh vs. Counted**: `raw_duration_min` (Scanner) vs. `counted_duration_min` (10h-gecapped). Beides gespeichert für Audit.
8. **Reglement-Werte** als Seeds eingetragen, nicht hardcoded in Business-Logic.

---

## 2. PostgreSQL Extensions

```sql
CREATE EXTENSION IF NOT EXISTS pgcrypto;     -- gen_random_uuid()
CREATE EXTENSION IF NOT EXISTS btree_gist;   -- GIST-Overlap-Constraints
```

---

## 3. ENUM-Types

```sql
-- Time-Entry-Lifecycle
CREATE TYPE time_entry_state AS ENUM (
    'draft',        -- MA erfasst, noch editierbar
    'submitted',    -- MA hat Monat eingereicht
    'approved',     -- TL hat approved
    'locked',       -- Monatslock, export-bereit
    'corrected',    -- historische Version nach Korrektur
    'rejected'      -- TL hat abgelehnt, zurück zu draft
);

-- Absence-Lifecycle
CREATE TYPE absence_state AS ENUM (
    'draft',
    'submitted',
    'approved',
    'active',       -- Start-Datum erreicht
    'completed',    -- End-Datum vorbei
    'rejected',
    'cancelled',
    'corrected'
);

-- Correction-Lifecycle
CREATE TYPE correction_state AS ENUM (
    'requested',
    'tl_approved',
    'gf_approved',
    'applied',
    'rejected'
);

-- Monats-Lock-State
CREATE TYPE period_close_state AS ENUM (
    'open',
    'submitted',
    'tl_approved',
    'gf_approved',
    'locked',
    'exported',
    'reopened'      -- bei Admin-Override
);

-- Arbeitszeit-Modell
CREATE TYPE work_time_model AS ENUM (
    'FLEX_CORE',        -- Gleitzeit mit Kernzeit (Default)
    'FIXED',            -- Fix-Zeit
    'PARTTIME',         -- Teilzeit %
    'SIMPLIFIED_73B',   -- Vereinfachte Erfassung Art. 73b ArGV 1
    'EXEMPT_EXEC'       -- Höhere leitende Tätigkeit (Art. 3 ArG) · Ausnahme
);

-- Scan-Event-Typ (Fingerabdruckscanner)
CREATE TYPE scan_event_type AS ENUM (
    'check_in',         -- Arbeitsbeginn
    'check_out',        -- Arbeitsende
    'break_start',      -- Pause beginnt
    'break_end',        -- Pause endet
    'override'          -- manuelle Admin-Korrektur
);

-- Time-Entry-Source
CREATE TYPE time_entry_source AS ENUM (
    'scanner',          -- Fingerabdruckscanner (primär)
    'manual',           -- MA hat manuell nachgetragen
    'timer',            -- Web-UI-Timer (wenn scanner-frei)
    'import',           -- CSV-Import
    'admin'             -- Admin hat korrigiert
);

-- Time-Kind (3-Konten-Saldo)
CREATE TYPE overtime_kind AS ENUM (
    'regular',          -- im Soll
    'ueberstunden_or',  -- OR Art. 321c (über Vertrag, innerhalb 45h)
    'ueberzeit_arg',    -- ArG Art. 12 (über 45h, Jahres-Cap 170h)
    'uncounted'         -- >10h/Tag · Firmenpolicy-Cut
);

-- Lohnfortzahlungs-Skala
CREATE TYPE salary_scale_code AS ENUM (
    'ZURICH',           -- Zürcher Skala (Default laut Reglement)
    'BERN',
    'BASEL',
    'INSURANCE_EQUIV'   -- KTG-Versicherung ≥80% 720 Tage
);

-- Skala-Phase (für fact_salary_continuation)
CREATE TYPE salary_continuation_phase AS ENUM (
    'full_100',         -- 100% Lohn AG
    'partial_ktg',      -- 80% über KTG-Versicherung
    'unpaid'            -- Anspruch ausgeschöpft
);
```

---

## 4. Dimension Tables

### 4.1 `dim_absence_type`

Abwesenheits-Katalog (Reglement + Gesetz).

```sql
CREATE TABLE dim_absence_type (
    code                        VARCHAR(40) PRIMARY KEY,
    label_de                    VARCHAR(120) NOT NULL,
    paid_default                BOOLEAN NOT NULL,
    counts_toward_target        BOOLEAN NOT NULL DEFAULT TRUE,  -- zählt als Sollgutschrift
    max_days_per_year           NUMERIC(6,2) NULL,
    requires_cert_from_day_1dj  SMALLINT NULL,    -- 1. Dienstjahr (Reglement §3.5.2)
    requires_cert_from_day_2dj  SMALLINT NULL,    -- 2. Dienstjahr
    requires_cert_from_day_3dj  SMALLINT NULL,    -- 3.+ Dienstjahr
    requires_approval           BOOLEAN NOT NULL DEFAULT TRUE,
    affects_vacation_accrual    BOOLEAN NOT NULL DEFAULT FALSE,
    legal_basis_ref             VARCHAR(200) NULL,
    swissdec_wage_type          VARCHAR(20) NULL, -- Mapping ELM 5.0
    bexio_absence_type_id       INTEGER NULL,     -- Mapping Bexio
    category                    VARCHAR(40) NULL, -- 'medical' | 'family' | 'civic' | 'policy' | 'extra'
    active                      BOOLEAN NOT NULL DEFAULT TRUE,
    created_at                  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_cert_days_1dj CHECK (requires_cert_from_day_1dj IS NULL OR requires_cert_from_day_1dj >= 1),
    CONSTRAINT chk_cert_days_2dj CHECK (requires_cert_from_day_2dj IS NULL OR requires_cert_from_day_2dj >= 1),
    CONSTRAINT chk_cert_days_3dj CHECK (requires_cert_from_day_3dj IS NULL OR requires_cert_from_day_3dj >= 1)
);
```

**Seeds (Phase 1):**

| code | label_de | paid | cat | 1DJ | 2DJ | 3+DJ | legal |
|------|----------|------|-----|-----|-----|------|-------|
| VACATION | Ferien | ✓ | policy | – | – | – | OR 329a |
| VACATION_HALF_AM | Ferien-Halbtag Vormittag | ✓ | policy | – | – | – | OR 329a |
| VACATION_HALF_PM | Ferien-Halbtag Nachmittag | ✓ | policy | – | – | – | OR 329a |
| SICK_PAID | Krankheit (bezahlt) | ✓ | medical | 1 | 2 | 3 | OR 324a, Reglement §3.5.2 |
| SICK_UNPAID | Krankheit (unbezahlt) | ✗ | medical | 1 | 1 | 1 | OR 324a |
| ACCIDENT_OCC | Berufsunfall (UVG) | ✓ | medical | 1 | 1 | 1 | UVG |
| ACCIDENT_NOCC | Nichtberufsunfall (UVG) | ✓ | medical | 1 | 1 | 1 | UVG |
| MILITARY | Militärdienst | ✓ | civic | – | – | – | EOG, OR 324b |
| CIVIL_SERVICE | Zivildienst | ✓ | civic | – | – | – | EOG |
| CIVIL_PROTECTION | Zivilschutz | ✓ | civic | – | – | – | EOG |
| FIREFIGHTER | Feuerwehr-Einsatz | ✓ | civic | – | – | – | EOG |
| REDCROSS | Rotkreuz-Einsatz | ✓ | civic | – | – | – | EOG |
| MATERNITY | Mutterschaftsurlaub 16 Wo | ✓ | family | – | – | – | EOG 16b, Reglement §6.2.3 |
| OTHER_PARENT | Vaterschafts-/Elternteil (10 AT) | ✓ | family | – | – | – | EOG 16i |
| ADOPTION | Adoptionsurlaub (10 AT) | ✓ | family | – | – | – | EOG 16t |
| CARE_RELATIVE | Pflege Angehörige (3/Ereignis, 10/J) | ✓ | family | 4 | 4 | 4 | OR 329h |
| CARE_CHILD_LONG | Betreuung krankes Kind (98 AT/18 Mt) | ✓ | family | – | – | – | EOG 16n |
| COMP_TIME | Kompensation Überstunden/Überzeit | ✓ | policy | – | – | – | OR 321c, Reglement §2 |
| UNPAID_LEAVE | Unbezahlter Urlaub | ✗ | policy | – | – | – | vertraglich |
| BEREAVEMENT | Trauerfall | ✓ | policy | – | – | – | Firmen-Policy |
| WEDDING | Eigene Hochzeit/Partnerschaft | ✓ | policy | – | – | – | OR 329 Abs. 3 |
| MOVE | Umzug | ✓ | policy | – | – | – | Firmen-Policy |
| OFFICIAL_DUTY | Amtliche Vorladung/öffentliches Amt | ✓ | civic | – | – | – | OR 324a analog |
| EDUCATION_PAID | Weiterbildung (bezahlt) | ✓ | policy | – | – | – | Firmen-Policy |
| EXTRA_BIRTHDAY_SELF | Extra: Geburtstag MA (1 T/J) | ✓ | extra | – | – | – | Reglement §2 Extra-Guthaben |
| EXTRA_BIRTHDAY_CLOSE | Extra: Geburtstag Angehörige (1 T/J) | ✓ | extra | – | – | – | Reglement §2 |
| EXTRA_JOKER | Extra: Jokertag (Me Time) (1 T/J) | ✓ | extra | – | – | – | Reglement §2 |
| EXTRA_ZEG | Extra: ZEG-Zielerreichung (1 T/Halbjahr bei ≥100%) | ✓ | extra | – | – | – | Reglement §2 |
| EXTRA_GL | Extra: GL-Ermessen (bis 3 T) | ✓ | extra | – | – | – | Reglement §2 |
| SABBATICAL | Sabbatical | ✗ | policy | – | – | – | Firmen-Policy |

### 4.2 `dim_time_category`

Zeit-Kategorien (Billable / ZEG-relevant).

```sql
CREATE TABLE dim_time_category (
    code                VARCHAR(40) PRIMARY KEY,
    label_de            VARCHAR(120) NOT NULL,
    billable_default    BOOLEAN NOT NULL DEFAULT FALSE,
    project_required    BOOLEAN NOT NULL DEFAULT FALSE,
    counts_as_worktime  BOOLEAN NOT NULL DEFAULT TRUE,
    is_break            BOOLEAN NOT NULL DEFAULT FALSE,
    zeg_relevant        BOOLEAN NOT NULL DEFAULT FALSE, -- für Commission-ZEG-Staffel
    sort_order          SMALLINT NOT NULL DEFAULT 100,
    active              BOOLEAN NOT NULL DEFAULT TRUE
);
```

**Seeds:**

| code | label | billable | project_req | worktime | zeg | sort |
|------|-------|----------|-------------|----------|-----|------|
| PROD_BILL | Produktiv – verrechenbar | ✓ | ✓ | ✓ | ✓ | 10 |
| PROD_NONBILL | Produktiv – nicht verrechenbar | ✗ | ✓ | ✓ | ✓ | 20 |
| CLIENT_MEETING | Kunden-Termin | ✓ | ✓ | ✓ | ✓ | 30 |
| CANDIDATE_MEETING | Kandidaten-Interview | ✗ | ✓ | ✓ | ✓ | 40 |
| RESEARCH | Research / Sourcing / Mapping | ✗ | ✓ | ✓ | ✓ | 50 |
| BD_SALES | Business Development | ✗ | ✓ | ✓ | ✗ | 60 |
| TEAM_DEV | Team-/Persönlichkeitsentwicklung | ✗ | ✗ | ✓ | ✗ | 70 |
| ADMIN | Administration | ✗ | ✗ | ✓ | ✗ | 80 |
| INTERNAL_MEETING | Internes Meeting / Jour fixe | ✗ | ✗ | ✓ | ✗ | 90 |
| TRAINING | Training / Weiterbildung | ✗ | ✗ | ✓ | ✗ | 100 |
| TRAVEL_WORK | Reisezeit (geschäftlich) | ✗ | ✓ | ✓ | ✗ | 110 |
| BREAK | Pause | ✗ | ✗ | ✗ | ✗ | 999 |

### 4.3 `dim_work_time_model`

```sql
CREATE TABLE dim_work_time_model (
    code                    VARCHAR(40) PRIMARY KEY,
    label_de                VARCHAR(120) NOT NULL,
    simplified_recording    BOOLEAN NOT NULL DEFAULT FALSE,
    subject_to_arg_worktime BOOLEAN NOT NULL DEFAULT TRUE,
    requires_core_time      BOOLEAN NOT NULL DEFAULT FALSE,
    requires_scanner        BOOLEAN NOT NULL DEFAULT TRUE,
    legal_ref               VARCHAR(200) NULL,
    active                  BOOLEAN NOT NULL DEFAULT TRUE
);
```

**Seeds:**

| code | label | simpl | arg | core | scanner | legal |
|------|-------|-------|-----|------|---------|-------|
| FLEX_CORE | Gleitzeit mit Kernzeit (Default) | ✗ | ✓ | ✓ | ✓ | ArG 9 |
| FIXED | Fix-Zeit | ✗ | ✓ | ✗ | ✓ | ArG 9 |
| PARTTIME | Teilzeit % | ✗ | ✓ | ✓ | ✓ | ArG/OR |
| SIMPLIFIED_73B | Vereinfachte Erfassung 73b | ✓ | ✓ | ✗ | ✗ | ArGV 1 Art. 73b |
| EXEMPT_EXEC | Höhere leitende Tätigkeit | ✓ | ✗ | ✗ | ✗ | Art. 3 lit. d ArG · enge Prüfung |

### 4.4 `dim_salary_continuation_scale`

Lohnfortzahlungs-Skalen-Lookup (Reglement: Zürcher Skala).

```sql
CREATE TABLE dim_salary_continuation_scale (
    scale_code      salary_scale_code NOT NULL,
    dienstjahr_from SMALLINT NOT NULL CHECK (dienstjahr_from >= 1),
    dienstjahr_to   SMALLINT NULL,
    duration_weeks  NUMERIC(5,2) NOT NULL,
    active          BOOLEAN NOT NULL DEFAULT TRUE,
    PRIMARY KEY (scale_code, dienstjahr_from)
);
```

**Seeds Zürcher Skala** (Default lt. Reglement Generalis Provisio §6.2.1):

| scale | DJ_from | DJ_to | weeks |
|-------|---------|-------|-------|
| ZURICH | 1 | 1 | 3 |
| ZURICH | 2 | 2 | 8 |
| ZURICH | 3 | 3 | 9 |
| ZURICH | 4 | 4 | 10 |
| ZURICH | 5 | 9 | 11 |
| ZURICH | 10 | 14 | 16 |
| ZURICH | 15 | 19 | 21 |
| ZURICH | 20 | 24 | 26 |
| ZURICH | 25 | NULL | 31 |

**Seeds Berner Skala** (Alternative):

| BERN | 1 | 1 | 3 |
| BERN | 2 | 2 | 4.33 | (1 Monat = 4.33 Wochen)
| BERN | 3 | 4 | 8.67 | (2 Mt)
| BERN | 5 | 9 | 13 | (3 Mt)
| BERN | 10 | 14 | 17.33 | (4 Mt)
| BERN | 15 | 19 | 21.67 | (5 Mt)
| BERN | 20 | 24 | 26 | (6 Mt)
| BERN | 25 | NULL | 30.33 | (+1 Mt je 5 DJ)

---

## 5. Fact Tables

### 5.1 `firm_settings` (globale Konfig)

```sql
CREATE TABLE firm_settings (
    key             VARCHAR(80) PRIMARY KEY,
    value_text      TEXT NULL,
    value_numeric   NUMERIC(10,4) NULL,
    value_json      JSONB NULL,
    description     TEXT NULL,
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by      UUID NOT NULL REFERENCES dim_user(id)
);
```

**Seeds:**

| key | value | description |
|-----|-------|-------------|
| max_daily_hours | 10.0 | Daily-Cap: Zeit >10h wird nicht weitergezählt (Firmenpolicy, Risk-F2) |
| normal_weekly_hours | 45.0 | Normalarbeitszeit laut Tempus Passio §2 |
| team_dev_weekly_hours | 2.5 | Team-/Persönlichkeitsentwicklung (aggregierbar) |
| default_break_threshold_5h | 15 | Pause ab 5h in min |
| default_break_threshold_7h | 30 | Pause ab 7h in min |
| default_break_threshold_9h | 60 | Pause ab 9h in min |
| vacation_default_days | 25 | Reglement Tempus Passio §2 |
| vacation_carryover_deadline_rule | "14d_after_easter" | Reglement |
| doctor_cert_1dj | 1 | Arztzeugnis 1. Dienstjahr ab Tag |
| doctor_cert_2dj | 2 | 2. Dienstjahr ab Tag |
| doctor_cert_3dj_plus | 3 | 3.+ Dienstjahr ab Tag |
| salary_continuation_scale_default | "ZURICH" | Reglement Generalis Provisio §6.2.1 |
| salary_continuation_waiting_period_months | 3 | Nach 3 Mt Dienstzeit (Reglement §6.2.1) |
| monthly_payroll_cutoff_day | 25 | Export-Termin für Treuhand |
| extra_leave_birthday_days | 1 | Geburtstag MA (Reglement §2) |
| extra_leave_birthday_close_days | 1 | Geburtstag nahestehende Person |
| extra_leave_joker_days | 1 | Jokertag Me Time |
| extra_leave_zeg_days_per_halfyear | 1 | ZEG-Zielerreichung ≥100% |
| extra_leave_gl_max_days | 3 | GL-Ermessen Maximum |
| jahres_ueberzeit_cap | 170 | ArG Art. 12 · Büropersonal bei 45h-Regime |

### 5.2 `fact_workday_target`

Arbeitszeit-Vertrag pro MA pro Jahr.

```sql
CREATE TABLE fact_workday_target (
    id                              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id                         UUID NOT NULL REFERENCES dim_user(id),
    employment_contract_id          UUID NULL REFERENCES fact_employment_contracts(id),  -- HR-Modul: Pensum/Stunden-Source-of-Truth
    year                            SMALLINT NOT NULL,
    work_time_model_code            VARCHAR(40) NOT NULL REFERENCES dim_work_time_model(code),
    target_hours_per_week           NUMERIC(5,2) NOT NULL,   -- muss mit HR fact_employment_contracts konsistent sein (via Worker)
    variant_percent                 NUMERIC(5,2) NOT NULL DEFAULT 100.00,
    weekday_minutes_jsonb           JSONB NOT NULL,  -- {"mon":510,"tue":510,...,"sun":0}
    default_break_min               SMALLINT NOT NULL DEFAULT 30,
    core_hours_mo_fr_am_from        TIME NULL,       -- Mo-Fr Vormittag Start
    core_hours_mo_fr_am_to          TIME NULL,       -- Mo-Fr Vormittag Ende
    core_hours_mo_do_pm_from        TIME NULL,       -- Mo-Do Nachmittag Start
    core_hours_mo_do_pm_to          TIME NULL,       -- Mo-Do Nachmittag Ende
    core_hours_fr_pm_from           TIME NULL,       -- Fr Nachmittag Start
    core_hours_fr_pm_to             TIME NULL,       -- Fr Nachmittag Ende
    vacation_days_entitlement       NUMERIC(4,1) NOT NULL DEFAULT 25.0,
    salary_continuation_scale       salary_scale_code NOT NULL DEFAULT 'ZURICH',
    simplified_agreement_signed_at  TIMESTAMPTZ NULL,
    simplified_agreement_file       VARCHAR(500) NULL,
    exempt_exec_decision_at         TIMESTAMPTZ NULL,
    exempt_exec_decision_file       VARCHAR(500) NULL,
    contract_start                  DATE NOT NULL,
    contract_end                    DATE NULL,
    created_at                      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at                      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    audit_trail_jsonb               JSONB NOT NULL DEFAULT '[]'::jsonb,
    CONSTRAINT chk_variant_range CHECK (variant_percent > 0 AND variant_percent <= 100),
    CONSTRAINT chk_target_hours CHECK (target_hours_per_week > 0 AND target_hours_per_week <= 50),
    CONSTRAINT chk_break_min CHECK (default_break_min BETWEEN 0 AND 240),
    CONSTRAINT chk_contract_period CHECK (contract_end IS NULL OR contract_end > contract_start),
    CONSTRAINT chk_simplified_signed CHECK (
        work_time_model_code <> 'SIMPLIFIED_73B'
        OR simplified_agreement_signed_at IS NOT NULL
    ),
    CONSTRAINT chk_exempt_signed CHECK (
        work_time_model_code <> 'EXEMPT_EXEC'
        OR exempt_exec_decision_at IS NOT NULL
    ),
    CONSTRAINT uq_user_year_contract UNIQUE (user_id, year, contract_start)
);
CREATE INDEX idx_workday_target_user_year ON fact_workday_target(user_id, year);
CREATE UNIQUE INDEX uq_workday_target_active ON fact_workday_target(user_id, year)
    WHERE contract_end IS NULL;
```

**weekday_minutes_jsonb Beispiel (Vollzeit FLEX_CORE, 45h = 2700min/Wo):**

```json
{
  "mon": 540, "tue": 540, "wed": 540, "thu": 540,
  "fri": 540, "sat": 0, "sun": 0
}
```

### 5.3 `fact_holiday_cantonal`

Feiertags-Kalender.

```sql
CREATE TABLE fact_holiday_cantonal (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    canton_code     CHAR(2) NOT NULL DEFAULT 'ZH',
    date            DATE NOT NULL,
    label_de        VARCHAR(120) NOT NULL,
    half_day        BOOLEAN NOT NULL DEFAULT FALSE,
    is_statutory    BOOLEAN NOT NULL DEFAULT TRUE,
    credit_factor   NUMERIC(4,3) NOT NULL DEFAULT 1.000,  -- 1.0=ganz, 0.5=halb
    source_ref      VARCHAR(200) NULL,
    active          BOOLEAN NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_credit_factor CHECK (credit_factor > 0 AND credit_factor <= 1),
    CONSTRAINT uq_holiday_canton_date_label UNIQUE (canton_code, date, label_de)
);
CREATE INDEX idx_holiday_canton_year ON fact_holiday_cantonal(canton_code, date);
```

**Seeds 2026 (9 gesetzliche ZH-FT + Reglement-Berchtoldstag + 3 Sperrfristen-Halbtage):**

| date | label | statutory | credit | note |
|------|-------|-----------|--------|------|
| 2026-01-01 | Neujahr | ✓ | 1.000 | ArG 20a |
| 2026-01-02 | Berchtoldstag | ✗ | 1.000 | Tempus Passio (als bezahlt gewährt) |
| 2026-04-03 | Karfreitag | ✓ | 1.000 | |
| 2026-04-06 | Ostermontag | ✓ | 1.000 | |
| 2026-05-01 | Tag der Arbeit | ✓ | 1.000 | ZH-Sonderregelung |
| 2026-05-14 | Auffahrt | ✓ | 1.000 | |
| 2026-05-25 | Pfingstmontag | ✓ | 1.000 | |
| 2026-08-01 | Bundesfeier | ✓ | 1.000 | fällt auf Sa |
| 2026-12-25 | Weihnachten | ✓ | 1.000 | |
| 2026-12-26 | Stephanstag | ✓ | 1.000 | fällt auf Sa |
| 2026-04-20 | Sechseläuten (Halbtag PM) | ✗ | 0.500 | Reglement-Sperrfrist |
| 2026-09-14 | Knabenschiessen (Halbtag PM) | ✗ | 0.500 | Reglement-Sperrfrist |

### 5.4 `fact_bridge_day`

Brücken-Tage (F11: manuell durch GF pro Jahr).

```sql
CREATE TABLE fact_bridge_day (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    date                DATE NOT NULL,
    year                SMALLINT GENERATED ALWAYS AS (EXTRACT(YEAR FROM date)::SMALLINT) STORED,
    label_de            VARCHAR(120) NOT NULL,
    credit_factor       NUMERIC(4,3) NOT NULL DEFAULT 1.000,  -- 1.0 ganzer Tag, 0.5 Halbtag
    decided_by          UUID NOT NULL REFERENCES dim_user(id),
    decided_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    reason              TEXT NULL,
    active              BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT uq_bridge_date UNIQUE (date),
    CONSTRAINT chk_bridge_credit CHECK (credit_factor > 0 AND credit_factor <= 1)
);
CREATE INDEX idx_bridge_year ON fact_bridge_day(year);
```

### 5.5 `fact_time_scan_event` (Scanner-Roh)

**Scanner-Events** (Fingerabdruckscanner). Raw, unverarbeitet.

**DSG-Kritisch:** biometrische Daten. Template NIE hier, nur abgeleitete scan-events.

```sql
CREATE TABLE fact_time_scan_event (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES dim_user(id),
    scan_at         TIMESTAMPTZ NOT NULL,
    scan_type       scan_event_type NOT NULL,
    device_id       VARCHAR(80) NULL,       -- Scanner-Hardware-Kennung
    device_location VARCHAR(120) NULL,      -- 'Eingang' / 'Büro 2' etc.
    raw_payload_jsonb JSONB NULL,           -- Scanner-API-Rohdaten (ohne Biometrie)
    override_by     UUID NULL REFERENCES dim_user(id),  -- bei scan_type='override'
    override_reason TEXT NULL,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_override_fields CHECK (
        (scan_type = 'override' AND override_by IS NOT NULL AND override_reason IS NOT NULL)
        OR scan_type <> 'override'
    )
);
CREATE INDEX idx_scan_user_date ON fact_time_scan_event(user_id, scan_at);
CREATE INDEX idx_scan_type ON fact_time_scan_event(scan_type);
```

### 5.6 `fact_time_entry` (aggregiert)

Tages-Eintrag · aggregiert aus Scanner-Events oder manuell erstellt.

```sql
CREATE TABLE fact_time_entry (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id             UUID NOT NULL REFERENCES dim_user(id),
    entry_date          DATE NOT NULL,
    start_time          TIME NULL,              -- NULL bei SIMPLIFIED_73B
    end_time            TIME NULL,              -- NULL bei SIMPLIFIED_73B
    break_min           SMALLINT NOT NULL DEFAULT 0,
    raw_duration_min    INTEGER NOT NULL,       -- Scanner-Roh (brutto)
    counted_duration_min INTEGER NOT NULL,      -- gecapped @ max_daily_hours (Firmenpolicy)
    uncounted_duration_min INTEGER GENERATED ALWAYS AS (raw_duration_min - counted_duration_min) STORED,
    project_id          UUID NULL REFERENCES fact_process_core(id),
    category_code       VARCHAR(40) NOT NULL REFERENCES dim_time_category(code),
    billable            BOOLEAN NOT NULL DEFAULT FALSE,
    overtime_kind       overtime_kind NOT NULL DEFAULT 'regular',
    entry_state         time_entry_state NOT NULL DEFAULT 'draft',
    source              time_entry_source NOT NULL DEFAULT 'scanner',
    comment             TEXT NULL,
    submitted_at        TIMESTAMPTZ NULL,
    approved_by         UUID NULL REFERENCES dim_user(id),
    approved_at         TIMESTAMPTZ NULL,
    locked_at           TIMESTAMPTZ NULL,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by          UUID NOT NULL REFERENCES dim_user(id),
    audit_trail_jsonb   JSONB NOT NULL DEFAULT '[]'::jsonb,
    CONSTRAINT chk_raw_positive CHECK (raw_duration_min >= 0),
    CONSTRAINT chk_counted_range CHECK (counted_duration_min >= 0 AND counted_duration_min <= 600), -- 10h cap
    CONSTRAINT chk_counted_leq_raw CHECK (counted_duration_min <= raw_duration_min),
    CONSTRAINT chk_break_nonneg CHECK (break_min >= 0 AND break_min <= 240),
    CONSTRAINT chk_time_consistency CHECK (
        (start_time IS NULL AND end_time IS NULL)
        OR (start_time IS NOT NULL AND end_time IS NOT NULL AND end_time > start_time)
    ),
    CONSTRAINT chk_approval_consistency CHECK (
        (entry_state IN ('approved','locked') AND approved_by IS NOT NULL AND approved_at IS NOT NULL)
        OR entry_state NOT IN ('approved','locked')
    ),
    CONSTRAINT chk_lock_consistency CHECK (
        (entry_state = 'locked' AND locked_at IS NOT NULL) OR entry_state <> 'locked'
    )
);
CREATE INDEX idx_time_entry_user_date ON fact_time_entry(user_id, entry_date);
CREATE INDEX idx_time_entry_state ON fact_time_entry(entry_state) WHERE entry_state IN ('draft','submitted');
CREATE INDEX idx_time_entry_project ON fact_time_entry(project_id) WHERE project_id IS NOT NULL;
CREATE INDEX idx_time_entry_date_range ON fact_time_entry(entry_date, user_id);
CREATE INDEX idx_time_entry_billable ON fact_time_entry(billable) WHERE billable = TRUE;
CREATE INDEX idx_time_entry_audit_gin ON fact_time_entry USING gin (audit_trail_jsonb);

-- Overlap-Prevention: keine 2 Einträge gleichzeitig für gleichen User
ALTER TABLE fact_time_entry ADD CONSTRAINT excl_time_entry_overlap
    EXCLUDE USING GIST (
        user_id WITH =,
        tsrange(
            (entry_date::timestamp + start_time),
            (entry_date::timestamp + end_time),
            '[)'
        ) WITH &&
    ) WHERE (entry_state <> 'rejected' AND start_time IS NOT NULL);
```

### 5.7 `fact_time_correction`

Korrektur-Anträge nach Approval/Lock (F13: nur Admin-Rolle).

```sql
CREATE TABLE fact_time_correction (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    original_entry_id   UUID NOT NULL REFERENCES fact_time_entry(id),
    requested_by        UUID NOT NULL REFERENCES dim_user(id),
    requested_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    reason              TEXT NOT NULL,
    old_values_jsonb    JSONB NOT NULL,
    new_values_jsonb    JSONB NOT NULL,
    diff_jsonb          JSONB GENERATED ALWAYS AS
        (jsonb_strip_nulls(new_values_jsonb - old_values_jsonb)) STORED,
    tl_approved_by      UUID NULL REFERENCES dim_user(id),
    tl_approved_at      TIMESTAMPTZ NULL,
    admin_approved_by   UUID NULL REFERENCES dim_user(id),     -- erforderlich wenn locked
    admin_approved_at   TIMESTAMPTZ NULL,
    applied_at          TIMESTAMPTZ NULL,
    status              correction_state NOT NULL DEFAULT 'requested',
    audit_jsonb         JSONB NOT NULL DEFAULT '{}'::jsonb,
    CONSTRAINT chk_correction_flow CHECK (
        status NOT IN ('applied') OR admin_approved_by IS NOT NULL OR tl_approved_by IS NOT NULL
    )
);
CREATE INDEX idx_correction_original ON fact_time_correction(original_entry_id);
CREATE INDEX idx_correction_status ON fact_time_correction(status);
```

### 5.8 `fact_time_period_close`

Monats-Lock-Status (F12: Hybrid · Wochen-Check + Monats-Lock).

```sql
CREATE TABLE fact_time_period_close (
    id                          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id                     UUID NOT NULL REFERENCES dim_user(id),
    period_month                DATE NOT NULL,              -- erster Tag des Monats
    submitted_at                TIMESTAMPTZ NULL,
    submitted_by                UUID NULL REFERENCES dim_user(id),
    tl_weekly_checks_done       JSONB NULL,                 -- {"2026-W15": "2026-04-10T..."}
    tl_approved_at              TIMESTAMPTZ NULL,
    tl_approved_by              UUID NULL REFERENCES dim_user(id),
    gf_approved_at              TIMESTAMPTZ NULL,
    gf_approved_by              UUID NULL REFERENCES dim_user(id),
    locked_at                   TIMESTAMPTZ NULL,
    locked_by                   UUID NULL REFERENCES dim_user(id),
    exported_at                 TIMESTAMPTZ NULL,
    exported_by                 UUID NULL REFERENCES dim_user(id),
    export_batch_ref            VARCHAR(120) NULL,
    export_needs_redo           BOOLEAN NOT NULL DEFAULT FALSE,  -- bei Korrektur nach Export
    status                      period_close_state NOT NULL DEFAULT 'open',
    audit_trail_jsonb           JSONB NOT NULL DEFAULT '[]'::jsonb,
    CONSTRAINT chk_period_first_day CHECK (date_trunc('month', period_month)::date = period_month),
    CONSTRAINT uq_period_close_user_month UNIQUE (user_id, period_month)
);
CREATE INDEX idx_period_close_status ON fact_time_period_close(status);
CREATE INDEX idx_period_close_month ON fact_time_period_close(period_month);
```

### 5.9 `fact_absence`

Abwesenheiten (Ferien, Krank, Unfall, etc.).

```sql
CREATE TABLE fact_absence (
    id                          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id                     UUID NOT NULL REFERENCES dim_user(id),
    absence_type_code           VARCHAR(40) NOT NULL REFERENCES dim_absence_type(code),
    start_date                  DATE NOT NULL,
    end_date                    DATE NOT NULL,
    half_day_start              BOOLEAN NOT NULL DEFAULT FALSE,
    half_day_end                BOOLEAN NOT NULL DEFAULT FALSE,
    working_days_deducted       NUMERIC(5,2) NOT NULL,      -- berechnet: Periode minus WE/FT/Teilzeit
    paid                        BOOLEAN NOT NULL,
    approved_by                 UUID NULL REFERENCES dim_user(id),
    approved_at                 TIMESTAMPTZ NULL,
    doctor_cert_file            VARCHAR(500) NULL,
    doctor_cert_uploaded_at     TIMESTAMPTZ NULL,
    doctor_cert_reminder_sent_at TIMESTAMPTZ NULL,
    status                      absence_state NOT NULL DEFAULT 'draft',
    reason                      TEXT NULL,
    salary_continuation_phase   salary_continuation_phase NULL,  -- bei SICK: 100/partial/unpaid
    created_at                  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at                  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    audit_trail_jsonb           JSONB NOT NULL DEFAULT '[]'::jsonb,
    CONSTRAINT chk_absence_period CHECK (end_date >= start_date),
    CONSTRAINT chk_days_positive CHECK (working_days_deducted >= 0),
    CONSTRAINT chk_approval CHECK (
        (status IN ('approved','active','completed')
         AND approved_by IS NOT NULL AND approved_at IS NOT NULL)
        OR status NOT IN ('approved','active','completed')
    ),
    CONSTRAINT chk_cert_consistency CHECK (
        (doctor_cert_file IS NULL AND doctor_cert_uploaded_at IS NULL)
        OR (doctor_cert_file IS NOT NULL AND doctor_cert_uploaded_at IS NOT NULL)
    )
);
CREATE INDEX idx_absence_user_period ON fact_absence(user_id, start_date, end_date);
CREATE INDEX idx_absence_type ON fact_absence(absence_type_code);
CREATE INDEX idx_absence_open ON fact_absence(status) WHERE status IN ('draft','submitted');

-- Overlap-Prevention für approved/active/completed Absences
ALTER TABLE fact_absence ADD CONSTRAINT excl_absence_overlap
    EXCLUDE USING GIST (
        user_id WITH =,
        daterange(start_date, end_date, '[]') WITH &&
    ) WHERE (status IN ('approved','active','completed'));
```

### 5.10 `fact_vacation_balance`

Ferien-Konto pro Jahr (inkl. Reglement-Übertrag 14 Tage nach Ostern).

```sql
CREATE TABLE fact_vacation_balance (
    user_id                 UUID NOT NULL REFERENCES dim_user(id),
    year                    SMALLINT NOT NULL,
    entitlement_days        NUMERIC(5,2) NOT NULL,          -- 25 Default lt. Reglement
    carried_over            NUMERIC(5,2) NOT NULL DEFAULT 0,
    taken                   NUMERIC(5,2) NOT NULL DEFAULT 0,
    planned                 NUMERIC(5,2) NOT NULL DEFAULT 0,
    remaining               NUMERIC(5,2) GENERATED ALWAYS AS
        (entitlement_days + carried_over - taken) STORED,
    carryover_deadline      DATE NULL,                      -- 14d nach Ostern Folgejahr
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (user_id, year),
    CONSTRAINT chk_balance_nonneg CHECK (
        entitlement_days >= 0 AND taken >= 0 AND carried_over >= 0 AND planned >= 0
    )
);
```

### 5.11 `fact_overtime_balance`

3-Konten-Saldo: Überstunden (OR) vs. Überzeit (ArG).

```sql
CREATE TABLE fact_overtime_balance (
    user_id             UUID NOT NULL REFERENCES dim_user(id),
    period              VARCHAR(7) NOT NULL,        -- YYYY-MM oder YYYY für Jahressaldo
    overtime_kind       overtime_kind NOT NULL,     -- 'ueberstunden_or' | 'ueberzeit_arg'
    accumulated_min     INTEGER NOT NULL DEFAULT 0,
    compensated_min     INTEGER NOT NULL DEFAULT 0, -- Zeitausgleich
    paid_out_min        INTEGER NOT NULL DEFAULT 0, -- Auszahlung (bei Arkadium = 0, nur Zeitausgleich)
    remaining_min       INTEGER GENERATED ALWAYS AS
        (accumulated_min - compensated_min - paid_out_min) STORED,
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (user_id, period, overtime_kind),
    CONSTRAINT chk_ot_kind CHECK (overtime_kind IN ('ueberstunden_or','ueberzeit_arg'))
);
```

### 5.12 `fact_extra_leave_entitlement`

Extra-Guthaben-Ansprüche (Reglement Tempus Passio §2).

```sql
CREATE TABLE fact_extra_leave_entitlement (
    id                          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id                     UUID NOT NULL REFERENCES dim_user(id),
    year                        SMALLINT NOT NULL,
    absence_type_code           VARCHAR(40) NOT NULL REFERENCES dim_absence_type(code),
    days_entitled               NUMERIC(4,2) NOT NULL,
    days_taken                  NUMERIC(4,2) NOT NULL DEFAULT 0,
    reason_note                 TEXT NULL,                      -- bei EXTRA_GL: GL-Begründung
    unlocked_by                 UUID NULL REFERENCES dim_user(id),  -- bei EXTRA_ZEG / EXTRA_GL: wer hat freigegeben
    unlocked_at                 TIMESTAMPTZ NULL,
    expires_at                  DATE NULL,                      -- verfällt bei Kündigung für a/b/c
    lapsed                      BOOLEAN NOT NULL DEFAULT FALSE,
    created_at                  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_extra_leave_per_year UNIQUE (user_id, year, absence_type_code)
);
CREATE INDEX idx_extra_leave_user_year ON fact_extra_leave_entitlement(user_id, year);
```

### 5.13 `fact_salary_continuation_claim`

Lohnfortzahlungs-Anspruch bei Krankheit (Zürcher Skala).

```sql
CREATE TABLE fact_salary_continuation_claim (
    id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id                 UUID NOT NULL REFERENCES dim_user(id),
    dienstjahr              SMALLINT NOT NULL,
    scale_code              salary_scale_code NOT NULL,
    entitlement_weeks       NUMERIC(5,2) NOT NULL,      -- aus dim_salary_continuation_scale
    entitlement_days        NUMERIC(5,2) NOT NULL,      -- berechnet
    consumed_days_100       NUMERIC(5,2) NOT NULL DEFAULT 0,
    consumed_days_80_ktg    NUMERIC(5,2) NOT NULL DEFAULT 0,
    waiting_period_served   BOOLEAN NOT NULL DEFAULT FALSE,  -- 3 Mt Karenz lt. Reglement §6.2.1
    reset_date              DATE NOT NULL,              -- Dienstjahres-Beginn
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_salary_claim_user_dj UNIQUE (user_id, dienstjahr)
);
```

### 5.14 `fact_simplified_agreement`

Art. 73b ArGV 1 kollektive / individuelle Vereinbarung (für SIMPLIFIED_73B MA).

```sql
CREATE TABLE fact_simplified_agreement (
    id                          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    agreement_type              VARCHAR(20) NOT NULL CHECK (agreement_type IN ('collective','individual')),
    signed_by_user_id           UUID NULL REFERENCES dim_user(id),   -- bei individual
    signed_count_majority       SMALLINT NULL,                       -- bei collective
    signed_at                   TIMESTAMPTZ NOT NULL,
    valid_from                  DATE NOT NULL,
    valid_to                    DATE NULL,
    pdf_file                    VARCHAR(500) NOT NULL,
    annual_review_at            TIMESTAMPTZ NULL,                    -- jährliches Endgespräch
    status                      VARCHAR(20) NOT NULL DEFAULT 'active' CHECK (status IN ('active','revoked','expired')),
    created_at                  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_signed_fields CHECK (
        (agreement_type = 'individual' AND signed_by_user_id IS NOT NULL)
        OR (agreement_type = 'collective' AND signed_count_majority IS NOT NULL)
    )
);
```

### 5.15 `fact_scanner_access_audit`

DSG-Audit: wer sieht Scanner-Daten ein (biometrie-sensitiv).

```sql
CREATE TABLE fact_scanner_access_audit (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    accessed_by     UUID NOT NULL REFERENCES dim_user(id),
    access_type     VARCHAR(40) NOT NULL CHECK (access_type IN ('read_scans','read_entries','export','correction')),
    target_user_id  UUID NULL REFERENCES dim_user(id),    -- NULL bei Admin-Bulk-Export
    period_month    DATE NULL,
    reason          TEXT NULL,
    ip_address      INET NULL,
    accessed_at     TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_scanner_audit_accessed_by ON fact_scanner_access_audit(accessed_by, accessed_at);
CREATE INDEX idx_scanner_audit_target ON fact_scanner_access_audit(target_user_id);
```

---

## 6. Views (für Commission-Integration + Dashboard)

### 6.1 `v_daily_saldo`

```sql
CREATE VIEW v_daily_saldo AS
SELECT
    te.user_id,
    te.entry_date,
    SUM(te.counted_duration_min) AS worked_min,
    SUM(te.uncounted_duration_min) AS uncounted_min,
    SUM(te.break_min) AS break_min,
    (SELECT wt.weekday_minutes_jsonb->lower(to_char(te.entry_date, 'dy'))
       FROM fact_workday_target wt
      WHERE wt.user_id = te.user_id
        AND wt.contract_start <= te.entry_date
        AND (wt.contract_end IS NULL OR wt.contract_end >= te.entry_date)
      LIMIT 1)::int AS target_min
FROM fact_time_entry te
WHERE te.entry_state IN ('approved','locked')
GROUP BY te.user_id, te.entry_date;
```

### 6.2 `v_monthly_saldo`

```sql
CREATE VIEW v_monthly_saldo AS
SELECT
    user_id,
    date_trunc('month', entry_date)::date AS period_month,
    SUM(worked_min) AS total_worked_min,
    SUM(uncounted_min) AS total_uncounted_min,
    SUM(target_min) AS total_target_min,
    SUM(worked_min) - SUM(target_min) AS saldo_min
FROM v_daily_saldo
GROUP BY user_id, date_trunc('month', entry_date);
```

### 6.3 `v_time_per_mandate` (Commission-ZEG-Feed)

```sql
CREATE VIEW v_time_per_mandate AS
SELECT
    te.project_id,
    te.user_id,
    date_trunc('month', te.entry_date)::date AS period_month,
    SUM(te.counted_duration_min) FILTER (WHERE tc.zeg_relevant = TRUE) AS zeg_relevant_min,
    SUM(te.counted_duration_min) FILTER (WHERE tc.billable_default = TRUE) AS billable_min,
    SUM(te.counted_duration_min) AS total_min
FROM fact_time_entry te
JOIN dim_time_category tc ON tc.code = te.category_code
WHERE te.entry_state IN ('approved','locked')
  AND te.project_id IS NOT NULL
GROUP BY te.project_id, te.user_id, date_trunc('month', te.entry_date);
```

### 6.4 `v_weekly_approval_queue` (für TL-Dashboard F12 Hybrid)

```sql
CREATE VIEW v_weekly_approval_queue AS
SELECT
    te.user_id,
    u.label_de AS user_name,
    date_trunc('week', te.entry_date)::date AS week_start,
    COUNT(*) AS entry_count,
    SUM(te.counted_duration_min) AS total_worked_min,
    SUM(te.uncounted_duration_min) AS total_uncounted_min,
    COUNT(*) FILTER (WHERE te.entry_state = 'draft') AS draft_count,
    COUNT(*) FILTER (WHERE te.entry_state = 'submitted') AS submitted_count
FROM fact_time_entry te
JOIN dim_user u ON u.id = te.user_id
WHERE te.entry_state IN ('draft','submitted')
GROUP BY te.user_id, u.label_de, date_trunc('week', te.entry_date)
HAVING COUNT(*) FILTER (WHERE te.entry_state = 'submitted') > 0
    OR MAX(te.created_at) < NOW() - INTERVAL '5 days';
```

---

## 7. Retention + DSG-Löschung

**Retention-Regeln:**

| Entität | Retention | Grund |
|---------|-----------|-------|
| `fact_time_entry` | 5 J post Vertrags-Ende | ArGV 1 Art. 73 Abs. 2 |
| `fact_absence` (medical) | 5 J post Vertrags-Ende | ArG 73 + revDSG Art. 5 (besondere PD → danach zwingend löschen) |
| `fact_time_scan_event` | 5 J | ArG 73 |
| `fact_scanner_access_audit` | 10 J | DSG-Nachweispflicht |
| `fact_time_correction` | 10 J | Audit-Trail für Gerichtsbeweis |
| `doctor_cert_file` | 5 J post Abwesenheit-Ende | revDSG Art. 5 Ziff. 2 |
| `audit_trail_jsonb` | append-only, 10 J | Beweislast-Mitigation |

**Löschjob (nightly):**

```sql
-- Beispiel: alte Krank-Zertifikate löschen (Datei + Link)
UPDATE fact_absence
SET doctor_cert_file = NULL,
    doctor_cert_uploaded_at = NULL,
    audit_trail_jsonb = audit_trail_jsonb || jsonb_build_object(
        'action', 'retention_cert_purge',
        'at', NOW()
    )
WHERE status IN ('completed')
  AND end_date < NOW() - INTERVAL '5 years'
  AND doctor_cert_file IS NOT NULL;
```

---

## 8. Integration-Hooks

### 8.1 Commission-Engine

**Event `time_entry.locked.v1`** publiziert bei `entry_state → locked` UND `project_id IS NOT NULL`:

```json
{
  "event_version": "1",
  "entry_id": "uuid",
  "user_id": "uuid",
  "project_id": "uuid",
  "category_code": "PROD_BILL",
  "counted_duration_min": 480,
  "billable": true,
  "zeg_relevant": true,
  "entry_date": "2026-04-19",
  "locked_at": "2026-05-05T10:00:00+02:00"
}
```

Commission-Engine berechnet aus `v_time_per_mandate` ZEG-Staffel je Mandat.

### 8.2 CRM

`fact_time_entry.project_id` ist **nullable FK** auf `fact_process_core(id)`. Projekt-Dropdown filtert nur `status='active'`.

### 8.3 Treuhand Kunz Export (Bexio-CSV + ELM 5.0)

**Bexio-CSV** (UTF-8-BOM, Semicolon, CRLF):

```csv
MA_Nr;AHV_Nr;Name;Vorname;Monat;Beschaeftigungsgrad;Soll_Std;Ist_Std;\
Ferien_Tage;Krank_Tage_bez;Krank_Tage_unbez;Unfall_BU;Unfall_NBU;\
Militaer;Mutterschaft;OtherParent;Ueberstunden_Saldo;Ueberzeit_Saldo;\
Ueberzeit_Kompensiert;Feiertage_Tage;Bruecken_Tage;Extra_Guthaben_Tage;Bemerkung
```

**ELM 5.0 XML** (vorbereitet, aktiviert Phase 2):
- Namespace `dom-ch-salarydeclaration-5`
- Aggregierte Lohnarten: Grundlohn-Periode, Ferien, Feiertag, Überzeit-Auszahlung (bei Arkadium = 0), EO (Mutterschaft/Vaterschaft/Militär), KTG

### 8.4 Scanner-Integration

Scanner-Device sendet Events via REST-API:

```
POST /api/zeit/scan
{
  "device_id": "SCANNER-01",
  "scan_at": "2026-04-19T08:47:23+02:00",
  "scan_type": "check_in",
  "user_id_hash": "sha256:..."  // Template-Hash, kein Roh-Fingerabdruck
}
```

Worker `scan-event-processor` aggregiert scan_events zu `fact_time_entry` (daily batch 02:00 UTC).

---

## 9. Seeds-Zusammenfassung

Phase-1-Go-Live benötigt folgende Seed-Daten:

| Tabelle | # Rows | Quelle |
|---------|--------|--------|
| `firm_settings` | 19 | Reglement + Peter-Decisions |
| `dim_absence_type` | 30 | Reglement §3.5/§6 + EOG + OR + Extra-Guthaben |
| `dim_time_category` | 12 | AI-Konsens + Arkadium-Spezifika |
| `dim_work_time_model` | 5 | Gesetz + Reglement |
| `dim_salary_continuation_scale` | 18 (9 ZH + 9 BE) | Gerichtspraxis |
| `fact_holiday_cantonal` | 12 (2026) | ZH + Reglement |
| `fact_bridge_day` | GF-manuell pro Jahr | F11-Decision |

---

## 10. Offen für Phase-2

- **ELM 5.0 XML-Generator** (Phase 2 · Swissdec-Integration, Deadline ELM 4.0 = 30.6.2026)
- **Bexio-API-Push** statt CSV (Phase 2)
- **Mobile-Browser-Optimierungen** (kein PWA, kein Native laut F14)
- **ZEG-Staffel-Logic** (konkrete Schwellen 80/60/… in Commission-Engine-Spec)
- **Scanner-Hardware-Auswahl** (separat evaluieren vor Go-Live)

---

## 11. Changelog

| Version | Datum | Änderung |
|---------|-------|----------|
| 0.1 | 2026-04-19 | Initial draft · 15 Tabellen · 9 Enums · 4 Views · Scanner-Integration · Extra-Guthaben · 3-Konten-Saldo · Zürcher Skala |
| 0.2 | 2026-04-20 | Deltas aus Mockup-Iteration · firm_settings + substitute_user_id · Policy-Anpassungen |

---

## 12. Deltas v0.1 → v0.2

### 12.1 Neue `firm_settings`-Keys

```sql
INSERT INTO firm_settings (key, value_text, description) VALUES
  ('overtime_compensation_policy', 'paid_with_salary',
   'Arkadium-Policy: OR-Überstunden + ArG-Überzeit mit Grundlohn abgegolten (Vertragsklausel). Kein Zeitausgleich, keine Auszahlung. Tracking nur für Compliance (ArG Art. 12 Jahres-Cap 170h). Alternative Values: time_off | pay_25pct | hybrid'),
  ('ferien_stellvertreter_required_from_days', '3',
   'Stellvertreter-Pflicht bei Ferien-Anträgen ab N Tagen (Reglement Tempus Passio §2 Policy)'),
  ('auto_reply_enabled', 'false',
   'Arkadium-Policy: keine Outlook-Auto-Reply bei Abwesenheit (MA bleiben erreichbar). Andere Tenants: true');
```

### 12.2 Neue Spalte auf `fact_absence`

```sql
ALTER TABLE fact_absence
  ADD COLUMN substitute_user_id UUID NULL REFERENCES dim_user(id);

COMMENT ON COLUMN fact_absence.substitute_user_id IS
  'Stellvertretung bei Ferien (Pflicht bei ≥ 3 Tagen · Reglement Tempus Passio §2). NULL bei Krank/Militär/Extra-Guthaben';

-- Constraint: bei VACATION-Typen ≥ 3 Tagen MUSS Stellvertreter gesetzt sein (Pflicht-Check im Worker, nicht DB-Constraint wegen Policy-Flexibilität)
```

### 12.3 Role-Code-Rename (Dokumentation)

Interne Rollen-Codes im System:

| v0.1 Code | v0.2 Code | Display-Label |
|-----------|-----------|---------------|
| `MA` | `MA` | Mitarbeiter |
| `TL` | `HEAD` | Head of |
| `GF` / `FOUNDER` | `ADMIN` | Admin |
| `BO` | `BO` | Backoffice |
| `ADMIN` | (merged with GF) | (siehe oben) |

**Impact:** `dim_user.role_code` VARCHAR(10) Enum aktualisiert. Migrations-Skript: `UPDATE dim_user SET role_code = 'HEAD' WHERE role_code = 'TL'; UPDATE dim_user SET role_code = 'ADMIN' WHERE role_code IN ('GF', 'FOUNDER');`

### 12.4 `dim_time_category` optionaler für Aggregator-Worker

`fact_time_entry.category_code` bleibt Pflichtfeld (NOT NULL Constraint unverändert), aber:
- Scanner-Aggregator-Worker füllt jetzt Default-Wert `PROD_NONBILL` (statt Kategorie vom MA zugeordnet zu erwarten)
- UI-Seite hat keine Kategorie-Zuordnung im Tages-Eintrag-Drawer mehr
- ZEG-Berechnung in Commission-Engine nutzt ausschliesslich `v_time_per_mandate` mit `zeg_relevant`-Flag auf Kategorie-Dimension (via Worker-Default)

**Migrations-Empfehlung:** Bestehende NULL-Werte (falls vorhanden aus Mockup-Phase) mit `PROD_NONBILL` füllen.

### 12.5 Wegfallende View

`v_weekly_approval_queue` bleibt im Schema erhalten, wird aber **nicht mehr aktiv** verwendet (Wochen-Check-Feature entfernt). Backend-Worker `week-check-reminder` wird deprecated.

### 12.6 Tenant-Policy-Variation

Schema explizit multi-tenant-fähig für spätere Vermarktung:

| Policy | Arkadium | Standard-KMU | Beratung (Time-based) |
|--------|----------|--------------|----------------------|
| `overtime_compensation_policy` | `paid_with_salary` | `time_off` | `hybrid` |
| `auto_reply_enabled` | `false` | `true` | `true` |
| `ferien_stellvertreter_required_from_days` | `3` | `5` | `1` |

### 12.7 Admin-UI-Scope reduziert (Tab-Level)

Zeit-Admin behält nur:
- Arbeitszeit-Modelle (FK auf `fact_workday_target`)
- Feiertage (FK auf `fact_holiday_cantonal`)
- 73b-Vereinbarungen (FK auf `fact_simplified_agreement`)
- Korrekturen-Queue (FK auf `fact_time_correction` WHERE status='requested')

**MA-Verträge** (Arbeitsvertrag, Reglement-Signaturen, Skala-Wahl) ausschliesslich HR-Modul (`fact_employment_contracts` · `fact_employment_attachments`).
