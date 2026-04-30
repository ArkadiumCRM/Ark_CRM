---
title: "ARK Backend Architecture Patch v2.8 → v2.9 · Phase-1-A Sync"
type: spec
module: stammdaten, email, powerbi
version: 2.9
created: 2026-04-30
updated: 2026-04-30
status: Erstentwurf · Phase-1-A Sync-Patch
sources: [
  "Grundlagen MD/ARK_BACKEND_ARCHITECTURE_v2_8.md",
  "specs/ARK_STAMMDATEN_VOLLANSICHT_INTERACTIONS_v0_1.md",
  "wiki/concepts/outlook-failsafe.md",
  "specs/ARK_POWER_BI_INTEGRATION_PLAN_v0_1.md",
  "specs/ARK_DATABASE_SCHEMA_PATCH_v1_6_to_v1_7_email_queue.md"
]
tags: [backend, patch, stammdaten, email, powerbi, workers, events, endpoints, phase1a]
---

# ARK Backend Architecture · Patch v2.8 → v2.9 · Phase-1-A Sync

**Stand:** 2026-04-30
**Status:** Erstentwurf · Phase-1-A Sync-Patch
**Quellen:**
- `Grundlagen MD/ARK_BACKEND_ARCHITECTURE_v2_8.md` (Vorgänger)
- `specs/ARK_STAMMDATEN_VOLLANSICHT_INTERACTIONS_v0_1.md` §4.1 (22 Endpoints)
- `wiki/concepts/outlook-failsafe.md` §3 (Send-Queue-Retry-Policy)
- `specs/ARK_POWER_BI_INTEGRATION_PLAN_v0_1.md` §8 (Embed-Token-Flow)
- `specs/ARK_DATABASE_SCHEMA_PATCH_v1_6_to_v1_7_email_queue.md` (DB-Voraussetzung)

**Vorrang:** Stammdaten > Schema > Patch > Mockups

**Voraussetzung:** DB-Patch v1.7 (`fact_email_send_queue` + Enums) muss vor diesem Patch deployed sein.

---

## 0. ZIELBILD (was ändert dieser Patch)

Dieser Patch aktiviert drei neue Endpoint-Namespaces und Worker-Sets für Phase-1-A:

1. **Stammdaten-Vollansicht** (`/api/v1/stammdaten/*`): 22 Endpoints für Browse, Edit, Batch-Import, Audit, Export und Translations der 67 `dim_*`-Kataloge.
2. **Email-Send-Worker** (Outlook-Failsafe): `email-send.worker.ts` + `email-send-drain.worker.ts` mit Retry-Policy + Backoff-Schedule + 4 neuen Events.
3. **Power-BI-Embed-Token-Endpoint** (Phase-1-Greenfield): `POST /api/v1/performance/powerbi/embed-token` mit Service-Principal-Auth gegen Power-BI REST API.

---

## 1. Stammdaten-Vollansicht — Endpoints (~22)

Namespace: `/api/v1/stammdaten/`
Auth: JWT (alle Rollen können lesen; Admin-only für Mutationen)
Implementierungs-Referenz: `specs/ARK_STAMMDATEN_VOLLANSICHT_INTERACTIONS_v0_1.md` §4.1

### 1.1 Read-Endpoints (All-Roles)

```
GET    /api/v1/stammdaten/summary
       Zweck: Dashboard-Aggregat (67 Kataloge, Gesamtanzahl Einträge, Last-Edit)
       Auth: JWT · All roles
       Response: { catalog_count: 67, entry_count: N, last_edited_at: ISO, last_edited_by: 'PW' }
       Cache: 5 min Backend-Memory

GET    /api/v1/stammdaten/search?q=<string>&limit=20&offset=0
       Zweck: Cross-Catalog-Volltextsuche (Code + Label DE/EN/FR + Beschreibung)
       Auth: JWT · All roles
       Query-Params: q (min 2 Zeichen) · limit (default 20, max 50) · offset · category_slug
       Response: { results: [{code, label_de, catalog, category_slug, match_field}], total: N }
       Debounce-Empfehlung: 250ms im Frontend

GET    /api/v1/stammdaten/categories
       Zweck: Inventar der 8 Kategorien mit Metadaten
       Auth: JWT · All roles
       Response: { categories: [{slug, label_de, catalog_count, icon}] }
       Cache: Session (statisch)

GET    /api/v1/stammdaten/categories/:slug/stats
       Zweck: Stat-Strip-Werte pro Kategorie (für Tab-Wechsel)
       Auth: JWT · All roles
       Path-Params: slug (workflow|communication|skills|branchen-geo|mitarbeiter-account|mandat-honorar-assessment|system-scraper|governance)
       Response: { catalog_count: N, entry_count: N, last_updated_at: ISO, used_in_entities_count: N }
       Cache: 5 min · Invalidation bei Mutation in Kategorie

GET    /api/v1/stammdaten/categories/:slug/catalogs
       Zweck: Card-Grid-Daten pro Kategorie
       Auth: JWT · All roles
       Query-Params: active · missing_translation · top10 · modified_7d · sort (alpha|usage)
       Response: { catalogs: [{slug, label_de, description, entry_count, active_count, tags, last_updated_at}] }
       Cache: 5 min

GET    /api/v1/stammdaten/dim/:catalog
       Zweck: Tabellen-Daten eines Katalogs (paginiert, filterbar, sortierbar)
       Auth: JWT · All roles
       Path-Params: catalog (snake_case, z.B. activity_types)
       Query-Params: q · active · missing_lang · sort (label_de:asc|code:asc|sort_order:asc) · limit (default 50) · offset
       Response: { entries: [{code, label_de, label_en, label_fr, description, sort_order, active, used_count, updated_at, updated_by}], total: N }

GET    /api/v1/stammdaten/dim/:catalog/entries/:code
       Zweck: Eintrag-Detail (Tab 1 im Detail-Drawer)
       Auth: JWT · All roles
       Response: vollständiger Eintrag-Record + Metadaten

GET    /api/v1/stammdaten/dim/:catalog/entries/:code/usage?limit=50
       Zweck: Verwendungs-Stats (Top-50 Referenzen aus fact_*-Tabellen)
       Auth: JWT · All roles
       Response: { usages: [{entity_type, entity_id, entity_label, context}], total_count: N }
       Cache: 5 min Backend-Memory (Aggregation teuer)

GET    /api/v1/stammdaten/dim/:catalog/entries/:code/audit?since=30d
       Zweck: Eintrag-Audit-History (Tab 3 im Detail-Drawer)
       Auth: JWT · Admin + eigene Änderungen für non-Admin
       Query-Params: since (default 30d · all · custom ISO-Range) · action_type (multi) · actor (multi)
       Response: { entries: [{timestamp, action, actor, field, old_value, new_value}], total: N }

GET    /api/v1/stammdaten/dim/:catalog/entries/:code/translations
       Zweck: Multi-Lang-Werte (Tab 4 im Detail-Drawer, nur Multi-Lang-Kataloge)
       Auth: JWT · All roles
       Response: { translations: [{lang, label, description, updated_at, updated_by}] }

GET    /api/v1/stammdaten/dim/:catalog/export.csv
       Zweck: CSV-Export eines Katalogs (UTF-8 BOM, Excel-kompatibel)
       Auth: JWT · All roles
       Response: text/csv mit Spalten: code,label_de,label_en,label_fr,description,sort_order,active,used_count,updated_at,updated_by
       Audit-Event: audit.config.export

GET    /api/v1/stammdaten/categories/:slug/export.zip
       Zweck: ZIP-Export aller Kataloge einer Kategorie (eine CSV pro Katalog)
       Auth: JWT · All roles
       Response: application/zip
       Audit-Event: audit.config.export

GET    /api/v1/stammdaten/export-all.zip
       Zweck: Komplett-Export aller 67 Kataloge als ZIP
       Auth: JWT · Admin only (403 für non-Admin)
       Response: application/zip
       Audit-Event: audit.config.export (scope: 'all')
```

### 1.2 Mutations-Endpoints (Admin only)

```
POST   /api/v1/stammdaten/edit-mode
       Zweck: Edit-Modus aktivieren (Session-Start, Audit-Pflicht)
       Auth: JWT · Admin
       Body: { actor_id: uuid }
       Response: { session_id: uuid, started_at: ISO }
       Side-Effect: INSERT fact_audit_log (action='config.edit_mode.enabled')
       Emit: audit.config.edit_mode_enabled

DELETE /api/v1/stammdaten/edit-mode
       Zweck: Edit-Modus deaktivieren
       Auth: JWT · Admin
       Body: { session_id: uuid }
       Response: { ended_at: ISO, mutations_count: N }
       Side-Effect: INSERT fact_audit_log (action='config.edit_mode.disabled', payload={started_at, ended_at, mutations_count})
       Emit: audit.config.edit_mode_disabled

POST   /api/v1/stammdaten/dim/:catalog/entries
       Zweck: Neuen Eintrag anlegen
       Auth: JWT · Admin (außer Locked/External → 403)
       Headers: X-Edit-Session-Id · X-Actor-Id
       Body: { code, label_de, label_en?, label_fr?, description?, sort_order?, active? }
       Response: 200 + vollständiger Eintrag
       Validation: code unique, snake_case, label_de Pflicht
       Side-Effect: INSERT fact_audit_log (action='config.<dim>.create')
       Emit: config.<dim>.created

PATCH  /api/v1/stammdaten/dim/:catalog/entries/:code
       Zweck: Eintrag-Update (Inline-Edit oder Soft-Disable)
       Auth: JWT · Admin (außer Locked/External → 403)
       Headers: If-Match: <updated_at> · X-Edit-Session-Id · X-Actor-Id
       Body: Partial<{label_de, label_en, label_fr, description, sort_order, active}>
       Response: 200 + vollständiger Eintrag | 409 Conflict {current_value, updated_at, updated_by}
       Side-Effect: INSERT fact_audit_log (action='config.<dim>.update' | 'config.<dim>.disable' | 'config.<dim>.enable')
       Emit: config.<dim>.updated | config.<dim>.disabled | config.<dim>.enabled

DELETE /api/v1/stammdaten/dim/:catalog/entries/:code
       Zweck: Hard-Delete (nur bei 0 FK-Verwendungen)
       Auth: JWT · Admin
       Headers: X-Edit-Session-Id · X-Actor-Id
       Body: { reason: string (min 10 Zeichen) }
       Response: 200 | 409 {fk_count: N, fk_tables: [...]} (FK-Block)
       Side-Effect: INSERT fact_audit_log (action='config.<dim>.delete', payload={code, label_de, reason, fk_count_at_delete: 0})
       Emit: config.<dim>.deleted

PATCH  /api/v1/stammdaten/dim/:catalog/reorder
       Zweck: Sort-Order-Bulk-Update (Drag&Drop)
       Auth: JWT · Admin
       Headers: X-Edit-Session-Id · X-Actor-Id
       Body: { moves: [{code, from, to}] }
       Response: 200 + aktualisierte Entry-Liste
       Atomare Transaction über alle moves
       Side-Effect: INSERT fact_audit_log (action='config.<dim>.reorder')
       Emit: config.<dim>.reordered

POST   /api/v1/stammdaten/dim/:catalog/batch-import/preview
       Zweck: CSV-Upload + Diff-Preview (Step 2 im Batch-Import-Flow)
       Auth: JWT · Admin
       Content-Type: multipart/form-data (CSV-File, max 5 MB, UTF-8 mit/ohne BOM)
       Response: { session_id: uuid, new_count: N, update_count: N, unchanged_count: N, not_in_csv_count: N, errors: [{row, field, message}] }
       Session-TTL: 10 min (dann abgelaufen → Client muss neu hochladen)

POST   /api/v1/stammdaten/dim/:catalog/batch-import/apply
       Zweck: CSV-Batch-Apply (Step 3, nach Preview-Approval)
       Auth: JWT · Admin
       Body: { import_session_id: uuid }
       Response: 200 { inserts: N, updates: M } | 409 { reason: 'session_expired' | 'session_not_found' }
       Atomare Transaction (bei einem Fehler: kompletter Rollback)
       Side-Effect: INSERT fact_audit_log (action='config.<dim>.batch_import', payload={session_id, inserts, updates, source_file})
       Emit: config.<dim>.batch_imported

PUT    /api/v1/stammdaten/dim/:catalog/entries/:code/translations
       Zweck: Multi-Lang-Werte aktualisieren (alle Sprachen auf einmal)
       Auth: JWT · Admin (Multi-Lang-Kataloge only)
       Headers: X-Edit-Session-Id · X-Actor-Id
       Body: { translations: [{lang: 'en'|'fr', label, description?}] }
       Response: 200 + aktualisierter translations-Record
       Side-Effect: INSERT fact_audit_log (action='config.<dim>.translation_update')
       Emit: config.<dim>.updated
```

### 1.3 Header-Konventionen (alle Mutations-Endpoints)

```
If-Match: <updated_at>        -- Conflict-Detection für PATCH/DELETE
X-Actor-Id: <user_uuid>       -- Audit-Tracking
X-Edit-Session-Id: <uuid>     -- Edit-Modus-Session-Validation
```

### 1.4 Response-Standards

```
200  { entry | entries | ... }   -- Success
400  { errors: [{field, message}] }   -- Validation-Fehler
403  { reason: "admin_required" | "locked_catalog" | "external_managed" }
409  { current_value, updated_at, updated_by }   -- Conflict
409  { fk_count: N, fk_tables: [...] }   -- FK-Block bei Delete
422  { errors: [...] }   -- Batch-Import Validation-Fehler mit Zeilennummer
```

### 1.5 Stammdaten-Edit-Modus-Session (Server-Side)

```typescript
// Tabelle: stammdaten_edit_sessions (In-Memory oder Redis, kein DDL-Patch nötig)
// Felder: session_id, actor_id, tenant_id, started_at, last_activity_at
// Idle-Timeout: 60 Minuten
// Cleanup-Cron: alle 15 Minuten (stale Sessions löschen)
// Validation: jeder Mutations-Endpoint prüft X-Edit-Session-Id gegen Session-Store
//             Bei abgelaufener Session: 401 { reason: 'edit_session_expired' }
```

---

## 2. Email-Send-Worker (Outlook-Failsafe)

Implementierungs-Referenz: `wiki/concepts/outlook-failsafe.md` §3
DB-Voraussetzung: `fact_email_send_queue` (DB-Patch v1.7)

### 2.1 Worker `email-send.worker.ts`

```typescript
// Datei: workers/email-send.worker.ts
// Pattern: BullMQ (analog zu anderen Workers in Backend-v2.8 §Workers)
// Cron-Poll: alle 30 Sekunden

// Cron-Job (PgBoss)
schedule('email-send-poll', '*/30 * * * * *', async () => {
  // Batch: bis 20 Jobs pro Tick
  const jobs = await db.query(`
    SELECT id, actor_id, recipient_to, recipient_cc, recipient_bcc,
           subject, body_html, attachments, template_key,
           linked_entity_id, linked_entity_type,
           attempt_count, idempotency_key
    FROM ark.fact_email_send_queue
    WHERE status IN ('pending', 'failed')
      AND next_retry_at <= now()
    ORDER BY next_retry_at ASC
    LIMIT 20
    FOR UPDATE SKIP LOCKED
  `);

  for (const job of jobs) {
    await queue.add('email-send', { job_id: job.id });
  }
});

// Worker
queue.process('email-send', async (task) => {
  const { job_id } = task.data;

  // Inflight-Lock: status = 'sending'
  await db.query(
    `UPDATE ark.fact_email_send_queue
     SET status='sending', last_attempt_at=now(), attempt_count=attempt_count+1
     WHERE id=$1 AND status IN ('pending','failed')`,
    [job_id]
  );

  const job = await db.queryOne(
    `SELECT * FROM ark.fact_email_send_queue WHERE id=$1`,
    [job_id]
  );
  if (!job) return; // Race-Condition: anderer Worker hat diesen Job schon

  try {
    // Token-Check für actor
    const token = await getValidMsGraphToken(job.actor_id);

    // MS-Graph Send
    await msGraphSendMail(token, {
      to: job.recipient_to,
      cc: job.recipient_cc,
      bcc: job.recipient_bcc,
      subject: job.subject,
      body: job.body_html,
      attachments: job.attachments,
    });

    // Success
    await db.query(
      `UPDATE ark.fact_email_send_queue
       SET status='sent', updated_at=now()
       WHERE id=$1`,
      [job_id]
    );

    // fact_history-Eintrag (wenn linked_entity_id gesetzt)
    if (job.linked_entity_id) {
      await insertHistoryEntry({
        actor_id: job.actor_id,
        entity_id: job.linked_entity_id,
        entity_type: job.linked_entity_type,
        activity_type_code: 'email_sent',
        payload: { subject: job.subject, recipient_to: job.recipient_to },
      });
    }

    emit('email.send.sent', {
      job_id,
      actor_id: job.actor_id,
      recipient_count: job.recipient_to.length,
    });

  } catch (err) {
    const errorClass = classifyMsGraphError(err);
    const isRetriable = !['MSGRAPH_TOKEN_EXPIRED', 'MSGRAPH_PERMISSION_DENIED', 'MSGRAPH_RECIPIENT_INVALID'].includes(errorClass);
    const maxRetries = getMaxRetries(errorClass); // siehe §2.3 Tabelle
    const newStatus = (!isRetriable || job.attempt_count >= maxRetries) ? 'dead_lettered' : 'failed';

    await db.query(
      `UPDATE ark.fact_email_send_queue
       SET status=$2,
           last_error_code=$3,
           last_error_detail=$4,
           next_retry_at=$5,
           updated_at=now()
       WHERE id=$1`,
      [
        job_id,
        newStatus,
        errorClass,
        err.message?.slice(0, 5000),
        newStatus === 'failed' ? computeNextRetryAt(errorClass, job.attempt_count, err.retryAfter) : null,
      ]
    );

    if (newStatus === 'dead_lettered') {
      emit('email.send.dead_lettered', {
        job_id,
        actor_id: job.actor_id,
        error_class: errorClass,
        attempt_count: job.attempt_count,
      });
    } else {
      emit('email.send.failed', {
        job_id,
        actor_id: job.actor_id,
        error_class: errorClass,
        attempt_count: job.attempt_count,
        next_retry_at: computeNextRetryAt(errorClass, job.attempt_count, err.retryAfter),
      });
    }
  }
});
```

### 2.2 Worker `email-send-drain.worker.ts`

```typescript
// Datei: workers/email-send-drain.worker.ts
// Trigger: POST /api/v1/integrations/outlook/connect Success (Token-Reauth)
// Zweck: dead_lettered-Jobs mit MSGRAPH_TOKEN_EXPIRED zurück auf pending setzen

// Event-Trigger: 'outlook.token.refreshed' (nach erfolgreichem OAuth-Reauth)
queue.process('email-send-drain', async (task) => {
  const { actor_id } = task.data;

  const result = await db.query(
    `UPDATE ark.fact_email_send_queue
     SET status='pending',
         attempt_count=0,
         next_retry_at=now(),
         last_error_code=NULL,
         last_error_detail=NULL,
         updated_at=now()
     WHERE actor_id=$1
       AND status='dead_lettered'
       AND last_error_code='MSGRAPH_TOKEN_EXPIRED'
     RETURNING id`,
    [actor_id]
  );

  const drained_count = result.rowCount;

  if (drained_count > 0) {
    // Frontend-Push: Banner „N gestaute Mails werden jetzt gesendet"
    pushToUserSession(actor_id, {
      type: 'email_queue_drain',
      drained_count,
      message: `${drained_count} gestaute ${drained_count === 1 ? 'Mail wird' : 'Mails werden'} jetzt gesendet`,
    });
  }

  emit('email.queue.drained', { actor_id, drained_count });
});
```

### 2.3 Failure-Klassifizierung-Tabelle

| Error-Klasse | HTTP-Status | Retry? | Max-Retries | Backoff-Schedule (Sekunden) |
|---------------|-------------|--------|-------------|------------------------------|
| `MSGRAPH_TOKEN_EXPIRED` | 401 | ❌ Stop | 0 | — → direkt `dead_lettered` |
| `MSGRAPH_PERMISSION_DENIED` | 403 | ❌ Stop | 0 | — → direkt `dead_lettered` |
| `MSGRAPH_RECIPIENT_INVALID` | 400 | ❌ Stop | 0 | — → direkt `dead_lettered` |
| `MSGRAPH_QUOTA_EXCEEDED` | 429 | ✅ | 5 | Exponential + `Retry-After`-Header |
| `MSGRAPH_503` | 503 | ✅ | 5 | 60, 300, 900, 1800, 3600 |
| `MSGRAPH_504` | 504 | ✅ | 5 | 60, 300, 900, 1800, 3600 |
| `MSGRAPH_500` | 500 | ✅ | 3 | 300, 1800, 7200 |
| `NETWORK_TIMEOUT` | — | ✅ | 5 | 30, 120, 300, 900, 1800 |
| `UNKNOWN` | — | ✅ | 3 | 60, 300, 1800 |

Backoff-Funktion:

```typescript
function computeNextRetryAt(
  errorClass: string,
  attemptCount: number,
  retryAfterHeader?: number
): Date {
  if (errorClass === 'MSGRAPH_QUOTA_EXCEEDED' && retryAfterHeader) {
    return addSeconds(new Date(), retryAfterHeader);
  }
  const schedules: Record<string, number[]> = {
    'MSGRAPH_503':      [60, 300, 900, 1800, 3600],
    'MSGRAPH_504':      [60, 300, 900, 1800, 3600],
    'NETWORK_TIMEOUT':  [30, 120, 300, 900, 1800],
    'MSGRAPH_500':      [300, 1800, 7200],
    'UNKNOWN':          [60, 300, 1800],
    'MSGRAPH_QUOTA_EXCEEDED': [60, 300, 900, 1800, 3600], // Fallback ohne Header
  };
  const seconds = schedules[errorClass]?.[attemptCount - 1] ?? 60;
  return addSeconds(new Date(), seconds);
}
```

### 2.4 Neue Events (Email-Send-Queue)

Die folgenden Events werden via `fact_event_queue` (bestehend) emittiert:

| Event-Key | Trigger | Payload | Subscriber |
|-----------|---------|---------|------------|
| `email.send.queued` | Compose-Drawer Click „Senden" → INSERT in fact_email_send_queue | `{ job_id, actor_id, recipient_count, subject_preview }` | audit.worker · WS-Push an Actor |
| `email.send.sent` | Worker erfolgreich gesendet | `{ job_id, actor_id, recipient_count }` | audit.worker · fact_history-Worker · WS-Push |
| `email.send.failed` | Worker Fehler, wird erneut versucht | `{ job_id, actor_id, error_class, attempt_count, next_retry_at }` | audit.worker · WS-Push an Actor (Outbox-Indicator) |
| `email.send.dead_lettered` | Max-Retries erschöpft oder Stop-Error | `{ job_id, actor_id, error_class, attempt_count }` | audit.worker · notification.worker (Dead-Letter-Banner) · Admin-Reminder wenn > 5 DL in 1h |

### 2.5 Bestehender Einschub im Worker-Inventar (Backend-v2.8)

Ergänzung zu `Backend-v2.8 §Workers` Tabelle „Kommunikation" — neue Zeilen:

```
email-send.worker.ts         Cron 30s    Outlook-Failsafe Send-Queue: pending-Jobs via MS-Graph senden
email-send-drain.worker.ts   Event       Token-Reauth-Trigger: dead_lettered-Jobs (TOKEN_EXPIRED) zurück auf pending
```

---

## 3. Power-BI-Embed-Token-Endpoint (Phase-1-Greenfield)

Implementierungs-Referenz: `specs/ARK_POWER_BI_INTEGRATION_PLAN_v0_1.md` §8

### 3.1 Neuer Endpoint

```
POST   /api/v1/performance/powerbi/embed-token
       Zweck: Power-BI-Embed-Token generieren für Iframe-Embed im Performance-Modul
       Auth: JWT (alle Rollen) — Token wird für den aufrufenden User generiert
       Body: {
         report_id: string,   -- Power-BI Report-UUID (aus dim_powerbi_view.powerbi_dataset_url)
         page_name?: string   -- Optional: spezifische Report-Page
       }
       Response: {
         embed_token: string,           -- Power-BI-Embed-Token (opaker String)
         report_url: string,            -- URL zum Einbetten im Iframe
         token_expiry: ISO,             -- Ablaufzeit (ca. 60 min ab Generierung)
         refresh_after_seconds: 3000    -- Frontend: Token-Refresh nach 3000s (50 min)
       }
       Error: 503 { reason: 'powerbi_service_unavailable' }
              404 { reason: 'report_not_found' }
              403 { reason: 'powerbi_not_configured' }  (wenn Azure-AD-App fehlt)
```

<!-- NEEDS-USER-INPUT: Power-BI Token-TTL: Laut §8.1 „60 min (Power-BI-Default)" — ist das ein konfigurierbarer Wert (env-Var) oder fix 60 min? Falls Power-BI-Premium: TTL kann abweichen. Bitte bestätigen ob 60 min für alle Szenarien gilt. -->

### 3.2 Service-Principal-Auth (Backend-seitig)

```typescript
// Service-Principal-Konfiguration (aus .env / Vault)
// POWERBI_TENANT_ID    — Azure-AD-Tenant-ID
// POWERBI_CLIENT_ID    — Azure-AD-App-Client-ID (App-Registration)
// POWERBI_CLIENT_SECRET — Client-Secret (rotierbar, nie in Code)
// POWERBI_WORKSPACE_ID — Power-BI-Workspace-UUID

async function generateEmbedToken(reportId: string): Promise<EmbedTokenResponse> {
  // Schritt 1: Azure-AD-Token (Service-Principal-Auth)
  const aadToken = await acquireAadToken({
    tenantId: process.env.POWERBI_TENANT_ID,
    clientId: process.env.POWERBI_CLIENT_ID,
    clientSecret: process.env.POWERBI_CLIENT_SECRET,
    scope: 'https://analysis.windows.net/powerbi/api/.default',
  });

  // Schritt 2: Power-BI REST API — Embed-Token generieren
  // Quelle: Power-BI REST API POST /reports/{reportId}/GenerateToken
  const pbiResponse = await fetch(
    `https://api.powerbi.com/v1.0/myorg/groups/${process.env.POWERBI_WORKSPACE_ID}/reports/${reportId}/GenerateToken`,
    {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${aadToken}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ accessLevel: 'View' }),
    }
  );

  if (!pbiResponse.ok) {
    throw new PowerBiServiceError(pbiResponse.status, await pbiResponse.text());
  }

  const { token, expiration } = await pbiResponse.json();

  return {
    embed_token: token,
    report_url: `https://app.powerbi.com/reportEmbed?reportId=${reportId}&groupId=${process.env.POWERBI_WORKSPACE_ID}`,
    token_expiry: expiration,
    refresh_after_seconds: 3000,  // 50 min (10 min Puffer vor Ablauf)
  };
}
```

### 3.3 Azure-AD-App-Anforderungen (Greenfield-Gap)

<!-- NEEDS-USER-INPUT: Azure-AD-App-Registration für Power-BI-Service-Principal noch nicht erstellt (Greenfield, ARK_POWER_BI_INTEGRATION_PLAN_v0_1.md §8.2). Folgende Angaben von Nenad/Peter nötig: POWERBI_TENANT_ID, POWERBI_CLIENT_ID — erst wenn Azure-App registriert. Bis dahin: Endpoint gibt 403 zurück mit { reason: 'powerbi_not_configured' }. -->

Required Azure-AD-App-Permissions:
- `Power BI Service`: `Tenant.Read.All`, `Report.Read.All`, `Dataset.Read.All`

### 3.4 Token-Caching (Backend-seitig)

```typescript
// Embed-Token ist kurz-lived (60 min) — kein Server-seitiges Caching empfohlen.
// Frontend ist verantwortlich für Re-Fetch via Polling (nach 50 min) oder WS-Push.
// Begründung: Personalisierter Token pro User-Session — kein shared Cache sinnvoll.
// Ausnahme: wenn mehrere Tiles denselben Report einbetten → de-duplicate via
// request-deduplication im API-Layer (gleicher report_id in < 60s → gleicher Token zurück).
```

### 3.5 Audit-Event

```typescript
// Jeder Token-Generate-Request wird geloggt:
emit('powerbi.embed_token.generated', {
  actor_id: currentUser.id,
  report_id,
  expires_at: tokenExpiry,
});
// Zugehöriges fact_audit_log entry: action='powerbi.embed_token.generated'
```

---

## 4. SYNC-IMPACT

| Grundlagen-Datei | Änderung | Grund |
|------------------|----------|-------|
| `ARK_DATABASE_SCHEMA_v1_6.md` | DB-Patch v1.7 **Voraussetzung** | `fact_email_send_queue` + Enums |
| `ARK_FRONTEND_FREEZE_v1_13.md` | FE-Patch v1.14 **Folge-Patch** | Outbox-Indicator + Stammdaten-Route + Power-BI-Iframe-Tile |
| `ARK_STAMMDATEN_EXPORT_v1_6.md` | Kein Patch nötig | Keine neuen Stammdaten (dim_*-Kataloge unverändert) |
| `ARK_GESAMTSYSTEM_UEBERSICHT_v1_5.md` | Changelog-Eintrag Phase-1-A | Stammdaten-Vollansicht + Email-Failsafe + Power-BI-Embed |

**Apply-Reihenfolge:** DB-Patch v1.7 → dieser Backend-Patch v2.9 → FE-Patch v1.14.

---

## 5. Konsistenz-Verifikation Endpoints

Abgleich gegen `specs/ARK_STAMMDATEN_VOLLANSICHT_INTERACTIONS_v0_1.md` §4.1:

| Endpoint (Source-Spec) | Patch §1.1/1.2 | Status |
|------------------------|----------------|--------|
| GET `/api/v1/stammdaten/summary` | §1.1 | ✅ |
| GET `/api/v1/stammdaten/search` | §1.1 | ✅ |
| GET `/api/v1/stammdaten/categories` | §1.1 | ✅ |
| GET `/api/v1/stammdaten/categories/:slug/stats` | §1.1 | ✅ |
| GET `/api/v1/stammdaten/categories/:slug/catalogs` | §1.1 | ✅ |
| GET `/api/v1/stammdaten/dim/:catalog` | §1.1 | ✅ |
| GET `/api/v1/stammdaten/dim/:catalog/entries/:code` | §1.1 | ✅ |
| GET `/api/v1/stammdaten/dim/:catalog/entries/:code/usage` | §1.1 | ✅ |
| GET `/api/v1/stammdaten/dim/:catalog/entries/:code/audit` | §1.1 | ✅ |
| GET `/api/v1/stammdaten/dim/:catalog/entries/:code/translations` | §1.1 | ✅ |
| GET `/api/v1/stammdaten/dim/:catalog/export.csv` | §1.1 | ✅ |
| GET `/api/v1/stammdaten/categories/:slug/export.zip` | §1.1 | ✅ |
| GET `/api/v1/stammdaten/export-all.zip` | §1.1 | ✅ |
| POST `/api/v1/stammdaten/edit-mode` | §1.2 | ✅ |
| DELETE `/api/v1/stammdaten/edit-mode` | §1.2 | ✅ |
| POST `/api/v1/stammdaten/dim/:catalog/entries` | §1.2 | ✅ |
| PATCH `/api/v1/stammdaten/dim/:catalog/entries/:code` | §1.2 | ✅ |
| DELETE `/api/v1/stammdaten/dim/:catalog/entries/:code` | §1.2 | ✅ |
| PATCH `/api/v1/stammdaten/dim/:catalog/reorder` | §1.2 | ✅ |
| POST `/api/v1/stammdaten/dim/:catalog/batch-import/preview` | §1.2 | ✅ |
| POST `/api/v1/stammdaten/dim/:catalog/batch-import/apply` | §1.2 | ✅ |
| PUT `/api/v1/stammdaten/dim/:catalog/entries/:code/translations` | §1.2 | ✅ |

**Ergebnis:** Alle 22 Endpoints aus Source-Spec §4.1 übernommen. ✅

---

**Ende v2.9.** Apply-Reihenfolge: DB-Patch v1.7 → Backend-Patch v2.9 → FE-Patch v1.14.
