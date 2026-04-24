# ARK CRM — Stammdaten-Patch · E-Learning Sub B · v0.1

**Scope:** Neue Enums und Activity-Types für den Content-Generator (Sub B).
**Zielversion:** gemeinsam mit Sub-A-Patch in nächstem Version-Bump.
**Basis-Specs:** `specs/ARK_E_LEARNING_SUB_B_SCHEMA_v0_1.md`, `specs/ARK_E_LEARNING_SUB_B_INTERACTIONS_v0_1.md`.
**Vorheriger Patch:** `specs/ARK_STAMMDATEN_PATCH_ELEARNING_v0_1.md` (Sub A).
**Stand:** 2026-04-20
**Status:** Review ausstehend (Peter)

---

## Changelog

| # | Katalog | Änderung |
|---|---------|----------|
| 1 | `elearn_source_kind` | NEU (5 Werte: pdf/docx/book/web_url/crm_query) |
| 2 | `elearn_source_priority` | NEU (3 Werte: low/normal/high) |
| 3 | `elearn_job_status` | NEU (5 Werte: pending/running/ready_for_review/completed/failed) |
| 4 | `elearn_job_triggered_by` | NEU (3 Werte: scheduled/manual/event) |
| 5 | `elearn_artifact_type` | NEU (5 Werte: course_meta/module/lesson/quiz_question/quiz_pool) |
| 6 | `elearn_artifact_status` | NEU (5 Werte: draft/approved/rejected/published/superseded) |
| 7 | `elearn_review_action` | NEU (5 Werte: approve/reject/edit/delete/publish) |
| 8 | `elearn_publish_mode` | NEU (2 Werte: direct/pr) — Tenant-Setting-Enum |
| 9 | `dim_activity_types` | +12 Seed-Rows (`elearn_*` Sub-B-Activities) |
| 10 | `dim_event_types` | +12 Seed-Rows (`elearn_*` Sub-B-Events) |

---

## 1. Neue Enums

### 1.1 `elearn_source_kind`

| Wert | Bedeutung |
|------|-----------|
| `pdf` | PDF-Upload in `raw/E-Learning/<thema>/` |
| `docx` | Word-Dokument |
| `book` | Buch-Volltext + Notes-Sidecar |
| `web_url` | Scheduled Web-Scrape (SIA/ETH/Baublatt/Konkurrenten) |
| `crm_query` | SQL-Query gegen CRM-DB (anonymisiert) |

### 1.2 `elearn_source_priority`

| Wert | Bedeutung |
|------|-----------|
| `low` | Niedrige Priorität |
| `normal` | Default |
| `high` | Priorisiert bei Generation-Batch |

### 1.3 `elearn_job_status`

| Wert | Bedeutung |
|------|-----------|
| `pending` | In Queue |
| `running` | R1–R4 aktiv |
| `ready_for_review` | R4 fertig, Artefakte warten auf Review |
| `completed` | Alle Artefakte reviewed |
| `failed` | Fehler (Error in `error`-Spalte) |

### 1.4 `elearn_job_triggered_by`

| Wert | Bedeutung |
|------|-----------|
| `scheduled` | Durch Cron-Scheduler |
| `manual` | Admin-Trigger aus UI |
| `event` | Event-driven (z. B. nach Source-Registrierung) |

### 1.5 `elearn_artifact_type`

| Wert | Bedeutung |
|------|-----------|
| `course_meta` | `course.yml`-Entwurf |
| `module` | `module.yml`-Entwurf |
| `lesson` | `lesson.md`-Entwurf |
| `quiz_question` | Einzelne Frage |
| `quiz_pool` | Komplette `quiz.yml` |

### 1.6 `elearn_artifact_status`

| Wert | Bedeutung |
|------|-----------|
| `draft` | Neu generiert, wartet auf Review |
| `approved` | Reviewt, Publish läuft |
| `rejected` | Abgelehnt mit Grund |
| `published` | Im Content-Repo committed |
| `superseded` | Durch neueren Artefakt ersetzt oder via Expiry archiviert |

### 1.7 `elearn_review_action`

| Wert | Bedeutung |
|------|-----------|
| `approve` | Artefakt freigegeben |
| `reject` | Artefakt abgelehnt |
| `edit` | Artefakt inline editiert |
| `delete` | Artefakt gelöscht |
| `publish` | Commit im Content-Repo |

### 1.8 `elearn_publish_mode`

| Wert | Bedeutung |
|------|-----------|
| `direct` | Direkt-Commit auf `main` des Content-Repos |
| `pr` | Auto-PR im Content-Repo (GitHub-Review-Stufe) |

## 2. Erweiterung bestehender Kataloge

### 2.1 `dim_activity_types` — Seed-Rows (12 neu)

| activity_type_name | activity_category | activity_channel | is_auto_loggable | description |
|--------------------|--------------------|------------------|------------------|-------------|
| elearn_source_registered | elearning | System | true | E-Learning: Content-Source registriert |
| elearn_source_failed | elearning | System | true | E-Learning: Source-Ingest-Fehler |
| elearn_job_started | elearning | System | true | E-Learning: Generation-Job gestartet |
| elearn_job_completed | elearning | System | true | E-Learning: Generation-Job abgeschlossen |
| elearn_job_failed | elearning | System | true | E-Learning: Generation-Job fehlgeschlagen |
| elearn_artifact_approved | elearning | CRM | true | E-Learning: Artefakt freigegeben |
| elearn_artifact_rejected | elearning | CRM | true | E-Learning: Artefakt abgelehnt |
| elearn_artifact_edited | elearning | CRM | true | E-Learning: Artefakt bearbeitet |
| elearn_artifact_published | elearning | System | true | E-Learning: Artefakt ins Content-Repo committed |
| elearn_cost_cap | elearning | System | true | E-Learning: LLM-Kostenlimit erreicht |

(Kategorie `elearning` existiert bereits aus Sub-A-Patch.)

### 2.2 `dim_event_types` — Seed-Rows (12 neu)

Siehe Backend-Patch `ARK_BACKEND_ARCHITECTURE_PATCH_ELEARNING_SUB_B_v0_1.md §1`.

## 3. UI-Label-Vocabulary (Ergänzung `wiki/meta/mockup-baseline.md §16`)

| Enum-Wert | UI-Label (DE) |
|-----------|---------------|
| `source_kind=pdf` | PDF-Dokument |
| `source_kind=docx` | Word-Dokument |
| `source_kind=book` | Buch |
| `source_kind=web_url` | Web-Quelle |
| `source_kind=crm_query` | CRM-Abfrage |
| `source_priority=low` | Niedrig |
| `source_priority=normal` | Normal |
| `source_priority=high` | Hoch |
| `job_status=pending` | Wartet |
| `job_status=running` | Läuft |
| `job_status=ready_for_review` | Zur Prüfung |
| `job_status=completed` | Abgeschlossen |
| `job_status=failed` | Fehler |
| `job_triggered_by=scheduled` | Automatisch |
| `job_triggered_by=manual` | Manuell |
| `job_triggered_by=event` | Ereignis-gesteuert |
| `artifact_type=course_meta` | Kurs-Metadaten |
| `artifact_type=module` | Modul |
| `artifact_type=lesson` | Lesson |
| `artifact_type=quiz_question` | Quiz-Frage |
| `artifact_type=quiz_pool` | Quiz-Pool |
| `artifact_status=draft` | Entwurf |
| `artifact_status=approved` | Freigegeben |
| `artifact_status=rejected` | Abgelehnt |
| `artifact_status=published` | Veröffentlicht |
| `artifact_status=superseded` | Überholt |
| `review_action=approve` | Freigeben |
| `review_action=reject` | Ablehnen |
| `review_action=edit` | Bearbeiten |
| `review_action=delete` | Löschen |
| `review_action=publish` | Publizieren |
| `publish_mode=direct` | Direkt-Commit |
| `publish_mode=pr` | Pull-Request |

## 4. Wiki-Sync

Nach Merge zu aktualisieren:

- `wiki/meta/mockup-baseline.md §16` — UI-Label-Vocabulary Sub-B-Block ergänzen.
- `wiki/concepts/elearning-module.md` — Sub-B-Abschnitt ergänzen (Content-Generator-Pipeline-Erklärung).
- `wiki/meta/spec-sync-regel.md` — Sub-B-Specs in Matrix aufnehmen.

## 5. Offene Punkte

- Neue Badge-Types für Autoren-Role (z. B. „Content-Publisher" — MA, der > 10 Artefakte approved hat) — Phase-2.
