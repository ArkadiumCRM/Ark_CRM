---
title: "ARK E-Learning Sub B (Content-Generator) — Interactions v0.1"
type: spec
created: 2026-04-20
updated: 2026-04-20
sources: []
tags: [elearning, erp, phase3, sub-b, interactions, pipeline, rag, llm]
status: draft
author: Peter Wiederkehr + Claude (Brainstorming-Session 2026-04-20)
companion: ARK_E_LEARNING_SUB_B_SCHEMA_v0_1.md
depends_on: ARK_E_LEARNING_SUB_A_INTERACTIONS_v0_1.md
---

# ARK E-Learning Sub B · Content-Generator · Interactions v0.1

> **Companion:** DB-Schema, API-Endpoints, UI-Seiten, Enums und Tenant-Settings in [`ARK_E_LEARNING_SUB_B_SCHEMA_v0_1.md`](ARK_E_LEARNING_SUB_B_SCHEMA_v0_1.md).

## 0. Scope

Dieses Dokument beschreibt Pipeline-Flows (R1–R5), Runner-Logik, LLM-Prompts, Review-Workflow und Publish-Mechanik von Sub B. Struktur liegt im SCHEMA-Companion.

## 1. Event-Typen

Neue `elearn_*`-Events für Sub B (CHECK `event_category='elearning'`):

| Event | Payload (Auszug) |
|-------|-------------------|
| `elearn_source_registered` | `source_id, kind, slug, sparten` |
| `elearn_source_ingested` | `source_id, chunks_count, tokens` |
| `elearn_source_ingest_failed` | `source_id, error` |
| `elearn_generation_job_started` | `job_id, source_ids, llm_model` |
| `elearn_generation_job_completed` | `job_id, artifacts_count, cost_eur` |
| `elearn_generation_job_failed` | `job_id, error` |
| `elearn_artifact_created` | `artifact_id, job_id, artifact_type` |
| `elearn_artifact_approved` | `artifact_id, reviewer` |
| `elearn_artifact_rejected` | `artifact_id, reviewer, reason` |
| `elearn_artifact_edited` | `artifact_id, reviewer, diff_summary` |
| `elearn_artifact_published` | `artifact_id, commit_sha, content_repo` |
| `elearn_cost_cap_exceeded` | `tenant_id, scope (job/monthly), cost_eur, cap_eur` |

## 2. Worker / Cron / Runner

### 2.1 Pipeline-Runner (R1–R5)

Implementiert als Python-Module in `tools/elearn-content-gen/`. CLI-Entry via `python -m elearn_content_gen <runner> [args]`; Worker-Entry via Event-Processor-Dispatch.

| Runner | Input | Output | Trigger |
|--------|-------|--------|---------|
| `r1_ingest` | `dim_elearn_source.source_id` | Raw-Text + `dim_elearn_source.last_ingested_at` | Event `elearn_source_registered`, Cron für Web/CRM, CLI |
| `r2_chunk_embed` | Raw-Text | `dim_elearn_chunk`-Rows mit Embedding | Event `elearn_source_ingested` |
| `r3_cluster` | `dim_elearn_chunk[]` (pro Target-Course oder Auto-Discovery) | `dim_elearn_generation_job.cluster_summary` | Event `elearn_source_ingested` (batch-aggregated) oder Manual |
| `r4_generate` | Cluster + RAG-Chunks | `dim_elearn_generated_artifact`-Rows | Intern von R3 gechained |
| `r5_publish` | approved Artifact | Content-Repo-Commit/PR | Event `elearn_artifact_approved` |

### 2.2 Cron-Worker

| Worker | Schedule | Zweck |
|--------|----------|-------|
| `elearn-web-scraper` | konfigurierbar pro Source in `dim_elearn_source.meta.schedule` (Default `0 3 * * 1`) | Web-Sources scrapen → R1 |
| `elearn-crm-query-runner` | konfigurierbar pro Query | CRM-Queries ausführen → R1 |
| `elearn-cost-monitor` | täglich `0 1 * * *` | Tenant-Monats-Cost summieren, bei >95 % Cap Warnung, bei ≥100 % Job-Disable |
| `elearn-artifact-expiry` | täglich `0 4 * * *` | Drafts älter als 30 Tage ohne Review → auto-archive (`status='superseded'`) |

### 2.3 Event-driven Worker

| Worker | Trigger-Event | Concurrency | Retry |
|--------|---------------|-------------|-------|
| `elearn-source-ingestor` | `elearn_source_registered` | 3 | 3× |
| `elearn-chunk-embedder` | `elearn_source_ingested` | 5 | 3× (Backoff bei Rate-Limit) |
| `elearn-generation-orchestrator` | Cluster-Ready (intern) | 2 | 3× |
| `elearn-publish-worker` | `elearn_artifact_approved` | 1 pro Tenant | 3× |

## 3. Pipeline-Flows

### 3.1 R1 · Ingest

**Eingabe-Varianten pro `kind`:**

- `pdf` / `docx`: File-Pfad aus `dim_elearn_source.uri`. Parse via `pdfplumber` (pdf) oder `python-docx`. Text-Normalisierung: Whitespace, Hyphenation-Merge. Metadata-Sidecar einlesen falls vorhanden.
- `book`: lese `text.md`/`text.txt` plus `notes.md`. Notizen werden als **Prefix-Prompt-Hint** markiert (höheres Gewicht bei R4).
- `web_url`: HTTP-Request mit User-Agent `ARK-ElearnScraper/1.0`. CSS-Selector via `beautifulsoup4`. Anti-Bot: Retry mit Backoff; bei 429/403 Task pausieren und markieren.
- `crm_query`: SQL-Template laden aus `tools/elearn-content-gen/queries/*.sql`. Params einsetzen. Query ausführen mit tenant-scoped DB-Connection. Output als strukturierter JSON → Text-Serialisierung. Anonymisierung via Regex-Pattern (`dim_user.display_name` → `[MA]`, `dim_candidate.full_name` → `[Kandidat]`, `dim_account.company_name` → `[Kunde-A]/[Kunde-B]/…` konsistent pro Row).

**Hash-Check:** `content_hash = SHA256(normalized_text)`. Wenn `== dim_elearn_source.content_hash`: skip R2 (keine Änderung).

**Output:** `source.last_ingested_at = NOW()`, neuer Hash gespeichert, Event `elearn_source_ingested`.

### 3.2 R2 · Chunk + Embed

- **Chunk-Strategie:** Sliding-Window 800 Tokens mit 100 Tokens Overlap. Grenzen möglichst an Paragraph-Enden. Minimum-Chunk: 200 Tokens.
- **Embedding-Call:** Batch 20 Chunks pro Request, Modell aus `dim_elearn_tenant.settings.elearn_b.embedding_model`.
- **Kosten-Tracking:** Embedding-Tokens zählen, aggregieren auf Job-Ebene (wenn Job bereits existiert).
- **Upsert:** `ON CONFLICT (tenant_id, source_id, order_idx) DO UPDATE`. Geänderte Chunks bekommen neue `content_hash`.
- **Alte Chunks:** wenn Source neuen Inhalt hat und alte Order-Idx nicht mehr existieren → `DELETE` (Source-Update ist quasi eine neue Version).

### 3.3 R3 · Topic-Cluster

**Zwei Modi:**

1. **Directed (target_course_slug gesetzt):** Alle Chunks mit diesem Target sammeln, nach Heading/Section gruppieren, LLM-Call „welche Module ergeben sich aus diesen Chunks?" → Cluster mit vorgeschlagenen `module_slug` + `title`.
2. **Auto-Discovery (target_course_slug null):** Alle ungeclusterten Chunks in Batch, pgvector-k-Means oder hierarchisches Clustering. LLM-Zusammenfassung pro Cluster für `course_slug`-Vorschlag + Modul-Gruppierung.

**Output:** `dim_elearn_generation_job` mit `cluster_summary` als JSONB:
```json
{
  "target_course_slug": "arc-marktwissen",
  "clusters": [
    {
      "module_slug": "hauptakteure",
      "module_title": "Hauptakteure der Schweizer Planerszene",
      "chunk_ids": ["...", "..."],
      "estimated_lessons": 3
    },
    ...
  ]
}
```

### 3.4 R4 · Content-Gen

**Pro Cluster werden 3 Artefakt-Typen generiert:**

#### 4.3.1 Lesson-Draft (`artifact_type='lesson'`)

**Prompt-Template `lesson-draft-prompt`:**
```
System:
Du schreibst eine Lern-Lektion für ein E-Learning-Tool einer Schweizer Headhunting-Boutique.
Zielgruppe: {rollen} der Sparte {sparten}.
Format: Markdown mit Frontmatter. Klar, strukturiert, professionell.

Modul-Kontext:
Kurs: {course_title}
Modul: {module_title}

Lerninhalt (aus folgenden Quellen zusammengestellt):
{chunks_text}

Zusätzliche Notizen des Wissensträgers:
{book_notes}

Schreibe EINE Lesson mit:
- Frontmatter: slug, title, order, min_read_seconds
- Einleitung (1 Absatz, warum das Thema wichtig ist)
- 3-5 Hauptabschnitte mit Überschriften
- Praxis-Beispiel aus dem Schweizer Markt
- Kurze Zusammenfassung

Keine Embeds erfinden (Bilder, PDFs) — die werden später vom Autor ergänzt.
```

**LLM-Output:** Markdown-Body, gespeichert in `draft_content.markdown`.

#### 4.3.2 Quiz-Pool (`artifact_type='quiz_pool'`)

**Prompt-Template `quiz-generation-prompt`:**
```
System:
Du generierst einen Fragen-Pool für ein Modul-Quiz.
Alle 6 Fragen-Typen sind erlaubt: mc, multi, freitext, truefalse, zuordnung, reihenfolge.
Ziel: 15-20 Fragen verschiedener Schwierigkeitsgrade.

Modul-Inhalt:
{lesson_markdowns_concat}

Erzeuge einen YAML-Fragen-Pool gemäss folgendem Schema:

questions:
  - type: mc | multi | freitext | truefalse | zuordnung | reihenfolge
    question: <text>
    options: [...]         # bei mc/multi
    correct: <int | int[]> # bei mc/multi
    correct: <bool>        # bei truefalse
    musterloesung: <text>  # bei freitext
    keywords: [...]        # bei freitext
    pairs: [[a,b], ...]    # bei zuordnung
    items: [...]           # bei reihenfolge
    explanation: <text>
    difficulty: easy | medium | hard

Halte Distractors (falsche Optionen) realistisch, nicht offensichtlich falsch.
```

**LLM-Output:** YAML-Struktur, gespeichert in `draft_content.yaml`.

#### 4.3.3 Course/Module-Meta (`artifact_type='course_meta'` / `'module'`)

Nur bei Auto-Discovery-Clustering (kein vorhandener Kurs). Kürzere Prompts für Metadaten-Generierung.

### 3.5 R5 · Publish

**Trigger:** Event `elearn_artifact_approved`.

**Publish-Modus aus Tenant-Settings (`elearn_b.publish_mode`):**

#### 5.5.1 `direct`

1. Artefakt-Content rendern zu File (Lesson-MD oder Quiz-YAML).
2. Git-Clone Content-Repo (oder lokaler Checkout).
3. File an richtigem Pfad schreiben (`courses/<slug>/modules/<n>-<slug>/lessons/...` je nach Artefakt-Typ).
4. Commit mit Message `elearn-content-gen: <artifact_type> <slug> (job <id>)`.
5. Push nach `main`.
6. `dim_elearn_generated_artifact.status='published'`, `published_commit_sha`, Event.
7. **Sub-A-Import** wird automatisch getriggert durch Git-Webhook → Content ist live.

#### 5.5.2 `pr`

1. Schritte 1–5 wie oben, aber auf Branch `elearn-gen/<job_id>/<artifact_slug>`.
2. Push Branch.
3. GitHub-API: Open PR mit Title `E-Learning Content: <artifact_type> <slug>` und Body mit Job-Trace + Source-Referenzen.
4. `status='published'` mit `published_commit_sha` = PR-Head-SHA; PR-URL in Artifact-Meta gespeichert.
5. Human-zweite-Review via GitHub-PR-Interface.
6. Erst nach PR-Merge triggert Sub-A-Import.

**Error-Handling:** Push-Conflicts → Rebase-Retry 3×, dann fehlschlagen lassen (Event `elearn_artifact_publish_failed`, Admin-Notification).

## 4. Review-Workflow (UI-Flow)

### 4.1 Review-Queue-Page

`erp/elearn/admin/content-gen-review.html`:
- Tabelle mit Artefakten, Default-Sort `created_at ASC` (oldest first).
- Filter: `artifact_type`, `target_course_slug`, `status`, `job_id`.
- Badge pro Reviewer für offene Artefakte (Auto-Assign aus Tenant-Settings).

### 4.2 Artefakt-Drawer (540 px)

**Layout:**
```
┌ Artefakt: Lesson "Grosse Planer der Schweiz"
│ Target: arc-marktwissen > hauptakteure
│ Job #42 · generiert 2026-04-20 14:30 · Claude Sonnet 4.6 · 1.23 € Cost
│
├ Inhalt (Tabs)
│   [Preview] [Source] [Chunks] [Diff]
│
│ Preview: Rendered Markdown mit Syntax-Highlighting
│ Source:  Raw Markdown (editierbar)
│ Chunks:  Liste der 7 Quellchunks mit Similarity-Score
│ Diff:    nur sichtbar wenn Update einer bestehenden Lesson
│
├ Kommentar (optional)
│ [Textarea für Ablehnungs-/Edit-Grund]
│
└ [Ablehnen]   [Bearbeiten]   [Freigeben]   [Direkt publishen]
```

**Aktionen:**
- `Freigeben`: `status='approved'`, triggert R5-Publish im Hintergrund.
- `Direkt publishen`: identisch zu Freigeben, nur UI-Shortcut.
- `Bearbeiten`: öffnet Editor-Modus, Source-Tab wird editierbar, Diff wird live berechnet, bei Save → `action='edit'` in `fact_elearn_review_action` + `status` bleibt `draft` für erneutes Review oder `approved` falls Head-Rolle.
- `Ablehnen`: Grund-Pflicht, `status='rejected'`.

### 4.3 Keyboard-Shortcuts

- `J` / `K` → next/prev Artefakt
- `A` → Freigeben
- `R` → Ablehnen (öffnet Grund-Textarea)
- `E` → Bearbeiten
- `P` → Direkt publishen
- `Esc` → Drawer schliessen

## 5. Scheduling & Config-Hot-Reload

### 5.1 Web-Source-Scheduler

- `dim_elearn_source` mit `kind='web_url'` hat `meta.schedule` (z.B. `weekly`, `daily`, `cron=0 3 * * 1`).
- Worker `elearn-web-scraper` läuft jede Stunde und prüft, welche Sources fällig sind (basierend auf `last_ingested_at` + Schedule).
- Fälligkeit: wenn `NOW() >= last_ingested_at + schedule_interval`.

### 5.2 CRM-Query-Scheduler

- Analog `kind='crm_query'`.
- SQL-Templates in Git versioniert; Config-Änderung via `POST /api/elearn/admin/content-gen/config/crm-queries`.

### 5.3 Config-Changes

Config-YAML-Files (`config/elearn-web-sources.yml`, `config/elearn-crm-queries.yml`) werden via Endpoint gespeichert. Backend validiert YAML-Schema, sync'd `dim_elearn_source` (Upsert neuer / Disable entfernter).

## 6. Cost-Management

### 6.1 Cost-Tracking pro Job

Jeder LLM-Call schreibt in `dim_elearn_generation_job.total_tokens_in/out` und `total_cost_eur`. Kosten-Berechnung aus Modell-Preisen (hardcoded Konstante pro Modell in `tools/elearn-content-gen/lib/pricing.py`).

### 6.2 Cost-Caps

**Per Job Cap (`elearn_b.llm_cost_cap_per_job_eur`, Default 5):**
- Vor jedem LLM-Call: Check `current_job.total_cost_eur + estimated_call_cost <= cap`.
- Bei Überschreitung: Job pausiert, Event `elearn_cost_cap_exceeded`, Admin-Notification. Manueller Resume via API.

**Monthly Cap (`llm_cost_cap_monthly_eur`, Default 200):**
- Worker `elearn-cost-monitor` täglich:
  ```sql
  SELECT SUM(total_cost_eur) FROM dim_elearn_generation_job
  WHERE tenant_id = $1 AND started_at >= DATE_TRUNC('month', NOW())
  ```
- Bei ≥ 95 %: Warnung. Bei ≥ 100 %: Neue Jobs werden pending-blockiert bis Monatsende oder manueller Reset.

### 6.3 Cost-Dashboard

In `content-gen.html` Widget:
- Monats-Budget, Verbrauch, Restbudget (Progress-Bar farbkodiert).
- Top-5 teuerste Jobs des Monats.
- Cost pro Source-Kind aggregiert.

## 7. LinkedIn-Scraper-Port (Implementation-Notiz)

Selektive Libs aus `C:\Linkedin_Automatisierung\lib\` nach `Ark_CRM/tools/elearn-content-gen/lib/`:

| Original | Ziel | Anpassungen |
|----------|------|-------------|
| `anthropic_client.py` | `llm_client.py` | Tenant-aware Settings-Loader |
| `embedding_client.py` | `embedding_client.py` | unverändert, nur Config-Quelle |
| `dedup.py` | `dedup.py` | unverändert |
| `frontmatter_io.py` | `frontmatter_io.py` | unverändert |
| `config_loader.py` | `config_loader.py` | Tenant-Scoping ergänzen |
| `r1_runner.py`-Pattern | `r1_ingest.py` | Source-Kind-Dispatcher neu; LinkedIn-spezifisches raus |
| `r2_runner.py`-Pattern | `r2_chunk_embed.py` | Chunking unverändert |
| `r3_runner.py`-Pattern | `r3_cluster.py` | LinkedIn-Format-Scanner raus, Topic-Cluster rein |
| `r4_runner.py`-Pattern | `r4_generate.py` | Komplett neu schreiben für ARK-Output-Format |
| — | `r5_publish.py` | Neu: Git-Commit/PR-Logic |
| `newsletter_generator.py` | **Sub C** (nicht hier) | — |

**Lizenz-Check:** vor Port sicherstellen, dass Libs MIT/Apache-lizenziert oder in-house. Peter hat intern geschrieben → OK.

## 8. State-Diagramme

### 8.1 `dim_elearn_generation_job.status`

```
pending → running → ready_for_review → completed
                            ↓
                         failed (bei Error)
```

### 8.2 `dim_elearn_generated_artifact.status`

```
draft → approved → published
  ↓        ↓
rejected  superseded (überholte Version)
```

### 8.3 Source-Lifecycle

```
dim_elearn_source.enabled=true
  → R1 ingested (new hash) → R2 chunks → (aggregated) R3 → R4 → R5
  → enabled=false (manuell oder wegen Fehlern) → Source pausiert
```

## 9. Integration mit Sub A

**Datenfluss:**
```
Sub B R5 Publish → Content-Repo (Git push) → Webhook → Sub A POST /admin/import
                                                          ↓
                                                  Sub A parses + upserts → MA sehen neue Kurse
```

**Artifact-Traceability:** `dim_elearn_generated_artifact.published_commit_sha` + Sub A `fact_elearn_import_log.commit_sha` verknüpft → Click von importiertem Kurs zurück zum Generation-Job möglich.

## 10. Integration mit Sub C (Newsletter)

Sub C nutzt identische R1–R3-Runner für Newsletter-Content-Sourcing. R4 hat eigenes Newsletter-Template. R5 publisht nicht in Content-Repo, sondern in Newsletter-Tabelle (`fact_elearn_newsletter_issue`, kommt in Sub-C-Spec). Details: Sub C.

## 11. Fehler-Szenarien

| Szenario | Verhalten |
|----------|-----------|
| LLM-Rate-Limit (429) | Exponential-Backoff, max 5 Retries, dann Job pausiert |
| LLM-Output-Validation-Fehler (YAML invalid) | 2 Retries mit „validation-feedback"-Prompt, dann Artefakt mit `status='draft'` + Fehler-Meta |
| Git-Push-Conflict | Rebase + Retry 3×, dann `elearn_artifact_publish_failed` |
| CRM-Query-Error | Source-Status `enabled=false` automatisch, Admin-Alert |
| Embedding-Dimension-Mismatch (Modell-Wechsel) | Alle Chunks des Tenants re-embedden via Migration-Task |
| Anonymisierung lässt Namen durch | Review-UI markiert suspected-PII, Head soll vor Approve cleanen |

## 12. Nächste Schritte

1. Peter reviewt SCHEMA + INTERACTIONS.
2. Sub B Grundlagen-Patches werden parallel erzeugt (analog Sub A).
3. Nach Freigabe: konsolidierter Implementation-Plan A+B.
4. Sub C Brainstorming.
