---
title: "Database-Schema Digest (v1.3.4)"
type: meta
created: 2026-04-17
updated: 2026-04-17
sources: ["Grundlagen MD/ARK_DATABASE_SCHEMA_v1_3.md"]
tags: [digest, schema, database, grundlagen]
---

# Database-Schema Digest v1.3.4 (Stand 2026-04-17)

Kompakter Lookup-Digest des Grundlagendokuments `Grundlagen MD/ARK_DATABASE_SCHEMA_v1_3.md` (Stand 2026-04-17, ~2560 Zeilen / ~80k Tokens; v1.3 + v1.3.4 Dok-Generator-Addendum §14.1–14.3). Dieser Digest ist **lossless für Tabellen-Liste + Kern-Relationen + ENUMs**, lossy für Spalten-Details, Constraints, Indizes, Beispiele. Für exakte DDL immer die Original-Datei lesen.

---

## TOC (Sektionen im Quelltext)

| § | Titel | Inhalt |
|---|-------|--------|
| 0 | Grundregeln | 10 absolute Regeln (UUID, ark-Schema, Soft-Delete, Events, Audit-Log) |
| 0.1 | Pflichtfelder | Standard-Felder operativ vs. Stammdaten, Trigger, Globale Indizes |
| 0.2 | Historisierung | `valid_from`/`valid_to`/`is_current` für History-relevante Tabellen |
| 1 | Event-Rückgrat | `dim_event_types`, `dim_automation_rules`, `fact_event_queue`, `fact_event_log`, `fact_notifications` |
| 2 | Core — Kandidaten | `dim_candidates_profile`, `fact_candidate_briefing`, `fact_candidate_employment`, `fact_candidate_projects`, 9 Bridges |
| 3 | Core — Accounts | `dim_accounts`, `dim_account_contacts`, `dim_account_groups`, `dim_account_aliases`, `fact_account_locations`, 6 Bridges |
| 4 | Core — Jobs | `fact_jobs`, `fact_jobbasket`, `fact_vacancies`, 7 Bridges |
| 5 | Core — Mandate | `fact_mandate`, `fact_mandate_billing`, `fact_mandate_research` |
| 6 | Core — Prozesse | `fact_process_core`, `fact_process_events`, `fact_process_finance` + 8 Stammdaten |
| 7 | Services — Activity | `fact_history`, `fact_reminders`, `fact_call_context`, `dim_activity_types` |
| 8 | Services — Assessments | 10 Fact-Tabellen + 3 ASSESS-5.0-Stammdaten |
| 9 | Services — Scraper (v1.2 legacy) | `fact_scraped_items`, `fact_scrape_snapshots`, `fact_scrape_changes`, `fact_job_platforms` |
| 10 | Services — Analytics | `dim_mitarbeiter`, `dim_roles`, `bridge_mitarbeiter_roles`, `fact_goals`, `fact_positions_raster`, `dim_salary_benchmark`, 12 Views |
| 11 | Services — Stammdaten | `dim_cluster`, `dim_functions`, `dim_focus`, `dim_edv`, `dim_education`, `dim_sector`, `dim_sparte`, `dim_languages`, `dim_projects`, `dim_date` |
| 12 | AI / RAG / Matching | `fact_embeddings`, `dim_embedding_chunks`, `fact_ai_classifications`, `fact_ai_suggestions`, `fact_match_scores` |
| 13 | Skill Economy | **DEPRECATED v1.2** (10 Tabellen) |
| 14 | Dokumente | `fact_documents` |
| 15 | Integrationen / Kommunikation | `dim_email_templates`, `dim_prompt_templates`, `dim_notification_templates`, `dim_integration_tokens`, `dim_webhooks`, `fact_webhook_logs` |
| 15b | Neue Tabellen v1.2 | `dim_tenant_features`, `dim_automation_settings`, `dim_jobbasket_rejection_types`, `fact_email_drafts`, `v_account_duplicates` |
| 16 | Shared / Auth / System | `dim_crm_users`, `app_users`, `fact_audit_log`, `tenants`, `dim_pii_classification`, `dim_ai_write_policies` |
| 17 | Datenqualität | `dim_quality_rule_types`, `fact_data_quality_issues` |
| 18 | Merge-Logik | `fact_entity_merges` |
| 19 | Phase 2 Scaffold | 35 Tabellen (Messaging, Zeiterfassung, Performance, Entwicklung, Lohnlauf, Ausschreibungen, Publishing, Markt, Buchhaltung) |
| 20 | Migration 004 | Auth-Token-Rotation: `fact_refresh_tokens`, `fact_token_revocations` |
| 21 | Migration 005 | UI-Addendum: `bridge_briefing_projects`, `dim_honorar_settings`, `fact_linkedin_activities` |
| 22 | Migration 007 | v1.2 Performance-Indizes + Schema-Änderungen (Zusammenfassung) |
| 23 | Nachtrag v1.3.1 | Theme-Preference, `dim_dossier_preferences`, Account-UI, Kontakt-Drawer, Org-Funktion-Refactor (Drop is_decision_maker etc. → `org_function` Enum) |
| 14.1 | Addendum v1.3.4 | `document_label` ENUM-Erweiterung (12 neue Labels) |
| 14.2 | Addendum v1.3.4 | Neue Tabelle `dim_document_templates` (Stammdaten) |
| 14.3 | Addendum v1.3.4 | `fact_assessment_order.status` ENUM-Fix (`invoiced` raus) |

**Vor v1.3 Header (Zeilen 1–213):** v1.2 → v1.3 Delta: 28 neue Fact/Bridge-Tabellen, 15 neue dim_*-Stammdaten, 30+ Feld-Erweiterungen, 14 aufgelöste Widersprüche, neue Views (`v_protection_window_claims`, `v_assessment_credits_account_summary`, `v_assessment_credits_order_summary`), 30 neue Event-Typen, 3 Migrations-Waves.

---

## Tables (lossless list)

### Dimensions (Stammdaten, kein tenant_id — global)

**Core-Enums / Taxonomien:**
- `dim_cluster` — Cluster-Hierarchie (Hochbau/Tiefbau etc.), parent-basiert
- `dim_functions` — Funktionen/Rollen-Katalog, hierarchisch
- `dim_focus` — Fachliche Spezialisierungen (ersetzt Skills seit v1.2), hierarchisch
- `dim_edv` — Software/Tools-Katalog (Vendor, Version)
- `dim_education` — Bildungsabschlüsse/-institutionen
- `dim_sector` — Branchen-Klassifizierung
- `dim_sparte` — Sparten (ARC/GT/ING/PUR/REM) mit Lead
- `dim_languages` — Sprachen mit Code + National-Flag
- `dim_projects` — Bauprojekt-Stammdaten (alt, v1.3 erweitert durch `fact_projects`)
- `dim_date` — Datumsdimension 2020–2035 (INT PK, für Power BI)
- `dim_firmengruppen` — Firmengruppen (v1.3, für Gruppen-Taskforces + Schutzfrist)
- `dim_sia_phases` — SIA-Bauphasen (6 Haupt + 12 Teil, v1.3)
- `dim_culture_dimensions` — Kultur-Dimensionen (v1.3)
- `dim_dossier_preferences` — 7 Dossier-Versand-Präferenzen (v1.3.1)
- `dim_org_functions` — Org-Funktionen (vr_board/executive/hr/einkauf/assistenz, v1.3.1)

**Prozess/Mandat/Ablehnung-Stammdaten:**
- `dim_process_stages` — Pipeline-Stages (Expose·CV Sent·TI·1st·2nd·3rd·Assessment·Offer·Placement)
- `dim_process_status` — Prozess-Status
- `dim_rejection_reasons_candidate` — Ablehnungsgründe seitens Kandidat
- `dim_rejection_reasons_client` — Ablehnungsgründe seitens Kunde
- `dim_rejection_reasons_internal` — Interne Ablehnungsgründe (v1.3)
- `dim_cancellation_reasons` — Abbruch-Gründe
- `dim_dropped_reasons` — Dropped-Gründe (v1.3)
- `dim_offer_refused_reasons` — Offer-Refused-Gründe (v1.3)
- `dim_vacancy_rejection_reasons` — Vakanz-Ablehnungs-Gründe (v1.3)
- `dim_final_outcome` — Final-Outcome-Katalog
- `dim_jobbasket_rejection_types` — Prelead-Ablehnungsgründe (v1.2, Kategorie candidate/cm/am)

**Event/Automation/Messaging:**
- `dim_event_types` — Event-Typ-Katalog (14 Kategorien)
- `dim_automation_rules` — Automation-Regeln mit Circuit Breaker (operativ, tenant_id)
- `dim_automation_settings` — Konfigurierbare Fristen/Schwellwerte pro Tenant (v1.2, erweitert v1.3 um 20+ Keys)
- `dim_reminder_templates` — Reminder-Templates (v1.3)
- `dim_time_packages` — Zeit-Paket-Definitionen für Time-Mandate (v1.3)
- `dim_email_templates` — Email-Templates (template_key, linked_activity_type, linked_automation_key)
- `dim_prompt_templates` — AI-Prompt-Templates
- `dim_notification_templates` — Push/In-App-Notification-Templates

**Assessment:**
- `dim_assessment_types` — Assessment-Typen-Katalog (MDI/Relief/ASSESS 5.0 etc., v1.3)
- `dim_outmatch_competencies` — ASSESS-5.0-Kompetenzen
- `dim_outmatch_job_profiles` — ASSESS-5.0-Job-Profile
- `dim_outmatch_profile_competencies` — Bridge Profile↔Competency mit weight

**Activity/History:**
- `dim_activity_types` — Activity-Types (11 Kategorien, Single Source of Truth für `fact_history`)

**Mitarbeiter/Auth/System:**
- `dim_mitarbeiter` — Mitarbeiter (operativ, hat tenant_id — hier gelistet wegen Stammdaten-Charakter)
- `dim_roles` — Rollen-Stammdaten (Admin/CM/AM/Researcher/Head_of/Backoffice/Assessment_Manager/ReadOnly)
- `dim_crm_users` — CRM-User (operativ, Passwort-Hash, WebAuthn)
- `dim_pii_classification` — PII-Klassifizierung pro Tabelle/Feld
- `dim_ai_write_policies` — AI-Governance (per Entity/Field welche Policy gilt)
- `dim_tenant_features` — Feature Flags pro Tenant (v1.2)
- `dim_honorar_settings` — Honorar-Konfiguration pro Tenant (v1.3 formal dokumentiert)
- `dim_integration_tokens` — OAuth/API-Token-Metadata (secret_ref, kein Klartext)
- `dim_webhooks` — Registrierte Webhook-Endpunkte
- `dim_salary_benchmark` — Gehalts-Benchmarks (historisiert)
- `dim_embedding_chunks` — Text-Chunks für Embeddings
- `dim_account_groups` — Account-Gruppen (operativ)
- `dim_account_aliases` — Account-Aliase (operativ)
- `dim_account_contacts` — Account-Kontakte (operativ, historisiert)
- `dim_candidates_profile` — Kandidaten-Stammdaten (operativ, historisiert — zentrale Tabelle)
- `dim_accounts` — Account-Stammdaten (operativ, zentrale Tabelle)

**Scraper (v1.3):**
- `dim_scraper_types` — Scraper-Typ-Registry
- `dim_scraper_global_settings` — Scraper-Settings (global)

**Matching (v1.3):**
- `dim_matching_weights` — Matching-Gewichte (Kandidat↔Job)
- `dim_matching_weights_project` — Matching-Gewichte (Projekt-Kontext)

**Dok-Generator (v1.3.4, neu 2026-04-17):**
- `dim_document_templates` — Template-Katalog Dok-Generator (38 aktiv + 1 ausstehend in 7 Kategorien)

**Buchhaltung Phase 2 Scaffold:**
- `dim_chart_of_accounts` — Kontenplan Schweizer KMU-Standard

**Quality:**
- `dim_quality_rule_types` — Datenqualitäts-Regeln

**Sonstige:**
- `dim_skills_master`, `dim_skill_aliases` — **DEPRECATED v1.2**

### Facts (operativ, tenant_id + Pflichtfelder)

**Event-Rückgrat:**
- `fact_event_queue` — Zentrale Event-Queue (Idempotency, Retry, Dead Letter)
- `fact_event_log` — Unveränderliches Event-Log (nur INSERT)
- `fact_notifications` — Notifications (Push/Email/In-App/SMS)

**Kandidaten:**
- `fact_candidate_briefing` — Briefing-Versionen (unbegrenzt pro Kandidat seit v1.3)
- `fact_candidate_employment` — Beschäftigungshistorie
- `fact_candidate_projects` — Projekt-Referenzen des Kandidaten
- `fact_candidate_presentation` — Kandidaten-Vorstellungen (Schutzfrist-Trigger, v1.3)
- `fact_candidate_assessment_version` — Zentrale Versionierung Test-Ergebnisse (v1.3)
- `fact_candidate_matches` — Matching-Scores Kandidat↔Job (7 Sub-Scores, v1.3)

**Accounts:**
- `fact_account_locations` — Account-Standorte
- `fact_account_project_notes` — AM-Notizen pro Account×Projekt (v1.3)

**Jobs/Mandate:**
- `fact_jobs` — Jobs (+29 Felder in v1.3: description_md, salary, pensum, matching, publication, lifecycle)
- `fact_jobbasket` — Prelead/Oral-Go/Written-Go/CV-Sent Flow
- `fact_vacancies` — Erkannte Vakanzen (Scraper/Manual)
- `fact_mandate` — Mandate (+10 Felder v1.3: terminated_*, group_id, linked_project_id, is_longlist_locked)
- `fact_mandate_option` — Mandat-Optionen VI–X (Idents/Dossiers/Marketing/Assessment/Garantie, v1.3)
- `fact_mandate_billing` — Rechnungen (Types: Retainer/Success/Milestone + termination/option/refund)
- `fact_mandate_research` — Longlist/Research-Kandidaten pro Mandat

**Prozesse:**
- `fact_process_core` — Prozess-Kern (Stage + Status, UNIQUE offener Prozess pro Kandidat×Job)
- `fact_process_events` — Datum-Events pro Stage
- `fact_process_finance` — Fee/Commission/Guarantee pro Prozess
- `fact_process_interviews` — Interview-Timeline (v1.3)

**Schutzfrist / Referral:**
- `fact_protection_window` — Schutzfrist-Fenster 12/16 Mt (scope=account/group, v1.3)
- `fact_referral` — Referral-Prämien-Tracking (v1.3)

**Assessment:**
- `fact_assessment_order` — Assessment-Auftrag (Credits-Modell v0.2, v1.3)
- `fact_assessment_run` — Assessment-Durchführung pro Credit (v1.3)
- `fact_assessment_billing` — Assessment-Rechnungen (v1.3)
- `fact_assessment_disc` — DISC (red/yellow/green/blue natural+adapted + 12 Sub)
- `fact_assessment_driving_forces` — 12 Antriebskräfte
- `fact_assessment_eq` — 5 EQ-Dimensionen + eq_total
- `fact_assessment_ikigai` — 4 Felder + 4 Schnittmengen + Text
- `fact_assessment_outmatch` — ASSESS 5.0 (profile_id, competency_scores)
- `fact_assessment_human_needs_bip` — 6 Human Needs + 12 BIP
- `fact_assessment_stressoren` — 8 Stressoren + 5 Antreiber + 3 Coping
- `fact_assessment_resilienz` — 7 Resilienz + 4 Langzeitfolgen + burnout_risk
- `fact_assessment_motivation` — Sinn/Motivation/Energie/Zufriedenheit
- `fact_assessment_results` — Generisch (module + scores jsonb)
- `fact_assessment_cross_analysis` — AI-Cross (strengths/development)
- `fact_assessment_invites` — Einladungs-Tokens

**Scraper:**
- `fact_scraped_items` — Scraped Items (v1.2 legacy)
- `fact_scrape_snapshots` — Scrape-Snapshots (v1.2 legacy)
- `fact_scrape_changes` — Detected Changes (v1.2 legacy)
- `fact_job_platforms` — Job-Platform-Tracking (v1.2 legacy)
- `fact_scraper_schedule` — Scraper-Scheduling mit Priority (v1.3)
- `fact_scraper_runs` — Scraper-Run-Historie (v1.3)
- `fact_scraper_findings` — Scraper-Findings (Review-Queue, v1.3)
- `fact_scraper_alerts` — Scraper-Alerts 4 Severity-Levels (v1.3)

**Projekte (v1.3):**
- `fact_projects` — Bauprojekte
- `fact_project_bkp_gewerke` — Projekt-Gewerke (BKP-basiert)
- `fact_project_company_participations` — Firmen-Beteiligungen
- `fact_project_candidate_participations` — Kandidaten-Beteiligungen
- `fact_project_media` — Projekt-Galerie (Fotos/Renderings)
- `fact_project_similarities` — Projekt-Ähnlichkeits-Cache (P1)

**Activity/History:**
- `fact_history` — **Zentrale Aktivitäts-Tabelle** (polymorphe FKs auf candidate/account/job/process/mandate + call/email + AI-Felder)
- `fact_reminders` — Reminders (polymorphe FKs: candidate/account/job/process/mandate/event) · v1.3.5: + `template_id uuid FK → dim_reminder_templates(id)` + `escalation_sent_at timestamptz` (Idempotenz 48-h-Eskalation)
- `fact_call_context` — Call-Context-Matching (phone_normalized → Entity)
- `fact_linkedin_activities` — LinkedIn-Social-Tracking (v1.2)
- `fact_email_drafts` — Email-Entwürfe (v1.2)

**AI / Matching:**
- `fact_embeddings` — pgvector Embeddings (1536 dim, historisiert)
- `fact_ai_classifications` — AI-Klassifikationen (reviewable, historisiert)
- `fact_ai_suggestions` — AI-Vorschläge (pending/accepted/rejected)
- `fact_match_scores` — Kandidat↔Job Match-Scores (historisiert)

**Analytics:**
- `fact_goals` — Ziele pro Mitarbeiter (Placements/Revenue/Calls/Briefings/GOs/Idents/ClassificationRate)
- `fact_positions_raster` — Positions-Raster pro Account×Funktion

**Dokumente:**
- `fact_documents` — Zentrale Dokumenten-Tabelle (polymorphe FKs, OCR, Embedding-Status, Retention)

**Integrationen:**
- `fact_webhook_logs` — Webhook-Versuche (nur INSERT)

**Auth:**
- `fact_refresh_tokens` — Refresh-Tokens (Family-Based Reuse Detection, v1.2)
- `fact_token_revocations` — JTI-Blacklist (System, v1.2)
- `fact_audit_log` — Audit-Log (nur INSERT)

**Qualität/Merge:**
- `fact_data_quality_issues` — Offene Quality-Issues
- `fact_entity_merges` — Durchgeführte Merges (reversible)

**Buchhaltung Phase 2:**
- `fact_accounting_periods` — Buchungsperioden mit Lock
- `fact_journal_entries` — Doppelte Buchführung (nur INSERT, Stornos als is_reversal)

**Phase 2 Scaffold (leer, Schema definiert):** `fact_messages`, `fact_message_campaigns`, `fact_time_entries`, `fact_absences`, `fact_time_budgets`, `fact_performance_reviews`, `fact_360_feedback`, `fact_development_plans`, `fact_learning_progress`, `fact_competency_ratings`, `fact_payroll`, `fact_invoices`, `fact_expenses`, `fact_job_postings`, `fact_posting_costs`, `fact_posting_stats`, `fact_publications`, `fact_publication_stats`, `fact_organigram_changes`, `fact_market_snapshots`, `fact_competitor_tracking`.

**DEPRECATED v1.2:** `fact_skill_market_value`, `fact_skill_salary_data`, `fact_skill_demand_index`, `fact_function_skill_premium`.

### Bridges (N:N-Beziehungen, historisiert wo sinnvoll)

**Kandidaten-Bridges** (alle mit `UNIQUE (tenant_id, candidate_id, {ref}_id) WHERE is_current`):
- `bridge_candidate_cluster` — candidate ↔ cluster (is_primary_cluster)
- `bridge_candidate_functions` — candidate ↔ function (is_primary_function, rating 1-10)
- `bridge_candidate_focus` — candidate ↔ focus (is_primary_focus, rating 1-10)
- `bridge_candidate_edv` — candidate ↔ edv (rating 1-10, skill_level)
- `bridge_candidate_education` — candidate ↔ education (graduation_year)
- `bridge_candidate_languages` — candidate ↔ language (Muttersprache/C2/C1/B2/B1/A2/A1)
- `bridge_candidate_sector` — candidate ↔ sector
- `bridge_candidate_sparte` — candidate ↔ sparte (sparte_order)
- `bridge_candidate_skill` — **DEPRECATED v1.2**

**Account-Bridges:** `bridge_account_cluster`, `bridge_account_functions`, `bridge_account_focus`, `bridge_account_edv`, `bridge_account_sector`, `bridge_account_sparte` (Schema analog Kandidaten, aber `is_core_*` statt `is_primary_*`).

**Job-Bridges:** `bridge_job_cluster`, `bridge_job_functions`, `bridge_job_focus`, `bridge_job_edv`, `bridge_job_education`, `bridge_job_sector`, `bridge_job_sparte`. `bridge_job_skill` **DEPRECATED**.

**Mandate/Gruppen:**
- `bridge_mandate_accounts` — N:N Mandat↔Account (Gruppen-Taskforce, v1.3)

**Projekte (v1.3):**
- `bridge_project_clusters` — Projekt ↔ Cluster (is_primary)
- `bridge_project_spartens` — Projekt ↔ Sparte (is_primary)

**Briefing:**
- `bridge_briefing_projects` — Briefing ↔ Projekt mit candidate_comment/insider_info/rating (v1.2)

**Mitarbeiter-Rollen:**
- `bridge_mitarbeiter_roles` — Mitarbeiter ↔ Rolle (Multi-Rollen, is_primary_role)

**DEPRECATED v1.2:** `bridge_skill_related_skill`, `bridge_function_skill`.

### Views

- `v_candidates_overview` — Kandidaten-Liste mit Kerndaten
- `v_candidate_duplicates` — Kandidaten-Duplikate (Fuzzy)
- `v_account_duplicates` — Account-Duplikate (v1.2)
- `v_mandate_overview` — Mandate + KPIs
- `v_goals_progress` — Ziele + achievement_pct
- `v_open_reminders` — Offene Reminders
- `v_open_vacancies` — Offene Vakanzen
- `v_account_intelligence` — Account-KPIs
- `v_salary_warnings` — Gehalts-Mismatch
- `v_powerbi_kandidaten`, `v_powerbi_prozesse`, `v_powerbi_umsatz`, `v_powerbi_markt` — Power-BI-Views
- `v_protection_window_claims` — Aktive claim-pending Schutzfristen (v1.3)
- `v_assessment_credits_account_summary` — Credits-Aggregation pro Account (v1.3)
- `v_assessment_credits_order_summary` — Credits-Aggregation pro Auftrag (v1.3)

---

## Core Relationships

**Zentrale Entities + deren FK-Sterne:**

### `dim_candidates_profile` (Kandidat) — zentraler Hub
- ← referenziert von: `fact_candidate_briefing`, `fact_candidate_employment`, `fact_candidate_projects`, `fact_candidate_presentation`, `fact_jobbasket`, `fact_mandate_research`, `fact_process_core`, `fact_history`, `fact_reminders`, `fact_protection_window`, `fact_match_scores`, `fact_candidate_matches`, `fact_linkedin_activities`, `fact_referral`, alle 9 `bridge_candidate_*`, `dim_account_contacts.candidate_id` (Kontakt ist gleichzeitig Kandidat), `app_users.candidate_id`.
- Self-FK: `merged_into_id`, `referral_from_id`.

### `dim_accounts` (Account) — zentraler Hub
- ← referenziert von: `dim_account_contacts`, `fact_account_locations`, `dim_account_aliases`, `fact_candidate_employment` (Arbeitgeber), `fact_jobs`, `fact_vacancies`, `fact_process_core`, `fact_history`, `fact_reminders`, `fact_protection_window` (scope=account), `fact_scraped_items`, `fact_scrape_*`, `fact_job_platforms`, `fact_positions_raster`, `fact_assessment_order`, `fact_account_project_notes`, alle 6 `bridge_account_*`.
- → referenziert: `dim_account_groups` (account_group_id), `dim_firmengruppen` (group_id, v1.3), `dim_sparte`, `dim_mitarbeiter` (account_manager_id).
- Self-FK: `merged_into_id`.

### `fact_jobs` (Job) — verbindet Account × Mandat × Prozess
- → `dim_accounts` (account_id NOT NULL), `dim_account_contacts`, `fact_mandate` (mandate_id nullable), `fact_vacancies`, `fact_projects` (linked_project_id, v1.3), `dim_mitarbeiter` (job_owner), `dim_sparte`, `dim_functions` (target_function_id).
- ← `fact_jobbasket`, `fact_process_core`, `fact_match_scores`, `fact_history`, `fact_reminders`, 7 `bridge_job_*`.

### `fact_mandate` (Mandat)
- → `fact_jobs` (job_id NOT NULL), `dim_mitarbeiter` (owner, lead_researcher), `dim_firmengruppen` (group_id, v1.3), `fact_projects` (linked_project_id, v1.3), `fact_mandate_billing` (termination_invoice_id, v1.3).
- ← `fact_mandate_billing`, `fact_mandate_research`, `fact_mandate_option`, `fact_process_core`, `fact_history`, `fact_reminders`, `bridge_mandate_accounts` (v1.3).

### `fact_process_core` (Prozess) — Kandidat × Account × Job × optional Mandat
- → `dim_candidates_profile` (candidate_id NOT NULL), `dim_accounts` (account_id NOT NULL), `fact_jobs` (job_id NOT NULL), `fact_mandate` (mandate_id nullable), `dim_mitarbeiter` (CM/AM/Researcher), `dim_rejection_reasons_*` / `dim_dropped_reasons` / `dim_offer_refused_reasons` / `dim_cancellation_reasons`.
- ← `fact_process_events`, `fact_process_finance`, `fact_process_interviews`, `fact_jobbasket`, `fact_history`, `fact_reminders`, `fact_positions_raster` (last_placement_id).
- **Invariante:** UNIQUE(tenant_id, candidate_id, job_id) WHERE status NOT IN (Closed/Rejected/Cancelled/Dropped) — max. 1 offener Prozess pro Kandidat×Job.

### `fact_projects` (Bauprojekt, v1.3)
- ← `fact_project_bkp_gewerke`, `fact_project_company_participations`, `fact_project_candidate_participations`, `fact_project_media`, `fact_account_project_notes`, `bridge_project_clusters`, `bridge_project_spartens`, `bridge_briefing_projects`, `fact_project_similarities`.
- → `fact_jobs.linked_project_id`, `fact_mandate.linked_project_id`.

### `fact_history` (Activity/Timeline) — polymorpher Hub
- → **alle** Kern-Entities gleichzeitig nullable: `candidate_id`, `account_id`, `account_contact_id`, `job_id`, `process_id`, `mandate_id`, `location_id`.
- → `dim_activity_types` (activity_type_id NOT NULL — Single Source of Truth für Typ), `dim_mitarbeiter`, `fact_event_queue` (event_id).
- → polymorphe Reason-FKs: `rejection_reason_candidate_id`, `rejection_reason_client_id`, `cancellation_reason_id`, `dropped_reason_id`, `offer_refused_reason_id`.
- **Rolle:** Single Source of Truth für Check-Ins, Debriefings, Coachings, Referenzauskünfte, Stage-Transitions. UI-Felder projizieren aus `fact_history`.

### `fact_jobbasket` (Prelead→CV-Sent-Flow)
- → `dim_candidates_profile`, `fact_jobs`, `fact_process_core` (nullable — vor Prozess-Eröffnung), `dim_mitarbeiter` (assigned_to), `dim_jobbasket_rejection_types`.
- UNIQUE(tenant_id, candidate_id, job_id).

### Schutzfrist-Scope (v1.3)
- `fact_protection_window.scope ENUM('account','group')` + CHECK(ONE-OF account_id vs. group_id).
- `fact_candidate_presentation` triggert Schutzfrist.
- Bei Account in Gruppe: 2 Einträge (account + group Scope).

### Auth-Kette
- `dim_crm_users` ← `dim_mitarbeiter.auth_user_id`, `fact_refresh_tokens`, `fact_audit_log`.
- `app_users` → `dim_candidates_profile` (Kandidaten-App).

### Event-Kette
- `fact_event_queue` causation/parent-Self-FK → Event-DAG. correlation_id gruppiert Saga-Steps.
- `fact_event_log` → `fact_event_queue` + `dim_automation_rules`.

---

## Special Tables (strukturell unusual)

### `fact_history` (§7)
Zentrale polymorphe Aktivitäts-Tabelle. Alle UI-Felder (Check-Ins, Debriefings, Coachings, Stage-Transitions, Referenzauskünfte) projizieren hierauf. `activity_type_id` FK → `dim_activity_types` (11 Kategorien). Zusätzliche Felder für Call (recording_url, transcript, sentiment) + Email (subject, body_html, message_id) + AI (summary, action_items, red_flags) + Reason-System (5 polymorphe Reason-FKs, Backend entscheidet welches Feld gesetzt wird).

### `dim_automation_settings` (§15b)
Key-Value-Store konfigurierbarer Fristen/Schwellwerte pro Tenant. Vordefinierte Keys: `ghosting_frist_tage=14`, `stale_prozess_tage=14`, `inactive_alter=60`, `datenschutz_reset_tage=365`, `briefing_reminder_tage=7`, `klassifizierung_eskalation_1h=24`, `klassifizierung_eskalation_2h=48`. v1.3 +20 Keys (process_stale_thresholds JSONB, Temperature-Schwellen, Schutzfrist-Settings, Batch-Zeitpunkte, Referral-Offset, Matching-Daily-Batch-Hour).

### `dim_automation_rules` (§1)
Circuit-Breaker-Schutz gegen Event-Stürme: `max_triggers_per_hour/day`, `circuit_breaker_tripped/_at/_reset_at`. Bei Überschreitung automatisch gebremst bis Reset-Zeit.

### `fact_event_queue` (§1)
Zentrale Event-Backbone mit Idempotency (UNIQUE tenant_id+idempotency_key), Retry-Logic (retry_count, next_retry_at, max_retries, dead_lettered_at), Event-Kette (causation_event_id, parent_event_id, correlation_id). source_system-Enum: threecx/outlook/scraper/crm/app/linkedin/whatsapp/system/webhook.

### `fact_protection_window` (§v1.3-Delta)
Schutzfrist-Fenster mit dualem Scope: CHECK((scope='account' AND account_id NOT NULL AND group_id NULL) OR (scope='group' AND group_id NOT NULL AND account_id NULL)). 12 Mt default / 16 Mt bei Nicht-Kooperation des Kunden. Trigger = `fact_candidate_presentation`. Status `claim_pending` → View `v_protection_window_claims`.

### `fact_assessment_order` + `fact_assessment_order_credits` (§v1.3-Delta)
Credits-Modell: Auftrag hat typisierte Credits (MDI/Relief/ASSESS 5.0 etc.) via Bridge. `fact_assessment_run` konsumiert je 1 Credit → `result_version_id` FK → `fact_candidate_assessment_version` (zentrale Versionierung).

### `fact_journal_entries` (§19 Phase 2)
Doppelte Buchführung, nur INSERT. Jede Buchung = Soll + Haben paarweise über shared `journal_id`. Storno nur via `is_reversal=true` + `reversal_of`. Periodenabschluss via `fact_accounting_periods.locked_at` + Trigger `check_period_lock`.

### `fact_audit_log` / `fact_event_log` / `fact_webhook_logs`
Alle drei: **nur INSERT** via `REVOKE UPDATE, DELETE`. Unveränderliche Logs.

### `fact_embeddings` (§12)
pgvector-Embeddings (1536 dim, ivfflat Index, vector_cosine_ops). Polymorphe FKs (entity_type+entity_id) + `chunk_id` → `dim_embedding_chunks`. Historisiert (is_current).

### `dim_ai_write_policies` (§16)
AI-Governance-Layer: Per (entity_type, field_name) definiert policy_type ∈ {suggest_only, auto_after_review, auto_allowed, forbidden}. Default: alle Kandidaten-/Prozess-Felder `suggest_only`. `is_do_not_contact` = `forbidden`. `ai_summary/action_items/red_flags` = `auto_allowed`.

### `dim_date` (§11)
INT PK (`date_id` = YYYYMMDD), kein uuid, kein is_active. Reines Read-Only-Lookup für Power BI (2020–2035, ~5800 Zeilen). Einmalig via `migrations/001_seed_dim_date.sql` befüllt.

### `fact_candidate_briefing` (§v1.3)
UNIQUE-Constraint entfernt → unbegrenzt viele Briefings pro Kandidat. Aktuellstes: `ORDER BY briefing_date DESC LIMIT 1`. `previous_version_id` Self-FK für Versionskette.

### Bridge-Tabellen — Historisierung
Alle `bridge_candidate_*` (und analog account/job) tragen `valid_from`/`valid_to`/`is_current` + `UNIQUE (tenant_id, {parent}_id, {ref}_id) WHERE is_current = true`. Rating-Range auf 1–10 erweitert (v1.3, vorher 1–5).

---

## v1.3.4 Addendum (2026-04-17) — Dok-Generator-Schema

### §14 Erweitertes `fact_documents` (5 neue Felder)

```sql
-- bestehend: entity_type, entity_id, document_label, file_name, ...
-- NEU 2026-04-17 (Dok-Generator):
generated_from_template_id  uuid REFERENCES ark.dim_document_templates(id)
generated_by_doc_gen        boolean DEFAULT false
params_jsonb                jsonb
entity_refs_jsonb           jsonb  -- [{"type":"mandate","id":"uuid"},{"type":"candidate","id":"uuid"}]
delivery_mode               text
  CHECK (delivery_mode IN ('save_only','save_and_email','save_and_download'))
email_recipient_contact_id  uuid REFERENCES ark.dim_account_contacts(id)
```

### §14.1 `document_label` ENUM-Erweiterung (2026-04-17)

Bestehende Labels (aus v1.2): `'Original CV'`, `'ARK CV'`, `'Abstract'`, `'Expose'`, `'Arbeitszeugnis'`, `'Diplom'`, `'Zertifikat'`, `'Mandat Report'`, `'Assessment-Dokument'`, `'Mandatsofferte unterschrieben'`, `'Sonstiges'`.

**Neue Labels (12, v1.3.4 für Dok-Generator-Outputs):**
- `'Mandat-Offerte'` (Alias zu 'Mandatsofferte unterschrieben')
- `'Mandat-Rechnung'`
- `'Best-Effort-Rechnung'`
- `'Assessment-Offerte'`
- `'Assessment-Rechnung'`
- `'Executive-Report'` (NEU)
- `'Mahnung'`
- `'Referenzauskunft'`
- `'Referral'`
- `'Interviewguide'`
- `'Reporting'`
- `'Factsheet'`

### §14.2 `dim_document_templates` (neue Stammdaten-Tabelle, 2026-04-17)

```sql
dim_document_templates
  id                       uuid PK,
  tenant_id                uuid FK,
  template_key             text UNIQUE,           -- 'mandat_offerte_target', 'ark_cv', ...
  display_name             text NOT NULL,
  category                 text
    CHECK IN ('mandat_offerte','mandat_rechnung','best_effort',
              'assessment','rueckerstattung','kandidat','reporting'),
  target_entity_types      text[],                -- ['mandate'] oder ['candidate','mandate']
  multi_entity             boolean DEFAULT false,
  bulk_capable             boolean DEFAULT false,
  required_params          text[],
  placeholders_jsonb       jsonb,
  editor_schema_jsonb      jsonb,
  pdf_engine               text
    CHECK IN ('weasyprint','chromium','docx2pdf') DEFAULT 'weasyprint',
  default_language         text DEFAULT 'de',
  source_docx_storage_path text,
  source_docx_version      int DEFAULT 1,
  is_system_template       boolean DEFAULT true,
  is_active                boolean DEFAULT true,
  sort_order               int,
  created_at, updated_at
```

**Seed-Daten:** 38 Templates + 1 ausstehend (`mandat_offerte_time` mit `is_active=false`). Vollständiger Katalog in `ARK_STAMMDATEN_EXPORT_v1_3.md` §56.

**Kategorien-CHECK:** 7 Werte — `mandat_offerte` · `mandat_rechnung` · `best_effort` · `assessment` · `rueckerstattung` · `kandidat` · `reporting`.

**PDF-Engine-CHECK:** 3 Werte — `weasyprint` (default) · `chromium` · `docx2pdf`.

### §14.3 `fact_assessment_order.status` ENUM-Fix (v0.3 Sync, 2026-04-17)

```sql
-- v0.2 (alt): ENUM('offered','ordered','partially_used','fully_used','invoiced','cancelled')
-- v0.3 (neu): 'invoiced' entfernt — Billing-State lebt auf fact_assessment_billing.status
fact_assessment_order
  status  ENUM('offered','ordered','partially_used','fully_used','cancelled')
```

**Migration-Pfad:** `UPDATE fact_assessment_order SET status='fully_used' WHERE status='invoiced';` bei Schema-Update.

---

## Pointer to full source

Für exakte Definitionen (Spalten-Typen, Constraints, Indizes, Defaults, CHECKs, Beispielzeilen, Views-DDL, Migrations-Reihenfolge) immer die Original-Datei konsultieren:

**`C:/ARK CRM/Grundlagen MD/ARK_DATABASE_SCHEMA_v1_3.md`** (2495 Zeilen)

Navigations-Hinweise:
- **v1.2→v1.3 Delta + neue Tabellen-Liste:** Zeilen 1–213
- **Grundregeln + Pflichtfelder:** §0–§0.2 (Z. 228–306)
- **Events + Automation:** §1 (Z. 308–461)
- **Core-Module:** §2 Kandidaten (Z. 463) / §3 Accounts (Z. 775) / §4 Jobs (Z. 939) / §5 Mandate (Z. 1051) / §6 Prozesse (Z. 1122)
- **Services:** §7 Activity (Z. 1223) / §8 Assessments (Z. 1339) / §9 Scraper (Z. 1376) / §10 Analytics (Z. 1429) / §11 Stammdaten (Z. 1570)
- **AI/RAG:** §12 (Z. 1625)
- **Dokumente + Integrationen:** §14–§15b (Z. 1765–1950)
- **Dok-Generator-Addendum v1.3.4:** §14.1 `document_label`-Erweiterung (Z. 1817) · §14.2 `dim_document_templates` (Z. 1833) · §14.3 `fact_assessment_order.status` ENUM-Fix (Z. 1863)
- **Auth + Governance:** §16 (Z. 1953)
- **Quality + Merge:** §17–§18 (Z. 2069–2123)
- **Phase 2 Scaffold inkl. Buchhaltung:** §19 (Z. 2127–2218)
- **Migrations 004/005/007:** §20–§22 (Z. 2245–2383)
- **Nachtrag v1.3.1 (Theme, Dossier, Org-Funktion-Refactor):** §23 (Z. 2386–2427)
- **Widerspruchsfreiheits-Checkliste:** Z. 2430–2495

**Related:**
- [[ARK_STAMMDATEN_EXPORT_v1_3]] — Enum-Werte, dim_*-Inhalte (Single Source of Truth für Stammdaten)
- [[ARK_BACKEND_ARCHITECTURE_v2]] — Endpunkte, Events, Saga-Flows V1–V7
- [[ARK_FRONTEND_FREEZE_v1]] — UI-Patterns, Routing, Design-System
- [[ARK_GESAMTSYSTEM_UEBERSICHT_v1]] — Gesamtbild + Changelog
- [[spec-sync-regel]] — Sync-Matrix Grundlagen ↔ Detailmasken-Specs
