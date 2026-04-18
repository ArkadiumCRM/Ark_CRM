# ARK CRM — Job-Detailmaske Schema v0.1

**Stand:** 13.04.2026
**Status:** Erstentwurf — Review ausstehend
**Quellen:** ARK_FRONTEND_FREEZE_v1_10.md (Jobs & Vacancies, Jobbasket), ARK_DATABASE_SCHEMA_v1_3.md, ARK_ACCOUNT_DETAILMASKE_INTERACTIONS_v0_3.md TEIL 7 (Tab Jobs & Vakanzen), Wiki [[job]], [[matching]], [[jobbasket]], Entscheidungen 2026-04-13
**Begleitdokument:** `ARK_JOB_DETAILMASKE_INTERACTIONS_v0_1.md`
**Vorrang:** Stammdaten > dieses Schema > Frontend Freeze > Mockups

---

## 0. ZIELBILD

Vollseite `/jobs/[id]` — Detailansicht einer offenen Stelle / Vakanz. Jobs können mit oder ohne Mandat existieren, lebenszyklisch durchlaufen sie Scraper-Vorschlag → Vakanz → Aktiv → Besetzt → Geschlossen.

**Primäre Nutzer:**
- AM (Owner des Accounts): Stellenbeschreibung pflegen, Status steuern, Mandat-Verknüpfung
- CM: Jobbasket-Dashboard, Matching-Ansicht für Kandidaten-Zuordnung
- Researcher / Hunter: Matching-Tab als Sourcing-Werkzeug
- Admin: Read-Only + strategische Entscheidungen

**Abgrenzung:**
- Der **operative Jobbasket-Flow** (Preleads, GOs, Versand) passiert in der **Kandidatenmaske Tab 5 Jobbasket**
- Der **Jobbasket-Tab hier** ist eine **read-mostly Pipeline-Übersicht**: welche Kandidaten haben diesen Job im Basket, in welchem Stage

---

## 1. DESIGNSYSTEM-REFERENZ

Erbt aus [[kandidatenmaske-schema]] § 0. Job-spezifisch:

### Status-Tokens

| Status | Farbe | Beschreibung |
|--------|-------|--------------|
| `scraper_proposal` | grau-dim `#9a968e` | Scraper-Vorschlag (amber Banner im Account-Tab 6) |
| `vakanz` | amber `#f59e0b` | Bestätigt, aber nicht mandatiert |
| `aktiv` | green `#5DCAA5` | Mandatiert (Teil eines Mandats ODER Erfolgsbasis) |
| `besetzt` | gold `#dcb479` | Placement erfolgt |
| `geschlossen` | teal-dim | Nach Garantiefrist durch |
| `abgelehnt` | red-dim | Scraper-Vorschlag verworfen, oder nach Vakanz verworfen |

### Mockup-Dateien (zu erstellen)

| # | Tab | Datei (geplant) |
|---|-----|-----------------|
| 1 | Übersicht | `job_uebersicht_v1.html` |
| 2 | Jobbasket | `job_jobbasket_v1.html` |
| 3 | Matching | `job_matching_v1.html` |
| 4 | Prozesse | `job_prozesse_v1.html` |
| 5 | Dokumente | `job_dokumente_v1.html` |
| 6 | History | `job_history_v1.html` |

---

## 2. GESAMT-LAYOUT

```
┌──────────────────────────────────────────────────────────────────┐
│ Breadcrumb: Accounts / [Account] / Jobs / [Job-Titel]            │
├──────────────────────────────────────────────────────────────────┤
│ HEADER                                                             │
│ ┌──────────────────────────────────────────────────────────────┐ │
│ │ Bauführer Tiefbau  [Aktiv ▼]  [🎯 Target-Mandat: XYZ]         │ │
│ │ Volare Group AG · Zürich · Civil Engineering                   │ │
│ │                                                                  │ │
│ │ SNAPSHOT-BAR (sticky, 6 Slots)                                 │ │
│ │ 📋Basket  ⚙Prozesse  🎯Matching  💰Gehalt  📅Erstellt  🏆Placements│ │
│ │                                                                  │ │
│ │ [📄 Stellenausschreibung] [📧 Briefing mailen] [📤 Kandidat vorschlagen] │ │
│ └──────────────────────────────────────────────────────────────┘ │
│ TAB-BAR: Übersicht │ Jobbasket │ Matching │ Prozesse │ Dok │ Hist │
│                                                                    │
│ TAB-CONTENT                                                        │
│ KEYBOARD-HINTS-BAR                                                 │
└──────────────────────────────────────────────────────────────────┘
```

---

## 3. BREADCRUMB

```
Accounts / [Account-Name] / Jobs / [Job-Titel]       🔍  [Avatar]
```

Alternative Einstiege (Referrer-basiert):
- `Mandate / [Mandat] / Positionen / [Job-Titel]` (bei Taskforce-Positionen)

---

## 4. HEADER

### 4.1 Titel-Zeile

| Element | Inhalt | Interaktion |
|---------|--------|-------------|
| Job-Titel | `fact_jobs.title` (32px, fett) | Inline-Edit |
| Status-Dropdown | scraper_proposal / vakanz / aktiv / besetzt / geschlossen / abgelehnt | Confirm-Dialog bei Statuswechsel |
| Mandat-Badge | `🎯 Target-Mandat: [Name]` / `⚡ Taskforce-Position` / `💼 Erfolgsbasis` / `— Vakanz (nicht mandatiert)` | Read-only |
| Confirmation-Badge | Nur bei `scraper_proposal`: amber "Scraper-Vorschlag — bestätigen?" | Klick → Confirm-Workflow |

### 4.2 Meta-Zeile

| Element | Inhalt |
|---------|--------|
| Account-Link | `account_id` → `/accounts/[id]` |
| Standort-Chip | `location_id` → Name |
| Sparte-Badge | `sparte_id` |
| Function-Chip | `function_id` |
| Stellenplan-Referenz (konditional) | Wenn `fact_account_org_positions.linked_job_id` verknüpft: "→ Stellenplan: [Position-Titel]" → Account Tab 5 |

### 4.3 Snapshot-Bar (sticky `top:0, z-index:50`, 6 Slots, **harmonisiert 2026-04-16**)

Canonical: `.snapshot-bar` + `.snapshot-item` (lbl/val/delta) — siehe `wiki/concepts/design-system.md` §3.2b. Keine Dupes zum Header (Status-Dropdown, Mandat-Badge, Stellenplan-Chip, „Offen seit"-Meta stehen oben).

| Slot | Inhalt | Source |
|------|--------|--------|
| 1 | 🎯 Matches ≥ 70 % | `COUNT(fact_candidate_matches WHERE job_id AND score >= 70)` · Delta: „+N seit 7d · Top-Score %" |
| 2 | 🧺 Im Jobbasket | `COUNT(fact_candidate_jobbasket WHERE job_id AND stage != 'to_send_completed')` · Delta: „N Prelead · N Versandt" |
| 3 | ⚙ Aktive Prozesse | `COUNT(fact_process_core WHERE job_id AND status = 'Open')` · Delta: „N Mandat · N EB" |
| 4 | 📍 Standort | `dim_jobs.location + workload_pct` (z.B. „Zürich · 80–100 %") |
| 5 | 💰 TC-Range | `salary_min_chf – salary_max_chf` · Delta: „inkl. Bonus" falls Flag gesetzt |
| 6 | 🌡 Ø Match-Score | `AVG(fact_candidate_matches.score WHERE job_id AND score >= 70)` · Delta: „über N Matches" |

**Dropped** (waren Slots in v0.1, jetzt Header-Elemente oder Tab-4):
- ~~📅 Erstellt~~ → banner-meta „Eröffnet 14.01.2026 · offen seit 91 Tagen"
- ~~🏆 Placements~~ → Tab 4 Prozesse (historische 0 bei offenen Jobs uninteressant)

### 4.4 Quick Actions

| Button | Wann | Aktion |
|--------|------|--------|
| 📄 Stellenausschreibung | immer | PDF-Generator oder Preview der aktuellen Ausschreibung |
| 📧 Briefing mailen | immer | Email-Composer mit Stellenbeschreibung als Anhang, Empfänger-Dropdown Kandidaten oder Kontakte |
| 📤 Kandidat vorschlagen | Status = Aktiv | Drawer: Kandidat-Suche → wird in dessen Jobbasket als "Prelead" gesetzt |

### 4.5 Tab-Bar

6 Tabs, Keyboard `1`–`6`:

```
│ Übersicht │ Jobbasket │ Matching │ Prozesse │ Dokumente │ History │
```

---

## 5. TAB 1 — ÜBERSICHT

### 5.1 Sektionen

#### Sektion 1 — Stammdaten

| Feld | Typ | DB |
|------|-----|-----|
| `title` | Text | `fact_jobs.title` |
| `function_id` | Single-Select (Stammdaten) | — |
| `sparte_id` | Multi-Toggle (5 Tags) | — |
| `cluster_id` | Hierarchisches Autocomplete | — |
| `location_id` | Dropdown (Account-Standorte) | `fact_account_locations` |
| `status` | Enum (siehe Header) | `status` |
| `confirmation_status` | Enum (nur bei `scraper_proposal`) | `confirmation_status` |

#### Sektion 2 — Verknüpfungen

| Feld | Typ |
|------|-----|
| Account | Link-Chip (read-only, Parent-Entity) |
| Mandat | Link-Chip (nullable) |
| Zugehörige Stellenplan-Position | Link-Chip zu Account Tab 5 (konditional, `fact_account_org_positions.linked_job_id`) |
| Owner AM | aus `account.owner` (read-only) |

#### Sektion 3 — Stellenbeschreibung

| Feld | Typ | DB |
|------|-----|-----|
| `job_description` | Rich-Text / Markdown (Textarea mit Formatting) | `fact_jobs.description_md` |
| `responsibilities` | Textarea (Liste) | `responsibilities_md` |
| `requirements` | Textarea (Liste) | `requirements_md` |
| `nice_to_have` | Textarea (Liste) | `nice_to_have_md` |
| Sprache der Ausschreibung | Dropdown (DE/FR/IT/EN) | `language` |

#### Sektion 4 — Konditionen (Gehalts- und Benefit-Rahmen)

| Feld | Typ | DB |
|------|-----|-----|
| Gehalt Min / Max (CHF) | CHF-Pair | `salary_min_chf`, `salary_max_chf` |
| Pensum | Dropdown/Range (50–100%) | `pensum_min`, `pensum_max` |
| Vertragsart | Enum (Unbefristet / Befristet / Freelance / Temporär) | `contract_type` |
| Startdatum (geplant) | Date | `target_start_date` |
| Urlaubstage | Int | `vacation_days` |
| Home-Office-Anteil | Dropdown (0–100%) | `remote_pct` |
| Besondere Benefits | Tag-Liste | `benefits` |

#### Sektion 5 — Matching-Kriterien (Hard + Soft)

| Feld | Typ | DB |
|------|-----|-----|
| Pflicht-Skills (Hard) | Tag-Multi-Select | `required_skills` |
| Wünschenswerte Skills (Soft) | Tag-Multi-Select | `preferred_skills` |
| Mindest-Erfahrung (Jahre) | Int | `min_years_experience` |
| EDV-Kenntnisse (BIM, CAD etc.) | Multi-Select | `required_software_ids` |
| No-Go-Arbeitgeber | Multi-Select | `nogo_employer_ids` (z.B. Firmengruppen) |
| Standort-Radius (km) | Int | `location_radius_km` |

#### Sektion 6 — Ausschreibung & Sichtbarkeit

| Feld | Typ | DB |
|------|-----|-----|
| Öffentliche Stellenausschreibung? | Toggle | `is_public_posting` |
| URL Ausschreibung | URL | `public_url` |
| Publiziert auf | Multi-Select (jobs.ch, alpha.ch, LinkedIn, Fachzeitung, eigene Website, …) | `publication_channels` |
| Verdeckte Suche | Toggle (Default bei Führungskräften) | `is_confidential` |

#### Sektion 7 — Notizen & Briefing

- Freitext-Notizen (`notes`)
- Kunden-Briefing-Unterlage (Link zu Dokument falls vorhanden)

#### Sektion 8 — Status-Abschluss (konditional)

| Feld | Wann |
|------|------|
| `filled_at` | Besetzt |
| `filled_by_candidate_id` | Besetzt (verknüpfter Kandidat) |
| `closed_at` | Geschlossen |
| `rejection_reason` | Abgelehnt |

---

## 6. TAB 2 — JOBBASKET (PIPELINE-ÜBERSICHT)

**Read-mostly** Pipeline-Übersicht aller Kandidaten die diesen Job im Basket haben. Nicht der operative Verwaltungs-Flow (der lebt in Kandidat Tab 5).

### 6.1 Layout

Kanban-View als Default (6 Spalten analog Jobbasket-Stages), Toggle auf Liste.

### 6.2 Kanban-Spalten

| Spalte | Stage-Filter | Farbe |
|--------|--------------|-------|
| Prelead | `prelead` | grau |
| Oral GO | `oral_go` | amber |
| Written GO | `written_go` | blau |
| Assigned | `assigned` | grün |
| To Send | `to_send` | grün-hell |
| Versendet (CV Sent / Exposé) | `cv_sent` / `expose_sent` | teal (terminal, zeigt letzten 7 Tage) |

### 6.3 Card-Inhalt

```
┌────────────────────────────┐
│ 📷 Foto  Max Muster         │
│ Bauingenieur · Implenia     │
│ 📞 Letzter Kontakt: 03.04.  │
│ CM: PW · WG: 05.04.2026     │
│ [🔒 Assigned Gate 1]        │
└────────────────────────────┘
```

- Klick → Navigation zur **Kandidatenmaske Tab 5 Jobbasket** (operative Verwaltung)
- Keine Drag & Drop hier — nur Ansicht. Änderungen passieren in Kandidat Tab 5.

### 6.4 Filter

- Stage-Chips
- CM (Zuständiger Candidate Manager)
- Priority
- Gate-Status: Assigned / Dokumente fehlen

### 6.5 KPI-Banner oben

```
📊 12 Kandidaten aktiv · 3 Assigned · 2 To Send · 5 versendet letzte 7 Tage
```

### 6.6 Empty-State

> "Noch keine Kandidaten in diesem Job-Basket.
> → Kandidaten hinzufügen passiert in der Kandidatenmaske (Jobbasket-Tab) oder via Quick-Action 'Kandidat vorschlagen' im Header."

---

## 7. TAB 3 — MATCHING

Operatives Sourcing-Werkzeug. Zeigt Kandidaten sortiert nach Matching-Score basierend auf den Kriterien aus Tab 1 Sektion 5 + Gehalt + Location.

### 7.1 Layout

Tabelle + Filter-Bar.

### 7.2 Spalten

| Spalte | Inhalt |
|--------|--------|
| Foto + Name | Link zur Kandidatenmaske |
| Aktuelle Funktion | Aus Werdegang |
| Aktueller Arbeitgeber | Aus Werdegang |
| Score (gesamt) | 0–100 Gauge mit Farb-Gradient |
| Sub-Scores | Breakdown als Mini-Bars: Sparte / Function / Salary / Location / Skills / Availability / Experience (7 Sub-Scores laut [[matching]]) |
| Temperature | 🔥/🟡/🔵 |
| Letzter Kontakt | Datum |
| Im Jobbasket? | ✓ Check-Icon falls bereits drin |
| Aktionen | "+ In Jobbasket" (→ triggert Prelead-Creation) / "→ Profil öffnen" |

### 7.3 Filter

- Score-Schwelle (Slider, Default ≥ 60)
- Temperature (Hot / Warm / Cold / Alle)
- Sparte
- Standort-Radius
- Im Jobbasket: Ja / Nein / Alle
- NoGo-Kandidat ausschliessen (Default: ja)

### 7.4 Score-Berechnung (Info-Tooltip)

Algorithmus siehe [[matching]]-Konzept. Der Score ist eine gewichtete Summe der 7 Sub-Scores. Gewichte konfigurierbar pro Tenant in `dim_matching_weights` (Phase 1.5).

### 7.5 KPI-Banner

```
🎯 47 Kandidaten mit Score ≥ 60 · 12 davon Hot · 3 bereits im Basket
```

### 7.6 Empty-State (keine Matches)

> "Keine passenden Kandidaten mit Score ≥ [threshold] gefunden. Threshold anpassen oder Matching-Kriterien in Tab Übersicht Sektion 5 überarbeiten."

---

## 8. TAB 4 — PROZESSE

Alle Prozesse für diesen Job (`fact_process_core.job_id = X`).

### 8.1 Layout

Analog Mandat-Tab 3 / Account-Tab 10. Liste mit Toggle auf Kanban.

### 8.2 Spalten

| Spalte | Source |
|--------|--------|
| Kandidat | `candidate_id` + Foto + Name |
| Stage | `stage` (Exposé → Platzierung) |
| Status | `status` (Open/On Hold/Rejected/Placed/...) |
| Nächstes Interview | `MIN(fact_process_interviews.interview_date WHERE date > now)` |
| CM | `cm_user_id` |
| Mandat | falls verschiedene Prozesse aus verschiedenen Mandaten zusammen laufen — sichtbar |
| Erstellt am | `created_at` |
| Aktionen | Slide-in-Drawer / Vollansicht `/processes/[id]` |

### 8.3 Filter

Stage, Status, CM, Zeitraum, Freitext.

### 8.4 Empty-State

> "Noch keine Prozesse für diesen Job. Prozesse entstehen aus dem Jobbasket bei CV/Exposé-Versand."

---

## 9. TAB 5 — DOKUMENTE

### 9.1 Kategorien (job-spezifisch)

| Kategorie | Trigger |
|-----------|---------|
| Stellenausschreibung | Generiert aus Tab 1 Sektion 6 oder manueller Upload |
| Briefing-Unterlage (Kundenseitig) | Manuell |
| Interne Notizen / Kunde-Briefing | Manuell |
| Anforderungs-Dokument | Manuell (wenn Kunde extra Dokument liefert) |
| Sonstiges | Manuell |

### 9.2 Layout

Card-Grid mit Kategorie-Filter (analog Mandat Tab 6).

### 9.3 Stellenausschreibung-Generator

CTA-Button "📄 Stellenausschreibung generieren":
- Template rendert Markdown-Content aus Tab 1 Sektionen 3 + 4 zu formatiertem PDF
- Design-Template mit ARK-Branding
- Sprache wählbar (DE/FR/IT/EN — aus Tab 1)
- Versionierung: jede Generation = neues Dokument

---

## 10. TAB 6 — HISTORY

Analog andere History-Tabs. Scope: `WHERE job_id = X`.

### 10.1 Event-Typen (job-spezifisch)

- `job_created` (manuell oder aus Scraper-Confirmation)
- `status_changed` (vakanz → aktiv → besetzt → geschlossen)
- `scraper_proposal_received`
- `scraper_proposal_confirmed` / `_rejected`
- `description_updated`
- `salary_range_changed`
- `candidate_added_to_basket` (Info-Event, Details in Kandidat-History)
- `process_created` (Info-Event, Details in Prozess-History)
- `job_filled` (Placement)
- `job_closed` (Garantie durch)

### 10.2 KPI-Banner

```
Letzte Änderung: 12.04.2026 von PW · Status seit: 01.03.2026 auf "Aktiv" · Erstellt: 15.02.2026
```

---

## 11. KEYBOARD-HINTS-BAR

**Global:** `1`–`6` Tab · `Ctrl+K` Suche · `Esc`

**Tab 1 Übersicht:** `E` Edit-Mode · `S` Save · `G` Stellenausschreibung generieren

**Tab 2 Jobbasket:** `K` Kanban · `L` Liste · `F` Filter

**Tab 3 Matching:** `+` Kandidat in Basket · `↑`/`↓` Navigation · `O` Profil öffnen

**Tab 4 Prozesse:** analog Prozess-Liste

**Tab 5 Dokumente:** `U` Upload · `G` Ausschreibung generieren

---

## 12. RESPONSIVE

**Desktop (≥ 1280px):** 2-col Sektionen Tab 1, Kanban Tab 2/4.
**Tablet (768–1279px):** Snapshot-Bar 2-zeilig.
**Mobile (< 768px):** Phase 2.

---

## 13. BERECHTIGUNGEN (RBAC)

| Aktion | AM (Owner) | AM (andere) | Researcher/Hunter | CM | Admin | Backoffice |
|--------|-----------|-------------|-------------------|-----|---------|-----------|
| Lesen (alle Tabs) | ✅ | ✅ | ✅ | ✅ | ✅ | ⚠ |
| Stammdaten editieren | ✅ | ⚠ | ❌ | ❌ | ✅ | ❌ |
| Stellenbeschreibung editieren | ✅ | ⚠ | ❌ | ⚠ | ✅ | ❌ |
| Matching-Kriterien editieren | ✅ | ❌ | ⚠ (Vorschläge) | ⚠ | ✅ | ❌ |
| Status ändern (Vakanz → Aktiv) | ✅ | ❌ | ❌ | ❌ | ✅ | ❌ |
| Scraper-Proposal bestätigen | ✅ | ❌ | ❌ | ❌ | ✅ | ❌ |
| Kandidat in Jobbasket vorschlagen | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ |
| Matching-Tab operativ nutzen | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ |
| Dokument Upload | ✅ | ⚠ | ✅ | ⚠ | ✅ | ❌ |
| Stellenausschreibung generieren | ✅ | ⚠ | ❌ | ❌ | ✅ | ❌ |

---

## 14. DATENBANK-REFERENZ

Bestehende Tabellen (siehe [[datenbank-schema]]):
- `fact_jobs` — Haupttabelle (Lifecycle Vakanz → Job → Filled, `fact_vacancies` deprecated)
- `fact_candidate_jobbasket` — Kandidat-Job-Zuordnungen im Basket
- `fact_process_core` — Prozesse
- `fact_candidate_matches` — Matching-Scores (falls bereits vorhanden; sonst neu)

**Neue / erweiterte Felder (v0.1 Schema):**

```sql
fact_jobs:
  + confirmation_status ENUM('scraper_proposal','confirmed','rejected') DEFAULT 'confirmed'
  + description_md TEXT
  + responsibilities_md TEXT
  + requirements_md TEXT
  + nice_to_have_md TEXT
  + language ENUM('de','fr','it','en') DEFAULT 'de'
  + salary_min_chf DECIMAL(10,2)
  + salary_max_chf DECIMAL(10,2)
  + pensum_min INT, pensum_max INT
  + contract_type ENUM
  + target_start_date DATE
  + vacation_days INT
  + remote_pct INT
  + benefits JSONB
  + required_skills JSONB, preferred_skills JSONB
  + min_years_experience INT
  + required_software_ids JSONB
  + nogo_employer_ids JSONB
  + location_radius_km INT
  + is_public_posting BOOLEAN
  + public_url VARCHAR
  + publication_channels JSONB
  + is_confidential BOOLEAN
  + filled_at TIMESTAMP, filled_by_candidate_id FK
  + closed_at TIMESTAMP
  + notes TEXT

fact_candidate_matches (neu, falls nicht vorhanden):
  id, tenant_id, candidate_id, job_id,
  score_total INT,       -- 0-100
  score_sparte, score_function, score_salary, score_location,
  score_skills, score_availability, score_experience,
  computed_at TIMESTAMP,
  UNIQUE(candidate_id, job_id)
```

---

## 15. OFFENE SPEC-PUNKTE

| # | Punkt | Priorität |
|---|-------|-----------|
| 1 | Interactions-Spec v0.1 | P0 (direkt folgend) |
| 2 | Mockup-HTMLs für 6 Tabs | P1 |
| 3 | Matching-Algorithmus Details + Gewichtungen (`dim_matching_weights`) | P1 |
| 4 | Stellenausschreibungs-PDF-Template (Design) | P1 |
| 5 | AI-Scoring-Erklärungs-Tooltip (Phase 1.5) | Phase 1.5 |
| 6 | Multi-Language-Stellenbeschreibung (parallele Sprachen statt Sprach-Switch) | Phase 2 |
| 7 | Public-Posting-Integration (jobs.ch API etc.) | Phase 2 |

---

## 16. RELATED SPECS / WIKI

- `ARK_JOB_DETAILMASKE_INTERACTIONS_v0_1.md`
- `ARK_ACCOUNT_DETAILMASKE_SCHEMA_v0_2.md` Tab 6 (Jobs & Vakanzen) — Einstiegspunkt
- `ARK_MANDAT_DETAILMASKE_SCHEMA_v0_2.md` — Taskforce-Positionen verknüpft
- `ARK_KANDIDATENMASKE_SCHEMA_v1_3.md` Tab 5 (Jobbasket) — operative Verwaltung
- `ARK_PROZESS_DETAILMASKE_SCHEMA_v0_1.md` — Prozesse ab CV-Versand
- [[job]], [[matching]], [[jobbasket]], [[scraper]]
- [[detailseiten-guideline]]
