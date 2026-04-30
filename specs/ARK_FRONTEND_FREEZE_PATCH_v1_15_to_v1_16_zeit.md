---
title: "ARK Frontend-Freeze · Patch v1.15 → v1.16 · Zeit-Modul"
type: patch
phase: 3
created: 2026-04-30
updated: 2026-04-30
status: draft
depends_on: [
  "specs/ARK_ZEIT_INTERACTIONS_v0_1.md (authoritative Routes/Sidebar/UI-source)",
  "specs/ARK_ZEIT_SCHEMA_v0_1.md (Schema-Refs)",
  "specs/ARK_ZEITERFASSUNG_PLAN_v0_1.md (Phase-Plan + Mockup-Realisierung §6.3)",
  "specs/ARK_DATABASE_SCHEMA_PATCH_v1_8_to_v1_9_zeit.md (Tabellen-Referenz)",
  "specs/ARK_STAMMDATEN_PATCH_v1_7_to_v1_8_zeit.md (UI-Label-Vocabulary)"
]
target: "Grundlagen MD/ARK_FRONTEND_FREEZE_v1_15.md → v1.16 (neuer Abschnitt §4j Operations · Zeit)"
tags: [frontend, patch, zeit, phase-3, routing, sidebar, drawer, rbac, scanner, dsg]
---

# ARK Frontend-Freeze · Patch v1.15 → v1.16 · Zeit-Modul

**Stand:** 2026-04-30
**Status:** Draft · ergänzend zu HR-Patch v1.14 → v1.15 (parallel)
**Quellen:**
- `Grundlagen MD/ARK_FRONTEND_FREEZE_v1_15.md` (Vorgänger · enthält bereits HR-Patch)
- `specs/ARK_ZEIT_INTERACTIONS_v0_1.md` §1 (Navigation/Routes) · §2 (Screen-Inventory) · §3 (Drawer) · §4 (Modals) · §6 (Rollen-Matrix) · §12 (Deltas v0.1 → v0.2)
- `specs/ARK_ZEIT_SCHEMA_v0_1.md` §3 (ENUMs für UI-Labels) · §6 (Views für Saldi/Charts)
- `specs/ARK_ZEITERFASSUNG_PLAN_v0_1.md` §6.3 (Mockup-Realisierung mit Realität-Marker 2026-04-30)

**Vorrang:** Stammdaten > Schema > Patch > Mockups

**Voraussetzungen:**
- DB-Patch v1.8 → v1.9 (P1) deployed
- Stammdaten-Patch v1.7 → v1.8 (P2) deployed
- Backend-Patch v2.5 → v2.6 (committed 2026-04-19) deployed

---

## 0. ZIELBILD

Dieser Patch ergänzt Frontend-Freeze v1.15 um einen vollständigen neuen Operations-Bereich „Zeit" (User-facing Sidebar-Label „**Zeiterfassung**"). Drei Bausteine:

1. **§4j Operations · Zeit** — neuer Top-Level-Abschnitt analog §4i Billing + §4h Performance: 10 Routen + 7-Eintrag-Sidebar-Tree + 5 UI-Patterns (Stempel-Quick-Action · Wochen-Approval-Pattern · Saldi-Visualisierung · Heatmap-Calendar · Scanner-Audit-Banner) + Drawer-Inventar.
2. **Drawer-Inventar (5 Drawer + 2 Modals)** — vollständige Liste der 540px-Slide-In-Drawer und 420px-Confirm-Modals (Drawer-Default-Regel).
3. **Permission-Matrix (4 Rollen × 10 Routen)** — Mitarbeiter / Head of / Backoffice / Admin je Route + spezifische Aktionen (DSG-Audit-Bypass).

---

## 1. Routenmodell-Ergänzung (§4j Operations · Zeit)

Ergänzung zu `ARK_FRONTEND_FREEZE_v1_15.md` §7 Routenmodell. Alle 10 Routen aus `ARK_ZEIT_INTERACTIONS_v0_1.md` §1 + §2 übernommen.

### 1.1 Top-Level-Routen (10)

| Route | Screen | Default-Tab | Zielgruppe | RLS-Hinweis |
|-------|--------|-------------|-----------|-------------|
| `/zeit` | Hub-Topbar (Hub-Page) | Dashboard | alle | — |
| `/zeit/dashboard` | Dashboard | Hero-KPIs · Wochen-Grid | alle | RLS auf eigene Daten |
| `/zeit/meine-zeit` | Meine Zeit (Wochen-Raster) | aktuelle KW | alle | RLS-Self |
| `/zeit/monat/:period` | Monats-Übersicht | aktueller Monat | alle | `:period` = `YYYY-MM` |
| `/zeit/abwesenheiten` | Team-Abwesenheiten | Monats-Kalender | alle | DSG-gefiltert: kein Cert-File im Grid |
| `/zeit/team` | Team-Approvals | 3 Tabs (Stempel-Anträge · Monats · Saldi) | Head of · Admin | nur Direct-Reports |
| `/zeit/saldi` | Saldi (4 Karten) | Ferien · OR-ÜZ · ArG-ÜZ · Extra | alle (self) · Head of+ (Team) | RLS-Self · Head of: Direct-Reports |
| `/zeit/export` | Treuhand-Export | aktueller Monat | Backoffice · Admin | Voraussetzung-Check |
| `/zeit/admin` | Zeit-Admin | 4 Tabs (Modelle · FT · 73b · Korrekturen) | Admin (+ BO für FT/Bridge-Day) | – |
| `/zeit/list` | Legacy-Liste (Phase-1 Fallback) | – | – | aus Sidebar entfernt, File bleibt auf Disk |

### 1.2 URL-State-Sync (Filter / Tabs)

```text
?week=2026-W16                            → Wochen-Picker auf Meine-Zeit
?period=2026-03                           → Monats-Picker auf Monat-Detail
?tab=stempel|monats|saldi                 → Team-Tab-Switch
?tab=modelle|ft|73b|korrekturen           → Admin-Tab-Switch
?absence_type=VACATION|SICK_PAID|…        → Abwesenheits-Filter (Multi)
?role_filter=ma|head|admin                → Team-Saldi-Filter (Admin only)
?from=YYYY-MM-DD&to=YYYY-MM-DD            → Datum-Range (Saldi-Detail)
?canton=ZH                                → Feiertage-Filter (Admin)
?drawer-tab=scanner|kategorien|audit      → Tages-Eintrag-Drawer-Tab
?korrektur_status=requested|tl_approved   → Admin-Korrekturen-Filter
```

**Browser-Back** funktioniert für alle Filter-Kombinationen. Tab-Wechsel im Drawer schreibt `?drawer-tab=…`.

### 1.3 Komponenten-Struktur (Next.js App Router)

```text
app/
  zeit/
    layout.tsx                       → Zeit-Header + Sidebar-Sub-Tree (Hub-Page)
    page.tsx                         → Redirect zu /zeit/dashboard
    dashboard/page.tsx               → Hero-KPIs + Wochen-Grid + Alerts
    meine-zeit/page.tsx              → Wochen-Raster + Wochen-Footer
    monat/
      [period]/page.tsx              → Monats-Übersicht + Submit-Modal
    abwesenheiten/page.tsx           → Monats-Kalender-Grid
    team/page.tsx                    → 3 Tabs (Stempel · Monats · Saldi)
    saldi/page.tsx                   → 4 Karten (Ferien · OR · ArG · Extra)
    export/page.tsx                  → Treuhand-Export-Generator
    admin/page.tsx                   → 4 Sub-Tabs (Modelle/FT/73b/Korrekturen)
```

**Mockup-Mapping** (alle 10 Mockups existieren in `mockups/ERP Tools/zeit/`):

```text
mockups/ERP Tools/zeit/
  zeit.html                ← Hub-Topbar (Sidebar-Tree „Zeiterfassung")
  zeit-dashboard.html      ← /zeit/dashboard
  zeit-meine-zeit.html     ← /zeit/meine-zeit
  zeit-monat.html          ← /zeit/monat/:period
  zeit-abwesenheiten.html  ← /zeit/abwesenheiten
  zeit-team.html           ← /zeit/team
  zeit-saldi.html          ← /zeit/saldi
  zeit-export.html         ← /zeit/export
  zeit-admin.html          ← /zeit/admin
  zeit-list.html           ← Legacy-Phase-1-Fallback (nicht aktiv)
```

**Mockup-Realisierungs-Status** (per Plan-Update §6.3 vom 2026-04-30):
- Cross-Modul-Funktionen integriert: Approvals → `zeit-team.html`, Time-Mandat-Billing → `billing/billing-rechnungen.html` (Domain-Owner Billing), Biometrie-Admin → `zeit-admin.html`
- Mobile-Responsive direkt in existierenden Mockups (kein separates `zeit-mobile.html`)

---

## 2. Sidebar-Tree „Zeiterfassung"

Ergänzung zu `ARK_FRONTEND_FREEZE_v1_15.md` §6 Sidebar-Gruppierung.

### 2.1 Sidebar-Eintrag (Top-Level)

```text
-- Bestehend (v1.15):
GRUPPE 4 – Operations:
  Email & Kalender │ Performance │ HR │ E-Learning │ Finanzen
  -- (Zeit war v1.13 schon als Phase-1-Stub vorhanden, wird hier Phase-3-fully-spec'd)

-- v1.16 unverändert (Zeit bleibt am gleichen Sidebar-Slot, Sub-Tree neu):
GRUPPE 4 – Operations:
  Email & Kalender │ Performance │ HR │ Zeit │ E-Learning │ Finanzen
```

### 2.2 Sub-Tree „Zeiterfassung" (Slide-Out-Sub-Menü, 7 Einträge)

UI-Label „**Zeiterfassung**" (statt Code „zeit"). Sidebar-Sub-Tree pro Rolle gefiltert.

```text
Zeiterfassung
├── Dashboard            → /zeit/dashboard               [alle]
├── Meine Zeit           → /zeit/meine-zeit              [alle]
├── Abwesenheiten        → /zeit/abwesenheiten           [alle]
├── Team-Approvals       → /zeit/team                    [Head of · Admin]
├── Saldi                → /zeit/saldi                   [alle]
├── Export               → /zeit/export                  [Backoffice · Admin]
└── Admin                → /zeit/admin                   [Admin]
```

### 2.3 Sidebar-Item-Konfiguration

```typescript
{
  label: 'Zeiterfassung',
  href: '/zeit',
  icon: 'Clock',
  group: 4,                           // Operations
  permission: ['ma', 'head', 'backoffice', 'admin'],
  activePattern: /^\/zeit/,
  badge: {
    source: 'GET /api/v1/zeit/badge-counts',
    fields: [
      'open_corrections',             // Admin-Korrekturen-Queue
      'pending_team_approvals',       // Head-Stempel + Monats
      'unsubmitted_periods',          // MA: noch nicht eingereichter Monat
      'cert_pending'                  // Arztzeugnis-Reminder fällig
    ],
    color: 'amber',
    polling_seconds: 60,
  },
  children: [/* 7 Sub-Items siehe §2.2 */]
}
```

**Permission-Verhalten:**
- **MA** sieht: Dashboard, Meine Zeit, Abwesenheiten, Saldi (4 Einträge).
- **Head of** sieht zusätzlich: Team-Approvals (5 Einträge).
- **Backoffice** sieht zusätzlich: Export (6 Einträge ohne Admin).
- **Admin** sieht alle 7 Einträge.

### 2.4 Sidebar-Footer Behaviour

User-Profile-Dropdown identisch zu `crm.html` (Mein Profil · Team-Übersicht · Keyboard-Shortcuts · Abmelden). Keine Zeit-spezifischen Footer-Items.

---

## 3. UI-Patterns (5)

Ergänzung zu `ARK_FRONTEND_FREEZE_v1_15.md` §4 Operations-UI-Patterns.

### 3.1 Stempel-Quick-Action (Sticky-Footer-Chip)

Pattern aus `ARK_ZEIT_INTERACTIONS_v0_1.md` §2.1 (Timer-Widget) · v0.2 §12.3 (Stempel-Antrag-Modell).

```text
┌─ Sticky-Footer-Chip ─────────────────┐
│ ⌚ Stempel-Antrag stellen            │
└──────────────────────────────────────┘
```

**Use-Case:** MA bemerkt fehlenden Scan · klickt Chip → öffnet Stempel-Antrag-Drawer mit Datum/Uhrzeit/Auto-Detect-Typ + Grund-Dropdown.

**Sichtbarkeit:**
- Nur auf `/zeit/meine-zeit`, `/zeit/monat/:period`, `/zeit/dashboard`
- Nicht für Roles `EXEMPT_EXEC` (vereinfachte Erfassung 73b)

### 3.2 Wochen-Approval-Pattern (Bulk-Approve)

Pattern aus `ARK_ZEIT_INTERACTIONS_v0_1.md` §2.5 (Tab 1 · Stempel-Anträge).

```text
┌─ Offene Stempel-Anträge (KW 16) ──── [Alle anhaken] [Approve markierte] ─┐
│ ☐ Peter Wiederkehr  18.04. 08:30  Home-Office       [Details] [Approve] │
│ ☐ Lisa Rüegg        17.04. 17:00  Vergessen         [Details] [Approve] │
│ ☐ Joaquin Vega      19.04. 12:30  Termin extern     [Details] [Approve] │
└──────────────────────────────────────────────────────────────────────────┘
```

- **Bulk-Action-Bar oben:** „Alle anhaken" + „Approve markierte" (mit Confirm-Modal bei ≥5 Anträgen)
- **Inline-Buttons:** Approve · Reject · Details (öffnet Drawer)
- **Filter-Chips:** alle Korrektur-Gründe aus `dim_time_correction_reason` (8 Codes · siehe Stammdaten-Patch §6)

### 3.3 Saldi-Visualisierung (4-Karten-Grid)

Pattern aus `ARK_ZEIT_INTERACTIONS_v0_1.md` §2.6.

```text
┌─ Ferien ────┐ ┌─ OR-Überstunden ┐ ┌─ ArG-Überzeit ─┐ ┌─ Extra-Guthaben─┐
│ 14 / 25 Tg  │ │ 0h (Lohn-abg.)  │ │ 8 / 170h       │ │ Joker 0/1       │
│ Verfällt    │ │ Info-Chip:      │ │ ⚠ 5%           │ │ ZEG-Q1 1/1      │
│ 20.04.27    │ │  „Lohn-abgegolt." │ │  Cap-Annähr.   │ │ GL-Extra 0/3    │
│ [Antrag]    │ │ kein Action-Btn │ │ [Kompens.]     │ │ [Beantragen]    │
└─────────────┘ └─────────────────┘ └────────────────┘ └─────────────────┘
```

- **Pflicht-Info-Chip** auf OR-Überstunden-Karte: „Lohn-abgegolten" (Arkadium-Vertragsklausel · keine Auszahlung/Kompensation · Memory `feedback_zeit_stempel_modell.md`)
- **ArG-Cap-Warning** ab 90% Jahres-Auslastung (153h/170h) · Color amber
- **Detail-Drawer pro Karte:** Timeline aller Buchungen + CSV-Export

### 3.4 Heatmap-Calendar Pattern (Team-Abwesenheiten)

Pattern aus `ARK_ZEIT_INTERACTIONS_v0_1.md` §2.4.

```text
            │1 │2 │3 │4 │5 │6 │7 │... 30│
 ───────────┼──┼──┼──┼──┼──┼──┼──┼───┼─┤
 Nenad (NB) │  │  │  │  │  │  │  │...│ │
 Peter (PW) │  │  │  │ ▓│ ▓│ ▓│ ▓│...│ │  ▓ Ferien
 Lisa (LR)  │  │  │  │  │  │  │  │...│ │  ▒ Krank
 Anna (AH)  │ M│  │  │  │  │  │  │...│ │  M Militär
            │  │  │  │  │  │  │  │   │ │  ★ Extra (Jokertag)
```

**DSG-Pflicht** (revDSG Art. 5 Ziff. 4):
- Im Grid sichtbar: nur Abwesenheits-Typ + Zeitraum
- **Nicht** sichtbar: Arztzeugnis-File · Krankheits-Detail · Reason-Text
- File-Access nur in Detail-Drawer für Berechtigte (eigene oder MA mit `direct_supervisor_id` = current_user)

**Rendering:** 2-Buchstaben-MA-Kürzel (PW/JV/LR · per Stammdaten-Wording-Regel · niemals Vollnamen).

### 3.5 Scanner-Access-Audit-Banner (DSG-Compliance)

Pattern für `/zeit/admin` Tab "Korrekturen" + `/zeit/team`.

```typescript
// Pre-Render Check
useEffect(() => {
  if (page === '/zeit/team' || page === '/zeit/admin/korrekturen') {
    fetch('/api/v1/zeit/scanner-audit/log', {
      method: 'POST',
      body: JSON.stringify({
        access_type: 'read_scans',
        target_user_id: focusedUserId,
        period_month: focusedPeriod,
        reason: 'team_approval' | 'correction_review',
      }),
    });
  }
}, [page, focusedUserId, focusedPeriod]);
```

- **Banner sichtbar in Admin-Korrekturen-Tab:** „DSG-Audit aktiv · Jeder Zugriff auf Scanner-Daten wird in `fact_scanner_access_audit` geloggt." (klein, sticky-top, dismissable nach Admin-Confirm pro Session)
- **Audit-Log-Sub-Tab** im Admin-Bereich (Tab "Audit") zeigt eigene + Team-Audit-Trail · Read-Only

---

## 4. Drawer-Inventar (5 Drawer + 2 Modals)

Per CLAUDE.md Drawer-Default-Regel — alle CRUD und Mehrschritt-Eingaben als 540px-Slide-In. Confirm-Schritte als 420px-Modal.

### 4.1 Drawer (5)

| Drawer-Slug | Titel | Trigger | Layout | Sektionen | Quelle |
|-------------|-------|---------|--------|-----------|--------|
| `drawer-tages-eintrag-edit` | Tages-Eintrag · DD.MM.YYYY | Klick Tages-Karte (Meine-Zeit) ODER Tag-Zeile (Monat) | 540px Read+Edit | 4 (Scanner-Events RO · Zusammenfassung · Audit-Trail · Korrektur-Action) | §3.1 |
| `drawer-urlaubs-antrag` | Neuer Urlaubsantrag | `[+ Antrag]` Abwesenheiten · `[Antrag stellen]` Saldi-Ferien | 540px Multi-Step | 4 Steps (Typ · Periode · Stellvertreter · Konfliktcheck) | §3.2 |
| `drawer-krank-meldung` | Krankmeldung einreichen | `[+ Antrag]` mit Typ=Krank | 540px CRUD | 3 Sektionen (Periode · Cert-Upload · Bemerkung) | §3.3 |
| `drawer-korrektur-antrag` | Korrektur beantragen · DD.MM.YYYY | `[Korrektur beantragen]` auf gesperrtem Tages-Eintrag | 540px Read+Edit | 3 Sektionen (Diff-Preview · Grund · Info-Box) | §3.4 |
| `drawer-extra-guthaben-antrag` | Extra-Guthaben beantragen | `[Extra beantr.]` in Saldi | 540px CRUD | 3 Sektionen (Typ-Pick · Datum · Sperrfristen-Check) | §3.5 |

### 4.2 Drawer-Standard-Properties

```typescript
interface ZeitDrawerProps {
  width: 540;
  origin: 'right';
  backdrop: 'opaque-30';
  closeBehavior: 'esc' | 'backdrop-click' | 'x';
  stickyHeader: true;                       // Title + Status-Badge
  stickyFooter: true;                       // Aktions-Buttons
  urlSync: '?drawer=…&drawer-tab=…';
  unsavedChangesGuard: true;
}
```

**Datum-Eingabe-Regel (CLAUDE.md):** Alle Datum-Felder (Von/Bis bei Urlaub, Datum bei Korrektur, Stempel-Zeit) als native `<input type="date">` / `<input type="time">` · Kalender-Picker UND Tastatur-Eingabe pflicht.

### 4.3 Modals (2 · 420px Confirm)

| Modal-Slug | Titel | Trigger | Inhalt | Quelle |
|------------|-------|---------|--------|--------|
| `modal-monat-einreichen` | Monat einreichen | `[Submit]` in Monats-Übersicht | Ist/Soll/Diff · Warnings-Liste · Hard-Block bei Pausen-Verletzung · Confirm-Checkbox | §4.1 |
| `modal-lock-override` | Monats-Lock aufheben | Admin `[Lock zurücksetzen]` in Korrekturen-Queue | Aktueller Status · Re-Export-Warnung · Pflicht-Grund · Audit-Confirm | §4.2 |

**Hard-Blocks bei `modal-monat-einreichen`** (Submit verhindert · keine Bypass-Möglichkeit MA):
- Pause < 60min bei Arbeitszeit > 9h (ArG 15)
- Pause < 30min bei Arbeitszeit > 7h (ArG 15)
- Ruhezeit < 11h zwischen Tagen → Soft-Warning (Policy-Konfigurierbar in `firm_settings`)

**Modal-Doppel-Confirm** bei `modal-lock-override`: zusätzliche Checkbox „Ich bestätige, dass dieser Override im Audit-Log erscheint und ein Re-Export an Treuhand Kunz nötig wird."

---

## 5. Permission-Matrix (4 Rollen × 10 Routen)

Übernommen aus `ARK_ZEIT_INTERACTIONS_v0_1.md` §6 Rollen-Matrix.

### 5.1 Rollen-Übersicht

| Rolle | Code | Routes | Edit | Special |
|-------|------|--------|------|---------|
| **Mitarbeiter (MA-Self)** | `MA` | 5 (Dashboard, Meine Zeit, Abwesenheiten, Saldi · own scope) | eigene Zeit (draft) · Anträge stellen | Stempel-Antrag · Korrektur-Antrag · Extra-Guthaben-Antrag |
| **Head of (HoD-Approver)** | `HEAD` | 6 (+ Team) | eigene + Team-Approvals · Direct-Reports-Scope | Wochen-Stempel-Approve · Monats-Approve · Team-Saldi-View |
| **Backoffice (BO-Billing)** | `BO` | 8 (+ Export) | alle ausser Lock-Override + Korrektur-nach-Lock | Treuhand-Export generieren · Bridge-Day editieren · MA-Vertrag (FT) |
| **Admin (HR-Admin)** | `ADMIN` | 10 (alle) | alle inkl. Lock-Override + Korrektur-nach-Lock + DSG-Audit-View | F13 Lock-Override · Arbeitszeit-Modell zuweisen · 73b-Vereinbarung pflegen |

### 5.2 Route-Permission-Matrix

| Route | MA | HEAD | BO | ADMIN |
|-------|----|------|----|-------|
| `/zeit/dashboard` | ✓ Self | ✓ Self+Team | ✓ Tenant | ✓ Tenant |
| `/zeit/meine-zeit` | ✓ Self | ✓ Self | ✓ Self | ✓ Self |
| `/zeit/monat/:period` | ✓ Self | ✓ Self+Team-Read | ✓ Tenant | ✓ Tenant |
| `/zeit/abwesenheiten` | ✓ Self+Tenant-Grid | ✓ + Approve normal | ✓ + Approve MAT/ADOPT/UNPAID | ✓ alle |
| `/zeit/team` | – | ✓ Direct-Reports | ✓ Tenant | ✓ Tenant |
| `/zeit/saldi` | ✓ Self | ✓ Self+Team | ✓ Self+Tenant | ✓ Tenant |
| `/zeit/export` | – | – | ✓ generate + send | ✓ generate (no send) |
| `/zeit/admin` (Modelle) | – | – | ✓ + Bridge-Day | ✓ alle Tabs |
| `/zeit/admin` (FT) | – | – | ✓ | ✓ |
| `/zeit/admin` (73b) | – | – | – | ✓ |
| `/zeit/admin` (Korrekturen) | – | ✓ vor Lock | – | ✓ nach Lock (F13) |

### 5.3 Aktion-Permission-Matrix (Top-12 kritische Aktionen)

| Aktion | MA | HEAD | BO | ADMIN |
|--------|----|------|----|-------|
| Eigene Zeit erfassen (Scanner/manuell) | ✓ | ✓ | ✓ | ✓ |
| Eigene Zeit editieren (draft) | ✓ | ✓ | ✓ | ✓ |
| Eigene Zeit editieren (submitted) | reopen-only | ✓ | ✗ | ✗ |
| Eigene Zeit editieren (locked) | Korrektur-Antrag | Korrektur-Antrag | ✗ | ✗ |
| Stempel-Antrag stellen | ✓ | ✓ | ✓ | ✓ |
| Stempel-Antrag approve | ✗ | ✓ Direct-Reports | ✓ Tenant | ✓ |
| Wochen-Approval (entfällt v0.2) | – | – | – | – |
| Monats-Approval (HEAD) | ✗ | ✓ | ✗ | ✗ |
| Monats-Approval (ADMIN) | ✗ | ✗ | ✓ | ✗ |
| Monats-Lock | ✗ | ✗ | ✓ | ✓ |
| Lock-Override (reopen) | ✗ | ✗ | ✗ | **✓ F13 only** |
| Treuhand-Export generieren | ✗ | ✗ | ✓ | ✓ |
| Treuhand-Export versenden | ✗ | ✗ | ✓ | ✗ |
| Korrektur-Approval vor Lock | ✗ | ✓ | ✓ | ✗ |
| Korrektur-Approval nach Lock | ✗ | ✗ | ✗ | **✓ F13 only** |
| Arbeitszeit-Modell zuweisen | ✗ | ✗ | ✓ | ✓ |
| Bridge-Day festlegen (F11) | ✗ | ✗ | ✓ | ✗ |
| 73b-Vereinbarung pflegen | ✗ | ✗ | – | ✓ |
| Scanner-Events sehen (eigene) | ✓ | ✓ Direct-Reports | ✓ | ✓ |
| Scanner-Access-Audit sehen | ✗ | ✗ | ✓ | ✓ |
| Arztzeugnis-File öffnen (own) | ✓ | own + reports | ✓ | ✗ encrypted-only |

**RLS-Hinweis:** Server-side Row-Level-Security auf `fact_time_entry`, `fact_absence`, `fact_time_scan_event` (siehe DB-Patch v1.9 §8). Frontend-Filter sind UI-Komfort, Backend prüft jede Anfrage.

---

## 6. Apply-Reihenfolge + Dependencies

### 6.1 Apply-Reihenfolge

1. **DB-Patch v1.8 → v1.9** (`specs/ARK_DATABASE_SCHEMA_PATCH_v1_8_to_v1_9_zeit.md`) — alle Tabellen + ENUMs + RLS
2. **Stammdaten-Patch v1.7 → v1.8** (`specs/ARK_STAMMDATEN_PATCH_v1_7_to_v1_8_zeit.md`) — 30 Absence-Types · 12 Categories · 5 Models · Vocabulary
3. **Backend-Patch v2.5 → v2.6** (committed 2026-04-19) — Scanner-Endpoints + Worker
4. **Frontend-Patch v1.15 → v1.16 (dieser Patch)** — §4j Operations · Zeit
5. **Gesamtsystem-Patch v1.6 → v1.7** (`specs/ARK_GESAMTSYSTEM_PATCH_v1_6_to_v1_7_zeit.md`) — Changelog

### 6.2 Dependencies-Check

| Voraussetzung | Quelle | Status |
|---------------|--------|--------|
| `dim_user.direct_supervisor_id` (HR-Patch) | HR-Patch v1.7 → v1.8 | parallel im Commit-Set |
| `fact_employment_contracts` (HR-Patch) | HR-Patch v1.7 → v1.8 | Pflicht für `fact_workday_target.employment_contract_id` FK |
| `fact_time_entry`-Tabelle | DB-Patch v1.9 | Pflicht für Meine-Zeit-Liste |
| `fact_absence`-Tabelle | DB-Patch v1.9 | Pflicht für Abwesenheiten-Grid |
| 30 Absence-Types seeded | Stammdaten-Patch v1.8 | Pflicht für Antrag-Drawer-Dropdown |
| Vocabulary-Mapping `mockup-baseline.md` §16 | Stammdaten-Patch v1.8 | Pflicht für UI-Status-Badges |
| Scanner-Endpoints `/api/zeit/scan` | Backend-Patch v2.6 | Pflicht für Scanner-Integration |
| Worker `scan-event-processor` | Backend-Patch v2.6 | Pflicht für nightly Aggregation |
| Outlook-Token-Pattern | Phase-1-A FE-Patch v1.14 | Pflicht für Treuhand-Export-Mail |

---

## 7. Sync-Impact

| Grundlagen-Datei | Änderung | Grund |
|------------------|----------|-------|
| `ARK_FRONTEND_FREEZE_v1_15.md` | **dieser Patch** → v1.16 | §4j Operations · Zeit (NEU) |
| `ARK_BACKEND_ARCHITECTURE_v2_6.md` | bereits v2.6 (committed 2026-04-19) | Endpoints-Ref |
| `ARK_DATABASE_SCHEMA_v1_8.md` → v1.9 | bereits via DB-Patch v1.9 (P1) | Tabellen-Ref |
| `ARK_STAMMDATEN_EXPORT_v1_7.md` → v1.8 | bereits via Stammdaten-Patch (P2) | Vocabulary-Ref |
| `ARK_GESAMTSYSTEM_UEBERSICHT_v1_6.md` → v1.7 | wird via P4 | Cross-Module-Integration + Changelog |
| `wiki/meta/spec-sync-regel.md` | Update | Sync-Matrix-Eintrag Zeit-Patches 5/5 |
| `wiki/meta/mockup-baseline.md` | Update §16 | UI-Label-Vocabulary aus Stammdaten-Patch §9 |

---

## 8. Kompatibilitäts-Notizen

### 8.1 Sidebar-Änderung (Gruppe 4)

Zeit-Eintrag bestand bereits in v1.13 als Phase-1-Stub (auf `zeit-list.html`). v1.16 ersetzt Stub durch Phase-3-Hub-Page mit 7-Eintrag-Sub-Tree. Kein Breaking-Change. Sidebar-Präferenz `localStorage` bleibt gültig. `zeit-list.html` als Fallback auf Disk, aber nicht mehr in Sidebar.

### 8.2 Drawer-Default-Regel

Alle 5 Zeit-Drawer halten 540px-Default. 2 Modals (`modal-monat-einreichen`, `modal-lock-override`) als 420px-Confirm bewusst pro CLAUDE.md Drawer-Default-Regel "Modale nur für kurze Confirms / Blocker". Audit-Log dokumentiert beide Confirm-Aktionen explizit.

### 8.3 Datum-Eingabe-Regel

Alle Datum-Felder (Urlaub Von/Bis · Korrektur Datum · Stempel Datum/Zeit) als native `<input type="date">` / `<input type="time">`. Kalender-Picker + Tastatur-Eingabe Pflicht (CLAUDE.md). Kein Click-only-Picker.

### 8.4 DSG-Compliance (Scanner-Daten)

Erste umfangreiche DSG-besondere-PD-Datenklasse im UI (revDSG Art. 5 Ziff. 4). Frontend-Pattern:
- Audit-Banner in Team/Admin-Routen
- Cert-Files niemals im Grid sichtbar (nur in Detail-Drawer mit Berechtigung)
- 2-Buchstaben-MA-Kürzel statt Vollnamen wo möglich (Stammdaten-Wording-Regel)
- Klick-Zugriff auf Scanner-Events triggert API-Call `/zeit/scanner-audit/log`

### 8.5 Stempel-Antrag-Modell (v0.2-Delta)

Manueller Zeit-Eintrag von Block-basiert (v0.1: Datum + Von/Bis + Pause + Kategorie + Projekt) auf Single-Event-basiert (v0.2: Datum + Uhrzeit + Auto-Detect-Typ + Grund-Dropdown) reduziert. Kategorien-Zuordnung aus Tages-Eintrag-Drawer entfernt — ZEG-Berechnung läuft via `v_time_per_mandate` auf Scanner-Aggregat-Basis (Memory `feedback_zeit_stempel_modell.md`).

### 8.6 Lohn-abgegolten-Policy (Arkadium-spezifisch)

Saldi-OR-Karte zeigt Info-Chip „Lohn-abgegolten" statt Action-Buttons (kein Zeitausgleich, keine Auszahlung — Vertragsklausel). `firm_settings.overtime_compensation_policy = 'paid_with_salary'`. Andere Tenants können `time_off` / `pay_25pct` / `hybrid` setzen (Policy-Variante in DB-Patch §10).

---

## 9. Acceptance Criteria

- [ ] §4j Operations · Zeit in `ARK_FRONTEND_FREEZE_v1_16.md` appendet
- [ ] Sidebar-Sub-Tree „Zeiterfassung" mit 7 Sub-Einträgen sichtbar (Permission-gefiltert pro Rolle)
- [ ] Alle 10 Top-Level-Routen `/zeit/*` erreichbar + URL-State-Sync funktional
- [ ] Browser-Back funktioniert für alle Filter-Kombinationen + Drawer-States
- [ ] Sticky-Footer-Stempel-Quick-Action sichtbar nur auf Dashboard/Meine-Zeit/Monat
- [ ] Wochen-Approval-Bulk-Action mit Confirm-Modal bei ≥5 Anträgen
- [ ] Saldi-OR-Karte zeigt „Lohn-abgegolten"-Info-Chip ohne Action-Buttons
- [ ] ArG-Cap-Warning ab 90% Jahres-Auslastung (153/170h) sichtbar in amber
- [ ] Heatmap-Calendar zeigt 2-Buchstaben-MA-Kürzel + Typ-Farbcodierung · keine Cert-Files im Grid
- [ ] Scanner-Audit-Banner sichtbar in `/zeit/team` + `/zeit/admin/korrekturen` · API-Call bei jedem Scanner-Daten-Read
- [ ] Alle 5 Drawer (`drawer-tages-eintrag-edit` … `drawer-extra-guthaben-antrag`) öffnen 540px slide-in von rechts
- [ ] `modal-monat-einreichen` blockiert Submit bei Pause-Hard-Verletzung
- [ ] `modal-lock-override` mit Doppel-Confirm + Audit-Log-Eintrag
- [ ] Datum-Eingaben überall native + Tastatur (CLAUDE.md Datum-Eingabe-Regel)
- [ ] Permission-Matrix korrekt: MA Self, HEAD Direct-Reports, BO Tenant, ADMIN F13-Override-Befugnis
- [ ] Stammdaten-Vocabulary aus `mockup-baseline.md` §16 in allen Status-Badges sichtbar (kein Enum-Code im UI)
- [ ] `zeit-list.html` aus Sidebar entfernt, File auf Disk als Fallback erhalten

---

## 10. Memory-Verweise

- `project_zeit_modul_architecture.md` — Scanner-First-Pattern · Role-Rename TL→HEAD/GF→ADMIN · Lohn-abgegolten-Policy
- `feedback_zeit_stempel_modell.md` — Stempel-Antrag mit 8 Grund-Codes · Single-Event-Modell (v0.2-Delta)
- `feedback_phase3_modules_separate.md` — ERP-Module separat von CRM, eigene Hub-Pages (zeit.html als Hub)
- `feedback_claude_design_no_app_bar.md` — Sub-Pages haben keine App-Bar (Hub-Topbar liefert das)
- `project_activity_linking.md` — UI-Felder linken auf `fact_history` · neue Zeit-Touchpoints-Activity-Types
- `reference_treuhand_kunz.md` — `office@treuhand-kunz.ch` · Bexio-CSV + Swissdec-ELM
- `project_arkadium_role.md` — Arkadium = Headhunting-Boutique · Rollen-Definition
- `feedback_worktree_sync_main.md` — Edits parallel nach `C:\Projects\Ark_CRM\` syncen

---

**Ende v1.16 · Zeit.** Apply-Reihenfolge: DB v1.9 → Stammdaten v1.8 → Backend v2.6 (bereits committed) → FE v1.16 (dieser Patch) → Gesamtsystem v1.7.
Mockup-Referenz: `mockups/ERP Tools/zeit/*.html` (10 Mockups · Phase-1 Realisierung 100% per Plan-Update §6.3).
