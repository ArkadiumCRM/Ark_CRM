---
title: "Admin-System"
type: concept
created: 2026-04-17
updated: 2026-04-18
sources: ["specs/ARK_ADMIN_VOLLANSICHT_SCHEMA_v0_1.md", "specs/ARK_ADMIN_VOLLANSICHT_INTERACTIONS_v0_1.md", "specs/ARK_ADMIN_DEBUG_SCHEMA_v1_0.md", "specs/ARK_DATABASE_SCHEMA_PATCH_v1_3_to_v1_4.md", "specs/ARK_BACKEND_ARCHITECTURE_PATCH_v2_5_to_v2_6.md", "migrations/003_admin_vollansicht_addendum.sql"]
tags: [admin, system, config, debug, audit, retention, automation, templates]
---

# Admin-System

Die **Admin-Vollansicht** (`/admin`) ist die zentrale System-Konfigurations-Zentrale des ARK CRM. Sie bündelt alle tenant-weiten Knobs in 10 Tabs unter einer einzigen Top-Level-Navigation.

## Zweck

Single-Write-Entry-Point für Mutationen an Grundlagen-Daten zur Laufzeit. Andere UI-Bereiche (Detailseiten, Tool-Masken) lesen Konfiguration, ändern sie aber nicht. Dadurch:

- **Klar definierter Audit-Trail** — jede Konfig-Änderung führt zu `fact_audit_log`-Row mit `action=CONFIG`
- **Vier-Augen-Prinzip** möglich für kritische Änderungen (Retention-Policy)
- **Konsistente Berechtigung** — `requireRole('admin')` Middleware auf allen `/api/admin/*` Routes
- **Live-Reload** — Settings-Change-Events triggern Service-Reloads ohne Restart

## Berechtigung

| Rolle | Zugriff |
|-------|---------|
| `admin` | Vollzugriff Read-Write auf alle 10 Tabs |
| `head_of_department` | **Kein Zugriff** (Design-Entscheidung 2026-04-17) — HoD nutzt Dashboard mit erweitertem Team-Scope |
| alle anderen | HTTP 403 + Redirect `/dashboard` |

Siehe [[rbac-matrix]] §Admin-Vollansicht.

## Struktur (10 Tabs)

| # | Tab | Hauptinhalt |
|---|-----|-------------|
| 1 | **Feature-Flags** | `dim_automation_settings` · 4 Sec-Groups (Ghosting/Stale · Placement/Honorar · Feature-Previews · Ratenlimits) · Editierbare Honorar-Staffel-Matrix + 4-Block-Refund-Staffel |
| 2 | **Automation-Regeln** | `dim_automation_rules` CRUD · Rule-Builder mit 6 Trigger-Modi · Condition-Builder · Action-Chain (12 Aktionstypen) · Circuit-Breaker-Grid |
| 3 | **Reminder-Templates** | 10 [[reminders]]-Templates · Inhalt + Trigger + Eskalation + Sichtbarkeit |
| 4 | **Email** | 5 Sub-Tabs: Templates (38) · OAuth-Tokens · CodeTwo-Sync · Ignore-List · Queue/Delivery — siehe [[email-system]] |
| 5 | **Telefonie 3CX** | SLA-KPIs + Verbindungs-Config + Webhook-Log — siehe [[telefonie-3cx]] |
| 6 | **Scraper** | Job-Scheduling · Run-History · Alerts · Global-Settings — siehe [[scraper]] |
| 7 | **Notifications** | Templates pro Kanal (In-App/Push/Email-Digest) + Queue + Kanal-Health |
| 8 | **Dashboard-Templates** | Rollen-Default-Editor (User-Overrides bleiben) — verlinkt mit [[dashboard]] |
| 9 | **Debug** | 5 Sub-Tabs: Event-Log · Saga-Traces · Dead-Letter-Queue · Circuit-Breaker · Rule-Execution — siehe [[debuggability]] |
| 10 | **Audit & Retention** | `fact_audit_log` Browser · Legal-Hold · Retention-Policy (Vier-Augen) · DSG-Anfragen — siehe [[audit-log-retention]] |

## Architektur-Konzepte

### Single-Write-Entry-Point

**Regel:** Konfiguration darf nur über die Admin-Vollansicht geändert werden. Programmatische Mutationen via Backend-API gehen ebenfalls über `/api/admin/*` mit Admin-Service-Account.

Begründung:
- Audit-Lücken vermieden
- Race-Conditions zwischen UI-Edit und Direct-DB-Edit eliminiert
- Versionierung greift einheitlich

### Circuit-Breaker

Schutz vor Fehler-Kaskaden. State-Machine: **CLOSED → OPEN → HALF-OPEN → CLOSED**.

- Trip bei `> N Fehler in T min` (pro Regel/Worker konfiguriert)
- Cooldown sperrt Worker für 30 min default
- Half-Open testet 1 Probe-Run nach Cooldown
- Manual-Reset durch Admin (mit Confirm)

Pro Komponente eine eigene CB-Instanz: Email-Sequence-Engine · Reminder-Dispatcher · Matching-Worker · Scraper-Pool · 3CX-Webhook · AI-LLM.

Siehe [[automationen]] §Circuit-Breaker.

### Vier-Augen-Prinzip · Retention-Policy

Änderungen an Retention-Werten erfordern 2 Admin-Signaturen:

1. Admin-A erstellt Proposal (`POST /api/admin/retention-policies/:key/propose`)
2. System schreibt `dim_retention_change_proposals`-Row mit Status `pending_second_signature`
3. Notification an alle anderen Admins
4. Admin-B prüft + entscheidet (Approve/Reject)
5. Bei 2 distinct `approve`-Signaturen: Policy greift, `fact_retention_change_approvals` füllt sich

Rollback nicht möglich — bereits gehashte/gelöschte Daten sind unwiederbringlich.

Siehe [[audit-log-retention]] §Vier-Augen-Prinzip.

### Legal-Hold

Friert Entity ein:
- Alle UPDATE/DELETE-Operationen blockiert (DB-Trigger `block_if_legal_hold`)
- Retention-Worker überspringt die Entity (Hashing/Deletion verweigert)
- UI zeigt Badge „🔒 Legal-Hold"

Mit Pflichtfeld `reason` (≥ 20 Zeichen) und Kontext (Gerichtsverfahren, Mediation, etc.). Aufheben erfordert separaten Audit-Eintrag mit `release_reason`.

Pro Entity-Typ (Kandidat/Account/Mandat/Prozess/Placement) ein Trigger.

### DSG-Anfragen

Auskunfts-/Löschanfragen gem. DSG Art. 8 + 25:
- SLA 30 Tage ab `received_at` (DB-Default-Trigger)
- Bei Typ `loeschung`: Saga `candidate_data_erasure` (8 Steps · siehe [[audit-log-retention]])
- Legal-Hold blockiert Löschung
- Personal-Data-Hashing statt Hard-Delete (Statistik bleibt)
- Deletion-Certificate-PDF wird archiviert

### Template-Versionierung

Reminder/Email/Notification/Document-Templates sind versioniert:
- Jede Änderung inkrementiert `version` (semver-minor)
- Snapshot alter Version in `fact_template_versions` (append-only)
- Automation-Regeln pinnen auf Major-Version → Minor-Updates greifen nicht automatisch
- User-Opt-in für Upgrade

Siehe [[template-versionierung]].

### Settings-Change-Events

Zentraler Handler `setting-changed.handler.ts` reagiert auf `setting.changed`-Event:

| Key-Prefix | Reloaded |
|------------|----------|
| `ghosting_*`, `stale_*` | Pipeline-Heatmap + Auto-Flag-Workers |
| `fee_staffel_*` | Placement-Fee-Calculator |
| `refund_staffel_*` | Refund-Calculator |
| `email_rate_*` | Email-Rate-Limiter-Middleware |
| `feature_*` | Feature-Flag-Store (in-memory cache) |
| `3cx_*` | 3CX-Client-Config |
| `ai_token_budget_*` | AI-Usage-Accountant |

Reload geschieht ohne Service-Restart — Komponenten holen bei nächstem Request neuen Wert.

## Daten-Tabellen (v1.4)

Neue Tabellen durch Admin-Vollansicht (siehe Migration `003_admin_vollansicht_addendum.sql`):

- `dim_legal_holds` — aktive Holds + Historie
- `dim_retention_change_proposals` — Vier-Augen-Pending-Liste
- `fact_retention_change_approvals` — Audit der Sign-offs
- `fact_template_versions` — Versions-Historie
- `dim_dsg_requests` — DSG-Anfragen + SLA-Tracking

Erweiterte Tabellen:
- `dim_automation_settings` + `value_jsonb` Spalte (für Matrix-Werte)
- `fact_audit_log.action` CHECK +5 Werte (CONFIG · LEGAL_HOLD · RETENTION_CHANGE · DSG_REQUEST · PLACEMENT)
- `dim_event_types.event_category` CHECK +2 Werte (admin · audit)

## Worker (8 neu)

| Worker | Trigger | Zweck |
|--------|---------|-------|
| `circuit-breaker.worker.ts` | event-driven | State-Transitions CLOSED↔OPEN↔HALF-OPEN |
| `oauth-expiry.worker.ts` | daily 07:00 | Token-Ablauf-Warnung < 7 d |
| `codetwo-sync.worker.ts` | every 6 h + manual | Signatur-Templates syncen |
| `retention.worker.ts` | nightly 02:00 | Retention-Policy enforcen (respektiert Legal-Hold) |
| `dsg-sla-monitor.worker.ts` | hourly | DSG-Request-SLA prüfen |
| `legal-hold-trigger.worker.ts` | event-driven | Backup-Layer zum DB-Trigger |
| `rule-execution.worker.ts` | event-driven | Rule-Executor + Action-Chain |
| `template-version.worker.ts` | event-driven | Template-Snapshot-Erstellung |

## Sagas (3 neu)

- **`candidate_data_erasure`** (8 Steps) — DSG Art. 25 Löschungs-Workflow mit Kompensation
- **`retention_enforce`** (5 Steps) — Nightly-Hash/Delete gemäß Policy
- **`codetwo_sync`** (6 Steps) — CodeTwo-Signatur-Sync

Saga-Traces einsehbar in Admin-Tab 9 Sub-Tab Sagas. Manual-Retry und Skip-Step durch Admin möglich.

## Verwandte Konzepte

- [[debuggability]] — Event-Log + Saga-Trace + DLQ + Rule-Execution (eingebunden als Tab 9)
- [[automationen]] — Automation-Regeln + Circuit-Breaker (Tab 2)
- [[audit-log-retention]] — Audit + Legal-Hold + Retention + DSG (Tab 10)
- [[telefonie-3cx]] — 3CX-Konfiguration (Tab 5)
- [[email-system]] — Email-Templates + OAuth + CodeTwo (Tab 4)
- [[scraper]] — Scraper-Admin (Tab 6)
- [[reminders]] — Reminder-Templates (Tab 3)
- [[template-versionierung]] — Versionierungs-Strategie aller Templates
- [[rbac-matrix]] — Berechtigungen pro Tab
- [[berechtigungen]] — Allgemeine RBAC-Konzepte
- [[design-system]] — UI-Patterns (Drawer-Wide, Flag-Row, Builder, Matrix-Editor)

## Verwandte Specs

- `specs/ARK_ADMIN_VOLLANSICHT_SCHEMA_v0_1.md`
- `specs/ARK_ADMIN_VOLLANSICHT_INTERACTIONS_v0_1.md`
- `specs/ARK_ADMIN_DEBUG_SCHEMA_v1_0.md` (eingebunden als Tab 9)
- `specs/ARK_DASHBOARD_CUSTOMIZATION_SCHEMA_v1.md` (eingebunden als Tab 8)
- `specs/ARK_DATABASE_SCHEMA_PATCH_v1_3_to_v1_4.md` §A
- `specs/ARK_BACKEND_ARCHITECTURE_PATCH_v2_5_to_v2_6.md` §K

## Verwandte Mockups

- `mockups/admin.html` — Hauptansicht (10 Tabs · 8 Drawer)
- `mockups/admin-dashboard-templates.html` — Sub-Mockup für Tab 8
- `mockups/crm.html` — Sidebar-Eintrag 🔧 Admin
