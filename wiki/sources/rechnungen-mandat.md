---
title: "Rechnungen Mandat (alle Varianten)"
type: source
created: 2026-04-12
updated: 2026-04-12
sources: ["General/1_ Rechnungen & -sheets/Mandat/*.docx", "General/1_ Rechnungen & -sheets/Rückerstattung/Vorlage_Rechnung Rückerstattung.docx"]
tags: [source, rechnung, mandat, billing, kuendigung, rueckerstattung]
---

# Rechnungen Mandat (alle Varianten)

**Verzeichnis:** `raw/General/1_ Rechnungen & -sheets/Mandat/`

## 3 Teilzahlungs-Rechnungen (Standard Exklusivmandat)

| Template | Auslöser | Beschreibung |
|----------|----------|--------------|
| `Vorlage_Rechnung Mandat 1. Teilzahlung.docx` | Vertragsunterzeichnung | Anzahlung Stage 1 |
| `Vorlage_Rechnung Mandat 2. Teilzahlung.docx` | 2 Kandidatendossiers vorgelegt | Stage 2 |
| `Vorlage_Rechnung Mandat 3. Teilzahlung.docx` | Beidseitige Vertragsunterzeichnung | Schlusszahlung |

Alle mit Mahnungs-Pendant in `Mahnungen/` und Du-Variante in `DU-Vorlagen Mandat/` (informelle Kunden-Ansprache).

## Kündigungs-Rechnung (kritisch!)

**Datei:** `Vorlage_Abschlusszahlung_Kündigung Mandat/Vorlage_Rechnung_Kündigung Mandat.docx`

**Logik (Beispiel HHM 4U AG):**
```
1. Stage: Suchstrategie, Ident, Pooling       → honoriert
2. Stage: Ansprache, Selektion, Briefing      → gekündigt
3. Stage: Vertragswesen, Abschluss, Off/On    → gekündigt
Abschlusszahlung (80% Gesamtsumme abzüglich Stage 1) → 17'220 CHF
```

**Formel:** `Rechnungsbetrag = (Gesamtmandatssumme × 80%) − bereits bezahlte Stages`

Begründungstext: *"Wir bedauern, dass das Mandat von Ihrer Seite vorzeitig beendet wurde… Wie im Vertrag vereinbart, stellen wir Ihnen 80 % der Honorarsumme in Rechnung."*

## Optionale Stage Rechnung

**Datei:** `Vorlage_Rechnung_Mandat_Optionale Stage.docx` — für Zusatzleistungen VI–X (siehe [[optionale-stages]]).

## Rückerstattungs-Rechnung (Gutschrift)

**Datei:** `Rückerstattung/Vorlage_Rechnung Rückerstattung.docx`

Referenziert **Ziffer 8 der AGB** (Kulanz-Rückvergütung, siehe [[agb-arkadium]]).
- Rückvergütung 100% / 50% / 25% / 10% je nach Austritts-Monat
- Gutschrift mit Valuta-Datum auf Kundenkonto
- Referenziert Original-Rechnungsnummer
- Nur für **Best Effort / Erfolgsbasis**, nicht für Mandate (dort: Ersatzbesetzung)

## Rechnungssheets (Excel)

- `Rechnungssheet_Mandat.xlsx` — Mandat-Tracking
- `Rechnungssheet_Best Effort.xlsx` / `_ohne Rabatt.xlsx` — Erfolgsbasis
- `Rechnungssheet_S. Burri.xlsx` — personalisiert

## CRM-Implikationen

- Alle 7 Rechnungstypen (3 Teilzahlungen + Kündigung + OptStage + Rückerstattung + Mahnung) als Template-IDs in `dim_dokument_templates`
- Kündigungs-Rechnung braucht neuen Auto-Trigger bei Mandat-Status = `Abgebrochen` + Seite = Kunde
- 80%-Regel als Formel in `fact_mandate_billing`

## Related

[[mandat-kuendigung]], [[rueckerstattung]], [[honorar-berechnung]], [[dokumente]]
