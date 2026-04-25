---
title: "ARK HR-Modul · Schema v0.1"
type: spec
module: hr
version: 0.1
created: 2026-04-25
updated: 2026-04-25
status: draft
sources: [
  "mockups/ERP Tools/hr/hr.html",
  "mockups/ERP Tools/hr/hr-dashboard.html",
  "mockups/ERP Tools/hr/hr-list.html",
  "mockups/ERP Tools/hr/hr-mitarbeiter-self.html",
  "mockups/ERP Tools/hr/hr-warnings-disciplinary.html",
  "mockups/ERP Tools/hr/hr-onboarding-editor.html",
  "mockups/ERP Tools/hr/hr-absence-calendar.html",
  "mockups/ERP Tools/hr/hr-provisionsvertrag-editor.html",
  "mockups/ERP Tools/hr/hr-academy-dashboard.html",
  "specs/ARK_ZEIT_SCHEMA_v0_1.md"
]
tags: [spec, schema, hr, employment, onboarding, disciplinary, probezeit, rls]
---

# ARK HR-Modul · Database Schema v0.1

**Scope:** PostgreSQL-Schema für das HR-ERP-Modul. Deckt Arbeitsverträge, HR-Dokumente, Onboarding-Checklisten, Probezeit-Tracking, Verwarnungen & Disziplinarmassnahmen. Absenzenverwaltung lebt in `ARK_ZEIT_SCHEMA_v0_1.md` (FK-Referenzen hier).

**Grundlagen-Sync erforderlich:** `ARK_STAMMDATEN_EXPORT_v1_5.md` · `ARK_DATABASE_SCHEMA_v1_5.md` · `ARK_BACKEND_ARCHITECTURE_v2_7.md` · `ARK_FRONTEND_FREEZE_v1_12.md`

**Abhängigkeiten:**
- `dim_user` aus Basis-Schema (id, role_code, label_de, team_id, employment_start)
- `fact_absence` aus `ARK_ZEIT_SCHEMA_v0_1.md` (Absenz-Kalender greift auf diese Tabelle zu)
- `fact_employment_contracts` definiert `contract_start` → `dim_user.employment_start` Sync per Trigger

**Legal-Basis:**
- OR Art. 319–362 (Einzelarbeitsvertrag), Art. 321 (Sorgfalt), Art. 336 (Kündigung)
- OR Art. 335c (Kündigungsfristen), Art. 337c (fristlose Kündigung)
- OR Art. 328 (Persönlichkeitsschutz), Art. 328a (Datenschutz)
- revDSG Art. 25 ff. (Auskunftsrecht), Art. 5 Ziff. 2 (besondere Personendaten)
- ArG Art. 6 (Gesundheitsschutz), Art. 38 (Betriebsordnung)
- Arkadium-Reglemente: Generalis Provisio, Progressus, Praemium Victoria, Locus Extra, Tempus Passio 365

---

## 1. Schema-Prinzipien

1. **UUID-Primary-Keys** durchgängig (`gen_random_uuid()`).
2. **ENUMs** (nicht VARCHAR) für Status/Typ-Felder — DB-seitige Integrität.
3. **`audit_trail_jsonb`** append-only auf allen mutierten Fact-Tabellen.
4. **`retention_until DATE`** auf sensiblen Tabellen (DSG-Löschjob).
5. **RLS ab v0.2**: Row-Level Security für alle `fact_hr_*`-Tabellen (MA sieht nur eigene Daten, HEAD sieht Team, ADMIN sieht alles).
6. **Keine Lohn-Rohdaten im HR-Schema**: Salärwerte werden in `fact_employment_contracts.salary_monthly_chf` gespeichert, nicht redundant in Absenz- oder Disziplinar-Tabellen.
7. **Dokument-Files** als `VARCHAR(500)` Pfad/URL — kein Binary in DB.
8. **Soft-Delete** via `archived_at TIMESTAMPTZ` statt `DELETE` — Audit-Compliance.

---

## 2. PostgreSQL Extensions

```sql
CREATE EXTENSION IF NOT EXISTS pgcrypto;     -- gen_random_uuid()
```

---

## 3. ENUM-Types

```sql
-- Vertrags-Lifecycle
CREATE TYPE contract_state AS ENUM (
    'draft',        -- Entwurf, noch nicht unterschrieben
    'pending_sig',  -- Wartet auf Unterschriften
    'active',       -- Gültig, in Kraft
    'terminated',   -- Gekündigt (Frist läuft oder abgelaufen)
    'expired',      -- Befristeter Vertrag ausgelaufen
    'voided'        -- Ungültig / Fehler
);

-- Anstellungsart
CREATE TYPE employment_type AS ENUM (
    'permanent',    -- Unbefristet
    'fixed_term',   -- Befristet
    'intern',       -- Praktikum
    'freelance'     -- Freie Mitarbeit (keine AHV-Pflicht über Arkadium)
);

-- Vertragsende-Grund
CREATE TYPE termination_reason AS ENUM (
    'resignation',          -- Kündigung durch MA
    'dismissal',            -- Kündigung durch AG (ordentlich)
    'dismissal_immediate',  -- Fristlose Entlassung (OR 337)
    'mutual_agreement',     -- Auflösung im gegenseitigen Einvernehmen
    'end_fixed_term',       -- Befristung ausgelaufen
    'retirement',           -- Pensionierung
    'death'                 -- Todesfall
);

-- HR-Dokument-Status (pro signiertem Dokument)
CREATE TYPE hr_doc_state AS ENUM (
    'pending',      -- Dokument generiert, Unterschrift ausstehend
    'signed',       -- Beidseitig unterschrieben
    'superseded',   -- Von neuerer Version ersetzt
    'revoked'       -- Widerrufen
);

-- Probezeit-Milestone-Typ
CREATE TYPE probation_milestone_type AS ENUM (
    'month_1_review',       -- 1-Monats-Gespräch
    'month_2_review',       -- 2-Monats-Gespräch (optional)
    'probation_end',        -- Probezeit-Abschluss
    'probation_extended',   -- Probezeit verlängert (OR 335b Abs. 2)
    'probation_failed'      -- Probezeit nicht bestanden (Kündigung in Probezeit)
);

-- Disziplinar-Kategorie (Escalation Path)
CREATE TYPE disciplinary_level AS ENUM (
    'verbal_warning',       -- Mündliche Ermahnung
    'written_warning',      -- Schriftliche Verwarnung (erste)
    'formal_warning',       -- Förmliche Abmahnung
    'final_warning',        -- Letzte Verwarnung vor Kündigung
    'suspension',           -- Freistellung (mit/ohne Lohn)
    'dismissal_immediate'   -- Fristlose Entlassung
);

-- Disziplinar-Status
CREATE TYPE disciplinary_state AS ENUM (
    'draft',        -- Entwurf, noch nicht zugestellt
    'issued',       -- Zugestellt / kommuniziert
    'acknowledged', -- MA hat zur Kenntnis genommen (Unterschrift)
    'disputed',     -- MA bestreitet (Einsprache)
    'resolved',     -- Erledigt / ohne Folge
    'archived'      -- Abgelegt (nach Retention-Frist für Einträge ohne Folgen)
);

-- Onboarding-Instanz-Status
CREATE TYPE onboarding_state AS ENUM (
    'draft',        -- Template wird konfiguriert
    'active',       -- Läuft (MA hat angefangen)
    'completed',    -- Alle Pflicht-Tasks erledigt
    'overdue',      -- Mindestens 1 Pflicht-Task überfällig
    'cancelled'     -- Abgebrochen (z.B. Kündigung in Probezeit)
);

-- Onboarding-Task-Status
CREATE TYPE onboarding_task_state AS ENUM (
    'pending',
    'in_progress',
    'done',
    'skipped',      -- Optional-Tasks können übersprungen werden
    'overdue'
);

-- Onboarding-Task-Assignee-Rolle
CREATE TYPE onboarding_assignee_role AS ENUM (
    'new_hire',     -- Neuer Mitarbeiter selbst
    'head_of',      -- Head of (direkte Vorgesetzte)
    'admin',        -- Admin (HR/GF)
    'it',           -- IT (Geräte, Zugänge)
    'buddy'         -- Buddy / Paten-MA
);
```

---

## 4. Dimension Tables

### 4.1 `dim_hr_document_type`

Katalog aller HR-Dokument-Typen.

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

**Seeds:**

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

### 4.2 `dim_disciplinary_offense_type`

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

**Seeds:**

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

### 4.3 `dim_onboarding_task_template_type`

Katalog wiederverwendbarer Onboarding-Aufgaben.

```sql
CREATE TABLE dim_onboarding_task_template_type (
    code                VARCHAR(80) PRIMARY KEY,
    label_de            VARCHAR(200) NOT NULL,
    default_assignee    onboarding_assignee_role NOT NULL,
    default_due_offset_days SMALLINT NOT NULL DEFAULT 7,    -- Tage nach Eintrittsdatum
    is_mandatory        BOOLEAN NOT NULL DEFAULT TRUE,
    category            VARCHAR(40) NOT NULL,               -- 'admin' | 'it' | 'compliance' | 'social' | 'role'
    description         TEXT NULL,
    sort_order          SMALLINT NOT NULL DEFAULT 100,
    active              BOOLEAN NOT NULL DEFAULT TRUE
);
```

**Seeds:**

| code | label_de | assignee | offset | mandatory | cat |
|------|----------|----------|--------|-----------|-----|
| `WELCOME_MEETING` | Willkommensgespräch mit Head of | head_of | 1 | ✓ | social |
| `IT_EQUIPMENT_SETUP` | IT-Einrichtung (Laptop, Handy, Zugänge) | it | 1 | ✓ | it |
| `EMAIL_SETUP` | E-Mail + Kalender-Einrichtung (Outlook) | it | 1 | ✓ | it |
| `SIGN_GENERALIS_PROVISIO` | Generalis Provisio unterschreiben | new_hire | 1 | ✓ | compliance |
| `SIGN_PROGRESSUS` | Progressus (Stellenbeschreibung) unterschreiben | new_hire | 3 | ✓ | compliance |
| `SIGN_TEMPUS_PASSIO` | Tempus Passio 365 unterschreiben | new_hire | 3 | ✓ | compliance |
| `SIGN_LOCUS_EXTRA` | Locus Extra unterschreiben | new_hire | 3 | ✓ | compliance |
| `SIGN_PRAEMIUM_VICTORIA` | Praemium Victoria unterschreiben (wenn Provisions-MA) | new_hire | 5 | ✗ | compliance |
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

## 5. Fact Tables

### 5.1 `fact_employment_contracts`

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
    CONSTRAINT chk_probation_max CHECK (probation_months BETWEEN 0 AND 6),  -- fix 3 Mt; Verlängerung via fact_probation_milestones (max 6 Mt total, OR 335b Abs. 2)
    CONSTRAINT chk_termination_consistency CHECK (
        (contract_state = 'terminated' AND terminated_at IS NOT NULL AND termination_reason IS NOT NULL)
        OR contract_state <> 'terminated'
    )
);

CREATE INDEX idx_employment_user ON fact_employment_contracts(user_id);
CREATE INDEX idx_employment_state ON fact_employment_contracts(contract_state);
CREATE INDEX idx_employment_start ON fact_employment_contracts(contract_start);

-- Nur 1 aktiver Vertrag pro MA zur gleichen Zeit
CREATE UNIQUE INDEX uq_employment_active ON fact_employment_contracts(user_id)
    WHERE contract_state = 'active';
```

### 5.2 `fact_employment_attachments`

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
CREATE INDEX idx_attachment_user ON fact_employment_attachments(user_id);
CREATE INDEX idx_attachment_type ON fact_employment_attachments(doc_type_code);
CREATE INDEX idx_attachment_state ON fact_employment_attachments(doc_state)
    WHERE doc_state = 'pending';
```

### 5.3 `fact_disciplinary_records`

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

    -- Archivierung (DSGVO: nach 2 J ohne Folgen löschen — OR-Empfehlung)
    archived_at             TIMESTAMPTZ NULL,
    retention_until         DATE NULL,                  -- gesetzt bei Archivierung

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

CREATE INDEX idx_disciplinary_user ON fact_disciplinary_records(user_id);
CREATE INDEX idx_disciplinary_state ON fact_disciplinary_records(disciplinary_state);
CREATE INDEX idx_disciplinary_open ON fact_disciplinary_records(user_id, disciplinary_state)
    WHERE disciplinary_state IN ('draft','issued','disputed');
CREATE INDEX idx_disciplinary_incident ON fact_disciplinary_records(incident_date);
```

### 5.4 `fact_probation_milestones`

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

CREATE INDEX idx_probation_user ON fact_probation_milestones(user_id);
CREATE INDEX idx_probation_contract ON fact_probation_milestones(contract_id);
CREATE INDEX idx_probation_open ON fact_probation_milestones(user_id, scheduled_date)
    WHERE conducted_at IS NULL;
```

### 5.5 `fact_onboarding_templates`

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

    CONSTRAINT chk_default_unique UNIQUE NULLS NOT DISTINCT (is_default, target_role_code)  -- max 1 Default pro Rolle
);

CREATE INDEX idx_onb_template_role ON fact_onboarding_templates(target_role_code);
```

**Seeds (Phase-1):**

| name | target_role | default |
|------|-------------|---------|
| Onboarding Mitarbeiter (Standard) | MA | ✓ |
| Onboarding Head of | HEAD | ✓ |
| Onboarding Admin/Backoffice | ADMIN | ✓ |

### 5.6 `fact_onboarding_template_tasks`

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

### 5.7 `fact_onboarding_instances`

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

    -- Probezeit-Abschluss via fact_probation_milestones (milestone_type='probation_end')
    probation_milestone_id  UUID NULL REFERENCES fact_probation_milestones(id),  -- gesetzt wenn Probezeit abgeschlossen

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

CREATE INDEX idx_onb_instance_user ON fact_onboarding_instances(user_id);
CREATE INDEX idx_onb_instance_state ON fact_onboarding_instances(onboarding_state);
CREATE INDEX idx_onb_instance_active ON fact_onboarding_instances(user_id, entry_date)
    WHERE onboarding_state IN ('active','overdue');

-- Max 1 aktives Onboarding pro MA
CREATE UNIQUE INDEX uq_onb_active_per_user ON fact_onboarding_instances(user_id)
    WHERE onboarding_state IN ('active','overdue');
```

### 5.8 `fact_onboarding_instance_tasks`

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
    assigned_to_user_id     UUID NULL REFERENCES dim_user(id),   -- konkrete Person
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
CREATE INDEX idx_onb_tasks_overdue ON fact_onboarding_instance_tasks(due_date)
    WHERE task_state IN ('pending','in_progress');
```

---

## 6. Views

### 6.1 `v_hr_active_employees`

Aktive Mitarbeiter mit Vertragsdaten (für HR-List + Dashboard).

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

### 6.2 `v_onboarding_progress`

Onboarding-Fortschritt aller aktiven Prozesse (für Onboarding-Editor §5.7).

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

### 6.3 `v_disciplinary_summary`

Aktive Verwarnung-Zusammenfassung pro Mitarbeiter (für Verwarnungs-Seite).

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

### 6.4 `v_pending_signatures`

Dokumente mit ausstehenden Unterschriften (für HR-Dashboard Alerts).

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

## 7. Seeds-Zusammenfassung

Phase-1-Go-Live:

| Tabelle | # Rows | Quelle |
|---------|--------|--------|
| `dim_hr_document_type` | 13 | Arkadium-Reglemente (Eigennamen) |
| `dim_disciplinary_offense_type` | 13 | HR-Best-Practice + OR |
| `dim_onboarding_task_template_type` | 18 | Peter-Decisions + Mockup |
| `fact_onboarding_templates` | 3 | Rollen: MA / HEAD / ADMIN |
| `fact_onboarding_template_tasks` | ~18 pro Template | Aus `dim_onboarding_task_template_type` |

Mitarbeiter-Verträge und Dokumente werden bei Go-Live manuell migriert.

---

## 8. Retention + DSG

| Entität | Retention | Grund |
|---------|-----------|-------|
| `fact_employment_contracts` | 10 J post Vertragsende | OR Art. 127/128 (allg. Verjährung) |
| `fact_employment_attachments` | 10 J post Vertragsende | Beweislast |
| `fact_disciplinary_records` (ohne Folgen) | 2 J post Archivierung | EDÖB-Empfehlung |
| `fact_disciplinary_records` (mit Kündigung) | 10 J | OR 339/341 |
| `fact_probation_milestones.outcome_note` | 2 J post Probezeit | revDSG Art. 25 |
| `fact_onboarding_instances` | 5 J post Austritt | Compliance-Nachweis |

**Nightly Retention Worker** setzt `archived_at` auf abgelaufene Disziplinar-Einträge ohne Folgen (Status = `resolved` + `incident_date < NOW() - 2 years`).

---

## 9. Integration Hooks

### 9.1 Dokument-Generator

**Event `hr.document.ready.v1`** auf `fact_employment_attachments.doc_state → pending`:

```json
{
  "event_version": "1",
  "attachment_id": "uuid",
  "user_id": "uuid",
  "doc_type_code": "GENERALIS_PROVISIO",
  "contract_id": "uuid",
  "template_file": "/templates/generalis_provisio_v3.docx",
  "metadata": {"name": "Max Muster", "entry_date": "2026-05-01"}
}
```

Dok-Generator-Worker rendert PDF → Upload → aktualisiert `file_path` auf Attachment.

### 9.2 E-Learning / Academy

**`fact_onboarding_instance_tasks.task_type_code = 'TOOL_INTRO_ELEARN'`** bei Status `done` → Event `onboarding.task.done.v1` → E-Learning-Modul weist Pflicht-Kurs automatisch zu.

### 9.3 Absenz-Kalender

`fact_absence` (aus Zeit-Modul) wird im Absenz-Kalender des HR-Moduls via JOIN auf `dim_user` dargestellt. Kein eigenes Absenz-Schema in HR — reine Leseansicht.

### 9.4 Commission / Praemium Victoria

`fact_employment_contracts.has_provisions = TRUE` → Commission-Engine berechtigt MA für Provisions-Berechnung. Änderung triggert `commission.eligibility.changed.v1`.

---

## 10. Offen für Phase-2

- **Digital Signature Integration** (Swiss ID / DocuSign) — Phase 2
- **AHV-API-Anbindung** Treuhand Kunz — Phase 2
- **Lohnerhöhungs-Workflow** (History + Approval) — Phase 2
- **Stelleninserat-Koppelung** (Hire-from-Mandate-Workflow) — Phase 2
- **Multi-Tenant RLS-Erweiterung** (für SaaS-Vermarktung) — Phase 3

---

## 11. Changelog

| Version | Datum | Änderung |
|---------|-------|----------|
| 0.1 | 2026-04-25 | Initial draft · 3 Dims · 8 Facts · 4 Views · Retention · Integration-Hooks |
| 0.2 | 2026-04-25 | Triggers (Audit/State) + Row-Level-Security-Policies |

---

## 12. Deltas v0.1 → v0.2 · Triggers + RLS-Policies

### 12.1 Trigger-Funktion: Audit-Trail Append (generisch)

Wiederverwendbar für alle HR-Tabellen mit `audit_trail_jsonb`.

```sql
CREATE OR REPLACE FUNCTION fn_append_audit_trail()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
DECLARE
    v_changed_fields JSONB;
    v_audit_entry   JSONB;
BEGIN
    -- Diff: nur geänderte Felder (nicht audit_trail_jsonb selbst, nicht updated_at)
    SELECT jsonb_object_agg(key, value)
    INTO v_changed_fields
    FROM jsonb_each(to_jsonb(NEW))
    WHERE key NOT IN ('audit_trail_jsonb', 'updated_at')
      AND (to_jsonb(OLD) ->> key) IS DISTINCT FROM value::text;

    -- Kein Diff → kein Eintrag
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
```

### 12.2 Audit-Triggers auf HR-Tabellen

```sql
-- Arbeitsverträge
CREATE TRIGGER trg_employment_contract_audit
    BEFORE UPDATE ON fact_employment_contracts
    FOR EACH ROW EXECUTE FUNCTION fn_append_audit_trail();

-- Dokument-Anhänge
CREATE TRIGGER trg_employment_attachment_audit
    BEFORE UPDATE ON fact_employment_attachments
    FOR EACH ROW EXECUTE FUNCTION fn_append_audit_trail();

-- Disziplinar-Records
CREATE TRIGGER trg_disciplinary_audit
    BEFORE UPDATE ON fact_disciplinary_records
    FOR EACH ROW EXECUTE FUNCTION fn_append_audit_trail();

-- Probezeit-Meilensteine
CREATE TRIGGER trg_probation_milestone_audit
    BEFORE UPDATE ON fact_probation_milestones
    FOR EACH ROW EXECUTE FUNCTION fn_append_audit_trail();

-- Onboarding-Instanzen
CREATE TRIGGER trg_onboarding_instance_audit
    BEFORE UPDATE ON fact_onboarding_instances
    FOR EACH ROW EXECUTE FUNCTION fn_append_audit_trail();
```

### 12.3 Trigger: Onboarding-Fortschritt auto-aktualisieren

Wenn ein `fact_onboarding_instance_tasks`-Eintrag auf `done` / `overdue` gesetzt wird → Instanz-Counters + Status aktualisieren.

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
    SET
        total_tasks     = v_total,
        done_tasks      = v_done,
        overdue_tasks   = v_overdue,
        onboarding_state = v_new_state,
        updated_at      = NOW()
    WHERE id = NEW.instance_id;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_onboarding_task_state_changed
    AFTER INSERT OR UPDATE OF task_state ON fact_onboarding_instance_tasks
    FOR EACH ROW EXECUTE FUNCTION fn_onboarding_task_state_change();
```

### 12.4 Trigger: Disziplinar-Eskalation vorschlagen

Bei INSERT neuer Verwarnung → zählt aktive Einträge → setzt `suggested_next_level`.

```sql
CREATE OR REPLACE FUNCTION fn_disciplinary_suggest_escalation()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
DECLARE
    v_open_count    INTEGER;
    v_next_level    disciplinary_level;
BEGIN
    SELECT COUNT(*)
    INTO v_open_count
    FROM fact_disciplinary_records
    WHERE user_id = NEW.user_id
      AND id <> NEW.id
      AND disciplinary_state NOT IN ('resolved','archived');

    -- Eskalations-Logik: +1 Stufe über aktuellem Level
    v_next_level := CASE NEW.disciplinary_level
        WHEN 'verbal_warning'   THEN 'written_warning'::disciplinary_level
        WHEN 'written_warning'  THEN 'formal_warning'::disciplinary_level
        WHEN 'formal_warning'   THEN 'final_warning'::disciplinary_level
        WHEN 'final_warning'    THEN 'suspension'::disciplinary_level
        WHEN 'suspension'       THEN 'dismissal_immediate'::disciplinary_level
        ELSE NULL
    END;

    NEW.suggested_next_level := v_next_level;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_disciplinary_escalation
    BEFORE INSERT ON fact_disciplinary_records
    FOR EACH ROW EXECUTE FUNCTION fn_disciplinary_suggest_escalation();
```

### 12.5 Trigger: Vertragsende setzt Retention

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

### 12.6 Row-Level Security (RLS)

**Rollen-Hierarchie** (aus `dim_user.role_code`):

| role_code | Beschreibung | HR-Zugriff |
|-----------|-------------|------------|
| `MA` | Mitarbeiter | Nur eigene Daten (read) |
| `HEAD` | Head of | Eigene + Team-Mitglieder |
| `ADMIN` | Admin / GF | Vollzugriff |
| `BO` | Backoffice | Read-only alle (Reporting) |

**Helper-Funktionen:**

```sql
-- Gibt die dim_user.id des aktuell eingeloggten Users zurück
-- (app.current_user_id wird per Session-Setting vom API-Layer gesetzt)
CREATE OR REPLACE FUNCTION fn_current_user_id()
RETURNS UUID LANGUAGE sql STABLE AS $$
    SELECT id FROM dim_user
    WHERE auth_uid = current_setting('app.current_user_id', TRUE)::uuid
    LIMIT 1;
$$;

-- Gibt role_code des aktuellen Users zurück
CREATE OR REPLACE FUNCTION fn_current_role_code()
RETURNS VARCHAR(10) LANGUAGE sql STABLE AS $$
    SELECT role_code FROM dim_user WHERE id = fn_current_user_id() LIMIT 1;
$$;

-- Gibt UUIDs aller MA zurück, für die der aktuelle User als Head verantwortlich ist
-- (team_id-Matching: MA.team_id = HEAD.id)
CREATE OR REPLACE FUNCTION fn_team_user_ids()
RETURNS UUID[] LANGUAGE sql STABLE AS $$
    SELECT ARRAY(
        SELECT id FROM dim_user
        WHERE team_lead_id = fn_current_user_id()
           OR id = fn_current_user_id()   -- eigene Daten immer inkl.
    );
$$;
```

**RLS aktivieren + Policies:**

```sql
-- RLS aktivieren
ALTER TABLE fact_employment_contracts    ENABLE ROW LEVEL SECURITY;
ALTER TABLE fact_employment_attachments  ENABLE ROW LEVEL SECURITY;
ALTER TABLE fact_disciplinary_records    ENABLE ROW LEVEL SECURITY;
ALTER TABLE fact_probation_milestones    ENABLE ROW LEVEL SECURITY;
ALTER TABLE fact_onboarding_instances    ENABLE ROW LEVEL SECURITY;
ALTER TABLE fact_onboarding_instance_tasks ENABLE ROW LEVEL SECURITY;

-- ── fact_employment_contracts ──────────────────────────────────────────
-- MA: nur eigener Vertrag (read)
CREATE POLICY pol_contract_ma_read ON fact_employment_contracts
    FOR SELECT TO ark_role_ma
    USING (user_id = fn_current_user_id());

-- HEAD: eigener + Team (read)
CREATE POLICY pol_contract_head_read ON fact_employment_contracts
    FOR SELECT TO ark_role_head
    USING (user_id = ANY(fn_team_user_ids()));

-- HEAD: kein Schreibzugriff auf Verträge (nur Admin)
-- ADMIN: alles
CREATE POLICY pol_contract_admin_all ON fact_employment_contracts
    FOR ALL TO ark_role_admin
    USING (TRUE) WITH CHECK (TRUE);

-- BO: read-only alle
CREATE POLICY pol_contract_bo_read ON fact_employment_contracts
    FOR SELECT TO ark_role_bo
    USING (TRUE);

-- ── fact_employment_attachments ────────────────────────────────────────
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

-- ── fact_disciplinary_records ──────────────────────────────────────────
-- MA darf eigene Disziplinar-Einträge NICHT lesen (vertraulich gegenüber MA bis Zustellung)
-- MA sieht nur Einträge mit state >= 'issued'
CREATE POLICY pol_disciplinary_ma_read ON fact_disciplinary_records
    FOR SELECT TO ark_role_ma
    USING (
        user_id = fn_current_user_id()
        AND disciplinary_state IN ('issued','acknowledged','disputed')
    );

CREATE POLICY pol_disciplinary_head_read ON fact_disciplinary_records
    FOR SELECT TO ark_role_head
    USING (user_id = ANY(fn_team_user_ids()));

-- HEAD darf Verwarnungen für eigenes Team erstellen/bearbeiten
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

-- ── fact_probation_milestones ──────────────────────────────────────────
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

-- ── fact_onboarding_instances ──────────────────────────────────────────
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

-- ── fact_onboarding_instance_tasks ────────────────────────────────────
-- Tasks: via instance_id → RLS auf übergeordnete Instanz delegieren
CREATE POLICY pol_onboarding_tasks_ma ON fact_onboarding_instance_tasks
    FOR ALL TO ark_role_ma
    USING (
        instance_id IN (
            SELECT id FROM fact_onboarding_instances
            WHERE user_id = fn_current_user_id()
        )
    )
    WITH CHECK (
        instance_id IN (
            SELECT id FROM fact_onboarding_instances
            WHERE user_id = fn_current_user_id()
        )
        AND assignee_role = 'new_hire'  -- MA darf nur eigene Tasks erledigen
    );

CREATE POLICY pol_onboarding_tasks_head ON fact_onboarding_instance_tasks
    FOR ALL TO ark_role_head
    USING (
        instance_id IN (
            SELECT id FROM fact_onboarding_instances
            WHERE user_id = ANY(fn_team_user_ids())
        )
    )
    WITH CHECK (
        instance_id IN (
            SELECT id FROM fact_onboarding_instances
            WHERE user_id = ANY(fn_team_user_ids())
        )
    );

CREATE POLICY pol_onboarding_tasks_admin ON fact_onboarding_instance_tasks
    FOR ALL TO ark_role_admin
    USING (TRUE) WITH CHECK (TRUE);
```

### 12.7 DB-Rollen + Grants

```sql
-- Rollen erstellen (falls nicht vorhanden)
DO $$ BEGIN
    CREATE ROLE ark_role_ma;
    CREATE ROLE ark_role_head;
    CREATE ROLE ark_role_admin;
    CREATE ROLE ark_role_bo;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- Grants: Dimensions (public, kein RLS)
GRANT SELECT ON dim_hr_document_type                TO ark_role_ma, ark_role_head, ark_role_admin, ark_role_bo;
GRANT SELECT ON dim_disciplinary_offense_type       TO ark_role_ma, ark_role_head, ark_role_admin, ark_role_bo;
GRANT SELECT ON dim_onboarding_task_template_type   TO ark_role_ma, ark_role_head, ark_role_admin, ark_role_bo;

-- Grants: Templates (read-all; schreiben nur Admin)
GRANT SELECT ON fact_onboarding_templates           TO ark_role_ma, ark_role_head, ark_role_bo;
GRANT SELECT ON fact_onboarding_template_tasks      TO ark_role_ma, ark_role_head, ark_role_bo;
GRANT ALL    ON fact_onboarding_templates           TO ark_role_admin;
GRANT ALL    ON fact_onboarding_template_tasks      TO ark_role_admin;

-- Grants: RLS-geschützte Fact-Tabellen
GRANT SELECT, INSERT, UPDATE ON fact_employment_contracts    TO ark_role_ma, ark_role_head;
GRANT ALL                    ON fact_employment_contracts    TO ark_role_admin;
GRANT SELECT                 ON fact_employment_contracts    TO ark_role_bo;

GRANT SELECT, INSERT, UPDATE ON fact_employment_attachments  TO ark_role_head;
GRANT SELECT                 ON fact_employment_attachments  TO ark_role_ma, ark_role_bo;
GRANT ALL                    ON fact_employment_attachments  TO ark_role_admin;

GRANT SELECT, INSERT, UPDATE ON fact_disciplinary_records    TO ark_role_head;
GRANT SELECT                 ON fact_disciplinary_records    TO ark_role_ma, ark_role_bo;
GRANT ALL                    ON fact_disciplinary_records    TO ark_role_admin;

GRANT ALL    ON fact_probation_milestones                    TO ark_role_head, ark_role_admin;
GRANT SELECT ON fact_probation_milestones                    TO ark_role_ma, ark_role_bo;

GRANT ALL    ON fact_onboarding_instances                    TO ark_role_head, ark_role_admin;
GRANT SELECT ON fact_onboarding_instances                    TO ark_role_ma, ark_role_bo;

GRANT ALL    ON fact_onboarding_instance_tasks               TO ark_role_ma, ark_role_head, ark_role_admin;
GRANT SELECT ON fact_onboarding_instance_tasks               TO ark_role_bo;

-- Views (keine RLS → inherits aus Basis-Tabellen)
GRANT SELECT ON v_hr_active_employees   TO ark_role_ma, ark_role_head, ark_role_admin, ark_role_bo;
GRANT SELECT ON v_onboarding_progress   TO ark_role_head, ark_role_admin;
GRANT SELECT ON v_disciplinary_summary  TO ark_role_head, ark_role_admin;
GRANT SELECT ON v_pending_signatures    TO ark_role_head, ark_role_admin;
```

### 12.8 Supabase Auth Adapter

Supabase nutzt `auth.uid()` statt `current_setting`. Adapter-Funktion für Supabase-Deployment:

```sql
CREATE OR REPLACE FUNCTION fn_current_user_id()
RETURNS UUID LANGUAGE sql STABLE SECURITY DEFINER AS $$
    SELECT id FROM dim_user
    WHERE auth_uid = auth.uid()
    LIMIT 1;
$$;
```

`dim_user.auth_uid UUID NULL UNIQUE` — Spalte muss in Basis-Schema vorhanden sein (falls nicht: `ALTER TABLE dim_user ADD COLUMN auth_uid UUID NULL UNIQUE;`).

---

## 13. Migrations-Reihenfolge (v0.1 → v0.2)

```sql
-- 1. Extensions (bereits vorhanden aus Zeit-Schema)
-- 2. ENUMs
-- 3. Dimension Tables + Seeds
-- 4. Fact Tables
-- 5. Indexes
-- 6. Views
-- 7. Trigger-Funktionen (§12.1–12.5)
-- 8. Triggers
-- 9. RLS aktivieren
-- 10. Helper-Funktionen (§12.6)
-- 11. RLS-Policies
-- 12. Rollen + Grants (§12.7)
-- 13. Supabase Auth Adapter falls Supabase-Deployment (§12.8)
```
