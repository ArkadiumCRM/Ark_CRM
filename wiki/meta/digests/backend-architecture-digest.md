---
title: "Backend Architecture Digest v2.5.5"
type: meta
created: 2026-04-17
updated: 2026-04-17
sources: ["ARK_BACKEND_ARCHITECTURE_v2_5.md"]
tags: [digest, backend, architecture, events, worker, endpoints, sagas]
---

# Backend Architecture Digest — v2.5.5 (Stand 2026-04-17)

Kompaktes Nachschlagewerk aus `Grundlagen MD/ARK_BACKEND_ARCHITECTURE_v2_5.md` (~3810 Zeilen; v2.5 + v2.5.4 Dok-Generator-Addendum §L + v2.5.5 Outlook-Architektur-Update 2026-04-17). Events, Worker, Endpunkte, Sagas, WebSocket-Channels und Settings-Keys **verlustfrei**. Request-/Response-Shapes, Saga-Step-Internals, Prosa: weggelassen — siehe Volltext.

## Architektur-Änderung v2.5.5 (2026-04-17)

**Outlook-Integration:** Shared-Mailbox-Ansatz (ursprünglich Phase 1) **verworfen**. Ersatz: **individuelle User-Tokens** — jeder Mitarbeiter OAuth-verbindet sein persönliches Outlook-Postfach einmalig. Entfernt: `OUTLOOK_SHARED_ACCOUNT` ENV-Var · „Phase 1 / Phase 2"-Sprachregelung. Grund: einfachere Architektur, klare User-Ownership, DSG-konform. Siehe `wiki/concepts/email-system.md` für Wiki-Dokumentation und `specs/ARK_EMAIL_KALENDER_DETAILMASKE_SCHEMA_v0_1.md` für Detailmaske.

## TOC — Quellen-Sections

**Teil v2.5 (Ergänzung, Zeilen 1-377):**

- **A. Neue Event-Typen** (30+) — Mandat/Schutzfrist/Claim/Assessment/Prozess/Job/Scraper/Firmengruppen/Projekt/Saga-Failure
- **B. Neue Worker** (18) — Nightly-Batch/Event-getrieben/Scraper/Datenqualität/Workflow
- **C. Neue Endpunkte** (46) — Mandat/Prozess/Assessment/Account/Firmengruppe/Scraper/Kandidat/Projekt/User-Prefs
- **D. Atomare Transaktionen / Sagas** (8) — V1-V7 Placement + Report-Upload + Kündigung + weitere
- **E. WebSocket-Infrastruktur** — Topic-basierte Live-Updates
- **F. Scraper-Rate-Limiting** — Token-Bucket pro (scraper_type, target_domain)
- **G. Event-Scope-Registry** — Multi-Entity-Events
- **H. dim_automation_settings Keys** — Verweist auf Stammdaten §66
- **I. Priority-Roadmap v2.5** — P0/P1/P2
- **J. Detailseiten-Spec-Referenzen**
- **L. Dok-Generator-Endpoints** (NEU v2.5.4, 2026-04-17) — 9 Endpoints + Wrapper-Mapping + 3 Events

**Teil v2.4 (Original, Zeilen 381-3716):**

- **§0** Grundregeln (10)
- **§1** Zielbild — Modularer Monolith mit Event Spine
- **§2** Tech Stack — Node+Fastify+TypeScript+Supabase+PgBoss+Railway
- **§3** 6-Schichten-Modell — API/Services/Policies/Repos/Workers/Adapters
- **§4** Ordnerstruktur
- **§5** API-Design — Response-Shape, Statuscodes, Pagination
- **§6** Auth & RBAC — JWT, Refresh, RLS vs Service Role, Session-Mgmt
- **§7** Concurrency Control — row_version / updateWithVersion()
- **§7b** Multi-Tenancy — tenant_id aus JWT, Tenant-Safe Repo
- **§8** Validierung — Zod
- **§9** Business Logic — Controller/Service/Repository + Statusmaschinen (CANDIDATE/PROCESS/MANDATE/JOB/VACANCY/MANDATE_RESEARCH)
- **§10** Event-System — Outbox, Idempotenz, Event Processor, PgBoss
- **§10b** Stage-Automatisierungen — Kandidat/Mandat-Research/Jobbasket
- **§11** Endpunkt-Übersicht Phase 1 (Full-List)
- **§12** Worker-Architektur (12 Pflicht-Worker)
- **§13** Integrationen — 3CX dual / Outlook / LinkedIn / Power BI
- **§14** AI/LLM — Governance, Adapter, RAG, Matching
- **§15** Dokument-Upload-Sicherheit — Virus-Scan obligatorisch
- **§16** Error Handling & Logging
- **§17** Sicherheit — Headers, Rate Limit, CORS, HMAC
- **§18** Audit Log
- **§19** Performance — Caching-Strategie
- **§20** Datenschutz — Anonymisierung, Retention
- **§21** Observability
- **§22** Testing-Strategie
- **§23** Deployment Railway + Env-Vars
- **§24** Build-Reihenfolge (7 Wellen)
- **§25** Top-10-Risiken
- **§26** Phase-2-Kompatibilität
- **§27** Feature Flags
- **§28** Bulk Operations
- **§29** Domain Error Katalog (ERROR_CODES)
- **§30** Migrations + Seeds + Backup
- **§31** OpenAPI/Swagger
- **§32** Local Dev (ngrok)
- **§33** Postgres-to-AppError Mapper
- **§34** Zod-Schema Reuse für Worker-Payloads
- **§35** Backpressure & Queue-Priorisierung
- **§36** SLOs & Alert-Schwellen
- **§37** Data Quality als Backend-Capability
- **§38** Contract Tests
- **§39** Read Model & Projection — Views / Materialized Views
- **§40** Field Level Permissions — filterFieldsByRole()
- **§41** Request Context Typ
- **§42** Admin-Diagnose-Endpunkte
- **§43** Dokument-Download Governance
- **§44** Beispiel-Flows (4 End-to-End)
- **§45** Runbooks & Incident-Playbooks (6)
- **§46** Modul-Definitionen — Search / RAG / Matching / Recommendation
- **§47** API Breaking-Change & Deprecation Policy
- **§48** Graceful Shutdown
- **§49** Singleton Jobs / Leader Election
- **§50** DB Timeouts & Connection Pool

---

## Events (lossless)

### Kandidat (9)

| Event | Scope |
|-------|-------|
| `candidate.created` | Kandidat |
| `candidate.stage_changed` | Kandidat |
| `candidate.updated` | Kandidat |
| `candidate.deleted` | Kandidat |
| `candidate.merged` | Kandidat |
| `candidate.briefing_created` | Kandidat |
| `candidate.document_uploaded` | Kandidat |
| `candidate.assessment_completed` | Kandidat |
| `candidate.anonymized` | Kandidat |

### Prozess (11 + v2.4-Basis)

| Event | Scope |
|-------|-------|
| `process.created` / `process_created` | Prozess |
| `process.stage_changed` | Prozess |
| `process.placement_done` | Prozess |
| `process.closed` / `process_closed` | Prozess |
| `process.reopened` | Prozess |
| `process.on_hold` | Prozess |
| `process.rejected` | Prozess |
| `stale_detected` | Prozess |
| `interview_scheduled` | Prozess |
| `interview_rescheduled` | Prozess |
| `coaching_added` | Prozess |
| `debriefing_added` | Prozess |
| `placed` | **5 Entities**: Kandidat + Account + Job + Prozess + Mandat |
| `placement_cancelled` | Prozess |
| `early_exit_recorded` | Prozess |
| `guarantee_refund_issued` | Prozess |

### Job (8 + v2.4-Basis)

| Event | Scope |
|-------|-------|
| `job.created` / `job_created_manual` | Job |
| `job.stage_changed` | Job |
| `job.filled` / `job_filled` | Job |
| `job.cancelled` | Job |
| `job.vacancy_detected` | Job |
| `job.published` | Job |
| `job_from_scraper` | Job |
| `job_from_mandate` | Job |
| `job_from_org_position` | Job |
| `scraper_proposal_confirmed` | Job |
| `scraper_proposal_rejected` | Job |
| `job_closed` | Job |
| `job_disappeared_from_source` | Job |
| `matching_recomputed` | Job |

### Mandat (9)

| Event | Scope |
|-------|-------|
| `mandate.created` | Mandat |
| `mandate.stage_changed` | Mandat |
| `mandate.completed` / `mandate_completed` | Mandat + Account |
| `mandate.cancelled` | Mandat |
| `mandate_terminated` | Mandat + Account |
| `termination_invoice_generated` | Mandat + Account |
| `mandate_option_ordered` | Mandat + Account |
| `mandate_longlist_locked` | Mandat |
| `shortlist_trigger_reached` | Mandat |
| `process_rejected_due_to_mandate_termination` | Prozess + Mandat |
| `exclusivity_ended` | Mandat |
| `group_mandate_created` | Gruppe + beteiligte Accounts |

### Schutzfrist & Claim (7)

| Event | Scope |
|-------|-------|
| `candidate_presented_email` | Kandidat + Account + Mandat |
| `candidate_presented_verbal` | Kandidat + Account + Mandat |
| `protection_window_opened` | Kandidat + Account (+ Gruppe bei scope='group') |
| `protection_window_extended` | Kandidat + Account |
| `protection_violation_detected` | Alert + Kandidat + Account/Gruppe |
| `claim_invoiced` | Account + Kandidat + Rechnung |
| `claim_context_determined` | Audit mit `context_case` ∈ {X, Y, Z} |

### Assessment (13)

| Event | Scope |
|-------|-------|
| `assessment_order_created` | Assessment-Order |
| `assessment_order_signed` | Assessment-Order |
| `assessment_credit_assigned` (inkl. Typ) | Assessment + Kandidat |
| `assessment_credit_reassigned_away` | Assessment + Kandidat |
| `assessment_credit_reassigned_to` | Assessment + Kandidat |
| `assessment_run_scheduled` | Assessment-Run |
| `assessment_run_completed` | Assessment-Run |
| `assessment_run_cancelled` | Assessment-Run |
| `assessment_version_created` | Assessment-Version |
| `assessment_order_cancelled` | Assessment-Order |
| `assessment_invoice_generated` | Assessment-Billing |
| `assessment_invoice_paid` | Assessment-Billing |
| `assessment_order_credits_rebalanced_by_founder` | Assessment-Order |
| `assessment.completed` (v2.4) | Assessment |
| `assessment.invite_sent` (v2.4) | Assessment |
| `assessment.expired` (v2.4) | Assessment |

### Scraper (12)

| Event | Scope |
|-------|-------|
| `scraper_run_started` | Scraper-Run |
| `scraper_run_finished` | Scraper-Run |
| `scraper_run_failed` | Scraper-Run |
| `scraper_run_retried` | Scraper-Run |
| `finding_detected` | Scraper-Finding |
| `finding_accepted` | Scraper-Finding |
| `finding_rejected` | Scraper-Finding |
| `finding_marked_low_confidence` | Scraper-Finding |
| `scraper_config_changed` | Scraper-Type |
| `alert_raised` | Scraper-Alert |
| `alert_acknowledged` | Scraper-Alert |
| `alert_dismissed` | Scraper-Alert |
| `auto_disable_triggered` | Scraper-Type |
| `anomaly_detected` | Scraper-Type |
| `scrape.change_detected` (v2.4) | Account |
| `scrape.new_job_detected` (v2.4) | Account |
| `scrape.person_left` (v2.4) | Account |
| `scrape.new_person` (v2.4) | Account |
| `scrape.role_changed` (v2.4) | Account |

### Firmengruppe (6)

| Event | Scope |
|-------|-------|
| `group_created_manual` | Firmengruppe |
| `group_created_suggested_by_scraper` | Firmengruppe |
| `group_created_confirmed` | Firmengruppe |
| `group_created_rejected` | Firmengruppe |
| `group_member_added` | Firmengruppe + Account |
| `group_member_removed` | Firmengruppe + Account |
| `group_culture_generated` | Firmengruppe |
| `group_framework_contract_added` | Firmengruppe |
| `group_protection_window_opened` | Firmengruppe + Kandidat |

### Projekt (8)

| Event | Scope |
|-------|-------|
| `project_created_manual` | Projekt |
| `project_created_from_candidate_werdegang` | Projekt + Kandidat |
| `project_created_from_scraper` | Projekt |
| `bkp_gewerk_added` | Projekt |
| `bkp_gewerk_removed` | Projekt |
| `company_participation_added` | Projekt + Account |
| `company_participation_changed` | Projekt + Account |
| `company_participation_removed` | Projekt + Account |
| `candidate_participation_added` | Projekt + Kandidat |
| `candidate_participation_changed` | Projekt + Kandidat |
| `candidate_participation_removed` | Projekt + Kandidat |
| `media_uploaded` | Projekt |
| `account_project_note_added` | Projekt + Account |
| `account_project_note_updated` | Projekt + Account |
| `classification_changed` | Projekt |

### Call / Email / Dokument / History (v2.4-Basis)

| Event | Scope |
|-------|-------|
| `call.received` | Kandidat/Account (via fact_call_context) |
| `call.transcript_ready` | Kandidat/Account |
| `call.missed` | Kandidat/Account |
| `email.received` | Kandidat/Account/Prozess |
| `email.sent` | Kandidat/Account/Prozess |
| `email.bounced` | Kandidat/Account |
| `document.uploaded` | Entity via document_type |
| `document.cv_parsed` | Kandidat |
| `document.ocr_done` | Document |
| `document.embedded` | Document |
| `document.reparsed` | Document |
| `history.created` | Entity |
| `history.ai_summary_ready` | Entity |

### Match (2)

| Event | Scope |
|-------|-------|
| `match.score_updated` | Kandidat + Job |
| `match.suggestion_ready` | Kandidat + Job |

### System (4)

| Event | Scope |
|-------|-------|
| `system.data_quality_issue` | Issue |
| `system.circuit_breaker_tripped` | Automation-Rule |
| `system.dead_letter_alert` | Job |
| `system.retention_action` | Kandidat |

### Saga-Failure + Batch (v2.5.1, 6)

| Event | Scope | Trigger |
|-------|-------|---------|
| `placement_failed` | Prozess | TX1 Rollback (Schutzfrist-Konflikt, mandate_locked, Validation-Fail) |
| `mandate_termination_failed` | Mandat | TX3 Rollback (placement_in_progress, Validation-Fail) |
| `reminder_batch_created` | Kandidat + Account | Nach Step 7 in TX1 (5 Auto-Reminders) |
| `interview_completed` | Prozess + Kandidat | Nach Debriefing gesetzt, Outcome=Continue |
| `finding_expired_unreviewed` | Scraper-Finding | Nach 14d in needs_am_review-Queue (P1.5 SLA) |
| `legal_hold_toggled` | Audit-Log | Admin setzt/hebt Legal-Hold |
| `reminder_reassigned` (v2.5.5) | Reminder + both Mitarbeiter | `POST /reminders/:id/reassign` — HoD+/Admin |
| `reminder_overdue_escalation` (v2.5.5) | Reminder + Zuständiger + Head of | Worker `reminder-overdue-escalation.worker.ts` bei 48 h überfällig |

**Hinweis CRUD-Events:** `description_updated`, `contact_changed`, `internal_notes_updated` etc. sowie Reminder-Lifecycle (`created`/`completed`/`snoozed`/`updated`) sind **nicht** dediziert — abgedeckt durch `fact_audit_log` mit generischem `entity_updated` + Field-Diff.

---

## Workers (lossless)

### Pflicht-Worker Phase 1 v2.4 (12)

| Worker | Zweck |
|--------|-------|
| `event-processor.worker.ts` | **Der wichtigste** — liest fact_event_queue (status=pending), lädt dim_automation_rules, Circuit Breaker, erzeugt Folgejobs, schreibt fact_event_log |
| `ai.worker.ts` | Klassifikationen (Generalist/Spezialist, Seniority, Culture Fit), Transkript-Summary, CV-Parsing, Dossier. Über ai-write.policy geprüft |
| `embedding.worker.ts` | Chunking + Embeddings (OpenAI/Anthropic), alte Chunks deaktivieren, Reindex |
| `document.worker.ts` | OCR → CV-Parsing → Embedding Pipeline. Status: none → pending → done/failed |
| `threecx.worker.ts` | Call Events, Telefonnummer → fact_call_context Lookup, Auto-History, Transkript-Trigger |
| `outlook.worker.ts` | Mail-Sync, Thread-Zuordnung zu Kandidat/Kontakt/Account/Prozess, Anhänge → Dokumente |
| `scraper.worker.ts` | Scraping-Ergebnisse, Änderungserkennung, Events |
| `email.worker.ts` | E-Mail-Versand mit Retry |
| `notification.worker.ts` | Push / In-App / SMS |
| `reminder.worker.ts` | Fällige Reminders aus fact_reminders |
| `retention.worker.ts` | PII-Retention, Anonymisierung, data_retention_date |
| `analytics.worker.ts` | Materialized View Refresh, Snapshots |

### Nightly-Batch-Worker v2.5 (8)

| Worker | Cron | Zweck |
|--------|------|-------|
| `stale-detection.worker.ts` | 03:00 | Prozesse `Open` mit überschrittenem Stage-Alter → `Stale` |
| `assessment-billing-overdue.worker.ts` | 02:00 | Rechnungen nach Zahlungsziel → `overdue` |
| `process-guarantee-closer.worker.ts` | 01:00 | Prozesse nach Garantiefrist → `closed` |
| `protection-window-auto-extend.worker.ts` | 02:00 | Schutzfrist 12 → 16 Monate bei fehlender Info-Antwort |
| `candidate-temperature-scorer.worker.ts` | 00:00 + 12:00 | Kandidat-Temperature (Hot/Warm/Cold) |
| `account-temperature-scorer.worker.ts` | 00:00 + 12:00 | Account-Temperature |
| `matching-daily-batch.worker.ts` | 04:00 | Matching-Recompute alle aktiven Jobs + Projekte |
| `reminder-overdue-escalation.worker.ts` (v2.5.5) | hourly 08–20h | 48-h-überfällige Reminders → Eskalation an Head of via `vorgesetzter_id` + Event. Idempotent via `fact_reminders.escalation_sent_at`. 24-h-Schwelle → Push an Zuständigen. |

### Event-getriebene Worker v2.5 (6)

| Worker | Trigger | Zweck |
|--------|---------|-------|
| `process-auto-reminder.worker.ts` | `placed` | 5 Auto-Reminders (Onboarding, 30/60/90 Tage, Garantie) |
| `matching-recompute.worker.ts` | Skill/Stage/Doc-Change | Async Score-Recompute |
| `referral-payout-trigger.worker.ts` | `placed` | Referral-Check + `payout_due_at` setzen |
| `process-interview-coaching-reminder.worker.ts` | `interview_scheduled` | Reminder 2d vor Termin |
| `process-interview-debriefing-reminder.worker.ts` | `interview_scheduled` | Reminder am Termin-Tag |
| `scraper-finding-processor.worker.ts` | `finding_detected` | Duplicate + Confidence + `review_priority` + Staging |

### Scraper-Worker v2.5 (3)

| Worker | Trigger | Zweck |
|--------|---------|-------|
| `scraper-batch-job.worker.ts` | Cron + Manual | Priority-Queue Scraper-Runs |
| `scraper-auto-disable.worker.ts` | N-Strike | Auto-Disable + Critical Alert |
| `scraper-antiduplicate.worker.ts` | Pre-Insert | Duplicate-Detection pro Typ |

### Datenqualität & System v2.5 (2)

| Worker | Zweck |
|--------|-------|
| `stammdaten-drift-detection.worker.ts` | Periodisch website_url / employee_count / founded_year prüfen |
| `websocket-publisher.worker.ts` | Event-Publishing an WebSocket-Clients |

### Workflow-Worker v2.5.1 (4)

| Worker | Trigger | Zweck |
|--------|---------|-------|
| `shortlist-trigger-payment.worker.ts` | `process.stage_changed → shortlist` | Target-Mandat: Stage-1-Zahlung setzen |
| `outlook-calendar-sync.worker.ts` | `interview_scheduled` / `_rescheduled` + Cron 15 min | Bidirektional MS Graph: ARK ↔ Outlook-Kalender (CM = Organizer) |
| `stale-notification.worker.ts` | Cron 09:00 | Reminder an AM für `process.status='Stale'` (48h / 7d Eskalation) |
| `process-closed-archiving.worker.ts` | `process_closed` + 30d Delay | Prozess-Payload in `archive.processes`, UI Read-Only |

### Scheduled Jobs (PgBoss)

| Job | Cron |
|-----|------|
| `cleanup-pii` | `0 2 * * *` (täglich 02:00) |
| `refresh-powerbi` | `0 */4 * * *` (alle 4h) |
| `scrape-accounts` | `0 8 * * 1-5` (Mo-Fr 08:00) |
| `worker-heartbeat` | `*/5 * * * *` (alle 5 min) |

Alle scheduled Jobs → **Pflicht** `singletonKey` (§49).

---

## Endpoints (lossless, method + path)

### Health (no auth)

```
GET    /health/live
GET    /health/ready
GET    /health/dependencies
```

### Auth (§6, §11)

```
POST   /api/v1/auth/login
POST   /api/v1/auth/refresh
POST   /api/v1/auth/logout
GET    /api/v1/auth/me
POST   /api/v1/auth/forgot-password
POST   /api/v1/auth/reset-password
POST   /api/v1/auth/change-password
GET    /api/v1/auth/sessions
DELETE /api/v1/auth/sessions/:id
DELETE /api/v1/auth/sessions
```

### Users / Mitarbeiter

```
GET    /api/v1/users
GET    /api/v1/users/:id
POST   /api/v1/users
PATCH  /api/v1/users/:id
GET    /api/v1/users/:id/permissions
PATCH  /api/v1/users/:id/permissions
```

### User-Preferences (v2.5.2)

```
GET    /api/v1/me/preferences
PATCH  /api/v1/me/preferences
```

### Kandidaten

```
GET    /api/v1/candidates
POST   /api/v1/candidates
GET    /api/v1/candidates/:id
PATCH  /api/v1/candidates/:id
DELETE /api/v1/candidates/:id
POST   /api/v1/candidates/:id/restore
POST   /api/v1/candidates/:id/stage-change
GET    /api/v1/candidates/:id/history
GET    /api/v1/candidates/:id/documents
GET    /api/v1/candidates/:id/employment
POST   /api/v1/candidates/:id/employment
PATCH  /api/v1/candidates/:id/employment/:employmentId
GET    /api/v1/candidates/:id/projects
POST   /api/v1/candidates/:id/projects
PATCH  /api/v1/candidates/:id/projects/:projectId
GET    /api/v1/candidates/:id/skills         # DEPRECATED v2.4
PUT    /api/v1/candidates/:id/skills         # DEPRECATED v2.4
GET    /api/v1/candidates/:id/functions
PUT    /api/v1/candidates/:id/functions
GET    /api/v1/candidates/:id/focus
PUT    /api/v1/candidates/:id/focus
GET    /api/v1/candidates/:id/assessments
GET    /api/v1/candidates/:id/briefings
POST   /api/v1/candidates/:id/briefings
GET    /api/v1/candidates/:id/match-scores
POST   /api/v1/candidates/:id/merge
POST   /api/v1/candidates/:id/anonymize
GET    /api/v1/candidates/:id/export
POST   /api/v1/candidates/linkedin-import
GET    /api/v1/candidates/:id/linkedin-activities
GET    /api/v1/candidates/:id/briefings/:briefingId/projects
POST   /api/v1/candidates/:id/briefings/:briefingId/projects
PATCH  /api/v1/candidates/:id/briefings/:briefingId/projects/:projectId
POST   /api/v1/candidates/:id/presentations   # v2.5, manuell + Gate-2-Auto
```

### Accounts

```
GET    /api/v1/accounts
POST   /api/v1/accounts
GET    /api/v1/accounts/:id
PATCH  /api/v1/accounts/:id
DELETE /api/v1/accounts/:id
POST   /api/v1/accounts/:id/restore
POST   /api/v1/accounts/:id/merge
GET    /api/v1/accounts/:id/contacts
POST   /api/v1/accounts/:id/contacts
PATCH  /api/v1/accounts/:id/contacts/:contactId
GET    /api/v1/accounts/:id/locations
POST   /api/v1/accounts/:id/locations
PATCH  /api/v1/accounts/:id/locations/:locationId
GET    /api/v1/accounts/:id/aliases
POST   /api/v1/accounts/:id/aliases
GET    /api/v1/accounts/:id/jobs
GET    /api/v1/accounts/:id/vacancies
GET    /api/v1/accounts/:id/organigram
GET    /api/v1/accounts/:id/scrape-changes
GET    /api/v1/accounts/:id/market-events
POST   /api/v1/accounts/:id/scrape
POST   /api/v1/accounts/:id/protection-windows/:wid/file-claim   # v2.5 Kontext X/Y/Z
PATCH  /api/v1/accounts/:id/protection-windows/:wid              # v2.5
POST   /api/v1/accounts/:id/protection-windows/:wid/extend       # v2.5 Phase 2
POST   /api/v1/accounts/:id/group-assign                         # v2.5 rueckwirkende Gruppen-Eintraege
```

### Firmengruppe (v2.5)

```
POST   /api/v1/company-groups/:id/mandate-for-group
```

### Jobs & Vakanzen

```
GET    /api/v1/jobs
POST   /api/v1/jobs
GET    /api/v1/jobs/:id
PATCH  /api/v1/jobs/:id
DELETE /api/v1/jobs/:id
POST   /api/v1/jobs/:id/stage-change
GET    /api/v1/jobs/:id/basket
POST   /api/v1/jobs/:id/basket
PATCH  /api/v1/jobs/:id/basket/:candidateId
GET    /api/v1/jobs/:id/basket/:candidateId/send-options
POST   /api/v1/jobs/:id/basket/:candidateId/send-cv
POST   /api/v1/jobs/:id/basket/:candidateId/send-expose
GET    /api/v1/jobs/:id/matches
PUT    /api/v1/jobs/:id/skills               # DEPRECATED v2.4
PUT    /api/v1/jobs/:id/functions
PUT    /api/v1/jobs/:id/focus
POST   /api/v1/jobs/:id/publish

GET    /api/v1/vacancies
POST   /api/v1/vacancies
GET    /api/v1/vacancies/:id
PATCH  /api/v1/vacancies/:id
POST   /api/v1/vacancies/:id/convert-to-job
```

### Mandate

```
GET    /api/v1/mandates
POST   /api/v1/mandates
GET    /api/v1/mandates/:id
PATCH  /api/v1/mandates/:id
DELETE /api/v1/mandates/:id
POST   /api/v1/mandates/:id/stage-change
GET    /api/v1/mandates/:id/research
POST   /api/v1/mandates/:id/research
PATCH  /api/v1/mandates/:id/research/:candidateId
GET    /api/v1/mandates/:id/billing
POST   /api/v1/mandates/:id/billing
GET    /api/v1/mandates/:id/billing-preview
GET    /api/v1/mandates/:id/processes
GET    /api/v1/mandates/:id/jobs
POST   /api/v1/mandates/:id/terminate             # v2.5 Kuendigungs-TX (AM)
POST   /api/v1/mandates/:id/complete              # v2.5 Abschluss + Schutzfrist
```

### Prozesse

```
GET    /api/v1/processes
POST   /api/v1/processes                          # max 1 offener Prozess pro Kandidat/Job (UNIQUE)
GET    /api/v1/processes/:id
PATCH  /api/v1/processes/:id
POST   /api/v1/processes/:id/stage-change
GET    /api/v1/processes/:id/timeline
GET    /api/v1/processes/:id/events
POST   /api/v1/processes/:id/close
POST   /api/v1/processes/:id/reopen
POST   /api/v1/processes/:id/reject
PATCH  /api/v1/processes/:id/finance
POST   /api/v1/processes/:id/upgrade-to-cv-sent
POST   /api/v1/processes/:id/on-hold              # v2.5
POST   /api/v1/processes/:id/reopen-from-hold     # v2.5
PATCH  /api/v1/processes/:id/stage                # v2.5
POST   /api/v1/processes/:id/set-interview        # v2.5
PATCH  /api/v1/processes/:id/interviews/:iid      # v2.5
POST   /api/v1/processes/:id/interviews/:iid/debriefing   # v2.5
POST   /api/v1/processes/:id/place                # v2.5 ATOMARE TX (8 Steps)
POST   /api/v1/processes/:id/cancel-placement     # v2.5
POST   /api/v1/processes/:id/record-early-exit    # v2.5
POST   /api/v1/processes/:id/create-refund-invoice  # v2.5
POST   /api/v1/processes/:id/create-invoice       # v2.5
POST   /api/v1/processes/bulk-reject-by-mandate-termination   # v2.5
```

### Assessments

```
GET    /api/v1/assessments
GET    /api/v1/assessments/:id
POST   /api/v1/assessments
PATCH  /api/v1/assessments/:id
POST   /api/v1/assessments/:id/complete
POST   /api/v1/assessments/:id/invite
GET    /api/v1/assessments/:candidateId/cross-analysis
POST   /api/v1/assessments/import-scheelen                   # v2.4 CSV-Import mit Dry-Run
POST   /api/v1/assessments/:id/assign-credit                 # v2.5 Typ-Pflicht + Kandidat
POST   /api/v1/assessments/:id/runs/:rid/reassign-candidate  # v2.5 nur innerhalb Typ
PATCH  /api/v1/assessments/:id/runs/:rid/scheduled-date      # v2.5
POST   /api/v1/assessments/:id/runs/:rid/complete            # v2.5 ATOMARE TX Report-Upload
POST   /api/v1/assessments/:id/runs/:rid/cancel              # v2.5
PATCH  /api/v1/assessments/:id/status                        # v2.5
POST   /api/v1/assessments/:id/generate-quote                # v2.5
POST   /api/v1/assessments/:id/billing/create-invoice        # v2.5
POST   /api/v1/assessments/:id/billing/:bid/mark-paid        # v2.5
POST   /api/v1/assessments/:id/billing/add-expense           # v2.5
POST   /api/v1/assessments/:id/credits/rebalance             # v2.5 Founder/Admin-Override
GET    /api/v1/assessments/:id/runs                          # v2.5
```

### History & Aktivitäten

```
GET    /api/v1/history
POST   /api/v1/history                           # Rejection-History → reason Pflicht
GET    /api/v1/history/:id
PATCH  /api/v1/history/:id
GET    /api/v1/activities
POST   /api/v1/activities
PATCH  /api/v1/activities/:id
POST   /api/v1/activities/:id/complete
```

### Reminders (v2.5.5 erweitert · Tool-Maske `/reminders`)

```
GET    /api/v1/reminders               (Query: ?scope=self|team|all &status/type/assignee/entity/range)
POST   /api/v1/reminders
GET    /api/v1/reminders/:id
PATCH  /api/v1/reminders/:id           (inkl. is_done-Undo-Pfad)
POST   /api/v1/reminders/:id/complete
POST   /api/v1/reminders/:id/snooze
POST   /api/v1/reminders/:id/reassign  (v2.5.5 · HoD+/Admin · Event reminder_reassigned)
GET    /api/v1/user-preferences/reminders   (v2.5.5 · Saved-Views + Defaults aus dashboard_config)
PATCH  /api/v1/user-preferences/reminders   (v2.5.5 · Saved-Views CRUD · Scope/View-Prefs · Push-Defaults)
```

### Dokumente

```
POST   /api/v1/documents/upload
GET    /api/v1/documents
GET    /api/v1/documents/:id
PATCH  /api/v1/documents/:id
DELETE /api/v1/documents/:id
GET    /api/v1/documents/:id/download
POST   /api/v1/documents/:id/reparse
GET    /api/v1/documents/:id/ai-suggestions
POST   /api/v1/documents/:id/link-entity
```

### Events & Automationen

```
GET    /api/v1/events
GET    /api/v1/events/:id
POST   /api/v1/events/replay/:id                 # Admin only
GET    /api/v1/event-types
GET    /api/v1/automation-rules
POST   /api/v1/automation-rules
PATCH  /api/v1/automation-rules/:id
POST   /api/v1/automation-rules/:id/enable
POST   /api/v1/automation-rules/:id/disable
POST   /api/v1/automation-rules/:id/reset-circuit-breaker
GET    /api/v1/entities/:type/:id/event-chain    # v2.4 Debuggability
```

### Notifications

```
GET    /api/v1/notifications
PATCH  /api/v1/notifications/:id/read
PATCH  /api/v1/notifications/:id/unread
POST   /api/v1/notifications/test
GET    /api/v1/notification-templates
```

### Emails (v2.4)

```
POST   /api/v1/emails/send
POST   /api/v1/emails/send-with-template
GET    /api/v1/emails/inbox
GET    /api/v1/emails/drafts
POST   /api/v1/emails/drafts
PATCH  /api/v1/emails/drafts/:id
DELETE /api/v1/emails/drafts/:id
GET    /api/v1/email-templates
POST   /api/v1/email-templates
PATCH  /api/v1/email-templates/:id
DELETE /api/v1/email-templates/:id
```

### Provisionen (v2.4)

```
GET    /api/v1/commissions
GET    /api/v1/commissions/summary
GET    /api/v1/commissions/:processId
```

### Automation-Settings (v2.4)

```
GET    /api/v1/automation-settings
PATCH  /api/v1/automation-settings/:key
```

### AI / Suggestions

```
POST   /api/v1/ai/classify
POST   /api/v1/ai/summarize
POST   /api/v1/ai/parse-cv
POST   /api/v1/ai/generate-dossier
GET    /api/v1/ai/suggestions
GET    /api/v1/ai/suggestions/:id
POST   /api/v1/ai/suggestions/:id/accept
POST   /api/v1/ai/suggestions/:id/reject
POST   /api/v1/ai/suggestions/:id/modify
GET    /api/v1/ai/classifications/:entityType/:entityId
GET    /api/v1/ai/policies
```

### RAG / Search

```
POST   /api/v1/rag/query
POST   /api/v1/rag/reindex/:entityType/:entityId
GET    /api/v1/rag/chunks/:entityType/:entityId
GET    /api/v1/search/candidates
GET    /api/v1/search/accounts
GET    /api/v1/search/jobs
GET    /api/v1/search/global
```

### Matching

```
GET    /api/v1/matching/candidate/:candidateId/jobs
GET    /api/v1/matching/job/:jobId/candidates
POST   /api/v1/matching/recalculate/job/:jobId
POST   /api/v1/matching/recalculate/candidate/:candidateId
GET    /api/v1/matching/explain/:matchId
```

### Analytics

```
GET    /api/v1/analytics/pipeline
GET    /api/v1/analytics/revenue
GET    /api/v1/analytics/team-performance
GET    /api/v1/analytics/market
GET    /api/v1/analytics/skills
GET    /api/v1/analytics/goals
GET    /api/v1/analytics/goals/:userId
GET    /api/v1/analytics/export/powerbi/:viewName
```

### Market Intelligence

```
GET    /api/v1/market/accounts/:accountId/changes
GET    /api/v1/market/accounts/:accountId/organigram
GET    /api/v1/market/snapshots
GET    /api/v1/market/competitors
POST   /api/v1/market/rebuild-snapshot
```

### Stammdaten (cached 30 min TTL)

```
GET    /api/v1/stammdaten/clusters
GET    /api/v1/stammdaten/functions
GET    /api/v1/stammdaten/focus
GET    /api/v1/stammdaten/edv
GET    /api/v1/stammdaten/sectors
GET    /api/v1/stammdaten/skills
GET    /api/v1/stammdaten/skills/:id/premium
GET    /api/v1/stammdaten/languages
```

### Integrationen / Webhooks (NICHT unter /api/v1/ — fix registriert)

```
# 3CX A) CRM-Template (X-API-Key)
GET    /api/3cx/lookup
GET    /api/3cx/lookup-email
POST   /api/3cx/report-call

# 3CX B) Webhook (HMAC X-3CX-Secret)
POST   /api/3cx/webhook

# Outlook / Microsoft Graph
GET    /api/outlook/auth/callback                # Azure Redirect URI
POST   /api/v1/integrations/outlook/connect
POST   /api/v1/integrations/outlook/disconnect
POST   /api/v1/integrations/outlook/sync

# Generische Webhooks
POST   /api/v1/webhooks/scraper/change-detected
POST   /api/v1/webhooks/scraper/new-job-detected
POST   /api/v1/webhooks/:webhookId

# Integration Tests
POST   /api/v1/integrations/3cx/test
```

### Scraper (v2.4-Basis)

```
POST   /api/v1/scraper/jobs
GET    /api/v1/scraper/jobs/:jobId
GET    /api/v1/scraper/items
PATCH  /api/v1/scraper/items/:id
```

### Scraper (v2.5, 14)

```
POST   /api/v1/scraper/bulk-run
POST   /api/v1/scraper/runs/:id/rerun
GET    /api/v1/scraper/runs/:id
POST   /api/v1/scraper/findings/:id/accept
POST   /api/v1/scraper/findings/:id/reject
POST   /api/v1/scraper/findings/bulk-accept
GET    /api/v1/scraper/findings/:id/detail
PATCH  /api/v1/scraper/types/:tid/config
POST   /api/v1/scraper/types/:tid/toggle
POST   /api/v1/scraper/alerts/:id/acknowledge
POST   /api/v1/scraper/alerts/:id/dismiss
POST   /api/v1/scraper/anomalies/:id/convert-to-alert
POST   /api/v1/scraper/report
GET    /api/v1/scraper/live                      # WebSocket
```

### Honorar Settings

```
GET    /api/v1/settings/honorar
POST   /api/v1/settings/honorar
PATCH  /api/v1/settings/honorar/:id
DELETE /api/v1/settings/honorar/:id
```

### Projekt + Media (v2.5.1)

```
GET    /api/v1/projects/search                   # Fuzzy (pg_trgm), Debounce-Client
POST   /api/v1/projects/link                     # Werdegang → fact_projects
POST   /api/v1/projects/quick-create             # Mini-Drawer: name/bauherr/from_year/to_year
GET    /api/v1/projects/:id/participations
POST   /api/v1/projects/:id/participations
PATCH  /api/v1/projects/:id/participations/:pid
DELETE /api/v1/projects/:id/participations/:pid
POST   /api/v1/media/upload                      # Unified Multipart, Virus-Scan, returns media_id
```

### CRM AI Assistant

```
POST   /api/v1/assistant/chat
GET    /api/v1/assistant/conversations
DELETE /api/v1/assistant/conversations/:id
```

### Admin

```
GET    /api/v1/admin/users
POST   /api/v1/admin/users
PATCH  /api/v1/admin/users/:id
DELETE /api/v1/admin/users/:id/sessions
GET    /api/v1/admin/audit-log
GET    /api/v1/admin/queue-status
GET    /api/v1/admin/system-status
GET    /api/v1/admin/dead-letters
GET    /api/v1/admin/ai/suggestions
GET    /api/v1/admin/data-quality
POST   /api/v1/admin/data-quality/:id/resolve
GET    /api/v1/admin/data-quality/duplicates
POST   /api/v1/candidates/:id/merge-suggest
GET    /api/v1/admin/integrations/health
GET    /api/v1/admin/circuit-breakers
POST   /api/v1/admin/circuit-breakers/:ruleId/reset
GET    /api/v1/admin/workers/health
GET    /api/v1/admin/tokens/expiry
GET    /api/v1/admin/retention/pending
```

### Bulk-Operations

```
POST   /api/v1/candidates/bulk-import            # CSV/Excel + Preview (?dry_run=true)
POST   /api/v1/candidates/bulk-stage-change
POST   /api/v1/candidates/bulk-archive
POST   /api/v1/candidates/bulk-restore
POST   /api/v1/candidates/bulk-merge-prepare
POST   /api/v1/skills/bulk-assign
POST   /api/v1/scraper/bulk-review
POST   /api/v1/matching/bulk-recalculate
POST   /api/v1/rag/bulk-reindex
```

### Phase-2-Router (reserviert → 501 Not Implemented)

```
/api/v1/time/...
/api/v1/invoicing/...
/api/v1/payroll/...
/api/v1/messaging/...
/api/v1/publishing/...
/api/v1/performance/...
/api/v1/development/...
/api/v1/absences/...
```

---

## Sagas (Namen + Steps)

Alle Sagas: atomic mit Rollback bei Fehler. Step-Interna bewusst weggelassen — siehe Spec-Referenzen in Spalte `Spec`.

### TX1 — Placement (V1-V7, `POST /processes/:id/place`, 8 Steps)

1. Prozess-Update (Stage, Status, placed_at, placed_by)
2. Finance (Fee berechnen, Provisionen, Refund-Modell)
3. Mandat-Billing (bei Target/Taskforce: Stage-Zahlung fällig)
4. Job-Filled (Job-Status → Filled, closed_at)
5. Schutzfrist (protection_window_opened, 12 oder 16 Mt)
6. Referral (falls Referrer gesetzt: payout_due_at)
7. Stellenplan (bei Org-Position: Besetzung)
8. 5 Auto-Reminders (Onboarding, 30/60/90 Tage, Garantie-Closer)

**Failure-Events:** `placement_failed` (Rollback) bei Schutzfrist-Konflikt, mandate_locked, Validation-Fail.

**V1-V7-Prinzip** (siehe Memory `project_v1_v7_placement.md`): zweistufig (Saga + UI-Readiness). Stage-Skip bis Angebot OK, nie direkt zu Platzierung.

Spec: `specs/ARK_PROZESS_DETAILMASKE_INTERACTIONS_v0_1.md` TEIL 4.

### TX2 — Assessment-Report-Upload (`POST /assessments/:id/runs/:rid/complete`, 4 Steps)

1. Version-Insert (fact_assessment_versions, neuer Dokument-Blob)
2. Run completed (fact_assessment_runs.status → completed, report_uploaded_at)
3. credits_used + 1 (fact_assessment_orders)
4. Order-Status (prüfen ob alle Credits verbraucht → order_completed)

Spec: `specs/ARK_ASSESSMENT_DETAILMASKE_INTERACTIONS_v0_2.md` TEIL 5.

### TX3 — Mandat-Kündigung (`POST /mandates/:id/terminate`, 6 Steps)

1. Mandat-Status → `Cancelled` / `Terminated`
2. Rechnung-Calc (pro-rata, open vacancies, Kündigungsgebühr nach AGB)
3. Billing-Insert (fact_mandate_billing — termination_invoice)
4. PDF-Async (PDF-Generator-Worker)
5. Schutzfrist-Opening (für alle exponierten Kandidaten → protection_window_opened)
6. Events (mandate_terminated, termination_invoice_generated + Bulk-Reject-Jobs für offene Prozesse)

**Failure-Event:** `mandate_termination_failed` bei placement_in_progress / Validation-Fail.

Spec: `specs/ARK_MANDAT_DETAILMASKE_INTERACTIONS_v0_3.md` TEIL 9.

### TX4 — Scraper-Finding-Accept (`POST /scraper/findings/:id/accept`, 4 Steps)

1. Finding-Status → `accepted`
2. Entity-Create (Account/Contact/Job/Vacancy je nach Finding-Typ)
3. History-Insert (fact_history — wer akzeptiert, welche Quelle)
4. Duplicate-Check (Anti-Duplicate-Worker-Call, bei Match → merge_suggestion)

Spec: `specs/ARK_SCRAPER_MODUL_INTERACTIONS_v0_1.md` TEIL 3.

### TX5 — Gruppen-Mandat-Create (`POST /company-groups/:id/mandate-for-group`, 3 Steps)

1. Mandat-Insert (fact_mandates mit scope='group')
2. bridge_mandate_accounts (N-Einträge für alle Gruppen-Member)
3. Events (`group_mandate_created` mit Scope=Gruppe + N Accounts)

Spec: `specs/ARK_FIRMENGRUPPE_DETAILMASKE_INTERACTIONS_v0_1.md` TEIL 5.

### TX6 — Gruppen-Member-Add (`POST /accounts/:id/group-assign`, Batch)

1. group_id setzen (fact_accounts.group_id)
2. N Protection-Window-Inserts (rückwirkend für alle existierenden exponierten Kandidaten)

Spec: `specs/ARK_FIRMENGRUPPE_DETAILMASKE_INTERACTIONS_v0_1.md` TEIL 2.

### TX7 — Bulk-Reject-by-Mandate-Termination (`POST /processes/bulk-reject-by-mandate-termination`, Batch)

- N Prozesse → `Rejected` + `process_rejected_due_to_mandate_termination` Events.
- Wird von TX3 (Mandat-Kündigung) getriggert.

Spec: `specs/ARK_MANDAT_DETAILMASKE_INTERACTIONS_v0_3.md` TEIL 9.

### TX8 — Process-Early-Exit + Refund (2 getrennte TX)

- **TX8a** (`POST /processes/:id/record-early-exit`): Status-Change → `EarlyExit`, Event `early_exit_recorded`.
- **TX8b** (`POST /processes/:id/create-refund-invoice`): Refund-Berechnung nach Business-Modell-Matrix (siehe Memory `project_refund_model_routing.md` — Erfolgsbasis=Staffel, Mandat=Ersatz, Time=keine), Event `guarantee_refund_issued`.

Spec: `specs/ARK_PROZESS_DETAILMASKE_INTERACTIONS_v0_1.md` TEIL 7.

---

## WebSocket Channels

Endpoint: `WSS /ws/tenant/:tenantId/live` (Auth via JWT Query-Param oder Header).

Topic-basiert (subscribe):

- `scraper:dashboard` — Live Scraper-Run-Status (Latenz < 2s)
- `scraper:review-queue` — Live Review-Queue (< 2s)
- `assessment:order:{id}` — Snapshot-Bar pro Assessment-Order (< 1s)
- `matching:job:{id}` — Matching-Status pro Job (< 5s)

Implementation: Phase 1 In-Memory Pub/Sub (Single-Instance) → Phase 2 Redis Pub/Sub (Multi-Instance). `websocket-publisher.worker.ts` hält Client-Connections.

---

## dim_automation_settings Keys

Die verbindliche lossless-Liste steht in `raw/Ark_CRM_v2/ARK_STAMMDATEN_EXPORT_v1_3.md` §66 (Referenz im Backend-Doc). Zitat aus §H:

> "Siehe Stammdaten v1.3 Sektion 66. Admin-UI für alle 20+ neuen Keys in Frontend v1.10."

**Konkret erwähnte Keys im Backend-Doc:**

- `concurrent_run_limit` (aus `dim_scraper_global_settings`, Default 10)
- `rate_limit_per_hour` (aus `dim_scraper_types`, pro Scraper-Typ)

**Pauschal erwähnt** (v2.4): "Alle Fristen konfigurierbar über dim_automation_settings" — betrifft u.a.

- Schutzfrist-Default (12 Mt / 16 Mt)
- Garantie-Frist (3 Mt post-Placement)
- Stale-Schwelle pro Prozess-Stage
- Protection-Auto-Extend Trigger (Tage ohne Info-Antwort)
- 30/60/90-Tage-Check-In Defaults
- Candidate-Temperature Schwellen (Hot/Warm/Cold)
- Finding-Review-SLA (14d für needs_am_review)
- Billing-Overdue Tage
- Matching-Recompute Intervall

**→ Volle Key-Liste pflegt §66 der Stammdaten-Grundlagendatei.**

---

## §L. Dok-Generator-Endpoints (NEU v2.5.4, 2026-04-17)

Globaler Dok-Generator `/operations/dok-generator` ersetzt verstreute CTAs in Entity-Detailmasken durch zentrale Workflow-Engine.

### §L.1 Template-Registry (2 Endpoints)

```
GET  /api/v1/document-templates                          → Liste (filter ?category, ?target_entity_type)
       response: [{ key, display_name, category, kinds, is_active, ... }]

GET  /api/v1/document-templates/:key                     → Template-Details
       response: { ...full template with placeholders_jsonb, editor_schema_jsonb }
```

### §L.2 Document Generation — Master-Endpoint (4 Endpoints)

```
POST /api/v1/documents/generate                          → Master-Generate-Call
  body:
    template_key: 'mandat_offerte_target'
    entity_refs: [{ type: 'mandate', id: 'uuid' }]
    params: { sprache: 'de', empfaenger_anrede: 'Herr', zahlungsfrist_tage: 30 }
    overrides: { 'section.custom_paragraph': 'freier Text …' }
    delivery: 'save_only' | 'save_and_email' | 'save_and_download'
    email_options: { recipient_contact_id, subject, email_template_key } (bei email)
  response:
    { document_id, pdf_signed_url, action_result: 'saved' | 'saved_and_sent' }

POST /api/v1/documents/resolve-placeholders              → Live-Canvas-Render
  body: { template_key, entity_refs }
  response: { placeholders: { "x.y": "value", ... }, missing_required: [...] }

POST /api/v1/documents/:id/regenerate                    → Neue Version bei Template-Update
  body: { new_template_version?, params_overrides? }
  response: { document_id, pdf_signed_url }

POST /api/v1/documents/:id/email                         → Nachträglicher Email-Versand
  body: { recipient_contact_id, subject, email_template_key }
  response: { email_id, status: 'sent' }
```

### §L.3 Recent / Drafts (3 Endpoints)

```
GET  /api/v1/document-generator/recent                   → Sidebar "Zuletzt"
       query: ?limit=5&user_id=current
       response: [{ doc_id, display_name, entity_label, created_at, actor }]

GET  /api/v1/document-generator/drafts                   → Phase 2
       query: ?user_id=current
       response: [{ draft_id, template_key, entity_refs, params, updated_at }]

POST /api/v1/document-generator/drafts                   → Phase 2 Auto-Save
       body: { template_key, entity_refs, params, editor_state }
       response: { draft_id }
```

### §L.4 Wrapper-Mapping alter Endpoints

Bestehende punktuelle Endpoints werden zu Wrappern:

| Alter Endpoint | Intern ersetzt durch |
|----------------|---------------------|
| `POST /api/v1/assessments/:id/generate-quote` | `POST /api/v1/documents/generate` mit `template_key='assessment_offerte'` |
| `POST /api/v1/ai/generate-dossier` | `POST /api/v1/documents/generate` mit `template_key='ark_cv'` / `'abstract'` / `'expose'` |

Alte Endpoints bleiben backward-compatible, neue Implementation nutzt Master-Endpoint.

### §L.5 Events (3 neue)

| Event | Scope | Payload |
|-------|-------|---------|
| `document_generated` | Entity (aus entity_refs) + Dokument | `{ doc_id, template_key, params, delivery_mode }` |
| `document_emailed` | Entity + Kontakt | `{ doc_id, recipient_contact_id, email_id, subject }` |
| `document_regenerated` | Entity + Dokument | `{ doc_id, new_version, reason }` |

### §L.6 Validierungs-Regeln

- Template muss existieren + `is_active=true` (sonst 404)
- Entity-Refs müssen Template-Kinds matchen (sonst 400)
- Multi-Entity-Template braucht ≥ 1 Entity je Kind
- Required Params gesetzt (z.B. `sprache`)
- Email-Delivery: `recipient_contact_id` muss zum Entity-Account gehören
- PDF-Render > 10 MB → 413

**Summary §L:** 9 neue Endpoints (2 Registry + 4 Generation + 3 Drafts/Recent) · 3 neue Events · 2 Wrapper-Mappings.

---

## Pointer to full source

Für Details nicht in diesem Digest die Grundlagendatei `Grundlagen MD/ARK_BACKEND_ARCHITECTURE_v2_5.md` konsultieren:

| Thema | §-Section | Zeilen |
|-------|-----------|--------|
| Event-Processor Worker-Interna (LLM-Rate-Limiting, Circuit Breaker) | §10 | 1290-1376 |
| Idempotenz-Keys (Schema + Pseudocode) | §10 Outbox | 1176-1288 |
| Stage-Automatisierungs-Trigger-Matrix | §10b | 1380-1492 |
| Saga-Step-Interna (TX1-TX8) | jeweilige Detailseiten-Specs unter `specs/` | — |
| Request/Response-Body Shapes pro Endpunkt | jeweilige Detailseiten-Specs | — |
| 3CX-Webhook-Payload-Shape + HMAC | §13 | 1964-2025 |
| Outlook-OAuth-Flow + Scopes | §13 | 2027-2073 |
| Zod-Schemas für Event-Payloads | §34 | 2838-2877 |
| AI-Write-Policy-Matrix | §14 | 2093-2136 |
| Matching-Scoring 7 Dimensionen | §14 + §46 | 2129-2135, 3432-3452 |
| ERROR_CODES Katalog | §29 | 2629-2681 |
| Rate-Limit-Tabellen (Global/Auth/AI/Upload) | §17 | 2230-2236 |
| Backpressure-Limits (maxConcurrentAiJobs etc.) | §35 | 2881-2924 |
| SLOs + Alert-Schwellen | §36 | 2928-2965 |
| Graceful Shutdown Code | §48 | 3521-3577 |
| Singleton-Jobs Regeln | §49 | 3580-3621 |
| DB-Pool Konfig + Timeouts | §50 | 3625-3699 |
| Connection-String + Env-Vars | §23 | 2438-2477 |
| Runbooks (6 Incident-Playbooks) | §45 | 3320-3405 |
| Beispiel-Flows End-to-End | §44 | 3270-3316 |
| Field-Level-Permissions (FIELD_PERMISSIONS Map) | §40 | 3087-3147 |
| RequestContext Interface | §41 | 3150-3187 |
| Breaking-Change / Deprecation | §47 | 3464-3517 |
| Dok-Generator-Endpoints (9) + Wrapper + Events | §L | 3722-3806 |

## Related

- [[spec-sync-regel]] — Sync zwischen Grundlagen + 9 Detailspecs
- [[interaction-patterns]] — UI-Interactions (Drawer, Terminologie)
- [[status-enum-katalog]] — Alle Status-Enums
- `wiki/concepts/algorithms.md` — Fuzzy-Match / Honorar-Logik
- `wiki/analyses/audit-2026-04-13-komplett.md` — Audit der 14 Entscheidungen 2026-04-14
