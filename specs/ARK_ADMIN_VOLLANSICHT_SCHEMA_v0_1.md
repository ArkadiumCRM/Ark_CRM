# ARK CRM — Admin Vollansicht Schema v0.1

**Stand:** 2026-04-17
**Status:** Erstentwurf — Review ausstehend
**Quellen:**
- `Grundlagen MD/ARK_BACKEND_ARCHITECTURE_v2_5.md` (§A Event-Typen · §B Worker · §H Settings-Keys · §Sagas · §Circuit-Breaker)
- `Grundlagen MD/ARK_DATABASE_SCHEMA_v1_3.md` (`dim_automation_rules` · `dim_automation_settings` · `dim_reminder_templates` · `dim_email_templates` · `dim_notification_templates` · `dim_webhooks` · `fact_audit_log` · `fact_scraper_runs`)
- `Grundlagen MD/ARK_STAMMDATEN_EXPORT_v1_3.md` (§56 Dokument-Templates · §64 Reminder-Templates)
- `Grundlagen MD/ARK_FRONTEND_FREEZE_v1_10.md` (Admin-Routing · Rollen · Feature-Flags)
- `specs/ARK_ADMIN_DEBUG_SCHEMA_v1_0.md` (Debug-Tab-Inhalte · Event-Log · Saga-Trace · DLQ · Circuit-Breaker · Rule-Exec)
- `specs/ARK_DASHBOARD_CUSTOMIZATION_SCHEMA_v1.md` (Widget-Library · Rolle-Defaults)
- `specs/ARK_SCRAPER_MODUL_SCHEMA_v0_1.md` (Scraper-Jobs · Alerts · Global-Settings)
- `specs/ARK_REMINDERS_VOLLANSICHT_SCHEMA_v0_1.md` (Reminder-Template-Referenz)
- `specs/ARK_EMAIL_KALENDER_DETAILMASKE_SCHEMA_v0_1.md` (Email-Template-Referenz · CodeTwo · OAuth-Tokens)
- `wiki/concepts/automationen.md` · `berechtigungen.md` · `audit-log-retention.md` · `telefonie-3cx.md` · `debuggability.md` · `template-versionierung.md`
- `mockups/admin.html` (Referenz-Mockup Stand 2026-04-17)

**Vorrang:** Stammdaten > dieses Schema > Frontend-Freeze > Mockup
**Begleitdokument:** `ARK_ADMIN_VOLLANSICHT_INTERACTIONS_v0_1.md`

---

## 0. ZIELBILD

Vollseite `/admin` — konsolidierte **System-Konfigurations-Zentrale** für die Rolle `admin`. Bündelt Feature-Flags, Automation-Regeln, Template-CRUD (Reminder/Email/Notification), Integrationen (Outlook/3CX/Scraper), Dashboard-Defaults, Debug/Observability und Audit/Retention in einer Tab-Struktur.

**Abgrenzung zu anderen System-Oberflächen:**

| Oberfläche | Scope | Zweck |
|------------|-------|-------|
| Profil-Dropdown (Sidebar-User-Click) | User-scoped (Theme · Notifications · Signatur · Shortcuts · Hilfe · Logout) | Persönliche Präferenzen — **kein eigener Sidebar-Eintrag mehr** (entschieden 18.04.2026) |
| `⌘K`-Search · Mitarbeiter-Avatare (Hover-Card) | Quick-Lookup wer-ist-wer | Team-Übersicht ohne dedizierte Maske · volle Verwaltung in HR-Tool P2 |
| `/stammdaten` | Kataloge (`dim_*`) + Dokument-Templates | Fachliche Enums |
| **`/admin`** (dieses Dokument) | **Tenant-weite System-Config · Admin-only** | **„System-Knobs & Observability"** |
| HR-Tool P2 (`/hr`) | Arbeitsverträge · Onboarding · Lifecycle · RBAC-Write · **Team-Verwaltung** | Personalverwaltung (nicht Teil dieser Spec) |

> **Sidebar-Vereinfachung 2026-04-18 (Variante A):** System-Sektion enthält nur noch **Stammdaten** + **Admin**. Settings als Profil-Dropdown (Standard-SaaS-Pattern), Team komplett in HR-Tool Phase 2. Vermeidet Doppel-Wartung bei HR-Tool-Launch.

**Einordnung:** Top-Level-Nav unter „System" (Sidebar-Icon 🔧). Admin ist kein Entity — keine Detail-Maske im engeren Sinn, sondern eine Tool-Maske mit 10 Tabs. Route: `/admin` (Default Tab 1) und `/admin/:tab` (Deep-Link).

**Primäre Nutzer:**

| Rolle | Zugriff | Nutzungs-Szenario |
|-------|---------|-------------------|
| `admin` | Vollzugriff · Read-Write | Tenant-Config, Rollout neuer Regeln, Debug bei Incidents, Audit-Review |
| andere | **kein Zugriff** (HTTP 403) | — |

> **Design-Entscheidung 2026-04-17:** `head_of_department` erhält **keinen** Admin-Zugriff (ursprünglich vorgesehen, zurückgenommen). HoD nutzt Dashboard/Team-View mit erweitertem Team-Scope. Tenant-weite Config bleibt ausschließlich bei `admin`.

**Prinzipien:**
- **Alles Change-Log-pflichtig** — jede Mutation schreibt `fact_audit_log`-Row mit `action=CONFIG|CREATE|UPDATE|DELETE`, `actor`, `diff`, `reason` (wo Pflicht)
- **Optimistic Updates bei Toggles** (Feature-Flags, Auto-Rules Pause/Activate) · Spinner bei destructive Actions (Manual CB-Reset, Retry DLQ, Legal-Hold)
- **Vier-Augen-Prinzip** für Retention-Policy-Änderungen (2 Admins, Sign-off per Banner) — siehe §10.3
- **Keine Bulk-Destructive-Actions** — Legal-Hold, DLQ-Flush, Retention-Change immer einzeln mit Bestätigungs-Drawer
- **Deep-Link-fähig**: `/admin/:tab` und `/admin/:tab/:entity` (z.B. `/admin/automation/R-1234`, `/admin/debug/saga/S-5678`)
- **Auto-Refresh** (30 s Default, abschaltbar) für Live-Panels (Event-Log, Queue, Circuit-Breaker)
- **Drawer-Default** für alle CRUD-Operationen (540 px / 760 px Wide für Builder) — Modal nur für kurze Confirm/Blocker

---

## 1. DESIGNSYSTEM-REFERENZ

Erbt aus `ARK_FRONTEND_FREEZE_v1_10.md` und `wiki/meta/mockup-baseline.md`. Modul-spezifisch:

### Modul-Farbe

Kein dedizierter Accent — Admin nutzt Standard-Accent. Status-Semantik über Farb-Tokens:

| Status | Farbe | Token |
|--------|-------|-------|
| OK / aktiv | Grün | `var(--green)` |
| Warn / degraded | Amber | `var(--amber)` |
| Error / Circuit-Breaker tripped | Rot | `var(--red)` |
| Off / deaktiviert | Muted | `var(--text-light)` |
| Info / Beta | Blau | `var(--blue)` |
| Config-Change | Amber-soft | `var(--amber-soft)` |
| Audit/Placement-Event | Gold-soft | `var(--gold-soft)` |

### Health-Dots

| Dot-Klasse | Bedeutung | Animation |
|------------|-----------|-----------|
| `.h-dot.ok` | CLOSED / OK | static |
| `.h-dot.warn` | HALF-OPEN / Degraded | static |
| `.h-dot.err` | OPEN / Tripped / Error | pulse 1.4s |
| `.h-dot.off` | Deaktiviert / Paused | static |

### Status-Badges

`.s-badge.ok` · `.s-badge.warn` · `.s-badge.err` · `.s-badge.info` · `.s-badge.gold` · `.s-badge.purple` · `.s-badge.off`

### Flag-Row-Pattern

Zentrales Config-Editor-Pattern (Feature-Flags, Telefonie-Config, Retention-Policy, Scraper-Global-Settings):

```
[Key + Beschreibung]   [Value-Input]   [Scope-Label]   [Edit-Button]
```

Grid: `1fr 160px 120px 80px` (Tab 1) oder erweitert `1fr auto 120px 80px` bei Staffel-Preview.

---

## 2. SEITEN-STRUKTUR

```
/admin
├── Header (Breadcrumb: Home / Admin)
├── Admin-Only Warn-Banner (gelb · „Nur Rolle admin")
├── Page-Banner (Titel + Meta + Legal-Hold-Toggle + Refresh)
├── KPI-Strip · 6 Cards (System-Health · klickbar → zu Tab)
├── Tabbar (10 Tabs · sticky top:0)
└── Content (pro Tab eine .tab-panel)
```

**Tabs-Übersicht:**

| # | Tab | Route | Titel |
|---|-----|-------|-------|
| 1 | Feature-Flags | `/admin/flags` | Feature-Flags & System-Settings |
| 2 | Automation-Regeln | `/admin/automation` | Automation-Regeln + Circuit-Breaker |
| 3 | Reminder-Templates | `/admin/reminder-templates` | 10 Reminder-Templates (`dim_reminder_templates`) |
| 4 | Email | `/admin/email` | Templates · OAuth · CodeTwo · Ignore-List · Queue |
| 5 | Telefonie 3CX | `/admin/telefonie` | Verbindung · Config · Webhook-Log |
| 6 | Scraper | `/admin/scraper` | Jobs · Run-History · Alerts · Global-Settings |
| 7 | Notifications | `/admin/notifications` | Templates · Queue · Kanäle |
| 8 | Dashboard-Templates | `/admin/dashboards` | Rollen-Defaults (User-Overrides bleiben) |
| 9 | Debug | `/admin/debug` | Event-Log · Sagas · DLQ · Circuit-Breaker · Rule-Exec |
| 10 | Audit & Retention | `/admin/audit` | Audit-Log · Legal-Hold · Retention · DSG-Anfragen |

---

## 3. KPI-STRIP (Oben · 6 Cards)

Live System-Health. Auto-Refresh 30 s. Jede Card klickbar → zu zugehörigem Tab.

| # | Card | Quelle | Klick-Ziel |
|---|------|--------|------------|
| 1 | Events heute | Aggregate `fact_events` count WHERE date=today | Tab 9 · Event-Log |
| 2 | Saga-Failures (7 d) | `fact_saga_traces` WHERE state=COMPENSATED | Tab 9 · Saga-Traces |
| 3 | Scraper-Alerts | `fact_scraper_alerts` WHERE status=open | Tab 6 · Alerts |
| 4 | OAuth-Tokens | `dim_user_oauth_tokens` count(active) / count(total) | Tab 4 · OAuth |
| 5 | 3CX-SLA | P95 Latency aus `fact_3cx_webhook_events` (24h) | Tab 5 |
| 6 | Automation-Runs (24 h) | `fact_rule_executions` count WHERE t>now-24h | Tab 2 |

---

## 4. TAB 1 · FEATURE-FLAGS & SYSTEM-SETTINGS

**Datenbasis:** `dim_automation_settings` (Key-Value-Store, Scope: tenant | user | feature_preview) + hart definierte Feature-Flags in `dim_feature_flags`.

**Sektionen (4 Sec-Groups):**

### 4.1 Ghosting & Stale-Timings (5 Keys)

| Key | Typ | Default | Min/Max |
|-----|-----|---------|---------|
| `ghosting_frist_tage` | int | 14 | 1–90 |
| `stale_prozess_tage` | int | 21 | 1–120 |
| `schutzfrist_warn_vorlauf_tage` | int | 30 | 7–180 |
| `refresh_frist_monate` | int | 18 | 6–36 |
| `checkin_offsets` | int[] (csv) | `7,30,90` | — |

### 4.2 Placement & Honorar (4 Keys · Staffel-Editoren)

| Key | Typ | Editor |
|-----|-----|--------|
| `fee_staffel_erfolgsbasis` | matrix[{tc_from, tc_to, fee_pct, min_fee}] | Fee-Staffel-Drawer (§13.1) |
| `garantiefrist_monate` | int | inline input |
| `refund_staffel_erfolgsbasis` | blocks[{label, from_day, to_day, refund_pct}] | Refund-Staffel-Drawer (§13.2) |
| `schutzfrist_default_mt` | int | inline input |

**Honorar-Staffel-Invariante:** Bänder lückenlos (nach `tc_from` aufsteigend) · `tc_to` eines Bandes = `tc_from` des nächsten · oberstes Band: `tc_to = null` (∞). Fee% monoton steigend empfohlen (nicht enforced).

**Refund-Staffel-Invariante:** Block 1 kann negative `from_day`/`to_day` (Vor-Start-Zeitraum) · 4 Blöcke default (Vor Start · 1. Mt · 2. Mt · 3. Mt) · refund_pct 0–100.

### 4.3 Feature-Previews (Toggles)

| Flag | Default | Status-Badge |
|------|---------|--------------|
| `feature_ai_briefing` | on | Beta |
| `feature_matching_v2` | on | Stable |
| `feature_dokgen_ai` | on | Beta |
| `feature_exec_report_v2` | off | Preview |
| `feature_hr_tool` | off (locked Phase 2) | Phase 2 |
| `feature_provisions_v2` | off (locked Phase 2) | Phase 2 |

### 4.4 Ratenlimits & Kontingente (3 Keys)

| Key | Default | Einheit |
|-----|---------|---------|
| `email_rate_limit_per_user_hour` | 100 | Mails/h |
| `scraper_max_concurrent` | 4 | Jobs |
| `ai_token_budget_daily` | 500000 | Tokens/Tag |

---

## 5. TAB 2 · AUTOMATION-REGELN

**Datenbasis:** `dim_automation_rules` (Regel-Definitionen) · `fact_rule_executions` (Run-Log) · `dim_circuit_breakers` (Health).

### 5.1 Regel-Tabelle

Spalten: Health-Dot · Name + Version · Trigger-Event · Aktion · Runs (24h) · Fehlerquote · Status · Actions.

**Status-Enum:** `active` · `paused` · `beta` · `deactivated`

### 5.2 Regel-Builder-Drawer

**Drawer-Wide** (760px). 5 Sektionen:

#### 5.2.1 Basis-Information
- Name (Pflicht, ≤ 120 Zeichen)
- Beschreibung (Markdown)
- Kategorie (Enum): `reminder_automation` · `email_automation` · `status_change` · `notification` · `webhook` · `data_sync` · `custom`
- Priorität (Enum): `low` · `medium` · `high` · `urgent`
- Status (Enum): `active` · `beta` · `deactivated`

#### 5.2.2 Trigger (6 Modi)

| Modus | Eingaben |
|-------|----------|
| **event** | Event-Type (Combobox: 62 Katalog-Events + neu tippen → Custom-Event-Registrierung) |
| **schedule** | Cron-Ausdruck (validiert) + Zeitzone + Helper-Buttons |
| **field** | Entity · Feld · Change-Typ (any/to-value/from-value) |
| **stale** | Entity · Schwelle (Wert + Einheit: Stunden/Tage/Monate) |
| **webhook** | Auto-generierte URL `https://api.../webhook/rule/{rule_id}` + HMAC-Secret |
| **manual** | Nur via API `POST /api/rules/{id}/run` oder Entity-Drawer-Button |

#### 5.2.3 Bedingungen (Condition-Builder)

- Beliebig viele Rows · AND/OR-Logik (builder-logic-toggle) · Gruppen-Nesting
- Row-Felder: **Quelle** (payload-var · entity-field · time · actor · custom-expr) × **Operator** (12 Operatoren: `=` `≠` `>` `≥` `<` `≤` `enthält` `beginnt mit` `ist leer` `in Liste` `regex` `matches-template`) × **Value**
- Fallback: Direkt-Edit-JSON-Logic (für verschachtelte Queries)

#### 5.2.4 Aktions-Kette

- Beliebig viele Schritte (sequenziell) · 12 Aktion-Typen:

| Typ | Config-Felder |
|-----|---------------|
| Reminder erstellen | Template (`dim_reminder_templates`) · Zuweisung · Zeitpunkt (vor/bei/nach Event + Offset) |
| Email senden | Template (`dim_email_templates`) · Absender · CC/BCC · Draft-vs-Direct |
| Notification senden | Template (`dim_notification_templates`) · Empfänger · Kanäle |
| Feld setzen / Status ändern | Entity · Feld · Neuer Wert |
| Activity loggen | `dim_activity_types` · Notizen-Template |
| Webhook aufrufen | URL · Method · Headers · Body-Template |
| Wert berechnen | Expression · Ziel-Variable |
| Delay / Wait | Dauer (min/h/d) |
| Assessment bestellen | Typ (Phase 1: SCHEELEN-Subset) · Empfänger |
| Dokument generieren | `dim_document_templates` · Ziel-Entity |
| Andere Regel triggern | Rule-ID + Payload-Mapping |
| Custom JS (Sandbox) | Code-Editor · Max 1000 Zeilen · Whitelist-APIs |

**On-Error (pro Regel)**: `compensate` (Saga-Rollback default) · `ignore` · `retry` (3× exp-backoff) · `escalate` (Admin-Notification).

#### 5.2.5 Circuit-Breaker-Config

| Feld | Default | Beschreibung |
|------|---------|--------------|
| fehler_schwelle | 10 | Anzahl Fehler |
| zeitfenster_min | 5 | In N Minuten |
| cooldown_min | 30 | Pause nach Trip |

Bei Trip: Regel pausiert, Notification an Admin, nach Cooldown 1 Probe-Run (HALF-OPEN) → OK = CLOSED, Fehler = OPEN + neuer Cooldown.

#### 5.2.6 Test-Run (Dry-Run)

- „Mit letztem Live-Event testen" (zieht letztes matching Event)
- „Mit Custom-Payload testen" (JSON-Editor)
- „Preview JSON-Logic" (zeigt compiliertes JSON-Logic)

Test-Ergebnis: Anzahl Matches · würde-erstellen-Preview (Reminders/Notifications/Emails) · OK/Fehler-Status.

### 5.3 Circuit-Breaker-Grid (unter Tabelle)

Card pro aktiver CB. Zeigt: Name · State (CLOSED/HALF-OPEN/OPEN) · Trip-Schwelle · Runs · Fehler · Letzter Reset · Manual-Reset-Button (OPEN).

---

## 6. TAB 3 · REMINDER-TEMPLATES

**Datenbasis:** `dim_reminder_templates` (10 Stammdaten-Vorlagen aus `ARK_STAMMDATEN_EXPORT_v1_3.md §64`).

### 6.1 Template-Grid

Cards, 3 Spalten. Pro Card:
- Name + Auto/Manuell-Badge
- Body-Snippet (gekürzt ≤ 160 Zeichen)
- Trigger + Priorität + Verwendungs-Count (30 d)

### 6.2 Template-Drawer (760px)

**Sektionen:**

#### 6.2.1 Basis
- Name · Typ (Reminder-Kategorie Enum · 10 Typen aus STAMMDATEN) · Icon (Icon-Picker 10 Symbole)

#### 6.2.2 Inhalt
- Titel-Template (≤ 200 Zeichen · Handlebars-Syntax `{{var}}`)
- Beschreibung-Template (Markdown, unbegrenzt)
- Variable-Chips (Klick einfügen): kontext-abhängige Liste aus Trigger-Event-Payload

#### 6.2.3 Trigger & Timing
- Quelle: `auto` · `manual` · `both`
- Trigger-Event (nur bei auto): Event-Katalog-Combobox
- Zeitpunkt: `before` · `at` · `after` · Offset (Wert + Einheit)
- Eskalation: `none` · `prio_up_24h` · `notify_hod_24h` · `auto_escalate_team_48h`

#### 6.2.4 Zuweisung & Priorität
- Default-Zuweisung: `process_am` · `researcher` · `backoffice` · `fixed_user` · `creator`
- Priorität (Prio-Seg): low/medium/high/urgent
- Entity-Kontext: Kandidat · Prozess · Account · Mandat · kontextfrei
- Wiederholung: einmalig · täglich · wöchentlich · monatlich

#### 6.2.5 Sichtbarkeit
Chips (multi-select): „Verwendbar in Automation-Regel" · „Manuell aus Kandidat-Drawer" · „Manuell aus Prozess-Drawer" · „Nur Admin-aktivierbar"

### 6.3 Template-Versionierung

Jede Änderung inkrementiert `version` (semver-minor). Alte Versionen in `fact_template_versions` archiviert. Referenzen von Automation-Regeln auf Major-Version gepinnt (siehe `wiki/concepts/template-versionierung.md`).

---

## 7. TAB 4 · EMAIL

**Datenbasis:** `dim_email_templates` (38 Templates + 4 Automation-Linked) · `dim_user_oauth_tokens` · `dim_codetwo_signatures` · `dim_email_ignore_rules` · `fact_email_deliveries`.

### 7.1 Sub-Tabs (5)

| # | Sub-Tab | Inhalt |
|---|---------|--------|
| 4.1 | Templates | Table mit 38 Email-Templates · Filter Kategorie/Sprache |
| 4.2 | OAuth-Tokens | Je User 1 Row · Status · Scopes · Refresh-Datum |
| 4.3 | CodeTwo-Signaturen | Sync-Status + aktive Signatur-Templates |
| 4.4 | Ignore-List | Regel-Patterns (42 default) zur Filterung eingehender Mails |
| 4.5 | Queue & Delivery | 24h-Queue-Stats + Bounce-Log 7d |

### 7.2 Email-Template-Drawer (760px)

Sektionen:

#### 7.2.1 Basis
- Name (intern) · Kategorie (9 Enums: Kontakt-Erstansprache · Interview-Einladung · Expose · Offer & Contract · Post-Placement · Rejection · Schutzfrist-Claim · Newsletter · Custom) · Sprache (DE/EN/FR)

#### 7.2.2 Betreff & Body
- Toolbar-Bar (Bold · Italic · Underline · Liste · Link · Signatur · HTML-Toggle · Preview)
- Subject-Input (1 Zeile, bold)
- Body-Textarea (min-height 200px, Handlebars-Syntax)
- Variable-Chips unterhalb (+ Custom-Variable-Option)

#### 7.2.3 Automation-Verknüpfung
- Auto-Versand-Trigger (Chips: `longlist_approved` · `candidate_shortlisted` · custom)
- Freigabe-Flow (`instant` · `am_approval` · `hod_approval_if_value_gt_X` · `draft_only`)
- Draft-Modus (`always_draft` · `direct_if_vars_filled` · `never_direct`)

#### 7.2.4 Anhänge & Beilagen
Chips: Kandidaten-CV (ARK-Format) · Kandidaten-Dossier (PDF) · Assessment-Report · Referenzen · Custom

#### 7.2.5 Tracking
- Open-Tracking (Pixel on/off) · Click-Tracking on/off · Read-Receipt (anfordern Outlook on/off)

### 7.3 OAuth-Token-Management

Shared-Mailbox-Ansatz verworfen (2026-04-17) — individuelle User-Tokens via Microsoft Graph.

Row pro User: Mitarbeiter · Outlook-Account · Status (active/expiring/expired) · Scopes (Mail.ReadWrite · Calendars.ReadWrite · Contacts.Read) · Verbunden-seit · Nächster-Refresh · Re-Auth-Button.

**Auto-Warn:** Token läuft in < 7 d ab → Notification an User + Admin (Template: `oauth_token_expiring`).

### 7.4 CodeTwo-Sync

Externes System für zentrale Outlook-Signaturen. Admin-UI zeigt nur:
- Sync-Status (OK / Fail)
- Letzter Sync (Timestamp)
- Aktive Signatur-Templates (Liste)
- Link zu CodeTwo-Admin (extern)

Edit der Templates erfolgt in CodeTwo, nicht im CRM.

### 7.5 Ignore-List

42 Default-Regeln (Linkedin-Notifications, Newsletter, OOO-Auto-Replies, etc.). 5 Regel-Typen: `domain` · `domain_pattern` · `sender_pattern` · `subject_regex` · `header_list_unsubscribe`.

Pro Regel: Pattern · Typ · Grund · Blockiert-Count (30 d) · Scope.

### 7.6 Queue & Delivery

4-Row-Queue-Meter: Sofort versendet · Im Queue (pending) · Retry (soft-fail) · Dead-Letter (hard-fail).

Bounce-Log 7d: Empfänger · Bounce-Typ (Hard/Soft/Full-Inbox) · Datum.

---

## 8. TAB 5 · TELEFONIE 3CX

**Datenbasis:** `dim_3cx_config` · `fact_3cx_webhook_events` · `fact_call_transcripts`.

### 8.1 SLA-KPI-Strip (3 Cards)

| KPI | Ziel | Quelle |
|-----|------|--------|
| Call → History (P95) | < 30 s | `fact_3cx_webhook_events` |
| Transcript → Summary (P95) | < 3 min | `fact_call_transcripts` |
| Calls (24 h) | — (Count) | ein/aus/missed aufgeschlüsselt |

### 8.2 Verbindung & Konfiguration (Flag-Row-Pattern)

| Key | Typ | Bemerkung |
|-----|-----|-----------|
| `3cx_pbx_url` | string | Hostname · Verbindungs-Status |
| `3cx_api_key` | secret (masked) | Rotation-Empfehlung alle 90 d |
| `3cx_webhook_url` | string (readonly) | Test-Button |
| `3cx_transcription_engine` | enum | Whisper-Large-v3 (default) · Whisper-Medium · Deepgram-Nova |
| `3cx_auto_call_logging` | bool | Auto-Erfassung als Activity |

### 8.3 Webhook-Log

Table · letzte 24 h · Auto-Refresh 30 s. Spalten: Zeit · Event (`call.ended` · `call.missed` · `call.failed`) · Teilnehmer · Dauer · Latenz (Call→History) · Transcript-Status · Gesamt-Status.

SLA-Warn: Latenz > 30s → `s-badge.warn` „Late".

---

## 9. TAB 6 · SCRAPER

**Datenbasis:** `dim_scraper_jobs` · `fact_scraper_runs` · `fact_scraper_alerts` · `dim_scraper_global_settings` · `dim_circuit_breakers`.

### 9.1 KPI-Strip (4 Cards)

Aktive Jobs · Erfolgsrate 7d · Alerts · Circuit-Breaker-Tripped.

### 9.2 Sub-Tabs (4)

| # | Sub-Tab | Inhalt |
|---|---------|--------|
| 6.1 | Jobs & Schedules | Table mit 24 Scraper-Jobs · Filter Typ/Status |
| 6.2 | Run-History | 240 letzte Runs · Erfolg/Fehler |
| 6.3 | Alerts | 3 aktive Alerts · Severity-Chips (Critical/Warning/Info) |
| 6.4 | Global-Settings | User-Agent · Timeout · Retry-Policy · CB-Schwelle · Proxy-Pool |

### 9.3 Scraper-Typen (Enum)

`website_monitor` · `team_page` · `stellenplan` · `news_feed`

### 9.4 Scraper-Job-Drawer

Verweist auf `specs/ARK_SCRAPER_MODUL_SCHEMA_v0_1.md` (bereits definiert, wird in Admin eingeklinkt, nicht dupliziert).

---

## 10. TAB 7 · NOTIFICATIONS

**Datenbasis:** `dim_notification_templates` · `fact_notifications` · `dim_notification_channels`.

### 10.1 Sub-Tabs (3)

| # | Sub-Tab | Inhalt |
|---|---------|--------|
| 7.1 | Templates | 14 Templates · Auto-Trigger-Mapping |
| 7.2 | Queue | 4-Row-Queue (In-App · Push · Email-Digest · Failed) |
| 7.3 | Kanäle | 3 Karten (In-App · Push · Email-Digest) mit Health-Status |

### 10.2 Notification-Template-Drawer

Sektionen:

#### 10.2.1 Basis
- Name · Trigger-Event (Combobox) · Priorität (Prio-Seg)

#### 10.2.2 Kanäle
- Multi-Select-Chips: `in_app` · `push_web` · `email_digest` · `slack` · `webhook`

#### 10.2.3 Texte pro Kanal

Je aktivem Kanal eigene Text-Konfig:

| Kanal | Felder | Limit |
|-------|--------|-------|
| In-App | Titel · Body | 120 Zeichen Body |
| Push Web | Titel · Body | 60 / 180 Zeichen |
| Email-Digest | Sektions-Titel · Zeilen-Template | — |

#### 10.2.4 Deep-Link & Action
- Deep-Link-Template (z.B. `/reminders/{{reminder.id}}`)
- Quick-Actions-Chips (Erledigen · Snoozen · Weitergeben · Custom)

#### 10.2.5 Empfängerkreis
- `assigned_user` · `process_am` · `am_team` · `all_admins` · `custom_expr`
- User-Opt-out erlaubt (bool) — System-kritische Notifications nicht abschaltbar

#### 10.2.6 Rate-Limit (Anti-Spam)
- Max/User/Stunde · Max/User/Tag · Dedup-Fenster (min)

### 10.3 Kanäle-Gesundheit

Karten: Status (aktiv/inaktiv) · User-Count (Push: opt-in) · Delivery-Stats.

---

## 11. TAB 8 · DASHBOARD-TEMPLATES

**Datenbasis:** `dim_dashboard_templates` (Rolle-Defaults) · `dim_dashboard_widgets` (Widget-Library) — siehe `ARK_DASHBOARD_CUSTOMIZATION_SCHEMA_v1.md`.

### 11.1 Rolle-Chips

6 Rollen: `senior_partner` · `consultant` · `researcher` · `backoffice` · `admin` · `head_of_department`.

Pro Rolle: Widget-Count-Badge.

### 11.2 Widget-Grid (pro Rolle)

Cards mit Widget-Name + Beschreibung. Aus Widget-Library (Referenz: `ARK_DASHBOARD_CUSTOMIZATION_SCHEMA_v1.md §4`).

### 11.3 Interaktion mit User-Overrides

Änderungen am Rolle-Default wirken **nur** auf **neue User** dieser Rolle + Admin-Action „Reset auf Default". User mit existierendem Override bleiben unangetastet (siehe §12.2 Events).

---

## 12. TAB 9 · DEBUG

Verweist auf `specs/ARK_ADMIN_DEBUG_SCHEMA_v1_0.md` (bereits definiert). Admin-Vollansicht integriert diese 5 Sub-Tabs:

| # | Sub-Tab | Spec-Referenz |
|---|---------|---------------|
| 9.1 | Event-Log | §3 Event-Log |
| 9.2 | Saga-Traces | §4 Saga-Trace |
| 9.3 | Dead-Letter-Queue | §5 DLQ |
| 9.4 | Circuit-Breaker | §6 CB-Grid |
| 9.5 | Rule-Execution | §7 Rule-Exec |

**Wichtig:** Admin-Debug-Spec bleibt kanonische Quelle — diese Spec ergänzt nur die Integration in den Tab-Container.

---

## 13. TAB 10 · AUDIT & RETENTION

**Datenbasis:** `fact_audit_log` (append-only) · `dim_legal_holds` · `dim_retention_policies` · `fact_dsg_requests`.

### 13.1 KPI-Strip (4 Cards)

Audit-Events 24h · Legal-Hold aktiv · Retention-Policy-Max (10 J) · DSG-Löschanfragen offen.

### 13.2 Sub-Tabs (4)

| # | Sub-Tab | Inhalt |
|---|---------|--------|
| 10.1 | Audit-Log | Table `fact_audit_log` · Filter Entity/Aktion/Datum |
| 10.2 | Legal-Hold | Table aktiver Holds · CRUD |
| 10.3 | Retention-Policy | 5 Keys Flag-Row-Pattern |
| 10.4 | DSG-Löschanfragen | Auskunfts-/Löschanfragen gem. DSG Art. 8 & Art. 25 |

### 13.3 Audit-Log-Aktionen (Enum)

`CREATE` · `UPDATE` · `DELETE` · `READ` (nur für sensitive Daten: Bank, Gehaltsvorstellung, Assessment-Details) · `EXPORT` · `CONFIG` · `PLACEMENT` · `LEGAL_HOLD` · `RETENTION_CHANGE`.

### 13.4 Retention-Policy-Keys

| Key | Default | Rechtsgrundlage |
|-----|---------|-----------------|
| `retention_activities_jahre` | 10 | DSG CH |
| `retention_bank_data_jahre` | 10 | OR CH |
| `retention_candidate_base_jahre` | 5 | DSG Art. 6 (Zweckbindung) |
| `personal_data_hashing_enabled` | true | DSG (Hashing statt Löschung) |
| `audit_log_retention_jahre` | 10 | OR / DSG |

**Vier-Augen-Prinzip:** Änderung erfordert Sign-off durch 2 Admins (2 Datenbank-Rows in `fact_retention_change_approvals`). Rückwirkung nur nach Rechtsprüfung (Warn-Banner).

### 13.5 Legal-Hold-Drawer

Felder: Entity-Ref · Gesetzt-von · Datum · Grund (Pflicht, Freitext) · Ablauf (Datum oder „offen"). CRUD mit Vier-Augen-Confirm für Aufheben.

### 13.6 DSG-Anfrage-Drawer

Felder: Anfrage-Typ (Auskunft / Löschung / Berichtigung) · Betroffene Person · Eingangsdatum · SLA-Ablauf (30 d) · Status (offen / in Bearbeitung / erledigt) · Bearbeiter · Notizen · Ergebnis-Dokument-Link.

---

## 14. BERECHTIGUNGEN

| Tab | `admin` | andere Rollen |
|-----|---------|---------------|
| Alle 10 Tabs | **R/W** | **403 Forbidden** |
| Deep-Links `/admin/:tab` | Vollzugriff | Redirect `/dashboard` + Toast „Keine Berechtigung" |

**Hinweis:** `head_of_department` hat **keinen** Admin-Zugriff (Design-Entscheidung 2026-04-17). Hoheitliche Einsicht in Team-Workload erfolgt über Dashboard + `/team`.

**Admin-Fallback:** Falls einziger Admin deaktiviert wird, bleibt letzter Admin aktiv (DB-Constraint `dim_users WHERE role='admin' AND active=true COUNT ≥ 1`).

---

## 15. DATEN-INVARIANTEN

### 15.1 Feature-Flags
- `dim_automation_settings` Primärschlüssel: `(tenant_id, scope, key)`
- Value-Typ: `json` (unterstützt int, string, bool, array, object, matrix)
- Änderung triggert `fact_audit_log` mit `action=CONFIG`
- Feature-Flags mit `locked=true` (HR-Tool, Provisions v2) können nicht aktiviert werden, bis Tenant Feature-License hat

### 15.2 Automation-Rules
- `dim_automation_rules.status` ∈ {`active`, `paused`, `beta`, `deactivated`}
- `version` inkrementell · alte Versionen in `fact_rule_versions`
- Circuit-Breaker pro Regel 1:1 (`dim_circuit_breakers.rule_id FK`)
- `fact_rule_executions` append-only · Retention 90 d default

### 15.3 Templates (Reminder / Email / Notification)
- Namen eindeutig pro Typ (`UNIQUE(type, name, tenant_id)`)
- Delete: Soft-Delete (`deleted_at`) · Referenzen von aktiven Regeln blockieren Delete (FK-Check)
- Variable-Namen: snake_case · Prefix `{{entity.field}}` oder `{{custom.xxx}}`

### 15.4 Audit-Log
- `fact_audit_log` **append-only** — keine Update/Delete möglich (DB-Trigger)
- Legal-Hold überschreibt Retention (`legal_hold_id IS NOT NULL` → nie löschen/hashen)
- Diffs als `jsonb` gespeichert (before/after)

### 15.5 Retention-Policy
- Änderung erfordert 2 Admin-Signatures (`fact_retention_change_approvals` Count ≥ 2)
- Policy-Enforcement via Nightly-Worker (`retention.worker.ts`)
- Personal-Data-Hashing: irreversibles SHA-256 der PII-Felder, Statistik-Felder bleiben (anonymisiert)

---

## 16. ROUTING

| Route | Wirkung |
|-------|---------|
| `/admin` | Default Tab 1 (Feature-Flags) |
| `/admin/flags` | Tab 1 |
| `/admin/automation` | Tab 2 |
| `/admin/automation/:ruleId` | Tab 2 + Rule-Drawer offen |
| `/admin/reminder-templates` | Tab 3 |
| `/admin/reminder-templates/:id` | Tab 3 + Template-Drawer offen |
| `/admin/email` | Tab 4 (Sub-Tab 4.1) |
| `/admin/email/:subtab` | Tab 4 + Sub-Tab (templates/oauth/codetwo/ignore/queue) |
| `/admin/email/templates/:id` | Tab 4 · Sub-Tab 4.1 + Template-Drawer |
| `/admin/telefonie` | Tab 5 |
| `/admin/scraper` | Tab 6 (Sub-Tab 6.1) |
| `/admin/scraper/:subtab` | Tab 6 + Sub-Tab |
| `/admin/notifications` | Tab 7 |
| `/admin/dashboards` | Tab 8 |
| `/admin/debug` | Tab 9 (Sub-Tab 9.1 · Event-Log) |
| `/admin/debug/:subtab` | Tab 9 + Sub-Tab |
| `/admin/audit` | Tab 10 (Sub-Tab 10.1) |
| `/admin/audit/:subtab` | Tab 10 + Sub-Tab |

**Deep-Link-Query-Parameter:**

- `?filter=…&from=…&to=…` — Server-side-persistiert pro User
- `?highlight=<id>` — Scroll + Pulse-Animation auf Row

---

## 17. OFFENE PUNKTE / PHASE 1.5+

| # | Punkt | Wann | Bemerkung |
|---|-------|------|-----------|
| 1 | Webhooks-Registry (`dim_webhooks` + Logs) | P1.5 | Eigener Tab oder Sektion in Tab 2? |
| 2 | Workers/Cron-Monitor (18 Worker aus §B) | P2 | Niche UI, manual-trigger für Admins |
| 3 | RBAC-Editor (`dim_roles` CRUD) | P2 (HR-Tool) | Aktuell hardcoded · Phase 2 editierbar |
| 4 | Commit-Lag / WAL-Monitor | P2 | Nice-to-have für Datenbank-Health |
| 5 | Tenant-Wide Search über Config-Keys | P1.5 | Globale Suchleiste oberhalb Tab 1 |
| 6 | Import/Export Config (Tenant-Template) | P2 | Für neue Tenants (Multi-Tenancy) |
| 7 | HR-Tool-Integration | P2 | Feature-Flag `feature_hr_tool` aktiviert neue Tabs |

---

## 18. CHANGELOG

- **v0.1 (2026-04-17)** Erstentwurf aus Mockup `mockups/admin.html` · nachträglich erstellt gem. Mockup-First-Workflow (Memory `feedback_mockup_first_workflow.md`).
