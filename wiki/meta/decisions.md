---
title: "ARK Decision Log"
type: meta
created: 2026-04-17
updated: 2026-04-17
tags: [decisions, governance, adr]
---

# ARK Decision Log

Append-only Log aller projekt-prägenden Entscheidungen. Verhindert Re-Litigation (wiederholtes Diskutieren gleicher Fragen) und gibt späteren Sessions Kontext.

**Format pro Eintrag:**
```
## [YYYY-MM-DD] Kurztitel (max 8 Wörter)

- **Kontext:** Was war das Problem / die Frage?
- **Entscheidung:** Was wurde beschlossen?
- **Alternativen:** Was wurde verworfen und warum?
- **Konsequenz:** Was folgt daraus (Code, UI, Prozess)?
- **Revisit:** unter welchen Bedingungen neu verhandelbar?
```

**Wartungs-Regel für Assistant:**
Bei jeder User-Entscheidung von Tragweite (neue Regel, Architektur-Wahl, Scope-Cut, UI-Pattern-Wahl, Prozess-Änderung) → **hier eintragen**. Nicht bei Trivialitäten (Naming von einzelnen Variablen, CSS-Pixel-Werte).

---

## [2026-04-20] Billing-Modul v0.1 · PO-Entscheide Batch 1

- **Kontext:** Billing-Modul Phase-3-ERP Research-Phase abgeschlossen (3 Quellen: Claude Code, GPT, Gemini). Meta-Analyse identifiziert 14 PO-Entscheide als Blocker für Spec v0.1. Batch 1 mit 5 High-Impact-Fragen an Peter.
- **Entscheidung:**
  1. **Commission-Retention-Modell 80/20 beibehalten** (Memory `project_commission_model.md`). Begründung: Payout passiert **quartalsmässig im Folgemonat** (Jan/Apr/Jul/Okt — Folgemonat nach Q4/Q1/Q2/Q3). Durch Quartals-Rhythmus ist MA-Liquidität ausreichend geschützt, 100 %-Retention bis Garantie-Ende nicht nötig. Verworfen: Research-Empfehlung GPT + Gemini (100 % Retention bis Tag 90).
  2. **Garantie-Start = Stellenantritt-Datum** des Kandidaten (nicht Placement + Payment). AGB-konform (§8 Post-Probezeit-Logik). Parametrisierbar via `guarantee_start_policy` für Sondervereinbarungen. Verworfen: Payment-basierte Kopplung (juristisch ungleich AGB).
  3. **Refund-Staffel (Best-Effort, Garantie-Fall):**
     - Exit **vor Stellenantritt** → **100 %**
     - Exit in **Monat 1** (nach Stellenantritt) → **50 %**
     - Exit in **Monat 2** → **25 %**
     - Exit in **Monat 3** → **10 %**
     - Exit **> Tag 90** → **0 %** (ausserhalb Garantie)
     Parametrisierbar in `dim_refund_reason_codes`. Verworfen: aktuelle 100 %-linear-Praxis (zu grob), 100/66/33/0 (Claude), 100/50/25/0 (GPT).
  4. **Mahn-Kadenz segmentiert pro Kunden-Klasse.** Key-Accounts: T+30/45/60, Standard: T+15/30/45. Feld `dim_accounts.dunning_cadence_profile` (Enum: `key_account` / `standard`). Inkasso-Eskalation nach letzter Mahnstufe + 5d. Verworfen: globale einheitliche Kadenz.
- **Alternativen:** siehe oben pro Punkt.
- **Konsequenz:**
  - Schema-Deltas: `dim_mandate.guarantee_start_policy`, `dim_refund_reason_codes` mit Staffel-% pro Code inkl. `pre_start`-Code, `dim_accounts.dunning_cadence_profile`. Commission-Engine-Spec bleibt unverändert (80/20).
  - UI: Refund-Cockpit zeigt Staffel-Preview basiert auf `stellenantritt_date` + Exit-Datum. Mahnwesen-Cockpit filtert nach Cadence-Profile.
  - Q4 (System of Record Billing vs Bexio) **offen** — Peter klärt mit GF Nenad.
  - Q6–Q14 (Batch 2+3) nachfolgend.
- **Revisit:**
  - Refund-Staffel: bei > 3 realen Garantie-Fällen pro Jahr Praxis-Review (greift die Staffel gerecht?).
  - Commission-Retention: bei > 2 arbeitsrechtlichen Clawback-Konflikten → auf 100 %-Retention umstellen.
  - Mahn-Kadenz-Segmentierung: bei häufiger Umklassifizierung Key-Account ↔ Standard Automatisierungs-Regel definieren (z.B. basiert auf Zahlungshistorie).

---

## [2026-04-20] Billing-Modul v0.1 · PO-Entscheide Batch 2

- **Kontext:** Fortsetzung Batch 1. Q6–Q10 decken QR-Bank-Technik, Mahngebühren, Approval-Schwellen, EU-Scope, Währungen ab.
- **Entscheidung:**
  6. **QR-IBAN noch nicht vorhanden.** Peter beschafft bei Kantonalbank nach. MVP-Strategie: Schema bereitet `qr_iban` + `reference_type`-Enum (QRR/SCOR/NON) vor. Solange keine QR-IBAN → **SCOR-Referenz** (Creditor Reference ISO 11649) mit klassischer IBAN CH07 0077 7009 0644 7451 4. Upgrade auf QRR/QR-IBAN sobald Bank liefert — reine Config-Änderung, kein Schema-Delta.
  7. **Mahngebühren / Verzugszins vertagt.** Status quo bleibt: keine Gebühr, kein Zins auf Rechnung/Mahnung ausgewiesen. Systemisch vorbereitet (`fact_dunning.fee` + `interest_amount` bestehen), aber in MVP immer 0. Revisit bei AGB-Revision oder konkretem Cashflow-Problem.
  8. **Alle Gutschriften / Stornos / Refunds / Inkasso / Stage-4 immer GF-Pflicht.** Keine Backoffice-Schwelle. Strenge Vier-Augen-Linie — Backoffice erstellt Draft, GF genehmigt via separater Action. Verworfen: CHF-5'000-Grenze (zu weich für Boutique-Grösse).
  9. **EU-Kunden Out-of-Scope MVP.** Arkadium hat aktuell nur CH-Kunden. Feld `dim_accounts.iso_country_code` bleibt Pflicht (QR-Compliance), aber Reverse-Charge-Logik + EU-Pflichttexte + ESTV-Export-Markierung werden **nicht** implementiert. Notiert für evtl. Phase 2 (Feature-Flag `feature_eu_invoicing` in `dim_automation_settings`).
  10. **CHF-only MVP.** Kein Multi-Währungs-Support. `fact_invoice.currency` bleibt default 'CHF', keine Umrechnung, keine EUR-Variante. Notiert für spätere Erweiterung bei real DE/EU-Pipeline.
- **Alternativen:** siehe oben pro Punkt.
- **Konsequenz:**
  - Schema-Deltas: `dim_accounts.iso_country_code` Pflicht (immer 'CH' in MVP); `fact_invoice.qr_reference_type` default 'SCOR' statt 'QRR'; `fact_invoice.qr_iban` nullable; `feature_eu_invoicing` als Feature-Flag in `dim_automation_settings`.
  - Approval-Flow: GF-Approval-Button auf Draft für alle kritischen Aktionen. Backoffice kann nicht "bypass".
  - MVP-Scope ca. 30 % kleiner als ursprüngliche Research-Annahme (ohne EU + ohne Multi-Currency).
- **Revisit:**
  - QR-IBAN: sobald Bank liefert → Config-Umstellung, Regressions-Test auf Auto-Match-Quote.
  - Mahngebühren: bei AGB-Revision oder > 3 Mt Cashflow-Problem.
  - EU-Kunden: bei erstem konkretem DE/AT-Lead in Pipeline.
  - GF-Approval: bei Operational-Friction (GF zu oft angefragt für Kleinigkeiten) → Schwelle einführen.

---

## [2026-04-20] Billing-Modul v0.1 · PO-Entscheide Batch 3

- **Kontext:** Finale 5 Fragen (Q11–Q15) decken Team-Wechsel-Commission, Schutzfrist-Bonus-Rechnung, Mandat-Zahlungsziel, Terminology, Blind-Copy + Du/Sie-Templates ab.
- **Entscheidung:**
  11. **TBC — Team-Wechsel-Commission (AM wechselt mid-Mandat)** im Arbeits-/Provisionsvertrag geregelt. Vertrag (`Praemium Victoria` / `Generalis Provisio`) **nicht im Worktree** — weder als PDF noch MD. Peter lädt nach oder gibt mündlich an. Bis dahin: Spec v0.1 nutzt Platzhalter-Feld `dim_commission_year.team_transition_rule` (Enum TBC).
  12. **Schutzfrist-Bonus-Rechnung (§6 AGB) in MVP als `invoice_type`-Code vorbereitet, Template später.** Real-Case selten (< 1× pro Jahr). `dim_invoice_types` bekommt Code `bonus_schutzfrist` (Label "Bonus · Schutzfrist-Verletzung"), aber kein PDF-Template in MVP. Bei Bedarf Ad-hoc-Erstellung über generisches Rechnungs-Template mit manuellem Anschreiben-Text.
  13. **Zahlungsziel Mandat bleibt 10 Tage.** Deutlich kürzer als Best-Effort (30 Tage). Begründung: Liquidität für laufende Mandatsarbeit. Konfigurierbar pro Mandat via `fact_mandate.payment_terms_days` (Default 10), aber Standard-Flow nutzt Default ohne User-Entscheid.
  14. **Terminology-Rename: "Kreditoren-Ansicht" → "Debitoren-Ansicht" / "Kundenkonto"** in allen UIs, Specs, Mockups. Buchhalterisch korrekt (Kreditor = Lieferant aus Sicht Arkadium; Kunden mit offenen Rechnungen = Debitoren). Verworfen: Bestandsschutz der falschen Begrifflichkeit. Lint-Rule ergänzen: UI-Text-Scan auf "Kreditor" in Billing-Kontext.
  15. **Blind-Copy immer an, kein Opt-Out.** DSG-sicher, Verhältnismässigkeits-Prinzip (revDSG Art. 6 Abs. 2). Seite 3 der Rechnung generiert immer mit Platzhalter "Kandidat (Diskretions-Kopie)" statt Klarname. Kein Account-Override. **Du/Sie-Templates: 1 Template mit Textbaustein-Variablen** `{{anrede}}` (z.B. `{{anrede_pronomen}}`, `{{anrede_verb}}`). PDF-Generator liest `dim_accounts.tone_of_voice` und rendert Satz-Varianten automatisch. Verworfen: (a) 2 separate PDF-Templates (Doppel-Pflege bei Textänderungen).
- **Alternativen:** siehe oben pro Punkt.
- **Konsequenz:**
  - Schema-Deltas: `dim_invoice_types` + Code `bonus_schutzfrist`; `fact_mandate.payment_terms_days` (Default 10); `dim_accounts.tone_of_voice` (Enum `sie`/`du`, Default `sie`); `dim_commission_year.team_transition_rule` (Enum TBC, pending Vertrag).
  - Template-Engine: Rechnungs-Template mit Textbaustein-Variablen `{{anrede}}`, `{{anrede_pronomen}}`, `{{anrede_verb}}`, `{{anrede_possessiv}}`. Renderer unterstützt Grammatik-Variation (Sie-Form vs. Du-Form).
  - Blind-Copy: fest in PDF-Generator-Logik (Seite 3 Placeholder-Ersetzung), kein UI-Toggle.
  - UI-Labels-Audit: alle Vorkommen "Kreditor"/"Kreditoren" in Mockups + Specs → Debitor / Kundenkonto.
  - Q11 bleibt pending — Peter liefert Vertrag oder mündliche Regel nach.
- **Revisit:**
  - Schutzfrist-Bonus-Rechnung: bei ≥ 2 Real-Cases pro Jahr → dediziertes PDF-Template.
  - Zahlungsziel Mandat: bei Kunden-Beschwerden oder Marktanpassung.
  - Du/Sie-Template: bei Grammatik-Inkonsistenzen → ggf. auf 2 separate Templates zurück.
  - Blind-Copy: bei Kunden-Zwang auf Transparenz-Mode → konfigurierbarer Opt-Out.
  - Team-Wechsel: wenn Vertrag nachgeliefert, Decision ergänzen + `team_transition_rule` Enum-Werte definieren.

---

## [2026-04-20] SIX Swiss QR-Bill v2.3 · 21.11.2025-Update bestätigt (Fact-Check)

- **Kontext:** GPT-Research-Quelle behauptete "SIX Guideline 2.3 gültig ab 21.11.2025 mit mandatory structured address Type S". Claude- + Gemini-Research-Quellen hatten das Update nicht erwähnt. Verifizierung via Perplexity (4 Primary Sources six-group.com) vor Library-/Schema-Commit.
- **Entscheidung:** **Fact bestätigt.** SIX Swiss Payment Standards Implementation Guidelines **v2.3 valid from 21.11.2025** (supersedes v2.2). Key-Changes:
  1. **Structured address Type S MANDATORY** für neue QR-Rechnungen ab 21.11.2025 (Felder: `street_name`, `building_number`, `post_code`, `town_name`, `iso_country_code`).
  2. **Combined-address Type K deprecated** · Transitional Period, danach Bank-Reject.
  3. **Extended character sets** (Unicode-Ausweitung) · optional.
  4. **v2.4 supersedes v2.3 from 14.11.2026** · Standing-Orders-Cleanup-Deadline 13.11.2026.
  5. Structured addresses mandatory für **alle** Payment-Types (D/S/X) ab November 2026.
- **Alternativen:** Keine — Compliance-Pflicht, keine Wahl.
- **Konsequenz:**
  - `dim_accounts`-Schema: `legal_street_name` + `legal_house_number` + `legal_post_code` + `legal_town_name` + `iso_country_code` separat. NOT NULL für aktive Billing-Kunden (Enforcement via CHECK-Constraint oder Pre-Issue-Validator).
  - **Migration-Task** vor MVP-Go-Live: Bestandsadressen splitten (Regex-Parser oder manuelles Nachpflegen durch Backoffice).
  - **QR-Library-Verification** erforderlich: `schoero/swiss-qr-bill` (TypeScript) und/oder `manuelbl/swiss-qr-bill` (Java) Version-Support für IG v2.3/v2.4 prüfen. Separater Fact-Check via GitHub-Releases.
  - **Pre-Issue-Validator im Rechnungs-Editor** zwingend: Type-S-Compliance-Check mit inline-Fehler bei fehlenden Feldern. Reject vor PDF-Generierung.
  - **v2.4-ready Architektur:** MVP-Go-Live nach 14.11.2026 → direkt v2.4 implementieren statt v2.3. Upgrade-Path parametrisierbar via `dim_automation_settings.qr_bill_guideline_version`.
- **Revisit:**
  - v2.4 spec-review bei GO-Live → sicherstellen dass Extended Character Sets + Sonderfälle abgedeckt.
  - Library-Breaking-Change-Monitoring: GitHub-Releases abo-Notify für QR-Bill-Libraries.
- **Quellen:**
  - https://www.six-group.com/dam/download/banking-services/standardization/sps/ig-delta-guide-sps2025-en.pdf
  - https://www.six-group.com/dam/download/banking-services/standardization/qr-bill/factsheet-qr-bill-transition-period-erp-en.pdf
  - https://www.six-group.com/dam/download/banking-services/standardization/qr-bill/ig-qr-bill-v2.4-de.pdf

---

## [2026-04-20] Billing-Modul · AGB FEB 2023 Volltext-Review · Korrekturen + Ergänzungen

- **Kontext:** Volltext-Review von `raw/Ark_CRM_v2/Arkadium_AGB_FEB_2023.pdf` nach PO-Review-Batches 1–3. Ziel: verbindliche AGB-Regelungen mit Decisions abgleichen. Ergebnis: 2 Decisions präzisieren + 3 neue Erkenntnisse.
- **Supersedes:**
  - **Batch 1 Q3 (Refund-Staffel)** — Staffel bindet an **Probezeit-Dauer**, nicht Kalendermonat post-Stellenantritt. Aktuelle Decision-Beschreibung "Monat 1 / Monat 2 / Monat 3 nach Stellenantritt" ist unpräzise.
  - **Batch 3 Q13 (Mandat-Zahlungsziel)** — AGB §5 regelt Mandate **explizit nicht** ("werden separat vereinbart"). 10 Tage ist Arkadium-Praxis-Default, aber pro Mandat vertraglich.
- **Entscheidung (AGB-wörtlich bzw. daraus abgeleitet):**

  **1. Refund-Staffel-Präzisierung (ersetzt Batch 1 Q3):**
     - Stelle **nicht angetreten** → **100 % Refund** (voller Honorar-Betrag)
     - Austritt **während Monat 1 Probezeit** → **50 %**
     - Austritt **während Monat 2 Probezeit** → **25 %**
     - Austritt **während Monat 3 Probezeit** → **10 %**
     - Austritt **nach Probezeit-Ende** → **0 %** (kein Refund-Anspruch)
     - Schema-Pflicht: `fact_candidate_placement.probezeit_months` (Integer, Default 3, konfigurierbar 1–6) + `fact_candidate_placement.probezeit_end_date` (Generated Column aus Stellenantritt + probezeit_months).
     - Refund-Cockpit berechnet Staffel-% aus `(exit_date - stellenantritt_date)` in Monaten **relativ zu Probezeit-Range**, nicht absolut.

  **2. Refund-Ausschluss-Gründe (neu):**
     Enum `dim_refund_denial_reasons`:
     - `customer_caused_no_start` — Kandidat kann wegen Kunden-Gründen Stelle nicht antreten
     - `customer_terminated_during_probation` — Kunde kündigt Kandidat während Probezeit
     - `after_probation_exit` — Austritt nach Probezeit-Ende
     - `no_notification_3d` — Kunde hat 3-Tage-Meldepflicht verletzt (keine Info vor/binnen 3 Tagen nach Kandidat-Kündigung)
     - `no_cause_reported` — Kunde hat keine Kündigungsgründe gemeldet
     Bei Match eines Codes: Refund-Anspruch **verneint**, Refund-Cockpit zeigt Reject-Begründung + Audit-Trail.

  **3. 3-Tage-Meldepflicht-Flow (neu):**
     UI-Flow im Refund-Cockpit: vor Betrags-Berechnung Check `days_between(kandidat_kuendigung_date, kunden_meldung_date) <= 3`. Bei > 3 Tagen → Refund-Denial automatisch vorgeschlagen (mit GF-Override-Option).

  **4. Mandat-Zahlungsziel-Präzisierung (ersetzt Batch 3 Q13):**
     - AGB regelt Mandat-Zahlungskonditionen **nicht** (§5 explizit).
     - **10 Tage** ist Arkadium-Praxis-Default, aber pro Mandat vertraglich.
     - Schema: `fact_mandate.payment_terms_days` (Integer, Default 10, **zwingend konfigurierbar** pro Mandat).
     - **Neu:** `fact_mandate.contract_pdf_path` (String, nullable) für Mandat-Sondervereinbarung-Ablage.
     - UI-Hinweis im Mandat-Editor: "Zahlungsziel wird aus Mandat-Vertrag übernommen, nicht aus AGB."

  **5. Honorar-Staffel Best-Effort (neu · AGB §4):**
     Honorarsatz ist **nicht fix 25 %** sondern nach Jahressalär gestaffelt:

     | Jahressalär (Basis: Jahreslohn + 13./14. ML + variable Bestandteile + Fringe Benefits) | Honorarsatz |
     |---|---|
     | < CHF 90'000 | 21 % |
     | < CHF 110'000 | 23 % |
     | < CHF 130'000 | 25 % |
     | ≥ CHF 130'000 | 27 % |

     Schema: **neue Tabelle** `dim_honorar_staffel` (versionierbar, bei AGB-Revision neue Version):
     ```sql
     CREATE TABLE dim_honorar_staffel (
       id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
       staffel_version text NOT NULL,  -- 'agb-feb-2023'
       valid_from date NOT NULL,
       valid_until date,
       salary_from_chf numeric(12,2) NOT NULL,
       salary_to_chf numeric(12,2),    -- NULL = Open-Top
       honorar_pct numeric(5,2) NOT NULL,
       UNIQUE (staffel_version, salary_from_chf)
     );
     ```
     Rechnungs-Editor berechnet Satz automatisch bei Salär-Eingabe. Rabatt-Feld überschreibt Staffel-Satz. `fact_invoice_item.honorarsatz_pct` speichert den verwendeten Satz zum Zeitpunkt der Rechnungsstellung (Revisionssicherheit bei späteren Staffel-Änderungen).

  **6. Schutzfrist-Trigger-Präzisierung (AGB §4, letzter Absatz · Ergänzung zu Memory `project_guarantee_protection.md`):**
     - **12 Mt** default ab "Absage" oder "letztem Kontakt"
     - **16 Mt** wenn Kunde **10-Tage-Auskunftspflicht verletzt** (Info zur 12-Mt-Berechnung nicht geliefert)
     - **Weitere Verlängerung** solange Kunde Kandidaten-Infos über 12/16 Mt hinaus speichert (AGB-bindend, technisch schwer nachweisbar)
     - Memory `project_guarantee_protection.md` hatte Punkt 1+2 korrekt, **Punkt 3 fehlte** — Update-Task.
     - UI-Hinweis im Schutzfrist-Tab: "Schutzfrist läuft weiter, solange Kunden-Datenbank Kandidaten-Informationen enthält." (Empfehlung für AM, kein Auto-Feature.)

  **7. Verzugszins / Mahngebühr (AGB §7 · Bestätigung Q7):**
     - AGB erwähnt weder Verzugszins noch Mahngebühr.
     - OR Art. 104 default 5 % p.a. greift automatisch ab Mahnung, muss aktiv eingefordert werden.
     - Q7-Decision (vertagen) **bleibt gültig**. Bei späterer Einführung → **AGB-Revision zwingend parallel**, nicht nur System-Config.

  **8. Gerichtsstand (AGB §10):**
     - **Zürich** (Hauptsitz Arkadium) für Streitigkeiten.
     - Für Billing-Workflow relevant: Betreibungsbegehren am Gerichtsstand Zürich möglich, aber auch am Sitz des Schuldners (SchKG Art. 67).

- **Alternativen:** Keine — AGB-Text ist bindend.
- **Konsequenz:**
  - Schema-Deltas (5 neue/erweiterte Felder + 2 neue Tabellen):
    - `fact_candidate_placement.probezeit_months` + `probezeit_end_date`
    - `dim_refund_denial_reasons` (Enum-Tabelle)
    - `fact_mandate.payment_terms_days` + `fact_mandate.contract_pdf_path`
    - `dim_honorar_staffel` (versionierbare Tabelle)
    - `fact_invoice_item.honorarsatz_pct` (Revisionssicherheit)
  - Refund-Cockpit erweitern um 3-Tage-Meldepflicht-Check + Ausschluss-Grund-Dropdown.
  - Rechnungs-Editor: Auto-Staffel-Satz-Berechnung bei Salär-Eingabe.
  - Memory-Update: `project_guarantee_protection.md` um Punkt 3 (Datenspeicher-Verlängerung) ergänzen.
- **Revisit:**
  - AGB-Revision: bei jeder AGB-Änderung Review aller ableitenden Decisions (Honorar-Staffel · Schutzfrist · Refund · Zahlungsziel).
  - Probezeit-Dauer-Varianz: bei > 2 Fällen mit Sonderprobezeit (< 3 Mt oder > 3 Mt) → Datenqualitäts-Check ob `probezeit_months` aus Kandidaten-Arbeitsvertrag sauber erfasst.
- **Quelle:** `raw/Ark_CRM_v2/Arkadium_AGB_FEB_2023.pdf` · Zürich, 1. Februar 2023

---

## [2026-04-20] Billing-Modul v0.1 · PO-Entscheide Batch 4

- **Kontext:** Finale 4 Fragen aus Plan v0.1 §11 (Q16–Q19) · Altrechnungen-Migration · Rabatt-Schwelle · Time-Mandat-Modell · Assessment-Rechnungs-Flow.
- **Entscheidung:**

  16. **Altrechnungen-Migration · Excel + PDF-Import.** Bestehende Rechnungs-PDFs aus `raw/General/1_ Rechnungen & -sheets/` + Excel-Tracking-Sheets (`Rechnungssheet_Best Effort.xlsx` · `Rechnungssheet_Mandat.xlsx` · `Rechnungssheet_S. Burri.xlsx`) werden importiert. Für jede Altrechnung:
     - Meta-Daten aus Excel-Sheet → `fact_invoice` mit `source='migration_excel'`
     - PDF-Datei referenziert via `fact_invoice.pdf_path` (Pfad zu Original-PDF in `raw/...`)
     - SHA-256-Hash berechnet → `fact_invoice.pdf_hash_sha256` (Revisionssicherheit)
     - Status default `paid` · manuelle Korrektur für offene Forderungen
     - Rechnungs-Nr aus Excel übernommen (nicht neu vergeben)
     Migration-Script: Worker `billing-excel-pdf-import` · Log in `fact_invoice_audit` mit `event_type=migration_import`.

  17. **Rabatt-Freigabe ist Sales-Entscheidung (nicht Backoffice).** Rabatte werden von **AM / Head-of / Assessment-Manager** verhandelt — Backoffice übernimmt nur den bereits festgelegten Rabatt in die Rechnung. **GF-Approval ab Rabatt > 20 %.**
     - Rabatt wird **bei Mandat-Abschluss / Process-Placement** gesetzt, nicht bei Rechnungs-Erstellung.
     - Schema-Deltas:
       - `fact_process_core.negotiated_discount_pct` (numeric, Default 0) · `negotiated_by_user_id` FK `dim_mitarbeiter` · `negotiated_at` timestamptz
       - `fact_mandate.negotiated_discount_pct` · `negotiated_by_user_id` · `negotiated_at`
     - Rechnungs-Editor liest Rabatt-Wert aus Process/Mandat (read-only) · Override im Drawer nur durch GF möglich.
     - Verworfen: Q17-Optionen (a)/(b)/(c) — falsches mentales Modell, Backoffice entscheidet nie über Rabatte.

  18. **Time-Mandat ist Weekly-Fee (nicht stundenbasiert).** Korrektur gegenüber Plan-v0.1 §4.2 Time-Mandat-Beschreibung:
     - Time-Mandat fakturiert **Weekly-Fee × Anzahl Wochen im Monat**, nicht stundenbasiert
     - **Keine Kopplung an Zeit-Modul `fact_zeit_summary`** (Zeit-Modul ist MA-intern, nicht Kunden-Abrechnung)
     - Schema-Deltas:
       - `fact_mandate.weekly_fee_chf` (numeric, pro Mandat verhandelt)
       - `fact_mandate.time_billing_start_date` (date, Beginn fakturierbarer Zeitraum)
       - `fact_mandate.time_billing_end_date` (date, nullable — NULL = open-ended)
     - Worker `time-mandate-monthly-invoice` (Cron: 1. Tag Folgemonat · 06:00):
       - Iteriert aktive Time-Mandate (`business_model = mandat_time` + `status = signed`)
       - Berechnet Anzahl Wochen im Vormonat (pro rata bei Teilmonaten · Start/End-Datum berücksichtigen)
       - Generiert Draft `fact_invoice` mit `type=mandat_time_monthly` · `stage_nr=NULL`
       - Betrag = `weekly_fee_chf × anzahl_wochen_im_monat`
     - UI: Mandat-Editor zeigt Weekly-Fee-Feld + Billing-Zeitraum-Range-Picker.
     - Time-Mandat-Rechnung-Template neu (PDF): "Wöchentliche Pauschale für Zeitraum [von–bis] · CHF X × N Wochen = CHF Y".

  19. **Assessment-Rechnung = separater Flow.** Neuer `invoice_type=assessment`:
     - Eigenes PDF-Template (basiert auf `raw/General/1_ Rechnungen & -sheets/Diagnostic & Assessment/Vorlage_Rechnung_Diagnostics & Assessment.pdf`)
     - **Keine Honorar-Staffel** (fixer Preis pro Assessment ODER Pauschale pro Kandidat · aus `dim_assessment_types.price_chf`)
     - Trigger: `fact_assessment_order.status = delivered` → `invoice_triggered_assessment`-Event
     - Empfänger: Auftraggeber-Account (`fact_assessment_order.customer_id`)
     - Keine Commission-Kopplung (Assessment-Rechnungen lösen keine CM/AM-Provision aus · Severina-Nolan-Jahresziel wird separat in Commission-Engine behandelt)
     - Schema: `fact_invoice.assessment_order_id` FK `fact_assessment_order` (nullable, nur bei type=assessment)

- **Alternativen:** Siehe oben pro Punkt.

- **Konsequenz:**
  - Schema-Deltas zusätzlich:
    - `fact_invoice.assessment_order_id` FK · `fact_invoice.source` Enum (`native` / `migration_excel`)
    - `fact_process_core` + `fact_mandate`: 3 Rabatt-Felder (`negotiated_discount_pct` · `negotiated_by_user_id` · `negotiated_at`)
    - `fact_mandate.weekly_fee_chf` · `time_billing_start_date` · `time_billing_end_date`
    - `dim_invoice_types` neuer Code `mandat_time_monthly` · `assessment`
  - Worker-Liste erweitert:
    - `billing-excel-pdf-import` (einmalig bei Migration)
    - `time-mandate-monthly-invoice` (monatlich Cron)
  - Rollen-Matrix-Update Plan §7:
    - **AM / CM / Head-of / Assessment-Manager:** Rabatt-Verhandlung bei Process/Mandat-Abschluss (nicht in Rechnungs-Drawer)
    - **Backoffice:** Read-Only auf Rabatt-Wert bei Rechnungs-Erstellung
    - **GF:** Override-Authority bei Rabatt > 20 %
  - Plan-v0.1 §4.2 Time-Mandat-Beschreibung **superseded** (war: stundenbasiert aus Zeit-Modul) · neu: Weekly-Fee-Modell.
  - Plan-v0.1 §11 Q16/Q17/Q18/Q19 resolved.

- **Revisit:**
  - Altrechnungen-PDF-Hash: bei Qualitäts-Problem (beschädigte PDFs im raw/) → Fallback-Hash auf Excel-Meta.
  - Rabatt > 20 % Frequenz: bei häufigem GF-Approval (> 2×/Monat) → Schwelle erhöhen auf 25 %.
  - Time-Mandat pro-rata-Berechnung: bei Kontroversen mit Kunde → Kalender-Woche vs. 7-Tage-Block klären.
  - Assessment-Preis-Quelle: falls `dim_assessment_types.price_chf` zu starr → Auftrags-spezifische Preise über `fact_assessment_order.negotiated_price_chf`.

---

## [2026-04-20] Billing-Modul · QR-Library-Version-Check + SIX-Datum-Korrektur

- **Kontext:** Plan v0.1 + Schema v0.1 + Interactions v0.1 spezifizieren `schoero/swiss-qr-bill` als primäre QR-Library. Peter fordert Fact-Check vor Commit. Perplexity-Check gegen GitHub + NPM + SIX-Primary-Sources durchgeführt.
- **Findings:**

  **1. SIX-Datum-Korrektur:** Direkte Primary-Source-Zitate aus `ig-qr-bill-v2.3-en.pdf`:
  - **IG v2.3 valid from 21. November 2025** (nicht 22.11.2025 wie bisher dokumentiert)
  - v2.3 remains valid **until November 2027** (Parallelbetrieb mit v2.4 möglich)
  - v2.2 (22.02.2021) + v2.1 (30.09.2019) komplett durch v2.3 ersetzt
  - **Alle bisherigen Decision-Einträge mit "22.11.2025" korrigiert auf "21.11.2025".**

  **2. IG v2.4 technisch-neutral für CHF:** Direktes Zitat `ig-qr-bill-v2.4-en.pdf`:
  > "Version 2.4 does not result in any technical adjustments for invoicing in Swiss francs (CHF). For invoicing in euros (EUR), only the combination IBAN/SCOR reference and IBAN/unstructured message is possible."
  - **Konsequenz:** Für CHF-only MVP ist v2.3-Code = v2.4-Code. Kein Upgrade-Zwang bei 14.11.2026.
  - Plan-v0.1-Aussage "MVP-Go-Live nach 14.11.2026 → direkt v2.4" war übervorsichtig · bleibt dokumentarisch, kein Implementations-Zwang.

  **3. Library-Status:**
     - **`schoero/swissqrbill`** (NPM-Package-Name · TypeScript, NICHT `schoero/swiss-qr-bill`):
       - GitHub: https://github.com/schoero/swissqrbill · 41 Releases · TS 99.5 %
       - Latest **v4.2.0 · 28.05.2025** (6 Monate vor v2.3-Effective-Date)
       - **Keine öffentliche v2.3-Compliance-Aussage** · manuelle Verifikation nötig
       - NPM-Install: `npm i swissqrbill` (Name ohne Bindestriche)
     - **`manuelbl/SwissQRBill`** (Java):
       - v3.3.0 (01.06.2024) explizit "Ready for QR bill 2.3" · Extended Character Set + deprecated Combined-Address Type K
       - v3.3.1 (24.10.2024) PDFBox-Update
       - **Fallback-Option**, aber Java im Node-Stack aufwendig (Edge-Function oder Microservice-Call)

- **Entscheidung:**
  1. **Primäre Library: `swissqrbill` v4.2.0** (NPM · TypeScript, schoero). Package-Name-Korrektur in Plan v0.1 §8.3 + Schema-Kommentaren: `swissqrbill` (ein Wort, kein Bindestrich).
  2. **Verifikations-Task vor MVP-Commit:**
     - Pre-MVP-Regression-Test mit SIX-Referenz-PDFs v2.3 (Type-S-Structured-Address + Extended Character Set)
     - GitHub-Issue-Watch: `schoero/swissqrbill` Releases + Issues mit Keyword "v2.3" / "Type S" / "structured address"
  3. **Bei v2.3-Gap (falls Regression-Test fehlschlägt):**
     - Priorität 1: Fork + PR mit Type-S-Structured-Address-Support
     - Priorität 2: Fallback auf `manuelbl/SwissQRBill` v3.3.1 via Edge-Function
     - Priorität 3: Eigen-Build mit PDFKit + SIX-Spec-Parser (2–3 Wochen Dev-Aufwand)
  4. **v2.4-Upgrade:** kein aktiver Upgrade-Task für CHF-only-MVP. Falls EUR-Feature aktiviert wird (Feature-Flag `feature_eu_invoicing`): v2.4-Code-Review + Library-Version-Check (schoero/manuelbl) zum Zeitpunkt.

- **Alternativen:** 
  - **Eigen-Build:** verworfen in MVP · reaktiviert als Priorität 3 bei v2.3-Gap
  - **manuelbl-Java als Primär:** verworfen wegen Node-Stack-Fit · bleibt Fallback

- **Konsequenz:**
  - Plan v0.1 §8.3 Library-Name-Korrektur: `schoero/swiss-qr-bill` → `swissqrbill` (NPM)
  - Neue Pre-MVP-Task: "QR-Library-Regression-Test gegen SIX v2.3 Test-PDFs" (Teil Phase 3.B.1)
  - Monitoring-Setup: GitHub-Release-Subscription für `schoero/swissqrbill`
  - Falls v2.3-Gap entdeckt: Fork-Repo `ArkadiumCRM/swissqrbill-v2.3-fork` + Upstream-PR
  - Keine Plan-/Schema-/Interactions-Breaking-Changes durch diesen Fact-Check.

- **Revisit:**
  - Pre-MVP-Regression-Test-Ergebnis: falls fehlschlägt → Fork-/Fallback-Plan aktivieren
  - Library-Release-Notes: bei schoero/swissqrbill v4.3+ prüfen ob v2.3-Compliance dokumentiert
  - v2.4-Effective-Date 14.11.2026: falls EUR-Feature aktiv → erneute Library-Evaluation

- **Quellen:**
  - https://github.com/schoero/swissqrbill (v4.2.0 · 28.05.2025)
  - https://github.com/manuelbl/SwissQRBill/releases (v3.3.1 · 24.10.2024)
  - https://www.six-group.com/dam/download/banking-services/standardization/qr-bill/ig-qr-bill-v2.3-en.pdf
  - https://www.six-group.com/dam/download/banking-services/standardization/qr-bill/ig-qr-bill-v2.4-en.pdf
  - https://www.npmjs.com/package/swissqrbill

---

## [2026-04-20] Commission-Engine ↔ Billing · Event-Schnittstelle · 5 Patches

- **Kontext:** Cross-Check zwischen `ERP Tools/specs/ARK_COMMISSION_ENGINE_SPEC_v0_1.md` und frisch erstellter `ARK_BILLING_INTERACTIONS_v0_1.md`. 7 Findings (5 Gaps + 2 Konsistenzen) identifiziert. Alle 5 Gaps gepatcht.

- **Findings-Zusammenfassung:**
  - ✅ Konsistent: Quartals-Payout-Kadenz (Jan/Apr/Jul/Okt) · Time-Mandat-Commission-Ausschluss
  - 🔴 Gap 1: Trigger-Widerspruch `placement_confirmed` (Commission) vs `payment_received` (Billing)
  - 🔴 Gap 3: Fehlende Subscriber für `invoice_partially_paid` · `invoice_cancelled` · `invoice_written_off`
  - 🔴 Gap 4: Rücklage-Freigabe-Trigger nicht auf Stellenantritt-Policy angepasst
  - 🟡 Gap 2: Event-Naming-Inkonsistenz `commission_clawback_triggered` vs `ruecklage_clawback`
  - 🟡 Gap 6: Researcher-Pauschale-Clawback-Flow in Billing-Saga fehlt

- **Patches (alle applied):**

  1. **Commission-Engine-Spec §4.1 · 2-Stufen-Trigger-Modell:**
     - **Stufe 1 (Forecast):** `placement_confirmed` → Ledger-Row mit `status='forecast'` · commission_gross berechnet · abschlag/ruecklage **NOCH NICHT aktiv**
     - **Stufe 2 (Promotion):** `payment_received` + `invoice_paid` aus Billing → Row promoted zu `status='pending_payment'` · `abschlag_chf = gross * 0.80` · `ruecklage_chf = gross * 0.20`
     - `invoice_partially_paid` → Forecast bleibt · Notiz-Annotation "Teilzahlung CHF x/y · warte auf Vollzahlung" · keine Promotion
     - `invoice_cancelled` → forecast DELETE · pending_payment UPDATE clawed_back · paid_abschlag Clawback-Process
     - `invoice_written_off` → alle Stati Clawback · Rücklage verloren

  2. **Commission-Engine-Spec §4.3 · Rücklage-Freigabe-Trigger:**
     - Umgestellt von `placement_date + 3 months` auf **`fact_candidate_placement.stellenantritt_date + 3 months`** (= `guarantee_end_date` Generated Column)
     - Parametrisierbar via `fact_mandate.guarantee_start_policy` (Default `stellenantritt`)
     - Kompatibel mit Billing-Decision Batch 1 Q2

  3. **Commission-Engine-Spec §5 · Event-Tabelle:**
     - Aufgeteilt in §5.1 (Commission-publishes) + §5.2 (Billing-subscribed) + §5.3 (Naming-Kompatibilität)
     - 6 neue Subscriber-Events aus Billing: `placement_confirmed` · `payment_received` · `invoice_paid` · `invoice_partially_paid` · `invoice_cancelled` · `invoice_written_off` · `refund_issued`
     - 2 neue Commission-Events: `commission_forecast_created` · `commission_promoted_to_pending`
     - Naming-Alignment: `ruecklage_clawback` → **`commission_clawback_triggered`** (Billing-Sender-Name) · `ruecklage_released` → `commission_ruecklage_released`

  4. **Commission-Engine-Spec Frontmatter:**
     - `updated: 2026-04-20`
     - `patches_applied`-Feld neu mit Beschreibung der 2026-04-20-Patches
     - Version bleibt v0.1 (Patch-in-place da noch Draft-Status)

  5. **Billing-Interactions §4.2 · Saga-Refund-Flow erweitert:**
     - Commission-Handling verzweigt nach `commission_primary_role`:
       - `cm_am` / `head_of` → negative `fact_commission_ledger`-Entry · Status-Handling je nach aktuellem Ledger-Status
       - `researcher` → `fact_researcher_fee.status = 'clawed_back'` (Pauschale 1:1)
       - `none` → Keine Aktion
     - Explizit dokumentiert dass Event `commission_clawback_triggered` alignt zu Commission-Spec §5

- **Alternativen:** Commission-Engine-Spec v0.2-Bump statt v0.1-Patch-in-place verworfen · Commission-Spec ist weiterhin Draft, Patch-in-place + `patches_applied`-Feld im Frontmatter reicht.

- **Konsequenz:**
  - Beide Specs (Billing v0.1 + Commission-Engine v0.1) kohärent in Event-Schnittstelle
  - 2-Stufen-Ledger-Modell (Forecast/Promotion) neu dokumentiert · Schema-DB-Erweiterung NICHT nötig (Status-Spalte existiert bereits, nur neue Werte `forecast`/`pending_payment` genutzt)
  - Commission-Engine-Worker `commission-engine-bridge` (aus Billing) subscribed 7 Events
  - Saga-Flow Refund-Clawback dokumentiert für 3 Rollen-Varianten (cm_am/head_of/researcher/none)
  - Commission-Spec §4.3 Worker-Query-Anpassung: `fact_candidate_guarantee` → `fact_candidate_placement.guarantee_end_date`

- **Revisit:**
  - Pre-MVP-Implementation: Commission-Worker muss 2-Stufen-Handling testen (Forecast-Row → Promotion via Event-Flow)
  - Clawback-Race-Conditions: Concurrent `invoice_cancelled` + `payment_received` → Transaktions-Isolation SERIALIZABLE
  - v0.2-Bump bei größeren Schema-Änderungen (z.B. wenn Forecast-Rows eigene Tabelle kriegen)

---

## [2026-04-18] Harness-Evolution v2: Cross-Provider-MCPs, Routines, Autoresearch, Karpathy

- **Kontext:** Peter wollte Setup grundlegend überdenken. Skills/MCPs/Hooks/Routines/Lints waren vorhanden aber ausbaufähig. Karpathy-Principles, Claude Design, Cross-Provider-Integration (Codex/Perplexity/DeepSeek), Autoresearch, OpenClaw/Hermes standen zur Diskussion.
- **Entscheidung:** 
  1. **Karpathy-Skill** lokal unter `.claude/skills/karpathy/` (4 Principles: Think-Before-Coding, Simplicity-First, Surgical-Changes, Goal-Driven-Execution).
  2. **Claude Design** (Anthropic Labs, launched 18.04.2026) als Phase-2-Mockup-Werkzeug → Handoff-Bundle zu Claude Code. Browser-only, kein Desktop.
  3. **Cross-Provider-MCPs**: Codex (OpenAI inkl. o3), Perplexity (Web-Research+Citations), DeepSeek (günstiges Reasoning). Setup-Guide: `wiki/meta/mcp-setup-guide.md`. Peter installt manuell im Terminal nach Key-Beschaffung.
  4. **OpenClaw + Hermes verworfen** — Konkurrenz-Frameworks zu Claude Code, kein Integrations-Nutzen.
  5. **3 Cloud-Routines** (laufen unabhängig von Peter's Laptop):
     - `ark-weekly-drift` (Mo 09:00 CEST) — Drift-Scan → `drift-log.md`
     - `ark-weekly-po-agenda` (Mi 09:00 CEST) — Agenda → `po-review-agenda-YYYY-MM-DD.md`
     - `ark-daily-digest-staleness` (Di-So 08:00 CEST) — STALE.md-Flags
     Kontrolle: https://claude.ai/code/scheduled
  6. **`ark-autorefine` Skill** — Karpathy-Autoresearch-Pattern adaptiert für Phase-1-Cleanup. Human-in-Loop MVP (kein Auto-Apply ohne Peter-OK). `.claude/skills/ark-autorefine/`.
  7. **Bypass-Permissions global** in `~/.claude/settings.json` mit Hard-Deny-Guards (rm -rf, git force, DROP TABLE, etc.). Assistant self-checks kritische Ops in Chat.
  8. **Caveman-Lite** als Default in `%APPDATA%/caveman/config.json`.
  9. **2 neue Slash-Commands**: `/ark-po-review`, `/ark-phase2-plan`.
  10. **Git-Repo etabliert**: https://github.com/ArkadiumCRM/Ark_CRM (private). Audio/Video in `raw/` per .gitignore excluded (> 100MB limit).
  
- **Alternativen verworfen:**
  - LangChain / OpenClaw / Hermes als Parallel-Framework (Konkurrenten zu Claude Code).
  - Codex als Komplett-Ersatz für Claude (zweite LLM-Billing ohne klaren Mehrwert ausser Cross-Review).
  - Autoresearch vollautonom overnight (ARK braucht semantic Validator, nicht nur Lint-Count → Human-in-Loop).
  - Hermes für spezifische Subtasks (redundant, alles was Hermes kann hat Claude Code).
  - Phase-2-Code-Start jetzt (Peter will zuerst Phase-1-Cleanup + ERP-Module als Specs/Mockups).
  
- **Konsequenz:**
  - Peter bedient Setup-Alltag via 4 Oberflächen: Claude Code (default), Claude Desktop (brainstorm), Claude Design (neue Mockups), Obsidian (Wiki-Browse).
  - Cross-Provider-Nutzung wird im Chat transparent angekündigt ("Ich lass Codex das Refactor reviewen...").
  - Routines produzieren 3 Artefakte/Woche die Peter Montag/Mittwoch reviewt.
  - Autorefine-Loop kann ab sofort via "autorefine nächster Punkt" gestartet werden.
  
- **Revisit:** 
  - Permission-Bypass: nach 2-4 Wochen prüfen ob Self-Check-Regel zuverlässig greift. Bei Regelbruch → zurück zu `defaultMode: auto` mit Classifier.
  - Routines: nach 4 Runs prüfen ob Signal-zu-Noise stimmt. Sonst Anpassung der Prompts.
  - Codex/Perplexity/DeepSeek: nach 1 Monat ROI-Check (wirklich bessere Outputs vs Kosten?).
  - Autorefine v2 (Auto-Apply für SAFE-Categories): erst nach 20+ erfolgreich-iterierten Zyklen manuell.

## [2026-04-17] Grundlagen-Digests + Auto-Lint-Hooks etabliert

- **Kontext:** SessionStart-Hook sprengte Inline-Limit (200k Token) → Grundlagen nie im Context. User musste Stages/Flows/Business-Logik wiederholt erklären.
- **Entscheidung:** 5 Grundlagen-Digests (~42k Token total, Enums lossless, Prosa lossy) + 3 neue Hooks (Auto-Lint Post-Edit, Digest-Staleness-Check, Pre-Edit-Hint) + Anti-Pattern-Digest + Decision-Log + Mockup-Baseline.
- **Alternativen:** (a) Volltext chunked einmalig pro Session laden (~300k Context-Verbrauch, zu teuer wenn Arbeit folgt). (b) Nur on-demand Read (vergessens-anfällig, driftet zu manuellen Re-Erklärungen). (c) CLAUDE.md fett machen (schlecht wartbar, 200k-Inline-Problem bleibt).
- **Konsequenz:** Jede Session ~42k Digest-Context + Anti-Patterns + Decisions + Baseline auto-geladen. Präzisions-Arbeit (exakte Spalten/Endpoints) erfordert explizite User-Freigabe vor Volltext-Read.
- **Revisit:** Wenn Digests driften (Grundlagen-Edit → STALE.md Flag) → Regeneration. Wenn Auto-Lint False-Positives nervt → Patterns tunen in `.claude/hooks/ark-lint.ps1`.

## [2026-04-16] Arkadium ist NICHT Interview-Teilnehmer

- **Kontext:** Mehrfach Verwechslung "Arkadium führt Interview / macht TI". Falsches mentales Modell.
- **Entscheidung:** Interviews (TI / 1st / 2nd / 3rd / Assessment) laufen ausschliesslich zwischen Kandidat ↔ Kunde. Arkadium-Touchpoints ausschliesslich: Briefing (mit Kandidat, einmalig nach Hunt), Coaching (vor Interview), Debriefing (nach Interview, beidseitig), Referenzauskunft (vor Placement).
- **Alternativen:** Keine -- ist fachliche Realität der Headhunting-Boutique.
- **Konsequenz:** Alle UI-Texte/Labels/Tooltips/Timeline-Events müssen diese Rolle sauber abbilden. Activity-Type-Mapping in STAMMDATEN §14.
- **Revisit:** Nicht revisitbar (Business-Realität).

## [2026-04-16] Schutzfrist ≠ Garantiefrist

- **Kontext:** UI-Verwechslung: Garantiefrist (3 Mt post-Placement) vs Schutzfrist (12/16 Mt bei NICHT-Placement).
- **Entscheidung:** Getrennte UI-Flächen. Garantie: Post-Placement-Timeline / 3 Check-Ins. Schutzfrist: Separate Account-Tab / Kandidat-Tab "Offene Schutzfristen". Schutzfrist greift NUR wenn Prozess OHNE Placement endet (Rejection/Stale/Closed).
- **Alternativen:** Gemeinsames Widget "Post-Placement" -- verworfen, weil semantisch unterschiedlich.
- **Konsequenz:** Mockups candidates.html/accounts.html haben separate Tabs/Widgets.
- **Revisit:** Nicht revisitbar (AGB §6 + Vertragslogik).

## [2026-04-14] Drawer 540px als CRUD-Default

- **Kontext:** Inkonsistente Dialog-Typen (Modal, Drawer, Sheet) über Mockups.
- **Entscheidung:** CRUD + Mehrschritt-Eingaben + Bestätigungen mit Feldern → Drawer 540px slide-from-right. Modal NUR für kurze Confirms / Blocker / System-Notifications ohne Formular.
- **Alternativen:** Modal-Default (rejected, keine mobile-responsive Antwort). Bottom-Sheet (rejected, desktop-first Produkt).
- **Konsequenz:** Alle 9 Detailmasken + Drawer-Pattern aus `mockup-baseline.md`. Lint-Hook flaggt Modal+Form-Kombinationen.
- **Revisit:** Wenn neuer Entity-Typ grundsätzlich andere UX verlangt (bisher nicht eingetreten).

## [2026-04-14] Briefing vs Stellenbriefing Terminologie

- **Kontext:** Beide Begriffe im Einsatz, Semantik unscharf.
- **Entscheidung:** **Briefing** = Kandidat-Seite (Arkadium ↔ Kandidat, Eignungsgespräch nach Hunt). **Stellenbriefing** = Account/Job/Mandat-Seite (Arkadium ↔ Kunde über Stelle). Nicht vermischen.
- **Alternativen:** Einheitlicher Begriff "Briefing" (rejected, vermischt 2 Flows).
- **Konsequenz:** UI-Labels, Timeline-Events, Activity-Types entsprechend.
- **Revisit:** Nicht revisitbar.

## Tipp für Assistant

- Bei jeder User-Nachricht die eine **Regel**, **Pattern-Wahl**, oder **Scope-Cut** enthält → hier eintragen.
- Kurz halten: Kontext + Entscheidung + Konsequenz reichen meist.
- Alternativen nur ausfuehren wenn nicht-trivial verworfen (bildungsrelevant für spätere Revisits).
- NICHT eintragen: einzelne Variable-Names, CSS-Pixel, typo-fixes, one-off-Commits.

## [2026-04-26] PO-Review-Entscheidungen Performance-Modul-Abschluss

- **Kontext:** PO-Review nach Performance-Modul Mockup-Phase-Abschluss (11/11 P0+P1 Seiten fertig, 5 Grundlagen synced, Spec-Mockup-Sync-Report geprüft). 4 Entscheidungen zur Priorisierung Phase-3-ERP-Roadmap.
- **Entscheidungen:**
  1. **Account-Tab9 Group-Scope weiter aufgeschoben.** Account-Detailseite zeigt Hierarchie-Struktur (Parent/Child-Accounts) bislang nur as Label/Display. Echte UI-Scope für Tab 9 (Filter nach Group, Edit-Drawer für Group-Assignment) bleibt offen in `wiki/meta/detailseiten-nachbearbeitung.md` als **KRITISCH P0 · Original-Erfassung 2026-04-13**. Grund: höherere Priorität haben Publishing + Messaging Phase-3-Mockups (entgegen ursprünglicher Planung). Revisit nach publishing+messaging fertig.
  2. **Performance-Backend-Implementation aufgeschoben.** Backend-Code für Performance-Modul startet NACH Mockup-Vollständigkeit für weitere Phase-3-ERP-Module (Publishing, Messaging, ggf. elearn-Tiefe). Grund: Peter will erst Mockup-Skelett aller 5 Module sichtbar haben, bevor Backend parallel läuft. Parallel-Dev würde zu Drift führen (Spec-Async).
  3. **Sample-Data-File-Pattern auf andere ERP-Module rückportieren.** Performance-Modul nutzt zentrale `mockups/_shared/perf-sample-data.js` mit `window.ARK_PERF.*`-Namespace für Demo-Daten. Pattern bewährt (einfach zentral editierbar, keine Makro-Templates in HTML nötig). Soll auf HR, Commission, Zeit, Billing **rückportiert werden** (eigene Session, ~2-3h Multi-File-Refactor mit Backups). Aufgeschoben auf separate Task `project_sample_data_rollout_pending.md` (Memory).
  4. **CSS-Comment-UMLAUT-Fixes deployed.** 9 Performance-Mockups hatte Sub-Agent `fuer` statt `für` in CSS-Comments hinterlassen (kosmetisch, kein funktional/UI-Impact). Alle 9 gefixt: performance-admin, performance-business, performance-coverage, performance-funnel, performance-insights, performance-mitarbeiter, performance-reports, performance-revenue, performance-team. Auch 9 unresolved Changelog-Einträge (Grundlagen-Syncs 2026-04-25) markiert als `resolved (2026-04-25 · Performance-Modul-Sync)`.
- **Alternativen verworfen:**
  - Backend-Implementation JETZT starten mit Mockup-Parallel-Sprints → verworfen (Peter will erst Mockup-Vollständigkeit).
  - Sample-Data-Rollout erst bei nächster Touch-Iteration je Modul → verworfen (gleichzeitige Migration einfacher zu reviewen in einer Session).
  - Account-Tab9 Group-Scope JETZT bauen statt Publishing/Messaging → verworfen (strategische Prio-Verschiebung).
- **Konsequenz:**
  - Phase-3-ERP Mockup-Roadmap: 5 Module geplant (HR, Zeit, Commission, Billing, E-Learning teilweise, **Performance fertig**). Nächste Mockups: **Publishing** + **Messaging**. Nach Vollständigkeit: Backend-Implementation + Sample-Data-Rollout parallel.
  - Account-Tab9 Group-Scope → Backlog, Nachbearbeitung nach Publishing+Messaging.
  - Sample-Data-Rollout Pending-Task → Memory `project_sample_data_rollout_pending.md` created · Session-TODO für nach Publishing+Messaging.
  - Changelog + decisions.md updated (PO-Review 2026-04-26).
- **Revisit:**
  - Nach Publishing + Messaging Mockup-Abschluss (geschätzt nächste 2 Sessions) → Backend-Implementation starten.
  - Sample-Data-Rollout eigene Session (2-3h) nach Mockup-Vollständigkeit.
  - Account-Tab9 Group-Scope wenn Detailseiten-Nachbearbeitung auf Agenda kommt (ursprünglich P0 — neu 2026-04-26 aufgeschoben, nicht gestrichen).
