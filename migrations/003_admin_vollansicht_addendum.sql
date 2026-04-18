-- ================================================================================
-- Migration 003 · Admin-Vollansicht-Addendum
-- ================================================================================
-- Basis-Spec: specs/ARK_ADMIN_VOLLANSICHT_SCHEMA_v0_1.md
-- Begleit-Interactions: specs/ARK_ADMIN_VOLLANSICHT_INTERACTIONS_v0_1.md
-- DB-Patch-Addendum: specs/ARK_DATABASE_SCHEMA_PATCH_v1_3_to_v1_4.md §A
-- Backend-Patch-Addendum: specs/ARK_BACKEND_ARCHITECTURE_PATCH_v2_5_to_v2_6.md §K
-- Stand: 2026-04-17
-- ================================================================================
-- Zweck: Admin-Vollansicht-Unterbau · neue Tabellen, Settings-Struktur-Wechsel,
--        Event-Katalog-Erweiterung, Legal-Hold-Blocker-Trigger, Audit-Action-Enum.
-- ================================================================================

BEGIN;

-- ================================================================================
-- 1 · dim_automation_settings · JSONB-Spalte ergänzen (für Matrix-Keys)
-- ================================================================================

ALTER TABLE ark.dim_automation_settings
  ADD COLUMN IF NOT EXISTS value_jsonb JSONB;

COMMENT ON COLUMN ark.dim_automation_settings.value_jsonb IS
  'v1.4: JSONB-Value für Matrix/Array/Object-Keys (fee_staffel, refund_staffel, etc.)';

-- ================================================================================
-- 2 · fact_audit_log · CHECK-Enum erweitern
-- ================================================================================

ALTER TABLE ark.fact_audit_log
  DROP CONSTRAINT IF EXISTS fact_audit_log_action_check;

ALTER TABLE ark.fact_audit_log
  ADD CONSTRAINT fact_audit_log_action_check CHECK (action IN (
    'CREATE','UPDATE','DELETE','READ','EXPORT',
    'CONFIG','PLACEMENT','LEGAL_HOLD','RETENTION_CHANGE','DSG_REQUEST'
  ));

COMMENT ON CONSTRAINT fact_audit_log_action_check ON ark.fact_audit_log IS
  'v1.4: 5 neue Actions für Admin-Vollansicht (CONFIG, LEGAL_HOLD, RETENTION_CHANGE, DSG_REQUEST)';

-- ================================================================================
-- 3 · dim_legal_holds · neu
-- ================================================================================

CREATE TABLE IF NOT EXISTS ark.dim_legal_holds (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  entity_type       TEXT NOT NULL CHECK (entity_type IN (
                      'candidate','account','mandate','process','placement'
                    )),
  entity_id         UUID NOT NULL,
  reason            TEXT NOT NULL CHECK (length(reason) >= 20),
  set_by            UUID NOT NULL REFERENCES ark.dim_mitarbeiter(id),
  set_at            TIMESTAMPTZ NOT NULL DEFAULT now(),
  expires_at        TIMESTAMPTZ,
  released_by       UUID REFERENCES ark.dim_mitarbeiter(id),
  released_at       TIMESTAMPTZ,
  release_reason    TEXT,
  active            BOOLEAN GENERATED ALWAYS AS (released_at IS NULL) STORED,
  tenant_id         UUID NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_legal_holds_entity
  ON ark.dim_legal_holds (entity_type, entity_id);

CREATE INDEX IF NOT EXISTS idx_legal_holds_active
  ON ark.dim_legal_holds (active) WHERE active = true;

CREATE UNIQUE INDEX IF NOT EXISTS uniq_legal_holds_active_per_entity
  ON ark.dim_legal_holds (entity_type, entity_id) WHERE released_at IS NULL;

COMMENT ON TABLE ark.dim_legal_holds IS
  'v1.4: Entity-Legal-Hold · friert Mutation/Löschung + Retention ein';

-- ================================================================================
-- 4 · Legal-Hold-Blocker · Trigger-Function + Attachments
-- ================================================================================

CREATE OR REPLACE FUNCTION ark.block_if_legal_hold()
RETURNS TRIGGER AS $$
DECLARE
  v_entity_type TEXT;
BEGIN
  -- Map TG_TABLE_NAME (plural, e.g. dim_candidates) auf Legal-Hold-Enum
  v_entity_type := CASE TG_TABLE_NAME::text
    WHEN 'dim_candidates' THEN 'candidate'
    WHEN 'dim_accounts' THEN 'account'
    WHEN 'dim_mandates' THEN 'mandate'
    WHEN 'fact_processes' THEN 'process'
    WHEN 'fact_placements' THEN 'placement'
    ELSE NULL
  END;

  IF v_entity_type IS NULL THEN
    RETURN OLD;  -- Tabelle nicht im Legal-Hold-Scope
  END IF;

  IF EXISTS (
    SELECT 1 FROM ark.dim_legal_holds
     WHERE entity_type = v_entity_type
       AND entity_id = OLD.id
       AND active = true
  ) THEN
    RAISE EXCEPTION 'Entity % unter Legal-Hold, Mutation blockiert. Admin muss zuerst Legal-Hold aufheben.', OLD.id
      USING ERRCODE = 'check_violation';
  END IF;

  RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- Attach Triggers auf Entity-Tables
CREATE TRIGGER trg_legal_hold_block_candidates
  BEFORE UPDATE OR DELETE ON ark.dim_candidates
  FOR EACH ROW EXECUTE FUNCTION ark.block_if_legal_hold();

CREATE TRIGGER trg_legal_hold_block_accounts
  BEFORE UPDATE OR DELETE ON ark.dim_accounts
  FOR EACH ROW EXECUTE FUNCTION ark.block_if_legal_hold();

CREATE TRIGGER trg_legal_hold_block_mandates
  BEFORE UPDATE OR DELETE ON ark.dim_mandates
  FOR EACH ROW EXECUTE FUNCTION ark.block_if_legal_hold();

CREATE TRIGGER trg_legal_hold_block_processes
  BEFORE UPDATE OR DELETE ON ark.fact_processes
  FOR EACH ROW EXECUTE FUNCTION ark.block_if_legal_hold();

CREATE TRIGGER trg_legal_hold_block_placements
  BEFORE UPDATE OR DELETE ON ark.fact_placements
  FOR EACH ROW EXECUTE FUNCTION ark.block_if_legal_hold();

-- ================================================================================
-- 5 · dim_retention_change_proposals · Vier-Augen-Prinzip
-- ================================================================================

CREATE TABLE IF NOT EXISTS ark.dim_retention_change_proposals (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  setting_key       TEXT NOT NULL,
  old_value         JSONB NOT NULL,
  new_value         JSONB NOT NULL,
  reason            TEXT NOT NULL CHECK (length(reason) >= 20),
  proposed_by       UUID NOT NULL REFERENCES ark.dim_mitarbeiter(id),
  proposed_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
  status            TEXT NOT NULL CHECK (status IN (
                      'pending_second_signature','approved','rejected','withdrawn'
                    )) DEFAULT 'pending_second_signature',
  resolved_at       TIMESTAMPTZ,
  resolved_by       UUID REFERENCES ark.dim_mitarbeiter(id),
  rejection_reason  TEXT,
  tenant_id         UUID NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_retention_proposals_status
  ON ark.dim_retention_change_proposals (status, tenant_id);

CREATE INDEX IF NOT EXISTS idx_retention_proposals_setting
  ON ark.dim_retention_change_proposals (setting_key, proposed_at DESC);

COMMENT ON TABLE ark.dim_retention_change_proposals IS
  'v1.4: Vier-Augen-Prinzip für Retention-Policy-Änderungen · Admin-A proposed, Admin-B approved';

-- ================================================================================
-- 6 · fact_retention_change_approvals · Audit-Trail 2-Admin-Sign-Offs
-- ================================================================================

CREATE TABLE IF NOT EXISTS ark.fact_retention_change_approvals (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  proposal_id   UUID NOT NULL REFERENCES ark.dim_retention_change_proposals(id),
  approver_id   UUID NOT NULL REFERENCES ark.dim_mitarbeiter(id),
  approved_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  action        TEXT NOT NULL CHECK (action IN ('approve','reject')),
  comment       TEXT,
  UNIQUE (proposal_id, approver_id)
);

COMMENT ON TABLE ark.fact_retention_change_approvals IS
  'v1.4: Append-only Audit-Trail · Retention-Policy-Proposal braucht ≥ 2 distinct approver_id mit action=approve';

-- ================================================================================
-- 7 · fact_template_versions · Template-Historie (Reminder/Email/Notification)
-- ================================================================================

CREATE TABLE IF NOT EXISTS ark.fact_template_versions (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  template_type TEXT NOT NULL CHECK (template_type IN (
                  'reminder','email','notification','document'
                )),
  template_id   UUID NOT NULL,
  version       TEXT NOT NULL,
  archived_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  archived_by   UUID REFERENCES ark.dim_mitarbeiter(id),
  snapshot      JSONB NOT NULL,
  change_reason TEXT
);

CREATE INDEX IF NOT EXISTS idx_template_versions_lookup
  ON ark.fact_template_versions (template_type, template_id, archived_at DESC);

COMMENT ON TABLE ark.fact_template_versions IS
  'v1.4: Append-only Template-Version-Historie · Snapshot bei jedem Minor-Bump';

-- ================================================================================
-- 8 · dim_dsg_requests · DSG-Auskunfts/Löschanfragen
-- ================================================================================

CREATE TABLE IF NOT EXISTS ark.dim_dsg_requests (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  request_type    TEXT NOT NULL CHECK (request_type IN (
                    'auskunft','loeschung','berichtigung','widerspruch','datenportabilitaet'
                  )),
  subject_person  UUID REFERENCES ark.dim_candidates(id),
  subject_email   TEXT,
  received_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
  sla_deadline    TIMESTAMPTZ NOT NULL,
  status          TEXT NOT NULL CHECK (status IN (
                    'open','in_progress','completed','rejected','escalated'
                  )) DEFAULT 'open',
  assignee        UUID REFERENCES ark.dim_mitarbeiter(id),
  notes           TEXT,
  result_document UUID,
  completed_at    TIMESTAMPTZ,
  tenant_id       UUID NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_dsg_requests_status
  ON ark.dim_dsg_requests (status, sla_deadline);

CREATE INDEX IF NOT EXISTS idx_dsg_requests_subject
  ON ark.dim_dsg_requests (subject_person);

COMMENT ON TABLE ark.dim_dsg_requests IS
  'v1.4: DSG Art. 8/25 · SLA-Default 30 Tage ab received_at';

-- SLA-Default-Trigger
CREATE OR REPLACE FUNCTION ark.set_dsg_sla_deadline()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.sla_deadline IS NULL THEN
    NEW.sla_deadline := NEW.received_at + interval '30 days';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_dsg_sla_default
  BEFORE INSERT ON ark.dim_dsg_requests
  FOR EACH ROW EXECUTE FUNCTION ark.set_dsg_sla_deadline();

-- ================================================================================
-- 9 · Settings-Struktur-Wechsel · Fee-Staffel scalar → matrix
-- ================================================================================

UPDATE ark.dim_automation_settings
   SET value_jsonb = jsonb_build_array(
         jsonb_build_object('tc_from', 0,      'tc_to', 120000, 'fee_pct', 22, 'min_fee', 15000),
         jsonb_build_object('tc_from', 120000, 'tc_to', 180000, 'fee_pct', 25, 'min_fee', 25000),
         jsonb_build_object('tc_from', 180000, 'tc_to', 250000, 'fee_pct', 28, 'min_fee', 40000),
         jsonb_build_object('tc_from', 250000, 'tc_to', 400000, 'fee_pct', 30, 'min_fee', 60000),
         jsonb_build_object('tc_from', 400000, 'tc_to', NULL,   'fee_pct', 33, 'min_fee', 100000)
       ),
       value_text = NULL,
       key = 'fee_staffel_erfolgsbasis',
       description = 'v1.4: TC-Band × Fee% Matrix · Fallback wenn Mandat keinen Override hat'
 WHERE key = 'default_fee_pct_erfolgsbasis';

-- Zusatz-Keys Fee-Staffel-Optionen
INSERT INTO ark.dim_automation_settings (key, value_text, description) VALUES
  ('fee_staffel_calc_mode', 'flat_fee_pct_on_total',
   'flat_fee_pct_on_total | progressive | min_fee_floor'),
  ('fee_staffel_tc_definition', 'base_plus_bonus_plus_signing',
   'base_plus_bonus_plus_signing | base_plus_variable | base_only'),
  ('fee_staffel_rounding_chf', '100',
   'Rundung in CHF: 100 | 500 | 1000 | 0')
ON CONFLICT (key) DO NOTHING;

-- ================================================================================
-- 10 · Settings-Struktur-Wechsel · Refund-Staffel 3-csv → 4-block-matrix
-- ================================================================================

UPDATE ark.dim_automation_settings
   SET value_jsonb = jsonb_build_array(
         jsonb_build_object('label','Vor Start','from_day',-9999,'to_day',-1,'refund_pct',100),
         jsonb_build_object('label','1. Monat', 'from_day',0,    'to_day',30, 'refund_pct',50),
         jsonb_build_object('label','2. Monat', 'from_day',31,   'to_day',60, 'refund_pct',25),
         jsonb_build_object('label','3. Monat', 'from_day',61,   'to_day',90, 'refund_pct',10)
       ),
       value_text = NULL,
       description = 'v1.4: 4-Block-Staffel (Vor Start / 1.-3. Monat) · Refund% auf Netto-Fee'
 WHERE key = 'refund_staffel_erfolgsbasis';

-- Zusatz-Keys Refund-Optionen
INSERT INTO ark.dim_automation_settings (key, value_text, description) VALUES
  ('refund_typ', 'gutschrift_naechste_rechnung',
   'gutschrift_naechste_rechnung | rueckueberweisung | kunde_waehlt'),
  ('refund_basis', 'netto_fee',
   'netto_fee | brutto_fee'),
  ('refund_ersatzkandidat_rule', 'optional',
   'optional | vorrang_ersatz | refund_zwingend')
ON CONFLICT (key) DO NOTHING;

-- ================================================================================
-- 11 · Admin-Vollansicht Bulk-Settings (Feature-Flags · Ratenlimits · Schwellen)
-- ================================================================================

INSERT INTO ark.dim_automation_settings (key, value_text, description) VALUES
  -- Ghosting & Stale
  ('ghosting_frist_tage',             '14',     'Tage ohne Antwort bis Prozess-Flag Ghosting'),
  ('stale_prozess_tage',              '21',     'Tage ohne Activity bis Pipeline stale'),
  ('schutzfrist_warn_vorlauf_tage',   '30',     'Vorlauf für Schutzfrist-Warnung/Reminder'),
  ('refresh_frist_monate',            '18',     'Kandidat-Refresh-Schwelle in Monaten'),
  ('checkin_offsets',                 '7,30,90','Post-Placement Check-In-Offsets (csv)'),
  -- Placement
  ('garantiefrist_monate',            '3',      'Default-Garantiefrist'),
  ('schutzfrist_default_mt',          '12',     'Default-Schutzfrist AGB §6'),
  -- Ratenlimits
  ('email_rate_limit_per_user_hour',  '100',    'Max Mails pro User und Stunde'),
  ('scraper_max_concurrent',          '4',      'Max parallele Scraper-Jobs'),
  ('ai_token_budget_daily',           '500000', 'Tenant-AI-Token-Budget pro Tag'),
  -- Feature-Flags
  ('feature_ai_briefing',             'true',   'AI-Briefing-Pipeline Phase 1 Beta'),
  ('feature_matching_v2',             'true',   'Vektor-basiertes Matching v2'),
  ('feature_dokgen_ai',               'true',   'Dok-Generator AI-Draft'),
  ('feature_exec_report_v2',          'false',  'Executive-Report v2 Layout'),
  ('feature_hr_tool',                 'false',  'Phase 2 HR-Tool · locked'),
  ('feature_provisions_v2',           'false',  'Phase 2 Provisions-Engine · locked'),
  -- 3CX Telefonie
  ('3cx_transcription_engine',        'whisper_large_v3',
   'whisper_large_v3 | whisper_medium | deepgram_nova'),
  ('3cx_auto_call_logging',           'true',   'Auto-Erfassung Calls als Activity')
ON CONFLICT (key) DO NOTHING;

-- Falls Lock-Spalte existiert, Phase-2-Features sperren
-- (nur Comment · Production-DB prüft eigene Schema-Version):
--   UPDATE ark.dim_automation_settings SET is_locked = true
--     WHERE key IN ('feature_hr_tool','feature_provisions_v2');

-- ================================================================================
-- 12 · Event-Katalog · event_category CHECK erweitern (admin + audit)
-- ================================================================================

ALTER TABLE ark.dim_event_types
  DROP CONSTRAINT IF EXISTS dim_event_types_event_category_check;

ALTER TABLE ark.dim_event_types
  ADD CONSTRAINT dim_event_types_event_category_check CHECK (event_category IN (
    'lifecycle','interaction','match','status','workflow','guarantee',
    'protection_window','saga','ai','finance','referral','assessment',
    'system','admin','audit'
  ));

-- ================================================================================
-- 13 · Event-Katalog · Admin-Events seeden (31 Rows)
-- ================================================================================

INSERT INTO ark.dim_event_types
  (event_name, event_category, entity_type, emitter_component, create_history, is_automatable)
VALUES
  ('setting.changed',                    'admin',  'system',             'admin-api',               false, false),
  ('automation.rule.created',            'admin',  'automation_rule',    'admin-api',               false, false),
  ('automation.rule.updated',            'admin',  'automation_rule',    'admin-api',               false, false),
  ('automation.rule.paused',             'admin',  'automation_rule',    'admin-api',               false, false),
  ('automation.rule.activated',          'admin',  'automation_rule',    'admin-api',               false, false),
  ('automation.rule.deleted',            'admin',  'automation_rule',    'admin-api',               false, false),
  ('circuit_breaker.tripped',            'system', 'circuit_breaker',    'circuit-breaker-worker',  false, true),
  ('circuit_breaker.reset',              'admin',  'circuit_breaker',    'admin-api',               false, false),
  ('circuit_breaker.half_open',          'system', 'circuit_breaker',    'circuit-breaker-worker',  false, true),
  ('reminder_template.updated',          'admin',  'template',           'admin-api',               false, false),
  ('email_template.updated',             'admin',  'template',           'admin-api',               false, false),
  ('notification_template.updated',      'admin',  'template',           'admin-api',               false, false),
  ('oauth.token.refreshed',              'system', 'oauth_token',        'outlook-sync-worker',     false, true),
  ('oauth.token.expiring',               'system', 'oauth_token',        'oauth-expiry-worker',     false, true),
  ('oauth.token.expired',                'system', 'oauth_token',        'oauth-expiry-worker',     false, true),
  ('codetwo.sync.started',               'system', 'integration',        'codetwo-sync-worker',     false, true),
  ('codetwo.sync.completed',             'system', 'integration',        'codetwo-sync-worker',     false, true),
  ('codetwo.sync.failed',                'system', 'integration',        'codetwo-sync-worker',     false, true),
  ('dashboard_template.widget.added',    'admin',  'dashboard_template', 'admin-api',               false, false),
  ('dashboard_template.widget.removed',  'admin',  'dashboard_template', 'admin-api',               false, false),
  ('dashboard.reset.bulk',               'admin',  'dashboard',          'admin-api',               false, false),
  ('legal_hold.set',                     'audit',  'legal_hold',         'admin-api',               true,  false),
  ('legal_hold.released',                'audit',  'legal_hold',         'admin-api',               true,  false),
  ('retention_policy.proposed',          'audit',  'retention_policy',   'admin-api',               false, false),
  ('retention_policy.approved',          'audit',  'retention_policy',   'admin-api',               true,  false),
  ('retention_policy.rejected',          'audit',  'retention_policy',   'admin-api',               false, false),
  ('retention_policy.changed',           'audit',  'retention_policy',   'admin-api',               true,  false),
  ('dsg_request.created',                'audit',  'dsg_request',        'admin-api',               true,  false),
  ('dsg_request.completed',              'audit',  'dsg_request',        'admin-api',               true,  false),
  ('dsg_request.rejected',               'audit',  'dsg_request',        'admin-api',               false, false),
  ('ignore_rule.hit',                    'system', 'email_ignore_rule',  'email-ingest-worker',     false, true)
ON CONFLICT (event_name) DO NOTHING;

-- ================================================================================
-- 14 · Rollback-Skript (Reference · nicht automatisch ausgeführt)
-- ================================================================================
--
-- BEGIN;
--   DROP TRIGGER IF EXISTS trg_dsg_sla_default ON ark.dim_dsg_requests;
--   DROP FUNCTION IF EXISTS ark.set_dsg_sla_deadline();
--
--   DROP TRIGGER IF EXISTS trg_legal_hold_block_candidates ON ark.dim_candidates;
--   DROP TRIGGER IF EXISTS trg_legal_hold_block_accounts ON ark.dim_accounts;
--   DROP TRIGGER IF EXISTS trg_legal_hold_block_mandates ON ark.dim_mandates;
--   DROP TRIGGER IF EXISTS trg_legal_hold_block_processes ON ark.fact_processes;
--   DROP TRIGGER IF EXISTS trg_legal_hold_block_placements ON ark.fact_placements;
--   DROP FUNCTION IF EXISTS ark.block_if_legal_hold();
--
--   DROP TABLE IF EXISTS ark.dim_dsg_requests;
--   DROP TABLE IF EXISTS ark.fact_template_versions;
--   DROP TABLE IF EXISTS ark.fact_retention_change_approvals;
--   DROP TABLE IF EXISTS ark.dim_retention_change_proposals;
--   DROP TABLE IF EXISTS ark.dim_legal_holds;
--
--   -- Settings rückgängig (Keys einzeln):
--   DELETE FROM ark.dim_automation_settings WHERE key IN (
--     'fee_staffel_calc_mode','fee_staffel_tc_definition','fee_staffel_rounding_chf',
--     'refund_typ','refund_basis','refund_ersatzkandidat_rule',
--     'ghosting_frist_tage','stale_prozess_tage','schutzfrist_warn_vorlauf_tage',
--     'refresh_frist_monate','checkin_offsets','garantiefrist_monate','schutzfrist_default_mt',
--     'email_rate_limit_per_user_hour','scraper_max_concurrent','ai_token_budget_daily',
--     'feature_ai_briefing','feature_matching_v2','feature_dokgen_ai','feature_exec_report_v2',
--     'feature_hr_tool','feature_provisions_v2',
--     '3cx_transcription_engine','3cx_auto_call_logging'
--   );
--
--   -- value_jsonb Spalte bleibt bestehen (könnte von anderen Keys genutzt werden)
--
--   -- fact_audit_log action CHECK zurück auf pre-1.4
--   ALTER TABLE ark.fact_audit_log DROP CONSTRAINT fact_audit_log_action_check;
--   ALTER TABLE ark.fact_audit_log ADD CONSTRAINT fact_audit_log_action_check CHECK (action IN (
--     'CREATE','UPDATE','DELETE','READ','EXPORT','PLACEMENT'
--   ));
--
--   -- Event-Katalog: 31 Admin-Events rückgängig
--   DELETE FROM ark.dim_event_types WHERE event_name IN (
--     'setting.changed','automation.rule.created','automation.rule.updated',
--     'automation.rule.paused','automation.rule.activated','automation.rule.deleted',
--     'circuit_breaker.tripped','circuit_breaker.reset','circuit_breaker.half_open',
--     'reminder_template.updated','email_template.updated','notification_template.updated',
--     'oauth.token.refreshed','oauth.token.expiring','oauth.token.expired',
--     'codetwo.sync.started','codetwo.sync.completed','codetwo.sync.failed',
--     'dashboard_template.widget.added','dashboard_template.widget.removed','dashboard.reset.bulk',
--     'legal_hold.set','legal_hold.released',
--     'retention_policy.proposed','retention_policy.approved','retention_policy.rejected','retention_policy.changed',
--     'dsg_request.created','dsg_request.completed','dsg_request.rejected',
--     'ignore_rule.hit'
--   );
-- COMMIT;

-- ================================================================================
-- COMMIT · Migration 003 fertig
-- ================================================================================

COMMIT;

-- Verifikation (manuell ausführen):
--   SELECT count(*) FROM ark.dim_event_types WHERE event_category IN ('admin','audit');  -- erwartet 31
--   SELECT count(*) FROM ark.dim_automation_settings WHERE key LIKE 'feature_%';         -- erwartet 6
--   SELECT count(*) FROM information_schema.tables
--     WHERE table_schema = 'ark' AND table_name IN (
--       'dim_legal_holds','dim_retention_change_proposals','fact_retention_change_approvals',
--       'fact_template_versions','dim_dsg_requests'
--     );  -- erwartet 5
