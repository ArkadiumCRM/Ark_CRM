---
title: "ARK Database Schema Patch v1.6 → v1.7 · Email-Send-Queue (Outlook-Failsafe)"
type: spec
module: email
version: 1.7
created: 2026-04-30
updated: 2026-04-30
status: Erstentwurf · Phase-1-A Sync-Patch
sources: [
  "Grundlagen MD/ARK_DATABASE_SCHEMA_v1_6.md",
  "wiki/concepts/outlook-failsafe.md",
  "specs/ARK_EMAIL_KALENDER_DETAILMASKE_INTERACTIONS_v0_1.md"
]
tags: [schema-patch, db-migration, email, outlook, failsafe, send-queue, rls, enums]
---

# ARK Database Schema · Patch v1.6 → v1.7 · Email-Send-Queue

**Stand:** 2026-04-30
**Status:** Erstentwurf · Phase-1-A Sync-Patch
**Quellen:**
- `Grundlagen MD/ARK_DATABASE_SCHEMA_v1_6.md` (Vorgänger)
- `wiki/concepts/outlook-failsafe.md` §3 Send-Queue-Retry-Policy (Single-Source-of-Truth)
- `specs/ARK_EMAIL_KALENDER_DETAILMASKE_INTERACTIONS_v0_1.md` (Email-System-Kontext)

**Vorrang:** Stammdaten > Schema > Patch > Mockups

---

## 0. ZIELBILD (was ändert dieser Patch)

Dieser Patch führt die Tabelle `fact_email_send_queue` ein, die als persistente Send-Queue für ausgehende E-Mails via MS-Graph dient. Transiente Fehler (5xx, 429, Network-Timeout) werden damit nicht mehr direkt an den User gegeben, sondern gepuffert und via Worker-Retry aufgelöst. Ergänzend werden zwei neue Enum-Types (`email_send_status`, `email_error_class`) sowie die zugehörigen Indizes und RLS-Policies definiert.

**Abhängigkeiten:** Backend-Patch v2.9 benötigt diese Tabelle für `email-send.worker.ts`. FE-Patch v1.14 baut den Outbox-Indicator darauf auf.

---

## 1. Neue Enum-Types

### 1.1 `email_send_status`

```sql
CREATE TYPE ark.email_send_status AS ENUM (
    'pending',        -- In Queue, wartet auf nächsten Worker-Tick
    'sending',        -- Worker hält den Job gerade (Inflight-Lock)
    'sent',           -- Erfolgreich via MS-Graph gesendet
    'failed',         -- Letzter Versuch fehlgeschlagen, wird erneut versucht
    'dead_lettered'   -- Max-Retries erschöpft oder nicht-retriable Fehler
);

COMMENT ON TYPE ark.email_send_status IS
    'Status einer ausgehenden Mail in fact_email_send_queue.';
```

### 1.2 `email_error_class`

```sql
CREATE TYPE ark.email_error_class AS ENUM (
    'MSGRAPH_TOKEN_EXPIRED',       -- 401 · Token abgelaufen → direkt dead_lettered, Reauth nötig
    'MSGRAPH_PERMISSION_DENIED',   -- 403 · Berechtigung entzogen → direkt dead_lettered, Admin-Mail
    'MSGRAPH_RECIPIENT_INVALID',   -- 400 · Empfänger ungültig → direkt dead_lettered, User-Banner
    'MSGRAPH_QUOTA_EXCEEDED',      -- 429 · Rate-Limit → exponential backoff mit Retry-After-Header
    'MSGRAPH_503',                 -- 503 · Transient Service Unavailable → gestaffelter Retry
    'MSGRAPH_504',                 -- 504 · Gateway Timeout → gestaffelter Retry
    'MSGRAPH_500',                 -- 500 · MS-Server-Bug (selten) → 3 Retries mit langem Backoff
    'NETWORK_TIMEOUT',             -- Netzwerk-Timeout CRM ↔ MS-Graph → schnelle Retries
    'UNKNOWN'                      -- Unklassifizierter Fehler → 3 Retries mit moderatem Backoff
);

COMMENT ON TYPE ark.email_error_class IS
    'Klassifizierung von MS-Graph-Fehlern für Retry-Policy in email-send.worker.ts.
     Jede Klasse hat eine eigene Retry-Policy (Backoff-Schedule + Max-Retries),
     definiert in wiki/concepts/outlook-failsafe.md §3.3.';
```

---

## 2. Neue Tabelle `fact_email_send_queue`

```sql
CREATE TABLE ark.fact_email_send_queue (
    id                  uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id           uuid        NOT NULL REFERENCES ark.dim_tenant(id) ON DELETE CASCADE,

    -- Sender
    actor_id            uuid        NOT NULL REFERENCES ark.dim_mitarbeiter(id) ON DELETE RESTRICT,

    -- Empfänger
    recipient_to        text[]      NOT NULL CHECK (array_length(recipient_to, 1) >= 1),
    recipient_cc        text[]      NOT NULL DEFAULT '{}',
    recipient_bcc       text[]      NOT NULL DEFAULT '{}',

    -- Inhalt
    subject             text        NOT NULL CHECK (length(subject) > 0),
    body_html           text        NOT NULL,
    attachments         jsonb       NOT NULL DEFAULT '[]',
    -- Format: [{"file_ref": "...", "filename": "...", "mime_type": "..."}]

    -- Tracking
    template_key        text        NULL,   -- NULL = Freitext-Mail; gesetzt = Template-Spur
    linked_entity_id    uuid        NULL,   -- Verknüpfte Entity für fact_history-Eintrag nach Send
    linked_entity_type  text        NULL,   -- z.B. 'candidate', 'account', 'process', 'mandate'

    -- Queue-Status
    status              ark.email_send_status NOT NULL DEFAULT 'pending',
    attempt_count       int         NOT NULL DEFAULT 0 CHECK (attempt_count >= 0),
    last_attempt_at     timestamptz NULL,
    next_retry_at       timestamptz NOT NULL DEFAULT now(),
    -- next_retry_at = now() für initialen pending-Zustand (sofortiger erster Versuch)

    -- Fehler-Details
    last_error_code     ark.email_error_class NULL,
    last_error_detail   text        NULL,   -- Stack/Response-Body (max 5000 Zeichen in App-Layer)

    -- Idempotenz
    idempotency_key     text        NOT NULL,
    -- Format: '<actor_id>:<sha256(recipient_to+subject+body_html)>:<created_at_ms>'
    -- Verhindert Doppel-Send bei Retry-Races

    -- Zeitstempel
    created_at          timestamptz NOT NULL DEFAULT now(),
    updated_at          timestamptz NOT NULL DEFAULT now(),

    CONSTRAINT fact_email_send_queue_idempotency_unique UNIQUE (idempotency_key)
);

COMMENT ON TABLE ark.fact_email_send_queue IS
    'Persistente Send-Queue für ausgehende E-Mails via MS-Graph.
     Resilience: transiente Fehler werden gepuffert und via email-send.worker.ts
     mit Retry-Policy aufgelöst (statt direkter Failure-Toast an User).
     Single-Source-of-Truth: wiki/concepts/outlook-failsafe.md §3.';

COMMENT ON COLUMN ark.fact_email_send_queue.attachments IS
    'JSON-Array von File-Refs: [{file_ref, filename, mime_type}].
     file_refs zeigen auf fact_documents oder temporäre Upload-Keys.';
COMMENT ON COLUMN ark.fact_email_send_queue.idempotency_key IS
    'Einzigartiger Key pro Mail-Versuch. Format: <actor_id>:<hash>:<timestamp_ms>.
     Verhindert Doppel-Send bei parallelen Worker-Läufen oder Retry-Races.';
COMMENT ON COLUMN ark.fact_email_send_queue.next_retry_at IS
    'Früheste Zeit für nächsten Versuch. Initial = now() (sofort).
     Nach Fehler: berechnet von email-send.worker.ts gemäss Backoff-Schedule
     (wiki/concepts/outlook-failsafe.md §3.4).';
COMMENT ON COLUMN ark.fact_email_send_queue.status IS
    'pending → Worker picked up → sending → MS-Graph-OK → sent
                                            └→ MS-Graph-Fehler → failed (retry) oder dead_lettered (stop)';
```

---

## 3. Indizes

```sql
-- Primary Worker-Poll-Index: WHERE status='pending' AND next_retry_at <= now()
CREATE INDEX idx_email_queue_poll
    ON ark.fact_email_send_queue (status, next_retry_at)
    WHERE status IN ('pending', 'failed');

-- Actor-Status-Index: für Outbox-Indicator (User sieht eigene offene/failed Mails)
CREATE INDEX idx_email_queue_actor_status
    ON ark.fact_email_send_queue (actor_id, status)
    WHERE status IN ('pending', 'sending', 'failed', 'dead_lettered');

-- Tenant-Status-Index: für Admin-DLQ-View + Dead-Letter-Banner
CREATE INDEX idx_email_queue_tenant_status
    ON ark.fact_email_send_queue (tenant_id, status, created_at DESC)
    WHERE status IN ('failed', 'dead_lettered');

-- Idempotency-Lookup: bereits durch UNIQUE-Constraint indexed,
-- aber explizit für Clarity dokumentiert:
-- UNIQUE INDEX: fact_email_send_queue_idempotency_unique (idempotency_key)
```

---

## 4. RLS-Policy

```sql
-- RLS aktivieren
ALTER TABLE ark.fact_email_send_queue ENABLE ROW LEVEL SECURITY;

-- Tenant-Isolation (Standard-Policy für alle Rollen)
CREATE POLICY email_queue_tenant_isolation
    ON ark.fact_email_send_queue
    USING (tenant_id = current_setting('app.tenant_id')::uuid);

-- User-Scope: User sieht nur eigene Queue-Einträge (für Outbox-Indicator + Mini-Drawer)
CREATE POLICY email_queue_actor_scope
    ON ark.fact_email_send_queue
    FOR SELECT
    USING (
        tenant_id = current_setting('app.tenant_id')::uuid
        AND (
            actor_id = current_setting('app.user_id')::uuid
            OR current_setting('app.user_role') IN ('admin', 'head')
        )
    );

-- Write: User darf nur eigene Einträge anlegen (INSERT mit actor_id = current_user)
CREATE POLICY email_queue_insert_own
    ON ark.fact_email_send_queue
    FOR INSERT
    WITH CHECK (
        tenant_id = current_setting('app.tenant_id')::uuid
        AND actor_id = current_setting('app.user_id')::uuid
    );

-- Worker-Bypass: email-send.worker.ts benötigt vollständigen Read/Write-Zugriff
-- (analog zu ark_worker_service in DB v1.6 §8)
CREATE POLICY email_queue_worker_bypass
    ON ark.fact_email_send_queue
    TO ark_worker_service
    USING (TRUE)
    WITH CHECK (TRUE);
```

---

## 5. Updated-At-Trigger

```sql
-- Standard-Trigger-Pattern (analog allen anderen fact_*-Tabellen)
CREATE TRIGGER email_queue_updated_at
    BEFORE UPDATE ON ark.fact_email_send_queue
    FOR EACH ROW
    EXECUTE FUNCTION ark.set_updated_at();
```

---

## 6. Berechtigungen

```sql
-- Normaler User: INSERT (eigene Mails queuen) + SELECT (Outbox-Indicator)
GRANT INSERT, SELECT ON ark.fact_email_send_queue TO ark_user;

-- Admin/Head: SELECT alle Einträge des Tenants (Admin-DLQ-View)
-- Wird bereits via RLS-Policy email_queue_actor_scope ermöglicht (kein extra GRANT nötig)

-- Worker-Service: vollständig (INSERT, UPDATE, SELECT, DELETE für Cleanup)
GRANT INSERT, UPDATE, SELECT, DELETE ON ark.fact_email_send_queue TO ark_worker_service;

-- Power-BI Reader: kein Zugriff auf Email-Queue (kein GRANT)
```

---

## 7. Retention-Cleanup

```sql
-- Retention-Hinweis (kein DDL-Patch, dokumentativ):
-- dead_lettered-Einträge: 30 Tage Retention (wiki/concepts/outlook-failsafe.md §5 Q5)
-- sent-Einträge: 7 Tage (Audit-Trail liegt in fact_audit_log + fact_history)
--
-- Cleanup via retention.worker.ts (bestehend) - neues Job-Pattern:
-- DELETE FROM ark.fact_email_send_queue
--   WHERE (status = 'sent'          AND created_at < now() - INTERVAL '7 days')
--      OR (status = 'dead_lettered' AND created_at < now() - INTERVAL '30 days');
--
-- Vor Delete: Insert summary in fact_audit_log mit action='email.queue.cleanup',
-- payload={sent_deleted: N, dead_lettered_deleted: M, period: '7d/30d'}
```

---

## 8. Migration-Reihenfolge

1. CREATE TYPE `email_send_status`
2. CREATE TYPE `email_error_class`
3. CREATE TABLE `fact_email_send_queue`
4. CREATE INDEX × 3 (`idx_email_queue_poll`, `idx_email_queue_actor_status`, `idx_email_queue_tenant_status`)
5. ALTER TABLE ENABLE ROW LEVEL SECURITY
6. CREATE POLICY × 4
7. CREATE TRIGGER `email_queue_updated_at`
8. GRANT Permissions
9. Verify: EXPLAIN auf Worker-Poll-Query (`WHERE status='pending' AND next_retry_at <= now()`), Check RLS mit Test-User

---

## 9. Rollback

```sql
-- Partieller Rollback (Tabelle noch leer):
DROP TABLE IF EXISTS ark.fact_email_send_queue CASCADE;
DROP TYPE IF EXISTS ark.email_send_status CASCADE;
DROP TYPE IF EXISTS ark.email_error_class CASCADE;

-- Nach Datenbefüllung: Rollback nur via Backup (destruktiv)
```

---

## 10. SYNC-IMPACT

| Grundlagen-Datei | Änderung erforderlich |
|------------------|-----------------------|
| `ARK_BACKEND_ARCHITECTURE_v2_8.md` | +Worker `email-send.worker.ts` + `email-send-drain.worker.ts` + 4 neue Events → **Backend-Patch v2.9** |
| `ARK_FRONTEND_FREEZE_v1_13.md` | +Outbox-Indicator + Mini-Drawer + Dead-Letter-Banner → **FE-Patch v1.14** |
| `ARK_STAMMDATEN_EXPORT_v1_6.md` | Kein Patch nötig (keine neuen dim_*-Stammdaten) |
| `ARK_GESAMTSYSTEM_UEBERSICHT_v1_5.md` | Changelog-Eintrag „Email-Send-Queue v1.7" (Folge-Patch Gesamtsystem) |

---

**Ende v1.7.** Apply-Reihenfolge: DB-Patch v1.7 → Backend-Patch v2.9 → FE-Patch v1.14.
Backend-Patch v2.9 hat Abhängigkeit auf diese Tabelle (Worker-SQL).
