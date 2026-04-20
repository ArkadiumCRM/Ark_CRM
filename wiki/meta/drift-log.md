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
| **REVERSE DRIFT: ERP Tools** | 🔴 HOCH | 16 Mockups in `mockups/ERP Tools/` (commission×6, hr×7, zeit×3) ohne korrespondierende Specs in `specs/ARK_COMMISSION_*/ARK_HR_*/ARK_ZEITERFASSUNG_*` |
| Admin-Debug-Spec ohne Mockup | 🟡 MITTEL | `ARK_ADMIN_DEBUG_SCHEMA_v1_0.md` neu — kein `admin-debug.html` in Vollansichten (admin.html berührt, aber kein Debug-spezifisches Mockup) |
| Stammdaten-Vollansicht Plan-only | 🟡 MITTEL | `ARK_STAMMDATEN_VOLLANSICHT_PLAN_v0_1.md` existiert, `stammdaten.html` berührt — aber kein SCHEMA oder INTERACTIONS Spec |
| Pipeline-Component-Spec ohne Mockup | 🟢 NIEDRIG | `ARK_PIPELINE_COMPONENT_v1_0.md` ist Komponenten-Spec, kein dediziertes Mockup erwartet — ok |
| Dashboard-Customization ohne Mockup | 🟢 NIEDRIG | `ARK_DASHBOARD_CUSTOMIZATION_SCHEMA_v1.md` — `dashboard.html` berührt ✓ |
| Alle 13 Entity-/Tool-Masken | ✅ SYNCED | Kandidat · Account · Mandat · Projekt · Prozess · Assessment · Scraper · Email-Kalender · Reminders · Dok-Generator · Admin · Firmengruppe · Job — alle spec+mockup beide berührt |
| Grundlagen-Changelog | ✅ CLEAN | 0 unresolved entries |
| Digests | ✅ CURRENT | Alle 5 Digests aktuell (letzter Clean 2026-04-17 18:18) |

### Action Items (für Peter)

1. **🔴 ERP-Tools-Specs schreiben** — `ARK_COMMISSION_SCHEMA_v0_1.md`, `ARK_HR_SCHEMA_v0_1.md`, `ARK_ZEITERFASSUNG_SCHEMA_v0_1.md` erstellen, bevor ERP-Mockups weiter wachsen. Reverse-Drift schließt sich nur mit Spec-Erstellung.

2. **🔴 `ark-lint` auf ERP-Tools-Mockups** — 16 neue HTML-Files in `mockups/ERP Tools/` noch nie gelinted. Wahrscheinlich Hauptquelle der SNAKE-CASE=188 + UMLAUT=161 Kumulativ-Counts. Einen gezielten Lint-Pass starten.

3. **🟡 Stammdaten-Vollansicht vervollständigen** — Plan-Spec vorhanden, aber kein SCHEMA/INTERACTIONS-Spec. Entweder Spec erstellen oder Mockup als Draft markieren.

4. **🟡 Admin-Debug-Mockup** — `ARK_ADMIN_DEBUG_SCHEMA_v1_0.md` spezifiziert Debug-Ansicht, aber kein `admin-debug.html` existiert. Falls Feature geplant: Mockup anlegen oder in `admin.html` integrieren und Spec-Scope anpassen.

5. **🟢 Powershell-Hook** — `ark-status.ps1` läuft nur im Windows-Env. Für Monday-Scans in Linux-Umgebung: Bash-Fallback oder Ergebnisse via Windows-Session vorbereiten.

6. **🟢 `/ark-sync-report`** — Nach ERP-Spec-Erstellung ein vollständiger Sync-Report empfohlen (13 Entity-Specs × 5 Grundlagen-Files).
