---
title: "Factsheet Personalgewinnung"
type: source
created: 2026-04-12
updated: 2026-04-12
sources: ["ARK_Factsheet Personalgewinnung.pdf"]
tags: [source, dienstleistungen, preise, target, time, taskforce]
---

# Factsheet Personalgewinnung

**Datei:** `raw/ARK_Factsheet Personalgewinnung.pdf`
**Status:** Aktuell (Stand April 2026)

## Zusammenfassung

Offizielles Dienstleistungs-Factsheet von Arkadium. Definiert die drei Kerndienstleistungen und deren Preismodelle. Diese Namen sind die kanonischen Bezeichnungen im CRM.

## Drei Dienstleistungen

### 1. Target — Einzelpositionen

Zwei Varianten:

**Best Effort (kein formelles Mandat)**
- Zugang zu geprüften Kandidaten aus parallelen Suchprozessen
- Kurzfristige Zusammenarbeit
- Honorar: 21-27% vom Jahresgehalt (ab 2027: 23-29%)
- Hunt-Status
- Läuft über AGB, kein Mandat im CRM nötig

**Exklusivmandat**
- Schwer besetzbare Leistungsfunktionen / strategische Positionen
- Verdeckte & exklusive Suche
- Honorar: Fixpauschale (35-40% vom Jahresgehalt als Richtwert für Kunden)
- Pauschale wird durch 3 geteilt → 3 Stage-Zahlungen
- No-Hunt-Status
- Garantiezeit: 3 Monate (dazukaufbar bis 6 Monate)
- Ersatzbesetzung geschuldet (nicht Rückvergütung)

Time-to-fill: 12-18 Wochen

### 2. Time — Feste Rekrutierungskapazitäten

Slot-basiertes Modell. Jeder Slot = eine Position, flexibel austauschbar.

| Paket | Slots | Listenpreis/Slot/Woche | Aktueller Preis/Slot/Woche |
|-------|-------|----------------------|--------------------------|
| Entry | 2 | CHF 2'250.- | **CHF 1'950.-** |
| Medium | 3 | CHF 1'950.- | **CHF 1'650.-** |
| Professional | 4 | CHF 1'650.- | **CHF 1'250.-** |

- Mindestens 2 Slots
- Dauer in Wochen definiert, monatlich abgerechnet
- Kündigungsfrist: 3 Wochen schriftlich
- Keine Mindestlaufzeit
- Kein Stundensatz — reine Wochenfee
- Degressive Staffel: mehr Slots = günstiger pro Slot
- Aktuell rabattierte Preise (neue Dienstleistung)

### 3. Taskforce — Team-/Standortaufbau

- Aufbau von Standorten, Abteilungen und Teams
- Mehrere Schlüsselrollen parallel
- Preislogik: Monatsfee + Sharing (Success Fee pro Position)
- Abschlusszahlung je Position individuell (z.B. PL vs. Abteilungsleiter unterschiedlich)
- Min. 3 Positionen

## Naming-Mapping (KRITISCH)

| Factsheet (kanonisch) | Altes CRM-Label | DB mandate_type |
|----------------------|-----------------|-----------------|
| Target (Exklusivmandat) | Einzelmandat | `'Target'` |
| Taskforce | RPO | `'Taskforce'` |
| Time | Time | `'Time'` |
| Target (Best Effort) | — | Kein Mandat, läuft über AGB/Erfolgsbasis |

## Verlinkte Wiki-Seiten

[[mandat]], [[honorar-berechnung]], [[erfolgsbasis]], [[agb-arkadium]]
