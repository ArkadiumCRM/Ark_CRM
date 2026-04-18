---
description: Spec-Mockup-Sync-Drift-Report über alle Grundlagen, Specs und Mockups
argument-hint: [--focus=mockups|specs|grundlagen|all]
---

# ARK Spec-Mockup-Sync-Report

Führt Drift-Analyse durch zwischen:
- **5 Grundlagen-Digests** (`wiki/meta/digests/*-digest.md`)
- **9 Detailmasken-Specs** (`specs/ARK_*_SCHEMA_*.md`, `specs/ARK_*_INTERACTIONS_*.md`)
- **Mockups** (`mockups/*.html`)

## Vorgehen

1. Prüfe `wiki/meta/digests/STALE.md` — gibt es geflaggte Digest-Staleness?
2. Prüfe `wiki/meta/grundlagen-changelog.md` — unresolved Einträge?
3. Prüfe `wiki/meta/lint-violations.md` — letzte 50 Violations, pro Datei gruppiert.
4. Lade `wiki/meta/spec-sync-regel.md` (Sync-Matrix Grundlagen ↔ Specs).
5. Für focus-Scope (default=all):
   - **grundlagen:** Liste alle STALE-Digests + welche Specs/Mockups betroffen.
   - **specs:** Gehe durch alle 9 Detailmasken-Specs. Pro Spec: welche Grundlage ist die Quelle? Gibt es Änderungen in der Grundlage seit letztem Spec-Sync?
   - **mockups:** Pro Mockup-Datei: Grep für Shared-Components (Drawer-Width, Stage-Pipeline, Snapshot-Bar). Drift gegen Baseline?
6. Output-Format:

```markdown
# Spec-Mockup-Sync-Report — YYYY-MM-DD

## Unresolved Changelog-Einträge (N)
- ...

## Stale Digests (N)
- digest-name — source Grundlage edited @ YYYY-MM-DD

## Spec ↔ Grundlagen Drift (N)
- SPEC-Datei → Grundlage X hat seit YYYY-MM-DD 3 Änderungen (Abschnitt §Y, §Z, §W) — Spec nicht aktualisiert.

## Mockup Drift (N)
- mockup.html → Component "Stage-Pipeline" weicht von candidates.html ab (line 240).

## Lint-Violations letzte 7 Tage (N)
- mockup.html: 5 DB-TECH, 2 UMLAUT, 1 DRAWER-DEFAULT

## Empfehlungen
1. ...
2. ...
```

7. Schreibe Report nach `wiki/analyses/sync-report-YYYY-MM-DD.md`, update `index.md`, append `log.md`.

## Arguments

- `--focus=mockups` — nur Mockup-Drift gegen Baseline
- `--focus=specs` — nur Spec ↔ Grundlagen Drift
- `--focus=grundlagen` — nur Stale-Digests + Changelog
- `--focus=all` (default) — alle 3

## Beispiele

```
/ark-sync-report
/ark-sync-report --focus=mockups
```
