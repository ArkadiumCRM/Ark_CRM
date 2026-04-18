---
title: "ARK Account Detailmaske Schema v0.2"
type: source
created: 2026-04-13
updated: 2026-04-17
sources: ["ARK_ACCOUNT_DETAILMASKE_SCHEMA_v0_3.md"]
tags: [source, account, schema, layout, design, detailseite, snapshot-bar, kpi-bar, org-function]
---

# ARK Account Detailmaske Schema v0.2

**Datei:** `specs/ARK_ACCOUNT_DETAILMASKE_SCHEMA_v0_3.md`
**Status:** v0.2 = Konsistenz-Update nach Audit 14.04.2026
**Begleitdokument:** [[account-interactions]] v0.3

## Änderungen v0.1 → v0.2

- **RBAC-Rolle** `Founder` → `Admin` (global, 14.04.2026)
- **Snapshot-Bar Slots 5+6 ersetzt** — Offene Mandate / Aktive Prozesse → **Gegründet / Standorte** (reine Firmografik). Beziehungs-KPIs leben jetzt in Tab-1-KPI-Bar.
- **Tab 1 Arkadium-Relation KPI-Bar** neu (4 KPIs über 10 Sektionen)
- **Kontakt-Drawer 4-Tab-Struktur** (Tab 3): Stammdaten / Kommunikation / Prozesse / Notizen
- **Kontakt-Rollen-Refactor**: subjektive Flags (`is_decision_maker`/`is_key_contact`/`is_champion`/`is_blocker`) + redundante `decision_level`-Spalte **entfernt** → objektive `org_function` ENUM (7 Codes aus `dim_org_functions`)
- Typisierte Credits-Referenz in Tab 8 (`fact_assessment_order_credits` FK)
- Stale "v0.2-Update ausstehend"-Note entfernt (Interactions v0.3 deckt Tab 8/9 ab)

## Zusammenfassung

Schema-Spec für Account-Detailseite (`/accounts/[id]`) — definiert Layout, Felder pro Tab, Design-Tokens, Berechtigungen.

## Layout-Struktur

- **13 Tabs + 1 konditional** (Firmengruppe wenn `account_group_id IS NOT NULL`)
- **Header mit 6-Slot Snapshot-Bar** (reine Firmografik)
- **Temperature-Badge** (Hot/Warm/Cold) aus 2-Layer-Modell
- **Soft-Block-Banner** für Blacklisted + is_no_hunt

### Tab-Liste (13+1)

1. **Übersicht** (Stammdaten + Arkadium-Relation-KPI-Bar, 10 Sektionen)
2. **Profil & Kultur** (5 Sektionen + AI-Hybrid-Workflow)
3. **Kontakte** (Aktiv + Inaktiv, 4-Tab-Drawer)
4. **Standorte** (HQ-Cards, max 1 HQ/Account)
5. **Organisation** (Subtabs Stellenplan + Teamrad)
6. **Jobs & Vakanzen** (Einheitstabelle Lifecycle)
7. **Mandate** (Tabelle + Entwürfe-Banner)
8. **Assessments** (Tabelle + Teamrad-Abdeckungs-KPI) — *neu v0.1*
9. **Schutzfristen** (Matrix + Claim-Workflow + Auto-Extension-Timer) — *neu v0.1*
10. **Prozesse** (Cross-Navigation Tab 7 ↔ Tab 10)
11. **History** (account-spezifischer Scope)
12. **Dokumente** (8 Kategorien)
13. **Reminders**
\+ **Firmengruppe** (konditional)

## Header-Struktur

### Snapshot-Bar (6 Slots) — Reine Firmografik

**Canonical:** `.snapshot-bar` + `.snapshot-item` (sticky `top:0, z-index:50`, über Tabbar)

| Slot | KPI | Source |
|------|-----|--------|
| 1 | 👥 Mitarbeitende CH-weit | `employee_count` |
| 2 | 📈 Wachstum 3 Jahre | `growth_rate_3y_pct` |
| 3 | 💰 Umsatz letztes GJ | `revenue_last_year_chf` |
| 4 | 🏛 **Gegründet** (mit Alters-Berechnung) | `founded_year` |
| 5 | 📍 **Standorte** | `COUNT(dim_account_locations)` |
| 6 | ⭐ Kulturfit-Score | aus Tab 2 |

### Tab 1 Arkadium-Relation KPI-Bar (neu 14.04.2026)

4 KPI-Kacheln über den 10 Sektionen, komplementär zur Snapshot-Bar:

| KPI | Berechnung |
|-----|-----------|
| 💰 Umsatz mit Arkadium YTD | `SUM(fact_mandate_billing.amount WHERE paid)` + Erfolgsbasis |
| 🏆 Placements total | `COUNT(fact_process_core WHERE status='Placed')` |
| ⏱ Ø Time-to-Hire | Mittel `(placed_at - opened_at)` letzte 12 Mt |
| 📈 Conversion CV→Placement | `Placed / CV Sent` letzte 12 Mt |

## Kontakt-Rollen-Refactor (v0.2)

**Vorher (v0.1):** 4 subjektive Boolean-Flags + `decision_level`-Spalte
**Jetzt (v0.2):** Ein objektiver ENUM `org_function` aus `dim_org_functions` (7 Codes):
- `linie` · `hr` · `management` · `board` · `einkauf` · `assistenz` · `fachspezialist`

In Tabellen-Kopf als Pill angezeigt (L/H/M/B/E/A/F).

## Kontakt-Drawer (Tab 3) — 4-Tab-Struktur

Pro Kontakt-Drawer 4 Tabs (Details siehe Interactions v0.3 TEIL 4):
1. **Stammdaten** — Kontakt-Basisinfos
2. **Kommunikation** — Verlauf mit Filter-Chips + Kennzahlen
3. **Prozesse** — verknüpfte Prozesse
4. **Notizen** — freie Notizen

## Tab 1 — 10 Sektionen

| # | Sektion | Key-Felder |
|---|---------|-----------|
| 1 | Identität | account_name, legal_name, handelsregister_uid, aliases (Drawer), founded_year, status, customer_class, purchase_potential, sparte_id, owner_team |
| 2 | Web & Kontakt | website_url, career_page_url, team_page_url, linkedin_url, country, account_manager_id |
| 3 | Unternehmensgrösse | employee_count, growth_rate_3y_pct, revenue_last_year_chf, revenue_estimate_chf |
| 4 | Klassifikation & Verknüpfungen | industry, taetigkeitsfelder, usp + Sparte/Sector/Cluster/Functions/Focus |
| 5 | Intelligence | penetration_score, hiring_potential_ranking, job_posting_frequency, fluktuation_rate, competitor_headhunters |
| 6 | Flags & Regeln | is_no_hunt, has_had_process, AGB-Block |
| 7 | Scraping | scraping_enabled, scrape_interval_hours, "Jetzt scrapen" |
| 8 | Notizen | comment_short, comment_internal |
| 9 | Zugehörigkeit | account_group_id |
| 10 | Audit | created/updated metadata |

## Tab 9 — Schutzfristen (Claim-Workflow)

Matrix aller aktiven `fact_protection_window`-Einträge:
- **Claim-Pending-Banner** wenn Scraper Kandidat beim Account detektiert, der aktive Schutzfrist hat
- **Auto-Extension-Timer**: `info_requested_at` gesetzt, `info_received_at` NULL → nach 10 Tagen `extended=true`, Banner "Schutzfrist verlängert auf 16 Monate"
- 3 Abschluss-Wege pro Case: Info-Request / Claim stellen / Ohne Claim abschliessen

## Pflichtfelder (hart)

- `account_name`, `country`, `sparte_id`, `account_manager_id`

## Offene Punkte

- Mockup-HTMLs für 13 Tabs (P1)
- Firmengruppen-Detailmaske Schema (konditionaler Tab, P1)
- Teamrad-Visualisierung Details (P1)
- Auto-Match-Algorithmus Kontakte → Kandidat (P1)

## Verlinkte Wiki-Seiten

[[account]], [[account-interactions]], [[kontakt-kandidat-regel]], [[temperatur-modell]], [[mandat]], [[diagnostik-assessment]], [[direkteinstellung-schutzfrist]], [[detailseiten-guideline]]
