---
title: "ARK Zeiterfassung · Umsetzungsplan v0.1"
type: plan
phase: 3
created: 2026-04-19
updated: 2026-04-19
status: draft
sources: [
  "ERP Tools/zeit.html",
  "ERP Tools/zeit-list.html",
  "raw/Ark_CRM_v2/ARK_DATABASE_SCHEMA_v1_3.md",
  "raw/Ark_CRM_v2/ARK_BACKEND_ARCHITECTURE_v2_5.md",
  "raw/Ark_CRM_v2/ARK_STAMMDATEN_EXPORT_v1_3.md",
  "memory/project_commission_model.md",
  "wiki/entities/mandat.md"
]
tags: [plan, erp, zeiterfassung, phase-3, billing, biometrie, fingerabdruck]
---

# ARK Zeiterfassung · Phase-3-Umsetzungsplan v0.1

Dieser Plan konsolidiert Markt-Recherche, interne System-Referenzen, Fingerabdruck-Scanner-Integration und konkretes Datenmodell für das Zeiterfassungs-Modul. Er ist Grundlage für `ARK_ZEITERFASSUNG_SCHEMA_v0_1.md` und `ARK_ZEITERFASSUNG_INTERACTIONS_v0_1.md` (folgen nach PO-Freigabe).

---

## 1. Markt-Überblick · Zeiterfassungs-Tools

### 1.1 Relevante Tools für CH/EU-Dienstleister <50 MA

| Tool | Herkunft | Stärke | Preis-Indikation | Relevanz für uns |
|------|----------|--------|------------------|-------------------|
| **Bexio Zeit** | CH (St. Gallen) | Native CH-Payroll-Integration, ERP-Bundle | ab CHF 29/User/Mt | **hoch** — wir nutzen Bexio bereits für Rechnungsstellung |
| **Proffix / Sage** | CH | Traditionelle KMU-ERP mit Zeit-Modul | ab CHF 50/User/Mt | mittel — konkurrenziert Bexio |
| **Mobatime** | CH | Hardware-nah (Stempeluhren + Fingerabdruck) | hardware-dependent | **hoch** — Fingerabdruck-Scanner-Integration |
| **Personio** | DE | HR + Zeit + Payroll integriert | ab CHF 12/User/Mt | mittel — decken HR schon selbst ab |
| **Factorial** | ES | HR + Zeit, gute UX | ab CHF 6/User/Mt | niedrig — HR selbst gebaut |
| **Clockodo** | DE | Projekt-Zeiterfassung für Agenturen | ab CHF 8/User/Mt | **hoch** — Projekt/Mandat-Paradigma passt |
| **Harvest** | US | Einfache Projekt-Zeit + Billing | ab CHF 12/User/Mt | mittel — US-zentrisch |
| **Toggl Track** | EE | Timer-basiert, leichtgewichtig | ab CHF 10/User/Mt | niedrig — zu wenig ERP-Tiefe |
| **Zep** | DE | Projekt + Kunde + Rechnung für Berater | ab CHF 10/User/Mt | **hoch** — Beratungs-Fokus |
| **HRworks** | DE | Voll-HR inkl. Zeit, integriert | ab CHF 7/User/Mt | niedrig — HR selbst gebaut |
| **Papershift** | DE | Dienstplan + Zeit, schichtbasiert | ab CHF 4/User/Mt | niedrig — Schichten nicht unser Modell |
| **Jibble** | UK | Kostenlose Basis + Fingerabdruck-Support | ab CHF 3/User/Mt | hoch (Vergleich Hardware) |
| **Timeular** | AT | Hardware-Würfel + Timer-App | ab CHF 9/User/Mt | niedrig (Gimmick) |

### 1.2 Feature-Kanon (was jedes ernsthafte Tool hat)

**Core-Features:**
- Wochen- / Tages- / Listen-Ansicht der Erfassung
- Timer (Start/Stop) + Manuelle Nachträge
- Buchungs-Dimensionen: Projekt/Mandat · Kunde · Tätigkeit · Kostenstelle
- Soll-/Ist-Vergleich mit Delta
- Feiertags-Kalender (kantonsabhängig CH)
- Pausen-Regeln (Schweiz: ab 9 h automatische 30-min-Pause)
- Überstunden-Saldo mit konfigurierbarer Abgeltungs-Regel
- Absenzen-Integration (Ferien · Krank · Unbezahlt · Mutterschaft · Militär)

**Beratungs-Features:**
- Billable vs. Non-Billable-Kategorisierung
- Stundensatz pro Kunde/Mandat/Mitarbeiter (oder Mischung)
- Utilization-KPI (billable Stunden / Gesamt-Stunden)
- Fakturierungs-Vorschau + Rechnungs-Export
- Budget-Cap pro Projekt/Mandat mit Alert
- Kalendarisch-Sync (Outlook / Google) als Erfassungs-Vorschlag

**Approval-Flow:**
- Wochen-Submit durch Mitarbeiter
- Manager-Review + Approve / Reject
- Rückwirkende Edits nach Approval sperren
- Audit-Log aller Änderungen

**Hardware-Integration (wo vorhanden):**
- Stempeluhr · PIN · Karte · Fingerabdruck · Gesichtserkennung
- API/Webhook-basierte Events in ERP

**Reports:**
- Utilization pro MA / Team / Periode
- Profit pro Mandat (Stunden × Stundensatz - interne Kosten)
- Payroll-Export (Lohn · Überstunden · Spesen)
- Overtime-Alerts

### 1.3 Was NICHT gebraucht wird für Arkadium-Boutique

- **Schichtpläne** (Gastro/Retail-Feature) — wir sind Berater, keine Schichten
- **GPS-Geofencing** — überkontrolliert für Vertrauensarbeit
- **Aktivitäts-Screenshots** (Toggl-Style) — Micromanagement
- **Minute-Tracking** — 0.5-h-Granularität ist ausreichend
- **Multi-Language-UI** — nur DE (bei Bedarf später FR)
- **Native Mobile App** — responsive Web reicht

### 1.4 UX-Best-Practices (Akzeptanz-Faktoren)

**Was Friction reduziert:**
- Template-Woche kopieren (letzte Woche → neue Woche)
- Inline-Editing im Grid ohne Modal
- Auto-Vorschläge basierend auf Kalender + CRM-History
- Lane-Suche („Bauherr Muster" statt MAN-2026-014)
- Bulk-Edit für identische Buchungen mehrere Tage

**Was User frustriert:**
- Over-Approval (jede Änderung muss 2x bestätigt werden)
- Zu granulare Felder (100+ Activity-Types auf einmal)
- Projekt-Suche ohne Auto-Complete
- Keine Erinnerung an unerfasste Tage
- Wochen-Abschluss blockiert rückwirkende Legit-Korrekturen

---

## 2. Schweizer Arbeitsrecht · Compliance-Baseline

### 2.1 Pflicht-Regeln

| Regel | Quelle | Impact |
|-------|--------|--------|
| **Arbeitszeit-Dokumentation** | ArG Art. 73 | Stunden-Tracking ist **Pflicht**, auch bei Vertrauensarbeit (Art. 73a) |
| **Vereinfachtes Verfahren** | ArGV1 Art. 73a | Bei Lohn &gt; CHF 120k + Autonomie: nur wöchentliche Summe erforderlich |
| **Tägliche Ruhezeit** | ArG Art. 15a | 11 h zwischen 2 Arbeitstagen · System sollte Verletzungen flaggen |
| **Pausen-Pflicht** | ArG Art. 15 | Ab 5.5 h = 15 min · ab 7 h = 30 min · ab 9 h = 60 min |
| **Höchstarbeitszeit** | ArG Art. 9 | 45 h / Wo (Büro) · 50 h / Wo (andere) |
| **Sonntagsarbeit** | ArG Art. 18 | Nur mit Bewilligung · auch für Berater relevant |
| **Aufbewahrungspflicht** | ArGV1 Art. 73 | **5 Jahre** Arbeitszeit-Daten |
| **Zugriff Kontrollorgan** | ArG Art. 42 | Seco muss jederzeit Einsicht haben können |

### 2.2 Ausnahmen (leitende Angestellte)

- Geschäftsleitung = PW (Managing Partner) — **keine Stempelpflicht**, nur Kontroll-Tracking freiwillig
- Senior Consultants mit VR-Rolle / hoher Autonomie: Vereinfachtes Verfahren möglich

### 2.3 Biometrie & DSG

**Relevante Artikel DSG (revidiert 2023):**

| Art. | Inhalt | Impact Fingerabdruck |
|------|--------|----------------------|
| **Art. 5 lit. c** | Biometrische Daten zur eindeutigen Identifikation = **besonders schützenswert** | Fingerabdruck fällt drunter |
| **Art. 6** | Rechtmäßigkeit: Zweckbindung, Verhältnismäßigkeit | Fingerabdruck nur wenn kein milderes Mittel reicht |
| **Art. 8** | Datensicherheit: angemessene Massnahmen | Template-Hash + Verschlüsselung-at-Rest Pflicht |
| **Art. 19** | Informationspflicht bei Beschaffung | Mitarbeiter muss informiert werden |
| **Art. 22** | Datenschutz-Folgeabschätzung | **Pflicht** bei Biometrie-System |
| **Art. 30** | Einwilligung bei besonders schützenswerten Daten | Explizite, dokumentierte Zustimmung · jederzeit widerrufbar |

**Konsequenzen für unser Tool:**
1. **Fingerabdruck nur optional** — Alternative (PIN/Karte) muss existieren
2. **Template-Hash lokal auf Scanner + verschlüsselt im ERP** · nie roher Abdruck speichern
3. **DSFA (Datenschutz-Folgeabschätzung)** vor Einführung — dokumentieren
4. **Einwilligungs-Formular** pro MA · widerrufbar (dann Rollback zu PIN)
5. **Separate Aufbewahrung** von biometrischen Templates · Löschung bei Austritt automatisch
6. **Log-Separation**: Zutritt-Events (aus Scanner) ≠ HR-Personal-Daten

---

## 3. Interne System-Referenzen (Ergebnisse Agent-Scan)

### 3.1 Was existiert bereits

**DB-Felder mit Zeit-Bezug:**
- `fact_history.activity_duration_minutes` — Dauer einzelner Activities (Call: 42 min, Meeting: 60 min)
- `fact_history.activity_timestamp` — Vollständiger Zeitstempel
- `fact_reminders.due_time` + `done_at` — Reminder-Fälligkeiten

**Mandat-Typen** (STAMMDATEN §13 + `fact_mandate.mandate_type`):
- **Target** — Fixpauschale, Stunden sind interne KPI (nicht billing-relevant)
- **Taskforce** — Monats-Fee + Stunden-Cap (z.B. 80 h / Monat)
- **Time** — pure Stunden-Billing (CHF 165/h Beispiel)

**Mitarbeiter-Felder** (`dim_mitarbeiter`):
- `commission_rate` · `target_calls_day` · `target_briefings_month` · `target_gos_month` · `target_placements_year` · `target_revenue_year`
- Keine direkte Zeit-Ziele oder Pensum-Felder → **ERGÄNZUNGS-BEDARF**

**Mockup-Assets:**
- `ERP Tools/zeit.html` · Wochen-Timesheet mit 6 Tabs (bereits gebaut)
- `ERP Tools/zeit-list.html` · Team-Übersicht (bereits gebaut)
- Activity-Dauer in `candidates.html` History-Drawer (z.B. „42 min")

### 3.2 Was fehlt (Gap-Analyse)

| Priorität | Lücke | Typ |
|-----------|-------|-----|
| **BLOCKER** | `fact_time_entries` | Neue Fakt-Tabelle |
| **BLOCKER** | `fact_absences` + `dim_absence_types` | Bereits in HR-Tool geplant, aber Schema fehlt |
| **BLOCKER** | `dim_time_packages` | In v1.3 erwähnt, Inhalt fehlt |
| **BLOCKER** | Timesheet-Workflow-Events | `timesheet_*`-Events fehlen in `dim_event_types` |
| **P0** | `fact_time_budgets` | Soll-Stunden pro MA + Periode |
| **P0** | `fact_work_contracts` (oder Erweiterung dim_mitarbeiter) | Pensum, Tagesstunden, Feiertags-Region |
| **P1** | `fact_time_approvals` | Manager-Approval-State |
| **P1** | Utilization-Views | SQL-Views für KPI-Berechnung |
| **P1** | Billing-Integration | `fact_mandate_billing` ↔ `fact_time_entries` Link |
| **P2** | Biometrie-Stack | `dim_biometric_templates` · `fact_clock_events` · `dim_time_terminals` |
| **P2** | Kalender-Sync-Import | Outlook-Events → Buchungsvorschläge |
| **P2** | Activity-Linking | `fact_history.time_entry_id` FK |

---

## 4. Fingerabdruck-Scanner · Architektur

### 4.1 Hardware-Auswahl

**Empfehlung: Mobatime AMG oder ZKTeco IClock (3-Weg-Entscheidung nach Evaluation)**

| Hersteller | Modell | Schnittstelle | Vorteile | DSG-Risiko |
|------------|--------|---------------|----------|------------|
| **Mobatime AMG** | AMG-86 | REST-API + SFTP | CH-Hersteller, Ersatzteile CH | niedrig (CH-hosted) |
| **ZKTeco** | IClock 880 | ZKAccess + API | Markt-Standard, günstig | mittel (China-OEM · prüfen) |
| **Suprema BioStation** | 2A | REST + LDAP | Top-Template-Qualität | niedrig |
| **Dormakaba/Kaba** | b-COMM | Proprietär | Enterprise-Standard | niedrig |

**Auswahl-Kriterien:**
1. REST-API oder Webhook für Event-Streaming ins ERP
2. Template-Hash lokal auf Gerät (kein Upload zu Cloud)
3. Fallback-PIN für Mitarbeiter ohne Biometrie-Einwilligung
4. CH-Support / Schweizer Datenzentrum

### 4.2 Datenfluss

```
[Scanner am Office-Eingang]
        │
        │ 1. Mitarbeiter legt Finger auf
        │ 2. Scanner matcht gegen lokalen Template-Hash
        │ 3. Match → HTTPS POST /api/v1/clock-events
        │
        ▼
[ARK ERP · /api/v1/clock-events]
        │
        │ 1. Validiert HMAC-Signatur
        │ 2. Mappt Template-ID → dim_mitarbeiter_id
        │ 3. INSERT fact_clock_events
        │ 4. Fire EVENT: clock_in / clock_out
        │
        ▼
[Worker · time-entry-autofill.worker.ts]
        │
        │ Wenn Mitarbeiter der Woche noch keine Buchung:
        │ Vorschlag generieren (Start-/Ende-Zeit + default-Mandat)
        │
        ▼
[Mitarbeiter im zeit.html]
        │
        │ Sieht „auto-erfasst 08:15 - 17:42 · 9.5 h"
        │ Bestätigt oder korrigiert
        │ → fact_time_entries finalisiert
```

### 4.3 Neue Tabellen für Biometrie

```sql
-- Biometrische Templates (gehashte Fingerabdruck-Vektoren)
CREATE TABLE dim_biometric_templates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  mitarbeiter_id UUID NOT NULL REFERENCES dim_mitarbeiter(id) ON DELETE CASCADE,
  template_hash TEXT NOT NULL UNIQUE,        -- SHA-256 des Templates
  scanner_id UUID REFERENCES dim_time_terminals(id),
  enrolled_at TIMESTAMPTZ NOT NULL,
  enrolled_by UUID REFERENCES dim_mitarbeiter(id),
  consent_document_url TEXT NOT NULL,        -- signierte Einwilligung
  consent_given_at TIMESTAMPTZ NOT NULL,
  revoked_at TIMESTAMPTZ,                    -- bei Widerruf
  active BOOLEAN GENERATED ALWAYS AS (revoked_at IS NULL) STORED
);

-- Time-Terminals (physische Geräte)
CREATE TABLE dim_time_terminals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  terminal_name TEXT NOT NULL,               -- "Haupteingang Zürich"
  serial_number TEXT UNIQUE,
  vendor TEXT,                               -- "Mobatime" · "ZKTeco"
  model TEXT,
  api_endpoint TEXT,
  api_hmac_secret TEXT NOT NULL,             -- für Event-Auth
  location TEXT,                             -- "Zürich HQ"
  installed_at DATE,
  last_heartbeat TIMESTAMPTZ,
  active BOOLEAN DEFAULT true
);

-- Ein-/Austempel-Events
CREATE TABLE fact_clock_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  mitarbeiter_id UUID NOT NULL REFERENCES dim_mitarbeiter(id),
  terminal_id UUID NOT NULL REFERENCES dim_time_terminals(id),
  event_type TEXT NOT NULL CHECK (event_type IN ('clock_in','clock_out','break_start','break_end','unknown')),
  event_timestamp TIMESTAMPTZ NOT NULL,
  auth_method TEXT NOT NULL CHECK (auth_method IN ('fingerprint','pin','card','manual')),
  confidence_score NUMERIC(3,2),             -- 0.00 - 1.00 vom Scanner
  time_entry_id UUID REFERENCES fact_time_entries(id),  -- nach Autofill-Match
  raw_payload JSONB,                         -- Original-Webhook für Debug
  created_at TIMESTAMPTZ DEFAULT now()
);
```

### 4.4 Opt-In / Opt-Out-Flow

**UI-Sektion im HR-Tab „System-Zugang":**

```
Biometrie-Zutritt ○ nicht eingerichtet  [Einrichten]
                  ● aktiv seit 15.02.2026  [Widerrufen]
```

Beim **Einrichten**:
1. DSFA-Dokument anzeigen (PDF aus `specs/DSFA_BIOMETRIE_v1.md`)
2. Einwilligungs-Formular signieren (elektronisch)
3. Termin am Scanner-Terminal für Enrollment
4. Template wird gehashed, `consent_document_url` + `consent_given_at` gesetzt

Beim **Widerrufen**:
1. `revoked_at = now()`
2. Template-Hash invalidieren (Scanner-Sync)
3. Mitarbeiter erhält temporären PIN per Email
4. HR-Notification + Audit-Log

---

## 5. Empfohlenes Datenmodell (final)

### 5.1 Neue Fakt-Tabellen

```sql
-- Kern: eine Buchung pro Mitarbeiter/Tag/Kategorie
CREATE TABLE fact_time_entries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  mitarbeiter_id UUID NOT NULL REFERENCES dim_mitarbeiter(id),
  entry_date DATE NOT NULL,
  iso_week INT NOT NULL,                      -- ISO-Kalenderwoche
  iso_year INT NOT NULL,
  hours NUMERIC(4,2) NOT NULL CHECK (hours > 0 AND hours <= 24),
  category TEXT NOT NULL CHECK (category IN (
    'mandate_billable',    -- billable für Target-Mandat
    'mandate_time',        -- billable Time-Mandat (auto-invoice)
    'mandate_internal',    -- Mandat-Arbeit, nicht billable
    'internal_admin',      -- Overhead / Admin
    'internal_training',   -- Schulungen
    'internal_research',   -- Pipeline-Pflege
    'absence_vacation',    -- Ferien (Mirror)
    'absence_sick',        -- Krankheit (Mirror)
    'absence_holiday',     -- Feiertag
    'absence_other'        -- Unbezahlt / Militär / Mutterschaft
  )),
  mandate_id UUID REFERENCES fact_mandate(id),
  project_id UUID REFERENCES fact_projects(id),
  process_id UUID REFERENCES fact_process(id),
  activity_type_id UUID REFERENCES dim_activity_types(id),
  role_in_mandate TEXT CHECK (role_in_mandate IN ('am','cm','research','consultant')),
  description TEXT,
  billable BOOLEAN GENERATED ALWAYS AS (category IN ('mandate_billable','mandate_time')) STORED,
  hourly_rate_chf NUMERIC(8,2),              -- pro Buchung (kann variieren je Mandat)
  source TEXT NOT NULL CHECK (source IN ('manual','timer','clock_auto','import_calendar','import_history')),
  clock_event_in_id UUID REFERENCES fact_clock_events(id),
  clock_event_out_id UUID REFERENCES fact_clock_events(id),
  week_status TEXT NOT NULL DEFAULT 'open' CHECK (week_status IN ('open','submitted','approved','locked')),
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  created_by UUID NOT NULL REFERENCES dim_mitarbeiter(id),
  UNIQUE (mitarbeiter_id, entry_date, category, mandate_id, project_id)
);

-- Wochen-Status je MA (denormalisierter Cache)
CREATE TABLE fact_time_weeks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  mitarbeiter_id UUID NOT NULL REFERENCES dim_mitarbeiter(id),
  iso_week INT NOT NULL,
  iso_year INT NOT NULL,
  target_hours NUMERIC(5,2) NOT NULL,
  actual_hours NUMERIC(5,2) NOT NULL DEFAULT 0,
  billable_hours NUMERIC(5,2) NOT NULL DEFAULT 0,
  overtime_hours NUMERIC(5,2) GENERATED ALWAYS AS (actual_hours - target_hours) STORED,
  status TEXT NOT NULL DEFAULT 'open' CHECK (status IN ('open','submitted','approved','rejected','locked')),
  submitted_at TIMESTAMPTZ,
  approved_at TIMESTAMPTZ,
  approved_by UUID REFERENCES dim_mitarbeiter(id),
  rejection_reason TEXT,
  comment TEXT,
  UNIQUE (mitarbeiter_id, iso_year, iso_week)
);

-- Soll-Stunden-Budgets (Pensum-Änderungen, Teilzeit)
CREATE TABLE fact_time_budgets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  mitarbeiter_id UUID NOT NULL REFERENCES dim_mitarbeiter(id),
  valid_from DATE NOT NULL,
  valid_until DATE,
  pensum_percent NUMERIC(4,1) NOT NULL CHECK (pensum_percent > 0 AND pensum_percent <= 100),
  hours_per_week NUMERIC(4,2) NOT NULL,
  hours_per_day NUMERIC(4,2) NOT NULL,
  vacation_days_per_year INT NOT NULL,
  canton_code CHAR(2) NOT NULL,             -- für Feiertags-Kalender
  holiday_calendar_id UUID REFERENCES dim_holiday_calendars(id),
  overtime_annual_threshold NUMERIC(5,2) DEFAULT 50,  -- ab 50 h wird ausbezahlt
  overtime_multiplier NUMERIC(3,2) DEFAULT 1.25       -- 125 % Ausbezahlung
);

-- Überstunden-Saldo (Event-Sourced Snapshot pro Monat)
CREATE TABLE fact_overtime_snapshots (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  mitarbeiter_id UUID NOT NULL REFERENCES dim_mitarbeiter(id),
  snapshot_year INT NOT NULL,
  snapshot_month INT NOT NULL,
  opening_balance NUMERIC(6,2) NOT NULL,    -- Saldo-Start
  month_delta NUMERIC(6,2) NOT NULL,        -- +/- dieses Monats
  closing_balance NUMERIC(6,2) NOT NULL,
  above_threshold_paid NUMERIC(6,2) DEFAULT 0,  -- über 50 h → Auszahlung
  time_off_taken NUMERIC(6,2) DEFAULT 0,
  UNIQUE (mitarbeiter_id, snapshot_year, snapshot_month)
);
```

### 5.2 Neue Dim-Tabellen

```sql
-- Absenzen-Typen (Phase 3 + HR-Tool-Sync)
CREATE TABLE dim_absence_types (
  id UUID PRIMARY KEY,
  code TEXT UNIQUE NOT NULL,                -- 'vacation','sick','holiday','unpaid','maternity','military'
  label_de TEXT NOT NULL,
  paid BOOLEAN NOT NULL,
  requires_certificate BOOLEAN NOT NULL,    -- Arztzeugnis?
  requires_approval BOOLEAN NOT NULL,
  counts_towards_overtime BOOLEAN DEFAULT false,
  sort_order INT
);

-- Feiertags-Kalender (kantonsabhängig CH)
CREATE TABLE dim_holiday_calendars (
  id UUID PRIMARY KEY,
  canton_code CHAR(2) NOT NULL,
  name_de TEXT NOT NULL,
  year INT NOT NULL,
  UNIQUE (canton_code, year)
);

CREATE TABLE fact_holidays (
  id UUID PRIMARY KEY,
  calendar_id UUID NOT NULL REFERENCES dim_holiday_calendars(id),
  holiday_date DATE NOT NULL,
  name_de TEXT NOT NULL,
  paid BOOLEAN DEFAULT true,
  half_day BOOLEAN DEFAULT false
);

-- Time-Packages (Time-Mandate-Pakete)
CREATE TABLE dim_time_packages (
  id UUID PRIMARY KEY,
  name_de TEXT NOT NULL UNIQUE,             -- 'Entry 2-Slot', 'Medium 3-Slot', 'Professional 4-Slot'
  num_slots INT NOT NULL,
  price_per_slot_per_week NUMERIC(8,2) NOT NULL,
  list_price_per_slot_per_week NUMERIC(8,2),
  min_weeks INT DEFAULT 1,
  cancellation_notice_weeks INT DEFAULT 3,
  hours_per_slot NUMERIC(4,2) NOT NULL,     -- z.B. 10 h / Slot / Woche
  sort_order INT
);
```

### 5.3 Views für Reporting

```sql
-- Utilization pro MA/Woche
CREATE VIEW v_utilization AS
SELECT
  mitarbeiter_id,
  iso_year, iso_week,
  SUM(hours) FILTER (WHERE billable) AS billable_hours,
  SUM(hours) AS total_hours,
  ROUND(100.0 * SUM(hours) FILTER (WHERE billable) / NULLIF(SUM(hours), 0), 1) AS utilization_pct
FROM fact_time_entries
WHERE category LIKE 'mandate_%' OR category LIKE 'internal_%'
GROUP BY mitarbeiter_id, iso_year, iso_week;

-- Time-Mandat-Billing-Queue (Auto-Invoice-Kandidaten)
CREATE VIEW v_time_billing_queue AS
SELECT
  mandate_id,
  EXTRACT(MONTH FROM entry_date) AS billing_month,
  EXTRACT(YEAR FROM entry_date) AS billing_year,
  SUM(hours) AS total_hours,
  SUM(hours * hourly_rate_chf) AS gross_amount_chf,
  MIN(entry_date) AS period_start,
  MAX(entry_date) AS period_end
FROM fact_time_entries
WHERE category = 'mandate_time' AND week_status = 'locked'
GROUP BY mandate_id, billing_month, billing_year;
```

### 5.4 Events (dim_event_types-Erweiterung)

| Event-Code | Trigger | Nutzer |
|------------|---------|--------|
| `time_entry_created` | Mitarbeiter bucht Stunde | Audit-Log |
| `time_entry_updated` | Änderung vor Lock | Audit-Log |
| `time_week_submitted` | Mitarbeiter schliesst Woche ab | Notification an Manager |
| `time_week_approved` | Manager bestätigt | Billing-Worker triggert |
| `time_week_rejected` | Manager rejected | Notification an MA |
| `time_week_locked` | Nach Approval | Edit-Sperre aktiv |
| `clock_event_in` | Scanner-Tempel | Auto-Fill-Worker |
| `clock_event_out` | Scanner-Tempel | Auto-Fill-Worker |
| `overtime_threshold_reached` | 90 % der 50h-Schwelle | HR + MA Notification |
| `time_billing_ready` | Time-Mandat Monat abschliessbar | Backoffice-Worker |
| `absence_booked` | Absenz-Eintrag (Mirror aus HR) | Timesheet-Update |
| `biometric_enrolled` | Neuer Fingerabdruck registriert | Audit + HR |
| `biometric_revoked` | Einwilligung widerrufen | Scanner-Sync |

---

## 6. UI-Scope (Ausbau bestehender Mockups)

### 6.1 Erweiterungen `zeit.html` (bereits gebaut)

**Tab 1 · Woche** — ergänzen:
- Template-Woche-Kopieren-Button („Letzte Woche als Vorlage")
- Kalender-Sync-Vorschläge (Outlook-Events als pending-Buchungen)
- Auto-Clock-In-Anzeige wenn Scanner-Event existiert („08:15 erkannt · bestätigen?")

**Tab 2 · Monat** — ergänzen:
- Heatmap Ferien-Ampeln
- Spalte „Approved by"

**Tab 3 · Pro Mandat** — ergänzen:
- Filter billable/non-billable
- Ausschöpfungs-Progressbar je Taskforce-Cap

**Tab 4 · Überstunden** — ok, nur DSG-Hinweis-Box

**Tab 5 · Absenzen** — bleibt Mirror ✓

**Tab 6 · History** — ergänzen:
- Filter nach Event-Typ
- Clock-Events sichtbar

**Neue Tabs (optional Phase 3.1):**
- **Tab 7 · Biometrie** — Einwilligung + Enrollment-Status (nur wenn Feature-Flag `feature_biometric` aktiv)

### 6.2 Erweiterungen `zeit-list.html`

- Spalte „Biometrie aktiv" · Ja/Nein
- Spalte „Heute eingecheckt" · Clock-In-Zeit aus Scanner
- Filter „Seit 1 Tag nicht eingetroffen" (für HR-Nachfass)

### 6.3 Neue Mockups

**Update 2026-04-30:** Funktionen sind in existierende Mockups integriert worden (statt separate Files) — Pattern-Decision analog `hr-absence-calendar.html` (Cross-Modul-Funktion lebt in einem Hauptmockup).

| Mockup (Plan) | Tatsächliche Realisierung | Status |
|---------------|---------------------------|--------|
| ~~`zeit-approvals.html` (P0)~~ | Integriert in `zeit-team.html` (H1 „Team · Zeit-Approvals" + Tab „Monats-Approvals" + Stempel-Antrag-Liste) | ✅ **integriert** |
| ~~`zeit-billing.html` (P0)~~ | Integriert in **Billing-Modul** (`billing/billing-rechnungen.html` macht Time-Mandat-Rechnungen · Cross-Modul-Pattern: Billing ist Domain-Owner) | ✅ **integriert in Billing-Modul** |
| ~~`zeit-reports.html` (P1)~~ | Teilweise integriert in `zeit-saldi.html` + `zeit-export.html` · Profit-per-Mandate + Trend-Charts überlappen mit Performance-Modul (`performance-revenue.html`) | 🟡 **teilweise** (Profit/Trend könnte zukünftig dediziert kommen) |
| ~~`zeit-biometric-admin.html` (P2)~~ | Integriert in `zeit-admin.html` (Scanner-Access-Audit · 73b-Vereinbarungen · DSG-Audit revDSG Art. 5 Ziff. 4) | ✅ **integriert** |
| ~~`zeit-mobile.html` (P3)~~ | Responsive bereits in existierenden Mockups (Plan-Notiz bestätigt) | ✅ **nicht nötig** |

**Architektur-Pattern bestätigt:** Cross-Modul-Funktionen (Billing-Handover, Mobile-Responsive) leben in Domain-Owner-Mockups, nicht als duplicate Sub-Pages im Quell-Modul. Spart Wartungs-Aufwand und vermeidet Spec-Drift.

**Verbleibende echte Lücke:** ggf. dediziertes `zeit-reports.html` für Profit-per-Mandate-Analytics — aber überlappt mit Performance-Modul, Bedarf Phase-3.2-Entscheidung.

---

## 7. Umsetzungs-Phasen

### Phase 3.0 · Fundament (2-3 Wochen Dev)

**Was:** Kern-Tabellen + manuelle Erfassung ohne Scanner

1. Migration: `fact_time_entries` · `fact_time_weeks` · `fact_time_budgets` · `dim_absence_types` · `dim_holiday_calendars` · `fact_holidays`
2. Endpoints: `POST/GET/PATCH /api/v1/time-entries` · `POST /api/v1/time-weeks/:id/submit` · `POST /api/v1/time-weeks/:id/approve`
3. UI: `zeit.html` aktueller Stand geht live
4. Feiertags-Seed für Kantone ZH, BS, BE, ZG, SG (wo MA wohnen)
5. RBAC-Erweiterung: Rolle `Time_Approver` (= Vorgesetzter) + `HR_Manager` (Edit-Rechte)
6. Absenzen-Mirror-Trigger: `fact_absence` (HR-Tool) → auto-INSERT in `fact_time_entries` mit category=`absence_*`

**Definition of Done:**
- MA kann Woche erfassen, submitten, Manager approved
- Utilization-View liefert Zahlen
- Feiertage werden korrekt abgezogen

### Phase 3.1 · Billing-Integration (2 Wochen Dev)

**Was:** Time-Mandate automatisch abrechnen

1. `dim_time_packages` seeden mit Entry/Medium/Professional-Definitionen
2. View `v_time_billing_queue` + Worker `time-billing-monthly.worker.ts`
3. UI: `zeit-billing.html` · Backoffice sieht „Rechnung bereit" pro Mandat
4. Integration mit Bexio-API für Rechnung-Export (oder CSV-Fallback)
5. `fact_mandate_billing.time_entry_period_id` FK zu `fact_time_weeks`

**Definition of Done:**
- Time-Mandat Monatsabschluss klickbar · Rechnung-Preview → Bexio-Export
- Taskforce-Cap-Alerts bei 80 % Ausschöpfung

### Phase 3.2 · Überstunden + Reports (1-2 Wochen Dev)

**Was:** Saldo-Logik + Reports

1. `fact_overtime_snapshots` monatlich materialisieren (Worker)
2. `overtime_threshold_reached`-Alert bei 90 %
3. UI: `zeit-reports.html` · Utilization-Charts + Profit-per-Mandate
4. Payroll-Export (CSV) für externe Systeme

**Definition of Done:**
- Monatsabschluss-Saldo korrekt
- Alerts feuern an HR + MA bei 45 h Saldo
- PDF-Report pro MA/Monat

### Phase 3.3 · Biometrie (3-4 Wochen, nur wenn Peter greenlight)

**Was:** Fingerabdruck-Scanner-Anbindung

1. Hardware-Evaluation (Mobatime vs. ZKTeco vs. Suprema) · Beschaffung
2. DSFA-Dokument erstellen + Rechts-Review
3. Migration: `dim_time_terminals` · `dim_biometric_templates` · `fact_clock_events`
4. Endpoint: `POST /api/v1/clock-events` (Webhook von Scanner)
5. Worker: `time-entry-autofill.worker.ts` · Auto-Vorschläge aus Clock-Events
6. UI: Einwilligungs-Flow + Biometrie-Tab in HR-Tool
7. Enrollment-Termine mit HR koordinieren
8. Fallback-PIN-System für opt-out-User

**Definition of Done:**
- Einwilligung signiert pro MA (dokumentiert)
- Fingerabdruck-Stempel → auto Buchung im zeit.html innert 5 min
- Widerruf → Template gelöscht + PIN-Failover aktiv
- DSG-Folgeabschätzung abgenommen

### Phase 3.4 · Kalender-Sync + UX-Polish (optional)

- Outlook-Events → Buchungs-Vorschläge (nutzt bestehende OAuth-Tokens aus Email-Tool)
- Template-Woche kopieren
- Inline-Edit im Grid
- Mobile-optimierte Quick-Entry-View

---

## 8. Abhängigkeiten

| Erforderlich VOR Start | Begründung |
|------------------------|------------|
| HR-Tool Phase 3.0 live (Schema + Mockup) | `dim_mitarbeiter`-Erweiterungen + Absenzen-Integration |
| Feature-Flag-System in Admin-Vollansicht | `feature_time_tracking` · `feature_biometric` (Phase 3.3) |
| Bexio-API-Credentials (Backoffice) | Rechnung-Export Phase 3.1 |
| Rechts-Review (DSG-Folgeabschätzung) | Biometrie Phase 3.3 |
| Hardware-Beschaffung (Scanner) | Phase 3.3 |

---

## 9. Risiken

| Risiko | Wahrsch. | Impact | Mitigation |
|--------|----------|--------|------------|
| MA-Akzeptanz niedrig (Vertrauensarbeit-Kultur) | mittel | hoch | Freiwilliges Erfassen Phase 3.0 · nur Time-Mandate pflicht |
| DSG-Verstoss Biometrie | niedrig | sehr hoch | DSFA + Rechts-Review + Opt-Out-Fallback |
| Bexio-Integration hakt | mittel | mittel | CSV-Fallback als Plan B |
| Feiertags-Kalender falsch (kantonale Sonderfälle) | mittel | niedrig | Seed-Daten + jährlicher Maintenance-Task |
| Scanner-Hardware-Ausfall | niedrig | mittel | PIN-Fallback immer verfügbar |
| Überstunden-Alerts zu spät | niedrig | mittel | Worker tägl. statt monatl. für Schwell-Detection |

---

## 10. Offene Entscheidungen (für Peter am Dienstag)

1. **Mandat-Erfassung für Target-Mandate** · pflicht oder freiwillig?
2. **Granularität** · 0.5 h Schritte (aktuell) · oder 0.25 h / freie Minuten?
3. **Template-Woche** · lokal pro MA oder zentral vom HR?
4. **Scanner-Standort(e)** · nur Zürich-HQ oder auch Basel/Winterthur (falls Remote-Home)?
5. **Biometrie-Alternative** · PIN · RFID-Karte · Mobile-App mit PIN?
6. **Bexio-Integration Zeitpunkt** · Phase 3.1 zwingend oder später?
7. **Historische Daten** · Stunden vor Go-Live manuell nachtragen oder Stichtag-Start?
8. **Approvals** · jede Woche Manager-Sign-Off oder nur bei Delta > X h?
9. **Vertrauensarbeit-Regime** · alle MA stempeln oder nur unter Senior-Level?
10. **Integration CRM-Activities** · `fact_history`-Aktivitäten auto ins Timesheet?

---

## Related

- [[hr-tool-plan]] (wenn vorhanden)
- [[project_commission_model]] (Provisionen — Lohn-Side, nicht Stunden)
- [[mandat]] (Target · Taskforce · Time · Stundenbasis)
- [[activity-types]] (STAMMDATEN §14 · Zeit-Dimension optional)
- `ERP Tools/zeit.html` · `zeit-list.html`
- Künftig: `ARK_ZEITERFASSUNG_SCHEMA_v0_1.md` · `ARK_ZEITERFASSUNG_INTERACTIONS_v0_1.md`
