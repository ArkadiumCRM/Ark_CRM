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
recurrence          text NOT NULL DEFAULT 'None'
  CHECK (recurrence IN ('None','Daily','Weekly','Monthly'))
is_done             boolean NOT NULL DEFAULT false
done_at             timestamptz
done_by             uuid REFERENCES ark.dim_mitarbeiter(id)
is_auto_generated   boolean NOT NULL DEFAULT false
is_push_sent        boolean NOT NULL DEFAULT false
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

### Outmatch Stammdaten
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
```

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
```
