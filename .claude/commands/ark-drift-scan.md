---
description: Drift-Scan across ARK files. L1=Grundlagen intern (default), L2=+Specs, L3=+Mockups, L4=+Mockups intern
argument-hint: [grundlagen|specs|mockups|all]
---

# ARK Drift-Scan: Scope=`$ARGUMENTS`

## Scope-Handling

Falls `$ARGUMENTS` leer oder `grundlagen` → **nur L1**.
Falls `specs` → **L1 + L2**.
Falls `mockups` → **L1 + L2 + L3**.
Falls `internal` → **nur L4** (Mockups untereinander).
Falls `all` → **alle 4 Ebenen**.
Falls ungueltig → frage User welchen Scope.

**Dieser Bau: L1 + L2 + L3 + L4 implementiert.**

**Scope-Variante** mit Doppelpunkt: `specs:processes` oder `mockups:mandates` → nur diese Entity scannen (statt alle).

**Neuer Scope `internal`**: nur L4 (Mockups untereinander, ohne Grundlagen/Specs).

---

## L1 · Grundlagen intern

Scanne Konsistenz zwischen den 5 Grundlagen-Dateien.

### Load

@raw/Ark_CRM_v2/ARK_STAMMDATEN_EXPORT_v1_3.md

@raw/Ark_CRM_v2/ARK_DATABASE_SCHEMA_v1_3.md

@raw/Ark_CRM_v2/ARK_BACKEND_ARCHITECTURE_v2_5.md

@raw/Ark_CRM_v2/ARK_FRONTEND_FREEZE_v1_10.md

@raw/Ark_CRM_v2/ARK_GESAMTSYSTEM_UEBERSICHT_v1_3.md

### Check-Matrix

Pruefe folgende Konsistenz-Regeln:

**Check 1 · Stages**
- Extrahiere aus STAMMDATEN §13 alle Prozess-Stages
- Suche in BACKEND_ARCH welche Stages in Sagas/Events referenziert werden
- Suche in FRONTEND_FREEZE welche Stages in UI-Patterns genannt sind
- **Finding:** Stage in BACKEND/FRONTEND die nicht in STAMMDATEN steht → Drift
- **Finding:** Stage in STAMMDATEN die nirgends referenziert wird → tote Enum

**Check 2 · Mandat-Typen**
- Extrahiere aus STAMMDATEN (Target/Taskforce/Time)
- Suche Referenzen in BACKEND_ARCH (Saga-Routing), FRONTEND_FREEZE, DATABASE_SCHEMA
- Finding: Mandat-Typ erwaehnt der nicht im Katalog ist

**Check 3 · Tables**
- Extrahiere aus DATABASE_SCHEMA alle Tabellen (`dim_*`, `fact_*`, `bridge_*`)
- Suche Referenzen in BACKEND_ARCH (Sagas die diese Tabellen updaten)
- Finding: Tabelle in Saga die nicht in SCHEMA existiert (oder umgekehrt)

**Check 4 · Sagas V1-V7**
- Extrahiere aus BACKEND_ARCH alle Sagas (V1, V2, ..., V7)
- Pruefe ob jede Saga in GESAMTSYSTEM-Changelog erwaehnt wird
- Pruefe ob Stages die Sagas triggern in STAMMDATEN existieren

**Check 5 · Activity-Types**
- Extrahiere aus STAMMDATEN §14 alle 64 Activity-Types + 11 Kategorien
- Suche in BACKEND_ARCH Event-Definitions ob alle Kategorien abgedeckt
- Finding: Activity-Type in UI-Pattern (FRONTEND) der nicht im Katalog ist

**Check 6 · Sparten**
- STAMMDATEN §8: ARC · GT · ING · PUR · REM
- Suche Referenzen in DATABASE_SCHEMA (Filter), FRONTEND_FREEZE
- Finding: Andere Sparten-Werte (Hochbau/Tiefbau = Cluster-Ebene)

**Check 7 · Version-Consistency**
- GESAMTSYSTEM-Changelog erwaehnt Versionen (z.B. "DATABASE_SCHEMA v1_3")
- Pruefe ob diese Versionen matchen mit Dateinamen in `raw/Ark_CRM_v2/`
- Finding: Changelog erwaehnt v1_4 aber File ist v1_3

**Check 8 · EQ/Motivatoren**
- STAMMDATEN §67a (EQ-Dimensionen) und §67b (Motivatoren)
- Referenzen in FRONTEND_FREEZE (Assessment-UI)
- Finding: andere Framework-Werte (z.B. Stress-Management = EQ-i 2.0, nicht unser Framework)

### Output-Format

Pro Finding eine Karte:

```markdown
## Finding <n> · Check <x>: <kurzer Titel>

**Type:** <Enum-Mismatch | Table-Missing | Version-Drift | Tote-Enum | ...>
**Severity:** P0 | P1 | P2
**Locations:**
  - <File-1>: <Zeilen/Abschnitt>, Inhalt: "<excerpt>"
  - <File-2>: <Zeilen/Abschnitt>, Inhalt: "<excerpt>"

**Konflikt:** <Beschreibung>

**Optionen:**
  (A) <File-1> anpassen: <was>
  (B) <File-2> anpassen: <was>

**Empfehlung:** <A oder B> — <Begruendung>
```

Am Ende:

```markdown
## Summary

Total: <n> Findings
Nach Priorität: P0 <x> · P1 <y> · P2 <z>
Nach Check:
- Check 1 (Stages): <count>
- Check 2 (Mandat-Typen): <count>
- ...

## Empfohlene Sync-Reihenfolge

1. <Finding-Ref mit kuerzestem Fix-Pfad>
2. ...
```

### Wichtig

- **Nicht erfinden:** Wenn du unsicher bist ob es wirklich Drift ist → ausgeben als "Ambiguous" mit Fragezeichen statt als Finding
- **Kontext-lastig:** Bei unklarem Match User um Klarstellung bitten bevor viel Output generiert wird
- **Priorität realistisch:** P0 nur fuer Blocker (Code bricht), P1 fuer Inkonsistenz die Bugs verursachen kann, P2 fuer Cosmetics
- **Tote Enums:** markieren aber nicht als P0 (könnten geplant sein)

---

## L2 · Grundlagen ↔ Specs

Nur ausfuehren wenn Scope ``specs``, ``mockups`` oder ``all``. Sonst ueberspringen.

### Load Specs

@specs/ARK_ACCOUNT_DETAILMASKE_SCHEMA_v0_3.md

@specs/ARK_ACCOUNT_DETAILMASKE_INTERACTIONS_v0_3.md

@specs/ARK_ASSESSMENT_DETAILMASKE_SCHEMA_v0_2.md

@specs/ARK_ASSESSMENT_DETAILMASKE_INTERACTIONS_v0_2.md

@specs/ARK_FIRMENGRUPPE_DETAILMASKE_SCHEMA_v0_1.md

@specs/ARK_FIRMENGRUPPE_DETAILMASKE_INTERACTIONS_v0_1.md

@specs/ARK_JOB_DETAILMASKE_SCHEMA_v0_1.md

@specs/ARK_JOB_DETAILMASKE_INTERACTIONS_v0_1.md

@specs/ARK_KANDIDATENMASKE_SCHEMA_v1_3.md

@specs/ARK_KANDIDATENMASKE_INTERACTIONS_v1_3.md

@specs/ARK_MANDAT_DETAILMASKE_SCHEMA_v0_2.md

@specs/ARK_MANDAT_DETAILMASKE_INTERACTIONS_v0_3.md

@specs/ARK_PIPELINE_COMPONENT_v1_0.md

@specs/ARK_PROJEKT_DETAILMASKE_SCHEMA_v0_2.md

@specs/ARK_PROJEKT_DETAILMASKE_INTERACTIONS_v0_1.md

@specs/ARK_PROZESS_DETAILMASKE_SCHEMA_v0_1.md

@specs/ARK_PROZESS_DETAILMASKE_INTERACTIONS_v0_1.md

@specs/ARK_SCRAPER_MODUL_SCHEMA_v0_1.md

@specs/ARK_SCRAPER_MODUL_INTERACTIONS_v0_1.md

### Check-Matrix L2

**Check L2.1 · Version-Referenzen**
- Jeder Spec sollte auf aktuelle Grundlagen-Versionen referenzieren (STAMMDATEN v1_3, DATABASE_SCHEMA v1_3, BACKEND_ARCH v2_5, FRONTEND_FREEZE v1_10, GESAMTSYSTEM v1_3)
- Suche in jedem Spec Referenzen wie "v1_2", "v2_4", "v1_9"
- **Finding:** Spec referenziert veraltete Grundlagen-Version
- **Severity:** P1 (koennte Specs in falschem Zustand einfrieren)

**Check L2.2 · Enum-Verwendung in Schema-Specs**
- Schema-Specs listen Felder mit Enum-Werten (z.B. Stage-Dropdown, Mandat-Typ-Select)
- Verglichen mit STAMMDATEN-Katalog
- **Finding:** Spec nennt Enum-Wert der nicht im Katalog steht (z.B. "Briefing" statt "Expose")
- **Finding:** Spec verwendet Enum aus altem Katalog (z.B. EQ-i 2.0 Werte)
- **Severity:** P0 (Feature-Implementation waere falsch)

**Check L2.3 · Tabellen/Spalten in Schema-Specs**
- Schema-Specs beschreiben Felder die zu DB-Spalten mappen
- Verglichen mit DATABASE_SCHEMA v1_3
- **Finding:** Spec nennt Spalte die nicht in SCHEMA existiert
- **Finding:** Spec-Field-Typ weicht vom SCHEMA-Spalten-Typ ab (z.B. TEXT vs VARCHAR)
- **Severity:** P0 (Coding waere unmoeglich)

**Check L2.4 · Events/Endpoints in Interactions-Specs**
- Interactions-Specs beschreiben User-Actions → Events (z.B. "Klick auf Platzierung → Saga V1")
- Verglichen mit BACKEND_ARCH v2_5 Saga-Definitionen
- **Finding:** Interaction referenziert Saga die nicht existiert (z.B. "V8" oder alte "V-Legacy")
- **Finding:** Event-Name inkonsistent zwischen Spec und Backend-Datei
- **Severity:** P0 fuer V-Nummern, P1 fuer Event-Namen

**Check L2.5 · UI-Patterns in Interactions-Specs**
- Interactions-Specs beschreiben UI-Patterns (Drawer/Modal/Popover/Tab)
- Verglichen mit FRONTEND_FREEZE v1_10 Design-System-Richtlinien
- **Finding:** Spec verwendet Modal fuer CRUD (violation der Drawer-Regel)
- **Finding:** Drawer-Width ≠ 540px
- **Finding:** Tab-Struktur weicht vom FRONTEND_FREEZE ab
- **Severity:** P1

**Check L2.6 · Fehlende Specs fuer im GESAMTSYSTEM erwaehnte Features**
- GESAMTSYSTEM listet Features/Module
- Verglichen ob Detail-Spec dazu existiert
- **Finding:** Feature in GESAMTSYSTEM aber keine Spec (z.B. "Timesheet-Modul erwaehnt, keine TIMESHEET_DETAILMASKE Spec")
- **Severity:** P2

### Output-Format L2

Gleiches Finding-Format wie L1, aber `Check-Prefix` statt `Check <x>`:

```markdown
## Finding <n> · L2.3: <Titel>

**Type:** Column-Missing
**Severity:** P0
**Locations:**
  - Spec: `specs/ARK_MANDAT_DETAILMASKE_SCHEMA_v0_2.md` §4.3
  - DB-Schema: `ARK_DATABASE_SCHEMA_v1_3.md` Tabelle `fact_mandates`

**Konflikt:** Spec nennt Feld `retainer_amount NUMERIC(12,2)`, nicht in DB-Schema

**Optionen:**
  (A) DB-Schema: Spalte hinzufuegen via Migration
  (B) Spec: Feld entfernen (falls nicht gebraucht)

**Empfehlung:** (muss User entscheiden basierend auf Business-Logik)
```

---

## L3 · Specs ↔ Mockups

Nur ausfuehren wenn Scope ``mockups`` oder ``all``. Sonst ueberspringen.

### Mockup-Set (keine @-refs, da Token-schwer)

Nutze **Read-Tool** pro Mockup (nicht inline Preload). Default-Set (nur Detail-Masken):

- `mockups/accounts.html`
- `mockups/assessments.html`
- `mockups/candidates.html`
- `mockups/groups.html`
- `mockups/jobs.html`
- `mockups/mandates.html`
- `mockups/processes.html`
- `mockups/projects.html`

**List-Views und Dashboards** (`*-list.html`, `dashboard.html`, `crm.html`) ueberspringen — die sind generiert aus Detail-Mockups.

Bei Scope `mockups:<entity>` (z.B. `mockups:processes`) → nur `mockups/<entity>.html`.

### Spec-Mapping

| Mockup | Zugehoerige Specs |
|--------|-------------------|
| accounts.html | ARK_ACCOUNT_DETAILMASKE_SCHEMA + INTERACTIONS |
| assessments.html | ARK_ASSESSMENT_DETAILMASKE_SCHEMA + INTERACTIONS |
| candidates.html | ARK_KANDIDATENMASKE_SCHEMA + INTERACTIONS |
| groups.html | ARK_FIRMENGRUPPE_DETAILMASKE_SCHEMA + INTERACTIONS |
| jobs.html | ARK_JOB_DETAILMASKE_SCHEMA + INTERACTIONS |
| mandates.html | ARK_MANDAT_DETAILMASKE_SCHEMA + INTERACTIONS |
| processes.html | ARK_PROZESS_DETAILMASKE_SCHEMA + INTERACTIONS |
| projects.html | ARK_PROJEKT_DETAILMASKE_SCHEMA + INTERACTIONS |

### Check-Matrix L3

Pro Mockup folgende Checks:

**Check L3.1 · Tab-Struktur**
- Interactions-Spec definiert Tab-Liste (z.B. Prozess: 5 Tabs)
- Mockup verglichen ob gleiche Tabs in gleicher Reihenfolge
- **Finding:** Tab fehlt im Mockup / extra Tab ohne Spec / falsche Reihenfolge
- **Severity:** P1

**Check L3.2 · Drawer-Anzahl und Felder**
- Schema-Spec listet Drawer mit Feldern (z.B. NeuerKandidat-Drawer: 8 Felder)
- Mockup verglichen: wie viele Drawer? wie viele Felder je Drawer?
- **Finding:** Drawer fehlt / hat weniger/mehr Felder
- **Severity:** P0 (bei fehlenden Pflichtfeldern) oder P1

**Check L3.3 · Drawer-Width**
- Alle CRUD-Drawer muessen 540px sein (Drawer-Default-Regel 14.04.2026)
- Suche in Mockup-CSS `.drawer` oder `[id*=drawer]` width-Werte
- **Finding:** Drawer mit width ≠ 540px
- **Severity:** P1

**Check L3.4 · Modal-vs-Drawer fuer CRUD**
- Drawer-Default-Regel: CRUD immer Drawer, Modal nur Confirms
- Scanne `<dialog>`, `.modal`, `role="dialog"` mit CRUD-Content
- **Finding:** Modal fuer CRUD-Flow
- **Severity:** P1

**Check L3.5 · Stage-Pipeline-Rendering**
- Wo Spec verlangt Stage-Pipeline (Prozess, Kandidat-Tab-6, Mandat, etc.)
- Verglichen mit Reference candidates.html Tab 6 SVG-Linie
- **Finding:** anderes Rendering (z.B. Kachel-Grid statt SVG-Linie)
- **Severity:** P1 (Design-Drift, nicht funktional blockierend)

**Check L3.6 · Enum-Werte in Dropdowns/Filtern**
- Mockup hat `<select>`, `<option>`, Chips, Filter-Buttons
- Verglichen mit STAMMDATEN-Katalog (via Schema-Spec)
- **Finding:** Dropdown-Option nicht im Katalog (z.B. "Briefing" statt "Expose")
- **Severity:** P0

**Check L3.7 · Saga-Preview im Drawer**
- Interactions-Spec definiert welche Sagas ein Drawer triggert (z.B. Placement-Drawer → Saga V1 mit 8 Steps)
- Verglichen ob Mockup eine `<ul>`-Preview mit allen Steps zeigt
- **Finding:** Saga-Preview fehlt oder zeigt nur Teil der Steps
- **Severity:** P1

**Check L3.8 · DB-Tech-Details in UI-Text**
- `dim_*`, `fact_*`, `bridge_*`, `_fk`, rohe `_id` in Card-Titeln, Tooltips, Labels
- **Finding:** DB-Begriffe leaken in User-facing-Text
- **Severity:** P2

### Output-Format L3

Pro Finding gleiches Schema:

```markdown
## Finding <n> · L3.4: Modal fuer CRUD in <mockup>

**Type:** Modal-vs-Drawer-Violation
**Severity:** P1
**Locations:**
  - Mockup: `mockups/mandates.html` Z. 1240 (Modal fuer "Neuer Mandant")
  - Spec: `specs/ARK_MANDAT_DETAILMASKE_INTERACTIONS_v0_3.md` §3.1 (fordert Drawer)

**Konflikt:** Mockup nutzt Modal, Spec + Drawer-Default-Regel verlangen Drawer

**Optionen:**
  (A) Mockup: Modal → Drawer (540px, slide-from-right) umbauen
  (B) Spec: Modal-Nutzung rechtfertigen (warum Ausnahme)

**Empfehlung:** A — Drawer-Default-Regel ist Project-Wide, keine Ausnahme
```

### Pro-Mockup-Summary

Am Ende von L3 Mockup-Level-Tabelle:

```markdown
## L3 · Pro-Mockup Summary

| Mockup | L3.1 | L3.2 | L3.3 | L3.4 | L3.5 | L3.6 | L3.7 | L3.8 | Total |
|--------|------|------|------|------|------|------|------|------|-------|
| accounts.html | 0 | 1 | 0 | 0 | 1 | 0 | 0 | 2 | 4 |
| processes.html | 2 | 0 | 0 | 1 | 1 | 3 | 2 | 0 | 9 |
| ... |
```

---

---

## L4 · Mockups intern (Shared-Components)

Nur ausfuehren wenn Scope ``all`` oder ``internal``. Sonst ueberspringen.

Scanne ob identische Design-Patterns konsistent ueber alle Mockups implementiert sind. L4 braucht keine Grundlagen/Specs im Kontext — pure Mockup-zu-Mockup-Vergleiche.

### Mockup-Set

Gleiche 8 Detail-Mockups wie L3. Zusaetzlich optional List-Views fuer spezifische Checks (L4.9).

### Reference-Mockup-Mapping

Pro Shared-Component wird eine Referenz-Implementation festgelegt (zumeist `candidates.html` da am ausgearbeitetsten):

| Component | Reference | Check |
|-----------|-----------|-------|
| Stage-Pipeline | candidates.html Tab 6 SVG-Linie | L4.1 |
| Drawer | candidates.html erster CRUD-Drawer (540px) | L4.2 |
| Header-Row (Breadcrumb + Actions) | candidates.html | L4.3 |
| Tab-Navigation | candidates.html | L4.4 |
| Card-Layout (padding/radius/shadow) | candidates.html Main-Card | L4.5 |
| Timeline/History-View | activities.html (falls existiert) sonst candidates.html Tab 7 | L4.6 |
| Snapshot-Bar | jobs.html oder mandates.html (sichtbarste Version) | L4.7 |
| Stage-Popover (Skip/Back) | candidates.html Tab 6 `.pr-stage-pop` | L4.8 |
| Post-Placement-Garantie | candidates.html Tab 6 Widget | L4.9 |
| Empty-State-Pattern | candidates.html oder accounts.html | L4.10 |

### Check-Matrix L4

Pro Shared-Component:

**Check L4.1 · Stage-Pipeline-Rendering**
- Reference: SVG-Linie mit 9 Dots, Gradient-Fill, pulsing-Ring auf Current, Diamant auf Placement
- Scan alle Mockups die Stage-Pipeline zeigen (candidates, processes, mandates)
- **Finding:** Anderes Rendering (z.B. processes.html 9-Kachel-Grid)
- **Severity:** P1

**Check L4.2 · Drawer-Spezifikation**
- Drawer-Width: 540px exakt
- Slide-Richtung: von rechts (`transform: translateX`)
- Escape-Key + Backdrop-Click schliessen
- Footer sticky
- Scanne CSS-Klassen `.drawer`, `[class*=drawer]`
- **Finding:** Drawer mit abweichender Width / andere Slide-Richtung / fehlende Footer
- **Severity:** P1

**Check L4.3 · Header-Row**
- Struktur: Breadcrumb (links) + Titel + Action-Icons (rechts)
- Hoehe, Padding, Shadow einheitlich
- **Finding:** andere Struktur / fehlende Breadcrumb / Action-Icons links statt rechts
- **Severity:** P2

**Check L4.4 · Tab-Navigation**
- Tab-Bar-Styling: Icons + Text, Active-State mit Underline + Farbe
- Badge-Positionierung
- **Finding:** andere Tab-Rendering (z.B. Buttons statt Underlines)
- **Severity:** P2

**Check L4.5 · Card-Layout-Konstanten**
- Konsistente padding, border-radius, box-shadow ueber Mockups
- Identische Card-Header-Struktur (Titel + Subtitel + Actions)
- **Finding:** Card-Styling divergiert (verschiedene radius/shadow)
- **Severity:** P2

**Check L4.6 · Timeline/History-View**
- Gleiche Event-Bullet-Struktur, gleiche Datum-Formatierung, gleiche Actor-Anzeige (2-Buchstaben-Kuerzel)
- **Finding:** andere Timeline-Rendering ueber Mockups
- **Severity:** P2

**Check L4.7 · Snapshot-Bar**
- Gleiche Slot-Struktur (KPI-Boxen)
- **Finding:** Snapshot-Bar in einem Mockup vorhanden, in vergleichbarem fehlend
- **Severity:** P2

**Check L4.8 · Stage-Popover**
- `.pr-stage-pop` mit Skip/Back-Chip + Pflicht-Textarea fuer Grund
- **Finding:** Stage-Wechsel ohne Popover / Popover ohne Pflicht-Textarea
- **Severity:** P1

**Check L4.9 · Post-Placement-Garantie-Widget**
- 3-Mt/6-Mt/12-Mt-Milestone-Dots + 4-Spalten-Metrik-Panel
- Erwartet in candidates.html Tab 6 UND processes.html Tab 1 Sektion 4
- **Finding:** Widget fehlt wo es laut Logik hingehoert
- **Severity:** P1

**Check L4.10 · Empty-State-Pattern**
- Icon + Title + Description + optional CTA-Button
- **Finding:** Mockups ohne Empty-State wo List/Filter-Tabs existieren
- **Severity:** P2

**Check L4.11 · Color-Tokens**
- Reference-Mockup hat definierte CSS-Variablen (`--ark-primary`, `--ark-bg-card`, etc.)
- **Finding:** Hardcoded Hex-Werte statt CSS-Variablen in anderen Mockups
- **Severity:** P2

**Check L4.12 · List-View-Consistency** (optional, wenn `list-views` im Scope)
- `accounts-list.html`, `candidates-list.html`, etc. — alle gleiche Tabellen-Struktur?
- Filter-Chips gleich positioniert?
- **Finding:** andere Tabellen-Struktur / andere Filter-Mechanik
- **Severity:** P2

### Output-Format L4

Pro Finding gleiches Schema + zusaetzlich **Spread-Zeile** (in wie vielen Mockups betroffen):

```markdown
## Finding <n> · L4.1: Stage-Pipeline divergiert

**Type:** Component-Drift
**Severity:** P1
**Spread:** 2 von 4 Mockups die Pipeline zeigen
**Reference:** `mockups/candidates.html` Tab 6 (SVG-Linie, 9 Dots, Gradient)

**Abweichungen:**
  - `mockups/processes.html` Z. 580-720: 9-Kachel-Grid (`.pst-step` roemisch I-IX)
  - `mockups/mandates.html` Z. 890-940: SVG-Linie (OK, matches reference)

**Konflikt:** processes.html weicht ab, reduziert visuelle Konsistenz

**Optionen:**
  (A) processes.html auf SVG-Linie umstellen (Reference wird Standard)
  (B) Shared-Component extrahieren mit 2 Modi (compact/detailed)
  (C) Reference aendern auf processes.html Kachel-Grid (anderswo nachziehen)

**Empfehlung:** B — SVG-Linie ist Standard, aber detailed-Mode fuer Prozess-Detail sinnvoll
```

### Pro-Component-Summary L4

```markdown
## L4 · Pro-Component Summary

| Component | Betroffene Mockups | Severity |
|-----------|--------------------|---------:|
| Stage-Pipeline | processes.html | P1 |
| Drawer-Width | (alle konform) | - |
| Header-Row | accounts.html, groups.html | P2 |
| ... |
```

---

### Abschluss

Nach L1 + L2 + L3 + L4 Report, Summary-Tabelle:

```markdown
## Gesamt-Summary

| Ebene | Findings | P0 | P1 | P2 |
|-------|----------|----|----|----|
| L1 (Grundlagen intern) | <n> | <p0> | <p1> | <p2> |
| L2 (Grundlagen ↔ Specs) | <n> | <p0> | <p1> | <p2> |
| L3 (Specs ↔ Mockups) | <n> | <p0> | <p1> | <p2> |
| L4 (Mockups intern) | <n> | <p0> | <p1> | <p2> |

Total: <total> Findings
```

Danach frage User:
```
Welches Finding zuerst angehen?
(n) — Finding-Nummer
(skip) — spaeter wiederkommen
(export) — Report in wiki/meta/drift-scan-YYYYMMDD-HHMM.md speichern
(filter) — nur P0 anzeigen / nur bestimmte Check-Nummer
```
