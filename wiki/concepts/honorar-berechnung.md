---
title: "Honorar-Berechnung"
type: concept
created: 2026-04-08
updated: 2026-04-16
sources: ["ARK_GESAMTSYSTEM_UEBERSICHT_v1_2.md", "ARK_DATABASE_SCHEMA_v1_2.md", "ARK_Factsheet Personalgewinnung.pdf"]
tags: [concept, billing, fees, commissions, target, taskforce, time]
---

# Honorar-Berechnung

Provisionen und Honorare bei Placement. Vier Preismodelle je nach Dienstleistung.

## 1. Target Best Effort (ohne Mandat) — Erfolgsbasis-Staffel

| Gehalt (CHF) | Honorar | Ab 2027 |
|--------------|---------|---------|
| < 90'000 | 21% | 23% |
| < 110'000 | 23% | 25% |
| < 130'000 | 25% | 27% |
| ≥ 130'000 | 27% | 29% |

Pro Prozess individuell überschreibbar. Gespeichert in `dim_honorar_settings`. Siehe [[erfolgsbasis]].

## 2. Target Exklusivmandat — Fixpauschale ÷ 3

- **Pauschale:** Fixbetrag in CHF (35-40% vom Jahresgehalt als Richtwert, NICHT als Berechnungsformel)
- **3 gleiche Stage-Zahlungen:** Pauschale ÷ 3
  1. Bei Mandatsofferte unterschrieben
  2. Bei Shortlist-Trigger (konfigurierbare CV-Anzahl)
  3. Bei Placement
- **Garantiezeit:** 3 Monate Standard, dazukaufbar bis 6 Monate (siehe [[garantiefrist]])
- **Garantieleistung:** **Ersatzbesetzung** geschuldet (NICHT Rückvergütung!)
- **Zahlungsziel:** 10 Tage

> [!warning] Unterschied zu Best Effort
> Bei Target Best Effort gilt die Rückvergütungs-Staffel (AGB). Bei Target Exklusivmandat wird stattdessen eine **Ersatzbesetzung** geschuldet — kein Geld zurück, sondern eine neue Suche.

### Kündigungs-Szenario (Exit Option)

**Fall A — Arkadium kündigt:**
```
Rechnungsbetrag = (Gesamtmandatssumme × 0.80) − Σ(bereits bezahlte Stages)
```
Anzahlung wird nicht rückvergütet; 80% werden fällig.

**Fall B — Auftraggeber kündigt / besetzt anderweitig:**
```
Payout_Total = max(Σ(Stages bis inkl. laufender), Gesamtmandatssumme × 0.80)
Rechnungsbetrag = Payout_Total − Σ(bereits bezahlte Stages)
```
Laufende Stage wird fällig, **80% als Floor** auf Gesamt-Payout. Bei Kündigung in Stage 3 zahlt Kunde 100% (= Stage 3 regulär), in Stage 1/2 greifen die 80%.

Siehe [[mandat-kuendigung]] und Template [[rechnungen-mandat]].

## 3. Taskforce — Monatsfee + Success pro Position

- **Monatsfee:** Fixbetrag CHF/Monat für Recherche-Kapazität
- **Success Fee:** Individuell pro Position (z.B. Abteilungsleiter höher als Projektleiter)
- **Garantiezeit:** 3 Monate Standard, dazukaufbar bis 6 Monate
- **Garantieleistung:** Ersatzbesetzung geschuldet
- **Zahlungsziel:** 10 Tage

*(Hinweis: Das frühere "RPO"-Produkt wurde 2026 in **Taskforce** umbenannt — gleiches Produkt, nur neuer Name. Siehe [[rpo-offerte]].)*

## 4. Time — Wochenfee pro Slot

| Paket | Slots | Preis/Slot/Woche | Listenpreis |
|-------|-------|-----------------|-------------|
| Entry | 2 | CHF 1'950.- | ~~CHF 2'250.-~~ |
| Medium | 3 | CHF 1'650.- | ~~CHF 1'950.-~~ |
| Professional | 4 | CHF 1'250.- | ~~CHF 1'650.-~~ |

- Dauer in Wochen definiert, **monatlich abgerechnet**
- Keine Garantie/Ersatzbesetzung (Kunde führt Prozess selbst)
- Kündigungsfrist 3 Wochen schriftlich
- **Zahlungsziel:** 10 Tage

## Rückvergütung (nur Target Best Effort / Erfolgsbasis)

### Cancellation (Rückzieher nach Placement)
100% Rückvergütung

### Regulärer Austritt
| Monat | Rückvergütung |
|-------|--------------|
| 1 | 50% |
| 2 | 25% |
| 3 | 10% |

> [!info] Gilt NICHT für Mandate (Target Exklusiv, Taskforce)
> Bei Mandaten greift die Ersatzbesetzung, nicht die Rückvergütungs-Staffel.

## Provisions-Berechnung (Umsatz → Net Fee → Payroll)

**Umsatz-Seite (CRM 1.0):** Der bei Placement entstehende Net Fee wird automatisch berechnet aus:
- Kandidaten-Gehalt (`salary_candidate_target`)
- Honorarsatz (Mandat-Konditionen oder Erfolgsbasis-Staffel)
- Abzüglich Sub-Provisionen / externen Kosten (= Net Fee)

**Mitarbeiter-Zuteilung (CRM 1.0 — nur als Eingangsfeld):**
- `am_user_id` + `cm_user_id` pro Prozess
- Standard 50 / 50 Split bei unterschiedlichen Personen
- Researcher über `dim_kandidat.created_by_user_id`

**Payroll-Berechnung (CRM 2.0 via [[provisionierung]]):** ZEG-Staffel, Quartals-Kummulation, 80 / 20 Abschlag/Rücklage, Auszahlung Folgemonat — **nicht** in CRM 1.0 UI, nur Excel.

> [!warning] Scope-Grenze
> CRM 1.0 zeigt **Net Fees und Zuteilung**, keine Mitarbeiter-Auszahlungsbeträge. Siehe [[provisionierung]] für Scope-Abgrenzung.

## Datenbank

- `fact_process_finance` — Gehalt, Fees, Provisionen pro Prozess
- `fact_mandate_billing` — Zahlungsplan pro Mandat (Retainer/Success/Milestone)
- `dim_honorar_settings` — Tenant-konfigurierbare Honorarsätze (Erfolgsbasis-Staffel)
- `dim_mitarbeiter` — Kommissionssätze pro Mitarbeiter

## 5. Diagnostik & Assessment — Pauschalpreis

Eigenständige Dienstleistungs-Linie: siehe [[diagnostik-assessment]]. Pauschalpreis pro Package (z.B. CHF 10'000 für 2 Assessments), kein Stages-Modell.

## Related

- [[prozess]] — Wo die Fee berechnet wird
- [[mandat]] — Mandats-spezifische Konditionen
- [[mandat-kuendigung]] — 80%-Regel bei vorzeitigem Abbruch
- [[garantiefrist]] — 3-Mt-Post-Placement-Garantie (Rückvergütung/Ersatz-Trigger)
- [[direkteinstellung-schutzfrist]] — 12/16-Mt-Anti-Umgehung (separates Konzept)
- [[provisionierung]] — Mitarbeiter-Payroll (out-of-scope CRM 1.0)
- [[optionale-stages]] — Zusatzleistungen VI–X
- [[erfolgsbasis]] — Target Best Effort ohne Mandat
- [[factsheet-personalgewinnung]] — Offizielles Factsheet mit allen Preisen
