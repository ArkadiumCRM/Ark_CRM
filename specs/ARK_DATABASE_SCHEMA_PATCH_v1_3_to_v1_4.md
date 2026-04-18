# ARK CRM — DB-Schema-Patch v1.3 → v1.4

**Scope:** Datenmodell-Änderungen für System-Activity-Types
**Zielversion:** `ARK_DATABASE_SCHEMA_v1_4.md`
**Basis-Spec:** `specs/ARK_SYSTEM_ACTIVITY_TYPES_SCHEMA_v1.md`
**Stammdaten-Patch:** `specs/ARK_STAMMDATEN_PATCH_v1_3_to_v1_4_ACTIVITY_TYPES.md`
**Migration-Script:** `migrations/001_system_activity_types.sql`
**Stand:** 17.04.2026
**Status:** Review ausstehend

---

## KORREKTUR zur Spec v1.0

Bei DB-Review wurde festgestellt, dass die ursprüngliche Spec-Annahme inkorrekt war:

| Spec v1.0 Annahme | Realität | Konsequenz |
|-------------------|----------|-------------|
| `dim_event_types` muss CREATE werden | **Existiert bereits** mit `event_category`, `event_name`, `payload_schema_json`, `is_automatable`, `sort_order` | Nur ALTER + Seed nötig |
| `fact_system_log` als neue Tabelle | **Redundant** — `fact_event_queue` + `fact_event_log` decken Ops-Audit komplett ab | **fact_system_log wird NICHT erstellt** |
| `event_domain`-Feld neu | Existiert bereits als `event_category` mit 13 Werten | Check-Constraint erweitern |

**Neue Architektur (korrigiert):**

```
Trigger → fact_event_queue (bestehend, alle Events)
              │
              ▼
      system-activity-writer (NEU)
              │
         ┌────┴────┐
         ▼         ▼
  fact_history    (nichts — Event bleibt nur in Queue/Log)
  wenn dim_event_types.default_activity_type_id IS NOT NULL

Zusätzlich: automation-rules schreiben weiterhin in fact_event_log (Rule-Execution-Trace, bestehend).
```

---

## Changelog v1.3 → v1.4

| # | Tabelle | Änderung | Typ |
|---|---------|----------|-----|
| 1 | `dim_activity_types` | +3 Spalten: `actor_type`, `source_system`, `is_notifiable` | ALTER |
| 2 | `dim_event_types` | +5 Spalten: `default_activity_type_id`, `default_actor_type`, `default_source_system`, `emitter_component`, `create_history` | ALTER |
| 3 | `dim_event_types.event_category` | CHECK erweitert um 7 Werte (`guarantee`, `protection_window`, `saga`, `ai`, `finance`, `referral`, `assessment`) | ALTER CHECK |
| 4 | `fact_event_queue.source_system` | CHECK erweitert um 7 Werte (`gmail`, `llm`, `saga-engine`, `nightly-batch`, `event-worker`, `manual-upload`, `calendar-integration`) | ALTER CHECK |
| 5 | `dim_activity_types` | +37 Seed-Rows (#70–#106) | DATA |
| 6 | `dim_event_types` | +~35 Seed-Rows (neue Events aus Spec-Katalog) | DATA |
| 7 | Indizes | +2 auf `dim_activity_types(actor_type)` und `dim_event_types(create_history, default_activity_type_id)` | INDEX |

**Nicht in v1.4:**

- KEINE neue Tabelle `fact_system_log` (durch `fact_event_queue` + `fact_event_log` abgedeckt)
- KEINE Änderung an `fact_history` (existierende Spalten `activity_type_id`, `is_auto_logged`, `event_id` reichen)
- KEINE Änderung an `dim_automation_rules` (Circuit-Breaker bereits vorhanden)

---

## 1. ALTER `dim_activity_types`

**Ist-Stand (v1.3):**
```sql
activity_type_name  text NOT NULL UNIQUE
activity_category   text CHECK (activity_category IN (
  'Kontaktberührung','Erreicht','Emailverkehr','Messaging',
  'Interviewprozess','Placementprozess','Refresh Kandidatenpflege',
  'Mandatsakquise','Erfolgsbasis','Assessment','System'))
activity_channel    text CHECK (activity_channel IN ('Phone','Email','In-Person','Video','Chat',
  'App','LinkedIn','Whatsapp','Xing','Social Media','CRM','System'))
is_auto_loggable    boolean NOT NULL DEFAULT false
description         text
```

**Soll-Stand (v1.4) — Änderungen:**

```sql
-- v1.4: Kategorien-CHECK auf 18 Werte erweitert (7 neue)
activity_category   text CHECK (activity_category IN (
  'Kontaktberührung','Erreicht','Emailverkehr','Messaging',
  'Interviewprozess','Placementprozess','Refresh Kandidatenpflege',
  'Mandatsakquise','Erfolgsbasis','Assessment','System / Meta',
  -- NEU v1.4:
  'Kalender & Planung','Dokumenten-Pipeline','Garantie & Schutzfrist',
  'Scraper & Intelligence','Pipeline-Transitions','Saga-Events','AI & LLM'))

-- NEU v1.4: actor_type (wer erzeugt Row)
actor_type          text NOT NULL DEFAULT 'user'
  CHECK (actor_type IN ('user','system','automation','integration'))

-- NEU v1.4: source_system (technische Herkunft)
source_system       text NULL
  CHECK (source_system IS NULL OR source_system IN (
    'threecx','outlook','gmail','scraper','llm','saga-engine',
    'nightly-batch','event-worker','manual-upload','calendar-integration'))

-- NEU v1.4: is_notifiable (steuert Notification-Fanout)
is_notifiable       boolean NOT NULL DEFAULT false
```

**Migrationsregel für bestehende Rows:**
- Default `actor_type='user'` passt für alle bestehenden manuellen Einträge
- `actor_type` muss auf `'automation'` gesetzt werden für bestehende Rows mit `is_auto_loggable=true`:
 - #56 „Assessment - Ergebnisse erfasst"
 - #60 „Inactive"
 - #61 „GO Ghosting"
 - #62 „Briefing"
 - #63 „Rebriefing"
 - #64 „Schutzfrist - Status-Änderung"
- Bestehende Kategorie „System" wird umbenannt → „System / Meta" (cosmetic, verdeutlicht Abgrenzung zu System-Events)

**Index:**
```sql
CREATE INDEX idx_activity_types_actor
  ON ark.dim_activity_types(actor_type)
  WHERE actor_type <> 'user';
```

---

## 2. ALTER `dim_event_types`

**Ist-Stand (v1.3):**
```sql
event_category  text NOT NULL
  CHECK (event_category IN ('candidate','process','job','mandate',
    'call','email','document','scrape','system','match',
    'jobbasket','reminder','account'))
entity_type     text NOT NULL
event_name      text NOT NULL UNIQUE
event_description text
payload_schema_json jsonb
is_automatable  boolean NOT NULL DEFAULT true
sort_order      int
UNIQUE (event_name)
```

**Soll-Stand (v1.4) — Änderungen:**

```sql
-- v1.4: event_category CHECK erweitert (20 Werte, +7)
event_category  text NOT NULL
  CHECK (event_category IN ('candidate','process','job','mandate',
    'call','email','document','scrape','system','match',
    'jobbasket','reminder','account','assessment',
    -- NEU v1.4:
    'guarantee','protection_window','saga','ai','finance','referral'))

-- NEU v1.4: Mapping Event → Activity-Type (NULL = Event erzeugt kein fact_history-Row)
default_activity_type_id  uuid NULL REFERENCES ark.dim_activity_types(id)

-- NEU v1.4: Default actor_type für Events die fact_history schreiben
default_actor_type        text NOT NULL DEFAULT 'automation'
  CHECK (default_actor_type IN ('system','automation','integration'))

-- NEU v1.4: Default source_system für fact_history-Row
default_source_system     text NULL

-- NEU v1.4: Welche Komponente emittiert
emitter_component         text NULL

-- NEU v1.4: Steuert Schreib-Verhalten
create_history            boolean NOT NULL DEFAULT false
  -- true  = system-activity-writer schreibt fact_history (erfordert default_activity_type_id)
  -- false = Event bleibt nur in fact_event_queue / fact_event_log
```

**Indizes:**
```sql
CREATE INDEX idx_event_types_create_history
  ON ark.dim_event_types(create_history, default_activity_type_id)
  WHERE create_history = true;
```

**Constraint:**
```sql
-- create_history=true erfordert Activity-Type-Mapping
ALTER TABLE ark.dim_event_types ADD CONSTRAINT check_history_mapping
  CHECK (create_history = false OR default_activity_type_id IS NOT NULL);
```

---

## 3. ALTER `fact_event_queue.source_system` CHECK

**Ist-Stand (v1.3):**
```sql
source_system text NOT NULL
  CHECK (source_system IN ('threecx','outlook','scraper','crm','app',
    'linkedin','whatsapp','system','webhook'))
```

**Soll-Stand (v1.4):**
```sql
source_system text NOT NULL
  CHECK (source_system IN ('threecx','outlook','scraper','crm','app',
    'linkedin','whatsapp','system','webhook',
    -- NEU v1.4:
    'gmail','llm','saga-engine','nightly-batch','event-worker',
    'manual-upload','calendar-integration'))
```

---

## 4. SEEDS (Referenz)

### 4.1 `dim_activity_types` — 37 neue Rows

Vollständige Liste siehe `specs/ARK_STAMMDATEN_PATCH_v1_3_to_v1_4_ACTIVITY_TYPES.md`. Hier nur Sample-Insert als SQL-Muster:

```sql
INSERT INTO ark.dim_activity_types
  (activity_type_name, activity_category, activity_channel,
   is_auto_loggable, actor_type, source_system, is_notifiable, description)
VALUES
  ('Kalender - Interview geplant', 'Kalender & Planung', 'System',
   true, 'integration', 'calendar-integration', true,
   'Interview-Termin via Kalender-Integration eingetragen'),
  ('Reminder - Interview steht bevor', 'Kalender & Planung', 'System',
   true, 'automation', 'event-worker', true,
   'Auto-Reminder 7 Tage vor Interview-Termin'),
  -- ... (35 weitere Rows, siehe Stammdaten-Patch §Neue Sektionen)
  ('AI - Activity-Type-Vorschlag', 'AI & LLM', 'System',
   true, 'automation', 'llm', false,
   'Unklassifizierte History-Zeile erhält AI-Vorschlag');
```

### 4.2 `dim_event_types` — Seeds + Updates bestehender Rows

**Bestehende Events (Zeile 326–336 in v1.3) — Update mit `create_history=true` + Activity-Type-Mapping:**

```sql
UPDATE ark.dim_event_types SET
  create_history = true,
  default_activity_type_id = (SELECT id FROM ark.dim_activity_types
                              WHERE activity_type_name = 'Briefing'),
  default_actor_type = 'automation',
  default_source_system = 'event-worker',
  emitter_component = 'briefing-save-handler'
WHERE event_name = 'history.created'; -- Beispiel

-- analog für: candidate.stage_changed, process.stage_changed, call.received,
--              email.received, document.uploaded, etc.
```

**Neue Events (aus Spec §4.1 + §4.2) — Inserts:**

```sql
-- Events die fact_history erzeugen (create_history=true):
INSERT INTO ark.dim_event_types
  (event_name, event_category, entity_type, create_history,
   default_activity_type_id, default_actor_type, default_source_system,
   emitter_component, event_description)
VALUES
  ('interview.scheduled', 'calendar', 'process', true,
   (SELECT id FROM ark.dim_activity_types WHERE activity_type_name = 'Kalender - Interview geplant'),
   'integration', 'calendar-integration',
   'calendar-integration-adapter',
   'Interview-Termin wurde via Kalender-Integration erstellt'),
  -- ... (weitere ~25 Events mit create_history=true)
  
  -- Events die NUR in Queue/Log landen (create_history=false):
  ('saga.v1_stage_placement', 'saga', 'process', false,
   NULL, 'automation', 'saga-engine', 'saga-engine-v7',
   'Saga-Step V1 — Stage auf placement gesetzt'),
  -- ... (weitere ~9 Saga/System Events mit create_history=false)

  ('temperature.updated', 'system', 'candidate', false,
   NULL, 'system', 'nightly-batch', 'nightly-scoring-batch',
   'Temperature-Scoring durch Nightly-Batch aktualisiert');
```

---

## 5. KEINE CREATE `fact_system_log`

**Begründung:** Bestehende Infrastruktur deckt Ops-Audit vollständig ab:

| Use-Case aus Spec v1.0 | Abdeckung in v1.3 |
|-----------------------|-------------------|
| Saga V1–V6 Step-Trace | `fact_event_queue` (alle Saga-Events werden emittiert, `correlation_id` bindet sie) + `fact_event_log` (Rule-Executions mit input/output-Snapshot) |
| Temperature-Update-Trace | `fact_event_queue` mit `event_name='temperature.updated'`, `create_history=false` |
| Circuit-Breaker-Event | `dim_automation_rules.circuit_breaker_tripped` + `fact_event_queue` `circuit_breaker.tripped` |
| Dead-Letter-Events | `fact_event_queue.status='dead_lettered'` + `dead_lettered_at` + `error_message` |
| Retention-Warning | `fact_event_queue` mit `event_name='retention.warning'` |

**Admin-Debug-Tab (`/admin/system-log`) Query-Beispiel:**

```sql
-- Alle Saga-Steps einer Placement:
SELECT eq.triggered_at, eq.event_name, eq.status, el.action_taken, el.duration_ms
FROM ark.fact_event_queue eq
LEFT JOIN ark.fact_event_log el ON el.event_id = eq.id
WHERE eq.correlation_id = $1  -- saga_run.id
  AND eq.event_name LIKE 'saga.%'
ORDER BY eq.triggered_at;

-- System-Events eines Kandidaten:
SELECT eq.triggered_at, eq.event_name, et.create_history
FROM ark.fact_event_queue eq
JOIN ark.dim_event_types et ON et.id = eq.event_type_id
WHERE eq.entity_type = 'candidate' AND eq.entity_id = $1
  AND et.default_actor_type IN ('system','automation','integration')
ORDER BY eq.triggered_at DESC;
```

---

## 6. ROLLOUT-REIHENFOLGE

```
1. Migration 001_system_activity_types.sql ausführen
   a. ALTER dim_activity_types + CHECK + Indizes
   b. ALTER dim_event_types + CHECK + Indizes + Constraint
   c. ALTER fact_event_queue.source_system CHECK
2. Seed dim_activity_types (+37 Rows)
3. Seed dim_event_types (+35 Rows, Updates bestehende)
4. Backfill actor_type für 6 bestehende auto-logged Rows
5. Deploy system-activity-writer Worker (Feature-Flag off)
6. Smoke-Test in Staging: 1 Test-Event pro Domain
7. Feature-Flag on, Monitoring Dead-Letter-Rate
```

---

## 7. ROLLBACK-STRATEGIE

Alle Änderungen sind additiv (neue Spalten mit DEFAULT, erweiterte CHECKs). Rollback:

```sql
-- Schritt 1: Worker stoppen (Feature-Flag off)
-- Schritt 2: Seeds zurückrollen
DELETE FROM ark.dim_activity_types WHERE activity_type_name IN (...37 Namen);
DELETE FROM ark.dim_event_types WHERE event_name IN (...35 Namen);

-- Schritt 3: Spalten droppen
ALTER TABLE ark.dim_activity_types
  DROP COLUMN actor_type,
  DROP COLUMN source_system,
  DROP COLUMN is_notifiable;

ALTER TABLE ark.dim_event_types
  DROP COLUMN default_activity_type_id,
  DROP COLUMN default_actor_type,
  DROP COLUMN default_source_system,
  DROP COLUMN emitter_component,
  DROP COLUMN create_history;

-- Schritt 4: CHECKs zurücksetzen (DROP + recreate mit alter Werte-Liste)
-- ... (siehe migration-down-script)
```

Bestehende `fact_history`-Rows bleiben unverändert — `actor_type` ist neu mit DEFAULT `'user'`, keine Dateninterpretations-Änderung.

---

## 8. SYNC-CHECK zu Grundlagen

Nach Einarbeitung in `ARK_DATABASE_SCHEMA_v1_4.md`:

| Grundlagen-Datei | Änderung nötig |
|------------------|----------------|
| `ARK_STAMMDATEN_EXPORT_v1_3.md` → v1_4 | §14 erweitert (siehe Stammdaten-Patch) |
| `ARK_BACKEND_ARCHITECTURE_v2_5.md` → v2_6 | Sektion B: neuer Worker `system-activity-writer`; Sektion G: kein neuer Event-Scope, existing `fact_event_queue` nutzen |
| `ARK_FRONTEND_FREEZE_v1_*.md` | Timeline-Komponente: `actor_type` Badge, Filter-Chips |
| `ARK_GESAMTSYSTEM_UEBERSICHT_v1_*.md` | Changelog v1.4-Eintrag |

**Spec v1.0-Korrektur nötig:** Sektionen §2.3 (`fact_system_log` CREATE) und §5 (Worker schreibt in `fact_system_log`) müssen zu „existing `fact_event_queue` + `fact_event_log` reichen" umformuliert werden. Wird mit Spec v1.1 nach Review abgedeckt.

---

## 9. OFFENE PUNKTE — resolved v1.3 (17.04.2026)

| # | Frage | Entscheidung | Doc-Ref |
|---|-------|--------------|---------|
| D1 | „System" → „System / Meta" Umbenennung | **Ja** — additiv, Frontend-Filter-Labels bereits in Mockup-Update Phase B angepasst. Backend-Query-Grep als Pre-Deploy-Check. | Decisions §D1 |
| D2 | `emitter_component` text vs enum | **text** — flexibler bei Worker-Umbenennungen, Katalog-Pflege über Backend-Lint | Decisions §D2 |
| D3 | Bestehende ~27 Events Mapping | **Abgeschlossen** via `ARK_EVENT_TYPES_MAPPING_v1_4.md` (28 Events entschieden, 11 neue Activity-Types #111–#121) | Event-Mapping-Doc |
| D4 | `call.received`/`email.received` Actor-Override | **Default `integration`** bei 3CX/Outlook-Auto-Import, Writer-Code überschreibt auf `user` wenn `payload.source='crm_manual_entry'` | Decisions §D4 |

### Zusätzliche v1.3 Amendments für DB-Schema

**Neue Constraint für Writer-Idempotenz (ersetzt Zeitfenster-Logik):**

```sql
ALTER TABLE ark.fact_history ADD CONSTRAINT uniq_fact_history_event_id
  UNIQUE (event_id) WHERE event_id IS NOT NULL;
```

**`dim_event_types` Seed-Zusatz — Namensvereinheitlichungen (Decisions §Namensvereinheitlichungen):**

Parallel-Phase für `placement_done` → `placement_completed`:
- Beide Event-Namen seeden, identisches Mapping auf Activity-Type #99
- Nach 2-Sprint-Rename in Prod-Code → `placement_done.is_automatable=false`
- Nach 3 Monaten → Row löschen

Hart-Rename für 3 low-traffic Events:
- `system.circuit_breaker_tripped` → `circuit_breaker.tripped`
- `system.dead_letter_alert` → `dead_letter.alert`
- `jobbasket.stage_changed` → `jobbasket.stage_assigned`

Keine Backwards-Kompatibilität nötig (Events werden nur von Admin-Workern emittiert, Cutover sauber).

**`system.retention_action` Split:**

```sql
INSERT INTO ark.dim_event_types (event_name, event_category, entity_type, create_history,
  default_activity_type_id, default_actor_type, default_source_system, emitter_component) VALUES
  ('system.retention_action.candidate', 'system', 'candidate', true,
    (SELECT id FROM ark.dim_activity_types WHERE activity_type_name = 'System - Kandidat anonymisiert (GDPR)'),
    'automation', 'nightly-batch', 'gdpr-retention-batch'),
  ('system.retention_action.other', 'system', 'system', false,
    NULL, 'automation', 'nightly-batch', 'gdpr-retention-batch');
```

Conditional-Mapping sauber modelliert — kein Writer-Code-Fork nötig.

**Redis-Lock-Setting-Key (für Notification-Dedup):**

```sql
INSERT INTO ark.dim_automation_settings (key, value_text, value_bool, description) VALUES
  ('notification_dedup_enabled', NULL, true, 'v1.3: Redis-Lock für Hook+Rule Notification-Dedup aktivieren'),
  ('notification_dedup_ttl_seconds', '60', NULL, 'v1.3: TTL des Dedup-Locks in Sekunden');
```

---

---

## ADMIN-VOLLANSICHT-ADDENDUM (17.04.2026)

**Scope:** Neue Tabellen und Settings-Key-Strukturen, die durch `specs/ARK_ADMIN_VOLLANSICHT_SCHEMA_v0_1.md` eingeführt werden. Diese Änderungen gehen in v1.4 ein, zusätzlich zu System-Activity-Types.

**Basis-Spec:** `ARK_ADMIN_VOLLANSICHT_SCHEMA_v0_1.md` (Tabs 10 · Audit & Retention, Tab 1 · Feature-Flags)

### A.1 Neue Tabelle `dim_retention_change_proposals`

Vier-Augen-Prinzip für Retention-Policy-Änderungen (§13.4 Admin-Vollansicht-Spec).

```sql
CREATE TABLE ark.dim_retention_change_proposals (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  setting_key       TEXT NOT NULL,
  old_value         JSONB NOT NULL,
  new_value         JSONB NOT NULL,
  reason            TEXT NOT NULL CHECK (length(reason) >= 20),
  proposed_by       UUID NOT NULL REFERENCES ark.dim_mitarbeiter(id),
  proposed_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
  status            TEXT NOT NULL CHECK (status IN (
                      'pending_second_signature','approved','rejected','withdrawn'
                    )) DEFAULT 'pending_second_signature',
  resolved_at       TIMESTAMPTZ,
  resolved_by       UUID REFERENCES ark.dim_mitarbeiter(id),
  rejection_reason  TEXT,
  tenant_id         UUID NOT NULL
);

CREATE INDEX idx_retention_proposals_status ON ark.dim_retention_change_proposals (status, tenant_id);
CREATE INDEX idx_retention_proposals_setting ON ark.dim_retention_change_proposals (setting_key, proposed_at DESC);
```

### A.2 Neue Tabelle `fact_retention_change_approvals`

Audit-Trail der 2-Admin-Sign-offs.

```sql
CREATE TABLE ark.fact_retention_change_approvals (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  proposal_id   UUID NOT NULL REFERENCES ark.dim_retention_change_proposals(id),
  approver_id   UUID NOT NULL REFERENCES ark.dim_mitarbeiter(id),
  approved_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  action        TEXT NOT NULL CHECK (action IN ('approve','reject')),
  comment       TEXT,
  UNIQUE (proposal_id, approver_id)
);
```

**Invariante:** Proposal ist nur dann `approved`, wenn ≥ 2 distinct approver_id mit action='approve' existieren. Enforcement via Trigger oder Application-Layer.

### A.3 Neue Tabelle `fact_template_versions`

Versions-Historie für Reminder/Email/Notification-Templates (§6.3 Admin-Vollansicht).

```sql
CREATE TABLE ark.fact_template_versions (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  template_type TEXT NOT NULL CHECK (template_type IN (
                  'reminder','email','notification','document'
                )),
  template_id   UUID NOT NULL,
  version       TEXT NOT NULL,
  archived_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  archived_by   UUID REFERENCES ark.dim_mitarbeiter(id),
  snapshot      JSONB NOT NULL,
  change_reason TEXT
);

CREATE INDEX idx_template_versions_lookup ON ark.fact_template_versions (template_type, template_id, archived_at DESC);
```

**Retention:** Append-only · mindestens 5 J aufbewahren (siehe `retention_candidate_base_jahre`-Policy).

### A.4 Neue Tabelle `dim_dsg_requests`

DSG-Auskunfts-/Löschanfragen (§13.6 Admin-Vollansicht).

```sql
CREATE TABLE ark.dim_dsg_requests (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  request_type    TEXT NOT NULL CHECK (request_type IN (
                    'auskunft','loeschung','berichtigung','widerspruch','datenportabilitaet'
                  )),
  subject_person  UUID REFERENCES ark.dim_candidates(id),
  subject_email   TEXT,
  received_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
  sla_deadline    TIMESTAMPTZ NOT NULL,
  status          TEXT NOT NULL CHECK (status IN (
                    'open','in_progress','completed','rejected','escalated'
                  )) DEFAULT 'open',
  assignee        UUID REFERENCES ark.dim_mitarbeiter(id),
  notes           TEXT,
  result_document UUID,
  completed_at    TIMESTAMPTZ,
  tenant_id       UUID NOT NULL
);

CREATE INDEX idx_dsg_requests_status ON ark.dim_dsg_requests (status, sla_deadline);
CREATE INDEX idx_dsg_requests_subject ON ark.dim_dsg_requests (subject_person);
```

**SLA-Default:** `sla_deadline = received_at + interval '30 days'` (DSG Art. 8 Abs. 5).

### A.5 `dim_automation_settings` · Strukturelle Erweiterung

#### A.5.1 `fee_staffel_erfolgsbasis` · Typ-Wechsel scalar → matrix

**Alt (v1.3):**
```sql
('default_fee_pct_erfolgsbasis', '25', NULL, 'Fee% default für Erfolgsbasis')
```

**Neu (v1.4):** Value als JSONB-Matrix, key umbenannt für Klarheit.

```sql
UPDATE ark.dim_automation_settings
   SET value_jsonb = jsonb_build_array(
         jsonb_build_object('tc_from', 0,      'tc_to', 120000, 'fee_pct', 22, 'min_fee', 15000),
         jsonb_build_object('tc_from', 120000, 'tc_to', 180000, 'fee_pct', 25, 'min_fee', 25000),
         jsonb_build_object('tc_from', 180000, 'tc_to', 250000, 'fee_pct', 28, 'min_fee', 40000),
         jsonb_build_object('tc_from', 250000, 'tc_to', 400000, 'fee_pct', 30, 'min_fee', 60000),
         jsonb_build_object('tc_from', 400000, 'tc_to', NULL,   'fee_pct', 33, 'min_fee', 100000)
       ),
       key = 'fee_staffel_erfolgsbasis'
 WHERE key = 'default_fee_pct_erfolgsbasis';
```

**Pflicht:** Spalte `value_jsonb` existiert (falls nicht → ALTER TABLE). `value_text` dann für Scalar-Keys reserviert.

**Zusatz-Keys (Fee-Staffel-Optionen):**

```sql
INSERT INTO ark.dim_automation_settings (key, value_text, description) VALUES
  ('fee_staffel_calc_mode', 'flat_fee_pct_on_total', 'flat_fee_pct_on_total | progressive | min_fee_floor'),
  ('fee_staffel_tc_definition', 'base_plus_bonus_plus_signing', 'base_plus_bonus_plus_signing | base_plus_variable | base_only'),
  ('fee_staffel_rounding_chf', '100', 'Rundung in CHF: 100 | 500 | 1000 | 0');
```

#### A.5.2 `refund_staffel_erfolgsbasis` · Struktur 3-csv → 4-block-matrix

**Alt (v1.3):**
```sql
('refund_staffel_erfolgsbasis', '100,66,33', NULL, 'Refund % pro Monat')
```

**Neu (v1.4):**

```sql
UPDATE ark.dim_automation_settings
   SET value_jsonb = jsonb_build_array(
         jsonb_build_object('label','Vor Start','from_day',-9999,'to_day',-1,'refund_pct',100),
         jsonb_build_object('label','1. Monat', 'from_day',0,    'to_day',30, 'refund_pct',50),
         jsonb_build_object('label','2. Monat', 'from_day',31,   'to_day',60, 'refund_pct',25),
         jsonb_build_object('label','3. Monat', 'from_day',61,   'to_day',90, 'refund_pct',10)
       ),
       value_text = NULL
 WHERE key = 'refund_staffel_erfolgsbasis';
```

**Zusatz-Keys:**

```sql
INSERT INTO ark.dim_automation_settings (key, value_text, description) VALUES
  ('refund_typ', 'gutschrift_naechste_rechnung', 'gutschrift_naechste_rechnung | rueckueberweisung | kunde_waehlt'),
  ('refund_basis', 'netto_fee', 'netto_fee | brutto_fee'),
  ('refund_ersatzkandidat_rule', 'optional', 'optional | vorrang_ersatz | refund_zwingend');
```

### A.6 `fact_audit_log` · Action-Enum erweitern

```sql
ALTER TABLE ark.fact_audit_log
  DROP CONSTRAINT IF EXISTS fact_audit_log_action_check;

ALTER TABLE ark.fact_audit_log
  ADD CONSTRAINT fact_audit_log_action_check CHECK (action IN (
    'CREATE','UPDATE','DELETE','READ','EXPORT',
    'CONFIG','PLACEMENT','LEGAL_HOLD','RETENTION_CHANGE','DSG_REQUEST'
  ));
```

**Semantik:**
- `CONFIG` — Änderungen in Feature-Flags, Settings (Tab 1)
- `LEGAL_HOLD` — Setzen/Aufheben eines Legal-Hold (Tab 10)
- `RETENTION_CHANGE` — Retention-Policy-Änderung (nach 2-Admin-Approval)
- `DSG_REQUEST` — DSG-Anfrage-Erstellung/Bearbeitung

### A.7 `dim_legal_holds` · falls noch nicht existiert

```sql
CREATE TABLE IF NOT EXISTS ark.dim_legal_holds (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  entity_type       TEXT NOT NULL CHECK (entity_type IN (
                      'candidate','account','mandate','process','placement'
                    )),
  entity_id         UUID NOT NULL,
  reason            TEXT NOT NULL CHECK (length(reason) >= 20),
  set_by            UUID NOT NULL REFERENCES ark.dim_mitarbeiter(id),
  set_at            TIMESTAMPTZ NOT NULL DEFAULT now(),
  expires_at        TIMESTAMPTZ,
  released_by       UUID REFERENCES ark.dim_mitarbeiter(id),
  released_at       TIMESTAMPTZ,
  release_reason    TEXT,
  active            BOOLEAN GENERATED ALWAYS AS (released_at IS NULL) STORED,
  UNIQUE (entity_type, entity_id) WHERE released_at IS NULL
);

CREATE INDEX idx_legal_holds_entity ON ark.dim_legal_holds (entity_type, entity_id);
CREATE INDEX idx_legal_holds_active ON ark.dim_legal_holds (active) WHERE active = true;
```

**Blocker-Trigger auf betroffene Entity-Tables:**

```sql
CREATE OR REPLACE FUNCTION ark.block_if_legal_hold()
RETURNS TRIGGER AS $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM ark.dim_legal_holds
     WHERE entity_type = TG_TABLE_NAME::text  -- vereinfachte Darstellung
       AND entity_id = OLD.id
       AND active = true
  ) THEN
    RAISE EXCEPTION 'Entity % is under legal hold, modification blocked', OLD.id;
  END IF;
  RETURN OLD;
END;
$$ LANGUAGE plpgsql;
```

Anhängen an `dim_candidates`, `dim_mandates`, `fact_processes`, `dim_accounts`, `fact_placements` (UPDATE/DELETE).

### A.8 `dim_automation_settings` · Admin-Vollansicht-Settings (Bulk-Insert)

```sql
INSERT INTO ark.dim_automation_settings (key, value_text, description) VALUES
  -- Tab 1 neu/bestätigt
  ('ghosting_frist_tage',             '14',     'Tage ohne Antwort bis Prozess-Flag Ghosting'),
  ('stale_prozess_tage',               '21',     'Tage ohne Activity bis Pipeline-Heatmap stale markiert'),
  ('schutzfrist_warn_vorlauf_tage',    '30',     'Vorlauf für Schutzfrist-Warnung/Reminder'),
  ('refresh_frist_monate',             '18',     'Kandidat-Refresh-Schwelle in Monaten'),
  ('checkin_offsets',                  '7,30,90','Post-Placement Check-In-Offsets in Tagen (csv)'),
  ('garantiefrist_monate',             '3',      'Default-Garantiefrist'),
  ('schutzfrist_default_mt',           '12',     'Default-Schutzfrist (AGB §6)'),
  -- Ratenlimits
  ('email_rate_limit_per_user_hour',   '100',    'Max Mails pro User und Stunde'),
  ('scraper_max_concurrent',           '4',      'Max parallele Scraper-Jobs'),
  ('ai_token_budget_daily',            '500000', 'Tenant-Token-Budget pro Tag'),
  -- Feature-Flags
  ('feature_ai_briefing',              'true',   'AI-Briefing-Pipeline Phase 1 Beta'),
  ('feature_matching_v2',              'true',   'Vektor-basiertes Matching v2'),
  ('feature_dokgen_ai',                'true',   'Dok-Generator AI-Draft'),
  ('feature_exec_report_v2',           'false',  'Executive-Report v2 Layout'),
  ('feature_hr_tool',                  'false',  'Phase 2 HR-Tool · locked'),
  ('feature_provisions_v2',            'false',  'Phase 2 Provisions-Engine · locked')
ON CONFLICT (key) DO NOTHING;
```

`feature_hr_tool` und `feature_provisions_v2` zusätzlich als `locked=true` markieren (falls Lock-Spalte existiert).

### A.9 Index-Zusammenfassung Admin-Addendum

| Tabelle | Index | Zweck |
|---------|-------|-------|
| dim_retention_change_proposals | idx_retention_proposals_status | Offene Proposals-Listing |
| dim_retention_change_proposals | idx_retention_proposals_setting | Historie pro Key |
| fact_template_versions | idx_template_versions_lookup | Version-Historie pro Template |
| dim_dsg_requests | idx_dsg_requests_status | SLA-Monitor |
| dim_dsg_requests | idx_dsg_requests_subject | Kandidaten-Lookup |
| dim_legal_holds | idx_legal_holds_entity | Blocker-Check |
| dim_legal_holds | idx_legal_holds_active | Admin-Listing |

### A.10 Migrations-Reihenfolge (Admin-Addendum)

Migration-Script: `migrations/002_admin_vollansicht_addendum.sql` (neu · anzulegen)

Schritte:
1. `dim_automation_settings` · ALTER falls `value_jsonb` nicht vorhanden
2. `fact_audit_log` · CHECK-Constraint erweitern
3. CREATE `dim_legal_holds` + Trigger auf Entity-Tables
4. CREATE `dim_retention_change_proposals` + `fact_retention_change_approvals`
5. CREATE `fact_template_versions`
6. CREATE `dim_dsg_requests`
7. UPDATE Settings (Fee/Refund-Struktur-Wechsel)
8. INSERT neue Settings-Keys
9. Indexes

### A.11 Coverage-Check gegen Admin-Spec

| Admin-Spec §  | DB-Artefakt | Status |
|---------------|-------------|--------|
| §4.2 Fee-Staffel | `fee_staffel_erfolgsbasis` matrix | ✅ A.5.1 |
| §4.2 Refund-Staffel | `refund_staffel_erfolgsbasis` blocks | ✅ A.5.2 |
| §13.4 Retention-Proposals | `dim_retention_change_proposals` + `fact_retention_change_approvals` | ✅ A.1/A.2 |
| §13.5 Legal-Hold | `dim_legal_holds` | ✅ A.7 |
| §13.6 DSG-Requests | `dim_dsg_requests` | ✅ A.4 |
| §6.3 Template-Versionierung | `fact_template_versions` | ✅ A.3 |
| §15.4 Audit-Log Action-Enum | `fact_audit_log.action` CHECK | ✅ A.6 |
| §4.1-§4.4 Flag-Keys | Bulk-Insert 16 Keys | ✅ A.8 |

---

**Ende DB-Schema-Patch v1.3 → v1.4 inkl. Admin-Vollansicht-Addendum.**
