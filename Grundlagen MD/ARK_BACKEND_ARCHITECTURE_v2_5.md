# ARK Backend Architecture – v2.5

**Stand:** 2026-04-14
**System:** Greenfield – modularer Monolith mit Event Spine
**Status:** Review-Reif (Ergänzung v2.4)
**Referenz-DB:** ARK_DATABASE_SCHEMA_v1.3 (189+ Tabellen inkl. 28 neue)
**Vorgänger:** v2.4 (2026-03-30)

## Änderungen v2.4 → v2.5

Resultiert aus Komplett-Audit (`wiki/analyses/audit-2026-04-13-komplett.md`) + 14 Entscheidungen 2026-04-14. **Ergänzung** zu v2.4 — bestehende Endpunkte/Events/Worker bleiben gültig.

### Zusammenfassung

| Bereich | Neu in v2.5 |
|---------|-------------|
| **Events** | 30+ neue Event-Typen (mandate_terminated, assessment_*, protection_window_*, scraper_*, claim_*, ...) |
| **Worker** | 18 neue Async-Worker (Stale-Detection, Billing-Overdue, Protection-Extend, Scraper-Pipeline, Reminders, ...) |
| **Endpunkte** | 46 neue REST-Endpunkte (Prozess/Assessment/Scraper/Mandat/Account/Firmengruppe) |
| **Transaktionen** | 8 atomare Multi-Step-Sagas (Placement, Report-Upload, Kündigung, ...) |
| **WebSocket** | Neue Infrastruktur für Live-Updates (Scraper-Dashboard, Assessment-Snapshot) |
| **Rate-Limiting** | Token-Bucket pro Scraper-Source + Concurrent-Limits |
| **Settings** | 12+ neue Konfig-Keys in dim_automation_settings |
| **Event-Scope-Registry** | Multi-Entity-Events (placed → 5 Entities) |

---

## A. Neue Event-Typen (30+)

### Mandat-Events (9)

| Event | Scope |
|-------|-------|
| `mandate_terminated` | Mandat + Account |
| `termination_invoice_generated` | Mandat + Account |
| `mandate_completed` | Mandat + Account |
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

### Assessment-Events (13)

`assessment_order_created` · `_order_signed` · `_credit_assigned` (inkl. Typ) · `_credit_reassigned_away` · `_credit_reassigned_to` · `_run_scheduled` · `_run_completed` · `_run_cancelled` · `_version_created` · `_order_cancelled` · `_invoice_generated` · `_invoice_paid` · `order_credits_rebalanced_by_founder`

### Prozess-Events (11)

`process_created` · `stale_detected` · `interview_scheduled` · `_rescheduled` · `coaching_added` · `debriefing_added` · `placed` (5 Entities!) · `placement_cancelled` · `early_exit_recorded` · `guarantee_refund_issued` · `process_closed`

### Job-Events (8)

`job_created_manual` · `_from_scraper` · `_from_mandate` · `_from_org_position` · `scraper_proposal_confirmed/rejected` · `job_filled` · `job_closed` · `job_disappeared_from_source` · `matching_recomputed`

### Scraper-Events (12)

`scraper_run_started/finished/failed/retried` · `finding_detected/accepted/rejected/marked_low_confidence` · `config_changed` · `alert_raised/acknowledged/dismissed` · `auto_disable_triggered` · `anomaly_detected`

### Firmengruppen-Events (6)

`group_created_manual/suggested_by_scraper/confirmed/rejected` · `group_member_added/removed` · `group_culture_generated` · `group_framework_contract_added` · `group_protection_window_opened`

### Projekt-Events (8)

`project_created_manual/from_candidate_werdegang/from_scraper` · `bkp_gewerk_added/removed` · `company_participation_added/changed/removed` · `candidate_participation_added/changed/removed` · `media_uploaded` · `account_project_note_added/updated` · `classification_changed`

### Nachtrag v2.5.1 (Audit 2026-04-14) — Saga-Failure + Batch-Events (6)

| Event | Scope | Trigger |
|-------|-------|---------|
| `placement_failed` | Prozess | TX1 Rollback (Schutzfrist-Konflikt, mandate_locked, Validation-Fail) |
| `mandate_termination_failed` | Mandat | TX3 Rollback (placement_in_progress, Validation-Fail) |
| `reminder_batch_created` | Kandidat+Account | Nach Step 7 in TX1 (5 Auto-Reminders) |
| `interview_completed` | Prozess+Kandidat | Nach Debriefing gesetzt, Outcome=Continue |
| `finding_expired_unreviewed` | Scraper-Finding | Nach 14d in needs_am_review-Queue (P1.5 SLA) |
| `legal_hold_toggled` | Audit-Log | Admin setzt/hebt Legal-Hold (siehe [[audit-log-retention]]) |

### Nachtrag v2.5.5 (2026-04-17) — Reminders-Vollansicht-Events (2)

| Event | Scope | Trigger |
|-------|-------|---------|
| `reminder_reassigned` | Reminder + both Mitarbeiter | `POST /api/v1/reminders/:id/reassign` — HoD+/Admin reassigned Reminder zu anderem Mitarbeiter. Payload: `{reminder_id, old_assignee_id, new_assignee_id, reassigned_by}`. Trigger Notification an `new_assignee_id`. |
| `reminder_overdue_escalation` | Reminder + Zuständiger + Head of | Worker `reminder-overdue-escalation.worker.ts` bei 48 h überfällig. Payload: `{reminder_id, overdue_hours, escalated_to, notification_sent}`. Einmalig pro Reminder (Idempotent via `escalation_sent_at`-Flag). |

**Hinweis zu CRUD-Events:** Events wie `description_updated`, `contact_changed`, `internal_notes_updated`, sowie Reminder-Lifecycle (`created`/`completed`/`snoozed`/`updated`) werden **nicht** als dedizierte Event-Typen geführt — sie sind durch `fact_audit_log` mit generischem `entity_updated` + Field-Diff abgedeckt.

---

## B. Neue Worker (18)

### Nightly-Batch-Worker (8)

| Worker | Cron | Zweck |
|--------|------|-------|
| `stale-detection.worker.ts` | 03:00 | Prozesse `Open` mit überschrittenem Stage-Alter → `Stale` |
| `assessment-billing-overdue.worker.ts` | 02:00 | Rechnungen nach Zahlungsziel → `overdue` |
| `process-guarantee-closer.worker.ts` | 01:00 | Prozesse nach Garantiefrist → `closed` |
| `protection-window-auto-extend.worker.ts` | 02:00 | Schutzfrist 12 → 16 Monate bei fehlender Info-Antwort |
| `candidate-temperature-scorer.worker.ts` | 00:00+12:00 | Kandidat-Temperature (Hot/Warm/Cold) |
| `account-temperature-scorer.worker.ts` | 00:00+12:00 | Account-Temperature |
| `matching-daily-batch.worker.ts` | 04:00 | Matching-Recompute alle aktiven Jobs + Projekte |
| `reminder-overdue-escalation.worker.ts` | hourly 08–20h | NEU 2026-04-17: 48-h-überfällige Reminders → `reminder_overdue_escalation` Event + Notification an Head of (`dim_mitarbeiter.vorgesetzter_id`). Idempotent via `fact_reminders.escalation_sent_at` (neu). 24-h-Schwelle erzeugt Push an Zuständigen direkt (ohne Event). |

### Event-getriebene Worker (6)

| Worker | Trigger | Zweck |
|--------|---------|-------|
| `process-auto-reminder.worker.ts` | `placed` | 5 Auto-Reminders (Onboarding, 30/60/90, Garantie) |
| `matching-recompute.worker.ts` | Skill/Stage/Doc-Change | Async Score-Recompute |
| `referral-payout-trigger.worker.ts` | `placed` | Referral-Check + `payout_due_at` setzen |
| `process-interview-coaching-reminder.worker.ts` | `interview_scheduled` | Reminder 2d vor Termin |
| `process-interview-debriefing-reminder.worker.ts` | `interview_scheduled` | Reminder am Termin-Tag |
| `scraper-finding-processor.worker.ts` | `finding_detected` | Duplicate + Confidence + `review_priority` + Staging |

### Scraper-Worker (3)

| Worker | Trigger | Zweck |
|--------|---------|-------|
| `scraper-batch-job.worker.ts` | Cron + Manual | Priority-Queue Scraper-Runs |
| `scraper-auto-disable.worker.ts` | N-Strike | Auto-Disable + Critical Alert |
| `scraper-antiduplicate.worker.ts` | Pre-Insert | Duplicate-Detection pro Typ |

### Datenqualität & System (2)

| Worker | Zweck |
|--------|-------|
| `stammdaten-drift-detection.worker.ts` | Periodisch website_url/employee_count/founded_year checken |
| `websocket-publisher.worker.ts` | Event-Publishing an WebSocket-Clients |

### Nachtrag v2.5.1 (Audit 2026-04-14) — Workflow-Worker (4)

| Worker | Trigger | Zweck |
|--------|---------|-------|
| `shortlist-trigger-payment.worker.ts` | `process.stage_changed → shortlist` | Bei Target-Mandat: Stage-1-Zahlung fällig setzen (`fact_mandate_billing`) |
| `outlook-calendar-sync.worker.ts` | `interview_scheduled/_rescheduled` + Cron 15min | Bidirektional MS Graph API: ARK ↔ Outlook-Kalender (CM als Organizer) |
| `stale-notification.worker.ts` | Cron 09:00 | Reminder an AM für `process.status='Stale'` (48h/7d-Eskalation) |
| `process-closed-archiving.worker.ts` | `process_closed` + 30d Delay | Prozess-Payload in `archive.processes` verschieben, UI Read-Only |

---

## C. Neue Endpunkte (46)

Hochzusammenfassung (vollständige Flow-Details in jeweiligen Detailseiten-Specs):

### Mandat (2)

```
POST /api/v1/mandates/:id/terminate              (Kündigungs-TX, AM)
POST /api/v1/mandates/:id/complete               (Abschluss + Schutzfrist)
```

### Prozess (13)

```
POST  /api/v1/processes/:id/on-hold              POST  /api/v1/processes/:id/reopen-from-hold
PATCH /api/v1/processes/:id/stage                POST  /api/v1/processes/:id/set-interview
PATCH /api/v1/processes/:id/interviews/:iid      POST  /api/v1/processes/:id/interviews/:iid/debriefing
POST  /api/v1/processes/:id/place                (ATOMARE TX, 8 Steps)
POST  /api/v1/processes/:id/cancel-placement     POST  /api/v1/processes/:id/record-early-exit
POST  /api/v1/processes/:id/create-refund-invoice POST /api/v1/processes/:id/create-invoice
PATCH /api/v1/processes/:id/finance              GET   /api/v1/processes/:id/timeline
POST  /api/v1/processes/bulk-reject-by-mandate-termination
```

### Assessment (11)

```
POST  /api/v1/assessments/:id/assign-credit       (Typ-Pflicht + Kandidat)
POST  /api/v1/assessments/:id/runs/:rid/reassign-candidate  (nur innerhalb Typ)
PATCH /api/v1/assessments/:id/runs/:rid/scheduled-date
POST  /api/v1/assessments/:id/runs/:rid/complete  (ATOMARE TX, Report-Upload)
POST  /api/v1/assessments/:id/runs/:rid/cancel
PATCH /api/v1/assessments/:id/status
POST  /api/v1/assessments/:id/generate-quote
POST  /api/v1/assessments/:id/billing/create-invoice
POST  /api/v1/assessments/:id/billing/:bid/mark-paid
POST  /api/v1/assessments/:id/billing/add-expense
POST  /api/v1/assessments/:id/credits/rebalance   (Founder/Admin-Override)
GET   /api/v1/assessments/:id/runs
```

### Account / Schutzfristen (3)

```
POST  /api/v1/accounts/:id/protection-windows/:wid/file-claim   (Kontext X/Y/Z)
PATCH /api/v1/accounts/:id/protection-windows/:wid
POST  /api/v1/accounts/:id/protection-windows/:wid/extend       (Phase 2)
```

### Firmengruppe (2)

```
POST  /api/v1/company-groups/:id/mandate-for-group
POST  /api/v1/accounts/:id/group-assign           (rückwirkende Schutzfrist-Gruppen-Einträge)
```

### Scraper (14)

```
POST  /api/v1/scraper/bulk-run                    POST /api/v1/scraper/runs/:id/rerun
GET   /api/v1/scraper/runs/:id                    POST /api/v1/scraper/findings/:id/accept
POST  /api/v1/scraper/findings/:id/reject         POST /api/v1/scraper/findings/bulk-accept
GET   /api/v1/scraper/findings/:id/detail         PATCH /api/v1/scraper/types/:tid/config
POST  /api/v1/scraper/types/:tid/toggle           POST /api/v1/scraper/alerts/:id/acknowledge
POST  /api/v1/scraper/alerts/:id/dismiss          POST /api/v1/scraper/anomalies/:id/convert-to-alert
POST  /api/v1/scraper/report                      GET /api/v1/scraper/live   (WebSocket)
```

### Kandidat (1)

```
POST  /api/v1/candidates/:id/presentations        (manuell + Gate-2-Auto)
```

### Nachtrag v2.5.2 (2026-04-14) — User-Preferences (2)

```
GET   /api/v1/me/preferences                     (theme_preference + weitere)
PATCH /api/v1/me/preferences                     (theme_preference: 'dark'|'light'|'system')
```

DB-Erweiterung: `dim_crm_users + theme_preference ENUM('dark','light','system') DEFAULT 'dark'`.

### Nachtrag v2.5.1 (Audit 2026-04-14) — Projekt + Media (6)

```
GET   /api/v1/projects/search?q=                 (Fuzzy-Match, pg_trgm, Debounce-Client)
POST  /api/v1/projects/link                      (Werdegang-Eintrag → fact_projects, Bridge-Insert)
POST  /api/v1/projects/quick-create              (Mini-Drawer: name, bauherr, from_year, to_year)
GET   /api/v1/projects/:id/participations        POST /api/v1/projects/:id/participations
PATCH /api/v1/projects/:id/participations/:pid   DELETE /api/v1/projects/:id/participations/:pid
POST  /api/v1/media/upload                       (unified Multipart, Virus-Scan, Returns media_id)
```

Fuzzy/UID/Honorar-Logik: siehe `wiki/concepts/algorithms.md`.

---

## D. Atomare Transaktionen / Sagas (8)

| # | Saga | Sub-Steps | Spec |
|---|------|-----------|------|
| TX1 | Placement | 8 (Prozess+Finance+Mandat-Billing+Job-Filled+Schutzfrist+Referral+Stellenplan+5 Reminders) | Prozess-Interactions TEIL 4 |
| TX2 | Assessment-Report-Upload | 4 (Version-Insert + Run+completed + credits_used+1 + Order-Status) | Assessment-Interactions TEIL 5 |
| TX3 | Mandat-Kündigung | 6 (Status+Rechnung-Calc+Billing-Insert+PDF-Async+Schutzfrist-Opening+Events) | Mandat-Interactions TEIL 9 |
| TX4 | Scraper-Finding-Accept | 4 (Finding+accepted + Entity-Create + History + Duplicate-Check) | Scraper-Interactions TEIL 3 |
| TX5 | Gruppen-Mandat-Create | 3 (Mandat+bridge_mandate_accounts+Events) | Firmengruppe-Interactions TEIL 5 |
| TX6 | Gruppen-Member-Add | Batch: group_id + N Protection-Window-Inserts | Firmengruppe-Interactions TEIL 2 |
| TX7 | Bulk-Reject-by-Mandate-Termination | Batch: N Prozesse → Rejected + Events | Mandat-Interactions TEIL 9 |
| TX8 | Process-Early-Exit + Refund | 2 getrennte TX | Prozess-Interactions TEIL 7 |

Alle mit Rollback bei Fehler. Pseudocode in jeweiliger Spec.

---

## E. WebSocket-Infrastruktur (NEU)

### Endpoint

```
WSS /ws/tenant/:tenantId/live
Auth: JWT via Query-Param oder Header
```

### Subscription-Model

Topic-basiert: `scraper:dashboard`, `scraper:review-queue`, `assessment:order:{id}`, `matching:job:{id}`.

### Use Cases + Latenz-Ziele

| View | Topic | Latenz |
|------|-------|--------|
| Scraper-Dashboard | `scraper:dashboard` | < 2s |
| Scraper-Review-Queue | `scraper:review-queue` | < 2s |
| Assessment-Snapshot-Bar | `assessment:order:{id}` | < 1s |
| Job-Matching-Status | `matching:job:{id}` | < 5s |

### Implementation

- Phase 1: In-Memory Pub/Sub (Single-Instance)
- Phase 2: Redis Pub/Sub (Multi-Instance)
- WebSocket-Publisher-Worker hält Client-Connections, routet Events

---

## F. Scraper-Rate-Limiting (NEU)

### Token-Bucket

Pro Kombination `(scraper_type, target_domain)` ein Bucket. Rate aus `dim_scraper_types.rate_limit_per_hour`.

### Concurrent-Run-Limit

Global pro Tenant: `dim_scraper_global_settings.concurrent_run_limit` (Default 10). PgBoss-Queue mit Capacity-Gate.

### Alerts

- Soft bei > 50% Verbrauch/h → `rate_limit_reached` Alert
- Hard bei leerem Bucket → Run `partial` mit Retry

### Module

```
/src/modules/rate-limit/
  token-bucket.ts
  scraper-limiter.ts
  concurrent-gate.ts
```

---

## G. Event-Scope-Registry (Multi-Entity-Events)

```typescript
// /src/events/scope-registry.ts
export const EVENT_SCOPE_RULES: Record<EventType, ScopeResolver> = {
  'placed': async (event) => {
    const p = await loadProcess(event.entity_id)
    return {
      candidates: [p.candidate_id],
      accounts: [p.account_id],
      jobs: [p.job_id],
      processes: [p.id],
      mandates: p.mandate_id ? [p.mandate_id] : []
    }
  },
  // ... 30+ weitere Events
}
```

Event-Processor nutzt Registry für Multi-Entity-Audit-Log-Writes.

---

## H. Neue Konfig-Keys in dim_automation_settings

Siehe Stammdaten v1.3 Sektion 66. Admin-UI für alle 20+ neuen Keys in Frontend v1.10.

---

## I. Priority-Roadmap v2.5-Implementierung

**P0 Blocker (3-4 Wochen parallel):**
- 10 P0-Events + 7 P0-Worker + 24 P0-Endpunkte
- 8 Atomic Transactions
- WebSocket-Infrastruktur (Scraper + Assessment)
- Scraper-Rate-Limiting

**P1 (1-2 Wochen):**
- 14 P1-Events + 10 P1-Worker + 18 P1-Endpunkte
- Event-Scope-Registry
- 12 Setting-Keys Admin-UI

**P2 (Phase 1.5):**
- Auto-Accept-Thresholds, Prompt-Tuning, Kalender-Sync, Stammdaten-Drift

---

## J. Detailseiten-Spec-Referenzen

| Bereich | Spec |
|---------|------|
| Mandat-Kündigung | `specs/ARK_MANDAT_DETAILMASKE_INTERACTIONS_v0_3.md` TEIL 9 |
| Prozess-Placement-TX | `specs/ARK_PROZESS_DETAILMASKE_INTERACTIONS_v0_1.md` TEIL 4 |
| Assessment-TX | `specs/ARK_ASSESSMENT_DETAILMASKE_INTERACTIONS_v0_2.md` TEIL 3+5 |
| Scraper-Pipeline | `specs/ARK_SCRAPER_MODUL_INTERACTIONS_v0_1.md` (gesamt) |
| Protection-Claim | `specs/ARK_ACCOUNT_DETAILMASKE_INTERACTIONS_v0_3.md` TEIL 8c |
| Firmengruppen-Mandat | `specs/ARK_FIRMENGRUPPE_DETAILMASKE_INTERACTIONS_v0_1.md` TEIL 5 |
| Projekt-Matching | `specs/ARK_PROJEKT_DETAILMASKE_INTERACTIONS_v0_1.md` TEIL 4+9 |
| Enum-Konventionen | `wiki/concepts/status-enum-katalog.md` |
| DB-Tabellen | `ARK_DATABASE_SCHEMA_v1_3.md` |
| Stammdaten | `ARK_STAMMDATEN_EXPORT_v1_3.md` |

---

# Original v2.4 (unverändert übernommen als Referenz)

# ARK Backend Architecture – Freeze v2.4 (konsolidiert)

**Stand:** 2026-03-30
**System:** Greenfield – modularer Monolith mit Event Spine
**Status:** EINGEFROREN – verbindliche Basis für alle Backend-Entwicklung
**Referenz-DB:** ARK_DATABASE_SCHEMA_v1.2 (~161 Tabellen + 4 Views, 10 deprecated)
**Reviews eingearbeitet:** ChatGPT · Perplexity · Manus AI · Claude (Anthropic) · Gesamtsystem-Review v1.2
**Änderungen v2.3 → v2.4:**
- Wechselmotivation (8 Stufen) auf Kandidaten-Profil, availability_date entfernt
- Prelead ersetzt Lead im Jobbasket, differenzierte Rejection (candidate/cm/am)
- Mandats-Status: Entwurf/Aktiv/Abgelehnt/Completed/Cancelled, Offerten-Conversion-Rate KPI
- Prozess-Status: Open/On Hold/Rejected/Placed/Cancelled (Cancelled = Rückzieher nach Placement)
- Erfolgsbasis-Prozesse (ohne Mandat) mit Best-Effort-Staffel
- Skills deprecated → Focus bildet Skills ab
- Email-System: neue Endpunkte (send, drafts, inbox)
- Assessment CSV-Import Endpunkt
- Activity-Types: 11 Kategorien, categorization_status um 'pending' erweitert
- fact_history: activity_type Text-Feld entfernt
- AGB-Tracking auf Accounts (agb_confirmed_at, agb_version)
- Max Upload 20 MB (statt 25 MB)
- Alle Fristen konfigurierbar über dim_automation_settings



## 0. ABSOLUT VERBINDLICHE GRUNDREGELN

```
REGEL 1   tenant_id kommt NUR aus JWT – niemals aus Request-Body oder Query-Params
REGEL 2   Business Write + Event Insert = immer eine Transaktion
REGEL 3   AI schreibt nie direkt in operative Tabellen
REGEL 4   Kein Hard Delete – immer Soft Delete
REGEL 5   Niemals interne Fehler, Stack Traces oder DB-Schema an Client
REGEL 6   PII-Felder in Logs maskieren (Namen, Email, Telefon, Lohn)
REGEL 7   Rate Limiting auf allen Endpunkten – AI-Endpunkte besonders streng
REGEL 8   Audit Log bei jeder Zustandsänderung, jedem Login, jedem Fehler
REGEL 9   API-Versionierung /api/v1/ ab Tag 1 – keine Ausnahme
REGEL 10  SELECT nur benötigte Felder – kein SELECT * in Production
```

---

## 1. ZIELBILD

Das Backend ist nicht einfach eine REST API – es ist gleichzeitig:

1. **Transaktionsschicht** zwischen Frontend und Datenbank
2. **Security Layer** für JWT, Rollen, Tenant Isolation und RLS
3. **Orchestrator** für Events, Automationen und Worker Jobs
4. **Integrationslayer** für 3CX, Outlook, Scraper, Webhooks, LLM-Anbieter
5. **Governance Layer** für AI, Dokumente, Audit, Datenschutz und PII
6. **Analytics Layer** für Power BI, Reporting, Snapshots, Materialized Views
7. **Domain Layer** für Kandidaten, Accounts, Jobs, Mandate, Prozesse, Skills
8. **Phase-2-Träger** für Billing, Zeit, HR, Payroll, Publishing

**Architekturprinzip: Modularer Monolith mit Event Spine**

- ein gemeinsames Backend-Projekt, klar getrennte Module
- gemeinsame Auth, Logging, Validation, Error Handling, DB und Queue Infrastruktur
- keine verteilten Microservices in Phase 1 (wäre Overengineering)
- alle Seiteneffekte laufen über Event Queue und Worker
- Integrationen sind Adapter – nicht Kernlogik

---

## 2. TECH STACK

```
Runtime:       Node.js (LTS)
Framework:     Fastify (bevorzugt) oder Express
Language:      TypeScript (strict: true)
DB:            Supabase PostgreSQL – nur ark Schema, kein public
Queue:         PgBoss (PostgreSQL-basiert, kein Redis nötig in Phase 1)
Hosting:       Railway (API + Worker als getrennte Services)
Logging:       Pino (strukturiertes JSON-Logging)
Validation:    Zod (Single Source of Truth für Input-Typen)
Security:      Helmet.js + @fastify/rate-limit
Auth:          JWT (eigene Implementierung auf dim_crm_users)
               Backend ist primäre Enforcement-Schicht (Service Role Key)
               RLS nur zweite Linie für direkte DB-Zugriffe (Power BI, Admin-Tools)
Monitoring:    Sentry (Error) + Railway Metrics
Testing:       Vitest + Supertest
```

**Warum Fastify statt Express:**
Bessere Performance unter Last, gute TypeScript-Integration, saubere Plugin-Struktur. Express ist möglich, Fastify ist die bessere Wahl für ein sauberes Backend-Backbone.

---

## 3. SCHICHTENMODELL (6 Schichten)

```
Schicht 1: API Layer
  Verantwortung: HTTP Parsing, Auth Middleware, Rollenprüfung, Request Validation,
  Response Mapping, Fehlercodes. KEINE Business Logic.

Schicht 2: Application Services
  Verantwortung: fachliche Use Cases, Transaktionsgrenzen, Event Erzeugung,
  Policy-Prüfungen, Zusammenspiel mehrerer Repositories.
  Beispiele: changeCandidateStage() · uploadDocument() · acceptAiSuggestion()
             createProcessFromJobbasket() · handleIncoming3cxCall()

Schicht 3: Domain / Policy Layer
  Verantwortung: Statusmaschinen, erlaubte Übergänge, Matching-Regeln,
  Sichtbarkeitsregeln, AI-Write-Policies, Automation-Rule-Evaluation.

Schicht 4: Repository Layer
  Verantwortung: DB-Zugriff, tenant-sichere Queries, keine Business-Entscheidungen,
  selektive Feldwahl, optimierte Listen und Detailabfragen.

Schicht 5: Worker Layer
  Verantwortung: asynchrone Verarbeitung, Event Queue Konsum, Retry Handling,
  API Calls gegen Drittanbieter, AI Jobs, E-Mail-Versand, Scraper.

Schicht 6: Integration Adapter Layer
  Verantwortung: 3CX Adapter, Outlook Adapter, LLM Provider Adapter, Scraper Adapter,
  Notification Adapter, später Social und Messaging Adapter.
  WICHTIG: Provider-Details NICHT im Kern verteilt – immer über Adapter-Services.
```

---

## 4. ORDNERSTRUKTUR (FINAL)

```
ark-backend/
├── src/
│   ├── app/
│   │   ├── server.ts              ← Fastify/Express Setup
│   │   ├── app.ts                 ← App mit Plugins, Middleware
│   │   └── routes.ts              ← Alle Route-Registrierungen
│   │
│   ├── api/
│   │   └── v1/
│   │       ├── auth/
│   │       ├── users/
│   │       ├── candidates/
│   │       ├── accounts/
│   │       ├── account-contacts/
│   │       ├── jobs/
│   │       ├── vacancies/
│   │       ├── mandates/
│   │       ├── processes/
│   │       ├── history/
│   │       ├── activities/
│   │       ├── documents/
│   │       ├── events/
│   │       ├── automations/
│   │       ├── notifications/
│   │       ├── assessments/
│   │       ├── ai/
│   │       ├── rag/
│   │       ├── search/
│   │       ├── matching/
│   │       ├── analytics/
│   │       ├── market-intelligence/
│   │       ├── integrations/
│   │       ├── webhooks/
│   │       ├── scraper/
│   │       └── admin/
│   │
│   ├── modules/                   ← Business Logic pro Domäne
│   │   ├── auth/
│   │   ├── users/
│   │   ├── candidates/
│   │   ├── accounts/
│   │   ├── jobs/
│   │   ├── mandates/
│   │   ├── processes/
│   │   ├── history/
│   │   ├── documents/
│   │   ├── events/
│   │   ├── automations/
│   │   ├── notifications/
│   │   ├── assessments/
│   │   ├── ai/
│   │   ├── rag/
│   │   ├── matching/
│   │   ├── search/
│   │   ├── analytics/
│   │   ├── market-intelligence/
│   │   ├── integrations/
│   │   └── shared/
│   │
│   ├── workers/
│   │   ├── index.ts               ← Worker Entry Point (separater Railway Service)
│   │   ├── event-processor.worker.ts   ← DER wichtigste Worker
│   │   ├── email.worker.ts
│   │   ├── ai.worker.ts           ← Klassifikation, Summary, Parsing, Dossier
│   │   ├── embedding.worker.ts    ← Chunking + pgvector Embeddings
│   │   ├── reminder.worker.ts
│   │   ├── notification.worker.ts
│   │   ├── threecx.worker.ts
│   │   ├── outlook.worker.ts
│   │   ├── scraper.worker.ts
│   │   ├── document.worker.ts     ← OCR, Parsing, Embedding-Pipeline
│   │   ├── webhook.worker.ts
│   │   ├── retention.worker.ts    ← PII-Retention, Anonymisierung
│   │   └── analytics.worker.ts    ← Materialized View Refresh, Snapshots
│   │
│   ├── policies/                  ← Domain-Policies (Statusmaschinen, AI-Grenzen)
│   │   ├── candidate-stage.policy.ts
│   │   ├── process-stage.policy.ts
│   │   ├── mandate-stage.policy.ts
│   │   ├── job-stage.policy.ts
│   │   ├── ai-write.policy.ts
│   │   ├── visibility.policy.ts
│   │   └── retention.policy.ts
│   │
│   ├── adapters/                  ← Integration Adapter (Provider-Abstraktion)
│   │   ├── llm/
│   │   │   ├── openai.adapter.ts
│   │   │   └── anthropic.adapter.ts
│   │   ├── email/
│   │   ├── threecx/
│   │   ├── outlook/
│   │   ├── scraper/
│   │   ├── notifications/
│   │   └── publishing/
│   │
│   ├── middleware/
│   │   ├── auth.middleware.ts
│   │   ├── tenant.middleware.ts
│   │   ├── role.middleware.ts
│   │   ├── requestId.middleware.ts
│   │   ├── rateLimit.middleware.ts
│   │   ├── piiMask.middleware.ts
│   │   ├── audit.middleware.ts
│   │   └── errorHandler.middleware.ts
│   │
│   ├── lib/
│   │   ├── supabase.ts
│   │   ├── pg.ts                  ← Direkter pg-Client für Transaktionen
│   │   ├── transaction.ts         ← withTransaction() Helper
│   │   ├── pgboss.ts
│   │   ├── logger.ts              ← Pino mit PII-Redaction
│   │   ├── cache.ts               ← In-Memory Cache für Stammdaten
│   │   └── sentry.ts
│   │
│   ├── config/
│   │   ├── env.ts                 ← Alle Env-Variablen via Zod validiert
│   │   ├── roles.ts               ← RBAC-Konfiguration
│   │   ├── permissions.ts         ← Endpunkt-Berechtigungen
│   │   └── stageMachines.ts       ← Erlaubte Stage-Übergänge (alle Entitäten)
│   │
│   └── types/
│       ├── index.ts
│       ├── database.types.ts      ← Generiert: supabase gen types typescript
│       └── api.types.ts
│
├── tests/
│   ├── unit/                      ← Policies, Statusmaschinen, Validierung
│   ├── integration/               ← Service Layer gegen Test-DB
│   ├── api/                       ← Endpunkte, Auth, Pagination, Errors
│   └── fixtures/
│
├── .env.example                   ← Keine echten Werte
├── tsconfig.json                  ← strict: true
└── railway.toml
```

---

## 5. API-DESIGN

### Grundprinzipien
```
- REST API, /api/v1/... ab Tag 1 – keine Ausnahme
- Controller nur für HTTP-Handling, keine Business Logic
- Kein direkter DB-Zugriff im Controller
- Whitelist-Filter – kein dynamisches SQL
- Zod-Validierung vor jedem DB-Zugriff
```

### Einheitliche Response-Struktur
```typescript
// Erfolg:
{
  "success": true,
  "data": {},
  "meta": { "requestId": "uuid", "total": 100, "hasNext": true, "nextCursor": "uuid" },
  "error": null
}

// Fehler:
{
  "success": false,
  "data": null,
  "error": { "code": "VALIDATION_ERROR", "message": "...", "fields": {} }
}
```

### HTTP-Statuscodes
```
200  GET / PUT / PATCH erfolgreich
201  POST – neue Ressource erstellt
204  DELETE – Soft Delete
400  Fehlende Pflichtfelder, falsches Format
401  Kein / ungültiger Token
403  Rolle/Permission fehlt
404  Ressource nicht gefunden
409  Duplikat (Email bereits vorhanden)
422  Business-Regel verletzt (ungültiger Stage-Wechsel)
429  Rate Limit überschritten
500  Unbekannter Fehler (kein Detail an Client)
```

### Pagination (Cursor-basiert für grosse Tabellen)
```
GET /api/v1/candidates?limit=25&cursor=uuid&sort=created_at&order=desc
Meta: { total, hasNext, hasPrev, nextCursor, limit }
```

### Anti-Patterns (VERBOTEN)
```
❌ SELECT *
❌ Unlimitierte Listen ohne Pagination
❌ Dynamische Filter ohne Whitelist
❌ tenant_id aus Request übernehmen
❌ Business Logic im Controller
❌ DB-Zugriff im Controller
❌ Provider-Details direkt in Kernlogik
❌ Stack Traces an Client
❌ generische "update any field" Endpunkte
```

---

## 6. AUTHENTICATION & AUTHORIZATION

### JWT-Payload
```typescript
interface JWTPayload {
  userId: string      // dim_crm_users.id
  tenantId: string    // tenants.id
  roles: RoleKey[]    // Alle Rollen des Mitarbeiters (aus bridge_mitarbeiter_roles)
  primaryRole: RoleKey // Primäre Rolle (is_primary_role=true) für Anzeige
  sparteId: string    // dim_sparte.id
  sessionId: string   // für Audit Log
  iat: number
  exp: number
  // NIEMALS: Passwörter, Tokens, PII-Daten
}
// Access Token: 15-60 Min
// Refresh Token: 7-30 Tage, rotierend (Token Rotation bei Refresh)
```

### Auth-Endpunkte
```
POST   /api/v1/auth/login
POST   /api/v1/auth/refresh            ← Token Rotation
POST   /api/v1/auth/logout
GET    /api/v1/auth/me                 ← kein Passwort-Hash zurück!
POST   /api/v1/auth/forgot-password
POST   /api/v1/auth/reset-password
POST   /api/v1/auth/change-password
```

### RBAC (Role-Based Access Control)
```typescript
type RoleKey = 'Admin' | 'Candidate_Manager' | 'Account_Manager' | 'Researcher'
             | 'Head_of' | 'Backoffice' | 'Assessment_Manager' | 'ReadOnly'

// Multi-Rollen: Ein Mitarbeiter kann mehrere Rollen haben
// JWT enthält roles[] Array, nicht eine einzelne Rolle

// Endpunkt-Schutz via Middleware (mindestens eine passende Rolle):
router.post('/candidates', requireAnyRole(['Admin', 'Candidate_Manager']), handler)
router.delete('/candidates/:id', requireAnyRole(['Admin']), handler)

// requireAnyRole Implementation:
const requireAnyRole = (allowed: RoleKey[]) => (req, reply, next) => {
  const userRoles: RoleKey[] = req.jwtPayload.roles
  if (!userRoles.some(r => allowed.includes(r))) {
    throw new ForbiddenError('Keine der benötigten Rollen vorhanden')
  }
  next()
}

// Ressourcen-Level-Check:
// Candidate_Manager sieht nur Kandidaten mit candidate_manager_id = userId
// Admin und Head_of sehen alles
```

### Passwort-Sicherheit
```
- bcrypt min 12 Rounds oder argon2id
- Rate Limit Login: 5 Versuche / 15 Min pro IP
- Account Lock: nach 5 Fehlversuchen → is_locked=true, locked_until=+30min
- failed_login_count in dim_crm_users tracken
- Audit Log: jeder Failed Login
- Reset via forgot-password: Token mit Ablaufzeit, einmalig verwendbar
```

### Refresh Token Härtung (Pflicht)
```typescript
// Refresh Tokens werden NIEMALS im Klartext in der DB gespeichert:
// → hash(refreshToken) speichern, Token selbst an Client
// → UNIQUE Constraint auf token_hash

// JTI (JWT ID) für Access Token Revocation:
interface JWTPayload {
  jti: string      // Unique Token ID → für Blacklist
  userId, tenantId, roles, primaryRole, sparteId, sessionId, iat, exp
}

// Token Blacklist (Phase 1: Postgres, kein Redis):
// Entscheidung: fact_token_revocations in Postgres – kein Redis in Phase 1.
// Begründung: Postgres mit Index auf (jti, expires_at) ist bei ARK-Last völlig ausreichend,
// wartungsärmer als eine zusätzliche Redis-Instanz und konsistent mit dem restlichen Stack.
// Phase 2: Redis nur einführen wenn Revocation-Queries messbar zu Latenz-Problemen führen.
// Bei Logout / Passwortänderung / Account-Sperre:
// → JTI in fact_token_revocations eintragen
// → Middleware prüft bei jedem Request ob JTI auf Blacklist steht

// Token Family Konzept (Reuse Detection):
// Jedes Refresh Token hat eine family_id
// Bei Rotation: altes Token ungültig, neues Token bekommt selbe family_id
// Wenn gestohlenes Token verwendet wird → ganze Familie invalidieren → forced re-login

// Session Management:
// POST /api/v1/auth/sessions            ← alle aktiven Sessions
// DELETE /api/v1/auth/sessions/:id      ← einzelne Session beenden
// DELETE /api/v1/auth/sessions          ← alle Sessions beenden (logout everywhere)
// Admin: DELETE /api/v1/admin/users/:id/sessions  ← forced logout

// REFRESH TOKEN TRANSPORTMODELL (architektonische Entscheidung – Phase 1):
//
// Entscheidung: httpOnly + Secure + SameSite=Strict Cookie für Refresh Token
//
// Begründung:
//   → httpOnly: Refresh Token nie via JavaScript lesbar → XSS-Angriff kann Token nicht stehlen
//   → Secure: nur über HTTPS übertragen (nie im Klartext)
//   → SameSite=Strict: CSRF-Schutz – Browser sendet Cookie nur bei Same-Origin-Requests
//   → Access Token weiterhin im Memory (nicht localStorage!) – kurzlebig (15 Min)
//
// Electron-App Besonderheit:
//   → Electron nutzt eigene Session-Verwaltung (keine Browser-Cookies)
//   → Electron: Refresh Token in electron.safeStorage verschlüsselt auf Disk speichern
//   → Explizit VERBOTEN: Refresh Token in localStorage, sessionStorage oder unkrypt. File
//
// Login-Flow:
//   1. POST /api/v1/auth/login → Response: { accessToken }
//      + Set-Cookie: refreshToken=<token>; HttpOnly; Secure; SameSite=Strict; Path=/api/v1/auth/refresh
//   2. Client speichert accessToken nur im JS-Memory (nicht localStorage)
//   3. Bei Access Token Expiry: POST /api/v1/auth/refresh (Cookie wird automatisch mitgesendet)
//   4. Logout: DELETE Cookie serverseitig + JTI auf Blacklist
//
// CORS-Konsequenz: Allowed Origins MÜSSEN exact match sein (kein Wildcard) damit SameSite greift
```

### RLS vs. Service Role (architektonische Entscheidung)
```
ARK Backend nutzt Variante A:
  → Backend verwendet Supabase Service Role Key
  → Service Role bypassed RLS (das ist bewusst und gewollt)
  → Das Backend selbst ist die primäre und letzte Instanz der Zugriffskontrolle
  → RLS dient als zweite Linie für direkten DB-Zugang (Power BI, Admin-Tools)

Konsequenz:
  → Jede Repository-Query MUSS tenant_id filtern – kein Verlass auf RLS
  → Repository-Base: withTenant(tenantId) als Pflicht-Helper
  → Verboten: Queries auf operative Tabellen ohne .eq('tenant_id', ctx.tenantId)
  → Integration Tests MÜSSEN Cross-Tenant-Blocking prüfen (kein RLS-Safety-Net)

Warum nicht Variante B (RLS greift):
  → Komplexeres Token-Propagation-Setup
  → Schlechtere Performance (RLS-Overhead)
  → Weniger Kontrolle bei komplexen Joins
  → Für Phase 1 unnötig – Backend-Enforcement ist sauber genug
```

---

## 7. CONCURRENCY CONTROL

```typescript
// row_version in DB ist Pflicht auf allen operativen Tabellen (Trigger erhöht bei UPDATE).
// Das Backend muss das nutzen – sonst überschreibt der letzte Schreibvorgang still den vorherigen.

// PATCH mit Versionsprüfung (Optimistic Locking):
router.patch('/candidates/:id', async (req, reply) => {
  const { version, ...updates } = req.body  // Client muss aktuelle version mitsenden

  const result = await db.query(`
    UPDATE ark.dim_candidates_profile
    SET first_name=$1, updated_at=now(), row_version=row_version+1
    WHERE id=$2 AND tenant_id=$3 AND row_version=$4
    RETURNING id, row_version
  `, [updates.first_name, req.params.id, ctx.tenantId, version])

  if (result.rowCount === 0) {
    // Entweder nicht gefunden ODER Version wurde von jemandem anderen geändert:
    const exists = await checkExists(req.params.id, ctx.tenantId)
    if (!exists) throw new NotFoundError('Kandidat')
    throw new ConflictError('VERSION_CONFLICT: Datensatz wurde zwischenzeitlich geändert. Bitte neu laden.')
  }
})

// Gilt für: ALLE PATCH/PUT auf Kerntabellen
// Stage-Wechsel, AI-Suggestion Accept/Reject, Merge, Dokument-Update

// Conflicts: HTTP 409 mit Code 'VERSION_CONFLICT'
// → Frontend zeigt: "Jemand anderes hat diesen Datensatz geändert. Bitte die Seite neu laden."

// Worker Concurrency:
// Worker prüfen Status-Flags vor Verarbeitung:
// WHERE id = $1 AND status = 'pending'  → verhindert doppelte Verarbeitung
// UPDATE ... SET status='processing' WHERE status='pending'  → atomares Claim
```

### Repository-Standard: `updateWithVersion()` (Pflicht)

Optimistic Locking darf nicht von jedem Entwickler neu erfunden werden. Das Repository-Pattern stellt sicher, dass der Schutz konsistent über alle Entitäten greift.

```typescript
// lib/repository.base.ts
export const updateWithVersion = async <T>(
  trx: Transaction,
  table: string,
  id: string,
  tenantId: string,
  version: number,
  updates: Partial<T>
): Promise<T> => {
  // Parameter-Belegung:
  //   $1 = id, $2 = tenantId, $3 = version (WHERE-Clause)
  //   $4, $5, ... = Update-Felder (SET-Clause) → Offset ist 4, nicht 5
  const updateKeys   = Object.keys(updates)
  const updateValues = Object.values(updates)
  const setClause = updateKeys
    .map((key, i) => `${key}=$${i + 4}`)   // ← $4 für erstes Update-Feld
    .join(', ')
  const values = [id, tenantId, version, ...updateValues]
  //              $1  $2        $3        $4, $5, ...

  const result = await trx.query<T>(`
    UPDATE ark.${table}
    SET ${setClause}, updated_at=now(), row_version=row_version+1
    WHERE id=$1 AND tenant_id=$2 AND row_version=$3
    RETURNING *
  `, values)

  if (result.rowCount === 0) {
    const exists = await trx.query(
      `SELECT 1 FROM ark.${table} WHERE id=$1 AND tenant_id=$2`, [id, tenantId])
    if (exists.rowCount === 0) throw new NotFoundError(table)
    throw new ConflictError('VERSION_CONFLICT: Datensatz geändert. Bitte neu laden.', 'CONC_001')
  }
  return result.rows[0]
}

// Verwendung in allen Repositories (Kandidaten, Jobs, Mandate, Prozesse ...):
export const updateCandidate = (id, tenantId, version, data, trx) =>
  updateWithVersion(trx, 'dim_candidates_profile', id, tenantId, version, data)

// VERBOTEN: UPDATE ohne row_version-Prüfung auf operativen Kerntabellen
// PR-Review Pflicht: jede neue UPDATE-Query muss row_version im WHERE enthalten

---

## 7b. MULTI-TENANCY

```typescript
// tenant_id AUSSCHLIESSLICH aus JWT:
const tenantMiddleware = async (req) => {
  req.context.tenantId = req.jwtPayload.tenantId
  // NIEMALS: req.body.tenantId oder req.query.tenantId
}

// Jede operative Query:
supabase.from('ark.dim_candidates_profile')
  .select('...')
  .eq('tenant_id', req.context.tenantId)  // PFLICHT
  .eq('is_active', true)
  .is('deleted_at', null)

// Stammdaten (dim_cluster, dim_functions etc.) – kein Filter nötig, global

// Cross-Tenant-Zugriff = Security Incident:
if (resource.tenant_id !== ctx.tenantId) {
  await auditService.log({ action: 'CROSS_TENANT_ATTEMPT', ... })
  throw new ForbiddenError('Cross-tenant access detected')
}
```

**Tenant-Safe Repository Pattern (verbindlich):**
Jede Repository-Methode erhält `tenantId` aus `ctx` und muss intern immer `WHERE tenant_id = $tenantId` setzen. Queries auf operative Tabellen ohne Tenant-Filter sind verboten – es gibt kein RLS-Safety-Net da das Backend mit Service Role arbeitet.

---

## 8. VALIDIERUNG & INPUT SANITIZATION

```typescript
// candidates.schema.ts
export const CreateCandidateSchema = z.object({
  first_name:      z.string().min(1).max(100).trim(),
  last_name:       z.string().min(1).max(100).trim(),
  email_1:         z.string().email().max(255).toLowerCase().optional(),
  candidate_stage: z.enum(['Check','Refresh','Premarket','Active Sourcing',
    'Market Now','Inactive','Blind','Datenschutz']),
  candidate_temperature: z.enum(['Hot','Warm','Cold']).optional(),
  // v2.4: Wechselmotivation (8 Stufen) — ersetzt availability_date
  wechselmotivation: z.enum([
    'Arbeitslos','Will/muss wechseln','Will/muss wahrscheinlich wechseln',
    'Wechselt bei gutem Angebot','Wechselmotivation spekulativ',
    'Wechselt gerade intern & will abwarten','Will absolut nicht wechseln',
    'Will nicht mit uns zusammenarbeiten'
  ]).optional(),
  sparte_id:       z.string().uuid('Ungültige Sparte-ID'),
  birth_date:      z.string().datetime().optional(),
})
export type CreateCandidateInput = z.infer<typeof CreateCandidateSchema>

// Validierungsregeln:
// - UUID bei allen ID-Parametern prüfen
// - Strings: trim, max-length, XSS-safe
// - Enums identisch zu DB-CHECK-Constraints
// - Datumsfelder: ISO 8601, valid_from <= valid_to prüfen
// - Zahlen: min/max, NaN abfangen
// - Pagination: limit max 100, cursor muss UUID sein
// - NIEMALS rohe Request-Daten in DB-Queries
```

---

## 9. BUSINESS LOGIC & SERVICE LAYER

### Controller → Service → Repository (Pflicht-Pattern)
```typescript
// candidates.router.ts – nur Routing
router.post('/', auth, roles(['Admin', 'Candidate_Manager']), ctrl.create)

// candidates.controller.ts – nur HTTP-Handling
export const create = async (req, reply) => {
  const input = CreateCandidateSchema.parse(req.body)
  const candidate = await candidatesService.create(input, req.context)
  return reply.status(201).send({ success: true, data: candidate })
}

// candidates.service.ts – Business Logic + Transaktion
export const create = async (input, ctx) => {
  const existing = await candidatesRepo.findByEmail(input.email_1, ctx.tenantId)
  if (existing) throw new ConflictError('Email bereits vorhanden')

  return await withTransaction(async (trx) => {
    const candidate = await candidatesRepo.create(input, ctx.tenantId, trx)
    await eventService.emit('candidate.created', candidate.id, ctx, trx)
    await auditService.log({ action: 'CREATE', entity: 'candidate', entityId: candidate.id }, ctx, trx)
    return candidate
  })
}

// candidates.repository.ts – nur DB-Zugriffe
export const create = async (data, tenantId, trx) => {
  return await trx.query(`
    INSERT INTO ark.dim_candidates_profile (tenant_id, first_name, last_name, ...)
    VALUES ($1, $2, $3, ...) RETURNING id, full_name, candidate_stage
  `, [tenantId, data.first_name, data.last_name, ...])
}
```

### Transaktionen (Business Write + Event = EINE Transaktion)
```typescript
export const withTransaction = async <T>(fn: (client) => Promise<T>): Promise<T> => {
  const client = await pool.connect()
  try {
    await client.query('BEGIN')
    const result = await fn(client)
    await client.query('COMMIT')
    return result
  } catch (err) {
    await client.query('ROLLBACK')
    throw err
  } finally { client.release() }
}
```

### Soft Delete + Restore
```typescript
// Soft Delete:
await withTransaction(async (trx) => {
  await trx.query(`UPDATE ark.dim_candidates_profile SET
    is_active=false, deleted_at=now(), deleted_by=$1, deletion_reason=$2
    WHERE id=$3 AND tenant_id=$4`, [ctx.userId, reason, id, ctx.tenantId])
  await eventService.emit('candidate.deleted', id, ctx, trx)
  await auditService.log({ action: 'DELETE', ... }, ctx, trx)
})

// Restore (POST /candidates/:id/restore):
await trx.query(`UPDATE ark.dim_candidates_profile SET
  is_active=true, deleted_at=null, deleted_by=null, deletion_reason=null
  WHERE id=$1 AND tenant_id=$2`, [id, ctx.tenantId])
```

### Statusmaschinen (config/stageMachines.ts)
```typescript
export const CANDIDATE_STAGE_TRANSITIONS: Record<string, string[]> = {
  'Check':           ['Refresh', 'Premarket', 'Active Sourcing', 'Inactive', 'Blind', 'Datenschutz'],
  'Refresh':         ['Check', 'Premarket', 'Active Sourcing', 'Inactive', 'Blind', 'Datenschutz'],
  'Premarket':       ['Active Sourcing', 'Check', 'Refresh', 'Inactive', 'Datenschutz'],
  'Active Sourcing': ['Market Now', 'Premarket', 'Check', 'Refresh', 'Inactive', 'Datenschutz'],
  'Market Now':      ['Active Sourcing', 'Inactive', 'Datenschutz'],
  'Inactive':        ['Check', 'Refresh', 'Blind', 'Datenschutz'],
  'Blind':           ['Check', 'Refresh', 'Inactive', 'Datenschutz'],
  'Datenschutz':     [],  // Regulär Terminal. Sonder-Automation (system_override) darf nach 1 Jahr → Refresh.
                          // Auch manuell rückstellbar via dedizierte Funktion mit Audit-Log.
}
// Hinweis: Alle Stages können manuell geändert werden.
// Automatische Event-getriebene Übergänge siehe Abschnitt 10b.

export const PROCESS_STAGE_TRANSITIONS: Record<string, string[]> = {
  'Expose':     ['CV Sent', 'Closed'],
  'CV Sent':    ['TI', 'Closed', 'Rejected'],
  'TI':         ['1st', 'Closed', 'Rejected'],
  '1st':        ['2nd', 'Closed', 'Rejected', 'Offer'],
  '2nd':        ['3rd', 'Closed', 'Rejected', 'Offer'],
  '3rd':        ['Assessment', 'Offer', 'Closed', 'Rejected'],
  'Assessment': ['Offer', 'Closed', 'Rejected'],
  'Offer':      ['Placement', 'Closed', 'Rejected'],
  'Placement':  ['Closed'],
}

// v2.4: Entwurf und Abgelehnt hinzugefügt. Offerten-Conversion-Rate KPI.
export const MANDATE_STATUS_TRANSITIONS: Record<string, string[]> = {
  'Entwurf':   ['Active', 'Abgelehnt'],  // Aktivierung via Dokument-Upload "Mandatsofferte unterschrieben"
  'Active':    ['Completed', 'Cancelled'],
  'Abgelehnt': [],  // Mandat kam nicht zustande (KPI: Offerten-Conversion-Rate)
  'Completed': [],
  'Cancelled': [],
}

// v2.4: Cancelled = Rückzieher nach Placement (100% Rückvergütung)
export const PROCESS_STATUS_TRANSITIONS: Record<string, string[]> = {
  'Open':      ['Placed', 'On Hold', 'Closed', 'Rejected', 'Dropped'],
  'Placed':    ['Cancelled'],  // Post-Placement Cancellation (Rückzieher)
  'On Hold':   ['Open', 'Closed', 'Rejected'],
  'Closed':    [],
  'Rejected':  [],
  'Stale':     ['Open', 'Closed'],
  'Cancelled': [],
  'Dropped':   [],
}

export const JOB_STATUS_TRANSITIONS: Record<string, string[]> = {
  'Open':      ['Filled', 'On Hold', 'Cancelled'],
  'On Hold':   ['Open', 'Cancelled'],
  'Filled':    [],
  'Cancelled': [],
}

// v2.4: Vacancy-Status aktualisiert (On Hold + Cancelled + Lost)
export const VACANCY_STATUS_TRANSITIONS: Record<string, string[]> = {
  'Open':      ['Filled', 'On Hold', 'Cancelled', 'Lost'],
  'Filled':    [],
  'On Hold':   ['Open', 'Cancelled'],
  'Cancelled': [],
  'Lost':      ['Open'],  // Kann reaktiviert werden
}

export const MANDATE_RESEARCH_TRANSITIONS: Record<string, string[]> = {
  // Manuell änderbar (is_stage_locked = false):
  'research':                ['nicht_erreichbar', 'nicht_mehr_erreichbar',
                              'nicht_interessiert', 'dropped', 'cv_expected'],
  'nicht_erreichbar':        ['research', 'nicht_mehr_erreichbar',
                              'nicht_interessiert', 'dropped', 'cv_expected'],
  'nicht_mehr_erreichbar':   [],
  'nicht_interessiert':      [],
  'dropped':                 [],
  'cv_expected':             ['cv_in', 'nicht_interessiert', 'dropped',
                              'nicht_erreichbar'],
  // Automatisch + gesperrt (is_stage_locked = true):
  'cv_in':                   ['briefing', 'dropped'],
  'briefing':                ['go_muendlich', 'nicht_interessiert', 'dropped'],
  'go_muendlich':            ['go_schriftlich', 'rejected_oral_go', 'ghosted'],
  'go_schriftlich':          ['rejected_written_go'],
  // GO-Rejections sind terminal:
  'rejected_oral_go':        [],
  'rejected_written_go':     [],
  'ghosted':                 [],
}

// Validierung in policies/candidate-stage.policy.ts:
export const validateStageChange = (current: string, next: string, transitions) => {
  const allowed = transitions[current] ?? []
  if (!allowed.includes(next))
    throw new UnprocessableError(`Stage-Wechsel ${current} → ${next} nicht erlaubt`)
}
```

---

## 10. EVENT-SYSTEM & AUTOMATISIERUNG

### Outbox Pattern (verbindlich)

`fact_event_queue` ist die kanonische **Outbox** des Systems. Diese Regel ist nicht verhandelbar:

```
1. Business Write + Event Insert passieren in EINER Transaktion (COMMIT oder ROLLBACK beides)
2. Events werden ERST nach erfolgreichem COMMIT vom Worker konsumiert
3. Kein Worker und keine Integration darf Events aus halbfertigen Zuständen lesen
4. Keine direkte Job-Erzeugung (PgBoss) parallel zum Write ohne persistierten Event
5. Wenn der Event Processor Folgejobs erzeugt → nur auf Basis persistierter Queue-Events
```

**Outbox → PgBoss Überführung (architektonische Entscheidung):**
```
Variante (gewählt): Event Processor Worker pollt fact_event_queue direkt.
  → event-processor.worker.ts: SELECT ... WHERE status='pending' ORDER BY triggered_at
  → Kein separater Dispatcher
  → PgBoss Jobs werden IM Worker erzeugt (nach Commit, auf Basis des persistierten Events)
  → Vorteil: kein zusätzlicher Service, kein doppelter State
  → Risiko: Worker muss atomar claimen: UPDATE SET status='processing' WHERE status='pending'
    damit kein zweiter Worker denselben Event doppelt verarbeitet

VERBOTEN: Direkte PgBoss.send() im API-Handler ohne vorherigen Event-Insert in fact_event_queue
VERBOTEN: PgBoss Jobs erzeugen bevor die umschliessende Transaktion committed ist
```

Warum: Würde der Worker einen Event lesen bevor der äussere COMMIT fertig ist, sieht er den neuen Zustand noch nicht (Read Committed Isolation). Das produziert stille Inkonsistenzen.

**Idempotenz-Felder in `fact_event_queue` (verbindlich):**
```
UNIQUE auf idempotency_key:
  → Für interne Events: Key = SHA-256 aus (event_name + entity_type + entity_id + payload_snapshot)
  → ON CONFLICT (idempotency_key) DO NOTHING

UNIQUE auf (tenant_id, source_system, source_event_id):
  → Für externe Webhooks (3CX, Outlook, Scraper): source_event_id = externe ID (z.B. 3CX Call-ID)
  → ON CONFLICT (tenant_id, source_system, source_event_id) DO NOTHING

Beide Constraints koexistieren – interner Event nutzt idempotency_key, externer Event nutzt source_event_id.
```

### Event Service (korrigiert)
```typescript
// ❌ FALSCH – Date.now() macht Idempotenz kaputt (jeder Aufruf = neuer Key):
// idempotency_key = `${eventName}:${entityId}:${Date.now()}`

// ✅ RICHTIG – Deterministische Keys:
// Für interne Domain-Events (CRM-initiiert):
const idempotencyKey = `${eventName}:${entityId}:${payload ? hash(JSON.stringify(payload)) : 'nopayload'}`
// hash() = SHA-256 Kurzform, z.B. erste 16 Zeichen

// Für externe Events (3CX, Outlook, Webhooks):
// source_system + source_event_id = harte Eindeutigkeit (ON CONFLICT greift)

export const emit = async (
  eventName: string,
  entityId: string,
  ctx: RequestContext,
  trx: Transaction,
  payload?: Record<string, unknown>,
  sourceEventId?: string,          // Externe ID (3CX Call-ID, MS Graph Message-ID etc.)
  sourceSystem: 'crm' | 'threecx' | 'outlook' | 'scraper' | 'worker' = 'crm'
  //            ↑ PFLICHT: kein Hardcode auf 'crm' mehr – externe Events nennen ihren Ursprung
) => {
  const eventType = await getEventTypeByName(eventName)

  // Deterministischer Idempotenz-Key für interne Events:
  const stablePayloadHash = payload ? crypto.createHash('sha256')
    .update(JSON.stringify(payload)).digest('hex').slice(0, 16) : 'empty'
  const idempotencyKey = `${eventName}:${entityId}:${stablePayloadHash}`

  if (sourceEventId) {
    // EXTERNER Event (3CX, Outlook, Scraper):
    // Primäre Idempotenz via (tenant_id, source_system, source_event_id)
    // → ON CONFLICT greift bei Doppelzustellung des Providers
    await trx.query(`
      INSERT INTO ark.fact_event_queue (
        tenant_id, event_type_id, entity_type, entity_id,
        payload_json, idempotency_key, source_system,
        source_event_id, triggered_by, correlation_id
      ) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)
      ON CONFLICT (tenant_id, source_system, source_event_id) DO NOTHING
    `, [ctx.tenantId, eventType.id, eventType.entity_type, entityId,
        JSON.stringify(payload ?? {}), idempotencyKey, sourceSystem,
        sourceEventId, ctx.userId, ctx.correlationId])
  } else {
    // INTERNER Event (CRM-initiiert, Worker-initiiert):
    // Primäre Idempotenz via (tenant_id, idempotency_key)
    await trx.query(`
      INSERT INTO ark.fact_event_queue (
        tenant_id, event_type_id, entity_type, entity_id,
        payload_json, idempotency_key, source_system,
        source_event_id, triggered_by, correlation_id
      ) VALUES ($1,$2,$3,$4,$5,$6,$7,NULL,$8,$9)
      ON CONFLICT (tenant_id, idempotency_key) DO NOTHING
    `, [ctx.tenantId, eventType.id, eventType.entity_type, entityId,
        JSON.stringify(payload ?? {}), idempotencyKey, sourceSystem,
        ctx.userId, ctx.correlationId])
  }
}

// Aufruf-Beispiele:
// Intern (CRM Stage-Change):
await eventService.emit('candidate.stage_changed', candidateId, ctx, trx, stagePayload)

// Extern (3CX Webhook):
await eventService.emit('call.received', historyId, ctx, trx, callPayload, threecxCallId, 'threecx')
// → ON CONFLICT (tenant_id, source_system='threecx', source_event_id=threecxCallId) DO NOTHING

// Extern (Outlook Sync):
await eventService.emit('email.received', historyId, ctx, trx, emailPayload, msGraphMessageId, 'outlook')
// → ON CONFLICT (tenant_id, source_system='outlook', source_event_id=msGraphMessageId) DO NOTHING
```

### Event Processor Worker (DER wichtigste Worker)
```typescript
boss.work('process-event', async (job) => {
  const { eventId, tenantId } = job.data
  const event = await loadEvent(eventId, tenantId)
  const rules = await loadMatchingRules(event.event_type_id, tenantId)

  for (const rule of rules) {
    if (rule.circuit_breaker_tripped) { logger.warn('CB tripped'); continue }
    if (rule.max_triggers_per_hour) {
      const count = await getTriggerCount(rule.id, 'hour')
      if (count >= rule.max_triggers_per_hour) { await tripCircuitBreaker(rule.id); continue }
    }
    await executeAction(rule, event, tenantId)
    await incrementTriggerCount(rule.id)
  }
  await markEventProcessed(eventId)
  await writeEventLog(eventId)
})

// LLM-FOLGEJOB RATE LIMITING (Pflicht bei Massen-Scraping / Bulk-Import):
// Problem: 50k Kandidaten × 1 Embedding-Job = 50'000 LLM-Calls in Sekunden → API-Quota gesprengt
// Lösung: Der event-processor.worker.ts drosselt Folgejobs auf LLM-Queues aktiv:
const LLM_FOLLOWUP_RATE = {
  maxPerMinute:   30,   // Globales LLM-Call-Limit pro Worker-Zyklus
  burstAllowed:   10,   // Kurzfristiger Burst erlaubt
  delayMs:        2000, // Mindest-Delay zwischen LLM-Folgejobs bei Quota-Nähe
} as const

// Vor jedem LLM-Folgejob im event-processor:
const currentLLMRate = await getLLMCallRateLastMinute()
if (currentLLMRate >= LLM_FOLLOWUP_RATE.maxPerMinute) {
  // Nicht abbrechen – mit Delay requeuen:
  await boss.send('ai-classify', jobData, { startAfter: new Date(Date.now() + LLM_FOLLOWUP_RATE.delayMs) })
  logger.warn({ currentLLMRate }, 'LLM rate limit reached – folgejob delayed')
  return
}
```

### Vollständige Event-Liste Phase 1
```
KANDIDAT:   candidate.created · candidate.stage_changed · candidate.updated ·
            candidate.deleted · candidate.merged · candidate.briefing_created ·
            candidate.document_uploaded · candidate.assessment_completed · candidate.anonymized

PROZESS:    process.created · process.stage_changed · process.placement_done ·
            process.closed · process.reopened · process.on_hold · process.rejected

JOB:        job.created · job.stage_changed · job.filled · job.cancelled ·
            job.vacancy_detected · job.published

MANDAT:     mandate.created · mandate.stage_changed · mandate.completed · mandate.cancelled

CALL:       call.received · call.transcript_ready · call.missed
EMAIL:      email.received · email.sent · email.bounced
DOKUMENT:   document.uploaded · document.cv_parsed · document.ocr_done ·
            document.embedded · document.reparsed
HISTORY:    history.created · history.ai_summary_ready
SCRAPER:    scrape.change_detected · scrape.new_job_detected · scrape.person_left ·
            scrape.new_person · scrape.role_changed
MATCH:      match.score_updated · match.suggestion_ready
ASSESSMENT: assessment.completed · assessment.invite_sent · assessment.expired
SYSTEM:     system.data_quality_issue · system.circuit_breaker_tripped ·
            system.dead_letter_alert · system.retention_action
```

### PgBoss Setup
```typescript
export const boss = new PgBoss({
  connectionString: process.env.DATABASE_URL,
  schema: 'pgboss',
  retryLimit: 3, retryDelay: 60, retryBackoff: true,  // 1min → 5min → 30min
  expireInHours: 24, deleteAfterDays: 7,
})

// Scheduled Jobs:
await boss.schedule('cleanup-pii',      '0 2 * * *')       // tägl. 2:00
await boss.schedule('refresh-powerbi',  '0 */4 * * *')     // alle 4h
await boss.schedule('scrape-accounts',  '0 8 * * 1-5')     // Mo-Fr 8:00
await boss.schedule('worker-heartbeat', '*/5 * * * *')     // alle 5 Min

// Dead Letter Monitoring:
boss.work('*__dlq', async (job) => {
  logger.error({ jobName: job.name }, 'Dead letter job')
  Sentry.captureEvent({ message: `DLQ: ${job.name}`, level: 'error' })
})
```

---

## 10b. STAGE-AUTOMATISIERUNGEN (Event-getrieben)

Alle Stage-Übergänge werden primär durch Events (History-Einträge, Dokument-Uploads,
Prozess-Events) ausgelöst. Die Automatisierungslogik läuft über dim_automation_rules
und wird vom event-processor.worker.ts ausgeführt.

### Kandidaten-Stage Automatisierung

Alle Stages können jederzeit manuell geändert werden. Die Automatik ist ein Vorschlag.

```
① Check (Default)               ← candidate.created
② → Refresh                     ← Ghosting/Absage nach CV Expected
                                   (History: NIC, Dropped, Ghosting)
③ → Premarket                   ← History: 'Erreicht - Briefing'
④ → Active Sourcing             ← Briefing + Original CV + Diplom + Arbeitszeugnis vorhanden
                                   (auch ausgelöst bei document.uploaded wenn Bedingung neu erfüllt)
⑤ → Market Now                  ← process.created (mind. 1 offener Prozess)
⑥ → Active Sourcing (zurück)    ← Alle Prozesse geschlossen (kein Open mehr)
⑦ → Inactive                    ← Alter > 60 (täglicher Scheduled Job, 03:00)
⑧ → Datenschutz                 ← POST /candidates/:id/anonymize → Anonymisierungs-Workflow
```

### Mandat-Research-Stage Automatisierung

Bis cv_expected manuell. Ab cv_in automatisch UND gesperrt (is_stage_locked=true).

```
MANUELL (offen):     research → nicht_erreichbar → cv_expected
GESPERRT (auto):     cv_expected + Original CV    → cv_in
                     cv_in + Briefing History      → briefing
                     briefing + GO mündl. History   → go_muendlich
                     go_muendlich + GO schriftl.    → go_schriftlich
                     go_schriftlich + Versand       → Jobbasket → Prozess
```

Backend-Enforcement: `mandateResearchService.updateContactStatus()` prüft is_stage_locked.
Gesperrte Stages können nur durch verifizierte Automation Rules geändert werden.

### Mandate Research ↔ Jobbasket: Parallele Systeme

**WICHTIG:** Mandate Research und Jobbasket sind PARALLELE Tracking-Systeme, kein
sequentieller Übergang. Derselbe Kandidat existiert gleichzeitig in beiden:

```
┌─────────────────────────────────────────────────────────────────┐
│ MANDATE RESEARCH                   JOBBASKET                    │
│ (Research-Perspektive)             (Versand-Perspektive)        │
│                                                                  │
│ research                           Lead                          │
│ nicht_erreichbar                     │                           │
│ cv_expected ─────────────────────── │ (gleicher Kandidat)       │
│ cv_in          ←─── Original CV ──→ │                           │
│ briefing       ←─── Briefing ─────→ │                           │
│ go_muendlich   ←─── Mündl. GO ────→ is_oral_go                 │
│ go_schriftlich ←─── Schriftl. GO ─→ is_written_go              │
│                                     is_assigned (Gate 1)        │
│                                     is_to_send (Gate 2)         │
│                                     CV Sent / Exposé Sent       │
│                                     → Prozess erstellt          │
└─────────────────────────────────────────────────────────────────┘

GEMEINSAME EVENT-TRIGGER:
  → History 'Erreicht - Briefing'       → aktualisiert BEIDE Systeme
  → History 'Emailverkehr - Mündl. GOs' → aktualisiert BEIDE Systeme
  → History 'Emailverkehr - Schriftl. GOs' → aktualisiert BEIDE Systeme
  → document.uploaded (Original CV)     → aktualisiert BEIDE Systeme

MANUELLER SCHRITT:
  → Kandidat wird manuell in den Jobbasket eines Jobs hinzugefügt (als Lead)
  → Das passiert NICHT automatisch bei go_schriftlich
  → Der Recruiter entscheidet für WELCHEN Job der Kandidat in den Basket kommt
  → Ein Kandidat kann in mehreren Jobbaskets gleichzeitig sein (verschiedene Jobs)
```

### Jobbasket-Flow Automatisierung

```
① Lead                          ← Kandidat in Jobbasket hinzugefügt
② → is_oral_go                  ← History: 'Emailverkehr - Mündliche GOs versendet'
③ → is_written_go               ← History: 'Emailverkehr - Schriftliche GOs'
④ → is_assigned (Gate 1)        ← Schriftl. GO + Original CV + Diplom + Arbeitszeugnis
⑤ → Versandoptionen (Gate 2)    ← ARK CV + Abstract → CV Sent Button
                                   Exposé → Exposé Sent Button
                                   Alle drei → beide Buttons
⑥ → CV Sent / Exposé Sent      ← E-Mail an Kunden mit Anhängen
⑦ → Prozess automatisch erstellt ← Stage 'CV Sent' oder 'Expose'
```

### Reason-Pflichtfelder

```
Bei jeder Absage/Rejection MUSS ein Grund ausgewählt werden:
  Kandidat lehnt ab:     → rejection_reason_candidate_id (Pflicht)
  Kunde lehnt ab:        → rejection_reason_client_id (Pflicht)
  GO Rejected:           → go_rejection_reason_id (Pflicht)
  Dropped:               → dropped_reason_id (Pflicht)
  Offer Refused:         → offer_refused_reason_id (Pflicht)
  Cancellation:          → cancellation_reason_id (Pflicht)
  Ghosted:               → kein Grund (NULL erlaubt)

Backend erzwingt: History-Eintrag ohne passenden Grund → 422 Unprocessable
```

### Erweiterbarkeit

Neue Automatisierungen können OHNE Code-Änderung hinzugefügt werden:
→ Neuer Eintrag in dim_automation_rules (Konfiguration, kein Deployment)
→ Event Spine + Automation Rules + Policies = 3-Schichten-Architektur
→ Circuit Breaker schützt vor Event-Stürmen
→ Feature Flags erlauben einzelne Automationen zu deaktivieren

---

## 11. ENDPUNKT-ÜBERSICHT PHASE 1

### Health (kein Auth required)
```
GET    /health/live                       ← Läuft der Prozess?
GET    /health/ready                      ← Kann Service Requests bedienen?
GET    /health/dependencies               ← DB, Queue, Cache erreichbar?
```

### Auth
```
POST   /api/v1/auth/login
POST   /api/v1/auth/refresh
POST   /api/v1/auth/logout
GET    /api/v1/auth/me
POST   /api/v1/auth/forgot-password
POST   /api/v1/auth/reset-password
POST   /api/v1/auth/change-password
GET    /api/v1/auth/sessions                   ← Alle aktiven Sessions
DELETE /api/v1/auth/sessions/:id               ← Einzelne Session beenden
DELETE /api/v1/auth/sessions                   ← Alle Sessions beenden (Logout Everywhere)
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

### Kandidaten
```
GET    /api/v1/candidates
POST   /api/v1/candidates
GET    /api/v1/candidates/:id
PATCH  /api/v1/candidates/:id
DELETE /api/v1/candidates/:id              ← Soft Delete
POST   /api/v1/candidates/:id/restore      ← Soft Delete rückgängig
POST   /api/v1/candidates/:id/stage-change
GET    /api/v1/candidates/:id/history
GET    /api/v1/candidates/:id/documents
GET    /api/v1/candidates/:id/employment
POST   /api/v1/candidates/:id/employment
PATCH  /api/v1/candidates/:id/employment/:employmentId
GET    /api/v1/candidates/:id/projects
POST   /api/v1/candidates/:id/projects
PATCH  /api/v1/candidates/:id/projects/:projectId
GET    /api/v1/candidates/:id/skills       ← DEPRECATED v2.4 (Skills → Focus)
PUT    /api/v1/candidates/:id/skills       ← DEPRECATED v2.4 (Skills → Focus)
GET    /api/v1/candidates/:id/functions
PUT    /api/v1/candidates/:id/functions
GET    /api/v1/candidates/:id/focus
PUT    /api/v1/candidates/:id/focus
GET    /api/v1/candidates/:id/assessments
GET    /api/v1/candidates/:id/briefings
POST   /api/v1/candidates/:id/briefings
GET    /api/v1/candidates/:id/match-scores
POST   /api/v1/candidates/:id/merge
POST   /api/v1/candidates/:id/anonymize    ← DSGVO/nDSG
GET    /api/v1/candidates/:id/export       ← DSGVO/nDSG
POST   /api/v1/candidates/linkedin-import  ← Browser Extension
GET    /api/v1/candidates/:id/linkedin-activities  ← Social Tracking (Likes, Comments, etc.)
GET    /api/v1/candidates/:id/briefings/:briefingId/projects  ← Verknüpfte Projekte im Briefing
POST   /api/v1/candidates/:id/briefings/:briefingId/projects
PATCH  /api/v1/candidates/:id/briefings/:briefingId/projects/:projectId
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
GET    /api/v1/jobs/:id/basket/:candidateId/send-options  ← Verfügbare Versandoptionen (Gate 2)
POST   /api/v1/jobs/:id/basket/:candidateId/send-cv       ← CV senden → Prozess erstellen
POST   /api/v1/jobs/:id/basket/:candidateId/send-expose   ← Exposé senden → Prozess erstellen
GET    /api/v1/jobs/:id/matches
PUT    /api/v1/jobs/:id/skills             ← DEPRECATED v2.4 (Skills → Focus)
PUT    /api/v1/jobs/:id/functions
PUT    /api/v1/jobs/:id/focus
POST   /api/v1/jobs/:id/publish

GET    /api/v1/vacancies
POST   /api/v1/vacancies
GET    /api/v1/vacancies/:id
PATCH  /api/v1/vacancies/:id
POST   /api/v1/vacancies/:id/convert-to-job  ← Vakanz → operativer Job
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
GET    /api/v1/mandates/:id/billing-preview   ← Vorschau (nur Service Layer)
GET    /api/v1/mandates/:id/processes
GET    /api/v1/mandates/:id/jobs
```

### Prozesse
```
GET    /api/v1/processes
POST   /api/v1/processes                      ← Duplikat-Schutz: max 1 offener Prozess
                                                 pro Kandidat pro Job (DB UNIQUE + Service Check)
GET    /api/v1/processes/:id
PATCH  /api/v1/processes/:id
POST   /api/v1/processes/:id/stage-change
GET    /api/v1/processes/:id/timeline         ← Alle Events chronologisch
GET    /api/v1/processes/:id/events
POST   /api/v1/processes/:id/close
POST   /api/v1/processes/:id/reopen
POST   /api/v1/processes/:id/reject         ← Mit Pflicht-Reason
PATCH  /api/v1/processes/:id/finance
POST   /api/v1/processes/:id/upgrade-to-cv-sent  ← Exposé → CV Sent Nachfolge
```

### History & Aktivitäten
```
GET    /api/v1/history
POST   /api/v1/history                       ← Rejection-History braucht reason (Pflicht)
GET    /api/v1/history/:id
PATCH  /api/v1/history/:id
GET    /api/v1/activities
POST   /api/v1/activities
PATCH  /api/v1/activities/:id
POST   /api/v1/activities/:id/complete
```

### Reminders
```
GET    /api/v1/reminders                      ← Meine/Team/Alle Reminders
                                                Query: ?scope=self|team|all (rollen-gated)
                                                       &status=overdue|today|week|later|done
                                                       &type=<reminder_type>
                                                       &assignee=<mitarbeiter_id>
                                                       &entity=<candidate|account|mandate|job|process>&id=<uuid>
                                                       &from=<iso-date>&to=<iso-date>
                                                       &priority=Urgent|High|Medium|Low
                                                       &recurrence=None|Daily|Weekly|Monthly
                                                       &auto_only=true|false
POST   /api/v1/reminders                      ← Neuen Reminder erstellen
GET    /api/v1/reminders/:id
PATCH  /api/v1/reminders/:id                  ← Datum/Notiz/Priority/Typ/is_done (Undo-Pfad) ändern
POST   /api/v1/reminders/:id/complete         ← Als erledigt markieren (setzt is_done/done_at/done_by)
POST   /api/v1/reminders/:id/snooze           ← +1h/+1d/+1w/<iso-date>
POST   /api/v1/reminders/:id/reassign         ← NEU 2026-04-17: Mitarbeiter-Wechsel (HoD+/Admin)
                                                Body: {new_assignee_id}
                                                Event: reminder_reassigned
```

### User Preferences (Reminders Saved Views)
```
GET    /api/v1/user-preferences/reminders              ← NEU 2026-04-17: liest dashboard_config.reminders (JSON)
PATCH  /api/v1/user-preferences/reminders              ← Merged Partial-Update (Saved-Views CRUD, Scope/View-Prefs, Push-Defaults)
                                                         Body-Operations:
                                                           { "saved_views": {"add":{…}} | {"update":{id, …}} | {"delete":{id}} | {"reorder":[ids]} }
                                                           { "last_active_scope": "self|team|all" }
                                                           { "last_active_view": "list|calendar" }
                                                           { "push_notification_defaults": {…} }
                                                         Max 10 user-defined saved_views pro User.
```

### Dokumente
```
POST   /api/v1/documents/upload               ← MIME/Hash/Grösse/Malware-Check
GET    /api/v1/documents
GET    /api/v1/documents/:id
PATCH  /api/v1/documents/:id
DELETE /api/v1/documents/:id
GET    /api/v1/documents/:id/download         ← Signed URL
POST   /api/v1/documents/:id/reparse          ← OCR/Parsing erneut triggern
GET    /api/v1/documents/:id/ai-suggestions   ← CV-Parse-Vorschläge
POST   /api/v1/documents/:id/link-entity      ← Nachträglich verknüpfen
```

### Events & Automationen
```
GET    /api/v1/events
GET    /api/v1/events/:id
POST   /api/v1/events/replay/:id              ← Nur Admin, kein Loop
GET    /api/v1/event-types
GET    /api/v1/automation-rules
POST   /api/v1/automation-rules
PATCH  /api/v1/automation-rules/:id
POST   /api/v1/automation-rules/:id/enable
POST   /api/v1/automation-rules/:id/disable
POST   /api/v1/automation-rules/:id/reset-circuit-breaker  ← Manueller Reset
```

### Debuggability / Event-Chain (NEU v2.4)
```
GET    /api/v1/entities/:type/:id/event-chain        ← Kombinierte Timeline: History + Events + Audit
                                                        Query-Params: ?from=&to=&source=human|system|automation
                                                        Liefert chronologisch sortiert mit correlation_id
                                                        Für Admin Event-Chain Explorer und Entity-Detail-Ansicht
```

### Notifications
```
GET    /api/v1/notifications
PATCH  /api/v1/notifications/:id/read
PATCH  /api/v1/notifications/:id/unread
POST   /api/v1/notifications/test
GET    /api/v1/notification-templates
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
POST   /api/v1/assessments/import-scheelen          ← v2.4: CSV-Import mit Dry-Run
```

### Emails (NEU v2.4 — CRM als zentrales Kommunikationstool)
```
POST   /api/v1/emails/send                          ← Email aus CRM senden (via MS Graph)
POST   /api/v1/emails/send-with-template            ← Email mit Template senden (Auto-Klassifizierung)
GET    /api/v1/emails/inbox                          ← Unklassifizierte eingehende Mails
GET    /api/v1/emails/drafts                         ← Gespeicherte Entwürfe
POST   /api/v1/emails/drafts                         ← Entwurf speichern
PATCH  /api/v1/emails/drafts/:id                     ← Entwurf bearbeiten
DELETE /api/v1/emails/drafts/:id                     ← Entwurf löschen
GET    /api/v1/email-templates                       ← Alle Templates (System + Custom)
POST   /api/v1/email-templates                       ← Neues Template (Admin)
PATCH  /api/v1/email-templates/:id                   ← Template bearbeiten (Admin)
DELETE /api/v1/email-templates/:id                   ← Template löschen (nur Custom, nicht System)
```

### Provisionen (NEU v2.4)
```
GET    /api/v1/commissions                           ← Provisionsübersicht (gefiltert nach Mitarbeiter)
GET    /api/v1/commissions/summary                   ← Zusammenfassung: offen, ausgezahlt, total pro Periode
GET    /api/v1/commissions/:processId                ← Provisions-Detail pro Prozess
```

### Automation-Settings (NEU v2.4)
```
GET    /api/v1/automation-settings                   ← Alle konfigurierbaren Fristen/Schwellwerte
PATCH  /api/v1/automation-settings/:key              ← Wert ändern (Admin)
```

### AI / Suggestions
```
POST   /api/v1/ai/classify                     ← Generalist/Spezialist, Seniority
POST   /api/v1/ai/summarize
POST   /api/v1/ai/parse-cv
POST   /api/v1/ai/generate-dossier
GET    /api/v1/ai/suggestions
GET    /api/v1/ai/suggestions/:id
POST   /api/v1/ai/suggestions/:id/accept
POST   /api/v1/ai/suggestions/:id/reject
POST   /api/v1/ai/suggestions/:id/modify
GET    /api/v1/ai/classifications/:entityType/:entityId
GET    /api/v1/ai/policies                     ← dim_ai_write_policies
```

### RAG / Search
```
POST   /api/v1/rag/query                       ← Semantische Suche
POST   /api/v1/rag/reindex/:entityType/:entityId  ← Manueller Reindex
GET    /api/v1/rag/chunks/:entityType/:entityId   ← Chunks inspizieren
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
GET    /api/v1/matching/explain/:matchId       ← Score-Erklärung (nicht Blackbox!)
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
GET    /api/v1/market/accounts/:accountId/organigram  ← Organigramm-History
GET    /api/v1/market/snapshots
GET    /api/v1/market/competitors
POST   /api/v1/market/rebuild-snapshot
```

### Stammdaten (gecacht, 30 Min TTL)
```
GET    /api/v1/stammdaten/clusters
GET    /api/v1/stammdaten/functions
GET    /api/v1/stammdaten/focus
GET    /api/v1/stammdaten/edv
GET    /api/v1/stammdaten/sectors
GET    /api/v1/stammdaten/skills
GET    /api/v1/stammdaten/skills/:id/premium  ← CHF-Aufschlag Skill-Economy
GET    /api/v1/stammdaten/languages
```

### Webhooks & Integrationen (eingehend)

**WICHTIG: Externe Webhook- und OAuth-Endpunkte stehen NICHT unter /api/v1/**
Sie sind bei externen Systemen (3CX, Azure) fix registriert und können nicht versioniert werden.

```
# 3CX – DUALE INTEGRATION

# A) CRM-Template (Server Side) – Screen-Pop & Call Journaling
#    Auth: API Key (X-API-Key Header), in 3CX CRM-Template konfiguriert
GET    /api/3cx/lookup                         ← Kontakt-Lookup via Telefonnummer (MUSS GET sein!)
GET    /api/3cx/lookup-email                   ← Kontakt-Lookup via E-Mail
POST   /api/3cx/report-call                    ← Call Journaling (Anruf loggen)

# B) Webhook (Event-basiert) – Echtzeit-Events + Transkription
#    Auth: HMAC-Signatur (X-3CX-Secret Header)
POST   /api/3cx/webhook                        ← Alle 3CX Events (Call + Transcript + AI)

# Microsoft / Outlook – registrierte Redirect URI in Azure App Registration
GET    /api/outlook/auth/callback              ← OAuth2 Callback (Azure Redirect URI)
POST   /api/v1/integrations/outlook/connect    ← Initiiert OAuth2-Flow
POST   /api/v1/integrations/outlook/disconnect
POST   /api/v1/integrations/outlook/sync       ← Manueller Mail-Sync trigger

# Generische ausgehende Webhooks (versioniert)
POST   /api/v1/webhooks/scraper/change-detected
POST   /api/v1/webhooks/scraper/new-job-detected
POST   /api/v1/webhooks/:webhookId

# Integration Tests
POST   /api/v1/integrations/3cx/test
```

### Scraper
```
POST   /api/v1/scraper/jobs
GET    /api/v1/scraper/jobs/:jobId
GET    /api/v1/scraper/items
PATCH  /api/v1/scraper/items/:id               ← Approve/Reject
```

### Honorar Settings (Tenant-konfigurierbar)
```
GET    /api/v1/settings/honorar                ← Alle Honorarsätze des Tenants
POST   /api/v1/settings/honorar                ← Neuen Satz anlegen
PATCH  /api/v1/settings/honorar/:id            ← Satz anpassen
DELETE /api/v1/settings/honorar/:id            ← Soft Delete
```

### CRM AI Assistant (Chatbot)
```
POST   /api/v1/assistant/chat                  ← Chat-Nachricht → RAG + LLM → Antwort
GET    /api/v1/assistant/conversations          ← Bisherige Konversationen
DELETE /api/v1/assistant/conversations/:id      ← Konversation löschen
```

### Admin
```
GET    /api/v1/admin/users
POST   /api/v1/admin/users
PATCH  /api/v1/admin/users/:id
DELETE /api/v1/admin/users/:id/sessions        ← Forced Logout
GET    /api/v1/admin/audit-log
GET    /api/v1/admin/queue-status
GET    /api/v1/admin/system-status
GET    /api/v1/admin/dead-letters
GET    /api/v1/admin/ai/suggestions
GET    /api/v1/admin/data-quality
```

### Phase 2 (reserviert – 501 Not Implemented)
```
/api/v1/time/...          ← Zeiterfassung
/api/v1/invoicing/...     ← Rechnungen
/api/v1/payroll/...       ← Lohnlauf
/api/v1/messaging/...     ← WhatsApp/SMS/LinkedIn
/api/v1/publishing/...    ← Multi-Channel Publishing
/api/v1/performance/...   ← 360-Grad, Reviews
/api/v1/development/...   ← E-Learning, Entwicklungspläne
/api/v1/absences/...      ← Ferien, Abwesenheiten
```

---

## 12. WORKER-ARCHITEKTUR

### Alle Pflicht-Worker Phase 1

**1. event-processor.worker.ts** – DER wichtigste
Liest fact_event_queue (status=pending), lädt dim_automation_rules, prüft circuit breaker, erzeugt Folgejobs, schreibt fact_event_log, setzt processed_at/worker_id/status.

**2. ai.worker.ts**
Klassifikationen (Generalist/Spezialist, Seniority, Culture Fit), Transkript-Zusammenfassungen, CV-Parsing, Dossier-Generierung. Alle Outputs über ai-write.policy.ts prüfen.

**3. embedding.worker.ts**
Chunking, Embeddings via OpenAI/Anthropic, alte Chunks deaktivieren (is_current=false), Reindex-Jobs.

**4. document.worker.ts**
OCR → CV-Parsing → Embedding Pipeline. Status-Updates auf fact_documents: none → pending → done/failed.

**5. threecx.worker.ts**
Call Events verarbeiten, Telefonnummer → fact_call_context lookup, Auto-History erstellen, Transkript-Workflow anstossen.

**6. outlook.worker.ts**
Mails synchronisieren, Thread-Zuordnung zu Kandidat/Kontakt/Account/Prozess, Anhänge als Dokumente erfassen.

**7. scraper.worker.ts**
Scraping-Ergebnisse verarbeiten, Änderungserkennung (new_person/person_left/new_job/role_changed), Events erzeugen.

**8. email.worker.ts** – E-Mail-Versand mit Retry

**9. notification.worker.ts** – Push/In-App/SMS

**10. reminder.worker.ts** – Fällige Reminders aus fact_reminders

**11. retention.worker.ts** – PII-Retention, Anonymisierung, data_retention_date prüfen

**12. analytics.worker.ts** – Materialized View Refresh, Snapshots

### Worker-Grundregeln
```typescript
// Alle Worker idempotent und fehlerresistent:
const safeWork = (name, handler) => boss.work(name, async (job) => {
  try { await handler(job) }
  catch (err) {
    logger.error({ err, jobName: name, jobId: job.id }, 'Worker error')
    Sentry.captureException(err)
    throw err  // PgBoss retried automatisch: 1min → 5min → 30min → Dead Letter
  }
})

// Heartbeat alle 5 Min (Monitoring):
await boss.schedule('worker-heartbeat', '*/5 * * * *')
```

---

## 13. INTEGRATIONEN

### 3CX (Telefonie) – Duale Integration

**A) CRM-Template (Server Side) – Screen-Pop & Call Journaling:**

```
  CRM-Template Import:
    → XML-Datei in 3CX Management Console hochladen
    → Admin → CRM Integration → Server Side → Add
    → Template definiert URL-Muster, Auth-Header und Feld-Mapping
    → Nach Import: API Key in Template-Konfiguration eintragen

  Auth: API Key (X-API-Key Header)
    → API Key wird in 3CX CRM-Template-Konfiguration eingetragen
    → Backend prüft X-API-Key gegen gespeicherten Key (timingSafeEqual)
    → Env: THREECX_CRM_API_KEY

  Endpunkte:
    GET  /api/3cx/lookup?number={phone}      ← Phone-Lookup für Screen-Pop
      Response: { candidateId, candidateName, accountId, accountName,
                  crmUrl, crmProtocolUrl }
      crmUrl:         https://ark-frontend-omega.vercel.app/candidates/{id} (Web)
      crmProtocolUrl: ark-crm://candidates/{id} (Electron Deep Link)
      MUSS GET sein – 3CX-Anforderung

    GET  /api/3cx/lookup-email?email={email} ← E-Mail-Lookup
      Sucht in dim_candidates_profile + dim_account_contacts

    POST /api/3cx/report-call                ← Call Journaling (Anruf loggen)
      Erstellt fact_history Eintrag
      Idempotenz via call_id als source_event_id
```

**B) Webhook (Event-basiert) – Echtzeit-Events + Transkription:**

```
  Webhook URL (in 3CX Management Console registriert):
    POST https://arkcrm-production.up.railway.app/api/3cx/webhook

  Auth: HMAC-Signatur (X-3CX-Secret Header)
    → Env: THREECX_WEBHOOK_SECRET

  Sicherheits-Schichten:
    1. X-3CX-Secret Header Verifikation (timingSafeEqual)
    2. IP-Whitelist (optional, Nice-to-have):
       → Wenn 3CX feste IP hat: THREECX_IP_WHITELIST in Env
       → Wenn nicht: API Key + HMAC reichen für Phase 1

  Webhook Replay Protection:
    → Timestamp im Payload prüfen: Requests älter als 5 Min ablehnen
    → Idempotenz via source_event_id (3CX Call-ID)

  Verarbeitung:
    POST /api/3cx/webhook ← Alle Events: call.received, transcript.ready, missed
      1. X-3CX-Secret Header verifizieren (timingSafeEqual)
      2. IP prüfen (wenn Whitelist konfiguriert)
      3. Timestamp-Freshness prüfen (max 5 Min alt)
      4. Event-Typ ermitteln (incoming/outgoing/missed/transcript)
      5. Telefonnummer → fact_call_context → Kandidat/Account auflösen
      6. IN EINER TRANSAKTION: fact_history Eintrag + Event in fact_event_queue
      7. Bei transcript: call.transcript_ready → AI Worker → ai_summary
      8. Idempotenz via source_event_id = 3CX Call-ID (ON CONFLICT DO NOTHING)
```

### Outlook / Microsoft Graph
```
  Produktiv-Konfiguration:
    Azure Tenant:   (aus Azure Portal → Entra ID → Übersicht)
    Redirect URI:   https://arkcrm-production.up.railway.app/api/outlook/auth/callback
      (in Azure App Registration fix registriert – NICHT unter /api/v1/!)
    Architektur:    Individuelle User-Tokens (jeder Mitarbeiter OAuth-verbindet sein persönliches Outlook-Postfach)

  IDs und Secrets:
    → OUTLOOK_TENANT_ID, OUTLOOK_CLIENT_ID, OUTLOOK_CLIENT_SECRET
      aus Azure Portal → Entra ID → App-Registrierungen entnehmen
    → NIEMALS in Dokumenten oder Code festschreiben
    → Nur in Railway Env oder Secret Store

  Berechtigungen (Delegated, bereits eingerichtet):
    Mail.Read · Mail.ReadBasic · Mail.Send
    Calendars.ReadWrite                         ← Kalender bidirektional
    offline_access                              ← Refresh Token für dauerhaften Zugriff

  OAuth2-Flow:
    POST /api/v1/integrations/outlook/connect   ← Leitet zu Microsoft-Login
    GET  /api/outlook/auth/callback             ← Azure Redirect URI (KEIN /v1/!)
      → Code gegen Access + Refresh Token tauschen
      → Tokens als secret_ref in Railway/Vault speichern (NIE Klartext in DB)
      → dim_integration_tokens: secret_ref + token_fingerprint (SHA-256)

  Individuelle User-Tokens (Architektur-Entscheidung 2026-04-17):
    - Jeder Mitarbeiter OAuth-verbindet sein persönliches Outlook-Postfach einmalig
    - Token + Refresh-Token pro User in dim_integration_tokens (secret_ref)
    - Kein Shared-Mailbox-Zwischenschritt (ursprünglich geplante „Phase 1" verworfen)
    - Mail-Sync, Kalender-Sync, Send-as laufen im Kontext des jeweiligen User-Postfachs
    - Historie-Events sauber pro Mitarbeiter zugeordnet
    - Onboarding: neuer Mitarbeiter → Erst-Login → OAuth-Flow → fertig

  Sync-Scope (was bewusst NICHT synchronisiert wird):
    - Interne Team-Mails (zwischen Mitarbeitern) → kein Sync
    - Newsletter, Werbemails, automatische Benachrichtigungen → kein Sync
    - Nur synchronisiert: Mails die Kandidaten-/Account-Email-Adressen enthalten
    - Datenschutz: Mitarbeiter-interne Kommunikation bleibt out-of-scope

  Kalender-Integration (Calendars.ReadWrite):
    - Teams-Meetings + Termine direkt aus CRM erstellen
    - Termine zu Prozessen/Kandidaten verknüpfen

  Mail-Sync:
    fact_history: email_subject, email_message_id (body_html nur wenn nicht PII-kritisch)
    Event: email.received → outlook.worker → Zuordnung zu Kandidat/Account
    Idempotenz via email_message_id (source_event_id = MS Graph Message-ID)
```

### LinkedIn Browser Extension
```
POST /api/v1/candidates/linkedin-import
1. Duplikat-Check via linkedin_url
2. 202 Accepted + PgBoss Job für Verarbeitung
3. Worker: Kandidat anlegen + Embedding triggern
```

### Power BI
```
- Eigener read-only DB-User: ark_powerbi
- GRANT SELECT nur auf v_powerbi_* Views und dim_date
- Kein Zugriff auf operative Tabellen
- Tenant-Filter ist bereits in den Views eingebaut
```

---

## 14. AI / LLM INTEGRATION

### AI Governance (PFLICHT)
```typescript
// policies/ai-write.policy.ts
export const checkWritePolicy = async (entityType, fieldName) => {
  const policy = await getPolicyFromCache(entityType, fieldName)
    ?? await getPolicyFromCache(entityType, '*')
  if (!policy || policy.policy_type === 'forbidden')
    throw new ForbiddenError(`AI darf ${fieldName} auf ${entityType} nicht schreiben`)
  return policy
}
// 'suggest_only'       → via fact_ai_suggestions, Mensch entscheidet
// 'auto_after_review'  → nach Human-Review schreiben
// 'auto_allowed'       → direkt (nur ai_summary, ai_action_items, ai_red_flags)
// 'forbidden'          → nie (z.B. is_do_not_contact, candidate_stage)
```

### LLM-Aufrufe (Provider-abstrakt via Adapter)
```
Adapter: adapters/llm/openai.adapter.ts + anthropic.adapter.ts
Prompt Templates aus dim_prompt_templates (versioniert!)
PII vor LLM-Call reduzieren (DSGVO)
Outputs: fact_ai_classifications / fact_ai_suggestions / fact_history.ai_*
NIEMALS direkt in Core-Tabellen schreiben
```

### RAG
```
1. Text chunken → dim_embedding_chunks
2. Embeddings berechnen → fact_embeddings (pgvector 1536d)
3. Alte Embeddings: is_current=false
4. Semantische Suche: ivfflat cosine similarity
5. Tenant-Filter auf allen RAG-Abfragen (PFLICHT)
```

### Matching
```
7 Teil-Scores: sparte/function/salary/location/skills/availability/experience
Scores historisiert (is_current), Erklärung in match_breakdown_json
GET /api/v1/matching/explain/:matchId – Score NICHT als Blackbox
Trigger: Skill-Update, Stage-Change, Dokument-Upload, Briefing-Änderung
```

---

## 15. DOKUMENT-VERARBEITUNG & UPLOAD-SICHERHEIT

```typescript
// POST /api/v1/documents/upload – PFLICHT-Checks:
// 1. MIME-Type via file magic bytes prüfen (nicht nur Extension)
// 2. Max-Grösse: 20 MB Default
// 3. Erlaubte Typen: PDF, DOCX, XLSX, JPG, PNG
// 4. File Hash SHA-256 → file_hash in fact_documents (Duplikat-Erkennung)
// 5. Virus-Scan (OBLIGATORISCH – nicht optional!)
//    Begründung (Manus AI): Dokumente kommen von externen Quellen (Kandidaten, Scraper).
//    Ein infiziertes PDF könnte Mitarbeiter-Workstations kompromittieren.
//    Implementierung: ClamAV-Container auf Railway ODER externer Dienst (Cloudmersive, VirusTotal API)
//    Datei bleibt in Quarantäne bis Scan abgeschlossen → embedding_status='quarantine'
//    Bei Fund: fact_documents.quarantine_status='infected', Uploader benachrichtigen
// 6. ERST NACH ALLEN CHECKS: Upload zu Supabase Storage
// 7. Dann: fact_documents INSERT + document.uploaded Event (eine Transaktion!)

// POST /api/v1/documents/:id/reparse
// Manuelles Re-Triggern von OCR/Parsing/Embedding
// Sinnvoll wenn CV-Parser verbessert wurde
```

---

## 16. ERROR HANDLING & LOGGING

### Error-Klassen
```typescript
export class AppError extends Error {
  constructor(public message: string, public statusCode: number, public code: string, public fields?: Record<string, string>) { super(message) }
}
export class ValidationError    extends AppError { constructor(m, f?) { super(m, 400, 'VALIDATION_ERROR', f) } }
export class UnauthorizedError  extends AppError { constructor(m='Nicht authentifiziert') { super(m, 401, 'UNAUTHORIZED') } }
export class ForbiddenError     extends AppError { constructor(m='Keine Berechtigung') { super(m, 403, 'FORBIDDEN') } }
export class NotFoundError      extends AppError { constructor(e='Ressource') { super(`${e} nicht gefunden`, 404, 'NOT_FOUND') } }
export class ConflictError      extends AppError { constructor(m) { super(m, 409, 'CONFLICT') } }
export class UnprocessableError extends AppError { constructor(m) { super(m, 422, 'UNPROCESSABLE') } }
```

### Globaler Error Handler
```typescript
export const errorHandler = (err, req, reply) => {
  if (err instanceof AppError) {
    logger.warn({ err, requestId: req.id }, 'Operational error')
    return reply.status(err.statusCode).send({ success: false, data: null,
      error: { code: err.code, message: err.message, fields: err.fields ?? null } })
  }
  logger.error({ err, requestId: req.id }, 'Unhandled error')
  Sentry.captureException(err)
  return reply.status(500).send({ success: false, data: null,
    error: { code: 'INTERNAL_ERROR', message: 'Interner Serverfehler', fields: null }
    // NIEMALS: err.stack, err.message, DB-Details
  })
}
```

### Pino Logging mit PII-Redaction
```typescript
export const logger = pino({
  level: process.env.LOG_LEVEL ?? 'info',
  redact: {
    paths: [
      'req.headers.authorization', '*.password', '*.password_hash',
      '*.email', '*.email_1', '*.email_2',
      '*.phone_mobile', '*.phone_direct',
      '*.first_name', '*.last_name',
      '*.transcript_text', '*.ai_summary',
      '*.salary*', '*.fee_amount',
    ],
    censor: '[REDACTED]'
  }
})
// Pflichtfelder pro Request-Log:
// requestId · tenantId · userId · method · path · statusCode · durationMs
```

---

## 17. SICHERHEIT

### Security Headers
```typescript
app.use(helmet({
  contentSecurityPolicy: { directives: { defaultSrc: ["'self'"], objectSrc: ["'none'"] } },
  frameguard: { action: 'deny' },            // X-Frame-Options: DENY
  noSniff: true,                              // X-Content-Type-Options: nosniff
  hsts: { maxAge: 31536000, includeSubDomains: true },
  referrerPolicy: { policy: 'no-referrer' }
}))
```

### Rate Limiting
```
Global:         100 Requests / 15 Min pro IP
Auth-Endpoints:  5 Versuche / 15 Min
AI-Endpoints:   20 Requests / Min (kostenintensiv)
Upload:         10 Uploads / Min pro User
```

### CORS
```typescript
const allowedOrigins = [process.env.VERCEL_URL, 'app://ark-crm', 'http://localhost:3000'].filter(Boolean)
// KEIN origin: '*' in Production
```

### Webhook-Signatur (HMAC – alle eingehenden Webhooks)
```typescript
const verifyWebhookSignature = (req, secret) => {
  const expected = crypto.createHmac('sha256', secret).update(JSON.stringify(req.body)).digest('hex')
  if (!crypto.timingSafeEqual(Buffer.from(req.headers['x-webhook-signature']), Buffer.from(expected)))
    throw new UnauthorizedError('Ungültige Webhook-Signatur')
}
```

---

## 18. AUDIT LOG

```typescript
// Immer in derselben Transaktion wie Business-Write:
await auditService.log({
  action: 'STAGE_CHANGE', entity: 'candidate', entityId: id,
  field: 'candidate_stage', oldValue: maskPII(old), newValue: maskPII(next),
}, ctx, trx)

// Pflicht-Einträge:
// CREATE · UPDATE · DELETE · STAGE_CHANGE · LOGIN · LOGIN_FAILED ·
// PERMISSION_DENIED · CROSS_TENANT_ATTEMPT · DATA_EXPORT · ANONYMIZE · RESTORE

// Suspicious Activity (is_suspicious=true + Sentry Alert):
// - failed logins > 3
// - Zugriff zwischen 00:00-05:00 Uhr
// - Cross-Tenant-Versuch
// - Ungewöhnlich hohe Request-Rate
```

---

## 19. PERFORMANCE

```typescript
// Kein N+1 – Join statt Loop:
supabase.from('ark.dim_candidates_profile')
  .select('id, full_name, candidate_stage, bridge_candidate_functions(function:dim_functions(id,function_name))')
  .eq('tenant_id', ctx.tenantId)

// Stammdaten 30 Min cachen:
const clusters = await getCachedStammdaten('dim_cluster', () =>
  supabase.from('ark.dim_cluster').select('id, cluster_name, parent_cluster_id'))

// CACHE-INVALIDIERUNGSSTRATEGIE (verbindlich):
//
// WER invalidiert wann:
//   → Admin ändert Stammdaten (dim_cluster, dim_functions, dim_focus, dim_edv etc.)
//     → Admin-Service ruft invalidateCache(key) nach erfolgreichem DB-Write auf
//   → Kein automatischer TTL-basierter Ablauf als einzige Strategie –
//     Stammdaten können sich zwischen 0 und 30 Min ändern, TTL ist nur Fallback.
//
// IMPLEMENTIERUNG (lib/cache.ts):
const CACHE: Map<string, { data: unknown; expiresAt: number }> = new Map()

export const getCachedStammdaten = async <T>(
  key: string,
  fetcher: () => Promise<T>,
  ttlMs = 30 * 60 * 1000
): Promise<T> => {
  const entry = CACHE.get(key)
  if (entry && entry.expiresAt > Date.now()) return entry.data as T
  const data = await fetcher()
  CACHE.set(key, { data, expiresAt: Date.now() + ttlMs })
  return data
}

export const invalidateCache = (key: string): void => {
  CACHE.delete(key)
  // Auch ohne key: invalidateCache() → CACHE.clear() bei globalem Reset
}

// MULTI-INSTANCE auf Railway (2+ Worker/API-Instanzen):
// → In-Memory Cache ist instanz-lokal – eine Instanz invalidiert nicht die anderen
// → Pragmatische Phase-1-Lösung: kurze TTL (30 Min) hält Drift begrenzt
// → Admin-Änderungen an Stammdaten sind selten (< 1x/Woche) – Drift akzeptabel
// → Falls Sofort-Konsistenz nötig: Railway-Restart nach Stammdaten-Änderung (manuell)
//    ODER DB-Polling der Stammdaten alle 5 Min statt In-Memory-Cache (einfachste Option)
// → Phase 2: Redis-basierter Distributed Cache wenn Railway auf 3+ Instanzen skaliert

// CACHE BYPASS (Pflicht):
// → Sicherheitskritische Daten (Rollen, Permissions, AI-Policies): NIEMALS aus Cache
//    → immer frisch aus DB lesen (< 1 Query pro Request, unkritisch)
// → Audit-relevante Stammdaten (event_types, pii_classification): kein Cache
// → Nur reine Lookup-Stammdaten cachen: dim_cluster, dim_functions, dim_focus,
//    dim_focus, dim_edv, dim_education, dim_languages
//    (dim_skills_master ist DEPRECATED v1.2 — Skills werden über dim_focus abgebildet)

// Slow Query Logging (> 500ms):
if (Date.now() - start > 500) logger.warn({ duration, query: 'findCandidates' }, 'Slow query')

// Grosse Listen: cursor-basiert, nie unlimitiert
// SELECT: nur benötigte Felder
// Response: gzip/brotli komprimieren
```

---

## 20. DATENSCHUTZ & COMPLIANCE (nDSG / DSGVO)

```typescript
// Anonymisierung (POST /api/v1/candidates/:id/anonymize):
await withTransaction(async (trx) => {
  await trx.query(`UPDATE ark.dim_candidates_profile SET
    first_name='Anonymisiert', last_name='Anonymisiert',
    email_1=null, phone_mobile=null, adresse=null, birth_date=null,
    linkedin_url=null, photo_url=null, anonymized_at=now()
    WHERE id=$1 AND tenant_id=$2`, [id, ctx.tenantId])
  // Transkripte, Briefings analog anonymisieren
  await eventService.emit('candidate.anonymized', id, ctx, trx)
  await auditService.log({ action: 'ANONYMIZE', ... }, ctx, trx)
})

// Datenexport (GET /api/v1/candidates/:id/export):
// Alle relevanten Tabellen → JSON → Audit Log

// Automatische Retention (retention.worker.ts täglich):
// data_retention_date < today() AND anonymized_at IS NULL → anonymize()
```

---

## 21. OBSERVABILITY & BETRIEB

### Pflicht-Monitoring
```
- Request IDs in allen Logs und Responses
- Strukturierte JSON-Logs (Pino)
- Sentry: Error Tracking + Alerting
- Health: /health/live, /health/ready, /health/dependencies
- Queue: Dead Letter Rate, Länge, Retry-Häufigkeit
- Worker Heartbeats alle 5 Min
- DB Slow Query Monitoring (> 500ms)
- AI Token-Verbrauch und Kosten pro Provider tracken
- Embedding Job Status
- Scraper Änderungsvolumen
- Webhook Fehlerquote
- Circuit Breaker Trip-Events
```

---

## 22. TESTING-STRATEGIE

```
UNIT TESTS (Pflicht):
  - Alle Statusmaschinen (erlaubte / verbotene Übergänge)
  - Alle Zod-Validierungsschemas
  - AI-Write-Policy Enforcement (ai-write.policy.ts)
  - Visibility Policies, Utility-Funktionen

INTEGRATION TESTS (Pflicht):
  - Service Layer gegen Test-DB
  - Business Write + Event Insert in einer Transaktion
  - Role Checks (403 bei falscher Rolle)
  - AI Suggestion Flow (suggest → accept → Core-Write)
  - Stage Change Flow mit ungültigen Übergängen
  - Soft Delete + Restore
  - Cross-Tenant Blocking (403)

API TESTS (Pflicht):
  - Auth (Login, Refresh, Logout)
  - Pagination und Filter
  - Alle Fehler-Statuscodes (401/403/404/409/422)
  - Rate Limiting
  - Upload-Validierung (MIME, Grösse)

WORKER TESTS (Pflicht):
  - Idempotente Verarbeitung (doppelter Event = keine doppelte Aktion)
  - Retry-Logik und Exponential Backoff
  - Dead Letter Verhalten
  - Circuit Breaker Trip
  - Externe API-Fehler (3CX down, LLM timeout)

SECURITY TESTS (Pflicht):
  - Cross-Tenant Blocking
  - Verbotene Rollen
  - Manipulierte JWTs
  - Webhook-Signatur-Fehler
  - SQL Injection Versuche
```

---

## 23. DEPLOYMENT (RAILWAY)

### Services
```
ark-api      → src/app.ts            (Haupt-API)
ark-workers  → src/workers/index.ts  (Job-Queue, selber Code, anderer Entry Point)
```

### Environment Variables
```bash
DATABASE_URL=postgresql://...
SUPABASE_URL=https://...
SUPABASE_SERVICE_ROLE_KEY=...   # Nur Backend – nie Frontend!
JWT_SECRET=...                  # Min 256-bit random
JWT_EXPIRES_IN=3600
REFRESH_TOKEN_EXPIRES_IN=604800

# OpenAI / Anthropic
OPENAI_API_KEY=...
ANTHROPIC_API_KEY=...

# 3CX Telefonie (duale Integration)
THREECX_WEBHOOK_SECRET=...      # HMAC Secret für Webhook Auth (X-3CX-Secret)
THREECX_CRM_API_KEY=...         # API Key für CRM-Template Auth (X-API-Key)
THREECX_BASE_URL=...            # z.B. https://pbx.example.ch:5001 (kommt von IT)
THREECX_CLIENT_ID=...           # OAuth2 aus 3CX Management Console (kommt von IT)
THREECX_CLIENT_SECRET=...       # OAuth2 aus 3CX Management Console (kommt von IT)
THREECX_IP_WHITELIST=...        # Optional: feste IP der 3CX-Instanz (kommt von IT)

# Microsoft 365 / Outlook (Azure App Registration)
# WICHTIG: IDs aus Azure Portal → Entra ID → App-Registrierungen entnehmen
# NIEMALS echte IDs in Dokumenten oder Code festschreiben
OUTLOOK_TENANT_ID=...           # Verzeichnis-ID (Mandanten-ID) aus Azure Portal
OUTLOOK_TENANT_DOMAIN=...       # z.B. organisation.onmicrosoft.com
OUTLOOK_CLIENT_ID=...           # Anwendungs-ID (Client-ID) aus App Registration
OUTLOOK_CLIENT_SECRET=...       # Client Secret aus Certificates & Secrets
OUTLOOK_REDIRECT_URI=https://arkcrm-production.up.railway.app/api/outlook/auth/callback
# (OUTLOOK_SHARED_ACCOUNT entfernt 2026-04-17 — Architektur-Umstellung auf individuelle User-Tokens)

# Monitoring
SENTRY_DSN=...

# App
NODE_ENV=production
LOG_LEVEL=info
PORT=3000
ALLOWED_ORIGINS=https://ark-frontend-omega.vercel.app,app://ark-crm
BACKEND_URL=https://arkcrm-production.up.railway.app
```

### CI/CD
```yaml
# GitHub Actions: Test → Type-Check → Deploy
on: [push]
jobs:
  test: npm ci && npm run type-check && npm test
  deploy: railwayapp/railway-github-action@v1
```

---

## 24. BUILD-REIHENFOLGE (7 WELLEN)

**Welle 1: Plattform-Fundament** ✅ COMPLETED + AUDITED
App Bootstrap, Auth, Request-Kontext, Logging, Error Handling, DB-Layer, Queue-Layer, Health Checks, Config & Secrets

**Welle 2: Core CRM** ✅ COMPLETED + AUDITED (45/45 Checks)
Candidates, Accounts, Contacts, Jobs, Mandates, Processes, History, Documents

**Welle 3: Event- und Automation-Spine** ✅ COMPLETED + AUDITED (25/25 Checks)
Event Queue Services, Event Processor Worker, Automation Rules, Notifications, Audit Integration

**Welle 4: AI und RAG** ✅ COMPLETED
AI Adapter (OpenAI + Anthropic), Suggestion Flow, Classification Flow, Embedding Worker, Search (tsvector/tsquery + pg_trgm), RAG Query (pgvector), Matching Services (7 Teil-Scores)

**Welle 5: Integrationen** ⬚ PENDING
3CX, Outlook, Scraper, LinkedIn Browser Extension, Webhooks

**Welle 6: Analytics und Marktintelligenz** ⬚ PENDING
Reporting Layer, Power BI Exporte, Markt-Snapshots, Organigramm-Änderungen

**Welle 7: Phase 2 Module** ⬚ PENDING
Billing, Buchhaltung (Periodenabschluss-Lock zuerst!), Zeiterfassung, HR/Dev, Payroll, Publishing

---

## 25. GRÖSSTE RISIKEN WENN FALSCH GEBAUT

```
1. CRUD statt Event Spine
   → Automationen, Auditierbarkeit und Phase-2-Erweiterbarkeit brechen

2. AI zu viel Macht geben
   → Datenmüll, Vertrauensverlust, Compliance-Risiken

3. tenant_id nicht hart genug ziehen
   → Security Incident, potenzieller Datenschutzverstoss

4. Controller fett machen (Business Logic im Controller)
   → Alles untestbar und chaotisch

5. Integrationen direkt in Business Logic mischen
   → Jede Änderung an 3CX/Outlook/Social kostet Wochen

6. Search, RAG und Matching vermischen
   → Klarheit, Performance und Nachvollziehbarkeit verloren

7. Analytics direkt auf Operativ-Abfragen bauen
   → Dashboards langsam, DB unter Last

8. Keine Backpressure im Event System
   → Massen-Scraping oder Bulk-Updates kippen die Plattform

9. Webhook-Signaturen nicht prüfen
   → Jeder kann beliebige Events injecten

10. Upload-Sicherheit ignorieren
    → Malware in Supabase Storage, MIME-Spoofing-Angriffe
```

---

## 26. PHASE-2-KOMPATIBILITÄT

```typescript
// 1. fact_mandate_billing.invoice_number: NIE direkt verwenden
//    → immer über mandateBillingService abstrahieren, FK kommt in Phase 2

// 2. Phase-2-Router JETZT reservieren (501 Not Implemented):
app.register(timeRouter,      { prefix: '/api/v1/time' })
app.register(invoicingRouter, { prefix: '/api/v1/invoicing' })
app.register(payrollRouter,   { prefix: '/api/v1/payroll' })
app.register(messagingRouter, { prefix: '/api/v1/messaging' })

// 3. Periodenabschluss-Lock: ERSTES was in Phase 2 implementiert wird
//    Kein Buchungssatz ohne offene Periode (fact_accounting_periods.locked_at IS NULL)

// 4. commission_rate in dim_mitarbeiter: nur Phase-1-Annäherung
//    Phase 2 Lohnlauf baut darauf auf – keine komplexe Lohnlogik jetzt
```

---

## 27. FEATURE FLAGS

Feature Flags erlauben risikoarme Deployments. Neue AI-Features, Integrationen und Worker-Aktionen werden graduell aktiviert statt alles-oder-nichts deployed.

```typescript
// config/featureFlags.ts
export const FEATURE_FLAGS = {
  enableAiSuggestionsWrite:    process.env.FF_AI_SUGGESTIONS_WRITE === 'true',
  enableAiAutoClassify:        process.env.FF_AI_AUTO_CLASSIFY === 'true',
  enableScraperImport:         process.env.FF_SCRAPER_IMPORT === 'true',
  enable3cxIntegration:        process.env.FF_3CX_INTEGRATION === 'true',
  enableOutlookSync:           process.env.FF_OUTLOOK_SYNC === 'true',
  enableMarketIntelligence:    process.env.FF_MARKET_INTELLIGENCE === 'true',
  enableEmbeddings:            process.env.FF_EMBEDDINGS === 'true',
  enableSemanticSearch:        process.env.FF_SEMANTIC_SEARCH === 'true',
} as const

// Verwendung in Worker / Service:
if (!FEATURE_FLAGS.enable3cxIntegration) {
  logger.warn('3CX Integration disabled via feature flag')
  return
}

// Tenant-spezifische Flags (Phase 2):
// → dim_tenant_features Tabelle: tenant_id + feature_key + is_enabled
// → ermöglicht A/B Testing und schrittweises Rollout pro Kunde
```

---

## 28. BULK OPERATIONS

Bei 50'000 Kandidaten, Massen-Scraping und 100k Skills reichen Einzel-Endpunkte nicht. Bulk-Operationen brauchen immer Dry Run, Preview und Fehlerbericht.

```
POST   /api/v1/candidates/bulk-import         ← CSV/Excel Import mit Preview
POST   /api/v1/candidates/bulk-stage-change   ← Viele Kandidaten auf einmal
POST   /api/v1/candidates/bulk-archive        ← Soft Delete Batch
POST   /api/v1/candidates/bulk-restore
POST   /api/v1/candidates/bulk-merge-prepare  ← Duplikat-Review vorbereiten

POST   /api/v1/skills/bulk-assign             ← Kandidat → Skills Batch
POST   /api/v1/scraper/bulk-review            ← Approve/Reject Scraper-Items
POST   /api/v1/matching/bulk-recalculate      ← Alle Scores neu berechnen
POST   /api/v1/rag/bulk-reindex               ← Alle Embeddings neu generieren

Pflicht-Pattern für alle Bulk-Operationen:
  1. ?dry_run=true → Preview ohne Schreiben (Response: was würde passieren)
  2. Validierungsbericht: { total: 500, valid: 487, invalid: 13, errors: [...] }
  3. Asynchron via PgBoss (202 Accepted + jobId)
  4. Fortschritt abrufbar: GET /api/v1/jobs/:jobId/status
  5. Rollback-Mechanismus bei kritischen Fehlern
  6. Jede Bulk-Aktion erzeugt einen übergeordneten Audit-Eintrag
```

---

## 29. DOMAIN ERROR KATALOG

Einheitliche Fehlercodes damit das Frontend auf spezifische Fehler reagieren kann.

```typescript
// lib/errorCodes.ts
export const ERROR_CODES = {
  // Auth
  INVALID_CREDENTIALS:       'AUTH_001',
  ACCOUNT_LOCKED:            'AUTH_002',
  TOKEN_EXPIRED:             'AUTH_003',
  TOKEN_REVOKED:             'AUTH_004',
  INSUFFICIENT_ROLE:         'AUTH_005',

  // Tenant
  TENANT_MISMATCH:           'TENANT_001',
  CROSS_TENANT_ATTEMPT:      'TENANT_002',

  // Validation
  VALIDATION_ERROR:          'VAL_001',
  INVALID_UUID:              'VAL_002',
  INVALID_ENUM:              'VAL_003',
  DATE_RANGE_INVALID:        'VAL_004',

  // Concurrency
  VERSION_CONFLICT:          'CONC_001',

  // Business Rules
  INVALID_STAGE_TRANSITION:  'BIZ_001',
  CANDIDATE_ALREADY_MERGED:  'BIZ_002',
  MANDATE_ALREADY_CLOSED:    'BIZ_003',
  PERIOD_LOCKED:             'BIZ_004',   // Phase 2 Buchhaltung

  // AI Governance
  AI_POLICY_VIOLATION:       'AI_001',
  AI_POLICY_FORBIDDEN:       'AI_002',
  AI_SUGGESTION_EXPIRED:     'AI_003',

  // Integrations
  WEBHOOK_SIGNATURE_INVALID: 'INT_001',
  WEBHOOK_TIMESTAMP_EXPIRED: 'INT_002',
  INTEGRATION_TOKEN_INVALID: 'INT_003',

  // Resources
  NOT_FOUND:                 'RES_001',
  DUPLICATE:                 'RES_002',
  SOFT_DELETED:              'RES_003',
} as const

// Verwendung:
throw new ConflictError('VERSION_CONFLICT: Datensatz wurde geändert', ERROR_CODES.VERSION_CONFLICT)
throw new UnprocessableError('Stage-Wechsel nicht erlaubt', ERROR_CODES.INVALID_STAGE_TRANSITION)
```

---

## 30. MIGRATIONS-STRATEGIE & SEEDS

```
Migrations-Tool: SQL-First (direkt in Supabase) oder Drizzle / Flyway
Lokale Dev DB:   Supabase CLI (supabase start) oder Docker PostgreSQL
Environments:    local → dev → staging → prod (railway environments)

Seed-Strategie:
  1. Stammdaten Seeds (einmalig, dann nie mehr via App geändert):
     - dim_cluster, dim_functions, dim_focus, dim_edv, dim_education,
       dim_sector, dim_sparte, dim_languages, dim_date (2020-2035)
     - 100k Skills → fact_function_skill_premium
     - dim_ai_write_policies (vordefinierte Policies)
     - dim_event_types (alle definierten Events)
     - dim_pii_classification (alle PII-Felder)
  2. Test Seeds (für CI/CD Tests):
     - Synthetische Kandidaten, Accounts, Jobs ohne echte PII
     - Anonymisierte oder komplett fiktive Daten
  3. Migration Prozedere:
     - Migration Datei in /migrations/YYYY-MM-DD_description.sql
     - Review via PR vor jedem Staging-Deploy
     - Rollback-SQL als Kommentar in jedem Migration-File
     - supabase gen types typescript nach jeder Migration → CI-Step

Backup & Recovery (DSGVO/nDSG-Pflicht):
  → Supabase Point-in-Time Recovery (PITR) aktivieren
  → Tägliche automatische Backups (Supabase Pro Feature)
  → Recovery Time Objective (RTO): max 1 Stunde
  → Recovery Point Objective (RPO): max 1 Stunde
  → Monatlicher Recovery-Test (tatsächlich wiederherstellen und prüfen)
  → Backup-Aufbewahrung: 30 Tage für operative Daten, 10 Jahre für Buchungsdaten (Phase 2)
```

---

## 31. API DOKUMENTATION (OpenAPI / Swagger)

```typescript
// @fastify/swagger generiert automatisch aus Zod-Schemas:
import fastifySwagger from '@fastify/swagger'
import fastifySwaggerUI from '@fastify/swagger-ui'

await app.register(fastifySwagger, {
  openapi: {
    info: { title: 'ARK CRM API', version: '1.0.0', description: 'ARK Executive Search CRM' },
    servers: [{ url: 'https://arkcrm-production.up.railway.app' }],
    components: {
      securitySchemes: { bearerAuth: { type: 'http', scheme: 'bearer', bearerFormat: 'JWT' } }
    },
    security: [{ bearerAuth: [] }]
  }
})

await app.register(fastifySwaggerUI, {
  routePrefix: '/docs',                   // nur in non-prod!
  uiConfig: { docExpansion: 'list' }
})

// Endpunkte automatisch dokumentiert wenn Zod-Schema vorhanden
// → GET /docs      → Swagger UI (nur staging/dev, in Prod: 404 / komplett deaktiviert)
// → GET /docs/json → OpenAPI JSON (in Prod: nur hinter Admin-Auth oder gar nicht exposed)

// Prod-Regel: /docs wird via NODE_ENV-Check komplett nicht registriert.
// /docs/json in Prod nur falls explizit gebraucht – dann hinter requireRoles(['Admin'])
if (process.env.NODE_ENV !== 'production') {
  await app.register(fastifySwagger, swaggerConfig)
  await app.register(fastifySwaggerUI, swaggerUIConfig)
}

// Shared Types für Frontend (Codegen):
// → aus OpenAPI JSON können TypeScript-Types für Frontend generiert werden
// → supabase gen types typescript als fixer CI-Step nach DB-Änderungen
```

---

## 32. LOCAL DEVELOPMENT MIT EXTERNEN WEBHOOKS

3CX und Azure Redirect URI brauchen eine öffentliche URL. Ohne Tunnel funktionieren lokale Integration-Tests nicht.

```bash
# package.json scripts:
{
  "scripts": {
    "dev":        "tsx watch src/app/server.ts",
    "dev:tunnel": "concurrently \"npm run dev\" \"ngrok http 3000\"",
    "dev:workers":"tsx watch src/workers/index.ts"
  }
}

# ngrok konfigurieren (.ngrok.yml):
# authtoken: [ngrok token aus Env]
# tunnels:
#   ark-api:
#     proto: http
#     addr: 3000
#     inspect: true

# Lokale Test-URLs:
# 3CX Webhook:      https://xxx.ngrok-free.app/api/3cx/webhook
# Outlook Callback: https://xxx.ngrok-free.app/api/outlook/auth/callback
# → In 3CX Management Console temporär als Test-URL eintragen
# → In Azure App Registration als zusätzliche Redirect URI eintragen (für Dev)

# WICHTIG: ngrok-URL nie in Production-Konfiguration eintragen
# WICHTIG: ngrok-Session hat Timeout → neu starten bei Inaktivität
```

---

## 33. POSTGRES-TO-APPERROR MAPPER

Kein manuelles Fehler-Handling in jedem Repository. Ein zentraler Mapper übersetzt Postgres-Fehlercodes automatisch in saubere AppErrors.

```typescript
// lib/pgErrorMapper.ts
import { DatabaseError } from 'pg'

export const mapPgError = (err: unknown): never => {
  if (err instanceof DatabaseError) {
    switch (err.code) {
      case '23505':  // unique_violation
        // WICHTIG: err.detail NICHT direkt an Client – könnte DB-Struktur leaken
        throw new ConflictError('Duplikat: Eintrag existiert bereits', 'RES_002')
      case '23503':  // foreign_key_violation
        throw new UnprocessableError('Referenz existiert nicht', 'VAL_004')
      case '23514':  // check_violation
        throw new UnprocessableError('Constraint verletzt', 'VAL_003')
      case '40001':  // serialization_failure (Retry sinnvoll)
        throw new ConflictError('Bitte nochmals versuchen', 'CONC_002')
      case '55P03':  // lock_not_available
        throw new ConflictError('Ressource gesperrt', 'CONC_003')
      default:
        // Interne Details (pgCode, pgMessage) NUR ins Log – nie an Client
        logger.error({ pgCode: err.code }, 'Unhandled DB error')
        throw new AppError('Datenbankfehler', 500, 'DB_ERROR')
    }
  }
  throw err
}

// Verwendung in Repositories (DRY):
export const create = async (data, tenantId, trx) => {
  try {
    return await trx.query(`INSERT INTO ark.dim_candidates_profile ...`)
  } catch (err) {
    mapPgError(err)  // wirft automatisch den richtigen AppError
  }
}
```

---

## 34. ZOD-SCHEMA REUSE FÜR WORKER EVENT-PAYLOADS

Zod-Schemas nicht nur für `req.body` – auch Worker validieren ihre Event-Payloads. Kein Worker verarbeitet korrupte Daten still.

```typescript
// schemas/events/candidate.events.schema.ts
export const CandidateStageChangedPayloadSchema = z.object({
  from:      z.string().min(1),
  to:        z.string().min(1),
  changedBy: z.string().uuid(),
  reason:    z.string().optional(),
})

export const CallReceivedPayloadSchema = z.object({
  phoneNumber:  z.string().min(5),
  callId:       z.string().min(1),
  callType:     z.enum(['incoming', 'outgoing', 'missed']),
  duration:     z.number().optional(),
})

// Worker validiert immer zuerst:
boss.work('process-event', async (job) => {
  const event = await loadEvent(job.data.eventId, job.data.tenantId)

  // Payload gegen Schema validieren – wirft ZodError bei korrupten Daten:
  const payloadSchema = getPayloadSchema(event.event_type_name)
  const payload = payloadSchema.parse(event.payload_json)

  // Jetzt sicher weiterarbeiten mit typisiertem payload:
  await processEvent(event, payload)
})

// Zentrale Schema-Map:
const EVENT_PAYLOAD_SCHEMAS: Record<string, ZodSchema> = {
  'candidate.stage_changed': CandidateStageChangedPayloadSchema,
  'call.received':           CallReceivedPayloadSchema,
  'document.uploaded':       DocumentUploadedPayloadSchema,
  // ... alle Events
}
```

---

## 35. BACKPRESSURE & QUEUE-PRIORISIERUNG (konkret)

Das grösste operative Risiko bei Massen-Scraping, Bulk-Imports und AI-Jobs. Ohne Backpressure kann ein einziger Burst die Queue lahmlegen.

```typescript
// Harte Grenzen (config/queueLimits.ts):
export const QUEUE_LIMITS = {
  maxConcurrentAiJobs:        5,    // LLM-Aufrufe teuer und langsam
  maxConcurrentEmbeddingJobs: 10,
  maxConcurrentScraperJobs:   3,    // pro Tenant
  maxConcurrentDocumentJobs:  10,
  perTenantHourlyAiQuota:     100,  // AI-Jobs pro Tenant und Stunde
  // ↑ Schutzmechanismus gegen Kostenexplosion: eine fehlerhafte Automation-Rule
  //   die in einer Endlosschleife LLM-Calls triggert, kostet sonst in Minuten
  //   hunderte CHF. Bei 100 Jobs/h und ~0.002 CHF/Call: max ~0.20 CHF/h pro Tenant.
  //   Alert bei > CHF 50/Tag (Abschnitt 36) erkennt globale Anomalien.
  reindexOnlyInMaintenanceWindow: true,  // Grosse Reindex-Jobs: 00:00-04:00
  scraperBurstLimit:          50,   // Max Änderungen pro Scraper-Run bevor Pause
} as const

// PgBoss Queue-Konfiguration mit Concurrency:
boss.work('ai-classify', { teamSize: QUEUE_LIMITS.maxConcurrentAiJobs }, aiClassifyHandler)
boss.work('ai-embed',    { teamSize: QUEUE_LIMITS.maxConcurrentEmbeddingJobs }, embedHandler)
boss.work('scrape-account', { teamSize: QUEUE_LIMITS.maxConcurrentScraperJobs }, scraperHandler)

// Priorisierte Queues (PgBoss priority-Feld):
// priority 0 (höchste): call.received, user-initiierte Actions
// priority 1:           email.received, document.uploaded
// priority 2:           AI Classification, Matching
// priority 3:           Embedding, Scraper
// priority 4 (niedrigste): Reindex, Cleanup, Analytics Refresh

// Per-Tenant Quota prüfen im Worker:
const checkTenantQuota = async (tenantId, jobType) => {
  const count = await getJobCountLastHour(tenantId, jobType)
  if (count >= QUEUE_LIMITS.perTenantHourlyAiQuota) {
    logger.warn({ tenantId, jobType }, 'Tenant AI quota exceeded')
    throw new Error('QUOTA_EXCEEDED')  // PgBoss retried nach backoff
  }
}

// Globaler Kill Switch (Feature Flag):
if (!FEATURE_FLAGS.enableScraperImport) { logger.warn('Scraper disabled'); return }
```

---

## 36. SLOs & BETRIEBSZIELE

```
LATENZ-ZIELE:
  99% aller API Requests:          < 500ms
  95% aller API Requests:          < 200ms
  Search / RAG Queries:            < 2s (99%)
  Analytics Endpoints:             < 5s (99%)

EVENT-VERARBEITUNGS-ZIELE:
  call.received → fact_history:    < 30 Sekunden
  call.transcript_ready → Summary: < 3 Minuten
  document.uploaded → embedded:    < 5 Minuten
  scrape.change → Notification:    < 5 Minuten
  AI Classification (async):       < 10 Minuten
  Kandidaten-Matching Update:      < 15 Minuten

ALERT-SCHWELLEN (sofort → PagerDuty / Sentry):
  DLQ Rate:         > 5 Jobs in 15 Min → Alert
  Event Lag:        > 50 Events pending > 10 Min → Alert
  Worker Error:     > 10% Error Rate in 5 Min → Alert
  API Error Rate:   > 1% 5xx in 5 Min → Alert
  Health Ready:     DOWN → sofort Alert
  DB Slow Query:    > 2s → Alert (> 500ms → Log)
  AI Cost:          > CHF 50/Tag → Alert

DEGRADED-DEFINITION:
  System gilt als "degraded" wenn:
  - Event-Verarbeitung > 30 Min Lag
  - AI-Features teilweise nicht verfügbar
  - Response-Zeit > 2s p99

INCIDENT-DEFINITION:
  System gilt als "down" wenn:
  - /health/ready gibt 500 zurück
  - DB nicht erreichbar
  - Keine Events werden verarbeitet (Event Processor Worker down)
```

---

## 37. DATA QUALITY ALS BACKEND-CAPABILITY

Nicht nur Admin-Monitoring – sondern ein echtes Backend-Modul mit Pipelines.

```
DUPLICATE DETECTION PIPELINE:
  1. Bei Kandidaten-Import (LinkedIn, Scraper):
     → Name + Telefon + Email Normalisierung
     → Fuzzy-Match gegen bestehende Kandidaten
     → Score > 85% → fact_data_quality_issues (type='potential_duplicate')
     → Notification an zuständigen Candidate Manager

  2. Bei Account-Scraping:
     → Firmennamen-Normalisierung (GmbH, AG, SA Varianten)
     → Domain-Matching
     → Organigramm-Duplikate verhindern

NORMALISIERUNG (vor jedem DB-Insert):
  Telefonnummern:  E.164 Format (+41791234567)
  Email:           lowercase, trim
  Firmennamen:     "ACME GmbH" → normalisiert für Matching
  Kanton:          "Zürich" / "ZH" / "Zurich" → immer dim_cluster.cluster_short_id
  Skills:          DEPRECATED v1.2 — Skills werden über dim_focus abgebildet

SOURCE OF TRUTH PRIORITÄTEN (bei Konflikten Scraper vs. CRM):
  Priorität 1: Manuell von Mitarbeiter erfasst
  Priorität 2: Browser Extension Import (LinkedIn)
  Priorität 3: Scraper-Daten
  → Scraper überschreibt nie manuell erfasste Daten
  → Bei Abweichung: fact_data_quality_issues (type='conflict')

ENDPUNKTE:
  GET  /api/v1/admin/data-quality        ← Offene Issues
  POST /api/v1/admin/data-quality/:id/resolve
  GET  /api/v1/admin/data-quality/duplicates
  POST /api/v1/candidates/:id/merge-suggest ← AI-Merge-Vorschlag
```

---

## 38. CONTRACT TESTS FÜR PROVIDER

Bei 3CX, Outlook, LLM-Adaptern und Browser Extension sind externe API-Änderungen realistisch. Contract Tests erkennen Brüche früh.

```typescript
// tests/contracts/threecx.contract.test.ts
describe('3CX Webhook Contract', () => {
  it('should handle call-received event shape', () => {
    const fixture = loadFixture('threecx/call-received.json')
    const result = ThreeCxWebhookSchema.safeParse(fixture)
    expect(result.success).toBe(true)
  })

  it('should handle transcript-ready event shape', () => {
    const fixture = loadFixture('threecx/transcript-ready.json')
    expect(ThreeCxTranscriptSchema.safeParse(fixture).success).toBe(true)
  })
})

// tests/contracts/outlook.contract.test.ts
describe('Outlook Graph API Contract', () => {
  it('should parse email message shape', () => {
    const fixture = loadFixture('outlook/email-message.json')
    expect(OutlookEmailSchema.safeParse(fixture).success).toBe(true)
  })
})

// tests/contracts/llm.contract.test.ts
describe('LLM Provider Contract', () => {
  it('should parse OpenAI completion response', () => {
    const fixture = loadFixture('llm/openai-completion.json')
    expect(OpenAiCompletionSchema.safeParse(fixture).success).toBe(true)
  })
})

// Golden Files für CV-Parsing:
// tests/fixtures/cv-parsing/input-*.pdf + expected-output-*.json
// Worker-Test vergleicht Parsing-Ergebnis gegen Golden File

// Fixtures liegen in: tests/fixtures/{provider}/{event}.json
// CI: Fixtures aus letztem echten Provider-Response generieren + committen
// Bei Provider-Update: Tests schlagen fehl → bewusste Migration nötig
```

---

## 39. READ MODEL & PROJECTION STRATEGIE

Wann direkt operative Tabellen lesen und wann zwingend Views oder Materialized Views nutzen.

```
DIREKT OPERATIVE TABELLEN (erlaubt für):
  → CRUD Operationen (GET /candidates/:id, GET /processes/:id)
  → Einzelsatz-Abfragen mit bekanntem PK
  → Schreibvorgänge
  → Interne Service-Calls mit vollem Context

DEDIZIERTE READ VIEWS (Pflicht für):
  → /api/v1/processes/:id/timeline      ← v_process_timeline
  → /api/v1/analytics/pipeline          ← v_pipeline_summary
  → /api/v1/matching/explain/:matchId   ← v_match_explain
  → /api/v1/market/accounts/:id/organigram ← v_account_organigram

MATERIALIZED VIEWS (Pflicht für, werden via analytics.worker.ts refreshed):
  → Power BI Exports: mv_powerbi_kandidaten, mv_powerbi_prozesse, mv_powerbi_umsatz
  → Market Intelligence: mv_market_snapshot
  → Skill Economy: mv_skill_premium_rankings
  → Refresh: alle 4h via analytics.worker.ts oder on-demand via /analytics/refresh
  → REFRESH MATERIALIZED VIEW CONCURRENTLY (kein Table-Lock)

VERBOTEN:
  → Analytics-Abfragen direkt gegen 20 operative Tabellen joinen
  → Dashboard-Daten ungecacht direkt abfragen
  → Power BI direkt auf fact_process_core (zu teuer)
```

---

## 40. FIELD LEVEL PERMISSIONS

RBAC regelt Endpunkt-Zugriff – für sensible Felder braucht es zusätzlich Feldsichtbarkeit. Das ist kein optionales Prinzip, sondern ein verpflichtender Mechanismus: **jede Response-Serialisierung muss durch `filterFieldsByRole()` laufen**, bevor Daten den Controller verlassen. `roles` ist ein Array (Multi-Rollen-System) – Zugriff wird gewährt wenn mindestens eine Rolle das Feld sehen darf.

```typescript
// config/fieldPermissions.ts
export const FIELD_PERMISSIONS: Record<string, Rolle[]> = {
  // Kandidaten – sensible Felder:
  'candidate.salary_expectation':   ['Admin', 'Candidate_Manager'],
  'candidate.ai_red_flags':         ['Admin', 'Candidate_Manager'],
  'candidate.internal_notes':       ['Admin', 'Candidate_Manager'],
  'candidate.assessment_results':   ['Admin', 'Candidate_Manager'],
  'candidate.transcript_text':      ['Admin', 'Candidate_Manager'],
  'candidate.anonymized_at':        ['Admin'],

  // Prozesse:
  'process.fee_amount':             ['Admin'],
  'process.fee_percentage':         ['Admin'],
  'process.internal_comments':      ['Admin', 'Candidate_Manager'],

  // Mitarbeiter:
  'mitarbeiter.commission_rate':    ['Admin'],
  'mitarbeiter.salary':             ['Admin'],
}

// Repository-Schicht filtert Felder basierend auf Rolle:
export const filterFieldsByRole = <T extends object>(obj: T, roles: RoleKey[], resource: string): Partial<T> => {
  return Object.fromEntries(
    Object.entries(obj).filter(([key]) => {
      const permKey = `${resource}.${key}`
      const allowed = FIELD_PERMISSIONS[permKey]
      return !allowed || roles.some(r => allowed.includes(r))
    })
  ) as Partial<T>
}

// SERIALISIERER-BASIERTER MECHANISMUS (Pflicht):
// filterFieldsByRole() ist NICHT optional – es ist der letzte Schritt vor der Response.
// Mechanismus: Service → Repository gibt vollständiges Objekt zurück
//              → Controller ruft filterFieldsByRole(candidate, ctx.roles, 'candidate')
//              → Nur erlaubte Felder gehen in die Response

// candidates.controller.ts:
export const getById = async (req, reply) => {
  const candidate = await candidatesService.getById(req.params.id, req.context)
  const filtered  = filterFieldsByRole(candidate, req.context.role, 'candidate')
  return reply.send({ success: true, data: filtered })
}

// VERBOTEN:
// → candidate direkt ohne filterFieldsByRole() in Response schicken
// → Filterung im Service Layer (Service gibt vollständig zurück, Controller filtert)
// → Sensible Felder im SQL SELECT weglassen statt filterFieldsByRole() verwenden
//   (SQL-Ansatz ist fehleranfälliger – bei neuen Feldern vergisst man leicht den Ausschluss)

// PR-REVIEW PFLICHT:
// Jeder neue GET-Endpunkt der sensitive Entitäten (candidate, process, mitarbeiter)
// zurückgibt MUSS filterFieldsByRole() im Controller haben.
// → CI-Lint-Regel empfohlen: eslint-plugin-custom → no-unfiltered-sensitive-entity
```

---

## 41. REQUEST CONTEXT – ZENTRALER TYP

`ctx` taucht überall auf. Verbindliche TypeScript-Definition verhindert inkonsistente Nutzung.

```typescript
// types/requestContext.ts
export interface RequestContext {
  requestId:      string        // UUID, generiert pro Request
  correlationId:  string        // Durchgehend durch Event-Ketten
  tenantId:       string        // Aus JWT – nie aus Request
  userId:         string        // dim_crm_users.id
  sessionId:      string        // Für Audit Log
  role:           Rolle         // Aus JWT
  sparteId:       string        // Aus JWT
  sourceSystem:   'crm' | 'worker' | 'webhook' | 'admin'
  ipAddress:      string
  userAgent:      string
  impersonatedBy?: string       // Nur bei Admin-Impersonation (hart auditiert)
  featureFlags:   Readonly<typeof FEATURE_FLAGS>  // Flags zum Zeitpunkt des Requests
}

// Middleware setzt Context:
export const buildContext = (req): RequestContext => ({
  requestId:     req.id,
  correlationId: req.headers['x-correlation-id'] ?? req.id,
  tenantId:      req.jwtPayload.tenantId,
  userId:        req.jwtPayload.userId,
  sessionId:     req.jwtPayload.sessionId,
  role:          req.jwtPayload.roles,
  sparteId:      req.jwtPayload.sparteId,
  sourceSystem:  'crm',
  ipAddress:     req.ip,
  userAgent:     req.headers['user-agent'] ?? 'unknown',
  featureFlags:  FEATURE_FLAGS,  // globale Flags zum Zeitpunkt des Requests
})

// Context wird an ALLE Service/Repository-Aufrufe weitergegeben – nie rekonstruiert
```

---

## 42. ADMIN DIAGNOSE ENDPUNKTE (ERWEITERT)

```
Zusätzlich zu queue-status / system-status:

GET  /api/v1/admin/integrations/health
  → 3CX: letzter Webhook-Eingang, letzter Fehler, Token-Status
  → Outlook: Token-Expiry, letzter Sync, Fehlerquote
  → Scraper: letzter Run pro Account, Fehlerquote, offene Changes

GET  /api/v1/admin/circuit-breakers
  → Alle dim_automation_rules mit circuit_breaker_tripped=true
  → Trigger-Count pro Stunde/Tag
  → Letzter Trip-Zeitpunkt

POST /api/v1/admin/circuit-breakers/:ruleId/reset
  → Manueller Reset (bereits als Endpunkt definiert, hier als Admin-Kontext)

GET  /api/v1/admin/workers/health
  → Letzter Heartbeat pro Worker
  → Fehlerquote letzte Stunde
  → Aktuelle Queue-Tiefe pro Job-Typ

GET  /api/v1/admin/tokens/expiry
  → Alle dim_integration_tokens mit expires_at < now() + 7 Tage
  → Warnung: Outlook Token läuft in X Tagen ab

GET  /api/v1/admin/retention/pending
  → Kandidaten mit data_retention_date < today() AND anonymized_at IS NULL
  → Anzahl + Preview (ohne PII)
```

---

## 43. DOKUMENT-DOWNLOAD GOVERNANCE

Upload-Sicherheit ist stark. Download-Seite war noch offen.

```typescript
// GET /api/v1/documents/:id/download

// 1. Signed URL Generierung (Supabase Storage):
const signedUrl = await supabase.storage
  .from('crm-documents')
  .createSignedUrl(document.storage_path, 300)  // TTL: 5 Minuten

// TTL-Regeln:
//   Normale Dokumente:          300 Sek (5 Min)
//   Sensitive Dokumente (CV, Zeugnis, Assessment): 60 Sek (1 Min)
//   Transkripte:                60 Sek
//   Öffentliche Preview:        3600 Sek (1h) – nur für anonymisierte Derivate

// 2. Berechtigungsprüfung vor URL-Ausgabe:
const canDownload = checkFieldPermission(ctx.role, 'document', document.document_type)
if (!canDownload) throw new ForbiddenError('Keine Download-Berechtigung')

// 3. Download Audit (jeder Download wird geloggt):
await auditService.log({
  action: 'DOCUMENT_DOWNLOAD',
  entity: 'document',
  entityId: document.id,
  field: 'storage_url',
}, ctx)  // KEIN trx nötig – Audit auch ohne Business-Transaktion

// 4. Original vs. Derivat Retention:
//   Original:             niemals gelöscht, nur is_active=false bei Soft Delete
//   OCR-Text:             kann neu generiert werden → löschbar
//   Embeddings:           rekonstruierbar → bei Löschung deaktivieren
//   AI-Summary:           rekonstruierbar → soft delete

// 5. Preview (Browser-Ansicht ohne Download):
//   Nur für nicht-sensible Dokumente
//   Separate signed URL mit Content-Disposition: inline (statt attachment)
```

---

## 44. BEISPIEL-FLOWS (Onboarding & Dokumentation)

Für neue Entwickler – konkrete End-to-End-Flows durch das System.

```
FLOW 1: 3CX Call → History → AI Summary → Reminder
  1. 3CX sendet POST /api/3cx/webhook (call.received)
  2. IP-Whitelist + X-3CX-Secret geprüft
  3. Telefonnummer → fact_call_context → Kandidat/Account aufgelöst
  4. TRANSAKTION: fact_history (call_direction, duration) + call.received Event INSERT
  5. COMMIT
  6. event-processor.worker.ts: lädt dim_automation_rules für call.received
  7. Rule "Auto-Summary bei bekanntem Kandidat": trigger_ai Job → PgBoss
  8. ai.worker.ts: Prompt Template laden, PII reduzieren, LLM aufrufen
  9. ai-write.policy: auto_allowed für ai_summary → direkt in fact_history schreiben
  10. Event: history.ai_summary_ready → Notification an Candidate Manager
  11. Rule "Reminder 3 Tage": create_reminder Job → fact_reminders INSERT

FLOW 2: Scraper Change → Vacancy → Notification
  1. scraper.worker.ts: Account-Website gescrapt, neue Stelle erkannt
  2. fact_scrape_changes INSERT (change_type='new_job')
  3. Event: scrape.new_job_detected
  4. event-processor.worker.ts: Rule "Auto-Vacancy bei neuem Job"
  5. fact_vacancies INSERT (status='scraped', source_type='scraper')
  6. Event: job.vacancy_detected → Account Manager Notification
  7. Wenn Account Manager: job.vacancy → Review → POST /vacancies/:id/convert-to-job

FLOW 3: Dokument Upload → CV Parsing → Kandidat Update Suggestion
  1. POST /api/v1/documents/upload (Multipart)
  2. MIME-Check, Hash, Grösse, Virus-Scan (obligatorisch)
  3. Supabase Storage Upload
  4. TRANSAKTION: fact_documents INSERT + document.uploaded Event
  5. document.worker.ts: OCR → Parsing via LLM → Embedding
  6. CV-Parse Ergebnis: ai-write.policy 'suggest_only' für Core-Felder
  7. fact_ai_suggestions INSERT (zB: "Kandidat Name ist Max Muster")
  8. Notification: "CV geparst – X Vorschläge zur Übernahme"
  9. POST /ai/suggestions/:id/accept → TRANSAKTION: Core Update + Event + Audit

FLOW 4: Kandidat Stage Change → Automation → E-Mail
  1. POST /api/v1/candidates/:id/stage-change { to: 'Market Now', version: 5 }
  2. Auth + RBAC + tenant_id aus JWT
  3. Optimistic Locking: row_version=5 prüfen → Match → OK
  4. Policy: CANDIDATE_STAGE_TRANSITIONS['Active Sourcing'] enthält 'Market Now' → OK
  5. TRANSAKTION: dim_candidates_profile UPDATE + candidate.stage_changed Event
  6. COMMIT
  7. event-processor.worker.ts: Rule "E-Mail Vorlage bei Market Now"
  8. email.worker.ts: dim_email_templates laden → Personalisieren → Senden
  9. fact_history INSERT (email_sent), Event: email.sent, Audit Log
```

---

## 45. RUNBOOKS & INCIDENT-PLAYBOOKS

Monitoring ist wertlos ohne definierte Reaktion. Diese Runbooks gelten für Phase 1 und sind Pflicht für jede Person mit Produktionszugang.

```
=== RUNBOOK 1: Event Processor Worker DOWN ===
Symptom:  /health/ready gibt 503, Event-Queue wächst, keine Events werden verarbeitet
Alert:    Sentry + Railway Healthcheck schlägt fehl
Sofort:
  1. Railway Dashboard → ark-workers Service → Logs prüfen
  2. Crash-Ursache identifizieren (OOM, DB-Verbindung, uncaught Exception)
  3. Wenn DB-Verbindung: DATABASE_URL prüfen, Supabase Status-Seite checken
  4. Manual Restart: Railway → Redeploy
  5. Nach Restart: fact_event_queue prüfen – pending Events > 0?
     → Sie werden automatisch aufgeholt (Worker startet bei pending Events)
  6. Wenn DLQ-Rate steigt: Admin-Endpoint GET /api/v1/admin/workers/health prüfen
Eskalation: Wenn Worker nach 2 Restarts nicht stabil → Slack-Alert an Team-Lead
RTO-Ziel: < 15 Minuten bis erster Worker wieder läuft

=== RUNBOOK 2: DLQ Rate-Spike ===
Symptom:  > 5 Dead-Letter-Jobs in 15 Min (Alert-Schwelle aus Abschnitt 36)
Alert:    Sentry DLQ-Alert
Sofort:
  1. GET /api/v1/admin/workers/health → welcher Job-Typ betroffen?
  2. Logs für den Job-Typ prüfen: Was ist der Fehler?
     a) LLM-Timeout → LLM-Provider Status checken (OpenAI/Anthropic Status-Seite)
        → Feature Flag: FF_AI_AUTO_CLASSIFY=false → AI-Jobs pausieren
     b) 3CX-Fehler → GET /api/v1/admin/integrations/health → 3CX-Status
        → Webhook-URL in 3CX prüfen
     c) DB-Fehler → Supabase Dashboard → Connection Pool / Slow Queries
  3. Nach Behebung: DLQ-Jobs manuell requeuen via Admin (wenn idempotent)
  4. Root Cause im Incident-Log dokumentieren
Eskalation: Wenn > 50 DLQ-Jobs oder kritische Business-Flows betroffen → sofort

=== RUNBOOK 3: High API Error Rate (5xx) ===
Symptom:  > 1% 5xx in 5 Min
Alert:    Sentry Error Rate Alert
Sofort:
  1. Sentry → aktuelle Fehler → welcher Endpoint / welche Error-Klasse?
  2. Handelt es sich um DB-Fehler? → Supabase Connection Pool prüfen
  3. Handelt es sich um einen bestimmten Tenant? → Cross-Tenant-Angriff ausschliessen
  4. Railway Logs → Memory / CPU auf ark-api prüfen
  5. Bei Memory-Druck: Redeploy (Railway auto-restarts on OOM, aber manuell prüfen)
Eskalation: Wenn > 5% 5xx über 10 Min → Incident Level 1 (alle Mitarbeiter informieren)

=== RUNBOOK 4: Outlook-Token abgelaufen ===
Symptom:  GET /api/v1/admin/tokens/expiry zeigt recruiter@arkadium.ch Ablauf < 0 Tage
          Mail-Sync stoppt, email.received Events kommen nicht mehr
Alert:    Täglicher Check via admin/tokens/expiry (cron oder manuell)
Sofort:
  1. POST /api/v1/integrations/outlook/connect → OAuth-Flow neu durchlaufen
     (recruiter@arkadium.ch Account einloggen)
  2. Outlook-Adapter-Test: Testmail senden → prüfen ob email.received Event entsteht
  3. fact_integration_tokens prüfen: neues expires_at korrekt?
Präventiv: Alert wenn expires_at < 7 Tage (bereits via admin/tokens/expiry)

=== RUNBOOK 5: Supabase DB down / nicht erreichbar ===
Symptom:  /health/dependencies gibt 503, alle API-Calls schlagen fehl
Alert:    Railway Healthcheck + Sentry
Sofort:
  1. Supabase Status-Seite prüfen (https://status.supabase.com)
  2. Wenn Supabase-Incident: warten (nichts zu tun)
  3. Wenn DB-Verbindung ok aber PITR-Recovery nötig:
     → Supabase Dashboard → Database → Restore from Backup
     → RTO-Ziel: max 1 Stunde (aus Abschnitt 30)
     → Nach Restore: Event-Queue auf Konsistenz prüfen
  4. Team informieren: welche Daten potenziell verloren (max RPO: 1h)
Dokumentation: Jeder Recovery-Test monatlich im Incident-Log

=== RUNBOOK 6: Circuit Breaker Trip ===
Symptom:  GET /api/v1/admin/circuit-breakers zeigt circuit_breaker_tripped=true
          Automationen für diesen Event-Typ laufen nicht mehr
Sofort:
  1. Welche Regel betroffen? → Trigger-Count, letzter Trip-Zeitpunkt
  2. Ursache der Überschreitung prüfen (Bug? Datenproblem? Konfigurationsfehler?)
  3. Wenn Ursache behoben: POST /api/v1/admin/circuit-breakers/:ruleId/reset
  4. max_triggers_per_hour der Regel prüfen – ggf. Wert anpassen
  5. Audit-Eintrag: warum Trip, was behoben, wer resettet hat

=== ON-CALL ESKALATIONSPFAD (Phase 1) ===
  Stufe 1: Selbst beheben (Runbooks oben, max 15 Min Versuch)
  Stufe 2: Team-Lead informieren (Slack #ark-incidents)
  Stufe 3: Wenn Datenverlust oder Security-Incident vermutet: sofort eskalieren,
           Supabase Support kontaktieren, Railway Support kontaktieren
  Alle Incidents dokumentieren in: /docs/incidents/YYYY-MM-DD_kurzbeschreibung.md
```

---

## 46. MODUL-DEFINITIONEN: SEARCH / RAG / MATCHING / RECOMMENDATION

Diese vier Module werden im Code, in Gesprächen und in der Dokumentation häufig vermischt. Die folgende Definition ist verbindlich – kein Entwickler darf diese Begriffe austauschbar verwenden.

```
SEARCH (strukturierte & Volltextsuche)
  Definition:  SQL-basierte Suche mit Filtern, Volltextindex (tsvector) und
               Sortierung auf operativen Tabellen. Kein Vektorvergleich.
  Input:       User-eingegebene Suchbegriffe, strukturierte Filter (Stage, Sparte, etc.)
  Output:      Paginierte Liste von Entities (Kandidaten, Accounts, Jobs)
  Technologie: PostgreSQL Full-Text-Search (tsvector / tsquery) + Zod-validierte Filter
  Endpunkte:   GET /api/v1/search/candidates, /accounts, /jobs, /global
  Verboten:    Keine Vektor-Embeddings, keine Score-Berechnung, keine Inference

RAG (semantisches Retrieval über Chunks)
  Definition:  Embedding-basierte Ähnlichkeitssuche auf dim_embedding_chunks.
               Freitext-Frage → Embedding → pgvector cosine-similarity → relevante Chunks.
  Input:       Natürlichsprachliche Frage (z.B. "Zeige Kandidaten mit SAP-Erfahrung in Zürich")
  Output:      Relevante Text-Chunks + Kontext für nachgelagerten LLM-Call
  Technologie: pgvector (ivfflat), 1536d Embeddings (OpenAI text-embedding-3-small)
  Endpunkte:   POST /api/v1/rag/query, /rag/reindex, /rag/chunks
  Verboten:    RAG ersetzt keine strukturierten Filter – immer tenant_id filtern

MATCHING (regel- und scorebasiertes Kandidat-Job-Pairing)
  Definition:  Berechnung eines numerischen Match-Scores zwischen Kandidat und Job
               anhand von 7 definierten Dimensionen (Sparte, Function, Lohn, Standort,
               Skills, Verfügbarkeit, Erfahrung). Deterministisch und erklärbar.
  Input:       Kandidat-ID + Job-ID (oder Batch)
  Output:      Score 0-100 + match_breakdown_json (warum dieser Score)
  Technologie: Service-Layer Berechnung, keine Black Box, in fact_match_scores persistiert
  Endpunkte:   GET /matching/candidate/:id/jobs, /matching/job/:id/candidates,
               /matching/explain/:matchId, /matching/recalculate/...
  Verboten:    Kein LLM im Kern-Score – höchstens als ergänzende Signal-Quelle

RECOMMENDATION (aus Matching oder Marktregeln abgeleitete Vorschläge)
  Definition:  Auf Basis von Matching-Scores und Marktregeln generierte, priorisierte
               Vorschläge für Aktionen (z.B. "Dieser Kandidat passt zu 3 offenen Jobs").
               Recommendations sind Handlungsvorschläge – keine Suchergebnisse.
  Input:       Trigger: Stage-Change, Vakanz-Erkennung, Kandidat-Update
  Output:      fact_ai_suggestions (type='recommendation') oder Notification
  Technologie: Event-getrieben via Automation Rules + Matching-Ergebnisse
  Endpunkte:   GET /api/v1/ai/suggestions (gefiltert auf type='recommendation')
  Verboten:    Recommendations niemals direkt in Core-Felder schreiben (ai-write.policy!)
```

**Merkhilfe für das Team:**
```
Search    = ich weiss was ich suche      → Filter + Volltext → SQL
RAG       = ich beschreibe was ich will  → Embedding → pgvector
Matching  = wie gut passen diese zwei?   → Score + Erklärung → deterministisch
Recommend = was sollte ich jetzt tun?    → Vorschlag → Event-getrieben
```

---

## 47. API BREAKING-CHANGE & DEPRECATION POLICY

Klar definiert damit Frontend, Browser Extension und externe Tools nicht still brechen.

```
DEFINITION BREAKING CHANGE:
  Ein Breaking Change ist jede Änderung, die existierende Consumers ohne
  Anpassung ihres Codes nicht korrekt verarbeiten können:
  - Entfernung eines Feldes aus Response
  - Umbenennung eines Feldes
  - Änderung eines Datentyps (z.B. string → number)
  - Entfernung oder Umbenennung eines Endpunkts
  - Änderung von HTTP-Methode oder Statuscodes
  - Entfernung eines Enum-Wertes (Hinzufügen ist non-breaking)
  - Änderung von Pflichtfeldern in Request

NICHT BREAKING (Additive Changes – erlaubt ohne Versionierung):
  - Hinzufügen neuer optionaler Felder in Response
  - Hinzufügen neuer optionaler Request-Parameter
  - Hinzufügen neuer Endpunkte
  - Hinzufügen neuer Enum-Werte (Consumer müssen unknown values tolerieren)
  - Performance-Verbesserungen ohne Verhaltenssänderung

VERSIONING-STRATEGIE:
  URL-basiert: /api/v1/ → /api/v2/ bei Breaking Changes
  Beide Versionen gleichzeitig betrieben während Deprecation-Periode
  v1 läuft min. 90 Tage nach Ankündigung von v2 weiter
  Aktive Informationspflicht: alle Consumer werden informiert

DEPRECATION-PROZESS:
  1. Deprecated-Felder: Response enthält { _deprecated: { field: "reason" } }
  2. Header-Hinweis: X-Deprecated-Endpoint: true + X-Deprecation-Date: YYYY-MM-DD
  3. Ankündigung: Changelog + Info an alle bekannten Consumer (inkl. Browser Extension)
  4. Mindest-Laufzeit nach Deprecation-Ankündigung: 60 Tage für Phase 1 Consumers
  5. Erst dann: Entfernung des alten Endpunkts / Feldes

WEBHOOK PAYLOAD VERSIONIERUNG:
  Alle Webhook-Payloads enthalten ein version-Feld:
  { "version": "1.0", "event": "call.received", "data": {...} }
  Bei Payload-Änderungen: version erhöhen, altes Format parallel senden
  Consumer können anhand version die richtige Parsing-Logik wählen

CONTRACT TESTS BEIM BREAKING CHANGE:
  Vor jeder v2-Einführung: alle bestehenden Contract Tests (Abschnitt 38)
  gegen neue Version laufen lassen → kein unbewusster Bruch

PHASE-1-CONSUMER ÜBERSICHT:
  - ark-frontend (Vercel)
  - ark-crm Electron App
  - ARK Browser Extension (LinkedIn Import)
  - Power BI (direkt auf DB-Views, kein API-Breaking-Change-Risiko)
  - 3CX CRM-Template (GET /api/3cx/lookup – nie anpassen ohne 3CX-Test)
  → Bei Breaking Changes: Consumer-Liste durchgehen, alle informieren, alle testen
```

---

## 48. GRACEFUL SHUTDOWN (API & WORKER)

Bei Railway-Deploys, Restarts und Skalierungsereignissen darf kein Request und kein Job halb bearbeitet abgebrochen werden.

```typescript
// src/app/server.ts – API Graceful Shutdown:
const shutdown = async (signal: string) => {
  logger.info({ signal }, 'Shutdown signal received – draining connections')

  // 1. Neue Requests ablehnen (Health /ready gibt 503):
  isShuttingDown = true

  // 2. Laufende Requests zu Ende bringen (max 30 Sekunden):
  await server.close()   // Fastify wartet auf ausstehende Requests

  // 3. DB-Pool schliessen:
  await pool.end()

  logger.info('API shutdown complete')
  process.exit(0)
}

process.on('SIGTERM', () => shutdown('SIGTERM'))  // Railway sendet SIGTERM vor Kill
process.on('SIGINT',  () => shutdown('SIGINT'))   // Ctrl+C lokal

// Health-Check reagiert auf isShuttingDown:
app.get('/health/ready', (req, reply) => {
  if (isShuttingDown) return reply.status(503).send({ status: 'shutting_down' })
  // ...normale Checks
})

// src/workers/index.ts – Worker Graceful Shutdown:
const workerShutdown = async (signal: string) => {
  logger.info({ signal }, 'Worker shutdown signal – stopping job pickup')

  // 1. Keine neuen Jobs mehr abgreifen:
  await boss.stop({ timeout: 30_000 })
  // PgBoss setzt laufende Jobs zurück auf 'pending' falls Timeout überschritten

  // 2. Laufende Jobs sauber beenden (max 30 Sek):
  // PgBoss.stop() wartet auf aktive Handler – dann setzt er Jobs auf 'pending' zurück
  // → beim nächsten Worker-Start werden sie erneut verarbeitet (idempotent!)

  // 3. DB-Pool schliessen:
  await pool.end()

  logger.info('Worker shutdown complete')
  process.exit(0)
}

process.on('SIGTERM', () => workerShutdown('SIGTERM'))
process.on('SIGINT',  () => workerShutdown('SIGINT'))

// WICHTIG: Alle Worker-Handler MÜSSEN idempotent sein (bereits in Abschnitt 22 gefordert).
// Graceful Shutdown ist nur sicher weil ein halb verarbeiteter Job beim nächsten Start
// erneut verarbeitet wird ohne Datendopplung.
```

---

## 49. SINGLETON JOBS / LEADER ELECTION

Geplante Jobs wie `refresh-powerbi`, `cleanup-pii` und `scrape-accounts` dürfen bei mehreren Worker-Instanzen nicht parallel laufen. PgBoss unterstützt Singleton-Semantik nativ.

```typescript
// PgBoss Singleton: nur 1 aktiver Job pro Name gleichzeitig in der Queue
// → singletonKey verhindert doppelte Einreihung, singletonSeconds verhindert Doppellauf

// Scheduled Jobs als Singleton registrieren:
await boss.schedule('cleanup-pii', '0 2 * * *', {}, {
  singletonKey: 'cleanup-pii-global',  // ← nur 1 Job mit diesem Key in Queue erlaubt
})
await boss.schedule('refresh-powerbi', '0 */4 * * *', {}, {
  singletonKey: 'refresh-powerbi-global',
})
await boss.schedule('scrape-accounts', '0 8 * * 1-5', {}, {
  singletonKey: 'scrape-accounts-global',
})

// Ad-hoc Singleton (z.B. manuell ausgelöster Bulk-Reindex):
await boss.send('rag-bulk-reindex', payload, {
  singletonKey: `rag-reindex-${tenantId}`,    // pro Tenant genau 1 Reindex gleichzeitig
  singletonSeconds: 3600,                      // 1h Sperr-Fenster
})

// Warum kein Advisory Lock?
// → PgBoss Singleton ist einfacher, testet auf DB-Ebene atomar und
//   vermeidet die Komplexität von pg_try_advisory_lock / pg_advisory_unlock.
// → Advisory Locks nur wenn PgBoss Singleton für einen Usecase zu grob ist.

// REGEL: Jeder scheduled Job (boss.schedule) MUSS einen singletonKey haben.
// VERBOTEN: boss.schedule ohne singletonKey für nicht-idempotente Jobs.

// Worker-Skalierung:
// Bei 2+ Worker-Instanzen (Railway scale-out) pickt jeweils nur 1 Instanz den Job.
// Die anderen Instanzen sehen "bereits in Verarbeitung" und überspringen.
// → Korrekte PgBoss Konfiguration: teamSize=1 für Singleton-Jobs:
boss.work('cleanup-pii',      { teamSize: 1 }, cleanupPiiHandler)
boss.work('refresh-powerbi',  { teamSize: 1 }, refreshPowerBiHandler)
boss.work('scrape-accounts',  { teamSize: 1 }, scrapeAccountsHandler)
```

---

## 50. DB TIMEOUTS, CONNECTION POOLING & QUERY CANCELLATION

Ohne feste Timeout-Grenzen schleppt sich das System unter Last schleichend in Probleme: hängende Queries blockieren Pool-Connections, langsame Queries blockieren andere Requests.

```typescript
// lib/pg.ts – Connection Pool Konfiguration:
import { Pool } from 'pg'

export const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  max:              20,    // Max gleichzeitige Connections (Supabase Free: 60, Pro: 200)
  min:              2,     // Minimum Idle Connections (warm halten)
  idleTimeoutMillis: 10_000,   // Idle Connection nach 10s schliessen
  connectionTimeoutMillis: 3_000, // Timeout wenn kein Slot frei: 3s → dann Error
  // → Verhindert Request-Stau wenn Pool erschöpft (sofortiger Fehler statt unbegrenztes Warten)
})

// Postgres Session-Level Timeouts (bei jeder neuen Connection setzen):
pool.on('connect', async (client) => {
  // Query darf max 10s laufen (verhindert hängende Analytics-Queries):
  await client.query(`SET statement_timeout = '10000'`)
  // Transaktion die länger als 30s idle ist: automatisch abbrechen:
  await client.query(`SET idle_in_transaction_session_timeout = '30000'`)
  // Lock-Wartezeit max 5s (statt ewig auf Locks warten):
  await client.query(`SET lock_timeout = '5000'`)
})

// Query Cancellation bei Request-Abbruch (Client disconnect):
// WICHTIG: pg_cancel_backend(pg_backend_pid()) würde die eigene Verbindung canceln –
// das ist NICHT das Ziel. Korrekt ist es, die Backend-PID der betroffenen DB-Session
// zu ermitteln und diese gezielt abzubrechen.
//
// Empfohlene Strategie für Phase 1:
// → statement_timeout (bereits oben gesetzt) übernimmt die Schutzfunktion automatisch.
//   Ein Query, der das Timeout überschreitet, wird von Postgres selbst abgebrochen.
// → Explizites Request-Abort-Handling ist deshalb in Phase 1 nicht nötig.
//
// Für Phase 2 (falls nötig):
//   1. Backend-PID beim pool.connect() aus pg_stat_activity lesen und im Request-Kontext speichern
//   2. Bei req.on('close'): separaten Admin-Client nutzen, um pg_cancel_backend(savedPid) aufzurufen
//   3. Dabei sicherstellen, dass der Admin-Client NICHT dieselbe Connection ist
// → Diese Komplexität lohnt sich erst bei messbarem Problem durch lange Client-Disconnects.

// Retry-Strategie bei transienten DB-Fehlern:
// PgBoss Fehler: retryLimit=3, retryDelay=60, retryBackoff=true (bereits in Abschnitt 10)
// API Layer: transiente DB-Fehler (code 40001 serialization_failure) → max 2 Retries:
const withRetry = async <T>(fn: () => Promise<T>, maxRetries = 2): Promise<T> => {
  for (let i = 0; i <= maxRetries; i++) {
    try { return await fn() }
    catch (err) {
      if (err.code === '40001' && i < maxRetries) {
        await new Promise(r => setTimeout(r, 50 * Math.pow(2, i)))  // 50ms → 100ms
        continue
      }
      throw err
    }
  }
}

// POOL-MONITORING (in Observability eingebunden):
setInterval(() => {
  logger.info({
    pool_total:   pool.totalCount,
    pool_idle:    pool.idleCount,
    pool_waiting: pool.waitingCount,
  }, 'DB pool stats')
}, 60_000)  // jede Minute loggen

// ALERT wenn pool.waitingCount > 5 über 30s → Pool-Engpass → Railway Scaling prüfen

// VERBOTEN:
// → Pool-Grösse > 80% des Supabase Connection-Limits setzen (keine Reserve für Admin-Tools)
// → Queries ohne statement_timeout in Production
// → Transactions offen lassen ohne try/finally (pool.connect() immer mit finally: client.release())
```

---

## KURZREFERENZ – TOP 10 REGELN

```
1.  tenant_id NUR aus JWT – niemals aus Request
2.  Business Write + Event Insert = EINE Transaktion
3.  AI schreibt nie direkt in Core-Tabellen (ai-write.policy.ts prüfen!)
4.  Kein Hard Delete – Soft Delete + Restore möglich
5.  Niemals Stack Traces / interne Fehler an Client
6.  PII in Logs maskieren (Pino redact)
7.  Rate Limiting auf ALLEN Endpunkten
8.  Audit Log bei JEDER Zustandsänderung
9.  /api/v1/ Versionierung ab Tag 1 – keine Ausnahme
10. SELECT nur benötigte Felder – kein SELECT *
```

---

## L. Dok-Generator-Endpoints (NEU 2026-04-17)

Globaler Dok-Generator `/operations/dok-generator` ersetzt verstreute CTAs in Entity-Detailmasken durch zentrale Workflow-Engine.

### L.1 Template-Registry

```
GET    /api/v1/document-templates                        → Liste (filter ?category, ?target_entity_type)
  response: [{ key, display_name, category, kinds, is_active, ... }]

GET    /api/v1/document-templates/:key                   → Template-Details
  response: { ...full template with placeholders_jsonb, editor_schema_jsonb }
```

### L.2 Document Generation (Master-Endpoint)

```
POST   /api/v1/documents/generate
  body:
    template_key: 'mandat_offerte_target'
    entity_refs: [{ type: 'mandate', id: 'uuid' }]
    params: { sprache: 'de', empfaenger_anrede: 'Herr', zahlungsfrist_tage: 30 }
    overrides: { 'section.custom_paragraph': 'freier Text …' }
    delivery: 'save_only' | 'save_and_email' | 'save_and_download'
    email_options: { recipient_contact_id, subject, email_template_key } (bei email)
  response:
    { document_id, pdf_signed_url, action_result: 'saved' | 'saved_and_sent' }

POST   /api/v1/documents/resolve-placeholders            → Live-Canvas-Render
  body: { template_key, entity_refs }
  response: { placeholders: { "x.y": "value", ... }, missing_required: [...] }

POST   /api/v1/documents/:id/regenerate                  → neue Version bei Template-Update
  body: { new_template_version?, params_overrides? }
  response: { document_id, pdf_signed_url }

POST   /api/v1/documents/:id/email                       → Nachträglicher Email-Versand
  body: { recipient_contact_id, subject, email_template_key }
  response: { email_id, status: 'sent' }
```

### L.3 Recent / Drafts

```
GET    /api/v1/document-generator/recent                 → Sidebar Zuletzt
  query: ?limit=5&user_id=current
  response: [{ doc_id, display_name, entity_label, created_at, actor }]

GET    /api/v1/document-generator/drafts                 → Phase 2
  query: ?user_id=current
  response: [{ draft_id, template_key, entity_refs, params, updated_at }]

POST   /api/v1/document-generator/drafts                 → Phase 2 Auto-Save
  body: { template_key, entity_refs, params, editor_state }
  response: { draft_id }
```

### L.4 Wrapper-Mapping alter Endpoints

Bestehende punktuelle Endpoints werden zu Wrappern:

| Alter Endpoint | Intern ersetzt durch |
|----------------|---------------------|
| `POST /api/v1/assessments/:id/generate-quote` | `POST /api/v1/documents/generate` mit `template_key='assessment_offerte'` |
| `POST /api/v1/ai/generate-dossier` | `POST /api/v1/documents/generate` mit `template_key='ark_cv'` / `'abstract'` / `'expose'` |

Alte Endpoints bleiben backward-compatible, neue Implementation soll Master-Endpoint nutzen.

### L.5 Events

| Event | Scope | Payload |
|-------|-------|---------|
| `document_generated` | Entity (aus entity_refs) + Dokument | `{ doc_id, template_key, params, delivery_mode }` |
| `document_emailed` | Entity + Kontakt | `{ doc_id, recipient_contact_id, email_id, subject }` |
| `document_regenerated` | Entity + Dokument | `{ doc_id, new_version, reason }` |

### L.6 Validierungs-Regeln

- Template muss existieren + `is_active=true` (sonst 404)
- Entity-Refs müssen Template-Kinds matchen (sonst 400)
- Multi-Entity-Template braucht ≥ 1 Entity je Kind
- Required Params gesetzt (z.B. `sprache`)
- Email-Delivery: `recipient_contact_id` muss zum Entity-Account gehören
- PDF-Render > 10 MB → 413

---

