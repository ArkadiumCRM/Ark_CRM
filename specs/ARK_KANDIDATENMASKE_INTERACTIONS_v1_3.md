# ARK CRM — Kandidatenmaske Interactions Spec v1.3

**Stand:** 14.04.2026
**Status:** Review-Reif (Ergänzung v1.2)
**Kontext:** Definiert Verhalten, Interaktionslogik, CRUD-Flows, Validierung und Speicher-Strategien für alle Tabs der Kandidaten-Detailmaske.
**Ergänzt:** ARK_KANDIDATENMASKE_SCHEMA_v1_3.md (Feld-Inventar + Layout)
**Vorrang:** Stammdaten > dieses Dokument > Schema v1.3 > Mockups
**Vorgänger:** v1.2 (07.04.2026)

## Änderungen v1.2 → v1.3 (14.04.2026)

Ergänzung zu v1.2. Alle bestehenden Patterns (TEIL 0 Globale Patterns, TEIL 1–15 Tab-Interactions) bleiben gültig. Neue Integrations-Logik konzentriert sich auf Cross-Entity-Flows zu den neu erstellten Detailseiten.

### Tab 1 Übersicht — User-Decisions 14.04.2026

| # | Decision | Detail |
|---|----------|--------|
| T1-1 | Source-Badges nur global | Aggregierte Anzeige im Tab-Header (welche Quellen den Datensatz gefüllt haben). Keine per-Sektion-Badges (Lärm-Reduktion). |
| T1-2 | Branchen-Sektion (`dim_sector`) hinzugefügt | Eigene Sektion parallel zu Cluster, Tag-Style **neutral** (kein Gold). |
| T1-3 | EDV gruppiert nach Kategorien | Sichtbare Sektions-Header: AVA/Kalkulation · BIM/CAD · ERP · Office · Projektmanagement. Pro Eintrag: skill_level-Text + Rating. |
| T1-4 | KB-Hints-Bar Pflicht | Konsistent über alle 10 Tabs am unteren Rand. ↑↓ · Enter · E · S · Esc. |
| T1-5 | Functions/Focus-Reihenfolge fix | Sortierung Primary → Rating desc → Name. Kein User-Drag-Reorder (Konsistenz: gleiche Anzeige für alle User). |
| T1-6 | AI-Vorschläge vereinfacht | Globaler Hinweis-Banner + inline Markierung nur bei CV-Parse / Scraper-Funden mit Accept/Reject am Feld. **Keine** AI-berechneten Aussagen wie Seniority-Level oder Profil-Match-% mehr im UI. Confidence-Score nur im Audit-Backend. |
| T1-7 | Personen-Rollen Kandidat | Nur **CM** und **Researcher** (kein „Hunter" als separate Rolle). Je 1 Person zuweisbar. |
| T1-8 | Sparte-Validierung | Mind. 1 aktiv Pflicht. Toast „Mind. eine Sparte muss aktiv bleiben" beim Deaktivierungs-Versuch der letzten. |
| T1-9 | Grade A/B/C Single-Select-Pills | Kunden-Klasse als 3 Toggle-Pills, genau 1 aktiv (Single, nicht Multi). **Farbcodierung: A = grün, B = amber, C = rot.** |
| T1-10 | Briefing-Kurzansicht in Tab 1 | **Nur Gehalts-Bars** (3-Zeilen Aktuell/Schmerzgrenze/Ziel + Marktbenchmark). Alle anderen Briefing-Felder bleiben in Tab 2. Cross-Sync. **Position: zuoberst in der Main-Spalte** (vor Cluster). |
| T1-11 | Pill-Verhalten in Stammdaten-Sektionen | **Nur aktive Pills sichtbar** in: Cluster, Subcluster, Branchen, Functions, Focus, EDV, Sprachen, Ausbildung. „+ Hinzufügen" öffnet Drawer/Autocomplete; Klick auf × an einer Pill entfernt sie. **Keine Toggle-Logik** dort (alle sichtbaren = ausgewählt). Toggle-Pills nur in: Sparte (5 immer sichtbar), Flags (5 immer sichtbar), Grade (3 immer sichtbar). |
| T1-12 | Personalien · Ansprache | Nur Werte „Herr" oder „Frau" (kein angehängter Nachname). |
| T1-13 | CM/Researcher als Dropdowns | Beide als `<select>`-Dropdowns über alle Arkadium-Mitarbeiter. Nicht als rote Pflichtfelder visualisieren (Default ist immer gesetzt = Owner-Team-Mitglied). |
| T1-14 | Sektions-Reihenfolge Sidebar | Personalien · Kontakt · Standort · **Flags / Führungs-Ebene** · Zuordnung · Status &amp; Qualität. (Flags zwischen Standort und Zuordnung statt am Ende.) |
| T1-15 | CM/Researcher rollengefiltert | Dropdown CM zeigt nur Mitarbeiter mit Rolle = Candidate Manager. Dropdown Researcher zeigt nur Researcher. Filter-Hinweis sichtbar (klein, kursiv). |
| T1-16 | „+ Hinzufügen"-Pattern | Inline Autocomplete-Popover: Suchfeld + Vorschläge aus Stammdaten (kontextuell ranked, z.B. „nach Sparte ING") + Footer mit Stammdaten-Hinweis + „+ Neuer Eintrag (Admin)"-Link. Pattern einheitlich für Cluster · Subcluster · Branchen · Functions · Focus · EDV · Sprachen · Ausbildung. |
| T1-17 | Rating 1–10 einheitlich | Alle Sektionen mit Rating verwenden **klickbare Rating-Bar** (10 Punkte) im `<dd>`-Slot. Pill im `<dt>` enthält Name + Text-Label (z.B. skill_level für EDV). Gilt für Functions, Focus, EDV. Sprachen nutzen CEFR-Level statt Rating, Ausbildung kein Rating. |
| T1-18 | Grade-Position | Grade A/B/C als Pills in **Sidebar-Card „Zuordnung"** unter Sparte (nicht in „Status &amp; Qualität"). Logisch verwandt: beide sind Zuordnungs-/Klassifizierungs-Felder. |
| T1-19 | Card-Border-Konvention | **Keine farbigen Border-Lefts** auf Standard-Cards (Flags, Zuordnung, Briefing-Eckdaten). Border-Left ist exklusiv reserviert für Warnungen / Highlights (z.B. Risiken-Card). Konsistenz mit accounts/mandates-Mockup. |
| T1-20 | Cluster-Popover: Katalog fix | Cluster-Stammdaten sind fix (99,99 % unverändert). „+ Neuer Cluster (Admin)"-Option **entfernt**. Popover zeigt nur die pro Sparte verfügbaren Cluster, die **noch nicht zugewiesen** sind. Hinweis im Footer: „Fixer Katalog — alle [Sparte]-Cluster bereits sichtbar" wenn Katalog ausgeschöpft. |
| T1-21 | Focus: Primary / Secondary | Analog Functions: **Primary** (★, genau 1) + **Secondary** (☆, max. 1–2) + aktive Pills (Default). |
| T1-22 | Standort-Reihenfolge | Adresse · PLZ/Ort · **Grossregion** (Dropdown) · **Kanton** (Dropdown, gefiltert auf gewählte Grossregion) · Arbeitsort · Land. Kanton-Filter reduziert Auswahl zu 1–8 Kantonen je Grossregion. |
| T1-23 | Kontakt-Reihenfolge Telefone | E-Mail · E-Mail 2 · **Direkt · Mobil · Privat** (in dieser Reihenfolge) · LinkedIn · Xing. Direkt ist primärer Business-Kanal. |
| T1-24 | Keine DB-Technikdetails in UI | Card-Titel, Subtitel, Tooltips zeigen **keine Tabellen-/Spaltennamen** (`dim_*`, `fact_*`, `_id`, `_fk` etc.). Stattdessen sprechende Begriffe („Katalog", „Stammdaten" allgemein, ohne konkreten Tabellen-Namen). Global gültig (siehe CLAUDE.md „Keine-DB-Technikdetails-im-UI-Regel"). |
| T1-25 | Abgeleitete / Read-only Felder | **Arbeitsort** = aus aktueller Position in Tab 3 Werdegang (Firmen-Standort der jüngsten Station). **Land** = auto aus Adresse/PLZ (CH-PLZ-Range → Schweiz, AT/DE analog). **Owner Team** = auto aus Sparte (Stammdaten §10: ING/GT → Team ING & BT; ARC/REM → Team ARC & REM; PUR → Mandat-abhängig). Alle drei Felder sind **read-only** mit kursivem Herkunfts-Hinweis („· auto aus …"). Keine manuelle Eingabe. |
| T1-26 | Dropdown-Verhalten Read/Edit | Dropdowns in Detailmasken (z.B. Grossregion/Kanton in Standort) sind im **Read-Mode als Text** sichtbar (via `data-edit-from` + `<template>`). Erst nach Klick auf „Bearbeiten" werden sie zu `<select>`-Controls. Ausnahme: Dropdowns in **Zuordnungs-/Status-Cards** (CM, Researcher) bleiben immer aktiv, da direkt zuweisbar. |

### Tab 2 Briefing — User-Decisions 15.04.2026

| # | Decision | Detail |
|---|----------|--------|
| T2-1 | Zwei Modi · Mode-Switch oben | **🎙 Gesprächsleitfaden · Live-Call** (führt CM während Briefing-Gespräch Frage-für-Frage durch · Leitfaden-Fortschritt 1/10 sichtbar) und **📋 Ausgefüllte Maske · Review &amp; Nachbessern** (AI-gefüllt aus Call-Transkript, CM reviewt). CM muss **nie von 0** ausfüllen. |
| T2-2 | Wechselmotivations-Farben | Stufe 1–3 = **grün** · 4–5 = **gelb/amber** · 6–8 = **rot** (anstatt der per-Stufe-individuellen Farben). Synced mit Header-Badge. |
| T2-3 | Flugreisen-Feld gestrichen | Aus Sektion 3 Mobilität entfernt — nie definiert gewesen. |
| T2-4 | Alle Briefing-Textfelder editierbar | Keine `disabled`-Attribute auf Textareas. Gilt insb. für Sektion 5 „Weitere Skills", Sektion 6 „Triggerpunkt" und „Moderation / Coaching-Bedarf". |
| T2-5 | Zonen-Modell mit 4 Textareas | Neben 4-Zonen-Bar für jede Zone (Komfort/Lern/Wachstum/Angst) eine eigene Textarea zur Beschreibung. Sweet Spot markiert in Wachstums-Zone. |
| T2-6 | Projekt-Edit-Buttons funktional | ✎-Button an verknüpften Projekten öffnet `projektDrawer` (540 px, BKP-Gewerke · SIA-Phasen · Rolle · Verantwortungsgrad · Kommentar). ✕-Button: Confirm + Entfernen. Klick auf Row öffnet ebenfalls Drawer. |
| T2-7 | „+ Projekt verknüpfen" Demo sichtbar | Autocomplete-Popover inline in Sektion 10 immer sichtbar (Demo) — zeigt Fuzzy-Match-Schwellen ≥ 85 % Auto · 60–84 % Auswahl · &lt; 60 % „Neues Projekt". Ranking nach Bauherr/Zeitraum-Match. |
| T2-8 | Grade A/B/C = Cross-Sync | Grade-Feld in Sektion 4 Bewertung und in Tab 1 Zuordnung sind **dasselbe Feld**. Änderung an einer Stelle reflektiert sofort an anderer Stelle. UI zeigt „synced"-Hinweis. Beide Stellen als „Grade" benannt (vorher teilweise „Bewertung"). |
| T2-9 | Gesprächsleitfaden · 10 Schritte (neue Reihenfolge) | Reihenfolge orientiert sich am natürlichen Gesprächsfluss: **1** Werdegang Stationen · **2** Werdegang Learnings & Entwicklung · **3** Aktuelle Rolle Team & Fachgebiete · **4** Aktuelle Rolle Zufriedenheit/Chef/Führung · **5** Zukunftsvision · **6** Fachkompetenz Stärken · **7** Fachkompetenz Lücken & Lernwünsche · **8** Projekte Beteiligung & Daten · **9** Projekte Herausforderungen & Stakeholders · **10** Eckdaten (Gehalt/Verfügbarkeit/Mobilität/Bewertung zuletzt). Jeder Schritt: Frage für Kandidat · Hinweise für CM · Feld-Mapping · Live-Notizen. **Alle 10 Schritte einzeln anklickbar** im Fortschritts-Panel rechts — Sprünge jederzeit möglich (Leitfaden ist grob, Themen können ineinander schmelzen). Farb-Markierung: ✓ grün (abgeschlossen) · ▶ accent (aktuell) · grau (offen). |
| T2-10 | Zonen-Modell · kategorisch statt numerisch | **Zonen-Bar** (Komfort grün · Lern gold · Wachstum amber · Angst rot) ist reine **visuelle Illustration / Legende** — kein Slider, kein %-Wert (Sweet Spot ist Gefühlssache, nicht numerisch messbar). **Sweet Spot** erfasst via **Single-Select-Pill** (`[Komfort] [Lern] [Wachstum] [Angst]` · genau 1 aktiv) über den 4 beschreibenden Textareas. Aktive Pill in Zonen-Farbe. Backend-Feld: `sweet_spot_zone` ENUM (`komfort`/`lern`/`wachstum`/`angst`). Default-Vorschlag bei neuem Briefing: Wachstum. |
| T2-11 | Gesprächseinstieg als Schritt 1 | Gesprächsleitfaden startet mit Rapport-Aufbau: Ziel des Kandidaten, Gründe für die Zusage, Erwartungen, Überblick über Ablauf/Themen/Vertraulichkeit. Werdegang (Stationen + Learnings) rutschen auf Schritt 2 (zusammengefasst). Leitfaden bleibt bei 10 Schritten. |
| T2-12 | Sprache · Sie-Form für Kandidat | Alle Fragen im Gesprächsleitfaden und im Briefing-Kontext an den Kandidaten in **Sie-Form**. Interne Hinweise für CM bleiben in Du-Form (Arkadium-interne Kommunikation). |

### Tab 3 Werdegang — Entscheidungen (15.04.2026)

| # | Thema | Entscheidung |
|---|-------|-------------|
| T3-1 | Timeline-Visual | Vertikale Linie mit Dots pro Station (current=grün, done=gold, gap=dashed grey). Jahres-Marker als Pills am Strang zwischen Stationen. |
| T3-2 | Section-Headers | Zwei Karten: **💼 Beruflicher Werdegang** (synced mit Functions/Cluster/Sparte/Sektor in Tab 1) und **🎓 Ausbildung** (synced mit Tab 1 Ausbildung). Icons + Sync-Hinweis rechts neben Titel. |
| T3-3 | Motion-Pills | Pro Station 2 Inline-Pills: **Zugang** (Eintrittsgrund, grün) und **Abgang** (Austrittsgrund, amber bzw. rot bei kritischen Gründen wie „Kündigung AG"). Dropdown-Werte: Zugang (7): Headhunt, Eigeninitiative, Intern-Aufstieg, Intern-Transfer, Netzwerk/Empfehlung, Berufseinstieg, Wiedereinstieg. Abgang (7): Karriereschritt, Kulturfit, Firma verkauft/liquidiert, Kündigung AG, Umzug, Sabbatical/Weiterbildung, Pensionierung. |
| T3-4 | Station-Tags | Pro Beruf-Station farbige Pills: Funktion (fn, accent), Cluster (fc, gold), Sparte (sp, green), Sektor (sec, blue), Region (rg, grau). Ausbildung nur Funktion+Cluster. |
| T3-5 | Gap-Einträge | Bei Zeitlücken >1 Monat automatische Timeline-Einträge (gestrichelte Dot, Streifen-Box). Text „⏸ Lücke · X Monate · Grund"). User kann Lücke als Sabbatical/Weiterbildung/Arbeitslos klassifizieren oder ignorieren. |
| T3-6 | AI-Projekt-Vorschläge | Eigene Karte oben (Gold-Border): LinkedIn-Scraper-Matches mit Match-Score %. Pro Vorschlag: Projekt-Logo, Name, Begründung (Zeitraum/Region/BKP/Sparte), Button „✓ Zuordnen" / „Ignorieren". |
| T3-7 | Projekt-Edit-Drawer | Klick auf Projekt-Row → `werdegangProjektDrawer` (540px). Felder: BKP-Multi-Select (dim_bkp_codes), SIA-Phasen-Multi-Select (dim_sia_phases 6+12), Rolle (dim_functions Projektmanagement/Bauführung/Bauherrenberatung), Verantwortungsgrad (Führend/Mitarbeitend/Beratend), Team-Grösse, Stakeholder/Namedropping, Herausforderungen, Tratsch, Referenz-Eignung, ARK-CV-Sichtbarkeit. |
| T3-8 | Station-Edit-Drawer | Klick auf Station-Card → `stationDrawer`. Felder: Typ (Beruf/Ausbildung/Lücke), Titel, Arbeitgeber (dim_accounts FK), Zeitraum (Monat-Picker), Standort, Zugang/Abgang, Beschreibung, Funktionen/Cluster/Sparte/Sektor/Region (msel), LinkedIn-URL. |
| T3-9 | Projekt-Sync bidirektional | Werdegang-Projekt-FK → `fact_projects`. Änderung BKP/SIA/Rolle im Werdegang-Drawer syncht in `fact_project_candidate_participations` und umgekehrt. Info-Banner im Drawer macht das explizit. |
| T3-10 | Cross-Sync Werdegang → Tab 1 | Functions/Cluster/Sparte/Sektor werden aus allen Stationen aggregiert und in Tab 1 Übersicht read-only gespiegelt (bereits Konvention). Änderung in Station = automatischer Refresh Tab 1. Hinweis-Leiste im Station-Drawer. |
| T3-11 | Ausbildungs-Details | Pro Ausbildungs-Station: Bildungsgrad (CAS/MAS/BSc/MSc/PhD/Lehre/Berufsmatura/Gym), Note Ø, Auszeichnung (Freitext). Bildungsgrad-Enum aus dim_education_level. |
| T3-12 | Employer klickbar | Arbeitgeber-Name ist Link zu Account-Detailseite (falls verknüpft). Kleiner Account-Badge „→" rechts vom Namen. Auch im Drawer als Button „→ Account öffnen". |
| T3-13 | Datepicker | `<input type="month">` für Von/Bis (Monat+Jahr reicht für Werdegang, kein Tag). Checkbox „heute" setzt Bis auf heutigen Monat und macht Feld disabled. |
| T3-14 | Filter-Chips | „Alle · Beruf · Ausbildung · Lücken" mit Counts. Klick filtert die beiden Karten-Sektionen. |
| T3-15 | Stammdaten-Compliance | BKP-Codes aus dim_bkp_codes (425 Einträge), SIA-Phasen aus dim_sia_phases (6 Haupt + 12 Teil, SIA-Norm 112), Rolle aus dim_functions, Sektor aus dim_sector. Keine Freitext-Pills für diese Felder. |
| T3-16 | Keyboard-Nav | Pfeil-Tasten ↑/↓ springen zwischen Station-Cards (Tab-Index gesetzt). Enter öffnet Drawer. Esc schliesst. |

### Tab 4 Assessment — Entscheidungen (15.04.2026)

| # | Thema | Entscheidung |
|---|-------|-------------|
| T4-1 | Version-Navigation | Oberste Zeile: Pfeil-Navigation ‹ / › zwischen Versionen + aktiver Version als Pill „v2 · 15.03.2026 · Auftrag AS-XXXX". Rechts Buttons „Versionen vergleichen" und „Auftrag öffnen". |
| T4-2 | Modul-Status-Strip | Unter Version-Nav horizontale Pills pro Modul (done=grün, pending=amber, missing=grau). Zeigt auf einen Blick welche Assessments bereits erstellt sind. |
| T4-3 | DISC-Wheel | Polarplot SVG mit 4 Quadranten D/I/S/C farbig. Position-Dot Gold markiert Scheelen-Typ (z.B. „Reformer ★25"). In Overview kompakt (neben Bars), in Scheelen-Tab gross mit allen 60 Typen-Segmenten. |
| T4-4 | DISC-Bars | 4 horizontale Bars D/I/S/C mit Score 0–100, Trend-Pfeile ↑/↓ bei Änderung zu Vorversion. Basis-Typ + Stress-Typ als Muted-Zeile unterhalb. |
| T4-5 | EQ 5-Grid | 5 Zellen horizontal: Selbstwahrnehmung · Selbstregulierung · Motivation · Soziale Wahrnehmung · Soziale Regulierung (aus §67a Stammdaten). Jede Zelle mit grosser Zahl + Label + Mini-Bar. Grün bei ≥8, Rot bei ≤6.5. |
| T4-6 | Motivatoren 6 Trias | 6 Zeilen Opposing-Bars mit je 2 Polen (aus §67b): Theoretisch/Praktisch · Ökonomisch/Altruistisch · Ästhetisch/Funktional · Sozial/Individualistisch · Individualistisch/Kooperativ · Traditionell/Progressiv. Bar links accent, rechts gold, Zahl in der Mitte. |
| T4-7 | ASSESS 5.0 | Grosse Haupt-Zahl (z.B. 8.2/10) + Profil-Label + Match-Prozent. Darunter Fit-Gauge-Bars für 5 Dimensionen (Führung / Kommunikation / Entscheidungsstärke / Analytik / Anpassungsfähigkeit). |
| T4-8 | Relief / Stressoren | Halbkreis-Gauge mit Gradient grün→amber→rot + Gesamt-Zahl. Darunter Liste aller 8 Stressoren mit Bars farbcodiert (lo=grün ≤2.5, mid=amber 2.5–3.8, hi=rot >3.8). |
| T4-9 | Human Needs Ringe | SVG mit 6 Segmenten (Sicherheit · Vielfalt · Bedeutung · Verbundenheit · Wachstum · Beitrag) kreisförmig angeordnet. Segment-Füllung 3-stufig nach Ausprägung. In Scheelen-Tab zusätzlich als Bar-Liste mit Zahlen. |
| T4-10 | Driving Forces | Eigene Card mit Top-5 Forces als Fit-Gauge-Bars + Gesamt-Score. |
| T4-11 | AI Cross-Modul-Summary | Gold-Card im Overview und eigener Sub-Tab. Text-Zusammenfassung oben + Stärken/Entwicklungsfelder als Chips. Chip-Title-Attribute zeigen Quellen („DISC · D 78", „EQ Soz. Regul. 6.3"). Hover zeigt Modul-Herkunft. |
| T4-12 | Vergleich-Sub-Tab | 3 Chip-Tabs: Kandidat vs. Jobanforderung · Kandidat vs. Team · Versions-Diff (v1↔v2). Job-Dropdown zum Wechseln. Delta-Tabelle mit Opposing-Bars Kandidat/Anforderung + Δ-Spalte ±. Spider-Overlay als zusätzliche Visualisierung. Gap-Empfehlung in 3-Tier-Boxen (gedeckt/coachen/risiko). |
| T4-13 | Teamrad | Polar-SVG mit 4 DISC-Quadranten, 8–9 Member-Dots + Kandidat als Gold-Star. Team-Fit-Ring Kreisdiagramm mit Prozent-Wert. Member-Tabelle mit Rolle, DISC-Typ, EQ, Gap-Analyse. Optional Bench-Szenario-Button. |
| T4-14 | Versions-Diff | 3. Chip-Tab im Vergleich. Zeigt nebeneinander v1/v2 derselben Person, markiert Deltas ±. |
| T4-15 | Stammdaten-Compliance | DISC 60-Typen aus §67 (Katalog: Reformer, Motivator, Driver, Perfektionist, Supporter, Networker usw.). EQ-Dim-Labels exakt aus §67a. Motivatoren-Pole aus §67b. Human Needs aus Scheelen 6HM. Modul-Namen aus dim_assessment_types §51. |
| T4-16 | Design-Sprache | Verspielte v2-Grafiken (Wheels, Ringe, Gauges, Opposing-Bars) vom TYP übernommen, aber in Editorial-Stil (Navy/Gold/Green statt bunte Gradients, flache SVGs, klare Card-Frames, keine Animationen). |
| T4-17 | Drawer-Interaktion | Klick auf Modul-Card öffnet Detail-Drawer (Phase 2 — aktuell nicht implementiert). Bearbeitung der Assessment-Werte erfolgt primär über Auftrag-Detailseite in assessments.html. |
| T4-18 | Wertebereiche · korrigiert | **Verbindlich aus v2:** DISC 0–100 · Motivatoren 0–100 (nicht 0–10) · Outmatch/ASSESS 5.0 1–10 · Relief 1 (positiv) – 6 (negativ) · Human Needs 0–100 · Driving Forces 0–100 · EQ 0–10 (Skala konsistent halten) · ASSESS-Sub-Dim 1–10. Jede Card zeigt Skala-Hinweis am Footer. |
| T4-19 | Motivatoren · Pol-Namen | Verbindliche Pol-Bezeichnungen aus Scheelen (v2): **Instinktiv ⟷ Intellektuell · Idealistisch ⟷ Effizienz · Objektiv ⟷ Harmonisch · Eigennützig ⟷ Altruistisch · Kooperativ ⟷ Macht · Aufgeschlossen ⟷ Prinzipientreu**. Jede Trias mit eigener Akzentfarbe. Werte als „L ⟷ R" zentral. |
| T4-20 | Relief-Card · Aufbau | 3 Key-Metrics oben (Stressor Total · Resilienz · Energie als grosse Zahl /6) + Burnout-Ampel (3 Punkte grün/amber/rot, aktiver leuchtet) + 8 Stressoren-Bars 2-spaltig (Zeitdruck · Konflikt · Überlastung · Ambiguität · Kontrolle · Isolation · Monotonie · Wertekonflikt). Skala-Footer. |
| T4-21 | Outmatch-Card · Aufbau | Profil-Label oben (z.B. „Gesamtbauleiter Spezialtiefbau") + Ring-Gauge (88×88px) mit Total-Score zentriert + 4 Sub-Dim-Bars (Führung · Kommunikation · Entscheidung · Teamwork) mit Trend-Pfeilen. Skala 1–10 Footer. |
| T4-22 | Empty-State-Cards | MDI/App/Ikigai erhalten eigene Cards mit zentriertem Icon + Beschreibung + CTA-Button. MDI bei „Auftrag offen" mit ETA-Datum + Border-Left amber. App + Ikigai mit Empty-State + „Einladung senden" / „Termin planen". |
| T4-23 | Human Needs · Werte | 6 Bedürfnisse aus Scheelen 6HM verbindlich: Sicherheit · Abwechslung · Bedeutung · Verbindung · Wachstum · Beitrag (nicht „Vielfältigkeit"/„Liebe & Verbindung"). Skala 0–100. Pro Need eigene Akzentfarbe. |
| T4-24 | EQ-Skala | Skala **1–100** (nicht 1–10). Werte einheitlich überall (Overview + Scheelen-Detail). |
| T4-25 | Scheelen-Tab · Motivatoren-Detail | Card mit 6 Wertetrias als 2-Spalten-Grid, jede mit eigener Akzentfarbe-Border-Left, Trias-Name in Caps Libre Baskerville oben + Opposing-Bar + Interpretations-Text (1 Satz). |
| T4-26 | Scheelen-Tab · EQ-Detail | Card mit 5 grossen Score-Tiles (84/72/81/70/63) farbcodiert (≥80 grün, 65–79 accent, ≤64 rot) + Gesamt-Pill in Header + Interpretations-Block unten. |
| T4-27 | Scheelen-Tab · Outmatch-Detail + BIP-6F Subdims | Outmatch-Detail mit allen 8 Kompetenzen (statt nur 4 in Overview): Führung · Kommunikation · Entscheidung · Teamwork · Problemlösung · Stressresistenz · Kundenorientierung · Innovation. BIP-6F Validierungspunkte als 6 Cards mit je 2–3 Subdim-Opposing-Bars (15 Polaritäten total), Border-Left in Hauptdim-Farbe. |
| T4-28 | **Tab 4 ist READ-ONLY** | Kandidaten-Tab 4 ist **ausschliesslich Visualisierung**. Jede Eingabe / Werte-Erfassung / Versionierung erfolgt über die Auftrags-Detailseite (`assessments.html`). Begründung: jede Analyse ist an einen Auftrag gebunden (Billing, Owner, Deadline, Versionierung, Multi-Kandidaten-Aufträge). Single Source of Truth = `fact_assessment_order` + `fact_candidate_assessment_version`. |
| T4-29 | Action-Buttons Tab 4 | Alle Action-CTAs routen zu `assessments.html` mit vorausgewähltem Kandidaten + ggf. Modul-Typ: **„+ Neuer Auftrag"** (Header-Banner) · **„🤖 AI-Analyse beauftragen"** (Filter-Bar) · **„→ Aktiven Auftrag öffnen"** (Version-Nav) · Empty-State-CTAs („+ Auftrag anlegen") für MDI/App/Ikigai · MDI-Pending: „→ Auftrag AS-XXXX öffnen". Keine Inline-Edit-Buttons in Tab 4. |
| T4-30 | Read-only-Banner | Persistenter Hinweis-Banner oben in Tab 4: 🔒 „Read-only · Visualisierung. Bearbeitung &amp; Werte-Erfassung erfolgt im jeweiligen Auftrag." mit Primary-CTA „+ Neuer Auftrag" rechts. Visuell als Accent-Soft-Box mit Border-Left in `var(--accent)`. |
| T4-31 | Edge-Case extern eingebrachte Reports | Wenn Kandidat ein bereits vorhandenes Assessment (z.B. MDI von 2020) einbringt: ein Auftrag vom Typ **„Extern eingebracht"** mit Kosten 0 wird trotzdem in `fact_assessment_order` angelegt. Werte werden via Upload (PDF) + manuelle Erfassung oder OCR im Auftrag gepflegt. Kein direkter Eintrag in Kandidaten-Maske ohne Auftrag. |

### Tab 5 Jobbasket — Entscheidungen (15.04.2026)

| # | Thema | Entscheidung |
|---|-------|-------------|
| T5-1 | Stages | 7 Stufen: Prelead (0) → Oral GO (1) → Written GO (2) → Assigned (3) → To Send (4) → Sent (5) · Rejected (-1). Stage-Pills farbcodiert konsistent mit Pipeline-Chips. |
| T5-2 | Schutzfrist-Banner (v1.3) | Persistent oben im Tab falls Schutzfrist aktiv: 🛡 „Schutzfrist aktiv bis DD.MM.YYYY · Account X · Prozess Y · 16 Mt Periode". AI-Matching blockiert entsprechende Jobs automatisch („✗ Blockiert"-Button statt „+ In Basket"). |
| T5-3 | AI-Matching-Card | Top-4 Vorschläge als Grid. Pro Vorschlag: Logo + Titel + Account + Match-% (Libre Baskerville, gold bei ≥ 85, accent bei 70–84, grau darunter) + Begründung (Region/DISC/TC-Fit/BKP) + Button. Bei Schutzfrist: disabled + Shield-Icon. |
| T5-4 | Pipeline-Chips | 7 Chips (Alle + 6 Stages + Rejected) mit Counts. Klickbar als Filter. Aktiver Chip mit Accent-Soft-Hintergrund. |
| T5-5 | Job-Card-Layout | Top-Row: Logo + Titel + Account + Mandate-Flag (Target/Taskforce/Time/Einzelmandat) · Meta-Zeile (Owner/Region/TC-Range/Datum) · Stage-Pill · Ablehnen-✕ · Collapse-›. Body collapsible: SVG-Timeline + stage-spezifischer Box (Gate/Ghosting/Proc-Link/Rejection). |
| T5-6 | SVG-Timeline pro Card | 5 Hauptstationen (Prelead · Oral GO · Written · Assigned · Sent). Dots: done=grün, active=gold mit Pulse-Animation, blocked=rot mit Blink-Animation, future=grau dashed. Labels oben, Dates unten (Daten pro abgeschlossener Stage sichtbar). |
| T5-7 | Gate 1 (Stage 2 → 3) | 4 Doc-Checks: Schriftl. GO · Original CV · Diplom · Arbeitszeugnis. Rot-Box bei Missing. Action-Row mit „→ Dokumente-Tab öffnen" + „✉ Kandidat anfragen". Nicht hart-blockierend. |
| T5-8 | Gate 2 (Stage 3/4 → 5) | 3 Doc-Checks: ARK-CV · Abstract · Exposé (optional). Zwei separate Versand-Buttons: „📄 CV versenden" (needs ARK-CV + Abstract) und „🔒 Exposé versenden (anonym)" (needs Exposé). Gold-Border-Box. |
| T5-9 | Ghosting-Hinweis | Stage Oral GO: wenn keine Antwort > 7 Tage: amber Warn-Box „⏳ Keine Antwort seit X Tagen · Deadline DD.MM.YYYY · blockiert Written GO". Action „🔔 Reminder senden". |
| T5-10 | Prozess-Link (Stage Sent) | Grüne Box „→ Prozess eröffnet: P-YYYY-XXX · Stage V · nächstes Event DD.MM.YYYY" mit Primary-Button „→ Prozess" zu processes.html. |
| T5-11 | Rejection-Detail | Stage -1: rote Box mit Head „✕ Ablehnung · Stage X · DD.MM.YYYY · durch User" + Grund (Dropdown-Wert) + Beschreibung (Freitext). Card-Opacity reduziert auf 0.75. |
| T5-12 | Keyboard-Shortcuts | ↑/↓ Card-Nav · Enter Card aufklappen · S Fokus Suchfeld · Esc Filter aufheben. Hint-Bar unter Pipeline-Chips. |
| T5-13 | Kanban D&D (Phase 2) | Drag & Drop zwischen Pipeline-Chips nicht in v1.3. Geplant für Phase 2 als zusätzliche View neben Card-View. |
| T5-14 | **Versand-Flow CV / Exposé** | **Variante A (neuer Kunde):** zuerst **Exposé anonymisiert** → bei Kunden-Interesse **dann CV**. **Variante B (bekannter Kunde):** direkt CV-Versand. **Nach CV-Versand ist kein Exposé mehr nötig.** Beide Varianten enden in Stage „Sent" — Differenz nur Fork-Pfad (Exposé-Node alleine, CV-Node alleine, oder beide). |
| T5-15 | **Kein Versand aus Kandidaten-Maske** | Buttons „CV versenden" / „Exposé versenden" sind **nicht im Jobbasket-Tab**. Zentraler Versand erfolgt via **Dashboard · To-Send-Inbox** (eine Liste aller Kandidaten-Job-Kombinationen in Stage „To Send" über alle Kandidaten hinweg). AM kann dort bulk versenden. Kandidaten-Maske zeigt nur Status. |
| T5-16 | **Live-Stage-Transitions** | Stages werden **live** weitergeschaltet (event-driven, **kein Sync-Lauf**) sobald Bedingungen erfüllt: Prelead→Oral GO nach Email-Trigger + Empfang · Oral GO→Written GO nach schriftlichem GO · Written GO→Assigned nach Gate 1 (alle 4 Docs) · Assigned→To Send nach Gate 2 (CV+Abstract oder Exposé) · To Send→Sent nach Dashboard-Versand. **Keine manuellen „Auf X setzen"-Buttons**. Jedes Event (Doc-Upload, Email-Empfang, Versand) löst sofort die Transition aus, UI refreshed via Subscription/SSE. |
| T5-17 | **Oral GO = warten auf schriftliches GO** | In Stage „Oral GO" wartet das System auf die **schriftliche Bestätigung** (Email/Chat vom Kandidaten). Das mündliche GO wurde bereits im GO-Termin besprochen — deshalb die Stage-Bezeichnung. Ghosting-Hinweis nach 7 Tagen ohne schriftliche Antwort. |
| T5-18 | **Rejected ↔ History-Kopplung** | Eine Stage-Rejection wird **ausschliesslich über einen History-Eintrag** erzeugt, nicht direkt im Basket. Flow: User erstellt History-Eintrag (z.B. „Absage nach GO-Termin") → verknüpft Prozess/Job → wählt Grund aus stage-spezifischem Katalog → System setzt Job automatisch auf `stage=-1` mit `rejAt=<aktuelle Stage>` + verlinkt History-ID in `jb-reject-box`. Direkt-Rejection im Basket (✕-Icon) öffnet einen Quick-History-Drawer. |
| T5-19 | **Absagegrund-Katalog · stage-sensitiv** | Gründe variieren nach Stage, da manche Parteien erst später Sichtbarkeit haben: **Prelead:** Kandidat nicht erreichbar · Kandidat abgelehnt aus Distanz · ARK-intern (Dupl./Priorität) · **Oral GO:** Kandidat nach Termin abgesagt · Kulturfit · TC-Mismatch · ARK-intern · **Written GO:** Kandidat zieht zurück · TC-Erwartung nicht erfüllbar · ARK-intern (bessere Alternative) · **Assigned:** alle vorigen + Gate-1-Doc dauerhaft fehlend · **To Send / Sent:** alle vorigen + **Account lehnt ab** (erst ab hier sichtbar, weil CV/Exposé beim Account) · Kunde hat bereits entschieden. |
| T5-20 | **Kein „Weiterstellen"-Button** | Aus T5-16: Card-Body zeigt bei fertigen Gates einen Info-Hinweis „Live-Weiterstellung auf X sobald …" statt Button. Transition erfolgt sofort beim Event (kein Sync-Lauf). Badge „Ready" / „Bereit" signalisiert Zustand. |
| T5-21 | **Job-Suche live & funktional** | Input-Feld triggert `jbSearch(query)` (min. 2 Zeichen). Filter-Pills (Alle/Accounts/Jobs) steuern Trefferart. Ergebnisse gruppiert: Accounts (+ eingerückte Jobs des Accounts) und Jobs (Einzeltreffer bei Titel-Match ohne Account-Match). Default: Empty-State mit Hinweis. |
| T5-22 | **AI-Matching default collapsed** | AI-Vorschlags-Card ist **collapsed by default** — Job-Suche ist der primäre Flow. User klappt AI-Match aktiv auf bei Bedarf. |

| # | Änderung | TEIL |
|---|----------|------|
| 1 | **Tab 2 Briefing — Projekt-Autocomplete-Flow:** Fuzzy-Match + Hybrid-Flow (≥85% Auto, 60-84% Review, <60% "Neues Projekt anlegen") | TEIL 2 (Briefing) § Projekte |
| 2 | **Tab 3 Werdegang — Projekt-Verknüpfung:** Inline-Drawer für BKP/SIA/Rolle pro Projekt, Auto-Insert in `fact_project_candidate_participations` | TEIL 3 (Werdegang) |
| 3 | **Tab 4 Assessment — Versionierung:** Pfeil-Navigation via `fact_candidate_assessment_version`, Link zur Assessment-Detailseite | TEIL 4 (Assessment) |
| 4 | **Tab 5 Jobbasket — Schutzfrist-Check:** Vor Prelead-Creation Schutzfrist-Query, Info-Badge ohne Block | TEIL 6 (Jobbasket) |
| 5 | **Tab 6 Prozesse — Drawer-Interaktion:** Slide-in-Drawer 540px statt Direkt-Navigation (konsistent mit Prozess-Mischform) | TEIL 7 (Prozesse) |
| 6 | **Tab 7 History — neue Event-Typen:** Schutzfrist, Assessment, Referral-Events integriert | TEIL 8 (History) |
| 7 | **Tab 10 Reminders — neue Auto-Typen:** Assessment-Coaching/Debriefing, Schutzfrist-Info-Request-Tracking | TEIL 11 (Reminders) |
| 8 | **Event-Scope-Registry:** Kandidaten-Events aus v2.5 konsistent integriert (candidate_presented_*, assessment_*, protection_window_*) | alle Tabs |
| 9 | **Sprachstandard:** `candidate_id` konsistent | alle Tabs |

## Kern-Flows v1.3

### Projekt-Autocomplete-Flow (Tab 2 Briefing, neu)

```
User gibt Projekt-Name ein (z.B. "Kalkbreite")
  ↓
Debounce 300ms → GET /api/v1/projects/search?q=Kalkbreite&similarity=fuzzy
  ↓
Response: [
  { id, name, bauherr, from, to, similarity: 0.92 },
  { id, name, ..., similarity: 0.67 },
  ...
]
  ↓
IF top_similarity >= 0.85:
  Show single auto-suggestion card (Preview mit Bauherr, Zeitraum, Volumen)
  → User klickt "Verknüpfen" → POST /api/v1/candidates/:id/briefing/project-link
     Body: { project_id, werdegang_station_id }
     → Backend: Insert fact_project_candidate_participations + Update fact_candidate_werdegang.project_id
     → Event: project_candidate_linked (scope: Kandidat + Projekt)

ELIF top_similarity >= 0.60:
  Show dropdown with top 3 + "Neues Projekt anlegen"

ELSE:
  Show "Neues Projekt anlegen" Mini-Drawer
  → Pflichtfelder: project_name, bauherr_account_id, from_year, to_year
  → POST /api/v1/projects (mit source='candidate_werdegang', source_ref_id=candidate_id)
  → Anschließend Verknüpfung wie oben
```

### Werdegang-Station Projekt-Drawer (Tab 3)

Inline-Drawer bei Klick auf Projekt-Row einer Werdegang-Station:
- BKP-Gewerk-Multi-Select (aus `dim_bkp_codes`)
- SIA-Phasen Multi-Select (aus `dim_sia_phases`, Haupt-Phasen primär)
- Rolle (Freitext oder Dropdown: Projektleiter/Bauleiter/Planer/Polier/...)
- Zeitraum (falls abweichend von Arbeitsstation)
- Verantwortungsgrad: Führend / Mitarbeitend / Beratend
- Kommentar (Arkadium-intern)

Save → Update `fact_project_candidate_participations`. Event `candidate_participation_changed` am Projekt + Kandidaten.

### Assessment-Versionierung-Navigation (Tab 4)

Pfeil-Navigation in jedem Sub-Tab (DISC, EQ, Scheelen 6HM, ASSESS 5.0, Driving Forces, Human Needs, Ikigai, AI-Analyse, Teamrad):

```
API: GET /api/v1/candidates/:id/assessment-versions?type=mdi&q=&account=&date_from=&date_to=
Response: [
  { version_id, version_number, version_date, order_id, order_account_name, package_name, executive_summary_doc_id, ... },
  ...
]
```

UI:
```
◀ Version 2 von 3 ▶   [▼ alle Versionen · 🔍 Filter]
via Auftrag AS-2026-042 (Volare Group AG)
Durchgeführt: 05.03.2026 durch SCHEELEN®
[→ Zum Assessment-Auftrag]
```

Navigation ändert nur `selected_version_id` (Client-State), Tab-Content lädt Daten aus der gewählten Version.

#### Filter/Suche nach Auftrag (v1.3, P2-Erweiterung)

Neben der Pfeil-Navigation gibt es **Dropdown + Suche** für Szenarien mit mehreren Versionen pro Typ aus unterschiedlichen Aufträgen (Multi-Auftrag-Re-Assessment). Trigger: Klick auf Pill "▼ alle Versionen".

**Dropdown-Inhalt (sortiert desc nach `version_date`):**

```
┌──────────────────────────────────────────────────────────────────┐
│ 🔍 [Suche: Auftrag, Package, Account …]                           │
│ [alle Aufträge ▼]  [letzte 12 Mt ▼]                              │
├──────────────────────────────────────────────────────────────────┤
│ ● v3 · 05.03.2026 — AS-2026-042 · Volare Group AG                │
│     Package: "Führungs-Check 2026-Q1"                              │
│                                                                    │
│ ○ v2 · 12.09.2025 — AS-2025-198 · Implenia AG                     │
│     Package: "Leadership Re-Assessment"                            │
│                                                                    │
│ ○ v1 · 04.02.2024 — AS-2024-017 · Volare Group AG                 │
│     Package: "Hiring-Assessment CFO"                               │
└──────────────────────────────────────────────────────────────────┘
```

**Filter-Optionen:**

| Filter | Typ | Verhalten |
|--------|-----|-----------|
| **Volltext-Suche** | Text-Input | Client-seitig auf `order_id` + `order_account_name` + `package_name` (Fuzzy-Match) |
| **Account-Chip** | Multi-Select-Dropdown | Nur Versionen aus Aufträgen dieses/dieser Account(s). Liste aus `DISTINCT order_account_name` der aktuellen Versions-Liste |
| **Zeitraum-Chip** | Pill-Dropdown (`Alle` / `Letzte 12 Monate` / `2024` / `2025` / `2026` / `Custom`) | Filtert auf `version_date` |

**Zusätzlich im Header-Bar der Sub-Tab-Seite (neben Pfeil-Nav):**
- Badge `[3 Versionen · 2 Aufträge · 2 Accounts]` als Kurz-Übersicht der Multi-Auftrag-Konstellation, Klick öffnet Dropdown
- Bei nur 1 Version/Auftrag: Dropdown ausgeblendet, Badge stattdessen einfache Info `[1 Version]`

**Keyboard-Shortcuts:**
- `←` / `→`: Pfeil-Nav (bestehend)
- `V`: öffnet Versions-Dropdown
- `Esc`: schliesst Dropdown

**Server-seitig:** Query-Params an bestehende API (`q`, `account`, `date_from`, `date_to`) — keine neue Endpoint. Dropdown rendert Result-Liste clientseitig.

### Schutzfrist-Check im Jobbasket (Tab 5)

Beim Hinzufügen eines Kandidaten zu einem Jobbasket-Eintrag (Prelead-Creation):

```
Query: SELECT * FROM fact_protection_window pw
       JOIN fact_candidate_presentation cp ON cp.id = pw.presentation_id
       WHERE cp.candidate_id = :candidate_id
         AND pw.status = 'active'
         AND (pw.account_id = :job_account_id
              OR pw.group_id = :job_account.group_id)
```

Bei Treffer → Info-Badge in Prelead-Card:
```
🛡 Schutzfrist aktiv bis 12.04.2027
(Kandidat wurde bereits bei diesem Account vorgestellt)
```

Nicht blockierend — AM sieht Info und weiß, dass Honoraranspruch bestände.

### Prozess-Drawer-Interaktion (Tab 6)

```
Klick auf Prozess-Row in Tabelle
  ↓
Slide-in-Drawer öffnet rechts (540px, von rechts, Overlay mit blur)
  ↓
Drawer-Content:
  - Kandidat-Mini-Card (Foto, Name, aktuelle Funktion)
  - Pipeline-Visualisierung (9 Stages kompakt)
  - Stage-Dropdown + Status-Dropdown
  - Nächstes Interview: Datum + Typ
  - Letzte 3 History-Einträge
  - Quick-Actions: [Ablehnen] [On Hold] [Platzieren] [Interview setzen]
  - "→ Vollansicht öffnen" (Link zu /processes/[id] in neuem Tab)
```

Escape / Overlay-Klick / X-Button → Drawer schließt.

### Event-Typen im Kandidaten-History

Die v1.2-Event-Filter (11 Kategorien) werden erweitert:

| Filter-Kategorie | Event-Typen |
|------------------|-------------|
| Kontaktberührung | call_made, email_sent, meeting_held, ... (v1.2) |
| Erreicht | reached_by_phone, reached_by_email, ... (v1.2) |
| ... | ... (v1.2 Kategorien bleiben) |
| **Schutzfrist-Events** *(NEU v1.3)* | candidate_presented_email, candidate_presented_verbal, protection_window_opened, protection_window_extended, protection_violation_detected |
| **Assessment-Events** *(NEU v1.3)* | assessment_credit_assigned, assessment_credit_reassigned_away/to, assessment_run_scheduled, assessment_run_completed, assessment_version_created |
| **Referral-Events** *(NEU v1.3, wenn Kandidat Empfehler war)* | referral_payout_triggered, referral_payout_paid |
| **Projekt-Events** *(NEU v1.3)* | project_candidate_linked, candidate_participation_added/changed/removed |

Filter-State im URL persistiert. Counts 0 = disabled.

### Reminder-Integration (Tab 10)

Neue Auto-Reminder-Trigger (zusätzlich zu v1.2):

| Reminder-Typ | Trigger | Template |
|--------------|---------|----------|
| `assessment_termin_vorbereiten` | `scheduled_at - 3d` | "Assessment-Termin [Typ] mit [Kandidat] vorbereiten" |
| `assessment_coaching_call` | `scheduled_at - 2d` | Analog Interview-Coaching |
| `assessment_debriefing_call` | `scheduled_at` (Abend) | Analog Interview-Debriefing |
| `schutzfrist_info_request_countdown` | `info_requested_at` + daily | "Info-Request läuft — noch X Tage bis Auto-Extension" |

### Berechtigungs-Ergänzungen v1.3

Keine neuen RBAC-Regeln für Kandidaten-Detailseite selbst. Aber kontextuelle Links:
- Link zu `/projects/[id]` → RBAC der Projekt-Detailseite (Fremd-AM-View mit eingeschränkten Sektionen)
- Link zu `/assessments/[id]` → RBAC der Assessment-Detailseite (CM sieht Tab 1+2+5, Preise maskiert)
- Link zu Schutzfrist-Fenster → RBAC der Account-Tab 9 (AM-Owner kann Claim stellen)

---

# Original v1.2 Content (unverändert)

**Changelog v1.1 → v1.2:** Tabs 5–10 (Jobbasket, Prozesse, History, Dokumente, Dok-Generator, Reminders) vollständig spezifiziert und an die richtige Stelle im Dokument einsortiert. TEILE durchnummeriert (TEIL 6–11 = Tabs 5–10, TEIL 12 = Projekt-Datenmodell, TEIL 13 = Stammdaten-Tabellen, TEIL 14 = Vormerkliste, TEIL 15 = Offene Punkte). Vormerklisten zusammengeführt. Offene Punkte um Tabs 5–10 bereinigt.
**Changelog v1.0 → v1.1:** Assessment-Subtabs AI-Analyse (Teil 5d), Vergleich (Teil 5e) und Teamrad (Teil 5f) vollständig spezifiziert. Teamrad-Architektur: Primär im Account, Embed beim Kandidaten.

## TEIL 0: GLOBALE PATTERNS (gelten überall)

### Pattern 1: Inline-Edit
**Entscheidung:** Hybrid (Option D)
- **Quick-Edit Felder** (einfache Einzelfelder wie Telefon, Email, Toggles): Klick auf den angezeigten Wert → Input erscheint → Blur/Enter speichert → ESC verwirft
- **Komplexe Sektionen** (Briefing-Sektionen, Gehalt-Block, Persönlichkeit): Sektions-Edit-Button → alle Felder der Sektion werden editierbar → "Speichern"/"Abbrechen" Buttons

### Pattern 2: Tag-CRUD
**Entscheidung:** Hybrid Hinzufügen + X-auf-Hover Entfernen
- **Hinzufügen einfache Tags** (Sprachen, EDV, Cluster, Sector): Inline Autocomplete → "+"-Pill am Ende der Tag-Liste → Input → Vorschläge → Auswahl → sofort gespeichert
- **Hinzufügen komplexe Tags** (Functions, Focus): Drawer (540px) mit Suchfeld, Mehrfachauswahl, Rating, Primary/Secondary Toggles → "Übernehmen"
- **Entfernen:** X-Button erscheint auf Hover → Klick → Tag sofort entfernt → Undo-Toast (6s mit "Rückgängig"-Button)

### Pattern 3: Dropdowns
**Entscheidung:** shadcn/ui Custom (Option B)
- Unter ~7 Optionen: Einfaches Select (nicht suchbar)
- Ab ~7 Optionen: Combobox mit Suchfeld
- **Clearable:** Ja, bei optionalen Feldern (kleines X um Wert zu löschen)
- Pflichtfelder sind nicht clearable

### Pattern 4: Drawer
**Entscheidung:** Hintergrund gesperrt + Confirm bei Dirty State (Option A + Y)
- 540px breit, von rechts, Overlay mit Blur
- Hintergrund gesperrt — kein Klicken möglich während Drawer offen
- Schliessen: X-Button, Escape, Klick auf Overlay
- **Bei ungespeicherten Änderungen:** Confirm-Dialog "Ungespeicherte Änderungen. Verwerfen / Speichern / Abbrechen"

### Pattern 5: Speicher-Strategie
**Entscheidung:** Autosave für Quick-Edits, Section-based Save für Komplexes (Option D)
- **Quick-Edit Felder:** Sofort gespeichert bei Blur/Enter (Autosave)
- **Komplexe Sektionen:** Expliziter "Speichern"-Button pro Sektion
- **Drawer:** Immer expliziter "Speichern"-Button
- Dirty-State wird visuell angezeigt (gold ● oder ähnlich)

### Pattern 6: Navigation Guard
**Entscheidung:** Dirty-State bleibt bei Tab-Wechsel, Warnung nur bei Weg-Navigation (Option B)
- Tab-Wechsel innerhalb Kandidatenmaske: Kein Dialog, Dirty-State bleibt im Speicher erhalten
- Navigation weg vom Kandidaten (anderer Kandidat, anderes Modul, Browser-Back): Warn-Dialog "Ungespeicherte Änderungen"

### Pattern 7: Optimistic Updates
**Entscheidung:** Differenziert nach Risiko (Option C)
- **Optimistic:** Quick-Edits (Telefon ändern, Tag hinzufügen, Notiz bearbeiten) — UI zeigt sofort neuen Wert, Rollback bei Fehler
- **Pessimistic:** Geschäftskritische Aktionen (Stage-Änderung, Prozess erstellen, CV-Versand, Briefing-Sektion speichern, Dokument löschen) — UI wartet auf Server-Bestätigung

### Pattern 8: Toast-Feedback
**Entscheidung:** 3-Level-System (Option C)
- **Success (grün):** Auto-dismiss 3 Sekunden. Für: Sektion gespeichert, Reminder erstellt
- **Warning (amber):** Auto-dismiss 6 Sekunden. Für: Speichern erfolgreich mit Hinweis, Version Conflict
- **Error (rot):** Bleibt stehen bis User schliesst (kein Auto-dismiss). Für: Speichern fehlgeschlagen, Session abgelaufen
- **Undo (grün mit Action-Button):** Auto-dismiss 6 Sekunden. Für: Tag entfernt, Kontaktdaten gelöscht — mit [Rückgängig]-Button
- Position: Unten-mitte, max 3 gleichzeitig, älteste wird verdrängt

### Pattern 9: Confirm-Dialoge
**Entscheidung:** Destruktiv + geschäftskritisch (Option B)
- **Confirm bei:** Kandidat archivieren, Dokument/Station/Briefing/Reminder löschen, Prozess abbrechen/rejecten, Stage-Änderung, CV-/Exposé-Versand, Email-Versand, "Mündliche GOs versenden", "Schriftliche GOs versenden", Prozess erstellen
- **Design:** Modal mit Backdrop-Blur, zentriert. Action-Button wiederholt Aktion als Text ("Ja, archivieren"), nie nur "OK"
- **Phase 1.5/2 vorgemerkt:** Kontextabhängige Konsequenzen-Texte (Option C) — Dialog zeigt was genau passieren wird

### Pattern 10: Listen-Strategie
**Entscheidung:** Differenziert nach Kontext (Option D)
- **Load All:** Werdegang, Dokumente, Reminders, Jobbasket, Prozesse (typisch <30 Einträge pro Kandidat)
- **Infinite Scroll:** History (kann hunderte Einträge haben) — mit TanStack Virtual für Performance
- **Pagination:** Nur in der Kandidatenliste (tausende), nicht in der Detailmaske

### Pattern 11: Datepicker (global)
Jeder Datepicker bietet zwei Eingabewege:
- **Kalender:** Klick auf Kalender-Icon → visueller Kalender → Datum auswählen
- **Manuelle Eingabe:** Direkt ins Feld tippen im Format dd.MM.yyyy → Validierung bei Blur

---

## TEIL 1: HEADER

### Avatar
- 120px, rund, Fallback Initialen in Teal
- **Upload:** Gold "+" Button → Datei-Dialog → Crop-Modal (kreisförmig, zoom/verschiebbar) → Upload. Auch Drag-and-Drop auf Avatar möglich → Crop-Modal
- **Klick auf Avatar:** Öffnet ARK CV (wenn vorhanden) → Fallback Original CV → Fallback Foto-Grossansicht

### Stage-Änderung
- **Dropdown mit Kontext + ungültige Stages ausgegraut (Option C)**
- Jeder Stage zeigt Hinweis was der Wechsel bewirkt
- Nicht erreichbare Stages ausgegraut mit Erklärung warum (fehlende Vorbedingungen)
- Confirm-Dialog bei Auswahl (geschäftskritisch)

### Quick Actions

**📞 Anrufen (Click-to-Call):**
- Klick → Nummern-Popover (Option B) mit allen verfügbaren Nummern
- Klick auf Nummer → 3CX triggert Anruf
- Auch bei nur einer Nummer: Popover als Bestätigungsschritt

**✉ Email:**
- **Phase 1:** Popover mit "📧 Neue Email (CRM)" + "📨 In Outlook öffnen" (Option C)
- **Phase 1.5/2 vorgemerkt:** Vollständiger CRM-interner Email-Composer mit individuellem Absender pro Mitarbeiter (pw@arkadium.ch, sp@arkadium.ch etc.)

**🔔 Reminder:**
- Quick-Popover mit Minimalfeldern (Text, Datum, Priorität) + Link "Erweitert →" → voller Drawer (Option C)

### Temperature + Wechselmotivation Badges
- **Temperature:** Nicht klickbar. Automatisch berechnet (siehe Temperature-Modell unten)
- **Wechselmotivation:** Klickbar → Popover mit 8-Stufen-Selektor → sofort gespeichert, synced mit Briefing

### Temperature-Modell (Auto-only, keine manuelle Überschreibung)

**Schicht 1: Hard-Rules (überschreiben alles)**

| Regel | Bedingung | Erzwingt | Verfall |
|---|---|---|---|
| HR-1 | Placement <6 Monate | 🔵 Cold | Automatisch nach 6 Monaten |
| HR-2 | NIC <60 Tage | 🔵 Cold | Automatisch nach 60 Tagen |
| HR-3 | DO-NOT-CONTACT aktiv | 🔵 Cold | Manuell entfernen |
| HR-4 | Ghosting (2+ ohne Antwort) | 🔵 Cold | 60 Tage ODER aktives Signal |
| HR-5 | Selbst beworben <14 Tage | 🔥 Hot | Automatisch nach 14 Tagen |
| HR-6 | Aktiver Prozess ≥ Interview | 🔥 Hot | Solange Prozess aktiv |

**Konfliktregel:** Hot-Rules (HR-5, HR-6) überschreiben alle anderen HR.

**Schicht 2: Punktebasierter Score (wenn keine Hard-Rule greift)**

| Signal | Punkte |
|---|---|
| WM-Stufe 7–8 | +3 |
| WM-Stufe 5–6 | +2 |
| WM-Stufe 4 | +1 |
| Erfolgreicher Call <14 Tage | +2 |
| Erfolgreicher Call <30 Tage | +1 |
| Briefing <30 Tage | +2 |
| CV zugeschickt | +2 |
| Aktiver Prozess (Stage < Interview) | +2 |
| Im Jobbasket aktiv | +1 |
| Kündigungsfrist ≤ 1 Monat | +1 |
| WM-Stufe 1–2 | -3 |
| WM-Stufe 3 | -1 |
| Kein Call seit 60+ Tage | -2 |
| Kein Call seit 90+ Tage | -3 |
| Kein Briefing vorhanden | -1 |
| Alle Prozesse beendet (<30d) | -2 |
| Kündigungsfrist ≥ 6 Monate | -1 |

**Schwellwerte:** ≥5 = 🔥 Hot, 1–4 = 🟡 Warm, ≤0 = 🔵 Cold

**Berechnung:** Zwei Batch-Jobs täglich (00:00 + 12:00 Uhr). Kein Event-getriebenes Recalculating.

**Phase 1.5/2 vorgemerkt:** Scoring-Punkte und Schwellwerte admin-konfigurierbar via dim_automation_settings.

### Profilvollständigkeit
**Gewichtete Berechnung (Option B):**

| Bereich | Gewicht | Pflichtfelder |
|---|---|---|
| Stammdaten | 20% | Name, Kontaktdaten (email_1, phone_mobile), Standort, Foto, Sparte |
| Verknüpfungen | 15% | Mind. 1 Function, mind. 3 Focus, mind. 1 Hauptcluster, mind. 1 Ausbildung, mind. 1 Sprache |
| Briefing | 30% | Alle Textfelder anteilig |
| Werdegang | 20% | Mind. 1 Arbeitsstation, aktuelle Position markiert |
| Dokumente | 15% | Original CV + ARK CV + Abstract (je anteilig) |

Farbe: grün >80%, amber 50–80%, rot <50%

**Phase 1.5/2 vorgemerkt:** Migration zu konfigurierbaren Gewichten (Option C).

### Beste Erreichbarkeit
- **Phase 1:** Einfaches 3-Stunden-Fenster (08–11, 11–14, 14–17, 17–20), Anzeige ab 5 erreichten Calls. Format: "📞 14–17 Uhr"
- **Phase 2 vorgemerkt:** Gewichtetes Zeitfenster mit Zeitzerfall über 90 Tage

### DO-NOT-CONTACT
- Visuell: Roter Badge im Header, prominent
- **Soft-Block (Option B):** Anrufen/Email/Jobbasket/Prozesse → Warn-Dialog "Dieser Kandidat ist als DO NOT CONTACT markiert. Trotzdem fortfahren?"
- Jede Aktion trotz Flag wird im Audit-Log protokolliert

### Breadcrumb
- Klick auf "Kandidaten" → zurück zur Kandidatenliste
- **Filter-/Scroll-Zustand wird beibehalten (Option B)** — User sieht exakt die gleiche gefilterte Liste wie vorher

---

## TEIL 2: TAB 1 — ÜBERSICHT

### Sektionen
- Alle Sektionen standardmässig **offen**
- Collapsible mit Chevron
- **Phase 2 vorgemerkt:** User-Präferenz merken (Option D)

### Stammdaten (2-Spalten Grid)

**Harte Pflichtfelder (bei Erstellung + danach, kann nie geleert werden):**
Anrede, Vorname, Nachname, Sparte, Kanton, Land (Default: Schweiz), Grossregion (auto aus Kanton), Candidate Manager, **Researcher** (kanonische Bezeichnung — kein „Hunter"), Owner Team

**Update 14.04.2026:** Beim Kandidaten existieren nur die zwei Personen-Rollen **CM** (Candidate Manager) und **Researcher**. „Hunter" als separate Rolle wird nicht verwendet — der Researcher übernimmt die Sourcing-/Hunting-Tätigkeiten in Tab 2 Longlist (aus Mandat-Sicht) und wird hier als Candidate Researcher gepflegt. Genau 1 Person je Rolle.

**Weiche Pflichtfelder (erwartet, nicht blockierend, beeinflusst Profilvollständigkeit):**
Email 1, Telefon Mobil, LinkedIn URL

**Optionale Felder:**
Email 2, Telefon Geschäft, Telefon Privat, Geburtsdatum, Nationalität, Wohnort, PLZ

**Validierung Pflichtfelder (Option C):**
- Harte Pflicht bei Erstellung: Formular lässt sich nicht absenden ohne diese Felder
- Danach in Detailansicht: Weiche Pflicht — Warnung (amber Umrandung) aber erlaubt
- Gelöschte Kontaktdaten (Emails/Nummern): Undo-Toast mit "Rückgängig" (6s)

**Grossregion:** Auto-berechnet aus Kanton (Schweiz), manuelles Dropdown für andere Länder (Option C)

| Grossregion | Kantone |
|---|---|
| Région lémanique | VD, VS, GE |
| Espace Mittelland | BE, FR, SO, NE, JU |
| Nordwestschweiz | BS, BL, AG |
| Zürich | ZH |
| Ostschweiz | GL, SH, AR, AI, SG, GR, TG |
| Zentralschweiz | LU, UR, SZ, OW, NW, ZG |
| Tessin | TI |

**Flags (Toggle-Chips):** blue_collar, fachliche_fuehrung, df_1_ebene, df_2_ebene, vr_c_suite

### Verknüpfungs-Sektionen

| Sektion | Eingabe | Anzahl | Primary | Secondary | Rating | Besonderheiten |
|---|---|---|---|---|---|---|
| Functions | Drawer (190+) | Unbegrenzt | ✓ | ✓ | 1–10 | Gold-Tags, Mehrfachauswahl im Drawer. **Reihenfolge fix** (Primary → Rating desc → Name asc), kein User-Drag-Reorder |
| Focus | Drawer (160+) | Unbegrenzt | ✓ | ✓ | 1–10 | Teal-Tags. Reihenfolge fix analog Functions |
| EDV | Inline Autocomplete | Unbegrenzt | ✗ | ✗ | 1–10 + Text-Level | Text-Level (Grundkenntnisse/Anwender/Experte) → Default-Rating (3/6/9), feinjustierbar. **Gruppiert nach Kategorie** (sichtbare Sektions-Header: AVA/Kalkulation · BIM/CAD · ERP · Office · Projektmanagement). „+ Software"-Pill pro Kategorie |
| Sprachen | Inline Autocomplete + Level-Dropdown | Unbegrenzt | ✗ | ✗ | Kein Rating, nur Level | 7 Stufen: Muttersprache, C2, C1, B2, B1, A2, A1 |
| Cluster | Inline Autocomplete, hierarchisch → Subcluster | Unbegrenzt | ✓ | ✗ | Kein Rating | Subcluster gefiltert nach gewähltem Cluster |
| Ausbildung | "+"-Pill → Drawer (vollständiger Werdegang-Eintrag) | Unbegrenzt | ✗ | ✗ | — | Synced mit Werdegang, Bildungsgrad → Bezeichnung hierarchisch |
| Sector | Inline Autocomplete (~50) | Unbegrenzt | ✓ | ✗ | Kein Rating | **Tag-Style neutral** (kein Gold) — Reporting/Filter-Zweck, NEU 14.04.2026 |
| Sparte | 5 Toggle-Tags (ING/GT/ARC/REM/PUR) | Multi | ✓ | ✗ | — | Alle 5 immer sichtbar, **mind. 1 aktiv** (Validierung: Toast „Mind. eine Sparte muss aktiv bleiben" beim Versuch, letzte zu deaktivieren) |
| **Grade (Kunden-Klasse)** | 3 Toggle-Pills A/B/C | **Single** | — | — | — | **Genau 1 aktiv** (Single-Select). Klick auf inaktive Pill ersetzt Auswahl. NEU 14.04.2026 |

**Primary/Secondary Darstellung:**
- Primary: Farbiger Tag mit Label "Primary"
- Secondary: Outline-Tag mit Label "Secondary"
- Sortierung: Primary → Secondary → Rest (nach Rating absteigend)
- Umschalten: Automatisch, alter Primary verliert Flag → Toast-Feedback

**Ausbildungs-Drawer Felder:**

| Feld | Typ | Pflicht |
|---|---|---|
| Bildungsgrad | Dropdown (EFZ, EBA, HF, FH, Uni/ETH, MBA, MAS/CAS/DAS, Doktorat, Kurs/Seminar/Zertifikat, Andere) | Ja |
| Bezeichnung | Autocomplete, hierarchisch gefiltert nach Bildungsgrad | Ja |
| Institution | Freitext | Ja |
| Von | Jahr | Ja |
| Bis | Jahr (optional — leer = gleiches Jahr wie Von) oder "Laufend" | Nein |
| Abgeschlossen | Toggle Ja/Nein | Ja |
| Bemerkungen | Textarea | Nein |

**Globale Datumsregel Ausbildung:** Von (Jahr, Pflicht), Bis (Jahr, optional — leer = gleiches Jahr). Gilt für ALLE Bildungstypen einheitlich.

### Empty / Loading / Error States

| Zustand | Verhalten |
|---|---|
| Loading | Skeleton-Screens pro Sektion (Option A). Phase 2: Progressive Loading (Option C) |
| Empty Tags | Nur "+"-Pill "Hinzufügen", kein Icon/Text |
| Empty Stammdaten | Platzhalter "Nicht angegeben" in gedämpfter Farbe (#726e66). Weiche Pflichtfelder: amber Umrandung |
| Error | Inline-Banner oben im Tab: "Daten konnten nicht geladen werden" + "Erneut versuchen". Phase 2: Error pro Sektion (Option B) |
| Save-Error Quick-Edit | Error-Toast (rot, permanent) + Wert zurückgesetzt |
| Save-Error Sektion | Error-Toast + Felder bleiben im Edit-Modus (kein Reset) |
| Version Conflict (409) | Warning-Toast (amber): "Jemand anders hat diesen Bereich bearbeitet. Bitte Seite neu laden." |

---

## TEIL 3: TAB 2 — BRIEFING

### Zwei Modi
- **Toggle-Button oben:** [📞 Live Briefing] ←→ [📝 Review]
- **Default:** Review-Modus
- Manueller Toggle — nicht automatisch basierend auf 3CX-Status (nicht jedes Gespräch ist ein Briefing)

### Versionierung
- Jedes Briefing-Gespräch = eigenständige Version (Option A)
- Keine Vorausfüllung aus vorheriger Version
- Neue Version = leeres Formular
- Vorherige Version als **Read-Only-Referenz einblendbar** (Split-View, Option C)

### AI-Review-Flow (nach Gespräch)
1. AI verarbeitet Transkript → füllt Briefing-Felder automatisch
2. Recruiter reviewed **sektionsweise** (Option C)
3. Fortschritt: "5/8 Sektionen bestätigt"
4. Pro Sektion: "✓ Sektion bestätigen" Button
5. **Leere Felder blockieren** — wenn AI ein Feld nicht erkannt hat, muss Recruiter manuell ausfüllen. Kein Feld darf leer bleiben.

**Feld-Zustände:**

| Zustand | Darstellung |
|---|---|
| AI-befüllt, noch nicht reviewed | Gelbe Umrandung + "AI"-Badge |
| AI-befüllt, bestätigt | Normale Darstellung |
| AI-befüllt, korrigiert | Normale Darstellung + Chip "Manuell angepasst" |
| Leer (AI hat nicht erkannt) | Rote Umrandung + "Pflichtfeld" Hinweis |

### Live-Modus (während Gespräch)
**Split-View (Option C):**
- Links: Leitfaden + Kontext (Sektions-Navigation, Median-Daten, Projekt-Suche)
- Rechts: Notizfeld (sektionsgebunden)

**Notizfeld:** Sektionsgebunden (Option B) — wechselt mit der aktiven Sektion im Leitfaden. Autosave. AI verarbeitet Transkript + sektionsgebundene Notizen zusammen. Bei Konflikten: AI markiert beide Werte, Consultant entscheidet im Review.

### Briefing-Sektionen

**Sektion 1: Gehalt & Vergütung**

| Feld | Typ | Verhalten |
|---|---|---|
| Fixlohn aktuell | CHF Integer | Balken aktualisiert live |
| Schmerzgrenze | CHF Integer | Separater Balken |
| Ziel | CHF Integer | Separater Balken |
| STI | CHF Integer (nicht Prozent) | Kein Balken |
| LTI | CHF Integer (nicht Prozent) | Kein Balken |
| Spesen-Pauschale | CHF Integer | |
| ÖV-Abo-Wert | CHF Integer | |
| Fahrzeug-Situation | Dropdown (4 Werte) | Wenn "Kein Fahrzeug" → Typ + Abzug ausgeblendet |
| Fahrzeug-Typ | Freitext | Nur sichtbar wenn Fahrzeug ≠ "Kein" |
| Fahrzeug-Abzug | CHF Integer | Nur sichtbar wenn Fahrzeug ≠ "Kein" |
| Lohnsituation | Dropdown (5 Werte) | Pflichtfeld, manuell |
| Monatslohn-Toggle | Toggle | Umrechnung ×12/÷12 |
| Spesen-Typen | Multi-Select (5 Optionen) | |
| Benefits | Multi-Select frei | |
| Total Paket | Auto-berechnet, read-only | Fixlohn + STI + LTI + Spesen + ÖV - Fahrzeug-Abzug |

**Marktmedian:** Berechnet aus allen Kandidaten mit Fixlohn-Wert, gefiltert nach Primary Function + Sparte + Kanton/Grossregion, Briefing <24 Monate. Progressive Erweiterung bei <5 Datenpunkten (Kanton → Grossregion → schweizweit). Anzeige: "Basierend auf X Kandidaten, Raum Y".

**Sektion 2: Arbeit & Verfügbarkeit**

| Feld | Typ |
|---|---|
| Pensum aktuell/gewünscht | Dropdown (40%, 50%, 60%, 70%, 80%, 80–100%, 100%) |
| Anstellungssituation | Dropdown (Festangestellt, Temporär, Selbstständig, Arbeitssuchend) |
| Kündigungsfrist | Dropdown (Sofort, 1 Monat, 2 Monate, 3 Monate, 6 Monate) |
| Wechselmotivation | 8-Segment-Leiste, synced mit Header |

**Sektion 3: Mobilität**

| Feld | Typ |
|---|---|
| Mobilität | Toggle-Tags (Auto, ÖV, Fahrrad, Zu Fuss) — alle 4 immer sichtbar |
| Arbeitsweg max | Dropdown (15 min, 30 min, 45 min, 60 min, 90 min, Egal) |
| Umzugsbereitschaft | Dropdown (5 Werte) |
| Homeoffice aktuell/gewünscht | Dropdown (0%, 20%, 40%, 60%, 80%, 100%) |
| Regionen | 7 Toggle-Tags (Grossregionen), synced mit Übersicht |

**Sektion 4: Bewertung**
- A/B/C: 3 klickbare Tags (A grün, B amber, C rot)
- GO-Themen: Textarea mit grünem Rahmen
- NO-GO-Themen: Textarea mit rotem Rahmen

**Sektion 5: Kompetenzen** (2-Spalten Grid, Freitext): Hardskills, Social Skills, Methoden, Führung

**Sektion 6: Persönlichkeit** (2-Spalten Grid, Freitext): Selbstbild, Fremdbild, Motivation, Bedürfnisse, Triggerpunkt, Moderation

**Sektion 7: Zonen**
4-Zonen-Bar (Komfort grün → Angst rot → Lern gold → Wachstum amber) + Sweet Spot (goldene Card, Freitext)

**Sektion 8: Privat**
Zivilstand (Dropdown), Kinder (Dropdown 0–5+), Leidenschaft (Textarea)

**Sektion 9: Projekte**
Siehe TEIL 12 (Projekt-Datenmodell).

---

## TEIL 4: TAB 3 — WERDEGANG

### Grundstruktur
- Vertikale Timeline, zwei Sektionen: "Beruf" / "Aus- / Weiterbildung"
- Sortierung: Neueste oben (Option A)
- Farbcodierte Pills: Zugang (grün), Abgang (rot/grau)

### Station hinzufügen
Drawer (540px), entry_type steuert Felder:
- **Job:** Firma (Autocomplete dim_accounts + "+Neu"), Stellenbezeichnung, Function, Sparte, Von/Bis (Monat/Jahr, Pflicht), Zugang/Abgang Dropdown, Beschreibung, Pensum, Cluster, Sector
- **Ausbildung:** Siehe Ausbildungs-Drawer in Teil 2
- **Kurs:** Wie Ausbildung
- **Lücke:** Nur Von/Bis + Beschreibung

**Datepicker:** Monat/Jahr für Jobs (Pflicht), Jahr für Ausbildung/Kurs.

### Lücken-Erkennung
**Automatisch (Option A):** Lücken >1 Monat → amber Element: "⚠ Lücke: April–Juni 2020 (3 Monate)". Klick → Lücke erklären.

### Projekte pro Station
**AI ordnet automatisch zu + manuell korrigierbar + manuell hinzufügbar (Option C)**

### Verknüpfung mit Übersicht
Neue Functions/Cluster/Sector/Sparten aus Werdegang erscheinen in Übersicht als **AI-Vorschlag** (gelbe Badges), nicht automatisch übernommen.

### LinkedIn-Import
**Phase 1.5/2 vorgemerkt:** URL-Scraping + PDF-Upload.

---

## TEIL 5: TAB 4 — ASSESSMENT

### Navigation
3 Tab-Ebenen:
1. **Haupttabs (gold):** Assessment aktiv
2. **Assessment-Subtabs (lila #a78bfa):** Gesamtüberblick, Scheelen & HN, App (disabled), AI-Analyse, Vergleich, Teamrad
3. **Modul-Tabs (grau, kleiner):** Innerhalb Scheelen & HN — DISC, Motivatoren, Relief, ASSESS 5.0, Human Needs, BIP, EQ

### Datenquellen

| Modul | Produkt | Dimensionen | Skala | Datenquelle |
|---|---|---|---|---|
| DISC | TriMetrix | 4 DISC + 4 Verhaltens-Dim, Natural+Adapted | 0–100 | CSV/Excel (Fallback: PDF-Parser) |
| Motivatoren | TriMetrix | 12 Driving Forces (6 Paare) | 0–100 | CSV/Excel (Fallback: PDF) |
| Relief | Relief | 10 Bereiche, 37 Dimensionen + Ampel | 0–6 | CSV/Excel (Fallback: PDF) |
| ASSESS 5.0 | ASSESS 5.0 | 8–12 Kompetenzen + 27 Persönlichkeit + Matching | 0–10 | CSV/Excel (Fallback: PDF) |
| Human Needs | Briefing | 6 Needs | — | AI aus Transkript |
| BIP | Briefing | 12 Dimensionen | — | AI aus Transkript |
| EQ | TriMetrix | 5 Dimensionen | 0–100 | CSV/Excel (Fallback: PDF) |

### Import-Flow
- Upload im **Dokumente-Tab** mit Label "Assessment"
- Backend-Worker erkennt Analyse-Typ automatisch (CSV/Excel + PDF-Fallback)
- **Duplikat-Erkennung:** SHA-256 Hash + inhaltliche Übereinstimmung → Warn-Dialog

### Versionierung
Pro Modul unabhängige Pfeil-Navigation. DISC kann auf Version 3 stehen während EQ auf Version 1 ist.

### Subtab 4a: Gesamtüberblick
- Status-Pills pro Modul (✓ grün mit Datum, ✗ grau, 🔒 disabled)
- Key-Scores auf einen Blick
- AI-Cross-Analysis Summary (immer aktuellste Version)

### Subtab 4b: Scheelen & Human Needs
- 7 Modul-Tabs in dritter Tab-Ebene (grau)
- Jedes Modul: Visualisierung gemäss Schema v1.2 + Pfeil-Versionierung

---

### Subtab 4d: AI-Analyse

**Grundprinzip:** Read-only — rein wissenschaftlich basierend auf Assessment-Daten, nicht editierbar.

#### States

**Empty State:** Icon (🧠), Modul-Cards mit Status. Button enabled ab ≥3 Module, darunter disabled + Tooltip.

**Loading State:** Spinner + 4-Step-Progress. Timeout 60s → Error-Toast. Kein Abbruch-Button.

**Result State:** 5 collapsible Sektionen + Spy-Nav rechts.

#### Source-Pills
- **Bestehende Analyse:** Statisch, nicht klickbar — zeigen welche Module eingeflossen sind (Transparenz)
- **Beim Neu-Generieren:** Popup mit Modul-Checkboxen (alle default aktiv), User kann Module deaktivieren

#### Versionierung
- **Persönlichkeitsanalyse (4 Sektionen):** Gesamtversion (v1, v2 etc.), alle 4 Sektionen wechseln gleichzeitig
- **Positions-Fit:** Separat versioniert (eigener Lebenszyklus, abhängig von Jobs/Prozessen)

#### Toolbar

| Element | Verhalten |
|---|---|
| "Analyse neu generieren" | Popup mit Modul-Checkboxen → Confirm → Loading → neue Version |
| Alle aufklappen/zuklappen | Toggled alle Sektionen |
| Farbenblind-Toggle | `cb-mode` Klasse, persistiert in localStorage |
| Kopieren | Dual-Format Clipboard: Rich Text (HTML) + Plaintext Fallback |

#### Trigger bei neuen Modulen
Kein Auto-Generieren. Hinweis-Banner: "Neues Modul verfügbar (EQ v1). Analyse neu generieren um aktualisierte Insights zu erhalten." + Button.

#### Banner-Priorität
Priorisiertes Single-Banner + Badge-Count. Reihenfolge: Error > Neues Modul > Delta-Summary > Positions-Fit veraltet.

#### Konfidenz
LLM bestimmt Konfidenz pro Sektion selbst im Generation-Request (Hoch/Mittel/Niedrig).

#### 5 Sektionen

**1. Persönlichkeitsprofil:** Fliesstext, read-only, Fett-Markierungen.

**2. Stärken & Risiken:** 2-Spalten Grid (grün/rot). Cards mit Quellen-Badges (Phase 2: klickbar → Modul-Tab).

**3. Cross-Modul-Muster:** Cards mit Badge-Typ: "Bestätigt" / "Spannung" / "Erkenntnis". Multi-Source-Badges.

**4. Empfehlungen & Coaching-Hinweise:** Nummerierte Cards. Read-only. **Copy per Card:** Hover → Clipboard-Icon → Klick kopiert Einzelempfehlung.

**5. Positions-Fit:**
- **Quelle:** Hybrid — automatisch aus Prozess + manuell hinzufügbar ("+ Positions-Fit hinzufügen")
- **Mehrere Fits:** Primary Fit inline, weitere über Badge → Drawer als Vergleichsansicht
- **Kein Prozess:** Hinweis + Link "→ Jobbasket öffnen"
- Farbcodiert: Grün ≥75%, Amber 50–74%, Rot <50%

#### Entwicklungs-Tracking
- **Delta-Summary:** LLM generiert "Was hat sich geändert?"-Zusammenfassung bei neuer Version
- **Score-Trend-Badges:** ↑/↓ Pfeile bei numerischen Werten gegenüber vorheriger Version

#### Spy-Nav
Sticky rechts (160px), farbige Dots, Scroll-Spy, Klick = Smooth-Scroll.

#### Keyboard

| Taste | Aktion |
|---|---|
| ↑/↓ | Sektion wechseln |
| Enter | Auf-/zuklappen |
| C | Kopieren |
| G | Neu generieren (mit Confirm) |
| 1–5 | Direkt zu Sektion |

#### Datenmodell
- `fact_ai_analyses` (candidate_id, version, generated_at, modules_used[], sections_json, model_version, delta_summary)
- `fact_ai_position_fits` (analysis_id, process_id/job_id, scores_json, version)
- PgBoss Job: `ai.generate-analysis`

---

### Subtab 4e: Vergleich

**Grundprinzip:** 2–8 Kandidaten nebeneinander. Charts = reine Berechnung, AI-Empfehlung = manuell generierbar.

#### Kandidaten-Auswahl
- Klick "+" → Popup mit: oben Prozess-Kandidaten (Quick-Picks), unten freie Suche (Autocomplete, ≥1 Assessment)
- **Max. 8 Kandidaten.** Ab 5+ kompakteres Layout
- **Speicherbare Vergleichssets:** Auswahl + Filter + Highlight-Overrides + Job gespeichert. Daten immer live aus DB. AI-Empfehlung nicht gespeichert.

#### Zugriffspunkte
- **Kandidatenmaske → Assessment → Vergleich:** Aktueller Kandidat fixiert
- **Prozess-Detailmaske → "Kandidaten vergleichen":** Freie Auswahl, alle Prozess-Kandidaten vorausgewählt

#### Analyse-Filter (Source-Bar)
Echte Filter: Toggle blendet Dimensionen/Zeilen/Charts ein/aus.

#### Fehlende Module
"n/a"-Badge + Modul-Badges pro Kandidat in Auswahl-Sektion.

#### Scorecard Best-Highlighting
Automatisch höchster Wert = grün (niedrigster bei Relief/Burnout). Manuelle Umschaltung pro Dimension per Klick auf Spalten-Header.

#### AI-Empfehlung
- Manueller Button "AI-Vergleich generieren"
- Optional positions-bezogen: Dropdown "Für Position:" (Auto-Fill aus Prozess)
- Kein Job = generische Empfehlung

#### Export
- **Kundenversion-PDF** (Light, ARK CI, professionell)
- **Clipboard** intern (HTML + Plaintext)

#### 6 Sektionen
1. Kandidaten-Auswahl (Slots, Farben, Module-Badges)
2. Übersichts-Scorecard (Tabelle, Best-Highlighting)
3. Dimensionen-Dot-Plot (farbige Marker pro Kandidat)
4. DISC-Wheel & BIP-Radar Overlay (Positionen + Polygone)
5. Stil-Vergleich (Text-Chips: Führungsstil, Kommunikation, Unter Druck, Teamrolle)
6. Positions-Fit & AI-Empfehlung (Gauges + Text)

---

### Subtab 4f: Teamrad

**Architektur:** Primär im **Account-Tab** (Stellenplan/Organigramm). Im Kandidaten-Subtab: **read-only Smart-Embed** mit kandidatenrelevanten Sektionen.

#### Account-Tab (Primary, Vollansicht)

**Team-Datenquelle:** Nur Kandidaten mit Assessment-Daten. ARK führt Assessments bei Kunden-Teams durch — alle Mitarbeiter werden als Kandidaten erfasst.

**Stellenplan:** Single Source of Truth im Account. Teams/Abteilungen dort gepflegt. Teamrad zeigt ausgewähltes Team.

**"Mit / Ohne Kandidat" Toggle:** Beide Versionen beim Generieren gleichzeitig erstellt und gecacht. Toggle = Instant-Switch, kein Loading.

**AI Team-Analyse:**
- Manueller "Generieren"-Klick nach Team-Zusammenstellung
- Danach gecacht. Banner bei Team-Änderungen
- Charts = reine Berechnung (sofort). AI-Summaries pro Sektion = nachgelagert in einem LLM-Call (Skeleton → Text)

**Sektionen:**
1. Team-Auswahl (aus Stellenplan)
2. AI Team-Analyse (Harmonien, Spannungsfelder, Lücken, Empfehlung — Mit/Ohne)
3. DISC-Teamrad & Zusammensetzung
4. Relief — Burnoutprävention (Heatmap, Ampel)
5. Motivatoren — Driving Forces
6. EQ Team-Vergleich
7. ASSESS 5.0 — Kompetenzen (Heatmap-Tabelle)
8. Kandidaten-Fit ins Team

**Export:** PDF + PPTX. Varianten: "Nur Team" / "Team + Kandidat" / "Beide (Vorher/Nachher)". Kundenversion ARK CI.

**Versionierung:** Kein aktives Versioning. Snapshots bei jedem Export gespeichert → "Exportierte Berichte" im Account (Audit-Trail).

#### Kandidaten-Subtab (Smart-Embed)

**Zeigt nur:**
- Team-Fit Score (Gauge)
- DISC-Position im Teamrad
- Lücken die der Kandidat füllt
- Mit/Ohne Toggle (gecacht, instant)
- AI-Empfehlung Team-Fit

**Team-Auswahl:** Manuelle Account/Team-Suche. Aktive Prozesse als hervorgehobene Quick-Picks.

**Daten pflegen:** Nur im Account-Tab. Link "Vollständige Analyse im Account öffnen →".

**Nicht im Embed:** Burnout-Heatmap, Motivatoren, ASSESS 5.0-Tabelle, EQ-Vergleich, Team-Zusammensetzung editieren.

---

## TEIL 6: TAB 5 — JOBBASKET

### Stage-Wechsel
- **Vollständig automatisiert** via History-Einträge und Dokumente
- Mündliche GOs versendet (History-Eintrag mit Email) → Prelead → Oral GO
- Schriftliche GO eingegangen (History-Eintrag) → Oral GO → Written GO
- Alle Gate-1 Dokumente vorhanden → Written GO → Assigned
- CV/Exposé versendet (History-Eintrag mit Email, verknüpft mit Prozess) → Assigned → CV Sent / Exposé
- **Pipeline-SVG ist reine Statusanzeige**, kein manuelles Durchklicken

### Manuelle Aktionen
- Job zum Basket hinzufügen (AI-Vorschlag oder Suche)
- Job aus Basket entfernen
- Rejection erfassen
- **Quick-Action Shortcuts** pro Job-Card für Aktionen die den Stage vorantreiben:
  - "📧 Mündliche GOs versenden" → öffnet Email-Flow (History-Eintrag)
  - "📄 Schriftliche GO erfassen" → öffnet History-Drawer mit richtigem ActivityType
  - "📨 CV senden" / "📨 Exposé senden" → nur sichtbar wenn Gate-1 erfüllt, öffnet Email-Flow
- Shortcuts sind Abkürzungen — die gleiche Aktion könnte auch im History-Tab ausgelöst werden

### Gate-1 Dokumenten-Check
- **Permanente Mini-Checkliste** unter der Pipeline wenn Stage = Written GO
- Zeigt: ✓ Original CV, ✓ Diplom, ✗ Arbeitszeugnis, ✓ Schriftl. GO
- **Klick auf fehlendes Dokument → navigiert zum Dokumente-Tab**
- Verschwindet sobald Gate-1 passiert ist

### AI-Matching Vorschläge
- Gecacht + Banner bei Profiländerung: "Profil hat sich geändert. Vorschläge neu berechnen?"
- Manueller "Neu berechnen"-Button
- 3 Vorschlagskarten mit Score-Breakdown (Sparte, Function, Salary, Location, Skills, Availability, Experience)

### Rejection
- **Drawer (540px)** mit:
  - Wer hat abgelehnt: Pflicht-Dropdown (Kandidat / CM / AM)
  - Warum: Pflicht-Dropdown (aus dim_jobbasket_rejection_types)
  - Kommentar: Freitext (optional)
  - Ghosting-Checkbox: Ja/Nein (triggert HR-4 Cold-Rule im Temperature-Modell)
  - Kontext: Übersicht was die Rejection bewirkt (Pipeline-Vorschau, Temperature-Auswirkung)

### Collapse / Expand
- **Aktive Jobs** (Prelead bis To Send): standardmässig aufgeklappt
- **Abgeschlossene** (CV Sent/Exposé) und **Rejected**: collapsed — nur Header (Titel, Account, Stage-Badge)
- Klick klappt auf

### Sortierung & Filterung
- **Stage-Filter:** Klickbare Chips oben (Alle, Prelead, Oral GO, Written GO, Assigned, Versendet, Rejected) mit Count
- **Sortier-Dropdown:** Stage / Datum (neueste zuerst) / Account A-Z / Zuletzt aktualisiert
- **Freitext-Suche:** Filtert über Job-Titel und Account-Name

### "Als Prelead hinzufügen"
- Sofort hinzugefügt + Undo-Toast (6s mit "Rückgängig"-Button)
- Konsistent mit Tag-CRUD Pattern

### Keyboard

| Taste | Aktion |
|---|---|
| ↑/↓ | Job-Card Navigation |
| Enter | Card auf-/zuklappen |
| S | Suche fokussieren |
| Esc | Filter/Suche zurücksetzen |

---

## TEIL 7: TAB 6 — PROZESSE

### Ansicht
- **Liste als Default** (Tabelle mit: Job, Account, Mandat, Stage, Status, Nächstes Interview, Erstellt am)
- Sortierbar pro Spalte
- Kanban als optionaler Toggle — rein visuelle Pipeline-Übersicht, kein Drag & Drop für Stage-Wechsel

### Prozess erstellen
- **Automatisch aus Jobbasket:** Prozess wird erstellt wenn CV oder Exposé aus dem Jobbasket versendet wird (History-Eintrag triggert)
- Kein manuelles Erstellen von Prozessen
- Prozess erbt Job, Account, Mandat (falls vorhanden) aus dem Jobbasket-Eintrag

### Klick-Verhalten
- **Klick auf Prozess → Drawer (540px)** mit Zusammenfassung:
  - Stage-Pipeline-Visualisierung
  - Nächstes Interview (Datum, Typ)
  - Honorar-Modell + berechneter Betrag
  - Letzte Aktivität (3 neueste History-Einträge)
  - Status-Badge (Open, On Hold, Rejected, Placed etc.)
- Button "Vollansicht öffnen →" → navigiert zu `/processes/[id]`

### Prozess-Status
Open, On Hold, Rejected, Placed, Stale, Closed, Cancelled, Dropped
- **Cancelled** = Rückzieher nach Placement (100% Rückvergütung)
- Status-Wechsel: Event-getrieben aus History-Einträgen, wie bei Jobbasket

### Honorar-Berechnung
- **Automatisch** basierend auf Erfolgsbasis-Staffel (Default) oder Mandat-Konditionen
- Default Best-Effort-Staffel: unter 90k → 21%, unter 110k → 23%, unter 130k → 25%, ab 130k → 27%
- Pro Prozess individuell überschreibbar im Drawer

---

## TEIL 8: TAB 7 — HISTORY

### Neuer Eintrag
- **Drawer** mit:
  - **ActivityType: Pflicht** — Combobox mit Suche (60+ Typen, gefiltert auf Kandidaten-relevante)
  - ActivityType bestimmt über DB-Verknüpfungen die Kategorie, Stage-Trigger, Briefing-Verknüpfung etc.
  - **Notizfeld: Optional** — Freitext
  - **Verknüpfung: Automatisch vorgeschlagen + korrigierbar** — System schlägt Prozess/Job/Mandat vor basierend auf ActivityType + aktiven Entitäten. Recruiter kann korrigieren oder leer lassen.
- **Transkript:** Wird automatisch im Hintergrund verarbeitet → AI-Summary → Felder werden nachträglich im History-Eintrag ergänzt. Badge "⏳ Transkript wird verarbeitet" → "✓ Transkript verfügbar"

### 3CX-Integration
- **Automatisch:** Alle 3CX-Calls (ein- und ausgehend) → automatischer History-Eintrag → Drawer zur Nachbearbeitung (ActivityType + optional Notiz)
- **Manuell:** Drawer für nicht-3CX-Calls (Handy-Rückrufe, WhatsApp etc.)
- **Click-to-Call im CRM** ist der Hauptweg um Calls über 3CX zu routen
- **Empfehlung: Rufweiterleitung Handy → 3CX evaluieren mit tiag.ch** (alle eingehenden Handy-Calls laufen über 3CX → lückenlose History)

### Mobile Nachbearbeitung
- **Push-Notification** nach Call-Ende: "Call mit Max Muster (4:32 Min) — Nachbearbeiten?"
- Klick öffnet Mobile-optimierten Drawer (ActivityType + Notiz)
- History-Eintrag wird sofort erstellt als "⏳ Nachbearbeitung ausstehend"
- Badge bleibt bis Recruiter nachbearbeitet hat
- **Dashboard-KPI:** "X Calls ausstehend" als Reminder

### Drawer-Tabs (kontextabhängig)
- Alle relevanten Tabs sichtbar (max 5), nicht-relevante fehlen
- Tabs: Übersicht, Transkript, AI-Summary, AI→Briefing (Link), Email-Thread, Reminders

| Call-Typ | Übersicht | Transkript | AI-Summary | AI→Briefing | Email | Reminders |
|---|---|---|---|---|---|---|
| Erreicht (normal) | ✓ | ✓ | ✓ | — | — | ✓ |
| Briefing-Call | ✓ | ✓ | — | ✓ | — | ✓ |
| NE (Kontaktberührung) | ✓ | — | — | — | — | ✓ |
| Email | ✓ | — | — | — | ✓ | ✓ |
| System-Auto | ✓ | — | — | — | — | ✓ |

### Email-Integration
- **Automatische Sync** aller Mitarbeiter-Email-Accounts (pw@, sp@, yb@, nn@ etc.)
- System matched automatisch anhand der Kandidaten-Email-Adressen (email_1, email_2)
- Emails erscheinen als History-Einträge mit Typ "Email" und blauem Dot
- **Email-Thread:** Im Drawer-Tab "Email" vollständiger Thread sichtbar

### Klassifizierung
- **confirmed:** ✓ Bestätigt (grün)
- **ai_suggested:** AI-Vorschlag (lila) + 1-Klick Bestätigen Button
- **pending:** ⏳ Offen (amber) — Nachbearbeitung ausstehend
- **manual:** Manuell erfasst (blau)

---

## TEIL 9: TAB 8 — DOKUMENTE

### Upload-Flow
- **Zwei Eingabewege:** Drag & Drop Zone oben ODER "Datei auswählen"-Button (Datei-Dialog)
- **Dokumententyp ist Pflicht** — nach Datei-Auswahl/Drop öffnet sich Typ-Dropdown:
  - Original CV, ARK CV, Abstract, Exposé, Diplom, Arbeitszeugnis, Schriftliche GO, Assessment, Foto, Sonstiges
- Upload startet erst nach Typ-Auswahl
- Mehrere Dateien gleichzeitig möglich → jede bekommt eigenen Typ-Dialog

### Gate-1 Checkliste
- Oben im Tab: Prüft 4 Pflicht-Dokumente
- ✓ Original CV, ✓ Diplom, ✗ Arbeitszeugnis (fehlt), ✓ Schriftliche GO
- Gleiche Checkliste wie im Jobbasket bei Written GO Stage
- Fehlende Dokumente mit Upload-Shortcut

### Dokument-Aktionen
- **Download:** Klick auf Dateiname
- **Preview:** Hover/Klick → Preview im Drawer (PDF-Viewer, Bild-Viewer)
- **Löschen:** ✕-Button auf Hover → Confirm-Dialog (destruktive Aktion)
- **Label ändern:** Quick-Edit auf den Dokumententyp
- **Versionierung:** Neuer Upload mit gleichem Typ → ersetzt nicht, sondern erstellt neue Version. Alte Version bleibt erreichbar über Pfeil-Navigation.

---

## TEIL 10: TAB 9 — DOK-GENERATOR

### Phase 1: Template-basiert
- "Neues Dokument" → Dropdown (ARK CV / Abstract / Exposé)
- System befüllt Template automatisch aus Profil-, Briefing- und Werdegang-Daten
- **Preview** mit Feld-Overrides (Recruiter kann einzelne Textfelder anpassen)
- "Generieren" → PDF wird erstellt → automatisch im Dokumente-Tab abgelegt
- Kein WYSIWYG-Editor in Phase 1

### Phase 2: WYSIWYG-Editor
- Rich-Text-Editor im Dokument-Layout
- Text ändern, Abschnitte umordnen, Foto tauschen
- Als eigenständiges Feature separat scopen und bauen

### Voraussetzungen pro Dokument-Typ
- **ARK CV:** Foto + Stammdaten + Werdegang + min. 1 Function
- **Abstract:** ARK CV + Briefing (Kompetenzen, Bewertung)
- **Exposé:** Abstract + Briefing (vollständig) + Assessment-Summary (optional)
- Fehlende Voraussetzungen: Hinweis mit Links zu den relevanten Tabs

---

## TEIL 11: TAB 10 — REMINDERS

### Darstellung
- **Gruppiert nach Status:**
  - 🔴 **Überfällig** (rot, oben, immer sichtbar, nicht collapsible)
  - 🟡 **Heute / Diese Woche** (amber)
  - ⚪ **Kommend** (normal)
  - ✓ **Erledigt** (collapsed unten, ausklappbar)

### Erstellen
- Mehrere Einstiegspunkte:
  - **Header Quick-Action** → Popover mit Minimalfeldern + "Erweitert →" Link
  - **History-Drawer** → "Reminder erstellen" Tab
  - **Reminders-Tab** → "+" Button → Drawer
- **Drawer-Felder:**
  - Text (Pflicht)
  - Datum (Pflicht)
  - Uhrzeit (optional)
  - Priorität: Normal / Hoch / Dringend (Pflicht, Default: Normal)
  - Verknüpfung: Prozess/Job/Mandat (optional, Autocomplete)

### Erledigen
- Checkbox in der Liste → durchgestrichen → verschiebt nach "Erledigt"
- Undo-Toast (6s) falls versehentlich

### Notifications
- **In-App:** Badge auf Reminder-Tab + Glocke im Header zeigt Anzahl überfälliger/heutiger
- **Push:** Phase 1.5 — Push-Notification bei Fälligkeit (Desktop + Mobile)
- **Email:** Phase 2 — Tägliche Digest-Email mit offenen Reminders

### Keyboard

| Taste | Aktion |
|---|---|
| ↑/↓ | Reminder Navigation |
| Enter | Drawer öffnen |
| Space | Erledigt togglen |
| N | Neuer Reminder |

---

---

## TEIL 12: PROJEKT-DATENMODELL

### 3-Ebenen-Struktur

**Ebene 1: Gesamtprojekt** (`dim_projects`)
Projektname, Auftraggeber (FK → dim_accounts), Grossregion, Beschreibung, Gesamtvolumen

**Ebene 2: Gewerk** (`fact_project_gewerke`)
project_id, bkp_code, los_bezeichnung, ausfuehrende_firma_id, volumen_chf, gesamtvolumen_gewerk_chf, von_jahr, bis_jahr, version, status, bemerkungen, tenant_id

**Ebene 3: Kandidaten-Beteiligung** (`bridge_candidate_project_gewerk`)
briefing_id, project_gewerk_id, candidate_id, rolle_function_id, sia_phases[], von_jahr, bis_jahr, verantwortetes_volumen_chf, herausforderungen, ergebnisse, insider_info, tenant_id

### Projekt-Drawer im Briefing
Scrollbare Sections (alle 3 Ebenen untereinander). AI füllt grob vor, Recruiter verfeinert.

### Filter-Flow
1. BC/WC → filtert BKP
2. SIA-Phase (Multi-Select) → filtert BKP weiter
3. BKP-Code auswählen (2-stellig, optional 3-stellig)
4. Gewerk-Details ausfüllen

---

## TEIL 13: NEUE STAMMDATEN-TABELLEN

### dim_sia_phases
code (PK), parent_code, ebene (1=Phase, 2=Teilphase), bezeichnung, phasenziel, is_active. 6 Phasen + 12 Teilphasen nach SIA 112.

### dim_bkp_codes
code (PK), parent_code, ebene (1–4), bezeichnung, is_blue_collar, is_white_collar, is_relevant, is_active. ~425 Positionen.

### bridge_bkp_sia_phases
bkp_code, sia_phase_code. ~1465 Verknüpfungen.

### collar_type auf dim_functions
blue_collar, white_collar, both (z.B. Polier).

### Projektvolumen-Typen
Bausumme, Baumeistervolumen, Heizung, Lüftung, Klima, Sanitär, Elektro, Honorarvolumen, Andere (+Freitext).

### SIA-Phasen für Projekte
Multi-Select Tags + Freitext "Phasen-Details".

---

## TEIL 14: PHASE 1.5/2 VORMERKLISTE

| Feature | Phase | Beschreibung |
|---|---|---|
| Confirm-Dialoge mit Konsequenzen-Text | 1.5 | Dialog zeigt was genau passiert |
| Profilvollständigkeit konfigurierbar | 2 | Gewichte über Admin-Panel |
| Temperature admin-konfigurierbar | 1.5/2 | Scoring via dim_automation_settings |
| Temperature gewichtetes Zeitfenster | 2 | Zeitzerfall über 90 Tage |
| Progressive Loading | 2 | Header zuerst, Sektionen nachladen |
| Error pro Sektion | 2 | Statt Inline-Banner |
| User-Präferenz Sektions-Zustand | 2 | Offen/zu merken |
| CRM Email-Composer | 1.5/2 | Individueller Absender |
| LinkedIn-Import | 1.5/2 | URL-Scraping + PDF-Upload |
| Semantische Projekt-Suche | 2 | Embeddings-basiert |
| Assessment-Charts (D3/Recharts) | 2 | DISC-Ringdiagramme, Spider/Radar |
| AI-Analyse Diff-Ansicht | 2 | Side-by-Side Versionsvergleich |
| AI-Analyse Source-Badge → Modul-Tab | 2 | Klick navigiert zum Modul |
| Vergleich eigenständige Route `/compare` | 2 | Vergleich als eigenes Feature |
| Vergleich PPTX-Export | 2 | Zusätzlich zum PDF |
| Teamrad Account-Stellenplan | 1 | Organigramm im Account pflegen |
| Teamrad PPTX-Export | 1 | PowerPoint für Kunden |
| AI-Dokumententyp-Erkennung | 1.5 | Upload → AI erkennt Typ aus Dateiname + Inhalt |
| Dok-Generator WYSIWYG | 2 | Rich-Text-Editor im Dokument-Layout |
| Reminder Push-Notifications | 1.5 | Desktop + Mobile bei Fälligkeit |
| Reminder Email-Digest | 2 | Tägliche Zusammenfassung offener Reminders |
| 3CX Rufweiterleitung Mobile | 1 | Evaluieren mit tiag.ch (Handy → 3CX) |
| Outlook Email-Sync alle Accounts | 1 | Vollständige Email-Integration pro Mitarbeiter |
| Jobbasket AI-Matching Scoring | 1.5 | fact_match_scores Berechnung |
| Kanban-Ansicht Prozesse | 2 | Visuelle Pipeline, read-only (kein D&D) |

---

## TEIL 15: OFFENE PUNKTE (nächste Session)

- Berechnungsformeln (Total Paket exakt, Profilvollständigkeit exakt)
- Cross-Tab Datenfluss-Mechanik
- Permission Matrix (Feld × Rolle)
- API Contract Sheet
- Relief Datenstruktur (10 Bereiche, 37 Dimensionen)
- ASSESS 5.0 Kompetenz-Liste (kommt von Scheelen)
- Account-Detailmaske: Teamrad-Tab spezifizieren (Stellenplan, Organigramm)
- Account-Detailmaske: Exportierte Berichte / Snapshot-Verwaltung
