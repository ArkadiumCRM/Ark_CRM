# ARK CRM — DB-Schema-Patch · E-Learning Sub C · v0.1

**Scope:** Datenmodell-Erweiterung für den Wochen-Newsletter (Sub C).
**Zielversion:** gemeinsam mit Sub-A/B-Patches im nächsten Grundlagen-Version-Bump.
**Basis-Specs:** `specs/ARK_E_LEARNING_SUB_C_SCHEMA_v0_1.md`, `specs/ARK_E_LEARNING_SUB_C_INTERACTIONS_v0_1.md`.
**Vorherige Patches:** `specs/ARK_DATABASE_SCHEMA_PATCH_ELEARNING_v0_1.md` (Sub A), `…_SUB_B_v0_1.md` (Sub B).
**Stand:** 2026-04-20
**Status:** Review ausstehend (Peter)

---

## Changelog

| # | Tabelle | Änderung | Typ |
|---|---------|----------|-----|
| 1 | `dim_elearn_newsletter_issue` | NEU | CREATE |
| 2 | `dim_elearn_newsletter_subscription` | NEU | CREATE |
| 3 | `fact_elearn_newsletter_assignment` | NEU | CREATE |
| 4 | `fact_elearn_newsletter_section_read` | NEU | CREATE |
| 5 | `dim_user.newsletter_enforcement_override` | neue Spalte (TEXT, nullable) | ALTER |
| 6 | Indizes | 6 neue | INDEX |
| 7 | CHECK-Constraints | 5 neue | ALTER CHECK |
| 8 | Tenant-Settings | JSONB-Key `elearn_c.*` | DATA |

---

## 1. Neue Tabellen

Vollständige DDL in `ARK_E_LEARNING_SUB_C_SCHEMA_v0_1.md §4`. Kurzform:

```sql
dim_elearn_newsletter_issue (issue_id PK, tenant_id, sparte, issue_week, publish_at,
                             title, sections JSONB, quiz_module_id, quiz_pass_threshold,
                             enforcement_mode, generation_job_id, status, published_at, created_at,
                             UNIQUE(tenant_id, sparte, issue_week))

dim_elearn_newsletter_subscription (sub_id PK, tenant_id, ma_id, sparte, mode,
                                    enforcement_override, created_at,
                                    UNIQUE(tenant_id, ma_id, sparte))

fact_elearn_newsletter_assignment (assignment_id PK, tenant_id, ma_id, issue_id FK,
                                   assigned_at, deadline, read_started_at, read_completed_at,
                                   quiz_attempt_id FK, status, reminder_sent_at,
                                   escalated_to_head_at, enforcement_mode_applied,
                                   UNIQUE(tenant_id, ma_id, issue_id))

fact_elearn_newsletter_section_read (read_id PK, tenant_id, assignment_id FK,
                                     section_idx, scroll_pct, time_spent_sec, read_at,
                                     UNIQUE(tenant_id, assignment_id, section_idx))
```

## 2. ALTER bestehender Tabellen

```sql
ALTER TABLE dim_user ADD COLUMN newsletter_enforcement_override TEXT;
-- NULL = tenant default; 'soft' | 'hard'
```

## 3. Indizes

```sql
CREATE INDEX ON dim_elearn_newsletter_issue (tenant_id, sparte, issue_week);
CREATE INDEX ON dim_elearn_newsletter_issue (tenant_id, status, publish_at);
CREATE INDEX ON dim_elearn_newsletter_subscription (tenant_id, ma_id);
CREATE INDEX ON fact_elearn_newsletter_assignment (tenant_id, ma_id, status)
  WHERE status IN ('pending','reading','quiz_in_progress');
CREATE INDEX ON fact_elearn_newsletter_assignment (tenant_id, deadline)
  WHERE status NOT IN ('quiz_passed','expired');
CREATE INDEX ON fact_elearn_newsletter_section_read (tenant_id, assignment_id, section_idx);
```

## 4. CHECK-Constraints

```sql
ALTER TABLE dim_elearn_newsletter_issue ADD CONSTRAINT ck_nl_issue_status
  CHECK (status IN ('draft','review','published','archived'));

ALTER TABLE dim_elearn_newsletter_issue ADD CONSTRAINT ck_nl_issue_enforcement
  CHECK (enforcement_mode IN ('soft','hard'));

ALTER TABLE dim_elearn_newsletter_subscription ADD CONSTRAINT ck_nl_sub_mode
  CHECK (mode IN ('auto','opt_in','opt_out'));

ALTER TABLE dim_elearn_newsletter_subscription ADD CONSTRAINT ck_nl_sub_enforcement
  CHECK (enforcement_override IS NULL OR enforcement_override IN ('soft','hard'));

ALTER TABLE fact_elearn_newsletter_assignment ADD CONSTRAINT ck_nl_assignment_status
  CHECK (status IN ('pending','reading','quiz_in_progress','quiz_passed','quiz_failed','expired'));

ALTER TABLE fact_elearn_newsletter_assignment ADD CONSTRAINT ck_nl_assignment_enforcement
  CHECK (enforcement_mode_applied IN ('soft','hard'));

ALTER TABLE dim_user ADD CONSTRAINT ck_user_newsletter_enforcement
  CHECK (newsletter_enforcement_override IS NULL OR newsletter_enforcement_override IN ('soft','hard'));
```

## 5. Tenant-Settings (Seed)

```sql
UPDATE dim_elearn_tenant SET settings = settings || '{
  "elearn_c": {
    "enforcement_mode": "soft",
    "publish_day_cron": "0 6 * * 1",
    "reminder_hours": 48,
    "escalation_days": 7,
    "expiry_days": 14,
    "sparten_enabled": ["ARC","GT","ING","PUR","REM"],
    "sparte_uebergreifend_enabled": true,
    "archive_retention_months": 24,
    "max_sections_per_issue": 6,
    "max_questions_per_quiz": 10,
    "min_sections_per_issue": 3,
    "min_questions_per_quiz": 3,
    "allow_auto_opt_out": false
  }
}'::jsonb;
```

## 6. Interop mit Sub A

Newsletter-Quiz nutzt `fact_elearn_quiz_attempt` mit `attempt_kind='newsletter'` (bereits in Sub A vorbereitet). Pro Issue wird ein synthetischer `dim_elearn_module` angelegt (Owner: versteckter Newsletter-Kurs `dim_elearn_course` pro Tenant mit `slug='__newsletter__'`). Quiz-Fragen in `dim_elearn_question` via `module_id`.

## 7. Migration-Script

`migrations/NNN_elearn_sub_c_newsletter.sql`:

1. `CREATE TABLE` für 4 neue Tabellen.
2. `ALTER TABLE dim_user ADD COLUMN`.
3. `CREATE INDEX`.
4. `ALTER TABLE … ADD CONSTRAINT`.
5. `UPDATE dim_elearn_tenant SET settings` (idempotent JSONB-Merge).
6. Seed: versteckter Newsletter-Kurs `dim_elearn_course (slug='__newsletter__', status='archived', title='Newsletter-Quizzes')` pro Tenant.

Rollback via `DROP TABLE … CASCADE` + Settings-Cleanup.

## 8. Offene Punkte

- **Sparte-übergreifender Newsletter:** als extra Sparte-Wert `'uebergreifend'` modellieren oder als separates Flag? Entschieden: Sparte-Wert `'uebergreifend'` (konsistent mit bestehenden Sparten-Feldern; kein zusätzliches Flag).
- **Versteckter Newsletter-Kurs-Owner:** damit Admin nicht versehentlich diesen Kurs im Kurs-Katalog bearbeiten kann → UI-Filter per Slug-Prefix `__`.
