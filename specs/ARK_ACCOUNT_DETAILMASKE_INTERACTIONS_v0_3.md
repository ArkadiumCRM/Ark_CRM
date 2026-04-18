# ARK CRM — Account-Detailmaske Interactions Spec v0.3

**Stand:** 14.04.2026
**Status:** Review ausstehend
**Kontext:** Definiert Verhalten, Interaktionslogik, CRUD-Flows, Validierung und Speicher-Strategien für alle Tabs der Account-Detailmaske. Gleicher Methodik-Rahmen wie ARK_KANDIDATENMASKE_INTERACTIONS_v1_3.md.
**Begleitdokument:** `ARK_ACCOUNT_DETAILMASKE_SCHEMA_v0_3.md` (Layout, Felder, Design-Tokens)
**Vorrang:** Stammdaten > dieses Dokument > Schema > Mockups
**Globale Patterns:** Es gelten alle 11 globalen Patterns aus TEIL 0 der Kandidaten-Interactions v1.2.

## Changelog v0.1 → v0.2 (13.04.2026)

| # | Änderung | Sektion |
|---|----------|---------|
| 1 | Tab-Struktur von 11 auf 13 Tabs erweitert (+Assessments, +Schutzfristen) | TEIL 0 |
| 2 | Tab 8 Assessments — Flows, Datenmodell, Auto-Trigger | TEIL 8b (neu) |
| 3 | Tab 9 Schutzfristen — Matrix, Claim-Workflow, Auto-Extension | TEIL 8c (neu) |
| 4 | Header Quick-Action: "+ Assessment beauftragen" | TEIL 1 |
| 5 | Header Claim-Banner bei offenen Schutzfrist-Verletzungen | TEIL 1 |
| 6 | Cross-Navigation Mandat-Option IX → Assessment | TEIL 8b |

## Changelog v0.2 → v0.3 (14.04.2026)

| # | Änderung | Sektion |
|---|----------|---------|
| 7 | **Route:** `/company-groups/[id]` (englisch, Entscheidung #1) | Bedingter Tab Firmengruppe |
| 8 | **Tab 9 Schutzfristen: Gruppen-Scope-Einträge angezeigt** mit Label "Gruppen-Schutzfrist" (Audit-Finding P0.2) | TEIL 8c |
| 9 | **Claim stellen: AM alleine** (Entscheidung #5, kein Admin-Gate) | TEIL 8c |
| 10 | **Claim-Billing-Logik kontextabhängig** (Mandats-Konditionen vs. Erfolgsbasis-Staffel, Entscheidung #7) | TEIL 8c |
| 11 | **Assessment-Credits-Typen-Übersicht** in Tab 8 Top-Banner (Gesamt gekauft/verbraucht/offen pro Typ) | TEIL 8b |
| 12 | **Assessment-Typisierung konsistent** zur Assessment-Spec v0.2 | TEIL 8b |
| 13 | **TEIL-Nummerierung normalisiert:** 8/8b/8c → 8a/8b/8c für Klarheit (P0.3 aus Audit) | TEIL 8a/8b/8c |
| 14 | Sprachstandard: `candidate_id` konsistent | DB-Referenzen |

---

## TEIL 0: STRUKTURELLE GRUNDENTSCHEIDUNGEN

### Tab-Struktur (final)

| # | Tab | Inhalt |
|---|---|---|
| 1 | Übersicht | Stammdaten in 10 Sektionen |
| 2 | Profil & Kultur | Vision/Mission/Purpose, Führung & Strategie, Kulturprofil (Arkadium Analyse) |
| 3 | Kontakte | dim_account_contacts (jeder Kontakt = auch Kandidat) |
| 4 | Standorte | fact_account_locations (Container pro Standort, Inline-Edit) |
| 5 | Organisation | Subtab Stellenplan + Subtab Teamrad |
| 6 | Jobs & Vakanzen | fact_jobs (eine Tabelle, Lifecycle Vakanz → Job) |
| 7 | Mandate | fact_mandate inkl. Konditionen pro Mandat |
| 8 | Assessments (neu v0.2) | fact_assessment_order — mandatsbezogen + eigenständig |
| 9 | Schutzfristen (neu v0.2) | fact_protection_window Matrix + Claim-Workflow |
| 10 | Prozesse | fact_process_core |
| 11 | History | fact_history |
| 12 | Dokumente | fact_documents |
| 13 | Reminders | fact_reminders |
| (bedingt) | Firmengruppe | Nur sichtbar wenn `account_group_id IS NOT NULL` |
| (bedingt) | Projekte | Nur sichtbar wenn `EXISTS(fact_projects WHERE bauherr_account_id = this.id) OR EXISTS(fact_project_company_participations WHERE account_id = this.id)` |

13 fixe Tabs + 2 bedingt.

### Design-Konsistenz

Alle Tabs folgen den gleichen visuellen und Interaktions-Patterns wie die Kandidatenmaske. Account-Tab bildet das gleiche System mit account-spezifischen Themen.

---

## TEIL 1: HEADER

### Logo
- **Quelle:** Scraper-basiert (wenn `scraping_enabled = true` extrahiert der Scraper das Logo nebenbei von der Website)
- **Fallback:** Farbige Initialen-Kreis (z.B. "BA" für Brun AG)
- **Manueller Upload:** Jederzeit möglich via Gold "+" Button → Datei-Dialog → überschreibt Auto-Fetch
- **Klick auf Logo:** Öffnet `website_url` in neuem Tab

### Stammdaten-Zeile
- Account-Name (gross)
- Sparte-Badge
- account_status Dropdown (Active / Inactive / Prospect / Blacklisted) — Pattern wie Kandidat-Stage: Dropdown mit Kontext, ungültige Stages ausgegraut, Confirm-Dialog
- Customer Class Pill (A/B/C)
- Einkaufspotenzial Pill (★/★★/★★★)
- AGB-Badge (grün "AGB bestätigt [Datum]" oder amber "AGB ausstehend")
- Account Temperature Badge (🔥 Hot / 🟡 Warm / 🔵 Cold) — siehe Temperature-Modell unten

### Aliases (Auch bekannt als)
- **Versteckt wenn nicht vorhanden** — keine leere Zeile
- Wenn vorhanden: Kleine graue Zeile unter dem Account-Namen "Auch bekannt als: Implenia, Implenia Schweiz AG"
- Edit über die "Identität"-Sektion in Tab 1 → Edit-Button öffnet Drawer mit Alias-Liste (Type-Selector: Trading Name / Abkürzung / Früherer Name)

### Snapshot-Bar (zweite Header-Zeile, sticky) — **Reine Firmografik (Entscheidung 14.04.2026)**
6 KPI-Slots als grosse Zahlen-Kacheln, in jedem Tab sichtbar. **Bewusst keine Arkadium-Beziehungs-Metriken** — diese leben in der Tab-1-KPI-Bar (siehe TEIL 2).

| Slot | KPI | Quelle |
|---|---|---|
| 1 | 👥 Mitarbeitende CH-weit | `dim_accounts.employee_count` |
| 2 | 📈 Wachstum letzte 3 Jahre | NEU: `growth_rate_3y_pct` |
| 3 | 💰 Umsatz letztes Geschäftsjahr | NEU: `revenue_last_year_chf` |
| 4 | 🏛 Gegründet | `dim_accounts.founded_year` (mit Alters-Berechnung) |
| 5 | 📍 Standorte | `count(dim_account_locations WHERE account_id = X)` |
| 6 | ⭐ Kulturfit-Score Arkadium Analyse | Berechnet aus Tab 2 Profil & Kultur |

Slot 6 zeigt "—" solange noch keine Arkadium-Analyse läuft. Klick auf Slot 5 → springt zu Tab 4 Standorte.

### Quick Actions
- **📞 Anrufen:** Popover mit allen Telefonnummern aller Kontakte (gruppiert nach Person, Decision Maker oben). Click-to-Call via 3CX. Auch bei nur einer Nummer: Popover als Bestätigungsschritt.
- **✉ Email:** Phase 1 Popover mit "📧 Neue Email (CRM)" + "📨 In Outlook öffnen". Phase 1.5/2 vorgemerkt: voller CRM-Composer.
- **🔔 Reminder:** Quick-Popover mit Minimalfeldern (Text, Datum, Priorität) + Link "Erweitert →" → voller Drawer. Verknüpfung optional auf Mandat/Prozess/Job.
- **🧭 Assessment beauftragen (NEU v0.2):** Öffnet Assessment-Auftrags-Drawer (siehe TEIL 8b). Erzeugt eigenständigen `fact_assessment_order` ohne Mandats-Bezug.

### Claim-Banner (konditional, NEU v0.2)

Wenn zu diesem Account offene **Schutzfrist-Claims** existieren (Scraper-Match "Kandidat bei diesem Account angestellt" + aktives Schutzfrist-Fenster), erscheint **oberhalb der Snapshot-Bar** ein Full-Width Banner:

```
⚠️ 2 Claim-Fälle ausstehend — Kandidaten bei diesem Account angestellt, Honoraranspruch prüfen
   [→ Zu Tab Schutzfristen]
```

Farbe: Amber. Klick → springt zu Tab 9 Schutzfristen mit Filter `status = 'claim_pending'`.

### Account Temperature (Auto-only, keine manuelle Überschreibung)

**Visuell:** Badge `🔥 Hot` / `🟡 Warm` / `🔵 Cold` (analog Kandidat). Tooltip on hover zeigt wirksame Hard-Rule oder Score-Breakdown.

**Schicht 1: Hard-Rules (überschreiben alles)**

| Regel | Bedingung | Erzwingt | Verfall |
|---|---|---|---|
| HR-1 | `account_status = 'Blacklisted'` | 🔵 Cold | Manuell entfernen |
| HR-2 | `account_status = 'Inactive'` | 🔵 Cold | Manuell auf Active setzen |
| HR-3 | Aktives Mandat (Status `Aktiv`) vorhanden | 🔥 Hot | Solange Mandat aktiv |
| HR-4 | Aktiver Prozess (Status `Open`) vorhanden | 🔥 Hot | Solange Prozess offen |
| HR-5 | Letzter erreichter Kontakt < 30 Tage UND `account_status = 'Active'` | 🔥 Hot | Nach 30 Tagen Verfall |

**Konfliktregel:** HR-1 und HR-2 (Blacklisted/Inactive) sind immer Cold und überschreiben alles andere. Reihenfolge: HR-1 → HR-2 → HR-3/4/5 → Score.

**Schicht 2: Punktebasierter Score (wenn keine Hard-Rule greift)**

| Signal | Punkte |
|---|---|
| Letzter erreichter Kontakt 30–60 Tage | +1 |
| Letzter erreichter Kontakt 60–120 Tage | 0 |
| Letzter erreichter Kontakt 120–365 Tage | -2 |
| Letzter erreichter Kontakt > 365 Tage | -4 |
| AGB bestätigt (`agb_confirmed_at IS NOT NULL`) | +2 |
| AGB nicht bestätigt | -1 |
| Mind. 1 Prozess in den letzten 12 Monaten | +2 |
| Mind. 1 Mandat (egal Status) in den letzten 12 Monaten | +2 |
| Customer Class A | +2 |
| Customer Class B | +1 |
| Customer Class C | 0 |
| Einkaufspotenzial ★★★ | +2 |
| Einkaufspotenzial ★★ | +1 |
| Penetration Score ≥ 70 | +2 |
| Penetration Score 40–69 | +1 |
| `has_had_process = false` UND Account-Alter > 90 Tage | -2 |
| Letzte 3 Mandate alle abgelehnt | -3 |

**Schwellwerte:** ≥5 = 🔥 Hot, 1–4 = 🟡 Warm, ≤0 = 🔵 Cold

**Berechnung:** Zwei Batch-Jobs täglich (00:00 + 12:00 Uhr), identisch zum Kandidat-Temperature-Job. **Phase 1.5/2 vormerken:** Scoring konfigurierbar via `dim_automation_settings`.

### Soft-Blocks
- **Blacklisted:** Anrufen/Email/Mandat erstellen/Prozess starten → Warn-Dialog "Account ist BLACKLISTED. Trotzdem fortfahren?" + Audit-Log
- **is_no_hunt:** Kandidat aus diesem Account in Jobbasket/Prozess hinzufügen → Warn-Dialog "Bei diesem Account ist Headhunting untersagt. Trotzdem fortfahren?" + Audit-Log. Mandate, Email, Anruf bleiben uneingeschränkt erlaubt.

### Definition account_status (Stammdaten-Klärung)
- **Active** — Normaler Kunde, alles erlaubt
- **Prospect** — Noch kein Kunde, Akquise-Phase, kein bestätigtes Mandat
- **Inactive** — Ehemaliger Kunde, schläft, keine aktive Bearbeitung mehr, kann reaktiviert werden
- **Blacklisted** — Negativ-Liste (schlecht bezahlt, rechtliche Auseinandersetzung, Inhaber daneben benommen)

`is_no_hunt` ist davon **separates Flag** mit anderer Bedeutung: "Wir dürfen bei diesem Kunden niemanden abwerben" — Loyalitätsregel der Branche. Ein Kunde kann gleichzeitig `Active` und `is_no_hunt = true` sein (Normalfall für gute Bestandskunden).

### Breadcrumb
- Klick "Accounts" → zurück zur Accounts-Liste mit erhaltenem Filter-/Scroll-Zustand

---

## TEIL 2: TAB 1 — ÜBERSICHT (STAMMDATEN)

### Arkadium-Relation KPI-Bar (NEU 14.04.2026, oben in Tab 1)

Vier KPI-Kacheln über den Sektionen, **Beziehungs-Metriken** (komplementär zur Snapshot-Bar im Header die nur Firmografik zeigt):

| KPI | Berechnung |
|---|---|
| 💰 Umsatz mit Arkadium YTD | `SUM(fact_mandate_billing.amount WHERE account_id = X AND year = current AND status = 'paid')` + Erfolgsbasis-Honorare |
| 🏆 Placements total | `count(fact_process_core WHERE account_id = X AND status = 'Placed')` |
| ⏱ Ø Time-to-Hire | Mittelwert `(placed_at - opened_at)` über letzte 12 Monate |
| 📈 Conversion CV→Placement | `count(Placed) / count(CV Sent)` letzte 12 Monate |

Format wie Snapshot-Bar (grosse Serif-Zahl + Label uppercase + Sub-Text mit Trend/Vergleich).

### Sektionen-Struktur

10 Sektionen, alle collapsible, alle standardmässig offen — gleiches 2-Spalten-Grid-Layout wie Kandidaten Tab 1.

| # | Sektion | Felder |
|---|---|---|
| 1 | **Identität** | account_name, account_legal_name, handelsregister_uid, account_aliases, founded_year, account_status, customer_class, purchase_potential, sparte_id, owner_team |
| 2 | **Web & Kontakt** | website_url, domain_normalized (read-only abgeleitet), career_page_url, team_page_url, linkedin_url, country, account_manager_id |
| 3 | **Unternehmensgrösse** | employee_count, growth_rate_3y_pct (NEU), revenue_last_year_chf (NEU), revenue_estimate_chf, founded_year |
| 4 | **Klassifikation & Verknüpfungen** | industry, taetigkeitsfelder, usp + Verknüpfungssektion (siehe unten) |
| 5 | **Intelligence** | penetration_score, hiring_potential_ranking, hiring_season, job_posting_frequency, fluktuation_rate, competitor_headhunters, dossier_send_preference |
| 6 | **Flags & Regeln** | is_no_hunt, has_had_process, AGB-Block (agb_confirmed_at, agb_version) |
| 7 | **Scraping** | scraping_enabled (Toggle), scrape_interval_hours (Dropdown 6h/12h/24h/7d), last_scraped_at, "Jetzt scrapen" Button (rate-limited 1×/Stunde/Account) |
| 8 | **Notizen** | comment_short, comment_internal |
| 9 | **Zugehörigkeit** | account_group_id (Link zur Firmengruppe falls vorhanden, sonst "Keiner Gruppe zugeordnet" + Button) |

**Standorte sind NICHT in Tab 1** — wurden in Tab 4 verschoben.

### Verknüpfungs-Sektion (innerhalb "Klassifikation & Verknüpfungen")

| Verknüpfung | Pflege | Bedeutung |
|---|---|---|
| **Sparte** | Multi-Toggle (5 Toggle-Tags ING/GT/ARC/REM/PUR), mind. 1 aktiv — exakt wie Kandidat | In welchen Sparten ist der Account aktiv |
| **Sector** | Inline Autocomplete (~50), Multi-Select | In welchem Branchen-Sektor (Öffentliche Hand / Private Bauherren / Industrie / Infrastruktur / Wohnbau etc.) |
| **Cluster** | Inline Autocomplete hierarchisch → Subcluster | Tätigkeitscluster (Hochbau / Tiefbau / Tunnelbau / Brückenbau etc.) |
| **Functions** | **Auto-aggregiert aus Werdegang** der Kandidaten die hier arbeiten/gearbeitet haben (read-only Anzeige "🏗 Functions die wir kennen: Polier (12), Bauführer (8)…") | Wer arbeitet typisch in dieser Firma |
| **Focus** | **Auto-aggregiert** wie Functions | Welche Spezialisierungen sehen wir |

### Owner Team
- Account hat eigenes `owner_team` (für Mandate/Akquise)
- Kandidaten-Owner-Team ist davon **unabhängig** — keine Synchronisation zwischen Account-AM-Team und Kandidat-Owner-Team

### Validierung
- **Harte Pflichtfelder bei Erstellung** (kann nie geleert werden): account_name, country, sparte_id, account_manager_id
- **Weiche Pflichtfelder** (erwartet, nicht blockierend): website_url, domain_normalized, employee_count, AGB-Block bei A-Kunden

---

## TEIL 3: TAB 2 — PROFIL & KULTUR

### Sektionen-Struktur

| # | Sektion | Inhalt |
|---|---|---|
| 1 | **Vision · Mission · Purpose** | Vision (Textarea), Mission (Textarea), Purpose (Textarea), Kernwerte (Tag-Liste) |
| 2 | **Führung & Strategie** | Führungsstil, Entscheidungskultur, Transformationsreife, Wachstumsstrategie, Differenzierung, Nachfolgeregelung |
| 3 | **Kulturprofil — Arkadium Analyse** | 6 Score-Dimensionen mit Balken: Leistungsorientierung, Innovationskultur, Autonomiespielraum, Feedbackkultur, Hierarchieflachheit, Transformationsreife |
| 4 | **Kulturfit-Score** | Gesamt-Score (0–100) mit Methodik-Tooltip, abgeleitet aus Sektion 3 |
| 5 | **Quellen & Vertrauen** | Liste der Datenquellen aus denen die Analyse generiert wurde, Konfidenz pro Sektion |

### Workflow — Hybrid AI + Manuell (Option A: AI-Draft → Sektions-Bestätigung)

- AM klickt "Analyse generieren"
- AI liest alle verfügbaren Datenquellen (siehe Datenquellen-Regel)
- Schlägt für jedes Feld einen Wert oder Text vor
- Vorschläge erscheinen mit **gelber Umrandung + "AI"-Badge** — exakt das gleiche Pattern wie der AI-Review-Flow im Briefing-Tab des Kandidaten
- AM reviewed sektionsweise, bestätigt ("✓ Sektion bestätigen") oder korrigiert
- Leere Felder muss AM manuell ausfüllen
- **Switch auf voll-AI später möglich** indem Bestätigungs-Schritt optional gemacht wird

### Score-Erhebung — Hybrid (Option B: AI gibt Range, Mensch setzt exakten Wert)

- AI analysiert Quellen und gibt pro Dimension eine **Tendenz**: "Niedrig 0–30 / Mittel 30–60 / Hoch 60–85 / Sehr hoch 85–100" plus Kurzbegründung
- AM setzt den exakten Score per Slider in der vorgeschlagenen Range
- **Phase 1.5/2 vorgemerkt:** Strukturierter Fragebogen-Modus (Option C) sobald Methodik vom Chef vorliegt — Backend `fact_account_culture_scores` mit Modus-Flag bereits vorbereitet

### Datenquellen für AI-Generierung
- Account-eigene Daten (History, Briefings, Mandate-Notizen, Scraping-Daten von Website/LinkedIn, vergangene Prozesse)
- **PLUS** öffentliche Web-Recherche (Google/Web für aktuelle News, Pressemitteilungen, Geschäftsberichte)
- Quellen werden in Sektion 5 "Quellen & Vertrauen" geloggt
- Web-Recherche bedeutet externe API-Calls — Datenschutz ok weil kein Personenbezug rausgeht (nur Account-Name als Suchbegriff)

### Trigger
- **Manuell** über "Analyse neu generieren" Button
- **Plus automatischer Refresh-Hint Banner** wenn signifikant neue Daten da sind (z.B. "Letzte Analyse vor 6 Monaten, 47 neue History-Einträge seitdem. Neu generieren?")

### Berechtigung
- Nur **Admin** und Mitarbeiter mit Rolle `Account_Manager` (über `bridge_mitarbeiter_roles`)
- Account_Manager-Rolle ist eine **zusätzliche** Rolle (nicht exklusiv) — z.B. Stefano kann Head_of UND Account_Manager sein

### Versionierung
- Pattern wie AI-Analyse-Subtab beim Kandidaten — jede Generierung = neue Version, Pfeil-Navigation, Diff-Ansicht für Phase 2

---

## TEIL 4: TAB 3 — KONTAKTE

### Grundprinzip — KRITISCH
**Jeder Kontakt MUSS auch als Kandidat im System erfasst sein.** `dim_account_contacts.candidate_id` ist effektiv NOT NULL. Die Tabelle wird konzeptionell zu einer **Bridge zwischen `dim_candidates_profile` und `dim_accounts`** mit kontaktspezifischen Zusatzfeldern.

### Schema-Vereinfachung
**Doppelte Personen-Felder auf `dim_account_contacts` werden entfernt** und leben nur noch auf `dim_candidates_profile`:
- ❌ first_name, last_name, salutation, email_1, email_2, phone_direct, phone_mobile, phone_private, linkedin_url, xing_url, birthday, function_id, disc_type

**Account-spezifisch verbleibend:** account_id, candidate_id, department, **org_function** (NEU 14.04.2026 — ersetzt `is_decision_maker`, `is_key_contact`, `is_champion`, `is_blocker`), contact_status, relationship_score, communication_preference, best_contact_time, do_not_contact, location_id, comment_short, onboarding_notes, last_contacted_date, last_reached_date, valid_from/to/is_current

**Hinweis:** Die 4 Subjektiv-Flags wurden entfernt (schlechte Pflege-Qualität). `org_function` ist objektiv und eindeutig (5 Codes aus `dim_org_functions` — vr_board/executive/hr/einkauf/assistenz).

### Layout — zwei Sektionen
- **Sektion 1: Aktive Kontakte** (`contact_status = 'Active'`) — als Tabelle, oben, default expanded
- **Sektion 2: Inaktive Kontakte (X)** (`Inactive` + `Left Company`) — collapsible, default collapsed

### Spalten in der aktiven Tabelle (Sales-fokussiert)
Name (mit Org-Funktions-Pill V/E/H/K/A) · Position · Department · Org-Funktion · Telefon · Email · Letzter Kontakt · Status · Aktionen

**Decision Level entfernt** (14.04.2026) — war redundant mit Position + Org-Funktion + Organigramm aus Tab 5.

### Filter & Sort
- **Filter-Chip-Gruppe** "Org-Funktion": Alle / VR-Board / Executive / HR / Einkauf / Assistenz (Multi-Select)
- Weitere Filter: Status, DNC-Flag
- Sortierbar nach: Name, Org-Funktion, Letzter Kontakt

Personen-Daten kommen via Join aus `dim_candidates_profile`. Im Kontakt-Drawer werden first_name/last_name/email/phone **read-only angezeigt** mit Hinweis "Stammdaten beim Kandidat pflegen → Kandidatenprofil öffnen".

### Erstellen / Auto-Match-Flow
- "+ Neuer Kontakt" Button → Drawer
- AM gibt erste Personen-Daten ein → System sucht Kandidaten-Match (Email exakt = stark, Vor+Nachname + Sparte/Function = mittel, nur Name = schwach mit Warnung)
- **Match gefunden:** AM bestätigt → Kontakt wird mit Kandidaten-FK angelegt
- **Kein Match (Hard Stop):** Drawer zeigt "Diese Person ist noch nicht als Kandidat erfasst. Bitte zuerst als Kandidat anlegen." mit Button "→ Als Kandidat anlegen" → öffnet vollen Kandidaten-Erstellungs-Flow → nach Speichern zurück in den Kontakt-Drawer mit vorbefülltem Match
- Begründung Hard Stop statt Mini-Form: voller Kandidaten-Flow verleitet zu vollständigerer Eingabe

### Bulk Import
**Phase 1 enthalten:**
- **Scraper-Vorschläge:** Wenn `team_page_url` gesetzt und Scraping aktiv, schlägt der Scraper neue Kontakte aus der Team-Page vor. AM bestätigt sektionsweise.
- **CSV-Import:** Drawer mit Datei-Upload, Spalten-Mapping (auto-detect von Header-Namen), Preview, Bulk-Insert mit Auto-Match-Suche pro Zeile
- **LinkedIn-Connections-Export:** Gleicher Flow wie CSV mit LinkedIn-spezifischem Mapping

### DO-NOT-CONTACT (Kontakt-Level)
- Roter Badge prominent im Kontakt-Drawer wenn `do_not_contact = true`
- Soft-Block auf 📞/✉ Aktionen → Warn-Dialog
- Audit-Log bei Override
- Pattern identisch zum Kandidaten

### Click-to-Call
- Click-to-Call funktioniert direkt in der Kontakt-Tabelle (nicht nur über Drawer)
- Routet via 3CX

### Verknüpfung Kontakt ↔ Standort
- Im Kontakt-Drawer: Dropdown "An welchem Standort?" → Auswahl aus den Standorten dieses Accounts (`fact_account_locations`)
- Optional, nur Pull-Richtung
- Im Standort-Tab keine umgekehrte "Wer ist hier" Liste (verworfen)

### Kontakt-Drawer — Struktur (NEU 14.04.2026)

Slide-in rechts, 540px breit, 4 Tabs:

| Tab | Inhalt |
|---|---|
| **1 · Stammdaten** | Personen-Daten read-only (Join aus `dim_candidates_profile`) mit Hinweis "beim Kandidaten pflegen" + Link · Account-Beziehung editierbar (Position, Department, Decision Level, Standort, Flags DM/KC/Champion/Blocker, Relationship Score 0–10, Kommunikations-Präferenz, Beste Kontaktzeit, Status, DNC) · Onboarding-Notizen |
| **2 · Kommunikation** | Timeline aller Interaktionen **nur mit diesem Account** (Calls/E-Mails/Meetings/LinkedIn) mit Filter-Chips (Alle / 📞 / ✉ / 🤝 / 💼) · Kennzahlen-Sektion: Total Interaktionen, Split, Ø Antwortzeit, Initialisierungs-Split (Arkadium vs. Kontakt), Sentiment-Trend |
| **3 · Prozesse** | Liste der Prozesse an denen dieser Kontakt beteiligt war (Briefing-Gesprächs-Partner, Interview-Teilnehmer, Final-Entscheider) — Cross-Nav zum jeweiligen Prozess |
| **4 · Notizen** | Interne Notizen chronologisch, + Hinzufügen-Button |

**Zugriff:** 
- 🕒 **Verlauf-Icon** in Row-Actions → öffnet Drawer direkt auf Tab 2 (Kommunikation)
- › **Details-Icon** → öffnet Drawer auf Tab 1 (Stammdaten)

**Drawer-Footer-Quick-Actions:** 📞 Anrufen · ✉ E-Mail · 🔔 Reminder · **Bearbeiten** (primary)

**Abgrenzung zu Tab 11 History:**
- Kontakt-Drawer-Tab-2 zeigt nur Interaktionen **dieses Kontakts** mit diesem Account
- Tab 11 Account-History zeigt alle Events **zum Account** (Mandate, Prozesse, Schutzfristen, System-Events) — mit optionalem Kontakt-Filter

---

## TEIL 5: TAB 4 — STANDORTE

### Layout
- **Container/Cards pro Standort** (kein Drawer, kein Tabellen-Layout)
- HQ visuell hervorgehoben mit gold-gerahmter Card + "HQ"-Badge
- "+ Neuer Standort" Button → neue leere Card am Ende mit aktivem Inline-Input

### Felder pro Card
- Bezeichnung
- Standort-Typ als Badge (HQ / Niederlassung — nur diese 2 Werte)
- Adresse (Strasse, PLZ, Ort, Kanton)
- Telefonnummer
- Email
- Pin-Icon → Google Maps (rechts oben, öffnet `https://maps.google.com/?q=<adresse>` in neuem Tab)

**NICHT enthalten:** Standort-Manager, Eröffnungsdatum, Bemerkungen, Mitarbeiteranzahl pro Standort, Koordinaten

### Edit-Pattern — Inline-Edit pro Feld (Pattern 1 / Quick-Edit)
- Klick auf ein Feld → wird zum Input → Blur/Enter speichert → ESC verwirft
- Auto-Save pro Feld
- Kein Drawer-Modus, kein Card-Edit-Modus

### HQ-Logik
- **Hart erzwungen:** Max. 1 HQ pro Account
- Auto-Switch beim Setzen: alter HQ wird auf "Niederlassung" umgestellt
- Toast-Feedback: "Hauptsitz übernommen, alter Hauptsitz auf Niederlassung umgestellt"
- Kein Confirm-Dialog (triviale Reorg, kein gefährlicher Edit)

### Geocoding
- **Phase 1:** Keine Koordinaten in DB. Pin öffnet Google Maps via Adress-String.
- **Phase 1.5 vorgemerkt:** Auto-Geocoding via Swisstopo/Nominatim sobald Karten oder Distanzberechnungen gebraucht werden

---

## TEIL 6: TAB 5 — ORGANISATION

Zwei Subtabs in lila #a78bfa (analog Assessment-Subtabs beim Kandidaten):
1. **Stellenplan** — Datenpflege
2. **Teamrad** — Visualisierung/Analyse darüber (read-only)

Dieser Tab ist der **Mutter-Ort** für beides — beim Kandidaten gibt es nur ein read-only Smart-Embed mit Teilausschnitt.

### Subtab 5a: Stellenplan

#### Datenmodell — neue zentrale Tabelle `fact_account_org_positions`
- position_title, function_id, location_id, department_name (text, account-frei)
- reports_to_position_id (self-FK)
- status: 'besetzt' / 'vakant' / 'geplant'
- candidate_id (NULL bei vakant/geplant) — wegen Kontakt=Kandidat-Regel
- linked_job_id (NULL wenn ARK kein Mandat hat)
- vacant_since, planned_for
- account_id, tenant_id, valid_from/to/is_current

#### Visualisierung — Hybrid (Option C)
- **Default: Indented List** (eingerückte Hierarchie wie Datei-Browser, Klick auf "▶" klappt Knoten auf/zu) — für die Pflege-Arbeit
- **Toggle "🌳 Org-Chart anzeigen":** Wechselt auf klassisches Tree-Org-Chart für Präsentation/Übersicht — read-only
- Edit nur in der Liste, Org-Chart ist reine Anzeige
- Library: `react-organizational-chart` oder `dagre-d3`

#### Status-Modell — Drei Stati mit Farb-Coding (Option A)
- **Besetzt** (grün): Stelle hat verknüpften Kandidaten, voller Eintrag
- **Vakant** (amber): Stelle existiert, niemand sitzt drauf, Card zeigt "🪑 Vakant seit DD.MM.YYYY"
- **Geplant** (blau, gestrichelt): Stelle ist budgetiert/geplant aber noch nicht offiziell ausgeschrieben (z.B. "ab Q3 2026")

#### Verknüpfung Vakanz ↔ Job ↔ Mandat — Bidirektional (Option C)
- Im vakanten Stellen-Drawer: "Mit Job verknüpfen" (Autocomplete-Suche) ODER "→ Job aus dieser Stelle erstellen" (öffnet Job-Drawer mit vorbefüllten Daten)
- Im Job-Drawer wird umgekehrt angezeigt: "Aus Stellenplan: [Position], [Standort]"
- Bidirektional editierbar — entweder Richtung kann der Auslöser sein

#### Pflege-Workflow — Hybrid (Option C)
- ARK pflegt als Hauptverantwortlicher (Account Manager und Researcher tragen ein basierend auf Briefings, LinkedIn-Recherche, Kunden-Calls)
- **Plus Scraper-Unterstützung:** Scraper läuft regelmässig auf `team_page_url` und LinkedIn und schlägt neue/geänderte Stellen vor → AM bestätigt sektionsweise
- **Phase 2 vorgemerkt:** Customer Portal für Self-Service durch Kunden

#### Abteilungen — Account-spezifisch frei (Option A)
- Jeder Account hat seine eigenen Abteilungen
- Im Stellen-Drawer: Autocomplete über die bestehenden Abteilungen dieses Accounts + "+ Neue Abteilung"
- Keine globalen Stammdaten — Cross-Account-Auswertung als Phase 1.5/2 vorgemerkt mit nachträglichem Mapping

### Subtab 5b: Teamrad

**Vollansicht** (im Kandidat ist nur das Smart-Embed). Struktur (14.04.2026 präzisiert):

**Sticky Control-Bar oben:** Team-Dropdown + Avatar-Stack + **`+ Kandidat`**-Button (Quellen: aktive Prozesse des Accounts ODER Freitext-Kandidaten-Suche) + Team-Member-Chip mit ×-Remove + Mit/Ohne-Kandidat-Toggle + **`Analyse generieren`** + **`Export`** + **`Team speichern als...`** + Team-Stats-Zeile.

**Sektionen (in dieser Reihenfolge — AI zuoberst):**

| # | Sektion | Inhalt |
|---|---|---|
| I | **AI Team-Analyse** | Harmonien / Spannungsfelder / Lücken / Empfehlung. Mit/Ohne-Kandidat-Summary |
| II | **DISC-Teamrad** | 60-Positionen-Scheelen-Modell als Wheel (identisch zur Kandidatenmaske) + D/I/S/C Team-Verteilung |
| III | **Burnout-Prävention (Relief)** | Stress-Resistenz pro Person, Warnung bei Score < 50 |
| IV | **Driving Forces (Motivatoren)** | 6 Scheelen-Polaritäten (`dim_motivator_dimensions`): Theoretisch · Ökonomisch · Ästhetisch · Sozial · Individualistisch · Traditionell |
| V | **Emotionale Intelligenz** | 5 Goleman-Dimensionen (`dim_eq_dimensions`): Selbstwahrnehmung · Selbstregulierung · Soziale Wahrnehmung · Soziale Regulierung · Motivation — als Tabelle Team-Ø vs. Kandidat mit Δ |
| VI | **ASSESS-Kompetenzen** | ASSESS 5.0-Heatmap auf Basis ASSESS-5.0-Kompetenzen (`dim_assess_competencies`, 26 Kompetenzen). **Profil-Selector**: 11 Standard-Profile (Geschäftsführung/Executive, HR Manager, Personalleiter, Abteilungsleiter, Teamleiter, Specialist, Sales Manager, Sales Professional, Leading Leaders/Others/Yourself) + Custom-Profil-Erstellung |
| VII | **Kandidat-Fit-Analyse** | Team-Fit-Score + Stärken / Risiken / Empfehlung |

**Terminologie fixiert:** EQ-Dimensionen nach Goleman-5 (nicht EQ-i 2.0). Motivatoren nach Scheelen 6-Polaritäten (nicht TTI Driving Forces linear). ASSESS 5.0 synonym mit ASSESS 5.0.

#### Team-Auswahl-Flow — Hybrid (Sub-Option C)
- **Default Modus:** Eigener Team-Builder im Teamrad-Subtab oben — Dropdown "Abteilung" lädt alle Stellen dieser Abteilung, oder Multi-Select-Autocomplete für ad-hoc Stellen-Auswahl
- **Plus Quick-Action im Stellenplan:** Multi-Select-Modus (Checkboxen) im Stellenplan-Subtab → AM wählt Stellen → Klick "Im Teamrad analysieren →" → Wechsel auf Teamrad mit dieser Auswahl als aktivem Team

#### Caching, Charts, Versionierung
- Charts = reine Berechnung (sofort)
- AI-Summaries pro Sektion = nachgelagert in einem LLM-Call (Skeleton → Text)
- "Mit / Ohne Kandidat" Toggle: beide Versionen beim Generieren gleichzeitig erstellt und gecacht → Instant-Switch
- Manueller "Generieren"-Klick nach Team-Zusammenstellung
- Banner bei Team-Änderungen
- **Versionierung:** Kein aktives Versioning. Snapshots bei jedem Export gespeichert → "Exportierte Berichte"

#### Export
- PDF + PPTX
- Varianten: "Nur Team" / "Team + Kandidat" / "Beide (Vorher/Nachher)"
- Kundenversion ARK CI

---

## TEIL 7: TAB 6 — JOBS & VAKANZEN

### Begriffsdefinition (KRITISCH)

| Begriff | Bedeutung |
|---|---|
| **Job** | Jede Position die ARK im System hat. Manuell erfasst oder vom Scraper kommend und bestätigt. ARK kann ein Mandat dafür haben oder nicht. |
| **Vakanz** | Ein **unbestätigter Scraper-Fund** — also ein Job-Kandidat aus der Career-Page-Erkennung. Sobald ein AM ihn bestätigt, wird er zu einem Job (= Status-Wechsel innerhalb derselben Lifecycle, keine Konvertierung zwischen zwei Tabellen). |

### Datenmodell — eine Tabelle, eine Lifecycle (Option A)
- `fact_vacancies` wird **deprecated und gelöscht**
- Alles in `fact_jobs` mit neuen Feldern:
  - `confirmation_status` ('Vakanz' / 'Bestätigt')
  - `source` ('Manuell' / 'Scraper')
  - `source_url` (für Scraper-Vakanzen, URL der Career-Page)
  - `detected_at` (für Scraper-Funde)
  - `rejected_at`, `rejected_by`, `rejection_reason` (wenn AM eine Vakanz ablehnt)
  - `owner_account_manager_id` FK → `dim_mitarbeiter` (mit Account_Manager-Rolle)
  - `linked_position_id` FK → `fact_account_org_positions`
- Migration: alle bestehenden Vakanzen werden mit `confirmation_status = 'Vakanz'` in `fact_jobs` übernommen

### Job-Status (unverändert aus Schema)
Open / Filled / On Hold / Cancelled. **Kein Pre-Briefing-Status.**

### Layout — eine Tabelle mit Filter-Chips (Sub-Option A)
- Default-Filter: "Aktiv" (alle bestätigten Jobs mit Status Open/On Hold)
- Chips: "Alle / Aktiv / 🆕 Vakanzen (Scraper, unbestätigt) / Geschlossen (Filled/Cancelled)"
- Vakanz-Zeilen visuell gekennzeichnet (amber Hintergrund + 🆕 Badge) auch in der "Alle"-Ansicht
- Confirmation-Action prominent in Vakanz-Zeilen: **✓ Bestätigen** und **✗ Ablehnen** Button direkt in der Zeile

### Owner = Account Manager (NICHT Candidate Manager)
- Der Job gehört zum Account, der Account hat einen AM, also gehört der Job dem AM
- `fact_jobs.owner_account_manager_id` FK → `dim_mitarbeiter` mit Validierung dass die Person die `Account_Manager`-Rolle hat (über `bridge_mitarbeiter_roles`)
- Getrennt von `dim_accounts.account_manager_id` (kann gleich sein, muss aber nicht — Account-AM kann einzelne Jobs an anderen AM delegieren)
- CM lebt nicht am Job, sondern an `fact_process_core` pro Prozess

### Bestätigungs-Flow für eine Vakanz (Option B)
- "✓ Bestätigen" öffnet Drawer mit Scraper-Daten als Vorschlag + Pflichtfeldern:
  - Owner Account Manager (Pflicht)
  - Honorar-Modell (oder "kein Mandat / Erfolgsbasis")
  - Optional: Briefing-Termin geplant
- AM füllt aus → speichert → Status wechselt von "Vakanz" auf "Bestätigt", Job-Status auf "Open"
- Kein Pre-Briefing-Zwischenschritt

### Manuell erfasst = direkt Job (Option A)
- Vakanzen entstehen ausschliesslich aus dem Scraper
- Manuelle Erfassung legt sofort einen bestätigten Job an (`source = 'Manuell'`, `confirmation_status = 'Bestätigt'`)
- Klare Definition: Vakanz = Scraper + unbestätigt

### Vakanz-Lifecycle bei Nicht-Bestätigung
- **Keine Auto-Schliessung**
- AM muss aktiv entscheiden: Bestätigen oder Ablehnen
- Bei Ablehnen: optional Grund ("kein ARK-Fokus", "zu junior", "extern besetzt") → `rejected_at`, `rejected_by`, `rejection_reason` werden gefüllt
- Abgelehnte Vakanzen bleiben in der DB für KPI-Tracking

### Spalten in der Job-Tabelle

| Spalte | Inhalt |
|---|---|
| Titel | "Bauführer Tiefbau" |
| Function | Badge |
| Standort | Aus location_id |
| Status | Open / On Hold / Filled / Cancelled |
| Quelle | Manuell / Scraper |
| Owner AM | Initialen + Name (kein Foto) |
| Pipeline | "12 Kandidaten, 3 in Interview" |
| Honorar | Target / Taskforce / Time / Erfolgsbasis |
| Erstellt am | Datum |
| Aktionen | Drawer öffnen / Vollansicht öffnen / bei Vakanzen: ✓ Bestätigen + ✗ Ablehnen |

### Mandate-Gruppierung (Option C)
- Default: flache Liste (häufigster Use-Case bei Erfolgsbasis)
- Toggle "Nach Mandat gruppieren": gruppiert nach `mandate_id`, Mandat-Header → zugehörige Jobs (für Target/Taskforce-Sicht)

---

## TEIL 8a: TAB 7 — MANDATE

**Status:** Fragen 8.1–8.3 beantwortet (Session 2026-04-12). Fragen 8.4–8.6 offen.

### Bekannte Vorgaben aus Schema, Freeze und Factsheet
- **Typen:** Target (Exklusivmandat), Taskforce (Team-/Standortaufbau), Time (Slot-basiert)
- **Status:** Entwurf → Aktiv / Abgelehnt → Abgeschlossen / Abgebrochen
- **Aktivierung:** Status-Wechsel Entwurf → Aktiv erfolgt automatisch wenn Dokument mit Label "Mandatsofferte unterschrieben" hochgeladen wird
- **KPIs aus Schema:** Ident Target/Actual, Call Target/Actual, Shortlist-Trigger (konfigurierbar) — nur bei Target
- **Taskforce:** Jede Position innerhalb des Mandats = eigener Job, Abschlusszahlung je Position individuell
- **Time:** Slot-basiert, min. 2 Slots, Wochenfee degressiv, monatlich abgerechnet
- **Konditionen** werden pro Mandat gepflegt (kein eigener Tab)
- **Zahlungsziel:** Default 10 Tage

### 8.1 Layout — ENTSCHIEDEN: Hybrid (Option C)

Entwürfe als **amber Banner/Cards über** der Tabelle (Action-Items, AM muss sie aktivieren). Darunter: **Tabelle mit Filter-Chips** (Aktiv / Abgeschlossen / Abgebrochen / Alle). Konsistent mit dem Vakanz-Banner-Pattern aus Tab 6.

Begründung: Entwürfe sind "To-Dos", aktive Mandate sind die tägliche Arbeit — zwei verschiedene Mindsets, visuell getrennt.

### 8.2 Entwurf erstellen — ENTSCHIEDEN: Drawer mit dynamischen Sektionen (Option C)

"+ Neues Mandat" → Drawer mit **Typ-Auswahl oben** (Target / Taskforce / Time). Typ-Wechsel blendet die passenden Sektionen ein/aus. Pflichtfelder je nach Typ, alles in einem Drawer, kein Wizard.

Begründung: Konsistent mit dem Rest des Systems (Drawers überall), typ-aware. Wizard wäre Overhead für ein Team das täglich Mandate erfasst.

### 8.3 Konditionen-Modell — ENTSCHIEDEN: Strukturiert + Freitext (Option C, typ-spezifisch)

#### Target (Exklusivmandat) — Felder im Drawer

| Feld | Typ | Default/Hinweis |
|------|-----|-----------------|
| **Pauschale (CHF)** | Zahl (Pflicht) | Fixbetrag. 35-40% vom Jahresgehalt als Richtwert (Tooltip) |
| *Zahlung 1/2/3 (CHF)* | Berechnet (read-only) | Pauschale ÷ 3, angezeigt als Vorschau |
| **Shortlist-Trigger** | Dropdown (2 CVs / 3 CVs / 4 CVs) | Default: 3 |
| **Garantiezeit** | Dropdown (3 Monate / 4 / 5 / 6) | Default: 3 Monate |
| *Garantieleistung* | Read-only Label | "Ersatzbesetzung" (immer, kein Toggle) |

#### Taskforce — Felder im Drawer

| Feld | Typ | Default/Hinweis |
|------|-----|-----------------|
| **Monatsfee (CHF)** | Zahl (Pflicht) | Fix-Betrag/Monat |
| **Positionen** | Sub-Tabelle | Pro Position: Titel, Function, Success Fee (CHF) — individuell |
| **Garantiezeit** | Dropdown (3 / 4 / 5 / 6 Monate) | Default: 3 |
| *Garantieleistung* | Read-only Label | "Ersatzbesetzung" |

#### Time — Felder im Drawer

| Feld | Typ | Default/Hinweis |
|------|-----|-----------------|
| **Paket** | Dropdown (Entry 2 Slots / Medium 3 Slots / Professional 4 Slots) | — |
| *Slots* | Berechnet aus Paket | 2 / 3 / 4 |
| *Preis/Slot/Woche (CHF)* | Berechnet aus Paket | 1'950 / 1'650 / 1'250 (aktuell rabattiert) |
| **Dauer (Wochen)** | Zahl (Pflicht) | — |
| *Monatlicher Betrag* | Berechnet (read-only) | Slots × Preis × 4.33 Wochen/Monat |
| **Kündigungsfrist** | Read-only | "3 Wochen schriftlich" |

#### Für alle Typen

| Feld | Typ | Default |
|------|-----|---------|
| **Zahlungsziel (Tage)** | Zahl | 10 |
| **Spesen-Pauschale (CHF)** | Zahl | 0 |
| **Bemerkungen** | Freitext | Für Sonderfälle (Split-Fee, Rahmenvertrag-Rabatt, etc.) |

### Offene Fragen (noch zu beantworten)

### 8.4 KPI-Targets-Pflicht — ENTSCHIEDEN: Hard-Pflicht bei Aktivierung (Option C, verschärft)

- Beim Erstellen (Entwurf): KPIs optional — Entwurf darf ohne Targets existieren
- Beim Übergang Entwurf → Aktiv (Dokument "Mandatsofferte unterschrieben" hochgeladen): **Validierungs-Dialog**
- **Hard-Pflicht (alle drei):**
  - Ident Target (Anzahl zu identifizierender Kandidaten)
  - Call Target (Anzahl Calls)
  - Shortlist-Trigger (Anzahl CVs die 2. Zahlung auslöst)
- Falls eines fehlt: Aktivierung blockiert → "Bitte alle KPI-Targets setzen bevor das Mandat aktiviert wird"
- AM füllt nach → Speichern → Aktivierung durchgeführt
- **Gilt nur für Target-Mandate.** Taskforce und Time haben keine Ident/Call/Shortlist-KPIs.

### 8.5 KPI-Tracking — ENTSCHIEDEN: Mini-Ampel in Liste + Detail im Drawer (Option C)

**In der Tabellenzeile:** 3 Ampel-Dots nebeneinander (Idents / Calls / Shortlist)
- 🟢 ≥80% vom Target
- 🟡 40–79%
- 🔴 <40%
- Tooltip on hover: z.B. "Idents: 34/50 (68%)"

**Im Drawer (Tab Übersicht):** Volle Progress-Bars mit Zahlen und Prozent.

Schwellwerte (80/40) initial hardcoded, **Phase 1.5/2 vorgemerkt:** konfigurierbar via `dim_automation_settings`.

Nur bei Target-Mandaten sichtbar. Taskforce und Time zeigen stattdessen andere Metriken (Taskforce: Positionen besetzt/offen, Time: Slots aktiv/pausiert).

### 8.6 Drawer-Tabs — ENTSCHIEDEN: 5 Tabs (Option C)

| # | Tab | Inhalt |
|---|-----|--------|
| 1 | **Übersicht** | Typ-Badge, Status, Konditionen-Zusammenfassung, KPI-Fortschritt (Progress-Bars), Garantiezeit, AM, Researcher |
| 2 | **Jobs** | Verknüpfte Jobs als Liste. Taskforce: mehrere Zeilen mit individueller Success Fee. Time: Slots mit Position-Zuordnung |
| 3 | **Pipeline** | Kompakte Longlist-Zusammenfassung als Zahlen-Kacheln (Research: 12 · CV Expected: 4 · CV IN: 3 · GO: 1). Kein Kanban im Drawer. Link "→ Vollständige Longlist öffnen" → Vollseite |
| 4 | **Billing** | Zahlungsplan-Tabelle: Target = 3 Zeilen (Pauschale÷3), Taskforce = Monatsfee + Success pro Position, Time = Wochen-Abrechnung. Status bezahlt/offen pro Zeile |
| 5 | **Dokumente** | Mandatsofferte, Reports, Verträge |

- History entfällt im Drawer (lebt auf der Vollseite)
- "→ Vollansicht öffnen" Link prominent oben rechts im Drawer-Header

---

## TEIL 8b: TAB 8 — ASSESSMENTS (v0.2, aktualisiert v0.3 für Typisierte Credits)

Alle Assessment-Aufträge zu diesem Account — mandatsbezogen (via Mandat-Option IX) und eigenständig (ohne Mandat).

### Datenmodell

```sql
fact_assessment_order (
  id,
  account_id,            -- immer gesetzt (Kunde, der bezahlt)
  candidate_id,           -- immer gesetzt (getestete Person; neu angelegt wenn noch nicht im System)
  mandat_id,             -- nullable (nur bei mandatsbezogener Durchführung)
  package_type: 'diagnostik_only' | 'full_package' | 'executive_summary_only',
  price_chf,             -- case-by-case pauschal
  partner: 'SCHEELEN' | 'internal' | ...,
  status: 'offered' | 'ordered' | 'scheduled' | 'completed',  -- Korrektur 14.04.2026: 'invoiced' entfernt (ist Billing-Status, nicht Auftrag-Status)
  ordered_at,
  signed_document_id,    -- FK zum Offerten-PDF (unterschrieben)
  invoice_id             -- FK zu fact_assessment_billing
)

fact_assessment_billing (
  id,
  assessment_order_id,
  billing_type: 'full' | 'deposit' | 'final' | 'expense',
  amount_chf,
  due_date,
  invoice_id,
  paid_at,
  status: 'pending' | 'invoiced' | 'paid' | 'overdue'
)
```

### Layout (v0.3)

**Top-Banner-Reihe (zwei KPI-Banner):**

1. **Teamrad-Abdeckung:**
   ```
   📊 Teamrad-Abdeckung: 12 von 47 Mitarbeitenden haben ein Assessment. [→ Teamrad ansehen]
   ```

2. **Credits-Übersicht (NEU v0.3, Nachbearbeitungs-Punkt aus 13.04.):**
   ```
   🎯 Credits gekauft · verbraucht · offen (aggregiert über alle Aufträge dieses Accounts):

   MDI      ████████░░ 3/4 verbraucht · 1 offen
   Relief   ██████████ 2/2 verbraucht · 0 offen
   ASSESS 5.0 ████░░░░░░ 1/3 verbraucht · 2 offen
   DISC     ░░░░░░░░░░ 0/1 verbraucht · 1 offen

   Total: 10 Credits (CHF 24'500) · 6 verbraucht · 4 offen
   ```
   Live-Aggregation aus `fact_assessment_order_credits` WHERE order.account_id = X.

- **Filter-Chips unter den Bannern:** Alle / Mandatsbezogen / Eigenständig / In Progress / Completed / **Typ (Multi-Select, NEU v0.3)**
- **Tabelle** mit allen Assessments — zusätzliche Spalte "Credits-Mix" (z.B. "1 MDI · 1 Relief · 1 ASSESS 5.0")

### Assessment beauftragen — Flow

Trigger: Header Quick-Action "🧭 Assessment beauftragen" oder Button "+ Neues Assessment" in Tab 8.

**Drawer-Schritte (v0.3 typisierte Credits):**
1. **Package-Name** (optional, z.B. "Führungs-Check 2026-Q2")
2. **Credits-Zusammenstellung** (Kern, NEU v0.3): Multi-Row-Editor
   - Pro Zeile: Typ-Dropdown (aus `dim_assessment_types`) + Quantity + Einzelpreis (optional)
   - "+ Weiteren Typ hinzufügen" Button
   - Beispiel: "1× MDI @ CHF 2'500 · 1× Relief @ CHF 1'800 · 1× ASSESS 5.0 @ CHF 3'200"
3. **Mandats-Verknüpfung** (optional):
   - Radio: "Mandatsbezogen" (Dropdown aktive Mandate) / "Eigenständig"
   - Bei Mandatsbezogen: Auto-Flag als Option IX am Mandat
4. **Kandidaten zuweisen** (optional — kann später erfolgen): Multi-Select pro Typ
5. **Gesamtpreis** — auto-berechnet aus Einzel-Credits ODER manuell überschreibbar (Pauschal-Modus)
6. **Offerte generieren** → PDF aus `Vorlage_Offerte Diagnostik & Assessment.docx` mit Credits-Breakdown
7. **Upload unterschriebene Offerte** → `status = 'ordered'`, `signed_document_id` gesetzt
8. **Auto-Aktionen:**
   - `fact_assessment_order_credits` Inserts pro Typ-Zeile
   - `fact_history` Eintrag am Account + bei jedem beteiligten Kandidaten
   - Bei Mandatsbezug: `fact_mandate_option` mit `option_type = 'IX_assessment'` + `assessment_order_id` FK
   - Billing-Rechnungszeile (`billing_type = 'full'`, sofort bei `ordered` fällig — siehe Assessment-Interactions v0.2)

### Status-Wechsel (Order-Level)

Order-Status kennt kein `invoiced` (siehe Assessment-Schema v0.3 + Database §14.3). Rechnungs-Bezahl-State lebt auf `fact_assessment_billing.status`.

| Von | Nach | Trigger |
|-----|------|---------|
| offered | ordered | Unterschriebene Offerte hochgeladen |
| ordered | partially_used | Erster Credit verbraucht (Kandidat-Assessment durchgeführt) |
| partially_used | fully_used | Letzter Credit verbraucht |
| ordered / partially_used / fully_used | cancelled | Auftrag storniert |

Billing-Trigger: Rechnung fällig **sofort bei `ordered`** (Credits-Modell, nicht erst bei `completed`). Auto-Insert `fact_assessment_billing` mit `status='pending'`. Billing-Status-Flow (pending → invoiced → paid → overdue) ist unabhängig vom Order-Status.

### Click-Verhalten

- Klick auf Zeile → Drawer (540px) mit Assessment-Übersicht + Package, Kandidat-Link, Status-Timeline
- "→ Vollansicht öffnen" → `/assessments/[id]` (eigene Detailseite)

### Cross-Navigation

- **Von Mandat (Tab 7 → Mandat-Detailseite → Option IX):** Link auf zugehöriges Assessment öffnet direkt Assessment-Detailseite
- **Von Kandidat-Assessment-Tab:** Link "Teil von Auftrag XYZ" → Assessment-Detailseite
- **Zurück zum Account:** Assessment-Detailseite hat Breadcrumb → Account

### Berechtigung

- **Lesen:** alle Rollen (analog Mandat-Lesen)
- **Beauftragen / Bearbeiten:** AM (Owner des Accounts) + Admin + Admin
- **Als bezahlt markieren:** AM + Admin + Backoffice

### Empty-State

> "Noch keine Assessments für diesen Account. Assessments können entweder eigenständig beauftragt oder über ein Mandat (Option IX) ausgelöst werden.
> [🧭 Assessment beauftragen]"

### Phase 1.5 / Phase 2

| Feature | Phase |
|---------|-------|
| Multi-Kandidat-Batch-Assessments als einzelnem Auftrag | 1.5 |
| Auto-Terminvorschlag an Kandidat (Kalender-Integration) | 2 |
| Partner-API-Integration SCHEELEN | 2 |

---

## TEIL 8c: TAB 9 — SCHUTZFRISTEN (v0.2, erweitert v0.3: Gruppen-Scope + AM-Claim)

Aggregierte Matrix aller aktiven `fact_protection_window`-Einträge zu diesem Account. Zentrale Arbeitsumgebung für Umgehungs-/Direkteinstellungs-Fälle.

### Datenmodell (v0.3 mit Gruppen-Scope)

```sql
fact_candidate_presentation (
  id, candidate_id, account_id, mandate_id, process_id,
  presentation_type: 'email_dossier' | 'verbal_meeting' | 'upload_portal',  -- dim_presentation_types §10c
  presented_at, presented_by
)

fact_protection_window (
  id, presentation_id, candidate_id,
  scope ENUM('account','group') DEFAULT 'account',   -- NEU v0.3
  account_id NULL,       -- wenn scope='account'
  group_id NULL,         -- wenn scope='group' (aus Firmengruppen-Integration)
  starts_at, base_duration_months DEFAULT 12,
  extended boolean, expires_at,
  info_requested_at, info_received_at,
  status: 'active' | 'expired' | 'honored' | 'claim_pending' | 'paid',
  CHECK ((scope='account' AND account_id IS NOT NULL AND group_id IS NULL)
      OR (scope='group'   AND group_id   IS NOT NULL AND account_id IS NULL))
)
```

### Layout (v0.3: Query-Scope erweitert)

**Scope der angezeigten Einträge (NEU v0.3):**
Das Tab zeigt **beide Scope-Typen**:
1. `fact_protection_window WHERE scope='account' AND account_id = <current_account.id>`
2. `fact_protection_window WHERE scope='group' AND group_id = <current_account.group_id>` (falls Account in Gruppe)

Gruppen-Level-Einträge sind **rechtlich relevanter** (weiter gefasst) und bekommen eine spezielle Darstellung.

**Matrix-Tabelle mit Filter-Bar oben:**

| Filter | Werte |
|--------|-------|
| **Scope (NEU v0.3)** | Alle / Nur Account-Level / Nur Gruppen-Level |
| Status | Active / Expired / Honored / Claim Pending / Paid / Alle |
| Zeitraum (Ablauf) | Date-Range oder "< 30 Tage", "30–90 Tage", "> 90 Tage" |
| Extended | Ja / Nein / Alle |
| Mandat | Dropdown (bei Klick aus Tab 7 → Auto-Filter) |

**Spalten:**
- **Scope-Badge (NEU v0.3):** "🏢 Account" (blau) oder "🏛 Gruppen-Schutzfrist" (gold, für `scope='group'`)
- Kandidat (Foto + Name → Link `/candidates/[id]`)
- Vorgestellt am (`presentation_at`)
- Vorstellungs-Typ (email_dossier / verbal_meeting / upload_portal — dim_presentation_types §10c)
- Verknüpftes Mandat (Link zu Tab 7 oder `/mandates/[id]`)
- Status-Badge
- Ablaufdatum (`expires_at`)
- Extended? (Ja + Icon oder Nein)
- Letzter Kontakt zu Kandidat (aus History)
- Aktionen (Drawer / Claim / Info-Request)

**Info-Panel bei Gruppen-Level-Einträgen (NEU v0.3):**
Über der Tabelle (wenn Account in Gruppe): *"🏛 Dieser Account ist Teil der Firmengruppe [Name]. Zusätzlich zu Account-Level-Schutzfristen werden auch Gruppen-weit geltende Schutzfristen (von Schwesterngesellschaften) angezeigt. [→ Firmengruppe ansehen]"*

### Claim-Workflow (KRITISCH)

Wenn der [[scraper]] erkennt, dass ein Kandidat bei diesem Account angestellt ist UND eine aktive Schutzfrist besteht:

1. **Auto-Event:** `protection_window.status = 'claim_pending'`
2. **Banner im Header** (siehe TEIL 1): "⚠️ X Claim-Fälle ausstehend"
3. **Row in Tab 9 erhält rote Umrandung + Alert-Icon**
4. **Klick auf Row → Claim-Drawer:**

   ```
   Claim-Fall: Max Muster bei Volare Group AG
   ─────────────────────────────
   Vorgestellt am: 12.03.2025 (vor 13 Monaten)
   Schutzfrist läuft bis: 12.03.2026 (active) oder 12.07.2026 (extended)
   Scraper-Erkenntnis: Max ist seit 01.04.2026 bei Volare angestellt
   (Quelle: LinkedIn Position Update)
   ─────────────────────────────
   Aktionen:
   [📧 Info-Request senden]  [💰 Claim stellen]  [⊘ Abschliessen ohne Claim]
   ```

### Info-Request Flow (10-Tage-Fenster)

**Klick auf "📧 Info-Request senden":**
1. Email-Template öffnet sich mit vorgefülltem Text (aus [[agb-arkadium]] Informationspflicht-Klausel)
2. Empfänger: Hauptansprechpartner des Accounts (AGB-Kontakt oder AM-Kontakt)
3. Nach Versand: `info_requested_at = now` gesetzt
4. **Countdown-Anzeige** im Row: "Noch X Tage bis Auto-Extension auf 16 Monate"
5. Nach 10 Tagen ohne `info_received_at`:
   - `extended = true`
   - `expires_at = original_expires_at + 4 months`
   - Event `protection_window_extended` im History
   - Banner im Row: "🛡 Schutzfrist automatisch auf 16 Monate verlängert"
6. Bei Antwort vor Ablauf: AM markiert manuell "Antwort erhalten" → `info_received_at = now`, kein Auto-Extend

### Claim stellen Flow (v0.3, präzisiert 14.04.)

**Berechtigung (Entscheidung #5):** AM (Owner des Accounts) kann Claim alleine stellen — kein Admin-Gate. Audit-Log obligatorisch.

**Drei Billing-Fälle** (gemäss Mandat-Interactions v0.3 TEIL 10):

| Fall | Bedingung | Honorar-Basis |
|------|-----------|--------------|
| **X** | Mandats-Ursprung + identische Position | **Rest-Mandatssumme** (Gesamt − bezahlte Stages) |
| **Y** | Mandats-Ursprung + andere Position (gleiche Firma ODER Schwester in Gruppe) | **Staffel** auf neuen Jahreslohn |
| **Z** | Erfolgsbasis-Ursprung (kein Mandat) | **Staffel** auf neuen Jahreslohn |

**Rechnungs-Empfänger (Peter-Klarstellung 14.04.):** Immer die **tatsächlich einstellende Firma** (aus Scraper-Fund), niemals die Holding — auch bei Gruppen-Schutzfrist-Match.

**Klick auf "💰 Claim stellen":**

1. **Position-Check-Drawer (NEU v0.3):**
   - Zeigt nebeneinander: Ursprungs-Mandats-Position (falls Mandat-Ursprung) + neue Position (aus Scraper-Fund oder manuellem Eintrag)
   - AI-basierter Match-Score (Fuzzy auf Job-Title + Function + BKP-Gewerk)
   - AM bestätigt **welcher Fall zutrifft (X / Y / Z)** — Override jederzeit möglich
   - Falls unklar: Default "Y — andere Position" (konservativer, Staffel)

2. **Honorar-Drawer (je nach Fall):**
   - **Fall X:** Vorschau "Restbetrag Mandat: CHF [Gesamt] − [bezahlt] = [Rest]"
   - **Fall Y/Z:** Gehalt-Eingabe (Default: wenn bekannt aus Scraper/Placement) → Staffel-Anwendung (21/23/25/27% automatisch je Gehalts-Schwelle)
   - AM kann Betrag überschreiben (Audit-Log)
   - Vorschau Rechnungsbetrag netto + MwSt + brutto

3. **Empfänger-Bestätigung:** Rechnungs-Empfänger = einstellende Firma. Bei Gruppen-Schutzfrist zeigt Drawer: *"Rechnung geht an [Gesellschaft X] (nicht an Holding [Gruppe]). OK?"*

4. "Rechnung erstellen" → Claim-Rechnung generiert aus Template:
   - Fall X: `Vorlage_Rechnung_Mandat_Direkteinstellung-Claim.docx` (zu erstellen in Nachbearbeitung)
   - Fall Y/Z: `Vorlage_Rechnung_Erfolgsbasis-Direkteinstellung-Claim.docx` (zu erstellen)

5. `protection_window.status = 'claim_pending'` → `'paid'` nach Zahlung (manuell markieren)

6. Events:
   - `claim_invoiced` (Account + Kandidat)
   - `claim_context_determined` mit `context_case` ∈ {X, Y, Z} — Audit-Trail für Nachvollziehbarkeit

### Abschliessen ohne Claim Flow

**Klick auf "⊘ Abschliessen ohne Claim":**
1. Confirm-Dialog: "Kulanz-Entscheidung dokumentieren?"
2. Pflichtfeld: Begründung (Textarea)
3. `status = 'expired'` (oder neu `'waived'` falls gewünscht)
4. Event mit Begründung in History

### Manueller Eintrag

"+ Schutzfrist manuell anlegen" Button — falls Vorstellung ausserhalb des normalen Flows lief (z.B. Legacy-Daten). Pflichtfelder: Kandidat, Vorstellungs-Datum, Typ, Mandat (optional), starts_at.

### Empty-State

> "Keine aktiven Schutzfristen für diesen Account."

### Berechtigung (v0.3 aktualisiert, Entscheidung #5)

| Aktion | AM (Owner) | AM (andere) | Admin/Admin | Backoffice |
|--------|-----------|-------------|---------------|-----------|
| Matrix lesen (Account + Gruppen-Scope) | ✅ | ✅ | ✅ | ⚠ |
| Info-Request senden | ✅ | ❌ | ✅ | ❌ |
| **Claim stellen** | ✅ **(alleine, kein Gate)** | ❌ | ✅ | ❌ |
| Claim-Rechnung erstellen | ✅ | ❌ | ✅ | ✅ |
| Abschliessen ohne Claim | ✅ | ❌ | ✅ | ❌ |
| Manueller Eintrag | ✅ | ❌ | ✅ | ❌ |
| Gruppen-Scope-Eintrag editieren | ❌ | ❌ | ✅ | ❌ |

**Änderung v0.3:** Claim kann AM alleine stellen (früher Admin-Freigabe). Audit-Log obligatorisch.

### Phase 1.5 / Phase 2

| Feature | Phase |
|---------|-------|
| Claim-Rechnungs-Template | 1.5 |
| Bulk-Info-Requests für mehrere Kandidaten pro Account | 1.5 |
| Scraper-Monitoring-Frequenz konfigurierbar | 2 |
| Automatische Claim-Empfehlung durch AI | 2 |
| 12-Monats-Speicherfrist-Detection beim Kunden (Info noch vorhanden?) | 2 |

---

## TEIL 9: TAB 10 — PROZESSE

Analog Kandidat Tab 6 (Prozesse), aber aus **Account-Perspektive** = alle Kandidaten die an diesen Kunden vorgestellt wurden/werden.

### Ansicht
- **Liste als Default** (Tabelle), Kanban als optionaler Toggle (rein visuell, kein D&D)
- Sortierbar pro Spalte

### Spalten

| Spalte | Inhalt | Unterschied zu Kandidat |
|--------|--------|------------------------|
| **Kandidat** | Name + Foto-Thumbnail | NEU (beim Kandidaten nicht nötig) |
| Job | Position-Titel | Identisch |
| Mandat | Mandat-Name oder "Erfolgsbasis" Badge | Identisch |
| Stage | Exposé → ... → Platzierung | Identisch |
| Status | Open / On Hold / Rejected / Placed etc. | Identisch |
| Nächstes Interview | Datum + Typ | Identisch |
| **CM** | Candidate Manager (Initialen) | NEU (beim Kandidaten nicht nötig) |
| Erstellt am | Datum | Identisch |

### Filter-Chips
- **Aktiv** (Default) / Placed / Abgelehnt / Alle
- **Mandat-Filter:** Dropdown/Chips pro Mandat (bei Klick aus Tab 7 Mandate → automatisch gefiltert auf dieses Mandat)

### Prozess erstellen
- **Kein manuelles Erstellen** — Prozesse entstehen automatisch aus dem Jobbasket (identisch zum Kandidaten)

### Klick-Verhalten
- **Klick auf Prozess → Drawer (540px)** mit:
  - Stage-Pipeline-Visualisierung
  - Kandidat-Summary (Name, Foto, aktuelle Position)
  - Nächstes Interview (Datum, Typ)
  - Honorar-Modell + berechneter Betrag
  - Letzte Aktivität (3 neueste History-Einträge)
  - Status-Badge
- Button "Vollansicht öffnen →" → `/processes/[id]`

### Cross-Navigation Tab 7 → Tab 8
- Im Mandate-Drawer (Tab 7) im "Pipeline"-Tab: Klick auf eine Stage-Kachel → wechselt zu Tab 8 mit Filter auf dieses Mandat + diese Stage
- Shortcut für den AM: "Wie viele Kandidaten sind im Interview bei Mandat X?"

---

## TEIL 10: TAB 11 — HISTORY

Analog Kandidat Tab 7 (History). Gleiche Mechanik, account-spezifischer Scope.

### Was ist identisch zum Kandidaten
- Neuer Eintrag via Drawer (ActivityType Pflicht, Notiz optional, Verknüpfung auto-suggested)
- 3CX-Integration: automatische History-Einträge für alle Calls
- Email-Integration: automatische Sync + Matching
- Klassifizierung: confirmed / ai_suggested / pending / manual
- Transkript + AI-Summary + Mobile Nachbearbeitung
- Drawer-Tabs kontextabhängig (Übersicht, Transkript, AI-Summary, Email, Reminders)

### Was ist anders (Account-Perspektive)

| Aspekt | Kandidat Tab 7 | Account Tab 9 |
|--------|---------------|---------------|
| **Scope** | Alle Aktivitäten zu diesem Kandidaten | Alle Aktivitäten zu diesem Account |
| **ActivityTypes** | Kandidaten-relevante gefiltert | Account-relevante gefiltert |
| **Zusätzliche ActivityTypes** | — | "Mandatsbesprechung", "Quartals-Review", "AGB Verhandlungen", "AGB bestätigt", "Account-Besuch", "Pricing-Verhandlung" |
| **Verknüpfung** | Prozess/Job/Mandat | Prozess/Job/Mandat/Kontakt (Welcher Ansprechpartner?) |
| **Filter** | Nach Kategorie, Zeitraum | Zusätzlich nach Kontaktperson, Mandat |
| **Spalte "Kontakt"** | — | Welcher Ansprechpartner beim Account war involviert |

### Auto-Match Kontaktperson
- Bei 3CX-Calls: System matched Telefonnummer gegen `dim_account_contacts` → Kontaktperson wird automatisch verknüpft
- Bei Email: Matching gegen Kontakt-Email-Adressen
- Manuell: Dropdown "Ansprechpartner" im History-Drawer

---

## TEIL 11: TAB 12 — DOKUMENTE

Analog Kandidat Tab 8 (Dokumente). Gleiche Upload-Mechanik, account-spezifische Dokumenttypen.

### Was ist identisch zum Kandidaten
- Drag & Drop + Datei-Dialog Upload
- Dokumententyp ist Pflicht nach Upload
- Download, Preview (PDF/Bild-Viewer im Drawer)
- Versionierung (gleicher Typ → neue Version, alte archiviert)

### Was ist anders (Account-Perspektive)

| Aspekt | Kandidat Tab 8 | Account Tab 10 |
|--------|---------------|----------------|
| **Dokumenttypen** | Original CV, ARK CV, Abstract, Exposé, Diplom, Arbeitszeugnis, Schriftliche GO, Assessment, Foto, Sonstiges | **Mandatsofferte unterschrieben**, Vertrag, AGB, Quartals-Report, Mandat-Report, Organigramm, Firmen-Präsentation, Sonstiges |
| **Gate-Check** | Gate-1 Checkliste (4 Pflicht-Dokumente) | Kein Gate-Check (kein Pendant) |
| **Trigger** | — | Upload "Mandatsofferte unterschrieben" → Mandat-Status Entwurf → Aktiv |
| **Gruppierung** | Nach Typ | Nach Typ ODER nach Mandat (bei mehreren Mandaten übersichtlicher) |

### Mandats-Verknüpfung
- Beim Upload: optionales Dropdown "Zu welchem Mandat?" → verknüpft Dokument mit `fact_mandate`
- Bei "Mandatsofferte unterschrieben": Mandat-Dropdown wird Pflicht (System muss wissen welches Mandat aktiviert wird)

---

## TEIL 12: TAB 13 — REMINDERS

Analog Kandidat Tab 10 (Reminders). Gleiche Mechanik, account-spezifische Verknüpfungen.

### Was ist identisch zum Kandidaten
- Auto-generierte + manuelle Reminders
- Eskalation (überfällige Reminders hervorgehoben)
- Priorität (Low / Normal / High / Urgent)
- Status (Open / Done / Snoozed / Cancelled)
- Quick-Popover für schnelle Erstellung (aus Header Quick Actions)

### Was ist anders (Account-Perspektive)

| Aspekt | Kandidat Tab 10 | Account Tab 11 |
|--------|----------------|----------------|
| **Verknüpfung** | Prozess | Mandat / Job / Prozess / Kontakt |
| **Auto-Reminders** | Post-Placement (1./2./3. Monat · 3-Mt=Garantie-Ende), Briefing-Follow-up | **Mandats-Reminders** (Garantiefrist-Ende, Quartals-Review), **AGB-Erinnerung**, **Scraper-Review** |
| **Gruppierung** | Keine (wenige Reminders pro Kandidat) | Nach Mandat oder chronologisch (Account kann viele Reminders haben) |

### Account-spezifische Auto-Reminders

| Trigger | Reminder |
|---------|---------|
| Mandat aktiviert | "Quartals-Review in 90 Tagen" |
| Placement (im Mandat) | "Garantiefrist endet am [Datum]" (3 oder 6 Monate) |
| AGB älter als 12 Monate | "AGB-Erneuerung fällig bei [Account]" |
| Scraper findet neue Vakanzen | "X neue Vakanzen bei [Account] — prüfen" |
| Letzter Kontakt > 90 Tage bei A-Kunde | "Keine Aktivität seit 90 Tagen bei A-Kunde [Account]" |

---

## TEIL 13: BEDINGTER TAB — FIRMENGRUPPE

**Sichtbarkeit:** Nur wenn `account_group_id IS NOT NULL`.

### Inhalt — Aggregations-Dashboard

| Sektion | Inhalt |
|---------|--------|
| **Gruppenmitglieder** | Liste aller Accounts in der Firmengruppe mit Kundenklasse, Status, AM. Klick → navigiert zum Account |
| **Aggregierte KPIs** | Offene Mandate (Summe), aktive Prozesse (Summe), Placements letzte 12M (Summe), Gesamtumsatz Gruppe |
| **Kontakte über Gruppe** | Cross-Account Kontaktliste (Decision Makers aller Gruppenaccounts) |
| **Mandats-Übersicht** | Alle Mandate aller Gruppenaccounts in einer Tabelle |

### Edit-Logik
- **Gruppenzuordnung** über Tab 1 Sektion "Zugehörigkeit" (nicht hier)
- Firmengruppen-Tab ist **read-only** — reine Aggregationsansicht
- Firmengruppe selbst hat eine eigene Detailseite `/company-groups/[id]` für Stammdaten-Pflege der Gruppe (Route standardisiert auf Englisch, Entscheidung #1)

### Phase 1.5/2 vorgemerkt
- Gruppen-weiter No-Hunt-Status (propagiert auf alle Mitglieder)
- Gruppen-AGB (einmal bestätigen für alle)
- Cross-Account Reporting (Umsatz, Marge, Pipeline pro Gruppe)

---

## TEIL 14: BEDINGTER TAB — PROJEKTE (neu v0.3)

**Sichtbarkeit:** Nur wenn
```sql
EXISTS(SELECT 1 FROM fact_projects WHERE bauherr_account_id = this.id)
OR EXISTS(SELECT 1 FROM fact_project_company_participations WHERE account_id = this.id)
```

Tab bleibt ausgeblendet, solange der Account nicht mit mindestens einem Projekt verknüpft ist — analog zum Firmengruppe-Pattern (TEIL 13).

### Query-Logic

```sql
SELECT
  p.id AS project_id,
  p.project_name,
  p.status,
  p.project_start, p.project_end,
  CASE
    WHEN p.bauherr_account_id = :account_id THEN 'bauherr'
    ELSE fppc.role
  END AS role,
  (SELECT COUNT(*) FROM fact_placements pl WHERE pl.project_id = p.id) AS arkadium_placements
FROM fact_projects p
LEFT JOIN fact_project_company_participations fppc
  ON fppc.project_id = p.id AND fppc.account_id = :account_id
WHERE p.bauherr_account_id = :account_id
   OR fppc.account_id = :account_id
GROUP BY p.id
ORDER BY p.project_start DESC;
```

### Layout

**Filter-Chips oben:**
- Rolle: Alle / Bauherr / Architekt / Generalplaner / TU / GU / Fachplaner / Weitere (aus `fact_project_company_participations.role` Enum)
- Status: Alle / Planung / Ausschreibung / Ausführung / Abgenommen / Abgeschlossen / Gestoppt (aus `fact_projects.status` Enum)
- Zeitraum: Alle / Aktuell (ongoing) / Letzte 12M / Historisch

**Tabelle:**

| Spalte | Source |
|--------|--------|
| Projekt-Name | `fact_projects.project_name` → Link `/projects/[id]` |
| Bauherr (wenn nicht this.account) | `fact_projects.bauherr_account_id → dim_accounts.name` — bei Eigen-Bauherrschaft: "—" / Gold-Badge "Bauherr (wir)" |
| Rolle | aus Query `role` (bauherr / architect / tu / spezialist / …) |
| Status | `fact_projects.status` — Badge |
| Zeitraum | `project_start` – `project_end` (beide optional) |
| Arkadium-Placements | Count aus `fact_placements.project_id` — Chip mit #Anzahl |
| BKP-Gewerk (optional) | `fact_project_company_participations.bkp_gewerk` (nur bei Nicht-Bauherr-Rollen) |
| Aktionen | Klick-Row = Drawer / "→ Projekt öffnen" |

**Empty-State:** nicht vorgesehen (Tab ist bedingt — taucht erst auf wenn Projekte verknüpft sind).

### Header Quick-Action

In Account-Header-Toolbar zusätzliche Quick-Action (nur wenn Tab sichtbar):

**"🏗 Projekt verknüpfen":** Öffnet Drawer 540px
- Projekt-Autocomplete-Feld (Fuzzy-Match `fact_projects.project_name`, Confidence-Schwellen wie Kandidaten-Werdegang: ≥85% Auto / 60–84% Review / <60% "Neues Projekt anlegen")
- Rolle-Dropdown (aus `dim_project_roles`)
- BKP-Gewerk (Multi-Select, optional)
- SIA-Phase (Multi-Select, optional)
- Kommentar (Textarea)
- Save → Insert in `fact_project_company_participations` mit `account_id = this.id`
- Event `account_project_linked` in `fact_history` am Account + Projekt

**"+ Neues Projekt anlegen" (in Autocomplete-Fallback):**
- Mini-Drawer: Name (Pflicht), Bauherr-Autocomplete (optional), Standort, Zeitraum (grob von/bis Jahr)
- Auto-Insert in `fact_projects` mit `source='account_tab'`, `source_ref_id=account.id`
- Im Anschluss direkt Rolle/BKP/SIA-Drawer für `fact_project_company_participations`

### Row-Click

Klick auf Tabellen-Zeile öffnet **540px Drawer** mit Projekt-Übersicht:
- Header: Projekt-Name + Bauherr + Status-Badge
- Arkadium-Beteiligungen: Placements-Liste (Name/Rolle/Platzierungsdatum)
- Rolle/BKP/SIA-Info aus `fact_project_company_participations`
- Button "→ Zur Projekt-Detailseite" öffnet `/projects/[id]`
- Button "✎ Beteiligung bearbeiten" (ändert Rolle/BKP/SIA)
- Button "✕ Beteiligung entfernen" (Soft-Delete mit Audit-Trail)

### Cross-Navigation

- **Projekt-Detailseite §6 (Beteiligte Firmen):** Account erscheint mit Rolle + BKP/SIA-Info. Klick zurück auf Account-Name öffnet Account-Detailseite Tab 1.
- **AM-Notizen zum Projekt:** Account-Kommentar auf `fact_project_company_participations.am_notes` → sichtbar in Projekt-Detailseite §6 Sub-Sektion "AM-Notizen pro Firma".

### Edit-Logik

- Tab ist **read-mostly** — Aggregation von Beteiligungen.
- Edits der einzelnen Beteiligung (Rolle/BKP/SIA) erfolgen über den Row-Drawer, nicht inline.
- Edits am Projekt selbst (Name, Bauherr, Status) nur über Projekt-Detailseite.

### Phase 1.5/2 vorgemerkt

- Projekt-Preise/Umsatz pro Account-Beteiligung (z.B. Referenz-Projekte mit Volumen)
- Automatische Projekt-Zuordnung beim Placement (wenn Kandidat auf Projekt vermittelt wird)
- Cross-Account-Projekt-Analytics (Wer baut mit wem?)

---

## TEIL 14: SCHEMA-DELTA-NOTIZ (für Audit-Runde nach Fertigstellung)

### Neue Tabellen

| # | Tabelle | Zweck | Aus Tab |
|---|---|---|---|
| 1 | `fact_account_culture_analysis` | JSONB-Sektionen mit Versionierung der Arkadium-Analyse | 2 |
| 2 | `fact_account_culture_scores` | 6 Dimensionen × Account × Version, mit source ('ai'/'manual'/'questionnaire') | 2 |
| 3 | `dim_culture_dimensions` | Stammdaten der 6 Dimensionen | 2 |
| 4 | `fact_account_temperature` | Hard-Rule + Score-Breakdown, analog Kandidat | Header |
| 5 | `bridge_mitarbeiter_roles` | Multi-Rollen Bridge-Tabelle | allgemein |
| 6 | `dim_location_types` | 2 Einträge: HQ, Niederlassung | 4 |
| 7 | `fact_account_org_positions` | Stellenplan zentrale Tabelle | 5 |

### Schema-Änderungen auf bestehenden Tabellen

**`dim_accounts`:**
- + `growth_rate_3y_pct` (numeric)
- + `revenue_last_year_chf` (bigint)

**`dim_mitarbeiter.role_type`:**
- CHECK erweitert um `Account_Manager`
- Bridge-Tabelle wird Source of Truth für Permissions, Spalte bleibt für primäre Rolle / Anzeige

**`dim_account_contacts`:**
- `candidate_id` → effektiv NOT NULL (Business Rule, technisch via Trigger nach Migration)
- ENTFERNUNG der duplizierten Personen-Felder: first_name, last_name, salutation, email_1, email_2, phone_direct, phone_mobile, phone_private, linkedin_url, xing_url, birthday, function_id, disc_type
- Verbleibend: account-spezifische Felder (is_*, relationship_score, communication_preference, best_contact_time, do_not_contact, location_id, comment_short, onboarding_notes, last_contacted_*, valid_*)

**`fact_account_locations`:**
- + `email`
- ENTFERNUNG: standort_manager, eroeffnungsdatum, bemerkungen, latitude, longitude, mitarbeiter_count
- `location_type` FK → `dim_location_types`

**`fact_jobs`:**
- + `confirmation_status` ('Vakanz' / 'Bestätigt')
- + `source` ('Manuell' / 'Scraper')
- + `source_url`
- + `detected_at`
- + `rejected_at`, `rejected_by`, `rejection_reason`
- + `owner_account_manager_id` FK → `dim_mitarbeiter`
- + `linked_position_id` FK → `fact_account_org_positions`

### Tabelle deprecated
- `fact_vacancies` → wird gelöscht. Migration: alle bestehenden Vakanzen werden mit `confirmation_status = 'Vakanz'` in `fact_jobs` übernommen.

### Stammdaten-Inhalte
- `dim_location_types`: 2 Einträge (HQ, Niederlassung)
- `dim_culture_dimensions`: 6 Einträge (Leistungsorientierung, Innovationskultur, Autonomiespielraum, Feedbackkultur, Hierarchieflachheit, Transformationsreife)

---

## TEIL 15: PHASE 1.5 / PHASE 2 VORMERKLISTE

| Feature | Phase | Beschreibung |
|---|---|---|
| Account Temperature konfigurierbar | 1.5/2 | Scoring + Schwellwerte via `dim_automation_settings` |
| Auto-Geocoding Standorte | 1.5 | Swisstopo/Nominatim sobald Karten/Distanz gebraucht werden |
| Karten-Visualisierung Standorte | 2 | Eingebettete Schweizer Karte mit Pins |
| Kulturprofil Fragebogen-Modus | 1.5/2 | Strukturierte Fragen → automatische Score-Berechnung sobald Methodik vom Chef vorliegt |
| Kulturprofil Switch auf voll-AI | 1.5/2 | Bestätigungs-Schritt optional machen |
| Account-Logo via externe API | 1.5/2 | Clearbit / Brandfetch / Logo.dev als Alternative zum Scraper |
| Konfigurierbare Spalten Kontakte | 1.5/2 | User-Preferences pro Spalten-Set, gemeinsam mit Kandidatenliste |
| Customer Portal Stellenplan | 2 | Self-Service-Pflege durch Kunde |
| Cross-Account Abteilungs-Auswertung | 1.5/2 | Mit Tagging/Mapping-Layer über account-spezifische Abteilungen |
| Mandate-Templates Stammdaten | 1.5/2 | `dim_mandate_templates` Admin-pflegbar (statt hartcodiert) |

---

## TEIL 16: METHODIK-REFERENZ

**Spec-First-Prinzip:** Alle Masken werden vollständig spezifiziert bevor implementiert wird. Reihenfolge: Kandidatenmaske → Account-Detailmaske → Mandate/Jobs/Prozess-Detailmasken → Listenansichten → 3-Layer-Audit (Interactions → DB → Backend) → Schema/Backend-Updates → Implementation in Waves.

**Session-Methodik pro Tab:**
1. Mockup + bestehende Doku (Schema, Freeze, Stammdaten) lesen
2. Offene Interaktionsfragen identifizieren
3. Pro Frage 3–4 Optionen mit Pro/Contra + Empfehlung
4. User entscheidet
5. Antworten in Teile gegliedert, am Ende konsolidieren
6. Vorrang-Regel: Stammdaten > Interactions Doc > Schema > Mockups
7. Phase 1.5/2 wird konsequent vorgemerkt statt jetzt zu entscheiden

**Globale Patterns aus TEIL 0 der Kandidaten-Interactions v1.2 gelten 1:1.**
