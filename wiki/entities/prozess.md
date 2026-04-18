---
title: "Prozess"
type: entity
created: 2026-04-08
updated: 2026-04-16
sources: ["ARK_GESAMTSYSTEM_UEBERSICHT_v1_3.md", "ARK_DATABASE_SCHEMA_v1_3.md", "ARK_BACKEND_ARCHITECTURE_v2_5.md", "ARK_PROZESS_DETAILMASKE_SCHEMA_v0_1.md", "ARK_PROZESS_DETAILMASKE_INTERACTIONS_v0_1.md"]
tags: [entity, prozess, core, pipeline]
---

# Prozess

Die Interview-Pipeline — vom Versand des Dossiers bis zur Platzierung. Ein Prozess verknüpft einen [[kandidat]] mit einem [[job]] und optional einem [[mandat]].

## Stage-Pipeline (9 Stages)

```
Exposé → CV Sent → TI → 1. Interview → 2. Interview → 3. Interview → Assessment → Angebot → Platzierung
```

**Stage-Flow-Regeln (präzisiert 2026-04-16):**
- **Forward-Skip** erlaubt: `CV Sent → 2nd`, `1st → Angebot`, `2nd → Angebot` usw. — Kunden machen nicht immer 3 Interviews
- **Backward-Sprung** erlaubt mit Confirm-Dialog + Pflicht-Grund (Audit in `fact_process_events`)
- **Platzierung** ist Ausnahme: setzt `stage='angebot'` voraus (Saga-Pre-Check V1), kein direkter Skip
- Win-Probability pro Stage aus `dim_process_stages`: 5/10/20/35/55/70/70/80/100 %

**Duplikatschutz:** Max 1 offener Prozess pro (`candidate_id`, `job_id`). „Offen" = Status ∈ {Open, On Hold, Stale}. Closed / Placed / Rejected zählen nicht.

## Status (8)

| Status | Beschreibung |
|--------|-------------|
| **Open** | Aktiv in der Pipeline |
| **On Hold** | Manuell pausiert (Grund + Wiederaufnahme-Datum) |
| **Stale** | Auto (Stage-Alter ≥ Schwelle) — jeder Activity-Log resettet |
| **Rejected** | Abgelehnt · 3 Reason-Tabellen (candidate / client / internal) |
| **Placed** | Erfolgreich platziert · 3-Mt-[[garantiefrist]] aktiv |
| **Cancelled** | Rückzieher nach Placement · 100 % Rückvergütung |
| **Closed** | Regulär abgeschlossen · Garantiefrist durch |
| **Dropped** | Admin-Override (Duplikat-Merge etc.) |

Per-Stage-Stale-Schwellen (aus `dim_process_stages.stale_days`): Exposé 14 · CV Sent 10 · TI 7 · 1st/2nd/3rd 14 · Assessment 21 · Angebot 10.

## Datenbank

- `fact_process_core` — Haupttabelle: Stage, Status, Rejection-Tracking
- `fact_process_events` — Datums-Stempel pro Meilenstein (Event-Log)
- `fact_process_finance` — Gehalt, Fees, Provisions-Splits (AM/CM/Hunter)
- `fact_candidate_guarantee` — 3-Mt-Garantiefrist (seriell pro Kandidat)
- `fact_protection_window` — 12/16-Mt-Schutzfrist (separates Konzept)
- `fact_direct_hire_claim` — Claim-Workflow (Direkteinstellung hintenrum)

## Interview-Terminierung

- **Kunde terminiert** (nicht Arkadium) — Arkadium begleitet via Coaching vor + Debriefing nach Interview
- Pro Interview: Reminder mit Datum + Prozess-Verknüpfung
- Auto: Outlook-Kalendereintrag via MS-Graph `CalendarReadWrite`
- Fehlt Interview-Datum nach Stage-Wechsel > 2 Tage → Auto-Reminder „Interview-Datum fehlt"

## Erstellungs-Wege

| Weg | Trigger | Voraussetzung |
|-----|---------|---------------|
| Automatisch | [[jobbasket]] Gate 2 Versand | 4 Docs komplett |
| Manuell Erfolgsbasis | AM/CM Klick „+ Prozess" | Kein aktives Target-Mandat |
| Nicht erlaubt | Manuell in aktiven Target-Mandat-Scope | Muss via Jobbasket |

## Placement-Flow (8-Step Saga TX1)

Server-Transaktion mit 7 Pre-Validations (V1–V7 in Interactions-Spec § TEIL 4):

1. Prozess → `stage='platzierung'`, `status='Placed'`
2. Finance (Erfolgsbasis-Fee ODER Mandat-Billing Stage 3 / Success / Slot)
3. Job → `status='filled'`, `filled_count++`
4. Schutzfrist-Rotation: alte honored, neue eröffnet (3 Mt für Garantie-Scope, 12 Mt für Nach-Placement-Scope)
5. Referral-Auslösung (falls vorhanden)
6. Stellenplan-Update (Mandat mit Projekt-Bezug)
7. Post-Placement-Reminders (5 auto: D+7 Onboarding, D+30, D+60, D+90, Garantie-Ende)
8. Andere offene Prozesse desselben Kandidaten → Auto-Reject „platziert anderswo"

**Placement-Drawer UI** (Mockup Phase F): zeigt 7 Datenvollständigkeits-Felder (Angebot-Datum · TC-Salär · Start-Datum · Honorar-Modell · Rechnungs-Adresse · Splits · Job-Filled-Count) + 8-Step-Saga-Preview. Button disabled bis alle grün.

## Garantiefrist (3 Mt · Post-Placement)

Siehe [[garantiefrist]] — seriell pro Kandidat (keine parallelen). Austritt innerhalb:

- **Erfolgsbasis** → Rückvergütungs-Staffel 100/50/25/10/0 % (Cancellation / Monat 1/2/3/>3)
- **Mandat** (Target Exklusiv / Taskforce) → Ersatzbesetzung, kein Geld zurück
- **Time** → keine Garantie (Kunde führt Prozess selbst)

**Refund-Drawer** (Mockup Phase F): modell-spezifischer Router via `procVarSwitch` — Erfolgsbasis-Pfad zeigt Staffel-Tabelle, Mandat-Pfad zeigt Ersatzbesetzungs-Hinweis.

## Rejection-Flow (3 Reason-Tabellen)

- `dim_rejection_reasons_candidate` — Kandidat-Seite (Gegenangebot, Gehalt, Standort, Fit, …)
- `dim_rejection_reasons_client` — Kunden-Seite (Skill-Mismatch, Fit, Budget, …)
- `dim_rejection_reasons_internal` — Intern (Duplikat, Fehl-Screening, Schutzfrist, …)

Rejection **triggert 12-Mt-Schutzfrist** wenn Kandidat bereits vorgestellt wurde (ab Stage ≥ CV Sent). Siehe [[direkteinstellung-schutzfrist]].

## Automationen

- Placement → Job-Filled, Schutzfrist-Rotation, Reminders, Kandidat-Sperre
- Stale-Detection (Nightly): Per-Stage-Schwelle-Check → `status='Stale'` + Notification
- Garantie-Ende-Auto: `placed_at + garantie_months` → `status='Closed'`
- Shortlist-Trigger bei Target-Mandaten (siehe [[mandat]])

## Frontend (Mischform)

- **Primär-Arbeitsort:** Pipeline-Modul `/processes` (Liste + 540-Slide-in-Drawer, 80 % Workflow)
- **Detailseite `/processes/[id]`:** 3 Tabs (Übersicht / Interviews & Honorar / Dokumente & History) für tiefere Analyse
- Stage-Pipeline als 9 Kacheln (done / current / future-Design), klickbar mit Confirm bei Rückwärts-Sprung
- 11 Drawers (Phase F): interview · rejection · placement · onHold · refund · invoice · feeOverride · history · reminder · upload · doc
- Keyboard-Shortcuts (Phase G): 1-3 Tabs, I Interview, H On-Hold, R Reject, P Place, T Theme, Esc Close

## Mockup-Status

Mockup `mockups/processes.html` (Phases A–G complete 2026-04-16):
- A Skelett · B Pipeline-Vis · C Tab 1 Übersicht · D Interviews + Honorar · E Dokumente + History · F 11 Drawers · G Quick-Actions + Stale-Logic
- 2086 Zeilen · div-bal 0 · script-bal 0
- Backup: `backups/processes.html.2026-04-16-phaseF.bak`
- Demo-Toggles: Mandat/Erfolgsbasis · Stale-Banner · Early-Exit · Post-Placement · Stale-Simulation (3/6/14 d)

## Related

- [[kandidat]] — Der Kandidat im Prozess
- [[job]] — Die Stelle
- [[mandat]] — Optional: das übergeordnete Mandat
- [[jobbasket]] — Wo der Prozess entsteht
- [[honorar-berechnung]] — Fees und Preismodelle
- [[garantiefrist]] — 3-Mt-Post-Placement-Garantie
- [[direkteinstellung-schutzfrist]] — 12/16-Mt-Anti-Umgehung
- [[provisionierung]] — Mitarbeiter-Payroll (CRM 2.0)
- [[reminders]] — Auto-Reminders bei Interviews und Post-Placement
