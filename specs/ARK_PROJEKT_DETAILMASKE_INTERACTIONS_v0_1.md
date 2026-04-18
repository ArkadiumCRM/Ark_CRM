# ARK CRM — Projekt-Detailmaske Interactions Spec v0.1

**Stand:** 13.04.2026
**Status:** Erstentwurf — Review ausstehend
**Kontext:** Verhalten, Lifecycle, Flows der Projekt-Detailseite `/projects/[id]`. Vollseite mit 6 Tabs, 3-Tier-Struktur (Projekt → Gewerk → Beteiligungen breit+tief).
**Begleitdokument:** `ARK_PROJEKT_DETAILMASKE_SCHEMA_v0_1.md`
**Vorrang:** Stammdaten > dieses Dokument > Schema > Mockups

---

## TEIL 0: STRUKTURELLE GRUNDENTSCHEIDUNGEN

### Tab-Struktur

| # | Tab | Inhalt |
|---|-----|--------|
| 1 | Übersicht | Grunddaten (öffentlich + intern getrennt) + AM-Notizen pro Account |
| 2 | Gewerke (BKP) | Kern-Arbeitsumgebung — pro BKP-Gewerk Firmen + Kandidaten-Beteiligungen |
| 3 | Matching | Passende Kandidaten + ähnliche Projekte |
| 4 | Galerie | Fotos, Renderings, Pläne |
| 5 | Dokumente | Beschreibungen, Pressemeldungen, Pitch-Unterlagen (ohne AM-Notizen) |
| 6 | History | Event-Stream |

### Erstellungs-Wege (PR-2: alle drei)

| Weg | Trigger | Source-Flag |
|-----|---------|-------------|
| **Manuell** | AM erstellt über Projekte-Liste "+ Neues Projekt" | `source='manual'` |
| **Aus Kandidat-Werdegang** | Kandidat gibt Projektname in Briefing ein → Autocomplete-Match fehlschlägt → Option "Neues Projekt anlegen" | `source='candidate_werdegang'` + `source_ref_id=candidate_id` |
| **Scraper** | simap.ch / Baublatt / TEC21 / Account-Referenz-Seite detektiert Projekt | `source='scraper'` + Scraper-Finding-Link |

### Duplikat-Erkennung (PR-10: alle Methoden)

Vor Insert in Projekt-DB werden **drei Prüfungen** parallel ausgeführt:
1. **String-Similarity:** Levenshtein + Standort-Match gegen bestehende `fact_projects.project_name`
2. **AI-Matching:** LLM-Check ob "Überbauung Kalkbreite" ≈ "Überbauung Kalkbreite Zürich" + Volumen/Standort-Kontext
3. **Manual Review:** Bei Unsicherheit (Confidence 50–80%) → AM entscheidet in Drawer

**Treffer-Schwellen:**
- Confidence ≥ 85%: Auto-Merge-Vorschlag (AM bestätigt einmal)
- Confidence 50–84%: Review-Dialog
- Confidence < 50%: kein Merge, neues Projekt anlegen

---

## TEIL 1: HEADER & QUICK ACTIONS

### Hero-Bild

Thumbnail im Header. Bei Klick → Galerie-Tab mit diesem als aktives Bild. Upload direkt durch Klick auf leeres Feld.

### Status-Dropdown

| Von | Nach | Trigger |
|-----|------|---------|
| Planung | Ausschreibung | Manuell, wenn Projekt in Ausschreibungs-Phase |
| Ausschreibung | Ausführung | Baustart-Datum erreicht oder manuell |
| Ausführung | Abgenommen | Abnahme-Datum |
| Abgenommen | Abgeschlossen | Garantie-Ende oder manuell |
| Beliebig | Gestoppt | Confirm + Grund (z.B. "Budget-Freeze") |

### Quick-Action "📄 Projekt-Report"

PDF-Generator:
- Stammdaten (öffentliche Infos)
- Gewerke-Struktur mit beteiligten Firmen
- Arkadium-Pitch-Format-Option (für Kundenpräsentationen): nur öffentliche Infos, Fotos, Highlights
- Interne Option: mit allen Beteiligungs-Details, Kandidaten-Namen, internen Kommentaren

### Quick-Action "➕ Beteiligung hinzufügen"

Shortcut zum Gewerke-Tab → Drawer für Firma oder Kandidat. Wenn kein Gewerk ausgewählt, fragt zuerst "An welchem BKP-Gewerk?".

---

## TEIL 2: TAB 1 — ÜBERSICHT

### Öffentlich / Intern Trennung

**Öffentliche Sektion** (Sektionen 1–4):
- Sichtbar für alle Nutzer inkl. fremde AMs (mit Berechtigung)
- Fliesst in Projekt-Report (externe Version)
- Fliesst in Matching-Berechnungen

**Interne Sektion** (Sektionen 5–6):
- Nur Bauherr-AM, beteiligte AMs, Admin, Researcher
- Fliesst NICHT in externe Reports
- Tab-Sub-Divider visuell

### AM-Notizen pro Account (Sektion 6)

Bridge-Tabelle `fact_account_project_notes`:

**Flow:**
1. AM öffnet Projekt
2. In Sektion 6 sieht er: eigene Notiz (editierbar) + andere Account-Notizen (read-only, mit Autor-Info)
3. Edit speichert mit `UNIQUE(project_id, account_id)` — ein Account hat immer genau eine Notiz pro Projekt (keine mehrfachen Einträge)
4. Bei Update: Event `account_project_note_added/updated`

**Visibility-Regeln:**
- Bauherr-AM sieht alle Notizen aller beteiligten Accounts (für Gesamtkontext)
- Andere AMs sehen nur eigene + alle öffentlichen Projekt-Infos
- Admin sieht alle Notizen

### Bauherr-Änderung

Nicht häufig, aber möglich (z.B. Projekt wechselt Bauherr):
- Admin-Only
- Confirm-Dialog mit Begründung
- Event `bauherr_changed`
- `fact_account_project_notes` des alten Bauherrn bleibt bestehen

### Cluster / Sparten-Änderung

Beide Multi-Select inline-editierbar. Änderung triggert:
- Matching-Recompute (async)
- Event `classification_changed`

---

## TEIL 3: TAB 2 — GEWERKE (BKP)

### Gewerk hinzufügen

Button "+ BKP-Gewerk hinzufügen":
1. Dropdown / Autocomplete aus BKP-Katalog (`dim_bkp_codes`, ~425 Einträge)
2. Duplikat-Check: gibt es das Gewerk schon am Projekt?
3. Insert `fact_project_bkp_gewerke`
4. Neues Akkordeon erscheint, expandiert

### Gewerk bearbeiten

Inline-Edit des `total_volume_chf` und `gewerk_comment`. Änderung ohne Confirm (auto-save).

### Gewerk entfernen

"⋯ Menu → Entfernen":
1. Confirm-Dialog: *"Gewerk entfernen? X Firmen-Beteiligungen und Y Kandidaten-Beteiligungen werden mit-gelöscht."*
2. Begründung optional
3. Cascading Delete aller Sub-Beteiligungen
4. Event `bkp_gewerk_removed`

### Firma hinzufügen (innerhalb Gewerk)

Drawer mit Feldern (siehe Schema § 6.4):

**Account-Autocomplete:**
- Match in `dim_accounts` → FK verknüpfen
- Kein Match → **Hard-Stop** "→ Als Account anlegen" (wie Kontakt-Kandidat-Regel)

**Validierung:**
- `role` Pflicht
- `from_date <= to_date` wenn beide gesetzt
- Summe optional

**Duplikat-Warnung:** Gleiche Firma + gleiches Gewerk → Warn-Dialog (Confirm, nicht Block) — Firma kann in mehreren Rollen im gleichen Gewerk auftauchen (z.B. Implenia als GU + als Planer).

### Kandidat hinzufügen (innerhalb Gewerk)

Analog Firma. **Besonderheit:**
- `employer_account_id` (Anstellungs-Firma zum Zeitpunkt): Default-Vorschlag aus Kandidaten-Werdegang entsprechend `from_date`
- `sia_phase_ids`: Multi-Select aus **6 Haupt- + 12 Teilphasen** (hierarchisch via `dim_sia_phases.parent_id`). Validierung: Wird eine Teilphase gewählt, wird die zugehörige Hauptphase **automatisch mitselektiert** (visuell im Tree-Picker ausgegraut). Rückwärts: Hauptphase-Wahl ohne Teilphasen ist erlaubt (= Gesamt-Phase).
- `role`: Freitext oder aus Vorschlags-Dropdown (Projektleiter, Bauleiter, Planer, ...)

**Auto-Sync zu Kandidaten-Werdegang:**
- Bei Hinzufügen: optional Eintrag im Kandidaten-Werdegang ergänzen (falls noch nicht vorhanden)
- Confirm-Dialog "Auch im Werdegang des Kandidaten erfassen?"

### Beteiligung bearbeiten

Row-Click öffnet Drawer. Edit + Save. Audit-Log für Änderungen.

### Beteiligung entfernen

Confirm + Begründung. Soft-Delete (falls historische Korrektur).

---

## TEIL 4: TAB 3 — MATCHING

### Async Compute

Matching-Scores werden im Hintergrund berechnet:
- Täglicher Batch
- On-Demand bei Projekt-Klassifikations-Änderung (Cluster/Sparte/BKP-Update)
- Cache in `fact_project_similarities` + virtuelle View für Kandidaten-Matches

### Sub-A: Passende Kandidaten

**Score-Berechnung:**
```
score = w_cluster * cluster_overlap_pct
      + w_bkp * bkp_experience_pct
      + w_sia * sia_phase_coverage_pct
      + w_volume * volume_similarity_pct
      + w_location * location_proximity_pct
      + w_recency * recent_experience_bonus
```

Gewichte in `dim_matching_weights_project` (Phase 1.5 konfigurierbar).

**Overlay-Logik (Partial-Override):** `dim_matching_weights_project` überschreibt nur die darin definierten Dimensionen. Nicht-überschriebene Dimensionen erben den Wert aus `dim_matching_weights` (Base). Berechnung pro Dimension: `effective_weight(dim) := project_overlay.weight(dim) ?? base.weight(dim)`. Details: siehe [[algorithms]] § 4.

**Row-Aktion "+ Pitch-Vorbereitung":**
- Öffnet Drawer mit Kandidat + Projekt-Context
- Generiert Pitch-Argument-Entwurf via AI (Phase 1.5)
- Link zum Kandidaten für Briefing/Outreach

### Sub-B: Ähnliche Projekte

Klick auf ähnliches Projekt → direkte Navigation zur dessen Detailseite.

### Filter

Mindest-Score, Cluster-Preset, SIA-Phasen, Kandidat-Temperatur, Geografie-Radius.

---

## TEIL 5: TAB 4 — GALERIE

### Upload-Flow

Drag & Drop oder File-Picker. Multi-File-Upload. Pro Datei:
- Typ-Dropdown (Foto / Rendering / Plan / Baustelle / After-Move-In)
- Caption
- Aufnahmedatum (optional)
- Autor / Copyright (wichtig für Recht)
- Privacy-Flag (öffentlich/intern)

### Bearbeiten / Löschen

Hover-Actions pro Bild:
- ✏ Edit (Caption, Typ, Privacy)
- 🗑 Delete (Confirm)
- ⬇ Download (falls erlaubt durch Copyright)

### Lightbox

Klick → Vollbild. Navigation via ←/→. Keyboard `Esc` schliesst.

### Ordering

Drag & Drop in Grid-Ansicht → `order_index` aktualisiert. Admin-Default: newest first.

### Foto-Quellen

Beim Scraping (z.B. aus Pressemeldungen): automatischer Upload mit `privacy='public'` Default + `author='scraper:source'` + `copyright_info`.

---

## TEIL 6: TAB 5 — DOKUMENTE

Standard-Upload-Flow analog Mandat/Account. Auto-Enrichment via AI:
- Kategorie-Vorschlag
- Datum-Extraktion
- Text-Extraction für Matching-Suche

**Explizit NICHT hier:** AM-Notizen zum Projekt (→ Tab 1 Sektion 6).

---

## TEIL 7: TAB 6 — HISTORY

Scope: `WHERE project_id = X`. Alle Events aus Tab 1–5 fliessen hier ein. Standard-Filter.

---

## TEIL 8: CROSS-ENTITY-INTEGRATIONEN

### (A) Werdegang/Briefing ↔ Projekt (PR-12 Hybrid)

**Beim Kandidat-Briefing (Kandidatenmaske Tab 2 Briefing):**
1. Kandidat gibt Projekt-Name ein in Werdegang-/Erfahrungs-Sektion
2. **Autocomplete** gegen `fact_projects.project_name` + Fuzzy-Match
3. **Match gefunden (Confidence ≥ 85%):** Link mit Preview ("Überbauung Kalkbreite, Volare Group, 2023-2025" — Bestätigen?)
4. **Match unklar (50-84%):** Dropdown mit Top-3-Kandidaten + "Neues Projekt anlegen"
5. **Kein Match:** Button "Neues Projekt anlegen" → Mini-Drawer mit Pflichtfeldern (Name, Bauherr-Account, grober Zeitraum) → Voller Eintrag kann später ergänzt werden

**Synchronisation:**
- Nach Verknüpfung: Kandidat-Werdegang-Eintrag bekommt `project_id`
- Automatische Insert in `fact_project_candidate_participations` (ohne Gewerk initial, AM ergänzt später)
- Kurzübersicht im Werdegang: Projekt-Name, Rolle, Zeitraum, Link zur Projekt-Detailseite

### (B) Account ↔ Projekt

**Account-Detailseite bekommt neuen Tab "Projekte"** (siehe Nachbearbeitung):
- Zeigt alle Projekte an denen dieser Account beteiligt war (entweder als Bauherr oder via `fact_project_company_participations`)
- Mit Rolle-Filter
- Klick → Projekt-Detailseite

### (C) Kandidat ↔ Projekt

Kandidaten-Detailseite Werdegang/Briefing-Tab zeigt Projekt-Links mit Kurzvorschau. Bei Aufruf des Projekts von dort aus: Breadcrumb zeigt Einstiegspunkt.

### (D) Mandat / Job ↔ Projekt

Optional: Bei Mandat-/Job-Erstellung kann ein Projekt verknüpft werden (z.B. "Suche Bauleiter für Projekt Überbauung XY").
- Mandat bekommt `fact_mandate.linked_project_id` (nullable)
- Job bekommt `fact_jobs.linked_project_id` (nullable)
- Im Projekt sichtbar unter "Verwandte Mandate" (Nachbearbeitung Phase 1.5)

### (E) Scraper-Integration

Scraper-Findings mit `finding_type='project_detected'` landen in Scraper-Review-Queue. Accept → Projekt wird erstellt mit `source='scraper'`.

---

## TEIL 9: MATCHING-ALGORITHMUS (DETAIL)

### Projekt-zu-Kandidat-Matching

Gegeben ein Projekt X, finde Kandidaten Y die passen:

```
FOR candidate IN candidates:
  previous_projects = candidate.project_participations
  
  cluster_overlap = |X.clusters ∩ UNION(p.clusters for p in previous_projects)| / |X.clusters|
  
  bkp_experience = |X.bkp_gewerke ∩ UNION(p.bkp_gewerke for p where candidate involved)| / |X.bkp_gewerke|
  
  sia_coverage = durchschnittliche SIA-Phasen-Abdeckung
  
  volume_similarity = 1 - |log(X.volume) - log(avg(previous.volume))| / max_log_diff
  
  location_proximity = 1 - min(distance(X.location, p.location)) / max_distance
  
  recency_bonus = 1 if any previous participation within 2 years else 0.5
  
  score = weighted_sum()
```

### Projekt-zu-Projekt-Matching

Gegeben Projekt X, finde ähnliche Projekte Y:

```
cluster_match = Jaccard(X.clusters, Y.clusters)
bkp_overlap = Jaccard(X.bkp_gewerke, Y.bkp_gewerke)
volume_diff = 1 - min(1, abs(log(X.volume) - log(Y.volume)) / threshold)
location_distance_factor = exp(-distance / decay)
score = weighted_sum()
```

Batch-Compute in `fact_project_similarities` Tabelle (nightly + on-demand).

---

## TEIL 10: EVENTS

| Event | Scope |
|-------|-------|
| `project_created_manual` | Projekt + primärer Bauherr-Account |
| `project_created_from_candidate_werdegang` | Projekt + Kandidat |
| `project_created_from_scraper` | Projekt + Scraper-Run |
| `status_changed` | Projekt |
| `bauherr_changed` | Projekt + beide Accounts (alt + neu) |
| `classification_changed` | Projekt |
| `bkp_gewerk_added` / `_removed` | Projekt |
| `company_participation_added/changed/removed` | Projekt + Account |
| `candidate_participation_added/changed/removed` | Projekt + Kandidat (+ Account des Anstellungszeitpunkts) |
| `media_uploaded` | Projekt |
| `document_uploaded` | Projekt |
| `internal_notes_updated` | Projekt |
| `account_project_note_added/updated` | Projekt + Account |

---

## TEIL 11: DUPLIKAT-MANAGEMENT

### Merge-Flow

Wenn AM entscheidet "Duplikat, Merge":
1. Ziel-Projekt auswählen (das, was erhalten bleibt)
2. Daten-Kollision-Check: welche Felder unterscheiden sich?
3. Pro Feld: Auswahl welche Version gewinnt (Left/Right/Beide mergen)
4. Alle Sub-Einträge (`fact_project_bkp_gewerke`, `fact_project_company_participations`, `fact_project_candidate_participations`, `fact_project_media`, `fact_project_account_notes`) werden zusammengeführt
5. Kandidaten-Werdegang-Einträge mit `project_id = source` werden auf `target` umgehängt
6. Source-Projekt wird soft-deleted mit `merged_into_project_id` Referenz

### Split-Flow (Phase 2)

Falls irrtümlich gemergt: Admin kann ein Projekt wieder splitten.

---

## TEIL 12: BERECHTIGUNGEN (Spezialfälle)

### Fremd-AM-View

AM eines Accounts, der nicht am Projekt beteiligt ist:
- Sieht nur **öffentliche Sektionen** (1–4 in Tab 1, Tab 4 Galerie mit `is_public=true`)
- KEINE Einsicht in Firmen-/Kandidaten-Beteiligungs-Details
- KEINE Einsicht in Arkadium-interne Strategie-Bewertung

### Scraper-Auto-Updates

Bei Scraper-Updates an bestehenden Projekten:
- Stammdaten-Änderungen landen in Review-Queue als `project_data_drift`
- Bestehende Manual-Überschreibungen werden NICHT überschrieben (nur ergänzt)

---

## TEIL 13: PHASE 1.5 / PHASE 2

| Feature | Phase |
|---------|-------|
| Karten-Integration (Lat/Long, Projekt-Clustering auf Map) | 2 |
| AI-Pitch-Argument-Generator bei Matching | 1.5 |
| AI-Extraktion aus Projekt-PDFs (automatische BKP-Zuordnung) | 1.5 |
| Split-Flow bei fehlerhaftem Merge | 2 |
| Kandidaten-Werdegang-Update-Propagation bei Projekt-Änderung | 1.5 |
| Dynamic-Visualization der Gewerk-Volumina (Pie/Stacked-Bar) | 2 |
| Integration Baublatt-API (strukturierter Datenimport) | 2 |
| Public-Projekt-Portal (anonymized Showcase) | 2 |

---

## TEIL 14: VERKNÜPFUNGEN (Summary)

| Entity | Via | Richtung |
|--------|-----|----------|
| Account (Bauherr) | `fact_projects.bauherr_account_id` | 1:N (Account → Projekte) |
| Account (beteiligte Firmen) | `fact_project_company_participations` | N:N mit Rolle |
| Kandidat | `fact_project_candidate_participations` | N:N mit SIA-Phase + Rolle |
| BKP-Gewerk | `fact_project_bkp_gewerke` → `dim_bkp_codes` | 1:N |
| SIA-Phase | via Beteiligungen | N:N |
| Mandat (optional) | `fact_mandate.linked_project_id` | 1:N (Projekt → Mandate) |
| Job (optional) | `fact_jobs.linked_project_id` | 1:N |
| Scraper | `fact_scraper_findings.resulting_entity_id` | 1:N |

---

## TEIL 15: METHODIK-REFERENZ

Erbt Patterns von Account/Mandat/Job-Interactions. Keine Abweichungen.

---

## Related Specs / Wiki

- `ARK_PROJEKT_DETAILMASKE_SCHEMA_v0_1.md`
- `ARK_KANDIDATENMASKE_INTERACTIONS_v1_3.md` (Briefing + Werdegang-Integration — Nachbearbeitung)
- `ARK_ACCOUNT_DETAILMASKE_INTERACTIONS_v0_3.md` (neuer Tab "Projekte" — Nachbearbeitung)
- `ARK_SCRAPER_MODUL_INTERACTIONS_v0_1.md` (Projekt-Finding-Typ)
- [[projekt-datenmodell]], [[stammdaten]]
- [[detailseiten-guideline]], [[detailseiten-nachbearbeitung]]
