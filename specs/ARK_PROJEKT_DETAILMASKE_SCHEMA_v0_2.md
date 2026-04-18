# ARK CRM — Projekt-Detailmaske Schema v0.2

**Stand:** 14.04.2026
**Status:** Review ausstehend
**Quellen:** Wiki [[projekt-datenmodell]], ARK_STAMMDATEN_EXPORT_v1_3.md (Cluster, Sparten, BKP, SIA), ARK_DATABASE_SCHEMA_v1_3.md, ARK_BKP_CODES_STAMMDATEN.md, Entscheidungen 2026-04-13 (15 Fragen PR) + 2026-04-14
**Begleitdokument:** `ARK_PROJEKT_DETAILMASKE_INTERACTIONS_v0_1.md`
**Vorrang:** Stammdaten > dieses Schema > Frontend Freeze > Mockups

## Changelog v0.1 → v0.2 (14.04.2026)

| # | Änderung | Sektion |
|---|----------|---------|
| 1 | **Multi-Cluster/Multi-Sparte via Bridge-Tabellen** (statt JSONB-Arrays): `bridge_project_clusters`, `bridge_project_spartens` | § 5.2, § 14 |
| 2 | **SIA-Phasen 6 + 12 hierarchisch** (statt "11 flach"): `dim_sia_phases` aus Stammdaten v1.3, Multi-Select primär Haupt-Phasen, optional Drilldown auf Teilphasen | § 5.5, § 6, § 14 |
| 3 | **`volume_range` als Generated Column** aus `volume_chf_exact` (Postgres STORED) | § 5.2, § 14 |
| 4 | Route englisch: `/projects/[id]` (statt `/projekte/[id]`, bestätigt Entscheidung #1) | § 0, § 3 |
| 5 | Sprachstandard `candidate_id` statt `candidate_id` | § 14 |
| 6 | Referenz auf neues `dim_sia_phases` Stammdaten-Dokument v1.3 | § 14 |

## Changelog v0.2 → v0.3 (16.04.2026)

| # | Änderung | Sektion |
|---|----------|---------|
| 7 | **Projekt-Reports-to** (firmen-übergreifend, pro Projekt): `reports_to_candidate_participation_id` / `reports_to_company_participation_id` auf `fact_project_candidate_participations` + `fact_project_company_participations`. Gilt nur im aktuellen Projekt — unabhängig von Firmen-Organigramm (dim_accounts_org_chart). Beispiel: Sub-Bauleiter rapportiert GU-Gesamt-PL, nicht eigenem Firmen-CEO. XOR-Constraint + Cycle-Check. | §14 |
| 8 | **Referenz-Eignung**: `can_be_referenced`, `reference_only_internal`, `reference_approval_date`, `reference_approval_by`, `reference_copyright_claim`. Steuert ob Beteiligung in externen Arkadium-Pitch-Unterlagen genannt werden darf. | §14 |
| 9 | **Vertragsart + Abgerufen-Tracking**: `contract_type` (pauschal/einheitspreis/globalpreis/cost_plus) + `called_volume_chf` für Progress-Visualisierung Auftragssumme vs. Abgerufen. | §14 |
| 10 | **Projekt-Kontakt-Pivot**: Neue Tabelle `fact_project_company_contacts` für Ansprechpersonen pro Firmen-Beteiligung (Multi-Kontakte pro Gewerk). | §14 |
| 11 | **Team-Kontext-Felder** auf `fact_project_candidate_participations`: `team_size`, `stakeholder_namedropping`, `challenges`, `highlights` (aus Drawer-Tab-Ausbau). | §14 |

---

## 0. ZIELBILD

Vollseite `/projects/[id]` — zentrale Datenstruktur für Bauprojekte als Matching-Basis und Marktübersicht.

**Zwei primäre Use Cases (PR-1 A+D):**
1. **Matching-Basis**: Welche Kandidaten haben Erfahrung mit ähnlichen Projekten? (BKP/SIA/Cluster-Match)
2. **Marktkenntnis**: Überblick über relevante Bauprojekte in der Branche

**Architektur (PR-3 bestätigt — 3-Tier, breit + tief):**
- **Level 1 — Projekt** (z.B. "Überbauung Kalkbreite Zürich")
- **Level 2 — Gewerk** (BKP-basiert, mehrere pro Projekt, z.B. BKP 2.1 Baukonstruktionen)
- **Level 3 — Beteiligungen** pro Gewerk — **mehrere Firmen und Kandidaten pro Gewerk möglich**, mit SIA-Phasen, Rollen, Summen, Kommentaren

**Primäre Nutzer:**
- AM: Projekt-Stammdaten pflegen, Matching-Kontext
- Researcher / Hunter: Kandidaten mit passender Projekt-Erfahrung finden
- CM: Kontext für Kandidaten-Pitch (welche Projekte hat er gemacht)
- Admin: Marktübersicht, strategische Projekte

**Keine neue Projekt-Typen-Tabelle** — Klassifikation via bestehende Cluster/Sparten (Entscheidung 2026-04-13, PR-6).

---

## 1. DESIGNSYSTEM-REFERENZ

Erbt aus [[kandidatenmaske-schema]] § 0. Projekt-spezifisch:

### Farb-Tokens

| Token | Hex | Verwendung |
|-------|-----|-----------|
| Projekt-Primär | Teal `#196774` | Projekt-Badge, BKP-Section-Header |
| Status Planung | Amber `#f59e0b` | Planungs-Phase |
| Status Ausführung | Green `#5DCAA5` | In Ausführung |
| Status Abgeschlossen | Gold-dim | Abgeschlossen |
| Status Gestoppt | Red `#ef4444` | Gestoppt |
| BKP-Badge | Teal-hell | Pro BKP-Gewerk |
| SIA-Badge | Purple `#a78bfa` | Pro SIA-Phase |
| Beteiligung-Rolle | Blue `#60a5fa` | Rollen-Pill |

### Mockup-Dateien (zu erstellen)

| # | Tab | Datei (geplant) |
|---|-----|-----------------|
| 1 | Übersicht | `projekt_uebersicht_v1.html` |
| 2 | Gewerke (BKP) | `projekt_gewerke_v1.html` |
| 3 | Matching | `projekt_matching_v1.html` |
| 4 | Galerie | `projekt_galerie_v1.html` |
| 5 | Dokumente | `projekt_dokumente_v1.html` |
| 6 | History | `projekt_history_v1.html` |

---

## 2. GESAMT-LAYOUT

```
┌──────────────────────────────────────────────────────────────────┐
│ Breadcrumb: Projekte / Überbauung Kalkbreite Zürich              │
├──────────────────────────────────────────────────────────────────┤
│ HEADER                                                             │
│ ┌──────────────────────────────────────────────────────────────┐ │
│ │ [Hero-Bild] Überbauung Kalkbreite Zürich  [Ausführung ▼]      │ │
│ │ Bauherr: Volare Group · Zürich · Hochbau · BKP 2 + 3          │ │
│ │                                                                  │ │
│ │ SNAPSHOT-BAR (sticky, 6 Slots)                                 │ │
│ │ 🏗Status  📅Zeitraum  💰Volumen  🏢Firmen  👥Kandidaten  📸Fotos│ │
│ │                                                                  │ │
│ │ [📄 Projekt-Report] [➕ Beteiligung hinzufügen] [🔔 Reminder]  │ │
│ └──────────────────────────────────────────────────────────────┘ │
│ TAB-BAR: Übersicht │ Gewerke │ Matching │ Galerie │ Dok │ Hist  │
│                                                                    │
│ TAB-CONTENT                                                        │
│ KEYBOARD-HINTS-BAR                                                 │
└──────────────────────────────────────────────────────────────────┘
```

---

## 3. BREADCRUMB

```
Projekte / [Projekt-Name]        🔍 Ctrl+K  [Avatar]
```

Alternative Einstiege (Referrer-basiert):
- `Accounts / [Account] / Projekte / [Projekt-Name]`
- `Candidates / [Kandidat] / Werdegang / [Projekt]`

---

## 4. HEADER

### 4.1 Hero-Bild

Klein (60×60) im Header, bei Klick → Galerie-Tab mit diesem als primäres Bild.

### 4.2 Titel-Zeile

| Element | Inhalt | Interaktion |
|---------|--------|-------------|
| Projekt-Name | `fact_projects.project_name` (32px, fett) | Inline-Edit |
| Status-Dropdown | Planung / Ausschreibung / Ausführung / Abgenommen / Abgeschlossen / Gestoppt | Confirm bei Wechsel |

### 4.3 Meta-Zeile

| Element | Inhalt |
|---------|--------|
| Bauherr | Account-Link |
| Standort | Adresse (kurz) |
| Cluster | Badge (Hauptcluster, z.B. "Hochbau") |
| BKP-Hauptgewerke | Badge-Liste (aus Tab 2 aggregiert) |

### 4.4 Snapshot-Bar (sticky `top:0, z-index:50`, 6 Slots, **harmonisiert 2026-04-16**)

Canonical: `.snapshot-bar` + `.snapshot-item` (lbl/val/delta) — siehe `wiki/concepts/design-system.md` §3.2b. Keine Dupes zum Header (Status-Dropdown, Bauherr-Link, Cluster-Chip, Sparte-Chip stehen oben).

**Projekttyp-agnostisch** — funktioniert für Hochbau · Tiefbau · Infrastruktur · Industrie. Kein BGF/Einheiten (wäre Hochbau-spezifisch).

| Slot | Inhalt | Source |
|------|--------|--------|
| 1 | 💰 Volumen | `volume_chf_exact` oder `volume_range` Label |
| 2 | 📅 Zeitraum | `start_date – end_date_planned` (bzw. actual) |
| 3 | 🏗 BKP-Gewerke | `COUNT(fact_project_bkp_gewerke WHERE project_id)` · Delta: Status-Aufteilung (vergeben/Ausschreibung/offen) |
| 4 | 🏢 Beteiligte Firmen | `COUNT(DISTINCT account_id FROM fact_project_company_participations)` |
| 5 | 👥 Beteiligte Kandidaten | `COUNT(DISTINCT candidate_id FROM fact_project_candidate_participations)` |
| 6 | 📸 Medien | `COUNT(fact_project_media)` · Delta: Typ-Aufteilung (Foto · Rendering · Plan) |

**Dropped** (war in v0.1): ~~🏗 Status~~ → Status-Dropdown im Header. BGF/Einheiten wurden nicht aufgenommen (projekttyp-spezifisch).

### 4.5 Quick Actions

| Button | Aktion |
|--------|--------|
| 📄 Projekt-Report | PDF mit Stammdaten, Gewerken, Beteiligungen, Galerie-Preview (Arkadium-Pitch-Format) |
| ➕ Beteiligung hinzufügen | Drawer für neue Firmen-/Kandidaten-Beteiligung an einem Gewerk |
| 🔔 Reminder | Quick-Popover |

### 4.6 Tab-Bar

6 Tabs, Keyboard `1`–`6`:

```
│ Übersicht │ Gewerke (BKP) │ Matching │ Galerie │ Dokumente │ History │
```

---

## 5. TAB 1 — ÜBERSICHT

### 5.1 Layout

2-col Grid, Sektionen collapsible.

### 5.2 Öffentlich / Intern Trennung (PR-15)

Oberer Bereich **"Öffentliche Infos"** (können z.B. in Projekt-Report fliessen, potentiell auch Kunden-facing):
- Grunddaten, Volumen, Zeitraum, Bauherr, Standort, Foto-Highlights

Unterer Bereich **"Arkadium-interne Infos"** (geschützt):
- Strategische Bewertung, Arkadium-Kunde-Beziehung, interne Tags
- AM-Notizen pro Account — via `fact_account_project_notes` Bridge (siehe § 14)

### 5.3 Sektionen

#### Sektion 1 — Grunddaten (öffentlich)

| Feld | Typ | DB |
|------|-----|-----|
| `project_name` | Text | `fact_projects.project_name` |
| `bauherr_account_id` | Account-Link (FK) | Bezug zum primären Bauherrn |
| Standort | Adresse (Strasse, PLZ, Ort, Kanton) | `address_*` |
| Koordinaten | Lat/Long (optional, Phase 2 für Karte) | — |
| Cluster | Multi-Select aus `dim_clusters`, ein Cluster als primary markierbar | via `bridge_project_clusters(project_id, cluster_id, is_primary)` |
| Sparten | Multi-Toggle (ING/GT/ARC/REM/PUR), eine als primary | via `bridge_project_spartens(project_id, sparte_id, is_primary)` |
| Status | Enum | `status` |
| Start-Datum | Date | `start_date` |
| End-Datum (geplant) | Date | `end_date_planned` |
| End-Datum (tatsächlich) | Date | `end_date_actual` |

#### Sektion 2 — Volumen & Dimensionen (öffentlich)

| Feld | Typ | DB |
|------|-----|-----|
| Projektvolumen (CHF, exakt) | CHF Input (falls bekannt) | `volume_chf_exact` (nullable) |
| Projektvolumen (Range) | Auto-berechnet aus `volume_chf_exact` wenn gesetzt; sonst manuell editierbar | `volume_range` **Generated Column STORED** (siehe § 14) |
| Bruttogeschossfläche (m²) | Int | `bgf_sqm` |
| Anzahl Wohnungen / Einheiten | Int | `unit_count` |
| Anzahl Stockwerke | Int | `floor_count` |
| Baugrube-Tiefe | Decimal | `pit_depth_m` |

#### Sektion 3 — Projekt-Beschreibung (öffentlich)

Rich-Text / Markdown Editor. Quelle: extrahiert aus Baublatt/simap/Pressemeldungen oder manuell.

#### Sektion 4 — Öffentliche Referenzen (öffentlich)

| Feld | Typ | Source |
|------|-----|--------|
| Baublatt-URL | URL | `baublatt_url` |
| simap.ch-URL | URL | `simap_url` |
| Presse-URLs | Multi-URL | `press_urls` JSONB |
| Weitere Referenzen | Freitext-Liste | — |

#### Sektion 5 — Arkadium-interne Strategie (intern)

| Feld | Typ | DB |
|------|-----|-----|
| Strategische Bewertung | Dropdown (Top-Projekt / Standard / Nischen / Low Priority) | `strategic_rating` |
| Tags | Multi-Select Freie Tags | `tags` JSONB |
| Interne Kommentare | Textarea | `internal_notes` |
| Arkadium-Involvement-Level | Dropdown (Aktiv / Beobachtet / Keine Beteiligung) | `involvement_level` |

#### Sektion 6 — AM-Notizen pro Account (intern, per Account)

Tabellen-Sub-Section:
- Pro Account der mit diesem Projekt verknüpft ist, zeigt AM-spezifische Notizen
- Liste der Notizen mit Account-Link + Autor + Datum + Text
- Nur der AM des jeweiligen Accounts kann seine Notiz editieren
- Datenquelle: `fact_account_project_notes` Bridge

---

## 6. TAB 2 — GEWERKE (BKP) — KERN-ARBEITSUMGEBUNG

Die operative Tiefen-Ansicht: pro BKP-Gewerk welche Firmen + Kandidaten beteiligt sind, in welchen SIA-Phasen, mit welchen Summen und Kommentaren.

### 6.1 Layout

Akkordeon-Liste: jede BKP-Gewerk-Zeile ist expandable. Default: **erste 3 expandiert**, Rest kollabiert.

### 6.2 BKP-Gewerk-Zeile (kollabiert)

```
▶ BKP 2.1 — Baukonstruktionen                 CHF 12'500'000   👥 8 Kandidaten · 🏢 3 Firmen
```

### 6.3 BKP-Gewerk-Detail (expandiert)

```
▼ BKP 2.1 — Baukonstruktionen                 CHF 12'500'000   👥 8 · 🏢 3

   📝 Gewerk-Kommentar: [editable textarea — Arkadium-interne Einschätzung]

   🏢 BETEILIGTE FIRMEN (3)
   ─────────────────────────────────────────────────────────────────
   │ Implenia AG         │ Generalunternehmer │ CHF 12'500'000 │ ⋯ │
   │ Muster Bau AG       │ Subunternehmer     │ CHF 2'100'000  │ ⋯ │
   │ XYZ Handwerk        │ Subunternehmer     │ CHF 450'000    │ ⋯ │

   👥 BETEILIGTE KANDIDATEN (8)
   ─────────────────────────────────────────────────────────────────
   │ Max Muster    │ Bauleiter   │ via Implenia    │ SIA 41, 51, 52    │ 2023-2025 │ ⋯ │
   │ Anna Klein    │ Projektleit.│ via Implenia    │ SIA 41, 51        │ 2023-2024 │ ⋯ │
   │ …                                                                               │

   [+ Firma hinzufügen]  [+ Kandidat hinzufügen]
```

### 6.4 Firmen-Beteiligungs-Drawer

Beim Klick auf Firmen-Zeile oder "+ Firma hinzufügen":

| Feld | Typ |
|------|-----|
| Account (FK) | Autocomplete aus `dim_accounts` (Kein-Match → "Als Account anlegen") |
| Rolle | Dropdown (Bauherr / Architekt / Generalplaner / TU / GU / Fachplaner / Subunternehmer / Bauleitung / Handwerker / Lieferant / Andere) |
| Zeitraum (von/bis) | Date-Range |
| Summe (CHF) | Decimal (optional) |
| Kommentar | Textarea (Arkadium-intern) |
| SIA-Phasen (Multi-Select, hierarchisch) | Multi-Select primär aus 6 Haupt-Phasen (SIA 1–6) aus `dim_sia_phases WHERE level=1`, optional Drilldown auf Teilphasen (`parent_phase_id = ausgewählte_Haupt-Phase`). Speicherung als FK-Liste, typischerweise Haupt-Phasen-IDs |

### 6.5 Kandidaten-Beteiligungs-Drawer

Beim Klick auf Kandidaten-Zeile oder "+ Kandidat hinzufügen":

| Feld | Typ |
|------|-----|
| Kandidat (FK) | Autocomplete aus `dim_candidates_profile` (Kein-Match → "Als Kandidat anlegen") |
| Rolle | Dropdown (Projektleiter / Bauleiter / Architekt / Planer / Polier / Fachspezialist / …) |
| Anstellungs-Firma zum Zeitpunkt | FK zu `dim_accounts` (optional, Default aus Werdegang) |
| SIA-Phasen | Multi-Select aus 6 Haupt-Phasen + optional Teilphasen-Drilldown (siehe `dim_sia_phases` v1.3) |
| Zeitraum (von/bis) | Date-Range |
| Verantwortungsgrad | Dropdown (Führend / Mitarbeitend / Beratend) |
| Kommentar | Textarea (Arkadium-intern, z.B. "Sehr gute Leistung laut Referenzen") |

### 6.6 Gewerk hinzufügen / entfernen

Button "+ BKP-Gewerk hinzufügen" → Dropdown aus BKP-Katalog (~425 Codes).

### 6.7 Aggregate-KPIs pro Gewerk

Für jedes Gewerk werden automatisch berechnet:
- Summe aller Firmen-Beteiligungen
- Summe aller SIA-Phasen-Dauern
- Anzahl beteiligte Firmen / Kandidaten

### 6.8 Gewerk-Validierung

- Ein Gewerk kann mehrere Firmen und mehrere Kandidaten haben (breit+tief, PR-3 bestätigt)
- Ein Kandidat kann in mehreren SIA-Phasen eines Gewerks beteiligt sein
- Duplikate (gleicher Kandidat + gleiche Firma + gleiches Gewerk + überlappender Zeitraum) werden **als Warnung** angezeigt (Confirm statt Block)

---

## 7. TAB 3 — MATCHING

Findet Kandidaten mit ähnlicher Projekt-Erfahrung.

### 7.1 Matching-Kriterien

Zwei Richtungen:

**(A) Kandidaten → dieses Projekt:**
Welche Kandidaten wären gut für dieses Projekt (aufgrund ihrer bisherigen Projekt-Erfahrung in ähnlichen Gewerken/Clustern)?

**(B) Ähnliche Projekte:**
Welche anderen Projekte im CRM sind diesem ähnlich (Cluster + BKP + Volumen-Range + Standort)?

### 7.2 Tab-Sub-Sections

#### Sub-Section A: Passende Kandidaten

Tabelle mit Score (analog Job-Matching):

| Spalte | Inhalt |
|--------|--------|
| Kandidat | Foto + Name |
| Aktuelle Funktion / Arbeitgeber | |
| Score (0–100) | Gauge + Breakdown |
| Bisherige Projekte gleichen Clusters | Count (z.B. "5 Hochbau-Projekte") |
| Bisherige BKP-Erfahrung | Match-Liste (z.B. "BKP 2.1 ✓, BKP 3.4 ✓") |
| SIA-Phasen-Abdeckung | ✓ pro benötigte Phase |
| Aktionen | → Profil / + Pitch-Vorbereitung |

#### Sub-Section B: Ähnliche Projekte

Tabelle mit Ähnlichkeits-Score:

| Spalte | Inhalt |
|--------|--------|
| Projekt | Link |
| Bauherr | Account |
| Cluster-Match | % |
| BKP-Überlappung | % |
| Volumen-Ähnlichkeit | % |
| Geografie-Distanz | km |
| Overall-Score | 0–100 |

### 7.3 Filter

- Mindest-Score-Schwelle
- Cluster (pre-set)
- SIA-Phasen
- Kandidat-Temperatur

---

## 8. TAB 4 — GALERIE

Foto-/Rendering-Sammlung des Projekts.

### 8.1 Layout

Masonry-Grid oder Karten-Grid, klickbar zur Lightbox.

### 8.2 Medien-Typen

| Typ | Beschreibung |
|-----|-------------|
| Foto | Echtes Projekt-Foto |
| Rendering | Visualisierung (Architekt) |
| Plan | Grundriss / Schnitt |
| Baustelle | Aktuelle Baustellenfotos |
| After-Move-In | Post-Completion-Bilder |

### 8.3 Upload-Drawer

- Multi-File-Upload (Drag & Drop)
- Pro Bild: Typ, Bildunterschrift, Aufnahmedatum, Autor, Copyright-Info
- Privacy-Flag: Öffentlich / Intern

### 8.4 Lightbox

Vollbild-Ansicht mit Navigation, Download, Zuschneiden (Phase 2).

### 8.5 Empty-State

> "Noch keine Fotos. Lade Bilder hoch, um das Projekt visuell zu dokumentieren. [📤 Upload]"

---

## 9. TAB 5 — DOKUMENTE

### 9.1 Kategorien

| Kategorie | Zweck |
|-----------|-------|
| Projekt-Beschreibung (offiziell) | Vom Kunden bereitgestellt |
| Pressemeldungen | Medien-PDFs |
| Baublatt / simap.ch Extracts | Automatisiert aus Scraper oder manuell |
| Arkadium-Pitch-Unterlagen | Für neue Mandate bei ähnlichen Projekten |
| Referenz-Schreiben | Kunden-Referenzen |
| Sonstiges | Manuell |

**Explizit NICHT hier:** AM-Notizen zum Projekt (→ `fact_account_project_notes` im Account-Kontext, angezeigt in Tab 1 Sektion 6).

### 9.2 Layout

Card-Grid mit Kategorie-Filter (analog Mandat Tab 6).

### 9.3 Auto-Enrichment

Bei Upload werden via AI:
- Dokumente automatisch kategorisiert
- Metadaten extrahiert (Datum, Titel)
- Falls PDF mit Projekt-Beschreibung: Text-Extraction für Matching

---

## 10. TAB 6 — HISTORY

### 10.1 Event-Typen (projekt-spezifisch)

- `project_created_manual` / `_from_candidate_werdegang` / `_from_scraper`
- `status_changed`
- `bauherr_changed`
- `bkp_gewerk_added` / `_removed`
- `company_participation_added` / `_changed` / `_removed`
- `candidate_participation_added` / `_changed` / `_removed`
- `media_uploaded`
- `document_uploaded`
- `internal_notes_updated`
- `account_project_note_added` (pro Account-Kontext)

### 10.2 Filter

Event-Typ, User, Zeitraum, Scope (Grunddaten / Gewerke / Beteiligungen / Medien / Notizen).

---

## 11. KEYBOARD-HINTS-BAR

**Global:** `1`–`6` Tab · `Ctrl+K` Suche · `Esc`

**Tab 1 Übersicht:** `E` Edit · `S` Save

**Tab 2 Gewerke:** `G` Gewerk hinzufügen · `F` Firma hinzufügen (in selected Gewerk) · `K` Kandidat hinzufügen

**Tab 3 Matching:** `↑`/`↓` Navigation

**Tab 4 Galerie:** `U` Upload · `←`/`→` Lightbox-Navigation

**Tab 5 Dokumente:** `U` Upload · `F` Filter

---

## 12. RESPONSIVE

**Desktop (≥ 1280px):** 2-col Sektionen, Masonry-Galerie.
**Tablet (768–1279px):** 1-col, 2-Column-Galerie.
**Mobile (< 768px):** Phase 2.

---

## 13. BERECHTIGUNGEN (RBAC)

| Aktion | AM (Bauherr-Account) | AM (andere Accounts, beteiligt) | AM (fremd) | Researcher | Admin | Backoffice |
|--------|---------------------|----------------------------------|------------|-----------|---------|-----------|
| Lesen (alle Tabs) | ✅ | ✅ | ⚠ (nur öffentliche Infos) | ✅ | ✅ | ❌ |
| Grunddaten editieren | ✅ | ⚠ (Vorschläge) | ❌ | ❌ | ✅ | ❌ |
| BKP-Gewerk hinzufügen | ✅ | ✅ | ❌ | ❌ | ✅ | ❌ |
| Firmen-Beteiligung hinzufügen | ✅ | ✅ (eigene Firma) | ❌ | ❌ | ✅ | ❌ |
| Kandidaten-Beteiligung hinzufügen | ✅ | ✅ | ❌ | ⚠ | ✅ | ❌ |
| Fotos hochladen | ✅ | ✅ | ❌ | ⚠ | ✅ | ❌ |
| AM-Notizen (pro Account) | ⚠ (nur eigene) | ⚠ (nur eigene) | ❌ | ❌ | ✅ | ❌ |
| Projekt-Report generieren | ✅ | ✅ | ❌ | ❌ | ✅ | ❌ |
| Projekt löschen | ❌ | ❌ | ❌ | ❌ | ✅ | ❌ |

---

## 14. DATENBANK-REFERENZ (v0.2)

### Stammdaten-Referenzen

- `dim_clusters` (bestehend) + `dim_subclusters` (hierarchisch)
- `dim_sparte` (bestehend, 5 Einträge: ING/GT/ARC/REM/PUR)
- `dim_sia_phases` (**neu v1.3** — siehe `ARK_STAMMDATEN_EXPORT_v1_3.md` Sektion 55): 6 Haupt-Phasen + 12 Teilphasen, `parent_phase_id` self-FK, `level` SMALLINT
- `dim_bkp_codes` (bestehend, ~425 Codes, 4 Ebenen hierarchisch)

### Neue Tabellen

```sql
fact_projects (
  id uuid PK,
  tenant_id FK,
  project_name VARCHAR NOT NULL,
  bauherr_account_id FK NOT NULL,  -- primärer Bauherr
  address_street VARCHAR,
  address_zip VARCHAR,
  address_city VARCHAR,
  address_canton VARCHAR,
  lat DECIMAL NULL, long DECIMAL NULL,       -- Phase 2
  -- cluster_ids / sparte_ids entfernt v0.2 → via Bridge-Tabellen (siehe unten)
  status ENUM('planung','ausschreibung','ausfuehrung','abgenommen','abgeschlossen','gestoppt'),
  start_date DATE NULL,
  end_date_planned DATE NULL,
  end_date_actual DATE NULL,
  volume_chf_exact DECIMAL NULL,
  volume_range ENUM('<5M','5-20M','20-50M','>50M') GENERATED ALWAYS AS (
    CASE
      WHEN volume_chf_exact IS NULL THEN NULL
      WHEN volume_chf_exact < 5000000 THEN '<5M'
      WHEN volume_chf_exact < 20000000 THEN '5-20M'
      WHEN volume_chf_exact < 50000000 THEN '20-50M'
      ELSE '>50M'
    END
  ) STORED,                                   -- v0.2: Generated Column
  volume_range_manual ENUM('<5M','5-20M','20-50M','>50M') NULL,  -- Fallback wenn exact unbekannt
  bgf_sqm INT NULL,
  unit_count INT NULL,
  floor_count INT NULL,
  pit_depth_m DECIMAL NULL,
  description_md TEXT,
  baublatt_url VARCHAR NULL,
  simap_url VARCHAR NULL,
  press_urls JSONB,
  strategic_rating ENUM('top','standard','niche','low') NULL,
  tags JSONB,
  internal_notes TEXT,                        -- Arkadium-global, nicht pro Account
  involvement_level ENUM('active','observed','none'),
  is_public_flag BOOLEAN DEFAULT TRUE,
  source ENUM('manual','scraper','candidate_werdegang'),
  source_ref_id VARCHAR,
  created_at, updated_at, created_by, updated_by
)

-- NEU v0.2: Bridge-Tabellen statt JSONB-Arrays
bridge_project_clusters (
  id uuid PK,
  project_id FK NOT NULL,
  cluster_id FK NOT NULL,              -- → dim_clusters
  is_primary BOOLEAN DEFAULT FALSE,    -- max. 1 pro Projekt (UNIQUE-Index bei is_primary=TRUE)
  UNIQUE(project_id, cluster_id)
)

bridge_project_spartens (
  id uuid PK,
  project_id FK NOT NULL,
  sparte_id FK NOT NULL,               -- → dim_sparte (ING/GT/ARC/REM/PUR)
  is_primary BOOLEAN DEFAULT FALSE,
  UNIQUE(project_id, sparte_id)
)

fact_project_bkp_gewerke (
  id uuid PK,
  project_id FK,
  bkp_code_id FK,                             -- aus bestehendem BKP-Katalog (dim_bkp_codes)
  total_volume_chf DECIMAL NULL,
  gewerk_comment TEXT,                        -- Arkadium-intern
  order_index INT,                            -- Sortier-Reihenfolge
  created_at
)

fact_project_company_participations (
  id uuid PK,
  project_id FK,
  bkp_gewerk_id FK,                           -- an welchem Gewerk beteiligt
  account_id FK,                              -- welche Firma
  role ENUM('bauherr','architekt','generalplaner','tu','gu','fachplaner',
           'subunternehmer','bauleitung','handwerker','lieferant','andere'),
  contract_type ENUM('pauschal','einheitspreis','globalpreis','cost_plus') NULL,  -- v0.3
  from_date DATE NULL,
  to_date DATE NULL,
  contract_volume_chf DECIMAL NULL,           -- Auftragssumme
  called_volume_chf DECIMAL NULL,             -- v0.3: abgerufen (für Progress-Bar Vertragssumme)
  sia_phase_ids JSONB,                        -- Multi-Select (Array von dim_sia_phases.id, typischerweise Haupt-Phasen; Teilphasen optional)
  comment TEXT,                               -- Arkadium-intern
  -- v0.3: Projekt-Reports-to (firmen-übergreifend, nur in diesem Projekt gültig)
  reports_to_company_participation_id UUID NULL,
                                              -- FK auf andere fact_project_company_participations im SELBEN project_id
                                              -- z.B. Sub-Unternehmer reports to GU
                                              -- CHECK: nicht self · Trigger: same project_id · Cycle-Check (rekursive CTE)
  -- v0.3: Referenz-Eignung
  can_be_referenced BOOLEAN NULL,             -- NULL=undefined · TRUE=✓ · FALSE=✗
  reference_approval_date DATE NULL,
  reference_approval_by FK NULL,              -- dim_crm_users
  reference_notes TEXT NULL,
  created_at, updated_at
)

fact_project_candidate_participations (
  id uuid PK,
  project_id FK,
  bkp_gewerk_id FK,
  candidate_id FK,
  employer_account_id FK NULL,                -- Anstellungs-Firma zum Zeitpunkt
  role VARCHAR,                               -- Freitext oder aus Dropdown (Projektleiter, Bauleiter, ...)
  sia_phase_ids JSONB,                        -- Array von dim_sia_phases.id (Haupt-Phasen + optional Teilphasen)
  responsibility_level ENUM('leading','contributing','advisory'),
  team_size INT NULL,                         -- v0.3: direkte Unterstellte-Anzahl (operativ, nicht strukturell)
  from_date DATE NULL,
  to_date DATE NULL,
  comment TEXT,                               -- Arkadium-intern · Tratsch
  stakeholder_namedropping TEXT NULL,         -- v0.3: wer war noch im Team/Umfeld (freier Text)
  challenges TEXT NULL,                       -- v0.3: Herausforderungen
  highlights TEXT NULL,                       -- v0.3: Highlights / Awards
  -- v0.3: Projekt-Reports-to (firmen-übergreifend, XOR zwischen Kandidat oder Firma)
  reports_to_candidate_participation_id UUID NULL,
                                              -- FK auf andere fact_project_candidate_participations im SELBEN project_id
  reports_to_company_participation_id UUID NULL,
                                              -- Alternative: direkt an Firma rapportieren (z.B. Bauherr-Vertretung)
  -- XOR Constraint
  CONSTRAINT reports_to_xor CHECK (
    (reports_to_candidate_participation_id IS NULL)
    OR (reports_to_company_participation_id IS NULL)
  ),
  -- v0.3: Referenz-Eignung
  can_be_referenced BOOLEAN NULL,             -- NULL=undefined · TRUE=✓ nennbar · FALSE=✗ nicht nennen
  reference_only_internal BOOLEAN DEFAULT FALSE,  -- △ nur intern (nicht in externen Pitches)
  reference_approval_date DATE NULL,
  reference_approval_by FK NULL,
  reference_copyright_claim BOOLEAN DEFAULT FALSE,  -- Kandidat stimmt Verwendung in Arkadium-Pitch zu
  created_at, updated_at
)

-- v0.3: Projekt-Kontakt-Pivot (welche Account-Kontakte sind Ansprechpersonen für eine Firmen-Beteiligung)
fact_project_company_contacts (
  id uuid PK,
  company_participation_id FK,                -- → fact_project_company_participations
  contact_id FK,                              -- → fact_accounts_contacts
  project_role VARCHAR,                       -- Funktion im Gewerk (z.B. „Projektleiter", „Kalkulator", „Geschäftsführung")
  is_primary BOOLEAN DEFAULT FALSE,           -- Haupt-Ansprechperson für dieses Gewerk
  created_at
)

fact_project_media (
  id uuid PK,
  project_id FK,
  media_type ENUM('photo','rendering','plan','construction_site','after_move_in'),
  file_url VARCHAR,
  caption TEXT,
  taken_at DATE NULL,
  author VARCHAR NULL,
  copyright_info VARCHAR NULL,
  is_public BOOLEAN DEFAULT FALSE,
  order_index INT,
  created_at
)

fact_account_project_notes (
  id uuid PK,
  project_id FK,
  account_id FK,                              -- Account-Kontext für diese Notiz
  notes TEXT,
  created_by FK,
  updated_by FK,
  created_at, updated_at,
  UNIQUE(project_id, account_id)              -- max. 1 Notiz-Eintrag pro Projekt+Account
)

fact_project_similarities (                   -- Phase 1.5: Matching-Vorberechnung
  id uuid PK,
  project_id FK,
  similar_project_id FK,
  similarity_score DECIMAL,
  computed_at TIMESTAMP,
  UNIQUE(project_id, similar_project_id)
)
```

### Erweiterte bestehende Tabellen

```sql
dim_candidates_profile.werdegang (bzw. fact_candidate_werdegang):
  + project_id FK NULL  -- bei Briefing/Werdegang-Eintrag: Verknüpfung zu fact_projects
  -- Freitext bleibt bestehen als Fallback, strukturierter Link bevorzugt (PR-12 Hybrid)
```

---

## 15. OFFENE SPEC-PUNKTE

| # | Punkt | Priorität |
|---|-------|-----------|
| 1 | Interactions v0.1 | P0 (direkt folgend) |
| 2 | Mockup-HTMLs für 6 Tabs | P1 |
| 3 | Scraper-Integration simap/Baublatt/TEC21/Account-Referenzen | P1 (bereits in Scraper-Spec aufgenommen) |
| 4 | Kartenansicht (Lat/Long) | Phase 2 |
| 5 | Projekt-Ähnlichkeits-Algorithmus (`fact_project_similarities`) | Phase 1.5 |
| 6 | AI-Extraktion aus Projekt-PDFs | Phase 1.5 |
| 7 | Werdegang-/Briefing-Integration (PR-12 Hybrid-Autocomplete) | P1 |

---

## 16. RELATED SPECS / WIKI

- `ARK_PROJEKT_DETAILMASKE_INTERACTIONS_v0_1.md`
- `ARK_KANDIDATENMASKE_SCHEMA_v1_3.md` (Werdegang mit Projekt-Verknüpfung, Phase 1.5 Update)
- `ARK_ACCOUNT_DETAILMASKE_SCHEMA_v0_3.md` (Account-Projekte-Tab — Phase 1.5 Nachbearbeitung)
- `ARK_SCRAPER_MODUL_INTERACTIONS_v0_1.md` (Projekt-Scraper-Source)
- [[projekt-datenmodell]], [[stammdaten]] (Cluster, Sparten, BKP, SIA)
- [[detailseiten-guideline]]
