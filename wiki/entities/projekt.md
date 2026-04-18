---
title: "Projekt"
type: entity
created: 2026-04-16
updated: 2026-04-16
sources: ["ARK_PROJEKT_DETAILMASKE_SCHEMA_v0_2.md", "ARK_PROJEKT_DETAILMASKE_INTERACTIONS_v0_1.md", "ARK_STAMMDATEN_EXPORT_v1_3.md", "ARK_BKP_CODES_STAMMDATEN.md"]
tags: [entity, projekt, bauprojekt, 3-tier, core]
---

# Projekt

Bauprojekt als zentrale Referenz für Matching, Marktkenntnis und Kandidaten-Werdegänge. Universal einsetzbar für Hochbau · Tiefbau · Infrastruktur · Industrie.

## 3-Tier-Struktur

```
Projekt (fact_projects)
  └── BKP-Gewerk (fact_project_bkp_gewerke)
       ├── Firmen-Beteiligungen (fact_project_company_participations) — N Firmen mit Rolle
       └── Kandidaten-Beteiligungen (fact_project_candidate_participations) — N Kandidaten mit SIA-Phasen
```

Ein Gewerk kann mehrere Firmen + mehrere Kandidaten haben. Ein Kandidat kann in mehreren SIA-Phasen eines Gewerks beteiligt sein (breit+tief, PR-3 bestätigt).

## Datenbank

**Haupttabelle:** `fact_projects`

**Bridge-Tabellen (Multi-Select):** `bridge_project_clusters`, `bridge_project_spartens` (beide mit `is_primary`-Flag, max 1 pro Projekt)

**Sub-Strukturen:**
- `fact_project_bkp_gewerke` (je Projekt N Gewerke via `dim_bkp_codes`)
- `fact_project_company_participations` (je Gewerk N Firmen mit Rolle, Summe, SIA-Phasen, **Reports-to-Firma**, **Vertragsart**, **Abgerufen**, **Referenz-Eignung**)
- `fact_project_candidate_participations` (je Gewerk N Kandidaten mit Rolle, SIA-Phasen, Verantwortungsgrad, **Team-Size**, **Stakeholder-Namedropping**, **Herausforderungen/Highlights**, **Reports-to-Kandidat oder -Firma (XOR)**, **Referenz-Eignung + Copyright-Claim**)
- `fact_project_company_contacts` (v0.3 NEU: Account-Kontakte pro Firmen-Beteiligung · Multi-Kontakte pro Gewerk · `is_primary`-Flag)
- `fact_project_media` (Fotos, Renderings, Pläne, Baustellen-Fotos, After-Move-In)
- `fact_account_project_notes` (AM-Notizen pro Account+Projekt, `UNIQUE(project_id, account_id)`)
- `fact_project_similarities` (Matching-Cache Projekt↔Projekt)

### Projekt-Reports-to (Hierarchie-Besonderheit)

**Wichtig:** Projekt-Reports-to ≠ Firmen-Organigramm. Im Projekt-Kontext rapportiert oft:
- Sub-Bauleiter (Firma X) → GU-Gesamt-PL (Firma Implenia)
- Fachplaner (externe Firma) → Gesamtplaner (externe Firma)
- Polier (Sub-Firma) → Bauleiter (GU-Firma)
- GU → Bauherr-Vertretung (Account-Kontakt)

Das ist **firmen-übergreifend und nur in diesem Projekt gültig** — unabhängig vom Firmen-Organigramm (dim_accounts_org_chart). Der selbe Kandidat kann in unterschiedlichen Projekten an unterschiedliche Leute rapportieren.

**DB-Umsetzung:**
- `fact_project_candidate_participations.reports_to_candidate_participation_id` ODER `.reports_to_company_participation_id` (XOR-Constraint)
- `fact_project_company_participations.reports_to_company_participation_id`
- Cycle-Check via rekursive CTE beim INSERT/UPDATE
- FK-Ziel muss im selben `project_id` sein (Trigger-Check)

**Stammdaten-Bezüge:**
- `dim_bkp_codes` (425 Codes, 4-stufig hierarchisch)
- `dim_sia_phases` (6 Haupt + 12 Teilphasen, `parent_phase_id` self-FK)
- `dim_clusters` / `dim_subcluster`
- `dim_sparte` (5 Einträge: ARC/GT/ING/PUR/REM)

**Generated Column:** `volume_range` aus `volume_chf_exact` (STORED, via CASE-Expression)

## Status

| Status | Beschreibung |
|---|---|
| **Planung** | Default, vor Baustart |
| **Ausschreibung** | Vergabe-Phase für Gewerke |
| **Ausführung** | Baustart erreicht |
| **Abgenommen** | Abnahme-Datum |
| **Abgeschlossen** | Garantiezeit abgelaufen |
| **Gestoppt** | Abgebrochen (mit Begründung) |

## Erstellungs-Wege (3 Quellen)

| Weg | Trigger | Source-Flag |
|---|---|---|
| **Manuell** | AM legt in Projekte-Liste neu an | `source='manual'` |
| **Aus Kandidat-Werdegang** | Kandidat gibt Projekt im Briefing ein, Autocomplete fehlschlägt | `source='candidate_werdegang'` |
| **Scraper** | simap.ch / Baublatt / TEC21 erkennt Projekt | `source='scraper'` |

**Duplikat-Erkennung 3-stufig:** String-Similarity + AI-LLM + Manual Review. Auto-Merge-Vorschlag ≥ 85 % Confidence.

## Frontend — 6 Tabs (`mockups/projects.html`)

**Stand 2026-04-16** — Phase A–I abgeschlossen.

| # | Tab | Inhalt | Status |
|---|---|---|---|
| 1 | Übersicht | 6 Sektionen mit Öffentlich/Intern-Split · AM-Notizen pro Account via `accountNoteDrawer` |
| 2 | Gewerke (BKP) | **3 View-Switch**: 📋 Akkordeon (SIA-primär · BKP sekundär) · 📊 Gantt (36-Monats-Zeitachse · Swimlanes) · 🕸 **Netzwerk** (SVG-Graph mit Projekt-Reports-to firmen-übergreifend · Side-Panel) |
| 3 | Matching | **2 Sub-Sections**: passende Kandidaten (6 Score-Dimensionen) + ähnliche Projekte (Jaccard + Vol + Geo) · `pitchDrawer` |
| 4 | Galerie | **Masonry-Grid + Lightbox** · 5 Medien-Typen · Privacy-Flag · Typ-spezifische CSS-Gradient-Tiles |
| 5 | Dokumente | Profile „Projekt" · 6 Kategorien · AI-Auto-Enrichment-Banner |
| 6 | History | 13 Projekt-Lifecycle-Events · Filter · Kategorie-Chips |

### Header-Spezialitäten

- **Hero-Bild klein** (60×60) klickbar → Tab 4 Galerie
- **Status-Dropdown** 6 Werte · Confirm bei Wechsel
- **Scraper-Source-Banner** (conditional) mit Confirm/Reject-Actions
- **Snapshot-Bar sticky** (6 Slots, projekttyp-agnostisch für Hoch-/Tiefbau/Infrastruktur): 💰 Volumen · 📅 Zeitraum · 🏗 BKP-Gewerke · 🏢 Firmen · 👥 Kandidaten · 📸 Medien
- **Quick-Actions**: `➕ Beteiligung hinzufügen` (→ `addBeteiligungDrawer`), `+ BKP-Gewerk` (→ `newGewerkDrawer`), `📄 Projekt-Report` (→ `projektReportDrawer`), `🔁 Matching neu`

### Drawer-Inventar (14 Stück)

| # | Drawer | Breite | Zweck |
|---|---|---|---|
| 1 | `newGewerkDrawer` | 540 | BKP-Code-Search aus 425 |
| 2 | `gewerkSettingsDrawer` | 540 | Edit/Delete Gewerk mit Cascade-Warnung |
| 3 | `firmaParticipationDrawer` | wide | **5 Tabs (v0.3 ausgebaut)**: Basis (+Vertragsart+Abgerufen) · SIA · **Kontakte** (Account-Kontakte pro Gewerk) · **Verträge+Dok** (Offerte/Vertrag/Nachträge/Stage-Rechnungen) · **Kontext+Referenz** (Kommentar+Reports-to-Firma+Cross-Refs+Referenz-Eignung) |
| 4 | `kandidatParticipationDrawer` | wide | **6 Tabs (v0.3 ausgebaut)**: Basis · SIA · Rolle · **Team-Kontext** (Reports-to firmen-übergreifend+Direct Reports+Peers+Stakeholder) · **Evidence+Referenz** (Werkzeugnisse+Referenz-Schreiben+Copyright-Claim) · **Kontext+Werdegang-Sync** (Tratsch+AI-Match+Konflikt-Detection) |
| 5 | `mediaUploadDrawer` | 540 | Multi-File + 5 Typ-Select + Privacy |
| 6 | `mediaEditDrawer` | 540 | Caption/Typ/Privacy editieren |
| 7 | `uploadDrawer` | 540 | Tab 5 Dokumente Standard |
| 8 | `pitchDrawer` | 540 | Tab 3 Matching Row-Action |
| 9 | `projektReportDrawer` | 540 | PDF-Generator mit intern/extern-Option + Sprache |
| 10 | `addBeteiligungDrawer` | 540 | Quick-Action: Gewerk + Firma/Kandidat wählen, routet weiter |
| 11 | `accountNoteDrawer` | 540 | Tab 1 §6 · UNIQUE(project_id, account_id) |
| 12 | `mergeDrawer` | wide | 3 Tabs · Duplikat-Merge mit Feld-Kollision |
| 13 | `reminderDrawer` | 540 | Standard |
| — | `historyDrawer` | — | — (Phase 2, nicht in P0) |

## Cross-Entity-Verknüpfungen

| Richtung | Via | Typ |
|---|---|---|
| Projekt → Account (Bauherr) | `fact_projects.bauherr_account_id` | 1:1 (pro Projekt) |
| Projekt ↔ Account (Beteiligungen) | `fact_project_company_participations` mit Rolle (11 Typen) | N:N |
| Projekt ↔ Kandidat | `fact_project_candidate_participations` mit SIA-Phasen | N:N |
| Projekt ↔ BKP-Code | `fact_project_bkp_gewerke` | 1:N |
| Projekt ↔ SIA-Phase | via Beteiligungen | N:N |
| Projekt ↔ Mandat (optional) | `fact_mandate.linked_project_id` | 1:N — Phase 1.5 |
| Projekt ↔ Job (optional) | `fact_jobs.linked_project_id` | 1:N — Phase 1.5 |
| Projekt ↔ Firmengruppe | transitiv via Bauherr-Account | — |
| Kandidat-Werdegang ↔ Projekt | `dim_candidates_profile.werdegang.project_id` + Hybrid-Autocomplete | Bidirektional |
| Scraper → Projekt | `fact_scraper_findings.resulting_entity_id` | 1:1 |

## Matching-Algorithmus

### Richtung A: Kandidaten → Projekt
```
score = w_cluster · cluster_overlap
      + w_bkp     · bkp_experience
      + w_sia     · sia_phase_coverage
      + w_volume  · volume_similarity
      + w_location · location_proximity
      + w_recency · recent_experience_bonus
```

Gewichte via `dim_matching_weights_project` als **Overlay** auf `dim_matching_weights` (Base). Partial-Override pro Dimension.

### Richtung B: Projekt → Projekt
Jaccard auf Cluster + BKP-Gewerke, plus Volumen-log-Diff, plus Geo-Distanz-Decay. Cache in `fact_project_similarities`, nightly + on-demand recompute.

## Berechtigungen

Jeder AM sieht alles — keine Berechtigungs-Varianten im Mockup. Admin kann Projekte löschen (soft-delete) und Mergen rückgängig machen (Phase 2).

## Related

- [[account]] — Bauherr + beteiligte Firmen
- [[kandidat]] — via Werdegang + Beteiligungen
- [[mandat]] — optional via `linked_project_id`
- [[job]] — optional via `linked_project_id`
- [[firmengruppe]] — transitiv
- [[stammdaten]] — BKP-Codes, SIA-Phasen, Cluster, Sparten
- [[matching]] — Projekt-basiertes Matching
- [[projekt-datenmodell]] — 3-Tier-Konzept
- [[dokumente-kategorien]] — Profil „Projekt" (6 Kategorien)
- [[design-system]] — Snapshot-Bar §3.2b, Drawer-Patterns
- [[scraper]] — Projekt-Detection aus Baublatt/simap/TEC21
