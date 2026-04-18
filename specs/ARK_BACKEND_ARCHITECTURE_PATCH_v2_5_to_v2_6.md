# ARK CRM — Backend-Architektur-Patch v2.5 → v2.6

**Scope:** Event-Processor-Erweiterung für automatisches `fact_history`-Schreiben bei System-Events
**Zielversion:** `ARK_BACKEND_ARCHITECTURE_v2_6.md`
**Basis-Spec:** `specs/ARK_SYSTEM_ACTIVITY_TYPES_SCHEMA_v1.md`
**Vorheriger Patch:** `specs/ARK_DATABASE_SCHEMA_PATCH_v1_3_to_v1_4.md`
**Stand:** 17.04.2026
**Status:** Review ausstehend

---

## KORREKTUREN zur Spec v1.0 (Fortsetzung)

Die ursprüngliche Spec v1.0 beschreibt einen neuen Worker `system-activity-writer`. Nach Review der v2.5-Architektur stellt sich heraus: **auch dieser Worker ist redundant**.

| Spec v1.0 Annahme | Realität v2.5 | Konsequenz |
|-------------------|---------------|-------------|
| Neuer Worker `system-activity-writer` | `event-processor.worker.ts` existiert bereits als **zentraler Event-Consumer** | Kein neuer Worker — nur Erweiterung des bestehenden Processors |
| Writer liest `dim_event_types.target_table` | `dim_automation_rules.action_type` hat bereits Wert `'create_history'` — vorhandenes Rule-System deckt Use-Case | Auto-History via Event-Type-Mapping ODER via Rule (Wahl des einfacheren Pfads) |
| Writer → `fact_system_log` | `fact_system_log` existiert nicht — existing `fact_event_queue` + `fact_event_log` reichen (siehe DB-Patch) | Ops-Log läuft unverändert über Event-Queue |

**Konsequenz für Spec v1.0:** Version **v1.2** wird nötig (korrigiert §2.3, §5 — entfernt `fact_system_log` UND `system-activity-writer`).

---

## Korrigierte Architektur

```
Trigger (Worker / API / Integration / Scheduled)
        │
        ▼
fact_event_queue.insert {event_type_id, entity, payload, correlation_id}
        │
        ▼
event-processor.worker.ts  (BESTEHEND, erweitert in v2.6)
        │
   ┌────┴─────────────────────────────────────┐
   ▼                                          ▼
[NEU v2.6: Pre-Rule Hook]              [BESTEHEND: Rule-Execution]
"Falls dim_event_types.create_history  Für jede Rule aus dim_automation_rules
 = true → INSERT fact_history mit       execute action (create_reminder,
 default_activity_type_id, is_auto=     send_notification, trigger_ai,
 true, actor_type, source_system"       trigger_webhook, create_history, ...)
   │                                          │
   └────────────────┬─────────────────────────┘
                    ▼
         writeEventLog(event_id) → fact_event_log
         markEventProcessed(event_id) → fact_event_queue.status='done'
```

**Wichtig:** Der neue Pre-Rule-Hook in §B1 ist **deklarativ** — steuert sich ausschliesslich über `dim_event_types.create_history` + `default_activity_type_id`. Kein neuer Code pro Event nötig, nur Katalog-Pflege.

---

## Changelog v2.5 → v2.6

| # | Bereich | Änderung |
|---|---------|----------|
| 1 | Sektion B (Worker-Liste) | KEIN neuer Worker — nur Erweiterung `event-processor.worker.ts` |
| 2 | Sektion B1 (NEU) | Pre-Rule-Hook für Auto-History-Creation dokumentiert |
| 3 | Sektion D (Sagas) | TX1 Placement: alle 7 Sub-Steps emittieren Events mit `correlation_id` (war teilweise, jetzt Pflicht) |
| 4 | Sektion G (Event-Scope) | +~35 neue Event-Namen in Registry (aus Spec-Katalog) |
| 5 | Sektion H (dim_automation_settings) | +1 Key `system_event_writer_enabled` (Feature-Flag) |

**Nicht geändert in v2.6:**
- Event-Processor-Grundstruktur (Loop, Circuit-Breaker, Rate-Limit) — bleibt
- `fact_event_log` Struktur — bleibt
- Saga-Engine — bleibt (nur Pflicht-Emission erhöht)

---

## A. Event-Processor — Erweiterung (Pre-Rule Auto-History)

### A.1 Bestehender Flow (v2.5)

```typescript
// /src/workers/event-processor.worker.ts
boss.work('process-event', async (job) => {
  const { eventId, tenantId } = job.data
  const event = await loadEvent(eventId, tenantId)
  const rules = await loadMatchingRules(event.event_type_id, tenantId)

  for (const rule of rules) {
    if (rule.circuit_breaker_tripped) continue
    if (/* rate-limit gate */) continue
    await executeAction(rule, event, tenantId)
    await incrementTriggerCount(rule.id)
  }
  await markEventProcessed(eventId)
  await writeEventLog(eventId)
})
```

### A.2 Erweiterter Flow (v2.6)

```typescript
// /src/workers/event-processor.worker.ts  (ERWEITERT v2.6)
boss.work('process-event', async (job) => {
  const { eventId, tenantId } = job.data
  const event = await loadEvent(eventId, tenantId)
  const eventType = await loadEventType(event.event_type_id) // NEU: Type mitladen

  // NEU v2.6: Pre-Rule-Hook — automatisches fact_history-Insert
  if (eventType.create_history === true && eventType.default_activity_type_id) {
    await writeAutoHistory({
      event_id: event.id,
      activity_type_id: eventType.default_activity_type_id,
      actor_type: eventType.default_actor_type,
      source_system: eventType.default_source_system,
      entity_type: event.entity_type,
      entity_id: event.entity_id,
      occurred_at: event.triggered_at,
      payload: event.payload_json,
      correlation_id: event.correlation_id,
      tenant_id: tenantId,
    })
  }

  // BESTEHEND: Rule-Execution (unverändert)
  const rules = await loadMatchingRules(event.event_type_id, tenantId)
  for (const rule of rules) {
    if (rule.circuit_breaker_tripped) continue
    if (rule.max_triggers_per_hour) {
      const count = await getTriggerCount(rule.id, 'hour')
      if (count >= rule.max_triggers_per_hour) {
        await tripCircuitBreaker(rule.id); continue
      }
    }
    await executeAction(rule, event, tenantId)
    await incrementTriggerCount(rule.id)
  }

  await markEventProcessed(eventId)
  await writeEventLog(eventId)
})
```

### A.3 `writeAutoHistory` Implementation

```typescript
// /src/services/history/auto-history-writer.ts (NEU v2.6)
export async function writeAutoHistory(params: AutoHistoryParams): Promise<void> {
  const { event_id, activity_type_id, actor_type, source_system,
          entity_type, entity_id, occurred_at, payload,
          correlation_id, tenant_id } = params

  // Idempotenz: event_id ist FK, UNIQUE per Event
  const existing = await db
    .selectFrom('fact_history')
    .where('event_id', '=', event_id)
    .select('id')
    .executeTakeFirst()
  if (existing) {
    logger.debug({ event_id }, 'auto-history already exists, skipping')
    return
  }

  // Entity-Mapping: entity_type → FK-Spalte in fact_history
  const fkField = resolveHistoryFK(entity_type) // 'candidate_id' | 'account_id' | ...

  await db.insertInto('fact_history').values({
    tenant_id,
    activity_type_id,
    activity_date: occurred_at.toISOString().slice(0, 10),
    activity_timestamp: occurred_at,
    is_auto_logged: true,
    event_id,
    [fkField]: entity_id,
    comment: extractComment(payload),
    // actor_type / source_system sind neu auf dim_activity_types, nicht fact_history —
    // sie werden via JOIN gelesen, nicht redundant gespeichert
  }).execute()

  // Falls is_notifiable → Notification-Enqueue (delegated an notification-worker)
  const activityType = await loadActivityType(activity_type_id)
  if (activityType.is_notifiable) {
    await boss.send('notification-fanout', {
      event_id, activity_type_id, entity_type, entity_id, tenant_id,
    })
  }
}

type AutoHistoryParams = {
  event_id: string
  activity_type_id: string
  actor_type: 'system' | 'automation' | 'integration'
  source_system: string | null
  entity_type: string
  entity_id: string
  occurred_at: Date
  payload: Record<string, unknown>
  correlation_id: string
  tenant_id: string
}
```

### A.4 Feature-Flag

Key `system_event_writer_enabled` in `dim_automation_settings`:
- `true` (Default in Staging/Prod nach Rollout) → Pre-Rule-Hook aktiv
- `false` → Hook übersprungen, nur Rules werden ausgeführt (für Emergency-Disable)

```typescript
const writerEnabled = await getSetting('system_event_writer_enabled', tenantId)
if (writerEnabled && eventType.create_history) {
  await writeAutoHistory(...)
}
```

---

## B. Keine neuen Worker — Sektion B bleibt bei 18

Explizit: v2.6 führt **keinen neuen Worker** ein. Tabelle Sektion B (7 Nightly + 6 Event-getrieben + 3 Scraper + 2 Daten/System + 4 Workflow) bleibt identisch.

Die Pre-Rule-Logik lebt als **Service-Modul** (`/src/services/history/auto-history-writer.ts`), nicht als eigener Worker. Das ist bewusst:
- Kein zusätzlicher Queue-Overhead
- Gleiche Transaktion wie Event-Processing
- Einfacheres Debugging (alle Side-Effects eines Events in einem Log-Eintrag)

---

## C. Saga-Correlation (Sektion D Erweiterung)

### C.1 Pflicht-Emission für TX1 Placement (bisher teilweise)

Alle 7 Sub-Steps der Placement-Saga emittieren jetzt **Pflicht** einen Event in `fact_event_queue`:

| Sub-Step | Event-Name | create_history | Activity-Type (wenn history) |
|----------|-----------|----------------|------------------------------|
| V1: Stage=placement, Status=Placed | `saga.v1_stage_placement` | false | — (nur Log) |
| V2: Finance berechnet | `saga.v2_finance_calculated` | false | — |
| V3: Job.status=filled | `saga.v3_job_filled` | false | — |
| V4: Garantiefrist eröffnet | `saga.v4_guarantee_opened` + parallel `guarantee.started` | true (nur `guarantee.started`) | #78 Garantiefrist - Gestartet |
| V5: Referral-Auslösung | `saga.v5_referral_triggered` + parallel `referral.triggered` | true (nur `referral.triggered`) | #105 Referral ausgelöst |
| V6: Stellenplan-Update | `saga.v6_staffing_plan_updated` | false | — |
| V7: Post-Placement-Reminders + Saga-Complete | `process.placement_completed` | true | #99 Placement - Vollständig abgeschlossen |

**Alle 7+2=9 Events** teilen sich dieselbe `correlation_id` (= `saga_run.id`). Admin-Debug-Query:

```sql
SELECT eq.triggered_at, eq.event_name, eq.status,
       el.action_taken, el.duration_ms
FROM ark.fact_event_queue eq
LEFT JOIN ark.fact_event_log el ON el.event_id = eq.id
WHERE eq.correlation_id = $1  -- saga_run.id
ORDER BY eq.triggered_at;
```

Liefert komplette Saga-Timeline für einen Placement-Vorgang, inkl. Rule-Executions (z.B. welche Notifications versendet wurden).

### C.2 Saga-Failure-Handling

Bei Fehler in Sub-Step V_X:
1. Alle bisherigen Steps werden rolled back (Transaction-Savepoints oder Compensating Actions je nach Step)
2. Event `saga.failure` mit `severity='error'`, `correlation_id` der fehlgeschlagenen Saga, `payload = { failed_step, error_code, rollback_actions }`
3. Falls V7 nicht erreicht → **keine** `process.placement_completed`-Row in `fact_history` (User-Timeline zeigt Placement nicht als erfolgt)
4. Notification an Process-Owner (AM/CM) mit `is_notifiable=true` für `saga.failure`

### C.3 Andere Sagas (TX2–TX8)

Analog für:
- TX2 Assessment-Report-Upload: emittiert `assessment.v1_version_insert`, `assessment.v2_run_completed`, `assessment.v3_credits_incremented`, `assessment.v4_order_status_updated` (alle Log, keine history)
- TX3 Mandat-Kündigung: `mandate.v1_status_cancelled`, ..., `mandate.v6_events_fanout` — und parallel user-sichtbares `mandate.cancelled` → fact_history
- TX4 Scraper-Finding-Accept: `scrape.item_imported` (history) + 3 Log-Events
- TX5/TX6/TX7/TX8: analog — Sub-Step-Events mit `correlation_id`, ein user-sichtbarer Aggregat-Event

**Migration-Aufwand:** 7 Saga-Implementierungen müssen Pflicht-Event-Emission auditiert werden. Checklist-Item für Backend-Team Sprint 2.

---

## D. Event-Scope-Registry Erweiterung (Sektion G)

Registry `EVENT_SCOPE_RULES` in `/src/events/scope-registry.ts` erhält Einträge für alle ~35 neuen Event-Namen aus `dim_event_types`-Seed. Beispiele:

```typescript
export const EVENT_SCOPE_RULES: Record<EventType, ScopeResolver> = {
  // ... bestehende 30+ Events

  // NEU v2.6:
  'interview.scheduled': async (event) => {
    const p = await loadProcess(event.entity_id)
    return {
      candidates: [p.candidate_id],
      accounts: [p.account_id],
      jobs: [p.job_id],
      processes: [p.id],
    }
  },
  'guarantee.started': async (event) => {
    const g = await loadGuarantee(event.entity_id)
    return {
      candidates: [g.candidate_id],
      accounts: [g.account_id],
      processes: [g.process_id],
    }
  },
  'direct_hire_claim.opened': async (event) => {
    const c = await loadClaim(event.entity_id)
    return {
      candidates: [c.candidate_id],
      accounts: [c.account_id],
      protection_windows: [c.protection_window_id],
    }
  },
  'scrape.new_person': async (event) => ({ accounts: [event.entity_id] }),
  'scrape.role_changed': async (event) => {
    const r = await loadScrapeFinding(event.entity_id)
    return {
      candidates: r.matched_candidate_id ? [r.matched_candidate_id] : [],
      accounts: [r.account_id],
    }
  },
  'briefing.auto_filled': async (event) => ({ candidates: [event.entity_id] }),
  'process.placement_completed': async (event) => {
    // Sammel-Scope: öffnet alle Substeps via correlation_id
    const p = await loadProcess(event.entity_id)
    const substeps = await loadSagaSubsteps(event.correlation_id)
    return {
      candidates: [p.candidate_id],
      accounts: [p.account_id],
      jobs: [p.job_id],
      processes: [p.id],
      mandates: p.mandate_id ? [p.mandate_id] : [],
      saga_substeps: substeps.map(s => s.id), // für Admin-Debug-View
    }
  },
  // ... weitere 28 Events analog
}
```

**Registry-Pflege:** Jeder neue Event-Name aus Spec-Katalog §4 muss hier einen Resolver bekommen. Fehlt Resolver → Processor fällt auf `entity_type/entity_id`-only Scope zurück (Fallback).

---

## E. `dim_automation_settings` Erweiterung (Sektion H)

Neuer Key:

| Key | Default | Typ | Beschreibung |
|-----|---------|-----|--------------|
| `system_event_writer_enabled` | `true` | bool | Master-Feature-Flag Pre-Rule Auto-History. `false` = nur Rules ausführen. |
| `system_event_writer_log_level` | `'info'` | enum | `debug`/`info`/`warn` für Writer-Logging |
| `saga_correlation_retention_days` | `90` | int | Wie lange Correlation-IDs in Event-Queue vor Purge bleiben |
| `auto_history_idempotency_window_hours` | `24` | int | Zeitraum nach Event-Insert, innerhalb dessen Retry keinen doppelten fact_history erzeugen darf (via event_id UNIQUE) |

---

## F. Logging & Observability

### F.1 Strukturierte Logs

Pre-Rule-Hook loggt pro Event:

```json
{
  "level": "info",
  "msg": "auto_history_written",
  "event_id": "uuid",
  "event_name": "guarantee.started",
  "activity_type_id": "uuid",
  "entity_type": "candidate",
  "entity_id": "uuid",
  "correlation_id": "uuid",
  "tenant_id": "uuid",
  "duration_ms": 12
}
```

### F.2 Metriken

Neue Prometheus-Metriken:

| Metrik | Typ | Labels |
|--------|-----|--------|
| `ark_auto_history_writes_total` | Counter | `event_name`, `tenant_id`, `status` (success/skipped/error) |
| `ark_auto_history_write_duration_ms` | Histogram | `event_name` |
| `ark_saga_duration_ms` | Histogram | `saga_type` (TX1–TX8), `outcome` (success/failure) |
| `ark_event_queue_lag_seconds` | Gauge | `event_category` |

### F.3 Dashboards

- **Grafana: „System-Events Health"** — Auto-History-Write-Rate, Dead-Letter-Rate, Saga-Success-Rate
- **Grafana: „Saga-Timings"** — TX1–TX8 Dauer-Verteilung, Rollback-Rate

---

## G. Migration & Rollout

### G.1 Schritt-Reihenfolge

```
1. DB-Migration 001_system_activity_types.sql ausführen (bereits in Phase A Schritt 3)
2. Deploy event-processor.worker.ts v2.6 (Feature-Flag OFF)
3. Smoke-Test in Staging:
   a. Manuelles Einfügen 1 Test-Event pro create_history=true Event-Type
   b. Prüfen: fact_history-Row wird erstellt
   c. Prüfen: correlation_id korrekt gepflegt
4. Feature-Flag ON in Staging (24h Beobachtung)
5. Feature-Flag ON in Prod, 50% Traffic (48h Beobachtung dead-letter + idempotency)
6. Feature-Flag ON für 100% (nach Grünphase)
7. Bestehende ad-hoc fact_history.insert() Aufrufe im Backend migrieren (Sprint 2-4):
   a. Alle Stellen mit direktem INSERT finden → Event-Emission stattdessen
   b. Event-Type in dim_event_types + create_history=true konfigurieren
   c. Tests anpassen
8. Alte direkte Inserts deprecaten, entfernen
```

### G.2 Rollback

Emergency-Rollback:
```sql
UPDATE ark.dim_automation_settings
  SET value_bool = false
  WHERE key = 'system_event_writer_enabled';
```
Sofort deaktiviert Pre-Rule-Hook ohne Code-Rollback.

Vollständiger Code-Rollback: deploy v2.5 `event-processor.worker.ts` zurück — DB-Änderungen (v1.4-Schema) bleiben, sind additiv und stören v2.5-Code nicht.

---

## H. SYNC-CHECK zu Grundlagen

Nach Einarbeitung in `ARK_BACKEND_ARCHITECTURE_v2_6.md`:

| Grundlagen-Datei | Änderung nötig |
|------------------|----------------|
| `ARK_DATABASE_SCHEMA_v1_3.md` → v1_4 | Bereits abgedeckt durch DB-Schema-Patch (Phase A Schritt 3) |
| `ARK_STAMMDATEN_EXPORT_v1_3.md` → v1_4 | Bereits abgedeckt durch Stammdaten-Patch (Phase A Schritt 2) |
| `ARK_FRONTEND_FREEZE_v1_*.md` | Timeline-Badge 🤖, Filter-Chips (Phase B) |
| `ARK_GESAMTSYSTEM_UEBERSICHT_v1_*.md` | Changelog-Eintrag v2.6 |

**Spec v1.0 → v1.2 nötig (Phase A Schritt 5):**
- §2.3 streichen (`fact_system_log` CREATE)
- §5 umschreiben (kein neuer Worker — Pre-Rule-Hook im bestehenden Processor)
- §4.2 umbenennen („System-Log-Events" → „Queue-only-Events" mit `create_history=false`)
- §8 Migration vereinfachen (weniger Infra-Änderungen)

---

## I. OFFENE PUNKTE — resolved v1.3 (17.04.2026)

| # | Frage | Entscheidung | Doc-Ref |
|---|-------|--------------|---------|
| B1 | Pre-Rule-Hook-Placement | **Direkt in `event-processor.worker.ts`** (keine Queue-Reihenfolge-Probleme, atomarer Flow) | Decisions §B1 |
| B2 | Saga-Emission-Audit | **Team-Task** — Backend-Team auditiert 8 Sagas in Sprint 1 vor v2.6-Deploy | Decisions §Team-Tasks |
| B3 | Event-Scope-Registry Ownership | **Backend-Lead** zentral pflegt, Feature-Teams ergänzen neue Resolver per PR | Decisions §B3 |
| B4 | Notification-Fanout-Duplikate | **Redis-Lock 60s TTL** pro `(event_id, recipient, template)` — Fallback `pg_advisory_lock` | Decisions §Q8 + §J.1 unten |
| B5 | Idempotency-Strategie | **UNIQUE-Constraint** auf `fact_history.event_id` (DB-Garantie) statt Zeitfenster | Decisions §B5 |

### Amendment v1.3 — Zusätzliche Sektionen

### J.1 Notification-Dedup via Redis-Lock (v1.3)

Lösung für B4 — Hook + Rule fanouten doppelt:

```typescript
// /src/services/notifications/dedup.ts (NEU v2.6)
export async function sendNotificationDeduped(params: NotificationParams): Promise<void> {
  const { event_id, recipient_user_id, template_key, tenant_id } = params

  const lockKey = `notif-dedup:${tenant_id}:${event_id}:${recipient_user_id}:${template_key}`
  const ttl = await getSetting('notification_dedup_ttl_seconds', tenant_id) ?? 60

  const acquired = await redis.set(lockKey, '1', { NX: true, EX: ttl })
  if (!acquired) {
    logger.debug({ lockKey }, 'notification deduplicated, skipping')
    return
  }

  try {
    await sendNotification(params)
  } catch (err) {
    // Bei Fehler Lock NICHT freigeben — Retry via andere Route würde sonst zu Doppel-Send führen
    logger.error({ err, lockKey }, 'notification send failed')
    throw err
  }
}
```

**Alternative ohne Redis:**

```sql
SELECT pg_try_advisory_lock(hashtext('notif-dedup:' || :event_id || ':' || :recipient || ':' || :template));
-- true = Lock erworben, send Notification
-- false = schon vergeben, skip
-- Auto-release am Transaktionsende
```

### J.2 Idempotency via UNIQUE-Constraint (v1.3)

Lösung für B5:

```sql
ALTER TABLE ark.fact_history ADD CONSTRAINT uniq_fact_history_event_id
  UNIQUE (event_id) WHERE event_id IS NOT NULL;
```

Writer-Code vereinfacht (ersetzt früheren SELECT-before-INSERT + 24h-Window):

```typescript
try {
  await db.insertInto('fact_history').values({ event_id, ... }).execute()
} catch (e) {
  if (isUniqueViolation(e, 'uniq_fact_history_event_id')) {
    logger.debug({ event_id }, 'duplicate event, skipping')
    return
  }
  throw e
}
```

**Folge:** Writer ist idempotent-by-construction, Retry-Flow (PgBoss) kann beliebig oft laufen ohne Doppel-Rows.

### J.3 Registry-Ownership (v1.3)

Für B3: `EVENT_SCOPE_RULES` in `/src/events/scope-registry.ts` wird zentral vom Backend-Lead gepflegt. Feature-Teams:

- **Dürfen** neue Resolver per PR ergänzen wenn sie neues Event-Type einführen
- **Müssen** Event-Name + Resolver-Spec vor PR im Decisions-Doc oder RFC dokumentieren
- **Dürfen nicht** bestehende Resolver ändern ohne Code-Review durch Backend-Lead (breaking-change-Risiko)

Linter-Regel (CI-Hook): neue `dim_event_types`-Rows ohne korrespondierenden Resolver → Warning, nicht fail (Registry kann einen Fallback-Scope haben).

---

## ADMIN-VOLLANSICHT-ADDENDUM (17.04.2026)

**Scope:** Neue Events, Worker, Sagas, Endpunkte, WebSocket-Channels und RBAC-Gates für Admin-Vollansicht (`specs/ARK_ADMIN_VOLLANSICHT_SCHEMA_v0_1.md` + `_INTERACTIONS_v0_1.md`).

**Zielversion:** `ARK_BACKEND_ARCHITECTURE_v2_6.md`

### K.1 Neue Events (Event-Katalog-Ergänzung)

Alle in `dim_event_types` seeden mit Category `system`/`admin` und emitter_component gemäß Tabelle:

| # | event_name | category | entity_type | emitter | create_history |
|---|-----------|----------|-------------|---------|----------------|
| 1 | `setting.changed` | admin | system | admin-api | false |
| 2 | `automation.rule.created` | admin | automation_rule | admin-api | false |
| 3 | `automation.rule.updated` | admin | automation_rule | admin-api | false |
| 4 | `automation.rule.paused` | admin | automation_rule | admin-api | false |
| 5 | `automation.rule.activated` | admin | automation_rule | admin-api | false |
| 6 | `automation.rule.deleted` | admin | automation_rule | admin-api | false |
| 7 | `circuit_breaker.tripped` | system | circuit_breaker | circuit-breaker-worker | false |
| 8 | `circuit_breaker.reset` | admin | circuit_breaker | admin-api | false |
| 9 | `circuit_breaker.half_open` | system | circuit_breaker | circuit-breaker-worker | false |
| 10 | `reminder_template.updated` | admin | template | admin-api | false |
| 11 | `email_template.updated` | admin | template | admin-api | false |
| 12 | `notification_template.updated` | admin | template | admin-api | false |
| 13 | `oauth.token.refreshed` | system | oauth_token | outlook-sync-worker | false |
| 14 | `oauth.token.expiring` | system | oauth_token | oauth-expiry-worker | false |
| 15 | `oauth.token.expired` | system | oauth_token | oauth-expiry-worker | false |
| 16 | `codetwo.sync.started` | system | integration | codetwo-sync-worker | false |
| 17 | `codetwo.sync.completed` | system | integration | codetwo-sync-worker | false |
| 18 | `codetwo.sync.failed` | system | integration | codetwo-sync-worker | false |
| 19 | `dashboard_template.widget.added` | admin | dashboard_template | admin-api | false |
| 20 | `dashboard_template.widget.removed` | admin | dashboard_template | admin-api | false |
| 21 | `dashboard.reset.bulk` | admin | dashboard | admin-api | false |
| 22 | `legal_hold.set` | audit | legal_hold | admin-api | true |
| 23 | `legal_hold.released` | audit | legal_hold | admin-api | true |
| 24 | `retention_policy.proposed` | audit | retention_policy | admin-api | false |
| 25 | `retention_policy.approved` | audit | retention_policy | admin-api | true |
| 26 | `retention_policy.rejected` | audit | retention_policy | admin-api | false |
| 27 | `retention_policy.changed` | audit | retention_policy | admin-api | true |
| 28 | `dsg_request.created` | audit | dsg_request | admin-api | true |
| 29 | `dsg_request.completed` | audit | dsg_request | admin-api | true |
| 30 | `dsg_request.rejected` | audit | dsg_request | admin-api | true |
| 31 | `ignore_rule.hit` | system | email_ignore_rule | email-ingest-worker | false |

**Payload-Schema-Referenz:** Siehe `ARK_EVENT_TYPES_MAPPING_v1_4.md` zur Erweiterung.

**event_category CHECK erweitern:** `audit` + `admin` zu bestehenden Werten hinzufügen:

```sql
ALTER TABLE ark.dim_event_types
  DROP CONSTRAINT IF EXISTS dim_event_types_event_category_check;
ALTER TABLE ark.dim_event_types
  ADD CONSTRAINT dim_event_types_event_category_check CHECK (event_category IN (
    'lifecycle','interaction','match','status','workflow','guarantee',
    'protection_window','saga','ai','finance','referral','assessment',
    'system','admin','audit'
  ));
```

### K.2 Neue Worker

| # | Worker | Trigger | Quelle | Frequenz | Zweck |
|---|--------|---------|--------|----------|-------|
| W1 | `circuit-breaker.worker.ts` | event-driven | `fact_rule_executions` INSERT | on-event | Trip-Check · State-Transition CLOSED↔OPEN↔HALF-OPEN |
| W2 | `oauth-expiry.worker.ts` | cron | daily 07:00 | 1/Tag | Token-Ablauf-Warnung < 7 d · auto re-auth request |
| W3 | `codetwo-sync.worker.ts` | cron + manual | every 6 h / admin-triggered | 4/Tag + manuell | Signatur-Templates aus CodeTwo syncen |
| W4 | `retention.worker.ts` | cron | nightly 02:00 | 1/Tag | Retention-Policy enforcen · Hash/Delete gem. Policy · Legal-Hold respektieren |
| W5 | `dsg-sla-monitor.worker.ts` | cron | hourly | 24/Tag | DSG-Request-SLA prüfen · Eskalation an Admin bei < 7 d Rest |
| W6 | `legal-hold-trigger.worker.ts` | event-driven | entity UPDATE/DELETE | on-event | DB-Trigger-Backup: blockiert Mutation bei aktivem Legal-Hold |
| W7 | `rule-execution.worker.ts` | event-driven | Rule-Trigger-Events | on-event | Rule-Executor · Condition-Eval · Action-Chain · Circuit-Breaker-Check |
| W8 | `template-version.worker.ts` | event-driven | Template-UPDATE | on-event | Snapshot alter Version in `fact_template_versions` schreiben |

**Abhängigkeiten:**
- W1 liest `dim_circuit_breakers`, schreibt State-Changes
- W4 respektiert `dim_legal_holds.active=true` — blockiert Hash/Delete
- W7 schreibt `fact_rule_executions` pro Run (success + failure)

### K.3 Neue Sagas

#### K.3.1 Saga `candidate_data_erasure` (DSG Art. 25)

**Trigger:** Admin-initiated via DSG-Request-Drawer (Tab 10.4)

**Steps (8):**

| # | Step | Kompensation |
|---|------|--------------|
| 1 | Validate Admin-Permission + DSG-Request-Status | — |
| 2 | Prüfe aktive Legal-Holds auf Kandidat | — |
| 3 | Prüfe Referenzen (aktive Prozesse/Mandate) | — |
| 4 | Generate Deletion-Certificate PDF (via Dok-Generator) | delete_certificate |
| 5 | Anonymize PII-Felder (`dim_candidates` Hash) | restore_from_snapshot |
| 6 | Invalidate Active-Sessions (optional) | — (nicht kompensierbar) |
| 7 | `emit: dsg_request.completed` | — |
| 8 | `audit: action=DELETE, sub_action=dsg_erasure` | — |

**Fehler-Modi:**
- Step 2 findet Legal-Hold → Abbruch, Response an Antragsteller mit Grund
- Step 3 findet aktive Prozesse → Warn an Admin, kein Block (manuelle Entscheidung)
- Step 5 Fehler → Restore aus Pre-Hash-Snapshot (temp-gespeichert) + Request zurück auf `in_progress`

#### K.3.2 Saga `retention_enforce`

**Trigger:** Cron (nightly 02:00 via `retention.worker.ts`)

**Steps (5):**

| # | Step | Kompensation |
|---|------|--------------|
| 1 | Scan `fact_*`-Tables nach Retention-Policy | — |
| 2 | Filter: `legal_hold.active=false` | — |
| 3 | Personal-Data-Hashing (wenn Hash-Policy) ODER Delete | restore_from_snapshot (nur Hash) |
| 4 | Audit-Row pro Kandidat: `action=RETENTION_CHANGE` | — |
| 5 | Weekly-Report an Admin-Notification | — |

**Fehler-Modi:**
- Step 3 Fehler → Rollback Hash + Retry in nächster Nacht
- Bei > 5 % Failure-Rate → Abbruch + Admin-Alert, Circuit-Breaker auf Retention-Worker

#### K.3.3 Saga `codetwo_sync`

**Trigger:** Cron (every 6h) + Manual

**Steps (6):**

| # | Step | Kompensation |
|---|------|--------------|
| 1 | Fetch/Refresh CodeTwo-API-Token | — |
| 2 | Get all Signature-Templates from CodeTwo | — |
| 3 | Diff gegen `dim_codetwo_signatures` | — |
| 4 | Match auf `dim_mitarbeiter.codetwo_template_id` | — |
| 5 | Update Rows + merke Diff | revert_update (temp-snapshot) |
| 6 | Bei Gesamt-Fehler: `emit: codetwo.sync.failed` + Admin-Notification | — |

**Fehler-Modi:**
- Step 1-2 Fail → 3× Retry (exp-backoff) → Abbruch + Notification
- Step 5 Fail → Revert nur dieser Row, andere bleiben gesynct

### K.4 Neue API-Endpunkte

**Routing-Prefix:** `/api/admin` · Gate: `role === 'admin'` (HTTP 403 sonst)

#### K.4.1 Feature-Flags & Settings (Tab 1)

| Method | Path | Zweck |
|--------|------|-------|
| GET | `/api/admin/flags/bootstrap` | Tab 1 Initial-Load (alle 4 Sec-Groups) |
| PUT | `/api/admin/settings/:key` | Wert ändern (Request: `{value, reason?}`) |
| POST | `/api/admin/settings/reset-all` | Alle non-locked Keys auf Default |
| GET | `/api/admin/settings/:key/history` | Change-Historie (Audit-Log-Filter) |

#### K.4.2 Automation-Rules (Tab 2)

| Method | Path | Zweck |
|--------|------|-------|
| GET | `/api/admin/automation/bootstrap` | Tab 2 (Rules-List + CB-State) |
| POST | `/api/admin/automation-rules` | Neue Regel |
| PUT | `/api/admin/automation-rules/:id` | Update Regel (Version-Bump) |
| PUT | `/api/admin/automation-rules/:id/status` | Pause/Activate (`{status}`) |
| DELETE | `/api/admin/automation-rules/:id` | Soft-Delete |
| POST | `/api/admin/automation-rules/:id/test-run` | Dry-Run (`{mode: 'last_event'|'custom', payload?}`) |
| POST | `/api/admin/automation-rules/:id/duplicate` | Kopie |
| POST | `/api/admin/circuit-breakers/:id/reset` | Manual-Reset (admin) |

#### K.4.3 Templates (Tab 3/4/7)

| Method | Path | Zweck |
|--------|------|-------|
| GET | `/api/admin/reminder-templates` | Liste + Counts |
| POST | `/api/admin/reminder-templates` | Neu |
| PUT | `/api/admin/reminder-templates/:id` | Update (Version-Bump) |
| DELETE | `/api/admin/reminder-templates/:id` | Soft-Delete (FK-Check) |
| POST | `/api/admin/reminder-templates/:id/duplicate` | Kopie |
| (analog) | `/api/admin/email-templates/…` | Email-Templates |
| POST | `/api/admin/email-templates/:id/test-send` | Test-Mail an Caller |
| (analog) | `/api/admin/notification-templates/…` | Notification-Templates |
| POST | `/api/admin/notification-templates/:id/test-send` | Test-Notif an Caller |

#### K.4.4 Email-Integrationen (Tab 4)

| Method | Path | Zweck |
|--------|------|-------|
| GET | `/api/admin/oauth-tokens` | Liste pro User |
| POST | `/api/admin/oauth-tokens/:user_id/reauth` | Redirect zu MS-Login-Flow |
| POST | `/api/admin/codetwo/sync` | Manual-Sync |
| GET | `/api/admin/codetwo/sync-log` | Letzte 20 Sync-Runs |
| GET | `/api/admin/email-ignore-rules` | Liste |
| POST | `/api/admin/email-ignore-rules` | Neu |
| DELETE | `/api/admin/email-ignore-rules/:id` | Delete |
| POST | `/api/admin/email-ignore-rules/:id/simulate` | Regel auf letzten 100 Mails testen |

#### K.4.5 Telefonie (Tab 5)

| Method | Path | Zweck |
|--------|------|-------|
| GET | `/api/admin/3cx/bootstrap` | Tab 5 (KPIs + Webhook-Log) |
| POST | `/api/admin/3cx/rotate-api-key` | Key-Rotation (Response einmalig) |
| POST | `/api/admin/3cx/webhook-test` | Dummy-Event senden, Latenz messen |

#### K.4.6 Scraper (Tab 6)

Verweist auf `specs/ARK_SCRAPER_MODUL_INTERACTIONS_v0_1.md` — Endpunkte `/api/admin/scraper-*` dort definiert.

#### K.4.7 Dashboard-Templates (Tab 8)

| Method | Path | Zweck |
|--------|------|-------|
| GET | `/api/admin/dashboard-templates/:role` | Default-Widgets für Rolle |
| POST | `/api/admin/dashboard-templates/:role/widgets` | Widget hinzufügen |
| PUT | `/api/admin/dashboard-templates/:role/widgets/:id` | Widget-Config ändern |
| DELETE | `/api/admin/dashboard-templates/:role/widgets/:id` | Widget entfernen |
| POST | `/api/admin/dashboard-templates/:role/reset-user-overrides` | Bulk-Reset User |

#### K.4.8 Debug (Tab 9)

| Method | Path | Zweck |
|--------|------|-------|
| GET | `/api/admin/events` | Event-Log-Query (filter, from/to) |
| GET | `/api/admin/events/:id` | Event-Detail + Downstream-Chain |
| GET | `/api/admin/sagas/:id` | Saga-Trace |
| POST | `/api/admin/sagas/:id/retry` | Retry ab letztem Fail-Step |
| POST | `/api/admin/sagas/:id/skip-step` | Force-Skip (with reason) |
| GET | `/api/admin/dlq` | Dead-Letter-Queue-Liste |
| POST | `/api/admin/dlq/:id/retry` | Retry einzelnen DLQ-Item |
| DELETE | `/api/admin/dlq/:id` | Force-Delete (discard) |
| GET | `/api/admin/rule-executions` | Rule-Exec-Log |

#### K.4.9 Audit & Retention (Tab 10)

| Method | Path | Zweck |
|--------|------|-------|
| GET | `/api/admin/audit-log` | Query mit Filtern |
| GET | `/api/admin/audit-log/export` | CSV-Export (streamed) |
| GET | `/api/admin/legal-holds` | Liste aktiver Holds |
| POST | `/api/admin/legal-holds` | Neu setzen |
| DELETE | `/api/admin/legal-holds/:id` | Aufheben (Pflichtfeld reason) |
| GET | `/api/admin/retention-policies` | Aktuelle Policy-Werte |
| POST | `/api/admin/retention-policies/:key/propose` | Neuen Wert vorschlagen (wartet auf 2. Admin) |
| GET | `/api/admin/retention-policies/proposals` | Offene Proposals für Admin-B |
| POST | `/api/admin/retention-policies/proposals/:id/approve` | Bestätigen |
| POST | `/api/admin/retention-policies/proposals/:id/reject` | Ablehnen |
| GET | `/api/admin/dsg-requests` | Liste offener Anfragen |
| POST | `/api/admin/dsg-requests` | Neue Anfrage erfassen |
| PUT | `/api/admin/dsg-requests/:id` | Status/Notes updaten |
| POST | `/api/admin/dsg-requests/:id/execute-erasure` | Saga `candidate_data_erasure` triggern |

### K.5 RBAC-Gates

**Middleware:** `requireRole('admin')` auf allen `/api/admin/*`-Routes.

**Fehler-Response bei Non-Admin:**
```json
{ "error": "forbidden", "message": "Admin-Rolle erforderlich", "code": 403 }
```

**WICHTIG — Design-Change 2026-04-17:** Die Rolle `head_of_department` hat **keinen** Admin-Zugriff mehr. Alte Route-Matcher, die HoD erlaubten, müssen entfernt werden:

```diff
- const ADMIN_ROLES = ['admin', 'head_of_department']
+ const ADMIN_ROLES = ['admin']
```

HoD-spezifische Datensicht (Team-Workload etc.) erfolgt über erweiterten Team-Scope in `/team` und Dashboard — nicht über `/admin`.

### K.6 WebSocket-Channels (neu)

| Channel | Subscribe-Gate | Payload |
|---------|----------------|---------|
| `admin:events-tail` | role=admin + Tab 9 aktiv | Event-Stream mit Filter |
| `admin:kpi-strip` | role=admin + Admin-View offen | KPI-Delta (30 s) |
| `admin:circuit-breakers` | role=admin + Tab 2/9 offen | CB-State-Change-Broadcasts |
| `admin:saga-failures` | role=admin + Tab 9 Sagas-Sub-Tab offen | Compensation-Broadcasts |
| `admin:dlq-updates` | role=admin + Tab 9 DLQ-Sub-Tab offen | DLQ-Additions |

**Fallback:** Long-Polling `/api/admin/poll?last_ts=...` bei WS-Ausfall.

### K.7 Circuit-Breaker-State-Machine

```
      success
 ┌─────────────────────┐
 │                     │
 ▼                     │
CLOSED ──fail > N/t──▶ OPEN
 ▲                     │
 │                     │ cooldown-timer
 │                     │ T Minuten
 │                     ▼
 └─── success ──── HALF-OPEN
                     │
                     │ fail
                     ▼
                   OPEN (new cooldown)
```

State-Transitions schreiben Event + Audit-Row.

### K.8 Saga-Engine · Admin-Interventionen

Manual-Retry / Skip-Step aus Admin-UI:
- Schreibt `fact_saga_interventions`-Row (neue Table, siehe DB-Addendum wenn ergänzt)
- Audit-Pflicht: Actor + Reason-Required
- Bei Skip-Step: Saga-State markiert `recovered=true, integrity=manual_skip`

### K.9 Settings-Change-Event-Handler

Ein zentraler Event-Handler (`setting-changed.handler.ts`) subscribt auf `setting.changed` und reloaded:

| Key-Prefix | Reloaded Component |
|------------|-------------------|
| `ghosting_*`, `stale_*` | Pipeline-Heatmap + Auto-Flag-Workers |
| `fee_staffel_*` | Placement-Fee-Calculator |
| `refund_staffel_*` | Refund-Calculator |
| `email_rate_*` | Email-Rate-Limiter-Middleware |
| `feature_*` | Feature-Flag-Store (in-memory cache) |
| `3cx_*` | 3CX-Client-Config |
| `ai_token_budget_*` | AI-Usage-Accountant |

Reload ohne Restart — Components holen bei nächstem Request neuen Wert aus DB.

### K.10 Template-Versionierung · Event-Pattern

Bei Template-Update:
1. Snapshot alte Version in `fact_template_versions`
2. Inkrement `version` (semver-minor)
3. Emit `{reminder|email|notification}_template.updated`
4. Abonnenten (Rule-Worker, Email-Worker) laden neue Version nur bei Major-Bump automatisch · bei Minor bleibt gepinnte Version aktiv (User-Opt-in zum Upgrade)

### K.11 Coverage-Check gegen Admin-Spec

| Admin-Spec §  | Backend-Artefakt | Status |
|---------------|------------------|--------|
| §2 Tab-Bootstrap | Bootstrap-Endpunkte pro Tab | ✅ K.4 |
| §5 Rule-Builder | `/api/admin/automation-rules` + test-run | ✅ K.4.2 |
| §5.2.6 Test-Run | `POST .../test-run` | ✅ K.4.2 |
| §5.3 CB Manual-Reset | `POST /api/admin/circuit-breakers/:id/reset` | ✅ K.4.2 |
| §7.4 CodeTwo-Sync | Saga + Worker + Endpunkt | ✅ K.3.3 + K.4.4 |
| §7.3 OAuth-Token-Ablauf | Worker W2 + Event 14/15 | ✅ K.1/K.2 |
| §10.2 Saga-Retry | `POST /api/admin/sagas/:id/retry` | ✅ K.4.8 |
| §11.2 Dashboard-Reset-Bulk | `POST .../reset-user-overrides` + Event 21 | ✅ K.4.7 |
| §13.3 Legal-Hold-Blocker | Worker W6 + Event 22/23 | ✅ K.1/K.2 |
| §13.5 Retention Vier-Augen | Endpunkte K.4.9 (propose/approve/reject) | ✅ K.4.9 |
| §13.6 DSG-Request | Endpunkte K.4.9 + Saga K.3.1 | ✅ K.3.1 + K.4.9 |
| §14 RBAC (HoD kein Admin) | Middleware-Change K.5 | ✅ K.5 |
| §17 Circuit-Breaker-State | K.7 State-Machine | ✅ K.7 |

---

**Ende Backend-Architecture-Patch v2.5 → v2.6 inkl. Admin-Vollansicht-Addendum.**

**Ende Backend-Architektur-Patch v2.5 → v2.6.**
