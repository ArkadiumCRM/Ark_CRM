---
title: "ARK Database Schema · Patch v1.7 → v1.8 · HR-Modul"
type: spec
module: hr
version: 1.8
created: 2026-04-30
updated: 2026-04-30
status: draft · HR-Sync-Patch
sources: [
  "Grundlagen MD/ARK_DATABASE_SCHEMA_v1_7.md",
  "specs/ARK_HR_TOOL_SCHEMA_v0_2.md",
  "specs/ARK_HR_TOOL_INTERACTIONS_v0_1.md",
  "specs/ARK_HR_TOOL_PLAN_v0_2.md"
]
tags: [schema-patch, db-migration, hr, employment, onboarding, disciplinary, probezeit, rls, enums, triggers]
---

# ARK Database Schema · Patch v1.7 → v1.8 · HR-Modul

**Stand:** 2026-04-30
**Status:** Draft · HR-Sync-Patch
**Quellen:**
- `Grundlagen MD/ARK_DATABASE_SCHEMA_v1_7.md` (Vorgänger)
- `specs/ARK_HR_TOOL_SCHEMA_v0_2.md` (DDL-Quelle, v0.2 = authoritative)
- `specs/ARK_HR_TOOL_INTERACTIONS_v0_1.md` (Drawer-Inventar, Alert-Views)
- `specs/ARK_HR_TOOL_PLAN_v0_2.md` (Legal-Basis, Scope, Retention)

**Vorrang:** Stammdaten > Schema > Patch > Mockups

**Voraussetzungen:**
- DB-Patch v1.7 (`fact_email_send_queue` + Email-Enums) deployed
- `dim_user` mit `role_code`, `team_lead_id`, `employment_start`, `active` vorhanden
- `fact_absence` aus `ARK_ZEIT_SCHEMA_v0_1.md` (FK-Referenz, nicht hier definiert)
- DB-Rollen `ark_role_ma`, `ark_role_head`, `ark_role_admin`, `ark_role_bo`, `ark_worker_service` vorhanden

---

## 0. ZIELBILD (was ändert dieser Patch)

Dieser Patch führt das vollständige HR-Modul-Schema in die Grundlagen-DB-Spec ein. Umfang:

1. **8 neue ENUM-Types** (Vertrags- und HR-Lifecycle-States)
2. **3 Dimension-Tabellen** (`dim_hr_document_type`, `dim_disciplinary_offense_type`, `dim_onboarding_task_template_type`) mit Phase-1-Seeds
3. **8 Fact-Tabellen** (`fact_employment_contracts`, `fact_employment_attachments`, `fact_disciplinary_records`, `fact_probation_milestones`, `fact_onboarding_templates`, `fact_onboarding_template_tasks`, `fact_onboarding_instances`, `fact_onboarding_instance_tasks`)
4. **4 Views** (`v_hr_active_employees`, `v_onboarding_progress`, `v_disciplinary_summary`, `v_pending_signatures`)
5. **5 Trigger-Funktionen + 8 Trigger-Bindungen**
6. **RLS-Policies** (MA-Self · HEAD-Team · ADMIN-All · BO-ReadOnly) auf allen Fact-Tabellen
7. **Seeds** (47 Einträge auf Dim-Tabellen + 3 Standard-Onboarding-Templates)

**Abhängigkeiten:** Backend-Patch v2.9 → v2.10 benötigt diese Tabellen für HR-Workers und Endpoints.

---

## 1. Neue ENUM-Types

### 1.1 `contract_state`

```sql
CREATE TYPE contract_state AS ENUM (
    'draft',        -- Entwurf, noch nicht unterschrieben
    'pending_sig',  -- Wartet auf Unterschriften
    'active',       -- Gültig, in Kraft
    'terminated',   -- Gekündigt (Frist läuft oder abgelaufen)
    'expired',      -- Befristeter Vertrag ausgelaufen
    'voided'        -- Ungültig / Fehler
);
```

### 1.2 `employment_type`

```sql
CREATE TYPE employment_type AS ENUM (
    'permanent',    -- Unbefristet
    'fixed_term',   -- Befristet
    'intern',       -- Praktikum
    'freelance'     -- Freie Mitarbeit (keine AHV-Pflicht über Arkadium)
);
```

### 1.3 `termination_reason`

```sql
CREATE TYPE termination_reason AS ENUM (
    'resignation',          -- Kündigung durch MA
    'dismissal',            -- Kündigung durch AG (ordentlich)
    'dismissal_immediate',  -- Fristlose Entlassung (OR 337)
    'mutual_agreement',     -- Auflösung im gegenseitigen Einvernehmen
    'end_fixed_term',       -- Befristung ausgelaufen
    'retirement',           -- Pensionierung
    'death'                 -- Todesfall
);
```

### 1.4 `hr_doc_state`

```sql
CREATE TYPE hr_doc_state AS ENUM (
    'pending',      -- Dokument generiert, Unterschrift ausstehend
    'signed',       -- Beidseitig unterschrieben
    'superseded',   -- Von neuerer Version ersetzt
    'revoked'       -- Widerrufen
);
```

### 1.5 `probation_milestone_type`

```sql
CREATE TYPE probation_milestone_type AS ENUM (
    'month_1_review',       -- 1-Monats-Gespräch
    'month_2_review',       -- 2-Monats-Gespräch (optional)
    'probation_end',        -- Probezeit-Abschluss
    'probation_extended',   -- Probezeit verlängert (OR 335b Abs. 2)
    'probation_failed'      -- Probezeit nicht bestanden (Kündigung in Probezeit)
);
```

### 1.6 `disciplinary_level`

```sql
CREATE TYPE disciplinary_level AS ENUM (
    'verbal_warning',       -- Mündliche Ermahnung
    'written_warning',      -- Schriftliche Verwarnung (erste)
    'formal_warning',       -- Förmliche Abmahnung
    'final_warning',        -- Letzte Verwarnung vor Kündigung
    'suspension',           -- Freistellung (mit/ohne Lohn)
    'dismissal_immediate'   -- Fristlose Entlassung
);
```

### 1.7 `disciplinary_state`

```sql
CREATE TYPE disciplinary_state AS ENUM (
    'draft',        -- Entwurf, noch nicht zugestellt
    'issued',       -- Zugestellt / kommuniziert
    'acknowledged', -- MA hat zur Kenntnis genommen (Unterschrift)
    'disputed',     -- MA bestreitet (Einsprache)
    'resolved',     -- Erledigt / ohne Folge
    'archived'      -- Abgelegt (nach Retention-Frist)
);
```

### 1.8 `onboarding_state`

```sql
CREATE TYPE onboarding_state AS ENUM (
    'draft',        -- Template wird konfiguriert
    'active',       -- Läuft (MA hat angefangen)
    'completed',    -- Alle Pflicht-Tasks erledigt
    'overdue',      -- Mindestens 1 Pflicht-Task überfällig
    'cancelled'     -- Abgebrochen (z.B. Kündigung in Probezeit)
);
```

### 1.9 `onboarding_task_state`

```sql
CREATE TYPE onboarding_task_state AS ENUM (
    'pending',
    'in_progress',
    'done',
    'skipped',      -- Optional-Tasks können übersprungen werden
    'overdue'
);
```

### 1.10 `onboarding_assignee_role`

```sql
CREATE TYPE onboarding_assignee_role AS ENUM (
    'new_hire',     -- Neuer Mitarbeiter selbst
    'head_of',      -- Head of (direkte Vorgesetzte)
    'admin',        -- Admin (HR/GF)
    'it',           -- IT (Geräte, Zugänge)
    'buddy'         -- Buddy / Paten-MA
);
```

---

## 2. Neue Dimension-Tabellen

### 2.1 `dim_hr_document_type`

Katalog aller HR-Dokument-Typen (Reglemente, Verträge, Bescheinigungen).

```sql
CREATE TABLE dim_hr_document_type (
    code                    VARCHAR(60) PRIMARY KEY,
    label_de                VARCHAR(200) NOT NULL,
    requires_signature      BOOLEAN NOT NULL DEFAULT TRUE,
    requires_counter_sig    BOOLEAN NOT NULL DEFAULT TRUE,   -- Gegenzeichnung AG
    template_file           VARCHAR(500) NULL,               -- Master-Template-Pfad
    legal_ref               VARCHAR(300) NULL,
    supersedes_on_new       BOOLEAN NOT NULL DEFAULT TRUE,   -- alte Version → superseded
    retention_years         SMALLINT NOT NULL DEFAULT 10,
    category                VARCHAR(40) NOT NULL,            -- 'reglement' | 'vertrag' | 'bescheinigung' | 'other'
    sort_order              SMALLINT NOT NULL DEFAULT 100,
    active                  BOOLEAN NOT NULL DEFAULT TRUE,
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

**Seeds (13 Einträge):**

| code | label_de | sig | cat | retention | sort |
|------|----------|-----|-----|-----------|------|
| `EMPLOYMENT_CONTRACT` | Arbeitsvertrag | ✓ | vertrag | 10 | 10 |
| `GENERALIS_PROVISIO` | Generalis Provisio (Allg. Anstellungsbedingungen) | ✓ | reglement | 10 | 20 |
| `PROGRESSUS` | Progressus (Stellenbeschreibung) | ✓ | vertrag | 10 | 30 |
| `PRAEMIUM_VICTORIA` | Praemium Victoria (Provisionsvertrag) | ✓ | vertrag | 10 | 40 |
| `TEMPUS_PASSIO_365` | Tempus Passio 365 (Arbeitszeitenreglement) | ✓ | reglement | 10 | 50 |
| `LOCUS_EXTRA` | Locus Extra (Mobiles Arbeiten) | ✓ | reglement | 10 | 60 |
| `DATENSCHUTZ_ERKLAERUNG` | Datenschutzerklärung (DSG-Einwilligung) | ✓ | bescheinigung | 10 | 70 |
| `REFERENCE_LETTER` | Arbeitszeugnis | ✓ | bescheinigung | 10 | 80 |
| `INTERIM_REFERENCE` | Zwischenzeugnis | ✓ | bescheinigung | 10 | 90 |
| `SALARY_STATEMENT` | Lohnausweis | ✗ | bescheinigung | 10 | 100 |
| `AHV_CONFIRMATION` | AHV-Bestätigung Anmeldung | ✗ | bescheinigung | 5 | 110 |
| `PROBATION_EXTENSION` | Probezeit-Verlängerung (OR 335b Abs. 2) | ✓ | vertrag | 10 | 120 |
| `OTHER` | Sonstiges Dokument | ✗ | other | 10 | 999 |

> **Hinweis (Umlaute-Regel):** Reglements-Namen (Praemium Victoria, Generalis Provisio, Progressus, Tempus Passio 365, Locus Extra) sind lateinische Eigennamen — keine Umlaut-Substitute, keine Eindeutschung.

### 2.2 `dim_disciplinary_offense_type`

Delikt-Katalog für Verwarnungsgründe.

```sql
CREATE TABLE dim_disciplinary_offense_type (
    code                VARCHAR(60) PRIMARY KEY,
    label_de            VARCHAR(200) NOT NULL,
    category            VARCHAR(40) NOT NULL,   -- 'attendance' | 'conduct' | 'performance' | 'compliance' | 'integrity'
    typical_level       disciplinary_level NOT NULL,
    legal_ref           VARCHAR(200) NULL,
    active              BOOLEAN NOT NULL DEFAULT TRUE,
    sort_order          SMALLINT NOT NULL DEFAULT 100
);
```

**Seeds (13 Einträge):**

| code | label_de | cat | typical_level |
|------|----------|-----|---------------|
| `REPEATED_LATENESS` | Wiederholte Unpünktlichkeit | attendance | written_warning |
| `UNEXCUSED_ABSENCE` | Unentschuldigtes Fernbleiben | attendance | written_warning |
| `INSUBORDINATION` | Nichtbefolgung von Weisungen | conduct | written_warning |
| `MISCONDUCT_COLLEAGUE` | Unangemessenes Verhalten gegenüber Kollegen | conduct | verbal_warning |
| `MISCONDUCT_CLIENT` | Unangemessenes Verhalten gegenüber Kunden/Kandidaten | conduct | written_warning |
| `PERFORMANCE_DEFICIENCY` | Wiederholte Leistungsmängel | performance | verbal_warning |
| `TARGET_MISS_REPEATED` | Wiederholtes Verfehlen vereinbarter Ziele | performance | written_warning |
| `DATA_BREACH_INTERNAL` | Verletzung Datenschutz intern | compliance | formal_warning |
| `CONFIDENTIALITY_BREACH` | Bruch der Schweigepflicht (Kunden/Kandidaten) | compliance | formal_warning |
| `EXPENSE_FRAUD` | Manipulation Spesenabrechnung | integrity | final_warning |
| `COMPETITION_VIOLATION` | Verletzung Konkurrenzverbot | integrity | dismissal_immediate |
| `HARASSMENT` | Belästigung / Diskriminierung | conduct | dismissal_immediate |
| `OTHER` | Sonstiger Grund | conduct | verbal_warning |

### 2.3 `dim_onboarding_task_template_type`

Katalog wiederverwendbarer Onboarding-Aufgaben.

```sql
CREATE TABLE dim_onboarding_task_template_type (
    code                    VARCHAR(80) PRIMARY KEY,
    label_de                VARCHAR(200) NOT NULL,
    default_assignee        onboarding_assignee_role NOT NULL,
    default_due_offset_days SMALLINT NOT NULL DEFAULT 7,    -- Tage nach Eintrittsdatum
    is_mandatory            BOOLEAN NOT NULL DEFAULT TRUE,
    category                VARCHAR(40) NOT NULL,           -- 'admin' | 'it' | 'compliance' | 'social' | 'role'
    description             TEXT NULL,
    sort_order              SMALLINT NOT NULL DEFAULT 100,
    active                  BOOLEAN NOT NULL DEFAULT TRUE
);
```

**Seeds (18 Einträge):**

| code | label_de | assignee | offset_d | mandatory | cat |
|------|----------|----------|----------|-----------|-----|
| `WELCOME_MEETING` | Willkommensgespräch mit Head of | head_of | 1 | ✓ | social |
| `IT_EQUIPMENT_SETUP` | IT-Einrichtung (Laptop, Handy, Zugänge) | it | 1 | ✓ | it |
| `EMAIL_SETUP` | E-Mail + Kalender-Einrichtung (Outlook) | it | 1 | ✓ | it |
| `SIGN_GENERALIS_PROVISIO` | Generalis Provisio unterschreiben | new_hire | 1 | ✓ | compliance |
| `SIGN_PROGRESSUS` | Progressus (Stellenbeschreibung) unterschreiben | new_hire | 3 | ✓ | compliance |
| `SIGN_TEMPUS_PASSIO` | Tempus Passio 365 unterschreiben | new_hire | 3 | ✓ | compliance |
| `SIGN_LOCUS_EXTRA` | Locus Extra unterschreiben | new_hire | 3 | ✓ | compliance |
| `SIGN_PRAEMIUM_VICTORIA` | Praemium Victoria unterschreiben (Provisions-MA) | new_hire | 5 | ✗ | compliance |
| `SIGN_DATENSCHUTZ` | Datenschutzerklärung unterzeichnen | new_hire | 1 | ✓ | compliance |
| `AHV_REGISTRATION` | AHV-Anmeldung Treuhand | admin | 3 | ✓ | admin |
| `BADGE_KEY` | Büroschlüssel / Badge aushändigen | admin | 1 | ✓ | admin |
| `BANK_DETAILS` | Bankverbindung erfassen | new_hire | 3 | ✓ | admin |
| `CRM_INTRO` | CRM-Einführung (ARK CRM Demo) | head_of | 5 | ✓ | role |
| `TOOL_INTRO_ELEARN` | E-Learning Plattform Einführung | head_of | 7 | ✓ | role |
| `BUDDY_INTRO` | Vorstellung Buddy / Paten | buddy | 1 | ✗ | social |
| `TEAM_LUNCH` | Team-Mittagessen (erste Woche) | head_of | 5 | ✗ | social |
| `MONTH_1_REVIEW` | 1-Monats-Feedback-Gespräch | head_of | 30 | ✓ | role |
| `PROBATION_REVIEW` | Probezeit-Abschlussgespräch | head_of | 90 | ✓ | role |

---

## 3. Neue Fact-Tabellen

### 3.1 `fact_employment_contracts`

Arbeitsvertrag pro Mitarbeiter (1 aktiver Vertrag zur Zeit).

```sql
CREATE TABLE fact_employment_contracts (
    id                          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id                     UUID NOT NULL REFERENCES dim_user(id),
    employment_type             employment_type NOT NULL DEFAULT 'permanent',
    contract_state              contract_state NOT NULL DEFAULT 'draft',

    -- Laufzeit
    contract_start              DATE NOT NULL,
    contract_end                DATE NULL,          -- NULL bei unbefristet
    probation_months            SMALLINT NOT NULL DEFAULT 3,    -- OR 335b Abs. 1: max 3 Mt (Verlängerung bis 6 Mt)
    probation_end               DATE GENERATED ALWAYS AS
                                    (contract_start + (probation_months || ' months')::interval)::date STORED,
    notice_period_months        SMALLINT NOT NULL DEFAULT 1,    -- OR 335c
    notice_period_override      TEXT NULL,          -- Freitext bei Sonderregelung

    -- Lohn (Pensum/Stunden leben in Zeit-Modul fact_workday_target)
    salary_monthly_chf          NUMERIC(10,2) NULL, -- NULL bei Freelance
    salary_currency             CHAR(3) NOT NULL DEFAULT 'CHF',
    has_provisions              BOOLEAN NOT NULL DEFAULT FALSE,  -- Praemium-Victoria-Berechtigung

    -- Vertragsende
    terminated_at               DATE NULL,
    termination_reason          termination_reason NULL,
    termination_notice_given_at DATE NULL,
    termination_note            TEXT NULL,

    -- Admin
    created_by                  UUID NOT NULL REFERENCES dim_user(id),
    created_at                  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at                  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    audit_trail_jsonb           JSONB NOT NULL DEFAULT '[]'::jsonb,
    retention_until             DATE NULL,          -- gesetzt bei termination: +10 J

    CONSTRAINT chk_contract_dates CHECK (
        contract_end IS NULL OR contract_end > contract_start
    ),
    CONSTRAINT chk_probation_max CHECK (probation_months BETWEEN 0 AND 6),
    CONSTRAINT chk_termination_consistency CHECK (
        (contract_state = 'terminated' AND terminated_at IS NOT NULL AND termination_reason IS NOT NULL)
        OR contract_state <> 'terminated'
    )
);

CREATE INDEX idx_employment_user     ON fact_employment_contracts(user_id);
CREATE INDEX idx_employment_state    ON fact_employment_contracts(contract_state);
CREATE INDEX idx_employment_start    ON fact_employment_contracts(contract_start);

-- Nur 1 aktiver Vertrag pro MA zur gleichen Zeit
CREATE UNIQUE INDEX uq_employment_active ON fact_employment_contracts(user_id)
    WHERE contract_state = 'active';
```

### 3.2 `fact_employment_attachments`

Reglements-Signaturen + Vertragsbeilagen pro Mitarbeiter.

```sql
CREATE TABLE fact_employment_attachments (
    id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    contract_id             UUID NOT NULL REFERENCES fact_employment_contracts(id),
    user_id                 UUID NOT NULL REFERENCES dim_user(id),
    doc_type_code           VARCHAR(60) NOT NULL REFERENCES dim_hr_document_type(code),
    doc_state               hr_doc_state NOT NULL DEFAULT 'pending',

    -- Dokument
    file_path               VARCHAR(500) NULL,      -- generiertes PDF
    version_label           VARCHAR(40) NULL,        -- z.B. "v3 (2026-04)"
    valid_from              DATE NOT NULL DEFAULT CURRENT_DATE,
    valid_to                DATE NULL,

    -- Signaturen
    signed_by_ma_at         TIMESTAMPTZ NULL,       -- MA-Unterschrift
    signed_by_admin_at      TIMESTAMPTZ NULL,       -- Admin/GF-Gegenzeichnung
    signed_by_admin_user_id UUID NULL REFERENCES dim_user(id),

    -- Supersession
    superseded_by_id        UUID NULL REFERENCES fact_employment_attachments(id),
    superseded_at           TIMESTAMPTZ NULL,

    created_by              UUID NOT NULL REFERENCES dim_user(id),
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    audit_trail_jsonb       JSONB NOT NULL DEFAULT '[]'::jsonb,

    CONSTRAINT chk_sig_pending CHECK (
        (doc_state = 'signed'
         AND signed_by_ma_at IS NOT NULL
         AND signed_by_admin_at IS NOT NULL)
        OR doc_state <> 'signed'
    ),
    CONSTRAINT chk_supersession CHECK (
        (doc_state = 'superseded' AND superseded_by_id IS NOT NULL)
        OR doc_state <> 'superseded'
    )
);

CREATE INDEX idx_attachment_contract ON fact_employment_attachments(contract_id);
CREATE INDEX idx_attachment_user     ON fact_employment_attachments(user_id);
CREATE INDEX idx_attachment_type     ON fact_employment_attachments(doc_type_code);
CREATE INDEX idx_attachment_pending  ON fact_employment_attachments(doc_state)
    WHERE doc_state = 'pending';
```

### 3.3 `fact_disciplinary_records`

Verwarnungen und Disziplinarmassnahmen.

```sql
CREATE TABLE fact_disciplinary_records (
    id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id                 UUID NOT NULL REFERENCES dim_user(id),
    offense_type_code       VARCHAR(60) NOT NULL REFERENCES dim_disciplinary_offense_type(code),
    disciplinary_level      disciplinary_level NOT NULL,
    disciplinary_state      disciplinary_state NOT NULL DEFAULT 'draft',

    -- Sachverhalt
    incident_date           DATE NOT NULL,
    incident_description    TEXT NOT NULL,
    file_path               VARCHAR(500) NULL,          -- PDF der schriftlichen Verwarnung

    -- Eskalations-Tracking
    previous_record_id      UUID NULL REFERENCES fact_disciplinary_records(id),
    suggested_next_level    disciplinary_level NULL,    -- berechnet per Trigger

    -- Zustellung
    issued_at               TIMESTAMPTZ NULL,
    issued_by               UUID NULL REFERENCES dim_user(id),
    acknowledged_at         TIMESTAMPTZ NULL,           -- MA-Unterschrift / Kenntnisnahme
    acknowledged_note       TEXT NULL,                  -- MA-Stellungnahme

    -- Auflösung
    resolved_at             TIMESTAMPTZ NULL,
    resolved_note           TEXT NULL,
    resolved_by             UUID NULL REFERENCES dim_user(id),

    -- Archivierung (revDSG: nach 2 J ohne Folgen löschen — OR-Empfehlung)
    archived_at             TIMESTAMPTZ NULL,
    retention_until         DATE NULL,

    created_by              UUID NOT NULL REFERENCES dim_user(id),
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    audit_trail_jsonb       JSONB NOT NULL DEFAULT '[]'::jsonb,

    CONSTRAINT chk_issued_consistency CHECK (
        (disciplinary_state IN ('issued','acknowledged','disputed','resolved')
         AND issued_at IS NOT NULL AND issued_by IS NOT NULL)
        OR disciplinary_state NOT IN ('issued','acknowledged','disputed','resolved')
    ),
    CONSTRAINT chk_no_self_previous CHECK (
        previous_record_id IS NULL OR previous_record_id <> id
    )
);

CREATE INDEX idx_disciplinary_user     ON fact_disciplinary_records(user_id);
CREATE INDEX idx_disciplinary_state    ON fact_disciplinary_records(disciplinary_state);
CREATE INDEX idx_disciplinary_open     ON fact_disciplinary_records(user_id, disciplinary_state)
    WHERE disciplinary_state IN ('draft','issued','disputed');
CREATE INDEX idx_disciplinary_incident ON fact_disciplinary_records(incident_date);
```

### 3.4 `fact_probation_milestones`

Probezeit-Gespräche und Meilensteine.

```sql
CREATE TABLE fact_probation_milestones (
    id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id                 UUID NOT NULL REFERENCES dim_user(id),
    contract_id             UUID NOT NULL REFERENCES fact_employment_contracts(id),
    milestone_type          probation_milestone_type NOT NULL,

    -- Planung
    scheduled_date          DATE NOT NULL,
    conducted_at            TIMESTAMPTZ NULL,
    conducted_by            UUID NULL REFERENCES dim_user(id),

    -- Ergebnis
    outcome_note            TEXT NULL,          -- Gesprächsnotiz (vertraulich)
    outcome_doc_path        VARCHAR(500) NULL,  -- PDF-Protokoll
    passed                  BOOLEAN NULL,       -- NULL = noch offen, TRUE/FALSE nach Gespräch

    -- Verlängerung (nur bei milestone_type = 'probation_extended')
    extended_to_date        DATE NULL,          -- neues Probezeit-Ende (max 6 Mt total)
    extension_reason        TEXT NULL,

    created_by              UUID NOT NULL REFERENCES dim_user(id),
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    audit_trail_jsonb       JSONB NOT NULL DEFAULT '[]'::jsonb,

    CONSTRAINT chk_extended_fields CHECK (
        (milestone_type = 'probation_extended' AND extended_to_date IS NOT NULL)
        OR milestone_type <> 'probation_extended'
    ),
    CONSTRAINT chk_passed_conducted CHECK (
        (passed IS NOT NULL AND conducted_at IS NOT NULL)
        OR passed IS NULL
    )
);

CREATE INDEX idx_probation_user     ON fact_probation_milestones(user_id);
CREATE INDEX idx_probation_contract ON fact_probation_milestones(contract_id);
CREATE INDEX idx_probation_open     ON fact_probation_milestones(user_id, scheduled_date)
    WHERE conducted_at IS NULL;
```

### 3.5 `fact_onboarding_templates`

Wiederverwendbare Onboarding-Checklisten (nach Rollen-Typ).

```sql
CREATE TABLE fact_onboarding_templates (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name                VARCHAR(200) NOT NULL,
    description         TEXT NULL,
    target_role_code    VARCHAR(10) NULL REFERENCES dim_user(role_code),   -- NULL = generisch
    is_default          BOOLEAN NOT NULL DEFAULT FALSE,
    active              BOOLEAN NOT NULL DEFAULT TRUE,
    created_by          UUID NOT NULL REFERENCES dim_user(id),
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    audit_trail_jsonb   JSONB NOT NULL DEFAULT '[]'::jsonb,

    CONSTRAINT chk_default_unique UNIQUE NULLS NOT DISTINCT (is_default, target_role_code)
);

CREATE INDEX idx_onb_template_role ON fact_onboarding_templates(target_role_code);
```

**Seeds (3 Standard-Templates):**

| name | target_role | is_default |
|------|-------------|-----------|
| Onboarding Mitarbeiter (Standard) | MA | ✓ |
| Onboarding Head of | HEAD | ✓ |
| Onboarding Admin/Backoffice | ADMIN | ✓ |

### 3.6 `fact_onboarding_template_tasks`

Aufgaben einer Vorlage (geordnete Checkliste).

```sql
CREATE TABLE fact_onboarding_template_tasks (
    id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    template_id             UUID NOT NULL REFERENCES fact_onboarding_templates(id) ON DELETE CASCADE,
    task_type_code          VARCHAR(80) NULL REFERENCES dim_onboarding_task_template_type(code),
    custom_label            VARCHAR(200) NULL,          -- wenn kein task_type_code
    description             TEXT NULL,
    assignee_role           onboarding_assignee_role NOT NULL DEFAULT 'new_hire',
    due_offset_days         SMALLINT NOT NULL DEFAULT 7,
    is_mandatory            BOOLEAN NOT NULL DEFAULT TRUE,
    sort_order              SMALLINT NOT NULL DEFAULT 100,
    active                  BOOLEAN NOT NULL DEFAULT TRUE,
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_label_or_type CHECK (
        task_type_code IS NOT NULL OR custom_label IS NOT NULL
    )
);

CREATE INDEX idx_template_tasks_tmpl ON fact_onboarding_template_tasks(template_id, sort_order);
```

### 3.7 `fact_onboarding_instances`

Onboarding-Prozess pro Mitarbeiter (instantiiert aus Template).

```sql
CREATE TABLE fact_onboarding_instances (
    id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id                 UUID NOT NULL REFERENCES dim_user(id),
    contract_id             UUID NOT NULL REFERENCES fact_employment_contracts(id),
    template_id             UUID NULL REFERENCES fact_onboarding_templates(id),
    onboarding_state        onboarding_state NOT NULL DEFAULT 'draft',

    -- Timing
    entry_date              DATE NOT NULL,                  -- = contract_start
    target_complete_date    DATE NOT NULL,                  -- entry_date + 90 Tage (Probezeit)

    -- Probezeit-Abschluss via fact_probation_milestones
    probation_milestone_id  UUID NULL REFERENCES fact_probation_milestones(id),

    -- Progress (denormalisiert, per Trigger aktualisiert)
    total_tasks             SMALLINT NOT NULL DEFAULT 0,
    done_tasks              SMALLINT NOT NULL DEFAULT 0,
    overdue_tasks           SMALLINT NOT NULL DEFAULT 0,

    created_by              UUID NOT NULL REFERENCES dim_user(id),
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    audit_trail_jsonb       JSONB NOT NULL DEFAULT '[]'::jsonb,

    CONSTRAINT chk_progress CHECK (
        done_tasks <= total_tasks AND overdue_tasks <= total_tasks
    )
);

CREATE INDEX idx_onb_instance_user   ON fact_onboarding_instances(user_id);
CREATE INDEX idx_onb_instance_state  ON fact_onboarding_instances(onboarding_state);
CREATE INDEX idx_onb_instance_active ON fact_onboarding_instances(user_id, entry_date)
    WHERE onboarding_state IN ('active','overdue');

-- Max 1 aktives Onboarding pro MA
CREATE UNIQUE INDEX uq_onb_active_per_user ON fact_onboarding_instances(user_id)
    WHERE onboarding_state IN ('active','overdue');
```

### 3.8 `fact_onboarding_instance_tasks`

Einzelne Aufgaben eines laufenden Onboarding-Prozesses.

```sql
CREATE TABLE fact_onboarding_instance_tasks (
    id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    instance_id             UUID NOT NULL REFERENCES fact_onboarding_instances(id) ON DELETE CASCADE,
    template_task_id        UUID NULL REFERENCES fact_onboarding_template_tasks(id),
    task_type_code          VARCHAR(80) NULL REFERENCES dim_onboarding_task_template_type(code),
    label                   VARCHAR(200) NOT NULL,
    description             TEXT NULL,
    assignee_role           onboarding_assignee_role NOT NULL,
    assigned_to_user_id     UUID NULL REFERENCES dim_user(id),
    is_mandatory            BOOLEAN NOT NULL DEFAULT TRUE,
    task_state              onboarding_task_state NOT NULL DEFAULT 'pending',

    -- Timing
    due_date                DATE NOT NULL,
    started_at              TIMESTAMPTZ NULL,
    completed_at            TIMESTAMPTZ NULL,
    completed_by            UUID NULL REFERENCES dim_user(id),
    completion_note         TEXT NULL,

    sort_order              SMALLINT NOT NULL DEFAULT 100,
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_done_consistency CHECK (
        (task_state = 'done' AND completed_at IS NOT NULL AND completed_by IS NOT NULL)
        OR task_state <> 'done'
    )
);

CREATE INDEX idx_onb_tasks_instance ON fact_onboarding_instance_tasks(instance_id, sort_order);
CREATE INDEX idx_onb_tasks_assignee ON fact_onboarding_instance_tasks(assigned_to_user_id)
    WHERE task_state = 'pending';
CREATE INDEX idx_onb_tasks_overdue  ON fact_onboarding_instance_tasks(due_date)
    WHERE task_state IN ('pending','in_progress');
```

---

## 4. Views

### 4.1 `v_hr_active_employees`

```sql
CREATE VIEW v_hr_active_employees AS
SELECT
    u.id AS user_id,
    u.label_de AS name,
    u.role_code,
    ec.id AS contract_id,
    ec.contract_start,
    ec.employment_type,
    ec.salary_monthly_chf,
    ec.has_provisions,
    ec.probation_end,
    CASE WHEN ec.probation_end >= CURRENT_DATE THEN TRUE ELSE FALSE END AS in_probation,
    ec.notice_period_months
FROM dim_user u
JOIN fact_employment_contracts ec ON ec.user_id = u.id
    AND ec.contract_state = 'active'
WHERE u.active = TRUE;
```

### 4.2 `v_onboarding_progress`

```sql
CREATE VIEW v_onboarding_progress AS
SELECT
    oi.id AS instance_id,
    oi.user_id,
    u.label_de AS employee_name,
    oi.entry_date,
    oi.target_complete_date,
    oi.onboarding_state,
    oi.total_tasks,
    oi.done_tasks,
    oi.overdue_tasks,
    oi.total_tasks - oi.done_tasks AS remaining_tasks,
    CASE
        WHEN oi.total_tasks = 0 THEN 0
        ELSE ROUND(oi.done_tasks::numeric / oi.total_tasks * 100)
    END AS progress_pct,
    pm.conducted_at AS probation_completed_at,
    pm.passed       AS probation_passed,
    ec.probation_end
FROM fact_onboarding_instances oi
JOIN dim_user u ON u.id = oi.user_id
JOIN fact_employment_contracts ec ON ec.id = oi.contract_id
LEFT JOIN fact_probation_milestones pm ON pm.id = oi.probation_milestone_id
WHERE oi.onboarding_state IN ('active','overdue','draft');
```

### 4.3 `v_disciplinary_summary`

```sql
CREATE VIEW v_disciplinary_summary AS
SELECT
    dr.user_id,
    u.label_de AS employee_name,
    COUNT(*) AS total_records,
    COUNT(*) FILTER (WHERE dr.disciplinary_state IN ('issued','disputed')) AS open_records,
    MAX(dr.disciplinary_level::text)::disciplinary_level AS highest_level,
    MAX(dr.incident_date) AS last_incident_date,
    BOOL_OR(dr.disciplinary_state = 'disputed') AS has_dispute
FROM fact_disciplinary_records dr
JOIN dim_user u ON u.id = dr.user_id
WHERE dr.disciplinary_state NOT IN ('resolved','archived')
GROUP BY dr.user_id, u.label_de;
```

### 4.4 `v_pending_signatures`

```sql
CREATE VIEW v_pending_signatures AS
SELECT
    ea.id AS attachment_id,
    ea.user_id,
    u.label_de AS employee_name,
    ea.doc_type_code,
    dt.label_de AS doc_label,
    ea.doc_state,
    ea.created_at,
    CASE
        WHEN ea.signed_by_ma_at IS NULL THEN 'MA-Unterschrift ausstehend'
        WHEN ea.signed_by_admin_at IS NULL THEN 'Admin-Gegenzeichnung ausstehend'
        ELSE 'Unbekannt'
    END AS pending_reason,
    (CURRENT_DATE - ea.created_at::date) AS days_pending
FROM fact_employment_attachments ea
JOIN dim_user u ON u.id = ea.user_id
JOIN dim_hr_document_type dt ON dt.code = ea.doc_type_code
WHERE ea.doc_state = 'pending';
```

---

## 5. Trigger-Funktionen + Bindungen

### 5.1 `fn_append_audit_trail()` — generischer Audit-Diff-Trigger

```sql
CREATE OR REPLACE FUNCTION fn_append_audit_trail()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
DECLARE
    v_changed_fields JSONB;
    v_audit_entry   JSONB;
BEGIN
    SELECT jsonb_object_agg(key, value)
    INTO v_changed_fields
    FROM jsonb_each(to_jsonb(NEW))
    WHERE key NOT IN ('audit_trail_jsonb', 'updated_at')
      AND (to_jsonb(OLD) ->> key) IS DISTINCT FROM value::text;

    IF v_changed_fields IS NULL OR v_changed_fields = '{}'::jsonb THEN
        RETURN NEW;
    END IF;

    v_audit_entry := jsonb_build_object(
        'at',  NOW(),
        'by',  current_setting('app.current_user_id', TRUE),
        'op',  TG_OP,
        'diff', v_changed_fields
    );

    NEW.audit_trail_jsonb := NEW.audit_trail_jsonb || v_audit_entry;
    NEW.updated_at := NOW();
    RETURN NEW;
END;
$$;

-- Bindungen auf alle HR-Fact-Tabellen
CREATE TRIGGER trg_employment_contract_audit
    BEFORE UPDATE ON fact_employment_contracts
    FOR EACH ROW EXECUTE FUNCTION fn_append_audit_trail();

CREATE TRIGGER trg_employment_attachment_audit
    BEFORE UPDATE ON fact_employment_attachments
    FOR EACH ROW EXECUTE FUNCTION fn_append_audit_trail();

CREATE TRIGGER trg_disciplinary_audit
    BEFORE UPDATE ON fact_disciplinary_records
    FOR EACH ROW EXECUTE FUNCTION fn_append_audit_trail();

CREATE TRIGGER trg_probation_milestone_audit
    BEFORE UPDATE ON fact_probation_milestones
    FOR EACH ROW EXECUTE FUNCTION fn_append_audit_trail();

CREATE TRIGGER trg_onboarding_instance_audit
    BEFORE UPDATE ON fact_onboarding_instances
    FOR EACH ROW EXECUTE FUNCTION fn_append_audit_trail();
```

### 5.2 `fn_onboarding_task_state_change()` — Fortschritts-Counter

```sql
CREATE OR REPLACE FUNCTION fn_onboarding_task_state_change()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
DECLARE
    v_total     SMALLINT;
    v_done      SMALLINT;
    v_overdue   SMALLINT;
    v_new_state onboarding_state;
BEGIN
    SELECT
        COUNT(*),
        COUNT(*) FILTER (WHERE task_state = 'done'),
        COUNT(*) FILTER (WHERE task_state = 'overdue' AND is_mandatory)
    INTO v_total, v_done, v_overdue
    FROM fact_onboarding_instance_tasks
    WHERE instance_id = NEW.instance_id;

    IF v_done >= v_total THEN
        v_new_state := 'completed';
    ELSIF v_overdue > 0 THEN
        v_new_state := 'overdue';
    ELSE
        v_new_state := 'active';
    END IF;

    UPDATE fact_onboarding_instances
    SET total_tasks      = v_total,
        done_tasks       = v_done,
        overdue_tasks    = v_overdue,
        onboarding_state = v_new_state,
        updated_at       = NOW()
    WHERE id = NEW.instance_id;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_onboarding_task_state_changed
    AFTER INSERT OR UPDATE OF task_state ON fact_onboarding_instance_tasks
    FOR EACH ROW EXECUTE FUNCTION fn_onboarding_task_state_change();
```

### 5.3 `fn_disciplinary_suggest_escalation()` — Eskalations-Vorschlag

```sql
CREATE OR REPLACE FUNCTION fn_disciplinary_suggest_escalation()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
    NEW.suggested_next_level := CASE NEW.disciplinary_level
        WHEN 'verbal_warning'   THEN 'written_warning'::disciplinary_level
        WHEN 'written_warning'  THEN 'formal_warning'::disciplinary_level
        WHEN 'formal_warning'   THEN 'final_warning'::disciplinary_level
        WHEN 'final_warning'    THEN 'suspension'::disciplinary_level
        WHEN 'suspension'       THEN 'dismissal_immediate'::disciplinary_level
        ELSE NULL
    END;
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_disciplinary_escalation
    BEFORE INSERT ON fact_disciplinary_records
    FOR EACH ROW EXECUTE FUNCTION fn_disciplinary_suggest_escalation();
```

### 5.4 `fn_employment_contract_termination()` — Retention-Datum

```sql
CREATE OR REPLACE FUNCTION fn_employment_contract_termination()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
    IF NEW.contract_state = 'terminated' AND OLD.contract_state <> 'terminated' THEN
        NEW.retention_until := COALESCE(NEW.terminated_at, CURRENT_DATE) + INTERVAL '10 years';
    END IF;
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_employment_contract_termination
    BEFORE UPDATE OF contract_state ON fact_employment_contracts
    FOR EACH ROW
    WHEN (NEW.contract_state = 'terminated' AND OLD.contract_state <> 'terminated')
    EXECUTE FUNCTION fn_employment_contract_termination();
```

---

## 6. Row-Level Security (RLS)

### 6.1 Helper-Funktionen

```sql
CREATE OR REPLACE FUNCTION fn_current_user_id()
RETURNS UUID LANGUAGE sql STABLE AS $$
    SELECT id FROM dim_user
    WHERE auth_uid = current_setting('app.current_user_id', TRUE)::uuid
    LIMIT 1;
$$;

CREATE OR REPLACE FUNCTION fn_current_role_code()
RETURNS VARCHAR(10) LANGUAGE sql STABLE AS $$
    SELECT role_code FROM dim_user WHERE id = fn_current_user_id() LIMIT 1;
$$;

CREATE OR REPLACE FUNCTION fn_team_user_ids()
RETURNS UUID[] LANGUAGE sql STABLE AS $$
    SELECT ARRAY(
        SELECT id FROM dim_user
        WHERE team_lead_id = fn_current_user_id()
           OR id = fn_current_user_id()
    );
$$;
```

### 6.2 RLS aktivieren

```sql
ALTER TABLE fact_employment_contracts      ENABLE ROW LEVEL SECURITY;
ALTER TABLE fact_employment_attachments    ENABLE ROW LEVEL SECURITY;
ALTER TABLE fact_disciplinary_records      ENABLE ROW LEVEL SECURITY;
ALTER TABLE fact_probation_milestones      ENABLE ROW LEVEL SECURITY;
ALTER TABLE fact_onboarding_instances      ENABLE ROW LEVEL SECURITY;
ALTER TABLE fact_onboarding_instance_tasks ENABLE ROW LEVEL SECURITY;
```

### 6.3 RLS-Policies `fact_employment_contracts`

```sql
CREATE POLICY pol_contract_ma_read ON fact_employment_contracts
    FOR SELECT TO ark_role_ma
    USING (user_id = fn_current_user_id());

CREATE POLICY pol_contract_head_read ON fact_employment_contracts
    FOR SELECT TO ark_role_head
    USING (user_id = ANY(fn_team_user_ids()));

CREATE POLICY pol_contract_admin_all ON fact_employment_contracts
    FOR ALL TO ark_role_admin
    USING (TRUE) WITH CHECK (TRUE);

CREATE POLICY pol_contract_bo_read ON fact_employment_contracts
    FOR SELECT TO ark_role_bo
    USING (TRUE);
```

### 6.4 RLS-Policies `fact_employment_attachments`

```sql
CREATE POLICY pol_attachment_ma_read ON fact_employment_attachments
    FOR SELECT TO ark_role_ma
    USING (user_id = fn_current_user_id());

CREATE POLICY pol_attachment_head_read ON fact_employment_attachments
    FOR SELECT TO ark_role_head
    USING (user_id = ANY(fn_team_user_ids()));

CREATE POLICY pol_attachment_admin_all ON fact_employment_attachments
    FOR ALL TO ark_role_admin
    USING (TRUE) WITH CHECK (TRUE);

CREATE POLICY pol_attachment_bo_read ON fact_employment_attachments
    FOR SELECT TO ark_role_bo
    USING (TRUE);
```

### 6.5 RLS-Policies `fact_disciplinary_records`

```sql
-- MA: nur Einträge mit state >= 'issued' (vertraulich bis Zustellung)
CREATE POLICY pol_disciplinary_ma_read ON fact_disciplinary_records
    FOR SELECT TO ark_role_ma
    USING (
        user_id = fn_current_user_id()
        AND disciplinary_state IN ('issued','acknowledged','disputed')
    );

CREATE POLICY pol_disciplinary_head_read ON fact_disciplinary_records
    FOR SELECT TO ark_role_head
    USING (user_id = ANY(fn_team_user_ids()));

CREATE POLICY pol_disciplinary_head_write ON fact_disciplinary_records
    FOR INSERT TO ark_role_head
    WITH CHECK (user_id = ANY(fn_team_user_ids()));

CREATE POLICY pol_disciplinary_head_update ON fact_disciplinary_records
    FOR UPDATE TO ark_role_head
    USING (user_id = ANY(fn_team_user_ids()));

CREATE POLICY pol_disciplinary_admin_all ON fact_disciplinary_records
    FOR ALL TO ark_role_admin
    USING (TRUE) WITH CHECK (TRUE);

CREATE POLICY pol_disciplinary_bo_read ON fact_disciplinary_records
    FOR SELECT TO ark_role_bo
    USING (TRUE);
```

### 6.6 RLS-Policies `fact_probation_milestones`

```sql
CREATE POLICY pol_probation_ma_read ON fact_probation_milestones
    FOR SELECT TO ark_role_ma
    USING (user_id = fn_current_user_id());

CREATE POLICY pol_probation_head_all ON fact_probation_milestones
    FOR ALL TO ark_role_head
    USING (user_id = ANY(fn_team_user_ids()))
    WITH CHECK (user_id = ANY(fn_team_user_ids()));

CREATE POLICY pol_probation_admin_all ON fact_probation_milestones
    FOR ALL TO ark_role_admin
    USING (TRUE) WITH CHECK (TRUE);
```

### 6.7 RLS-Policies `fact_onboarding_instances`

```sql
CREATE POLICY pol_onboarding_inst_ma_read ON fact_onboarding_instances
    FOR SELECT TO ark_role_ma
    USING (user_id = fn_current_user_id());

CREATE POLICY pol_onboarding_inst_head_all ON fact_onboarding_instances
    FOR ALL TO ark_role_head
    USING (user_id = ANY(fn_team_user_ids()))
    WITH CHECK (user_id = ANY(fn_team_user_ids()));

CREATE POLICY pol_onboarding_inst_admin_all ON fact_onboarding_instances
    FOR ALL TO ark_role_admin
    USING (TRUE) WITH CHECK (TRUE);

CREATE POLICY pol_onboarding_inst_bo_read ON fact_onboarding_instances
    FOR SELECT TO ark_role_bo
    USING (TRUE);
```

### 6.8 RLS-Policies `fact_onboarding_instance_tasks`

```sql
CREATE POLICY pol_onboarding_task_ma_read ON fact_onboarding_instance_tasks
    FOR SELECT TO ark_role_ma
    USING (
        instance_id IN (
            SELECT id FROM fact_onboarding_instances WHERE user_id = fn_current_user_id()
        )
    );

CREATE POLICY pol_onboarding_task_head_all ON fact_onboarding_instance_tasks
    FOR ALL TO ark_role_head
    USING (
        instance_id IN (
            SELECT id FROM fact_onboarding_instances
            WHERE user_id = ANY(fn_team_user_ids())
        )
    );

CREATE POLICY pol_onboarding_task_admin_all ON fact_onboarding_instance_tasks
    FOR ALL TO ark_role_admin
    USING (TRUE) WITH CHECK (TRUE);

CREATE POLICY pol_onboarding_task_bo_read ON fact_onboarding_instance_tasks
    FOR SELECT TO ark_role_bo
    USING (TRUE);
```

---

## 7. Retention-Policy

| Tabelle | Retention | Rechtsgrundlage |
|---------|-----------|-----------------|
| `fact_employment_contracts` | 10 J post Vertragsende | OR Art. 127/128 |
| `fact_employment_attachments` | 10 J post Vertragsende | Beweislast |
| `fact_disciplinary_records` (ohne Folgen) | 2 J post Archivierung | EDÖB-Empfehlung |
| `fact_disciplinary_records` (mit Kündigung) | 10 J | OR 339/341 |
| `fact_probation_milestones.outcome_note` | 2 J post Probezeit | revDSG Art. 25 |
| `fact_onboarding_instances` | 5 J post Austritt | Compliance-Nachweis |

Retention-Cleanup via `hr-retention.worker.ts` (Backend-Patch v2.10 §2).

---

## 8. Migration-Reihenfolge

1. `CREATE EXTENSION IF NOT EXISTS pgcrypto` (falls noch nicht vorhanden)
2. CREATE TYPE × 10 (ENUMs §1.1–1.10)
3. CREATE TABLE `dim_hr_document_type` + Seeds
4. CREATE TABLE `dim_disciplinary_offense_type` + Seeds
5. CREATE TABLE `dim_onboarding_task_template_type` + Seeds
6. CREATE TABLE `fact_employment_contracts` + Indizes
7. CREATE TABLE `fact_employment_attachments` + Indizes
8. CREATE TABLE `fact_disciplinary_records` + Indizes
9. CREATE TABLE `fact_probation_milestones` + Indizes
10. CREATE TABLE `fact_onboarding_templates` + Seeds
11. CREATE TABLE `fact_onboarding_template_tasks` + Index
12. CREATE TABLE `fact_onboarding_instances` + Indizes
13. CREATE TABLE `fact_onboarding_instance_tasks` + Indizes
14. CREATE VIEW × 4 (§4)
15. CREATE FUNCTION + TRIGGER `fn_append_audit_trail` (§5.1)
16. CREATE FUNCTION + TRIGGER `fn_onboarding_task_state_change` (§5.2)
17. CREATE FUNCTION + TRIGGER `fn_disciplinary_suggest_escalation` (§5.3)
18. CREATE FUNCTION + TRIGGER `fn_employment_contract_termination` (§5.4)
19. Helper-Funktionen `fn_current_user_id`, `fn_current_role_code`, `fn_team_user_ids` (§6.1)
20. ALTER TABLE ENABLE ROW LEVEL SECURITY × 6 (§6.2)
21. CREATE POLICY × 22 (§6.3–6.8)

---

## 9. Rollback

```sql
-- (nur wenn Tabellen leer / in Testumgebung)
DROP VIEW  IF EXISTS v_pending_signatures, v_disciplinary_summary,
                      v_onboarding_progress, v_hr_active_employees CASCADE;
DROP TABLE IF EXISTS fact_onboarding_instance_tasks, fact_onboarding_instances,
                      fact_onboarding_template_tasks, fact_onboarding_templates,
                      fact_probation_milestones, fact_disciplinary_records,
                      fact_employment_attachments, fact_employment_contracts CASCADE;
DROP TABLE IF EXISTS dim_onboarding_task_template_type,
                      dim_disciplinary_offense_type, dim_hr_document_type CASCADE;
DROP TYPE  IF EXISTS onboarding_assignee_role, onboarding_task_state, onboarding_state,
                      disciplinary_state, disciplinary_level, probation_milestone_type,
                      hr_doc_state, termination_reason, employment_type, contract_state CASCADE;
```

---

## 10. SYNC-IMPACT

| Grundlagen-Datei | Änderung |
|------------------|----------|
| `ARK_BACKEND_ARCHITECTURE_v2_9.md` | +HR-Endpoints + HR-Worker + HR-Events → **Backend-Patch v2.10** |
| `ARK_STAMMDATEN_EXPORT_v1_6.md` | +HR-Stammdaten-Kataloge → **Stammdaten-Patch v1.7** |
| `ARK_FRONTEND_FREEZE_v1_14.md` | +HR-Routing + Sidebar + Drawer-Inventar → **FE-Patch v1.15** |
| `ARK_GESAMTSYSTEM_UEBERSICHT_v1_5.md` | Changelog-Eintrag „HR-Modul v1.8" (Folge-Patch) |

---

**Ende v1.8.** Apply-Reihenfolge: DB-Patch v1.8 → Backend-Patch v2.10 → Stammdaten-Patch v1.7 → FE-Patch v1.15.
