# ARK CRM — Backend-Architektur-Patch · E-Learning Sub C · v0.1

**Scope:** Backend-Erweiterung für den Wochen-Newsletter (Sub C): Events, Worker, R4b-Runner, API-Endpoints, RLS, Notifications.
**Zielversion:** gemeinsam mit Sub-A/B-Patches.
**Basis-Specs:** `specs/ARK_E_LEARNING_SUB_C_SCHEMA_v0_1.md`, `specs/ARK_E_LEARNING_SUB_C_INTERACTIONS_v0_1.md`.
**Vorherige Patches:** Sub A + Sub B Backend-Patches.
**Stand:** 2026-04-20
**Status:** Review ausstehend (Peter)

---

## Changelog

| # | Bereich | Änderung |
|---|---------|----------|
| 1 | Event-Typen | +12 neue `elearn_newsletter_*`-Events |
| 2 | Worker | +3 event-driven + 3 Cron-Worker |
| 3 | Pipeline-Runner | +1 neuer Runner `r4b_newsletter.py` in `tools/elearn-content-gen/runners/` |
| 4 | API-Endpoints | +15 Endpoints unter `/api/elearn/my/newsletter/*`, `/team/newsletter/*`, `/admin/newsletter/*` |
| 5 | RLS-Policies | +4 Policies (tenant-scoped) |
| 6 | Notifications | Newsletter-Reminder, Escalation, Published, Expired |
| 7 | Prompts | 3 neue LLM-Prompts: structure, section-body, quiz-gen |

---

## 1. Event-Typen

Kategorie `event_category='elearning'` bereits aus Sub-A-Patch.

| event_name | emitter | create_history | default_activity_type |
|------------|---------|----------------|-----------------------|
| `elearn_newsletter_issue_drafted` | newsletter-generator | false | — |
| `elearn_newsletter_issue_published` | newsletter-publisher | true | elearn_nl_published |
| `elearn_newsletter_assigned` | assignment-creator | true | elearn_nl_assigned |
| `elearn_newsletter_read_started` | read-api | false | — |
| `elearn_newsletter_read_completed` | read-api | false | — |
| `elearn_newsletter_quiz_passed` | attempt-finalizer (Sub A Worker) | true | elearn_nl_quiz_passed |
| `elearn_newsletter_quiz_failed` | attempt-finalizer | true | elearn_nl_quiz_failed |
| `elearn_newsletter_reminder_sent` | newsletter-reminder | true | elearn_nl_reminder |
| `elearn_newsletter_escalated_to_head` | newsletter-reminder | true | elearn_nl_escalated |
| `elearn_newsletter_expired` | newsletter-reminder | true | elearn_nl_expired |
| `elearn_newsletter_subscription_added` | subscription-api | false | — |
| `elearn_newsletter_enforcement_override_set` | admin-override-api | true | elearn_nl_override |

**Activity-Types (Seed):** 9 neue, Kategorie `elearning`.

## 2. Worker

### 2.1 Cron

| Worker | Schedule | Zweck |
|--------|----------|-------|
| `elearn-newsletter-generator` | `{tenant}.settings.elearn_c.publish_day_cron` (Default `0 6 * * 1`) | Pro Sparte ein Draft-Issue erzeugen via R1–R4b |
| `elearn-newsletter-publisher` | stündlich `0 * * * *` | Draft-Issues ab `publish_at` auf `published` setzen, Assignments erzeugen |
| `elearn-newsletter-reminder` | stündlich | Soft-Enforcement: Reminder / Escalation / Expiry |
| `elearn-newsletter-archive-purger` | monatlich `0 2 1 * *` | Issues älter `archive_retention_months` auf `status='archived'` |

### 2.2 Event-driven

| Worker | Trigger | Concurrency |
|--------|---------|-------------|
| `elearn-newsletter-subscription-initializer` | `user_created` | 1 |
| `elearn-newsletter-subscription-syncer` | `user_sparte_changed`, `user_role_changed` | 1 |
| `elearn-newsletter-assignment-creator` | `elearn_newsletter_issue_published` | 1 pro Tenant |

## 3. R4b Runner

**`tools/elearn-content-gen/runners/r4b_newsletter.py`** (Port aus `C:\Linkedin_Automatisierung\lib\newsletter_generator.py`, ARK-spezifisch angepasst).

**CLI:** `python -m elearn_content_gen newsletter --tenant <id> --sparte <code> --week <iso-week>`

**Input:**
- Tenant-ID, Sparte, ISO-Week.
- Content-Fundus: Chunks mit `source.last_ingested_at >= NOW() - 7 days` und passenden Sparten.

**Output:**
- `dim_elearn_newsletter_issue` mit `status='draft'`.
- Synthetisches `dim_elearn_module` + `dim_elearn_question`-Rows für Quiz.
- `generation_job_id` referenziert für Cost-Tracking.

**Fehler-Fälle:**
- Zu wenig Content-Chunks (< 3 Cluster): Skippen mit Event `elearn_newsletter_skipped_insufficient_content`, kein Issue erzeugt.
- LLM-Timeout: Job fehlschlägt, Retry 2×, dann Admin-Alert.

## 4. LLM-Prompts

Neue Prompt-Templates in `tools/elearn-content-gen/prompts/`:

| Prompt-Slug | Zweck |
|-------------|-------|
| `newsletter_structure` | Clustering → Section-Auswahl + Titel |
| `newsletter_section_body` | Markdown-Body pro Section aus Chunks |
| `newsletter_quiz_generation` | YAML-Fragen-Pool aus Section-Bodies |

Details und Prompt-Texte in `INTERACTIONS §3.2`.

## 5. API-Endpoints

Namespace-Präfix pro Ebene (MA / Team / Admin). Auth-Middleware wie Sub A/B.

### 5.1 MA (`/api/elearn/my/newsletter/*`)

| Methode | Pfad | Zweck |
|---------|------|-------|
| GET | `/my/newsletter` | Aktuelle + Archiv |
| GET | `/my/newsletter/:issue_id` | Issue-Details + Quiz-Status |
| POST | `/my/newsletter/:issue_id/read-start` | Read-Flow starten |
| POST | `/my/newsletter/:issue_id/sections/:idx/progress` | Scroll/Time heartbeat |
| POST | `/my/newsletter/:issue_id/quiz/start` | Quiz-Attempt starten (nutzt Sub-A-Engine) |
| GET | `/my/newsletter/subscriptions` | Eigene Abos |
| POST | `/my/newsletter/subscriptions` | Opt-in zu weiterer Sparte |
| DELETE | `/my/newsletter/subscriptions/:id` | Opt-out (nur wenn erlaubt) |

### 5.2 Team (`/api/elearn/team/newsletter/*`)

| Methode | Pfad | Zweck |
|---------|------|-------|
| GET | `/team/newsletter/queue` | Überfällige Assignments im Team |
| POST | `/team/newsletter/:assignment_id/remind` | Manueller Reminder |

### 5.3 Admin (`/api/elearn/admin/newsletter/*`)

| Methode | Pfad | Zweck |
|---------|------|-------|
| GET | `/admin/newsletter/issues` | Alle Ausgaben (filterbar) |
| GET | `/admin/newsletter/issues/:id` | Preview + Stats |
| POST | `/admin/newsletter/issues/:id/publish` | Manuelles Publish |
| POST | `/admin/newsletter/issues/:id/archive` | Archivieren |
| POST | `/admin/newsletter/generate` | Manueller Generation-Run `{sparte, issue_week}` |
| GET | `/admin/newsletter/config` | Tenant-Settings lesen |
| POST | `/admin/newsletter/config` | Tenant-Settings speichern |
| GET | `/admin/newsletter/metrics` | Read-Rate, Quiz-Pass-Rate, Escalation-Quote |
| POST | `/admin/newsletter/enforcement-override` | Per-MA-Override `{ma_id, mode}` |

## 6. RLS-Policies

Analog Sub A/B:

```sql
ALTER TABLE dim_elearn_newsletter_issue ENABLE ROW LEVEL SECURITY;
CREATE POLICY nl_issue_tenant_isolation ON dim_elearn_newsletter_issue
  USING (tenant_id = current_setting('app.current_tenant_id')::uuid)
  WITH CHECK (tenant_id = current_setting('app.current_tenant_id')::uuid);

-- Analog für dim_elearn_newsletter_subscription, fact_elearn_newsletter_assignment,
-- fact_elearn_newsletter_section_read.
```

**Assignment-Policy (MA-scoped):**
- `fact_elearn_newsletter_assignment` zusätzlich per `ma_id` für `/my/*`-Endpoints.
- Head sieht Team via `dim_user.reports_to`-Join.
- Admin/Backoffice sieht tenant-weit.

## 7. Notifications

| Template | Empfänger | Trigger |
|----------|-----------|---------|
| `elearn-nl-issue-published` | Abonnenten (In-App) | `elearn_newsletter_issue_published` |
| `elearn-nl-reminder` | MA | `elearn_newsletter_reminder_sent` |
| `elearn-nl-escalated-to-head` | Head | `elearn_newsletter_escalated_to_head` |
| `elearn-nl-expired` | MA | `elearn_newsletter_expired` |
| `elearn-nl-quiz-passed` | MA | `elearn_newsletter_quiz_passed` |
| `elearn-nl-generation-failed` | Admin | bei R4b-Fehler |

## 8. Sub-D-Hook

Sub C erzeugt nur Assignments-State mit `enforcement_mode_applied`. Sub D (Progress-Gate) liest:

```sql
SELECT 1 FROM fact_elearn_newsletter_assignment
WHERE tenant_id = $1 AND ma_id = $2
  AND status NOT IN ('quiz_passed', 'expired')
  AND enforcement_mode_applied = 'hard'
LIMIT 1;
```

Wenn vorhanden → Sub D zeigt Gate-Page. Kein direkter Code in Sub C für Enforcement.

## 9. Interop mit Sub A

- Newsletter-Quiz-Submit durchläuft identische Sub-A-Flows (LLM-Scorer, Head-Review, Attempt-Finalizer).
- `elearn-attempt-finalizer` (aus Sub A) erkennt `attempt.attempt_kind='newsletter'` und emittiert zusätzlich `elearn_newsletter_quiz_passed`/`failed` (Cross-Event-Emission dokumentieren im Worker-Code).
- Assignment-Status-Update bei Quiz-Pass: separater Sub-Handler auf `elearn_quiz_passed`-Event, matched Assignment via `quiz_attempt_id`.

## 10. Performance

- **Generation-Dauer:** ~3–5 Min pro Sparte (4 Sections + Quiz, Claude Sonnet 4.6).
- **Assignments-Bulk-Insert:** bei 30 MA × 5 Sparten = 150 Rows pro Publish-Run, in Batch-Insert.
- **Reminder-Scan:** stündlich `SELECT … FROM fact_elearn_newsletter_assignment WHERE deadline <= NOW() + INTERVAL '1h'` — mit Index auf `(tenant_id, deadline)` schnell.

## 11. Cost

Newsletter-Generation zählt gegen `elearn_b.llm_cost_cap_monthly_eur` (gleiches Budget wie Content-Gen). Separate Kosten-Aggregation nach Source-Kind sichtbar im Admin-Dashboard.

## 12. Offene Punkte

- **Cross-Event-Emission** für Quiz-Passed im `attempt-finalizer`: Sub A Worker muss um Newsletter-Check erweitert werden (Code-Änderung in Sub A implementation, Spec-Patch dokumentieren).
- **Admin-Review-Gate vor Publish:** Phase-2 Setting `require_admin_review_before_publish`.
- **Parallel-Runs pro Sparte:** Concurrency-Limit im Generator damit LLM-Rate-Limit nicht überschritten wird.
