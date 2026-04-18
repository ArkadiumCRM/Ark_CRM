---
title: "ARK Database Schema v1.3"
type: source
created: 2026-04-08
updated: 2026-04-14
sources: ["ARK_DATABASE_SCHEMA_v1_3.md", "ARK_DATABASE_SCHEMA_v1_2.md"]
tags: [source, database, schema, technical]
---

# ARK Database Schema v1.3

**Aktuelle Datei:** `raw/Ark_CRM_v2/ARK_DATABASE_SCHEMA_v1_3.md`
**Vorherige Version:** `raw/Ark_CRM_v2/ARK_DATABASE_SCHEMA_v1_2.md` (bleibt erhalten)

## v1.3 (14.04.2026) — Konsolidierung der Detailseiten-Specs

**28 neue Fact-/Bridge-Tabellen + 15 dim_*-Stammdaten + 30+ Feld-Erweiterungen.**

Ergebnis des Komplett-Audits und der 14 Klärungs-Entscheidungen. Erweiterung zu v1.2, **nicht Ersetzung**.

### Neue Tabellen nach Bereich

- **Mandat-Lifecycle (4):** fact_mandate_option, fact_candidate_presentation, fact_protection_window, fact_referral
- **Assessment-Modul (5):** fact_assessment_order, fact_assessment_order_credits, fact_assessment_run, fact_assessment_billing, fact_candidate_assessment_version
- **Prozess + Matching (2):** fact_process_interviews, fact_candidate_matches
- **Firmengruppen (2):** dim_firmengruppen, bridge_mandate_accounts
- **Scraper (6):** fact_scraper_schedule, fact_scraper_runs, fact_scraper_findings, fact_scraper_alerts + dim_scraper_types + dim_scraper_global_settings
- **Projekte (8):** fact_projects, fact_project_bkp_gewerke, fact_project_company_participations, fact_project_candidate_participations, fact_project_media, fact_account_project_notes, bridge_project_clusters, bridge_project_spartens + Phase 1.5: fact_project_similarities
- **Stammdaten (15 dim_*):** siehe Stammdaten-Export v1.3

### Feld-Erweiterungen

- **fact_mandate:** +10 Felder (Kündigung, Longlist-Lock, Gruppen-Binding, Projekt-Link)
- **fact_mandate_billing.billing_type:** +termination, +option, +refund
- **fact_jobs:** +29 Felder (Stellenbeschreibung-Markdown, Matching-Kriterien, Konditionen, Lifecycle)
- **fact_process_core:** +4 Felder (on_hold_reason, stale_detected_at, cancellation_reason, cancelled_by)
- **dim_accounts:** +3 Felder (group_id, growth_rate_3y_pct, revenue_last_year_chf)
- **dim_automation_settings:** +20 Konfig-Keys
- **fact_candidate_briefing:** UNIQUE-Constraint entfernt
- **Rating-Range 1-10** statt 1-5 in bridge_candidate_* Tabellen

### 14 aufgelöste Widersprüche

Inkl. Sprachstandard `candidate_id`, `volume_range` Generated Column, Protection-Window ONE-OF, Polymorphe FK strict CHECK, Bridge-Tabellen statt JSONB, typisierte Credits, etc.

### 3 neue Views

- `v_protection_window_claims` — Claim-Pending über beide Scopes
- `v_assessment_credits_account_summary` — Account-Credits-Aggregation
- `v_assessment_credits_order_summary` — Order-Credits-Aggregation

### Migrations-Roadmap (Waves)

Wave 1 (parallel, P0, 6-8 Wochen): Firmengruppen + Assessment + Mandat-Optionen + Schutzfrist + Scraper + Prozess-Interviews
Wave 2 (4-6 Wochen): Projekt-Modul + Matching + fact_jobs-Felder + Views
Wave 3 (2 Wochen): Restliche Stammdaten-Kataloge + Automation-Settings-Erweiterung

## v1.2 (unverändert)

Vollständiges Datenbankschema mit ~161 Tabellen + 13 Views in 21 Sektionen. PostgreSQL mit pgvector Extension, nur `ark` Schema.

## Schlüssel-Patterns (v1.2)

- UUID überall, Soft Delete, Optimistic Locking (`row_version`)
- Naming: `dim_*` (Master), `fact_*` (Transaktional), `bridge_*` (M:N)
- Historisierung via `valid_from`/`valid_to`/`is_current`
- Immutable Logs (INSERT only): `fact_audit_log`, `fact_event_log`, `fact_webhook_logs`
- 35 Phase-2-Tabellen als Scaffold vordefiniert
- 10 deprecated Tabellen (Skills → Focus Migration)

## Verlinkte Wiki-Seiten

[[datenbank-schema]], [[kandidat]], [[account]], [[job]], [[mandat]], [[prozess]], [[event-system]], [[stammdaten]], [[audit-2026-04-13-komplett]], [[audit-entscheidungen-2026-04-14]], [[status-enum-katalog]]
