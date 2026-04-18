---
title: "ARK Account Detailmaske Interactions v0.3"
type: source
created: 2026-04-08
updated: 2026-04-14
sources: ["ARK_ACCOUNT_DETAILMASKE_INTERACTIONS_v0_3.md", "ARK_ACCOUNT_DETAILMASKE_INTERACTIONS_v0_2.md", "ARK_ACCOUNT_DETAILMASKE_INTERACTIONS_v0_1.md"]
tags: [source, account, interactions, behavior, assessments, schutzfristen, claim-workflow, gruppen-scope, credits-typisiert]
---

# ARK Account Detailmaske Interactions v0.3

**Aktuelle Datei:** `specs/ARK_ACCOUNT_DETAILMASKE_INTERACTIONS_v0_3.md`
**Vorherige Versionen:** `specs/alt/ARK_ACCOUNT_DETAILMASKE_INTERACTIONS_v0_2.md` und `v0_1.md`
**Status:** v0.3 = Update mit Gruppen-Schutzfrist-Scope + AM-Claim + typisierten Credits (14.04.2026)
**Begleitdokument:** [[account-schema]] v0.1

## Zusammenfassung

Behavioral Spec für die Account-Detailansicht. **13 feste Tabs + 1 konditionaler Tab** (Firmengruppe).

## Schlüssel-Erkenntnisse

> [!warning] Architektur-Entscheidung
> **Kontakt = Kandidat Regel:** Jeder Kontakt MUSS ein Kandidat sein (`candidate_id` effektiv NOT NULL). Personen-Felder leben NUR auf `dim_candidates_profile`, Kontakt-Tabelle hat nur account-spezifische Felder.

- Tab 2: **Profil & Kultur** — AI-generierte Kulturanalyse mit 6 Score-Dimensionen + Kulturfit-Score 0-100
- Tab 5: **Organisation** — Stellenplan mit besetzt/vakant/geplant Status, bidirektionale Job-Verknüpfung
- Tab 6: **Jobs & Vakanzen** — `fact_vacancies` deprecated, alles in `fact_jobs` mit confirmation_status
- Functions/Focus auf Accounts sind auto-aggregiert (read-only) aus verknüpften Kandidaten-Werdegängen
- Soft-Blocks: Blacklisted Accounts → Warn-Dialog + Audit Log. is_no_hunt → Block für Jobbasket/Prozesse
- Account-Temperatur-Modell analog Kandidat aber mit anderen Signalen

## Neu in v0.3

- **Tab 9 Schutzfristen: Gruppen-Scope-Einträge** mit Label "Gruppen-Schutzfrist" sichtbar (schliesst P0.2-Audit-Gap)
- **Claim stellen: AM alleine** (kein Admin-Gate)
- **Claim-Billing-Kontext:** auto Mandats-Kondition vs. Erfolgsbasis-Staffel je nach Ursprungs-Presentation
- **Tab 8 Assessments Credits-Typen-Übersicht:** Top-Banner mit aggregierter MDI/Relief/ASSESS 5.0-Breakdown
- **Credits-Konfiguration-Drawer:** Multi-Row-Editor (Typ + Quantity + Einzelpreis)
- **Firmengruppe-Route:** `/company-groups/[id]` (englisch)
- TEIL-Nummerierung: 8a/8b/8c (zuvor 8/8b/8c)
- Sprachstandard: `candidate_id` konsistent

## Alt v0.2

- **Tab 8 Assessments:** Alle Assessment-Aufträge mandatsbezogen + eigenständig, Teamrad-Abdeckungs-KPI, 7-Schritt-Beauftragungs-Flow, Status-Pipeline, Cross-Navigation zu Mandat-Option IX und Kandidaten-Tab
- **Tab 9 Schutzfristen:** Matrix aller `fact_protection_window`, Claim-Workflow (Info-Request mit 10-Tage-Auto-Extension auf 16 Monate, Claim stellen, Abschliessen ohne Claim), manueller Eintrag für Legacy-Fälle
- **Header:** Quick-Action "Assessment beauftragen" + Claim-Banner bei offenen Schutzfrist-Verletzungen
- **Tab-Numerierung:** 11 → 13 Tabs (Prozesse/History/Dokumente/Reminders verschoben)

## Schema-Delta

7 neue Tabellen (v0.1), zusätzlich ab v0.2:
- `fact_assessment_order`, `fact_assessment_billing`
- `fact_candidate_presentation`, `fact_protection_window`

## Verlinkte Wiki-Seiten

[[account]], [[account-schema]], [[kontakt-kandidat-regel]], [[temperatur-modell]], [[diagnostik-assessment]], [[direkteinstellung-schutzfrist]], [[mandat-kuendigung]], [[referral-programm]]
