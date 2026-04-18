# ARK CRM — Job-Detailmaske Interactions Spec v0.1

**Stand:** 13.04.2026
**Status:** Erstentwurf — Review ausstehend
**Kontext:** Verhalten, Lifecycle, Flows der Job-Detailseite `/jobs/[id]`. Volle Detailseite (6 Tabs) gemäss Entscheidung 2026-04-13.
**Begleitdokument:** `ARK_JOB_DETAILMASKE_SCHEMA_v0_1.md`
**Vorrang:** Stammdaten > dieses Dokument > Schema > Mockups
**Globale Patterns:** 11 Global Patterns aus Kandidaten-Interactions v1.2

---

## TEIL 0: STRUKTURELLE GRUNDENTSCHEIDUNGEN

### Tab-Struktur

| # | Tab | Inhalt |
|---|-----|--------|
| 1 | Übersicht | Stammdaten, Stellenbeschreibung, Konditionen, Matching-Kriterien, Sichtbarkeit |
| 2 | Jobbasket | Read-mostly Pipeline-Übersicht aller Kandidaten im Basket dieses Jobs |
| 3 | Matching | Operatives Sourcing-Tool mit 7-Sub-Score-Ranking |
| 4 | Prozesse | Prozesse `WHERE job_id = X` |
| 5 | Dokumente | Stellenausschreibung, Briefing, Notizen |
| 6 | History | Event-Stream |

### Lifecycle-Prinzip

Ein Job durchläuft einen **linearen Lifecycle** mit kontrollierten Status-Wechseln:

```
scraper_proposal → vakanz → aktiv → besetzt → geschlossen
                 ↘ abgelehnt                 ↘ abgelehnt
```

- **scraper_proposal:** vom Scraper identifizierte Vakanz auf Account-Website, noch nicht bestätigt
- **vakanz:** Job bestätigt, aber **nicht mandatiert** (Arkadium weiss von ihm)
- **aktiv:** Mandatiert (Teil eines Mandats) ODER Erfolgsbasis
- **besetzt:** Placement erfolgt
- **geschlossen:** Garantiefrist durch
- **abgelehnt:** Scraper-Vorschlag verworfen, oder nach Vakanz als nicht relevant markiert

### Erstellungs-Wege

| Weg | Trigger |
|-----|---------|
| **Automatisch (Scraper)** | Scraper findet neue Vakanz auf `team_page_url` oder `career_page_url` → `status = 'scraper_proposal'` |
| **Manuell** | AM erstellt Job am Account (über Account Tab 6 "+ Neuer Job") |
| **Aus Mandat** | Mandats-Erstellung mit `mandate_type = 'Taskforce'` + Positionen → je Position 1 Job |
| **Aus Stellenplan** | Organisations-Stellenplan-Position wird "vermittlungsfähig" → "Jetzt mandatieren" Button erzeugt Job |

---

## TEIL 1: HEADER & STATUS-STEUERUNG

### Status-Übergänge

| Von | Nach | Trigger | Validierung / Pflicht |
|-----|------|---------|----------------------|
| scraper_proposal | vakanz | AM bestätigt Vorschlag (Button "Bestätigen" im amber Banner) | optional: Stellenbeschreibung-Review |
| scraper_proposal | abgelehnt | AM: "Nicht relevant" | Confirm-Dialog |
| vakanz | aktiv | Mandat wird erstellt mit diesem Job / AM setzt manuell "Aktiv" (Erfolgsbasis) | Pflicht: `salary_min_chf`, `salary_max_chf`, mind. `function_id` + `location_id` |
| vakanz | abgelehnt | AM: "Nicht mehr relevant" | Confirm-Dialog + Grund |
| aktiv | besetzt | Prozess für diesen Job → Status Placed | Auto (aus Prozess-Placement) |
| besetzt | geschlossen | Garantiefrist durch | Auto nach `placed_at + garantie_months` |
| aktiv | geschlossen (ohne Besetzung) | AM: "Stelle wurde vom Kunden zurückgezogen" | Confirm + Grund |

### Optimistic Update

- Stammdaten-Edits: Optimistic (auto-save pro Feld)
- Status-Wechsel: Confirm-Dialog, kein Optimistic (Server-Confirm)
- Matching-Kriterien-Änderungen: re-computen asynchron, Loading-State auf Matching-Tab

### Scraper-Proposal-Confirmation

Prominentes amber Banner in Tab 1 Sektion 1 (und im Header wenn `status = 'scraper_proposal'`):

```
⚠️ Scraper-Vorschlag vom [date]
Quelle: https://[account-website]/karriere/[url]
[✓ Bestätigen]  [✗ Ablehnen]  [🔍 Quelle ansehen]
```

**Bestätigen:**
1. Drawer öffnet sich mit Scraper-extrahierten Feldern (Titel, Beschreibung, Anforderungen) — AM kann editieren
2. Bei Confirm: `status = 'vakanz'`, `confirmation_status = 'confirmed'`
3. Event `scraper_proposal_confirmed` im History

**Ablehnen:**
1. Confirm + Grund (Dropdown aus `dim_vacancy_rejection_reasons`)
2. `status = 'abgelehnt'`, `confirmation_status = 'rejected'`

---

## TEIL 2: TAB 1 — ÜBERSICHT

### Edit-Verhalten

Alle Sektionen sind **immer editierbar** (keine Lock-Zustände basierend auf Status) — ausser:
- Wenn `status = 'besetzt'` oder `'geschlossen'`: Stellenbeschreibung + Matching-Kriterien werden locked (Snapshot wird eingefroren), nur Notes editierbar
- Grund: historische Integrität bei Audits

### Stellenbeschreibung editieren

Rich-Text / Markdown Editor. Optionen:
- Manuell schreiben
- **AI-Vorschlag "Briefing generieren"** (Phase 1.5): basierend auf `function_id`, `sparte_id`, Account-Branche → AI schlägt Boilerplate-Stellenbeschreibung vor, AM reviewed

### Matching-Kriterien-Änderungen

Jede Änderung triggert **async Recompute** von `fact_candidate_matches`:
- Loading-Spinner im Matching-Tab-Badge ("Neu berechnet... 23%")
- Nach Abschluss: Toast "Matching aktualisiert — 47 Kandidaten mit Score ≥ 60"

### Stellenplan-Verknüpfung

Wenn Job aus Stellenplan erstellt wurde (`fact_account_org_positions.linked_job_id = this.id`):
- Banner in Header: *"Dieser Job ist mit Position [XYZ] im Stellenplan verknüpft"*
- Klick → Navigation zu Account Tab 5 Subtab Stellenplan
- Bei Placement: `fact_account_org_positions.status = 'besetzt'`, `candidate_id = placed_candidate_id`

---

## TEIL 3: TAB 2 — JOBBASKET (PIPELINE-ÜBERSICHT)

### Read-only Charakter

Diese Pipeline-Ansicht ist **nicht der operative Verwaltungs-Flow**. Operative Aktionen (Prelead erstellen, Oral/Written GO setzen, Gate-1-Assignment, Versand) passieren in der **Kandidatenmaske Tab 5 Jobbasket**.

### Was der Tab kann

- **Lesen:** Alle Kandidaten mit diesem Job im Basket (+ Stage, CM, Letzter Kontakt)
- **Navigieren:** Klick auf Card → Kandidatenmaske Tab 5
- **Filtern:** nach Stage, CM, Priority
- **KPI-Banner:** Summe + Aufteilung nach Stage

### Was der Tab NICHT kann (bewusst)

- Kein Drag & Drop zwischen Stages
- Kein Prelead-Hinzufügen direkt (dafür: Header Quick-Action "Kandidat vorschlagen" → führt zu Prelead-Flow im Kandidaten)
- Kein GO-Setzen (passiert beim Kandidaten im GO-Termin-Workflow)

### KPI-Banner

Live-Update bei Änderungen (WebSocket):
```
📊 12 Kandidaten aktiv · 3 Assigned · 2 To Send · 5 versendet letzte 7 Tage
```

### Empty-State

> "Noch keine Kandidaten in diesem Job-Basket. Die operative Verwaltung läuft über die Kandidatenmaske — hier nur Übersicht."

---

## TEIL 4: TAB 3 — MATCHING

### Score-Berechnung

Async Batch-Job (täglich + bei Matching-Kriterien-Änderung) berechnet:

```
score_total = w_sparte * score_sparte
            + w_function * score_function
            + w_salary * score_salary
            + w_location * score_location
            + w_skills * score_skills
            + w_availability * score_availability
            + w_experience * score_experience
```

Gewichte (`w_*`) konfigurierbar in `dim_matching_weights` (Phase 1.5 — Admin-Settings).

Pro Sub-Score:
- **Sparte:** Exakte Übereinstimmung = 100, Nachbar-Sparte = 50, andere = 0
- **Function:** Function-Match inkl. Hierarchie (Junior ↔ Senior ↔ Lead)
- **Salary:** Kandidaten-Wunschgehalt vs. Job-Range — innerhalb = 100, Abweichung in % → linear sinkend
- **Location:** Distanz (km) vs. `location_radius_km` + Kandidat-Ortsbereitschaft
- **Skills:** Pflicht-Skills (hard) müssen alle matchen (sonst 0); Optional-Skills +Bonus
- **Availability:** Kandidaten-Status + Temperatur
- **Experience:** `min_years_experience` vs. Kandidat-Gesamterfahrung

Detailalgorithmus in [[matching]] Wiki-Konzept.

### Klick auf Kandidat-Row

Öffnet Slide-in-Drawer (540px):
- Kandidat-Summary (Foto, Name, Funktion, aktueller Arbeitgeber)
- Score-Breakdown als Radar-Chart (7 Dimensionen)
- Quick-Actions: "→ Kandidatenprofil" / "+ In Jobbasket (als Prelead)" / "Nicht relevant"
- Bei "+ In Jobbasket": erzeugt `fact_candidate_jobbasket` mit `stage = 'prelead'`, Notification an Kandidat-CM

### Score-Schwelle

Default-Schwelle **60** (Slider editierbar, pro User persistiert in `dim_user_preferences`).

### Bulk-Action

Multi-Select Checkboxen → "Ausgewählte in Jobbasket" (batch Prelead-Creation). Bei > 10: Confirm-Dialog.

### Nicht relevant markieren

Kandidat wird in `dim_job_candidate_exclusions` gelogged:
- `reason` (Dropdown: Falsche Sparte, Falsche Seniorität, Wohnort zu weit, ...)
- Wird aus Matching-Tab ausgeblendet bis AM manuell "Wieder anzeigen" klickt
- Re-Compute berücksichtigt Exclusion

---

## TEIL 5: TAB 4 — PROZESSE

### Listen-Interaktion

Analog Mandat-Tab 3 / Account-Tab 10:
- Klick → Slide-in-Drawer (Pipeline-Visualisierung + Quick-Actions)
- "→ Vollansicht öffnen" → `/processes/[id]`

### Auto-Aktualisierung

Wenn ein neuer Prozess für diesen Job entsteht (aus Jobbasket-Versand), erscheint er innerhalb 2 Sekunden in der Liste (WebSocket).

---

## TEIL 6: TAB 5 — DOKUMENTE

### Stellenausschreibung-Generator

Button "📄 Stellenausschreibung generieren":
1. Template rendert Markdown-Content aus Tab 1 Sektionen 3 + 4
2. Design: ARK-Branded PDF
3. Felder auto-befüllt: Titel, Beschreibung, Anforderungen, Gehalt, Benefits, Startdatum, Kontakt
4. Sprache aus `fact_jobs.language`
5. Output: PDF im Tab 5 unter Kategorie "Stellenausschreibung" (Version N+1)

### Upload

Standard-Upload mit Kategorie-Dropdown. Besonderheit:
- Upload "Briefing-Unterlage (Kundenseitig)" → Flag setzen + Notification an alle CMs des Accounts

---

## TEIL 7: TAB 6 — HISTORY

### Scope

`WHERE job_id = X`. Zusätzlich Cross-Entity-Events die diesen Job betreffen:
- Prozess-Events (wenn Prozess Stage/Status ändert)
- Jobbasket-Events (wenn Kandidat in/aus Basket)
- Scraper-Events (wenn Scraper Update am Job findet, z.B. Stelle verschwunden)

### Filter

Activity-Typ, User, Zeitraum, Cross-Entity-Event (Toggle "Nur direkte Job-Events" / "Auch abgeleitete Events").

---

## TEIL 8: AUTO-AKTIONEN & EVENTS

### Event-Katalog (15)

| Event | Scope |
|-------|-------|
| `job_created_manual` | Job + Account |
| `job_created_from_scraper` | Job + Account + Scraper |
| `job_created_from_mandate` | Job + Account + Mandat |
| `job_created_from_org_position` | Job + Account + Stellenplan-Position |
| `scraper_proposal_confirmed` / `_rejected` | Job + Account |
| `status_changed` | Job |
| `description_updated` | Job |
| `salary_range_changed` | Job + Account (wichtig für Matching-Recompute) |
| `matching_criteria_updated` | Job (triggert Async Recompute) |
| `matching_recomputed` | Job |
| `candidate_proposed_via_matching` | Kandidat + Job |
| `stellenausschreibung_generated` | Job + Dokument |
| `job_filled` | Job + Account + Prozess + Kandidat |
| `job_closed` | Job + Account |
| `job_rejected_after_vakanz` | Job + Account |

### Auto-Trigger

**Status `vakanz → aktiv`:** Matching-Compute wird priorisiert.

**Status `aktiv → besetzt`:**
- `filled_at = now`, `filled_by_candidate_id = process.candidate_id`
- Alle anderen offenen Prozesse für diesen Job: Banner "Stelle besetzt — Status prüfen?"
- Jobbasket-Kandidaten mit Stage ≤ `to_send` → Status bleibt, aber Banner am Kandidat
- Verknüpfte Stellenplan-Position (falls vorhanden) auf `besetzt` + `candidate_id`

**Status `besetzt → geschlossen`:**
- Auto am `filled_at + garantie_months` (Nightly Batch)
- Kann vorzeitig manuell gesetzt werden durch AM

---

## TEIL 9: VERKNÜPFUNGEN

### Zum Account
- Job existiert immer an genau einem Account (`account_id` NOT NULL)
- Erscheint in Account Tab 6 als Zeile
- Entwurfs-Banner im Account-Tab wenn `status = 'scraper_proposal'`

### Zum Mandat
- Job kann genau einem Mandat zugeordnet sein (`mandate_id` nullable)
- Bei Taskforce: N Jobs pro Mandat (je 1 Job pro Position)
- Bei Target: 1 Job pro Mandat (selten, meist ist Target 1:1)

### Zum Kandidaten
- Über `fact_candidate_jobbasket` (N:N) — Kandidaten mit diesem Job im Basket
- Über `fact_process_core` (N:1) — aktive/historische Prozesse
- Über `fact_candidate_matches` (N:N) — Matching-Scores

### Zur Stellenplan-Position
- `fact_account_org_positions.linked_job_id = this.id` (optional)
- Bidirektional nutzbar in UI

### Zum Scraper
- `fact_scraper_runs.detected_job_ids` zeigt welche Jobs in welchem Run gefunden wurden
- Scraper-Update erkennt wenn Job auf Website **verschwindet** → Event `job_disappeared_from_source`, Banner "Stelle nicht mehr ausgeschrieben — Status prüfen?"

---

## TEIL 10: PHASE 1.5 / PHASE 2 VORMERKLISTE

| Feature | Phase |
|---------|-------|
| AI-Stellenbeschreibungs-Generator | 1.5 |
| Matching-Gewichte-Admin-UI | 1.5 |
| Multi-Language-Stellenbeschreibung parallel | 2 |
| Public-Posting-API (jobs.ch etc.) | 2 |
| AI-Explanation für Matching-Score ("Warum diese 68 Punkte?") | 1.5 |
| Candidate-Facing Job-Portal mit Bewerbungs-Link | 2 |
| Job-Diff-Ansicht (bei Updates aus Scraper) | 2 |

---

## TEIL 11: METHODIK-REFERENZ

Erbt Event-System, RBAC, Patterns aus Kandidat/Mandat/Account-Interactions. Keine Abweichungen.

---

## Related Specs / Wiki

- `ARK_JOB_DETAILMASKE_SCHEMA_v0_1.md`
- `ARK_ACCOUNT_DETAILMASKE_INTERACTIONS_v0_3.md` TEIL 7 (Tab 6 Jobs & Vakanzen)
- `ARK_MANDAT_DETAILMASKE_INTERACTIONS_v0_3.md` (Taskforce → Jobs pro Position)
- `ARK_KANDIDATENMASKE_INTERACTIONS_v1_3.md` Tab 5 (Jobbasket — operativ)
- `ARK_PROZESS_DETAILMASKE_INTERACTIONS_v0_1.md`
- [[job]], [[matching]], [[jobbasket]], [[scraper]], [[stammdaten]]
- [[detailseiten-guideline]]
