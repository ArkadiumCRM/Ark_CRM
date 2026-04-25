---
title: "ARK HR-Modul · Schema-Patch v0.1 → v0.2 (Performance-Reviews-Migration)"
type: spec
module: hr
version: 0.2
created: 2026-04-25
updated: 2026-04-25
status: draft
sources: [
  "specs/ARK_HR_TOOL_SCHEMA_v0_1.md",
  "specs/ARK_HR_TOOL_INTERACTIONS_v0_1.md",
  "specs/ARK_PERFORMANCE_TOOL_SCHEMA_v0_1.md",
  "Grundlagen MD/ARK_DATABASE_SCHEMA_v1_5.md",
  "memory/project_performance_modul_decisions.md"
]
tags: [spec, schema, hr, patch, performance-reviews, 360-feedback, competency, development-plans, q1-c]
---

# ARK HR-Modul · Schema-Patch v0.1 → v0.2

**Anlass:** Q1=C aus Performance-Modul-Scoping (2026-04-25). 8 Performance-Schema-Stubs aus DB §19 werden voll ins HR-Modul migriert. `fact_learning_progress` wird gestrichen (E-Learning Sub-A `fact_elearn_attempt` ist Single-Source).

**Migrierte Tabellen (vorher in DB §19, jetzt in HR):**
1. `fact_performance_reviews` — Periodische Reviews (Self + Manager + optional 360°-Aggregat)
2. `fact_360_feedback` — Peer/Direct-Reports/Manager/Self-Feedback einzelner Quellen
3. `dim_feedback_questions` — Question-Bank rolle/sparte-spezifisch
4. `dim_feedback_cycles` — Review-Zyklen (Quartal/Halbjahr/Jahr)
5. `fact_competency_ratings` — Skill-Bewertungen pro MA × Competency
6. `dim_competency_framework` — Skill-Matrix pro Rolle
7. `fact_development_plans` — Karriere-/Entwicklungspläne (lang)
8. ~~`fact_learning_progress`~~ — **gestrichen** (E-Learning Sub-A ist Single-Source)

**Konsequenz für Performance-Modul:** liest `v_hr_review_summary` (Aggregat-View) für Performance-Mitarbeiter-Page-Tab "Reviews". Schreibt nichts ins HR.

---

## 1. Neue ENUMs (HR-Patch §F)

```sql
-- Review-Cycle-Cadence
CREATE TYPE review_cycle_cadence AS ENUM (
    'quarterly',  -- Q1/Q2/Q3/Q4
    'biannual',   -- H1/H2
    'annual',     -- Jahresreview
    'probation',  -- Probezeit-End-Review (gekoppelt an fact_probation_milestones)
    'ad_hoc'      -- Sonderreview (z.B. nach Beförderung)
);

-- Review-Status
CREATE TYPE review_state AS ENUM (
    'draft',         -- Cycle definiert, noch nicht gestartet
    'self_pending',  -- MA muss Self-Assessment machen
    'manager_pending', -- Head muss Manager-Assessment machen
    'meeting_scheduled', -- Beide fertig, Termin steht
    'meeting_done',  -- Gespräch geführt, Konsens-Notiz fehlt
    'signed',        -- Beide haben unterschrieben (final)
    'cancelled'      -- Cycle abgebrochen (z.B. MA verlässt Firma)
);

-- 360°-Feedback-Source-Rolle
CREATE TYPE feedback_source_role AS ENUM (
    'self',          -- MA bewertet sich selbst
    'manager',       -- direkter Vorgesetzter
    'peer',          -- gleichrangiger Kollege
    'direct_report', -- direkt unterstellter MA
    'cross_func',    -- aus anderer Sparte/Team (z.B. AM bewertet CM)
    'external'       -- Kunde/Externer (selten, Phase-3.3+)
);

-- Question-Type für Question-Bank
CREATE TYPE question_type AS ENUM (
    'rating_1_5',     -- Likert-Skala 1-5
    'rating_1_10',    -- Skala 1-10
    'multi_choice',   -- Multiple-Choice (mit options_jsonb)
    'free_text',      -- offene Antwort
    'yes_no',         -- binär
    'boolean_explain' -- Yes/No mit Pflicht-Begründung
);

-- Competency-Level (Soll-Ist-Skala)
CREATE TYPE competency_level AS ENUM (
    'novice',          -- 1: Lernend
    'developing',      -- 2: Entwickelnd
    'proficient',      -- 3: Kompetent (Soll für Junior-Rollen)
    'advanced',        -- 4: Fortgeschritten (Soll für Senior-Rollen)
    'expert'           -- 5: Experte (Soll für Head/Admin-Rollen)
);

-- Development-Plan-Status
CREATE TYPE development_plan_state AS ENUM (
    'draft',
    'agreed',          -- MA + Head haben sich auf Plan geeinigt
    'in_progress',     -- Plan läuft
    'milestone_due',   -- Zwischenziel erreicht (Check-In)
    'completed',       -- alle Ziele erreicht
    'archived',        -- veraltet, neuer Plan
    'cancelled'        -- abgebrochen (z.B. Karrierewechsel)
);
```

---

## 2. `dim_feedback_cycles`

Definiert die Review-Zyklen pro Tenant. Admin pflegt.

```sql
CREATE TABLE dim_feedback_cycles (
    id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id               UUID NOT NULL,
    code                    VARCHAR(60) NOT NULL,                -- z.B. 'h1_2026', 'q3_2026', 'probation_johndoe'
    label_de                VARCHAR(200) NOT NULL,               -- z.B. "Halbjahresreview H1 2026"
    cadence                 review_cycle_cadence NOT NULL,
    period_start            DATE NOT NULL,
    period_end              DATE NOT NULL,
    self_assessment_due     DATE NOT NULL,                       -- bis wann MA fertig
    manager_assessment_due  DATE NOT NULL,                       -- bis wann Head fertig
    meeting_due             DATE NOT NULL,                       -- bis wann Gespräch geführt
    review_signoff_due      DATE NOT NULL,                       -- bis wann unterschrieben
    target_audience         VARCHAR(40) NOT NULL DEFAULT 'all_active', -- 'all_active' | 'specific_users' | 'specific_roles'
    target_users_jsonb      JSONB NULL,                          -- bei 'specific_users': [user_id, ...]
    target_roles_jsonb      JSONB NULL,                          -- bei 'specific_roles': [role_code, ...]
    question_set_id         UUID NULL,                           -- ggf. spezifische Question-Bank pro Cycle
    enable_360              BOOLEAN NOT NULL DEFAULT FALSE,      -- 360°-Feedback aktiviert?
    enable_competency_rating BOOLEAN NOT NULL DEFAULT FALSE,     -- Competency-Bewertung aktiviert?
    notes                   TEXT NULL,
    state                   VARCHAR(20) NOT NULL DEFAULT 'draft', -- 'draft' | 'open' | 'closed' | 'archived'
    created_by_user_id      UUID NOT NULL REFERENCES dim_user(id),
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (tenant_id, code)
);

CREATE INDEX idx_feedback_cycle_state ON dim_feedback_cycles(tenant_id, state, period_end DESC);

ALTER TABLE dim_feedback_cycles ENABLE ROW LEVEL SECURITY;
CREATE POLICY feedback_cycle_tenant ON dim_feedback_cycles
    USING (tenant_id = current_setting('app.tenant_id')::uuid);
```

---

## 3. `dim_feedback_questions`

Question-Bank — Stammdaten der Fragen.

```sql
CREATE TABLE dim_feedback_questions (
    id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id               UUID NOT NULL,
    code                    VARCHAR(80) NOT NULL,                -- z.B. 'q_communication_clarity'
    label_de                VARCHAR(300) NOT NULL,               -- die eigentliche Frage
    description_de          TEXT NULL,                           -- Kontext / Hilfe
    question_type           question_type NOT NULL,
    options_jsonb           JSONB NULL,                          -- für multi_choice: ["Option A", ...]
    category                VARCHAR(40) NOT NULL,                -- 'communication' | 'leadership' | 'technical' | 'collaboration' | 'self_management' | 'business_impact'
    applicable_roles        TEXT[] NOT NULL DEFAULT '{ma}',      -- für welche Rollen relevant
    applicable_sources      feedback_source_role[] NOT NULL DEFAULT '{self,manager}', -- welche Source-Rollen beantworten
    applicable_sparten      TEXT[] NULL,                         -- NULL = alle
    weight                  NUMERIC(4,2) NOT NULL DEFAULT 1.0,   -- Gewichtung im Aggregat
    sort_order              SMALLINT NOT NULL DEFAULT 100,
    active                  BOOLEAN NOT NULL DEFAULT TRUE,
    archived_at             TIMESTAMPTZ NULL,
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (tenant_id, code)
);

CREATE INDEX idx_feedback_question_category_role ON dim_feedback_questions(category, active);

ALTER TABLE dim_feedback_questions ENABLE ROW LEVEL SECURITY;
CREATE POLICY feedback_question_tenant ON dim_feedback_questions
    USING (tenant_id = current_setting('app.tenant_id')::uuid);
```

**Question-Bank Default-Seeds (v0.2):** ~25 Fragen aus 6 Kategorien (in separatem Stammdaten-Patch).

---

## 4. `fact_performance_reviews`

Master-Tabelle pro Review-Instanz (Cycle × MA).

```sql
CREATE TABLE fact_performance_reviews (
    id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id               UUID NOT NULL,
    cycle_id                UUID NOT NULL REFERENCES dim_feedback_cycles(id) ON DELETE RESTRICT,
    user_id                 UUID NOT NULL REFERENCES dim_user(id),       -- MA der reviewed wird
    manager_user_id         UUID NOT NULL REFERENCES dim_user(id),       -- Head der reviewt
    state                   review_state NOT NULL DEFAULT 'draft',
    self_assessment_completed_at      TIMESTAMPTZ NULL,
    manager_assessment_completed_at   TIMESTAMPTZ NULL,
    meeting_scheduled_at    TIMESTAMPTZ NULL,
    meeting_held_at         TIMESTAMPTZ NULL,
    consensus_notes         TEXT NULL,                           -- Notizen aus Gespräch
    consensus_score         NUMERIC(4,2) NULL,                   -- aggregierter Konsens-Score (1-5)
    self_signed_at          TIMESTAMPTZ NULL,
    manager_signed_at       TIMESTAMPTZ NULL,
    signed_pdf_path         VARCHAR(500) NULL,                   -- finales unterschriebenes PDF
    confidential_notes      TEXT NULL,                           -- Manager-only Notizen (RLS-spezial)
    audit_trail_jsonb       JSONB NOT NULL DEFAULT '[]',
    archived_at             TIMESTAMPTZ NULL,
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (tenant_id, cycle_id, user_id)
);

CREATE INDEX idx_perf_review_user_cycle ON fact_performance_reviews(tenant_id, user_id, cycle_id);
CREATE INDEX idx_perf_review_manager_state ON fact_performance_reviews(tenant_id, manager_user_id, state);

ALTER TABLE fact_performance_reviews ENABLE ROW LEVEL SECURITY;
CREATE POLICY perf_review_visibility ON fact_performance_reviews
    USING (
        tenant_id = current_setting('app.tenant_id')::uuid
        AND (
            user_id = current_setting('app.user_id')::uuid              -- Self
            OR manager_user_id = current_setting('app.user_id')::uuid    -- Manager
            OR current_setting('app.role_code') IN ('admin')             -- Admin tenant-weit
        )
    );

-- confidential_notes nur Manager + Admin sehen — App-Layer-Filter
```

---

## 5. `fact_360_feedback`

Einzelne Feedback-Einträge (Self/Manager/Peer/Direct-Report/Cross-Func).

```sql
CREATE TABLE fact_360_feedback (
    id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id               UUID NOT NULL,
    review_id               UUID NOT NULL REFERENCES fact_performance_reviews(id) ON DELETE CASCADE,
    source_user_id          UUID NULL REFERENCES dim_user(id),   -- wer das Feedback abgibt (NULL bei externer Source bei Anonymisierung)
    source_role             feedback_source_role NOT NULL,
    source_anonymous        BOOLEAN NOT NULL DEFAULT FALSE,      -- Bei Peer/Direct-Report-Feedback: anonymisiert?
    submitted_at            TIMESTAMPTZ NULL,                    -- NULL wenn noch ausstehend
    answers_jsonb           JSONB NOT NULL DEFAULT '{}',         -- {question_code: answer_value}
    aggregate_score         NUMERIC(4,2) NULL,                   -- berechneter Mittelwert (gewichtet)
    free_text_summary       TEXT NULL,                           -- optional: freier Kommentar
    audit_trail_jsonb       JSONB NOT NULL DEFAULT '[]',
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    -- Bei Self/Manager: max 1 Eintrag pro Review (Constraint via Index)
    UNIQUE (tenant_id, review_id, source_user_id, source_role)
);

CREATE INDEX idx_360_review ON fact_360_feedback(review_id, source_role);
CREATE INDEX idx_360_source ON fact_360_feedback(tenant_id, source_user_id) WHERE source_user_id IS NOT NULL;

ALTER TABLE fact_360_feedback ENABLE ROW LEVEL SECURITY;
CREATE POLICY feedback_360_visibility ON fact_360_feedback
    USING (
        tenant_id = current_setting('app.tenant_id')::uuid
        AND (
            -- Self sieht eigenes Self-Feedback und (anonymisiert) Aggregat von Peer/Direct-Report
            EXISTS (SELECT 1 FROM fact_performance_reviews r WHERE r.id = fact_360_feedback.review_id AND r.user_id = current_setting('app.user_id')::uuid AND fact_360_feedback.source_role IN ('self'))
            -- Manager sieht alle Feedback-Items für Reviews seiner Direct-Reports (Anonymisierung App-Layer)
            OR EXISTS (SELECT 1 FROM fact_performance_reviews r WHERE r.id = fact_360_feedback.review_id AND r.manager_user_id = current_setting('app.user_id')::uuid)
            -- Source sieht eigenes Feedback (kann editieren bis submitted)
            OR source_user_id = current_setting('app.user_id')::uuid
            -- Admin sieht alles
            OR current_setting('app.role_code') IN ('admin')
        )
    );

-- Anonymisierung erfolgt App-Layer beim Aggregat — Source-User-ID wird im UI nicht angezeigt bei source_anonymous=TRUE
```

---

## 6. `dim_competency_framework`

Skill-Matrix pro Rolle. Definiert was eine Rolle "können sollte".

```sql
CREATE TABLE dim_competency_framework (
    id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id               UUID NOT NULL,
    code                    VARCHAR(80) NOT NULL,                -- z.B. 'comp_briefing_quality'
    label_de                VARCHAR(200) NOT NULL,               -- "Briefing-Qualität"
    description_de          TEXT NULL,
    category                VARCHAR(40) NOT NULL,                -- 'methodology' | 'communication' | 'leadership' | 'technical' | 'business' | 'culture'
    applicable_roles_jsonb  JSONB NOT NULL,                      -- {role_code: required_level} z.B. {"researcher": "developing", "cm": "proficient", "head": "expert"}
    measurement_guideline_jsonb JSONB NULL,                      -- pro Level: was bedeutet das konkret? {"novice": "...", "proficient": "...", ...}
    sort_order              SMALLINT NOT NULL DEFAULT 100,
    active                  BOOLEAN NOT NULL DEFAULT TRUE,
    archived_at             TIMESTAMPTZ NULL,
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (tenant_id, code)
);

CREATE INDEX idx_competency_category ON dim_competency_framework(category, active);

ALTER TABLE dim_competency_framework ENABLE ROW LEVEL SECURITY;
CREATE POLICY competency_tenant ON dim_competency_framework
    USING (tenant_id = current_setting('app.tenant_id')::uuid);
```

**Default-Seeds (v0.2):** ~15 Competencies (in Stammdaten-Patch).

---

## 7. `fact_competency_ratings`

Bewertungen pro MA × Competency × Cycle.

```sql
CREATE TABLE fact_competency_ratings (
    id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id               UUID NOT NULL,
    review_id               UUID NOT NULL REFERENCES fact_performance_reviews(id) ON DELETE CASCADE,
    competency_id           UUID NOT NULL REFERENCES dim_competency_framework(id),
    user_id                 UUID NOT NULL REFERENCES dim_user(id),
    rated_by_user_id        UUID NOT NULL REFERENCES dim_user(id), -- Self oder Manager (entscheidend für Aggregat)
    rated_by_role           feedback_source_role NOT NULL,
    rating_level            competency_level NOT NULL,
    target_level            competency_level NOT NULL,           -- aus dim_competency_framework.applicable_roles_jsonb gemappt
    gap_score               SMALLINT GENERATED ALWAYS AS (
        CASE rating_level
            WHEN 'novice' THEN 1 WHEN 'developing' THEN 2 WHEN 'proficient' THEN 3
            WHEN 'advanced' THEN 4 WHEN 'expert' THEN 5
        END -
        CASE target_level
            WHEN 'novice' THEN 1 WHEN 'developing' THEN 2 WHEN 'proficient' THEN 3
            WHEN 'advanced' THEN 4 WHEN 'expert' THEN 5
        END
    ) STORED,                                                    -- negativ = Gap, positiv = Über-Soll
    evidence                TEXT NULL,                           -- konkrete Belege (z.B. "PW-Briefing 18.03 hatte Schwächen in...")
    rated_at                TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (tenant_id, review_id, competency_id, rated_by_user_id, rated_by_role)
);

CREATE INDEX idx_comp_rating_user ON fact_competency_ratings(tenant_id, user_id, competency_id);
CREATE INDEX idx_comp_rating_review ON fact_competency_ratings(review_id);
CREATE INDEX idx_comp_rating_gap ON fact_competency_ratings(tenant_id, gap_score) WHERE gap_score < 0;

ALTER TABLE fact_competency_ratings ENABLE ROW LEVEL SECURITY;
CREATE POLICY comp_rating_visibility ON fact_competency_ratings
    USING (
        tenant_id = current_setting('app.tenant_id')::uuid
        AND (
            user_id = current_setting('app.user_id')::uuid
            OR EXISTS (SELECT 1 FROM dim_user u WHERE u.id = fact_competency_ratings.user_id AND u.reports_to = current_setting('app.user_id')::uuid)
            OR current_setting('app.role_code') IN ('admin')
        )
    );
```

---

## 8. `fact_development_plans`

Karriere-/Entwicklungspläne (Q2=C: lange Karriere-Goals hier, kurze operative in Performance-Modul).

```sql
CREATE TABLE fact_development_plans (
    id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id               UUID NOT NULL,
    user_id                 UUID NOT NULL REFERENCES dim_user(id),
    plan_horizon_months     SMALLINT NOT NULL DEFAULT 12,        -- z.B. 12, 24, 36
    period_start            DATE NOT NULL,
    period_end              DATE NOT NULL,
    title                   VARCHAR(200) NOT NULL,               -- z.B. "Wachstum zu Senior-CM"
    description             TEXT NULL,
    state                   development_plan_state NOT NULL DEFAULT 'draft',
    goals_jsonb             JSONB NOT NULL DEFAULT '[]',         -- [{id, title, type: 'skill'|'role'|'certification'|'business', target_date, status, evidence}]
    linked_academy_modules  UUID[] NULL,                         -- Refs zu dim_academy_modules (E-Learning Sub-A)
    linked_competencies     UUID[] NULL,                         -- Refs zu dim_competency_framework
    mentor_user_id          UUID NULL REFERENCES dim_user(id),
    next_checkin_at         DATE NULL,
    last_review_id          UUID NULL REFERENCES fact_performance_reviews(id),  -- bei welchem Review zuletzt diskutiert
    agreed_at               TIMESTAMPTZ NULL,
    completed_at            TIMESTAMPTZ NULL,
    cancelled_at            TIMESTAMPTZ NULL,
    cancellation_reason     TEXT NULL,
    audit_trail_jsonb       JSONB NOT NULL DEFAULT '[]',
    created_by_user_id      UUID NOT NULL REFERENCES dim_user(id),
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_dev_plan_user_state ON fact_development_plans(tenant_id, user_id, state) WHERE state IN ('agreed', 'in_progress', 'milestone_due');
CREATE INDEX idx_dev_plan_checkin ON fact_development_plans(next_checkin_at) WHERE state IN ('agreed', 'in_progress');

ALTER TABLE fact_development_plans ENABLE ROW LEVEL SECURITY;
CREATE POLICY dev_plan_visibility ON fact_development_plans
    USING (
        tenant_id = current_setting('app.tenant_id')::uuid
        AND (
            user_id = current_setting('app.user_id')::uuid
            OR mentor_user_id = current_setting('app.user_id')::uuid
            OR EXISTS (SELECT 1 FROM dim_user u WHERE u.id = fact_development_plans.user_id AND u.reports_to = current_setting('app.user_id')::uuid)
            OR current_setting('app.role_code') IN ('admin')
        )
    );
```

---

## 9. View: `v_hr_review_summary` (Performance-Modul-Schnittstelle)

Aggregat-View für Performance-Modul (READ-only).

```sql
CREATE OR REPLACE VIEW v_hr_review_summary AS
SELECT
    r.tenant_id,
    r.user_id,
    u.label_de AS user_label,
    u.role_code,
    u.team_id,
    c.cadence,
    c.period_start,
    c.period_end,
    r.state,
    r.consensus_score,
    r.signed_at IS NOT NULL AS is_signed,
    -- Letzte Review pro User
    ROW_NUMBER() OVER (PARTITION BY r.tenant_id, r.user_id ORDER BY c.period_end DESC) AS recency_rank,
    -- Aggregat-Self-Score
    (SELECT AVG((value::text)::numeric)
     FROM fact_360_feedback f, jsonb_each(f.answers_jsonb)
     WHERE f.review_id = r.id AND f.source_role = 'self') AS self_score_avg,
    -- Aggregat-Manager-Score
    (SELECT AVG((value::text)::numeric)
     FROM fact_360_feedback f, jsonb_each(f.answers_jsonb)
     WHERE f.review_id = r.id AND f.source_role = 'manager') AS manager_score_avg,
    -- 360-Aggregat (peer + direct_report + cross_func)
    (SELECT AVG((value::text)::numeric)
     FROM fact_360_feedback f, jsonb_each(f.answers_jsonb)
     WHERE f.review_id = r.id AND f.source_role IN ('peer','direct_report','cross_func')) AS feedback_360_avg,
    -- Competency-Gap-Aggregat
    (SELECT AVG(gap_score)
     FROM fact_competency_ratings cr
     WHERE cr.review_id = r.id AND cr.rated_by_role = 'manager') AS avg_competency_gap,
    r.archived_at
FROM fact_performance_reviews r
JOIN dim_feedback_cycles c ON r.cycle_id = c.id
JOIN dim_user u ON r.user_id = u.id
WHERE r.archived_at IS NULL;

-- Performance-Modul-Read-Only-Rolle braucht SELECT-Grant:
GRANT SELECT ON v_hr_review_summary TO performance_reader;
```

---

## 10. Mockup-Erweiterungen (HR v0.2)

Neue Pages im HR-Hub:

| Page (neu) | Datei | Inhalt |
|------------|-------|--------|
| Reviews | `mockups/ERP Tools/hr/hr-reviews.html` | Reviews-Liste pro MA, Cycle-Status, Drawer-CRUD |
| Cycles | `mockups/ERP Tools/hr/hr-review-cycles.html` | Admin: Cycles definieren, aktivieren, schliessen |
| Question-Bank | `mockups/ERP Tools/hr/hr-feedback-questions.html` | Admin: Fragen-Verwaltung |
| Competency-Framework | `mockups/ERP Tools/hr/hr-competency-framework.html` | Admin: Skill-Matrix-Definition pro Rolle |
| Development-Plans | `mockups/ERP Tools/hr/hr-development-plans.html` | MA: Eigener Plan, Head: Team-Pläne |

**Sidebar-Erweiterung in `hr.html`:**

```
HR-Hub
├─ Dashboard
├─ Mitarbeiter
├─ Verträge & Dokumente
├─ Onboarding
├─ Verwarnungen
├─ Reviews          ← NEU
├─ Development      ← NEU
└─ Admin (Admin only)
   ├─ Cycles        ← NEU
   ├─ Question-Bank ← NEU
   └─ Competencies  ← NEU
```

---

## 11. Drawer-Inventar HR v0.2 (zusätzlich zu v0.1)

| Drawer-ID | Trigger | Inhalt | Schema-Entität |
|-----------|---------|--------|----------------|
| `drawer-review-cycle-new` (Admin) | "+ Cycle" | Cycle definieren (Cadence, Period, Due-Dates, Question-Set) | `dim_feedback_cycles` |
| `drawer-review-cycle-edit` (Admin) | Klick auf Cycle | Edit + Aktivieren/Schliessen | `dim_feedback_cycles` |
| `drawer-review-self-assessment` (MA) | "Self-Assessment ausfüllen" | Question-Bank durchlaufen, Antworten speichern | `fact_360_feedback` (source_role=self) |
| `drawer-review-manager-assessment` (Head) | "Manager-Assessment ausfüllen" | Wie oben + confidential_notes | `fact_360_feedback` (source_role=manager) + `fact_performance_reviews.confidential_notes` |
| `drawer-review-360-invite` (Head) | "360°-Feedback einholen" | Source-User auswählen (peer/direct-report/cross-func), Invitation senden | `fact_360_feedback` (Stub-Einträge mit submitted_at=NULL) |
| `drawer-review-360-submit` (Source) | Klick auf eingegangene Invitation | Eigenes Feedback ausfüllen (anonymisiert wenn aktiviert) | `fact_360_feedback` |
| `drawer-review-meeting-prep` (Head) | "Gespräch vorbereiten" | Side-by-Side Self vs Manager, Diskussionspunkte | `fact_performance_reviews` |
| `drawer-review-meeting-notes` (Head) | "Konsens-Notizen erfassen" | Meeting-Notes, Konsens-Score | `fact_performance_reviews.consensus_notes/_score` |
| `drawer-review-signoff` (Self + Manager) | "Unterschreiben" | Final-PDF-Vorschau, beide signieren | `fact_performance_reviews.self_signed_at/manager_signed_at/signed_pdf_path` |
| `drawer-competency-rate` (Head) | Klick auf Competency in Review | Level-Auswahl + Evidence | `fact_competency_ratings` |
| `drawer-development-plan-new` (Head + MA) | "+ Plan" | Plan-Definition mit Goals, verlinkten Modulen, Mentor | `fact_development_plans` |
| `drawer-development-plan-edit` | Klick auf Plan | Goals updaten, Status setzen, Check-In dokumentieren | `fact_development_plans` |
| `drawer-question-bank-edit` (Admin) | Klick auf Frage | Frage edit (Text, Type, Kategorie, Rollen) | `dim_feedback_questions` |
| `drawer-question-bank-new` (Admin) | "+ Frage" | neue Frage erstellen | `dim_feedback_questions` |
| `drawer-competency-edit` (Admin) | Klick auf Competency | Level-Definitions, Rollen-Required-Level | `dim_competency_framework` |

---

## 12. Sagas

### 12.1 Saga: Review-Cycle-Lifecycle

```
Step 1 (Admin):
  - Definiert Cycle in drawer-review-cycle-new
  - INSERT dim_feedback_cycles (state='draft')
  - Klickt "Aktivieren" → state='open'
  - System: für jeden Target-MA INSERT fact_performance_reviews (state='self_pending')
  - System: erstellt Reminder für jeden MA "Self-Assessment fällig bis X"
  - Optional bei enable_360=TRUE: Head wählt 360°-Quellen → INSERT Stub-Einträge in fact_360_feedback

Step 2 (MA):
  - Bekommt Reminder
  - Öffnet drawer-review-self-assessment
  - Beantwortet Fragen → INSERT fact_360_feedback (source_role='self')
  - UPDATE fact_performance_reviews.self_assessment_completed_at
  - Wenn auch Manager-Assessment fertig: UPDATE state='meeting_scheduled'
  - Sonst: state='manager_pending'

Step 3 (Head):
  - Bekommt Reminder
  - Öffnet drawer-review-manager-assessment
  - Beantwortet Fragen + ggf. confidential_notes
  - INSERT fact_360_feedback (source_role='manager')
  - UPDATE fact_performance_reviews.manager_assessment_completed_at
  - state='meeting_scheduled'

Step 4 (Optional 360°):
  - Source-User bekommen Reminder bei aktiviertem 360°
  - Öffnen drawer-review-360-submit
  - Submit Feedback (anonymisiert)
  - UPDATE fact_360_feedback (Stub → vollständig)

Step 5 (Meeting):
  - Head + MA führen Gespräch
  - Head erfasst Konsens-Notes via drawer-review-meeting-notes
  - UPDATE fact_performance_reviews.consensus_notes/_score, meeting_held_at
  - state='meeting_done'

Step 6 (Signoff):
  - System rendert PDF (via Dok-Generator-Template 'hr_review_v1')
  - Self öffnet drawer-review-signoff → unterschreibt
  - Manager öffnet drawer-review-signoff → unterschreibt
  - state='signed'
  - signed_pdf_path gesetzt
  - Reminder gelöscht
  - Cycle bleibt offen für andere MA, schliesst wenn alle signed

Step 7 (Cycle-Close):
  - Admin (oder Cron) prüft: alle Reviews signed?
  - UPDATE dim_feedback_cycles.state='closed'
  - Performance-Modul kann v_hr_review_summary für diesen Cycle aggregieren
```

### 12.2 Saga: Probezeit-End → Auto-Review-Cycle

```
Trigger: fact_probation_milestones (milestone_type='probation_end') wird auf 'pending' gesetzt
  → System erstellt automatisch INSERT dim_feedback_cycles (cadence='probation', code='probation_<user_id>')
  → INSERT fact_performance_reviews (state='self_pending') für diesen MA
  → Saga 12.1 Step 2 ff.
```

---

## 13. Endpoints (HR-Patch)

```
# Cycles
GET    /api/v1/hr/review-cycles
POST   /api/v1/hr/review-cycles                              ← Admin
PATCH  /api/v1/hr/review-cycles/:id                          ← Admin
POST   /api/v1/hr/review-cycles/:id/activate                 ← Admin: state=open + create reviews
POST   /api/v1/hr/review-cycles/:id/close                    ← Admin: state=closed

# Reviews
GET    /api/v1/hr/reviews/me                                 ← eigene Reviews
GET    /api/v1/hr/reviews/team                               ← Team (Head)
GET    /api/v1/hr/reviews/:id
POST   /api/v1/hr/reviews/:id/self-assessment                ← Self speichert Antworten
POST   /api/v1/hr/reviews/:id/manager-assessment             ← Manager speichert
POST   /api/v1/hr/reviews/:id/meeting-notes                  ← Konsens
POST   /api/v1/hr/reviews/:id/sign                           ← Self oder Manager unterschreibt

# 360°
GET    /api/v1/hr/reviews/:id/360-feedback                   ← alle Einträge (gefiltert nach RBAC)
POST   /api/v1/hr/reviews/:id/360-feedback/invite            ← Head lädt Source ein
POST   /api/v1/hr/reviews/:id/360-feedback/:feedback_id/submit ← Source submitted

# Question-Bank (Admin)
GET    /api/v1/hr/feedback-questions
POST   /api/v1/hr/feedback-questions
PATCH  /api/v1/hr/feedback-questions/:id
DELETE /api/v1/hr/feedback-questions/:id                     ← Soft-Delete

# Competency-Framework (Admin)
GET    /api/v1/hr/competency-framework
POST   /api/v1/hr/competency-framework
PATCH  /api/v1/hr/competency-framework/:id

# Competency-Ratings
POST   /api/v1/hr/reviews/:id/competency-ratings             ← Head bewertet
GET    /api/v1/hr/reviews/:id/competency-ratings

# Development-Plans
GET    /api/v1/hr/development-plans/me
GET    /api/v1/hr/development-plans/team                     ← Head
POST   /api/v1/hr/development-plans                          ← Head + MA gemeinsam
PATCH  /api/v1/hr/development-plans/:id
POST   /api/v1/hr/development-plans/:id/agree                ← MA + Head agreement
POST   /api/v1/hr/development-plans/:id/checkin              ← Status-Update
POST   /api/v1/hr/development-plans/:id/complete

# Read-Only-View für Performance-Modul
GET    /api/v1/hr/review-summary                             ← v_hr_review_summary mit Filter
```

---

## 14. Streichungen

### 14.1 `fact_learning_progress` (DB §19)

**Streichen, nicht migrieren.** E-Learning Sub-A `fact_elearn_attempt` + `fact_elearn_assignment` + `fact_elearn_certificate` sind vollständige Single-Source. Performance-Modul liest via `v_elearn_compliance` (existiert).

### 14.2 `dim_skill_certifications` (DB §19 ENTWICKLUNG-Block)

**Streichen.** E-Learning Sub-A hat `fact_elearn_certificate` mit eigenem Cert-Generator + Badge-Engine. Externe Schulungs-Zertifikate (CAS/MAS) werden zukünftig via `fact_training_requests` (in HR-Academy-Konzept erwähnt) getrackt — separater Spec-Patch wenn benötigt.

---

## 15. Acceptance Criteria

- [ ] 7 neue Tabellen erstellt (RLS + Indizes + ENUMs)
- [ ] `v_hr_review_summary` View erstellt + GRANT für Performance-Modul
- [ ] 5 neue Mockup-HTMLs (Reviews, Cycles, Questions, Competencies, Dev-Plans)
- [ ] Sidebar in `hr.html` erweitert
- [ ] ~15 neue Drawer in HR-Modul
- [ ] 2 Sagas implementiert (Review-Cycle-Lifecycle, Probezeit-Auto-Trigger)
- [ ] ~30 neue Endpoints `/api/v1/hr/reviews/...`, `/development-plans/...`, etc.
- [ ] Question-Bank-Default-Seeds (~25 Fragen)
- [ ] Competency-Framework-Default-Seeds (~15 Competencies)
- [ ] Streichungen: `fact_learning_progress` + `dim_skill_certifications` aus DB §19
- [ ] HR-Lint grün (Stammdaten, DB-Tech, Drawer-Default, Datum, Umlaute)
- [ ] DSGVO: 360°-Anonymisierung App-Layer, Confidential-Notes RBAC
