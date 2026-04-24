---
title: "Spec-Mockup-Sync-Report 2026-04-24"
type: analysis
created: 2026-04-24
updated: 2026-04-24
tags: [sync, drift, report]
---

# Spec-Mockup-Sync-Report — 2026-04-24

## Summary

- Unresolved Changelog: 0
- Stale Digests: 4
- Spec-Grundlagen-Drift: 18
- Mockup-Drift: 19
- Lint-Violations (7d): 525

---

## A · Unresolved Changelog-Einträge (0)

Alle Einträge im grundlagen-changelog.md tragen Status resolved.

Top-5 jüngste resolved Einträge:

| Datum | Grundlage | Sync-Target | Status |
|-------|-----------|-------------|--------|
| 2026-04-20 | ARK_BACKEND_ARCHITECTURE v2.5→v2.6 | ARK_ZEIT_SCHEMA + ARK_ZEIT_INTERACTIONS | resolved |
| 2026-04-20 | ARK_DATABASE_SCHEMA v1.3→v1.4 | Zeit-Modul 15T+4V+9E | resolved |
| 2026-04-20 | ARK_STAMMDATEN_EXPORT v1.3→v1.4 | §90 Zeit-Modul-Stammdaten | resolved |
| 2026-04-17 | ARK_FRONTEND_FREEZE v1.10→v1.11 | 22 Mockups Responsive-Rollout | resolved |
| 2026-04-17 | ARK_FRONTEND_FREEZE →v1.10.5 | ARK_EMAIL_KALENDER Spec + mockup | resolved |

---

## B · Stale Digests (4)

STALE.md Letzter Clean: 2026-04-17 18:18 (vor Zeit-Modul PR #2).
Nach PR #2 (commit d0828ba, 2026-04-20) 4 Grundlagen gebumpt, Digests nicht regeneriert:

| Digest | Digest-Stand | Grundlage | git-mtime | Stale? |
|--------|-------------|-----------|-----------|--------|
| stammdaten-digest.md | 2026-04-17 v1.3.4 | ARK_STAMMDATEN_EXPORT v1.4 | 2026-04-20 19:00 | STALE |
| database-schema-digest.md | 2026-04-17 v1.3.4 | ARK_DATABASE_SCHEMA v1.4 | 2026-04-20 19:00 | STALE |
| backend-architecture-digest.md | 2026-04-17 v2.5.5 | ARK_BACKEND_ARCHITECTURE v2.6 | 2026-04-20 19:00 | STALE |
| frontend-freeze-digest.md | 2026-04-17 v1.10.5 | ARK_FRONTEND_FREEZE v1.11 | 2026-04-20 19:00 | STALE |
| gesamtsystem-digest.md | 2026-04-17 v1.3.5 | ARK_GESAMTSYSTEM v1.3 | 2026-04-18 18:46 | ok |

---

## C · Spec ↔ Grundlagen Drift (18)

Alle 18 Entity-Detailmasken-Specs: git-mtime 2026-04-18 18:46 (commit 9b78d5f E-Learning Phase-3).
4 Grundlagen (STAMMDATEN/DATABASE/BACKEND/FRONTEND): git-mtime 2026-04-20 19:00 (PR #2 Zeit-Modul).

| Spec-File | Spec-Aenderung | Grundlage-Source | Grundlage-Aenderung | Drift |
|-----------|---------------|------------------|---------------------|-------|
| ARK_KANDIDATENMASKE_SCHEMA_v1_3.md | 2026-04-18 | STAMMDATEN/DB/BACKEND/FRONTEND | 2026-04-20 | +1d 0h |
| ARK_KANDIDATENMASKE_INTERACTIONS_v1_3.md | 2026-04-18 | STAMMDATEN/DB/BACKEND/FRONTEND | 2026-04-20 | +1d 0h |
| ARK_ACCOUNT_DETAILMASKE_SCHEMA_v0_2.md | 2026-04-18 | STAMMDATEN/DB/BACKEND/FRONTEND | 2026-04-20 | +1d 0h |
| ARK_ACCOUNT_DETAILMASKE_INTERACTIONS_v0_3.md | 2026-04-18 | STAMMDATEN/DB/BACKEND/FRONTEND | 2026-04-20 | +1d 0h |
| ARK_FIRMENGRUPPE_DETAILMASKE_SCHEMA_v0_1.md | 2026-04-18 | STAMMDATEN/DB/BACKEND/FRONTEND | 2026-04-20 | +1d 0h |
| ARK_FIRMENGRUPPE_DETAILMASKE_INTERACTIONS_v0_1.md | 2026-04-18 | STAMMDATEN/DB/BACKEND/FRONTEND | 2026-04-20 | +1d 0h |
| ARK_MANDAT_DETAILMASKE_SCHEMA_v0_2.md | 2026-04-18 | STAMMDATEN/DB/BACKEND/FRONTEND | 2026-04-20 | +1d 0h |
| ARK_MANDAT_DETAILMASKE_INTERACTIONS_v0_3.md | 2026-04-18 | STAMMDATEN/DB/BACKEND/FRONTEND | 2026-04-20 | +1d 0h |
| ARK_JOB_DETAILMASKE_SCHEMA_v0_1.md | 2026-04-18 | STAMMDATEN/DB/BACKEND/FRONTEND | 2026-04-20 | +1d 0h |
| ARK_JOB_DETAILMASKE_INTERACTIONS_v0_1.md | 2026-04-18 | STAMMDATEN/DB/BACKEND/FRONTEND | 2026-04-20 | +1d 0h |
| ARK_PROZESS_DETAILMASKE_SCHEMA_v0_1.md | 2026-04-18 | STAMMDATEN/DB/BACKEND/FRONTEND | 2026-04-20 | +1d 0h |
| ARK_PROZESS_DETAILMASKE_INTERACTIONS_v0_1.md | 2026-04-18 | STAMMDATEN/DB/BACKEND/FRONTEND | 2026-04-20 | +1d 0h |
| ARK_ASSESSMENT_DETAILMASKE_SCHEMA_v0_3.md | 2026-04-18 | STAMMDATEN/DB/BACKEND/FRONTEND | 2026-04-20 | +1d 0h |
| ARK_ASSESSMENT_DETAILMASKE_INTERACTIONS_v0_3.md | 2026-04-18 | STAMMDATEN/DB/BACKEND/FRONTEND | 2026-04-20 | +1d 0h |
| ARK_SCRAPER_MODUL_SCHEMA_v0_1.md | 2026-04-18 | STAMMDATEN/DB/BACKEND/FRONTEND | 2026-04-20 | +1d 0h |
| ARK_SCRAPER_MODUL_INTERACTIONS_v0_1.md | 2026-04-18 | STAMMDATEN/DB/BACKEND/FRONTEND | 2026-04-20 | +1d 0h |
| ARK_PROJEKT_DETAILMASKE_SCHEMA_v0_2.md | 2026-04-18 | STAMMDATEN/DB/BACKEND/FRONTEND | 2026-04-20 | +1d 0h |
| ARK_PROJEKT_DETAILMASKE_INTERACTIONS_v0_1.md | 2026-04-18 | STAMMDATEN/DB/BACKEND/FRONTEND | 2026-04-20 | +1d 0h |

Kontext: Zeit-Modul loest keine Detailmasken-Kaskade aus (neues eigenstaendiges Modul).
Drift formal vorhanden, inhaltlich unkritisch. Acknowledgment-Notiz empfohlen.

---

## D · Mockup-Drift (19)

### D.1 Drawer-Width

Baseline editorial.css: .drawer { width:540px } korrekt als shared CSS (kein CSS-Custom-Property).
Alle Vollansichten laden editorial.css. ERP billing.html: 540px bestaetigt.
Drift-Hits: 0

### D.2 Tab-Panel-Class (.tab-pane vs .tab-panel) -- 17 Files

| File | Drift | Fix |
|------|-------|-----|
| Vollansichten/accounts.html | .tab-pane | → .tab-panel |
| Vollansichten/admin.html | .tab-pane | → .tab-panel |
| Vollansichten/assessments.html | .tab-pane | → .tab-panel |
| Vollansichten/candidates.html | .tab-pane | → .tab-panel |
| Vollansichten/groups.html | .tab-pane | → .tab-panel |
| Vollansichten/jobs.html | .tab-pane | → .tab-panel |
| Vollansichten/mandates.html | .tab-pane | → .tab-panel |
| Vollansichten/processes.html | .tab-pane | → .tab-panel |
| Vollansichten/projects.html | .tab-pane | → .tab-panel |
| Vollansichten/reminders.html | .tab-pane | → .tab-panel |
| Vollansichten/scraper.html | .tab-pane | → .tab-panel |
| Vollansichten/stammdaten.html | .tab-pane | → .tab-panel |
| ERP Tools/billing/billing-debitoren.html | .tab-pane | → .tab-panel |
| ERP Tools/billing/billing-mahnwesen.html | .tab-pane | → .tab-panel |
| ERP Tools/billing/billing-refunds.html | .tab-pane | → .tab-panel |
| ERP Tools/commission/commission-admin.html | .tab-pane | → .tab-panel |
| ERP Tools/commission/commission-team.html | .tab-pane | → .tab-panel |

### D.3 Topbar Tool-Tabs Reihenfolge -- 2 Files

Soll: CRM - HR - Commission - Zeit - Billing - Performance - E-Learning
Clean: zeit.html / elearn.html / hr.html (alle 7 Tabs inkl. E-Learning korrekt)

| File | Component | Drift | Fix |
|------|-----------|-------|-----|
| ERP Tools/billing/billing.html | Topbar Tool-Tabs | E-Learning-Tab fehlt | Append E-Learning-Link nach Performance |
| ERP Tools/commission/commission.html | Topbar Tool-Tabs | E-Learning-Tab fehlt | dto. |

Vollansichten haben kein tool-tabs-Topbar -- kein Vollansichten-Drift in dieser Kategorie.

---

## E · Lint-Violations letzte 7 Tage (525)

Zeitfenster: 2026-04-17 bis 2026-04-24. Gesamt 525 Violation-Rows.

| Regel | Anzahl |
|-------|--------|
| SNAKE-CASE | 188 |
| UMLAUT | 161 |
| DB-TECH | 116 |
| DRAWER-DEFAULT | 33 |
| ROUTE-TMPL | 6 |
| sonstige | ~21 |
| **Total** | **525** |

| File | UMLAUT | DB-TECH | DRAWER-DEFAULT | SNAKE-CASE | Total |
|------|--------|---------|----------------|------------|-------|
| scraper.html | 13 | -- | -- | 52 | 124 |
| log.md | 59 | -- | -- | -- | 84 |
| stammdaten.html | -- | 30 | -- | 8 | 76 |
| admin-dashboard-templates.html | -- | 1 | 16 | 16 | 57 |
| admin-mobile.html | -- | -- | -- | -- | 36 |
| candidates.html | -- | 18 | -- | -- | 20 |
| processes.html | -- | 19 | -- | -- | 19 |
| commission-admin.html | -- | -- | -- | -- | 14 |
| commission-team.html | 12 | -- | -- | -- | 12 |
| billing-mahnwesen.html | -- | -- | 8 | -- | 8 |

Hinweis: log.md UMLAUT 59 = Artefakt (Hook scannt log.md-Appends, kein User-facing Content).
scraper.html 124 = iterative Sessions, gleiche Violations mehrfach geloggt.

---

## Empfehlungen (priorisiert)

1. [P0] Digests regenerieren -- 4 Digests stale seit Zeit-Modul PR #2 (2026-04-20). Vor naechstem prime-ark: Agent-Task je Digest.
2. [P1] tab-pane → tab-panel Rollout -- sed-Rollout auf 17 Files. Risikoarm.
3. [P1] E-Learning-Tab in billing.html + commission.html -- Copy aus zeit.html Topbar-Block, je 1 Zeile appenden.
4. [P2] Spec-Drift Acknowledgment -- 18 Specs formal vor Zeit-Modul-Grundlagen-Update. Kein Kaskaden-Bedarf. Notiz in spec-sync-regel.md.
5. [P2] scraper.html + admin-dashboard-templates.html Cleanup -- 52 SNAKE-CASE + 16 DRAWER-DEFAULT pruefen ob noch offen.
6. [P3] Lint-Hook Ausnahmen -- log.md + wiki/meta/ vom UMLAUT-Scan ausschliessen (59 false positives).

---

## Related

- [[spec-sync-regel]] -- Sync-Matrix Grundlagen <-> Specs
- [[sync-report-2026-04-17]] -- vorheriger Report
- [[digests/STALE]] -- aktueller Stale-Status
