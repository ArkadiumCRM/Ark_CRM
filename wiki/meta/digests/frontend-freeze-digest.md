---
title: "Frontend Freeze Digest v1.12"
type: meta
created: 2026-04-17
updated: 2026-04-24
last_regen: 2026-04-24T00:00
sources: ["ARK_FRONTEND_FREEZE_v1_12.md"]
tags: [digest, frontend, freeze, routing, design-system, elearn, erp]
---

# Frontend-Freeze v1.12 — Kompakt-Digest (Stand 2026-04-24)

Quelle: `Grundlagen MD/ARK_FRONTEND_FREEZE_v1_12.md` (~4475 Zeilen; v1.10 + v1.10.4 Dok-Generator-Addendum §4e + v1.10.5 Email-Kalender-Addendum §4f + v1.11 Responsive-Rewrite + v1.12 E-Learning-Modul TEIL O, 2026-04-24). Dieser Digest gibt Routing, Detailmasken-Inventar, Design-System-Regeln, Komponenten und Interaction-Pattern-Referenzen verlustfrei wieder. Pixel-/Padding-/Animation-Details sind bewusst weggelassen — bei Bedarf Original-§ lesen.

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
TEIL O  E-Learning-Modul Frontend (NEU v1.12, 2026-04-24)
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
| `/operations/dok-generator` | Globaler Dok-Generator (NEU v1.10.4, 5-Step-Workflow) |
| `/operations/email-kalender` | Email & Kalender (NEU v1.10.5, Single-Page-Maske mit Mode-Toggle Email↔Kalender, 8 Drawer) |
| `/documents` | Dokumente (Deep-Link, nicht in Sidebar) |
| `/documents/[id]` | Dokument-Detail |
| `/reminders` | Reminders-Vollansicht (NEU v1.10.5, 3. Tool-Maske) |
| `/notifications` | Notification-Vollseite (aus Bell-Icon) |
| `/search` | Strukturierte Suche + RAG-Tab (Deep-Link) |
| `/matching` | Matching-Modul (Deep-Link) |
| `/ai-review` | AI Review Inbox |
| `/market-intelligence` | Market Intelligence |
| `/settings` | Settings (Profil, Benachrichtigungen, Sessions, Locale) |
| `/settings/appearance` | Theme-Toggle (Dark/Light/System) |
| `/admin` | Admin-Bereich (User-Mgmt, Tenant-Config, Automation-Settings, Audit) |

Renames v1.10: `/firmengruppen` → `/company-groups`, `/projekte` → `/projects`.

Electron Protocol: `ark-crm://candidates/[uuid]`, `ark-crm://accounts/[uuid]`, `ark-crm://mandates/[uuid]`, `ark-crm://actions/call-log`.

**ERP-Workspace-Routen (NEU v1.12)** — siehe TEIL O unten: `/erp/elearn/*`, `/erp/hr`, `/erp/zeit`, `/erp/commission`, `/erp/billing`.

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
Übersicht (Stammdaten, Stellenplan-Ref, Markdown-Beschreibung, Konditionen, Matching-Kriterien, Sichtbarkeit) · Jobbasket (Pipeline 6 Stages) · Matching (7-Sub-Score-Tabelle + Radar) · Prozesse · Dokumente (Stellenausschreibung-Generator DE/FR/IT/EN) · History. Lifecycle `scraper_proposal → vakanz → aktiv → besetzt → geschlossen`.

### 4d.5 Firmengruppen-Detailmaske — 6 Tabs
Übersicht · Kultur (6 Dimensionen + Gesellschafts-Vergleich) · Kontakte (aggregiert) · Mandate & Prozesse · Dokumente (Rahmenvertrag, Master-NDA, Konzern-AGB) · History.

### 4d.6 Assessments-Detailmaske — 5 Tabs
Übersicht (Credits-Tabelle pro Typ) · Durchführungen (Kern, Typ-Filter) · Billing (`full` Default) · Dokumente · History. 11 Typen: MDI / Relief / ASSESS 5.0 / DISC / EQ / Scheelen 6HM / Driving Forces / Human Needs / Ikigai / AI-Analyse / Teamrad-Session.

### 4d.7 Projekte-Detailmaske — 6 Tabs
Übersicht (Öffentlich + Arkadium-intern getrennt) · Gewerke (BKP, Kern-Arbeitsumgebung) · Matching · Galerie (Masonry) · Dokumente · History. 3-Tier: Projekt → Gewerk (BKP) → Beteiligungen (Firmen + Kandidaten mit SIA-Phasen, 6 Haupt + 12 Teilphasen).

### 4d.8 Scraper-Control-Center — 6 Tabs
Dashboard (Ampel-System) · Review-Queue (Kern, 10 Finding-Typen, Bulk-Accept ≥80%) · Runs (Diff-View) · Configs (7 Scraper-Typen) · Alerts & Fehler (9 Alert-Typen) · History. Confidence: ≥85% Auto, 60–84% Review, <60% `needs_am_review`.

---

## Design-System Rules

### Drawer-Regel (CLAUDE.md Drawer-Default, §4)
- **Drawer (540px Slide-in von rechts, Default)**: CRUD, Bestätigungen, Mehrschritt-Eingaben, Unterentitäten, Quick-Edits (1–5 Felder), Reminder/Notiz erstellen.
- **Modal nur für**: kurze Confirms, Blocker, Forced Reauth, System-Notifications, Placement-Modal (8-Step-TX, KEIN Optimistic Update).
- **Vollseite**: Hauptdetailansichten Kandidat / Account / Job / Mandat / Prozess / Firmengruppe / Projekt / Assessment — immer. Kein Nested Drawer. Navigation zwischen Entitäten via `router.push()`.
- **Im Slide-In: Tabs** zur Strukturierung — kein Slide-In im Slide-In.
- Schliessen via X, Escape, Klick ausserhalb.

### Header-Layout (pro Detailseite)
- Identität/Klassifizierung/Status oben (banner-meta + banner-chips + Status-Dropdown + Mandat-Badge/Package-Badge).
- Quick-Actions rechts.
- Breadcrumb-Konvention: **2-stufig** Default, **4-stufig** bei Sub-Entitäten, **1-stufig** für System-Module.
- "Zuletzt geändert"-Zeile (last_modified_at + last_modified_by + source_system) immer sichtbar.

### Snapshot-Bar (Fix 6 Slots, sticky unter Header)
Sticky `top:0, z-index:50` unter Page-Banner; Tabbar folgt sticky mit `top:64px, z-index:49`. Auf Tablet 3×2 statt 6×1. CSS-Classes `.snapshot-bar` + `.snapshot-item`.

**Dupe-Regel (CRITICAL):** Snapshot-Slots dürfen NICHT duplizieren, was in banner-meta / banner-chips / Status-Dropdown / Mandat-Badge steht.

Slot-Allokation:
- Account: Mitarbeitende · Wachstum 3J · Umsatz · Gegründet · Standorte · Kulturfit
- Kandidat: Ø Match-Score · Im Jobbasket · Aktive Prozesse · Refresh-Due · Placements hist. · Assessments
- Mandat: Idents · Calls · Shortlist · Pauschale · Time-to-Fill · Placements (3 mit Progress-Bars)
- Firmengruppe: Gesellschaften · Mitarbeitende · Umsatz · Aktive Prozesse · Placements YTD · Arkadium-Umsatz YTD
- Job: Matches ≥70% · Im Jobbasket · Aktive Prozesse · Standort · TC-Range · Ø Match-Score
- Projekt: Volumen · Zeitraum · BKP-Gewerke · Beteiligte Firmen · Beteiligte Kandidaten · Medien
- Prozess: Stage-Alter · Nächstes Interview · Win-Probability · Pipeline-Wert · CM/AM · Garantie

**Ausnahmen 7 Slots**: Assessment, Scraper, Projekt.

### Tab-Structure
- Klick auf Oberreiter öffnet Listen-/Suchansicht zuerst; erst Klick auf Eintrag → Detailansicht.
- Versionierung (Briefings, Assessments): **Pfeil-Navigation** `← [Datum] →`, aktuellste default.

### Card-Pattern & Pipeline
- **Process Stage Pipeline Component** (§9.8, shared): Modi `detailed` / `compact`. Konsolidiert unter `.ark-pl-*`. Single Source of Truth: `specs/ARK_PIPELINE_COMPONENT_v1_0.md`.

### Datum-Eingabe-Regel (CLAUDE.md Datum-Eingabe-Regel, §14)
Alle Datum-/Zeit-Felder: natives `<input type="date">` / `datetime-local` / `time` — Kalender-Picker UND manuelle Tastatur-Eingabe Pflicht, kein Click-only-Picker.

### Density & Theme
- **Density-Modi**: kompakt · normal (Default) · komfort (tenant-aware).
- **Dark Mode Default + Light Mode** (user-umschaltbar via `/settings/appearance`). `data-theme="dark|light"` auf `<html>`. WCAG AA Pflicht.
- **Motion**: `prefers-reduced-motion` respektieren.
- **Zahlen**: `tabular-nums` überall (CHF, %, Datum dd.MM.yyyy).

### Produkt-Navigation + Sidebar-Gruppierung (CRM)
- **Ober-Oberreiter (Produkt-Nav)**: CRM · Zeiterfassung · Billing · Analysen & Reporting · HR & Entwicklung. Ab v1.12 Topbar-Toggle CRM↔ERP (siehe TEIL O).
- **Sidebar Gruppe 1 (9 Haupteinträge)**: Dashboard · Kandidaten · Accounts · Firmengruppen · Jobs · Mandate · Prozesse · Projekte · Scraper.
- **Gruppe 2**: Market Intelligence.
- **Gruppe 3 (System)**: Admin · Settings.
- Nicht in Sidebar (nur Deep-Link): Dokumente, Suche (via Cmd+K), Matching, Reminders, Notifications.

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

### Sparte-Chip (NEU v1.12, cross-Module)
```
ARC:            #D32F2F
GT:             #1976D2
ING:            #388E3C
PUR:            #7B1FA2
REM:            #F57C00
uebergreifend:  #616161
```

Implementierung: CSS-Variables in `globals.css` (HSL). Vollständige Token-Palette: `wiki/concepts/design-tokens.md`.

---

## Components (lossless Namen)

### shadcn/ui-Basis (`components/ui/`)
Einzige Komponenten-Basis (kein Wildwuchs, kein zweites Date-Picker / Select / Modal).

### Shared (`components/shared/`)
- **DataTable** (TanStack Table + TanStack Virtual)
- **FilterBar** (Debounce 200ms Standard / 500ms Heavy)
- **StatusBadge** · **EntityCard** · **Timeline** · **SearchPalette**
- **CommandPalette** (cmdk)
- **EmptyState** · **Skeletons**
- **PermissionGate** (show/hide · read-only · maskiert · disabled mit Tooltip)
- **FeatureFlagGate**
- **DetailDrawer** · **ErrorState** · **ErrorBoundary** · **ToastSystem**
- **PresenceIndicator** · **BulkActionBar** · **ExportButton**
- **MarkdownRenderer** (react-markdown + rehype-sanitize)
- **MarkdownEditor** (Textarea + Preview-Toggle)

### Feature-Module
`components/candidates/`, `/accounts/`, `/contacts/`, `/jobs/`, `/mandates/`, `/processes/`, `/documents/`, `/reminders/`, `/notifications/`, `/matching/`, `/ai/`, `/analytics/`, `/dashboard/`, `/elearn/` (NEU v1.12).

### Design-System-Komponenten v1.10 (neu/benannt)
- **PipelineBar** / **ProcessStagePipeline** (§9.8, Modi `detailed` / `compact`)
- **SnapshotBar** (6 Slots fix, Dupe-Regel, `.snapshot-bar`)
- **StageTransitionDrawer** (Placement-Modal, 8-Step-TX, kein Optimistic)
- **ActivityTimeline** (mit `data-activity-id`-Anchor)
- **Versionierungs-Pfeil-Nav**

### Hooks (`hooks/`)
useAuth · usePermissions · useKeyboard · useDebounce · useNetworkStatus · useRealtimeChannel · useEntityDrawer · useUrlFilters · useTenant · usePresence · useErrorBoundary · useBulkAction · useFeatureFlag · **useScrollTracker** (NEU v1.12).

### Stores (`stores/`) — alle tenant-aware (ausser sidebar, theme, toast)
ui.store · filter-presets.store · command-palette.store · table-preferences.store · workspace.store · toast.store.

---

## Interaction-Patterns Reference (§-numbers)

Aus `wiki/concepts/interaction-patterns.md`:

| § | Topic |
|---|---|
| §4 | **Drawer-Default-Regel** — CRUD / Bestätigungen / Mehrschritt als 540px-Drawer |
| §14 | **Datum-Eingabe-Regel** — native `<input type="date">` |
| §14a | **Terminologie Briefing vs. Stellenbriefing** |

Weitere CLAUDE.md-Regeln:
- **Datei-Schutz-Regel** — Backups vor Bulk-Edits >5 KB, Edits via Edit/Write, nie `open('w')`.
- **Umlaute-Regel** — ä ö ü Ä Ö Ü ß UTF-8 Pflicht.
- **Keine-DB-Technikdetails-im-UI-Regel** — keine `dim_*` / `fact_*` / `bridge_*` / `*_id` in User-facing Texten.
- **Arkadium-Rolle-Regel** — Arkadium nicht-teilnehmend bei Interviews; Touchpoints: Briefing / Coaching / Debriefing / Referenzauskunft.
- **Activity-Linking-Regel** (§9.9) — UI-Felder sind Projektionen von `fact_history`, mit `data-activity-id`.
- **Schutzfrist-Regel** — 12/16-Mt-Direkteinstellungs-Schutzfrist getrennt von 3-Mt-Post-Placement-Garantie.
- **Stammdaten-Wording-Regel** — gegen `ARK_STAMMDATEN_EXPORT_v1_3.md` prüfen.
- **Spec-Sync-Regel** — 5 Grundlagen × 9 Detailmasken Sync-Matrix.
- **ark-lint-skip-Marker** — `<!-- ark-lint-skip:begin reason=admin-xxx -->…<!-- ark-lint-skip:end -->` zur Markierung legitimer Admin-/Debug-Flächen.

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

E-Learning-Shortcuts siehe TEIL O unten.

---

## Sonstige lossless Kern-Listen

### 22 Grundregeln (REGEL 01–22) — Kurzbezeichnung
01 Backend=Source of Truth · 02 tenant_id nur aus Backend-Kontext · 03 Permissions nie nur UI · 04 zentraler API-Client · 05 Server-State vs UI-State trennen · 06 RHF+Zod · 07 Optimistic nur mit Rollback · 08 Stage-Changes MÜSSEN Optimistic · 09 keine PII in localStorage/URL · 10 Hauptdetails=Vollseiten · 11 Keyboard-First · 12 TanStack Virtual Pflicht · 13 API-Types generiert · 14 kein Optimistic bei komplexen Writes/AI/Merge · 15 kein PII-Suchtext in URL · 16 Stores tenant-aware · 17 withCredentials nur für /auth/* · 18 kein Token-Broadcast · 19 Presence rein indikativ · 20 kein SSR von sensiblen Daten · 21 Markdown via Sanitizer · 22 UUID in URL erlaubt.

### Query Cache TTL (Ressourcengruppen, §16h)
Stammdaten 30/60 min · Entitäts-Details 5/15 min · Listen 2/10 min · Dashboard KPIs 2/5 min · Notifications/Reminders 0/5 min · Matching/AI 1/10 min · Presence nie gecacht.

### Responsive Policy (§24b · v1.11 REWRITE 2026-04-17)
**Voller Mobile-/Tablet-Support**.
- **Desktop > 960 px:** primärer Power-User-Mode, Sidebar 56 px hover-expand 240 px, Keyboard-Shortcuts
- **Tablet 641–960 px:** Sidebar 56 px + Pin-Toggle ⇔, Hover aus (Touch), KPI 3-col
- **Mobile ≤ 640 px:** Top-Bar 52 px + ☰ Slide-Out-Drawer 280 px, KPI 2-col, DataTable → Card-Stack, Drawer → Full-Screen-Sheet 100vw×100vh, Tabs/Filter-Bar/Chip-Group horizontal scrollbar, 3-Pane-Layouts → Pane-Toggle
- **Safe-Area-Inset:** `<meta viewport-fit=cover>` + `env(safe-area-inset-top/bottom)`
- **Touch-Targets:** min 36×36 px, primär 44×44 px
- **Test-Tool:** `mockups/crm-mobile.html`

### Bundle-Budget (§20)
Initial ≤200 kB gzip · Per-Route-Chunk ≤100 kB · Recharts / Drawers / komplexe Forms lazy.

### Build-Wellen (§26)
- **Welle 1 Fundament**: Shell, Auth, Middleware, Query Provider, API-Client, Gates, DataTable, FilterBar, Candidate List+Detail, Locale, Toast.
- **Welle 2 Kern-CRM**: Accounts, Contacts, Mandates, Processes (Stage-Change), History Timeline, Notifications, Reminders, Command Palette, Workspace, Dashboard.
- **Welle 3 Erweitert**: Documents, Search, Matching, AI Review, Realtime Presence, Market Intelligence, Bulk, Export/Import, Auditability, Merge/DQ.
- **Welle 4 Abschluss/Desktop**: Admin, Settings, Electron, Error Boundaries, ESLint Boundaries, Storybook/Chromatic, Bundle-Budget-CI.

---

## §4e Operations · Dok-Generator (NEU v1.10.4, 2026-04-17)

**Location:** `/operations/dok-generator` · Sidebar-Bereich Operations
**Spec:** `specs/ARK_DOK_GENERATOR_SCHEMA_v0_1.md` + `INTERACTIONS_v0_1.md`
**Mockup:** `mockups/dok-generator.html`

Zentrales Tool zur Generierung aller Arkadium-Kundenkontakt-Dokumente. Ersetzt verstreute Entity-CTAs durch zentrales 5-Step-Workflow-Tool.

### 5 Workflow-Steps

| Step | Main-Inhalt | Output |
|------|-------------|--------|
| 1 Template | Template-Grid (38 Cards · 7 Kategorien · Favoriten) | `currentTemplate` |
| 2 Entity | Entity-Picker (9 Kinds, Multi/Bulk) | `entityList` |
| 3 Ausfüllen | WYSIWYG-Editor (A4-Canvas + ARKADIUM-Branding) | Content-Overrides |
| 4 Preview | Read-only Canvas-Clone | — |
| 5 Ablage | Delivery (save_only / save_and_email / save_and_download) | `fireGenerate()` |

### Template-Katalog
38 aktive Templates in 7 Kategorien: `mandat_offerte` (4) · `mandat_rechnung` (10) · `best_effort` (8) · `assessment` (3) · `rueckerstattung` (1) · `kandidat` (5) · `reporting` (7).

### Dokument-Labels (12)
`'Mandat-Offerte'`, `'Mandat-Rechnung'`, `'Best-Effort-Rechnung'`, `'Assessment-Offerte'`, `'Assessment-Rechnung'`, `'Executive-Report'`, `'Mahnung'`, `'Referenzauskunft'`, `'Referral'`, `'Interviewguide'`, `'Reporting'`, `'Factsheet'`.

### Backend-Endpoints
9 unter `/api/v1/document-templates/*` + `/api/v1/documents/generate,resolve-placeholders,regenerate,email` + `/api/v1/document-generator/recent,drafts`.

---

## §4f Operations · Email & Kalender (NEU v1.10.5, 2026-04-17)

**Location:** `/operations/email-kalender`
**Spec:** `specs/ARK_EMAIL_KALENDER_DETAILMASKE_SCHEMA_v0_1.md` + `INTERACTIONS_v0_1.md`
**Mockup:** `mockups/email-kalender.html`

Architektur-Entscheidungen: Layout A (Segment-Toggle `[✉ Email | 📅 Kalender]`) · individuelle User-Tokens (OAuth) · CodeTwo für Signatur · Inline-Quick-Reply + Drawer für Compose-New/Reply-All/Forward · Kalender-Team-Overlay nur frei/busy (DSG).

### 8 Drawer-Inventar

| # | Drawer | Breite | Zweck |
|---|--------|--------|-------|
| 1 | Compose | 760px | Email schreiben · 3 Tabs |
| 2 | Event | 760px | Termin · 4 Tabs |
| 3 | Create-Kandidat | 540px | Aus Email |
| 4 | Create-Account | 540px | Aus Email |
| 5 | Template-Picker | 540px | 38 Templates · 4 Automation |
| 6 | Konten & Sync | 540px | OAuth · CodeTwo · Ignore |
| 7 | Entity-Match | 540px | Fuzzy-Scoring |
| 8 | File-Attach | 760px | Dokumente aus CRM · 3 Tabs |

### Ordner-Modell
Klassifiziert · Unbekannt · Inbox (Intern / Sonstige) · Ignoriert.

### Activity-Types (11 Emailverkehr-Einträge aus Stammdaten §14)
Allgemeine Kommunikation · CV Chase · Absage Briefing · Absage Bewerbung · Absage vor GO Termin · Mündliche GOs versendet · Absage nach GO Termin · Schriftliche GOs · Eingangsbestätigung Bewerbung · Mandatskommunikation · AGB Verhandlungen.

### MS-Graph-Integration
Endpoints `/api/v1/emails/*` + `/api/v1/email-templates/*` + `/api/v1/integrations/outlook/*`. Worker: `outlook.worker.ts` · `outlook-calendar-sync.worker.ts` · `email.worker.ts`. Events: `email.received|sent|bounced` · `interview_scheduled|rescheduled`. Idempotenz via `email_message_id`.

---

## TEIL O — E-Learning-Modul Frontend (NEU v1.12, 2026-04-24)

**Quellen-Specs:**
- `specs/ARK_FRONTEND_FREEZE_PATCH_ELEARNING_v0_1.md` (Sub A)
- `specs/ARK_FRONTEND_FREEZE_PATCH_ELEARNING_SUB_B_v0_1.md`
- `specs/ARK_FRONTEND_FREEZE_PATCH_ELEARNING_SUB_C_v0_1.md`
- `specs/ARK_FRONTEND_FREEZE_PATCH_ELEARNING_SUB_D_v0_1.md`

### O.1 Topbar-Toggle CRM ↔ ERP

**Position:** links neben User-Avatar in globaler Topbar. Sichtbar auf allen Seiten (CRM + ERP).

**Verhalten:**
- Segmented-Control mit zwei Buttons: **CRM** | **ERP**
- Aktiver Modus visuell hervorgehoben (Primärfarbe-Fill, weisser Text)
- Klick wechselt Workspace: ändert Sidebar-Inhalt + Default-Route
- Persistenz: letzter Modus pro User in `localStorage`
- CRM-Default: `/crm/candidates.html` (bzw. letzte CRM-Route)
- ERP-Default: `/erp/elearn/dashboard.html` (bzw. letzte ERP-Route)

**Zugriffs-Rechte:** alle authentifizierten User sehen beide Modi; Sidebar-Items ohne Zugriff werden ausgeblendet.

### O.2 ERP-Workspace-Struktur

```
/erp
  /elearn        ← E-Learning (dieser Patch)
  /hr            ← bestehender HR-ERP
  /zeit          ← bestehender Zeit-ERP (v1.11)
  /commission    ← bestehender Commission-ERP
  /billing       ← bestehendes Billing-Modul
```

**ERP-Sidebar-Pattern** (identisch zu CRM-Sidebar): 240 px fixed-width links · Top-Logo Arkadium · Section-Header kollabierbar (Default offen) · Active-Item Primary-Fill · Icons aus `lucide-icons`.

**ERP-Sidebar-Struktur E-Learning:**
```
── E-Learning
   • Meine Kurse
   • Mein Newsletter           (nach Sub C)
   • Mein Compliance-Status    (nach Sub D)
   ─ (Trenner, Head+Admin)
   • Team-Übersicht
   • Team-Compliance           (nach Sub D)
   • Freitext-Queue
   • Zuweisungen
   ─ (Trenner, Admin only)
   • Kurs-Katalog
   • Curriculum-Templates
   • Import-Dashboard
   • Analytics
   ─ (Trenner, Content-Gen)
   • Content-Generator         (Sub B)
   • Content-Sources
   • Review-Queue
   ─ (Trenner, Newsletter)
   • Newsletter-Konfiguration  (Sub C)
   • Newsletter-Archiv
   • Newsletter-Queue
   ─ (Trenner, Progress-Gate)
   • Compliance-Dashboard      (Sub D)
   • Gate-Rules
   • Override-Verwaltung
   • Gate-Audit-Log
```

### O.3 Neue Page-Templates (25+)

Pfad: `mockups/erp/elearn/*.html`. Baseline-Styling = CRM (candidates.html).

#### Sub A · MA-Pages (6)

| Datei | Zweck |
|---|---|
| `dashboard.html` | Einstieg: Onboarding-Progress (neue MA) oder Tabs Pflicht/Empfohlen/Entdecken |
| `course.html` | Kurs-Übersicht: Module-Liste, Progress-Ringe, Pre-Test-Button |
| `lesson.html` | Markdown-Viewer + Embeds + Scroll-Tracker + Sticky-Footer |
| `quiz.html` | Quiz-Runner mit 6 Fragen-Components |
| `quiz-result.html` | Ergebnis + Feedback + Retry/Weiter |
| `certificates.html` | Zertifikate-Grid + Badge-Wall |

#### Sub A · Gemeinsame Pages (Head+Admin) (3)

| Datei | Zweck |
|---|---|
| `team.html` | Team-Übersicht (Head: eigenes Team / Admin: tenant-weit) |
| `freitext-queue.html` | Review-Queue + LLM-Vorschlag + Head-Override-Drawer |
| `assignments.html` | Massen-Zuweisung (Sparte/Rolle/Kurs-Filter) |

#### Sub A · Admin-only (4)
`admin/courses.html` · `admin/curriculum.html` · `admin/imports.html` · `admin/analytics.html`

#### Sub B · Admin-only (3)
`admin/content-gen.html` (Job-Timeline + Cost-Widget) · `admin/content-gen-sources.html` (Upload/Web/CRM-Tabs) · `admin/content-gen-review.html` (Review-Queue + Drawer)

#### Sub C · MA + Admin (5)
`newsletter.html` (Aktuell/Archiv-Tabs) · `newsletter-issue.html` (Reader + Section-Timeline) · `admin/newsletter-config.html` · `admin/newsletter-archive.html` · `admin/newsletter-queue.html`

#### Sub D · MA + Team + Admin (7)
`gate.html` (Full-Screen-Gate bei Block) · `my/compliance.html` (MA-Self-View) · `team/compliance.html` (Head-Dashboard) · `admin/compliance.html` (Admin-Dashboard) · `admin/gate-rules.html` · `admin/gate-overrides.html` · `admin/gate-audit.html`

### O.4 Neue Components

#### O.4.1 Markdown-Renderer mit Embed-Blocks
Lesson-Content + Newsletter-Sections. Standard-Markdown + Custom-Embed-Syntax:
- `![[image.png]]` → `<img>` aus Content-Repo-Assets
- `{% embed pdf="file.pdf" page=N %}` → embedded PDF-Viewer (PDF.js)
- `{% embed youtube="ID" %}` → YouTube-iframe

Server-side Markdown-to-HTML beim Import, Embed-Blocks zu Platzhaltern, Client-side Komponenten-Mount.

#### O.4.2 Scroll-Tracker-Hook
**API:** `useScrollTracker({ lessonId, minReadSeconds, onComplete })`
- Trackt max `scroll_pct` pro Lesson/Section
- Trackt aktive `time_sec` (pausiert bei Tab-Unfocus via `visibilitychange`)
- Heartbeat alle 15 s via `POST /api/elearn/my/lessons/:lid/progress` (Sub A) bzw. 10 s für Newsletter-Sections (Sub C)
- Callback `onComplete` bei `scroll_pct ≥ 90` UND `time_sec ≥ minReadSeconds`

#### O.4.3 Quiz-Runner Components (6)

| Component | Typ |
|---|---|
| `<QuizQuestionMC>` | Radio-Buttons |
| `<QuizQuestionMulti>` | Checkboxes |
| `<QuizQuestionTrueFalse>` | Zwei grosse Buttons |
| `<QuizQuestionZuordnung>` | Drag-Drop Left→Right |
| `<QuizQuestionReihenfolge>` | Drag-Drop Vertikal-Sort |
| `<QuizQuestionFreitext>` | Textarea + Char-Counter |

**Gemeinsame API:** `{ question, value, onChange, disabled }`.

#### O.4.4 Freitext-Review-Drawer (Sub A)
540 px Slide-in. Sections: Frage · Musterlösung (readonly) · Keywords (Chips) · MA-Antwort (readonly) · LLM-Vorschlag (Score-Bar farbkodiert + Feedback-Text) · Head-Override (Score-Slider 0-100 vorgefüllt + Feedback-Textarea) · Action-Buttons.

**Shortcuts:** `J`/`K` next/prev · `Enter` LLM bestätigen · `O` Override-Fokus · `Esc` schliessen.

#### O.4.5 Review-Drawer (Sub B)
540 px. Tabs: **Preview** (rendered Markdown/YAML) · **Source** (raw, editierbar) · **Chunks** (Similarity-Score-Liste) · **Diff** (Side-by-Side).

**Editor:** CodeMirror mit Markdown/YAML-Syntax-Highlighting + Schema-Validation. Live-Diff gegen Original-Draft.

**Shortcuts:** `A` Freigeben · `R` Ablehnen · `E` Bearbeiten · `P` Direkt publishen · `J`/`K` next/prev · `Esc`.

#### O.4.6 Newsletter-Reader (Sub C)
Single-page scroll, Max-Width 720 px Reading-Column:
- Hero-Titel + Subtitle mit Lese-Fortschritt (2/4 Sections)
- Left-Rail Section-Timeline (IntersectionObserver + Scroll-Spy, Checkmark bei `read_at`)
- Enforcement-Badge oben rechts (`soft`=orange „Erinnerung" / `hard`=rot „Pflicht-Lock")
- Sticky-Footer mit Quiz-Button (disabled bis alle Sections `read_at`)
- Quiz → `POST /quiz/start` → Weiterleitung zu Sub-A-Quiz-Runner

**Shortcuts:** `Space`/`PageDown` nächste Section · `PageUp` vorherige · `Q` Quiz starten · `Esc` zurück.

#### O.4.7 Countdown-Widget (Sub C)
Zeigt „noch X Tage" bis Deadline. Farbcodierung: grün > 3 Tage · gelb 1-3 · rot < 1 Tag/überfällig. Tooltip mit konkretem Datum.

#### O.4.8 Enforcement-Badge (Sub C)
`soft` → orange Pill „Erinnerung" · `hard` → rote Pill „Pflicht-Lock".

#### O.4.9 Sparte-Chip (Sub C)
Cross-Module-Farbcodierung: ARC=#D32F2F · GT=#1976D2 · ING=#388E3C · PUR=#7B1FA2 · REM=#F57C00 · uebergreifend=#616161.

#### O.4.10 State-spezifische Card-Visuals (Sub A Dashboard)

| State | Visual |
|---|---|
| Gesperrt (Step-Lock) | Ausgegraut + Schloss-Icon + Tooltip |
| Nicht gestartet | „Jetzt starten" + Progress-Ring 0 % |
| In Arbeit | Progress-Ring X % + Modul-Stand |
| Quiz in Prüfung | Badge „In Prüfung" + Progress eingefroren |
| Abgeschlossen | Checkmark + „Erneut anschauen" |
| Refresher fällig | Gelbes Badge „Refresher fällig" + Deadline |
| Deadline überschritten | Rotes Badge „Überfällig" |

#### O.4.11 Cost-Widget (Sub B)
Progress-Bar Verbrauch/Cap · Farbcodierung: grün < 80 %, gelb 80-95 %, rot ≥ 95 % · Tooltip Top-5-Jobs · Klick → Cost-Detail-Modal (Aggregation nach Source-Kind).

#### O.4.12 Global Components Sub D (CRM + ERP)

**Login-Popup** (nach erfolgreichem Login):
- 540 px, Fokus-Trap, `aria-modal="true"`
- Trigger: `pending_items >= settings.login_popup_min_items` via `/api/elearn/my/gate-status`
- Buttons: „Zu meinen Aufgaben" (primary, `Enter`) · „Später" (disabled wenn `blocks_active`, `Esc`)

**Topbar-Gate-Badge:**
- Icon: Checkliste mit Count-Badge (rot bei Pflicht, orange bei Soft)
- Hover: Mini-Popover Top-5 pending Items
- Klick: `/erp/elearn/dashboard.html` (MA) bzw. `/erp/elearn/admin/compliance.html` (Admin/Head)
- Conditional: nur sichtbar wenn `pending_items > 0`

**Dashboard-Banner (Sub A Dashboard):**
- Gelb bei Soft, rot bei Hard
- „Ausblenden" snoozt 30 Min (localStorage)
- Klickbar pro Item → Direct Navigation

#### O.4.13 HTTP-Interceptor (Sub D)

Globaler Axios/Fetch-Interceptor:
```ts
interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 403 && error.response.data?.error === 'GATE_BLOCKED') {
      const { rule_id, redirect_to } = error.response.data;
      window.location.href = redirect_to;  // → /erp/elearn/gate.html?rules=<id>
      return;
    }
    return Promise.reject(error);
  }
);
```

**Ausnahme:** eigene Gate-Status-Calls (`/api/elearn/my/gate-status`) fangen den Fehler selbst ab.

### O.5 Design-System-Konformität (E-Learning-Regeln)

- **Umlaute:** UTF-8 echte ä/ö/ü/Ä/Ö/Ü/ß (nie `ae`/`oe`/`ue`/`ss`)
- **Drawer-Default-Regel:** 540 px Slide-in für CRUD / Bestätigungen / Mehrschritt. Modale nur für kurze Confirms / Blocker / System-Notifications
- **Datum-Eingabe-Regel:** nativer `<input type="date">`/`datetime-local`/`time` (Picker UND Tastatur-Eingabe)
- **Keine DB-Technikdetails** in User-facing-Texten: keine `dim_*`/`fact_*`/`_fk`/`_id`. UI-Label-Vocabulary aus Stammdaten-Patch
- **Admin-/Debug-Ausnahmen:** wrappen mit `<!-- ark-lint-skip:begin reason=admin-elearn -->…<!-- ark-lint-skip:end -->`
- **Gate-Page-Regel:** darf Gate-Rule-Namen (Admin-frei formulierbar) zeigen, aber keine Feature-Keys (technisch `create_candidate`). Stattdessen dynamische deutsche Labels
- **Admin-Audit-Page** darf Feature-Keys und Rule-Namen zeigen (Admin-Kontext)

### O.6 Base-Tokens (identisch CRM)

- Primary: Arkadium-Blau
- Score-Farbcodierung: rot < 50, gelb 50-79, grün ≥ 80 (cross-Module)
- Lock-State: neutral-grey-400 + Schloss-Icon
- Spacing: 8 px Grid
- Component-Kits: Base wie CRM (Shadcn-basiert)

### O.7 Responsive-Breakpoints

- **Desktop (≥ 1280 px):** Full-Layout, Tabellen mehrspaltig, Drawer rechts
- **Tablet (768-1279 px):** Tabellen Horizontal-Scroll, Drawer Full-Width-Bottom
- **Mobile:** Gate-Page + Login-Popup mobile-optimiert · andere E-Learning-Pages Phase-2/3
- Newsletter-Reader Mobile: Section-Timeline horizontal-scroll oben, Column 100 %

### O.8 A11y

- Gate-Page: `role="alertdialog"` mit ARIA-Describe auf pending Items
- Login-Popup: Fokus-Trap, `aria-modal="true"`
- Compliance-Score-Gauge: ARIA-Live bei Wert-Änderung
- Quiz-Runner: ARIA-Live-Regionen für Score-Announcements
- Section-Timeline: ARIA-Tree-Role
- Countdown-Widget: ARIA-Live bei Status-Wechsel (< 1 Tag)
- Quiz-Start-Button: `aria-disabled` + Tooltip warum disabled
- Farb-Codierung nicht alleiniger Info-Träger (Icons + Text redundant)
- Focus-Management: nach Drawer-Close Fokus zurück auf Zeilen-Row

### O.9 Keyboard-Shortcuts Übersicht (E-Learning)

| Kontext | Shortcuts |
|---|---|
| Quiz-Runner | Tab-Navigation, Enter-Submit |
| Freitext-Review-Drawer (Sub A) | `J`/`K` next/prev · `Enter` LLM bestätigen · `O` Override · `Esc` |
| Review-Queue (Sub B) | `A`/`R`/`E`/`P` Aktionen · `J`/`K` · `Esc` |
| Newsletter-Reader (Sub C) | `Space`/`PageDown`/`PageUp` · `Q` Quiz · `Esc` |
| Newsletter-Archive-Drawer (Sub C) | `J`/`K` · `P` Publish · `A` Archive · `Esc` |
| Compliance-Dashboard (Sub D) | `F` Filter · `E` Export · `J`/`K` |
| Gate-Rules-Editor (Sub D) | `N` Neue Rule · `D` Disable · `E` Edit |
| Login-Popup (Sub D) | `Enter` primary · `Esc` wenn enabled |

### O.10 Cross-Module-Integration

- **Topbar-Tab „E-Learning" 🎓** in alle 6 anderen Shells integriert (crm/hr/zeit/commission/billing/elearn)
- **postMessage-Theme-Sync:** Broadcast in 6 Shells, Message-Listener in 65+ Content-Pages (ab E-Learning-Release 2026-04-24)
- **Shared `_shared/theme-sync.js`** vorhanden, Referenzierung in Folge-Session

---

## Pointer to Full Source

Für folgende Details das Original-Dokument `Grundlagen MD/ARK_FRONTEND_FREEZE_v1_12.md` konsultieren:

| Thema | §-Section | Was fehlt hier |
|---|---|---|
| Exakte CSS-Pixel, Padding, Margins | §8, §8b, §8c | Nur Drawer 540px + Snapshot sticky top:0/64px hier lossless |
| Animation-Timings | §8.2 | Weggelassen (reduced-motion-Prinzip genügt) |
| Density-Padding-Werte kompakt/normal/komfort | §8.1 | Nur Modus-Namen hier |
| ESLint Boundaries Importregeln | §24c | Nur Namenskonventionen hier |
| Ordnerstruktur vollständig | §5 | Nur Top-Level-Stores/Hooks/Shared hier |
| Toast Error-Code-Mapping vollständig | §12 | Nur Prioritätsmatrix + Dedup hier |
| Electron IPC preload.ts Beispielcode | §14.1 | Nur Flags hier |
| CSP-Header vollständig | §11d | Nur dass CSP gesetzt wird hier |
| OpenAPI Codegen + ts-to-zod Setup | §11e, §25 | Nur Erwähnung hier |
| DataTable A11y `role="grid"` Details | §9.1, §22 | Regel-Liste hier |
| Schema-SQL Schnipsel | §4d.5 | Nur Hinweis hier |
| Assessment-Chart-Mapping-Tabelle | §4d.6 | Nur Tab-Struktur hier |
| Dashboard Empty-State Copy | §4b | Nur Block-Struktur hier |
| Placement-Modal 8 Saga-Steps | "Placement-Modal" nach §4d.8 | Stichwort hier, Detail in Backend v2.5 TX1 |
| E-Learning Page-Content-Details | TEIL O.3 (pro Page) | Page-Pfad + Zweck hier lossless, Layout-Details in Sub-Specs |

---

**Digest-Meta:**
- Quelle: 4475 Zeilen, ~130 kTok
- Digest: ca. 620 Zeilen, geschätzt 11–13 kTok
- Lossless: Routing (CRM + ERP), Detailmasken+Tabs, Drawer-Regel 540px, Snapshot-Slots, Color-Tokens inkl. Sparte-Chip, Component-Inventory, Interaction-Pattern-§-Numbers, 22 Grundregeln (kurz), Keyboard-Shortcuts v1.10 + E-Learning, Build-Wellen, TEIL O (Topbar-Toggle, ERP-Sidebar, 25+ Page-Templates, Components + APIs, HTTP-Interceptor, Shortcut-Tabellen, Design-System-Konformität).
- Summiert: CSS-Pixel/Paddings/Animations/Prose-Erklärungen/Schema-SQL/Code-Beispiele/Dashboard-Copy.
