# ARK CRM — Frontend-Freeze-Patch · E-Learning Sub C · v0.1

**Scope:** Frontend-Erweiterung für den Wochen-Newsletter (Sub C): MA-Pages, Admin-Pages, Components, Sidebar-Erweiterung.
**Zielversion:** Frontend-Freeze v1.11 (gemeinsam mit Sub A/B).
**Basis-Specs:** `specs/ARK_E_LEARNING_SUB_C_SCHEMA_v0_1.md`, `specs/ARK_E_LEARNING_SUB_C_INTERACTIONS_v0_1.md`.
**Vorherige Patches:** Sub A + Sub B Frontend-Patches.
**Stand:** 2026-04-20
**Status:** Review ausstehend (Peter)

---

## Changelog

| # | Bereich | Änderung |
|---|---------|----------|
| 1 | MA-Pages | +2 (newsletter.html, newsletter-issue.html) |
| 2 | Admin-Pages | +3 (newsletter-config, newsletter-archive, newsletter-queue) |
| 3 | Components | Newsletter-Reader mit Section-Timeline, Countdown-Widget, Enforcement-Badge |
| 4 | Sidebar | MA-Block + Admin-Block erweitert |
| 5 | Keyboard-Shortcuts | Newsletter-Reader Navigation |

---

## 1. MA-Pages

### 1.1 `erp/elearn/newsletter.html` — Übersicht

**Layout:**
- Topbar mit Tab-Navigation: **Aktuell** (N) | **Archiv** (M)
- Tab „Aktuell":
  - Grid aus Newsletter-Cards (eine pro offenem Assignment).
  - Card-Anatomie:
    - Sparte-Chip (farbkodiert: ARC=rot, GT=blau, ING=grün, PUR=violett, REM=orange)
    - Titel + Woche
    - Deadline-Countdown („noch 3 Tage")
    - Status-Badge (Offen / Beim Lesen / Quiz läuft / Abgelaufen)
    - Bei `enforcement_mode_applied='hard'`: rotes Pflicht-Banner am oberen Card-Rand
    - Action-Button „Jetzt lesen" / „Quiz starten" / „Weiterlesen"
- Tab „Archiv":
  - Listen-View, chronologisch, filterbar nach Sparte + Jahr + Quiz-Status.
  - Archivierte Issues (`status='archived'`) grau-out, aber weiterhin klickbar.

### 1.2 `erp/elearn/newsletter-issue.html?id=<issue_id>` — Reader

**Layout (single-page scroll, Max-Width 720 px Reading-Column):**

```
┌─────────────────────────────────────────────────────┐
│  ◀ Zurück        Sparte-Chip · KW17 · 2026          │
│                                                     │
│  <Hero-Titel>                                       │
│  <Subtitle mit Lese-Fortschritt 2/4 Sections>      │
├─────────┬───────────────────────────────────────────┤
│         │                                           │
│ Section │  <Section 1: Markt-News>                 │
│Timeline │  <Markdown-Body>                         │
│         │                                           │
│  ✓ 1    │                                           │
│  ○ 2    │  <Section 2: Team-Einblicke>             │
│  ○ 3    │  ...                                     │
│  ○ 4    │                                           │
│         │  <Section 3: Vertiefung>                 │
│ [Quiz]  │  ...                                     │
│(locked) │                                           │
│         │  <Section 4: Im Fokus>                   │
│         │  ...                                     │
└─────────┴───────────────────────────────────────────┘
  Sticky-Footer: ────────────────────────────────────
  [Quiz starten]  (disabled bis alle Sections gelesen)
```

**Features:**
- Linke Vertical-Timeline: Section-Navigation mit Scroll-Spy. Checkmark wenn `read_at IS NOT NULL`.
- Scroll-Tracker pro Section (Heartbeat `POST /progress` alle 10 s).
- Quiz-Button:
  - Disabled wenn nicht alle Sections `read_at` gesetzt.
  - Enabled + farbig wenn ready.
  - Klick → `POST /quiz/start` → Weiterleitung zu Sub-A-Quiz-Runner (`erp/elearn/quiz.html`).
- Enforcement-Badge oben rechts: bei `hard` = „Pflicht-Newsletter" rotes Label; bei `soft` = „Erinnerung" orange.

## 2. Admin-Pages

### 2.1 `erp/elearn/admin/newsletter-config.html`

**Sections:**

1. **Schedule**
   - Publish-Day (Cron-Picker oder Wochentag + Uhrzeit)
   - Reminder-Hours (Number-Input, Default 48)
   - Escalation-Days (Default 7)
   - Expiry-Days (Default 14)

2. **Sparten**
   - Multi-Select-Toggles für ARC, GT, ING, PUR, REM
   - Toggle „Sparte-übergreifender Newsletter"

3. **Enforcement**
   - Radio: Soft (Default) | Hard
   - Toggle „Auto-Opt-out erlauben" (Default: false)

4. **Content-Limits**
   - Min/Max Sections pro Ausgabe
   - Min/Max Fragen pro Quiz

5. **Archiv**
   - Retention-Monate (Default 24)

6. **Per-MA-Override-Liste**
   - Tabelle aller MA mit `newsletter_enforcement_override != NULL`
   - Edit-Button pro Zeile: Mode ändern oder Override entfernen

### 2.2 `erp/elearn/admin/newsletter-archive.html`

**Layout:**
- KPI-Widgets oben:
  - Aktive Issues (`published`)
  - Durchschnittliche Read-Rate (%)
  - Durchschnittliche Quiz-Pass-Rate (%)
  - Escalation-Quote (%)
  - Top-Sparten nach Engagement (Bar-Chart)

- Tabelle aller Issues:
  - Spalten: Sparte, Woche, Publish-Datum, Assignments, Read-Rate, Pass-Rate, Status
  - Klick auf Zeile → Drawer 540 px mit:
    - Section-Preview (Akkordeon)
    - Quiz-Preview mit Fragen-Liste
    - Metriken (gelesen / Quiz bestanden / expired)
    - Aktions-Buttons: Publishen (bei draft), Archivieren, Re-Generate

### 2.3 `erp/elearn/admin/newsletter-queue.html` (Head + Admin)

**Layout:**
- Filter: Team (Head-scoped auto-gefiltert), Sparte, Alter.
- Tabelle überfälliger Assignments:
  - MA-Name, Issue-Titel, Publish-Alter (Tage), Status, Escalation-Status
  - Aktionen: Manual-Reminder, Override-Mode (Head kann für einzelne MA temporär hard/soft setzen)

## 3. Components

### 3.1 Newsletter-Reader

- **Section-Timeline-Component:** Left-Rail mit Scroll-Anchor-Navigation. IntersectionObserver triggert Section-Active-State.
- **Scroll-Tracker-Hook:** analog Sub A Lesson-Viewer (`useScrollTracker`) — pro Section instanziiert.
- **Markdown-Renderer:** gleicher wie Sub A (Markdown + Embeds).

### 3.2 Countdown-Widget

- Zeigt „noch X Tage" bis `deadline`.
- Farbkodiert: grün > 3 Tage, gelb 1–3 Tage, rot < 1 Tag / überfällig.
- Tooltip mit konkretem Datum.

### 3.3 Enforcement-Badge

- Variante `soft`: orange Pill „Erinnerung".
- Variante `hard`: rote Pill „Pflicht-Lock".
- Tooltip erklärt den Modus.

### 3.4 Sparte-Chip

- Farbkodiert nach Sparte (konsistent im ganzen Modul).
- Icon-Prefix optional.

## 4. Sidebar-Erweiterung

**MA-Block (bestehend aus Sub A) → ergänzt:**

| Position | Label | Link |
|----------|-------|------|
| 1 | Meine Kurse | `dashboard.html` |
| 2 | **Mein Newsletter** | `newsletter.html` |

**Admin-Block (bestehend Sub B) → ergänzt:**

| Position | Label | Link |
|----------|-------|------|
| … | Content-Generator | `admin/content-gen.html` |
| … | Content-Sources | `admin/content-gen-sources.html` |
| … | Review-Queue | `admin/content-gen-review.html` |
| — | — Trenner „Newsletter" — | — |
| … | **Newsletter-Konfiguration** | `admin/newsletter-config.html` |
| … | **Newsletter-Archiv** | `admin/newsletter-archive.html` |
| … | **Newsletter-Queue** | `admin/newsletter-queue.html` |

## 5. Keyboard-Shortcuts

### 5.1 Newsletter-Reader (`newsletter-issue.html`)

| Shortcut | Aktion |
|----------|--------|
| `Space` / `PageDown` | Scroll to next section |
| `PageUp` | Previous section |
| `Q` | Quiz starten (wenn eligible) |
| `Esc` | Zurück zu Newsletter-Übersicht |

### 5.2 Admin-Archive-Drawer

| Shortcut | Aktion |
|----------|--------|
| `J` / `K` | Next / Prev Issue |
| `P` | Publishen (bei draft) |
| `A` | Archivieren |
| `Esc` | Drawer schliessen |

## 6. Dashboard-Banner (für Sub A Dashboard)

**Hinweis:** Sub A `dashboard.html` bekommt neuen Banner-Block:

```
┌─────────────────────────────────────────────────────┐
│  📬 Newsletter KW17 bereit zum Lesen (Sparte ARC)  │
│  [Jetzt lesen]  noch 5 Tage                         │
└─────────────────────────────────────────────────────┘
```

- Nur sichtbar bei Assignments `status IN ('pending', 'reading')`.
- Bei `hard`-Enforcement: prominenter (rot, pulsierend).

## 7. Mobile/Responsive

- **Newsletter-Reader Mobile:** Section-Timeline wird zu horizontal-scroll oben. Max-Width-Column rückt auf 100 %.
- **Admin-Pages:** Tabellen mit Horizontal-Scroll. Config-Form single-column.

## 8. Design-System-Konformität

- Echte Umlaute UTF-8.
- Drawer 540 px für Admin-Detail-Drawers.
- Datum-Picker nativ.
- Keine DB-Tech-Details in User-facing-Texten (Label-Vocabulary aus Stammdaten-Patch Sub C).
- Sparte-Farbcodierung **konsistent mit CRM** (falls bereits definiert — sonst neues Color-Mapping in Mockup-Baseline hinzufügen).

## 9. A11y

- Section-Timeline mit ARIA-Tree-Role.
- Countdown-Widget mit ARIA-Live-Region bei Status-Wechsel (< 1 Tag).
- Quiz-Start-Button mit klarem `aria-disabled`-State und Tooltip warum disabled.

## 10. Wiki-Sync

- `wiki/meta/mockup-baseline.md` — ERP-Workspace-Abschnitt um Sub-C-Pages ergänzen.
- `wiki/concepts/elearning-module.md` — UI-Teil Sub C.
- Neue Wiki-Seite `wiki/concepts/newsletter-enforcement.md` — Soft vs Hard Enforcement Guide.

## 11. Offene Punkte

- **Sparte-Farb-Mapping:** falls im CRM noch nicht definiert, im Mockup-Baseline einheitlich festlegen. Vorschlag: ARC=#D32F2F, GT=#1976D2, ING=#388E3C, PUR=#7B1FA2, REM=#F57C00, uebergreifend=#616161.
- **Ad-hoc-Newsletter-Ausgabe:** Admin kann manuell Sonder-Newsletter erstellen ausserhalb des Wochen-Schedulings? Phase-2 UI-Addition (Backend-Endpoint `POST /generate` existiert bereits).
- **Newsletter-Embeds:** Bilder/YouTube-Embeds in Sections erlaubt? Default ja (gleicher Markdown-Renderer wie Sub A).
