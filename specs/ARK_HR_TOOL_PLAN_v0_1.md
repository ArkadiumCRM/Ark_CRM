---
title: "ARK HR-Tool · Umsetzungsplan v0.1"
type: plan
phase: 3
created: 2026-04-19
updated: 2026-04-19
status: draft
sources: [
  "mockups/ERP Tools/hr.html (Dashboard-First-Redesign)",
  "raw/Ark_CRM_v2/ARK_DATABASE_SCHEMA_v1_3.md § dim_mitarbeiter",
  "raw/Ark_CRM_v2/ARK_BACKEND_ARCHITECTURE_v2_5.md",
  "raw/Ark_CRM_v2/ARK_STAMMDATEN_EXPORT_v1_3.md § Rollen + Sparten",
  "memory/project_arkadium_role.md",
  "memory/project_commission_model.md",
  "memory/project_phase3_erp_standalone.md",
  "memory/project_activity_linking.md"
]
tags: [plan, erp, hr, phase-3, mitarbeitende, onboarding, absenzen, dsg, standalone]
---

# ARK HR-Tool · Phase-3-Umsetzungsplan v0.1

Grundlage für `ARK_HR_TOOL_SCHEMA_v0_1.md` + `ARK_HR_TOOL_INTERACTIONS_v0_1.md`. **Eigenständiges ARK-Produkt** (siehe Memory `project_phase3_erp_standalone.md`) — nicht Personio-Integration, sondern ARK-Native-HR-Modul mit optionalem Export zu externen Systemen.

---

## 1. Scope · Was ist das HR-Tool

**Zielgruppe intern**: HR-Manager (oft Personalunion mit GL-Assistent), Vorgesetzte (AM/CM mit Team), Mitarbeitende (Self-Service), Backoffice (Payroll-Export).

**Zielgruppe extern**: Treuhänder/Payroll-Anbieter (CSV/API-Export).

**Was das HR-Tool IST:**
- Zentrale Verwaltung aller Mitarbeiter-Daten (MA-Stammdaten, Verträge, Compliance, Dokumente)
- Lifecycle-Management: Bewerber → Onboarding → Aktiv → Offboarding → Alumni
- Absenzen-Management (Ferien, Krankheit, Unpaid, Mutterschaft, Militär, Feiertage)
- Onboarding-Checklisten (template-basiert)
- Zertifikat-Tracker mit Expiry-Alerts (Scheelen MDI/Relief/ASSESS/EQ, LinkedIn Recruiter, etc.)
- HR-Dokumenten-Ablage mit DSG-Retention-Regeln
- Audit-Log für sensible Daten (AHV, Gehalt, Pass)
- Self-Service-Portal für MA (eigenes Profil, Ferienantrag, Zertifikate)

**Was das HR-Tool NICHT ist:**
- Keine Payroll-Engine (Lohnabrechnung · Sozialbeiträge · Quellensteuer-Berechnung — lebt im Payroll-System/Treuhänder)
- Keine Performance-Reviews (siehe Phase-3-Performancetool)
- Keine Zeiterfassung (siehe Phase-3-Zeiterfassung)
- Keine Recruiting-Funnel für externe Kandidaten (das ist CRM)
- Keine Workflow-Engine für komplexe Approval-Chains (simple Manager-Genehmigung genügt)
- Kein LMS (Learning-Management-System — Enrollment-Tracking reicht, externe Kurse via LinkedIn-Learning/Udemy)

---

## 2. Markt-Überblick · HR-Tools für KMU (15-50 MA)

| Tool | Herkunft | Stärke | Preis | Relevanz ARK |
|------|----------|--------|-------|--------------|
| **Personio** | DE | Voll-HR + Payroll + Recruiting, Marktführer DACH KMU | CHF 12-18/MA/Mt | Feature-Benchmark, aber über-engineert für 20 MA |
| **BambooHR** | US | Einfache UX, starker Self-Service, gute Reports | CHF 8-15/MA/Mt | Feature-Benchmark Self-Service |
| **Factorial** | ES | HR + Zeit + Documents, fair bepreist | CHF 6-12/MA/Mt | preis-/feature-sensibel, gute Abwesenheits-UX |
| **HiBob** | UK | Moderne UX, Strong-Culture-Tool | CHF 10-14/MA/Mt | teuer für Boutique, UX-Inspiration |
| **Workday** | US | Enterprise-HR | CHF 30+/MA/Mt | **over-scope** für <30 MA |
| **HRworks** | DE | DACH-Fokus, solide | CHF 7/MA/Mt | Feature-Baseline |
| **Bexio HR** | CH | In Bexio integriert, CH-konform | Bexio Pro CHF 45/Mt + Add-on | Payroll-Bezug, kein eigenes HR-UI |
| **Abacus HR** | CH | CH-Treuhand-Standard | Enterprise-Preis | Payroll-Referenz, Export-Format |

**Take-Away für ARK-Standalone-Strategie:**
- Feature-Fokus Personio/BambooHR: Lifecycle + Absenzen + Dokumente + Self-Service
- UX-Inspiration: HiBob (Culture) · Factorial (Absenzen-Kalender) · BambooHR (Self-Service)
- Payroll-Export-Format: Abacus/Bexio kompatibel (CSV mit definierten Feldern)
- Ablehnen: Workday-Komplexität, Workflow-Engine-Overkill

---

## 3. CH-Arbeitsrecht · Compliance-Baseline

### 3.1 Pflichten für HR-System (nicht Zeiterfassung, die ist separat)

| Regel | Quelle | Impact |
|-------|--------|--------|
| **Arbeitsvertrag schriftlich** | OR Art. 319 ff. | PDF-Ablage Pflicht, 5 J. nach Austritt |
| **Arbeitszeugnis bei Austritt** | OR Art. 330a | Vorlagen-Generator empfohlen |
| **AHV-Anmeldung 10-Tage-Frist** | AHVG Art. 5 | Auto-Reminder + Formular-Export 8.4 |
| **Pensionskasse 10-Tage-Frist** | BVG Art. 10 | Auto-Reminder + PK-Export |
| **Quellensteuer Anmeldung** | DBG Art. 88 | Kanton-spezifisch (ZH/BS/BE/ZG/SG je MA) |
| **Unfallversicherung UVG** | UVG Art. 7 | Info + Ablage |
| **Aufbewahrung 5-10 J.** | OR, AHVG, BVG | Auto-Retention-Rules |

### 3.2 DSG-Baseline für HR-Daten

| Datentyp | Klassifikation | Zugriff |
|----------|---------------|---------|
| Name, Email, Telefon | Personendaten | MA + Vorgesetzter + HR + Admin |
| Adresse, Geburtsdatum, Zivilstand | Personendaten | MA + HR + Admin |
| AHV-Nr, Pass-Nr | **Sensible Daten (Art. 5 DSG)** | nur HR + Admin + MA-Self (Audit-Log) |
| Gehalt, Provisionsbasis | Personendaten, intern sensibel | nur HR + Backoffice + Admin + MA-Self |
| Krankheits-Notizen, Arztzeugnis | **Sensible Daten (Gesundheit)** | nur HR + Admin (MA hat Recht auf Auskunft) |
| Hintergrund-Check-Report | **Sensible Daten** | nur HR + Admin |
| Bewerbungs-Gespräch-Notizen | Personendaten (mit Vorbehalten) | HR + Vorgesetzter |

**Konsequenzen für Tool:**
- Sensible Felder maskiert anzeigen (`756.•••.•••.••`), Aufdecken mit Audit-Log
- Retention-Policies automatisch (5/10 J.)
- Self-Service-Export (DSG Art. 25 Auskunftsrecht)
- Löschung nach Retention + Legal-Hold-Flag für Ausnahmen

---

## 4. Interne System-Referenzen (was existiert schon)

### 4.1 `dim_mitarbeiter` in DB-Schema v1.3

Bereits vorhanden:
- **Person**: `vorname`, `nachname`, `email`, `eintrittsdatum`, `austrittsdatum`
- **Organisation**: `sparte_id` (FK), `team` (text), `standort`, `vorgesetzter_id` (FK)
- **Rollen**: `rolle` (deprecated), `bridge_mitarbeiter_roles` (N:N, 6 Rollen)
- **KPIs/Targets**: `target_calls_day`, `target_briefings_month`, `target_gos_month`, `target_placements_year`, `target_revenue_year`
- **Finanziell**: `commission_rate` (0.3 default)
- **System**: `auth_user_id`, `threecx_extension`, `status` (Active/Inactive/On Leave), `dashboard_config` JSONB, `email_signature_html`

### 4.2 Fehlende Felder für HR-Tool

Muss ergänzt werden:
- **Vertrag**: Pensum %, Vertragstyp, Kündigungsfrist, Probezeit-Ende, Arbeitsort-Details
- **CH-Compliance**: AHV-Nr (hashed), Pass-Nr, Kanton, Arbeitsbewilligung, Pensionskasse
- **Person**: Geburtsdatum, Geschlecht, Nationalität, Zivilstand, Muttersprache, Weitere Sprachen
- **Adresse**: Strasse, PLZ/Ort, Kanton, Land, Wohnsituation
- **Notfallkontakt**: 1-2 Personen mit Beziehung
- **Bankverbindung**: Ref zu Payroll-System (IBAN nicht in HR-Tool)

### 4.3 RBAC-Stand

**Bereits definiert** (6 Rollen):
AM · CM · Researcher · Admin · Backoffice + geplant: Head_of_Department

**Neu für HR-Tool:**
- **HR-Manager** — volle HR-Rechte, sensible Daten, Audit-Log-pflicht
- **Team-Lead / Vorgesetzter** — Team-Scope: Ferien-Genehmigung, Team-Übersicht, eigene MA-Details
- **Mitarbeiter-Self** — nur eigene Daten, Ferienantrag, Zertifikat-Upload, Dokument-Download

### 4.4 Feature-Flag

`feature_hr_tool` in `dim_automation_settings` — aktuell **locked (Phase 2)**. Unlock bei Phase-3-Go-Live.

---

## 5. Use-Cases · User-Journeys

### 5.1 HR-Manager · Daily Landing

1. Öffnet `/hr` → sieht **Dashboard** mit:
   - Alerts (Probezeit-Enden · Zertifikat-Expiries · Überstunden-Alerts · Ferienanträge · Austritte)
   - Action-Queue (8-10 offene Tasks)
   - Team-Kalender-Matrix (18 MA × 7 Tage)
   - Lifecycle-Pipeline (wer kommt · wer geht)
2. Klickt MA-Name → **Side-Panel** mit 8 Accordion-Sektionen
3. Erledigt Tasks direkt aus Alerts (Genehmigen, Gespräch terminieren, Dokument hochladen)

### 5.2 Vorgesetzter · Team-Führung

1. Öffnet Dashboard gefiltert auf eigenes Team
2. Bekommt Notifications bei: Ferienanträge eigener MA · 30-/60-/90-Tage-Feedbacks fällig · Zertifikat-Expiries · Probezeit-Enden
3. Terminiert Probezeit-Gespräch, protokolliert Ergebnis
4. Genehmigt/Ablehnt Ferienanträge inkl. Team-Konflikt-Check

### 5.3 Mitarbeiter · Self-Service

1. Öffnet eigenes Profil → sieht Basis-Daten, Vertrag-Übersicht, Ferien-Saldo, Zertifikate, Dokumente
2. Beantragt Ferien → Drawer mit Saldo-Check, Stellvertretung, Outlook-Auto-Reply
3. Lädt Zertifikat hoch (nach abgeschlossener Schulung)
4. Beantragt Schulung → Manager bekommt Notification + Budget-Check

### 5.4 Backoffice · Payroll-Monatsabschluss

1. Öffnet Dashboard → sieht offene Payroll-Tasks (neue MA, Austritte, Lohn-Änderungen)
2. Exportiert Monats-Delta als CSV für Treuhänder
3. Ladet Lohn-Ausweis je MA hoch → automatische Verfügbarkeit in Self-Service

### 5.5 Lifecycle · Neuer MA (Onboarding)

1. **Bewerber**-Card im Kanban erstellen (CV + Notizen)
2. Bei Entscheidung → Drag zu **Offer** · Vertrag-Vorlage generieren
3. Vertrag signiert → Drag zu **Vertrag** · Start-Datum fixiert
4. Auto-Trigger Onboarding-Template: 28 Tasks über 4 Phasen (Pre-Arrival / Day-1 / Woche-1 / Monat 1-3)
5. Drag zu **Onboarding** am Start-Datum
6. Nach Probezeit: Drag zu **Aktiv** (wenn übernommen) oder zurück zu Offer (wenn Abbruch)

### 5.6 Lifecycle · Austritt (Offboarding)

1. Kündigung erhalten → MA in Kanban zu **Offboarding** draggen
2. Auto-Trigger Offboarding-Checkliste: 15 Tasks (IT-Deprovisioning, Geräte-Rückgabe, Arbeitszeugnis, Pensionskasse-Austritt, Finale Lohn-Abrechnung)
3. Am Austritts-Tag: Auto-Archive in **Alumni**-Spalte
4. Retention-Policies greifen: Daten bleiben 5/10 J. in Alumni-Status, dann auto-Löschung (mit Legal-Hold-Override)

---

## 6. Empfohlenes Datenmodell (ARK-native)

### 6.1 Erweiterung `dim_mitarbeiter`

```sql
ALTER TABLE dim_mitarbeiter ADD COLUMN IF NOT EXISTS
  -- Person
  geburtsdatum DATE,
  geschlecht TEXT CHECK (geschlecht IN ('w','m','d')),
  nationalitaet TEXT,
  zivilstand TEXT CHECK (zivilstand IN ('ledig','verheiratet','geschieden','verwitwet','partnerschaft')),
  muttersprache TEXT,
  weitere_sprachen JSONB,

  -- Adresse
  adresse_strasse TEXT,
  adresse_plz TEXT,
  adresse_ort TEXT,
  adresse_kanton CHAR(2),
  adresse_land TEXT DEFAULT 'CH',

  -- CH-Compliance (sensible Felder, separate Verschlüsselung)
  ahv_nr_hash TEXT,                       -- SHA-256 · nie plain
  ahv_nr_encrypted BYTEA,                 -- AES-256-Verschlüsselung für Display nach Auth+Audit
  pass_nr_encrypted BYTEA,
  pass_gueltig_bis DATE,
  arbeitsbewilligung_typ TEXT,            -- 'CH','B','C','L','G','andere'
  arbeitsbewilligung_gueltig_bis DATE,
  pensionskasse_name TEXT,
  pensionskasse_nr TEXT,
  hintergrund_check_date DATE,
  hintergrund_check_result TEXT,

  -- Lifecycle-Status
  lifecycle_stage TEXT DEFAULT 'aktiv' CHECK (lifecycle_stage IN (
    'bewerber','offer','vertrag','onboarding','aktiv','offboarding','alumni'
  )),
  lifecycle_stage_since TIMESTAMPTZ DEFAULT now();
```

### 6.2 Neue Tabellen

```sql
-- Verträge (Versionierung je Anpassung)
CREATE TABLE fact_employment_contracts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  mitarbeiter_id UUID NOT NULL REFERENCES dim_mitarbeiter(id),
  contract_type TEXT NOT NULL CHECK (contract_type IN (
    'unbefristet','befristet','praktikum','lehre','mandat','fix_term'
  )),
  valid_from DATE NOT NULL,
  valid_until DATE,                                -- NULL = unbefristet
  pensum_percent NUMERIC(4,1) NOT NULL CHECK (pensum_percent > 0 AND pensum_percent <= 100),
  hours_per_week NUMERIC(4,2) NOT NULL,
  jobtitel TEXT NOT NULL,
  funktions_stufe TEXT,                            -- 'Junior','Senior','Lead','Partner',...
  arbeitsort TEXT,
  home_office_days INT DEFAULT 0,
  probezeit_monate INT DEFAULT 3,
  probezeit_ende DATE GENERATED ALWAYS AS (valid_from + (probezeit_monate || ' months')::INTERVAL) STORED,
  kuendigungsfrist_monate INT DEFAULT 3,
  kuendigungsfrist_nach_probezeit_monate INT DEFAULT 3,
  konkurrenzverbot_monate INT DEFAULT 0,
  konkurrenzverbot_radius_km INT DEFAULT 0,
  konkurrenzverbot_entschaedigung_chf NUMERIC(10,2) DEFAULT 0,
  ferien_tage_jahr INT DEFAULT 25,
  vertrag_dokument_url TEXT,
  signed_at TIMESTAMPTZ,
  signed_by_mitarbeiter BOOLEAN DEFAULT false,
  signed_by_arbeitgeber BOOLEAN DEFAULT false,
  is_active BOOLEAN GENERATED ALWAYS AS (
    (valid_until IS NULL OR valid_until >= CURRENT_DATE) AND valid_from <= CURRENT_DATE
  ) STORED,
  created_at TIMESTAMPTZ DEFAULT now(),
  created_by UUID REFERENCES dim_mitarbeiter(id)
);

-- Absenzen (Quelle-Tabelle, gespiegelt in Zeiterfassung)
CREATE TABLE fact_absences (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  mitarbeiter_id UUID NOT NULL REFERENCES dim_mitarbeiter(id),
  absence_type_id UUID NOT NULL REFERENCES dim_absence_types(id),
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  half_day_start BOOLEAN DEFAULT false,            -- nur halber Tag am Anfang
  half_day_end BOOLEAN DEFAULT false,
  working_days NUMERIC(5,2) NOT NULL,              -- Werktage netto (Feiertage/WE ausgeschlossen)
  notes TEXT,
  approval_status TEXT DEFAULT 'pending' CHECK (approval_status IN (
    'pending','approved','rejected','cancelled','auto_approved'
  )),
  approved_by UUID REFERENCES dim_mitarbeiter(id),
  approved_at TIMESTAMPTZ,
  rejection_reason TEXT,
  requested_at TIMESTAMPTZ DEFAULT now(),
  requested_by UUID REFERENCES dim_mitarbeiter(id),
  certificate_required BOOLEAN DEFAULT false,      -- Arztzeugnis bei Krank >5 Tage
  certificate_uploaded_at TIMESTAMPTZ,
  certificate_document_url TEXT,
  stellvertretung_id UUID REFERENCES dim_mitarbeiter(id),
  outlook_autoreply BOOLEAN DEFAULT true,
  cancelled_at TIMESTAMPTZ,
  cancelled_reason TEXT
);

CREATE TABLE dim_absence_types (
  id UUID PRIMARY KEY,
  code TEXT UNIQUE NOT NULL,
  label_de TEXT NOT NULL,
  paid BOOLEAN NOT NULL,
  requires_certificate BOOLEAN NOT NULL,
  requires_approval BOOLEAN NOT NULL,
  auto_approve_threshold_days INT,                 -- <=X Tage auto-approved
  counts_towards_vacation_balance BOOLEAN DEFAULT false,
  max_days_per_year INT,
  sort_order INT
);

-- Seed-Werte:
-- vacation · Ferien · paid=t · requires_cert=f · req_approval=t
-- sick · Krankheit · paid=t · requires_cert=t(>5d) · req_approval=f
-- unpaid · Unbezahlter Urlaub · paid=f · req_cert=f · req_approval=t
-- maternity · Mutterschaft · paid=t (14 Wo 80%) · req_cert=t · req_approval=f
-- paternity · Vaterschaft · paid=t (2 Wo) · req_cert=f · req_approval=t
-- military · Militär/Zivildienst · paid=t (80%) · req_cert=t · req_approval=f
-- training · Schulung · paid=t · req_approval=t
-- holiday · Feiertag · paid=t · req_approval=f · auto_approve

-- Ferien-Konto (Jahres-Snapshot)
CREATE TABLE fact_vacation_balances (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  mitarbeiter_id UUID NOT NULL REFERENCES dim_mitarbeiter(id),
  year INT NOT NULL,
  allocated_days NUMERIC(4,1) NOT NULL,
  used_days NUMERIC(4,1) DEFAULT 0,
  pending_days NUMERIC(4,1) DEFAULT 0,
  carried_from_prev_year NUMERIC(4,1) DEFAULT 0,
  carry_expires_at DATE,                           -- z.B. 30.06. des Folgejahres
  remaining_days NUMERIC(4,1) GENERATED ALWAYS AS (
    allocated_days + carried_from_prev_year - used_days - pending_days
  ) STORED,
  UNIQUE (mitarbeiter_id, year)
);

-- Onboarding-Templates + Instances
CREATE TABLE dim_onboarding_templates (
  id UUID PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  target_role TEXT,                                -- 'Consultant','Researcher','Backoffice','Manager'
  phases JSONB NOT NULL,                           -- Array: [{phase:'pre-arrival', tasks:[...]}, ...]
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE fact_onboarding_instances (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  mitarbeiter_id UUID NOT NULL REFERENCES dim_mitarbeiter(id),
  template_id UUID NOT NULL REFERENCES dim_onboarding_templates(id),
  started_at DATE NOT NULL,
  expected_completion_date DATE,
  actual_completion_date DATE,
  buddy_id UUID REFERENCES dim_mitarbeiter(id),
  mentor_id UUID REFERENCES dim_mitarbeiter(id),
  tasks_state JSONB,                               -- [{task_id, done, done_at, done_by, notes}, ...]
  notes TEXT,
  status TEXT DEFAULT 'in_progress' CHECK (status IN ('in_progress','completed','abandoned'))
);

-- Zertifikate
CREATE TABLE dim_certifications (
  id UUID PRIMARY KEY,
  name_de TEXT NOT NULL,
  issuer TEXT,
  category TEXT CHECK (category IN (
    'recruiting','assessment','soft_skills','technical','legal','other'
  )),
  typical_validity_months INT,
  renewable BOOLEAN DEFAULT true,
  is_mandatory_for_roles TEXT[],                  -- ['Consultant','Senior Consultant']
  sort_order INT
);

CREATE TABLE fact_employee_certifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  mitarbeiter_id UUID NOT NULL REFERENCES dim_mitarbeiter(id),
  certification_id UUID NOT NULL REFERENCES dim_certifications(id),
  acquired_at DATE NOT NULL,
  valid_until DATE,
  certificate_document_url TEXT,
  status TEXT GENERATED ALWAYS AS (
    CASE
      WHEN valid_until IS NULL THEN 'active'
      WHEN valid_until < CURRENT_DATE THEN 'expired'
      WHEN valid_until < CURRENT_DATE + INTERVAL '6 months' THEN 'expiring'
      ELSE 'active'
    END
  ) STORED,
  cost_chf NUMERIC(10,2),
  approved_by UUID REFERENCES dim_mitarbeiter(id)
);

-- Schulungs-Anforderungen
CREATE TABLE fact_training_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  mitarbeiter_id UUID NOT NULL REFERENCES dim_mitarbeiter(id),
  title TEXT NOT NULL,
  provider TEXT,
  type TEXT CHECK (type IN ('zertifizierung','seminar','konferenz','online','coaching','konferenz')),
  start_date DATE,
  end_date DATE,
  duration_days NUMERIC(3,1),
  cost_chf NUMERIC(10,2),
  travel_cost_chf NUMERIC(10,2) DEFAULT 0,
  justification TEXT,
  expected_certificate BOOLEAN DEFAULT false,
  status TEXT DEFAULT 'draft' CHECK (status IN (
    'draft','submitted','approved','rejected','completed','cancelled'
  )),
  submitted_at TIMESTAMPTZ,
  approved_by UUID REFERENCES dim_mitarbeiter(id),
  approved_at TIMESTAMPTZ,
  linked_certification_id UUID REFERENCES fact_employee_certifications(id)
);

-- HR-Dokumente
CREATE TABLE fact_hr_documents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  mitarbeiter_id UUID NOT NULL REFERENCES dim_mitarbeiter(id),
  document_type TEXT NOT NULL CHECK (document_type IN (
    'arbeitsvertrag','vertrags_nachtrag','arbeitszeugnis','zwischenzeugnis',
    'zertifikat','policy_acknowledgement','hintergrund_check','arztzeugnis',
    'passfoto','lebenslauf','referenzschreiben','lohnausweis','kuendigung','sonstiges'
  )),
  name TEXT NOT NULL,
  document_date DATE,
  expiry_date DATE,
  document_url TEXT NOT NULL,
  file_hash_sha256 TEXT,
  uploaded_by UUID REFERENCES dim_mitarbeiter(id),
  uploaded_at TIMESTAMPTZ DEFAULT now(),
  retention_years INT NOT NULL,                    -- 5, 10, oder solange aktiv
  retention_until_date DATE GENERATED ALWAYS AS (
    uploaded_at::DATE + (retention_years || ' years')::INTERVAL
  ) STORED,
  visibility TEXT DEFAULT 'hr_admin_self' CHECK (visibility IN (
    'hr_admin_self',            -- MA + HR + Admin
    'hr_admin_only',            -- nur HR + Admin (sensibel)
    'hr_admin_self_supervisor'  -- plus Vorgesetzter
  )),
  legal_hold BOOLEAN DEFAULT false,                -- Ausnahme von Auto-Löschung
  deleted_at TIMESTAMPTZ,
  deleted_reason TEXT
);

-- Notfallkontakte
CREATE TABLE dim_emergency_contacts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  mitarbeiter_id UUID NOT NULL REFERENCES dim_mitarbeiter(id),
  priority INT DEFAULT 1,                          -- 1 = primär, 2 = sekundär
  name TEXT NOT NULL,
  relationship TEXT NOT NULL,                      -- 'Partner','Mutter','Vater',...
  phone TEXT NOT NULL,
  phone_alt TEXT,
  email TEXT,
  last_verified_at DATE,
  UNIQUE (mitarbeiter_id, priority)
);

-- HR-Audit-Log (separat von System-Audit für DSG-Granularität)
CREATE TABLE audit_hr_access (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  timestamp TIMESTAMPTZ DEFAULT now(),
  actor_id UUID NOT NULL REFERENCES dim_mitarbeiter(id),
  action TEXT NOT NULL CHECK (action IN (
    'view','reveal_sensitive','update','create','delete','export','download'
  )),
  entity_type TEXT NOT NULL CHECK (entity_type IN (
    'mitarbeiter','contract','absence','document','certification',
    'compensation','ahv','pass','background_check','emergency_contact'
  )),
  entity_id UUID,
  target_mitarbeiter_id UUID REFERENCES dim_mitarbeiter(id),
  field_changed TEXT,                              -- nur bei update
  reason TEXT,                                     -- Begründung für sensitive Zugriffe
  ip_address INET,
  user_agent TEXT,
  status TEXT DEFAULT 'success' CHECK (status IN ('success','blocked','error'))
);

-- Lifecycle-Stage-History (für Kanban-Übergänge)
CREATE TABLE fact_lifecycle_transitions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  mitarbeiter_id UUID NOT NULL REFERENCES dim_mitarbeiter(id),
  from_stage TEXT,
  to_stage TEXT NOT NULL,
  transitioned_at TIMESTAMPTZ DEFAULT now(),
  transitioned_by UUID REFERENCES dim_mitarbeiter(id),
  reason TEXT,
  notes TEXT
);

-- Kompensations-Historie (Read-Only-Ref auf Payroll)
CREATE TABLE fact_compensation_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  mitarbeiter_id UUID NOT NULL REFERENCES dim_mitarbeiter(id),
  valid_from DATE NOT NULL,
  valid_until DATE,
  base_salary_chf_annual NUMERIC(10,2) NOT NULL,
  salary_distribution INT DEFAULT 13,              -- 12 oder 13 Monate
  commission_rate NUMERIC(4,3),
  commission_model_text TEXT,                      -- Freitext-Beschreibung
  bonus_pool_eligible BOOLEAN DEFAULT false,
  benefits JSONB,                                  -- {sbb_ga:true, handy_pauschale:80, home_office:100, ...}
  training_budget_chf NUMERIC(8,2) DEFAULT 4000,
  source TEXT DEFAULT 'payroll_system',           -- wo die Wahrheit liegt
  last_sync_at TIMESTAMPTZ,
  is_active BOOLEAN GENERATED ALWAYS AS (
    (valid_until IS NULL OR valid_until >= CURRENT_DATE) AND valid_from <= CURRENT_DATE
  ) STORED
);
```

### 6.3 Views für Reporting

```sql
-- Alerts-View (für Dashboard)
CREATE VIEW v_hr_alerts AS
SELECT
  'probezeit_ending' AS alert_type,
  m.id AS mitarbeiter_id,
  m.vorname || ' ' || m.nachname AS name,
  (ec.probezeit_ende - CURRENT_DATE) AS days_remaining,
  'urgent' AS severity
FROM dim_mitarbeiter m
JOIN fact_employment_contracts ec ON ec.mitarbeiter_id = m.id AND ec.is_active
WHERE ec.probezeit_ende BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '30 days'

UNION ALL

SELECT
  'certification_expiring',
  m.id,
  m.vorname || ' ' || m.nachname,
  (fc.valid_until - CURRENT_DATE),
  CASE WHEN fc.valid_until < CURRENT_DATE + INTERVAL '1 month' THEN 'urgent' ELSE 'warning' END
FROM dim_mitarbeiter m
JOIN fact_employee_certifications fc ON fc.mitarbeiter_id = m.id
WHERE fc.status IN ('expired','expiring')

UNION ALL

SELECT
  'vacation_approval_pending',
  m.id,
  m.vorname || ' ' || m.nachname,
  EXTRACT(DAY FROM (now() - fa.requested_at))::INT,
  CASE WHEN now() - fa.requested_at > INTERVAL '7 days' THEN 'warning' ELSE 'info' END
FROM dim_mitarbeiter m
JOIN fact_absences fa ON fa.mitarbeiter_id = m.id
WHERE fa.approval_status = 'pending';
```

### 6.4 Events

| Event-Code | Trigger | Nutzer |
|------------|---------|--------|
| `mitarbeiter_created` | Neuer MA angelegt | Audit + Onboarding-Worker |
| `lifecycle_stage_changed` | Kanban-Drag | Audit + Workflow-Trigger |
| `contract_signed` | PDF signiert | Retention + HR-Notification |
| `probezeit_ending_soon` | 30 Tage vor Ende | Vorgesetzter + HR |
| `vacation_requested` | MA stellt Antrag | Vorgesetzter-Notification |
| `vacation_approved` | Manager genehmigt | MA + Timesheet-Mirror + Outlook-Autoreply |
| `absence_started` | Krankmeldung | Team-Kalender-Update |
| `certification_expiring` | 6 Mt vor Ende | MA + HR + Vorgesetzter |
| `onboarding_task_overdue` | Task über Fälligkeit | Buddy + HR |
| `document_retention_expiring` | 30 Tage vor Auto-Löschung | HR |
| `biometric_enrolled` / `biometric_revoked` | falls Zeiterfassung-Biometrie | HR + Audit |
| `offboarding_started` | Kanban zu Offboarding | IT-Deprovisioning-Worker |
| `alumni_archived` | Austritts-Tag erreicht | Retention-Cron |

---

## 7. UI-Scope (bereits teilweise gebaut)

### 7.1 Aktueller Mockup-Stand

`mockups/ERP Tools/hr.html` = **Dashboard-First** mit:
- Header + Top-Bar (Search + Actions)
- 5 Alert-Cards
- Action-Queue (8 Tasks)
- Team-Matrix 18 MA × 7 Tage
- Lifecycle-Pipeline (7 Spalten Kanban)
- MA-Liste (Tabelle)
- Side-Panel (620px) mit 8 Accordion-Sektionen

`mockups/ERP Tools/hr-list.html` = **Tabelle-Ansicht** (CRM-Style · kann ersetzt werden durch Dashboard-Filter)

### 7.2 Noch zu bauen (nach Schema + Interactions)

| Mockup | Zweck | Priorität |
|--------|-------|-----------|
| `hr-mitarbeiter-self.html` | MA-Self-Service-Profil (Read + Self-Edit für Notfallkontakt/Adresse) | P0 |
| `hr-onboarding-editor.html` | Template-Editor für Onboarding-Checklisten | P1 |
| `hr-absence-calendar.html` | Großer Team-Kalender-Monat/Quartal-View | P1 |
| `hr-documents-admin.html` | Dokument-Retention-Monitor + Bulk-Operations | P1 |
| `hr-reports.html` | HR-Reports: Fluktuation, Absenz-Rate, Dienstalter, Trainings-Budget | P2 |
| `hr-org-chart.html` | Organigramm-Vollbild (interaktiv) | P2 |
| `hr-mobile.html` | Mobile-Self-Service (Ferienantrag, Krankmeldung, Profil) | P2 |

### 7.3 Drawer-Katalog

| Drawer | Breite | Inhalt |
|--------|--------|--------|
| Neuer MA anlegen | 760 (wide-tabs) | Basis · Vertrag · Rolle · Compliance |
| Vertrag bearbeiten | 540 | Alle Vertrags-Felder |
| Ferienantrag | 540 | Zeitraum, Saldo, Stellvertretung, Auto-Reply |
| Krankmeldung | 540 | Zeitraum, Arztzeugnis-Upload |
| Schulung anfordern | 540 | Schulung, Budget-Check, Begründung |
| Dokument hochladen | 540 | Typ, Metadaten, Retention, Sichtbarkeit |
| Zertifikat erfassen | 540 | Name, Issuer, Validity, Upload, Reminder |
| Probezeit-Abschluss | 760 | Entscheidung · Feedback Vorgesetzter · Feedback MA · Vereinbarungen |
| Kündigung einreichen | 540 | Datum, Grund, Offboarding-Trigger |
| Arbeitszeugnis-Generator | 760 | Template, Editable-Felder, Preview, Export |

---

## 8. Umsetzungs-Phasen

### Phase 3.0 · HR-Fundament (3-4 Wo Dev)

**Scope:** Mitarbeiter-Stammdaten, Verträge, Dashboard, Side-Panel, Basis-RBAC

1. Migration: Erweiterung `dim_mitarbeiter` + neue Tabellen (contracts, emergency_contacts, compensation_history, lifecycle_transitions, audit_hr_access)
2. Endpoints: `GET/PATCH /api/v1/employees/:id` · `POST /api/v1/employees` · `POST /api/v1/contracts`
3. UI: `hr.html` (Dashboard) geht live · Side-Panel mit 8 Accordion-Sektionen
4. RBAC-Erweiterung: `HR_Manager` · `Team_Lead` · `Employee_Self`
5. Sensible-Daten-Layer: AHV/Pass maskiert, Aufdecken mit Audit-Log
6. Feature-Flag-Entlock `feature_hr_tool`

**DoD:** HR-Manager kann alle 18 MA sehen, neuen MA anlegen, Vertrag bearbeiten. Alle sensiblen Zugriffe im Audit-Log.

### Phase 3.1 · Absenzen + Kalender (2 Wo Dev)

1. Migration: `fact_absences` · `dim_absence_types` · `fact_vacation_balances` · `fact_holidays` · `dim_holiday_calendars`
2. Endpoints: Ferienantrag-Flow · Genehmigungs-Flow · Saldo-Query
3. Worker: Kantonale Feiertage seeden (ZH, BS, BE, ZG, SG initial)
4. UI: Drawer Ferienantrag + Krankmeldung · Team-Matrix live · `hr-absence-calendar.html`
5. Integration: Outlook-Auto-Reply-Toggle (nutzt Email-Tool-Tokens)

**DoD:** MA beantragt Ferien → Vorgesetzter genehmigt → Team-Kalender zeigt Absenz → Outlook-Auto-Reply aktiv.

### Phase 3.2 · Onboarding + Zertifikate (2-3 Wo Dev)

1. Migration: `dim_onboarding_templates` · `fact_onboarding_instances` · `dim_certifications` · `fact_employee_certifications` · `fact_training_requests`
2. Template-Seeds: "Consultant" · "Researcher" · "Backoffice"
3. Endpoints: Task-Completion, Template-Clone, Zertifikat-Upload, Schulungs-Request
4. Worker: Expiring-Certs-Reminder (90/30 Tage) · Overdue-Tasks-Alert
5. UI: Onboarding-Checklist im Side-Panel · Zertifikat-Erfassen-Drawer · `hr-onboarding-editor.html`

**DoD:** Neuer MA → Auto-Onboarding-Template attacht · Tasks abarbeitbar · Zertifikat-Ablauf flaggt Alert.

### Phase 3.3 · Dokumente + DSG-Retention (1-2 Wo Dev)

1. Migration: `fact_hr_documents` mit Auto-Retention
2. Storage: Azure Blob / S3 verschlüsselt
3. Endpoints: Upload (multipart), Download (mit Audit), Bulk-Retention-Check
4. Worker: Retention-Expiry-Reminder (30 Tage vor Auto-Löschung) · Legal-Hold-Override-Log
5. UI: Document-Drawer mit Sichtbarkeits-Scope · `hr-documents-admin.html` (Bulk-Admin)

**DoD:** PDF-Ablage funktioniert · Retention-Regeln greifen · DSG-Auskunftsrecht abbildbar (Self-Service-Export).

### Phase 3.4 · Lifecycle + Kanban (1-2 Wo Dev)

1. Migration: `fact_lifecycle_transitions` · Erweiterung `dim_mitarbeiter.lifecycle_stage`
2. Endpoints: Stage-Transition · Offboarding-Template-Auto-Attach
3. Worker: Austritts-Cron (täglich) · Alumni-Auto-Archive · IT-Deprovisioning-Trigger
4. UI: Kanban-Drag-Drop live · Offboarding-Checkliste-Drawer · Kündigungs-Drawer

**DoD:** Drag von Aktiv → Offboarding triggert Checkliste · Austritt-Datum → Auto-Alumni.

### Phase 3.5 · Self-Service (2 Wo Dev)

1. Endpoints: Self-View-Scope (eigene Daten lesen + begrenzte Edit-Rechte)
2. UI: `hr-mitarbeiter-self.html` · Mobile-View
3. Auskunftsrecht-Export: PDF mit allen eigenen Daten (DSG Art. 25)
4. Integration: Zertifikat-Upload · Schulungs-Request · Ferienantrag

**DoD:** MA loggt ein, sieht nur eigene Daten, kann Ferien beantragen, Zertifikat hochladen.

### Phase 3.6 · Reports + Org-Chart (optional, 1-2 Wo)

- HR-Reports (Fluktuation, Absenz-Rate, Trainings-Budget, Dienstalter)
- Interaktiver Org-Chart
- Export zu Payroll (CSV für Treuhänder)

---

## 9. Abhängigkeiten

| Erforderlich VOR Start | Begründung |
|------------------------|------------|
| Feature-Flag-System (Admin-Vollansicht) | `feature_hr_tool` Unlock-Point |
| Blob-Storage (Azure/S3) + Encryption | HR-Dokumente |
| Email-Worker mit Outlook-Tokens | Auto-Reply bei Ferien |
| Audit-Log-Infrastruktur (`fact_audit_log`) | existiert bereits |
| RBAC-Matrix-Erweiterung | neue Rollen HR_Manager etc. |
| Kantonale Feiertag-Daten (Seed) | Absenz-Werktag-Berechnung |

---

## 10. Risiken

| Risiko | W | I | Mitigation |
|--------|---|---|------------|
| MA-Skepsis bei Self-Service (Surveillance-Fear) | mittel | mittel | Transparente Kommunikation · keine Performance-Metrics im HR-Tool |
| DSG-Verstoß bei sensiblen Daten | niedrig | sehr hoch | Sensible-Daten-Layer + Audit + Retention-Automation |
| Kantonale Feiertag-Drift | mittel | niedrig | Jährlicher Maintenance-Task · Seed aus offiziellen Quellen |
| Payroll-Sync-Drift | mittel | mittel | Read-Only-Attitude · Payroll bleibt SSOT · `last_sync_at` tracking |
| Onboarding-Template-Over-Engineering | hoch | niedrig | MVP 3 Templates · Dynamisches Hinzufügen erst Phase 3.2+ |
| Kanban-Drag-Drop-Konflikte (Race-Conditions) | niedrig | mittel | Optimistic Locking mit `lifecycle_stage_since` |
| Austrittsprozess verzögert → alte Daten bleiben | mittel | mittel | Auto-Alumni-Cron + Legal-Hold-Override |

---

## 11. Offene Entscheidungen für Peter

1. **Bewerber-Phase im Kanban**: Inklusive oder separates Recruiting-Tool (Phase 4)?
2. **Payroll-Export-Format**: Bexio-CSV · Abacus-XML · Swissdec-ELM-Standard · oder alle drei?
3. **Arbeitszeugnis-Generator**: Phase 3.0 inbegriffen oder später Phase 3.6?
4. **Lohnausweis-Upload durch wen**: Backoffice manuell · Auto-Import aus Payroll · oder Self-Service?
5. **Notfallkontakt-Priorität**: max. 1 · 2 · oder unlimited?
6. **Feiertags-Kantone**: welche seeden initial (Wohnort-basiert vs. Arbeitsort-basiert)?
7. **Sprachanforderungen**: nur DE · oder auch FR (falls Peter Westschweiz-Expansion plant)?
8. **Arzt-Zeugnis-Pflicht ab wann**: 3 Tage · 5 Tage (Standard) · 7 Tage?
9. **Ferien-Übertrag-Regel**: kompletter Übertrag ins Folgejahr · max 5 Tage · Stichtag 30.06.?
10. **Dienstjubiläums-Gratifikation**: automatisch erkennen + HR-Alert · oder manuell?
11. **Geburtstags-Erinnerung im Team-Kalender**: sichtbar · opt-in · deaktiviert?
12. **Probezeit-Default-Dauer**: 3 Mt (OR-Standard) · 6 Mt (Senior) · je nach Funktionsstufe?

---

## 12. Verschieben zu anderen Modulen

**Wird nicht im HR-Tool gebaut, landet woanders:**

| Feature | Wo |
|---------|-----|
| Zeiterfassung | Phase-3-Zeiterfassung (separates Tool) |
| Performance-Reviews | Phase-3-Performancetool (geplant) |
| Lohnabrechnung/Sozialbeiträge | Payroll-System (Treuhänder/Bexio) · nur Read-Only-Ref |
| Stellenausschreibungen | Phase-3-Publishing (geplant) |
| Kandidaten-Pipeline | CRM (Phase 1) |
| Provisions-Berechnung | Phase-3-Billing (CRM 2.0) |

---

## Related

- `mockups/ERP Tools/hr.html` · `hr-list.html` — Aktuelle Mockups (Dashboard-First)
- `specs/ARK_ZEITERFASSUNG_PLAN_v0_1.md` — Schwester-Plan (Cross-Dependencies: Absenzen-Mirror, Mitarbeiter-Stammdaten)
- `specs/ARK_ZEITERFASSUNG_RESEARCH_ADDENDUM_v0_1.md` — DSG-Lessons-Learned (auch für HR relevant)
- Memory `project_arkadium_role.md` — Arkadium-Touchpoints (Briefing/Coaching/Debriefing)
- Memory `project_commission_model.md` — Provisions-Modell (für HR-Kompensation-Tab)
- Memory `project_phase3_erp_standalone.md` — Standalone-Prinzip
- Künftig: `ARK_HR_TOOL_SCHEMA_v0_1.md` · `ARK_HR_TOOL_INTERACTIONS_v0_1.md`
