# ARK CRM — Backend-Architektur-Patch · E-Learning · v0.1

**Scope:** Backend-Erweiterung für das Phase-3-ERP-Modul E-Learning (Sub A · Kurs-Katalog): Events, Worker, API-Endpoints, RLS-Policies, Queue-Integration.
**Zielversion:** `ARK_BACKEND_ARCHITECTURE_v2_6.md` (baut auf dem parallel laufenden Activity-Types-Patch `v2_5_to_v2_6` auf; finale Version beim Merge festzulegen).
**Basis-Specs:** `specs/ARK_E_LEARNING_SUB_A_SCHEMA_v0_1.md`, `specs/ARK_E_LEARNING_SUB_A_INTERACTIONS_v0_1.md`.
**Vorheriger Patch:** `specs/ARK_DATABASE_SCHEMA_PATCH_ELEARNING_v0_1.md`.
**Stand:** 2026-04-20
**Status:** Review ausstehend (Peter)

---

## Changelog

| # | Bereich | Änderung |
|---|---------|----------|
| 1 | Event-Typen | +16 neue `elearn_*`-Events (siehe Sektion 1) |
| 2 | Worker | +9 neue Worker (7 event-driven, 2 Cron) |
| 3 | API-Endpoints | +30+ Endpoints unter `/api/elearn/*` (3 Ebenen: MA / Team / Admin) |
| 4 | Queue | E-Learning-Worker nutzen bestehende `fact_event_queue`-Infrastruktur (keine neue Queue) |
| 5 | RLS-Policies | +15 Policies für `tenant_id`-Scoping |
| 6 | Integrationen | LLM-Provider (Claude Haiku 4.5 / Sonnet 4.6) via Anthropic-SDK; S3/Blob für Cert-PDFs; Git-Webhook-Endpoint |
| 7 | Notifications | E-Learning-spezifische Notification-Templates (MA + Head + Admin) |

---

## 1. Event-Typen (Seed für `dim_event_types`)

**Kategorie:** neue `event_category='elearning'` (CHECK-Erweiterung nötig).

| event_name | emitter_component | create_history | default_activity_type_id |
|------------|-------------------|----------------|--------------------------|
| `elearn_course_assigned` | onboarding-initializer / team-assignment-api | true | elearn_assigned |
| `elearn_course_started` | enrollment-api | true | elearn_started |
| `elearn_course_completed` | attempt-finalizer | true | elearn_completed |
| `elearn_lesson_completed` | progress-api | false | — (Summary via Module-Event) |
| `elearn_quiz_attempted` | quiz-api | false | — |
| `elearn_quiz_passed` | attempt-finalizer | true | elearn_quiz_passed |
| `elearn_quiz_failed` | attempt-finalizer | true | elearn_quiz_failed |
| `elearn_freitext_submitted` | quiz-submit-api | false | — |
| `elearn_freitext_reviewed` | freitext-review-api | false | — |
| `elearn_certificate_issued` | cert-generator | true | elearn_cert |
| `elearn_badge_earned` | badge-engine | true | elearn_badge |
| `elearn_refresher_triggered` | refresher-trigger | true | elearn_refresher |
| `elearn_role_change_triggered` | role-change-watcher | true | elearn_role_change |
| `elearn_assignment_expired` | deadline-expiry | true | elearn_expired |
| `elearn_onboarding_finalized` | team-api | true | elearn_onboarding_done |
| `elearn_content_imported` | import-worker | false | — (nur Import-Log) |

**Activity-Types** (Sub-Set neu für `dim_activity_types`):

| activity_type_name | activity_category | activity_channel | is_auto_loggable |
|--------------------|--------------------|------------------|------------------|
| elearn_assigned | `elearning` (neu) | CRM | true |
| elearn_started | `elearning` | CRM | true |
| elearn_completed | `elearning` | CRM | true |
| elearn_quiz_passed | `elearning` | CRM | true |
| elearn_quiz_failed | `elearning` | CRM | true |
| elearn_cert | `elearning` | System | true |
| elearn_badge | `elearning` | System | true |
| elearn_refresher | `elearning` | System | true |
| elearn_role_change | `elearning` | System | true |
| elearn_expired | `elearning` | System | true |
| elearn_onboarding_done | `elearning` | CRM | true |

Kategorie-CHECK erweitern: `activity_category IN (..., 'elearning')` (siehe Stammdaten-Patch).

## 2. Worker

Neun neue Worker, alle in bestehendes Event-Processor-Framework integriert.

### 2.1 Event-driven Worker

| Worker | Trigger-Event | Concurrency | Retry |
|--------|---------------|-------------|-------|
| `elearn-onboarding-initializer` | `user_created` | 1 | 3× |
| `elearn-role-change-watcher` | `user_role_changed` / `user_sparte_changed` | 1 | 3× |
| `elearn-cert-generator` | `elearn_course_completed` (letztes Modul) | 3 | 3× |
| `elearn-badge-engine` | `elearn_course_completed` / `elearn_quiz_passed` | 5 | 3× |
| `elearn-freitext-llm-scorer` | `elearn_freitext_submitted` | 5 | 3× (Backoff 2 s / 8 s / 30 s) |
| `elearn-attempt-finalizer` | `elearn_freitext_reviewed` (letzter pending Review) | 5 | 3× |
| `elearn-import-worker` | `POST /api/elearn/admin/import` (HTTP-synchron + Background-Parse) | 1 pro Tenant | 2× |

### 2.2 Cron-Worker

| Worker | Schedule | Zweck |
|--------|----------|-------|
| `elearn-refresher-trigger` | `0 2 * * *` | Refresher-Assignments erzeugen |
| `elearn-deadline-expiry` | `0 6 * * *` | Abgelaufene Assignments expirieren |
| `elearn-sla-reminder` | `0 * * * *` (stündlich) | Freitext-Queue-Reminder + Escalation + Auto-Confirm |

### 2.3 Worker-Implementations-Hinweise

- Alle Worker respektieren `tenant_id`-Scoping (keine Cross-Tenant-Operationen).
- LLM-Scorer nutzt Anthropic-SDK mit Retry-Logic. Prompt-Template siehe `INTERACTIONS §9.2`.
- Cert-Generator: Puppeteer + HTML-Template → PDF → S3-Upload. Cert-PDF-Template liegt in `templates/elearn-cert.html`.
- Import-Worker: Git-Clone mit flachem Shallow-Clone (`--depth 1 --branch main`), YAML-Validierung via Zod, Diff-Logic wie in `INTERACTIONS §3`.

## 3. API-Endpoints

Namespace: `/api/elearn/*`. Drei Ebenen (MA / Team / Admin). Vollständige Liste siehe `SCHEMA §5`. Implementations-Framework: bestehendes ARK-Routing (tRPC oder REST — je nach Projekt-Standard; in Implementation-Plan festzulegen).

### 3.1 Auth-Middleware

Alle Endpoints durchlaufen `requireAuth()`:
- Extrahiert `tenant_id`, `user_id`, `role` aus JWT.
- Setzt `SET app.current_tenant_id = $1` (PostgreSQL-Session-Var für RLS).
- Route-Guards pro Ebene:
  - `/my/*` → jeder authentifizierte User (nur eigene Ressourcen via RLS).
  - `/team/*` → `role IN ('head_of', 'admin', 'backoffice')`, zusätzlich Sparten-Filter via `dim_user.reports_to` oder `dim_user.sparte`.
  - `/admin/*` → `role IN ('admin', 'backoffice')`.

### 3.2 Git-Webhook-Endpoint (`POST /api/elearn/admin/import`)

- **Auth:** Shared-Secret HMAC-SHA256 im Header `X-Git-Signature` (pro Tenant in `dim_elearn_tenant.settings.webhook_secret`).
- **Body:** GitHub-Webhook-Payload-Format.
- **Response:** 202 Accepted + Job-ID (Background-Verarbeitung), danach Event `elearn_content_imported`.
- **Alternative manuell:** `POST /api/elearn/admin/import/manual` mit `{ commit_sha? }` für Admin-Trigger aus Dashboard.

## 4. RLS-Policies

Pro neue Tabelle eine Policy für SELECT/INSERT/UPDATE/DELETE, tenant-scoped:

```sql
-- Beispiel für dim_elearn_course; analog für alle 15 neuen Tabellen
ALTER TABLE dim_elearn_course ENABLE ROW LEVEL SECURITY;

CREATE POLICY elearn_course_tenant_isolation ON dim_elearn_course
  USING (tenant_id = current_setting('app.current_tenant_id')::uuid)
  WITH CHECK (tenant_id = current_setting('app.current_tenant_id')::uuid);
```

**Ausnahmen:**
- `fact_elearn_progress` und `fact_elearn_quiz_attempt`: zusätzlich `ma_id = current_setting('app.current_user_id')::uuid` für MA-Endpoints; Team/Admin-Endpoints nutzen separate View mit erweiterten Rights.
- `fact_elearn_freitext_review`: Head sieht nur Team-Reviews (Sub-Query via `dim_user.reports_to`).

## 5. Queue-Integration

- Alle Events fliessen durch bestehende `fact_event_queue` → `event-processor.worker.ts`.
- Neue Event-Typen bekommen im Processor einen Router-Dispatch auf die entsprechenden E-Learning-Worker.
- Keine eigene Queue-Infrastruktur. Priorität `default`; LLM-Scorer kann in Phase-2 auf separaten High-Throughput-Worker ausgelagert werden, falls Latenz-Probleme.

## 6. Notifications

Neue Notification-Templates (in bestehendem Notification-System):

| Template | Empfänger | Trigger |
|----------|-----------|---------|
| `elearn-new-assignment` | MA | `elearn_course_assigned` |
| `elearn-refresher-due` | MA + Head (CC) | `elearn_refresher_triggered` |
| `elearn-deadline-warning` | MA | 7 Tage vor `assignment.deadline` |
| `elearn-deadline-expired` | MA + Head | `elearn_assignment_expired` |
| `elearn-quiz-result` | MA | `elearn_quiz_passed` / `elearn_quiz_failed` |
| `elearn-cert-issued` | MA | `elearn_certificate_issued` |
| `elearn-freitext-queue-reminder` | Head | SLA Tag 3 |
| `elearn-freitext-queue-escalation` | Admin + Head | SLA Tag 7 |

## 7. Integrationen

### 7.1 LLM (Anthropic)

- **Modell-Default:** `claude-haiku-4-5`.
- **Tenant-Override:** `dim_elearn_tenant.settings.llm_model`.
- **Confidence-Escalation:** bei `confidence < 60` Retry mit `claude-sonnet-4-6` (konfigurierbar per Tenant).
- **Rate-Limit-Handling:** Queue-basiert, Concurrency 5; bei 429 Exponential-Backoff, dann 3× Retry.
- **Cost-Tracking:** pro LLM-Call Insert in `fact_llm_usage` (bestehend — verifizieren) mit `purpose='elearn_freitext'`.

### 7.2 S3 / Blob (Zertifikate)

- Bucket `ark-elearn-certs` (oder Tenant-prefix-Pattern).
- Pfad: `<tenant_id>/<cert_id>.pdf`.
- Public-read (Download-Link in `dim_elearn_certificate.pdf_url`).
- Lifecycle: kein Auto-Delete (Certs sind Audit-relevant).

### 7.3 Git-Webhook

- GitHub-Repo `arkadium/ark-elearning-content` (oder Tenant-Namespace).
- Webhook-Secret in `dim_elearn_tenant.settings.webhook_secret` (tenant-spezifisch).
- Branch `main` triggert Re-Import.

## 8. Performance-Annahmen

- **Erwartetes Volumen pro Tenant/Jahr:**
  - ~50 Kurse, ~500 Module, ~5 000 Lessons, ~10 000 Fragen (Pool).
  - ~30 aktive Lerner, ~100 000 Progress-Events/Jahr, ~10 000 Quiz-Attempts/Jahr.
  - ~2 000 Freitext-Reviews/Jahr.
- **Hot-Path-Queries:**
  - `GET /my/courses` mit Unlock-Computation: 1–2 JOINs über `fact_elearn_enrollment` + `dim_elearn_course` + `fact_elearn_curriculum_override`/`dim_elearn_curriculum_template`. Erwartete Latenz < 50 ms.
  - `GET /team/freitext-queue`: Index `(tenant_id, status)` Partial, < 20 ms.
- **Caching:** Kurs-Content (Lessons + Fragen) kann Edge-gecached werden (15 min TTL). Content-Hash-Bust bei neuem Import.

## 9. Offene Punkte

- **Saga-Integration:** E-Learning ist aktuell nicht Teil bestehender Sagas. Falls später Kurs-Abschluss ein Trigger für Provisions-/HR-Workflows wird, Saga-Definition in Sub-D oder separatem Patch.
- **Mobile-Push-Notifications:** nicht MVP. Phase-2 falls relevant.
- **Audit-Log für Admin-Revisions** (`POST /admin/freitext/:id/revise`): separater Event-Type `elearn_freitext_revised` mit before/after Payload — im MVP bereits einbauen.
