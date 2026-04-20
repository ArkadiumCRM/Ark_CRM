---
title: "ARK Zeit-Modul · Interactions v0.1"
type: spec
module: zeit
version: 0.1
created: 2026-04-19
updated: 2026-04-19
status: draft
sources: [
  "specs/ARK_ZEIT_SCHEMA_v0_1.md",
  "wiki/sources/hr-reglemente.md",
  "wiki/meta/zeit-decisions-2026-04-19.md",
  "wiki/sources/phase3-research/zeit/zeit-research-overview.md"
]
tags: [spec, interactions, ui, flows, zeit, scanner, drawer, dsg]
---

# ARK Zeit-Modul · UI + Interactions v0.1

**Scope:** UI-Architektur (Screens/Drawer/Modals) · State-Machines · Rollen-Matrix · Scanner-Flow · Validation-Regeln · Navigation.

**Design-Grundlagen:** 540px-Drawer-Default · 420px-Modal nur für irreversible Confirms · Editorial-Serif (Libre Baskerville Headlines · DM Sans Body) · Sidebar 56/240px · Farb-Tokens aus editorial.css.

**Schema-Referenz:** [ARK_ZEIT_SCHEMA_v0_1.md](ARK_ZEIT_SCHEMA_v0_1.md)

---

## 1. Navigation

Sidebar-Module im `zeit.html`-Shell (56/240px Hover-Expand, Pin-Toggle, `ark-sidebar-pinned` localStorage).

| Modul | Icon | Route | Rollen |
|-------|------|-------|--------|
| Dashboard | ⊡ | `/zeit/dashboard` | alle |
| Meine Zeit | ⌚ | `/zeit/meine-zeit` | alle |
| Abwesenheiten | ⊠ | `/zeit/abwesenheiten` | alle |
| Team | ⌹ | `/zeit/team` | Head of/Admin |
| Saldi | ⊘ | `/zeit/saldi` | alle (self) · Head of+ (Team) |
| Export | ⇱ | `/zeit/export` | Backoffice/Admin |
| Admin | ⚙ | `/zeit/admin` | Admin |

Sidebar-Footer: User-Profile-Dropdown identisch zu `crm.html` (Mein Profil · Team-Übersicht · Keyboard-Shortcuts · Abmelden).

---

## 2. Screen-Inventory

### 2.1 Dashboard (`/zeit/dashboard`)

**Zweck:** Hero-Überblick · Tages-/Wochen-Saldo · Timer-Widget (bei Scanner-freien Arbeitsplätzen) · Ferien-Rest · Team-Abwesenheiten heute.

**Layout:**

```
┌─ Hero-KPIs (4 Cards) ───────────────────────────────────────────────┐
│ Wochen-Saldo       │ Monats-Ist/Soll   │ Ferien-Rest     │ ArG-Überzeit │
│ +2h 15min          │ 142 / 180h        │ 12 von 25       │ 8 / 170h   │
│ (grün delta-chip)  │ Progress-Ring     │ (planend: 2)    │ (Warning)  │
└────────────────────────────────────────────────────────────────────┘

┌─ Meine-Woche-Grid (Mo-So) ─────────────────┐ ┌─ Nächste Events ────────┐
│ Mo 19.04  08:47-12:00 · 13:30-17:45 │ 8h  │ │ • 27.04. Max: Ferien    │
│ Di 20.04  08:45-12:00 · 13:30-17:45 │ 8h  │ │ • 01.05. Tag der Arbeit │
│ Mi 21.04  ...                       │ 8h  │ │ • 04.05. Monatslock     │
│ Do 22.04  ...                       │ 8h  │ │   (letzter Tag Submit)  │
│ Fr 23.04  08:45-16:00 + 2.5h Team   │ 9h  │ └─────────────────────────┘
│ Sa/So     –                         │ 0h  │
│ ────────── Total: 41h · Soll: 45h ──┘     │
└────────────────────────────────────────────┘

┌─ Alerts + Team-Abwesenheiten heute ────────────────────────────────┐
│ 🟠 Arztzeugnis fehlt: Krankmeldung 18.04 (Anna) · ab heute fällig │
│ 🟢 3 Team-Mitglieder abwesend: PW (Ferien), LR (Krank), JV (Militär) │
└────────────────────────────────────────────────────────────────────┘
```

**Interaktionen:**
- Klick Hero-KPI → Drill-Down-Drawer mit Detail (z.B. Wochen-Saldo → Liste der Tages-Einträge dieser Woche)
- Klick Woche-Grid-Tag → Drawer "Tages-Eintrag-Edit"
- Klick Alert → Drawer je nach Typ (Arztzeugnis-Upload-Drawer)

**Timer-Widget** (nur wenn MA nicht Scanner-basiert — z.B. Home-Office oder Remote):
- Sticky-Footer-Chip rechts unten
- Idle / Running / Paused States
- Klick "Start" öffnet Projekt-/Kategorie-Quickpick

### 2.2 Meine Zeit (`/zeit/meine-zeit`)

**Zweck:** Wochen-Raster mit inline-Edit für Tages-Einträge · Scanner-Daten automatisch geladen · manuelle Nachträge möglich.

**Layout:**

Wochen-Raster (7 Tages-Karten horizontal):

```
┌─ Woche 16 · 20.04-26.04.2026 ─── [Gestern kopieren] [Neu +] ────────┐
│                                                                     │
│ Mo 20.04         Di 21.04         Mi 22.04         Do 23.04         │
│ ─────────        ─────────        ─────────        ─────────        │
│ 08:47 Check-In   08:45 Check-In   08:45 Check-In   08:44 Check-In   │
│ 12:00 Break-Out  12:00 Break-Out  ...              ...              │
│ 13:30 Check-In                                                      │
│ 17:45 Check-Out                                                     │
│ ─────────                                                           │
│ Ist: 08:28 (8h 28min) · davon gezählt: 08:00                        │
│ Soll: 09:00 · Diff: -32min                                          │
│ Kategorie: PROD_BILL 6h · ADMIN 2h                                  │
│ Projekt: Implenia-Senior-Eng · Arcoba-Planer                        │
│ Status: submitted ✓                                                 │
│ [Edit] [Kategorien zuordnen]                                        │
└─────────────────────────────────────────────────────────────────────┘

┌─ Wochen-Footer ────────────────────────────────────────────────────┐
│ Total Ist:  41h 12min (gezählt: 40h 00min · nicht-angerechnet: 1h 12min) │
│ Soll:       45h 00min                                              │
│ Diff:       -4h 48min                                              │
│ ArG-Überzeit: 0h  · OR-Überstunden: 0h  · Jahres-Überzeit: 8/170h  │
│                                                                    │
│ [Monat einreichen] (disabled bis Monat vorbei + keine Errors)      │
└────────────────────────────────────────────────────────────────────┘
```

**Interaktionen:**
- Klick Tages-Karte → Drawer "Tages-Eintrag-Edit" (540px)
- `[Gestern kopieren]` → dupliziert Kategorien-/Projekt-Zuordnung vom Vortag (nicht Scanner-Zeiten)
- `[Neu +]` → Drawer "Neuer Zeiteintrag manuell"
- Kalender-Nav: ← / → / Heute / Monat-Picker

### 2.3 Monats-Übersicht (`/zeit/monat/:period`)

**Zweck:** Vor Monats-Submit prüfen · Tabelle Tag/Soll/Ist/Diff/Warnings/Status · Approval-Chain.

**Layout:**

```
┌─ März 2026 · Monats-Übersicht ─── [Submit] [Export CSV] ─────────────┐
│ ┌────┬────┬──────┬──────┬─────┬──────┬────────┬──────┬──────────┐ │
│ │Tag │WoT │Soll  │Ist   │Diff │Kat   │Pausen  │Ruhe  │Status    │ │
│ ├────┼────┼──────┼──────┼─────┼──────┼────────┼──────┼──────────┤ │
│ │01  │So  │  –   │  –   │ –   │  –   │   –    │  ✓   │  –       │ │
│ │02  │Mo  │ 9:00 │ 8:45 │-15  │PROD  │   ✓    │  ✓   │approved ✓│ │
│ │03  │Di  │ 9:00 │ 9:15 │+15  │PROD  │   ✓    │  ✓   │approved ✓│ │
│ │04  │Mi  │ 9:00 │10:30 │+90  │PROD  │  🟠    │  ✓   │submitted │ │
│ │    │    │      │      │     │      │ (28m)  │      │          │ │
│ │05  │Do  │ 9:00 │ 0:00 │-540 │VAC   │   –    │  ✓   │absence   │ │
│ │06  │Fr  │ 9:00 │ 8:30 │-30  │PROD+ │   ✓    │  ✓   │submitted │ │
│ │    │    │      │      │     │TEAM  │        │      │          │ │
│ │... │    │      │      │     │      │        │      │          │ │
│ └────┴────┴──────┴──────┴─────┴──────┴────────┴──────┴──────────┘ │
│                                                                    │
│ Monats-Total: 175h 45min / Soll 180h · Diff -4h 15min              │
│ ArG-Überzeit: 0h · OR-Überstunden: 0h                              │
│ Warnings: 1 (Pausen-Unterschreitung 04.03.)                        │
│                                                                    │
│ Approval-Chain:                                                    │
│   ○ Submitted (Du: 31.03. pending)                                 │
│   ○ Head-Approved (PW: pending)                                      │
│   ○ Admin-Approved (Nenad: pending)                                   │
│   ○ Locked                                                         │
│   ○ Exported                                                       │
└────────────────────────────────────────────────────────────────────┘
```

**Interaktionen:**
- Klick Tag-Zeile → Drawer "Tages-Eintrag-Edit"
- Klick Pausen-Warnung 🟠 → Tooltip mit Detail ("Bei 9h Arbeitszeit braucht es 60min Pause, nur 28min erfasst")
- `[Submit]` öffnet Modal 420px "Monat einreichen" (Confirm mit Ist/Soll/Warnings-Count)
- `[Submit]` disabled wenn Hard-Errors (Pausen 60min-Pflicht bei >9h gebrochen, Ruhezeit <11h)

### 2.4 Abwesenheiten (`/zeit/abwesenheiten`)

**Zweck:** Monats-Kalender-Grid mit Team-Zeilen · Farbcodierung nach Abwesenheitstyp · Quick-Filter.

**Layout:**

```
┌─ April 2026 · Team-Abwesenheiten ──── [+ Antrag] ────────────────────┐
│            │1│2│3│4│5│6│7│8│9│... 30│                                │
│ ───────────┼─┼─┼─┼─┼─┼─┼─┼─┼─┼───┼─┤                                │
│ Nenad (NB) │ │ │ │ │ │ │ │ │ │...│ │                                │
│ Peter (PW) │ │ │ │▓│▓│▓│▓│▓│▓│...│ │  ▓ = Ferien                   │
│ Lisa (LR)  │ │ │ │ │ │ │ │▒│▒│...│ │  ▒ = Krank                    │
│ Anna (AH)  │M│ │ │ │ │ │ │ │ │...│ │  M = Militär                   │
│ Joaquin(JV)│ │ │ │ │ │ │★│ │ │...│ │  ★ = Extra (Jokertag)         │
│ ...        │ │ │ │ │ │ │ │ │ │...│ │                                │
│                                                                      │
│ Filter: [Alle Typen ▾] [Alle MA ▾] [Monat ▾]                        │
└──────────────────────────────────────────────────────────────────────┘
```

**Interaktionen:**
- Klick Zelle → Drawer "Abwesenheits-Detail" (540px)
- Klick leerer Zellen (eigene Zeile) → Drawer "Neuer Antrag"
- `[+ Antrag]` → Drawer "Neuer Antrag" mit Typ-Dropdown
- Legend-Click → Filter aktiv

**DSG-Note:** Arztzeugnis-File nicht im Grid sichtbar · nur Abwesenheits-Typ + Zeitraum · Datei nur in Detail-Drawer für Berechtigte.

### 2.5 Team (`/zeit/team`) — nur Head of/Admin

**Zweck:** Approval-Queue · Team-Saldi-Overview · Auffälligkeiten.

**Layout:** 3 Tabs:

**Tab 1: Wochen-Check (F12 Hybrid-Mode)**

```
┌─ Offene Wochen-Reviews (KW 16) ─── [Alle anhaken] [Approve markierte]─┐
│ ☐ Peter Wiederkehr      40h 12min / 45h · 2h uncounted · 0 Warnings │
│ ☐ Lisa Rüegg            45h 30min / 45h · 0h uncounted · 1 Warning  │
│ ☐ Joaquin Vega          47h 15min / 45h · 0h uncounted · 2 Warnings│
│ ...                                                                   │
└──────────────────────────────────────────────────────────────────────┘
```

**Tab 2: Monats-Approvals**

```
┌─ Offene Monats-Submits (März 2026) ──────────────────────────────────┐
│ • Peter → submitted 31.03. · [Approve] [Reject] [Details]           │
│ • Lisa  → submitted 01.04. · [Approve] [Reject] [Details]           │
│ ...                                                                   │
└──────────────────────────────────────────────────────────────────────┘
```

**Tab 3: Team-Saldi**

```
┌─ Team-Saldi-Übersicht ──────────────────────────────────────────────┐
│ MA      │ Wochen-Saldo │ Monat Ist/Soll │ Ferien-Rest │ Überzeit-J  │
│ PW      │ +2h 15       │ 142/180        │ 12/25       │ 8/170       │
│ LR      │ 0h           │ 175/180        │ 18/25       │ 0/170       │
│ ...                                                                   │
└──────────────────────────────────────────────────────────────────────┘
```

### 2.6 Saldi (`/zeit/saldi`)

**Zweck:** 3-Konten-Modell + Ferien + Extra-Guthaben · Verlauf + Buchungslogik.

**4 Karten:**

```
┌─ Ferien ────────┐ ┌─ OR-Überstunden ┐ ┌─ ArG-Überzeit ─┐ ┌─ Extra-Guthaben─┐
│ Entitlement 25  │ │ Akkumuliert 0h  │ │ Akkumuliert 8h │ │ Geburtstag 1/1  │
│ Übertrag    2   │ │ Kompensiert 0h  │ │ Kompensiert 0h │ │ Angehörige 1/1  │
│ Bezogen    10   │ │ Rest         0h │ │ Rest         8h│ │ Jokertag   0/1  │
│ Geplant     3   │ │                 │ │ Jahres-Cap   170│ │ ZEG-Q1     1/1  │
│ Rest       14   │ │ (Reglement: nur │ │                │ │ ZEG-Q2     0/1  │
│                 │ │  Zeitausgleich) │ │                │ │ GL-Extra   0/3  │
│ Verfällt 13.04. │ │                 │ │                │ │                 │
│ (Ostern+14)     │ │                 │ │                │ │                 │
│ [Antrag stellen]│ │ [Kompensation]  │ │ [Kompensation] │ │ [Extra beantr.] │
└─────────────────┘ └─────────────────┘ └────────────────┘ └─────────────────┘
```

**Details-Drawer** pro Karte:
- Timeline aller Buchungen (Akkumuliert / Bezug / Kompensation)
- CSV-Export

### 2.7 Export (`/zeit/export`) — nur Backoffice/Admin

**Zweck:** Monats-Exporte für Treuhand Kunz generieren · Bexio-CSV / ELM 5.0 (Phase 2).

**Layout:**

```
┌─ Export-Generator ──────────────────────────────────────────────────┐
│ Periode: [März 2026 ▾]                                              │
│ Format:  [○] Bexio-CSV  [○] ELM 5.0 XML (Phase 2)  [●] Generisch   │
│ MA:      [Alle 10 MA ▾]                                             │
│                                                                     │
│ Voraussetzung-Check:                                                │
│   ✓ 10/10 MA haben Monat submitted                                  │
│   ✓ 10/10 Head-Approved                                               │
│   ✗ 2/10 Admin-Approved (Peter, Lisa pending)                          │
│                                                                     │
│ [Preview] [Exportieren] (disabled)                                  │
└─────────────────────────────────────────────────────────────────────┘

┌─ Vergangene Exporte ────────────────────────────────────────────────┐
│ Februar 2026 · 10 MA · 15.03.2026 · bexio_hours_2026_02.csv [↓]   │
│ Januar  2026 · 10 MA · 12.02.2026 · bexio_hours_2026_01.csv [↓]   │
└─────────────────────────────────────────────────────────────────────┘
```

### 2.8 Admin (`/zeit/admin`) — nur Admin

**Zweck:** Stammdaten + Policies.

**5 Sub-Module (Tabs):**

1. **Arbeitszeit-Modelle:** Zuweisung pro MA (Model + Kernzeit + Pensum)
2. **Feiertage-Editor:** ZH-Kalender + Brückentag-Editor (F11)
3. **MA-Verträge:** `fact_workday_target` CRUD
4. **Sozialpartner-Vereinbarung 73b:** Template + Upload-Tracker
5. **Korrekturen nach Lock:** Queue aller `fact_time_correction.status='requested'` — nur Admin darf approven (F13)

---

## 3. Drawer-Inventory (540px konsistent)

### 3.1 Tages-Eintrag-Edit

**Trigger:** Klick Tages-Karte in Meine-Zeit / Klick Tag-Zeile in Monats-Übersicht.

**Felder:**

```
Header: [19.04.2026 · Montag]
────────────────────────────────────
Scanner-Events (read-only):
  08:47 → Check-In (SCANNER-01, Eingang)
  12:00 → Break-Out (SCANNER-01, Eingang)
  13:28 → Break-End (SCANNER-01, Eingang)
  17:45 → Check-Out (SCANNER-01, Eingang)

Zusammenfassung:
  Brutto:  9h 10min (Scan-In bis Scan-Out minus Pausen)
  Pause:   32min (gescannt)
  Netto:   8h 38min
  Gezählt: 8h 38min (keine Cap-Überschreitung)

Kategorie-Zuordnung (Pflicht bei Submit):
  [PROD_BILL ▾] 6h 00min · Projekt [Implenia-Senior-Eng ▾] · [x] Billable
  [+ Kategorie hinzufügen]
  [ADMIN    ▾] 2h 38min · Projekt [–]              · [ ] Billable

Kommentar: [_____________________]
──────────────────────────────────
[Audit-Trail ▸ Collapsible]
  - 19.04. 08:47 scan_event: check_in
  - 19.04. 17:45 scan_event: check_out
  - 19.04. 18:10 created by system (aggregation)
  - 19.04. 18:15 category assigned by Peter

[Korrektur beantragen] (wenn status=locked)
[Speichern draft] [Speichern + einreichen]
```

**Validation bei Submit:**
- Kategorien-Summe = counted_duration_min (±1 min tolerance)
- Pausen-Regel (Reglement + ArG) — Hard-Block bei Verletzung
- Ruhezeit 11h zum Vortag — Warning (nicht Hard-Block, Policy)

### 3.2 Urlaubs-Antrag

**Trigger:** `[+ Antrag]` in Abwesenheiten · `[Antrag stellen]` in Saldi-Ferien-Karte.

**Felder:**

```
Header: Neuer Urlaubsantrag
────────────────────────────────────
Typ:  [Ferien ▾]
       (Extra-Guthaben → Sub-Auswahl)

Von:  [20.04.2026]   [ ] Halbtag PM
Bis:  [24.04.2026]   [ ] Halbtag AM

Auto-Calc:
  Arbeitstage:     5 (Mo-Fr)
  Feiertage drin:  0
  Ferientage:      5 von 14 Rest

Grund (optional):
  [____________________________]

Team-Kalender-Konflikte:
  ✓ Keine Konflikte im Team am 20.-24.04.

──────────────────────────────────
[Senden]
```

**Nach Send:** Status `submitted` · Mail an Head of · bei Approval: Status `approved` · Kalender-Sync.

### 3.3 Krank-Meldung

**Trigger:** `[+ Antrag]` · `Absenz-Typ=Krank` ausgewählt.

**Felder:**

```
Header: Krankmeldung einreichen
────────────────────────────────────
Von:  [20.04.2026]
Bis:  [voraussichtlich bis 22.04.2026] (kann später verlängert werden)

Arztzeugnis erforderlich ab: Tag 2  (dein Dienstjahr: 2. DJ · Reglement §3.5.2)
  ab 21.04.2026 Upload-Pflicht

Upload Arztzeugnis (optional jetzt):
  [Datei wählen] drag-and-drop

Bemerkung (optional):
  [__________________________]

──────────────────────────────────
[Einreichen]
```

**Flow:**
- Meldung sofort `active` (keine Approval-Schwelle für Krank)
- Reminder-Mail ab Tag N+1 (wenn Zeugnis fehlt)
- Bern-/Zürcher-Skala Anspruchs-Check im Hintergrund
- Bei Annäherung Limite: Alert an Head of

### 3.4 Korrektur-Antrag

**Trigger:** Klick `[Korrektur beantragen]` auf gesperrten Tages-Eintrag.

**Felder:**

```
Header: Korrektur beantragen · 02.03.2026
────────────────────────────────────
Ursprungs-Werte:           Neue Werte:
  Kategorie PROD_BILL       [PROD_BILL ▾]
  Dauer 6h 00min            [6h 00min]
  Projekt Implenia          [Arcoba ▾] (geändert)
  Billable: ✓               [✓] Billable

Diff-Preview:
  project_id: [alt] UUID-Implenia → [neu] UUID-Arcoba

Grund (Pflicht):
  [Falsche Projekt-Zuordnung · bei Stundenbuchung]
  [_____________________________________________]

Info: Monat ist bereits locked.
Korrektur benötigt Admin-Freigabe.

──────────────────────────────────
[Senden]
```

**Nach Submit:**
- Status `requested` in `fact_time_correction`
- Mail an Admin
- Bei Approval: Original-Eintrag `entry_state=corrected`, neuer Eintrag erstellt
- Wenn Monat bereits exportiert: `fact_time_period_close.export_needs_redo=true`

### 3.5 Extra-Guthaben-Antrag

**Trigger:** `[Extra beantr.]` in Saldi.

**Felder:**

```
Header: Extra-Guthaben beantragen
────────────────────────────────────
Typ: [Jokertag ▾]
     ▸ Geburtstag MA (1 T · nur in Geburtstagswoche 12.-16.04.)
     ▸ Geburtstag nahestehende Person (1 T · frei wählbar)
     ▸ Jokertag (Me Time) (1 T · frei wählbar)
     ▸ ZEG-Zielerreichung Q1 (1 T · bei ≥100% ZEG · freigegeben)
     ▸ GL-Ermessen (bis 3 T · GL-Freigabe nötig)

Datum: [22.04.2026] [ ] Halbtag

Sperrfristen-Check:
  ✓ Nicht in Weihnachtswoche (24.12.-01.01.)
  ✓ Nicht an Sechseläuten-Halbtag (20.04.)
  ✓ Nicht an Brückentag

Bei Geburtstag MA: Fenster 12.04.-18.04.2026 (±3 Tage um 15.04.)

──────────────────────────────────
[Senden]
```

---

## 4. Modal-Inventory (420px · nur für irreversible Confirms)

### 4.1 Monat einreichen (Modal 420px)

**Trigger:** `[Submit]` in Monats-Übersicht.

```
┌─ März 2026 einreichen? ──────────────────────┐
│                                              │
│ Ist:      175h 45min                         │
│ Soll:     180h 00min                         │
│ Diff:      -4h 15min                         │
│                                              │
│ Warnings (1):                                │
│   ⚠ Pausen-Unterschreitung 04.03.           │
│                                              │
│ ☑ Ich bestätige, dass die erfasste Zeit     │
│    korrekt und vollständig ist.              │
│                                              │
│  [Abbrechen]  [Einreichen]                   │
└──────────────────────────────────────────────┘
```

**Hard-Blocks (Submit verhindert):**
- Pause < 60min bei Arbeitszeit > 9h
- Pause < 30min bei Arbeitszeit > 7h
- Ruhezeit < 11h zwischen Tagen (nur Soft-Warning, kein Hard-Block)

### 4.2 Lock-Override (Modal 420px · nur Admin)

**Trigger:** Admin klickt `[Lock zurücksetzen]` in Admin-Korrektur-Queue.

```
┌─ Monats-Lock aufheben? ────────────────────┐
│                                            │
│ Periode:   März 2026 (Peter Wiederkehr)   │
│ Aktueller Status: exported                 │
│                                            │
│ ⚠ Kritisch: Export bereits an Treuhand    │
│    übermittelt. Re-Export erforderlich.    │
│                                            │
│ Grund (Pflicht):                           │
│ [___________________________________]      │
│                                            │
│ ☑ Audit-Log-Eintrag bestätigt              │
│                                            │
│  [Abbrechen]  [Lock aufheben]              │
└────────────────────────────────────────────┘
```

---

## 5. State-Machines

### 5.1 Time-Entry-Lifecycle

```
[draft] ──MA submit──► [submitted] ──Head approve──► [approved]
   ▲                      │                              │
   │                      ▼                              ▼
   │                 [rejected] ◀── Head reject ──── [locked] ──Admin-Korrektur──► [corrected]
   │                      │                              │
   └────reopen (Head)───────┘                             │
                                                         ▼
                                                    [exported] (via period_close)
```

**Transitions:**

| From | To | Actor | Condition |
|------|-----|-------|-----------|
| – | draft | Scanner/MA/Admin | Eintrag erstellt |
| draft | submitted | MA | Tages-/Wochen-Submit |
| submitted | approved | Head of | Head-Approval (wöchentlich F12) |
| submitted | rejected | Head of | Head-Reject mit Grund |
| rejected | draft | Head of | Reopen |
| approved | locked | Admin | Monats-Lock |
| locked | corrected | Admin | Korrektur approved |
| corrected | – | – | Unveränderbar, Audit-Historie |

### 5.2 Absence-Lifecycle

```
[draft] ──submit──► [submitted] ──approve──► [approved] ──start_date──► [active] ──end_date──► [completed]
   ▲                    │                         │                                                │
   │                    ▼                         ▼                                                ▼
   └──MA-cancel──── [rejected]              [cancelled]                                       [corrected]
```

### 5.3 Period-Close-Lifecycle

```
[open] ──MA submit──► [submitted] ──Head approve──► [tl_approved] ──Admin approve──► [gf_approved] ──lock──► [locked]
                                                                                                              │
                                                                                                              ▼
                                                                                                         [exported]
                                                                                                              │
                                                                                                              ▼ (Admin-Override)
                                                                                                        [reopened]
                                                                                                              │
                                                                                                              ▼ (Re-Flow)
                                                                                                         [submitted]
```

### 5.4 Correction-Lifecycle

```
[requested] ──Head approve──► [tl_approved] ──(if locked: Admin approve)──► [admin_approved] ──apply──► [applied]
      │                           │                                                │
      ▼                           ▼                                                ▼
  [rejected]                  [rejected]                                      [rejected]
```

**Wenn Monat nicht locked:** Head-Approval genügt → direkt `applied`.
**Wenn Monat locked:** zusätzlich Admin-Approval erforderlich (F13).

---

## 6. Rollen-Matrix (final)

| Aktion | MA | Head of | Backoffice | Admin |
|--------|----|---------|------------|-------|
| **Eigene Zeit** | | | | | |
| Eigene Zeit erfassen (Scanner/manuell) | ✓ | ✓ | ✓ | ✓ | ✓ |
| Eigene Zeit editieren (draft) | ✓ | ✓ | ✓ | ✓ | ✓ |
| Eigene Zeit editieren (submitted) | reopen only | ✓ | ✓ | ✗ | ✗ |
| Eigene Zeit editieren (locked) | Korrektur-Antrag | Korrektur-Antrag | Korrektur-Antrag | ✗ | ✗ |
| Monat submit | ✓ | ✓ | ✓ | ✓ | ✓ |
| **Abwesenheit** | | | | | |
| Eigene Abwesenheit beantragen | ✓ | ✓ | ✓ | ✓ | ✓ |
| Extra-Guthaben beantragen | ✓ | ✓ | ✓ | ✓ | ✓ |
| Extra-Guthaben freigeben (ZEG, GL) | ✗ | ✗ | ✓ | ✗ | ✓ |
| **Team** | | | | | |
| Team-Zeit sehen | ✗ | ✓ (reports) | ✓ (alle) | ✓ (alle) | ✓ |
| Team-Zeit approven (wöchentlich F12) | ✗ | ✓ | ✓ | ✗ | ✗ |
| Team-Abwesenheit approven (normal) | ✗ | ✓ | ✓ | ✗ | ✗ |
| Team-Abwesenheit approven (MAT/ADOPT/UNPAID/>10 Tage) | ✗ | ✗ | ✓ | ✗ | ✗ |
| **Monats-Flow** | | | | | |
| Monats-Submit (eigener) | ✓ | ✓ | ✓ | ✓ | ✓ |
| Head-Approval Monat | ✗ | ✓ | ✓ | ✗ | ✗ |
| Admin-Approval Monat | ✗ | ✗ | ✓ | ✗ | ✗ |
| Monats-Lock | ✗ | ✗ | ✓ | ✓ | ✗ |
| Lock-Override (reopen) | ✗ | ✗ | ✗ | ✗ | ✓ (F13) |
| **Export** | | | | | |
| Treuhand-Export generieren | ✗ | ✗ | ✓ | ✓ | ✓ |
| Treuhand-Export versenden | ✗ | ✗ | ✓ | ✓ | ✗ |
| **Admin** | | | | | |
| Korrektur-Approval vor Lock | ✗ | ✓ | ✓ | ✗ | ✗ |
| Korrektur-Approval nach Lock | ✗ | ✗ | ✗ | ✗ | ✓ (F13) |
| Arbeitszeit-Modell zuweisen | ✗ | ✗ | ✓ | ✗ | ✓ |
| Feiertage editieren | ✗ | ✗ | ✓ | ✓ | ✓ |
| Bridge-Day festlegen (F11) | ✗ | ✗ | ✓ | ✗ | ✗ |
| MA-Vertrag editieren | ✗ | ✗ | ✓ | ✗ | ✓ |
| 73b-Vereinbarung pflegen | ✗ | ✗ | ✓ | ✗ | ✓ |
| **DSG** | | | | | |
| Scanner-Events sehen (eigene) | ✓ | ✓ (reports) | ✓ | ✓ | ✓ |
| Arztzeugnis-File öffnen (eigene) | ✓ | eigene reports | ✓ | ✓ | ✗ (encrypted) |
| Scanner-Access-Audit sehen | ✗ | ✗ | ✓ | ✗ | ✓ |
| Löschung PD (post-Retention) | ✗ | ✗ | freigabe | execution | tech |

---

## 7. Scanner-Integration-Flow

### 7.1 Scan-Event-Verarbeitung

```
┌─ MA scannt bei Arbeitsbeginn ────────────────────────────────────────┐
│                                                                      │
│ 1. SCANNER-01 sendet REST:                                           │
│    POST /api/zeit/scan                                               │
│    {                                                                 │
│      "device_id": "SCANNER-01",                                      │
│      "scan_at": "2026-04-19T08:47:23+02:00",                         │
│      "scan_type": "check_in",                                        │
│      "user_id_hash": "sha256:abc123..."                              │
│    }                                                                 │
│                                                                      │
│ 2. API-Server:                                                       │
│    - Validiert Token (scanner-api-key)                               │
│    - Resolved user_id aus user_id_hash-Lookup                        │
│    - INSERT fact_time_scan_event                                     │
│    - Returns 200                                                     │
│                                                                      │
│ 3. Worker scan-event-processor (nightly 02:00 UTC):                  │
│    - Aggregiert Events pro User pro Tag                              │
│    - Erstellt / Updated fact_time_entry (status=draft)               │
│    - Berechnet raw_duration_min + counted_duration_min               │
│    - Überlauf (>10h) → uncounted_duration_min gefüllt                │
│    - Pausen aus break_start/break_end-Paaren                         │
│                                                                      │
│ 4. MA sieht am Folgetag aggregierten Tages-Eintrag                   │
│    → muss Kategorie + Projekt zuordnen + submit                      │
└──────────────────────────────────────────────────────────────────────┘
```

### 7.2 Scanner-Ausnahmen (Home-Office / Remote / Scanner-Defekt)

- MA im Home-Office: manuelle Eintragung via Meine-Zeit-Drawer (`source=manual` oder `source=timer`)
- Scanner-Defekt: Admin kann `source=admin` mit Override-Reason setzen
- Vergessen zu scannen: MA erstellt manuellen Nachtrag, Head approved

### 7.3 DSG-Audit-Flow

Jeder Zugriff auf Scanner-Daten (Drawer "Scanner-Events", Export, Admin-Scan-Liste) → automatischer Eintrag in `fact_scanner_access_audit`.

Admin-Dashboard zeigt Audit-Log pro Monat · Admin kann reviewen.

---

## 8. Validation-Regeln

### 8.1 Pausen-Validation (Reglement §2 + ArG §15)

| Arbeitszeit | Reglement-Min | Reglement-Max | Gesetz-Min (ArG) |
|-------------|---------------|---------------|------------------|
| > 5h | 15min | 60min | 15min (ab 5.5h) |
| > 7h | 30min | 75min | 30min |
| > 8h | 60min | 90min | – (ab 9h: 60min) |
| > 9h | 60min | 90min | 60min |

**UI-Feedback:**
- Pause < Reglement-Min bei entsprechender Arbeitszeit → 🟠 Warning auf Tages-Karte
- Pause < Gesetz-Min → 🔴 Hard-Block bei Submit (Gesetzeswarnung)
- Pause > Reglement-Max → 🟡 Info "Pause über dem üblichen Rahmen"

### 8.2 Ruhezeit-Validation (ArG §15a)

- 11h zwischen Ende Tag N und Beginn Tag N+1 → Soft-Warning bei Unterschreitung
- Firmen-Regel optional Hard-Block konfigurierbar in `firm_settings`

### 8.3 Wochen-Cap-Validation (ArG §9 + Reglement §2)

- Wochen-Summe > 45h → UI zeigt "ArG-Überzeit" mit Gesetzeswarnung (nicht Hard-Block)
- Jahres-Überzeit > 170h → Hard-Warning · Monats-Submit nicht blockieren (wäre rechtlich zu hart), aber Alert an Head+Admin
- Daily-Cap 10h: `counted_duration_min` max 600 · Überschuss in `uncounted_duration_min`

### 8.4 Arztzeugnis-Staffelung (Reglement §3.5.2 · F6)

Berechnung in Business-Logic (nicht Schema-Constraint):

```
dienstjahr = DATEDIFF(current_date, employment_start_date) / 365
require_cert_from_day = CASE
    WHEN dienstjahr = 1 THEN 1  -- ab Tag 1
    WHEN dienstjahr = 2 THEN 2  -- ab Tag 2
    ELSE                    3   -- ab Tag 3
END
```

System sendet Reminder am `absence.start_date + require_cert_from_day - 1`.

---

## 9. Flows · End-to-End

### 9.1 Happy-Path · Scanner-MA · März 2026

1. **Tag-für-Tag (automatisch):** Scanner loggt 4x/Tag (check_in, break_out, break_end, check_out)
2. **Worker nightly:** aggregiert zu `fact_time_entry status=draft`
3. **Wöchentlich (F12 Hybrid):**
   - MA öffnet Meine-Zeit, ordnet Kategorie+Projekt zu, klickt "Woche einreichen"
   - Head of sieht in Team → Wochen-Check Tab, approved Batch
4. **Monats-Ende (31.03.):**
   - MA prüft Monats-Übersicht, klickt "Monat einreichen" (Modal 420px Confirm)
   - `fact_time_period_close.status=submitted`
5. **Head-Approval (01.04.):**
   - Team → Monats-Approvals Tab
   - Klick "Approve" → `tl_approved`
6. **Admin-Approval (02.04.):**
   - Gleiche UI, aber "Admin-Approve"-Action
   - `gf_approved`
7. **Lock (05.04.):**
   - Backoffice klickt "Lock" in Export-Screen
   - `locked`
8. **Export (15.04.):**
   - Backoffice klickt "Exportieren" für Bexio-CSV
   - `exported`, Mail an Treuhand Kunz

### 9.2 Edge-Case · Korrektur nach Lock

1. MA merkt am 20.04., dass 15.03. falsche Projekt-Zuordnung war (Implenia statt Arcoba).
2. MA öffnet 15.03.-Eintrag in Meine-Zeit → sees `status=locked` → klickt "Korrektur beantragen".
3. Drawer 3.4 zeigt Diff + verlangt Grund.
4. Submit → `fact_time_correction status=requested`.
5. Admin sieht in `/zeit/admin/corrections` die Queue.
6. Admin klickt "Approve" → `admin_approved` → automatisch `applied`:
   - Original `fact_time_entry` bekommt `status=corrected`
   - Neuer Eintrag wird erstellt mit neuen Werten
   - `fact_time_period_close.export_needs_redo=true`
   - Mail an Backoffice: "Re-Export erforderlich"

### 9.3 Edge-Case · Krank mit DJ-Staffelung

- Anna (2. Dienstjahr) meldet am 20.04. Krankheit.
- System berechnet: DJ=2 → `require_cert_from_day=2`
- Drawer 3.3 zeigt: "Arztzeugnis erforderlich ab 21.04.2026"
- 21.04. 08:00 → Worker `doctor-cert-reminder` sendet Mail an Anna + Head of
- Anna upload Zeugnis bis 21.04. 17:00 → Status OK
- Wenn 22.04. 08:00 noch kein Upload → Alert eskaliert an Admin

---

## 10. Offen für Phase-B-Mockups

Nach Spec-Freeze folgen Mockups (HTML) — 1:1 aus dieser Interactions-Spec:

| Mockup | Priorität |
|--------|-----------|
| `mockups/ERP Tools/zeit-meine-zeit.html` | P1 (Kern-Screen) |
| `mockups/ERP Tools/zeit-monat.html` | P1 |
| `mockups/ERP Tools/zeit-abwesenheiten.html` | P1 |
| `mockups/ERP Tools/zeit-team.html` | P1 |
| `mockups/ERP Tools/zeit-saldi.html` | P1 |
| `mockups/ERP Tools/zeit-export.html` | P2 |
| `mockups/ERP Tools/zeit-admin.html` | P2 |
| `mockups/ERP Tools/zeit-dashboard.html` | existiert (harmonize mit neuen KPIs) |

---

## 11. Changelog

| Version | Datum | Änderung |
|---------|-------|----------|
| 0.1 | 2026-04-19 | Initial draft · 7 Screens + 5 Drawer + 2 Modals · 4 State-Machines · Rollen-Matrix · Scanner-Flow · 3-Konten-Saldo UI · Extra-Guthaben-Flow |
| 0.2 | 2026-04-20 | Mockup-Phase-Deltas · 10-Punkte-Review-Runde |

---

## 12. Deltas v0.1 → v0.2 (Mockup-Iteration)

### 12.1 Rollen-Rename

- `TL` → **Head of** (Head ING · Head ARC · Head PUR · etc.)
- `GF` / `Founder` → **Admin** (Nenad = Admin-Rolle · System-Super-User)
- Rollen-Matrix jetzt **4** statt 5 Rollen: Mitarbeiter · Head of · Backoffice · Admin

### 12.2 Arkadium-Policy · Überzeit = Lohn-abgegolten

F8-Decision revidiert: OR-Überstunden + ArG-Überzeit sind bei Arkadium mit **Grundlohn abgegolten** (Vertragsklausel). **Keine** Kompensation · **Keine** Auszahlung. `fact_overtime_balance` bleibt als reines Tracking für ArG-Compliance (170h-Jahres-Cap-Warning). UI zeigt Info-Chip "Lohn-abgegolten" statt Action-Buttons.

**Schema-Impact:** neuer `firm_settings.overtime_compensation_policy = 'paid_with_salary'` (Arkadium) · Alternative für andere Tenants: `time_off` · `pay_25pct` · `hybrid`.

### 12.3 Stempel-Antrag · Einzel-Event statt Zeit-Block

Manueller Zeit-Eintrag wurde radikal simplifiziert:

**Vorher (v0.1):** Zeit-Block-Erfassung (Datum + Von/Bis + Pause + Kategorie + Projekt + Verrechenbar + Grund)

**Nachher (v0.2):** Einzelner Scanner-Stempel-Event:
- Datum + Uhrzeit
- Auto-Detect Typ (Check-In / Pause-Start / Pause-Ende / Check-Out basierend auf Tages-Scan-Folge)
- Manueller Override-Toggle (für Edge-Cases)
- **Grund als Dropdown** statt freitext: Home-Office / Remote / Scanner-Defekt / Vergessen / Termin extern / Früh weg / Spät gekommen / Sonstiges
- Keine Kategorie-Zuordnung · keine Pausen-Minuten (entfallen im Scanner-Modell)

**Use-Case:** Freitag-Wochenkontrolle · MA sieht Fehler/vergessene Scans · stellt Stempel-Antrag · Head approved in Team-Approvals-Queue.

### 12.4 Kategorien raus aus Tages-Eintrag-Drawer

Ursprünglich Kategorie+Projekt+Billable-Zuordnung pro Tag in Tages-Eintrag-Drawer. **Entfällt komplett** — Abrechnung läuft nicht stündlich sondern via ZEG-Staffel (auf Mandats-Summen-Basis · siehe Commission-Engine-Spec). Tages-Eintrag reduziert auf Scanner-Events + Summary + Audit + Kommentar.

**Schema-Impact:** `fact_time_entry.category_code` und `billable` bleiben im Schema · werden von Scanner-Aggregator-Worker nicht mehr ausgefüllt · optional für manuelle Overrides. Commission-Engine nutzt `v_time_per_mandate` direkt.

### 12.5 Ferien-Antrag mit Stellvertretung

Neu in Ferien-Antrag-Drawer (zeit-abwesenheiten):
- **Stellvertretung** (Team-Pick Dropdown) · conditional sichtbar nur bei Typ VACATION/VACATION_HALF_*
- Pflicht bei Ferien ≥ 3 Tage (Reglement Tempus Passio §2)

**Kein** Auto-Reply (Outlook-Integration) — Arkadium-Policy: auch in Ferien erreichbar.

**Schema-Impact:** `fact_absence.substitute_user_id UUID NULL REFERENCES dim_user(id)` · neu.

### 12.6 Team-Approvals · Wochen-Check entfernt

Head-Workflow vereinfacht · Tabs reduziert von 4 auf 3:

**v0.1:** Wochen-Check · Monats-Approvals · Team-Saldi

**v0.2:** Stempel-Anträge · Monats-Approvals · Team-Saldi

**Begründung:** Scanner-Daten sind automatisch valide · Wochen-Check redundant zu Stempel-Anträge + Team-Saldi-Heatmap. Anomalien (ArG-Cap-Annäherung, Overtime-Spikes) sichtbar im Team-Saldi-Tab · Head bei Bedarf ad-hoc.

**Wegfallender Backend-Impact:** `v_weekly_approval_queue` View bleibt im Schema für potentielle spätere Aktivierung · Worker `week-check-reminder` entfällt.

### 12.7 MA-Verträge komplett in HR

Zeit-Admin Tab "MA-Verträge" entfernt · HR ist ausschliesslich zuständig für:
- Arbeitsverträge + Reglement-Signaturen (Generalis Provisio · Tempus Passio 365 · Locus Extra)
- Home-Office-Bewilligung (Reglement Locus Extra · Quoten 20 HO + 10 Remote · GL-Ermessen)
- Zertifikate (Scheelen-Tracker)
- Schulungen (Academy)

**Zeit-Admin** behält nur: Arbeitszeit-Modelle (Gleitzeit-Zuweisung) · Feiertage · 73b-Vereinbarungen · Korrekturen-Queue.

### 12.8 HR-Mitarbeiter-Self entkoppelt von Zeit-Flows

Ferien+Krank-Drawers aus `hr-mitarbeiter-self.html` komplett entfernt (inkl. Trigger-Buttons). Nur noch im Zeit-Modul verfügbar. Home-Office-Drawer bleibt in HR (Reglement-Bewilligung). Quick-Actions in HR reduziert auf: Home-Office · Schulung · Zertifikat.

### 12.9 UI-Patterns harmonisiert

- **Drawer:** `.drawer.open` (editorial.css-Convention) statt `.active` · `!important`-Override für CRM-Base-Transform
- **Button im Drawer-Foot:** `.btn .btn-sm [.btn-primary|.btn-danger]` statt eigener `.btn-x*`-Varianten · matches CRM
- **Backdrop-Click:** `closeAllDrawers()` schliesst alle offenen Drawer/Backdrops · überall einheitlich
- **Admin-Edit-Drawer:** kontextuell pro Tab (Arbeitszeit-Modell / Feiertag / 73b / Korrektur) statt generisch
- **Tages-Drawer in zeit-meine-zeit:** dynamisch pro Tag (Mo–So) via `dayContent`-Dictionary

### 12.10 Shell-Features

- **Role-Switcher** (Demo-Feature) in Topbar · zeigt/versteckt Sidebar-Sektionen nach Rolle
- **Command-Palette** (⌘K) · globale Navigation + Aktionen + Tool-Wechsel
- **Profile-Drawer · Shortcuts-Drawer · Logout-Drawer** via Profile-Popup
- **Sidebar default collapsed** (ignoriert stale localStorage-Pin)

### 12.11 Neue Navigation

zeit-list.html (Legacy Phase-1) aus Sidebar entfernt · File bleibt auf Disk als Fallback. Team-Approvals-Badge zeigt 6 (3 Stempel + 3 Monats) mit Tooltip.
