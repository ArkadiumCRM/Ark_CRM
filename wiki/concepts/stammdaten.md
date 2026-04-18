---
title: "Stammdaten"
type: concept
created: 2026-04-08
updated: 2026-04-08
sources: ["ARK_GESAMTSYSTEM_UEBERSICHT_v1_2.md", "ARK_DATABASE_SCHEMA_v1_2.md", "ARK_BKP_CODES_STAMMDATEN.md"]
tags: [concept, stammdaten, master-data, kompetenzen]
---

# Stammdaten

Globale Master-Data-Tabellen (kein `tenant_id`). Gecacht mit 30 Min TTL.

## Kompetenz-Dimensionen

| Tabelle | Inhalt | Anzahl | Hierarchisch |
|---------|--------|--------|-------------|
| `dim_cluster` | Fachliche Cluster + Subcluster | ~15 + 66 | Ja (parent_cluster_id) |
| `dim_functions` | Berufsfunktionen | 190+ | Ja (parent_function_id) |
| `dim_focus` | Fachliche Skills (ersetzt dim_skills) | 160+ | Nein |
| `dim_edv` | Software/Tools | 120+ | Nein |
| `dim_education` | Ausbildungsgrad + konkrete Ausbildung | variabel | Nein |
| `dim_sector` | Branchen | variabel | Nein |
| `dim_sparte` | Sparten (ING/GT/ARC/REM/PUR) | 5 | Nein |
| `dim_languages` | Sprachen (CEFR A1-C2 + Muttersprache) | variabel | Nein |

## Branchenspezifisch (Bau)

### BKP-Codes (Baukostenplan)

`dim_bkp_codes` — Schweizer Baukostenplan-Codierung, hierarchisch (4 Ebenen). Jeder Code mit:
- `is_blue_collar` / `is_white_collar` — Welche Kandidatentypen relevant
- `is_relevant` — Für ARK-Recruiting relevant

Beispiele: BKP 21 = Rohbau 1 (Baumeisterarbeiten), BKP 24 = HLK-Anlagen, BKP 29 = Honorare

### SIA-Phasen

`dim_sia_phases` — Schweizer Bauprojekt-Phasen (SIA 112):
1. Strategische Planung
2. Vorstudien
3. Projektierung (Vorprojekt, Bauprojekt, Bewilligungsverfahren)
4. Ausschreibung
5. Realisierung (Ausführungsprojekt, Ausführung, Inbetriebnahme)
6. Bewirtschaftung

## Aktivitäts-Stammdaten

| Tabelle | Inhalt |
|---------|--------|
| `dim_activity_types` | 61+ Typen in 11 Kategorien |
| `dim_event_types` | Event-Typ-Katalog (13 Kategorien) |
| `dim_process_stages` | Prozess-Stages mit Win Probability |
| `dim_rejection_reasons_candidate` | Kandidaten-Ablehnungsgründe |
| `dim_rejection_reasons_client` | Kunden-Ablehnungsgründe |
| `dim_dropped_reasons` | Dropped-Gründe |
| `dim_cancellation_reasons` | Cancellation-Gründe |
| `dim_offer_refused_reasons` | Angebots-Ablehnungsgründe |
| `dim_jobbasket_rejection_types` | Prelead-Rejection (candidate/cm/am) |

## Template-Stammdaten

| Tabelle | Inhalt |
|---------|--------|
| `dim_email_templates` | 32 Email-Templates (erweiterbar) |
| `dim_prompt_templates` | AI Prompt-Templates (versioniert) |
| `dim_notification_templates` | Notification-Templates |

## Konfigurations-Stammdaten

| Tabelle | Inhalt |
|---------|--------|
| `dim_honorar_settings` | Honorar-Staffeln pro Tenant |
| `dim_automation_settings` | Alle Fristen/Schwellwerte (konfigurierbar) |
| `dim_tenant_features` | Feature Flags pro Tenant |
| `dim_ai_write_policies` | AI-Governance-Regeln |

## DEPRECATED

`dim_skills_master` + 9 zugehörige Tabellen — komplett ersetzt durch `dim_focus`.

## Related

- [[datenbank-schema]] — Vollständiges Schema
- [[kandidat]] — Kompetenz-Zuordnung über Bridge-Tabellen
- [[projekt-datenmodell]] — BKP-Codes und SIA-Phasen im Detail
