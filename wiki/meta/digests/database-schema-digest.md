---
title: "Database Schema Digest v1.5"
type: meta
created: 2026-04-17
updated: 2026-04-24
sources: ["ARK_DATABASE_SCHEMA_v1_5.md"]
tags: [digest, schema, database, grundlagen]
---

# Database-Schema Digest v1.5 (Stand 2026-04-24)

Kompakter Lookup-Digest des Grundlagendokuments `Grundlagen MD/ARK_DATABASE_SCHEMA_v1_5.md` (Stand 2026-04-24, ~3000 Zeilen; v1.3 Baseline + v1.3.4 Dok-Generator + v1.4 Zeit-Modul + v1.5 E-Learning). Dieser Digest ist **lossless für Tabellen-Liste + Kern-Relationen + ENUMs + CHECK-Constraints + Indizes**, lossy für Spalten-Detail-Typen, Migrationsprosa, offene Punkte. Für exakte DDL immer die Original-Datei lesen.

**Tabellen-Count: ~204 Tabellen + 8 Views** (v1.2 Baseline + v1.3 +28 Tabellen + v1.4 Zeit +15 + v1.5 E-Learning +28).

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
| 23 | Nachtrag v1.3.1 | Theme-Preference, `dim_dossier_preferences`, Account-UI, Kontakt-Drawer, Org-Funktion-Refactor |
| 14.1 | Addendum v1.3.4 | `document_label` ENUM-Erweiterung (12 neue Labels) |
| 14.2 | Addendum v1.3.4 | Neue Tabelle `dim_document_templates` (Stammdaten) |
| 14.3 | Addendum v1.3.4 | `fact_assessment_order.status` ENUM-Fix (`invoiced` raus) |
| v1.4 | Zeit-Modul (2026-04-19) | 15 Tables + 4 Views + 9 Enums + btree_gist |
| v1.5 | E-Learning-Modul (2026-04-24) | 28 Tables Sub A/B/C/D + pgvector + RLS |

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
- `dim_mitarbeiter` — Mitarbeiter (operativ, hat tenant_id)
- `dim_roles` — Rollen-Stammdaten (Admin/CM/AM/Researcher/Head_of/Backoffice/Assessment_Manager/ReadOnly)
- `dim_crm_users` — CRM-User (operativ, Passwort-Hash, WebAuthn)
- `dim_pii_classification` — PII-Klassifizierung pro Tabelle/Feld
- `dim_ai_write_policies` — AI-Governance (per Entity/Field welche Policy gilt)
- `dim_tenant_features` — Feature Flags pro Tenant (v1.2)
- `dim_honorar_settings` — Honorar-Konfiguration pro Tenant (v1.3)
- `dim_integration_tokens` — OAuth/API-Token-Metadata (secret_ref)
- `dim_webhooks` — Registrierte Webhook-Endpunkte
- `dim_salary_benchmark` — Gehalts-Benchmarks (historisiert)
- `dim_embedding_chunks` — Text-Chunks für Embeddings
- `dim_account_groups` — Account-Gruppen
- `dim_account_aliases` — Account-Aliase
- `dim_account_contacts` — Account-Kontakte (historisiert)
- `dim_candidates_profile` — Kandidaten-Stammdaten (historisiert — zentrale Tabelle)
- `dim_accounts` — Account-Stammdaten (zentrale Tabelle)

**Scraper (v1.3):**
- `dim_scraper_types`, `dim_scraper_global_settings`

**Matching (v1.3):**
- `dim_matching_weights`, `dim_matching_weights_project`

**Dok-Generator (v1.3.4, 2026-04-17):**
- `dim_document_templates` — Template-Katalog (38 aktiv + 1 ausstehend in 7 Kategorien)

**Zeit-Modul (v1.4, 2026-04-19):**
- `dim_absence_type` (30 Codes · DJ-gestaffelt)
- `dim_time_category` (12 Codes · billable_default + zeg_relevant)
- `dim_work_time_model` (5 Codes: FLEX_CORE/FIXED/PARTTIME/SIMPLIFIED_73B/EXEMPT_EXEC)
- `dim_salary_continuation_scale` (composite PK · ZH + BE Seeds)

**E-Learning (v1.5, 2026-04-24):**
- `dim_elearn_tenant`, `dim_elearn_course`, `dim_elearn_module`, `dim_elearn_lesson`, `dim_elearn_question`
- `dim_elearn_curriculum_template`, `dim_elearn_certificate`, `dim_elearn_badge`
- `dim_elearn_source`, `dim_elearn_chunk`, `dim_elearn_generation_job`, `dim_elearn_generated_artifact`
- `dim_elearn_newsletter_issue`, `dim_elearn_newsletter_subscription`
- `dim_elearn_gate_rule`, `dim_elearn_gate_override`

**Buchhaltung Phase 2 Scaffold:**
- `dim_chart_of_accounts` — Kontenplan Schweizer KMU-Standard

**Quality:**
- `dim_quality_rule_types`

**DEPRECATED v1.2:** `dim_skills_master`, `dim_skill_aliases`.

### Facts (operativ, tenant_id + Pflichtfelder)

**Event-Rückgrat:** `fact_event_queue`, `fact_event_log`, `fact_notifications`

**Kandidaten:** `fact_candidate_briefing`, `fact_candidate_employment`, `fact_candidate_projects`, `fact_candidate_presentation` (Schutzfrist-Trigger, v1.3), `fact_candidate_assessment_version` (v1.3), `fact_candidate_matches` (v1.3, 7 Sub-Scores)

**Accounts:** `fact_account_locations`, `fact_account_project_notes` (v1.3)

**Jobs/Mandate:** `fact_jobs` (+29 Felder v1.3), `fact_jobbasket`, `fact_vacancies`, `fact_mandate` (+10 Felder v1.3), `fact_mandate_option` (VI–X, v1.3), `fact_mandate_billing`, `fact_mandate_research`

**Prozesse:** `fact_process_core` (UNIQUE offener Prozess), `fact_process_events`, `fact_process_finance`, `fact_process_interviews` (v1.3)

**Schutzfrist / Referral:** `fact_protection_window` (scope=account/group, v1.3), `fact_referral` (v1.3)

**Assessment:** `fact_assessment_order` (Credits v0.3, `invoiced` raus v1.3.4), `fact_assessment_run` (v1.3), `fact_assessment_billing` (v1.3), `fact_assessment_disc`, `fact_assessment_driving_forces`, `fact_assessment_eq`, `fact_assessment_ikigai`, `fact_assessment_outmatch`, `fact_assessment_human_needs_bip`, `fact_assessment_stressoren`, `fact_assessment_resilienz`, `fact_assessment_motivation`, `fact_assessment_results`, `fact_assessment_cross_analysis`, `fact_assessment_invites`

**Scraper:** `fact_scraped_items`, `fact_scrape_snapshots`, `fact_scrape_changes`, `fact_job_platforms` (v1.2 legacy) · `fact_scraper_schedule`, `fact_scraper_runs`, `fact_scraper_findings`, `fact_scraper_alerts` (v1.3)

**Projekte (v1.3):** `fact_projects`, `fact_project_bkp_gewerke`, `fact_project_company_participations`, `fact_project_candidate_participations`, `fact_project_media`, `fact_project_similarities`

**Activity/History:** `fact_history` (zentrale polymorphe Tabelle), `fact_reminders` (+template_id + escalation_sent_at v1.3.5), `fact_call_context`, `fact_linkedin_activities` (v1.2), `fact_email_drafts` (v1.2)

**AI / Matching:** `fact_embeddings` (pgvector 1536, historisiert), `fact_ai_classifications`, `fact_ai_suggestions`, `fact_match_scores`

**Analytics:** `fact_goals`, `fact_positions_raster`

**Dokumente:** `fact_documents` (+5 Dok-Generator-Felder v1.3.4)

**Integrationen:** `fact_webhook_logs` (INSERT-only)

**Auth:** `fact_refresh_tokens` (v1.2), `fact_token_revocations` (v1.2), `fact_audit_log` (INSERT-only)

**Qualität/Merge:** `fact_data_quality_issues`, `fact_entity_merges`

**Buchhaltung Phase 2:** `fact_accounting_periods`, `fact_journal_entries`

**Zeit-Modul (v1.4):**
- `firm_settings` (19 Global-Configs)
- `fact_workday_target` (weekday_minutes_jsonb · core_hours 3 Paare · Salary-Scale pro User)
- `fact_holiday_cantonal` (12 Seeds 2026 · is_statutory)
- `fact_bridge_day` (GF-manuell pro Jahr · F11)
- `fact_time_scan_event` (Scanner-Roh · DSG Art. 5.4)
- `fact_time_entry` (raw_duration_min vs counted_duration_min · GIST-Overlap)
- `fact_time_correction` (tl_approved_by + admin_approved_by)
- `fact_time_period_close` (Monats-Lock · tl_weekly_checks_done JSONB · F12 Hybrid)
- `fact_absence` (GIST-Overlap · DJ-gestaffelter Arztzeugnis-Reminder)
- `fact_vacation_balance` (entitlement+carried_over-taken · carryover_deadline DATE)
- `fact_overtime_balance` (3-Konten: ueberstunden_or vs ueberzeit_arg)
- `fact_extra_leave_entitlement` (Geburtstag/Joker/ZEG/GL)
- `fact_salary_continuation_claim` (Krank · Zürcher Skala)
- `fact_simplified_agreement` (73b · individual/collective)
- `fact_scanner_access_audit` (DSG-Biometrie-Zugriffe)

**E-Learning (v1.5):**
- `fact_elearn_curriculum_override` · `fact_elearn_assignment`
- `fact_elearn_enrollment` · `fact_elearn_progress` · `fact_elearn_quiz_attempt` · `fact_elearn_freitext_review`
- `fact_elearn_import_log`
- `fact_elearn_review_action`
- `fact_elearn_newsletter_assignment` · `fact_elearn_newsletter_section_read`
- `fact_elearn_gate_event` · `fact_elearn_compliance_snapshot`

**Phase 2 Scaffold (leer, Schema definiert):** `fact_messages`, `fact_message_campaigns`, `fact_time_entries` (legacy scaffold, ersetzt durch v1.4), `fact_absences` (legacy scaffold, ersetzt durch v1.4), `fact_time_budgets`, `fact_performance_reviews`, `fact_360_feedback`, `fact_development_plans`, `fact_learning_progress`, `fact_competency_ratings`, `fact_payroll`, `fact_invoices`, `fact_expenses`, `fact_job_postings`, `fact_posting_costs`, `fact_posting_stats`, `fact_publications`, `fact_publication_stats`, `fact_organigram_changes`, `fact_market_snapshots`, `fact_competitor_tracking`.

**DEPRECATED v1.2:** `fact_skill_market_value`, `fact_skill_salary_data`, `fact_skill_demand_index`, `fact_function_skill_premium`.

### Bridges (N:N-Beziehungen, historisiert wo sinnvoll)

**Kandidaten-Bridges** (alle mit `UNIQUE (tenant_id, candidate_id, {ref}_id) WHERE is_current`):
- `bridge_candidate_cluster`, `bridge_candidate_functions`, `bridge_candidate_focus`, `bridge_candidate_edv`, `bridge_candidate_education`, `bridge_candidate_languages`, `bridge_candidate_sector`, `bridge_candidate_sparte`
- DEPRECATED: `bridge_candidate_skill`

**Account-Bridges:** `bridge_account_cluster`, `bridge_account_functions`, `bridge_account_focus`, `bridge_account_edv`, `bridge_account_sector`, `bridge_account_sparte` (`is_core_*` statt `is_primary_*`)

**Job-Bridges:** `bridge_job_cluster`, `bridge_job_functions`, `bridge_job_focus`, `bridge_job_edv`, `bridge_job_education`, `bridge_job_sector`, `bridge_job_sparte`. DEPRECATED: `bridge_job_skill`.

**Mandate/Gruppen:** `bridge_mandate_accounts` (Gruppen-Taskforce, v1.3)

**Projekte (v1.3):** `bridge_project_clusters`, `bridge_project_spartens`

**Briefing:** `bridge_briefing_projects` (Briefing ↔ Projekt · candidate_comment/insider_info/rating, v1.2)

**Mitarbeiter-Rollen:** `bridge_mitarbeiter_roles` (Multi-Rollen, is_primary_role)

**DEPRECATED v1.2:** `bridge_skill_related_skill`, `bridge_function_skill`.

### Views

- `v_candidates_overview`, `v_candidate_duplicates`, `v_account_duplicates` (v1.2), `v_mandate_overview`, `v_goals_progress`, `v_open_reminders`, `v_open_vacancies`, `v_account_intelligence`, `v_salary_warnings`
- Power-BI: `v_powerbi_kandidaten`, `v_powerbi_prozesse`, `v_powerbi_umsatz`, `v_powerbi_markt`
- v1.3: `v_protection_window_claims`, `v_assessment_credits_account_summary`, `v_assessment_credits_order_summary`
- v1.4 Zeit (4): `v_daily_saldo`, `v_monthly_saldo`, `v_time_per_mandate` (Commission-ZEG-Feed), `v_weekly_approval_queue` (TL-Dashboard F12)

---

## Core Relationships

**Zentrale Entities + deren FK-Sterne:**

### `dim_candidates_profile` (Kandidat) — zentraler Hub
- ← `fact_candidate_briefing`, `fact_candidate_employment`, `fact_candidate_projects`, `fact_candidate_presentation`, `fact_jobbasket`, `fact_mandate_research`, `fact_process_core`, `fact_history`, `fact_reminders`, `fact_protection_window`, `fact_match_scores`, `fact_candidate_matches`, `fact_linkedin_activities`, `fact_referral`, alle 9 `bridge_candidate_*`, `dim_account_contacts.candidate_id`, `app_users.candidate_id`.
- Self-FK: `merged_into_id`, `referral_from_id`.

### `dim_accounts` (Account) — zentraler Hub
- ← `dim_account_contacts`, `fact_account_locations`, `dim_account_aliases`, `fact_candidate_employment`, `fact_jobs`, `fact_vacancies`, `fact_process_core`, `fact_history`, `fact_reminders`, `fact_protection_window`, `fact_scraped_items`, `fact_scrape_*`, `fact_job_platforms`, `fact_positions_raster`, `fact_assessment_order`, `fact_account_project_notes`, alle 6 `bridge_account_*`.
- → `dim_account_groups`, `dim_firmengruppen` (v1.3), `dim_sparte`, `dim_mitarbeiter` (account_manager_id).
- Self-FK: `merged_into_id`.

### `fact_jobs` (Job) — verbindet Account × Mandat × Prozess
- → `dim_accounts`, `dim_account_contacts`, `fact_mandate`, `fact_vacancies`, `fact_projects` (v1.3), `dim_mitarbeiter`, `dim_sparte`, `dim_functions`.
- ← `fact_jobbasket`, `fact_process_core`, `fact_match_scores`, `fact_history`, `fact_reminders`, 7 `bridge_job_*`.

### `fact_mandate` (Mandat)
- → `fact_jobs`, `dim_mitarbeiter`, `dim_firmengruppen` (v1.3), `fact_projects` (v1.3), `fact_mandate_billing` (termination_invoice_id).
- ← `fact_mandate_billing`, `fact_mandate_research`, `fact_mandate_option`, `fact_process_core`, `fact_history`, `fact_reminders`, `bridge_mandate_accounts`.

### `fact_process_core` (Prozess) — Kandidat × Account × Job × optional Mandat
- → `dim_candidates_profile`, `dim_accounts`, `fact_jobs`, `fact_mandate` (nullable), `dim_mitarbeiter` (CM/AM/Researcher), Reason-FKs.
- ← `fact_process_events`, `fact_process_finance`, `fact_process_interviews`, `fact_jobbasket`, `fact_history`, `fact_reminders`, `fact_positions_raster` (last_placement_id).
- **Invariante:** UNIQUE(tenant_id, candidate_id, job_id) WHERE status NOT IN (Closed/Rejected/Cancelled/Dropped).

### `fact_projects` (Bauprojekt, v1.3)
- ← `fact_project_bkp_gewerke`, `fact_project_company_participations`, `fact_project_candidate_participations`, `fact_project_media`, `fact_account_project_notes`, `bridge_project_clusters`, `bridge_project_spartens`, `bridge_briefing_projects`, `fact_project_similarities`.
- → `fact_jobs.linked_project_id`, `fact_mandate.linked_project_id`.

### `fact_history` (Activity/Timeline) — polymorpher Hub
- → alle Kern-Entities nullable: `candidate_id`, `account_id`, `account_contact_id`, `job_id`, `process_id`, `mandate_id`, `location_id`.
- → `dim_activity_types` (NOT NULL), `dim_mitarbeiter`, `fact_event_queue`.
- → polymorphe Reason-FKs: `rejection_reason_candidate_id`, `rejection_reason_client_id`, `cancellation_reason_id`, `dropped_reason_id`, `offer_refused_reason_id`.
- **Rolle:** Single Source of Truth für Check-Ins, Debriefings, Coachings, Referenzauskünfte, Stage-Transitions.

### `fact_jobbasket` — UNIQUE(tenant_id, candidate_id, job_id).

### Schutzfrist-Scope (v1.3)
- `fact_protection_window.scope ENUM('account','group')` + CHECK(ONE-OF account_id vs. group_id).
- Trigger = `fact_candidate_presentation`. Bei Account-in-Gruppe: 2 Einträge.

### Auth-Kette
- `dim_crm_users` ← `dim_mitarbeiter.auth_user_id`, `fact_refresh_tokens`, `fact_audit_log`.
- `app_users` → `dim_candidates_profile`.

### Event-Kette
- `fact_event_queue` causation/parent-Self-FK → Event-DAG. correlation_id gruppiert Saga-Steps.
- `fact_event_log` → `fact_event_queue` + `dim_automation_rules`.

---

## Special Tables (strukturell unusual)

### `fact_history` (§7)
Zentrale polymorphe Aktivitäts-Tabelle. `activity_type_id` FK → `dim_activity_types` (11 Kategorien). Call-Felder (recording_url, transcript, sentiment), Email (subject, body_html, message_id), AI (summary, action_items, red_flags), 5 polymorphe Reason-FKs.

### `dim_automation_settings` (§15b)
Key-Value-Store. v1.2 Keys: `ghosting_frist_tage=14`, `stale_prozess_tage=14`, `inactive_alter=60`, `datenschutz_reset_tage=365`, `briefing_reminder_tage=7`, `klassifizierung_eskalation_1h=24`, `klassifizierung_eskalation_2h=48`. v1.3 +20 Keys. v1.5 Namespaces: `elearn_b.*`, `elearn_c.*`, `elearn_d.*`.

### `dim_automation_rules` (§1)
Circuit-Breaker: `max_triggers_per_hour/day`, `circuit_breaker_tripped/_at/_reset_at`.

### `fact_event_queue` (§1)
Idempotency (UNIQUE tenant_id+idempotency_key), Retry (retry_count/next_retry_at/max_retries/dead_lettered_at), Event-Kette (causation/parent/correlation). source_system-Enum: threecx/outlook/scraper/crm/app/linkedin/whatsapp/system/webhook.

### `fact_protection_window` (v1.3)
CHECK((scope='account' AND account_id NOT NULL AND group_id NULL) OR (scope='group' AND group_id NOT NULL AND account_id NULL)). 12 Mt default / 16 Mt bei Nicht-Kooperation.

### `fact_assessment_order` + Credits (v1.3)
Credits-Modell v0.3 · status `offered|ordered|partially_used|fully_used|cancelled` (`invoiced` raus, Billing-State auf `fact_assessment_billing.status`).

### `fact_journal_entries` (§19)
Nur INSERT. Doppelte Buchführung (Soll+Haben paarweise über `journal_id`). Storno = `is_reversal=true`. Periodenabschluss via `fact_accounting_periods.locked_at`.

### `fact_audit_log` / `fact_event_log` / `fact_webhook_logs` / `fact_time_scan_event` / `fact_scanner_access_audit` / `fact_elearn_gate_event`
Alle **nur INSERT** (`REVOKE UPDATE, DELETE`). Unveränderliche Logs.

### `fact_embeddings` (§12)
pgvector 1536 dim, ivfflat Index, vector_cosine_ops. Polymorphe FKs (entity_type+entity_id) + chunk_id. Historisiert.

### `dim_ai_write_policies` (§16)
policy_type ∈ {suggest_only, auto_after_review, auto_allowed, forbidden}. Default: Kandidaten-/Prozess-Felder `suggest_only`. `is_do_not_contact` = `forbidden`. AI-Felder = `auto_allowed`.

### `dim_date` (§11)
INT PK (YYYYMMDD), kein uuid, kein is_active. 2020–2035 · Power BI.

### `fact_candidate_briefing` (v1.3)
UNIQUE entfernt → unbegrenzt viele Briefings. Aktuellstes: `ORDER BY briefing_date DESC LIMIT 1`. `previous_version_id` Self-FK.

### Bridge-Tabellen — Historisierung
`valid_from`/`valid_to`/`is_current` + `UNIQUE (tenant_id, {parent}_id, {ref}_id) WHERE is_current = true`. Rating-Range 1–10 (v1.3).

### `fact_time_entry` + `fact_absence` (v1.4)
GIST-Overlap-Exclude-Constraint auf `tstzrange(start,end)` pro User → keine Überschneidungen möglich. `counted_duration_min` respektiert 10h-Cap, `raw_duration_min` = unskippiert.

### `fact_time_period_close` (v1.4)
Monats-Lock mit `tl_weekly_checks_done JSONB` (F12 Hybrid). State-Machine: open → submitted → tl_approved → gf_approved → locked → exported → reopened.

---

## v1.3.4 Addendum (2026-04-17) — Dok-Generator-Schema

### §14 Erweitertes `fact_documents` (5 neue Felder)
```sql
generated_from_template_id  uuid FK → dim_document_templates
generated_by_doc_gen        boolean DEFAULT false
params_jsonb                jsonb
entity_refs_jsonb           jsonb  -- [{"type":"mandate","id":"uuid"}]
delivery_mode               text CHECK IN ('save_only','save_and_email','save_and_download')
email_recipient_contact_id  uuid FK → dim_account_contacts
```

### §14.1 `document_label` ENUM-Erweiterung
Bestehend v1.2: `'Original CV'`, `'ARK CV'`, `'Abstract'`, `'Expose'`, `'Arbeitszeugnis'`, `'Diplom'`, `'Zertifikat'`, `'Mandat Report'`, `'Assessment-Dokument'`, `'Mandatsofferte unterschrieben'`, `'Sonstiges'`.

Neu v1.3.4 (12): `'Mandat-Offerte'`, `'Mandat-Rechnung'`, `'Best-Effort-Rechnung'`, `'Assessment-Offerte'`, `'Assessment-Rechnung'`, `'Executive-Report'`, `'Mahnung'`, `'Referenzauskunft'`, `'Referral'`, `'Interviewguide'`, `'Reporting'`, `'Factsheet'`.

### §14.2 `dim_document_templates`
```sql
dim_document_templates
  id, tenant_id, template_key UNIQUE, display_name,
  category CHECK IN ('mandat_offerte','mandat_rechnung','best_effort',
                     'assessment','rueckerstattung','kandidat','reporting'),
  target_entity_types text[], multi_entity bool, bulk_capable bool,
  required_params text[], placeholders_jsonb, editor_schema_jsonb,
  pdf_engine CHECK IN ('weasyprint','chromium','docx2pdf') DEFAULT 'weasyprint',
  default_language DEFAULT 'de', source_docx_storage_path, source_docx_version,
  is_system_template bool DEFAULT true, is_active bool, sort_order
```
Seed: 38 Templates + 1 ausstehend (`mandat_offerte_time` inactive).

### §14.3 `fact_assessment_order.status` ENUM-Fix
v0.3: `ENUM('offered','ordered','partially_used','fully_used','cancelled')` — `'invoiced'` entfernt. Migration: `UPDATE ... SET status='fully_used' WHERE status='invoiced';`

---

## v1.4 Zeit-Modul (2026-04-19) — Phase 3 ERP

**Extensions:** `CREATE EXTENSION IF NOT EXISTS btree_gist` (für GIST-Overlap-Exclude).

**ENUM-Types neu (9):**
1. `time_entry_state` (draft·submitted·approved·locked·corrected·rejected)
2. `absence_state` (draft·submitted·approved·active·completed·rejected·cancelled·corrected)
3. `correction_state` (requested·tl_approved·gf_approved·applied·rejected)
4. `period_close_state` (open·submitted·tl_approved·gf_approved·locked·exported·reopened)
5. `work_time_model` (FLEX_CORE·FIXED·PARTTIME·SIMPLIFIED_73B·EXEMPT_EXEC)
6. `scan_event_type` (check_in·check_out·break_start·break_end·override)
7. `time_entry_source` (scanner·manual·timer·import·admin)
8. `overtime_kind` (regular·ueberstunden_or·ueberzeit_arg·uncounted)
9. `salary_scale_code` (ZURICH·BERN·BASEL·INSURANCE_EQUIV) + `salary_continuation_phase`

**Retention:**
| Entität | Retention | Grund |
|---------|-----------|-------|
| fact_time_entry | 5 J post Vertragsende | ArGV 1 Art. 73.2 |
| fact_absence (medical) | 5 J post Vertragsende | ArG 73 + revDSG Art. 5 |
| doctor_cert_file | 5 J post Abwesenheit | revDSG Art. 5.2 |
| fact_scanner_access_audit | 10 J | DSG-Nachweispflicht |
| fact_time_correction | 10 J | Gerichtsbeweis |

**Integration:** `fact_time_entry.project_id` → `fact_process_core(id)` (nullable) · `user_id` → `dim_user(id)` · Commission-Engine liest `v_time_per_mandate` für ZEG-Staffel.

---

## v1.5 E-Learning-Modul (2026-04-24) — Multi-Tenant Phase 3 ERP

**Quellen:** `specs/ARK_DATABASE_SCHEMA_PATCH_ELEARNING_{v0_1,SUB_B_v0_1,SUB_C_v0_1,SUB_D_v0_1}.md`

**Multi-Tenant:** Erste konsequent Multi-Tenant-fähige Komponente. **Alle 28 neuen Tabellen tragen `tenant_id UUID NOT NULL`** + RLS-Policies. Zweck: White-Label für externe Boutiquen.

**Extensions:** `CREATE EXTENSION IF NOT EXISTS vector` (pgvector für RAG-Embeddings, Sub B). `btree_gist` bereits aus v1.4.

### Sub A · Kurs-Katalog (15 Tabellen)

**Tenant + Content (5):**
```sql
dim_elearn_tenant (tenant_id PK, name, settings JSONB, created_at)
dim_elearn_course (course_id PK, tenant_id, slug, title, description, sparten[], rollen[],
                   duration_min, refresher_months, pretest_enabled, pretest_pass_threshold,
                   pass_threshold, version, content_hash, status, published_at,
                   UNIQUE(tenant_id, slug))
dim_elearn_module (module_id PK, tenant_id, course_id FK, slug, order_idx, title, description,
                   content_hash, UNIQUE(tenant_id, course_id, slug),
                   UNIQUE(tenant_id, course_id, order_idx))
dim_elearn_lesson (lesson_id PK, tenant_id, module_id FK, slug, order_idx, title, content_md,
                   min_read_seconds, content_hash, UNIQUE(tenant_id, module_id, slug),
                   UNIQUE(tenant_id, module_id, order_idx))
dim_elearn_question (question_id PK, tenant_id, module_id FK, type, payload JSONB,
                     version, content_hash)
```

**Zuweisung / Onboarding (3):**
```sql
dim_elearn_curriculum_template (template_id PK, tenant_id, sparte NULLABLE, rolle,
                                course_ids UUID[], UNIQUE(tenant_id, sparte, rolle))
fact_elearn_curriculum_override (override_id PK, tenant_id, ma_id, course_ids UUID[],
                                 reason, UNIQUE(tenant_id, ma_id))
fact_elearn_assignment (assignment_id PK, tenant_id, ma_id, course_id FK, reason, deadline,
                        assigned_by, assigned_at, status)
```

**Progress / Quiz (4):**
```sql
fact_elearn_enrollment (enrollment_id PK, tenant_id, ma_id, course_id FK, course_version,
                        status, started_at, completed_at,
                        UNIQUE(tenant_id, ma_id, course_id))
fact_elearn_progress (progress_id PK, tenant_id, enrollment_id FK, lesson_id FK,
                      scroll_reached_pct, time_spent_sec, completed_at,
                      UNIQUE(tenant_id, enrollment_id, lesson_id))
fact_elearn_quiz_attempt (attempt_id PK, tenant_id, enrollment_id FK, module_id FK,
                          attempt_kind DEFAULT 'module',  -- module | pretest | newsletter
                          score_pct, passed, status, attempted_at, finalized_at, answers JSONB)
fact_elearn_freitext_review (review_id PK, tenant_id, attempt_id FK, question_id FK,
                             ma_answer, llm_score, llm_feedback, llm_model,
                             head_score, head_feedback, reviewed_by, reviewed_at, status)
```

**Cert / Badges / Audit (3):**
```sql
dim_elearn_certificate (cert_id PK, tenant_id, ma_id, course_id FK, course_version,
                        pdf_url, issued_at,
                        -- Sub D Erweiterung: status, expired_at, revoked_at, revoked_reason
                        UNIQUE(tenant_id, ma_id, course_id, course_version))
dim_elearn_badge (badge_id PK, tenant_id, ma_id, badge_type, course_id NULLABLE, earned_at)
fact_elearn_import_log (log_id PK, tenant_id, commit_sha, trigger, imported, updated,
                        archived, errors JSONB, started_at, finished_at)
```

**ALTER `dim_user`:** `+elearn_onboarding_active BOOLEAN NOT NULL DEFAULT false`

**Indizes Sub A:**
```sql
CREATE INDEX ON fact_elearn_progress (tenant_id, enrollment_id, lesson_id);
CREATE INDEX ON fact_elearn_quiz_attempt (tenant_id, enrollment_id, module_id);
CREATE INDEX ON fact_elearn_freitext_review (tenant_id, status) WHERE status = 'pending';
CREATE INDEX ON fact_elearn_assignment (tenant_id, ma_id, status) WHERE status = 'active';
CREATE INDEX ON dim_elearn_course (tenant_id, status, slug);
```

**CHECK-Constraints Sub A:**
- `fact_elearn_assignment.reason IN ('onboarding','adhoc','refresher','role_change','sparten_change')`
- `fact_elearn_assignment.status IN ('active','completed','expired','cancelled')`
- `fact_elearn_quiz_attempt.attempt_kind IN ('module','pretest','newsletter')`
- `fact_elearn_quiz_attempt.status IN ('in_progress','pending_review','finalized')`
- `fact_elearn_freitext_review.status IN ('pending','confirmed','overridden','confirmed_auto')`
- `dim_elearn_question.type IN ('mc','multi','freitext','truefalse','zuordnung','reihenfolge')`
- `dim_elearn_course.status IN ('draft','published','archived')`

### Sub B · Content-Generator (5 Tabellen + pgvector)

```sql
dim_elearn_source (source_id PK, tenant_id, kind, slug, uri, title, sparten[],
                   target_course_slug, meta JSONB, priority, content_hash,
                   last_ingested_at, enabled, UNIQUE(tenant_id, kind, slug))
dim_elearn_chunk (chunk_id PK, tenant_id, source_id FK, order_idx, text, tokens,
                  embedding VECTOR(1536), meta JSONB, content_hash,
                  UNIQUE(tenant_id, source_id, order_idx))
dim_elearn_generation_job (job_id PK, tenant_id, source_ids UUID[], cluster_summary JSONB,
                           llm_model, llm_prompt_template, status, triggered_by,
                           triggered_by_user, total_tokens_in, total_tokens_out,
                           total_cost_eur, started_at, finished_at, error)
dim_elearn_generated_artifact (artifact_id PK, tenant_id, job_id FK, artifact_type,
                               target_course_slug, target_module_slug, target_lesson_slug,
                               draft_content JSONB, preview_text, source_chunk_ids UUID[],
                               status, reviewer, reviewed_at, published_commit_sha)
fact_elearn_review_action (action_id PK, tenant_id, artifact_id FK, action, reviewer,
                           reason, diff JSONB, created_at)
```

**Indizes Sub B (inkl. IVFFLAT):**
```sql
CREATE INDEX ON dim_elearn_source (tenant_id, kind, enabled);
CREATE INDEX ON dim_elearn_chunk (tenant_id, source_id, order_idx);
CREATE INDEX ON dim_elearn_chunk USING ivfflat (embedding vector_cosine_ops) WITH (lists = 100);
CREATE INDEX ON dim_elearn_generation_job (tenant_id, status, started_at DESC);
CREATE INDEX ON dim_elearn_generated_artifact (tenant_id, status)
  WHERE status IN ('draft', 'approved');
CREATE INDEX ON fact_elearn_review_action (tenant_id, artifact_id, created_at DESC);
```

**CHECK-Constraints Sub B:**
- `dim_elearn_source.kind IN ('pdf','docx','book','web_url','crm_query')`
- `dim_elearn_source.priority IN ('low','normal','high')`
- `dim_elearn_generation_job.status IN ('pending','running','ready_for_review','completed','failed')`
- `dim_elearn_generation_job.triggered_by IN ('scheduled','manual','event')`
- `dim_elearn_generated_artifact.artifact_type IN ('course_meta','module','lesson','quiz_question','quiz_pool')`
- `dim_elearn_generated_artifact.status IN ('draft','approved','rejected','published','superseded')`
- `fact_elearn_review_action.action IN ('approve','reject','edit','delete','publish')`

**Tenant-Settings `elearn_b.*`:** `publish_mode`, `content_repo`, `content_repo_branch`, `github_pat_vault_ref`, `llm_model_default='claude-sonnet-4-6'`, `llm_model_tagging='claude-haiku-4-5'`, `llm_cost_cap_monthly_eur=200`, `llm_cost_cap_per_job_eur=5`, `embedding_model='text-embedding-3-small'`, `embedding_dimension=1536`, `scheduler.enabled`, `scheduler.default_schedule='0 3 * * 1'`, `review.auto_assign_to_head`, `review.review_sla_days=7`.

### Sub C · Wochen-Newsletter (4 Tabellen)

```sql
dim_elearn_newsletter_issue (issue_id PK, tenant_id, sparte, issue_week, publish_at,
                             title, sections JSONB, quiz_module_id, quiz_pass_threshold,
                             enforcement_mode, generation_job_id, status, published_at,
                             UNIQUE(tenant_id, sparte, issue_week))
dim_elearn_newsletter_subscription (sub_id PK, tenant_id, ma_id, sparte, mode,
                                    enforcement_override, UNIQUE(tenant_id, ma_id, sparte))
fact_elearn_newsletter_assignment (assignment_id PK, tenant_id, ma_id, issue_id FK,
                                   assigned_at, deadline, read_started_at, read_completed_at,
                                   quiz_attempt_id FK, status, reminder_sent_at,
                                   escalated_to_head_at, enforcement_mode_applied,
                                   UNIQUE(tenant_id, ma_id, issue_id))
fact_elearn_newsletter_section_read (read_id PK, tenant_id, assignment_id FK,
                                     section_idx, scroll_pct, time_spent_sec, read_at,
                                     UNIQUE(tenant_id, assignment_id, section_idx))
```

**ALTER `dim_user`:** `+newsletter_enforcement_override TEXT` (NULL = tenant default · 'soft' | 'hard')

**Indizes Sub C:**
```sql
CREATE INDEX ON dim_elearn_newsletter_issue (tenant_id, sparte, issue_week);
CREATE INDEX ON dim_elearn_newsletter_issue (tenant_id, status, publish_at);
CREATE INDEX ON dim_elearn_newsletter_subscription (tenant_id, ma_id);
CREATE INDEX ON fact_elearn_newsletter_assignment (tenant_id, ma_id, status)
  WHERE status IN ('pending','reading','quiz_in_progress');
CREATE INDEX ON fact_elearn_newsletter_assignment (tenant_id, deadline)
  WHERE status NOT IN ('quiz_passed','expired');
CREATE INDEX ON fact_elearn_newsletter_section_read (tenant_id, assignment_id, section_idx);
```

**CHECK-Constraints Sub C:**
- `dim_elearn_newsletter_issue.status IN ('draft','review','published','archived')`
- `dim_elearn_newsletter_issue.enforcement_mode IN ('soft','hard')`
- `dim_elearn_newsletter_subscription.mode IN ('auto','opt_in','opt_out')`
- `dim_elearn_newsletter_subscription.enforcement_override IS NULL OR IN ('soft','hard')`
- `fact_elearn_newsletter_assignment.status IN ('pending','reading','quiz_in_progress','quiz_passed','quiz_failed','expired')`
- `fact_elearn_newsletter_assignment.enforcement_mode_applied IN ('soft','hard')`
- `dim_user.newsletter_enforcement_override IS NULL OR IN ('soft','hard')`

**Tenant-Settings `elearn_c.*`:** `enforcement_mode='soft'`, `publish_day_cron='0 6 * * 1'`, `reminder_hours=48`, `escalation_days=7`, `expiry_days=14`, `sparten_enabled=['ARC','GT','ING','PUR','REM']`, `sparte_uebergreifend_enabled=true`, `archive_retention_months=24`, `max/min_sections_per_issue=6/3`, `max/min_questions_per_quiz=10/3`, `allow_auto_opt_out=false`.

**Interop Sub A:** Newsletter-Quiz nutzt `fact_elearn_quiz_attempt` mit `attempt_kind='newsletter'`. Pro Issue synthetisches `dim_elearn_module` im versteckten Newsletter-Kurs pro Tenant (`slug='__newsletter__'`).

### Sub D · Progress-Gate (4 Tabellen + Cert-Erweiterung)

```sql
dim_elearn_gate_rule (rule_id PK, tenant_id, name, description, trigger_type,
                      trigger_params JSONB, blocked_features TEXT[], allowed_features TEXT[],
                      priority, enabled, created_by, UNIQUE(tenant_id, name))
fact_elearn_gate_event (event_id PK, tenant_id, ma_id, rule_id, feature_key, action,
                        override_id, request_meta JSONB, occurred_at)  -- INSERT-only
dim_elearn_gate_override (override_id PK, tenant_id, ma_id, override_type, reason,
                          valid_from, valid_until, pause_deadlines, created_by,
                          ended_at, ended_by)
fact_elearn_compliance_snapshot (snapshot_id PK, tenant_id, ma_id, snapshot_date,
                                 courses_total, courses_completed,
                                 newsletters_total, newsletters_passed,
                                 certs_active, certs_expired, overdue_items,
                                 compliance_score,
                                 UNIQUE(tenant_id, ma_id, snapshot_date))
```

**ALTER `dim_elearn_certificate` (Sub A Tabelle, +4 Spalten):**
```sql
ALTER TABLE dim_elearn_certificate
  ADD COLUMN status TEXT NOT NULL DEFAULT 'active',
  ADD COLUMN expired_at TIMESTAMPTZ,
  ADD COLUMN revoked_at TIMESTAMPTZ,
  ADD COLUMN revoked_reason TEXT;

ALTER TABLE dim_elearn_certificate ADD CONSTRAINT ck_cert_status
  CHECK (status IN ('active','expired','revoked'));

CREATE INDEX ON dim_elearn_certificate (tenant_id, ma_id, status) WHERE status = 'active';
```

**Indizes Sub D:**
```sql
CREATE INDEX ON dim_elearn_gate_rule (tenant_id, enabled, priority DESC) WHERE enabled = true;
CREATE INDEX ON fact_elearn_gate_event (tenant_id, ma_id, occurred_at DESC);
CREATE INDEX ON fact_elearn_gate_event (tenant_id, feature_key, occurred_at DESC);
CREATE INDEX ON fact_elearn_gate_event (tenant_id, rule_id, occurred_at DESC)
  WHERE rule_id IS NOT NULL;
CREATE INDEX ON dim_elearn_gate_override (tenant_id, ma_id, valid_from, valid_until)
  WHERE ended_at IS NULL;
CREATE INDEX ON fact_elearn_compliance_snapshot (tenant_id, ma_id, snapshot_date DESC);
CREATE INDEX ON fact_elearn_compliance_snapshot (tenant_id, snapshot_date, compliance_score);
```

**CHECK-Constraints Sub D:**
- `dim_elearn_gate_rule.trigger_type IN ('newsletter_overdue','onboarding_overdue','refresher_due','cert_expired','assignment_expired')`
- `fact_elearn_gate_event.action IN ('blocked','allowed','overridden','bypassed')`
- `dim_elearn_gate_override.override_type IN ('vacation','parental_leave','medical','emergency_bypass','other')`
- `dim_elearn_gate_override.valid_until IS NULL OR valid_until > valid_from`

**Tenant-Settings `elearn_d.*`:** `login_popup_enabled=true`, `login_popup_min_items=1`, `gate_cache_ttl_seconds=60`, `compliance_snapshot_cron='0 3 * * *'`, `compliance_report_retention_months=36`, `cert_auto_revoke_on_major_version=true`, `dashboard_banner_position='top'`, `default_gate_rules_seed=true`.

**Default-Gate-Rules-Seed (4 Rules pro Tenant):**
- `Hard-Newsletter-Block` (Priority 100)
- `Onboarding-Expired-Block` (90)
- `Cert-Expired-Readonly` (80)
- `Soft-Newsletter-Warning` (50)

### RLS-Policies (alle 28 neuen Tabellen)

**Template pro Tabelle:**
```sql
ALTER TABLE <tabelle> ENABLE ROW LEVEL SECURITY;
CREATE POLICY <table>_tenant_isolation ON <tabelle>
  USING (tenant_id = current_setting('app.current_tenant_id')::uuid)
  WITH CHECK (tenant_id = current_setting('app.current_tenant_id')::uuid);
```

**MA-Scoping-Ausnahmen:**
- `fact_elearn_progress`, `fact_elearn_quiz_attempt`: zusätzlich `ma_id = current_setting('app.current_user_id')::uuid` für MA-Endpoints
- `fact_elearn_freitext_review`: Head-Scoping via `dim_user.reports_to`-Join
- `fact_elearn_newsletter_assignment`: MA-scoped für `/my/*`, Team via `reports_to`, Admin tenant-weit
- `fact_elearn_compliance_snapshot`: MA-scoped für self-view, Team via `reports_to`

### Migration-Reihenfolge Sub A→D

1. `CREATE EXTENSION IF NOT EXISTS vector`
2. Sub A: 15 Tables (FK-Reihenfolge: tenant → course → module → lesson → question → curriculum → override → assignment → enrollment → progress → quiz_attempt → freitext_review → cert → badge → import_log)
3. Sub A: `ALTER dim_user ADD elearn_onboarding_active`
4. Sub A: Indizes + CHECK + Seed `dim_elearn_tenant` (Arkadium-Default)
5. Sub B: 5 Tables + IVFFLAT-Index + CHECK + Tenant-Settings `elearn_b.*`
6. Sub C: 4 Tables + `ALTER dim_user ADD newsletter_enforcement_override` + Indizes + CHECK + Tenant-Settings `elearn_c.*` + Seed versteckter Newsletter-Kurs (`slug='__newsletter__'`)
7. Sub D: 4 Tables + `ALTER dim_elearn_certificate` (+4 Spalten) + Indizes + CHECK + Tenant-Settings `elearn_d.*` + Default-Gate-Rules-Seed
8. RLS: `ENABLE ROW LEVEL SECURITY` + Policies auf allen 28 Tabellen

### Performance-Annahmen E-Learning

- pgvector-RAG-Retrieval: < 100 ms mit IVFFLAT (bis ~1 Mio Chunks/Tenant)
- Gate-Middleware-Overhead: < 1 ms mit Cache, 5-15 ms ohne
- Compliance-Snapshot: ~50 ms pro MA (Multi-JOIN), 30 MA Tenant → 1.5 s/Run
- Newsletter-Publish: Bulk-Insert 150 Assignments (30 MA × 5 Sparten) < 200 ms
- Audit-Log `fact_elearn_gate_event`: ~150k Events/Monat/MA → Partitionieren/Archivieren nach 12 Monaten

---

## Version-Changelog

- **v1.3 (2026-04-14):** 28 neue Fact/Bridge-Tabellen, 15 neue Stammdaten, 30+ Feld-Erweiterungen, 3 Migrations-Waves
- **v1.3.1 (2026-04-14):** Theme-Preference, `dim_dossier_preferences`, Org-Funktion-Refactor
- **v1.3.4 (2026-04-17):** Dok-Generator (`dim_document_templates` + `fact_documents`+5 Felder)
- **v1.4 (2026-04-19):** Zeit-Modul (15 Tables + 4 Views + 9 Enums + btree_gist)
- **v1.5 (2026-04-24):** E-Learning-Modul Sub A/B/C/D (28 Tables · pgvector · 2 Spalten `dim_user` · 4 Spalten `dim_elearn_certificate` · 30+ Indizes inkl. IVFFLAT · 20+ CHECK-Constraints · RLS-Policies). Tabellen-Count: ~204 + 8 Views.

---

## Pointer to full source

Für exakte Definitionen (Spalten-Typen, Constraints, Indizes, Defaults, CHECKs, Views-DDL, Migrations-Reihenfolge) immer:

**`C:/ARK CRM/Grundlagen MD/ARK_DATABASE_SCHEMA_v1_5.md`** (~3000 Zeilen)

Navigations-Hinweise:
- **v1.2→v1.3 Delta:** Zeilen 1–213
- **Grundregeln + Pflichtfelder:** §0–§0.2 (Z. 228–306)
- **Events + Automation:** §1 (Z. 308–461)
- **Core-Module:** §2 Kandidaten (Z. 463) / §3 Accounts (Z. 775) / §4 Jobs (Z. 939) / §5 Mandate (Z. 1051) / §6 Prozesse (Z. 1122)
- **Services:** §7 Activity (Z. 1223) / §8 Assessments (Z. 1339) / §9 Scraper (Z. 1376) / §10 Analytics (Z. 1429) / §11 Stammdaten (Z. 1570)
- **AI/RAG:** §12 (Z. 1625)
- **Dokumente + Integrationen:** §14–§15b (Z. 1765–1950)
- **Dok-Generator-Addendum v1.3.4:** §14.1–14.3 (Z. 1817–1891)
- **Auth + Governance:** §16 (Z. 1953)
- **Quality + Merge:** §17–§18 (Z. 2069–2123)
- **Phase 2 Scaffold inkl. Buchhaltung:** §19 (Z. 2127–2218)
- **Migrations 004/005/007:** §20–§22 (Z. 2245–2383)
- **Nachtrag v1.3.1 (Theme, Dossier, Org-Funktion):** §23 (Z. 2386–2427)
- **Widerspruchsfreiheits-Checkliste:** Z. 2430–2495
- **v1.4 Zeit-Modul-Erweiterung:** Z. 2582–2660
- **v1.5 E-Learning-Modul Sub A/B/C/D:** Z. 2663–2970

**Related:**
- [[ARK_STAMMDATEN_EXPORT_v1_3]] — Enum-Werte, dim_*-Inhalte
- [[ARK_BACKEND_ARCHITECTURE_v2]] — Endpunkte, Events, Saga-Flows V1–V7
- [[ARK_FRONTEND_FREEZE_v1]] — UI-Patterns, Routing, Design-System
- [[ARK_GESAMTSYSTEM_UEBERSICHT_v1]] — Gesamtbild + Changelog
- [[spec-sync-regel]] — Sync-Matrix Grundlagen ↔ Detailmasken-Specs
