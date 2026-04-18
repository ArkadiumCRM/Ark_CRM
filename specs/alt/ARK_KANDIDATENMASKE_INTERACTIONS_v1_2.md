# ARK CRM — Kandidatenmaske Interactions Spec v1.2

**Stand:** 07.04.2026
**Status:** Arbeitsdokument — wird zum Schema v1.3 zusammengeführt
**Kontext:** Definiert das Verhalten, die Interaktionslogik, CRUD-Flows, Validierung und Speicher-Strategien für alle Tabs der Kandidaten-Detailmaske.
**Ergänzt:** ARK_KANDIDATENMASKE_SCHEMA_v1_2.md (Feld-Inventar + Layout)
**Vorrang:** Bei Widerspruch gilt: Stammdaten > dieses Dokument > Schema v1.2 > Mockups
**Änderungen v1.1 → v1.2:** Tabs 5–10 (Jobbasket, Prozesse, History, Dokumente, Dok-Generator, Reminders) vollständig spezifiziert und an die richtige Stelle im Dokument einsortiert. TEILE durchnummeriert (TEIL 6–11 = Tabs 5–10, TEIL 12 = Projekt-Datenmodell, TEIL 13 = Stammdaten-Tabellen, TEIL 14 = Vormerkliste, TEIL 15 = Offene Punkte). Vormerklisten zusammengeführt. Offene Punkte um Tabs 5–10 bereinigt.
**Änderungen v1.0 → v1.1:** Assessment-Subtabs AI-Analyse (Teil 5d), Vergleich (Teil 5e) und Teamrad (Teil 5f) vollständig spezifiziert. Teamrad-Architektur: Primär im Account, Embed beim Kandidaten.

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
Anrede, Vorname, Nachname, Sparte, Kanton, Land (Default: Schweiz), Grossregion (auto aus Kanton), Candidate Manager, Candidate Hunter, Owner Team

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
| Functions | Drawer (190+) | Unbegrenzt | ✓ | ✓ | 1–10 | Gold-Tags, Mehrfachauswahl im Drawer |
| Focus | Drawer (160+) | Unbegrenzt | ✓ | ✓ | 1–10 | Teal-Tags |
| EDV | Inline Autocomplete | Unbegrenzt | ✗ | ✗ | 1–10 + Text-Level | Text-Level (Grundkenntnisse/Anwender/Experte) → Default-Rating (3/6/9), feinjustierbar |
| Sprachen | Inline Autocomplete + Level-Dropdown | Unbegrenzt | ✗ | ✗ | Kein Rating, nur Level | 7 Stufen: Muttersprache, C2, C1, B2, B1, A2, A1 |
| Cluster | Inline Autocomplete, hierarchisch → Subcluster | Unbegrenzt | ✓ | ✗ | Kein Rating | Subcluster gefiltert nach gewähltem Cluster |
| Ausbildung | "+"-Pill → Drawer (vollständiger Werdegang-Eintrag) | Unbegrenzt | ✗ | ✗ | — | Synced mit Werdegang, Bildungsgrad → Bezeichnung hierarchisch |
| Sector | Inline Autocomplete (~50) | Unbegrenzt | ✓ | ✗ | Kein Rating | |
| Sparte | 5 Toggle-Tags (ING/GT/ARC/REM/PUR) | Multi | ✓ | ✗ | — | Alle 5 immer sichtbar, mind. 1 aktiv |

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
3. **Modul-Tabs (grau, kleiner):** Innerhalb Scheelen & HN — DISC, Motivatoren, Relief, Outmatch, Human Needs, BIP, EQ

### Datenquellen

| Modul | Produkt | Dimensionen | Skala | Datenquelle |
|---|---|---|---|---|
| DISC | TriMetrix | 4 DISC + 4 Verhaltens-Dim, Natural+Adapted | 0–100 | CSV/Excel (Fallback: PDF-Parser) |
| Motivatoren | TriMetrix | 12 Driving Forces (6 Paare) | 0–100 | CSV/Excel (Fallback: PDF) |
| Relief | Relief | 10 Bereiche, 37 Dimensionen + Ampel | 0–6 | CSV/Excel (Fallback: PDF) |
| Outmatch | ASSESS 5.0 | 8–12 Kompetenzen + 27 Persönlichkeit + Matching | 0–10 | CSV/Excel (Fallback: PDF) |
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
7. Outmatch — Kompetenzen (Heatmap-Tabelle)
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

**Nicht im Embed:** Burnout-Heatmap, Motivatoren, Outmatch-Tabelle, EQ-Vergleich, Team-Zusammensetzung editieren.

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
