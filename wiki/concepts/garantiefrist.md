---
title: "Garantiefrist (Post-Placement)"
type: concept
created: 2026-04-16
updated: 2026-04-16
sources: ["ARK_Factsheet Personalgewinnung.pdf", "Arkadium_AGB_FEB_2023.pdf", "Provisionssheet Joaquin Vega.xlsx", "Provisionssheet Peter Wiederkehr.xlsx"]
tags: [concept, garantie, placement, rueckverguetung, ersatzbesetzung, provisionen]
---

# Garantiefrist (Post-Placement)

Zeitraum nach Placement, in dem Arkadium für den Platzierungserfolg einsteht. Bei vorzeitigem Austritt (Kündigung durch Kandidat oder Kunde) wird je nach Preismodell entweder **Rückvergütung** fällig (Erfolgsbasis) oder eine **Ersatzbesetzung** geschuldet (Mandat). Zu unterscheiden von der **Direkteinstellungs-Schutzfrist** (12/16 Mt, AGB — siehe [[direkteinstellung-schutzfrist]]).

## Dauer

- **Standard: 3 Monate** ab Start-Datum des Kandidaten
- **Dazukaufbar bis 6 Monate** (per Mandatsofferte-Klausel)
- **Probezeit-Verlängerung** des Arbeitgebers verschiebt das voraussichtliche Garantie-Ende mit (Feld „vorauss. Garantie-Ende (vorb. PZ-Verlängerung)" im Provisionssheet)

## Serielles Modell (wichtig)

> [!info] Keine parallelen Garantiefristen pro Kandidat
> Ein Kandidat hat zu jedem Zeitpunkt **höchstens eine** aktive Garantiefrist.
>
> - Placement → Garantiefrist 3 Mt aktiv
> - Innerhalb 3 Mt: Kündigung/Rausschmiss → Rückvergütung (Erfolgsbasis) oder Ersatzbesetzung (Mandat) fällig
> - Nach 3 Mt: Garantie abgelaufen, **keine weitere Garantie** bis zum nächsten Placement desselben Kandidaten
> - Neuer Placement desselben Kandidaten → neue 3-Mt-Garantie startet ab neuem Start-Datum

Deshalb braucht das Datenmodell **keinen** Parallelitäts-Check — `fact_candidate_guarantee.status='active'` WHERE kandidat_id = X ist immer maximal 1 Row.

## Verhalten bei vorzeitigem Austritt innerhalb Garantiefrist

### Erfolgsbasis (Target Best Effort) → Rückvergütungs-Staffel

Zählt ab Start-Datum, gestaffelt nach Austrittsmonat:

| Monat | Rückvergütung |
|-------|---------------|
| 1     | 50 %          |
| 2     | 25 %          |
| 3     | 10 %          |
| ab 4  | 0 %           |

**Cancellation** (Rückzieher vor Arbeitsantritt bzw. kurz nach Start) = **100 %** Rückvergütung.

### Mandat (Target Exklusiv / Taskforce) → Ersatzbesetzung

**Kein Geld zurück.** Arkadium startet eine neue Suche für dieselbe Stelle zum gleichen Konditions-Rahmen, bis Ersatz platziert ist.

### Time → keine Garantie

Kunde führt Prozess selbst, keine Garantieleistung geschuldet.

Details und Mandatskündigungs-Sonderfälle: [[honorar-berechnung]], [[mandat-kuendigung]].

## Zusammenhang mit Provisionen

Die Garantiefrist triggert zwei Provisions-Mechanismen (heute manuell in Excel, ab CRM-2.0 im [[provisionierung]]-Modul):

1. **20 % Rücklage** — Pro Deal werden bei Quartals-Provisionsauszahlung nur 80 % ausgezahlt, 20 % als Rücklage gehalten bis Garantie-Ablauf. Austritt → Rücklage wird gegengerechnet.
2. **Net-Fee-Storno** — Bei Austritt wird die Net-Fee-Zuteilung des Quartals rückabgewickelt (anteilig bei Rückvergütungs-Staffel).

## Datenmodell (Soll, CRM 2.0)

```sql
fact_candidate_guarantee (
  id,
  placement_id,             -- FK fact_process_finance / fact_placement
  kandidat_id,
  account_id,
  starts_at,                -- = Start-Datum Kandidat
  base_end_at,              -- = starts_at + 3 Monate
  extended_end_at,          -- falls PZ-Verlängerung / Zukauf
  end_at,                   -- effektives Ende
  status: 'active' | 'fulfilled' | 'breached_refund' | 'breached_replacement',
  breach_reason,            -- bei status != fulfilled
  breach_month,             -- 1 | 2 | 3 (für Rückvergütungs-Satz)
  refund_amount_chf,        -- nur bei Erfolgsbasis
  replacement_prozess_id    -- nur bei Mandat
)
```

## UI-Implikationen (Soll)

- **Prozess-Detail Tab 2**: Garantiefrist-Card mit Countdown, Breach-Drawer („Kandidat ist ausgetreten")
- **Kandidat-Profil Tab 6**: Garantie-Status-Badge am Placement-Eintrag
- **Account-Detail**: Anzahl Garantien offen / gebrochen (KPI)
- **Home-Widget** (Soll CRM 2.0): „Garantien laufen ab in < 14 Tagen" → proaktiv Check-in

## Abgrenzung zur Direkteinstellungs-Schutzfrist

| Merkmal | Garantiefrist | Direkteinstellungs-Schutzfrist |
|---------|--------------|---------------------------------|
| Dauer | 3 Mt (bis 6 Mt) | 12 Mt (auto-extend 16 Mt) |
| Auslöser | Erfolgreicher Placement | Vorstellungs-Ende ohne Placement |
| Trigger | Austritt Kandidat/Kunde | Kunde stellt Kandidat selbst ein |
| Rechtsfolge | Rückvergütung oder Ersatz | Honoraranspruch entsteht |
| Rechtsbasis | Factsheet / Mandatsofferte | AGB Klausel Direkteinstellung |
| Parallel möglich? | Nein (seriell pro Kandidat) | Nein (pro Vorstellung) |

## Related

- [[honorar-berechnung]] — Rückvergütungs-Staffel, Ersatzbesetzungs-Regel
- [[mandat-kuendigung]] — Sonderfälle Mandat-Exit
- [[direkteinstellung-schutzfrist]] — Das **andere** (12/16-Mt) Fristen-Konzept
- [[erfolgsbasis]] — Rückvergütungs-Mechanik
- [[provisionierung]] — 20 %-Rücklage-Logik
- [[rekrutierungsprozess]] — Post-Placement-Phase
