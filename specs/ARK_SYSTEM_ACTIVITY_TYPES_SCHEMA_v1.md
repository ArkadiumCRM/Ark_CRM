# ARK CRM — System-Activity-Types Schema v1.3

**Stand:** 17.04.2026
**Status:** Review ausstehend — v1.3 konsolidiert alle Open-Questions aus v1.2 (siehe [Decisions-Doc](ARK_SYSTEM_ACTIVITY_TYPES_DECISIONS_v1_3.md))

**Begleitdokumente (alle parallel erstellt):**
- `specs/ARK_STAMMDATEN_PATCH_v1_3_to_v1_4_ACTIVITY_TYPES.md` — §14 Activity-Katalog-Erweiterung
- `specs/ARK_DATABASE_SCHEMA_PATCH_v1_3_to_v1_4.md` — DB-Änderungen
- `specs/ARK_BACKEND_ARCHITECTURE_PATCH_v2_5_to_v2_6.md` — Event-Processor-Erweiterung
- `migrations/001_system_activity_types.sql` — ausführbares Migrations-Script

**Quellen:**
- `raw/Ark_CRM_v2/ARK_STAMMDATEN_EXPORT_v1_3.md` §14 (Activity-Katalog bestehend, 69 Typen)
- `raw/Ark_CRM_v2/ARK_BACKEND_ARCHITECTURE_v2_5.md` Sektion A/B/D/G
- `raw/Ark_CRM_v2/ARK_DATABASE_SCHEMA_v1_3.md` (`fact_event_queue`, `fact_event_log`, `fact_history`, `dim_activity_types`, `dim_event_types`, `dim_automation_rules`)
- `wiki/concepts/automationen.md`, `event-system.md`, `history-system.md`, `scraper.md`, `reminders.md`
- Entscheidungen 17.04.2026: D1=7 neue Kategorien · D2=`dim_event_types`-Mapping · D3=Saga-Hybrid · D4=Low-Value-Events nur in Queue/Log

**Vorrang:** Stammdaten > dieses Schema > Frontend Freeze > Mockups

---

## Changelog v1.0 → v1.3

| # | Version | Korrektur | Sektion | Grund |
|---|---------|-----------|---------|-------|
| 1 | v1.2 | `fact_system_log` wird **NICHT** neu erstellt | §2.3 (entfernt) | Bestehende `fact_event_queue` + `fact_event_log` decken Ops-Audit komplett ab |
| 2 | v1.2 | Kein neuer Worker `system-activity-writer` | §5 (umgeschrieben) | Bestehender `event-processor.worker.ts` wird erweitert (Pre-Rule-Hook) |
| 3 | v1.2 | `dim_event_types` existiert bereits — ALTER statt CREATE | §2.2 | v1.3-Schema hat schon die Tabelle |
| 4 | v1.2 | Kategorie „System-Log-Events" umbenannt in „Queue-only-Events" | §4.2 | Konsistenz mit neuer Architektur |
| 5 | v1.2 | §6 Saga-Handling verweist auf Backend-Arch-Patch | §6 | Detail dort, hier nur Prinzip |
| 6 | v1.2 | Migration vereinfacht (2 ALTER statt 3 ALTER + 2 CREATE) | §8 | Weniger Infrastruktur-Änderungen |
| 7 | **v1.3** | Mini-User-Chip neben 🤖 bei `actor_type='integration'` + `mitarbeiter_id IS NOT NULL` | §7.1 | Outlook-/Kalender-Sync-Events machen initiierenden User sichtbar |
| 8 | **v1.3** | UNIQUE-Constraint `fact_history.event_id` statt 24h-Zeitfenster | §2.4 + §5.3 | Deterministische Idempotenz via DB-Constraint |
| 9 | **v1.3** | Notification-Dedup via Redis-Lock 60s TTL | §5.5 (neu) | Verhindert doppelte Notifications bei Hook+Rule-Fanout |
| 10 | **v1.3** | AI-Klassifizierung als Overlay statt eigener Timeline-Row | §4.1 (angepasst) | `history.classification_suggested` → `create_history=false`, nutzt bestehende `fact_history.suggested_activity_type` |
| 11 | **v1.3** | Namensvereinheitlichungen (4 Events auf kanonische Form) | §4 | siehe Decisions-Doc §Namensvereinheitlichungen |
| 12 | **v1.3** | `system.retention_action` in 2 Events gesplittet (.candidate → history / .other → queue) | §4 | Conditional Mapping sauber modellieren |

**Kernaussage:** ARK-Event-Infrastruktur ist **bereits vollständig ausreichend** — System-Activity-Types erfordern nur Katalog-Expansion + 2 Tabellen-ALTER + 1 Code-Hook im bestehenden Event-Processor.

---

## 0. ZIELBILD

System-seitige Aktionen (Automation, Integrations, Saga-Steps, Scheduled Jobs, AI-Pipelines) werden **katalogisiert** und landen — je nach User-Relevanz — entweder auf der User-sichtbaren Activity-Timeline (`fact_history`) oder bleiben ausschliesslich in der Event-Queue (`fact_event_queue` + `fact_event_log`).

**Abgrenzung:**

| Akteur | Beispiel | Ziel | UI-Sichtbarkeit |
|--------|----------|------|-----------------|
| **User** (Consultant) | Anruf, Email, Briefing-Gespräch | `fact_history` | Timeline aller Masken |
| **System/Automation** (User-relevant) | Stage-Auto-Transition, Credit verbraucht, Garantiefrist gestartet | `fact_history` + `is_auto_logged=true` + Badge 🤖 | Timeline, filterbar |
| **System/Automation** (Ops-only) | Temperature-Scoring, Matching-Recompute, Circuit-Breaker | `fact_event_queue` + `fact_event_log` (keine `fact_history`-Row) | Admin-Debug-Tab, nicht in User-Timeline |
| **Saga-Engine** (V1–V6 Steps) | `saga.v3_job_filled` | `fact_event_queue` + `fact_event_log` | Admin-Debug-Tab |
| **Saga-Engine** (V7 abgeschlossen) | `process.placement_completed` | `fact_history` | Timeline (eine Sammel-Row pro Placement) |

**Datenfluss-Prinzip (korrigiert v1.2):**

```
Backend-Trigger / Worker / Integration
        │
        ▼
fact_event_queue  (BESTEHEND)
        │
        ▼
event-processor.worker.ts  (BESTEHEND, erweitert in v2.6)
        │
   ┌────┴──────────────────────────┐
   ▼                               ▼
[Pre-Rule-Hook v2.6:             [Rule-Execution v2.5]
 wenn dim_event_types.            Automation-Rules aus
 create_history=true → INSERT     dim_automation_rules
 fact_history mit default_        (create_reminder, send_notification,
 activity_type_id]                trigger_ai, create_history, ...)
   │                               │
   └─────────────┬─────────────────┘
                 ▼
       fact_event_log (Rule-Execution-Trace)
       fact_event_queue.status='done'
```

**Primäre Nutzer:**
- **Consultant (CM/AM):** sieht System-Events in Timeline mit Badge 🤖; Filter-Chip „Nur User-Aktionen" default off
- **Admin:** zusätzlich Debug-Tab mit `fact_event_queue` + `fact_event_log` für Saga-Traces, Failed Events, Circuit-Breaker-Status
- **Backend-Worker:** schreibt ausschliesslich über Event-Emission in `fact_event_queue`, nie direkt in `fact_history`

---

## 1. DESIGN-SYSTEM-REFERENZ

Timeline-Komponente erbt aus `ARK_KANDIDATENMASKE_SCHEMA_v1_3.md` §0. System-Events erhalten:

| Token | Wert | Verwendung |
|-------|------|-----------|
| Icon System | 🤖 (SVG-Icon) | Avatar-Slot statt User-Kürzel |
| Farbe System-Zeile | `#64748b` (slate-500) | Subtiler als User-Action |
| Source-System-Badge | pill, `font-mono` | `3cx` / `outlook` / `scraper` / `llm` / `saga` / `batch` |

---

## 2. DATENMODELL

**Details siehe:** `specs/ARK_DATABASE_SCHEMA_PATCH_v1_3_to_v1_4.md`

### 2.1 `dim_activity_types` — ALTER (3 neue Spalten)

```sql
ALTER TABLE ark.dim_activity_types ADD COLUMN actor_type text
  NOT NULL DEFAULT 'user'
  CHECK (actor_type IN ('user','system','automation','integration'));

ALTER TABLE ark.dim_activity_types ADD COLUMN source_system text NULL
  CHECK (source_system IS NULL OR source_system IN (
    'threecx','outlook','gmail','scraper','llm','saga-engine',
    'nightly-batch','event-worker','manual-upload','calendar-integration'));

ALTER TABLE ark.dim_activity_types ADD COLUMN is_notifiable boolean
  NOT NULL DEFAULT false;
```

Zusätzlich: `activity_category`-CHECK erweitert um 7 neue Werte (siehe §3).

**Feldsemantik:**
- `actor_type` — wer generiert Row in `fact_history`. `user` = manuell; `system` = Scheduled-Batch; `automation` = eventgetrieben; `integration` = externes System (3CX, Outlook, Scraper).
- `source_system` — technische Herkunft für Debug/Filter. Nullable für `user`-Rows.
- `is_notifiable` — steuert Notification-Fanout. Default false.

### 2.2 `dim_event_types` — ALTER (NICHT CREATE — Tabelle existiert bereits v1.3)

v1.3-Schema hat bereits: `event_category`, `entity_type`, `event_name` UNIQUE, `event_description`, `payload_schema_json`, `is_automatable`, `sort_order`.

v1.4-Erweiterung: 5 neue Spalten + `event_category`-CHECK erweitert:

```sql
ALTER TABLE ark.dim_event_types
  ADD COLUMN default_activity_type_id uuid NULL
    REFERENCES ark.dim_activity_types(id);

ALTER TABLE ark.dim_event_types
  ADD COLUMN default_actor_type text NOT NULL DEFAULT 'automation'
    CHECK (default_actor_type IN ('system','automation','integration'));

ALTER TABLE ark.dim_event_types
  ADD COLUMN default_source_system text NULL;

ALTER TABLE ark.dim_event_types
  ADD COLUMN emitter_component text NULL;

ALTER TABLE ark.dim_event_types
  ADD COLUMN create_history boolean NOT NULL DEFAULT false;

ALTER TABLE ark.dim_event_types ADD CONSTRAINT check_history_mapping
  CHECK (create_history = false OR default_activity_type_id IS NOT NULL);
```

`event_category`-CHECK erweitert um: `assessment`, `guarantee`, `protection_window`, `saga`, `ai`, `finance`, `referral`.

### 2.3 KEINE neue Tabelle `fact_system_log` (korrigiert v1.2)

**Begründung:** Bestehende Infrastruktur deckt Ops-Audit komplett ab:

| Use-Case | Abdeckung (bestehend) |
|----------|----------------------|
| Saga V1–V6 Step-Trace | `fact_event_queue` (alle Events mit `correlation_id`) + `fact_event_log` (Rule-Executions mit Input/Output-Snapshot) |
| Temperature/Matching-Batch | `fact_event_queue` mit `event_name='temperature.updated'`, `create_history=false` |
| Circuit-Breaker-Event | `dim_automation_rules.circuit_breaker_tripped` + Event in Queue |
| Dead-Letter-Events | `fact_event_queue.status='dead_lettered'` + `dead_lettered_at` + `error_message` |
| Retention-Warning | `fact_event_queue` mit `event_name='retention.warning'` |

**Admin-Debug-Query-Beispiel:**

```sql
-- Alle Events eines Kandidaten (system + user):
SELECT eq.triggered_at, eq.event_name, et.create_history,
       et.default_actor_type, eq.status
FROM ark.fact_event_queue eq
JOIN ark.dim_event_types et ON et.id = eq.event_type_id
WHERE eq.entity_type = 'candidate' AND eq.entity_id = $1
ORDER BY eq.triggered_at DESC;

-- Komplette Saga-Timeline via correlation_id:
SELECT eq.triggered_at, eq.event_name, el.action_taken, el.duration_ms
FROM ark.fact_event_queue eq
LEFT JOIN ark.fact_event_log el ON el.event_id = eq.id
WHERE eq.correlation_id = $1
ORDER BY eq.triggered_at;
```

### 2.4 `fact_history` — minimale Änderung (v1.3)

Bestehende Struktur:
- `activity_type_id` FK → `dim_activity_types` (neu mit `actor_type='system'` möglich)
- `is_auto_logged` boolean (bereits vorhanden)
- `event_id` FK → `fact_event_queue` (bereits vorhanden)
- `categorization_status` (`pending`/`manual`/`ai_suggested`/`confirmed`, bereits vorhanden)
- `suggested_activity_type` text (bereits vorhanden — wird v1.3 für AI-Overlay genutzt)
- `ai_summary` text (bereits vorhanden — wird v1.3 für AI-Overlay genutzt)
- `mitarbeiter_id` FK (bereits vorhanden — wird v1.3 von Writer bei `actor_type='integration'` aus `event.triggered_by` übertragen)

**Eine neue Constraint v1.3:**

```sql
ALTER TABLE ark.fact_history ADD CONSTRAINT uniq_fact_history_event_id
  UNIQUE (event_id) WHERE event_id IS NOT NULL;
```

Garantiert Idempotenz des Writers: ein `fact_event_queue.id` kann höchstens eine `fact_history`-Row erzeugen. Writer-Retries und Doppel-Verarbeitung sind damit DB-seitig abgefangen (kein Code-seitiges Zeitfenster nötig).

`actor_type` und `source_system` werden über JOIN auf `dim_activity_types` gelesen, nicht redundant in `fact_history` gespeichert.

---

## 3. ACTIVITY-KATEGORIEN — ERWEITERUNG AUF 18 (bisher 11)

Bestehend: Kontaktberührung · Erreicht · Emailverkehr · Messaging · Interviewprozess · Placementprozess · Refresh Kandidatenpflege · Mandatsakquise · Erfolgsbasis · Assessment · System / Meta (v1.4: Umbenennung von „System")

**NEU v1.4 — 7 zusätzliche Kategorien:**

| # | Kategorie | Fokus | Rows (Ziel) |
|---|-----------|-------|-------------|
| 12 | Kalender & Planung | Interview-Termin, Auto-Reminder | 3 |
| 13 | Dokumenten-Pipeline | Upload, CV-Parse, OCR, Embedding | 5 |
| 14 | Garantie & Schutzfrist | Garantie/Schutzfrist-Lifecycle, Claims | 7 |
| 15 | Scraper & Intelligence | Market-Change-Detection, Claim-Matching | 6 |
| 16 | Pipeline-Transitions (Auto) | Jobbasket/Prozess Stage-Auto-Wechsel | 8 |
| 17 | Saga-Events (User-sichtbar) | Nur `V7=placement_completed` | 1 |
| 18 | AI & LLM | Transkription, Auto-Fill, Klassifizierungs-Vorschlag | 3 |

**Summe Activity-Types:** 69 (v1.3) + 37 (v1.4: 33 in neuen Kategorien + 4 in bestehenden) = **106 Rows**.

**Queue-only-Events** (keine `dim_activity_types`-Row, nur `dim_event_types` mit `create_history=false`): zusätzlich **15 Events**.

Vollständige Row-Liste in `specs/ARK_STAMMDATEN_PATCH_v1_3_to_v1_4_ACTIVITY_TYPES.md`.

---

## 4. EVENT-KATALOG (Übersicht)

Vollständige Liste: `specs/ARK_STAMMDATEN_PATCH_v1_3_to_v1_4_ACTIVITY_TYPES.md` §Neue Sektionen.

### 4.1 Events → `fact_history` (User-sichtbar, `create_history=true`)

~32 neue Events, Mapping zu 33 neuen Activity-Types plus 4 Ergänzungen in bestehenden Kategorien. Gruppiert nach Domäne:

| Domäne | Events | Activity-Types |
|--------|--------|----------------|
| Kalender | `interview.scheduled`, `reminder.interview_upcoming`, `reminder.interview_date_missing` | #70–72 |
| Dokumente | `document.cv_parsed`, `document.ocr_done`, `document.embedded`, `document.uploaded`, `document.reparsed` | #73–77 |
| Garantie/Schutzfrist | `guarantee.started/fulfilled/breached`, `reminder.guarantee_expiring`, `protection_window.started/extended`, `direct_hire_claim.opened` | #78–84 |
| Scraper | `scrape.new_person/person_left/new_job_detected/role_changed/item_imported/protection_match` | #85–90 |
| Pipeline | `jobbasket.go_oral/go_written/stage_assigned/stage_to_send/cv_sent`, `process.stale_detected/auto_rejected` + bestehender `process.stage_changed` mapped | #91–98 |
| Saga (User-V7) | `process.placement_completed` | #99 |
| AI/LLM | `briefing.auto_filled`, `call.transcript_ready`, `history.classification_suggested` | #100–102 |
| Ergänzungen | `email.bounced`, `assessment.credit_consumed`, `referral.triggered`, `candidate.anonymized` | #103–106 |

### 4.2 Queue-only-Events (`create_history=false`, vorher: „System-Log-Events")

15 Events — bleiben in `fact_event_queue`, keine `fact_history`-Row, kein `dim_activity_types`-Eintrag. Nur in Admin-Debug-Tab sichtbar.

| event_name | event_category | severity | emitter |
|-----------|----------------|----------|---------|
| `saga.v1_stage_placement` | saga | info | saga-engine-v7 |
| `saga.v2_finance_calculated` | saga | info | saga-engine-v7 |
| `saga.v3_job_filled` | saga | info | saga-engine-v7 |
| `saga.v4_guarantee_opened` | saga | info | saga-engine-v7 |
| `saga.v5_referral_triggered` | saga | info | saga-engine-v7 |
| `saga.v6_staffing_plan_updated` | saga | info | saga-engine-v7 |
| `saga.failure` | saga | error | saga-engine-v7 |
| `temperature.updated` | system | debug | nightly-scoring-batch |
| `matching.scores_recomputed` | match | debug | matching-recompute-worker |
| `staffing_plan.updated` | system | info | project-staffing-worker |
| `webhook.triggered` | system | info | webhook-dispatcher |
| `dead_letter.alert` | system | error | event-queue-monitor |
| `process.duplicate_detected` | process | warn | process-creation-guard |
| `circuit_breaker.tripped` | system | critical | automation-engine |
| `retention.warning` | system | warn | gdpr-retention-batch |

**Severity** wird über `fact_event_queue.status` + Rule-Execution-Outcome abgeleitet — kein separates Feld nötig.

---

## 5. EVENT-PROCESSOR-ERWEITERUNG (statt neuer Worker)

**Details siehe:** `specs/ARK_BACKEND_ARCHITECTURE_PATCH_v2_5_to_v2_6.md` §A

### 5.1 Kein neuer Worker

v1.0 plante einen Worker `system-activity-writer`. Review ergab: **überflüssig**.

- `event-processor.worker.ts` existiert bereits als zentraler Event-Consumer (v2.5)
- `dim_automation_rules.action_type` hat bereits Wert `'create_history'` (bestehende Rule-Action)
- Neue Logik: **Pre-Rule-Hook** in bestehendem Processor

### 5.2 Pre-Rule-Hook Flow

```typescript
// Erweiterung von /src/workers/event-processor.worker.ts (v2.6)
async function handleEvent(eventId, tenantId) {
  const event = await loadEvent(eventId, tenantId)
  const eventType = await loadEventType(event.event_type_id)

  // Pre-Rule-Hook v2.6: automatisches fact_history-Insert
  if (eventType.create_history && eventType.default_activity_type_id) {
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

  // Bestehend: Rule-Execution
  const rules = await loadMatchingRules(event.event_type_id, tenantId)
  for (const rule of rules) { /* ... */ }

  await markEventProcessed(eventId)
  await writeEventLog(eventId)
}
```

### 5.3 Idempotenz

`fact_history.event_id` UNIQUE constraint → doppelte Event-Processing schreibt nicht zweimal.

### 5.4 Feature-Flag

`dim_automation_settings.system_event_writer_enabled` (bool). Default `true`, Emergency-Off via SQL-Update.

### 5.5 Notification-Dedup (Redis-Lock, v1.3)

Wenn sowohl Pre-Rule-Hook (`is_notifiable=true`) ALS AUCH eine Automation-Rule (`action_type='send_notification'`) für dasselbe Event feuern → doppelte Benachrichtigung. Lösung v1.3:

```typescript
const lockKey = `notif-dedup:${event_id}:${recipient}:${template}`
const acquired = await redis.set(lockKey, '1', { NX: true, EX: 60 })
if (!acquired) {
  logger.debug({ lockKey }, 'notification deduplicated')
  return
}
await sendNotification(...)
```

- TTL 60 s: deckt Worker-Retries + Rule-Execution-Verzögerung ab
- Fallback bei Redis-Ausfall: beide Notifications feuern (besser zu viel als zu wenig)
- Alternative ohne Redis: `pg_advisory_lock(hashtext(lockKey))` mit gleicher Semantik

---

## 6. SAGA V1–V7 HANDLING (D3-Hybrid)

**Details siehe:** `specs/ARK_BACKEND_ARCHITECTURE_PATCH_v2_5_to_v2_6.md` §C

**Prinzip:**

| Step | Event | Ziel |
|------|-------|------|
| V1 | `saga.v1_stage_placement` | `fact_event_queue` nur (keine history) |
| V2 | `saga.v2_finance_calculated` | Queue only |
| V3 | `saga.v3_job_filled` | Queue only |
| V4 | `saga.v4_guarantee_opened` + parallel `guarantee.started` | Queue + `fact_history` (Activity #78) |
| V5 | `saga.v5_referral_triggered` + parallel `referral.triggered` | Queue + `fact_history` (Activity #105) |
| V6 | `saga.v6_staffing_plan_updated` | Queue only |
| V7 | `process.placement_completed` | Queue + `fact_history` (Activity #99, User-Timeline-Row) |

**Correlation-ID:** Alle 7+2=9 Events teilen sich `saga_run.id` als `correlation_id`. Admin-Debug-Drawer auf `process.placement_completed`-Row zeigt alle Substeps via Query:

```sql
SELECT * FROM ark.fact_event_queue
WHERE correlation_id = $1 AND event_name LIKE 'saga.%';
```

**Rollback:** Failure in V_X → `saga.failure`-Event, kein `process.placement_completed` → Placement nicht in User-Timeline. Notification an Process-Owner.

**TX2–TX8** analog: Sub-Step-Events queue-only, ein user-sichtbarer Aggregat-Event in `fact_history`.

---

## 7. UI-IMPACT

### 7.1 Timeline-Komponente (alle 9 Detailmasken)

**Rendering-Regel für `fact_history`-Row (v1.3 erweitert):**

```
IF dim_activity_types.actor_type = 'user' THEN
  [Avatar: User-Kürzel PW/JV/LR]  Activity-Type-Name

ELSIF dim_activity_types.actor_type = 'integration' AND fact_history.mitarbeiter_id IS NOT NULL THEN
  [Avatar: 🤖 + source_system-Badge]  [Mini-Chip: via PW]  Activity-Type-Name
  -- z.B. Outlook-Sync: PW war Kalender-Organizer → sichtbar ohne Prominenz

ELSIF dim_activity_types.actor_type IN ('system','automation') THEN
  [Avatar: 🤖 + source_system-Badge]  Activity-Type-Name
  -- autonome Events (Nightly-Batch, Saga-Engine) ohne initiierenden User

ELSIF dim_activity_types.actor_type = 'integration' AND fact_history.mitarbeiter_id IS NULL THEN
  [Avatar: 🤖 + source_system-Badge]  Activity-Type-Name
  -- Scraper-Events o.ä. ohne User-Attribution
END
```

**Filter-Chips (Timeline-Header):**

| Chip | Default | Wirkung |
|------|---------|---------|
| Alle | aktiv | kein Filter |
| Nur User-Aktionen | inaktiv | WHERE actor_type = 'user' |
| Nur System-Events | inaktiv | WHERE actor_type <> 'user' |
| Source-Filter (Multi) | leer | WHERE source_system IN (...) |

### 7.2 Mockups zu aktualisieren

| Datei | Änderung |
|-------|----------|
| `mockups/activities.html` | Master — Filter-Chips, Badge-Styling, 🤖-Icon |
| `mockups/candidates.html`, `accounts.html`, `jobs.html`, `mandates.html`, `projects.html`, `placements.html` | Timeline-Tab: neues Rendering |
| `mockups/processes.html` | Timeline-Tab + `process.placement_completed`-Row öffnet Sub-Drawer mit V1–V6-Substeps aus `fact_event_queue` |

### 7.3 Admin-Debug-Tab (neu)

Route `/admin/event-log` (nur Role=Admin):
- Filter: `entity_type`, `entity_id`, `event_category`, `correlation_id`, Zeitraum
- Query-Basis: `fact_event_queue` JOIN `dim_event_types` JOIN `fact_event_log`
- Export: CSV für einzelne Saga-Traces
- Live-Tail: WebSocket-Topic `admin.event_queue` pusht neue Rows

Separate Spec: `ARK_ADMIN_DEBUG_SCHEMA_v1_0.md` (out of scope hier).

---

## 8. MIGRATION

**Details siehe:** `migrations/001_system_activity_types.sql` + `specs/ARK_DATABASE_SCHEMA_PATCH_v1_3_to_v1_4.md`

### 8.1 Kernschritte

```
1. ALTER dim_activity_types: +3 Spalten, CHECK erweitert
2. ALTER dim_event_types: +5 Spalten, CHECK erweitert, Constraint
3. ALTER fact_event_queue.source_system CHECK erweitert
4. Seed dim_activity_types: +37 Rows (#70–#106)
5. Seed dim_event_types: +~30 neue Events + Update ~25 bestehender mit Mapping
6. Backfill actor_type für 6 bestehende is_auto_loggable=true Rows
7. Deploy event-processor.worker.ts v2.6 (Feature-Flag off)
8. Smoke-Test Staging, dann Feature-Flag on
9. Schrittweise Migration ad-hoc fact_history.insert() → Event-Emission (Sprint 2-4)
```

### 8.2 Rollout-Phasen

| Phase | Zeit | Scope |
|-------|------|-------|
| A | 2d | SQL-Migration + Seed + Deploy v2.6 (Flag off) |
| B | 1d | Staging Smoke-Test, Flag on Staging |
| C | 3d | Prod Rollout 50% → 100% |
| D | 2d | Mockups + Frontend Timeline-Badge |
| E | 2d | Bestehende ad-hoc Inserts migrieren |
| F | 4d | Gap-Events implementieren (bestehend-Code-Änderungen im Backend) |

### 8.3 Rollback

Emergency-Flag in SQL:
```sql
UPDATE ark.dim_automation_settings
  SET value_bool = false
  WHERE key = 'system_event_writer_enabled';
```
Alles weitere ist additiv (neue Spalten mit DEFAULT, erweiterte CHECKs) — kein Datenverlust bei Rollback.

---

## 9. OPEN QUESTIONS — resolved v1.3

Alle 9 Fragen sind durch `specs/ARK_SYSTEM_ACTIVITY_TYPES_DECISIONS_v1_3.md` entschieden:

| # | Frage | Entscheidung v1.3 | Doc-Ref |
|---|-------|-------------------|---------|
| Q1 | Saga-Sub-Step-Audit | Backend-Team-Task (Sprint 1 vor v2.6-Deploy) | Decisions §Team-Tasks |
| Q2 | Integration-Actor optional User zeigen | **Ja** — Mini-User-Chip bei `mitarbeiter_id` gesetzt (siehe §7.1) | Decisions §Q2 |
| Q3 | `email.received` Fallback | #120 + `categorization_status=pending` + `is_notifiable=true` | Event-Mapping + Decisions §M2 |
| Q4 | Saga-Failures in User-Timeline | **Nein** — nur Notification, Details im Admin-Debug | Decisions §Q4 |
| Q5 | Scrape-Events Granularität | **Pro Entity** (nicht Batch) | Decisions §Q5 |
| Q6 | Notification-Channel v1.4 | **In-App only** — Email-Digest v1.5 | Decisions §Q6 |
| Q7 | `deprecated_at`-Feld | **Nein** — `is_automatable=false` reicht | Decisions §Q7 |
| Q8 | Duplicate Notifications Hook+Rule | **Redis-Lock** 60s TTL pro `(event_id, recipient, template)` | Decisions §Q8 + §5.5 unten |
| Q9 | Numbering sequentiell vs thematisch | **Sequentiell** #70–#121 bestätigt | Decisions §Q9 |

---

## 10. SYNC-MATRIX zu Grundlagen

| Grundlagen-Datei | Änderung | Sektion | Version-Bump |
|------------------|----------|---------|--------------|
| `ARK_STAMMDATEN_EXPORT_v1_3.md` | §14 Kategorien 11→18; +37 Rows; §14 Statistik; §14c Event-Katalog; §14d Queue-only-Events | §14, §14c, §14d | → v1_4 |
| `ARK_DATABASE_SCHEMA_v1_3.md` | 2× ALTER (`dim_activity_types`, `dim_event_types`) + `fact_event_queue.source_system` CHECK | Tabellen-Sektionen | → v1_4 |
| `ARK_BACKEND_ARCHITECTURE_v2_5.md` | §A Event-Processor-Erweiterung; §D Saga-Correlation-Pflicht; §G Registry +35 Resolver; §H 4 neue Settings-Keys | A, D, G, H | → v2_6 |
| `ARK_FRONTEND_FREEZE_v1_*.md` | Timeline-Badge 🤖, Filter-Chips, Admin-Debug-Route | UI-Komponenten, Routing | neue Version |
| `ARK_GESAMTSYSTEM_UEBERSICHT_v1_*.md` | Changelog-Eintrag v1.4 | Changelog | neue Version |

**Detailmasken-Specs (9)** — kein Version-Bump, Timeline erbt aus zentraler Komponente.

---

## 11. ABHÄNGIGKEITEN & OUT-OF-SCOPE

**In-Scope v1.2:**
- Datenmodell (2 ALTER + 1 CHECK-Erweiterung)
- 37 neue Activity-Types, ~30 neue Event-Types
- Event-Processor Pre-Rule-Hook
- Saga-Correlation-Pflicht

**Out-of-Scope v1.2 (separate Specs):**
- Admin-Debug-Tab-UI → `ARK_ADMIN_DEBUG_SCHEMA_v1_0.md`
- Notification-Channel-Email-Digest → `ARK_NOTIFICATION_SCHEMA_v1_0.md`
- Email-Template ↔ Event-Type Mapping-Tabelle → `ARK_EMAIL_AUTOMATION_SCHEMA_v1_0.md`
- AI-Klassifizierungs-Vorschlag-UX → `ARK_AI_PIPELINE_SCHEMA_v1_0.md`

---

## 12. FERTIGSTELLUNGS-KRITERIEN v1.2

- [ ] SQL-Migration `001_system_activity_types.sql` gereviewt + in Staging deployed
- [ ] `dim_event_types` mit ~30 neuen Rows + ~25 Updates geseeded
- [ ] 37 neue `dim_activity_types`-Rows geseeded (Validierung via DO-Block passed)
- [ ] `event-processor.worker.ts` v2.6 deployed + Feature-Flag auf
- [ ] Mindestens 1 Test-Event pro Domäne durchgängig: Emit → Queue → Processor → `fact_history` → Timeline
- [ ] Saga-Test: Placement durchlaufen, alle 7 Steps mit `correlation_id` in Queue, V7 in `fact_history`
- [ ] Dead-Letter-Monitoring + Prometheus-Metriken in Prod aktiv
- [ ] 5 Grundlagen-Dateien auf v1.4/v1.4/v2.6 synchronisiert
- [ ] Mockup `activities.html` Filter-Chips + Badge-Rendering sichtbar
- [ ] Event-Scope-Registry mit 35 neuen Resolvern ergänzt

---

**Ende v1.3.** Review-Freigabe durch PO + Backend-Lead erforderlich vor Implementierungs-Start. Alle Open-Questions aus v1.2 sind jetzt entschieden (siehe `specs/ARK_SYSTEM_ACTIVITY_TYPES_DECISIONS_v1_3.md`).
