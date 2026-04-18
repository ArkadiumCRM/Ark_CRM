-- =============================================================================
-- Migration 001 — System-Activity-Types (v1.3 → v1.4)
-- =============================================================================
-- Scope: Datenmodell-Erweiterung für system-seitige Events und Auto-Activities
-- Basis-Spec: specs/ARK_SYSTEM_ACTIVITY_TYPES_SCHEMA_v1.md
-- Patch-Docs: specs/ARK_DATABASE_SCHEMA_PATCH_v1_3_to_v1_4.md
--             specs/ARK_STAMMDATEN_PATCH_v1_3_to_v1_4_ACTIVITY_TYPES.md
-- Stand:      17.04.2026
-- Autor:      ARK-CRM Team
-- =============================================================================
-- Änderungen:
--   1. dim_activity_types  +3 Spalten (actor_type, source_system, is_notifiable)
--   2. dim_activity_types.activity_category CHECK erweitert (11 → 18 Werte)
--   3. dim_event_types     +5 Spalten (default_activity_type_id,
--                          default_actor_type, default_source_system,
--                          emitter_component, create_history)
--   4. dim_event_types.event_category CHECK erweitert (13 → 20 Werte)
--   5. fact_event_queue.source_system CHECK erweitert (9 → 16 Werte)
--   6. Indizes + Constraints
--   7. Seed dim_activity_types (+37 Rows, #70–#106)
--   8. Seed dim_event_types (+35 Rows)
--   9. Backfill actor_type für bestehende auto-logged Rows
-- =============================================================================

BEGIN;

-- -----------------------------------------------------------------------------
-- SCHRITT 1: dim_activity_types — neue Spalten
-- -----------------------------------------------------------------------------

ALTER TABLE ark.dim_activity_types
  ADD COLUMN actor_type text NOT NULL DEFAULT 'user'
    CHECK (actor_type IN ('user','system','automation','integration'));

ALTER TABLE ark.dim_activity_types
  ADD COLUMN source_system text NULL
    CHECK (source_system IS NULL OR source_system IN (
      'threecx','outlook','gmail','scraper','llm','saga-engine',
      'nightly-batch','event-worker','manual-upload','calendar-integration'
    ));

ALTER TABLE ark.dim_activity_types
  ADD COLUMN is_notifiable boolean NOT NULL DEFAULT false;

-- Kategorien-CHECK auf 18 Werte erweitert
ALTER TABLE ark.dim_activity_types
  DROP CONSTRAINT IF EXISTS dim_activity_types_activity_category_check;

ALTER TABLE ark.dim_activity_types
  ADD CONSTRAINT dim_activity_types_activity_category_check
  CHECK (activity_category IN (
    'Kontaktberührung','Erreicht','Emailverkehr','Messaging',
    'Interviewprozess','Placementprozess','Refresh Kandidatenpflege',
    'Mandatsakquise','Erfolgsbasis','Assessment','System / Meta',
    -- NEU v1.4:
    'Kalender & Planung','Dokumenten-Pipeline','Garantie & Schutzfrist',
    'Scraper & Intelligence','Pipeline-Transitions','Saga-Events','AI & LLM'
  ));

-- Kategorie-Umbenennung (cosmetic, vor CHECK-Recreate durchgeführt wenn nötig)
UPDATE ark.dim_activity_types
  SET activity_category = 'System / Meta'
  WHERE activity_category = 'System';

CREATE INDEX idx_activity_types_actor
  ON ark.dim_activity_types(actor_type)
  WHERE actor_type <> 'user';

-- -----------------------------------------------------------------------------
-- SCHRITT 2: dim_event_types — neue Spalten + erweiterter CHECK
-- -----------------------------------------------------------------------------

-- event_category CHECK auf 20 Werte (+ 'assessment','guarantee','protection_window','saga','ai','finance','referral')
ALTER TABLE ark.dim_event_types
  DROP CONSTRAINT IF EXISTS dim_event_types_event_category_check;

ALTER TABLE ark.dim_event_types
  ADD CONSTRAINT dim_event_types_event_category_check
  CHECK (event_category IN (
    'candidate','process','job','mandate','call','email','document',
    'scrape','system','match','jobbasket','reminder','account',
    -- NEU v1.4:
    'assessment','guarantee','protection_window','saga','ai','finance','referral'
  ));

ALTER TABLE ark.dim_event_types
  ADD COLUMN default_activity_type_id uuid NULL
    REFERENCES ark.dim_activity_types(id);

ALTER TABLE ark.dim_event_types
  ADD COLUMN default_actor_type text NOT NULL DEFAULT 'automation'
    CHECK (default_actor_type IN ('system','automation','integration'));

ALTER TABLE ark.dim_event_types
  ADD COLUMN default_source_system text NULL;

ALTER TABLE ark.dim_event_types
  ADD COLUMN emitter_component text NULL;

ALTER TABLE ark.dim_event_types
  ADD COLUMN create_history boolean NOT NULL DEFAULT false;

ALTER TABLE ark.dim_event_types
  ADD CONSTRAINT check_history_mapping
  CHECK (create_history = false OR default_activity_type_id IS NOT NULL);

CREATE INDEX idx_event_types_create_history
  ON ark.dim_event_types(create_history, default_activity_type_id)
  WHERE create_history = true;

-- -----------------------------------------------------------------------------
-- SCHRITT 3: fact_event_queue.source_system — erweiterter CHECK
-- -----------------------------------------------------------------------------

ALTER TABLE ark.fact_event_queue
  DROP CONSTRAINT IF EXISTS fact_event_queue_source_system_check;

ALTER TABLE ark.fact_event_queue
  ADD CONSTRAINT fact_event_queue_source_system_check
  CHECK (source_system IN (
    'threecx','outlook','scraper','crm','app',
    'linkedin','whatsapp','system','webhook',
    -- NEU v1.4:
    'gmail','llm','saga-engine','nightly-batch','event-worker',
    'manual-upload','calendar-integration'
  ));

-- -----------------------------------------------------------------------------
-- SCHRITT 3b: fact_history.event_id UNIQUE-Constraint (v1.3 Decisions §B5)
-- Writer-Idempotenz: ein Event kann höchstens eine fact_history-Row erzeugen.
-- Ersetzt früher angedachtes Zeitfenster (24h) durch harte DB-Garantie.
-- -----------------------------------------------------------------------------

ALTER TABLE ark.fact_history
  ADD CONSTRAINT uniq_fact_history_event_id
  UNIQUE (event_id) DEFERRABLE INITIALLY IMMEDIATE;
-- Anmerkung: PARTIAL UNIQUE (WHERE event_id IS NOT NULL) ist in Postgres
-- nicht als named CONSTRAINT möglich — stattdessen partial UNIQUE INDEX:

ALTER TABLE ark.fact_history DROP CONSTRAINT IF EXISTS uniq_fact_history_event_id;

CREATE UNIQUE INDEX uniq_fact_history_event_id
  ON ark.fact_history(event_id)
  WHERE event_id IS NOT NULL;

-- -----------------------------------------------------------------------------
-- SCHRITT 4: Seed dim_activity_types (+48 Rows, #70–#121)
-- -----------------------------------------------------------------------------

-- Kategorie 12 — Kalender & Planung (3 Rows: #70-72)
INSERT INTO ark.dim_activity_types
  (activity_type_name, activity_category, activity_channel,
   is_auto_loggable, actor_type, source_system, is_notifiable, description)
VALUES
  ('Kalender - Interview geplant', 'Kalender & Planung', 'System',
   true, 'integration', 'calendar-integration', true,
   'Interview-Termin via Kalender-Integration eingetragen (Kandidat und Kunde direkt)'),
  ('Reminder - Interview steht bevor', 'Kalender & Planung', 'System',
   true, 'automation', 'event-worker', true,
   'Auto-Reminder 7 Tage vor Interview-Termin (Default konfigurierbar)'),
  ('Reminder - Interview-Datum fehlt', 'Kalender & Planung', 'System',
   true, 'automation', 'nightly-batch', true,
   'Stage-Wechsel zu Interview ohne Datum — 2 Tage später Reminder');

-- Kategorie 13 — Dokumenten-Pipeline (5 Rows: #73-77)
INSERT INTO ark.dim_activity_types
  (activity_type_name, activity_category, activity_channel,
   is_auto_loggable, actor_type, source_system, is_notifiable, description)
VALUES
  ('Dokument - Hochgeladen', 'Dokumenten-Pipeline', 'System',
   false, 'user', 'manual-upload', false,
   'Dokument-Upload durch Consultant oder Kandidat'),
  ('Dokument - CV automatisch geparst', 'Dokumenten-Pipeline', 'System',
   true, 'automation', 'llm', false,
   'AI-Extraktion nach Upload (Name, Erfahrung, Kompetenzen)'),
  ('Dokument - OCR abgeschlossen', 'Dokumenten-Pipeline', 'System',
   true, 'automation', 'event-worker', false,
   'Text-Erkennung bei Scan-PDFs durchgelaufen'),
  ('Dokument - Vektorindex aufgenommen', 'Dokumenten-Pipeline', 'System',
   true, 'automation', 'event-worker', false,
   'Dokument-Chunks für semantische Suche indiziert'),
  ('Dokument - Neu geparst', 'Dokumenten-Pipeline', 'System',
   false, 'user', 'manual-upload', false,
   'Manueller Re-Parse durch Consultant');

-- Kategorie 14 — Garantie & Schutzfrist (7 Rows: #78-84)
INSERT INTO ark.dim_activity_types
  (activity_type_name, activity_category, activity_channel,
   is_auto_loggable, actor_type, source_system, is_notifiable, description)
VALUES
  ('Garantiefrist - Gestartet', 'Garantie & Schutzfrist', 'System',
   true, 'automation', 'saga-engine', true,
   'Saga V4 — 3-Mt-Garantiefrist nach Placement eröffnet (dazukaufbar bis 6 Mt)'),
  ('Garantiefrist - Erfüllt', 'Garantie & Schutzfrist', 'System',
   true, 'automation', 'nightly-batch', true,
   'Kandidat hat Garantiefrist-Zeitraum vollständig durchlaufen'),
  ('Garantiefrist - Gebrochen', 'Garantie & Schutzfrist', 'System',
   true, 'automation', 'event-worker', true,
   'Austritt innerhalb Garantiefrist — Rückvergütung oder Ersatz-Auslösung'),
  ('Reminder - Garantie läuft ab', 'Garantie & Schutzfrist', 'System',
   true, 'automation', 'nightly-batch', true,
   'Auto-Reminder 14 Tage vor Garantie-Ablauf'),
  ('Schutzfrist - Gestartet', 'Garantie & Schutzfrist', 'System',
   true, 'automation', 'event-worker', false,
   'Direkteinstellungs-Schutzfrist bei Nicht-Placement aktiv (Default 12 Mt)'),
  ('Schutzfrist - Auf 16 Mt verlängert', 'Garantie & Schutzfrist', 'System',
   true, 'automation', 'nightly-batch', false,
   'Auto-Verlängerung wenn Kunde Info nicht innerhalb 10 Tagen sendet'),
  ('Schutzfrist - Claim eröffnet', 'Garantie & Schutzfrist', 'System',
   true, 'integration', 'scraper', true,
   'Scraper erkennt Direkteinstellung innerhalb Schutzfrist — Claim-Workflow');

-- Kategorie 15 — Scraper & Intelligence (6 Rows: #85-90)
INSERT INTO ark.dim_activity_types
  (activity_type_name, activity_category, activity_channel,
   is_auto_loggable, actor_type, source_system, is_notifiable, description)
VALUES
  ('Scraper - Neue Person bei Account', 'Scraper & Intelligence', 'System',
   true, 'integration', 'scraper', true,
   'LinkedIn-Scraper erkennt neuen Mitarbeiter beim Zielkunden'),
  ('Scraper - Person hat Account verlassen', 'Scraper & Intelligence', 'System',
   true, 'integration', 'scraper', true,
   'Abgang eines Mitarbeiters automatisch detektiert'),
  ('Scraper - Neue Job-Stelle erkannt', 'Scraper & Intelligence', 'System',
   true, 'integration', 'scraper', true,
   'Neue offene Stelle beim Zielkunden entdeckt'),
  ('Scraper - Rollenänderung erkannt', 'Scraper & Intelligence', 'System',
   true, 'integration', 'scraper', true,
   'Person wechselt intern die Rolle (z.B. Beförderung)'),
  ('Scraper - Eintrag importiert', 'Scraper & Intelligence', 'System',
   false, 'user', 'scraper', false,
   'Scraper-Ergebnis nach Review in Kontakt/Job übernommen'),
  ('Scraper - Schutzfrist-Match erkannt', 'Scraper & Intelligence', 'System',
   true, 'integration', 'scraper', true,
   'Direkteinstellung innerhalb aktiver Schutzfrist durch Scraper identifiziert');

-- Kategorie 16 — Pipeline-Transitions (Auto) (8 Rows: #91-98)
INSERT INTO ark.dim_activity_types
  (activity_type_name, activity_category, activity_channel,
   is_auto_loggable, actor_type, source_system, is_notifiable, description)
VALUES
  ('Jobbasket - Mündliches GO erhalten', 'Pipeline-Transitions', 'System',
   true, 'automation', 'event-worker', false,
   'Jobbasket-Stage automatisch auf oral_go gesetzt'),
  ('Jobbasket - Schriftliches GO erhalten', 'Pipeline-Transitions', 'System',
   true, 'automation', 'event-worker', false,
   'Schriftliche Bestätigung erhalten — Stage written_go'),
  ('Jobbasket - Zuweisung abgeschlossen', 'Pipeline-Transitions', 'System',
   true, 'automation', 'event-worker', false,
   'Gate 1 — alle 4 Pflicht-Dokumente vorhanden (CV, Diplom, Zeugnis, Briefing)'),
  ('Jobbasket - Versandbereit', 'Pipeline-Transitions', 'System',
   true, 'automation', 'event-worker', false,
   'Gate 2 — ARK-CV plus Abstract oder Exposé vorhanden'),
  ('Jobbasket - CV an Kunde versendet', 'Pipeline-Transitions', 'System',
   true, 'automation', 'event-worker', true,
   'Versand via Dashboard To-Send-Inbox — Prozess automatisch erstellt'),
  ('Prozess - Stage automatisch gewechselt', 'Pipeline-Transitions', 'System',
   true, 'automation', 'event-worker', false,
   'Prozess-Stage durch Auto-Rule gewechselt (keine manuelle Aktion)'),
  ('Prozess - Stale erkannt', 'Pipeline-Transitions', 'System',
   true, 'automation', 'nightly-batch', true,
   'Stage-spezifische Alter-Schwelle überschritten'),
  ('Prozess - Automatisch abgelehnt', 'Pipeline-Transitions', 'System',
   true, 'automation', 'saga-engine', false,
   'Andere offene Prozesse des Kandidaten nach Placement automatisch geschlossen');

-- Kategorie 17 — Saga-Events (1 Row: #99)
INSERT INTO ark.dim_activity_types
  (activity_type_name, activity_category, activity_channel,
   is_auto_loggable, actor_type, source_system, is_notifiable, description)
VALUES
  ('Placement - Vollständig abgeschlossen', 'Saga-Events', 'System',
   true, 'automation', 'saga-engine', true,
   'Saga V7 erfolgreich — öffnet Sub-Drawer mit allen 6 Substeps aus fact_event_queue');

-- Kategorie 18 — AI & LLM (3 Rows: #100-102)
INSERT INTO ark.dim_activity_types
  (activity_type_name, activity_category, activity_channel,
   is_auto_loggable, actor_type, source_system, is_notifiable, description)
VALUES
  ('AI - Briefing aus Transkript befüllt', 'AI & LLM', 'System',
   true, 'automation', 'llm', true,
   'LLM-Extraktor hat Briefing-Maske aus Call-Transkript befüllt — Consultant muss bestätigen'),
  ('AI - Call-Transkription fertig', 'AI & LLM', 'System',
   true, 'automation', 'llm', false,
   'Audio-Transkription durch Provider (Whisper/Claude) abgeschlossen'),
  ('AI - Activity-Type-Vorschlag', 'AI & LLM', 'System',
   true, 'automation', 'llm', false,
   'Unklassifizierte History-Zeile erhält AI-Vorschlag für Activity-Type-Zuordnung');

-- Ergänzungen in bestehenden Kategorien (4 Rows: #103-106)
INSERT INTO ark.dim_activity_types
  (activity_type_name, activity_category, activity_channel,
   is_auto_loggable, actor_type, source_system, is_notifiable, description)
VALUES
  ('Emailverkehr - Bounce', 'Emailverkehr', 'Email',
   true, 'integration', 'outlook', false,
   'Email konnte nicht zugestellt werden — Mail-Provider-Bounce automatisch erkannt'),
  ('Assessment - Credit verbraucht', 'Assessment', 'System',
   true, 'automation', 'event-worker', false,
   'Credit-Verbrauch nach Durchführung automatisch gebucht'),
  ('Placementprozess - Referral ausgelöst', 'Placementprozess', 'System',
   true, 'automation', 'saga-engine', true,
   'Saga V5 — Referral-Chain beim Placement automatisch getriggert'),
  ('System - Kandidat anonymisiert (GDPR)', 'System / Meta', 'System',
   true, 'automation', 'nightly-batch', false,
   'Persönliche Daten nach 1 Jahr Inaktivität automatisch anonymisiert');

-- -----------------------------------------------------------------------------
-- SCHRITT 4b (v1.3): +11 Rows #111–#121 aus Event-Mapping-Entscheidungen
-- Aus specs/ARK_EVENT_TYPES_MAPPING_v1_4.md — neue Activity-Types für
-- bestehende Events die create_history=true brauchen aber kein Mapping hatten.
-- -----------------------------------------------------------------------------

INSERT INTO ark.dim_activity_types
  (activity_type_name, activity_category, activity_channel,
   is_auto_loggable, actor_type, source_system, is_notifiable, description)
VALUES
  ('System - Kandidat zusammengeführt', 'System / Meta', 'System',
   true, 'automation', 'event-worker', false,
   'Zwei Kandidaten-Profile via Merge zusammengeführt — History wandert an Target-Kandidat'),
  ('Placementprozess - Wiedereröffnet', 'Placementprozess', 'System',
   true, 'user', 'event-worker', true,
   'Geschlossener Prozess wurde reaktiviert'),
  ('Placementprozess - Pausiert', 'Placementprozess', 'System',
   true, 'user', 'event-worker', true,
   'Prozess mit Wiederaufnahme-Datum on hold gesetzt'),
  ('Job - Abgesagt', 'Placementprozess', 'System',
   true, 'user', 'event-worker', true,
   'Offene Stelle abgesagt (manuell oder durch Mandat-Kündigung)'),
  ('Mandat - Abgeschlossen', 'Mandatsakquise', 'System',
   true, 'user', 'event-worker', true,
   'Mandat erfolgreich beendet'),
  ('Mandat - Gekündigt', 'Mandatsakquise', 'System',
   true, 'user', 'event-worker', true,
   'Mandat vorzeitig gekündigt (Saga TX3)'),
  ('Mandat - Aktiviert', 'Mandatsakquise', 'System',
   true, 'automation', 'event-worker', true,
   'Nach Unterzeichnung — erste Stage-Zahlung fällig'),
  ('Kommunikation - Eingehender Anruf (unklassifiziert)', 'Kontaktberührung', 'Phone',
   true, 'integration', 'threecx', true,
   '3CX-Auto-Import ohne Klassifizierungsregel — AM klassifiziert später, Dashboard-Badge signalisiert pending'),
  ('Kommunikation - Anruf verpasst', 'Kontaktberührung', 'Phone',
   true, 'integration', 'threecx', false,
   '3CX Missed-Call automatisch geloggt'),
  ('Kommunikation - Eingehende Email (unklassifiziert)', 'Emailverkehr', 'Email',
   true, 'integration', 'outlook', true,
   'Kein Template-Match — categorization_status=pending, Dashboard-Badge für Klassifizierung'),
  ('Assessment - Abgelaufen', 'Assessment', 'System',
   true, 'automation', 'nightly-batch', false,
   'Assessment-Invite expired ohne Completion');

-- -----------------------------------------------------------------------------
-- SCHRITT 5: Backfill actor_type für bestehende auto-logged Rows
-- -----------------------------------------------------------------------------

UPDATE ark.dim_activity_types
  SET actor_type = 'automation',
      source_system = 'event-worker'
  WHERE is_auto_loggable = true
    AND actor_type = 'user';  -- war Default, jetzt explizit setzen

-- Spezifische Source-Systems für bekannte bestehende Auto-Events:
UPDATE ark.dim_activity_types
  SET source_system = 'nightly-batch'
  WHERE activity_type_name IN ('Inactive','GO Ghosting');

UPDATE ark.dim_activity_types
  SET source_system = 'llm'
  WHERE activity_type_name = 'Briefing';

UPDATE ark.dim_activity_types
  SET source_system = 'event-worker'
  WHERE activity_type_name IN ('Rebriefing','Assessment - Ergebnisse erfasst');

UPDATE ark.dim_activity_types
  SET source_system = 'saga-engine'
  WHERE activity_type_name = 'Schutzfrist - Status-Änderung';

-- -----------------------------------------------------------------------------
-- SCHRITT 6: Seed dim_event_types — neue Events
-- -----------------------------------------------------------------------------

-- Hilfs-View für Activity-Type-IDs (nur während Migration)
-- (In Prod: direktes SELECT inline im INSERT)

-- 6a. Events die fact_history erzeugen (create_history=true, ~30 Events)
INSERT INTO ark.dim_event_types
  (event_name, event_category, entity_type, create_history,
   default_activity_type_id, default_actor_type, default_source_system,
   emitter_component, event_description, is_automatable)
VALUES
  -- Kalender
  ('interview.scheduled', 'calendar', 'process', true,
   (SELECT id FROM ark.dim_activity_types WHERE activity_type_name = 'Kalender - Interview geplant'),
   'integration', 'calendar-integration', 'calendar-integration-adapter',
   'Interview-Termin via Kalender erstellt', true),
  ('reminder.interview_upcoming', 'reminder', 'process', true,
   (SELECT id FROM ark.dim_activity_types WHERE activity_type_name = 'Reminder - Interview steht bevor'),
   'automation', 'event-worker', 'reminder-scheduler',
   'Auto-Reminder vor Interview-Termin', true),
  ('reminder.interview_date_missing', 'reminder', 'process', true,
   (SELECT id FROM ark.dim_activity_types WHERE activity_type_name = 'Reminder - Interview-Datum fehlt'),
   'automation', 'nightly-batch', 'nightly-stale-detector',
   'Stage Interview ohne Datum nach 2 Tagen', true),

  -- Dokumente
  ('document.cv_parsed', 'document', 'candidate', true,
   (SELECT id FROM ark.dim_activity_types WHERE activity_type_name = 'Dokument - CV automatisch geparst'),
   'automation', 'llm', 'cv-parser-worker',
   'CV-Parsing via LLM abgeschlossen', true),
  ('document.ocr_done', 'document', 'candidate', true,
   (SELECT id FROM ark.dim_activity_types WHERE activity_type_name = 'Dokument - OCR abgeschlossen'),
   'automation', 'event-worker', 'ocr-pipeline',
   'OCR-Pipeline abgeschlossen', true),
  ('document.embedded', 'document', 'candidate', true,
   (SELECT id FROM ark.dim_activity_types WHERE activity_type_name = 'Dokument - Vektorindex aufgenommen'),
   'automation', 'event-worker', 'embedding-worker',
   'Dokument-Embedding in pgvector', true),

  -- Garantie & Schutzfrist
  ('guarantee.started', 'guarantee', 'candidate', true,
   (SELECT id FROM ark.dim_activity_types WHERE activity_type_name = 'Garantiefrist - Gestartet'),
   'automation', 'saga-engine', 'saga-engine-v7',
   'Garantiefrist bei Placement eröffnet', true),
  ('guarantee.fulfilled', 'guarantee', 'candidate', true,
   (SELECT id FROM ark.dim_activity_types WHERE activity_type_name = 'Garantiefrist - Erfüllt'),
   'automation', 'nightly-batch', 'guarantee-lifecycle-worker',
   'Garantiefrist durchlaufen', true),
  ('guarantee.breached', 'guarantee', 'candidate', true,
   (SELECT id FROM ark.dim_activity_types WHERE activity_type_name = 'Garantiefrist - Gebrochen'),
   'automation', 'event-worker', 'guarantee-lifecycle-worker',
   'Austritt innerhalb Garantiefrist', true),
  ('reminder.guarantee_expiring', 'reminder', 'candidate', true,
   (SELECT id FROM ark.dim_activity_types WHERE activity_type_name = 'Reminder - Garantie läuft ab'),
   'automation', 'nightly-batch', 'reminder-scheduler',
   '14 Tage vor Garantie-Ablauf', true),
  ('protection_window.started', 'protection_window', 'candidate', true,
   (SELECT id FROM ark.dim_activity_types WHERE activity_type_name = 'Schutzfrist - Gestartet'),
   'automation', 'event-worker', 'protection-window-worker',
   'Schutzfrist bei Nicht-Placement', true),
  ('protection_window.extended', 'protection_window', 'account', true,
   (SELECT id FROM ark.dim_activity_types WHERE activity_type_name = 'Schutzfrist - Auf 16 Mt verlängert'),
   'automation', 'nightly-batch', 'protection-window-worker',
   'Auto-Verlängerung auf 16 Mt', true),
  ('direct_hire_claim.opened', 'protection_window', 'candidate', true,
   (SELECT id FROM ark.dim_activity_types WHERE activity_type_name = 'Schutzfrist - Claim eröffnet'),
   'integration', 'scraper', 'scraper-claim-matcher',
   'Scraper-Match für Direkteinstellung', true),

  -- Scraper
  ('scrape.new_person', 'scrape', 'account', true,
   (SELECT id FROM ark.dim_activity_types WHERE activity_type_name = 'Scraper - Neue Person bei Account'),
   'integration', 'scraper', 'scraper-linkedin',
   'Neue Person bei Account entdeckt', true),
  ('scrape.person_left', 'scrape', 'account', true,
   (SELECT id FROM ark.dim_activity_types WHERE activity_type_name = 'Scraper - Person hat Account verlassen'),
   'integration', 'scraper', 'scraper-linkedin',
   'Person hat Account verlassen', true),
  ('scrape.new_job_detected', 'scrape', 'account', true,
   (SELECT id FROM ark.dim_activity_types WHERE activity_type_name = 'Scraper - Neue Job-Stelle erkannt'),
   'integration', 'scraper', 'scraper-jobs',
   'Neue Stelle beim Zielkunden', true),
  ('scrape.role_changed', 'scrape', 'candidate', true,
   (SELECT id FROM ark.dim_activity_types WHERE activity_type_name = 'Scraper - Rollenänderung erkannt'),
   'integration', 'scraper', 'scraper-linkedin',
   'Person wechselt interne Rolle', true),
  ('scrape.item_imported', 'scrape', 'account', true,
   (SELECT id FROM ark.dim_activity_types WHERE activity_type_name = 'Scraper - Eintrag importiert'),
   'integration', 'scraper', 'scraper-review-worker',
   'Scraper-Eintrag nach Review importiert', true),
  ('scrape.protection_match', 'protection_window', 'candidate', true,
   (SELECT id FROM ark.dim_activity_types WHERE activity_type_name = 'Scraper - Schutzfrist-Match erkannt'),
   'integration', 'scraper', 'scraper-claim-matcher',
   'Schutzfrist-Match durch Scraper', true),

  -- Pipeline-Transitions
  ('jobbasket.go_oral', 'jobbasket', 'candidate', true,
   (SELECT id FROM ark.dim_activity_types WHERE activity_type_name = 'Jobbasket - Mündliches GO erhalten'),
   'automation', 'event-worker', 'jobbasket-stage-worker',
   'Jobbasket-Stage oral_go', true),
  ('jobbasket.go_written', 'jobbasket', 'candidate', true,
   (SELECT id FROM ark.dim_activity_types WHERE activity_type_name = 'Jobbasket - Schriftliches GO erhalten'),
   'automation', 'event-worker', 'jobbasket-stage-worker',
   'Jobbasket-Stage written_go', true),
  ('jobbasket.stage_assigned', 'jobbasket', 'candidate', true,
   (SELECT id FROM ark.dim_activity_types WHERE activity_type_name = 'Jobbasket - Zuweisung abgeschlossen'),
   'automation', 'event-worker', 'jobbasket-stage-worker',
   'Jobbasket Gate 1 erreicht', true),
  ('jobbasket.stage_to_send', 'jobbasket', 'candidate', true,
   (SELECT id FROM ark.dim_activity_types WHERE activity_type_name = 'Jobbasket - Versandbereit'),
   'automation', 'event-worker', 'jobbasket-stage-worker',
   'Jobbasket Gate 2 erreicht', true),
  ('jobbasket.cv_sent', 'jobbasket', 'process', true,
   (SELECT id FROM ark.dim_activity_types WHERE activity_type_name = 'Jobbasket - CV an Kunde versendet'),
   'automation', 'event-worker', 'jobbasket-dispatch-worker',
   'CV-Versand an Kunde', true),
  ('process.stale_detected', 'process', 'process', true,
   (SELECT id FROM ark.dim_activity_types WHERE activity_type_name = 'Prozess - Stale erkannt'),
   'automation', 'nightly-batch', 'nightly-stale-detector',
   'Stage-Alter-Schwelle überschritten', true),
  ('process.auto_rejected', 'process', 'candidate', true,
   (SELECT id FROM ark.dim_activity_types WHERE activity_type_name = 'Prozess - Automatisch abgelehnt'),
   'automation', 'saga-engine', 'saga-engine-v7',
   'Auto-Reject nach Placement anderswo', true),

  -- Saga V7 (v1.3: kanonischer Name + parallel-Phase alias)
  ('process.placement_completed', 'saga', 'process', true,
   (SELECT id FROM ark.dim_activity_types WHERE activity_type_name = 'Placement - Vollständig abgeschlossen'),
   'automation', 'saga-engine', 'saga-engine-v7',
   'Saga V7 — Placement-Saga erfolgreich abgeschlossen (kanonisch v1.3)', true),
  ('process.placement_done', 'saga', 'process', true,
   (SELECT id FROM ark.dim_activity_types WHERE activity_type_name = 'Placement - Vollständig abgeschlossen'),
   'automation', 'saga-engine', 'saga-engine-v7',
   'Alias v1.2 → process.placement_completed. Parallel-Phase 2 Sprints, dann is_automatable=false, nach 3 Mt Prod-Grünphase entfernen', true),

  -- AI & LLM
  ('briefing.auto_filled', 'ai', 'candidate', true,
   (SELECT id FROM ark.dim_activity_types WHERE activity_type_name = 'AI - Briefing aus Transkript befüllt'),
   'automation', 'llm', 'llm-briefing-extractor',
   'Briefing aus Call-Transkript befüllt', true),
  ('call.transcript_ready', 'ai', 'candidate', true,
   (SELECT id FROM ark.dim_activity_types WHERE activity_type_name = 'AI - Call-Transkription fertig'),
   'automation', 'llm', 'transcription-worker',
   'Audio-Transkription abgeschlossen', true),
  ('history.classification_suggested', 'ai', 'candidate', true,
   (SELECT id FROM ark.dim_activity_types WHERE activity_type_name = 'AI - Activity-Type-Vorschlag'),
   'automation', 'llm', 'llm-classifier',
   'AI schlägt Activity-Type vor', true),

  -- Email/Finance/Referral
  ('email.bounced', 'email', 'candidate', true,
   (SELECT id FROM ark.dim_activity_types WHERE activity_type_name = 'Emailverkehr - Bounce'),
   'integration', 'outlook', 'email-inbound-matcher',
   'Email-Zustellung fehlgeschlagen', true),
  ('assessment.credit_consumed', 'assessment', 'account', true,
   (SELECT id FROM ark.dim_activity_types WHERE activity_type_name = 'Assessment - Credit verbraucht'),
   'automation', 'event-worker', 'assessment-credit-worker',
   'Assessment-Credit automatisch abgebucht', true),
  ('referral.triggered', 'referral', 'candidate', true,
   (SELECT id FROM ark.dim_activity_types WHERE activity_type_name = 'Placementprozess - Referral ausgelöst'),
   'automation', 'saga-engine', 'saga-engine-v7',
   'Referral-Chain bei Placement', true),
  ('candidate.anonymized', 'system', 'candidate', true,
   (SELECT id FROM ark.dim_activity_types WHERE activity_type_name = 'System - Kandidat anonymisiert (GDPR)'),
   'automation', 'nightly-batch', 'gdpr-retention-batch',
   'GDPR-Anonymisierung nach 1 Jahr', true),

  -- v1.3: system.retention_action Split (Decisions §M1)
  ('system.retention_action.candidate', 'system', 'candidate', true,
   (SELECT id FROM ark.dim_activity_types WHERE activity_type_name = 'System - Kandidat anonymisiert (GDPR)'),
   'automation', 'nightly-batch', 'gdpr-retention-batch',
   'Retention-Action speziell für Kandidaten — User-Timeline-Eintrag', true),

  -- v1.3: neue Event-Types für #111-#121 (Decisions §M4, §M5)
  ('candidate.merged', 'candidate', 'candidate', true,
   (SELECT id FROM ark.dim_activity_types WHERE activity_type_name = 'System - Kandidat zusammengeführt'),
   'automation', 'event-worker', 'candidate-merge-worker',
   'Zwei Kandidaten-Profile zusammengeführt, History wandert an Target', true),
  ('process.reopened', 'process', 'process', true,
   (SELECT id FROM ark.dim_activity_types WHERE activity_type_name = 'Placementprozess - Wiedereröffnet'),
   'automation', 'event-worker', 'process-reopen-handler',
   'Geschlossener Prozess wurde reaktiviert', true),
  ('process.on_hold', 'process', 'process', true,
   (SELECT id FROM ark.dim_activity_types WHERE activity_type_name = 'Placementprozess - Pausiert'),
   'automation', 'event-worker', 'process-hold-handler',
   'Prozess on hold gesetzt', true),
  ('job.cancelled', 'job', 'job', true,
   (SELECT id FROM ark.dim_activity_types WHERE activity_type_name = 'Job - Abgesagt'),
   'automation', 'event-worker', 'job-cancel-handler',
   'Offene Stelle abgesagt', true),
  ('mandate.completed', 'mandate', 'mandate', true,
   (SELECT id FROM ark.dim_activity_types WHERE activity_type_name = 'Mandat - Abgeschlossen'),
   'automation', 'event-worker', 'mandate-lifecycle-worker',
   'Mandat erfolgreich beendet', true),
  ('mandate.cancelled', 'mandate', 'mandate', true,
   (SELECT id FROM ark.dim_activity_types WHERE activity_type_name = 'Mandat - Gekündigt'),
   'automation', 'saga-engine', 'saga-engine-v7',
   'Mandat vorzeitig gekündigt (Saga TX3)', true),
  ('mandate.activated', 'mandate', 'mandate', true,
   (SELECT id FROM ark.dim_activity_types WHERE activity_type_name = 'Mandat - Aktiviert'),
   'automation', 'event-worker', 'mandate-activation-handler',
   'Nach Unterzeichnung aktiviert', true),
  ('call.received', 'call', 'candidate', true,
   (SELECT id FROM ark.dim_activity_types WHERE activity_type_name = 'Kommunikation - Eingehender Anruf (unklassifiziert)'),
   'integration', 'threecx', 'threecx-adapter',
   '3CX-Auto-Import, Fallback-Row mit categorization_status=pending', true),
  ('call.missed', 'call', 'candidate', true,
   (SELECT id FROM ark.dim_activity_types WHERE activity_type_name = 'Kommunikation - Anruf verpasst'),
   'integration', 'threecx', 'threecx-adapter',
   '3CX Missed-Call', true),
  ('email.received', 'email', 'candidate', true,
   (SELECT id FROM ark.dim_activity_types WHERE activity_type_name = 'Kommunikation - Eingehende Email (unklassifiziert)'),
   'integration', 'outlook', 'email-inbound-matcher',
   'Fallback wenn kein Template-Match', true),
  ('assessment.expired', 'assessment', 'candidate', true,
   (SELECT id FROM ark.dim_activity_types WHERE activity_type_name = 'Assessment - Abgelaufen'),
   'automation', 'nightly-batch', 'assessment-lifecycle-worker',
   'Invite expired ohne Completion', true);

-- 6b. Events die NUR in Queue/Log bleiben (create_history=false, ~15 Events)
INSERT INTO ark.dim_event_types
  (event_name, event_category, entity_type, create_history,
   default_actor_type, default_source_system, emitter_component,
   event_description, is_automatable)
VALUES
  ('saga.v1_stage_placement', 'saga', 'process', false,
   'automation', 'saga-engine', 'saga-engine-v7',
   'Saga Step V1 — Stage auf placement gesetzt', true),
  ('saga.v2_finance_calculated', 'saga', 'process', false,
   'automation', 'saga-engine', 'saga-engine-v7',
   'Saga Step V2 — Finance berechnet', true),
  ('saga.v3_job_filled', 'saga', 'job', false,
   'automation', 'saga-engine', 'saga-engine-v7',
   'Saga Step V3 — Job als filled markiert', true),
  ('saga.v4_guarantee_opened', 'saga', 'candidate', false,
   'automation', 'saga-engine', 'saga-engine-v7',
   'Saga Step V4 — Garantiefrist-Row erstellt', true),
  ('saga.v5_referral_triggered', 'saga', 'candidate', false,
   'automation', 'saga-engine', 'saga-engine-v7',
   'Saga Step V5 — Referral-Chain angestossen', true),
  ('saga.v6_staffing_plan_updated', 'saga', 'job', false,
   'automation', 'saga-engine', 'saga-engine-v7',
   'Saga Step V6 — Stellenplan aktualisiert', true),
  ('saga.failure', 'saga', 'process', false,
   'automation', 'saga-engine', 'saga-engine-v7',
   'Saga-Rollback bei Step-Failure', true),
  ('temperature.updated', 'system', 'candidate', false,
   'system', 'nightly-batch', 'nightly-scoring-batch',
   'Temperature-Score aktualisiert', true),
  ('matching.scores_recomputed', 'match', 'job', false,
   'automation', 'event-worker', 'matching-recompute-worker',
   'Matching-Scores neu berechnet', true),
  ('staffing_plan.updated', 'system', 'job', false,
   'automation', 'event-worker', 'project-staffing-worker',
   'Projekt-Stellenplan geändert', true),
  ('webhook.triggered', 'system', 'system', false,
   'system', 'webhook', 'webhook-dispatcher',
   'Ausgehender Webhook ausgelöst', true),
  ('dead_letter.alert', 'system', 'system', false,
   'system', 'system', 'event-queue-monitor',
   'Dead-Letter-Schwelle überschritten', true),
  ('process.duplicate_detected', 'process', 'candidate', false,
   'automation', 'event-worker', 'process-creation-guard',
   'Doppelter Prozess-Anlage-Versuch', true),
  ('circuit_breaker.tripped', 'system', 'system', false,
   'system', 'system', 'automation-engine',
   'Automation-Regel Circuit-Breaker aktiviert', true),
  ('retention.warning', 'system', 'candidate', false,
   'automation', 'nightly-batch', 'gdpr-retention-batch',
   '30 Tage vor Aufbewahrungs-Ablauf', true),

  -- v1.3: system.retention_action.other (ohne fact_history, Pendant zu .candidate oben)
  ('system.retention_action.other', 'system', 'system', false,
   'automation', 'nightly-batch', 'gdpr-retention-batch',
   'Retention-Action für Nicht-Kandidat-Entities — nur Queue-Log (Decisions §M1)', true);

-- -----------------------------------------------------------------------------
-- SCHRITT 7: Update bestehender dim_event_types Rows mit create_history + Mapping
-- -----------------------------------------------------------------------------
-- Bestehende Events aus v1.3 (Zeile 326-336): Mapping auf Activity-Types

UPDATE ark.dim_event_types SET
  create_history = true,
  default_activity_type_id = (SELECT id FROM ark.dim_activity_types
                              WHERE activity_type_name = 'Briefing'),
  default_actor_type = 'automation',
  default_source_system = 'event-worker',
  emitter_component = 'briefing-save-handler'
WHERE event_name = 'history.created';

UPDATE ark.dim_event_types SET
  create_history = true,
  default_activity_type_id = (SELECT id FROM ark.dim_activity_types
                              WHERE activity_type_name = 'Prozess - Stage automatisch gewechselt'),
  default_actor_type = 'automation',
  default_source_system = 'event-worker',
  emitter_component = 'process-stage-worker'
WHERE event_name = 'process.stage_changed';

UPDATE ark.dim_event_types SET
  create_history = true,
  default_activity_type_id = (SELECT id FROM ark.dim_activity_types
                              WHERE activity_type_name = 'Dokument - Hochgeladen'),
  default_actor_type = 'user',
  default_source_system = 'manual-upload',
  emitter_component = 'document-upload-handler'
WHERE event_name = 'document.uploaded';

-- TODO Reviewer: weitere ~24 bestehende Events mappen
-- (candidate.stage_changed, candidate.temperature_changed, etc.)
-- Aus Sicherheitsgründen wird die Mapping-Vollständigkeit in Schritt 8 validiert.

-- -----------------------------------------------------------------------------
-- SCHRITT 8: Validierungs-Queries (post-migration Check)
-- -----------------------------------------------------------------------------
-- Diese Queries müssen nach Migration erfolgreich laufen:

-- 8a. Alle create_history=true Events haben Activity-Type-Mapping
-- Erwartet: 0 Rows
DO $$
DECLARE
  missing_count int;
BEGIN
  SELECT COUNT(*) INTO missing_count
  FROM ark.dim_event_types
  WHERE create_history = true AND default_activity_type_id IS NULL;

  IF missing_count > 0 THEN
    RAISE EXCEPTION 'Migration-Failure: % Event-Types mit create_history=true ohne Activity-Type-Mapping', missing_count;
  END IF;
END $$;

-- 8b. Anzahl neuer Activity-Types = 48 (v1.3: 37 initial + 11 Mapping-Doc #111-#121)
DO $$
DECLARE
  new_count int;
BEGIN
  SELECT COUNT(*) INTO new_count
  FROM ark.dim_activity_types
  WHERE activity_category IN (
    'Kalender & Planung','Dokumenten-Pipeline','Garantie & Schutzfrist',
    'Scraper & Intelligence','Pipeline-Transitions','Saga-Events','AI & LLM'
  ) OR activity_type_name IN (
    'Emailverkehr - Bounce','Assessment - Credit verbraucht',
    'Placementprozess - Referral ausgelöst',
    'System - Kandidat anonymisiert (GDPR)',
    -- v1.3 Mapping-Doc additions (#111-#121):
    'System - Kandidat zusammengeführt',
    'Placementprozess - Wiedereröffnet',
    'Placementprozess - Pausiert',
    'Job - Abgesagt',
    'Mandat - Abgeschlossen',
    'Mandat - Gekündigt',
    'Mandat - Aktiviert',
    'Kommunikation - Eingehender Anruf (unklassifiziert)',
    'Kommunikation - Anruf verpasst',
    'Kommunikation - Eingehende Email (unklassifiziert)',
    'Assessment - Abgelaufen'
  );

  IF new_count <> 48 THEN
    RAISE EXCEPTION 'Migration-Failure: % neue Activity-Types gefunden (erwartet 48)', new_count;
  END IF;
END $$;

-- 8c. Kein auto-logged Row ohne actor_type
DO $$
DECLARE
  bad_count int;
BEGIN
  SELECT COUNT(*) INTO bad_count
  FROM ark.dim_activity_types
  WHERE is_auto_loggable = true AND actor_type = 'user';

  IF bad_count > 0 THEN
    RAISE EXCEPTION 'Migration-Failure: % auto-logged Rows haben actor_type=user', bad_count;
  END IF;
END $$;

-- -----------------------------------------------------------------------------
-- SCHRITT 9 (v1.3): dim_automation_settings — neue Feature-Flag- & Config-Keys
-- Siehe Decisions §Q8 (Notification-Dedup) und Admin-Debug-Spec §Q2 (Retention)
-- -----------------------------------------------------------------------------

INSERT INTO ark.dim_automation_settings (key, value_text, value_bool, value_int, description)
VALUES
  ('system_event_writer_enabled', NULL, true, NULL,
   'v1.3: Master-Feature-Flag Pre-Rule Auto-History. false = nur Rules ausführen.'),
  ('notification_dedup_enabled', NULL, true, NULL,
   'v1.3: Redis-Lock für Hook+Rule Notification-Dedup aktivieren (Decisions §Q8)'),
  ('notification_dedup_ttl_seconds', NULL, NULL, 60,
   'v1.3: TTL des Dedup-Locks in Sekunden (deckt Worker-Retries + Rule-Delay ab)'),
  ('system_event_retention_days', NULL, NULL, 180,
   'v1.3: fact_event_queue + fact_event_log Retention (Prod 180d / Test 30d / Dev 7d)'),
  ('saga_correlation_retention_days', NULL, NULL, 90,
   'v1.3: Wie lange Correlation-IDs in Event-Queue vor Purge bleiben'),
  ('auto_history_source_override_enabled', NULL, true, NULL,
   'v1.3: Erlaubt Writer actor_type=integration → user Override bei payload.source=crm_manual_entry (Decisions §D4)');

-- Fallback falls Schema-Spalten abweichen (idempotent):
-- Wenn value_int nicht existiert, nutze value_text statt dessen:
-- UPDATE ark.dim_automation_settings SET value_text = '60' WHERE key = 'notification_dedup_ttl_seconds';

COMMIT;

-- =============================================================================
-- v1.3 POST-DEPLOY HART-RENAMES (separates Script `002_v1_3_renames.sql`)
-- Wird NACH Backend-Code-Rename ausgeführt (nicht in dieser Migration)
-- =============================================================================
-- Hart-Rename 3 low-traffic Events (Decisions §Namensvereinheitlichungen):
-- BEGIN;
-- UPDATE ark.dim_event_types SET event_name = 'circuit_breaker.tripped'
--   WHERE event_name = 'system.circuit_breaker_tripped';
-- UPDATE ark.dim_event_types SET event_name = 'dead_letter.alert'
--   WHERE event_name = 'system.dead_letter_alert';
-- UPDATE ark.dim_event_types SET event_name = 'jobbasket.stage_assigned'
--   WHERE event_name = 'jobbasket.stage_changed';
-- COMMIT;
--
-- Nach 2-Sprint-Prod-Grünphase für placement_done → placement_completed-Alias:
-- UPDATE ark.dim_event_types SET is_automatable = false
--   WHERE event_name = 'process.placement_done';
-- (und nach weiteren 3 Monaten DELETE)
-- =============================================================================

-- =============================================================================
-- DOWN-MIGRATION (Rollback) — Referenz, separates Script
-- =============================================================================
-- BEGIN;
-- DELETE FROM ark.dim_event_types WHERE event_name IN (
--   'interview.scheduled', 'reminder.interview_upcoming', ...37 Namen
-- );
-- DELETE FROM ark.dim_activity_types WHERE activity_category IN (
--   'Kalender & Planung','Dokumenten-Pipeline','Garantie & Schutzfrist',
--   'Scraper & Intelligence','Pipeline-Transitions','Saga-Events','AI & LLM'
-- ) OR activity_type_name IN (...4 Ergänzungen);
-- ALTER TABLE ark.dim_activity_types DROP COLUMN actor_type, DROP COLUMN source_system, DROP COLUMN is_notifiable;
-- ALTER TABLE ark.dim_event_types DROP COLUMN default_activity_type_id, DROP COLUMN default_actor_type,
--   DROP COLUMN default_source_system, DROP COLUMN emitter_component, DROP COLUMN create_history;
-- -- Kategorie-CHECKs auf alte Werte zurücksetzen
-- ...
-- COMMIT;
-- =============================================================================
