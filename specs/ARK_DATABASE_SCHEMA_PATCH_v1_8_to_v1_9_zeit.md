---
title: "ARK Database Schema Patch v1.8 → v1.9 · Zeit-Modul"
type: spec
module: zeit
version: 1.9
created: 2026-04-30
updated: 2026-04-30
status: Erstentwurf · Phase-3-ERP Sync-Patch
sources: [
  "Grundlagen MD/ARK_DATABASE_SCHEMA_v1_8.md",
  "specs/ARK_ZEIT_SCHEMA_v0_1.md",
  "specs/ARK_ZEIT_INTERACTIONS_v0_1.md",
  "specs/ARK_ZEITERFASSUNG_PLAN_v0_1.md",
  "wiki/meta/zeit-decisions-2026-04-19.md"
]
tags: [schema-patch, db-migration, zeit, arbeitszeit, absenzen, scanner, dsg, arg, indexes, rls, gist, btree-gist]
---

# ARK Database Schema · Patch v1.8 → v1.9 · Zeit-Modul

**Stand:** 2026-04-30
**Status:** Erstentwurf · Phase-3-ERP Sync-Patch
**Quellen:**
- `Grundlagen MD/ARK_DATABASE_SCHEMA_v1_8.md` (Vorgänger · enthält bereits HR-Patch v1.7 → v1.8)
- `specs/ARK_ZEIT_SCHEMA_v0_1.md` §3-§9 (Single-Source-of-Truth Tabellen + ENUMs)
- `specs/ARK_ZEIT_INTERACTIONS_v0_1.md` §5 (State-Machines · Lifecycle-Constraints)
- `specs/ARK_ZEITERFASSUNG_PLAN_v0_1.md` §2 (CH-Arbeitsrecht-Compliance · 5 J Retention)
- `wiki/meta/zeit-decisions-2026-04-19.md` (F1-F14 Peter-Decisions)

**Vorrang:** Stammdaten > Schema > Patch > Mockups

**Voraussetzungen:**
- HR-Patch v1.7 → v1.8 (Mitarbeiter-Stammdaten + `fact_employment_contracts`) deployed (parallel im selben Commit-Set)
- PostgreSQL-Extensions `pgcrypto` + `btree_gist` aktiviert

---

## 0. ZIELBILD (was ändert dieser Patch)

Dieser Patch führt das vollständige PostgreSQL-Schema für das Zeit-ERP-Modul ein:

- **15 neue Tabellen** (3 dim_*, 11 fact_*, 1 firm_settings) für Arbeitszeiterfassung, Abwesenheits-Management, Ferien-/Überzeit-Konten, Monats-Lock, Treuhand-Export, Extra-Guthaben (Arkadium-spezifisch), Scanner-Integration (Fingerabdruck).
- **9 neue ENUM-Types** (Lifecycle-States, Scan-Event-Typ, Time-Source, Overtime-Kind, Salary-Skala, Salary-Phase, Period-Close-State, Correction-State, Work-Time-Model).
- **4 Views** (`v_daily_saldo`, `v_monthly_saldo`, `v_time_per_mandate`, `v_weekly_approval_queue`) für Dashboard + Commission-Engine-ZEG-Feed.
- **GIST-Overlap-Constraints** auf `fact_time_entry` + `fact_absence` (verhindert doppelte Einträge pro User/Periode).
- **RLS-Policies** (per-Tenant + per-User-self + Manager-Approval-Scope + Backoffice/Admin-Bypass).
- **DSG-Audit-Tabelle** für Scanner-Daten-Zugriff (revDSG Art. 5 Ziff. 4 · biometrische Daten = besondere PD).
- **Retention-Hooks** (5 J post Vertrags-Ende für Scanner-Events + Time-Entries · 10 J für Audit + Correction).

**Abhängigkeiten:** Backend-Patch v2.5 → v2.6 (committed 2026-04-19) liefert Worker `scan-event-processor` + Endpoints; FE-Patch v1.15 → v1.16 (P3) baut UI-Routing darauf auf.

---

## 1. PostgreSQL Extensions

```sql
CREATE EXTENSION IF NOT EXISTS pgcrypto;     -- gen_random_uuid()
CREATE EXTENSION IF NOT EXISTS btree_gist;   -- GIST-Overlap-Constraints (Time-Entry + Absence)
```

---

## 2. Neue ENUM-Types (9)

### 2.1 `time_entry_state`

```sql
CREATE TYPE ark.time_entry_state AS ENUM (
    'draft',        -- MA erfasst, noch editierbar
    'submitted',    -- MA hat Monat eingereicht
    'approved',     -- Head of hat approved
    'locked',       -- Monatslock, export-bereit
    'corrected',    -- historische Version nach Korrektur
    'rejected'      -- Head of hat abgelehnt, zurück zu draft
);
```

### 2.2 `absence_state`

```sql
CREATE TYPE ark.absence_state AS ENUM (
    'draft', 'submitted', 'approved', 'active', 'completed',
    'rejected', 'cancelled', 'corrected'
);
```

### 2.3 `correction_state`

```sql
CREATE TYPE ark.correction_state AS ENUM (
    'requested', 'tl_approved', 'gf_approved', 'applied', 'rejected'
);
```

### 2.4 `period_close_state`

```sql
CREATE TYPE ark.period_close_state AS ENUM (
    'open', 'submitted', 'tl_approved', 'gf_approved',
    'locked', 'exported', 'reopened'
);
```

### 2.5 `work_time_model`

```sql
CREATE TYPE ark.work_time_model AS ENUM (
    'FLEX_CORE',        -- Gleitzeit mit Kernzeit (Default)
    'FIXED',            -- Fix-Zeit
    'PARTTIME',         -- Teilzeit %
    'SIMPLIFIED_73B',   -- Vereinfachte Erfassung Art. 73b ArGV 1
    'EXEMPT_EXEC'       -- Höhere leitende Tätigkeit (Art. 3 ArG)
);
```

### 2.6 `scan_event_type`

```sql
CREATE TYPE ark.scan_event_type AS ENUM (
    'check_in', 'check_out', 'break_start', 'break_end', 'override'
);
```

### 2.7 `time_entry_source`

```sql
CREATE TYPE ark.time_entry_source AS ENUM (
    'scanner', 'manual', 'timer', 'import', 'admin'
);
```

### 2.8 `overtime_kind`

```sql
CREATE TYPE ark.overtime_kind AS ENUM (
    'regular',          -- im Soll
    'ueberstunden_or',  -- OR Art. 321c (über Vertrag, innerhalb 45h)
    'ueberzeit_arg',    -- ArG Art. 12 (über 45h, Jahres-Cap 170h)
    'uncounted'         -- >10h/Tag · Firmenpolicy-Cut
);
```

### 2.9 `salary_scale_code` + `salary_continuation_phase`

```sql
CREATE TYPE ark.salary_scale_code AS ENUM (
    'ZURICH', 'BERN', 'BASEL', 'INSURANCE_EQUIV'
);

CREATE TYPE ark.salary_continuation_phase AS ENUM (
    'full_100', 'partial_ktg', 'unpaid'
);
```

---

## 3. Neue Dimension-Tabellen (3)

### 3.1 `dim_absence_type`

```sql
CREATE TABLE ark.dim_absence_type (
    code                        VARCHAR(40) PRIMARY KEY,
    label_de                    VARCHAR(120) NOT NULL,
    paid_default                BOOLEAN NOT NULL,
    counts_toward_target        BOOLEAN NOT NULL DEFAULT TRUE,
    max_days_per_year           NUMERIC(6,2) NULL,
    requires_cert_from_day_1dj  SMALLINT NULL,    -- 1. Dienstjahr
    requires_cert_from_day_2dj  SMALLINT NULL,    -- 2. Dienstjahr
    requires_cert_from_day_3dj  SMALLINT NULL,    -- 3.+ Dienstjahr
    requires_approval           BOOLEAN NOT NULL DEFAULT TRUE,
    affects_vacation_accrual    BOOLEAN NOT NULL DEFAULT FALSE,
    legal_basis_ref             VARCHAR(200) NULL,
    swissdec_wage_type          VARCHAR(20) NULL,
    bexio_absence_type_id       INTEGER NULL,
    category                    VARCHAR(40) NULL, -- 'medical' | 'family' | 'civic' | 'policy' | 'extra'
    active                      BOOLEAN NOT NULL DEFAULT TRUE,
    created_at                  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_cert_days_1dj CHECK (requires_cert_from_day_1dj IS NULL OR requires_cert_from_day_1dj >= 1),
    CONSTRAINT chk_cert_days_2dj CHECK (requires_cert_from_day_2dj IS NULL OR requires_cert_from_day_2dj >= 1),
    CONSTRAINT chk_cert_days_3dj CHECK (requires_cert_from_day_3dj IS NULL OR requires_cert_from_day_3dj >= 1)
);

COMMENT ON TABLE ark.dim_absence_type IS
    'Abwesenheitskatalog (Reglement + Gesetz). 30 Default-Seeds in Stammdaten-Patch v1.7→v1.8 §1.';
```

### 3.2 `dim_time_category`

```sql
CREATE TABLE ark.dim_time_category (
    code                VARCHAR(40) PRIMARY KEY,
    label_de            VARCHAR(120) NOT NULL,
    billable_default    BOOLEAN NOT NULL DEFAULT FALSE,
    project_required    BOOLEAN NOT NULL DEFAULT FALSE,
    counts_as_worktime  BOOLEAN NOT NULL DEFAULT TRUE,
    is_break            BOOLEAN NOT NULL DEFAULT FALSE,
    zeg_relevant        BOOLEAN NOT NULL DEFAULT FALSE, -- Commission-ZEG-Staffel-Feed
    sort_order          SMALLINT NOT NULL DEFAULT 100,
    active              BOOLEAN NOT NULL DEFAULT TRUE
);
```

### 3.3 `dim_work_time_model`

```sql
CREATE TABLE ark.dim_work_time_model (
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

### 3.4 `dim_salary_continuation_scale`

```sql
CREATE TABLE ark.dim_salary_continuation_scale (
    scale_code      ark.salary_scale_code NOT NULL,
    dienstjahr_from SMALLINT NOT NULL CHECK (dienstjahr_from >= 1),
    dienstjahr_to   SMALLINT NULL,
    duration_weeks  NUMERIC(5,2) NOT NULL,
    active          BOOLEAN NOT NULL DEFAULT TRUE,
    PRIMARY KEY (scale_code, dienstjahr_from)
);
```

---

## 4. Neue Fact-Tabellen (11)

### 4.1 `firm_settings` (globale Konfig)

```sql
CREATE TABLE ark.firm_settings (
    key             VARCHAR(80) PRIMARY KEY,
    value_text      TEXT NULL,
    value_numeric   NUMERIC(10,4) NULL,
    value_json      JSONB NULL,
    description     TEXT NULL,
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by      UUID NOT NULL REFERENCES ark.dim_user(id)
);
```

Kritische Seeds (Vollzahl + Reglement-Werte siehe Stammdaten-Patch v1.7→v1.8 §3):
- `max_daily_hours = 10.0` (Daily-Cap, Firmenpolicy F2)
- `normal_weekly_hours = 45.0` (Tempus Passio §2)
- `jahres_ueberzeit_cap = 170` (ArG Art. 12)
- `salary_continuation_scale_default = 'ZURICH'` (Generalis Provisio §6.2.1)
- `monthly_payroll_cutoff_day = 25` (Treuhand-Export-Termin)
- `overtime_compensation_policy = 'paid_with_salary'` (Arkadium-Vertragsklausel)

### 4.2 `fact_workday_target`

```sql
CREATE TABLE ark.fact_workday_target (
    id                              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id                         UUID NOT NULL REFERENCES ark.dim_user(id),
    employment_contract_id          UUID NULL REFERENCES ark.fact_employment_contracts(id),
    -- HR-Modul ist Source-of-Truth für Pensum/Stunden, Sync via Worker
    year                            SMALLINT NOT NULL,
    work_time_model_code            VARCHAR(40) NOT NULL REFERENCES ark.dim_work_time_model(code),
    target_hours_per_week           NUMERIC(5,2) NOT NULL,
    variant_percent                 NUMERIC(5,2) NOT NULL DEFAULT 100.00,
    weekday_minutes_jsonb           JSONB NOT NULL,
    -- {"mon":540,"tue":540,"wed":540,"thu":540,"fri":540,"sat":0,"sun":0}
    default_break_min               SMALLINT NOT NULL DEFAULT 30,
    core_hours_mo_fr_am_from        TIME NULL,
    core_hours_mo_fr_am_to          TIME NULL,
    core_hours_mo_do_pm_from        TIME NULL,
    core_hours_mo_do_pm_to          TIME NULL,
    core_hours_fr_pm_from           TIME NULL,
    core_hours_fr_pm_to             TIME NULL,
    vacation_days_entitlement       NUMERIC(4,1) NOT NULL DEFAULT 25.0,
    salary_continuation_scale       ark.salary_scale_code NOT NULL DEFAULT 'ZURICH',
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
```

### 4.3 `fact_holiday_cantonal`

```sql
CREATE TABLE ark.fact_holiday_cantonal (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    canton_code     CHAR(2) NOT NULL DEFAULT 'ZH',
    date            DATE NOT NULL,
    label_de        VARCHAR(120) NOT NULL,
    half_day        BOOLEAN NOT NULL DEFAULT FALSE,
    is_statutory    BOOLEAN NOT NULL DEFAULT TRUE,
    credit_factor   NUMERIC(4,3) NOT NULL DEFAULT 1.000,
    source_ref      VARCHAR(200) NULL,
    active          BOOLEAN NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_credit_factor CHECK (credit_factor > 0 AND credit_factor <= 1),
    CONSTRAINT uq_holiday_canton_date_label UNIQUE (canton_code, date, label_de)
);
```

### 4.4 `fact_bridge_day`

```sql
CREATE TABLE ark.fact_bridge_day (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    date                DATE NOT NULL,
    year                SMALLINT GENERATED ALWAYS AS (EXTRACT(YEAR FROM date)::SMALLINT) STORED,
    label_de            VARCHAR(120) NOT NULL,
    credit_factor       NUMERIC(4,3) NOT NULL DEFAULT 1.000,
    decided_by          UUID NOT NULL REFERENCES ark.dim_user(id),
    decided_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    reason              TEXT NULL,
    active              BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT uq_bridge_date UNIQUE (date),
    CONSTRAINT chk_bridge_credit CHECK (credit_factor > 0 AND credit_factor <= 1)
);
```

### 4.5 `fact_time_scan_event` (Scanner-Roh-Events)

```sql
CREATE TABLE ark.fact_time_scan_event (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id             UUID NOT NULL REFERENCES ark.dim_user(id),
    scan_at             TIMESTAMPTZ NOT NULL,
    scan_type           ark.scan_event_type NOT NULL,
    device_id           VARCHAR(80) NULL,
    device_location     VARCHAR(120) NULL,
    raw_payload_jsonb   JSONB NULL,                 -- Scanner-API-Rohdaten OHNE Biometrie
    override_by         UUID NULL REFERENCES ark.dim_user(id),
    override_reason     TEXT NULL,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_override_fields CHECK (
        (scan_type = 'override' AND override_by IS NOT NULL AND override_reason IS NOT NULL)
        OR scan_type <> 'override'
    )
);

COMMENT ON TABLE ark.fact_time_scan_event IS
    'DSG-kritisch: revDSG Art. 5 Ziff. 4 (biometrische Daten = besondere PD).
     Template-Hash NIE hier speichern, nur abgeleitete scan-events.';
```

### 4.6 `fact_time_entry` (aggregierter Tages-Eintrag)

```sql
CREATE TABLE ark.fact_time_entry (
    id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id                 UUID NOT NULL REFERENCES ark.dim_user(id),
    entry_date              DATE NOT NULL,
    start_time              TIME NULL,
    end_time                TIME NULL,
    break_min               SMALLINT NOT NULL DEFAULT 0,
    raw_duration_min        INTEGER NOT NULL,       -- Scanner-Roh (brutto)
    counted_duration_min    INTEGER NOT NULL,       -- gecapped @ max_daily_hours
    uncounted_duration_min  INTEGER GENERATED ALWAYS AS (raw_duration_min - counted_duration_min) STORED,
    project_id              UUID NULL REFERENCES ark.fact_process_core(id),
    category_code           VARCHAR(40) NOT NULL REFERENCES ark.dim_time_category(code),
    billable                BOOLEAN NOT NULL DEFAULT FALSE,
    overtime_kind           ark.overtime_kind NOT NULL DEFAULT 'regular',
    entry_state             ark.time_entry_state NOT NULL DEFAULT 'draft',
    source                  ark.time_entry_source NOT NULL DEFAULT 'scanner',
    comment                 TEXT NULL,
    submitted_at            TIMESTAMPTZ NULL,
    approved_by             UUID NULL REFERENCES ark.dim_user(id),
    approved_at             TIMESTAMPTZ NULL,
    locked_at               TIMESTAMPTZ NULL,
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by              UUID NOT NULL REFERENCES ark.dim_user(id),
    audit_trail_jsonb       JSONB NOT NULL DEFAULT '[]'::jsonb,
    CONSTRAINT chk_raw_positive CHECK (raw_duration_min >= 0),
    CONSTRAINT chk_counted_range CHECK (counted_duration_min >= 0 AND counted_duration_min <= 600),
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

-- Overlap-Prevention: keine 2 Einträge gleichzeitig für gleichen User
ALTER TABLE ark.fact_time_entry ADD CONSTRAINT excl_time_entry_overlap
    EXCLUDE USING GIST (
        user_id WITH =,
        tsrange(
            (entry_date::timestamp + start_time),
            (entry_date::timestamp + end_time),
            '[)'
        ) WITH &&
    ) WHERE (entry_state <> 'rejected' AND start_time IS NOT NULL);
```

### 4.7 `fact_time_correction`

```sql
CREATE TABLE ark.fact_time_correction (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    original_entry_id   UUID NOT NULL REFERENCES ark.fact_time_entry(id),
    requested_by        UUID NOT NULL REFERENCES ark.dim_user(id),
    requested_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    reason              TEXT NOT NULL,
    old_values_jsonb    JSONB NOT NULL,
    new_values_jsonb    JSONB NOT NULL,
    diff_jsonb          JSONB GENERATED ALWAYS AS
        (jsonb_strip_nulls(new_values_jsonb - old_values_jsonb)) STORED,
    tl_approved_by      UUID NULL REFERENCES ark.dim_user(id),
    tl_approved_at      TIMESTAMPTZ NULL,
    admin_approved_by   UUID NULL REFERENCES ark.dim_user(id),
    admin_approved_at   TIMESTAMPTZ NULL,
    applied_at          TIMESTAMPTZ NULL,
    status              ark.correction_state NOT NULL DEFAULT 'requested',
    audit_jsonb         JSONB NOT NULL DEFAULT '{}'::jsonb,
    CONSTRAINT chk_correction_flow CHECK (
        status NOT IN ('applied') OR admin_approved_by IS NOT NULL OR tl_approved_by IS NOT NULL
    )
);
```

### 4.8 `fact_time_period_close`

```sql
CREATE TABLE ark.fact_time_period_close (
    id                          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id                     UUID NOT NULL REFERENCES ark.dim_user(id),
    period_month                DATE NOT NULL,
    submitted_at                TIMESTAMPTZ NULL,
    submitted_by                UUID NULL REFERENCES ark.dim_user(id),
    tl_weekly_checks_done       JSONB NULL,
    tl_approved_at              TIMESTAMPTZ NULL,
    tl_approved_by              UUID NULL REFERENCES ark.dim_user(id),
    gf_approved_at              TIMESTAMPTZ NULL,
    gf_approved_by              UUID NULL REFERENCES ark.dim_user(id),
    locked_at                   TIMESTAMPTZ NULL,
    locked_by                   UUID NULL REFERENCES ark.dim_user(id),
    exported_at                 TIMESTAMPTZ NULL,
    exported_by                 UUID NULL REFERENCES ark.dim_user(id),
    export_batch_ref            VARCHAR(120) NULL,
    export_needs_redo           BOOLEAN NOT NULL DEFAULT FALSE,
    status                      ark.period_close_state NOT NULL DEFAULT 'open',
    audit_trail_jsonb           JSONB NOT NULL DEFAULT '[]'::jsonb,
    CONSTRAINT chk_period_first_day CHECK (date_trunc('month', period_month)::date = period_month),
    CONSTRAINT uq_period_close_user_month UNIQUE (user_id, period_month)
);
```

### 4.9 `fact_absence`

```sql
CREATE TABLE ark.fact_absence (
    id                              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id                         UUID NOT NULL REFERENCES ark.dim_user(id),
    absence_type_code               VARCHAR(40) NOT NULL REFERENCES ark.dim_absence_type(code),
    start_date                      DATE NOT NULL,
    end_date                        DATE NOT NULL,
    half_day_start                  BOOLEAN NOT NULL DEFAULT FALSE,
    half_day_end                    BOOLEAN NOT NULL DEFAULT FALSE,
    working_days_deducted           NUMERIC(5,2) NOT NULL,
    paid                            BOOLEAN NOT NULL,
    approved_by                     UUID NULL REFERENCES ark.dim_user(id),
    approved_at                     TIMESTAMPTZ NULL,
    substitute_user_id              UUID NULL REFERENCES ark.dim_user(id),
    -- Stellvertreter Pflicht bei VACATION ≥3 Tage (Reglement Tempus Passio §2)
    doctor_cert_file                VARCHAR(500) NULL,
    doctor_cert_uploaded_at         TIMESTAMPTZ NULL,
    doctor_cert_reminder_sent_at    TIMESTAMPTZ NULL,
    status                          ark.absence_state NOT NULL DEFAULT 'draft',
    reason                          TEXT NULL,
    salary_continuation_phase       ark.salary_continuation_phase NULL,
    created_at                      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at                      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    audit_trail_jsonb               JSONB NOT NULL DEFAULT '[]'::jsonb,
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

-- Overlap-Prevention für approved/active/completed Absences
ALTER TABLE ark.fact_absence ADD CONSTRAINT excl_absence_overlap
    EXCLUDE USING GIST (
        user_id WITH =,
        daterange(start_date, end_date, '[]') WITH &&
    ) WHERE (status IN ('approved','active','completed'));
```

### 4.10 `fact_vacation_balance`

```sql
CREATE TABLE ark.fact_vacation_balance (
    user_id                 UUID NOT NULL REFERENCES ark.dim_user(id),
    year                    SMALLINT NOT NULL,
    entitlement_days        NUMERIC(5,2) NOT NULL,
    carried_over            NUMERIC(5,2) NOT NULL DEFAULT 0,
    taken                   NUMERIC(5,2) NOT NULL DEFAULT 0,
    planned                 NUMERIC(5,2) NOT NULL DEFAULT 0,
    remaining               NUMERIC(5,2) GENERATED ALWAYS AS
        (entitlement_days + carried_over - taken) STORED,
    carryover_deadline      DATE NULL,    -- 14d nach Ostern Folgejahr (Reglement)
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (user_id, year),
    CONSTRAINT chk_balance_nonneg CHECK (
        entitlement_days >= 0 AND taken >= 0 AND carried_over >= 0 AND planned >= 0
    )
);
```

### 4.11 `fact_overtime_balance` (3-Konten-Saldo)

```sql
CREATE TABLE ark.fact_overtime_balance (
    user_id             UUID NOT NULL REFERENCES ark.dim_user(id),
    period              VARCHAR(7) NOT NULL,        -- YYYY-MM oder YYYY
    overtime_kind       ark.overtime_kind NOT NULL,
    accumulated_min     INTEGER NOT NULL DEFAULT 0,
    compensated_min     INTEGER NOT NULL DEFAULT 0,
    paid_out_min        INTEGER NOT NULL DEFAULT 0,
    remaining_min       INTEGER GENERATED ALWAYS AS
        (accumulated_min - compensated_min - paid_out_min) STORED,
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (user_id, period, overtime_kind),
    CONSTRAINT chk_ot_kind CHECK (overtime_kind IN ('ueberstunden_or','ueberzeit_arg'))
);
```

### 4.12 `fact_extra_leave_entitlement`

```sql
CREATE TABLE ark.fact_extra_leave_entitlement (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id             UUID NOT NULL REFERENCES ark.dim_user(id),
    year                SMALLINT NOT NULL,
    absence_type_code   VARCHAR(40) NOT NULL REFERENCES ark.dim_absence_type(code),
    days_entitled       NUMERIC(4,2) NOT NULL,
    days_taken          NUMERIC(4,2) NOT NULL DEFAULT 0,
    reason_note         TEXT NULL,
    unlocked_by         UUID NULL REFERENCES ark.dim_user(id),
    unlocked_at         TIMESTAMPTZ NULL,
    expires_at          DATE NULL,
    lapsed              BOOLEAN NOT NULL DEFAULT FALSE,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_extra_leave_per_year UNIQUE (user_id, year, absence_type_code)
);
```

### 4.13 `fact_salary_continuation_claim`

```sql
CREATE TABLE ark.fact_salary_continuation_claim (
    id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id                 UUID NOT NULL REFERENCES ark.dim_user(id),
    dienstjahr              SMALLINT NOT NULL,
    scale_code              ark.salary_scale_code NOT NULL,
    entitlement_weeks       NUMERIC(5,2) NOT NULL,
    entitlement_days        NUMERIC(5,2) NOT NULL,
    consumed_days_100       NUMERIC(5,2) NOT NULL DEFAULT 0,
    consumed_days_80_ktg    NUMERIC(5,2) NOT NULL DEFAULT 0,
    waiting_period_served   BOOLEAN NOT NULL DEFAULT FALSE,
    reset_date              DATE NOT NULL,
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_salary_claim_user_dj UNIQUE (user_id, dienstjahr)
);
```

### 4.14 `fact_simplified_agreement` (Art. 73b ArGV 1)

```sql
CREATE TABLE ark.fact_simplified_agreement (
    id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    agreement_type          VARCHAR(20) NOT NULL CHECK (agreement_type IN ('collective','individual')),
    signed_by_user_id       UUID NULL REFERENCES ark.dim_user(id),
    signed_count_majority   SMALLINT NULL,
    signed_at               TIMESTAMPTZ NOT NULL,
    valid_from              DATE NOT NULL,
    valid_to                DATE NULL,
    pdf_file                VARCHAR(500) NOT NULL,
    annual_review_at        TIMESTAMPTZ NULL,
    status                  VARCHAR(20) NOT NULL DEFAULT 'active'
                            CHECK (status IN ('active','revoked','expired')),
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_signed_fields CHECK (
        (agreement_type = 'individual' AND signed_by_user_id IS NOT NULL)
        OR (agreement_type = 'collective' AND signed_count_majority IS NOT NULL)
    )
);
```

### 4.15 `fact_scanner_access_audit` (DSG-Audit)

```sql
CREATE TABLE ark.fact_scanner_access_audit (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    accessed_by     UUID NOT NULL REFERENCES ark.dim_user(id),
    access_type     VARCHAR(40) NOT NULL
                    CHECK (access_type IN ('read_scans','read_entries','export','correction')),
    target_user_id  UUID NULL REFERENCES ark.dim_user(id),
    period_month    DATE NULL,
    reason          TEXT NULL,
    ip_address      INET NULL,
    accessed_at     TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE ark.fact_scanner_access_audit IS
    'DSG-Nachweispflicht (revDSG Art. 12) · 10 J Retention. Jeder Zugriff auf Scanner-Daten loggt hier.';
```

---

## 5. Indizes

```sql
-- workday_target
CREATE INDEX idx_workday_target_user_year ON ark.fact_workday_target(user_id, year);
CREATE UNIQUE INDEX uq_workday_target_active ON ark.fact_workday_target(user_id, year)
    WHERE contract_end IS NULL;

-- holiday + bridge
CREATE INDEX idx_holiday_canton_year ON ark.fact_holiday_cantonal(canton_code, date);
CREATE INDEX idx_bridge_year ON ark.fact_bridge_day(year);

-- Scanner-Events (Hot-Path: Stempel-Lookup pro User pro Tag)
CREATE INDEX idx_scan_user_date ON ark.fact_time_scan_event(user_id, scan_at);
CREATE INDEX idx_scan_type ON ark.fact_time_scan_event(scan_type);

-- Time-Entry (mehrere Hot-Paths)
CREATE INDEX idx_time_entry_user_date ON ark.fact_time_entry(user_id, entry_date);
CREATE INDEX idx_time_entry_state ON ark.fact_time_entry(entry_state)
    WHERE entry_state IN ('draft','submitted');
CREATE INDEX idx_time_entry_project ON ark.fact_time_entry(project_id)
    WHERE project_id IS NOT NULL;
CREATE INDEX idx_time_entry_date_range ON ark.fact_time_entry(entry_date, user_id);
CREATE INDEX idx_time_entry_billable ON ark.fact_time_entry(billable) WHERE billable = TRUE;
CREATE INDEX idx_time_entry_audit_gin ON ark.fact_time_entry USING gin (audit_trail_jsonb);

-- Correction
CREATE INDEX idx_correction_original ON ark.fact_time_correction(original_entry_id);
CREATE INDEX idx_correction_status ON ark.fact_time_correction(status);

-- Period-Close
CREATE INDEX idx_period_close_status ON ark.fact_time_period_close(status);
CREATE INDEX idx_period_close_month ON ark.fact_time_period_close(period_month);

-- Absence
CREATE INDEX idx_absence_user_period ON ark.fact_absence(user_id, start_date, end_date);
CREATE INDEX idx_absence_type ON ark.fact_absence(absence_type_code);
CREATE INDEX idx_absence_open ON ark.fact_absence(status) WHERE status IN ('draft','submitted');

-- Extra-Leave
CREATE INDEX idx_extra_leave_user_year ON ark.fact_extra_leave_entitlement(user_id, year);

-- Scanner-Audit (Compliance-Reports)
CREATE INDEX idx_scanner_audit_accessed_by ON ark.fact_scanner_access_audit(accessed_by, accessed_at);
CREATE INDEX idx_scanner_audit_target ON ark.fact_scanner_access_audit(target_user_id);
```

---

## 6. Views (4)

### 6.1 `v_daily_saldo`

```sql
CREATE VIEW ark.v_daily_saldo AS
SELECT
    te.user_id,
    te.entry_date,
    SUM(te.counted_duration_min) AS worked_min,
    SUM(te.uncounted_duration_min) AS uncounted_min,
    SUM(te.break_min) AS break_min,
    (SELECT (wt.weekday_minutes_jsonb->>lower(to_char(te.entry_date, 'dy')))::int
       FROM ark.fact_workday_target wt
      WHERE wt.user_id = te.user_id
        AND wt.contract_start <= te.entry_date
        AND (wt.contract_end IS NULL OR wt.contract_end >= te.entry_date)
      LIMIT 1) AS target_min
FROM ark.fact_time_entry te
WHERE te.entry_state IN ('approved','locked')
GROUP BY te.user_id, te.entry_date;
```

### 6.2 `v_monthly_saldo`

```sql
CREATE VIEW ark.v_monthly_saldo AS
SELECT
    user_id,
    date_trunc('month', entry_date)::date AS period_month,
    SUM(worked_min) AS total_worked_min,
    SUM(uncounted_min) AS total_uncounted_min,
    SUM(target_min) AS total_target_min,
    SUM(worked_min) - SUM(target_min) AS saldo_min
FROM ark.v_daily_saldo
GROUP BY user_id, date_trunc('month', entry_date);
```

### 6.3 `v_time_per_mandate` (Commission-ZEG-Feed)

```sql
CREATE VIEW ark.v_time_per_mandate AS
SELECT
    te.project_id,
    te.user_id,
    date_trunc('month', te.entry_date)::date AS period_month,
    SUM(te.counted_duration_min) FILTER (WHERE tc.zeg_relevant = TRUE) AS zeg_relevant_min,
    SUM(te.counted_duration_min) FILTER (WHERE tc.billable_default = TRUE) AS billable_min,
    SUM(te.counted_duration_min) AS total_min
FROM ark.fact_time_entry te
JOIN ark.dim_time_category tc ON tc.code = te.category_code
WHERE te.entry_state IN ('approved','locked')
  AND te.project_id IS NOT NULL
GROUP BY te.project_id, te.user_id, date_trunc('month', te.entry_date);
```

### 6.4 `v_weekly_approval_queue` (deprecated · für Spätaktivierung)

```sql
CREATE VIEW ark.v_weekly_approval_queue AS
SELECT
    te.user_id,
    u.label_de AS user_name,
    date_trunc('week', te.entry_date)::date AS week_start,
    COUNT(*) AS entry_count,
    SUM(te.counted_duration_min) AS total_worked_min,
    SUM(te.uncounted_duration_min) AS total_uncounted_min,
    COUNT(*) FILTER (WHERE te.entry_state = 'draft') AS draft_count,
    COUNT(*) FILTER (WHERE te.entry_state = 'submitted') AS submitted_count
FROM ark.fact_time_entry te
JOIN ark.dim_user u ON u.id = te.user_id
WHERE te.entry_state IN ('draft','submitted')
GROUP BY te.user_id, u.label_de, date_trunc('week', te.entry_date)
HAVING COUNT(*) FILTER (WHERE te.entry_state = 'submitted') > 0
    OR MAX(te.created_at) < NOW() - INTERVAL '5 days';
```

---

## 7. Trigger für Aggregate

### 7.1 Updated-At-Trigger (Standard-Pattern)

```sql
CREATE TRIGGER fact_time_entry_updated_at
    BEFORE UPDATE ON ark.fact_time_entry
    FOR EACH ROW EXECUTE FUNCTION ark.set_updated_at();

CREATE TRIGGER fact_absence_updated_at
    BEFORE UPDATE ON ark.fact_absence
    FOR EACH ROW EXECUTE FUNCTION ark.set_updated_at();

CREATE TRIGGER fact_workday_target_updated_at
    BEFORE UPDATE ON ark.fact_workday_target
    FOR EACH ROW EXECUTE FUNCTION ark.set_updated_at();

CREATE TRIGGER fact_vacation_balance_updated_at
    BEFORE UPDATE ON ark.fact_vacation_balance
    FOR EACH ROW EXECUTE FUNCTION ark.set_updated_at();

CREATE TRIGGER fact_overtime_balance_updated_at
    BEFORE UPDATE ON ark.fact_overtime_balance
    FOR EACH ROW EXECUTE FUNCTION ark.set_updated_at();
```

### 7.2 Audit-Trail-Append (auf Mutationen)

```sql
-- Generische Trigger-Function (analog email-queue, billing-invoice):
CREATE OR REPLACE FUNCTION ark.append_audit_trail()
RETURNS TRIGGER AS $$
BEGIN
    NEW.audit_trail_jsonb := COALESCE(NEW.audit_trail_jsonb, '[]'::jsonb) || jsonb_build_object(
        'action', TG_OP,
        'at', NOW(),
        'by', current_setting('app.user_id', TRUE),
        'changes', to_jsonb(NEW) - to_jsonb(OLD)
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER fact_time_entry_audit
    BEFORE UPDATE ON ark.fact_time_entry
    FOR EACH ROW EXECUTE FUNCTION ark.append_audit_trail();

CREATE TRIGGER fact_absence_audit
    BEFORE UPDATE ON ark.fact_absence
    FOR EACH ROW EXECUTE FUNCTION ark.append_audit_trail();
```

---

## 8. RLS-Policies

```sql
-- RLS aktivieren auf allen Zeit-Fact-Tabellen
ALTER TABLE ark.fact_time_entry ENABLE ROW LEVEL SECURITY;
ALTER TABLE ark.fact_time_scan_event ENABLE ROW LEVEL SECURITY;
ALTER TABLE ark.fact_absence ENABLE ROW LEVEL SECURITY;
ALTER TABLE ark.fact_time_correction ENABLE ROW LEVEL SECURITY;
ALTER TABLE ark.fact_time_period_close ENABLE ROW LEVEL SECURITY;
ALTER TABLE ark.fact_vacation_balance ENABLE ROW LEVEL SECURITY;
ALTER TABLE ark.fact_overtime_balance ENABLE ROW LEVEL SECURITY;
ALTER TABLE ark.fact_extra_leave_entitlement ENABLE ROW LEVEL SECURITY;
ALTER TABLE ark.fact_scanner_access_audit ENABLE ROW LEVEL SECURITY;

-- Policy 1: User sieht eigene Daten (MA-Self-Scope)
CREATE POLICY zeit_entry_self_scope
    ON ark.fact_time_entry
    FOR SELECT
    USING (user_id = current_setting('app.user_id')::uuid);

-- Policy 2: Head of sieht Team (Direct-Reports)
CREATE POLICY zeit_entry_head_scope
    ON ark.fact_time_entry
    FOR SELECT
    USING (
        current_setting('app.user_role') = 'head'
        AND user_id IN (
            SELECT id FROM ark.dim_user
             WHERE direct_supervisor_id = current_setting('app.user_id')::uuid
        )
    );

-- Policy 3: Backoffice + Admin sehen alles (Tenant-weit)
CREATE POLICY zeit_entry_backoffice_admin_scope
    ON ark.fact_time_entry
    FOR ALL
    USING (current_setting('app.user_role') IN ('backoffice', 'admin'));

-- Policy 4: Worker-Service (Aggregator + Treuhand-Export-Worker)
CREATE POLICY zeit_entry_worker_bypass
    ON ark.fact_time_entry
    TO ark_worker_service
    USING (TRUE) WITH CHECK (TRUE);

-- Analoge Policies für fact_absence, fact_time_scan_event, fact_time_correction,
-- fact_time_period_close, fact_vacation_balance, fact_overtime_balance,
-- fact_extra_leave_entitlement (Scanner-Audit nur Backoffice/Admin)

-- Scanner-Audit: nur Backoffice + Admin sehen Audit-Trail
CREATE POLICY scanner_audit_admin_only
    ON ark.fact_scanner_access_audit
    FOR ALL
    USING (current_setting('app.user_role') IN ('backoffice', 'admin'));
```

---

## 9. Berechtigungen

```sql
GRANT SELECT, INSERT, UPDATE ON ark.fact_time_entry TO ark_user;
GRANT SELECT, INSERT, UPDATE ON ark.fact_absence TO ark_user;
GRANT SELECT ON ark.fact_time_scan_event TO ark_user;          -- Read-only für MA (eigene)
GRANT SELECT, INSERT ON ark.fact_time_correction TO ark_user;
GRANT SELECT ON ark.fact_vacation_balance TO ark_user;
GRANT SELECT ON ark.fact_overtime_balance TO ark_user;
GRANT SELECT, INSERT ON ark.fact_extra_leave_entitlement TO ark_user;

-- Backoffice / Admin: alle Mutationen
GRANT ALL ON ark.fact_time_entry, ark.fact_absence, ark.fact_time_correction,
              ark.fact_time_period_close, ark.fact_workday_target,
              ark.fact_holiday_cantonal, ark.fact_bridge_day,
              ark.fact_simplified_agreement, ark.fact_scanner_access_audit
              TO ark_backoffice, ark_admin;

-- Worker-Service: vollständig
GRANT ALL ON ALL TABLES IN SCHEMA ark TO ark_worker_service;

-- Power-BI: Read-only auf Saldo-Views (keine Roh-Scanner-Daten!)
GRANT SELECT ON ark.v_daily_saldo, ark.v_monthly_saldo,
                ark.v_time_per_mandate
                TO ark_powerbi_reader;
```

---

## 10. Retention + DSG-Löschung

| Entität | Retention | Grundlage |
|---------|-----------|-----------|
| `fact_time_entry` | 5 J post Vertrags-Ende | ArGV 1 Art. 73 Abs. 2 |
| `fact_absence` (medical) | 5 J post Vertrags-Ende | revDSG Art. 5 (besondere PD) |
| `fact_time_scan_event` | 5 J | ArGV 1 Art. 73 |
| `fact_scanner_access_audit` | 10 J | DSG-Nachweispflicht |
| `fact_time_correction` | 10 J | Audit-Trail-Beweislast |
| `doctor_cert_file` (Files) | 5 J post Abwesenheits-Ende | revDSG Art. 5 Ziff. 2 |
| `audit_trail_jsonb` (alle) | 10 J append-only | OR 958f |

**Worker:** `retention.worker.ts` (bestehend) erweitert um Zeit-spezifische Cleanup-Jobs (nightly).

---

## 11. Migration-Reihenfolge

1. CREATE EXTENSIONS (`pgcrypto`, `btree_gist`)
2. CREATE TYPE × 9 (alle ENUMs §2)
3. CREATE TABLE × 4 (dim_*: absence_type, time_category, work_time_model, salary_continuation_scale)
4. CREATE TABLE × 11 (fact_*: workday_target, holiday_cantonal, bridge_day, time_scan_event, time_entry, time_correction, time_period_close, absence, vacation_balance, overtime_balance, extra_leave_entitlement, salary_continuation_claim, simplified_agreement, scanner_access_audit) + `firm_settings`
5. CREATE INDEX × 16 (siehe §5)
6. CREATE VIEW × 4 (siehe §6)
7. ALTER TABLE … ADD CONSTRAINT excl_*_overlap (GIST · 2 Constraints)
8. ENABLE RLS auf 9 Fact-Tabellen
9. CREATE POLICY × 4 pro RLS-Tabelle (~36 Policies)
10. CREATE TRIGGER (updated_at × 5 + audit × 2)
11. GRANT Permissions
12. Verify: EXPLAIN auf Hot-Path-Queries (`v_daily_saldo`, `v_time_per_mandate`), GIST-Constraint-Test mit Overlap-Insert (muss fehlschlagen)

---

## 12. Rollback

```sql
-- Partieller Rollback (Tabellen leer):
DROP VIEW IF EXISTS ark.v_weekly_approval_queue, ark.v_time_per_mandate,
                    ark.v_monthly_saldo, ark.v_daily_saldo CASCADE;
DROP TABLE IF EXISTS
    ark.fact_scanner_access_audit, ark.fact_simplified_agreement,
    ark.fact_salary_continuation_claim, ark.fact_extra_leave_entitlement,
    ark.fact_overtime_balance, ark.fact_vacation_balance,
    ark.fact_absence, ark.fact_time_period_close, ark.fact_time_correction,
    ark.fact_time_entry, ark.fact_time_scan_event,
    ark.fact_bridge_day, ark.fact_holiday_cantonal,
    ark.fact_workday_target, ark.firm_settings,
    ark.dim_salary_continuation_scale, ark.dim_work_time_model,
    ark.dim_time_category, ark.dim_absence_type
    CASCADE;
DROP TYPE IF EXISTS
    ark.salary_continuation_phase, ark.salary_scale_code,
    ark.overtime_kind, ark.time_entry_source, ark.scan_event_type,
    ark.work_time_model, ark.period_close_state,
    ark.correction_state, ark.absence_state, ark.time_entry_state
    CASCADE;
```

---

## 13. SYNC-IMPACT

| Grundlagen-Datei | Änderung |
|------------------|----------|
| `ARK_BACKEND_ARCHITECTURE_v2_6.md` | bereits v2.6 (committed 2026-04-19, Backend-Patch enthält Worker `scan-event-processor` + `time-billing-monthly` + 4 Endpoints) — keine separate Backend-Sync für Zeit nötig |
| `ARK_STAMMDATEN_EXPORT_v1_7.md` | +30 Absence-Types · +12 Time-Categories · +5 Work-Time-Models · +18 Skalen-Rows · +12 Feiertage · +Activity-Type-Erweiterung → **Stammdaten-Patch v1.7→v1.8 (P2)** |
| `ARK_FRONTEND_FREEZE_v1_15.md` | +10 Routen `/zeit/*` + Sidebar-Sektion + 5 Drawer + Permission-Matrix → **FE-Patch v1.15→v1.16 (P3)** |
| `ARK_GESAMTSYSTEM_UEBERSICHT_v1_6.md` | Changelog v1.7 + Cross-Module-Integration (HR/Billing/Performance/Stammdaten) → **Gesamtsystem-Patch v1.6→v1.7 (P4)** |

---

## 14. Acceptance Criteria

- [ ] 9 ENUM-Types erstellt + alle States in `fact_time_entry.entry_state` etc. validiert
- [ ] 4 Dim-Tabellen + 14 Fact-Tabellen + `firm_settings` migriert
- [ ] 16 Indizes (inkl. GIN auf `audit_trail_jsonb`) angelegt
- [ ] 4 Views liefern korrekte Aggregate (Test mit 1-Wochen-Sample)
- [ ] 2 GIST-Overlap-Constraints blocken doppelte Einträge (Negativ-Test)
- [ ] RLS aktiv: MA sieht nur eigene Zeit, Head of sieht Direct-Reports, Backoffice/Admin alles
- [ ] `v_time_per_mandate` liefert ZEG-relevante Minuten pro Projekt+User+Monat (Commission-Engine-Smoke-Test)
- [ ] Rollback-Script lauffähig auf leerer DB
- [ ] DSG-Audit-Tabelle `fact_scanner_access_audit` schreibt bei jedem Scanner-Daten-Read

---

**Ende v1.9 · Zeit.** Apply-Reihenfolge: DB v1.9 (dieser Patch) → Stammdaten v1.8 → Backend v2.6 (bereits committed) → FE v1.16 → Gesamtsystem v1.7.
Backend-Patch existiert bereits (committed 2026-04-19 als Teil v2.5 → v2.6 Z. Zeit) — keine separate Backend-Sync nötig.
