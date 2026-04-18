---
title: "Detailseiten-Inventar"
type: meta
created: 2026-04-13
updated: 2026-04-17
tags: [detailseiten, inventar, spec-status, roadmap]
---

# Detailseiten-Inventar

Status aller Detailseiten + Tool-Masken im ARK CRM gemäss [[detailseiten-guideline]]. Jede Seite braucht **Schema** + **Interactions**.

## Entity-Detailseiten (9)

| # | Detailseite | Route | Schema | Interactions | Status |
|---|-------------|-------|--------|--------------|--------|
| 1 | **Kandidaten** | `/candidates/[id]` | `ARK_KANDIDATENMASKE_SCHEMA_v1_3.md` ✅ | `ARK_KANDIDATENMASKE_INTERACTIONS_v1_3.md` ✅ | v1.3 (14.04.2026): Projekt-Autocomplete Briefing, Werdegang-Projekt-FK, Assessment-Versionierung-Nav, Schutzfrist-Awareness, Prozess-Drawer |
| 2 | **Accounts** | `/accounts/[id]` | `ARK_ACCOUNT_DETAILMASKE_SCHEMA_v0_3.md` ✅ | `ARK_ACCOUNT_DETAILMASKE_INTERACTIONS_v0_3.md` ✅ | v0.2 (14.04.2026): Schema + Interactions konsolidiert — Tab 8 Assessments (typisierte Credits), Tab 9 Schutzfristen (Gruppen-Scope, AM-Claim) |
| 3 | **Firmengruppen** | `/company-groups/[id]` | `ARK_FIRMENGRUPPE_DETAILMASKE_SCHEMA_v0_1.md` ✅ | `ARK_FIRMENGRUPPE_DETAILMASKE_INTERACTIONS_v0_1.md` ✅ | 6 Tabs, gruppenübergreifende Taskforces, Schutzfrist gruppenweit — v0.1 komplett (13.04.2026) |
| 4 | **Mandate** | `/mandates/[id]` | `ARK_MANDAT_DETAILMASKE_SCHEMA_v0_2.md` ✅ | `ARK_MANDAT_DETAILMASKE_INTERACTIONS_v0_3.md` ✅ | v0.2 (14.04.2026): Kündigung AM-alleine (Admin-Gate raus), `is_longlist_locked`, Claim-Fälle X/Y/Z |
| 5 | **Jobs** | `/jobs/[id]` | `ARK_JOB_DETAILMASKE_SCHEMA_v0_1.md` ✅ | `ARK_JOB_DETAILMASKE_INTERACTIONS_v0_1.md` ✅ | Volle Detailseite mit 6 Tabs (Übersicht/Jobbasket/Matching/Prozesse/Dokumente/History), v0.1 komplett (13.04.2026) |
| 6 | **Prozesse** | `/processes/[id]` | `ARK_PROZESS_DETAILMASKE_SCHEMA_v0_1.md` ✅ | `ARK_PROZESS_DETAILMASKE_INTERACTIONS_v0_1.md` ✅ | Mischform: Pipeline-Modul Hauptarbeitsort + schlanke 3-Tab-Detailseite · **Mockup Phases A–H komplett (16.04.2026)**: 9-Stage-Kacheln-Pipeline, 11 Drawers, V1–V7 Saga+UI-Readiness, Refund-Modell-Router (Erfolgsbasis-Staffel vs Mandat-Ersatzbesetzung), 3-Mt-[[garantiefrist]] abgegrenzt von 12/16-Mt-Schutzfrist, Per-Stage-Stale-Schwellen + Simulation, Keyboard-Shortcuts |
| 7 | **Assessments** | `/assessments/[id]` | `ARK_ASSESSMENT_DETAILMASKE_SCHEMA_v0_2.md` ✅ | `ARK_ASSESSMENT_DETAILMASKE_INTERACTIONS_v0_2.md` ✅ | v0.2 mit **typisierten Credits** (14.04.2026). v0.1 in `/specs/alt/` |
| 8 | **Scraper** | `/scraper` | `ARK_SCRAPER_MODUL_SCHEMA_v0_1.md` ✅ | `ARK_SCRAPER_MODUL_INTERACTIONS_v0_1.md` ✅ | System-/Monitoring-Modul mit 6 Tabs, Review-Queue, 7 Scraper-Typen, AI-Extraction — v0.1 komplett (13.04.2026) |
| 9 | **Projekte** | `/projects/[id]` | `ARK_PROJEKT_DETAILMASKE_SCHEMA_v0_2.md` ✅ | `ARK_PROJEKT_DETAILMASKE_INTERACTIONS_v0_1.md` ✅ | Schema v0.2 (14.04.2026): Bridge-Tabellen, SIA 6+12 hierarchisch, Generated Column volume_range |

## Tool-Masken (3)

Operative Tools ohne Entity-Bindung. Gleiche Spec-Anforderungen wie Entity-Detailseiten.

| # | Tool-Maske | Route | Schema | Interactions | Status |
|---|-----------|-------|--------|--------------|--------|
| T1 | **Dok-Generator** | `/operations/dok-generator` | `ARK_DOK_GENERATOR_SCHEMA_v0_1.md` ✅ | `ARK_DOK_GENERATOR_INTERACTIONS_v0_1.md` ✅ | v0.1 (17.04.2026): 38 Templates, 5-Step-Workflow, Deep-Link aus Entity-CTAs |
| T2 | **Email & Kalender** | `/operations/email-kalender` | `ARK_EMAIL_KALENDER_DETAILMASKE_SCHEMA_v0_1.md` ✅ | `ARK_EMAIL_KALENDER_DETAILMASKE_INTERACTIONS_v0_1.md` ✅ | v0.1 (17.04.2026): Unified Inbox, Mode-Toggle Email↔Kalender, MS-Graph-User-Tokens |
| T3 | **Reminders** | `/reminders` | `ARK_REMINDERS_VOLLANSICHT_SCHEMA_v0_1.md` ✅ | `ARK_REMINDERS_VOLLANSICHT_INTERACTIONS_v0_1.md` ✅ | v0.1 (17.04.2026): Cross-Entity, Liste + Kalender, Scope self/team/all, Saved-Views, Drag-to-Reschedule — Plan: `ARK_REMINDERS_VOLLANSICHT_PLAN_v0_1.md` |

## System-Vollansichten (1 + Phase 2)

System-Konfigurations-Oberflächen. Sidebar-Sektion „System" enthält **nur 2 Einträge** (entschieden 18.04.2026):

```
System
├── 🗂 Stammdaten   (Kataloge `dim_*` + Doc-Templates · alle Rollen Read · Admin Edit)
└── 🔧 Admin        (System-Config · admin-only · siehe S1)
```

**Nicht mehr im Sidebar (Variante A · 18.04.2026):**
- ⚙ **Settings** — User-Präferenzen sind im **Profil-Dropdown** (Sidebar-User-Footer-Click): Mein Profil · Notifikationen · Email-Signatur · Theme · Shortcuts · Hilfe · Abmelden
- 👥 **Team** — Quick-Lookup über `⌘K`-Search + Mitarbeiter-Avatare in Entities (Hover-Card). Volle Verwaltung in HR-Tool Phase 2.

| # | Vollansicht | Route | Schema | Interactions | Status |
|---|-------------|-------|--------|--------------|--------|
| S1 | **Admin** | `/admin` | `ARK_ADMIN_VOLLANSICHT_SCHEMA_v0_1.md` ✅ | `ARK_ADMIN_VOLLANSICHT_INTERACTIONS_v0_1.md` ✅ | v0.1 (17.04.2026): 10 Tabs (Feature-Flags · Automation · Templates · Email · Telefonie · Scraper · Notifications · Dashboard-Templates · Debug · Audit). Admin-only (HoD ohne Zugriff). Debug-Tab inkludiert `ARK_ADMIN_DEBUG_SCHEMA_v1_0.md`. Migration: `migrations/003_admin_vollansicht_addendum.sql`. Mobile: `admin-mobile.html` (Bottom-Sheet-Drawer). Eigene Spec-Klasse — Single-Write-Entry-Point siehe [[spec-sync-regel]] §Admin-als-Sync-Knotenpunkt |
| S2 | **HR-Tool** | `/hr` (Phase 2) | — (offen) | — (offen) | Phase 2 · Feature-Flag `feature_hr_tool` locked. Scope: Arbeitsverträge · Onboarding · Lifecycle · RBAC-Editor · **Team-Verwaltung (komplett)** |

## Nicht im CRM (werden im ERP abgebildet)

- **Mitarbeiter** — kommt im ERP-Programm unter HR
- **Reporting / Performance** — wird im ERP-Tool als Performance-Tool kommen. Im CRM nur das **Dashboard** als laufende Übersicht (siehe [[reportings-am-cm-tl]] als Referenz, aber keine eigene Reporting-Detailseite im CRM)

## Priorisierung (Vorschlag)

**P0 — Bestehende Specs aufarbeiten:**
1. ✅ **Mandate Interactions v0.2** — Kündigung/Optionen/Schutzfrist/Taskforce (13.04.2026)
2. ✅ **Mandate Schema v0.1** — neu erstellt (13.04.2026)
3. ✅ **Accounts Schema v0.1** — neu erstellt mit Tab 8 Assessments + Tab 9 Schutzfristen (13.04.2026)
4. ✅ **Accounts Interactions v0.2** — Tab 8 Assessments + Tab 9 Schutzfristen inkl. Claim-Workflow (13.04.2026)
5. **Kandidaten** — ggf. kleinere Updates für Assessment-Tab-Verknüpfung (offen, P2)

**P1 — Neue Specs:**
4. ✅ **Assessments** — Schema + Interactions mit Credits-Modell (13.04.2026)
5. ✅ **Prozesse** — Schema + Interactions als Mischform (13.04.2026)
6. ✅ **Jobs** — Schema + Interactions volle Detailseite mit Matching-Tab (13.04.2026)

**P2 — Ergänzende Specs:**
7. ✅ **Firmengruppen** — Schema + Interactions mit gruppenweiter Schutzfrist (13.04.2026)
8. ✅ **Scraper** — Schema + Interactions als Monitoring-Tool mit Staging-Review (13.04.2026)
9. ✅ **Projekte** — Schema + Interactions mit 3-Tier BKP/SIA/Beteiligungen (13.04.2026)

---

## Gesamt-Status nach 13.04.2026

**Alle 9 Detailseiten v0.1/v0.2 Erstentwurf fertig.**

Nächster Schritt: **Finale Nachbearbeitungs-Runde** rückwärts durch alle Detailseiten gemäss `detailseiten-nachbearbeitung.md` (~12 Cross-Reference- und Integrations-Punkte).

## Related

[[detailseiten-guideline]], [[frontend-freeze]], [[mandat-lifecycle-gaps]]
