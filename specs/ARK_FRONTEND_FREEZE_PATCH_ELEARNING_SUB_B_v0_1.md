# ARK CRM — Frontend-Freeze-Patch · E-Learning Sub B · v0.1

**Scope:** Frontend-Erweiterung für den Content-Generator (Sub B): 3 neue Admin-Pages, Review-Drawer, Editor-Component.
**Zielversion:** gemeinsam mit Sub-A-Patch (Frontend-Freeze v1.11).
**Basis-Specs:** `specs/ARK_E_LEARNING_SUB_B_SCHEMA_v0_1.md`, `specs/ARK_E_LEARNING_SUB_B_INTERACTIONS_v0_1.md`.
**Vorheriger Patch:** `specs/ARK_FRONTEND_FREEZE_PATCH_ELEARNING_v0_1.md` (Sub A).
**Stand:** 2026-04-20
**Status:** Review ausstehend (Peter)

---

## Changelog

| # | Bereich | Änderung |
|---|---------|----------|
| 1 | Admin-Pages | +3 neue Seiten unter `mockups/erp/elearn/admin/` |
| 2 | Components | Review-Drawer, Markdown-Diff-Viewer, YAML-Editor, Chunk-Preview |
| 3 | Sidebar | Admin-Sidebar-Block erweitert um 3 Items |
| 4 | Cost-Widget | Monats-Budget-Progress mit Farb-Codierung |
| 5 | Keyboard-Shortcuts | A/R/E/P/J/K für Review-Queue |

---

## 1. Neue Admin-Pages

Pfad: `mockups/erp/elearn/admin/*.html`. Baseline-Styling = CRM.

### 1.1 `content-gen.html` — Zentrale Übersicht

**Layout:**
- Top: Cost-Widget (Monats-Budget, Progress-Bar, Top-5-teuerste-Jobs).
- Mitte: Job-Timeline (letzte 50 Jobs, sortiert nach `started_at DESC`). Pro Row: Status-Badge, Trigger-Icon, Source-Count, Artefakte-Count, Kosten, Dauer.
- Rechts: Schnell-Aktions-Panel („Neuer Job", „Sources verwalten", „Review-Queue öffnen").

### 1.2 `content-gen-sources.html` — Source-Verwaltung

**Tabs:**
- **Upload** (PDF/DOCX/Book): Drag-Drop-Zone, Form für Metadaten (Sparten, Target-Course, Priority).
- **Web-Quellen:** Liste aller `web_url`-Sources mit Enable-Toggle, Schedule-Dropdown, Letzter Scrape, Fehler-Status. „+ Neue Web-Quelle" öffnet Drawer.
- **CRM-Abfragen:** Liste aller `crm_query`-Sources mit Template-Slug, Parametern, Schedule. „+ Neue Abfrage" öffnet Drawer mit SQL-Template-Picker + Param-Form.

### 1.3 `content-gen-review.html` — Review-Queue

**Layout:**
- Filter-Bar oben: `artifact_type`, `target_course_slug`, `status`, `job_id`, Reviewer-Assignee.
- Tabelle: Artefakte mit Status-Badge, Typ-Icon, Target-Course-Link, Alter, LLM-Modell, Reviewer-Avatar.
- Zeilen-Klick → Review-Drawer (siehe §2.1).

## 2. Neue Components

### 2.1 Review-Drawer (540 px)

**Structure:**

```
┌ Header
│ Artefakt: <Typ> "<Titel>"
│ Target: <course_slug> › <module_slug> › <lesson_slug>
│ Job #<id> · generiert <datetime> · <llm_model> · <cost> €
│
├ Tabs
│ [Preview] [Source] [Chunks] [Diff]
│
│ Preview: Rendered Markdown (für lesson) oder formatiertes YAML (für quiz_pool)
│ Source:  Raw (editierbar bei Edit-Mode)
│ Chunks:  Scroll-Liste der Source-Chunks mit Similarity-Score-Badge
│ Diff:    Side-by-Side alt vs neu (nur sichtbar bei Update einer bestehenden Lesson/Quiz)
│
├ Kommentar-Feld (optional, Textarea)
│
└ Aktions-Buttons: [Ablehnen] [Bearbeiten] [Freigeben] [Direkt publishen]
```

**Editor-Mode:**
- Bei Klick auf „Bearbeiten" wird `Source`-Tab zum Editor.
- **Markdown-Editor** (für lesson): CodeMirror mit Markdown-Syntax-Highlighting + Live-Preview.
- **YAML-Editor** (für quiz_pool): CodeMirror mit YAML-Syntax-Highlighting + Schema-Validation.
- Diff-Tab zeigt live Live-Diff gegen Original-Draft.
- Save-Button: `action='edit'`, `status` bleibt `draft` bei Non-Head-Reviewer oder wird zu `approved` bei Head/Admin.

### 2.2 Markdown-Diff-Viewer

Side-by-Side-Darstellung alt vs. neu mit Line-Level-Highlighting (insertions grün, deletions rot). Basis: `diff2html` oder `react-diff-viewer`.

### 2.3 Chunk-Preview-Component

Liste der `source_chunk_ids` mit:
- Source-Titel + Kind-Icon.
- Text-Excerpt (erste 200 Zeichen).
- Similarity-Score-Badge (farbkodiert: rot < 0.5, gelb 0.5–0.7, grün ≥ 0.7).
- Klick expandiert Vollmodus.

### 2.4 Cost-Widget

- Progress-Bar: Verbrauch/Cap.
- Farb-Codierung: grün < 80 %, gelb 80–95 %, rot ≥ 95 %.
- Tooltip mit Top-5-Jobs.
- Klick → Cost-Detail-Modal mit Aggregation nach Source-Kind.

## 3. Sidebar-Erweiterung (Admin-Teil)

**Bestehender Admin-Block (aus Sub A) wird erweitert:**

| Position | Label | Link |
|----------|-------|------|
| 5 | Kurs-Katalog | `admin/courses.html` |
| 6 | Curriculum-Templates | `admin/curriculum.html` |
| 7 | Import-Dashboard | `admin/imports.html` |
| 8 | Analytics | `admin/analytics.html` |
| — | — Trenner: „Content-Generator" — | — |
| 9 | **Content-Generator** | `admin/content-gen.html` |
| 10 | **Content-Sources** | `admin/content-gen-sources.html` |
| 11 | **Review-Queue** | `admin/content-gen-review.html` |

## 4. Keyboard-Shortcuts (Review-Queue)

| Shortcut | Aktion |
|----------|--------|
| `J` / `K` | Next / Prev Artefakt in Queue |
| `A` | Freigeben |
| `R` | Ablehnen (öffnet Grund-Textarea) |
| `E` | Bearbeiten (öffnet Editor) |
| `P` | Direkt publishen |
| `Esc` | Drawer schliessen |

Modal-Dialoge (z. B. für Ablehnungs-Grund) fangen Shortcuts nicht ab, bis expliziter Fokus.

## 5. Config-Editor für Web/CRM-Sources

### 5.1 Web-Source-Drawer

```
Slug:               [text-input]
Name:               [text-input]
URL:                [url-input]
CSS-Selector:       [text-input + Test-Button]
Schedule:           [dropdown: weekly/daily/cron + custom-cron-input]
Sparten:            [multi-select]
Target-Course:      [dropdown aus published Kurse, optional]
Enabled:            [toggle]

[Testen] [Speichern] [Abbrechen]
```

**Test-Button:** führt einmal Scrape durch, zeigt ersten Chunk in Preview — ohne DB-Write.

### 5.2 CRM-Query-Drawer

```
Slug:               [text-input]
Name:               [text-input]
SQL-Template:       [dropdown aus queries/*.sql]
Parameter:          [dynamisch aus Template]
Schedule:           [wie oben]
Anonymize:          [toggle, default true]
Target-Course:      [dropdown]
Enabled:            [toggle]

[Testen] [Speichern] [Abbrechen]
```

## 6. Design-System-Konformität

- Echte Umlaute UTF-8.
- Drawer 540 px für CRUD-Aktionen.
- Datum-Picker nativ.
- Keine DB-Tech-Details in User-facing-Texten (Label-Vocabulary aus Stammdaten-Patch).
- Admin-Sektionen, die intern Enum-Werte zeigen, mit `<!-- ark-lint-skip:begin reason=admin-content-gen -->…<!-- ark-lint-skip:end -->` wrappen.

## 7. Responsive-Verhalten

- **Desktop (≥ 1280 px):** Tabellen mehrspaltig, Drawer rechts.
- **Tablet (768–1279 px):** Tabellen mit Horizontal-Scroll, Drawer Full-Width-Bottom.
- **Mobile:** nicht MVP.

## 8. A11y-Überlegungen

- ARIA-Live-Region für Status-Änderungen im Review-Drawer.
- Focus-Management: nach Drawer-Close Fokus zurück auf Zeilen-Row.
- Keyboard-Shortcuts haben sichtbare Tooltip-Hints.
- Contrast-Check für Status-Badges und Score-Farben.

## 9. Wiki-Sync

- `wiki/meta/mockup-baseline.md` — ERP-Workspace-Abschnitt um Sub-B-Pages ergänzen.
- `wiki/concepts/elearning-module.md` — UI-Teil Sub B dokumentieren.

## 10. Offene Punkte

- **YAML-Editor-Library:** Monaco (schwer) vs. CodeMirror (leicht). Implementation-Plan entscheidet.
- **PDF-Preview:** im Source-Tab des Review-Drawers für `source_kind='pdf'` direkt embedden? Oder nur Text-Version anzeigen? MVP: nur Text.
- **Bulk-Actions:** „Alle approved" oder „Alle rejected" für eine Filter-Auswahl — Phase-2.
