---
title: "ARK Frontend-Freeze · Patch v1.14 → v1.15 · HR-Modul"
type: patch
phase: 3
created: 2026-04-30
updated: 2026-04-30
status: draft · HR-Sync-Patch
depends_on: [
  "specs/ARK_HR_TOOL_INTERACTIONS_v0_1.md (authoritative Drawer/Routes/UI-Quelle)",
  "specs/ARK_HR_TOOL_SCHEMA_v0_2.md (Schema-Refs)",
  "specs/ARK_HR_TOOL_PLAN_v0_2.md (Phase-Plan + Rollen-Matrix)",
  "specs/ARK_DATABASE_SCHEMA_PATCH_v1_7_to_v1_8_hr.md (Tabellen-Referenz)",
  "specs/ARK_BACKEND_ARCHITECTURE_PATCH_v2_9_to_v2_10_hr.md (Endpoints)",
  "specs/ARK_STAMMDATEN_PATCH_v1_6_to_v1_7_hr.md (UI-Label-Vocabulary)"
]
target: "Grundlagen MD/ARK_FRONTEND_FREEZE_v1_14.md → v1.15 (neuer Abschnitt §4j Operations · HR-Tool)"
tags: [frontend, patch, hr, phase-3, routing, sidebar, drawer, rbac, onboarding, disciplinary, erp]
---

# ARK Frontend-Freeze · Patch v1.14 → v1.15 · HR-Modul

**Stand:** 2026-04-30
**Status:** Draft · HR-Sync-Patch
**Quellen:**
- `Grundlagen MD/ARK_FRONTEND_FREEZE_v1_14.md` (Vorgänger · §6 Sidebar-Gruppierung · §7 Routenmodell · §4 Operations)
- `specs/ARK_HR_TOOL_INTERACTIONS_v0_1.md` §1 (Seitenstruktur) · §2 (Drawer-Inventar) · §3 (Kern-Flows)
- `mockups/ERP Tools/hr/` — 8 HR-Mockup-Dateien (Routes-Extraktion)
- `specs/ARK_HR_TOOL_SCHEMA_v0_2.md` §12.6 (RLS-Rollen-Hierarchie)
- `specs/ARK_BACKEND_ARCHITECTURE_PATCH_v2_9_to_v2_10_hr.md` §4 (RBAC-Matrix)
- `specs/ARK_STAMMDATEN_PATCH_v1_6_to_v1_7_hr.md` §8 (UI-Label-Vocabulary)

**Vorrang:** Stammdaten > Schema > Patch > Mockups

**Voraussetzungen:**
- DB-Patch v1.8 (HR-Tabellen + RLS) deployed
- Backend-Patch v2.10 (HR-Endpoints + Events) deployed
- Stammdaten-Patch v1.7 (HR-UI-Labels) deployed
- FE-Patch v1.14 (Billing-Modul + Phase-1-A) deployed
- ERP-Hub-Topbar vorhanden (Module-Tabs inkl. HR-Tab-Slot)

---

## 0. ZIELBILD (was ändert dieser Patch)

Dieser Patch ergänzt Frontend-Freeze v1.14 um einen vollständigen neuen Operations-Bereich „HR-Tool" (User-facing Sidebar-Label „**Personal**"). Vier Bausteine:

1. **§4j Operations · HR-Tool** — neuer Top-Level-Abschnitt analog §4i Billing: 10 Top-Level-Routen + 7-Eintrag-Sidebar-Tree + 6 UI-Patterns + Drawer-Inventar (11 Drawer)
2. **Sidebar-Sektion** — neues Sidebar-Segment „Personal" mit Sub-Items (analog Billing-Sidebar-Pattern)
3. **Drawer-Inventar (11 Drawer)** — vollständige Liste der 540px-Slide-In-Drawer aus `_INTERACTIONS_v0_1.md` §2 + heute aktualisierte Mockups (commits 9e233df + d8a5972)
4. **Permission-Matrix (4 Rollen · 10 Routen)** — HR-Admin · HoD · MA-Self · BO

---

## 1. Routenmodell-Ergänzung (§4j Operations · HR-Tool)

Ergänzung zu `ARK_FRONTEND_FREEZE_v1_14.md` §7 Routenmodell. Alle 10 Top-Level-Routen aus `mockups/ERP Tools/hr/`-Dateistruktur + `_INTERACTIONS_v0_1.md` §1.

### 1.1 Top-Level-Routen (10)

| Route | Mockup-Datei | Screen | Default-Ansicht | Zielgruppe |
|-------|-------------|--------|-----------------|-----------|
| `/erp/hr` | `hr.html` | HR Hub | Dashboard-Redirect | Admin · HoD · BO |
| `/erp/hr/dashboard` | `hr-dashboard.html` | HR-Dashboard | KPIs + Alerts | Admin · HoD · BO |
| `/erp/hr/list` | `hr-list.html` | Mitarbeiterliste | Alle aktiven MA | Admin · HoD |
| `/erp/hr/list/:user_id` | `hr-list.html` (Drawer-Flow) | MA-Detail-Drawer | Vertrag-Tab | Admin · HoD |
| `/erp/hr/self` | `hr-mitarbeiter-self.html` | Self-Service | Eigenes Profil + Dokumente | MA-Self |
| `/erp/hr/disciplinary` | `hr-warnings-disciplinary.html` | Verwarnungen & Disziplinar | Offene Einträge | Admin · HoD |
| `/erp/hr/disciplinary/:record_id` | `hr-warnings-disciplinary.html` (Drawer-Flow) | Disziplinar-Eintrag-Drawer | Detail-Tab | Admin · HoD |
| `/erp/hr/onboarding` | `hr-onboarding-editor.html` | Onboarding-Editor | Aktive Onboardings | Admin · HoD |
| `/erp/hr/provisions` | `hr-provisionsvertrag-editor.html` | Provisionsvertrag-Editor | Praemium-Victoria-Konfiguration | Admin |
| `/erp/hr/academy` | `hr-academy-dashboard.html` | Academy-Dashboard | E-Learning-Auswertung | Admin · HoD · BO |

> **Archiviert (nicht HR-Tool-eigene Routes):**
> - `hr-absence-calendar.html` → Zeit-Modul-Route `/erp/zeit/calendar` (nicht mehr in HR-Sidebar)
> - HR zeigt nur Summary-KPIs für Absenzen via Zeit-API

### 1.2 URL-State-Sync (Filter / Tabs)

```text
?contract_state=draft|pending_sig|active|terminated|expired
?employment_type=permanent|fixed_term|intern|freelance
?in_probation=true
?overdue_only=true
?disciplinary_state=draft|issued|acknowledged|disputed|resolved
?disciplinary_level=verbal_warning|written_warning|formal_warning|final_warning|suspension|dismissal_immediate
?onboarding_state=active|overdue|completed|cancelled
?role_code=MA|HEAD|ADMIN|BO
?sparte=ARC|GT|ING|PUR|REM
?q=<Suche>
?user_id=<uuid>                       → MA-Auswahl-Filter
?drawer=contract|document|disciplinary|onboarding|probation  → Drawer-öffnen via URL
?drawer-tab=detail|verlauf|dokumente|aufgaben  → Drawer-interne Tab-State
?period=7d|30d|quarter|ytd            → Dashboard-Zeitraum
```

**Browser-Back** funktioniert für alle Filter-Kombinationen. Drawer-State via `?drawer=...`-Param.

### 1.3 Komponenten-Struktur (Next.js App Router)

```text
app/
  erp/
    hr/
      layout.tsx                    → HR-Hub-Header + Tabbar (Routen 1.1) + KPI-Stat-Strip
      page.tsx                      → Redirect → /erp/hr/dashboard
      dashboard/
        page.tsx                    → hr-dashboard.html
      list/
        page.tsx                    → hr-list.html
        [user_id]/
          page.tsx                  → MA-Detail-Drawer-Flow
      self/
        page.tsx                    → hr-mitarbeiter-self.html (MA-Self-Route, RLS-geschützt)
      disciplinary/
        page.tsx                    → hr-warnings-disciplinary.html
        [record_id]/
          page.tsx                  → Disciplinary-Drawer-Flow
      onboarding/
        page.tsx                    → hr-onboarding-editor.html
      provisions/
        page.tsx                    → hr-provisionsvertrag-editor.html (Admin-only)
      academy/
        page.tsx                    → hr-academy-dashboard.html
```

**Mockup-Mapping (alle Phase-1-Mockups existieren):**

```text
mockups/ERP Tools/hr/
  hr.html                           ← Hub (Sidebar-Tree, Tab-Router)
  hr-dashboard.html                 ← /erp/hr/dashboard
  hr-list.html                      ← /erp/hr/list
  hr-mitarbeiter-self.html          ← /erp/hr/self
  hr-warnings-disciplinary.html     ← /erp/hr/disciplinary
  hr-onboarding-editor.html         ← /erp/hr/onboarding
  hr-provisionsvertrag-editor.html  ← /erp/hr/provisions
  hr-academy-dashboard.html         ← /erp/hr/academy
```

---

## 2. Sidebar-Sektion „Personal"

Ergänzung zu `ARK_FRONTEND_FREEZE_v1_14.md` §6 Sidebar-Gruppierung. Neue ERP-Sidebar-Sektion analog „Finanzen" (Billing-Patch v1.14).

### 2.1 Sidebar-Tree

```
Personal                              ← Sektion-Header (collapsed-by-default auf Mobile)
├── Dashboard                         → /erp/hr/dashboard
├── Mitarbeiter                       → /erp/hr/list
├── Mein Profil                       → /erp/hr/self        (nur für MA-Self, versteckt für Admin-Only-User)
├── Verwarnungen                      → /erp/hr/disciplinary
├── Onboarding                        → /erp/hr/onboarding
├── Provisionsvertrag                 → /erp/hr/provisions   (nur Admin)
└── Academy                           → /erp/hr/academy
```

**Badge-Logik (analog Billing-Sidebar):**

| Sidebar-Item | Badge-Quelle | Badge-Farbe |
|-------------|-------------|------------|
| Dashboard | offene Alerts total | red (wenn > 0) |
| Mitarbeiter | MA in Probezeit mit Ablauf ≤ 7 Tage | amber |
| Verwarnungen | offene Disputed-Einträge | red |
| Onboarding | überfällige Onboarding-Tasks | red |

### 2.2 ERP-Topbar Integration

Das HR-Modul erscheint als Tab in der ERP-Topbar (Memory `feedback_claude_design_no_app_bar.md`):

```
ERP-Topbar: [CRM] [Personal] [Zeit] [Billing] [Performance] [Publishing]
                    ^
                  aktiv bei /erp/hr/*
```

**Kein App-Bar** im HR-Modul selbst — Topbar liefert Brand + Module-Tabs + User-Pill + Theme-Toggle.

---

## 3. UI-Patterns (§4j)

### 3.1 Compliance-Matrix-Pattern (hr-warnings-disciplinary.html)

```
Compliance-Matrix: tabellarische Übersicht aller MA × Compliance-Dimensionen
- Spalten: MA-Kürzel | Pensum | Verwarnungen (Level-Badge) | Offene Unterschriften | Probezeit-Status
- Row-Farben: grün (compliant) · amber (pending_sig > 5d, Probezeit ≤ 14d) · rot (disputed, overdue)
- Click auf Row → MA-Detail-Drawer (drawer-contract-view)
- Kein DB-Techname in Tabellen-Headers (Keine-DB-Techdetails-Regel)
```

### 3.2 Drawer-Default-Pattern (Drawer-Default-Regel)

**Pflicht:** Alle CRUD-Operationen, Bestätigungen und Mehrschritt-Eingaben als 540px Slide-In-Drawer. Modal-Dialoge nur für kurze Bestätigungen (z.B. „Dokument wirklich widerrufen?").

```
Drawer-Trigger → 540px Slide-In-Drawer (rechts)
  └── Tabs intern (wenn > 1 Informationsebene): Detail · Verlauf · Dokumente · Aufgaben
```

### 3.3 Probezeit-Alert-Banner

```
Dashboard-Alert-Bereich: sticky unter KPI-Bar
- Amber-Banner: „X Probezeiten laufen in ≤ 14 Tagen ab" → Klick → hr-list mit ?in_probation=true
- Red-Banner: „Y überfällige Onboarding-Tasks" → Klick → /erp/hr/onboarding?overdue_only=true
- Red-Banner: „Z offene Verwarnungen (Bestritten)" → Klick → /erp/hr/disciplinary?disciplinary_state=disputed
```

### 3.4 Theme-Toggle

HR-Modul unterstützt Dark/Light-Mode analog allen anderen ERP-Modulen. Toggle in ERP-Topbar (nicht im HR-Hub selbst).

### 3.5 MA-Kürzel-Anzeige-Regel

**Stammdaten-Regel:** Mitarbeiter werden stets mit 2-Buchstaben-Kürzel dargestellt (PW / JV / LR etc.), niemals Vollname in Tabellen oder Badge-Labels. Vollname nur in Drawer-Headers und Dokument-Generierung.

### 3.6 Datum-Eingabe-Regel (Pflicht)

Alle Datum-/Zeit-Eingaben in HR-Drawers (Eintrittsdatum, Kündigung, Probezeit-Ende, Incident-Date) müssen **Kalender-Picker UND manuelle Tastatur-Eingabe** unterstützen (natives `<input type="date">`). Keine reinen Click-only-Picker.

---

## 4. Drawer-Inventar (11 Drawer)

Ergänzung zu `ARK_FRONTEND_FREEZE_v1_14.md` §5 Drawer-Inventar. Alle 11 HR-Drawer folgen dem 540px-Slide-In-Rechts-Standard (Drawer-Default-Regel).

### 4.1 Stammdaten-Bereich (4 Drawer)

| Drawer-ID | Trigger-Element | Breite | Tabs | Schema-Entität |
|-----------|-----------------|--------|------|----------------|
| `drawer-contract-new` | Button „+ Vertrag erfassen" (hr-list.html) | 540px | — | `fact_employment_contracts` |
| `drawer-contract-view` | Click auf MA-Row → Vertrags-Icon | 540px | Detail · Verlauf · Dokumente | `fact_employment_contracts` |
| `drawer-contract-terminate` | Button „Kündigung erfassen" (drawer-contract-view) | 540px | — | `fact_employment_contracts` |
| `drawer-document-sign` | Button „Dokument anfordern" (hr-list.html In-Row) | 540px | — | `fact_employment_attachments` |

**`drawer-contract-new` Felder:**
- Name (Autocomplete auf dim_user unassigned) — Pflicht
- Rolle (Dropdown: AM / CM / RA / BO / HEAD / ADMIN) — Pflicht
- Anstellungsart (Dropdown: Unbefristet / Befristet / Praktikum / Freie Mitarbeit) — Pflicht
- Eintrittsdatum (input type="date", Kalender + Tastatur) — Pflicht
- Probezeit in Monaten (0–3, default 3) — Pflicht
- Monatslohn CHF (Zahl, NULL für Freelance) — optional
- Provisions-berechtigt (Toggle, default AUS) — optional
- Onboarding automatisch starten? (Checkbox, default AN) — optional

**`drawer-contract-view` Tabs:**
- **Detail:** Vertragstyp, Laufzeit, Lohn, Probezeit-Status, Kündigung
- **Verlauf:** audit_trail_jsonb aus `/api/v1/hr/contracts/:id/timeline`
- **Dokumente:** Dokument-Liste + Signatur-Status (aus `v_pending_signatures`)

### 4.2 Disziplinar-Bereich (3 Drawer)

| Drawer-ID | Trigger-Element | Breite | Tabs | Schema-Entität |
|-----------|-----------------|--------|------|----------------|
| `drawer-disciplinary-new` | Button „+ Verwarnung erfassen" (hr-warnings-disciplinary.html) | 540px | — | `fact_disciplinary_records` |
| `drawer-disciplinary-view` | Click auf Eintrag in Tabelle | 540px | Detail · Verlauf · Eskalation | `fact_disciplinary_records` |
| `drawer-disciplinary-acknowledge` | Button „Kenntnisnahme erfassen" (MA-Self-Ansicht) | 540px | — | `fact_disciplinary_records` |

**`drawer-disciplinary-new` Felder:**
- Mitarbeiter (Autocomplete, MA-Kürzel) — Pflicht
- Delikt-Typ (Dropdown aus `dim_disciplinary_offense_type`) — Pflicht
- Datum des Vorfalls (input type="date") — Pflicht
- Eskalations-Level (Dropdown, vorausgefüllt mit `typical_level` des Delikts) — Pflicht
- Beschreibung (Textarea, min 20 Zeichen) — Pflicht
- Datei-Upload (PDF der Verwarnung) — optional
- Vorgeschlagene nächste Stufe (Read-Only, berechnet vom API via DB-Trigger) — angezeigt nach Submit

**`drawer-disciplinary-view` Tabs:**
- **Detail:** Delikt, Level, Status, Sachverhalt, Zustellungsdatum
- **Verlauf:** Eskalations-Chain (via `previous_record_id`)
- **Eskalation:** nächste mögliche Massnahme + Aktions-Buttons (Admin: Freigeben / HoD: Erstellen)

**`drawer-disciplinary-acknowledge` Felder:**
- Stellungnahme (Textarea) — optional
- Datum der Kenntnisnahme (auto: TODAY) — Read-Only
- Submit-Button: „Zur Kenntnis genommen"

### 4.3 Onboarding-Bereich (4 Drawer)

| Drawer-ID | Trigger-Element | Breite | Tabs | Schema-Entität |
|-----------|-----------------|--------|------|----------------|
| `drawer-onboarding-start` | Button „Onboarding starten" (hr-onboarding-editor.html) | 540px | — | `fact_onboarding_instances` |
| `drawer-onboarding-task-edit` | Click auf Task-Row in Onboarding-Instanz | 540px | — | `fact_onboarding_instance_tasks` |
| `drawer-onboarding-template-edit` | Button „Template bearbeiten" (hr-onboarding-editor.html) | 540px | Aufgaben · Einstellungen | `fact_onboarding_templates` |
| `drawer-probation-complete` | Button „Probezeit abschliessen" (HEAD-only, nur wenn probation_end ≥ TODAY - 7d) | 540px | — | `fact_probation_milestones` |

**`drawer-onboarding-start` Felder:**
- Mitarbeiter (Autocomplete, vorausgefüllt wenn aus drawer-contract-new Auto-Flow) — Pflicht
- Template (Dropdown mit Rollen-Default-Vorauswahl) — Pflicht
- Eintrittsdatum (vorausgefüllt aus contract_start) — Pflicht, editierbar
- Probezeit-Ziel (auto: entry_date + 90 Tage) — Read-Only

**`drawer-probation-complete` Felder:**
- Bestanden? (Toggle: Ja / Nein) — Pflicht
- Gesprächsnotiz (Textarea) — Pflicht
- Dokument-Upload (PDF-Protokoll) — optional
- Submit-Button:
  - Bei Ja → `onboarding_state = 'completed'` + Commission-Eligibility-Check
  - Bei Nein → `onboarding_state = 'cancelled'` + Empfehlung drawer-contract-terminate öffnen

---

## 5. Permission-Matrix (4 Rollen · 10 Routen)

| Route | HR-Admin (GF/HR-Mgr) | HoD | MA-Self | BO |
|-------|:-------------------:|:---:|:-------:|:--:|
| `/erp/hr/dashboard` | ✓ Vollzugriff | ✓ Team-gefiltert | ✗ | ✓ Read-Only |
| `/erp/hr/list` | ✓ Alle MA | ✓ Eigenes Team | ✗ | ✓ Read-Only |
| `/erp/hr/list/:user_id` | ✓ | ✓ Team | ✗ | ✗ |
| `/erp/hr/self` | ✗ (Admin hat eigene Ansicht im /list) | ✗ | ✓ Nur eigenes Profil | ✗ |
| `/erp/hr/disciplinary` | ✓ Alle | ✓ Team | ✗ | ✗ |
| `/erp/hr/disciplinary/:record_id` | ✓ | ✓ Team | ✓ Nur issued/ack/disp | ✗ |
| `/erp/hr/onboarding` | ✓ Alle | ✓ Team | ✗ | ✓ Read-Only |
| `/erp/hr/provisions` | ✓ | ✗ | ✗ | ✗ |
| `/erp/hr/academy` | ✓ | ✓ Team-gefiltert | ✗ | ✓ Read-Only |
| `/erp/hr` (Hub-Redirect) | ✓ → dashboard | ✓ → dashboard | ✓ → self | ✓ → dashboard |

**Drawer-Aktionen Kurzmatrix:**

| Drawer | Admin | HoD | MA-Self |
|--------|:-----:|:---:|:-------:|
| drawer-contract-new | ✓ | ✗ | ✗ |
| drawer-contract-view | ✓ | ✓ Team | ✓ Eigener (Read-Only) |
| drawer-contract-terminate | ✓ | ✗ | ✗ |
| drawer-document-sign (admin-sig) | ✓ | ✗ | ✗ |
| drawer-document-sign (ma-sig) | ✗ | ✗ | ✓ |
| drawer-disciplinary-new | ✓ | ✓ Team | ✗ |
| drawer-disciplinary-view | ✓ | ✓ Team | ✓ Eigene issued/ack/disp |
| drawer-disciplinary-acknowledge | ✗ | ✗ | ✓ |
| drawer-onboarding-start | ✓ | ✗ | ✗ |
| drawer-onboarding-task-edit | ✓ | ✓ Team | ✓ Zugewiesene Tasks |
| drawer-onboarding-template-edit | ✓ | ✗ | ✗ |
| drawer-probation-complete | ✓ | ✓ Team | ✗ |

**Redirect-Logik bei fehlender Berechtigung:**

```text
Unauthorisierte Route → /erp/hr/self (wenn MA-Self-Rolle)
                     → /erp (ERP-Hub) mit Toast "Kein Zugriff"
```

---

## 6. Änderungen an bestehenden Sections (v1.14 → v1.15)

### 6.1 §7 Routenmodell — neue Zeilen

Ergänzung der bestehenden Route-Tabelle in v1.14:

```
/erp/hr                    → HR-Hub
/erp/hr/dashboard          → HR-Dashboard
/erp/hr/list               → Mitarbeiterliste
/erp/hr/list/:user_id      → MA-Detail-Drawer-Flow
/erp/hr/self               → Self-Service (MA-Rolle)
/erp/hr/disciplinary       → Verwarnungen & Disziplinar
/erp/hr/disciplinary/:id   → Disciplinary-Drawer-Flow
/erp/hr/onboarding         → Onboarding-Editor
/erp/hr/provisions         → Provisionsvertrag-Editor (Admin-only)
/erp/hr/academy            → Academy-Dashboard
```

### 6.2 §6 Sidebar-Gruppierung — neue Sektion

Ergänzung nach Sektion „Finanzen" (Billing):

```
Personal
  Dashboard
  Mitarbeiter
  Mein Profil      (nur MA-Rolle)
  Verwarnungen
  Onboarding
  Provisionsvertrag (nur Admin)
  Academy
```

### 6.3 §5 Drawer-Inventar — neue Einträge

11 neue Drawer-Einträge (§4 dieses Patches) in die bestehende Drawer-Inventar-Tabelle von v1.14 eintragen.

---

## 7. SYNC-IMPACT

| Grundlagen-Datei | Änderung |
|------------------|----------|
| `ARK_DATABASE_SCHEMA_v1_7.md` | HR-Tabellen → DB-Patch v1.8 (bereits geschrieben) |
| `ARK_BACKEND_ARCHITECTURE_v2_9.md` | HR-Endpoints → Backend-Patch v2.10 (bereits geschrieben) |
| `ARK_STAMMDATEN_EXPORT_v1_6.md` | HR-Stammdaten → Stammdaten-Patch v1.7 (bereits geschrieben) |
| `ARK_GESAMTSYSTEM_UEBERSICHT_v1_5.md` | Changelog-Eintrag „HR-Modul FE v1.15" (Folge-Patch Gesamtsystem v1.6 → v1.7, separat) |
| `wiki/meta/mockup-baseline.md` | §16 HR-UI-Labels bereits in Stammdaten-Patch v1.7 §8 |

---

**Ende v1.15.** Apply-Reihenfolge: DB-Patch v1.8 → Backend-Patch v2.10 → Stammdaten-Patch v1.7 → FE-Patch v1.15.
Gesamtsystem-Patch v1.6 → v1.7 (Changelog-Aggregation aller 4 Patches) separat.
