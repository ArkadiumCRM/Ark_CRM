---
title: "Provisionierung (Mitarbeiter-Vergütung)"
type: concept
created: 2026-04-16
updated: 2026-04-19
sources: ["Anhang - Provisionsstaffel CM.pdf", "Provisionssheet Joaquin Vega.xlsx", "Provisionssheet Peter Wiederkehr.xlsx", "Peter-Entscheidung 2026-04-19 Option D"]
tags: [concept, provisionen, vergütung, payroll, crm-1.0, kern-usp, commission-engine]
---

# Provisionierung (Mitarbeiter-Vergütung)

Interne Vergütungssystematik für Arkadium-Mitarbeiter. Pro Rolle unterschiedliches Modell. Seit Peter-Entscheidung **2026-04-19 (Option D)** ist die Commission-Engine **Phase 1 Kern-USP des ARK-CRM** — nicht mehr vertagt auf CRM 2.0.

> [!info] Scope-Update 2026-04-19 · Commission-Engine = CRM 1.0 Kern-USP
> **Die frühere Regel "CRM 1.0 = Umsatz-Tracking / CRM 2.0 = Provisions-Engine" ist mit Option D aufgehoben.** Commission-Engine wird als Phase-1-Kern gebaut (Spec: `specs/ARK_COMMISSION_ENGINE_SPEC_v0_1.md`). Grund: Markt-Validierung — Bullhorn/Invenias/Salesforce haben keine native Commission-Split-Logik für Headhunting → ARKs Killer-USP für SaaS-Phase-2. Break-Even-Modellierung ab ~5 SaaS-Kunden Jahr 4-5.
>
> **Scope Phase 1 inkludiert**: Commission-Ledger, ZEG-Staffel-Engine, Quartals-Kumulation, 80/20-Split, Researcher-Pauschale, Head-of-Teambudget-Rollup, Bonus-Ermessens-Flow für Nicht-Berechtigte, CSV/Excel/XML-Export (kein aktiver Bexio-API-Call in Phase 1).
>
> **Weiterhin ausserhalb Phase 1**: Eigene Swissdec-Payroll, Brutto/Netto-Berechnung, AHV/ALV/BVG/UVG-Integration, Quellensteuer-Tarif-Engine, Lohnausweis-Generierung. Payroll-Export an Treuhänder/Bexio als CSV bleibt Standard bis Phase 3.
>
> **Verwandt**: Memory `project_commission_model.md` + `project_arkadium_roles_2026.md` · Handoff-Strategy `specs/ARK_HR_STRATEGY_DECISION_v0_1.md`.

## Rollen-Modell

### 1. Researcher — Pauschale pro Placement

- **CHF 250 – 750** pro Placement eines Kandidaten, den der Researcher ins System geholt hat („CV-Upload-Owner")
- Pauschal, nicht gehalts-/ZEG-abhängig
- Fällig bei erfolgreicher Platzierung (nicht bei Garantie-Breach)
- Kein Jahresbudget, keine Staffel

**CRM-Eingangsfeld:** `dim_kandidat.created_by_user_id` (= Uploader) → Researcher-Zuteilung

### 2. CM / AM — Jahresziel + 50/50-Deal-Split + ZEG-Staffel

Das Kern-Provisions-Modell.

#### Budget-Parameter (pro Mitarbeiter)

- **Jahresbudget** (Netto-Fee-Ziel): CHF **360 k – 700 k** je nach Sparte/Senior-Level
- **Budget/Quartal**: Jahresbudget ÷ 4 (quartalisiert)
- **Pro-Rata** bei Untermonats-Anstellung (z.B. Start Mai → 8/12 Budget)
- **Variables Gehalt bei 100 % ZEG**: fixer OTE-Wert (z.B. CHF 40 k bei Joaquin CM, CHF 90 k bei Head of) — zahlbar bei Zielerreichung

#### Deal-Zuteilung

- Jeder Placement wird **50/50 zwischen AM und CM** aufgeteilt
- Ist derselbe Mitarbeiter AM **und** CM → voller Anteil (100 %)
- Zuteilungspunkte im Sheet: **1 = Halber Anteil** (Split), **2 = Voller Anteil** (Alleinstellung oder Head-of-Team-Rollup)

**CRM-Eingangsfeld:** `fact_process_finance.am_user_id` + `cm_user_id` + `split_am_pct` + `split_cm_pct`

#### ZEG (Zielerreichungsgrad)

```
ZEG = Σ(zugeteilte Net Fees im Zeitraum) / Σ(Budget im Zeitraum)
```

Berechnet **kummulativ** über die Quartale (Q1, Q1+Q2, Q1+Q2+Q3, Jahr).

#### Provisionsstaffel (aus `Anhang - Provisionsstaffel CM.pdf`)

| ZEG-Bereich | Provisionssatz (% vom OTE) |
|-------------|-----------------------------|
| < 50 %      | 0 %                          |
| 50 – 59 %   | 10 – 28 % (+2 % pro 1 % ZEG) |
| 60 – 69 %   | 30 – 39 % (+1 % pro 1 % ZEG) |
| 70 – 99 %   | 40 – 98 % (+2 % pro 1 % ZEG) |
| 100 %       | **100 %** (Zielpunkt)        |
| 101 – 150 % | 102 – 160 % (+2 %, ab 100 % wieder +2/%)|
| > 150 %     | +1 % pro 1 % ZEG darüber (degressiv) |

Wichtige Schwellen:
- ZEG < 50 % → **keine Provision**
- ZEG = 50 % → Sprung auf 10 %
- ZEG = 60 – 70 % → flacher (nur +1 %/%)
- ZEG = 70 – 100 % → steil (+2 %/%)
- ZEG > 150 % → degressiv (+1 %/%)

> [!note] PDF-Staffel-Tabelle hat im Bereich 100–150 % pro +1 % ZEG +2 % Provision (z.B. 110 % → 120 %, 120 % → 130 %, 150 % → 160 %). Ab >150 % wechselt die Steigung auf +1 %/%. Details siehe [[anhang-provisionsstaffel-cm]].

#### Quartals-Auszahlung

- Abrechnung **quartalsweise**, Auszahlung im **Folgemonat**:
  - Q1 → April
  - Q2 → Juli
  - Q3 → Oktober
  - Q4 → Januar
- **80 % Abschlag** + **20 % Rücklage** pro Quartal
- Die 20 %-Rücklage wird erst frei, wenn die [[garantiefrist]] des zugrundeliegenden Deals abgelaufen ist (3 Mt). Austritt → Rücklage wird gegengerechnet.

### 3. Head of — Teambudget

- **Teambudget** = Summe aller Umsätze der betreuten Sparten (alle Mitarbeiter darunter)
- Jahresziel-Range: **CHF 1.0 M – 1.5 M+** (siehe Peter Wiederkehr Provisionssheet: 1.5 M für CI & BT)
- **Alle Umsatz-Typen zählen**: Erfolgsbasis-Deals, Target Exklusivmandate, Taskforce
- **Time** → **ausserordentlich abgerechnet** (Logik CRM 2.0 noch nicht definiert)
- ZEG-Staffel analog CM/AM (gleiche Provisionsstaffel)
- OTE-Basis höher (z.B. CHF 90 k bei 100 % ZEG)

**CRM-Eingangsfeld:** `dim_mitarbeiter.role = 'head_of'` + `dim_mitarbeiter.sparten_scope[]` (welche Sparten zählen zum Teambudget)

## Konkrete Beispiele (aus den Excel-Sheets)

### Joaquin Vega — CM Civil Engineering 2026

| Parameter          | Wert       |
|--------------------|-----------|
| Jahresbudget       | 440 000   |
| Budget / Quartal   | 110 000   |
| OTE (100 % ZEG)    | 40 000    |
| OTE / Periode (Q)  | 10 000    |
| Q1 Net Fees kum.   | 129 945   |
| Q1 ZEG kum.        | 118 %     |
| Q1 Prov-Satz       | 128 %     |
| Q1 Provision       | 12 800    |
| 80 % Abschlag      | 10 240    |
| 20 % Rücklage      | 2 560     |

### Peter Wiederkehr — Head of CI & BT 2026

| Parameter          | Wert         |
|--------------------|-------------|
| Jahresbudget       | 1 500 000   |
| Budget / Quartal   | 375 000     |
| OTE (100 % ZEG)    | 90 000      |
| OTE / Periode (Q)  | 22 500      |
| Q1 Net Fees kum.   | 295 614     |
| Q1 ZEG kum.        | 79 %        |
| Q1 Prov-Satz       | 58 %        |
| Q1 Provision       | 13 050      |
| 80 % Abschlag      | 10 440      |
| 20 % Rücklage      | 2 610       |

## CRM-Felder (die bereits in 1.0 erfasst werden müssen)

Für spätere Provisions-Engine-Anbindung (CRM 2.0) sind folgende Felder kritisch:

| Feld | Tabelle | Zweck |
|------|---------|-------|
| `am_user_id` | `fact_process_finance` | AM-Zuteilung |
| `cm_user_id` | `fact_process_finance` | CM-Zuteilung |
| `split_am_pct` + `split_cm_pct` | `fact_process_finance` | Wenn != 50/50 (selten) |
| `researcher_user_id` / `created_by_user_id` | `dim_kandidat` | Researcher-Pauschale-Zuteilung |
| `net_fee_chf` | `fact_process_finance` | Net Fee = Rechnungsbetrag minus Sub-Fees |
| `placement_date` | `fact_process_finance` | Für Quartalszuordnung |
| `sparten_id` | `dim_jobs` | Head-of-Teambudget-Rollup |
| `guarantee_end_at` | `fact_candidate_guarantee` | Rücklage-Freigabe-Trigger |
| `salary_candidate_target_chf` | `fact_process_finance` | Basis Erfolgsbasis-Staffel |
| `business_model` | `dim_mandate` / `fact_process_finance` | Mandat / Erfolgsbasis / Taskforce / Time (Time = ausserordentlich) |

## Scope-Update 2026-04-19 · Commission-Engine in CRM 1.0

Mit Option D (Peter-Entscheidung 2026-04-19) ist folgendes **im Scope Phase 1**:

- ✅ Provisions-Staffel-Engine (ZEG → Satz)
- ✅ Quartals-Kumulation
- ✅ 80/20-Splitting Abschlag/Rücklage
- ✅ Auszahlungs-Workflow (internal) + CSV/Excel/XML-Export
- ✅ Pro-Rata-Berechnung bei Eintritt/Austritt
- ✅ Head-of-Teambudget-Rollup
- ✅ Researcher-Pauschale-Zuteilung
- ✅ Rücklage-Freigabe nach Garantie-Ablauf
- ✅ Bonus-Ermessens-Flow (Nicht-Berechtigte: GF-Ermessen)
- ✅ Commission-UI in Mockups (eigene Views: MA-Self, Head-of, Admin/Backoffice)

**Weiterhin ausserhalb Phase 1 (Treuhänder-Modell bleibt):**
- ❌ Eigene Swissdec-Zertifizierung
- ❌ AHV/IV/EO/ALV-Berechnung
- ❌ BVG-Integration
- ❌ Quellensteuer-Tarif-Engine
- ❌ Lohnausweis-Generierung
- ❌ Brutto/Netto-Berechnung
- ❌ Aktiver Bexio-API-Call (nur CSV-Export für Peter Phase 1 · API-Integration als eigenes Phase-2-Wave)
- ❌ Time-Sonderabrechnung (Mechanik noch offen, Phase 3)

**Grundsatz**: Commission-Engine berechnet **was** an jede Person ausgezahlt werden soll. Treuhänder/Bexio/Abacus macht das **wie** (Brutto/Netto-Lohnlauf, Swissdec-Meldungen). ARK-CRM übergibt das Resultat als Export-File an den Payroll-Provider.

## Quellen

- [[anhang-provisionsstaffel-cm]] — Provisionsstaffel-PDF (40 %→100 %→160 %)
- [[provisionssheet-joaquin]] — CM-Beispiel mit Quartals-Kummulation
- [[provisionssheet-peter]] — Head-of-Beispiel mit Teambudget

## Related

- [[honorar-berechnung]] — Umsatz-seitige Honorar-Modelle (was den Net Fee erzeugt)
- [[garantiefrist]] — 3-Mt-Rücklage-Trigger
- [[rekrutierungsprozess]] — Wo Placements entstehen
- [[mandat]] — Mandats-Net-Fee-Quellen
- [[erfolgsbasis]] — Erfolgsbasis-Net-Fee-Quellen
