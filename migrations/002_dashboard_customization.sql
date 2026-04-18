-- =============================================================================
-- Migration 002 — Dashboard-Customization (v1.4)
-- =============================================================================
-- Scope: Rolle-basierte Dashboard-Templates mit User-Override + Mobile-Responsive
-- Basis-Spec: specs/ARK_DASHBOARD_CUSTOMIZATION_SCHEMA_v1.md
-- Stand:      17.04.2026
-- =============================================================================
-- Änderungen:
--   1. dim_dashboard_widgets        NEW TABLE (Widget-Registry)
--   2. dim_dashboard_role_defaults  NEW TABLE (Rolle-Templates)
--   3. dim_crm_users                +3 Spalten (additional_roles, dashboard_layout_json, active_dashboard_view)
--   4. dim_automation_settings      +3 neue Feature-Flags
--   5. Seed dim_dashboard_widgets   (24 Rows)
--   6. Seed dim_dashboard_role_defaults (~60 Rows: 7 Rollen × ~8 Widgets)
--   7. Validierungs-DO-Blöcke
-- =============================================================================

BEGIN;

-- -----------------------------------------------------------------------------
-- SCHRITT 1: dim_dashboard_widgets — Widget-Registry
-- -----------------------------------------------------------------------------

CREATE TABLE ark.dim_dashboard_widgets (
  id                   uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  widget_key           text UNIQUE NOT NULL,
    -- 'pending-calls', 'to-send-inbox', 'garantie-ablauf-14d', ...
  widget_name          text NOT NULL,
  description          text,
  category             text NOT NULL
    CHECK (category IN ('kpi','triage','alert','analytics','agenda','ops')),
  data_scope           text NOT NULL
    CHECK (data_scope IN ('user','team','sparte','account','global')),
  allowed_roles        text[] NOT NULL DEFAULT '{}',
    -- Welche Rollen dürfen dieses Widget sehen
  default_size         text NOT NULL DEFAULT 'half'
    CHECK (default_size IN ('full','half','third','quarter')),
  mobile_mode          text NOT NULL DEFAULT 'compact'
    CHECK (mobile_mode IN ('full','compact','hidden','link-only')),
  default_sort_order   int NOT NULL DEFAULT 100,
  config_schema        jsonb NULL,
  is_pinnable          boolean NOT NULL DEFAULT true,
    -- false = kann nicht vom User ausgeblendet werden
  endpoint             text NULL,
  websocket_topic      text NULL,
  deprecated_at        timestamptz NULL,
  created_at           timestamptz DEFAULT now()
);

CREATE INDEX idx_widgets_category ON ark.dim_dashboard_widgets(category);
CREATE INDEX idx_widgets_roles ON ark.dim_dashboard_widgets USING gin(allowed_roles);

-- -----------------------------------------------------------------------------
-- SCHRITT 2: dim_dashboard_role_defaults — Rolle-Templates
-- -----------------------------------------------------------------------------

CREATE TABLE ark.dim_dashboard_role_defaults (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       uuid NOT NULL REFERENCES ark.dim_tenants(id),
  role_key        text NOT NULL
    CHECK (role_key IN ('Admin','CM','AM','RA','BO','HoD','Combined')),
  widget_id       uuid NOT NULL REFERENCES ark.dim_dashboard_widgets(id),
  sort_order      int NOT NULL,
  size_override   text NULL
    CHECK (size_override IN ('full','half','third','quarter')),
  config_json     jsonb NULL,
  is_pinned       boolean NOT NULL DEFAULT false,
  created_by      uuid REFERENCES ark.dim_crm_users(id),
  updated_at      timestamptz DEFAULT now(),

  UNIQUE (tenant_id, role_key, widget_id)
);

CREATE INDEX idx_role_defaults_role
  ON ark.dim_dashboard_role_defaults(tenant_id, role_key, sort_order);

-- -----------------------------------------------------------------------------
-- SCHRITT 3: dim_crm_users — User-Override-Spalten
-- -----------------------------------------------------------------------------

ALTER TABLE ark.dim_crm_users
  ADD COLUMN additional_roles text[] DEFAULT '{}',
    -- Haupt-Rolle in .role, zusätzliche in additional_roles
    -- Beispiel: PW → role='Admin', additional_roles=['AM']
  ADD COLUMN dashboard_layout_json jsonb NULL,
    -- User-Override überlagert Rolle-Defaults
  ADD COLUMN active_dashboard_view text NULL
    CHECK (active_dashboard_view IS NULL OR active_dashboard_view IN (
      'Admin','CM','AM','RA','BO','HoD','Combined'
    ));

CREATE INDEX idx_crm_users_additional_roles
  ON ark.dim_crm_users USING gin(additional_roles)
  WHERE additional_roles IS NOT NULL AND array_length(additional_roles, 1) > 0;

-- -----------------------------------------------------------------------------
-- SCHRITT 4: dim_automation_settings — Feature-Flags
-- -----------------------------------------------------------------------------

INSERT INTO ark.dim_automation_settings (key, value_bool, value_int, description) VALUES
  ('dashboard_customization_enabled', true, NULL,
   'v1.4: Master-Feature-Flag Dashboard-Customization. false = Fallback auf hardcoded Default-Layout.'),
  ('dashboard_widget_cache_ttl_seconds', NULL, 60,
   'v1.4: Redis-Cache-TTL pro (user_id, widget_key) für Widget-Daten-Calls'),
  ('dashboard_max_widgets_per_view', NULL, 20,
   'v1.4: Soft-Limit max. Widgets pro Dashboard-View (UI-Performance)');

-- -----------------------------------------------------------------------------
-- SCHRITT 5: Widget-Katalog seeden (24 Rows)
-- -----------------------------------------------------------------------------

-- 5.1 KPI-Widgets (6)
INSERT INTO ark.dim_dashboard_widgets
  (widget_key, widget_name, description, category, data_scope,
   allowed_roles, default_size, mobile_mode, default_sort_order, is_pinnable, endpoint)
VALUES
  ('kpi-umsatz-ytd', 'Umsatz YTD', 'Jahres-Umsatz bis Stichtag',
   'kpi', 'global', ARRAY['Admin','AM','HoD'], 'quarter', 'full', 10, true,
   'GET /api/v1/dashboard/widgets/kpi-umsatz-ytd'),
  ('kpi-placements-ytd', 'Placements YTD', 'Erfolgreiche Placements im aktuellen Jahr',
   'kpi', 'global', ARRAY['Admin','CM','AM','RA','BO','HoD'], 'quarter', 'full', 20, false,
   'GET /api/v1/dashboard/widgets/kpi-placements-ytd'),
  ('kpi-offene-mandate', 'Offene Mandate', 'Aktive Mandate nach Typ',
   'kpi', 'team', ARRAY['Admin','AM'], 'quarter', 'full', 30, true,
   'GET /api/v1/dashboard/widgets/kpi-offene-mandate'),
  ('kpi-aktive-prozesse', 'Aktive Prozesse', 'Laufende Placement-Prozesse',
   'kpi', 'team', ARRAY['Admin','CM','AM','RA','BO','HoD'], 'quarter', 'full', 40, true,
   'GET /api/v1/dashboard/widgets/kpi-aktive-prozesse'),
  ('kpi-blocker-count', 'Blocker-Count', 'Blocker die sofortige Action brauchen',
   'kpi', 'user', ARRAY['Admin','CM','AM','RA','BO','HoD'], 'quarter', 'full', 50, false,
   'GET /api/v1/dashboard/widgets/kpi-blocker-count'),
  ('kpi-system-health', 'System-Health', 'Circuit-Breaker · Dead-Letter · Queue-Lag',
   'kpi', 'global', ARRAY['Admin'], 'quarter', 'hidden', 60, true,
   'GET /api/v1/dashboard/widgets/kpi-system-health');

-- 5.2 Triage-Widgets (3)
INSERT INTO ark.dim_dashboard_widgets
  (widget_key, widget_name, description, category, data_scope,
   allowed_roles, default_size, mobile_mode, default_sort_order, is_pinnable, endpoint, websocket_topic)
VALUES
  ('pending-calls', 'Pending Calls Triage',
   'Unklassifizierte 3CX-Anrufe mit AI-Vorschlag',
   'triage', 'user', ARRAY['AM','CM','Admin'], 'half', 'compact', 100, true,
   'GET /api/v1/dashboard/widgets/pending-calls', 'dashboard.widget.pending-calls'),
  ('pending-emails', 'Pending Emails Triage',
   'Unklassifizierte Outlook/Gmail-Mails ohne Template-Match',
   'triage', 'user', ARRAY['AM','CM','Admin'], 'half', 'compact', 110, true,
   'GET /api/v1/dashboard/widgets/pending-emails', 'dashboard.widget.pending-emails'),
  ('to-send-inbox', 'To-Send-Inbox · CV-Versand',
   'Kandidaten-Dossiers bereit zum Versand · AGB-Check + Dokumenten-Vollständigkeit',
   'triage', 'user', ARRAY['AM','CM'], 'full', 'compact', 120, true,
   'GET /api/v1/dashboard/widgets/to-send-inbox', 'dashboard.widget.to-send-inbox');

-- 5.3 Alert-Widgets (5)
INSERT INTO ark.dim_dashboard_widgets
  (widget_key, widget_name, description, category, data_scope,
   allowed_roles, default_size, mobile_mode, default_sort_order, is_pinnable, endpoint)
VALUES
  ('garantie-ablauf-14d', 'Garantie-Ablauf 14 Tage',
   'Placements mit Garantiefrist-Ende innerhalb 14 Tagen',
   'alert', 'team', ARRAY['CM','AM','Admin'], 'half', 'link-only', 200, false,
   'GET /api/v1/dashboard/widgets/garantie-ablauf-14d'),
  ('stale-prozesse', 'Stale-Prozesse-Triage',
   'Prozesse mit überschrittener Stage-Alter-Schwelle',
   'alert', 'user', ARRAY['CM','AM','Admin'], 'half', 'compact', 210, false,
   'GET /api/v1/dashboard/widgets/stale-prozesse'),
  ('agb-pending', 'AGB-Pending Alert',
   'Erfolgsbasis-Accounts mit versandtem CV aber ohne AGB-Bestätigung',
   'alert', 'account', ARRAY['AM','Admin'], 'third', 'link-only', 220, false,
   'GET /api/v1/dashboard/widgets/agb-pending'),
  ('claim-faelle-offen', 'Claim-Fälle offen',
   'Direkteinstellungs-Schutzfrist-Matches mit offenem Claim-Workflow',
   'alert', 'account', ARRAY['AM','Admin'], 'third', 'link-only', 230, false,
   'GET /api/v1/dashboard/widgets/claim-faelle-offen'),
  ('scraper-review-queue', 'Scraper-Findings Review',
   'LinkedIn-Scraper-Queue pending Review durch AM/RA',
   'alert', 'account', ARRAY['AM','RA','Admin'], 'half', 'compact', 240, false,
   'GET /api/v1/dashboard/widgets/scraper-review-queue');

-- 5.4 Ops-Widgets (3)
INSERT INTO ark.dim_dashboard_widgets
  (widget_key, widget_name, description, category, data_scope,
   allowed_roles, default_size, mobile_mode, default_sort_order, is_pinnable, endpoint)
VALUES
  ('meine-reminders', 'Meine überfälligen Reminders',
   'User-spezifische Reminder-Liste mit Drill-Down · mehr als nur Badge-Count',
   'ops', 'user', ARRAY['Admin','CM','AM','RA','BO','HoD'], 'half', 'full', 300, false,
   'GET /api/v1/dashboard/widgets/meine-reminders'),
  ('team-workload', 'Team-Workload-Tabelle',
   'Workload-Verteilung über Mitarbeiter · Mandate/Prozesse/Last',
   'ops', 'team', ARRAY['Admin','HoD'], 'half', 'hidden', 310, false,
   'GET /api/v1/dashboard/widgets/team-workload'),
  ('activity-feed-24h', 'Activity-Feed (24h)',
   'Team-Aktivität der letzten 24 Stunden · System + User-Events',
   'ops', 'team', ARRAY['Admin','HoD'], 'full', 'link-only', 320, false,
   'GET /api/v1/dashboard/widgets/activity-feed-24h');

-- 5.5 Analytics-Widgets (5)
INSERT INTO ark.dim_dashboard_widgets
  (widget_key, widget_name, description, category, data_scope,
   allowed_roles, default_size, mobile_mode, default_sort_order, is_pinnable, endpoint)
VALUES
  ('pipeline-snapshot', 'Pipeline-Snapshot',
   'Übersicht Late-Stage / Offer / Stale-Prozesse + Prognose',
   'analytics', 'team', ARRAY['Admin','CM','HoD'], 'half', 'compact', 400, false,
   'GET /api/v1/dashboard/widgets/pipeline-snapshot'),
  ('time-to-fill-trend', 'Time-to-Fill-Trend',
   'Pipeline-Velocity pro Stage · 6-Monats-Sparkline',
   'analytics', 'team', ARRAY['HoD','Admin'], 'half', 'hidden', 410, false,
   'GET /api/v1/dashboard/widgets/time-to-fill-trend'),
  ('placement-rate-sparte', 'Placement-Rate nach Sparte',
   'YTD-Placements aufgeschlüsselt nach ARC/GT/ING/PUR/REM',
   'analytics', 'sparte', ARRAY['Admin','HoD'], 'half', 'hidden', 420, false,
   'GET /api/v1/dashboard/widgets/placement-rate-sparte'),
  ('honorar-cashflow', 'Honorar-Cashflow-Prognose',
   'Q2 realisiert vs in-Abwicklung vs pending vs at-Risk',
   'analytics', 'global', ARRAY['Admin','AM','BO'], 'half', 'hidden', 430, false,
   'GET /api/v1/dashboard/widgets/honorar-cashflow'),
  ('jobbasket-gate-backlog', 'Jobbasket-Gate-Backlog',
   'Mini-Pipeline Prelead → Oral GO → Written GO → Assigned → To-Send',
   'analytics', 'team', ARRAY['CM','AM','Admin'], 'third', 'compact', 440, false,
   'GET /api/v1/dashboard/widgets/jobbasket-gate-backlog');

-- 5.6 Agenda-Widgets (2)
INSERT INTO ark.dim_dashboard_widgets
  (widget_key, widget_name, description, category, data_scope,
   allowed_roles, default_size, mobile_mode, default_sort_order, is_pinnable, endpoint)
VALUES
  ('heute-agenda', 'Heute · Agenda',
   'Termine + Calls + Meetings heute · Teams-Integration',
   'agenda', 'user', ARRAY['Admin','CM','AM','RA','BO','HoD'], 'half', 'full', 500, false,
   'GET /api/v1/dashboard/widgets/heute-agenda'),
  ('mein-fokus-woche', 'Mein Fokus diese Woche',
   'Manueller Fokus-Block mit Zielen der Woche',
   'agenda', 'user', ARRAY['Admin','CM','AM','RA','BO','HoD'], 'half', 'full', 510, false,
   'GET /api/v1/dashboard/widgets/mein-fokus-woche');

-- Optional: Bounce-Alert (v1.4 Ergänzung)
INSERT INTO ark.dim_dashboard_widgets
  (widget_key, widget_name, description, category, data_scope,
   allowed_roles, default_size, mobile_mode, default_sort_order, is_pinnable, endpoint)
VALUES
  ('bounce-alert', 'Bounce-Adressen Alert',
   'Email-Bounces der letzten Woche · Adress-Pflege-Hinweis',
   'alert', 'global', ARRAY['AM','CM','Admin'], 'third', 'hidden', 250, false,
   'GET /api/v1/dashboard/widgets/bounce-alert');

-- 5.7 Spezial-Widgets (3) — RA/AM/BO-spezifisch (v1.4 Nachtrag)
INSERT INTO ark.dim_dashboard_widgets
  (widget_key, widget_name, description, category, data_scope,
   allowed_roles, default_size, mobile_mode, default_sort_order, is_pinnable, endpoint)
VALUES
  ('longlist-research-backlog', 'Longlist-Research-Backlog',
   'Mandate mit offenem Research-Auftrag · Longlist-Ziel vs. aktueller Stand · SLA für unassigned Research',
   'ops', 'user', ARRAY['RA','Admin','HoD'], 'half', 'compact', 330, false,
   'GET /api/v1/dashboard/widgets/longlist-research-backlog'),
  ('mandats-offerten-conversion', 'Mandats-Offerten-Conversion',
   'Funnel Erstgespräch → Offerte → Verhandlung → Unterschrieben → Aktiv · Hit-Rate YTD',
   'analytics', 'team', ARRAY['AM','HoD','Admin'], 'half', 'hidden', 450, false,
   'GET /api/v1/dashboard/widgets/mandats-offerten-conversion'),
  ('assessment-credits-expiring', 'Assessment-Credits ablaufen',
   'Aufträge mit bald ablaufenden oder kaum genutzten Credits · Nachbestell-Trigger',
   'alert', 'account', ARRAY['BO','CM','AM','Admin'], 'third', 'link-only', 260, false,
   'GET /api/v1/dashboard/widgets/assessment-credits-expiring');

-- -----------------------------------------------------------------------------
-- SCHRITT 6: Rolle-Defaults seeden (~60 Rows: 6 Rollen × ~8-18 Widgets)
-- -----------------------------------------------------------------------------

-- Hilfs-Variable für default tenant_id (Produktion: pro Tenant wiederholen)
DO $$
DECLARE
  t_id uuid;
BEGIN
  SELECT id INTO t_id FROM ark.dim_tenants LIMIT 1;
  IF t_id IS NULL THEN
    RAISE EXCEPTION 'Kein Tenant gefunden — Migration bricht ab.';
  END IF;

  -- ========== CM (Candidate Manager) Template (10 Widgets) ==========
  INSERT INTO ark.dim_dashboard_role_defaults (tenant_id, role_key, widget_id, sort_order, is_pinned) VALUES
    (t_id, 'CM', (SELECT id FROM ark.dim_dashboard_widgets WHERE widget_key = 'kpi-blocker-count'), 0, true),
    (t_id, 'CM', (SELECT id FROM ark.dim_dashboard_widgets WHERE widget_key = 'kpi-aktive-prozesse'), 10, false),
    (t_id, 'CM', (SELECT id FROM ark.dim_dashboard_widgets WHERE widget_key = 'kpi-placements-ytd'), 20, false),
    (t_id, 'CM', (SELECT id FROM ark.dim_dashboard_widgets WHERE widget_key = 'kpi-umsatz-ytd'), 30, false),
    (t_id, 'CM', (SELECT id FROM ark.dim_dashboard_widgets WHERE widget_key = 'pending-calls'), 100, true),
    (t_id, 'CM', (SELECT id FROM ark.dim_dashboard_widgets WHERE widget_key = 'pending-emails'), 110, true),
    (t_id, 'CM', (SELECT id FROM ark.dim_dashboard_widgets WHERE widget_key = 'meine-reminders'), 200, false),
    (t_id, 'CM', (SELECT id FROM ark.dim_dashboard_widgets WHERE widget_key = 'stale-prozesse'), 210, false),
    (t_id, 'CM', (SELECT id FROM ark.dim_dashboard_widgets WHERE widget_key = 'heute-agenda'), 300, false),
    (t_id, 'CM', (SELECT id FROM ark.dim_dashboard_widgets WHERE widget_key = 'garantie-ablauf-14d'), 310, false),
    (t_id, 'CM', (SELECT id FROM ark.dim_dashboard_widgets WHERE widget_key = 'jobbasket-gate-backlog'), 400, false),
    (t_id, 'CM', (SELECT id FROM ark.dim_dashboard_widgets WHERE widget_key = 'pipeline-snapshot'), 410, false);

  -- ========== AM (Account Manager) Template (11 Widgets) ==========
  INSERT INTO ark.dim_dashboard_role_defaults (tenant_id, role_key, widget_id, sort_order, is_pinned) VALUES
    (t_id, 'AM', (SELECT id FROM ark.dim_dashboard_widgets WHERE widget_key = 'kpi-umsatz-ytd'), 0, false),
    (t_id, 'AM', (SELECT id FROM ark.dim_dashboard_widgets WHERE widget_key = 'kpi-placements-ytd'), 10, false),
    (t_id, 'AM', (SELECT id FROM ark.dim_dashboard_widgets WHERE widget_key = 'kpi-offene-mandate'), 20, false),
    (t_id, 'AM', (SELECT id FROM ark.dim_dashboard_widgets WHERE widget_key = 'kpi-blocker-count'), 30, true),
    (t_id, 'AM', (SELECT id FROM ark.dim_dashboard_widgets WHERE widget_key = 'to-send-inbox'), 100, true),
    (t_id, 'AM', (SELECT id FROM ark.dim_dashboard_widgets WHERE widget_key = 'pending-emails'), 110, false),
    (t_id, 'AM', (SELECT id FROM ark.dim_dashboard_widgets WHERE widget_key = 'agb-pending'), 200, true),
    (t_id, 'AM', (SELECT id FROM ark.dim_dashboard_widgets WHERE widget_key = 'claim-faelle-offen'), 210, false),
    (t_id, 'AM', (SELECT id FROM ark.dim_dashboard_widgets WHERE widget_key = 'scraper-review-queue'), 220, false),
    (t_id, 'AM', (SELECT id FROM ark.dim_dashboard_widgets WHERE widget_key = 'heute-agenda'), 300, false),
    (t_id, 'AM', (SELECT id FROM ark.dim_dashboard_widgets WHERE widget_key = 'garantie-ablauf-14d'), 310, false),
    (t_id, 'AM', (SELECT id FROM ark.dim_dashboard_widgets WHERE widget_key = 'honorar-cashflow'), 400, false),
    (t_id, 'AM', (SELECT id FROM ark.dim_dashboard_widgets WHERE widget_key = 'mandats-offerten-conversion'), 410, false),
    (t_id, 'AM', (SELECT id FROM ark.dim_dashboard_widgets WHERE widget_key = 'assessment-credits-expiring'), 250, false);

  -- ========== Admin Template (18 Widgets — Union ehemals Admin + Founder) ==========
  INSERT INTO ark.dim_dashboard_role_defaults (tenant_id, role_key, widget_id, sort_order, is_pinned) VALUES
    (t_id, 'Admin', (SELECT id FROM ark.dim_dashboard_widgets WHERE widget_key = 'kpi-umsatz-ytd'), 0, true),
    (t_id, 'Admin', (SELECT id FROM ark.dim_dashboard_widgets WHERE widget_key = 'kpi-placements-ytd'), 10, true),
    (t_id, 'Admin', (SELECT id FROM ark.dim_dashboard_widgets WHERE widget_key = 'kpi-offene-mandate'), 20, false),
    (t_id, 'Admin', (SELECT id FROM ark.dim_dashboard_widgets WHERE widget_key = 'kpi-blocker-count'), 30, true),
    (t_id, 'Admin', (SELECT id FROM ark.dim_dashboard_widgets WHERE widget_key = 'kpi-system-health'), 40, true),
    (t_id, 'Admin', (SELECT id FROM ark.dim_dashboard_widgets WHERE widget_key = 'team-workload'), 100, true),
    (t_id, 'Admin', (SELECT id FROM ark.dim_dashboard_widgets WHERE widget_key = 'claim-faelle-offen'), 110, true),
    (t_id, 'Admin', (SELECT id FROM ark.dim_dashboard_widgets WHERE widget_key = 'scraper-review-queue'), 120, false),
    (t_id, 'Admin', (SELECT id FROM ark.dim_dashboard_widgets WHERE widget_key = 'garantie-ablauf-14d'), 210, false),
    (t_id, 'Admin', (SELECT id FROM ark.dim_dashboard_widgets WHERE widget_key = 'agb-pending'), 220, false),
    (t_id, 'Admin', (SELECT id FROM ark.dim_dashboard_widgets WHERE widget_key = 'pipeline-snapshot'), 230, false),
    (t_id, 'Admin', (SELECT id FROM ark.dim_dashboard_widgets WHERE widget_key = 'to-send-inbox'), 240, false),
    (t_id, 'Admin', (SELECT id FROM ark.dim_dashboard_widgets WHERE widget_key = 'heute-agenda'), 300, false),
    (t_id, 'Admin', (SELECT id FROM ark.dim_dashboard_widgets WHERE widget_key = 'meine-reminders'), 310, false),
    (t_id, 'Admin', (SELECT id FROM ark.dim_dashboard_widgets WHERE widget_key = 'honorar-cashflow'), 400, false),
    (t_id, 'Admin', (SELECT id FROM ark.dim_dashboard_widgets WHERE widget_key = 'time-to-fill-trend'), 410, false),
    (t_id, 'Admin', (SELECT id FROM ark.dim_dashboard_widgets WHERE widget_key = 'placement-rate-sparte'), 420, false),
    (t_id, 'Admin', (SELECT id FROM ark.dim_dashboard_widgets WHERE widget_key = 'activity-feed-24h'), 500, false);

  -- ========== RA (Research Analyst) Template (9 Widgets) — v1.4 Nachtrag ==========
  INSERT INTO ark.dim_dashboard_role_defaults (tenant_id, role_key, widget_id, sort_order, is_pinned) VALUES
    (t_id, 'RA', (SELECT id FROM ark.dim_dashboard_widgets WHERE widget_key = 'kpi-aktive-prozesse'), 0, false),
    (t_id, 'RA', (SELECT id FROM ark.dim_dashboard_widgets WHERE widget_key = 'kpi-placements-ytd'), 10, false),
    (t_id, 'RA', (SELECT id FROM ark.dim_dashboard_widgets WHERE widget_key = 'kpi-blocker-count'), 20, true),
    (t_id, 'RA', (SELECT id FROM ark.dim_dashboard_widgets WHERE widget_key = 'longlist-research-backlog'), 50, true),
    (t_id, 'RA', (SELECT id FROM ark.dim_dashboard_widgets WHERE widget_key = 'scraper-review-queue'), 100, true),
    (t_id, 'RA', (SELECT id FROM ark.dim_dashboard_widgets WHERE widget_key = 'meine-reminders'), 200, false),
    (t_id, 'RA', (SELECT id FROM ark.dim_dashboard_widgets WHERE widget_key = 'heute-agenda'), 300, false),
    (t_id, 'RA', (SELECT id FROM ark.dim_dashboard_widgets WHERE widget_key = 'pipeline-snapshot'), 400, false);

  -- ========== BO (Backoffice) Template (8 Widgets) — v1.4 Nachtrag ==========
  INSERT INTO ark.dim_dashboard_role_defaults (tenant_id, role_key, widget_id, sort_order, is_pinned) VALUES
    (t_id, 'BO', (SELECT id FROM ark.dim_dashboard_widgets WHERE widget_key = 'kpi-umsatz-ytd'), 0, false),
    (t_id, 'BO', (SELECT id FROM ark.dim_dashboard_widgets WHERE widget_key = 'kpi-blocker-count'), 10, true),
    (t_id, 'BO', (SELECT id FROM ark.dim_dashboard_widgets WHERE widget_key = 'assessment-credits-expiring'), 90, true),
    (t_id, 'BO', (SELECT id FROM ark.dim_dashboard_widgets WHERE widget_key = 'agb-pending'), 100, true),
    (t_id, 'BO', (SELECT id FROM ark.dim_dashboard_widgets WHERE widget_key = 'honorar-cashflow'), 200, true),
    (t_id, 'BO', (SELECT id FROM ark.dim_dashboard_widgets WHERE widget_key = 'meine-reminders'), 300, false),
    (t_id, 'BO', (SELECT id FROM ark.dim_dashboard_widgets WHERE widget_key = 'heute-agenda'), 310, false);

  -- ========== HoD (Head of Sparte) Template (10 Widgets) ==========
  INSERT INTO ark.dim_dashboard_role_defaults (tenant_id, role_key, widget_id, sort_order, is_pinned) VALUES
    (t_id, 'HoD', (SELECT id FROM ark.dim_dashboard_widgets WHERE widget_key = 'kpi-placements-ytd'), 0, true),
    (t_id, 'HoD', (SELECT id FROM ark.dim_dashboard_widgets WHERE widget_key = 'kpi-umsatz-ytd'), 10, false),
    (t_id, 'HoD', (SELECT id FROM ark.dim_dashboard_widgets WHERE widget_key = 'placement-rate-sparte'), 20, true),
    (t_id, 'HoD', (SELECT id FROM ark.dim_dashboard_widgets WHERE widget_key = 'kpi-blocker-count'), 30, true),
    (t_id, 'HoD', (SELECT id FROM ark.dim_dashboard_widgets WHERE widget_key = 'team-workload'), 100, false),
    (t_id, 'HoD', (SELECT id FROM ark.dim_dashboard_widgets WHERE widget_key = 'pipeline-snapshot'), 110, false),
    (t_id, 'HoD', (SELECT id FROM ark.dim_dashboard_widgets WHERE widget_key = 'time-to-fill-trend'), 200, false),
    (t_id, 'HoD', (SELECT id FROM ark.dim_dashboard_widgets WHERE widget_key = 'honorar-cashflow'), 210, false),
    (t_id, 'HoD', (SELECT id FROM ark.dim_dashboard_widgets WHERE widget_key = 'stale-prozesse'), 300, false),
    (t_id, 'HoD', (SELECT id FROM ark.dim_dashboard_widgets WHERE widget_key = 'garantie-ablauf-14d'), 310, false),
    (t_id, 'HoD', (SELECT id FROM ark.dim_dashboard_widgets WHERE widget_key = 'activity-feed-24h'), 500, false);

END $$;

-- -----------------------------------------------------------------------------
-- SCHRITT 7: Validierungs-Queries (post-migration Check)
-- -----------------------------------------------------------------------------

-- 7a. 24 Widgets im Katalog
DO $$
DECLARE
  widget_count int;
BEGIN
  SELECT COUNT(*) INTO widget_count FROM ark.dim_dashboard_widgets;
  IF widget_count <> 27 THEN
    RAISE EXCEPTION 'Migration-Failure: % Widgets im Katalog (erwartet 27 — 24 Haupt + 3 Spezial RA/AM/BO)', widget_count;
  END IF;
END $$;

-- 7b. 6 Rollen mit Templates gefüllt
DO $$
DECLARE
  role_count int;
BEGIN
  SELECT COUNT(DISTINCT role_key) INTO role_count FROM ark.dim_dashboard_role_defaults;
  IF role_count <> 6 THEN
    RAISE EXCEPTION 'Migration-Failure: % Rollen mit Templates (erwartet 6: CM/AM/Admin/RA/BO/HoD)', role_count;
  END IF;
END $$;

-- 7c. Kein allowed_roles-Widget ohne passende Rolle-Default
DO $$
DECLARE
  orphan_count int;
BEGIN
  SELECT COUNT(*) INTO orphan_count
  FROM ark.dim_dashboard_widgets w
  WHERE NOT EXISTS (
    SELECT 1 FROM ark.dim_dashboard_role_defaults d
    WHERE d.widget_id = w.id
  );
  IF orphan_count > 0 THEN
    RAISE WARNING 'Migration-Warning: % Widgets ohne Rolle-Default-Verwendung (möglicherweise OK für Opt-In-Widgets)', orphan_count;
  END IF;
END $$;

-- 7d. Alle pinned-Widgets sind `is_pinnable=true` im Katalog
DO $$
DECLARE
  bad_count int;
BEGIN
  SELECT COUNT(*) INTO bad_count
  FROM ark.dim_dashboard_role_defaults d
  JOIN ark.dim_dashboard_widgets w ON w.id = d.widget_id
  WHERE d.is_pinned = true AND w.is_pinnable = false;
  IF bad_count > 0 THEN
    RAISE EXCEPTION 'Migration-Failure: % Rolle-Defaults haben is_pinned=true für nicht-pinbare Widgets', bad_count;
  END IF;
END $$;

-- 7e. Jede Rolle hat mindestens KPI-Strip-Äquivalent + 1 Operations-Widget
DO $$
DECLARE
  role_name text;
  kpi_count int;
BEGIN
  FOREACH role_name IN ARRAY ARRAY['CM','AM','Admin','RA','BO','HoD'] LOOP
    SELECT COUNT(*) INTO kpi_count
    FROM ark.dim_dashboard_role_defaults d
    JOIN ark.dim_dashboard_widgets w ON w.id = d.widget_id
    WHERE d.role_key = role_name AND w.category = 'kpi';
    IF kpi_count < 2 THEN
      RAISE WARNING 'Migration-Warning: Rolle % hat nur % KPI-Widgets (empfohlen >= 2)', role_name, kpi_count;
    END IF;
  END LOOP;
END $$;

COMMIT;

-- =============================================================================
-- BACKFILL (optional · separates Script wenn User bereits existieren)
-- =============================================================================
-- BEGIN;
--
-- -- Setze active_dashboard_view auf role für alle bestehenden User ohne Override
-- UPDATE ark.dim_crm_users
--   SET active_dashboard_view = role
--   WHERE active_dashboard_view IS NULL
--     AND role IS NOT NULL
--     AND dashboard_layout_json IS NULL;
--
-- -- Demo-Doppelrollen (Beispiel: PW = Admin + AM)
-- UPDATE ark.dim_crm_users
--   SET additional_roles = ARRAY['AM']
--   WHERE email = 'peter.wiederkehr@arkadium.ch';
--
-- COMMIT;

-- =============================================================================
-- DOWN-MIGRATION (Rollback) — Referenz, separates Script
-- =============================================================================
-- BEGIN;
-- ALTER TABLE ark.dim_crm_users
--   DROP COLUMN additional_roles,
--   DROP COLUMN dashboard_layout_json,
--   DROP COLUMN active_dashboard_view;
-- DROP TABLE ark.dim_dashboard_role_defaults;
-- DROP TABLE ark.dim_dashboard_widgets;
-- DELETE FROM ark.dim_automation_settings WHERE key IN (
--   'dashboard_customization_enabled',
--   'dashboard_widget_cache_ttl_seconds',
--   'dashboard_max_widgets_per_view'
-- );
-- COMMIT;
-- =============================================================================

-- =============================================================================
-- Notes
-- =============================================================================
-- 1. Bei Multi-Tenant-Setups: Seed-Block in DO $$ Section pro Tenant wiederholen.
-- 2. Widget-Endpoints (Spalte `endpoint`) sind Backend-Referenzen, keine echten URLs —
--    dienen als Auto-Discovery-Hilfe für das Frontend.
-- 3. `websocket_topic` gesetzt nur für Triage-Widgets (Live-Updates sinnvoll).
--    KPI/Analytics-Widgets: Pull via Interval + Redis-Cache reicht.
-- 4. Nach Deployment: Frontend-Feature-Flag-Check via `GET /api/v1/settings/public`
--    → Fallback auf hardcoded Layout wenn `dashboard_customization_enabled=false`.
-- =============================================================================
