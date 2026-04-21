# ARK CRM — Gesamtsystem-Übersicht-Patch · E-Learning Sub B · v0.1

**Scope:** High-Level-Ergänzung zur Gesamtsystem-Übersicht für Sub B (Content-Generator).
**Zielversion:** gemeinsam mit Sub-A-Patch in Gesamtsystem v1.4.
**Basis-Specs:** `specs/ARK_E_LEARNING_SUB_B_SCHEMA_v0_1.md`, `specs/ARK_E_LEARNING_SUB_B_INTERACTIONS_v0_1.md`.
**Vorheriger Patch:** `specs/ARK_GESAMTSYSTEM_PATCH_ELEARNING_v0_1.md` (Sub A).
**Stand:** 2026-04-20
**Status:** Review ausstehend (Peter)

---

## Changelog

| # | Bereich | Änderung |
|---|---------|----------|
| 1 | Modul-Landkarte | Sub B Status: Spec v0.1 abgeschlossen |
| 2 | Daten-Flüsse | Externe Integrationen erweitert (LLM, Embeddings, Git, Web-Scraping) |
| 3 | Phasen-Plan | Sub B Meilensteine ergänzt |
| 4 | Kosten-Management | neues Budget-Konzept pro Tenant dokumentiert |
| 5 | Sub-System-Interaktion | Sub B → Sub A Publish-Loop (Git-Webhook) dokumentiert |

---

## 1. Modul-Landkarte (aktualisiert)

```
Phase 3 · ERP-Ergänzungen
  ├── HR-Tool
  ├── Zeiterfassung
  ├── Commission-Engine
  ├── E-Learning
  │   ├── Sub A: Kurs-Katalog        (Specs v0.1 ✓, Patches v0.1 ✓, Implementation ausstehend)
  │   ├── Sub B: Content-Generator   (Specs v0.1 ✓, Patches v0.1 ✓, Implementation nach Sub A)
  │   ├── Sub C: Wochen-Newsletter   (Entwurf offen, nutzt Sub-B-Pipeline)
  │   └── Sub D: Progress-Gate       (Entwurf offen)
  └── Doc-Generator
```

## 2. Sub-B-Eigenständigkeit

- **Pipeline-Code** lebt in `tools/elearn-content-gen/` (Python-Subdirectory im ARK-Repo).
- **Code-Port aus** `C:\Linkedin_Automatisierung` (LinkedIn-Automation-Projekt, Peter-intern). Selektive Wiederverwendung von `anthropic_client`, `embedding_client`, `dedup`, `frontmatter_io`, `config_loader`, R1–R4-Runner-Pattern.
- **Schema-Namespace:** `dim_elearn_source`, `dim_elearn_chunk`, `dim_elearn_generation_job`, `dim_elearn_generated_artifact`, `fact_elearn_review_action` (alle tenant-scoped).
- **UI-Namespace:** `erp/elearn/admin/content-gen*.html` (Admin-only).
- **API-Namespace:** `/api/elearn/admin/content-gen/*`.

## 3. Sub-B-Meilensteine

1. Spec-Freigabe (SCHEMA + INTERACTIONS + 5 Patches) — **aktueller Stand**.
2. Port-Audit LinkedIn_Automatisierung → Liste der zu portierenden Files erstellen.
3. Implementation-Plan via `superpowers:writing-plans` (konsolidiert mit Sub A).
4. Python-Worker-Setup (`tools/elearn-content-gen/` Package, `pyproject.toml`, Dependencies).
5. DB-Migration (pgvector-Extension + 5 Tabellen + Indizes).
6. R1-Ingest-Runner pro Source-Kind (PDF → DOCX → Book → Web → CRM, iterativ).
7. R2-Chunk-Embed (inkl. pgvector-Integration).
8. R3-Cluster + R4-Generate (LLM-Prompt-Templates iterieren bis Output-Qualität OK).
9. R5-Publish (Git-Commit/PR-Mechanik).
10. Admin-UI (Content-Gen-Dashboard, Sources-Verwaltung, Review-Queue).
11. Pilot: 2-3 echte Sources (z. B. 1 SIA-PDF + 1 Web-Scrape + 1 CRM-Query) → Output prüfen.
12. Rollout: Content-Repo mit initialen generierten Kursen füllen (Markt-/HR-/Recruiting-Grundlagen).

## 4. Daten-Flüsse Sub B → Sub A

```
Sub B · R5 Publish
    │
    ├── Git-Push nach arkadium/ark-elearning-content
    │       (Branch main oder PR je Tenant-Setting)
    │
    └── Git-Webhook → Sub A · POST /api/elearn/admin/import
                                      │
                                      ▼
                           Sub A: Parse + Upsert Kurse/Module/Lessons/Fragen
                                      │
                                      ▼
                           MA sieht neuen Kurs/Refresher in Dashboard
```

**Traceability:**
- `dim_elearn_generated_artifact.published_commit_sha` == Sub-A `fact_elearn_import_log.commit_sha`.
- Von einem importierten Kurs kann bis zum Generation-Job zurückverfolgt werden (Audit).

## 5. Externe Integrationen (erweitert)

| Integration | Zweck | Richtung |
|-------------|-------|----------|
| Anthropic API | LLM-Generation (Claude Sonnet 4.6 + Haiku 4.5) | Ausgehend |
| OpenAI API | Embeddings (text-embedding-3-small) | Ausgehend |
| Voyage AI API | Alternative Embeddings (voyage-3) | Ausgehend (optional, tenant-override) |
| GitHub API | PR-Creation bei `publish_mode='pr'` | Ausgehend |
| Git (Content-Repo) | Clone/Push für Content-Sync | Beide |
| Web-Scraping (SIA/ETH/…) | Source-Ingest | Ausgehend (HTTP-Requests) |
| CRM-DB (eigene) | SQL-Queries für CRM-Source-Ingest | Intern (read-only Role) |

## 6. Kosten-Management (neu)

**Konzept:** LLM-Kosten pro Tenant budgetierbar. Jeder Generation-Job trackt Tokens + Cost.

**Default-Budget:** 200 €/Monat pro Tenant, 5 €/Job (Tenant-konfigurierbar).

**Monitoring:**
- `elearn-cost-monitor` (Cron täglich).
- Bei ≥ 95 % Monats-Cap → Admin-Notification.
- Bei 100 % → Neue Jobs blockiert (manueller Reset oder Monats-Rollover).

**Cost-Dashboard:**
- Monats-Verbrauch + Restbudget.
- Top-Jobs nach Kosten.
- Aggregation nach Source-Kind.

## 7. Sicherheit & Compliance

- **CRM-Daten-Anonymisierung:** Regex-basiert pre-persist; Head kann im Review-Drawer PII-Markers prüfen.
- **Read-only DB-Role:** Sub-B-CRM-Query-Runner nutzt dedicated `elearn_content_gen_reader` Postgres-Role.
- **LLM-Prompt-Logging:** Prompts + Responses werden in `dim_elearn_generation_job.llm_prompt_template` (Slug) referenziert. Volltext optional in separater Audit-Tabelle (Phase-2, falls Compliance es fordert).
- **GitHub-PAT-Handling:** Vault-Referenz, niemals in Logs/Settings-Klartext.

## 8. Performance & Skalierung

**Erwartetes Volumen pro Tenant/Jahr:**
- ~500 Sources, ~100 000 Chunks, ~1 000 Generation-Jobs, ~10 000 Artefakte.
- **Kritischer Pfad:** pgvector-RAG-Retrieval → < 100 ms mit IVFFLAT.
- **Generation-Durchsatz:** ~2–5 Min pro Modul (entspricht ~300 Modulen/Monat bei single-Worker).

**Skalierung:**
- Python-Worker horizontal skalierbar (Concurrency konfigurierbar).
- Embedding-Client Rate-Limit-aware (Backoff).
- IVFFLAT-Reindex bei > 10 % Chunk-Wachstum.

## 9. Team-Verantwortlichkeiten (erweitert)

| Rolle | Sub-B-Verantwortung |
|-------|---------------------|
| Peter | Quellen-Kuration (Bücher, Notizen, Prio-PDFs), Review aller generierten Artefakte |
| Head-of | Review-Queue-Bearbeitung für eigene Sparte (Auto-Assign) |
| Admin/Backoffice | Source-Verwaltung, Scheduler-Config, Cost-Monitoring, GitHub-PAT-Rotation |
| MA | keine Sub-B-Interaktion (sehen nur fertigen Content aus Sub A) |

## 10. Referenz-Dokumente

- **SCHEMA Sub B:** `specs/ARK_E_LEARNING_SUB_B_SCHEMA_v0_1.md`
- **INTERACTIONS Sub B:** `specs/ARK_E_LEARNING_SUB_B_INTERACTIONS_v0_1.md`
- **DB-Patch Sub B:** `specs/ARK_DATABASE_SCHEMA_PATCH_ELEARNING_SUB_B_v0_1.md`
- **Backend-Patch Sub B:** `specs/ARK_BACKEND_ARCHITECTURE_PATCH_ELEARNING_SUB_B_v0_1.md`
- **Stammdaten-Patch Sub B:** `specs/ARK_STAMMDATEN_PATCH_ELEARNING_SUB_B_v0_1.md`
- **Frontend-Patch Sub B:** `specs/ARK_FRONTEND_FREEZE_PATCH_ELEARNING_SUB_B_v0_1.md`

## 11. Offene Punkte / Follow-ups

- **Sub C** nutzt dieselbe Pipeline R1–R4, aber eigener R4-Newsletter-Prompt und eigener Publish-Pfad (nicht in Content-Repo, sondern in Newsletter-DB-Tabelle). Sub-C-Brainstorming als nächster Schritt.
- **Sub D** unabhängig.
- **Port-Entscheidung:** bleiben LinkedIn_Automatisierung-Files als eigenes Repo für LinkedIn-Automation oder wird das Repo komplett archiviert und in ARK-CRM konsolidiert? Peter entscheidet vor Implementation-Start.
