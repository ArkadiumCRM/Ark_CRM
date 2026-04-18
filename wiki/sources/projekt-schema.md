---
title: "ARK Projekt Detailmaske Schema v0.3"
type: source
created: 2026-04-13
updated: 2026-04-17
sources: ["ARK_PROJEKT_DETAILMASKE_SCHEMA_v0_2.md"]
tags: [source, projekt, schema, bkp, sia, matching, bauprojekt, bridge-tabellen, reports-to, referenz-eignung]
---

# ARK Projekt Detailmaske Schema v0.3

**Aktuelle Datei:** `specs/ARK_PROJEKT_DETAILMASKE_SCHEMA_v0_2.md` (enthält v0.2 + v0.3 Changelogs)
**Status:** v0.3 = Projekt-Reports-To + Referenz-Eignung + Vertragsart + Kontakt-Pivot + Team-Kontext (16.04.2026)
**Begleitdokument:** [[projekt-interactions]] v0.1

## Changelog v0.2 → v0.3 (16.04.2026)

| # | Änderung | Scope |
|---|----------|-------|
| 7 | **Projekt-Reports-To** (firmen-übergreifend, pro Projekt) | `reports_to_candidate_participation_id` / `reports_to_company_participation_id` |
| 8 | **Referenz-Eignung** | `can_be_referenced` · `reference_only_internal` · `reference_approval_date/by` · `reference_copyright_claim` |
| 9 | **Vertragsart + Abgerufen-Tracking** | `contract_type` (pauschal/einheitspreis/globalpreis/cost_plus) · `called_volume_chf` |
| 10 | **Projekt-Kontakt-Pivot** | Neue Tabelle `fact_project_company_contacts` (Multi-Kontakte pro Firmen-Beteiligung) |
| 11 | **Team-Kontext-Felder** (Kandidat-Participation) | `team_size` · `stakeholder_namedropping` · `challenges` · `highlights` |

## Changelog v0.1 → v0.2 (14.04.2026)

- **Bridge-Tabellen** `bridge_project_clusters` + `bridge_project_spartens` statt JSONB-Arrays (mit `is_primary`-Flag)
- **SIA-Phasen 6 + 12 hierarchisch** via neue `dim_sia_phases` (Stammdaten v1.3)
- **`volume_range` als Generated Column** aus `volume_chf_exact` (Postgres STORED), Fallback-Feld `volume_range_manual` wenn exact unbekannt
- Route englisch: `/projects/[id]`
- Sprachstandard `candidate_id`

## Primäre Use Cases

1. **Matching-Basis**: Kandidaten mit Erfahrung an ähnlichen Projekten finden
2. **Marktkenntnis**: Überblick über relevante Bauprojekte

## 6 Tabs

1. Übersicht — Stammdaten (öffentlich + intern getrennt) + AM-Notizen pro Account-Kontext
2. Gewerke (BKP) — Kern-Arbeitsumgebung, 3-Tier breit+tief: Firmen + Kandidaten pro BKP-Gewerk mit SIA-Phasen/Summen/Kommentaren · **v0.3: Reports-To + Referenz-Eignung + Team-Kontext in Drawer**
3. Matching — passende Kandidaten + ähnliche Projekte
4. Galerie — Fotos, Renderings, Pläne
5. Dokumente — Pressemeldungen, Pitch-Unterlagen (ohne AM-Notizen)
6. History — Event-Stream

## Klassifikation über bestehende Stammdaten

Keine neue Typen-Tabelle — **Cluster + Sparte + BKP-Gewerke** als vollständige Klassifikation. Cluster deckt Hochbau/Tiefbau/Infrastruktur/etc. ab.

## DB-Tabellen

**Kern (v0.2):**
- `fact_projects` — Stammdaten (`volume_range` als STORED Generated Column)
- `bridge_project_clusters` / `bridge_project_spartens` — Multi-Select mit `is_primary`
- `fact_project_bkp_gewerke` — Level 2 (BKP-basiert)
- `fact_project_company_participations` — Level 3 (Firmen)
- `fact_project_candidate_participations` — Level 3 (Kandidaten)
- `fact_project_media` — Galerie
- `fact_account_project_notes` — AM-Notizen pro Account-Kontext (Bridge)
- `fact_project_similarities` — Matching-Vorberechnung (Phase 1.5)

**Neu v0.3:**
- `fact_project_company_contacts` — Ansprechpersonen pro Firmen-Beteiligung (Multi-Kontakte pro Gewerk, mit `is_primary`)

## v0.3 Schlüssel-Konzepte

### Projekt-Reports-To (firmen-übergreifend)

Rapportiert **nur im aktuellen Projekt** — unabhängig von Firmen-Organigramm (`dim_accounts_org_chart`). Klassisches Beispiel: Sub-Bauleiter rapportiert GU-Gesamt-PL, nicht eigenem Firmen-CEO.

- XOR-Constraint zwischen `reports_to_candidate_participation_id` und `reports_to_company_participation_id`
- Cycle-Check (rekursive CTE) verhindert A→B→A-Zyklen
- Trigger: same `project_id`

### Referenz-Eignung

Steuert, ob eine Beteiligung in externen Arkadium-Pitch-Unterlagen genannt werden darf:
- `can_be_referenced` (TRUE/FALSE/NULL=undefined)
- `reference_only_internal` (nur intern, nicht in externen Pitches)
- `reference_approval_date` + `reference_approval_by` (Audit-Trail)
- `reference_copyright_claim` (Kandidat stimmt Verwendung in Arkadium-Pitch zu)

### Vertragsart + Abgerufen

Progress-Visualisierung Auftragssumme vs. Abgerufen:
- `contract_type`: pauschal · einheitspreis · globalpreis · cost_plus
- `called_volume_chf` vs. `contract_volume_chf` für Progress-Bar

### Team-Kontext (Kandidat)

Auf `fact_project_candidate_participations`:
- `team_size` (direkte Unterstellte, operativ)
- `stakeholder_namedropping` (wer war noch im Team/Umfeld, Freitext)
- `challenges` (Herausforderungen)
- `highlights` (Awards / Erfolge)

## v0.2 Schlüssel-Konzepte (weiterhin gültig)

- **Öffentliche vs. interne Infos** getrennt in Übersicht-Sektionen
- **AM-Notizen pro Account-Kontext**: jeder beteiligte Account hat eigene Notiz zum Projekt
- **Foto-Galerie** als eigener Tab mit Privacy-Flag pro Medium
- **3 Erstellungs-Wege:** manuell, Kandidat-Werdegang-Auto, Scraper
- **Duplikat-Erkennung** via String + AI + Manual Review mit Confidence-Schwellen

## Verlinkte Wiki-Seiten

[[projekt-datenmodell]], [[projekt-interactions]], [[stammdaten]], [[kandidat]], [[account]], [[scraper]], [[detailseiten-guideline]]
