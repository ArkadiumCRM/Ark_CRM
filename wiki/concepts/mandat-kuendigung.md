---
title: "Mandat-Kündigung (Exit Option)"
type: concept
created: 2026-04-12
updated: 2026-04-12
sources: ["General/4_Account Management/Mandatsofferte/Vorlage_Mandatsofferte.docx", "General/1_ Rechnungen & -sheets/Mandat/Vorlage_Abschlusszahlung_Kündigung Mandat/Vorlage_Rechnung_Kündigung Mandat.docx"]
tags: [concept, mandat, kuendigung, exit-option, billing, crm-gap]
---

# Mandat-Kündigung (Exit Option)

Regelt vorzeitiges Beenden eines laufenden [[mandat]]s von einer der beiden Seiten. In der [[mandatsofferte-vorlage]] (Klausel II) verbindlich geregelt — **Kernrelevanz für CRM, bisher unvollständig abgebildet**.

## Die zwei Fälle (aus der Offerte)

### Fall A — Arkadium kündigt
*"Falls für die Stelle keine Kandidaten identifiziert oder keine weiteren vorgelegt werden können, behält sich die Arkadium AG das Recht vor, vom Mandat zurückzutreten"*

**Konsequenzen:**
- Keine Rückvergütung bereits bezahlter Stages/Anzahlung
- **Zahlung von 80% der Gesamtmandatssumme** fällig

**Typischer Grund:** Markt gibt keine Kandidaten her, Search-Strategie erschöpft.

**Praxis (geklärt 2026-04-13):** Fall A ist bisher **nie eingetreten**. Arkadium macht stattdessen weiter oder erweitert das Mandat mit zusätzlichen Idents (Option VI). Im CRM als seltener Ausnahmefall abbilden, keine vordefinierte Kündigungs-Schwelle — individuelle Entscheidung durch Admin.

### Fall B — Auftraggeber kündigt (oder besetzt anderweitig)
*"Sollte die Auftraggeberin die oben genannte Position anderweitig besetzen oder vom Vertrag zurücktreten, obwohl das Projekt bereits aufgegleist ist, wird die laufende Stage resp. mindestens 80% der Gesamtmandatssumme fällig."*

**Konsequenz (klargestellt mit Peter 2026-04-12):**
- **Laufende Stage wird fällig**, aber **80% der Gesamtmandatssumme sind ein Floor auf den Gesamt-Payout**
- Regel: Insgesamt gezahlt wird `max(alle Stages bis inkl. laufender, 80% × Gesamtsumme)`
- Rechnungsbetrag = Floor-Total − bereits bezahlte Stages
- Beispiele:
  - Kündigung in Stage 1 (nichts bezahlt): 80% > Stage 1 → **80% werden fällig**
  - Kündigung in Stage 2 (Stage 1 bezahlt = 33%): Stage 1+2 = 66% < 80% → **80% werden fällig**, abzgl. bezahlter 33% → Rechnung 47%
  - Kündigung in Stage 3 (Stage 1+2 bezahlt = 66%): Stage 1+2+3 = 100% > 80% → **Stage 3 normal fällig** (die 80% greifen nicht mehr)

**Typische Gründe:**
- Anderweitige Besetzung (eigener Netzwerk-Kandidat, anderer Dienstleister trotz Exklusivität, interne Lösung)
- Projekt-Storno (Restrukturierung, Budgetwegfall, Merger)
- Siehe auch [[direkteinstellung-schutzfrist]] für Sonderfall: Kunde stellt **einen von uns identifizierten Kandidaten direkt ein**

## Berechnungs-Formel (Kündigungs-Rechnung)

```
Fall A (Arkadium kündigt):
  Payout_Total = Gesamtmandatssumme × 0.80
  Rechnungsbetrag_netto = Payout_Total − Σ(bereits_bezahlte_Stages)

Fall B (Auftraggeber kündigt):
  Payout_Total = max(Σ(Stages_bis_inkl_laufender), Gesamtmandatssumme × 0.80)
  Rechnungsbetrag_netto = Payout_Total − Σ(bereits_bezahlte_Stages)
```

**Beispiel Fall A** (Arkadium kündigt, Stage 1 bereits honoriert):
- Gesamtmandat: CHF 34'025
- Stage 1 honoriert: CHF 10'000
- Payout_Total = CHF 27'220 (80%)
- Rechnungsbetrag = CHF 27'220 − CHF 10'000 = CHF 17'220 netto
- + 8.1% MwSt = CHF 18'614.80 (Template-Beispiel aus `Vorlage_Rechnung_Kündigung Mandat.docx`)

**Beispiel Fall B** (Auftraggeber kündigt in Stage 3, Gesamt CHF 30'000, 3 gleiche Stages à CHF 10'000):
- Stage 1+2 bereits bezahlt: CHF 20'000
- Stages bis inkl. Stage 3 = CHF 30'000
- 80% = CHF 24'000
- Payout_Total = max(30'000, 24'000) = CHF 30'000
- Rechnungsbetrag = CHF 30'000 − CHF 20'000 = CHF 10'000 (= Stage 3 normal, 80% greifen nicht)

**Beispiel Fall B** (Auftraggeber kündigt in Stage 2, nichts bezahlt, Gesamt CHF 30'000):
- Stages bis inkl. Stage 2 = CHF 20'000
- 80% = CHF 24'000
- Payout_Total = max(20'000, 24'000) = CHF 24'000 (80%-Floor greift)
- Rechnungsbetrag = CHF 24'000 − 0 = CHF 24'000

## CRM-Datenmodell (Soll)

`fact_mandate` Ergänzungen:
- `terminated_by: 'arkadium' | 'client' | null`
- `terminated_reason: 'no_candidates' | 'client_hired_elsewhere' | 'client_direct_hire' | 'project_cancelled' | 'other'`
- `terminated_at`, `terminated_note`
- `termination_invoice_id` (FK zu `fact_mandate_billing`)

`fact_mandate_billing` neues Typ-Enum: `'termination'` (zusätzlich zu existing stage-types).

## Auto-Trigger (Soll)

1. **Status-Wechsel** `Aktiv → Abgebrochen` öffnet Drawer "Kündigungsgrund + Seite"
2. **Auto-Berechnung** der Abschlusszahlung nach 80%-Formel
3. **Rechnungserstellung** via `Vorlage_Rechnung_Kündigung Mandat.docx`
4. **Locking** der Longlist (kein weiteres Research)
5. **Audit-Log** via [[event-system]]

## Spezialfall: Exklusivitätsbruch

Bruch der 3-Wochen-Exklusivität (Klausel I) während Offerte-Phase: auch schon Rechtsfall. **Noch nicht im CRM** — müsste als `exclusivity_end_date` auf `fact_mandate` mit Verletzungs-Detection.

## Garantiefrist-Fall (kein Kündigungsgrund, aber verwandt)

Kandidat verlässt Stelle innerhalb Garantiefrist (3 Monate Standard, 6 Monate mit [[optionale-stages]] X) → **Ersatzbesetzung** geschuldet (NICHT Geld zurück). Unterscheidung zur [[rueckerstattung]] bei Best Effort.

## Unscharfe Punkte

- Wie wird bei Fall A argumentiert dass "keine Kandidaten findbar" — Schwelle/Beweisbarkeit?
- **Geklärt 2026-04-12:**
  - Fall A (Arkadium kündigt): fix 80% der Gesamtsumme − bezahlte Stages
  - Fall B (Auftraggeber kündigt): laufende Stage wird fällig, aber **80% sind Floor auf Gesamt-Payout** → bei Kündigung in Stage 3 zahlt er 100% (= normal Stage 3), in Stage 1/2 mindestens 80%

## Related

[[mandat]], [[direkteinstellung-schutzfrist]], [[mandatsofferte-vorlage]], [[rechnungen-mandat]], [[honorar-berechnung]], [[mandat-lifecycle-gaps]]
