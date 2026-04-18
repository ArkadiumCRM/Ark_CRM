# ARK CRM — Reminders Vollansicht Interactions v0.1

**Stand:** 2026-04-17
**Status:** Erstentwurf — Review ausstehend
**Quellen:**
- `specs/ARK_REMINDERS_VOLLANSICHT_SCHEMA_v0_1.md` (Begleit-Schema)
- `specs/ARK_REMINDERS_VOLLANSICHT_PLAN_v0_1.md` (Phase 0 Entscheidungen)
- `Grundlagen MD/ARK_BACKEND_ARCHITECTURE_v2_5.md` (§Reminders-Endpunkte Z. 1663–1671, §Worker 10, §Event-Typen)
- `Grundlagen MD/ARK_DATABASE_SCHEMA_v1_3.md` (§`fact_reminders` Z. 1282, §`fact_history`)
- `Grundlagen MD/ARK_STAMMDATEN_EXPORT_v1_3.md` (§64 `dim_reminder_templates`, §14 Activity-Types)
- `Grundlagen MD/ARK_FRONTEND_FREEZE_v1_10.md` (§Reminders · §Drawer-Default-Regel · §Datum-Eingabe-Regel)
- `mockups/reminders.html` (konkrete Drawer-IDs, Tab-Indices, Component-Klassen)
- `wiki/concepts/reminders.md` (Eskalationslogik)
- `wiki/concepts/interaction-patterns.md` (globale UI-Patterns — Referenz)

**Vorrang:** Stammdaten > Schema > dieses Interactions-Dokument > Frontend Freeze > Mockups

---

## 0. SCOPE

Verhaltens-Spezifikation der Reminders-Vollansicht (`/reminders`). Ergänzt `ARK_REMINDERS_VOLLANSICHT_SCHEMA_v0_1.md` (Struktur/Layout/Tokens) um: Flows · Events · Permissions-Matrix · State-Management · Keyboard · Empty/Error-States.

**Nicht-Ziel:** Auto-Regeln-Admin-Maske (`/admin/reminder-rules`) — separate Spec.

---

## 1. FUNKTIONEN PRO BEREICH

### 1a. Header / Page-Banner

| Element | Funktion | Endpoint | Event |
|---------|----------|----------|-------|
| `Scope: <current>` Switcher | Toggle zwischen `self` / `team` / `all` (rollen-gated) | GET `/api/v1/reminders?scope=…` mit Query-Param-Refresh | kein User-Event; URL-State-Update |
| `+ Reminder` Button | Öffnet `#remNewDrawer` | — | — |

**Scope-Switcher-Logik:**
- Klick auf Switcher zyklisch: `Eigene` → `Team` → (`Alle` nur Admin) → zurück zu `Eigene`
- Scope-Wechsel triggert Re-Fetch der Liste + KPI-Werte
- Server-seitig: 403 wenn User versucht, nicht-erlaubten Scope zu setzen
- URL-Param `?scope=team` wird gesetzt (deep-linkable, Bookmarkable)

### 1b. KPI-Strip (6 Cards)

Jede Card ist klickbar → setzt Status-Chip-Filter + (nur bei „Erledigt (30 d)") Archiv-Toggle on.

| Card | Klick-Aktion | Backend-Query |
|------|--------------|----------------|
| Offen | `filterStatus('all')` | `is_done=false AND scope-match` |
| Überfällig | `filterStatus('overdue')` | `is_done=false AND due_date < today` |
| Heute | `filterStatus('today')` | `due_date = today AND is_done=false` |
| Diese Woche | `filterStatus('week')` | `due_date BETWEEN today+1 AND today+7 AND is_done=false` |
| Später | `filterStatus('later')` | `due_date > today+7 AND is_done=false` |
| Erledigt (30 d) | `filterStatus('done')` | `is_done=true AND done_at >= today-30` |

Werte werden live aktualisiert nach jedem Complete/Snooze/Reassign (Optimistic + Re-Fetch auf Background).

### 1c. Saved-Views-Chips

| Aktion | Verhalten |
|--------|-----------|
| Klick auf Chip | Lädt gespeicherte Filter-/Scope-/View-Kombi · URL-Update · KPI-Re-Fetch |
| Klick auf aktiven Chip nochmal | Keine Aktion (idempotent) |
| Right-Click (Kontext-Menü) | nur User-defined Views: „Umbenennen" · „Löschen" · „Duplizieren" |
| Drag-and-Drop | Reihenfolge ändern (User-defined nur; System-Defaults fix) |
| `+ Neue Ansicht` | Öffnet Modal (ausnahmsweise Modal, kurze 1-Feld-Eingabe für Namen — siehe §4d) |

### 1d. View-Toggle (Liste / Kalender)

Switch persistiert als User-Pref (letzte Ansicht wiederhergestellt bei Re-Login) — Storage siehe §10.

### 1e. Filter-Bar

- Alle Filter kombinierbar (AND-verknüpft)
- Jeder Filter-Change → debounced 250 ms → Backend-Refetch
- Aktive Filter erscheinen als Tag-Chips unter Filter-Bar · Klick auf `✕` entfernt Filter
- `[Filter leeren]`-Button erscheint wenn ≥ 1 Filter aktiv

### 1f. Status-Chip-Tabs (nur Liste-Modus)

Exklusiv-Selektion (genau 1 aktiv). Wechsel setzt Sub-Filter auf Section-Groups (z.B. Chip „Heute" → nur Section „Heute" bleibt sichtbar, andere collapsed).

### 1g. Reminder-Row (Liste)

| Interaktion | Wirkung |
|-------------|---------|
| Klick auf Row (nicht auf Action-Buttons) | Öffnet `#remDetailDrawer` mit dieser Row-ID |
| Klick auf Entity-Badge | Navigation zur Entity-Detailseite oder -Drawer (je nach Entity-Typ) |
| Klick auf Typ-Chip | Setzt Filter „Typ" auf diesen Typ |
| Klick auf Mitarbeiter-Kürzel | Setzt Filter „Zuständig" auf diesen Mitarbeiter |
| Klick auf `[Erledigen]` | Optimistic Complete (siehe §2a) |
| Klick auf `[⏰ ▾]` | Öffnet Snooze-Popover (siehe §2b) |
| Hover | Row-background `var(--bg)`, Cursor pointer |
| Keyboard: `E` auf fokussierter Row | Complete |
| Keyboard: `S` auf fokussierter Row | Snooze-Popover öffnen |

### 1h. Reminder-Chip (Kalender)

| Interaktion | Wirkung |
|-------------|---------|
| Klick | Öffnet `#remDetailDrawer` |
| Drag auf anderen Tag | `PATCH /api/v1/reminders/:id` mit neuem `due_date` (Optimistic) |
| Hover | Tooltip mit Titel · Fälligkeit · Priority · Zuständig |

---

## 2. CRUD-FLOWS

### 2a. Complete (Erledigen)

**Trigger:** `[Erledigen]`-Button in Row, `E`-Keyboard, oder Footer-Button im Detail-Drawer.

**Flow:**
1. Client sendet `POST /api/v1/reminders/:id/complete` (kein Body nötig)
2. **Optimistic:** Row fadet aus Section, KPI „Offen" dekrementiert, „Erledigt (30 d)" inkrementiert, Toast „✓ Erledigt · Undo (5 s)"
3. Undo-Klick innerhalb 5 s: `PATCH /api/v1/reminders/:id` mit Body `{is_done: false, done_at: null, done_by: null}` — kein dedizierter Uncomplete-Endpoint (Audit-Trail per `fact_audit_log` `entity_updated`)
4. Backend schreibt: `fact_reminders.is_done=true, done_at=now(), done_by=current_user_id`
5. Lifecycle-Log: `fact_audit_log` schreibt `entity_updated` mit Field-Diff `is_done/done_at/done_by` (keine dedizierte `reminder_completed`-Event — siehe §8)
6. Bei Recurrence ≠ None: Worker erstellt neuen Reminder mit `due_date = old_due_date + interval`, `is_auto_generated=true`
7. Fehler-Rollback: Row wieder einblenden, KPI zurücksetzen, Toast „Fehler beim Erledigen · erneut versuchen"

**State-Transition:**
```
offen → (Complete) → erledigt → (Undo innerhalb 5 s) → offen
                               ↳ (nach 5 s commit) final
```

### 2b. Snooze

**Trigger:** `[⏰ ▾]`-Button in Row, `S`-Keyboard, oder Footer-Button im Detail-Drawer.

**Snooze-Optionen (Popover `.snooze-pop`):**
| Option | `due_date`-Anpassung |
|--------|----------------------|
| +1 Stunde | (nur wenn `due_time` gesetzt) `due_time += 1h`, evtl. Datum-Überlauf |
| +1 Tag | `due_date += 1 day` |
| +1 Woche | `due_date += 7 days` |
| Custom … | Öffnet Mini-Date-Picker (nativ `<input type="date">`), User wählt Datum |

**Flow:**
1. User klickt Option → `POST /api/v1/reminders/:id/snooze` mit Body `{duration: '1h'|'1d'|'1w'|<iso-date>}`
2. Optimistic: Row wechselt Section-Group (z.B. von „Heute" zu „Diese Woche"), Toast „⏰ Verschoben auf <neues Datum> · Undo"
3. Backend berechnet neue `due_date`, schreibt `fact_reminders.snooze_until = new_due_date`
4. Event: `reminder_snoozed` (bestehend) mit Payload `{old_due_date, new_due_date, duration}`
5. Fehler-Rollback analog Complete

### 2c. Reassign

**Trigger:** Nur im `#remDetailDrawer` Footer-Button `[👥 Reassign]`. Nur HoD+/Admin+ sichtbar.

**Flow:**
1. Klick öffnet Mitarbeiter-Select (scope-aware — nur Team-Mitglieder sichtbar, bei Admin tenant-weit)
2. User wählt → `POST /api/v1/reminders/:id/reassign` **(NEUER Endpoint — Phase 3 ergänzen)** mit Body `{new_assignee_id}`
3. Optimistic: Row-Mitarbeiter-Kürzel ändert sich
4. Backend: `fact_reminders.mitarbeiter_id = new_assignee_id`, Event `reminder_reassigned` (neu — Phase 3) mit `{old_assignee_id, new_assignee_id, reassigned_by}`
5. Optional: Notification an neuen Zuständigen („Dir wurde ein Reminder zugewiesen: …")

**Permission-Check (Server-side):**
- HoD darf nur innerhalb eigenes Team reassignen (eigenes Team = HoD-Zuordnung via `dim_team`)
- Admin darf tenant-weit
- AM/CM/RA/BO dürfen **nicht** reassignen (Button nicht gerendert)

### 2d. Neuer Reminder anlegen

**Trigger:** `+ Reminder` Button, Keyboard `N`, oder Deep-Link-Aufruf mit Query-Params.

**Drawer-Flow (`#remNewDrawer`):**

1. Drawer öffnet, Felder mit Defaults:
   - Zuständig: aktueller User
   - Priorität: `Medium`
   - Wiederholung: `Einmalig` (None)
   - Datum: `today + 1 day`
   - Uhrzeit: `09:00`
2. **Deep-Link-Vorbefüllung:**
   - URL `?template=rt_06` → Vorlagen-Select vorgewählt, `applyTemplate()` füllt Titel via Template-Map
   - URL `?entity=candidate&id=<uuid>` → Entity-Link-Typ = „Kandidat", Autocomplete vorbefüllt mit Namen
   - URL `?due=2026-04-20` → Datum vorgewählt
3. Template-Wechsel (onChange): `applyTemplate()` überschreibt `title`-Input mit Template-Text (map in `<script>`)
4. User füllt Pflicht-Felder: Titel (*), Datum (*), Zuständig (*)
5. Klick `[💾 Reminder anlegen]` → `POST /api/v1/reminders` mit Body:
   ```json
   {
     "title": "…",
     "description": "…",
     "mitarbeiter_id": "<uuid>",
     "due_date": "2026-04-20",
     "due_time": "17:00",
     "priority": "Medium",
     "reminder_type": "coaching"|"debriefing"|…,
     "template_id": "<uuid|null>",  // Phase 3: prüfen ob FK oder NULL bei Eigene-Eingabe
     "recurrence": "None",
     "candidate_id": "<uuid|null>",
     "account_id": "<uuid|null>",
     "mandate_id": "<uuid|null>",
     "job_id": "<uuid|null>",
     "process_id": "<uuid|null>",
     "push_reminder_minutes_before": 30|null
   }
   ```
6. Response 201 + neue Row: Drawer schliesst, Liste-Refetch, Toast „✓ Reminder angelegt", neue Row highlighted 2 s
7. Fehler 400/403/500: Drawer bleibt offen, Inline-Feld-Errors (z.B. „Datum liegt in Vergangenheit" — Warn, nicht Block), Fehler-Banner oben

**Validation (Client-side):**
- Titel: nicht leer, max 200 Zeichen
- Datum: min `today` (Warn bei Vergangenheit, kein Hard-Block — Reminder für vergangenes OK für Dokumentation)
- Priorität: enum aus 4 Werten
- Wiederholung: enum aus 4 Werten
- Entity-Link: wenn gesetzt, Autocomplete muss valides Match liefern (kein Freitext)

**Validation (Server-side):**
- Spiegelt Client + zusätzliche CHECK-Constraints lt. `fact_reminders` (CHECK priority, CHECK recurrence)
- `mitarbeiter_id` muss im gleichen Tenant sein
- FK-Prüfung für alle Entity-Refs

### 2e. Reminder bearbeiten

**Trigger:** Klick auf Reminder-Titel oder Row → `#remDetailDrawer` öffnet Tab „Übersicht".

**Inline-Edit-Strategie (lt. Interaction-Patterns):**
- Felder sind **live editierbar** (keine Explicit-Save-Button)
- Auf `blur` oder `Enter` (bei Text-Inputs) → `PATCH /api/v1/reminders/:id` mit geändertem Feld
- Optimistic Update · bei Fehler Rollback + Toast

**Felder editierbar (wer darf):**
| Feld | self | team | all |
|------|------|------|-----|
| Titel | eigene | HoD+ eigene Team | Admin+ |
| Beschreibung | dito | dito | dito |
| Datum/Uhrzeit | dito | dito | dito |
| Priorität | dito | dito | dito |
| Typ | dito | dito | dito |
| Zuständig | nie (→ Reassign-Flow §2c) | HoD+ | Admin+ |
| Quelle | nie (read-only) | nie | nie |
| Auto-generiert-Flag | nie | nie | nie |

### 2f. Löschen

**UI-Pfad:** Nicht verfügbar in dieser Maske.

**Admin-Pfad:** Nur über Admin-Tool `/admin/reminder-rules` (separater Scope) oder direkt DB — nicht Teil dieser Spec.

**Rationale:** Audit-Trail bleibt erhalten (`fact_reminders` behält Row, `is_done` + `done_by`). Löschen würde `fact_history`-Verknüpfungen kaputt machen.

### 2g. Drag-to-Reschedule (Kalender-Modus)

**Trigger:** User zieht Reminder-Chip im Monats-/Wochenraster auf anderen Tag.

**Flow:**
1. `dragstart` auf `.cal-chip` → speichert Reminder-ID in `dataTransfer`
2. `dragover` auf `.cal-cell` → zeigt Drop-Indicator (`outline: 2px dashed var(--accent)`)
3. `drop` → sendet `PATCH /api/v1/reminders/:id` mit neuem `due_date`
4. Optimistic: Chip wechselt Zelle sofort
5. Fehler-Rollback: Chip zurück + Toast

**Constraints:**
- Drag nur für eigene Reminders (self-scope); bei Team-Scope: HoD+
- Drag auf Tag in Vergangenheit: Warn-Toast „Datum liegt in Vergangenheit — trotzdem verschieben?" mit [Ja/Nein]

---

## 3. SAVED-VIEWS-VERWALTUNG

### 3a. Neue Ansicht speichern

**Trigger:** `+ Neue Ansicht` Chip → Modal (ausnahmsweise Modal, siehe Drawer-Default-Regel: kurze 1-Feld-Eingabe erlaubt).

**Flow:**
1. Modal zeigt: Name-Input (Placeholder „z.B. Mandats-Follow-ups"), Abbrechen · Speichern
2. Speichern → `POST /api/v1/user-preferences/saved-views` **(neuer Endpoint — Phase 3)** mit Body:
   ```json
   {
     "view_name": "…",
     "view_type": "reminders",
     "filters": { "type":"debriefing", "scope":"self", … },
     "view_mode": "list"|"calendar"
   }
   ```
3. Response 201 → neuer Chip erscheint rechts neben letzten User-View
4. Max 10 User-Views — bei Limit: Fehler-Toast „Max 10 Ansichten. Erst eine löschen."

### 3b. Ansicht umbenennen/löschen

**Trigger:** Right-Click auf User-View-Chip → Kontext-Menü.

System-Default-Views können **nicht** umbenannt/gelöscht werden (fix per Rollen-Seed).

### 3c. Standard-View-Aktivierung bei Page-Load

1. URL hat Query-Params? → diese haben Vorrang
2. Sonst: User-Pref `last_active_view` → diese aktivieren
3. Sonst: System-Default-View für Rolle (aus Schema §5a Tabelle)

---

## 4. STATE-MANAGEMENT

### 4a. URL-State (deep-linkable)

Alle Filter/Scope/View als Query-Params abgebildet:
```
/reminders?scope=team&view=list&status=overdue&type=debriefing&assignee=JV&entity=candidate&id=<uuid>&from=2026-04-15&to=2026-04-22
```

**Präzedenz-Logik:**
1. URL-Params > User-Pref > System-Default-View
2. Jeder Filter-Wechsel pusht neuen History-Entry (Back-Button funktioniert)

### 4b. User-Preferences

**Storage-Entscheidung (Phase 3 geklärt):** keine neue Tabelle. Nutze bestehendes Feld `dim_mitarbeiter.dashboard_config jsonb` (DB-Schema Z. 1457) mit folgendem Schema-Ausschnitt:

```json
{
  "reminders": {
    "last_active_scope": "self|team|all",
    "last_active_view": "list|calendar",
    "last_active_saved_view_key": "mein-tag|<user-defined-uuid>",
    "push_notification_defaults": {
      "minutes_before": 30,
      "channels": ["in-app","email"]
    },
    "saved_views": [
      {
        "id": "<uuid>",
        "name": "Mandats-Follow-ups",
        "created_at": "2026-04-17T10:00:00Z",
        "filters": {
          "scope": "self",
          "type": "followup",
          "entity_type": "mandate"
        },
        "view_mode": "list",
        "sort_index": 0
      }
    ]
  }
}
```

System-Default-Views (rollen-spezifisch) werden **nicht** in dashboard_config gespeichert — sie sind per Code/Seed-Konstante je Rolle definiert und beim Page-Load aus Rollen-Kontext resolved.

### 4c. Optimistic-Update-Policy

**Erlaubt (lt. FRONTEND_FREEZE):**
- Complete, Snooze, Reassign, Inline-Edit in Detail-Drawer, Drag-to-Reschedule

**Nicht-Optimistic (Server-Wait + Spinner):**
- Neuer Reminder anlegen (POST) — weil ID vom Server kommt
- Saved-View erstellen (POST)

### 4d. Optimistic-Locking

`fact_reminders` hat `updated_at` (lt. Schema-Convention). Bei PATCH:
- Client sendet `If-Unmodified-Since: <updated_at>`
- Server 409 wenn Record inzwischen geändert → Client zeigt Merge-Konflikt-Toast „Dieser Reminder wurde gerade von <user> bearbeitet. Neu laden?" mit [Neu laden / Meine Änderungen verwerfen]

---

## 5. VERKNÜPFUNGEN

### 5a. Entity-Deep-Links

| Badge-Klick | Ziel |
|-------------|------|
| 👤 Kandidat | `/candidates/<id>` Detailseite (Tab 1) |
| 🏢 Account | `/accounts/<id>` Detailseite |
| 🎯 Mandat | `/mandates/<id>` Detailseite |
| 💼 Job | `/jobs/<id>` Detailseite |
| 🔄 Prozess | Öffnet Prozess-Slide-in-Drawer (lt. FRONTEND_FREEZE v1.10 Prozess-Mischform) |

### 5b. Back-Navigation aus Entity-Kontext

Entity-Tab-Reminders (Kandidat §10, Account §13) linken mit `?entity=<type>&id=<uuid>` zurück in Vollansicht — Vollansicht filtert automatisch auf diese Entity und zeigt Breadcrumb-Addendum:

```
Home / Reminders / <Entity-Name>
```

### 5c. Dashboard-Widget-Link

„→ Alle Reminders (N offen)" auf Dashboard linkt auf `/reminders?scope=self&status=all` (ohne Entity-Filter).

---

## 6. AUTOMATIONEN

### 6a. Auto-Reminder-Generierung

Worker `reminder.worker.ts` (`ARK_BACKEND_ARCHITECTURE_v2_5.md` §Worker 10) erzeugt Reminders aus `dim_reminder_templates` bei Trigger-Events:

| Template-Key | Trigger-Event | Offset | Empfänger |
|--------------|---------------|--------|-----------|
| rt_01 onboarding_call | `placement_confirmed` | start_date − 7 d | CM |
| rt_02 placement_1m | `placement_confirmed` | placed_at + 1 Mt | CM |
| rt_03 placement_2m | `placement_confirmed` | placed_at + 2 Mt | CM |
| rt_04 placement_3m | `placement_confirmed` | placed_at + 3 Mt | CM + AM |
| rt_05 guarantee_end | `placement_confirmed` | placed_at + garantie_months | AM + CM |
| rt_06 interview_coaching | `interview_scheduled` | scheduled_at − 2 d | CM |
| rt_07 interview_debriefing | `interview_scheduled` | scheduled_at (Abend) | CM |
| rt_08 interview_date_missing | `stage_changed` zu TI/1st/2nd/3rd | stage_changed_at + 2 d | CM |
| rt_09 briefing_missing | `candidate_created` | created_at + 7 d | CM |
| rt_10 info_request_auto_extend | `protection_info_requested` | info_requested_at + daily | AM |

Worker setzt `is_auto_generated=true`, speichert `reminder_type` gemäss Template-Key. UI zeigt `⚙ Auto`-Badge mit Tooltip zur Trigger-Beschreibung.

### 6b. Eskalations-Logik (aus `wiki/concepts/reminders.md`)

Worker prüft stündlich (oder via Event `reminder.worker.tick`):

| Schwelle | Aktion |
|----------|--------|
| `due_date < today` und seit 24 h | Push-Notification an Zuständigen (Kanal: In-App + Email) |
| `due_date < today` und seit 48 h | Notification an Head of des Zuständigen + Event `reminder_overdue_escalation` (neu — Phase 3) |
| Wöchentlich | KPI-Report an Admin: überfällige Reminders pro Mitarbeiter (separater Report, nicht UI) |

### 6c. Auto-Cleanup

**Nicht in Phase 1.** Phase-2-Kandidat: erledigte Reminders > 180 d automatisch in Kalt-Archiv-Tabelle umziehen (Performance).

---

## 7. CONSTRAINTS / ZWÄNGE

| Constraint | Durchsetzung |
|------------|--------------|
| Nur eigene Reminders write-bar (ohne Scope-Rechte) | Server 403, Client Button disabled |
| Erledigte Reminders nicht mehr editierbar | Client: Edit-Mode disabled; Server: 409 bei PATCH |
| Auto-generierte Reminders: `is_auto_generated`-Flag read-only (nie umschaltbar) | Server ignoriert PATCH auf Feld |
| Recurrence + bereits erledigt: Worker erzeugt Nachfolge-Reminder | automatisch |
| Reassign auf User ohne Berechtigung | Server 400: „Empfänger hat keinen Reminder-Read-Zugriff" |
| Snooze auf Datum in Vergangenheit | Client: Warn-Toast, aber erlaubt (für Dokumentations-Zwecke) |
| Max 10 Saved Views pro User | Client-Block bei Limit + Toast |

---

## 8. EVENTS

**Pattern-Entscheidung (Phase 3 geklärt):** Nach `ARK_BACKEND_ARCHITECTURE_v2_5.md` Z. 91 („CRUD-Events werden **nicht** als dedizierte Event-Typen geführt — abgedeckt durch `fact_audit_log` mit generischem `entity_updated` + Field-Diff"): Lifecycle-Aktionen (Create/Complete/Snooze/Update) **nicht** als eigene Event-Typen, sondern über Audit-Log. Nur Business-Events mit Notification-Trigger oder Cross-Entity-Scope sind dediziert.

### 8a. Dedizierte Events (via `fact_event_queue`)

| Event | Neu? | Trigger | Scope | Payload (Kern) |
|-------|------|---------|-------|----------------|
| `reminder_batch_created` | ✓ bestehend (BACKEND Z. 86) | Placement-Saga TX1 Step 7 | Kandidat + Account | `process_id, candidate_id, account_id, reminder_ids[], template_keys[]` |
| `reminder_reassigned` | **NEU** | POST `/api/v1/reminders/:id/reassign` | self + both parties | `reminder_id, old_assignee_id, new_assignee_id, reassigned_by` |
| `reminder_overdue_escalation` | **NEU** | Worker bei 48 h überfällig | self + head_of | `reminder_id, overdue_hours, escalated_to, notification_sent` |

### 8b. Audit-Log-Pattern (via `fact_audit_log` `entity_updated`)

Folgende Aktionen erzeugen **kein** dediziertes Event, sondern einen `entity_updated`-Audit-Log-Eintrag mit Field-Diff auf `fact_reminders`:

| Aktion | Field-Diff | Equivalent (Legacy-Namen in v0.1-Draft) |
|--------|------------|------------------------------------------|
| Reminder anlegen | alle Pflicht-Felder | ehemals „reminder_created" |
| Reminder erledigen | `is_done: false → true, done_at, done_by` | ehemals „reminder_completed" |
| Reminder snoozen | `due_date, snooze_until` | ehemals „reminder_snoozed" |
| Inline-Edit (Titel/Beschreibung/Priority/Typ/Datum) | entsprechende Felder | ehemals „reminder_updated" |
| Uncomplete (Undo innerhalb 5 s) | `is_done: true → false, done_at: → null` | implizit via Audit-Log |

**Vorteil:** kein Events-Explosion bei CRUD, volle Historie via Audit-Log-Field-Diff rekonstruierbar. Historie-Tab im Detail-Drawer rendert Audit-Log-Einträge für diesen `reminder_id` chronologisch.

### 8c. Sync-Status zu BACKEND

- `reminder_batch_created` ✓ bereits dokumentiert
- `reminder_reassigned` + `reminder_overdue_escalation` → **in Phase 3 in `ARK_BACKEND_ARCHITECTURE_v2_5.md` §A Event-Typen ergänzen**
- Lifecycle-Events nicht mehr ergänzen (Audit-Pattern)

---

## 9. PERMISSIONS-MATRIX

Vollständige Auflösung aus Schema §10b/c:

| Aktion | AM/CM/RA/BO | HoD | Admin |
|--------|-------------|-----|-------|
| Eigene Reminders lesen | ✓ | ✓ | ✓ |
| Team-Reminders lesen | ✗ | ✓ (eigenes Team) | ✓ (alle Teams) |
| Tenant-weit lesen (Scope=all) | ✗ | ✗ | ✓ |
| Eigene Reminders Complete/Snooze/Edit | ✓ | ✓ | ✓ |
| Fremde Team-Reminders Complete/Snooze/Edit | ✗ | ✓ (eigenes Team) | ✓ |
| Tenant-weit Complete/Snooze/Edit | ✗ | ✗ | ✓ |
| Reassign (eigene → andere) | ✗ | ✓ (ins eigene Team) | ✓ (tenant-weit) |
| Neue Reminders anlegen (für sich) | ✓ | ✓ | ✓ |
| Neue Reminders anlegen (für andere) | ✗ | ✓ (eigenes Team) | ✓ |
| Saved Views erstellen (eigene) | ✓ | ✓ | ✓ |
| Saved Views für Team erstellen | ✗ | Phase 2 Entscheidung | Phase 2 |
| Auto-Regeln bearbeiten | ✗ | ✗ | ✓ (via `/admin/reminder-rules`) |
| Löschen | ✗ | ✗ | ✗ (UI) · ✓ (Admin-Tool) |

### 9a. Server-Enforcement

Jeder Endpoint prüft:
1. User-ID extrahieren aus Token
2. User-Rolle + Team-Mitgliedschaft laden (siehe §9b Team-Definition)
3. Action gegen Permissions-Matrix prüfen
4. 403 Forbidden bei Verstoss, mit Body `{reason: "insufficient_scope"|"not_in_team"|"role_missing"}`

### 9b. Team-Definition (Phase 3 geklärt)

Team basiert auf **`dim_mitarbeiter.vorgesetzter_id`** (DB-Schema Z. 1454) — nicht auf `dim_mitarbeiter.team text` (Freitext, für Reporting/Labelling, nicht für Permissions).

**Scope-Resolution-Queries:**

| Scope | SQL-Ausdruck (vereinfacht) |
|-------|-----------------------------|
| `self` | `mitarbeiter_id = :current_user_id` |
| `team` (HoD-Perspektive) | `mitarbeiter_id IN (SELECT id FROM dim_mitarbeiter WHERE vorgesetzter_id = :current_user_id) OR mitarbeiter_id = :current_user_id` |
| `all` (Admin-Perspektive) | `tenant_id = :current_user_tenant_id` (alle) |

**Rollen-Mapping zur Scope-Zulässigkeit:**

| `dim_mitarbeiter.rolle_type` | Max-erlaubter Scope |
|------------------------------|---------------------|
| `Candidate_Manager` / `Account_Manager` / `Researcher` / `Backoffice` / `Assessment_Manager` | `self` |
| `Head_of` | `team` |
| `Admin` | `all` |

Bei Multi-Rollen (via `bridge_mitarbeiter_roles`) gilt der höchste Scope aus den aktiven Rollen.

---

## 10. DRAWERS / MODALS

### 10a. `#remDetailDrawer` (540 px, slide-in rechts)

**Tabs (5):** Übersicht · Historie · Verknüpfungen · Wiederholung · Push

**State bei Open:**
- Tab-Index aus URL-Param `?tab=<0-4>` oder Default 0
- Felder live-fetched via `GET /reminders/:id`
- Inline-Edit aktiv (siehe §2e)

**Footer-Buttons (kontext-abhängig):**
| Button | Sichtbar wenn |
|--------|---------------|
| Abbrechen | immer |
| 👥 Reassign | HoD+ und Reminder im Team-Scope oder Admin+ |
| ⏰ Snooze ▾ | Reminder nicht erledigt und User hat Edit-Permission |
| ✓ Erledigen (primary) | dito |

**Close-Verhalten:**
- `✕`-Button, Backdrop-Klick, oder `Esc` → Drawer schliesst
- Bei pending Inline-Edit: kein Prompt nötig (Auto-Save on blur)

### 10b. `#remNewDrawer` (540 px, slide-in rechts)

**State bei Open:**
- Felder leer / Default-Werte (siehe §2d Schritt 1)
- Deep-Link-Vorbefüllung aktiv (siehe §2d Schritt 2)

**Close-Verhalten:**
- Wenn Felder gefüllt und nicht gespeichert: Navigation-Guard-Prompt „Änderungen verwerfen?" [Abbrechen / Verwerfen]
- Nach `saveReminder()`: Auto-Close

### 10c. `+ Neue Ansicht` Modal

**Ausnahme zur Drawer-Default-Regel** (CLAUDE.md §Drawer-Default-Regel):
- Kurze 1-Feld-Eingabe (nur Name) → Modal erlaubt
- Breite 320 px, zentriert, Backdrop

**Fields:**
- Name-Input (Placeholder, Max 50 Zeichen)
- Buttons: Abbrechen (ghost) · Speichern (primary)

---

## 11. EMPTY & ERROR STATES

### 11a. Empty States (Schema §11 konkretisiert)

| Zustand | Anzeige | CTA |
|---------|---------|-----|
| 0 Reminders total | Zentrierter Block mit 🔔-Icon (60×60) + „Keine Reminders. Lege deinen ersten an." | `[+ Reminder]` primary |
| Alle erledigt, 0 offen | „🎉 Alles erledigt! Nichts mehr offen in deinem Scope." | `[Erledigte anzeigen ▾]` secondary |
| Filter-Kombi leer | „Keine Reminders mit diesen Filtern." | `[Filter leeren]` |
| Kalender-Monat ohne Reminder | Zentriertes Placeholder in Monatsraster | `[+ Reminder anlegen]` |
| Erledigt-Chip aktiv, 0 in 30 d | „Keine erledigten Reminders in den letzten 30 Tagen." | `[Älteres anzeigen ▾]` |

### 11b. Error States

| Error | UI-Verhalten |
|-------|--------------|
| Netzwerk-Timeout bei Liste-Fetch | Skeleton-Loader verschwindet, Fehler-Banner oben „Verbindung unterbrochen. [Neu laden]" |
| 403 Forbidden bei Scope-Switch | Toast „Kein Zugriff auf diesen Scope" + Switcher fällt auf vorherigen Wert zurück |
| 500 Server-Error bei POST | Drawer bleibt offen, Banner rot oben im Drawer „Fehler beim Speichern. [Erneut versuchen]" |
| 409 Optimistic-Lock bei PATCH | Toast mit Merge-Prompt (siehe §4d) |
| Rate-Limit | Toast „Zu viele Anfragen. Einen Moment bitte." |

---

## 12. KEYBOARD-SHORTCUTS

Scope: aktiv wenn Focus **nicht** in Input/Textarea/contenteditable.

| Key | Aktion |
|-----|--------|
| `N` | Öffnet `#remNewDrawer` |
| `V` | Toggelt Liste ↔ Kalender |
| `J` | Navigiert zur nächsten Row (Liste) / nächsten Tag (Kalender) |
| `K` | Navigiert zur vorherigen Row / vorherigen Tag |
| `Enter` | Öffnet Detail-Drawer für fokussierte Row |
| `E` | Erledigen für fokussierte Row |
| `S` | Öffnet Snooze-Popover für fokussierte Row |
| `R` | Öffnet Reassign-Select (nur berechtigte Rollen) |
| `1`…`6` | Status-Chip-Tab 1–6 (Alle/Überfällig/Heute/Woche/Später/Erledigt) |
| `Esc` | Schliesst offenen Drawer / Popover |
| `Cmd/Ctrl + K` | Global Command Palette (System-Shortcut, nicht Page-spezifisch) |

**Focus-Management:**
- Bei Page-Load: Focus auf erste Row in Überfällig (falls vorhanden), sonst erste Row Heute, sonst Drawer-CTA
- Nach Complete/Snooze: Focus auf nächste Row
- Drawer-Close: Focus auf vorherige Row

---

## 13. INTEGRATIONS-TESTS (für QA)

Kritische Flows zu decken:

1. **Scope-Gating:** AM loggt ein, Scope-Switcher darf nicht sichtbar sein. HoD sieht Switcher, max `team`. Admin sieht `all`.
2. **Complete + Undo:** Row erledigen, innerhalb 5 s Undo klicken → Row wieder in offener Liste.
3. **Snooze-Section-Wechsel:** Reminder heute snoozen +1 Woche → erscheint in „Diese Woche" (falls ≤ 7 d) oder „Später".
4. **Auto-Reminder-Darstellung:** Worker erzeugt rt_06-Reminder → erscheint mit `⚙ Auto`-Badge, `reminder_type=coaching`.
5. **Deep-Link aus Entity-Tab:** `/reminders?entity=candidate&id=<x>` → Liste gefiltert, Breadcrumb mit Kandidat-Name.
6. **Drag-to-Reschedule Kalender:** Chip ziehen → Backend-PATCH, Optimistic-Update.
7. **Saved-View:** 3 Filter setzen, speichern, anderer Tag öffnen → Chip klicken → Filter restored.
8. **Reassign-Permission:** AM versucht Reassign → Button nicht sichtbar. HoD versucht Reassign auf fremdes Team → 403.
9. **Optimistic-Lock:** 2 HoDs editieren gleichen Reminder gleichzeitig → zweiter bekommt 409 + Merge-Prompt.
10. **Erledigt-Archive:** Reminder vor 31 d erledigt → nicht sichtbar; Toggle „Älteres anzeigen" → wird sichtbar.

---

## 14. OFFENE FRAGEN (für v0.2)

Ergänzend zu Schema §16:

1. **Undo-Fenster:** 5 s fix oder konfigurierbar via User-Pref?
2. **Push-Kanäle:** SMS in Phase 1 oder später? (Backend-Worker unterstützt laut §Worker 9 `notification.worker.ts` schon Push/In-App/SMS)
3. **Reassign-Notification:** Empfänger bekommt Email + In-App, oder nur In-App?
4. **Recurrence-Enddatum:** lt. Drawer-Tab „Wiederholung" gibt es kein Enddatum-Feld — soll das in v0.2 ergänzt werden? (Stammdaten §64 hat `recurrence` CHECK in 4 Werten, aber kein `recurrence_end`)
5. **Merge-Konflikt-UX:** automatisches Feld-weises Merging oder harter Choice „Deine Änderungen / Server-Stand"?
6. **Mobile:** Gesture-Support für Complete/Snooze (Swipe) — v2 oder nie?

---

## Related

- [[reminders]] (Konzept)
- [[interaction-patterns]] (globale UI-Patterns — Save-Strategy, Navigation-Guard, Optimistic-Update)
- [[frontend-freeze]] §Reminders · §Drawer-Default-Regel · §Datum-Eingabe-Regel
- [[spec-sync-regel]]
- `specs/ARK_REMINDERS_VOLLANSICHT_SCHEMA_v0_1.md`
- `specs/ARK_REMINDERS_VOLLANSICHT_PLAN_v0_1.md`
