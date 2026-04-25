---
title: "ARK Database Schema Patch v1.5 → v1.6 · Performance-Modul"
type: spec
module: performance
version: 1.6
created: 2026-04-25
updated: 2026-04-25
status: draft
sources: [
  "Grundlagen MD/ARK_DATABASE_SCHEMA_v1_5.md",
  "specs/ARK_PERFORMANCE_TOOL_SCHEMA_v0_1.md",
  "specs/ARK_HR_TOOL_SCHEMA_PATCH_v0_1_to_v0_2.md",
  "specs/ARK_STAMMDATEN_PATCH_v1_5_to_v1_6_performance.md",
  "memory/project_performance_modul_decisions.md"
]
tags: [schema-patch, db-migration, performance, hr, views, materialized-views, rls, q1-c]
---

# ARK Database Schema Patch v1.5 → v1.6

**Scope:**
1. Streichung der 8 HR-Performance-Stubs aus DB §19 (Migration ins HR-Modul siehe `ARK_HR_TOOL_SCHEMA_PATCH_v0_1_to_v0_2.md`)
2. Hinzufügen 7 HR-Performance-Tabellen (in `ark.hr_*`-Schema)
3. Hinzufügen 14 Performance-Modul-Tabellen + 8 Live-Views + 8 Materialized Views
4. Erweiterung `dim_process_stages` + `dim_user`
5. Streichung redundanter Stubs (`fact_learning_progress`, `dim_skill_certifications`)

---

## 1. Streichungen aus DB §19 (PHASE 2 SCAFFOLD)

**Zu entfernen aus dem Phase-2-Scaffold-Block:**

```
PERFORMANCE:        fact_performance_reviews · fact_360_feedback · dim_feedback_questions · dim_feedback_cycles
ENTWICKLUNG:        fact_development_plans · fact_learning_progress · dim_learning_modules ·
                    dim_skill_certifications · fact_competency_ratings · dim_competency_framework
```

**Begründung:**
- `fact_performance_reviews`, `fact_360_feedback`, `dim_feedback_questions`, `dim_feedback_cycles`, `fact_development_plans`, `fact_competency_ratings`, `dim_competency_framework` → in HR-Modul (siehe HR-Patch)
- `fact_learning_progress`, `dim_learning_modules`, `dim_skill_certifications` → gestrichen (E-Learning Sub-A ist Single-Source via `fact_elearn_attempt`, `fact_elearn_assignment`, `fact_elearn_certificate`)

**§19-Ersatztext:**

```
PERFORMANCE-MODUL (eigenes ERP-Modul, siehe ARK_PERFORMANCE_TOOL_SCHEMA_v0_1.md):
  Snapshot-Layer:    fact_metric_snapshot_hourly/daily/weekly/monthly/quarterly/yearly
  Insight-Loop:      fact_insight · fact_action_item · fact_action_outcome
  Goals:             fact_perf_goal
  Reports:           dim_report_template · fact_report_run
  Forecast:          dim_forecast_conversion_rate · fact_forecast_snapshot
  Dashboards:        dim_dashboard_layout · dim_dashboard_tile_type · fact_dashboard_view_log
  Power-BI:          dim_powerbi_view
  Stammdaten:        dim_metric_definition · dim_anomaly_threshold

HR-PERFORMANCE-REVIEWS (im HR-Modul, siehe ARK_HR_TOOL_SCHEMA_PATCH_v0_1_to_v0_2.md):
  Cycles:            dim_feedback_cycles
  Questions:         dim_feedback_questions
  Reviews:           fact_performance_reviews · fact_360_feedback
  Competency:        dim_competency_framework · fact_competency_ratings
  Development:       fact_development_plans

E-LEARNING (existiert, Sub A-D):
  E-Learning ist Single-Source für Lern-Daten (fact_elearn_attempt, _assignment, _certificate, _badge).
  Performance-Modul liest nur via v_elearn_compliance.

GESTRICHEN (war in v1.5 §19):
  fact_learning_progress      → ersetzt durch fact_elearn_attempt
  dim_learning_modules        → ersetzt durch dim_elearn_course
  dim_skill_certifications    → ersetzt durch fact_elearn_certificate
```

---

## 2. Erweiterungen bestehender Tabellen

### 2.1 `dim_process_stages`

```sql
ALTER TABLE ark.dim_process_stages
    ADD COLUMN IF NOT EXISTS funnel_relevance VARCHAR(20) NOT NULL DEFAULT 'standard'
        CHECK (funnel_relevance IN ('standard', 'major_milestone', 'drop_off_risk', 'terminal')),
    ADD COLUMN IF NOT EXISTS avg_days_target SMALLINT NULL;

COMMENT ON COLUMN ark.dim_process_stages.funnel_relevance IS
    'Performance-Funnel-Klassifizierung: standard | major_milestone | drop_off_risk | terminal';
COMMENT ON COLUMN ark.dim_process_stages.avg_days_target IS
    'Soll-Verweildauer pro Stage in Tagen (für Stage-Velocity-KPI)';

-- Seeds (Updates, siehe Stammdaten-Patch §7.1):
UPDATE ark.dim_process_stages SET funnel_relevance='drop_off_risk', avg_days_target=5  WHERE stage_code='expose';
UPDATE ark.dim_process_stages SET funnel_relevance='major_milestone', avg_days_target=7  WHERE stage_code='cv_sent';
UPDATE ark.dim_process_stages SET funnel_relevance='drop_off_risk', avg_days_target=14 WHERE stage_code='ti';
UPDATE ark.dim_process_stages SET funnel_relevance='drop_off_risk', avg_days_target=14 WHERE stage_code='1st';
UPDATE ark.dim_process_stages SET funnel_relevance='drop_off_risk', avg_days_target=14 WHERE stage_code='2nd';
UPDATE ark.dim_process_stages SET funnel_relevance='drop_off_risk', avg_days_target=21 WHERE stage_code='3rd';
UPDATE ark.dim_process_stages SET funnel_relevance='standard',      avg_days_target=14 WHERE stage_code='assessment';
UPDATE ark.dim_process_stages SET funnel_relevance='major_milestone', avg_days_target=7  WHERE stage_code='offer';
UPDATE ark.dim_process_stages SET funnel_relevance='terminal',      avg_days_target=0  WHERE stage_code='placement';
```

### 2.2 `dim_user`

```sql
ALTER TABLE ark.dim_user
    ADD COLUMN IF NOT EXISTS performance_visibility_scope VARCHAR(20) NOT NULL DEFAULT 'self'
        CHECK (performance_visibility_scope IN ('self', 'team', 'tenant', 'admin'));

COMMENT ON COLUMN ark.dim_user.performance_visibility_scope IS
    'Performance-Modul-Sichtbarkeit: self (nur eigene) | team (eigenes Team) | tenant (komplett) | admin';

-- Seeds (Updates):
UPDATE ark.dim_user SET performance_visibility_scope='self'  WHERE role_code IN ('researcher', 'cm', 'am', 'ra', 'ma');
UPDATE ark.dim_user SET performance_visibility_scope='team'  WHERE role_code = 'head';
UPDATE ark.dim_user SET performance_visibility_scope='admin' WHERE role_code = 'admin';
```

---

## 3. Performance-Modul-Tabellen (CREATE)

Vollständige DDL siehe `ARK_PERFORMANCE_TOOL_SCHEMA_v0_1.md`. Hier nur Reihenfolge + Schema-Namen.

```sql
-- Schema-Namespace
CREATE SCHEMA IF NOT EXISTS ark_perf;

-- Extensions (idempotent)
CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE EXTENSION IF NOT EXISTS btree_gin;

-- ENUMs (siehe Performance-SCHEMA §3, 11 ENUMs)
-- ... (CREATE TYPE ... AS ENUM ...) für alle ENUMs

-- Stammdaten-Tabellen (§4)
CREATE TABLE ark_perf.dim_metric_definition (...);
CREATE TABLE ark_perf.dim_anomaly_threshold (...);
CREATE TABLE ark_perf.dim_dashboard_tile_type (...);
CREATE TABLE ark_perf.dim_dashboard_layout (...);
CREATE TABLE ark_perf.dim_report_template (...);
CREATE TABLE ark_perf.dim_powerbi_view (...);

-- Snapshot-Tabellen (§5) — partitioniert nach Monat
CREATE TABLE ark_perf.fact_metric_snapshot_hourly (...) PARTITION BY RANGE (snapshot_at);
CREATE TABLE ark_perf.fact_metric_snapshot_daily (...);
CREATE TABLE ark_perf.fact_metric_snapshot_weekly (...);
CREATE TABLE ark_perf.fact_metric_snapshot_monthly (...);
CREATE TABLE ark_perf.fact_metric_snapshot_quarterly (...);
CREATE TABLE ark_perf.fact_metric_snapshot_yearly (...);

-- Goals (§6)
CREATE TABLE ark_perf.fact_perf_goal (...);

-- Insight-Loop (§7)
CREATE TABLE ark_perf.fact_insight (...);
CREATE TABLE ark_perf.fact_action_item (...);
CREATE TABLE ark_perf.fact_action_outcome (...);

-- Reports (§8)
CREATE TABLE ark_perf.fact_report_run (...);

-- Forecast (§9)
CREATE TABLE ark_perf.dim_forecast_conversion_rate (...);
CREATE TABLE ark_perf.fact_forecast_snapshot (...);

-- Telemetrie (§10)
CREATE TABLE ark_perf.fact_dashboard_view_log (...);

-- Initiale Snapshot-Partitionen (laufender + nächster Monat)
CREATE TABLE ark_perf.fact_metric_snapshot_hourly_2026_04
    PARTITION OF ark_perf.fact_metric_snapshot_hourly
    FOR VALUES FROM ('2026-04-01') TO ('2026-05-01');
CREATE TABLE ark_perf.fact_metric_snapshot_hourly_2026_05
    PARTITION OF ark_perf.fact_metric_snapshot_hourly
    FOR VALUES FROM ('2026-05-01') TO ('2026-06-01');
-- ... weitere im partition-creator.worker (Cron monatlich für die nächsten 3 Monate)
```

---

## 4. HR-Performance-Tabellen (CREATE im hr-Schema)

Vollständige DDL siehe `ARK_HR_TOOL_SCHEMA_PATCH_v0_1_to_v0_2.md`. Reihenfolge:

```sql
CREATE SCHEMA IF NOT EXISTS ark_hr;
-- (oder bestehendes ark-Schema falls HR dort lebt)

-- ENUMs (HR-Patch §1, 7 ENUMs)
CREATE TYPE review_cycle_cadence AS ENUM (...);
CREATE TYPE review_state AS ENUM (...);
CREATE TYPE feedback_source_role AS ENUM (...);
CREATE TYPE question_type AS ENUM (...);
CREATE TYPE competency_level AS ENUM (...);
CREATE TYPE development_plan_state AS ENUM (...);

-- Tabellen
CREATE TABLE ark_hr.dim_feedback_cycles (...);
CREATE TABLE ark_hr.dim_feedback_questions (...);
CREATE TABLE ark_hr.fact_performance_reviews (...);
CREATE TABLE ark_hr.fact_360_feedback (...);
CREATE TABLE ark_hr.dim_competency_framework (...);
CREATE TABLE ark_hr.fact_competency_ratings (...);
CREATE TABLE ark_hr.fact_development_plans (...);
```

---

## 5. Live-Views (Performance-Modul liest READ-only)

Diese Views laufen Live (kein Snapshot). Für Drill-Downs + ad-hoc Queries.

### 5.1 `v_pipeline_funnel`

```sql
CREATE OR REPLACE VIEW ark_perf.v_pipeline_funnel AS
WITH stage_counts AS (
    SELECT
        p.tenant_id,
        p.assigned_user_id AS owner_id,
        u.team_id,
        u.sparte,
        m.business_model,
        s.stage_code,
        s.sort_order AS stage_order,
        s.funnel_relevance,
        s.avg_days_target,
        COUNT(*) AS process_count,
        SUM(p.expected_revenue_chf) AS pipeline_value_chf,
        AVG(EXTRACT(epoch FROM (NOW() - p.last_stage_change_at)) / 86400) AS avg_days_in_stage
    FROM ark.fact_process p
    JOIN ark.dim_process_stages s ON p.current_stage_id = s.id
    JOIN ark.dim_user u ON p.assigned_user_id = u.id
    LEFT JOIN ark.fact_mandate m ON p.mandate_id = m.id
    WHERE p.archived_at IS NULL
    GROUP BY p.tenant_id, p.assigned_user_id, u.team_id, u.sparte, m.business_model, s.stage_code, s.sort_order, s.funnel_relevance, s.avg_days_target
)
SELECT
    sc.*,
    -- Conversion-Rate vs nächster Stage
    LEAD(sc.process_count) OVER (PARTITION BY sc.tenant_id, sc.owner_id, sc.team_id, sc.sparte, sc.business_model ORDER BY sc.stage_order) AS next_stage_count,
    CASE WHEN sc.process_count > 0 THEN
        LEAD(sc.process_count) OVER (PARTITION BY sc.tenant_id, sc.owner_id, sc.team_id, sc.sparte, sc.business_model ORDER BY sc.stage_order)::numeric / sc.process_count
    ELSE NULL END AS conversion_to_next
FROM stage_counts sc;

GRANT SELECT ON ark_perf.v_pipeline_funnel TO ark_perf_reader;
```

### 5.2 `v_candidate_coverage`

```sql
CREATE OR REPLACE VIEW ark_perf.v_candidate_coverage AS
WITH last_touch AS (
    SELECT
        h.candidate_id,
        h.tenant_id,
        MAX(h.created_at) AS last_touch_at,
        COUNT(*) AS total_touches_12m,
        COUNT(*) FILTER (WHERE h.created_at > NOW() - INTERVAL '30 days') AS touches_30d
    FROM ark.fact_history h
    JOIN ark.dim_activity_types a ON h.activity_type_code = a.code
    WHERE h.candidate_id IS NOT NULL
        AND a.entity_relevance IN ('candidate', 'both')
        AND h.created_at > NOW() - INTERVAL '12 months'
    GROUP BY h.candidate_id, h.tenant_id
),
target_freq AS (
    -- Soll-Touch-Frequenz pro Stage
    SELECT
        c.id AS candidate_id,
        c.tenant_id,
        c.assigned_cm_id,
        c.sparte,
        s.stage_code AS current_stage,
        CASE s.stage_code
            WHEN 'cv_in' THEN INTERVAL '14 days'
            WHEN 'briefing' THEN INTERVAL '21 days'
            WHEN 'go_oral' THEN INTERVAL '7 days'
            WHEN 'go_written' THEN INTERVAL '7 days'
            ELSE INTERVAL '60 days'
        END AS target_touch_interval
    FROM ark.dim_candidate c
    LEFT JOIN ark.dim_candidate_stages s ON c.current_stage_id = s.id
    WHERE c.archived_at IS NULL AND c.do_not_contact = FALSE
)
SELECT
    t.candidate_id,
    t.tenant_id,
    t.assigned_cm_id,
    t.sparte,
    t.current_stage,
    t.target_touch_interval,
    lt.last_touch_at,
    lt.total_touches_12m,
    lt.touches_30d,
    EXTRACT(epoch FROM (NOW() - lt.last_touch_at)) / 86400 AS days_since_touch,
    CASE WHEN lt.last_touch_at IS NULL THEN 'never_touched'
         WHEN NOW() - lt.last_touch_at > t.target_touch_interval * 2 THEN 'critical'
         WHEN NOW() - lt.last_touch_at > t.target_touch_interval THEN 'overdue'
         ELSE 'ok' END AS coverage_state,
    -- Coverage-Score (0-100) — höher = besser
    LEAST(100, GREATEST(0,
        100 - 50 * (EXTRACT(epoch FROM (NOW() - COALESCE(lt.last_touch_at, t.target_touch_interval::TEXT::timestamptz))) / EXTRACT(epoch FROM t.target_touch_interval) - 1)
    )) AS coverage_score
FROM target_freq t
LEFT JOIN last_touch lt ON t.candidate_id = lt.candidate_id;

GRANT SELECT ON ark_perf.v_candidate_coverage TO ark_perf_reader;
```

### 5.3 `v_account_coverage`

```sql
CREATE OR REPLACE VIEW ark_perf.v_account_coverage AS
WITH last_touch AS (
    SELECT
        h.account_id,
        h.tenant_id,
        MAX(h.created_at) AS last_touch_at,
        COUNT(*) FILTER (WHERE h.created_at > NOW() - INTERVAL '90 days') AS touches_90d
    FROM ark.fact_history h
    JOIN ark.dim_activity_types a ON h.activity_type_code = a.code
    WHERE h.account_id IS NOT NULL
        AND a.entity_relevance IN ('account', 'both')
        AND h.created_at > NOW() - INTERVAL '12 months'
    GROUP BY h.account_id, h.tenant_id
)
SELECT
    a.id AS account_id,
    a.tenant_id,
    a.assigned_am_id,
    a.purchase_potential,
    a.has_active_mandate,
    lt.last_touch_at,
    lt.touches_90d,
    EXTRACT(epoch FROM (NOW() - lt.last_touch_at)) / 86400 AS days_since_touch,
    -- Soll-Frequenz: ★★★ alle 30d, ★★ alle 60d, ★ alle 120d
    CASE a.purchase_potential
        WHEN 3 THEN 30
        WHEN 2 THEN 60
        ELSE 120
    END AS target_days,
    CASE
        WHEN lt.last_touch_at IS NULL THEN 'never_touched'
        WHEN EXTRACT(epoch FROM (NOW() - lt.last_touch_at)) / 86400 > (CASE a.purchase_potential WHEN 3 THEN 60 WHEN 2 THEN 120 ELSE 240 END) THEN 'critical'
        WHEN EXTRACT(epoch FROM (NOW() - lt.last_touch_at)) / 86400 > (CASE a.purchase_potential WHEN 3 THEN 30 WHEN 2 THEN 60 ELSE 120 END) THEN 'overdue'
        ELSE 'ok'
    END AS coverage_state
FROM ark.dim_account a
LEFT JOIN last_touch lt ON a.id = lt.account_id
WHERE a.archived_at IS NULL;

GRANT SELECT ON ark_perf.v_account_coverage TO ark_perf_reader;
```

### 5.4 `v_mandate_kpi_status`

```sql
CREATE OR REPLACE VIEW ark_perf.v_mandate_kpi_status AS
SELECT
    m.id AS mandate_id,
    m.tenant_id,
    m.code,
    m.label_de,
    m.business_model,
    m.sparte,
    m.account_id,
    m.state,
    -- Ident-Target vs Actual
    m.ident_target,
    (SELECT COUNT(*) FROM ark.fact_process p WHERE p.mandate_id = m.id AND p.first_identified_at IS NOT NULL) AS ident_actual,
    -- Call-Target vs Actual
    m.call_target,
    (SELECT COUNT(*) FROM ark.fact_history h WHERE h.mandate_id = m.id AND h.activity_type_code IN ('call_outbound', 'call_attempt')) AS call_actual,
    -- Shortlist
    m.shortlist_size_target,
    (SELECT COUNT(*) FROM ark.fact_process p WHERE p.mandate_id = m.id AND p.cv_sent_at IS NOT NULL) AS shortlist_actual,
    -- Placements
    (SELECT COUNT(*) FROM ark.fact_placement pl JOIN ark.fact_process p ON pl.process_id = p.id WHERE p.mandate_id = m.id) AS placements_actual,
    -- Revenue
    (SELECT COALESCE(SUM(i.amount_paid), 0) FROM ark.fact_invoice i WHERE i.mandate_id = m.id AND i.state = 'paid') AS revenue_actual_chf
FROM ark.fact_mandate m
WHERE m.archived_at IS NULL;

GRANT SELECT ON ark_perf.v_mandate_kpi_status TO ark_perf_reader;
```

### 5.5 `v_revenue_attribution`

```sql
CREATE OR REPLACE VIEW ark_perf.v_revenue_attribution AS
SELECT
    i.tenant_id,
    i.id AS invoice_id,
    i.amount_paid AS revenue_chf,
    i.paid_at,
    DATE_TRUNC('month', i.paid_at) AS revenue_month,
    DATE_TRUNC('quarter', i.paid_at) AS revenue_quarter,
    DATE_TRUNC('year', i.paid_at) AS revenue_year,
    p.id AS placement_id,
    pr.id AS process_id,
    pr.cm_user_id,
    pr.am_user_id,
    pr.researcher_user_id,
    m.id AS mandate_id,
    m.business_model,
    m.sparte,
    a.id AS account_id,
    a.label_de AS account_label,
    -- Commission-Refs
    cl_cm.amount_chf AS commission_cm_chf,
    cl_am.amount_chf AS commission_am_chf,
    cl_research.amount_chf AS commission_research_chf
FROM ark.fact_invoice i
LEFT JOIN ark.fact_placement p ON i.placement_id = p.id
LEFT JOIN ark.fact_process pr ON p.process_id = pr.id
LEFT JOIN ark.fact_mandate m ON pr.mandate_id = m.id
LEFT JOIN ark.dim_account a ON COALESCE(m.account_id, pr.account_id) = a.id
LEFT JOIN ark.fact_commission_ledger cl_cm ON cl_cm.placement_id = p.id AND cl_cm.role = 'cm'
LEFT JOIN ark.fact_commission_ledger cl_am ON cl_am.placement_id = p.id AND cl_am.role = 'am'
LEFT JOIN ark.fact_commission_ledger cl_research ON cl_research.placement_id = p.id AND cl_research.role = 'researcher'
WHERE i.state = 'paid' AND i.archived_at IS NULL;

GRANT SELECT ON ark_perf.v_revenue_attribution TO ark_perf_reader;
```

### 5.6 `v_activity_heatmap`

```sql
CREATE OR REPLACE VIEW ark_perf.v_activity_heatmap AS
SELECT
    h.tenant_id,
    h.created_by_user_id AS user_id,
    DATE(h.created_at) AS activity_date,
    EXTRACT(dow FROM h.created_at) AS day_of_week,  -- 0=Sonntag
    EXTRACT(hour FROM h.created_at) AS hour_of_day,
    h.activity_type_code,
    a.category AS activity_category,
    COUNT(*) AS activity_count
FROM ark.fact_history h
JOIN ark.dim_activity_types a ON h.activity_type_code = a.code
WHERE h.created_at > NOW() - INTERVAL '12 months'
GROUP BY h.tenant_id, h.created_by_user_id, DATE(h.created_at), EXTRACT(dow FROM h.created_at), EXTRACT(hour FROM h.created_at), h.activity_type_code, a.category;

GRANT SELECT ON ark_perf.v_activity_heatmap TO ark_perf_reader;
```

### 5.7 `v_elearn_compliance`

```sql
CREATE OR REPLACE VIEW ark_perf.v_elearn_compliance AS
SELECT
    u.tenant_id,
    u.id AS user_id,
    u.label_de,
    u.role_code,
    -- Pflicht-Kurse
    COUNT(*) FILTER (WHERE asg.is_mandatory = TRUE) AS mandatory_assignments,
    COUNT(*) FILTER (WHERE asg.is_mandatory = TRUE AND asg.completed_at IS NOT NULL) AS mandatory_completed,
    COUNT(*) FILTER (WHERE asg.is_mandatory = TRUE AND asg.completed_at IS NULL AND asg.due_at < NOW()) AS mandatory_overdue,
    -- Compliance-Score (% Pflicht-Kurse erledigt)
    CASE WHEN COUNT(*) FILTER (WHERE asg.is_mandatory = TRUE) > 0
         THEN COUNT(*) FILTER (WHERE asg.is_mandatory = TRUE AND asg.completed_at IS NOT NULL)::numeric / COUNT(*) FILTER (WHERE asg.is_mandatory = TRUE) * 100
         ELSE 100 END AS compliance_pct,
    -- Newsletter-Compliance
    (SELECT COUNT(*) FROM ark_elearn.fact_elearn_attempt att
     WHERE att.user_id = u.id AND att.attempt_kind = 'newsletter' AND att.passed = TRUE
       AND att.created_at > NOW() - INTERVAL '30 days') AS newsletter_quizzes_30d,
    -- Certificates aktiv
    (SELECT COUNT(*) FROM ark_elearn.fact_elearn_certificate cert
     WHERE cert.user_id = u.id AND cert.expired_at IS NULL) AS active_certificates
FROM ark.dim_user u
LEFT JOIN ark_elearn.fact_elearn_assignment asg ON asg.user_id = u.id
WHERE u.archived_at IS NULL
GROUP BY u.tenant_id, u.id, u.label_de, u.role_code;

GRANT SELECT ON ark_perf.v_elearn_compliance TO ark_perf_reader;
```

### 5.8 `v_zeit_utilization`

```sql
CREATE OR REPLACE VIEW ark_perf.v_zeit_utilization AS
SELECT
    u.tenant_id,
    u.id AS user_id,
    u.label_de,
    DATE_TRUNC('month', te.work_date) AS month,
    SUM(te.duration_minutes) / 60.0 AS hours_worked,
    SUM(CASE WHEN ab.absence_type = 'sick' THEN ab.duration_days ELSE 0 END) AS sick_days,
    SUM(CASE WHEN ab.absence_type = 'vacation' THEN ab.duration_days ELSE 0 END) AS vacation_days,
    -- Soll-Stunden basierend auf Pensum
    (u.contract_pensum_pct / 100.0 * 173.33) AS target_hours_monthly,  -- 173.33 = 100% Schweizer Standard
    -- Auslastung
    CASE WHEN u.contract_pensum_pct > 0 THEN
        SUM(te.duration_minutes) / 60.0 / (u.contract_pensum_pct / 100.0 * 173.33) * 100
    ELSE NULL END AS utilization_pct
FROM ark.dim_user u
LEFT JOIN ark.fact_time_entries te ON te.user_id = u.id
LEFT JOIN ark.fact_absences ab ON ab.user_id = u.id AND DATE_TRUNC('month', ab.start_date) = DATE_TRUNC('month', te.work_date)
WHERE u.archived_at IS NULL
GROUP BY u.tenant_id, u.id, u.label_de, DATE_TRUNC('month', te.work_date), u.contract_pensum_pct;

GRANT SELECT ON ark_perf.v_zeit_utilization TO ark_perf_reader;
```

### 5.9 `v_hr_review_summary` (HR-Performance-Brücke)

Bereits im HR-Patch definiert (`ARK_HR_TOOL_SCHEMA_PATCH_v0_1_to_v0_2.md` §9). Performance-Modul liest via:

```sql
GRANT SELECT ON ark_hr.v_hr_review_summary TO ark_perf_reader;
```

### 5.10 `v_commission_run_rate`

```sql
CREATE OR REPLACE VIEW ark_perf.v_commission_run_rate AS
SELECT
    cl.tenant_id,
    cl.user_id,
    DATE_TRUNC('month', cl.posted_at) AS month,
    cl.role,
    SUM(cl.amount_chf) AS commission_chf,
    COUNT(*) AS commission_events
FROM ark.fact_commission_ledger cl
WHERE cl.archived_at IS NULL
GROUP BY cl.tenant_id, cl.user_id, DATE_TRUNC('month', cl.posted_at), cl.role;

GRANT SELECT ON ark_perf.v_commission_run_rate TO ark_perf_reader;
```

---

## 6. Materialized Views für Power-BI (8 Views, Q4=D)

### 6.1 `mv_perf_pipeline_today` (hourly)

```sql
CREATE MATERIALIZED VIEW ark_perf.mv_perf_pipeline_today AS
SELECT
    tenant_id, owner_id, team_id, sparte, business_model, stage_code, stage_order, funnel_relevance,
    process_count, pipeline_value_chf, avg_days_in_stage, conversion_to_next,
    NOW() AS refresh_at
FROM ark_perf.v_pipeline_funnel
WHERE TRUE;  -- Snapshot

CREATE UNIQUE INDEX idx_mv_pipeline_today_pk
    ON ark_perf.mv_perf_pipeline_today (tenant_id, owner_id, sparte, business_model, stage_code);

-- Refresh-Worker pattern:
-- REFRESH MATERIALIZED VIEW CONCURRENTLY ark_perf.mv_perf_pipeline_today;
```

### 6.2 `mv_perf_goal_drift_critical` (hourly)

```sql
CREATE MATERIALIZED VIEW ark_perf.mv_perf_goal_drift_critical AS
WITH goal_progress AS (
    SELECT
        g.id AS goal_id,
        g.tenant_id,
        g.user_id,
        g.metric_code,
        g.target_value,
        g.target_direction,
        g.period_start,
        g.period_end,
        s.metric_value AS current_value,
        EXTRACT(epoch FROM (NOW() - g.period_start)) / EXTRACT(epoch FROM (g.period_end - g.period_start)) AS period_progress,
        s.metric_value / NULLIF(g.target_value, 0) AS achievement_ratio
    FROM ark_perf.fact_perf_goal g
    JOIN LATERAL (
        SELECT metric_value FROM ark_perf.fact_metric_snapshot_daily
        WHERE metric_code = g.metric_code AND scope_type = 'user' AND scope_value::uuid = g.user_id
        ORDER BY snapshot_date DESC LIMIT 1
    ) s ON TRUE
    WHERE g.cancelled_at IS NULL AND g.period_end > NOW()
)
SELECT
    *,
    -- Drift = (achievement_ratio - period_progress) * 100
    CASE g.target_direction
        WHEN 'higher' THEN (achievement_ratio - period_progress) * 100
        ELSE (period_progress - achievement_ratio) * 100
    END AS drift_pct,
    NOW() AS refresh_at
FROM goal_progress g
WHERE
    CASE g.target_direction
        WHEN 'higher' THEN (achievement_ratio - period_progress) * 100
        ELSE (period_progress - achievement_ratio) * 100
    END < -20;  -- nur critical Drift

CREATE UNIQUE INDEX idx_mv_goal_drift_pk
    ON ark_perf.mv_perf_goal_drift_critical (goal_id);
```

### 6.3 `mv_perf_coverage_critical` (hourly)

```sql
CREATE MATERIALIZED VIEW ark_perf.mv_perf_coverage_critical AS
SELECT
    'candidate' AS entity_type,
    candidate_id AS entity_id,
    tenant_id,
    assigned_cm_id AS owner_id,
    sparte,
    days_since_touch,
    coverage_state,
    coverage_score,
    NOW() AS refresh_at
FROM ark_perf.v_candidate_coverage
WHERE coverage_state IN ('critical', 'never_touched')
UNION ALL
SELECT
    'account' AS entity_type,
    account_id AS entity_id,
    tenant_id,
    assigned_am_id AS owner_id,
    NULL::text AS sparte,
    days_since_touch,
    coverage_state,
    NULL::numeric AS coverage_score,
    NOW() AS refresh_at
FROM ark_perf.v_account_coverage
WHERE coverage_state IN ('critical', 'never_touched');

CREATE UNIQUE INDEX idx_mv_coverage_critical_pk
    ON ark_perf.mv_perf_coverage_critical (entity_type, entity_id);
```

### 6.4 `mv_perf_revenue_monthly` (monthly)

```sql
CREATE MATERIALIZED VIEW ark_perf.mv_perf_revenue_monthly AS
SELECT
    tenant_id,
    revenue_month,
    sparte,
    business_model,
    cm_user_id,
    am_user_id,
    SUM(revenue_chf) AS total_revenue_chf,
    COUNT(*) AS placement_count,
    SUM(commission_cm_chf) AS commission_cm_total,
    SUM(commission_am_chf) AS commission_am_total,
    SUM(commission_research_chf) AS commission_research_total,
    NOW() AS refresh_at
FROM ark_perf.v_revenue_attribution
GROUP BY tenant_id, revenue_month, sparte, business_model, cm_user_id, am_user_id;

CREATE UNIQUE INDEX idx_mv_revenue_monthly_pk
    ON ark_perf.mv_perf_revenue_monthly (tenant_id, revenue_month, sparte, business_model, cm_user_id, am_user_id);
```

### 6.5-6.8 Weitere Materialized Views

`mv_perf_pipeline_funnel_daily`, `mv_perf_cohort_hunt_vintage`, `mv_perf_activity_heatmap_weekly`, `mv_perf_elearn_compliance_daily` — analoges Pattern. SQL aus Live-Views aggregiert pro Snapshot-Periode + UNIQUE-Index für CONCURRENT REFRESH.

---

## 7. RLS-Policies (sammlung)

Alle `fact_perf_*`, `fact_insight`, `fact_action_*`, `fact_report_run`, `fact_forecast_*`, `dim_dashboard_layout`, `fact_metric_snapshot_*`, `fact_dashboard_view_log` sowie HR-Performance-Tabellen (`fact_performance_reviews`, `fact_360_feedback`, `fact_competency_ratings`, `fact_development_plans`, `dim_feedback_cycles`, `dim_feedback_questions`, `dim_competency_framework`):

```sql
-- Tenant-Isolation (alle)
ALTER TABLE <table> ENABLE ROW LEVEL SECURITY;
CREATE POLICY <name>_tenant_isolation ON <table>
    USING (tenant_id = current_setting('app.tenant_id')::uuid);

-- Worker-Bypass (für Snapshot-Worker)
CREATE ROLE ark_worker_service NOLOGIN;
ALTER TABLE <table> FORCE ROW LEVEL SECURITY;  -- forciert RLS auch für Owner-Rolle
CREATE POLICY <name>_worker_bypass ON <table>
    TO ark_worker_service
    USING (TRUE)
    WITH CHECK (TRUE);
```

---

## 8. Berechtigungs-Rollen

```sql
-- Power-BI Read-Only
CREATE ROLE powerbi_reader NOLOGIN;
GRANT USAGE ON SCHEMA ark_perf TO powerbi_reader;
GRANT SELECT ON ALL MATERIALIZED VIEWS IN SCHEMA ark_perf TO powerbi_reader;
ALTER DEFAULT PRIVILEGES IN SCHEMA ark_perf GRANT SELECT ON MATERIALIZED VIEWS TO powerbi_reader;

-- Performance-Modul-Reader (für Live-Views, falls anders gehandelt)
CREATE ROLE ark_perf_reader NOLOGIN;
GRANT USAGE ON SCHEMA ark_perf TO ark_perf_reader;
GRANT SELECT ON ALL TABLES IN SCHEMA ark_perf TO ark_perf_reader;
GRANT SELECT ON ark_hr.v_hr_review_summary TO ark_perf_reader;
GRANT SELECT ON ark.fact_history TO ark_perf_reader;  -- für Live-Aggregation
GRANT SELECT ON ark.fact_process TO ark_perf_reader;
GRANT SELECT ON ark.fact_mandate TO ark_perf_reader;
GRANT SELECT ON ark.fact_invoice TO ark_perf_reader;
GRANT SELECT ON ark.fact_placement TO ark_perf_reader;
GRANT SELECT ON ark.fact_commission_ledger TO ark_perf_reader;
GRANT SELECT ON ark.dim_candidate TO ark_perf_reader;
GRANT SELECT ON ark.dim_account TO ark_perf_reader;
GRANT SELECT ON ark.dim_user TO ark_perf_reader;
GRANT SELECT ON ark.fact_time_entries TO ark_perf_reader;
GRANT SELECT ON ark.fact_absences TO ark_perf_reader;
GRANT SELECT ON ark_elearn.fact_elearn_attempt TO ark_perf_reader;
GRANT SELECT ON ark_elearn.fact_elearn_assignment TO ark_perf_reader;
GRANT SELECT ON ark_elearn.fact_elearn_certificate TO ark_perf_reader;

-- Worker-Service (für Snapshot-Writes mit RLS-Bypass)
CREATE ROLE ark_worker_service NOLOGIN;
GRANT USAGE ON SCHEMA ark_perf TO ark_worker_service;
GRANT INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA ark_perf TO ark_worker_service;
```

---

## 9. Migration-Reihenfolge (Production-Deploy)

1. **Backup** der bestehenden DB
2. CREATE EXTENSIONS (idempotent)
3. CREATE SCHEMA ark_perf, ark_hr (oder bestehend)
4. CREATE all ENUMs (Performance + HR-Patch)
5. CREATE Stammdaten-Tabellen (dim_*) — Performance + HR
6. CREATE Snapshot-Tabellen + Initial-Partitionen — Performance
7. CREATE Goal/Insight/Action/Report/Forecast/Telemetrie-Tabellen — Performance
8. CREATE Performance-Reviews/Feedback/Competency/Dev-Plans-Tabellen — HR
9. CREATE Live-Views (10 Views)
10. CREATE Materialized Views (8 Views) + UNIQUE-Indizes
11. ALTER TABLE dim_process_stages + dim_user (Erweiterungen + Updates)
12. INSERT Stammdaten-Seeds (siehe Stammdaten-Patch)
13. ENABLE RLS + CREATE Policies (alle neuen Tabellen)
14. CREATE Roles (powerbi_reader, ark_perf_reader, ark_worker_service)
15. GRANT Permissions
16. Verify: SELECT count(*) für alle Seeds, EXPLAIN auf alle Views, Materialized-View-Initial-Refresh
17. Drop unused Phase-2-Scaffold-Tabellen aus DB §19 (wenn sie als CREATE TABLE existierten — falls nur als Comment in §19, nichts zu tun)

---

## 10. Rollback-Strategie

```sql
-- Vollständiger Rollback (NICHT für Production wenn Daten drin sind!)
DROP SCHEMA ark_perf CASCADE;
-- HR-Tabellen einzeln droppen wenn nötig (Daten würden verloren!)
DROP TABLE ark_hr.fact_development_plans CASCADE;
-- ... etc.

-- Partielles Rollback nur für Erweiterungen:
ALTER TABLE ark.dim_process_stages DROP COLUMN funnel_relevance, DROP COLUMN avg_days_target;
ALTER TABLE ark.dim_user DROP COLUMN performance_visibility_scope;

-- Empfehlung: Für Produktion Migrations-Reverse-Skripte separat pflegen
```

---

## 11. Performance-Erwägungen

- **Partitionierung Snapshots:** monatliche Range-Partitions, automatische Erstellung via Cron
- **Indizes:** kompakt, fokussiert auf häufige Queries (nicht über-indexiert — INSERT-Performance!)
- **Materialized Views Refresh:** CONCURRENT (kein Lock auf Read), Worker-koordiniert
- **JSONB-Felder:** btree_gin-Index nur wo Filter darauf läuft (audit_trail meist nicht durchsucht)
- **Snapshot-Volumen:** ~33 Metriken × ~500 Scopes × 365 Tage = ~6 Mio Rows/Jahr für daily — vertretbar für PostgreSQL
- **Hourly-Snapshots:** nur Critical-Views, ~10 Metriken × ~50 Scopes × 24 Std × 365 = ~4 Mio Rows/Jahr
- **Retention-Cleaner:** wöchentlich, löscht alte Snapshots gemäss `retention_until`

---

## 12. Acceptance Criteria

- [ ] §19 Streichungen umgesetzt (Code-Comment-Update in DB v1.6)
- [ ] 14 Performance-Tabellen + 7 HR-Performance-Tabellen erstellt mit RLS
- [ ] 10 Live-Views funktional (`v_pipeline_funnel`, `v_candidate_coverage`, ...)
- [ ] 8 Materialized Views erstellt + erste Refresh erfolgreich
- [ ] Erweiterungen `dim_process_stages` + `dim_user` deployed + Seeds geupdated
- [ ] 3 Rollen (`powerbi_reader`, `ark_perf_reader`, `ark_worker_service`) erstellt + GRANTs
- [ ] Initial-Partitionen für aktuellen + nächsten Monat (hourly) erstellt
- [ ] EXPLAIN auf alle Views < 1s für Standard-Filter
- [ ] Materialized-View-Refresh < 5min für alle 8 Views beim Initial-Run
- [ ] Backup-Strategie + Rollback-Skripte vorhanden
