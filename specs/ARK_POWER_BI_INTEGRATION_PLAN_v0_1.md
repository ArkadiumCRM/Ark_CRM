# ARK CRM — Power-BI-Integration · Umsetzungsplan v0.1

**Stand:** 2026-04-30
**Status:** Plan-Konsolidierung · 70% aus existierenden Specs · 30% Greenfield-Gaps für Stakeholder-Review
**Quellen:**
- `Grundlagen MD/ARK_BACKEND_ARCHITECTURE_v2_8.md` §Performance-Modul TEIL R · §Worker · §Cron-Jobs (Z. 1377, 3619, 3629–3655, 4527, 4551)
- `Grundlagen MD/ARK_DATABASE_SCHEMA_v1_6.md` §Materialized Views (Z. 1577–1580) · §`dim_powerbi_view` · §`powerbi_reader` Role (Z. 3231–3243, 3254–3257)
- `Grundlagen MD/ARK_STAMMDATEN_EXPORT_v1_6.md` §97.6 (Z. 3375–3413) — 8 Default-Power-BI-Views als Seeds
- `specs/ARK_PERFORMANCE_TOOL_SCHEMA_v0_1.md` §Power-BI-Bridge · §Admin-Endpoints (Z. 369–379, 1002–1003, 1009–1010)
- `specs/ARK_PERFORMANCE_TOOL_INTERACTIONS_v0_1.md` §Power-BI-Embed (Z. 396)
- `wiki/concepts/performance-modul.md` §Phase-3.2-Roadmap (Z. 351)
- `wiki/meta/overview.md` §Power-BI-Integration (offene Frage — Stand vor 2026-04-25 Merge, jetzt 70% obsolete)

**Vorrang:** Stammdaten > dieses Plan > Frontend Freeze > Mockups
**Begleitdokumente (Folge-Sessions):**
- `ARK_POWER_BI_INTEGRATION_SCHEMA_v0_2.md` (Greenfield-Areas konkretisiert)
- `ARK_POWER_BI_INTEGRATION_INTERACTIONS_v0_1.md` (Embed-UI-Flows)

---

## 0. ZIELBILD

ARK CRM exponiert eine **konsolidierte Read-Only-Daten-Schicht** für Power-BI (Microsoft BI-Tool). Power-BI-Reports und -Dashboards visualisieren KPIs (Kandidaten-Pipeline, Mandate-Velocity, Umsatz/Provisionen, Markt/Scraper-Daten) für Management und externe Stakeholder. ARK selbst baut keine Reports im Power-BI-Service — Reports werden manuell von Peter/Nenad in Power-BI Desktop konfiguriert, Daten kommen automatisch via Materialized-Views + scheduled Refresh.

### Abgrenzung — was ist Scope, was nicht

| Scope (in dieser Spec) | Out-of-Scope (gehört woanders) |
|------------------------|---------------------------------|
| Daten-Pipeline (DB-Views → MV → Refresh) | Power-BI-Dashboard-Design, DAX-Queries, Visuals |
| `powerbi_reader`-Role, RLS, Service-Account-Auth | Power-BI-Workspace-Lizenz-Verwaltung |
| Refresh-Worker, Cron, Failure-Handling | PBIX-Source-Control + Versioning |
| Admin-API für Monitoring | Power-BI-Capacity-Sizing-Forecast |
| Bridge-API für Power-BI-Service-Account | End-User-Schulung |
| Iframe-Embed-Vorbereitung in ARK-Frontend | Power-BI-Custom-Visuals-Entwicklung |

### Primäre Konsumenten

| Rolle | Was sie tun | Surface |
|-------|-------------|---------|
| **Peter (Founder)** | KPI-Dashboards, Strategie-Reports, Cross-Modul-Analytics | Power-BI Desktop + Service |
| **Nenad (BI-Engineer)** | Report-Authoring, Dashboard-Builder, Data-Modeling | Power-BI Desktop |
| **Kunde/Stakeholder** | Read-Only-View embedded in ARK-CRM oder via Power-BI-Service-Share | Iframe in ARK Performance-Modul |
| **Backend-Worker** (kein User) | Schedule-Refresh-Jobs, Health-Monitoring | API-Worker-Service |

### Prinzipien

- **No-Direct-Operative-Access:** Power-BI sieht nur `mat_view_*` und `v_*`-Views, niemals operative Tabellen (`fact_*`, `dim_*`).
- **Tenant-Isolation:** Multi-Tenant-RLS gilt auch für Power-BI-Connections (siehe §6).
- **Refresh-Driven, nicht Realtime:** Materialized Views werden cron-basiert refresh'd (per-View konfigurierbar), keine Live-Replikation.
- **Audit-Trail:** Jeder Refresh + jeder Service-Account-API-Call landet in `fact_audit_log`.
- **Failure-Loud:** Refresh-Fehlschläge erzeugen Admin-Reminder (blocker severity).
- **Greenfield-First für Power-BI-seitige Config:** Workspace-Setup, Gateway, RLS-DAX, Embed-Token-Flow sind eigene Folge-Spec.

---

## 1. QUELLEN-INVENTAR (Was existiert bereits)

### 1.1 Datenbank-Layer

| Asset | File · Lokation | Stand |
|-------|------------------|-------|
| `powerbi_reader` Role | DB-Schema v1.6 §Roles Z. 3254–3257 | ✅ definiert · `NOLOGIN` · `SELECT ON ALL MATERIALIZED VIEWS IN SCHEMA ark_perf` |
| 8 Materialized Views | DB-Schema v1.6 Z. 1577–1580 + Stammdaten v1.6 §97.6 | ✅ Seeds: `v_powerbi_kandidaten`, `v_powerbi_prozesse`, `v_powerbi_umsatz`, `v_powerbi_markt`, `v_powerbi_team_perf`, `v_powerbi_anomalies`, `v_powerbi_action_outcomes`, `v_powerbi_capacity` |
| `dim_powerbi_view` Katalog | DB-Schema v1.6 §`dim_powerbi_view` + Performance-Schema Z. 369–379 | ✅ Spalten: `code`, `label_de`, `refresh_cron`, `is_critical`, `sql_definition`, `powerbi_dataset_url` (NULL), `last_refresh_state` enum |
| RLS-Policies | DB-Schema v1.6 Z. 3231–3243 | ✅ `tenant_id = current_setting('app.tenant_id')::uuid` auf allen `fact_*` + `dim_powerbi_view` |
| Worker-Bypass | DB-Schema v1.6 §Roles | ✅ `ark_worker_service` hat `BYPASS_RLS` für Refresh-Writes |

### 1.2 Backend-Layer

| Asset | File · Lokation | Stand |
|-------|------------------|-------|
| Refresh-Worker | Backend v2.8 §Worker Z. 3619–3655 | ✅ `powerbi-view-refresh.worker` (BullMQ) · per-View-Cron aus `dim_powerbi_view.refresh_cron` |
| Cron-Job | Backend v2.8 Z. 1377 | ✅ `refresh-powerbi` alle 4h via PgBoss · Singleton-Key verhindert Parallel-Runs |
| Refresh-SQL | Backend v2.8 Z. 3641 | ✅ `REFRESH MATERIALIZED VIEW CONCURRENTLY <name>` mit UNIQUE-Index-Voraussetzung |
| Failure-Event | Backend v2.8 §Events | ✅ `perf_powerbi_view_refresh_failed` triggert Admin-Reminder (blocker) |
| Admin-Endpoint List | Performance-Schema Z. 1002 | ✅ `GET /api/v1/performance/admin/powerbi-views` (JWT, admin) |
| Admin-Endpoint Refresh | Performance-Schema Z. 1003 | ✅ `POST /api/v1/performance/admin/powerbi-views/:code/refresh` |
| Bridge-Endpoint List | Performance-Schema Z. 1009 | ✅ `GET /api/powerbi/views` (X-API-Key, Service-Account) |
| Bridge-Endpoint Status | Performance-Schema Z. 1010 | ✅ `GET /api/powerbi/refresh-status` (X-API-Key) |
| Service-Account | Backend v2.8 Z. 4551 | ⚠ Notiz „API-Key generiert + an Nenad" — kein Rotations-Prozess spec'd |

### 1.3 Stammdaten-Layer

| Asset | File · Lokation | Stand |
|-------|------------------|-------|
| 8 Default-View-Seeds | Stammdaten v1.6 §97.6 Z. 3375–3413 | ✅ Code, Label, Refresh-Cron, Critical-Flag, SQL-Definition pro View |
| Tile-Type `iframe_powerbi` | Stammdaten v1.6 §Tile-Types Z. 3359 | ✅ Power-BI-Embed-Tile-Typ vorbereitet |
| Metric-Defs (33) | Stammdaten v1.6 §97.x | ✅ KPI-Definitionen die in Power-BI-Views referenziert werden |
| Anomaly-Thresholds (15) | Stammdaten v1.6 §97.x | ✅ Schwellwerte für Anomalie-Detection-View |

### 1.4 Frontend-Layer

| Asset | File · Lokation | Stand |
|-------|------------------|-------|
| Power-BI-Embed Tile-Type | Performance-Spec Interactions Z. 396 | ⚠ erwähnt: „Admin + on-demand Power-User-Tiles · Power-BI-JS-SDK" — kein Iframe-Flow spec'd |
| Performance-Modul Frontend | Frontend v1.13 TEIL R | ✅ Performance-Mockups bereit |

---

## 2. DATEN-ARCHITEKTUR

```
                    ┌─────────────────────────────┐
                    │  Operative Daten            │
                    │  fact_* + dim_*  (RLS aktiv)│
                    └──────────────┬──────────────┘
                                   │
                                   │ SELECT
                                   ▼
                    ┌─────────────────────────────┐
                    │  Materialized Views (8)     │
                    │  ark_perf.mat_view_*        │
                    │  · tenant_id-Spalte built-in│
                    │  · UNIQUE-Index pro View    │
                    └──────────────┬──────────────┘
                                   │
                       ┌───────────┴───────────┐
                       │                       │
       ┌───────────────▼─────────┐   ┌─────────▼─────────────┐
       │ powerbi-view-refresh    │   │ powerbi_reader Role   │
       │ .worker (BullMQ)        │   │ NOLOGIN · SELECT-only │
       │ · per-View-Cron         │   └─────────┬─────────────┘
       │ · CONCURRENT-Refresh    │             │
       │ · Failure-Event         │             │
       └─────────────────────────┘             │
                                               │ SELECT (mit Tenant-Filter)
                                               ▼
                                    ┌──────────────────────┐
                                    │  Power-BI Service    │
                                    │  (Microsoft Cloud)   │
                                    │  · Workspaces        │
                                    │  · Datasets          │
                                    │  · Reports/Dashboards│
                                    └──────────┬───────────┘
                                               │
                              ┌────────────────┴──────────────┐
                              │                               │
                  ┌───────────▼─────────┐         ┌───────────▼──────────┐
                  │ Power-BI Desktop    │         │ Iframe-Embed         │
                  │ (Nenad Authoring)   │         │ in ARK-Frontend      │
                  └─────────────────────┘         │ (Performance-Modul)  │
                                                  └──────────────────────┘
```

### 2.1 Materialized Views — 8 Seeds

| View-Code | Label DE | Refresh-Cron | Critical | Inhalt |
|-----------|----------|--------------|----------|--------|
| `v_powerbi_kandidaten` | Kandidaten-KPIs | hourly | ✅ | Aktive Kandidaten, Stages, Stalled-Counts, EQ/Motivator-Stats |
| `v_powerbi_prozesse` | Pipeline-Statistiken | hourly | ✅ | Stage-Velocity, Conversion-Rates, Stalled-Prozesse, Time-in-Stage |
| `v_powerbi_umsatz` | Revenue/Fees/Provisionen | hourly | ✅ | Realized Revenue (Placement-Fees), Pipeline-Wert, Commission-Splits |
| `v_powerbi_markt` | Scraping/Marktdaten | daily | ⚠ | Neue Stellen-Detected, Account-Activity, Vacancy-Quellen |
| `v_powerbi_team_perf` | Team-Performance | daily | ⚠ | Activity-Counts pro MA, Pipeline-Coverage, Closed-Won-Rate |
| `v_powerbi_anomalies` | Anomalie-Heatmap | daily | ⚠ | Threshold-Breaches aus `dim_anomaly_thresholds` |
| `v_powerbi_action_outcomes` | Action-Item-Wirkung | weekly | ⚠ | Closed-Loop: Action → 7d Outcome (vom Performance-Modul) |
| `v_powerbi_capacity` | Workload/Capacity | weekly | ⚠ | Workload-Score pro MA, Open-Mandate-Belastung |

**Refresh-Frequenz-Logik:**
- `is_critical=true` → Hourly-Refresh, Failure → sofortiger Admin-Reminder
- `is_critical=false` → Daily/Weekly, Failure → Reminder mit niedrigerer Severity (notice statt blocker)

### 2.2 RLS auf Views

Materialized Views erben **keine RLS** automatisch (Postgres-Limitation). Stattdessen:
- Jede MV hat eine `tenant_id`-Spalte (built-in im SQL-Definition)
- `powerbi_reader`-Role hat `BYPASSRLS=false`, sieht alle Tenants (Tenant-Isolation passiert in Power-BI via DAX-RLS, siehe §6)
- Alternative-Strategie (Phase-2): pro-Tenant-Schema `ark_perf_<tenant>` mit View-Replikaten — würde RLS-DAX-Komplexität in Power-BI eliminieren, aber pro-Tenant-MV-Pflege wäre Overhead

**Phase-1-Default:** Single-Schema `ark_perf` mit tenant_id-Spalte in jeder MV. Power-BI-RLS macht Tenant-Filter via DAX (siehe §6).

---

## 3. REFRESH-PIPELINE

### 3.1 Worker-Architektur

```typescript
// Backend-v2.8 §Worker Z. 3619–3655 (Auszug):

// Cron-Job (PgBoss)
schedule('refresh-powerbi', '0 */4 * * *', async () => {
  const views = await db.query('SELECT * FROM dim_powerbi_view WHERE active=true');
  for (const v of views) {
    if (cronMatches(v.refresh_cron, now())) {
      await queue.add('powerbi-view-refresh', { code: v.code });
    }
  }
});

// Worker
queue.process('powerbi-view-refresh', async (job) => {
  const { code } = job.data;
  const view = await db.queryOne('SELECT * FROM dim_powerbi_view WHERE code=$1', [code]);
  try {
    await db.query(`REFRESH MATERIALIZED VIEW CONCURRENTLY ark_perf.${view.mv_name}`);
    await updateState(code, 'success', new Date());
    emit('perf_powerbi_view_refreshed', { code });
  } catch (err) {
    await updateState(code, 'failed', new Date(), err.message);
    emit('perf_powerbi_view_refresh_failed', {
      code,
      error: err.message,
      severity: view.is_critical ? 'blocker' : 'notice'
    });
  }
});
```

### 3.2 Failure-Handling

| Severity | Trigger | Reaktion |
|----------|---------|----------|
| `blocker` | Critical-View Refresh-Failure | Admin-Reminder sofort, optional E-Mail an Nenad |
| `notice` | Non-Critical-View Refresh-Failure | Admin-Reminder mit 24h-Snooze, kein E-Mail |
| `warn` | Refresh-Duration > 5min | Sentry-Error, kein User-Reminder |

### 3.3 UNIQUE-Index-Pflicht

`REFRESH MATERIALIZED VIEW CONCURRENTLY` benötigt UNIQUE-Index auf MV. Pflicht:
- Jede MV hat einen `id`-PK (uuid oder composite)
- DB-Schema-Patch v1.6 enthält bereits Index-Definitionen für die 8 Seeds

### 3.4 Refresh-Status-Tracking

`dim_powerbi_view` Spalten:
- `last_refresh_started_at` timestamptz
- `last_refresh_completed_at` timestamptz
- `last_refresh_state` enum: `pending` / `running` / `success` / `failed`
- `last_refresh_error` text NULL
- `consecutive_failures` int (default 0)

Bei `consecutive_failures >= 3`: Severity-Eskalation (notice → warn → blocker).

---

## 4. API-SURFACE

### 4.1 Admin-API (JWT-Auth)

| Verb | Path | Zweck |
|------|------|-------|
| GET | `/api/v1/performance/admin/powerbi-views` | Liste aller Views + last_refresh_state |
| GET | `/api/v1/performance/admin/powerbi-views/:code` | Detail einer View (SQL-Def, History) |
| POST | `/api/v1/performance/admin/powerbi-views/:code/refresh` | Manueller Refresh (force) |
| GET | `/api/v1/performance/admin/powerbi-views/:code/audit` | Refresh-History (last 30 days) |

**UI-Surface:** Admin-Tab 1 Sub-Section „Power-BI-Views" zeigt Status-Tabelle + Refresh-Buttons.

### 4.2 Bridge-API (X-API-Key-Auth)

| Verb | Path | Zweck |
|------|------|-------|
| GET | `/api/powerbi/views` | Liste der refresh-baren Views (für Power-BI-Service-Account) |
| GET | `/api/powerbi/refresh-status` | Aggregat-Status aller Views |
| POST | `/api/powerbi/notify-refresh-needed` (greenfield) | Power-BI signalisiert „Dataset-Refresh failed, Backend bitte MV neu refresh'n" |

**Authentication:**
- API-Key im Header `X-API-Key: pbi-svc-<random-32-char>`
- Backend validiert gegen `dim_integration_tokens` mit `service='powerbi'`
- Rotation: derzeit manuell (Backend v2.8 Z. 4551), Rotations-Prozess ist Greenfield-Gap (siehe §11)

---

## 5. POWER-BI-WORKSPACE-SETUP (Greenfield)

### 5.1 Workspace-Hierarchie

**Vorschlag (Stakeholder-Review):**
```
ARK Power-BI Tenant
├── ARK-Production (Workspace)
│   ├── Datasets
│   │   ├── ARK-CRM-Operational (verbunden mit ark_perf-Views)
│   │   └── ARK-CRM-Performance (verbunden mit Performance-Modul-MVs)
│   └── Reports
│       ├── Kandidaten-Dashboard
│       ├── Pipeline-Velocity
│       ├── Umsatz-Dashboard
│       └── Markt-Heatmap
├── ARK-Staging (Workspace · separates Tenant)
└── ARK-DEV (Workspace · für Nenad-Iteration)
```

### 5.2 Capacity-SKU

**Vorschlag Phase-1:** Power-BI Pro (per-User-Lizenz, Peter + Nenad). Kein Premium-Capacity nötig solange < 5 User.
**Phase-2 (wenn Kunden Embed kriegen):** Premium-Capacity oder Embedded-A-SKU für Iframe-Embedding ohne User-Lizenzen.

### 5.3 Refresh-Frequenz-Limits (Power-BI-seitig)

- Power-BI Pro: 8 scheduled Refreshes/Tag pro Dataset
- Power-BI Premium: 48/Tag pro Dataset
- ARK-MV-Refresh ist unabhängig (passiert backend-seitig), Power-BI-Dataset-Refresh holt nur die aktuelle MV-Snapshot

---

## 6. RLS-MAPPING (Greenfield)

### 6.1 Multi-Tenant-Strategie in Power-BI

**Option A: DAX-RLS auf jedem Dataset** (Phase-1-Empfehlung)
```dax
[Tenant Filter] = LOOKUPVALUE(
    user_tenant_mapping[tenant_id],
    user_tenant_mapping[email], USERPRINCIPALNAME()
) = 'mat_view_kandidaten'[tenant_id]
```
- Pro: einfacher Setup, single Dataset pro Topic
- Con: jeder Power-BI-User braucht Eintrag in `user_tenant_mapping` (gepflegt in Stammdaten)

**Option B: Pro-Tenant-Workspace** (Phase-2-Option)
- Eigener Power-BI-Workspace pro Kunde
- Daten-Pipeline filtert tenant_id auf Backend-Ebene
- Pro: keine DAX-RLS, klare Isolation
- Con: Pflege-Overhead (M+ Workspaces), Lizenz-Kosten

### 6.2 ARK-interne Mitarbeiter (Cross-Tenant-Sicht)

Peter + Head-Roles brauchen Cross-Tenant-Sicht für Aggregat-KPIs. DAX-RLS-Lösung:
- Spezial-Rolle `super-admin` in Power-BI ohne RLS-Filter
- Mapping in `user_tenant_mapping` mit `is_super_admin=true`

---

## 7. GATEWAY + CONNECTIVITY (Greenfield)

### 7.1 Connection-Modell

ARK-DB läuft auf Supabase (Cloud-PostgreSQL). Power-BI-Service ist Cloud-only. Kein On-Prem-Gateway nötig — Power-BI verbindet direkt zu Supabase.

**Anforderungen:**
- Supabase-IP-Whitelisting für Power-BI-Service-IPs (Microsoft veröffentlicht IP-Ranges)
- TLS-Pflicht (Supabase erzwingt das default)
- Connection-String mit Service-Account-User (`powerbi_reader`-Role · separates DB-User mit `LOGIN=true`-Variante für Power-BI-Login)

### 7.2 Failover

Bei Supabase-Outage: Power-BI-Refresh failed → Power-BI-Email an Owner. Keine separate Failover-Strategie, da Performance-Modul-Reminders auf Refresh-Fehler bereits triggern (siehe §3.2).

---

## 8. EMBED + FRONTEND-INTEGRATION (Greenfield)

### 8.1 Iframe-Embed im ARK-CRM

Performance-Modul Tile-Type `iframe_powerbi` (Stammdaten v1.6 §Tile-Types Z. 3359) erlaubt Embedding einzelner Power-BI-Reports/Tiles in ARK-Dashboards.

**Token-Flow:**
1. ARK-User öffnet Performance-Modul-Tile mit `tile_type='iframe_powerbi'`
2. Frontend ruft `POST /api/v1/performance/powerbi/embed-token` (greenfield)
3. Backend ruft Power-BI REST API `POST /reports/{id}/GenerateToken` mit Service-Principal
4. Backend gibt embed-token + report-url zurück
5. Frontend rendert `<iframe src="..." />` mit Token im URL-Hash

**Token-Lifecycle:**
- Token-TTL: 60 min (Power-BI-Default)
- Auto-Refresh: Frontend re-fetch'd Token nach 50 min via WebSocket-Push oder Polling

### 8.2 Service-Principal-Auth (statt User-Login)

Power-BI-Embed-Token-Generation braucht Service-Principal (Azure-AD-App-Registration mit Power-BI-Permissions). **Greenfield-Bedarf:**
- Azure-AD-App registrieren
- Tenant-ID, Client-ID, Client-Secret in `.env` (oder Vault)
- Permissions: `Tenant.Read.All`, `Report.Read.All`, `Dataset.Read.All`

---

## 9. GOVERNANCE + CHANGE-MANAGEMENT (Greenfield)

### 9.1 View-SQL-Änderungs-Prozess

**Aktuell:** SQL-Definitions liegen in `dim_powerbi_view.sql_definition`, manuell editierbar via Admin-UI.

**Vorschlag Workflow:**
1. View-SQL-Änderung via Admin-Tab Edit-Form (mit Edit-Modus-Audit)
2. Backend führt `EXPLAIN`-Test auf neuer SQL aus, bevor Save
3. `MIGRATION` statt direktem UPDATE: neue View-Version `v_powerbi_*_v2`, Switch via `is_active`-Flag
4. Power-BI-Dataset-Connection wird auf neue MV gepointed (Nenad-Aktion)
5. Audit-Log mit `actor_id`, alte+neue SQL-Diff

**Phase-1-Vereinfachung:** Direkter Edit ohne Versions-Migration. Audit-Log + Backup-vor-Edit. Versionierung erst bei produktiver Nutzung.

### 9.2 Impact-Analyse

**Bedarf:** Wenn View-SQL geändert wird, welche Power-BI-Reports brechen?
**Greenfield-Lösung:** Manuell-Liste in `dim_powerbi_view.dependent_reports` (jsonb-Liste der bekannten Power-BI-Reports). Pflege: Nenad meldet bei jedem neuen Report.

---

## 10. MONITORING + COST (Greenfield)

### 10.1 Observability

| Metrik | Quelle | Alert-Schwelle |
|--------|--------|-----------------|
| Refresh-Duration pro View | `dim_powerbi_view.last_refresh_duration` | > 5 min: Warn, > 15 min: Critical |
| Consecutive-Failures pro View | `dim_powerbi_view.consecutive_failures` | >= 3: Severity-Eskalation |
| API-Calls Bridge-Endpoint | `fact_audit_log` mit `action='powerbi.bridge.*'` | > 1000/h: Anomaly |
| Power-BI-Service-Refresh-Failures | Power-BI-Service-API (Pull-Modus) | Greenfield: separater Worker |

### 10.2 Cost-Tracking

Power-BI Pro/Premium kostet per User/Monat. Tracking out-of-scope (Microsoft 365 Admin Center liefert das).

ARK-DB-Kosten durch Refresh: Materialized-View-Refresh ist DB-Workload — kann bei großen Tenants > 10% DB-Capacity nutzen. **Empfehlung:** Refresh-Cron in Off-Hours legen (z.B. nachts 02:00–06:00 für non-critical).

---

## 11. PHASEN-PLAN

| Phase | Scope | Output | Owner |
|-------|-------|--------|-------|
| **0 · Plan (dieses Dokument)** | Konsolidierung + Gap-Identifikation | Plan-Doku · Stakeholder-Review | Claude (Spec) + PW + Nenad |
| **1 · Greenfield-Specs** | Workspace-Setup, RLS-DAX, Embed-Token, Service-Principal-Auth, Governance | `ARK_POWER_BI_INTEGRATION_SCHEMA_v0_2.md` | PW + Nenad + Claude |
| **2 · Initial-Reports** | 4 critical Reports (Kandidaten/Prozesse/Umsatz/Markt) in Power-BI | PBIX-Files + Workspace-Setup | Nenad |
| **3 · Embed-Integration** | Iframe-Embed im Performance-Modul + Token-Flow | `ARK_POWER_BI_INTEGRATION_INTERACTIONS_v0_1.md` + Frontend-Patch | Claude (Spec) + Frontend-Lead |
| **4 · Custom-Tile-Builder** | User-defined Views via Admin-UI (Phase-3.2-Roadmap) | Spec + Mockup | Phase-3.2 |
| **5 · Cross-Tenant-Reports** | Super-Admin-Workspace, Aggregat-KPIs | Phase-2-Folge-Spec | Phase-2 |

**Phase-0-1 Aufwand:** ~2h Specs + ~1h Stakeholder-Review.
**Phase-2-3 Aufwand:** ~8h Implementation (Backend-Embed-Endpoints + Frontend-Iframe + Power-BI-Authoring).

---

## 12. OFFENE FRAGEN (für Stakeholder-Brainstorm)

| # | Frage | Vorschlag | Owner |
|---|-------|-----------|-------|
| 1 | Workspace-Modell: Single-Workspace mit DAX-RLS oder Pro-Tenant-Workspace? | Phase-1: Single + DAX-RLS · Phase-2: Pro-Tenant wenn > 10 Kunden | Peter + Nenad |
| 2 | Power-BI-Lizenz-Modell: Pro pro User oder Embedded-A-SKU? | Pro für Phase-1 (intern) · Embedded für Phase-2 (Kunde) | Peter |
| 3 | Service-Principal-Auth: Azure-AD-App ARK-CRM-PowerBI registrieren? | Ja, Azure-AD-App + Client-Secret-in-Vault | Nenad |
| 4 | Refresh-Cron-Pflege: Nenad ändert via Admin-UI oder via Migration-Patch? | Admin-UI mit Audit-Log (analog Stammdaten-Edit) | Peter |
| 5 | Iframe-Embed: nur Reports oder auch einzelne Tiles? | Beide — `tile_type='iframe_powerbi'` enthält `report_id` ODER `tile_id` | Frontend-Lead |
| 6 | Cross-Tenant-Sicht für Peter: Super-Admin-Workspace oder DAX-Bypass? | DAX-Bypass mit `is_super_admin=true` Flag in Mapping | Peter |
| 7 | API-Key-Rotation: Quartalsweise manuell oder automatisch? | Quartalsweise manuell Phase-1 · später automatisch via Worker | Peter |
| 8 | Disaster-Recovery: PBIX-Files in Git oder OneDrive-Backup? | OneDrive-Backup Phase-1 · Git Phase-2 wenn > 10 Reports | Nenad |
| 9 | Performance-Tuning: Aggregations-Tables (Pre-built Cubes) nötig? | Erst bei spürbaren Latencies (>10s Visual-Load) | Nenad |
| 10 | Mobile-Power-BI: iOS/Android-App-Support oder nur Web? | Web Phase-1 · Mobile Phase-2 falls Bedarf | Peter |

---

## 13. SYNC-PLAN

| Grundlagen-Datei | Änderung | Grund |
|------------------|----------|-------|
| `ARK_DATABASE_SCHEMA_v1_6.md` | keine in Phase-0 | Materialized Views bereits definiert |
| `ARK_BACKEND_ARCHITECTURE_v2_8.md` | +Sektion „Power-BI-Embed-Token-Endpoints" (Phase-3) | Neue Endpoints `embed-token`, `notify-refresh-needed` |
| `ARK_FRONTEND_FREEZE_v1_13.md` | +Section Performance-Modul-Iframe-Embed (Phase-3) | UI-Pattern für Power-BI-Iframe |
| `ARK_STAMMDATEN_EXPORT_v1_6.md` | keine | Tile-Type + Views bereits enthalten |
| `ARK_GESAMTSYSTEM_UEBERSICHT_v1_5.md` | Changelog-Eintrag „Power-BI-Integration v0.1 Plan" | Doku-Update |

**Wiki-Update:**
- `wiki/meta/overview.md` Power-BI-Eintrag aktualisieren: „🟢 Plan v0.1 vorhanden · Phase-1 Greenfield-Areas in Folge-Session"
- Neuer Concept-Page: `wiki/concepts/power-bi-integration.md` (Index analog `outlook-failsafe.md`)

---

## 14. FERTIGSTELLUNGS-KRITERIEN v0.1 (Phase-0)

- [x] Quellen-Inventar komplett (§1)
- [x] Daten-Architektur dokumentiert (§2)
- [x] Refresh-Pipeline beschrieben (§3)
- [x] API-Surface katalogisiert (§4)
- [x] Greenfield-Areas identifiziert (§5–10)
- [x] Phasen-Plan (§11)
- [x] 10 offene Fragen für Stakeholder-Review (§12)
- [x] Sync-Plan (§13)
- [ ] Stakeholder-Review (PW + Nenad) — pending
- [ ] Phase-1 Greenfield-Specs gestartet — pending

---

**Ende v0.1.** Begleit-Specs (Folge-Sessions): `ARK_POWER_BI_INTEGRATION_SCHEMA_v0_2.md` (Greenfield) + `ARK_POWER_BI_INTEGRATION_INTERACTIONS_v0_1.md` (Embed-UI). Review durch PO (PW) + BI-Lead (Nenad) erforderlich vor Phase-1-Start.
