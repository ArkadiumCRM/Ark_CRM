---
title: "ARK Firmengruppe Detailmaske Schema v0.1"
type: source
created: 2026-04-13
updated: 2026-04-13
sources: ["ARK_FIRMENGRUPPE_DETAILMASKE_SCHEMA_v0_1.md"]
tags: [source, firmengruppe, schema, konzern, aggregation]
---

# ARK Firmengruppe Detailmaske Schema v0.1

**Datei:** `specs/ARK_FIRMENGRUPPE_DETAILMASKE_SCHEMA_v0_1.md`
**Status:** v0.1 = Erstentwurf
**Begleitdokument:** [[firmengruppe-interactions]] v0.1

## 6 Tabs

1. Übersicht — Gruppen-Stammdaten, Gesellschaften-Liste, aggregierte KPIs
2. Kultur — Holding-weite Kultur-Analyse (AI-Hybrid)
3. Kontakte — Aggregiert über alle Gesellschaften, Read-only
4. Mandate & Prozesse — Gruppenübergreifende Taskforces + Account-spezifische + alle Prozesse
5. Dokumente — Rahmenverträge, Master-NDAs, Konzern-AGB (mit Subset-Gültigkeit)
6. History — Gruppen-Events + signifikante Account-Events (Mix-Strategie)

## Schlüssel-Entscheidungen (13.04.2026)

- **2-stufig flach**: Gruppe → Gesellschaften, keine Sub-Gruppen
- **Kein eigener Group-AM**, Admin ownt Gruppen-Aktionen
- **Gruppenübergreifende Taskforces** via `bridge_mandate_accounts` (N:N) + `fact_mandate.group_id`
- **Schutzfrist gruppenweit** (FG-10, KRITISCH): `fact_protection_window.scope` mit Werten `account`/`group`, Scraper matcht gegen beide
- **Scraper-Vorschlag** via Handelsregister-UID/Hauptsitz, AM bestätigt

## Neue DB-Tabellen / Felder

- `dim_firmengruppen` (neu falls nicht existiert)
- `dim_accounts.group_id` (bestehend)
- `bridge_mandate_accounts` (N:N für gruppenübergreifende)
- `fact_mandate.group_id` (neu)
- `fact_protection_window.scope` + `group_id` (KRITISCH, neue Logik)
- `fact_account_culture_scores.target_type` + `group_id` (Erweiterung)

## Verlinkte Wiki-Seiten

[[firmengruppe]], [[firmengruppe-interactions]], [[account]], [[direkteinstellung-schutzfrist]], [[detailseiten-guideline]]
