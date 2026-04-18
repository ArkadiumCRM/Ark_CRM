---
title: "ARK Firmengruppe Detailmaske Interactions v0.1"
type: source
created: 2026-04-13
updated: 2026-04-13
sources: ["ARK_FIRMENGRUPPE_DETAILMASKE_INTERACTIONS_v0_1.md"]
tags: [source, firmengruppe, interactions, gruppenmandat, gruppenschutzfrist]
---

# ARK Firmengruppe Detailmaske Interactions v0.1

**Datei:** `specs/ARK_FIRMENGRUPPE_DETAILMASKE_INTERACTIONS_v0_1.md`
**Status:** v0.1 = Erstentwurf
**Begleitdokument:** [[firmengruppe-schema]] v0.1

## Kern-Flows

- **Erstellung:** Scraper-Vorschlag (Handelsregister-UID-Match) → amber Banner → AM/Admin bestätigt → Gruppe aktiv
- **Gesellschaft hinzufügen:** Account-Autocomplete, auto-Rückwirkung: bestehende Vorstellungen bekommen gruppenweite Schutzfrist-Einträge
- **Gruppenübergreifendes Mandat (Taskforce-only):** beteiligte Gesellschaften Multi-Select, führende Gesellschaft per Radio, `bridge_mandate_accounts` bekommt N Einträge
- **Dokumenten-Gültigkeitsbereich:** Upload mit Subset-Option (ganze Gruppe ODER nur X/Y/Z)
- **Kultur-Analyse auf Gruppen-Ebene:** AI-Hybrid nur durch Admin, Quellen: Holding-Web, Geschäftsberichte, aggregierte Gesellschafts-Kultur-Scores (Vergleich in Sektion 6)

## Schutzfrist-Integration (KRITISCH, FG-10)

Jede Vorstellung an einen Account in einer Gruppe erzeugt **zwei** `fact_protection_window` Einträge:
- `scope='account'` für AM-Sicht
- `scope='group'` mit `group_id` — rechtlich relevant
- Scraper-Match bei Job-Wechsel prüft beide Scopes
- Group-Level-Treffer zeigt Claim in Firmengruppe-Tab 4 + im Account-Tab 9 mit Label "Gruppen-Schutzfrist"

**Impact auf andere Specs:** Account-Interactions v0.2 → v0.3 benötigt Schutzfrist-Gruppen-Scope (dokumentiert in [[detailseiten-nachbearbeitung]]).

## History-Strategie (FG-12)

Mix: alle Gruppen-Level-Events + signifikante Account-Events (flag-basiert).
Signifikant: Placements, Mandats-Lifecycle, Kultur-Update, Blacklisting, AGB, Umbenennung.

## 11 Events

group_created_manual, group_suggested_by_scraper, group_confirmed, group_rejected, group_member_added, group_member_removed, group_culture_generated, group_mandate_created, group_framework_contract_added, group_report_generated, group_protection_window_opened.

## Verlinkte Wiki-Seiten

[[firmengruppe-schema]], [[firmengruppe]], [[account]], [[mandat]], [[direkteinstellung-schutzfrist]], [[detailseiten-nachbearbeitung]], [[detailseiten-guideline]]
