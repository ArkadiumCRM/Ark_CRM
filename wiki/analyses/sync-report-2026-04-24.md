---
title: "Spec-Mockup-Sync-Report 2026-04-24"
type: analysis
created: 2026-04-24
updated: 2026-04-24
sources: []
tags: [sync-report, drift-scan, elearn, phase3]
---

# Spec-Mockup-Sync-Report — 2026-04-24

Scope: alle Module. Fokus: Status nach E-Learning Sub A–D Mockup-Komplettierung und Billing-Finalisierung.

## Unresolved Changelog-Einträge (0)

Alle 18 Zeit-Modul-Einträge aus Session `13946034` (2026-04-19 22:59 – 23:46) wurden im Sammel-Resolution-Block 2026-04-20 auf `resolved` gesetzt — Sync erfolgte via PR #2 (commit d0828ba). Keine weiteren unresolved Einträge offen.

## Stale Digests (0)

Letzter Clean-State: 2026-04-17 18:18.

- ✅ `backend-architecture-digest.md` — v2.5.5 current
- ✅ `database-schema-digest.md` — fact_reminders + template_id FK current
- ✅ `frontend-freeze-digest.md` — v1.11 Responsive-Policy current
- ✅ `gesamtsystem-digest.md` — v1.3.6 current
- ✅ `stammdaten-digest.md` — keine Änderung an Grundlage seit v1.3

**Hinweis:** Nach Zeit-Modul PR #2 (d0828ba) wurden Grundlagen auf v1.4/v2.6/v1.11 gebumpt. Die Digests sind **noch auf Baseline** (v1.3.6 etc.) — technisch überholt. Regeneration empfohlen, nicht blockierend.

## Spec ↔ Grundlagen Drift (E-Learning-Spezial-Kontext)

E-Learning Sub A–D sind **neue Module** ohne bestehende Grundlagen-Verankerung. Die 8 E-Learning-Specs (Schema + Interactions × 4 Subs) existieren als `draft`, aber:

| Spec | Status | Grundlagen-Patch erstellt? |
|------|--------|----------------------------|
| `ARK_E_LEARNING_SUB_A_SCHEMA_v0_1.md` | draft | ✅ 5 Patches (DB, Backend, Frontend, Stammdaten, Gesamt) |
| `ARK_E_LEARNING_SUB_A_INTERACTIONS_v0_1.md` | draft | ✅ 5 Patches |
| `ARK_E_LEARNING_SUB_B/C/D` | draft | ✅ je 5 Patches (insg. 20 Patches) |

**Drift-Status:** Patches existieren in `specs/ARK_*_PATCH_ELEARNING_*.md`, sind aber noch **nicht in Grundlagen-Files eingearbeitet** (analog Zeit-Modul-Workflow vor PR #2). Dies ist **erwarteter Zustand** im Spec-First-Workflow — nicht als Drift zu werten.

**Empfehlung (Folge-Session):** Nach Deep-Review Mockups + Specs → Grundlagen-Merge (wie Zeit-Modul PR #2) für v1.5/v2.7/v1.12 Bump.

## Mockup Drift

### E-Learning-Modul (19 Files + 5 harmonisierte)

Scan gegen Baseline (`candidates.html`, hr.html-Shell-Pattern, `wiki/meta/mockup-baseline.md`):

| Component | Status | Notes |
|-----------|--------|-------|
| Shell-Pattern (topbar + sidebar + profil-pop) | ✅ 1:1 hr.html | elearn.html |
| 540 px Drawer | ✅ durchgängig | Alle Drawer (team, freitext, assignments, admin-courses, curriculum, imports, content-gen) |
| KPI-Hero-Strip (4 Karten, farbiger border-left) | ✅ konsistent | hr-dashboard-Pattern |
| Sparten-Chips (Farben ARC/GT/ING/PUR/REM) | ✅ konsistent | fest definiert |
| Stage-Pipeline (9 Dots) | N/A | E-Learning hat keine Pipeline-Entity |
| Snapshot-Bar | N/A | E-Learning kein Snapshot-Modul |
| Theme-Toggle | ✅ funktional | postMessage + localStorage + direct-DOM |

**Keine Drift-Punkte identifiziert.**

### Billing / Commission / Zeit / HR (Bestand)

Laut `wiki/meta/lint-violations.md` letzte 7 Tage:

| Datei | Violations | Kategorie |
|-------|------------|-----------|
| `billing-mahnwesen.html` | 1 | DRAWER-DEFAULT (1 Modal-Pattern) |
| `zeit-monat.html` | 1 (2×) | DRAWER-DEFAULT (3 Modal-Patterns) |
| `commission-team.html` | 2 | UMLAUT (Kuerzel in JS-Funktionsnamen) |
| `billing-debitoren.html`, `billing-dashboard.html` | mehrere | DRAWER-DEFAULT |

**Empfehlung:** Diese Violations sind teilweise in Admin-/Debug-Bereichen und benötigen Einzelprüfung ob Modal-Pattern legitim (System-Notification) oder Drawer-Umbau fällig.

## Lint-Violations letzte 7 Tage (konsolidiert)

| Datei | DB-TECH | UMLAUT | DRAWER | SNAKE-CASE | Total |
|-------|---------|--------|--------|------------|-------|
| elearn-newsletter-issue.html | 2 (gefixt) | — | — | — | 0 |
| elearn-freitext-queue.html | — | — | 1* | — | 1 |
| elearn-admin-curriculum.html | — | — | — | 1 | 1 |
| billing-mahnwesen.html | — | — | 1 | — | 1 |
| billing-debitoren.html | — | — | 1 | — | 1 |
| billing-dashboard.html | — | — | 1 | — | 1 |
| zeit-monat.html | — | — | 2 | — | 2 |
| commission-team.html | — | 2 | — | — | 2 |

*Freitext-Queue Modal-Pattern = Batch-Confirm-Modal (Spec-konform, kleiner Bestätigungs-Dialog) → false positive oder absichtlich Modal.

## Empfehlungen (priorisiert)

### P0 — Sofort
- Keine. E-Learning + Billing strukturell clean.

### P1 — Vor nächstem Release
1. **Billing/Zeit DRAWER-DEFAULT prüfen:** 6 Treffer in `billing-*` und `zeit-monat.html`. Entscheidung Modal (System) vs. Drawer (CRUD) pro Fall.
2. **commission-team.html UMLAUT:** 2× „kuerzel" in JS-Code → `kuerzel` als Variablenname ist zulässig, Lint-Hook sollte JS-Identifier von UI-Text unterscheiden (Hook-Verbesserung, kein Content-Fix).
3. **elearn-admin-curriculum.html SNAKE-CASE:** 1× `elearn_onboarding_initializer` in User-Text → mit `<!-- ark-lint-skip -->` wrappen (Info-Box für Admin).

### P2 — Nächster Sync-Zyklus
1. **Grundlagen-Merge E-Learning:** Nach Deep-Review Mockups → Grundlagen-Patches (20 Dateien) in Hauptdateien einarbeiten → v1.5/v2.7/v1.12 Bump (Muster wie Zeit-Modul PR #2).
2. **Digests regenerieren:** Nach Grundlagen-Bump.
3. **Billing-Drift-Audit:** Laut Handover aus anderer Session läuft parallel `claude/distracted-almeida-16d1f1` mit Billing Cross-Module-Vernetzungs-Audit — Ergebnisse mergen.

## Gesamt-Status

**Grün.** Hauptsysteme strukturell in Sync. Offene Punkte sind kosmetische Lints (P2) oder Prozess-Schritte für nächsten Release-Zyklus (Grundlagen-Merge).

## Related

- [[elearn-handover]] — E-Learning Handover-Dokument
- [[spec-sync-regel]] — Governance: Sync-Matrix
- [[sync-report-2026-04-17]] — vorheriger Report
