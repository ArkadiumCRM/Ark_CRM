# ARK Frontend Architecture – Freeze v1.9

**Stand:** 2026-03-30
**Status:** FROZEN – massgebliche Grundlage für alle Frontend-Entscheidungen
**Referenzen:** ARK Backend Freeze v2.3 · ARK Datenbank Schema Freeze v1.2 · ARK Gesamtsystem-Übersicht v1.2
**Vorversion:** Freeze v1.8 (2026-03-28)
**Konsolidiert:** UI Addendum v1.2 als Section 4d integriert
**Änderungen v1.8 → v1.9:**
- Dark Mode only (ARK CI-Farbpalette) als verbindliches Farbschema definiert (Section 8c)
- Produkt-Navigation (Ober-Oberreiter) als neue Shell-Ebene hinzugefügt (Section 6)
- Sidebar-Gruppierung präzisiert: 9 Haupteinträge + Market Intelligence + Admin/Settings (Section 6)
- Phase-2-Items aus Sidebar entfernt → leben in Produkt-Navigation
- **Hauptdetailansichten sind Vollseiten** — kein Drawer/Slide-In für Kandidat, Account, Job, Mandat, Prozess (Regel 10, Section 4c, Section 7)
- Nested Drawer Pattern entfällt — Navigation zwischen Entitäten via router.push() und Browser-History

**Änderungen Business-Logik (Gesamtsystem-Review v1.2):**
- Wechselmotivation (8 Stufen) als neues Feld neben Temperatur auf Kandidaten-Profil
- Preleads als erster Jobbasket-Stage + differenzierte Rejection (candidate/cm/am)
- Mandatsarten: Einzelmandat/RPO/Time (nicht Executive Search/Direct Search)
- Mandats-Status: Entwurf → Aktiv / Abgelehnt (via Dokument-Upload "Mandatsofferte unterschrieben" bzw. manuell). KPI: Offerten-Conversion-Rate
- Prozess-Status: Open, On Hold, Rejected, Placed, Stale, Closed, Cancelled, Dropped
- Erfolgsbasis-Prozesse (ohne Mandat) mit Default Best-Effort-Staffel, individuell überschreibbar
- AGB-Tracking auf Accounts (agb_confirmed_at), Gate-Check bei CV-Versand ohne bestätigte AGB
- Account Einkaufspotenzial ★/★★/★★★ als neues Feld
- Skills-System deprecated → Focus bildet Skills ab (kein separates Skill-Modul)
- Datenschutz-Stage: nach 1 Jahr auto → Refresh, auch manuell rückstellbar (Sonder-Automation)
- Dok-Typen: "Dossier" → "ARK CV", neue Kategorie "Assessment-Dokument", Max 20 MB
- Email-System: 32 Templates, CRM als zentrales Kommunikationstool
- Alle Fristen konfigurierbar über Admin → Automation-Settings
- Longlist-Synchronisierung: Automationen greifen übergreifend auf Kandidaten-Stage UND alle aktiven Longlists

> Dieses Dokument gilt als einzige Wahrheit für Frontend-Architektur, Stack, Patterns und Konventionen.
> Abweichungen nur nach expliziter Entscheidung und Dokumentation.



## Inhaltsverzeichnis

```text
0.  Zielbild
1.  Grundregeln (22 Regeln)
2.  Tech Stack + TypeScript Flags + Version Pinning
3.  Architekturprinzipien
4.  Informationsarchitektur
4b. Dashboard – Modul-Spezifikation (inkl. Empty State)
4c. Kernmodul-Spezifikationen Phase 1
4d. UI-Detailspezifikation – Masken, Tabs, Felder (ex UI Addendum v1.2)
5.  Ordnerstruktur
6.  Shell und Navigation (inkl. Produkt-Navigation / Ober-Oberreiter)
6b. URL State Governance und Privacy
6c. Tenant-Scope für Stores und Caches
7.  Routenmodell
8.  Designsystem
8b. Design System Governance
8c. ARK CI-Farbpalette und Dark Mode
9.  Kernkomponenten (DataTable, FilterBar, Command Palette, Markdown, PermissionGate)
9.7 Navigation zwischen Entitäten (Vollseiten-Pattern)
10. State Management
11. API Integration (zwei Axios-Instanzen, Interceptors, Rate-Limit-UX)
11b. Rendering Strategy (RSC / CSR)
11c. Next.js Middleware – Edge Auth-Enforcement
11d. Content Security Policy (CSP)
11e. Zod Schema Strategy (ts-to-zod + Response Validation)
12. Globales Toast/Notification-System (Prioritäten, Deduplizierung)
13. Auth und Session
13b. Frontend Permission Model
13c. Field Permission States + resolveFieldRenderState()
14. Electron (IPC Bridge, Protocol Handler, Code Signing, sandbox)
15. Permissions und Sichtbarkeit
16. Realtime und Sync (Supabase Realtime, WebSocket Reconnect)
16b. Query Key und Cache Invalidation Policy (Cross-Module)
16c. Session Bootstrap + Multi-Tab-Synchronisation
16d. Platform Capability Matrix (Web vs. Electron)
16e. Form und Concurrency Patterns
16f. Keyboard Shortcut Matrix
16g. Leere, Fehler und Konfliktzustände
16h. Query Cache TTL – Ressourcengruppen
16i. Bulk UX (sync, async, Fehlerreport, Limits)
16j. Print und Export UX
16k. Navigation Recovery (Soft-Delete, 403, Protocol Handler)
16l. Saved Views und Workspace Memory (inkl. Privacy Guardrails)
16m. Import / Export UX (Column Mapping, Dry Run)
16n. Feature Flags und Rollout Strategy (Flag ≠ Permission, Lifecycle)
16o. Internationalisierung und Locale Strategy (de-CH, Intl.Collator)
16p. UI Auditability – Änderungsverlauf sichtbar machen
16q. Offline und Degraded Connectivity Strategy
16r. File Handling UX und Security (Upload, Scan, Preview/Download)
16s. Search UX Governance (drei Paradigmen)
16t. User Preferences Policy
16u. Long-running Tasks UX (Shell-Banner, Push, Retry)
17. Dokumente und Uploads → Vollständig in 16r
17b. Dokument-Pipeline UI pro Stufe
17c. Realtime Presence (Lebenszyklus, Heartbeat, TTL)
18. AI, Matching und RAG UX
18b. AI Explainability UI Standard (Confidence, Audit-Spur)
19. Fehlerbehandlung
20. Performance + Bundle-Budget (≤ 200 kB Initial Bundle)
21. Offline, Netzwerk und Desktop → Vollständig in 16q
21b. React Error Boundary Strategie (Route, Drawer, Widget)
22. Accessibility (A11y)
22b. Session Multi-Tab (BroadcastChannel)
23. Observability (erlaubt / verboten, Session Replay Policy)
24. Testing (Unit, Component, Integration, E2E, Desktop Smoke)
24b. Responsive Policy (Desktop-First, Tablet Read-Only, Mobile Blocker)
24c. ESLint Architekturregeln und Import Boundaries
25. Developer Experience (Setup, DevTools, SemVer, CI/CD, Conventional Commits)
26. Build-Reihenfolge (4 Wellen)
27. Fazit
```

---

## Inhaltsverzeichnis

| # | Abschnitt |
|---|-----------|
| 0 | Zielbild |
| 1 | Absolut verbindliche Grundregeln (Regeln 01–22) |
| 2 | Tech Stack · TypeScript Flags · Version-Pinning |
| 3 | Architekturprinzipien |
| 4 | Informationsarchitektur |
| 4b | Dashboard – Modul-Spezifikation |
| 4c | Kernmodul-Spezifikationen Phase 1 |
| 4d | UI-Detailspezifikation – Masken, Tabs, Felder (ex UI Addendum v1.2) |
| 5 | Ordnerstruktur |
| 6 | Shell und Navigation (inkl. Produkt-Navigation / Ober-Oberreiter) |
| 6b | URL State Governance und Privacy |
| 6c | Tenant-Scope für Stores und Caches |
| 7 | Routenmodell |
| 8 | Designsystem |
| 8b | Design System Governance |
| 8c | ARK CI-Farbpalette und Dark Mode |
| 9 | Kernkomponenten (DataTable · FilterBar · Command Palette · Markdown · Gates) |
| 10 | State Management (TanStack Query · Zustand · Forms · Optimistic) |
| 11 | API Integration (Axios · Interceptors · Types · Fehlernormalisierung) |
| 11b | Rendering Strategy (RSC / CSR) |
| 11c | Next.js Middleware – Edge Auth-Enforcement |
| 11d | Content Security Policy (CSP) |
| 11e | Zod Schema Strategy |
| 12 | Globales Toast/Notification-System |
| 13 | Auth und Session |
| 13b | Frontend Permission Model (4 Ebenen · Backend-Vertrag) |
| 13c | Field Permission States · resolveFieldRenderState() |
| 14 | Electron – Desktop-Spezifikation |
| 15 | Permissions und Sichtbarkeit |
| 16 | Realtime und Sync · Supabase Realtime · WebSocket Reconnect |
| 16b | Query Key und Cache Invalidation Policy |
| 16c | Session Bootstrap · Multi-Tab · BroadcastChannel |
| 16d | Platform Capability Matrix (Web vs. Electron) |
| 16e | Form und Concurrency Patterns |
| 16f | Keyboard Shortcut Matrix |
| 16g | Leere, Fehler und Konfliktzustände |
| 16h | Query Cache TTL – Ressourcengruppen |
| 16i | Bulk UX – vollständige Spezifikation |
| 16j | Print und Export UX |
| 16k | Navigation Recovery |
| 16l | Saved Views und Workspace Memory |
| 16m | Import / Export UX (inkl. Column Mapping) |
| 16n | Feature Flags und Rollout Strategy |
| 16o | Internationalisierung und Locale Strategy (de-CH) |
| 16p | UI Auditability – Änderungsverlauf |
| 16q | Offline und Degraded Connectivity |
| 16r | File Handling UX und Security |
| 16s | Search UX Governance |
| 16t | User Preferences Policy |
| 16u | Long-running Tasks UX |
| 17 | Dokumente und Uploads → siehe 16r |
| 17b | Dokument-Pipeline UI pro Stufe |
| 17c | Realtime Presence (Lebenszyklus · TTL · Datenschutz) |
| 18 | AI, Matching und RAG UX |
| 18b | AI Explainability UI Standard |
| 19 | Fehlerbehandlung |
| 20 | Performance · Bundle-Budget |
| 21 | Offline, Netzwerk und Desktop → siehe 16q |
| 21b | React Error Boundary Strategie |
| 22 | Accessibility (A11y) |
| 22b | Session Multi-Tab |
| 23 | Observability |
| 24 | Testing (Unit · Component · Integration · E2E · Desktop Smoke) |
| 24b | Responsive Policy (Desktop · Tablet · Mobile Blocker) |
| 24c | ESLint Architekturregeln und Import Boundaries |
| 25 | Developer Experience (Setup · DevTools · Versioning · CI/CD · Commits) |
| 26 | Build-Reihenfolge (Wellen 1–4) |
| 27 | Fazit |

---

## 0. Zielbild

Das Frontend ist nicht einfach eine hübsche Oberfläche. Es ist gleichzeitig:

1. **Arbeitsoberfläche** für Power User mit hoher Informationsdichte
2. **Steuerkonsole** für Kandidaten, Accounts, Mandate, Prozesse, Reminders und Automationen
3. **Review-Schicht** für AI-Vorschläge, Matching, RAG-Treffer und Dokumentverarbeitung
4. **Realtime-Oberfläche** für Notifications, Reminder-Zähler und ausgewählte Statusänderungen
5. **Sichere Präsentationsschicht** über einem mandantenfähigen Backend mit Field-Level-Permissions
6. **Desktop-geeignete App** für intensive tägliche Nutzung mit Tastaturfokus
7. **Phase-2-Träger** für ERP-Module wie Zeit, Billing, Reporting und Mitarbeiterentwicklung

**Architekturprinzip:** Schnelle Arbeitsoberfläche für Power User – nicht generisches CRUD-Adminpanel.
Servergetriebene Wahrheit. UI-State klar getrennt von Server-State.

---

## 1. Absolut verbindliche Grundregeln

```text
REGEL 01  Das Frontend ist nie Source of Truth für Geschäftsdaten – das Backend ist es
REGEL 02  tenant_id kommt nie aus UI-State, URL oder Formularen – nur aus dem Backend-Kontext
REGEL 03  Rollen, Permissions und Field-Level-Visibility werden nie nur im UI vertraut
REGEL 04  API-Calls laufen immer über einen zentralen Client – keine Wildwuchs-Requests
REGEL 05  Server-State via TanStack Query, UI-State via Zustand – nicht vermischen
REGEL 06  Formulare nutzen React Hook Form + Zod – keine ad hoc Validierung
REGEL 07  Optimistic Updates nur dort, wo ein sauberer Rollback definiert ist
REGEL 08  Stage-Changes MÜSSEN Optimistic Updates nutzen – immer mit Rollback
REGEL 09  Keine PII in localStorage, SessionStorage, URL oder unmaskierten Logs
           localStorage nur für nicht-sensitive UI-Präferenzen (Sidebar, Density, Spalten)
           Niemals für Geschäftsdaten, Suchbegriffe, Entitätsdaten oder Auth-Artefakte
REGEL 10  Hauptdetailansichten (Kandidat, Account, Job, Mandat, Prozess) sind Vollseiten – kein Drawer/Slide-In.
           Drawers nur für: Quick-Edits (1–5 Felder), Unterentitäten (Kontakte, History-Einträge),
           Reminder erstellen, Projekt-Slide-In. Modals nur für kurze Bestätigungen und Alerts.
REGEL 11  Keyboard-First, datenintensiv, konsistent – kein dekoratives Dashboard-Spielzeug
REGEL 12  Alle Haupt-DataTable-Instanzen MÜSSEN TanStack Virtual nutzen
REGEL 13  API-Types werden generiert, nicht manuell gepflegt
REGEL 14  Optimistic Updates sind bei komplexen Writes, AI-Aktionen und Merges verboten
REGEL 15  Suchtext mit möglicher PII darf nie automatisch in die URL geschrieben werden
REGEL 16  Alle Zustand-Stores und Query Caches müssen tenant-aware sein
REGEL 17  withCredentials: true nur für /auth/refresh, /auth/logout, /auth/bootstrap
REGEL 18  Tokens werden nie zwischen Tabs übertragen – nur Session-Events synchronisiert
REGEL 19  Presence ist rein indikativ – sie ersetzt niemals fachliches Locking
REGEL 20  Sensible Daten dürfen nie durch SSR oder Prefetch in HTML-Output landen
REGEL 21  Markdown-Inhalte werden immer via DOMPurify sanitized bevor sie gerendert werden
REGEL 22  UUID in der URL ist erlaubt – sie ist kein Name, keine Kontaktinfo, kein direktes PII
```

---

## 2. Tech Stack

```text
Framework        Next.js 14+ App Router
UI               React 18+ (Server Components + Client Components gezielt)
Language         TypeScript strict (Pflicht-Flags: siehe unten)
Styling          Tailwind CSS + CSS Variables
Components       shadcn/ui als Basis, projektweit angepasst
State            TanStack Query für Server-State, Zustand für UI-State
Forms            React Hook Form + Zod (Validation Mode: onBlur)
Tabellen         TanStack Table + TanStack Virtual
Command Palette  cmdk
Rich Text        Markdown (react-markdown) + DOMPurify für Notiz-/Kommentarfelder
Charts           Recharts (lazy, nicht im Initial Bundle)
Icons            Lucide React
Date             date-fns + date-fns-tz (CH-Format: dd.MM.yyyy, Europe/Zurich)
HTTP Client      Axios (zwei Instanzen: authClient + apiClient)
Desktop          Electron 28+ mit sicherer IPC Bridge
Auth             Access Token im Memory, Refresh via httpOnly Cookie / safeStorage
Realtime         Supabase Realtime (direkter Frontend-Zugriff, kein Proxy)
Deployment       Vercel für Web, Electron Builds separat
Testing          Vitest + Testing Library + Playwright + MSW
Type Generation  OpenAPI Codegen (openapi-typescript) aus Backend-Swagger
Schema Sharing   ts-to-zod aus generierten Types (kein manuelles Schreiben)
Linting          ESLint + eslint-plugin-boundaries
Dev-Playground   Storybook
```

### TypeScript Pflicht-Flags

```json
{
  "strict": true,
  "noUncheckedIndexedAccess": true,
  "exactOptionalPropertyTypes": true,
  "noImplicitReturns": true,
  "noFallthroughCasesInSwitch": true
}
```

Kein `any`. Kein `// @ts-ignore` ohne Kommentar + Issue-Link.

### Version-Pinning-Policy

```text
Minor/Patch:   automatisches Update via Renovate (wöchentlich, CI muss grün bleiben)
Major:         explizite Entscheidung + Migrations-Issue + separater PR
               Betrifft: Next.js, React, Electron, TanStack, shadcn
Review-Rhythmus: Quartalsweise Dependencies-Review
```

---

## 3. Architekturprinzipien

### 3.1 Server-State ist führend
TanStack Query ist der Standard für alle Server-Daten. Kein lokales Caching von Geschäftsdaten.

### 3.2 UI-State ist lokal und leichtgewichtig
Zustand nur für: Sidebar, Drawers, Selektion, Density, Toast-Queue, UI-Presets.

### 3.3 URL ist Teil des Zustands – innerhalb definierter Grenzen
Nur erlaubte Keys (Abschnitt 6b). Kein PII-Text. UUIDs erlaubt (Regel 22 – Begründung: UUID ist ein opaker Identifier, kein Name oder Kontaktdatum).

### 3.4 Frontend trennt vier Modi klar
Lesen · Bearbeiten · Review · Steuern

---

## 4. Informationsarchitektur

### Phase-1-Module
```text
Dashboard · Candidates · Accounts · Account Contacts · Jobs / Vacancies
Mandates · Processes · History / Activities · Documents · Reminders
Notifications · Search · Matching · AI Review · Market Intelligence
Settings · Admin
```

### Phase-2-reserviert
```text
Time · Billing · Reporting · HR · Publishing · Payroll
```

---

## 4b. Dashboard – Modul-Spezifikation

Das Dashboard ist die Startseite. Es zeigt den täglichen Arbeitsfokus, keine dekorativen Charts.

### Inhalt Phase 1

**Block 0 – Aktionsbedarf (NEU v1.2, ganz oben, immer sichtbar)**
```text
Unklassifizierte Einträge:    Gelber Badge mit Zähler — Anrufe/Emails ohne Activity-Type
Ausstehende AI-Empfehlungen:  Badge mit Zähler — AI-Vorschläge die bestätigt/abgelehnt werden müssen
Nicht zugewiesene History:    Badge mit Zähler — Einträge ohne Kandidat/Account-Zuordnung
→ Klick auf jeden Badge öffnet gefilterte Liste der offenen Einträge
→ Eskalation: 24h → Reminder, 48h → Head_of Notification, wöchentlich → KPI-Report
```

**Block 1 – Meine Reminders (oberste Priorität)**
```text
Überfällig:       Reminders deren Datum in der Vergangenheit liegt – rot markiert
Heute:            Reminders mit heutigem Datum – gelb markiert
Nächste 7 Tage:   Vorschau kommender Reminders
Aktionen:         Direktes "Erledigen" ohne Drawer-Öffnung (Optimistic Update erlaubt)
Link:             "Alle Reminders" → /reminders
```

**Block 2 – KPIs (Key Performance Indicators)**
```text
Offene Mandate:             Anzahl aktiver Mandate
Aktive Kandidaten:          Kandidaten mit mind. einem aktiven Prozess
Prozesse nach Stage:        Compact Barchart oder Zahlenreihe (Sourcing / Interview / Offer / ...)
Neue Kandidaten (7 Tage):   Delta zur Vorwoche
Klassifizierungsrate:       Prozent klassifizierter Einträge (Ziel: >95%)
AI-Bestätigungsrate:        Prozent bestätigter/abgelehnter AI-Vorschläge
```

KPIs kommen aus dedizierten Count-Queries (kein Full-Table-Scan im Frontend).
Kein Recharts-Chart im Initial Bundle – lazy geladen.

### Was das Dashboard NICHT zeigt (Phase 1)
- Keine "letzte Aktivitäten" Timeline (kommt in Phase 2 oder als Widget wenn Performance klar ist)
- Kein "Recently Viewed" (gehört in Command Palette, nicht auf Dashboard)
- Keine komplexen Filtermöglichkeiten auf dem Dashboard

### Empty State – neuer User / leerer Tenant

Was sieht jemand der sich zum ersten Mal anmeldet (0 Kandidaten, 0 Mandate, 0 Reminders)?

```text
Block 1 (Reminders): EmptyState-Variante:
  Icon + "Noch keine Reminders"
  CTA: "Ersten Reminder erstellen" → öffnet Reminder-Erstellen-Drawer

Block 2 (KPIs): Zahlen zeigen 0, OHNE Fehlerzustand-Styling
  Nicht grau, nicht ausgegraut – 0 ist ein valider Zustand
  Kleiner Hinweis-Text unter KPI-Block:
  "Lege deinen ersten Kandidaten und dein erstes Mandat an, um loszulegen."
  CTAs: "Kandidat anlegen" · "Mandat anlegen"

Kein Onboarding-Wizard, kein Tooltip-Carousel:
  Zu viel Overhead. Der Hinweis-Text + CTAs reichen für Phase 1.
  Detailliertes Onboarding ist Phase-2-Kandidat.
```

### Empty State – neuer User (kein Daten vorhanden)

Wenn Mandate = 0 und Kandidaten = 0 und Reminders = 0 (frischer Tenant oder neuer User):

```text
KPI-Block:       Zahlen zeigen 0 – kein Verstecken, kein Spinner
                 Unter den KPIs: "Legen Sie los – erstellen Sie Ihren ersten Kandidaten."
                 [Kandidat erstellen] [Mandat erstellen] – zwei prominente CTAs

Reminders-Block: "Keine Reminders – Sie sind auf dem neuesten Stand."
                 Kleines Illustration-Icon (neutral, nicht kindisch)

Onboarding-Hint: einmaliger Hinweis (localStorage-Flag: 'onboarding_dismissed')
                 "Neu hier? Starten Sie mit einem Kandidaten oder einem Mandat."
                 [Schliessen]-Button setzt Flag, Hint verschwindet dauerhaft
```

Kein Blocker-Modal, kein erzwungenes Onboarding-Flow. User kann sofort in die App.

### Technisches Muster
```text
Dashboard = reiner Read-Only View
Alle Daten via TanStack Query (staleTime kurz: 2 min, da täglich geöffnet)
Kein Realtime auf Dashboard-KPIs (Polling via refetchInterval: 5 min als Fallback)
Reminders-Block via Realtime-Invalidation (Count-Signal)
```

---

## 4c. Kernmodul-Spezifikationen (Übersicht Phase 1)

Jedes Modul folgt demselben Grundmuster: Liste + Vollseite (Detail/Edit) + Deep Link.
Klick auf Listenzeile → Navigation zu `/modul/[id]`. Kein Drawer für Hauptdetailansichten.
Drawers bleiben nur für Unterentitäten (Kontakte, History-Einträge, Projekte) und Quick-Edits.

### Candidates
```text
Liste:       DataTable mit Virtualisierung, Default-Sort: last_modified_at DESC
             Spalten: Name, Aktuelle Position, Location, Stage, Temperatur, Wechselmotivation, Letzte Aktivität
Detail:      Vollseite /candidates/[id] (Stammdaten, Functions/Focus, Timeline, Dokumente, AI Suggestions, Prozesse)
Edit:        Section-based (Stammdaten / Kontakt / Kompetenzen / Notes)
Kernbeziehung: Kandidat → Prozesse → Mandate (navigierbar via Links)
Notes:       Markdown-Feld, gespeichert als Plain-Markdown, gerendert via react-markdown + DOMPurify

Stage-Anzeige:
  → candidate_stage als Badge im Header und in der Tabelle
  → Stage ist manuell änderbar (Dialog via Quick Action), auch Datenschutz → Refresh (Sonder-Automation)
  → Bei automatischer Stage-Änderung: Toast-Notification
    "Stage automatisch auf [X] geändert (Grund: [Y])"
  → Stages: Check · Refresh · Premarket · Active Sourcing · Market Now ·
    Inactive · Blind · Datenschutz

Wechselmotivation-Anzeige:
  → Badge neben Temperatur im Header
  → 8 Stufen: Arbeitslos, Will/muss wechseln, Will/muss wahrscheinlich wechseln,
    Wechselt bei gutem Angebot, Spekulativ, Wechselt intern & wartet ab,
    Will absolut nicht wechseln, Will nicht mit uns zusammenarbeiten

Stage-Automatisierungs-Hinweise (inline in Detailseite):
  → Wenn Stage < Active Sourcing UND Dokumente fehlen:
    Info-Banner: "Für Active Sourcing fehlen: [Original CV / Diplom / Arbeitszeugnis]"
    Link zum Dokument-Tab
  → Wenn Stage = Datenschutz:
    Warnung: "Kandidat im Datenschutz-Modus. Wird nach 1 Jahr automatisch auf Refresh gestellt.
    Manuell rückstellbar über Stage-Änderung."
  → Wenn Stage = Inactive UND Grund = Alter:
    Info: "Automatisch auf Inactive gesetzt (Alter > 60)"
  → Wenn Stage = Inactive UND Grund = Cold:
    Info: "Automatisch auf Inactive gesetzt (Temperatur Cold > 6 Monate)"
```

### Accounts
```text
Liste:       Default-Sort: name ASC
             Spalten: Name, Branche, Ort, Sparte, Kundenklasse, Einkaufspotenzial (★), Aktive Mandate
Detail:      Vollseite /accounts/[id] (Stammdaten, Kontakte, Mandate, Timeline, Market Data)
Kernbeziehung: Account → Contacts, Account → Mandate
Neue Felder v1.2:
  purchase_potential (1/2/3 → ★/★★/★★★): Einkaufspotenzial
  agb_confirmed_at + agb_version: AGB-Bestätigung
  → AGB-Badge im Header: "AGB bestätigt ✅ [Datum]" oder "AGB ausstehend ⚠️"
  → Gate-Check: CV-Versand ohne bestätigte AGB → Warnung (kein Block)
```

### Account Contacts
```text
Liste:       Kontakte eines Accounts (Sub-Liste in Account-Detailseite) oder Modul-Liste
Default-Sort: last_name ASC
```

### Jobs / Vacancies
```text
Liste:       Stellenausschreibungen (intern oder extern), Default-Sort: created_at DESC
Kernbeziehung: Job → 0..n Mandate (RPO: mehrere Jobs unter einem Mandat)
Vacancy → Job: Konvertierung via Button "Vakanz zu Job umwandeln"
Job-Status: Open · Filled · On Hold · Cancelled
  Auto-Filled: Automatisch wenn Placement in einem verknüpften Prozess
  Manuell Filled: "Extern besetzt" — Kunde hat Stelle selbst besetzt (getrackt als KPI)
  On Hold: Kunde pausiert die Suche
Vacancy-Status: Open · Filled · On Hold · Cancelled · Lost
  Lost = Stelle extern besetzt, ARK hat den Zuschlag nicht bekommen
  Cancelled = Stelle existiert nicht mehr oder vom Kunden zurückgezogen
Function/Focus: Jeder Job wird mit Functions + Focus verknüpft (AI-Vorschlag möglich)
```

### Mandates
```text
Liste:       Default-Sort: created_at DESC
             Spalten: Titel, Account, Typ (Einzelmandat/RPO/Time), Status, Anzahl Prozesse, Stage-Verteilung
Detail:      Vollseite /mandates/[id] mit Pipeline-Übersicht (Kandidaten in Prozessen)
Kernbeziehung: Mandat → Prozesse → Kandidaten

Mandats-Typen:
  Einzelmandat = Exklusiver Auftrag für eine Stelle. 3-Teile-Zahlung
    (Vertragsunterzeichnung, Shortlist, Placement)
  RPO = Aufbau Abteilung/Standort, mind. 3 Positionen. Jede Position = eigener Job.
    Monatliche Fee + Erfolgsfee pro Position.
  Time = Reine Beratungsleistung. Nur monatliche Fee.

Mandats-Status: Entwurf → Aktiv / Abgelehnt. Aktiv → Abgeschlossen / Abgebrochen.
  Aktivierung: Dokument "Mandatsofferte unterschrieben" hochgeladen → Entwurf → Aktiv
  Abgelehnt: Mandat kommt nicht zustande → KPI: Offerten-Conversion-Rate
  Aktivierung: Automatisch wenn Dokument "Mandatsofferte unterschrieben" hochgeladen wird

Shortlist-Trigger (nur Einzelmandat):
  → Konfigurierbare Anzahl CV Sent (z.B. 2 oder 3) löst 2. Zahlung aus
  → Bei Überschreitung: Abfrage ob Zusatzleistung fällig
  → Zusatzleistungen: Ident-Zusatzpreis + Dossier-Zusatzpreis (pro Mandat definierbar)
```

### Processes (Kern-Entität)
```text
Ein Prozess = ein Kandidat bei einem Account/Job in einer Stage.
Prozesse können mit ODER ohne Mandat existieren (Erfolgsbasis).
Liste:       Default-Sort: stage_changed_at DESC
             Spalten: Kandidat, Account, Job, Mandat (optional), Stage, Zuständiger, Letzte Änderung
Detail:      Vollseite /processes/[id] mit Stage-Change (Optimistic Update), Timeline, Notizen
Stage-Change: Kandidat-Detailseite zeigt aktive Prozesse; Stage-Change aus beiden möglich

Prozess-Status: Open, On Hold, Rejected, Placed, Stale, Closed, Cancelled, Dropped
  Cancelled = Rückzieher nach Placement (Kandidat zieht nach Zusage zurück, 100% Rückvergütung)

Rejection-Flow (bei jeder Absage):
  → Button "Ablehnen" öffnet Modal mit Pflicht-Dropdown:
    - Rejected by: Kandidat / Kunde / Intern
    - Grund: Dropdown aus passender Reason-Tabelle (pflicht, kein Submit ohne Auswahl)
    - Kommentar: optionales Freitextfeld
  → Kein Optimistic Update bei Rejection (Server-Bestätigung abwarten)
  → Nach Rejection: Prozess wird als "Rejected" angezeigt mit Grund-Badge
```

### Jobbasket (innerhalb Job-/Mandat-Detailseite)
```text
Jobbasket ist kein eigenes Modul, sondern ein Tab/Bereich in der Job- oder Mandat-Detailseite.
Zeigt alle Kandidaten die für diesen Job im Basket sind, mit ihrem aktuellen Status.

Spalten:    Kandidat, Stage (Prelead → Oral GO → Written GO → Assigned → To Send),
            Versandstatus, Prozess-Link

Stage-Flow: Prelead → Oral GO → Written GO → Assigned → To Send → CV Sent / Exposé

Preleads:
  → CM wählt nach GO-Termin passende Accounts/Jobs aus → kommen als Preleads in Jobbasket
  → Prelead = erstes Stage, Kandidat weiss noch nichts davon
  → CM bespricht Preleads mit Kandidat im GO-Termin
  → CM versendet Email "Mündliche GOs" mit Prelead-Liste → Prelead → Oral GO (automatisch)
  → Kandidat bestätigt schriftlich → Oral GO → Written GO (automatisch)

Rejection auf Prelead-Stage (3 Varianten):
  → Rejected Candidate: Kandidat will dieses Unternehmen nicht verfolgen
  → Rejected CM: CM findet es nicht sinnvoll zu besprechen
  → Rejected AM: AM findet den Kandidaten nicht passend für diesen Account
  → Pflichtfelder: go_rejected_by (candidate/cm/am) + rejection_type_id (aus dim_jobbasket_rejection_types)

Stage-Badges: Visuell klar erkennbar welcher Gate-Status erreicht ist.

Gate 1 – Assigned (automatisch nach Schriftlichem GO):
  → Grüner Badge "Assigned" wenn alle Bedingungen erfüllt:
    ✅ Schriftliche GOs · ✅ Original CV · ✅ Diplom · ✅ Arbeitszeugnis
  → Roter Badge "Dokumente fehlen" mit Liste fehlender Docs wenn nicht erfüllt
  → Klick auf Badge → Kandidaten-Detailseite Dokument-Tab öffnen

Gate 2 – Versandoptionen (nach Assigned):
  → API: GET /jobs/:id/basket/:candidateId/send-options
  → Button "CV senden" sichtbar wenn: ARK CV + Abstract vorhanden
  → Button "Exposé senden" sichtbar wenn: Exposé vorhanden
  → Beide Buttons sichtbar wenn alle drei Dokumente vorhanden
  → Grauer Zustand + Tooltip wenn keine Versandoption verfügbar

Versand-Flow:
  → Klick auf "CV senden" oder "Exposé senden"
  → Confirmation-Modal: "CV/Exposé an [Kontaktname] senden?"
    Empfänger-Dropdown: Account-Kontakte des zugehörigen Accounts
    Anhänge werden automatisch zusammengestellt (nicht editierbar)
  → Nach Bestätigung: E-Mail wird versendet, Prozess automatisch erstellt
  → Kein Optimistic Update (Server-Bestätigung abwarten, da E-Mail + Prozess)
  → Nach Erfolg: Toast "Prozess erstellt" + Query-Invalidierung

Exposé → CV Sent Upgrade:
  → Prozesse im Stage "Expose" zeigen zusätzlichen Button "CV nachreichen"
  → POST /processes/:id/upgrade-to-cv-sent
  → Stage wechselt zu "CV Sent"
```

### Kandidat ↔ Mandat ↔ Prozess – Kernbeziehung UI

```text
Kandidaten-Detailseite (/candidates/[id]):
  Tab "Prozesse" → Liste aller Prozesse des Kandidaten (mit UND ohne Mandat)
  Button "Zu Mandat hinzufügen" → Mandat auswählen → Prozess erstellt
  Klick auf Prozess → Navigation zu /processes/[id] (Vollseite)

Mandate-Detailseite (/mandates/[id]):
  Tab "Pipeline" → Kanban-Übersicht oder Liste nach Stage
  Button "Kandidat hinzufügen" → Kandidat suchen (Command Palette) → Prozess erstellt
  Klick auf Kandidat → Navigation zu /candidates/[id] (Vollseite)

Prozess-Detailseite (/processes/[id]):
  Zeigt: Kandidat-Summary, Account, Job, Mandat-Summary (optional — kann leer sein bei Erfolgsbasis)
  Stage-Change direkt auf der Seite (Optimistic)
  Links zu Kandidat, Account, Job und Mandat → Navigation zu jeweiliger Vollseite
  Prozesse OHNE Mandat: Mandats-Feld zeigt "Erfolgsbasis" Badge, Konditionen aus Best-Effort-Staffel

  Interview-Timeline (aus fact_process_events, prominent in der Prozess-Übersicht):
    Zeigt ALLE Termine — vergangene (stattgefunden) UND zukünftige (geplant):

    TI:           15.03.2026 14:00 ✅ stattgefunden    — oder "Noch nicht terminiert"
    1. Interview: 22.03.2026 10:00 ✅ stattgefunden    — oder "Noch nicht terminiert"
    2. Interview: 02.04.2026 09:00 📅 geplant          — oder "Noch nicht terminiert"
    3. Interview: —                                     — "Noch nicht terminiert"
    Assessment:   —                                     — "Noch nicht terminiert"

    → Vergangene Termine: ✅ Badge mit Datum, nicht editierbar
    → Zukünftige Termine: 📅 Badge mit Datum, editierbar (DateTimePicker)
    → Ohne Termin: Grau "Noch nicht terminiert" + Button "Termin eintragen"
    → Bei Eingabe: automatisch Reminder + Outlook-Kalendereintrag für CM erstellt
    → Feedback pro Interview: interview_feedback_1st/2nd/3rd (Textfeld, editierbar)
      Feedback wird nach dem Interview ausgefüllt (Coaching/Debriefing-Notizen)
    → Automatischer Reminder wenn Termin fehlt:
      Wenn Prozess-Stage auf TI/1st/2nd/3rd/Assessment wechselt und das entsprechende
      Datum-Feld leer ist → Reminder an CM: "Termin für [Stage] bei [Account] noch nicht eingetragen"
      Frist: konfigurierbar in Admin → Automation-Settings (Default: 2 Tage nach Stage-Wechsel)

Erfolgsbasis-Flow (ohne Mandat):
  Gleicher Ablauf wie mit Mandat: Briefing → GO → Preleads → Versand → Prozess
  Kein Longlist/KPI-Tracking (da kein Mandat), Konditionen individuell überschreibbar
  AGB müssen vom Account bestätigt sein (agb_confirmed_at) → Warnung wenn nicht
```

### Navigation zwischen Entitäten

Da Hauptdetailansichten Vollseiten sind (kein Nested Drawer), erfolgt die Navigation
zwischen verknüpften Entitäten via `router.push()`. Der Zurück-Button und Browser-History
ermöglichen die Rückkehr zur vorherigen Seite.

```text
Beispiel-Flow:
  /candidates → Klick auf Max Muster → /candidates/uuid-123
  → Tab "Prozesse" → Klick auf Prozess → /processes/uuid-456
  → Link "Mandat anzeigen" → /mandates/uuid-789
  → Zurück-Button → /processes/uuid-456
  → Zurück-Button → /candidates/uuid-123
```

### History / Activities
```text
Kein eigenes Edit-Formular – Einträge entstehen durch Aktionen in anderen Modulen
Manuelle Einträge: Anrufnotiz, Meeting-Notiz, E-Mail-Notiz (Markdown-Feld)
  → Erstellt aus Kandidaten-Detailseite, Account-Detailseite oder Prozess-Detailseite
  → Shortcut: "N" = neue Notiz (kontextabhängig)
Liste:       Timeline-View, Default-Sort: timestamp DESC
Filter:      11 Kategorien (Kontaktberührung, Erreicht, Emailverkehr, Messaging,
             Interviewprozess, Placementprozess, Refresh, Mandatsakquise,
             Erfolgsbasis, Assessment, System) + Entitäts-Filter

Automatische Einträge:
  → 3CX-Anrufe: Auto-History mit AI-Vorschlag für Activity-Type (1-Klick bestätigen)
  → Emails (Outlook-Sync): Auto-History, Template-basierte Auto-Klassifizierung
  → System-Events: Briefing, Rebriefing, Assessment Ergebnisse, Inactive, GO Ghosting

Klassifizierungs-Status:
  → pending: Frisch importiert, noch nicht klassifiziert
  → ai_suggested: AI hat Vorschlag gemacht, wartet auf Bestätigung
  → confirmed: Consultant hat AI-Vorschlag bestätigt (1-Klick)
  → manual: Consultant hat manuell klassifiziert (Dropdown)
```

### Notifications
```text
Bell-Icon im Header → Dropdown-Overlay (max. 5 neueste, Link "Alle anzeigen")
/notifications → Vollseite mit Liste aller Notifications
Typen:        Reminder fällig, Prozess geändert, AI-Suggestion, Import abgeschlossen,
              Mention (Phase 2), Export bereit
Aktionen:     Als gelesen markieren (einzeln + alle), direkt zur Entität navigieren
Realtime:     Count via Supabase Realtime Channel, Invalidierung via Query
```

### Reminders
```text
/reminders → Liste aller Reminders (gefiltert: überfällig, heute, bald, alle)
API:        GET /api/v1/reminders (mit Filter-Params: overdue, today, upcoming)
Erstellen:  POST /api/v1/reminders
            Aus jedem Drawer via "Reminder setzen"-Button oder Shortcut
            Felder: Entität, Datum, Uhrzeit, Notiz (Plaintext), Wiederholung (Phase 2)
Auflösen:   POST /api/v1/reminders/:id/complete (Optimistic Update erlaubt)
Snooze:     POST /api/v1/reminders/:id/snooze (+1h, +1d, +1w – Optimistic, schnell)
Ändern:     PATCH /api/v1/reminders/:id (Datum/Notiz)
```

### Merge / Duplikat-UX
```text
Duplikat-Erkennung: Backend-seitig, UI zeigt Merge-Vorschlag als Banner auf Entity-Detail
Merge-Flow:
  1. "Duplikat gefunden: Kandidat X" → Banner mit "Zusammenführen"-Button
  2. Side-by-Side-Vergleich: Felder nebeneinander, User wählt pro Feld welcher Wert gewinnt
  3. Preview der Merged-Entity
  4. Confirm → Backend führt Merge durch (Prozesse, Dokumente, Timeline übernommen)
  5. Kein Optimistic Update – warten auf Server-Bestätigung
```

### Data Quality (DQ) Issues
```text
DQ-Issue Typen:   Pflichtfeld leer, veraltete Kontaktinfo (> 12 Monate), 
                  Duplikatverdacht, AI-Confidence-Warnung
UI:               Gelbes Warning-Icon auf Entity-Row und im Drawer-Header
Schnellfilter:    "mit Data Quality Issue" in FilterBar
DQ-Detail:        Im Drawer-Tab oder inline: Was ist das Problem? Wie beheben?
Beheben:          Feld ausfüllen / Kontakt verifizieren / als "OK" markieren
```

### Settings
```text
Abschnitte:
  Mein Profil:        Name, E-Mail, Passwort-Änderung, Avatar
  Benachrichtigungen: Welche Events triggern Notifications / E-Mail
  Tastatur-Shortcuts: Übersicht, anpassbar (Phase 2)
  Sitzungen:          Aktive Sessions, "Überall abmelden"
  Sprache / Locale:   Phase 2 (aktuell fix de-CH)
```

### Admin
```text
Abschnitte (nur für Admin-Rolle):
  User-Management:      User anlegen, Rollen zuweisen, deaktivieren
  Tenant-Config:        Tenant-Einstellungen, Sparten-Verwaltung
  Feature Flags:        dim_tenant_features — Features pro Tenant aktivieren/deaktivieren
  Automation-Settings:  dim_automation_settings — Alle konfigurierbaren Fristen und Schwellwerte:
                        Ghosting-Frist (Tage), Stale-Prozess (Tage), Inactive-Alter,
                        Datenschutz-Reset (Tage), Briefing-Reminder (Tage),
                        Klassifizierungs-Eskalation (Stunden), Cold-Inactive (Monate),
                        Onboarding-Reminder (Tage), Post-Placement Check-ins (30/60/90 Tage),
                        Klassifizierungsziel (%), Data-Retention-Warnung (Tage)
  Honorar-Settings:     dim_honorar_settings — Best-Effort-Staffel, Rückvergütungsfristen
  Email-Templates:      dim_email_templates — CRUD für Templates, System-Templates nur bearbeiten
  Audit Log:            Readonly-Liste aller Audit-Events (filterbar)
  Event-Chain Explorer:  "Warum ist das passiert?" — kombinierte Timeline pro Entity
                        (fact_history + fact_event_queue + fact_audit_log zusammengeführt)
                        Filter: Quelle (Mensch/System/Automation), Entity-Typ, Zeitraum
                        Zeigt correlation_id Event-Ketten visuell an
  Import-Jobs:          Status aller laufenden und abgeschlossenen Jobs
  Datenqualität:        Übersicht offener DQ-Issues, Duplikat-Kandidaten + Duplikat-Accounts
```

---


## 4d. UI-DETAILSPEZIFIKATION – Masken, Tabs, Felder

> Quelle: ARK_FRONTEND_UI_ADDENDUM_v1.2 (2026-03-28)
> Ergänzt Section 4c mit vollständigen Feld- und Tab-Definitionen pro Maske.

### 4d.0 GLOBALE UI-PATTERNS

### Slide-In Panel (Drawer) — nur für Unterentitäten und Quick-Edits
- **NICHT für Hauptdetailansichten** (Kandidat, Account, Job, Mandat, Prozess → Vollseite)
- Verwendung für: Unterentitäten (Kontakte, History-Einträge), Projekt-Slide-In,
  Quick-Edits (1–5 Felder), Reminder erstellen
- Öffnet von rechts, überlagert Hauptinhalt
- **Im Slide-In: Tabs** zur Strukturierung (KEIN Slide-In im Slide-In)
- Schliessen via X, Escape, oder Klick ausserhalb

### Versionierung (Briefings + Assessments)
- **Pfeil-Navigation** links/rechts: ← [15.03.2026] →
- Aktuellste Version immer zuerst (default)
- "Neue Version" Button erstellt neuen Datensatz
- Ältere Versionen vollständig erhalten

### Oberreiter-Navigation
- Klick auf Oberreiter → **Listenansicht / Suchansicht** zuerst
- Erst bei Klick auf einen Eintrag → Detailansicht

### Hauptnavigation (Oberreiter / Sidebar Gruppe 1)
```
Dashboard │ Kandidaten │ Accounts │ Firmengruppen │ Jobs │ Mandate │ Prozesse │ Projekte │ Scraper
```

Zusätzlich in der Sidebar (Gruppe 2 + 3): Market Intelligence, Admin, Settings.
Vollständige Sidebar-Gruppierung und Produkt-Navigation: siehe Section 6.

---

### 4d.1 KANDIDATEN-DETAILMASKE

### Layout
```
┌─────────────────────────────────────────────────────────────┐
│  [Foto]  Max Muster · Bauleiter · Market Now 🟢             │
│          email@example.com · +41 79 xxx xx xx               │
│          📍 Zürich, CH  [← klickbar → Google Maps]          │
│          Sparte: Hochbau · LinkedIn: [🔗]                   │
│  [Stage-Badge] [Temperature-Badge] [Wechselmotivation-Badge] [DO-NOT-CONTACT-Flag]    │
├─────────────────────────────────────────────────────────────┤
│ Übersicht │ Briefing │ Werdegang │ Assessment │ Jobbasket │ │
│ Prozesse │ History │ Dokumente │ Dok.-Generator │ Reminders │
├─────────────────────────────────────────────────────────────┤
│  [Tab-Inhalt]                                               │
└─────────────────────────────────────────────────────────────┘
```

### Header (immer sichtbar)
- **Foto** aus photo_url (Fallback: Initialen-Avatar)
- Name, primäre Funktion, Stage-Badge, Temperature-Badge, Wechselmotivation-Badge
- Kontaktdaten (email_1, phone_mobile)
- **📍 Standort-Pin** — Klick öffnet Google Maps
- **LinkedIn-Link** 🔗 aus linkedin_url
- Primäre Sparte
- DO-NOT-CONTACT Flag (rot, prominent)
- Quick Actions: Anrufen, E-Mail, Stage ändern, Reminder erstellen

---

### Tab 1: Übersicht / Stammdaten

**Verknüpfung mit Stammdaten (Smart-Suche):**
- Cluster, **Function**, **Focus**, EDV, Education, Sector, Sparte, Languages
- **Es gibt keine "Skills"-Kategorie** — Skills werden über Focus abgebildet
  (dim_skills_master ist DEPRECATED seit v1.2)
- Autocomplete-Suche über dim_functions + dim_focus (hierarchisch)
- Mehrfachzuordnung via Bridge-Tabellen
- Primary-Flag pro Zuordnung
- **Rating 1–10** (nicht basic/advanced/expert)
  - bridge_candidate_functions.rating: 1–10
  - bridge_candidate_focus.rating: 1–10
  - bridge_candidate_edv.rating: 1–10 (zusätzlich skill_level Text)
- Source-Badge (cv_parse, briefing, assessment, linkedin, scraper, manual)
- AI-detected hervorgehoben mit Confidence-Score

**Auto-Fill von LinkedIn / Scraper:**
- LinkedIn-Import füllt automatisch:
  - Stammdaten: Name, Titel, Standort, Functions/Focus
  - **Werdegang:** Arbeitsstationen + Ausbildungen → Tab 3
  - **LinkedIn-URL** → linkedin_url Feld
- AI-Vorschläge als gelbe Badges "AI-Vorschlag" — Klick übernimmt
- Nie direkt in Core-Felder — immer via fact_ai_suggestions

**Felder:**
- Alle Felder aus dim_candidates_profile
- Flags: blue_collar, fachliche_fuehrung, df_1_ebene, df_2_ebene, vr_c_suite
- Status: candidate_temperature (Hot/Warm/Cold), wechselmotivation (8 Stufen)
- Zuständig: candidate_manager_id, candidate_hunter_id, owner_team

---

### Tab 2: Briefing

**Versionierung (unbegrenzt, Pfeil-Navigation):**
```
← [Briefing vom 15.03.2026] → [+ Neues Briefing]
```
- Beliebig viele Briefings — jederzeit erstellbar
- → SCHEMA-ÄNDERUNG: UNIQUE Constraint entfernen

**Auto-Fill aus History (Transkript):**
- Wenn ein History-Eintrag als "Briefing" gelabelt ist →
  AI verarbeitet das Transkript im Hintergrund und füllt Briefing-Felder vor
- **Läuft asynchron** — User kann weiterarbeiten während AI befüllt
- Vorgeschlagene Felder als gelbe "AI-Vorschlag" Badges
- User bestätigt oder überschreibt

**Projekt-Verknüpfung:**
- Abschnitt "Besprochene Projekte"
- Autocomplete-Suche über dim_projects
- **Klick auf Projekt → Slide-In** mit Tabs:
  Übersicht │ Beteiligte │ Kommentare │ Dokumente
- Neues Projekt erfassen falls nicht im System
- Pro Projekt: my_role, challenges, results, Insider-Info

**Abschnitte:**
- Salary: aktuell, Ziel, Schmerzgrenze, Bonus
- Verfügbarkeit: Kündigungsfrist, Freistellung möglich
- Bewertung: Kandidatenbewertung, Gesprächsführung
- Kompetenzen: Hardskills, Social Skills, Methoden, Führung
- Persönlichkeit: Selbstbild, Fremdbild, Motivation, Bedürfnisse, Triggerpunkt
- Zonen: Komfort, Lern, Wachstum, Angst, Sweet Spot
- Privat: Zivilstand, Kinder, Leidenschaft
- Sonstiges: Offene Bewerbungen, andere PDL, Verpflichtung
- **Projekte:** Besprochene Projekte (siehe oben)

---

### Tab 3: Werdegang

**Arbeitsstationen (fact_candidate_employment):**
- Timeline-Darstellung (vertikal, chronologisch)
- **Verknüpfungen pro Station:**
  - Function (dim_functions)
  - Account (dim_accounts) — bei welcher Firma
  - Focus (dim_focus)
  - Education (dim_education) — bei entry_type = education
  - Cluster, Sector, Sparte
- entry_type: job / education / gap / other (visuell unterschieden)
- Aktuell angestellt: grüner Indikator
- Klick auf Station → Slide-In mit Details + Projekten

**Projekte (fact_candidate_projects):**
- Pro Arbeitsstation expandierbar
- **Automatische Zuordnung aus Briefing:** AI erkennt aufgrund
  Briefing-Informationen (Zeitraum, Arbeitgeber) bei welcher
  Arbeitsstation ein Projekt stattfand und ordnet es automatisch zu
- Verknüpfung mit dim_projects (globaler Katalog)
- Klick → Drawer mit Projekt-Detail

**Auto-Fill:**
- LinkedIn-Import füllt Arbeitsstationen + Ausbildungen automatisch
- Scraper-Import füllt aktuelle Position
- AI matcht Firmennamen mit bestehenden Accounts

---

### Tab 4: Assessment

**Untertabs:**
```
Gesamtüberblick │ Scheelen & Human Needs │ App │ AI-Analyse │ Vergleich │ Teamrad
```

**Versionierung (PRO ANALYSE-TYP individuell):**
```
← [DISC vom 15.03.2026] → [+ Neues DISC]
```
- Jeder Analyse-Typ unabhängig versionierbar
- Pfeil-Navigation pro Analyse (aktuellste zuerst)
- **Erweiterbar:** Neue Analyse-Typen später einfach hinzufügbar

**Untertab: Gesamtüberblick**
- Dashboard über alle Analyse-Typen
- Kompakte Zusammenfassung: Letzte Version jeder Analyse
- Key-Scores auf einen Blick
- AI-Cross-Analysis Summary
- "Wann wurde was zuletzt gemacht?" Übersicht

**Untertab: Scheelen & Human Needs**
Aktuelle Analysen:
- **DISC:** Ringdiagramm (4 Quadranten Red/Yellow/Green/Blue)
  - Natural vs. Adapted Profile
  - 12 Sub-Dimensionen als Balkendiagramm
- **Motivatoren (Driving Forces):** 12 Kräfte als Balken (paarweise)
- **Relief (= Stressoren + Resilienz + Motivation):**
  - 8 Stressoren als Balken + Total-Score als Tachometer
  - 5 Antreiber, 3 Coping-Stile
  - 7 Resilienz-Dimensionen als Spider/Radar
  - Burnout-Risk als Ampel
  - Motivation: Sinn + Motivation als Balken, Energie als Tachometer
  - Wechselmotivation + Narrative
- **Outmatch:** Kompetenz-basiert
  - **Einzelne Kompetenzen als Balkendiagramm** (horizontale Balken pro Kompetenz)
  - Spider/Radar als Gesamtübersicht über alle Kompetenzen
  - Total-Score als Tachometer
  - Vergleich gegen Job-Profil-Anforderungen (Soll vs. Ist)
- **6 Human Needs + Bochumer Inventar (BIP):**
  - 6 Human Needs als Balken
  - 12 BIP-Dimensionen als Spider/Radar
  - Kombinierter Dual-Axis Chart

**Untertab: App**
- App-spezifische Analysen (werden automatisch eingespielt)
- **Zusätzliche Metriken:**
  - Antwortzeiten pro Frage
  - Antwortzeiten-Verteilung (Histogramm)
  - Auffälligkeiten: Zu schnell (nicht gelesen?), Zu lange (outzoned?
    abgelenkt? überfordert? anderes gemacht?)
- Ikigai, EQ, generische Results
- (Weitere Analysen später ergänzbar)

**Untertab: AI-Analyse**
- AI Cross-Analysis über ALLE Assessment-Typen
- Stärken / Entwicklungsfelder
- **Entwicklungs-Tracking:**
  - Vergleich aktuelle vs. frühere Versionen
  - Entwicklungen: "EQ +15% seit letztem Assessment"
  - Regressionen: "Burnout-Risk von gelb auf rot"
  - Trend-Line-Charts über Zeit
- Versioniert (Pfeil-Navigation)
- "Neue Analyse generieren" Button

**Untertab: Vergleich**
- **2–8 Kandidaten** nebeneinander
- Dimensionen wählbar (DISC, EQ, Relief, Outmatch, Human Needs, BIP)
- Overlay Spider-Graphs
- AI-Summary
- Export als PDF

**Untertab: Teamrad**
- **Verlinkung zur Account-Maske** → Account / Tab: Teamrad
- Kurzvorschau wenn Prozess/Job verknüpft
- Vollständige Analyse lebt im Account-Tab

---

### Tab 5: Jobbasket / GO-Flow

**Logik: Jobs/Preleads werden IN die Kandidaten-Jobbasket gelegt**
(Nicht: Kandidat wird in Job-Basket gelegt — sondern: Job/Prelead kommt zum Kandidaten)

- Alle Jobs/Preleads die beim Kandidaten im Basket sind (fact_jobbasket)
- GO-Flow als visuelle Pipeline pro Job:
  ```
  Prelead → Oral GO → Written GO → Assigned → To Send → CV Sent / Exposé
  ```
- **Prelead = erster Stage:** CM wählt nach GO-Termin passende Accounts/Jobs aus
- **Automatisiert:** Stufen wechseln via Events/Automation Rules
  - Email "Mündliche GOs" versendet → Prelead → Oral GO
  - Schriftliche GOs eingegangen → Oral GO → Written GO
  - Alle Dokumente vorhanden → Written GO → Assigned (Gate 1)
- **Rejection:** Per Stage möglich mit Pflicht-Begründung
  - go_rejected_by: candidate / cm / am (WER hat abgelehnt)
  - rejection_type_id: aus dim_jobbasket_rejection_types (WARUM)

**AI-Matching (Kandidat → Jobs):**
- "Passende Jobs finden" → fact_match_scores
- Score (0-100) mit Breakdown (zieht aus gesamtem Kandidatenprofil)
- "Als Prelead hinzufügen" Quick-Action

---

### Tab 6: Prozesse

- Aktive Prozesse des Kandidaten (mit UND ohne Mandat)
- **Ansicht umschaltbar:** Kanban oder Liste
- Pipeline visuell (Expose → Placement)
- **Interview-Termine** als Spalte in der Liste: zeigt das nächste anstehende Datum, oder das letzte stattgefundene wenn keines geplant (z.B. "2. Int. am 02.04.2026" oder "1. Int. ✅ 22.03.2026")
- **Klick → Navigation zu /processes/[id]** (Vollseite)
- **Prozess-Status:** Open, On Hold, Rejected, Placed, Stale, Closed, Cancelled, Dropped
  - Cancelled = Rückzieher nach Placement (100% Rückvergütung)
- **Honorar-Berechnung (automatisch):**
  - **Erfolgsbasis (ohne Mandat):** Default Best-Effort-Staffel:
    unter 90k → 21%, unter 110k → 23%, unter 130k → 25%, ab 130k → 27%
    Pro Prozess individuell überschreibbar.
  - **Mit Mandat:** Konditionen aus dem Mandat (Einzelmandat/RPO/Time)
  - Rückvergütungsfristen: Monat 1 → 50%, Monat 2 → 25%, Monat 3 → 10%
  - **Alle Prozentsätze, Schwellen und Fristen konfigurierbar**
    in Admin → Automation-Settings (nicht hardcoded)
  - Anzeige pro Prozess: Geschätztes Honorar in CHF
  - **AGB-Gate-Check:** Bei CV-Versand an Account ohne bestätigte AGB → Warnung

---

### Tab 7: History

- Chronologische Timeline
- Filter: 11 Kategorien (Kontaktberührung, Erreicht, Emailverkehr, Messaging,
  Interviewprozess, Placementprozess, Refresh, Mandatsakquise, Erfolgsbasis, Assessment, System)
- **Klick → Drawer** mit Tabs für Details
- Call: Dauer, Richtung, Sentiment, Transkript, AI-Summary
- Email: Subject, Body, Anhänge, Thread-Ansicht, Reply-Button → Email-Composer
- "Neuer Eintrag" Button
- Klassifizierungs-Status Badge (pending/ai_suggested/confirmed/manual)

---

### Tab 8: Dokumente

- Upload: **Drag & Drop** ODER **Klick → Ordner-Auswahl**
- **Max 20 MB** pro Datei
- **Dokument-Labels:** Original CV, ARK CV, Abstract, Exposé, Arbeitszeugnis, Diplom,
  Zertifikat, Assessment-Dokument, Mandatsofferte unterschrieben, Mandat Report, Sonstiges
- **Bearbeitung:**
  - Seiten drehen (90°/180°/270°)
  - Seitenreihenfolge ändern (Drag & Drop)
  - Seiten löschen / hinzufügen
- OCR/Parsing Status, Version-History, Preview, Reparse
- **Mandatsofferte-Trigger:** Upload mit Label "Mandatsofferte unterschrieben" → Mandat automatisch auf Aktiv

---

### Tab 9: Dokumenten-Generator (ARK CV / Abstract / Exposé)

**Bezieht Daten aus ALLEN Tabs:**
- Übersicht: Stammdaten, Functions, Focus, Foto
- Briefing: Kompetenzen, Bewertung, Salary (nur im ARK CV sichtbar)
- Werdegang: Arbeitsstationen, Ausbildungen, Projekte
- Assessment: Zusammenfassung der Analysen
- Dokumente: Original CV, Diplome, Arbeitszeugnisse

**Dokumenttypen:**
- **ARK CV:** Vollständiges aufbereitetes CV im ARK-Layout (intern und für Kunden, inkl. Gehalt)
- **Abstract:** Kurzzusammenfassung ohne Gehalt (für Kunden)
- **Exposé:** Anonymisierte Version (Name/Foto entfernt, Firmen optional anonymisiert)

**Editor:** Word-ähnlicher WYSIWYG-Editor **innerhalb des CRM**
- Formatting, Bilder, ARK-Branding, Sektionen umordnen
- PDF-Export, versioniert
- **Phase 2:** Rechnungen, Assessment-Reports, Mandate-Status-Reports, Zeitreports

---

### Tab 10: Reminders

- Offene Reminders, Priority-Badge, Erledigt-Toggle
- Recurring, Snooze, "Neuer Reminder"

---

### 4d.2 ACCOUNT-DETAILMASKE

### Layout
```
┌─────────────────────────────────────────────────────────────┐
│  Brun AG · Bauunternehmung · Active · A-Kunde · ★★★         │
│  www.brun-ag.ch · 📍 Zürich [→ Maps] · ING                 │
│  Account Manager: Hans Müller                                │
│  [AGB bestätigt ✅ 15.03.2026]                              │
├─────────────────────────────────────────────────────────────┤
│ Übersicht │ Kontakte │ Standorte │ Firmengruppe │           │
│ Jobs & Vakanzen │ Mandate │ History │ Dokumente │           │
│ Organigram / Stellenplan │ Teamrad                          │
├─────────────────────────────────────────────────────────────┤
│  [Tab-Inhalt]                                               │
└─────────────────────────────────────────────────────────────┘
```

### Tab 1: Übersicht / Stammdaten
- Alle Felder aus dim_accounts
- **Einkaufspotenzial:** ★ (0-1 Positionen/Jahr), ★★ (2-3), ★★★ (3+) — purchase_potential 1/2/3
- **AGB-Status:** agb_confirmed_at + agb_version (wann und welche Version bestätigt)
  - Wenn bestätigt: Grüner Badge "AGB bestätigt [Datum]"
  - Wenn nicht: Gelber Badge "AGB ausstehend"
- **Sparte:** ING/GT/ARC/REM/PUR
- Verknüpfungen: Cluster, Functions, Focus, EDV, Sector, Sparte
- Intelligence, Scraping-Status, Notizen

### Tab 2: Kontakte
- DataTable mit dim_account_contacts
- Primary Contact hervorgehoben, Decision Maker / Budget Holder Badges
- **Status "Left" → Kontakt wird ausgegraut, nach unten in Unterkategorie
  "Inactive" verschoben** (nicht gelöscht — historisch erhalten)
- Klick → Drawer, Quick Actions: Anrufen, E-Mail

### Tab 3: Standorte
- Karte mit allen Standorten, HQ hervorgehoben
- 📍 Pin pro Standort → Google Maps

### Tab 4: Firmengruppe / Konzern
- Baumstruktur dim_account_groups
- Mutter-/Tochtergesellschaften, Navigation

### Tab 5: Jobs & Vakanzen
- Aktive Jobs, Vakanzen (Scraper vs. Manual)
- "Convert to Job" Quick-Action, Mandate-Potential
- Klick → Navigation zu /jobs/[id]

### Tab 6: Mandate
- Mandate dieses Accounts
- **KPIs:**
  - Ident-Target vs. Actual
  - **Anrufversuche:** Vertraglich vereinbart vs. aktuell durchgeführt
    (History-Tracker über Kandidaten in der Longlist)
  - Placement-Datum Ziel vs. Status
- Billing-Übersicht
- Klick → navigiert zu Mandat-Detailansicht

### Tab 7: History
- Gefiltert auf account_id, Kontaktperson-Zuordnung
- Klick → Drawer

### Tab 8: Dokumente
- Mandat Reports, Verträge, Drag & Drop Upload

### Tab 9: Organigram / Stellenplan
- Baumstruktur: Positionen mit Personen
- Scraper-Änderungen hervorgehoben
- Verknüpfung mit Kandidaten
- Offene Positionen (Vakanzen)

### Tab 10: Teamrad (ALLE Analysen)
- **Nicht nur DISC — alle Analyse-Typen aufstellbar**
- **Mitarbeiter auswählbar aus:**
  - Organigram / Stellenplan (dort zugewiesene Personen)
  - Werdegang der Kandidaten (wer arbeitet/arbeitete dort)
  - Manuell hinzufügen
- Analysen: DISC, Motivatoren, Relief, Outmatch, EQ, Human Needs, BIP
- Harmonien + Spannungsfelder erkennen
- Lückenanalyse + AI-Empfehlung
- Export als PDF

---

### 4d.3 MANDATE-DETAILMASKE

### Tabs
```
Übersicht │ Longlist │ Prozesse │ Billing │ History │ Dokumente
```

### Tab 1: Übersicht
- Alle Felder aus fact_mandate
- **Mandats-Typ:** Einzelmandat / RPO / Time (Anzeige als Badge)
- **Status:** Entwurf → Aktiv / Abgelehnt. Aktiv → Abgeschlossen / Abgebrochen
  - Automatische Aktivierung: Wenn Dokument "Mandatsofferte unterschrieben" hochgeladen → Entwurf → Aktiv
  - Manuell Abgelehnt: Wenn Mandat nicht zustande kommt → Entwurf → Abgelehnt
  - KPI: Offerten-Conversion-Rate (wie viele offerierte Mandate kommen zustande)
- Job-Verknüpfung (bei RPO: mehrere Jobs), Owner, Researcher
- KPIs:
  - **Ident-Target vs. Actual:** Actual = Anzahl Kandidaten in der Longlist
  - Call-Target vs. Actual (aus History-Einträgen der Longlist-Kandidaten)
  - **Anrufversuche-Tracker:** Vertraglich vereinbart vs. tatsächlich durchgeführt
  - Markt-Kapazität
- **Shortlist-Trigger (nur Einzelmandat):**
  - Konfigurierbare Anzahl CV Sent (z.B. 2 oder 3) die 2. Zahlung auslöst
  - Anzeige: "Shortlist: 2/3 CV Sent" mit Fortschrittsbalken
  - Bei Erreichen: Notification an AM "2. Zahlung fällig"
  - Bei Überschreitung: Dialog "Zusatzleistung fällig?"
- **Zusatzleistungen:** Ident-Zusatzpreis + Dossier-Zusatzpreis (CHF pro Stück)
  - Anzeige als "Extras: X Idents à CHF Y, Z Dossiers à CHF W"
- Status, Garantie

### Tab 2: Longlist (Mandate-Research)
- **Ansicht umschaltbar:** Kanban ODER Liste
- Kanban: 10 Spalten (research → go_schriftlich → abgelehnt)
- Drag & Drop zwischen Spalten
- Kandidaten-Cards: Foto, Name, Funktion, letzter Kontakt, Priority
- **Durchcall-Funktion für Researcher:**
  - "Nächsten anrufen" Button → öffnet nächsten Kandidaten mit **höchster
    Priority** der noch nicht erreicht wurde (den man unbedingt noch erreichen muss)
  - Click-to-Call Integration (3CX)
  - Status automatisch updaten nach Call (erreichbar/nicht erreichbar)
- Bulk-Actions, Filter (Priority, Validated, NoGo)

### Tab 3: Prozesse
- Alle Prozesse die zu diesem Mandat gehören
- Kanban oder Liste
- Stage + Status sichtbar
- **Interview-Termine** als Spalte in der Liste (nächstes geplantes oder letztes stattgefundenes Datum)
- Klick auf Prozess → Navigation zu /processes/[id]

### Tab 4: Billing
- fact_mandate_billing Einträge
- **Einzelmandat:** 3 Zahlungen (Vertragsunterzeichnung, Shortlist-Trigger, Placement)
- **RPO:** Monatliche Fee + Erfolgsfee pro Position
- **Time:** Nur monatliche Fee
- Rechnungsstatus, Fälligkeiten
- Summen-Übersicht

### Tab 5: History
- History-Einträge der Kandidaten die in der Longlist sind
- Gefiltert auf mandate_id
- Klick → Drawer

### Tab 6: Dokumente
- Mandat-Reports, Verträge

---

### 4d.4 WEITERE OBERREITER

### 4a. Firmengruppen (Top-Level)
- Listenansicht aller dim_account_groups
- Baumstruktur-Navigation
- Klick → Firmengruppe-Detail mit zugehörigen Accounts

### 4b. Prozesse (Top-Level)
- **Ansicht umschaltbar:** Kanban oder Liste
- Kanban: 9 Spalten (Expose → Placement)
- **Mandat-Tag:** Visuell sichtbar ob Prozess zu einem Mandat gehört oder nicht
- Cards: Kandidat + Account + Job + Stage-Datum
- Drag & Drop für Stage-Wechsel
- Win-Probability pro Spalte
- Filter: Sparte, Team, AM, CM
- Klick → Navigation zu /processes/[id]

### 4c. Projekte (Top-Level)
- Listenansicht dim_projects
- **Verknüpfungen pro Projekt:**
  - Kandidaten, Accounts, Sparte, Cluster, Function, Focus
- Detailansicht: Beteiligte, Kommentare, Insider-Infos, Dokumente
- Suche, Filter, Karten-Ansicht
- Neues Projekt erfassen

### 4d. Scraper (Top-Level)
- **Übersicht:** Welche Accounts werden auto-gescraped
- **Auswählen / Abwählen:** scraping_enabled Toggle pro Account
- **Scrape-Intervall** anpassen pro Account
- **Ergebnisse:** Was wurde gescraped (fact_scraped_items)
  - Status: pending / reviewed / imported / rejected
  - Approve / Reject Workflow
- **Änderungen:** fact_scrape_changes
  - Neue Personen, Abgänge, neue Jobs, geschlossene Jobs, Rollenwechsel
  - Acknowledge-Workflow
- **Manuelles Scrapen:** "Jetzt scrapen" Button pro Account
- **Statistiken:** Letzte Scrape-Zeit, Dauer, Anzahl Items
- **LinkedIn Social Tracking (Erweiterung):**
  - Likes: Welche Posts hat der Kandidat geliked
  - Kommentare: Worauf hat der Kandidat kommentiert
  - Shares: Was hat der Kandidat geteilt
  - Verbindungen: Mit wem ist der Kandidat vernetzt (relevant für Sourcing)
  - Gruppen: In welchen LinkedIn-Gruppen ist der Kandidat
  - Aktivitäts-Score: Wie aktiv ist der Kandidat auf LinkedIn
  - **Zweck:** Gesprächsanknüpfungspunkte, Interessenprofile,
    Wechselbereitschafts-Indikatoren (z.B. "liked Job-Posts von Konkurrenz")

---

### 4d.5 SCHEMA-ÄNDERUNGEN

### 5a. Briefing-Versionierung
```sql
ALTER TABLE ark.fact_candidate_briefing 
  DROP CONSTRAINT fact_candidate_briefing_tenant_id_candidate_id_key;
```

### 5b. Rating-Skala 1-10 (statt basic/advanced/expert)
```sql
-- bridge_candidate_skill: skill_level bleibt als Text, rating wird 1-10
-- bridge_candidate_functions: rating smallint → CHECK (rating BETWEEN 1 AND 10)
-- bridge_candidate_focus: rating smallint → CHECK (rating BETWEEN 1 AND 10)
-- bridge_candidate_edv: rating smallint → CHECK (rating BETWEEN 1 AND 10)
ALTER TABLE ark.bridge_candidate_functions DROP CONSTRAINT IF EXISTS bridge_candidate_functions_rating_check;
ALTER TABLE ark.bridge_candidate_functions ADD CONSTRAINT bridge_candidate_functions_rating_check CHECK (rating BETWEEN 1 AND 10);
ALTER TABLE ark.bridge_candidate_focus DROP CONSTRAINT IF EXISTS bridge_candidate_focus_rating_check;
ALTER TABLE ark.bridge_candidate_focus ADD CONSTRAINT bridge_candidate_focus_rating_check CHECK (rating BETWEEN 1 AND 10);
ALTER TABLE ark.bridge_candidate_edv DROP CONSTRAINT IF EXISTS bridge_candidate_edv_rating_check;
ALTER TABLE ark.bridge_candidate_edv ADD CONSTRAINT bridge_candidate_edv_rating_check CHECK (rating BETWEEN 1 AND 10);
```

### 5c. Bridge Briefing-Projekte
```sql
CREATE TABLE IF NOT EXISTS ark.bridge_briefing_projects (
    id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id       uuid NOT NULL REFERENCES ark.tenants(id),
    is_active       boolean NOT NULL DEFAULT true,
    created_at      timestamptz NOT NULL DEFAULT now(),
    updated_at      timestamptz NOT NULL DEFAULT now(),
    row_version     bigint NOT NULL DEFAULT 1,
    briefing_id     uuid NOT NULL REFERENCES ark.fact_candidate_briefing(id),
    project_id      uuid NOT NULL REFERENCES ark.dim_projects(id),
    candidate_comment text,
    insider_info    text,
    project_rating  int CHECK (project_rating BETWEEN 1 AND 10),
    UNIQUE (tenant_id, briefing_id, project_id)
);
```

### 5d. Honorar-Einstellungen (konfigurierbar pro Tenant)
```sql
CREATE TABLE IF NOT EXISTS ark.dim_honorar_settings (
    id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id       uuid NOT NULL REFERENCES ark.tenants(id),
    is_active       boolean NOT NULL DEFAULT true,
    created_at      timestamptz NOT NULL DEFAULT now(),
    updated_at      timestamptz NOT NULL DEFAULT now(),
    row_version     bigint NOT NULL DEFAULT 1,
    -- Honorarstufen (Best Effort)
    setting_type    text NOT NULL CHECK (setting_type IN ('best_effort','mandate','custom')),
    salary_threshold_chf int NOT NULL,       -- z.B. 90000, 110000, 130000
    fee_percentage  numeric NOT NULL,         -- z.B. 21, 23, 25, 27
    -- Rückvergütung
    refund_month_1_pct numeric DEFAULT 50,    -- Austritt Monat 1: 50%
    refund_month_2_pct numeric DEFAULT 25,    -- Austritt Monat 2: 25%
    refund_month_3_pct numeric DEFAULT 10,    -- Austritt Monat 3: 10%
    -- Fristen
    protection_period_months int DEFAULT 12,  -- 12-Monats-Schutzfrist
    extended_period_months int DEFAULT 16,    -- Verlängerung bei Nichtmeldung
    -- MwSt
    vat_applicable  boolean NOT NULL DEFAULT true,
    valid_from      date NOT NULL DEFAULT CURRENT_DATE,
    valid_to        date,
    UNIQUE (tenant_id, setting_type, salary_threshold_chf)
);
```

### 5e. LinkedIn Social Tracking (Scraper-Erweiterung)
```sql
CREATE TABLE IF NOT EXISTS ark.fact_linkedin_activities (
    id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id       uuid NOT NULL REFERENCES ark.tenants(id),
    is_active       boolean NOT NULL DEFAULT true,
    created_at      timestamptz NOT NULL DEFAULT now(),
    updated_at      timestamptz NOT NULL DEFAULT now(),
    row_version     bigint NOT NULL DEFAULT 1,
    candidate_id    uuid NOT NULL REFERENCES ark.dim_candidates_profile(id),
    activity_type   text NOT NULL 
        CHECK (activity_type IN ('like','comment','share','post','group_join','connection')),
    content_url     text,
    content_text    text,
    content_author  text,
    target_company  text,                     -- Firma auf die sich die Aktivität bezieht
    detected_at     timestamptz NOT NULL DEFAULT now(),
    relevance_score numeric CHECK (relevance_score BETWEEN 0 AND 1),
    is_wechselbereitschaft_signal boolean NOT NULL DEFAULT false,
    notes           text
);

CREATE INDEX idx_linkedin_activities_candidate 
    ON ark.fact_linkedin_activities(candidate_id, detected_at DESC);
```

---

### 4d.6 ASSESSMENT-VISUALISIERUNGEN

| Assessment | Chart-Typ | Bibliothek |
|---|---|---|
| DISC Natural/Adapted | Ringdiagramm (4 Quadranten) | D3 / Custom SVG |
| DISC Sub-Dimensionen | Horizontale Balken (12) | Recharts |
| Motivatoren | Gegenüberstellung Balken (6 Paare) | Recharts |
| EQ 5 Dimensionen | Spider/Radar | Recharts |
| EQ Total | Tachometer/Gauge | Custom SVG |
| Relief – Stressoren | Horizontale Balken (8) | Recharts |
| Relief – Stressor Total | Tachometer | Custom SVG |
| Relief – Resilienz | Spider/Radar (7 Achsen) | Recharts |
| Relief – Burnout Risk | Ampel (grün/gelb/rot) | Custom |
| Relief – Motivation | Balken + Tachometer | Recharts |
| Outmatch Einzelkompetenzen | **Horizontale Balken** pro Kompetenz | Recharts |
| Outmatch Gesamtübersicht | Spider/Radar | Recharts |
| Outmatch Total | Tachometer | Custom SVG |
| Ikigai | 4-Kreise Venn | D3 / Custom SVG |
| 6 Human Needs | Balken (6) | Recharts |
| BIP (Bochumer Inventar) | Spider/Radar (12 Achsen) | Recharts |
| Human Needs + BIP | Dual-Axis Spider | D3 |
| Vergleich (2-8 Kandidaten) | Overlay Spider Graphs | D3 |
| Teamrad (alle Analysen) | Multi-Profile Wheel | D3 / Custom SVG |
| AI Entwicklungs-Trend | Line-Chart über Zeit | Recharts |
| App Antwortzeiten | Histogramm | Recharts |
## 5. Ordnerstruktur

```text
src/
  app/
    (auth)/
      login/page.tsx
      reset-password/page.tsx
    (dashboard)/
      layout.tsx              ← Client Component (Shell, Auth, Realtime)
      page.tsx                ← Dashboard
      candidates/
        page.tsx              ← Client Component
        [id]/page.tsx         ← Client Component (sensitiv, kein SSR)
      accounts/ · contacts/ · jobs/ · mandates/ · processes/
      documents/ · reminders/ · notifications/ · search/
      matching/ · ai-review/ · market-intelligence/
      settings/ · admin/
    api/
    not-found.tsx             ← Globale 404-Seite
    error.tsx                 ← Globale Error-Boundary

  middleware.ts               ← Next.js Edge Middleware (Auth-Enforcement)

  components/
    ui/                       ← shadcn/ui Basis (angepasste Tokens, keine Logik)
    shared/
      DataTable/
      FilterBar/
      StatusBadge/
      EntityCard/
      Timeline/
      SearchPalette/
      CommandPalette/
      EmptyState/
      Skeletons/
      PermissionGate/
      FeatureFlagGate/        ← NEU
      DetailDrawer/
      ErrorState/
      ErrorBoundary/
      ToastSystem/
      PresenceIndicator/
      BulkActionBar/
      ExportButton/
      MarkdownRenderer/       ← react-markdown + DOMPurify
      MarkdownEditor/         ← Textarea mit Markdown-Preview-Toggle
    candidates/ · accounts/ · contacts/ · jobs/
    mandates/ · processes/ · documents/ · reminders/
    notifications/ · matching/ · ai/ · analytics/
    dashboard/                ← Dashboard-spezifische Widgets

  features/
    candidates/ · accounts/ · mandates/ · processes/
    documents/ · matching/ · ai-review/ · search/ · admin/
    dashboard/
    (jedes Feature: api/ · hooks/ · components/ · schemas/ · mappers/)

  hooks/
    useAuth.ts · usePermissions.ts · useKeyboard.ts
    useDebounce.ts · useNetworkStatus.ts · useRealtimeChannel.ts
    useEntityDrawer.ts · useUrlFilters.ts · useTenant.ts
    usePresence.ts · useErrorBoundary.ts · useBulkAction.ts
    useFeatureFlag.ts         ← NEU

  lib/
    api/
      client.ts               ← apiClient (withCredentials: false)
      auth-client.ts          ← authClient (withCredentials: true)
      interceptors.ts
      errors.ts
      queryKeys.ts
      invalidation.ts
      ttl.ts
    auth/
      token-memory.ts · session.ts · guards.ts · bootstrap.ts
    electron/
      bridge.ts · platform.ts · protocol-handler.ts · capabilities.ts
    realtime/
      supabase.ts             ← Supabase Client (direkter Zugriff für Realtime)
      presence.ts
    notifications/
      toast.store.ts · error-codes.ts
    utils/
      date.ts · formatters.ts · masks.ts · clipboard.ts
      download.ts · export.ts
      field-state.ts          ← resolveFieldRenderState()
      debounce.ts             ← DEBOUNCE_MS = 200 Konstante
      sanitize.ts             ← DOMPurify Wrapper
    i18n/
      de-CH.ts                ← Alle UI-Strings als Konstanten (i18n-Vorbereitung)

  stores/
    ui.store.ts               ← tenant-aware
    filter-presets.store.ts   ← tenant-aware
    command-palette.store.ts  ← tenant-aware
    table-preferences.store.ts ← tenant-aware
    workspace.store.ts        ← tenant-aware
    toast.store.ts

  providers/
    query-provider.tsx · auth-provider.tsx
    theme-provider.tsx · shortcut-provider.tsx

  types/
    api.types.ts              ← GENERIERT (openapi-typescript)
    ui.types.ts · permissions.types.ts

tests/
  fixtures/                   ← kanonische Response-Shapes pro Endpoint
  handlers/                   ← MSW Request-Handler pro Modul
  e2e/                        ← Playwright Tests

.storybook/
  main.ts · preview.ts
```

---

## 6. Shell und Navigation

### Produkt-Navigation (Ober-Oberreiter)

Oberhalb der gesamten Shell (Sidebar + Content) liegt eine horizontale Produkt-Navigationsleiste.
Sie trennt die grossen Produktbereiche. In Phase 1 ist nur CRM aktiv.

```text
CRM │ Zeiterfassung │ Billing │ Analysen & Reporting │ HR & Entwicklung
 ▲        (Phase 2)    (Phase 2)      (Phase 2)            (Phase 2)
aktiv     ausgegraut   ausgegraut     ausgegraut           ausgegraut
```

- Höhe: 40px, Background: #1a1a1a (dunkler als Sidebar), Border-Bottom: 1px solid #333
- ARK-Logo links (Gold-Gradient A-Zeichen + "ARK" in Gold)
- Aktiver Tab: Gold-Unterstreichung (border-bottom 2px #dcb479)
- Inaktive Tabs: text-gray-500, opacity 0.35, cursor-not-allowed
- Phase-2-Items die bisher in der Sidebar standen (Zeiterfassung, Abrechnung, Reporting, HR)
  werden durch diese Leiste ersetzt und aus der CRM-Sidebar entfernt

### Pflichtbestandteile
- Produkt-Navigation (Ober-Oberreiter, ganz oben)
- Linke Hauptnavigation / Sidebar (kollabierbar)
- Obere Leiste: Cmd+K Trigger (plattformabhängig: ⌘K auf Mac, Ctrl+K auf Windows),
  Notifications-Bell (Realtime Count), Reminder-Zähler, User-Menü
- Aktiver Tenant + aktive Sparte im Header sichtbar
- Kontextuelle Sekundärnavigation innerhalb grösserer Module
- Globaler Toast-Bereich
- Banner-Zone: Offline, API degraded, Session expiry

### Sidebar-Gruppierung

Die Sidebar enthält drei visuell getrennte Gruppen (Separatoren zwischen den Gruppen):

```text
GRUPPE 1 – Hauptnavigation (9 Oberreiter laut Section 4d):
  Dashboard │ Kandidaten │ Accounts │ Firmengruppen │ Jobs │ Mandate │ Prozesse │ Projekte │ Scraper

  ─── Separator ───

GRUPPE 2 – Sekundär (Phase-1-Module, nicht in den 9 Oberreitern):
  Market Intelligence

  ─── Separator ───

GRUPPE 3 – System:
  Admin │ Settings
```

Module die NICHT als Sidebar-Einträge erscheinen (aber als Routen erreichbar bleiben):
- Dokumente → Tab in Detailmasken, globale Seite /documents nur via Deep Link
- Suche → primär über Command Palette (Cmd+K), Seite /search via Deep Link
- Matching → Tab in Kandidaten-/Job-Detail, Seite /matching via Deep Link
- Erinnerungen → Dashboard-Widget + Tab in Detailmasken, Seite /reminders via Deep Link
- Benachrichtigungen → Bell-Icon in Top-Bar → /notifications

### Shell-Zustand
```text
Sidebar (collapsed/expanded)  → ui.store.ts + localStorage
                                NICHT tenant-aware (Sidebar-Präferenz gilt global)
Aktiver Tenant                → aus /auth/me, im Auth-Provider
Aktive Sparte                 → aus /auth/me, im Auth-Provider
Tenant-Wechsel                → queryClient.clear() + Store-Resets + Redirect
Density                       → workspace.store.ts + Backend-Persist (tenant-aware)
```

### Navigation-Prinzip
Wenige Hauptpunkte. Tiefe Arbeit in Vollseiten-Detailansichten. Drawers nur für Unterentitäten und Quick-Edits.

---

## 6b. URL State Governance und Privacy

### Erlaubt in der URL
```text
Filter Keys (IDs, Enums, Status-Codes)
Sortierungs-Parameter
Aktiver Tab
Cursor (Pagination)
Saved View ID
Drawer Entity ID (UUID) – Begründung: UUID ist opaker Identifier, kein Name/Kontakt (Regel 22)
Density (optional)
```

### Verboten in der URL
```text
Freier Suchtext · Filterwerte mit PII (Namen, Kontaktdaten)
Tokens · Session-IDs · Semantische RAG-Queries
Compare-/Merge-Referenzen mit sensiblen IDs
```

### Deep Links und Neuer Tab
```text
Direkter URL-Zugriff:      /candidates/uuid-123 → Vollseite
Neuer Tab (Electron):      window.open('/candidates/uuid-123', '_blank')
Web (neuer Tab):           target="_blank" Link auf /candidates/uuid-123
```

---

## 6c. Tenant-Scope für Stores und Caches

Beim Tenant-Wechsel: `queryClient.clear()` (nicht nur invalidate).
Alle tenant-aware Stores: Reset-Action + tenantId als Key-Präfix.

```text
Tenant-aware:   filter-presets, table-preferences, workspace, command-palette, ui (Selektion)
NICHT tenant-aware: sidebar-state, theme, toast-queue
```

---

## 7. Routenmodell

```text
/login · /reset-password
/ → Dashboard
/candidates · /candidates/[id]
/accounts · /accounts/[id]
/contacts · /contacts/[id]
/company-groups · /company-groups/[id]
/jobs · /jobs/[id]
/mandates · /mandates/[id]
/processes · /processes/[id]
/projects · /projects/[id]
/scraper
/documents · /documents/[id]
/reminders · /notifications · /search
/matching · /ai-review · /market-intelligence
/settings · /admin
```

### Detailansichten als Vollseiten
Klick auf Listenzeile → Navigation zu `/[modul]/[id]` als Vollseite.
Hauptentitäten (Kandidaten, Accounts, Jobs, Mandate, Prozesse) öffnen IMMER als Vollseite — kein Drawer.
Drawers bleiben nur für Unterentitäten (Kontakte, History-Einträge, Projekte) und Quick-Edits.

---

## 8. Designsystem

Informationsdicht, nicht dekorativ. Reduzierte Padding- und Typografiepalette.
**Dark Mode only** — vollständige Farbdefinition in Section 8c.

### 8.1 Density-Modi
kompakt · normal (Default) · komfort — tenant-aware, Backend-persist.

### 8.2 Motion-Regeln
Nur funktionale Animationen. `prefers-reduced-motion` immer respektieren.

### 8.3 Tabellenzahlen
`tabular-nums` überall. CHF, %, Datum (dd.MM.yyyy) konsistent.

### 8.4 CSS Variables für Status
Alle Statusfarben aus CSS Variables. Nie hard-codiert. Vollständiger Farbkatalog in Section 8c.

---

## 8b. Design System Governance

### Verbindliche Basis
shadcn/ui als einzige Komponentenbasis. Lucide React als einzige Icon-Library.
Alle Farben, Radien, Schriften, Abstände aus `globals.css` CSS Variables.

### Erlaubt
Komponentenvarianten via shadcn-Konfiguration.
Zusätzliche CSS Variables für modulspezifische Statusfarben.
Wrapper-Komponenten mit Projekt-Defaults.

### Verboten
Direktes className-Überschreiben ohne Varianten-System.
Inline-Styles. Neue Farben ausserhalb CSS Variables.
Eigene Icon-Sets, Date-Picker, Select, Modal neben shadcn.

### Drift-Prävention
Storybook + Chromatic bei jedem PR. PR-Review-Pflicht für `components/ui/` und `components/shared/`.

---

## 8c. ARK CI-Farbpalette und Dark Mode

ARK CRM ist **Dark Mode only**. Kein Light-Mode-Toggle, kein Theme-Switching.
Die Farbpalette stammt aus der ARK Corporate Identity (CI-Handbuch).

### CI-Primärfarben

```text
ark-black:        #262626   (RGB 38,38,38)       Sidebar, Karten, primäre Flächen
ark-gold:         #dcb479   (RGB 220,180,121)     Primärer Akzent, aktive States, CTAs, Highlights
ark-teal-dark:    #1b3051   (RGB 27,48,81)        Sekundärer Akzent, tiefe Hintergründe
ark-teal:         #196774   (RGB 25,103,116)      Tertiärer Akzent, Avatare, Links, Hover
ark-light:        #eeeeee   (RGB 238,238,238)     Primärer Text auf dunklen Flächen
ark-sidebar-hover:#383838   (RGB 56,56,56)        Sidebar Hover, erhöhte Flächen
```

### Farbzuordnung im UI

```text
Produkt-Navigation:     #1a1a1a (dunkler als Sidebar)
Sidebar:                #262626 (ark-black)
Content-Hintergrund:    #1e1e1e
Karten / Erhöhte Flächen: #262626 oder #2a2a2a
Hover-States:           #383838
Borders:                #333333 (Standard), #4d4d4d (Hover)
Aktiver Sidebar-Item:   Border-left 3px #dcb479, Background #dcb479/10
Fokus-Ring:             #dcb479 (Gold)
```

### Status-Farben (funktional, nicht CI)

```text
Success:   #22c55e (Grün)      → Aktiv, Besetzt, Placed
Warning:   #f59e0b (Amber)     → On Hold, Warm, Überfällig
Danger:    #ef4444 (Rot)       → Rejected, Hot, Datenschutz, Fehler
Info:      #0ea5e9 (Blau)      → Market Now, Open, Info-Benachrichtigung
```

### Kandidaten-Stage-Farben

```text
Check:           #808080 (Grau)
Refresh:         #f59e0b (Amber)
Premarket:       #a855f7 (Violett)
Active Sourcing: #22c55e (Grün)
Market Now:      #0ea5e9 (Blau)
Inactive:        #666666 (Dunkelgrau)
Blind:           #4d4d4d (Noch dunkler)
Datenschutz:     #ef4444 (Rot)
```

### Temperature-Farben

```text
Hot:   #ef4444 (Rot)
Warm:  #f59e0b (Amber)
Cold:  #0ea5e9 (Blau)
```

### Wechselmotivation-Farben (NEU v1.2)

```text
Arbeitslos:                          #ef4444 (Rot — dringend)
Will/muss wechseln:                  #f97316 (Orange — hoch)
Will/muss wahrscheinlich wechseln:   #f59e0b (Amber — mittel-hoch)
Wechselt bei gutem Angebot:          #eab308 (Gelb — offen)
Wechselmotivation spekulativ:        #a3a3a3 (Grau — unklar)
Wechselt intern & wartet ab:         #0ea5e9 (Blau — abwarten)
Will absolut nicht wechseln:         #6b7280 (Dunkelgrau — kein Interesse)
Will nicht mit uns zusammenarbeiten: #991b1b (Dunkelrot — blockiert)
```

### Einkaufspotenzial-Anzeige (NEU v1.2)

```text
★     (1): text-foreground-muted
★★    (2): text-ark-gold
★★★   (3): text-ark-gold, font-bold
```

### Implementierung

Alle Farben werden als CSS Variables in `globals.css` definiert (HSL-Format für shadcn/ui-Kompatibilität).
shadcn/ui-Komponenten lesen automatisch aus den CSS Variables — keine Komponentenänderungen nötig.
Zusätzlich werden die ARK-Farben in `tailwind.config.ts` als Custom Colors registriert
(ark-gold, ark-teal, surface-*, stage-*, temp-*).

Tabular-Nums (`font-variant-numeric: tabular-nums`) ist Pflicht für alle Zahlen, CHF-Beträge,
Prozente und Datumsangaben (dd.MM.yyyy).

---

## 9. Kernkomponenten

### 9.1 DataTable – vollständige Spezifikation

**Basis:** TanStack Table + TanStack Virtual

**Virtualisierung:** Pflicht für alle Hauptlisten. Bei < 50 Zeilen read-only: optional.
Container: fixer `overflow-y: auto` mit `height`-Constraint.

**Pagination – Prev/Next mit Cursor:**
```text
UI:           "← Zurück" / "Weiter →" Buttons unterhalb der Tabelle
              Aktuelle Seite: "Seite 2 von ~47" (Approximate Count vom Backend)
URL-stabil:   ?cursor=xxx im Query-Param (erlaubter URL-Key)
Keyboard:     ArrowLeft/Right wenn Pagination-Zone fokussiert
Kein Infinite Scroll (schwer keyboard-navigierbar, schlecht für Power User mit Tab-Wechsel)
Kein klassisches Page-Offset (braucht teures COUNT(*) – Cursor ist effizienter)
```

**Default-Sortierung pro Modul:**
```text
Candidates:   last_modified_at DESC
Accounts:     name ASC
Contacts:     last_name ASC
Jobs:         created_at DESC
Mandates:     created_at DESC
Processes:    stage_changed_at DESC
Documents:    created_at DESC
Reminders:    due_at ASC (überfällige zuerst)
```

**Vertikale Pflichtfeatures:**
- Serverseitige Sortierung, Cursor-Pagination (Prev/Next), Sticky Header
- Multi-Select + Bulk Action Bar, Skeletons
- Spaltensteuerung (persistent pro Modul + User)
- Row Identity per UUID, Keyboard-Navigation (Arrow, Space, Enter)
- URL-Sync (Sortierung, Cursor), Inline Empty State
- PII-Masking in Zellen (via `resolveFieldRenderState()`)
- Error Row + Retry

**Horizontale Komplexität:**
- Pinned Columns links (Name/Status) und rechts (Aktionen)
- Ellipsis + Tooltip, Copy-to-Clipboard für Mail/Tel/URL
- Row Action Menu (Hover/Three-Dot), Spaltenkonfiguration pro User

**A11y in virtuellen Tabellen:**
- `role="grid"`, `aria-rowcount` (Gesamt), `aria-rowindex` pro Zeile
- `aria-sort`, `scope="col"`, Tastaturfokus überlebt Scroll

### 9.2 FilterBar

```text
Debounce:       Zwei Named Constants in lib/utils/debounce.ts:
                DEBOUNCE_MS = 200        → Standard (Textsuche, Filter-Inputs)
                DEBOUNCE_MS_HEAVY = 500  → Teure Endpunkte (RAG-Suche, Matching-Anfragen)
                Kein hardcoded Wert in Komponenten

                Warum unterschiedlich:
                200ms ist optimal für reaktive Textsuche (Kandidatenname, Account).
                RAG und Matching machen LLM-Calls oder Embedding-Lookups – hier kostet
                jeder Request deutlich mehr. 500ms verhindert Spam bei schnellem Tippen.
Suche:          lokal im Store (kein URL-Sync, kein PII in URL)
URL-Sync:       nur erlaubte Keys (Filter-IDs, Enums, Status, Preset-ID)
Komponenten:    Debounce-Input, Selects, Multi-Selects, Date Range, Chips, Reset
Schnellfilter:  "nur meine" · "aktive" · "mit Reminder" · "mit Data Quality Issue"
Presets:        Backend-persist, URL = Preset-ID (nicht der Filterinhalt)
```

### 9.3 Command Palette vs. strukturierte Suche – drei Paradigmen

**Command Palette (`Cmd/Ctrl + K`):**
Schnellnavigation + Quick Actions + recents. Max 8 Ergebnisse. Kein URL-Sync. < 1s zum Ziel.

**Strukturierte Suche (`/search`):**
Filterbasiert, URL-stabil (erlaubte Keys), Saveable Searches.

**Semantische RAG-Suche (Tab in `/search`):**
Freitext, Query lokal (kein URL-Sync), Quellen sichtbar. Nie mit strukturierter Suche vermischt.

### 9.4 Markdown-Renderer und Editor

Für alle Notiz- und Kommentarfelder (Kandidaten, Aktivitäten, Prozessnotizen):

**Warum nicht `react-markdown` + `DOMPurify` direkt:**
`react-markdown` rendert Markdown zu React-Elementen, nicht zu einem HTML-String.
`DOMPurify.sanitize()` erwartet aber einen HTML-String als Input — die beiden passen
nicht ohne Umweg zusammen. Der korrekte Ansatz ist `rehype-sanitize`, das direkt
im AST-Pipeline-Schritt von `react-markdown` sanitiert, bevor überhaupt React-Elemente
erzeugt werden. Das ist sicherer und performanter.

```text
Renderer:  react-markdown mit rehype-sanitize Plugin (sanitiert auf AST-Ebene, Regel 21)

           Konfiguration (defaultSchema aus rehype-sanitize anpassen):
           Erlaubt:    p, strong, em, ul, ol, li, h3, h4, code, pre, blockquote, br, a (href only)
           Verboten:   script, iframe, object, embed, style, form, input
           Verboten:   alle on*-Event-Attribute, javascript:-Links

           import ReactMarkdown from 'react-markdown'
           import rehypeSanitize, { defaultSchema } from 'rehype-sanitize'

           const sanitizeSchema = {
             ...defaultSchema,
             tagNames: ['p','strong','em','ul','ol','li','h3','h4','code','pre','blockquote','br'],
           }
           <ReactMarkdown rehypePlugins={[[rehypeSanitize, sanitizeSchema]]}>
             {markdownString}
           </ReactMarkdown>

Editor:    Textarea-basiert (kein WYSIWYG in Phase 1)
           Toggle: "Bearbeiten" ↔ "Vorschau"
           Markdown-Cheatsheet-Link im Editor-Footer

Speichern: Als roher Markdown-String, nie als HTML
           DOMPurify ist NICHT der primäre Sanitizer hier — rehype-sanitize ist es
           DOMPurify bleibt in lib/utils/sanitize.ts für andere Kontexte (falls nötig)
```

### 9.5 PermissionGate + FeatureFlagGate

**PermissionGate:** show/hide · read-only · maskiert · disabled mit Tooltip.
States in Abschnitt 13c. Für Berechtigungssteuerung.

**FeatureFlagGate:** show/hide für Feature-Availability.
Für Rollout-Steuerung. Nie mit PermissionGate vermischen (Abschnitt 16n).

### 9.6 Weitere Kernkomponenten
EntityCard · Timeline · StatusBadge · DetailDrawer · Skeletons ·
PresenceIndicator · ErrorBoundary · BulkActionBar · ExportButton

---

## 9.7 Detailseiten-Navigation (Vollseiten-Pattern)

Hauptentitäten (Kandidaten, Accounts, Jobs, Mandate, Prozesse) werden immer als
Vollseite dargestellt. Kein Drawer/Slide-In für diese Entitäten.

### Navigation zwischen verknüpften Entitäten

```text
Kandidaten-Detailseite:
  Tab "Prozesse" → Klick auf Prozess → router.push('/processes/[id]')
  Tab "Jobbasket" → Klick auf Job → router.push('/jobs/[id]')

Account-Detailseite:
  Tab "Kontakte" → Klick auf Kontakt → Drawer (Unterentität)
  Tab "Jobs" → Klick auf Job → router.push('/jobs/[id]')
  Tab "Mandate" → Klick auf Mandat → router.push('/mandates/[id]')

Mandat-Detailseite:
  Tab "Longlist" → Klick auf Kandidat → router.push('/candidates/[id]')
  Tab "Prozesse" → Klick auf Prozess → router.push('/processes/[id]')
```

### Zurück-Navigation

```text
Zurück-Button:    Auf jeder Detailseite oben links (← Zurück)
                  router.back() oder Fallback zur Modulliste
Browser-History:  Natürliche Browser-Navigation funktioniert
Tastatur:         Cmd + ← → Zurück zur Liste
```

### Drawers bleiben nur für

```text
Unterentitäten:   Kontakte (in Account), History-Einträge, Projekt-Slide-In
Quick-Edits:      Einzelne Felder ändern (1–5 Felder)
Erstellen:        Reminder erstellen, Notiz erstellen, Quick-Add
```

---


## 10. State Management

### 10.1 TanStack Query
Keys zentral (`lib/api/queryKeys.ts`). Filter + tenantId vollständig im Key.
`placeholderData` für ruhige Listen. Selektive Invalidierung (Abschnitt 16b).
Details und Listen entkoppelt. Count Queries getrennt. Prefetch bei Hover auf Listenzeilen.

### 10.2 Zustand
Nur UI-State. Alle Stores tenant-aware (ausser sidebar, theme). Kein Server-State.

### 10.3 Form State
**Validation Mode: `onBlur`** — validiert beim Verlassen eines Feldes, nicht bei jedem Keystroke.
Dirty Guard global. Serverfehler auf Felder mappen. `row_version` bei jedem PATCH.

### 10.4 Optimistic Updates

**Pflicht für:** Stage-Changes, Reminder auflösen/snoozen, Status Toggles, Read/Unread, Checkboxen

**Explizit verboten bei:** AI Accept, Merge, Bulk, Dokument-Pipeline, Permissions, komplexe Forms,
Matching-Recalculation, Uploads, Multi-Step-Writes

**Muster:** UI sofort → API-Call → Erfolg: Query invalidieren | Fehler: Rollback + Toast

---

## 11. API Integration

### 11.1 Zentraler Axios-Client

**Zwei Instanzen:**
```text
authClient (lib/api/auth-client.ts):
  withCredentials: true
  Nur für: POST /auth/refresh · POST /auth/logout · GET /auth/bootstrap

apiClient (lib/api/client.ts):
  withCredentials: false
  Für: alle anderen API-Calls
  Basis-URL: /api/v1/
  Content-Type: application/json
  x-request-id: automatisch per Interceptor
```

**AbortController – Scope und Verhalten:**
```text
Scope:        Ein AbortController pro TanStack Query Request (von TanStack verwaltet)
              Kein manueller Controller in Komponenten nötig
Navigation:   TanStack Query cancelt automatisch bei `enabled: false` oder Unmount
Drawer:       `queryClient.cancelQueries([key])` beim Drawer-Schliessen wenn laufend
React 18 StrictMode: TanStack Query ist StrictMode-kompatibel (Requests werden nicht doppelt gemacht)
              Axios-Interceptor muss mit AbortSignal umgehen: `signal.aborted`-Check
```

**Retry-Policy:**
```text
GETs:      max 2 Retries bei Netzwerkfehlern (TanStack Query retry: 2)
Mutationen: kein Retry (TanStack Query retry: 0 für useMutation)
Kein Retry bei: 401, 403, 409, 422, 429
```

**Rate-Limit-UX (429):**
```text
Sofort:     Auslösender Button für `retry-after`-Sekunden deaktiviert (Countdown sichtbar)
Toast:      "Zu viele Anfragen. Bitte X Sekunden warten." (auto-dismiss nach retry-after)
Weitere Requests: aus derselben Aktion werden im UI geblockt (Spinner replaced by Disabled-State)
Nach Ablauf: Button wird automatisch wieder aktiv (kein manueller Reload nötig)
```

### 11.2 Axios Interceptors – 401-Refresh

```text
Request:    Access Token aus Memory + x-request-id setzen
Response 401:
  → Refresh via authClient
  → Erfolg: neuer Token, gepufferte Requests wiederholen (Request-Queue, max 1 Refresh)
  → Fehler: Dirty-State Check → Dialog → Logout → /login
```

### 11.3 API-Types – OpenAPI Codegen

```bash
npm run generate:types   # openapi-typescript aus /api/swagger.json → src/types/api.types.ts
npm run test:contract    # Fixtures vs. aktuelle OpenAPI-Spec (läuft in CI)
```

### 11.4 Fehlernormalisierung
Backend: `{ success, data, meta, error }`. Strikter Normalizer in `lib/api/errors.ts`.

---

## 11b. Rendering Strategy (RSC / CSR)

### Seitenklassen und Rendering-Strategie

```text
(auth)/login                   → RSC (kein User-Kontext)
(dashboard)/layout.tsx         → Client Component (Shell, Realtime, Auth)
Alle (dashboard)/[modul]/      → Client Component (sensitiv, kein SSR)
not-found.tsx                  → RSC
error.tsx                      → Client Component (Error Boundary)
```

**SSR-Privacy (Regel 20):** Keine sensiblen Daten via SSR, `dehydrate` oder Prefetch in HTML.
`dehydrate/HydrationBoundary` nur für nicht-sensitive Daten (Enums, Lookup-Listen).

---

## 11c. Next.js Middleware – Edge Auth-Enforcement

**Warum Middleware:** `layout.tsx`-Guards laufen clientseitig nach dem Render.
Middleware läuft am Edge, bevor die Seite rendert → kein Flash of Unauthorized Content.

```typescript
// middleware.ts
import { NextResponse } from 'next/server'
import type { NextRequest } from 'next/server'

const PUBLIC_PATHS = ['/login', '/reset-password']

export function middleware(request: NextRequest) {
  const { pathname } = request.nextUrl

  if (PUBLIC_PATHS.some(p => pathname.startsWith(p))) {
    return NextResponse.next()
  }

  // Refresh Cookie vorhanden? (httpOnly – nur Existenz prüfbar, nicht Wert)
  const hasRefreshCookie = request.cookies.has('refresh_token')

  if (!hasRefreshCookie) {
    return NextResponse.redirect(new URL('/login', request.url))
  }

  return NextResponse.next()
}

export const config = {
  matcher: ['/((?!_next/static|_next/image|favicon.ico|api/).*)'],
}
```

**Wichtig:** Middleware prüft nur Cookie-Existenz (httpOnly, kein JS-Zugriff).
Echte Permission-Prüfung erfolgt im Auth-Provider nach Bootstrap + in jedem API-Request.
Middleware ist eine erste Linie, kein Ersatz für Backend-Enforcement.

---

## 11d. Content Security Policy (CSP)

CSP schützt gegen XSS, Click-jacking und unerwünschte Resource-Loads.

### Web (Vercel)

In `next.config.ts` als HTTP-Header:

```text
default-src 'self';
script-src 'self' 'unsafe-inline';   ← Next.js braucht inline scripts (einschränken wenn möglich)
style-src 'self' 'unsafe-inline';    ← Tailwind braucht inline styles
connect-src 'self'
  https://[project].supabase.co      ← Supabase REST + Realtime
  wss://[project].supabase.co;       ← Supabase Realtime WebSocket
img-src 'self' data: blob:
  https://[project].supabase.co;     ← Dokument-Previews aus Storage
font-src 'self';
frame-ancestors 'none';              ← kein iframe-Embedding
object-src 'none';
base-uri 'self';
```

### Electron

In `electron/main.ts` per `webPreferences`:
```typescript
webPreferences: {
  contextIsolation: true,
  nodeIntegration: false,
  sandbox: true,
  webSecurity: true,          ← Nie auf false setzen
}
```

Electron CSP via `session.defaultSession.webRequest.onHeadersReceived`.

---

## 11e. Zod Schema Strategy

**Problem:** OpenAPI Codegen produziert TypeScript-Interfaces, nicht Zod-Schemas.
Manuelles Schreiben führt zu Drift zwischen Types und Validierung.

### Lösung: ts-to-zod

```bash
npm run generate:schemas   # ts-to-zod src/types/api.types.ts → src/types/api.schemas.ts
```

Läuft nach `generate:types` in CI. Output ist `.gitignore`d (generiert, nicht editiert).

### API Response Validation (optional aber empfohlen)

```typescript
// lib/api/client.ts – Response Interceptor
import { safeParseResponse } from './response-validator'

apiClient.interceptors.response.use((response) => {
  if (process.env.NODE_ENV === 'development') {
    // Nur in Development: Response gegen Schema validieren und warnen
    // Hinweis: import.meta.env ist Vite-Syntax – Next.js nutzt process.env
    safeParseResponse(response)
  }
  return response
})
```

In Production: kein Performance-Overhead durch Validation.
In Development: Schema-Drift wird sofort als Console-Warning sichtbar.

### Formular-Schemas

Formular-Zod-Schemas sind **manuell** in `features/[x]/schemas/`.
Sie können strenger sein als die API-Schemas (z.B. Pflichtfelder im UI die API-seitig optional sind).
Kein Auto-Generieren für Formular-Schemas – zu viel Business-Logik.

---

## 12. Globales Toast/Notification-System

### Prioritätsmatrix

```text
Priorität   Typ        Verhalten             Auslöser
────────────────────────────────────────────────────────────────────
1 (höchst)  blocking   Vollbild-Modal        Forced Reauth, kritischer Datenverlust
2           error      persistent Toast      API-Fehler, Konflikt, Permission Denied
3           warning    persistent Toast      Session bald abgelaufen, Rate Limit
4           success    auto-dismiss 3s       Speichern OK, Export gestartet
5           info       auto-dismiss 4s       Hinweise, Feature-Infos
```

### Toast-Store-Regeln
```text
Max. gleichzeitig:  4 (älteste verdrängt, ausser persistent)
Blocking:           kein Toast – separater Modal-Flow
conflict:           eigener Typ mit CTA "Neu laden" / "Vergleichen"
```

### Deduplizierung
```text
Dedup-Key:  errorCode + entityId (falls vorhanden)
Fenster:    5 Sekunden
Verhalten:  erster Toast erscheint, Duplikate ignoriert, Counter optional sichtbar ("3×")
```

### Error-Code-Mapping (`lib/notifications/error-codes.ts`)
```text
VALIDATION_ERROR      → "Bitte Eingaben prüfen: {details}"
VERSION_CONFLICT      → "Datensatz wurde geändert. Bitte neu laden."
RATE_LIMITED          → "Zu viele Anfragen. Bitte {n}s warten." (Countdown)
PERMISSION_DENIED     → "Keine Berechtigung für diese Aktion."
SERVICE_UNAVAILABLE   → "System vorübergehend nicht verfügbar."
AUTH_EXPIRED          → "Sitzung abgelaufen. Bitte neu anmelden."
DUPLICATE_ENTRY       → "Eintrag existiert bereits."
```

### Banner-Zustände (persistent, kein Toast)
Offline · API degraded · Session bald abgelaufen (mit "Verlängern"-Aktion).

---

## 13. Auth und Session

Access Token im Memory. Refresh via httpOnly Cookie (Web) / safeStorage (Electron).

- Access Token nie in localStorage
- `useAuth()` liefert: userId, tenantId, roles (Array!), primaryRole, sparteId
- Multi-Rollen: Ein User kann z.B. Candidate_Manager + Account_Manager sein
- `usePermissions()` prüft: `roles.some(r => allowed.includes(r))`
- Session Expiry sichtbar + "Verlängern"-Aktion
- "Logout everywhere" + Session-Liste im Profilbereich
- Inaktivitätswarnung (Default 5 Minuten vor Ablauf)

---

## 13b. Frontend Permission Model

### Vier Ebenen
**Page Guard:** `middleware.ts` (Edge) + `layout.tsx` (Client). Unauthorized → /login oder 403.

**Section Guard:** Ganze Sektionen (z.B. Salary, AI Review Inbox) nur wenn Permission vorhanden.
Kein leerer Container, kein Layout-Shift.

**Field Guard (PermissionGate):** Auf Feldebene via `resolveFieldRenderState()`.
Kein `if (!value)` für permission-sensitive Felder.

**Action Guard:** Buttons/Links disabled mit erklärendem Tooltip. Versteckt wenn komplett unzulässig.

### Backend-Vertrag – ein kanonisches Muster

```json
{
  "id": "c8b3f2a1",
  "name": "Max Muster",
  "salary": null,
  "phone": "+41 •• ••• ••",
  "_fieldStates": {
    "salary": "KEINE_PERMISSION",
    "phone": "MASKIERT"
  }
}
```

Feldschlüssel immer vorhanden. `_fieldStates` ist kanonische Wahrheit.
`salary: null` ohne `_fieldStates.salary` = Daten fehlen.
`salary: null` mit `_fieldStates.salary = KEINE_PERMISSION` = Permission fehlt.
Kein Endpoint darf abweichen.

---

## 13c. Field Permission States

### Zustände

```text
NICHT_VORHANDEN  → null + kein _fieldStates-Eintrag → UI: "–"
KEINE_PERMISSION → null + _fieldStates = KEINE_PERMISSION → UI: "•••" + Icon
MASKIERT         → partieller Wert + _fieldStates = MASKIERT → UI: "+41 •• ••• ••"
READ_ONLY        → Wert vorhanden + READ_ONLY oder kein Eintrag → UI: normaler Wert
NICHT_GELADEN    → Feld fehlt im Response-Slice → UI: Skeleton
```

### Pflicht-Utility

```typescript
// lib/utils/field-state.ts
resolveFieldRenderState(entity: Entity, fieldName: string): FieldRenderState
// → { state: FieldState, value: unknown }
```

Jedes sensitive Feld läuft durch diese Funktion. Keine ad-hoc-Checks.

---

## 14. Electron – Desktop-Spezifikation

### 14.1 IPC Bridge

```typescript
webPreferences: {
  contextIsolation: true,   // Pflicht: trennt Renderer von Main-Kontext
  nodeIntegration: false,   // Pflicht: kein Node.js im Renderer
  sandbox: true,            // Empfohlen: stärkstes Sandboxing
  webSecurity: true,        // Nie auf false setzen
}
```

**`sandbox: true` und `contextBridge`:** `sandbox: true` schränkt das Preload-Script stark ein —
kein `require()` direkt im Preload möglich. Das ist kompatibel mit dem Architekturentscheid
(`contextIsolation: true` erfordert sowieso `contextBridge`-Patterns). Alle IPC-Channels
werden über `contextBridge.exposeInMainWorld()` im Preload exponiert.

```typescript
// electron/preload.ts
import { contextBridge, ipcRenderer } from 'electron'

contextBridge.exposeInMainWorld('electronBridge', {
  openFile: () => ipcRenderer.invoke('dialog:openFile'),
  notify: (msg: string) => ipcRenderer.send('notification:show', msg),
  // ... nur whitelistete Channels
})
```

Nur whitelistete Channels. Kein Node im Renderer.

### 14.2 Protocol Handler (`ark-crm://`)
```text
app.setAsDefaultProtocolClient('ark-crm')
ark-crm://candidates/[uuid]   → Kandidat-Detailansicht
ark-crm://accounts/[uuid]     → Account-Detailansicht
ark-crm://mandates/[uuid]     → Mandat-Detailansicht
ark-crm://actions/call-log    → Anrufnotiz-Drawer
```

### 14.3 Betriebsregeln
**Single Instance:** `app.requestSingleInstanceLock()`. Protocol-Trigger → fokussiert + navigiert.
**Auto-Update:** `electron-updater`. Background-Check. Banner. Update bei nächstem Neustart.
**Sandbox-Hinweis zu `sandbox: true`:**
`sandbox: true` ist korrekt und wichtig. Es schränkt das Preload-Script ein: kein direktes
`require()` mehr im Preload. Das ist kompatibel mit `contextIsolation: true`, da ohnehin
nur `contextBridge.exposeInMainWorld()` für IPC-Kommunikation verwendet werden darf.
Jeder IPC-Channel wird explizit im Preload via `contextBridge` exponiert — das ist die
einzige erlaubte Methode.

**Code Signing:** macOS (Apple Developer ID) + Windows (EV-Zertifikat). Pflicht vor erstem Release.
**Update-Kanal:** stable (Production) / beta (interne Tests). Konfigurierbar in `electron-builder.yml`.
**Fensterfokus:** `mainWindow.show()` + `mainWindow.focus()` bei Screen-Pop.
**Crash Recovery:** Main-Prozess: unhandled exceptions loggen. Renderer-Crash → Reload-Dialog.
**Fenster:** Minimum 1024×700px. Letzten State wiederherstellen.

---

## 15. Permissions und Sichtbarkeit

Vollständiges Modell in Abschnitt 13b und 13c.
Backend-Vertrag: `_fieldStates` – ein Muster, kein "oder".

---

## 16. Realtime und Sync

### Supabase Realtime – direkter Frontend-Zugriff
Das Frontend verbindet sich direkt mit Supabase Realtime (kein Backend-Proxy).
Der Supabase Anon Key ist im Frontend sichtbar — dies ist per Design zulässig,
da Row Level Security (RLS) als zweite Linie aktiv ist und Realtime-Channels
tenant-scoped sind.

**Was das Frontend direkt liest:** Realtime-Channels für Presence und Notification-Signals.
**Was das Frontend NIE direkt liest:** Operative Tabellen (ark.*) — nur via Backend-API.

### Realtime nur für
Reminder Count · Notification Bell · persönliche Tasks · Stage-Änderungen in offenen Detailansichten

### WebSocket Reconnect-Logik
```text
Supabase Realtime SDK handhabt Reconnect intern (Exponential Backoff).
Frontend überwacht Kanalstatus via onSubscribe-Callback:
  SUBSCRIBED:    normal
  CHANNEL_ERROR: Toast "Echtzeit-Verbindung unterbrochen" + Polling-Fallback (30s)
  TIMED_OUT:     gleich wie CHANNEL_ERROR
  CLOSED:        bei Tab-Hintergrund ok; bei aktivem Tab → Reconnect-Versuch

Polling-Fallback: TanStack Query refetchInterval: 30_000 für Notification Counts
                  während Realtime-Kanal nicht aktiv ist
```

### Pattern
Realtime Event → TanStack Query invalidiert gezielt → UI rendert aus Cache.
Keine zweite Wahrheit im Realtime-Layer.

---

## 16b. Query Key und Cache Invalidation Policy

### Query Keys – tenant-aware
```text
['candidates', { tenantId, ...filters }]
['candidate', { tenantId, id }]
['accounts', { tenantId, ...filters }]
['account', { tenantId, id }]
['mandates', { tenantId, ...filters }]
['mandate', { tenantId, id }]
['processes', { tenantId, ...filters }]
['process', { tenantId, id }]
['notifications', { tenantId, 'count' }]
['reminders', { tenantId, 'count' }]
['reminders', { tenantId, ...filters }]
['matching', { tenantId, ...params }]
['ai-suggestions', { tenantId, ...filters }]
['documents', { tenantId, entityId }]
['timeline', { tenantId, entityId }]
['dashboard-kpis', { tenantId }]
```

### Invalidierungsregeln (inkl. Cross-Module)
```text
Kandidat erstellen:        ['candidates']
Kandidat bearbeiten:       ['candidate', id] · ['matching', {candidateId}] · ['timeline', {entityId: id}]
Stage-Change:              ['process', id] · ['processes'] · ['timeline', {entityId: processId}]
                           · ['dashboard-kpis'] (Prozess-Verteilung ändert sich)
Reminder setzen/auflösen:  ['reminders', 'count'] · ['reminders'] · ['dashboard-kpis']
Notification gelesen:      ['notifications', 'count']
AI Suggestion accept:      ['ai-suggestions'] · betroffene Entität · ['timeline', {entityId}]
Dokument hochgeladen:      ['documents', {entityId}]
Mandat erstellen:          ['mandates'] · ['dashboard-kpis']
Bulk-Aktion:               alle betroffenen Listen + Counts + ggf. Matching
```

---

## 16c. Session Bootstrap

```text
1. App startet → middleware.ts prüft Cookie-Existenz
2. Auth-Provider: Refresh via authClient
   → Erfolg: Access Token in Memory → /auth/me → Permissions + Tenant + FeatureFlags
   → /auth/me OK: App rendert
   → Fehler: /login
3. Splash-Screen oder globales Skeleton während Bootstrap
4. Nach Bootstrap: Route Guards + FeatureFlagGate greifen
```

### Multi-Tab (BroadcastChannel)
```text
'session:logout'       → alle Tabs → /login
'session:refreshed'    → Tab B macht eigenen stillen Refresh (kein Token-Broadcast)
'session:expired'      → alle Tabs → Session-Expired-Banner
'permissions:changed'  → alle Tabs → /auth/me reloaden
```
Kein Token-Broadcast (Regel 18). Tab B nutzt seinen eigenen httpOnly Cookie.

---

## 16d. Platform Capability Matrix

```text
Feature                       Web              Electron
──────────────────────────────────────────────────────────────
Vollständige App-Funktion     ✅               ✅
Token Storage                 httpOnly Cookie  safeStorage
Protocol Handler (ark-crm://) ❌              ✅
Lokale Datei speichern        ❌               ✅ (via IPC)
OS-Benachrichtigungen         Browser API      Electron API
Auto-Update                   ❌               ✅
Code Signing                  n/a              macOS + Windows
Single Instance               ❌               ✅
Offline-Erkennung             navigator.onLine net.isOnline()
Crash Logging                 Sentry           Sentry + Main Log
Print                         Browser-Dialog   Electron-Dialog
Datei-Download                Browser-Link     Dialog + Pfadwahl
```

Alles über `lib/electron/capabilities.ts`. Kein `if (isElectron)` in Komponenten.

### UX-Policy für nicht verfügbare Features im Browser
Protocol Handler: nicht exponieren. Datei-Pfadwahl: Standard-Download. OS-Notifications: Browser-API.

---

## 16e. Form und Concurrency Patterns

### Drei Formular-Typen

**Kurzes Edit-Drawer-Formular (1–5 Felder):**
Whole form save. Optimistic wo erlaubt. Fehler inline + Toast.

**Grosses Vollansicht-Formular (z.B. Kandidat-Edit):**
Section-based save. Dirty Tracking pro Sektion. Kein Optimistic. `row_version` bei jedem PATCH.
Validation Mode: `onBlur`.

**Mehrstufiges Formular (z.B. Mandat erstellen):**
Zustand in React State. Validierung pro Schritt. Submit nur im letzten Schritt. Kein Optimistic.

### row_version Handling
```text
GET → row_version im Form-State mitführen
PATCH → row_version mitsenden
409 → Compare View: "Deine Änderungen" vs. "Aktuelle Version"
       Aktionen: Überschreiben / Verwerfen / Manuell zusammenführen
```

### Dirty Guard
`beforeunload`-Event bei aktivem Dirty-State. Drawer-Schliessen → Dialog.

### Undo
Nur bei simplen reversiblen Aktionen. Toast mit "Rückgängig" (5s) + API-Call zurück.

---

## 16f. Keyboard Shortcut Matrix

### Global
```text
Cmd/Ctrl + K    → Command Palette
Cmd/Ctrl + /    → Shortcut Cheatsheet
Escape          → Drawer / Dialog schliessen
```

### Listen-Ansicht
```text
Arrow Up/Down   → Zeile navigieren
Enter           → Drawer öffnen
Space           → Zeile selektieren
Cmd + A         → Alle sichtbaren selektieren
R               → Liste neu laden
N               → Neue Entity erstellen
```

### Detailseite
```text
Cmd + Enter     → Speichern (Edit-Modus)
Cmd + E         → Edit-Modus aktivieren
Cmd + ←         → Zurück zur Liste
Arrow Left/Right → Prev/Next Entity in Liste
```

### Konfliktregeln
Kein Browser-Standard überschreiben. Kein OS-Standard (Electron). Dialog → Fokus-Trap.

---

## 16g. Leere, Fehler und Konfliktzustände

### Leere Zustände
```text
Filter aktiv:  "Keine Einträge gefunden. Filter anpassen."
Kein Filter:   "Noch keine Einträge. [Erstellen]"
Permission:    "Keine Berechtigung, Einträge zu sehen."
Lädt:          Skeleton
```

### Fehlerzustände
```text
404:           "Nicht gefunden" + Link zur Liste
403:           "Keine Berechtigung"
Soft-Deleted:  "Archiviert" + Restore-Option (wenn berechtigt)
API down:      Retry-Fläche
Offline:       Banner, Retry bei Reconnect
Session exp:   Auth-Dialog (kein Redirect bei Dirty-State)
```

### Konfliktzustände
```text
VERSION_CONFLICT: Compare-View (Überschreiben / Verwerfen / Zusammenführen)
Presence:         "Wird bearbeitet von X" (informativ, kein Blocking)
Integration down: "Vorübergehend nicht verfügbar" (kein Crash)
```

---

## 16h. Query Cache TTL – Ressourcengruppen (`lib/api/ttl.ts`)

```text
Ressourcengruppe        staleTime   gcTime   Begründung
──────────────────────────────────────────────────────────
Stammdaten              30 min      60 min   Seltene Änderungen (Enums, Lookups)
Entitäts-Details         5 min      15 min   Moderate Änderungsrate
Listen / Suchresultate   2 min      10 min   Häufig gefiltert
Dashboard KPIs           2 min       5 min   Täglich geöffnet
Notifications/Reminders  0 (always)  5 min   Immer aktuell
Matching / AI Results    1 min      10 min   Volatile
AI Review Liste          1 min       5 min   Schnelle Review-Zyklen
Presence                 —          —        Nur Realtime-Channel, nie gecacht
```

---

## 16i. Bulk UX – vollständige Spezifikation

`BulkActionBar` erscheint wenn ≥ 1 Zeile selektiert. Zeigt: Anzahl, Aktionen, Deselect.

### Synchron (< 100 Einträge): Auswahl → Preview → Confirm → Ergebnis → Invalidieren
### Asynchron (> 100 Einträge): Auswahl → Preview + Warnung → Job-Trigger → Shell-Banner → Notification

```text
Ergebnis:     "52 OK" / "48 OK, 4 fehlgeschlagen" / "Fehlgeschlagen"
Fehlerreport: Tabelle (ID, Name, Fehlergrund) + CSV-Download + Retry nur Fehlgeschlagene
Soft Limit:   500 (Warnung)
Hard Limit:   2'000 (Backend-seitig erzwungen)
```

Kein Optimistic Update bei Bulk.

---

## 16j. Print und Export UX

### Tabellen-Export
```text
Format:     CSV oder XLSX
Inhalt:     sichtbare Spalten, aktuelle Sortierung
PII:        maskierte Felder bleiben maskiert; KEINE_PERMISSION-Felder nicht exportiert
< 5'000:    synchron + sofortiger Download
≥ 5'000:    Async-Job → In-App Notification + Download-Link (TTL 24h)
            E-Mail: optional, nur für sehr grosse Exporte (konfigurierbar pro Tenant)
Permission: eigener Export-Check (nicht nur Read)
Audit:      Download-Event geloggt
```

### Print
Web: Browser-Dialog. Electron: Electron-Dialog mit Drucker-Auswahl.
Print-CSS: kompaktes Layout ohne Navigation. PII-Masking wie im UI.

### Async-Export-Kanal
Primär: In-App Notification. E-Mail: nur optional für sehr lange Jobs.

---

## 16k. Navigation Recovery

```text
Entität gelöscht:       404 → "Nicht mehr vorhanden" + Link zur Liste
Soft-Deleted:           is_deleted = true → "Archiviert" + Restore (wenn berechtigt)
Keine Permission:       403 → "Keine Berechtigung" + Link zur Startseite
Anderer Tenant:         403/404 → gleich wie "Keine Permission"
ark-crm:// ungültig:    App öffnet → Route rendert 404 → kein Crash
```

Nach jedem Fehlerzustand: mindestens ein Weg zurück. Kein Dead End.

---

## 16l. Saved Views und Workspace Memory

### Was gespeichert wird
```text
Pro User + Modul (tenant-aware):
  Aktive Spalten + Reihenfolge · Sortierung · Density · Letzter Filter (nur erlaubte Keys)
  Letzter Scroll-Cursor (für "Zurück ohne Reset auf Seite 1")

Saved Views (Backend-persist):
  Name · Filter-Konfiguration (nur IDs/Enums/Status – kein Freitext, kein PII)
  Spalten · Sortierung
```

### Privacy Guardrails
```text
Recently Viewed:   persistent: nur Entity-ID + Typ + Timestamp (kein Display-Name = PII)
                   Display-Name: frisch aus Cache beim Rendern
                   Bei Permission-Entzug: beim nächsten Login bereinigen
                   Beim Tenant-Wechsel: vollständig bereinigen

Saved Views:       keine PII-Werte, keine RAG-Queries, keine KEINE_PERMISSION-IDs
Filter Presets:    nur strukturierte Filter; Freitext nur lokal im Store
```

### Ownership-Modell (Phase-2-vorbereitet)
```text
Phase 1: { id, name, owner_id, filters, columns, sort, is_private: true }
Phase 2: + shared_with_team · visibility · default_for_module
```
UI-Label: "Nur ich" (nicht "Privat") — Phase-2-Toggle-ready.

---

## 16m. Import / Export UX

### Import-Flow
```text
1. Datei hochladen (CSV/XLSX)
2. Column/Schema Mapping UI (bei generischen Formaten):
   → Auto-Vorschlag per Name-Matching (Confidence sichtbar)
   → Pflichtfelder rot wenn nicht gemappt
   → Optionale Felder überspringbar
   → Template-Download wenn exaktes Format gewünscht
3. Dry Run (Pflicht): "N Einträge werden importiert, M haben Fehler"
4. Fehlervorschau pro Zeile
5. Confirm → Async-Job → Progress → Ergebnis
Duplikate: Backend-Erkennung, UI zeigt Merge-Vorschlag
Audit:     Import-Event geloggt
```

---

## 16n. Feature Flags und Rollout Strategy

### Flags vs. Permissions – explizite Trennung

```text
Flags steuern VERFÜGBARKEIT:  Ist das Feature für diesen Tenant aktiviert?
Permissions steuern ZUGRIFF:  Darf dieser User das Feature nutzen?
```

Flag false = Feature existiert hier nicht. Kein Lock-Icon, kein "Access Denied", einfach nicht sichtbar.
`FeatureFlagGate` und `PermissionGate` sind verschiedene Komponenten. Nie mischen.

### Feature Flag Lifecycle

Jedes Flag braucht Owner + Review-Datum. Ohne Ablaufdatum: Code-Review abgelehnt.

```text
flag:       "matching_v2"
owner:      verantwortliche Person
created_at: Einführungsdatum
review_by:  spätestes Review-Datum
status:     active | scheduled_removal | permanent
```

`permanent`: für dauerhafte Tenant-Differenzierung. Alle anderen: bereinigen wenn obsolet.

### Implementierung

```text
Quelle:    /auth/me → { feature_flags: { ai_review: true, matching_v2: false, ... } }
           Kein clientseitiger Override. Kein Hardcoding.

FeatureFlagGate:
  <FeatureFlagGate flag="matching_v2">
    <MatchingModule />
  </FeatureFlagGate>

Flag false → Modul nicht gerendert, Navigationseintrag versteckt (nicht disabled)
```

### Rollout: intern → staging → pilot tenant → alle Tenants

---

## 16o. Internationalisierung und Locale Strategy

### Phase-1-Entscheidungen (verbindlich)
```text
UI-Sprache:    Deutsch (Schweiz) – "ss" statt "ß", alle Strings via lib/i18n/de-CH.ts
Datum:         dd.MM.yyyy (date-fns, Locale de explizit gesetzt)
Uhrzeit:       HH:mm (24-Stunden)
Zeitzone:      Europe/Zurich – UTC im Backend, date-fns-tz für Konvertierung
Währung:       CHF 1'234.50 via Intl.NumberFormat('de-CH', { style: 'currency', currency: 'CHF' })
Zahlen:        1'234.56 via Intl.NumberFormat('de-CH')
Telefon:       +41 XX XXX XX XX
Sortierung:    Intl.Collator('de-CH', { sensitivity: 'base' }) – explizit, nie Browser-Default
```

### Speicherformat vs. Anzeigeformat
```text
DateTime:  UTC ISO-String ("2026-03-27T14:32:00Z") → Anzeige "27.03.2026, 14:32"
Currency:  Integer-Cent (123450 = CHF 1'234.50) → Anzeige via Formatter
Numbers:   Zahl (1234.56) → Anzeige "1'234.56"
```
Kein Formular speichert lokalisierten Text. Import-Felder werden vor Speichern normalisiert.

### Sortierung (verbindlich)
```text
Verboten: array.sort() oder a.localeCompare(b) ohne Locale
Pflicht:  new Intl.Collator('de-CH', { sensitivity: 'base' }).compare(a, b)
```

---

## 16p. UI Auditability – Änderungsverlauf

### Was das Frontend zeigt

Pro Entität: `last_modified_at` + `last_modified_by` (Display-Name) + `source_system` (manuell / AI / Import / 3CX).

Timeline-Modul: Jede Änderung mit Zeitstempel, Akteur, Was (Feld + alt + neu), Wie.
Filterbar nach Zeitraum / Akteur / Typ.

AI-Auditability: action (accepted/modified/rejected) · original AI-Wert · finaler Wert · Confidence.

### Was das Frontend NICHT zeigt
Rohe `row_version` · interne UUIDs · Stack Traces.

### UX-Platzierung
"Zuletzt geändert"-Zeile im Entitäts-Header (immer sichtbar).
Timeline: vollständige scrollbare History. Tooltip auf sensiblen Feldern.

---

## 16q. Offline und Degraded Connectivity

```text
online:      Normal
degraded:    Banner "Verbindung instabil – einige Funktionen eingeschränkt"
offline:     Banner "Keine Verbindung – bitte Netzwerk prüfen"
reconnected: Banner weg + aktive Queries neu laden (refetchOnReconnect: true)
```

**Stale Data:** subtiler Hinweis wenn Daten älter als staleTime (kein Lärm wenn frisch).
**GETs:** TanStack Query retried automatisch bei Reconnect.
**Mutationen:** kein Auto-Retry. Formular bleibt offen. Manueller Retry-Button.

---

## 16r. File Handling UX und Security

```text
Erlaubte Typen:   PDF, DOCX, DOC, XLSX, XLS, JPG, PNG, TXT
Max. Grösse:      20 MB pro Datei (Backend-seitig erzwungen)
Max. gleichzeitig: 5 Dateien
```

Client-seitige Vorab-Validierung (Typ + Grösse) vor jedem Upload. Kein Server-Call bei ungültiger Datei.
Progress pro Datei. Abbruch möglich. Fehler pro Datei (nicht global).
Virus-Scan fehlgeschlagen: "Datei wurde aus Sicherheitsgründen abgelehnt." – kein technisches Detail, kein Retry.

Preview: nur mit Permission + Signed Preview URL. Download: eigener Check + Audit-Log + TTL-URL.
Sensible Dokumente: Confirm-Dialog vor Download.

---

## 16s. Search UX Governance

Ranking Backend-seitig. Highlighting via Snippet oder Mark-Matching.
Sensitive Treffer: maskierte Felder bleiben maskiert. KEINE_PERMISSION-Felder kein Snippet.
Suchergebnisse folgen denselben Field-Permission-States wie Detailansichten.

```text
Command Palette:    Navigation + Quick Actions. Max 8 Ergebnisse. Keine Pagination.
Strukturierte Suche: Filterbasiert. URL-stabil. Label: "Suchen".
Semantische Suche:  RAG-basiert. Query lokal. Label: "Semantische Suche" + Info-Icon.
```

---

## 16t. User Preferences Policy

```text
Präferenz              Speicherort             Tenant-aware  Sync
────────────────────────────────────────────────────────────────────
Density                workspace.store.ts      ja            Backend
Sidebar-State          ui.store.ts + LS        NEIN          localStorage
Table Columns          workspace.store.ts      ja            Backend
Table Sort-Default     workspace.store.ts      ja            Backend
Saved Views            Backend                 ja            Backend
Recents (nur IDs)      command-palette.ts      ja            nur lokal
Notification Prefs     Backend                 nein          Backend
Theme (falls genutzt)  ui.store.ts + LS        nein          localStorage
```

Backend-Wert gewinnt bei Konflikt immer. Kein Freitext / Auth-Artefakte in Präferenzen.

---

## 16u. Long-running Tasks UX

```text
< 3s:     normaler Loading-State
3–30s:    Progress-Indicator im Kontext (Drawer, Modal)
> 30s:    Shell-Banner + Notification bei Fertigstellung
sehr lang: Async-Job, Push via Supabase Realtime oder Polling (10s aktiv / 60s ruhend)
```

Shell-Banner: "[Task-Typ] läuft... X% (N von M)". Mehrere Jobs: wichtigster sichtbar.
Navigation weg vom Job: kein Dialog (Job läuft serverseitig weiter).
Abbruch: API DELETE /jobs/[id], Bestätigung bei > 10% Fortschritt.

---

## 17. Dokumente und Uploads

→ Vollständige Spezifikation: Abschnitt 16r (File Handling UX und Security).

Upload: Drag and Drop, Dateiauswahl, Progress, Status (Abschnitt 17b), Retry.
Download: Permission-Check + Audit-Hook. TTL-Signed URLs. Keine offenen Storage-Links.

---

## 17b. Dokument-Pipeline UI pro Stufe

```text
hochgeladen        → Datei empfangen, Checksum OK
scannt             → Virus/Malware-Scan
quarantäne         → Scan fehlgeschlagen, gesperrt
OCR / Parsing      → Text wird extrahiert
entities extracted → Kandidatendaten erkannt
AI Suggestions     → Vorschläge generiert, warten auf Review
embedding          → Semantischer Index aufgebaut
bereit             → Vollständig verarbeitet
fehlgeschlagen[N]  → Stufe N fehlgeschlagen (Stufe explizit sichtbar)
```

Pro Stufe: Retry, manuelles Reprocess (wenn berechtigt), Log-Ansicht.
Hinweis ob redigiert oder sensitiv klassifiziert.

---

## 17c. Realtime Presence

Presence ist **rein indikativ** (Regel 19). Niemals fachliches Locking.
`row_version` verhindert Inkonsistenz, nicht Presence.

### Lebenszyklus
```text
Beginn:    Edit-Drawer öffnet oder Edit-Seite lädt → Channel beitreten
Heartbeat: alle 15s (solange Session alive und Drawer offen)
Ende:      Drawer schliesst / Route wechselt / Tab geschlossen → Channel verlassen
Cleanup:   beforeunload → verlassen; Netzwerkverlust → "unknown"; Reconnect → neu senden
```

### Fokusverlust
Edit Presence bleibt aktiv solange Drawer offen + Session alive.
Nach 60s Fokusverlust: visuell abgeschwächt (grauer Avatar). Vollständige Entfernung nur über TTL.

### TTL / Stale Presence
```text
> 30s kein Heartbeat: stale markieren
> 60s kein Heartbeat: Presence entfernen
App-Sleep:            nach 120s bereinigt
```

UI: Avatare im Drawer-Header. "Wird bearbeitet von X". Mehrere: "X, Y und 1 weitere".
Datenschutz: nur User-ID + Display-Name. Tenant-scoped.

---

## 18. AI, Matching und RAG UX

### AI Review Inbox
accept · reject · modify before accept.
Confidence, Begründung, Quelle, betroffenes Feld. Statusfilter. Bulk nur mit Vorsicht.

### Matching
Score + Explainability. Kandidat-zu-Job und Job-zu-Kandidat getrennt. Keine Blackbox-Ampel.

### RAG
Eigener Modus. Query lokal. Quellen, Snippet, Ursprungsreferenz.

---

## 18b. AI Explainability UI Standard

### Pflichtattribute
```text
confidence:     0.0–1.0 oder kategorisch
source:         "AI – Dokumentanalyse" / "AI – Matching" / "AI – RAG"
affected_field: betroffenes Feld der Entität
rationale:      1–2 Sätze Begründung
status:         pending / accepted / rejected / modified
```

### Confidence-Schwellen
```text
≥ 0.8:    normale Darstellung, Accept-Button prominent
0.5–0.8:  normale Darstellung
< 0.5:    gedämpfte Farbe + Warnhinweis "Niedrige Konfidenz – sorgfältig prüfen"
          Accept-Button sekundär (nicht prominent)
```

### Audit-Spur
```text
accepted: Audit-Log: action=accepted, by=user, source=AI
rejected: Audit-Log: action=rejected, by=user
modified: Audit-Log: action=modified, by=user (modifizierter Wert gespeichert)
```

Accept/Reject/Modified dauerhaft unterscheidbar im Audit-Log.

### Verbote
Kein stiller AI-Write. Kein Bulk-Accept ohne Interface. Kein Auto-Accept bei Confidence < 0.5.

---

## 19. Fehlerbehandlung

```text
Inline:    Feldvalidierung (onBlur)
Toast:     Erfolg, kurze Fehler (Prioritätsmatrix Abschnitt 12)
Banner:    System down, Session expiry
Dialog:    irreversible Aktionen
Conflict:  VERSION_CONFLICT mit Compare View
Retry:     Netzwerkfehler in Listen und Details
```

---

## 20. Performance

- TanStack Virtual: Pflicht für alle Hauptlisten
- Recharts, Drawer, komplexe Formulare: `React.lazy` + `Suspense`
- Query Cache TTL per Ressourcengruppe (Abschnitt 16h)
- Kein Polling wenn Realtime oder Events besser sind

### Bundle-Budget
```text
Initial Bundle (gzip):     ≤ 200 kB
Per-Route-Chunk (gzip):    ≤ 100 kB
Recharts / Charts:         lazy (nicht im Initial Bundle)
Drawers / komplexe Forms:  lazy (nicht im Initial Bundle)
```

CI schlägt fehl wenn Budget überschritten (via `@next/bundle-analyzer` + size-limit).

---

## 21. Offline, Netzwerk und Desktop

→ Vollständige Spezifikation: Abschnitt 16q (Offline und Degraded Connectivity Strategy).

Phase 1: Saubere Kommunikation von Netzwerkverlust. Kein Offline-First.
Optional Phase 2: Drafts, Upload Queue, IndexedDB Persister.

---

## 21b. React Error Boundary Strategie

### Drei Ebenen
**Route-Level:** `error.tsx` (Next.js). Fehler + Retry + Link zur Liste. Log: Route, Typ, x-request-id.
**Drawer-Level:** Jeder DetailDrawer hat eigene Boundary. Schliesst sich nicht automatisch.
**Widget-Level:** Dashboard-Widgets, Charts. Andere Widgets bleiben funktionsfähig.

### Recovery UX
```text
Auto-Retry (einmalig nach 3s): Netzwerkfehler / 503 → Drawer + Widget Level
Manueller Retry:               alle anderen Fehler → Retry-Button
Eingabeschutz:                 Formular-State in Boundary-State sichern vor Reset
```

### Log-Deduplication
Gleicher Fehler < 5s → nur einmal an Sentry. `x-request-id` im Breadcrumb.

---

## 22. Accessibility (A11y)

### Mindeststandard Phase 1
- Focus-Styles nie entfernen
- ARIA-Labels für Icons/Buttons ohne Text
- Tabellen: `role="grid"`, `aria-rowcount`, `aria-rowindex`, `aria-sort`, `scope="col"`
- Modals/Drawers: `role="dialog"`, `aria-modal`, Fokus-Trap (rein + raus)
- `aria-live` für Toasts und Formfehler
- `prefers-reduced-motion` respektieren
- Skip Link für Navigation
- Screenreader-Text für Badges

### Command Palette A11y
`role="combobox"`, `aria-expanded`, `aria-controls`. Ergebnisse: `role="listbox"` + `role="option"`.

---

## 22b. Session Multi-Tab

BroadcastChannel für Session-Events (kein Token-Broadcast).
Logout → alle Tabs /login. Permission-Change → alle Tabs /auth/me reloaden.
Dirty-State pro Tab unabhängig. Forced Reauth: Dialog im aktiven Tab, Banner in anderen.

---

## 23. Observability

### Erlaubt
Error Tracking (Sentry), API Failure Rate, Web Vitals (LCP, CLS, FID),
Bundle Monitoring + Budget-Alerts, Feature Usage (aggregiert), `x-request-id` Correlation.

### Verboten
Session Replay ohne vollständiges DOM-Masking auf PII-Screens.
DOM-Text-Scraping · Screenshot-Telemetrie · individuelle User-Tracking-IDs.

---

## 24. Testing

### Testmatrix

**Unit:** Formatter, Filter Serializer, Permission Mapper, Field State Resolver,
Query Key Builder, Error-Code-Mapper, Platform Capabilities, TTL-Konstanten,
Debounce-Konstante, Locale Formatter, DOMPurify Sanitizer

**Component:** DataTable (Virtual + A11y + Pagination), FilterBar, StatusBadge,
PermissionGate, FeatureFlagGate, CommandPalette, ToastSystem, PresenceIndicator,
ErrorBoundary, BulkActionBar, MarkdownRenderer (Sanitization)

**Integration:** Hooks mit Query Client, Form Submit (onBlur Validation), Realtime Invalidation,
401-Interceptor + Request-Queue, Session Bootstrap, BroadcastChannel,
Bulk Action (sync + async), Rate-Limit-UX (429 → Button-Disable)

**E2E:** Login, Kandidat erstellen, Kandidat bearbeiten mit row_version, Process Stage Change
(Optimistic + Rollback), Prev/Next Pagination, Dokument Upload, AI Suggestion Accept/Reject,
Reminder Workflow, Command Palette, Protocol Handler, Multi-Tab Logout, Bulk mit Teilfehlern,
Export CSV, Markdown Editor + Sanitization

**Desktop Smoke:** Start, Login, Token Refresh, Datei öffnen, Notification Bridge,
ark-crm:// Trigger, Auto-Update-Check, Single Instance, Code Signing verifizieren

### API Mocking (MSW)
MSW als Standard. `tests/fixtures/` + `tests/handlers/`. Kein direktes Axios-Mocking.

### Contract Tests
```bash
npm run test:contract   # Frontend-Fixtures vs. aktuelle OpenAPI-Spec
```

### Visuelle Regression
Storybook + Chromatic. Pflicht für Kernkomponenten.

### DataTable Performance
```text
Messpunkt: erste bedienbare Scroll-Interaktion (= erster Frame scrollbar ohne Frame-Drop)
Ziel:      < 1.5s bei 5'000 Zeilen
Scroll:    keine Frame-Drops > 16ms (60fps)
Sortierung: < 300ms bis Skeleton sichtbar
```

---

## 24b. Responsive Policy

```text
Desktop (≥ 1280px):   vollständig, primärer Support
Laptop (1024–1279px): vollständig, Sidebar auto-collapsed
Tablet (768–1023px):  Read-Only (Listen + Drawers lesbar, kein Editing)
Mobile (< 768px):     Blocker-Screen
```

### Tablet Read-Only (768–1023px)
Sichtbar: Listen, Drawers (read-only), Timeline, Notifications.
Versteckt/Disabled: Edit-Buttons, Bulk Action Bar, Dokument-Upload.
Drawer: fullscreen. Banner: "Bearbeiten nicht verfügbar – bitte Desktop nutzen."

### Mobile Blocker (< 768px)
Vollbild: "ARK ist für Desktop optimiert. Bitte öffne die App auf einem Computer oder Laptop."
Kein Zugriff. Kein Support. Kein Bugfixing.

### Electron-Fenster
Minimum 1024×700px. Letzten State wiederherstellen.

---

## 24c. ESLint Architekturregeln und Import Boundaries

Tool: `eslint-plugin-boundaries`

```text
features/[x]        → components/shared/ · components/ui/ · hooks/ · lib/ · stores/ · types/
                       NICHT: features/[y] direkt

components/shared/  → components/ui/ · hooks/ · lib/ · types/
                       Stores: nur toast.store, ui.store (explizit erlaubt)
                       NICHT: features/

hooks/              → lib/ · types/
                       Stores: eigene Feature-UI-Stores erlaubt (useEntityDrawer → ui.store)
                       NICHT: beliebige Cross-Feature-Stores
                       NICHT: apiClient direkt (API-Calls → features/[x]/api/)

lib/                → types/
                       NICHT: components/ · features/ · stores/ · hooks/
```

### Namenskonventionen (verbindlich)
```text
Query Keys:    ['entity', { tenantId, ...params }] — immer Tuple
Hooks:         useEntityName, useEntityNameList, useEntityNameMutation
Mapper:        toEntityUI(), toEntityAPI() — Richtung im Namen
Schemas:       entityCreateSchema, entityUpdateSchema (Zod)
Store-Actions: setX, resetX, toggleX — niemals fetchX
```

---

## 25. Developer Experience (DX)

### Lokale Entwicklungsumgebung

```bash
# Voraussetzungen
node >= 20 (LTS), npm >= 10, Supabase CLI, Electron (via npm)

# Setup
git clone [repo]
cp .env.example .env.local         # Werte eintragen (siehe unten)
npm install
npx supabase start                 # Lokale Supabase DB (PostgreSQL + Storage + Realtime)
npm run generate:types              # API-Types aus Backend-Swagger
npm run generate:schemas            # Zod-Schemas aus API-Types

# Starten (Web)
npm run dev                        # Next.js auf localhost:3000

# Starten (Electron + Web parallel)
npm run dev:electron               # startet Next.js + Electron via concurrently
```

### Frontend-Umgebungsvariablen (.env.local)

```bash
# Supabase (für Realtime-Zugriff – Frontend nutzt Anon Key, NIE Service Role)
NEXT_PUBLIC_SUPABASE_URL=https://...
NEXT_PUBLIC_SUPABASE_ANON_KEY=...

# Backend-API
NEXT_PUBLIC_BACKEND_URL=https://arkcrm-production.up.railway.app

# App
NEXT_PUBLIC_APP_URL=https://ark-frontend-omega.vercel.app

# VERBOTEN im Frontend:
# SUPABASE_SERVICE_ROLE_KEY → nur im Backend
# JWT_SECRET → nur im Backend
# Alle *_CLIENT_SECRET Variablen → nur im Backend
```

### DevTools (Pflicht in Development)

```text
TanStack Query DevTools:   import { ReactQueryDevtools } from '@tanstack/react-query-devtools'
                           nur wenn process.env.NODE_ENV === 'development'
                           zeigt: Query Keys, Cache-Status, Stale/Fresh, Invalidierungen

Zustand DevTools:          via Redux DevTools Extension (Zustand ist kompatibel)
                           zeigt: Store-State, Aktionen, Time-Travel-Debugging

Next.js DevIndicator:      Standard (nicht deaktivieren)
```

### Versioning-Strategie (SemVer)

```text
Format:  MAJOR.MINOR.PATCH (z.B. 1.3.2)
MAJOR:   Breaking Change in API oder Electron-IPC
MINOR:   Neues Feature, abwärtskompatibel
PATCH:   Bugfix

Changelog:      CHANGELOG.md (automatisch via conventional-changelog)
About-Seite:    /settings → Über ARK: Version, Build-Datum, Commit-SHA
Electron:       Version in app.getVersion() · im Fenster-Titel sichtbar
```

### Conventional Commits (verbindlich)

```text
feat:     Neues Feature
fix:      Bugfix
chore:    Tooling, Dependencies, kein Produktionscode
refactor: Refactoring ohne neues Verhalten
test:     Tests hinzufügen oder ändern
docs:     Dokumentation
style:    Formatierung (kein Logik-Change)
perf:     Performance-Verbesserung

Beispiel: "feat(candidates): add Markdown support to notes field"
          "fix(auth): prevent Token-Broadcast in BroadcastChannel"
```

Commitlint + Husky erzwingen das Format im Pre-Commit Hook.

### CI/CD Pipeline-Übersicht

```text
Bei jedem PR:
  1. npm run generate:types           (Types frisch aus Backend-Swagger)
  2. npm run generate:schemas         (Zod-Schemas)
  3. npm run test:contract            (Frontend-Fixtures vs. OpenAPI)
  4. npm run lint                     (ESLint + Boundaries)
  5. npm run typecheck                (tsc --noEmit)
  6. npm run test                     (Vitest Unit + Component)
  7. npm run build                    (Next.js Build + Bundle-Budget-Check)
  8. npm run storybook:build          (Visual Regression via Chromatic)

Bei Merge in main:
  → Vercel: automatisches Production-Deployment (Web)
  → GitHub Actions: Electron-Build (Windows .exe + macOS .dmg)
  → Code-Signing: via GitHub Secrets (Apple + Windows Zertifikate)
  → Release: GitHub Release + CHANGELOG.md-Update

Preview-Deployments:
  → Vercel erstellt automatisch Preview-URL pro PR
  → Electron: kein automatischer Preview-Build (zu teuer), nur bei Release-Tags
```

### Type Generation
```bash
npm run generate:types    # in CI vor jedem Build
npm run generate:schemas  # direkt danach
```

### Storybook
Stories für: DataTable (5+ States + Pagination), FilterBar, StatusBadge, PermissionGate,
FeatureFlagGate, ToastSystem, BulkActionBar, PresenceIndicator, ErrorBoundary,
MarkdownRenderer (Sanitization-Demo).

### Recently Viewed
Global, tenant-aware, max 20 Einträge FIFO. In `command-palette.store.ts`.
Nur Entity-ID + Typ + Timestamp persistent (kein Display-Name).

---

## 26. Build-Reihenfolge

### Welle 1 – Fundament
App Shell · Auth + Session Bootstrap + middleware.ts · Query Provider
API Client (authClient + apiClient) · PermissionGate · FeatureFlagGate
DataTable Basis (Virtual + Prev/Next Pagination) · FilterBar (Debounce 200ms)
Candidate List · Candidate Detail (Section-based Form + row_version)
Locale Setup (de-CH, Intl.Collator) · Offline/Degraded Banner · Toast-System

### Welle 2 – Kern-CRM
Accounts · Contacts · Mandates · Processes (Stage-Change + Optimistic)
History Timeline + manuelle Aktivitäten (Markdown-Editor)
Notifications (Dropdown + /notifications) · Reminders (Snooze + Auflösen)
Command Palette (cmdk) · Workspace Store + Saved Views
User Preferences Backend-Sync · Long-running Task Banner
Dashboard (KPIs + Reminders-Block)

### Welle 3 – Erweiterte Features
Documents (Pipeline UI + File Security + Signed URLs)
Search (strukturiert + RAG + Governance) · Matching · AI Review (Explainability + Audit)
Realtime Presence · Market Intelligence
Bulk Actions vollständig · Export/Import (Column Mapping) · Print-Layouts
UI Auditability (Timeline-Modul) · Merge/Duplikat-UX · Data Quality UI

### Welle 4 – Abschluss und Desktop
Admin (User-Management, Audit-Log, Import-Jobs) · Settings (vollständig)
Analytics Dashboards · Electron Protocol Handler + Single Instance + Auto-Update + Code Signing
Error Boundaries vollständig · ESLint Boundaries aktiv · Storybook + Chromatic
Bundle-Budget-CI · CI/CD Pipeline vollständig · Phase-2 Plätze

---

## 27. Fazit

Dieses Dokument ist das Ergebnis von acht unabhängigen Reviews über acht Versionen.
v1.8 schliesst die Cross-Document-Review-Lücken. v1.9 ergänzt Design-Entscheidungen
nach erstem visuellen Review und integriert alle Business-Logik-Korrekturen aus der
Gesamtsystem-Übersicht v1.2.

**Business-Logik-Änderungen v1.9 (Gesamtsystem-Review):**
- Wechselmotivation (8 Stufen) neben Temperatur auf Kandidaten-Profil
- Preleads als erster Jobbasket-Stage + differenzierte Rejection (candidate/cm/am)
- Mandatsarten: Einzelmandat/RPO/Time mit korrekten Zahlungsmodellen
- Mandats-Status Entwurf → Aktiv / Abgelehnt (Offerten-Conversion-Rate KPI)
- Prozess-Status: Open, On Hold, Rejected, Placed, Stale, Closed, Cancelled, Dropped
- Erfolgsbasis-Prozesse ohne Mandat mit AGB-Gate-Check
- Account Einkaufspotenzial ★/★★/★★★ + AGB-Tracking
- Datenschutz-Stage: nach 1 Jahr auto → Refresh, manuell rückstellbar
- Skills deprecated → Focus bildet Skills ab
- Dashboard: Aktionsbedarf-Block (unklassifizierte Einträge, AI-Empfehlungen, nicht zugewiesene History)
- Admin: Automation-Settings, Honorar-Settings, Email-Templates als CRUD
- Dok-Typen: ARK CV (statt Dossier), Assessment-Dokument, Max 20 MB

**Bewertung v1.9:**
```text
Architekturqualität:     sehr hoch
Buildbarkeit:            ja – alle Ambiguitäten aufgelöst
Freeze-Reife:            vollständig
Harmonisierung:          DB v1.2 + Backend v2.3 + Frontend v1.9 + Stammdaten v1.2 + Gesamtsystem v1.2 = konsistent
```

**Alle zentralen Entscheidungen sind gesetzt:**

Backend als Source of Truth · TanStack Query (tenant-aware Keys, TTL-Gruppen) ·
TanStack Virtual + Prev/Next Cursor Pagination · Command Palette (cmdk) ·
`ark-crm://` Protocol Handler für 3CX · `_fieldStates` als einziger Backend-Vertrag ·
`resolveFieldRenderState()` als Pflicht-Utility · DOMPurify für Markdown-Notizen ·
Supabase Realtime direkter Zugriff (Frontend → Supabase) mit Reconnect-Logik ·
Next.js Middleware als Edge-Auth-Enforcement · CSP für Web + Electron ·
ts-to-zod für Schema-Sharing · BroadcastChannel für Session-Sync ohne Token-Broadcast ·
Feature Flags via Backend · Locale de-CH verbindlich ·
File Handling (20 MB, DOMPurify, TTL-Signed URLs) ·
Bundle-Budget ≤ 200 kB gzip · Dark Mode only (ARK CI: #262626/#dcb479/#196774) ·
Hauptdetailansichten als Vollseiten · CRM als zentrales Kommunikationstool ·
32 Email-Templates mit 4 Automation-Triggern · Alle Fristen konfigurierbar.

**Das System ist bereit für den nächsten Build-Zyklus.**
