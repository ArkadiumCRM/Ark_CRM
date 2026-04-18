---
title: "Reminders Vollansicht — Ausarbeitungsplan v0.1"
type: meta
created: 2026-04-17
updated: 2026-04-17
sources: ["ARK_FRONTEND_FREEZE_v1_10.md", "ARK_BACKEND_ARCHITECTURE_v2_5.md", "ARK_DATABASE_SCHEMA_v1_3.md", "ARK_STAMMDATEN_EXPORT_v1_3.md", "wiki/concepts/reminders.md"]
tags: [plan, reminders, tool-maske, vollansicht]
---

# Reminders Vollansicht (`/reminders`) — Ausarbeitungsplan v0.1

**Zweck:** Cross-Entity, user-/teamzentrierte Vollansicht aller Reminders — ergänzt (nicht ersetzt) Dashboard-Widget + Entity-Reminder-Tabs.

**Einordnung:** Tool-Maske (analog `/operations/dok-generator`, `/operations/email-kalender`). Keine Entity-Bindung. Zwei Spec-Dokumente Pflicht lt. [detailseiten-guideline](../wiki/meta/detailseiten-guideline.md).

**Status:** Entscheidungen Phase 0 geklärt — bereit für Spec-/Mockup-Phase.

---

## Bestand (bereits in Grundlagen definiert)

| Layer | Fundort |
|-------|---------|
| DB `fact_reminders` | `ARK_DATABASE_SCHEMA_v1_3.md` §fact_reminders (Z. 1282) |
| Stammdaten `dim_reminder_templates` (10 Vorlagen) | `ARK_STAMMDATEN_EXPORT_v1_3.md` §64 |
| API-Endpunkte (GET/POST/PATCH/complete/snooze) | `ARK_BACKEND_ARCHITECTURE_v2_5.md` §Reminders (Z. 1663) |
| Worker `reminder.worker.ts` | `ARK_BACKEND_ARCHITECTURE_v2_5.md` §Worker 10 |
| Route `/reminders` + Top-Nav-Eintrag | `ARK_FRONTEND_FREEZE_v1_10.md` §Routing |
| Dashboard-Widget "Meine überfälligen Reminders" | `mockups/dashboard.html` Z. 617 |
| Entity-Tab-Pattern (KPI/Filter/Status-Chips/Section-Groups) | `mockups/candidates.html` Tab 10 (Z. 4720) |
| Wiki-Konzept `reminders.md` | `wiki/concepts/reminders.md` |

**Fehlt:** Vollansicht-Spec + Mockup + Wiki-Erweiterung.

---

## Phase 0 — Entscheidungen (geklärt 2026-04-17)

| # | Entscheidung | Ausgang |
|---|--------------|---------|
| 1 | Scope-Default | Admin/Head-of: `eigene + Team` als Default + Scope-Switcher. AM/CM/RA/BO: **nur eigene**, kein Switcher sichtbar |
| 2 | View-Modus | **Liste + Kalender-Toggle**. Kein Kanban |
| 3 | Bulk-Actions | **Keine Bulk-Actions** — Sales-Team würde nur Bulk-Snoozen ohne Prüfung |
| 4 | Saved Views | **Ja, rollen-spezifisch** — HoD/Admin sehen andere Default-Views als AM/CM/RA/BO |
| 5 | Kalender-Integration | **CRM-intern** — kein Outlook-Sync in Reminders-Vollansicht (sonst Outlook-Kalender überladen). Outlook-Sync bleibt in `/operations/email-kalender` |
| 6 | Auto-Regeln verwalten | **Admin-Bereich separat** — gehört in Admin-Rules, nicht in Reminders-Vollansicht |
| 7 | Archiv-Cut | **Erledigte > 30 Tage ausblenden**, aber via Filter/Toggle erreichbar. Kein Hard-Delete (Audit-Trail) |

### Abgeleitete Rollen-Defaults

| Rolle | Default-Scope | Default-Saved-View |
|-------|--------------|---------------------|
| Admin | eigene + Team | "Team-Übersicht" (Überfällig aggregiert) |
| Head of | eigene + Team | "Team-Workload" (Überfällig + Heute aller zugeordneten Mitarbeiter) |
| AM / CM | eigene | "Mein Tag" (Heute + Überfällig) |
| RA (Research) | eigene | "Kandidaten-Refresh + Briefing" |
| BO (Backoffice) | eigene | "Garantie + Check-Ins" |

---

## Phase 1 — Spec-Dokumente

**Neue Dateien:**
```
specs/ARK_REMINDERS_VOLLANSICHT_SCHEMA_v0_1.md
specs/ARK_REMINDERS_VOLLANSICHT_INTERACTIONS_v0_1.md
```

### Schema-Inhalt (nach detailseiten-guideline)

- **Zielbild** — cross-entity Task-Management für Sales-Team
- **Layout** — Header · KPI-Strip (6 Cards) · View-Toggle (Liste/Kalender) · Filter-Bar · Saved-Views-Chips · Status-Chip-Tabs · Hauptbereich
- **Feld-Inventar** — pro Reminder-Row: Checkbox, Titel+Sub, Typ-Chip, Entity-Badge (klickbar), Fälligkeit, Priority-Dot, Mitarbeiter-Kürzel, Action-Button
- **Empty States** — (a) keine Reminders überhaupt · (b) alle erledigt · (c) Filter leer · (d) Kalender-Woche ohne Reminder
- **Berechtigungs-Differenzierung**
  - Scope-Switcher: nur Admin/HoD sichtbar
  - "Alle Reminders" (tenant-weit): nur Admin
  - Reassign: nur HoD+ (für eigenes Team), Admin (alle)
- **Design-Tokens**
  - Priority-Dots: Urgent (rot-plain) · High (rot-outline) · Medium (gelb) · Low (grau)
  - Overdue-Row: `border-left: 3px solid var(--red)`
  - Today-Row: `border-left: 3px solid var(--amber)`
  - Wiederverwendung der Entity-Tab-Tokens aus `candidates.html` Tab 10

### Interactions-Inhalt

- **CRUD-Flows**
  - Erstellen: Drawer 540px "Neuer Reminder" (aus jedem Screen via globalem Shortcut `N`)
  - Bearbeiten: Drawer 540px, Inline-Edit der Top-Felder
  - Complete: Inline-Button "Erledigen" (Optimistic Update)
  - Snooze: Dropdown +1h / +1d / +1w / Custom-Datum (Optimistic)
  - Reassign: nur für berechtigte Rollen, Select auf Mitarbeiter-Kürzel
  - Delete: nicht im UI (nur is_done=true toggeln, Admin-Lösch-Pfad in separatem Admin-Tool)
- **Save-Strategie** — Optimistic Update erlaubt (lt. FRONTEND_FREEZE)
- **Validation** — Pflicht: title, mitarbeiter_id, due_date. Priority-Default Medium, Recurrence-Default None
- **Verknüpfungen**
  - Klick Entity-Badge → Deep-Link zu Detailseite oder Drawer (Kandidat/Account/Mandat/Job/Prozess)
  - Klick Reminder-Titel → Reminder-Detail-Drawer (540px)
  - Footer-Link von Entity-Tab → `/reminders?entity=<type>&id=<uuid>` (gefiltert)
- **Automationen** — Auto-Reminder durch Worker, im UI read-only mit Badge "⚙ Auto"; Quelle anzeigen (Trigger)
- **Events** — write: `reminder_created` · `reminder_completed` · `reminder_snoozed` · `reminder_reassigned` (neu) · `reminder_overdue_escalation` (neu, worker-seitig)
- **Permissions-Matrix** — separate Sub-Tabelle pro Rolle (eigene read/write, fremde read, reassign)
- **Drawers**
  - Reminder-Detail-Drawer (Titel-Click): 5 Sub-Tabs — Übersicht · Historie · Verknüpfungen · Wiederholung · Erinnerungs-Push
  - Neuer-Reminder-Drawer: Vorlage (dim_reminder_templates als Select) · Titel · Beschreibung · Datum/Uhrzeit (nativer Picker + Keyboard-Input lt. Datum-Eingabe-Regel 14.04.2026) · Priorität · Recurrence · Entity-Link (Autocomplete über 5 Entity-Typen) · Zuständig · Erinnerungs-Push
- **Kalender-View** — Monats- + Wochenraster, Reminder als farbige Chips (Typ-Farbe), Drag-to-Reschedule via Drop-Zone (emits PATCH /reminders/:id {due_date})
- **Saved Views** — Storage: neue Stammdaten-/User-Pref-Tabelle (s. Phase 3 Sync-Check). Rollen-Defaults siehe oben.
- **Keyboard-Shortcuts**
  - `N` neu · `Enter` Detail öffnen · `E` erledigen · `S` snooze-Dropdown · `R` reassign · `J/K` navigieren · `1..5` Status-Chip-Tabs · `V` View-Toggle Liste/Kalender

---

## Phase 2 — Mockup `mockups/reminders.html`

**Reuse shared components:**
- Top-Nav via `_shared/layout.js`
- Drawer-Standard 540px (Regel 14.04.2026)
- Datum-Eingabe: nativer Picker + Keyboard (Regel 14.04.2026)
- Entity-Tab-Pattern aus `candidates.html` Tab 10 als Basis

**Neue Struktur:**

```
┌──────────────────────────────────────────────────────────┐
│ Breadcrumb: Reminders                                    │
│ H1: Reminders          [Scope: Eigene ▾] [+ Reminder]   │
├──────────────────────────────────────────────────────────┤
│ KPI-Strip (6 cards):                                     │
│  Offen · Überfällig · Heute · Diese Woche · Später ·    │
│  Erledigt (30 d)                                         │
├──────────────────────────────────────────────────────────┤
│ Saved-Views-Chips: [Mein Tag] [Mein Montag] [...] [+ Neu]│
├──────────────────────────────────────────────────────────┤
│ View-Toggle: [Liste] [Kalender]                          │
├──────────────────────────────────────────────────────────┤
│ Filter-Bar:                                              │
│  Suche · Typ · Zuständig · Quelle · Entity-Typ ·         │
│  Datums-Range · Priority · Recurrence                    │
├──────────────────────────────────────────────────────────┤
│ Status-Chip-Tabs (Liste-Modus):                          │
│  Alle offenen · ● Überfällig · Heute · Diese Woche ·    │
│  Später · Erledigt                                       │
├──────────────────────────────────────────────────────────┤
│ Liste-Modus: Section-Groups (Überfällig/Heute/Woche/    │
│              Später/Erledigt-collapsed) mit Data-Table  │
│                                                          │
│ Kalender-Modus: Monatsraster (Default) + Wochen-Toggle  │
│                 Reminder-Chips pro Tag, Click → Detail  │
└──────────────────────────────────────────────────────────┘
```

**Drawers (beide 540px):**
- `#reminderDetailDrawer` — Titel-Click
- `#reminderNewDrawer` — "+ Reminder" oder Shortcut `N`

**Lint-kritisch (Hooks scannen automatisch):**
- Umlaute echt (`ä`/`ö`/`ü`/`ß`) — `umlaute-lint`
- Keine DB-Tech in User-Texten (kein `fact_reminders`/`is_done`/etc.) — `db-techdetails-lint`
- Stammdaten-Wording: Typ-Chips nur aus `dim_reminder_templates` + Activity-Types — `stammdaten-lint`
- Drawer-Default 540px — `drawer-default-guard`
- Shared-Pattern-Konsistenz — `mockup-drift-check`

---

## Phase 3 — Grundlagen-Sync-Matrix

Prüfen/Ergänzen:

| Grundlage | Nötige Änderung | Neu? |
|-----------|-----------------|------|
| `ARK_FRONTEND_FREEZE_v1_10.md` | Tool-Masken-Kapitel erweitern (Reminders als 3. Tool-Maske neben Dok-Gen + Email-Kalender). Keyboard-Shortcuts-Tabelle um Reminder-Screen. | ergänzen |
| `ARK_BACKEND_ARCHITECTURE_v2_5.md` | Events `reminder_reassigned` + `reminder_overdue_escalation` prüfen, ggf. ergänzen. Endpoint `POST /reminders/:id/reassign` dokumentieren. | prüfen + evtl. ergänzen |
| `ARK_DATABASE_SCHEMA_v1_3.md` | Prüfen ob `fact_reminders.template_id uuid REFERENCES dim_reminder_templates(id)` ergänzt werden soll (derzeit nur `reminder_type text` — FK macht Template-Wechsel sauberer). Ggf. `fact_user_preferences` / `fact_saved_views`-Tabelle für Saved Views. | prüfen + evtl. ergänzen |
| `ARK_STAMMDATEN_EXPORT_v1_3.md` | UI-Label-Vocabulary §16 mockup-baseline.md: Reminder-Kategorie-Labels ergänzen (Follow-up, Interview-Coaching, Debriefing, Schutzfrist, Onboarding, Check-In, Garantie, Kandidaten-Refresh, Custom) | ergänzen in `wiki/meta/mockup-baseline.md` |
| `ARK_GESAMTSYSTEM_UEBERSICHT_v1_3.md` | Changelog-Eintrag "v1.3.x: Reminders Tool-Maske + Vollansicht ergänzt" | ergänzen |

---

## Phase 4 — Wiki-Update

- `wiki/concepts/reminders.md` — Section "Vollansicht `/reminders`" ergänzen (Abgrenzung zu Entity-Tab + Dashboard-Widget, Rollen-Scope-Logik, Saved-Views-Konzept)
- `wiki/meta/detailseiten-inventar.md` — Tool-Masken-Liste: 2 → 3 (+ Reminders)
- `wiki/meta/spec-sync-regel.md` — "2 Tool-Masken" → "3 Tool-Masken" (Reminders dazu)
- `wiki/meta/mockup-baseline.md` §16 — Reminder-Typ-Labels ins UI-Label-Vocabulary aufnehmen
- `index.md` — neue Spec-Pages + geänderte Konzept-Page eintragen
- `log.md` — Eintrag `[2026-04-XX] create | Reminders Vollansicht Spec + Mockup`

---

## Phase 5 — Entity-Tab-Harmonisierung

Ziel: Entity-Reminder-Tabs (Kandidat Tab 10, Account Tab 13 NEU, ggf. weitere) behalten Entity-Scope, linken aber sauber in die Vollansicht.

**Änderungen:**
- Footer-Link in jedem Entity-Reminder-Tab: **"→ Alle Reminders (entity-gefiltert)"** → `/reminders?entity=<type>&id=<uuid>`
- Deep-Link-Kontrakt (Query-Params) spezifizieren:
  - `entity=candidate|account|mandate|job|process`
  - `id=<uuid>`
  - `scope=self|team|all` (optional, rollen-gated)
  - `view=list|calendar`
  - `filter=overdue|today|week|later|done`
- Footer-Link in Dashboard-Widget "Meine überfälligen Reminders" bereits vorhanden (`→ Alle Reminders (12 offen)`) — auf neue Route-Params prüfen

**Konsistenz-Check:** bei welchen Entity-Masken ist Reminder-Tab vorgesehen?
- Kandidat: ✓ Tab 10 (candidates.html)
- Account: v1.10 NEU Tab 13
- Mandat / Job / Prozess / Projekt / Firmengruppe: prüfen, ob jeweils Reminder-Tab notwendig oder nur über Vollansicht erreichbar

---

## Reihenfolge & Grob-Aufwand

| # | Phase | Aufwand | Abhängigkeit |
|---|-------|---------|--------------|
| 1 | Schema-Spec v0.1 | ~1 h | Phase 0 ✓ |
| 2 | Mockup `reminders.html` (Liste-Modus zuerst) | ~2 h | Schema-Spec |
| 3 | Mockup Kalender-Modus ergänzen | ~1 h | Liste-Modus |
| 4 | Interactions-Spec v0.1 | ~1 h | Mockup steht |
| 5 | Grundlagen-Sync (Phase 3) | ~30 min | Spec fertig |
| 6 | Wiki-Update (Phase 4) | ~20 min | Specs + Mockup |
| 7 | Entity-Tab-Harmonisierung (Phase 5) | ~20 min | Deep-Link-Kontrakt aus Phase 1 |

**Gesamt:** ~6 h (Live-Arbeit, parallel kaum möglich wegen sequentieller Spec-Mockup-Dep).

---

## Definition of Done

- [ ] `specs/ARK_REMINDERS_VOLLANSICHT_SCHEMA_v0_1.md` existiert + komplett
- [ ] `specs/ARK_REMINDERS_VOLLANSICHT_INTERACTIONS_v0_1.md` existiert + komplett
- [ ] `mockups/reminders.html` existiert, Liste + Kalender-Toggle, Drawers, Keyboard-Shortcuts
- [ ] Alle 5 Grundlagen auf Sync geprüft + ggf. ergänzt
- [ ] Wiki-Konzept + Inventar + Sync-Regel aktualisiert
- [ ] Entity-Tabs mit Deep-Link-Footer ergänzt
- [ ] Lint clean: umlaute · db-techdetails · stammdaten · drawer-default · mockup-drift
- [ ] Changelog-Eintrag in `wiki/meta/grundlagen-changelog.md` falls Grundlagen-Edits erfolgt

---

## Related

- [[detailseiten-guideline]]
- [[detailseiten-inventar]]
- [[reminders]] (Konzept)
- [[frontend-freeze]]
- [[spec-sync-regel]]
