---
title: "HR · Mitarbeiter-Ordner + Tools (Personalstammdaten · Smarttime · Abwesenheitsantrag · Spesen)"
type: source
created: 2026-04-19
updated: 2026-04-19
sources: [
  "raw/HR/2_HR On- Offboarding/4_Ordner für Mitarbeiterordner/Personalstammdaten_Arkadium.docx",
  "raw/HR/2_HR On- Offboarding/4_Ordner für Mitarbeiterordner/Anleitung Smarttime Webinterface.pdf",
  "raw/HR/2_HR On- Offboarding/4_Ordner für Mitarbeiterordner/Abwesenheitsantrag.pdf",
  "raw/HR/2_HR On- Offboarding/4_Ordner für Mitarbeiterordner/Vorlage_Spesenabrechnung.xlsx",
  "raw/HR/2_HR On- Offboarding/12_Vorlagen Dokumente/neue Abwesenheit.xlsx"
]
tags: [hr, phase-3, smarttime, zeiterfassung, personalstammdaten, spesen, treuhand-kunz]
---

# HR · Mitarbeiter-Ordner + Tools

Operative MA-Vorlagen und externe Tool-Referenzen · Onboarding-Artefakte.

## §A Personalstammdaten-Formular

**Dokument:** `Personalstammdaten_Arkadium.docx`

**Zweck:** Bei Neueintritt · MA füllt aus · sendet an **Vorgesetzter/Team-Leader + CC an `office@treuhand-kunz.ch`** (siehe Memory `reference_treuhand_kunz.md`).

### Felder

| Feld | Typ | HR-Tool-Mapping (`dim_mitarbeiter`) |
|------|-----|-------------------------------------|
| Name | Text | `nachname` |
| Vorname | Text | `vorname` |
| Adresse | Text | `adresse_strasse` |
| PLZ / Ort | Text | `adresse_plz` · `adresse_ort` |
| Geburtsdatum | Date | `geburtsdatum` |
| E-Mail (Lohnabrechnung) | Email | separat von `email` (typisch privat) → neues Feld `email_payroll` oder `email_private` |
| Zivilstand / Heiratsdatum | Text | `zivilstand` + neu `heirat_datum DATE` |
| Partner erwerbstätig? | Yes/No | neu `partner_erwerbstaetig BOOLEAN` |
| Kinder (Anzahl/Name/Geburtsdatum) | Text | neu `kinder JSONB` (Array von `{name, geburtsdatum}`) |
| Konfession | Text | neu `konfession TEXT` |
| AHV-Nummer | Text | `ahv_nr_hash` + `ahv_nr_encrypted` (Plan §6.1) |
| Quellensteuer-Pflicht | Yes/No | neu `quellensteuer_pflichtig BOOLEAN` |
| Aufenthaltsbewilligung | Text | `arbeitsbewilligung_typ` |
| Bankkonto IBAN | Text | **nicht im HR-Tool** · nur bei Payroll-System (Treuhand Kunz) |
| Arbeitspensum | Number | `fact_employment_contracts.pensum_percent` |
| Eintrittsdatum | Date | `eintrittsdatum` |
| Austrittsdatum (Praktikanten/Trainees) | Date | `austrittsdatum` + `contract_type IN ('befristet','praktikum','lehre')` |

### Schema-Delta v0.2

```sql
ALTER TABLE dim_mitarbeiter ADD COLUMN IF NOT EXISTS
  email_private TEXT,                          -- Private Email für Lohnabrechnung
  heirat_datum DATE,
  partner_erwerbstaetig BOOLEAN,
  kinder JSONB,                                -- [{name, geburtsdatum}]
  konfession TEXT,
  quellensteuer_pflichtig BOOLEAN DEFAULT false,
  quellensteuer_kanton CHAR(2);                -- Kanton für Quellensteuer-Tarif
```

### Onboarding-Task

Pre-Arrival-Phase (Woche 0 vor Stellenantritt):
- Task: "Personalstammdaten-Formular via HR-Self-Service ausfüllen"
- Trigger: nach Vertrags-Signatur
- Assignee: Neuer MA
- Deadline: spätestens Day-1
- Auto-Submit-Action: Email an Vorgesetzten + Treuhand Kunz mit PDF-Export

## §B Smarttime Webinterface (Zeiterfassung)

**Dokument:** `Anleitung Smarttime Webinterface.pdf`

**Was ist Smarttime:** aktuell eingesetztes externes Zeiterfassungs-System. Wird in Phase-3-Zeiterfassung-Modul **abgelöst** (siehe `specs/ARK_ZEITERFASSUNG_PLAN_v0_1.md`).

**Features laut Anleitung (Arkadium nutzt aktuell):**
- Web-basiertes Zeiterfassungs-Interface
- Tägliche Arbeitszeit-Erfassung (Pflicht · Tempus Passio §9)
- Korrekturanträge bis Freitag
- Absenzen-Erfassung (Ferien, Krankheit, Weiterbildung)

**Migrations-Relevanz:** Zeiterfassungs-Modul ersetzt Smarttime; Absenzen werden dann via `fact_absences` (HR-Tool) + Zeit-Mirror (Zeiterfassungs-Modul) erfasst.

## §C Abwesenheitsantrag

**Dokument:** `Abwesenheitsantrag.pdf`

**Aktueller Prozess (manuell):**
- MA druckt PDF aus oder füllt digital aus
- Unterschrieben zu Vorgesetztem
- Vorgesetzter signiert → zu HR/Backoffice
- HR bucht in Smarttime

**HR-Tool-Ersatz (Phase 3.1):**
- `fact_absences` + `fact_absences.approval_status`-Flow (siehe Drawer §4.3 Ferienantrag + §4.4 Krankmeldung in Interactions v0.1)
- PDF-Export-Option behalten für Papier-Archivierung (via Dok-Generator)

## §D Spesenabrechnung

**Dokument:** `Vorlage_Spesenabrechnung.xlsx`

**Aktueller Prozess:**
- Monatlich MA füllt Excel aus
- Belege beifügen
- Vorgesetzter signiert
- Backoffice verrechnet im Lohnlauf

**HR-Tool-Relevanz:** Spesen-Modul ist **nicht Teil von HR-Tool** (Plan §1 "Was das HR-Tool NICHT ist" · gehört in Billing/Backoffice-Modul Phase 3). Spesenpauschale auf `fact_provisionsvertrag_versions.spesenpauschale_chf_mt` ist nur **Pauschale** · darüber hinaus Spesen laufen separat.

**Phase-3-Billing (zukünftig):** eigenes Spesen-Modul mit OCR + Beleg-Upload.

## §E "neue Abwesenheit.xlsx" (Vorlagen Dokumente)

Interne Excel-Vorlage für HR zum Eintragen neuer Absenzen (Pre-HR-Tool-Era). Wird obsolet mit HR-Tool-Phase-3.1.

## Key Takeaways

### Schema-Erweiterungen für v0.2

```sql
-- Zusätzliche dim_mitarbeiter-Felder aus Personalstammdaten-Formular:
ALTER TABLE dim_mitarbeiter ADD COLUMN IF NOT EXISTS
  email_private TEXT,
  heirat_datum DATE,
  partner_erwerbstaetig BOOLEAN,
  kinder JSONB,
  konfession TEXT,
  quellensteuer_pflichtig BOOLEAN DEFAULT false,
  quellensteuer_kanton CHAR(2);
```

### Treuhand-Kunz-Integration-Tasks (Phase 3.0 Onboarding)

1. Auto-Send Personalstammdaten an `office@treuhand-kunz.ch` nach Vertragssignatur
2. Auto-Import Lohnausweise von Treuhand Kunz im Januar/Februar (§11B-4)
3. Bexio-CSV-Export für Monats-Delta (§11B-2)

### Dokument-Types-Erweiterung (Schema §11.1)

```sql
-- Neu in fact_hr_documents.document_type:
-- 'personalstammdaten_formular' — ausgefüllt vom MA pre-arrival
-- 'spesenabrechnung_monat' — monatliche Spesen-Submission
-- 'smarttime_export' — historische Zeiterfassungs-Daten
```

## Related

- [[hr-einfuehrungsordner-starterinfo]] · [[hr-academy]]
- Memory `reference_treuhand_kunz.md`
- `specs/ARK_ZEITERFASSUNG_PLAN_v0_1.md` (Smarttime-Ablösung)
