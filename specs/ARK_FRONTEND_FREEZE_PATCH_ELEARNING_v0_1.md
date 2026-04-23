# ARK CRM — Frontend-Freeze-Patch · E-Learning · v0.1

**Scope:** Frontend-Patterns für das Phase-3-ERP-Modul E-Learning (Sub A · Kurs-Katalog): ERP-Workspace, Topbar-Toggle CRM↔ERP, ERP-Sidebar-Pattern, neue Page-Templates, Component-Erweiterungen.
**Zielversion:** `ARK_FRONTEND_FREEZE_v1_11.md` (Bump von v1.10).
**Basis-Specs:** `specs/ARK_E_LEARNING_SUB_A_SCHEMA_v0_1.md`, `specs/ARK_E_LEARNING_SUB_A_INTERACTIONS_v0_1.md`.
**Stand:** 2026-04-20
**Status:** Review ausstehend (Peter)

---

## Changelog

| # | Bereich | Änderung |
|---|---------|----------|
| 1 | Topbar | Neuer **Topbar-Toggle CRM ↔ ERP** (links neben User-Avatar) |
| 2 | Workspace | Neuer ERP-Workspace mit eigener Sidebar (getrennt vom CRM) |
| 3 | ERP-Sidebar-Pattern | Dokumentiert (gleiches Styling wie CRM-Sidebar, aber ERP-spezifische Items) |
| 4 | Pages | +13 neue HTML-Templates unter `mockups/erp/elearn/*` |
| 5 | Components | Markdown-Renderer mit Embed-Blocks (neu); Quiz-Runner-Components pro Fragen-Typ (neu) |
| 6 | Drawer-Patterns | E-Learning-spezifische Drawer (Freitext-Review, Team-Detail, Curriculum-Override, Ad-hoc-Assignment) |
| 7 | Keyboard-Shortcuts | Quiz-Runner und Freitext-Queue unterstützen Shortcuts (J/K/Enter/Esc) |
| 8 | Styling | ERP-Workspace nutzt identische Base-Tokens (Farben, Typo, Abstände) wie CRM; kein separates Theme |

**Nicht Teil dieses Patches:**
- Mobile-App-Patterns (nicht MVP).
- Newsletter-UI (Sub C).
- Gate-Enforcement-UI (Sub D).
- Claude-Design-generierte Mockups (folgen in separatem Mockup-Commit nach Spec-Freigabe).

---

## 1. Topbar-Toggle CRM ↔ ERP

### 1.1 Position

Links neben User-Avatar in der globalen Topbar. Sichtbar auf allen Seiten (CRM und ERP).

### 1.2 Verhalten

- Toggle als Segmented-Control mit zwei Buttons: **CRM** | **ERP**.
- Aktiver Modus visuell hervorgehoben (Primärfarbe-Fill, weisser Text).
- Klick wechselt Workspace: ändert Sidebar-Inhalt + Default-Route.
- Persistenz: letzter Modus pro User in `localStorage` gespeichert, wird beim nächsten Login wiederhergestellt.
- Route-Behaviour:
  - CRM-Default: `/crm/candidates.html` (bzw. letzte CRM-Route).
  - ERP-Default: `/erp/elearn/dashboard.html` (bzw. letzte ERP-Route).

### 1.3 Zugriffs-Rechte

- Alle authentifizierten User sehen beide Modi.
- Falls User in ERP keinen Zugriff auf ein Modul hat (z. B. nur Admin für `erp/elearn/admin/*`), zeigt die Sidebar das Item nicht.

## 2. ERP-Workspace

### 2.1 Struktur

```
/erp
  /elearn               ← Sub A (dieser Patch)
  /hr                   ← bestehender HR-ERP-Ansatz (aus erp-tools commit)
  /zeit                 ← bestehender Zeit-ERP
  /commission           ← bestehender Commission-ERP
```

Jedes ERP-Modul ist eigenständig, aber nutzt dieselbe Base (Sidebar, Topbar, Styling).

### 2.2 ERP-Sidebar-Pattern

**Layout identisch zu CRM-Sidebar:**
- Linke Fixed-Width-Spalte (240 px).
- Top-Logo (Arkadium).
- Module-Gruppierung mit Section-Headern.
- Aktives Item hervorgehoben (Primary-Fill-Background + weisser Text).
- Icons aus `lucide-icons` (wie CRM).

**ERP-Sidebar-Struktur (Module-Übersicht):**

```
── E-Learning
   • Meine Kurse
   • Team-Übersicht          (Head + Admin)
   • Freitext-Queue          (Head + Admin)
   • Zuweisungen             (Head + Admin)
   ─ (Trenner, nur Admin)
   • Kurs-Katalog            (Admin)
   • Curriculum-Templates    (Admin)
   • Import-Dashboard        (Admin)
   • Analytics               (Admin)

── HR                        (bestehend, separater Patch)
── Zeiterfassung             (bestehend)
── Commission                (bestehend)
```

### 2.3 Navigation zwischen ERP-Modulen

Sidebar-Section-Header sind klickbar — kollabiert andere Sections, fokussiert aktives Modul. Default: alle offen.

## 3. Neue Page-Templates

Pfad: `mockups/erp/elearn/*.html`. Baseline-Styling = CRM (`mockups/candidates.html`). Mockup-Implementation folgt in separatem Commit nach Spec-Freigabe.

### 3.1 MA-Pages (6)

| Datei | Zweck |
|-------|-------|
| `dashboard.html` | Einstieg: Onboarding-Progress (neue MA) oder Tabs Pflicht/Empfohlen/Entdecken |
| `course.html` | Kurs-Übersicht: Module-Liste, Progress-Ringe, Pre-Test-Button |
| `lesson.html` | Markdown-Viewer + Embeds + Scroll-Tracker + Sticky-Footer |
| `quiz.html` | Quiz-Runner mit Fragen-Components (MC, Multi, TF, Zuordnung, Reihenfolge, Freitext) |
| `quiz-result.html` | Ergebnis + Feedback + Retry/Weiter |
| `certificates.html` | Zertifikate-Grid + Badge-Wall |

### 3.2 Gemeinsame Pages (Head + Admin, Scope via Rolle) (3)

| Datei | Zweck |
|-------|-------|
| `team.html` | Team-Übersicht (Head: eigenes Team / Admin: tenant-weit) |
| `freitext-queue.html` | Review-Queue mit LLM-Vorschlag + Head-Override-Drawer |
| `assignments.html` | Massen-Zuweisung (Sparte/Rolle/Kurs-Filter) |

### 3.3 Admin-only Pages (4)

| Datei | Zweck |
|-------|-------|
| `admin/courses.html` | Publish/Archiv-Toggle, Version-Historie, Zielgruppen-Override |
| `admin/curriculum.html` | Template-Matrix (Rolle × Sparte), Drag-Drop-Kursliste pro Zelle |
| `admin/imports.html` | Git-Webhook-Status, Commit-Timeline, Retry |
| `admin/analytics.html` | KPIs, Heatmaps, Problem-Kurse |

## 4. Neue Components

### 4.1 Markdown-Renderer mit Embed-Blocks

**Zweck:** Lesson-Content rendern. Unterstützt Standard-Markdown + Custom-Embed-Syntax.

**Embed-Shortcodes:**
- `![[image.png]]` → `<img>` aus Content-Repo-Assets.
- `{% embed pdf="file.pdf" page=N %}` → embedded PDF-Viewer (PDF.js-basiert).
- `{% embed youtube="ID" %}` → YouTube-iframe.

**Pre-Rendering:** Server-side Markdown-to-HTML beim Import; Embed-Blocks zu Platzhaltern, Client-side Komponenten-Mount.

### 4.2 Scroll-Tracker-Hook

**Zweck:** Lesson-Engagement messen.

**API:** `useScrollTracker({ lessonId, minReadSeconds, onComplete })`
- Trackt max erreichten `scroll_pct` pro Lesson.
- Trackt aktive `time_sec` (pausiert bei Tab-Unfocus via `visibilitychange`).
- Heartbeat alle 15 s via `POST /api/elearn/my/lessons/:lid/progress`.
- Callback `onComplete` wird gefeuert, wenn `scroll_pct ≥ 90` und `time_sec ≥ minReadSeconds` → aktiviert „Erledigt"-Button.

### 4.3 Quiz-Fragen-Components

**Ein Component pro Fragen-Typ:**

| Component | Typ |
|-----------|-----|
| `<QuizQuestionMC>` | Radio-Buttons |
| `<QuizQuestionMulti>` | Checkboxes |
| `<QuizQuestionTrueFalse>` | Zwei grosse Buttons |
| `<QuizQuestionZuordnung>` | Drag-Drop Left→Right |
| `<QuizQuestionReihenfolge>` | Drag-Drop Vertikal-Sort |
| `<QuizQuestionFreitext>` | Textarea + Char-Counter |

**Gemeinsame API:** `{ question, value, onChange, disabled }`.

### 4.4 Freitext-Review-Drawer

**Layout:** 540 px Slide-in-Drawer (ARK-Drawer-Default-Regel).

**Sections:**
1. Frage-Anzeige.
2. Musterlösung (readonly).
3. Keywords als Chips.
4. MA-Antwort (readonly).
5. LLM-Vorschlag: Score-Bar (farbkodiert) + Feedback-Text.
6. Head-Override: Score-Slider (0-100, vorgefüllt mit llm_score) + Feedback-Textarea (vorgefüllt mit llm_feedback).
7. Action-Buttons: „LLM bestätigen" + „Überschreiben + speichern".

**Shortcuts:**
- `J` / `K` → nächster / vorheriger Review.
- `Enter` → „LLM bestätigen".
- `O` → Fokus auf Override-Slider.
- `Esc` → Drawer schliessen.

## 5. State-spezifische Card-Visuals

Auf `erp/elearn/dashboard.html` pro Kurs-Card:

| State | Visual |
|-------|--------|
| Gesperrt (Step-Lock) | Ausgegraut + Schloss-Icon + Tooltip |
| Nicht gestartet | „Jetzt starten"-Button + Progress-Ring 0 % |
| In Arbeit | Progress-Ring X % + Modul-Stand |
| Quiz in Prüfung | Badge „In Prüfung" + Progress-Ring eingefroren |
| Abgeschlossen | Checkmark + „Erneut anschauen"-Button |
| Refresher fällig | Gelbes Badge „Refresher fällig" + Deadline |
| Deadline überschritten | Rotes Badge „Überfällig" |

## 6. Drawer-Default-Regel (Konformität)

Alle CRUD / Bestätigungen / Mehrschritt-Eingaben als **540 px Drawer** (siehe CLAUDE.md Drawer-Default-Regel 2026-04-14). Modale nur für kurze Confirms, Blocker, System-Notifications.

**E-Learning-spezifische Drawer:**

| Drawer | Trigger | Inhalt |
|--------|---------|--------|
| Team-MA-Detail | Klick auf MA-Zeile in `team.html` | MA-Detail + Aktionen |
| Curriculum-Override | Aktion aus MA-Detail oder Team | Drag-Drop Kurs-Reihenfolge |
| Ad-hoc-Assignment | Aktion aus MA-Detail oder `assignments.html` | Kurs-Picker + Deadline + Reason |
| Freitext-Review | Klick auf Review in `freitext-queue.html` | Siehe §4.4 |
| Kurs-Admin | Klick auf Kurs in `admin/courses.html` | Metadaten + Publish-Toggle + Version-History |
| Curriculum-Template-Cell | Klick auf Zelle in `admin/curriculum.html` | Drag-Drop Kurs-Liste für Rolle × Sparte |

## 7. Datum-Eingabe-Regel (Konformität)

Alle Datum-Felder (Deadline-Picker in Ad-hoc-Assignment, Refresher-Ablauf-Anzeige) nutzen nativen `<input type="date">` mit Tastatur-Eingabe-Unterstützung (siehe CLAUDE.md Datum-Eingabe-Regel 2026-04-14).

## 8. Styling-Konventionen

- **Base-Tokens:** identisch mit CRM (Farben, Typo, Abstände, Shadows).
- **Farben:**
  - Primary: gleich wie CRM (Arkadium-Blau).
  - Score-Farbcodierung: rot < 50, gelb 50–79, grün ≥ 80 (konsistent über alle Score-Anzeigen).
  - Lock-State: neutral-grey-400 + Schloss-Icon.
- **Spacing:** 8 px Grid.
- **Component-Kits:** gleiche Base wie CRM (Shadcn-basiert oder was aktuell im Projekt ist — in Implementation-Plan festzulegen).

## 9. Umlaute-Regel + DB-Technikdetails-Regel (Konformität)

- **Umlaute:** echte UTF-8 (`ä ö ü Ä Ö Ü ß`). Niemals `ae`/`oe`/`ue`/`ss`.
- **Keine DB-Technikdetails in User-facing-Texten:** keine `dim_*`/`fact_*`/`_fk`/`_id`-Namen. Stattdessen sprechende Begriffe aus UI-Label-Vocabulary (siehe Stammdaten-Patch §3).
- **Admin-/Debug-Ausnahmen:** Admin-Sektionen in `mockups/` wrappen mit `<!-- ark-lint-skip:begin reason=admin-elearn -->…<!-- ark-lint-skip:end -->` (siehe `CLAUDE.md`).

## 10. Wiki-Sync

Nach Merge dieses Patches:

- `wiki/meta/mockup-baseline.md` — neuer Abschnitt „ERP-Workspace: E-Learning (Sub A)" mit Screenshot-Previews.
- `wiki/concepts/` — neue Seite `erp-workspace.md` mit Topbar-Toggle und Sidebar-Pattern-Dokumentation.
- `wiki/concepts/elearning-module.md` — UI-Teil dokumentieren.

## 11. Offene Punkte

- **PDF-Viewer-Library:** PDF.js oder react-pdf? In Implementation-Plan entscheiden.
- **Drag-Drop-Library:** native HTML5 DnD oder dnd-kit? Pro Komponente (Zuordnung, Reihenfolge, Curriculum-Matrix) zu prüfen.
- **Responsive-Breakpoints:** ERP-Workspace Desktop-First; Tablet-Support Phase-2; Mobile Phase-3.
- **A11y:** Quiz-Runner braucht ARIA-Live-Regionen für Score-Announcements; Screen-Reader-Testing in Implementation-Phase.
