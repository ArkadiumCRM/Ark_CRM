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
| ERP-Specs in separatem Verzeichnis | 🟡 MITTEL | ERP-Tools-Specs liegen in `ERP Tools/specs/` statt `specs/` — 15 Spec-Dateien (Commission×2, HR×8, Zeiterfassung×2, Eval×2). Intentional (ERP-Phase-Trennung) oder Struktur-Drift? |
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

3. **🟡 ERP-Specs-Verzeichnis klären** — Intentional in `ERP Tools/specs/` (ERP-Phase-Trennung) oder nach `specs/` migrieren? Entscheidung dokumentieren, dann konsistent halten.

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
