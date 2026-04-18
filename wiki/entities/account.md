---
title: "Account"
type: entity
created: 2026-04-08
updated: 2026-04-08
sources: ["ARK_GESAMTSYSTEM_UEBERSICHT_v1_2.md", "ARK_DATABASE_SCHEMA_v1_2.md", "ARK_FRONTEND_FREEZE_v1_9.md", "ARK_ACCOUNT_DETAILMASKE_INTERACTIONS_v0_1.md"]
tags: [entity, account, core, kontakt]
---

# Account

Firmen/Unternehmen die als Kunden oder potenzielle Kunden geführt werden.

## Datenbank

**Haupttabelle:** `dim_accounts` (operativ, tenant-isoliert)

**Verknüpfte Tabellen:**
- `dim_account_contacts` — Kontaktpersonen (historisiert)
- `dim_account_groups` — Firmengruppen/Konzerne
- `dim_account_aliases` — Alternative Firmennamen
- `fact_account_locations` — Standorte (HQ/Filiale/Fabrik/Büro)
- `fact_account_org_positions` — Stellenplan/Organigramm
- `fact_account_culture_analysis` — AI-Kulturanalyse
- `bridge_account_cluster/functions/focus/edv/sector/sparte` — Kompetenz-Zuordnungen (auto-aggregiert, read-only)

## Felder

- **Stammdaten:** Name, Rechtsform, Domain, Branche, Website
- **Klassifikation:** Status, Kundenklasse (A/B/C), Einkaufspotenzial (★/★★/★★★), No Hunt, Sparte
- **Intelligence:** Penetration Score, Hiring Potential, Growth Rate (3J), Revenue
- **Scraping:** Konfiguration, Intervall, letzte Ergebnisse
- **AGB-Tracking:** `agb_confirmed_at`, `agb_version` — Gate-Check bei Erfolgsbasis-Versand. Siehe [[agb-arkadium]]

### Einkaufspotenzial

| Sterne | Bedeutung |
|--------|-----------|
| ★ | 0-1 Positionen/Jahr |
| ★★ | 2-3 Positionen/Jahr |
| ★★★ | 3+ Positionen/Jahr |

### AGB-Gate

Vor CV/Exposé-Versand an Account ohne bestätigte AGB: Warnung "AGB noch nicht bestätigt. Fortfahren?" — kein Block, aber Risiko-Hinweis.

### Soft-Blocks

- **Blacklisted:** Warn-Dialog auf allen Aktionen + Audit Log
- **is_no_hunt:** Blockiert Kandidaten in Jobbasket/Prozesse, erlaubt aber Mandate/Email/Calls

### Temperatur

Automatisch berechnet, siehe [[temperatur-modell]]. Signale: Aktives Mandat/Prozess = Hot, AGB bestätigt = +2, Kundenklasse A = +2, Blacklisted = immer Cold.

### Functions/Focus

Auto-aggregiert (read-only) aus den Werdegängen aller verknüpften Kandidaten. Nicht manuell editierbar.

## Kontakte

`dim_account_contacts` — Ansprechpartner bei Accounts.

> [!warning] Architektur-Regel
> **Jeder Kontakt MUSS ein Kandidat sein.** Personen-Felder leben NUR auf `dim_candidates_profile`. Die Kontakt-Tabelle hat nur account-spezifische Felder. Siehe [[kontakt-kandidat-regel]].

**Account-spezifische Felder pro Kontakt:**
- `decision_level` — Entscheidungsebene
- `is_decision_maker` — Entscheidungsträger
- `is_champion` — Befürworter intern
- `is_blocker` — Blockiert Zusammenarbeit
- `relationship_score` — Beziehungsqualität
- `disc_type` — DISC Persönlichkeitstyp

**"Left Company":** Ausgegraut in Inactive-Sektion, historisch erhalten.

**Erstellung:** Suche nach existierendem Kandidaten → Match = Verknüpfung, kein Match = Hard Stop: Zuerst Kandidat erstellen.

## Profil & Kultur (Tab 2)

AI-generierte Kulturanalyse:
- Vision/Mission/Purpose
- Führung & Strategie
- 6 Kultur-Score-Dimensionen (Leistungsorientierung, Innovationskultur, Autonomie, Feedbackkultur, Hierarchieflachheit, Transformationsreife)
- Kulturfit-Score 0-100
- Workflow: AI erstellt Draft → AM reviewt sektionsweise

## Organisation (Tab 5)

Zwei Sub-Tabs:
- **Stellenplan:** Organigramm mit `fact_account_org_positions`, Status besetzt/vakant/geplant, bidirektionale Job-Verknüpfung
- **Teamrad:** Team-Analyse (DISC, Motivatoren, EQ etc.), Gap-Analyse, AI-Empfehlungen

## Frontend — 11 Tabs + 1 konditional

| # | Tab | Status | Details |
|---|-----|--------|---------|
| 1 | **Übersicht** | ✅ Spezifiziert | Stammdaten, Einkaufspotenzial, AGB-Status, Intelligence, Flags |
| 2 | **Profil & Kultur** | ✅ Spezifiziert | AI-Kulturanalyse, 6 Dimensionen, Kulturfit-Score |
| 3 | **Kontakte** | ✅ Spezifiziert | DataTable, Decision Maker/Champion/Blocker, "Left" Sektion |
| 4 | **Standorte** | ✅ Spezifiziert | Karten mit Google Maps Pins, max 1 HQ |
| 5 | **Organisation** | ✅ Spezifiziert | Sub-Tabs: Stellenplan + Teamrad |
| 6 | **Jobs & Vakanzen** | ✅ Spezifiziert | Aktive Stellen, Vakanz→Job Bestätigung |
| 7 | **Mandate** | ✅ Spezifiziert | Hybrid-Layout, typ-spezifische Konditionen (Target/Taskforce/Time), 5-Tab-Drawer |
| 8 | **Prozesse** | ✅ Spezifiziert | Analog Kandidat + Kandidaten-Spalte, CM-Spalte, Mandat-Filter, Cross-Nav aus Tab 7 |
| 9 | **History** | ✅ Spezifiziert | Analog Kandidat + Kontaktperson-Spalte, Account-ActivityTypes, Mandat-Filter |
| 10 | **Dokumente** | ✅ Spezifiziert | Analog Kandidat + Account-Dokumenttypen, Mandats-Verknüpfung, Aktivierungs-Trigger |
| 11 | **Reminders** | ✅ Spezifiziert | Analog Kandidat + Mandat/Job/Kontakt-Verknüpfung, Account-Auto-Reminders |
| (K) | **Firmengruppe** | ✅ Spezifiziert | Aggregations-Dashboard (read-only), Gruppenaccounts, KPIs, Cross-Account Kontakte |

> [!info] Spec-Status
> Account Interactions v0.1: **Alle Tabs vollständig spezifiziert** (1-11 + Firmengruppe). Tabs 8-11 analog Kandidatenmaske mit account-spezifischen Abweichungen.

## Header-Spezialitäten (Mockup)

- **Status-Dropdown** (Aktiv/On-Hold/DNC/Archiviert)
- **Sparte-Chip** (ARC/GT/ING/PUR/REM) — sync mit Tab 1 §4
- **Temperatur-Chip** (🔥 Hot / 🟡 Warm / 🔵 Cold)
- **Customer-Class-Pill** (Klasse A/B/C + Potenzial-Sterne)
- **AGB-Warning-Chip** bei ausstehender Bestätigung
- **Claim-Warning-Chip** + **Schutzfrist-Chip** mit Klick auf Tab 9
- **Holding-Chip** bei Gruppen-Zugehörigkeit
- **Snapshot-Bar sticky** (6 Slots, firmografisch · dupe-frei zum Header): Mitarbeitende CH · Wachstum 3J · Umsatz 2025 · Gegründet · Standorte · Kulturfit

## Duplikat-Erkennung

View `v_account_duplicates`:
- Fuzzy-Matching auf Firmennamen
- Matching auf `domain_normalized`
- Matching auf Handelsregister-UID

## Related

- [[kontakt-kandidat-regel]] — Kontakt = Kandidat Architektur-Entscheidung
- [[firmengruppe]] — Konzernstrukturen
- [[job]] — Jobs gehören zu Accounts
- [[mandat]] — Mandate gehören zu Accounts
- [[scraper]] — Automatisches Account-Monitoring
- [[temperatur-modell]] — Account-Temperatur
- [[agb-arkadium]] — Die geltenden AGB
