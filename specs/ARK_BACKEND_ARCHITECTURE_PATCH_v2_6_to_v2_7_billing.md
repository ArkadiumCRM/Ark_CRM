---
title: "ARK Backend-Architecture · Patch v2.6 → v2.7 · Billing-Modul"
type: patch
phase: 3
created: 2026-04-20
updated: 2026-04-20
status: draft
depends_on: [
  "specs/ARK_BILLING_INTERACTIONS_v0_1.md (authoritative Event/Worker/Endpoint source)",
  "specs/ARK_COMMISSION_ENGINE_SPEC_v0_1.md (Commission-Integration · 2026-04-20-Patches)"
]
target: "raw/Ark_CRM_v2/ARK_BACKEND_ARCHITECTURE_v2_6.md → v2.7 (neuer Abschnitt M. Billing-Modul)"
tags: [patch, backend, architecture, billing, phase-3, events, worker, saga]
---

# Backend-Architecture-Patch v2.6 → v2.7 · Billing-Modul

**Status:** Draft · anzuwenden nach Peter-Freigabe Billing-Spec v0.1 Freeze.

Neuer Abschnitt **M. Billing-Modul** (analog §Zeit-Modul v2.6).

---

## M. Billing-Modul · Events · Worker · Sagas · Endpoints

### M.1 Neue Event-Typen (26)

| Event-Code | Trigger-Quelle | Payload-Schema | Subscriber |
|------------|----------------|----------------|------------|
| `invoice_triggered` | `fact_process_core.stage = placement` | `{process_id, business_model}` | Worker `billing-draft-generator` |
| `akonto_invoice_triggered` | `fact_mandate.status = signed` | `{mandate_id}` | Worker `billing-draft-generator` |
| `zwischen_invoice_triggered` | Shortlist-Start (N CVs) | `{mandate_id, process_id}` | Worker `billing-draft-generator` |
| `schluss_invoice_triggered` | Mandat-Prozess Placement | `{mandate_id, process_id}` | Worker `billing-draft-generator` |
| `termination_invoice_triggered` | `fact_mandate.status = terminated_by_client` | `{mandate_id}` | Worker `billing-draft-generator` |
| `invoice_triggered_assessment` | `fact_assessment_order.status = delivered` | `{assessment_order_id}` | Worker `billing-draft-generator` |
| `invoice_triggered_time_monthly` | Cron (1. Tag Folgemonat) | `{mandate_id, month, year, weekly_fee, weeks_in_month}` | Worker `time-mandate-monthly-invoice` |
| `invoice_approved` | UI-Action | `{invoice_id, approved_by}` | Audit |
| `invoice_issued` | UI-Action | `{invoice_id}` | Worker `billing-pdf-generator` + `billing-email-sender` |
| `invoice_sent` | Email versendet | `{invoice_id, email_message_id}` | Audit · `fact_history` |
| `invoice_overdue` | Daily-Worker `dunning-cadence-check` | `{invoice_id, days_overdue}` | Reminders-Vollansicht |
| `dunning_sent` | Mahnung versendet | `{invoice_id, level, dunning_id}` | Audit |
| `invoice_disputed` | UI-Action | `{invoice_id, reason}` | Mahnungs-Timer-Pause |
| `payment_received` | `fact_payment` INSERT | `{invoice_id, payment_id, amount}` | Worker `commission-engine-bridge` |
| `invoice_partially_paid` | Teilzahlung | `{invoice_id, amount_paid, amount_open}` | Audit + Commission-Engine |
| `invoice_paid` | `amount_paid >= amount_gross` | `{invoice_id}` | Commission-Engine · Garantie-Timer-Start |
| `refund_eligibility_check` | `fact_history: candidate_resigned/dismissed` | `{placement_id, exit_date, exit_reason}` | Refund-Cockpit-Notification |
| `refund_issued` | GF-Approval + Issue | `{refund_id, original_invoice_id, amount}` | Commission-Engine-Clawback |
| `refund_paid` | Pain.001-Ausführung | `{refund_id, valuta_date}` | Audit |
| `credit_note_issued` | GF-Approval | `{credit_note_id, invoice_id, amount}` | Audit |
| `invoice_cancelled` | Storno | `{invoice_id, reason}` | Commission-Clawback |
| `invoice_written_off` | Nach Inkasso-Fail | `{invoice_id}` | Audit · Buchhaltung |
| `inkasso_handed_over` | GF-Approval | `{invoice_id, inkasso_id, partner}` | Audit |
| `commission_clawback_triggered` | aus `refund_issued` / `invoice_cancelled` / `invoice_written_off` | `{invoice_id, placement_id, clawback_amount, reason}` | Commission-Engine (§5.2 in Commission-Spec v0.1) |
| `mwst_quarter_snapshot_generated` | Cron (1. Tag nach Quartal) | `{quarter_start, gross_total}` | Admin-Notification |
| `treuhand_export_generated` | Monatlicher Worker | `{month, year, file_path}` | Email-Notification Treuhand Kunz |
| `migration_import_completed` | Nach Altrechnungen-Import | `{source, count, errors}` | Audit |

### M.2 Neue Worker (11)

**Event-driven (6):**

| Worker | Trigger-Events | Haupt-Logik |
|--------|----------------|-------------|
| `billing-draft-generator` | `invoice_triggered` / `akonto_invoice_triggered` / `zwischen_invoice_triggered` / `schluss_invoice_triggered` / `termination_invoice_triggered` / `invoice_triggered_assessment` | Erstellt `fact_invoice` Draft · Auto-Fill (Kandidat · Honorar-Staffel-Satz · Adresse · Signer · MwSt) · Rabatt aus Process/Mandat übernommen |
| `billing-pdf-generator` | `invoice_issued` / `credit_note_issued` / `refund_issued` / `dunning_sent` | 3-Seiten-PDF-Render (Anschreiben/Tabelle/Blind-Copy+QR) · SHA-256-Hash · `pdf_path` + `pdf_hash_sha256` |
| `billing-email-sender` | `invoice_issued` / `dunning_sent` | Versand via MS Graph mit Outlook-Token des `issued_by`-Backoffice-MA (individual tokens per Architektur-Entscheid 2026-04-17) |
| `commission-engine-bridge` | `payment_received` / `invoice_paid` / `invoice_partially_paid` / `refund_issued` / `invoice_cancelled` / `invoice_written_off` | Queued Events in `fact_commission_event_queue` · ruft Commission-Engine §4.1 Stufe-2-Promotion auf |
| `qr-bill-validator` | synchron pre-Issue | Type-S-Adress-Compliance · MwSt-Pflicht-Angaben · Betrag · Signer · QR-IBAN-Konsistenz |
| `migration-excel-pdf-import` | einmalig manuell | Liest Excel-Sheets + PDFs aus `raw/General/1_ Rechnungen & -sheets/` · `fact_invoice` mit `source='migration_excel'` |

**Cron (5):**

| Worker | Schedule | Funktion |
|--------|----------|----------|
| `dunning-cadence-check` | Daily 06:00 | Iteriert `v_invoice_dunning_queue` · `next_dunning_level_due` NOT NULL → Reminder-Row für Backoffice |
| `time-mandate-monthly-invoice` | Monthly 1. Tag 06:00 | Aktive Time-Mandate · Wochen im Vormonat (pro rata) · Draft-Invoice |
| `bank-statement-import` | Daily 07:00 (manueller Trigger) | CAMT.054-Parse · Auto-Match QRR/SCOR/Amount/Fuzzy · `fact_payment` INSERT |
| `mwst-quarter-snapshot` | 1. Tag nach Quartalsende | Aggregat `v_mwst_quarter` · ESTV-Report · Backoffice-Email |
| `treuhand-export-monthly` | 1. Tag jedes Monats 07:00 | Bexio-CSV · Email an Treuhand Kunz |
| `refund-eligibility-daily` | Daily 05:00 | `probezeit_end_date - today ≤ 14d` → Warn-Flag |
| `invoice-limitation-warning` | Daily 05:30 | `limitation_warning_at - today ≤ 90d` → Notification |
| `pdf-hash-verify-weekly` | Sunday 03:00 | Re-Hash PDFs · Compare mit `pdf_hash_sha256` · Alert bei Mismatch |

### M.3 Sagas (1)

**Saga: Refund-Issuance + Commission-Clawback (atomar)**

```
Step 1: fact_refund.denied=false + amount_refunded_gross gesetzt
Step 2: fact_invoice neu mit type=refund · parent=original_invoice_id
Step 3: fact_invoice_audit-Entry (event_type=refund_issued)
Step 4: Event refund_issued + commission_clawback_triggered → Commission-Engine
Step 5: Commission-Engine verzweigt nach commission_primary_role:
        ├─ cm_am / head_of → negative fact_commission_ledger-Entry
        ├─ researcher → fact_researcher_fee.status = 'clawed_back'
        └─ none → keine Aktion
Step 6: fact_refund.commission_clawback_triggered = true
Step 7: fact_refund.commission_clawback_at = now()

Compensation bei Fail: Steps 1–5 rollback · fact_refund.status = 'saga_failed' + Admin-Alert
```

Details: Billing-Interactions §4.2.

### M.4 REST-Endpoints (10 Gruppen)

Prefix: `/api/v1/billing`

| Gruppe | Endpoints |
|--------|-----------|
| Invoices | GET/POST `/invoices` · GET/PATCH `/invoices/:id` · POST `/approve`/`issue`/`cancel`/`dispute`/`resolve-dispute` · GET `/pdf`/`audit` |
| Payments | GET/POST `/payments` · POST `/payments/bank-import` · GET `/payments/unmatched` · PATCH `/payments/:id` |
| Dunning | GET `/dunning/pending` · POST `/dunning` · POST `/dunning/bulk` · DELETE `/dunning/:id` |
| Refunds | GET `/refunds` · POST `/refunds/check-eligibility/:placement_id` · POST `/refunds` · PATCH `/refunds/:id/approve` · POST `/refunds/:id/deny`/`pay` |
| Credit-Notes | GET/POST `/credit-notes` |
| MwSt | GET `/mwst/quarters/:quarter_start` · POST `/mwst/quarters/:quarter_start/export`/`lock` |
| Inkasso | GET `/inkasso` · POST `/inkasso` · POST `/inkasso/:id/dossier-export` · PATCH `/inkasso/:id` |
| Customers | GET `/customers` · GET `/customers/:id/ledger` · PATCH `/customers/:id/dunning-profile` |
| Treuhand-Export | GET `/export/treuhand/history` · POST `/export/treuhand/:year/:month` |
| Admin | POST `/admin/honorar-staffel` · POST `/admin/migration/excel-pdf` |

Details: Billing-Interactions §6.

### M.5 WebSocket-Channels

- `billing:dashboard` (aktuelle KPIs · 60s Polling oder Push)
- `billing:invoice:{invoice_id}` (Live-Updates bei Drawer-Open · Payment · Mahn-Status)
- `billing:unmatched` (Unmatched-Bookings-Queue-Updates)

### M.6 Settings-Keys (in `dim_automation_settings`)

| Key | Default | Zweck |
|-----|---------|-------|
| `billing.qr_reference_type_default` | `SCOR` | QRR aktivieren wenn QR-IBAN da |
| `billing.qr_iban` | NULL | Arkadium QR-IBAN (wenn vorhanden) |
| `billing.qr_bill_guideline_version` | `2.3` | SIX-IG-Version (Update-Path auf 2.4) |
| `billing.payment_terms_best_effort_days` | 30 | AGB §7 Best-Effort-Zahlungsziel |
| `billing.payment_terms_mandate_default_days` | 10 | Mandat-Default (per Mandat overridebar) |
| `billing.rabatt_gf_threshold_pct` | 20 | Ab Rabatt > X % GF-Approval-Pflicht |
| `billing.mahngebuehr_active` | false | MVP: aus, aktivierbar bei AGB-Revision |
| `billing.verzugszins_active` | false | MVP: aus |
| `billing.verzugszins_rate_pct` | 5.00 | OR 104 Default |
| `billing.feature_eu_invoicing` | false | EU-Reverse-Charge vertagt |
| `billing.feature_multi_currency` | false | Nur CHF MVP |
| `billing.arkadium_uid` | `CHE-463.920.799 MWST` | UID mit "MWST"-Suffix (Art. 26 MWSTG) |
| `billing.arkadium_iban` | `CH07 0077 7009 0644 7451 4` | Kantonalbank-Konto |
| `billing.treuhand_email` | `office@treuhand-kunz.ch` | Treuhand-Kunz-Export-Empfänger |

### M.7 RBAC-Rollen (Neue in `dim_mitarbeiter_roles`)

Keine neuen Rollen · Billing nutzt bestehende (AM · CM · Researcher · Backoffice · Head/GF · Treuhand · Admin).

Erweiterung `invoice_signer_priority` (smallint) in `dim_mitarbeiter` als Signer-Ranking für PDF-Anschreiben.

### M.8 Sync zu Commission-Engine

Commission-Engine-Spec v0.1 §4.1 + §4.3 + §5 (Patches 2026-04-20) implementieren:
- Subscriber-Events: `placement_confirmed` / `payment_received` / `invoice_paid` / `invoice_partially_paid` / `invoice_cancelled` / `invoice_written_off` / `refund_issued`
- 2-Stufen-Ledger-Modell: Forecast bei Placement · Promotion bei Payment
- Clawback-Event-Name: `commission_clawback_triggered` (aligned)
- Rücklage-Trigger: `fact_candidate_placement.guarantee_end_date` (Stellenantritt + 3 Mt)

---

## Sync-Kaskade

- **STAMMDATEN v1.5 §91** · Enum-Kataloge referenziert von Event-Payloads + Settings
- **DATABASE_SCHEMA v1.5** · Tabellen die Worker/Events nutzen
- **FRONTEND_FREEZE v1.12 §4h** · UI-Patterns aus Interactions v0.1
- **GESAMTSYSTEM v1.4** · Changelog

## Detailmasken-Impact

Keine neuen Detailmasken. Bestehende erweitert (siehe DATABASE-Patch).

---

**Patch anzuwenden nach Peter-Freigabe Billing-Spec v0.1 Freeze.**
