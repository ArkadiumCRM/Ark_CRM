# ARK CRM — Grundlagen-Sync-Roadmap v1.4

**Stand:** 17.04.2026
**Status:** Konsolidierter Sync-Plan für 5 Grundlagen-Dateien
**Scope:** Zwei Feature-Zyklen v1.4 (System-Activity-Types + Dashboard-Customization) + Option-B-Erweiterungen

**Zweck:** Dieses Dokument konsolidiert alle Änderungen aus den bisherigen Spec-Arbeiten in einen einzelnen Sync-Plan. Ermöglicht dem Backend-Team strukturierte Anwendung auf die 5 Grundlagen-Dateien ohne Spec-Reihenfolge durchgehen zu müssen.

---

## 1. BETROFFENE GRUNDLAGEN-DATEIEN

| Datei | Aktuelle Version | Neue Version | Änderungs-Umfang |
|-------|------------------|--------------|------------------|
| `Grundlagen MD/ARK_STAMMDATEN_EXPORT_v1_3.md` | v1.3 | **v1.5** | §14 Activity-Types (69→117) + §§neu Dashboard-Widgets + Role-Templates |
| `Grundlagen MD/ARK_DATABASE_SCHEMA_v1_3.md` | v1.3 | **v1.5** | 4 ALTER-Statements + 4 neue Tabellen + `uniq_fact_history_event_id` |
| `Grundlagen MD/ARK_BACKEND_ARCHITECTURE_v2_5.md` | v2.5 | **v2.7** | Event-Processor-Erweiterung + Dashboard-API + WebSocket-Topics |
| `Grundlagen MD/ARK_FRONTEND_FREEZE_v1_*.md` | — | **v1.2** | Grid-System · Mobile-Breakpoints · Edit-Modus · Drawer-Pattern |
| `Grundlagen MD/ARK_GESAMTSYSTEM_UEBERSICHT_v1_*.md` | — | **v1.4** | Changelog-Konsolidierung |

**Vollständige Quelldokumente (bereits erstellt):**

Feature-Zyklus **System-Activity-Types v1.4:**
- `specs/ARK_SYSTEM_ACTIVITY_TYPES_SCHEMA_v1.md` (v1.3)
- `specs/ARK_STAMMDATEN_PATCH_v1_3_to_v1_4_ACTIVITY_TYPES.md`
- `specs/ARK_DATABASE_SCHEMA_PATCH_v1_3_to_v1_4.md`
- `specs/ARK_BACKEND_ARCHITECTURE_PATCH_v2_5_to_v2_6.md`
- `specs/ARK_EVENT_TYPES_MAPPING_v1_4.md`
- `specs/ARK_SYSTEM_ACTIVITY_TYPES_DECISIONS_v1_3.md`
- `migrations/001_system_activity_types.sql`

Feature-Zyklus **Dashboard-Customization v1.4:**
- `specs/ARK_DASHBOARD_CUSTOMIZATION_SCHEMA_v1.md`
- `migrations/002_dashboard_customization.sql`

Option-B-Erweiterung (History-Drawer):
- Implementiert in 7 Mockup-Dateien (candidates + 6 weitere)

---

## 2. DATEI 1 — `ARK_STAMMDATEN_EXPORT_v1_3.md` → v1.5

### 2.1 §14 Activity-Types — Expansion 69 → 117 Rows

**Quelle:** `specs/ARK_STAMMDATEN_PATCH_v1_3_to_v1_4_ACTIVITY_TYPES.md` + Mapping-Amendment für #111–#121

**Änderungen konkret:**

| Block | Ort in §14 | Änderung |
|-------|-----------|----------|
| Intro (Scope) | Beginn §14 | +3 neue Felder-Erklärungen: `actor_type` · `source_system` · `is_notifiable` |
| Kategorien-Liste | Zeile 1539 | 11 → **18 Kategorien** |
| Kontaktberührung | unverändert | — |
| Erreicht | unverändert | — |
| Emailverkehr | nach #32 | **+1 Row #103** „Emailverkehr - Bounce" |
| Interviewprozess | unverändert | — |
| Placementprozess | nach #69 | **+1 Row #105** „Placementprozess - Referral ausgelöst" |
| Refresh | unverändert | — |
| Mandatsakquise | unverändert | — |
| Erfolgsbasis | unverändert | — |
| Assessment | nach #58 | **+1 Row #104** „Assessment - Credit verbraucht" |
| System / Meta | Zeile 1657 + Umbenennung | **System → System / Meta** · +1 Row #106 „Kandidat anonymisiert (GDPR)" |
| **NEU Kat 12** Kalender & Planung | nach System / Meta | 3 Rows #70–72 |
| **NEU Kat 13** Dokumenten-Pipeline | | 5 Rows #73–77 |
| **NEU Kat 14** Garantie & Schutzfrist | | 7 Rows #78–84 |
| **NEU Kat 15** Scraper & Intelligence | | 6 Rows #85–90 |
| **NEU Kat 16** Pipeline-Transitions | | 8 Rows #91–98 |
| **NEU Kat 17** Saga-Events | | 1 Row #99 |
| **NEU Kat 18** AI & LLM | | 3 Rows #100–102 |
| Mapping-Ergänzung | neuer Block nach Kat 18 | 11 Rows #111–121 (Merge/Reopen/OnHold/JobCancel/Mandat-Complete/Cancel/Activate/Call-unklass./Call-verpasst/Email-unklass./Assessment-abgelaufen) |
| Statistik-Block | Zeile 1671 | Update: 117/18-Kategorien/38-auto-logged/actor_type-Verteilung/source_system-Verteilung |

**Zusätzliche neue Sektionen nach §14:**

- **§14c** `dim_event_types` Event-Katalog (~61 Events in 16 Domänen)
- **§14d** Queue-only-Events (15 Events ohne fact_history-Row)

### 2.2 NEUE §§ für Dashboard-Customization

**Quelle:** `specs/ARK_DASHBOARD_CUSTOMIZATION_SCHEMA_v1.md` §4

**Neue Sektion:** `§65 Dashboard-Widgets-Registry (dim_dashboard_widgets)`

Tabelle mit 24 Widgets:
- 6 KPI + 3 Triage + 6 Alert + 3 Ops + 5 Analytics + 2 Agenda (+ bounce-alert)
- Spalten: widget_key · widget_name · category · data_scope · allowed_roles · default_size · mobile_mode · is_pinnable
- Vollständige Liste als Tabelle

**Neue Sektion:** `§66 Dashboard-Rolle-Templates (dim_dashboard_role_defaults)`

6 Rollen-Layouts als Tabellen:
- CM-Default (12 Rows)
- AM-Default (12 Rows)
- Admin-Default (18 Rows · Union ehemals Admin + Founder)
- RA-Default (7 Rows)
- BO-Default (6 Rows)
- HoD-Default (10 Rows)

### 2.3 Neue Einträge in §0 Tabellen-Index

| # | Tabellen-Name | Beschreibung | Prio |
|---|---------------|--------------|------|
| 68 | `dim_event_types` | **ERWEITERT v1.4** — +5 Spalten + create_history-Flag | P0 |
| 69 | `dim_dashboard_widgets` | **NEU v1.4** — Widget-Katalog · 24 Rows | P0 |
| 70 | `dim_dashboard_role_defaults` | **NEU v1.4** — Rolle-Default-Templates (~70 Rows) | P0 |

---

## 3. DATEI 2 — `ARK_DATABASE_SCHEMA_v1_3.md` → v1.5

### 3.1 Änderungs-Matrix

| Tabelle | Änderungs-Typ | Detail | Quelle |
|---------|--------------|--------|--------|
| `dim_activity_types` | ALTER | +3 Spalten (`actor_type`, `source_system`, `is_notifiable`) + CHECK-Erweiterung 11→18 Kategorien | `migrations/001` Schritt 1 |
| `dim_event_types` | ALTER | +5 Spalten (`default_activity_type_id`, `default_actor_type`, `default_source_system`, `emitter_component`, `create_history`) + CHECK-Erweiterung 13→20 Werte + `check_history_mapping`-Constraint | `migrations/001` Schritt 2 |
| `fact_event_queue` | ALTER | CHECK-Erweiterung `source_system` (9→16 Werte) | `migrations/001` Schritt 3 |
| `fact_history` | ALTER | +`uniq_fact_history_event_id` UNIQUE-Index (partial, WHERE event_id IS NOT NULL) | `migrations/001` Schritt 3b (v1.3 Amendment) |
| **NEU** `dim_dashboard_widgets` | CREATE | 14 Spalten + 2 Indizes | `migrations/002` Schritt 1 |
| **NEU** `dim_dashboard_role_defaults` | CREATE | 10 Spalten + UNIQUE(tenant,role,widget) + Index | `migrations/002` Schritt 2 |
| `dim_crm_users` | ALTER | +3 Spalten (`additional_roles` array · `dashboard_layout_json` jsonb · `active_dashboard_view` enum) + GIN-Index | `migrations/002` Schritt 3 |
| `dim_automation_settings` | INSERT | +9 Konfig-Keys (6 aus System-Activity-Types + 3 aus Dashboard) | `migrations/001` Schritt 9 + `migrations/002` Schritt 4 |

### 3.2 Deploy-Reihenfolge

```
1. migrations/001_system_activity_types.sql
   → dim_activity_types erweitert
   → dim_event_types erweitert
   → fact_history UNIQUE-Index
   → Activity-Type-Seed (+48 Rows #70–#121)
   → Event-Type-Seed (~45 neue Events + Updates)
   → Settings-Keys (6)

2. migrations/002_dashboard_customization.sql
   → dim_dashboard_widgets CREATE + Seed 24 Widgets
   → dim_dashboard_role_defaults CREATE + Seed ~70 Rows
   → dim_crm_users ALTER +3 Spalten
   → Settings-Keys (3)
```

### 3.3 Rollback-Strategie

Beide Migrations sind **komplett additiv** — Rollback via:

```sql
-- Migration 002 Rollback
ALTER TABLE ark.dim_crm_users
  DROP COLUMN additional_roles,
  DROP COLUMN dashboard_layout_json,
  DROP COLUMN active_dashboard_view;
DROP TABLE ark.dim_dashboard_role_defaults;
DROP TABLE ark.dim_dashboard_widgets;

-- Migration 001 Rollback
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
DROP INDEX ark.uniq_fact_history_event_id;
DELETE FROM ark.dim_activity_types WHERE activity_type_name IN (...48 Namen);
DELETE FROM ark.dim_event_types WHERE event_name IN (...~45 Namen);
```

---

## 4. DATEI 3 — `ARK_BACKEND_ARCHITECTURE_v2_5.md` → v2.7

### 4.1 Sektion A — Event-Processor-Erweiterung

**Quelle:** `specs/ARK_BACKEND_ARCHITECTURE_PATCH_v2_5_to_v2_6.md` §A

Änderung in `event-processor.worker.ts`:
- **Pre-Rule-Hook** (neu): vor Rule-Execution prüft `dim_event_types.create_history` → falls `true`, schreibt automatisch `fact_history`-Row
- Notification-Dedup via Redis-Lock (60s TTL) oder `pg_advisory_lock` als Fallback
- UNIQUE-Constraint-basierte Idempotenz statt Zeitfenster

### 4.2 Sektion B — Keine neuen Worker

Explizit: v2.6/2.7 führt **keine neuen Worker** ein. Tabelle Sektion B bleibt bei 18.

Dashboard-Widget-Daten werden via **bestehende Event-Queue-Worker** + neue API-Endpunkte geliefert (Pull + Push via WebSocket für Triage-Widgets).

### 4.3 Sektion C — Neue API-Endpunkte (13 neue)

**Dashboard (8):**
```
GET   /api/v1/me/dashboard                              -- aktives Layout
GET   /api/v1/me/dashboard?role=AM                      -- Rolle-View wechseln
PATCH /api/v1/me/dashboard-layout                       -- User-Override speichern

GET   /api/v1/dashboard/widgets/:widget_key             -- Widget-Daten fetchen
GET   /api/v1/admin/dashboard-templates                 -- alle Role-Templates
GET   /api/v1/admin/dashboard-templates/:role_key       -- einzelnes Template
PATCH /api/v1/admin/dashboard-templates/:role_key       -- Template aktualisieren

GET   /api/v1/settings/public                           -- Feature-Flag-Check
```

**Admin-Debug (5, optional aus Admin-Debug-Spec):**
```
GET /admin/event-log
GET /admin/event-log/saga/:correlation
GET /admin/event-log/dead-letter
POST /admin/event-log/event/:id/retry
POST /admin/event-log/circuit-breaker/:rule_id/reset
```

### 4.4 Sektion D — Saga-Correlation-ID Pflicht

Alle 8 bestehenden Sagas (TX1–TX8) müssen Sub-Steps mit `correlation_id = saga_run.id` emittieren (vorher teilweise).

**Backend-Team-Audit-Task** (Sprint 1 vor v2.7-Deploy).

### 4.5 Sektion E/F — unverändert

(WebSocket-Infrastruktur + Scraper-Rate-Limiting bleiben.)

### 4.6 Sektion G — Event-Scope-Registry +35 Resolver

**Quelle:** `specs/ARK_BACKEND_ARCHITECTURE_PATCH_v2_5_to_v2_6.md` §D

35 neue Resolver in `/src/events/scope-registry.ts` für neue Events aus Kat 12–18. **Backend-Lead pflegt zentral**, Feature-Teams ergänzen per PR (Decisions §B3).

### 4.7 Sektion H — Neue dim_automation_settings-Keys (9)

System-Activity-Types (6):
- `system_event_writer_enabled`
- `notification_dedup_enabled` · `notification_dedup_ttl_seconds=60`
- `system_event_retention_days=180`
- `saga_correlation_retention_days=90`
- `auto_history_source_override_enabled`

Dashboard-Customization (3):
- `dashboard_customization_enabled`
- `dashboard_widget_cache_ttl_seconds=60`
- `dashboard_max_widgets_per_view=20`

### 4.8 Sektion I — NEU: WebSocket-Topics Dashboard

```
dashboard.widget.pending-calls           Live-Update Pending-Counts
dashboard.widget.pending-emails
dashboard.widget.to-send-inbox
dashboard.widget.<any-widget-key>        für alle Widgets mit websocket_topic gesetzt
```

---

## 5. DATEI 4 — `ARK_FRONTEND_FREEZE_v1_*.md` → v1.2

### 5.1 Neue Sektionen

**§Dashboard-Grid-System:**
- 12-Spalten-CSS-Grid
- Widget-Sizes: `full` (12) · `half` (6) · `third` (4) · `quarter` (3)
- Breakpoints: Desktop ≥1280 · Tablet 768–1279 · Mobile <768
- `mobile_mode` pro Widget: `full` / `compact` / `hidden` / `link-only`

**§Edit-Modus-Pattern:**
- Toggle via „✎ anpassen"-Button oben rechts
- Inline-Controls pro Widget: Drag-Handle (⋮⋮) · Close (✕) · Resize (↔) · Config (⚙)
- Pinned-Widgets haben 🔒-Badge, nicht entfernbar
- Save-Flow: `PATCH /api/v1/me/dashboard-layout` + Success-Banner

**§Widget-Katalog-Drawer:**
- 540px slide-in (drawer-wide) — identisch zu historyDrawer-Pattern
- Search + Kategorie-Filter (6 Werte) + Rollen-Filter automatisch nach `allowed_roles`
- Pro Widget: Preview · Meta · Verwendet/Verfügbar-Status · „+ Hinzufügen" Button

**§Rolle-Toggle:**
- Oben rechts neben Edit-Button
- Popover-Dropdown mit 7 Rollen + Combined
- Persistiert in `dim_crm_users.active_dashboard_view`

**§Mobile-Adaptations:**
- Edit-Modus + Rolle-Toggle auf Mobile versteckt
- Hamburger-Nav statt Sidebar
- KPI-Strip 5→2 Kacheln
- Grid 1-Spalte · alle Widgets stacked

### 5.2 History-Drawer-Erweiterung (Option B)

**§Timeline-Drawer-Pattern:**
- `classify`-Tab bei `categorization_status='pending'`
- `history`-Tab für Kontakt-Verlauf (immer)
- `ai`-Tab enhanced: list-item Action-Items + field-grid Signale + Chips Schlagwörter
- Gilt für alle 7 Detailmasken mit Timeline (candidates · accounts · jobs · mandates · projects · assessments · groups)

### 5.3 Saga-Substeps-Drawer

**§Saga-Trace-Drawer-Pattern:**
- Öffnet bei Klick auf `process.placement_completed`-Row
- Zeigt V1–V7 als Timeline mit ms-Timings + Correlation-ID-Header
- Footer-Link „⚙️ Admin-Debug-Tab öffnen" (nur Admin-Role)
- Gleichartig für TX3 (Mandat-Kündigung) in `mandates.html`

### 5.4 CSS-Erweiterungen (editorial.css)

Neu v1.4:
- `.actor.actor-system` + 🤖-Prefix via `::before`
- 6 `.src-badge`-Varianten (saga/scraper/llm/batch/calendar/3cx)
- `.hist-system` Row-Styling (grey Left-Border)
- `.hist-pending` Row-Styling (gold Left-Border)
- Dashboard-Customization: `.widget[data-size]`, `.widget[data-mobile]`, Edit-Modus-Overlay

---

## 6. DATEI 5 — `ARK_GESAMTSYSTEM_UEBERSICHT_v1_*.md` → v1.4

### 6.1 Changelog-Eintrag v1.4

```
## v1.4 (17.04.2026)

### System-Activity-Types
- Activity-Type-Katalog 69 → 117 Rows (7 neue Kategorien #12–#18)
- dim_activity_types erweitert um actor_type · source_system · is_notifiable
- dim_event_types erweitert um create_history-Flag + default_activity_type_id
- fact_history UNIQUE-Index auf event_id (Idempotenz)
- Event-Processor-Hook: automatisches fact_history-Schreiben bei create_history=true
- Notification-Dedup via Redis-Lock (60s TTL)
- 15 Queue-only-Events (Saga-V1–V6 · temperature · matching · circuit-breaker · dead-letter · etc.)
- Namensvereinheitlichungen: placement_completed · circuit_breaker.tripped · dead_letter.alert · jobbasket.stage_assigned

### Dashboard-Customization
- Rolle-Defaults für 6 Rollen (CM · AM · Admin · RA · BO · HoD)
- User-Override persistiert in dashboard_layout_json
- Doppelrollen-Toggle (Admin + AM → Combined-View)
- 24 Widgets im Katalog (KPI · Triage · Alert · Ops · Analytics · Agenda)
- Edit-Modus mit Drag-Reorder + Resize + ✕-Entfernen + ⚙-Config
- Widget-Katalog-Drawer (540px, Rollen-gefiltert)
- Admin-Template-Editor `/admin/dashboard-templates`
- Mobile-Responsive mit 3 Breakpoints + mobile_mode pro Widget

### History-Drawer (Option B)
- Erweitert um Klassifizierungs-Tab (bei pending-Rows)
- Verlauf-Tab mit Kontakt-History
- AI-Summary-Tab auf list-item-Pattern umgebaut
- Konsistent über 7 Detailmasken

### Saga-Substeps-Drawer
- V1–V7 Placement-Saga-Trace in candidates.html + processes.html
- TX3 Mandat-Kündigungs-Saga in mandates.html (6 Substeps)
- Admin-Debug-Tab-Link für tiefere Analyse

### Mockups
- dashboard.html · 1429 Zeilen · Customization + 12 Widgets
- admin-dashboard-templates.html · Admin-Editor
- dashboard-mobile.html · 3-Breakpoint-Demo
- 9 Detailmasken mit pending-Rows + Option-B-Tabs

### Migrationen
- 001_system_activity_types.sql · 824 Zeilen
- 002_dashboard_customization.sql · 450 Zeilen

### Betroffene Grundlagen
- STAMMDATEN v1.3 → v1.5
- DATABASE_SCHEMA v1.3 → v1.5
- BACKEND_ARCH v2.5 → v2.7
- FRONTEND_FREEZE v1.x → v1.2
```

### 6.2 Sektion Feature-Flags

Neue Settings-Keys zur Kontrolle:

```
dashboard_customization_enabled         → false fällt zurück auf hardcoded Layout
system_event_writer_enabled            → false deaktiviert Auto-History-Hook
notification_dedup_enabled             → false → Duplikat-Notifications möglich
```

---

## 7. SPEC-SYNC-CHECKS (nach Apply)

### 7.1 Detailmasken-Specs (9) — Impact-Check

Folgende Detail-Masken-Specs **benötigen KEINEN Version-Bump**, da Timeline-Drawer-Änderungen über zentrale Komponente erbt:

- `ARK_KANDIDATENMASKE_SCHEMA_v1_3.md`
- `ARK_ACCOUNT_DETAILMASKE_SCHEMA_v0_3.md`
- `ARK_JOB_DETAILMASKE_SCHEMA_v0_1.md`
- `ARK_MANDAT_DETAILMASKE_SCHEMA_v0_2.md`
- `ARK_PROZESS_DETAILMASKE_SCHEMA_v0_1.md`
- `ARK_PROJEKT_DETAILMASKE_SCHEMA_v0_2.md`
- `ARK_FIRMENGRUPPE_DETAILMASKE_SCHEMA_v0_1.md`
- `ARK_ASSESSMENT_DETAILMASKE_SCHEMA_v0_2.md`
- `ARK_SCRAPER_MODUL_SCHEMA_v0_1.md`

**Grund:** Timeline-Tab erbt History-Drawer-Verhalten aus zentraler Komponente (editorial.css + layout.js).

### 7.2 Wiki-Updates

Neue Wiki-Konzept-Einträge zu erstellen:
- `wiki/concepts/dashboard-customization.md`
- `wiki/concepts/system-activity-types.md`
- `wiki/concepts/saga-substeps-drawer.md`

---

## 8. DEPLOY-REIHENFOLGE

```
Phase 1 (v1.4 Migrations)
  1. 001_system_activity_types.sql in Staging
  2. Frontend v2.6 Deploy mit system_event_writer_enabled=false (Flag-off)
  3. Smoke-Test (1 Event pro Domain)
  4. Flag-on Staging · 24h Monitoring Dead-Letter
  5. Prod-Rollout 50% → 100%

Phase 2 (Dashboard-Customization)
  6. 002_dashboard_customization.sql in Staging
  7. Frontend Dashboard-Customization Deploy mit dashboard_customization_enabled=false
  8. Smoke-Test (3 Rollen durchklicken)
  9. Flag-on · Rollen-Team-Review
  10. Prod-Rollout

Phase 3 (Grundlagen-Updates)
  11. Nach Prod-Stabilität: 5 Grundlagen-Dateien updaten auf v1.4/v1.5/v2.7
  12. Wiki-Changelog-Eintrag
```

---

## 9. OPEN TEAM-TASKS

Aus bisherigen Decisions übernommen:

1. **Backend-Team Saga-Emission-Audit** (Sprint 1 vor v2.7-Deploy): welche TX1–TX8 Sub-Steps emittieren aktuell KEINE `correlation_id`?
2. **Backend-Team Event-Scope-Registry**: 35 neue Resolver erstellen
3. **Backend-Team Redis-Lock-Infrastruktur** (oder `pg_advisory_lock` als Alternative)
4. **Backend-Team Rename-Cycle**: `placement_done` → `placement_completed` (2 Sprints Parallel-Phase)
5. **Migration-Mapping-Validation**: ~24 bestehende Events aus v1.3 mit `create_history` + `default_activity_type_id` ergänzen (in Mapping-Doc § spezifiziert)
6. **PO-Review Dashboard-Customization**: 3 Mockups (dashboard · admin-templates · mobile) durchgehen mit mind. CM + AM Vertretern

---

## 10. CHECKLIST FÜR IMPLEMENTIERUNGS-START

- [ ] PO-Approval für 2 Feature-Zyklen (System-Activity-Types + Dashboard-Customization)
- [ ] Backend-Lead Review der 2 Migration-Scripts + 4 Patch-Dokumente
- [ ] Frontend-Lead Review der 3 Mockups + Spec `ARK_DASHBOARD_CUSTOMIZATION_SCHEMA_v1.md`
- [ ] Staging-DB mit Test-Tenant + Dummy-User in allen 7 Rollen
- [ ] Redis-Instance (oder `pg_advisory_lock`-Bereitschaft)
- [ ] Feature-Flag-Monitoring-Dashboard (Grafana) vor Deploy
- [ ] Rollback-Plan dokumentiert + getestet in Staging
- [ ] 5 Grundlagen-Dateien-Backup vor v1.4/v1.5/v2.7-Updates

---

**Ende Grundlagen-Sync-Roadmap v1.4.** Nach PO/Backend-Lead/Frontend-Lead-Approval: Phase 1 Deploy starten.
