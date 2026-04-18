# ARK CRM — Admin Vollansicht Interactions v0.1

**Stand:** 2026-04-17
**Status:** Erstentwurf — Review ausstehend
**Schema-Gegenstück:** `ARK_ADMIN_VOLLANSICHT_SCHEMA_v0_1.md`
**Mockup-Referenz:** `mockups/admin.html`

**Quellen:**
- `ARK_ADMIN_VOLLANSICHT_SCHEMA_v0_1.md` (Daten-Struktur, Tab-Übersicht)
- `Grundlagen MD/ARK_BACKEND_ARCHITECTURE_v2_5.md` (Events · Sagas · Worker · Endpunkte)
- `specs/ARK_ADMIN_DEBUG_SCHEMA_v1_0.md` (Debug-Tab Interactions)
- `wiki/concepts/automationen.md` · `audit-log-retention.md`

---

## 0. ÜBERSICHT

Dieses Dokument beschreibt **User-Flows**, **State-Transitions**, **API-Endpunkte**, **Events** und **Sagas** pro Tab. Jeder Flow ist atomar beschrieben: Trigger → optimistic Update → API → Event → Ergebnis.

**Notations-Legende:**
- `POST /api/...` · HTTP-Endpunkt
- `emit:event_name` · System-Event
- `saga: saga_name` · Mehrstufige Transaktion mit Kompensation
- `audit: action=X` · `fact_audit_log`-Row geschrieben
- `ws:channel` · WebSocket-Broadcast

---

## 1. GLOBALE INTERAKTIONEN

### 1.1 Route-Load `/admin/:tab?`

**Flow:**
1. Browser: `GET /admin/flags` (oder Deep-Link)
2. Server prüft `current_user.role === 'admin'` → sonst `HTTP 403` + Redirect `/dashboard` mit Toast „Keine Berechtigung"
3. Lädt Tab-Data-Bundle: `GET /api/admin/:tab/bootstrap` (Tab-spezifisch, siehe §2-§11)
4. Render Page-Banner, KPI-Strip, aktive Tab-Panel
5. `audit: action=READ, entity=admin_view, tab=:tab, actor=current_user`

### 1.2 Tab-Switch (innerhalb `/admin`)

**Flow:**
1. Click Tab → `switchTab(n)` (aus `_shared/layout.js`)
2. URL-Update via `history.pushState` → `/admin/:newtab`
3. Wenn Tab-Data noch nicht geladen: `GET /api/admin/:newtab/bootstrap`
4. Auto-Refresh-Timer für Live-Tabs (9.1 Event-Log, Queue) aktivieren/stoppen

### 1.3 Sub-Tab-Switch

**Flow:**
1. Click Sub-Tab → `switchSubTab(id)` (scoped im aktuellen Tab-Panel)
2. Wenn Sub-Tab-Data lazy: `GET /api/admin/:tab/:subtab/bootstrap`
3. URL-Update `/admin/:tab/:subtab` (optional, nicht bei allen implementiert v0.1)

### 1.4 KPI-Card-Click

Jede KPI-Card ist klickbar → `switchTab(n)` + optional Pre-Filter via Query-Param (`?filter=failures` bei Saga-Card).

### 1.5 Legal-Hold-Button (Page-Banner)

Öffnet Dropdown mit: „Legal-Hold-Liste anzeigen" (→ Tab 10 · Sub-Tab 10.2) · „Neuer Legal-Hold" (Drawer §13.5).

### 1.6 Refresh-Button (Page-Banner)

Triggert Bootstrap-Reload aller Tabs-Cache + KPI-Strip-Refresh.

### 1.7 Auto-Refresh

- Standard: **30 s Intervall** für Live-Tabs
- Toggle in Page-Banner oder pro Tab
- Pausiert wenn Drawer offen (verhindert Race-Condition beim Editieren)

---

## 2. TAB 1 · FEATURE-FLAGS & SYSTEM-SETTINGS

### 2.1 Toggle Feature-Flag (`toggle`)

**Flow:**
1. User klickt `.toggle input[type=checkbox]`
2. Optimistic Update (Toggle flipt sofort)
3. `PUT /api/admin/settings/{key} { value: bool }`
4. Server:
   - Validiert `locked=false`
   - Schreibt `dim_automation_settings` · inkrementiert `version`
   - `audit: action=CONFIG, key, old_value, new_value, reason=null`
   - `emit: setting.changed { key, scope, new_value }`
5. Erfolg → Toast „Gespeichert" · Sub-Workers (abhängige Services) lesen neu
6. Fehler → Rollback Toggle · Error-Toast mit Grund

**Locked Flags** (HR-Tool, Provisions v2): Click zeigt Tooltip „Phase 2 · erfordert Feature-License", kein Toggle.

### 2.2 Numeric/Text-Value-Change

**Flow (für inline-Input wie `ghosting_frist_tage`):**
1. User tippt neuen Wert → `blur` oder `Enter`
2. Click Button „Ändern" → öffnet **`flagDrawer`** (§2.4)

### 2.3 Staffel-Preview-Click

**Flow:**
1. Click Button „Editieren" bei Honorar-Staffel oder Refund-Staffel
2. Öffnet dedizierten Drawer (`feeStaffelDrawer` §13.1 oder `refundStaffelDrawer` §13.2)

### 2.4 Flag-Drawer · Save

**Flow:**
1. User ändert Wert + tippt Begründung (Pflichtfeld falls enforced)
2. Click „Speichern"
3. `PUT /api/admin/settings/{key} { value, reason }`
4. Server: wie §2.1 Steps 4
5. Drawer schließt · Toast · KPI-Refresh

**Rollback-Button** „↺ Auf Default zurück": Ersetzt Input-Wert mit `dim_automation_settings.default_value`, speichert beim nächsten Save.

### 2.5 Alle zurücksetzen

**Flow:**
1. Click „↺ Alle zurücksetzen auf Default" in Toolbar
2. Confirm-Modal (kurz): „Alle Flag-Werte auf Default? Änderungen seit Initial-Setup werden überschrieben."
3. `POST /api/admin/settings/reset-all { scope: 'tenant' }`
4. Server: Transactional-Update aller non-locked Keys · schreibt 1 Audit-Row pro Key
5. Refresh Tab · Toast „N Werte zurückgesetzt"

---

## 3. TAB 2 · AUTOMATION-REGELN

### 3.1 Regel-Pause/Activate (Tabelle)

**Flow:**
1. Click „Pause"-Button in Row
2. Optimistic: Health-Dot wird grau · Status-Badge wird „Paused"
3. `PUT /api/admin/automation-rules/{id}/status { status: 'paused' }`
4. Server: Update `dim_automation_rules.status` · `audit: action=UPDATE` · `emit: automation.rule.paused`
5. Rule-Worker (`automation.worker.ts`) liest Status bei nächstem Run → skippt

**Activate:** Umgekehrt, `status='active'` + `emit: automation.rule.activated`.

### 3.2 Neue Regel erstellen

**Flow:**
1. Click „+ Neue Regel" → öffnet `ruleDrawer` leer
2. User befüllt 5 Sektionen
3. Click „Speichern" → Validation (Name Pflicht, Trigger gültig, min. 1 Action)
4. `POST /api/admin/automation-rules { ... }` → Server legt Row an · `audit: action=CREATE`
5. `emit: automation.rule.created`
6. Drawer schließt · Toast · Row in Tabelle eingefügt

### 3.3 Regel bearbeiten · Test-Run

**Flow (Test-Run):**
1. User in Drawer klickt „▶ Mit letztem Live-Event testen"
2. `POST /api/admin/automation-rules/{id}/test-run { mode: 'last_event' }`
3. Server: Zieht letztes matching Event aus `fact_events` · führt Rule im **Dry-Run-Modus** aus (keine Seiten-Effekte)
4. Response: `{ matched: bool, would_create: [{type, preview_data}], errors: [] }`
5. Rendered im `.test-preview`-Banner

**Mit Custom-Payload:** Zusätzlicher JSON-Editor-Modal → `POST /api/admin/automation-rules/{id}/test-run { mode: 'custom', payload: {...} }`.

### 3.4 Trigger-Mode-Switch (Drawer)

Siehe §1.2 Mockup-JS `toggleRuleTriggerType(val)` — zeigt nur den Mode-spezifischen Sub-Block.

### 3.5 Condition-Builder-Row hinzufügen

**Flow:**
1. Click „+ Bedingung hinzufügen"
2. Frontend: Neue `.cond-row` an bestehende Liste anhängen (kein Backend-Call bis Save)
3. Row entfernen: Click `.row-drop` → Remove DOM-Node

### 3.6 Action-Chain · Schritt umordnen

**Flow:**
1. Drag-Handle am linken Rand der Action-Card (v0.2, aktuell v0.1 statisch)
2. Drag to new position → Frontend reorders DOM
3. Beim Save: `actions` Array wird in neuer Reihenfolge gesendet

### 3.7 Circuit-Breaker Manual-Reset

**Flow:**
1. CB-Card mit Status `OPEN` oder `HALF-OPEN` zeigt „Manual Reset"-Button
2. Click → Confirm-Modal: „CB {{name}} manuell auf CLOSED setzen? Erneute Fehler triggern sofort wieder Trip."
3. `POST /api/admin/circuit-breakers/{id}/reset`
4. Server: `UPDATE dim_circuit_breakers SET state='CLOSED', last_manual_reset=now()` · `audit: action=UPDATE` · `emit: circuit_breaker.reset { cb_id, actor }`
5. Card-Update · Toast

### 3.8 Saga-Failure-Retry (Tab 9)

Siehe §10.2 (Saga-Trace Retry).

---

## 4. TAB 3 · REMINDER-TEMPLATES

### 4.1 Template öffnen (Grid → Drawer)

**Flow:** Click Card → `remTmplDrawer` mit Template-Daten populiert.

### 4.2 Template-Save

**Flow:**
1. User editiert Titel/Body/Trigger/Timing
2. Validation: Titel ≤ 200 Zeichen, Variable-Syntax `{{…}}` wohlgeformt
3. Click „Speichern" → `PUT /api/admin/reminder-templates/{id} { ... }`
4. Server: Inkrementiert `version` · schreibt alte Version in `fact_template_versions` · `audit: action=UPDATE`
5. `emit: reminder_template.updated { id, version }`
6. Referenzen von Automation-Regeln bleiben auf gepinnter Major-Version (automatischer Hinweis-Banner bei Minor-Bump ignorierbar)

### 4.3 Neue Template

**Flow:** Click „+ Neues Template" → leerer Drawer → `POST /api/admin/reminder-templates`.

### 4.4 Template löschen (Soft-Delete)

**Flow:**
1. Click „Löschen" im Drawer
2. Server prüft `SELECT COUNT(*) FROM dim_automation_rules WHERE template_id = ? AND status = 'active'`
3. Falls > 0: Error „Template wird von N aktiven Regeln verwendet. Erst Regeln deaktivieren."
4. Sonst: `DELETE /api/admin/reminder-templates/{id}` → setzt `deleted_at=now()` (Soft-Delete) · `audit: action=DELETE`

### 4.5 Template duplizieren

**Flow:**
1. Click „Duplizieren"
2. Neuer Drawer mit kopierten Werten · Name-Suffix „ (Kopie)"
3. Save → `POST` (neue Row) · keine Version-Historie-Übertragung

### 4.6 Variable-Chip-Click

**Flow:** Click Chip → `navigator.clipboard.writeText('{{var}}')` + Toast „Variable kopiert". V0.2: Direkt-Insert am Cursor-Position.

---

## 5. TAB 4 · EMAIL

### 5.1 Sub-Tab 4.1 · Template-Table · Row-Click

**Flow:** Click Row → `emailTmplDrawer` mit Template-Daten.

### 5.2 Template-Save (Email)

Analog §4.2, Endpunkt `PUT /api/admin/email-templates/{id}`.

**Template-Lint:** Server prüft alle Variablen gegen Payload-Schema des zugehörigen Trigger-Events. Fehlende Variablen → Warn-Toast, nicht Block.

### 5.3 Test-Send an mich

**Flow:**
1. Click „Test-Send an mich" im Drawer-Foot
2. `POST /api/admin/email-templates/{id}/test-send { to: current_user.email, sample_payload: {...} }`
3. Server rendert Template mit Sample-Payload · versendet via Outlook (User-Token) oder System-Mailbox
4. Toast „Test gesendet an {{email}}" · User prüft Inbox

### 5.4 Sub-Tab 4.2 · OAuth-Tokens

#### 5.4.1 Re-Auth

**Flow:**
1. Click „Re-Auth" in Row
2. Redirect zu Microsoft-Login: `GET /oauth/microsoft/authorize?user_id=X&redirect_uri=/admin/email/oauth`
3. Nach Consent: Callback mit neuem Refresh-Token · `UPDATE dim_user_oauth_tokens SET refresh_token, expires_at, scopes`
4. `audit: action=UPDATE, entity=oauth_token` · `emit: oauth.token.refreshed`
5. Redirect zurück · Row-Status „Aktiv"

#### 5.4.2 Auto-Warn < 7 d

**Worker:** `oauth_token_expiry.worker.ts` läuft täglich 07:00:
```
FOREACH token WHERE expires_at < now() + '7 days'
  emit: notification.enqueue { template: 'oauth_token_expiring', recipient: user_id }
  IF expires_at < now() + '1 day'
    ALSO notify admin
```

### 5.5 Sub-Tab 4.3 · CodeTwo-Sync

#### 5.5.1 Manual-Sync

**Flow:**
1. Click „↻ Manual-Sync"
2. `POST /api/admin/codetwo/sync`
3. Server: Ruft CodeTwo-API · lädt Signatur-Templates · matcht auf User (`dim_users.codetwo_template_id`)
4. Response: `{ templates_synced: N, users_updated: M, errors: [] }`
5. Panel-Update · Toast

#### 5.5.2 Sync-Log anzeigen

Öffnet Drawer mit letzten 20 Sync-Runs (Timestamp, Template-Count, User-Count, Errors, Dauer).

### 5.6 Sub-Tab 4.4 · Ignore-List

#### 5.6.1 Neue Regel

**Flow:**
1. Click „+ Regel" → `ignoreDrawer` (v0.2 dedicated drawer)
2. Felder: Pattern · Typ (Enum) · Grund · Scope (tenant/user)
3. Test-Mode: „Regel simuliert auf letzten 100 Mails" → Count zeigt wieviele blockiert würden
4. Save → `POST /api/admin/email-ignore-rules`

#### 5.6.2 Regel löschen

`DELETE /api/admin/email-ignore-rules/{id}` · Soft-Delete · `audit: action=DELETE`.

### 5.7 Sub-Tab 4.5 · Queue & Delivery

Live-Panel · Auto-Refresh 30 s.

**Click auf Queue-Row:** Öffnet Drawer mit Liste aller pending/failed Mails · Manual-Retry-Button pro Mail.

---

## 6. TAB 5 · TELEFONIE 3CX

### 6.1 API-Key-Rotation

**Flow:**
1. Click „Rotate"-Button
2. Confirm-Modal: „Neuen API-Key generieren? Alter Key wird sofort invalid."
3. `POST /api/admin/3cx/rotate-api-key`
4. Server: Generiert neuen Key · zeigt einmalig im Response (Copy-to-Clipboard-Button) · alter Key invalid
5. `audit: action=UPDATE, entity=3cx_config, field=api_key` (ohne Key selbst, nur Event)
6. **Pflicht:** User kopiert Key und trägt ihn in 3CX-Admin ein

### 6.2 Webhook-Test

**Flow:**
1. Click „Test"-Button bei Webhook-URL
2. `POST /api/admin/3cx/webhook-test`
3. Server sendet Dummy-Event an eigene Webhook-URL · misst Round-Trip-Time
4. Response: `{ ok: bool, latency_ms, error }`
5. Toast mit Ergebnis

### 6.3 Transcription-Engine-Wechsel

**Flow:**
1. Select-Change → optimistic
2. `PUT /api/admin/settings/3cx_transcription_engine { value: '...' }`
3. Server: `emit: transcription.engine.changed` · `call_transcript.worker.ts` re-loaded mit neuer Config
4. Warn-Toast: „Neue Engine aktiv. Laufende Transkriptionen laufen mit alter Engine zu Ende."

### 6.4 Webhook-Log Row-Click

Öffnet Drawer mit Full-Event-Details (Call-ID, Participants, Transcript-Text, Summary).

---

## 7. TAB 6 · SCRAPER

Verweist auf `specs/ARK_SCRAPER_MODUL_INTERACTIONS_v0_1.md` für Job-CRUD, Run-Triggering, Alert-Handling.

### 7.1 Admin-spezifische Interaktionen

#### 7.1.1 Circuit-Breaker Manual-Reset (Scraper)

Analog §3.7, Endpunkt `POST /api/admin/scraper-jobs/{id}/reset-breaker`.

#### 7.1.2 Alert-Resolve

**Flow:**
1. Click „Fix" oder „Ignore 24 h" in Alerts-Table
2. Fix → Öffnet Scraper-Job-Drawer mit Fokus auf Selector-Field (v0.2 AI-Vorschlag für neuen Selector)
3. Ignore 24 h → `PUT /api/admin/scraper-alerts/{id} { status: 'snoozed', snooze_until }`
4. `audit: action=UPDATE`

#### 7.1.3 Global-Setting-Change

Analog §2.1 Feature-Flag-Pattern, Endpunkt `PUT /api/admin/scraper/settings/{key}`.

---

## 8. TAB 7 · NOTIFICATIONS

### 8.1 Notification-Template-Save

Analog Reminder-Template §4.2, Endpunkt `PUT /api/admin/notification-templates/{id}`.

### 8.2 Test-an-mich

**Flow:**
1. Click „Test an mich" im Drawer
2. `POST /api/admin/notification-templates/{id}/test-send { recipient: current_user.id, channels: [...active...], sample_payload }`
3. User erhält Notification auf gewählten Kanälen

### 8.3 Kanal-Opt-out-Toggle (Tab-Kanäle)

Pro Kanal-Card: Admin kann tenant-weit abschalten (Toggle). Bei OFF: Worker skippt diese Kanal-Zustellung für alle User.

### 8.4 User-Opt-out (im Template)

Wenn „Nein · System-kritisch" gesetzt, zeigt User-Settings-UI diese Notification mit Lock-Icon (nicht abschaltbar).

---

## 9. TAB 8 · DASHBOARD-TEMPLATES

### 9.1 Rolle wählen

Click Rolle-Chip → Widget-Grid lädt für diese Rolle.

### 9.2 Widget hinzufügen

**Flow:**
1. Click „+ Widget hinzufügen" → Widget-Library-Modal (aus `ARK_DASHBOARD_CUSTOMIZATION_SCHEMA_v1 §4`)
2. Widget auswählen · Config (Filter, Scope) anpassen
3. Save → `POST /api/admin/dashboard-templates/{role}/widgets`

### 9.3 Widget entfernen

**Flow:**
1. Click ✕-Icon auf Widget-Card
2. Confirm: „Widget aus Rolle-Default entfernen? Bestehende User mit Override bleiben unberührt. Neue User erhalten kein Widget."
3. `DELETE /api/admin/dashboard-templates/{role}/widgets/{widget_id}`
4. `emit: dashboard_template.widget.removed`

### 9.4 Reset User-Overrides auf Default

**Flow:**
1. Click „Reset User-Overrides" (optional Bulk-Action pro Rolle)
2. Confirm: „Alle User der Rolle {{role}} auf aktuellen Default zurücksetzen? Custom-Widgets gehen verloren."
3. `POST /api/admin/dashboard-templates/{role}/reset-user-overrides`
4. Server: `DELETE FROM fact_user_dashboard_overrides WHERE user.role = X`
5. `emit: dashboard.reset.bulk { role, affected_users }`
6. Toast „N User zurückgesetzt"

### 9.5 Preview-Mode

**Flow:**
1. Click „Preview" → Öffnet neuen Tab/Iframe mit `/dashboard?as_role={{role}}&preview=true`
2. Admin sieht Dashboard wie Rolle-User ihn sieht (ohne tatsächliches Role-Switching)

---

## 10. TAB 9 · DEBUG

Verweist primär auf `ARK_ADMIN_DEBUG_SCHEMA_v1_0.md`. Hier nur Admin-Integrationen:

### 10.1 Event-Log Row-Click

**Flow:** Click Row → `eventDrawer` mit Full-Payload + Triggered-Downstream-Events.

### 10.2 Saga-Retry

**Flow:**
1. Click „Retry jetzt" in Saga-Trace-Card
2. Confirm: „Saga {{saga_id}} ab letztem fehlgeschlagenen Schritt wiederholen?"
3. `POST /api/admin/sagas/{id}/retry`
4. Server: Enqueues Saga-Retry-Job · `audit: action=UPDATE, entity=saga`
5. Toast „Retry enqueued" · Auto-Refresh zeigt neuen Status

### 10.3 Saga-Skip-Step

**Flow (advanced):**
1. Click „Skip Step N" (nur wenn Saga pattern erlaubt)
2. Confirm-Modal mit expliziter Warnung: „Step {{n}} überspringen kann zu inkonsistentem State führen. Sicher?"
3. `POST /api/admin/sagas/{id}/skip-step { step_n }`
4. `audit: action=UPDATE, entity=saga, reason_required=true` (User muss Grund eintippen)

### 10.4 Dead-Letter-Queue Process

DLQ-Items öffnen Detail-Drawer mit Full-Payload + Retry/Delete-Buttons. Pro Retry: `POST /api/admin/dlq/{id}/retry`.

### 10.5 Event-Log Live-Tail

**Flow:**
1. Checkbox „Live-Tail" aktivieren
2. Frontend öffnet WebSocket `ws://api/events?tail=true&filter=...`
3. Neue Events prependen sich in Tabelle (max 500 visible)
4. Uncheck → WS-Close

### 10.6 Rule-Execution Row-Click

Öffnet Drawer mit Full-Rule + Trigger-Event-Payload + Action-Output-JSON.

---

## 11. TAB 10 · AUDIT & RETENTION

### 11.1 Audit-Log Row-Click

**Flow:**
1. Click Row → `auditDrawer`
2. Zeigt Full-Diff (before/after als JSON-Tree), User-Agent, IP, Correlation-ID
3. „Jump to Entity" Button → öffnet Entity-Detail-Mask

### 11.2 Audit-Log Export (CSV)

**Flow:**
1. Filter setzen (Entity-Typ, Aktion, Datum)
2. Click „Export CSV"
3. `GET /api/admin/audit-log/export?filter=...&format=csv`
4. Server: Streamt CSV · `audit: action=EXPORT, details={filter, row_count}`
5. Browser-Download

### 11.3 Legal-Hold setzen

**Flow:**
1. Click „+ Legal-Hold" → `legalHoldDrawer`
2. Felder: Entity (Autocomplete-Search) · Grund (Pflicht, ≥ 20 Zeichen) · Ablauf (Datum oder „offen")
3. Save → `POST /api/admin/legal-holds`
4. Server:
   - Row in `dim_legal_holds`
   - Alle zugehörigen `fact_audit_log`-Einträge bekommen `legal_hold_id` gesetzt (via Trigger)
   - Entity-Delete/Update blockiert (DB-Constraint)
   - `audit: action=LEGAL_HOLD, entity=legal_hold`
   - `emit: legal_hold.set { entity_id, actor, reason }`
5. Betroffene Entities zeigen überall Badge „🔒 Legal-Hold"

### 11.4 Legal-Hold aufheben

**Flow:**
1. Click „Aufheben" in Legal-Hold-Row
2. Confirm: „Legal-Hold {{entity}} aufheben? Entity wird wieder mutierbar und unterliegt Retention."
3. Pflichtfeld „Grund für Aufhebung"
4. `DELETE /api/admin/legal-holds/{id} { reason }`
5. `audit: action=LEGAL_HOLD, sub_action=release`

### 11.5 Retention-Policy-Change · Vier-Augen-Prinzip

**Flow:**
1. Admin-A ändert Retention-Value + Grund → `POST /api/admin/retention-policies/{key}/propose { new_value, reason }`
2. Server: Erstellt `fact_retention_change_proposals` Row · Status `pending_second_signature`
3. Notification an alle anderen Admins
4. Admin-B öffnet Proposal → prüft Diff + Grund → Click „Bestätigen" oder „Ablehnen"
5. Bei „Bestätigen" 2 aus N Admins:
   - `UPDATE dim_retention_policies SET value=new_value`
   - `emit: retention_policy.changed`
   - `audit: action=RETENTION_CHANGE, approvals=[A,B]`
   - Warn-Banner: „Policy greift ab sofort. Rückwirkung auf bereits gelöschte/gehashte Daten nicht möglich."
6. Bei „Ablehnen": Proposal discarded, Notification an Admin-A.

### 11.6 DSG-Löschanfrage erfassen

**Flow:**
1. Click „+ Anfrage erfassen" → `dsgRequestDrawer`
2. Felder: Typ (Auskunft/Löschung/Berichtigung) · Person (Kandidat-Search) · Eingangsdatum · Notizen
3. `POST /api/admin/dsg-requests` → SLA-Timer startet (30 d)
4. `emit: dsg_request.created`
5. Assignee (default: Admin-Creator) bearbeitet · Status → `in_progress` → `completed`
6. Bei Typ=Löschung:
   - Saga `candidate_data_erasure` triggert
   - Legal-Hold wird geprüft (wenn aktiv → Löschung blockiert, Response an Betroffene Person)
   - Sonst: Personal-Data-Hashing + Audit-Eintrag + Ergebnis-Dokument generiert (Deletion-Certificate PDF)
7. Close → `audit: action=DELETE, entity=candidate, sub_action=dsg_erasure`

---

## 12. EVENTS · QUELLE UND SENKE

Alle admin-seitig erzeugten Events (Auswahl):

| Event | Produzent | Konsument | Payload-Kern |
|-------|-----------|-----------|--------------|
| `setting.changed` | Tab 1 | Worker-Reload, Audit | `{key, old, new, actor}` |
| `automation.rule.created` | Tab 2 | Audit, Notification | `{rule_id, actor}` |
| `automation.rule.paused` / `.activated` | Tab 2 | Rule-Worker | `{rule_id, actor}` |
| `circuit_breaker.reset` | Tab 2/9 | Affected-Worker | `{cb_id, actor, old_state}` |
| `reminder_template.updated` | Tab 3 | Reminder-Worker | `{template_id, version}` |
| `email_template.updated` | Tab 4 | Email-Worker | `{template_id, version}` |
| `oauth.token.refreshed` | Tab 4 | Outlook-Sync-Worker | `{user_id}` |
| `notification_template.updated` | Tab 7 | Notification-Worker | `{template_id, version}` |
| `dashboard_template.widget.added/removed` | Tab 8 | none (nur bei New-User-Signup relevant) | `{role, widget_id}` |
| `dashboard.reset.bulk` | Tab 8 | Dashboard-User-Sync | `{role, affected_users}` |
| `legal_hold.set` / `.release` | Tab 10 | Retention-Worker | `{entity_id, actor, reason}` |
| `retention_policy.changed` | Tab 10 | Retention-Worker | `{key, old, new, approvers}` |
| `dsg_request.created` / `.completed` | Tab 10 | SLA-Timer, Notification | `{request_id, type, subject}` |

---

## 13. SAGAS · ADMIN-TRIGGERED

### 13.1 Saga: `retention_enforce`

**Trigger:** Nightly-Worker (`retention.worker.ts`) · nicht Admin-UI (aber Config via Admin).

**Schritte:**
1. Scan `fact_*` Tables nach Retention-Policy
2. Für Rows out of policy: Check `legal_hold_id IS NULL`
3. Delete (bei Hard-Delete-Policy) oder Personal-Data-Hash (bei Hash-Policy)
4. `audit: action=DELETE/HASH, sub_action=retention`
5. Report an Admin-Notification (Wochenzusammenfassung)

### 13.2 Saga: `candidate_data_erasure` (DSG Art. 25)

**Trigger:** Admin-initiated (Tab 10 · DSG-Request)

**Schritte (8):**
1. Validate Admin-Permission + DSG-Request-Status
2. Prüfe Legal-Hold (blockiert Löschung → Fehler-Response)
3. Prüfe aktive Mandate/Prozesse (Warn bei Referenzen, aber nicht blockierend)
4. Generate Deletion-Certificate (PDF, archiviert)
5. Personal-Data-Hash aller `dim_candidates`-Felder
6. Invalidate Active-Sessions des Kandidaten (falls Self-Service-Portal genutzt)
7. Kompensation: Bei Fehler in 4-6 → Rollback 5+6, DSG-Request zurück auf `in_progress`
8. `audit: action=DELETE, sub_action=dsg_erasure, certificate_id`

### 13.3 Saga: `codetwo_sync`

**Trigger:** Manual (Tab 4) oder Cron (alle 6 h)

**Schritte:**
1. Fetch CodeTwo-API-Token (refresh wenn nötig)
2. Get all Signature-Templates
3. Match auf `dim_users` per `codetwo_template_id`
4. Update `dim_codetwo_signatures` · merke Diff
5. Bei Fehler in 1-4: Retry 3× exp-backoff
6. Letzter Retry-Fail → `emit: codetwo.sync.failed` + Admin-Notification

---

## 14. WEBSOCKET-CHANNELS (Admin-spezifisch)

| Channel | Subscribe-Condition | Payload |
|---------|--------------------|---------|
| `ws://admin/events-tail` | Tab 9 · Live-Tail aktiv | Event-Stream mit Filter |
| `ws://admin/kpi-strip` | Admin-View offen | KPI-Values Delta (30 s Interval) |
| `ws://admin/circuit-breakers` | Tab 2 oder 9 offen | CB-State-Changes |
| `ws://admin/saga-failures` | Tab 9 · Sub-Tab Sagas offen | Neue Saga-Compensations |

Fallback: Long-Polling `/api/admin/poll?last_ts=...` wenn WS nicht verfügbar.

---

## 15. OPTIMISTIC-UPDATE-STRATEGIE

| Aktion | Optimistic? | Begründung |
|--------|-------------|------------|
| Feature-Flag-Toggle | ✓ | Idempotent, niedrige Fehler-Rate |
| Rule Pause/Activate | ✓ | Reversible, kein Daten-Schaden |
| Rule-Save (CRUD) | ✗ (Spinner) | Validation auf Server kann fehlschlagen |
| Template-Save | ✗ (Spinner) | Variable-Lint am Server |
| CB-Manual-Reset | ✓ | Button-State sofort, State-Update via WS |
| Legal-Hold-Set | ✗ (Spinner) | Hat DB-Auswirkungen, Bestätigung wichtig |
| Legal-Hold-Release | ✗ (Spinner) | Hat DB-Auswirkungen, Bestätigung wichtig |
| Retention-Change-Propose | ✗ (Spinner) | Multi-Step-Flow, Admin-B-Signatur nötig |
| DSG-Request-Erstellen | ✗ (Spinner) | SLA startet, audit-pflichtig |
| Saga-Retry | ✗ (Spinner) | State-changing, Server-Bestätigung nötig |

---

## 16. ERROR-HANDLING

### 16.1 API-Fehler-Code-Mapping

| HTTP | Bedeutung | UI-Reaktion |
|------|-----------|-------------|
| 400 | Bad Request / Validation | Inline-Error am betreffenden Feld |
| 401 | Session abgelaufen | Redirect `/login` |
| 403 | Keine Admin-Berechtigung | Toast + Redirect `/dashboard` |
| 404 | Entity nicht gefunden | Toast + Refresh |
| 409 | Conflict (z.B. Version-Mismatch) | Confirm-Modal „Gleichzeitiger Edit. Neu laden?" |
| 422 | Semantic Error (Regel-Invariante) | Inline + Drawer-Banner rot |
| 423 | Locked (z.B. Feature-Flag locked) | Tooltip bei Hover |
| 500 | Server-Fehler | Toast „Fehler aufgetreten · Versuch erneut" |

### 16.2 Rollback bei Optimistic-Update-Fail

- Toggle: Zurückflippen + Error-Toast
- CB-Reset: Card-State zurück + Error-Toast

---

## 17. LESE-SHORTCUTS (Keyboard)

| Shortcut | Aktion |
|----------|--------|
| `1` – `9`, `0` (=10) | Tab-Switch |
| `t` / `T` | Theme-Toggle |
| `r` / `R` | Refresh |
| `/` | Focus auf aktive Suche |
| `Esc` | Drawer/Modal schließen |

Shortcuts deaktiviert in Input-Feldern (gem. `_shared/layout.js`).

---

## 18. DEEP-LINKS · TYPISCHE SZENARIEN

| Use-Case | Deep-Link |
|----------|-----------|
| Admin ruft Admin-B zu Retention-Review | `/admin/audit/retention?proposal=PR-112` |
| Head-of (ohne Admin!) will Rule ansehen — geht **nicht**, 403 | — |
| Incident-Debug aus Slack-Notification | `/admin/debug/saga/S-9812?highlight=step_4` |
| Scraper-Alert aus Notification | `/admin/scraper/alerts?highlight=A-234` |
| Email-OAuth-Token refresh aus User-Notification | `/admin/email/oauth?user=JV` |
| Legal-Hold-Setup aus Mandat-Drawer | `/admin/audit/legal-hold?entity=mandate:M-123&new=true` |

---

## 19. OFFENE PUNKTE · PHASE 1.5+

| # | Punkt | Wann |
|---|-------|------|
| 1 | Drag-Handle für Action-Chain-Reorder | P1.5 |
| 2 | AI-Selector-Vorschlag bei Scraper-Fix | P2 |
| 3 | Advanced JSON-Logic-Editor (Visual-Builder) | P1.5 |
| 4 | Sharing-Links für Rule-Templates (Cross-Tenant) | P2 |
| 5 | Approval-Workflow für kritische Flag-Changes (nicht nur Retention) | P1.5 |
| 6 | Bulk-Test-Run für N Rules in einer Transaction | P2 |
| 7 | Audit-Log-Search-DSL (Google-Style Query) | P1.5 |

---

## 20. CHANGELOG

- **v0.1 (2026-04-17)** Erstentwurf gemeinsam mit `ARK_ADMIN_VOLLANSICHT_SCHEMA_v0_1.md` aus Mockup `mockups/admin.html`.
