---
title: "ARK Stammdaten · Patch v1.4 → v1.5 · Billing-Modul §91"
type: patch
phase: 3
created: 2026-04-20
updated: 2026-04-20
status: draft
depends_on: [
  "specs/ARK_BILLING_PLAN_v0_1.md",
  "specs/ARK_BILLING_SCHEMA_v0_1.md",
  "specs/ARK_BILLING_INTERACTIONS_v0_1.md"
]
target: "raw/Ark_CRM_v2/ARK_STAMMDATEN_EXPORT_v1_4.md → v1.5 (neuer §91)"
tags: [patch, stammdaten, billing, phase-3]
---

# Stammdaten-Patch v1.4 → v1.5 · Billing-Modul

**Status:** Draft · anzuwenden nach Peter-Freigabe Billing-Spec v0.1 Freeze.

Dieser Patch fügt §91 zu `ARK_STAMMDATEN_EXPORT_v1_4.md` hinzu. Alle Enum-Kataloge für das Billing-Modul.

---

## §91. Billing-Modul-Stammdaten (NEU v1.5 · 2026-04-20)

Stammdaten-Kataloge für Rechnungsstellung, Mahnwesen, Refund, Zahlungen. Vollständige DDL in `specs/ARK_BILLING_SCHEMA_v0_1.md` §3.

### §91.1 Rechnungs-Typen (`dim_invoice_types`)

| Code | Label DE | Kategorie |
|------|----------|-----------|
| `erfolg` | Erfolgs-Rechnung | invoice (Best-Effort Placement) |
| `akonto` | Akonto-Rechnung | invoice (Mandat Stage 1) |
| `zwischen` | Zwischen-Rechnung | invoice (Mandat Stage 2 · Shortlist-Start) |
| `schluss` | Schluss-Rechnung | invoice (Mandat Stage 3 · Placement) |
| `mandat_time_monthly` | Time-Mandat Monats-Rechnung | invoice (Weekly-Fee × Wochen) |
| `optionale_stage` | Optionale Stage | invoice (Mandat Stage 4 · Sonder-Aufwand, GF-Pflicht) |
| `kuendigung` | Kündigungs-Rechnung | invoice (Mandat-Abbruch, GF-Pflicht) |
| `assessment` | Assessment-Rechnung | invoice (Diagnostik & Assessment) |
| `bonus_schutzfrist` | Bonus · Schutzfrist-Verletzung | invoice (§4 AGB · Direkteinstellung, GF-Pflicht) |
| `refund` | Rückerstattung | refund (Garantie-Fall · AGB §8) |
| `gutschrift` | Gutschrift | credit_note (Teil-Korrektur, GF-Pflicht) |
| `storno` | Storno | cancellation (vollständige Annullierung, GF-Pflicht) |

### §91.2 Rechnungs-Status (`dim_invoice_status`)

| Code | Label DE | Open/Terminal |
|------|----------|---------------|
| `draft` | Entwurf | open |
| `approved` | Freigegeben | open |
| `issued` | Versendet | open |
| `partial` | Teilbezahlt | open |
| `paid` | Bezahlt | terminal |
| `overdue` | Überfällig | open |
| `dunning_1` | Mahnung Stufe 1 | open |
| `dunning_2` | Mahnung Stufe 2 | open |
| `dunning_3` | Mahnung Stufe 3 | open |
| `disputed` | Honorarstreit | open |
| `gestundet` | Gestundet | open |
| `collection_external` | Inkasso extern | open |
| `debt_enforcement_pending` | Betreibung vorbereitet | open |
| `payment_order_served` | Zahlungsbefehl zugestellt | open |
| `legal_objection` | Rechtsvorschlag | open |
| `rights_opening_required` | Rechtsöffnung nötig | open |
| `cancelled` | Storniert | terminal |
| `refunded` | Rückerstattet | terminal |
| `written_off` | Abgeschrieben | terminal |

### §91.3 Honorar-Staffel (`dim_honorar_staffel`)

**AGB FEB 2023 · §4 Best-Effort-Honorarordnung** · versionierbar pro AGB-Version.

| Version `agb-feb-2023` | Jahressalär | Honorarsatz |
|------------------------|-------------|-------------|
| Einstieg | < CHF 90'000 | **21 %** |
| Mittel | < CHF 110'000 | **23 %** |
| Senior | < CHF 130'000 | **25 %** |
| Executive | ≥ CHF 130'000 | **27 %** |

Basis: erster Jahreslohn bei 100 % Zielerreichung + Vollpensum · inkl. 13./14. ML + variable Bestandteile + Fringe Benefits (Dienstwagenanteil etc.) · exkl. MwSt.

### §91.4 MwSt-Codes (`dim_mwst_codes`)

| Code | Rate | Tax-Treatment | ESTV-Box |
|------|------|---------------|----------|
| `std_81` | 8.10 % | domestic | 200 |
| `std_77` | 7.70 % | domestic (legacy bis 31.12.2023) | 200 |
| `red_26` | 2.60 % | domestic | 205 |
| `lodging_38` | 3.80 % | domestic (Beherbergung) | 207 |
| `export_0` | 0 % | export | 221 |
| `rc_0` | 0 % | reverse_charge | 221 |
| `exempt` | 0 % | exempt | 289 |

### §91.5 Zahlungsmittel (`dim_payment_methods`)

| Code | Label DE |
|------|----------|
| `qr` | QR-Überweisung |
| `bank_transfer` | Bank-Überweisung (klassisch) |
| `credit_card` | Kreditkarte |
| `twint_business` | TWINT Business |
| `compensation` | Verrechnung mit Gutschrift |
| `manual_journal` | Manuelle Buchung |

### §91.6 Refund-Gründe (`dim_refund_reason_codes`)

Routing auf `business_model` + Staffel-% aus AGB §8.

| Code | Label DE | Business-Model | Staffel-% | Probezeit-Phase |
|------|----------|----------------|-----------|-----------------|
| `no_start` | Stelle nicht angetreten | erfolgsbasis | 100 % | pre_start |
| `resign_month_1_probation` | Austritt Probezeit-Monat 1 | erfolgsbasis | 50 % | month_1 |
| `resign_month_2_probation` | Austritt Probezeit-Monat 2 | erfolgsbasis | 25 % | month_2 |
| `resign_month_3_probation` | Austritt Probezeit-Monat 3 | erfolgsbasis | 10 % | month_3 |
| `resign_post_probation` | Austritt nach Probezeit | erfolgsbasis | 0 % | post_probation |
| `mandate_early_exit` | Mandat-Kandidat früh ausgeschieden | mandat_target | — (Ersatz-Suche) | na |
| `mandate_early_exit_tf` | Taskforce-Mandat früh ausgeschieden | mandat_taskforce | — (Ersatz-Suche) | na |
| `time_exit_na` | Time-Mandat kein Refund | mandat_time | 0 % | na |

### §91.7 Refund-Ablehnungs-Gründe (`dim_refund_denial_reasons`)

AGB §8 Ausschluss-Tatbestände.

| Code | Label DE | AGB-Ref | GF-Override nötig |
|------|----------|---------|-------------------|
| `customer_caused_no_start` | Kunden-Gründe für Nicht-Antritt | AGB §8 | nein |
| `customer_terminated_during_probation` | Kunde kündigt in Probezeit | AGB §8 | nein |
| `after_probation_exit` | Austritt nach Probezeit | AGB §8 | nein |
| `no_notification_3d` | 3-Tage-Meldepflicht verletzt | AGB §8 | **ja** |
| `no_cause_reported` | Kunde meldete keine Gründe | AGB §8 | **ja** |

### §91.8 Gutschrifts-Gründe (`dim_credit_note_reasons`)

| Code | Label DE | GF-Pflicht |
|------|----------|-----------|
| `error_billing` | Rechnungs-Fehler | ja |
| `error_customer` | Falscher Kunde/Adresse | ja |
| `kulanz` | Kulanz-Gutschrift | ja |
| `dispute_resolved` | Honorarstreit-Vergleich | ja |
| `vat_correction` | MwSt-Korrektur | ja |
| `duplicate_invoice` | Doppelverrechnung | ja |
| `cancellation_reissue` | Storno und Neu-Erstellung | ja |
| `service_scope_change` | Leistungsumfang geändert | ja |

**Alle Gutschrifts-Gründe immer GF-Pflicht** (PO-Decision Batch 2 Q8).

### §91.9 Mahn-Gründe (`dim_dunning_reasons`)

| Code | Label DE |
|------|----------|
| `late_payment` | Zahlungsverzug |
| `partial_payment` | Teilzahlung unter Soll |

### §91.10 Anrede-Typ (`dim_account_tone_of_voice`)

| Code | Label DE |
|------|----------|
| `sie` | Sie-Form |
| `du` | Du-Form |

### §91.11 Privacy-Mode (`dim_account_privacy_mode`)

| Code | Label DE |
|------|----------|
| `blind_copy_only` | Blind-Copy (Default · DSG-sicher) |
| `initials` | Initialen |
| `internal_reference_only` | Nur interne Referenz |
| `full_name` | Vollname (volle Transparenz) |

Default: `blind_copy_only`.

### §91.12 Mahn-Kadenz-Profil (`dim_account_dunning_cadence_profile`)

Segmentiert pro Kunden-Klasse (PO-Decision Batch 1 Q5).

| Code | Label DE | T+L1 | Offset L2 | Offset L3 | Offset Inkasso |
|------|----------|------|-----------|-----------|----------------|
| `standard` | Standard-Kunde | T+15 | +15 | +15 | +5 |
| `key_account` | Key-Account | T+30 | +15 | +15 | +5 |

### §91.13 QR-Referenz-Typen (`dim_qr_reference_types`)

| Code | Label DE | Pattern |
|------|----------|---------|
| `QRR` | QR-Referenz 27-stellig | `^[0-9]{27}$` |
| `SCOR` | Creditor Reference ISO 11649 | `^RF[0-9]{2}[A-Z0-9]{1,21}$` |
| `NON` | Keine Referenz | — |

**MVP-Default:** `SCOR` (bis QR-IBAN von Kantonalbank beschafft · PO-Decision Batch 2 Q6).

### §91.14 Rechnungs-Quelle (`dim_invoice_source`)

| Code | Label DE |
|------|----------|
| `native` | Native · im System erstellt |
| `migration_excel` | Migration · aus Excel + PDF importiert |

---

## Sync-Kaskade zu anderen Grundlagen

- **DATABASE_SCHEMA v1.5:** Tabellen-Definitionen mit genau diesen Enum-FKs (siehe `ARK_DATABASE_SCHEMA_PATCH_v1_4_to_v1_5_billing.md`)
- **BACKEND_ARCHITECTURE v2.7:** Events referenzieren die Status-/Typ-Codes
- **FRONTEND_FREEZE v1.12:** UI-Labels lesen `label_de` aus `dim_*` (kein Hardcode)
- **GESAMTSYSTEM v1.4:** Changelog-Eintrag

## AGB-Quelle

Stammdaten-Werte für Honorar-Staffel und Refund-Staffel exakt aus `raw/Ark_CRM_v2/Arkadium_AGB_FEB_2023.pdf` §4 + §8.

---

**Patch anzuwenden nach Peter-Freigabe Billing-Spec v0.1 Freeze.**
