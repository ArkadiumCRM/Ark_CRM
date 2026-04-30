# ARK CRM — Stammdaten Vollansicht Interactions v0.1

**Stand:** 2026-04-30
**Status:** Erstentwurf — Reverse-Engineered aus Plan v0.1 + Mockup, Review ausstehend
**Quellen:**
- `specs/ARK_STAMMDATEN_VOLLANSICHT_SCHEMA_v0_1.md` (Begleit-Schema)
- `specs/ARK_STAMMDATEN_VOLLANSICHT_PLAN_v0_1.md` (Phase-0 Entscheidungen, alle 10 Fragen mit Vorschlag adoptiert)
- `Grundlagen MD/ARK_BACKEND_ARCHITECTURE_v2_8.md` (Endpoint-Patterns, Worker, Event-Typen)
- `Grundlagen MD/ARK_DATABASE_SCHEMA_v1_6.md` (`dim_*`-Tabellen, `fact_audit_log`)
- `Grundlagen MD/ARK_STAMMDATEN_EXPORT_v1_5.md` (67+ Kataloge · Source-of-Truth Inhalte)
- `Grundlagen MD/ARK_FRONTEND_FREEZE_v1_13.md` (§Drawer-Default-Regel, §Datum-Eingabe-Regel)
- `mockups/Vollansichten/stammdaten.html` (3955 Zeilen — Drawer-IDs, Component-Klassen)
- `wiki/concepts/admin-system.md` (Templates-CRUD-Verteilung)
- `wiki/concepts/interaction-patterns.md` (globale UI-Patterns — Referenz)
- CLAUDE.md §Stammdaten-Wording-Regel · §DB-Techdetails-im-UI-Regel · §Umlaute-Regel

**Vorrang:** Stammdaten > Schema > dieses Interactions-Dokument > Frontend Freeze > Mockups

---

## 0. SCOPE

Verhaltens-Spezifikation der Stammdaten-Vollansicht (`/stammdaten`). Ergänzt `ARK_STAMMDATEN_VOLLANSICHT_SCHEMA_v0_1.md` (Struktur/Layout/Tokens) um:
- Flows (Browse / Edit / Batch-Import / Konflikt-Resolution)
- Endpoints (`/api/v1/stammdaten/...`)
- Events (`config.<dim>.*`)
- Permissions-Matrix (Operation × Rolle)
- State-Management (Cache, URL-Sync, Optimistic-Update)
- Keyboard-Shortcuts
- Empty-/Error-States
- Audit-Integration

**Nicht-Ziel:** Admin-Tab-CRUD-Flows für Templates/Settings (separate Specs `ARK_ADMIN_VOLLANSICHT_INTERACTIONS_v0_1.md`).

---

## 1. FUNKTIONEN PRO BEREICH

### 1a. Header / Page-Banner

| Element | Funktion | Endpoint | Event |
|---------|----------|----------|-------|
| Title „Stammdaten" + Sub-Count | Statisch (Live-Aggregation) | GET `/api/v1/stammdaten/summary` | — |
| Globale Suche `[Suche...]` | Cross-Catalog-Match (debounced 250ms, min 2 Zeichen) | GET `/api/v1/stammdaten/search?q=...` | — |
| Edit-Modus-Toggle `[Browse ▾]` | Toggle Browse/Edit (Confirm-Modal bei Aktivierung) | POST `/api/v1/stammdaten/edit-mode` (audit) | `audit.config.edit_mode_enabled` / `audit.config.edit_mode_disabled` |
| CSV-Export-Dropdown `[Export ▾]` | Export aktive Tab-Kategorie / aktiven Katalog / alles | GET `/api/v1/stammdaten/export?scope=...` | — |

**Edit-Modus-Toggle-Logik:**
1. Klick → Dropdown mit Confirm-Checkbox erscheint
2. User aktiviert Checkbox → POST-Request mit `actor_id` + `started_at`
3. Bei Success: UI-State `edit_mode=true`, Banner erscheint, Inline-Edit-Cells aktivieren
4. Bei 403 (User ist nicht Admin): Toast „Edit-Modus erfordert Admin-Rolle"
5. Banner zeigt Live-Counter „Edit-Modus aktiv seit 14:32 (PW)"
6. Deaktivierung: Klick auf Banner-X → POST `/api/v1/stammdaten/edit-mode/disable` → Audit-Event

### 1b. Tabbar (sticky, 8 Kategorien)

Navigation zwischen Kategorien (siehe Schema §3 Tab-Inventar).

| Aktion | Verhalten |
|--------|-----------|
| Click Tab | Wechselt aktive Kategorie · URL-Update `?tab=<slug>` · re-fetch Stat-Strip + Card-Grid |
| Keyboard `←` `→` | Tabbar-Navigation (Focus auf aktivem Tab) |
| Direkt-Link `/stammdaten/communication` | Lädt Tab 2 (Communication) direkt geöffnet |

Tab-Wechsel löst aus:
- GET `/api/v1/stammdaten/categories/:slug/stats` (Stat-Strip-Werte)
- GET `/api/v1/stammdaten/categories/:slug/catalogs` (Card-Grid)

### 1c. Stat-Strip (4 Cards pro Tab)

| Card | Klick-Verhalten | Backend |
|------|------------------|---------|
| Kataloge in dieser Kategorie | Informational, kein Filter | `COUNT(catalogs)` aus Schema-Mapping |
| Einträge total | filter `view=bulk-overview` (öffnet alle Cards expanded) | `SUM(COUNT(*) FROM dim_<x>)` |
| Letztes Update | Öffnet Audit-Drawer mit Filter `category=<slug>` | `MAX(updated_at)` over alle dim-Tables in Kategorie |
| Verwendet in N Entities | Öffnet Verwendungs-Modal | Aggregierte `fact_*`-Counts (cached 5min) |

### 1d. Filter-Chips (toggle-able pro Tab)

- ✓ Aktiv (default on) · ✗ Inaktiv · 🔒 Locked · 🌐 External · ⚠ Übersetzung fehlt · 🆕 Letzte 7 d geändert · 🔥 Top 10 Verwendung
- Chips sind kombinierbar (AND-Logic)
- Jeder Chip-Toggle → re-fetch Card-Grid (debounced 200ms)
- URL-Update `&active=true&missing_translation=true`
- Aktive Chips zeigen subtle Border + Bold-Text

### 1e. Cat-Card-Grid

Card-Click-Verhalten:

| Aktion | Resultat |
|--------|----------|
| Click auf Card-Body | Öffnet Drill-Down (Slide-In 760px von rechts) — `openCatalog('<slug>')` |
| Click auf Tag-Chip | Filter-Chip-Toggle (z.B. Click `Locked` → setzt Locked-Filter) |
| Hover | Card-Elevation + Subtle Border-Highlight |
| Keyboard `Enter` (focused Card) | Öffnet Drill-Down |

Bei Tag `→ Admin`:
- Card zeigt zusätzlich Button `[→ Admin Tab N]` + `[Übersicht ansehen]`
- Click `→ Admin` navigiert zu `/admin#tab=N&...`
- Click `Übersicht ansehen` öffnet Read-Only-Drill-Down (kein Edit-Modus, auch wenn admin-Edit-Mode aktiv)

### 1f. Drill-Down · Catalog-Tabelle

Slide-In von rechts, 760px (siehe Schema §6).

**Toolbar-Aktionen:**

| Element | Browse | Edit | Endpoint | Event |
|---------|--------|------|----------|-------|
| Suche im Katalog `[Suche...]` | ✅ | ✅ | GET `/api/v1/stammdaten/dim/<x>?q=...` | — |
| Filter Aktiv/Inaktiv | ✅ | ✅ | Query-Param | — |
| Filter „Übersetzung fehlt" | ✅ | ✅ | Query-Param `missing_lang=...` | — |
| Sort (klickbare Header) | ✅ | ✅ | Query-Param `sort=...` | — |
| `+ Eintrag anlegen` | ❌ | ✅ | öffnet `#stammNewEntryDrawer` | — |
| `Batch-Import CSV` | ❌ | ✅ | öffnet `#stammBatchImportDrawer` | — |
| `Export CSV` | ✅ | ✅ | GET `/api/v1/stammdaten/dim/<x>/export.csv` | — |
| `Audit-Log` | ✅ | ✅ | öffnet `#stammAuditDrawer?dim=<x>` | — |
| `[X]` Close-Button | ✅ | ✅ | URL-Pop · Drill-Down schließt | — |

**Tabellen-Zeilen-Aktionen:**

| Aktion | Browse | Edit | Endpoint |
|--------|--------|------|----------|
| Click Zeile | öffnet Detail-Drawer (über Drill-Down-Layer) | öffnet Detail-Drawer | GET `/api/v1/stammdaten/dim/<x>/entries/:code` |
| Inline-Click Cell | — (Read-Only) | Cell wird zu Input | — |
| Drag Sort-Handle | — | Reorder + PATCH | PATCH `/api/v1/stammdaten/dim/<x>/reorder` |
| Toggle Aktiv-Spalte | — | Soft-Disable | PATCH `/api/v1/stammdaten/dim/<x>/entries/:code` |

### 1g. Detail-Drawer (Eintrag-Details)

4 Tabs (siehe Schema §7):

| Tab | Trigger | Endpoint |
|-----|---------|----------|
| 1 Übersicht | Default beim Öffnen | GET `/api/v1/stammdaten/dim/<x>/entries/:code` |
| 2 Verwendung | Click Tab | GET `/api/v1/stammdaten/dim/<x>/entries/:code/usage?limit=50` |
| 3 History | Click Tab | GET `/api/v1/stammdaten/dim/<x>/entries/:code/audit?since=30d` |
| 4 Übersetzungen | Click Tab (nur sichtbar bei `Multi-Lang`-Tag) | GET `/api/v1/stammdaten/dim/<x>/entries/:code/translations` |

Drawer-Schließen via:
- `[X]`-Button oben rechts
- ESC-Taste
- Click außerhalb Drawer (auf Drill-Down-Backdrop)
- URL-Navigation (Browser-Back)

---

## 2. BROWSE-MODUS-FLOWS

### 2.1 Lookup-Flow (Standard-Read)

**Ziel:** User möchte wissen „was ist `tt_telefon_interview`?"

1. User öffnet `/stammdaten`
2. Click Globale Suche → tippt „telefon-interview"
3. Resultat-Liste zeigt Match: „Telefon-Interview · Activity-Types · Communication"
4. Click Resultat → Navigation `/stammdaten/communication/activity-types/tt_telefon_interview`
5. UI: Tab 2 aktiv, Drill-Down `dim_activity_types` offen, Detail-Drawer für Eintrag offen mit Tab „Übersicht"
6. User sieht: Code, Label DE/EN/FR, Beschreibung, Verwendung-Stats

**Keyboard-Shortcut:** `Ctrl+K` öffnet Globale Suche (modaler Pattern, ähnlich Cmd-K in Linear).

### 2.2 Browse-by-Category-Flow

1. User öffnet `/stammdaten`
2. Tabbar zeigt 8 Kategorien — User klickt „Communication"
3. Stat-Strip + Card-Grid laden für Tab 2
4. User sieht 9 Cards (Activity-Types, Reminder-Templates, etc.)
5. Click „Activity-Typen" Card → Drill-Down öffnet mit Tabelle aller 69 Einträge
6. User scrollt, filtert nach „Aktiv" + Filter „Top 10 Verwendung"
7. Click auf Zeile → Detail-Drawer

### 2.3 CSV-Export-Flow

**Granularitäten:**

| Scope | Endpoint | Output |
|-------|----------|--------|
| Aktiver Katalog | GET `/api/v1/stammdaten/dim/<x>/export.csv` | Eine CSV mit allen Einträgen |
| Aktive Kategorie | GET `/api/v1/stammdaten/categories/<slug>/export.zip` | ZIP mit einer CSV pro Katalog |
| Alles | GET `/api/v1/stammdaten/export-all.zip` | ZIP mit 67 CSVs (Admin only) |

**CSV-Format:**
- UTF-8 mit BOM (Excel-kompatibel)
- Spalten: `code,label_de,label_en,label_fr,description,sort_order,active,used_count,updated_at,updated_by`
- Header-Zeile mit DE-Labels (für Empfänger-Lesbarkeit)

Audit-Event `audit.config.export` mit `actor_id`, `scope`, `format`.

---

## 3. EDIT-MODUS-FLOWS

### 3.1 Edit-Modus-Aktivierung

**Voraussetzungen:**
- User hat Rolle `admin` (sonst 403)
- Mobile-Endgerät detected → Edit-Modus deaktiviert mit Hinweis-Banner

**Flow:**

1. User klickt `[Browse ▾]`-Toggle
2. Dropdown öffnet:
   ```
   ☐ Edit-Modus aktivieren (admin · Audit-pflichtig)
   ```
3. User aktiviert Checkbox
4. Confirm-Modal:
   > „Edit-Modus aktivieren?
   > Jede Mutation (Inline-Edit, Sort, Disable, Delete, Batch-Import) wird im Audit-Log mit dir als Actor erfasst.
   > Edit-Modus läuft bis du explizit zurück auf Browse schaltest oder die Seite neu lädst."
   >
   > [Abbrechen] [Edit-Modus aktivieren]
5. Click „Aktivieren" → POST `/api/v1/stammdaten/edit-mode` mit `actor_id`
6. Backend: Insert in `fact_audit_log` (`action='config.edit_mode.enabled'`), emit `audit.config.edit_mode_enabled`
7. Frontend: UI-State `edit_mode=true`, Banner erscheint, Inline-Edit-Cells werden interaktiv
8. Banner zeigt: „⚠ Edit-Modus aktiv · Mutationen werden geloggt · seit 14:32 (PW) · [Beenden]"

### 3.2 Inline-Edit-Flow (Standard-Mutation)

**Beispiel:** Admin korrigiert Label DE für `tt_phone_interview` von „Phone Call" zu „Telefon-Interview".

1. User aktiviert Edit-Modus (siehe §3.1)
2. Navigation zu Drill-Down `dim_activity_types`
3. Click auf Cell „Label DE" der Zeile `tt_phone_interview`
4. Cell wird zu Input mit aktuellem Wert
5. User tippt „Telefon-Interview", drückt Enter
6. **Optimistic-Update:** UI zeigt sofort neuen Wert (kein Spinner)
7. Im Background: PATCH `/api/v1/stammdaten/dim/activity_types/entries/tt_phone_interview` mit Body `{label_de: "Telefon-Interview"}`
8. Backend:
   - Validate (Pflichtfeld, max 100 Zeichen, Umlaute-OK)
   - Check Conflict (`updated_at` vs `If-Match`-Header)
   - Update `dim_activity_types`
   - Insert in `fact_audit_log` (`action='config.activity_types.update'`, `payload={field: "label_de", old: "Phone Call", new: "Telefon-Interview"}`)
   - Emit `config.activity_types.updated` Event
9. **Success-Response:** Toast „Gespeichert" (autodismiss 2s)
10. **Failure-Response:**
    - 400 (Validation): Cell bleibt im Edit-State, Inline-Error-Hint, User kann korrigieren
    - 409 (Konflikt): siehe §3.3
    - 5xx: Optimistic-Rollback, Toast „Speichern fehlgeschlagen, bitte erneut versuchen"

### 3.3 Konflikt-Resolution

**Trigger:** Backend liefert 409 Conflict mit Body `{updated_at: "2026-04-30T14:35Z", updated_by: "JV", current_value: "Phone Call DE"}`.

**Modal öffnet:**

```
⚠ Konflikt erkannt

Eintrag wurde von JV vor 3 Min. geändert.

| Feld     | Dein Wert         | JV's Wert       |
|----------|-------------------|------------------|
| Label DE | Telefon-Interview | Telefon-Anruf    |

[Abbrechen] [JV's Wert übernehmen] [Meinen Wert überschreiben]
```

**Optionen:**
- **Abbrechen:** Edit verworfen, UI lädt aktuellen Server-Wert
- **JV's Wert übernehmen:** UI lädt JV's Wert, kein PATCH
- **Meinen Wert überschreiben:** PATCH mit `If-Match: <new-updated_at>` Header (Force-Update). Audit-Event mit `payload={conflict_resolved: "force_overwrite", previous_actor: "JV"}`

**Phase-1:** Kein 3-Wege-Auto-Merge — einfacher Diff-View. Bei mehrfachen Konflikten (>2) Empfehlung Bulk-Reload + manueller Re-Edit.

### 3.4 Sort-Order-Drag-Flow

1. Edit-Modus aktiv
2. Drill-Down zeigt Sort-Spalte mit Drag-Handle (`☰` Icon links der Sort-Number)
3. User klickt+hält Drag-Handle, zieht Zeile nach oben/unten
4. **Optimistic-Update:** UI zeigt sofort neue Reihenfolge
5. PATCH `/api/v1/stammdaten/dim/<x>/reorder` mit Body `{moves: [{code: "...", from: 21, to: 5}]}` (Bulk-Move für effiziente Multi-Reorder)
6. Backend: Update `sort_order` aller verschobenen Einträge atomar (Transaktion)
7. Audit-Event `config.<dim>.reorder` mit Bulk-Payload
8. Bei Failure: Optimistic-Rollback + Toast

### 3.5 Soft-Disable-Flow

1. Edit-Modus aktiv
2. Drill-Down: User klickt Toggle in Spalte „Aktiv?" einer Zeile
3. Optimistic: UI zeigt strike-through-Style + Filter-Chip „✗ Inaktiv" zeigt jetzt diesen Eintrag
4. PATCH `/api/v1/stammdaten/dim/<x>/entries/:code` mit `{active: false}`
5. Audit-Event `config.<dim>.disable`
6. Reactivate analog: Click → `{active: true}` → `config.<dim>.enable`

**FK-Konsistenz:** Soft-Disable ändert nichts an existierenden Referenzen aus `fact_*`. Eintrag erscheint nur nicht mehr in neuen Dropdowns/Selects.

### 3.6 Hard-Delete-Flow

**Voraussetzung:** 0 Verwendungen (FK-Check). Sonst Button disabled mit Tooltip „Eintrag wird in N Records verwendet · Soft-Disable empfohlen".

1. Edit-Modus aktiv
2. Detail-Drawer eines Eintrags geöffnet
3. Tab „Übersicht" zeigt unten Button `[Hard-Delete...]` (rot, nur bei 0 Usages aktiv)
4. Click → Confirm-Modal:
   > „Hard-Delete von 'Telefon-Interview' (`tt_phone_interview`)?
   >
   > Eintrag wird permanent gelöscht. Diese Aktion kann nicht rückgängig gemacht werden.
   >
   > Begründung (Pflicht):
   > [_________________________________]
   >
   > [Abbrechen] [Permanent löschen]"
5. User tippt Reason (min 10 Zeichen) + Click „Permanent löschen"
6. DELETE `/api/v1/stammdaten/dim/<x>/entries/:code` mit Body `{reason: "..."}`
7. Backend:
   - Re-Check FK-Count (Race-Condition-Schutz) — falls jetzt >0: 409 mit Hinweis
   - DELETE-Statement in Transaction
   - Insert `fact_audit_log` mit `action='config.<dim>.delete'`, `payload={code, label_de, reason, fk_count_at_delete: 0}`
   - Emit `config.<dim>.deleted`
8. Drawer schließt, Tabellen-Zeile verschwindet, Toast „Gelöscht"

### 3.7 Batch-Import-CSV-Flow

1. Edit-Modus aktiv
2. Drill-Down-Toolbar: Click `[Batch-Import CSV]`
3. Drawer `#stammBatchImportDrawer` öffnet (760px):
   - Step 1: File-Upload (Drag&Drop oder Click)
   - Step 2: Preview-Diff
   - Step 3: Confirm + Apply
4. **Step 1 — Upload:**
   - Akzeptiert: CSV (UTF-8 mit oder ohne BOM)
   - Max 5 MB
   - POST `/api/v1/stammdaten/dim/<x>/batch-import/preview` (multipart/form-data)
5. **Step 2 — Preview-Diff:**
   - Backend parst CSV, vergleicht mit Current-State
   - Response zeigt:
     - **Neu:** N Einträge, die hinzugefügt werden
     - **Update:** N Einträge, die modifiziert werden (Diff pro Feld)
     - **Unverändert:** N Einträge ohne Änderung
     - **Gelöscht (im CSV nicht enthalten):** N Einträge — Hinweis: NICHT auto-deleted, Soft-Disable empfohlen
     - **Errors:** Validation-Fehler (z.B. Pflichtfeld fehlt) mit Zeilennummer
   - User reviewt Preview
6. **Step 3 — Confirm:**
   - Confirm-Modal: „Apply N Updates + M Inserts? Diff im Audit-Log gespeichert."
   - Click „Anwenden" → POST `/api/v1/stammdaten/dim/<x>/batch-import/apply` mit `import_session_id` aus Step 2
7. Backend:
   - Atomare Transaction über alle Inserts/Updates
   - Bei einem Failure: kompletter Rollback + Error-Report
   - Audit-Event `config.<dim>.batch_import` mit `payload={inserts: N, updates: M, session_id: ..., source_file: "..."}`
8. Drawer schließt mit Success-Toast „N+M Einträge importiert"

**Phase-1-Limits:** CSV nur (kein Excel). Soft-Disable als Empfehlung statt Auto-Delete. 3-Wege-Merge nicht supported.

---

## 4. CRUD-OPERATIONS · ENDPOINT-MATRIX

### 4.1 Endpoint-Übersicht

| Verb | Path | Zweck | Permission |
|------|------|-------|------------|
| GET | `/api/v1/stammdaten/summary` | Dashboard-Aggregat (67 Kataloge, 5K Einträge, Last-Edit) | All |
| GET | `/api/v1/stammdaten/search?q=...` | Cross-Catalog-Suche | All |
| GET | `/api/v1/stammdaten/categories` | 8 Kategorien-Inventar | All |
| GET | `/api/v1/stammdaten/categories/:slug/stats` | Stat-Strip-Werte | All |
| GET | `/api/v1/stammdaten/categories/:slug/catalogs` | Card-Grid-Daten | All |
| GET | `/api/v1/stammdaten/dim/:catalog` | Tabellen-Daten (paginated, filter, sort) | All |
| GET | `/api/v1/stammdaten/dim/:catalog/entries/:code` | Eintrag-Detail | All |
| GET | `/api/v1/stammdaten/dim/:catalog/entries/:code/usage` | Verwendungs-Stats (Top-50) | All |
| GET | `/api/v1/stammdaten/dim/:catalog/entries/:code/audit` | Eintrag-Audit-History (default 30d) | All |
| GET | `/api/v1/stammdaten/dim/:catalog/entries/:code/translations` | Multi-Lang-Werte | All (Multi-Lang-Catalogs) |
| GET | `/api/v1/stammdaten/dim/:catalog/export.csv` | CSV-Export (UTF-8 BOM) | All |
| GET | `/api/v1/stammdaten/categories/:slug/export.zip` | Kategorie-ZIP-Export | All |
| GET | `/api/v1/stammdaten/export-all.zip` | Komplett-Export | Admin |
| POST | `/api/v1/stammdaten/edit-mode` | Edit-Modus aktivieren | Admin |
| DELETE | `/api/v1/stammdaten/edit-mode` | Edit-Modus deaktivieren | Admin |
| POST | `/api/v1/stammdaten/dim/:catalog/entries` | Neuer Eintrag | Admin (außer Locked/External) |
| PATCH | `/api/v1/stammdaten/dim/:catalog/entries/:code` | Eintrag-Update (Inline-Edit) | Admin |
| DELETE | `/api/v1/stammdaten/dim/:catalog/entries/:code` | Hard-Delete (mit FK-Check + Reason) | Admin |
| PATCH | `/api/v1/stammdaten/dim/:catalog/reorder` | Sort-Order-Bulk-Update | Admin |
| POST | `/api/v1/stammdaten/dim/:catalog/batch-import/preview` | CSV-Preview-Diff | Admin |
| POST | `/api/v1/stammdaten/dim/:catalog/batch-import/apply` | CSV-Apply (mit Session-ID) | Admin |
| PUT | `/api/v1/stammdaten/dim/:catalog/entries/:code/translations` | Multi-Lang-Update | Admin |

### 4.2 Header-Konventionen

- `If-Match: <updated_at>` für PATCH/DELETE (Conflict-Detection)
- `X-Actor-Id: <user_uuid>` (Audit-Tracking)
- `X-Edit-Session-Id: <session_uuid>` (Edit-Modus-Session-Validation)

### 4.3 Response-Standards

- Success: 200 mit aktualisiertem Eintrag
- Conflict: 409 mit Body `{current_value, updated_at, updated_by}`
- Validation: 400 mit Body `{errors: [{field, message}]}`
- Locked/External: 403 mit Body `{reason: "external_managed" | "locked_by_law"}`
- FK-Block: 409 mit Body `{fk_count: N, fk_tables: [...]}`

---

## 5. VALIDATION-REGELN

### 5.1 Per-Field-Validierung

| Feld | Regel | Frontend | Backend |
|------|-------|----------|---------|
| `code` | snake_case · ASCII · max 50 · unique pro Katalog | Pattern `^[a-z][a-z0-9_]*$` | DB-Unique-Constraint |
| `label_de` | Pflicht · max 100 · UTF-8 (Umlaute OK) | Text-Input mit Counter | NotNull + Length-Check |
| `label_en` | Optional · max 100 | — | Length-Check |
| `label_fr` | Optional · max 100 | — | Length-Check |
| `description` | Optional · max 500 | Textarea mit Counter | Length-Check |
| `sort_order` | Integer · ≥ 0 · per Katalog unique soft (Drag-Reorder erzeugt Lücken-Free) | Number-Input | Integer-Check |
| `active` | Boolean | Toggle | Bool-Cast |

### 5.2 Konsistenz-Regeln (Backend-Only)

- **Code-Immutable:** `code` ist nach Anlage nicht editierbar (FK-Konsistenz). UI zeigt Code als Read-Only nach Anlage.
- **Sparte-Constraint:** `dim_mitarbeiter_sparten_link` muss zu existierender (`active=true`) `dim_sparte` zeigen.
- **Hierarchie-Konsistenz:** `dim_functions.parent_code` muss in derselben Tabelle existieren (Self-FK).
- **Locked-Override:** Locked-Catalogs lehnen alle PATCH/POST/DELETE mit 403 ab — auch für Admin.

### 5.3 Umlaute-Validierung

CLAUDE.md §Umlaute-Regel: UTF-8-Echte Umlaute Pflicht. Backend rejected `ae`/`oe`/`ue`/`ss` als Substitut wenn Original-DB-Wert echte Umlaute hatte (Hint via Toast: „Bitte echte Umlaute verwenden: ä ö ü ß").

---

## 6. AUDIT-INTEGRATION

### 6.1 Audit-Action-Naming

Alle Mutationen schreiben in `fact_audit_log` mit Action-Pattern `config.<dim>.<verb>`:

| Verb | Trigger | Payload |
|------|---------|---------|
| `create` | POST neuer Eintrag | `{code, label_de, label_en, label_fr, sort_order}` |
| `update` | PATCH Inline-Edit | `{field, old, new}` (per geändertem Feld) |
| `disable` | PATCH `active=false` | `{code}` |
| `enable` | PATCH `active=true` | `{code}` |
| `reorder` | PATCH Bulk-Sort | `{moves: [{code, from, to}, ...]}` |
| `delete` | DELETE | `{code, label_de, reason, fk_count_at_delete}` |
| `batch_import` | POST batch-import/apply | `{session_id, inserts, updates, source_file}` |
| `export` | GET export.csv/zip | `{scope, format}` |
| `edit_mode_enabled` | POST edit-mode | `{started_at}` |
| `edit_mode_disabled` | DELETE edit-mode | `{started_at, ended_at, mutations_count}` |
| `translation_update` | PUT translations | `{lang, field, old, new}` |

### 6.2 Audit-Drawer (Tab 3 im Detail-Drawer)

Filter-Optionen:
- Time-Range: Default 30 Tage · Toggle „Alle anzeigen" · Custom-Range (Datepicker)
- Action-Type: Multi-Select (create/update/disable/enable/delete/batch)
- Actor: Multi-Select (Admin-Kürzel)

Spalten:
- Timestamp · Action · Actor · Field/Detail · Before/After-Diff

### 6.3 Cross-Eintrag-Audit-Log

In Drill-Down-Toolbar: Click `[Audit-Log]` öffnet `#stammAuditDrawer` mit Filter `dim=<x>` (alle Mutationen dieses Katalogs). Globaler Audit-Log liegt in Admin Tab 8.

---

## 7. PERMISSIONS-MATRIX

| Operation | AM/CM/RA/BO/HoD | Admin (PW) | External (DSG-Audit) |
|-----------|------------------|------------|------------------------|
| `/stammdaten` öffnen | ✅ | ✅ | ✅ |
| Globale Suche | ✅ | ✅ | ✅ |
| Tab-Navigation | ✅ | ✅ | ✅ |
| Card-Grid lesen | ✅ | ✅ | ✅ |
| Drill-Down öffnen | ✅ | ✅ | ✅ (Tab 8 Governance ggf. only) |
| Detail-Drawer Tab 1 (Übersicht) | ✅ | ✅ | ✅ |
| Detail-Drawer Tab 2 (Verwendung) | ✅ | ✅ | ✅ |
| Detail-Drawer Tab 3 (History) | ❌ (außer eigene) | ✅ | ✅ |
| Detail-Drawer Tab 4 (Übersetzungen) | ✅ Read | ✅ Edit | ✅ Read |
| CSV-Export Catalog | ✅ | ✅ | ✅ |
| CSV-Export Category | ✅ | ✅ | ✅ |
| CSV-Export-All | ❌ | ✅ | ❌ |
| Edit-Modus aktivieren | ❌ (403) | ✅ | ❌ |
| Inline-Edit | ❌ | ✅ (außer Locked/External) | ❌ |
| Sort-Drag | ❌ | ✅ (außer Locked/External) | ❌ |
| Soft-Disable | ❌ | ✅ (außer Locked/External) | ❌ |
| Hard-Delete | ❌ | ✅ (FK=0 + Reason) | ❌ |
| Batch-Import | ❌ | ✅ (außer Locked/External) | ❌ |
| Translations-Edit | ❌ | ✅ (Multi-Lang-Catalogs) | ❌ |
| Audit-Log lesen | ❌ (außer eigene) | ✅ | ✅ |

### 7.1 Nicht-erlaubt-Verhalten

- 403-Response → Frontend zeigt Toast „Berechtigung fehlt für diese Aktion"
- Mobile-Edit-Mode → Banner statt Toast: „Edit nur am Desktop möglich"
- External/Locked-Edit-Versuch → Inline-Disabled-Button mit Tooltip-Hinweis (siehe Schema §8.5)

---

## 8. KEYBOARD-SHORTCUTS

### 8.1 Globale Shortcuts (auf Page)

| Shortcut | Aktion |
|----------|--------|
| `Ctrl+K` (Mac: `Cmd+K`) | Öffnet Globale Suche |
| `Ctrl+E` (Admin only) | Toggle Edit-Modus (mit Confirm) |
| `Ctrl+Shift+E` | Globaler CSV-Export-Dropdown |
| `1`-`8` | Tab-Switch (1=Workflow, 2=Communication, ..., 8=Governance) |
| `?` | Öffnet Keyboard-Help-Overlay |

### 8.2 Tabbar-Shortcuts

| Shortcut | Aktion |
|----------|--------|
| `←` `→` | Tab-Navigation (wenn Tabbar fokussiert) |
| `Tab` | Focus weiter zu Filter-Chips → Card-Grid |

### 8.3 Drill-Down-Shortcuts

| Shortcut | Aktion |
|----------|--------|
| `Esc` | Schließt Drill-Down (oder Detail-Drawer wenn drüber) |
| `Ctrl+F` | Focus auf Suche-Feld (Drill-Down-Toolbar) |
| `Ctrl+N` (Admin · Edit-Modus) | Öffnet `#stammNewEntryDrawer` |
| `↑` `↓` | Tabellen-Zeile-Navigation |
| `Enter` | Öffnet Detail-Drawer der fokussierten Zeile |

### 8.4 Inline-Edit-Shortcuts

| Shortcut | Aktion |
|----------|--------|
| `Tab` / `Enter` | Speichern + nächste Cell |
| `Shift+Tab` / `Shift+Enter` | Speichern + vorherige Cell |
| `Esc` | Cancel ohne Speichern |
| `Ctrl+Z` | Undo letzten Edit (innerhalb Session, max 10) |

---

## 9. EMPTY- / ERROR-STATES

### 9.1 Empty-States

| Kontext | Anzeige |
|---------|---------|
| Globale Suche · 0 Treffer | „Kein Eintrag gefunden für ‚<query>'. Versuche kürzere Suche oder andere Begriffe." + Button `[Filter zurücksetzen]` |
| Tab-Pane · 0 Cards (alle Filter gefiltert) | „Keine Kataloge in dieser Kategorie passen zu den aktiven Filtern." + Filter-Reset-Button |
| Drill-Down · 0 Einträge nach Filter | „Keine Einträge passen zu den aktiven Filtern." |
| Detail-Drawer Verwendung · 0 Records | „Dieser Eintrag wird derzeit nicht verwendet. Hard-Delete möglich." (für Admin Edit-Mode) |
| Detail-Drawer Audit · 0 Einträge | „Keine Audit-Einträge im gewählten Zeitraum. Erweitere Filter oder ‚Alle anzeigen'." |

### 9.2 Error-States

| Fehler | UI-Reaktion |
|--------|-------------|
| Network-Failure (Fetch failed) | Banner oben „Verbindung fehlgeschlagen · [Erneut versuchen]" · Retry-Button |
| 401 Unauthorized | Redirect zu Login-Seite |
| 403 Forbidden | Toast „Berechtigung fehlt für diese Aktion" |
| 500 Server Error | Toast „Server-Fehler · IT informiert · bitte später erneut versuchen" + Auto-Sentry-Report |
| 409 Conflict (Edit) | Konflikt-Modal (siehe §3.3) |
| 409 FK-Block (Delete) | Inline-Hinweis statt Modal: „Eintrag wird in N Records verwendet · Hard-Delete blockiert" |
| 422 Validation | Inline-Field-Error in Edit-Cell oder Drawer-Form |
| Stale-Data (Edit-Mode-Session expired) | Modal „Edit-Modus ist abgelaufen · bitte erneut aktivieren" |

---

## 10. STATE-MANAGEMENT

### 10.1 URL-State-Sync

Alle wichtigen UI-States werden in URL persistiert (Bookmarkable, Shareable):

| State | URL-Param |
|-------|-----------|
| Aktive Tab | `?tab=<slug>` |
| Aktiver Catalog (Drill-Down offen) | `/stammdaten/<category>/<catalog>` |
| Aktiver Eintrag (Detail-Drawer offen) | `/stammdaten/<category>/<catalog>/<code>` |
| Aktive Drawer-Tab | `?drawer-tab=usage|history|translations` |
| Filter | `?active=true&missing_translation=true&top10=true&modified_7d=false` |
| Suche | `?search=<urlencoded>` |
| Edit-Modus | `?mode=edit` (admin only · sonst fallback browse) |
| Sort | `?sort=label_de:asc` |

URL-State ist Single-Source-of-Truth → Browser-Back/Forward funktionieren.

### 10.2 Cache-Strategie

| Daten | Cache-Layer | TTL |
|-------|-------------|-----|
| Catalog-Inventar (statisch) | Browser-Memory | Session |
| Stat-Strip-Werte | Browser-Memory | 5 min · invalidate bei Mutation |
| Card-Grid-Daten | Browser-Memory | 5 min · invalidate bei Mutation |
| Tabellen-Daten | Browser-Memory | 60s · invalidate bei Mutation |
| Verwendungs-Stats (`fact_*`-Counts) | Backend-Memory + Browser-Memory | 5 min |
| Audit-Log | Browser-Memory | 30s |

### 10.3 Edit-Modus-Session

- Edit-Modus-Aktivierung erzeugt Server-Side-Session (`stammdaten_edit_session` mit `session_id`, `actor_id`, `started_at`, `last_activity`)
- Idle-Timeout: 60 min (Session expires, aber Banner zeigt „Edit-Modus aktiv" — bei nächster Mutation 401-Response → Re-Activation-Modal)
- Bei Browser-Close ohne explizites Disable: Server cleant Session bei nächstem Cron (alle 15 min)

---

## 11. EVENTS / WS-CHANNELS

### 11.1 Event-Bus (`fact_event_queue`)

Alle Mutationen emittieren Events ins Event-Bus für Cross-Modul-Sync:

| Event | Trigger | Subscriber (Phase-1) |
|-------|---------|------------------------|
| `config.<dim>.created` | POST neuer Eintrag | Audit-Worker · Cache-Invalidation-Worker |
| `config.<dim>.updated` | PATCH | Audit-Worker · Cache-Invalidation · Frontend WS-Push |
| `config.<dim>.disabled` / `.enabled` | PATCH active | Audit-Worker · Frontend WS-Push |
| `config.<dim>.deleted` | DELETE | Audit-Worker · FK-Cache-Invalidation |
| `config.<dim>.reordered` | PATCH reorder | Audit-Worker |
| `config.<dim>.batch_imported` | POST batch-import | Audit-Worker · Cache-Invalidation |
| `config.edit_mode.enabled` / `.disabled` | POST/DELETE edit-mode | Audit-Worker |

### 11.2 WebSocket-Channel `stammdaten`

Frontend abonniert WS-Channel `stammdaten:<dim>` wenn Drill-Down/Detail-Drawer offen:
- Bei Mutation eines anderen Admins: Event-Push triggers Re-Fetch + Toast „Eintrag wurde von <actor> aktualisiert · neu geladen"
- Bei Hard-Delete im offenen Drawer: Modal „Eintrag wurde gelöscht von <actor>" + Drawer-Auto-Close

### 11.3 Subscriber-Matrix

| Worker | Subscribed Events | Aktion |
|--------|-------------------|--------|
| `audit.worker.ts` | `config.*` | Insert in `fact_audit_log` (falls nicht bereits direkt im Endpoint) |
| `cache.invalidation.worker.ts` | `config.<dim>.created/updated/disabled/enabled/deleted/reordered` | Memcache-Bust für `stammdaten:<dim>:*` Keys |
| `fk.consistency.worker.ts` | `config.<dim>.disabled/deleted` | Logging falls FK-Hilfs-Tables (z.B. `dim_mitarbeiter_sparten_link`) inkonsistent werden |

---

## 12. INTEGRATION MIT BESTEHENDEN MODULEN

### 12.1 Sidebar-Navigation

Sidebar-Eintrag „Stammdaten" unter „System" (siehe `Grundlagen MD/ARK_FRONTEND_FREEZE_v1_13.md` Sidebar-Tree).

### 12.2 Cross-Link aus anderen Tools

Alle Mockups, die Stammdaten-Werte zeigen, können mit `Ctrl+Click` auf einen Wert direkt zur Stammdaten-Detail-Drawer springen:

```html
<span class="stage-pill" data-stamm-link="/stammdaten/workflow/process-stages/cv_sent">
  CV Sent
</span>
```

JS:
```javascript
document.querySelectorAll('[data-stamm-link]').forEach(el => {
  el.addEventListener('click', (e) => {
    if (e.ctrlKey || e.metaKey) {
      window.open(el.dataset.stammLink, '_blank');
    }
  });
});
```

### 12.3 Activity-Type-Mapping (Admin → Stammdaten)

Wenn Admin Tab 4 (Templates) z.B. neue E-Mail-Template hinzufügt, die ein Activity-Type referenziert (`activity_type_code='tt_phone_interview'`), prüft Backend-Validation gegen `dim_activity_types`. Bei Stammdaten-Soft-Disable des Activity-Types: Admin-Tab zeigt Warnung „Template referenziert deaktivierten Activity-Type · Bitte korrigieren".

---

## 13. OFFENE FRAGEN

| # | Frage | Vorschlag |
|---|-------|-----------|
| 1 | Edit-Mode-Idle-Timeout: 60 min OK oder kürzer/länger? | 60 min — Balance zwischen Sicherheit und User-Experience |
| 2 | WebSocket-Channel pro Catalog ODER ein Channel für alle Stammdaten? | Pro Catalog (`stammdaten:<dim>`) — Subscriber-Effizienz, weniger Noise |
| 3 | Translations-Tab: Alle 3 Sprachen Pflicht oder DE-Only-OK? | DE-Only OK (default), EN/FR optional · Filter „Übersetzung fehlt" zeigt Lücken |
| 4 | Globale Suche: Auch Beschreibungs-Volltext oder nur Code/Labels? | Auch Beschreibung (Levenshtein-Fuzzy) — Power-User-Feature |
| 5 | Card-Grid Sort: Alphabetisch oder by Verwendungs-Count? | Toggle-Switch im Header (Default Alphabetisch) |
| 6 | Hard-Delete-Reason: Min 10 Zeichen ausreichend oder strenger Pflicht-Template? | Min 10 Zeichen frei — Audit-Log macht Pattern transparent |
| 7 | Batch-Import: Auch JSON oder nur CSV? | Phase-1 nur CSV · JSON als Phase-2 Erweiterung |
| 8 | Mobile-Read-Only: Card-Grid scrollt horizontal oder Stack? | Stack vertikal (1-Spalte) — bessere Mobile-UX |

---

**Ende v0.1.** Begleit-Schema: `ARK_STAMMDATEN_VOLLANSICHT_SCHEMA_v0_1.md`. Review durch PO (PW) erforderlich vor Implementation-Start.
