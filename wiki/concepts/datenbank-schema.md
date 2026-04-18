---
title: "Datenbank-Schema"
type: concept
created: 2026-04-08
updated: 2026-04-08
sources: ["ARK_DATABASE_SCHEMA_v1_2.md"]
tags: [concept, database, schema, technical]
---

# Datenbank-Schema

Supabase PostgreSQL mit pgvector Extension. ~161 Tabellen + 13 Views. Nur `ark` Schema (kein `public`).

## Grundregeln

1. **Alle IDs sind UUID** (Ausnahme: `dim_date.date_id` ist INT)
2. **Nur `ark` Schema** — `public` existiert nicht
3. **Kein Hard Delete** — immer `is_active` + `deleted_at`
4. **Master Data (dim_*) ist global** — kein `tenant_id`
5. **AI schreibt nie direkt** in operative Tabellen
6. **Jede State-Änderung** erzeugt Event in `fact_event_queue`
7. **Business Write + Event Insert** immer in einer Transaktion
8. **Tokens/Secrets nie in Plaintext** — nur Referenzen
9. **PII maskiert** in Logs
10. **`fact_audit_log`** — INSERT only, kein UPDATE, kein DELETE

## Namenskonvention

| Prefix | Typ | Beispiel |
|--------|-----|---------|
| `dim_*` | Dimension/Master Data | `dim_cluster`, `dim_functions` |
| `fact_*` | Transaktional/Operativ | `fact_history`, `fact_process_core` |
| `bridge_*` | Many-to-Many | `bridge_candidate_functions` |
| `v_*` | Views | `v_candidate_duplicates` |

## Standard-Felder

**Operative Tabellen:** `id` (UUID), `tenant_id`, `is_active`, `created_at`, `updated_at`, `row_version`, `deleted_at`, `deleted_by`, `deletion_reason`

**Master Data:** `id`, `is_active`, `created_at`, `updated_at`, `row_version`

**Historisierung:** `valid_from`, `valid_to`, `is_current` (auf Bridge-Tabellen)

## Tabellen-Übersicht nach Bereich

### Event Backbone (5 Tabellen)
`dim_event_types`, `dim_automation_rules`, `fact_event_queue`, `fact_event_log`, `fact_notifications`

### Kandidaten (14+ Tabellen)
`dim_candidates_profile` + 7 Bridge-Tabellen + `fact_candidate_briefing`, `fact_candidate_employment`, `fact_candidate_projects`

### Accounts (10+ Tabellen)
`dim_accounts`, `dim_account_contacts`, `dim_account_groups`, `dim_account_aliases`, `fact_account_locations` + 6 Bridge-Tabellen

### Jobs (10+ Tabellen)
`fact_jobs`, `fact_jobbasket`, `fact_vacancies` + 7 Bridge-Tabellen

### Mandate (3 Tabellen)
`fact_mandate`, `fact_mandate_billing`, `fact_mandate_research`

### Prozesse (3 + 7 Master)
`fact_process_core`, `fact_process_events`, `fact_process_finance` + `dim_process_stages`, `dim_rejection_reasons_*`, etc.

### Activity/History (4 + 1 Master)
`fact_history`, `fact_reminders`, `fact_call_context`, `dim_activity_types`

### Assessments (12+ Tabellen)
`fact_assessment_disc/driving_forces/eq/ikigai/outmatch/human_needs_bip/stressoren/resilienz/motivation/results/cross_analysis/invites`

### Scraper (4 Tabellen)
`fact_scraped_items`, `fact_scrape_snapshots`, `fact_scrape_changes`, `fact_job_platforms`

### Analytics (6 Tabellen)
`dim_mitarbeiter`, `dim_roles`, `bridge_mitarbeiter_roles`, `fact_goals`, `fact_positions_raster`, `dim_salary_benchmark`

### AI/RAG (5 Tabellen)
`fact_embeddings` (pgvector 1536d), `dim_embedding_chunks`, `fact_ai_classifications`, `fact_ai_suggestions`, `fact_match_scores`

### Dokumente (1 Tabelle)
`fact_documents` — Versioned, OCR Status, Retention Classes

### Kommunikation (7 Tabellen)
`dim_email_templates`, `dim_prompt_templates`, `dim_notification_templates`, `dim_integration_tokens`, `dim_webhooks`, `fact_webhook_logs`, `fact_email_drafts`

### Auth/System (6 Tabellen)
`dim_crm_users`, `app_users`, `fact_audit_log`, `tenants`, `dim_pii_classification`, `dim_ai_write_policies`

### Master Data / Stammdaten (10 Tabellen)
`dim_cluster`, `dim_functions`, `dim_focus`, `dim_edv`, `dim_education`, `dim_sector`, `dim_sparte`, `dim_languages`, `dim_projects`, `dim_date`

## Views (13)

| View | Zweck |
|------|-------|
| `v_candidates_overview` | Kandidatenliste |
| `v_mandate_overview` | Mandate mit KPIs |
| `v_goals_progress` | Ziel-Fortschritt |
| `v_open_reminders` | Offene Reminders |
| `v_open_vacancies` | Offene Vakanzen |
| `v_account_intelligence` | Account KPIs |
| `v_candidate_duplicates` | Kandidaten-Duplikate |
| `v_account_duplicates` | Account-Duplikate |
| `v_salary_warnings` | Gehalts-Mismatches |
| `v_powerbi_kandidaten` | Power BI Export |
| `v_powerbi_prozesse` | Power BI Export |
| `v_powerbi_umsatz` | Power BI Export |
| `v_powerbi_markt` | Power BI Export |

## Phase 2 Scaffold (35 Tabellen, leer)

Vordefinierte Schemas für: Messaging, Zeiterfassung, Performance, Development, Payroll, Job Postings, Publishing, Markt/Org, Buchhaltung.

## Deprecated (10 Tabellen)

`dim_skills_master` + 9 zugehörige Tabellen — ersetzt durch `dim_focus`.

## Architektur-Patterns

- **Optimistic Locking:** `row_version` auto-increment via Trigger
- **Tenant Isolation:** Alle operativen Tabellen mit `tenant_id` FK
- **Event Sourcing:** Alle State Changes durch `fact_event_queue`
- **Immutable Logs:** `fact_audit_log`, `fact_event_log`, `fact_webhook_logs` — INSERT only
- **Full-Text Search:** GIN Index auf Kandidatennamen (German text search)
- **Vector Search:** pgvector IVFFlat für 1536d Embeddings

## Related

- [[backend-architektur]] — 6-Layer-Architektur
- [[event-system]] — Event Backbone Details
- [[kandidat]] — Kandidaten-Tabellen im Detail
- [[stammdaten]] — Master Data Katalog
