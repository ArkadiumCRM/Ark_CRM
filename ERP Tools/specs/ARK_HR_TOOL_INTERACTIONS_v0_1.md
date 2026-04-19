---
title: "ARK HR-Tool · Interactions v0.1"
type: interactions
phase: 3
created: 2026-04-19
updated: 2026-04-19
status: draft
based_on: "ARK_HR_TOOL_SCHEMA_v0_1.md · ARK_HR_TOOL_PLAN_v0_2.md"
sources: [
  "ARK_HR_TOOL_PLAN_v0_2.md",
  "ARK_HR_TOOL_SCHEMA_v0_1.md",
  "wiki/concepts/interaction-patterns.md",
  "wiki/meta/mockup-baseline.md",
  "mockups/ERP Tools/hr.html",
  "mockups/ERP Tools/hr-list.html"
]
tags: [interactions, ui-flow, hr, phase-3, drawer, saga, events]
---

# ARK HR-Tool · Interactions v0.1

UI-Flow-Definitionen · Drawer-Interaktionen · Use-Case-Workflows · Saga-Sequenzen · Event-Trigger-Matrix. Basiert auf Plan v0.2 §5 + §7 und Schema v0.1.

**Prinzipien:**
- Drawer-Default-Regel: CRUD immer als Drawer · Modal nur für Confirm/Blocker
- Sensible-Daten-Maskierung mit Audit-Log-Pflicht bei Aufdecken
- Optimistic-Update für schnelle UX · Rollback bei Server-Fehler
- Events als Single-Source-of-Truth · UI-Status aus `fact_history`-Projektion (Activity-Linking-Regel)
- Kein Drag-Rückwärts im Kanban (Annullierung via Kontext-Menü)

## TOC

- §1 Scope + Global-Patterns
- §2 Dashboard `/hr`
- §3 MA-Side-Panel (8 Accordion-Sektionen)
- §4 Drawer-Inventar (19 Drawer)
- §5 Lifecycle-Saga
- §6 Worker + Event-Trigger-Matrix
- §7 Self-Service-UI
- §8 Mobile-Support
- §9 RBAC-UI-Gates
- §10 Related + Changelog

---

## §1 Scope + Global-Patterns

### §1.1 Drawer-Breiten

| Breite | Use-Case | Beispiele |
|--------|----------|-----------|
| 540px (Default) | Single-Entity-CRUD · Bestätigung | Ferienantrag · HO-Antrag · Krankmeldung · Dokument-Upload · Zertifikat |
| 760px (Wide-Tabs) | Multi-Tab-Workflow · Bündel-PDF | Neuer MA (4 Tabs) · Probezeit-Abschluss · Verwarnung · Disziplinar · Provisionsvertrag-Renewal · Aufhebungsvereinbarung · Arbeitszeugnis-Generator (Dok-Generator) |
| Full-Screen-Sheet | Mobile | Alle Drawer auf Mobile-Viewport |

### §1.2 Sensible-Daten-Masking

**Felder mit Masking-Pflicht:**
- `ahv_nr` → `756.••••.••••.••` (nur letzte 2 Ziffern bei Aufdecken)
- `pass_nr` → `X•••••••••`
- `base_salary_chf_annual` → `CHF •••'•••` (nur HR + Backoffice + Self)
- `bankverbindung` → existiert nicht im HR-Tool (Payroll-externe Ref)
- `hintergrund_check_result` → gemaskt als `••••••` bis Aufdecken

**Aufdeck-Flow:**
1. Button "Sensible Daten anzeigen" klicken
2. Modal: "Begründung für Aufdecken eingeben" (Textfeld, Pflicht)
3. Nach Eingabe → `audit_hr_access` INSERT mit `action='reveal_sensitive'` + `reason`
4. Feld wird 5 Minuten unmaskiert angezeigt, danach auto-remasked
5. Audit-Trail nachträglich einsehbar für HR-Compliance

### §1.3 Optimistic-Update-Pattern

**Standard-Flow (PATCH/POST):**
1. UI zeigt Änderung sofort (optimistic)
2. Backend-Request im Hintergrund
3. Bei Erfolg: UI bleibt · WebSocket-Event broadcast
4. Bei Fehler: UI rollback + Toast-Error · Retry-Option

**Ausnahmen (blocking):**
- Signatur-Flows (MA + Head + GL bei Provisionsvertrag)
- Payroll-Verrechnung (Disziplinar-Offset)
- Lifecycle-Stage-Transitions mit Saga-Trigger

### §1.4 Audit-Log-Triggers (implizit durch Backend-Middleware)

Jede Action loggt in `audit_hr_access`:
- `view` · bei jedem MA-Side-Panel-Öffnen (nur `read`-Action · Sampling für Performance)
- `reveal_sensitive` · bei AHV/Pass/Gehalt-Aufdecken
- `update` · bei jedem Field-Change · mit `field_changed`
- `create` · bei neuen Entities
- `delete` · nie hard-delete, immer soft-delete mit `deleted_at`
- `export` · bei DSG-Auskunft-Download
- `download` · bei Dokument-Download

### §1.5 Kein Drag-Rückwärts im Kanban

Peter-Entscheidung §11C-7: Lifecycle-Stage-Transitions nur **Vorwärts** im Kanban-Drag · Rückwärts via Kontext-Menü-Aktionen (z.B. "Kündigung annullieren", "Probezeit zurücksetzen").

---

## §2 Dashboard `/hr`

### §2.1 Header + Top-Bar

```
┌─────────────────────────────────────────────────────────────────┐
│ HR-Dashboard                                 [⌘K Search] [+Neu] │
├─────────────────────────────────────────────────────────────────┤
│ 👥 18 MA aktiv · 2 in Onboarding · 1 offboarding · 3 Alumni     │
└─────────────────────────────────────────────────────────────────┘
```

**Search:** Fuzzy-Match auf MA-Namen · Funktion · Email.
**+Neu:** öffnet Drawer "Neuer MA anlegen" (760px, 4-Tab) — siehe §4.1.

### §2.2 Alert-Cards (aus `v_hr_alerts`)

5 Alert-Cards nebeneinander, nach `severity` sortiert (urgent → warning → info):

```
┌─ Urgent ─────┐  ┌─ Urgent ──────┐  ┌─ Warning ────┐  ┌─ Info ──────┐  ┌─ Info ──────┐
│ Probezeit    │  │ Zertifikat    │  │ Verwarnung   │  │ HO-Antrag   │  │ Jubiläum    │
│ 2            │  │ 1 expiring    │  │ 1 Follow-up  │  │ 3 pending   │  │ 1 in 7 Tg   │
│ [Anzeigen]   │  │ [Anzeigen]    │  │ [Anzeigen]   │  │ [Anzeigen]  │  │ [Anzeigen]  │
└──────────────┘  └───────────────┘  └──────────────┘  └─────────────┘  └─────────────┘
```

**Interaktion:** Klick auf Card öffnet gefilterte Liste (Dialog bzw. Filter-Ansicht).

### §2.3 Action-Queue (8–10 offene Tasks)

Pro Alert eine Row:
- `🔴 Probezeit Sonja Bee Spiess endet in 5 Tagen · Gespräch terminieren` → Button "Probezeit-Abschluss"
- `🟡 Zertifikat Scheelen-EQ Aysun Y. läuft 30 Tage ab · Renewal planen` → Button "Schulung anfordern"
- `🟡 Verwarnung Tatjana P. · Follow-up in 14 Tagen fällig` → Button "Review + Decision"
- `🔵 3 HO-Anträge warten auf Freigabe` → Button "Genehmigen"

### §2.4 Team-Kalender-Matrix (18 MA × 7 Tage)

Wochen-View (Mo–So · heute orange markiert):

```
         Mo 20  Di 21  Mi 22  Do 23  Fr 24  Sa 25  So 26
Peter W. [🟢]   [🟢]   [🏠]   [🟢]   [🟢]   [—]    [—]
Sonja S. [🟢]   [🤒]   [🤒]   [🤒]   [🤒]   [—]    [—]
Aysun Y. [🟢]   [🟢]   [🟢]   [✈️]   [✈️]   [✈️]   [✈️]
...
```

**Legende:** 🟢 Vor-Ort · 🏠 HO · 🌍 Remote · ✈️ Ferien · 🤒 Krankheit · 🎓 Schulung · 🤱 Mutterschaft · 🎖 Militär

**Interaktion:**
- Klick auf Zelle → Mini-Popup mit Absenz-Details
- Klick auf MA-Name → Side-Panel öffnet (§3)
- Navigation: ◀ ▶ für Woche wechseln · Quartal/Monat-View-Toggle

### §2.5 Lifecycle-Pipeline (7 Spalten Kanban)

```
Offer → Vertrag → Onboarding → Aktiv → Under-Watch → Offboarding → Alumni
  (2)     (1)        (2)        (12)      (1)           (1)          (3)
```

**Unterteilung "Under-Watch" / "Final-Watch" / Offboarding-Branches:** in Sub-Spalten innerhalb der Hauptspalte anzeigen, oder als Sub-Tabs im "Offboarding"-Drill-Down.

**Interaktion Drag:**
- **Vorwärts erlaubt:** Offer → Vertrag · Vertrag → Onboarding · Onboarding → Aktiv · Aktiv → Under-Watch · Under-Watch → Final-Watch · jeder State → Offboarding-Branch → Alumni
- **Rückwärts via Kontext-Menü:** "Kündigung annullieren" · "Probezeit zurücksetzen"
- **Drop triggered Confirm-Modal:** "Status-Wechsel von X zu Y bestätigen?" + Optional-Drawer für Zusatz-Info (z.B. Offboarding-Grund)

### §2.6 MA-Liste (Tabelle)

Filter-Bar oben: Funktion · Sparte · Lifecycle-Stage · Head-of-Department · Eintrittsjahr

Spalten: MA-Name · Funktion · Sparte · Eintrittsdatum · Dienstjahre · Lifecycle-Stage · Head · nächstes Event (Jubiläum / Renewal / Zertifikat-Expire)

Klick auf Zeile → Side-Panel öffnet.

---

## §3 MA-Side-Panel (8 Accordion-Sektionen)

Side-Panel 620px · öffnet von rechts · schließbar via ESC oder X.

```
┌──────────────────────────────────────┐
│ Peter Wiederkehr                     │
│ Head of Civil Engineering & BT       │
│ Seit 2019-02-01 · 7 Dienstjahre      │
│                        [✕ Schließen] │
├──────────────────────────────────────┤
│ [Stammdaten-Snapshot-Bar]            │
│ 📍 Zürich · 100% · CHF ••• · 2 Kinder│
├──────────────────────────────────────┤
│ ▸ 1. Stammdaten (Person + Adresse)   │
│ ▸ 2. Vertrag (aktiv + Historie)      │
│ ▸ 3. Absenzen (Ferien · HO · Krank)  │
│ ▸ 4. Academy-Fortschritt             │
│ ▸ 5. Zertifikate + Schulungen        │
│ ▸ 6. Dokumente (chronologisch)       │
│ ▸ 7. Verwarnungen + Disziplinar      │
│ ▸ 8. Provisionsvertrag + Rollen      │
└──────────────────────────────────────┘
```

**Sektion 1 · Stammdaten:**
- Person: Vorname, Nachname, Geburtsdatum, Geschlecht, Nationalität, Zivilstand, Muttersprache
- Adresse: Strasse, PLZ/Ort, Kanton, Land
- Kontakt: Email, Telefon
- Notfallkontakte (max 2): Name, Beziehung, Phone
- CH-Compliance (maskiert, Audit-Reveal): AHV · Pass · Arbeitsbewilligung · Pensionskasse
- Inline-Edit pro Feld · Save on blur

**Sektion 2 · Vertrag:**
- Aktiver Vertrag: Typ, Pensum, Jobtitel (Progressus-Link), Probezeit-Ende, Kündigungsfristen-Übersicht, Karenzentschädigung, Konkurrenzverbot-Parameter
- Historie: alle vorherigen Verträge (mit Vertrags-Änderungen bei Pensum/Rolle-Wechsel)
- Button "Vertrag bearbeiten" → Drawer §4.2
- Button "Vertrags-Addendum erstellen" → Drawer §4.2 mit Pre-Fill

**Sektion 3 · Absenzen:**
- Ferien-Saldo: Remaining · Used · Pending · Carry (mit Deadline)
- Extra-Guthaben (5 Kategorien): Stand pro Kategorie
- HO-Quota: 12/20 HO · 3/10 Remote
- Krankheit-Historie (letzte 12 Mt)
- Button "Ferienantrag" · "Krankmeldung" · "HO-Antrag" → Drawer §4.3/§4.4/§4.5

**Sektion 4 · Academy-Fortschritt:**
- Fortschrittsbalken: 12/21 Module abgeschlossen
- Liste pro Modul: Status (abgeschlossen · in Arbeit · nicht begonnen) · Trainer · Datum · Score
- Button "Modul starten" · "Modul abschließen" → Inline-Form

**Sektion 5 · Zertifikate + Schulungen:**
- Aktive Zertifikate: Scheelen-MDI/Relief/ASSESS/EQ (Pflicht · §11C-9) + andere
- Status pro Zertifikat: active · expiring · expired
- Button "Zertifikat erfassen" · "Schulung anfordern" → Drawer §4.7/§4.6
- Button "Weiterbildungsvereinbarung erstellen" → Drawer §4.8

**Sektion 6 · Dokumente:**
- Chronologische Liste: Typ · Name · Datum · Retention-bis · Sichtbarkeit
- Filter: Typ · Jahr
- Button "Dokument hochladen" → Drawer §4.9
- Klick auf Dokument → Preview + Download (loggt `audit_hr_access.action='download'`)

**Sektion 7 · Verwarnungen + Disziplinar:**
- Verwarnungen-Timeline: verbal → first_written → final_written (Icons rot/orange)
- Disziplinar-Incidents: investigation · confirmed · paid · dismissed
- Button "Verwarnung ausstellen" · "Disziplinar melden" → Drawer §4.11/§4.12

**Sektion 8 · Provisionsvertrag + Rollen:**
- Aktiver Provisionsvertrag (Fiscal-Year): Budget-Ziel · Fix · Variabel · Spesen · Signatur-Status
- Rollen-Historie aus `fact_role_transitions`
- §5.3-Grace-Period-Alerts (falls Researcher→Consultant-Wechsel aktiv)
- Button "Renewal starten" → Drawer §4.13 (typisch Q4-Worker-getriggert)

---

## §4 Drawer-Inventar

### §4.1 Neuer MA anlegen (760px · 4-Tab)

**Trigger:** `/hr` Dashboard "+ Neu" Button · oder Kanban-Drop in Spalte "Offer".

**Tabs:**

#### Tab 1 · Basis-Daten
- Vorname, Nachname (Pflicht)
- Geburtsdatum (Pflicht)
- Email (Pflicht · Unique-Check)
- Telefon
- Adresse (Strasse, PLZ, Ort, Kanton, Land)
- Geschlecht (Select: w/m/d)
- Nationalität
- Zivilstand
- Muttersprache (Default 'de')
- Weitere Sprachen (Chips)

#### Tab 2 · Vertrag
- Stellenantritt (Date-Picker · Pflicht)
- Vertragstyp (unbefristet/befristet/...)
- Pensum % (Slider 10–100)
- Hours per Week (auto: Pensum × 0.45)
- Jobtitel → **Progressus-Selector** (aus `dim_job_descriptions` · aktive Version)
- Bruttobasisgehalt (CHF/Mt)
- Karenzentschädigung (auto-fill aus Job-Description · override möglich)
- Home-Office-Allowance (default 20)
- Remote-Allowance (default 10)
- Probezeit-Monate (default 3 · gelockt bei <3 per §11A-12)
- Kündigungsfristen-Preview (aus JSONB-Default)
- Konkurrenzverbot-Parameter (Default 18 Mt Deutschschweiz)

#### Tab 3 · Anhänge (5 Reglemente/Vorlagen)

Checkliste mit Pre-Selection:
- ☑ Reglement "Generalis Provisio" v2024-01-01
- ☑ Reglement "Tempus Passio 365" v2024-01-01
- ☑ Reglement "Locus Extra" v2024-01-01
- ☑ Stellenbeschreibung "Progressus" (auto aus Tab 2)
- ☐ Provisionsvertrag "Praemium Victoria" (optional · für Researcher ohne Praemium auch weglassbar)

Pro Zeile: Version-Anzeige · "Details" Link · Auto-generieren-Option für fehlende PDFs.

#### Tab 4 · Review + Bundle-PDF

- Zusammenfassungs-Preview (read-only)
- Fehler/Warnungen (z.B. "Karenzentschädigung 0 für Consultant – Default wäre CHF 500")
- Button "Bündel-PDF generieren" → Dok-Generator mit allen 5 Anhängen
- Button "An MA senden für Signatur" → Email mit Signatur-Link
- Button "Als Entwurf speichern"

**Events:**
- `mitarbeiter_created`
- `contract_signed` (wenn alle 3 Signaturen · Trigger via Signatur-Webhook)
- `lifecycle_stage_changed` (offer → vertrag → onboarding)

### §4.2 Vertrag bearbeiten (540px)

**Trigger:** MA-Side-Panel §3 Sektion 2 Button "Vertrag bearbeiten".

Felder wie Tab 2 von §4.1 · pre-filled aus aktivem Vertrag · "Speichern" erstellt neuen `fact_employment_contracts`-Row (altes `valid_until = today`) ODER als Vertrags-Addendum (abhängig von Change-Scope).

### §4.3 Ferienantrag (540px)

**Trigger:** Side-Panel §3 Sektion 3 "Ferienantrag" · oder Self-Service-Dashboard.

**Felder:**
- Zeitraum (Start/End · Date-Pickers)
- Halber-Tag-Start/End (Toggles)
- Working-Days (auto-berechnet aus Kalender + Feiertage · non-editierbar)
- Notizen
- Stellvertretung (MA-Select aus Team)
- Outlook-Auto-Reply (Toggle · default true)
- **Saldo-Anzeige-Sidebar:**
  - Default-Ferien Remaining: 17.5 Tage
  - Carry-Vorjahr: 5 Tage (Deadline 2026-04-20)
  - Extra-Guthaben:
    - Geburtstag Self: 1 Tag (verfügbar in Geburtstagswoche 15.–21. Juni)
    - Geburtstag Close: 1 Tag
    - Jokertag: 1 Tag
    - ZEG H1: 0 Tage (noch nicht berechnet)
    - ZEG H2: 1 Tag (aus 2025-Zielerreichung)

**Validation:**
- Min Lead-Time: 2 Werktage → 2 Wochen Vorlauf · 3+ Tage → 1 Monat Vorlauf (§ Tempus Passio 365)
- Team-Abdeckung-Check: Min 50% vor Ort (Config `vacation_team_coverage_min_pct`)
- Extra-Guthaben-Constraints (nur in Geburtstagswoche · nur in Sperrfristen für ZEG)

**Events:** `vacation_requested` · nach Genehmigung `vacation_approved`.

### §4.4 Krankmeldung (540px)

**Trigger:** Side-Panel §3 Sektion 3 "Krankmeldung" · oder Self-Service vor 08:00 Uhr (Generalis Provisio §3.5.2).

**Felder:**
- Zeitraum (Start/End)
- Notiz (Symptomfrei-Bestätigung optional)
- Arztzeugnis (Upload-Feld)

**Arztzeugnis-Staffel-Anzeige:**
- Dynamisch aus `dim_absence_types.certificate_staffelung_jsonb` + Mitarbeiter-Dienstjahr
- "Dienstjahr X · Arztzeugnis ab Tag Y Pflicht"

**Validation:**
- Auto-calculate `certificate_required` bei Save
- Wenn Zeugnis-Pflicht aber nicht hochgeladen: Warning · Eintrag trotzdem akzeptiert · Reminder-Mail an MA
- AG kann via HR-Toggle jederzeit Zeugnis ab Tag 1 verlangen

**Events:** `absence_started`.

### §4.5 Home-Office-Antrag (540px)

**Trigger:** Side-Panel §3 Sektion 3 "HO-Antrag" · oder Self-Service.

**Felder:**
- Datum (Date-Picker · muss ≥ heute + 48h sein)
- Request-Typ (Radio: HO · Remote-Work)
- Projekt-Context (Textfeld · Pflicht · Locus Extra §-Anforderung)

**Quota-Sidebar:**
- HO: 8/20 verwendet · 12 Tage Remaining
- Remote: 3/10 verwendet · 7 Tage Remaining
- Diese Woche: 1× HO bereits gebucht (max 1/Woche) · 0× Remote (max 2/Woche)

**Validation:**
- 48h-Lead-Time
- Probezeit-Check (nicht während)
- Team-Coverage 70% (Config `homeoffice_team_coverage_min_pct`)
- Keine Woche mit Ferien/Krankheit kombinierbar
- Max 1 HO/Woche · Max 2 Remote/Woche

**Events:** `homeoffice_request_submitted` → Genehmigung → `homeoffice_request_decision`.

### §4.6 Schulung anfordern (540px)

**Trigger:** Side-Panel §3 Sektion 5 "Schulung anfordern" · oder Self-Service.

**Felder:**
- Titel, Provider, Typ (Zertifizierung/Seminar/Konferenz/Online/Coaching)
- Zeitraum
- Kosten (Kurs + Travel)
- Begründung (Freitext · Pflicht)
- Erwartetes Zertifikat (Toggle)

**Validation:** Manager-Approval benötigt · Budget-Check aus `fact_compensation_history.training_budget_chf`.

**Events:** neuer `fact_training_requests`-Entry mit `status='submitted'` · Notification an Vorgesetzten.

### §4.7 Zertifikat erfassen (540px)

**Trigger:** Side-Panel §3 Sektion 5 "Zertifikat erfassen" · oder Self-Service.

**Felder:**
- Zertifikats-Typ (Select aus `dim_certifications` · Scheelen-4 oben · andere darunter)
- Acquired-Date
- Valid-Until (optional · je nach `typical_validity_months`)
- Zertifikat-Dokument (Upload)
- Kosten (optional · aus Training-Request verlinkbar)

### §4.8 Weiterbildungsvereinbarung (540px)

**Trigger:** Side-Panel §3 Sektion 5 "Weiterbildungsvereinbarung erstellen".

**Felder:**
- Titel, Provider
- Zeitraum (Start · Expected-Completion)
- Pensum-Reduktion % (Slider 0–50 · Default 5 wenn Schulung)
- Gehalt 100% trotz Pensum-Reduktion (Toggle · default true)
- AG-Kostenbeteiligung pro Semester (CHF)
- Semester-Anzahl (Default 2)
- Total-Kostenbeteiligung (auto-berechnet)

**Rückzahlungs-Vorschau-Sidebar:**
- Bei Austritt 0–12 Mt nach Abschluss: 100% Rückzahlung (CHF X)
- 13–18 Mt: 50% (CHF X/2)
- 19–24 Mt: 25% (CHF X/4)
- 25+ Mt: 0%

**Button "Agreement-PDF generieren"** → Dok-Generator mit Template.

### §4.9 Dokument hochladen (540px)

**Trigger:** Side-Panel §3 Sektion 6 "Dokument hochladen" · oder Bulk-Upload in Admin-View.

**Felder:**
- Dokument-Typ (Select aus `document_type`-Enum)
- Name
- Document-Date
- Expiry-Date (optional)
- Upload-Feld
- Retention-Jahre (auto-gesetzt je Typ: Zeugnisse 5 J · Verträge 10 J · Lohnausweise 10 J)
- Sichtbarkeit (Radio: hr_admin_self / hr_admin_only / hr_admin_self_supervisor)
- Legal-Hold-Flag (Admin-only)

### §4.10 Probezeit-Abschluss (760px · Wide-Tabs)

**Trigger:** Dashboard-Alert "Probezeit endet in 30 Tagen" · oder Side-Panel §3 Sektion 2.

**Tabs:**
1. **Entscheidung** — Radio: Übernahme / Verlängerung / Abbruch · Datum
2. **Feedback Vorgesetzter** — Textfelder für Stärken · Entwicklungspunkte · Empfehlung
3. **Feedback MA** — Selbsteinschätzung · Wünsche · Bemerkungen
4. **Vereinbarungen** — ggf. neue Probezeit-Verlängerung · Gehalts-Änderung · Rolle-Wechsel

**Events:**
- `probezeit_passed` → Lifecycle `onboarding → aktiv`
- `probezeit_failed` → Lifecycle `onboarding → offboarding_notice`

### §4.11 Verwarnung ausstellen (760px · Wide-Tabs)

**Trigger:** MA-Side-Panel §3 Sektion 7 "Verwarnung ausstellen" · nur HR_Manager + Founder + Head.

**Tabs:**
1. **Typ + Kontext**
   - Typ (Radio: verbal · first_written · final_written · notice_fristlos)
   - Issued-Date (Default heute)
   - Reason (Textfeld · Pflicht)
   - Legal-Refs (Multi-Select: OR 321a · ZGB 28 · StGB 173 · andere)

2. **Follow-up**
   - Follow-up-Deadline (default 30 Tage)
   - Alternative Offered (Textfeld · z.B. "Aufhebungsvertrag angeboten")
   - Konkrete Verhaltens-Erwartung

3. **Dokument + Benachrichtigung**
   - Template-Auswahl (aus Dok-Generator)
   - Preview + Generate-Button
   - Unterschrifts-Flow: MA-Empfangsbestätigung-Tracking
   - Notification via Email + Personal-Gespräch

**Saga bei Final-Written:**
- Lifecycle `aktiv → final_watch`
- Automatischer Follow-up-Check-Reminder nach Deadline
- Eskalations-Branch: compliance / mutual_agreement / termination

**Events:** `warning_issued` · nach MA-Confirm `warning_acknowledged` · bei Deadline `warning_follow_up_deadline`.

### §4.12 Disziplinar-Incident (760px · Wide-Tabs)

**Trigger:** MA-Side-Panel §3 Sektion 7 "Disziplinar melden" · nur HR + GL.

**Tabs:**
1. **Vorfall**
   - Penalty-Type-Select (aus `dim_disciplinary_penalty_types`)
   - Incident-Date
   - Beschreibung

2. **Evidenz**
   - Document-Upload (mehrfach · z.B. E-Mails, Zeugen-Statements)
   - Penalty-Amount-CHF (pre-filled aus Typ · override erlaubt mit Notiz)

3. **Status + GL-Approval**
   - Status (investigation · confirmed · dismissed)
   - GL-Approval-Button (nur für Founder-Rolle · setzt `gl_approved_at/by`)
   - Begründung GL-Approval (Pflicht)

4. **Payroll-Verrechnung** (nur wenn Status=`confirmed` UND `gl_approved`)
   - Toggle "Mit Lohn verrechnen"
   - MA-Notified-Date (Default: heute)
   - Offset-Effective-Date (min = notified_date + 1 Monat · §11C-4-Constraint)
   - Preview: "Verrechnung wird im Lohnlauf April 2026 verrechnet"

**Events:** `disciplinary_incident_reported` · `disciplinary_penalty_confirmed` · `disciplinary_offset_scheduled`.

### §4.13 Provisionsvertrag Jahres-Renewal (760px · Wide-Tabs)

**Trigger:** Q4-Worker "Renewal in 60 Tagen fällig" · oder manuell aus Side-Panel.

**Tabs:**
1. **Fiscal-Period**
   - Fiscal-Year (Default kommendes Jahr)
   - Period-Start (Default 01.01. · pro-rata für Neueintritte)
   - Period-End (Default 31.12.)
   - Rolle (Select: consultant/researcher/CM/AM/team_leader/head_of_department)

2. **Budget-Ziel**
   - Budget-Goal-CHF (Head + GL setzen)
   - Team-Budget-Goal (nur bei Team Leader · eigenes + unterstellte)
   - Historie letzte 3 Jahre als Referenz

3. **Gehalt**
   - Fix-Salary-Year-CHF
   - Variable-100%-CHF (bei ZEG 100%)
   - Spesenpauschale-CHF/Mt (Default 300)
   - Payout-Advance-% (Default 80)
   - ZEG-Staffel-Referenz (aus Commission-Engine)

4. **Signatur-Flow**
   - Bündel-PDF-Preview + Generate
   - Signatur-Status-Tracking: MA · Head · Founder (alle 3 Pflicht für `is_active`)
   - Send-for-Signature-Buttons

**Events:** `provisionsvertrag_renewal_due` (vom Worker) · `provisionsvertrag_signed` bei allen 3 Signaturen.

### §4.14 Kündigung einreichen (540px)

**Trigger:** Side-Panel oder Kanban-Drop auf "Offboarding".

**Felder:**
- Kündigungs-Art (Radio: AG-ordentlich · AG-fristlos · AN-ordentlich · AN-fristlos · Aufhebungsvereinbarung)
- Kündigungs-Datum
- Letzter Arbeitstag (auto-berechnet aus Kündigungsfrist + Art)
- Freistellung (Toggle)
- Grund (Textfeld · optional · bei AG-fristlos Pflicht)
- **Extra-Guthaben-Override-Toggle (§11C-11):** "Extra-Guthaben a/b/c trotz Kündigung weiter gewähren?" + Begründung

**Auto-Triggers bei Save:**
- Offboarding-Template auto-attach
- Konkurrenzverbot-Clock aktivieren (`austrittsdatum + 18 Mt`)
- Lifecycle → entsprechender Offboarding-Branch

**Events:** `lifecycle_stage_changed` · `offboarding_started`.

### §4.15 Kündigung annullieren (540px)

**Trigger:** Kontext-Menü-Aktion "Kündigung annullieren" in Offboarding-Kanban-Card (§11C-7 · kein Drag-Rückwärts).

**Felder:**
- Referenz zur Kündigung (pre-filled · read-only)
- Annullierungs-Datum (Default heute)
- Grund (Textfeld · Pflicht)
- Nahtlos-Bestätigung (Checkbox: "Arbeitsverhältnis setzt ohne neue Probezeit fort")
- Annullierungs-Dokument (Upload optional · Template-Generate-Option)

**Auto-Triggers:**
- Lifecycle → `aktiv` (zurück)
- Konkurrenzverbot-Clock deaktivieren
- Offboarding-Tasks (falls begonnen) pausieren

**Events:** `termination_annulled` · Audit-Log mit Vor/Nach-Status.

### §4.16 Aufhebungsvereinbarung (760px · Wide-Tabs)

**Trigger:** Kontext-Menü aus Kanban · typisch nach Final-Written-Verwarnung oder als Alternative zur Kündigung.

**Tabs:**
1. **Typ** — Freistellung vs Nach-Kündigung
2. **Konditionen** — Letzter Arbeitstag · Freistellung-Start · Gehalt bis wann · Vacations · Bonuszahlung · Karenzentschädigung
3. **Geheimhaltung + Konkurrenzverbot** — Referenz-Check zum Arbeitsvertrag · Modifikationen (z.B. Verkürzung Konkurrenzverbot)
4. **Dokument + Per-Saldo-Klausel** — Template-Generate · Unterschriften-Flow

**Events:** `aufhebungsvereinbarung_signed` · Lifecycle → `offboarding_amicable`.

### §4.17 Arbeitszeugnis-Generator

**Hinweis (Peter-Entscheidung §11B-3):** Nicht im HR-Tool implementiert · läuft über **globalen Dok-Generator** `/operations/dok-generator`.

**Integration:**
- Side-Panel §3 Sektion 6 "Arbeitszeugnis generieren" → öffnet Dok-Generator mit Pre-Selection:
  - Template: `arbeitszeugnis_consultant` oder `arbeitszeugnis_researcher` oder `arbeitsbestaetigung`
  - Context: MA-ID (für Auto-Fill aus `dim_mitarbeiter` + `fact_employment_contracts` + Academy-Fortschritt)
- Output landet in `fact_hr_documents.document_type='arbeitszeugnis'`

### §4.18 Extra-Guthaben bezu (540px)

**Trigger:** Self-Service oder Ferienantrag-Drawer mit "Extra-Guthaben verwenden"-Toggle.

**Felder:**
- Kategorie (Select: birthday_self · birthday_close · joker · zeg_h1 · zeg_h2 · gl_discretionary)
- Datum (Date-Picker)
- Anlass (Textfeld · optional)

**Validation (aus `dim_absence_types.bezugs_constraint_jsonb`):**
- birthday_self: Datum in MA-Geburtstagswoche
- birthday_close: Name + Datum der nahestehenden Person
- zeg_h1/h2: nur in Sperrfristen (24.12.–01.01. · Sechseläuten · Knabenschiessen · Brückentage)

### §4.19 Reglement-Signatur (540px)

**Trigger:** HR published neue Reglement-Version mit `requires_bulk_resignature = true` · MA bekommt Notification.

**Flow:**
- MA öffnet Drawer
- Reglement-PDF-Preview (aus `document_print_url`)
- Checkbox "Ich bestätige, die Bestimmungen gelesen und verstanden zu haben"
- Button "Elektronisch signieren"
- `fact_contract_attachments.signed_at` + `signed_by_mitarbeiter=true` gesetzt

**Events:** `reglement_signed_by_ma`.

---

## §5 Lifecycle-Saga

### §5.1 Happy-Path-Flow

```
[New Offer Drawer § 4.1]
  ↓ alle 3 Signaturen
  → lifecycle=offer · contract_created · mitarbeiter_created
  ↓ Vertrag signiert
  → lifecycle=vertrag
  ↓ Start-Datum erreicht (Cron)
  → lifecycle=onboarding · onboarding_instance created (Template aus role_at_contract)
  ↓ Probezeit-Abschluss (§4.10 Tab 1 = Übernahme)
  → lifecycle=aktiv · probezeit_passed
```

### §5.2 Verwarnungs-Eskalation

```
lifecycle=aktiv
  ↓ §4.11 verbal (nur Notiz · kein Stage-Change)
  ↓ §4.11 first_written
  → lifecycle=under_watch · warning_issued
  ↓ Follow-up-Deadline läuft (30 Tage)
  ├─ resolution='compliance' → lifecycle=aktiv (zurück)
  └─ §4.11 final_written
     → lifecycle=final_watch
     ↓ Entscheidung
     ├─ 'compliance' → lifecycle=aktiv
     ├─ 'mutual_agreement' → §4.16 Aufhebungsvereinbarung → lifecycle=offboarding_amicable
     ├─ 'termination_immediate' (fristlos Art. 337 OR) → lifecycle=offboarding_immediate
     └─ 'termination_notice' (ordentlich) → §4.14 Kündigung → lifecycle=offboarding_notice
```

### §5.3 Offboarding-Branches

```
offboarding_amicable | offboarding_immediate | offboarding_notice | offboarding_special
  ↓ (alle) Offboarding-Checkliste attached (15 Tasks · §5.6 Plan v0.2):
    - IT-Deprovisioning
    - Geräte-Rückgabe
    - KKV-Merkblatt + Rückläufer
    - Abredeversicherungs-Merkblatt + Rückläufer
    - Arbeitszeugnis (Dok-Generator)
    - Pensionskasse-Austritt
    - Schlussabrechnung (inkl. Weiterbildungs-Rückzahlung)
    - AHV-Austrittsmeldung
    - BVG-Austrittsmeldung
    - Akten-Rückgabe
    - Konkurrenzverbots-Erinnerung + Karenz-Check
    - Schlüssel/Badge
    - Provisions-Endabrechnung (Commission-Engine §6.2 laufende Prozesse)
    - Email-Auto-Reply
    - Alumni-Status + 18-Mt-Clock
  ↓ Alle Tasks done + letzter Arbeitstag erreicht
  → lifecycle=alumni
  ↓ Cron täglich prüft konkurrenzverbot_aktiv_bis
  → nach 18 Mt: Audit-Trail-Entry "Konkurrenzverbot abgelaufen"
```

### §5.4 Role-Transition (Researcher → Consultant)

```
§4.2 Vertrag bearbeiten · Rolle ändern
  → fact_role_transitions entry (effective_date, reason='promotion', grace_period=3 Mt)
  → grace_period_ends_at = effective_date + 3 Monate
  ↓ In dieser 3-Mt-Window:
    - Commission-Engine berechnet für alte Researcher-Erstansprache-Kandidaten noch Provisionen
    - Nach 3 Mt: §5.3 Praemium-Victoria-Grace-Period endet
  → Karenzentschädigung bleibt individualverhandelt (§11C-2 · kein Automatismus)
```

### §5.5 Annullierung (Reverse)

```
lifecycle=offboarding_*
  ↓ §4.15 Kündigung annullieren (Kontext-Menü · kein Drag-Rückwärts)
  → lifecycle=aktiv (nahtlos · keine neue Probezeit · §11C-7)
  → Konkurrenzverbot-Clock gelöscht
  → Offboarding-Tasks gecancelt
```

---

## §6 Worker + Event-Trigger-Matrix

### §6.1 Worker-Inventar

| Worker | Intervall | Zweck |
|--------|-----------|-------|
| `hr-probezeit-reminder.worker` | daily 08:00 | Alert 30 Tage vor Probezeit-Ende |
| `hr-certification-expiry.worker` | weekly | Alert 90/30 Tage vor Zertifikat-Ablauf |
| `hr-vacation-carry-easter.worker` | once-yearly (Jan) | Setzt `carry_deadline_date` = Ostermontag + 14 Tage |
| `hr-ferien-kuerzung.worker` | monthly | Berechnet Ferienkürzung bei > 2 Mt Absenz |
| `hr-zeg-half-year.worker` | 31.08. + 28.02. | ZEG-Berechnung · setzt `extra_zeg_h1/h2_days` |
| `hr-jubilaeum-alert.worker` | daily | Alert 30 Tage vor 5/10/15/20 J. Dienstjubiläum |
| `hr-konkurrenzverbot-clock.worker` | daily | Prüft Alumni-Clock · Trail bei Ablauf |
| `hr-provisionsvertrag-renewal.worker` | monthly (Okt/Nov) | Alert Renewal fällig für kommendes Jahr |
| `hr-warning-follow-up.worker` | daily | Alert Follow-up-Deadline fällig |
| `hr-offboarding-auto-archive.worker` | daily | Alumni-Auto-Archive bei letzter Arbeitstag |
| `hr-retention-expiry.worker` | weekly | Alert 30 Tage vor Dokument-Auto-Löschung |
| `hr-scheelen-certification-check.worker` | weekly | Alert wenn Scheelen-Zertifikat nach 6 Mt fehlt |
| `hr-disciplinary-offset-payroll.worker` | monthly (vor Lohnlauf) | Verrechnet bestätigte + MA-notified Disziplinar-Strafen |

### §6.2 Event-Trigger-Matrix

| Event | Trigger (UI-Action / Worker) | Subscribers |
|-------|------------------------------|-------------|
| `mitarbeiter_created` | §4.1 Save | Onboarding-Worker · Audit |
| `contract_signed` | Signatur-Webhook (alle 3) | Retention · HR-Notification · Scheelen-Certification-Check-Worker |
| `lifecycle_stage_changed` | Kanban-Drop + Drawer-Save | Audit · Offboarding-Worker (bei offboarding_*) |
| `probezeit_ending_soon` | Worker | Head · HR · Dashboard-Alert |
| `vacation_requested` | §4.3 Save | Vorgesetzter |
| `vacation_approved` | Approval-Click | MA · Outlook-Autoreply · Team-Kalender |
| `absence_started` | §4.4 Save + Saldo-Update | Team-Kalender |
| `certification_expiring` | Worker | MA · HR · Vorgesetzter |
| `onboarding_task_overdue` | Worker | Buddy · HR |
| `document_retention_expiring` | Worker | HR |
| `offboarding_started` | §4.14 Save | IT-Deprovisioning · Checkliste-Attach |
| `alumni_archived` | Worker bei Austrittsdatum | Retention-Cron |
| `warning_issued` | §4.11 Save | MA · Vorgesetzter |
| `warning_acknowledged` | MA-Confirm-Click | HR |
| `warning_follow_up_deadline` | Worker | HR |
| `termination_annulled` | §4.15 Save | HR · Payroll · Audit |
| `disciplinary_incident_reported` | §4.12 Tab 1 Save | HR · GL |
| `disciplinary_penalty_confirmed` | Status-Change | GL · Payroll-Worker (conditional) |
| `reglement_version_published` | Admin-Action | alle MA · Bulk-Signature-Request (wenn Flag) |
| `reglement_signed_by_ma` | §4.19 Save | HR-Audit |
| `provisionsvertrag_renewal_due` | Worker | HR · GL |
| `provisionsvertrag_signed` | Alle 3 Signaturen | Commission-Engine |
| `training_agreement_repayment_due` | Offboarding-Task | Payroll · Backoffice |
| `konkurrenzverbot_period_ended` | Worker | Audit |
| `homeoffice_request_submitted` | §4.5 Save | Vorgesetzter |
| `homeoffice_request_decision` | Approval-Click | MA |
| `academy_module_completed` | §3 Sektion 4 Save | Trainer · HR |
| `birthday_extra_day_eligible` | Worker | MA-Notification |
| `zeg_half_year_calculated` | Worker | MA · Backoffice |
| `role_transition_executed` | §4.2 Vertrag-Edit mit Rolle-Change | Commission-Engine (Grace-Period) |

---

## §7 Self-Service-UI

**Route:** `/hr/me` · `hr-mitarbeiter-self.html`-Mockup ausstehend.

### §7.1 Dashboard

Reduzierte Version von `/hr`:
- **Eigene Alerts:** Probezeit-Ende · Zertifikat-Expire · Jubiläum · Extra-Guthaben in Geburtstagswoche
- **Ferien-Saldo-Widget** mit allen 5 Extra-Kategorien
- **HO-Quota-Widget**
- **Aktive Absenzen** (inkl. bereits genehmigt, noch nicht bezogen)
- **Academy-Fortschritt** (eigene Module)
- **Eigene Dokumente** (download-fähig · mit `audit_hr_access`-Trail)
- **Anträge-Status** (Ferien · HO · Schulung · Weiterbildung)

### §7.2 Erlaubte Aktionen

- Ferienantrag (§4.3)
- Krankmeldung (§4.4)
- HO/Remote-Antrag (§4.5)
- Schulung anfordern (§4.6)
- Zertifikat erfassen (§4.7)
- Academy-Modul starten/abschliessen (Self-Assessment-Score)
- Notfallkontakte bearbeiten
- Adresse ändern
- Geburtstag-Sichtbarkeit-Toggle (Opt-in pro §11B-11)
- DSG-Auskunft-Export (Art. 25 DSG) · PDF aller eigenen Daten

### §7.3 Nicht erlaubt

- Andere MA-Daten sehen (nur Team-Kalender-Aggregat)
- Gehalt-Felder anderer MA
- Verwarnungen/Disziplinar erstellen (auch eigene nicht · Read-Only)
- Vertrags-Änderungen initiieren

---

## §8 Mobile-Support

Per Frontend-Freeze v1.11 §24b (Responsive-Policy): HR-Tool ist voll mobile-tauglich.

**Mobile-Anpassungen pro Drawer:**
- Full-Screen-Sheet statt 540/760 Drawer
- Tabs werden horizontal-scrollbar
- Signatur-Pad optimiert für Touch
- Saldo-Sidebars aufgeklappt, nicht side-by-side

**Mobile-Prio:**
- P0: Ferienantrag · Krankmeldung · HO-Antrag · Own-Profile-View
- P1: Zertifikat-Upload · Schulung-Anfrage · Dokument-Download
- P2: Full HR-Dashboard · Kanban (eingeschränkt · Desktop empfohlen)
- Desktop-Only: Verwarnung · Disziplinar · Provisionsvertrag-Renewal · Neuer-MA-Flow (CRUD-heavy)

---

## §9 RBAC-UI-Gates

| UI-Element | Sichtbar für | Editierbar für |
|-----------|--------------|----------------|
| `/hr` Dashboard (voll) | HR_Manager · Founder · Admin | — |
| `/hr` Team-View | Team_Lead | — |
| `/hr/me` | Employee_Self (eigene Daten) | Employee_Self (basic) |
| Side-Panel §3 Sektion 1-6 | HR_Manager · Founder · direkter Head (Team-Scope) · MA-Self (own) | HR_Manager · MA-Self (basic + Adresse + Notfallkontakte) |
| Side-Panel §3 Sektion 7 (Warnings + Disziplinar) | HR_Manager · Founder · direkter Head · MA-Self (nur own) | HR_Manager · Founder (issue) · MA (acknowledge) |
| Side-Panel §3 Sektion 8 (Provisionsvertrag) | HR_Manager · Founder · direkter Head · MA-Self (own) | HR + GL setzen · MA + Head + GL signieren |
| Sensible-Daten-Reveal | HR_Manager · Founder · Backoffice (Payroll) · MA-Self (own) | — |
| §4.1 Neuer MA | HR_Manager · Founder | |
| §4.11 Verwarnung ausstellen | HR_Manager · Founder · direkter Head | |
| §4.12 Disziplinar (gl_approved) | HR_Manager · Founder (Approve) | Founder only |
| §4.13 Provisionsvertrag-Renewal | HR_Manager · Founder setzen · Head + Founder signieren | |
| §4.14 Kündigung | HR_Manager · Founder · direkter Head | |
| §4.15 Annullierung | HR_Manager · Founder (nicht Head · governance) | |
| §4.16 Aufhebungsvereinbarung | HR_Manager · Founder | |
| Reglement-Publish (Admin) | Admin · HR_Manager | |

---

## §10 Related + Changelog

### Related

- `ARK_HR_TOOL_PLAN_v0_2.md` · `ARK_HR_TOOL_SCHEMA_v0_1.md` — Grundlage
- `ARK_DOK_GENERATOR_SCHEMA_v0_1.md` · `_INTERACTIONS_v0_1.md` — Bridge für Arbeitszeugnis (§4.17)
- `ARK_COMMISSION_ENGINE_SPEC_v0_1.md` — Bridge via `provisionsvertrag_signed`-Event
- `ARK_ZEITERFASSUNG_*_v0_1.md` — Schwester-Modul (Absenzen-Mirror)
- `wiki/concepts/interaction-patterns.md` — Global Patterns
- `wiki/meta/mockup-baseline.md` — HTML/CSS-Snippets

### Mockups (zu bauen)

- `mockups/ERP Tools/hr.html` (existiert · erweitern mit neuen Drawers)
- `mockups/ERP Tools/hr-list.html` (existiert)
- `mockups/ERP Tools/hr-mitarbeiter-self.html` (neu · Self-Service P0)
- `mockups/ERP Tools/hr-warnings-disciplinary.html` (neu)
- `mockups/ERP Tools/hr-provisionsvertrag-editor.html` (neu · Renewal-Flow)
- `mockups/ERP Tools/hr-academy-dashboard.html` (neu · Fortschritt-View)
- `mockups/ERP Tools/hr-absence-calendar.html` (neu · Quartal/Monat)
- `mockups/ERP Tools/hr-onboarding-editor.html` (neu · Template-Editor)
- `mockups/ERP Tools/hr-org-chart.html` (neu · Phase 3.6)
- `mockups/ERP Tools/hr-reports.html` (neu · Phase 3.6)

### Changelog v0.1 · 2026-04-19

**Initial Draft:**

- 10 Sections
- 19 Drawer-Definitionen (§4.1–§4.19)
- 4 Lifecycle-Saga-Flows (§5.1–§5.4 + §5.5 Annullierung)
- 13 Worker + 29 Event-Codes mit Subscriber-Matrix
- Self-Service-UI-Scope + RBAC-Gates
- Mobile-Support-Priorisierung

**Offene Punkte für v0.2:**

- UI-Wireframes als Screenshots einbinden (derzeit nur Text-Struktur)
- WebSocket-Channel-Definition für Real-Time-Updates (`hr:mitarbeiter:{id}`, `hr:dashboard:{tenant}`)
- Error-/Edge-Case-Spezifikation (z.B. doppelter HO-Antrag same day, Zeugnis-Upload bei fehlendem Dienstjahr)
- Accessibility-Audit (WCAG AA · Screen-Reader · Keyboard-Navigation)
- Performance-Targets (Dashboard-Load < 1s · Drawer-Open < 200ms)
- Detaillierte Validation-Rules pro Drawer (Zod/Yup-Schemas)
- Integration-Tests für Saga-Sequenzen
- Animations + Transitions-Spezifikation
