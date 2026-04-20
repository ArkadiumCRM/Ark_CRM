---
title: "Research-Prompts Phase 3 ERP (Zeit/Billing/Performance)"
type: meta
created: 2026-04-19
updated: 2026-04-19
sources: []
tags: [meta, phase3, research, prompt-template, external-ai, product-design]
---

# Research- & Design-Prompts für externe AIs · Phase 3 ERP-Module

Ziel: Analog HR-Tier-1-Ingest, aber erweitert um **Produkt-Design** (UI/Rollen/Logik/Integration). Prompts durch 2-3 externe AIs laufen lassen, Antworten konsolidieren, dann Claude Code baut Spec v0.x + Mockups.

**Output-Pflicht-Format (10 Sections je Tool):**

```
1. Legal-Framework (Paragraph-Refs, nur bei Zeit + Billing)
2. Stammdaten-Deltas (neue Enums/Kataloge)
3. Schema-Deltas (DDL-Snippets)
4. Prozess-Flows (Happy-Path + Edge-Cases + Saga-Steps)
5. Business-Logic (State-Machines, Berechnungen, Trigger, Validierungen)
6. UI-Architektur (Seiten, Drawer, Navigation, Screen-Inventory)
7. Rollen-Matrix (Wer sieht/bearbeitet was — MA/TL/GF/Backoffice/Admin)
8. Integrationen (intern: CRM/Commission/Email · extern: Treuhand/Payroll/Bexio)
9. Open Questions (nummeriert, konkret beantwortbar)
10. Risiken & Grauzonen (rechtlich/operativ/technisch)
```

---

## PROMPT 1 · ZEITERFASSUNG

**Attach:**
- Keine ARK-internen Dokumente nötig (Research rein rechtlich + branchenüblich)
- Optional: interne Arbeitszeit-Regeln (Excel, docx) wenn vorhanden

**Prompt-Text:**

```
Du bist Product-Designer + Business-Analyst für ein Schweizer CRM/ERP-System
einer Headhunting-Boutique (10 Mitarbeiter, Kanton Zürich, keine GAV). Wir
bauen ein vollständiges Zeiterfassungs-Modul. Deine Aufgabe: komplette
Produkt-Spezifikation inkl. UI-Design, Rollenlogik und Integrationen.

Kontext:
- 10 MA, Rollen: Founder · Head-of · Senior-Researcher · CM · AM · Researcher
  · Assistenz
- Rechtsgrundlage: Obligationenrecht (OR Art. 319-343) + Arbeitsgesetz (ArG)
  + ArGV 1/2, SECO-Wegleitung
- Einzelarbeitsverträge (42.5h/Woche Jahresarbeitszeit), keine GAV
- Firma nutzt Commission-Engine mit ZEG-Staffel (Zeit-Einsatz-Grad) →
  Zeiterfassung muss auf Mandate/Prozesse gebucht werden
- Treuhand-Partner (Treuhand Kunz) macht Payroll → CSV-Export (Bexio-CSV
  + Swissdec-ELM-Format)
- Bestehende CRM-Mockups: 540px-Drawer als Default, Editorial-Serif-Style
  (Libre Baskerville + DM Sans), 9-Stage-Prozess-Pipeline

Liefere strukturiert 10 Sections:

1. LEGAL-FRAMEWORK
   - Zeiterfassungspflicht ArG Art. 46 + ArGV 1 Art. 73 (detailliert)
   - Ausnahmen Art. 73a/b ArGV 1 (vereinfachte Erfassung ab CHF 120k / GL-Pos)
   - Ruhezeiten Art. 15-22 ArG (tägl. 11h, wöchentl. 35h, Pausen)
   - Höchstarbeitszeit Art. 9-12 ArG + OR Art. 321c (Überzeit)
   - Ferienanspruch OR Art. 329a, Kompensation Überzeit Art. 321c Abs. 3
   - Nacht-/Sonntagsarbeit ArG Art. 16-20 (in Headhunting meist N/A)
   - Krank/Unfall/Militär OR Art. 324a Bern-Skala
   - BGE 4A_295/2016 + Bundesgerichts-Urteile zu Zeiterfassungspflicht

2. STAMMDATEN-DELTAS
   Vollständige Enum-Listen, auch Detail-Level:
   - Abwesenheits-Typen (Ferien, Krank-bezahlt, Krank-unbezahlt, Unfall,
     Militär, Zivildienst, Schule/Weiterbildung, Mutterschaft, Vaterschaft,
     Pflege-Angehörige, Kompensation, unbezahlter Urlaub, Trauerfall…)
   - Zeit-Kategorien (Productive-billable, Productive-nonbillable, Admin,
     Training, Internal-Meeting, Client-Meeting, Travel, Break…)
   - Arbeitszeit-Modelle (Vertrauensarbeitszeit, Gleitzeit mit Kernzeit,
     Fix-Zeit, Teilzeit-%)
   - Feiertage Kanton ZH (1.1, 2.1, Karfreitag, Ostermontag, 1.5, Auffahrt,
     Pfingstmontag, 1.8, Bettag, 25.12, 26.12) + halbe Tage
   - Pausen-Regeln (30min ab 7h, 60min ab 9h tägl. Arbeitszeit)

3. SCHEMA-DELTAS
   DDL für mindestens:
   - `fact_time_entry` (user_id FK, date, start_time, end_time, duration_min,
     project_id FK NULL, category, billable BOOL, approved_by FK NULL,
     approved_at, comment, created_at, audit_trail_jsonb)
   - `fact_absence` (user_id FK, absence_type_code FK, start_date, end_date,
     paid BOOL, approved_by FK, doctor_cert_file VARCHAR NULL,
     doctor_cert_uploaded_at, status, created_at)
   - `dim_absence_type` (code, label_de, paid_default, max_days_per_year,
     requires_cert_from_day INT, requires_approval BOOL)
   - `fact_workday_target` (user_id FK, year, target_hours_per_week,
     default_break_min, variant_percent, contract_start, contract_end)
   - `fact_holiday_cantonal` (canton_code, date, label_de, half_day BOOL)
   - `fact_time_correction` (original_entry_id FK, corrected_by, reason,
     old_values_jsonb, new_values_jsonb, approved_by, audit)
   - Alle Indexes + Constraints

4. PROZESS-FLOWS
   - Tages-Erfassung: Timer-Start/Stop, nachträgliche manuelle Eintragung,
     Projekt-Auswahl, Kategorie
   - Monats-Abschluss: MA-Submit → Supervisor-Approval → Finale Sperre →
     Treuhand-Export
   - Korrektur nach Approval: Antrag MA → Re-Approval TL → Audit-Entry
   - Urlaubs-Antrag: Einreichen → Approval TL → Kalender-Sync
     (Team-Kalender für Abwesenheits-Übersicht)
   - Krankmeldung: Selbst-Meldung (bis 3 Tage) vs. Arztzeugnis (ab 3. Tag)
   - Überzeit-Kompensation: Auszahlung (Antrag TL+GF) vs. Zeit-Ausgleich
     (self-service wenn < 10h)
   - Feiertags-Behandlung (anteilig bei Teilzeit)

5. BUSINESS-LOGIC
   - Stunden-Saldo-Berechnung: Soll (aus workday_target) vs. Ist (sum
     time_entries) + Abwesenheiten + Feiertage
   - Überzeit-Schwelle: >45h/Woche = Überzeit (ArG Art. 9), >60h/Woche =
     illegal → Alert
   - Pflicht-Pausen-Validierung (30min/60min)
   - Ferien-Verjährung OR Art. 329a (5 Jahre)
   - Ferien-Übertrag max. 5 Tage ins Folgejahr (Firmen-Regel konfigurierbar)
   - Krank-Anspruch Bern-Skala (3 Wo 1. DJ, 1 Mt 2.-3. DJ, etc.)
   - State-Machine Time-Entry: draft → submitted → approved → locked →
     corrected (mit Audit-Historie)

6. UI-ARCHITEKTUR
   Screen-Inventory:
   - **Dashboard** (Hero-KPIs: Wochen-Saldo, Monats-Soll/Ist, Ferien-Rest,
     Abwesenheiten Team · Timer-Widget · nächster Feiertag)
   - **Tages-Erfassung** (aktive Woche + Kalender-Nav, Projekt-Dropdown,
     inline-Edit, Bulk-Copy gestriger Tag)
   - **Monats-Übersicht** (Tabelle Tag/Soll/Ist/Diff/Status + Export)
   - **Abwesenheits-Kalender** (Monats-Grid, MA-Zeilen, Type-farbig,
     Klick = Drawer)
   - **Antrags-Liste** (offene Approvals für TL/GF)
   - **Saldi-Ansicht** (Ferien-Konto, Überzeit-Konto, Krank-Konto)
   - **Admin-Module** (Arbeitszeit-Modelle, Feiertage-Editor, MA-Verträge)

   Drawer-Inventory:
   - Tages-Eintrag-Edit (540px, Felder: Datum/Start/Ende/Pause/Projekt/
     Kategorie/Billable/Kommentar)
   - Urlaubs-Antrag (540px, Felder: Typ/Von/Bis/Halbtag/Grund + Auto-Calc
     Arbeitstage)
   - Krank-Meldung (540px, Felder: Von/Bis/Arztzeugnis-Upload/Bemerkung)
   - Korrektur-Antrag (540px mit Diff-Preview)
   - Monats-Abschluss-Confirm (Modal 420px, atomare Sperre)

   Navigation:
   - Sidebar-Module (gleiche 56/240px-Pattern wie CRM): Dashboard · Meine Zeit
     · Abwesenheiten · Team · Saldi · Admin

7. ROLLEN-MATRIX
   | Feature                   | MA | TL | GF | Backoffice | Admin |
   |---------------------------|----|----|----|------------|-------|
   | Eigene Zeit erfassen      | ✓  | ✓  | ✓  | ✓          | ✓     |
   | Eigene Abwesenheit        | ✓  | ✓  | ✓  | ✓          | ✓     |
   | Team-Zeit sehen           | –  | ✓  | ✓  | ✓          | ✓     |
   | Team-Zeit approven        | –  | ✓  | ✓  | –          | –     |
   | Monats-Abschluss auslösen | –  | –  | ✓  | ✓          | –     |
   | Treuhand-Export           | –  | –  | ✓  | ✓          | –     |
   | Arbeitszeit-Modell ändern | –  | –  | ✓  | –          | ✓     |
   | Feiertage editieren       | –  | –  | –  | –          | ✓     |
   | Korrektur nach Lock       | –  | –  | ✓  | –          | –     |
   (Matrix erweitern, spezifische Cases dokumentieren)

8. INTEGRATIONEN
   - **CRM-Integration**: Projekt-Dropdown speist aus fact_process_core
     (nur active); time_entry.project_id FK
   - **Commission-Engine**: ZEG-Staffel-Berechnung nutzt fact_time_entry
     aggregiert je Mandat (Aufruf-Trigger für Commission-Recalc)
   - **Email/Kalender**: Urlaubs-Approval sendet Mail an MA + Team;
     Abwesenheit wird in Team-Kalender als All-Day-Event eingetragen
   - **Treuhand Kunz**: CSV-Export Monats-Ende mit Stunden/Abwesenheiten
     (Schema: MA-Nr, Monat, Soll, Ist, Ferien, Krank, Unfall, Überzeit);
     Swissdec-ELM falls zukünftig Direct-Payroll
   - **Bexio**: optional Stunden-Sync für Projekt-Billing
   - **Mobile/PWA**: Timer + schnelle Eintrag (später Phase 3.5)

9. OPEN QUESTIONS
   Nummeriert 1-N, je binär oder Multiple-Choice, z.B.:
   1. Arbeitszeit-Modell Default = (a) Vertrauensarbeitszeit / (b) Gleitzeit
      mit Kernzeit 09:00-15:00 / (c) Mix je Rolle?
   2. Soll-Ist-Auflösung = (a) Minute / (b) 15-min-Block / (c) Stunde?
   3. Überzeit-Cap = (a) 45h/Woche strikt / (b) 50h mit Signoff TL /
      (c) Jahres-Saldo prüfen?
   4. Ferien-Übertrag = (a) max 5 Tage / (b) unlimitiert bis Dezember /
      (c) Verfall 31.3.?
   5. Approval-Zyklus = (a) wöchentlich / (b) monatlich / (c) ad-hoc?
   …

10. RISIKEN & GRAUZONEN
    - Vertrauensarbeitszeit-Grauzone (ab CHF 120k-Pos zulässig, aber
      Dokumentation trotzdem empfohlen)
    - Art. 73b ArGV 1 vereinfachte Erfassung: benötigt schriftliche
      Vereinbarung MA↔AG
    - Teilzeit-Aufrechnung bei Kündigungsschutz (OR Art. 324a)
    - Ferien bei Rechtszeit-Schwankungen (anteilig je Dienstjahr?)
    - Datenschutz: Standort-Daten (Mobile-Timer)?
    - Audit-Trail-Aufbewahrung ArG Art. 73 Abs. 2 = mind. 5 Jahre

Output: reine Markdown mit H2/H3, keine Fliesstext-Einleitung, direkt
die 10 Sections. Tabellen wo sinnvoll.
```

---

## PROMPT 2 · BILLING

**Attach (alle aus `raw/General/1_ Rechnungen & -sheets/`):**

- `Best Effort/*` — Best-Effort-Rechnungsvorlagen
- `Mandat/*` — Mandat-Rechnungsvorlagen
- `Rechnungssheet/*` — historische Rechnungssheets
- `Rückerstattung/*` — Refund-Beispiele
- Optional: `Provisionssheet Joaquin Vega.xlsx` + `Provisionssheet Peter Wiederkehr.xlsx` (für Commission↔Billing-Verknüpfung)

**Prompt-Text:**

```
Du bist Product-Designer + Business-Analyst für ein Schweizer CRM/ERP-System
einer Headhunting-Boutique. Wir bauen ein vollständiges Billing-Modul mit
UI-Design, Rollen und Integrationen. Anbei echte Rechnungen + Vorlagen.

Kontext:
- 2 Business-Models:
  * Erfolgsbasis (Best Effort) — Honorar nur bei Platzierung
  * Mandat (Target / Taskforce / Time) — Anzahlung + Erfolgshonorar
- AGB §6: Schutzfrist 12 Mt (16 Mt bei Nicht-Kooperation) bei Direkteinstellung
- Garantiefrist 3 Mt post-Placement (Ersatz oder Refund bei Kündigung)
- MwSt 8.1%, Default-Zahlungsziel 30 Tage
- 3-Stufen-Mahnwesen intern, dann Inkasso
- Treuhand-Partner Treuhand Kunz (office@treuhand-kunz.ch) für Buchhaltung
- Bestehende CRM-Mockups: Editorial-Style, 540px-Drawer-Default

Liefere strukturiert 10 Sections:

1. LEGAL-FRAMEWORK
   - OR Art. 102-109 (Verzug, Mahnung, Zinsen)
   - OR Art. 394-406a (Auftragsrecht/Vermittlungsvertrag)
   - MWSTG + MWSTV (MwSt-Ausweisung, Reverse Charge EU)
   - DSG + DSGVO (Kandidaten-Daten auf Rechnung)
   - Inkasso-Recht + Betreibung SchKG
   - QR-Rechnung-Pflicht (ab 30.09.2022)
   - Verjährungsfristen (OR Art. 127/128, 10J vs. 5J)

2. STAMMDATEN-DELTAS
   - Rechnungstyp (Akonto, Schluss, Garantie-Refund, Bonus, Storno,
     Gutschrift, Mahngebühr, Inkasso-Gebühr)
   - Zahlstatus (offen, teilbezahlt, überfällig, bezahlt, abgeschrieben,
     inkasso, honorarstreit, gestundet)
   - Mahnstufen (1/2/3 + Betreibung)
   - Gutschriftsgründe (Fehler, Kulanz, Korrektur, Stornierung)
   - MwSt-Kategorien (Normal 8.1%, Reduziert 2.6%, Reverse-Charge 0%)
   - Zahlungsmittel (Bank-Überweisung, QR, Credit-Card, Stripe)

3. SCHEMA-DELTAS
   DDL:
   - `fact_invoice` (invoice_nr UNIQUE, customer_id FK, process_id FK NULL,
     invoice_type, amount_net, mwst_rate, amount_gross, currency,
     issued_at, due_at, paid_at, status, payment_reference, qr_iban,
     besr_reference, pdf_path)
   - `fact_invoice_item` (invoice_id FK, position, description, quantity,
     unit_price, discount_pct, total_net, mwst_code)
   - `fact_dunning` (invoice_id FK, level 1-3, sent_at, fee, deadline)
   - `fact_credit_note` (invoice_id FK, reason_code, amount, issued_at,
     approved_by)
   - `fact_payment` (invoice_id FK, amount, payment_date, payment_method,
     reference, bank_booking_jsonb)
   - `fact_refund` (invoice_id FK, reason_process_id, amount, approved_by,
     paid_at, reason) // Garantie-Fall
   - Alle Indexes + FK-Constraints

4. PROZESS-FLOWS
   - Best-Effort-Flow: Placement → Invoice-Draft → Invoice-Issued → Payment
     → Garantie-Timer-Start
   - Mandat-Flow: Auftrag → Akonto-Invoice → Akonto-Payment →
     Zwischen-Rechnung (optional, Time/Milestone) → Schluss-Invoice nach
     Placement → Payment
   - Refund/Rückerstattung: Kandidat verlässt in Garantiefrist →
     Ersatzvorschlag oder Refund-Invoice (Negativ)
   - Mahnwesen: T+30 Mahnstufe 1 → T+45 Stufe 2 → T+60 Stufe 3 →
     T+90 Inkasso-Übergabe
   - Honorarstreit: Kunde verweigert Zahlung → interne Eskalation
     GF → Inkasso-Partner
   - Gutschrift/Storno: Bug in Rechnung → Storno + neue Invoice
   - MwSt-Quartals-Abrechnung

5. BUSINESS-LOGIC
   - Auto-Generierung QR-Rechnung aus Template (IBAN/QR-IBAN/BESR-Ref)
   - Auto-Zuordnung Bank-Zahlung über BESR-Referenz
   - Teilzahlung → Rest-Status "teilbezahlt"
   - Garantie-Timer-Start = Placement-Datum + Payment-Eingang
   - Refund-Berechnung bei Kandidat-Kündigung < 30/60/90 Tage (Staffel)
   - MwSt-Split bei Mix-Rechnungen
   - Skonto (falls eingeführt)
   - State-Machine Invoice: draft → issued → partial → paid | overdue →
     dunning_L1 → dunning_L2 → dunning_L3 → inkasso → written_off

6. UI-ARCHITEKTUR
   Screen-Inventory:
   - **Dashboard** (Offen/Überfällig/Bezahlt YTD · Kreditoren-Liste Top-10 ·
     Mahnungs-Pipeline · Ausgehende MwSt-Abrechnung)
   - **Rechnungs-Liste** (Filter: Status/Kunde/Datum/Typ; Bulk-Actions:
     Exportieren/Mahnen/Stornieren)
   - **Rechnungs-Editor** (Positionen, MwSt-Split, QR-Preview, Auto-
     Fill aus process_core)
   - **Mahnwesen-Cockpit** (pending Stufen · One-Click "alle Stufe 1 senden")
   - **Kreditoren-Ansicht** (pro Kunde: alle Rechnungen, offene Posten,
     Zahlungshistorie)
   - **Zahlungseingang** (Bank-Import-View + Auto-Match via BESR)
   - **MwSt-Abrechnung** (Quartals-Report zum Einreichen bei ESTV)
   - **Refund-Cockpit** (Garantie-Fälle mit Frist)

   Drawer:
   - Rechnung-Detail (540px; Positionen + Zahlungen + Mahnungen +
     Audit-Historie)
   - Rechnung-Erstellen (540px; Multi-Step: Kunde → Process → Positionen
     → MwSt → Preview → Issue)
   - Gutschrift (540px; Rechnung auswählen + Grund + Betrag)
   - Mahnung-Senden (Modal 420px; Preview + Confirm)
   - Zahlung-Erfassen (540px; manuell wenn Auto-Match fehlschlägt)
   - Refund-Berechnung (540px; Staffel-Preview + Confirm)

7. ROLLEN-MATRIX
   | Feature               | AM | CM | Backoffice | GF | Treuhand | Admin |
   |-----------------------|----|----|------------|-----|----------|-------|
   | Rechnung erstellen    | –  | –  | ✓          | ✓   | –        | –     |
   | Rechnung senden       | –  | –  | ✓          | ✓   | –        | –     |
   | Mahnung auslösen      | –  | –  | ✓          | ✓   | –        | –     |
   | Gutschrift ausstellen | –  | –  | ✓ (<5k)    | ✓   | –        | –     |
   | Rechnungs-Liste sehen | ✓  | –  | ✓          | ✓   | –        | ✓     |
   | Kundenzahlung sehen   | ✓  | –  | ✓          | ✓   | –        | ✓     |
   | Export Treuhand       | –  | –  | ✓          | ✓   | ✓ (RO)   | –     |
   | MwSt-Abrechnung       | –  | –  | ✓          | ✓   | ✓ (RO)   | –     |

8. INTEGRATIONEN
   - **CRM**: Rechnung verknüpft mit process_core (Placement) und
     mandate (bei Mandat-Flow)
   - **Commission-Engine**: Payment-Eingang triggert Commission-Berechnung
     + Payout-Scheduling
   - **Email**: Rechnungs-PDF + Zahlungserinnerung via Outlook
     (individual tokens pro User)
   - **QR-Bill-Library** (z.B. `manuelbl/swiss-qr-bill`) für QR-Gen
   - **Bank-API** (Raiffeisen/ZKB/UBS EBICS oder CAMT.053 XML-Import)
     für Zahlungs-Abgleich
   - **Treuhand Kunz**: CSV/XML-Export der monatlichen Rechnungs- und
     Zahlungsdaten für Buchhaltung + MwSt
   - **Bexio** (optional): Rechnungen parallel in Bexio syncen falls
     Treuhand-Wechsel

9. OPEN QUESTIONS
   1. Eigene QR-Gen in-house oder externer Service (Twint Business)?
   2. Bank-Abgleich via (a) manueller CSV-Upload / (b) API-Integration /
      (c) EBICS-Automat?
   3. Inkasso-Partner fix oder situationsabhängig?
   4. MwSt-Abrechnung (a) in-app / (b) Treuhand / (c) hybrid?
   5. Akonto-% Mandat: fix 30% / 50% oder variabel pro Mandat?
   6. Mahngebühr: fixbetrag (CHF 30/50/80) oder %?
   7. Garantie-Refund-Staffel: linear oder Stufen?
   …

10. RISIKEN & GRAUZONEN
    - QR-Rechnung-Pflicht seit 30.09.2022 — Nicht-Konformität = Ablehnung
      durch Kunde
    - MwSt-Registrierungspflicht ab CHF 100k Jahresumsatz
    - Reverse-Charge bei EU-Kunden (DE/AT) — ESTV-Meldung
    - Rechnungs-Archivierung 10J (OR Art. 958f)
    - DSG: Kandidaten-Name auf Rechnung? (besser anonymisiert bei GDPR-Kunde)
    - Verjährung 5J für Honorare (OR Art. 128 Ziff. 1) vs. 10J allgemein
    - Betreibungs-Risiko: wann Reputations-Schaden überwiegt Forderung?

Output: reine Markdown 10 Sections.
```

---

## PROMPT 3 · PERFORMANCE (Reporting & KPI)

**Attach (alle aus `raw/General/5_Reportings/`):**

- `AM Reporting Fokus.pdf` — Account-Management-Reporting
- `CM Reporting Fokus.pdf` — Candidate-Management-Reporting
- `Reporting Hunt.docx` — Hunt/Research-Reporting
- `Reporting_Team Leader.pdf` — Team-Leader-Reporting
- `Vorlagen_Indesigns/*` — InDesign-Export-Vorlagen

**Prompt-Text:**

```
Du bist Product-Designer + Business-Analyst für ein Schweizer CRM/ERP-System
einer Headhunting-Boutique. Wir bauen ein vollständiges Performance/
Reporting-Modul. Anbei 4 aktuelle Reporting-Vorlagen aus dem Alltagsbetrieb.

Kontext:
- 4 Rollen mit eigenem Reporting: AM · CM · Researcher (Hunt) · Team-Leader
- Arkadium-M4-Modell (MEET · MATCH · MARKET · MONEY × je 4 Substeps = 16)
- 9-Stage-Prozess-Pipeline (Expose · CV Sent · TI · 1st · 2nd · 3rd ·
  Assessment · Offer · Placement)
- Commission-Engine (50/50 AM↔CM bei Placement, Researcher-Pauschale 500)
- Bestand: bis 100 Mandate parallel, 50-80 Placements/Jahr, 10 MA
- Bestehende CRM-Mockups: Editorial-Style, 540px-Drawer, Snapshot-Bar-Pattern

Liefere strukturiert 10 Sections (Legal-Framework entfällt, durch
Datenschutz-Check ersetzt):

1. DATENSCHUTZ-FRAMEWORK (statt Legal)
   - DSG + DSGVO bei MA-Performance-Daten
   - OR Art. 328 (Persönlichkeitsschutz AG)
   - Auskunftsrecht MA auf eigene Performance-Daten
   - Aufbewahrung + Löschung (Bewerbungsunterlagen-Parallele)
   - Betriebs-Rat / Kadervertreter bei >20 MA (Schwelle noch nicht
     erreicht)

2. STAMMDATEN-DELTAS
   - Reporting-Intervall (weekly, monthly, quarterly, yearly, custom)
   - KPI-Kategorien (Activity, Conversion, Revenue, Quality, Time)
   - Benchmark-Typen (Team-Avg, Firma-Historie 3J, extern-Branche,
     persönliches-Vorjahr)
   - KPI-Rollen-Scope (self, team, firm)
   - Goal-Status (set, on-track, at-risk, missed, exceeded)

3. SCHEMA-DELTAS
   DDL:
   - `fact_kpi_snapshot` (user_id FK, role_scope, kpi_code, period_start,
     period_end, value, benchmark_value, delta_pct, calculated_at,
     source_query_hash)
   - `dim_kpi_definition` (code UNIQUE, label_de, formula_spec_jsonb,
     role_scope, unit, benchmark_type, m4_phase NULL, pipeline_stage NULL,
     leading_lagging)
   - `fact_reporting_cycle` (user_id FK, period, generated_at, pdf_path,
     sent_to_emails TEXT[], reviewed_by FK, locked_at)
   - `fact_goal` (user_id FK, kpi_code FK, period_start, period_end,
     target_value, actual_value, status, created_by, approved_by)
   - `fact_benchmark_reference` (kpi_code FK, benchmark_type, period,
     value, source)
   - `fact_team_review` (team_id, period, facilitator_user_id, notes_md,
     action_items_jsonb, scheduled_at)

4. PROZESS-FLOWS
   - Monatlicher Cycle: Cron Tag 1 → Snapshots berechnen → TL reviewt →
     Freigabe GF → PDF-Gen + Versand
   - Quartals-Review: zusätzlich Team-Meeting-Prep (Vergleich 3 Monate,
     Ziel-Setzung Q+1)
   - Jahres-Review: Bonus-Berechnung (Commission-Engine-Link), Ziel-
     Anpassung Folgejahr
   - Pipeline-Drill-Down: MA klickt KPI → Drawer mit zugrunde liegenden
     Prozessen/Activities
   - Benchmark-Alert: KPI unterschritten Schwellwert → Auto-Alert an TL
     + MA + 1:1-Scheduling-Vorschlag
   - Korrektur-Flow: MA bestreitet KPI → TL Review → Recalc oder Overwrite
     + Audit

5. BUSINESS-LOGIC
   - Formel-Engine: formula_spec_jsonb als DSL für KPI-Berechnung (z.B.
     `{"op":"ratio","num":"count(cv_sent)","denom":"count(expose)"}`)
   - Leading vs. Lagging: z.B. CV-Send-Rate (leading) vs. Placement-Count
     (lagging)
   - M4-Mapping: jeder KPI kann optional M4-Phase zuordnen
     (MEET/MATCH/MARKET/MONEY)
   - Benchmark-Normalisierung: neue MA (< 6 Mt) gegen Onboarding-Benchmark,
     Senior gegen Senior-Benchmark
   - Saldo-Ebenen: self (Individual), team (Rolle-Aggregat), firm (gesamt)
   - State-Machine Goal: draft → set → on-track → at-risk | exceeded |
     missed → closed

6. UI-ARCHITEKTUR
   Screen-Inventory:
   - **Dashboard** (eigene Top-KPIs · vs. Vorperiode · vs. Benchmark ·
     Goal-Fortschritt · Drill-Down-Cards)
   - **KPI-Katalog** (alle KPIs, Formel-Preview, Benchmark, Rollen-Scope)
   - **Reporting-Generator** (MA wählt Periode + KPIs → Live-Preview →
     PDF-Export oder Email-Versand)
   - **Team-Dashboard** (TL-View: alle MA nebeneinander, Heatmap rot/gelb/
     grün)
   - **Firm-Dashboard** (GF-View: Gesamt-Trends, Top/Bottom-5, Mandats-
     Auslastung)
   - **Goal-Setting-Cockpit** (Periode-Start: Ziele festlegen, TL-Approval)
   - **Review-Modus** (Monats-/Quartalsbesprechung; strukturierte Notizen,
     Action-Items, Follow-up)
   - **KPI-Drill-Down-Drawer** (Klick auf KPI öffnet Drawer mit
     zugrundeliegenden Rows: Prozesse, Aktivitäten, Placements)

   Drawer:
   - KPI-Detail (540px; Formel + History 12 Mt + Vergleich Team/Benchmark)
   - Goal-Setzung (540px; KPI + Target + Rationale + TL-Approval)
   - Review-Notiz (540px; Prep für 1:1/Team-Meeting)
   - Benchmark-Korrektur (540px; Admin)

7. ROLLEN-MATRIX
   | Feature               | MA | TL | GF | Backoffice | Admin |
   |-----------------------|----|----|----|------------|-------|
   | Eigenes Dashboard     | ✓  | ✓  | ✓  | ✓          | ✓     |
   | Eigene KPIs Drill     | ✓  | ✓  | ✓  | –          | ✓     |
   | Team-KPIs sehen       | –  | ✓  | ✓  | –          | ✓     |
   | Firm-KPIs sehen       | –  | –  | ✓  | ✓          | ✓     |
   | Goals setzen (eigene) | ✓  | ✓  | ✓  | –          | –     |
   | Goals approven        | –  | ✓  | ✓  | –          | –     |
   | PDF-Export (eigenes)  | ✓  | ✓  | ✓  | ✓          | –     |
   | KPI-Definition ändern | –  | –  | –  | –          | ✓     |
   | Benchmark ändern      | –  | –  | –  | –          | ✓     |
   | Review-Notiz schreiben| ✓  | ✓  | ✓  | –          | –     |

8. INTEGRATIONEN
   - **CRM**: alle KPIs werden aus fact_process_core, fact_activity,
     fact_placement berechnet (read-only Join)
   - **Commission-Engine**: Placement-KPIs triggern Commission-Calc;
     Jahres-Review nutzt Commission-Ledger
   - **Zeit-Modul**: ZEG-KPIs (Zeit pro Mandat) aus fact_time_entry
   - **Email**: Monats-Report versendet via Outlook-Integration
     (individual tokens)
   - **PDF-Generator** (z.B. Puppeteer / Chromium-headless) für
     Report-Export; InDesign-Vorlagen als HTML-Template migriert
   - **Calendar**: 1:1- und Team-Reviews im Kalender eingetragen
   - **Notifications**: Alerts via in-app + Email wenn KPI <Schwellwert
   - **Export**: Excel/CSV für externe Analyse (Power-BI / Google Sheets)

9. OPEN QUESTIONS
   1. Report-Generierung (a) PDF via Chromium / (b) InDesign via
      InCopy-CC-Automation / (c) HTML live im Browser?
   2. KPI-Snapshot-Frequenz = (a) täglich / (b) wöchentlich /
      (c) on-demand?
   3. Benchmark-Normalisierung: wie lang ist "neu" bei MA?
      (3 Mt / 6 Mt / 12 Mt?)
   4. Alert-Trigger-Schwelle = (a) % unter Benchmark /
      (b) absolute Zahl / (c) TL-config pro KPI?
   5. Goal-Approval-Zyklus = (a) jährlich / (b) quartalsweise /
      (c) mix je KPI?
   6. MA-Performance-Daten-Aufbewahrung = (a) 5J / (b) 10J /
      (c) until-request-delete?
   7. M4-Mapping obligatorisch pro KPI oder optional?
   …

10. RISIKEN & GRAUZONEN
    - DSG: MA-Auskunftsrecht auf eigene Performance-Daten (Art. 8 DSG)
    - Persönlichkeitsschutz OR Art. 328 bei schlechten KPIs
      (Kündigungsgrund? Gerichtsentscheide?)
    - Benchmark-Vergleich zwischen MA = "Ranking" → Mitarbeiter-
      Unzufriedenheit-Risiko
    - Neue MA vs. Senior — ungleicher Vergleich
    - KPI-Gaming-Risiko (MA füllt nur KPIs ohne echten Wert)
    - Datenvolumen: bei 10 MA × 50 KPIs × monatlich × 10J = 60k Snapshots,
      wartbar
    - InDesign-Automation: komplex, CC-Server Lizenz-Frage

Output: reine Markdown 10 Sections.
```

---

## Workflow nach Retouren

Wenn Peter 2-3 AI-Antworten pro Tool zurück hat:

1. **Ingest** in `wiki/sources/phase3-research/`
   - `phase3-zeit-research-claude.md`, `-gpt.md`, `-gemini.md`
   - `phase3-billing-research-...`
   - `phase3-performance-research-...`

2. **Konsolidieren** pro Tool in `wiki/meta/phase3-<tool>-consolidated.md`
   - Identische Findings = confirmed
   - Widersprüche = als Open Question zurück an Peter
   - Best-Of aus den 3 Antworten je Section

3. **User Q&A** (analog HR-Plan v0.2): Open Questions nacheinander
   beantworten lassen

4. **Schema v0.1 + Interactions v0.1** generieren

5. **Mockups** bauen aus Specs

6. **Grundlagen-Sync**: in `ARK_STAMMDATEN_EXPORT_v1_*`,
   `ARK_DATABASE_SCHEMA_v1_*`, `ARK_BACKEND_ARCHITECTURE_v2_*` deltas einspielen
