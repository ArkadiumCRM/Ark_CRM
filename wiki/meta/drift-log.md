---
title: "Weekly Drift Log"
type: meta
created: 2026-04-20
updated: 2026-04-20
tags: [meta, drift, weekly-scan]
---

# Weekly Drift Log

Automatisch befüllt durch den Weekly Drift Scanner (montags 09:00 Europe/Zurich).

---

## [2026-04-28] Resolution · ERP-Specs-Verzeichnis

✅ **RESOLVED** Action Item #3 [2026-04-20]: ERP-Specs-Verzeichnis-Konsolidierung.

- 19 Spec-Files via `git mv` von `ERP Tools/specs/` → `specs/` migriert
- 2 Konflikt-Files gelöscht (`ARK_HR_TOOL_INTERACTIONS_v0_1.md` Legacy + `ARK_HR_TOOL_SCHEMA_v0_1.md` durch Patch-File ersetzt)
- 14 Cross-Ref-Files mit Pfad-Update (`ERP Tools/specs/` → `specs/`)
- `ERP Tools/specs/` Verzeichnis entfernt (leer)
- Backup: `backups/erp-tools-specs.2026-04-28-1858/` (21 Files)

**Begründung:** CLAUDE.md-Pattern erwartet `specs/ARK_*_SCHEMA_v*.md` als kanonischen Pfad. Single-Directory vereinfacht Spec-Sync-Hook. Phase-Trennung über Filename-Prefix (`ARK_HR_*`, `ARK_BILLING_*`, `ARK_ZEITERFASSUNG_*`).

**Offen aus [2026-04-20] Action Items:** #2 ERP-Tools-Lint-Pass.

---

## [2026-04-30] Resolution · ERP-Tools-Lint-Pass (51 Files)

✅ **RESOLVED** Action Item #2 [2026-04-20]: ERP-Tools-Lint-Pass.

🎯 **ALLE Action Items aus [2026-04-20] Weekly Drift Scan jetzt RESOLVED** (#1, #2, #3, #4, #5).

**Find:** Subagent (general-purpose mit Sonnet) auditierte 51 Files in `mockups/ERP Tools/{billing,commission,elearn,hr,zeit}/` (deutlich mehr als drift-log-Schätzung 16 — die ERP-Tools sind seit 2026-04-20 stark gewachsen).

**Erkenntnis:** ERP-Tools-Mockups waren weitgehend lint-clean:
- **0 Umlaute-Substitutes** (alle 51 Files verwenden bereits echte Umlaute)
- **4 DB-Tech-Hits** (gefixt mit ark-lint-skip Wraps für Admin/Spec-Ref-Context)
- **21 Snake-Case-Hits** (alle legitimate Admin/Spec-Ref Context · gewrappt)

**Fixes:**
| File | Change |
|------|--------|
| commission-admin.html | `paid_abschlag` → `Ausgezahlt · Rücklage` (SAFE-FIX User-Label) |
| elearn-admin-imports.html | ark-lint-skip wrap auf Event-Namen-Drawer |
| zeit-admin.html | ark-lint-skip wrap auf Scanner-Access-Audit-Table |
| zeit-meine-zeit.html | JS-audit-Array `/* ark-lint-skip */` wrap |
| hr-onboarding-editor.html | 2× ark-lint-skip wraps (Phase-Blocks + Template-Editor Module-IDs) |

**Billing (9 Files): komplett clean ohne jeden Fix nötig.**

**Cumulative-Violations-Counter-Erklärung:** Die 188 SNAKE-CASE + 161 UMLAUT in `lint-violations.md` waren vermutlich History aus Performance-Mockup-Build (2026-04-25/26) und bereits-resolved Cases. ERP-Tools-Mockups selbst sind und waren weitgehend clean — deutet auf disziplinierten Mockup-Build durch Claude Design hin.

**Commit:** `e86c806` · 5 Mockups + lint-violations.md · pushed to origin/main.

**Drift-Log [2026-04-20] Status:** Alle 5 Action Items resolved (#1 Detached-HEAD ✅ · #2 ERP-Lint ✅ · #3 ERP-Specs-Verzeichnis ✅ · #4 Stammdaten-Vollansicht ✅ · #5 Admin-Debug-Mockup ✅) — **drift-log [2026-04-20] vollständig closed.**

---

## [2026-04-30] Resolution · Performance-Mockup Tier-2/3 Pattern-Konsistenz + OS-Theme

✅ **DONE** Phase-3-B1a Tier-2 + Tier-3-Theme: alle 3 Audit-Top-Items (#3, #4, #5) abgeschlossen.

**Resolution:** Subagent (general-purpose mit Sonnet) implementierte 3 Tasks in einem Commit:

**Task A — Drawer-Pattern-Konsistenz (4 Files · 12 Drawer):**
| File | Drawer mit `data-drawer-key=` ergänzt |
|------|----------------------------------------|
| `performance-revenue.html` | 4 (explain · process · attribution · forecast-override) |
| `performance-team.html` | 2 (team-member · goal-new) |
| `performance-business.html` | 2 (business-mandant · sparte-overview) |
| `performance-reports.html` | 4 (trigger · run-detail · template-config · template-new) |

Additive: `id="drawer-..."` bleibt für Backward-Compat. JS-Lookup `data-drawer-key=` ODER `id=drawer-` funktioniert beide.

**Task B — data-open-drawer Standardisierung:**
- `performance-funnel.html`: 5× `data-open-drawer="funnel-process"`-Attribute entfernt (waren nur HTML-Trigger)
- JS-Delegation auf Z. 1120 (`document.addEventListener('click', ...)`) bleibt — Pattern jetzt sibling-conform

**Task C — prefers-color-scheme Media-Query (11 Files):**
- Alle 11 Files bekommen `@media (prefers-color-scheme: dark) { :root:not([data-theme="light"]) { ... } }` Block
- Override-Pattern: User-explizite `data-theme="light"` Wahl gewinnt über OS-Preference
- Var-Set per File akkurat kopiert (3 Varianten erkannt: tint/shadow, soft, business + sparten, dashboard-eigene Naming)

**Lint-Verifikation:**
- 0 Umlaute-Violations
- 0 neue DB-Tech-Violations (3 pre-existing in `ark-lint-skip` exempt)

**Spec-Compliance bleibt:** 91% (Tier-2/3 ist Polish, keine neuen Drawer)

**Commit:** `6568897` · 11 Files · +287/-17 Zeilen

**B1a-Branch komplett abgeschlossen** — Phase-3.1-Performance-Mockup ist Production-Mockup-Quality:
- ✅ 19 Drawer (P0+P1)
- ✅ Alle 4 Spec-Flows unblocked
- ✅ Lint-clean
- ✅ Pattern-konsistent
- ✅ OS-Dark-Mode-detection

---

## [2026-04-30] Resolution · Performance-Mockup Tier-2/3 P0-Lint-Fixes

✅ **DONE** Phase-3-B1a Tier-3 P0-Critical Lint-Violations fixed.

**Audit-Find (Sonnet-Subagent):** 11 Performance-Mockup-Files auf ARK-Lint-Compliance + Pattern-Konsistenz audited. 3 echte CRITICAL-Violations entdeckt; 3 weitere Treffer waren bereits korrekt in `ark-lint-skip`-Blöcken gewrappt (Audit-Miscount korrigiert).

**Resolution:** 3× Umlaute-Substitut `ueber` → `über` in `performance-dashboard.html`:
- Z. 1376: "Multi-Serie ueber Zeit" (Tile-Type-Card-Description)
- Z. 1531: "Werden Werte ueber-/unterschritten" (Anomaly-Detection-Hint)
- Z. 1620: "ueber alle nicht-abgeschlossenen Prozesse" (Forecast-Formel)

Alle waren in User-facing-Text, Pflicht-Fix per CLAUDE.md §Umlaute-Regel.

**Audit-Report-Korrekturen:**
- `reports.html` Z. 878+884 (`v_perf_forecast_q_audit`): bereits in `<!-- ark-lint-skip:begin reason=admin-error-diagnose -->` (Audit hat Skip-Marker übersehen)
- `admin.html` Z. 514 (`fact_metric_snapshot_*`): bereits in `<!-- ark-lint-skip:begin reason=admin-table-spec -->` (Audit hat Skip-Marker übersehen)

**Tier-2 / weitere Tier-3 (deferred zu Folge-Session):**
- 4 Files mit Mixed-Drawer-Pattern (`id="drawer-..."` vs `data-drawer-key=`): revenue · team · business · reports — Konsolidierung ~30-45min
- `data-open-drawer` only in funnel.html — Standardisierung ~20min
- `prefers-color-scheme` media query in 0 Files — ~60min für alle 11
- Mobile-Breakpoints (≤768px) fehlen in allen 11 Files — Mockup-Limitation, nicht Lint-blocker

---

## [2026-04-30] Resolution · Performance-Mockup P1-Drawers (Phase-3.1 vervollständigt)

✅ **DONE** Phase-3-Branch B1a P1-High: 11 P1-Drawer in 6 Performance-Sub-Page-Mockups implementiert.

**Resolution:** Subagent (general-purpose, Continuation nach Codex-Gate-Release) implementierte 11 P1-Drawer:

| File | Vorher | Nachher | Drawer hinzugefügt |
|------|--------|---------|----------------------|
| `performance-funnel.html` | 1087 | 1177 | funnel-process |
| `performance-coverage.html` | 1385 | 1507 | coverage-account |
| `performance-revenue.html` | 1742 | 1917 | revenue-attribution · forecast-override (Duplicate-Pattern) |
| `performance-mitarbeiter.html` | 1527 | 1621 | goal-edit |
| `performance-reports.html` | 1133 | 1363 | template-config · template-new |
| `performance-admin.html` | 1118 | 1457 | metric-new · anomaly-threshold · dashboard-default · snapshot-lag |

**Total:** +1050 Zeilen, 6 Files modifiziert.

**Wiring-Highlights:**
- Funnel: `→ Profil`-Link in funnel-stage Process-Liste · close + reopen Pattern
- Coverage: Account-Mode-Toggle bei tabAcc · Capture-Phase-Listener intercepted Account-Click
- Revenue: forecast-override als standalone Duplicate (existing drawer-process Override-Tab untouched per Pre-Decision · safer als Refactor)
- Mitarbeiter: 3× Goal-Edit-Buttons inline + 1× from goal-progress footer
- Reports: Template-Card-Click + new "+ Template"-Button
- Admin: rebound Threshold-Body, neuer Dashboard-Defaults-Body, Worker-Health-Card-Click

**Lint-Verifikation:**
- 0 Umlaute-Violations (ae/oe/ue/ss-Substitute)
- 0 DB-Tech-Names in User-Text (1 pre-existing benign HTML-Kommentar in coverage.html Z. 748 ist Developer-Comment, nicht user-facing)
- 540px Drawer-Width konsistent

**Spec-Compliance-Update:** 59% → 91% (31/34 Drawer MATCH).

**Backups:** `backups/performance-{funnel,coverage,revenue,mitarbeiter,reports,admin}.html.2026-04-30-<HHMM>.bak`

**Commit:** `f9e9b93` pushed to origin/main.

**Phase-3.1-Verdict:** **GO** — alle P0-Blocker + P1-High abgeschlossen. Customize-Dashboard-Flow + Closed-Loop-Flow + Admin-Config-Flow + Forecast-Drill-Flow alle unblocked.

**Offen B1a (für eigene Folge-Session, niedrige Priorität):**
- 3 Restdrawer aus 34: kleine Spec-Counting-Differenz · final 100% wenn nötig
- Tier-2: Pattern-Konsistenz `data-drawer-key` vs `id=drawer-*` cross-file harmonisieren
- Tier-3: Lint-Pass auf alle 11 Files (auch existierende), Test-Daten statt Placeholder

---

## [2026-04-30] Resolution · Performance-Mockup P0-Drawers (Phase-3.1)

✅ **DONE** Phase-3-Branch B1a P0-Blocker: 8 P0-Drawer in Performance-Mockups implementiert.

**Find via Audit (2026-04-30):** Performance-Mockups (11 Files, 14'702 Zeilen) sind 38% Spec-Compliance — 12 von 34 Spec-Drawer als MATCH, 21 MISSING. P0-Blocker: Dashboard (0/4 Tile-Drawer) + Insights (4/6 Action-Loop-Drawer fehlen) blockieren Customize-Flow + Closed-Loop.

**Resolution:** Subagent (general-purpose) implementierte 8 P0-Drawer in 2 Files:

| File | Vorher | Nachher | Drawer hinzugefügt |
|------|--------|---------|----------------------|
| `mockups/ERP Tools/performance/performance-dashboard.html` | 1297 | 2075 | tile-add · tile-edit · tile-explain · tile-drill |
| `mockups/ERP Tools/performance/performance-insights.html` | 1675 | 2077 | action-create · action-detail · action-update · action-followup |

**Wiring:** FAB-Button + Gear-Icon + Auto-injected ?-Icon + Tile-Click → Dashboard-Drawers · Existing "Massnahme erstellen" CTA + Action-Card-Click + Update-Button + Outcome-Confirm-Followup → Insights-Drawers.

**Lint-Verifikation:** 0 Umlaute-Violations · 0 DB-Techdetails in User-Text · 540px Drawer-Width konsistent · Backups in `backups/performance-*.2026-04-30-1545.bak`.

**Spec-Compliance-Update:** 38% → 59% (20 von 34 MATCH).

**Offen B1a (für Folge-Session):**
- P1-High: 10 Drawer fehlen (admin 4, revenue 1, funnel 1, coverage 1, mitarbeiter 1, reports 2)
- Tier-2: Pattern-Konsistenz `data-drawer-key` vs `id=drawer-*`, Responsive-Design, Theme-Toggle
- Tier-3: Lint-Pass auf alle 11 Files, Test-Daten

**Commit:** `7903d68` pushed to origin/main.

---

## [2026-04-30] Resolution · Power-BI-Integration Plan v0.1

✅ **DOCUMENTED** (overview.md "Power BI Integration: Views stehen bereit, Dashboards werden manuell..."): Power-BI-Integration konsolidiert.

**Find:** Der overview.md-Eintrag war veraltet. Performance-Modul-Merge am 2026-04-25 hat 70% der Power-BI-Integration bereits spec'd, ohne dass overview/drift-log das reflektierten:
- 8 Materialized Views (`v_powerbi_*`) in DB-Schema v1.6
- `dim_powerbi_view` Stammdaten-Katalog (8 Seeds in v1.6 §97.6)
- `powerbi_reader` Read-Only-Role mit RLS in DB v1.6
- Refresh-Worker `powerbi-view-refresh.worker` + Cron in Backend v2.8
- Admin + Bridge-Endpoints (X-API-Key) in Performance-Spec
- Event `perf_powerbi_view_refresh_failed`
- Tile-Type `iframe_powerbi` in Stammdaten v1.6

**Resolution:** `specs/ARK_POWER_BI_INTEGRATION_PLAN_v0_1.md` (~25 KB · 14 Sections) konsolidiert alle Pieces:
- §1 Quellen-Inventar (was existiert in Backend/DB/Stammdaten/Frontend)
- §2 Daten-Architektur mit Diagramm
- §3 Refresh-Pipeline (Worker, Failure-Handling, Severity-Eskalation)
- §4 API-Surface (Admin JWT + Bridge X-API-Key)
- §5–10 Greenfield-Areas: Workspace-Setup, RLS-DAX-Mapping, Gateway, Embed-Token-Flow, Governance, Monitoring
- §11 Phasen-Plan (5 Phasen, Phase-0+1 ~3h, Phase-2-3 ~8h)
- §12 10 offene Fragen für PW + Nenad-Stakeholder-Review
- §13 Sync-Plan (Backend + Frontend Patches Phase-3)

**Greenfield-Anteil 30%:** Workspace-Modell (Single+DAX vs Pro-Tenant), Service-Principal-Auth, Iframe-Embed-Token-Lifecycle, View-SQL-Change-Workflow, Cost/Capacity-Strategie.

**Phase-1-A ARK-CRM-Closing fertig** — alle 6 Phase-1-Items (A5/A2/A1/A3/A6/A4) abgeschlossen.

---

## [2026-04-30] Resolution · Detached-HEAD-Detection im SessionStart-Hook

✅ **RESOLVED** Action Item #1 [2026-04-20]: Detached-HEAD-Schutz.

**Find:** 2026-04-20 ging Commit `89b367b` (feat(erp-tools): HR/Commission/Zeit) in detached-HEAD-State verloren. Recovery via Reflog war erfolgreich, aber kein Schutz gegen Wiederholung.

**Resolution:** `.claude/hooks/session-overview.ps1` erweitert mit Git-Branch-Detection:
- Liest `git rev-parse --abbrev-ref HEAD` bei Session-Start
- 4 Branch-States klassifiziert: `main` (OK), `HEAD` (DETACHED-Warnung), `?` (silent), other (Info-Hinweis)
- Detached-HEAD-Fall: prominente Warnung mit Recovery-Anleitung (`git checkout main`) + Hintergrund-Referenz auf 89b367b-Vorfall
- Non-Main-Fall: Info-Hinweis (kein Hard-Block, OK für intentional Feature-Work)
- Auto-Switch bewusst NICHT implementiert — würde Probleme verbergen

**Verifiziert:** Hook-Run auf main produziert `**Git-Branch:** main OK` im Session-Overview.

**Variante H1 gewählt** (statt H2 PreToolUse-Hook): Detached-HEAD passiert selten, PreToolUse wäre Overkill und slowt jeden Edit. SessionStart-Warnung reicht.

---

## [2026-04-30] Resolution · Outlook-Failsafe-Konzept

✅ **DOCUMENTED** (overview.md "implementation status unclear"): Outlook-Failsafe-Strategie konsolidiert.

**Find:** Failsafe-Mechanismen waren in mehreren Files verteilt (Email-Spec Token-Erneuern, Backend-v2.8 §42 + Runbook 4, email-system.md), aber kein Single-Source-Index. Send-Queue-Retry-Policy beim Email-Send fehlte komplett.

**Resolution:**
- `wiki/concepts/outlook-failsafe.md` (~10.5 KB) — Index + Send-Queue-Retry-Policy
- 7 Failure-Modes klassifiziert (Token-Expiry · Token-Revoked · MS-Graph 5xx · 429 · Komplett-Outage · Network · Webhook-Loss)
- Send-Queue-Architektur (`fact_email_send_queue`) + Worker (`email.send.worker.ts`) + Backoff-Schedules pro Error-Klasse
- Admin-Surface-Mapping (Email-Modul Status-Card · Admin Tab 1 · Admin Tab 9 Sub-Tabs 9-1/9-2/9-3)
- 5 offene Fragen für Folge-Diskussion

**Sync-Bedarf (Folge-Session):**
- `ARK_DATABASE_SCHEMA_PATCH_v1_6_to_v1_7_email_queue.md` — Tabelle `fact_email_send_queue`
- `ARK_BACKEND_ARCHITECTURE_PATCH_v2_8_to_v2_9_email_failsafe.md` — Worker + Events
- `ARK_FRONTEND_FREEZE_PATCH_v1_13_to_v1_14_email_outbox.md` — Outbox-Indicator + Dead-Letter-Drawer

---

## [2026-04-30] Resolution · Stammdaten-Vollansicht Schema + Interactions

✅ **RESOLVED** Action Item #4 [2026-04-20] (Carryover): Stammdaten-Vollansicht-Spec-Lücke.

**Find:** Plan v0.1 + Mockup (3955 Zeilen) existierten seit 2026-04-18, aber Schema/Interactions-Specs fehlten. Drift-log markierte als 🟡 MITTEL.

**Resolution:** Reverse-Engineering aus Plan v0.1 + Mockup-Validation:
- `specs/ARK_STAMMDATEN_VOLLANSICHT_SCHEMA_v0_1.md` (~34 KB) — 15 Sections: ZIELBILD · Designsystem · Layout (Variant C) · Kategorie-Inventar (8 Tabs · 67 Kataloge) · Stat-Strip · Card-Grid · Drill-Down-Tabelle · Detail-Drawer · Browse/Edit-Modes · Suche+Filter · Routing · Permissions-Matrix · Cross-Links Admin · HR-Overlap-P2 · Sync-Plan · 8 offene Fragen
- `specs/ARK_STAMMDATEN_VOLLANSICHT_INTERACTIONS_v0_1.md` (~32 KB) — 13 Sections: Funktionen pro Bereich · Browse-Flows · Edit-Flows (Inline-Edit · Konflikt-Resolution · Sort-Drag · Soft-Disable · Hard-Delete · Batch-Import) · CRUD-Endpoint-Matrix (~22 Endpoints) · Validation · Audit-Integration · Permissions-Matrix · Keyboard-Shortcuts · Empty/Error-States · State-Management · Events/WS-Channels · Cross-Modul-Integration · 8 offene Fragen
- `wiki/meta/spec-sync-regel.md` aktualisiert: System-Vollansichten 1 → 2 (Admin + Stammdaten)

**Sync-Bedarf (Folge-Sessions):**
- `ARK_BACKEND_ARCHITECTURE_PATCH_v2_8_to_v2_9_stammdaten.md` — ~22 neue Endpoints
- `ARK_FRONTEND_FREEZE_PATCH_v1_13_to_v1_14_stammdaten.md` — Route `/stammdaten` + Sidebar
- `ARK_GESAMTSYSTEM_PATCH_v1_5_to_v1_6_stammdaten.md` — Changelog-Eintrag

**Begründung Reverse-Eng-Approach:** Mockup war Plan voraus (analog Admin-Debug-Resolution 2026-04-28). Spec dokumentiert Implementations-Realität statt von vorne zu erfinden.

---

## [2026-04-28] Resolution · Admin-Debug-Tab

✅ **RESOLVED** Action Item #5 [2026-04-20] (Carryover): Admin-Debug-Mockup-Klärung.

**Find:** Tab 9 „Debug" mit 5 Sub-Tabs (Event-Log, Saga-Traces, Dead-Letter, Circuit-Breaker, Rules) ist seit längerem in `mockups/Vollansichten/admin.html` (Zeile 2026+) implementiert — nicht „Mockup fehlt", sondern Spec-Realität-Drift: Spec definierte Single-Page-Route `/admin/event-log`, Mockup integrierte als Tab.

**Resolution:** `specs/ARK_ADMIN_DEBUG_SCHEMA_v1_0.md` von v1.0 → v1.1 in-place gepatched (Filename bleibt für Cross-Ref-Stabilität):
- §0 ZIELBILD: Single-Page-Route → Tab 9 in `admin.html`
- §2 ROUTING: 6 Routen `/admin/event-log/*` → Hash-Routes `/admin#tab=9-N`
- §15 Sync-Plan: Frontend-Freeze-Zeile angepasst (Tab-Inventar statt Routing-Eintrag)
- §16 Fertigstellungs-Kriterium: Route → Tab umformuliert

**Begründung:** Mockup war Spec voraus. Tab-Integration ist kohärentere Admin-Cockpit-UX (KPI-Cross-Links, kein Context-Switch). Spec wurde an Implementierungs-Realität angeglichen statt Mockup zu zerlegen.

---

## [2026-04-20] Weekly Drift Scan

> **⚠ HIGH PRIORITY**
> - SNAKE-CASE=188 Violations (kumulativ) — ERP-Tools-Mockups wahrscheinlich Hauptquelle, Lint-Pass ausstehend
> - UMLAUT=161 Violations (kumulativ) — gleiches Muster, gezielte Prüfung nötig
> - DB-TECH=113 Violations (kumulativ) — grösstenteils resolved (8 RESOLUTION ✓ Blöcke vorhanden)
> - 16 ERP-Tools-Mockups ohne zugehörige Specs → **REVERSE DRIFT** (siehe unten)

### ark-status.ps1
- **Status:** Nicht verfügbar — `powershell` nicht im PATH der Linux-Umgebung. Hook läuft nur im Windows-Dev-Environment.

### Unresolved Changelog (grundlagen-changelog.md)
- **Unresolved entries (`- [ ]`):** 0 — alle Einträge `resolved`
- Letzter Eintrag: [2026-04-17 18:37] session-cea13e34 → resolved 18:45

### Violations (wiki/meta/lint-violations.md — kumulativ inkl. gelöster)
- **DB-TECH=113  SNAKE-CASE=188  ROUTE-TMPL=6  KEBAB-TECH=0  UMLAUT=161  STAMMDATEN=0**
- 8 RESOLUTION ✓ Blöcke vorhanden (candidates.html ×14, accounts.html ×22 u.a.)
- Kumulative Zahlen — viele bereits gefixt; Netto-Offene schwer automatisch bestimmbar
- Empfehlung: gezielter `ark-lint`-Pass auf neue ERP-Tools-Mockups (kommende Woche)

### Digests (wiki/meta/digests/STALE.md)
- **Status:** Alle 5 Digests current — letzter Clean 2026-04-17 18:18
  - `backend-architecture-digest.md` — v2.5.5 (Reminders Events, Worker, Endpoints)
  - `database-schema-digest.md` — fact_reminders + template_id FK + escalation_sent_at
  - `frontend-freeze-digest.md` — §24b Responsive-Policy v1.11, /reminders Tool-Maske
  - `gesamtsystem-digest.md` — v1.3.6 (TEIL 23+24)
  - `stammdaten-digest.md` — keine Änderung an v1.3-Baseline
- Kein Grundlagen-Edit seit 2026-04-17 → Digests weiterhin aktuell (3 Tage alt, kein Stale-Flag)

### Specs edited (7d): 44 Dateien
**Aktive Specs (ohne alt/):**
- `ARK_KANDIDATENMASKE_SCHEMA/INTERACTIONS_v1_3`
- `ARK_ACCOUNT_DETAILMASKE_SCHEMA/INTERACTIONS_v0_2/v0_3`
- `ARK_MANDAT_DETAILMASKE_SCHEMA/INTERACTIONS_v0_2/v0_3`
- `ARK_PROJEKT_DETAILMASKE_SCHEMA/INTERACTIONS_v0_1/v0_2`
- `ARK_PROZESS_DETAILMASKE_SCHEMA/INTERACTIONS_v0_1`
- `ARK_ASSESSMENT_DETAILMASKE_SCHEMA/INTERACTIONS_v0_3` + MOCKUP_IMPL + PLAN
- `ARK_ADMIN_DEBUG_SCHEMA_v1_0` + `ARK_ADMIN_VOLLANSICHT_SCHEMA/INTERACTIONS_v0_1`
- `ARK_FIRMENGRUPPE_DETAILMASKE_SCHEMA/INTERACTIONS_v0_1`
- `ARK_JOB_DETAILMASKE_SCHEMA/INTERACTIONS_v0_1`
- `ARK_EMAIL_KALENDER_DETAILMASKE_SCHEMA/INTERACTIONS_v0_1`
- `ARK_REMINDERS_VOLLANSICHT_PLAN/SCHEMA/INTERACTIONS_v0_1`
- `ARK_SCRAPER_MODUL_SCHEMA/INTERACTIONS_v0_1` + PATCH_v0_1_to_v0_2
- `ARK_DOK_GENERATOR_SCHEMA/INTERACTIONS/MOCKUP_IMPL/PLAN_v0_1`
- `ARK_PIPELINE_COMPONENT_v1_0`
- `ARK_DASHBOARD_CUSTOMIZATION_SCHEMA_v1`
- `ARK_STAMMDATEN_VOLLANSICHT_PLAN_v0_1`
- Patch-Docs: `ARK_BACKEND_ARCHITECTURE_PATCH_v2_5_to_v2_6`, `ARK_DATABASE_SCHEMA_PATCH_v1_3_to_v1_4`, `ARK_STAMMDATEN_PATCH_v1_3_to_v1_4_ACTIVITY_TYPES`
- `ARK_GRUNDLAGEN_SYNC_v1_4`, `ARK_EVENT_TYPES_MAPPING_v1_4`, `ARK_SYSTEM_ACTIVITY_TYPES_*`
- `PO_REVIEW_SESSION_v1_4`
- 6 Alt-Specs (specs/alt/)

### Mockups edited (7d): ~66 Dateien
**Vollansichten (16):** accounts · admin · admin-dashboard-templates · assessments · candidates · dashboard · dok-generator · email-kalender · groups · jobs · mandates · processes · projects · reminders · scraper · stammdaten

**Listen (9):** accounts-list · assessments-list · candidates-list · groups-list · jobs-list · mandates-list · processes-list · projects-list

**ERP Tools (16):** commission-admin · commission-dashboard · commission-my · commission-my-researcher · commission-team · commission · hr-academy-dashboard · hr-dashboard · hr-list · hr-mitarbeiter-self · hr-provisionsvertrag-editor · hr-warnings-disciplinary · hr · zeit-dashboard · zeit-list · zeit

**Shared:** `_shared/editorial.css` · `_shared/layout.js`

**Root-Level-Duplikate (Legacy):** 14 root-level HTML-Files + assets

### Drift Findings

| Befund | Schwere | Detail |
|--------|---------|--------|
| **Git-Health: Detached-HEAD-Commit** | 🔴 HOCH | Commit `89b367b` (feat(erp-tools): HR/Commission/Zeit) war in detached HEAD State, nicht auf main verbunden. Wurde via Reflog recovered und via Merge-Commit in main integriert. Ursache prüfen. |
| ERP-Specs in separatem Verzeichnis | 🟡 MITTEL | ERP-Tools-Specs liegen in `specs/` statt `specs/` — 15 Spec-Dateien (Commission×2, HR×8, Zeiterfassung×2, Eval×2). Intentional (ERP-Phase-Trennung) oder Struktur-Drift? |
| Admin-Debug-Spec ohne Mockup | 🟡 MITTEL | `ARK_ADMIN_DEBUG_SCHEMA_v1_0.md` in `specs/` — kein `admin-debug.html` in `mockups/Vollansichten/`. Admin.html berührt, aber kein Debug-spezifisches Mockup. |
| Stammdaten-Vollansicht Plan-only | 🟡 MITTEL | `ARK_STAMMDATEN_VOLLANSICHT_PLAN_v0_1.md` vorhanden, `mockups/Vollansichten/stammdaten.html` existiert — aber kein SCHEMA/INTERACTIONS-Spec. |
| Mockup-Reorganisation abgeschlossen | ✅ INFO | `mockups/` hat neue Subdirectory-Struktur: `Listen/` (8 Files) · `Vollansichten/` (16 Files) · `ERP Tools/` (16 Files). Root-Level nur noch 4 mobile/shell HTMLs. |
| ERP-Tools-Specs vorhanden | ✅ SYNCED | Commission: `ARK_COMMISSION_ENGINE_SPEC_v0_1.md` ✓ · HR: `ARK_HR_TOOL_SCHEMA_v0_1.md` + 7 weitere ✓ · Zeiterfassung: `ARK_ZEITERFASSUNG_PLAN_v0_1.md` ✓ |
| Alle 13 Entity-/Tool-Masken | ✅ SYNCED | Kandidat · Account · Mandat · Projekt · Prozess · Assessment · Scraper · Email-Kalender · Reminders · Dok-Generator · Admin · Firmengruppe · Job — alle spec+mockup vorhanden |
| Grundlagen-Changelog | ✅ CLEAN | 0 unresolved entries |
| Digests | ✅ CURRENT | Alle 5 Digests aktuell (letzter Clean 2026-04-17 18:18) |

### Action Items (für Peter)

1. **🔴 Detached-HEAD-Ursache klären** — Commit `89b367b` war nicht auf main. Wiederholung verhindern: sicherstellen, dass Sessions immer `git checkout main` vor Commits machen. Scan-Routine funktioniert, Recovery war erfolgreich.

2. **🔴 `ark-lint` auf ERP-Tools-Mockups** — 16 HTML-Files in `mockups/ERP Tools/` noch nie gelinted. Wahrscheinlich Hauptquelle der SNAKE-CASE=188 + UMLAUT=161 Kumulativ-Counts. Gezielten Lint-Pass starten.

3. **🟡 ERP-Specs-Verzeichnis klären** — Intentional in `specs/` (ERP-Phase-Trennung) oder nach `specs/` migrieren? Entscheidung dokumentieren, dann konsistent halten.

4. **🟡 Stammdaten-Vollansicht vervollständigen** — Plan-Spec vorhanden, Mockup existiert (`stammdaten.html`) — SCHEMA + INTERACTIONS-Spec noch schreiben.

5. **🟡 Admin-Debug-Mockup** — `ARK_ADMIN_DEBUG_SCHEMA_v1_0.md` ohne Mockup. Mockup anlegen oder Scope in `admin.html` klären.

6. **🟢 Powershell-Hook** — `ark-status.ps1` läuft nur im Windows-Env. Für diesen Monday-Scan: N/A (Linux). Bash-Fallback oder Windows-Session verwenden.

7. **🟢 `/ark-sync-report`** — ERP-Specs-Erstellung abgeschlossen (15 Specs). Vollständiger Sync-Report empfohlen.

---

## [2026-04-27] Weekly Drift Scan

> **⚠ HIGH PRIORITY**
> - DB-TECH=116 / SNAKE-CASE=189 / UMLAUT=170 — alle >50 (kumulativ). ERP-Tools-Lint-Pass seit 2026-04-20 ausstehend, 0 neue RESOLUTION-Blöcke diese Woche.
> - Billing-Modul: 9 Mockups ohne Schema/Interactions-Spec (REVERSE DRIFT).

### ark-status.ps1
- **Status:** Nicht verfügbar — `powershell` nicht im PATH der Linux-Umgebung. Hook läuft nur im Windows-Dev-Environment.

### Unresolved Changelog (grundlagen-changelog.md)
- **Unresolved entries (`- [ ]`):** 0 — alle Einträge `resolved`
- Letzter Eintrag: [2026-04-25 21:24] session-53f982ef → resolved (Performance-Modul-Sync)

### Violations (wiki/meta/lint-violations.md — kumulativ inkl. gelöster)
- **DB-TECH=116  SNAKE-CASE=189  ROUTE-TMPL=6  KEBAB-TECH=0  UMLAUT=170  STAMMDATEN=0**
- 8 RESOLUTION ✓ Blöcke (unverändert gegenüber 2026-04-20 — keine neuen Resolutions diese Woche)
- Netto-Neu seit letztem Scan: DB-TECH+3 · UMLAUT+9 · SNAKE-CASE+1
- ERP-Tools-Mockups (billing · commission · elearn · hr · performance · zeit) wahrscheinliche Hauptquelle

### Digests (wiki/meta/digests/STALE.md)
- **Status:** Alle 5 Digests current — letzter Clean 2026-04-25 (Performance-Modul-Sync)
  - `stammdaten-digest.md` — v1.6 (§97 Performance + §98 HR-Reviews)
  - `database-schema-digest.md` — v1.6 (~225 Tabellen, TEIL Q Performance)
  - `backend-architecture-digest.md` — v2.8 (TEIL R Performance, 50 Endpoints)
  - `frontend-freeze-digest.md` — v1.13 (TEIL Q Performance, 10 Routes)
  - `gesamtsystem-digest.md` — v1.5 (TEIL 26 Performance)
- 2 Tage alt — kein Stale-Flag (Schwelle: >5 Tage)

### Specs edited (7d): 95 Dateien (inkl. alt/)

**Neue Module (vollständig):**
- E-Learning Sub A/B/C/D: `ARK_E_LEARNING_SUB_{A,B,C,D}_{SCHEMA,INTERACTIONS}_v0_1.md` (8 Spec-Files)
- Performance: `ARK_PERFORMANCE_TOOL_{SCHEMA,INTERACTIONS,MOCKUP_PLAN}_v0_1.md`
- HR: `ARK_HR_TOOL_SCHEMA_v0_1.md` + `v0_2.md` + `ARK_HR_TOOL_INTERACTIONS_v0_1.md` + `ARK_HR_TOOL_SCHEMA_PATCH_v0_1_to_v0_2.md`
- Zeit: `ARK_ZEIT_{SCHEMA,INTERACTIONS}_v0_1.md`
- Billing: Grundlagen-Patches only (3 Patch-Docs — kein Entity-Spec)

**Grundlagen-Patches (neue Woche):**
- Backend: `PATCH_v2_5_to_v2_6` · `PATCH_v2_6_to_v2_7_billing` · `PATCH_v2_7_to_v2_8_performance`
- DB-Schema: `PATCH_v1_3_to_v1_4` · `PATCH_v1_4_to_v1_5_billing` · `PATCH_v1_5_to_v1_6_performance`
- Stammdaten: `PATCH_v1_3_to_v1_4_ACTIVITY_TYPES` · `PATCH_v1_4_to_v1_5_billing` · `PATCH_v1_5_to_v1_6_performance`
- Frontend-Freeze: `PATCH_v1_12_to_v1_13_performance` + 4×E-Learning-Sub-Patches (kein Billing-Patch)
- Gesamtsystem: `PATCH_v1_4_to_v1_5_performance` + 4×E-Learning-Sub-Patches (kein Billing-Patch)

**Bestehende Masken (Updates):**
- `ARK_KANDIDATENMASKE_SCHEMA/INTERACTIONS_v1_3`
- `ARK_ACCOUNT_DETAILMASKE_SCHEMA_v0_2` / `INTERACTIONS_v0_3`
- `ARK_MANDAT_DETAILMASKE_SCHEMA_v0_2` / `INTERACTIONS_v0_3`
- `ARK_PROJEKT_DETAILMASKE_SCHEMA_v0_2` / `INTERACTIONS_v0_1`
- `ARK_PROZESS_DETAILMASKE_SCHEMA/INTERACTIONS_v0_1`
- `ARK_ASSESSMENT_DETAILMASKE_SCHEMA/INTERACTIONS_v0_3` + MOCKUP_IMPL + PLAN
- `ARK_ADMIN_VOLLANSICHT_SCHEMA/INTERACTIONS_v0_1` + `ARK_ADMIN_DEBUG_SCHEMA_v1_0`
- `ARK_FIRMENGRUPPE_DETAILMASKE_SCHEMA/INTERACTIONS_v0_1`
- `ARK_JOB_DETAILMASKE_SCHEMA/INTERACTIONS_v0_1`
- `ARK_EMAIL_KALENDER_DETAILMASKE_SCHEMA/INTERACTIONS_v0_1`
- `ARK_REMINDERS_VOLLANSICHT_{PLAN,SCHEMA,INTERACTIONS}_v0_1`
- `ARK_SCRAPER_MODUL_{SCHEMA,INTERACTIONS}_v0_1` + `PATCH_v0_1_to_v0_2`
- `ARK_DOK_GENERATOR_{SCHEMA,INTERACTIONS,MOCKUP_IMPL,PLAN}_v0_1`
- `ARK_PIPELINE_COMPONENT_v1_0` · `ARK_DASHBOARD_CUSTOMIZATION_SCHEMA_v1`
- `ARK_STAMMDATEN_VOLLANSICHT_PLAN_v0_1`

**Meta-Docs:** `ARK_GRUNDLAGEN_SYNC_v1_4` · `ARK_EVENT_TYPES_MAPPING_v1_4` · `ARK_SYSTEM_ACTIVITY_TYPES_{SCHEMA,DECISIONS}` · `PO_REVIEW_SESSION_v1_4` · 6 alt/-Specs

### Mockups edited (7d): ~125 Dateien

**ERP Tools:**
- `billing/` — 9 HTMLs (billing-dashboard · debitoren · inkasso · mahnwesen · mwst · rechnungen · refunds · zahlungen · billing)
- `commission/` — 6 HTMLs (admin · dashboard · my · my-researcher · team · commission)
- `elearn/` — 21 HTMLs (dashboard · course · lesson · quiz · quiz-result · certificates · assignments · my-courses · my-compliance · team · team-compliance · newsletter · newsletter-issue · freitext-queue · admin-courses · admin-curriculum · admin-content-gen · admin-analytics · admin-imports · elearn)
- `hr/` — 8 HTMLs (dashboard · list · mitarbeiter-self · provisionsvertrag-editor · onboarding-editor · warnings-disciplinary · academy-dashboard · hr)
- `performance/` — 11 HTMLs (dashboard · business · revenue · coverage · funnel · insights · mitarbeiter · team · admin · reports · performance)
- `zeit/` — 10 HTMLs (dashboard · list · meine-zeit · monat · team · saldi · export · abwesenheiten · admin · zeit)

**Vollansichten:** accounts · admin · admin-dashboard-templates · assessments · candidates · dashboard · dok-generator · email-kalender · groups · jobs · mandates · processes · projects · reminders · scraper · stammdaten (16)

**Listen:** accounts-list · assessments-list · candidates-list · groups-list · jobs-list · mandates-list · processes-list · projects-list (8)

**Shared + Root:** `_shared/editorial.css` · `_shared/layout.js` · `_shared/perf-sample-data.js` · `_shared/theme-sync.js` · `crm.html` · `crm-mobile.html` · `dashboard-mobile.html` · `admin-mobile.html` · `vercel.json`

### Drift Findings

| Befund | Schwere | Detail |
|--------|---------|--------|
| **Billing: 9 Mockups ohne Schema/Interactions-Spec** | 🔴 HOCH | `billing-*.html` (9 Files) vorhanden, aber kein `ARK_BILLING_SCHEMA_v*.md` + `ARK_BILLING_INTERACTIONS_v*.md` in `specs/`. Nur 3 Grundlagen-Patch-Docs vorhanden. REVERSE DRIFT. |
| **Billing: Fehlende Frontend-Freeze + Gesamtsystem Patches** | 🟡 MITTEL | Backend-/DB-/Stammdaten-Patches vorhanden, aber kein `ARK_FRONTEND_FREEZE_PATCH_*billing*` und kein `ARK_GESAMTSYSTEM_PATCH_*billing*`. Billing-UI-Patterns möglicherweise nicht in Freeze dokumentiert. |
| **ERP-Tools ark-lint-Pass ausstehend** | 🟡 MITTEL | Seit 2026-04-20-Empfehlung kein Lint-Pass auf ERP-Tools-Mockups. Neue Violations: UMLAUT+9, DB-TECH+3, SNAKE-CASE+1. 8 RESOLUTION-Blöcke unverändert. |
| **Stammdaten-Vollansicht: SCHEMA + INTERACTIONS fehlt** | 🟡 MITTEL | Plan-Spec + `stammdaten.html` vorhanden — kein SCHEMA/INTERACTIONS-Spec. (Carryover seit 2026-04-20) |
| **Admin-Debug: Mockup fehlt** | 🟢 NIEDRIG | `ARK_ADMIN_DEBUG_SCHEMA_v1_0.md` ohne `admin-debug.html`. (Carryover) |
| E-Learning Sub A/B/C/D aligned | ✅ SYNCED | Specs + Mockups (21 HTMLs) + 4×5 Grundlagen-Sub-Patches vollständig. |
| Performance-Modul aligned | ✅ SYNCED | 3 Spec-Files + 11 Mockups + alle 5 Grundlagen-Patches. Digests regeneriert. |
| HR-Modul aligned | ✅ SYNCED | Schema v0_2 + Interactions + Grundlagen-Sync + 8 Mockups. |
| Zeit-Modul aligned | ✅ SYNCED | 2 Specs + 10 Mockups + Grundlagen-Patches. |
| Grundlagen-Changelog | ✅ CLEAN | 0 unresolved entries |
| Digests | ✅ CURRENT | Alle 5 Digests regeneriert 2026-04-25 (2 Tage alt) |
| Detached-HEAD (2026-04-20) | ✅ RESOLVED | Recovery via Reflog abgeschlossen, main intakt. |

### Action Items (für Peter)

1. **🔴 `ark-lint` auf ERP-Tools-Mockups** — billing · commission · elearn · hr · performance · zeit. SNAKE-CASE=189 / UMLAUT=170 / DB-TECH=116 (alle >50). Lint-Pass ausstehend seit 2026-04-20. Gezielte Resolutions schreiben.

2. **🔴 Billing-Spec erstellen** — `ARK_BILLING_SCHEMA_v0_1.md` + `ARK_BILLING_INTERACTIONS_v0_1.md`. 9 Mockups ohne Entity-Spec ist Reverse Drift. Vorlage: ARK_HR_TOOL_SCHEMA_v0_1.md.

3. **🟡 Billing Frontend-Freeze + Gesamtsystem Grundlagen-Patches** — Analog zu Performance-Patches: `ARK_FRONTEND_FREEZE_PATCH_*billing*` + `ARK_GESAMTSYSTEM_PATCH_*billing*` erstellen, um Billing-UI-Patterns in Freeze zu dokumentieren.

4. **🟡 Stammdaten-Vollansicht vervollständigen** — SCHEMA + INTERACTIONS-Spec schreiben. Mockup + Plan existieren. (Carryover seit 2026-04-20)

5. **🟢 Admin-Debug Mockup** — `admin-debug.html` anlegen oder explizit in `admin.html` Scope-Note ergänzen. (Carryover)
