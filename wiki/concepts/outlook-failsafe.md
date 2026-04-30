---
title: "Outlook-Failsafe-Strategie"
type: concept
created: 2026-04-30
updated: 2026-04-30
sources: [
  "specs/ARK_EMAIL_KALENDER_DETAILMASKE_INTERACTIONS_v0_1.md",
  "Grundlagen MD/ARK_BACKEND_ARCHITECTURE_v2_8.md §42 Admin-Diagnose · §45 Runbook 4",
  "wiki/concepts/email-system.md",
  "specs/ARK_ADMIN_DEBUG_SCHEMA_v1_0.md (Admin Tab 9)"
]
tags: [concept, email, outlook, failsafe, integration, msgraph, runbook]
---

# Outlook-Failsafe-Strategie

Konsolidierter Überblick über Resilience-Mechanismen für die Outlook/MS-Graph-Integration. Einzelne Bausteine sind in mehreren Specs verteilt — diese Seite ist der **Single-Source-of-Truth-Index**.

## Scope

| Failure-Modus | Wo behandelt | Status |
|----------------|--------------|--------|
| Token-Expiry (vorhersehbar) | Email-Spec §Token-Erneuern + Backend-v2.8 §42 + Runbook 4 | ✅ spec'd |
| Token-Revoked (User dreht Permissions ab) | Email-Spec §Token-Erneuern (Banner-Flow) | ✅ spec'd |
| MS-Graph 5xx beim Send (transient) | **diese Seite §3 Send-Queue-Retry** | 🟡 hier neu |
| MS-Graph 429 Rate-Limit | **diese Seite §3.4 Backoff** | 🟡 hier neu |
| MS-Graph Komplett-Outage | Runbook 4 + this §4 | ✅ spec'd |
| Netzwerk-Timeout (CRM ↔ MS-Graph) | **diese Seite §3 Send-Queue-Retry** | 🟡 hier neu |
| Webhook-Verlust (delta-Sync ausfällt) | Backend-v2.8 §Outlook-Adapter | ⚠ Partial — siehe §5 offene Frage |

## 1. Token-Lifecycle (vorhandene Spec-Referenzen)

### 1.1 Health-Check-Worker (5min)

Worker `outlook.health.worker.ts` läuft alle 5 Min:
- Liest `dim_integration_tokens` für aktive Outlook-Connections
- Bei `expires_at < now() + 24h`: Auto-Refresh via Refresh-Token
- Bei `expires_at < now() + 7 Tage`: Markiert in `admin/tokens/expiry`-Endpoint
- Bei Refresh-Fehlschlag: Token als `status='expired'` markiert, Banner-Push an User-Session, Mail an Admin

**Endpoint:** `GET /api/v1/admin/tokens/expiry` (Backend-v2.8 §42 Z. 3250)
**Frequenz:** Täglich Cron + manueller Aufruf

### 1.2 User-Reauth-Flow (Token expired/revoked)

Spec: `ARK_EMAIL_KALENDER_DETAILMASKE_INTERACTIONS_v0_1.md` §TEIL 8 / Token-Erneuern.

1. Banner im Email-Kalender-Modul: „Email-Sync unterbrochen · Token erneuern"
2. Click → Modal mit Re-Auth-Button
3. Click „Token erneuern" → POST `/api/v1/integrations/outlook/connect` → MS-Login → Azure-Consent
4. Bei Success: Token aktualisiert, Banner verschwindet, Send-Queue-Drain startet (siehe §3.5)

### 1.3 Setup-/OAuth-Flow

Initial-Connect dokumentiert in Email-Spec §TEIL 8 / OAuth-Connect-Flow. Token + Refresh-Token landen in `dim_integration_tokens` (secret_ref).

## 2. Admin-Surface-Mapping

Welche Health-Indicators werden wo in der UI gezeigt?

| UI-Surface | Daten-Quelle | Endpoint |
|------------|--------------|----------|
| Email-Kalender Modul · Status-Card | Token-Status für aktiven User | `GET /api/v1/integrations/outlook/status?user=me` |
| Admin Tab 1 (Settings) · Integrations-Sub | Alle Tokens + Health-Score | `GET /api/v1/admin/integrations/health` |
| **Admin Tab 9 (Debug) · Sub-Tab 9-1 Event-Log** | `email.send.failed` / `email.token.refresh_failed` Events | Tab-9-Event-Filter |
| **Admin Tab 9 (Debug) · Sub-Tab 9-2 Saga-Traces** | Send-Saga-Traces bei mehrfach-Retry | correlation_id-Gruppierung |
| **Admin Tab 9 (Debug) · Sub-Tab 9-3 Dead-Letter-Queue** | Permanent-failed Send-Jobs | DLQ-Filter `job_type='email.send'` |

**Keine separate Mockup-Datei** für Outlook-Health nötig — alle Surfaces sind in admin.html (Tabs 1, 9) bereits da.

## 3. Send-Queue-Retry-Policy (NEU)

**Problem:** Beim Email-Send via MS-Graph kann ein transientes 5xx / 429 / Network-Timeout auftreten. Default-Behavior „direkt Failure-Toast an User" ist schlecht — User glaubt Mail ist verloren.

**Lösung:** Send-Queue mit Retry-Policy.

### 3.1 Queue-Architektur

`fact_email_send_queue` (neu in Backend-v2.9-Patch):

| Spalte | Typ | Bedeutung |
|--------|-----|-----------|
| `id` | uuid PK | — |
| `actor_id` | uuid FK → dim_mitarbeiter | Sender |
| `recipient_to`, `_cc`, `_bcc` | text[] | Empfänger |
| `subject` | text | — |
| `body_html` | text | — |
| `attachments` | jsonb | File-Refs |
| `template_key` | text NULL | Template-Spur |
| `linked_entity_id`, `_type` | uuid + enum | Entity-Spur (für `fact_history`-Eintrag) |
| `status` | enum: `pending` / `sending` / `sent` / `failed` / `dead_lettered` | — |
| `attempt_count` | int | 0..max_retries |
| `last_attempt_at` | timestamptz | — |
| `next_retry_at` | timestamptz | — |
| `last_error_code` | text | z.B. `MSGRAPH_503` / `MSGRAPH_429` / `MSGRAPH_TOKEN_EXPIRED` / `NETWORK_TIMEOUT` |
| `last_error_detail` | text | Stack/Response-Body |
| `idempotency_key` | text UNIQUE | Verhindert Doppel-Send |
| `created_at` | timestamptz | — |

### 3.2 Worker `email.send.worker.ts`

- Pollt `status='pending' AND next_retry_at <= now()` jede 30s
- Pro Job: Token-Check → MS-Graph-Send → Status-Update
- Bei Success: `status='sent'`, `fact_history`-Insert, `email.sent`-Event
- Bei Failure: Klassifizierung + Backoff (siehe §3.3)

### 3.3 Failure-Klassifizierung

| Error-Klasse | Retry? | Backoff | Max-Retries |
|---------------|--------|---------|--------------|
| `MSGRAPH_TOKEN_EXPIRED` (401) | ❌ stop | — | 0 → direkt `dead_lettered` mit Reauth-Aufforderung |
| `MSGRAPH_PERMISSION_DENIED` (403) | ❌ stop | — | 0 → `dead_lettered`, Admin-Mail |
| `MSGRAPH_RECIPIENT_INVALID` (400) | ❌ stop | — | 0 → `dead_lettered`, User-Banner |
| `MSGRAPH_QUOTA_EXCEEDED` (429) | ✅ | Exponential mit `Retry-After`-Header | 5 |
| `MSGRAPH_503` / `MSGRAPH_504` (transient) | ✅ | 1min, 5min, 15min, 30min, 60min | 5 |
| `NETWORK_TIMEOUT` | ✅ | 30s, 2min, 5min, 15min, 30min | 5 |
| `MSGRAPH_500` (Server-Bug, selten) | ✅ | 5min, 30min, 2h | 3 |
| Sonstige (`UNKNOWN`) | ✅ | 1min, 5min, 30min | 3 |

### 3.4 Backoff-Berechnung

```typescript
function nextRetryAt(errorClass: string, attemptCount: number, retryAfterHeader?: number): Date {
  if (errorClass === 'MSGRAPH_QUOTA_EXCEEDED' && retryAfterHeader) {
    return addSeconds(now(), retryAfterHeader);
  }
  const schedules = {
    'MSGRAPH_503': [60, 300, 900, 1800, 3600],
    'MSGRAPH_504': [60, 300, 900, 1800, 3600],
    'NETWORK_TIMEOUT': [30, 120, 300, 900, 1800],
    'MSGRAPH_500': [300, 1800, 7200],
    'UNKNOWN': [60, 300, 1800],
  };
  const seconds = schedules[errorClass]?.[attemptCount - 1] ?? 60;
  return addSeconds(now(), seconds);
}
```

### 3.5 Send-Queue-Drain bei Token-Reauth

Wenn User nach Token-Expired neu re-auth'd:
1. POST `/api/v1/integrations/outlook/connect` Success
2. Backend triggert `email.queue.drain.<actor_id>` Worker-Job
3. Worker setzt alle `dead_lettered`-Jobs mit `last_error_code='MSGRAPH_TOKEN_EXPIRED'` zurück auf `pending` mit `attempt_count=0`
4. Send-Worker pickt sie auf nächstem Tick auf
5. User sieht Banner „N gestaute Mails werden jetzt gesendet"

### 3.6 User-Surface

**Compose-Drawer:**
- Click „Senden" → Mail wird in Queue gepusht (`status='pending'`)
- Toast „Mail in Queue · wird zugestellt" (kein Spinner-Block)
- Drawer schließt sofort, User kann weiterarbeiten

**Outbox-Indicator:**
- Header zeigt Badge wenn `email_send_queue.status IN ('pending', 'sending', 'failed')` mit Count
- Click öffnet Mini-Drawer mit Status-Liste + Manual-Retry-Button

**Bei `dead_lettered`:**
- Banner „N Mails konnten nicht zugestellt werden · [Details]"
- Click öffnet Drawer mit Liste + Reason pro Mail
- Optionen pro Mail: `Erneut versuchen` · `Verwerfen` · `Bearbeiten`

## 4. MS-Graph Komplett-Outage

Behandlung in Runbook 4 (Backend-v2.8 §45) sowie `wiki/meta/digests/backend-architecture-digest.md` §Runbooks.

**CRM-Verhalten:**
- Send-Queue füllt sich mit `MSGRAPH_503`-Jobs
- Health-Check-Worker setzt Outlook-Status auf `degraded` nach 3 fehlgeschlagenen Health-Pings
- Admin-Tab 9 (Debug) zeigt rote KPI „Outlook-Health: degraded"
- Auto-Resume: sobald MS-Graph wieder erreichbar, Worker drain'd Queue automatisch (Backoff-Schedules sorgen für gestaffeltes Replay)

**Kein Temporary-Outlook-Fallback** (z.B. SMTP-Fallback) — Komplexität überwiegt Nutzen für Phase-1. MS-Graph-Outages sind selten (< 99.9% Uptime laut MS-Status-History).

## 5. Offene Fragen / Folge-Specs

| # | Frage | Vorschlag |
|---|-------|-----------|
| 1 | Send-Queue als eigene Tabelle ODER innerhalb `fact_event_queue` mit `job_type='email.send'`? | Eigene Tabelle (`fact_email_send_queue`) — Email-spezifische Spalten (recipient_to/cc/bcc, body_html, attachments) lohnen sich nicht im generischen Queue-Schema |
| 2 | Webhook-Verlust für Inbox-Sync: Polling-Fallback wenn delta-Sync stillsteht? | Watchdog-Worker prüft `last_inbox_sync_at` jeder Connection · bei > 30 min ohne Webhook: re-init-Subscription (MS-Graph-Subscriptions verfallen nach 4230 min default) |
| 3 | Admin-Notification-Channel bei `dead_lettered`-Spike: Sentry oder direkter Slack-Webhook? | Sentry (bestehende Infra) · Slack erst Phase-2 wenn Volumes größer |
| 4 | User-Visible-Banner bei degraded-Status: nur Admin oder alle User? | Alle User · transparente Kommunikation (Banner: „Outlook-Service derzeit langsam · Mails werden gepuffert") |
| 5 | Permanent-Failed-Mail-Retention: Wie lange in `dead_lettered`-Status behalten? | 30 Tage · danach Auto-Soft-Delete (Audit-Trail bleibt in `fact_audit_log`) |

## 6. Patch-Bedarf für Folge-Sessions

Damit Send-Queue-Retry-Policy implementiert werden kann:

- `ARK_DATABASE_SCHEMA_PATCH_v1_6_to_v1_7_email_queue.md` — neue Tabelle `fact_email_send_queue` + Indizes
- `ARK_BACKEND_ARCHITECTURE_PATCH_v2_8_to_v2_9_email_failsafe.md` — Worker `email.send.worker.ts` + Retry-Klassifizierung + neue Events (`email.send.queued/sent/failed/dead_lettered`)
- `ARK_FRONTEND_FREEZE_PATCH_v1_13_to_v1_14_email_outbox.md` — Outbox-Indicator + Compose-Toast-Pattern + Dead-Letter-Drawer

Optional Phase-2:
- SMTP-Fallback für Notfall-Send (extrem selten benötigt)
- Bulk-Resend-API für Admin (nach längerer Outage)

## 7. Referenzen

- Email-Modul-Detail: [[email-system]]
- Admin-Debug-Tab: [[../specs/ARK_ADMIN_DEBUG_SCHEMA_v1_0.md]] (Tab 9 Sub-Tabs)
- Backend-Endpoints: `Grundlagen MD/ARK_BACKEND_ARCHITECTURE_v2_8.md` §42 (Admin-Diagnose), §45 Runbook 4
- OAuth-Flow: `specs/ARK_EMAIL_KALENDER_DETAILMASKE_INTERACTIONS_v0_1.md` §TEIL 8

---

**Stand:** 2026-04-30 · **Status:** Index + Send-Queue-Retry-Policy (NEU) · Folge-Patches in §6 dokumentiert.
