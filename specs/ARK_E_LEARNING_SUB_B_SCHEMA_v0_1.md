---
title: "ARK E-Learning Sub B (Content-Generator) — Schema v0.1"
type: spec
created: 2026-04-20
updated: 2026-04-20
sources: []
tags: [elearning, erp, phase3, sub-b, schema, content-gen, llm, rag]
status: draft
author: Peter Wiederkehr + Claude (Brainstorming-Session 2026-04-20)
companion: ARK_E_LEARNING_SUB_B_INTERACTIONS_v0_1.md
depends_on: ARK_E_LEARNING_SUB_A_SCHEMA_v0_1.md
---

# ARK E-Learning Sub B · Content-Generator · Schema v0.1

> **Companion:** Pipeline-Flows, Runner-Logik, LLM-Prompts, Review-Workflow in [`ARK_E_LEARNING_SUB_B_INTERACTIONS_v0_1.md`](ARK_E_LEARNING_SUB_B_INTERACTIONS_v0_1.md).
> **Depends on:** Sub A (Kurs-Katalog) — erzeugt Content im Sub-A-kompatiblen Repo-Format.

## 0. Kontext

Sub B ist der **Content-Generator** des E-Learning-Moduls. Er ingested Quellen (PDFs, Bücher, Web, CRM-Daten), clustert Wissen thematisch, generiert via LLM Lesson-Markdown und Quiz-Fragen-Pools, und legt die Drafts zur Human-Review vor. Nach Approve werden die Artefakte in das **externe Content-Repo** (aus Sub A) commited — Sub A importiert sie dann via Git-Webhook.

**Basis:** bestehender LinkedIn-Scraper in `C:\Linkedin_Automatisierung` — selektiv portiert nach `Ark_CRM/tools/elearn-content-gen/`.

## 1. Guiding Principles

1. **4 Content-Quellen:** PDFs/Docx (manuell hochgeladen), Bücher + Peter-Notizen (Text-Files), Web-Scraper (SIA/ETH/Baublatt/Konkurrenten), CRM-Daten (anonymisiert aus `fact_history`).
2. **Human-in-the-Loop vor Publish.** Nichts landet im Content-Repo ohne Review-Approval.
3. **RAG-basierte Generation:** Chunks → Embeddings → pgvector-Suche → LLM-Prompt mit relevantem Kontext.
4. **Sub-A-Output-Format:** R4 generiert YAML + Markdown exakt im Sub-A-Repo-Schema (`course.yml`, `module.yml`, `lesson.md`, `quiz.yml`).
5. **Konfigurierbar pro Tenant:** Publish-Mode (Direct-Commit vs. Auto-PR), Scheduling pro Source, LLM-Cost-Caps.
6. **Multi-Tenant:** alle Tabellen `tenant_id`-scoped (konsistent mit Sub A).

## 2. Entscheidungs-Log (Brainstorming 2026-04-20)

| # | Entscheidung | Gewählt |
|---|--------------|---------|
| 1 | Content-Quellen | 4 Typen: PDF/Docx, Bücher+Notizen, Web, CRM-Daten |
| 2 | Review-Modus | Human-in-Loop bei jedem Publish |
| 3 | Libs-Integration | Selektiver Port aus `C:\Linkedin_Automatisierung` nach `Ark_CRM/tools/elearn-content-gen/` |
| 4 | Publish-Mode | Konfigurierbar pro Tenant (Direct-Commit vs. Auto-PR) |
| 5 | Web-Scraper-Scheduling | Konfigurierbar pro Source (weekly/daily/cron) |
| 6 | LLM-Cost-Budget | Konfigurierbar pro Tenant (Monats-Cap + Job-Cap) |
| 7 | Pipeline-Pattern | R1–R5 (Ingest → Chunk+Embed → Cluster → Generate → Review/Publish) analog LinkedIn-Runner |
| 8 | CRM-Daten | Anonymisiert destilliert, nicht direkt als Fragen |
| 9 | Embedding-DB | pgvector in bestehender Postgres-DB |
| 10 | LLM-Modell | Claude Sonnet 4.6 für Content-Gen (höhere Qualität); Haiku 4.5 nur für Zuordnung/Tagging-Aufgaben |

## 3. Content-Quellen (Formate)

### 3.1 PDFs/Docx (Typ `pdf` / `docx`)

- Ablage: `raw/E-Learning/<thema>/<datei>.pdf`
- Metadata-Sidecar (optional): `<datei>.meta.yml`
  ```yaml
  title: SIA Jahresbericht 2025
  sparten: [ARC, ING]
  target_course_slug: arc-marktwissen
  priority: high
  ```
- Ingest via CLI oder UI-Upload.

### 3.2 Bücher + Notizen (Typ `book`)

- Ablage: `raw/E-Learning/books/<book-slug>/`
  - `text.txt` oder `text.md` — Buch-Volltext (OCR falls nur PDF)
  - `notes.md` — Peters Erkenntnisse und Key-Takeaways (wichtiger RAG-Boost)
  - `meta.yml` — Titel, Autor, Jahr, Sparten, target_course_slug

### 3.3 Web-Quellen (Typ `web_url`)

- Config: `config/elearn-web-sources.yml` (tenant-scoped via Ordner-Prefix oder DB-Eintrag)
- Schema:
  ```yaml
  sources:
    - slug: sia-news
      name: SIA Newsletter
      url: https://www.sia.ch/de/der-sia/news
      scrape_selector: "article.news-item"   # CSS-Selector für relevante Blöcke
      schedule: weekly                        # weekly | daily | cron=<expr>
      sparten: [ARC, ING]
      target_course_slug: arc-marktwissen
      enabled: true
  ```

### 3.4 CRM-Daten (Typ `crm_query`)

- Config: `config/elearn-crm-queries.yml`
- Schema:
  ```yaml
  queries:
    - slug: debriefings-arc-q
      name: Kunden-Debriefings ARC (letzte 90 Tage)
      sql_template: queries/debriefings_by_sparte.sql
      params: {sparte: ARC, since_days: 90}
      target_course_slug: arc-marktwissen
      schedule: weekly
      anonymize: true                         # MA/Kandidat-Namen maskieren
      enabled: true
  ```
- SQL-Templates in `tools/elearn-content-gen/queries/*.sql` mit Named-Params. Query-Output wird automatisch anonymisiert (Namen → Rollen-Platzhalter).

## 4. DB-Schema

Alle Tabellen `tenant_id UUID NOT NULL` mit Index, RLS-Policy analog Sub A.

### 4.1 `dim_elearn_source`

```sql
dim_elearn_source (
  source_id UUID PK,
  tenant_id UUID NOT NULL,
  kind TEXT NOT NULL,                    -- pdf | docx | book | web_url | crm_query
  slug TEXT NOT NULL,
  uri TEXT NOT NULL,                     -- Pfad oder URL oder Query-Slug
  title TEXT,
  sparten TEXT[] NOT NULL DEFAULT '{}',
  target_course_slug TEXT,               -- Hint für Clustering, nullable
  meta JSONB NOT NULL DEFAULT '{}',
  priority TEXT NOT NULL DEFAULT 'normal', -- low | normal | high
  content_hash TEXT,                     -- Hash des letzten Ingests
  last_ingested_at TIMESTAMPTZ,
  enabled BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (tenant_id, kind, slug)
)
```

### 4.2 `dim_elearn_chunk`

```sql
dim_elearn_chunk (
  chunk_id UUID PK,
  tenant_id UUID NOT NULL,
  source_id UUID NOT NULL REFERENCES dim_elearn_source,
  order_idx INT NOT NULL,
  text TEXT NOT NULL,
  tokens INT NOT NULL,
  embedding VECTOR(1536),                -- pgvector; Dimension abhängig vom Embedding-Model
  meta JSONB NOT NULL DEFAULT '{}',      -- z.B. {page: 12, heading: "Hauptakteure"}
  content_hash TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (tenant_id, source_id, order_idx)
)
```

### 4.3 `dim_elearn_generation_job`

```sql
dim_elearn_generation_job (
  job_id UUID PK,
  tenant_id UUID NOT NULL,
  source_ids UUID[] NOT NULL,            -- welche Sources flossen ein
  cluster_summary JSONB,                 -- Output von R3
  llm_model TEXT,                        -- claude-sonnet-4-6 default
  llm_prompt_template TEXT,
  status TEXT NOT NULL DEFAULT 'pending',-- pending | running | ready_for_review | completed | failed
  triggered_by TEXT NOT NULL,            -- scheduled | manual | event
  triggered_by_user UUID,
  total_tokens_in INT DEFAULT 0,
  total_tokens_out INT DEFAULT 0,
  total_cost_eur NUMERIC(10,4) DEFAULT 0,
  started_at TIMESTAMPTZ,
  finished_at TIMESTAMPTZ,
  error TEXT
)
```

### 4.4 `dim_elearn_generated_artifact`

```sql
dim_elearn_generated_artifact (
  artifact_id UUID PK,
  tenant_id UUID NOT NULL,
  job_id UUID NOT NULL REFERENCES dim_elearn_generation_job,
  artifact_type TEXT NOT NULL,           -- course_meta | module | lesson | quiz_question | quiz_pool
  target_course_slug TEXT NOT NULL,
  target_module_slug TEXT,
  target_lesson_slug TEXT,
  draft_content JSONB NOT NULL,          -- YAML-ready struct oder Markdown-Body
  preview_text TEXT,                     -- Kurzform für Review-Liste
  source_chunk_ids UUID[] NOT NULL,      -- welche Chunks flossen ein (Traceability)
  status TEXT NOT NULL DEFAULT 'draft',  -- draft | approved | rejected | published | superseded
  reviewer UUID,
  reviewed_at TIMESTAMPTZ,
  published_commit_sha TEXT,             -- Commit im Content-Repo nach Publish
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
)
```

### 4.5 `fact_elearn_review_action`

```sql
fact_elearn_review_action (
  action_id UUID PK,
  tenant_id UUID NOT NULL,
  artifact_id UUID NOT NULL REFERENCES dim_elearn_generated_artifact,
  action TEXT NOT NULL,                  -- approve | reject | edit | delete | publish
  reviewer UUID NOT NULL,
  reason TEXT,
  diff JSONB,                            -- bei edit: alt vs neu
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
)
```

### 4.6 Indexe

```sql
CREATE INDEX ON dim_elearn_source (tenant_id, kind, enabled);
CREATE INDEX ON dim_elearn_chunk (tenant_id, source_id, order_idx);
CREATE INDEX ON dim_elearn_chunk USING ivfflat (embedding vector_cosine_ops) WITH (lists = 100);
CREATE INDEX ON dim_elearn_generation_job (tenant_id, status, started_at DESC);
CREATE INDEX ON dim_elearn_generated_artifact (tenant_id, status) WHERE status IN ('draft', 'approved');
CREATE INDEX ON fact_elearn_review_action (tenant_id, artifact_id, created_at DESC);
```

### 4.7 Extensions

```sql
CREATE EXTENSION IF NOT EXISTS vector;  -- pgvector
CREATE EXTENSION IF NOT EXISTS pgcrypto; -- für Hash-Funktionen (bestehend)
```

## 5. Tenant-Settings

Neue Keys in `dim_elearn_tenant.settings` (JSONB):

```yaml
elearn_b:
  publish_mode: "direct"               # direct | pr
  content_repo: "arkadium/ark-elearning-content"
  content_repo_branch: "main"
  github_pat_vault_ref: "elearn/github-pat"   # Vault-Referenz, kein Klartext
  llm_model_default: "claude-sonnet-4-6"
  llm_model_tagging: "claude-haiku-4-5"
  llm_cost_cap_monthly_eur: 200
  llm_cost_cap_per_job_eur: 5
  embedding_model: "text-embedding-3-small"
  embedding_dimension: 1536
  scheduler:
    enabled: true
    default_schedule: "0 3 * * 1"      # Montag 03:00 — weekly default
  review:
    auto_assign_to_head: true
    review_sla_days: 7
```

## 6. API-Endpoints (Contracts)

Namespace `/api/elearn/admin/content-gen/*` — Admin/Backoffice-only. Flow-Details in INTERACTIONS.

| Methode | Pfad | Zweck |
|---------|------|-------|
| GET    | `/api/elearn/admin/content-gen/sources` | Source-Liste |
| POST   | `/api/elearn/admin/content-gen/sources` | Neue Source registrieren (inkl. File-Upload für PDF/Book) |
| POST   | `/api/elearn/admin/content-gen/sources/:id/ingest` | Manuell R1 triggern |
| DELETE | `/api/elearn/admin/content-gen/sources/:id` | Source deaktivieren (`enabled=false`) |
| GET    | `/api/elearn/admin/content-gen/jobs` | Generation-Jobs (paginated) |
| POST   | `/api/elearn/admin/content-gen/jobs` | Neuen Job manuell starten: `{ source_ids[], target_course_slug? }` |
| GET    | `/api/elearn/admin/content-gen/jobs/:id` | Job-Details + Artefakt-Liste |
| POST   | `/api/elearn/admin/content-gen/jobs/:id/cancel` | Job abbrechen |
| GET    | `/api/elearn/admin/content-gen/artifacts` | Review-Queue (filtered by status) |
| GET    | `/api/elearn/admin/content-gen/artifacts/:id` | Artefakt-Detail inkl. Source-Chunks-Preview |
| POST   | `/api/elearn/admin/content-gen/artifacts/:id/approve` | Approve → R5-Publish |
| POST   | `/api/elearn/admin/content-gen/artifacts/:id/reject` | Body: `{ reason }` |
| POST   | `/api/elearn/admin/content-gen/artifacts/:id/edit` | Body: `{ draft_content }` — Inline-Edit |
| GET    | `/api/elearn/admin/content-gen/config/web-sources` | Web-Sources-Config lesen |
| POST   | `/api/elearn/admin/content-gen/config/web-sources` | Config speichern |
| GET    | `/api/elearn/admin/content-gen/config/crm-queries` | CRM-Queries-Config lesen |
| POST   | `/api/elearn/admin/content-gen/config/crm-queries` | Config speichern |

## 7. UI-Seiten (Ergänzung zu Sub A)

Admin-only, unter `erp/elearn/admin/`:

| Page | Zweck |
|------|-------|
| `content-gen.html` | Zentrale Übersicht: Job-Timeline, Queue-Stats, Cost-Budget |
| `content-gen-sources.html` | Source-Verwaltung: Upload, Web-URLs, CRM-Queries |
| `content-gen-review.html` | Review-Queue mit Drawer-basierter Artefakt-Inspektion |

Review-Drawer (540 px): siehe INTERACTIONS §5.

**Sidebar-Ergänzung (Admin-Teil, nach „Import-Dashboard"):**
- Content-Generator
- Content-Sources
- Review-Queue

## 8. Enums (neue Stammdaten)

### 8.1 `elearn_source_kind`

| Wert | Bedeutung |
|------|-----------|
| `pdf` | PDF-Upload in `raw/E-Learning/` |
| `docx` | Word-Dokument |
| `book` | Buch-Volltext mit Notizen |
| `web_url` | Scheduled Web-Scrape |
| `crm_query` | SQL-Query gegen CRM-DB |

### 8.2 `elearn_artifact_type`

| Wert | Bedeutung |
|------|-----------|
| `course_meta` | `course.yml`-Entwurf |
| `module` | `module.yml`-Entwurf |
| `lesson` | `lesson.md`-Entwurf |
| `quiz_question` | Einzelne Frage für `quiz.yml` |
| `quiz_pool` | Komplette Fragen-Pool-Datei |

### 8.3 `elearn_artifact_status`

| Wert | Bedeutung |
|------|-----------|
| `draft` | Neu generiert, wartet auf Review |
| `approved` | Reviewt, wartet auf Publish |
| `rejected` | Abgelehnt, Grund gespeichert |
| `published` | Im Content-Repo committed |
| `superseded` | Durch neueren Artefakt ersetzt |

### 8.4 `elearn_job_status`

| Wert | Bedeutung |
|------|-----------|
| `pending` | In Queue |
| `running` | R1–R4 aktiv |
| `ready_for_review` | R4 fertig, Artefakte bereit |
| `completed` | Alle Artefakte durch Review durch |
| `failed` | Abgebrochen (Error in Job.error) |

### 8.5 `elearn_review_action`

| Wert | Bedeutung |
|------|-----------|
| `approve` | Artefakt freigegeben |
| `reject` | Artefakt abgelehnt |
| `edit` | Artefakt inline editiert |
| `delete` | Artefakt gelöscht |
| `publish` | Artefakt ins Content-Repo committed |

## 9. Offene Punkte

- **PDF-Parser:** PyMuPDF vs. pdfplumber für Python-Portierung. pdfplumber gewinnt bei Layout-Erhalt, PyMuPDF bei Speed. Entscheidung im Implementation-Plan.
- **Embedding-Modell:** OpenAI `text-embedding-3-small` (1536 dims, günstig) vs. Voyage AI `voyage-3` (besser für Fachtexte). Tenant-override via Settings.
- **OCR-Fallback:** Für eingescannte PDFs tesseract oder Vision-API? Phase-2.
- **LLM-Cost-Tracking:** bereits via `total_cost_eur` per Job. Monats-Aggregation via Materialized-View in Backend-Patch.
- **CRM-Query-Anonymisierung:** deterministisch oder mit LLM? Erster Ansatz: Regex-basiert (Namen → `[MA]`, `[Kandidat]`, `[Kunde]`). Phase-2 LLM-gestützt falls nötig.

## 10. Abhängigkeiten

| Komponente | Abhängigkeit |
|------------|--------------|
| Sub A | Sub B generiert in Sub-A-kompatibles Format; publisht in Sub-A-Content-Repo; Sub A importiert via Git-Webhook |
| Sub C | Sub C nutzt dieselbe Pipeline (R1–R4) für Newsletter-Generation (INTERACTIONS Sub C §X) |
| Sub D | Keine direkte Abhängigkeit |
| LinkedIn_Automatisierung | Selektiver Port als Basis-Libs |

## 11. Nächste Schritte

1. Peter reviewt SCHEMA + INTERACTIONS für Sub B.
2. Nach Freigabe: konsolidierter Implementation-Plan für A+B via `superpowers:writing-plans`.
3. Port-Audit: welche Files aus `C:\Linkedin_Automatisierung` wandern in `tools/elearn-content-gen/`.
4. Grundlagen-Patches mergen (Sub A + Sub B zusammen als eine Grundlagen-Version-Bump-Runde).
5. Sub C Brainstorming.
