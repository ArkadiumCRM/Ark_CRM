# ARK Datenbank – Schema v1.6

**Stand:** 2026-04-25
**System:** Greenfield – komplett neuer Aufbau, keine Altlasten
**Status:** Review-Reif (Ergänzung v1.5)
**Vorgänger:** v1.5 (2026-04-24 · E-Learning + HR) / v1.4 (2026-04-19) / v1.3 (2026-04-14)
**Scope v1.6:** Performance-Modul (TEIL Q · 14 Tabellen im `ark_perf`-Schema + 7 HR-Performance-Tabellen im `ark_hr` + 10 Live-Views + 8 Materialized Views + RLS + 3 Rollen) · §19 Streichungen (8 Performance-Stubs migriert ins HR-Modul, 3 Stubs gestrichen ↦ E-Learning Single-Source) · `dim_process_stages` + `dim_user` erweitert
**Scope v1.5:** E-Learning-Modul Sub A/B/C/D + HR-Modul (TEIL M)

## Änderungen v1.2 → v1.3

Resultiert aus dem Komplett-Audit (`wiki/analyses/audit-2026-04-13-komplett.md`) + Entscheidungen 2026-04-14 (`wiki/analyses/audit-entscheidungen-2026-04-14.md`). Alle neuen Tabellen und Feld-Erweiterungen aus den 18 Detailseiten-Specs konsolidiert.

### 28 neue Fact-/Bridge-Tabellen

| # | Tabelle | Zweck | P |
|---|---------|-------|---|
| 1 | `fact_mandate_option` | Mandat-Optionen VI–X (Idents/Dossiers/Marketing/Assessment/Garantie) | P0 |
| 2 | `fact_candidate_presentation` | Kandidaten-Vorstellungen (Schutzfrist-Trigger) | P0 |
| 3 | `fact_protection_window` | Schutzfrist-Fenster (12/16 Monate, account + group Scope) | P0 |
| 4 | `fact_referral` | Referral-Prämien-Tracking | P0 |
| 5 | `fact_assessment_order` | Assessment-Auftrag (Credits-Modell v0.2) | P0 |
| 6 | `fact_assessment_order_credits` | Bridge: Auftrag-Typ-Credits (MDI/Relief/ASSESS 5.0/...) | P0 |
| 7 | `fact_assessment_run` | Assessment-Durchführung pro Credit | P0 |
| 8 | `fact_assessment_billing` | Assessment-Rechnungen | P0 |
| 9 | `fact_candidate_assessment_version` | Zentrale Versionierung Test-Ergebnisse | P0 |
| 10 | `fact_process_interviews` | Interview-Timeline pro Prozess | P0 |
| 11 | `fact_candidate_matches` | Matching-Scores Kandidat-Job (7 Sub-Scores) | P0 |
| 12 | `dim_firmengruppen` | Firmengruppen-Stammdaten | P0 |
| 13 | `bridge_mandate_accounts` | N:N Mandat-Account (Gruppen-Taskforce) | P0 |
| 14 | `fact_scraper_schedule` | Scraper-Scheduling mit Priority | P0 |
| 15 | `fact_scraper_runs` | Scraper-Run-Historie | P0 |
| 16 | `fact_scraper_findings` | Scraper-Findings (Review-Queue + review_priority) | P0 |
| 17 | `fact_scraper_alerts` | Scraper-Alerts (4 Severity-Levels) | P0 |
| 18 | `fact_projects` | Bauprojekte | P0 |
| 19 | `fact_project_bkp_gewerke` | Projekt-Gewerke (BKP-basiert) | P0 |
| 20 | `fact_project_company_participations` | Firmen-Beteiligungen an Gewerken | P0 |
| 21 | `fact_project_candidate_participations` | Kandidaten-Beteiligungen an Gewerken | P0 |
| 22 | `fact_project_media` | Projekt-Galerie (Fotos/Renderings) | P0 |
| 23 | `fact_account_project_notes` | AM-Notizen pro Account-Projekt-Kombo | P0 |
| 24 | `bridge_project_clusters` | N:N Projekt-Cluster (mit is_primary) | P0 |
| 25 | `bridge_project_spartens` | N:N Projekt-Sparte (mit is_primary) | P0 |
| 26 | `fact_project_similarities` | Projekt-Ähnlichkeits-Cache (Matching) | P1 |
| 27 | `dim_scraper_types` | Scraper-Typen-Registry (siehe Stammdaten v1.3) | P0 |
| 28 | `dim_scraper_global_settings` | Scraper-Settings (siehe Stammdaten v1.3) | P0 |

### 15 neue dim_*-Stammdaten-Tabellen

Vollständige Inhalte siehe `ARK_STAMMDATEN_EXPORT_v1_3.md` Sektionen 51–65:
`dim_assessment_types`, `dim_rejection_reasons_internal`, `dim_honorar_settings` (formal dokumentiert), `dim_culture_dimensions`, `dim_sia_phases`, `dim_dropped_reasons`, `dim_cancellation_reasons`, `dim_offer_refused_reasons`, `dim_vacancy_rejection_reasons`, `dim_scraper_types`, `dim_scraper_global_settings`, `dim_matching_weights`, `dim_matching_weights_project`, `dim_reminder_templates`, `dim_time_packages`.

### Feld-Erweiterungen bestehender Tabellen (30+)

**`fact_mandate` (+10 Felder):**
```sql
+ terminated_by ENUM('arkadium','client') NULL
+ terminated_reason VARCHAR NULL
+ terminated_at DATE NULL
+ terminated_note TEXT NULL
+ termination_invoice_id FK → fact_mandate_billing NULL
+ exclusivity_end_date DATE NULL
+ final_outcome VARCHAR NULL
+ group_id FK → dim_firmengruppen NULL
+ is_longlist_locked BOOLEAN DEFAULT FALSE
+ linked_project_id FK → fact_projects NULL  -- Phase 1.5
```

**`fact_mandate_billing.billing_type` Enum erweitert:**
`+ 'termination'` · `+ 'option'` · `+ 'refund'`

**`fact_jobs` (+29 Felder)** — siehe `ARK_JOB_DETAILMASKE_SCHEMA_v0_1.md` § 14 für komplette Definition. Kernfelder:
- Beschreibung: `description_md`, `responsibilities_md`, `requirements_md`, `nice_to_have_md`, `language`
- Konditionen: `salary_min_chf`, `salary_max_chf` (CHECK max≥min), `pensum_min/max`, `contract_type`, `target_start_date`, `vacation_days`, `remote_pct`, `benefits` JSONB
- Matching: `required_skills` JSONB, `preferred_skills` JSONB, `min_years_experience`, `required_software_ids` JSONB, `nogo_employer_ids` JSONB, `location_radius_km`
- Publication: `is_public_posting`, `public_url`, `publication_channels` JSONB, `is_confidential`
- Lifecycle: `confirmation_status ENUM('scraper_proposal','confirmed','rejected')`, `filled_at`, `filled_by_candidate_id` FK, `closed_at`
- Links: `linked_project_id FK → fact_projects` NULL (Phase 1.5)

**`fact_process_core` (+4 Felder):**
```sql
+ on_hold_reason TEXT NULL
+ stale_detected_at TIMESTAMP NULL
+ cancellation_reason VARCHAR NULL
+ cancelled_by ENUM('candidate','client','internal') NULL
```

**`dim_accounts` (+3 Felder):**
```sql
+ group_id FK → dim_firmengruppen NULL
+ growth_rate_3y_pct DECIMAL
+ revenue_last_year_chf DECIMAL
```

**`dim_automation_settings` (+20 Keys)** — siehe Stammdaten v1.3 Sektion 66 für vollständige Liste. Highlights:
- `process_stale_thresholds` JSONB (pro Stage)
- Temperature-Schwellen (Kandidat + Account)
- Schutzfrist-Settings (base_months, extend_months, info_request_wait_days)
- Batch-Zeitpunkte (assessment_billing_overdue, process_guarantee_closer, process_stale_detection)
- Referral-Offset-Tage
- Matching-Daily-Batch-Hour

**`fact_candidate_briefing`:** UNIQUE-Constraint entfernt → unbegrenzte Briefing-Versionen pro Kandidat (aktuellstes via `ORDER BY briefing_date DESC LIMIT 1`).

**Bridge-Tabellen Rating-Range:**
`bridge_candidate_functions` / `bridge_candidate_focus` / `bridge_candidate_edv`: `rating` 1-10 (statt 1-5).

### Aufgelöste Widersprüche & Klärungen

| # | Thema | Lösung |
|---|-------|--------|
| W1 | Sprachstandard | **Englisch für ID-Felder** — konsistent `candidate_id` (nicht `kandidat_id`), `account_id`, `mandate_id`, `process_id`, `group_id`, `project_id` |
| W2 | `dim_jobs` vs. `fact_jobs` | Nur `fact_jobs` operativ — kein separates `dim_jobs`-Katalog (Entscheidung #6) |
| W3 | `dim_candidates` vs. `dim_candidates_profile` | Nur `dim_candidates_profile` (Typo-Fixes in Specs) |
| W4 | Polymorphe FK Scraper-Findings | Strict CHECK Constraint: `target_entity_id` muss mit `target_entity_type` konsistent sein, oder beide NULL |
| W5 | Protection-Window ONE-OF | `CHECK ((scope='account' AND account_id IS NOT NULL AND group_id IS NULL) OR (scope='group' AND group_id IS NOT NULL AND account_id IS NULL))` |
| W6 | `fact_assessment_run.result_version_id` | FK zu neuer `fact_candidate_assessment_version` (Entscheidung #11) |
| W7 | `volume_range` vs. `volume_chf_exact` | `volume_range` als **Generated Column STORED** aus `volume_chf_exact`, `volume_range_manual` als Fallback (Entscheidung #12) |
| W8 | `cluster_ids` JSONB vs. Bridge | Bridge-Tabellen `bridge_project_clusters` + `bridge_project_spartens` (Entscheidung #13) |
| W9 | BKP-Hierarchie-Validierung | CHECK `ebene BETWEEN 1 AND 4`, Trigger oder App-Level: `parent_code.ebene = this.ebene - 1` |
| W10 | SIA-Phasen-Zählung | 6 Haupt- + 12 Teilphasen via `dim_sia_phases.parent_phase_id` (Entscheidung #3) |
| W11 | Schutzfrist-Gruppen-Scope | `fact_protection_window.scope ENUM('account','group')` + `group_id` FK. Bei Account in Gruppe werden 2 Einträge erstellt. |
| W12 | Mandat-Gruppen-Bindung | `fact_mandate.group_id` FK nullable + `bridge_mandate_accounts` für gruppenübergreifende Taskforces |
| W13 | Credits-Modell typisiert | `fact_assessment_order_credits` Bridge statt `credits_total` Feld (Entscheidung #10) |
| W14 | Billing-Types erweitert | `fact_mandate_billing.billing_type` Enum um 3 Werte erweitert |

### Neue Views

```sql
-- Aktive claim-pending Schutzfristen (über beide Scopes)
CREATE VIEW v_protection_window_claims AS
SELECT pw.*, c.first_name, c.last_name,
       COALESCE(a.account_name, g.group_name) AS protected_entity_name,
       pw.scope AS protection_scope
FROM fact_protection_window pw
LEFT JOIN dim_candidates_profile c ON c.id = pw.candidate_id
LEFT JOIN dim_accounts a ON a.id = pw.account_id
LEFT JOIN dim_firmengruppen g ON g.id = pw.group_id
WHERE pw.status = 'claim_pending';

-- Credits-Aggregation pro Account (für Account Tab 8 KPI-Banner)
CREATE VIEW v_assessment_credits_account_summary AS
SELECT o.account_id,
       oc.assessment_type_id,
       SUM(oc.quantity) AS total_bought,
       SUM(oc.used_count) AS total_used,
       SUM(oc.quantity - oc.used_count) AS total_remaining
FROM fact_assessment_order o
JOIN fact_assessment_order_credits oc ON oc.assessment_order_id = o.id
WHERE o.status NOT IN ('offered','cancelled')
GROUP BY o.account_id, oc.assessment_type_id;

-- Credits-Aggregation pro Auftrag (für Order-Header Snapshot-Bar)
CREATE VIEW v_assessment_credits_order_summary AS
SELECT oc.assessment_order_id,
       SUM(oc.quantity) AS total_credits,
       SUM(oc.used_count) AS used_credits,
       SUM(oc.quantity - oc.used_count) AS remaining_credits,
       COUNT(DISTINCT oc.assessment_type_id) AS type_variety
FROM fact_assessment_order_credits oc
GROUP BY oc.assessment_order_id;
```

### Events — Erweiterung `dim_event_types`

30 neue Event-Typen (siehe Audit-Report Teil II, Backend v2.5). Highlights für DB-Constraints:
- `mandate_terminated`, `termination_invoice_generated`, `protection_window_opened/extended`, `group_protection_window_opened`
- `assessment_order_created/signed`, `assessment_credit_assigned/reassigned_*`, `assessment_run_scheduled/completed/cancelled`, `assessment_version_created`, `order_credits_rebalanced_by_founder`
- `process_created`, `stale_detected`, `early_exit_recorded`, `guarantee_refund_issued`, `process_rejected_due_to_mandate_termination`
- `scraper_run_started/finished/failed`, `finding_detected/accepted/rejected/marked_low_confidence`, `protection_violation_detected`, `anomaly_detected`
- `group_mandate_created`, `group_member_added/removed`, `group_culture_generated`, `group_protection_window_opened`
- `job_created_manual/from_scraper/from_mandate/from_org_position`, `job_filled`, `job_closed`, `vacancy_changed`, `job_disappeared_from_source`
- `claim_invoiced`, `claim_context_determined` (mit context_case X/Y/Z)

### Migrations-Reihenfolge (Waves)

**Wave 1 (parallel, P0-Blocker, 6–8 Wochen):**
1. `dim_firmengruppen` + `dim_accounts.group_id` (Voraussetzung für Schutzfrist-Gruppen-Scope)
2. `dim_assessment_types` Stammdaten
3. Assessment-Stack: `fact_assessment_order` + `_credits` + `fact_assessment_run` + `_billing` + `fact_candidate_assessment_version`
4. `fact_mandate_option` + `fact_mandate` (10 neue Felder) + `fact_mandate_billing` (Enum-Erweiterung)
5. `fact_candidate_presentation` + `fact_protection_window` (mit scope-CHECK)
6. `fact_referral`
7. Scraper-Modul (6 Tabellen + 2 dim_*)
8. `fact_process_interviews` + `fact_process_core` (4 Felder)

**Wave 2 (abhängig Wave 1, 4–6 Wochen):**
9. Projekt-Modul (8 Tabellen + Bridge-Tabellen + `dim_sia_phases`)
10. `fact_candidate_matches` + `dim_matching_weights`
11. `bridge_mandate_accounts`
12. `fact_jobs` (29 Felder)
13. Views (v_protection_window_claims, v_assessment_credits_*)

**Wave 3 (Polish, Stammdaten-Kataloge, 2 Wochen):**
14. Alle restlichen dim_*-Tabellen (siehe Stammdaten v1.3 Sektionen 56–65)
15. `dim_automation_settings` (20 neue Keys)
16. Rating-Range-Migration (1-5 → 1-10)

### Vollständige Spalten-Definitionen

Die konkreten DDL-Statements der neuen Tabellen sind in den jeweiligen Spec-Dokumenten gepflegt (Single Source of Truth pro Entity):

| Tabellen-Bereich | Quell-Spec |
|------------------|------------|
| fact_mandate_option, fact_candidate_presentation, fact_protection_window | `specs/ARK_MANDAT_DETAILMASKE_INTERACTIONS_v0_3.md` TEIL 9 + TEIL 10 |
| fact_referral | `wiki/sources/referral-programm.md` + Mandat-Interactions TEIL 11 |
| fact_assessment_* (5 Tabellen) | `specs/ARK_ASSESSMENT_DETAILMASKE_SCHEMA_v0_2.md` § 13 |
| fact_candidate_assessment_version | Assessment Schema v0.2 § 13 |
| fact_process_interviews | `specs/ARK_PROZESS_DETAILMASKE_SCHEMA_v0_1.md` § 11 |
| fact_candidate_matches | `specs/ARK_JOB_DETAILMASKE_SCHEMA_v0_1.md` § 14 |
| dim_firmengruppen, bridge_mandate_accounts | `specs/ARK_FIRMENGRUPPE_DETAILMASKE_SCHEMA_v0_1.md` § 14 |
| Scraper-Modul (6 Fact + 2 dim_*) | `specs/ARK_SCRAPER_MODUL_SCHEMA_v0_1.md` § 14 |
| Projekt-Modul (7 Fact + 2 Bridge) | `specs/ARK_PROJEKT_DETAILMASKE_SCHEMA_v0_2.md` § 14 |
| dim_* Stammdaten (15 Tabellen) | `ARK_STAMMDATEN_EXPORT_v1_3.md` Sektionen 51-65 |
| fact_mandate + fact_jobs Feld-Erweiterungen | Mandat Schema v0.1 + Job Schema v0.1 |

---

# Original v1.2 (unverändert übernommen als Referenz)

# ARK Datenbank – Schema Freeze v1.2 (konsolidiert)

**Stand:** 2026-03-30
**System:** Greenfield – komplett neuer Aufbau, keine Altlasten
**Status:** EINGEFROREN – verbindliche Basis für alle Entwicklungsarbeiten
**Ersetzt:** ARK_DATABASE_SCHEMA_v1_1
**Änderungen v1.2:** Gesamtsystem-Review, Skills deprecated, Preleads, Wechselmotivation, AGB-Tracking, Email-System, Activity-Types 11 Kategorien, neue Tabellen/Events/Indizes

---

## 0. Absolut verbindliche Grundregeln

```
REGEL 1   Alle IDs sind uuid – überall, ohne Ausnahme, ab Tag 1
REGEL 2   Nur ark Schema – public existiert nicht
REGEL 3   Kein Hard-Delete – immer Soft-Delete via is_active + deleted_at
REGEL 4   Stammdaten sind global – kein tenant_id auf dim_* Tabellen
REGEL 5   AI schreibt nie direkt in operative Tabellen
REGEL 6   Jede Zustandsänderung erzeugt einen Event in fact_event_queue
REGEL 7   Business Write + Event Insert immer in derselben Transaktion
REGEL 8   Tokens/Secrets niemals im Klartext – nur Referenz auf Secret Store
REGEL 9   PII-Felder werden in Logs maskiert
REGEL 10  fact_audit_log – kein DELETE, kein UPDATE, nur INSERT
```

---

## 0.1 Pflichtfelder

### Operative Tabellen (haben tenant_id)
```sql
id              uuid        PRIMARY KEY DEFAULT gen_random_uuid()
tenant_id       uuid        NOT NULL REFERENCES ark.tenants(id)
is_active       boolean     NOT NULL DEFAULT true
created_at      timestamptz NOT NULL DEFAULT now()
updated_at      timestamptz NOT NULL DEFAULT now()
row_version     bigint      NOT NULL DEFAULT 1
deleted_at      timestamptz
deleted_by      uuid        REFERENCES ark.dim_crm_users(id)
deletion_reason text
```

### Stammdaten-Tabellen (kein tenant_id)
```sql
id              uuid        PRIMARY KEY DEFAULT gen_random_uuid()
is_active       boolean     NOT NULL DEFAULT true
created_at      timestamptz NOT NULL DEFAULT now()
updated_at      timestamptz NOT NULL DEFAULT now()
row_version     bigint      NOT NULL DEFAULT 1
```

### Trigger (auf alle Tabellen)
```sql
CREATE OR REPLACE FUNCTION ark.update_row_meta()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  NEW.row_version = OLD.row_version + 1;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

### Globale Indizes (auf alle operativen Tabellen)
```sql
CREATE INDEX ON {table}(tenant_id);
CREATE INDEX ON {table}(is_active) WHERE is_active = true;
CREATE INDEX ON {table}(updated_at);
CREATE INDEX ON {table}(deleted_at) WHERE deleted_at IS NULL;
```

---

## 0.2 Historisierung (für bestimmte Tabellen)

Tabellen die sich über Zeit ändern und deren Historie relevant ist:
```sql
valid_from      timestamptz NOT NULL DEFAULT now()
valid_to        timestamptz                          -- NULL = aktuell gültig
is_current      boolean     NOT NULL DEFAULT true

CREATE INDEX ON {table}(is_current) WHERE is_current = true;
CREATE INDEX ON {table}(valid_from, valid_to);
```

Betrifft: alle bridge_candidate_*, bridge_account_contacts_history,
fact_match_scores, fact_ai_classifications, dim_salary_benchmark

---

## 1. EVENT-RÜCKGRAT

### `dim_event_types` (Stammdaten – kein tenant_id)
```sql
event_category  text NOT NULL
  CHECK (event_category IN ('candidate','process','job','mandate',
    'call','email','document','scrape','system','match',
    'jobbasket','reminder','account'))
entity_type     text NOT NULL
event_name      text NOT NULL UNIQUE
event_description text
payload_schema_json jsonb
is_automatable  boolean NOT NULL DEFAULT true
sort_order      int

UNIQUE (event_name)
```

Beispiel-Events: `candidate.stage_changed · candidate.temperature_changed ·
candidate.wechselmotivation_changed · process.stage_changed · process.stale_detected ·
process.on_hold · job.stage_changed · job.filled_externally ·
mandate.stage_changed · mandate.activated · call.received ·
call.transcript_ready · email.received · email.sent ·
document.uploaded · document.cv_parsed · history.created ·
scrape.change_detected · scrape.new_job_detected ·
match.score_updated · assessment.completed ·
jobbasket.candidate_added · jobbasket.go_oral · jobbasket.go_written ·
reminder.overdue · account.contact_left ·
mandate.research_stage_changed`

---

### `dim_automation_rules` (operativ – hat tenant_id)
```sql
rule_key        text NOT NULL
rule_name       text NOT NULL
event_type_id   uuid NOT NULL REFERENCES ark.dim_event_types(id)
condition_json  jsonb
action_type     text NOT NULL
  CHECK (action_type IN ('create_reminder','send_notification',
    'update_field','trigger_ai','create_history',
    'trigger_webhook','create_event'))
action_config_json jsonb
priority        int NOT NULL DEFAULT 0
version         int NOT NULL DEFAULT 1
last_triggered_at timestamptz
trigger_count   bigint NOT NULL DEFAULT 0
description     text
created_by      uuid REFERENCES ark.dim_crm_users(id)

-- Circuit Breaker (Manus AI Empfehlung: Schutz vor Event-Endlosschleifen)
max_triggers_per_hour   int             -- NULL = unbegrenzt
max_triggers_per_day    int             -- NULL = unbegrenzt
circuit_breaker_enabled boolean NOT NULL DEFAULT true
circuit_breaker_tripped boolean NOT NULL DEFAULT false
circuit_breaker_tripped_at timestamptz
circuit_breaker_reset_at   timestamptz
last_trigger_window_count  int NOT NULL DEFAULT 0

UNIQUE (tenant_id, rule_key)
```

**Zweck Circuit Breaker:** Verhindert Event-Stürme. Beispiel: Scraper erkennt bei 50'000 Kandidaten gleichzeitig eine LinkedIn-Massenänderung → ohne Circuit Breaker würden 50'000 AI-Tasks und E-Mails gleichzeitig ausgelöst. Mit `max_triggers_per_hour = 100` wird die Rule nach 100 Auslösungen pro Stunde automatisch gebremst (`circuit_breaker_tripped = true`) bis zur Reset-Zeit.

---

### `fact_event_queue` (operativ – hat tenant_id)
```sql
event_type_id       uuid NOT NULL REFERENCES ark.dim_event_types(id)
entity_type         text NOT NULL
entity_id           uuid NOT NULL
payload_json        jsonb NOT NULL
status              text NOT NULL DEFAULT 'pending'
  CHECK (status IN ('pending','processing','done','failed','dead_lettered'))

-- Idempotenz
idempotency_key     text NOT NULL
source_system       text NOT NULL
  CHECK (source_system IN ('threecx','outlook','scraper','crm','app',
    'linkedin','whatsapp','system','webhook'))
source_event_id     text

-- Event-Kette
causation_event_id  uuid REFERENCES ark.fact_event_queue(id)
correlation_id      uuid NOT NULL DEFAULT gen_random_uuid()
parent_event_id     uuid REFERENCES ark.fact_event_queue(id)

-- Ausführung
triggered_by        uuid REFERENCES ark.dim_crm_users(id)
triggered_at        timestamptz NOT NULL DEFAULT now()
processing_started_at timestamptz
processed_at        timestamptz

-- Dead Letter
next_retry_at       timestamptz
max_retries         int NOT NULL DEFAULT 3
retry_count         int NOT NULL DEFAULT 0
dead_lettered_at    timestamptz
failure_code        text
error_message       text
worker_id           text

UNIQUE (tenant_id, source_system, source_event_id)
  WHERE source_event_id IS NOT NULL

-- v1.2: UNIQUE auf idempotency_key für Idempotenz-Garantie
UNIQUE (tenant_id, idempotency_key)

CREATE INDEX ON ark.fact_event_queue(status, triggered_at)
  WHERE status = 'pending';
CREATE INDEX ON ark.fact_event_queue(event_type_id, status);
CREATE INDEX ON ark.fact_event_queue(entity_type, entity_id);
CREATE INDEX ON ark.fact_event_queue(next_retry_at)
  WHERE status = 'failed';
CREATE INDEX ON ark.fact_event_queue(correlation_id);
CREATE INDEX ON ark.fact_event_queue(idempotency_key);
```

---

### `fact_event_log` (operativ – hat tenant_id)
```sql
event_id            uuid NOT NULL REFERENCES ark.fact_event_queue(id)
rule_id             uuid REFERENCES ark.dim_automation_rules(id)
correlation_id      uuid NOT NULL
action_taken        text NOT NULL
input_snapshot_json jsonb
output_snapshot_json jsonb
result_json         jsonb
duration_ms         int
logged_at           timestamptz NOT NULL DEFAULT now()

-- Kein UPDATE, kein DELETE erlaubt
-- REVOKE UPDATE, DELETE ON ark.fact_event_log FROM app_user;
```

---

### `fact_notifications` (operativ – hat tenant_id)
```sql
event_id            uuid REFERENCES ark.fact_event_queue(id)
mitarbeiter_id      uuid NOT NULL REFERENCES ark.dim_mitarbeiter(id)
channel             text NOT NULL
  CHECK (channel IN ('push','email','in-app','sms'))
template_id         uuid REFERENCES ark.dim_notification_templates(id)
title               text NOT NULL
body                text
payload_json        jsonb
sent_at             timestamptz
read_at             timestamptz
is_confetti         boolean NOT NULL DEFAULT false
```

---

## 2. CORE – kandidaten/

### `dim_candidates_profile` (operativ)
```sql
-- IDs
id                          uuid PK  -- DER PK
-- Pflichtfelder via Standard (id, tenant_id, is_active etc.)

-- Person
first_name                  text NOT NULL
last_name                   text NOT NULL
full_name                   text GENERATED ALWAYS AS
                              (first_name || ' ' || last_name) STORED
gender                      text
birth_date                  date
nationality                 text
ansprache                   text CHECK (ansprache IN ('Herr','Frau',''))

-- Kontakt
email_1                     text
email_2                     text
phone_mobile                text
phone_direct                text
phone_private               text

-- Standort
adresse                     text
plz                         text
wohnort                     text
arbeitsort                  text
kanton                      text
grossregion                 text
country                     text DEFAULT 'Switzerland'

-- Online
linkedin_url                text
xing_url                    text
photo_url                   text
photo_bucket                text

-- CRM-Status
candidate_stage             text NOT NULL DEFAULT 'Check'
  CHECK (candidate_stage IN ('Check','Refresh','Premarket',
    'Active Sourcing','Market Now','Inactive','Blind','Datenschutz'))
candidate_temperature       text DEFAULT 'Cold'
  CHECK (candidate_temperature IN ('Hot','Warm','Cold'))

-- v1.2: Wechselmotivation (8 Stufen) — faktische Situation des Kandidaten
-- Temperatur = Dringlichkeit aus ARK-Sicht, Wechselmotivation = Kandidaten-Situation
wechselmotivation           text
  CHECK (wechselmotivation IN (
    'Arbeitslos',
    'Will/muss wechseln',
    'Will/muss wahrscheinlich wechseln',
    'Wechselt bei gutem Angebot',
    'Wechselmotivation spekulativ',
    'Wechselt gerade intern & will abwarten',
    'Will absolut nicht wechseln',
    'Will nicht mit uns zusammenarbeiten'
  ))

-- Zuständig
candidate_manager_id        uuid REFERENCES ark.dim_mitarbeiter(id)
candidate_hunter_id         uuid REFERENCES ark.dim_mitarbeiter(id)
owner_team                  text
sparte_id                   uuid REFERENCES ark.dim_sparte(id)
  -- PRIMÄRE Sparte für Zuständigkeit/Routing
  -- Alle relevanten Sparten: bridge_candidate_sparte
  -- Invariante: is_primary_sparte=true in Bridge = konsistent mit diesem Feld

-- Flags
is_do_not_contact           boolean NOT NULL DEFAULT false
do_not_contact_reason       text
blue_collar                 boolean NOT NULL DEFAULT false
fachliche_fuehrung          boolean NOT NULL DEFAULT false
df_1_ebene                  boolean NOT NULL DEFAULT false
df_2_ebene                  boolean NOT NULL DEFAULT false
vr_c_suite                  boolean NOT NULL DEFAULT false

-- Dokumente
is_original_cv_available    boolean NOT NULL DEFAULT false
is_ark_cv_available         boolean NOT NULL DEFAULT false
dossier_preference          text

-- DSGVO
data_retention_date         date
anonymized_at               timestamptz

-- Qualität
data_freshness_score        int CHECK (data_freshness_score BETWEEN 0 AND 100)
data_quality_score          int CHECK (data_quality_score BETWEEN 0 AND 100)
missing_fields_json         jsonb
candidate_source            text
referral_from_id            uuid REFERENCES ark.dim_candidates_profile(id)

-- Merge
merged_into_id              uuid REFERENCES ark.dim_candidates_profile(id)
merge_batch_id              uuid
merge_reason                text
merged_at                   timestamptz
merged_by                   uuid REFERENCES ark.dim_crm_users(id)

-- Notizen
comment_short               text
comment_internal            text

-- Historisierung
valid_from                  timestamptz NOT NULL DEFAULT now()
valid_to                    timestamptz
is_current                  boolean NOT NULL DEFAULT true

-- Constraints
UNIQUE (tenant_id, email_1) WHERE email_1 IS NOT NULL AND is_active = true
```

---

### `fact_candidate_briefing` (operativ)
```sql
candidate_id        uuid NOT NULL REFERENCES ark.dim_candidates_profile(id)
briefing_date       date NOT NULL
version             int NOT NULL DEFAULT 1
previous_version_id uuid REFERENCES ark.fact_candidate_briefing(id)

-- Gehalt
briefing_salary_currently   int          -- CHF
briefing_salary_ziel        int
briefing_salary_schmerzgrenze int
briefing_salary_monthly     boolean
briefing_salary_sti         text
briefing_salary_lti         text
briefing_salary_spesen      text

-- Arbeit
briefing_pensum             int CHECK (briefing_pensum BETWEEN 0 AND 100)
briefing_pensum_future      int CHECK (briefing_pensum_future BETWEEN 0 AND 100)
briefing_employment_status  text
briefing_kuendigungsfrist   text
briefing_wechselbereitschaft text

-- Mobilität
briefing_mobility           text
briefing_arbeitsweg         text
briefing_arbeitsweg_distanz int
briefing_umzugbereitschaft  boolean
briefing_homeoffice_currently int
briefing_homeoffice_days_currently int

-- Bewertung
briefing_kandidatenbewertung text CHECK (briefing_kandidatenbewertung IN ('A','B','C'))
briefing_go_themen          text
briefing_nogo_themen        text

-- Kompetenzen
briefing_hardskills         text
briefing_social_skills      text
briefing_methodenkompetenz  text
briefing_fuehrungskompetenz text

-- Persönlichkeit
briefing_selbstbild_reflexion   text
briefing_fremdbild              text
briefing_intrinsische_motivation text
briefing_beduerfnisanalyse      text
briefing_triggerpunkt           text
briefing_moderation             text

-- Zonen-Modell
briefing_komfortzone        text
briefing_lernzone           text
briefing_wachstumszone      text
briefing_angstzone          text
briefing_sweet_spot         text

-- Privat
briefing_zivilstand         text
briefing_kinder             text
briefing_privates_leidenschaft text

-- Sonstiges
briefing_offene_bewerbungen text
briefing_other_pdl          text
briefing_verpflichtung      boolean
briefing_verpflichtung_amount int
briefing_verpflichtung_time text
```

---

### `fact_candidate_employment` (operativ)
```sql
candidate_id        uuid NOT NULL REFERENCES ark.dim_candidates_profile(id)
employer            text NOT NULL
account_id          uuid REFERENCES ark.dim_accounts(id)
job_title           text
function_id         uuid REFERENCES ark.dim_functions(id)
start_date          date
end_date            date
currently_employed  boolean NOT NULL DEFAULT false
work_region         text
description         text
zugangsgrund        text
abgangsgrund        text
entry_type          text CHECK (entry_type IN ('job','education','gap','other'))
sort_order          int NOT NULL DEFAULT 0

CHECK (end_date IS NULL OR end_date >= start_date)
```

---

### `fact_candidate_projects` (operativ)
```sql
candidate_id            uuid NOT NULL REFERENCES ark.dim_candidates_profile(id)
employment_id           uuid REFERENCES ark.fact_candidate_employment(id)
project_name            text NOT NULL
project_description     text
project_location        text
project_owner           text
project_architect       text
project_stakeholder     text
project_cost            bigint
team_size               int
budget_responsibility   bigint
start_date              date
end_date                date
dim_project_id          uuid REFERENCES ark.dim_projects(id)
highlight_for_cv        boolean NOT NULL DEFAULT false
is_reference_project    boolean NOT NULL DEFAULT false
project_type            text
my_role                 text
challenges              text
results                 text
technologies            text
sort_order              int NOT NULL DEFAULT 0
```

---

### Bridge-Tabellen Kandidaten (alle operativ, alle mit Historisierung)
```sql
-- bridge_candidate_cluster
candidate_id        uuid NOT NULL REFERENCES ark.dim_candidates_profile(id)
cluster_id          uuid NOT NULL REFERENCES ark.dim_cluster(id)
is_primary_cluster  boolean NOT NULL DEFAULT false
valid_from          timestamptz NOT NULL DEFAULT now()
valid_to            timestamptz
is_current          boolean NOT NULL DEFAULT true
UNIQUE (tenant_id, candidate_id, cluster_id) WHERE is_current = true

-- bridge_candidate_functions
candidate_id        uuid NOT NULL REFERENCES ark.dim_candidates_profile(id)
function_id         uuid NOT NULL REFERENCES ark.dim_functions(id)
is_primary_function boolean NOT NULL DEFAULT false
rating              int CHECK (rating BETWEEN 1 AND 10)
valid_from          timestamptz NOT NULL DEFAULT now()
valid_to            timestamptz
is_current          boolean NOT NULL DEFAULT true
UNIQUE (tenant_id, candidate_id, function_id) WHERE is_current = true

-- bridge_candidate_focus
candidate_id        uuid NOT NULL REFERENCES ark.dim_candidates_profile(id)
focus_id            uuid NOT NULL REFERENCES ark.dim_focus(id)
is_primary_focus    boolean NOT NULL DEFAULT false
rating              int CHECK (rating BETWEEN 1 AND 10)
valid_from / valid_to / is_current  -- wie oben
UNIQUE (tenant_id, candidate_id, focus_id) WHERE is_current = true

-- bridge_candidate_edv
candidate_id        uuid NOT NULL REFERENCES ark.dim_candidates_profile(id)
edv_id              uuid NOT NULL REFERENCES ark.dim_edv(id)
is_primary_edv      boolean NOT NULL DEFAULT false
rating              int CHECK (rating BETWEEN 1 AND 10)
skill_level         text CHECK (skill_level IN ('Grundkenntnisse','Anwender','Experte'))
UNIQUE (tenant_id, candidate_id, edv_id) WHERE is_current = true

-- bridge_candidate_education
candidate_id        uuid NOT NULL REFERENCES ark.dim_candidates_profile(id)
education_id        uuid NOT NULL REFERENCES ark.dim_education(id)
is_primary_education boolean NOT NULL DEFAULT false
graduation_year     int
UNIQUE (tenant_id, candidate_id, education_id) WHERE is_current = true

-- bridge_candidate_languages
candidate_id        uuid NOT NULL REFERENCES ark.dim_candidates_profile(id)
language_id         uuid NOT NULL REFERENCES ark.dim_languages(id)
skill_level         text NOT NULL
  CHECK (skill_level IN ('Muttersprache','C2','C1','B2','B1','A2','A1'))
UNIQUE (tenant_id, candidate_id, language_id) WHERE is_current = true

-- bridge_candidate_sector
candidate_id        uuid NOT NULL REFERENCES ark.dim_candidates_profile(id)
sector_id           uuid NOT NULL REFERENCES ark.dim_sector(id)
is_primary_sector   boolean NOT NULL DEFAULT false
UNIQUE (tenant_id, candidate_id, sector_id) WHERE is_current = true

-- bridge_candidate_sparte
candidate_id        uuid NOT NULL REFERENCES ark.dim_candidates_profile(id)
sparte_id           uuid NOT NULL REFERENCES ark.dim_sparte(id)
is_primary_sparte   boolean NOT NULL DEFAULT false
sparte_order        int
UNIQUE (tenant_id, candidate_id, sparte_id) WHERE is_current = true

-- bridge_candidate_skill — DEPRECATED v1.2 (Skills durch Focus ersetzt)
-- Tabelle bleibt bestehen, aber kein neuer Code darf sie referenzieren
-- candidate_id        uuid NOT NULL REFERENCES ark.dim_candidates_profile(id)
-- skill_id            uuid NOT NULL REFERENCES ark.dim_skills_master(id)
-- ...
```

---

## 3. CORE – accounts/

### `dim_accounts` (operativ)
```sql
account_name            text NOT NULL
account_legal_name      text
handelsregister_uid     text
domain_normalized       text
industry                text
usp                     text
taetigkeitsfelder       text
website_url             text
linkedin_url            text
career_page_url         text
team_page_url           text
country                 text NOT NULL DEFAULT 'Switzerland'
account_status          text NOT NULL DEFAULT 'Active'
  CHECK (account_status IN ('Active','Inactive','Prospect','Blacklisted'))
customer_class          text CHECK (customer_class IN ('A','B','C'))
-- v1.2: Einkaufspotenzial (★/★★/★★★)
purchase_potential       int CHECK (purchase_potential BETWEEN 1 AND 3)
  -- 1 = ★ (0-1 Positionen/Jahr), 2 = ★★ (2-3), 3 = ★★★ (3+)
account_manager_id      uuid REFERENCES ark.dim_mitarbeiter(id)
owner_team              text
sparte_id               uuid REFERENCES ark.dim_sparte(id)
account_group_id        uuid REFERENCES ark.dim_account_groups(id)
employee_count          int
founded_year            int
revenue_estimate_chf    bigint

-- Scraping
scraping_enabled        boolean NOT NULL DEFAULT false
scrape_interval_hours   int
last_scraped_at         timestamptz

-- Intelligence
penetration_score       int CHECK (penetration_score BETWEEN 0 AND 100)
hiring_potential_ranking text
hiring_season           text
job_posting_frequency   text
fluktuation_rate        text
competitor_headhunters  text
dossier_send_preference text
is_no_hunt              boolean NOT NULL DEFAULT false
has_had_process         boolean NOT NULL DEFAULT false
last_contacted_date     date
last_reached_date       date

-- Merge
merged_into_id          uuid REFERENCES ark.dim_accounts(id)
merge_batch_id          uuid

-- v1.2: AGB-Tracking (für Erfolgsbasis-Prozesse)
agb_confirmed_at        timestamptz     -- Wann hat der Kunde die AGB bestätigt?
agb_version             text            -- Welche AGB-Version wurde bestätigt?

-- Notizen
comment_short           text
comment_internal        text

UNIQUE (tenant_id, domain_normalized) WHERE domain_normalized IS NOT NULL
```

### `dim_account_contacts` (operativ, mit Historisierung)
```sql
account_id              uuid NOT NULL REFERENCES ark.dim_accounts(id)
first_name              text NOT NULL
last_name               text NOT NULL
full_name               text
salutation              text
department              text
birthday                date
email_1                 text
email_2                 text
phone_direct            text
phone_mobile            text
linkedin_url            text
xing_url                text
function_id             uuid REFERENCES ark.dim_functions(id)
decision_level          text
is_decision_maker       boolean NOT NULL DEFAULT false
is_key_contact          boolean NOT NULL DEFAULT false
is_champion             boolean NOT NULL DEFAULT false
is_blocker              boolean NOT NULL DEFAULT false
contact_status          text NOT NULL DEFAULT 'Active'
  CHECK (contact_status IN ('Active','Inactive','Left Company'))
relationship_score      int CHECK (relationship_score BETWEEN 1 AND 10)
communication_preference text
best_contact_time       text
do_not_contact          boolean NOT NULL DEFAULT false
disc_type               text
location_id             uuid REFERENCES ark.fact_account_locations(id)
candidate_id            uuid REFERENCES ark.dim_candidates_profile(id)
  -- NULL = Kontakt ist kein Kandidat
  -- Gesetzt = Kontakt ist gleichzeitig als Kandidat erfasst
comment_short           text
onboarding_notes        text
last_contacted_date     date
last_reached_date       date

-- Historisierung
valid_from              timestamptz NOT NULL DEFAULT now()
valid_to                timestamptz
is_current              boolean NOT NULL DEFAULT true
```

### `dim_account_groups` (operativ)
```sql
account_group_name          text NOT NULL
account_group_legal_name    text
account_group_manager_id    uuid REFERENCES ark.dim_mitarbeiter(id)
key_account_group           boolean NOT NULL DEFAULT false
group_status                text CHECK (group_status IN ('Active','Inactive'))
owner_team                  text
country                     text
website_url                 text
linkedin_url                text
comment_short               text
```

### `dim_account_aliases` (operativ)
```sql
account_id      uuid NOT NULL REFERENCES ark.dim_accounts(id)
alias_name      text NOT NULL
alias_type      text CHECK (alias_type IN ('trading_name','abbreviation','former_name'))
is_primary_alias boolean NOT NULL DEFAULT false
UNIQUE (account_id, alias_name)
```

### `fact_account_locations` (operativ)
```sql
account_id              uuid NOT NULL REFERENCES ark.dim_accounts(id)
location_name           text
location_type           text CHECK (location_type IN ('HQ','Branch','Factory','Office'))
is_headquarter          boolean NOT NULL DEFAULT false
address                 text
plz                     text
city                    text
kanton                  text
grossregion             text
country                 text DEFAULT 'Switzerland'
phone                   text
email                   text
website_url             text
linkedin_url            text
employee_count_location int
comment                 text
```

### Bridge-Tabellen Accounts (alle operativ)
```sql
-- Schema identisch zu Kandidaten-Bridges, aber für Accounts
bridge_account_cluster  → account_id + cluster_id + is_core_cluster
bridge_account_functions → account_id + function_id + is_core_function
bridge_account_focus    → account_id + focus_id + is_core_focus
bridge_account_edv      → account_id + edv_id + is_core_edv
bridge_account_sector   → account_id + sector_id + is_core_sector
bridge_account_sparte   → account_id + sparte_id + is_core_sparte

-- Alle mit: UNIQUE (tenant_id, account_id, {ref}_id)
```

---

## 4. CORE – jobs/

### `fact_jobs` (operativ)
```sql
account_id              uuid NOT NULL REFERENCES ark.dim_accounts(id)
account_contact_id      uuid REFERENCES ark.dim_account_contacts(id)
job_title               text NOT NULL
job_description         text
job_ad_text             text
job_link                text
job_source              text
salary_min              int
salary_max              int
-- v1.2: Gehalts-Constraint
CHECK (salary_max IS NULL OR salary_min IS NULL OR salary_min <= salary_max)
salary_currency         text NOT NULL DEFAULT 'CHF'
pensum_min              int DEFAULT 80 CHECK (pensum_min BETWEEN 0 AND 100)
pensum_max              int DEFAULT 100 CHECK (pensum_max BETWEEN 0 AND 100)
job_status              text NOT NULL DEFAULT 'Open'
  CHECK (job_status IN ('Open','Filled','On Hold','Cancelled'))
is_filled               boolean NOT NULL DEFAULT false
filled_reason           text
close_date              date
open_date               date NOT NULL DEFAULT CURRENT_DATE
is_confidential         boolean NOT NULL DEFAULT false
is_exclusive            boolean NOT NULL DEFAULT false
is_retained             boolean NOT NULL DEFAULT false
is_mandate_position     boolean NOT NULL DEFAULT false
is_vacancy_detected     boolean NOT NULL DEFAULT false
mandate_id              uuid REFERENCES ark.fact_mandate(id)
vacancy_id              uuid REFERENCES ark.fact_vacancies(id)
job_owner_id            uuid REFERENCES ark.dim_mitarbeiter(id)
sparte_id               uuid REFERENCES ark.dim_sparte(id)
target_function_id      uuid REFERENCES ark.dim_functions(id)
target_experience_years int
location_city           text
kanton                  text
comment_internal        text
```

### `fact_jobbasket` (operativ)
```sql
candidate_id        uuid NOT NULL REFERENCES ark.dim_candidates_profile(id)
job_id              uuid NOT NULL REFERENCES ark.fact_jobs(id)
process_id          uuid REFERENCES ark.fact_process_core(id)
is_in_job_basket    boolean NOT NULL DEFAULT true

-- v1.2: Prelead als erster Stage (ersetzt Lead)
is_prelead          boolean NOT NULL DEFAULT false
prelead_date        date

is_oral_go          boolean NOT NULL DEFAULT false
is_written_go       boolean NOT NULL DEFAULT false
is_assigned         boolean NOT NULL DEFAULT false
is_to_send          boolean NOT NULL DEFAULT false
is_cv_sent          boolean NOT NULL DEFAULT false
is_rejected         boolean NOT NULL DEFAULT false
go_rejected_stage   text    -- Auf welcher Stage wurde abgelehnt (prelead, oral_go, written_go etc.)

-- v1.2: Differenzierte Rejection (WER hat abgelehnt)
go_rejected_by      text CHECK (go_rejected_by IN ('candidate','cm','am'))
rejection_type_id   uuid REFERENCES ark.dim_jobbasket_rejection_types(id)

rejection_reason    text    -- Freitext-Kommentar
to_send_date        date
cv_sent_date        date
sent_type           text CHECK (sent_type IN ('Email','Portal','Hand','Expose'))
assigned_to         uuid REFERENCES ark.dim_mitarbeiter(id)
expose_sent_date    date
comment             text
UNIQUE (tenant_id, candidate_id, job_id)
```

### `fact_vacancies` (operativ)
```sql
account_id              uuid NOT NULL REFERENCES ark.dim_accounts(id)
vacancy_source          text CHECK (vacancy_source IN ('scraper','manual','referral','linkedin'))
vacancy_status          text NOT NULL DEFAULT 'Open'
  CHECK (vacancy_status IN ('Open','Filled','Closed','Lost'))
detected_date           date NOT NULL DEFAULT CURRENT_DATE
detected_by             uuid REFERENCES ark.dim_mitarbeiter(id)
departure_reason        text
function_id             uuid REFERENCES ark.dim_functions(id)
cluster_id              uuid REFERENCES ark.dim_cluster(id)
sparte_id               uuid REFERENCES ark.dim_sparte(id)
previous_candidate_id   uuid REFERENCES ark.dim_candidates_profile(id)
expected_fill_date      date
go_hunting              boolean NOT NULL DEFAULT false
mandate_potential       text
  CHECK (mandate_potential IN ('Noch_unklar','Hoch','Mittel','Kein'))
priority                text NOT NULL DEFAULT 'Normal'
  CHECK (priority IN ('Normal','High','Urgent'))
job_id                  uuid REFERENCES ark.fact_jobs(id)
comment                 text
```

### Bridge-Tabellen Jobs
```sql
bridge_job_cluster      → job_id + cluster_id + is_primary_cluster
bridge_job_functions    → job_id + function_id + is_primary_function
bridge_job_focus        → job_id + focus_id + is_primary_focus + comment_short
bridge_job_edv          → job_id + edv_id + is_primary_edv
bridge_job_education    → job_id + education_id + is_primary_education
bridge_job_sector       → job_id + sector_id + is_primary_sector
bridge_job_sparte       → job_id + sparte_id + is_primary_sparte
bridge_job_skill        → DEPRECATED v1.2 (Skills durch Focus ersetzt)

-- Alle mit UNIQUE (tenant_id, job_id, {ref}_id)
```

---

## 5. CORE – mandate/

### `fact_mandate` (operativ)
```sql
job_id                  uuid NOT NULL REFERENCES ark.fact_jobs(id)
mandate_owner_id        uuid NOT NULL REFERENCES ark.dim_mitarbeiter(id)
lead_researcher_id      uuid REFERENCES ark.dim_mitarbeiter(id)
mandate_name            text NOT NULL
mandate_type            text NOT NULL
  CHECK (mandate_type IN ('Einzelmandat','RPO','Time'))
mandate_status          text NOT NULL DEFAULT 'Entwurf'
  -- v1.2: Entwurf + Abgelehnt hinzugefügt. Aktivierung via Dokument-Upload "Mandatsofferte unterschrieben"
  -- KPI: Offerten-Conversion-Rate (Entwurf → Aktiv vs. Entwurf → Abgelehnt)
  CHECK (mandate_status IN ('Entwurf','Active','Abgelehnt','Completed','Cancelled'))
ident_target            int
call_target             int
target_placement_date   date
kickoff_date            date
market_capacity         int
market_notes            text
extra_dossiers_qty      int
extra_dossiers_price    int
extra_idents_qty        int
extra_idents_price      int
final_outcome           text
cancellation_reason     text
closing_report_notes    text
is_guarantee_refund     boolean NOT NULL DEFAULT false
guarantee_refund_amount int
guarantee_refund_date   date
```

### `fact_mandate_billing` (operativ)
```sql
mandate_id      uuid NOT NULL REFERENCES ark.fact_mandate(id)
payment_type    text CHECK (payment_type IN ('Retainer','Success','Milestone'))
payment_trigger text
payment_order   int
amount          int NOT NULL
currency        text NOT NULL DEFAULT 'CHF'
invoice_number  text
invoice_date    date
due_date        date
is_paid         boolean NOT NULL DEFAULT false
paid_date       date
```

### `fact_mandate_research` (operativ)
```sql
mandate_id      uuid NOT NULL REFERENCES ark.fact_mandate(id)
candidate_id    uuid NOT NULL REFERENCES ark.dim_candidates_profile(id)
researcher_id   uuid REFERENCES ark.dim_mitarbeiter(id)
contact_status  text NOT NULL DEFAULT 'research'
  CHECK (contact_status IN ('research','nicht_erreichbar',
    'nicht_mehr_erreichbar','nicht_interessiert','dropped',
    'cv_expected','cv_in','briefing','go_muendlich',
    'go_schriftlich','rejected_oral_go','rejected_written_go','ghosted'))
is_on_longlist  boolean NOT NULL DEFAULT true
is_validated    boolean NOT NULL DEFAULT false
is_nogo         boolean NOT NULL DEFAULT false
nogo_reason     text
go_rejection_reason_id uuid REFERENCES ark.dim_rejection_reasons_candidate(id)
is_stage_locked boolean NOT NULL DEFAULT false
priority        int DEFAULT 0
contact_date    date
contact_notes   text
notes           text
```

---

## 6. CORE – prozesse/

### `fact_process_core` (operativ)
```sql
candidate_id            uuid NOT NULL REFERENCES ark.dim_candidates_profile(id)
account_id              uuid NOT NULL REFERENCES ark.dim_accounts(id)
job_id                  uuid NOT NULL REFERENCES ark.fact_jobs(id)
mandate_id              uuid REFERENCES ark.fact_mandate(id)
candidate_manager_id    uuid REFERENCES ark.dim_mitarbeiter(id)
account_manager_id      uuid REFERENCES ark.dim_mitarbeiter(id)
research_analyst_id     uuid REFERENCES ark.dim_mitarbeiter(id)
current_process_stage   text NOT NULL DEFAULT 'Expose'
  CHECK (current_process_stage IN ('Expose','CV Sent','TI','1st',
    '2nd','3rd','Assessment','Offer','Placement'))
current_process_stage_order int
current_process_status  text NOT NULL DEFAULT 'Open'
  CHECK (current_process_status IN ('Open','Placed','On Hold',
    'Closed','Rejected','Stale','Cancelled','Dropped'))
is_placed               boolean NOT NULL DEFAULT false
is_closed               boolean NOT NULL DEFAULT false
is_on_hold              boolean NOT NULL DEFAULT false
on_hold_stage           text
is_assessment_included  boolean NOT NULL DEFAULT false
sparte                  text
team                    text
final_process_outcome   text
rejected_stage          text
rejected_by             text CHECK (rejected_by IN ('candidate','client','internal'))
candidate_rejection_reason uuid REFERENCES ark.dim_rejection_reasons_candidate(id)
client_rejection_reason    uuid REFERENCES ark.dim_rejection_reasons_client(id)
dropped_reason             uuid REFERENCES ark.dim_dropped_reasons(id)
offer_refused_reason       uuid REFERENCES ark.dim_offer_refused_reasons(id)
cancellation_reason        uuid REFERENCES ark.dim_cancellation_reasons(id)
cancellation_date          date
interview_feedback_1st     text
interview_feedback_2nd     text
interview_feedback_3rd     text

-- Duplikat-Schutz: max. 1 offener Prozess pro Kandidat pro Job
UNIQUE (tenant_id, candidate_id, job_id)
  WHERE current_process_status NOT IN ('Closed','Rejected','Cancelled','Dropped')
```

### `fact_process_events` (operativ)
```sql
process_id              uuid NOT NULL REFERENCES ark.fact_process_core(id)
process_start_date      date
expose_date             date
cv_sent_date            date
ti_date                 date
first_interview_date    date
second_interview_date   date
third_interview_date    date
assessment_date         date
offer_date              date
placement_date          date
closed_date             date
UNIQUE (tenant_id, process_id)
```

### `fact_process_finance` (operativ)
```sql
process_id              uuid NOT NULL REFERENCES ark.fact_process_core(id)
salary_candidate_target int
salary_client_budget    int
salary_match            text CHECK (salary_match IN ('Unknown','Match','Close','Mismatch'))
fee_type                text CHECK (fee_type IN ('Percentage','Fixed'))
fee_percentage          numeric CHECK (fee_percentage BETWEEN 0 AND 100)
fee_amount              int
fee_currency            text NOT NULL DEFAULT 'CHF'
invoice_number          text
invoice_date            date
invoice_status          text CHECK (invoice_status IN ('Draft','Sent','Paid','Overdue'))
payment_date            date
guarantee_period_days   int
guarantee_expiry_date   date
is_guarantee_refund     boolean NOT NULL DEFAULT false
guarantee_refund_amount int
guarantee_refund_date   date
commission_cm_pct       numeric CHECK (commission_cm_pct BETWEEN 0 AND 100)
commission_am_pct       numeric CHECK (commission_am_pct BETWEEN 0 AND 100)
commission_hunter_pct   numeric CHECK (commission_hunter_pct BETWEEN 0 AND 100)
UNIQUE (tenant_id, process_id)
```

### Prozess-Stammdaten (alle Stammdaten – kein tenant_id)
```sql
dim_process_stages          → stage_name · stage_order · win_probability · stage_category ·
                              is_pipeline_stage (true = gültiger Wert für current_process_stage,
                              false = Analytics-Label für Reporting/Power BI)
dim_process_status          → status_name · description
dim_rejection_reasons_candidate → reason_name · reason_category
dim_rejection_reasons_client    → reason_name · reason_category
dim_cancellation_reasons        → reason_name
dim_dropped_reasons             → reason_name
dim_offer_refused_reasons       → reason_name
dim_final_outcome               → outcome_name · is_positive
```

---

## 7. SERVICES – activity_service/

### `fact_history` (operativ)
```sql
-- v1.2: activity_type TEXT-Feld ENTFERNT (Normalisierungs-Verletzung)
-- Name wird via JOIN mit dim_activity_types geholt
activity_type_id        uuid NOT NULL REFERENCES ark.dim_activity_types(id)
activity_date           date NOT NULL
activity_time           time
activity_timestamp      timestamptz NOT NULL DEFAULT now()
activity_duration_minutes int
mitarbeiter_id          uuid REFERENCES ark.dim_mitarbeiter(id)
sparte                  text
team                    text
candidate_id            uuid REFERENCES ark.dim_candidates_profile(id)
account_id              uuid REFERENCES ark.dim_accounts(id)
account_contact_id      uuid REFERENCES ark.dim_account_contacts(id)
job_id                  uuid REFERENCES ark.fact_jobs(id)
process_id              uuid REFERENCES ark.fact_process_core(id)
mandate_id              uuid REFERENCES ark.fact_mandate(id)
location_id             uuid REFERENCES ark.fact_account_locations(id)
is_candidate_related    boolean NOT NULL DEFAULT false
is_account_related      boolean NOT NULL DEFAULT false
is_auto_logged          boolean NOT NULL DEFAULT false
comment                 text
action_items            text

-- Rejection/Reason-System (polymorphe FKs)
-- Je nach Kontext zeigt der Grund auf eine andere Stammdaten-Tabelle
-- Backend-Service bestimmt welches Feld gesetzt wird (Pflichtlogik)
rejection_reason_candidate_id uuid REFERENCES ark.dim_rejection_reasons_candidate(id)
rejection_reason_client_id    uuid REFERENCES ark.dim_rejection_reasons_client(id)
cancellation_reason_id        uuid REFERENCES ark.dim_cancellation_reasons(id)
dropped_reason_id             uuid REFERENCES ark.dim_dropped_reasons(id)
offer_refused_reason_id       uuid REFERENCES ark.dim_offer_refused_reasons(id)
call_direction          text CHECK (call_direction IN ('inbound','outbound'))
recording_url           text
transcript_text         text        -- PII Stufe 2
talk_listen_ratio       numeric
sentiment_score         numeric CHECK (sentiment_score BETWEEN -1 AND 1)
call_context_job_id     uuid REFERENCES ark.fact_jobs(id)
call_context_source     text
email_subject           text
email_body_html         text
email_message_id        text
ai_summary              text
ai_action_items         text
ai_red_flags            text
categorization_status   text
  -- v1.2: 'pending' hinzugefügt für frisch importierte Anrufe/Emails
  CHECK (categorization_status IN ('pending','manual','ai_suggested','confirmed'))
suggested_activity_type text
event_id                uuid REFERENCES ark.fact_event_queue(id)

CREATE INDEX ON ark.fact_history(candidate_id, activity_date DESC);
CREATE INDEX ON ark.fact_history(account_id, activity_date DESC);
CREATE INDEX ON ark.fact_history(process_id, activity_date DESC);
```

### `fact_reminders` (operativ)
```sql
title               text NOT NULL
description         text
mitarbeiter_id      uuid NOT NULL REFERENCES ark.dim_mitarbeiter(id)
due_date            date NOT NULL
due_time            time
priority            text NOT NULL DEFAULT 'Medium'
  CHECK (priority IN ('Low','Medium','High','Urgent'))
reminder_type       text
template_id         uuid REFERENCES ark.dim_reminder_templates(id)
  -- NEU 2026-04-17: FK auf Vorlage, wenn Reminder aus Template erzeugt.
  -- NULL bei manuell angelegten Reminders (User-Freitext ohne Vorlage).
  -- Konsistent mit Pattern dim_notification/email/prompt/document_templates.
recurrence          text NOT NULL DEFAULT 'None'
  CHECK (recurrence IN ('None','Daily','Weekly','Monthly'))
is_done             boolean NOT NULL DEFAULT false
done_at             timestamptz
done_by             uuid REFERENCES ark.dim_mitarbeiter(id)
is_auto_generated   boolean NOT NULL DEFAULT false
is_push_sent        boolean NOT NULL DEFAULT false
escalation_sent_at  timestamptz
  -- NEU 2026-04-17: Gesetzt wenn 48-h-Eskalation via reminder-overdue-escalation.worker
  -- an Head of versendet wurde. Idempotenz-Garantie (Worker skippt wenn NOT NULL).
snooze_until        timestamptz
candidate_id        uuid REFERENCES ark.dim_candidates_profile(id)
account_id          uuid REFERENCES ark.dim_accounts(id)
job_id              uuid REFERENCES ark.fact_jobs(id)
process_id          uuid REFERENCES ark.fact_process_core(id)
mandate_id          uuid REFERENCES ark.fact_mandate(id)
event_id            uuid REFERENCES ark.fact_event_queue(id)
```

### `fact_call_context` (operativ)
```sql
phone_normalized        text NOT NULL
candidate_id            uuid REFERENCES ark.dim_candidates_profile(id)
account_id              uuid REFERENCES ark.dim_accounts(id)
account_contact_id      uuid REFERENCES ark.dim_account_contacts(id)
job_id                  uuid REFERENCES ark.fact_jobs(id)
process_id              uuid REFERENCES ark.fact_process_core(id)
mitarbeiter_id          uuid REFERENCES ark.dim_mitarbeiter(id)
last_matched_at         timestamptz
match_confidence        numeric
UNIQUE (tenant_id, phone_normalized)
```

### `dim_activity_types` (Stammdaten)
```sql
activity_type_name  text NOT NULL UNIQUE
-- v1.2: 11 Kategorien (ersetzt bisherige 5)
activity_category   text CHECK (activity_category IN (
  'Kontaktberührung','Erreicht','Emailverkehr','Messaging',
  'Interviewprozess','Placementprozess','Refresh Kandidatenpflege',
  'Mandatsakquise','Erfolgsbasis','Assessment','System'))
activity_channel    text CHECK (activity_channel IN ('Phone','Email','In-Person','Video','Chat',
  'App','LinkedIn','Whatsapp','Xing','Social Media','CRM','System'))
is_auto_loggable    boolean NOT NULL DEFAULT false
-- v1.2: Beschreibung für Frontend-Anzeige
description         text
```

---

## 8. SERVICES – assessments/

### Assessment-Tabellen (alle operativ)
Alle teilen: `candidate_id uuid FK · assessed_at date · assessor_id uuid FK`

```sql
fact_assessment_disc            -- DISC: red/yellow/green/blue je natural+adapted + 12 Sub-Dims
fact_assessment_driving_forces  -- 12 Antriebskräfte als numeric Scores
fact_assessment_eq              -- 5 EQ-Dimensionen + eq_total
fact_assessment_ikigai          -- 4 Ikigai-Felder + 4 Schnittmengen + ikigai_text
fact_assessment_outmatch        -- profile_id FK + competency_scores_json + total_score
fact_assessment_human_needs_bip -- 6 Human Needs + 12 BIP-Dimensionen

-- NEU: Aufgeteilt aus fact_assessment_relief
fact_assessment_stressoren      -- 8 Stressoren + 5 Antreiber + 3 Coping + stressor_total_score
fact_assessment_resilienz       -- 7 Resilienz-Felder + 4 Langzeitfolgen + burnout_risk_score
fact_assessment_motivation      -- Sinn (3) + Motivation (4) + Energie + Zufriedenheit + narrative

fact_assessment_results         -- Generisch: module + scores jsonb + answers jsonb + behavioral jsonb
fact_assessment_cross_analysis  -- AI-Cross: analysis_text + strengths_json + development_areas_json
fact_assessment_invites         -- token + modules jsonb + status + expires_at + completed_modules jsonb
```

```sql
-- Status-Constraint für invites:
CHECK (status IN ('pending','sent','started','completed','expired'))
```

### ASSESS 5.0 Stammdaten
```sql
dim_outmatch_competencies       → competency_name · name_key · category · description
dim_outmatch_job_profiles       → profile_name · profile_category · description
dim_outmatch_profile_competencies → profile_id + competency_id + sort_order + weight
```

---

## 9. SERVICES – scraper/

```sql
-- fact_scraped_items
account_id          uuid NOT NULL REFERENCES ark.dim_accounts(id)
item_type           text CHECK (item_type IN ('job','person'))
status              text NOT NULL DEFAULT 'pending'
  CHECK (status IN ('pending','reviewed','imported','rejected'))
extracted_data      jsonb NOT NULL
classification      jsonb
similarity_score    numeric
matched_candidate_id uuid REFERENCES ark.dim_candidates_profile(id)
matched_job_id      uuid REFERENCES ark.fact_jobs(id)
reviewed_by         uuid REFERENCES ark.dim_mitarbeiter(id)
reviewed_at         timestamptz

CREATE INDEX ON ark.fact_scraped_items(account_id, status);
CREATE INDEX ON ark.fact_scraped_items(status) WHERE status = 'pending';

-- fact_scrape_snapshots
account_id          uuid NOT NULL REFERENCES ark.dim_accounts(id)
scraped_at          timestamptz NOT NULL
jobs                jsonb
people              jsonb
jobs_count          int
people_count        int
scrape_duration_ms  int

-- fact_scrape_changes
account_id          uuid NOT NULL REFERENCES ark.dim_accounts(id)
snapshot_id         uuid REFERENCES ark.fact_scrape_snapshots(id)
change_type         text CHECK (change_type IN ('new_person','person_left','new_job','job_closed','role_changed'))
person_name         text
old_value           text
new_value           text
is_acknowledged     boolean NOT NULL DEFAULT false
acknowledged_by     uuid REFERENCES ark.dim_mitarbeiter(id)
event_id            uuid REFERENCES ark.fact_event_queue(id)

-- fact_job_platforms
account_id          uuid NOT NULL REFERENCES ark.dim_accounts(id)
platform            text NOT NULL
job_title           text
job_url             text
function_id         uuid REFERENCES ark.dim_functions(id)
first_seen          date NOT NULL
last_seen           date
duration_days       int GENERATED ALWAYS AS (last_seen - first_seen) STORED
is_still_active     boolean NOT NULL DEFAULT true
```

---

## 10. SERVICES – analytics/ (read-only)

### `dim_mitarbeiter` (operativ)
```sql
vorname                 text NOT NULL
nachname                text NOT NULL
mitarbeiter_name        text GENERATED ALWAYS AS (vorname || ' ' || nachname) STORED
email                   text NOT NULL
rolle                   text NOT NULL
rolle_type              text
  -- DEPRECATED: Nutze bridge_mitarbeiter_roles für Multi-Rollen
  -- Bleibt als Fallback für Phase 1 Migration
  CHECK (rolle_type IN ('Candidate_Manager','Account_Manager','Researcher',
    'Admin','Head_of','Backoffice','Assessment_Manager'))
team                    text
standort                text
sparte_id               uuid REFERENCES ark.dim_sparte(id)
target_calls_day        int DEFAULT 20
target_briefings_month  int DEFAULT 8
target_gos_month        int DEFAULT 5
target_placements_year  int
target_revenue_year     int
eintrittsdatum          date
austrittsdatum          date
commission_rate         numeric DEFAULT 0.30 CHECK (commission_rate BETWEEN 0 AND 1)
vorgesetzter_id         uuid REFERENCES ark.dim_mitarbeiter(id)
auth_user_id            uuid REFERENCES ark.dim_crm_users(id)
threecx_extension       text
dashboard_config        jsonb
  -- User-Preferences-Bucket (frei strukturiert pro Feature).
  -- Bekannte Top-Level-Keys (2026-04-17):
  --   "dashboard": Widget-Layout/Pinning
  --   "reminders": Saved-Views + last_active_scope/view + push_defaults
  --     Struktur: { saved_views:[{id,name,filters,view_mode,sort_index,created_at}],
  --                 last_active_scope:"self|team|all",
  --                 last_active_view:"list|calendar",
  --                 last_active_saved_view_key:text,
  --                 push_notification_defaults:{minutes_before:int, channels:text[]} }
  --     Max 10 user-defined saved_views pro User.
email_signature_html    text
status                  text NOT NULL DEFAULT 'Active'
  CHECK (status IN ('Active','Inactive','On Leave'))
UNIQUE (tenant_id, email)
```

### `dim_roles` (Stammdaten – kein tenant_id)
Rollen-Stammdaten für Multi-Rollen-System. Ein Mitarbeiter kann mehrere Rollen haben.
```sql
role_key        text NOT NULL UNIQUE
  CHECK (role_key IN (
    'Admin','Candidate_Manager','Account_Manager','Researcher',
    'Head_of','Backoffice','Assessment_Manager','ReadOnly'
  ))
role_name       text NOT NULL          -- Anzeigename: z.B. 'Research Analyst'
role_category   text NOT NULL
  CHECK (role_category IN ('operations','management','support','system'))
permission_set  jsonb                  -- Basis-Berechtigungen der Rolle
```

### `bridge_mitarbeiter_roles` (operativ – hat tenant_id)
Ein Mitarbeiter kann mehrere Rollen gleichzeitig haben (z.B. Candidate_Manager + Account_Manager).
```sql
mitarbeiter_id  uuid NOT NULL REFERENCES ark.dim_mitarbeiter(id)
role_id         uuid NOT NULL REFERENCES ark.dim_roles(id)
is_primary_role boolean NOT NULL DEFAULT false
granted_at      timestamptz NOT NULL DEFAULT now()
granted_by      uuid REFERENCES ark.dim_crm_users(id)

UNIQUE (tenant_id, mitarbeiter_id, role_id) WHERE is_active = true
```

### `fact_goals` (operativ)
```sql
mitarbeiter_id  uuid NOT NULL REFERENCES ark.dim_mitarbeiter(id)
goal_type       text NOT NULL
  -- v1.2: ClassificationRate hinzugefügt
  CHECK (goal_type IN ('Placements','Revenue','Calls','Briefings','GOs','Idents','ClassificationRate'))
goal_period     text NOT NULL
  CHECK (goal_period IN ('Daily','Weekly','Monthly','Quarterly','Yearly'))
goal_level      text NOT NULL
  CHECK (goal_level IN ('Individual','Team','Sparte','Company'))
target_value    numeric NOT NULL
current_value   numeric NOT NULL DEFAULT 0
achievement_pct numeric GENERATED ALWAYS AS
  (CASE WHEN target_value > 0 THEN current_value / target_value * 100 ELSE 0 END) STORED
period_start    date NOT NULL
period_end      date NOT NULL
target_currency text NOT NULL DEFAULT 'CHF'
is_visible      text NOT NULL DEFAULT 'Team'
  CHECK (is_visible IN ('Self','Team','Company'))
```

### `fact_positions_raster` (operativ)
```sql
account_id              uuid NOT NULL REFERENCES ark.dim_accounts(id)
function_id             uuid NOT NULL REFERENCES ark.dim_functions(id)
cluster_id              uuid REFERENCES ark.dim_cluster(id)
sparte_id               uuid REFERENCES ark.dim_sparte(id)
headcount_target        int
headcount_current       int
open_positions          int GENERATED ALWAYS AS (headcount_target - headcount_current) STORED
salary_range_min        int
salary_range_max        int
fluktuation_risk        text CHECK (fluktuation_risk IN ('Low','High','Critical'))
avg_tenure_years        numeric
last_placement_date     date
last_placement_id       uuid REFERENCES ark.fact_process_core(id)
next_vacancy_est        date
```

### `dim_salary_benchmark` (Stammdaten, mit Historisierung)
```sql
function_id             uuid NOT NULL REFERENCES ark.dim_functions(id)
cluster_id              uuid REFERENCES ark.dim_cluster(id)
region                  text NOT NULL
experience_level        text NOT NULL
  CHECK (experience_level IN ('Junior','Mid','Senior','Lead','Executive'))
salary_p25              int
salary_p50              int
salary_p75              int
salary_p90              int
pensum                  int DEFAULT 100 CHECK (pensum BETWEEN 0 AND 100)
valid_from              date NOT NULL
valid_to                date
is_current              boolean NOT NULL DEFAULT true
data_source             text
data_points_count       int
```

### Views (alle read-only)
```sql
v_candidates_overview       -- Kandidatenliste mit Kerndaten
v_mandate_overview          -- Mandate + berechnete KPIs
v_goals_progress            -- Ziele + achievement_pct
v_open_reminders            -- Offene Reminders mit Namen
v_open_vacancies            -- Offene Vakanzen mit Account/Funktion
v_account_intelligence      -- Account-KPIs: open_jobs, active_mandates etc.
v_candidate_duplicates      -- Duplikat-Kandidaten
v_salary_warnings           -- Prozesse mit Gehaltsmismatch
v_powerbi_kandidaten        -- Power BI: Kandidaten-KPIs
v_powerbi_prozesse          -- Power BI: Pipeline-Statistiken
v_powerbi_umsatz            -- Power BI: Revenue/Fees/Provisionen
v_powerbi_markt             -- Power BI: Scraping/Marktdaten

-- Materialized Views für Power BI (bei Performance-Bedarf):
CREATE MATERIALIZED VIEW ark.mv_powerbi_umsatz AS ...
REFRESH MATERIALIZED VIEW CONCURRENTLY ark.mv_powerbi_umsatz;
```

---

## 11. SERVICES – stammdaten/ (alle Stammdaten – kein tenant_id)

```sql
dim_cluster         → cluster_name · cluster_short_id · parent_cluster_id ·
                      cluster_type · cluster_level · sort_order
dim_functions       → function_name · function_short_id · parent_function_id ·
                      function_level · function_category · sort_order
dim_focus           → focus_name · focus_short_id · parent_focus_id ·
                      focus_category · sort_order
dim_edv             → edv_name · edv_category · edv_explanation · vendor · current_version
dim_education       → education_name · education_level · education_field ·
                      education_institution_type · is_swiss
dim_sector          → sector_name · sector_category · sector_code
dim_sparte          → sparte_name · sparte_short (ING/ARC/GT/REM/PUR) ·
                      sparte_lead_id · sort_order
dim_languages       → language_name · language_code · is_national_language
dim_projects        → project_name · project_type · project_status ·
                      total_cost_chf · bauherrschaft · bauherrschaft_account_id ·
                      location_city · location_kanton · project_start · project_end
```

### `dim_date` (Stammdaten – kein tenant_id)
Standard-Datumsdimension für Power BI Drill-Down und Zeitreihen-Analysen.
Wird einmalig via SQL-Generierungsskript befüllt (2020–2035) und nie geändert.
Nicht im Stammdaten-Export (zu gross: ~5'800 Zeilen), sondern als Migration:
`migrations/001_seed_dim_date.sql` mit `generate_series('2020-01-01', '2035-12-31', '1 day')`
```sql
date_id             int PRIMARY KEY       -- Format YYYYMMDD, z.B. 20260327
full_date           date NOT NULL UNIQUE
year                int NOT NULL
quarter             int NOT NULL CHECK (quarter BETWEEN 1 AND 4)
month               int NOT NULL CHECK (month BETWEEN 1 AND 12)
month_name_de       text NOT NULL         -- z.B. 'März'
month_name_short_de text NOT NULL         -- z.B. 'Mrz'
week_of_year        int NOT NULL
day_of_week         int NOT NULL CHECK (day_of_week BETWEEN 1 AND 7)
day_name_de         text NOT NULL         -- z.B. 'Freitag'
is_weekend          boolean NOT NULL
is_swiss_holiday    boolean NOT NULL DEFAULT false
holiday_name_de     text
fiscal_year         int NOT NULL          -- Falls Geschäftsjahr ≠ Kalenderjahr
fiscal_quarter      int NOT NULL
fiscal_month        int NOT NULL
year_month          text NOT NULL         -- z.B. '2026-03' für einfaches Grouping
year_quarter        text NOT NULL         -- z.B. '2026-Q1'

-- Kein id uuid – date_id INT ist der PK
-- Kein is_active, created_at etc. – reines Read-Only Lookup
CREATE INDEX ON ark.dim_date(full_date);
CREATE INDEX ON ark.dim_date(year, month);
CREATE INDEX ON ark.dim_date(year_quarter);
```

---

## 12. AI / RAG / MATCHING

### `fact_embeddings` (operativ, mit Historisierung)
```sql
entity_type             text NOT NULL
entity_id               uuid NOT NULL
chunk_id                uuid NOT NULL REFERENCES ark.dim_embedding_chunks(id)
embedding               vector(1536) NOT NULL        -- pgvector
embedding_provider      text NOT NULL
  CHECK (embedding_provider IN ('openai','anthropic','local'))
embedding_dimension     int NOT NULL DEFAULT 1536
model_version           text NOT NULL
content_hash            text NOT NULL                -- SHA-256
source_document_id      uuid REFERENCES ark.fact_documents(id)
source_document_version int
chunking_strategy       text CHECK (chunking_strategy IN ('fixed','semantic','paragraph'))
chunk_overlap           int
redaction_status        text NOT NULL DEFAULT 'none'
  CHECK (redaction_status IN ('none','partially_redacted','redacted'))
language_confidence     numeric CHECK (language_confidence BETWEEN 0 AND 1)
is_current              boolean NOT NULL DEFAULT true

UNIQUE (tenant_id, entity_type, entity_id, chunk_id, model_version)
  WHERE is_current = true
CREATE INDEX ON ark.fact_embeddings USING ivfflat (embedding vector_cosine_ops);
CREATE INDEX ON ark.fact_embeddings(entity_type, entity_id, is_current);
```

### `dim_embedding_chunks` (operativ)
```sql
entity_type         text NOT NULL
entity_id           uuid NOT NULL
chunk_text          text NOT NULL
chunk_index         int NOT NULL
token_count         int
source_field        text
language            text CHECK (language IN ('de','en','fr','it'))
is_current          boolean NOT NULL DEFAULT true
```

### `fact_ai_classifications` (operativ, mit Historisierung)
```sql
entity_type             text NOT NULL
entity_id               uuid NOT NULL
model_type              text NOT NULL
  CHECK (model_type IN ('generalist_specialist','seniority',
    'culture_fit','function_match','skill_level'))
classification_result   text NOT NULL
confidence_score        numeric CHECK (confidence_score BETWEEN 0 AND 1)
reasoning_json          jsonb
input_snapshot_hash     text
prompt_template_id      uuid REFERENCES ark.dim_prompt_templates(id)
prompt_version          int
inference_provider      text
temperature             numeric
model_version           text NOT NULL
classified_at           timestamptz NOT NULL DEFAULT now()
is_human_confirmed      boolean NOT NULL DEFAULT false
confirmed_by            uuid REFERENCES ark.dim_mitarbeiter(id)
confirmed_at            timestamptz
review_status           text NOT NULL DEFAULT 'pending'
  CHECK (review_status IN ('pending','confirmed','overridden'))
supersedes_id           uuid REFERENCES ark.fact_ai_classifications(id)
valid_from              timestamptz NOT NULL DEFAULT now()
valid_to                timestamptz
is_current              boolean NOT NULL DEFAULT true
```

### `fact_ai_suggestions` (operativ)
```sql
entity_type             text NOT NULL
entity_id               uuid NOT NULL
suggestion_type         text NOT NULL
  CHECK (suggestion_type IN ('add_function','add_skill','update_stage',
    'match_candidate','update_field','add_cluster','merge_candidate'))
field_name              text
suggested_value_json    jsonb NOT NULL
current_value_json      jsonb
accepted_value_json     jsonb
confidence              numeric CHECK (confidence BETWEEN 0 AND 1)
reasoning               text
priority_score          numeric CHECK (priority_score BETWEEN 0 AND 1)
review_queue            text
  CHECK (review_queue IN ('cv_parse','stage','skill','match','general'))
source_event_id         uuid REFERENCES ark.fact_event_queue(id)
status                  text NOT NULL DEFAULT 'pending'
  CHECK (status IN ('pending','accepted','rejected','expired','superseded'))
expires_at              timestamptz
applied_event_id        uuid REFERENCES ark.fact_event_queue(id)
rejection_reason        text
reviewed_by             uuid REFERENCES ark.dim_mitarbeiter(id)
reviewed_at             timestamptz

CREATE INDEX ON ark.fact_ai_suggestions(status, expires_at) WHERE status = 'pending';
```

### `fact_match_scores` (operativ, mit Historisierung)
```sql
candidate_id        uuid NOT NULL REFERENCES ark.dim_candidates_profile(id)
job_id              uuid NOT NULL REFERENCES ark.fact_jobs(id)
score_total         numeric NOT NULL CHECK (score_total BETWEEN 0 AND 100)
score_sparte        numeric
score_function      numeric
score_salary        numeric
score_location      numeric
score_skills        numeric     -- v1.2: Immer NULL (Skills deprecated, via Focus abgebildet)
score_availability  numeric
score_experience    numeric
match_breakdown_json jsonb
model_version       text NOT NULL
calculated_at       timestamptz NOT NULL DEFAULT now()
is_current          boolean NOT NULL DEFAULT true

CREATE INDEX ON ark.fact_match_scores(candidate_id, is_current);
CREATE INDEX ON ark.fact_match_scores(job_id, score_total DESC);
```

---

## 13. SKILL ECONOMY — DEPRECATED v1.2

> **DEPRECATED:** Das gesamte Skill Economy Modul ist seit v1.2 deprecated.
> Skills werden ausschliesslich über dim_focus (fachliche Spezialisierungen) abgebildet.
> Die Tabellen bleiben im Schema bestehen, aber kein neuer Code darf sie referenzieren.
> Entfernung in einer zukünftigen Migration wenn keine Abhängigkeiten mehr bestehen.

Betroffene Tabellen (10):
- `dim_skills_master` — 100k generische Skills
- `dim_skill_aliases` — Skill-Aliase
- `bridge_skill_related_skill` — Verwandte Skills
- `bridge_function_skill` — Function ↔ Skill Zuordnung
- `bridge_candidate_skill` — Kandidat ↔ Skill Zuordnung (in Section 2)
- `bridge_job_skill` — Job ↔ Skill Zuordnung (in Section 4)
- `fact_skill_market_value` — Skill-Marktwert
- `fact_skill_salary_data` — Skill-Gehaltsdaten
- `fact_skill_demand_index` — Skill-Nachfrage-Index
- `fact_function_skill_premium` — Skill-Aufschlag pro Function

---

## 14. DOKUMENTE

### `fact_documents` (operativ)
```sql
entity_type         text NOT NULL
  CHECK (entity_type IN ('candidate','account','mandate','job'))
entity_id           uuid NOT NULL
document_label      text NOT NULL
  -- v1.2: 'Assessment-Dokument' und 'Mandatsofferte unterschrieben' hinzugefügt
  CHECK (document_label IN ('Original CV','ARK CV','Abstract','Expose',
    'Arbeitszeugnis','Diplom','Zertifikat','Mandat Report',
    'Assessment-Dokument','Mandatsofferte unterschrieben','Sonstiges'))
file_name           text NOT NULL
mime_type           text NOT NULL
file_type           text NOT NULL
file_size_kb        int
file_hash           text                  -- SHA-256 Integrität
storage_bucket      text NOT NULL
storage_path        text NOT NULL
version             int NOT NULL DEFAULT 1
is_latest           boolean NOT NULL DEFAULT true
sort_order          int NOT NULL DEFAULT 0
is_anonymized       boolean NOT NULL DEFAULT false
anonymized_from     uuid REFERENCES ark.fact_documents(id)
is_ark_generated    boolean NOT NULL DEFAULT false
is_rotated          boolean NOT NULL DEFAULT false
rotation_degrees    int DEFAULT 0
uploaded_by         uuid REFERENCES ark.dim_mitarbeiter(id)
upload_date         date NOT NULL DEFAULT CURRENT_DATE
ocr_status          text NOT NULL DEFAULT 'none'
  CHECK (ocr_status IN ('none','pending','done','failed'))
ocr_text            text
parsing_status      text NOT NULL DEFAULT 'none'
  CHECK (parsing_status IN ('none','pending','done','failed'))
parsed_data_json    jsonb
retention_class     text NOT NULL DEFAULT 'standard'
  CHECK (retention_class IN ('standard','sensitive','legal_hold','anonymized'))
retention_until     date
access_count        int NOT NULL DEFAULT 0
last_accessed_at    timestamptz
embedding_status    text NOT NULL DEFAULT 'none'
  CHECK (embedding_status IN ('none','pending','done','failed'))
-- NEU 2026-04-17 (Dok-Generator):
generated_from_template_id  uuid REFERENCES ark.dim_document_templates(id)
generated_by_doc_gen        boolean DEFAULT false
params_jsonb                jsonb
entity_refs_jsonb           jsonb  -- [{"type":"mandate","id":"uuid"},{"type":"candidate","id":"uuid"}]
delivery_mode               text
  CHECK (delivery_mode IN ('save_only','save_and_email','save_and_download'))
email_recipient_contact_id  uuid REFERENCES ark.dim_account_contacts(id)
```

### 14.1 `document_label` Enum-Erweiterung (2026-04-17)

Neue Labels (nebst bestehenden 'Original CV','ARK CV','Abstract','Expose',...):
- `'Mandat-Offerte'` (Alias zu 'Mandatsofferte unterschrieben' für Dok-Gen-Ausgaben)
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

### 14.2 `dim_document_templates` (Stammdaten, neu 2026-04-17)

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

### 14.3 `fact_assessment_order.status` ENUM-Fix (v0.3 Sync, 2026-04-17)

```sql
-- v0.3: 'invoiced' entfernt (Billing-State lebt auf fact_assessment_billing.status)
fact_assessment_order
  status  ENUM('offered','ordered','partially_used','fully_used','cancelled')
```

Migration-Pfad: `UPDATE fact_assessment_order SET status='fully_used' WHERE status='invoiced';` bei Schema-Update.

---

## 15. INTEGRATIONEN / KOMMUNIKATION

```sql
-- v1.2: dim_email_templates erweitert
dim_email_templates         → template_name · subject · body_html · template_category ·
                              activity_type · has_attachment · placeholders jsonb · language ·
                              template_key text UNIQUE ·          -- z.B. 'go_muendliche_versand'
                              linked_activity_type text ·         -- Wenn gesetzt: Activity-Type auto-gesetzt
                              linked_automation_key text ·        -- Wenn gesetzt: Backend-Automation triggern
                              is_system_template boolean DEFAULT true · -- System-Templates nicht löschbar
                              sort_order int DEFAULT 0
dim_prompt_templates        → template_name · system_prompt · user_prompt_template ·
                              activity_type · output_field · provider · model · version
dim_notification_templates  → template_name · trigger_event · channel · title_template ·
                              body_template · priority · is_confetti · deep_link_template
dim_integration_tokens      → provider · account_reference · scopes text[] ·
                              expires_at · last_refresh_at · token_fingerprint ·
                              secret_ref · is_valid · revoked_at · revocation_reason
                              -- KEIN access_token, KEIN refresh_token im Klartext
```

### `dim_webhooks` (operativ)
Registrierte Webhook-Endpunkte die bei bestimmten Events benachrichtigt werden.
Basis für `action_type = 'trigger_webhook'` in `dim_automation_rules`.
```sql
webhook_name        text NOT NULL
target_url          text NOT NULL
secret_ref          text NOT NULL         -- HMAC-Secret im Secret Store, nie im Klartext
event_types         text[] NOT NULL       -- Welche Events triggern diesen Webhook
is_active           boolean NOT NULL DEFAULT true
max_retries         int NOT NULL DEFAULT 3
timeout_seconds     int NOT NULL DEFAULT 30
created_by          uuid REFERENCES ark.dim_crm_users(id)

UNIQUE (tenant_id, webhook_name)
```

### `fact_webhook_logs` (operativ – nur INSERT)
Unveränderliches Log jedes Webhook-Versuchs. Basis für Retry-Logik und Debugging.
```sql
webhook_id          uuid NOT NULL REFERENCES ark.dim_webhooks(id)
event_id            uuid REFERENCES ark.fact_event_queue(id)
event_type          text NOT NULL
payload_hash        text NOT NULL         -- SHA-256 des gesendeten Payloads
target_url          text NOT NULL
attempt_number      int NOT NULL DEFAULT 1
http_status         int                   -- z.B. 200, 404, 500
response_body       text
duration_ms         int
sent_at             timestamptz NOT NULL DEFAULT now()
succeeded           boolean NOT NULL DEFAULT false
failure_reason      text
next_retry_at       timestamptz
is_dead_lettered    boolean NOT NULL DEFAULT false

-- Nur INSERT erlaubt:
-- REVOKE UPDATE, DELETE ON ark.fact_webhook_logs FROM app_user;

CREATE INDEX ON ark.fact_webhook_logs(webhook_id, succeeded);
CREATE INDEX ON ark.fact_webhook_logs(event_id);
CREATE INDEX ON ark.fact_webhook_logs(next_retry_at) WHERE NOT succeeded AND NOT is_dead_lettered;
```

---

## 15b. NEUE TABELLEN v1.2

### `dim_tenant_features` (operativ – hat tenant_id)
Tenant-spezifische Feature Flags. Ermöglicht Features pro Kunde einzeln zu aktivieren/deaktivieren.
```sql
feature_key         text NOT NULL
is_enabled          boolean NOT NULL DEFAULT false
enabled_at          timestamptz
enabled_by          uuid REFERENCES ark.dim_crm_users(id)
config_json         jsonb           -- Feature-spezifische Konfiguration

UNIQUE (tenant_id, feature_key)
```

### `dim_automation_settings` (operativ – hat tenant_id)
Konfigurierbare Fristen und Schwellwerte für Automationen. Pro Tenant individuell einstellbar.
```sql
setting_key         text NOT NULL   -- z.B. 'ghosting_frist_tage', 'stale_prozess_tage'
setting_value       text NOT NULL   -- Wert als String (wird im Backend geparst)
setting_type        text NOT NULL DEFAULT 'int'
  CHECK (setting_type IN ('int','boolean','string','json'))
description         text
default_value       text            -- Fallback wenn nicht gesetzt

UNIQUE (tenant_id, setting_key)
```

Vordefinierte Settings:
- `ghosting_frist_tage` = 14 (Tage nach Mündliche GOs ohne Reaktion → GO Ghosting)
- `stale_prozess_tage` = 14 (Tage in gleicher Stage → Prozess als Stale markieren)
- `inactive_alter` = 60 (Alter ab dem Kandidat automatisch Inactive wird)
- `datenschutz_reset_tage` = 365 (Tage nach Datenschutz-Stage → automatisch Refresh)
- `briefing_reminder_tage` = 7 (Tage nach Erstellung ohne Briefing → Reminder)
- `klassifizierung_eskalation_1h` = 24 (Stunden bis Stufe 1 Eskalation)
- `klassifizierung_eskalation_2h` = 48 (Stunden bis Stufe 2 Eskalation an Head_of)

### `dim_jobbasket_rejection_types` (Stammdaten – kein tenant_id)
Vordefinierte Ablehnungsgründe für Preleads, unterteilt nach Verursacher.
```sql
rejection_name      text NOT NULL UNIQUE
rejection_category  text NOT NULL
  CHECK (rejection_category IN ('candidate','cm','am'))
description         text
sort_order          int NOT NULL DEFAULT 0
```

### `fact_email_drafts` (operativ – hat tenant_id)
Email-Entwürfe die im CRM gespeichert werden.
```sql
mitarbeiter_id      uuid NOT NULL REFERENCES ark.dim_mitarbeiter(id)
candidate_id        uuid REFERENCES ark.dim_candidates_profile(id)
account_id          uuid REFERENCES ark.dim_accounts(id)
account_contact_id  uuid REFERENCES ark.dim_account_contacts(id)
to_email            text
cc_emails           text[]
bcc_emails          text[]
subject             text
body_html           text
template_id         uuid REFERENCES ark.dim_email_templates(id)
attachments_json    jsonb           -- [{document_id, file_name, mime_type}]
is_sent             boolean NOT NULL DEFAULT false
sent_at             timestamptz
```

### `v_account_duplicates` (View)
Account-Duplikat-Erkennung. Analog zu v_candidate_duplicates.
```sql
CREATE VIEW ark.v_account_duplicates AS
-- Fuzzy-Matching auf:
-- 1. domain_normalized (gleiche Website = wahrscheinlich gleicher Account)
-- 2. Firmennamen-Ähnlichkeit (z.B. 'Brun AG' vs. 'Brun Bauunternehmung AG')
-- 3. handelsregister_uid (identisch = definitiv gleicher Account)
-- Spalten: account_id_1, account_id_2, match_type, similarity_score
```

---

## 16. SHARED / AUTH / SYSTEM

### `dim_crm_users` (operativ)
```sql
username            text NOT NULL
password_hash       text NOT NULL
password_salt       text NOT NULL  -- DEPRECATED: argon2id generiert eigenen Salt im Hash-String
rolle               text NOT NULL
mitarbeiter_id      uuid REFERENCES ark.dim_mitarbeiter(id)
webauthn_credential jsonb
push_subscription   jsonb
last_login          timestamptz
failed_login_count  int NOT NULL DEFAULT 0
is_locked           boolean NOT NULL DEFAULT false
locked_until        timestamptz
UNIQUE (tenant_id, username)
```

### `app_users` (operativ)
```sql
email               text NOT NULL
password_hash       text NOT NULL
candidate_id        uuid REFERENCES ark.dim_candidates_profile(id)
display_name        text
last_login          timestamptz
push_token          text
UNIQUE (tenant_id, email)
```

### `fact_audit_log` (operativ – nur INSERT)
```sql
user_id             uuid REFERENCES ark.dim_crm_users(id)
session_id          text
request_id          text
action_type         text NOT NULL
entity_type         text
entity_id           uuid
field_changed       text
old_value           text
new_value           text
ip_address          text
user_agent          text
duration_ms         int
is_suspicious       boolean NOT NULL DEFAULT false
suspicious_reason   text
logged_at           timestamptz NOT NULL DEFAULT now()

-- Nur INSERT erlaubt:
REVOKE UPDATE, DELETE ON ark.fact_audit_log FROM app_user;
```

### `tenants` (System-Tabelle – kein tenant_id)
```sql
id                  uuid PK
tenant_name         text NOT NULL UNIQUE
tenant_slug         text NOT NULL UNIQUE
is_active           boolean NOT NULL DEFAULT true
created_at          timestamptz NOT NULL DEFAULT now()
```

### `dim_pii_classification` (System – kein tenant_id)
```sql
table_name          text NOT NULL
field_name          text NOT NULL
pii_level           text NOT NULL
  CHECK (pii_level IN ('direct_identifying','highly_sensitive','sensitive_business'))
retention_days      int
requires_encryption boolean NOT NULL DEFAULT false
requires_masking    boolean NOT NULL DEFAULT false
gdpr_basis          text CHECK (gdpr_basis IN ('consent','legitimate_interest','contract'))
UNIQUE (table_name, field_name)
```

### `dim_ai_write_policies` (System – kein tenant_id)
**Neu – Perplexity Empfehlung: AI Governance Layer**

Zentrale Tabelle die per Entity-Typ und Feld definiert was AI tun darf.
Basis für Audits und regulatorische Anforderungen.

```sql
entity_type         text NOT NULL
  CHECK (entity_type IN ('candidate','account','job','process','mandate','history'))
field_name          text NOT NULL           -- '*' = ganzes Entity, sonst spezifisches Feld
policy_type         text NOT NULL
  CHECK (policy_type IN (
    'suggest_only',        -- AI darf nur in fact_ai_suggestions schreiben
    'auto_after_review',   -- AI darf nach Human-Review automatisch schreiben
    'auto_allowed',        -- AI darf direkt schreiben (nur für dedizierte AI-Felder)
    'forbidden'            -- AI darf dieses Feld nie anfassen
  ))
review_required     boolean NOT NULL DEFAULT true
reviewer_role       text                    -- Welche Rolle muss reviewen (Candidate_Manager etc.)
review_timeout_hours int                    -- Nach X Stunden verfällt der Vorschlag
rationale           text                    -- Warum diese Policy?
effective_from      date NOT NULL DEFAULT CURRENT_DATE
effective_to        date                    -- NULL = dauerhaft gültig
created_by          text NOT NULL DEFAULT 'system'

UNIQUE (entity_type, field_name)
```

**Vordefinierte Policies:**

| entity_type | field_name | policy_type | Begründung |
|---|---|---|---|
| `candidate` | `candidate_stage` | `suggest_only` | Stage ist kritisch – immer Mensch |
| `candidate` | `is_do_not_contact` | `forbidden` | AI darf das nie setzen |
| `candidate` | `*` | `suggest_only` | Default: alle Kandidaten-Felder nur Vorschlag |
| `history` | `ai_summary` | `auto_allowed` | Dediziertes AI-Feld |
| `history` | `ai_action_items` | `auto_allowed` | Dediziertes AI-Feld |
| `history` | `ai_red_flags` | `auto_allowed` | Dediziertes AI-Feld |
| `process` | `current_process_stage` | `suggest_only` | Stage-Änderung immer durch Mensch |
| `process` | `*` | `suggest_only` | Default: alle Prozess-Felder nur Vorschlag |

---

## 17. DATENQUALITÄT

### `dim_quality_rule_types` (Stammdaten)
```sql
rule_name           text NOT NULL UNIQUE
rule_category       text NOT NULL
  CHECK (rule_category IN ('completeness','validity','uniqueness','consistency'))
entity_type         text
affected_field      text
auto_fixable        boolean NOT NULL DEFAULT false
fix_suggestion      text
```

### `fact_data_quality_issues` (operativ)
```sql
entity_type         text NOT NULL
entity_id           uuid NOT NULL
rule_type_id        uuid NOT NULL REFERENCES ark.dim_quality_rule_types(id)
severity            text NOT NULL
  CHECK (severity IN ('info','warning','error','critical'))
issue_description   text
field_name          text
current_value       text
expected_format     text
is_resolved         boolean NOT NULL DEFAULT false
resolved_at         timestamptz
resolved_by         uuid REFERENCES ark.dim_mitarbeiter(id)
auto_detected       boolean NOT NULL DEFAULT true
detected_at         timestamptz NOT NULL DEFAULT now()

CREATE INDEX ON ark.fact_data_quality_issues(entity_type, entity_id, is_resolved);
CREATE INDEX ON ark.fact_data_quality_issues(severity) WHERE NOT is_resolved;
```

---

## 18. MERGE-LOGIK

### `fact_entity_merges` (operativ)
```sql
entity_type         text NOT NULL CHECK (entity_type IN ('candidate','account'))
source_entity_id    uuid NOT NULL
target_entity_id    uuid NOT NULL
merge_reason        text
merge_type          text NOT NULL
  CHECK (merge_type IN ('manual','auto_detected','ai_suggested'))
merged_fields_json  jsonb
merged_by           uuid NOT NULL REFERENCES ark.dim_crm_users(id)
merged_at           timestamptz NOT NULL DEFAULT now()
is_reversible       boolean NOT NULL DEFAULT true
reversed_at         timestamptz
reversed_by         uuid REFERENCES ark.dim_crm_users(id)

CHECK (source_entity_id != target_entity_id)
```

---

## 19. PHASE 2 SCAFFOLD (leer, Schema definiert)

Alle Phase-2-Tabellen existieren mit vollständigem Schema aber ohne Daten.
Alle operativen haben tenant_id + Pflichtfelder. Alle Stammdaten ohne tenant_id.

```
MESSAGING:          fact_messages · dim_message_channels · dim_message_templates · fact_message_campaigns
ZEITERFASSUNG:      fact_time_entries · fact_absences · dim_absence_types · fact_time_budgets
PERFORMANCE:        fact_performance_reviews · fact_360_feedback · dim_feedback_questions · dim_feedback_cycles
ENTWICKLUNG:        fact_development_plans · fact_learning_progress · dim_learning_modules ·
                    dim_skill_certifications · fact_competency_ratings · dim_competency_framework
LOHNLAUF:           fact_payroll · dim_salary_grades · fact_invoices · fact_expenses · dim_cost_centers
AUSSCHREIBUNGEN:    fact_job_postings · fact_posting_costs · dim_posting_platforms · fact_posting_stats
PUBLISHING:         fact_publications · dim_publishing_channels · fact_publication_stats · dim_content_types
MARKT/ORGANIGRAM:   fact_organigram_changes · fact_market_snapshots · fact_competitor_tracking
```

### Buchhaltung Phase 2 – 3 kritische Scaffold-Tabellen

**WICHTIG:** Diese drei Tabellen müssen das ERSTE sein was in Phase 2 gebaut wird –
noch vor der ersten Rechnung. Der Periodenabschluss-Lock kann nicht nachgerüstet werden
wenn bereits Buchungsdaten existieren.

#### `dim_chart_of_accounts` (Stammdaten – kein tenant_id)
Kontenplan nach Schweizer KMU-Standard.
```sql
account_number      text NOT NULL UNIQUE  -- z.B. '1000', '3000', '4000'
account_name        text NOT NULL
account_type        text NOT NULL
  CHECK (account_type IN ('Aktiven','Passiven','Aufwand','Ertrag','Eigenkapital'))
account_category    text                  -- z.B. 'Umlaufvermögen', 'Personalaufwand'
parent_account_id   uuid REFERENCES ark.dim_chart_of_accounts(id)
account_level       int NOT NULL DEFAULT 1
is_posting_account  boolean NOT NULL DEFAULT true  -- Kann man darauf buchen?
vat_relevant        boolean NOT NULL DEFAULT false
sort_order          int
```

#### `fact_accounting_periods` (operativ)
Buchhaltungsperioden mit Lock-Mechanismus. Das Herzstück der Buchhaltungs-Integrität.
```sql
period_name         text NOT NULL         -- z.B. '2026-03', '2026-Q1', '2026'
period_type         text NOT NULL
  CHECK (period_type IN ('month','quarter','year'))
start_date          date NOT NULL
end_date            date NOT NULL
is_open             boolean NOT NULL DEFAULT true
locked_at           timestamptz           -- Wenn gesetzt: KEINE Buchungen mehr möglich
locked_by           uuid REFERENCES ark.dim_crm_users(id)
lock_reason         text
notes               text

UNIQUE (tenant_id, period_name, period_type)
CHECK (end_date > start_date)

-- DB-seitiger Schutz: Trigger verhindert Buchungen in gesperrte Perioden
-- CREATE TRIGGER check_period_lock BEFORE INSERT ON ark.fact_journal_entries ...
```

#### `fact_journal_entries` (operativ – nur INSERT, niemals UPDATE/DELETE)
Doppelte Buchführung. Jede Buchung besteht aus Soll + Haben (immer paarweise).
```sql
journal_id          uuid NOT NULL         -- Buchungsnummer (Soll + Haben teilen sich diese)
entry_type          text NOT NULL
  CHECK (entry_type IN ('debit','credit'))  -- Soll / Haben
account_id          uuid NOT NULL REFERENCES ark.dim_chart_of_accounts(id)
period_id           uuid NOT NULL REFERENCES ark.fact_accounting_periods(id)
amount_chf          numeric(15,2) NOT NULL CHECK (amount_chf > 0)
currency            text NOT NULL DEFAULT 'CHF'
exchange_rate       numeric DEFAULT 1.0
booking_date        date NOT NULL
value_date          date
description         text NOT NULL
reference_type      text                  -- 'invoice','expense','payroll','manual'
reference_id        uuid                  -- FK zur referenzierten Entität
vat_code            text                  -- z.B. 'CHE-8.1', 'CHE-2.6', 'CHE-0'
vat_amount_chf      numeric(15,2)
is_reversal         boolean NOT NULL DEFAULT false
reversal_of         uuid REFERENCES ark.fact_journal_entries(id)
created_by          uuid NOT NULL REFERENCES ark.dim_crm_users(id)
created_at          timestamptz NOT NULL DEFAULT now()

-- NIEMALS UPDATE oder DELETE – nur Stornobuchungen (is_reversal = true)
-- REVOKE UPDATE, DELETE ON ark.fact_journal_entries FROM app_user;
-- Soll = Haben wird im Backend validiert, nicht per DB-Constraint (zu komplex)

CREATE INDEX ON ark.fact_journal_entries(journal_id);
CREATE INDEX ON ark.fact_journal_entries(account_id, booking_date);
CREATE INDEX ON ark.fact_journal_entries(period_id);
CREATE INDEX ON ark.fact_journal_entries(reference_type, reference_id);
```

---

## Gesamtübersicht

| Bereich | Tabellen | Typ |
|---|---|---|
| Event-Rückgrat | 5 | Operativ |
| Core (5 Module) | 44 | Operativ (inkl. fact_jobbasket mit Prelead) |
| Services | 28 | Operativ + Stammdaten |
| Stammdaten | 11 | Global (inkl. dim_date, dim_roles) |
| AI / RAG / Matching | 5 | Operativ |
| Skill Economy | 10 | **DEPRECATED v1.2** |
| Dokumente | 1 | Operativ |
| Integrationen | 7 | Operativ (inkl. dim_webhooks + fact_email_drafts) |
| Neue Tabellen v1.2 | 5 | Operativ + Stammdaten (dim_tenant_features, dim_automation_settings, dim_jobbasket_rejection_types, fact_email_drafts, v_account_duplicates) |
| Shared / Auth / Governance | 7 | Operativ + System |
| Datenqualität | 2 | Operativ + Stammdaten |
| Merge | 1 | Operativ |
| Phase 2 Scaffold | 35 | Leer (inkl. 3 Buchhaltungs-Tabellen) |
| **Total** | **~161** | (davon 10 deprecated) |

---


---

## 20. MIGRATION 004: AUTH TOKEN ROTATION

### `fact_refresh_tokens` (operativ)
```sql
user_id             uuid NOT NULL REFERENCES ark.dim_crm_users(id)
token_hash          text NOT NULL UNIQUE
family_id           uuid NOT NULL           -- Family-Based Reuse Detection
session_id          text NOT NULL
is_revoked          boolean NOT NULL DEFAULT false
expires_at          timestamptz NOT NULL

CREATE INDEX ON ark.fact_refresh_tokens(user_id, tenant_id) WHERE NOT is_revoked;
CREATE INDEX ON ark.fact_refresh_tokens(family_id) WHERE NOT is_revoked;
CREATE INDEX ON ark.fact_refresh_tokens(expires_at) WHERE NOT is_revoked;
-- Cleanup: DELETE FROM WHERE expires_at < now() (periodisch)
```

### `fact_token_revocations` (System — JTI Blacklist)
```sql
jti                 text NOT NULL UNIQUE
expires_at          timestamptz NOT NULL
created_at          timestamptz NOT NULL DEFAULT now()

CREATE INDEX ON ark.fact_token_revocations(jti, expires_at);
-- Cleanup: DELETE FROM WHERE expires_at < now() (periodisch)
```

---

## 21. MIGRATION 005: UI ADDENDUM ÄNDERUNGEN

### Briefing-Versionierung
```sql
-- UNIQUE Constraint auf fact_candidate_briefing ENTFERNT:
-- ALTER TABLE ark.fact_candidate_briefing 
--   DROP CONSTRAINT fact_candidate_briefing_tenant_id_candidate_id_key;
-- Unbegrenzt viele Briefings pro Kandidat. Aktuellstes: ORDER BY briefing_date DESC LIMIT 1
```

### Rating-Skala 1-10
```sql
-- Rating auf bridge_candidate_functions/focus/edv von 1-5 auf 1-10 erweitert:
-- CHECK (rating BETWEEN 1 AND 10)
-- Betrifft: bridge_candidate_functions, bridge_candidate_focus, bridge_candidate_edv
```

### `bridge_briefing_projects` (operativ — Projekt-Verknüpfung im Briefing)
```sql
briefing_id         uuid NOT NULL REFERENCES ark.fact_candidate_briefing(id)
project_id          uuid NOT NULL REFERENCES ark.dim_projects(id)
candidate_comment   text            -- Was der Kandidat über das Projekt gesagt hat
insider_info        text            -- Klatsch, Tratsch, Insider-Infos
project_rating      int CHECK (project_rating BETWEEN 1 AND 10)
UNIQUE (tenant_id, briefing_id, project_id)
```

### `dim_honorar_settings` (operativ — konfigurierbar pro Tenant)
```sql
setting_type            text NOT NULL
  CHECK (setting_type IN ('best_effort','mandate','custom'))
salary_threshold_chf    int NOT NULL        -- z.B. 90000, 110000, 130000
fee_percentage          numeric NOT NULL     -- z.B. 21, 23, 25, 27
refund_month_1_pct      numeric DEFAULT 50   -- Austritt Monat 1: 50%
refund_month_2_pct      numeric DEFAULT 25   -- Austritt Monat 2: 25%
refund_month_3_pct      numeric DEFAULT 10   -- Austritt Monat 3: 10%
protection_period_months int DEFAULT 12      -- 12-Monats-Schutzfrist
extended_period_months  int DEFAULT 16       -- Verlängerung bei Nichtmeldung
vat_applicable          boolean NOT NULL DEFAULT true
valid_from              date NOT NULL DEFAULT CURRENT_DATE
valid_to                date
UNIQUE (tenant_id, setting_type, salary_threshold_chf)
```

### `fact_linkedin_activities` (operativ — LinkedIn Social Tracking)
```sql
candidate_id        uuid NOT NULL REFERENCES ark.dim_candidates_profile(id)
activity_type       text NOT NULL
  CHECK (activity_type IN ('like','comment','share','post','group_join','connection'))
content_url         text
content_text        text
content_author      text
target_company      text            -- Firma auf die sich die Aktivität bezieht
detected_at         timestamptz NOT NULL DEFAULT now()
relevance_score     numeric CHECK (relevance_score BETWEEN 0 AND 1)
is_wechselbereitschaft_signal boolean NOT NULL DEFAULT false
notes               text

CREATE INDEX ON ark.fact_linkedin_activities(candidate_id, detected_at DESC);
```

---

## 22. MIGRATION 007: v1.2 ÄNDERUNGEN

### Fehlende Indizes (Performance-kritisch)
```sql
-- Kandidaten nach Manager filtern (Dashboard "Meine Kandidaten")
CREATE INDEX ON ark.dim_candidates_profile(candidate_manager_id, tenant_id)
  WHERE is_active = true AND is_current = true;

-- Prozesse nach Stage für Kanban-Board
CREATE INDEX ON ark.fact_process_core(current_process_stage, tenant_id)
  WHERE current_process_status = 'Open';

-- Mandate Research für Longlist-Kanban
CREATE INDEX ON ark.fact_mandate_research(mandate_id, contact_status)
  WHERE is_active = true;

-- Jobbasket für Job-Detail-View
CREATE INDEX ON ark.fact_jobbasket(job_id, tenant_id)
  WHERE is_active = true AND is_in_job_basket = true;

-- Full-text Search Index auf Kandidat
CREATE INDEX ON ark.dim_candidates_profile
  USING gin(to_tsvector('german', coalesce(first_name,'') || ' ' || coalesce(last_name,'') || ' ' || coalesce(wohnort,'')));
```

### Schema-Änderungen (Zusammenfassung)
```sql
-- Alle v1.2 Änderungen auf bestehende Tabellen:
-- dim_candidates_profile: +wechselmotivation, -availability_date
-- dim_accounts: +purchase_potential, +agb_confirmed_at, +agb_version
-- fact_jobbasket: +is_prelead (ersetzt is_lead), +prelead_date, +go_rejected_by, +rejection_type_id, -is_lead, -lead_date
-- dim_activity_types: activity_category CHECK auf 11 Kategorien
-- dim_activity_types: +description
-- fact_history: -activity_type (text), categorization_status um 'pending'
-- dim_email_templates: +template_key, +linked_activity_type, +linked_automation_key, +is_system_template, +sort_order
-- fact_event_queue: +UNIQUE(tenant_id, idempotency_key)
-- fact_jobs: +CHECK(salary_min <= salary_max)
-- fact_mandate: mandate_status um 'Entwurf' und 'Abgelehnt' (Offerten-Conversion-Rate)
-- fact_documents: document_label um 'Assessment-Dokument', 'Mandatsofferte unterschrieben'
-- fact_goals: goal_type um 'ClassificationRate'
-- fact_match_scores: score_skills bleibt (immer NULL, deprecated)
-- dim_event_types: event_category um 'jobbasket','reminder','account'
-- bridge_candidate_skill: DEPRECATED
-- bridge_job_skill: DEPRECATED
-- Skill Economy (10 Tabellen): DEPRECATED
```

---

## 23. NACHTRAG v1.3.1 (2026-04-14) — UI-Ergänzungen

### `dim_crm_users` — Theme-Preference (Light Mode Einführung)

```sql
ALTER TABLE ark.dim_crm_users
  ADD COLUMN theme_preference text
    DEFAULT 'dark'
    CHECK (theme_preference IN ('dark','light','system'));
```

### `dim_dossier_preferences` (Stammdaten-Liste für `dim_accounts.dossier_send_preference`)

7 Standard-Codes: `email_hr`, `email_decision_maker`, `email_assistenz`, `portal_upload`, `physisch_post`, `physisch_persoenlich`, `nicht_definiert`. Details siehe `ARK_STAMMDATEN_EXPORT_v1_3.md §10b`. Phase 1.5: Soft-FK von `dim_accounts.dossier_send_preference` auf neue Stammdaten-Tabelle.

### Account-UI-Consolidation

Keine Schema-Änderung — nur Frontend. Snapshot-Bar Slots 5+6 umkonfiguriert (Offene Mandate / Aktive Prozesse → Gegründet / Standorte). Neue Arkadium-Relation-KPI-Bar in Tab 1 Account berechnet sich aus bestehenden Tabellen (`fact_mandate_billing`, `fact_process_core`) — keine neuen Spalten.

### Kontakt-Drawer

Keine neuen Tabellen. Nutzt vorhandene `dim_account_contacts` + `fact_history` (Tab "Kommunikation" filtert History auf `account_id + candidate_id`).

### `dim_account_contacts` — Org-Funktion (Refactor 14.04.2026)

Die bisher geplanten 4 Booleans (`is_decision_maker`, `is_key_contact`, `is_champion`, `is_blocker`) werden **entfernt** (subjektiv, schlecht pflegbar, kaum echte Nutzung). Stattdessen:

```sql
ALTER TABLE ark.dim_account_contacts
  DROP COLUMN IF EXISTS is_decision_maker,
  DROP COLUMN IF EXISTS is_key_contact,
  DROP COLUMN IF EXISTS is_champion,
  DROP COLUMN IF EXISTS is_blocker,
  DROP COLUMN IF EXISTS decision_level,
  ADD COLUMN org_function text NOT NULL DEFAULT 'executive'
    CHECK (org_function IN ('vr_board','executive','hr','einkauf','assistenz'));

CREATE INDEX idx_account_contacts_org_fn ON ark.dim_account_contacts(account_id, org_function);
```

Stammdaten-Details: siehe `ARK_STAMMDATEN_EXPORT_v1_3.md §10a dim_org_functions`.

---

## Widerspruchsfreiheits-Checkliste

```
✅ Alle IDs sind uuid – nirgends text als PK oder FK (Ausnahme: dim_date.date_id = INT)
✅ Nur ark Schema – public existiert nicht
✅ Stammdaten haben kein tenant_id
✅ Alle Status-Felder haben CHECK Constraints
✅ Alle Bridge-Tabellen haben UNIQUE Constraints
✅ AI schreibt nie direkt in operative Tabellen (dim_ai_write_policies)
✅ fact_audit_log nur INSERT – REVOKE UPDATE DELETE
✅ fact_webhook_logs nur INSERT – REVOKE UPDATE DELETE
✅ fact_journal_entries nur INSERT – nur Stornobuchungen
✅ dim_integration_tokens kein Klartext-Token – nur secret_ref
✅ dim_webhooks kein Klartext-Secret – nur secret_ref
✅ Historisierung: valid_from/valid_to/is_current auf allen relevanten Tabellen
✅ Pflichtfelder konsistent auf allen Tabellen
✅ Phase 2 als leerer Scaffold
✅ Circuit Breaker auf dim_automation_rules

v1.1 Ergänzungen:
✅ candidate_stage erweitert um 'Blind' und 'Datenschutz'
✅ fact_mandate_research.contact_status erweitert um GO-Rejection-Stages
✅ dim_roles + bridge_mitarbeiter_roles für Multi-Rollen-System
✅ dim_activity_types.activity_channel erweitert
✅ fact_history.activity_type_id FK auf dim_activity_types
✅ fact_jobbasket.sent_type erweitert um 'Expose'
✅ dim_account_contacts.candidate_id FK für Kontakt-Kandidat-Verknüpfung
✅ fact_process_core: UNIQUE(tenant_id, candidate_id, job_id) WHERE status NOT IN closed etc.

Migration 004: fact_refresh_tokens + fact_token_revocations
Migration 005: bridge_briefing_projects + dim_honorar_settings + fact_linkedin_activities

v1.2 Ergänzungen:
✅ Skill Economy (10 Tabellen) als DEPRECATED markiert – Focus bildet Skills ab
✅ fact_jobbasket: is_prelead (ersetzt is_lead), prelead_date, go_rejected_by (candidate/cm/am), rejection_type_id
✅ dim_candidates_profile: wechselmotivation (8 Stufen), availability_date ENTFERNT
✅ dim_accounts: purchase_potential (1-3 Sterne), agb_confirmed_at, agb_version
✅ dim_activity_types: 11 Kategorien (Kontaktberührung, Erreicht, Emailverkehr etc.)
✅ fact_history: activity_type TEXT ENTFERNT (nur FK), categorization_status um 'pending' erweitert
✅ dim_email_templates: template_key, linked_activity_type, linked_automation_key, is_system_template
✅ fact_event_queue: UNIQUE (tenant_id, idempotency_key) hinzugefügt
✅ fact_jobs: CHECK salary_min <= salary_max
✅ fact_mandate: mandate_status um 'Entwurf' und 'Abgelehnt' erweitert (Offerten-Conversion-Rate)
✅ fact_documents: document_label um 'Assessment-Dokument' und 'Mandatsofferte unterschrieben' erweitert
✅ fact_goals: goal_type um 'ClassificationRate' erweitert
✅ fact_match_scores: score_skills bleibt aber immer NULL (deprecated)
✅ dim_event_types: event_category um 'jobbasket', 'reminder', 'account' erweitert
✅ dim_event_types: 12 neue Events (jobbasket.*, reminder.overdue, process.stale_detected etc.)
✅ bridge_candidate_skill als DEPRECATED markiert
✅ bridge_job_skill als DEPRECATED markiert
✅ NEU: dim_tenant_features (Feature Flags pro Tenant)
✅ NEU: dim_automation_settings (konfigurierbare Fristen)
✅ NEU: dim_jobbasket_rejection_types (Prelead-Ablehnungsgründe)
✅ NEU: fact_email_drafts (Email-Entwürfe im CRM)
✅ NEU: v_account_duplicates (View für Account-Duplikat-Erkennung)
✅ Fehlende Indizes: Kandidaten nach Manager, Prozesse nach Stage, Mandate Research, Jobbasket, Full-Text-Suche

Tabellen-Count: ~161 Tabellen + 4 Views (davon 10 deprecated)
  001_foundation_stammdaten:     39 Tabellen
  002_core_operative:            47 Tabellen
  003_services_ai_phase2_seeds:  69 Tabellen + 3 Views
  004_auth_tokens:                2 Tabellen
  005_ui_addendum_changes:        3 Tabellen (+ 2 Schema-Änderungen)
  006_schema_cleanup:             0 Tabellen (Migration für Cleanup)
  007_v1_2_changes:               4 Tabellen + 1 View + Schema-Änderungen
  008_v1_4_zeit_module:          15 Tabellen + 4 Views + 9 Enums (Phase 3 ERP)
```

---

## v1.4 · Zeit-Modul-Erweiterung (2026-04-19 · Phase 3 ERP)

**Quelle:** `specs/ARK_ZEIT_SCHEMA_v0_1.md` · basiert auf [zeit-research-overview.md](../wiki/sources/phase3-research/zeit/zeit-research-overview.md) + Reglemente-Triade + Peter-Decisions.

### Extensions neu

```sql
CREATE EXTENSION IF NOT EXISTS btree_gist;  -- GIST-Overlap-Constraints
-- pgcrypto bereits vorhanden (gen_random_uuid)
```

### ENUM-Types neu (9)

1. `time_entry_state` (draft · submitted · approved · locked · corrected · rejected)
2. `absence_state` (draft · submitted · approved · active · completed · rejected · cancelled · corrected)
3. `correction_state` (requested · tl_approved · gf_approved · applied · rejected)
4. `period_close_state` (open · submitted · tl_approved · gf_approved · locked · exported · reopened)
5. `work_time_model` (FLEX_CORE · FIXED · PARTTIME · SIMPLIFIED_73B · EXEMPT_EXEC)
6. `scan_event_type` (check_in · check_out · break_start · break_end · override)
7. `time_entry_source` (scanner · manual · timer · import · admin)
8. `overtime_kind` (regular · ueberstunden_or · ueberzeit_arg · uncounted)
9. `salary_scale_code` (ZURICH · BERN · BASEL · INSURANCE_EQUIV) + `salary_continuation_phase`

### Dimension-Tabellen neu (4)

1. `dim_absence_type` · 30 Codes · DJ-gestaffelte Arztzeugnis-Felder
2. `dim_time_category` · 12 Codes · billable_default + zeg_relevant-Flags
3. `dim_work_time_model` · 5 Codes
4. `dim_salary_continuation_scale` · composite PK (scale_code, dienstjahr_from) · ZH + BE Seeds

### Fact-Tabellen neu (11)

1. `firm_settings` · 19 Global-Configs
2. `fact_workday_target` · Arbeitszeit-Vertrag pro MA/Jahr · weekday_minutes_jsonb · core_hours * 3 Paare (AM/PM/Fr) · Salary-Scale per User
3. `fact_holiday_cantonal` · 12 Seeds 2026 · `is_statutory` trennt gesetzl./lokal
4. `fact_bridge_day` · GF-manuell pro Jahr (F11)
5. `fact_time_scan_event` · Scanner-Roh (biometrie-sensitiv, DSG Art. 5 Ziff. 4)
6. `fact_time_entry` · `raw_duration_min` vs `counted_duration_min` (10h-Cap-Trennung) · GIST-Overlap-Exclude
7. `fact_time_correction` · mit tl_approved_by + admin_approved_by
8. `fact_time_period_close` · Monats-Lock mit `tl_weekly_checks_done JSONB` (F12 Hybrid)
9. `fact_absence` · GIST-Overlap-Exclude · DJ-gestaffelter Arztzeugnis-Reminder-Flag
10. `fact_vacation_balance` · entitlement + carried_over + taken → remaining (computed) · `carryover_deadline DATE` (14d nach Ostern)
11. `fact_overtime_balance` · 3-Konten: ueberstunden_or vs. ueberzeit_arg
12. `fact_extra_leave_entitlement` · Extra-Guthaben (Geburtstag/Joker/ZEG/GL)
13. `fact_salary_continuation_claim` · Krank-Anspruch nach Zürcher Skala
14. `fact_simplified_agreement` · 73b-Vereinbarung (individual/collective)
15. `fact_scanner_access_audit` · DSG-Audit für Biometrie-Zugriffe

### Views neu (4)

- `v_daily_saldo` · Ist vs. Soll pro User pro Tag
- `v_monthly_saldo` · Aggregat
- `v_time_per_mandate` · Commission-ZEG-Feed (FILTER zeg_relevant)
- `v_weekly_approval_queue` · TL-Dashboard F12 Hybrid

### Retention-Regeln neu

| Entität | Retention | Grund |
|---------|-----------|-------|
| fact_time_entry | 5 J post Vertragsende | ArGV 1 Art. 73 Abs. 2 |
| fact_absence (medical) | 5 J post Vertragsende | ArG 73 + revDSG Art. 5 |
| doctor_cert_file | 5 J post Abwesenheit-Ende | revDSG Art. 5 Ziff. 2 |
| fact_scanner_access_audit | 10 J | DSG-Nachweispflicht |
| fact_time_correction | 10 J | Gerichtsbeweis |

**Tabellen-Count aktualisiert:** ~176 Tabellen + 8 Views (davon 10 deprecated)

### Integration-Hooks zu bestehenden Tabellen

- `fact_time_entry.project_id` → FK auf `fact_process_core(id)` (nullable)
- `fact_time_entry.user_id` → FK auf `dim_user(id)` (alle neuen Zeit-Tabellen)
- Commission-Engine liest `v_time_per_mandate` für ZEG-Staffel

### Version-Changelog

- **v1.3 (2026-04-17):** Dok-Generator (dim_document_templates + fact_documents)
- **v1.4 (2026-04-19):** Zeit-Modul (15 Tabellen + 4 Views + 9 Enums + btree_gist)
- **v1.5 (2026-04-24):** E-Learning-Modul Sub A/B/C/D (28 neue Tabellen · pgvector-Extension · 2 Spalten `dim_user` · 4 Spalten `dim_elearn_certificate` · 30+ Indizes inkl. IVFFLAT · 20+ CHECK-Constraints · RLS-Policies auf allen tenant-scoped Tabellen). Tabellen-Count aktualisiert: ~204 Tabellen + 8 Views.

---

## v1.5 — E-Learning-Modul (Sub A/B/C/D)

**Quellen:**
- `specs/ARK_DATABASE_SCHEMA_PATCH_ELEARNING_v0_1.md` (Sub A)
- `specs/ARK_DATABASE_SCHEMA_PATCH_ELEARNING_SUB_B_v0_1.md`
- `specs/ARK_DATABASE_SCHEMA_PATCH_ELEARNING_SUB_C_v0_1.md`
- `specs/ARK_DATABASE_SCHEMA_PATCH_ELEARNING_SUB_D_v0_1.md`

**Multi-Tenant-Architektur:** E-Learning ist die erste konsequent Multi-Tenant-fähige Komponente in ARK. Alle 28 neuen Tabellen tragen `tenant_id UUID NOT NULL`. RLS-Policies auf allen Tabellen (`tenant_id = current_setting('app.current_tenant_id')::uuid`). Zweck: White-Label-Option für externe Recruiting-Boutiquen.

### Extensions

```sql
CREATE EXTENSION IF NOT EXISTS vector;  -- pgvector für RAG-Embeddings (Sub B)
-- btree_gist bereits aus v1.4 (Zeit-Modul)
```

### Sub A · Kurs-Katalog (15 neue Tabellen)

**Tenant + Content (5):**
```sql
dim_elearn_tenant (tenant_id PK, name, settings JSONB, created_at)

dim_elearn_course (course_id PK, tenant_id, slug, title, description, sparten[], rollen[],
                   duration_min, refresher_months, pretest_enabled, pretest_pass_threshold,
                   pass_threshold, version, content_hash, status, published_at,
                   created_at, updated_at, UNIQUE(tenant_id, slug))

dim_elearn_module (module_id PK, tenant_id, course_id FK, slug, order_idx, title, description,
                   content_hash, UNIQUE(tenant_id, course_id, slug),
                   UNIQUE(tenant_id, course_id, order_idx))

dim_elearn_lesson (lesson_id PK, tenant_id, module_id FK, slug, order_idx, title, content_md,
                   min_read_seconds, content_hash, UNIQUE(tenant_id, module_id, slug),
                   UNIQUE(tenant_id, module_id, order_idx))

dim_elearn_question (question_id PK, tenant_id, module_id FK, type, payload JSONB,
                     version, content_hash, created_at)
```

**Zuweisung / Onboarding (3):**
```sql
dim_elearn_curriculum_template (template_id PK, tenant_id, sparte NULLABLE, rolle,
                                course_ids UUID[], created_by, updated_at,
                                UNIQUE(tenant_id, sparte, rolle))

fact_elearn_curriculum_override (override_id PK, tenant_id, ma_id, course_ids UUID[],
                                 reason, overridden_by, created_at,
                                 UNIQUE(tenant_id, ma_id))

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
                          score_pct, passed, status, attempted_at, finalized_at,
                          answers JSONB)

fact_elearn_freitext_review (review_id PK, tenant_id, attempt_id FK, question_id FK,
                             ma_answer, llm_score, llm_feedback, llm_model,
                             head_score, head_feedback, reviewed_by, reviewed_at, status)
```

**Cert / Badges / Audit (3):**
```sql
dim_elearn_certificate (cert_id PK, tenant_id, ma_id, course_id FK, course_version,
                        pdf_url, issued_at,
                        -- v1.5 Sub-D-Erweiterung: +status, +expired_at, +revoked_at, +revoked_reason
                        UNIQUE(tenant_id, ma_id, course_id, course_version))

dim_elearn_badge (badge_id PK, tenant_id, ma_id, badge_type, course_id NULLABLE, earned_at)

fact_elearn_import_log (log_id PK, tenant_id, commit_sha, trigger, imported, updated,
                        archived, errors JSONB, started_at, finished_at)
```

**ALTER `dim_user`:**
```sql
ALTER TABLE dim_user ADD COLUMN elearn_onboarding_active BOOLEAN NOT NULL DEFAULT false;
```

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

### Sub B · Content-Generator (5 neue Tabellen + pgvector)

```sql
dim_elearn_source (source_id PK, tenant_id, kind, slug, uri, title, sparten[],
                   target_course_slug, meta JSONB, priority, content_hash,
                   last_ingested_at, enabled, created_at,
                   UNIQUE(tenant_id, kind, slug))

dim_elearn_chunk (chunk_id PK, tenant_id, source_id FK, order_idx, text, tokens,
                  embedding VECTOR(1536), meta JSONB, content_hash, created_at,
                  UNIQUE(tenant_id, source_id, order_idx))

dim_elearn_generation_job (job_id PK, tenant_id, source_ids UUID[], cluster_summary JSONB,
                           llm_model, llm_prompt_template, status, triggered_by,
                           triggered_by_user, total_tokens_in, total_tokens_out,
                           total_cost_eur, started_at, finished_at, error)

dim_elearn_generated_artifact (artifact_id PK, tenant_id, job_id FK, artifact_type,
                               target_course_slug, target_module_slug, target_lesson_slug,
                               draft_content JSONB, preview_text, source_chunk_ids UUID[],
                               status, reviewer, reviewed_at, published_commit_sha, created_at)

fact_elearn_review_action (action_id PK, tenant_id, artifact_id FK, action, reviewer,
                           reason, diff JSONB, created_at)
```

**Indizes Sub B (inkl. IVFFLAT Vector-Search):**
```sql
CREATE INDEX ON dim_elearn_source (tenant_id, kind, enabled);
CREATE INDEX ON dim_elearn_chunk (tenant_id, source_id, order_idx);
CREATE INDEX ON dim_elearn_chunk USING ivfflat (embedding vector_cosine_ops) WITH (lists = 100);
CREATE INDEX ON dim_elearn_generation_job (tenant_id, status, started_at DESC);
CREATE INDEX ON dim_elearn_generated_artifact (tenant_id, status) WHERE status IN ('draft', 'approved');
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

### Sub C · Wochen-Newsletter (4 neue Tabellen)

```sql
dim_elearn_newsletter_issue (issue_id PK, tenant_id, sparte, issue_week, publish_at,
                             title, sections JSONB, quiz_module_id, quiz_pass_threshold,
                             enforcement_mode, generation_job_id, status, published_at, created_at,
                             UNIQUE(tenant_id, sparte, issue_week))

dim_elearn_newsletter_subscription (sub_id PK, tenant_id, ma_id, sparte, mode,
                                    enforcement_override, created_at,
                                    UNIQUE(tenant_id, ma_id, sparte))

fact_elearn_newsletter_assignment (assignment_id PK, tenant_id, ma_id, issue_id FK,
                                   assigned_at, deadline, read_started_at, read_completed_at,
                                   quiz_attempt_id FK, status, reminder_sent_at,
                                   escalated_to_head_at, enforcement_mode_applied,
                                   UNIQUE(tenant_id, ma_id, issue_id))

fact_elearn_newsletter_section_read (read_id PK, tenant_id, assignment_id FK,
                                     section_idx, scroll_pct, time_spent_sec, read_at,
                                     UNIQUE(tenant_id, assignment_id, section_idx))
```

**ALTER `dim_user`:**
```sql
ALTER TABLE dim_user ADD COLUMN newsletter_enforcement_override TEXT;
-- NULL = tenant default · 'soft' | 'hard'
```

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

**Interop mit Sub A:** Newsletter-Quiz nutzt `fact_elearn_quiz_attempt` mit `attempt_kind='newsletter'`. Pro Issue synthetisches `dim_elearn_module` (Owner: versteckter Newsletter-Kurs pro Tenant mit `slug='__newsletter__'`).

### Sub D · Progress-Gate (4 neue Tabellen + Cert-Erweiterung)

```sql
dim_elearn_gate_rule (rule_id PK, tenant_id, name, description, trigger_type,
                      trigger_params JSONB, blocked_features TEXT[], allowed_features TEXT[],
                      priority, enabled, created_by, created_at, updated_at,
                      UNIQUE(tenant_id, name))

fact_elearn_gate_event (event_id PK, tenant_id, ma_id, rule_id, feature_key, action,
                        override_id, request_meta JSONB, occurred_at)

dim_elearn_gate_override (override_id PK, tenant_id, ma_id, override_type, reason,
                          valid_from, valid_until, pause_deadlines, created_by,
                          created_at, ended_at, ended_by)

fact_elearn_compliance_snapshot (snapshot_id PK, tenant_id, ma_id, snapshot_date,
                                 courses_total, courses_completed,
                                 newsletters_total, newsletters_passed,
                                 certs_active, certs_expired, overdue_items,
                                 compliance_score,
                                 UNIQUE(tenant_id, ma_id, snapshot_date))
```

**ALTER `dim_elearn_certificate` (Sub-A-Tabelle):**
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
CREATE INDEX ON fact_elearn_gate_event (tenant_id, rule_id, occurred_at DESC) WHERE rule_id IS NOT NULL;
CREATE INDEX ON dim_elearn_gate_override (tenant_id, ma_id, valid_from, valid_until) WHERE ended_at IS NULL;
CREATE INDEX ON fact_elearn_compliance_snapshot (tenant_id, ma_id, snapshot_date DESC);
CREATE INDEX ON fact_elearn_compliance_snapshot (tenant_id, snapshot_date, compliance_score);
```

**CHECK-Constraints Sub D:**
- `dim_elearn_gate_rule.trigger_type IN ('newsletter_overdue','onboarding_overdue','refresher_due','cert_expired','assignment_expired')`
- `fact_elearn_gate_event.action IN ('blocked','allowed','overridden','bypassed')`
- `dim_elearn_gate_override.override_type IN ('vacation','parental_leave','medical','emergency_bypass','other')`
- `dim_elearn_gate_override.valid_until IS NULL OR valid_until > valid_from`

**Tenant-Settings `elearn_d.*`:** `login_popup_enabled=true`, `login_popup_min_items=1`, `gate_cache_ttl_seconds=60`, `compliance_snapshot_cron='0 3 * * *'`, `compliance_report_retention_months=36`, `cert_auto_revoke_on_major_version=true`, `dashboard_banner_position='top'`, `default_gate_rules_seed=true`.

**Default-Gate-Rules-Seed** (4 Rules pro Tenant): `Hard-Newsletter-Block` (Priority 100) · `Onboarding-Expired-Block` (90) · `Cert-Expired-Readonly` (80) · `Soft-Newsletter-Warning` (50). Details in `specs/ARK_DATABASE_SCHEMA_PATCH_ELEARNING_SUB_D_v0_1.md §6`.

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

### Tabellen-Count aktualisiert

**v1.5:** ~204 Tabellen + 8 Views (176 v1.4 + 28 E-Learning). Inkl. Sub A 15, Sub B 5, Sub C 4, Sub D 4.

### Migration-Reihenfolge (konsolidiert)

1. `CREATE EXTENSION IF NOT EXISTS vector`
2. Sub A: 15 Tables (FK-Reihenfolge: tenant → course → module → lesson → question → curriculum → override → assignment → enrollment → progress → quiz_attempt → freitext_review → cert → badge → import_log)
3. Sub A: `ALTER dim_user ADD elearn_onboarding_active`
4. Sub A: Indizes + CHECK-Constraints
5. Sub A: Seed `dim_elearn_tenant` (Arkadium-Default)
6. Sub B: 5 Tables + IVFFLAT-Index + CHECK-Constraints + Tenant-Settings `elearn_b.*`
7. Sub C: 4 Tables + `ALTER dim_user ADD newsletter_enforcement_override` + Indizes + CHECK + Tenant-Settings `elearn_c.*` + Seed versteckter Newsletter-Kurs (`slug='__newsletter__'`)
8. Sub D: 4 Tables + `ALTER dim_elearn_certificate` (+4 Spalten) + Indizes + CHECK + Tenant-Settings `elearn_d.*` + Default-Gate-Rules-Seed
9. RLS: `ENABLE ROW LEVEL SECURITY` + Policies auf allen 28 Tabellen

### Performance-Annahmen

- **pgvector-RAG-Retrieval:** < 100 ms mit IVFFLAT (bis ~1 Mio Chunks/Tenant)
- **Gate-Middleware-Overhead:** < 1 ms mit Cache, 5-15 ms ohne Cache
- **Compliance-Snapshot:** ~50 ms pro MA (Multi-JOIN), 30 MA Tenant → 1.5 s/Run
- **Newsletter-Publish:** Bulk-Insert 150 Assignments (30 MA × 5 Sparten) in < 200 ms

---

## TEIL M: HR-Modul (v1.5, 2026-04-25)

**Spec-Quelle:** `specs/ARK_HR_TOOL_SCHEMA_v0_1.md`
**Scope:** Arbeitsverträge, HR-Dokumente, Disziplinarmassnahmen, Probezeit-Tracking, Onboarding-Checklisten. Absenzenverwaltung lebt in TEIL L (Zeit-Modul).

### M.1 Extensions

```sql
CREATE EXTENSION IF NOT EXISTS pgcrypto;  -- gen_random_uuid() (bereits vorhanden)
```

### M.2 ENUM-Types (9 neue)

| ENUM | Werte |
|------|-------|
| `contract_state` | draft · pending_sig · active · terminated · expired · voided |
| `employment_type` | permanent · fixed_term · intern · freelance |
| `termination_reason` | resignation · dismissal · dismissal_immediate · mutual_agreement · end_fixed_term · retirement · death |
| `hr_doc_state` | pending · signed · superseded · revoked |
| `probation_milestone_type` | month_1_review · month_2_review · probation_end · probation_extended · probation_failed |
| `disciplinary_level` | verbal_warning · written_warning · formal_warning · final_warning · suspension · dismissal_immediate |
| `disciplinary_state` | draft · issued · acknowledged · disputed · resolved · archived |
| `onboarding_state` | draft · active · completed · overdue · cancelled |
| `onboarding_task_state` | pending · in_progress · done · skipped · overdue |
| `onboarding_assignee_role` | new_hire · head_of · admin · it · buddy |

### M.3 Dimension Tables (3)

| Tabelle | PK | Seeds | Beschreibung |
|---------|-----|-------|-------------|
| `dim_hr_document_type` | `code VARCHAR(60)` | 13 Rows | Katalog HR-Dokument-Typen (Verträge, Reglemente, Bescheinigungen) |
| `dim_disciplinary_offense_type` | `code VARCHAR(60)` | 13 Rows | Delikt-Katalog (attendance/conduct/performance/compliance/integrity) |
| `dim_onboarding_task_template_type` | `code VARCHAR(80)` | 18 Rows | Wiederverwendbare Onboarding-Aufgaben-Vorlagen |

**dim_hr_document_type Seeds:** EMPLOYMENT_CONTRACT · GENERALIS_PROVISIO · PROGRESSUS · PRAEMIUM_VICTORIA · TEMPUS_PASSIO_365 · LOCUS_EXTRA · DATENSCHUTZ_ERKLAERUNG · REFERENCE_LETTER · INTERIM_REFERENCE · SALARY_STATEMENT · AHV_CONFIRMATION · PROBATION_EXTENSION · OTHER

**dim_disciplinary_offense_type Seeds:** REPEATED_LATENESS · UNEXCUSED_ABSENCE · INSUBORDINATION · MISCONDUCT_COLLEAGUE · MISCONDUCT_CLIENT · PERFORMANCE_DEFICIENCY · TARGET_MISS_REPEATED · DATA_BREACH_INTERNAL · CONFIDENTIALITY_BREACH · EXPENSE_FRAUD · COMPETITION_VIOLATION · HARASSMENT · OTHER

**dim_onboarding_task_template_type Seeds:** WELCOME_MEETING · IT_EQUIPMENT_SETUP · EMAIL_SETUP · SIGN_GENERALIS_PROVISIO · SIGN_PROGRESSUS · SIGN_TEMPUS_PASSIO · SIGN_LOCUS_EXTRA · SIGN_PRAEMIUM_VICTORIA · SIGN_DATENSCHUTZ · AHV_REGISTRATION · BADGE_KEY · BANK_DETAILS · CRM_INTRO · TOOL_INTRO_ELEARN · BUDDY_INTRO · TEAM_LUNCH · MONTH_1_REVIEW · PROBATION_REVIEW

### M.4 Fact Tables (8)

| Tabelle | FK-Hauptreferenz | Unique-Constraint | Beschreibung |
|---------|-----------------|-------------------|-------------|
| `fact_employment_contracts` | `dim_user(id)` | 1 aktiver Vertrag/MA (`contract_state='active'`) | Arbeitsvertrag-Lifecycle |
| `fact_employment_attachments` | `fact_employment_contracts(id)` + `dim_hr_document_type(code)` | — | Reglement-Signaturen + Vertragsbeilagen |
| `fact_disciplinary_records` | `dim_user(id)` + `dim_disciplinary_offense_type(code)` | — | Verwarnungen + Disziplinarmassnahmen |
| `fact_probation_milestones` | `dim_user(id)` + `fact_employment_contracts(id)` | — | Probezeit-Gespräche + Meilensteine |
| `fact_onboarding_templates` | `dim_user(role_code)` NULL | 1 Default/Rolle | Wiederverwendbare Checklisten-Vorlagen |
| `fact_onboarding_template_tasks` | `fact_onboarding_templates(id)` CASCADE | — | Aufgaben einer Vorlage |
| `fact_onboarding_instances` | `dim_user(id)` + `fact_employment_contracts(id)` | 1 aktives Onboarding/MA | Onboarding-Prozess pro MA |
| `fact_onboarding_instance_tasks` | `fact_onboarding_instances(id)` CASCADE | — | Einzelne Aufgaben im laufenden Onboarding |

**Alle Fact-Tabellen:** UUID-PKs · `audit_trail_jsonb JSONB` append-only · `updated_at TIMESTAMPTZ` · Soft-Delete via `archived_at`

**Retention:**

| Tabelle | Retention | Rechtsgrundlage |
|---------|-----------|----------------|
| `fact_employment_contracts` | 10 J post Vertragsende | OR 127/128 |
| `fact_employment_attachments` | 10 J post Vertragsende | Beweislast |
| `fact_disciplinary_records` (ohne Folgen) | 2 J post Archivierung | EDÖB |
| `fact_disciplinary_records` (mit Kündigung) | 10 J | OR 339/341 |
| `fact_onboarding_instances` | 5 J post Austritt | Compliance |

### M.5 Views (4)

| View | Beschreibung |
|------|-------------|
| `v_hr_active_employees` | Aktive MA + Vertragsdaten (JOIN dim_user + fact_employment_contracts) |
| `v_onboarding_progress` | Fortschritt + probation_passed aller aktiven Onboardings |
| `v_disciplinary_summary` | Aktive Verwarnung-Zusammenfassung pro MA (open_records, highest_level, has_dispute) |
| `v_pending_signatures` | Dokumente mit ausstehenden Unterschriften + days_pending |

### M.6 Triggers (5 Funktionen)

| Trigger | Tabelle | Funktion |
|---------|---------|---------|
| `trg_employment_contract_audit` | `fact_employment_contracts` | `fn_append_audit_trail()` — JSONB-Diff |
| `trg_employment_attachment_audit` | `fact_employment_attachments` | `fn_append_audit_trail()` |
| `trg_disciplinary_audit` | `fact_disciplinary_records` | `fn_append_audit_trail()` |
| `trg_probation_milestone_audit` | `fact_probation_milestones` | `fn_append_audit_trail()` |
| `trg_onboarding_instance_audit` | `fact_onboarding_instances` | `fn_append_audit_trail()` |
| `trg_onboarding_task_state_changed` | `fact_onboarding_instance_tasks` | `fn_onboarding_task_state_change()` — Counters + State |
| `trg_disciplinary_escalation` | `fact_disciplinary_records` | `fn_disciplinary_suggest_escalation()` — next_level |
| `trg_employment_contract_termination` | `fact_employment_contracts` | `fn_employment_contract_termination()` — retention_until |

### M.7 Row-Level Security

RLS aktiviert auf: `fact_employment_contracts` · `fact_employment_attachments` · `fact_disciplinary_records` · `fact_probation_milestones` · `fact_onboarding_instances` · `fact_onboarding_instance_tasks`

| Rolle | Zugriff |
|-------|---------|
| `ark_role_ma` | Read eigene Daten (Disziplinar: nur `state IN issued/acknowledged/disputed`) |
| `ark_role_head` | Read+Write eigenes Team (`fn_team_user_ids()` via `team_lead_id`) |
| `ark_role_admin` | Vollzugriff |
| `ark_role_bo` | Read-only alle |

Helper-Funktionen: `fn_current_user_id()` · `fn_current_role_code()` · `fn_team_user_ids()`
Supabase-Adapter: `fn_current_user_id()` SECURITY DEFINER mit `auth.uid()`

### M.8 Tabellen-Count aktualisiert

**v1.5 + HR:** ~215 Tabellen + 12 Views (204 E-Learning-Stand + 11 HR-Tabellen)
- 3 Dimension Tables · 8 Fact Tables = **11 neue Tabellen**
- 4 neue Views

### M.9 Migration-Reihenfolge HR

```
1. ENUMs (9 neue Typen)
2. Dimension Tables + Seeds (dim_hr_document_type · dim_disciplinary_offense_type · dim_onboarding_task_template_type)
3. Fact Tables (FK-Reihenfolge: contracts → attachments → disciplinary → probation → templates → template_tasks → instances → instance_tasks)
4. Indexes
5. Views (4)
6. Trigger-Funktionen (fn_append_audit_trail · fn_onboarding_task_state_change · fn_disciplinary_suggest_escalation · fn_employment_contract_termination)
7. Triggers (8)
8. RLS aktivieren (6 Fact-Tabellen)
9. Helper-Funktionen (fn_current_user_id · fn_current_role_code · fn_team_user_ids)
10. RLS-Policies
11. Grants (ark_role_ma/head/admin/bo)
12. Supabase Auth Adapter
```

---

## TEIL Q · Performance-Modul (v1.6 · 2026-04-25)

**Scope:** Cross-Modul-Analytics-Hub. 14 neue Tabellen im `ark_perf`-Schema + 7 HR-Performance-Tabellen im `ark_hr` (Q1=C Migration aus DB §19) + 10 Live-Views + 8 Materialized Views + RLS-Policies + 3 neue Rollen. Vollständiger Patch: `specs/ARK_DATABASE_SCHEMA_PATCH_v1_5_to_v1_6_performance.md`. Detailliertes Tabellen-DDL: `specs/ARK_PERFORMANCE_TOOL_SCHEMA_v0_1.md`.

### Q.1 Streichungen aus DB §19 (Phase-2-Scaffold)

Folgende Stubs werden aus dem Phase-2-Scaffold-Block entfernt:

```diff
-PERFORMANCE: fact_performance_reviews · fact_360_feedback · dim_feedback_questions · dim_feedback_cycles
-ENTWICKLUNG: fact_development_plans · fact_learning_progress · dim_learning_modules ·
-             dim_skill_certifications · fact_competency_ratings · dim_competency_framework
```

**Migration:**
- 7 Tabellen (`fact_performance_reviews` · `fact_360_feedback` · `dim_feedback_questions` · `dim_feedback_cycles` · `fact_competency_ratings` · `dim_competency_framework` · `fact_development_plans`) → ins HR-Modul (`ark_hr.*`, siehe HR-Patch §2-§9)
- 3 Tabellen gestrichen (`fact_learning_progress` · `dim_learning_modules` · `dim_skill_certifications`) → E-Learning Sub-A (`fact_elearn_attempt` · `dim_elearn_course` · `fact_elearn_certificate`) ist Single-Source

**§19 wird neu strukturiert:**

```
PERFORMANCE-MODUL (eigenes ERP-Modul · siehe ARK_PERFORMANCE_TOOL_SCHEMA_v0_1.md):
  Snapshot-Layer:    fact_metric_snapshot_hourly/daily/weekly/monthly/quarterly/yearly
  Insight-Loop:      fact_insight · fact_action_item · fact_action_outcome
  Goals:             fact_perf_goal
  Reports:           dim_report_template · fact_report_run
  Forecast:          dim_forecast_conversion_rate · fact_forecast_snapshot
  Dashboards:        dim_dashboard_layout · dim_dashboard_tile_type · fact_dashboard_view_log
  Power-BI:          dim_powerbi_view
  Stammdaten:        dim_metric_definition · dim_anomaly_threshold

HR-PERFORMANCE-REVIEWS (im HR-Modul · siehe ARK_HR_TOOL_SCHEMA_v0_2.md):
  Cycles:            dim_feedback_cycles
  Questions:         dim_feedback_questions
  Reviews:           fact_performance_reviews · fact_360_feedback
  Competency:        dim_competency_framework · fact_competency_ratings
  Development:       fact_development_plans

E-LEARNING (existiert · Sub A-D):
  E-Learning ist Single-Source für Lern-Daten.
  Performance-Modul liest nur via v_elearn_compliance.
```

### Q.2 Erweiterungen bestehender Tabellen

**`dim_process_stages`** (siehe §13 Stammdaten-Patch):
- ADD COLUMN `funnel_relevance VARCHAR(20) NOT NULL DEFAULT 'standard' CHECK (... IN ('standard', 'major_milestone', 'drop_off_risk', 'terminal'))`
- ADD COLUMN `avg_days_target SMALLINT NULL`
- Seeds-Updates für 9 Stage-Codes (siehe Stammdaten-Patch §97.7)

**`dim_user`**:
- ADD COLUMN `performance_visibility_scope VARCHAR(20) NOT NULL DEFAULT 'self' CHECK (... IN ('self', 'team', 'tenant', 'admin'))`
- Seeds-Updates: MA/Researcher/CM/AM/RA = `self`, Head = `team`, Admin = `admin`

### Q.3 Performance-Modul-Tabellen (`ark_perf`-Schema)

```sql
CREATE SCHEMA IF NOT EXISTS ark_perf;
CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE EXTENSION IF NOT EXISTS btree_gin;

-- 11 ENUMs (siehe Performance-Schema §3 + Stammdaten-Patch §97.1)

-- 6 Stammdaten-Tabellen
CREATE TABLE ark_perf.dim_metric_definition (...);
CREATE TABLE ark_perf.dim_anomaly_threshold (...);
CREATE TABLE ark_perf.dim_dashboard_tile_type (...);
CREATE TABLE ark_perf.dim_dashboard_layout (...);
CREATE TABLE ark_perf.dim_report_template (...);
CREATE TABLE ark_perf.dim_powerbi_view (...);
CREATE TABLE ark_perf.dim_forecast_conversion_rate (...);

-- 6 Snapshot-Tabellen — partitioniert nach Monat (RANGE auf snapshot_at)
CREATE TABLE ark_perf.fact_metric_snapshot_hourly (...) PARTITION BY RANGE (snapshot_at);
CREATE TABLE ark_perf.fact_metric_snapshot_daily (...);
CREATE TABLE ark_perf.fact_metric_snapshot_weekly (...);
CREATE TABLE ark_perf.fact_metric_snapshot_monthly (...);
CREATE TABLE ark_perf.fact_metric_snapshot_quarterly (...);
CREATE TABLE ark_perf.fact_metric_snapshot_yearly (...);

-- Insight-Loop + Goals + Reports + Telemetrie
CREATE TABLE ark_perf.fact_perf_goal (...);
CREATE TABLE ark_perf.fact_insight (...);
CREATE TABLE ark_perf.fact_action_item (...);
CREATE TABLE ark_perf.fact_action_outcome (...);
CREATE TABLE ark_perf.fact_report_run (...);
CREATE TABLE ark_perf.fact_forecast_snapshot (...);
CREATE TABLE ark_perf.fact_dashboard_view_log (...);

-- Initial-Partitionen für laufenden + nächsten Monat (hourly)
CREATE TABLE ark_perf.fact_metric_snapshot_hourly_2026_04 PARTITION OF ark_perf.fact_metric_snapshot_hourly
    FOR VALUES FROM ('2026-04-01') TO ('2026-05-01');
-- weitere Partitionen via partition-creator.worker (monatlicher Cron für nächste 3 Mt)
```

### Q.4 HR-Performance-Tabellen (`ark_hr`-Schema)

7 Tabellen migriert aus DB §19 ins HR-Modul. Vollständige DDL: `specs/ARK_HR_TOOL_SCHEMA_v0_2.md` §2-§8. Siehe auch §98 im Stammdaten-Export.

### Q.5 Live-Views (10 Views, READ-only für Performance)

Alle Live (kein Snapshot — für Drill-Downs + ad-hoc Queries):

| View | Zweck | Quellen |
|------|-------|---------|
| `v_pipeline_funnel` | Stage-Counts + Conversion-Rates pro tenant/owner/team/sparte/business_model | `fact_process` × `dim_process_stages` × `dim_user` × `fact_mandate` |
| `v_candidate_coverage` | Days-since-touch + coverage_state (`ok`/`overdue`/`critical`/`never_touched`) + score | `fact_history` × `dim_candidate` (12 Mt Lookback) |
| `v_account_coverage` | Days-since-touch + coverage_state nach `purchase_potential` (★/★★/★★★) | `fact_history` × `dim_account` |
| `v_mandate_kpi_status` | Ident-Target/Actual · Call-Target/Actual · Shortlist · Placements · Revenue | `fact_mandate` × `fact_process` × `fact_history` × `fact_placement` × `fact_invoice` |
| `v_revenue_attribution` | Revenue pro placement_id mit Commission-Refs (cm/am/researcher) | `fact_invoice` × `fact_placement` × `fact_process` × `fact_mandate` × `fact_commission_ledger` |
| `v_activity_heatmap` | Activity-Counts pro user × DOW × Hour-of-Day × activity_type | `fact_history` × `dim_activity_types` |
| `v_elearn_compliance` | Pflicht-Kurs-Compliance% + Newsletter-Quizzes + Active Certs | `dim_user` × `ark_elearn.*` |
| `v_zeit_utilization` | Hours-worked vs target_hours_monthly (Pensum-basiert) + Sick/Vacation-Days | `fact_time_entries` × `fact_absences` × `dim_user` |
| `v_hr_review_summary` | Aggregat-View über Performance-Reviews (HR-Patch-Brücke) | `ark_hr.*` |
| `v_commission_run_rate` | Commission-Sums pro user × month × role | `fact_commission_ledger` |

### Q.6 Materialized Views (8 Views für Power-BI)

Per `dim_powerbi_view.refresh_cron` getriggert via `powerbi-view-refresh.worker`. UNIQUE-Index für `REFRESH MATERIALIZED VIEW CONCURRENTLY`.

| View | Cadence | Critical |
|------|---------|----------|
| `mv_perf_pipeline_today` | hourly | ✓ |
| `mv_perf_goal_drift_critical` | hourly | ✓ |
| `mv_perf_coverage_critical` | hourly | ✓ |
| `mv_perf_revenue_monthly` | monthly | ✗ |
| `mv_perf_pipeline_funnel_daily` | daily | ✗ |
| `mv_perf_cohort_hunt_vintage` | weekly | ✗ |
| `mv_perf_activity_heatmap_weekly` | weekly | ✗ |
| `mv_perf_elearn_compliance_daily` | daily | ✗ |

### Q.7 RLS-Policies

Alle `fact_perf_*` · `fact_insight` · `fact_action_*` · `fact_report_run` · `fact_forecast_*` · `dim_dashboard_layout` · `fact_metric_snapshot_*` · `fact_dashboard_view_log` sowie alle 7 HR-Performance-Tabellen:

```sql
ALTER TABLE <table> ENABLE ROW LEVEL SECURITY;
ALTER TABLE <table> FORCE ROW LEVEL SECURITY;  -- forciert RLS auch für Owner-Rolle
CREATE POLICY <name>_tenant_isolation ON <table>
    USING (tenant_id = current_setting('app.tenant_id')::uuid);
CREATE POLICY <name>_worker_bypass ON <table>
    TO ark_worker_service
    USING (TRUE) WITH CHECK (TRUE);
```

Visibility-Scope-Filter (additiv):
- `self`: nur eigene Rows (`user_id = current_user`)
- `team`: Rows wo `user_id IN fn_team_user_ids()`
- `tenant`: alle Rows im Tenant
- `admin`: tenant + cross-tenant (Super-Admin only)

### Q.8 Berechtigungs-Rollen (3 neue Rollen)

```sql
-- Power-BI Read-Only (über X-API-Key auth)
CREATE ROLE powerbi_reader NOLOGIN;
GRANT USAGE ON SCHEMA ark_perf TO powerbi_reader;
GRANT SELECT ON ALL MATERIALIZED VIEWS IN SCHEMA ark_perf TO powerbi_reader;

-- Performance-Modul-Reader (Live-Views + cross-Modul-Reads)
CREATE ROLE ark_perf_reader NOLOGIN;
GRANT USAGE ON SCHEMA ark_perf TO ark_perf_reader;
GRANT SELECT ON ALL TABLES IN SCHEMA ark_perf TO ark_perf_reader;
GRANT SELECT ON ark_hr.v_hr_review_summary TO ark_perf_reader;
GRANT SELECT ON ark.fact_history, ark.fact_process, ark.fact_mandate,
                ark.fact_invoice, ark.fact_placement, ark.fact_commission_ledger,
                ark.dim_candidate, ark.dim_account, ark.dim_user,
                ark.fact_time_entries, ark.fact_absences,
                ark_elearn.fact_elearn_attempt, ark_elearn.fact_elearn_assignment,
                ark_elearn.fact_elearn_certificate
                TO ark_perf_reader;

-- Worker-Service (Snapshot-Writes mit RLS-Bypass)
CREATE ROLE ark_worker_service NOLOGIN;
GRANT USAGE ON SCHEMA ark_perf TO ark_worker_service;
GRANT INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA ark_perf TO ark_worker_service;
```

### Q.9 Migration-Reihenfolge (Production-Deploy)

```
1. Backup
2. CREATE EXTENSIONS (idempotent: pgcrypto, btree_gin)
3. CREATE SCHEMA ark_perf, ark_hr (oder bestehend)
4. CREATE alle ENUMs (Performance + HR-Patch)
5. CREATE Stammdaten-Tabellen (Performance + HR)
6. CREATE Snapshot-Tabellen + Initial-Partitionen
7. CREATE Goal/Insight/Action/Report/Forecast/Telemetrie-Tabellen
8. CREATE HR-Performance-Tabellen (Reviews, 360°, Competency, Dev-Plans)
9. CREATE Live-Views (10)
10. CREATE Materialized Views (8) + UNIQUE-Indizes
11. ALTER dim_process_stages + dim_user + Seeds-Updates
12. INSERT Stammdaten-Seeds (Stammdaten-Patch §97 — 76 Default-Rows)
13. ENABLE RLS + CREATE Policies
14. CREATE Roles (powerbi_reader, ark_perf_reader, ark_worker_service)
15. GRANT Permissions
16. Verify: SELECT count(*) für alle Seeds, EXPLAIN auf alle Views, Initial-Refresh aller MVs
17. Drop alte Phase-2-Stubs aus DB §19 (sofern als CREATE TABLE existiert)
```

### Q.10 Performance-Erwägungen

- **Partitionierung:** monatliche RANGE-Partitions, automatische Erstellung via `partition-creator.worker` (monatlicher Cron für die nächsten 3 Monate)
- **Snapshot-Volumen:** ~33 Metriken × ~500 Scopes × 365 Tage = ~6 Mio Rows/Jahr für daily — vertretbar
- **Hourly:** nur Critical-Views, ~10 Metriken × ~50 Scopes × 24h × 365 = ~4 Mio Rows/Jahr
- **MV-Refresh:** CONCURRENT (kein Lock auf Read), Worker-koordiniert
- **Retention:** wöchentlicher Cleaner via `snapshot-retention-cleaner.worker` löscht gemäss `retention_until`

### Q.11 Tabellen-Count aktualisiert

```
v1.5: ~215 Tabellen (204 E-Learning + 11 HR)
v1.6 Performance:
  - +14 ark_perf.* Tabellen
  - +7 ark_hr.* Performance-Reviews-Tabellen (migriert aus §19)
  - −3 gestrichen (fact_learning_progress, dim_learning_modules, dim_skill_certifications)
  - +10 Live-Views (ark_perf.v_*)
  - +8 Materialized Views (ark_perf.mv_*)
v1.6 total: ~225 Tabellen + ~30 Views (inkl. MV)
```

- **Audit-Log-Volumen `fact_elearn_gate_event`:** ~150k Events/Monat/MA → Partitionieren/Archivieren nach 12 Monaten
