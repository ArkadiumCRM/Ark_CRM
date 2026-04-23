# ARK CRM — DB-Schema-Patch · E-Learning Sub B · v0.1

**Scope:** Datenmodell-Erweiterung für den Content-Generator (Sub B) des Phase-3-ERP-Moduls E-Learning.
**Zielversion:** gemeinsam mit Sub-A-Patch in nächstem Grundlagen-Version-Bump.
**Basis-Specs:** `specs/ARK_E_LEARNING_SUB_B_SCHEMA_v0_1.md`, `specs/ARK_E_LEARNING_SUB_B_INTERACTIONS_v0_1.md`.
**Vorheriger Patch:** `specs/ARK_DATABASE_SCHEMA_PATCH_ELEARNING_v0_1.md` (Sub A).
**Stand:** 2026-04-20
**Status:** Review ausstehend (Peter)

---

## Changelog

| # | Tabelle | Änderung | Typ |
|---|---------|----------|-----|
| 1 | `dim_elearn_source` | NEU (4 Quell-Typen: pdf/docx/book/web_url/crm_query) | CREATE |
| 2 | `dim_elearn_chunk` | NEU (RAG-Chunks mit pgvector-Embedding) | CREATE |
| 3 | `dim_elearn_generation_job` | NEU (LLM-Generation-Job-Tracking + Cost) | CREATE |
| 4 | `dim_elearn_generated_artifact` | NEU (Draft-Artefakte für Review) | CREATE |
| 5 | `fact_elearn_review_action` | NEU (Audit-Trail für Review-Entscheidungen) | CREATE |
| 6 | pgvector Extension | NEU (für Embedding-Suche) | EXTENSION |
| 7 | Indizes | 6 neue (inkl. IVFFLAT für Vector-Search) | INDEX |
| 8 | CHECK-Constraints | 5 neue Enum-Validierungen | ALTER CHECK |
| 9 | `dim_elearn_tenant.settings` | neues JSONB-Key `elearn_b.*` (Publish-Mode, Cost-Caps, Scheduler) | DATA |

---

## 1. Extension

```sql
CREATE EXTENSION IF NOT EXISTS vector;
```

## 2. Neue Tabellen

Vollständige DDL in `ARK_E_LEARNING_SUB_B_SCHEMA_v0_1.md §4`. Kurzform:

```sql
dim_elearn_source (source_id PK, tenant_id, kind, slug, uri, title, sparten[],
                   target_course_slug, meta JSONB, priority, content_hash,
                   last_ingested_at, enabled, created_at,
                   UNIQUE(tenant_id, kind, slug))

dim_elearn_chunk (chunk_id PK, tenant_id, source_id FK, order_idx, text, tokens,
                  embedding VECTOR(1536), meta JSONB, content_hash, created_at,
                  UNIQUE(tenant_id, source_id, order_idx))

dim_elearn_generation_job (job_id PK, tenant_id, source_ids UUID[], cluster_summary JSONB,
                           llm_model, llm_prompt_template, status, triggered_by,
                           triggered_by_user, total_tokens_in, total_tokens_out,
                           total_cost_eur, started_at, finished_at, error)

dim_elearn_generated_artifact (artifact_id PK, tenant_id, job_id FK, artifact_type,
                               target_course_slug, target_module_slug, target_lesson_slug,
                               draft_content JSONB, preview_text, source_chunk_ids UUID[],
                               status, reviewer, reviewed_at, published_commit_sha, created_at)

fact_elearn_review_action (action_id PK, tenant_id, artifact_id FK, action, reviewer,
                           reason, diff JSONB, created_at)
```

## 3. Indizes

```sql
CREATE INDEX ON dim_elearn_source (tenant_id, kind, enabled);
CREATE INDEX ON dim_elearn_chunk (tenant_id, source_id, order_idx);
CREATE INDEX ON dim_elearn_chunk USING ivfflat (embedding vector_cosine_ops) WITH (lists = 100);
CREATE INDEX ON dim_elearn_generation_job (tenant_id, status, started_at DESC);
CREATE INDEX ON dim_elearn_generated_artifact (tenant_id, status) WHERE status IN ('draft', 'approved');
CREATE INDEX ON fact_elearn_review_action (tenant_id, artifact_id, created_at DESC);
```

**IVFFLAT-Hinweis:** `lists = 100` ist Startwert für < 1 Mio Chunks. Bei grösserem Volumen auf `sqrt(n_rows)` anpassen (Re-Index nötig).

## 4. CHECK-Constraints

```sql
ALTER TABLE dim_elearn_source ADD CONSTRAINT ck_source_kind
  CHECK (kind IN ('pdf','docx','book','web_url','crm_query'));

ALTER TABLE dim_elearn_source ADD CONSTRAINT ck_source_priority
  CHECK (priority IN ('low','normal','high'));

ALTER TABLE dim_elearn_generation_job ADD CONSTRAINT ck_job_status
  CHECK (status IN ('pending','running','ready_for_review','completed','failed'));

ALTER TABLE dim_elearn_generation_job ADD CONSTRAINT ck_job_triggered_by
  CHECK (triggered_by IN ('scheduled','manual','event'));

ALTER TABLE dim_elearn_generated_artifact ADD CONSTRAINT ck_artifact_type
  CHECK (artifact_type IN ('course_meta','module','lesson','quiz_question','quiz_pool'));

ALTER TABLE dim_elearn_generated_artifact ADD CONSTRAINT ck_artifact_status
  CHECK (status IN ('draft','approved','rejected','published','superseded'));

ALTER TABLE fact_elearn_review_action ADD CONSTRAINT ck_review_action
  CHECK (action IN ('approve','reject','edit','delete','publish'));
```

## 5. Tenant-Settings (JSONB-Erweiterung)

Default-Settings-Seed (pro Tenant):

```sql
UPDATE dim_elearn_tenant SET settings = settings || '{
  "elearn_b": {
    "publish_mode": "direct",
    "content_repo": "arkadium/ark-elearning-content",
    "content_repo_branch": "main",
    "github_pat_vault_ref": "elearn/github-pat",
    "llm_model_default": "claude-sonnet-4-6",
    "llm_model_tagging": "claude-haiku-4-5",
    "llm_cost_cap_monthly_eur": 200,
    "llm_cost_cap_per_job_eur": 5,
    "embedding_model": "text-embedding-3-small",
    "embedding_dimension": 1536,
    "scheduler": { "enabled": true, "default_schedule": "0 3 * * 1" },
    "review": { "auto_assign_to_head": true, "review_sla_days": 7 }
  }
}'::jsonb;
```

## 6. Migration-Script (geplant)

`migrations/NNN_elearn_sub_b_content_gen.sql`:

1. `CREATE EXTENSION vector` (idempotent).
2. `CREATE TABLE` für 5 neue Tabellen (Sub-B-spezifisch, FK-Abhängigkeiten berücksichtigen).
3. `CREATE INDEX` inkl. IVFFLAT.
4. `ALTER TABLE … ADD CONSTRAINT` (Sektion 4).
5. `UPDATE dim_elearn_tenant.settings` (Sektion 5, idempotent mit JSONB-Merge).

Rollback via `DROP TABLE … CASCADE` + Settings-Cleanup via `settings - 'elearn_b'`.

## 7. Performance-Annahmen

- Erwartetes Volumen pro Tenant/Jahr:
  - ~500 Sources
  - ~100 000 Chunks
  - ~1 000 Generation-Jobs
  - ~10 000 Artefakte
- **Hot-Path:** pgvector-Ähnlichkeits-Suche für RAG (Query-Embedding vs. `dim_elearn_chunk.embedding`), erwartete Latenz < 100 ms mit IVFFLAT.
- **Cost-Aggregation:** Materialized-View `mv_elearn_cost_by_month` kann in Phase-2 ergänzt werden falls SUM-Performance kritisch.

## 8. Offene Punkte

- **Embedding-Dimension-Migration:** wenn Peter später Modell wechselt (z. B. auf Voyage AI `voyage-3` mit 1024 dims), muss `embedding`-Spalte neu dimensioniert werden. Phase-2-Migration-Pfad dokumentieren.
- **Vector-Index-Rebuild:** IVFFLAT braucht periodisches REINDEX nach grösseren Insert-Batches (z. B. > 10 % Wachstum). Cron-Candidate.
