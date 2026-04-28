# ARK CRM — Admin-Debug-Tab Schema v1.1

**Stand:** 28.04.2026 (v1.1 · Tab-Integration-Update — Filename bleibt `_v1_0.md` für Cross-Ref-Stabilität)
**Status:** Implementiert als Tab 9 in `mockups/Vollansichten/admin.html`
**Scope:** Admin-only Ansicht für Event-Queue-Audit, Saga-Traces, Dead-Letter-Monitoring, Rule-Execution-History

**v1.0 → v1.1 Update (28.04.2026):** Architekturentscheidung — statt Single-Page-Route `/admin/event-log` ist Debug als **Tab 9 in `admin.html`** integriert (Sub-Tabs 9-1 Event-Log, 9-2 Saga-Traces, 9-3 Dead-Letter, 9-4 Circuit-Breaker, 9-5 Rules). Begründung: kohärente Admin-Cockpit-UX, KPI-Cross-Links, kein Context-Switch. Mockup war Spec voraus — Spec wurde an Implementierungs-Realität angeglichen.

**Begleit-Dokumente:**
- `specs/ARK_SYSTEM_ACTIVITY_TYPES_SCHEMA_v1.md` v1.2 §7.3 (UI-Impact Admin-Debug-Tab)
- `specs/ARK_BACKEND_ARCHITECTURE_PATCH_v2_5_to_v2_6.md` §F (Observability)
- `specs/ARK_SYSTEM_ACTIVITY_TYPES_DECISIONS_v1_3.md` (Decisions über Datenquellen)

**Quellen:**
- `raw/Ark_CRM_v2/ARK_DATABASE_SCHEMA_v1_3.md` §`fact_event_queue` · §`fact_event_log` · §`dim_event_types` · §`dim_automation_rules`
- `raw/Ark_CRM_v2/ARK_BACKEND_ARCHITECTURE_v2_5.md` §Event-Processor Worker

**Vorrang:** Stammdaten > dieses Schema > Frontend Freeze > Mockups

---

## 0. ZIELBILD

**Tab 9 „Debug" in `admin.html`** (Route `/admin#tab=9`) — Admin-only Cockpit-Sektion mit 5 Sub-Tabs:

1. **Event-Queue-Browser** — alle Events aus `fact_event_queue` mit Filtern, Paginierung, Detail-Drawer
2. **Saga-Trace-Viewer** — gruppierte Ansicht aller Events einer `correlation_id` (z.B. Placement-Saga V1–V7)
3. **Dead-Letter-Monitoring** — Events mit `status='dead_lettered'`, Retry-Button, Error-Detail
4. **Rule-Execution-History** — Joins auf `fact_event_log` für Automation-Rule-Audits (welche Rule hat was getan, wie lange gedauert)
5. **Circuit-Breaker-Dashboard** — aktive Tripped-Rules aus `dim_automation_rules`

**Primäre Nutzer:**
- **Admin (PW):** technische Debug-Ansicht bei Fehler-Reports, System-Health-Check
- **Backend-Lead (entwickler):** Performance-Monitoring, Incident-Analyse

**Abgrenzung:**
- **Keine User-Timeline** — das ist `fact_history` (User-sichtbar). Admin-Debug zeigt `fact_event_queue` + `fact_event_log` (technisch).
- **Keine Prod-Actions** — read-only ausser „Retry Dead-Letter-Event" und „Reset Circuit-Breaker" (2 write-Operationen, beide audited).

**Sichtbarkeit:**
- Route nur bei `dim_crm_users.role = 'Admin'` aufrufbar
- Andere Rollen bekommen 404 (nicht 403 — verschleiern dass Route existiert)
- Alle Aktionen logged in `fact_audit_log` mit `actor_id` + `action='admin_debug.*'`

---

## 1. DESIGN-SYSTEM-REFERENZ

Erbt aus `ARK_KANDIDATENMASKE_SCHEMA_v1_3.md` §0. Admin-Debug-spezifische Tokens:

| Token | Wert | Verwendung |
|-------|------|-----------|
| Admin-Slate | `#1e293b` | Page-Background (signalisiert „Technik-Ansicht") |
| Mono-Font | `'SF Mono', Menlo, monospace` | Event-Namen, IDs, Payloads, Durations |
| Severity-Debug | `#64748b` grau | Badge für `severity='debug'` |
| Severity-Info | `#0ea5e9` blau | `severity='info'` (default) |
| Severity-Warn | `#f59e0b` amber | `severity='warn'` |
| Severity-Error | `#ef4444` rot | `severity='error'` |
| Severity-Critical | `#dc2626` dunkelrot + pulse | `severity='critical'` |
| Status-Pending | `#fbbf24` | `status='pending'` in Queue |
| Status-Processing | `#3b82f6` blink | `status='processing'` (aktiv verarbeitet) |
| Status-Done | `#10b981` | `status='done'` |
| Status-Failed | `#ef4444` | `status='failed'` (retry-pending) |
| Status-Dead | `#7f1d1d` | `status='dead_lettered'` |

**Layout:** Breiter als Standard-Detailmaske — Full-Width-Grid (keine Card-Container), weil viele Spalten.

---

## 2. ROUTING

Tab-Integration in `admin.html` — keine eigenen URL-Routen, stattdessen Sub-Tab-Hash-Navigation:

```
/admin#tab=9        -- Tab 9 „Debug" (Eintrittspunkt, Default-Sub-Tab 9-1)
/admin#tab=9-1      -- Sub-Tab Event-Log (Haupt-Table-View)
/admin#tab=9-2      -- Sub-Tab Saga-Traces (gruppiert nach correlation_id)
/admin#tab=9-3      -- Sub-Tab Dead-Letter-Queue
/admin#tab=9-4      -- Sub-Tab Circuit-Breaker (in §13 als optional)
/admin#tab=9-5      -- Sub-Tab Rule-Execution-History
```

Single-Event-Detail öffnet als **Drawer** (540px, Standard ARK-Pattern) über aktivem Sub-Tab.

**Route-Guard:** erbt aus `admin.html` Page-Guard — Admin-Only-Zugriff bereits auf Page-Ebene erzwungen, kein zusätzlicher Tab-Guard nötig. Non-Admin sieht admin.html nicht (404).

```typescript
// /src/pages/admin.tsx
export async function onBeforeRoute({ user }) {
  if (user.role !== 'Admin') {
    return { redirect: '/404' }
  }
}
```

---

## 3. GESAMT-LAYOUT

```
┌──────────────────────────────────────────────────────────────────────┐
│ Breadcrumb: Admin / Event-Log                              [PW] [?]  │
├──────────────────────────────────────────────────────────────────────┤
│ ▸ Tabs: [All Events] [Sagas] [Dead-Letter ③] [Circuit-Breaker] [Rules] │
├──────────────────────────────────────────────────────────────────────┤
│ KPI-Strip                                                             │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐       │
│  │ Events  │ │ Processed│ │ Failed  │ │ Dead-L. │ │ Avg Lag │       │
│  │  /h     │ │  last h  │ │  last h │ │  total  │ │  ms     │       │
│  └─────────┘ └─────────┘ └─────────┘ └─────────┘ └─────────┘       │
├──────────────────────────────────────────────────────────────────────┤
│ Filter-Bar                                                            │
│  [ 🔍 Event-Name / Entity-ID / Correlation-ID ] [ Categ ▼ ]         │
│  [ Status ▼ ] [ Severity ▼ ] [ Source-System ▼ ] [ Emitter ▼ ]      │
│  [ Zeitraum: letzte 24h ▼ ] [ Live-Tail ⏸ ] [ ↓ CSV ]              │
├──────────────────────────────────────────────────────────────────────┤
│ Events-Table (virtualisiert, 50 Rows/Page)                           │
│ Time │ Event-Name │ Entity │ Status │ Duration │ Correlation │ ⋯  │
│ 15:08:03 │ saga.v1_stage... │ process/1847 │ ● done │ 98ms │ SAGA-... │
│ 15:08:04 │ saga.v2_finance... │ process/1847 │ ● done │ 142ms │ SAGA-... │
│ ...                                                                  │
├──────────────────────────────────────────────────────────────────────┤
│ Footer: ⏱ Auto-Refresh 5s · 🔄 Reload · 245 Events geladen          │
└──────────────────────────────────────────────────────────────────────┘
```

---

## 4. TAB 1 — ALL EVENTS (Default)

### 4.1 KPI-Strip

| KPI | Quelle | Formel |
|-----|--------|--------|
| Events/h | `fact_event_queue` | `COUNT(*) WHERE triggered_at > now() - 1 hour` |
| Processed (letzte h) | `fact_event_queue` | `COUNT(*) WHERE status='done' AND processed_at > now() - 1 hour` |
| Failed (letzte h) | `fact_event_queue` | `COUNT(*) WHERE status='failed' AND processed_at > now() - 1 hour` |
| Dead-Letter total | `fact_event_queue` | `COUNT(*) WHERE status='dead_lettered'` |
| Avg Queue-Lag (ms) | `fact_event_queue` | `AVG(processed_at - triggered_at)` wo `status='done'` last hour |

### 4.2 Filter-Bar

**Search-Input (fuzzy):**
- Event-Name (e.g. `guarantee.`) — matched against `event_name`
- Entity-Ref (e.g. `candidate/uuid`, oder `candidate/J. Egger` mit Name-Lookup)
- Correlation-ID (UUID oder lesbares Format `SAGA-YYYY-MMDD-####`)

**Dropdown-Filter:**
| Feld | Optionen-Quelle |
|------|-----------------|
| Category | `dim_event_types.event_category` DISTINCT (20 Werte v1.4) |
| Status | 5 Werte: pending/processing/done/failed/dead_lettered |
| Severity | Ableitung aus `dim_event_types.emitter_component` Map + `error_message` Presence |
| Source-System | `fact_event_queue.source_system` DISTINCT |
| Emitter | `dim_event_types.emitter_component` DISTINCT |

**Zeitraum:**
- Presets: Letzte Stunde · Heute · Letzte 24h · Letzte 7 Tage · Letzte 30 Tage · Custom
- Custom via Date-Range-Picker (natives input)
- Default: Letzte 24h

**Live-Tail-Toggle:**
- WebSocket-Topic `admin.event_queue` abonniert
- Neue Events erscheinen oben in Echtzeit (max 50 in Memory)
- ⏸-Pause-Button stoppt Fluss (Queue füllt sich weiter im Backend)

**CSV-Export:**
- Aktueller Filter-Zustand → Server-Side Export (max 10'000 Rows)
- Filename: `ark-event-log-YYYY-MM-DD-HHMM.csv`

### 4.3 Events-Table

**Spalten:**

| # | Spalte | Breite | Format | Sortierbar |
|---|--------|--------|--------|:---:|
| 1 | Time | 120px | `HH:MM:SS.ms` lokal | ✓ (default DESC) |
| 2 | Event-Name | 240px | Mono, klickbar → Detail | ✓ |
| 3 | Entity | 180px | `entity_type/short-ref` als Link → Detailmaske |  |
| 4 | Status | 100px | Pill mit Farbe | ✓ |
| 5 | Duration | 80px | `X ms` / `—` wenn pending | ✓ |
| 6 | Correlation | 140px | Mono, gekürzt `SAGA-...#0038` klickbar → Saga-Trace-View |  |
| 7 | Emitter | 140px | Mono, gekürzt | ✓ |
| 8 | Actions | 60px | `⋯`-Menü |  |

**Row-Aktions-Menü `⋯`:**
- Detail öffnen (Drawer)
- Saga-Trace öffnen (nur wenn correlation_id vorhanden)
- Retry (nur bei status='failed' oder 'dead_lettered')
- Copy Event-JSON
- Copy Correlation-ID

**Row-Styling:**
- `status='failed'` → roter Links-Border
- `status='dead_lettered'` → dunkelroter Hintergrund, strikethrough
- `status='processing'` → pulsierende Blau-Umrandung
- `severity='critical'` → roter Hintergrund-Tint

**Virtualisierung:**
- TanStack-Virtual für > 500 Zeilen
- Page-Size: 50 Rows default, erweiterbar auf 100/250/500
- Infinite-Scroll optional, aber Pagination-Buttons immer sichtbar

---

## 5. TAB 2 — SAGAS (Grouped by Correlation-ID)

### 5.1 Layout

Grid-View: ein Card pro laufender/kürzlich-fertiger Saga.

**Card-Inhalt:**

```
┌─────────────────────────────────────────────────────┐
│ SAGA-2026-0417-0038 · Placement               [⚙️]  │
│ Prozess #PR-2026-1847 · J. Egger → PL Hochbau      │
│ ──────────────────────────────────────────────      │
│ ● V1 ● V2 ● V3 ● V4 ● V5 ● V6 ● V7   ✓ 7/7         │
│ ──────────────────────────────────────────────      │
│ Dauer: 1'240 ms · Gestartet: 15:08:03 · ABGESCHL. │
└─────────────────────────────────────────────────────┘
```

**Status-Dots:**
- 🟢 success · 🟡 processing · 🔴 failed · ⚪ not-reached-yet
- Klick auf Dot → Filter-Scope auf diesen Substep (öffnet Tab 1 mit entsprechendem Filter)

**Card-Actions:**
- Klick auf Card → öffnet vollständigen Saga-Trace-Drawer (ähnlich `mockups/candidates.html#sagaSubstepsDrawer`)

### 5.2 Filter-Bar Tab 2

- Saga-Type (Placement/Mandat-Kündigung/Assessment-Report/Finding-Accept/…)
- Status (alle · running · completed · failed)
- Zeitraum
- Search (Correlation-ID oder Entity)

### 5.3 Saga-Trace-Drawer (Admin-Variante, erweitert ggü. User-Version)

**Zusätzliche Sektionen vs. User-Drawer:**

1. **Raw Event-Payloads** — `payload_json` pro Substep (expandable JSON-Viewer)
2. **Rule-Executions** — `fact_event_log`-Joins pro Step: welche Rule hat ausgelöst, `input_snapshot_json` + `output_snapshot_json`, `duration_ms`
3. **Retry-History** — falls Retries stattgefunden: Timestamp + Error-Message pro Versuch
4. **DB-Impact** — Liste der DB-Operationen pro Substep (Insert/Update/Delete-Counts, falls instrumentiert)
5. **Timing-Bar** — visueller Gantt-Chart der 7 Substeps auf einer Zeitachse (hilft Bottleneck-Erkennung)

---

## 6. TAB 3 — DEAD-LETTER QUEUE

### 6.1 Scope

Events mit `fact_event_queue.status='dead_lettered'` AND `dead_lettered_at > now() - 30 days`.

### 6.2 Layout

Table mit Zusatz-Spalten:

| Spalte | Beschreibung |
|--------|--------------|
| Dead-Lettered At | Timestamp wann DLQ'd |
| Retry Count | wie oft retried vor DLQ (3 default) |
| Failure Code | `failure_code` aus Queue |
| Error Message | gekürzt 80 chars, voll im Drawer |
| Actions | [🔄 Retry] [🗑 Permanent-Delete] [⚙️ Detail] |

### 6.3 Retry-Flow

**Pre-Retry-Check:**
- Event-Type noch existiert und `is_automatable=true`?
- Entity noch existiert?
- Keine neuere Version des gleichen Events in Queue?

**Retry-Action:**
- Event-Row kopiert mit neuer ID, `status='pending'`, `retry_count=0`
- Original-Row bleibt für Audit
- `fact_audit_log`-Entry: `admin_debug.retry_dead_letter` mit `original_event_id`

**Bulk-Retry:**
- Checkbox pro Row + „Retry All Selected" Button (max 50 auf einmal)

### 6.4 Alert-Integration

Wenn Dead-Letter-Queue-Count > 5 in den letzten 15 Minuten → automatischer Slack-Alert an #ark-alerts (separater Worker `dead-letter-monitor.worker.ts`). Dashboard zeigt gelben Warn-Banner.

---

## 7. TAB 4 — CIRCUIT-BREAKER

### 7.1 Scope

Aktuelle + historische Circuit-Breaker-Trips.

### 7.2 Layout

Card-Grid pro getrippter Rule:

```
┌──────────────────────────────────────────────────┐
│ 🛑 CIRCUIT-BREAKER TRIPPED                      │
│ Rule: scraper-finding-auto-import               │
│ Getrippt: 17.04.2026 14:32:18                   │
│ Reset um: 17.04.2026 15:32:18 (in 47 min)      │
│ Trigger-Count letzte h: 127 / Max 100           │
│ [ 🔓 Manuell Reset ] [ ⚙️ Rule Detail ]         │
└──────────────────────────────────────────────────┘
```

**Manuell-Reset-Action:**
- `UPDATE dim_automation_rules SET circuit_breaker_tripped=false, circuit_breaker_reset_at=now()`
- Audit-Log-Entry
- Bestätigungs-Dialog (kurzer Modal, Ausnahme zu Drawer-Default-Regel wegen Irreversibilität)

### 7.3 Historische Trips

Sub-Tab „History" zeigt alle Trips der letzten 30 Tage als Tabelle:
- Rule-Name · Tripped-At · Reset-At · Dauer · Event-Count-während-Trip

---

## 8. TAB 5 — RULE-EXECUTIONS

### 8.1 Scope

Browser für `fact_event_log` — zeigt welche Automation-Rules in welchem Zeitraum wie oft feuerten.

### 8.2 Layout

**Top-Section:** Heatmap (Rule × Stunde der letzten 24h) — dunkler = mehr Executions.

**Main-Table:**

| Spalte | Format |
|--------|--------|
| Triggered At | Timestamp |
| Rule | `rule_key` (z.B. „candidate-auto-inactive") |
| Event | das auslösende Event |
| Action Taken | `action_type` (create_reminder/send_notification/…) |
| Duration | `duration_ms` |
| Result | „success" / „error: ..." |
| Snapshots | [📥 Input] [📤 Output] (modals / drawer) |

### 8.3 Drill-Down

Klick auf Rule → öffnet Rule-Detail-Drawer mit:
- Aktueller Config (JSON-Viewer)
- Trigger-Count-Chart (letzte 7 Tage)
- Failure-Rate
- Link zu Rule-Edit (nur bei Admin-Rolle, eigene Berechtigung)

---

## 9. DATEN-QUERIES (Performance-kritisch)

### 9.1 Haupttabelle-Query (Tab 1)

```sql
SELECT
  eq.id,
  eq.triggered_at,
  eq.event_name,
  eq.entity_type,
  eq.entity_id,
  eq.status,
  eq.correlation_id,
  (eq.processed_at - eq.triggered_at) AS duration,
  et.event_category,
  et.emitter_component,
  et.create_history
FROM ark.fact_event_queue eq
JOIN ark.dim_event_types et ON et.id = eq.event_type_id
WHERE eq.tenant_id = $1
  AND eq.triggered_at BETWEEN $2 AND $3
  AND ($4::text IS NULL OR eq.event_name ILIKE $4 || '%')
  AND ($5::text IS NULL OR et.event_category = $5)
  AND ($6::text IS NULL OR eq.status = $6)
ORDER BY eq.triggered_at DESC
LIMIT 50 OFFSET $7;
```

**Indizes nötig** (bereits teilweise in v1.3):
- `fact_event_queue(tenant_id, triggered_at DESC)` — covering für Default-View
- `fact_event_queue(event_name varchar_pattern_ops)` — für Prefix-Suche
- `fact_event_queue(correlation_id)` — für Saga-Grouping
- `fact_event_queue(entity_type, entity_id)` — für Entity-Filter

### 9.2 Saga-Grouping-Query (Tab 2)

```sql
SELECT
  correlation_id,
  MIN(triggered_at) AS saga_start,
  MAX(processed_at) AS saga_end,
  COUNT(*) AS step_count,
  COUNT(*) FILTER (WHERE status = 'done') AS done_count,
  COUNT(*) FILTER (WHERE status = 'failed') AS failed_count,
  -- Saga-Type aus erstem Event ableiten:
  (ARRAY_AGG(event_name ORDER BY triggered_at))[1] AS root_event
FROM ark.fact_event_queue
WHERE tenant_id = $1
  AND triggered_at > now() - interval '7 days'
  AND correlation_id IS NOT NULL
GROUP BY correlation_id
ORDER BY saga_start DESC
LIMIT 100;
```

### 9.3 Retention & Archivierung

- `fact_event_queue` wird nach 180 Tagen in `archive.fact_event_queue_yyyy_mm` umgezogen (Partitioning)
- `fact_event_log` analog
- Admin-Debug-Tab zeigt standardmässig nur Live-Partition (letzten 180 Tage)
- Archiv-Ansicht über expliziten Tab-Switch „📦 Archiv" (langsamer, read-only)

---

## 10. LIVE-TAIL WEBSOCKET

### 10.1 Subscription

```
WSS /ws/tenant/:tenantId/live
  topic: admin.event_queue
```

**Payload pro Event:**

```json
{
  "event_id": "uuid",
  "event_name": "guarantee.started",
  "event_category": "guarantee",
  "entity_type": "candidate",
  "entity_id": "uuid",
  "status": "done",
  "correlation_id": "uuid",
  "triggered_at": "2026-04-17T15:08:03.812Z",
  "processed_at": "2026-04-17T15:08:03.997Z",
  "duration_ms": 185,
  "emitter_component": "saga-engine-v7"
}
```

### 10.2 Rate-Limit

- Server-Side-Throttle: max 50 Events/s pro Client (Burst 100)
- Client-Side-Buffer: max 500 Rows in Memory, älteste fallen raus
- Bei Overflow: Banner „⚠️ Event-Rate zu hoch — Live-Tail pausiert, Filter verengen"

### 10.3 Reconnection

- Automatisch mit exponential backoff (1s, 2s, 5s, 15s, 60s max)
- Nach Reconnect: letzter Timestamp wird gesendet → Server liefert verpasste Events nach

---

## 11. PERFORMANCE-BUDGET

| Query | Target | Notfall-Fallback |
|-------|--------|------------------|
| Haupt-Table (50 Rows, 24h-Filter) | < 150 ms | Materialized View für letzte 24h |
| Saga-Grouping (100 Cards, 7d) | < 300 ms | Background-Worker pre-aggregiert in `fact_saga_summary` |
| KPI-Strip (5 Queries) | < 100 ms total | Redis-Cache 30s TTL |
| CSV-Export (10k Rows) | < 10 s | Async-Export mit Email-Notification wenn fertig |
| Live-Tail-Latenz | < 2 s end-to-end | — |

---

## 12. AUDIT-LOG-INTEGRATION

Alle Admin-Aktionen werden in `fact_audit_log` persistiert:

| Action-Key | Auslöser | Payload |
|-----------|----------|---------|
| `admin_debug.view_event` | Drawer-Öffnung eines Events | `event_id`, `viewed_at` |
| `admin_debug.retry_dead_letter` | Retry-Click | `original_event_id`, `new_event_id` |
| `admin_debug.reset_circuit_breaker` | Manuell-Reset | `rule_key`, `was_tripped_since` |
| `admin_debug.export_csv` | CSV-Download | `filter_params`, `row_count` |
| `admin_debug.view_payload` | Raw-JSON-Anzeige | `event_id` (Grund: Datenschutz — sensitive Payloads dürfen nicht beliebig gelesen werden ohne Trace) |

---

## 13. MOCKUPS (zu erstellen)

| Datei | Scope |
|-------|-------|
| `mockups/admin-event-log.html` | Tab 1 + 2 + 3 als Vollseite |
| `mockups/admin-event-log-saga-drawer.html` | Saga-Trace-Admin-Drawer (erweitert ggü. User-Version) |
| `mockups/admin-event-log-dead-letter.html` | Tab 3 fokussiert mit Retry-Modal |
| `mockups/admin-event-log-circuit-breaker.html` | Tab 4 |
| `mockups/admin-event-log-rules.html` | Tab 5 mit Heatmap |

Phase-F Deliverable (nicht in v1.0 hier).

---

## 14. OPEN QUESTIONS

| # | Frage | Default bis geklärt |
|---|-------|---------------------|
| Q1 | Separate Admin-App / Sub-Domain oder Teil der Haupt-App? | **Teil der Haupt-App** unter `/admin` — gleicher Build, Auth-Guard auf Route-Level |
| Q2 | `fact_event_queue` und `fact_event_log` Retention Prod? | **180 Tage** (default) — konfigurierbar über `dim_automation_settings.system_event_retention_days` |
| Q3 | Live-Tail darf Payload-Felder enthalten? | **Nein** — nur Metadata. Payload bleibt Drawer-Detail (Audit-Log-Entry bei Anzeige) |
| Q4 | CSV-Export-Max-Rows — 10k zu wenig bei Prod-Traffic? | **10k v1.0**, Scale-Up wenn Prod-Feedback das zeigt |
| Q5 | Mobile-View nötig? | **Nein v1.0** — Admin-Debug ist Desktop-only (min-width 1280px) |
| Q6 | Rule-Live-Edit direkt im Admin-Debug-Tab? | **Nein v1.0** — nur Detail-View. Rule-Edit bleibt separate Admin-Maske (out of scope) |
| Q7 | WebSocket-Fallback bei Connectivity-Problemen? | **Polling 5s** alle 5 Sekunden wenn WebSocket fehlschlägt |
| Q8 | Event-Type-Entry in Katalog aus Debug-Tab heraus deaktivieren (`is_automatable=false`)? | **Ja als Quick-Action** — Admin soll Runaway-Events sofort killen können |

---

## 15. SYNC-MATRIX zu Grundlagen

Dieser Spec ist **additiv** — keine Änderung an Grundlagen nötig:

| Grundlagen-Datei | Änderung | Grund |
|------------------|----------|-------|
| `ARK_DATABASE_SCHEMA_v1_3.md` | keine | Bestehende Tabellen reichen (fact_event_queue, fact_event_log, dim_event_types, dim_automation_rules) |
| `ARK_BACKEND_ARCHITECTURE_v2_5.md` | v2.6 +Sektion „Admin-Debug-Endpoints" | GET-Only APIs für Tab-Data (separate Spec-Ergänzung) |
| `ARK_FRONTEND_FREEZE_v1_*.md` | Tab 9 in `admin.html` (Sub-Tabs 9-1..9-5) | Admin-Tab-Inventar dokumentieren |
| `ARK_STAMMDATEN_EXPORT_v1_4.md` | keine | — |
| `ARK_GESAMTSYSTEM_UEBERSICHT_v1_*.md` | Changelog-Eintrag | „v1.4 Admin-Debug-Tab eingeführt" |

---

## 16. FERTIGSTELLUNGS-KRITERIEN v1.0

- [ ] Tab 9 in `admin.html` aktiv (Route `/admin#tab=9`), 404 auf admin.html für Non-Admin
- [ ] Tab 1 (All Events) mit Filter + Pagination + CSV-Export
- [ ] Tab 2 (Sagas) mit Correlation-Grouping + Admin-Saga-Drawer
- [ ] Tab 3 (Dead-Letter) mit Retry-Flow
- [ ] Tab 4 (Circuit-Breaker) mit Manuell-Reset
- [ ] Tab 5 (Rules) mit Heatmap
- [ ] Live-Tail WebSocket funktional (Latenz < 2s)
- [ ] Alle Admin-Aktionen in `fact_audit_log` geloggt
- [ ] Query-Performance-Tests bestanden (Target aus §11)
- [ ] 5 Mockups (§13) reviewed + umgesetzt
- [ ] Grafana-Dashboard „System-Events Health" + „Saga-Timings" (aus Backend-Arch-Patch §F) deployed

---

**Ende v1.0.** Review-Freigabe durch Admin-User (PW) + Backend-Lead erforderlich vor Implementierungs-Start.
