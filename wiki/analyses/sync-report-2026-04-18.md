---
title: "Spec-Mockup-Sync-Report — 2026-04-18"
type: analysis
created: 2026-04-18
updated: 2026-04-18
sources: [
  "wiki/meta/digests/STALE.md",
  "wiki/meta/grundlagen-changelog.md",
  "wiki/meta/lint-violations.md",
  "wiki/meta/spec-sync-regel.md",
  "wiki/meta/autorefine-log.md"
]
tags: [sync-report, drift, audit, post-autorefine]
---

# Spec-Mockup-Sync-Report — 2026-04-18

Ausgelöst durch `/ark-sync-report` nach Abschluss autorefine-Session (20 Runs, 11 Nachbearbeitungs-Punkte + 3 Peter-Entscheidungen + 2 Follow-ups + 2 P2-Punkte + Lint-Fix). Drift-Analyse über alle drei Layer.

## 1. Unresolved Changelog-Einträge · 0

`wiki/meta/grundlagen-changelog.md` enthält 35 Einträge, alle **resolved**. Letzter offener Eintrag: keiner. Der letzte grosse Sync-Durchgang war 2026-04-17 (Mobile/Tablet-Support v1.3.6).

## 2. Stale Digests · 0

`wiki/meta/digests/STALE.md` zeigt alle 5 Digests **current** (letzter Clean 2026-04-17 18:18):

- `backend-architecture-digest.md` — v2.5.5 (2026-04-17 16:35)
- `database-schema-digest.md` — fact_reminders + template_id FK (2026-04-17 16:35)
- `frontend-freeze-digest.md` — §24b Responsive-Policy v1.11 rewrite (2026-04-17 18:10)
- `gesamtsystem-digest.md` — v1.3.5 → v1.3.6 (2026-04-17 18:12)
- `stammdaten-digest.md` — unverändert seit v1.3-Baseline

**Git-Check:** `Grundlagen MD/*.md` hat seit worktree-create (2026-04-18 20:05) **0 Edits**. Keine neue Staleness entstanden.

## 3. Spec ↔ Grundlagen Drift · 0

Seit 2026-04-18 20:05 wurde **keine** Grundlagen-Datei editiert. Damit kein "Grundlagen-Update → Spec lags hinterher"-Drift-Vektor aktiv.

**Umgekehrter Vektor (Spec-Update → Grundlagen-Nachzug nötig?):**

| Spec-Edit heute | Grundlagen-Auswirkung | Status |
|----------------|----------------------|--------|
| Mandat-Schema §1 + Job-Schema §2: `linked_project_id` FK | DB-Schema v1.3 L63 + L75 hat FK bereits (Phase 1.5 dokumentiert) | ✓ konform |
| Account-Schema §19 + Interactions TEIL 14: bedingter Tab Projekte | Nutzt `fact_projects.*` + `fact_project_company_participations.*`, existieren in DB-Schema v1.3 §18–25 | ✓ konform |
| Account-Interactions: Order-Status `invoiced` raus | DB-Schema v1.3 §14.3 ENUM-Fix bereits dokumentiert | ✓ konform |
| Account-Schema §12 Tab 8: Credits-Übersicht-Banner | UI-Pattern only, keine Schema-Änderung | ✓ konform |
| Mandat-Schema §6b + Interactions: Inline-Expand-Pattern | UI-Pattern; Frontend-Freeze §24b Inline-Pattern-Section **könnte** Update profitieren (optional) | ⚠️ P3-Follow-up |
| Mandat-Interactions TEIL 10: Vorstellungs-Markierung Drawer | UI-Pattern; `fact_candidate_presentation`-Insert bleibt wie dokumentiert | ✓ konform |
| Prozess-Schema §3: Breadcrumb auf Account-rooted DE | UI-Pattern only | ✓ konform |
| Kandidaten-Interactions §Assessment-Versionierung: Filter/Suche-Panel | API-Query-Params `q`, `account`, `date_from`, `date_to` — **kein neuer Endpoint**, nur Erweiterung der existierenden `GET /api/v1/candidates/:id/assessment-versions` | ⚠️ Backend-Architecture § Endpoint-Doku **könnte** Query-Param-Liste expliziter dokumentieren (optional) |

**Fazit Drift:** 0 harte Drift. 2 optionale P3-Follow-ups (Frontend-Freeze Pattern-Erweiterung, Backend-Architecture Query-Param-Doku) — nicht blockierend.

## 4. Mockup Drift · 0

Einzige Mockup-Änderung heute: `mockups/accounts.html` (Tab-15 Projekte hinzugefügt, 7.3KB diff).

**Shared-Component-Check:**

| Component | Reference | accounts.html Tab-15 | Status |
|-----------|-----------|----------------------|--------|
| Tab-Nav-Pattern `.tab.conditional` | accounts.html Tab-14 Firmengruppe (L224) | L225 `data-tab="15"` mit `.conditional` + `title`-Tooltip | ✓ identisch |
| KPI-Strip-Layout | groups.html + accounts.html Tab-14 (`.kpi-strip cols-5`) | `<div class="kpi-strip cols-5">` mit 5 KPI-Cards | ✓ identisch |
| Chip-Row Filter-Pattern | candidates.html + mandates.html | Filter-Chip-Row mit Divider | ✓ identisch |
| Data-Table-Pattern | Baseline §3 | `<table class="data-table">` mit standard Spalten + `.row-icon-btn` | ✓ identisch |
| Drawer-Width 540px | Baseline §5 | Kein Drawer im Tab-Panel (Read-only). Drawer-Trigger via "🏗 Projekt verknüpfen" verweist auf Interactions-Spec TEIL 14 (dort 540px dokumentiert) | ✓ konform |
| Stage-Pipeline 9-Dot | Nicht anwendbar im Projekte-Tab | — | n/a |

**Post-Lint-Fix:** Enum-Werte (`Ausschreibung`, `Fachplaner`, etc.) matchen `fact_projects.status` + `fact_project_company_participations.role` Enums aus Projekt-Schema v0.2 §13. Siehe autorefine-log Run 20.

## 5. Lint-Violations letzte 7 Tage · 101 Einträge

Breakdown pro Datei (Tally aus `wiki/meta/lint-violations.md` §2026-04-1[5-8]):

| Datei | Violations | Haupt-Regel |
|-------|-----------|-------------|
| `mockups/admin-mobile.html` | ~35 | SNAKE-CASE (`feature_ai_briefing`, `schutzfrist_warn_vorlauf_tage`, `interview_scheduled`, `prozess_no_activity_14d`, `feature_matching_v2`, `feature_hr_tool`) |
| `mockups/admin.html` | ~28 | SNAKE-CASE + DB-TECH (gleiche Feature-Flags + Trigger-Strings) |
| `mockups/reminders.html` | ~8 | SNAKE-CASE Reminder-Template-Keys (`rt_01`, `start_date − 7d`, `placed_at`) |
| `log.md` | 5 | UMLAUT (`Kürzel`, `für`, `über`, `könn`) in Session-Notes |
| Andere (specs/, wiki/) | ~25 | MIXED |

**Aus meiner autorefine-Session 2026-04-18 (ab 21:20):** 0 neue Lint-Einträge gefunden. Hook könnte während Session nicht getriggert haben; mein `/ark-lint`-Run in Auto-Mode fand 4 Stammdaten-Violations, die in Run 20 (Commit `bec1ee9`) gefixt wurden.

**Top-Themen:**
1. `admin-mobile.html` + `admin.html` zeigen Feature-Flags als snake_case in User-Text. Fix: kanonische Labels aus Baseline §16.3 einsetzen (z.B. `feature_ai_briefing` → "AI Briefing-Transkription").
2. `reminders.html` zeigt Template-Keys (`rt_01`). Fix: Baseline §16.12 Reminder-Typ-Labels.
3. `log.md` UMLAUT-Drift — append-only Historic, niedrige Prio.

## 6. Empfehlungen

### Sofort (nicht nötig — keine P0-Drift)
- Alle Drift-Check-Ergebnisse zeigen **konformen State**. Kein Sofort-Action-Bedarf.

### Nächste Session-Aufräumarbeit
1. **Admin-Mockup SNAKE-CASE Cleanup** (~35 Violations in admin.html + admin-mobile.html): Feature-Flags und Automation-Trigger via Baseline §16.3 / §16.12 kanonisch labeln. Geschätzter Aufwand: ~1h.
2. **Reminders-Mockup rt_*-Keys ersetzen** (~8 Violations): Baseline §16.12 kanonische Labels einsetzen.
3. **P3 Follow-ups aus Run-20-Session**:
   - Frontend-Freeze §24b Inline-Expand-Pattern als offizielle Pattern-Variante ergänzen (Mandat-§6b als Beispiel).
   - Backend-Architecture Endpoint `GET /api/v1/candidates/:id/assessment-versions` mit Query-Param-Liste (q/account/date_from/date_to) expliziter dokumentieren.

### Peter-Manuelle Arbeit (nicht autorefine-able)
- Claim-Rechnung `.docx` Templates im Arkadium-Corporate-Design (Run 15 REVERTED).

## 7. Sync-State Total

| Layer | Status |
|-------|--------|
| Grundlagen-Changelog | ✅ 35 resolved, 0 unresolved |
| Digest-Staleness | ✅ 0 stale |
| Spec ↔ Grundlagen | ✅ 0 harte Drift, 2 optionale P3 |
| Mockup ↔ Baseline | ✅ 0 Drift (post Run 20) |
| Lint-Violations neu heute | ✅ 0 (autorefine-Session clean) |
| Git-Branch | ✅ `claude/nice-turing-f27c27` pushed to origin, 4 Commits ahead of main |

## Related

- [[autorefine-log]] — 20 Runs 2026-04-18
- [[spec-sync-regel]] — Grundsatz
- [[detailseiten-nachbearbeitung]] — 11 Punkte + P2 abgeschlossen
- [[breadcrumbs-konsistenz]] — Run-18-Doku
- [[decisions]] — 3 Peter-Entscheidungen heute integriert
