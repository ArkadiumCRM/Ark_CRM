---
title: "Provisionssheet Peter Wiederkehr (Head of)"
type: source
created: 2026-04-16
updated: 2026-04-16
sources: ["Provisionssheet Peter Wiederkehr.xlsx"]
tags: [source, provisionen, head-of, beispiel, teambudget, anonymisiert]
---

# Provisionssheet Peter Wiederkehr (Head of)

Beispiel-Excel für Head-of-Rolle (CI & BT — Civil Engineering + Building Technology) 2026. **Nicht-echte Daten**. Gleiche Sheet-Struktur wie [[provisionssheet-joaquin]], aber **Teambudget-Scope** statt Einzel-CM-Scope.

## Grunddaten

| Feld | Wert |
|------|------|
| Mitarbeiter | Peter Wiederkehr |
| Rolle | Head of CI & BT |
| Geschäftsjahr | 2026 |
| Jahresbudget (Teambudget) | CHF 1 500 000 |
| Budget / Quartal | CHF 375 000 |
| OTE (100 % ZEG) | CHF 90 000 |
| OTE / Quartal | CHF 22 500 |

## Unterschied zu CM/AM-Sheet

- **Teambudget** = Summe aller Umsätze in den betreuten Sparten (CI & BT) — **alle Mitarbeiter** der Sparte kontribuieren
- **Deal-Punkte durchgehend 2** (= voller Anteil des Teambudgets — Head of sieht jeden Deal ganz im eigenen Budget, nicht 50/50)
- **Stage-X-Prefix** im Kandidaten-Feld (z.B. „Stage 1, Projektleiter Heizung/Kälte") = Mandats-Stage-Zahlungen, die auch auf Teambudget zählen
- **Mandats-Stage-Einnahmen** werden einzeln als Deal-Zeile aufgeführt (Stage 1 + Stage 2 + Stage 3 eines Mandats = 3 Zeilen)

## Q1-Beispiel-Deals (Auszug)

| Zeile | Kunde | Net Fee | Pkt | Zuteilung |
|-------|-------|---------|-----|-----------|
| Jan Osterwalder | B+S AG | 28 000 | 2 | 28 000 |
| Stage 3 Michael Vidal | Frutiger AG | 49 998 | 2 | 49 998 |
| Stage 3 Thomas Aeschbacher | Hefti.Hess.M. | 16 967 | 2 | 16 967 |
| Pascal Bader | Selmoni Ing. | 22 000 | 2 | 22 000 |
| Daniel Maurer | Büchi Bau | 30 875 | 2 | 30 875 |
| Morgane Giorgi | Grolimund+P. | 25 243 | 2 | 25 243 |
| Christoph Portmann | Hefti.Hess.M. | 30 000 | 2 | 30 000 |
| Stage 2 Projektleiter Hochbau | Frutiger AG | 16 666 | 2 | 16 666 |
| Stage 1 Projektleiter HKK | Klinova AG | 12 850 | 2 | 12 850 |
| Stage 4 Zustzzahlung Dossier | Frutiger AG | 5 200 | 2 | 5 200 |
| Stage 2 Senior PL | Hefti.Hess.M. | 16 967 | 2 | 16 967 |
| Stage 1 Bauführer | Frutiger AG | 13 333 | 2 | 13 333 |

## Q1-Berechnung

| Feld | Wert |
|------|------|
| Erzielte Net Fees kum. | 295 614 |
| Q1-Budget | 375 000 |
| ZEG Q1 kum. | 78.8 % |
| Provisionsstufe (Staffel) | 58 % |
| Provision brutto | 13 050 |
| 80 %-Abschlag | 10 440 |
| 20 %-Rücklage | 2 610 |

**Staffel-Check:** ZEG 79 % → laut [[anhang-provisionsstaffel-cm]] = 58 % → 22 500 × 58 % = 13 050 ✓

## Time-Sonderfall

Time-Deals (siehe [[honorar-berechnung]] §4) zählen **nicht** regulär ins Teambudget — werden **ausserordentlich abgerechnet**. Konkrete Mechanik in CRM 2.0 noch offen.

Hinweis fürs CRM: `dim_mandate.business_model = 'time'` muss aus der ZEG-Kumulation **ausgeschlossen** werden.

## Erkenntnisse für CRM-Anbindung

- **Sparten-Rollup** nötig: `dim_mitarbeiter.head_of_sparten[]` + `fact_process_finance.sparten_id` → Aggregation über alle Prozesse der Sparte
- **Business-Model-Filter**: `WHERE business_model != 'time'` für Teambudget-ZEG
- **Mandats-Stages einzeln**: Stage 1 / 2 / 3 eines Mandats erscheinen als separate Deal-Zeilen zu ihren jeweiligen Zahlungszeitpunkten (nicht erst bei Placement-Stage 3)
- **Head-of sieht jeden Deal voll**: Keine 50/50-Splits auf Head-of-Ebene

## Related

- [[provisionierung]] — Gesamtmodell
- [[provisionssheet-joaquin]] — CM-Kontrast-Beispiel
- [[anhang-provisionsstaffel-cm]] — Staffel-Tabelle
- [[honorar-berechnung]] — Umsatz-Quellen (wo Net Fees herkommen)
