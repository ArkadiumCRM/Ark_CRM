---
title: "Spec-Mockup-Sync-Report 2026-04-25"
type: analysis
created: 2026-04-25
sources: ["wiki/meta/digests/STALE.md", "wiki/meta/grundlagen-changelog.md", "wiki/meta/lint-violations.md", "wiki/meta/spec-sync-regel.md"]
tags: [analysis, sync-report, drift, performance-modul]
---

# Spec-Mockup-Sync-Report — 2026-04-25

## Executive Summary

Drift-Analyse direkt nach Performance-Modul-Mockup-Phase-Abschluss (11/11 Mockups). **Hauptbefund:** 4 Performance-Patches (STAMMDATEN/DB/BACKEND v1.5→v1.6/v1.7→v1.8 + HR-PATCH v0.1→v0.2) wurden erstellt (13:45–14:09), aber **noch nicht in die 5 Grundlagen-MDs eingearbeitet** — Grundlagen wurden zuletzt 13:36–13:38 mit dem HR-Modul-Sync (TEIL M/O/P/§96/TEIL 25) aktualisiert. Daher: 0 Performance-Referenzen in irgendeiner Grundlage, 5 Digests stale, Performance-Tool nicht in `spec-sync-regel.md` registriert. Zusätzlich aktive Lint-Violations in 3 neuen Performance-Mockups (UMLAUT-Substitute `fuer`/`ueber` in User-facing Texten + JS-Identifiern). Gesamt: ~13 drift-points, davon 9 als Folge des Performance-Patch-Backlogs.

## Unresolved Changelog-Einträge (0)

Alle Einträge im `wiki/meta/grundlagen-changelog.md` haben Status `resolved`. Die 5 letzten Einträge (HR-Modul-Sync session-7da21068, 2026-04-25 13:36–13:38) sind durch den selben Sync-Edit aufgelöst. **Aber:** der Performance-Modul-Build hat noch keinen Changelog-Eintrag erzeugt — die 4 Patches wurden als Spec-Files committed (commits 26233d1 + 4e8e1f2), nicht als Grundlagen-Edits → kein Hook-Trigger.

## Stale Digests (5/5)

Alle 5 Digests sind stale gegenüber den Grundlagen-Edits 2026-04-25 13:36–13:38 (HR-Modul-Sync TEIL M/O/P/§96/TEIL 25):

- `database-schema-digest.md` — Grundlage `ARK_DATABASE_SCHEMA_v1_5.md` edited 2026-04-25 13:36, digest last regenerated 2026-04-24 16:26 (≈ **23 h behind**)
- `backend-architecture-digest.md` — Grundlage `ARK_BACKEND_ARCHITECTURE_v2_7.md` edited 2026-04-25 13:36, digest last regenerated 2026-04-24 16:29 (≈ **23 h behind**)
- `stammdaten-digest.md` — Grundlage `ARK_STAMMDATEN_EXPORT_v1_5.md` edited 2026-04-25 13:37, digest last regenerated 2026-04-24 16:24 (≈ **23 h behind**)
- `frontend-freeze-digest.md` — Grundlage `ARK_FRONTEND_FREEZE_v1_12.md` edited 2026-04-25 13:38, digest last regenerated 2026-04-24 16:31 (≈ **23 h behind**)
- `gesamtsystem-digest.md` — Grundlage `ARK_GESAMTSYSTEM_UEBERSICHT_v1_4.md` edited 2026-04-25 13:38, digest last regenerated 2026-04-24 16:29 (≈ **23 h behind**)

**Hinweis:** Stale-Tagging korrekt durch Hook ausgelöst (alle 5 Einträge in `STALE.md` aus session-7da21068). Auflösung via parallele Subagent-Regeneration nach nächstem Commit.

## Spec ↔ Grundlagen Drift (5)

**Schweregrad-Mapping:** critical = > 30 d behind | warn = > 14 d | info = < 14 d.

### CRITICAL (> 30 d behind)

Keine — alle Detail-Specs jünger als 30 Tage gegen Grundlagen-Update.

### WARN (> 14 d behind, > 0 d)

- `specs/ARK_KANDIDATENMASKE_SCHEMA_v1_3.md` (updated 2026-04-16 23:06) → Grundlagen v1.5/v2.7/v1.12/v1.4 (2026-04-25 13:36–13:38) → **drift ~9 d (info)**, aber Spec-`Quellen:` referenziert noch v1.3/v2.5/v1.10 → **STALE-SOURCE-DRIFT** (warn)
- `specs/ARK_ACCOUNT_DETAILMASKE_SCHEMA_v0_2.md` (updated 2026-04-16 14:27) → identisches Muster: Quellen referenzieren v1.3/v2.5/v1.10, aktuelle Grundlagen-Versionen v1.5/v2.7/v1.12 → **STALE-SOURCE-DRIFT**
- `specs/ARK_MANDAT_DETAILMASKE_SCHEMA_v0_2.md` (updated 2026-04-16 14:28) → STALE-SOURCE-DRIFT (Quellen v1.3, aktuell v1.5)
- `specs/ARK_FIRMENGRUPPE_DETAILMASKE_SCHEMA_v0_1.md` (updated 2026-04-16 14:28) → STALE-SOURCE-DRIFT
- `specs/ARK_JOB_DETAILMASKE_SCHEMA_v0_1.md` (updated 2026-04-16 14:29) → STALE-SOURCE-DRIFT

**Befund:** Die 9 Entity-Detailmasken-Specs zeigen alle dieselbe Stale-Source-Referenz auf v1.3-Grundlagen-Stände, obwohl Grundlagen seit 2026-04-19 (Zeit), 2026-04-21 (Billing), 2026-04-24 (E-Learning) und 2026-04-25 (HR) auf v1.5/v2.7/v1.12/v1.4 weiter sind. Da diese Erweiterungen rein additiv waren (TEIL L/M/N/O/P, §90–§96), gibt es **keinen inhaltlichen Drift in Entity-Detail-Texten** — aber Source-Frontmatter ist veraltet. Die 9 Specs sind sachlich noch korrekt; nur die Versions-Anker müssten in einem Sammel-Refresh-Pass auf v1.5/v2.7/v1.12/v1.4 gehoben werden.

### INFO (< 14 d behind)

- `specs/ARK_PROZESS_DETAILMASKE_SCHEMA_v0_1.md` (2026-04-16 22:45) — info (~9 d, additiv kompatibel)
- `specs/ARK_ASSESSMENT_DETAILMASKE_SCHEMA_v0_3.md` (2026-04-17 14:00) — info
- `specs/ARK_SCRAPER_MODUL_SCHEMA_v0_1.md` (2026-04-17 18:36) — info
- `specs/ARK_PROJEKT_DETAILMASKE_SCHEMA_v0_2.md` (2026-04-16 16:08) — info
- `specs/ARK_HR_TOOL_SCHEMA_v0_1.md` (2026-04-25 11:32) — synchron, Source-of-Truth des HR-Sync 13:36–13:38
- `specs/ARK_HR_TOOL_SCHEMA_PATCH_v0_1_to_v0_2.md` (2026-04-25 14:03) — **NEW PATCH, noch nicht in HR-Tool-Schema v0.2 promoviert**
- `specs/ARK_PERFORMANCE_TOOL_SCHEMA_v0_1.md` (2026-04-25 13:45) — synchron, Source-of-Truth des Performance-Specs
- `specs/ARK_PERFORMANCE_TOOL_INTERACTIONS_v0_1.md` (2026-04-25 13:48) — synchron

## Performance-Modul Spec-Sync-Status

**KRITISCHE LÜCKE:** Die 4 Performance-Patches (alle 2026-04-25 13:45–14:09 erstellt) sind **NICHT in den 5 Grundlagen-MDs** eingearbeitet. Die 11 Performance-Mockups sind committet (commits ad5e81b … ed8dc6a + 08128ae), aber Grundlagen-Welt kennt das Performance-Modul noch nicht.

| Patch | Datum | Source-Spec | Ziel-Grundlage | Status |
|-------|-------|-------------|----------------|--------|
| `ARK_STAMMDATEN_PATCH_v1_5_to_v1_6_performance.md` | 13:52 | Performance-Spec | `ARK_STAMMDATEN_EXPORT_v1_5.md` → v1.6 | **NICHT GEMERGED** |
| `ARK_DATABASE_SCHEMA_PATCH_v1_5_to_v1_6_performance.md` | 14:06 | Performance-Spec | `ARK_DATABASE_SCHEMA_v1_5.md` → v1.6 | **NICHT GEMERGED** |
| `ARK_BACKEND_ARCHITECTURE_PATCH_v2_7_to_v2_8_performance.md` | 14:09 | Performance-Spec | `ARK_BACKEND_ARCHITECTURE_v2_7.md` → v2.8 | **NICHT GEMERGED** |
| `ARK_HR_TOOL_SCHEMA_PATCH_v0_1_to_v0_2.md` | 14:03 | HR-Tool-Spec (Performance-Tap-Cross-Reference) | `specs/ARK_HR_TOOL_SCHEMA_v0_1.md` → v0.2 | **NICHT GEMERGED** |

**Verifizierungs-Grep:** `grep -c "TEIL Q\|Performance-Modul" "Grundlagen MD/"*.md` → **0/0/0/0/0** — keine einzige Grundlage erwähnt das Performance-Modul.

### Frontend-Freeze + Gesamtsystem-Übersicht

- `ARK_FRONTEND_FREEZE_v1_12.md` (v1.12, 2026-04-25 13:38) — kein Performance-§ vorhanden. **Kein Performance-Patch existiert** für Frontend-Freeze (sollte ergänzt werden: 11 Performance-Page-Templates + Sub-Tab-Hub-Pattern + Coverage-SVG-Map-Component).
- `ARK_GESAMTSYSTEM_UEBERSICHT_v1_4.md` (v1.4, 2026-04-25 13:38) — kein Performance-TEIL. **Kein Performance-Patch existiert** für Gesamtsystem (sollte ergänzt werden: TEIL 26 Performance-Modul · Cross-Modul-Analytics-Hub · Cube-Schema · Anomaly-Engine).

### Spec-Sync-Regel.md

`wiki/meta/spec-sync-regel.md` listet aktuell 4 Tool-Masken (Dok-Generator, Email-Kalender, Reminders, Dashboard-Templates-Editor). **Performance-Tool ist nicht eingetragen** — sollte als 5. Tool-Maske unter "Tool-Masken" ergänzt werden mit Verweis auf:
- `specs/ARK_PERFORMANCE_TOOL_SCHEMA_v0_1.md`
- `specs/ARK_PERFORMANCE_TOOL_INTERACTIONS_v0_1.md`
- `specs/ARK_PERFORMANCE_TOOL_MOCKUP_PLAN.md`

## Mockup Drift (4)

Quick-Component-Drift-Check der 11 Performance-Mockups (alle dated 2026-04-25 15:43–20:55):

### performance.html (Hub-Shell, 2026-04-25 20:22)

- ✓ editorial.css verlinkt
- ✗ Kein 540px-Drawer (akzeptabel — Hub-Shell ist Tab-Router, kein CRUD)
- ✓ Keine Snapshot-Bar nötig (Tool-Maske, nicht Entity-Detailmaske)
- ✓ Keine App-Bar
- **No drift.**

### performance-dashboard.html (2026-04-25 15:43)

- ✓ editorial.css verlinkt (2×)
- ✗ **App-Bar HTML-Block vorhanden** (`<div class="app-bar">` Zeilen 713/732) — Drift gegen Sub-Page-Konvention (App-Bar nur in Hub-Shell `performance.html`, Sub-Pages sollen iframe-embedded ohne App-Bar laufen)
- ✓ `body.in-iframe .app-bar { display: none; }` definiert (Zeile 103) — App-Bar wird im Embed-Modus versteckt, daher praktisch konform, aber redundant ggü. den 9 anderen Sub-Pages, die keinen App-Bar-Block haben
- ✓ 0 Drawer-540px (Dashboard ohne CRUD-Drawer ist OK)

**Empfehlung:** App-Bar-Block aus `performance-dashboard.html` entfernen für Konsistenz mit `performance-insights.html`/`-funnel.html`/etc., oder begründen warum Dashboard als einzige Sub-Page einen App-Bar-Block hält.

### performance-coverage.html (2026-04-25 20:55) — UMLAUT-DRIFT

- ✗ Zeile 723: `Datenbasis: Bundesamt fuer Statistik (BFS), GEOSTAT.` → `für`
- ✗ Zeile 1204: SVG-Text-Embed mit `prufen` (im SVG-String) → `prüfen`
- **Recurrent violation** — 6× im Lint-Log seit 18:24 (`session-53f982ef`/`session-cb6f69fa`)

### performance-mitarbeiter.html (2026-04-25 18:12) — UMLAUT-DRIFT

- ✗ Zeile 197: `.ueber-grid {` (CSS-Klasse — könnte als JS-Identifier-Ausnahme durchgehen, aber Konvention `.uebersicht-grid` oder besser `.overview-grid`)
- ✗ Zeile 743: `<button data-tab="ueber">Übersicht</button>` (data-tab-Wert) — User-sichtbarer Text korrekt mit Umlaut, aber data-tab-Identifier ist trivialer Substitut
- ✗ Zeile 752: `<section class="ueber-grid">`
- **Recurrent violation** — 4× im Lint-Log seit 18:04

### performance-business.html (2026-04-25 19:42) + performance-team.html (2026-04-25 19:24)

- ✓ Beide editorial.css + 540px-Drawer + ohne App-Bar — clean
- ⚠ data-tab="uebersicht" als JS-Identifier (kein Lint-Hook-Match, da Substring `uebersicht` nicht als ae/oe/ue erkannt wird; reine Konvention)

### Stammdaten-Konformität (alle 11 Performance-Mockups)

- ✓ Sparten-Chips ARC/GT/ING/PUR/REM (verifiziert in performance-coverage.html, performance-business.html)
- ✓ Mitarbeiter-Kürzel als 2-Buchstaben-Codes (PW/JV/LR/MF) durchgängig
- ✓ Snapshot-Bar nicht erforderlich (Tool-Masken-Pattern)

### DB-Tech in performance-admin.html

- Zeile 486: `<code>fact_metric_snapshot_*</code>` — Admin-Sektion, OK
- Zeile 593: `derived from fact_perf_goal` — Admin-Sektion, OK
- Zeile 1035: `FROM fact_perf_forecast_q` — Admin-SQL-Block, OK
- ⚠ **Sollten mit `<!-- ark-lint-skip:begin reason=admin-saga-preview -->` umschlossen werden**, sonst wird der ark-lint-Hook diese als DB-TECH-Violations flaggen, sobald jemand den Hook drüberlaufen lässt.

## Lint-Violations letzte 7 Tage (43 distinct violations)

### Nach Datei (top-5)

| Datei | Anzahl | Typen |
|-------|--------|-------|
| `performance-coverage.html` | 11 | UMLAUT (recurrent — `fuer`, `prufen`) |
| `performance-mitarbeiter.html` | 12 | UMLAUT (`ueber*` als CSS/data-tab Identifier) |
| `zeit-monat.html` | 7 | DRAWER-DEFAULT (3 Modal-Patterns gefunden) |
| `commission-admin.html` / `commission-team.html` | 8 | UMLAUT (`kuerzel` als JS-Variable) |
| `billing-mahnwesen.html` | 6 | DRAWER-DEFAULT (5 Modal-Patterns gefunden) |

### Nach Typ

- **UMLAUT** (~30 violations) — am häufigsten in JS-Identifier/CSS-Klassen-Kontext (`kuerzel`, `ueber`, `verfuegbar`, `fuer`)
- **DRAWER-DEFAULT** (~10 violations) — `zeit-monat.html`, `billing-mahnwesen.html`, `elearn-freitext-queue.html` mit Modal-für-CRUD
- **DB-TECH** (3 violations, alle in `zeit-meine-zeit.html` Zeile 402: `fact_time_entry erstellt`)
- **SNAKE-CASE** (1 violation, `elearn-admin-curriculum.html`: `fact_*-Identifier in User-Text`)

### Recurrent (≥ 3× geloggt)

- `performance-coverage.html` Zeile 723 `fuer` — 6× seit 18:24 ungelöst
- `performance-mitarbeiter.html` Zeilen 197/743/752 `ueber` — 4× seit 18:04 ungelöst
- `zeit-monat.html` 3-Modal-Pattern — 5× seit 2026-04-20 ungelöst
- `billing-mahnwesen.html` 5-Modal-Pattern — 5× seit 2026-04-21 ungelöst

## Empfehlungen (priorisiert)

1. **CRITICAL — Performance-Patches in Grundlagen einarbeiten.** Die 4 Patches (STAMMDATEN, DB, BACKEND, HR-Patch) liegen seit 2026-04-25 14:09 erstellt, aber unmerged. Folge: 0 Performance-Referenzen in Grundlagen, Spec-Sync-Regel kennt das Modul nicht, wer auf Grundlagen schaut, sieht das Modul nicht. **Aktion:** Sync-Session anstossen — TEIL Q (DB), TEIL R (Backend), §97 (Stammdaten), TEIL S (Frontend-Freeze) und TEIL 26 (Gesamtsystem) appenden, danach 5 Digests regenerieren. Erwarteter Aufwand: 60–90 min via parallele Subagents.

2. **HIGH — Frontend-Freeze + Gesamtsystem Performance-Patches erstellen.** Aktuell existieren nur 3 Patches (STAMMDATEN/DB/BACKEND) — Frontend-Freeze und Gesamtsystem haben keinen Performance-Patch-File. **Aktion:** `ARK_FRONTEND_FREEZE_PATCH_v1_12_to_v1_13_performance.md` und `ARK_GESAMTSYSTEM_PATCH_v1_4_to_v1_5_performance.md` erstellen analog zu Billing/E-Learning-Patch-Mustern.

3. **HIGH — Performance-Tool in `wiki/meta/spec-sync-regel.md` als 5. Tool-Maske registrieren.** Aktuell nur 4 Tool-Masken gelistet, Performance-Tool fehlt komplett. Quick-Win, < 5 min.

4. **HIGH — `performance-coverage.html` UMLAUT-Fix.** Zeile 723 `fuer` → `für` und Zeile 1204 SVG-Text `prufen` → `prüfen` patchen. Wird seit 6 Lint-Runs gemeldet.

5. **MEDIUM — `performance-mitarbeiter.html` `.ueber-grid` umbenennen.** Entweder `.uebersicht-grid` (umlaut-konform) oder `.overview-grid` (englisch). data-tab-Wert ebenfalls anpassen. Oder Skip-Marker setzen.

6. **MEDIUM — `performance-dashboard.html` App-Bar-Block entfernen** (Konsistenz mit anderen Sub-Pages) oder im Frontend-Freeze-Patch begründen, warum Dashboard als einzige Sub-Page einen App-Bar-Block hat.

7. **MEDIUM — `performance-admin.html` DB-Tech-Skip-Marker einsetzen** (Zeilen 486/593/1035) — vor nächstem ark-lint-Run, sonst werden 3 Violations geloggt.

8. **MEDIUM — Stale-Source-Frontmatter in 9 Entity-Detailmasken-Specs refreshen.** Sammel-Pass: `Quellen: ARK_STAMMDATEN_EXPORT_v1_3.md` → `_v1_5.md`, `_v2_5.md` → `_v2_7.md`, `_v1_10.md` → `_v1_12.md`, `_v1_3.md` (Gesamt) → `_v1_4.md`. Kein inhaltlicher Drift, nur Versions-Anker.

9. **MEDIUM — 5 Digests regenerieren.** Nach Performance-Patches-Merge (Empfehlung 1) ohnehin nötig — daher zusammen erledigen, nicht zweimal.

10. **LOW — `zeit-monat.html` + `billing-mahnwesen.html` Modal→Drawer-Refactor** (CLAUDE.md Drawer-Default-Regel). 8 Violations seit 2026-04-20/21 offen.

11. **LOW — HR-Tool-Schema v0.2 aus Patch promovieren.** `ARK_HR_TOOL_SCHEMA_PATCH_v0_1_to_v0_2.md` (2026-04-25 14:03) existiert, aber `ARK_HR_TOOL_SCHEMA_v0_2.md` noch nicht erstellt.

## Related

- [[STALE]]
- [[grundlagen-changelog]]
- [[lint-violations]]
- [[spec-sync-regel]]
- [[mockup-baseline]]
