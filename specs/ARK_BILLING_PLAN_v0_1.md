---
title: "ARK Billing-Modul · Umsetzungsplan v0.1"
type: plan
phase: 3
created: 2026-04-20
updated: 2026-04-20
status: draft
po_review_date: 2026-04-20
po_review_status: "Batches 1–3 komplett (14/15) · Q4 System-of-Record + Q11 Team-Wechsel offen"
sources: [
  "specs/ARK_BILLING_RESEARCH_CLAUDE_v0_1.md",
  "specs/ARK_BILLING_RESEARCH_GPT_v0_1.md",
  "specs/ARK_BILLING_RESEARCH_GEMINI_v0_1.md",
  "raw/Ark_CRM_v2/Arkadium_AGB_FEB_2023.pdf",
  "raw/Ark_CRM_v2/ARK_DATABASE_SCHEMA_v1_3.md",
  "raw/Ark_CRM_v2/ARK_BACKEND_ARCHITECTURE_v2_5.md",
  "raw/Ark_CRM_v2/ARK_STAMMDATEN_EXPORT_v1_3.md",
  "raw/Ark_CRM_v2/ARK_FRONTEND_FREEZE_v1_10.md",
  "raw/Anhang - Provisionsstaffel CM.pdf",
  "raw/General/1_ Rechnungen & -sheets/ (PDF-Templates)",
  "specs/ARK_COMMISSION_ENGINE_SPEC_v0_1.md",
  "specs/ARK_HR_TOOL_PLAN_v0_2.md (Vorbild-Struktur)",
  "wiki/meta/decisions.md (§2026-04-20 Billing-Batches 1–3 · AGB-Review · SIX-Fact-Check)",
  "memory/project_commission_model.md",
  "memory/project_guarantee_protection.md",
  "memory/project_refund_model_routing.md",
  "memory/project_arkadium_roles_2026.md",
  "memory/reference_treuhand_kunz.md",
  "memory/project_phase3_erp_standalone.md",
  "memory/feedback_mockup_first_workflow.md (Phase 3 = Spec-First)"
]
grundlagen_sync_required: [
  "raw/Ark_CRM_v2/ARK_STAMMDATEN_EXPORT_v1_3.md (neue §Billing-Stammdaten · dim_invoice_types/dim_invoice_status/dim_honorar_staffel/dim_refund_reasons/dim_mwst_codes/dim_payment_methods/dim_refund_denial_reasons)",
  "raw/Ark_CRM_v2/ARK_DATABASE_SCHEMA_v1_3.md (neue Tabellen: fact_invoice · fact_invoice_item · fact_payment · fact_dunning · fact_credit_note · fact_refund · fact_inkasso · fact_invoice_audit · dim_honorar_staffel · dim_refund_denial_reasons · fact_mandate.payment_terms_days/contract_pdf_path · fact_candidate_placement.probezeit_months/probezeit_end_date · dim_accounts-Adress-Struktur-Felder)",
  "raw/Ark_CRM_v2/ARK_BACKEND_ARCHITECTURE_v2_5.md (neue Events/Worker/Endpoints · Billing-Saga)",
  "raw/Ark_CRM_v2/ARK_FRONTEND_FREEZE_v1_10.md (neue Routen /billing/* · UI-Patterns · Rechnungs-Editor-Drawer)",
  "raw/Ark_CRM_v2/ARK_GESAMTSYSTEM_UEBERSICHT_v1_3.md (Changelog)"
]
tags: [plan, erp, billing, phase-3, arkadium-honorar, qr-bill, standalone, commission-coupling]
---

# ARK Billing-Modul · Phase-3-Umsetzungsplan v0.1

**Phase-3-ERP-Modul · eigenständiges ARK-Produkt** (Memory `project_phase3_erp_standalone.md`). Kernfunktion: Honorar-Rechnungsstellung für Best-Effort- + Mandat-Placements der Arkadium-Headhunting-Boutique (10–12 MA) inkl. Mahnwesen, Refund-Workflow (Garantie-Fall), Bank-Reconciliation, MwSt-Quartalsabrechnung, Treuhand-Export.

Grundlage für `ARK_BILLING_SCHEMA_v0_1.md` + `ARK_BILLING_INTERACTIONS_v0_1.md`.

---

## 1. Scope · Was ist das Billing-Modul

### 1.1 Zielgruppen

- **Intern primär:** Backoffice (S. Tanner · Draft-Erstellung · Bank-Import · Treuhand-Export)
- **Intern sekundär:** GF (Nenad · Approval-Authority für alle kritischen Aktionen) · AM (Lesezugriff eigene Kunden-Zahlungen für Commission-Transparenz)
- **Extern:** Treuhand Kunz (Read-Only-Export-Empfänger) · Kantonalbank (CAMT.054-Datenquelle)

### 1.2 Was das Billing-Modul IST

- **Rechnungs-Orchestrator:** Best-Effort (1 Rechnung bei Placement) + Mandat (3 Stage-Rechnungen Akonto/Zwischen/Schluss) + Kündigungs-Rechnung (Mandat-Abbruch) + Rückerstattung (Garantie-Fall) + Gutschrift + Storno + Mahnung + Schutzfrist-Bonus (§6 AGB, selten)
- **3-seitiger PDF-Generator:** Anschreiben (Seite 1, Founder + Bereichs-Head-Signatur) + Rechnungs-Tabelle mit Kandidaten-Details (Seite 2) + Blind-Copy + Swiss QR-Bill (Seite 3, SIX v2.3/v2.4-konform)
- **Honorar-Staffel-Engine:** 21/23/25/27 % nach Jahressalär (AGB §4) · Rabatt-Override möglich
- **Mahnwesen segmentiert pro Kunden-Klasse:** Key-Accounts T+30/45/60, Standard T+15/30/45 (→ Inkasso bei GF-Freigabe)
- **Refund-Workflow mit Probezeit-basierter Staffel:** 100 % vor Start · 50/25/10 % in Probezeit-Monat 1/2/3 · 0 % nach Probezeit (AGB §8)
- **Bank-Reconciliation:** CAMT.054-Import · Auto-Match via QRR/SCOR-Referenz · Teilzahlungs-Handling
- **MwSt-Quartals-Abrechnung:** Aggregat + ESTV-konformer Report
- **Treuhand-Kunz-Export:** monatlicher Bexio-CSV (Rechnungen + Zahlungen + Gutschriften + Refunds + Debitoren-Saldo)
- **Commission-Engine-Bridge:** Payment-Event triggert Commission-Berechnung · Refund-Event triggert Clawback
- **Revisionssichere Archivierung:** PDF-Hashes (SHA-256) + 10-Jahres-Retention (OR 958f)
- **Debitoren-Ansicht pro Kunde:** alle Rechnungen + Zahlungen + offener Saldo + DSO

### 1.3 Was das Billing-Modul NICHT ist

- **Keine Payroll-Engine** — Lebt im HR-Tool + Treuhand Kunz
- **Keine Commission-Berechnung** — Eigenes Commission-Engine-Modul (`specs/ARK_COMMISSION_ENGINE_SPEC_v0_1.md`) · Billing liefert nur Zahlungs-Events
- **Keine FIBU-Engine** — Buchhaltung bleibt bei Treuhand Kunz · Billing exportiert CSV
- **Keine EU-Kunden-Fakturierung in MVP** — Reverse-Charge + EU-Pflichttexte vertagt (Feature-Flag `feature_eu_invoicing`)
- **Keine Multi-Währung in MVP** — CHF-only (EUR-Variante vertagt)
- **Keine Verzugszins-/Mahngebühr-Berechnung in MVP** — Felder vorbereitet, aber immer 0 (vertagt bis AGB-Revision)
- **Keine automatische Bank-API** — MVP = manueller CAMT.054-Upload (EBICS-API vertagt)
- **Kein Bexio-Sync** — Export-only (CSV-Dump), keine bidirektionale Sync
- **Kein aktives Inkasso-Interface** — MVP liefert Inkasso-Dossier-Export (Vertrag + AGB + Rechnung + Mahnungen + Korrespondenz), externe Übergabe manuell

---

## 2. Markt-Referenz · Billing-Tools für KMU

Kompakt — nicht hauptrelevant, weil Billing-Modul stark Arkadium-spezifisch (3-Seiten-PDF-Layout, Probezeit-Staffel, Mandat-Stage-Modell).

| Tool | Herkunft | Stärke | Relevanz ARK |
|------|----------|--------|--------------|
| **Bexio** | CH | KMU-Standard CH · Rechnungs-Gen + FIBU + Payroll | Treuhand Kunz nutzt Bexio-Format → Export-Ziel |
| **Abacus** | CH | Enterprise CH-ERP | Payroll-Referenz |
| **Banana Buchhaltung** | CH | Günstig, KMU | Out-of-scope |
| **Lexoffice** | DE | DACH-Standard | UX-Inspiration |
| **Odoo** | BE | Open-Source-ERP | Too-heavy |

**Take-Away:** Eigen-Build rechtfertigt sich durch 3-Seiten-PDF-Layout + Probezeit-Staffel + Commission-Bridge + Activity-Linking zu `fact_process_core` / `fact_mandate` — kein Off-the-Shelf-Tool deckt das ab. Treuhand-Export-Format = Bexio-CSV.

---

## 3. Legal-Framework

### 3.1 Arkadium AGB FEB 2023 (primär)

| § | Regelung | Billing-Impact |
|---|----------|----------------|
| §4 | Honorar-Staffel 21/23/25/27 % nach Jahressalär | `dim_honorar_staffel`-Tabelle + Auto-Satz-Berechnung |
| §4 | Schutzfrist 12 Mt ab letztem Kontakt · 16 Mt bei Auskunfts-Pflicht-Verletzung · weiter verlängert bei Datenspeicher-Verbleib | Schutzfrist-Bonus-Rechnung (invoice_type `bonus_schutzfrist`) · UI-Hinweis Datenspeicher |
| §5 | Mandat-Konditionen **nicht AGB-geregelt**, separat vereinbart | `fact_mandate.payment_terms_days` + `fact_mandate.contract_pdf_path` pro Mandat |
| §7 | Zahlungsziel Best-Effort **30 Tage netto** ab Vertragsabschluss Kandidat | `fact_invoice.due_at` = `contract_date + 30d` bei Best-Effort |
| §7 | **Keine Verzugszins-/Mahngebühr-Klausel** | OR 104 5 % greift, aber muss aktiv eingefordert → vertagt bis AGB-Revision |
| §8 | Kulanz-Refund-Staffel: 100 % vor Start · 50/25/10 % in Probezeit-Monat 1/2/3 · 0 % nach Probezeit | Probezeit-basierte Staffel-Engine · 3-Tage-Meldepflicht-Check |
| §8 | Refund-Ausschluss: Kunde-Gründe · Kunde-Kündigung Probezeit · keine Meldung · nach Probezeit | `dim_refund_denial_reasons` Enum |
| §10 | Gerichtsstand **Zürich** | SchKG-Betreibung Zürich ODER Sitz Schuldner möglich |

### 3.2 Schweizer Recht · Sekundär

| Quelle | Regelung | Billing-Impact |
|--------|----------|----------------|
| **OR Art. 102–109** | Schuldner-Verzug · Mahnung konstitutiv · 5 % Verzugszins default | Mahnungs-State-Machine · automatische Zins-Berechnung (MVP: immer 0) |
| **OR Art. 394–406 / 412–418** | Auftragsrecht / Mäkler-Vertrag | Honorar-Anspruch-Trigger bei "Zustandekommen Beschäftigungsverhältnis" (AGB §4) |
| **OR Art. 127/128 Ziff. 1** | Verjährung 10 Jahre allgemein · 5 Jahre bei Mäkler-Honoraren (Rechtsprechung uneinheitlich für Executive Search) | `limitation_warning_at` Feld (Default: 4 J nach `issued_at`) · 10-Jahres-Archivierung als Safe-Bet |
| **OR Art. 958f** | 10-Jahres-Aufbewahrung Handelsbücher + Belege | PDF-Archiv-Retention 10 J. · Hash-basiert (`pdf_hash_sha256`) |
| **MWSTG Art. 10** | Registrierungspflicht ab CHF 100k (Arkadium registriert, CHE-463.920.799) | UID-Suffix "MWST" auf Rechnung (Art. 26 MWSTG) |
| **MWSTG Art. 25** | Normalsatz 8.1 % (ab 01.01.2024 · AHV-21-Reform) | `dim_mwst_codes.std_81` = 8.10 |
| **MWSTG Art. 26** | Pflicht-Angaben Rechnung | Rendering-Engine Pre-Issue-Validator |
| **MWSTG Art. 35** | Quartals-Abrechnung · 60 Tage nach Quartalsende | v_mwst_quarter-Aggregat · Worker `mwst-quarter-snapshot` |
| **revDSG Art. 6** | Datenminimierung · Verhältnismässigkeit | Blind-Copy Default-An · Kandidaten-Name nur auf Seite 2 |
| **DSGVO Art. 30** | Verarbeitungsverzeichnis | Billing-System im VVT aufgenommen |
| **SchKG Art. 38/67** | Betreibungs-Verfahren | Inkasso-Status-Granularität (`collection_external` · `debt_enforcement_pending` · `payment_order_served` · `legal_objection` · `rights_opening_required`) |
| **SIX Swiss QR-Bill IG v2.3** (ab 22.11.2025) | Structured Address Type S Pflicht | `dim_accounts.legal_street_name`/`legal_house_number`/`legal_post_code`/`legal_town_name`/`iso_country_code` separat NOT NULL |
| **SIX Swiss QR-Bill IG v2.4** (ab 14.11.2026) | Extended Character Sets · strukturierte Adressen für alle Payment-Types | MVP-Go-Live nach 14.11.2026 → direkt v2.4 |

---

## 4. Business-Models · Flow-Architektur

### 4.1 Best-Effort (Erfolgsbasis)

```
fact_process_core.stage = 'placement'
  + fact_candidate_placement.contract_signed_at + start_date + probezeit_months
  ↓ event: invoice_triggered (Worker: billing-draft-generator)
fact_invoice (status=draft, type=erfolg)
  + Auto-Fill aus process_core + Honorar-Staffel aus dim_honorar_staffel
  ↓ Backoffice Review (Positionen, Rabatt, Zahlungsziel, Blind-Copy)
fact_invoice (status=approved) — GF-Approval optional bei Rabatt > 15 %
  ↓ event: invoice_issued
fact_invoice (status=issued, PDF+QR generiert, Email via Outlook-Token versendet)
  ↓ event: invoice_sent → fact_history (activity_type=emailverkehr-rechnung-versand)
fact_invoice (due_at = contract_date + 30d)
  ↓ CAMT.054-Import + Auto-Match
fact_payment → fact_invoice.status = paid
  ↓ event: payment_received (zu Commission-Engine: commission_calculation_triggered)
Garantie-Timer startet (aus fact_candidate_placement.probezeit_end_date)
```

### 4.2 Mandat (Target / Taskforce / Time)

```
fact_mandate.status = 'signed' (mit Mandat-Vertrag · fact_mandate.contract_pdf_path + payment_terms_days · Default 10)
  ↓ event: mandate_signed → akonto_invoice_triggered
fact_invoice (stage_nr=1, type=akonto, alle 3 Stages als Positionen · 2+3 als is_open_posten=true)
  ↓ payment → paid
fact_process_core.stage = 'cv_sent' + shortlist_count ≥ N
  ↓ event: shortlist_reached → zwischen_invoice_triggered
fact_invoice (stage_nr=2, type=zwischen · Stage 1 bezahlt, Stage 2 fällig, Stage 3 open_posten)
  ↓ payment → paid
fact_process_core.stage = 'placement'
  ↓ event: placement_confirmed → schluss_invoice_triggered
fact_invoice (stage_nr=3, type=schluss · Stage 1+2 bezahlt, Stage 3 fällig · **Honorar-Rest** = Total-Honorar − Akonto − Zwischen)
  ↓ payment → paid → Commission-Berechnung (nur bei Schluss-Rechnung)
```

**Time-Mandat:** periodische Rechnung monatlich basiert auf Zeit-Modul v0.1. Stages 1/2 entfallen, stattdessen `type=mandat_time_monthly` mit variablem Betrag aus `fact_zeit_summary` des Vormonats.

### 4.3 Kündigungs-Rechnung Mandat

```
fact_mandate.status = 'terminated_by_client'
  ↓ event: mandate_cancelled → termination_invoice_triggered
fact_invoice (type=kuendigung · Betrag = bereits fakturierte Stages + anteiliger Aufwand für laufende Stage)
  ↓ Verbleibende Stages werden auf fact_invoice.status=cancelled gesetzt
  ↓ Commission bleibt unberührt (kein Placement → keine Provision)
```

### 4.4 Refund (Garantie-Fall)

```
fact_history: candidate_resigned | candidate_dismissed
  + Bedingung: (exit_date - stellenantritt_date) < probezeit_months
  ↓ Router: business_model + denial-reason-check
    ├─ erfolgsbasis + keine denial → Refund-Staffel (Probezeit-basiert):
    │                                 vor Start=100% · M1=50% · M2=25% · M3=10%
    ├─ mandat_*                    → Ersatz-Suche primär (kein Refund-Default, Basis OR 107 Wandlung)
    └─ time                         → keine Aktion (keine Garantie bei Time)
  ↓ 3-Tage-Meldepflicht-Check (kunden_meldung_date vs kandidat_kuendigung_date)
    ├─ > 3 Tage → refund_denied_reason = no_notification_3d → Refund-Anspruch erloschen
    └─ ≤ 3 Tage → fortfahren
  ↓ Refund-Cockpit (GF-Pflicht-Approval)
fact_refund + fact_invoice (type=refund, parent_invoice_id = original)
  ↓ event: refund_issued → Commission-Clawback
fact_commission_ledger (negative Entry, clawed_back_from_ruecklage)
  ↓ Reverse-Payment (amount negativ an Kunde)
```

### 4.5 Mahnwesen (segmentiert pro `dim_accounts.dunning_cadence_profile`)

**Standard-Kunden:**
```
due_at + 0d  → status = overdue (internes Flag, keine Aktion)
due_at + 5d  → Soft-Reminder-Email (optional)
due_at + 15d → Mahnung 1 · dunning_1 · neue Frist + 10d
dunning_1.deadline + 15d (= T+30) → Mahnung 2 · dunning_2 · Ton schärfer
dunning_2.deadline + 15d (= T+45) → Mahnung 3 · dunning_3 · letzte Frist 5d
dunning_3.deadline + 5d (= T+50) → Inkasso-Eskalation (GF-Approval-Pflicht)
```

**Key-Account-Kunden:**
```
due_at + 0d  → status = overdue
due_at + 5d  → Soft-Reminder
due_at + 30d → Mahnung 1
+ 15d (T+45) → Mahnung 2
+ 15d (T+60) → Mahnung 3
+ 5d (T+65)  → Inkasso (GF)
```

### 4.6 Honorarstreit

```
manuell: fact_invoice.status = disputed (z.B. Kunde-Reklamation via Email/Call)
  ↓ Mahnungs-Timer pausiert
  ↓ fact_history: dispute_opened · GF-Eskalation-Task
  ↓ Resolution-Optionen:
     (a) paid-full → status = paid
     (b) Teil-Gutschrift + neue Invoice → status = credited, new Invoice issued
     (c) Storno komplett → status = cancelled
     (d) Inkasso wenn unbegründet → status = dunning_3 → inkasso
```

### 4.7 Gutschrift / Storno (strikt getrennt)

| Typ | Wirkung | Schema |
|-----|---------|--------|
| **Storno** | Falscher Beleg neutralisiert, meist mit Neu-Erstellung | `fact_credit_note` mit `amount = -invoice.amount_gross` + `linked_new_invoice_id` |
| **Gutschrift** | Betrag reduziert oder verrechnet | `fact_credit_note` mit Teil-Betrag |
| **Refund** | Geld fliesst zurück an Kunde | `fact_refund` + neue `fact_invoice type=refund` |

### 4.8 MwSt-Quartals-Abrechnung

```
Worker mwst-quarter-snapshot (Cron: 1. Tag nach Quartalsende)
  ↓ aggregiert v_mwst_quarter (alle issued/paid/credited Invoices)
  ↓ generiert MwSt-Report (PDF + CSV) gemäss ESTV-SuisseTax-Format
  ↓ Review Backoffice + GF-Approval
  ↓ Einreichung + Zahlung innerhalb 60d nach Quartalsende
```

---

## 5. Rechnungs-Template-Layout (3-Seiten-PDF)

### 5.1 Seite 1 — Anschreiben

- **Header:** Arkadium-Logo + "FUTURE BUILT ON POTENTIAL" + UID "CHE-463.920.799 MWST" + Rechnungs-Nr (FN{YYYY}.{MM}.{####})
- **Empfänger:** Kunde-Firma + z.Hd. Kontakt + **strukturierte Adresse** (Type S · Strasse + Hausnr + PLZ + Ort + ISO-Country)
- **Titel:** "RECHNUNG" / "MAHNUNG" / "RÜCKERSTATTUNG" (aus `fact_invoice.invoice_type`)
- **Anschreiben-Text:** Template mit Variablen `{{anrede_pronomen}}` / `{{anrede_verb}}` (Sie/Du-Form aus `dim_accounts.tone_of_voice`)
- **Datum + Signaturen:** Founder (Nenad Stoparanovic) + Bereichs-Head (z.B. PW Head CE&BT, JV Stv. CE&BT, YB Head ARC&REM) · als PNG-Einbettung aus `dim_mitarbeiter.digital_signature_img`
- **Footer:** Kontakt + Social-Links

### 5.2 Seite 2 — Rechnungs-Tabelle (mit Kandidaten-Details)

- **Kandidat + Startdatum + Funktion** (Best-Effort) ODER **Zahlung + Zahlungsgrund + Funktion** (Mandat)
- **Bereich (Sparten-Code aus `dim_sparten`) + Dienstleistung + Form**
- **Beschreibungs-Tabelle** mit Preis-Spalten (CHF exkl. MwSt)
- **Summe + MwSt 8.1 % + Rechnungsbetrag** (Rundung auf 5 Rappen)
- **Zahlungsziel fett** (T+30 Best-Effort / T+X Mandat · aus `fact_invoice.due_at`)
- **Zahlungsverbindung** (Konto-Info IBAN CH07 0077 7009 0644 7451 4)

### 5.3 Seite 3 — Blind-Copy + Swiss QR-Bill

- **Identisch Seite 2** aber Kandidaten-Klarname ersetzt durch **"Kandidat (Diskretions-Kopie)"** (DSG-konform · Blind-Copy = immer an, kein Opt-Out)
- **Swiss QR-Bill (SIX v2.4):** Empfangsschein + Zahlteil exakt 210×105 mm · QR-Code mit eingebettetem Betrag + SCOR/QRR-Referenz
- **Perforations-Trennlinie** sichtbar · Druck-Kompatibilität SIX-Standard

### 5.4 Template-Versionierung

- `fact_template_versions` (aus Admin-Vollansicht v0.1 · Tab 3)
- `fact_invoice.template_version` speichert verwendete Version bei Issue
- **AGB-Revision** → neue Template-Version · alte Rechnungen bleiben mit historischer AGB-Referenz reproduzierbar

---

## 6. Datenmodell · Entitäten-Übersicht (High-Level)

*Detail-DDL in `ARK_BILLING_SCHEMA_v0_1.md`*

### 6.1 Neue Dim-Tabellen (Stammdaten)

| Tabelle | Zweck | Besonderheit |
|---------|-------|--------------|
| `dim_invoice_types` | Rechnungs-Typen-Katalog | 11 Codes (akonto/zwischen/schluss/erfolg/kuendigung/optionale_stage/refund/storno/gutschrift/bonus_schutzfrist/mahngebuehr) |
| `dim_invoice_status` | Status-Enum | 14 Codes (draft/approved/issued/partial/paid/overdue/dunning_1-3/disputed/gestundet/cancelled/refunded/written_off/collection_external/debt_enforcement_pending/payment_order_served/legal_objection) |
| `dim_honorar_staffel` | AGB §4 Best-Effort-Honorar-Staffel | Versionierbar pro AGB-Version (21/23/25/27 %) |
| `dim_refund_reason_codes` | Refund-Grund-Codes (Garantie-Fall) | Routing auf business_model + Staffel-% (vor_start/m1/m2/m3) |
| `dim_refund_denial_reasons` | Ausschluss-Gründe AGB §8 | 5 Codes (customer_caused_no_start/customer_terminated_during_probation/after_probation_exit/no_notification_3d/no_cause_reported) |
| `dim_mwst_codes` | MwSt-Sätze + Tax-Treatment | std_81 · red_26 · rc_0 · exempt |
| `dim_payment_methods` | Zahlungsmittel-Enum | qr · bank_transfer · credit_card · twint_business · compensation |
| `dim_dunning_reasons` | Mahn-Gründe | late_payment · partial_payment |
| `dim_credit_note_reasons` | Gutschrift-Gründe | error_billing · error_customer · kulanz · dispute_resolved · vat_correction |

### 6.2 Neue Fact-Tabellen (Transaktional)

| Tabelle | Zweck | FK-Hub |
|---------|-------|--------|
| `fact_invoice` | Rechnungs-Header | customer_id · process_id · mandate_id · parent_invoice_id |
| `fact_invoice_item` | Rechnungs-Positionen | invoice_id (on cascade) · candidate_id · sparte_code |
| `fact_payment` | Zahlungseingänge | invoice_id · reversal_of (für Storno-Zahlung) |
| `fact_dunning` | Mahn-Historie | invoice_id · level 1–3 · unique(invoice_id, level) |
| `fact_credit_note` | Gutschriften | invoice_id · linked_new_invoice_id |
| `fact_refund` | Rückerstattungen (Garantie-Fall) | original_invoice_id · refund_invoice_id · reason_process_id |
| `fact_inkasso` | Inkasso-Übergaben | invoice_id · partner_name |
| `fact_invoice_audit` | Event-Audit (append-only) | invoice_id (on cascade) · actor_user_id |

### 6.3 Erweiterungen bestehender Tabellen

| Tabelle | Neue Felder | Grund |
|---------|-------------|-------|
| `dim_accounts` | `legal_street_name` · `legal_house_number` · `legal_post_code` · `legal_town_name` · `iso_country_code` · `tone_of_voice` (sie/du) · `dunning_cadence_profile` (key_account/standard) · `privacy_mode` (full_name/initials/blind_copy_only/internal_reference_only · Default blind_copy_only) · `debtor_contact_id` FK | SIX Type-S-Compliance · Mahn-Segmentierung · Blind-Copy-Granularität |
| `fact_mandate` | `payment_terms_days` (Default 10) · `contract_pdf_path` · `stage_amounts_jsonb` · `guarantee_start_policy` (Default `stellenantritt`) | AGB §5 Mandat separat · Stage-Beträge pro Mandat |
| `fact_candidate_placement` | `probezeit_months` (Default 3, Range 1–6) · `probezeit_end_date` (Generated) | AGB §8 Probezeit-basierte Refund-Staffel |
| `dim_mitarbeiter` | `digital_signature_img` (PNG/SVG Pfad oder Blob) · `department_code` (CE&BT / ARC&REM / MS&CS) | PDF-Anschreiben Signatur-Einbettung |

### 6.4 Views

- `v_invoice_open` — alle nicht-bezahlten mit Aging-Buckets
- `v_invoice_dunning_queue` — pending Mahnstufen nach Kadenz-Profil
- `v_mwst_quarter` — Quartals-Aggregat für ESTV-Report
- `v_customer_ledger` — Debitoren-Konto pro Kunde
- `v_refund_clawback` — offene Commission-Clawbacks

---

## 7. Rollen-Matrix

| Feature | AM | CM | Researcher | Backoffice | Head/GF | Treuhand (RO) | Admin |
|---------|----|----|------------|------------|---------|---------------|-------|
| Rechnung Draft erstellen | – | – | – | ✓ | ✓ | – | – |
| Rechnung Approved → Issued | – | – | – | – | ✓ | – | – |
| Mahnung Stufe 1 auslösen | – | – | – | ✓ | ✓ | – | – |
| Mahnung Stufe 2/3 | – | – | – | ✓ | ✓ | – | – |
| Gutschrift ausstellen | – | – | – | – | **✓ (immer GF)** | – | – |
| Storno | – | – | – | – | **✓ (immer GF)** | – | – |
| Refund ausstellen | – | – | – | – | **✓ (immer GF)** | – | – |
| Inkasso-Übergabe | – | – | – | – | **✓ (immer GF)** | – | – |
| Stage-4-Sonder-Rechnung | – | – | – | – | **✓ (immer GF)** | – | – |
| Rechnungs-Liste sehen | ✓ | ✓ | – | ✓ | ✓ | – | ✓ |
| Eigene Kunden-Zahlungen sehen (Row-Level) | ✓ | ✓ | – | ✓ | ✓ | – | ✓ |
| Bank-Import CAMT.054 | – | – | – | ✓ | ✓ | – | – |
| Zahlung manuell erfassen | – | – | – | ✓ | ✓ | – | – |
| Treuhand-Export generieren | – | – | – | ✓ | ✓ | ✓ (RO) | – |
| MwSt-Abrechnung finalisieren | – | – | – | ✓ | ✓ | ✓ (RO) | – |
| Commission-Clawback auslösen (Auto-Event) | – | – | – | – | ✓ (Review) | – | – |
| Audit-Log einsehen | – | – | – | ✓ | ✓ | ✓ (RO) | ✓ |

**Row-Level-Security (AM/CM):** Nur eigene Kunden via `dim_accounts.owner_am_id` / `owner_cm_id` Filter. Keine Billing-Aktionen — nur Lesezugriff für Commission-Transparenz.

---

## 8. Integrationen

### 8.1 CRM-intern

| Quelle | Ziel | Event |
|--------|------|-------|
| `fact_process_core.stage = placement` | Billing | `invoice_triggered` (Best-Effort Draft) |
| `fact_mandate.status = signed` | Billing | `akonto_invoice_triggered` |
| `fact_process_core.stage = cv_sent + N Candidates` | Billing | `zwischen_invoice_triggered` |
| Billing · `payment_received` | Commission-Engine | `commission_calculation_triggered` |
| Billing · `refund_issued` | Commission-Engine | `commission_clawback_triggered` |
| Billing · `invoice_overdue` | Reminders-Vollansicht | Reminder-Row für AM + Backoffice |
| `fact_history: candidate_resigned` (in Probezeit) | Billing | `refund_eligibility_check` |

### 8.2 Email (Outlook via MS Graph · individual tokens)

- Rechnungs-PDF-Versand via Outlook-Token des versendenden **Backoffice-MA** (Architektur-Entscheid 2026-04-17 · individual tokens, **nicht** Shared Mailbox)
- Template-basiert aus `dim_email_templates` (Email-Kalender-Modul)
- Empfänger: `fact_invoice.debtor_contact_email` aus `dim_accounts.debtor_contact_id`
- Logging: `fact_history` (entity=invoice, activity_type=emailverkehr-rechnung-versand) + `message_id` · `sent_at` · `delivery_status`

### 8.3 QR-Bill-Library

- **Empfehlung:** `swissqrbill` (NPM · `schoero/swissqrbill`) (TypeScript, Node, SSR-tauglich, SIX-zertifiziert)
- **Version-Check vor Commit:** GitHub-Releases für IG v2.3/v2.4-Support prüfen
- **Fallback:** `manuelbl/swiss-qr-bill` (Java)

### 8.4 Bank-Integration (MVP)

- **CAMT.054-XML Import** (manueller Upload durch Backoffice, täglich)
- **CSV-Fallback** falls CAMT-Parsing fehlschlägt
- **EBICS-API** vertagt Phase 2 (> 500 Rechnungen/Mt als Trigger)

### 8.5 Treuhand Kunz (Export)

- Referenz: `reference_treuhand_kunz.md` · office@treuhand-kunz.ch
- **Monatlicher Export** (1. Tag jedes Monats): Rechnungs-Journal + Zahlungen + Gutschriften + Refunds + Debitoren-Saldo
- **Format:** Bexio-CSV (kompatibel zum Bexio-Rechnungs-Import-Format)
- **Kontierung:** Ertragskonto 3400 (Dienstleistungserlöse) · Refund-Aufwandskonto TBD

### 8.6 Bexio (optional, vertagt)

- Nicht MVP (siehe Q4 pending · System-of-Record-Entscheid)

### 8.7 Reminders-Vollansicht

- Rechnungs-fällige / Mahn-Trigger-Reminders automatisch via `fact_reminders`
- Zielgruppe: Backoffice + AM (Row-Level-Filter)

### 8.8 Commission-Engine

- Siehe `specs/ARK_COMMISSION_ENGINE_SPEC_v0_1.md`
- Events: `invoice_paid` · `invoice_partially_paid` · `refund_issued` · `refund_paid` · `invoice_written_off`
- Trigger: nur `invoice_paid` mit `business_model = erfolgsbasis` ODER `stage_nr = 3` bei Mandat → Commission-Berechnung
- Clawback: bei `refund_issued` → Rücklage-Reduktion oder negative Position in nächster MA-Abrechnung

---

## 9. Phasen-Plan

### Phase 3.B.1 — Core · Best-Effort · MVP (höchste Priorität)

**Deliverables:**
- `dim_honorar_staffel` seeded (AGB FEB 2023 · Version `agb-feb-2023`)
- `dim_invoice_types` + `dim_invoice_status` + `dim_mwst_codes` seeded
- `fact_invoice` + `fact_invoice_item` + `fact_invoice_audit` Tabellen
- `dim_accounts` Adress-Struktur-Felder Migration (Regex-Parser für Bestandskunden)
- Rechnungs-Editor-Drawer (540px · Multi-Step: Kunde → Process → Positionen → MwSt → QR-Preview → Issue)
- Honorar-Staffel-Auto-Berechnung bei Salär-Eingabe
- PDF-Generator (3 Seiten · Blind-Copy Default-An · Du/Sie-Template-Baustein-Renderer)
- QR-Bill-Library-Integration (schoero/swiss-qr-bill v2.4 · SCOR-Fallback bis QR-IBAN)
- Pre-Issue-Validator (Type-S-Compliance · MwSt-Pflicht-Angaben · Betrags-Konsistenz)
- Rechnungs-Liste + Debitoren-Ansicht pro Kunde
- Email-Versand via Outlook-Token
- Approval-Flow (Draft → Approved → Issued, GF bei Rabatt > 15 % optional)
- 10-Jahres-Archivierung mit SHA-256-Hash

**Akzeptanz-Kriterien:**
- 1 Test-Rechnung für `Emch+Berger Gruppe` (wie PDF-Template) generierbar
- QR-Code scannbar via Swiss-Banking-App
- PDF-Hash reproduzierbar
- Multi-Role-Approval funktional

### Phase 3.B.2 — Mandat-Flow · 3-Stage-Akonto/Zwischen/Schluss

**Deliverables:**
- `fact_mandate` Erweiterung (payment_terms_days · contract_pdf_path · stage_amounts_jsonb · guarantee_start_policy)
- Mandat-Stage-Logik: alle 3 Stages auf jeder Stage-Rechnung (is_open_posten=true für nicht-fällige)
- Auto-Draft bei mandate_signed (Akonto) / shortlist_reached (Zwischen) / placement_confirmed (Schluss)
- Mandat-Stage-Trigger-Drawer (Backoffice-UI zur manuellen Auslösung)
- Kündigungs-Rechnung-Template (`type=kuendigung`)
- Optionale-Stage-Template (`type=optionale_stage` · GF-Approval-Pflicht)

### Phase 3.B.3 — Mahnwesen · Segmentierte Kadenz

**Deliverables:**
- `fact_dunning` Tabelle
- `dim_accounts.dunning_cadence_profile` Migration (Default standard)
- Worker `dunning-cadence-check` (daily cron · 06:00)
- Mahnwesen-Cockpit-Screen
- Mahn-PDF-Templates (3 Stufen · Ton schärfer pro Stufe · Du/Sie-Varianten)
- Bulk-Mahn-Versand (Preview-Modal vor Send)
- Mahnungs-Pause bei disputed-Status
- Verzugszins-Felder vorbereitet (MVP: fee=0, interest_amount=0)

### Phase 3.B.4 — Refund-Cockpit · Garantie-Staffel

**Deliverables:**
- `fact_refund` + `dim_refund_reason_codes` + `dim_refund_denial_reasons` Tabellen
- `fact_candidate_placement.probezeit_months` + `probezeit_end_date` Migration
- Refund-Cockpit-Screen (Filter: Garantie läuft in ≤ 14d · offene Garantie-Fälle)
- Refund-Berechnung-Drawer (Probezeit-basierte Staffel-Preview · GF-Approval)
- 3-Tage-Meldepflicht-Check
- Refund-Denial-Flow (manuelle Grund-Eingabe · Audit-Trail)
- Commission-Clawback-Event-Trigger (zu Commission-Engine)

### Phase 3.B.5 — Bank-Reconciliation · CAMT.054-Import

**Deliverables:**
- `fact_payment` Tabelle
- CAMT.054-XML-Parser (Worker `bank-statement-import`)
- Zahlungseingang-Screen mit Auto-Match-Queue
- Match-Priorität: QRR/SCOR-Referenz → Amount+IBAN → Fuzzy → Manuell
- `matched_confidence` numerisch
- Zahlung-Erfassen-Drawer (manueller Fallback)
- Teilzahlungs-Handling (status=partial auf Rest)

### Phase 3.B.6 — MwSt-Quartalsabrechnung + Treuhand-Export

**Deliverables:**
- `v_mwst_quarter` View
- Worker `mwst-quarter-snapshot` (1. Tag nach Quartalsende)
- MwSt-Abrechnung-Screen (ESTV-konformer Report)
- Treuhand-Kunz-Export (Bexio-CSV, monatlich)
- Export-Status-Tracking (`dim_accounts.export_status_treuhand`)
- Lock-Mechanismus nach Quartalsabschluss

### Phase 3.B.7 — Gutschrift / Storno / Dispute-Handling

**Deliverables:**
- `fact_credit_note` Tabelle
- Gutschrift-Erstellen-Drawer (Rechnung auswählen + Grund + Betrag + GF-Approval-Pflicht)
- Storno-Flow (Doppel-Confirm + 10s Undo-Toast)
- Dispute-Status + Mahnungs-Pause
- Link-zu-neuer-Invoice bei Storno+Neu-Erstellung

### Phase 3.B.8 — Optional: Inkasso-Übergabe · SchKG-Ready

**Deliverables:**
- `fact_inkasso` Tabelle
- Inkasso-Status-Granularität (collection_external · debt_enforcement_pending · payment_order_served · legal_objection · rights_opening_required)
- Inkasso-Dossier-Export (Vertrag + AGB + Rechnung + Mahnungen + Korrespondenz als ZIP)
- Inkasso-Partner-Stammdaten (konfigurierbar pro Fall · Memory-Flag Q3 PO-Review · Peter klärt)

### Phase 3.B.9 — Optional: Schutzfrist-Bonus · §6 AGB

**Deliverables:**
- `invoice_type=bonus_schutzfrist` Code
- Ad-hoc-Erstellung via generisches Rechnungs-Template + manueller Anschreiben-Text
- UI-Hinweis im Schutzfrist-Tab (Datenspeicher-Verlängerung)
- Kein dediziertes PDF-Template in MVP (selten · < 1× pro Jahr)

### Phase 3.B.X — Vertagt (nicht MVP)

- EU-Kunden-Fakturierung (Reverse-Charge · Feature-Flag `feature_eu_invoicing`)
- Multi-Währung (EUR/USD)
- Verzugszins-/Mahngebühr-Berechnung (nach AGB-Revision)
- EBICS-API-Integration
- Bidirektionale Bexio-Sync
- TWINT Business / Stripe-Integration
- Skonto-Engine
- Automatische Inkasso-Partner-Übergabe

---

## 10. Migration

### 10.1 Pre-Go-Live-Tasks

| Task | Owner | Deadline |
|------|-------|----------|
| Bestandskunden-Adress-Migration (Type S · Regex-Parser "Maneggstrasse 45" → `street_name="Maneggstrasse"` + `house_number="45"`) | Backoffice + Script | Vor Phase 3.B.1 |
| ISO-Country-Code-Pflege (immer 'CH' in MVP, aber Feld Pflicht) | Script | Vor Phase 3.B.1 |
| Honorar-Staffel-Seed (AGB FEB 2023 · 4 Bänder) | Admin-Seed | Phase 3.B.1 |
| QR-IBAN-Beschaffung Kantonalbank | Peter | Bis Phase 3.B.5 Go-Live (Fallback: SCOR bis dahin) |
| Signatur-PNG-Upload für Nenad + alle Heads | HR-Tool + Admin | Vor Phase 3.B.1 |
| Template-Version "agb-feb-2023" seeded in `fact_template_versions` | Admin-Seed | Phase 3.B.1 |
| Mandat-Vertrags-PDFs nachgeliefert (für Bestands-Mandate mit `contract_pdf_path=NULL`) | Backoffice | Vor Phase 3.B.2 |
| Probezeit-Dauer nachgepflegt in `fact_candidate_placement.probezeit_months` für aktive Placements | Backoffice | Vor Phase 3.B.4 |
| Rolle `head_of_department` + Signer-Rules in `dim_mitarbeiter` | HR-Tool-Bridge | Phase 3.B.1 |

### 10.2 Daten-Import (falls Altrechnungen digitalisiert werden)

- Excel-Sheets `Rechnungssheet_Best Effort.xlsx` / `Rechnungssheet_Mandat.xlsx` / `Rechnungssheet_S. Burri.xlsx` als Migration-Quelle
- Ziel: `fact_invoice` mit `source='migration_excel'` · keine PDFs nachgeneriert, nur Meta-Daten
- Status `paid` für alle Altrechnungen (default, manuelle Korrektur wenn offen)
- **Entscheidung pending** (Q in Batch 4?): alle Altrechnungen importieren oder Start-bei-Null?

---

## 11. Offene Fragen (TBC · vor Schema v0.1 klären)

| # | Frage | Status |
|---|-------|--------|
| **Q4** | System of Record Billing vs. Bexio | **offen** · Peter klärt mit GF Nenad |
| **Q11** | Team-Wechsel-Commission mid-Mandat (AM-1 → AM-2) | **offen** · Arbeits-/Provisionsvertrag (`Praemium Victoria`) nicht im Worktree · Peter lädt nach oder gibt mündlich an |
| **Q16** (neu) | Altrechnungen-Migration: Import aus Excel-Sheets ODER Start-bei-Null für Phase 3.B? | **offen** |
| **Q17** (neu) | Rabatt-Freigabe-Schwelle: Backoffice darf Rabatt bis X %? Default-Vorschlag 15 % · darüber GF-Pflicht | **offen** |
| **Q18** (neu) | Mandat-Stage-Betrag bei Time-Mandat: monatlich aus Zeit-Modul direkt oder manuelles Schluss-Aggregat? | **offen** |
| **Q19** (neu) | Assessment-Rechnung (kein Best-Effort/Mandat) — separater Flow oder Unter-Typ Best-Effort? (Vorlage `Vorlage_Rechnung_Diagnostics & Assessment.pdf` existiert) | **offen** |

---

## 12. Risiken & Grauzonen

### 12.1 Regulatorisch

- **SIX-Update 22.11.2025 · Type-S-Compliance** — Nicht-Konformität = Bank-Reject. MVP muss Type-S ab Start unterstützen, Bestandsadressen migriert.
- **5J-Verjährung Mäkler-Honorare** (OR 128 Ziff. 1 vs. 10J allgemein) — Rechtsprechung uneinheitlich für Executive Search. Sicherheits-Strategie: 10J Archivierung + Warnung bei 4J offenen Forderungen.
- **Reverse-Charge EU** bei Phase-2-Rollout — Feature-Flag vorbereitet, Logik aber nicht MVP.
- **MwSt-Registrierungspflicht CHF 100k** — Arkadium registriert, kein Risiko bei laufenden Umsätzen > 100k.

### 12.2 Datenschutz

- **Kandidaten-Name auf Seite 1 + 2** rechtlich zulässig (berechtigtes Interesse), aber Blind-Copy-Pflicht auf Seite 3 strikt DSG-konform.
- **Email-Empfänger "Buchhaltung@Kunde"** — Verarbeitungsverzeichnis-Eintrag nötig.
- **10J-Archivierung** vs. revDSG-Löschrecht — OR 958f überwiegt für Handelsdokumente, automatische Löschung nach Jahr 10.
- **AGB §9 Kunden-Löschpflicht 12 Mt** — technisch schwer auditierbar, Arkadium verlangt aber im UI-Hinweis der Schutzfrist darauf.

### 12.3 Concurrency & Datenintegrität

- **Rechnungsnummer-Kollision** bei paralleler Draft-Erstellung → PostgreSQL-Sequence `seq_invoice_yyyy` mit advisory-lock, nie Frontend-vergebene Nr.
- **CAMT-Import-Race** bei N parallelen Zahlungen → Transaktions-Isolation SERIALIZABLE für Match-Worker.
- **Saga-Atomarität** Refund-Issuance + Commission-Clawback → Saga-Pattern mit Compensation (Backend-Arch §Sagas).

### 12.4 Commission-Clawback

- **Rücklage 20 % könnte nicht reichen** bei > 3 Garantie-Fällen pro MA/Jahr → Clawback-Cap (max. 6 Monatslöhne) notwendig. Arbeitsrechtlich heikel (Lohn-Rückforderung MA). Bei Überschreitung Abschreibung zu Lasten Arkadium-Holding.
- **Quartals-Payout (Jan/Apr/Jul/Okt)** schützt Liquidität, aber Rücklage bleibt trotzdem exponiert → Commission-Retention-Variante (100 % bis Garantie-Ende) als Notfall-Fallback dokumentieren.

### 12.5 UX-Risiken

- **Storno unumkehrbar** — User-Fehler-Risiko → Doppel-Confirm + 10s Undo-Toast.
- **Bulk-Mahnung** an disputed/gestundete Invoices → Filter aktiv + Pre-Send-Preview mit Count.
- **Blind-Copy-Vergessen** (falls Opt-Out später eingeführt) → Default-An + Warn-Modal bei OFF.
- **Debitor vs. Kreditor** — Terminology-Rename in allen UIs (Q14-Decision) — Friction für Arkadium-Team in Übergangsphase.

### 12.6 Template-Management

- **Template-Versionierung** (`fact_template_versions`) — alte Rechnungen mit historischer Version reproduzierbar · AGB-Änderungen erhalten alte Template-Version.
- **AGB-Referenz in Anschreiben** — "Ziffer 8 AGB FEB 2023" bleibt bei AGB-Update · Rechnungen halten Template-Version zur Rechnungs-Zeit.

### 12.7 Liquiditäts-Forecasting

- **Akonto-Stages Mandat** → Dashboard soll Forecast zeigen (Pipeline offener Akontos nächste 30/60/90d)
- **Schluss-Rechnung verzögert** bei langen Target-Mandaten (6+ Mt) → Working-Capital-Belastung · optional Zwischen-Rechnung als Hebel

### 12.8 Abhängigkeit Commission-Engine

- Commission-Engine-Spec v0.1 muss vor Billing-Schema v0.1 finalisiert sein, damit Event-Schnittstelle sauber definiert (invoice_paid / refund_issued / invoice_partially_paid).
- Keine Billing-Schema-Änderung ohne Commission-Engine-Sync.

---

## 13. Decisions-Referenz

Alle bindenden Entscheidungen in [wiki/meta/decisions.md](../../wiki/meta/decisions.md) · relevante Abschnitte:

- **[2026-04-20] Billing-Modul v0.1 · PO-Entscheide Batch 1** — Commission-Retention 80/20 · Garantie-Start = Stellenantritt · Refund-Staffel 100/50/25/10 · Mahn-Kadenz segmentiert
- **[2026-04-20] Billing-Modul v0.1 · PO-Entscheide Batch 2** — QR-IBAN pending · Mahngebühr vertagt · GF-Approval-Pflicht alle kritischen Aktionen · EU-Out-of-Scope · CHF-only MVP
- **[2026-04-20] Billing-Modul v0.1 · PO-Entscheide Batch 3** — Team-Wechsel TBC · Schutzfrist-Bonus selten · Mandat-Zahlungsziel 10d Default · Debitoren-Rename · Blind-Copy immer an · Anrede-Template-Baustein
- **[2026-04-20] SIX Swiss QR-Bill v2.3 · 22.11.2025 Fact-Check** — IG v2.3 ab 22.11.2025 · IG v2.4 ab 14.11.2026 · Type-S-Adressen Pflicht
- **[2026-04-20] Billing-Modul · AGB FEB 2023 Volltext-Review** — Honorar-Staffel 21/23/25/27 % · Refund-Probezeit-basiert (nicht Kalender-Monat) · Refund-Ausschluss-Gründe · 3-Tage-Meldepflicht · Mandat-Konditionen pro Vertrag · Schutzfrist-Verlängerung Datenspeicher

---

## 14. Next

### 14.1 Sofort

1. **PO-Entscheide Q16–Q19** (Altrechnungen-Migration · Rabatt-Schwelle · Time-Mandat-Monatsrechnung · Assessment-Rechnungs-Flow)
2. **Q4 + Q11 Peter-Klärung** (parallel, nicht-Blocker für Schema v0.1 wenn mit TBC-Platzhaltern akzeptiert)
3. **Commission-Engine-Spec v0.1 Review** — Event-Schnittstelle validieren vor Schema v0.1 Commit
4. **QR-Library-Version-Check** — schoero/swiss-qr-bill v2.4-Support GitHub-Releases

### 14.2 Folge-Specs

1. **`ARK_BILLING_SCHEMA_v0_1.md`** — Komplette DDL für alle Tabellen + Views + Constraints + Indexe + Migrations-SQL
2. **`ARK_BILLING_INTERACTIONS_v0_1.md`** — UI-Flows · Drawer-Spezifikation · Screen-Wireframes-Referenzen · Event-Details · Worker-Definitionen

### 14.3 Mockup-Phase (nach Spec-v0.1-Fertigstellung)

- Mockup-First vs. Spec-First: Phase-3-ERP = **Spec-First** (per `feedback_mockup_first_workflow.md`)
- Mockups nach Spec-v0.1-OK: `mockups/ERP Tools/billing-*.html`
- Screens: `billing-dashboard.html` · `billing-rechnungen.html` · `billing-mahnwesen.html` · `billing-refund-cockpit.html` · `billing-zahlungen.html` · `billing-mwst.html` · `billing-kreditor-debitor.html`

### 14.4 Grundlagen-Sync (nach Spec-v0.1-Freeze)

- `ARK_STAMMDATEN_EXPORT_v1_4` → v1.5 (§91 Billing-Stammdaten)
- `ARK_DATABASE_SCHEMA_v1_4` → v1.5 (alle Billing-Tabellen + Erweiterungen)
- `ARK_BACKEND_ARCHITECTURE_v2_6` → v2.7 (Billing-Events · Worker · Sagas · Endpoints)
- `ARK_FRONTEND_FREEZE_v1_11` → v1.12 (Billing-Routen · UI-Patterns)
- `ARK_GESAMTSYSTEM_UEBERSICHT_v1_3.6` → v1.4 (Changelog-Eintrag)

---

**Status v0.1 · Draft · Review-Ready für PO-Sign-Off.**
