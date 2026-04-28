---
title: "ARK Billing-Modul · Interactions v0.1"
type: spec
phase: 3
created: 2026-04-20
updated: 2026-04-20
status: draft
depends_on: [
  "specs/ARK_BILLING_PLAN_v0_1.md",
  "specs/ARK_BILLING_SCHEMA_v0_1.md"
]
sources: [
  "specs/ARK_BILLING_PLAN_v0_1.md",
  "specs/ARK_BILLING_SCHEMA_v0_1.md",
  "raw/Ark_CRM_v2/ARK_BACKEND_ARCHITECTURE_v2_5.md (Events/Worker/Sagas-Pattern)",
  "raw/Ark_CRM_v2/ARK_FRONTEND_FREEZE_v1_10.md (UI-Pattern)",
  "wiki/meta/decisions.md (§2026-04-20 Billing-Batches 1–4 · AGB-Review · SIX-Fact-Check)",
  "wiki/meta/mockup-baseline.md (Drawer-540px · Editorial-Style)",
  "specs/ARK_COMMISSION_ENGINE_SPEC_v0_1.md (Event-Kopplung)",
  "specs/ARK_EMAIL_KALENDER_DETAILMASKE_SCHEMA_v0_1.md (Outlook-Token-Pattern)",
  "specs/ARK_REMINDERS_VOLLANSICHT_SCHEMA_v0_1.md (Reminder-Integration)"
]
grundlagen_sync_required: [
  "ARK_BACKEND_ARCHITECTURE_v2_6 → v2.7 (Section M. Billing-Modul · Events · Worker · Sagas · Endpoints)",
  "ARK_FRONTEND_FREEZE_v1_11 → v1.12 (§4h Operations · Billing · Routen · Drawer-Inventar)",
  "ARK_GESAMTSYSTEM_UEBERSICHT_v1_3.6 → v1.4 (Changelog)"
]
tags: [spec, interactions, billing, phase-3, ui-flows, events, workers, endpoints]
---

# ARK Billing-Modul · Interactions v0.1

UI-Flows · Screens · Drawer-Specs · Events · Workers · Sagas · REST-Endpoints · Email-Templates.

Grundlage: Plan v0.1 + Schema v0.1 + 4 PO-Batches + AGB-Review + SIX-Fact-Check.

---

## 1. Screen-Inventory

### 1.1 Top-Level-Routen

| Route | Screen | Zielgruppe | Default-Tab |
|-------|--------|-----------|-------------|
| `/billing` | Billing-Dashboard | Backoffice · GF | KPIs + Aging |
| `/billing/rechnungen` | Rechnungs-Liste | Backoffice · GF · AM (RLS) | alle aktiv |
| `/billing/rechnungen/:invoice_id` | Rechnung-Detail (Drawer-Flow) | Backoffice · GF | Positionen |
| `/billing/mahnwesen` | Mahnwesen-Cockpit | Backoffice · GF | pending Stufen |
| `/billing/debitoren` | Debitoren-Liste | Backoffice · GF · AM (RLS) | offene Salden |
| `/billing/debitoren/:customer_id` | Debitor-Konto (Kundenansicht) | Backoffice · GF · AM (RLS) | Ledger |
| `/billing/zahlungen` | Zahlungseingang | Backoffice · GF | Unmatched |
| `/billing/refunds` | Refund-Cockpit | Backoffice · GF | offene Garantie-Fälle |
| `/billing/mwst` | MwSt-Abrechnung | Backoffice · GF · Treuhand (RO) | aktuelles Quartal |
| `/billing/inkasso` | Inkasso-Liste | Backoffice · GF | aktive Verfahren |
| `/billing/export/treuhand` | Treuhand-Export | Backoffice · Treuhand (RO) | monatliche Batches |

### 1.2 Navigations-Struktur (Sidebar)

```
Finanzen
├── Dashboard
├── Rechnungen
├── Mahnwesen
├── Debitoren
├── Zahlungen
├── Refunds
├── MwSt
├── Inkasso
└── Treuhand-Export
```

UI-Label "**Finanzen**" statt "Billing" in Sidebar (per Research-Empfehlung · User-facing Deutsch).

---

## 2. Screen-Spezifikationen

### 2.1 `/billing` · Dashboard

**Layout:** 4-Spalten-KPI-Bar oben · 3 Widgets darunter (2/1-Split)

**KPIs (Top-Bar):**

| KPI | Berechnung | Deep-Link |
|-----|------------|-----------|
| Offen gesamt | `SUM(v_invoice_open.amount_open)` | `/billing/rechnungen?status=open` |
| Überfällig | `SUM amount_open WHERE due_date < today AND status != paid` | `/billing/rechnungen?status=overdue` |
| Zahlungseingänge 30d | `SUM fact_payment.amount WHERE payment_date >= today-30d` | `/billing/zahlungen?period=30d` |
| MwSt-Quartal offen | `SUM mwst_amount` aktuelles Quartal · nicht deklariert | `/billing/mwst` |

**Widgets:**

1. **Mahnungs-Pipeline** (Column-Chart) · Anzahl Rechnungen pro aktueller Mahnstufe + Pending-Eskalationen → Click-Through auf `/billing/mahnwesen`
2. **Top-10-Debitoren** (Tabelle) · höchste offene Salden · sortiert `open_balance DESC` aus `v_customer_ledger` · Ampel (grün/gelb/rot nach days_overdue)
3. **Refund-Warn-Liste** (Tabelle) · Placements in Garantiezeit mit Exit-Risiko (Probezeit-Ende ≤ 14d) · Click-Through auf Refund-Cockpit

**Refresh:** Live via WebSocket-Channel `billing:dashboard` oder Polling 60s.

### 2.2 `/billing/rechnungen` · Rechnungs-Liste

**Filter-Bar (horizontal scrollbar auf Mobile):**
- Status (Multi-Select)
- Typ (Multi-Select aus `dim_invoice_types`)
- Kunde (Autocomplete gegen `dim_accounts`)
- Sparte (Multi-Select `dim_sparten`)
- Datum-Range (von/bis · Kalender-Picker + manuelle Eingabe)
- Betrag-Range
- AGB-Version
- Sprache (Sie/Du)
- Exportstatus Treuhand
- Verantwortlicher (AM/CM · eigene Row-Level)

**Spalten:**

| Spalte | Sortable | Default |
|--------|----------|---------|
| Rechnungs-Nr | ✓ | DESC |
| Kunde | ✓ | — |
| Typ (Badge) | ✓ | — |
| Referenz (Kandidat/Mandat/Assessment) | — | — |
| Betrag brutto | ✓ | — |
| Offen | ✓ | — |
| Issue-Datum | ✓ | — |
| Fälligkeit | ✓ | — |
| Status (Badge) | ✓ | — |
| Mahnstufe (Badge) | — | — |
| Verantwortlich (AM + Backoffice) | — | — |
| Exportstatus | — | — |

**Bulk-Actions:**
- PDF-Export (ZIP mit allen selektierten)
- Mahnung senden (Bulk · Preview-Modal · Filter-Warning wenn disputed darunter)
- CSV-Export (Treuhand-Format oder Custom)
- Storno vorbereiten (immer GF · Einzel-Review)
- Email-Erinnerung senden

**Row-Click:** öffnet Rechnung-Detail-Drawer (siehe §3.1).

### 2.3 `/billing/mahnwesen` · Mahnwesen-Cockpit

**2 Tabs:**

1. **Pending** (Default) · aus `v_invoice_dunning_queue` wo `next_dunning_level_due IS NOT NULL`
2. **Aktiv** · alle mit Status `dunning_1/2/3`

**Spalten Pending:**
- Rechnungs-Nr
- Kunde + Kadenz-Profil (Badge: key_account / standard)
- Offen
- Tage überfällig
- Letzte Aktivität
- Nächste Stufe (Badge: "Mahnung 1" / "Mahnung 2" / "Mahnung 3" / "Inkasso-Eskalation")
- Empfohlene Aktion
- Risiko-Indikator (grün/gelb/rot basiert auf days_overdue + amount_open)

**Sammelaktion:** "Alle Stufe X vorbereiten" · Generiert Drafts, Versand nur nach Review im Modal (siehe §3.3).

### 2.4 `/billing/debitoren` · Debitoren-Liste

Aus `v_customer_ledger`.

**Spalten:** Kunde · Kadenz-Profil · Offener Saldo · Offene Rechnungen Count · Bezahlt YTD · Ø Zahlungsdauer · Letzte Rechnung

**Sortierung:** default `open_balance DESC`.

**Row-Click:** `/billing/debitoren/:customer_id`

### 2.5 `/billing/debitoren/:customer_id` · Debitor-Konto

**Header:** Kunde + Adresse (strukturiert) + Kadenz-Profil-Toggle + Tone-of-Voice-Toggle + Privacy-Mode-Dropdown

**Tabs:**

1. **Offene Posten** · alle nicht-bezahlten Rechnungen
2. **Zahlungshistorie** · alle `fact_payment` dieses Kunden, chronologisch
3. **Gutschriften/Refunds** · alle `fact_credit_note` + `fact_refund` dieses Kunden
4. **Streitfälle** · Rechnungen mit `dispute_reason`
5. **Audit** · `fact_history` Events für alle Invoices dieses Kunden

**KPI-Bar oben:**
- Offen gesamt
- Bezahlt YTD
- Ø Tage Zahlung
- Letzte Rechnung
- Höchste offene Einzelforderung

### 2.6 `/billing/zahlungen` · Zahlungseingang

**2 Tabs:**

1. **Import-Queue** · CAMT.054-Upload + Parsing-Status
2. **Unmatched Bookings** · Zahlungen ohne eindeutigen Match (Confidence < 70 %)

**Import-Tab:**
- Upload-Dropzone für `.xml` (CAMT.054) oder `.csv` (Fallback)
- Parser-Result-Preview vor Commit: Matched-Count · Unmatched-Count · Fehler-Count
- Commit-Button (Bulk-Insert nach Review)

**Unmatched-Tab:**
- Tabelle mit Bank-Booking-Daten (IBAN · Amount · Ref · Datum)
- Vorschlags-Liste (Top-3-Matches nach Heuristik)
- "Zahlung erfassen"-Action öffnet Drawer (siehe §3.5)

**Confidence-Badges:** Hoch ≥ 95 % · Mittel 70–94 % · Tief < 70 %

### 2.7 `/billing/refunds` · Refund-Cockpit

**Filter nach Garantiefrist-Status:**
- Offen (exit_date NULL · innerhalb probezeit_end_date)
- Exit-Risiko (Probezeit läuft in ≤ 14d ab · Kandidat noch aktiv)
- Ausgelöst (Refund im Entstehen)
- Abgeschlossen

**Spalten:**
- Placement-Process-Nr
- Kandidat (nach privacy_mode)
- Kunde
- Stellenantritt-Datum
- Probezeit-Ende
- Original-Rechnung-Nr + Betrag
- Status (Badge: "aktiv" / "exit gemeldet" / "refund draft" / "refund issued" / "refund paid")
- Aktion (Refund-Berechnung öffnen / Ausschluss prüfen)

**Row-Click:** öffnet Refund-Berechnung-Drawer (siehe §3.6).

### 2.8 `/billing/mwst` · MwSt-Abrechnung

**Layout:**
- Quartals-Selector (Default aktuelles Quartal)
- KPI-Bar: Steuerbare Umsätze · MwSt-Betrag · Korrekturen · Einreichungs-Deadline (60d nach Quartalsende)
- Mapping-Tabelle ESTV-Boxen (Ziffer 200/205/221/289) mit Beträgen
- Export-Buttons: PDF-Report · CSV-Export · Einreichungs-Markierung
- Status-Badge: "open" → "prepared" → "filed" → "paid"
- Lock-Mechanismus nach Quartalsabschluss (read-only für ältere Quartale · GF-Override möglich mit Audit-Log)

### 2.9 `/billing/inkasso` · Inkasso-Liste

**Spalten:** Partner · Übergabe-Datum · Status · Erwartete Recovery · Tatsächlich recovered · Betreibungs-Nr · Letzte Aktivität

**Detail-Drawer:** Dossier-Download-Link · Partner-Kommunikation · Status-Update · Gebühr-Tracking.

### 2.10 `/billing/export/treuhand` · Treuhand-Export

- Monatlicher Batch-Generator
- History-Tabelle aller Exports (Monat · Anzahl Rechnungen · Anzahl Zahlungen · Datei-Download · Sent-to-Kunz-Datum)
- Neuer Export: Monat auswählen → Preview → Commit → Email an office@treuhand-kunz.ch mit CSV-Attachment

---

## 3. Drawer-Spezifikationen (540px Default)

Alle CRUD/Multi-Step-Aktionen als Drawer per [CLAUDE.md Drawer-Default-Regel](../../CLAUDE.md).

### 3.1 Rechnung-Detail-Drawer

**Trigger:** Row-Click in `/billing/rechnungen` oder Deep-Link `/billing/rechnungen/:id`

**Header:**
- Rechnungs-Nr (Libre Baskerville) · Status-Badge · Typ-Badge
- Actions-Dropdown: Edit (nur Draft) · Approve (Backoffice→issued, GF bei Rabatt > 20 %) · Issue · Senden · Stornieren (immer GF) · Gutschrift (immer GF) · Mahnung auslösen

**Tabs (5):**

1. **Positionen** · Liste `fact_invoice_item` · bei Draft editierbar · Live-Summe unten (Sticky-Footer mit "Netto · MwSt · Brutto")
2. **Zahlungen** · alle `fact_payment` dieser Invoice · Action "Zahlung manuell erfassen"
3. **Mahnungen** · `fact_dunning`-History · Timestamps + Deadline + PDF-Link
4. **Audit** · `fact_invoice_audit`-Timeline chronologisch
5. **PDF-Preview** · iframe mit Live-Render · Toggle Seite 1/2/3 (Anschreiben/Tabelle/Blind-Copy+QR)

**Warnings (Inline):**
- Kandidaten-Klarname auf Seite 2 (nur wenn privacy_mode ≠ blind_copy_only)
- Verjährung läuft in ≤ 90d (bei `limitation_warning_at - today ≤ 90`)
- Adress-Struktur unvollständig (Type-S-Compliance)
- Dispute aktiv (Mahnungs-Timer pausiert)

**Sticky-Footer:**
- Betrags-Summary (Netto · MwSt · Brutto · Offen)
- Aktions-Buttons (je nach Status)

### 3.2 Rechnung-Erstellen-Drawer (Multi-Step Wizard)

**Trigger:** Button "Neue Rechnung" in `/billing/rechnungen` oder Auto-Open bei `invoice_triggered`-Event

**7 Steps:**

1. **Kunde wählen** · Autocomplete gegen `dim_accounts` · Validierung Type-S-Compliance (Warnung bei fehlenden Adress-Feldern)
2. **Quelle / Typ** · Radio-Gruppe:
   - Best-Effort-Prozess (Process-Autocomplete gegen `fact_process_core.stage = placement`)
   - Mandat-Stage (Mandat-Autocomplete + Stage-Selector 1/2/3/4)
   - Assessment-Auftrag (`fact_assessment_order`-Autocomplete)
   - Refund (Original-Rechnung wählen)
   - Gutschrift (Original-Rechnung wählen)
   - Freie Rechnung (manuell · GF-Pflicht)
3. **Positionen** · Auto-Fill aus gewählter Quelle:
   - Best-Effort: 1 Position mit Kandidat + Salär + Honorar-Staffel-Auto-Satz
   - Mandat: 3 Positionen (alle Stages · nur fällige mit Betrag · andere `is_open_posten=true` "OFFENER POSTEN")
   - Assessment: 1 Position mit Assessment-Typ + Preis aus `dim_assessment_types.price_chf`
   - Refund: 1 Position mit Refund-Staffel-Berechnung (Probezeit-basiert)
   - Manuell: User fügt Positionen hinzu
4. **MwSt & Rabatt** · pro Position MwSt-Code · Rabatt aus Process/Mandat (read-only außer GF) · Live-Summen
5. **Anschreiben + Signatur** · Template-Auswahl · Du/Sie-Preview · Signer-Auswahl (Primary = Nenad fix · Secondary = Bereichs-Head basiert auf Process/Mandat-Owner)
6. **QR-Preview** · Live-Render Seite 3 · Pre-Issue-Validator-Output (alle Checks grün?)
7. **Freigabe** · Approve → status=approved · Issue → status=issued + PDF-Gen + Email-Versand

**Validator-Checks vor Step 7:**
- Adress-Struktur Type S komplett
- MwSt-Pflicht-Angaben (UID, Satz, Betrag)
- Betrag > 0
- Signer gesetzt
- PDF-Template-Version valide
- Bei Rabatt > 20 %: GF-Approval-Pflicht

### 3.3 Mahnung-Senden-Modal (420px · kein Drawer)

**Trigger:** Action "Mahnung auslösen" aus Rechnungs-Liste/Detail oder Bulk aus Mahnwesen-Cockpit

**Content:**
- Kunden-Name + Rechnungs-Nr(n)
- Empfohlene Stufe (aus `v_invoice_dunning_queue`)
- Ton-Preview (Anschreiben-Text Stufe 1/2/3 · Du/Sie-Variante)
- Neue Frist (T+5 nach Versand)
- Optional: Mahngebühr (MVP: 0 · Feld ausgegraut)
- Optional: Verzugszins (MVP: 0)

**Actions:** "Abbrechen" · "Vorschau PDF" · "Senden" (Doppel-Confirm bei Bulk-Versand mit Count-Warning bei disputed)

### 3.4 Gutschrift-Drawer

**Steps:**

1. **Rechnung wählen** (Autocomplete gegen offene Rechnungen)
2. **Grund** (Dropdown `dim_credit_note_reasons`)
3. **Betrag** (Netto + MwSt · Default = Original-Rechnungs-Betrag)
4. **Optional: Neue Invoice verlinken** (bei Storno+Neu)
5. **GF-Approval** (immer Pflicht per Q8)
6. **PDF-Preview + Issue**

### 3.5 Zahlung-Erfassen-Drawer

**Trigger:** "Zahlung manuell erfassen" aus Rechnungs-Detail oder Unmatched-Bookings-Tab

**Felder:**
- Invoice (Autocomplete · bereits vorausgefüllt wenn aus Rechnung)
- Betrag
- Valuta-Datum (default heute · Kalender-Picker + manuell)
- Payment-Datum
- Zahlungsmittel (Dropdown `dim_payment_methods`)
- Referenz (QRR/SCOR/Freitext)
- Bank-Account
- Bank-Booking-Details (JSON-Textarea · für manuelle Eingabe)
- Match-Confidence (Auto-Berechnung · editierbar)
- Notiz

**Actions:** Speichern → Trigger `update_invoice_payment_state()` → Status-Update automatisch

### 3.6 Refund-Berechnung-Drawer

**Trigger:** Row-Click in Refund-Cockpit oder Auto-Open bei `refund_eligibility_check`-Event

**Sections:**

1. **Placement-Kontext:** Kandidat · Stellenantritt · Probezeit-Ende · Original-Rechnungs-Nr + Betrag
2. **Exit-Daten:** Exit-Datum · Grund (aus `fact_history`) · Wer hat gekündigt (Kandidat/Kunde)
3. **3-Tage-Meldepflicht-Check:**
   - Kandidat-Kündigungs-Datum
   - Kunden-Meldungs-Datum (bei Arkadium eingegangen)
   - Meldung within 3d? Auto-Badge "✓ erfüllt" / "✗ verletzt"
   - Bei Verletzung: Warning "Refund-Anspruch erloschen (AGB §8)" + GF-Override-Checkbox
4. **Ausschluss-Prüfung:**
   - Dropdown `dim_refund_denial_reasons`
   - Bei Auswahl: Refund-Denied-Flow
5. **Staffel-Berechnung (wenn kein Ausschluss):**
   - Anzeige Probezeit-Phase basiert auf `(exit_date - start_date)`
   - Staffel-% aus `dim_refund_reason_codes.staffel_pct` (100/50/25/10/0)
   - Refund-Betrag = original × staffel_% × (1 − keine-Toleranz)
   - MwSt-Anteil Refund
6. **Commission-Clawback-Preview:** welche MA betroffen · aus welcher Rücklage (aus `fact_commission_ledger`)
7. **GF-Approval-Pflicht** (immer Q8)
8. **Auszahlung:** Kunden-IBAN · Pain.001-Export-Button · Valuta-Datum

### 3.7 Inkasso-Übergabe-Drawer

**Sections:**

1. **Rechnungs-Kontext** (Nr, Kunde, offener Betrag, Mahnstufe-History)
2. **Dossier-Checklist:**
   - [ ] Vertrag/Offerte-PDF
   - [ ] AGB-Snapshot-PDF
   - [ ] Original-Rechnung-PDF
   - [ ] Alle Mahnungen-PDFs
   - [ ] Email-Korrespondenz (ZIP)
   - [ ] Placement-Nachweis (falls Best-Effort)
3. **Inkasso-Partner** (Dropdown oder Freitext · Default-Partner konfigurierbar pro GF-Entscheid)
4. **GF-Reputations-Warning** (besonders bei Key-Accounts)
5. **Export-Button:** ZIP-Dossier generieren + fact_inkasso anlegen

### 3.8 Mandat-Stage-Trigger-Drawer

**Trigger:** Auto bei `shortlist_reached`-Event oder manuell aus Mandat-Detailseite

**Content:**
- Mandat-Nr + Kunde
- Aktuelle Stage (1 bezahlt / 2 pending etc.)
- Nächste Stage + Betrag (aus `fact_mandate.stage_amounts_jsonb`)
- Auto-generierter Draft-Preview
- Approve + Issue

### 3.9 Bank-Import-Drawer (CAMT.054)

**Content:**
- Upload-Dropzone `.xml` / `.csv`
- Parser-Output:
  - Anzahl Bookings total
  - Auto-Match ≥ 95 %: N (Liste)
  - Auto-Match 70–94 %: N (Liste, zur Review)
  - Unmatched: N (Liste, manuell)
- Batch-Import-Button

### 3.10 Honorar-Streit-Drawer

**Trigger:** Action "Als Honorarstreit markieren" aus Rechnungs-Detail

**Sections:**

1. **Streit-Grund** (Freitext + Datum)
2. **Status-Update** → `disputed` (Mahnungs-Timer pausiert automatisch)
3. **Dokumenten-Sammlung** (Vertrag · AGB · Emails via Email-Kalender-Deep-Link)
4. **GF-Eskalation-Task** (Reminder via Reminders-Vollansicht)
5. **Resolution-Dropdown:** paid-full · teil-gutschrift · storno · inkasso (Sub-Flow je nach Auswahl)

---

## 4. Events

### 4.1 Billing-Events (neu in `ARK_BACKEND_ARCHITECTURE_v2_7` §A)

| Event-Code | Payload | Trigger | Consumers |
|------------|---------|---------|-----------|
| `invoice_triggered` | `{ process_id, business_model }` | `fact_process_core.stage = placement` | Worker `billing-draft-generator` |
| `akonto_invoice_triggered` | `{ mandate_id }` | `fact_mandate.status = signed` | Worker `billing-draft-generator` |
| `zwischen_invoice_triggered` | `{ mandate_id, process_id }` | Shortlist-Start (N CVs) | Worker `billing-draft-generator` |
| `schluss_invoice_triggered` | `{ mandate_id, process_id }` | `fact_process_core.stage = placement` (Mandat-Prozess) | Worker `billing-draft-generator` |
| `termination_invoice_triggered` | `{ mandate_id }` | `fact_mandate.status = terminated_by_client` | Worker `billing-draft-generator` |
| `invoice_triggered_assessment` | `{ assessment_order_id }` | `fact_assessment_order.status = delivered` | Worker `billing-draft-generator` |
| `invoice_triggered_time_monthly` | `{ mandate_id, month, year, weekly_fee, weeks_in_month }` | Cron 1. Tag Folgemonat | Worker `time-mandate-monthly-invoice` |
| `invoice_approved` | `{ invoice_id, approved_by }` | UI-Action "Approve" | Audit |
| `invoice_issued` | `{ invoice_id }` | UI-Action "Issue" | Worker `billing-pdf-generator` · `billing-email-sender` |
| `invoice_sent` | `{ invoice_id, email_message_id }` | Email-Versand erfolgt | Audit · `fact_history` |
| `invoice_overdue` | `{ invoice_id, days_overdue }` | Daily-Worker `dunning-cadence-check` | Reminders-Vollansicht · Dashboard |
| `dunning_sent` | `{ invoice_id, level, dunning_id }` | Mahnung versendet | Audit |
| `invoice_disputed` | `{ invoice_id, reason }` | UI-Action | Mahnungs-Timer-Pause |
| `payment_received` | `{ invoice_id, payment_id, amount }` | `fact_payment` INSERT | Worker `commission-engine-bridge` |
| `invoice_partially_paid` | `{ invoice_id, amount_paid, amount_open }` | `fact_payment` Teilzahlung | Audit |
| `invoice_paid` | `{ invoice_id }` | `amount_paid >= amount_gross` | Commission-Engine · Garantie-Timer-Start |
| `refund_eligibility_check` | `{ placement_id, exit_date, exit_reason }` | `fact_history: candidate_resigned/dismissed` | Refund-Cockpit-Notification |
| `refund_issued` | `{ refund_id, original_invoice_id, amount }` | GF-Approval + Issue | Commission-Engine-Clawback |
| `refund_paid` | `{ refund_id, valuta_date }` | Pain.001-Ausführung | Audit |
| `credit_note_issued` | `{ credit_note_id, invoice_id, amount }` | GF-Approval | Audit |
| `invoice_cancelled` | `{ invoice_id, reason }` | Storno | Commission-Clawback (falls ausbezahlt) |
| `invoice_written_off` | `{ invoice_id }` | Nach Inkasso-Fail | Audit · Buchhaltung |
| `inkasso_handed_over` | `{ invoice_id, inkasso_id, partner }` | GF-Approval | Audit |
| `mwst_quarter_snapshot_generated` | `{ quarter_start, gross_total }` | Cron 1. Tag nach Quartal | Admin-Notification |
| `treuhand_export_generated` | `{ month, year, file_path }` | Monatlicher Worker | Email-Notification Treuhand Kunz |
| `migration_import_completed` | `{ source, count, errors }` | Nach Altrechnungen-Import | Audit |

### 4.2 Saga: Refund-Issuance + Commission-Clawback

Atomisch (Backend-Architecture §Sagas-Pattern). Commission-Handling verzweigt auf `commission_primary_role` des betroffenen Placement-MAs (aus `fact_process_core.am_user_id` / `cm_user_id` / Research-Attribution).

```
Step 1: fact_refund.denied=false + amount_refunded_gross gesetzt
Step 2: fact_invoice neu mit type=refund · parent=original_invoice_id
Step 3: fact_invoice_audit-Entry (event_type=refund_issued)
Step 4: Event refund_issued + commission_clawback_triggered → Commission-Engine
Step 5: Commission-Engine verzweigt nach commission_primary_role:
        ├─ cm_am / head_of → negative fact_commission_ledger-Entry
        │   (proportional zu ursprünglicher forecast/pending_payment/paid_abschlag-Row)
        │   · Wenn Ledger-Status='paid_abschlag' → Rücklage reduziert ODER
        │     negativer Ledger-Eintrag im aktuellen Quartal
        │   · Wenn Ledger-Status='pending_payment' → UPDATE status='clawed_back'
        │   · Wenn Ledger-Status='forecast' → DELETE (war nie realisiert)
        ├─ researcher → fact_researcher_fee.status = 'clawed_back'
        │   (Pauschale-Clawback · 1:1, kein Staffel-Anteil)
        └─ none (z.B. GF-Placement) → Keine Aktion
Step 6: fact_refund.commission_clawback_triggered = true
Step 7: fact_refund.commission_clawback_at = now()

Compensation bei Fail: Steps 1–5 rollback · fact_refund.status = 'saga_failed' + Admin-Alert
```

**Event-Naming:** Sender `commission_clawback_triggered` (Billing → Commission). Commission-Engine-Spec v0.1 §5 subscribed unter diesem Namen (alter Name `ruecklage_clawback` deprecated per 2026-04-20).

---

## 5. Workers (Cron + Event-driven)

### 5.1 Event-driven Workers

| Worker | Trigger | Funktion |
|--------|---------|----------|
| `billing-draft-generator` | `invoice_triggered` / `akonto_invoice_triggered` / `zwischen_invoice_triggered` / `schluss_invoice_triggered` / `termination_invoice_triggered` / `invoice_triggered_assessment` | Erstellt `fact_invoice` Draft mit Auto-Fill (Kandidat · Honorar-Staffel-Satz · Adresse · Signer · MwSt) |
| `billing-pdf-generator` | `invoice_issued` / `credit_note_issued` / `refund_issued` / `dunning_sent` | Rendert 3-Seiten-PDF (Anschreiben · Tabelle · Blind-Copy+QR) · berechnet SHA-256-Hash · speichert in `pdf_path` |
| `billing-email-sender` | `invoice_issued` / `dunning_sent` | Versendet PDF via MS Graph mit User-Token des `issued_by`-Backoffice-MA |
| `commission-engine-bridge` | `payment_received` / `refund_issued` / `invoice_partially_paid` / `invoice_written_off` / `invoice_cancelled` | Queued Commission-Events in `fact_commission_event_queue` |
| `qr-bill-validator` | Pre-Issue (synchron) | Type-S-Compliance · MwSt-Pflicht · Betrag · Signer |
| `migration-excel-pdf-import` | Manueller Trigger (einmalig) | Liest Excel-Sheets + PDFs aus `raw/General/1_ Rechnungen & -sheets/` · erstellt `fact_invoice` mit `source='migration_excel'` |

### 5.2 Cron Workers

| Worker | Schedule | Funktion |
|--------|----------|----------|
| `dunning-cadence-check` | Daily 06:00 | Iteriert `v_invoice_dunning_queue` · bei `next_dunning_level_due` IS NOT NULL → Reminder-Row in `fact_reminders` für Backoffice (manueller Versand via Cockpit) |
| `time-mandate-monthly-invoice` | Monthly 1. Tag 06:00 | Iteriert aktive Time-Mandate · berechnet Wochen im Vormonat (pro rata) · erstellt Draft |
| `bank-statement-import` | Daily 07:00 (manuell getriggert wenn CSV-Upload) | Parst CAMT.054 · Auto-Match via QR-Ref/Amount/Fuzzy · legt `fact_payment` an · flagged unmatched für Review |
| `mwst-quarter-snapshot` | 1. Tag nach Quartalsende (01.04 · 01.07 · 01.10 · 01.01) | Aggregiert `v_mwst_quarter` · generiert ESTV-Report · email an Backoffice |
| `treuhand-export-monthly` | 1. Tag jedes Monats 07:00 | Generiert Bexio-CSV des Vormonats · email an Treuhand Kunz mit Attachment · markiert Rechnungen als `exported` |
| `refund-eligibility-daily` | Daily 05:00 | Prüft alle aktive Placements · `probezeit_end_date - today ≤ 14d` → Warn-Flag im Refund-Cockpit |
| `invoice-limitation-warning` | Daily 05:30 | Flagged offene Rechnungen mit `limitation_warning_at - today ≤ 90d` · notification an Backoffice+GF |
| `pdf-hash-verify-weekly` | Sunday 03:00 | Re-hashed PDFs aus `pdf_path` · vergleicht mit `pdf_hash_sha256` · bei Mismatch Alert GF (Revisionssicherheit) |
| `migration-status-daily` | Daily 08:00 | Bei laufender Migration: Fortschritt-Report |

---

## 6. REST-Endpoints

Prefix: `/api/v1/billing`

### 6.1 Rechnungen

| Method | Path | Funktion | Auth |
|--------|------|----------|------|
| GET | `/invoices` | Liste mit Filter-Query-Params | Backoffice+GF+AM(RLS) |
| POST | `/invoices` | Create Draft (manuell) | Backoffice+GF |
| GET | `/invoices/:id` | Detail | Backoffice+GF+AM(RLS) |
| PATCH | `/invoices/:id` | Update (nur Draft-Status) | Backoffice+GF |
| POST | `/invoices/:id/approve` | Approve · status=approved | Backoffice (Rabatt ≤ 20 %) oder GF |
| POST | `/invoices/:id/issue` | Issue · status=issued + PDF-Gen + Email | Backoffice+GF |
| POST | `/invoices/:id/cancel` | Storno (immer GF) | GF |
| POST | `/invoices/:id/dispute` | Markieren als Honorarstreit | Backoffice+GF |
| POST | `/invoices/:id/resolve-dispute` | Status-Update nach Streit | GF |
| GET | `/invoices/:id/pdf` | Download PDF | Backoffice+GF+AM(RLS) |
| GET | `/invoices/:id/audit` | Audit-Trail | Backoffice+GF+Admin |

### 6.2 Zahlungen

| Method | Path | Funktion |
|--------|------|----------|
| GET | `/payments` | Liste (Query: invoice_id, date-range) |
| POST | `/payments` | Manual Create (aus Drawer) |
| POST | `/payments/bank-import` | CAMT.054-Upload |
| GET | `/payments/unmatched` | Unmatched-Queue |
| PATCH | `/payments/:id` | Match bestätigen |

### 6.3 Mahnungen

| Method | Path | Funktion |
|--------|------|----------|
| GET | `/dunning/pending` | Pending-Queue (aus `v_invoice_dunning_queue`) |
| POST | `/dunning` | Mahnung auslösen (Einzel) |
| POST | `/dunning/bulk` | Bulk-Mahnung (mit Preview-Modal) |
| DELETE | `/dunning/:id` | Mahnung cancellen (bei Zahlungseingang) |

### 6.4 Refunds

| Method | Path | Funktion |
|--------|------|----------|
| GET | `/refunds` | Liste |
| POST | `/refunds/check-eligibility/:placement_id` | Eligibility-Check |
| POST | `/refunds` | Create (GF-Pflicht) |
| PATCH | `/refunds/:id/approve` | GF-Approval |
| POST | `/refunds/:id/deny` | Ablehnung mit Begründung |
| POST | `/refunds/:id/pay` | Auszahlung (Pain.001) |

### 6.5 Gutschriften

| Method | Path | Funktion |
|--------|------|----------|
| GET | `/credit-notes` | Liste |
| POST | `/credit-notes` | Create (GF-Pflicht) |

### 6.6 MwSt

| Method | Path | Funktion |
|--------|------|----------|
| GET | `/mwst/quarters/:quarter_start` | Aggregat |
| POST | `/mwst/quarters/:quarter_start/export` | PDF/CSV-Export |
| POST | `/mwst/quarters/:quarter_start/lock` | Quartal-Lock |

### 6.7 Inkasso

| Method | Path | Funktion |
|--------|------|----------|
| GET | `/inkasso` | Liste |
| POST | `/inkasso` | Übergabe anlegen (GF) |
| POST | `/inkasso/:id/dossier-export` | ZIP-Dossier-Download |
| PATCH | `/inkasso/:id` | Status/Recovery-Update |

### 6.8 Debitoren

| Method | Path | Funktion |
|--------|------|----------|
| GET | `/customers` | Liste (aus `v_customer_ledger`) |
| GET | `/customers/:id/ledger` | Kunden-Konto |
| PATCH | `/customers/:id/dunning-profile` | Kadenz-Profil ändern |

### 6.9 Treuhand-Export

| Method | Path | Funktion |
|--------|------|----------|
| GET | `/export/treuhand/history` | Bisherige Exports |
| POST | `/export/treuhand/:year/:month` | Neuen Export generieren |

### 6.10 Admin-Seeds

| Method | Path | Funktion |
|--------|------|----------|
| POST | `/admin/honorar-staffel` | Neue Staffel-Version seeden |
| POST | `/admin/migration/excel-pdf` | Migration starten (Worker-Trigger) |

---

## 7. Email-Templates (in `dim_email_templates`)

Alle Templates mit Textbaustein-Variablen `{{anrede_pronomen}}` / `{{anrede_verb}}` / `{{anrede_possessiv}}` für Sie/Du-Varianz.

| Template-Code | Zweck | Anrede-Support |
|---------------|-------|----------------|
| `invoice_erfolg` | Erfolgs-Rechnung Best-Effort | Sie + Du |
| `invoice_akonto` | Mandat Akonto | Sie + Du |
| `invoice_zwischen` | Mandat Zwischenrechnung | Sie + Du |
| `invoice_schluss` | Mandat Schlussrechnung | Sie + Du |
| `invoice_kuendigung` | Mandat-Kündigung | Sie + Du |
| `invoice_mandat_time_monthly` | Time-Mandat Monatsrechnung | Sie + Du |
| `invoice_optionale_stage` | Mandat-Sonderstage | Sie + Du |
| `invoice_assessment` | Assessment-Rechnung | Sie + Du |
| `invoice_bonus_schutzfrist` | §6-AGB-Schutzfrist-Bonus (generisch) | Sie + Du |
| `refund` | Rückerstattung | Sie + Du |
| `dunning_l1` | Mahnung Stufe 1 (höflich) | Sie + Du |
| `dunning_l2` | Mahnung Stufe 2 (bestimmter) | Sie + Du |
| `dunning_l3` | Mahnung Stufe 3 (scharf · Inkasso-Androhung) | Sie + Du |
| `credit_note` | Gutschrift | Sie + Du |
| `storno` | Storno | Sie + Du |
| `payment_reminder_soft` | Freundliche Zahlungserinnerung (T+5 optional) | Sie + Du |

**Anschreiben-Text** ist Template-spezifisch · AGB-Referenz (z.B. "gemäss AGB Ziffer 8") bleibt zur Template-Version-Zeit der Rechnung.

---

## 8. Pre-Issue-Validator

Synchron vor Status-Übergang `approved → issued`. Alle Checks müssen grün sein, sonst Issue blockiert.

| Check | Rule | Fehlermeldung |
|-------|------|---------------|
| Adress-Type-S-Compliance | `dim_accounts.legal_street_name`/`legal_house_number`/`legal_post_code`/`legal_town_name`/`iso_country_code` alle NOT NULL | "Kunde-Adresse unvollständig (Strasse/Hausnr/PLZ/Ort/Land) · QR-Pflicht SIX v2.3" |
| MwSt-Pflicht-Angaben | UID "CHE-463.920.799 MWST" auf Creditor · MwSt-Satz + Betrag auf Rechnung | "MwSt-Pflicht-Angaben fehlen (Art. 26 MWSTG)" |
| Betrag positiv | `amount_gross > 0` (ausser bei Refund < 0) | "Betrag muss > 0 sein" |
| Signer gesetzt | `signer_primary_id` + `signer_secondary_id` NOT NULL + Signatur-Bild vorhanden | "Signer-Signatur-Bild fehlt für {{signer_name}}" |
| Template-Version valide | `template_version` in `fact_template_versions` aktiv | "Template-Version {{version}} nicht aktiv" |
| QR-Referenz-Format | `qr_reference` matcht `dim_qr_reference_types.pattern` | "QR-Referenz-Format ungültig" |
| QR-IBAN-Konsistenz | `qr_iban IS NOT NULL` impliziert `reference_type = QRR` | "QR-IBAN erfordert QRR-Referenz" |
| Blind-Copy-Check | `privacy_mode = blind_copy_only` → Seite 3 hat keinen Kandidat-Klarnamen | "Blind-Copy-Pflicht verletzt" |
| Rabatt-Approval | `discount_pct > 20` erfordert GF-Approval | "Rabatt > 20 % erfordert GF-Genehmigung" |
| Rechnungs-Nr-Format | `invoice_nr ~ FN{YYYY}.{MM}.{####}` | "Rechnungs-Nr-Format ungültig" |

---

## 9. Migration-Runbook

### 9.1 Phasen

**Phase 0 · Vorbereitung (vor Billing-Go-Live):**
- [ ] Bestandskunden-Adress-Migration (Regex-Parser + manuelle Nachbesserung)
- [ ] `iso_country_code` auf 'CH' für alle CH-Kunden
- [ ] Honorar-Staffel-Seed `agb-feb-2023`
- [ ] Signatur-PNGs upload für Nenad + alle Bereichs-Heads
- [ ] Template-Version `agb-feb-2023` seeded in `fact_template_versions`
- [ ] Mandat-Vertrags-PDFs in `fact_mandate.contract_pdf_path` nachgepflegt
- [ ] Probezeit-Dauer in `fact_candidate_placement.probezeit_months` für aktive Placements

**Phase 1 · Altrechnungen-Import:**
- [ ] Worker `migration-excel-pdf-import` ausführen
- [ ] Review Fehler-Report (Rechnungen ohne PDF · Rechnungen ohne Excel-Match)
- [ ] Status `paid` vs. offen manuell verifizieren
- [ ] Hash-Compute-Check (SHA-256 konsistent)

**Phase 2 · Live-Schaltung:**
- [ ] Altsystem read-only setzen
- [ ] Rechnungs-Nr-Sequence 2026 ab nächster freier Nummer starten
- [ ] Backoffice-Training
- [ ] GF-Approval-Flow testen
- [ ] Erste Live-Rechnung generieren

### 9.2 Rollback-Plan

- Alle Edits über `fact_invoice_audit` trackable
- Bei Fehler: neues Draft via UI-Rollback-Action (GF-approve needed)
- Backup `dim_accounts_backup_pre_billing` für Adress-Rollback

---

## 10. UI-Patterns · Editorial-Style-Compliance

Referenz: `wiki/meta/mockup-baseline.md`.

| Pattern | Billing-Anwendung |
|---------|-------------------|
| Drawer 540px für CRUD | alle Erstellungs-/Detail-Drawer |
| Modal 420px für Confirms | Mahn-Versand · Storno-Bestätigung · Inkasso-Freigabe |
| Editorial-Font: Libre Baskerville für Titel, DM Sans für Body | Rechnungs-Editor-Drawer-Headers |
| Tab-Layout innerhalb Drawer | Rechnung-Detail (Positionen/Zahlungen/Mahnungen/Audit/PDF) |
| Sticky-Footer mit Aktions-Buttons | alle Drawer mit Issue/Cancel |
| Kalender-Picker + manuelle Tastatur-Eingabe für Datum-Felder | alle Datums-Felder (native `<input type="date">`) |
| Snapshot-Bar Header für Detail-Seiten | Debitor-Konto-Header (KPI-Bar) |
| Row-Click öffnet Detail-Drawer | Rechnungs-Liste · Debitoren-Liste · Refund-Cockpit |
| DB-Techdetails NIE in UI-Texten | "Offener Betrag" statt `amount_open`, "Kundenkonto" statt `fact_invoice` etc. |
| Deutsche Labels · Enums via `dim_*.label_de` | alle Status/Typ-Badges |

---

## 11. Stammdaten-UI-Labels · Canonical Mapping

Bindend für alle UI-Texte.

| Enum-Code | UI-Label DE | Kontext |
|-----------|-------------|---------|
| `draft` | Entwurf | Status-Badge |
| `approved` | Freigegeben | Status-Badge |
| `issued` | Versendet | Status-Badge |
| `partial` | Teilbezahlt | Status-Badge |
| `paid` | Bezahlt | Status-Badge |
| `overdue` | Überfällig | Status-Badge |
| `dunning_1/2/3` | Mahnung Stufe 1/2/3 | Status-Badge |
| `disputed` | Honorarstreit | Status-Badge |
| `gestundet` | Gestundet | Status-Badge |
| `collection_external` | Inkasso extern | Status-Badge |
| `debt_enforcement_pending` | Betreibung vorbereitet | Status-Badge |
| `payment_order_served` | Zahlungsbefehl zugestellt | Status-Badge |
| `legal_objection` | Rechtsvorschlag | Status-Badge |
| `rights_opening_required` | Rechtsöffnung nötig | Status-Badge |
| `cancelled` | Storniert | Status-Badge |
| `refunded` | Rückerstattet | Status-Badge |
| `written_off` | Abgeschrieben | Status-Badge |
| `erfolg` | Erfolgs-Rechnung | Typ-Badge |
| `akonto` | Akonto-Rechnung | Typ-Badge |
| `zwischen` | Zwischen-Rechnung | Typ-Badge |
| `schluss` | Schluss-Rechnung | Typ-Badge |
| `mandat_time_monthly` | Time-Mandat (monatlich) | Typ-Badge |
| `kuendigung` | Kündigungs-Rechnung | Typ-Badge |
| `optionale_stage` | Optionale Stage | Typ-Badge |
| `assessment` | Assessment-Rechnung | Typ-Badge |
| `bonus_schutzfrist` | Bonus · Schutzfrist | Typ-Badge |
| `refund` | Rückerstattung | Typ-Badge |
| `gutschrift` | Gutschrift | Typ-Badge |
| `storno` | Storno | Typ-Badge |
| `standard` | Standard-Kunde | Kadenz-Badge |
| `key_account` | Key-Account | Kadenz-Badge |
| `sie` / `du` | Sie-Form / Du-Form | Anrede-Toggle |
| `blind_copy_only` | Blind-Copy | Privacy-Badge |

Kein Enum-Code direkt im UI sichtbar (CLAUDE.md Keine-DB-Technikdetails-Regel).

---

## 12. Grundlagen-Sync-Checkliste (nach Interactions-v0.1-Freeze)

- [ ] `ARK_BACKEND_ARCHITECTURE_v2_6.md` → v2.7
  - §A Events: 26 neue Billing-Events (Abschnitt §4.1)
  - §B Workers: 11 neue (Abschnitt §5)
  - §Endpoints: `/api/v1/billing/*` (Abschnitt §6)
  - §Sagas: Refund-Issuance+Commission-Clawback (Abschnitt §4.2)
- [ ] `ARK_FRONTEND_FREEZE_v1_11.md` → v1.12
  - §4h Operations · Billing (neue Sektion analog §4f Email & Kalender)
  - 11 Top-Level-Routen
  - 10 Drawer-Specs + 1 Modal
  - UI-Label-Vocabulary
- [ ] `ARK_GESAMTSYSTEM_UEBERSICHT_v1_3.6.md` → v1.4
  - TEIL 25 Nachtrag · Billing-Modul

---

## 13. Test-Szenarien (Akzeptanz-Kriterien)

### 13.1 Happy-Path Best-Effort

1. Peter (AM) setzt Process auf Placement-Status · Rabatt 10 % bei Process eingetragen
2. System triggert `invoice_triggered` → Worker generiert Draft
3. Backoffice öffnet Drawer · Positionen auto-gefüllt · Staffel-Satz 25 % bei CHF 123'500 · Rabatt 10 % aus Process read-only
4. Approve → status=approved (Backoffice darf, da Rabatt < 20 %)
5. Issue → PDF generiert · Email versendet
6. 32 Tage später: CAMT.054-Import · Auto-Match 100 % Confidence
7. status=paid · Commission-Event queued · Garantie-Timer ab Stellenantritt

### 13.2 Mandat-Stage-Flow

1. Mandat signed · Akonto-Draft triggered · Betrag aus `stage_amounts_jsonb`
2. Alle 3 Stages auf Rechnung · Stage 1 fällig · Stage 2+3 "OFFENER POSTEN"
3. Payment · paid · Stage 2 im Backlog
4. Shortlist-Start · Zwischen-Draft · Stage 1 (paid) + Stage 2 (due) + Stage 3 (open_posten)
5. Placement · Schluss-Draft · Stage 1+2 paid + Stage 3 due
6. Commission-Event erst bei Schluss-Rechnung-Payment

### 13.3 Refund-Flow

1. Kandidat tritt aus in Probezeit-Monat 2
2. Kunde meldet 5 Tage nach Kandidat-Kündigung
3. Refund-Cockpit flagged `no_notification_3d` → GF-Override-Option
4. GF entscheidet Kulanz · Override mit Begründung
5. Refund-Betrag 25 % berechnet
6. GF approved · fact_refund created · Refund-Invoice generiert
7. Commission-Clawback-Event · MA-Rücklage reduziert
8. Pain.001-Export · Auszahlung an Kunden-IBAN

### 13.4 Mahnwesen-Segmentiert

1. Standard-Kunde · Rechnung T+0 issued · due T+30
2. Worker `dunning-cadence-check` T+15 (= days_to_l1 für standard) → flagged Mahnung 1 pending
3. Backoffice öffnet Mahnwesen-Cockpit · Bulk-Vorbereitung · Preview-Modal · 3 Rechnungen
4. Send → 3× `dunning_sent` Events · PDFs generiert + versendet
5. Key-Account identisch aber mit T+30/+45/+60 Kadenz

### 13.5 Migration Altrechnungen

1. Excel `Rechnungssheet_Best Effort.xlsx` hat 450 Zeilen · PDFs in `raw/General/1_ Rechnungen & -sheets/`
2. Worker läuft · matcht PDFs über Rechnungs-Nr · Hash-Compute
3. 420 Match · 30 Fehler (fehlendes PDF oder unbekannter Kunde)
4. Backoffice reviewt Fehler-Report · korrigiert manuell
5. Abschluss: 450 fact_invoice-Rows mit `source='migration_excel'` · Status `paid`

---

## 14. Next

- **Review durch Peter** (Plan v0.1 + Schema v0.1 + Interactions v0.1)
- **Open Q4 / Q11** nachziehen (System of Record + Team-Wechsel-Commission)
- **QR-Library-Version-Check** (schoero/swissqrbill v2.3/v2.4)
- **Commission-Engine-Spec v0.1** Event-Schnittstelle validieren
- **Mockup-Phase** nach Spec-Freeze: `mockups/ERP Tools/billing-*.html` · 11 Top-Level-Screens + 10 Drawer + 1 Modal

---

**Status v0.1 · Draft · Review-Ready.** Plan + Schema + Interactions = vollständiger Spec-Set v0.1 für Billing-Modul Phase-3-ERP.
