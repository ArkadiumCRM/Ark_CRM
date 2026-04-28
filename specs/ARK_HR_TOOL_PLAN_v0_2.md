---
title: "ARK HR-Tool · Umsetzungsplan v0.2"
type: plan
phase: 3
created: 2026-04-19
updated: 2026-04-19
supersedes: "ARK_HR_TOOL_PLAN_v0_1.md"
status: po-reviewed
po_review_date: 2026-04-19
po_review_status: "§11A/§11B/§11C komplett beantwortet (18/18) · bereit für Schema v0.1"
sources: [
  "ARK_HR_TOOL_PLAN_v0_1.md (supersedes)",
  "wiki/analyses/hr-schema-deltas-2026-04-19.md",
  "wiki/sources/hr-arbeitsvertraege.md",
  "wiki/sources/hr-reglemente.md",
  "wiki/sources/hr-provisionsvertraege.md",
  "wiki/sources/hr-arbeitszeugnisse.md",
  "wiki/sources/hr-weiterbildungsvereinbarung.md",
  "wiki/sources/hr-stellenbeschreibung-progressus.md",
  "wiki/sources/hr-kuendigung-aufhebung.md",
  "wiki/sources/hr-austritt-versicherung-merkblaetter.md",
  "wiki/concepts/hr-vertragswerk.md",
  "wiki/concepts/hr-academy.md",
  "wiki/concepts/hr-konkurrenz-abwerbeverbot.md",
  "wiki/concepts/hr-ma-rollen-matrix.md",
  "mockups/ERP Tools/hr.html (Dashboard-First-Redesign)",
  "raw/Ark_CRM_v2/ARK_DATABASE_SCHEMA_v1_3.md § dim_mitarbeiter",
  "raw/Ark_CRM_v2/ARK_BACKEND_ARCHITECTURE_v2_5.md",
  "raw/Ark_CRM_v2/ARK_STAMMDATEN_EXPORT_v1_3.md",
  "memory/project_arkadium_role.md",
  "memory/project_commission_model.md",
  "memory/project_phase3_erp_standalone.md",
  "memory/project_activity_linking.md",
  "memory/project_sprache_policy.md"
]
tags: [plan, erp, hr, phase-3, arkadium-vertragswerk, academy, praemium-victoria, standalone]
---

# ARK HR-Tool · Phase-3-Umsetzungsplan v0.2

**Änderungen v0.1 → v0.2 (2026-04-19):** Konsolidierung nach Tier-1-Ingest des Arkadium-Vertragswerks (26 DOCX + 2 PDFs aus `raw/HR/`). Plan-Fragen aus §11 zu 5/12 verbindlich beantwortet (Arztzeugnis-Staffelung · Probezeit · Feiertage · Sprachen · Bewerber-Phase). Datenmodell §6 erweitert um 8 neue Entitäten (Reglemente-Versionierung · Academy-Module · Disziplinar · Verwarnungen · Provisionsvertrag-Renewal · Weiterbildungsvereinbarung · Job-Descriptions · Role-Transitions). Zwei neue Phasen (3.7 Disziplinar · 3.8 Provisionsvertrag-Renewal-Cycle). 12 neue offene Fragen. Volltext-Änderungslog §14.

Grundlage für `ARK_HR_TOOL_SCHEMA_v0_1.md` + `ARK_HR_TOOL_INTERACTIONS_v0_1.md`. **Eigenständiges ARK-Produkt** (Memory `project_phase3_erp_standalone.md`) — kein Personio-Clone, sondern ARK-Native-HR mit optionalem Export zu externen Systemen.

---

## 1. Scope · Was ist das HR-Tool

**Zielgruppe intern:** HR-Manager (oft Personalunion mit GL-Assistent) · Vorgesetzte (AM/CM mit Team) · Mitarbeitende (Self-Service) · Backoffice (Payroll-Export).

**Zielgruppe extern:** Treuhänder/Payroll-Anbieter (CSV/API-Export).

**Was das HR-Tool IST:**

- Zentrale Verwaltung aller Mitarbeiter-Daten (MA-Stammdaten, Verträge, Compliance, Dokumente)
- Lifecycle-Management: **Offer → Vertrag → Onboarding → Aktiv → Offboarding → Alumni** (Bewerber raus, bleibt im CRM)
- Vertragswerk-Orchestrierung: Arbeitsvertrag + 3 Reglemente + Stellenbeschreibung + Provisionsvertrag als integrale Bestandteile (siehe [[hr-vertragswerk]])
- Absenzen-Management (Ferien, Krankheit mit Dienstjahr-Staffelung, Militär/Zivil/Rotkreuz/Feuerwehr, Mutterschaft/Vaterschaft, Weiterbildung, Extra-Guthaben)
- Home-Office + Remote-Work-Quota-Tracking (Locus Extra)
- Academy-Module + Lernfortschritt (Communication Edge, M4, Lernkarteien, M 1-4)
- Onboarding-Checklisten (template-basiert, Academy-gekoppelt)
- Zertifikat-Tracker mit Expiry-Alerts (Scheelen MDI/Relief/ASSESS/EQ, LinkedIn Recruiter, etc.)
- Weiterbildungsvereinbarungen mit Pensum-Impact + Rückzahlungs-Staffel
- HR-Dokumenten-Ablage mit DSG-Retention-Regeln
- Verwarnungs- + Eskalations-Tracker (informell → erste → letzte → Kündigung)
- Disziplinar-Incidents + Konventionalstrafen (Arkadium-spezifisches Sanktionswerk)
- Audit-Log für sensible Daten (AHV, Gehalt, Pass)
- Self-Service-Portal (eigenes Profil, Ferienantrag, Zertifikate, HO/Remote-Antrag)
- Konkurrenzverbot-Monitor post-Austritt (18-Mt-Countdown, Alumni-Status)
- Provisionsvertrag-Renewal (Praemium Victoria) mit Budget-Ziel-Setting (Q4 Vorjahr) + Commission-Engine-Bridge

**Was das HR-Tool NICHT ist:**

- Keine Payroll-Engine (Lohnabrechnung · Sozialbeiträge · Quellensteuer-Berechnung — lebt im Payroll-System/Treuhänder)
- Keine Performance-Reviews (siehe Phase-3-Performancetool)
- Keine Zeiterfassung (siehe Phase-3-Zeiterfassung)
- Keine Recruiting-Funnel für externe Kandidaten (das ist CRM)
- Keine Workflow-Engine für komplexe Approval-Chains (simple Manager-Genehmigung genügt)
- Kein LMS (Learning-Management-System — Enrollment-Tracking reicht, externe Kurse via LinkedIn-Learning/Udemy)
- Keine Commission-Berechnung (eigenes Commission-Engine-Modul; HR-Tool liefert nur `fact_provisionsvertrag_versions` + Rollen-Historie)

---

## 2. Markt-Überblick · HR-Tools für KMU (15-50 MA)

*(unverändert zu v0.1)*

| Tool | Herkunft | Stärke | Preis | Relevanz ARK |
|------|----------|--------|-------|--------------|
| **Personio** | DE | Voll-HR + Payroll + Recruiting, Marktführer DACH KMU | CHF 12-18/MA/Mt | Feature-Benchmark, aber über-engineert für 20 MA |
| **BambooHR** | US | Einfache UX, starker Self-Service | CHF 8-15/MA/Mt | Feature-Benchmark Self-Service |
| **Factorial** | ES | HR + Zeit + Documents | CHF 6-12/MA/Mt | gute Abwesenheits-UX |
| **HiBob** | UK | Moderne UX, Culture-Tool | CHF 10-14/MA/Mt | UX-Inspiration |
| **Workday** | US | Enterprise-HR | CHF 30+/MA/Mt | **over-scope** |
| **HRworks** | DE | DACH-Fokus | CHF 7/MA/Mt | Feature-Baseline |
| **Bexio HR** | CH | In Bexio integriert | Bexio Pro + Add-on | Payroll-Bezug |
| **Abacus HR** | CH | CH-Treuhand-Standard | Enterprise | Payroll-Referenz, Export-Format |

**Take-Away:** Feature-Fokus Personio/BambooHR (Lifecycle + Absenzen + Dokumente + Self-Service) · UX-Inspiration HiBob/Factorial/BambooHR · Payroll-Export Abacus/Bexio-kompatibel.

---

## 3. CH-Arbeitsrecht + Arkadium-Vertragswerk

### 3.1 CH-Pflichten für HR-System

| Regel | Quelle | Impact |
|-------|--------|--------|
| Arbeitsvertrag schriftlich | OR Art. 319 ff. | PDF-Ablage Pflicht, 5 J. nach Austritt |
| Arbeitszeugnis bei Austritt | OR Art. 330a | Vorlagen-Generator (Phase 3.6) |
| AHV-Anmeldung 10-Tage-Frist | AHVG Art. 5 | Auto-Reminder + Formular-Export |
| Pensionskasse 10-Tage-Frist | BVG Art. 10 | Auto-Reminder |
| Quellensteuer-Anmeldung | DBG Art. 88 | Kanton-spezifisch je MA |
| Unfallversicherung UVG | UVG Art. 7 | Info + Ablage |
| Ordentliche Kündigung | OR Art. 335 | Kündigungsfrist-Staffelung |
| Fristlose Kündigung | OR Art. 337 | Nur aus wichtigem Grund |
| Konkurrenzverbot post-AV | OR Art. 340 ff. | max 3 Jahre · regional/sachlich limitiert |
| Persönlichkeitsschutz | ZGB Art. 28 · OR 328 | Mobbing/Diskriminierung-Schutz |
| UVG-Abredeversicherung | UVG Art. 3 | Pflicht-Merkblatt bei Austritt |
| KTG-Übertrittsrecht | VVG · AVB | Pflicht-Merkblatt bei Austritt |
| Aufbewahrung 5-10 J. | OR · AHVG · BVG | Auto-Retention-Rules |

### 3.2 Arkadium-spezifische Ergänzungen (aus Vertragswerk)

**Kündigungsfristen-Staffelung** (§9 Arbeitsvertrag):

| Zeitraum | Frist |
|----------|-------|
| Probezeit (0–3 Mt) | 3 Tage jederzeit |
| 1. Dienstjahr | 1 Monat |
| 2.–5. Dienstjahr | 2 Monate |
| ab 6. Dienstjahr | 3 Monate |

**Arztzeugnis-Pflicht** (Generalis Provisio §3.5.2):

| Dienstjahr | Zeugnis ab |
|------------|-----------|
| 1. DJ | Tag 1 |
| 2. DJ | Tag 2 |
| ab 3. DJ | Tag 3 |

(AG darf jederzeit Zeugnis ab Tag 1 verlangen — Treuepflicht-Klausel.)

**Konkurrenzverbot + Abwerbeverbot** (siehe [[hr-konkurrenz-abwerbeverbot]]):

- 18 Monate nach AV-Ende
- Gebiet: Deutschschweiz
- Branche: Bau/Baunebengewerbe/Architecture/Civil-Engineering/Real-Estate/Building-Technology/Energy-Environmental
- Karenzentschädigung monatlich brutto: CHF 500 Consultant · CHF 350 Researcher (als Kompensation)
- Konventionalstrafen:
  - Konkurrenzverbot post-AV: 12 Bruttomonatslöhne, min CHF 80'000
  - Abwerbeverbot post-AV: CHF 80'000/Zuwiderhandlung
  - Geheimhaltung post-AV: CHF 20'000/Zuwiderhandlung

**Disziplinarstrafen während AV** (Arbeitsvertrag §10):

| Verletzung | Strafe |
|-----------|--------|
| Konkurrenzierung | CHF 20'000 |
| Abwerbung | CHF 10'000 |
| Nebentätigkeit ohne Zustimmung | CHF 3'000 |
| Diffamierende Äusserung | CHF 5'000 |
| Geschäftsgeheimnis-Verletzung | CHF 20'000 |

### 3.3 DSG-Baseline

*(unverändert zu v0.1)*

| Datentyp | Klassifikation | Zugriff |
|----------|---------------|---------|
| Name, Email, Telefon | Personendaten | MA + Vorgesetzter + HR + Admin |
| Adresse, Geburtsdatum, Zivilstand | Personendaten | MA + HR + Admin |
| AHV-Nr, Pass-Nr | **Sensible Daten (Art. 5 DSG)** | nur HR + Admin + MA-Self (Audit-Log) |
| Gehalt, Provisionsbasis | Personendaten, intern sensibel | nur HR + Backoffice + Admin + MA-Self |
| Krankheits-Notizen, Arztzeugnis | **Sensible Daten (Gesundheit)** | nur HR + Admin (MA hat Auskunftsrecht) |
| Hintergrund-Check-Report | **Sensible Daten** | nur HR + Admin |
| Disziplinar-Incidents | **Sensible Daten** | nur HR + GL + Admin (Audit-Log) |

**Konsequenzen:**
- Sensible Felder maskiert anzeigen · Aufdecken mit Audit-Log
- Retention-Policies automatisch (5/10 J.)
- Self-Service-Export (DSG Art. 25 Auskunftsrecht)
- Löschung nach Retention + Legal-Hold-Flag

---

## 4. Interne System-Referenzen

### 4.1 Bereits vorhandene `dim_mitarbeiter` (DB-Schema v1.3)

*(unverändert zu v0.1)*
- **Person:** `vorname`, `nachname`, `email`, `eintrittsdatum`, `austrittsdatum`
- **Organisation:** `sparte_id` (FK), `team`, `standort`, `vorgesetzter_id` (FK)
- **Rollen:** `rolle` (deprecated), `bridge_mitarbeiter_roles` (N:N, 6 Rollen)
- **KPIs/Targets:** `target_calls_day`, `target_briefings_month`, `target_gos_month`, `target_placements_year`, `target_revenue_year`
- **Finanziell:** `commission_rate` (0.3 default) — **DEPRECATED in v0.2**, ersetzt durch `fact_provisionsvertrag_versions`
- **System:** `auth_user_id`, `threecx_extension`, `status`, `dashboard_config` JSONB, `email_signature_html`

### 4.2 Neue Arkadium-Kontext-Felder (aus Vertragswerk)

- **Vertrag:** Karenzentschädigung, Pensum %, Vertragstyp, Kündigungsfristen-JSONB, Probezeit-Ende, Arbeitsort-Details, Home-Office-Quota
- **CH-Compliance:** AHV-Nr (hashed), Pass-Nr, Kanton, Arbeitsbewilligung, Pensionskasse
- **Person:** Geburtsdatum, Geschlecht, Nationalität, Zivilstand, Muttersprache
- **Adresse:** Strasse, PLZ/Ort, Kanton, Land, Wohnsituation
- **Notfallkontakt:** max 2 Personen mit Beziehung
- **Bankverbindung:** Ref zu Payroll-System (IBAN nicht in HR-Tool)
- **Arkadium-spezifisch:**
  - `current_job_description_id` (Progressus-Link)
  - `current_reglement_*_version` (3x, für Generalis Provisio · Tempus Passio · Locus Extra)
  - `head_of_department_id` (direkte Führung)
  - `signing_authority` (none · limited · full)
  - `academy_lead_id` (Ausbildungs-Verantwortlicher)
  - `konkurrenzverbot_aktiv_bis` (für Alumni-Monitor)

### 4.3 RBAC-Stand

**Bereits definiert** (6 Rollen): AM · CM · Researcher · Admin · Backoffice · Head-of-Department (geplant)

**Neu für HR-Tool:**
- **HR_Manager** — volle HR-Rechte, sensible Daten, Audit-Log-Pflicht
- **Team_Lead** — Team-Scope: Ferien-Genehmigung, Team-Übersicht, MA-Details
- **Employee_Self** — eigene Daten, Ferienantrag, Zertifikat-Upload, Dokument-Download
- **Academy_Lead** *(neu v0.2)* — Ausbildungs-Tracking, Modul-Freigaben, Lernfortschritt sichten

### 4.4 Feature-Flag

`feature_hr_tool` in `dim_automation_settings` — aktuell **locked (Phase 2)**. Unlock bei Phase-3-Go-Live.

### 4.5 Arkadium-Vertragswerk (neu v0.2)

5-Schicht-Stack (siehe [[hr-vertragswerk]]):

```
ARBEITSVERTRAG (Hauptvertrag, stabil)
  ├─ Reglement "Generalis Provisio" (Allgemeine Anstellungsbedingungen)
  ├─ Reglement "Tempus Passio 365" (Arbeitszeit)
  ├─ Reglement "Locus Extra" (Mobiles Arbeiten)
  ├─ Beschreibungen "Progressus" (Stellen-/Kompetenzbeschreibung)
  └─ Vertrag "Praemium Victoria" (Provisionsvertrag, jährlich)
```

**Widerspruchs-Regel:** Arbeitsvertrag > Reglemente > OR > zwingendes Recht.

---

## 5. Use-Cases · User-Journeys

### 5.1 HR-Manager · Daily Landing

*(unverändert zu v0.1)*

1. Öffnet `/hr` → **Dashboard** mit Alerts · Action-Queue · Team-Kalender-Matrix · Lifecycle-Pipeline
2. Klickt MA-Name → **Side-Panel** mit Accordion-Sektionen (inkl. neu: Verwarnungen · Disziplinar-Incidents · Academy-Progress)
3. Erledigt Tasks direkt aus Alerts

### 5.2 Vorgesetzter · Team-Führung

1. Dashboard gefiltert auf eigenes Team
2. Notifications bei: Ferien-/HO-Anträge · Probezeit-/Feedback-Deadlines · Zertifikat-Expiries · **§5.3-Praemium-Grace-Period-Endings**
3. Terminiert Probezeit-Gespräch, protokolliert Ergebnis
4. Genehmigt/Ablehnt Anträge inkl. Team-Konflikt-Check (50% Ferien · 70% HO-Abdeckung)

### 5.3 Mitarbeiter · Self-Service

1. Eigenes Profil → Basis-Daten · Vertrag · Ferien-Saldo (inkl. **5 Extra-Guthaben-Kategorien**) · Zertifikate · Dokumente · **Academy-Lernfortschritt**
2. Beantragt Ferien → Saldo-Check · Stellvertretung · Outlook-Auto-Reply
3. Beantragt **Home-Office/Remote-Work** → 48h-Lead-Time · Projekt-Context · Quota-Check
4. Lädt Zertifikat hoch
5. Beantragt Schulung → Manager-Genehmigung + Budget-Check

### 5.4 Backoffice · Payroll-Monatsabschluss

*(unverändert zu v0.1)*

### 5.5 Lifecycle · Neuer MA (Onboarding)

**Angepasst v0.2 — Bewerber-Phase raus:**

1. **Offer**-Card im Kanban erstellen (nach CRM-Recruiting-Abschluss · Link auf CV + Interview-Notizen)
2. Bei Entscheidung → Drag zu **Vertrag** · Vertrag-Vorlage generieren · Reglemente + Progressus + Praemium Victoria zusammenstellen
3. Vertrag signiert → Drag zu **Onboarding** · Academy-Modul-Liste attacht (Consultant: 14 Wochen / Researcher: 8 Wochen)
4. Auto-Trigger Onboarding-Template: Pre-Arrival / Day-1 / Woche-1 / Monat 1-3
5. Nach Probezeit: Drag zu **Aktiv** (wenn übernommen) oder zurück zu Offer (wenn Abbruch)

### 5.6 Lifecycle · Austritt (Offboarding)

**Erweitert v0.2 mit Verwarnungs-Branch:**

```
ACTIVE
 ├─ warning_verbal → ACTIVE (documented)
 ├─ warning_first_written → UNDER_WATCH
 │   ├─ compliance → ACTIVE
 │   └─ warning_final_written → FINAL_WATCH
 │       ├─ mutual_agreement → OFFBOARDING_AMICABLE (Aufhebungsvertrag)
 │       ├─ fristlose_kuendigung → OFFBOARDING_IMMEDIATE (Art. 337 OR)
 │       └─ ordentliche_kuendigung → OFFBOARDING_NOTICE
 ├─ resignation → OFFBOARDING_NOTICE
 │   └─ annullierung → ACTIVE (nahtlos, keine neue Probezeit)
 └─ retirement / death → OFFBOARDING_SPECIAL
```

**Offboarding-Checkliste (15 Tasks, inkl. Arkadium-spezifisch — siehe [[hr-austritt-versicherung-merkblaetter]]):**

1. IT-Deprovisioning
2. Geräte-Rückgabe
3. **KKV-Merkblatt AXA übergeben + Rückläufer** (neu v0.2)
4. **Abredeversicherungs-Merkblatt AXA übergeben + Rückläufer** (neu v0.2)
5. Arbeitszeugnis erstellen + übergeben (OR 330a)
6. Pensionskasse-Austritt
7. Schlussabrechnung (inkl. Rest-Ferien + Weiterbildungs-Rückzahlung falls fällig)
8. AHV-Austrittsmeldung
9. BVG-Austrittsmeldung
10. Akten-/Daten-Rückgabe
11. Konkurrenzverbots-Erinnerung + Karenzentschädigung-Check
12. Schlüssel/Badge/Parkplatz
13. **Provisions-Endabrechnung + §6.2-laufende-Prozesse-Vergütung** (Bridge zu Commission-Engine)
14. Email-Auto-Reply einrichten (Übergabe-Kontakt)
15. Alumni-Status setzen · 18-Mt-Konkurrenzverbots-Clock startet

### 5.7 Verwarnungs-Eskalation (neu v0.2)

**siehe [[hr-kuendigung-aufhebung]]**

1. HR/GL dokumentiert Vorfall → `fact_warnings` mit `warning_type = 'verbal'`
2. Wiederholung → `warning_type = 'first_written'` · Dokument aus Template · Follow-up-Deadline gesetzt (30 Tage)
3. Keine Besserung → `warning_type = 'final_written'` · Eskalations-Drohung · alternative Aufhebung-Option
4. Entscheidung: Compliance / Aufhebungsvertrag / fristlose Kündigung / ordentliche Kündigung

### 5.8 Disziplinar-Incident (neu v0.2)

**siehe [[hr-konkurrenz-abwerbeverbot]]**

1. HR meldet Vorfall (Konkurrenzierung · Diffamation · Geheimnis-Verletzung etc.)
2. `fact_disciplinary_incidents` mit `status = 'investigation'`
3. Evidenz sammeln (Dokumente, E-Mail-Screenshots, Zeugen)
4. GL entscheidet: `confirmed` · `dismissed`
5. Bei `confirmed` → Payroll-Verrechnung (Option: `offset_against_salary = true`)
6. Audit-Trail für evtl. Gerichtsverfahren

### 5.9 Provisionsvertrag-Jahres-Renewal (neu v0.2)

**Praemium Victoria wird jährlich neu geschlossen.**

1. **Oktober/November Vorjahr:** Budget-Ziel-Setting-Workshop HR + GL + Head-of-Department pro MA
2. **Dezember:** `fact_provisionsvertrag_versions` für kommendes Jahr angelegt (Entwurf)
3. **Ende Dezember/Januar:** Signatur-Flow je MA · Bündel-PDF aus Template
4. **Jährlich durchgehend:** Commission-Engine bezieht sich auf aktive `fact_provisionsvertrag_versions`-Row

---

## 6. Datenmodell (v0.2 komplett konsolidiert)

### 6.1 Erweiterung `dim_mitarbeiter`

```sql
ALTER TABLE dim_mitarbeiter ADD COLUMN IF NOT EXISTS
  -- Person
  geburtsdatum DATE,
  geschlecht TEXT CHECK (geschlecht IN ('w','m','d')),
  nationalitaet TEXT,
  zivilstand TEXT CHECK (zivilstand IN ('ledig','verheiratet','geschieden','verwitwet','partnerschaft')),
  muttersprache TEXT DEFAULT 'de',                          -- DE only Policy · Memory project_sprache_policy.md
  weitere_sprachen JSONB,                                    -- EN als 'nice-to-have', nicht Pflicht

  -- Adresse
  adresse_strasse TEXT,
  adresse_plz TEXT,
  adresse_ort TEXT,
  adresse_kanton CHAR(2),
  adresse_land TEXT DEFAULT 'CH',

  -- CH-Compliance (sensible Felder · AES-256 + Audit-Log)
  ahv_nr_hash TEXT,
  ahv_nr_encrypted BYTEA,
  pass_nr_encrypted BYTEA,
  pass_gueltig_bis DATE,
  arbeitsbewilligung_typ TEXT,
  arbeitsbewilligung_gueltig_bis DATE,
  pensionskasse_name TEXT,
  pensionskasse_nr TEXT,
  hintergrund_check_date DATE,
  hintergrund_check_result TEXT,

  -- Lifecycle (v0.2: Bewerber raus)
  lifecycle_stage TEXT DEFAULT 'aktiv' CHECK (lifecycle_stage IN (
    'offer','vertrag','onboarding','aktiv','under_watch','final_watch',
    'offboarding_amicable','offboarding_immediate','offboarding_notice',
    'offboarding_special','alumni'
  )),
  lifecycle_stage_since TIMESTAMPTZ DEFAULT now(),

  -- Arkadium-spezifisch (neu v0.2)
  current_job_description_id UUID REFERENCES dim_job_descriptions(id),
  current_reglement_generalis_provisio_version TEXT,
  current_reglement_tempus_passio_version TEXT,
  current_reglement_locus_extra_version TEXT,
  head_of_department_id UUID REFERENCES dim_mitarbeiter(id),
  academy_lead_id UUID REFERENCES dim_mitarbeiter(id),
  signing_authority TEXT CHECK (signing_authority IN ('none','limited','full')) DEFAULT 'none',
  konkurrenzverbot_aktiv_bis DATE,                           -- bei Austritt: austritt + 18 Mt

  -- DEPRECATED v0.2 (wird durch fact_provisionsvertrag_versions ersetzt):
  -- commission_rate NUMERIC(4,3)
  ;
```

### 6.2 Neue Tabellen — Vertragswerk

```sql
-- dim_job_descriptions (Progressus versioniert)
CREATE TABLE dim_job_descriptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code TEXT UNIQUE NOT NULL,                       -- 'consultant', 'research_analyst', 'team_leader_rem', ...
  name_de TEXT NOT NULL,
  bereich TEXT NOT NULL,                           -- 'Executive & Professional Search'
  abteilung TEXT,
  sparte TEXT,                                     -- 'ARC','REM','ING','TEC' oder Kombinationen
  signing_authority BOOLEAN DEFAULT false,
  default_pensum INT DEFAULT 100,
  zielbeschreibung_de TEXT,
  aufgaben JSONB,                                  -- Array of bullet points
  anforderungen JSONB,                             -- {ausbildung, weiterbildung, erfahrung, kompetenzen, sprachen}
  version TEXT,                                    -- '2024-01-01'
  valid_from DATE,
  valid_until DATE,
  document_url TEXT,                               -- Progressus-PDF
  superseded_by UUID REFERENCES dim_job_descriptions(id)
);

-- dim_reglemente (versionierte Anhänge)
CREATE TABLE dim_reglemente (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  latin_name TEXT UNIQUE NOT NULL,                 -- 'generalis_provisio', 'tempus_passio_365', 'locus_extra'
  name_de TEXT NOT NULL,
  description_de TEXT,
  version TEXT NOT NULL,                           -- '2024-01-01'
  valid_from DATE NOT NULL,
  valid_until DATE,
  document_draft_url TEXT,                         -- ENTWURF-Variante (WIP)
  document_digital_url TEXT,                       -- DIGITAL-Variante (Online-Anzeige)
  document_print_url TEXT,                         -- DRUCK-Variante (Signatur-Version, kanonisch)
  changelog JSONB,
  superseded_by UUID REFERENCES dim_reglemente(id)
);

-- fact_employment_contracts (erweitert)
CREATE TABLE fact_employment_contracts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  mitarbeiter_id UUID NOT NULL REFERENCES dim_mitarbeiter(id),
  contract_type TEXT NOT NULL CHECK (contract_type IN (
    'unbefristet','befristet','praktikum','lehre','mandat','fix_term'
  )),
  valid_from DATE NOT NULL,
  valid_until DATE,
  pensum_percent NUMERIC(4,1) NOT NULL CHECK (pensum_percent > 0 AND pensum_percent <= 100),
  hours_per_week NUMERIC(4,2) NOT NULL,
  job_description_id UUID REFERENCES dim_job_descriptions(id),
  jobtitel TEXT,                                   -- Fallback bei nicht gematchtem JD
  funktions_stufe TEXT,                            -- 'Junior','Senior','Lead','Partner'
  arbeitsort TEXT,
  home_office_allowance_days_year INT DEFAULT 20,
  remote_work_allowance_days_year INT DEFAULT 10,
  probezeit_monate INT DEFAULT 3,
  probezeit_ende DATE GENERATED ALWAYS AS (valid_from + (probezeit_monate || ' months')::INTERVAL) STORED,

  -- Kündigungsfristen (JSONB statt fixem INT)
  kuendigungsfristen_jsonb JSONB DEFAULT '{
    "probezeit_tage": 3,
    "dj_1": 1,
    "dj_2_5": 2,
    "dj_6_plus": 3
  }'::jsonb,

  -- Karenzentschädigung (monatlich zum Gehalt)
  karenzentschaedigung_chf_mt NUMERIC(8,2) NOT NULL DEFAULT 0,

  -- Konkurrenz- + Abwerbeverbot + Geheimhaltung (nachvertraglich)
  konkurrenzverbot_monate INT DEFAULT 18,
  konkurrenzverbot_region TEXT DEFAULT 'Deutschschweiz',
  konkurrenzverbot_branche_scope TEXT[] DEFAULT ARRAY[
    'bau_hauptgewerbe','bau_nebengewerbe','architecture',
    'civil_engineering','real_estate_management','building_technology','energy_environmental'
  ],
  konkurrenzverbot_konventionalstrafe_min_chf NUMERIC(10,2) DEFAULT 80000,
  konkurrenzverbot_konventionalstrafe_formula TEXT DEFAULT '12 Bruttomonatslöhne inkl. Provisionen/Spesen, min CHF 80000',
  abwerbeverbot_monate INT DEFAULT 18,
  abwerbeverbot_konventionalstrafe_chf NUMERIC(10,2) DEFAULT 80000,
  nachvertragliche_geheimhaltung_konventionalstrafe_chf NUMERIC(10,2) DEFAULT 20000,

  -- Weiterbildungs-Klauseln (aggregiert, Details in fact_training_agreements)
  ferien_tage_jahr NUMERIC(4,1) DEFAULT 25,

  -- Lohn-Zahlungsrhythmus
  lohn_payment_window TEXT DEFAULT '25_30_of_month',    -- Generalis Provisio §5.2

  -- Dokumente + Signaturen
  vertrag_dokument_url TEXT,
  signed_at TIMESTAMPTZ,
  signed_by_mitarbeiter BOOLEAN DEFAULT false,
  signed_by_head_of_department BOOLEAN DEFAULT false,
  signed_by_founder BOOLEAN DEFAULT false,

  is_active BOOLEAN GENERATED ALWAYS AS (
    (valid_until IS NULL OR valid_until >= CURRENT_DATE) AND valid_from <= CURRENT_DATE
  ) STORED,
  created_at TIMESTAMPTZ DEFAULT now(),
  created_by UUID REFERENCES dim_mitarbeiter(id)
);

-- fact_contract_attachments (Vertrags-Anhänge N:M)
CREATE TABLE fact_contract_attachments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  contract_id UUID NOT NULL REFERENCES fact_employment_contracts(id),
  attachment_type TEXT CHECK (attachment_type IN (
    'reglement_generalis_provisio',
    'reglement_tempus_passio',
    'reglement_locus_extra',
    'stellenbeschreibung_progressus',
    'provisionsvertrag_praemium_victoria',
    'weiterbildungsvereinbarung',
    'other'
  )),
  reglement_id UUID REFERENCES dim_reglemente(id),
  job_description_id UUID REFERENCES dim_job_descriptions(id),
  provisionsvertrag_version_id UUID REFERENCES fact_provisionsvertrag_versions(id),
  training_agreement_id UUID REFERENCES fact_training_agreements(id),
  document_url TEXT,
  signed_at TIMESTAMPTZ,
  signed_by_mitarbeiter BOOLEAN DEFAULT false
);

-- fact_provisionsvertrag_versions (Praemium Victoria jährlich)
CREATE TABLE fact_provisionsvertrag_versions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  mitarbeiter_id UUID NOT NULL REFERENCES dim_mitarbeiter(id),
  fiscal_period_start DATE NOT NULL,
  fiscal_period_end DATE NOT NULL,
  role_at_contract TEXT CHECK (role_at_contract IN (
    'consultant','researcher','candidate_manager','account_manager','team_leader','head_of_department'
  )),
  budget_goal_chf NUMERIC(12,2) NOT NULL,
  team_budget_goal_chf NUMERIC(12,2),                -- nur bei Team Leader / Head of
  fix_salary_period_chf NUMERIC(10,2) NOT NULL,
  variable_100pct_chf NUMERIC(10,2) NOT NULL,
  spesenpauschale_chf_mt NUMERIC(8,2) DEFAULT 300,
  zeg_staffel_id UUID REFERENCES dim_zeg_staffel(id),
  payout_advance_pct NUMERIC(5,2) DEFAULT 80.0,      -- 80/20-Split
  document_url TEXT,
  signed_at TIMESTAMPTZ,
  signed_by_mitarbeiter BOOLEAN DEFAULT false,
  signed_by_head_of_department BOOLEAN DEFAULT false,
  signed_by_founder BOOLEAN DEFAULT false,
  UNIQUE (mitarbeiter_id, fiscal_period_start)
);

-- fact_role_transitions (MA-Rolle-Wechsel mit §5.3-Praemium-Regel)
CREATE TABLE fact_role_transitions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  mitarbeiter_id UUID REFERENCES dim_mitarbeiter(id),
  from_role TEXT NOT NULL,
  to_role TEXT NOT NULL,
  effective_date DATE NOT NULL,
  reason TEXT CHECK (reason IN (
    'promotion', 'lateral_move', 'demotion', 'specialization', 'initial_assignment'
  )),
  new_karenzentschaedigung_chf_mt NUMERIC(8,2),
  new_contract_id UUID REFERENCES fact_employment_contracts(id),
  provision_grace_period_months INT DEFAULT 3,      -- §5.3 Praemium Victoria
  approved_by UUID REFERENCES dim_mitarbeiter(id),
  created_at TIMESTAMPTZ DEFAULT now()
);
```

### 6.3 Neue Tabellen — Absenzen + Kalender

```sql
-- dim_absence_types (erweitert mit CH-Spezifika + Arkadium-Extras)
CREATE TABLE dim_absence_types (
  id UUID PRIMARY KEY,
  code TEXT UNIQUE NOT NULL,
  label_de TEXT NOT NULL,
  paid BOOLEAN NOT NULL,
  requires_certificate BOOLEAN NOT NULL,
  certificate_rule_type TEXT CHECK (certificate_rule_type IN (
    'never', 'always_day_1', 'after_n_days_fixed', 'staffelung_by_dienstjahr'
  )),
  certificate_staffelung_jsonb JSONB,              -- {"dj_1": 1, "dj_2": 2, "dj_3_plus": 3}
  requires_approval BOOLEAN NOT NULL,
  auto_approve_threshold_days INT,
  counts_towards_vacation_balance BOOLEAN DEFAULT false,
  max_days_per_year INT,
  extra_guthaben_kategorie BOOLEAN DEFAULT false,  -- a/b/c verfallen bei Kündigung
  sort_order INT
);

-- Seeds (aus Generalis Provisio §3.5.2 + Tempus Passio §6+§7):
INSERT INTO dim_absence_types
  (code, label_de, paid, requires_certificate, certificate_rule_type, certificate_staffelung_jsonb,
   requires_approval, counts_towards_vacation_balance, extra_guthaben_kategorie, sort_order)
VALUES
  ('sick', 'Krankheit', true, true, 'staffelung_by_dienstjahr',
    '{"dj_1": 1, "dj_2": 2, "dj_3_plus": 3}'::jsonb, false, false, false, 10),
  ('vacation', 'Ferien', true, false, 'never', NULL, true, true, false, 20),
  ('unpaid', 'Unbezahlter Urlaub', false, false, 'never', NULL, true, false, false, 30),
  ('maternity', 'Mutterschaft (16 Wo EO)', true, true, 'always_day_1', NULL, false, false, false, 40),
  ('paternity', 'Vaterschaft (2 Wo EO)', true, false, 'never', NULL, true, false, false, 50),
  ('military', 'Militär-/Zivildienst (EO)', true, true, 'always_day_1', NULL, false, false, false, 60),
  ('civil_protection', 'Zivilschutz', true, true, 'always_day_1', NULL, false, false, false, 61),
  ('red_cross', 'Rotkreuzdienst', true, true, 'always_day_1', NULL, false, false, false, 62),
  ('fire_brigade', 'Feuerwehrdienst', true, true, 'always_day_1', NULL, false, false, false, 63),
  ('training', 'Weiterbildung', true, false, 'never', NULL, true, false, false, 70),
  ('sickness_family', 'Pflege Familie', true, false, 'never', NULL, true, false, false, 80),
  ('holiday', 'Feiertag (Kanton ZH)', true, false, 'never', NULL, false, false, false, 90),
  ('birthday_self', 'Geburtstag MA (Extra-Guthaben)', true, false, 'never', NULL, false, false, true, 100),
  ('birthday_close', 'Geburtstag nahestehend (Extra-Guthaben)', true, false, 'never', NULL, true, false, true, 101),
  ('joker_day', 'Jokertag (Me Time, Extra-Guthaben)', true, false, 'never', NULL, false, false, true, 102),
  ('zeg_target_reward', 'Zielerreichung Halbjahr (Extra-Guthaben)', true, false, 'never', NULL, true, false, true, 103),
  ('gl_discretionary', 'GL-Ermessen Extra-Tag', true, false, 'never', NULL, true, false, true, 104);

-- fact_absences
CREATE TABLE fact_absences (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  mitarbeiter_id UUID NOT NULL REFERENCES dim_mitarbeiter(id),
  absence_type_id UUID NOT NULL REFERENCES dim_absence_types(id),
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  half_day_start BOOLEAN DEFAULT false,
  half_day_end BOOLEAN DEFAULT false,
  working_days NUMERIC(5,2) NOT NULL,
  notes TEXT,
  approval_status TEXT DEFAULT 'pending' CHECK (approval_status IN (
    'pending','approved','rejected','cancelled','auto_approved'
  )),
  approved_by UUID REFERENCES dim_mitarbeiter(id),
  approved_at TIMESTAMPTZ,
  rejection_reason TEXT,
  requested_at TIMESTAMPTZ DEFAULT now(),
  requested_by UUID REFERENCES dim_mitarbeiter(id),
  certificate_required BOOLEAN DEFAULT false,      -- computed aus dim_absence_types + Dienstjahr + Dauer
  certificate_uploaded_at TIMESTAMPTZ,
  certificate_document_url TEXT,
  stellvertretung_id UUID REFERENCES dim_mitarbeiter(id),
  outlook_autoreply BOOLEAN DEFAULT true,
  cancelled_at TIMESTAMPTZ,
  cancelled_reason TEXT
);

-- fact_vacation_balances (erweitert mit Extra-Guthaben)
CREATE TABLE fact_vacation_balances (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  mitarbeiter_id UUID NOT NULL REFERENCES dim_mitarbeiter(id),
  year INT NOT NULL,

  -- Standard-Ferien (25 Tage)
  vacation_default_days NUMERIC(4,1) DEFAULT 25.0,
  vacation_used_days NUMERIC(4,1) DEFAULT 0,
  vacation_pending_days NUMERIC(4,1) DEFAULT 0,

  -- Übertrag Vorjahr (bis Ostern+14 zu beziehen)
  carried_from_prev_year NUMERIC(4,1) DEFAULT 0,
  carry_deadline_date DATE,                        -- generiert: Ostermontag + 14 Tage

  -- Extra-Guthaben-Kategorien (a/b/c verfallen bei Kündigung)
  extra_birthday_self_days NUMERIC(3,1) DEFAULT 1.0,
  extra_birthday_self_used NUMERIC(3,1) DEFAULT 0,
  extra_birthday_close_days NUMERIC(3,1) DEFAULT 1.0,
  extra_birthday_close_used NUMERIC(3,1) DEFAULT 0,
  extra_joker_days NUMERIC(3,1) DEFAULT 1.0,
  extra_joker_used NUMERIC(3,1) DEFAULT 0,
  extra_zeg_h1_days NUMERIC(3,1) DEFAULT 0,        -- gesetzt Ende August bei ≥100% H1
  extra_zeg_h1_used NUMERIC(3,1) DEFAULT 0,
  extra_zeg_h2_days NUMERIC(3,1) DEFAULT 0,        -- gesetzt Ende Februar Folgejahr bei ≥100% H2
  extra_zeg_h2_used NUMERIC(3,1) DEFAULT 0,
  extra_gl_discretionary_days NUMERIC(3,1) DEFAULT 0,    -- GL-Ermessen 0-3
  extra_gl_discretionary_used NUMERIC(3,1) DEFAULT 0,

  vacation_remaining NUMERIC(4,1) GENERATED ALWAYS AS (
    vacation_default_days + carried_from_prev_year - vacation_used_days - vacation_pending_days
  ) STORED,

  UNIQUE (mitarbeiter_id, year)
);

-- dim_holidays_zh (Seeds aus Tempus Passio §6)
CREATE TABLE dim_holidays (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  canton CHAR(2) NOT NULL,
  year INT NOT NULL,
  date DATE NOT NULL,
  name_de TEXT NOT NULL,
  is_half_day BOOLEAN DEFAULT false,
  is_working_day_alternative BOOLEAN DEFAULT false,
  UNIQUE (canton, date)
);

-- fact_homeoffice_requests (Locus Extra)
CREATE TABLE fact_homeoffice_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  mitarbeiter_id UUID REFERENCES dim_mitarbeiter(id),
  requested_date DATE NOT NULL,
  request_type TEXT CHECK (request_type IN ('homeoffice','remote_work')),
  submitted_at TIMESTAMPTZ DEFAULT now(),
  must_be_48h_before CHECK (requested_date - CURRENT_DATE >= 2),   -- soft constraint · UI-Validation
  project_context TEXT,
  status TEXT DEFAULT 'pending' CHECK (status IN (
    'pending', 'approved', 'rejected', 'cancelled'
  )),
  approved_by UUID REFERENCES dim_mitarbeiter(id),
  approved_at TIMESTAMPTZ,
  rejection_reason TEXT,
  UNIQUE (mitarbeiter_id, requested_date)
);

CREATE TABLE fact_homeoffice_quota_usage (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  mitarbeiter_id UUID REFERENCES dim_mitarbeiter(id),
  year INT NOT NULL,
  homeoffice_allowance_days NUMERIC(4,1) DEFAULT 20,
  homeoffice_used_days NUMERIC(4,1) DEFAULT 0,
  remote_work_allowance_days NUMERIC(4,1) DEFAULT 10,
  remote_work_used_days NUMERIC(4,1) DEFAULT 0,
  UNIQUE (mitarbeiter_id, year)
);
```

### 6.4 Neue Tabellen — Academy + Weiterbildung

```sql
-- dim_academy_modules (Communication Edge, M4, Lernkarteien, M 1-4)
CREATE TABLE dim_academy_modules (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  module_code TEXT UNIQUE NOT NULL,                -- 'comm_edge_1', 'm4_modell', 'm_1_1_ident', ...
  name_de TEXT NOT NULL,
  fachgebiet CHAR(1) CHECK (fachgebiet IN ('A','B','C')),
  part_number INT,
  duration_hours NUMERIC(5,1),
  document_urls JSONB,
  prerequisites UUID[] DEFAULT '{}',
  mandatory_for_roles TEXT[],                      -- ['consultant', 'researcher']
  sort_order INT
);

CREATE TABLE fact_academy_progress (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  mitarbeiter_id UUID REFERENCES dim_mitarbeiter(id),
  module_id UUID REFERENCES dim_academy_modules(id),
  started_at DATE,
  completed_at DATE,
  trainer_id UUID REFERENCES dim_mitarbeiter(id),
  self_assessment_score INT CHECK (self_assessment_score BETWEEN 1 AND 10),
  trainer_assessment_score INT CHECK (trainer_assessment_score BETWEEN 1 AND 10),
  notes TEXT,
  UNIQUE (mitarbeiter_id, module_id)
);

-- dim_certifications (Plan v0.1 bereits skizziert, hier komplett)
CREATE TABLE dim_certifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name_de TEXT NOT NULL,
  issuer TEXT,
  category TEXT CHECK (category IN (
    'recruiting','assessment','soft_skills','technical','legal','other'
  )),
  typical_validity_months INT,
  renewable BOOLEAN DEFAULT true,
  is_mandatory_for_roles TEXT[],
  sort_order INT
);

CREATE TABLE fact_employee_certifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  mitarbeiter_id UUID REFERENCES dim_mitarbeiter(id),
  certification_id UUID REFERENCES dim_certifications(id),
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

-- fact_training_requests (Plan v0.1 bereits skizziert)
CREATE TABLE fact_training_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  mitarbeiter_id UUID REFERENCES dim_mitarbeiter(id),
  title TEXT NOT NULL,
  provider TEXT,
  type TEXT CHECK (type IN ('zertifizierung','seminar','konferenz','online','coaching')),
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

-- fact_training_agreements (Weiterbildungsvereinbarung, NEU v0.2)
CREATE TABLE fact_training_agreements (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  mitarbeiter_id UUID REFERENCES dim_mitarbeiter(id),
  training_request_id UUID REFERENCES fact_training_requests(id),
  title TEXT NOT NULL,
  provider TEXT,
  start_date DATE NOT NULL,
  expected_completion_date DATE NOT NULL,
  actual_completion_date DATE,
  pensum_reduction_percent NUMERIC(4,1) DEFAULT 0,
  gehalt_wird_voll_weiter_bezahlt BOOLEAN DEFAULT true,
  employer_contribution_per_semester_chf NUMERIC(10,2),
  semester_count INT,
  total_employer_contribution_chf NUMERIC(10,2) GENERATED ALWAYS AS (
    employer_contribution_per_semester_chf * semester_count
  ) STORED,
  repayment_threshold_date DATE,
  agreement_document_url TEXT,
  signed_at TIMESTAMPTZ,
  status TEXT DEFAULT 'planned' CHECK (status IN (
    'planned','active','completed','aborted_personal','aborted_ag_cause'
  )),
  cancellation_date DATE,
  cancellation_reason TEXT
);

-- View für Rückzahlungs-Obligationen
CREATE VIEW v_training_repayment_obligations AS
SELECT
  ta.id,
  ta.mitarbeiter_id,
  ta.total_employer_contribution_chf,
  m.austrittsdatum,
  EXTRACT(MONTH FROM age(m.austrittsdatum, ta.actual_completion_date))::INT AS months_since_completion,
  CASE
    WHEN m.austrittsdatum IS NULL THEN 0
    WHEN ta.status = 'aborted_ag_cause' THEN 0
    WHEN EXTRACT(MONTH FROM age(m.austrittsdatum, ta.actual_completion_date)) <= 12 THEN 1.0
    WHEN EXTRACT(MONTH FROM age(m.austrittsdatum, ta.actual_completion_date)) <= 18 THEN 0.5
    WHEN EXTRACT(MONTH FROM age(m.austrittsdatum, ta.actual_completion_date)) <= 24 THEN 0.25
    ELSE 0
  END * ta.total_employer_contribution_chf AS repayment_amount_chf
FROM fact_training_agreements ta
JOIN dim_mitarbeiter m ON m.id = ta.mitarbeiter_id;
```

### 6.5 Neue Tabellen — Onboarding + Lifecycle

```sql
-- dim_onboarding_templates (Plan v0.1 bereits skizziert)
CREATE TABLE dim_onboarding_templates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT,
  target_role TEXT,                                 -- 'consultant','research_analyst','backoffice','manager'
  phases JSONB NOT NULL,
  academy_module_ids UUID[] DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE fact_onboarding_instances (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  mitarbeiter_id UUID REFERENCES dim_mitarbeiter(id),
  template_id UUID REFERENCES dim_onboarding_templates(id),
  started_at DATE NOT NULL,
  expected_completion_date DATE,
  actual_completion_date DATE,
  buddy_id UUID REFERENCES dim_mitarbeiter(id),
  mentor_id UUID REFERENCES dim_mitarbeiter(id),
  tasks_state JSONB,
  notes TEXT,
  status TEXT DEFAULT 'in_progress' CHECK (status IN ('in_progress','completed','abandoned'))
);

-- fact_lifecycle_transitions (Plan v0.1, erweitert)
CREATE TABLE fact_lifecycle_transitions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  mitarbeiter_id UUID REFERENCES dim_mitarbeiter(id),
  from_stage TEXT,
  to_stage TEXT NOT NULL,
  transitioned_at TIMESTAMPTZ DEFAULT now(),
  transitioned_by UUID REFERENCES dim_mitarbeiter(id),
  reason TEXT,
  notes TEXT,
  warning_id UUID REFERENCES fact_warnings(id),   -- optional: triggering warning
  offboarding_template_id UUID                    -- triggers Checkliste-Attach
);
```

### 6.6 Neue Tabellen — Verwarnungen + Disziplinar (NEU v0.2)

```sql
CREATE TABLE fact_warnings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  mitarbeiter_id UUID REFERENCES dim_mitarbeiter(id),
  warning_type TEXT CHECK (warning_type IN (
    'verbal',           -- informell
    'first_written',    -- erste schriftliche
    'final_written',    -- letzte schriftliche
    'notice_fristlos'   -- fristlos Art. 337 OR
  )),
  issued_at DATE NOT NULL,
  issued_by UUID REFERENCES dim_mitarbeiter(id),
  reason TEXT NOT NULL,
  legal_refs TEXT[],                     -- ['OR 321a', 'ZGB 28', 'StGB 173']
  document_url TEXT,
  acknowledged_at TIMESTAMPTZ,
  acknowledged_by_signature BOOLEAN DEFAULT false,
  alternative_offered TEXT,              -- z.B. 'Aufhebungsvertrag'
  follow_up_deadline DATE,
  resolution TEXT CHECK (resolution IN (
    'compliance', 'termination_notice', 'termination_immediate', 'mutual_agreement', 'escalation'
  )),
  resolved_at DATE
);

CREATE TABLE dim_disciplinary_penalty_types (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code TEXT UNIQUE,
  name_de TEXT NOT NULL,
  during_employment BOOLEAN DEFAULT true,
  post_employment BOOLEAN DEFAULT false,
  default_amount_chf NUMERIC(10,2),
  amount_formula TEXT,                   -- z.B. '12 Bruttomonatslöhne, min 80000'
  legal_ref TEXT
);

-- Seeds:
INSERT INTO dim_disciplinary_penalty_types
  (code, name_de, during_employment, post_employment, default_amount_chf, amount_formula, legal_ref)
VALUES
  ('konkurrenzierung_during_av', 'Konkurrenzierung während AV', true, false, 20000, NULL, 'OR 321a'),
  ('abwerbung_during_av', 'Abwerbung während AV', true, false, 10000, NULL, 'OR 321a'),
  ('nebentaetigkeit_unauthorized', 'Nebentätigkeit ohne Zustimmung', true, false, 3000, NULL, 'Generalis Provisio §3.5.3'),
  ('diffamation', 'Diffamierende Äusserung', true, false, 5000, NULL, 'OR 321a · ZGB 28'),
  ('geheimhaltung_verletzung_during', 'Geschäftsgeheimnis-Verletzung während AV', true, false, 20000, NULL, 'OR 321a'),
  ('konkurrenzverbot_post_av', 'Konkurrenzverbot post-AV', false, true, 80000, '12 Bruttomonatslöhne inkl. Provisionen/Spesen, min 80000', 'OR 340b'),
  ('abwerbeverbot_post_av', 'Abwerbeverbot post-AV', false, true, 80000, 'pro Zuwiderhandlung', 'OR 340'),
  ('geheimhaltung_post_av', 'Geheimhaltungs-Verletzung post-AV', false, true, 20000, 'pro Verletzung', 'OR 340b');

CREATE TABLE fact_disciplinary_incidents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  mitarbeiter_id UUID REFERENCES dim_mitarbeiter(id),
  penalty_type_id UUID REFERENCES dim_disciplinary_penalty_types(id),
  incident_date DATE,
  reported_by UUID REFERENCES dim_mitarbeiter(id),
  reported_at TIMESTAMPTZ DEFAULT now(),
  evidence_document_urls TEXT[],
  penalty_amount_chf NUMERIC(10,2),
  status TEXT DEFAULT 'investigation' CHECK (status IN (
    'investigation', 'confirmed', 'dismissed', 'paid', 'contested_in_court'
  )),
  offset_against_salary BOOLEAN DEFAULT false,
  offset_month DATE,
  notes TEXT
);
```

### 6.7 Neue Tabellen — Dokumente + HR-Audit

```sql
-- fact_hr_documents (Plan v0.1 bereits, erweitert mit Arkadium-spezifischen Typen)
CREATE TABLE fact_hr_documents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  mitarbeiter_id UUID REFERENCES dim_mitarbeiter(id),
  document_type TEXT NOT NULL CHECK (document_type IN (
    'arbeitsvertrag','vertrags_nachtrag','arbeitszeugnis','zwischenzeugnis','arbeitsbestaetigung',
    'reglement_generalis_provisio','reglement_tempus_passio','reglement_locus_extra',
    'stellenbeschreibung_progressus','provisionsvertrag_praemium_victoria',
    'weiterbildungsvereinbarung',
    'aufhebungsvereinbarung_freistellung','aufhebungsvereinbarung_nach_kuendigung',
    'kuendigung_ausgesprochen','kuendigung_annullierung',
    'verwarnung_erste','verwarnung_letzte',
    'zertifikat','policy_acknowledgement','hintergrund_check','arztzeugnis',
    'passfoto','lebenslauf','referenzschreiben','lohnausweis',
    'kkv_merkblatt_rücklauf','abredeversicherung_merkblatt_rücklauf',    -- NEU v0.2
    'sonstiges'
  )),
  name TEXT NOT NULL,
  document_date DATE,
  expiry_date DATE,
  document_url TEXT NOT NULL,
  file_hash_sha256 TEXT,
  uploaded_by UUID REFERENCES dim_mitarbeiter(id),
  uploaded_at TIMESTAMPTZ DEFAULT now(),
  retention_years INT NOT NULL,
  retention_until_date DATE GENERATED ALWAYS AS (
    uploaded_at::DATE + (retention_years || ' years')::INTERVAL
  ) STORED,
  visibility TEXT DEFAULT 'hr_admin_self' CHECK (visibility IN (
    'hr_admin_self', 'hr_admin_only', 'hr_admin_self_supervisor'
  )),
  legal_hold BOOLEAN DEFAULT false,
  deleted_at TIMESTAMPTZ,
  deleted_reason TEXT
);

-- dim_emergency_contacts + audit_hr_access + fact_compensation_history (unverändert v0.1)
-- siehe Plan v0.1 §6.2 für DDL
```

### 6.8 Views für Dashboard-Reporting

```sql
CREATE VIEW v_hr_alerts AS
-- Probezeit-Enden (Plan v0.1)
SELECT 'probezeit_ending' AS alert_type, m.id, m.vorname||' '||m.nachname AS name,
  (ec.probezeit_ende - CURRENT_DATE) AS days_remaining,
  'urgent' AS severity
FROM dim_mitarbeiter m
JOIN fact_employment_contracts ec ON ec.mitarbeiter_id = m.id AND ec.is_active
WHERE ec.probezeit_ende BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '30 days'

UNION ALL
-- Zertifikate (Plan v0.1)
SELECT 'certification_expiring', m.id, m.vorname||' '||m.nachname,
  (fc.valid_until - CURRENT_DATE),
  CASE WHEN fc.valid_until < CURRENT_DATE + INTERVAL '1 month' THEN 'urgent' ELSE 'warning' END
FROM dim_mitarbeiter m
JOIN fact_employee_certifications fc ON fc.mitarbeiter_id = m.id
WHERE fc.status IN ('expired','expiring')

UNION ALL
-- Ferienanträge pending (Plan v0.1)
SELECT 'vacation_approval_pending', m.id, m.vorname||' '||m.nachname,
  EXTRACT(DAY FROM (now() - fa.requested_at))::INT,
  CASE WHEN now() - fa.requested_at > INTERVAL '7 days' THEN 'warning' ELSE 'info' END
FROM dim_mitarbeiter m
JOIN fact_absences fa ON fa.mitarbeiter_id = m.id
WHERE fa.approval_status = 'pending'

UNION ALL
-- Verwarnungs-Follow-ups (NEU v0.2)
SELECT 'warning_follow_up_due', m.id, m.vorname||' '||m.nachname,
  (fw.follow_up_deadline - CURRENT_DATE)::INT,
  CASE WHEN fw.follow_up_deadline < CURRENT_DATE + INTERVAL '7 days' THEN 'urgent' ELSE 'warning' END
FROM dim_mitarbeiter m
JOIN fact_warnings fw ON fw.mitarbeiter_id = m.id
WHERE fw.resolved_at IS NULL
  AND fw.follow_up_deadline IS NOT NULL
  AND fw.follow_up_deadline BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '30 days'

UNION ALL
-- Home-Office-Anträge pending (NEU v0.2)
SELECT 'homeoffice_approval_pending', m.id, m.vorname||' '||m.nachname,
  EXTRACT(DAY FROM (fhr.requested_date - CURRENT_DATE))::INT,
  'info'
FROM dim_mitarbeiter m
JOIN fact_homeoffice_requests fhr ON fhr.mitarbeiter_id = m.id
WHERE fhr.status = 'pending'

UNION ALL
-- Konkurrenzverbot-Clock Alumni (NEU v0.2)
SELECT 'alumni_konkurrenzverbot_active', m.id, m.vorname||' '||m.nachname,
  (m.konkurrenzverbot_aktiv_bis - CURRENT_DATE)::INT,
  'info'
FROM dim_mitarbeiter m
WHERE m.lifecycle_stage = 'alumni'
  AND m.konkurrenzverbot_aktiv_bis >= CURRENT_DATE

UNION ALL
-- Praemium Victoria Renewal (NEU v0.2)
SELECT 'provisionsvertrag_renewal_due', m.id, m.vorname||' '||m.nachname,
  EXTRACT(DAY FROM (pv.fiscal_period_end - CURRENT_DATE))::INT,
  CASE WHEN pv.fiscal_period_end < CURRENT_DATE + INTERVAL '60 days' THEN 'warning' ELSE 'info' END
FROM dim_mitarbeiter m
JOIN fact_provisionsvertrag_versions pv ON pv.mitarbeiter_id = m.id
WHERE pv.fiscal_period_end BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '90 days';
```

### 6.9 Events (erweitert v0.2)

Plan v0.1 hat 13 Events. **Neu:**

| Event-Code | Trigger | Nutzer |
|------------|---------|--------|
| `warning_issued` | Verwarnung ausgestellt | HR + Vorgesetzter |
| `warning_acknowledged` | MA bestätigt Empfang | HR |
| `warning_follow_up_deadline` | 30 Tage nach letzter Verwarnung | HR |
| `termination_annulled` | Kündigung zurückgenommen | HR + Payroll + Audit |
| `disciplinary_incident_reported` | Disziplinar-Vorfall gemeldet | HR + Investigation |
| `disciplinary_penalty_confirmed` | Strafe bestätigt | Payroll (Verrechnung) |
| `reglement_version_published` | Neue Reglement-Version | alle MA Signatur-Request |
| `reglement_signed_by_ma` | MA signiert neues Reglement | HR-Audit |
| `provisionsvertrag_renewal_due` | Q4 jährlicher Renewal | HR + GL |
| `provisionsvertrag_signed` | Neue Praemium Victoria signiert | Commission-Engine |
| `training_agreement_repayment_due` | Weiterbildungs-Austritt | Payroll + Backoffice |
| `konkurrenzverbot_period_ended` | 18-Mt-Post-Austritt | Audit (Alumni-Update) |
| `homeoffice_request_submitted` | HO/Remote-Antrag | Vorgesetzter |
| `homeoffice_request_decision` | Genehmigt/abgelehnt | MA |
| `academy_module_completed` | Modul abgeschlossen | Trainer + HR |
| `birthday_extra_day_eligible` | Geburtstagswoche | MA Notification |
| `zeg_half_year_calculated` | H1 (31.08.) oder H2 (28.02.) | MA + Backoffice |
| `role_transition_executed` | Researcher→Consultant etc. | Commission-Engine (Grace-Period) |

---

## 7. UI-Scope

### 7.1 Aktueller Mockup-Stand

`mockups/ERP Tools/hr.html` = **Dashboard-First** (Header · Top-Bar · 5 Alert-Cards · Action-Queue · Team-Matrix 18 MA × 7 Tage · Lifecycle-Pipeline 7 Spalten Kanban · MA-Liste · Side-Panel 620px mit 8 Accordion-Sektionen).

`mockups/ERP Tools/hr-list.html` = Tabelle-Ansicht (CRM-Style).

### 7.2 Noch zu bauen (aktualisiert v0.2)

| Mockup | Zweck | Priorität |
|--------|-------|-----------|
| `hr-mitarbeiter-self.html` | MA-Self-Service-Profil | P0 |
| `hr-onboarding-editor.html` | Template-Editor | P1 |
| `hr-absence-calendar.html` | Team-Kalender-Monat/Quartal | P1 |
| `hr-documents-admin.html` | Dokument-Retention-Monitor | P1 |
| `hr-warnings-disciplinary.html` | **Verwarnungs- + Disziplinar-Tracker** (NEU v0.2) | P0 |
| `hr-provisionsvertrag-editor.html` | **Jahres-Renewal + Bündel-PDF** (NEU v0.2) | P0 |
| `hr-academy-dashboard.html` | **Academy-Module + Lernfortschritt** (NEU v0.2) | P1 |
| `hr-reports.html` | HR-Reports | P2 |
| `hr-org-chart.html` | Organigramm-Vollbild | P2 |
| `hr-mobile.html` | Mobile-Self-Service | P2 |

### 7.3 Drawer-Katalog (erweitert v0.2)

| Drawer | Breite | Inhalt |
|--------|--------|--------|
| Neuer MA anlegen | 760 (wide-tabs) | Basis · Vertrag · Anhänge (5 Reglemente/Vorlagen) · Review+Bundle-PDF |
| Vertrag bearbeiten | 540 | Alle Vertrags-Felder |
| Ferienantrag | 540 | Zeitraum, Saldo (alle Extra-Guthaben), Stellvertretung, Auto-Reply |
| Extra-Guthaben-Bezug | 540 | Kategorie-Selektor · Sperrfristen-Check · Geburtstagswoche-Validation |
| Krankmeldung | 540 | Zeitraum, Arztzeugnis-Upload (DJ-Staffelung automatisch) |
| **Home-Office-Antrag** (neu) | 540 | Tag · HO vs Remote · Projekt-Context · 48h-Check · Quota-Anzeige |
| Schulung anfordern | 540 | Schulung, Budget-Check, Begründung |
| **Weiterbildungsvereinbarung** (neu) | 540 | Pensum-Reduktion · AG-Beitrag · Rückzahlungs-Vorschau |
| Dokument hochladen | 540 | Typ, Metadaten, Retention, Sichtbarkeit |
| Zertifikat erfassen | 540 | Name, Issuer, Validity, Upload, Reminder |
| Probezeit-Abschluss | 760 | Entscheidung · Feedback Vorgesetzter · Feedback MA · Vereinbarungen |
| **Verwarnung ausstellen** (neu) | 760 | Typ (verbal/first/final) · Reason · Legal-Refs · Follow-up · Alternative (Aufhebung) · Template-Generator |
| **Disziplinar-Incident** (neu) | 760 | Penalty-Type-Selektor · Evidenz-Upload · GL-Entscheidung · Verrechnungs-Option |
| **Provisionsvertrag Jahres-Renewal** (neu) | 760 | Budget-Ziel-Setting · Fix + Variabel + Spesen · ZEG-Staffel-Preview · Signatur-Flow |
| Kündigung einreichen | 540 | Datum, Grund, Offboarding-Trigger |
| **Kündigung annullieren** (neu) | 540 | Referenz zur Kündigung · Grund · Nahtlos-Bestätigung |
| **Aufhebungsvereinbarung** (neu) | 760 | Freistellung vs Nach-Kündigung · Konditionen · Konkurrenzverbot-Reminder · Per-Saldo |
| Arbeitszeugnis-Generator | 760 | Template (Bestätigung vs Voll) · Rolle (Consultant/Researcher) · Genus · Leistungs-Editor · Preview · Export |

---

## 8. Umsetzungs-Phasen

### Phase 3.0 · HR-Fundament (3-4 Wo Dev) — erweitert

1. Migration: `dim_mitarbeiter`-Erweiterung · `fact_employment_contracts` · `dim_job_descriptions` · `dim_reglemente` · `fact_contract_attachments` · `dim_emergency_contacts` · `fact_compensation_history` · `fact_lifecycle_transitions` · `audit_hr_access` · `dim_disciplinary_penalty_types` (+ Seeds)
2. Endpoints: `GET/PATCH /api/v1/employees/:id` · `POST /api/v1/employees` · `POST /api/v1/contracts` · `POST /api/v1/contract-attachments`
3. UI: `hr.html` (Dashboard) · Side-Panel mit 8 Accordion-Sektionen + Arkadium-Vertragswerk-Tab
4. RBAC-Erweiterung: `HR_Manager` · `Team_Lead` · `Employee_Self` · `Academy_Lead`
5. Sensible-Daten-Layer: AHV/Pass maskiert, Aufdecken mit Audit-Log
6. Feature-Flag-Entlock `feature_hr_tool`
7. **Signatur-Flow** (4-Tab-Drawer für Neuer-MA mit Bündel-PDF-Generator)
8. **Reglemente-Seed** (3 Reglemente × aktuelle Version 2024-01-01)
9. **Job-Descriptions-Seed** (Consultant · Research Analyst · Team Leader × 4 Sparten · Head × 2 · Founder · Backoffice · HR-Manager)

**DoD:** HR-Manager kann alle MA sehen, neuen MA anlegen (mit Vertrag + 5 Anhängen), Bündel-PDF generieren. Alle sensiblen Zugriffe im Audit-Log.

### Phase 3.1 · Absenzen + Kalender (2 Wo Dev) — erweitert

1. Migration: `fact_absences` · `dim_absence_types` (+ Seeds inkl. Arkadium-Extras) · `fact_vacation_balances` (Extra-Guthaben-Kategorien) · `dim_holidays` (Seed ZH)
2. **Arztzeugnis-Staffelung** als computed field in `fact_absences.certificate_required` (basiert auf Dienstjahr + Dauer + Absence-Type)
3. **Ferienkürzungs-Regel** als Cron-Worker (> 2 Mt Absenz → 1/12/Mt Kürzung)
4. **Ostern+14-Carry-Deadline** pro Jahr automatisch setzen
5. Endpoints: Ferienantrag-Flow · Genehmigungs-Flow · Saldo-Query (alle Extra-Kategorien)
6. UI: Drawer Ferienantrag + Krankmeldung · Team-Matrix live · `hr-absence-calendar.html`
7. **Sperrfristen-Validation** bei Extra-Guthaben-Bezug (Geburtstagswoche · Brückentage · Sechseläuten · Knabenschiessen · 24.12.–01.01.)
8. Integration: Outlook-Auto-Reply-Toggle

**DoD:** MA beantragt Ferien + Extra-Guthaben → Vorgesetzter genehmigt → Kalender zeigt · Auto-Reply aktiv.

### Phase 3.1b · Home-Office + Remote-Work (1 Wo Dev · NEU v0.2)

1. Migration: `fact_homeoffice_requests` · `fact_homeoffice_quota_usage`
2. Endpoints: Antrag · Genehmigung · Quota-Query
3. UI: HO/Remote-Antrags-Drawer · Quota-Dashboard pro MA
4. **48h-Lead-Time-Constraint** + Probezeit-Check
5. **Team-Abdeckung-70%-Rule** als Validation (Team-Kalender-Query)

**DoD:** MA beantragt HO-Tag 48h vorher · Vorgesetzter genehmigt wenn Team-Abdeckung OK · Quota automatisch dekrementiert.

### Phase 3.2 · Onboarding + Zertifikate + Academy (2-3 Wo Dev) — erweitert

1. Migration: `dim_onboarding_templates` · `fact_onboarding_instances` · `dim_academy_modules` · `fact_academy_progress` · `dim_certifications` · `fact_employee_certifications` · `fact_training_requests`
2. **Academy-Module-Seeds** (Communication Edge 1-3 · M4 Modell · Lernkarteien 1&2 · M 1-4 Module)
3. **Onboarding-Template-Seeds** ("Consultant 14W" · "Researcher 8W" · "Backoffice")
4. Endpoints: Task-Completion · Template-Clone · Zertifikat-Upload · Schulungs-Request · Academy-Progress
5. Worker: Expiring-Certs-Reminder (90/30 Tage) · Overdue-Tasks-Alert
6. UI: Onboarding-Checklist + Academy-Progress im Side-Panel · Zertifikat-Erfassen-Drawer · `hr-onboarding-editor.html` · `hr-academy-dashboard.html`

**DoD:** Neuer MA → Auto-Onboarding-Template + Academy-Module-Liste attacht · Tasks abarbeitbar · Zertifikat-Ablauf flaggt Alert · Academy-Progress sichtbar.

### Phase 3.3 · Dokumente + DSG-Retention (1-2 Wo Dev) — erweitert

1. Migration: `fact_hr_documents` mit Auto-Retention · Document-Types-Enum erweitert (inkl. Aufhebungs-, Verwarnungs-, Reglemente-, Merkblatt-Typen)
2. Storage: Azure Blob / S3 verschlüsselt
3. Endpoints: Upload (multipart) · Download (mit Audit) · Bulk-Retention-Check
4. Worker: Retention-Expiry-Reminder (30 Tage) · Legal-Hold-Override-Log
5. UI: Document-Drawer mit Sichtbarkeits-Scope · `hr-documents-admin.html`

**DoD:** PDF-Ablage funktioniert · Retention-Regeln greifen · DSG-Auskunftsrecht abbildbar.

### Phase 3.4 · Lifecycle + Kanban (1-2 Wo Dev) — erweitert

1. Migration: `fact_lifecycle_transitions` (erweitert) · `fact_role_transitions` (NEU v0.2) · `fact_warnings`
2. Endpoints: Stage-Transition · Role-Transition · Offboarding-Template-Attach · Annullierungs-Flow
3. Worker: Austritts-Cron (täglich) · Alumni-Auto-Archive · IT-Deprovisioning-Trigger · **Konkurrenzverbot-18-Mt-Clock**
4. UI: Kanban-Drag-Drop live · Offboarding-Checkliste-Drawer · Kündigungs-Drawer · **Annullierungs-Drawer** · Role-Transition-Drawer

**DoD:** Drag Active → Under-Watch → Final-Watch → Offboarding-Branch triggert korrekte Saga · Role-Transition aktiviert §5.3-Grace-Period · Annullierung führt zu nahtlosem Zurück-zu-Active.

### Phase 3.5 · Self-Service (2 Wo Dev)

1. Endpoints: Self-View-Scope · begrenzte Self-Edit-Rechte
2. UI: `hr-mitarbeiter-self.html` · Mobile-View (falls Phase 2 Mobile-Support aktiv)
3. Auskunftsrecht-Export: PDF mit allen eigenen Daten (DSG Art. 25)
4. Integration: Zertifikat-Upload · Schulungs-Request · Ferienantrag · HO-Antrag

**DoD:** MA loggt ein, sieht nur eigene Daten, kann alle relevanten Anträge stellen.

### Phase 3.6 · Reports + Org-Chart + Arbeitszeugnis-Generator (1-2 Wo)

1. HR-Reports (Fluktuation · Absenz-Rate · Trainings-Budget · Dienstalter)
2. Interaktiver Org-Chart
3. Export zu Payroll (CSV für Treuhänder)
4. **Arbeitszeugnis-Generator** (Template-Selektor · Rolle-Selektor · Genus-Toggle · Leistungs-Editor · Preview · Export)
5. **Konkurrenzverbots-Monitor** post-Austritt (Alumni-Dashboard + 18-Mt-Countdown)

### Phase 3.7 · Disziplinar + Verwarnungen (1-2 Wo · NEU v0.2)

1. Migration: `fact_warnings` (bereits in 3.4) · `dim_disciplinary_penalty_types` · `fact_disciplinary_incidents`
2. Endpoints: Warning-CRUD · Incident-Workflow (investigation → confirmed/dismissed)
3. UI: `hr-warnings-disciplinary.html` · Warning-Drawer + Incident-Drawer
4. **Payroll-Bridge**: `offset_against_salary` triggert Verrechnung mit nächstem Lohnlauf
5. **Legal-Ref-Tooltips** (OR 321a · 337 · 340 · ZGB 28 · StGB 173)
6. Worker: Follow-up-Deadline-Alerts · Eskalations-Prompts

**DoD:** HR kann Verwarnung ausstellen → MA bestätigt → Follow-up-Deadline läuft → Eskalation oder Resolution · Disziplinar-Incident meldbar + Verrechnung funktioniert.

### Phase 3.8 · Provisionsvertrag-Renewal-Cycle (1-2 Wo · NEU v0.2)

1. Migration: `fact_provisionsvertrag_versions` · `dim_zeg_staffel`
2. Endpoints: Version-CRUD · Budget-Ziel-Setting · Signatur-Flow
3. UI: `hr-provisionsvertrag-editor.html` · Jahres-Renewal-Drawer · Bündel-PDF-Generator
4. **Oktober/November-Worker**: alle aktiven MA Renewal-Reminder
5. **Commission-Engine-Bridge**: `fact_provisionsvertrag_versions` als Source-of-Truth für Zielerreichung + Halbpunkt-Berechnung
6. **§5.3-Grace-Period-Handler**: bei Role-Transition Researcher→Consultant 3-Mt-Clock starten für alte Vermittlungen

**DoD:** GL kann Budget-Ziele für alle MA setzen · Signatur-Flow funktioniert · Commission-Engine zieht aktive Version · §5.3-Regel automatisch.

---

## 9. Abhängigkeiten

| Erforderlich VOR Start | Begründung |
|------------------------|------------|
| Feature-Flag-System (Admin-Vollansicht) | `feature_hr_tool` Unlock-Point |
| Blob-Storage (Azure/S3) + Encryption | HR-Dokumente |
| Email-Worker mit Outlook-Tokens | Auto-Reply bei Ferien · Signatur-Request-Mails |
| Audit-Log-Infrastruktur (`fact_audit_log`) | existiert |
| RBAC-Matrix-Erweiterung | neue Rollen HR_Manager · Team_Lead · Employee_Self · Academy_Lead |
| Kantonale Feiertag-Daten (Seed) | Absenz-Werktag-Berechnung |
| **Commission-Engine (Phase 3.x parallel)** (NEU v0.2) | `fact_provisionsvertrag_versions` als Source für Commission |
| **Signatur-Service** (z.B. Skribble) (NEU v0.2) | Digitale Vertragssignierung |
| **Ostern-Kalender-Worker** (NEU v0.2) | Jährlich Carry-Deadline (Ostermontag+14) setzen |

---

## 10. Risiken

*(v0.1 + neue v0.2):*

| Risiko | W | I | Mitigation |
|--------|---|---|------------|
| MA-Skepsis bei Self-Service | mittel | mittel | Transparenz · keine Performance-Metrics |
| DSG-Verstoß bei sensiblen Daten | niedrig | sehr hoch | Sensible-Daten-Layer + Audit + Retention |
| Kantonale Feiertag-Drift | mittel | niedrig | Jährlicher Maintenance-Task |
| Payroll-Sync-Drift | mittel | mittel | Read-Only-Attitude · `last_sync_at` tracking |
| Onboarding-Template-Over-Engineering | hoch | niedrig | MVP 3 Templates |
| Kanban-Drag-Drop-Konflikte | niedrig | mittel | Optimistic Locking mit `lifecycle_stage_since` |
| Austrittsprozess verzögert | mittel | mittel | Auto-Alumni-Cron + Legal-Hold-Override |
| **Reglement-Revision-Signature-Backlog** (NEU v0.2) | hoch | mittel | Bulk-Request-Flow · Opt-in/Opt-out klar |
| **Praemium-Victoria-Renewal verpasst** (NEU v0.2) | hoch | sehr hoch | Q3-Reminder + Backup-Termin bis 31.12. · Auto-Extension um 1 Mt fallback |
| **Disziplinar-Verrechnung vor GL-Bestätigung** (NEU v0.2) | niedrig | sehr hoch | 2-Augen-Prinzip · confirmed-State pflicht vor Payroll-Offset |
| **§5.3-Grace-Period-Fehler** (NEU v0.2) | mittel | hoch | Automatische Audit-Trail-Einträge · Test-Suite mit Edge-Cases |
| **Academy-Module-Versioning-Drift** (NEU v0.2) | mittel | niedrig | Jahres-Review bei Academy-Lead · semver-Versionierung |

---

## 11. Offene Entscheidungen · PO-Review (2026-04-19 komplett)

Alle 18 Fragen in PO-Review mit Peter beantwortet. Status: **§11A (6) + §11B (6) + §11C (12) = 18/18 beantwortet**.

### §11A Aus v0.1 beantwortet (durch Ingest)

| # | Frage | Antwort |
|---|-------|---------|
| 1 | Bewerber-Phase im Kanban | **Raus** — Lifecycle startet bei Offer |
| 6 | Feiertags-Kantone | **ZH initial** (9 Feiertage aus Tempus Passio §6), weitere Kantone on-demand |
| 7 | Sprachanforderungen | **DE only** (Memory `project_sprache_policy.md`) · EN-Template-Wording obsolet |
| 8 | Arzt-Zeugnis-Pflicht | **Dienstjahr-Staffelung** 1/2/3 Tage je DJ 1/2/3+ |
| 9 | Ferien-Übertrag-Regel | **Bis Ostermontag+14 beziehen** · jüngste Ansprüche zuerst · kein Deckel aber zeitlich limitiert |
| 12 | Probezeit-Default-Dauer | **3 Monate** Standard (alle Arkadium-Vorlagen) |

### §11B Aus v0.1 offen · PO-Review 2026-04-19

| # | Frage | Entscheidung | Schema-Impact |
|---|-------|-------------|---------------|
| 2 | Payroll-Export-Format | **Bexio-CSV start + Swissdec-ELM strategisch** · Abacus on-demand | 2-Format-Export-Worker · evtl. später Abacus-XML |
| 3 | Arbeitszeugnis-Generator | **Globaler Dok-Generator** (kein eigenes HR-Feature) · Template-Registration + MA-Kontext-Bridge · analog ARK CV/Abstract/Exposé | Phase 3.6 HR-Eintrag entfällt · `/operations/dok-generator`-Integration statt eigenes Drawer |
| 4 | Lohnausweis-Upload | **Auto-Import via Backoffice-Bulk-Trigger** · Self-Service-Anzeige | `fact_hr_documents.document_type='lohnausweis'` · Bulk-Upload-Endpoint |
| 5 | Notfallkontakt | **Max 2** (primär + sekundär) · Pflicht ≥ 1 | `dim_emergency_contacts.priority IN (1,2)` + Unique-Constraint |
| 10 | Dienstjubiläum | **Auto-Alert bei 5/10/15/20 J.** · GL-Ermessen je Fall · keine Auto-Zahlung | `fact_jubilaeum_handled_at` · `handled_by` · `gesture_type_freetext` |
| 11 | Geburtstag im Team-Kalender | **Opt-in** · MA entscheidet im Self-Service · Default nicht sichtbar | `dim_mitarbeiter.birthday_visible_in_team_calendar BOOLEAN DEFAULT false` |

### §11C Neu aus Ingest · PO-Review 2026-04-19

| # | Frage | Entscheidung | Schema-Impact |
|---|-------|-------------|---------------|
| 1 | Reglement-Versionierung Signatur-Pflicht | **Fall-zu-Fall** · HR/GL setzt pro Version | `dim_reglemente.requires_bulk_resignature BOOLEAN` (default false) · UI-Toggle beim Publish |
| 2 | Karenzentschädigung bei Rollen-Wechsel | **Individualverhandlung · kein Automatismus** | `fact_role_transitions.new_karenzentschaedigung_chf_mt` manuell gesetzt |
| 3 | Academy-Trainer-Rolle | **Multiple Trainer je Modul** · keine separate RBAC-Rolle `Academy_Lead` | `dim_academy_modules.default_trainer_ids UUID[]` · `fact_academy_progress.trainer_id` individuell |
| 4 | Disziplinar-Lohn-Verrechnung | **GL-Approval Pflicht + 1 Mt MA-Vorankündigung** vor Verrechnung | `fact_disciplinary_incidents.gl_approved_at` + `gl_approved_by` + `ma_notified_at` + `offset_effective_date` · Constraint `offset_effective_date >= ma_notified_at + INTERVAL '1 month'` |
| 5 | Praemium-Victoria-Zyklus | **Kalenderjahr 01.01.–31.12.** · Neu-Eintritte pro-rata | `fact_provisionsvertrag_versions.fiscal_period_start/end` fest auf Kalenderjahr (mit Sonderbehandlung erstes Jahr) · Q4-Renewal-Worker |
| 6 | Honorarstreitigkeit-Sonderfall | **Manuell durch Backoffice** · keine dedizierte Tabelle · Einmalzahlung pro Fall | via `fact_compensation_history` oder direkte Einmalzahlung · kein Commission-Engine-Integration · BO-Drawer mit Begründung + Kontext-Ref |
| 7 | Annullierung UI-Flow | **Kontext-Menü-Aktion "Kündigung annullieren"** + Drawer 540px · kein Kanban-Drag-Rückwärts | UI: Lifecycle-Transition-Worker handled reverse · `fact_lifecycle_transitions` mit `reason='annullierung'` |
| 8 | Alumni-Konkurrenzverbot-Monitor | **GF-Ermessen** · kein automatischer Monitor · GL entscheidet je Alumni-Fall · HR dokumentiert Verdachtsfälle manuell | Kein Schema-Impact · nur UI-Anzeige 18-Mt-Countdown + manueller Evidenz-Upload |
| 9 | Scheelen-Zertifikate Onboarding-Pflicht | **Alle 4 Pflicht für alle Rollen** (MDI · Relief · ASSESS · EQ) | `dim_certifications.is_mandatory_for_roles=['*']` Wildcard · Onboarding-Template-Seeds inkludieren alle 4 · neuer Alert `scheelen_certification_missing` |
| 10 | Lohnzahlungs-Kalender | **Config in `dim_automation_settings`** + View `v_next_lohn_payment_date` · optionale Ad-hoc-Overrides | Schlüssel: `lohnlauf_day_start=25` · `lohnlauf_day_end=30` · `december_before_xmas=true` · `avoid_weekend_holiday=true` · + `fact_lohn_payment_overrides` für Sonderfälle |
| 11 | Extra-Guthaben-Verfall | **Ab Kündigungs-Einreichung** · mit HR-Override-Option (Toggle im Kündigungs-Drawer) | `fact_vacation_balances.extra_abc_grant_override_at` + `_by` + `_reason` · Standard-Verfall bei `lifecycle_stage IN ('offboarding_*')` · Override kehrt Verfall um |
| 12 | Head-Signatur auf Provisionsvertrag | **Beide Signaturen Pflicht** (Head + GL + MA = 3 Signaturen) · RBAC: Head nur Unterstellten-Verträge | `fact_provisionsvertrag_versions.is_active` benötigt alle 3 Signatures · RBAC-Check `current_user.id = mitarbeiter.head_of_department_id` |

### Bereit für Schema-Arbeit

Nach PO-Review sind alle offenen Schema-relevanten Fragen beantwortet. Nächste Artefakte:
- `ARK_HR_TOOL_SCHEMA_v0_1.md` (DDL-Komplettdefinition aus §6.1–§6.9 + §11-Entscheidungen)
- `ARK_HR_TOOL_INTERACTIONS_v0_1.md` (UI-Flows aus §7 + §5 Use-Cases inkl. Verwarnungs-Eskalation · Annullierungs-Flow · Praemium-Renewal-Cycle)

Keine weiteren offenen Fragen vor Schema-Implementierung identifiziert. Minor-Entscheidungen (z.B. spezifische Event-Naming-Konventionen, View-Performance-Indices) werden im Schema-Entwurf selbst geklärt.

---

## 12. Verschieben zu anderen Modulen

*(unverändert v0.1):*

| Feature | Wo |
|---------|-----|
| Zeiterfassung | Phase-3-Zeiterfassung |
| Performance-Reviews | Phase-3-Performancetool |
| Lohnabrechnung/Sozialbeiträge | Payroll-System (Treuhänder/Bexio) · Read-Only-Ref |
| Stellenausschreibungen | Phase-3-Publishing |
| Kandidaten-Pipeline | CRM |
| Provisions-Berechnung | **Commission-Engine (eigenes Modul)** · HR-Tool liefert nur Versionen + Rollen |

---

## 13. Related

### Specs + Mockups
- `mockups/ERP Tools/hr.html` · `hr-list.html` — Aktuelle Mockups
- `specs/ARK_HR_TOOL_PLAN_v0_1.md` — Vorgänger (v0.2 supersedes)
- `specs/ARK_HR_TOOL_RESEARCH_v0_1.md` · `_v0_2.md` — Market Research
- `specs/ARK_HR_RESEARCH_SYNTHESE_v0_1.md`
- `specs/ARK_HR_STRATEGY_DECISION_v1_0.md` — Build-Strategy Freeze
- `specs/ARK_LUCCA_EVALUATION_v0_1.md` · `ARK_SWISSDECTX_EVALUATION_v0_1.md` — Build-vs-Buy
- `specs/ARK_ZEITERFASSUNG_PLAN_v0_1.md` — Schwester-Modul (Cross-Dep: Absenzen-Mirror)
- `specs/ARK_COMMISSION_ENGINE_SPEC_v0_1.md` — Commission-Bridge

### Wiki
- Sources: [[hr-arbeitsvertraege]] · [[hr-reglemente]] · [[hr-provisionsvertraege]] · [[hr-arbeitszeugnisse]] · [[hr-weiterbildungsvereinbarung]] · [[hr-stellenbeschreibung-progressus]] · [[hr-kuendigung-aufhebung]] · [[hr-austritt-versicherung-merkblaetter]]
- Concepts: [[hr-vertragswerk]] · [[hr-academy]] · [[hr-konkurrenz-abwerbeverbot]] · [[hr-ma-rollen-matrix]]
- Analysis: [[hr-schema-deltas-2026-04-19]]

### Memory
- `project_arkadium_role.md` (Arkadium-Touchpoints)
- `project_commission_model.md` (Commission-Engine v1.0)
- `project_phase3_erp_standalone.md` (Standalone-Prinzip)
- `project_activity_linking.md`
- `project_arkadium_roles_2026.md` (MA-Rollen-Matrix 2026)
- `project_sprache_policy.md` (DE only · NEU 2026-04-19)

### Grundlagen
- `raw/Ark_CRM_v2/ARK_DATABASE_SCHEMA_v1_3.md` §dim_mitarbeiter
- `raw/Ark_CRM_v2/ARK_BACKEND_ARCHITECTURE_v2_5.md`
- `raw/Ark_CRM_v2/ARK_STAMMDATEN_EXPORT_v1_3.md` §Rollen + Sparten

### Raw HR-Ordner (Tier-1 ingestiert 2026-04-19)
- `raw/HR/2_HR On- Offboarding/1_Arbeitsverträge/` · 4 Vorlagen
- `raw/HR/2_HR On- Offboarding/2_Reglemente/` · 3 Themen × 3 Varianten
- `raw/HR/2_HR On- Offboarding/3_Provisionsverträge/` · 3 Vorlagen
- `raw/HR/2_HR On- Offboarding/6_Arbeitszeugnisse & Arbeitsbestätigungen/` · 3 Templates + Checkliste
- `raw/HR/2_HR On- Offboarding/7_Weiterbildungsvereinbarung/` · Vorlage
- `raw/HR/2_HR On- Offboarding/8_Stellenbeschreibung/` · 2 Progressus-Vorlagen
- `raw/HR/2_HR On- Offboarding/9_Verwarnung, Kündigung & Aufhebungen/` · 4 Vorlagen
- `raw/HR/2_HR On- Offboarding/13_Dokumente bei Austritt/` · AXA-Merkblätter KKV + Abredeversicherung

---

## 14. Changelog v0.1 → v0.2 (2026-04-19)

### Beantwortet aus Ingest

- §11.1 Bewerber-Phase = **raus** (Lifecycle startet bei Offer)
- §11.6 Feiertage = **ZH initial** (9 konkrete Tage aus Tempus Passio §6)
- §11.7 Sprachen = **DE only** (Memory `project_sprache_policy.md`) · Progressus-Template "EN zwingend" ist Legacy
- §11.8 Arztzeugnis = **Dienstjahr-Staffelung** 1/2/3 Tage (Generalis Provisio §3.5.2)
- §11.9 Ferien-Übertrag = **Ostermontag+14-Deadline** · jüngste zuerst
- §11.12 Probezeit = **3 Monate** (alle Vorlagen)

### Neu hinzugefügt

- §3.2 Arkadium-spezifische Compliance-Details (Kündigungsfristen-Staffel, Arztzeugnis-Staffel, Konkurrenzverbot-Parameter, Disziplinarstrafen-Katalog)
- §4.5 Arkadium-Vertragswerk 5-Schicht-Modell
- §5.7 Verwarnungs-Eskalation Use-Case
- §5.8 Disziplinar-Incident Use-Case
- §5.9 Provisionsvertrag-Jahres-Renewal Use-Case
- §6.2 `dim_job_descriptions` · `dim_reglemente` · `fact_contract_attachments` · `fact_provisionsvertrag_versions` · `fact_role_transitions`
- §6.3 `dim_absence_types` erweiterte Seeds (Arkadium-Extra-Guthaben, DJ-Staffelung, CH-Dienste) · `fact_vacation_balances` mit 5 Extra-Kategorien · `fact_homeoffice_*`
- §6.4 `dim_academy_modules` · `fact_academy_progress` · `fact_training_agreements` + Rückzahlungs-View
- §6.6 `fact_warnings` · `dim_disciplinary_penalty_types` · `fact_disciplinary_incidents`
- §6.8 `v_hr_alerts` erweitert (Warnings · HO-Pending · Alumni-Konkurrenzverbot · Praemium-Renewal)
- §6.9 Events erweitert (18 neue Event-Codes)
- §7.2 Neue Mockups: `hr-warnings-disciplinary.html` · `hr-provisionsvertrag-editor.html` · `hr-academy-dashboard.html`
- §7.3 Neue Drawer: HO-Antrag · Weiterbildungsvereinbarung · Verwarnung · Disziplinar-Incident · Praemium-Renewal · Kündigungs-Annullierung · Aufhebungsvereinbarung
- §8.1b HO+Remote-Work-Phase
- §8.7 Phase 3.7 Disziplinar + Verwarnungen
- §8.8 Phase 3.8 Provisionsvertrag-Renewal-Cycle
- §9 Neue Dependencies: Commission-Engine-Bridge, Signatur-Service, Ostern-Kalender-Worker
- §10 Neue Risiken: Reglement-Revision-Backlog, Praemium-Renewal-Miss, Disziplinar-Verrechnung, §5.3-Grace-Period, Academy-Versioning
- §11C 12 neue offene Fragen

### Deprecated

- `dim_mitarbeiter.commission_rate` (wird durch `fact_provisionsvertrag_versions` ersetzt)

### Next Steps

- ~~v0.2 → PO-Review mit Peter~~ **✓ abgeschlossen 2026-04-19** (alle 18 Fragen beantwortet)
- **Laufend:** `ARK_HR_TOOL_SCHEMA_v0_1.md` + `ARK_HR_TOOL_INTERACTIONS_v0_1.md` schreiben mit finalisierten Entscheidungen aus §11
- **Parallel:** Mockup-Iteration `hr.html` · neue Mockups `hr-warnings-disciplinary.html` · `hr-provisionsvertrag-editor.html` · `hr-academy-dashboard.html`

### PO-Review-Log 2026-04-19

**Alle 18 Fragen in 1-to-1-Dialog beantwortet.** Key-Adjustments gegenüber v0.2-Vorschlägen:

- **§11B-3 Arbeitszeugnis-Generator:** statt "eigenes HR-Feature Phase 3.6" → **globaler Dok-Generator** (bestehende CRM-Infra) · Phase 3.6 im HR-Plan entsprechend reduziert
- **§11C-2 Karenzentschädigung Rollen-Wechsel:** statt "Sofort + pro-rata" → **Individualverhandlung** (mehr Flexibilität bei Beförderungen)
- **§11C-3 Academy-Trainer:** statt "Eigene RBAC-Rolle `Academy_Lead`" → **Multiple Trainer je Modul** (flexibler · kein eigenes Rollen-Konstrukt)
- **§11C-4 Disziplinar-Verrechnung:** strenger als Vorschlag (a) → **GL-Approval + 1 Mt MA-Vorankündigung** · Schutz vor übereilten Payroll-Offsets
- **§11C-6 Honorarstreit:** statt dedizierter Tabelle `fact_extraordinary_commission_revenue` → **manuell durch Backoffice** als Einmalzahlung · vermeidet Overengineering seltener Fälle
- **§11C-8 Alumni-LinkedIn-Monitor:** statt manueller HR-Eintrag → **GF-Ermessen** · noch zurückhaltender, kein automatisierter Flow
- **§11C-11 Extra-Guthaben-Verfall:** zur Vorschlag-Option (a) zusätzlich **HR-Override-Toggle** im Kündigungs-Drawer für Kulanzfälle
- **§11C-1 Reglement-Versionierung:** statt semver-Automatik → **Fall-zu-Fall-HR-Entscheidung** je Version

Entscheidungen wo Vorschlag bestätigt: **§11B-2 · §11B-4 · §11B-5 · §11B-10 · §11B-11 · §11C-5 · §11C-7 · §11C-9 · §11C-10 · §11C-12** (10 von 18).
