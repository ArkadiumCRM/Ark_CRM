# ARK CRM — Kandidaten-Detailmaske Schema v1.2

**Stand:** 01.04.2026
**Status:** Verbindlich für Frontend-Implementierung
**Quellen:** ARK_FRONTEND_FREEZE_v1_10.md (Section 4d.1), ARK_STAMMDATEN_EXPORT_v1_3.md, ARK_DATABASE_SCHEMA_v1_3.md, 14 harmonisierte HTML-Mockups
**Vorrang:** Bei Widerspruch gilt: Stammdaten > dieses Schema > Frontend Freeze > Mockups
**Änderungen v1.1 → v1.2:**
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

### Farben (ARK CI/CD — Dark Mode only)
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

## 2. TAB 1: ÜBERSICHT

### Sektionen (alle collapsible mit Chevron)

**Stammdaten (2-Spalten Grid):**
- Alle Felder aus dim_candidates_profile
- Flags als Toggle-Chips: blue_collar, fachliche_fuehrung, df_1_ebene, df_2_ebene, vr_c_suite
- Zuständig: CM (Initialen), Hunter (Initialen), Team

**Functions (dim_functions):**
- Smart-Search Autocomplete
- Rating 1–10 pro Function
- Primary-Flag (is_primary_function)
- Gold-Outline Pill "Hinzufügen" Button (einheitlich über alle Sektionen)

**Focus (dim_focus):**
- Gleiche Darstellung wie Functions
- Rating 1–10
- Teal-farbige Tags (Focus ≠ Function visuell unterscheidbar)

**Cluster & Subcluster:**
- Separate Container (nicht vermischt)
- dim_cluster + dim_subcluster

**EDV / Software (dim_edv):**
- Tags mit Rating 1–10
- Zusätzlich: skill_level Text (Grundkenntnisse/Anwender/Experte)
- Kategorien: AVA/Kalkulation, BIM/CAD, ERP, Office etc.

**Sprachen:**
- Aus bridge_candidate_languages
- Level: Muttersprache, C2, C1, B2, B1, A2, A1

**Source-Badges:** cv_parse (grün), briefing (gold), assessment (lila), linkedin (blau), scraper (teal), manual (grau)

**AI-Vorschläge:** Gelbe Badges "AI-Vorschlag" mit Confidence-Score, Klick übernimmt → fact_ai_suggestions

### Keyboard
- ↑↓ Sektion wechseln
- Enter: Sektion auf-/zuklappen
- E: Inline-Edit Modus
- S: Speichern

---

## 3. TAB 2: BRIEFING

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
| 4b Scheelen & Human Needs | kandidat_scheelen_6_HM_v2.html | DISC, Motivatoren, Relief, Outmatch, HN, BIP, EQ |
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
- "Wann zuletzt gemacht?" Übersicht — Status-Pills für: DISC, Motivatoren, Relief, Outmatch, Human Needs/BIP, EQ (Scheelen), App (grau), Führungsstil (grau, App), AI-Analyse
- Neue Analyse Dropdown: alle Module + Führungsstil ausgegraut (App-abhängig), EQ aktiv (Scheelen)

### Scheelen & Human Needs
- DISC: Ringdiagramm (4 Quadranten), Natural vs. Adapted, 12 Sub-Dimensionen
- Motivatoren: 12 Driving Forces als Balken (paarweise)
- Relief: Stressoren/Resilienz/Motivation (3 Untertabellen), Burnout-Risk Ampel
- Outmatch: Einzelne Kompetenzen als Balkendiagramm, Spider/Radar Gesamt, Soll vs. Ist
- 6 Human Needs: Balken
- EQ (Emotionale Intelligenz): 5 Dimensionen (Selbstwahrnehmung, Selbstregulation, Soziale Wahrnehmung, Soziale Regulierung, Motivation) als Score-Karten mit Gesamtscore + KI-Zusammenfassung
- Bochumer Inventar (BIP): 12 Dimensionen als Spider/Radar

### App (ARK Insight)
- App-spezifische Analysen (DISC, Führungsstil)
- Antwortzeiten pro Frage + Verteilung (Histogramm)
- Auffälligkeiten: Zu schnell (nicht gelesen?), Zu lange (outzoned? abgelenkt?)

### AI-Analyse
- Cross-Analysis über ALLE Assessment-Typen (6 Module: DISC, Motivatoren, Relief, Outmatch, BIP-6F, EQ)
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
- Alle Analyse-Typen aufstellbar (DISC, Motivatoren, Relief, Outmatch, EQ, Human Needs, BIP)
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
```
Expose → CV Sent → TI → 1st → 2nd → 3rd → Assessment → Offer → Placement
```
- Skip-Stages: Durchgängige Linie, übersprungene Nodes als gestrichelte Hohlringe
- Datum unter jedem Node
- Assessment: **Kein Datum** — wird im Assessment-Tab getrackt

### Debriefing-Dots (zwischen Interview-Stages)
- Kleine Dots auf der Pipeline-Linie zwischen TI↔1st, 1st↔2nd, 2nd↔3rd
- **Lila (📝):** Debriefing vorhanden → Klick öffnet Popover mit Notizen
- **Grau (—):** Kein Debriefing → Klick zeigt "Im History-Tab erfassen"
- Verknüpft mit fact_history Debriefing-Einträgen

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
- Einzelmandat (gold), RPO (teal), Erfolgsbasis (grau)
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
- Post-Placement Check-ins (30/60/90d)
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
Alle 10 Tabs mit Kern-Funktionalität, Dark Mode, Keyboard Navigation, Basic Drawer/Popovers, Error-States, Confirm-Dialoge, Pagination

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
