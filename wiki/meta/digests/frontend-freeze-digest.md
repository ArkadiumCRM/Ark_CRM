---
title: "Frontend-Freeze v1.10.5 — Digest"
type: meta
created: 2026-04-17
updated: 2026-04-17
last_regen: 2026-04-17T18:10
sources: ["ARK_FRONTEND_FREEZE_v1_10.md"]
tags: [digest, frontend, freeze, routing, design-system]
---

# Frontend-Freeze v1.10.5 — Kompakt-Digest (Stand 2026-04-17)

Quelle: `Grundlagen MD/ARK_FRONTEND_FREEZE_v1_10.md` (~4050 Zeilen; v1.10 + v1.10.4 Dok-Generator-Addendum §4e + v1.10.5 Email-Kalender-Addendum §4f, 2026-04-17). Dieser Digest gibt Routing, Detailmasken-Inventar, Design-System-Regeln, Komponenten und Interaction-Pattern-Referenzen verlustfrei wieder. Pixel-/Padding-/Animation-Details sind bewusst weggelassen — bei Bedarf Original-§ lesen.

## TOC (§-Sections der Quelle)

```
0    Zielbild
1    22 Grundregeln (REGEL 01–22)
2    Tech Stack + TypeScript Flags + Version Pinning
3    Architekturprinzipien
4    Informationsarchitektur (Phase-1-/Phase-2-Module)
4b   Dashboard — Modul-Spezifikation
4c   Kernmodul-Spezifikationen Phase 1
4d   UI-Detailspezifikation (Masken, Tabs, Felder)
4d.0 Globale UI-Patterns
4d.1 Kandidaten-Detailmaske
4d.2 Account-Detailmaske (+ Erweiterungen 4d.2.8/9/13 v1.10)
4d.3 Mandate-Detailmaske
4d.4 Jobs-Detailmaske (NEU v1.10)
4d.5 Firmengruppen-Detailmaske (NEU v1.10)
4d.6 Assessments-Detailmaske (NEU v1.10, typisierte Credits)
4d.7 Projekte-Detailmaske (NEU v1.10, 3-Tier BKP/SIA)
4d.8 Scraper-Control-Center (NEU v1.10)
4e   Operations · Dok-Generator (NEU v1.10.4, 2026-04-17)
4f   Operations · Email & Kalender (NEU v1.10.5, 2026-04-17)
5    Ordnerstruktur
6    Shell und Navigation (inkl. Produkt-Navigation)
6b   URL State Governance und Privacy
6c   Tenant-Scope für Stores und Caches
7    Routenmodell
8    Designsystem
8b   Design System Governance
8c   ARK CI-Farbpalette (Dark Default + Light Mode)
9    Kernkomponenten (DataTable, FilterBar, Command Palette, Markdown, Gates)
9.7  Detailseiten-Navigation (Vollseiten-Pattern)
9.8  Process Stage Pipeline Component (Shared)
9.9  Activity-Linking-Pattern
10   State Management (TanStack Query, Zustand, Forms, Optimistic)
11   API Integration (zwei Axios-Instanzen, Interceptors, Rate-Limit)
11b  Rendering Strategy (RSC / CSR)
11c  Next.js Middleware — Edge Auth
11d  Content Security Policy (CSP)
11e  Zod Schema Strategy (ts-to-zod)
12   Globales Toast/Notification-System
13   Auth und Session
13b  Frontend Permission Model (4 Ebenen)
13c  Field Permission States + resolveFieldRenderState()
14   Electron (IPC, Protocol Handler, Code Signing, Sandbox)
15   Permissions und Sichtbarkeit
16   Realtime und Sync (Supabase Realtime, WebSocket Reconnect)
16b  Query Key und Cache Invalidation Policy
16c  Session Bootstrap + Multi-Tab (BroadcastChannel)
16d  Platform Capability Matrix (Web vs. Electron)
16e  Form und Concurrency Patterns
16f  Keyboard Shortcut Matrix
16g  Leere, Fehler und Konfliktzustände
16h  Query Cache TTL — Ressourcengruppen
16i  Bulk UX (sync, async, Fehlerreport, Limits)
16j  Print und Export UX
16k  Navigation Recovery (Soft-Delete, 403, Protocol Handler)
16l  Saved Views und Workspace Memory (Privacy Guardrails)
16m  Import / Export UX (Column Mapping, Dry Run)
16n  Feature Flags und Rollout Strategy (Flag ≠ Permission)
16o  Internationalisierung und Locale (de-CH, Intl.Collator)
16p  UI Auditability — Änderungsverlauf
16q  Offline und Degraded Connectivity
16r  File Handling UX und Security
16s  Search UX Governance (drei Paradigmen)
16t  User Preferences Policy
16u  Long-running Tasks UX
17   Dokumente und Uploads → siehe 16r
17b  Dokument-Pipeline UI pro Stufe
17c  Realtime Presence (Lebenszyklus, Heartbeat, TTL)
18   AI, Matching und RAG UX
18b  AI Explainability UI Standard
19   Fehlerbehandlung
20   Performance + Bundle-Budget
21   Offline, Netzwerk und Desktop → siehe 16q
21b  React Error Boundary Strategie (Route, Drawer, Widget)
22   Accessibility (A11y)
22b  Session Multi-Tab (BroadcastChannel)
23   Observability
24   Testing
24b  Responsive Policy (Desktop-First + Mobile/Tablet voll — v1.11 rewrite)
24c  ESLint Architekturregeln + Import Boundaries
25   Developer Experience
26   Build-Reihenfolge (Wellen 1–4)
27   Fazit
```

---

## Routing Map (lossless)

Alle Routen sind englisch (Konvention v1.10). Detailansichten = Vollseite (Ausnahme: Prozesse — Mischform Listen-Drawer + schlanke Detailseite).

| URL | Zweck / Komponente |
|---|---|
| `/login` | Login-Seite (RSC) |
| `/reset-password` | Passwort-Reset |
| `/` | Dashboard |
| `/candidates` | Kandidaten-Liste |
| `/candidates/[id]` | Kandidaten-Detailmaske (10 Tabs, Vollseite) |
| `/accounts` | Accounts-Liste |
| `/accounts/[id]` | Account-Detailmaske (13 Tabs + 1 konditional, Vollseite) |
| `/contacts` | Kontakte-Liste (Sub-Liste/Modul) |
| `/contacts/[id]` | Kontakt-Detail (Drawer-basiert, Sub-Entität) |
| `/company-groups` | Firmengruppen-Liste |
| `/company-groups/[id]` | Firmengruppen-Detailmaske (6 Tabs, Vollseite) |
| `/jobs` | Jobs-Liste |
| `/jobs/[id]` | Jobs-Detailmaske (6 Tabs, Vollseite) |
| `/mandates` | Mandate-Liste |
| `/mandates/[id]` | Mandate-Detailmaske (6 Tabs, Vollseite) |
| `/processes` | Prozess-Listen-Modul mit Slide-in-Drawer (Primary Workflow, 80%) |
| `/processes/[id]` | Prozess-Detailseite (3 Tabs schlank, 20% komplex + Deep-Linking) |
| `/projects` | Projekte-Liste (inkl. Kartenansicht Phase 2) |
| `/projects/[id]` | Projekte-Detailmaske (6 Tabs, Vollseite, 3-Tier BKP/SIA) |
| `/assessments` | Assessments-Liste |
| `/assessments/[id]` | Assessments-Detailmaske (5 Tabs, typisierte Credits) |
| `/scraper` | Scraper-Control-Center (6 Tabs, globales System-Modul, kein `[id]`) |
| `/operations/dok-generator` | Globaler Dok-Generator (NEU v1.10.4, 5-Step-Workflow, Sibling zu Email & Kalender/Reminders/Scraper) |
| `/operations/email-kalender` | Email & Kalender (NEU v1.10.5, Single-Page-Maske mit Mode-Toggle Email↔Kalender, 8 Drawer, MS-Graph User-Tokens, CodeTwo-Signatur) |
| `/documents` | Dokumente (Deep-Link, nicht in Sidebar) |
| `/documents/[id]` | Dokument-Detail |
| `/reminders` | Reminders-Vollansicht (NEU v1.10.5, 3. Tool-Maske) — Liste + Kalender, Scope-Switcher (self/team/all via `dim_mitarbeiter.vorgesetzter_id`), Saved-Views (Storage `dashboard_config.reminders`), Drag-to-Reschedule, Keyboard N/V/E/S |
| `/notifications` | Notification-Vollseite (aus Bell-Icon) |
| `/search` | Strukturierte Suche + RAG-Tab (Deep-Link) |
| `/matching` | Matching-Modul (Deep-Link) |
| `/ai-review` | AI Review Inbox |
| `/market-intelligence` | Market Intelligence |
| `/settings` | Settings (Profil, Benachrichtigungen, Sessions, Locale) |
| `/settings/appearance` | Theme-Toggle (Dark/Light/System) |
| `/admin` | Admin-Bereich (User-Mgmt, Tenant-Config, Automation-Settings, Audit, Event-Chain Explorer) |

Renames v1.10: `/firmengruppen` → `/company-groups`, `/projekte` → `/projects`. Neu: `/assessments/[id]`, `/scraper`, `/company-groups/[id]`, `/jobs/[id]`, `/projects/[id]`.

Electron Protocol: `ark-crm://candidates/[uuid]`, `ark-crm://accounts/[uuid]`, `ark-crm://mandates/[uuid]`, `ark-crm://actions/call-log`.

---

## Detailmasken (lossless)

Status-Matrix v1.10 (Stand 2026-04-14 — alle 9 Detailseiten Schema + Interactions spezifiziert):

| # | Detailseite | Route | Tabs | Schema | Interactions | Zweck |
|---|---|---|---|---|---|---|
| 1 | Kandidaten | `/candidates/[id]` | 10 | v1.2 | v1.2 | Kandidat-Stammdaten, Briefing, Werdegang, Assessments, Jobbasket, Prozesse |
| 2 | Accounts | `/accounts/[id]` | 13+1 | v0.1 | v0.3 | Kunden-/Zielfirma-Stammdaten, Kontakte, Mandate, Teamrad |
| 3 | Firmengruppen | `/company-groups/[id]` | 6 | v0.1 | v0.1 | Holding + Gesellschaften (2-stufig flach), gruppenweit Schutzfrist |
| 4 | Mandate | `/mandates/[id]` | 6 | v0.1 | v0.3 | Mandats-Stammdaten, Longlist, Prozesse, Billing |
| 5 | Jobs | `/jobs/[id]` | 6 | v0.1 | v0.1 | Stellen-Details, Jobbasket, Matching, Stellenausschreibung-Generator |
| 6 | Prozesse | `/processes/[id]` + Drawer | 3 | v0.1 | v0.1 | Kandidat×Account×Job-Prozess mit Stage-Pipeline (Mischform) |
| 7 | Assessments | `/assessments/[id]` | 5 | v0.2 | v0.2 | Auftrags-Entity mit typisierten Credits (11 Typen) |
| 8 | Projekte | `/projects/[id]` | 6 | v0.2 | v0.1 | Bau-/Infrastruktur-Projekt mit 3-Tier Projekt→Gewerk(BKP)→Beteiligte |
| 9 | Scraper | `/scraper` | 6 | v0.1 | v0.1 | Globales Control-Center (Dashboard, Review-Queue, Runs, Configs, Alerts, History) |

### 4d.1 Kandidaten-Detailmaske — 10 Tabs
1. Übersicht/Stammdaten · 2. Briefing (versioniert) · 3. Werdegang · 4. Assessment (6 Untertabs: Gesamtüberblick, Scheelen & Human Needs, App, AI-Analyse, Vergleich, Teamrad) · 5. Jobbasket/GO-Flow · 6. Prozesse · 7. History · 8. Dokumente · 9. Dokumenten-Generator (ARK CV/Abstract/Exposé) · 10. Reminders.

### 4d.2 Account-Detailmaske — 13 Tabs + 1 konditional
1. Übersicht · 2. Profil & Kultur · 3. Kontakte · 4. Standorte · 5. Organisation (Stellenplan + Teamrad) · 6. Jobs & Vakanzen · 7. Mandate · **8. Assessments (NEU v1.10)** · **9. Schutzfristen (NEU v1.10)** · 10. Prozesse · 11. History · 12. Dokumente · **13. Reminders (NEU v1.10)** · +1 Firmengruppe (konditional).

### 4d.3 Mandate-Detailmaske — 6 Tabs
Übersicht · Longlist (Kanban 10 Spalten + Durchcall-Funktion) · Prozesse · Billing · History · Dokumente.

### 4d.4 Jobs-Detailmaske — 6 Tabs
Übersicht (Stammdaten, Stellenplan-Ref, Markdown-Beschreibung, Konditionen, Matching-Kriterien, Sichtbarkeit) · Jobbasket (Pipeline 6 Stages) · Matching (7-Sub-Score-Tabelle + Radar) · Prozesse · Dokumente (Stellenausschreibung-Generator DE/FR/IT/EN) · History. Lifecycle `scraper_proposal → vakanz → aktiv → besetzt → geschlossen`. 4 Erstellungs-Wege: Scraper, manuell, aus Mandat (Taskforce), aus Stellenplan.

### 4d.5 Firmengruppen-Detailmaske — 6 Tabs
Übersicht · Kultur (6 Dimensionen + Gesellschafts-Vergleich) · Kontakte (aggregiert) · Mandate & Prozesse · Dokumente (Rahmenvertrag, Master-NDA, Konzern-AGB mit `applies_to_account_ids`) · History. Erstellung via UID-Match (Zefix, ≥85% auto) oder manuell durch Founder.

### 4d.6 Assessments-Detailmaske — 5 Tabs
Übersicht (Credits-Tabelle pro Typ) · Durchführungen (Kern, Typ-Filter) · Billing (`full` Default) · Dokumente (Offerte, Summaries, Reports) · History. Credits-Modell typisiert, 11 Typen: MDI / Relief / ASSESS 5.0 / DISC / EQ / Scheelen 6HM / Driving Forces / Human Needs / Ikigai / AI-Analyse / Teamrad-Session. Umwidmung nur innerhalb gleichen Typs, kein Verfall. Versionierung via `fact_candidate_assessment_version`.

### 4d.7 Projekte-Detailmaske — 6 Tabs
Übersicht (Öffentlich + Arkadium-intern getrennt) · Gewerke (BKP, Kern-Arbeitsumgebung) · Matching · Galerie (Masonry) · Dokumente · History. 3-Tier: Projekt → Gewerk (BKP) → Beteiligungen (Firmen + Kandidaten mit SIA-Phasen, 6 Haupt + 12 Teilphasen). Klassifikation via `bridge_project_clusters` + `bridge_project_spartens`. 3 Erstellungs-Wege: manuell, aus Kandidat-Werdegang, Scraper (simap/Baublatt/TEC21).

### 4d.8 Scraper-Control-Center — 6 Tabs
Dashboard (Ampel-System, AI-Anomalie-Radar) · Review-Queue (Kern, 10 Finding-Typen, Bulk-Accept ≥80%) · Runs (Diff-View) · Configs (7 Scraper-Typen: Team-Page / Career-Page / Impressum / LinkedIn Phase 2 / Jobboards / PR-Reports / Handelsregister) · Alerts & Fehler (9 Alert-Typen, 4 Severities) · History. Confidence-Schwellen: ≥85% Auto, 60–84% Review, <60% `needs_am_review`. WebSocket-Live <2s. **Mockup:** `mockups/scraper.html` als Single-File mit 6 internen Tabs (konsistent zu `dok-generator.html`/`email-kalender.html`/`reminders.html`), Routing via `switchTab()`-JS, Keyboard 1–6. **Quick-Actions:** "▶ Jetzt scrapen (Bulk)" / "📊 Report" (Configs-Button entfernt 17.04.2026 — Redundanz zu Tab 4, Patch v0.2 P5).

---

## Design-System Rules

### Drawer-Regel (CLAUDE.md Drawer-Default, §4)
- **Drawer (540px Slide-in von rechts, Default)**: CRUD, Bestätigungen, Mehrschritt-Eingaben, Unterentitäten (Kontakte, History-Einträge, Projekt-Slide-In), Quick-Edits (1–5 Felder), Reminder/Notiz erstellen.
- **Modal nur für**: kurze Confirms, Blocker, Forced Reauth, System-Notifications, Placement-Modal (8-Step-TX, KEIN Optimistic Update).
- **Vollseite**: Hauptdetailansichten Kandidat / Account / Job / Mandat / Prozess / Firmengruppe / Projekt / Assessment — immer. Kein Nested Drawer. Navigation zwischen Entitäten via `router.push()`.
- **Im Slide-In: Tabs** zur Strukturierung — kein Slide-In im Slide-In.
- Schliessen via X, Escape, Klick ausserhalb.

### Header-Layout (pro Detailseite)
- Identität/Klassifizierung/Status oben (banner-meta + banner-chips + Status-Dropdown + Mandat-Badge/Package-Badge/etc.).
- Quick-Actions rechts (entity-spezifisch, siehe Shortcuts-Katalog unten).
- Breadcrumb-Konvention: **2-stufig** Default (Kandidat/Account/Mandat/Firmengruppe/Projekt), **4-stufig** bei Sub-Entitäten (Jobs unter Account, Prozesse aus Kandidat/Account, Assessments), **1-stufig** für System-Module (Scraper).
- "Zuletzt geändert"-Zeile (last_modified_at + last_modified_by + source_system) immer sichtbar.

### Snapshot-Bar (Fix 6 Slots, sticky unter Header)
Vereinheitlicht 2026-04-16. Sticky `top:0, z-index:50` unter Page-Banner; Tabbar folgt sticky mit `top:64px, z-index:49`. Auf Tablet 3×2 statt 6×1. CSS-Classes `.snapshot-bar` + `.snapshot-item` (lbl/val/delta). Optional `.ms-progress > .bar[.green|.amber|.red]`.

**Dupe-Regel (CRITICAL):** Snapshot-Slots dürfen NICHT duplizieren, was in banner-meta / banner-chips / Status-Dropdown / Mandat-Badge steht. Header = Identität/Status, Snapshot = operative Zahlen.

Slot-Allokation:
- Account: Mitarbeitende · Wachstum 3J · Umsatz · Gegründet · Standorte · Kulturfit
- Kandidat: Ø Match-Score · Im Jobbasket · Aktive Prozesse · Refresh-Due · Placements hist. · Assessments
- Mandat: Idents · Calls · Shortlist · Pauschale · Time-to-Fill · Placements (3 mit Progress-Bars)
- Firmengruppe: Gesellschaften · Mitarbeitende · Umsatz · Aktive Prozesse · Placements YTD · Arkadium-Umsatz YTD
- Job: Matches ≥70% · Im Jobbasket · Aktive Prozesse · Standort · TC-Range · Ø Match-Score
- Projekt: Volumen · Zeitraum · BKP-Gewerke · Beteiligte Firmen · Beteiligte Kandidaten · Medien
- Prozess: Stage-Alter · Nächstes Interview · Win-Probability · Pipeline-Wert · CM/AM · Garantie

**Ausnahmen 7 Slots**: Assessment (Credits-Mix), Scraper (Live-KPIs via WebSocket), Projekt (Zeitraum-Sonderslot).

### Tab-Structure
- Klick auf Oberreiter öffnet Listen-/Suchansicht zuerst; erst Klick auf Eintrag → Detailansicht.
- Tab-Zahlen pro Detailmaske: siehe Detailmasken-Tabelle oben.
- Versionierung (Briefings, Assessments): **Pfeil-Navigation** `← [Datum] →`, aktuellste Version default, "Neue Version" legt neuen Datensatz an, ältere bleiben vollständig erhalten.

### Card-Pattern & Pipeline
- **Process Stage Pipeline Component** (§9.8, shared): zwei Modi `detailed` (Prozess-Detailmaske, SVG-Linie + WinProb-Panel 280px rechts + Stage-Popover mit Pflicht-Grund) und `compact` (Listen-Karten, SVG inline oder CSS-only-Fallback ab 50 Karten). Ersetzt `.pst-step` (deprecated v1.1), `.pr-stage-track`/`.pr-stage-pop` → konsolidiert unter `.ark-pl-*`. Skip-Regeln V1-Saga-konform: Forward bis Angebot mit Grund erlaubt; Platzierung ausschliesslich via Placement-Drawer 8-Step-Saga. Single Source of Truth: `specs/ARK_PIPELINE_COMPONENT_v1_0.md`.
- Single-Source-of-Truth: `specs/ARK_PIPELINE_COMPONENT_v1_0.md`.

### Datum-Eingabe-Regel (CLAUDE.md Datum-Eingabe-Regel, §14)
Alle Datum-/Zeit-Felder: natives `<input type="date">` / `datetime-local` / `time` — Kalender-Picker UND manuelle Tastatur-Eingabe Pflicht, kein Click-only-Picker.

### Density & Theme
- **Density-Modi**: kompakt · normal (Default) · komfort (tenant-aware, Backend-persist).
- **Dark Mode Default + Light Mode** (user-umschaltbar via `/settings/appearance`). `data-theme="dark|light"` auf `<html>`, geladen aus `dim_crm_users.theme_preference ENUM('dark','light','system')`. Komponenten referenzieren ausschliesslich CSS-Variablen. WCAG AA Pflicht.
- **Motion**: nur funktional, `prefers-reduced-motion` respektieren.
- **Zahlen**: `tabular-nums` überall (CHF, %, Datum dd.MM.yyyy).

### Produkt-Navigation + Sidebar-Gruppierung
- **Ober-Oberreiter (Produkt-Nav)**: CRM (aktiv) · Zeiterfassung · Billing · Analysen & Reporting · HR & Entwicklung (alle Phase 2, ausgegraut).
- **Sidebar Gruppe 1 (9 Haupteinträge)**: Dashboard · Kandidaten · Accounts · Firmengruppen · Jobs · Mandate · Prozesse · Projekte · Scraper.
- **Gruppe 2**: Market Intelligence.
- **Gruppe 3 (System)**: Admin · Settings.
- Nicht in Sidebar (nur Deep-Link): Dokumente, Suche (via Cmd+K primär), Matching, Reminders, Notifications.

---

## Color-Tokens (lossless Katalog)

### CI-Primärfarben
```
ark-black:         #262626   Sidebar, Karten, primäre Flächen
ark-gold:          #dcb479   Primärer Akzent, aktive States, CTAs
ark-teal-dark:     #1b3051   Sekundärer Akzent, tiefe Hintergründe
ark-teal:          #196774   Tertiärer Akzent, Avatare, Links, Hover
ark-light:         #eeeeee   Primärer Text auf dunklen Flächen
ark-sidebar-hover: #383838   Sidebar Hover, erhöhte Flächen
```

### Funktions-Farben
```
Success:  #22c55e   Aktiv, Besetzt, Placed
Warning:  #f59e0b   On Hold, Warm, Überfällig
Danger:   #ef4444   Rejected, Hot, Datenschutz, Fehler
Info:     #0ea5e9   Market Now, Open, Info-Benachrichtigung
```

### Kandidaten-Stage-Farben
```
Check:            #808080
Refresh:          #f59e0b
Premarket:        #a855f7
Active Sourcing:  #22c55e
Market Now:       #0ea5e9
Inactive:         #666666
Blind:            #4d4d4d
Datenschutz:      #ef4444
```

### Temperature
```
Hot:  #ef4444 · Warm: #f59e0b · Cold: #0ea5e9
```

### Wechselmotivation (8 Stufen)
```
Arbeitslos:                          #ef4444
Will/muss wechseln:                  #f97316
Will/muss wahrscheinlich wechseln:   #f59e0b
Wechselt bei gutem Angebot:          #eab308
Wechselmotivation spekulativ:        #a3a3a3
Wechselt intern & wartet ab:         #0ea5e9
Will absolut nicht wechseln:         #6b7280
Will nicht mit uns zusammenarbeiten: #991b1b
```

### Einkaufspotenzial
```
★     (1): text-foreground-muted
★★    (2): text-ark-gold
★★★   (3): text-ark-gold, font-bold
```

Implementierung: CSS-Variables in `globals.css` (HSL), Tailwind-Custom-Colors `ark-gold`, `ark-teal`, `surface-*`, `stage-*`, `temp-*`. Vollständige Token-Palette beider Themes: `wiki/concepts/design-tokens.md`.

---

## Components (lossless Namen)

### shadcn/ui-Basis (`components/ui/`)
shadcn-Komponenten, angepasste Tokens, keine Logik. Einzige Komponenten-Basis (kein Wildwuchs, kein zweites Date-Picker / Select / Modal).

### Shared (`components/shared/`)
- **DataTable** (TanStack Table + TanStack Virtual, Pflicht für Hauptlisten)
- **FilterBar** (Debounce 200ms Standard / 500ms Heavy)
- **StatusBadge**
- **EntityCard**
- **Timeline**
- **SearchPalette**
- **CommandPalette** (cmdk)
- **EmptyState**
- **Skeletons**
- **PermissionGate** (show/hide · read-only · maskiert · disabled mit Tooltip)
- **FeatureFlagGate** (show/hide für Feature-Availability)
- **DetailDrawer**
- **ErrorState**
- **ErrorBoundary** (Route-/Drawer-/Widget-Level)
- **ToastSystem**
- **PresenceIndicator**
- **BulkActionBar**
- **ExportButton**
- **MarkdownRenderer** (react-markdown + rehype-sanitize — NICHT DOMPurify direkt)
- **MarkdownEditor** (Textarea + Preview-Toggle)

### Feature-Module (`components/candidates/`, `/accounts/`, `/contacts/`, `/jobs/`, `/mandates/`, `/processes/`, `/documents/`, `/reminders/`, `/notifications/`, `/matching/`, `/ai/`, `/analytics/`, `/dashboard/`)

### Design-System-Komponenten v1.10 (neu/benannt)
- **PipelineBar** / **ProcessStagePipeline** (§9.8, Modi `detailed` / `compact`, ersetzt `.pst-step`)
- **SnapshotBar** (6 Slots fix, Dupe-Regel, `.snapshot-bar`)
- **StageTransitionDrawer** (Placement-Modal, 8-Step-TX, kein Optimistic)
- **ActivityTimeline** (mit `data-activity-id`-Anchor)
- **Versionierungs-Pfeil-Nav** (Briefing/Assessment)

### Hooks (`hooks/`)
useAuth · usePermissions · useKeyboard · useDebounce · useNetworkStatus · useRealtimeChannel · useEntityDrawer · useUrlFilters · useTenant · usePresence · useErrorBoundary · useBulkAction · useFeatureFlag.

### Stores (`stores/`) — alle tenant-aware (ausser sidebar, theme, toast)
ui.store · filter-presets.store · command-palette.store · table-preferences.store · workspace.store · toast.store.

---

## Interaction-Patterns Reference (§-numbers für CLAUDE.md Cross-Refs)

Aus `wiki/concepts/interaction-patterns.md`:

| § | Topic |
|---|---|
| §4 | **Drawer-Default-Regel** — CRUD / Bestätigungen / Mehrschritt als 540px-Drawer (zitiert in CLAUDE.md) |
| §14 | **Datum-Eingabe-Regel** — native `<input type="date">` mit Kalender-Picker UND Tastatur-Eingabe (zitiert in CLAUDE.md) |
| §14a | **Terminologie Briefing vs. Stellenbriefing** — Briefing = Kandidat-Seite (Eignungsgespräch); Stellenbriefing = Account-/Mandats-Seite (Kunde ↔ Stelle). Nicht vermischen. (zitiert in CLAUDE.md) |

Weitere CLAUDE.md-Regeln mit Pattern-Bezug (nicht in interaction-patterns.md, aber Frontend-relevant):
- **Datei-Schutz-Regel** — Backups vor Bulk-Edits >5 KB, Edits via Edit/Write, nie `open('w')`.
- **Umlaute-Regel** — ä ö ü Ä Ö Ü ß UTF-8 Pflicht.
- **Keine-DB-Technikdetails-im-UI-Regel** — keine `dim_*` / `fact_*` / `bridge_*` / `*_id` in User-facing Texten.
- **Arkadium-Rolle-Regel** — Arkadium nicht-teilnehmend bei Interviews (TI/1st/2nd/3rd/Assessment = Kunde ↔ Kandidat); Arkadium-Touchpoints: Briefing / Coaching / Debriefing / Referenzauskunft.
- **Activity-Linking-Regel** (§9.9 im Frontend-Freeze) — UI-Felder sind Projektionen von `fact_history`, mit `data-activity-id` + Click öffnet History-Drawer.
- **Schutzfrist-Regel** — 12/16-Mt-Direkteinstellungs-Schutzfrist getrennt von 3-Mt-Post-Placement-Garantie; bei Placement Status `honored`.
- **Stammdaten-Wording-Regel** — gegen `ARK_STAMMDATEN_EXPORT_v1_3.md` prüfen (Stages, Mandat-Typen, Activity-Types §14, Sparten, EQ-Dimensionen, Motivatoren).
- **Spec-Sync-Regel** — 5 Grundlagen × 9 Detailmasken Sync-Matrix, siehe `wiki/meta/spec-sync-regel.md`.

---

## Keyboard Shortcuts (v1.10 Ergänzungen)

Global: `Cmd/Ctrl+K` Command Palette · `Cmd/Ctrl+/` Cheatsheet · `Escape` schliesst Drawer/Dialog.

Listen: `↑/↓` navigieren · `Enter` Drawer/Detail · `Space` select · `Cmd+A` alle · `R` reload · `N` neu erstellen.

Detail: `Cmd+Enter` speichern · `Cmd+E` Edit · `Cmd+←` zurück · `←/→` Prev/Next Entity.

Entity-spezifisch v1.10:
- Mandat: `🛑` Header Kündigungs-Drawer · `⚡` Option buchen
- Assessment: `+` Credit zuweisen · `R` Report übertragen
- Scraper: `A`/`X` Accept/Reject · `Shift+A` Bulk-Accept ≥80%
- Projekt: `G` Gewerk hinzufügen · `F`/`K` Firma/Kandidat in Gewerk
- Firmengruppe: `+` Gesellschaft hinzufügen · `M` Neues Gruppen-Mandat

---

## Sonstige lossless Kern-Listen

### 22 Grundregeln (REGEL 01–22) — Kurzbezeichnung
01 Backend=Source of Truth · 02 tenant_id nur aus Backend-Kontext · 03 Permissions nie nur UI · 04 zentraler API-Client · 05 Server-State vs UI-State trennen · 06 RHF+Zod · 07 Optimistic nur mit Rollback · 08 Stage-Changes MÜSSEN Optimistic · 09 keine PII in localStorage/URL · 10 Hauptdetails=Vollseiten · 11 Keyboard-First · 12 TanStack Virtual Pflicht · 13 API-Types generiert · 14 kein Optimistic bei komplexen Writes/AI/Merge · 15 kein PII-Suchtext in URL · 16 Stores tenant-aware · 17 withCredentials nur für /auth/* · 18 kein Token-Broadcast · 19 Presence rein indikativ · 20 kein SSR von sensiblen Daten · 21 Markdown via Sanitizer · 22 UUID in URL erlaubt.

### Query Cache TTL (Ressourcengruppen, §16h)
Stammdaten 30/60 min · Entitäts-Details 5/15 min · Listen 2/10 min · Dashboard KPIs 2/5 min · Notifications/Reminders 0/5 min · Matching/AI 1/10 min · Presence nie gecacht.

### Responsive Policy (§24b · v1.11 REWRITE 2026-04-17)
**Voller Mobile-/Tablet-Support** (alte Blocker-Regel raus).
- **Desktop > 960 px:** primärer Power-User-Mode, Sidebar 56 px hover-expand 240 px, Keyboard-Shortcuts
- **Tablet 641–960 px:** Sidebar 56 px + Pin-Toggle ⇔, Hover aus (Touch), KPI 3-col
- **Mobile ≤ 640 px:** Top-Bar 52 px + ☰ Slide-Out-Drawer 280 px, KPI 2-col, DataTable → Card-Stack, Drawer → Full-Screen-Sheet 100vw×100vh, Tabs/Filter-Bar/Chip-Group horizontal scrollbar, 3-Pane-Layouts → Pane-Toggle `data-pane="folders/list/reader"`, Tool-Sidebars (Dok-Gen 280 px) → Slide-in-Drawer
- **Safe-Area-Inset:** `<meta viewport-fit=cover>` + `env(safe-area-inset-top/bottom)` in allen 22 Mockup-HTMLs
- **Touch-Targets:** min 36×36 px, primär 44×44 px
- **Test-Tool:** `mockups/crm-mobile.html` = 3-iframe-Device-Frames-Demo

### Bundle-Budget (§20)
Initial ≤200 kB gzip · Per-Route-Chunk ≤100 kB · Recharts / Drawers / komplexe Forms lazy.

### Build-Wellen (§26)
- **Welle 1 Fundament**: Shell, Auth, Middleware, Query Provider, API-Client, Gates, DataTable, FilterBar, Candidate List+Detail, Locale, Toast.
- **Welle 2 Kern-CRM**: Accounts, Contacts, Mandates, Processes (Stage-Change), History Timeline, Notifications, Reminders, Command Palette, Workspace, Dashboard.
- **Welle 3 Erweitert**: Documents, Search (strukturiert+RAG), Matching, AI Review, Realtime Presence, Market Intelligence, Bulk, Export/Import, Auditability, Merge/DQ.
- **Welle 4 Abschluss/Desktop**: Admin, Settings, Electron (Protocol Handler, Single Instance, Auto-Update, Code Signing), Error Boundaries, ESLint Boundaries, Storybook/Chromatic, Bundle-Budget-CI.

---

## §4e Operations · Dok-Generator (NEU v1.10.4, 2026-04-17)

**Location:** `/operations/dok-generator` · Sidebar-Bereich Operations (Sibling zu Email-Inbox, Reminders, Scraper)
**Spec:** `specs/ARK_DOK_GENERATOR_SCHEMA_v0_1.md` + `INTERACTIONS_v0_1.md`
**Mockup:** `mockups/dok-generator.html` (1'321 Zeilen)

### Zweck

Zentrales Tool zur Generierung aller Dokumente, die Arkadium im Kundenkontakt erzeugt. Ersetzt verstreute CTAs in Entity-Detailmasken (Mandat „Offerte generieren", Assessment „Offerte generieren", Kandidat-Tab-9 „Dok-Generator" etc.) durch **ein zentrales Workflow-Tool** mit 5-Step-Flow.

### Prinzipien (User-Entscheidungen 2026-04-17)

- **1 Template pro Dokument-Variante** — separate Templates für Du/Sie, mit/ohne Rabatt, Mandat-Typ (keine Parameter)
- **Auto-Pull aus Entity-Vollansichten** — DB-Felder live aufgelöst, kein Abtippen
- **Multi-Entity nur bei `expose`** — Kandidat + optional Mandat-Kontext
- **Bulk-Mode bei Rechnungs-/Mahnungs-Templates** — N Entities auf einmal
- **Kein Admin-UI im Mockup** — Templates via DB-Seed (Admin-UI Phase 2)

### Layout

```
HEADER (Titel + Counter)
STEP-INDICATOR (horizontal, 5 Steps: Template → Entity → Ausfüllen → Preview → Ablage)
├─ SIDEBAR 280px (Kategorien, Quick-Filter, Favoriten, Zuletzt)
└─ MAIN (wechselt Inhalt je Step)
KB-HINTS unten
```

### 5 Workflow-Steps

| Step | Main-Inhalt | Output |
|------|-------------|--------|
| 1 Template | Template-Grid (38 Cards · 7 Kategorien · Favoriten-Star) | `currentTemplate` gesetzt |
| 2 Entity | Entity-Picker (9 Kinds, dynamisch gefiltert auf Template-Kinds, Multi/Bulk-Support) | `entityList` gefüllt |
| 3 Ausfüllen | WYSIWYG-Editor (Sidebar-Sektionen + A4-Canvas mit ARKADIUM-Branding) | Content-Overrides |
| 4 Preview | Read-only Canvas-Clone mit Zoom + Page-Break | — |
| 5 Ablage | Delivery-Optionen (save_only / save_and_email / save_and_download) + History-Preview-Drawer | `fireGenerate()` → Success-Drawer |

### Design-System-Konformität

- Drawer-Default-Regel eingehalten: 540px `.drawer` + `#drawerBackdrop` (Standard editorial.css)
- Kandidat-Tab-9 Editor-Styles generalisiert: Sidebar 260px + A4-Canvas 210mm
- ARKADIUM-Branding im Canvas: navy #1a2540, gold #b99a5a
- Step-Indicator sticky · Kategorie-Sidebar sticky
- 5 Drawers im Mockup: Credit-Zuweisung, Run-Detail, Kandidat-Ersetzen, Report-Upload, Success

### Kandidat-Tab-9 Migration

- **Phase 1**: Tab bleibt, Redirect-Banner mit Link zum globalen Dok-Generator (`?template=ark_cv&entity=candidate:<id>`)
- **Phase 2**: Tab-Layout wird zu Inline-Variante
- **Phase 3** (React-Port): Tab entfernt, nur Deep-Link zum globalen Tool

### Entity-CTA Deep-Link-Integration

Bestehende Entity-CTAs bereits auf Deep-Links migriert:
- `mandates.html` → Mandat-Report
- `assessments.html` Tab 4 → Offerte generieren
- `candidates.html` Tab 9 → Redirect-Banner

Phase 1.5 Migration: Accounts (Factsheet), Mandate (Rechnung-Stage-N), Prozesse (Best-Effort-Rechnung).

### RBAC

| Aktion | AM | CM | Backoffice | Admin |
|--------|----|----|-----------|-------|
| Templates lesen | ✅ | ✅ | ✅ | ✅ |
| Mandat-Offerten/Rechnungen generieren | ✅ | ⚠ | ✅ | ✅ |
| Kandidat-Dokumente (ARK CV/Abstract/Exposé) | ⚠ | ✅ | ❌ | ✅ |
| Assessment-Offerten/Rechnungen | ✅ | ⚠ | ✅ | ✅ |
| Executive Report | ⚠ | ✅ | ❌ | ✅ |
| Template-Admin-UI (Phase 2) | ❌ | ❌ | ❌ | ✅ |

### Template-Katalog

38 aktive Templates (+ 1 ausstehend `mandat_offerte_time`) in 7 Kategorien:
- `mandat_offerte` (4) · `mandat_rechnung` (10) · `best_effort` (8) · `assessment` (3) · `rueckerstattung` (1) · `kandidat` (5) · `reporting` (7)

**Vollständiger Katalog:** `ARK_STAMMDATEN_EXPORT_v1_3.md` §56.

### Dokument-Labels (12 neu)

Neue `document_label` ENUM-Werte für Dok-Generator-Outputs: `'Mandat-Offerte'`, `'Mandat-Rechnung'`, `'Best-Effort-Rechnung'`, `'Assessment-Offerte'`, `'Assessment-Rechnung'`, `'Executive-Report'` (NEU), `'Mahnung'`, `'Referenzauskunft'`, `'Referral'`, `'Interviewguide'`, `'Reporting'`, `'Factsheet'`.

Details: `ARK_DATABASE_SCHEMA_v1_3.md` §14.1.

### Datenbank

Neue Tabelle `dim_document_templates` (Stammdaten) + `fact_documents` Erweiterungen (5 neue Felder: `generated_from_template_id`, `generated_by_doc_gen`, `params_jsonb`, `entity_refs_jsonb`, `delivery_mode`, `email_recipient_contact_id`). Details: `ARK_DATABASE_SCHEMA_v1_3.md` §14.2.

### Backend-Endpoints

9 neue Endpoints unter `/api/v1/document-templates/*` + `/api/v1/documents/generate,resolve-placeholders,regenerate,email` + `/api/v1/document-generator/recent,drafts`. Details: `ARK_BACKEND_ARCHITECTURE_v2_5.md` §L.

### Mockup-Scope Phase 1

5 Seed-Templates mit vollem Canvas-Content: `mandat_offerte_target` · `rechnung_mandat_teilzahlung_1_sie` · `assessment_offerte` · `ark_cv` · `executive_report`. 33 weitere als Library-Cards sichtbar, Canvas-Content Phase 2.

---

## §4f Operations · Email & Kalender (NEU v1.10.5, 2026-04-17)

**Location:** `/operations/email-kalender` · Sidebar-Bereich Operations (Sibling zu Dok-Generator, Reminders, Scraper)
**Spec:** `specs/ARK_EMAIL_KALENDER_DETAILMASKE_SCHEMA_v0_1.md` + `INTERACTIONS_v0_1.md`
**Mockup:** `mockups/email-kalender.html` (~1700 Zeilen · Single-Page-Maske)

### Zweck

Vereint Email-Client und Kalender in einer Voll-Ansicht — Umsetzung des PO-Prinzips „nie das CRM verlassen". Ersetzt externe Outlook-Nutzung für Daily-Business-Kommunikation.

### Architektur-Entscheidungen (PO, 2026-04-17)

- **Layout A** — Segment-Toggle im Banner `[✉ Email | 📅 Kalender]`
- **Individuelle User-Tokens** — jeder Mitarbeiter OAuth-verbindet sein persönliches Outlook-Postfach (kein Shared-Mailbox-Zwischenschritt, ursprüngliche „Phase 1" verworfen)
- **CodeTwo für Signatur-Management** — server-seitig auf M365-Ebene, keine CRM-Signatur-Verwaltung
- **Inline-Quick-Reply + Drawer für Compose-New/Reply-All/Forward** — Drawer-Default-Regel-Ausnahme für häufigsten Case (kurze Reply)
- **Kalender-Team-Overlay zeigt nur frei/busy** — DSG-Datenschutz

### Layout

```
HEADER (Brand + Breadcrumb + Theme)
PAGE-BANNER (Titel + Meta + Mode-Segment + CTA)
├─ EMAIL-MODE: 3-Pane (Folders 220px | Liste 340px | Reader flex)
└─ KALENDER-MODE: 2-Pane (Sidebar 220px | Main flex, Tag/Woche/Monat-Views)
DRAWERS (on-demand, 540px oder 760px)
```

### 8 Drawer-Inventar

| # | Drawer | Breite | Zweck |
|---|--------|--------|-------|
| 1 | Compose | 760px | Email schreiben · 3 Tabs |
| 2 | Event | 760px | Termin öffnen/anlegen · 4 Tabs |
| 3 | Create-Kandidat | 540px | Aus Email anlegen |
| 4 | Create-Account | 540px | Aus Email anlegen |
| 5 | Template-Picker | 540px | 38 Templates · 4 mit Automation |
| 6 | Konten & Sync | 540px | OAuth · CodeTwo · Ignore-Liste |
| 7 | Entity-Match | 540px | Fuzzy-Scoring |
| 8 | File-Attach | 760px | Dokumente aus CRM · 3 Tabs |

### Ordner-Modell

| Ordner | Inhalt |
|--------|--------|
| Klassifiziert | Auto-Match auf Kandidat/Account via Adresse |
| Unbekannt | Kein Match — wartet auf Labeling |
| Inbox (Intern / Sonstige) | Manuell gelabelt (Team-intern, Dienstleister, Misc) |
| Ignoriert | Ignore-Liste-Hits (Newsletter) |

### Activity-Type-Katalog (verbindlich)

Compose-Drawer Verknüpfung-Tab nutzt ausschliesslich die **11 Emailverkehr-Einträge** aus `ARK_STAMMDATEN_EXPORT_v1_3.md §14`: Allgemeine Kommunikation · CV Chase · Absage Briefing · Absage Bewerbung · Absage vor GO Termin · Mündliche GOs versendet · Absage nach GO Termin · Schriftliche GOs · Eingangsbestätigung Bewerbung · Mandatskommunikation · AGB Verhandlungen.

### Integration zu MS Graph

- Endpoints `/api/v1/emails/*` (send · send-with-template · inbox · drafts) + `/api/v1/email-templates/*` + `/api/v1/integrations/outlook/*`
- Worker: `outlook.worker.ts` · `outlook-calendar-sync.worker.ts` · `email.worker.ts`
- Events: `email.received` · `email.sent` · `email.bounced` · `interview_scheduled` · `interview_rescheduled`
- Idempotenz via `email_message_id` (MS Graph)

### RBAC

| Rolle | Email | Kalender | Konten | Templates |
|-------|-------|----------|--------|-----------|
| AM | full | eigen + Kollegen frei/busy | eigen | lesen |
| CM | full | eigen + Kollegen frei/busy | eigen | lesen |
| Researcher | read + reply | eigen | eigen | lesen |
| Admin | alle User | alle User | alle | CRUD (nur Custom) |
| Backoffice | read · Rechnungs-Thread | read | — | lesen |

### Design-System-Konformität

- Drawer-Default-Regel · Datum-Eingabe-Regel · Stammdaten-Wording-Regel · Keine-DB-Technikdetails-Regel · Umlaute-Regel · Arkadium-Rolle-Regel
- Inline-Quick-Reply: dokumentierte Ausnahme der Drawer-Default-Regel (80/20 für kurze Reply)

---

## Pointer to Full Source

Für die folgenden Details das Original-Dokument `C:\ARK CRM\Grundlagen MD\ARK_FRONTEND_FREEZE_v1_10.md` konsultieren:

| Thema | §-Section | Was fehlt hier |
|---|---|---|
| Exakte CSS-Pixel, Padding, Margins | §8, §8b, §8c | Nur Drawer 540px, Snapshot sticky top:0/64px und Electron min 1024×700 hier lossless |
| Animation-Timings, Motion-Details | §8.2 | Weggelassen (reduced-motion-Prinzip genügt) |
| Density-Padding-Werte kompakt/normal/komfort | §8.1 | Nur Modus-Namen hier |
| ESLint Boundaries Importregeln vollständig | §24c | Namenskonventionen hier, Detail-Matrix dort |
| Ordnerstruktur vollständig mit Kommentaren | §5 | Nur Top-Level-Stores/Hooks/Shared hier |
| Toast Error-Code-Mapping vollständig | §12 | Nur Prioritätsmatrix + Dedup hier |
| Electron IPC preload.ts Beispielcode | §14.1 | contextIsolation/sandbox/true Flags hier, Code dort |
| CSP-Header vollständig (default-src, connect-src etc.) | §11d | Nur dass CSP gesetzt wird hier |
| OpenAPI Codegen + ts-to-zod Setup-Befehle | §11e, §25 | Kommandos nicht vollständig hier |
| DataTable A11y `role="grid"` Details | §9.1, §22 | Regel-Liste hier, ARIA-Attribute dort |
| Schema-SQL (bridge_briefing_projects etc.) | §4d.5 | Nur Hinweis dass es Schema-Änderungen gibt |
| Assessment-Chart-Mapping-Tabelle (DISC Ringdiagramm etc.) | §4d.6 | Tab-Struktur hier, Chart-Bibliothek-Mapping dort |
| Scraper Confidence-Schwellen, WebSocket-Latenz | §4d.8 | Hier lossless enthalten |
| Dashboard Empty-State Copy-Text | §4b | Nur Block-Struktur hier |
| Placement-Modal TX-Schritte / Saga-Zusammenspiel | "Placement-Modal" nach §4d.8 | Stichwort hier, 8 Saga-Steps in Backend v2.5 TX1 |

---

**Digest-Meta:**
- Quelle: 3850 Zeilen, ~110 kTok
- Digest: ca. 450 Zeilen, geschätzt 8–10 kTok
- Lossless: Routing, Detailmasken+Tabs, Drawer-Regel 540px, Snapshot-Slots, Color-Tokens, Component-Inventory, Interaction-Pattern-§-Numbers, 22 Grundregeln (kurz), Keyboard-Shortcuts v1.10, Build-Wellen.
- Summiert: CSS-Pixel/Paddings/Animations/Prose-Erklärungen/Schema-SQL/Code-Beispiele/Dashboard-Copy.
