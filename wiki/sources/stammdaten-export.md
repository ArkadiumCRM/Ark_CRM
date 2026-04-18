---
title: "ARK Stammdaten Export v1.3"
type: source
created: 2026-04-08
updated: 2026-04-14
sources: ["ARK_STAMMDATEN_EXPORT_v1_3.md", "ARK_STAMMDATEN_EXPORT_v1_2.md"]
tags: [source, stammdaten, master-data, reference]
---

# ARK Stammdaten Export v1.3

**Aktuelle Datei:** `raw/Ark_CRM_v2/ARK_STAMMDATEN_EXPORT_v1_3.md`
**Vorherige Version:** `raw/Ark_CRM_v2/ARK_STAMMDATEN_EXPORT_v1_2.md` (bleibt erhalten)

## Zusammenfassung

Kompletter Master-Data-Katalog. v1.3 ergänzt v1.2 um **15 neue Stammdaten-Tabellen** (Sektionen 51–65) + Erweiterungen der `dim_automation_settings` (Sektion 66).

## Neu in v1.3 (14.04.2026)

### Neue dim_*-Tabellen

| # | Tabelle | Zweck |
|---|---------|-------|
| 51 | `dim_assessment_types` | 11 Assessment-Typen (MDI/Relief/ASSESS 5.0/DISC/EQ/Scheelen 6HM/Driving Forces/Human Needs/Ikigai/AI-Analyse/Teamrad-Session) |
| 52 | `dim_rejection_reasons_internal` | 11 Prozess-interne Ablehnungsgründe |
| 53 | `dim_honorar_settings` | Erfolgsbasis-Staffel 21/23/25/27% (+ Ausblick 2027 auf 23/25/27/29%) |
| 54 | `dim_culture_dimensions` | 6 Kultur-Analyse-Dimensionen |
| 55 | `dim_sia_phases` | SIA 112: 6 Haupt + 12 Teil hierarchisch (Peter-Entscheidung 14.04.) |
| 56 | `dim_dropped_reasons` | 6 Prozess-Drop-Gründe |
| 57 | `dim_cancellation_reasons` | 9 Rückzieher-nach-Placement-Gründe |
| 58 | `dim_offer_refused_reasons` | 10 Angebots-Ablehnungs-Gründe |
| 59 | `dim_vacancy_rejection_reasons` | 8 Scraper-Proposal-Ablehnungsgründe |
| 60 | `dim_scraper_types` | 7 Scraper-Typen (Phase 1 + 1 Phase 2) |
| 61 | `dim_scraper_global_settings` | 14 globale Scraper-Settings |
| 62 | `dim_matching_weights` | 7 Job-Matching-Gewichte + Threshold |
| 63 | `dim_matching_weights_project` | 6 Projekt-Matching-Gewichte |
| 64 | `dim_reminder_templates` | 10 Auto-Reminder-Templates |
| 65 | `dim_time_packages` | 3 Time-Mandat-Pakete (Entry/Medium/Pro) |
| 66 | Erweiterungen `dim_automation_settings` | ~20 neue Keys (Stale/Temperature/Schutzfrist/Billing/Batch-Hours/Referral/Matching) |

### Globale Konventionen (v1.3 bestätigt)

- **Sprachstandard DB:** `candidate_id` (englisch), nicht `kandidat_id`
- **Routen englisch:** `/candidates`, `/accounts`, `/mandates`, `/jobs`, `/processes`, `/assessments`, `/scraper`, `/company-groups`, `/projects`
- **Status-Enum-Sprache gemischt (intentional):** Mandat + Job deutsch, Prozess + Assessment englisch
- **`fact_jobs`** (operativ) — kein separates `dim_jobs`-Katalog
- **SIA-Phasen:** 6 + 12 hierarchisch

## v1.2-Inhalt (bleibt erhalten in Sektionen 1–50)

- 108 EDV-Skills in 11 Kategorien
- 190+ Berufsfunktionen mit Hierarchy und Level
- 500+ Ausbildungseinträge (EFZ bis Doktorat)
- 19 Cluster + 78 Subcluster
- 160+ Focus-Bereiche
- 35 Branchen
- 64 Activity Types in 11 Kategorien (inkl. #64 Schutzfrist Status-Änderung, auto)
- 60+ Event Types in 12 Kategorien
- 32 Email-Templates
- 15 konfigurierbare Automation-Settings
- 10 Mitarbeiter mit UUIDs und Rollen

## Anhang

Kreuzreferenz-Tabelle zu den Detailseiten-Specs, die diese Stammdaten verwenden (siehe Sektion "Anhang: Bezug zu Detailseiten-Specs" am Ende von v1.3).

## Verlinkte Wiki-Seiten

[[stammdaten]], [[datenbank-schema]], [[audit-2026-04-13-komplett]], [[audit-entscheidungen-2026-04-14]]
