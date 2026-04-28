---
title: "Billing-Modul Research · Claude Code · v0.1"
type: source
created: 2026-04-20
updated: 2026-04-20
sources: ["Claude Code Opus 4.7 · In-Session Research"]
tags: [research, billing, phase3-erp, draft]
---

# Billing-Modul · Research v0.1 · Phase-3 ERP

**Stand:** 2026-04-20 · Arkadium AG, Zürich · MwSt CHE-463.920.799 · 8.1%
**Quelle:** Claude Code Opus 4.7 · strukturierte Research-Antwort auf 10-Sections-Prompt

---

## 1. LEGAL-FRAMEWORK

### 1.1 Schuldner-Verzug & Mahnwesen (OR Art. 102–109)

- **Art. 102 OR** — Verzug tritt ein bei (a) Mahnung nach Fälligkeit oder (b) kalendarisch bestimmter Leistungszeit (Zahlungsziel auf Rechnung reicht als Fälligkeitstermin, **Mahnung bleibt konstitutiv** für Verzug ausser bei vereinbartem Datum).
- **Art. 104 OR** — Verzugszins **5 %** p.a. gesetzlich; Vertragszins möglich (AGB-Klausel) — Arkadium AGB prüfen, ob höherer Zins vereinbart.
- **Art. 106 OR** — Schadenersatz bei höherem Verzugsschaden als Zins (z.B. Inkasso-Kosten).
- **Art. 107–109 OR** — Rücktritt vom Vertrag bei Verzug (für Billing irrelevant, Leistung ist bereits erbracht).

### 1.2 Auftragsrecht / Vermittlungsvertrag (OR Art. 394–406a)

- **Art. 394–406 OR** — einfacher Auftrag. Anwendbar auf Best-Effort-Headhunting (keine Erfolgsgarantie).
- **Art. 412–418 OR (Mäklervertrag)** — typischer Rechtsrahmen für Erfolgsbasis-Headhunting; Honorar nur bei **Kausalzusammenhang Vermittlung ↔ Abschluss**.
- **Art. 404 OR** — jederzeitiges Kündigungsrecht bei Auftrag (→ Mandat-Kündigung Rechnung nach Aufwand, bereits geleistet).
- **Arbeitsvermittlungsgesetz (AVG)** — Arkadium = Personalvermittler, bewilligungspflichtig (SECO), AVG Art. 9 begrenzt Vermittlungs-Gebühr gegenüber **Stellensuchendem** (nicht gegenüber Arbeitgeber). Headhunting-Honorar an Kunde = frei verhandelbar.

### 1.3 MwSt (MWSTG + MWSTV)

- **MWSTG Art. 10** — Registrierungspflicht ab **CHF 100k Jahresumsatz** (weltweit, nicht CH-only). Arkadium bereits registriert (CHE-463.920.799).
- **MwSt-Satz 8.1 %** (Normalsatz seit 01.01.2024) — MWSTG Art. 25.
- **MWSTG Art. 26** — Pflicht-Angaben auf Rechnung: (1) Name & Adresse Leistungserbringer + MwSt-Nr, (2) Name & Adresse Empfänger, (3) Datum, (4) Leistungsbeschreibung, (5) Entgelt, (6) Steuersatz + -betrag.
- **Reverse-Charge** (MWSTG Art. 45 ff.) — bei DE/AT-Kunden: Arkadium fakturiert **ohne CH-MwSt**, Hinweis "Steuerschuld geht auf Leistungsempfänger über" + ESTV-Meldung via Saldosteuersatz-Formular oder effektive Methode.
- **Quartals-Abrechnung** (MWSTG Art. 35) — 4× jährlich, 60 Tage nach Quartal-Ende; effektive Methode oder Saldosteuersatz-Methode (Arkadium prüfen).
- **Leistungsort-Regel (B2B)** — MWSTG Art. 8 Abs. 1 → Empfängerort-Prinzip: CH-Kunde = 8.1 %, EU-Kunde = 0 % + RC-Vermerk.

### 1.4 Datenschutz (DSG revDSG + DSGVO)

- **revDSG (seit 01.09.2023) Art. 6** — Datenminimierung. Kandidaten-Name auf Rechnung: nur wenn zur Zweckerfüllung nötig (Billing-Zuordnung).
- **Blind-Copy-Prinzip (Seite 3)** — bereits DSG-konform, da Kandidaten-Identität gegenüber Kunden-Buchhaltung anonymisiert.
- **DSGVO Art. 6 Abs. 1 f** — berechtigtes Interesse für Kandidaten-Name **im Anschreiben Seite 1** (Vertragsbezug), aber Minimierung auf Blind-Copy in Buchhaltungs-Seite empfohlen.
- **DSGVO Art. 30 (Verarbeitungsverzeichnis)** — Billing-System muss in VVT aufgenommen werden.
- **10-Jahres-Archivierung** (OR Art. 958f) vs. DSGVO-Löschrecht: **OR überwiegt** für Handelsdokumente, DSGVO Art. 17 Abs. 3 b erlaubt Speicherung wegen gesetzlicher Aufbewahrungspflicht.

### 1.5 Inkasso & Betreibung (SchKG)

- **SchKG Art. 38** — Geldforderung → Betreibung auf Pfändung/Konkurs (je nach Schuldner-Status).
- **SchKG Art. 67** — Betreibungsbegehren am Wohnsitz/Geschäftssitz Schuldner einreichen.
- **Inkasso-Kosten** — nach bundesgerichtlicher Praxis **nicht auf Schuldner überwälzbar** ausser bei expliziter AGB-Klausel + Kausalität nachweisbar.
- **Handelsrechtliche Sorgfaltspflicht** (OR 717 / AktG) — Abschreibung uneinbringlicher Forderungen erst nach **dokumentierten Eintreibungsversuchen** (Mahnstufen + Betreibung mind. versucht).

### 1.6 QR-Rechnung

- **SIX-Standard "Swiss QR Bill"** — Pflicht seit **30.09.2022** für alle CHF-/EUR-Zahlungen in CH.
- **QR-IBAN** (Konto 906447-4514 → IBAN CH07 0077 7009 0644 7451 4) — **QR-IBAN ist nicht gleich IBAN**: QR-IBAN nutzt Institut-ID "3…" statt "0…" für strukturierte Referenz (QRR). Arkadium-Bank abklären, ob QR-IBAN vorhanden oder SCOR-Referenz genutzt wird.
- **Referenz-Typen:** QRR (27-stellig, früher BESR/ESR), SCOR (Creditor Reference ISO 11649), NON (keine Referenz).
- **Pflicht-Felder:** Zahlungsteil + Empfangsschein, Perforations-Trennlinie, exakte Masse (105×210 mm Zahlteil).

### 1.7 Verjährung (OR Art. 127/128)

- **Art. 127 OR** — Regel: **10 Jahre**.
- **Art. 128 Ziff. 1 OR** — **5 Jahre** für "Forderungen für professionelle Dienstleistungen" (inkl. **Vermittler/Mäkler**). **→ Arkadium-Honorare verjähren 5 Jahre.**
- **Art. 135 OR** — Unterbrechung durch Betreibung/Klage/Schuldanerkennung → Verjährung startet neu.
- **Konsequenz:** System-Warnung spätestens 4 Jahre nach Rechnungsdatum bei offenen Forderungen, damit Fristunterbrechung rechtzeitig möglich.

---

## 2. STAMMDATEN-DELTAS

Neue Einträge für `ARK_STAMMDATEN_EXPORT` §?? (nächste Version nach Zeit-Modul §90, also §91 Billing-Modul-Stammdaten).

### 2.1 `dim_invoice_types`

| Code | Label | Verwendung |
|------|-------|------------|
| `akonto` | Akonto-Rechnung | Mandat Stage 1 |
| `zwischen` | Zwischen-Rechnung | Mandat Stage 2 (Shortlist) |
| `schluss` | Schluss-Rechnung | Mandat Stage 3 (Placement) |
| `erfolg` | Erfolgsrechnung | Best-Effort Placement |
| `kuendigung` | Kündigungs-Rechnung | Mandat-Abbruch, Aufwand-basiert |
| `optionale_stage` | Optionale Stage | Sonder-Aufwand (4. Stage) |
| `refund` | Rückerstattung | Garantie-Fall 100 % / Staffel |
| `storno` | Storno | vollständige Annullierung |
| `gutschrift` | Gutschrift | Teil-Korrektur (Fehler/Kulanz) |
| `mahngebuehr` | Mahngebühr | falls eingeführt (TBD) |

### 2.2 `dim_invoice_status`

| Code | Label | Endzustand |
|------|-------|-----------|
| `draft` | Entwurf | nein |
| `issued` | Versendet | nein |
| `partial` | Teilbezahlt | nein |
| `paid` | Bezahlt | ja |
| `overdue` | Überfällig | nein |
| `dunning_1` | Mahnstufe 1 | nein |
| `dunning_2` | Mahnstufe 2 | nein |
| `dunning_3` | Mahnstufe 3 | nein |
| `inkasso` | Inkasso-Übergabe | nein |
| `written_off` | Abgeschrieben | ja |
| `stunded` | Gestundet | nein |
| `disputed` | Honorarstreit | nein |
| `cancelled` | Storniert | ja |
| `refunded` | Rückerstattet | ja |

### 2.3 `dim_payment_methods`

| Code | Label |
|------|-------|
| `qr` | QR-Überweisung |
| `bank_transfer` | Bank-Überweisung (klassisch, ohne QR-Ref) |
| `credit_card` | Kreditkarte (falls Stripe-Integration) |
| `twint_business` | TWINT Business |
| `cash` | Barzahlung (Edge-Case) |
| `compensation` | Verrechnung (interne Buchung) |

### 2.4 `dim_mwst_codes`

| Code | Rate | Verwendung |
|------|------|-----------|
| `std_81` | 8.1 % | Normalsatz CH |
| `red_26` | 2.6 % | Reduziert (für Billing irrelevant, vollständigkeitshalber) |
| `rc_0` | 0 % | Reverse Charge (EU) |
| `exempt` | — | MwSt-befreit (z.B. Auslandsleistung ausserhalb EU) |

### 2.5 `dim_dunning_reasons` / `dim_credit_note_reasons`

| Reason-Code | Bereich | Label |
|-------------|---------|-------|
| `error_billing` | Gutschrift | Rechnungs-Fehler (Betrag/Position) |
| `error_customer` | Gutschrift | Falscher Kunde/Adresse |
| `kulanz` | Gutschrift | Kulanz-Gutschrift |
| `dispute_resolved` | Gutschrift | Honorarstreit-Vergleich |
| `late_payment` | Mahnung | Zahlungsverzug |
| `partial_payment` | Mahnung | Teilzahlung unter Soll |

### 2.6 `dim_refund_reason_codes` (Garantie-Fall · routing zu `business_model`)

| Code | Trigger | Business-Model | Aktion |
|------|---------|----------------|--------|
| `candidate_resign_lt_30d` | MA kündigt < 30 Tagen | erfolgsbasis | 100 % Refund ODER Ersatz |
| `candidate_resign_30_60d` | 30–60 Tage | erfolgsbasis | 66 % Refund (TBD) |
| `candidate_resign_60_90d` | 60–90 Tage | erfolgsbasis | 33 % Refund (TBD) |
| `candidate_dismissal_lt_90d` | Kunde kündigt MA in Garantie | erfolgsbasis | Ersatz (primär) oder Refund |
| `mandate_early_exit` | MA verlässt in Garantie (Mandat) | mandat | **Ersatz** (kein Refund) |
| `time_exit_na` | Time-Basis-Mandat | time | **keine Garantie** |

(Staffel-Prozentsätze sind offen — siehe §9 Q7.)

### 2.7 `dim_signers` (für Anschreiben Seite 1)

Bereits teil-vorhanden via `project_arkadium_roles_2026.md`. Billing ergänzt:
- **Founder-Slot (fix):** Nenad Stoparanovic
- **Bereichs-Signer:** Head CE&BT = PW, Stv. = JV, weitere Sparten analog (aus Roles-Matrix).
- **Fallback-Rule:** bei Abwesenheit Signer → Stv. einsetzen (Regel konfigurierbar in `dim_signer_rules`).

### 2.8 `dim_tone_of_voice` (Sie / Du)

| Code | Label |
|------|-------|
| `sie` | Sie-Form (Default) |
| `du` | Du-Form |

Pro Kunde zu setzen in `dim_accounts.tone_of_voice`.

---

## 3. SCHEMA-DELTAS

DDL-Entwurf für `ARK_DATABASE_SCHEMA` v1.5 (post-Zeit-Modul v1.4). Kurz-Fassung, vollständige Constraints + Indexe in Spec v0.1 nachziehen.

### 3.1 `fact_invoice`

```sql
CREATE TABLE fact_invoice (
  invoice_id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  invoice_nr           text UNIQUE NOT NULL,  -- FN2026.03.0917
  invoice_type         text NOT NULL REFERENCES dim_invoice_types(code),
  customer_id          uuid NOT NULL REFERENCES dim_accounts(account_id),
  process_id           uuid REFERENCES fact_process_core(process_id),   -- Best-Effort + Mandat-Schluss
  mandate_id           uuid REFERENCES fact_mandate(mandate_id),         -- Mandat-Akonto/Zwischen
  stage_nr             smallint,                   -- 1/2/3/4 bei Mandat, NULL sonst
  parent_invoice_id    uuid REFERENCES fact_invoice(invoice_id),        -- Storno/Gutschrift/Refund
  business_model       text NOT NULL,              -- erfolgsbasis/mandat_target/mandat_taskforce/mandat_time
  signer_primary_id    uuid NOT NULL REFERENCES dim_mitarbeiter(mitarbeiter_id),  -- Founder
  signer_secondary_id  uuid NOT NULL REFERENCES dim_mitarbeiter(mitarbeiter_id),  -- Bereichs-Head
  tone_of_voice        text NOT NULL DEFAULT 'sie', -- sie/du
  language             text NOT NULL DEFAULT 'de',
  currency             char(3) NOT NULL DEFAULT 'CHF',
  amount_net           numeric(14,2) NOT NULL,
  mwst_code            text NOT NULL REFERENCES dim_mwst_codes(code),
  mwst_rate            numeric(5,2) NOT NULL,      -- 8.10 / 0.00
  mwst_amount          numeric(14,2) NOT NULL,
  amount_gross         numeric(14,2) NOT NULL,
  qr_iban              text,                       -- QR-IBAN (Pflicht bei QRR)
  qr_reference_type    text NOT NULL DEFAULT 'QRR', -- QRR/SCOR/NON
  qr_reference         text,                       -- 27-stellig QRR
  issued_at            date,
  due_at               date,
  paid_at              date,
  status               text NOT NULL REFERENCES dim_invoice_status(code),
  pdf_path             text,                       -- Archiv 10J
  blind_copy_flag      boolean NOT NULL DEFAULT true,
  template_version     text NOT NULL,
  notes_internal       text,
  created_by           uuid NOT NULL REFERENCES dim_mitarbeiter(mitarbeiter_id),
  created_at           timestamptz NOT NULL DEFAULT now(),
  updated_at           timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT inv_mandat_stage CHECK (
    (invoice_type IN ('akonto','zwischen','schluss','optionale_stage') AND stage_nr IS NOT NULL)
    OR (invoice_type NOT IN ('akonto','zwischen','schluss','optionale_stage'))
  ),
  CONSTRAINT inv_mwst_rc CHECK (
    (mwst_code = 'rc_0' AND mwst_amount = 0) OR (mwst_code <> 'rc_0')
  )
);

CREATE INDEX ix_invoice_customer ON fact_invoice(customer_id);
CREATE INDEX ix_invoice_process  ON fact_invoice(process_id);
CREATE INDEX ix_invoice_mandate  ON fact_invoice(mandate_id);
CREATE INDEX ix_invoice_status_due ON fact_invoice(status, due_at);
CREATE UNIQUE INDEX ux_invoice_nr ON fact_invoice(invoice_nr);
```

### 3.2 `fact_invoice_item`

```sql
CREATE TABLE fact_invoice_item (
  item_id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  invoice_id      uuid NOT NULL REFERENCES fact_invoice(invoice_id) ON DELETE CASCADE,
  position        smallint NOT NULL,
  candidate_id    uuid REFERENCES dim_candidates(candidate_id),  -- nur bei Erfolgsrechnung/Refund
  job_role_label  text,                     -- Funktion/Rolle (freitext für Historie)
  sparte_code     text REFERENCES dim_sparten(code),
  description     text NOT NULL,
  quantity        numeric(10,2) NOT NULL DEFAULT 1,
  unit_price_net  numeric(14,2) NOT NULL,
  discount_pct    numeric(5,2) NOT NULL DEFAULT 0,
  honorarsatz_pct numeric(5,2),             -- bei Erfolgsbasis
  total_compensation numeric(14,2),          -- Basis Erfolgsbasis-Honorar
  total_net       numeric(14,2) NOT NULL,   -- (qty × unit × (1 - disc))
  mwst_code       text NOT NULL REFERENCES dim_mwst_codes(code),
  is_open_posten  boolean NOT NULL DEFAULT false,  -- "OFFENER POSTEN" in Mandat-Stage
  UNIQUE (invoice_id, position)
);
```

### 3.3 `fact_payment`

```sql
CREATE TABLE fact_payment (
  payment_id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  invoice_id          uuid NOT NULL REFERENCES fact_invoice(invoice_id),
  amount              numeric(14,2) NOT NULL,
  currency            char(3) NOT NULL DEFAULT 'CHF',
  payment_date        date NOT NULL,
  payment_method      text NOT NULL REFERENCES dim_payment_methods(code),
  qr_reference        text,                     -- vom Bank-Import gematched
  bank_booking_jsonb  jsonb,                    -- CAMT.053-Raw-Daten
  bank_account        text,
  is_auto_matched     boolean NOT NULL DEFAULT false,
  matched_by          uuid REFERENCES dim_mitarbeiter(mitarbeiter_id),
  matched_at          timestamptz,
  reversal_of         uuid REFERENCES fact_payment(payment_id),   -- Storno-Zahlung
  created_at          timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX ix_payment_invoice ON fact_payment(invoice_id);
CREATE INDEX ix_payment_qr_ref  ON fact_payment(qr_reference);
CREATE INDEX ix_payment_date    ON fact_payment(payment_date);
```

### 3.4 `fact_dunning`

```sql
CREATE TABLE fact_dunning (
  dunning_id       uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  invoice_id       uuid NOT NULL REFERENCES fact_invoice(invoice_id),
  level            smallint NOT NULL CHECK (level BETWEEN 1 AND 3),
  issued_at        date NOT NULL,
  deadline         date NOT NULL,
  fee              numeric(10,2) NOT NULL DEFAULT 0,
  interest_rate    numeric(5,2) NOT NULL DEFAULT 5.00,
  interest_amount  numeric(14,2) NOT NULL DEFAULT 0,
  pdf_path         text,
  sent_by          uuid NOT NULL REFERENCES dim_mitarbeiter(mitarbeiter_id),
  cancelled_at     timestamptz,                -- falls nach Versand Zahlung eingeht
  UNIQUE (invoice_id, level)
);
```

### 3.5 `fact_credit_note` / `fact_refund` / `fact_inkasso`

```sql
CREATE TABLE fact_credit_note (
  credit_note_id   uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  invoice_id       uuid NOT NULL REFERENCES fact_invoice(invoice_id),
  reason_code      text NOT NULL REFERENCES dim_credit_note_reasons(code),
  amount_net       numeric(14,2) NOT NULL,
  mwst_amount      numeric(14,2) NOT NULL,
  amount_gross     numeric(14,2) NOT NULL,
  issued_at        date NOT NULL,
  approved_by      uuid NOT NULL REFERENCES dim_mitarbeiter(mitarbeiter_id),
  requires_gf_approval boolean NOT NULL DEFAULT false,  -- ab CHF 5'000
  linked_new_invoice_id uuid REFERENCES fact_invoice(invoice_id)   -- bei Storno+Neu
);

CREATE TABLE fact_refund (
  refund_id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  original_invoice_id uuid NOT NULL REFERENCES fact_invoice(invoice_id),
  refund_invoice_id  uuid NOT NULL REFERENCES fact_invoice(invoice_id),   -- neue Invoice mit type=refund
  reason_process_id  uuid REFERENCES fact_process_core(process_id),       -- Early-Exit-Prozess
  reason_code        text NOT NULL REFERENCES dim_refund_reason_codes(code),
  business_model     text NOT NULL,     -- routing gate
  staffel_pct        numeric(5,2),       -- 100/66/33 etc.
  amount_refunded_net numeric(14,2) NOT NULL,
  mwst_amount        numeric(14,2) NOT NULL,
  amount_refunded_gross numeric(14,2) NOT NULL,
  valuta_date        date,
  approved_by        uuid NOT NULL REFERENCES dim_mitarbeiter(mitarbeiter_id),
  paid_at            date,
  commission_clawback_triggered boolean NOT NULL DEFAULT false
);

CREATE TABLE fact_inkasso (
  inkasso_id      uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  invoice_id      uuid NOT NULL REFERENCES fact_invoice(invoice_id),
  partner_name    text NOT NULL,
  handed_over_at  date NOT NULL,
  expected_recovery numeric(14,2),
  recovered       numeric(14,2) NOT NULL DEFAULT 0,
  fee_expected    numeric(14,2),
  status          text NOT NULL,           -- sent/in_progress/recovered/written_off
  closed_at       date
);
```

### 3.6 Views

- `v_invoice_open` — alle nicht-bezahlten, Aging-Buckets (0–30 / 31–60 / 61–90 / 90+).
- `v_invoice_dunning_queue` — pending Mahnstufen nach `due_at`.
- `v_mwst_quarter` — aggregiert `amount_net`, `mwst_amount` nach Quartal × MwSt-Code.
- `v_customer_ledger` — pro Kunde: Invoices + Payments + Saldo.
- `v_refund_clawback` — offene Commission-Clawbacks aus Refunds.

---

## 4. PROZESS-FLOWS

### 4.1 Best-Effort-Flow

```
Process Stage Placement  (fact_process_core.stage = 'placement')
 ↓ event: invoice_triggered
Invoice-Draft (status=draft, type=erfolg)
 ↓ user: Backoffice reviewt + issued
Invoice-Issued (status=issued, PDF generiert, QR embedded, versendet)
 ↓ event: invoice_issued
Payment eingeht (Bank-Import → Auto-Match via QRR)
 ↓ event: payment_received
Invoice-Paid (status=paid)
 ↓ event: guarantee_timer_started (3 Mt)
Commission-Payout-Scheduled (80% Abschlag, 20% Rücklage)
```

### 4.2 Mandat-Flow (Target / Taskforce / Time)

```
Mandat-Signature  (fact_mandate.status = 'signed')
 ↓ event: mandate_signed
Auto-Draft Akonto-Invoice (stage_nr=1, type=akonto) — fix CHF 10k? (Q5)
 ↓ issued → payment → paid
Trigger Shortlist-Start (process_core.stage = 'cv_sent' ≥ N candidates)
 ↓ event: shortlist_reached
Auto-Draft Zwischen-Invoice (stage_nr=2, type=zwischen)
 ↓ issued → payment → paid
Placement (process_core.stage = 'placement')
 ↓ event: placement_confirmed
Auto-Draft Schluss-Invoice (stage_nr=3, type=schluss)
 ↓ issued → payment → paid
Commission-Berechnung **nur auf Schluss-Invoice** (Stages 1+2 sind reine Akonto, keine Provision)
```

Time-Mandat: periodische Rechnung monatlich gemäss Zeiterfassung → Kopplung an Zeit-Modul (v0.1 vorhanden).

### 4.3 Refund-Flow (Garantie-Fall)

```
Early-Exit-Event (fact_history: candidate_resigned | candidate_dismissed, innerhalb 90 Tagen post-Placement)
 ↓ router: business_model
  ├─ erfolgsbasis → Refund-Staffel-Calc (lt/30/60/90d) → Refund-Invoice ODER Ersatz-Suche
  ├─ mandat_*    → Ersatz-Suche (kein Refund-Default)
  └─ time        → keine Aktion
 ↓ Refund-Invoice erstellt (type=refund, parent_invoice_id = original)
 ↓ approved_by GF (Pflicht)
 ↓ issued + valuta_date
 ↓ reverse payment (amount negativ in fact_payment)
 ↓ event: commission_clawback_triggered
 ↓ Commission-Engine zieht Provision retroaktiv zurück (aus Rücklage 20%)
```

### 4.4 Mahnwesen

```
Invoice.status = issued, due_at + 0d   → überfällig-Flag (nur intern)
due_at + 5d                             → Pre-Mahnung Email (automatisch, Reminder)
due_at + 14d (TBD)                      → Mahnung 1 (dunning_1, neue Frist 5d)
dunning_1.deadline + 15d                → Mahnung 2 (dunning_2, Ton schärfer)
dunning_2.deadline + 15d                → Mahnung 3 (dunning_3, letzte Frist 5d)
dunning_3.deadline + 5d                 → Inkasso-Eskalation (GF approval, fact_inkasso)
```

Rechnungs-AGB-Zeitachse validieren — aktuelle Arkadium-Praxis: T+30/+45/+60/+90.

### 4.5 Honorarstreit

```
Kunde-Reklamation (email, call) → manuell gesetzt: status=disputed
 ↓ Mahnungs-Timer pausiert
 ↓ GF-Eskalation, Meeting, ggf. Teil-Gutschrift
 ↓ Resolution: (a) paid-full / (b) gutschrift+neue_invoice / (c) storno / (d) inkasso wenn unbegründet
```

### 4.6 Gutschrift / Storno

```
Storno (vollständige Annullierung)
 ↓ fact_credit_note mit amount_gross = -invoice.amount_gross
 ↓ original invoice.status = cancelled
 ↓ Commission-Clawback falls Commission schon ausbezahlt

Gutschrift (Teil-Korrektur)
 ↓ fact_credit_note mit partial amount
 ↓ optional linked_new_invoice_id → neue korrigierte Invoice
 ↓ original bleibt issued/paid mit Vermerk
```

### 4.7 MwSt-Quartals-Abrechnung

```
Quartal-Ende (31.03 / 30.06 / 30.09 / 31.12)
 ↓ Worker generiert v_mwst_quarter-Aggregat
 ↓ Export ESTV-Formular (PDF oder ESTV SuisseTax eCH-0217)
 ↓ Review Backoffice + GF
 ↓ Einreichung + Zahlung innerhalb 60d
```

---

## 5. BUSINESS-LOGIC

### 5.1 Rechnungsnummer-Generator

Format: `FN{YYYY}.{MM}.{####}` · Zähler `####` ist **jahresweise fortlaufend** (nicht monatsweise), d.h. `FN2026.01.0001 → FN2026.12.0917`. Concurrency via PostgreSQL-Sequence `seq_invoice_yyyy` pro Jahr, oder advisory-lock-Pattern.

### 5.2 QR-Code-Generierung

- In-house-Library-Option: **manuelbl/swiss-qr-bill** (Java) oder **schoero/swiss-qr-bill** (TypeScript) — MIT-Lizenz, SIX-zertifiziert.
- Payload: Version 02.00 · Currency CHF · Amount · Creditor (Arkadium Name+IBAN+Adresse) · Reference Type QRR/SCOR · Reference 27-stellig · Debtor (optional).
- **QRR-Berechnung:** 26 numerische Stellen + Modulo-10-Recursive-Prüfziffer. Encoding-Muster: `FN{YYYYMMNNNN} → 26 Digits` (FN aus Rechnungs-Nr, mit führenden Nullen aufgefüllt, Prüfziffer als 27.).

### 5.3 Bank-Zahlung-Auto-Match

- Import CAMT.053 (XML, täglich) ODER CSV-Upload.
- Match-Priorität:
  1. **QRR/SCOR-Referenz** → `fact_invoice.qr_reference` exact-match → `is_auto_matched=true`.
  2. **Amount + Customer-IBAN** → wenn eindeutig auf eine offene Invoice → Vorschlag zur Bestätigung.
  3. **Manuell** → Zahlungs-Erfassen-Drawer.
- Teilzahlung: `sum(fact_payment.amount) < fact_invoice.amount_gross` → `status=partial`.
- Überzahlung: Vermerk + GF-Alert, kein Auto-Refund.

### 5.4 Honorar-Berechnung (Erfolgsbasis)

```
total_compensation = annual_salary + variable_components (Bonus, 13. ML, etc.)
honorar_net = total_compensation × honorarsatz_pct × (1 - discount_pct)
mwst_amount = honorar_net × 0.081
honorar_gross = honorar_net + mwst_amount
```

Beispiel aus Kontext: 123'500 × 25 % = 30'875 + 2'500.90 = 33'375.90 CHF.

### 5.5 Mandat-Stage-Logik

- Alle drei Stages **auf jeder Stage-Rechnung** aufgeführt (Positions), nur **aktive** Stage mit Betrag, andere `is_open_posten=true` (Display "OFFENER POSTEN").
- Stage-Beträge: fix pro Mandat bei Vertragsabschluss verhandelt, in `fact_mandate.stage_amounts_jsonb` gespeichert.

### 5.6 Refund-Staffel (Best-Effort, Garantie-Fall)

Aktueller Kenntnisstand: **100 % linear** (Arkadium-Praxis sieht Staffel nicht im Template). Vorschlag Modellierung:

| Early-Exit-Zeitpunkt | Refund-% |
|----------------------|----------|
| 0–30 Tage post-Placement | 100 % |
| 31–60 Tage | 66 % |
| 61–90 Tage | 33 % |
| > 90 Tage | 0 % (ausserhalb Garantie) |

**Parametrisieren** in `dim_refund_reason_codes` pro Code. PO-Entscheid offen (Q7).

### 5.7 State-Machine Invoice

```
draft → issued → partial ↔ paid
        issued → overdue → dunning_1 → dunning_2 → dunning_3 → inkasso → written_off
        (jede Stufe kann → paid springen bei Zahlungseingang)
        (alle → cancelled via Storno)
        paid → refunded (bei Garantie-Fall)
```

Invariante: `cancelled`, `paid`, `refunded`, `written_off` sind **End-Zustände** (kein Rückweg ohne neue Invoice).

### 5.8 Commission-Billing-Kopplung

- **Commission-Trigger:** nur bei `invoice.status = paid` **und** `business_model = erfolgsbasis` ODER `stage_nr = 3` bei Mandat.
- **Payout-Schedule:** 80 % Abschlag bei `payment_received`, 20 % Rücklage 90 Tage (Garantie-Ablauf).
- **Clawback:** bei `fact_refund` → `commission_clawback_triggered=true` → Rücklage reduziert oder bei bereits ausbezahlten 80 % negative Provisions-Position in nächster MA-Abrechnung.
- **Mandat-Stages 1+2:** keine Commission (reine Akonto, kein Placement).

---

## 6. UI-ARCHITEKTUR

### 6.1 Screen-Inventory (Top-Level-Routen)

| Route | Screen | Zweck |
|-------|--------|-------|
| `/billing` | Billing-Dashboard | KPIs, Aging, Mahn-Pipeline, MwSt-Stand |
| `/billing/rechnungen` | Rechnungs-Liste | Filter/Bulk-Actions/Search |
| `/billing/rechnungen/:id` | Rechnung-Detail | Deep-Link, Edit-Entry |
| `/billing/mahnwesen` | Mahnwesen-Cockpit | pending Stufen, Bulk-Mahn-Versand |
| `/billing/kreditoren/:customerId` | Kreditoren-Ansicht | Kunden-Saldo, Zahlungshistorie |
| `/billing/zahlungen` | Zahlungseingang | Bank-Import, Auto-Match-Review |
| `/billing/mwst` | MwSt-Abrechnung | Quartals-Report, ESTV-Export |
| `/billing/refunds` | Refund-Cockpit | Garantie-Fälle, Staffel-Preview |

### 6.2 Drawer-Inventory (540px per Default)

| Drawer | Zweck | Besonderheit |
|--------|-------|--------------|
| Rechnung-Detail | Tab-Layout: Positionen · Zahlungen · Mahnungen · Audit | Audit-Tab via `fact_history`-Events |
| Rechnung-Erstellen | Multi-Step: Kunde → Process/Mandat → Positionen → MwSt → QR-Preview → Issue | Auto-Fill aus `fact_process_core`/`fact_mandate` |
| Gutschrift-Erstellen | Rechnung-Auswahl + Grund + Betrag + GF-Approval falls ≥ CHF 5k | — |
| Zahlung-Erfassen | Manuell-Fallback, QR-Ref-Vorschlag | — |
| Refund-Berechnung | Staffel-Preview + GF-Confirm | routing auf business_model |
| Mandat-Stage-Trigger | Zwischenrechnung auslösen | bei Shortlist-Reached-Event |
| Bank-Import | CAMT.053-Upload + Preview | Zahlungs-Erfassen gruppen-weise |
| Honorar-Streit-Drawer | Markieren + Notiz + Mahnungs-Pause | — |

### 6.3 Modal-Inventory (nur Confirms, max 420px)

- **Mahnung-Senden** — Preview + Confirm (Bulk-Modus: Liste der Rechnungen).
- **Storno-Bestätigen** — unumkehrbar, Doppel-Confirm.
- **Inkasso-Übergabe** — GF-Approval-Pflicht, Warnung zu Reputations-Impact.

Alles andere = Drawer (CLAUDE.md Drawer-Default-Regel).

### 6.4 Dashboard-Widgets

- **KPIs oben:** Offen / Überfällig / Bezahlt YTD / MwSt-Debitor-Soll Q.
- **Aging-Chart:** 0–30 / 31–60 / 61–90 / 90+.
- **Top-10-Kreditoren** mit Ampel.
- **Mahn-Pipeline:** # Rechnungen pro Mahnstufe.
- **Refund-Warn-Liste:** Garantie läuft in ≤ 14d ab.

### 6.5 Rechnungs-Editor-Besonderheiten

- **Positionen:** Best-Effort = 1 Position (Honorar) · Mandat = 3 Positionen (Stages) · Refund = 1 Position (Bezahlte Summe + Rückvergütung-%).
- **QR-Preview live** bei Betrags-Änderung (Seite 3 Render).
- **Blind-Copy-Toggle** pro Kunde default-an (DSG).
- **Tone-of-Voice-Toggle** Sie/Du (aus `dim_accounts.tone_of_voice`, aber manuell overridebar).
- **Signer-Dropdown** mit Rolle-Label (z.B. "Peter Wiederkehr · Head CE&BT").

### 6.6 Datum-Inputs

Pflicht: `<input type="date">` mit Kalender-Picker UND manueller Tastatur-Eingabe (CLAUDE.md Datum-Eingabe-Regel).

### 6.7 DB-Techdetails-Maskierung

UI-Labels ausschliesslich sprechend: "Rechnungs-Nr", "Kunde", "Zahlungsziel", "Mahnstufe" — **keine** `fact_invoice.invoice_nr`, `dim_invoice_status.code` etc. (CLAUDE.md Keine-DB-Technikdetails-Regel).

---

## 7. ROLLEN-MATRIX

Abgleich mit `project_arkadium_roles_2026.md` · 3+1 Kern-Rollen (AM, CM, Researcher, Admin) + Commission-Engine-Rollen. Billing ergänzt Backoffice, GF, Treuhand.

| Feature | AM | CM | Researcher | Backoffice | Head/GF | Treuhand (RO) | Admin |
|---------|----|----|------------|------------|---------|---------------|-------|
| Rechnung erstellen (Draft) | – | – | – | ✓ | ✓ | – | – |
| Rechnung issued (Versand) | – | – | – | ✓ | ✓ | – | – |
| Mahnung Stufe 1 auslösen | – | – | – | ✓ | ✓ | – | – |
| Mahnung Stufe 2/3 | – | – | – | ✓ | ✓ | – | – |
| Gutschrift < CHF 5'000 | – | – | – | ✓ | ✓ | – | – |
| Gutschrift ≥ CHF 5'000 | – | – | – | – | ✓ | – | – |
| Storno | – | – | – | – | ✓ | – | – |
| Refund ausstellen | – | – | – | – | ✓ | – | – |
| Inkasso-Übergabe | – | – | – | – | ✓ | – | – |
| Rechnungs-Liste sehen | ✓ | ✓ | – | ✓ | ✓ | – | ✓ |
| Eigene Kunden-Zahlungen sehen | ✓ (own) | ✓ (own) | – | ✓ | ✓ | – | ✓ |
| Bank-Import durchführen | – | – | – | ✓ | ✓ | – | – |
| Zahlung-Erfassen manuell | – | – | – | ✓ | ✓ | – | – |
| Treuhand-Export generieren | – | – | – | ✓ | ✓ | ✓ (RO) | – |
| MwSt-Abrechnung finalisieren | – | – | – | ✓ | ✓ | ✓ (RO) | – |
| Commission-Clawback auslösen | – | – | – | – | ✓ | – | – |
| Audit-Log einsehen | – | – | – | ✓ | ✓ | ✓ (RO) | ✓ |

**Anmerkung:** AM/CM sehen **nur eigene Kunden** (Row-Level-Security über `dim_accounts.owner_am_id` / `owner_cm_id`). Researcher hat keinen Billing-Zugriff.

---

## 8. INTEGRATIONEN

### 8.1 CRM-interne Kopplung

| Quelle | Ziel | Event |
|--------|------|-------|
| `fact_process_core.stage = placement` | Billing | `invoice_triggered` (Best-Effort Draft) |
| `fact_mandate.status = signed` | Billing | `akonto_invoice_triggered` |
| `fact_process_core.stage = cv_sent` + N Candidates | Billing | `zwischen_invoice_triggered` |
| Billing · `payment_received` | Commission-Engine | `commission_calculation_triggered` |
| Billing · `refund_issued` | Commission-Engine | `commission_clawback_triggered` |
| Billing · `invoice_overdue` | Reminders | Reminder-Row für AM/Backoffice |

### 8.2 Email (Outlook via MS Graph · individual tokens)

- Rechnungs-PDF-Versand via Outlook-Token des **versendenden Backoffice-MA** (nicht Shared-Mailbox — per Entscheidung 2026-04-17).
- Template-basiert, aus `dim_email_templates` (Referenz Email-Kalender-Modul).
- Empfänger: Rechnungs-Empfänger-Kontakt aus `dim_accounts.contacts` mit Rolle "Buchhaltung" oder "Fakturierung".
- Versand-Event → `fact_history` entity=invoice, activity_type=emailverkehr-rechnung-versand.

### 8.3 QR-Bill-Library

**Empfehlung:** `schoero/swiss-qr-bill` (TypeScript, Node, SSR-tauglich, SIX-zertifiziert).
Alternative: eigene Render-Pipeline mit Standard-Lib (PDFKit + SIX-Spec), aber überflüssiger Eigenaufwand.

### 8.4 Bank-Integration

| Option | Aufwand | Empfehlung |
|--------|---------|------------|
| (a) manueller CSV-Upload | klein | MVP · Phase 1 |
| (b) CAMT.053-XML Import täglich | mittel | Phase 2 |
| (c) EBICS-Automat | hoch | Phase 3, nur bei > 500 Rechnungen/Mt |

Arkadium-Bank: Kantonalbank → EBICS-API verfügbar, aber kostenpflichtig. MVP = CAMT.053-Upload manuell.

### 8.5 Treuhand Kunz (Export)

Referenz: `reference_treuhand_kunz.md` — office@treuhand-kunz.ch · Bexio-CSV + Swissdec-ELM.

- Monatlicher Export: Rechnungs-Journal (alle `fact_invoice` + `fact_payment` des Monats) als CSV im Bexio-Format.
- Feld-Mapping: Rechnungs-Nr, Datum, Kunde, Netto, MwSt, Brutto, Zahlungs-Datum, Konto (FIBU-Soll/Haben).
- Swissdec-ELM nicht relevant für Billing (nur für Payroll/HR-Tool).

### 8.6 Bexio (optional, Phase 2)

Rechnungen parallel syncen falls Treuhand-Wechsel oder Arkadium FIBU selbst führt. Bexio-API (REST, OAuth2). **Nicht MVP.**

### 8.7 Reminders-Vollansicht (CRM-intern)

- Rechnungs-fällige / Mahn-Trigger-Reminders automatisch via `fact_reminders` (Referenz Reminders-Vollansicht 2026-04-17).
- Zielgruppe: Backoffice + AM (pro Kunde).

---

## 9. OPEN QUESTIONS

1. **QR-Gen** — In-house (`schoero/swiss-qr-bill`, MIT) oder externer Service (z.B. TWINT Business, dedizierte SIX-Provider)?
2. **Bank-Abgleich** — MVP manueller CSV-Upload ODER direkt CAMT.053-XML-Import? EBICS erst Phase 2/3?
3. **Inkasso-Partner** — fixer Partner (z.B. Intrum, Creditreform) oder pro Fall GF-Entscheid?
4. **MwSt-Abrechnung** — voll in-app (PDF-Generator ESTV-Formular) oder an Treuhand Kunz delegieren oder hybrid (Report + manuelle Einreichung)?
5. **Akonto-Betrag Mandat Stage 1** — fix CHF 10'000 (aus Beispiel) oder variabel % vom Gesamt-Honorar-Estimate (z.B. 30/50/70)?
6. **Mahngebühr** — einführen? Fix (CHF 30/50/80 je Stufe) oder % (1–2 %)? Aktuell nicht in Arkadium-Templates.
7. **Garantie-Refund-Staffel** — linear 100 % bis 90d (aktuelle Praxis) oder Stufen 100/66/33/0? **→ PO-Entscheid vor Implementierung kritisch.**
8. **Verzugszins** — 5 % OR-default oder höher per AGB? AGB FEB 2023 zu checken.
9. **EU-Kunden** — bereits vorhanden (DE/AT) oder Feature-Flag erst bei Bedarf? Reverse-Charge-Logik ist Entwicklungsaufwand.
10. **Rechnungs-Sprache** — Template nur DE oder auch EN-Variante? `project_sprache_policy.md` sagt DE-only · EN-Legacy. **→ Bestätigt DE-only.**
11. **Blind-Copy** — immer an oder konfigurierbar pro Kunde (manche Kunden wollen volle Transparenz)?
12. **Honorar-Streit-Workflow** — pauseiert Mahnungen automatisch oder manuell? Wie lange darf disputed-Status laufen ohne Auto-Eskalation?
13. **Teilzahlung bei Mahnung** — pausiert Mahnungs-Timer oder geht weiter auf Rest-Betrag?
14. **QR-IBAN** — Arkadium-Konto 906447-4514 hat QR-IBAN oder nutzt SCOR-Referenz? Bank-Abklärung nötig.
15. **Rechnungs-Archiv 10J** — PDF in DB-Spalte (`pdf_path` → S3/Supabase-Storage) oder Cold-Storage (Glacier-artig)? 10k PDFs × ~200 KB = 2 GB · unkritisch.
16. **Optionale-Stage-Auslöser** — welcher Event triggert "4. Stage" (Sonder-Aufwand)? Manuell durch Backoffice?
17. **Second-Placement-Rabatt** — automatisch (System erkennt 2. Placement selber Kunde) oder manuell bei Draft-Erstellung?
18. **Commission-Rücklage 20 %** — bei Clawback: aus Rücklage des **konkreten Placements** oder aus MA-Gesamt-Rücklage-Pool?

---

## 10. RISIKEN & GRAUZONEN

### 10.1 Regulatorisch

- **QR-Rechnung-Pflicht seit 30.09.2022** — Nicht-Konformität = Ablehnung durch Kunden-Buchhaltung, Reputations-Schaden, Zahlungsverzögerung.
- **MwSt-Registrierungspflicht CHF 100k** — Arkadium registriert, aber bei Umsatz-Einbruch < 100k 2 Jahre in Folge: ESTV-Meldung + Abmeldung optional prüfen (für Billing-System irrelevant, aber GF-Awareness).
- **Reverse-Charge EU-Kunden** — falsche Behandlung → Doppelbesteuerung oder ESTV-Busse. Feature-Flag vor EU-Rollout.
- **Rechnungs-Archivierung 10J** (OR 958f) — bei DB-Ausfall muss PDF-Archiv wiederherstellbar sein → Backup-Policy Billing-Spezifisch.

### 10.2 Datenschutz

- **Kandidaten-Name auf Seite 1** — rechtlich zulässig, aber Blind-Copy auf Seite 2+3 nicht überall konsequent. Risiko bei GDPR-Kunden (DE/AT).
- **Email-Versand an Kunden-Buchhaltung** — Empfänger ist "Buchhaltung@Kunde", nicht der CEO. Verarbeitungsverzeichnis-Eintrag nötig.
- **Löschung nach 10J** vs. **permanente Archivierung** — revDSG fordert Löschung bei Zweck-Wegfall; OR 958f fordert 10J. Klartext: nach Jahr 10 **automatische Löschung** (nicht "forever").

### 10.3 Verjährung (OR 128 Ziff. 1 · 5 Jahre)

- **Arkadium-Honorare = 5 Jahre**, nicht 10. System-Warnung spätestens Jahr 4 nötig.
- Bei langen Honorar-Streitigkeiten (> 4J) → automatische Betreibung zur Fristunterbrechung vorschlagen.

### 10.4 Inkasso-Kosten / Betreibungs-Risiko

- **Nicht immer überwälzbar** — OR/BGer-Praxis verlangt Kausalität + AGB-Klausel. Arkadium-AGB §? prüfen.
- **Reputations-Risiko Betreibung** — bei Kunden im Hauptmarkt (Baubranche CH) können Betreibungsregister-Einträge langfristig schädlich sein. GF-Entscheid pro Fall, **nicht automatisieren**.

### 10.5 Commission-Clawback

- **Rücklage 20 % kann nicht ausreichen** — bei hoher Refund-Quote pro MA (z.B. 3× Garantie-Fälle in 12 Monaten) → Rücklage aufgebraucht, negatives Commission-Konto beim MA. Arbeitsrechtlich heikel (Lohn-Rückforderung vom MA).
- **Lösung:** Clawback-Cap (z.B. max. 6 Monatslöhne), danach Abschreibung zu Lasten Arkadium-Holding.

### 10.6 Concurrency & Datenintegrität

- **Rechnungsnummer-Kollision** bei paralleler Draft-Erstellung → `seq_invoice_yyyy`-Lock + Retry. Nie Draft-Nr bei mehreren gleichzeitigen Usern "reservieren".
- **Zahlung-Auto-Match Race** bei CAMT-Import mit N Zahlungen parallel → Transaktions-Isolation SERIALIZABLE für Match-Worker.

### 10.7 UX-Risiken

- **Storno unumkehrbar** — User-Fehler-Risiko → Doppel-Confirm + 10-Sekunden-Rückgängig-Toast.
- **Bulk-Mahnung** — versehentliche Mahnung an disputed/gestundete Invoices → Filter aktiv UND Pre-Send-Preview mit Count.
- **Blind-Copy-Vergessen** — Versand an Kunde mit Klar-Name trotz "Blind-Copy erforderlich"-Kunde → Default-AN + Warnung wenn OFF.

### 10.8 Integrations-Risiken

- **Bank-API-Ausfall** (EBICS) → manueller CAMT.053-Fallback muss immer funktionieren.
- **Email-Versand-Token abgelaufen** (OAuth2-Refresh) → Queue mit Retry + GF-Alert wenn > 24h offen.
- **Commission-Engine-Kopplung** — bei Refund muss Clawback-Event **atomar** mit Refund-Invoice-Issuance geschehen (Saga-Pattern mit Compensation).

### 10.9 Template-Management

- **Template-Versionierung** (`fact_template_versions` aus Admin-Vollansicht) — alte Rechnungen müssen mit ihrem historischen Template reproduzierbar sein (AGB-Änderungen, Signer-Wechsel).
- **AGB-Referenz im Anschreiben** (z.B. "Ziffer 8 AGB FEB 2023") — bei AGB-Update automatisch auf aktuelle AGB-Version umstellen? **Nein** — Rechnungen behalten die AGB der Rechnungs-Zeit.

### 10.10 Liquiditäts-/Forecasting-Risiko

- **Akonto-Stages bei Mandat** → Arkadium-Cashflow abhängig von Mandat-Abschlüssen. Dashboard soll Forecast zeigen (Pipeline: offene Akontos der nächsten 30/60/90d).
- **Schluss-Rechnung verzögert** bei langen Suchprozessen (Target-Mandat 6+ Mt) → Working-Capital-Belastung. Optionale Zwischen-Rechnung als Liquiditäts-Hebel.
