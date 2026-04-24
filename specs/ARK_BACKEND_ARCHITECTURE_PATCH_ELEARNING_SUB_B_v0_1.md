# ARK CRM — Backend-Architektur-Patch · E-Learning Sub B · v0.1

**Scope:** Backend-Erweiterung für den Content-Generator (Sub B): Events, Worker/Runner, API-Endpoints, RLS-Policies, Integrationen (LLM, Embeddings, Git, Scheduling).
**Zielversion:** gemeinsam mit Sub-A-Patch in nächstem Grundlagen-Version-Bump.
**Basis-Specs:** `specs/ARK_E_LEARNING_SUB_B_SCHEMA_v0_1.md`, `specs/ARK_E_LEARNING_SUB_B_INTERACTIONS_v0_1.md`.
**Vorheriger Patch:** `specs/ARK_BACKEND_ARCHITECTURE_PATCH_ELEARNING_v0_1.md` (Sub A).
**Stand:** 2026-04-20
**Status:** Review ausstehend (Peter)

---

## Changelog

| # | Bereich | Änderung |
|---|---------|----------|
| 1 | Event-Typen | +12 neue `elearn_*`-Events (Sub B) |
| 2 | Runner | +5 neue Pipeline-Runner (R1–R5) in `tools/elearn-content-gen/` |
| 3 | Worker | +4 event-driven Worker + 4 Cron-Worker |
| 4 | API-Endpoints | +15 Endpoints unter `/api/elearn/admin/content-gen/*` (Admin-only) |
| 5 | RLS-Policies | +5 Policies für neue Tabellen (tenant-scoped) |
| 6 | Integrationen | Anthropic (LLM), OpenAI oder Voyage (Embeddings), Git + GitHub-API, pgvector |
| 7 | Sub-Directory | neuer `tools/elearn-content-gen/` im ARK-Repo für Pipeline-Code |

---

## 1. Event-Typen (Seed für `dim_event_types`)

Kategorie `event_category='elearning'` (aus Sub-A-Patch bereits erweitert).

| event_name | emitter_component | create_history | default_activity_type_id |
|------------|-------------------|----------------|--------------------------|
| `elearn_source_registered` | source-api / ingestor | true | elearn_source_registered |
| `elearn_source_ingested` | r1_ingest | false | — |
| `elearn_source_ingest_failed` | r1_ingest | true | elearn_source_failed |
| `elearn_generation_job_started` | generation-orchestrator | true | elearn_job_started |
| `elearn_generation_job_completed` | generation-orchestrator | true | elearn_job_completed |
| `elearn_generation_job_failed` | generation-orchestrator | true | elearn_job_failed |
| `elearn_artifact_created` | r4_generate | false | — |
| `elearn_artifact_approved` | review-api | true | elearn_artifact_approved |
| `elearn_artifact_rejected` | review-api | true | elearn_artifact_rejected |
| `elearn_artifact_edited` | review-api | true | elearn_artifact_edited |
| `elearn_artifact_published` | r5_publish | true | elearn_artifact_published |
| `elearn_cost_cap_exceeded` | cost-monitor | true | elearn_cost_cap |

**Activity-Types (Seed-Rows):** 12 neue für `dim_activity_types`, Kategorie `elearning`.

## 2. Pipeline-Runner (`tools/elearn-content-gen/`)

Python-Module, aufrufbar via CLI und via Worker-Dispatch.

```
tools/elearn-content-gen/
├── pyproject.toml
├── README.md
├── config/
│   ├── elearn-web-sources.yml.example
│   └── elearn-crm-queries.yml.example
├── queries/
│   └── debriefings_by_sparte.sql (Beispiel)
├── lib/
│   ├── __init__.py
│   ├── llm_client.py          (Port aus anthropic_client.py)
│   ├── embedding_client.py    (Port, unverändert)
│   ├── dedup.py               (Port, unverändert)
│   ├── frontmatter_io.py      (Port, unverändert)
│   ├── config_loader.py       (Port + Tenant-Scoping)
│   ├── pricing.py             (NEU: Modell-Preise, Cost-Berechnung)
│   ├── anonymizer.py          (NEU: CRM-Daten-Anonymisierung)
│   └── models.py              (NEU: Pydantic-Models für YAML/Artifacts)
├── runners/
│   ├── r1_ingest.py           (Source-Kind-Dispatcher)
│   ├── r2_chunk_embed.py
│   ├── r3_cluster.py
│   ├── r4_generate.py
│   └── r5_publish.py
├── prompts/
│   ├── topic_cluster.md
│   ├── lesson_draft.md
│   └── quiz_generation.md
└── cli.py                     (Entry-Point für manuelle Triggers)
```

**Package-Entry:** `python -m elearn_content_gen <command>` z. B. `ingest --source-id <uuid>`.

### 2.1 Runner-Details

| Runner | Python-Lib-Usage |
|--------|------------------|
| `r1_ingest` | `pdfplumber` (PDF), `python-docx` (DOCX), `beautifulsoup4 + httpx` (Web), `sqlalchemy` (CRM-Query) |
| `r2_chunk_embed` | `tiktoken` (Tokenization), `openai` oder `voyageai` (Embedding-API) |
| `r3_cluster` | `numpy` + pgvector-Query für k-Means / Hierarchical Clustering; LLM-Call für Namensgebung |
| `r4_generate` | `anthropic` SDK, Pydantic für YAML-Output-Validation |
| `r5_publish` | `GitPython` für Git-Ops, `httpx` für GitHub-API (PR-Creation) |

## 3. Worker

### 3.1 Event-driven

| Worker | Trigger-Event | Concurrency | Retry |
|--------|---------------|-------------|-------|
| `elearn-source-ingestor` | `elearn_source_registered` | 3 | 3× |
| `elearn-chunk-embedder` | `elearn_source_ingested` | 5 | 3× Backoff (Rate-Limit-aware) |
| `elearn-generation-orchestrator` | cluster-ready (intern) | 2 | 3× |
| `elearn-publish-worker` | `elearn_artifact_approved` | 1 pro Tenant | 3× |

### 3.2 Cron

| Worker | Schedule | Zweck |
|--------|----------|-------|
| `elearn-web-scraper` | stündlich `0 * * * *` (prüft Due-Set) | Fällige Web-Sources scrapen |
| `elearn-crm-query-runner` | stündlich `0 * * * *` (prüft Due-Set) | Fällige CRM-Queries ausführen |
| `elearn-cost-monitor` | täglich `0 1 * * *` | Monats-Cost aggregieren, Caps prüfen |
| `elearn-artifact-expiry` | täglich `0 4 * * *` | Drafts > 30 Tage ohne Review archivieren |

### 3.3 Deployment-Hinweise

- Worker laufen im bestehenden Event-Processor-Framework; neue Router-Dispatches in `event-processor.worker.ts` für Sub-B-Events.
- Pipeline-Runner können als Python-Subprozesse oder via separatem Python-Worker-Dienst laufen. Entscheidung im Implementation-Plan (vermutlich eigener Python-Service `elearn-content-gen-worker`, kommuniziert mit Postgres via `DATABASE_URL`).

## 4. API-Endpoints

Namespace `/api/elearn/admin/content-gen/*`. Admin/Backoffice-only. Vollständige Liste siehe SCHEMA §6. Implementations-Framework: bestehendes ARK-Routing.

Auth-Middleware identisch zu Sub A (`tenant_id` aus JWT, Route-Guard auf `role IN ('admin', 'backoffice')`).

## 5. RLS-Policies

Analog Sub A — pro neue Tabelle:

```sql
ALTER TABLE dim_elearn_source ENABLE ROW LEVEL SECURITY;
CREATE POLICY elearn_source_tenant_isolation ON dim_elearn_source
  USING (tenant_id = current_setting('app.current_tenant_id')::uuid)
  WITH CHECK (tenant_id = current_setting('app.current_tenant_id')::uuid);

-- analog für dim_elearn_chunk, dim_elearn_generation_job,
--              dim_elearn_generated_artifact, fact_elearn_review_action
```

## 6. Integrationen

### 6.1 Anthropic (LLM)

- SDK: `anthropic` Python-Package.
- Modell-Default: `claude-sonnet-4-6` (Generation), `claude-haiku-4-5` (Tagging/Clustering).
- Cost-Tracking: jeder Call schreibt in `dim_elearn_generation_job.total_tokens_in/out` + `total_cost_eur`.
- Rate-Limit: Concurrency 5 pro Tenant, Exponential-Backoff bei 429.
- Prompt-Caching (falls verfügbar): Cluster-Prompt cacheable, Per-Artifact-Prompts nicht.

### 6.2 Embeddings

- Default: OpenAI `text-embedding-3-small` (1536 dims) via `openai` SDK.
- Override pro Tenant: `voyageai` `voyage-3` (1024 dims) — Migration-Pfad dokumentiert im DB-Patch.
- Batch-Size: 20 Chunks pro Request, max 8 192 Tokens Gesamt.

### 6.3 Git / GitHub

- `GitPython` für lokale Git-Ops (clone, commit, push).
- GitHub-API via `httpx` für PR-Creation bei `publish_mode='pr'`.
- Auth: GitHub-PAT, Vault-Ref in `dim_elearn_tenant.settings.elearn_b.github_pat_vault_ref`.
- Content-Repo-Clone: shallow (`--depth 1 --branch <main>`), lokal gecached im Worker-Container.

### 6.4 pgvector

- Ähnlichkeits-Suche für RAG-Context-Retrieval:
  ```sql
  SELECT chunk_id, text, 1 - (embedding <=> $query_embedding) AS similarity
  FROM dim_elearn_chunk
  WHERE tenant_id = $1
  ORDER BY embedding <=> $query_embedding
  LIMIT 15;
  ```
- Cosine-Distance via `<=>` Operator.

## 7. Notifications

| Template | Empfänger | Trigger |
|----------|-----------|---------|
| `elearn-generation-ready` | Head/Admin (je nach Source-Target) | `elearn_generation_job_completed` mit `artifacts_count > 0` |
| `elearn-cost-cap-warning` | Admin | Monats-Cap ≥ 95 % erreicht |
| `elearn-cost-cap-exceeded` | Admin | Monats-Cap ≥ 100 % oder Job-Cap überschritten |
| `elearn-source-ingest-failed` | Admin | `elearn_source_ingest_failed` |
| `elearn-publish-failed` | Admin | Push-Conflict oder PR-Fehler |
| `elearn-review-sla-reminder` | Reviewer | Artefakte > 3 Tage ohne Review |

## 8. Sicherheit

- **CRM-Daten-Zugriff:** R1 CRM-Query-Runner läuft mit dediziertem read-only Postgres-Role `elearn_content_gen_reader`, der nur `fact_history`, `dim_candidate`, `dim_account`, `dim_user` lesen darf (SELECT, kein WRITE).
- **Anonymisierung:** bevor Text in `dim_elearn_chunk.text` persistiert wird, läuft `anonymizer.py` darüber. Tests in `tests/anonymizer_test.py` decken PII-Patterns ab.
- **GitHub-PAT:** niemals in Logs, nur aus Vault geladen, zur Runtime im Memory.
- **Webhook-Sicherheit (kein Eingangs-Webhook hier):** Sub B triggert Git-Push; Sub A empfängt Webhook (siehe Sub-A-Patch).

## 9. Performance-Annahmen

- **RAG-Retrieval:** < 100 ms pro Query mit IVFFLAT-Index (bis ~1 Mio Chunks/Tenant).
- **Generation-Job-Dauer:** ~2–5 Min pro Modul (bis ~10 Lessons + Quiz-Pool).
- **Embedding-Batch-Durchsatz:** 100 Chunks/Min (OpenAI Standard-Tier).
- **Cost:** ~0.5–2.0 € pro generiertes Modul (bei Claude Sonnet 4.6, Modul mit 5 Lessons + 20 Fragen).

## 10. Offene Punkte

- **Python-Worker-Deployment:** Separater Container im Docker-Compose / Kubernetes-Setup? Entscheidung im Implementation-Plan. Alternative: Event-Processor ruft Python-Subprozess (einfacher, aber skaliert schlechter).
- **LLM-Output-Validation:** Pydantic-Schema-Matching bei YAML-Output. Feedback-Loop-Prompt bei Schema-Fail (siehe INTERACTIONS §11).
- **Prompt-Versionierung:** Prompt-Dateien in Git versioniert. Bei Prompt-Änderung: Flag in `generation_job.llm_prompt_template` (Prompt-Slug/Version), damit reproduzierbar.
- **Saga-Integration:** nicht relevant (Sub B ist Pipeline, keine Cross-Entity-Transaktion).
