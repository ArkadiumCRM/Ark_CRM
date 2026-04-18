# ARK CRM/ERP — Gesamtsystem-Übersicht v1.2 (korrigiert)

**Stand:** 2026-03-30
**Autor:** Peter Wiederkehr (Produkt-Owner) + Claude (Architektur)
**Zweck:** Vollständige Beschreibung des ARK-Systems für neue Entwickler, Reviewer und Stakeholder

---

## TEIL 1: WAS IST ARK?

### 1.1 Das Unternehmen

ARK Executive Search (Arkadium AG) ist eine Schweizer Personalberatung spezialisiert auf die Baubranche. Das Unternehmen vermittelt Fach- und Führungskräfte in den Bereichen Tiefbau, Hochbau, HLKS, Gebäudetechnik, Architektur und Bauingenieurwesen.

Die Kerndienstleistung ist "Executive Search" mit der Methode "Direct Search" — ARK sucht aktiv nach Kandidaten anstatt auf Bewerbungen zu warten. Direct Search ist keine Mandatsart, sondern die grundlegende Arbeitsmethode die ARK bei allen Auftragstypen anwendet.

### 1.2 Die fünf Sparten

| Kürzel | Name | Beschreibung |
|---|---|---|
| ING | Civil Engineering | Ingenieurwesen, Umweltingenieure, Bauphysiker, Geotechnik |
| GT | Building Technology | Gebäudetechnik, Netzthematiken, Energiesektor |
| ARC | Architecture | Architektur, Innenarchitektur und Design |
| REM | Real Estate Management | Immobilienmanagement, Entwicklung, Asset Management |
| PUR | Procurement | Einkauf, Supply Chain, Beschaffung |

Jeder Kandidat, Account und Job wird einer primären Sparte zugeordnet.

### 1.3 Die Rollen

| Rolle | Aufgabe |
|---|---|
| Head of (HoD) | Spartenleitung, strategische Steuerung, Eskalationsstufe |
| Account Manager (AM) | Kundenbetreuer, akquiriert Mandate |
| Candidate Manager (CM) | Kandidatenbetreuer, führt Briefings, steuert GO-Prozess |
| Research Analyst (RA) | Longlist-Recherche, Erstansprache, Kaltakquise |
| Backoffice (BO) | Administration, Assessment-Management |
| Admin | Systemadministration, Benutzerverwaltung |

Eine Person kann mehrere Rollen gleichzeitig haben (z.B. CM + AM).

### 1.4 Der Arbeitstag eines Consultants

Der Consultant öffnet morgens das CRM (Electron Desktop-App) und arbeitet den ganzen Tag ausschliesslich darin. Kein separates Outlook, kein Browser für LinkedIn.

Dashboard zeigt: Überfällige Reminders, unklassifizierte Anrufe/Emails (gelber Badge mit Zähler), nicht zugewiesene History-Einträge, ausstehende AI-Empfehlungen zum Bestätigen, KPIs.

Was der Consultant NIE manuell tun muss: Stage-Changes, Prozess-Erstellung nach CV Sent, Duplikat-Erkennung, AI-Summaries, Zuordnung Call/Email → Kandidat, Gate-Prüfungen, Template-basierte Email-Klassifizierung.

Was der Consultant IMMER manuell tun muss: Activity-Type bestätigen (1-Klick), Dokumente hochladen, Briefing-Maske ausfüllen, Kandidat in Jobbasket legen, Rejection-Gründe angeben, AI-Empfehlungen bestätigen/ablehnen.

---

## TEIL 2: DER REKRUTIERUNGSPROZESS

### 2.1 Zwei Geschäftsmodelle

**Mit Mandat (Einzelmandat, RPO, Time):** Formeller Auftrag mit definierten Konditionen.

**Auf Erfolgsbasis (Best Effort):** Kein formelles Mandat. Kandidaten werden proaktiv vorgestellt. Honorar nur bei Placement, nach gestaffelter Tabelle (unter 90k → 21%, unter 110k → 23%, unter 130k → 25%, ab 130k → 27%). Pro Prozess individuell überschreibbar.

Der Prozessablauf ist bei beiden identisch: Briefing → GO-Termin → Preleads → Mündliche/Schriftliche GOs → CV/Exposé versenden → Interview-Pipeline → Placement. Der Unterschied: Bei Mandaten gibt es eine Longlist, KPI-Tracking und Mandat-spezifische Konditionen. Bei Erfolgsbasis fehlt das Mandat als Struktur, AGB müssen vom Kunden bestätigt werden.

### 2.2 Mandatsarten

| Typ | Beschreibung | Zahlung |
|---|---|---|
| Einzelmandat | Exklusiver Auftrag für eine Stelle | 3 Teile: (1) Vertragsunterzeichnung, (2) Shortlist (konfigurierbare Anzahl CV Sent), (3) Placement |
| RPO | Aufbau Abteilung/Standort, mind. 3 Positionen. Jede Position = eigener Job unter dem Mandat | Monatliche Fee + Erfolgsfee pro Position |
| Time | Reine Beratungsleistung | Nur monatliche Fee |

### 2.3 Longlist / Research

Der RA baut eine Longlist auf. Research-Flow:

Research → Nicht erreicht → CV Expected → CV IN → Briefing → GO mündlich → GO schriftlich

Ab "CV IN" sind Stages gesperrt (nur Automationen können ändern). Stages: Research, Nicht erreicht (NE), Nicht mehr erreichbar, Nicht interessiert (NIC = Not Interested Currently), Dropped, CV Expected, CV IN (auto bei CV-Upload), Briefing (auto bei Briefing-Speichern), GO mündlich (auto bei Mündliche-GOs-Email), GO schriftlich (auto bei Schriftl. GO-Eingang), Ghosted (auto nach Fristablauf), Rejected Oral/Written GO.

**Synchronisierung:** Alle Kandidaten in einer Longlist erhalten bei relevanten History-Einträgen automatisch Stage-Updates auch in der Mandate Research. NIC → rejected, Dropped → dropped, CV-Upload → cv_in, etc.

### 2.4 Preleads und GO-Prozess

**Preleads** sind Unternehmen/Jobs die der CM dem Kandidaten im GO-Termin vorstellen möchte.

1. Nach GO-Termin wählt CM passende Accounts/Jobs aus → kommen als Preleads in Jobbasket
2. CM bespricht Preleads mit Kandidat
3. CM versendet Email "Mündliche GOs" mit Prelead-Liste → Kandidat soll schriftlich rückbestätigen
4. Kandidat bestätigt schriftlich welche er verfolgen möchte
5. Abgelehnte Preleads: Rejected Candidate (Kandidat will nicht), Rejected CM (CM findet sinnlos), Rejected AM (AM findet nicht passend)

### 2.5 Jobbasket und Versand

Prelead → Oral GO → Written GO → Assigned → To Send → CV Sent / Exposé Sent

Gate 1 (Assigned): Automatisch wenn Schriftl. GO + CV + Diplom + Zeugnis vorhanden.
Gate 2 (Versand): Buttons erscheinen wenn ARK CV/Exposé vorhanden. Versand erstellt automatisch einen Prozess.

### 2.6 Prozess (Interview-Pipeline)

Exposé → CV Sent → TI → 1. Interview → 2. Interview → 3. Interview → Assessment → Angebot → Platzierung

Status: Open, On Hold, Rejected, Placed, Stale, Closed, Cancelled, Dropped. Cancelled = Rückzieher nach Placement (Kandidat zieht nach Zusage zurück, 100% Rückvergütung). Stale = zu lange in gleicher Stage (konfigurierbar). Closed = regulär abgeschlossen (Garantiefrist). Dropped = Prozess kam nicht zustande. Prozesse können mit oder ohne Mandat existieren.

**Interview-Terminierung:** Das Terminieren der Interviews macht der Kunde (nicht ARK). ARK begleitet den Kandidaten durch Coaching (vor Interview) und Debriefing (nach Interview). Für jedes Interview wird ein Reminder mit Datum und Prozess-Verknüpfung erstellt. Der Reminder enthält: Datum/Uhrzeit, Kandidat, Account, Ansprechpartner, Interview-Nummer (1./2./3.). Über die Outlook-Kalender-Integration (CalendarReadWrite Scope) wird automatisch ein Kalendereintrag für den CM erstellt.

Automatisch: Placement → Job auf "Filled". Shortlist-Trigger bei Einzelmandaten (siehe 5.3).

Tracking: Jobs ohne ARK-Prozess besetzt = "Extern besetzt". Jobs mit Prozess aber ohne Placement = "Nicht platziert".

### 2.7 Post-Placement

Automatische Reminders: Onboarding Call (Start - 7 Tage), 30/60/90-Tage Check-ins, Garantiefrist-Ende.

Cancellation = Rückzieher nach Placement. 100% Rückvergütung. Rückvergütungsfristen bei regulärem Austritt: Monat 1 → 50%, Monat 2 → 25%, Monat 3 → 10%.

---

## TEIL 3: KANDIDATEN

### 3.1 Profil

Personalien, Kontaktdaten, Standort, Online-Profile, Foto. CRM-Status: Stage, Temperatur (Hot/Warm/Cold), Wechselmotivation (8 Stufen). Zuständigkeit: CM, Hunter, Team, Sparte (ING/GT/ARC/REM/PUR). Flags: Blue Collar, Fachliche Führung, 1./2. Ebene DF, VR/C-Suite, DO-NOT-CONTACT.

### 3.2 Stages

| Stage | Trigger |
|---|---|
| Check | Automatisch bei Erstellung |
| Refresh | Bei Ghosting, NIC, Dropped. Nach 1 Jahr in Datenschutz. War im Austausch mit RA. |
| Premarket | Automatisch wenn Briefing gespeichert |
| Active Sourcing | Automatisch wenn CV + Diplom + Zeugnis + Briefing vorhanden |
| Market Now | Automatisch wenn Prozess erstellt |
| Inactive | Auto: Alter >60 oder Cold >6 Monate. Oder manuell. |
| Blind | Nur manuell. Potenziell interessant in Zukunft. |
| Datenschutz | Löst Anonymisierung aus. Nach 1 Jahr auto → Refresh. Auch manuell rückstellbar. |

Bei NIC, Dropped, Nicht mehr erreichbar: Stage-Update auch in allen aktiven Longlists.

**Datenschutz-Sonderregel:** Im Backend ist Datenschutz als terminaler Status definiert (keine regulären Übergänge erlaubt). Die automatische Rückkehr nach 1 Jahr und die manuelle Rückstellung werden als **Sonder-Automation** implementiert die den Terminal-Status explizit überschreiben darf. Dies wird im Code als dedizierte Funktion mit eigener Berechtigung (system_override) gebaut, nicht über die reguläre Stage-Machine. Audit-Log dokumentiert den Override-Grund.

### 3.3 Wechselmotivation und Temperatur

**Wechselmotivation** (faktische Situation): Arbeitslos, Will/muss wechseln, Will/muss wahrscheinlich wechseln, Wechselt bei gutem Angebot, Spekulativ, Wechselt intern & wartet ab, Will absolut nicht wechseln, Will nicht mit uns zusammenarbeiten.

**Temperatur** (Dringlichkeit aus ARK-Sicht): Hot (jetzt angehen), Warm (beobachten), Cold (nicht priorisiert).

Kombination gibt Information: "Wechselt bei gutem Angebot + Hot" = jetzt vorstellen.

### 3.4 Kompetenzen

Fünf Dimensionen: Cluster/Subcluster (fachliche Kompetenz-Cluster, ca. 15 + 66 Subclusters), Functions (Berufsfunktionen, 190+), Focus (fachliche Skills, 160+ — ersetzt das alte Skill-System), EDV (Software-Kenntnisse, 120+), Sector/Branche. Jede Zuordnung mit Rating 1-10 und Primary-Flag.

### 3.5 Briefing

Unbegrenzt versioniert. 9 Sektionen: Gehalt, Verfügbarkeit, Mobilität, Bewertung (A/B/C), Kompetenzen, Persönlichkeit, Zonen-Modell, Privat, Sonstiges, Projekte (aus Briefing → AI matcht zu Werdegang-Stationen).

### 3.6 Werdegang

Vertikale Timeline: Arbeitsstellen, Ausbildungen, Lücken. Pro Station: Projekte mit Bauherr, Kosten, Team. AI matcht Briefing-Projekte automatisch zu Stationen (KPI-Eskalation bei offenen Empfehlungen).

### 3.7 Assessment

DISC, Motivatoren, EQ, Relief, Outmatch, Human Needs/BIP, Ikigai. Pro Typ individuell versioniert.

---

## TEIL 4: ACCOUNTS UND KONTAKTE

### 4.1 Accounts

Stammdaten, Klassifikation (Status, Kundenklasse A/B/C, Einkaufspotenzial ★/★★/★★★, No Hunt, Sparte ING/GT/ARC/REM/PUR), Intelligence, Scraping. Nach Scraper-Bestätigung: Auto-Erstellung/Aktualisierung von Kontakten, Vakanzen, Organigramm.

**Einkaufspotenzial:** Neues Feld `purchase_potential` auf dim_accounts mit Werten 1/2/3 (★ = 0-1 Positionen/Jahr, ★★ = 2-3, ★★★ = 3+).

**AGB-Tracking:** Pro Account wird gespeichert ob und wann der Kunde die AGB bestätigt hat (Felder: `agb_confirmed_at`, `agb_version` auf dim_accounts). **Gate-Check bei Erfolgsbasis:** Bevor ein CV/Exposé an einen Kunden ohne bestätigte AGB versendet wird, erscheint eine Warnung: "AGB für diesen Account noch nicht bestätigt. Fortfahren?" Der Versand wird nicht blockiert, aber der CM wird auf das Risiko hingewiesen.

### 4.2 Kontakte

Decision Maker, Key Contact, Champion, Blocker Flags. "Left Company" = ausgegraut, historisch erhalten. Kann gleichzeitig Kandidat sein.

### 4.3 Firmengruppen

Aggregations-Dashboard: Zusammenfassung aller Tochterunternehmen (Mitarbeiter, Mandate, Prozesse, Sparten). Eigene Felder: Gruppen-Manager, Website, LinkedIn. Details in den Accounts.

---

## TEIL 5: JOBS, MANDATE, VAKANZEN

### 5.1 Jobs

Titel, Account, Sparte, Ort, Gehalt (CHF, CHECK min<=max), Pensum. Function/Focus-Verknüpfung (AI-Vorschlag). Status: Open → Filled / On Hold / Cancelled. Auto-Filled bei Placement. Manuell Filled = "Extern besetzt" (getrackt).

### 5.2 Vakanzen

Status: Open → Filled / On Hold / Cancelled / Lost (Lost = extern besetzt, ARK hat verloren).

### 5.3 Mandate

Typen: Einzelmandat, RPO, Time. Status: Entwurf → Aktiv / Abgelehnt. Aktiv → Abgeschlossen / Abgebrochen. Tracking: Offerten-Conversion-Rate (Entwurf → Aktiv vs. Entwurf → Abgelehnt). KPIs: Ident Target/Actual, Call Target/Actual, Shortlist-Trigger (konfigurierbar). RPO: Jede Position = eigener Job.

**Mandats-Aktivierung:** Ein Mandat wird im Status "Entwurf" erstellt. Es wird automatisch auf "Aktiv" gestellt wenn in der Mandats-Detailmaske ein Dokument mit dem Label "Mandatsofferte unterschrieben" hochgeladen wird. Dieser Trigger stellt sicher dass kein Mandat aktiv wird ohne unterzeichneten Vertrag.

**Shortlist-Trigger (Einzelmandat):** Im Mandat wird eine Anzahl "CV Sent" definiert (z.B. 2 oder 3) die die 2. Zahlung auslöst. Wenn diese Anzahl erreicht wird: (a) fact_mandate_billing erstellt automatisch den 2. Zahlungs-Eintrag, (b) Notification an AM: "Shortlist für Mandat X erreicht — 2. Zahlung fällig". Wenn MEHR CVs als konfiguriert versendet werden, fragt das System: "Shortlist-Limit überschritten. Zusatzleistung fällig?" Der AM entscheidet ob eine Zusatzleistung verrechnet wird.

**Zusatzleistungen bei Einzelmandaten:** Der Kunde kann zusätzliche Idents oder Dossiers dazukaufen. Pro Mandat definierbar: Ident-Zusatzpreis (CHF pro zusätzlichem identifiziertem Kandidaten über das Ident-Target hinaus) und Dossier-Zusatzpreis (CHF pro zusätzlich erstelltem Dossier über das Shortlist-Limit hinaus). Diese werden in der Mandats-Übersicht als "Extras" mit Stückzahl und Preis aufgeführt.

---

## TEIL 6: HISTORY UND AUTOMATIONEN

### 6.1 Drei Systeme

fact_history (Mensch), fact_event_queue (System), fact_audit_log (Compliance).

### 6.2 Activity-Types (61+ in 11 Kategorien)

Kontaktberührung (6), Erreicht (15, NIC = Not Interested Currently), Emailverkehr (11), Messaging (3), Interviewprozess (7), Placementprozess (3), Refresh (3), Mandatsakquise (4), Erfolgsbasis (2, NEU: AGB Verhandlungen + AGB bestätigt), Assessment (4), System (5).

### 6.3 Automations-Trigger-Matrix

Briefing → Premarket + Mandate Research briefing. Mündliche GOs → Jobbasket oral_go + Mandate Research go_muendlich. NIC/Dropped → Refresh + Mandate Research rejected/dropped. CV-Upload → Mandate Research cv_in. Placement → Job Filled + Onboarding/Check-in Reminders + Provisions-Berechnung. Datenschutz → Anonymisierung + nach 1 Jahr → Refresh (Sonder-Automation). Cold >6M → Inactive. Template-Email → Auto-Klassifizierung. Shortlist-Trigger → 2. Zahlung fällig + AM-Notification (nur Einzelmandat). CV-Versand an Account ohne bestätigte AGB → Warnung (kein Block). Interview-Termin eingetragen → Kalender-Eintrag + Reminder für CM. Dokument "Mandatsofferte unterschrieben" hochgeladen → Mandats-Status Entwurf → Aktiv.

Alle Automationen greifen übergreifend: Kandidaten-Stage UND alle aktiven Longlists.

### 6.4 Eskalation

Unklassifizierte Einträge: sofort Badge → 24h Reminder → 48h Head_of → wöchentlich KPI.
AI-Empfehlungen: Dashboard-Badge, gleiche Eskalation.
Ghosting: Reminder an CM + KPI-Tracking.
Alle Fristen konfigurierbar in Admin → Automation-Settings.

---

## TEIL 7: EMAIL-SYSTEM

CRM als zentrales Kommunikationstool. 32 Standard-Templates (4 mit Automation-Trigger). Erweiterbar. Unbekannte Emails → Angebot neuen Kandidaten/Account zu erstellen. Drafts im CRM speicherbar.

**Ausfallsicherheit:** Health-Check Worker prüft Token-Status alle 5 Min. Bei Ablauf: Auto-Refresh + Admin-Alert. Bei Fehlschlag: Banner "Email-Sync unterbrochen", Consultants können temporär über Outlook arbeiten, Nachhol-Sync wenn Token wieder gültig.

---

## TEIL 8: TELEFONIE (3CX)

Click-to-Call, auto History-Eintrag, Transkription, AI-Summary, Screen-Pop bei eingehenden Anrufen.

---

## TEIL 9: DOKUMENTE

Typen: Original CV, ARK CV, Exposé, Abstract, Diplom, Arbeitszeugnis, Assessment-Dokument, Vertrag, Mandat-Report. Max 20 MB. Dok-Generator: ARK CV, Abstract, Exposé. Phase 2: Rechnungen, Assessment-Reports, Zeitreports.

**Mandate-Report-Generator:** Für Mandate-Kunden die regelmässige Status-Reports erwarten. Generiert einen professionellen PDF-Report der automatisch Daten aus dem Mandat zusammenstellt: Longlist-Status (wie viele Kandidaten in welchem Stage), Anrufstatistiken (Call-Target vs. Actual), Pipeline-Fortschritt (Prozesse und deren Stages), Timeline (Kickoff → heute). Kann manuell oder periodisch (z.B. wöchentlich) generiert und per Email an den Kunden versendet werden.

---

## TEIL 10: REMINDERS

Auto-generiert: Kandidat ohne Briefing (7d), Onboarding Call (Start-7d), Post-Placement Check-ins (30/60/90d), Stale Prozess (>14d), Data Retention Warnung (30d), Ghosting, Datenschutz-Reset, Interview-Termine (verknüpft mit Prozess, erstellt Outlook-Kalendereintrag für CM), Interview-Datum fehlt (wenn Prozess-Stage auf Interview wechselt aber kein Datum eingetragen wird, Default 2 Tage nach Stage-Wechsel).

---

## TEIL 11: SCRAPER + MARKET INTELLIGENCE

Monitoring Websites/LinkedIn. Approve/Reject. Nach Bestätigung: Auto-Erstellung Kontakte, Vakanzen, Organigramm-Updates.

---

## TEIL 12: AI

Schreibt nie direkt. Vorschlag → Mensch bestätigt. AI-Bestätigungsrate als KPI. Matching zieht aus gesamtem Kandidatenprofil (Stammdaten, Werdegang, Briefing, Assessment, Dokumente, History).

**Assessment-Import:** Scheelen-Assessment-Ergebnisse werden per CSV-Datei importiert. Workflow: (1) Backoffice lädt CSV hoch, (2) System führt Dry-Run durch (Vorschau was importiert wird, welche Kandidaten zugeordnet werden), (3) Backoffice bestätigt, (4) Daten werden in die Assessment-Tabellen geschrieben, (5) Automatischer History-Eintrag "Assessment - Ergebnisse erfasst". Endpunkt: POST /api/v1/assessments/import-scheelen mit Dry-Run-Modus.

**Provisionsabrechnung:** Bei jedem Placement wird die Provision automatisch berechnet basierend auf: Kandidaten-Gehalt (salary_candidate_target), Honorarsatz (aus Mandat-Konditionen oder Best-Effort-Staffel), Kommissionssätze (commission_cm_pct, commission_am_pct, commission_hunter_pct aus dim_mitarbeiter). Bei Split-Mandaten (CM ≠ AM ≠ Hunter) wird die Provision pro Rolle aufgeteilt. Pro Mitarbeiter gibt es eine Provisionsübersicht mit: offene Provisionen (Placement erfolgt, noch nicht ausgezahlt), ausgezahlte Provisionen, Gesamt pro Periode. Phase 1: Berechnung und Übersicht. Phase 2: Integration mit Payroll/Lohnlauf.

**Account-Duplikat-Erkennung:** Analog zur Kandidaten-Duplikat-Erkennung (v_candidate_duplicates) wird eine Account-Duplikat-Erkennung implementiert: Fuzzy-Matching auf Firmennamen (z.B. "Brun AG" vs. "Brun Bauunternehmung AG"), Matching auf domain_normalized (gleiche Website = wahrscheinlich gleicher Account), Matching auf Handelsregister-UID. Besonders relevant wenn der Scraper neue Accounts erstellt. Duplikat-Kandidaten erscheinen als Merge-Vorschlag im Admin-Bereich.

**Outlook-Integration Ausfallsicherheit:** Da das CRM das zentrale Kommunikationstool ist, wird die Outlook-Integration zum kritischen Pfad. Schutzmassnahmen: (1) Health-Check Worker der alle 5 Minuten den Token-Status prüft, (2) Bei ablaufendem Token (< 24h): Automatischer Refresh-Versuch + Alert an Admin, (3) Bei fehlgeschlagenem Refresh: Sofortige Notification an Admin + Banner im CRM "Email-Sync unterbrochen", (4) Consultants können in diesem Fall temporär über Outlook arbeiten — eingehende Mails werden nachsynchronisiert sobald der Token wieder gültig ist.

---

## TEIL 12b: DEBUGGABILITY — "WARUM IST DAS PASSIERT?"

Eines der grössten Risiken bei einem Event-getriebenen System ist dass niemand mehr nachvollziehen kann warum etwas passiert ist. Wenn ein Kandidaten-Stage sich automatisch ändert oder ein Prozess erstellt wird, muss der Consultant (und der Admin) jederzeit sehen können: Was war der Auslöser? Welche Events haben sich verkettet?

**Event-Timeline pro Entity:** Jede Hauptentität (Kandidat, Account, Job, Mandat, Prozess) hat eine "Was ist passiert?"-Ansicht die drei Quellen zusammenführt:

1. **fact_history** — Was hat ein Mensch getan? (Anrufe, Emails, Meetings)
2. **fact_event_queue** — Was hat das System ausgelöst? (Stage-Changes, Automationen)
3. **fact_audit_log** — Was wurde konkret geändert? (Feld-Level Änderungen)

Die Ansicht zeigt eine chronologische Timeline mit:
- Wer/Was hat den Eintrag ausgelöst (Mensch/System/Automation)
- Was war der Trigger (z.B. "Email-Template Mündliche GOs versendet → Jobbasket oral_go → Mandate Research go_muendlich")
- Welche Felder wurden geändert (alter Wert → neuer Wert)
- correlation_id zum Nachverfolgen von Event-Ketten

**Im Frontend:** Eigener Tab oder Drawer pro Entity mit der kombinierten Timeline. Filter nach Quelle (History/Events/Audit). Besonders für Admins und Head_ofs wichtig bei Eskalationen.

**Im Backend:** Endpoint `GET /api/v1/entities/:type/:id/event-chain` der alle drei Quellen zusammenführt und chronologisch sortiert zurückgibt.

---

## TEIL 12c: PHASEN-KLARHEIT

Das System ist bewusst ambitioniert. Um die Komplexität zu kontrollieren, gilt eine strikte Phasen-Trennung:

**Phase 1 — MUSS funktionieren (Launch-Blocker):**
Kandidaten (10 Tabs), Accounts (10 Tabs), Jobs, Mandate, Prozesse, Jobbasket mit GO-Flow, History mit Activity-Types, Reminders, Dokumente mit Upload/Download, Basic Dashboard mit KPIs, Dark Mode, Vollseiten-Navigation, Suche (Command Palette), Benachrichtigungen.

**Phase 1.5 — Kurz nach Launch (erste 4 Wochen):**
AI Activity-Type Vorschläge, AI Transkript-Zusammenfassungen, Email-Composer im CRM (MS Graph Send), Email-Inbox (MS Graph Sync), 3CX Click-to-Call + Screen-Pop, Assessment CSV-Import, Stale-Prozess-Erkennung, Post-Placement Reminder-Kette, Account-Duplikat-Erkennung.

**Phase 2 — Mittelfristig (3-6 Monate nach Launch):**
RAG/Semantische Suche, AI Matching (Kandidat ↔ Job), WYSIWYG Dokumenten-Generator, Assessment-Charts (D3/Recharts), Kanban Drag & Drop, Teamrad-Visualisierung, Organigramm-Baumstruktur, Standorte-Karte, LinkedIn Social Tracking, Mandate-Report-Generator.

**Phase 3 — ERP (eigenes Produkt):**
Zeiterfassung, Buchhaltung (Periodenabschluss-Lock ZUERST), Payroll/Provisionsauszahlung, Performance/HR, Messaging (WhatsApp/LinkedIn), Publishing (Multi-Channel Stellenausschreibung).

**Prinzip: Complexity Budget.** Vor jedem Feature die Frage: "Macht das den Consultant messbar schneller?" Wenn nein → Phase 2 oder später.

---

## TEIL 13: STAMMDATEN

Kompetenz: dim_cluster (fachlich, mit Subclustern), dim_functions (190+), dim_focus (160+, = Skills), dim_edv (120+), dim_education (Grad + konkrete Ausbildung), dim_sector, dim_sparte (ING/GT/ARC/REM/PUR), dim_languages.

Aktivität: dim_activity_types (61+, 11 Kategorien), dim_event_types, dim_process_stages, dim_rejection_reasons_candidate/client, dim_dropped_reasons, dim_cancellation_reasons (Rückzieher nach Placement), dim_offer_refused_reasons, dim_jobbasket_rejection_types (candidate/cm/am).

Templates: dim_email_templates (32, erweiterbar), dim_prompt_templates, dim_notification_templates.

Konfiguration: dim_honorar_settings, dim_automation_settings (alle Fristen), dim_tenant_features, dim_ai_write_policies.

DEPRECATED: dim_skills_master + 9 zugehörige Tabellen (ersetzt durch dim_focus).

Views: v_candidate_duplicates (Kandidaten-Duplikat-Erkennung), v_account_duplicates (Account-Duplikat-Erkennung via Fuzzy-Matching Firmennamen, domain_normalized, Handelsregister-UID).

---

## TEIL 14–17: SCHEMA-ÄNDERUNGEN v1.1 → v1.2

Neues Feld wechselmotivation auf Kandidaten (8 Stufen). Neues Feld purchase_potential auf Accounts (1/2/3 Sterne). Neue Felder agb_confirmed_at + agb_version auf Accounts. Jobbasket: Prelead-Stage + differenzierte Rejection (candidate/cm/am). Activity-Types: 11 Kategorien. fact_history: Text-Feld entfernt, categorization_status um "pending" erweitert. Email-Templates erweitert (template_key, linked_activity_type, linked_automation_key). UNIQUE auf idempotency_key. Jobs: salary CHECK. Prozess-Status: Open, On Hold, Rejected, Placed, Stale, Closed, Cancelled, Dropped. Mandats-Status: Entwurf → Aktiv / Abgelehnt → Abgeschlossen / Abgebrochen. Neuer Status "Abgelehnt" für Mandate die nicht zustande kommen (KPI: Offerten-Conversion-Rate). Aktivierung via Dokument-Upload "Mandatsofferte unterschrieben". Datenschutz-Stage: Sonder-Automation für 1-Jahr-Reset die Terminal-Status überschreiben darf. Mandate: Zusatzleistungen-Felder (ident_extra_price, dossier_extra_price, ident_extra_qty, dossier_extra_qty). 5 neue Tabellen (dim_tenant_features, fact_email_drafts, dim_automation_settings, dim_jobbasket_rejection_types, v_account_duplicates als View). 12 neue Events (inkl. mandate.activated). 6 Indizes. Skills deprecated. Assessment-Import-Endpunkt. Provisionsübersicht-Endpunkt pro Mitarbeiter. Outlook Health-Check Worker. Power BI Read-Only-Datenbankrolle für Reporting.

---

## TEIL 18: PHASE 2

Zeiterfassung, Billing/Buchhaltung (Periodenabschluss-Lock zuerst!), Performance/HR, Messaging, Publishing, Payroll.

---

## TEIL 19: TECHNISCHE ARCHITEKTUR

Backend: Node.js/Fastify/Railway. Frontend: Next.js/React/Vercel. Dark Mode only (#262626/#dcb479/#196774). Detailansichten als Vollseiten. Event-Driven. AI schreibt nie direkt. Tenant-Isolation.

**Berechtigungsmatrix (Rolle × Modul × Aktion):** Definiert welche Rolle welche Daten sehen und welche Aktionen ausführen darf. Beispiele: RA sieht keine Gehaltsdaten, Backoffice kann keine Kandidaten-Stages ändern, CM sieht auf dem Dashboard nur "seine" Kandidaten aber alle in der Suche. Die vollständige Matrix wird im ARK_FRONTEND_FREEZE (UI-Sichtbarkeit pro Rolle) und ARK_BACKEND_ARCHITECTURE (Endpoint-Berechtigungen pro Rolle) definiert.

**Power BI / Reporting:** Nenad (Admin) verbindet Power BI direkt auf die Supabase-Datenbank über eine Read-Only-Rolle. Dashboards (Placement-Rate, Revenue pro Sparte, Pipeline-Velocity, Consultant-Performance etc.) werden in Production manuell erstellt und angepasst — keine Vordefinition im CRM nötig. Das DB-Schema (ARK_DATABASE_SCHEMA) muss sicherstellen dass die nötigen Views und Indizes für typische Reporting-Queries performant sind.
