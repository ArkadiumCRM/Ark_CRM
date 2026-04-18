# ARK CRM — Kandidaten-Detailmaske Schema v1.3

**Stand:** 14.04.2026
**Status:** Review-Reif (Ergänzung v1.2)
**Quellen:** ARK_FRONTEND_FREEZE_v1_10.md (Section 4d.1), ARK_STAMMDATEN_EXPORT_v1_3.md, ARK_DATABASE_SCHEMA_v1_3.md, 14 harmonisierte HTML-Mockups
**Vorrang:** Bei Widerspruch gilt: Stammdaten > dieses Schema > Frontend Freeze > Mockups
**Vorgänger:** v1.2 (01.04.2026)

## Änderungen v1.2 → v1.3 (14.04.2026)

| # | Änderung | Sektion |
|---|----------|---------|
| 1 | **Tab 2 Briefing:** Projekt-Autocomplete bei Werdegang-/Projekt-Eingabe (Fuzzy-Match gegen `fact_projects`, Confidence-Schwellen-basiert) | Tab 2 Briefing § Projekte |
| 2 | **Tab 3 Werdegang:** Pro Arbeitsstation können Projekte jetzt als strukturierte Entity verknüpft werden (FK zu `fact_projects`). Link zur Projekt-Detailseite `/projects/[id]`. "Neues Projekt anlegen" Mini-Drawer falls kein Match. Auto-Insert in `fact_project_candidate_participations` | Tab 3 Werdegang § Projekte pro Station |
| 3 | **Tab 4 Assessment (alle Sub-Tabs):** Versionierung via `fact_candidate_assessment_version` mit FK zu `fact_assessment_order`. Pro Version-Navigation: Label "Version N — via Auftrag AS-2026-XXX ([Account])". Link zur Assessment-Detailseite `/assessments/[id]` | Tab 4 Assessment (alle Sub-Tabs) |
| 4 | **Tab 6 Prozesse:** Klick auf Prozess-Zeile öffnet Slide-in-Drawer (540px) statt Direkt-Navigation — konsistent mit Prozess-Mischform (v1.10). Detailseite via "→ Vollansicht öffnen" | Tab 6 Prozesse |
| 5 | **Tab 7 History:** Neue Event-Typen integriert (candidate_presented_email/verbal, assessment_credit_assigned, assessment_run_completed, assessment_version_created, protection_window_opened, protection_window_extended, referral-Events). Filter-Kategorie "Schutzfrist-Events" und "Assessment-Events" neu. | Tab 7 History Event-Filter |
| 6 | **Tab 8 Dokumente:** Scraper-Source-Flag bei automatisch erzeugten Dokumenten (z.B. Scraper-detektierter CV-Update). Icon 🕸 in Card. | Tab 8 Dokumente |
| 7 | **Tab 10 Reminders:** Neue Auto-Reminder-Typen — Assessment-Reminder (Termin vorbereiten, Coaching-Call, Debriefing), Schutzfrist-Info-Request-Tracking. | Tab 10 Reminders |
| 8 | **Sprachstandard:** `candidate_id` (englisch) statt `candidate_id`. Konsistenz mit DB v1.3. | alle Sektionen |
| 9 | **Schutzfrist-Awareness:** Im Kontext "Kandidat bei Account X vorstellen" zeigt UI Schutzfrist-Status-Badge mit ggf. Warnung. | Tab 5 Jobbasket, Tab 6 Prozesse |

## Integrations-Details v1.3

### Tab 2 Briefing — Projekt-Autocomplete (Abschnitt "Projekte")

**Bisher (v1.2):** Freitextfeld für Projekt-Namen pro Werdegang-Eintrag.

**Neu (v1.3):** Hybrid-Autocomplete
1. AM/Kandidat tippt Projekt-Namen
2. Fuzzy-Match gegen `fact_projects.project_name` + Standort + Zeitraum
3. **Match ≥ 85%:** Auto-Suggestion mit Preview-Card ("Überbauung Kalkbreite, Volare Group, 2023-2025 — 45 M CHF"). Klick auf Card → Verknüpfung. Badge "✓ verknüpft".
4. **Match 60-84%:** Dropdown mit Top-3-Kandidaten + "Neues Projekt anlegen" Option
5. **Kein Match / < 60%:** Button "+ Neues Projekt anlegen" → Mini-Drawer:
   - Pflichtfelder: Projekt-Name, Bauherr-Account (Autocomplete), grober Zeitraum (von/bis Jahr)
   - Optionale Felder: Standort, Projekt-Volumen-Range
   - Bei Speichern: `fact_projects` Insert mit `source='candidate_werdegang'`, `source_ref_id=candidate_id`
6. Nach Verknüpfung: `fact_candidate_werdegang.project_id` FK gesetzt + automatischer Insert in `fact_project_candidate_participations` (ohne BKP-Gewerk initial — AM kann später ergänzen)
7. UI zeigt Projekt-Link mit Kurzinfo und Navigation zu `/projects/[id]`

### Tab 3 Werdegang — Projekt-Referenz pro Station

**Layout:** Timeline-Karte pro Arbeitsstation zeigt verlinkte Projekte als Sub-Section:

```
┌──────────────────────────────────────────────────┐
│ Implenia AG · Bauleiter · 2023-2025             │
│ ──────────────────────────────────────────────── │
│ 📋 Projekte:                                      │
│   • Überbauung Kalkbreite (via Briefing)  → 🔗  │
│   • Verkehrsknoten Luzern                 → 🔗  │
│   [+ Projekt hinzufügen]                         │
└──────────────────────────────────────────────────┘
```

**Pro Projekt-Eintrag sichtbar:**
- Projekt-Name (Link zu `/projects/[id]`)
- BKP-Gewerk (falls zugewiesen, sonst "— zuweisen →")
- SIA-Phasen (Multi-Select-Badges)
- Rolle (Projektleiter / Bauleiter / ...)
- Zeitraum (wenn abweichend von Arbeitsstation)

**Inline-Edit:** Klick auf Projekt-Row → Drawer zur Detail-Bearbeitung (BKP, SIA-Phasen, Rolle, Kommentar). Öffnet gleichzeitig `fact_project_candidate_participations` für Edit.

**Versionierungs-Info:** Wenn Projekt via Briefing hinzugefügt wurde, zeigt Info "via Briefing v3 am 12.03.2026" — verweist auf Briefing-Version.

### Tab 4 Assessment — Versionierung via `fact_candidate_assessment_version`

**Alle 6 Assessment-Sub-Tabs (DISC, EQ, Scheelen 6HM, ASSESS 5.0, Driving Forces, Human Needs, Ikigai, AI-Analyse, Teamrad):**

Pfeil-Navigation oben rechts zeigt Version-Nummer + Kontext:

```
◀ Version 2 von 3 ▶
via Auftrag AS-2026-042 (Volare Group, Assessment 'MDI Führungs-Check')
Durchgeführt am: 05.03.2026 durch SCHEELEN®
[→ Zum Assessment-Auftrag]
```

**Datenquelle:** `fact_candidate_assessment_version` mit FK zu `fact_assessment_order`.

**Bei fehlender Auftrags-Verknüpfung** (Legacy-Daten vor v0.2): Label "Version N — Manuell erfasst / Legacy".

**Diff-Ansicht (Phase 2):** Vergleich zwischen Versionen eines Typs.

### Tab 5 Jobbasket — Schutzfrist-Awareness

Pro Account-Job-Zuweisung im Jobbasket prüft System ob `fact_protection_window` mit `candidate_id = this + account_id = job.account_id + status='active'` existiert.

**Sichtbar:**
- Badge "🛡 Schutz aktiv bis DD.MM.YYYY" im Prelead-Card
- Info-Panel "Dieser Kandidat ist bereits unter Schutzfrist bei diesem Account" (nicht-blockierend)
- Click-through zum Schutzfrist-Fenster in Account-Tab 9

**Rationale:** AM sieht sofort, dass Arkadium eh Honoraranspruch hätte — kein Druck, den Prozess schnell durchzubringen.

### Tab 6 Prozesse — Drawer-Interaktion (Konsistenz mit Prozess-Mischform)

**Bisher (v1.2):** Klick auf Prozess-Zeile → Direkt-Navigation zu `/processes/[id]` (Vollseite).

**Neu (v1.3) konsistent mit Prozess-Interactions v0.1:**
- Klick auf Prozess-Zeile → **Slide-in-Drawer (540px)** mit:
  - Pipeline-Visualisierung
  - Aktueller Stage + Status
  - Nächstes Interview (Datum + Typ)
  - Letzte 3 Aktivitäten
  - Quick-Actions: Stage ändern / Ablehnen / On Hold / Platzieren
- "→ Vollansicht öffnen" Link im Drawer-Header → `/processes/[id]`

### Tab 7 History — Neue Event-Typen

Zusätzlich zu den bestehenden 11 Filter-Kategorien v1.2 kommt v1.3:

**Neue Filter-Kategorien:**
- **Schutzfrist-Events:** `candidate_presented_email`, `candidate_presented_verbal`, `protection_window_opened`, `protection_window_extended`, `protection_violation_detected`
- **Assessment-Events:** `assessment_credit_assigned`, `assessment_run_scheduled`, `assessment_run_completed`, `assessment_version_created`, `assessment_credit_reassigned_away/to`
- **Referral-Events:** `referral_payout_triggered` (wenn Kandidat Empfehler war)

Filter-Counts 0 = disabled (wie v1.2).

### Tab 8 Dokumente — Scraper-Source-Flag

Dokument-Card zeigt bei automatisch erstellten Dokumenten (z.B. Scraper hat CV auf LinkedIn detektiert, AI hat extrahiert):
- Badge "🕸 Scraper-generiert" (Purple, Scraper-System-Token)
- Source-Info im Hover: "Erstellt aus Scraper-Run #SCR-2026-4721"
- Unterschieden von manuell hochgeladenen Dokumenten

### Tab 10 Reminders — Assessment + Schutzfrist

Neue Auto-Reminder-Typen:
- `assessment_termin_vorbereiten` — X Tage vor Assessment-Termin
- `assessment_coaching_call` — 2 Tage vor Assessment (analog Interview-Coaching)
- `assessment_debriefing_call` — am Termin-Tag abends
- `schutzfrist_info_request_tracking` — bei offenen Info-Requests mit Countdown

### Datenbank-Felder v1.3

**`fact_candidate_werdegang`** (bzw. `dim_candidates_profile.werdegang` JSONB):
- `+ project_id FK → fact_projects` NULL (bei Verknüpfung zu Projekt-Entity)
- Freitext-Projekt-Name bleibt als Fallback wenn `project_id IS NULL` (Legacy)

**`fact_candidate_assessment_*`** Detail-Tabellen (DISC, EQ, Scheelen 6HM, ASSESS 5.0):
- `+ version_id FK → fact_candidate_assessment_version` NOT NULL (ab v1.3)

## Changelog v1.1 → v1.2 (Archiv)

**Ursprüngliche v1.2-Änderungen:**
- KB-Bar CSS in alle 14 Tabs integriert (war in 7 Tabs nur als HTML ohne Style vorhanden)
- KB-Bar Klassen vereinheitlicht: überall `kb-hint-item` (nicht `kb-hint`)
- Legacy-CSS (.topbar, .hw, .ar, .tab etc.) aus allen 5 Assessment-Files entfernt
- Drawer-Breite auf 540px einheitlich (History, Dokumente, AI-Analyse)
- ⌘-Shortcuts → Ctrl im Dok.-Generator (Ctrl als Standard, OS-Erkennung im echten Build)
- SVG-Pipeline Farben in Jobbasket + Prozesse auf WCAG-AA-Werte aktualisiert
- Gesamtüberblick: Inline-Subtabs-Duplikat im Content entfernt
- History: Alle 11 Filter-Kategorien immer sichtbar (Count 0 = disabled/ausgegraut)
- --purple CSS-Variable in allen Assessment-Files ergänzt
- 3-Review-Konsens (Claude 8.25, Perplexity 8.2, ChatGPT 7.6): Alle Findings umgesetzt
- Post-Review QoL: Gesamtüberblick doppelte Subtabs entfernt, Übersicht Tab-Spacing, Teamrad Alignment, DokGenerator Spacing, EQ/Führungsstil Status-Pills in Gesamtüberblick

### Mockup-Dateien (14 Stück)
| # | Tab / Untertab | Dateiname | Version |
|---|---|---|---|
| 1 | Übersicht | kandidat_uebersicht_v8.html | v8 |
| 2 | Briefing | kandidat_briefing_v3.html | v3 |
| 3 | Werdegang | kandidat_werdegang_v2.html | v2 |
| 4a | Assessment › Gesamtüberblick | kandidat_assessment_Gesamtüberblick_v2.html | v2 |
| 4b | Assessment › Scheelen & Human Needs | kandidat_scheelen_6_HM_v2.html | v2 |
| 4c | Assessment › App | — (ausgegraut, wird später gebaut) | — |
| 4d | Assessment › AI-Analyse | kandidat_ai_analyse_v2.html | v2 |
| 4e | Assessment › Vergleich | kandidat_vergleich_v2.html | v2 |
| 4f | Assessment › Teamrad | kandidat_teamrad_v2.html | v2 |
| 5 | Jobbasket | kandidat_jobbasket_v2.html | v2 |
| 6 | Prozesse | kandidat_prozesse_v2.html | v2 |
| 7 | History | kandidat_history_v2.html | v2 |
| 8 | Dokumente | kandidat_dokumente_v2.html | v2 |
| 9 | Dok.-Generator | kandidat_dokgenerator_v2.html | v2 |
| 10 | Reminders | kandidat_reminders_v2.html | v2 |

---

## 0. DESIGNSYSTEM-REFERENZ

### Farben (ARK CI/CD — Dark Default + Light Mode user-umschaltbar, siehe [[design-tokens]])
| Token | Hex | Verwendung |
|---|---|---|
| Schwarz | #262626 | Primary Background |
| Gold | #dcb479 | Akzent, CTAs, aktive Elemente, Primary Buttons |
| Teal | #196774 | Sekundär-Akzent, Tags, Prozess-Badges |
| Dunkelblau | #1b3051 | Tertiär |
| Hellgrau | #eeeeee | Text auf dunklem Hintergrund |
| Green | #5DCAA5 | Erfolg, Bestätigt, Erreicht |
| Red | #ef4444 | Fehler, Überfällig, Rejected |
| Amber | #f59e0b | Warnung, Pending, Heute |
| Blue | #60a5fa | Info, Email, Bald |
| Purple | #a78bfa | AI, Assessment, System-Auto |

### Backgrounds (dunkel-gestuft)
| Token | Hex | Verwendung |
|---|---|---|
| bg-primary | #1e1e1c | Seitenhintergrund |
| bg-card | #2c2c28 | Karten, Sidebar, Topbar |
| bg-elevated | #343430 | Erhöhte Elemente, Inputs |
| bg-hover | #3a3a35 | Hover-States |

### Typografie
| Element | Grösse | Gewicht | Farbe |
|---|---|---|---|
| Sektions-Titel | 13px | 600 | #e8e4dc |
| Body | 12px | 400 | #b5b0a8 |
| Meta/Labels | 10px | 500 | #9a968e |
| Badges | 9px | 600 | kontextabhängig |
| Tiny (Timestamps) | 8–9px | 400 | #726e66 |

### Locale
- Datum: dd.MM.yyyy (31.03.2026)
- Währung: CHF mit Apostroph-Separator (CHF 155'000)
- Sprache: de-CH, deutsche Umlaute Pflicht (ä, ö, ü)
- Initialen für Mitarbeiter: PW, JV, SP, YB, SN, NP, HB, LR

### Globale UI-Patterns
- **Buttons:** Primary = gold bg+border, Secondary = outline only, Destructive = red
- **Badges:** Abgerundet (border-radius: 4–6px), farbcodiert nach Kontext
- **Karten:** border-radius: 10–12px, border: .5px solid rgba(220,180,121,.10)
- **Keyboard-Hints-Bar:** Am unteren Rand jedes Tabs, bg: rgba(220,180,121,.04), tab-spezifische Shortcuts
- **Drawer:** 540px einheitlich, von rechts, Overlay mit blur, Esc/X/Overlay zum Schliessen
- **Popovers:** Erscheinen bei Klick auf SVG-Elemente, schliessen bei Klick aussen
- **Empty States:** Zentriert, Icon (opacity .3–.4) + Titel + Beschreibung + optionaler CTA-Button
- **CSS-Prefix:** Alle Standard-Elemente nutzen `ark-*` Klassen (ark-topbar, ark-header, ark-hdr, ark-tabs, ark-tab, ark-tabs2, ark-tab2, ark-qb etc.)
- **Achtung Dok.-Generator:** CV-Preview Header nutzt `.arkcv-header` (nicht `.ark-header`) um Kollision mit Page-Header zu vermeiden
- **Keyboard-Modifier:** Ctrl+ als Standard in Mockups (im echten Build: OS-Erkennung für ⌘ auf Mac)
- **KB-Bar Klasse:** `kb-hint-item` (nicht `kb-hint`) — einheitlich in allen 14 Tabs

### Standard-Patterns (Phase 3/4)
- **Error-Toast:** Fixiert unten-mitte, auto-dismiss 5s, 3 Varianten (error rot, success grün, warning amber)
- **Error-Banner:** Im Tab-Content, dismissbar, für nicht-blockierende Fehler (z.B. Upload fehlgeschlagen)
- **Confirm-Dialog:** Modal mit Backdrop-Blur, zentriert, für destruktive Aktionen (Löschen, Zurücksetzen)
- **Pagination:** Am Ende langer Listen, "Zeige 1–20 von 147" + Seiten-Buttons

---

## 1. HEADER (Option B: voller Header in jedem Tab, scrollt mit Content)

### Breadcrumb-Topbar (über dem Header)
```
Kandidaten / Max Muster                    🔍 Suche... Ctrl+K   [PW]
```
- Links: Breadcrumb-Navigation (Kandidaten klickbar → Liste)
- Rechts: Suche (Command Palette Trigger) + User-Avatar (Initialen)

### Layout
```
┌──────────────────────────────────────────────────────────────────┐
│ [Avatar 120px]   Max Muster  [A]                                 │
│  Stage-Ring      ✉ email · 📞 telefon · 🔗 LinkedIn              │
│  Gold + Upload   📍 Zürich  [ING] Tiefbau                        │
│                  [Active Sourcing] [🔥 Hot] [WM 7/8] [📞 14–17]  │
│                  Profilvollständigkeit ████████░░ 72%             │
│                  [📞 Anrufen] [✉ Email] [🔄 Stage] [🔔 Reminder] │
├──────────────────────────────────────────────────────────────────┤
│ Übersicht │ Briefing │ Werdegang │ Assessment │ Jobbasket │      │
│ Prozesse │ History │ Dokumente │ Dok.-Generator │ Reminders      │
└──────────────────────────────────────────────────────────────────┘
```

### Avatar
- **120px** (kompakt, da Header in jedem Tab erscheint), border-radius: 50%
- **Stage-Ring:** Farbiger Ring (conic-gradient) basierend auf candidate_stage
- **Gold "+" Upload-Button:** 28px, positioniert rechts unten am Avatar
- Fallback: Initialen-Avatar (MM) in Teal
- **CSS:** `.ark-av-w` (wrap) → `.ark-av-r` (ring) → `.ark-av-i` (inner) + `.ark-av-s` (stage) + `.ark-av-u` (upload)

### Profilvollständigkeit
- Horizontaler Fortschrittsbalken im Header
- Berechnung: Pflichtfelder aus Übersicht + Briefing + Werdegang + Dokumente
- Farbe: grün (>80%), amber (50–80%), rot (<50%)

### Badges
- **Stage:** Aus dim_candidate_stages, farbcodiert
- **Temperature:** Hot (rot) / Warm (amber) / Cold (blau)
- **Wechselmotivation:** Visuell "7/8" mit Mini-Balken
- **Beste Erreichbarkeit:** Berechnet aus History-Tab Anrufzeiten der erreichten Calls

### Quick Actions
- 📞 Anrufen (Click-to-Call via 3CX)
- ✉ Email senden
- 🔄 Stage ändern (Dropdown)
- 🔔 Reminder erstellen

---

## 1b. SNAPSHOT-BAR (sticky `top:0, z-index:50`, 6 Slots, **NEU harmonisiert 2026-04-16**)

Vorher: Kandidatenmaske hatte keine Snapshot-Bar. Neu eingeführt für Feature-Parität mit Account/Mandat/Firmengruppe/Job.

Canonical: `.snapshot-bar` + `.snapshot-item` (lbl/val/delta) — siehe `wiki/concepts/design-system.md` §3.2b. Keine Dupes zum Header (Stage-Dropdown, Temperatur-Chip, Grade-Chip, WM-Chip, Prozess-Link-Chip, Jobbasket-Count-Chip, Schutzfrist-Chip, Profilvollständigkeit-Progress stehen oben).

| Slot | Inhalt | Source |
|------|--------|--------|
| 1 | 🎯 Ø Match-Score | `AVG(fact_candidate_matches.score WHERE candidate_id)` · Delta: „Top-Job: N % (Jobtitel)" |
| 2 | 🧺 Im Jobbasket | `COUNT(fact_candidate_jobbasket WHERE candidate_id AND stage != 'to_send_completed')` · Delta: „N Jobs · N versandt" |
| 3 | ⚙ Aktive Prozesse | `COUNT(fact_process_core WHERE candidate_id AND status = 'Open')` · Delta: „z.B. CFO-Suche · Stage V" |
| 4 | 🔄 Refresh-Due | `DATEDIFF(days, NOW(), next_refresh_due)` · Delta: „letzter Touch vor N d" |
| 5 | 🏆 Placements historisch | `COUNT(fact_process_core WHERE candidate_id AND status = 'Placed')` · Delta: „erster Prozess läuft" (falls 0) |
| 6 | 🎓 Assessments | `COUNT(fact_assessment_orders WHERE candidate_id)` · Delta: Typ-Liste (z.B. „ASSESS 5.0 · EQ 2.0") |

**NIEMALS in Snapshot** (bereits im Header): Stage, Temperatur, Grade, WM, Prozess-Link, Jobbasket-Count, Schutzfrist-Count, Profilvollständigkeit.

---

## 2. TAB 1: ÜBERSICHT

### Sektionen (alle collapsible mit Chevron)

**Stammdaten (Sidebar-Spalte 320 px):**
- Alle Felder aus `dim_candidates_profile` (Personalien · Kontakt · Standort)
- Flags als Toggle-Chips: `blue_collar`, `fachliche_fuehrung`, `df_1_ebene`, `df_2_ebene`, `vr_c_suite`
- **Zuordnung-Sektion:** Sparte (Multi-Pill, mind. 1 Pflicht — siehe Validierung) · **CM** (genau 1 zuweisbar) · **Researcher** (genau 1 zuweisbar) · Owner Team
  - Hinweis (14.04.2026): Beim Kandidaten gibt es nur die Rollen **CM** und **Researcher** (kein „Hunter" als separate Rolle); Researcher ist die kanonische Bezeichnung für die Person aus Tab 2 Longlist (aus Mandat-Sicht).
- **Status &amp; Qualität-Sektion:** Original-CV/ARK-CV-Status · Datenqualität % · Datenfrische % · Stage · **Grade A/B/C** als Toggle-Pills (genau einer aktiv, mutually exclusive — Single-Select, NICHT Multi)

**Functions (`dim_functions`):**
- Smart-Search Autocomplete
- Rating 1–10 pro Function
- Primary-Flag (`is_primary_function`) — genau 1 als Primär markierbar
- „+ Hinzufügen"-Pill (einheitlich über alle Sektionen)
- **Reihenfolge fix** (Sortierung nach Primary, dann Rating desc, dann Name) — kein Drag-Reorder durch User (Konsistenz: Anzeige immer gleich, egal wer schaut)

**Focus (`dim_focus`):**
- Gleiche Darstellung wie Functions
- Rating 1–10
- Teal-farbige Tags zur visuellen Unterscheidung von Functions
- Reihenfolge fix (analog Functions, kein Drag-Reorder)

**Cluster &amp; Subcluster:**
- Separate Container (nicht vermischt)
- `dim_cluster` + `dim_subcluster`

**Branchen (`dim_sector`) — NEU 14.04.2026:**
- Eigene Sektion parallel zu Cluster
- Multi-Select Tags aus `dim_sector` (~50 Einträge)
- Tag-Style **neutral** (kein Gold — wird primär für Reporting/Filter genutzt, keine besondere Hervorhebung)
- Smart-Search Autocomplete
- Reihenfolge alphabetisch

**EDV / Software (`dim_edv`) — KAT-GRUPPIERT 14.04.2026:**
- **Gruppiert nach Kategorien** (sichtbare Sektions-Header je Kategorie):
  - AVA / Kalkulation
  - BIM / CAD
  - ERP
  - Office
  - Projektmanagement
- Pro Eintrag: Software-Name + `skill_level` als Text-Label („Grundkenntnisse" / „Anwender" / „Experte") + Rating 1–10
- „+ Software"-Pill pro Kategorie

**Sprachen (`dim_languages`):**
- Aus `bridge_candidate_languages`
- Level: Muttersprache · C2 · C1 · B2 · B1 · A2 · A1
- Vollnamen aus Stammdaten (Deutsch, Englisch, Französisch, …)

**Briefing-Kurzansicht — NEU 14.04.2026:**
- **Nur Gehalts-Bars** in Tab 1 (3-Zeilen-Visualisierung Aktuell / Schmerzgrenze / Ziel + Marktbenchmark-Hinweis)
- Alle übrigen Briefing-Felder (Wechselmotivation, GO/NO-GO, Hardskills-Notizen, Selbstbild, Führung, Motivation, Persönliches) **bleiben ausschliesslich in Tab 2 Briefing**
- Cross-Sync mit Tab 2 (Änderung an Gehaltsbars hier reflektiert in Tab 2 und umgekehrt)

**AI-Vorschläge — VEREINFACHT 14.04.2026:**
- **Globaler Hinweis-Banner** oben im Tab (gelb, klein) wenn AI-Vorschläge vorhanden sind
- Inline pro Feld: Markierung der Quelle nur für **CV-Parse** und **Scraper-Funde** (kleines Icon/Indikator), mit **Accept / Reject** direkt am Feld
- **Keine** AI-berechneten Aussagen wie „Seniority Senior 88 %" oder „Profil-Match Gesamtprojektleiter 92 %" mehr im UI
- Keine Confidence-Scores im UI (im Backend in `fact_ai_suggestions` weiterhin gespeichert für Audit)

**Source-Badges — REDUZIERT 14.04.2026:**
- **Nur global** im Header-Banner: zeigt aggregiert, welche Quellen den Datensatz gefüllt haben (z.B. „🟢 cv_parse · 🟦 linkedin · 🟪 manual")
- **Nicht mehr pro Sektion** (Reduktion visueller Lärm — User-Entscheidung 14.04.2026)

### Validierung

- **Sparte:** mind. 1 aktiv Pflicht. UI-Feedback: Versuch, letzte aktive zu deaktivieren, zeigt Toast-Error „Mind. eine Sparte muss aktiv bleiben."
- **Grade (A/B/C):** genau 1 aktiv (Single-Select-Pills); Klick auf inaktive Pill ersetzt aktuelle Auswahl.
- **CM / Researcher:** je max. 1 Person; bei Reassignment Confirm-Dialog.

### Keyboard
- ↑↓ Sektion wechseln
- Enter: Sektion auf-/zuklappen
- E: Inline-Edit Modus
- S: Speichern
- Esc: Edit abbrechen

**KB-Hints-Bar** unten an jedem Tab (`.kb-bar`) zeigt aktive Shortcuts. Konsistent über alle 10 Tabs.

---

## 3. TAB 2: BRIEFING

### Terminologie (CLAUDE.md §Arkadium-Rolle-Regel)

> „Briefing" in diesem Tab = **Eignungsgespräch Arkadium ↔ Kandidat** nach Hunt/Research. **Nicht zu verwechseln** mit anderen Arkadium-Touchpoints:

| Begriff | Teilnehmer | Wann | Wo erfasst |
|---------|-----------|------|-----------|
| **Briefing** (dieser Tab) | Arkadium ↔ Kandidat | Einmalig nach Hunt/Research | Kandidatenmaske Tab 2 (dieses) |
| **Coaching** | Arkadium ↔ Kandidat | VOR jedem Interview — Kandidat-Vorbereitung | Prozess-Detailmaske Tab 2 Interview-Timeline |
| **Debriefing** (beidseitig) | Arkadium ↔ Kandidat UND Arkadium ↔ Kunde | NACH jedem Interview (je 2 Events) | Prozess-Detailmaske Tab 2 Interview-Timeline |
| **Referenzauskunft** | Arkadium ↔ Referenzperson | Vor Placement, im Kunden-Auftrag | Prozess-Detailmaske |
| **Stellenbriefing** | Arkadium ↔ Kunde über Stelle | Am Mandats-Start | Account/Job/Mandat-Detailmaske |

Interviews selbst (TI / 1st / 2nd / 3rd / Assessment) laufen **direkt Kunde ↔ Kandidat** — Arkadium ist bei keinem Interview Teilnehmer.

### Versionierung
```
← [Briefing vom 15.03.2026] → [+ Neues Briefing]
  Version 3 von 3
```
- Unbegrenzt viele Briefings pro Kandidat
- Pfeil-Navigation, aktuellste immer zuerst (links = neueste)
- DB: fact_candidate_briefing (KEIN UNIQUE auf candidate_id)

### AI Auto-Fill aus History
- History-Eintrag mit Type "Erreicht - GO Termin aus oder im Briefing" →
  AI verarbeitet Transkript im Hintergrund → füllt Briefing-Felder vor
- **Asynchron** — User kann weiterarbeiten
- AI-Banner oben: "X Felder aus Transkript vorausgefüllt — Prüfen & Bestätigen"

### Quick-Jump Sidebar (rechts)
- Vertikale Sektions-Navigation
- Fortschritts-Dots pro Sektion: grün (komplett), amber (teilweise), grau (leer)
- Klick scrollt zur Sektion

### Sektionen (alle mit definierten Dropdowns — Werte in Stammdaten v1.3 Section 8)

**Gehalt & Vergütung:**
- Fixlohn, Schmerzgrenze, Ziel: Separate CHF-Felder mit horizontalen Balken
- Inline-Edit: Klick auf CHF-Betrag → Input → Balken aktualisiert sich live
- STI/LTI: CHF Integer (nicht Prozent)
- Spesen-Pauschale, ÖV-Abo-Wert, Fahrzeug (Dropdown 4 + Typ + Abzug)
- Lohnsituation: Dropdown 5 (Unter Markt, Leicht unter, Im Markt, Leicht über, Über Markt)
- Total Paket: Automatisch berechnet
- Marktmedian-Benchmark Linie im Balken-Chart

**Arbeit & Verfügbarkeit:**
- Pensum aktuell/gewünscht: Dropdown (40%, 50%, 60%, 70%, 80%, 100%)
- Anstellungssituation: Dropdown (Festangestellt, Temporär, Selbstständig, Arbeitssuchend)
- Kündigungsfrist: Dropdown (Sofort, 1 Monat, 2 Monate, 3 Monate, 6 Monate)
- Wechselmotivation: 8-Stufen-Selektor (synced mit Header-Badge), klickbare Stufen

**Mobilität:**
- Mobilität: Multi-Select (Auto, ÖV, Fahrrad, Zu Fuss)
- Arbeitsweg max.: Dropdown (15 min, 30 min, 45 min, 60 min, 90 min, Egal)
- Umzugsbereitschaft: Dropdown (Ja sofort, Ja bei richtigem Angebot, Eher nein, Nein, Nur innerhalb Kanton)
- Homeoffice aktuell/gewünscht: Dropdown (0%, 20%, 40%, 60%, 80%, 100%)
- Regionen: Freitext

**Bewertung:**
- A/B/C Dropdown
- GO-Themen: Freitext
- NO-GO-Themen: Freitext (rote Box, visuell stark hervorgehoben)

**Kompetenzen (2-Spalten Grid):**
- Hardskills, Social Skills, Methoden, Führung: alle Freitext

**Persönlichkeit (2-Spalten Grid):**
- Selbstbild, Fremdbild, Motivation, Bedürfnisse, Triggerpunkt, Moderation

**Zonen:**
- 4-Zonen-Bar: Komfort (grün), Lern (gold), Wachstum (amber), Angst (rot)
- Sweet Spot: Goldene Highlight-Card

**Privat:**
- Zivilstand: Dropdown (Ledig, In Partnerschaft, Verheiratet, Geschieden, Verwitwet)
- Kinder: Dropdown (0, 1, 2, 3, 4, 5+)
- Leidenschaft: Freitext

**Projekte:**
- Aus dim_projects (bridge_briefing_projects)
- Synchronisiert mit Werdegang-Tab
- AI ordnet Projekte automatisch Arbeitsstationen zu (basierend auf Zeitraum + Arbeitgeber)
- Klick → Drawer mit Projekt-Detail

### UX-Features
- Autosave-Indikator, Dirty-State (gold ●)
- Sektion-Fortschritt pro Header ("11/13 Felder")
- Zeitstempel pro Sektion
- History-Chip: "Aus: Briefing-Gespräch DD.MM.YYYY"
- Verpflichtungs-Warnung Banner (rot) wenn aktiv
- Keyboard: Tab/Shift+Tab Feldwechsel, Ctrl+S Speichern

---

## 4. TAB 3: WERDEGANG

### Vertikale Timeline
- Chronologisch (neueste oben)
- Farbcodierte Zugang/Abgang Pills: Zugang (grün), Abgang (rot/grau)
- Sektions-Headers: "Beruf" / "Aus- / Weiterbildung" (visuell getrennt)
- Zeitstrahl-Linie links

### Station (fact_candidate_employment)
- Verknüpfungen: Function, Account (dim_accounts), Focus, Education, Cluster, Sector, Sparte
- entry_type: job (Standard), education (Ausbildung), gap, other — visuell unterschieden
- Aktuell angestellt: Grüner Indikator + "Aktuell" Badge
- Klick → Drawer mit Details + verknüpften Projekten

### Projekte pro Station
- Expandierbar unter jeder Arbeitsstation
- AI ordnet automatisch Projekte aus Briefing den Stationen zu (Zeitraum + Arbeitgeber Match)
- Verknüpfung mit dim_projects (globaler Katalog)

### Auto-Fill
- LinkedIn-Import füllt Arbeitsstationen + Ausbildungen
- Scraper-Import füllt aktuelle Position
- AI matcht Firmennamen mit bestehenden dim_accounts

### Keyboard
- ↑↓ Station wechseln
- Enter: Station öffnen (Drawer)
- N: Neue Station hinzufügen

---

## 5. TAB 4: ASSESSMENT (6 Untertabs, App ausgegraut)

### Doppel-Navigation
Alle Assessment-Untertabs zeigen ZWEI Tab-Leisten:
1. **Haupttabs (10):** "Assessment" gold aktiv
2. **Untertabs (6):** Aktiver Untertab in **lila** (#a78bfa), "App" ausgegraut (disabled)

```css
.ark-tabs2 { background: var(--bg-e); }  /* Dunklerer Hintergrund als Haupttabs */
.ark-tab2.active { color: #a78bfa; border-bottom-color: #a78bfa; }
.ark-tab2.disabled { opacity: .5; cursor: default; }
```

### Sub-Tabs
```
Gesamtüberblick │ Scheelen & Human Needs │ App (ausgegraut) │ AI-Analyse │ Vergleich │ Teamrad
```

### Mockup-Zuordnung
| Untertab | HTML-Mockup | Bemerkung |
|---|---|---|
| 4a Gesamtüberblick | kandidat_assessment_Gesamtüberblick_v2.html | Dashboard |
| 4b Scheelen & Human Needs | kandidat_scheelen_6_HM_v2.html | DISC, Motivatoren, Relief, ASSESS 5.0, HN, BIP, EQ |
| 4c App | — (ausgegraut, wird gebaut wenn ARK Insight App soweit) | ARK Insight |
| 4d AI-Analyse | kandidat_ai_analyse_v2.html | Cross-Analysis |
| 4e Vergleich | kandidat_vergleich_v2.html | 2–8 Kandidaten |
| 4f Teamrad | kandidat_teamrad_v2.html | Team-Zusammenstellung + Analyse |

### Versionierung (pro Analyse-Typ individuell)
- Jeder Analyse-Typ hat eigene Pfeil-Navigation
- Aktuellste Version zuerst

### Gesamtüberblick
- Dashboard über alle Analyse-Typen
- Key-Scores auf einen Blick
- AI-Cross-Analysis Summary
- "Wann zuletzt gemacht?" Übersicht — Status-Pills für: DISC, Motivatoren, Relief, ASSESS 5.0, Human Needs/BIP, EQ (Scheelen), App (grau), Führungsstil (grau, App), AI-Analyse
- Neue Analyse Dropdown: alle Module + Führungsstil ausgegraut (App-abhängig), EQ aktiv (Scheelen)

### Scheelen & Human Needs
- DISC: Ringdiagramm (4 Quadranten), Natural vs. Adapted, 12 Sub-Dimensionen
- Motivatoren: 12 Driving Forces als Balken (paarweise)
- Relief: Stressoren/Resilienz/Motivation (3 Untertabellen), Burnout-Risk Ampel
- ASSESS 5.0: Einzelne Kompetenzen als Balkendiagramm, Spider/Radar Gesamt, Soll vs. Ist
- 6 Human Needs: Balken
- EQ (Emotionale Intelligenz): 5 Dimensionen (Selbstwahrnehmung, Selbstregulierung, Soziale Wahrnehmung, Soziale Regulierung, Motivation) als Score-Karten mit Gesamtscore + KI-Zusammenfassung
- Bochumer Inventar (BIP): 12 Dimensionen als Spider/Radar

### App (ARK Insight)
- App-spezifische Analysen (DISC, Führungsstil)
- Antwortzeiten pro Frage + Verteilung (Histogramm)
- Auffälligkeiten: Zu schnell (nicht gelesen?), Zu lange (outzoned? abgelenkt?)

### AI-Analyse
- Cross-Analysis über ALLE Assessment-Typen (6 Module: DISC, Motivatoren, Relief, ASSESS 5.0, BIP-6F, EQ)
- Stärken / Entwicklungsfelder
- Entwicklungs-Tracking: Vergleich mit früheren Versionen, Trend-Charts
- "Neue Analyse generieren" Button
- Versioniert (Pfeil-Navigation)

### Vergleich
- 2–8 Kandidaten nebeneinander, Dimensionen wählbar
- Overlay Spider-Graphs, AI-Summary, PDF Export

### Teamrad
- Eigenständiges Mockup (kandidat_teamrad_v2.html, 996 Zeilen)
- Team-Zusammenstellung: Mitarbeiter aus Organigram/Stellenplan auswählbar
- Alle Analyse-Typen aufstellbar (DISC, Motivatoren, Relief, ASSESS 5.0, EQ, Human Needs, BIP)
- Harmonien + Spannungsfelder erkennen
- Lückenanalyse + AI-Empfehlung
- Export als PDF
- **Auch erreichbar über Account-Detailmaske → Tab Teamrad**

---

## 6. TAB 5: JOBBASKET

### AI-Matching Vorschläge (oben)
- 3 Karten mit Score (0–100) + Breakdown (Sparte, Function, Salary, Location, Skills, Availability, Experience)
- "Als Prelead hinzufügen" Quick-Action
- Score aus fact_match_scores, zieht aus gesamtem Kandidatenprofil

### Job-Suche
- Suchfeld mit Account/Job Filter
- Ergebnisse: "In Basket" Jobs → "✕ Entfernen" Button, "Offen" → "+ Prelead" Button

### GO-Pipeline (SVG pro Job)
```
Prelead → Oral GO → Written GO → Assigned → To Send → CV Sent / Exposé
```
- Nodes: Ausgefüllt = erreicht, Hohlring = aktuell, Grau = ausstehend
- Pulsierender Ring am aktuellen Stage
- Datum unter jedem erreichten Node

### Gate 1 — Stufengerechte Logik
| Stage | Verhalten |
|---|---|
| Prelead | Button "Mündliche GOs versenden" |
| Oral GO | "Warte auf schriftliche Bestätigung" |
| Written GO | Prüft Dokumente: Original CV ✓, Diplom ✓, Arbeitszeugnis ✓ |
| Assigned | Alle Dokumente vorhanden → automatisch |

### Gate 2 — Versandoptionen (nach Assigned)
- "CV senden" sichtbar wenn: ARK CV + Abstract vorhanden
- "Exposé senden" sichtbar wenn: Exposé vorhanden

### Rejection
- Modal mit Pflicht-Dropdowns:
  - **Wer:** Candidate / CM / AM
  - **Warum:** Aus dim_jobbasket_rejection_types
- Ghosting-Warnung: 1× pro Job (kein Duplikat)

### QoL
- Pipeline-Summary Chips oben als klickbare Stage-Filter
- Job-Container zuklappbar mit Chevron
- Sortierung: Stage/Datum/Account
- Action-Required Badge (dynamisch berechnet)
- Keyboard: ↑↓ Navigation, Enter Auf-/Zuklappen, S Suche, Esc Reset

---

## 7. TAB 6: PROZESSE

### Ansicht umschaltbar: Cards (Default) / Kanban

### SVG Pipeline pro Prozess

> Shared-Component: Details in `ARK_PIPELINE_COMPONENT_v1_0.md` (Single Source of Truth). Hier nur Kandidaten-Tab-spezifische Abweichungen.

Kandidaten-Tab-6 verwendet `compact`-Mode:
- SVG-Linie inline pro Prozess-Card (bei > 50 Prozessen CSS-only-Fallback)
- WinProb **nicht** als 280 px Panel, sondern als Info-Row unter SVG (siehe §Info-Row)
- Kein Stage-Popover — Hover-Tooltip nur. Stage-Wechsel via Prozess-Detailmaske öffnen.
- Debriefing-Dots zwischen Interview-Stages (TI↔1st, 1st↔2nd, 2nd↔3rd): lila 📝 vs grau —
- Skip-Stages: gestrichelte Hohlringe, Datum unter jedem passed-Node, Assessment ohne Datum, Placement als Diamant bei Placed-Status

Siehe `ARK_PIPELINE_COMPONENT_v1_0.md` §§3–8 für Dot-States, Performance-Fallback, Accessibility.

### Debriefing-Warnung beim Weiterschalten
- Wenn Interview-Stage (TI/1st/2nd/3rd) weitergeschaltet wird und kein Debriefing existiert:
  → Orange Warnung: "Kein Debriefing vorhanden"
  → **"Trotzdem weiter (Ghosting / Kunden-Info)"** Override-Button

### Info-Row pro Prozess
- Win-Probability (% pro Stage)
- Tage in Pipeline (seit Expose-Datum)
- **AM als Initialen** (nicht CM — der ist auf Kandidat-Ebene)

### Kanban
- Drag & Drop zwischen Spalten
- **Interview-Stages (TI, 1st, 2nd, 3rd):** Datum-Prompt Modal beim Drop
- **Assessment:** Kein Datum beim Drop
- "Hierher ziehen" Platzhalter in leeren Spalten
- Win% pro Spalte

### Stage-Popover (Klick auf Pipeline-Node)
- Datum setzen/ändern
- "→ Weiter" mit Dropdown gültiger Transitions
- Debriefing-Check vor Advance

### Mandats-Tags pro Prozess
- Target (gold), Taskforce (teal), Time (blue), Erfolgsbasis (grau)
- AGB-Warnung wenn Account keine bestätigten AGB hat

### Keyboard
- ↑↓ Navigation, Enter Auf-/Zuklappen, L Cards, K Kanban

---

## 8. TAB 7: HISTORY

### Chronologische Timeline, gruppiert nach Woche
- "Diese Woche", "Letzte Woche", "Vor 2 Wochen" etc. mit Einträge-Zähler
- Farbige Dots: Phone (grün), Email (blau), System (lila), Meeting (gold), LinkedIn (blau), WhatsApp (grün)

### Anruf-Statistik Summary (oben)
- Anrufe gesamt, Erreicht (%), Minuten Gesprächszeit
- **Beste Erreichbarkeit:** Berechnet aus Uhrzeiten der erreichten Calls → auch im Header

### Filter & Suche
- 11 Kategorie-Filter (Kontaktberührung, Erreicht, Emailverkehr, Messaging, Interviewprozess, Placementprozess, Refresh Kandidatenpflege, Mandatsakquise, Erfolgsbasis, Assessment, System) — **alle immer sichtbar**, Count 0 = disabled/ausgegraut
- Freitext-Suche über Type, Body, Erfasser
- Datum-Range-Filter (Von/Bis)

### Klassifizierung
- **confirmed:** ✓ Bestätigt (grün)
- **ai_suggested:** AI-Vorschlag (lila) + 1-Klick Bestätigen Button
- **pending:** ⏳ Offen (amber)
- **manual:** Manuell (blau)

### Drawer (Klick auf Eintrag) — kontextabhängige Tabs

| Call-Typ | Übersicht | Transkript | AI-Summary | AI → Briefing | Email-Thread | Reminders |
|---|---|---|---|---|---|---|
| Erreicht (normal) | ✓ | ✓ | ✓ | — | — | ✓ |
| Briefing-Call (GO Termin aus/im Briefing) | ✓ | ✓ | — | ✓ (Link zu Briefing-Tab) | — | ✓ |
| NE (Kontaktberührung) | ✓ | — | — | — | — | ✓ |
| Email | ✓ | — | — | — | ✓ (Thread + Reply) | ✓ |
| System-Auto | ✓ | — | — | — | — | ✓ |

**Drawer-Tab "AI → Briefing":** Zeigt Hinweis "Output in Briefing-Maske" + Button "→ Briefing-Tab öffnen"

**Drawer-Tab "Reminders":** Neuen Reminder direkt aus History-Eintrag erstellen (Text, Datum, Uhrzeit, Priorität)

### Verknüpfungs-Badges
- Prozess (teal 🔄), Job (gold 💼), Mandat (lila 📋) — klickbar, navigiert zur Entität

### Keyboard
- ↑↓ Navigation, Enter Drawer öffnen, N Neuer Eintrag, Esc Schliessen

---

## 9. TAB 8: DOKUMENTE

### Gate-1 Checkliste (oben)
- Prüft 4 Pflicht-Dokumente: Original CV ✓/✗, Diplom ✓/✗, Arbeitszeugnis ✓/⏳, Schriftl. GO ✓/✗
- Farbcodiert: grün (bereit), gold (in Verarbeitung), rot (fehlend, klickbar)
- Rechts: "✓ Gate 1 bestanden" oder "⚠ Gate 1 blockiert"

### Upload Zone
- Drag & Drop ODER Klick → Ordner-Auswahl
- Max 20 MB pro Datei
- Erlaubte Typen: PDF, DOCX, XLSX, JPG, PNG

### Dokument-Labels (11 Stück, exakt aus Stammdaten)
Original CV, ARK CV, Abstract, Exposé, Arbeitszeugnis, Diplom, Zertifikat, Assessment-Dokument, Mandatsofferte unterschrieben, Mandat Report, Sonstiges

### 7-Stufen Pipeline (automatisch, kein manueller Schritt)
hochgeladen → scannt (Virus) → OCR / Parsing → Entities → AI Suggestions → Embedding → bereit

### Dokument-Liste
- Label-Filter mit Zähler
- Freitext-Suche (Name, Label, Uploader)
- Sortierung: Datum ↓, Name A–Z, Grösse ↓, Status (offen zuerst)
- Pipeline-Mini-Visualisierung (7 kleine Quadrate pro Dokument)
- Hover-Actions: Download, Reparse, Löschen

### Drawer (4 Tabs)
- **Preview:** Interaktiver Seiten-Editor
  - Thumbnails mit Mock-Content (variiert pro Seite)
  - **Drehen:** 90°/180°/270° pro Seite, visuell rotiert, Badge zeigt Grad
  - **Löschen:** Seite entfernen (min. 1 Seite muss bleiben)
  - **Drag & Drop:** Seitenreihenfolge ändern
  - **Hinzufügen:** Neue Seite am Ende
  - **Rückgängig:** Alle Änderungen zurücksetzen
  - Klick auf Thumbnail → grosse Vorschau darunter
  - Hinweis: "Änderungen als neue Version gespeichert"
- **Details:** Metadaten + Label ändern (klickbare Buttons für alle 11 Labels) + Aktionen (Reparse, Download, Löschen)
- **Pipeline:** 7-Stufen Detail-Ansicht mit Status pro Stufe
- **Versionen:** Version-History mit "Aktuell" Badge und "Wiederherstellen" Button

### Mandatsofferte-Trigger
- Upload mit Label "Mandatsofferte unterschrieben" → Mandat automatisch auf Aktiv

### Keyboard
- ↑↓ Navigation, Enter Preview, U Upload, S Suche, Esc Schliessen

---

## 10. TAB 9: DOK.-GENERATOR

### 3 Dokumenttypen

| Typ | Badge | Besonderheiten |
|---|---|---|
| ARK CV | Intern + Kunde | Vollständig + Gehalt (rot "nur intern") + Projektliste |
| Abstract | Für Kunden | Kurz + optionales Anschreiben mit Account-Kontakt |
| Exposé | Anonymisiert | Name/Foto/Firmen anonymisiert, Toggles in Sidebar |

### Daten-Vollständigkeit Check (oben)
- Pro Quelle: ✓ Stammdaten, ✓ Briefing, ⚠ Projekte (2 von 5 ohne Beschreibung), ✓ Dokumente
- Klickbar → navigiert zum entsprechenden Tab

### Template-Auswahl
- Classic / Modern / Minimal (visuell umschaltbar)

### Sidebar (links, einklappbar)
- **Sektions-Steuerung:** Checkboxen ein/aus + Drag & Drop Reihenfolge (⋮⋮ Grip)
- **Exposé:** Anonymisierungs-Toggles (Name, Foto, Firmennamen, Kontaktdaten)
- **Abstract:** Empfänger-Dropdown (Account-Kontakte) → personalisiertes Anschreiben

### Sektionen (ein-/ausschaltbar)

| Sektion | Quelle | ARK CV | Abstract | Exposé |
|---|---|---|---|---|
| Anschreiben | Job/Account | — | ✓ Default | — |
| Kandidaten-Header | Übersicht | ✓ Immer | ✓ Immer | ✓ Anon |
| Personalien | Übersicht | ✓ Default | ✓ Default | ✓ Reduziert |
| Kurzprofil (AI) | AI | ✓ Default | ✓ Default | ✓ Default |
| Funktionen & Fokus | Übersicht | ✓ Default | ✓ Default | ✓ Default |
| EDV / Software | Übersicht | ✓ Default | ✓ Default | ✓ Default |
| Beruflicher Werdegang | Werdegang | ✓ Default | ✓ Default | ✓ Firmen anon |
| Aus-/Weiterbildung | Werdegang | ✓ Default | ✓ Default | ✓ Default |
| Referenzprojekte | Briefing/Werdegang | ✓ Optional | — | — |
| Kompetenzen | Briefing | ✓ Default | ✓ Default | ✓ Default |
| Sprachen | Briefing | ✓ Default | ✓ Default | ✓ Default |
| Gehalt | Briefing | ✓ Optional | — | — |
| Assessment | Assessment | ✓ Optional | — | ✓ Optional |
| Beilagen | Dokumente | ✓ Default | ✓ Default | ✓ Default |

### Live-Vorschau (rechts)
- Weisser Hintergrund, ARK-Branding Header (Logo + Dokumenttyp)
- Wasserzeichen diagonal (ANONYMISIERT / ABSTRACT / ARK EXECUTIVE SEARCH)
- Gold-Akzente (Seitenlinien bei Werdegang, Skill-Tags)
- Seitenumbruch-Markierungen (gestrichelt)
- Footer: ARK Executive Search · Datum · Vertraulich

### WYSIWYG-Toolbar
- B/I/U, Listen/Nummerierung, Überschriften-Dropdown, Schriftart, Bild/Link, Undo/Redo
- Zoom: 50%–150% in 25%-Schritten (−/+/Wert)

### Bottom-Bar
- AI-Text generieren, PDF exportieren, Speichern, Neue Version
- Seitenanzahl-Schätzung: "~3 Seiten · A4" (dynamisch)
- Versions-Pills (v1/v2)

### Keyboard
- Ctrl+S Speichern, Ctrl+P PDF Export, Ctrl+Z Rückgängig, Ctrl+B Sidebar toggle

---

## 11. TAB 10: REMINDERS

### Summary-Karten (oben)
- Offen gesamt, Überfällig (rot), Heute (amber), Bald (blau)

### 5 Filter-Tabs
- Alle (zeigt offene, gruppiert nach Status), 🔴 Überfällig, 🟡 Heute, 🔵 Bald, ✓ Erledigt

### Gruppierung in "Alle"-Ansicht
- Sektions-Headers mit farbigen Dots: "🔴 Überfällig (2)", "🟡 Heute (2)", "🔵 Bald (4)"
- Innerhalb Gruppe: Hohe Priorität zuerst, dann chronologisch

### Reminder-Karte
- Farbiger Seitenstreifen links (rot/amber/blau/grün)
- Checkbox zum Erledigen (Toggle, visuell durchgestrichen)
- Text + relative Datumsanzeige ("vor 3 Tagen", "Heute 16:00", "in 2 Tagen")
- Priority-Badge (Hoch/rot, Mittel/amber, Tief/grau)
- Quellen-Badge (⚡ Auto / ✎ Manuell)
- Verknüpfungs-Badges (Prozess teal, Job gold, History grün) — klickbar
- Snooze-Buttons: +1h, +1d, +1w → Toast-Feedback ("⏰ Verschoben: +1 Tag → 01.04.2026")
- Edit-Button (✏, erscheint auf Hover)

### Neuer Reminder Form (öffnet oben, nicht unten)
- Text, Datum (Default: morgen), Uhrzeit (Default: 09:00), Priorität, Verknüpfung

### Auto-generierte Reminders (aus dem System)
- Kandidat ohne Briefing (7d)
- Onboarding Call (Start-7d)
- Post-Placement-Checks (1./2./3. Monat · 3-Mt = Garantiefrist-Ende)
- Stale Prozess (>14d)
- Data Retention Warnung (30d)
- Ghosting
- Datenschutz-Reset
- Interview-Datum fehlt (2d nach Stage-Wechsel)

### Keyboard
- ↑↓ Navigation, Space Erledigen, N Neuer Reminder, 1–5 Filter, Esc Reset

---

## 12. CROSS-TAB DATENFLUSS

| Von → Nach | Was fliesst |
|---|---|
| Briefing → Dok-Generator | Gehalt, Kompetenzen, Sprachen, Projekte |
| Werdegang → Dok-Generator | Arbeitsstationen, Ausbildungen |
| Assessment → Dok-Generator | DISC-Zusammenfassung |
| Übersicht → Dok-Generator | Functions, Focus, EDV, Foto, Kontaktdaten |
| Dokumente → Dok-Generator | Beilagen (Diplome, Zeugnisse) |
| Dokumente → Jobbasket | Gate-1 Checkliste (Original CV, Diplom, Arbeitszeugnis) |
| Jobbasket → Prozesse | CV Versand → Prozess-Erstellung |
| History → Prozesse | Debriefing-Einträge → Debriefing-Dots in Pipeline |
| History → Briefing | Briefing-Call Transkript → AI Auto-Fill |
| History → Header | Anrufzeiten → Beste Erreichbarkeit |
| Briefing → Werdegang | Projekte → automatische Zuordnung zu Arbeitsstationen |
| Jobbasket Gate-2 → Dokumente | Prüft ob ARK CV/Abstract/Exposé vorhanden |

---

## 13. PHASE-ZUORDNUNG

### Phase 1 (Launch-Blocker)
Alle 10 Tabs mit Kern-Funktionalität, Dark + Light Mode, Keyboard Navigation, Basic Drawer/Popovers, Error-States, Confirm-Dialoge, Pagination

### Phase 1.5 (4 Wochen nach Launch)
AI Auto-Fill Briefing, AI Activity-Type Vorschläge, Transkript-Summaries, Email-Composer, 3CX Click-to-Call, Assessment App-Subtab (wenn ARK Insight App bereit)

### Phase 2 (3–6 Monate nach Launch)
WYSIWYG Dok-Generator (Phase 1: PDF-Template-basiert), Assessment-Charts (D3/Recharts), Kanban D&D, Teamrad, Semantische Suche, AI Matching, Recurring Reminders

---

## 14. HARMONISIERUNGS-STATUS

### Abgeschlossen (Phase 1–4 + Post-Review Fixes)
- ✅ CSS-Variablen vereinheitlicht (ark-* Standard, WCAG AA Kontraste)
- ✅ Header Option B in allen 14 Tabs (120px Avatar, Badges, Quick Actions)
- ✅ Tab-Navigation einheitlich (.ark-tab / .ark-tab.active, Assessment L2: .ark-tab2 / .ark-tab2.active)
- ✅ Assessment Doppel-Navigation (Haupttabs + lila Untertabs, --purple Variable)
- ✅ Keyboard-Bars in allen 14 Tabs (CSS + HTML + einheitliche kb-hint-item Klasse)
- ✅ Linksbündig (kein margin:0 auto)
- ✅ Error-Banner, Confirm-Dialog, Pagination-Pattern demonstriert
- ✅ Toast CSS (Error/Success/Warning) in 4 Tabs
- ✅ Legacy-CSS (.topbar, .hw, .tab, .ar etc.) aus allen Assessment-Files entfernt
- ✅ Drawer-Breite einheitlich 540px (History, Dokumente, AI-Analyse)
- ✅ Ctrl als einheitlicher Modifier (kein ⌘ mehr in Mockups)
- ✅ SVG-Pipeline Farben auf WCAG AA aktualisiert (Jobbasket, Prozesse)
- ✅ History: Alle 11 Filter-Kategorien immer sichtbar (Count 0 = disabled)
- ✅ Gesamtüberblick: Inline-Subtabs-Duplikat entfernt
- ✅ EQ-Sektion in Scheelen & Human Needs ergänzt (5 Dimensionen + Gesamtscore)
- ✅ EQ-Source-Pill in AI-Analyse ergänzt (6/6 Module)
- ✅ Dok.-Generator: CSS-Klassen-Kollision behoben (.ark-header → .arkcv-header für CV-Preview)
- ✅ 3 unabhängige Reviews bestanden (Claude, ChatGPT, Perplexity)

### Offen
- ⏳ Assessment App-Subtab (ausgegraut bis ARK Insight bereit)
