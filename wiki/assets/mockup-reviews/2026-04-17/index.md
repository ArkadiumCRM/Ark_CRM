---
title: "Mockup-Review 2026-04-17 · Playwright-Capture-Archive"
type: meta
created: 2026-04-17
tags: [archive, mockup-review, playwright, screenshots]
---

# Mockup-Review 2026-04-17

Vollständige visuelle Erfassung aller 18 Mockups während der **DB-Tech-Violation-Fix-Session** (2026-04-17). Captured via Playwright-MCP.

## Kontext

Session-Ziel: Alle Mockups auf DB-Technikdetails-in-UI (CLAUDE.md Regel) prüfen + fixen + Lint-Hook erweitern + Baseline-Vocabulary etablieren.

**Ergebnis:** 129 Violations über 9 Files gefixt. Alle 18 Mockups clean. Siehe [[lint-violations]] Resolution-Blöcke für Edit-Details.

## Inhalt

### `screenshots/` (79 PNG · ~18 MB)

| Prefix | Mockup | Count |
|--------|--------|-------|
| `tab-*`, `drawer-*` | candidates.html (Tabs 1–10 + 9 Drawer) | ~20 |
| `acc-tab-*`, `acc-drawer-*` | accounts.html (14 Tabs + 12 Drawer) | ~26 |
| `mand-tab-*`, `mand-drawer-*` | mandates.html (7 Tabs + 5 Drawer) | ~12 |
| `grp-tab-*` | groups.html (7 Tabs) | 7 |
| `job-tab-*` | jobs.html (7 Tabs) | 7 |
| `proj-tab-*` | projects.html (6 Tabs) | 6 |
| `verify-*` | Post-Fix-Verification | 1 |
| `accounts-initial.png`, `candidates-initial.png` | Ausgangszustand vor Fixes | — |

### `snapshots/` (71 YAML + 8 Log · ~3 MB)

- `page-YYYY-MM-DD.yml` — Playwright accessibility-tree snapshots (DOM-Struktur, Refs für Interaktionen)
- `console-*.log` — Browser-Console-Messages während der Interaktion
- `candidates-snapshot.yml` — manueller Named-Snapshot

## Verwendung

Diese Artefakte sind **read-only Review-History**. Für laufende Arbeit nutze:

- [Lint-Hook](../../../.claude/hooks/ark-lint.ps1) — automatische Regression-Prävention
- [[mockup-baseline]] §16 — kanonisches UI-Label-Vocabulary
- [[lint-violations]] — Resolution-Historie pro Mockup

Kein Verweis aus produktiven Mockups/Specs hierher nötig.

## Cleanup-Hinweis

Archivgrösse: ~21 MB. Falls nicht mehr benötigt, kompletter Ordner löschbar ohne funktionalen Impact (Hook + Baseline.md sind die durable Artefakte).
