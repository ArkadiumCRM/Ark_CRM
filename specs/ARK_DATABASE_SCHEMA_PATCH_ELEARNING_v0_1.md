# ARK CRM — DB-Schema-Patch · E-Learning · v0.1

**Scope:** Datenmodell-Erweiterung für das neue Phase-3-ERP-Modul E-Learning (Sub A · Kurs-Katalog).
**Zielversion:** `ARK_DATABASE_SCHEMA_v1_4.md` bzw. `v1_5.md` (finale Version beim Merge von Peter festzulegen; baut auf dem Activity-Types-Patch `v1_3_to_v1_4` auf).
**Basis-Specs:** `specs/ARK_E_LEARNING_SUB_A_SCHEMA_v0_1.md`, `specs/ARK_E_LEARNING_SUB_A_INTERACTIONS_v0_1.md`.
**Stand:** 2026-04-20
**Status:** Review ausstehend (Peter)

---

## Changelog

| # | Tabelle | Änderung | Typ |
|---|---------|----------|-----|
| 1 | `dim_elearn_tenant` | NEU (Multi-Tenant-Setup) | CREATE |
| 2 | `dim_elearn_course` | NEU | CREATE |
| 3 | `dim_elearn_module` | NEU | CREATE |
| 4 | `dim_elearn_lesson` | NEU | CREATE |
| 5 | `dim_elearn_question` | NEU (Fragen-Pool pro Modul) | CREATE |
| 6 | `dim_elearn_curriculum_template` | NEU | CREATE |
| 7 | `fact_elearn_curriculum_override` | NEU | CREATE |
| 8 | `fact_elearn_assignment` | NEU | CREATE |
| 9 | `fact_elearn_enrollment` | NEU | CREATE |
| 10 | `fact_elearn_progress` | NEU (Lesson-Tracking) | CREATE |
| 11 | `fact_elearn_quiz_attempt` | NEU | CREATE |
| 12 | `fact_elearn_freitext_review` | NEU | CREATE |
| 13 | `dim_elearn_certificate` | NEU | CREATE |
| 14 | `dim_elearn_badge` | NEU | CREATE |
| 15 | `fact_elearn_import_log` | NEU | CREATE |
| 16 | `dim_user.elearn_onboarding_active` | NEU Spalte (BOOLEAN DEFAULT false) | ALTER |
| 17 | Indizes | 5 neue für Queue/Scope-Performance | INDEX |

**Nicht Teil dieses Patches:**
- Gate-Enforcement-Tabellen (Sub D, späterer Patch).
- Newsletter-Spezifika (Sub C, späterer Patch — Schema via `attempt_kind='newsletter'` bereits vorbereitet).
- RLS-Policies (gehören in Backend-Architektur-Patch).

---

## 1. Neue Tabellen

Vollständige DDL-Definitionen siehe `ARK_E_LEARNING_SUB_A_SCHEMA_v0_1.md §4`. Kurz-Referenz:

### 1.1 Tenant + Content

```sql
dim_elearn_tenant (tenant_id PK, name, settings JSONB, created_at)
dim_elearn_course (course_id PK, tenant_id, slug, title, description, sparten[], rollen[],
                   duration_min, refresher_months, pretest_enabled, pretest_pass_threshold,
                   pass_threshold, version, content_hash, status, published_at,
                   created_at, updated_at, UNIQUE(tenant_id, slug))
dim_elearn_module (module_id PK, tenant_id, course_id FK, slug, order_idx, title, description,
                   content_hash, UNIQUE(tenant_id, course_id, slug),
                   UNIQUE(tenant_id, course_id, order_idx))
dim_elearn_lesson (lesson_id PK, tenant_id, module_id FK, slug, order_idx, title, content_md,
                   min_read_seconds, content_hash, UNIQUE(tenant_id, module_id, slug),
                   UNIQUE(tenant_id, module_id, order_idx))
dim_elearn_question (question_id PK, tenant_id, module_id FK, type, payload JSONB,
                     version, content_hash, created_at)
```

### 1.2 Zuweisung / Onboarding

```sql
dim_elearn_curriculum_template (template_id PK, tenant_id, sparte NULLABLE, rolle,
                                course_ids UUID[], created_by, updated_at,
                                UNIQUE(tenant_id, sparte, rolle))
fact_elearn_curriculum_override (override_id PK, tenant_id, ma_id, course_ids UUID[],
                                 reason, overridden_by, created_at,
                                 UNIQUE(tenant_id, ma_id))
fact_elearn_assignment (assignment_id PK, tenant_id, ma_id, course_id FK, reason, deadline,
                        assigned_by, assigned_at, status)
```

### 1.3 Progress / Quiz

```sql
fact_elearn_enrollment (enrollment_id PK, tenant_id, ma_id, course_id FK, course_version,
                        status, started_at, completed_at,
                        UNIQUE(tenant_id, ma_id, course_id))
fact_elearn_progress (progress_id PK, tenant_id, enrollment_id FK, lesson_id FK,
                      scroll_reached_pct, time_spent_sec, completed_at,
                      UNIQUE(tenant_id, enrollment_id, lesson_id))
fact_elearn_quiz_attempt (attempt_id PK, tenant_id, enrollment_id FK, module_id FK,
                          attempt_kind DEFAULT 'module',  -- module | pretest | newsletter
                          score_pct, passed, status, attempted_at, finalized_at,
                          answers JSONB)
fact_elearn_freitext_review (review_id PK, tenant_id, attempt_id FK, question_id FK,
                             ma_answer, llm_score, llm_feedback, llm_model,
                             head_score, head_feedback, reviewed_by, reviewed_at, status)
```

### 1.4 Cert / Badges / Audit

```sql
dim_elearn_certificate (cert_id PK, tenant_id, ma_id, course_id FK, course_version,
                        pdf_url, issued_at,
                        UNIQUE(tenant_id, ma_id, course_id, course_version))
dim_elearn_badge (badge_id PK, tenant_id, ma_id, badge_type, course_id NULLABLE, earned_at)
fact_elearn_import_log (log_id PK, tenant_id, commit_sha, trigger, imported, updated,
                        archived, errors JSONB, started_at, finished_at)
```

## 2. ALTER bestehender Tabellen

```sql
ALTER TABLE dim_user ADD COLUMN elearn_onboarding_active BOOLEAN NOT NULL DEFAULT false;
```

**Begründung:** Flag für Step-by-Step-Unlock-Logik neuer Mitarbeiter. Default `false` = bestehende MA nicht betroffen; Head aktiviert manuell bei Onboarding-Start.

## 3. Indizes

```sql
CREATE INDEX ON fact_elearn_progress (tenant_id, enrollment_id, lesson_id);
CREATE INDEX ON fact_elearn_quiz_attempt (tenant_id, enrollment_id, module_id);
CREATE INDEX ON fact_elearn_freitext_review (tenant_id, status) WHERE status = 'pending';
CREATE INDEX ON fact_elearn_assignment (tenant_id, ma_id, status) WHERE status = 'active';
CREATE INDEX ON dim_elearn_course (tenant_id, status, slug);
```

## 4. Enum-Constraints (CHECK)

Die neuen Text-Werte sind im Stammdaten-Patch `ARK_STAMMDATEN_PATCH_ELEARNING_v0_1.md` definiert. Empfohlene CHECK-Constraints:

```sql
ALTER TABLE fact_elearn_assignment ADD CONSTRAINT ck_assignment_reason
  CHECK (reason IN ('onboarding','adhoc','refresher','role_change','sparten_change'));

ALTER TABLE fact_elearn_assignment ADD CONSTRAINT ck_assignment_status
  CHECK (status IN ('active','completed','expired','cancelled'));

ALTER TABLE fact_elearn_quiz_attempt ADD CONSTRAINT ck_attempt_kind
  CHECK (attempt_kind IN ('module','pretest','newsletter'));

ALTER TABLE fact_elearn_quiz_attempt ADD CONSTRAINT ck_attempt_status
  CHECK (status IN ('in_progress','pending_review','finalized'));

ALTER TABLE fact_elearn_freitext_review ADD CONSTRAINT ck_review_status
  CHECK (status IN ('pending','confirmed','overridden','confirmed_auto'));

ALTER TABLE dim_elearn_question ADD CONSTRAINT ck_question_type
  CHECK (type IN ('mc','multi','freitext','truefalse','zuordnung','reihenfolge'));

ALTER TABLE dim_elearn_course ADD CONSTRAINT ck_course_status
  CHECK (status IN ('draft','published','archived'));
```

## 5. Multi-Tenant-Hinweis

Alle 15 neuen Tabellen tragen `tenant_id UUID NOT NULL`. RLS-Policies werden im Backend-Patch definiert. Migration muss sicherstellen, dass `dim_elearn_tenant` vor allen anderen Inserts existiert (für Arkadium: Seed-Row in Migration).

## 6. Migration-Script (geplant)

`migrations/NNN_elearn_sub_a_catalog.sql` (Nummer bei Implementation festzulegen):

1. `CREATE TABLE` für 15 neue Tabellen (Sektion 1) in FK-Abhängigkeits-Reihenfolge.
2. `ALTER TABLE dim_user` (Sektion 2).
3. `CREATE INDEX` (Sektion 3).
4. `ALTER TABLE … ADD CONSTRAINT` (Sektion 4).
5. Seed: `INSERT INTO dim_elearn_tenant` für Arkadium-Default-Tenant.

Rollback via `DROP TABLE … CASCADE` in umgekehrter Reihenfolge + `ALTER TABLE dim_user DROP COLUMN elearn_onboarding_active`.

## 7. Offene Punkte

- Soft-Delete-Policy: Kurs-Archiv via `dim_elearn_course.status='archived'`; Attempts und Enrollments bleiben immer. Kein zusätzliches `deleted_at`-Feld nötig.
- S3/Blob-Bucket-Naming für `dim_elearn_certificate.pdf_url`: per Tenant separiert (`s3://ark-elearn-certs/<tenant_id>/<cert_id>.pdf`) — entschieden in Backend-Patch.
