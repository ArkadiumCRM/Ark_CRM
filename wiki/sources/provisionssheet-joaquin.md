---
title: "Provisionssheet Joaquin Vega (CM)"
type: source
created: 2026-04-16
updated: 2026-04-16
sources: ["Provisionssheet Joaquin Vega.xlsx"]
tags: [source, provisionen, cm, beispiel, anonymisiert]
---

# Provisionssheet Joaquin Vega (CM)

Beispiel-Excel für Candidate Manager (Civil Engineering) 2026. **Nicht-echte Daten** (zur Illustration). Zeigt die Excel-getriebene Provisions-Abrechnung, wie sie heute (CRM 1.0) läuft und in CRM 2.0 abgelöst werden soll.

## Grunddaten

| Feld | Wert |
|------|------|
| Mitarbeiter | Joaquin Vega |
| Rolle | CM Civil Engineering |
| Geschäftsjahr | 2026 |
| Jahresbudget | CHF 440 000 |
| Budget / Quartal | CHF 110 000 |
| OTE (100 % ZEG) | CHF 40 000 |
| OTE / Quartal | CHF 10 000 |

## Sheet-Struktur

Zwei Tabs:
1. **Provisionsberechnung** — Haupttab mit Q1 – Q4 Blöcken, jeder Block:
   - Deal-Liste (Kandidat / Kunde / RG-Nr. / Start-Datum / Garantie-Ende / Net Fee / Zuteilungspunkte / Zuteilung Net Fee)
   - Q-Summen (erzielte Net Fees, Q-Budget, Q-ZEG, Q-Provisionsstufe)
   - Kummulative Summen (kum. Net Fees / kum. Budget / kum. ZEG / kum. Provisionsstufe / kum. Provision / 80 %-Abschlag / 20 %-Rücklage / Auszahlung / Restanz)
2. **Provisionsstaffel** — Lookup-Tabelle ZEG → Satz (identisch [[anhang-provisionsstaffel-cm]])

## Q1-Beispiel-Deals (2026)

| Kandidat | Kunde | Start | Garantie-Ende | Net Fee | Pkt | Zuteilung |
|----------|-------|-------|---------------|---------|-----|-----------|
| Jan Osterwalder | B+S AG | 2026-04-30 | 2026-06-30 | 28 000 | 1 | 14 000 |
| Michael Vidal | Frutiger AG | 2026-09-01 | 2026-11-30 | 49 998 | 1 | 24 999 |
| Thomas Aeschbacher | Hefti.Hess.M. | 2026-08-01 | 2026-10-31 | 50 900 | 1 | 25 450 |
| Pascal Bader | Selmoni Ing. | 2026-06-01 | 2026-08-31 | 22 000 | 2 | 22 000 |
| Daniel Maurer | Büchi Bau | 2026-07-01 | 2026-09-30 | 30 875 | 2 | 30 875 |
| Morgane Giorgi | Grolimund+P. | 2026-06-01 | 2026-08-31 | 25 243 | 1 | 12 621 |

**Punkt-Logik beobachtet:**
- `1` = 50 %-Anteil (Deal ist AM/CM-Split, Joaquin ist nur eine der zwei Rollen)
- `2` = 100 %-Anteil (Joaquin ist AM **und** CM)

## Q1-Berechnung

| Feld | Wert |
|------|------|
| Erzielte Net Fees (Zuteilung) | 129 945 |
| Q1-Budget | 110 000 |
| ZEG Q1 kum. | 118.13 % |
| Provisionsstufe (Staffel) | 128 % |
| Provision brutto | 12 800 |
| 80 %-Abschlag (ausgezahlt) | 10 240 |
| 20 %-Rücklage | 2 560 |

## Garantie-Ende-Feld

Spalte E: **„vorauss. Garantie-Ende (vorb. PZ-Verlängerung)"** — bestätigt die 3-Mt-[[garantiefrist]] (Start-Datum + 3 Mt). Mit Vorbehalt der Probezeit-Verlängerung durch Arbeitgeber.

## Erkenntnisse für CRM-Anbindung

- **Kum. Rechnung** über alle bisherigen Q eines Jahres (nicht einzelnes Q isoliert) → CRM-Engine 2.0 muss Jahresscope + kumulative Aggregation können
- **Punkt-Zuteilung** (1 vs. 2) = kritisches Eingangsfeld → `fact_process_finance.allocation_points` oder als `split_pct` modellieren
- **Zuteilung Net Fee** = `Net Fee × (Punkte / 2)` → deterministisch berechenbar, nicht separat speichern nötig
- **Garantie-Ende** triggert Rücklage-Freigabe → FK `fact_candidate_guarantee.end_at`

## Related

- [[provisionierung]] — Gesamtmodell
- [[anhang-provisionsstaffel-cm]] — Staffel-Referenz
- [[provisionssheet-peter]] — Head-of-Beispiel (Kontrast)
- [[garantiefrist]] — 3-Mt-Rücklage-Trigger
