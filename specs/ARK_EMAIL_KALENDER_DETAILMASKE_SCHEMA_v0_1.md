# ARK CRM — Email & Kalender Detailmaske Schema v0.1

**Stand:** 17.04.2026
**Status:** Initial — Mockup-First (Ansatz A, `mockups/email-kalender.html` bereits umgesetzt)
**Quellen:**
- `Grundlagen MD/ARK_BACKEND_ARCHITECTURE_v2_5.md` (§ MS Graph / Outlook · § Email-Endpunkte · § Kalender-Integration · `outlook-calendar-sync.worker`)
- `Grundlagen MD/ARK_STAMMDATEN_EXPORT_v1_3.md` (§14 Activity Types — Kategorie „Emailverkehr" 11 Einträge · §14a Email-Templates 38 Einträge)
- `Grundlagen MD/ARK_DATABASE_SCHEMA_v1_3.md` (`dim_email_templates` · `fact_email_drafts` · `fact_history` · `dim_integration_tokens`)
- `Grundlagen MD/ARK_FRONTEND_FREEZE_v1_10.md` (§ Design-System · § Drawer-Default-Regel · § Routing)
- `wiki/concepts/email-system.md` (refreshed 2026-04-17 — CodeTwo + User-Token-Architektur)
- `mockups/email-kalender.html` (Ist-Stand Mockup)

**Vorrang:** Bei Widerspruch gilt: Stammdaten > dieses Schema > Frontend Freeze > Mockups

**Begleitdokument:** `ARK_EMAIL_KALENDER_DETAILMASKE_INTERACTIONS_v0_1.md` (Verhalten, Flows, Events)

---

## 0. ZIELBILD

Operatives Kommunikations-Modul — **Email + Kalender vereint** in einer Voll-Ansicht unter `/operations/email-kalender`. Entspricht PO-Grundsatz „nie das CRM verlassen" (siehe Memory `project_unified_communication.md`).

**Abgrenzung zu anderen Masken:** Keine Entity-Detailmaske (kein `/kandidat/[id]`-Pattern), sondern Tool-Maske wie `dashboard.html` oder `dok-generator.html`. Lebt im Segment „Operations" der globalen Sidebar.

**Primäre Nutzer:**
- **Alle Mitarbeiter** (AM · CM · Researcher · Admin · Backoffice) — Daily-Use-Tool
- Kontext-Sensitiv: AM schreibt Kunde, CM schreibt Kandidat, Researcher bekommt Sourcing-Antworten
- **Auto-Klassifikation** reduziert manuelle Zuordnung

**Abhängigkeiten:**
- MS Graph Integration (OAuth · individuelle User-Tokens, siehe Architektur-Entscheidung 2026-04-17)
- CodeTwo für Signatur-Management (Server-seitig · keine CRM-UX-Relevanz)
- `fact_history` für alle Activity-Logs (Emails = Activity-Type aus Katalog)
- `fact_documents` für Datei-Picker

---

## 1. DESIGNSYSTEM-REFERENZ

Erbt aus [[frontend-freeze]] und [[mockup-baseline]]. Modul-spezifische Ergänzungen:

### Module-Farbe

Keine dedizierte Modul-Farbe — nutzt Standard-Accent (`#1A3A5C`). Activity-Type-Farben im Kalender aus editorial.css:

| Activity-Type | Farbe | Token |
|---|---|---|
| Coaching | Blau | `var(--blue)` |
| Debriefing | Lila | `var(--purple)` |
| Mandats-Akquise | Gold | `var(--gold)` |
| Interview (extern) | Amber | `var(--amber)` |
| Team-intern | Grün | `var(--green)` |
| Extern / Kunde | Rot | `var(--red)` |

### Chip-Farben für Email-Kategorien

| Chip | Bedeutung | Token |
|---|---|---|
| 🎯 Mandat | Email mit Mandats-Bezug | `var(--gold-soft)` |
| 👤 Kandidat | Email mit Kandidaten-Bezug | `var(--blue-soft)` |
| 🏢 Account | Email mit Account-Bezug | `var(--accent-soft)` |
| ❓ Unbekannt | Kein Match — Labeling erforderlich | `var(--amber-soft)` |
| ⚡ Template-Auto | Automations-Template erkannt | `var(--purple-soft)` |

### Mockup-Datei

`mockups/email-kalender.html` — **eine** Single-Page-Maske mit Mode-Toggle (Email ↔ Kalender), kein Tab-Split pro Sub-Feature. Erweiterung über Drawer, nicht über Sub-Tabs.

---

## 2. GESAMT-LAYOUT

```
┌──────────────────────────────────────────────────────────────────┐
│ Header (editorial.css standard)                                  │
│ ARKADIUM · CRM · Operations        Breadcrumb: Home/Operations/… │
├──────────────────────────────────────────────────────────────────┤
│ Page-Banner                                                      │
│ 📬 Email & Kalender    Meta   [Segment: ✉ Email | 📅 Kalender]  │
│ 7 ungelesen · 4 Termine heute · 3 Entwürfe          [+ Neue ...]│
├──────────────────────────────────────────────────────────────────┤
│ Mode-Pane (conditional render)                                   │
│                                                                  │
│ ┌ EMAIL-MODE ─────────────────────────────────────────────────┐ │
│ │ Pane 1: Folders │ Pane 2: Mail-Liste │ Pane 3: Reader        ││
│ │ 220px           │ 340px              │ flex-1                ││
│ │                                                              ││
│ │                                        Reader-Actions-Bar    ││
│ │                                        Inline-Quick-Reply    ││
│ └──────────────────────────────────────────────────────────────┘│
│                                                                  │
│ ┌ KALENDER-MODE ──────────────────────────────────────────────┐ │
│ │ Sidebar: Mini-Cal + Filter │ Main: Toolbar + View           ││
│ │ 220px                      │ flex-1                         ││
│ │                                                              ││
│ │                            View: Tag | Woche | Monat        ││
│ └──────────────────────────────────────────────────────────────┘│
│                                                                  │
├──────────────────────────────────────────────────────────────────┤
│ Drawer-Overlay (540px oder 760px slide-in rechts, on demand)    │
│ 8 Drawer: Compose · Event · CreateKand · CreateAcc ·            │
│          TemplatePicker · Konten · EntityMatch · FileAttach      │
└──────────────────────────────────────────────────────────────────┘
```

Höhen-Mathematik: `calc(100vh - 185px)` für Mode-Pane. Banner ~85px · Header ~60px · Padding ~40px.

---

## 3. PAGE-BANNER

| Element | Inhalt | Verhalten |
|---|---|---|
| **Titel** | „📬 Email & Kalender" (Libre Baskerville 22px · accent) | statisch |
| **Meta-Zeile** | Kontext-sensitiv: Email-Mode „N ungelesen · M Termine heute · K Entwürfe" · Kalender-Mode „N Termine heute · M diese Woche · K diesen Monat" | live aus Backend |
| **Mode-Segment** | `[✉ Email | 📅 Kalender]` — Segmented Control, Mode-Switch | JS: `switchMode()` |
| **CTA-Button** | Kontext-sensitiv: Email-Mode „+ Neue Email" · Kalender-Mode „+ Neuer Termin" | JS: `bannerCtaClick()` |

**Wichtig:** Nur **ein** CTA-Button. Keine doppelte „+ Neuer Termin" in Kalender-Toolbar (explizit entfernt v0.1).

---

## 4. EMAIL-MODE — 3-Pane-Layout

### 4a. Pane 1 · Folders (220px)

Kategorien (Sektionen mit Head-Label):

**Posteingang:**
| Folder | Quelle | Count-Logik |
|---|---|---|
| 📥 Inbox | Email ohne Auto-Match · manuell als „Intern" gelabelt | User-labeled Bucket (Team · Dienstleister · Misc) |
| 🏷 Klassifiziert | Email mit Auto-Match auf Kandidat/Account | Join `fact_history` via `email_message_id` → Entity vorhanden |
| ❓ Unbekannt | Email ohne Match, noch nicht gelabelt | Filter: `email_classification IS NULL` |

**Arbeit:**
| Folder | Quelle |
|---|---|
| 📝 Entwürfe | `fact_email_drafts` |
| 📤 Gesendet | MS Graph Sent-Folder · Filter auf vom User versendet |
| 🗄 Archiv | MS Graph Archive-Folder · vom User archiviert |

**Filter nach Kategorie:**
| Folder | Filter |
|---|---|
| 👤 Kandidat-Mails | Count aller mit Kandidaten-Link |
| 🎯 Mandat / Account | Count aller mit Mandat-/Account-Link |
| ⚡ Template-Automation | Count aller via `dim_email_templates.linked_automation_key` erkannten |

**Konten & System:**
| Link | Ziel |
|---|---|
| 📋 Templates | öffnet `tplDrawer` (38 Einträge aus `dim_email_templates`) |
| ⚙ Konten & Sync | öffnet `kontenDrawer` |

### 4b. Pane 2 · Mail-Liste (340px)

**Liste-Head (sticky):** Titel (z.B. „Inbox") · Meta-Zeile („7 ungelesen · 18 heute")

**Filter-Bar (pills):** Alle · Ungelesen · Markiert · Mit Anhang

**Mail-Row Template:**
```
┌────────────────────────────────────────────────┐
│ From · Name oder Email          Zeit (2h / Mi)│
│ Subject (1-Zeile, ellipsis)                   │
│ Preview (1-Zeile, ellipsis, muted)            │
│ [Chip · Entity oder Template-Auto] 📎 ⚑       │
└────────────────────────────────────────────────┘
```

**States:**
- `unread` → fett + accent-Border-left bei active
- `active` → accent-Hintergrund + 3px Border-left
- `hover` → bg-muted

### 4c. Pane 3 · Reader

**Struktur (top → bottom):**
1. **Head (sticky):** Subject (serif accent) · From/To · Meta (Datum · Thread-Count · Attach-Count) · **verknüpfte Entity-Chips** (klickbar → Detailmaske)
2. **Body:** HTML-Rendering der Mail · Signatur-Trenner
3. **Attach-Bar** (falls vorhanden): Dateien als Chips
4. **Match-Suggestion-Banner** (nur bei Unbekannt-Mails): „🔍 N mögliche Matches" → öffnet `matchDrawer`
5. **Inline-Quick-Reply:** kollabiertes Textfeld → Expand → Send · „↗ Erweitern" → `composeDrawer`
6. **Actions-Bar:** Antworten · Allen · Weiterleiten · Mit Template · Als Aktivität · Termin · Archiv · Löschen · Mehr

---

## 5. KALENDER-MODE

### 5a. Sidebar (220px)

**Mini-Monatskalender:**
- Header: `‹` Monat-Titel `›` — klickbar für Monat-View
- Tag-Grid 7×6 · Highlight: `today` · `has-ev` (Dot unter Zahl)
- Klick auf Tag → Sprung in aktueller View

**Filter-Sektion · Aktivitäts-Typ:**
6 Multi-Select-Checkboxen mit Dot-Marker:
- Coaching (blau) · Debriefing (lila) · Mandats-Akquise (gold) · Interview extern (amber) · Team-intern (grün) · Extern/Kunde (rot)

**Filter-Sektion · Mitarbeiter:**
- PW (eigen, default checked)
- Kollegen (JV · LR · MF) — Overlay transparenter, nur frei/busy ohne Titel (DSG)
- Hinweis: „Kollegen-Kalender zeigen nur frei/busy"

**Quick-Links:** „Heute" · „Neuer Termin"

### 5b. Main · Toolbar

Nav `‹ Heute ›` · KW-/Monat-Label (Libre Baskerville) · View-Segment `[Tag | Woche | Monat]`

**Keine** „+ Neuer Termin"-Button — Single Source ist Banner-CTA + Sidebar-Quick-Link.

### 5c. Views

**Woche (default):**
- 7 Spalten · Zeitachse 08:00–20:00 · 30min-Raster
- Event-Block: absolute-positioniert · Border-left farbkodiert · Title + Zeit + Entity-Mini-Chip
- Heute-Spalte highlighted
- Kollegen-Events: transparenter + dashed Border

**Tag:**
- 1 Spalte · 30min-Raster · mehr Platz für Event-Details
- Header mit Datum (Libre Baskerville 18px) + Zusammenfassung

**Monat:**
- 7×5–6 Grid · Events als chips (max 3 pro Tag + „+N mehr")
- Klick auf Tag → Sprung in Tag-View

### 5d. Event-Click

Klick auf Event → `openEventDrawer(id)` → Drawer mit bestehenden Daten (4 Tabs)
Klick auf leeren Slot → `openNewEventDrawer()` → Drawer mit Default (Start = Klick-Slot-Zeit)

---

## 6. DRAWER-INVENTAR (8)

Alle 540px Standard-Drawer oder 760px `.drawer-wide` für Multi-Tab (Drawer-Default-Regel).

| # | Drawer-ID | Breite | Zweck | Tabs | Trigger |
|---|---|---|---|---|---|
| 1 | `composeDrawer` | 760px | Email schreiben/beantworten/weiterleiten | 3 (Inhalt · Verknüpfung · Optionen) | `+ Neue Email` · Reply · Reply-All · Forward · Quick-Reply-„↗ Erweitern" |
| 2 | `eventDrawer` | 760px | Termin öffnen/anlegen | 4 (Basis · Teilnehmer · Verknüpfung · Coaching-Notizen) | Event-Click · `+ Neuer Termin` |
| 3 | `createCandDrawer` | 540px | Kandidat aus Email anlegen | — | Unbekannt-Email „+ Kandidat" · Match-Drawer-Fallback |
| 4 | `createAccDrawer` | 540px | Account aus Email anlegen | — | Unbekannt-Email „+ Account" · Match-Drawer-Fallback |
| 5 | `tplDrawer` | 540px | Template auswählen | — (Kategorie-Gruppen) | Compose „📋 Template einfügen" · Folder „Templates" |
| 6 | `kontenDrawer` | 540px | Konten/Sync/CodeTwo/Ignore-Liste | — (Sektionen) | Folder „Konten & Sync" |
| 7 | `matchDrawer` | 540px | Fuzzy-Match-Treffer zuordnen | — | Reader „🔍 N Matches" bei Unbekannt-Mail |
| 8 | `fileAttachDrawer` | 760px | Datei aus CRM anhängen | 3 (Aus Kontext · Alle Dokumente · Zuletzt verwendet) | Compose „📁 Aus CRM anhängen" |

---

## 7. COMPOSE-DRAWER (Detail)

### Tab 0 · Inhalt

| Feld | Typ | Validierung |
|---|---|---|
| Auto-Klassif-Banner | Info (conditional) | zeigt wenn Template erkannt |
| An | Email-Adresse(n) | multi · required · format |
| CC | Email-Adresse(n) | multi · optional |
| BCC | Email-Adresse(n) | multi · optional |
| Betreff | Text | required · max 255 |
| Nachrichten-Text | Rich-Text | required |
| Template-Picker-Button | → `tplDrawer` | integriert Template in Body |
| Anhänge | Multi (CRM + Local + Drag) | total ≤ 25 MB (MS Graph limit) |

### Tab 1 · Verknüpfung

| Feld | Typ | Verhalten |
|---|---|---|
| Verknüpfte Einträge | Chips (Mandat/Kandidat/Account) | Auto-erkannt aus An-Adresse · manuell +/– |
| Aktivitäts-Typ für Historie | Select | **11 Emailverkehr-Einträge** aus STAMMDATEN v1.3 §14 (siehe §9 unten) |

### Tab 2 · Optionen

| Feld | Typ | Default |
|---|---|---|
| Priorität | Select (Normal/Hoch/Niedrig) | Normal |
| Absender | Select | aktueller User · nur ein Eintrag |
| Lesebestätigung anfordern | Checkbox | off |
| **Signatur-Info** | Info-Banner (CodeTwo) | — · **keine manuelle Checkbox** |
| Sofort senden / Später senden | Radio | sofort · sonst `datetime-local`-Input |

### Footer

`Senden` · `Als Entwurf speichern` · Auto-Save-Status · `Abbrechen`

---

## 8. EVENT-DRAWER (Detail)

### Tab 0 · Basis

| Feld | Typ |
|---|---|
| Titel | Text · required |
| Start | `datetime-local` · required |
| Ende | `datetime-local` · required · ≥ Start |
| Ganztags | Checkbox |
| Ort | Text |
| Aktivitäts-Typ | Select · aus `dim_activity_types` (Kategorie gefiltert auf: Coaching/Debriefing/Mandatsakquise/Interview/Team-intern/Extern) |
| Teams-Link | Auto-generiert (bei Teams-Meeting) · Kopieren · Neu generieren |
| Notizen / Agenda | Textarea · optional |

### Tab 1 · Teilnehmer

| Feld | Verhalten |
|---|---|
| Teilnehmer-Liste | Avatar · Name · Rolle (Mitarbeiter-Kürzel / Kandidat / Kunde) · Status-Pill (Zugesagt/Tentativ/Abgelehnt/Ausstehend) |
| + Teilnehmer einladen | Autocomplete auf Kandidaten · Accounts · Mitarbeiter |
| Erinnerung | Select (15min / 30min / 1h / 1d) + Kanal (Push+Email / Push / Email) |

### Tab 2 · Verknüpfung

Auto-erkannt aus Teilnehmern. Manuell zufügen/entfernen:
- 👤 Kandidat
- 🎯 Mandat
- 🏢 Account
- → Prozess

**Hinweis:** Nach Termin-Ende wird automatisch `fact_history`-Eintrag bei allen verknüpften Entities erzeugt. Notizen übernommen.

### Tab 3 · Coaching-Notizen (conditional — nur wenn Aktivitäts-Typ = Coaching)

| Feld | Inhalt |
|---|---|
| Coaching-Checkliste | 5 Pflicht-Items (Kandidaten-Motivation · Firmen-Know-How · Fragen an Kunde · Gehaltsverhandlungs-Taktik · Red-Flag-Check) |
| Offene Punkte | Textarea (full-width · min-height 220px) |

### Footer

`Speichern & schliessen` · `Speichern` · `Termin löschen` (nur bei bestehendem Event)

---

## 9. ACTIVITY-TYPE-KATALOG (Emailverkehr-Kategorie)

Aus `STAMMDATEN v1.3 §14` — **verbindlich** für Compose-Drawer · Reader „Als Aktivität erfassen":

| # | Label | Entity-Relevanz | Beschreibung |
|---|---|---|---|
| 22 | Emailverkehr - Allgemeine Kommunikation | both | Default · generische Kommunikation |
| 23 | Emailverkehr - CV Chase | candidate | Nachfassen wegen CV |
| 24 | Emailverkehr - Absage Briefing | candidate | Kandidat sagt Briefing ab |
| 25 | Emailverkehr - Absage Bewerbung | account | Kunde sagt nach CV-Sent ab |
| 26 | Emailverkehr - Absage vor GO Termin | candidate | Absage vor GO |
| 27 | Emailverkehr - Mündliche GOs versendet | account | ⚡ Auto · löst Jobbasket-Update „is_oral_go" aus |
| 28 | Emailverkehr - Absage nach GO Termin | account | Kunde lehnt nach GO ab |
| 29 | Emailverkehr - Schriftliche GOs | account | ⚡ Auto · Bestätigung eingehend |
| 30 | Emailverkehr - Eingangsbestätigung Bewerbung | candidate | Bestätigung Bewerbungseingang |
| 31 | Emailverkehr - Mandatskommunikation | account | Kommunikation zum Mandat |
| 32 | Emailverkehr - AGB Verhandlungen | account | AGB-Verhandlung |

**Keine Freitext-Optionen.** Neue Einträge nur via Stammdaten-Erweiterung + Freigabe.

---

## 10. TEMPLATE-KATALOG (38 Einträge)

Aus `dim_email_templates`. 4 mit Automations-Trigger (`linked_automation_key IS NOT NULL`):

| Template-Key | Kategorie | Auto-Trigger |
|---|---|---|
| `go_muendliche_versand` | GO-Prozess | ⚡ `jobbasket.is_oral_go + mandate_research → go_muendlich` |
| `cv_versand_kunde` | Versand | ⚡ `process.created + jobbasket → cv_sent` |
| `expose_versand_kunde` | Versand | ⚡ `process.created + jobbasket → expose_sent` |
| `assessment_link` | Assessment | ⚡ `Invite-Status → sent` |

Kategorien: Sourcing · CV & Dokumente · Briefing · GO-Prozess · Versand · Interview · Placement · Mandate · Assessment

Template-Picker-Drawer gruppiert nach Kategorie. Automation-Templates mit `AUTO`-Badge (amber) + Border-left.

---

## 11. DATEI-PICKER (FileAttach-Drawer)

### Tab 0 · Aus Kontext

Nur sichtbar, wenn Compose-Drawer verknüpfte Entities hat. Listet Dokumente aus:
- 👤 Kandidat → `fact_documents` WHERE `candidate_id = X`
- 🎯 Mandat → `fact_documents` WHERE `mandate_id = X`
- 🏢 Account → `fact_documents` WHERE `account_id = X`
- Optional: → Prozess, Assessment

Gruppiert nach Entity. Checkbox-Select · Multi-Choice.

### Tab 1 · Alle Dokumente

Volltext-Suche über `fact_documents`. Filter-Pills: Alle · PDF · Word/Excel · Bilder · Assessment-Reports · Jobbasket.

### Tab 2 · Zuletzt verwendet

Von diesem User in den letzten 30 Tagen per Email versendet.

### Footer

`N Dateien anhängen` · `Abbrechen`

---

## 12. KONTEN-DRAWER (Detail)

### Sektion 1 · Email-Konten

**1 Card pro User** (individuelle Tokens-Architektur, keine Shared Mailbox):
- Name („Mein Postfach")
- Adresse (`pw@arkadium.ch`)
- Tenant
- Letzter Sync · Token-Health · Kalender-Verbindung · Mails heute
- Buttons: `Token erneuern` · `Trennen`

Info-Text unten: „Pro User eigene OAuth-Verbindung (MS Graph · Calendars.ReadWrite · Mail.Send · Mail.Read)".

### Sektion 2 · Sync-Log

Monospace-Log · letzte 10 Ereignisse · Zeit + Farbe (green/amber/red) + Text.

### Sektion 3 · Email-Signatur · CodeTwo

**Status-Card:**
- C2-Logo + „CodeTwo Email Signatures for Office 365"
- Aktives Template (z.B. „Arkadium Senior Partner (DE)")
- Tenant-Scope
- Verwaltung · Status
- Erklär-Text: „Signaturen werden automatisch von CodeTwo auf Exchange-/M365-Server-Ebene nach Versand angehängt".
- Buttons: `Template wechseln` · `Vorschau anzeigen` · `Admin-Panel öffnen ↗`

### Sektion 4 · Ignore-Liste

Tabelle mit Zeilen: Typ (Domain/Absender/Betreff) · Wert · `×`-Remove.
Zufügen: Input + Typ-Select + `+ Hinzufügen`-Button.

### Sektion 5 · Sync-Scope

Checkboxen:
- ☑ Nur Mails mit Kandidaten-/Account-Adressen synchronisieren
- ☑ Automations-Templates erkennen & Historie automatisch befüllen
- ☑ Kalender-Termine bidirektional (ARK ↔ Outlook)
- ☐ Interne Team-Mails (@arkadium.ch) ebenfalls synchronisieren

---

## 13. ENTITY-MATCH-DRAWER

Bei Click „🔍 N mögliche Matches" in Unbekannt-Mail-Reader.

**Inhalt:**
- Liste von Match-Zeilen · sortiert nach Score absteigend
- Pro Zeile: Avatar · Name · Sub-Info (Funktion · letzter Kontakt) · Score (xx/100) · `Zuordnen`-Button
- Score-Algorithmus: Name (Levenshtein 40%) + Domain (30%) + Historie (30%)

**Fallback-Sektion „Keine Übereinstimmung?":**
- `+ Neuen Kandidaten anlegen` → `createCandDrawer`
- `+ Neuen Account anlegen` → `createAccDrawer`
- `Mail ignorieren` → Eintrag in Ignore-Liste

---

## 14. CREATE-KANDIDAT/-ACCOUNT-DRAWER

Vor-befüllt aus Email-Header + Body + Domain:

**Create-Kandidat:**
- Vor-/Nachname (aus From-Signature-Parser)
- Email (From)
- Telefon · LinkedIn (leer)
- Sparte · Org-Funktion · Arbeitgeber · Position
- Optional: ☑ „Email als Historien-Eintrag" · ☑ „CV-Anhang auto-parsen"

**Create-Account:**
- Firmenname (aus Domain)
- Website · Haupt-Email
- Sparten (multi) · Account-Manager
- Ansprechpartner (aus Signature) · Funktion

---

## 15. RBAC

| Rolle | Email-Mode | Kalender-Mode | Konten & Sync | Templates CRUD |
|---|---|---|---|---|
| **AM** | full | full (eigen + Kollegen frei/busy) | eigenes Konto | lesen |
| **CM** | full | full (eigen + Kollegen frei/busy) | eigenes Konto | lesen |
| **Researcher** | read + reply · kein Compose-new | eigen | eigenes Konto | lesen |
| **Admin** | full · alle User | full · alle User | alle Konten | **CRUD** · nur Custom (System-Templates read-only) |
| **Backoffice** | read · Rechnungs-Thread | read | — | lesen |

**Keine Cross-User-Mail-Lese-Rechte** außer Admin — Mails sind privat pro User-Postfach.

**Kalender-Overlay Kollegen:** nur `frei/busy` ohne Titel-Details (DSG).

---

## 16. BACKEND-INTEGRATION

### Endpunkte (aus `ARK_BACKEND_ARCHITECTURE_v2_5`)

| Endpoint | Zweck |
|---|---|
| `POST /api/v1/emails/send` | Email versenden |
| `POST /api/v1/emails/send-with-template` | Mit Template |
| `GET /api/v1/emails/inbox` | Inbox laden |
| `GET /api/v1/emails/:id` | Einzelne Mail (Body on demand) |
| `GET/POST/PATCH/DELETE /api/v1/emails/drafts` | Drafts CRUD |
| `GET /api/v1/email-templates` | Templates laden |
| `POST/PATCH/DELETE /api/v1/email-templates/:id` | Template-CRUD (Admin) |
| `POST /api/v1/integrations/outlook/connect` | OAuth-Flow |
| `POST /api/v1/integrations/outlook/disconnect` | Verbindung trennen |
| `POST /api/v1/integrations/outlook/sync` | Manueller Sync-Trigger |
| `GET /api/outlook/auth/callback` | Azure Redirect URI |

### Worker

| Worker | Trigger | Scope |
|---|---|---|
| `outlook.worker.ts` | Event-Bus · Cron | Mail-Pull/Send · Auto-Klassifikation |
| `outlook-calendar-sync.worker.ts` | `interview_scheduled` · `_rescheduled` · Cron 15min | Bidirektionaler Kalender-Sync |
| `email.worker.ts` | Event-Bus | Send mit Retry |

### Event-Katalog (Auto-Erzeugung)

| Event | Erzeuger | Verbraucher |
|---|---|---|
| `email.received` | `outlook.worker` | `fact_history` Insert · Klassifikation |
| `email.sent` | `email.worker` | `fact_history` Insert · Template-Automation |
| `email.bounced` | `outlook.worker` | User-Alert · Invalid-Address-Flag |
| `interview_scheduled` | Event-Drawer-Save | `outlook-calendar-sync.worker` erzeugt Outlook-Event |
| `interview_rescheduled` | Event-Drawer-Update | `outlook-calendar-sync.worker` aktualisiert |

### Idempotenz

- Email: `source_event_id = email_message_id` (MS Graph Message-ID) · `source_system = 'outlook'`
- `ON CONFLICT (tenant_id, source_system, source_event_id) DO NOTHING`

---

## 17. ROUTING

| Route | Ziel |
|---|---|
| `/operations/email-kalender` | Voll-Ansicht Email-Mode (default) |
| `/operations/email-kalender?mode=cal` | Voll-Ansicht Kalender-Mode |
| `/operations/email-kalender?mode=cal&view=day&date=2026-04-17` | Deep-Link Kalender Tag-View |
| `/operations/email-kalender?mode=email&folder=inbox&mail=<id>` | Deep-Link zu einzelner Mail |

**Sidebar-Link:** `crm.html:141` Operations-Sektion · `data-src="email-kalender.html"`

---

## 18. MOCKUP-DATEI (umgesetzt)

**`mockups/email-kalender.html`** (~113 KB, ~1700 Zeilen · ein Single-File-Mockup).

Vollständig implementiert:
- Header + Banner + Mode-Toggle
- Email-Mode 3-Pane mit 10 Sample-Mails · Reader · Quick-Reply · Actions-Bar
- Kalender-Mode 3 Views (Tag/Woche/Monat) · Mini-Cal · Filter-Sidebar · 13 Sample-Events
- 8 Drawer (inkl. File-Attach-Drawer für Datei-Picker)
- JS: Mode-Switch · View-Switch · Drawer-Open/Close/Tab-Switch · Theme-Toggle · Inline-Quick-Reply · Event-Drawer-Reset bei New-Event · Toast-Notifications

---

## 19. OFFENE PUNKTE · v0.2-Roadmap

- [ ] Popout-Fenster für Compose (Tri-State aus Brainstorming — später, nicht v1)
- [ ] Email-Rules (Auto-Labels, Filter) — separate Maske, post-v1
- [ ] Mehrere Signaturen pro User (falls CodeTwo nicht abdeckt)
- [ ] Kalender-Ressourcen (Räume, Geräte) — wenn physische Büros relevant
- [ ] Thread-View statt Single-Mail-Reader (Gmail-Style) — v0.3
- [ ] CC-/BCC-Auto-Complete auf Kandidaten/Accounts
- [ ] Mobile-Responsive-Anpassungen

---

## 20. CROSS-REFERENCES

- [[kandidatenmaske-schema]] — Email-Activity als Historien-Eintrag
- [[account-detailmaske-schema]] — Email-Entity-Chips öffnen Account-Detail
- [[mandat-detailmaske-schema]] — Mandats-Kommunikation-Verlauf
- [[email-system]] — Concept-Wiki (Architektur, Ordner-Modell, CodeTwo)
- [[automationen]] — Template-Automation-Trigger
- [[history-system]] — `fact_history` Activity-Types
- [[backend-architektur]] — MS Graph · Worker · Endpunkte
- [[spec-sync-regel]] — Governance für 10. Detailmaske (Email-Kalender jetzt in Sync-Matrix)
