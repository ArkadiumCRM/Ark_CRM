# ARK CRM — Reminders Vollansicht Schema v0.1

**Stand:** 2026-04-17
**Status:** Erstentwurf — Review ausstehend
**Quellen:**
- `Grundlagen MD/ARK_FRONTEND_FREEZE_v1_10.md` (§Routing `/reminders`, §Reminders-Tool-Ableitung, §Design-System)
- `Grundlagen MD/ARK_BACKEND_ARCHITECTURE_v2_5.md` (§Reminders-Endpunkte Z. 1663–1671 · §Worker 10 `reminder.worker.ts`)
- `Grundlagen MD/ARK_DATABASE_SCHEMA_v1_3.md` (§`fact_reminders` Z. 1282–1306)
- `Grundlagen MD/ARK_STAMMDATEN_EXPORT_v1_3.md` (§64 `dim_reminder_templates` 10 Vorlagen)
- `wiki/concepts/reminders.md` (Auto-Trigger-Übersicht + Eskalationslogik)
- `mockups/candidates.html` Tab 10 (Referenz-Pattern Entity-Tab Z. 4720–4918)
- `mockups/dashboard.html` (Widget „Meine überfälligen Reminders" Z. 617)
- `specs/ARK_REMINDERS_VOLLANSICHT_PLAN_v0_1.md` (Phase 0 Entscheidungen)

**Vorrang:** Stammdaten > dieses Schema > Frontend Freeze > Mockups
**Begleitdokument:** `ARK_REMINDERS_VOLLANSICHT_INTERACTIONS_v0_1.md`

---

## 0. ZIELBILD

Vollseite `/reminders` — **cross-entity, user-/teamzentrierte** Task-Management-Oberfläche für alle Reminders (manuell erstellt oder auto-generiert durch `reminder.worker.ts`).

**Abgrenzung zu bestehenden Reminder-Oberflächen:**

| Oberfläche | Scope | Zweck |
|------------|-------|-------|
| Dashboard-Widget „Meine überfälligen Reminders" | User · nur Überfällig/Heute, Top 5–8 | Morgen-Trigger, Einstieg |
| Entity-Tab Reminders (Kandidat §10 · Account §13) | 1 Entity | „Was steht bei dieser Entität an?" |
| **Vollansicht `/reminders`** (dieses Dokument) | **cross-entity · user oder team · alle Filter · Listen- + Kalender-View** | **„Was muss ich/mein Team tun?"** |
| Admin-Auto-Regeln `/admin/reminder-rules` (separates Tool) | Global · Schwellen/Templates | Admin-seitige Auto-Reminder-Konfiguration (nicht Teil dieser Spec) |

**Einordnung:** Tool-Maske (analog `/operations/dok-generator`, `/operations/email-kalender`) — keine Entity-Bindung. Lebt im Segment „Operations" (bzw. Haupt-Nav, siehe FRONTEND_FREEZE Top-Nav-Eintrag „Reminders").

**Primäre Nutzer (alle Rollen Daily-Use):**

| Rolle | Nutzungs-Szenario | Default-Scope |
|-------|------------------|----------------|
| **AM** (Account Manager) | Mandats-Follow-ups, Schutzfrist-Tracking, Garantie-Ende | eigene |
| **CM** (Candidate Manager) | Interview-Coaching, Debriefing, Post-Placement-Check-Ins, Briefing | eigene |
| **RA** (Research) | Kandidaten-Refresh, Briefing-Fehlt-Reminders, Scraper-Trigger | eigene |
| **BO** (Backoffice) | Garantie-Ende, Onboarding-Call, Rechnungs-Follow-ups | eigene |
| **Head of** (HoD) | Team-Workload, Überfällig-Eskalation, Urlaubs-Abdeckung | eigene + Team |
| **Admin** | Cross-Team-Monitoring, KPI, Eskalations-Audit | eigene + Team (Switcher auf „Alle") |

**Prinzipien:**
- **Optimistic Update** überall (Complete/Snooze/Reassign) — Spinner nur bei Hard-Failure-Rollback
- **Keine Bulk-Actions** (Phase 0 Entscheidung 3 — Sales-Team würde unüberprüft durch-snoozen)
- **Kalender-View CRM-intern** (Phase 0 Entscheidung 5 — kein Outlook-Sync, der bleibt in `/operations/email-kalender`)
- **Erledigte > 30 d ausgeblendet** (Phase 0 Entscheidung 7), via Toggle sichtbar; kein Hard-Delete (Audit-Trail bleibt)
- **Deep-Link-fähig** von Entity-Tabs + Dashboard (`?entity=<type>&id=<uuid>&scope=…&view=…&filter=…`)

---

## 1. DESIGNSYSTEM-REFERENZ

Erbt aus [[frontend-freeze]] und [[mockup-baseline]]. Modul-spezifische Ergänzungen:

### Module-Farbe

Keine dedizierte Modul-Farbe — nutzt Standard-Accent (`var(--accent)`). Semantik über Status-Farben:

| Status | Farbe | Token |
|--------|-------|-------|
| Überfällig | Rot | `var(--red)` (Border-left 3px + KPI-Card rot) |
| Heute | Amber/Gelb | `var(--amber)` |
| Diese Woche | Accent-soft | `var(--accent-soft)` |
| Später | Muted | `var(--muted)` |
| Erledigt | Grau · `<s>`-Strike | `var(--muted)` + `text-decoration:line-through` |

### Priority-Dots (fact_reminders.priority)

| Priority | Dot | Farbe |
|----------|-----|-------|
| Urgent | ● solid rot | `var(--red)` |
| High | ◉ ring rot | `var(--red)` outline |
| Medium | ● solid gelb | `var(--amber)` |
| Low | ○ ring grau | `var(--muted)` |

### Typ-Chips (dim_reminder_templates + freie Kategorien)

Kanonische Labels (in `wiki/meta/mockup-baseline.md` §16 ergänzen — siehe Phase 3):

| Chip | Bedeutung | Token |
|------|-----------|-------|
| 🧑‍💼 Interview-Coaching | Coaching-Call vor Interview (rt_06) | `var(--blue-soft)` |
| 💬 Debriefing | Nach Interview (rt_07) | `var(--purple-soft)` |
| 🎓 Briefing | Briefing mit Kandidat fehlt (rt_09) | `var(--gold-soft)` |
| 🛡 Schutzfrist | Info-Request-Tracking (rt_10) | `var(--amber-soft)` |
| 🎯 Onboarding | Onboarding-Call vor Arbeitsantritt (rt_01) | `var(--green-soft)` |
| ✓ Check-In | 1-/2-/3-Monats-Check (rt_02/03/04) | `var(--accent-soft)` |
| ⏱ Garantie | Garantiefrist-Ende (rt_05) | `var(--amber-soft)` |
| 📅 Interview-Datum | Datum-fehlt-Erinnerung (rt_08) | `var(--red-soft)` |
| 🔄 Kandidaten-Refresh | 6-Mt-Refresh CV/LinkedIn | `var(--blue-soft)` |
| 📝 Follow-up | Freier manueller Reminder | `var(--muted-soft)` |
| 🛠 Custom | User-defined | `var(--muted-soft)` |

### Entity-Badges (bei verknüpften Reminders)

Reuse aus `candidates.html` Verknüpfungs-Badges (Schema v1.3 §Verknüpfungs-Badges):
- Prozess (teal · 🔄) · Job (gold · 💼) · Mandat (lila · 📋) · Kandidat (blau · 👤) · Account (accent · 🏢)
- klickbar → Detailseite oder Drawer

### Auto-Badge

`fact_reminders.is_auto_generated=true` → Badge „⚙ Auto" neben Typ-Chip, Tooltip zeigt Trigger (z.B. „rt_04 — placed_at + 3 Monate").

### Mockup-Datei

`mockups/reminders.html` (Phase 2 dieses Plans — noch zu erstellen).

---

## 2. GESAMT-LAYOUT

```
┌──────────────────────────────────────────────────────────────────┐
│ Breadcrumb: Home / Reminders                                      │
├──────────────────────────────────────────────────────────────────┤
│ PAGE-BANNER                                                        │
│ 🔔 Reminders              Meta   [Scope: Eigene ▾]   [+ Reminder] │
│ 8 offen · 1 überfällig · 1 heute · 3 diese Woche · 12 erledigt    │
├──────────────────────────────────────────────────────────────────┤
│ KPI-STRIP (cols-6)                                                 │
│ Offen · Überfällig · Heute · Diese Woche · Später · Erledigt-30d  │
├──────────────────────────────────────────────────────────────────┤
│ SAVED-VIEWS-CHIPS                                                  │
│ [Mein Tag] [Mein Montag] [Überfällig Team*] [+ Neue Ansicht]      │
├──────────────────────────────────────────────────────────────────┤
│ VIEW-TOGGLE          FILTER-BAR                                    │
│ [📋 Liste] [📅 Kal.]  Suche · Typ · Zuständig · Quelle ·          │
│                       Entity-Typ · Datums-Range · Priority ·       │
│                       Recurrence · [nur Auto-generiert ☐]          │
├──────────────────────────────────────────────────────────────────┤
│ STATUS-CHIP-TABS (nur Liste-Modus)                                 │
│ [Alle offenen] [● Überfällig] [Heute] [Diese Woche] [Später]      │
│ [Erledigt]                                                         │
├──────────────────────────────────────────────────────────────────┤
│ MAIN-PANE (wechselt je nach View-Modus)                            │
│                                                                    │
│ ┌ LISTE-MODUS ───────────────────────────────────────────────── ┐ │
│ │ Section-Groups:                                                │ │
│ │  Überfällig (rot) · Heute · Diese Woche · Später · Erledigt   │ │
│ │  (Erledigt default collapsed)                                  │ │
│ │ Row: [☐] Titel+Sub · Typ-Chip · Entity-Badge · Fälligkeit ·   │ │
│ │      Priority-Dot · MA-Kürzel · [Erledigen]                    │ │
│ └────────────────────────────────────────────────────────────────┘ │
│                                                                    │
│ ┌ KALENDER-MODUS ────────────────────────────────────────────── ┐ │
│ │ Toolbar: [‹ ›] Monat-Titel · [Monat | Woche] · [Heute]        │ │
│ │ Raster: Monat 7×6 · Woche 7-Spalten Tag-Grid                   │ │
│ │ Reminder-Chips pro Tag (Typ-Farbe · max 3 + „+N")              │ │
│ │ Click Chip → Reminder-Detail-Drawer                            │ │
│ │ Drag Chip → anderer Tag → PATCH due_date (Optimistic)          │ │
│ └────────────────────────────────────────────────────────────────┘ │
│                                                                    │
├──────────────────────────────────────────────────────────────────┤
│ DRAWER-OVERLAY (540px slide-in rechts, on demand)                 │
│ 2 Drawer: ReminderDetail · ReminderNew                            │
└──────────────────────────────────────────────────────────────────┘
```

Höhen-Mathematik: `calc(100vh - 225px)` für Main-Pane. Banner ~85px · KPI ~80px · Saved-Views ~40px · View-Toggle+Filter ~80px · Status-Tabs ~40px (Liste only).

*Scope-Switcher und Saved-View „Überfällig Team" sichtbar nur für Admin/HoD (siehe §6 Berechtigungen).

---

## 3. PAGE-BANNER

| Element | Inhalt | Verhalten |
|---------|--------|-----------|
| **Titel** | „🔔 Reminders" (Libre Baskerville 22px · accent) | statisch |
| **Meta-Zeile** | „N offen · M überfällig · K heute · L diese Woche · P erledigt (30 d)" | live aus Backend-Count |
| **Scope-Switcher** | `[Eigene ▾]` → Dropdown `Eigene` · `Team` · `Alle` | Nur Admin/HoD sichtbar. AM/CM/RA/BO: kein Element gerendert. Default lt. Rollen-Tabelle in Phase-0-Plan |
| **CTA-Button** | „+ Reminder" (primary) — öffnet `#reminderNewDrawer` | global auch via Keyboard `N` |

Keine weiteren CTAs (kein „Auto-Regeln" hier — das ist `/admin/reminder-rules`).

---

## 4. KPI-STRIP

6 Cards horizontal (Breakpoint < 1280px → scrollable):

| Card | Label | Wert-Quelle | Klick-Aktion |
|------|-------|-------------|--------------|
| 1 | **Offen** | `count(is_done=false AND scope-match)` | Klick → Filter auf „Alle offenen" |
| 2 | **Überfällig** (rot) | `count(is_done=false AND due_date < today)` | Klick → Status-Chip „Überfällig" |
| 3 | **Heute** | `count(due_date = today AND is_done=false)` | Klick → Status-Chip „Heute" |
| 4 | **Diese Woche** | `count(due_date BETWEEN today+1 AND today+7 AND is_done=false)` | Klick → Status-Chip „Diese Woche" |
| 5 | **Später** | `count(due_date > today+7 AND is_done=false)` | Klick → Status-Chip „Später" |
| 6 | **Erledigt (30 d)** (gold-soft) | `count(done_at >= today-30)` | Klick → Status-Chip „Erledigt" (Archiv-Toggle on) |

Alle Werte scope-aware (eigene oder team oder all, je nach Scope-Switcher).

---

## 5. SAVED-VIEWS-CHIPS

Horizontal gescrollbare Chip-Leiste. Jeder Chip = gespeicherte Filter-/Scope-/View-Kombination.

### 5a. Default-Views (rollen-spezifisch, system-seeded)

| Rolle | Default-View 1 | Default-View 2 | Default-View 3 |
|-------|----------------|----------------|----------------|
| AM | Mein Tag | Mandats-Follow-ups | Schutzfrist-Tracking |
| CM | Mein Tag | Interview-Coaching + Debriefing | Post-Placement-Check-Ins |
| RA | Mein Tag | Briefing-Fehlt | Kandidaten-Refresh (6-Mt) |
| BO | Mein Tag | Garantie-Ende (nächste 30 d) | Onboarding-Call (nächste 14 d) |
| HoD | Team-Workload | Team-Überfällig | Mein Tag |
| Admin | Alle-Überfällig | Team-Workload | Mein Tag |

**„Mein Tag"** = Filter `scope=self, status=overdue|today, view=list`.

### 5b. User-defined Views

- CTA `+ Neue Ansicht` öffnet Mini-Modal (ausnahmsweise Modal statt Drawer, weil kurze 1-Feld-Eingabe: Name) — speichert aktuelle Filter-Kombi als User-Pref
- Max 10 Saved Views pro User
- Drag-to-Reorder, Right-Click → Umbenennen / Löschen
- Storage: neue Tabelle `fact_user_saved_views` (Phase 3 Sync-Check — prüfen ob existent oder neu nötig)

### 5c. Anzeige-Logik

- Aktiver View: Chip `border: 2px solid var(--accent)` + `bg: var(--accent-soft)`
- Hovering Chip: Tooltip mit Filter-Zusammenfassung
- Klick: setzt alle Filter/Scope/View gleichzeitig + URL-Update (deep-linkable)

---

## 6. FILTER-BAR + STATUS-CHIP-TABS

### 6a. Filter-Bar (immer sichtbar)

| Filter | Typ | Werte |
|--------|-----|-------|
| Suche | Text-Input | Fulltext über `title`, `description`, Entity-Name |
| Typ | Select | Alle · 11 Typ-Chips aus §1 |
| Zuständig | Select | Alle · eigene · Mitarbeiter-Kürzel-Liste (scope-aware — nur Team-Mitglieder wenn scope=team) |
| Quelle | Select | Alle · Manuell · Auto (System-Trigger) · Aus Prozess · Aus Jobbasket · Aus Schutzfrist |
| Entity-Typ | Select | Alle · Kandidat · Account · Mandat · Job · Prozess |
| Datums-Range | Date-Range-Picker (nativ, lt. Datum-Eingabe-Regel) | Default leer (kein Cap) |
| Priority | Select | Alle · Urgent · High · Medium · Low |
| Recurrence | Select | Alle · Einmalig · Daily · Weekly · Monthly |
| Nur Auto-generiert | Checkbox | default off |

**Filter-Tag-Chips unter Filter-Bar:** aktive Filter als entfernbare Chips (z.B. `Typ: Debriefing ✕`).

### 6b. Status-Chip-Tabs (nur Liste-Modus sichtbar)

6 Chips analog Entity-Tab-Pattern (candidates.html Tab 10):

| Chip | Count-Quelle |
|------|--------------|
| Alle offenen | `is_done=false` |
| ● Überfällig | `is_done=false AND due_date < today` |
| Heute | `due_date = today` |
| Diese Woche | `due_date BETWEEN today+1 AND today+7` |
| Später | `due_date > today+7` |
| Erledigt | `is_done=true AND done_at >= today-30` (lt. Phase 0 Entscheidung 7 — älter per Archiv-Toggle in Filter-Bar) |

---

## 7. LISTE-MODUS

### 7a. Section-Groups

Gruppiert nach Fälligkeits-Bucket (unabhängig vom Status-Chip — Chips filtern zusätzlich):

| Group | Sortierung | Collapse-Default |
|-------|------------|------------------|
| Überfällig (rot) | `due_date DESC` (älteste zuerst) | expanded |
| Heute (gelb) | `due_time ASC` (zeitlich) | expanded |
| Diese Woche | `due_date ASC, due_time ASC` | expanded |
| Später | `due_date ASC` | expanded |
| Erledigt (30 d) | `done_at DESC` | **collapsed** |

Section-Head: `border-left: 3px solid <status-color>` · H3 · Count-Badge.

### 7b. Reminder-Row-Template

```
┌────────────────────────────────────────────────────────────────┐
│ [☐] │ TITEL (bold)                      · Typ-Chip · Entity    │
│     │ Subtitle (muted, max 1 Zeile)       Badge(s)             │
│     │                                                            │
│     │ Fälligkeit · ● Priority · MA-Kürzel         [Erledigen] ▾ │
└────────────────────────────────────────────────────────────────┘
```

**Spalten-Inhalt:**

| Spalte | Inhalt | Verhalten |
|--------|--------|-----------|
| Checkbox | Markierung für Multi-Select (aktuell nur für Einzel-Auswahl-Highlight, keine Bulk-Actions) | Click toggelt row-selected-class |
| Titel | `fact_reminders.title` fett | Klick → `#reminderDetailDrawer` öffnet |
| Subtitle | `fact_reminders.description` truncated | — |
| Typ-Chip | aus §1 Typ-Chips | Click → Filter auf diesen Typ |
| Entity-Badge | klickbar, führt zu Entity-Detailseite/Drawer | Deep-Link mit `?entity=…&id=…` |
| Fälligkeit | Relative („6 d überfällig", „17:00 Uhr", „morgen", „in 3 d") + Absolut im Tooltip | — |
| Priority | Dot + Tooltip mit Priority-Name | — |
| MA-Kürzel | `actor-chip` mit 2-Buchstaben-Kürzel (PW/JV/LR…) | Click → Filter auf diesen Mitarbeiter |
| Aktion | [Erledigen] Primary-Button · Dropdown-Caret öffnet Sub-Menü (Snooze / Reassign / Öffnen) | — |

**Row-States:**
- `overdue` → `border-left: 3px solid var(--red)`
- `today` → `border-left: 3px solid var(--amber)`
- `done` → row muted + `text-decoration: line-through` auf Titel

### 7c. Snooze-Dropdown (per Row)

Klick auf Caret neben Erledigen-Button → Dropdown:
- `+1 Stunde` (bei due_time gesetzt)
- `+1 Tag`
- `+1 Woche`
- `Custom…` → Mini-Date-Picker (nativ)

Optimistic Update: Row fliegt aus aktuellem Bucket, Toast „Verschoben auf <Datum>" mit Undo-Link (5 s).

---

## 8. KALENDER-MODUS

### 8a. Toolbar

| Element | Inhalt |
|---------|--------|
| Navigation | `[‹]` vorher · Monat/Woche-Titel · `[›]` weiter |
| View-Sub-Toggle | `[Monat | Woche]` — Default Monat |
| Heute-Button | `[Heute]` — springt zu heute |

### 8b. Monatsraster (7×6)

- Tag-Zelle: Tagesnummer oben links · Reminder-Chips unten (max 3 sichtbar, +N-Link für mehr)
- Heute-Zelle: `background: var(--amber-soft)`
- Zelle anderer Monat: muted
- Klick auf Tag-Header → springt zu Wochenraster des Tages

### 8c. Wochenraster (7-Spalten)

- Spalte pro Tag · Reminder-Chips vertikal gestackt nach `due_time`
- Keine Stundenraster-Achse (Reminder sind primär datums-basiert, Uhrzeit optional)
- Scrollable wenn viele Reminders

### 8d. Reminder-Chip im Kalender

```
[● Typ-Icon] Titel-Truncated
```

- Farbe: Typ-Chip-Farbe (§1)
- Click → `#reminderDetailDrawer`
- Drag → anderer Tag → `PATCH /api/v1/reminders/:id` mit neuem `due_date` (Optimistic)
- Erledigte Reminders im Kalender: `opacity: 0.4` + `<s>`

### 8e. Kalender-Empty-State

Wenn in aktuellem Monat 0 Reminders: zentriertes Illustration-Placeholder + „Keine Reminders in diesem Zeitraum. [+ Reminder anlegen]".

---

## 9. DRAWERS

### 9a. `#reminderDetailDrawer` (540px)

Öffnet bei Klick auf Reminder-Titel.

**Header:**
- Titel (editierbar inline, Return speichert)
- Status-Badge (Offen/Überfällig/Heute/Erledigt)
- Close-Button `✕`

**Sub-Tabs (5):**

| Tab | Inhalt |
|-----|--------|
| **Übersicht** | Beschreibung · Typ (editierbar) · Fälligkeit (Datum+Uhrzeit editierbar, nativer Picker) · Priority · Zuständig (editierbar bei Berechtigung) · Quelle (Auto/Manuell) · Erstellt am/von · Erledigt am/von (falls done) |
| **Historie** | Event-Timeline: `reminder_created`, alle Snoozes, Reassigns, `reminder_completed` · analog `fact_history`-Darstellung |
| **Verknüpfungen** | Entity-Badges der gelinkten Entitäten · Klick öffnet Deep-Link / Drawer · CRUD für Verknüpfungen (nur wenn nicht auto-gen) |
| **Wiederholung** | Recurrence-Select (None/Daily/Weekly/Monthly) · Next-Occurrence-Vorschau · Enddatum (optional) |
| **Push-Erinnerung** | Slider „Erinnerung X Minuten vor Fälligkeit" · Kanal-Checkboxen (In-App · Email · Push) · Default aus User-Pref |

**Footer:**
- `[Erledigen]` primary (falls offen)
- `[Snooze ▾]`
- `[Reassign ▾]` (nur wenn Berechtigung)
- `[Löschen]` ghost (nur Admin; sonst nur via Admin-Tool)

### 9b. `#reminderNewDrawer` (540px)

Öffnet bei „+ Reminder"-Button oder Keyboard `N`.

**Felder (Pflicht *):**

| Feld | Typ | Default / Auto-Fill |
|------|-----|---------------------|
| Vorlage (optional) | Select aus `dim_reminder_templates` (10 Einträge §64) | „Eigene Eingabe" — wählt User eine Vorlage, füllt diese title/description aus Template, setzt `reminder_type` |
| Titel * | Text | vom Template oder leer |
| Beschreibung | Textarea | — |
| Fälligkeits-Datum * | Date-Input nativ (Picker + Keyboard) | heute + 1 Tag |
| Fälligkeits-Uhrzeit | Time-Input nativ | 09:00 |
| Priorität | Select (Urgent/High/Medium/Low) | Medium |
| Wiederholung | Select (None/Daily/Weekly/Monthly) | None |
| Entity-Link (optional) | Autocomplete (Typ + Name) über 5 Entity-Typen | `?entity=…&id=…`-Deep-Link vorbefüllt |
| Zuständig * | Mitarbeiter-Select (scope-aware) | eingeloggter User |
| Erinnerungs-Push | Checkbox + Minuten-vor-Input | off |

**Deep-Link-Vorbefüllung:**
- URL `?entity=candidate&id=<uuid>` → Entity-Link vorbefüllt mit Kandidat X
- URL `?template=rt_06` → Vorlage „Interview-Coaching" vorbefüllt

**Footer:**
- `[Abbrechen]` ghost
- `[Reminder anlegen]` primary (POST `/api/v1/reminders`)

---

## 10. BERECHTIGUNGEN (Scope-Logik)

### 10a. Scope-Ebenen

| Scope | Was wird angezeigt |
|-------|---------------------|
| `self` | Nur Reminders wo `mitarbeiter_id = current_user_id` |
| `team` | Reminders aller direkten Reports (`dim_mitarbeiter.vorgesetzter_id = current_user_id`) + eigene — siehe Interactions §9b |
| `all` | Alle Reminders im Tenant (tenant-weit) |

### 10b. Rollen-Mapping (Scope-Switcher-Sichtbarkeit)

| Rolle | Default-Scope | Switcher sichtbar? | Max-Scope |
|-------|---------------|---------------------|-----------|
| AM | self | nein | self |
| CM | self | nein | self |
| RA | self | nein | self |
| BO | self | nein | self |
| HoD | team | ja (self/team) | team |
| Admin | team | ja (self/team/all) | all |

### 10c. Aktions-Permissions

| Aktion | self | team | all |
|--------|------|------|-----|
| Lesen | immer | HoD+ | Admin+ |
| Complete / Snooze | eigene immer; fremde nur HoD+ für Team | HoD+ | Admin+ |
| Reassign | eigene → andere nur HoD+ | HoD+ (innerhalb Team) | Admin+ (tenant-weit) |
| Löschen | nie im UI | nie im UI | nur Admin via Admin-Tool |
| Auto-Regeln bearbeiten | nie (ausserhalb dieser Maske) | nie | `/admin/reminder-rules` |

### 10d. Saved Views pro Rolle

Siehe §5a — system-seeded Defaults. User-defined Views: max 10, tenant-scoped, not-shareable (Phase 1 — Sharing ggf. später).

---

## 11. EMPTY STATES

| Zustand | Anzeige |
|---------|---------|
| Keine Reminders überhaupt | Illustration + „Keine Reminders. Lege deinen ersten an." + `[+ Reminder]`-CTA |
| Alle erledigt (0 offen) | „🎉 Alles erledigt! Nichts mehr offen in deinem Scope." |
| Filter-Kombination leer | „Keine Reminders mit diesen Filtern. Filter zurücksetzen." + `[Filter leeren]`-Button |
| Kalender-Monat ohne Reminder | Zentriertes „Keine Reminders in diesem Zeitraum. [+ Reminder anlegen]" |
| Erledigt-Chip aktiv, 0 in 30 d | „Keine erledigten Reminders in den letzten 30 Tagen. [Älteres anzeigen ▾]" |

---

## 12. RESPONSIVE-VERHALTEN

| Breakpoint | Verhalten |
|------------|-----------|
| ≥ 1440px | Volles Layout, KPI cols-6, Filter-Bar 1 Zeile |
| 1280–1439px | KPI cols-6 scrollable horizontal · Filter-Bar 1 Zeile ggf. wrap |
| < 1280px | Saved-Views-Chips horizontal scrollable · Filter-Bar wrapped 2 Zeilen |
| < 960px | Desktop-only Hinweis oder Mobile-Zweit-Mockup (out-of-scope Phase 1) |

Mobile-First ist **nicht** Ziel (FRONTEND_FREEZE Regel 11 — Desktop-geeignet).

---

## 13. DESIGN-TOKENS SPEZIFISCH

| Token | Wert | Verwendung |
|-------|------|-----------|
| `--reminders-overdue-bg` | `var(--red-soft)` | Überfällig-KPI-Card, Row-Border-Left |
| `--reminders-today-bg` | `var(--amber-soft)` | Heute-KPI, Row-Border-Left, Kalender-Heute-Zelle |
| `--reminders-kalender-chip-radius` | 3px | Reminder-Chip im Kalender (consistent with editorial.css) |
| `--reminders-kpi-cols` | 6 | Grid-Spalten im KPI-Strip |
| `--reminders-saved-views-chip-height` | 32px | Saved-View-Chip |

---

## 14. BACKEND-ANKNÜPFUNG (Referenz · nach Phase-3-Sync 2026-04-17)

Endpoints (aus `ARK_BACKEND_ARCHITECTURE_v2_5.md` §Reminders + §User-Preferences):

| Endpoint | Zweck | Scope-Enforcement |
|----------|-------|-------------------|
| `GET /api/v1/reminders?scope=self|team|all&…` | Listen-Abfrage | Server prüft Rollen-Max-Scope |
| `POST /api/v1/reminders` | Erstellen | — |
| `GET /api/v1/reminders/:id` | Detail | Lesen-Permission |
| `PATCH /api/v1/reminders/:id` | Ändern (due_date/title/description/priority/is_done-Undo) | Edit-Permission |
| `POST /api/v1/reminders/:id/complete` | Erledigt markieren | Edit-Permission |
| `POST /api/v1/reminders/:id/snooze` | +1h/+1d/+1w/Custom | Edit-Permission |
| `POST /api/v1/reminders/:id/reassign` (v2.5.5 neu) | Mitarbeiter-Wechsel | HoD+ |
| `GET /api/v1/user-preferences/reminders` (v2.5.5 neu) | Saved-Views + Defaults lesen | self (immer eigene) |
| `PATCH /api/v1/user-preferences/reminders` (v2.5.5 neu) | Saved-Views CRUD + Defaults | self (immer eigene) |

Events (aus `ARK_BACKEND_ARCHITECTURE_v2_5.md` §A):

| Event | Typ | Auslöser |
|-------|-----|----------|
| `reminder_batch_created` | dediziert (bestehend) | Placement-Saga TX1 Step 7 |
| `reminder_reassigned` | dediziert (v2.5.5 neu) | `POST /reminders/:id/reassign` |
| `reminder_overdue_escalation` | dediziert (v2.5.5 neu) | Worker bei 48 h überfällig |
| Lifecycle (create/complete/snooze/update) | **nicht dediziert** | via `fact_audit_log` `entity_updated` + Field-Diff |

Worker:
- `reminder.worker.ts` — generisch, Fälligkeits-Push + Auto-Gen aus `dim_reminder_templates`
- `process-auto-reminder.worker.ts` — 5 Auto-Reminders bei Placement-Event `placed`
- `process-interview-coaching-reminder.worker.ts` + `process-interview-debriefing-reminder.worker.ts` — bei `interview_scheduled`
- `reminder-overdue-escalation.worker.ts` (v2.5.5 neu) — hourly 08–20h, 48-h-Schwelle, idempotent via `fact_reminders.escalation_sent_at`

DB-Referenzen:
- `fact_reminders` (DB v1.3.5): + `template_id uuid FK → dim_reminder_templates(id)`, + `escalation_sent_at timestamptz`
- `dim_mitarbeiter.dashboard_config jsonb` — Storage für Saved-Views + User-Prefs (Sub-Key `reminders`)
- `dim_mitarbeiter.vorgesetzter_id` — Team-Definition (direkte Reports)
- `bridge_mitarbeiter_roles` + `dim_mitarbeiter.rolle_type` — Permission-Gating

---

## 15. ABGRENZUNG ZU ENTITY-TABS

**Was die Entity-Tabs (Kandidat §10, Account §13) weiter erfüllen:**
- Alle Reminders dieser konkreten Entität (Filter implizit)
- Kontext-Erstellung („+ Reminder an diesem Kandidaten" — Entity-Link vorbefüllt)
- Inline-History zur Entität

**Was nur `/reminders` kann:**
- Cross-Entity-Liste
- Scope auf Team / All (HoD+/Admin+)
- Kalender-View
- Saved Views
- Deep-Link aus anderen Kontexten
- Footer-Ausgangspunkt aus Dashboard-Widget

**Link-Verbindung (Phase 5 Plan):**
- Entity-Tab Footer: `→ Alle Reminders` → `/reminders?entity=<type>&id=<uuid>`
- Dashboard-Widget Footer: `→ Alle Reminders (N offen)` → `/reminders`

---

## 16. OFFENE FRAGEN (v0.2)

### Phase-3-Sync 2026-04-17 geklärt

1. ✓ **Saved Views Storage** → `dim_mitarbeiter.dashboard_config.reminders.saved_views[]` (JSONB, max 10 user-defined). Keine neue Tabelle nötig.
2. ✓ **`template_id` als FK** → ergänzt in `fact_reminders` (DB v1.3.5).
4. ✓ **Team-Definition** → `dim_mitarbeiter.vorgesetzter_id` (direkte Reports). Kein separates `dim_team`.

### Noch offen für v0.2

3. **Overdue-Eskalations-Schwellen konfigurierbar?** Aktuell hart-codiert in `reminder-overdue-escalation.worker.ts` (24 h Push an Zuständigen, 48 h Push an Head of). Soll das in `dim_automation_settings` als JSONB-Key (`reminder_escalation_thresholds`) wie andere Schwellen?
5. **Sharing Saved Views** pro Team (HoD teilt mit Team): Phase 1 no-share. v0.2 entscheiden.
6. **Mobile** out-of-scope v0.1.
7. **Recurrence-Enddatum** (Feld `recurrence_end_date` in `fact_reminders`) — fehlt aktuell, aber UI-Drawer Tab „Wiederholung" hat kein Enddatum. Pragmatisch: Phase 2.
8. **Undo-Fenster (5 s)** User-Pref konfigurierbar oder fix?

---

## Related

- [[reminders]] (Konzept)
- [[detailseiten-guideline]]
- [[frontend-freeze]]
- [[spec-sync-regel]]
- `specs/ARK_REMINDERS_VOLLANSICHT_INTERACTIONS_v0_1.md` (Begleit-Spec, next)
- `specs/ARK_REMINDERS_VOLLANSICHT_PLAN_v0_1.md` (Ausarbeitungsplan)
