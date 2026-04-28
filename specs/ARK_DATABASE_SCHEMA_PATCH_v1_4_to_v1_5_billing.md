---
title: "ARK Database-Schema · Patch v1.4 → v1.5 · Billing-Modul"
type: patch
phase: 3
created: 2026-04-20
updated: 2026-04-20
status: draft
depends_on: [
  "specs/ARK_BILLING_SCHEMA_v0_1.md (authoritative DDL source)"
]
target: "raw/Ark_CRM_v2/ARK_DATABASE_SCHEMA_v1_4.md → v1.5"
tags: [patch, database, schema, billing, phase-3, postgresql]
---

# Database-Schema-Patch v1.4 → v1.5 · Billing-Modul

**Status:** Draft · anzuwenden nach Peter-Freigabe Billing-Spec v0.1 Freeze.

Vollständige DDL ist in `specs/ARK_BILLING_SCHEMA_v0_1.md` (~1100 Zeilen). Dieser Patch referenziert + listet Delta-Summary für Grundlagen-Integration.

---

## Delta-Summary

### Neue Tabellen (17)

**Dim-Tabellen (14):**
- `dim_invoice_types`
- `dim_invoice_status`
- `dim_honorar_staffel`
- `dim_mwst_codes`
- `dim_payment_methods`
- `dim_refund_reason_codes`
- `dim_refund_denial_reasons`
- `dim_credit_note_reasons`
- `dim_dunning_reasons`
- `dim_account_tone_of_voice`
- `dim_account_privacy_mode`
- `dim_account_dunning_cadence_profile`
- `dim_qr_reference_types`
- `dim_invoice_source`

**Fact-Tabellen (8):**
- `fact_invoice` (Rechnungs-Header)
- `fact_invoice_item` (Positionen)
- `fact_payment` (Zahlungen)
- `fact_dunning` (Mahnungen)
- `fact_credit_note` (Gutschriften)
- `fact_refund` (Rückerstattungen)
- `fact_inkasso` (Inkasso-Übergaben)
- `fact_invoice_audit` (Event-Audit, append-only)

### Erweiterte bestehende Tabellen (5)

**`dim_accounts`:**
- `legal_street_name` · `legal_house_number` · `legal_post_code` · `legal_town_name` · `iso_country_code` (SIX QR-Bill Type-S · Pflicht ab 21.11.2025)
- `tone_of_voice` FK `dim_account_tone_of_voice`
- `privacy_mode` FK `dim_account_privacy_mode`
- `dunning_cadence_profile` FK `dim_account_dunning_cadence_profile`
- `debtor_contact_id` FK `dim_contacts`
- `export_status_treuhand`

**`fact_mandate`:**
- `payment_terms_days` (Default 10)
- `contract_pdf_path`
- `stage_amounts_jsonb`
- `guarantee_start_policy` (Default `stellenantritt`)
- `negotiated_discount_pct` · `negotiated_by_user_id` · `negotiated_at`
- `weekly_fee_chf` · `time_billing_start_date` · `time_billing_end_date` (Time-Mandat Weekly-Fee-Modell)

**`fact_process_core`:**
- `negotiated_discount_pct` · `negotiated_by_user_id` · `negotiated_at`

**`fact_candidate_placement`:**
- `probezeit_months` (Default 3, Range 1–6)
- `probezeit_end_date` (Generated Column)
- `guarantee_end_date` (Generated Column · start_date + 3 months)

**`dim_mitarbeiter`:**
- `digital_signature_img_path` (PNG/SVG für PDF-Signatur-Einbettung)
- `department_code` (CE&BT / ARC&REM / MS&CS / GF / BO / ADMIN)
- `is_invoice_signer` · `invoice_signer_priority`

**`dim_assessment_types`:**
- `price_chf` (Standard-Preis pro Assessment-Typ)

### Neue Views (5)

- `v_invoice_open` (Aging-Buckets)
- `v_invoice_dunning_queue` (pending Mahnstufen nach Kadenz-Profil)
- `v_mwst_quarter` (Quartals-Aggregat für ESTV-Report)
- `v_customer_ledger` (Debitoren-Konto pro Kunde · DSO)
- `v_refund_clawback` (offene Commission-Clawbacks)

### Neue Functions / Triggers

- `generate_invoice_nr(p_year int)` — transaktional-sichere Rechnungs-Nr-Generierung (Advisory-Lock · Sequence pro Jahr)
- `generate_qrr_reference(p_invoice_nr text)` — 27-stellige QRR mit Modulo-10-Prüfziffer
- `update_invoice_payment_state()` — Trigger-Function auf `fact_payment` (INSERT/UPDATE/DELETE) · aktualisiert `fact_invoice.amount_paid` + `status_code` + `paid_date`

### Row-Level-Security

- `fact_invoice` + `fact_payment`: AM/CM sehen nur eigene Kunden via `dim_accounts.owner_am_id` / `owner_cm_id`
- Backoffice/GF/Admin/Treuhand: Full-Read
- Write-Permissions: Backoffice + GF

### Indexes (30+)

Siehe Schema-Spec §7 für vollständige Liste. Key-Indexes:
- `ux_invoice_nr` (UNIQUE)
- `ix_invoice_status_due` (Composite · für Aging-View)
- `ix_invoice_limitation_warning` (Partial · OR 128 Verjährungs-Warning)
- `ix_payment_qr_ref` (Partial · Auto-Match)
- `ix_refund_clawback_open` (Partial · offene Clawbacks)

### Constraints & Invariants

- `invoice_nr` Format `FN{YYYY}.{MM}.{####}`
- `amount_gross = amount_net + mwst_amount`
- `mwst_amount = 0` bei Reverse-Charge/Export/Exempt
- Mandat-Invoice erfordert `stage_nr` + `mandate_id`
- Assessment-Invoice erfordert `assessment_order_id`
- Refund/Storno/Gutschrift erfordert `original_invoice_id`
- `amount_paid ≤ amount_gross`
- `QR-IBAN impliziert QRR`
- Time-Mandat erfordert `weekly_fee_chf` + `time_billing_start_date`

---

## Seed-Daten

Siehe STAMMDATEN-Patch `specs/ARK_STAMMDATEN_PATCH_v1_4_to_v1_5_billing.md` für Enum-Values. Binding DDL mit INSERT-Statements in Schema v0.1 §3.

## Migrations-Scripts

Siehe `ARK_BILLING_SCHEMA_v0_1.md` §11:
- Adress-Strukturierung Bestandskunden (Regex-Parser)
- Altrechnungen-Import (Excel + PDF · Worker `billing-excel-pdf-import`)
- ISO-Country-Code Pflicht-Migration

---

## Sync-Kaskade

- **STAMMDATEN v1.5 §91** · alle Enum-Kataloge
- **BACKEND_ARCHITECTURE v2.7 §M** · Events · Worker · Endpoints · Sagas für diese Tabellen
- **FRONTEND_FREEZE v1.12 §4h** · UI-Patterns · Rechnungs-Editor-Drawer · Mahnwesen-Cockpit · Refund-Cockpit
- **GESAMTSYSTEM v1.4** · Changelog

## Detailmasken-Spec-Impact (Sync-Matrix)

Per `wiki/meta/spec-sync-regel.md` §Sync-Matrix:

| Detailmaske | Impact | Aktion |
|-------------|--------|--------|
| Account-Spec | Adress-Struktur-Felder · dunning_cadence · privacy_mode · debtor_contact | v0.3 → v0.4 Schema-Erweiterung |
| Mandat-Spec | payment_terms_days · contract_pdf_path · stage_amounts_jsonb · guarantee_start_policy · negotiated_discount · time-Mandat-Felder | v0.3 → v0.4 |
| Prozess-Spec | negotiated_discount-Felder | v0.3 → v0.4 |
| Kandidat-Spec | Placement-Probezeit-Felder (via fact_candidate_placement) | v1.3 → v1.4 |
| Assessment-Spec | dim_assessment_types.price_chf | v0.3 → v0.4 |

---

**Patch anzuwenden nach Peter-Freigabe Billing-Spec v0.1 Freeze + Commission-Engine-v0.1-Patches-Review.**
