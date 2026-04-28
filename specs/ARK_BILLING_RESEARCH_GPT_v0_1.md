---
title: "Billing-Modul Research · GPT mit Zitaten · v0.1"
type: source
created: 2026-04-20
updated: 2026-04-20
sources: ["Externe AI-Antwort · GPT-artig mit Fedlex/SIX/KMU-Zitaten"]
tags: [research, billing, phase3-erp, external-ai]
---

# Billing-Modul Research · GPT-Antwort mit Zitaten

**Quelle:** Externe AI-Antwort · GPT-artig · narrative Struktur mit Citations

## 1. LEGAL-FRAMEWORK

Für Arkadium ist rechtlich nicht einfach nur "Rechnung raus, Mahnung raus" relevant, sondern ein Bündel aus OR, MWST, Datenschutz, Betreibungsrecht und Zahlungsstandard. Beim Zahlungsverzug gilt in der Schweiz: Der Schuldner gerät grundsätzlich durch Mahnung in Verzug, ausser es wurde ein bestimmter Verfalltag vereinbart. Ab Verzug ist ohne abweichende Vereinbarung grundsätzlich ein Verzugszins von 5 Prozent p.a. geschuldet. Für das Modul heisst das: `due_at` ist kein blosses UI-Feld, sondern ein juristisch relevanter Trigger für Overdue, Mahnung und Verzugszinslogik. ([Fedlex][1])

Die Arkadium Vertragslogik liegt materiell meist im Umfeld des Auftragsrechts nach OR Art. 394 ff. Dort ist zentral, dass eine Vergütung geschuldet ist, wenn sie vereinbart oder üblich ist. Für Executive Search ist das entscheidend, weil Best Effort, Mandat, Akonto, Schutzfrist und Garantiefall sauber aus Vertrag, AGB und Prozessereignissen ableitbar sein müssen. Die AGB Referenzen auf Garantie und Refund müssen daher im Billing-Modul versioniert am Rechnungsfall gespeichert werden, nicht nur als PDF irgendwo im DMS. ([Fedlex][1])

Mehrwertsteuerlich ist Arkadium mit 8.1 Prozent Normalsatz unterwegs. Rechnungen müssen die Mindestangaben nach MWSTG enthalten. Bei grenzüberschreitenden Konstellationen ist wichtig: Die inländischen Formvorschriften zur Rechnungsstellung gelten nicht einfach schematisch für alle Auslandssachverhalte, und die steuerliche Behandlung bei Dienstleistungen an ausländische Empfänger muss separat geprüft werden. Für euer Datenmodell braucht es deshalb nicht nur `mwst_rate`, sondern auch `tax_treatment`, `place_of_supply`, `reverse_charge_flag` und eine Begründung, warum 0 Prozent oder Reverse Charge angewendet wurde. ([estv.admin.ch][2])

Datenschutzrechtlich ist euer aktuelles 3 Seiten Modell mit Kandidatenbezug heikel, aber beherrschbar. Das revidierte DSG verlangt rechtmässige, verhältnismässige Bearbeitung und Datenminimierung. Praktisch heisst das: Kandidatenname auf Seite 2 nur dann, wenn er für den Abrechnungszweck erforderlich ist; auf Seite 3 ist eure Blind Copy Logik genau richtig und sollte konsequent Default sein. Für DSGVO sensible Kunden braucht ihr zusätzlich eine Template Policy "Candidate Reference Mode" mit Optionen `full_name`, `initials`, `blind_copy_only`, `internal_reference_only`. ([Fedlex][3])

Inkasso und Betreibung sind in der Schweiz nicht dasselbe. Inkasso ist aussergerichtlich, Betreibung ist das staatliche Vollstreckungsverfahren nach SchKG. Nach Zustellung eines Zahlungsbefehls kann der Schuldner innert 10 Tagen Rechtsvorschlag erheben. Daraus folgt für das Modul: Ab Mahnstufe 3 braucht ihr keinen diffusen Status "Inkasso", sondern mindestens `collection_external`, `debt_enforcement_pending`, `payment_order_served`, `legal_objection`, `rights_opening_required`. ([Bundesamt für Justiz][4])

Zur QR Rechnung: Seit 1. Oktober 2022 haben die QR Rechnungen die alten Einzahlungsscheine endgültig abgelöst. Zusätzlich gelten seit 22. November 2025 neue Vorgaben gemäss aktueller SIX Guideline 2.3. Das ist wichtig, weil viele Teams noch mit "seit 30.09.2022 Pflicht" formulieren. Praktisch korrekt ist: alte Einzahlungsscheine waren nur bis 30.09.2022 verwendbar; ab 01.10.2022 ist QR Standard, und seit 22.11.2025 gelten aktualisierte Regeln. Das Modul darf QR daher nicht als statisches Bild behandeln, sondern als standardisierte, versionsabhängige Rendering Engine. ([SIX][5])

Bei Verjährung und Archivierung müsst ihr zwei Dinge trennen. Geschäftsbücher und Buchungsbelege sind zehn Jahre aufzubewahren. Verjährungsrechtlich gilt grundsätzlich zehn Jahre, für bestimmte periodische Forderungen und Berufsvergütungen aber teils eine fünfjährige Frist. Für Honorarforderungen im Search Umfeld ist das nicht etwas, das man pauschal blind auf "5 Jahre sicher" setzen sollte, sondern im Zweifel juristisch prüfen. Produktseitig ist die sichere Lösung: 10 Jahre revisionssichere Archivierung als Systemstandard, plus `limitation_warning_at` als konfigurierbare Forderungsüberwachung. ([KMU Verwaltung][6])

---

## 2. STAMMDATEN-DELTAS

Ihr braucht ein sauberes Billing Master Data Modell, sonst endet das Modul als PDF Generator ohne Kontrolltiefe.

**Rechnungstypen**

| Code | Label | Verwendung |
| ----------------------- | ----------------------- | ------------------------------------------------- |
| invoice_best_effort | Best Effort Rechnung | Erfolgsbasis bei Placement |
| invoice_mandate_stage_1 | Mandat Akonto | Vertragsunterzeichnung |
| invoice_mandate_stage_2 | Mandat Zwischenrechnung | Shortlist Start oder Meilenstein |
| invoice_mandate_stage_3 | Mandat Schlussrechnung | Placement |
| invoice_mandate_stage_4 | Mandat Sonderstage | Optionaler Zusatzaufwand |
| invoice_termination | Kündigung Mandat | Abschlusszahlung bei Abbruch |
| refund_credit | Rückerstattung | Garantiefall oder Kulanz |
| credit_note | Gutschrift | Korrektur ohne Geldrückfluss oder mit Verrechnung |
| cancellation_invoice | Storno | Falsch ausgestellte Rechnung |
| bonus_invoice | Bonus / Zusatzhonorar | Schutzfrist, Zusatzleistung |
| dunning_fee | Mahngebühr | Nur falls eingeführt |
| collection_fee | Inkasso Gebühr | Nur falls vertraglich bzw. zulässig abbildbar |

**Zahlstatus**

| Code | Bedeutung |
| ------------------- | ------------------------------- |
| draft | Entwurf |
| issued | Ausgestellt, noch keine Zahlung |
| partially_paid | Teilbezahlt |
| paid | Voll bezahlt |
| overdue | Fällig, nicht bezahlt |
| dunning_l1 | Mahnstufe 1 |
| dunning_l2 | Mahnstufe 2 |
| dunning_l3 | Mahnstufe 3 |
| collection_external | Externes Inkasso |
| debt_enforcement | Betreibung eingeleitet |
| legal_dispute | Honorarstreit / Rechtsstreit |
| deferred | Gestundet |
| written_off | Abgeschrieben |
| cancelled | Storniert |
| refunded | Rückerstattet |
| netted | Durch Gutschrift verrechnet |

**Mahnstufen**

| Code | Logik |
| ---------------- | -------------------------------------- |
| none | keine |
| reminder_soft | Vorfällige oder freundliche Erinnerung |
| l1 | Mahnung 1 |
| l2 | Mahnung 2 |
| l3 | Mahnung 3 |
| debt_enforcement | Betreibung |
| collection_hold | gestoppt wegen Vergleich / Streit |

**Gutschriftsgründe**

| Code | Bedeutung |
| -------------------- | ------------------------ |
| invoice_error | Rechnungsfehler |
| amount_correction | Betragskorrektur |
| goodwill | Kulanz |
| refund_guarantee | Garantie-Refund |
| duplicate_invoice | Doppelverrechnung |
| vat_correction | MWST-Korrektur |
| service_scope_change | Leistungsumfang geändert |
| cancellation_reissue | Storno und Neuerstellung |

**MwSt-Kategorien**

| Code | Satz | Zweck |
| ------------------ | ---- | ------------------------------------------------- |
| ch_standard | 8.1% | Standard Schweiz |
| ch_reduced | 2.6% | Falls künftig relevant |
| ch_special_lodging | 3.8% | wohl irrelevant, aber systemisch standardisierbar |
| export_service_0 | 0% | Auslandssachverhalt |
| reverse_charge_0 | 0% | Empfänger schuldet Steuer im Ausland |
| tax_exempt | 0% | Nur falls rechtlich einschlägig |

**Zahlungsmittel**

| Code | Bedeutung |
| -------------- | -------------------------- |
| bank_transfer | Klassische Überweisung |
| qr_bill | QR Zahlung |
| card | Kreditkarte |
| stripe | Stripe |
| twint | TWINT |
| manual_journal | Manuelle Buchung |
| offset_credit | Verrechnung mit Gutschrift |

Zusätzlich braucht ihr folgende Stammdaten, die im Prompt noch fehlen, aber operativ Pflicht sind:

| Feld | Warum |
| ------------------------- | ------------------------------------------- |
| `invoice_language` | DE Standard, EN optional künftig |
| `addressing_mode` | Sie / Du |
| `agb_version_id` | rechtssichere Referenz |
| `template_variant` | Rechnung, Mahnung, Refund, Kündigung Mandat |
| `signature_profile_id` | Nenad + zweiter Signer |
| `bank_account_profile_id` | falls mehrere Konti kommen |
| `debtor_contact_id` | zuständige Person für Rechnungen |
| `privacy_mode` | Kandidatenanzeige steuern |
| `commission_eligibility` | ja/nein |
| `export_status_treuhand` | offen / exportiert / bestätigt |

---

## 3. SCHEMA-DELTAS

Unten ist die fachlich sinnvolle DDL Richtung PostgreSQL. Ich ergänze Felder, die ihr für echte Revisionssicherheit braucht.

```sql
create table dim_invoice_type (
invoice_type_code text primary key,
label_de text not null,
category text not null, -- invoice | refund | credit_note | dunning | cancellation
affects_revenue boolean not null default true,
affects_commission boolean not null default false
);
create table dim_invoice_status (
status_code text primary key,
label_de text not null,
is_open boolean not null,
is_terminal boolean not null default false
);
create table dim_mwst_code (
mwst_code text primary key,
label_de text not null,
rate numeric(5,2) not null,
tax_treatment text not null, -- domestic | export | reverse_charge | exempt
estv_box_code text null
);
create table fact_invoice (
invoice_id uuid primary key default gen_random_uuid(),
invoice_nr text not null unique,
customer_id uuid not null references dim_account(account_id),
debtor_contact_id uuid null references dim_contact(contact_id),
process_id uuid null references fact_process(process_id),
mandate_id uuid null references fact_mandate(mandate_id),
original_invoice_id uuid null references fact_invoice(invoice_id),
invoice_type_code text not null references dim_invoice_type(invoice_type_code),
status_code text not null references dim_invoice_status(status_code),
invoice_language text not null default 'de-CH',
addressing_mode text not null check (addressing_mode in ('sie','du')),
privacy_mode text not null default 'blind_copy_only',
agb_version_id uuid null references dim_contract_version(contract_version_id),
currency char(3) not null default 'CHF',
amount_net numeric(18,2) not null,
amount_vat numeric(18,2) not null,
amount_gross numeric(18,2) not null,
default_mwst_code text not null references dim_mwst_code(mwst_code),
issue_date date not null,
service_date date null,
due_date date null,
paid_date date null,
valuta_date date null,
payment_terms_days integer null,
payment_reference text null,
qr_iban text null,
iban text null,
creditor_name text not null default 'Arkadium AG',
creditor_address_jsonb not null,
debtor_address_jsonb not null,
qr_bill_payload_jsonb null,
pdf_path text null,
pdf_hash_sha256 text null,
template_variant text not null,
signature_profile_id uuid null,
commission_eligibility boolean not null default false,
commission_released_at timestamp null,
export_status_treuhand text not null default 'open',
exported_at timestamp null,
cancellation_reason text null,
dispute_reason text null,
internal_note text null,
created_at timestamp not null default now(),
created_by uuid not null,
issued_at timestamp null,
issued_by uuid null,
updated_at timestamp not null default now(),
updated_by uuid not null
);
create index idx_fact_invoice_customer on fact_invoice(customer_id);
create index idx_fact_invoice_process on fact_invoice(process_id);
create index idx_fact_invoice_mandate on fact_invoice(mandate_id);
create index idx_fact_invoice_status on fact_invoice(status_code);
create index idx_fact_invoice_issue_date on fact_invoice(issue_date);
create index idx_fact_invoice_due_date on fact_invoice(due_date);
create index idx_fact_invoice_original_invoice on fact_invoice(original_invoice_id);
create table fact_invoice_item (
invoice_item_id uuid primary key default gen_random_uuid(),
invoice_id uuid not null references fact_invoice(invoice_id) on delete cascade,
position_no integer not null,
line_type text not null, -- fee | discount | text | subtotal | vat_info | offener_posten
description text not null,
quantity numeric(18,4) not null default 1,
unit text null,
unit_price numeric(18,2) not null default 0,
discount_pct numeric(7,4) not null default 0,
total_net numeric(18,2) not null,
mwst_code text not null references dim_mwst_code(mwst_code),
candidate_reference text null,
function_title text null,
stage_no integer null,
stage_status text null, -- due | open_item | paid | cancelled
meta_jsonb null
);
create unique index uq_fact_invoice_item_pos on fact_invoice_item(invoice_id, position_no);
create index idx_fact_invoice_item_invoice on fact_invoice_item(invoice_id);
create table fact_payment (
payment_id uuid primary key default gen_random_uuid(),
invoice_id uuid not null references fact_invoice(invoice_id),
payment_date date not null,
valuta_date date null,
amount numeric(18,2) not null,
currency char(3) not null default 'CHF',
payment_method text not null,
reference text null,
bank_booking_jsonb null,
bank_statement_import_id uuid null,
matched_confidence numeric(5,2) null,
is_manual boolean not null default false,
created_at timestamp not null default now(),
created_by uuid not null
);
create index idx_fact_payment_invoice on fact_payment(invoice_id);
create index idx_fact_payment_date on fact_payment(payment_date);
create index idx_fact_payment_reference on fact_payment(reference);
create table fact_dunning (
dunning_id uuid primary key default gen_random_uuid(),
invoice_id uuid not null references fact_invoice(invoice_id) on delete cascade,
dunning_level integer not null check (dunning_level between 1 and 3),
sent_at timestamp not null,
deadline date not null,
fee_amount numeric(18,2) not null default 0,
interest_amount numeric(18,2) not null default 0,
template_variant text not null,
channel text not null default 'email_pdf',
email_message_id text null,
created_by uuid not null,
unique (invoice_id, dunning_level)
);
create table fact_credit_note (
credit_note_id uuid primary key default gen_random_uuid(),
invoice_id uuid not null references fact_invoice(invoice_id),
reason_code text not null,
amount_net numeric(18,2) not null,
amount_vat numeric(18,2) not null,
amount_gross numeric(18,2) not null,
issued_at timestamp not null,
approved_by uuid not null,
note text null
);
create table fact_refund (
refund_id uuid primary key default gen_random_uuid(),
invoice_id uuid not null references fact_invoice(invoice_id),
reason_process_id uuid null references fact_process(process_id),
original_payment_id uuid null references fact_payment(payment_id),
refund_policy_code text not null,
amount numeric(18,2) not null,
approved_by uuid not null,
paid_at timestamp null,
reason text not null,
customer_bank_jsonb null
);
create table fact_invoice_audit (
audit_id uuid primary key default gen_random_uuid(),
invoice_id uuid not null references fact_invoice(invoice_id) on delete cascade,
event_type text not null,
old_value_jsonb null,
new_value_jsonb null,
actor_user_id uuid not null,
created_at timestamp not null default now()
);
```

**Wichtige Constraints und Regeln**

| Regel | Begründung |
| ----------------------------------------------- | ------------------------------------------------------------------ |
| `invoice_nr UNIQUE` | Nummernkreis darf nie kollidieren |
| `original_invoice_id` | Storno, Gutschrift, Refund sauber referenzierbar |
| `on delete cascade` nur bei Items/Dunning/Audit | Hauptbeleg nie versehentlich löschbar |
| `pdf_hash_sha256` | Revisionssicherheit, Nachweis unveränderter PDF-Fassung |
| `matched_confidence` | Bankmatching transparent statt Black Box |
| `privacy_mode` | Datenschutzlogik systemisch |
| `commission_eligibility` | Billing nicht mit Commission vermischen, aber kontrolliert koppeln |

**Zusätzliche Empfehlung**

Eine reine `fact_invoice` reicht nicht. Ihr braucht auch einen **Nummernkreis-Service** mit Sperrlogik pro Monat/Jahr, sonst produziert Parallelbetrieb Duplikate. Format: `FN{YYYY}.{MM}.{####}`. Die Sequenz muss transaktional vergeben werden, nicht im Frontend.

---

## 4. PROZESS-FLOWS

### 4.1 Best Effort

1. Process erreicht Stage `placement_confirmed`
2. System prüft: `agb_accepted`, `placement_date`, `salary_confirmed`, `honorarsatz`, `responsible_backoffice`
3. Auto erstellt Invoice Draft mit Honorarbasis
4. Backoffice prüft Kandidatenreferenz, Rabatt, Zahlungsfrist 30 Tage
5. Rechnung wird issued, PDF erzeugt, QR Zahlteil gerendert
6. Zahlungseingang matched
7. Status `paid`
8. Commission Event wird freigegeben
9. Garantie Timer startet

**Wichtiger Delta:**
Garantie Timer sollte **nicht** nur auf Placement + Payment basieren, sondern auf einer klaren Policy. Fachlich sinnvoller ist: Garantie beginnt mit Stellenantritt oder vertraglich definiertem Placement Effective Date. Payment ist für Commission relevant, nicht zwingend für Garantie. Eure vorgeschlagene Logik "Placement-Datum + Payment-Eingang" ist operativ simpel, aber juristisch nicht automatisch identisch mit der AGB Garantie. Das muss als `guarantee_start_policy` parametrierbar sein.

### 4.2 Mandat

1. Mandat wird als gewonnen markiert
2. Stage 1 Akonto Draft wird erstellt
3. Alle drei Stages werden auf Rechnung ausgewiesen
4. Nur fällige Stage hat Betrag, andere `OFFENER POSTEN`
5. Zahlungseingang Stage 1
6. Bei Shortlist Start oder definiertem Milestone wird Stage 2 Draft erzeugt
7. Bei Placement oder Mandatsabschluss wird Stage 3 Draft erzeugt
8. Optionale Stage 4 nur mit GF Freigabe
9. Storno, Korrektur oder Kündigung Mandat über separate Vorlage

### 4.3 Kündigung Mandat

1. Mandat Status `terminated_by_client`
2. System zieht bisher fakturierte und noch fakturierbare Leistungen
3. Abschlussrechnung auf Basis Mandatsmodell
4. Nicht mehr geschuldete Restphasen werden auf `cancelled`
5. Commission bleibt unberührt, da kein Placement

### 4.4 Refund / Rückerstattung

1. Kandidat verlässt Unternehmen in Garantiefrist oder refundauslösender Tatbestand tritt ein
2. AM oder GF eröffnet Garantiefall
3. System zeigt Policy: Ersatzkandidat, Full Refund, Partial Refund
4. Refund-Cockpit berechnet Vorschlag
5. GF Freigabe nötig
6. Refund Beleg wird erzeugt
7. Auszahlung an Kundenkonto
8. Bereits freigegebene Commission wird als Clawback markiert

### 4.5 Mahnwesen

Empfohlene Automatik:

| Tag relativ zu `due_date` | Aktion |
| ------------------------- | ------------------------------- |
| T+1 | Status `overdue`, internes Flag |
| T+5 | Soft Reminder optional |
| T+15 | Mahnstufe 1 |
| T+30 | Mahnstufe 2 |
| T+45 | Mahnstufe 3 |
| T+60 | GF Review Inkasso / Betreibung |
| T+75 | Betreibungsbegehren vorbereitet |
| T+90 | finaler Eskalationsentscheid |

Dein vorgeschlagenes T+30, T+45, T+60, T+90 ist defensiv und reputationsschonend. Für Arkadium kann das sinnvoll sein. Cashflow-seitig ist es aber langsam. Ich würde das als Policy pro Kundensegment parametrieren.

### 4.6 Honorarstreit

1. Kunde bestreitet Rechnung
2. Status `legal_dispute`
3. Mahnautomatik stoppt
4. Interne Task an GF
5. Dokumentencenter sammelt Vertrag, AGB Version, E-Mail Verlauf, Placement Nachweis
6. Entscheid: Vergleich, Gutschrift, Fortführung, Inkasso, Betreibung

### 4.7 Gutschrift / Storno

Strikt trennen:

| Typ | Wirkung |
| ---------- | ---------------------------------------------------------- |
| Storno | falscher Beleg wird neutralisiert, meist mit Neuerstellung |
| Gutschrift | Betrag wird reduziert oder verrechnet |
| Refund | Geld fliesst zurück an Kunde |

### 4.8 MWST-Abrechnung

1. Alle issued, bezahlten und korrigierten Belege werden periodisch aggregiert
2. Zuordnung in ESTV Box Logik
3. Quartalsreport
4. Export an Treuhand
5. Lock nach Periodenabschluss

---

## 5. BUSINESS-LOGIC

### 5.1 QR Rechnung

QR Rechnung muss aus strukturierten Feldern generiert werden, nicht aus einer Grafik. Minimum:

* Creditor Name + Adresse
* IBAN oder QR-IBAN
* Debtor Daten
* Betrag
* Referenztyp
* Referenz
* Währung
* Zusätzliche Informationen

Wichtig: Wenn ihr echte QR Referenzlogik wollt, müsst ihr unterscheiden zwischen normaler IBAN und QR-IBAN. `besr_reference` im alten Sinn ist historisch belastet. Produktseitig sauberer sind `reference_type` mit `QRR`, `SCOR`, `NON` und dazu ein validiertes `payment_reference`. Wegen der geänderten SIX Vorgaben seit November 2025 sollte die Library aktiv gepflegt oder intern getestet sein. ([SIX][7])

### 5.2 Auto-Zuordnung Zahlung

Matching Reihenfolge:

1. Exakte Referenz
2. QR Referenz
3. Exakter Betrag + Debitor + plausibles Datum
4. Fuzzy Match mit Confidence Score
5. Manuelle Zuordnung

Bankimport sollte CAMT.053 priorisieren. CSV nur als Fallback. API oder EBICS später.

### 5.3 Teilzahlung

Wenn `sum(payments) < amount_gross` und `> 0`, dann Status `partially_paid`. Mahnlogik läuft auf Restbetrag, nicht auf Vollbetrag. Rechnungsdetail muss offen zeigen:

* Ursprungsbetrag
* bisher bezahlt
* Rest offen
* allfällige Mahngebühren
* allfälliger Verzugszins

### 5.4 Garantie Timer

Empfohlenes Modell:

| Feld | Zweck |
| ------------------------------ | --------------------------------- |
| `guarantee_policy_code` | AGB / Sondervereinbarung |
| `guarantee_start_date` | effektiv |
| `guarantee_end_date` | Start + 3 Monate |
| `refund_eligibility_status` | eligible / expired / under_review |
| `replacement_option_available` | bool |

Nicht hart im Code an Zahlungseingang koppeln.

### 5.5 Refund Staffel

Du hast selbst die Lücke benannt. Arkadium scheint aktuell faktisch 100 Prozent zu fahren, aber das ist als Systemlogik zu grob. Sinnvolle Policy-Engine:

| Kündigung nach Stellenantritt | Refund Vorschlag |
| ----------------------------- | ---------------- |
| 0 bis 30 Tage | 100% |
| 31 bis 60 Tage | 50% |
| 61 bis 90 Tage | 25% |
| >90 Tage | 0% |

Alternative: Ersatzkandidat priorisieren, Refund nur subsidiär. Wichtig ist, dass das System `policy_snapshot` speichert, damit spätere AGB Änderungen alte Fälle nicht umschreiben.

### 5.6 MwSt Split

Wenn mehrere Positionen mit unterschiedlichen MwSt Codes auf einer Rechnung vorkommen, darf `amount_vat` nicht nur aus Headerlogik kommen. Ihr braucht pro Item Steuer und dann einen Header Rollup.

### 5.7 Skonto

Derzeit nicht nötig. Wenn eingeführt, dann nur mit diesen Feldern:

* `discount_if_paid_until`
* `discount_pct`
* `discount_amount`
* `effective_amount_if_early_paid`

Sonst weicht Buchhaltung und Debitorenlogik auseinander.

### 5.8 State Machine

Empfohlene Invoice State Machine:

```text
draft
→ approved
→ issued
→ partially_paid | paid | overdue
overdue
→ dunning_l1
→ dunning_l2
→ dunning_l3
→ collection_external | debt_enforcement | legal_dispute | written_off
issued | overdue | dunning_l1..l3
→ cancelled
issued | paid | partially_paid
→ credited | refunded
```

**Wichtiger Punkt:**
`approved` fehlt in deinem Zielbild. Den braucht ihr zwingend, damit Entwurf und freigegebener, aber noch nicht gesendeter Beleg getrennt sind.

---

## 6. UI-ARCHITEKTUR

Eure bestehende Designwelt ist editorial, also muss Billing nicht wie ein generisches ERP aussehen. Gleichzeitig darf die Ästhetik die Debitorenklarheit nicht verwässern. Empfehlung: **klarer Operator-Workspace im ARK Stil**, nicht hübsches PDF-Tool.

### 6.1 Screen Inventory

#### Dashboard

KPI Karten oben:

* Offen gesamt
* Überfällig gesamt
* Zahlungseingänge 30 Tage
* Refunds laufend
* MwSt Periode offen
* Durchschnittliche DSO

Darunter 3 Kernmodule:

1. **Mahnungs-Pipeline**
2. **Top Debitoren**
3. **Offene Garantiefälle mit Refund-Risiko**

#### Rechnungs-Liste

Spalten:

| Spalte | Bemerkung |
| -------------- | ------------------------------ |
| Rechnungs-Nr | klickbar |
| Kunde | Account |
| Typ | Best Effort / Mandat / Refund |
| Referenz | Kandidat / Mandat / Blind Copy |
| Betrag brutto | CHF |
| Offen | CHF |
| Issue Date | |
| Due Date | |
| Status | Badge |
| Mahnstufe | Badge |
| Verantwortlich | Backoffice |
| Exportstatus | Treuhand |

Filterleiste:
Status, Typ, Kunde, Sparte, Datum, Betrag, AGB Version, Sprache, Sie/Du, Exportstatus.

Bulk Actions:
PDF Export, Mahnung senden, CSV Export, Treuhand Export, Storno vorbereiten.

#### Rechnungs-Editor

Rechte Seite 540px Drawer, links Hintergrundliste oder Prozesskontext.

Steps:

1. Kunde
2. Quelle wählen: Best Effort Prozess / Mandat / freie Rechnung / Refund / Gutschrift
3. Positionen
4. Steuerlogik
5. Anschreiben + Signatur
6. QR Preview
7. Freigabe

**Auto-Fill aus `process_core`:** Kandidat, Funktion, Startdatum, Salär, Honorarsatz, Placement Datum, Sparte, AM.

#### Mahnwesen-Cockpit

Das ist kein Nice-to-have. Das ist operativ Gold.

Spalten: Rechnung, Kunde, Offen, Tage überfällig, letzte Aktivität, nächste Stufe, empfohlene Aktion, Risiko.

Sammelaktion: "Alle Mahnung 1 vorbereiten" aber Versand erst nach Review.

#### Kreditoren-Ansicht

Du meinst hier faktisch Debitorenansicht pro Kunde. Benenne das UI korrekt als **Kundenkonto** oder **Debitorenkonto**, nicht Kreditorenansicht. Kreditor ist in der Buchhaltungslogik Lieferant, also falsch.

Inhalt: Alle Rechnungen, Zahlungen, Gutschriften, Streitfälle, durchschnittliche Zahlungsdauer, offener Saldo.

#### Zahlungseingang

2 Tabs:

* Import Queue
* Unmatched Bookings

Mit Confidence Badges: hoch, mittel, tief.

#### MwSt-Abrechnung

Periode, steuerbare Umsätze, Korrekturen, Gutschriften, Exporte, ESTV Mapping.

#### Refund-Cockpit

Fälle nach Frist sortiert: 0 bis 30 Tage, 31 bis 60, 61 bis 90, >90.

### 6.2 Drawer / Modal Spezifikation

| UI-Element | Breite | Inhalt |
| ------------------ | -----: | ----------------------------------------------- |
| Rechnung-Detail | 540px | Header, Positionen, Zahlungen, Mahnungen, Audit |
| Rechnung-Erstellen | 540px | Wizard |
| Gutschrift | 540px | Ursprungsrechnung, Grund, Betrag, PDF Preview |
| Zahlung-Erfassen | 540px | Betrag, Valuta, Referenz, Match |
| Refund-Berechnung | 540px | Policy, Staffel, Commission Clawback |
| Mahnung-Senden | 420px | Tonstufe, Textvorschau, neue Frist |
| Inkasso-Übergabe | 540px | Dossier Checkliste |

### 6.3 UI Muster, die ihr zusätzlich braucht

* Audit Timeline im Drawer
* Inline Warnungen bei Kandidatendaten auf PDF
* PDF Version Switch Seite 2 / Seite 3
* Live Betragserklärung `123'500 × 25% = 30'875`
* Readonly Block nach `issued`
* "Storno und Neu erstellen" als geführte Aktion, nicht manuelle Bastelarbeit
* Sticky Summary Footer im Drawer

---

## 7. ROLLEN-MATRIX

Die Grundidee passt, aber zwei Dinge fehlen: **Approval** und **Segregation of Duties**.

| Feature | AM | CM | Backoffice | GF | Treuhand | Admin |
| --------------------------------- | -: | -------: | -------------: | -: | -------: | ----: |
| Rechnung Draft erstellen | – | – | ✓ | ✓ | – | – |
| Rechnung freigeben | – | – | ✓ bis Schwelle | ✓ | – | – |
| Rechnung senden | – | – | ✓ | ✓ | – | – |
| Rechnung lesen | ✓ | optional | ✓ | ✓ | RO | ✓ |
| Zahlung sehen | ✓ | – | ✓ | ✓ | RO | ✓ |
| Zahlung matchen | – | – | ✓ | ✓ | – | – |
| Mahnung auslösen | – | – | ✓ | ✓ | – | – |
| Gutschrift < CHF 5k | – | – | ✓ | ✓ | – | – |
| Gutschrift ≥ CHF 5k | – | – | – | ✓ | – | – |
| Refund genehmigen | – | – | – | ✓ | – | – |
| Storno durchführen | – | – | ✓ | ✓ | – | – |
| Inkasso / Betreibung freigeben | – | – | – | ✓ | – | – |
| Treuhand Export | – | – | ✓ | ✓ | ✓ RO | – |
| MwSt-Abrechnung sehen | – | – | ✓ | ✓ | ✓ RO | – |
| Policy / Nummernkreis / Templates | – | – | – | – | – | ✓ |

**Empfohlene Zusatzregeln**

* Backoffice darf Draft erstellen und Standardfälle freigeben
* GF Pflicht bei Refund, Kulanz, Streit, Stage 4, Gutschriften über Schwelle
* Admin hat technische Rechte, aber keine fachliche Finanzfreigabe
* AM sieht Kundenzahlung und Status, aber ändert keine Beträge
* CM standardmässig kein Billing Zugriff

---

## 8. INTEGRATIONEN

### 8.1 CRM

Billing hängt an:

* `fact_process` für Best Effort Placement
* `fact_mandate` für Mandatsrechnungen
* `dim_account` und `dim_contact`
* `dim_contract_version` bzw. AGB Snapshot
* `offer / placement / start_date` Events

Pflichtintegration: Wenn im Prozess ein Placement bestätigt wird, muss Billing einen Draft-Vorschlag erzeugen, nicht sofort eine Rechnung.

### 8.2 Commission Engine

Das ist kritisch. Commission darf **nur** auf Basis von **eingegangener Zahlung** freigegeben werden. Nicht auf `issued`. Bei Refund oder Gutschrift braucht ihr Rückabwicklung.

Empfohlene Events:

* `invoice_paid`
* `invoice_partially_paid`
* `refund_issued`
* `refund_paid`
* `invoice_written_off`

Jeder Event schreibt in eine `fact_commission_event_queue`.

### 8.3 Email / Outlook

Nicht pro User Token, wenn es sich vermeiden lässt. Besser:

* Shared mailbox oder service account
* Versand im Namen definierter Billing Absender
* PDF als Attachment
* HTML Mail mit Template Variants Sie / Du
* Logging von `message_id`, `sent_at`, `delivery_status`

### 8.4 QR Bill Library

Eine Library wie `manuelbl/swiss-qr-bill` ist für Start okay, aber nur wenn sie aktuelle SIX Änderungen unterstützt oder ihr Regressionstests dagegen habt. Sonst baut ihr technische Schuld in den Zahlungsprozess ein. Relevant wegen der aktualisierten Vorgaben seit November 2025. ([SIX][7])

### 8.5 Bank

Priorität:

1. CAMT.053 XML Import
2. CSV Fallback
3. API Integration
4. EBICS Automatisierung

EBICS lohnt sich erst, wenn Volumen und Reife da sind.

### 8.6 Treuhand Kunz

Exportpaket monatlich:

* Rechnungen
* Zahlungen
* Gutschriften
* Refunds
* Debitorensaldo
* MWST Mapping

Formate: Bexio CSV, eigenes CSV, optional XML.

### 8.7 Bexio

Nicht als Core einplanen. Optionales Side Sync, sonst verdoppelt ihr Logik und Konflikte. System of Record sollte euer CRM/ERP oder Bexio sein, aber nicht beides halb.

---

## 9. OPEN QUESTIONS

Hier sind die offenen Punkte in produktlogischer Priorität, nicht einfach gesammelt:

1. **Was ist das führende Finanzsystem?** Eigenes Billing als System of Record oder nur Vorstufe für Treuhand/Bexio?
2. **Wie beginnt die Garantiefrist wirklich?** Placement Datum, Vertragsunterzeichnung, Stellenantritt oder Zahlungseingang?
3. **Welche Refund Policy gilt verbindlich?** Immer 100 Prozent, Ersatzkandidat zuerst oder Staffel 30/60/90?
4. **Braucht Arkadium echte Mahngebühren oder nur Verzugszins + Erinnerung?** Heute scheint ihr ohne Gebühren zu arbeiten.
5. **Welche Freigabeschwellen gelten?** Refund, Gutschrift, Kulanz, Stage 4, Storno, Streitfall.
6. **Welche Bankanbindung ist realistisch in Phase 1?** CSV, CAMT Import oder API?
7. **Welcher Referenzstandard wird verwendet?** QRR, SCOR oder Non Reference?
8. **Wie anonymisiert ihr Kandidaten auf Kundenrechnungen standardmässig?** Vollname, Initialen, Blind Copy only?
9. **Wie wird mit EU Kunden umgegangen?** Reverse Charge Policy, Pflichttexte, steuerliche Prüfung je Land.
10. **Soll das System Verzugszins automatisch berechnen?** Juristisch möglich, operativ aber oft reputationssensitiv.
11. **Wie wird mit Teilzahlungen umgegangen?** Mahnung auf Restbetrag, Kulanzlogik, Ratenzahlung?
12. **Soll Mahnstufe 1 automatisch gesendet werden oder nur vorgeschlagen?**
13. **Welche PDFs sind revisionssicher eingefroren?** Jede issued Version, jede Mahnung, jede Gutschrift?
14. **Wie laufen Storno und Neuvergabe der Rechnungsnummern?** Nie überschreiben, immer Kette.
15. **Wie tief soll Treuhand Kunz direkten Readonly Zugriff erhalten?**
16. **Braucht ihr Fremdwährungen oder bleibt alles CHF only?**
17. **Braucht ihr eigene Bonusrechnungen für Schutzfristfälle nach §6 AGB?**

---

## 10. RISIKEN & GRAUZONEN

1. **QR Standard Drift** — Wer QR nur als statische PDF Komponente denkt, baut schnell am aktuellen Standard vorbei. Seit 22.11.2025 gelten aktualisierte Vorgaben. ([SIX][7])
2. **Datenschutz vs. Buchhaltungsnutzen** — Kandidatendaten auf Rechnungen können für den Zweck zu weit gehen. Blind Copy sollte Default sein, volle Kandidatennennung Ausnahme mit klarer Begründung. Das folgt aus Verhältnismässigkeit und Datenminimierung. ([Fedlex][3])
3. **Juristische Übervereinfachung bei Mahnung** — "3 Mahnungen nötig" ist in der Schweiz kein Gesetz. Es ist Praxis. Wenn ihr das System falsch modelliert, erzeugt ihr träge Debitorenprozesse. ([Fedlex][1])
4. **Garantie- und Commission-Kopplung falsch definiert** — Wenn Garantie, Refund und Commission auf falsche Events hängen, entstehen interne Konflikte und Clawback Chaos.
5. **Storno, Gutschrift, Refund werden vermischt** — Das ist einer der häufigsten Buchhaltungsfehler in kleineren Unternehmen. Im System streng trennen.
6. **MWST Ausland falsch behandelt** — Gerade bei DE/AT Kunden kann ein falscher 0 Prozent oder Reverse Charge Entscheid später teuer werden. Produktseitig müsst ihr steuerliche Begründung und Exportspuren speichern. ([Fedlex][8])
7. **Falsche Terminologie im UI** — "Kreditoren-Ansicht" für Kundenforderungen ist fachlich falsch. Das muss Debitorenansicht oder Kundenkonto heissen.
8. **Kein Approval Layer** — Ohne Freigabestufe kann Backoffice faktisch jede finanzielle Rechtswirkung alleine auslösen. Das ist governance-seitig schwach.
9. **Keine revisionssichere Archivierung** — Rechnungen, Mahnungen und Zahlungsbelege müssen 10 Jahre aufbewahrt werden. Ohne Hash, Version und Exportlog seid ihr angreifbar. ([KMU Verwaltung][6])
10. **Betreibung ohne Dossierfähigkeit** — Wer nach Mahnstufe 3 nicht sauber Vertrag, AGB, Rechnung, Versandnachweis, Placement-Nachweis und Korrespondenz bündeln kann, verliert operativ Zeit und Druck. Im SchKG Kontext zählt die saubere Beleglage spätestens bei Rechtsvorschlag. ([KMU Verwaltung][9])
11. **Nummernkreis-Kollisionen** — Format schön, aber ohne transaktionale Sequenzlogik gefährlich.
12. **Bexio Parallelwelt** — Wenn ihr parallel in Bexio und im CRM Rechnungen pflegt, bekommt ihr doppelte Wahrheit.
13. **Teilzahlungen nicht sauber modelliert** — Führt zu falschen Mahnungen, falschem Saldo, falscher Commission.
14. **PDF zentriertes Denken** — Das PDF ist Ausgabe, nicht Wahrheit. Wahrheit ist der strukturierte Datensatz.

[1]: https://www.fedlex.admin.ch/eli/cc/27/317_321_377/de
[2]: https://www.estv.admin.ch/de/mehrwertsteuer
[3]: https://www.fedlex.admin.ch/eli/oc/2022/491/de
[4]: https://www.bj.admin.ch/bj/de/home/wirtschaft/schkg.html
[5]: https://www.six-group.com/de/products-services/banking-services/payment-standardization/standards/qr-bill.html
[6]: https://www.kmu.admin.ch/kmu/de/home/praktisches-wissen/finanzielles/buchhaltung-und-revision/elektronische-aufbewahrung-der-geschaeftsbuecher.html
[7]: https://www.six-group.com/de/products-services/banking-services/billing-and-payments/qr-bill.html
[8]: https://www.fedlex.admin.ch/eli/cc/2009/615/de
[9]: https://www.kmu.admin.ch/kmu/de/home/praktisches-wissen/finanzielles/buchhaltung-und-revision/was-tun-bei-drohendem-zahlungsausfall/betreibungsbegehren.html
