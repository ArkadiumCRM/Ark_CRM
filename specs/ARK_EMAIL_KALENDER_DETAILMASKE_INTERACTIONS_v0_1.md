# ARK CRM — Email & Kalender Detailmaske Interactions Spec v0.1

**Stand:** 17.04.2026
**Status:** Initial — dokumentiert Ist-Stand des Mockups `mockups/email-kalender.html`
**Kontext:** Definiert Verhalten · CRUD-Flows · Validierung · Events für die Voll-Ansicht Email & Kalender.
**Begleitdokument:** `ARK_EMAIL_KALENDER_DETAILMASKE_SCHEMA_v0_1.md` (Layout, Felder, Drawer-Inventar)
**Vorrang:** Stammdaten > dieses Dokument > Schema > Mockups
**Globale Patterns:** Drawer-Default-Regel · Datum-Eingabe-Regel (Picker + Tastatur) · Umlaute-Regel · Keine-DB-Technikdetails-Regel · Stammdaten-Wording-Regel (alle CRITICAL, CLAUDE.md).

---

## TEIL 0 · STRUKTURELLE GRUNDENTSCHEIDUNGEN

### Architektur-Entscheidungen (PO, 17.04.2026)

| # | Entscheidung | Begründung |
|---|---|---|
| 1 | **Layout A** (Mode-Toggle im Banner) statt Tab-Navigation (B) oder 3-Pane-Hybrid (C) | Klare Mode-Trennung · voller Screen je Mode |
| 2 | **Full-Scope** für v1 | Backend-Features bereits alle gebaut — keine Sub-Phasen nötig |
| 3 | **Quick-Reply inline + Drawer für Compose-New/Reply-All/Forward/Template** | 80/20-Regel — häufigster Case (kurze Reply) ohne Drawer-Reibung. Drawer-Default-Regel-Ausnahme dokumentiert. |
| 4 | **Individuelle User-Tokens** · kein Shared-Mailbox-Zwischenschritt | Vereinfacht Architektur · klare User-Ownership · DSG-konform |
| 5 | **CodeTwo für Signaturen** · keine CRM-Signatur-Verwaltung | Zentrale Admin-Kontrolle · keine Compose-UX-Komplexität |
| 6 | **Kalender-Team-Overlay zeigt nur frei/busy** ohne Titel | DSG-Datenschutz · Team-Koordination ohne Inhalts-Leak |
| 7 | **Kein Popout-Fenster** (Tri-State aus Brainstorming verworfen für v1) | Over-Engineering — Drawer reicht |

### Sidebar-Link

`mockups/crm.html:141` wurde von `Email-Inbox` auf `Email & Kalender` umbenannt und auf `email-kalender.html` gelinkt.

---

## TEIL 1 · PAGE-BANNER + MODE-SWITCH

### Mode-Switch

**Segmented Control** im Banner: `[✉ Email | 📅 Kalender]`

**JS:** `switchMode(m)`:
1. Toggle `.active` auf Segment-Button
2. Show/hide `.mode-pane` (`#emailMode` · `#calMode`)
3. Update Banner-Meta (`#bannerMeta`) kontext-sensitiv
4. Update CTA-Button-Label (`#bannerCta`)

### Banner-CTA

**`bannerCtaClick()`:**
- Email-Mode → `openDrawer('composeDrawer')`
- Kalender-Mode → `openNewEventDrawer()` (reset + defaults)

### Deep-Link

Route-Params beim Seiten-Load lesen:
- `?mode=cal|email` → Mode setzen
- `?view=day|week|month` → Kalender-View setzen
- `?date=YYYY-MM-DD` → Kalender auf Datum springen
- `?mail=<id>` → Mail öffnen + im Reader rendern
- `?folder=inbox|classified|unknown|drafts|sent|archive` → Folder aktivieren

---

## TEIL 2 · EMAIL-MODE

### Folder-Click

**`selectFolder(el, key)`:**
1. Alle `.ep-folder` `.active` entfernen
2. `el.classList.add('active')`
3. Mail-Liste neu laden mit Filter-Key
4. Optional: Match-Banner im Reader anzeigen bei `key === 'unknown'`

### Filter-Pills (Alle / Ungelesen / Markiert / Mit Anhang)

**`filterMails(el, key)`:**
- Toggle Pill-Active
- Mail-Liste filtern (ohne Folder-Änderung)
- Composable: Folder `classified` + Pill `unread` → nur ungelesen klassifizierte Mails

### Mail-Click

**`selectMail(el, id)`:**
1. Reader lädt Mail via `GET /api/v1/emails/:id`
2. Mail als gelesen markieren (`unread`-Klasse raus)
3. Badge-Count im Folder -1
4. Outlook-seitig als gelesen markieren (MS Graph)
5. Verknüpfte Entity-Chips rendern (aus `fact_history` Join)
6. Match-Banner nur bei `email_classification = 'unknown'`

### Inline-Quick-Reply

**State-Machine:**

```
collapsed → (click/focus) → expanded
expanded → (Send-Button) → sent + collapsed
expanded → (Erweitern-Button) → collapsed + openComposeDrawer mit Text
expanded → (Verwerfen / Esc) → collapsed + Text verworfen
expanded → (Ctrl+Enter / ⌘+Enter) → Send
```

**Send-Flow:**
1. `POST /api/v1/emails/send` mit Body, To = Original-From, Subject = „Re: …"
2. Bei Erfolg: Toast „Antwort versendet · Historien-Eintrag erstellt"
3. Neue Mail erscheint in „Gesendet"
4. `fact_history`-Eintrag mit Activity-Type „Emailverkehr - Allgemeine Kommunikation" (oder kontext-sensitiv)
5. Bei Fehler: Toast-Fehler · Text bleibt im Textarea

**Keine CC/BCC/Anhänge/Template** inline — für das alles „↗ Erweitern" → Compose-Drawer mit Text übernommen.

### Reader-Actions-Bar

| Button | Aktion |
|---|---|
| ↵ Antworten | `openComposeDrawer('reply')` · Mode: reply |
| ↩ Allen antworten | `openComposeDrawer('reply-all')` |
| → Weiterleiten | `openComposeDrawer('forward')` |
| 📝 Mit Template | `openDrawer('tplDrawer')` |
| → Als Aktivität erfassen | `logAsActivity()` · erstellt `fact_history`-Eintrag ohne Senden |
| 📅 Termin vereinbaren | `openDrawer('eventDrawer')` · Auto-Verknüpfung mit Mail-Entities |
| 🗄 Archivieren | MS Graph Move to Archive |
| 🗑 Löschen | MS Graph Delete + Soft-Delete in `fact_history` |
| ⋯ Mehr | Dropdown: Als ungelesen · Drucken · Spam · Weiterleiten an Outlook |

### Entity-Chip-Click im Reader

`openEntity(kind)`:
- `mandat` → Route `/mandate/[id]`
- `kandidat` → Route `/kandidat/[id]`
- `account` → Route `/accounts/[id]`
- Öffnet in **neuem Tab** — User verlässt Email-Kontext nicht

---

## TEIL 3 · KALENDER-MODE

### View-Switch

**`switchCalView(v)`:**
1. Toggle `.view-seg` Button active
2. Show/hide `.cal-view`
3. Update `#calMainTitle`:
   - Tag: „Fr · 17. April 2026"
   - Woche: „KW 16 · 13.–19. April 2026"
   - Monat: „April 2026"

### Event-Click (bestehender Termin)

**`openEventDrawer(id)`:**
1. Drawer mit Event-Daten befüllen (aktuell hardcoded Demo — in Produktion via `GET /api/v1/calendar-events/:id`)
2. Title/Sub im Drawer-Head setzen
3. Delete-Button sichtbar
4. Coaching-Tab sichtbar (nur wenn `activity_type.category = 'Coaching'`)
5. Tab 0 (Basis) aktiv
6. Drawer öffnen

### Neuer Termin

**`openNewEventDrawer()`:**
1. Titel „Neuer Termin" · Sub „Neuen Kalender-Eintrag anlegen"
2. Alle Input-Felder leeren
3. Start = nächste volle Stunde · Ende = +30 Minuten
4. Aktivitäts-Typ-Select auf ersten Eintrag (Coaching default — evtl. anpassen via letzte Nutzung)
5. Teilnehmer-Liste reduzieren auf Organisator (aktueller User)
6. Verknüpfung-Tab: leere Hinweis-Sektion + „+ Kandidat/Mandat/Account verknüpfen"-Buttons
7. Coaching-Tab ausblenden (erscheint nur bei Typ=Coaching)
8. Delete-Button ausblenden (neuer Termin hat nichts zu löschen)
9. Drawer öffnen · Fokus auf Titel-Feld

### Slot-Click (Kalender-Zelle)

Kurzklick auf leeren Slot → `openNewEventDrawer()` mit Start = Slot-Zeit
Doppelklick-Drag → In-Place-Quick-Create (v0.2 · nicht in v1)

### Filter-Interaktion

**Aktivitäts-Typ-Checkboxen:**
- Multi-Select · default alle aktiv
- Change → Events mit abgewähltem Typ ausblenden (visuell only, nicht löschen)

**Mitarbeiter-Checkboxen:**
- PW default aktiv (eigener Kalender)
- Kollegen (JV/LR/MF) default aus — aktivieren blendet deren frei/busy-Blöcke ein
- Kollegen-Events: `.cal-event.colleague` · transparenter + dashed border
- Titel versteckt · stattdessen Zeit + „Besetzt"

### Mini-Cal-Click

Click auf Tag → Sprung zur Woche/Tag in der aktiven Main-View

### Keyboard (Kalender)

- `←` / `→` → Woche/Tag vor/zurück
- `t` → Heute
- `d` / `w` / `m` → View wechseln
- `n` → Neuer Termin

---

## TEIL 4 · COMPOSE-DRAWER-FLOW

### Modes

| Mode | Trigger | Pre-Fill |
|---|---|---|
| `new` | Banner-CTA · Sidebar-Link | leer |
| `reply` | Reader „↵ Antworten" | An = Original-From · Subject = „Re: …" · Body-Zitat |
| `reply-all` | Reader „↩ Allen antworten" | An = alle Recipients · CC übernommen |
| `forward` | Reader „→ Weiterleiten" | An = leer · Subject = „Fwd: …" · Body-Zitat + Anhänge übernommen |
| `from-quick-reply` | Quick-Reply „↗ Erweitern" | An = Original-From · Body = Quick-Reply-Text |
| `from-template` | Tab 0 „📋 Template einfügen" | Template-Body ersetzt Body · Subject optional |

### Auto-Klassifikations-Banner

Zeigt, wenn System Template-Match erkennt (z.B. Subject matcht `template.subject_pattern`):
> ⚡ Auto-Klassifikation aktiv. Template „Mündliche GOs" erkannt → wird als Emailverkehr · Mündliche GOs in Historie erfasst.

### Tab-Switch

**`drawerTab('composeDrawer', idx)`:**
- Toggle `.drawer-tab.active`
- Show/hide `.drawer-pane`

### Senden-Flow

1. Validierung:
   - An: required · mindestens 1 gültige Email
   - Betreff: required · max 255
   - Body: required
   - Total Anhang-Größe ≤ 25 MB (MS Graph-Limit)
2. Request `POST /api/v1/emails/send` (oder `/send-with-template` wenn Template gewählt)
3. Server:
   - Sendet via MS Graph im Kontext des User-Tokens
   - CodeTwo fügt Signatur server-seitig an
   - Erzeugt `email.sent`-Event
   - Worker schreibt `fact_history`-Eintrag mit gewähltem Activity-Type
   - Bei Automations-Template: zusätzlicher Side-Effekt (z.B. Jobbasket-Update)
4. Erfolg: Toast „Email versendet" · Drawer schließen · Mail in „Gesendet" sichtbar
5. Fehler: Toast-Error · Drawer offen · Text bleibt

### Als-Entwurf-Speichern

1. Request `POST /api/v1/emails/drafts` (oder PATCH bei Update)
2. Entry in `fact_email_drafts`
3. Toast „Als Entwurf gespeichert"
4. Drawer bleibt offen · Auto-Save-Status zeigt „zuletzt 12:04"

### Auto-Save

Alle 30 Sekunden bei Veränderung (debounced) → PATCH `fact_email_drafts`. Status-Text im Footer.

---

## TEIL 5 · EVENT-DRAWER-FLOW

### Aktivitäts-Typ-Wechsel

Wenn Typ = „Coaching · Kandidat (vor Interview)" gewählt wird:
- Coaching-Tab (Tab 3) einblenden
- Automatische Checkliste pre-gefüllt

Andere Typen → Coaching-Tab ausblenden.

### Teams-Link-Generierung

- Default: auto-generiert beim Speichern (via MS Graph Online-Meeting-API)
- „Neu generieren"-Button → neuer Link, alter invalidiert
- „Kopieren"-Button → Clipboard

### Teilnehmer-Auto-Complete

Input feldbasiert:
1. Trigger bei 2+ Zeichen
2. Suche über `dim_candidates` · `dim_account_contacts` · `dim_employees`
3. Ergebnis-Liste mit Avatar + Name + Rolle
4. Select → fügt Teilnehmer hinzu mit Status „Pending"

### Verknüpfung-Auto-Detection

Aus Teilnehmer-Liste automatisch:
- Kandidat-Teilnehmer → Kandidaten-Link
- Account-Kontakt-Teilnehmer → Account + (wenn vorhanden) Mandat-Link
- Falls in aktivem Prozess → Prozess-Link

### Speichern-Flow

1. Validierung: Titel · Start · Ende · mindestens Organisator
2. Request `POST /api/v1/calendar-events` (oder PATCH bei Update)
3. Server:
   - Erzeugt `interview_scheduled`-Event (wenn Typ = Interview)
   - `outlook-calendar-sync.worker.ts` erzeugt Outlook-Event via MS Graph
   - Teams-Link beigefügt
   - Einladungen an Teilnehmer versendet
   - Bei Termin-Ende (Cron): `fact_history`-Eintrag bei allen verknüpften Entities
4. Erfolg: Toast „Termin gespeichert" · Kalender neu gerendert

### Termin löschen

1. Confirm-Dialog: „Termin wirklich löschen? Absagen werden an Teilnehmer versendet."
2. Request `DELETE /api/v1/calendar-events/:id`
3. MS Graph: Event + Absage-Mails versenden
4. `interview_rescheduled` oder `interview_cancelled` Event
5. Kalender aktualisieren

---

## TEIL 6 · CREATE-KANDIDAT-/ACCOUNT-DRAWER

### Pre-Fill-Logik

**From-Signature-Parser** extrahiert aus Mail-Body:
- Name · Email · Telefon · Firma · Titel
- Algorithmus: Regex + LLM-Fallback (low-temperature)

**Domain-Analyse** für Account:
- Domain → Firmenname (via WHOIS + Website-Scrape)
- Falls Account existiert → statt Create „Bestehenden Account öffnen" vorschlagen

### Create-Flow

1. User ergänzt/korrigiert Felder
2. ☑ „Email als Historien-Eintrag anlegen" → bei Save wird `fact_history`-Entry erzeugt
3. ☑ „CV-Anhang automatisch parsen" → CV wird via LLM geparsed (Career-Timeline, Sparte, Position)
4. Request `POST /api/v1/candidates` bzw. `/accounts`
5. Erfolg: Toast „Kandidat angelegt" · Navigate zu Detailmaske neuer Kandidat/Account
6. Email im Reader bekommt automatisch Entity-Chip verknüpft

---

## TEIL 7 · TEMPLATE-PICKER-DRAWER

### Laden

`GET /api/v1/email-templates` → alle Templates (System + Custom · `is_system_template` im Response)

### Suche

Input-Field · full-text über `template_name` + `subject` + `body_html` + `tags`

### Auswahl

Template-Card-Click → `Template verwenden`-Button
- `template_body_html` in Compose-Drawer-Body eingesetzt
- `template_subject` in Betreff eingesetzt (nur bei `new`-Mode)
- `linked_activity_type` in Verknüpfung-Tab als Default
- `linked_automation_key` → Auto-Klassifikations-Banner

### Admin-CRUD

Für Admin: Template-Drawer hat zusätzlich (v0.2):
- `+ Neues Template`-Button
- Pro Card: `Bearbeiten` · `Duplizieren` · `Löschen` (nur bei `is_system_template = false`)

---

## TEIL 8 · KONTEN-DRAWER

### OAuth-Connect-Flow

1. Button „Jetzt verbinden" (bei nicht-verbundenem Konto)
2. Redirect zu `POST /api/v1/integrations/outlook/connect`
3. MS-Login → Azure App Consent
4. Redirect zurück via `GET /api/outlook/auth/callback`
5. Token + Refresh-Token in `dim_integration_tokens` (secret_ref)
6. Status-Card wechselt auf ✓ OK

### Token-Erneuern

- Health-Check-Worker prüft alle 5 Min Token-Expiry
- Bei < 24h Restlaufzeit: Auto-Refresh via Refresh-Token
- Bei Fehlschlag: Banner „Email-Sync unterbrochen" + Mail an Admin
- Manueller Refresh: Button „Token erneuern" triggert sofortigen Refresh

### Trennen

- Confirm-Dialog
- Request `POST /api/v1/integrations/outlook/disconnect`
- Token lokal gelöscht · Azure-App-Permissions belassen
- Sync stoppt · bestehende `fact_history`-Einträge bleiben

### CodeTwo-Sektion

**Read-only im CRM** (Management läuft im CodeTwo-Admin-Panel):
- Status-Abfrage via CodeTwo-API (v0.2)
- Aktuelles Template anzeigen
- Links: Admin-Panel öffnen (externe URL) · Template wechseln (öffnet Admin-Panel) · Vorschau (CodeTwo Preview-API)

### Ignore-Liste

**CRUD in-drawer:**
- Tabelle mit Zeilen · jede Zeile hat `×`-Button für Remove
- Unten: Input + Typ-Select + `+ Hinzufügen`
- Speicherung: `dim_email_ignore_rules` (neu in v1.4 DB-Schema-Patch — optional)
- Alternative: User-Preferences-JSON

### Sync-Scope-Checkboxen

Persistiert in `dim_automation_settings` (pro User oder pro Tenant):
- `email_sync_only_matched_addresses` (bool, default true)
- `email_auto_classify_templates` (bool, default true)
- `calendar_bidirectional_sync` (bool, default true)
- `email_sync_internal_team_mails` (bool, default false)

---

## TEIL 9 · ENTITY-MATCH-DRAWER

### Match-Algorithmus

Score 0–100:
- **Name-Match (40%):** Levenshtein-Distanz zwischen From-Name und `dim_candidates.full_name` / `dim_account_contacts.full_name`
- **Domain-Match (30%):** From-Domain matcht `dim_accounts.email_domain`
- **Historie-Match (30%):** Recency + Frequenz früherer Interaktionen (aus `fact_history`)

**Threshold:** nur Matches mit Score ≥ 50 angezeigt. Sortiert desc.

### Match-Row-Click

Button „Zuordnen":
1. Update Email-Record: `classified_entity_id = X`, `classified_entity_type = 'candidate' | 'account'`
2. `fact_history`-Eintrag anlegen (Activity-Type „Emailverkehr - Allgemeine Kommunikation")
3. Mail verschoben von „Unbekannt" → „Klassifiziert"
4. Drawer schließen · Reader aktualisiert · Toast „Zugeordnet zu [Name]"

### Fallback-Actions

- **+ Neuen Kandidaten** → `createCandDrawer` (Match-Drawer schließen)
- **+ Neuen Account** → `createAccDrawer`
- **Mail ignorieren** → Absender zur Ignore-Liste · Mail archivieren

---

## TEIL 10 · FILE-ATTACH-DRAWER

### Laden „Aus Kontext"

1. Parent-Drawer (Compose) übergibt verknüpfte Entities
2. Request `GET /api/v1/documents?candidate_id=X&mandate_id=Y&account_id=Z`
3. Gruppiert rendern (Kandidat · Mandat · Account · Prozess · Assessment)

### Laden „Alle Dokumente"

1. `GET /api/v1/documents?q=<search>&type=<filter>` · paginated
2. Filter-Pills: PDF · Word/Excel · Bilder · Assessment-Reports · Jobbasket
3. „Weitere Ergebnisse laden"-Link am Ende

### Laden „Zuletzt verwendet"

`GET /api/v1/documents/recent-attachments?user_id=me&days=30` · sortiert DESC

### Auswahl

Multi-Select via Checkboxen. Footer-Button: „N Dateien anhängen".

**Anhänge-Flow:**
1. Selected Files werden im Compose-Drawer-Anhänge-Bereich als Chips gerendert
2. `document_id`-Referenz (nicht Re-Upload · Server holt beim Send aus `fact_documents`)
3. Total-Size-Check: bestehende Anhänge + neue ≤ 25 MB

### Drawer-Close

Drawer schließt nach Auswahl automatisch wenn „Anhängen" geklickt. Bei „Abbrechen" Auswahl verworfen.

---

## TEIL 11 · BACKEND-INTEGRATION & EVENTS

### Auto-Klassifikations-Pipeline

Beim Eingang einer Mail (`email.received`-Event):
1. `outlook.worker.ts` pollt MS Graph · schreibt Raw-Mail temporär
2. Address-Lookup:
   - From matcht `dim_candidates.email_1` / `email_2` → candidate_id setzen
   - From matcht `dim_account_contacts.email` → account_id + contact_id setzen
   - From-Domain matcht `dim_accounts.email_domain` → account_id-Vorschlag (Score-basiert)
3. Subject/Body-Match gegen `dim_email_templates.subject_pattern`:
   - Match → `linked_activity_type` + `linked_automation_key` setzen
   - Automation auslösen (z.B. Jobbasket-Update)
4. `fact_history`-Insert mit `source_system='outlook'` · `source_event_id=email_message_id`
5. WebSocket-Topic `user:{user_id}:inbox` → Live-Update

### Idempotenz

`email_message_id` (MS Graph Message-ID) als unique · `ON CONFLICT DO NOTHING` bei Re-Sync.

### Rate-Limiting (MS Graph)

- Pro User: 10.000 Requests/10min (Microsoft-Limit)
- Token-Bucket im Worker auf 5.000/10min (Safety-Margin)
- Sync-Intervall: 1 Minute (Polling) · Webhook-Subscription für Realtime (v0.2)

---

## TEIL 12 · AUDIT & ACTIVITY-LOGGING

### Alle Events werden protokolliert

| Aktion | `fact_history`-Activity-Type | Source |
|---|---|---|
| Mail empfangen + zugeordnet | aus Template oder „Emailverkehr - Allgemeine Kommunikation" | outlook.worker |
| Mail gesendet | aus Template oder User-wählbar | email.worker |
| Quick-Reply gesendet | „Emailverkehr - Allgemeine Kommunikation" | API |
| Mail „Als Aktivität erfassen" (ohne Send) | User-wählbar · default „Emailverkehr - Allgemeine Kommunikation" | API |
| Termin angelegt (Coaching) | „Interviewprozess - Coaching durchgeführt" (nach Ende) | Cron nach event_end |
| Termin angelegt (Debriefing) | „Interviewprozess - Debriefing" | Cron |
| Termin angelegt (Mandats-Pitch) | „Mandatsakquise - Pitch durchgeführt" | Cron |

### RBAC-Audit

Alle CRUD-Events (Compose · Event · Template-CRUD · Konten-Trennen) schreiben nach `fact_audit_log` mit `user_id` + `action` + `entity_type` + `entity_id`.

---

## TEIL 13 · PERFORMANCE · CACHING

- Inbox-Liste: paginated (50 Mails pro Request) · Virtual-Scrolling ab 1000+ Mails
- Mail-Body: on-demand bei Reader-Open (nicht prefetch)
- Kalender-Events: Fetch für aktuelle View ± 1 Woche
- Templates: client-seitig gecached · Invalidation bei Admin-CRUD
- Ignore-Liste: client-seitig gecached (User-spezifisch)

---

## TEIL 14 · ERROR-HANDLING

| Fehler | UX |
|---|---|
| Token expired (nicht auto-refresh-bar) | Banner oben rot: „Email-Sync unterbrochen — Jetzt neu verbinden" |
| MS Graph 429 Rate-Limit | Toast „Sync kurz pausiert · wird fortgesetzt" · Worker-Retry mit Exp-Backoff |
| Attachment > 25 MB | Inline-Fehler „Max 25 MB · Datei entfernen oder Link verwenden" |
| Invalid Recipient (bounce) | nach Send Toast-Error · Mail mit ⚠-Badge · Entity-Hinweis „Email-Adresse prüfen" |
| Template-Automation-Fehler | Toast + Admin-Alert · Mail trotzdem versendet |
| Calendar-Sync-Fehler | Event bleibt lokal sichtbar · Status „Nicht synchronisiert" · Retry-Button |

---

## TEIL 15 · GLOBALE PATTERNS (aus CLAUDE.md)

### Drawer-Default-Regel

- Compose · Event · Create-Kandidat · Create-Account · Template-Picker · Konten · Entity-Match · File-Attach: **alle Drawer**
- Ausnahme: Inline-Quick-Reply (dokumentiert in §3 Architektur-Entscheidungen)

### Datum-Eingabe-Regel

Alle Datum-/Zeit-Felder im Event-Drawer nutzen `<input type="datetime-local">` (nativer Picker + Tastatur).

### Umlaute-Regel

Alle UI-Texte verwenden echte Umlaute (ä ö ü ß). CSS classnames ohne Umlaute erlaubt (technische Notwendigkeit).

### Keine-DB-Technikdetails-Regel

Kein `dim_*`/`fact_*`/`bridge_*` in User-facing Text. Ausnahme: Spec-Dokument (dieses Dokument), Admin-/Debug-Sektionen (mit `<!-- ark-lint-skip -->`-Markern).

### Stammdaten-Wording-Regel

Activity-Type-Dropdown verwendet ausschließlich die 11 offiziellen Emailverkehr-Einträge aus STAMMDATEN v1.3 §14. Keine Freitext-Optionen.

### Arkadium-Rolle-Regel

Aktivitäts-Typen im Event-Drawer unterscheiden Coaching (Arkadium↔Kandidat) vs. Interview-extern (Kunde↔Kandidat, read-only). Arkadium nimmt nicht an Interviews teil.

---

## TEIL 16 · OFFENE PUNKTE

- [ ] Thread-Ansicht statt Single-Mail-Reader (v0.3)
- [ ] Bulk-Actions auf Mail-Liste (markieren, archivieren, verschieben mehrerer)
- [ ] Draft-Konflikte (gleichzeitige Bearbeitung) — Last-Write-Wins vs. Lock
- [ ] Kalender-Ressourcen-Buchung (Räume, Geräte)
- [ ] Email-Rules (Auto-Labeling, Filter-Erzeugung vom Reader aus)
- [ ] Mobile-Responsive-Breakpoints (<1280px · <1024px · <768px)
- [ ] Accessibility · Keyboard-Navigation · ARIA-Rollen

---

## TEIL 17 · CROSS-REFERENCES

- [[email-kalender-detailmaske-schema]] — Layout · Felder · Drawer-Inventar
- [[kandidatenmaske-interactions]] — History-Tab-Interaktion (wo Emails erscheinen)
- [[account-detailmaske-interactions]] — Kontakt-Drawer Kommunikations-Tab
- [[email-system]] — Concept-Wiki (Architektur, CodeTwo, Ordner-Modell)
- [[spec-sync-regel]] — Governance-Matrix · 10. Detailmaske
- [[mockup-baseline]] — Drawer-Snippets · Form-Row-Patterns · File-Row-Pattern (neu)
