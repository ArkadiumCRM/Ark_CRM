# ARK CRM — Mandat-Detailmaske Interactions Spec v0.3

**Stand:** 14.04.2026
**Status:** Review ausstehend
**Kontext:** Definiert Verhalten, Interaktionslogik, CRUD-Flows und Speicher-Strategien für alle Tabs der Mandate-Detailseite (`/mandates/[id]`). Gleicher Methodik-Rahmen wie die Kandidaten- und Account-Interactions-Specs.
**Vorrang:** Stammdaten > dieses Dokument > Schema > Mockups
**Globale Patterns:** Es gelten alle 11 globalen Patterns aus TEIL 0 der Kandidaten-Interactions v1.2.

## Changelog v0.1 → v0.2 (13.04.2026)

| # | Änderung | Sektion |
|---|----------|---------|
| 1 | Kündigungs-Workflow (Exit Option) mit Fall A / Fall B Formeln | TEIL 9 (neu) + Status-Wechsel-Logik |
| 2 | Optionale Stages VI–X (Mehr Idents / Dossiers / Marketing / Assessment / Garantie) | TEIL 2b (neu) + Billing |
| 3 | Schutzfrist-Integration (fact_candidate_presentation → fact_protection_window) | TEIL 10 (neu) |
| 4 | Taskforce-Klarstellung (= umbenanntes RPO) | TEIL 0 |
| 5 | Assessment-Verknüpfung (Option IX + eigenständig) | TEIL 11 |
| 6 | Referral-Trigger (Kandidaten- und Kunden-Referral) | TEIL 11 |
| 7 | Header Quick-Action "Mandat kündigen" | TEIL 1 |
| 8 | Billing: Kündigungs-Rechnung als eigener Zeilen-Typ | TEIL 5 |
| 9 | Exklusivitätsfrist (3 Wochen ab Versand) als sichtbares Feld | TEIL 1 Snapshot-Bar |

## Changelog v0.2 → v0.3 (14.04.2026)

| # | Änderung | Sektion |
|---|----------|---------|
| 10 | Kündigungs-Flow vollständig ausgearbeitet (aus Audit-Gap B-1): Drawer-Pflichtfelder, Auto-Rechnungs-Generierung mit PDF-Template, atomare Transaktion | TEIL 9 (erweitert) |
| 11 | **Longlist-Locking** bei Kündigung: `is_longlist_locked` Feld, UI-Badge, keine neuen Stage-Wechsel, Durchcall-Queue leer | TEIL 3 + TEIL 9 |
| 12 | **Offene Prozesse schliessbar** trotz Lock: Status-Wechsel zu `Dropped`/`Cancelled` erlaubt, Bulk-Action "Alle offenen als Dropped markieren" | TEIL 4 + TEIL 9 |
| 13 | Kündigungs-Freigabe: **AM alleine** (kein Admin-Gate, Entscheidung #4) | TEIL 9 + RBAC |
| 14 | Claim-Billing-Kontext: Mandats-Stage-3 bei Target, Staffel-Basis bei Erfolgsbasis (Entscheidung #7) | TEIL 10 |
| 15 | Schutzfrist-Scope bei Kündigung: **nur konkret vorgestellte Kandidaten** (Entscheidung #14) | TEIL 10 |

---

## TEIL 0: STRUKTURELLE GRUNDENTSCHEIDUNGEN

### Tab-Struktur (aus Frontend Freeze + Entity-Definition)

| # | Tab | Inhalt |
|---|-----|--------|
| 1 | Übersicht | Typ, Status, Konditionen, KPIs, Garantie, Owner, Researcher, **Optionale Stages** |
| 2 | Longlist | Kanban (10 Spalten) oder Liste, Drag & Drop, Durchcall-Funktion |
| 3 | Prozesse | Alle Mandate-Prozesse, Interview-Termine |
| 4 | Billing | Zahlungstracking pro Mandatstyp **+ Kündigungs-/Options-Rechnungen** |
| 5 | History | History-Einträge der Longlist-Kandidaten |
| 6 | Dokumente | Reports, Mandatsofferte, Verträge, **Options-Aufträge**, **Kündigungs-Rechnungen** |

6 Tabs. Kein konditionaler Tab.

### Mandatstypen — Kontext für alle Tabs

| Typ | Wesen | Longlist | KPIs | Billing |
|-----|-------|---------|------|---------|
| **Target** | Exklusive Suche für 1 Position | Ja, vollwertig | Ident/Call/Shortlist | Pauschale ÷ 3 |
| **Taskforce** (ehemals RPO) | Team-/Standortaufbau, ≥3 Positionen | Ja, pro Position | Positionen besetzt/offen | Monatsfee + Success/Position |
| **Time** | Feste Rekrutierungskapazität in Slots | Nein (ARK liefert, Kunde führt Prozess) | Slots aktiv/pausiert | Wochenfee × Slots |

> **Taskforce = RPO** (Umbenennung 2026): "RPO" (Recruitment Process Outsourcing) wurde durch "Taskforce" ersetzt. Inhaltlich identisch. Alt-Mandate, die noch unter "RPO" abgeschlossen wurden, liegen unter `mandate_type = 'Taskforce'`.

### Einheitliche Regeln für alle Mandatstypen

- **Exit Option (80%-Regel)** bei Kündigung — siehe TEIL 9
- **Exklusivität** 3 Wochen ab Versand der Kandidaten-Vorstellung (aus Mandatsofferte Klausel I)
- **Schutzfrist** 12 Monate ab Vorstellungs-Ende (Auto-Extension auf 16 Monate bei Info-Verweigerung) — siehe TEIL 10
- **Optionale Stages VI–X** buchbar — siehe TEIL 2b

---

## TEIL 1: HEADER

### Stammdaten-Zeile
- Mandat-Name (gross)
- Typ-Badge: `🎯 Target` / `⚡ Taskforce` / `⏱ Time`
- Status-Dropdown (Entwurf / Aktiv / Abgeschlossen / Abgebrochen / Abgelehnt) — Confirm-Dialog bei Statuswechsel
- Account-Name (als Link → `/accounts/[id]`)
- Owner AM (Initialen + Name)
- Lead Researcher (Initialen + Name) — nur bei Target und Taskforce

### Snapshot-Bar (sticky, analog Account-Header)

| Slot | Target | Taskforce | Time |
|------|--------|-----------|------|
| 1 | 📊 Idents: 34/50 (Progress) | 📊 Positionen: 2/5 besetzt | 📊 Slots: 3/3 aktiv |
| 2 | 📞 Calls: 12/20 (Progress) | 💰 Monatsfee: CHF X | 💰 Wochenfee: CHF X/Slot |
| 3 | 📋 Shortlist: 2/3 CV Sent | 📋 Prozesse aktiv: 8 | 📋 Kandidaten geliefert: 12 |
| 4 | 💰 Pauschale: CHF X | ⏱ Laufzeit: Monat 3/12 | ⏱ Woche 8/unbefristet |
| 5 | ⏱ Time-to-fill: Woche 6/12-18 | 🏆 Placements: 1 | — |
| 6 | 🛡 Garantie: 3M (bis DD.MM.YY) | 🛡 Garantie: 3M | — |
| 7 | 🔐 Exklusivität: aktiv bis DD.MM.YY | 🔐 Exklusivität: aktiv | — |

**Exklusivitäts-Badge:**
- `🟢 Aktiv bis DD.MM.YY` wenn `exclusivity_end_date > now`
- `🟡 Ausgelaufen` wenn abgelaufen, aber Mandat noch aktiv
- Klick auf Badge → Popover mit Info zu Klausel I (3 Wochen Regel)

### Quick Actions
- **📞 Anrufen:** Öffnet Kontakt-Popover des verknüpften Accounts (Decision Makers oben)
- **✉ Email:** Analog Account
- **📄 Mandat-Report:** Quick-Generate → PDF-Report mit aktuellem Longlist-Stand, KPIs, Pipeline
- **🔔 Reminder:** Quick-Popover mit Mandat als Default-Verknüpfung
- **⚡ Option buchen:** Drawer für Optionale Stage VI–X (siehe TEIL 2b)
- **🛑 Mandat kündigen:** Nur bei Status `Aktiv` sichtbar — öffnet Kündigungs-Drawer (siehe TEIL 9)

### Breadcrumb
`Accounts > [Account-Name] > Mandate > [Mandat-Name]`
Klick auf Account → zurück zur Account-Detailseite Tab 7 (Mandate)

---

## TEIL 2: TAB 1 — ÜBERSICHT

### Sektionen-Struktur

| # | Sektion | Inhalt | Editierbar |
|---|---------|--------|------------|
| 1 | **Grunddaten** | mandate_name, mandate_type (read-only nach Erstellung), account (Link), job(s) (Links), kickoff_date, target_placement_date | Inline-Edit |
| 2 | **Team** | mandate_owner_id (AM), lead_researcher_id, weitere Researcher (Multi-Select) | Inline-Edit |
| 3 | **Konditionen** | Typ-spezifisch — siehe unten | Inline-Edit |
| 4 | **KPI-Targets & Fortschritt** | Typ-spezifisch — siehe unten | Targets: Inline-Edit. Actuals: Berechnet |
| 5 | **Shortlist & Extras** | Nur Target: Shortlist-Trigger, Zusatz-Idents, Zusatz-Dossiers | Inline-Edit |
| 6 | **Garantie** | garantiezeit_monate, Garantieleistung ("Ersatzbesetzung"), Garantie-Ablaufdatum (berechnet) | Inline-Edit |
| 6b | **Optionale Stages** | Liste der gebuchten Options VI–X mit Status | Siehe TEIL 2b |
| 7 | **Marktanalyse** | market_capacity, market_notes | Inline-Edit |
| 8 | **Notizen** | Freitext-Notizen zum Mandat | Inline-Edit |
| 9 | **Status & Abschluss** | final_outcome, terminated_by, terminated_reason, terminated_at, cancellation_note, closing_report_notes, is_guarantee_refund | Nur bei Abgeschlossen/Abgebrochen sichtbar |

### Konditionen-Sektion (Sektion 3) — typ-spezifisch

**Target:**
| Feld | Anzeige |
|------|---------|
| Pauschale (CHF) | Grosse Zahl |
| Zahlung 1 / 2 / 3 | Berechnet (Pauschale ÷ 3), jeweils mit Status-Badge (fällig / bezahlt / offen) |
| Zahlungsziel | X Tage |
| Spesen-Pauschale | CHF |
| Bemerkungen | Freitext |

**Taskforce:**
| Feld | Anzeige |
|------|---------|
| Monatsfee (CHF/Monat) | Grosse Zahl |
| Positionen-Tabelle | Inline-Tabelle: Position, Function, Success Fee, Status (offen/besetzt) |
| Zahlungsziel | X Tage |
| Spesen-Pauschale | CHF |
| Bemerkungen | Freitext |

**Time:**
| Feld | Anzeige |
|------|---------|
| Paket | Entry (2) / Medium (3) / Professional (4) |
| Preis/Slot/Woche | CHF (berechnet aus Paket) |
| Dauer (Wochen) | Zahl |
| Monatlicher Betrag | Berechnet (read-only) |
| Kündigungsfrist | "3 Wochen schriftlich" (read-only) |
| Zahlungsziel | X Tage |
| Bemerkungen | Freitext |

### KPI-Sektion (Sektion 4) — typ-spezifisch

**Target:**
- Ident Target vs. Actual — Progress-Bar mit Ampel (🟢≥80% / 🟡40-79% / 🔴<40%)
- Call Target vs. Actual — Progress-Bar mit Ampel
- Shortlist: X/Y CV Sent — Progress-Bar, bei Erreichen: Banner "2. Zahlung fällig"

**Taskforce:**
- Positionen besetzt / offen / geplant — gestapelter Balken
- Aktive Prozesse pro Position

**Time:**
- Slots aktiv / pausiert
- Kandidaten geliefert (Gesamt)
- Durchschnittliche Lieferzeit pro Slot

### Status-Wechsel-Logik

| Von | Nach | Trigger | Validierung |
|-----|------|---------|-------------|
| Entwurf | Aktiv | Dokument "Mandatsofferte unterschrieben" Upload | **Hard-Pflicht:** Ident Target, Call Target, Shortlist-Trigger (nur Target) |
| Entwurf | Abgelehnt | Manuell (AM) | Confirm-Dialog |
| Aktiv | Abgeschlossen | Manuell (AM) | Confirm-Dialog + final_outcome Pflicht |
| Aktiv | Abgebrochen | Button "🛑 Mandat kündigen" → Kündigungs-Drawer | Pflicht: terminated_by (arkadium/client), terminated_reason, terminated_note — siehe TEIL 9 |

---

## TEIL 2b: OPTIONALE STAGES (NEU v0.2)

### Kontext

Aus der Mandatsofferte (Klausel VI–X) sind fünf nachträglich buchbare Zusatzleistungen verfügbar:

| # | Option | Auswirkung |
|---|--------|-----------|
| VI | Mehr Idents | `target_idents` wird erhöht |
| VII | Mehr Dossiers | `target_dossiers` wird erhöht (ohne Ident-Erweiterung) |
| VIII | Marketing-Massnahmen | Premium-Publikationen (jobs.ch, alpha.ch, LinkedIn, Fachblog) |
| IX | Fundiertes Assessment | Kandidaten-Assessment via SCHEELEN® → erzeugt Assessment-Auftrag |
| X | Fakultative Garantiefrist | Verlängert `garantie_months` auf 4/5/6 |

**Preislogik:** Alle Optionen sind **case-by-case** (keine festen Preise, keine Formeln).

### Datenmodell

```
fact_mandate_option (
  id,
  mandate_id,
  option_type: 'VI_more_idents' | 'VII_more_dossiers' | 'VIII_marketing' | 'IX_assessment' | 'X_garantie_extension',
  price_chf,
  extension_value,       -- z.B. +10 Idents, +2 Monate Garantie, NULL bei Marketing/Assessment
  status: 'offered' | 'accepted' | 'in_progress' | 'delivered' | 'invoiced',
  ordered_at,
  signed_document_id,    -- FK zum Auftragserteilungs-PDF
  invoice_id,             -- FK zu fact_mandate_billing
  assessment_order_id    -- FK zu fact_assessment_order (nur Option IX)
)
```

### UI — Sektion 6b in Tab Übersicht

Leerzustand: *"Noch keine Optionalen Stages gebucht. [+ Option buchen]"*

Mit Einträgen: Tabelle
| Option | Beschreibung | Preis | Status | Auftrag | Rechnung |
|--------|-------------|-------|--------|---------|----------|
| VI Mehr Idents | +10 Idents | CHF 2'500 | ✅ Geliefert | 📄 Auftrag.pdf | 📄 RG-001 |
| IX Assessment | 1 Position | CHF 5'000 | ⏳ In progress | 📄 Auftrag.pdf | — |

### Option-Buchen-Flow (Header Quick-Action oder Tabellen-Button)

1. Drawer öffnet sich mit Option-Typ-Dropdown (VI–X)
2. Felder je Typ:
   - **VI/VII:** extension_value (Zahl), price_chf, Kommentar
   - **VIII:** Kanäle (Multi-Select Chips: jobs.ch, alpha.ch, Fachzeitungen, LinkedIn, Fachblog), price_chf, Kommentar
   - **IX:** Anzahl Assessments, Kandidat(en) auswählen (Multi-Select aus Longlist), price_chf, Kommentar — **erzeugt parallel Assessment-Auftrag** (siehe TEIL 11)
   - **X:** extension_value (Monate: +1/+2/+3), price_chf, Kommentar — **aktualisiert `garantie_months` auf Mandat**
3. "Auftrag generieren" → PDF aus `Vorlage_Auftragserteilung_Optionale_Stage.docx`
4. Kunde unterschreibt → Upload des signierten Dokuments → Status `accepted`
5. Rechnungszeile wird automatisch in Tab 4 Billing erstellt (siehe TEIL 5)

### Auto-Aktionen

- **Option VI** → `fact_mandate.target_idents += extension_value` + Longlist-Kanban-Progress-Bar aktualisiert sich
- **Option VII** → `fact_mandate.target_dossiers += extension_value`
- **Option IX** → Erzeugt `fact_assessment_order` mit `mandate_id` verknüpft, erscheint in Tab 6 Dokumente
- **Option X** → `fact_mandate.garantie_months += extension_value` (max 6), Snapshot-Bar Slot 6 aktualisiert sich

---

## TEIL 3: TAB 2 — LONGLIST

**Nur bei Target und Taskforce.** Bei Time: Tab zeigt "Time-Mandate haben keine Longlist. Kandidaten werden direkt an den Kunden übergeben." mit Link zum Prozesse-Tab.

### Longlist-Lock-Status (NEU v0.3)

`fact_mandate.is_longlist_locked` (Boolean) steuert Editierbarkeit:
- **`false` (Default):** Longlist voll editierbar (Drag & Drop, Durchcall, neue Kandidaten, Stage-Wechsel)
- **`true` (nach Kündigung):** Read-mostly-Modus
  - Sticky Banner oben: *"🔒 Longlist gesperrt — Mandat wurde am [date] gekündigt"*
  - Kein Drag & Drop (Stages bleiben wie sie waren)
  - Durchcall-Queue leer (Button disabled: "Keine Durchcall-Kandidaten — Mandat gekündigt")
  - "+ Kandidat hinzufügen" Button disabled
  - Bulk-Actions nur noch: **Export**, **NoGo markieren** (für Schutz-Zwecke)
  - Kanban-Cards: Hover-Actions entfallen
- **Unlock (Reaktivierung):** nur via Admin-Override (rare, mit Audit-Log)

### Ansicht
- **Kanban als Default** (umgekehrt zu Prozessen — hier ist Kanban der Hauptarbeitsort)
- Toggle auf Liste
- Keyboard-Shortcut: `K` = Kanban, `L` = Liste

### Kanban-Spalten (10)

| # | Spalte | Stage | Farbe | Schutzfrist-relevant? |
|---|--------|-------|-------|----------------------|
| 1 | Research | `research` | Grau | Nein |
| 2 | Nicht erreicht | `nicht_erreichbar` | Amber | Nein |
| 3 | NIC | `nicht_interessiert` | Rot (gedimmt) | Nein |
| 4 | CV Expected | `cv_expected` | Blau | Nein |
| 5 | CV IN | `cv_in` | Grün (locked 🔒) | **Ja** (erste Vorstellung beim Kunden möglich) |
| 6 | Briefing | `briefing` | Grün (locked 🔒) | **Ja** |
| 7 | GO mündlich | `go_muendlich` | Grün (locked 🔒) | **Ja** |
| 8 | GO schriftlich | `go_schriftlich` | Grün (locked 🔒) | **Ja** |
| 9 | Dropped | `dropped` | Rot | Nur wenn zuvor vorgestellt |
| 10 | Ghosted | `ghosted` | Grau (gedimmt) | Nur wenn zuvor vorgestellt |

**Locking:** Ab "CV IN" (Spalte 5) sind Stages gesperrt — Cards haben 🔒 Icon, kein D&D möglich. Nur Automationen können diese Stages ändern (CV-Upload → cv_in, Briefing-Save → briefing, etc.)

**Schutzfrist-Trigger:** Beim Eintritt in Stage 5+ UND wenn ein Vorstellungs-Event stattfindet (Dossier per Mail, mündliche Vorstellung im Call/Teams) → `fact_candidate_presentation` Eintrag wird geschrieben. Siehe TEIL 10.

### Kandidaten-Card (Kanban)

```
┌────────────────────────────┐
│ 📷 Foto  Max Muster         │
│ Bauingenieur · Implenia     │
│ 📞 Letzter Kontakt: 03.04. │
│ ⭐ Priority: Hoch           │
│ ✓ Validated                 │
│ 🛡 Schutz bis 12.04.2027   │  ← neu v0.2 bei Stage 5+
└────────────────────────────┘
```

- **Foto** (Thumbnail aus `dim_candidates_profile`)
- **Name** (Klick → `/candidates/[id]` in neuem Tab)
- **Aktuelle Funktion + Arbeitgeber** (aus Werdegang)
- **Letzter Kontakt** (Datum, aus History)
- **Priority** (Hoch/Normal/Niedrig — manuell setzbar, beeinflusst Durchcall-Reihenfolge)
- **Validated-Badge** (✓ wenn `is_validated = true`)
- **NoGo-Badge** (⛔ wenn `is_nogo = true`, Card rot umrandet)
- **Schutzfrist-Badge** (🛡 bis DD.MM.YYYY) — nur ab Stage 5+ sichtbar

### Drag & Drop
- Nur für **nicht-gelockte Stages** (Research → CV Expected)
- Drop auf gelockte Spalte → Fehlermeldung "Diese Stage wird automatisch gesetzt"
- Drop auf NIC/Dropped/Ghosted → Confirm-Dialog mit Grund-Pflichtfeld

### Durchcall-Funktion (KRITISCH für Researcher)

**Button "📞 Nächsten anrufen"** prominent oben rechts im Longlist-Tab.

Flow:
1. System wählt den nächsten Kandidaten: **höchste Priority** + Stage `research` oder `nicht_erreichbar` + `is_nogo = false` + kein Call in den letzten 24h
2. Kandidaten-Drawer öffnet sich mit:
   - Kandidaten-Summary (Name, Funktion, Arbeitgeber, Briefing-Kernpunkte falls vorhanden)
   - **Click-to-Call Button** (3CX)
   - Quick-Actions: "Erreicht" / "Nicht erreicht" / "NIC" / "Dropped" / "Nummer falsch"
3. Nach Call: RA klickt Status → Stage-Update → Drawer schliesst → nächster Kandidat automatisch (oder "Keine weiteren Kandidaten" wenn Queue leer)

**Queue-Anzeige:** "📞 12 Kandidaten in der Call-Queue" neben dem Button. Tooltip zeigt die nächsten 3 mit Name und Priority.

### Kandidat hinzufügen
- **"+ Kandidat hinzufügen"** Button → Command Palette / Suchfeld
- Suche nach Name, Email, Funktion
- Match → Kandidat wird als `research` Stage zur Longlist hinzugefügt
- Duplikatschutz: Kandidat der bereits in der Longlist ist → Warnung "Bereits in der Longlist (Stage: [X])"
- **Schutzfrist-Check:** Bei Hinzufügen prüfen, ob Kandidat bereits eine aktive Schutzfrist zum Account des aktuellen Mandats hat → Hinweisbanner "⚠ Kandidat steht unter Schutzfrist bei diesem Account (bis DD.MM.YYYY) — Honoraranspruch bereits gesichert" (nicht blockierend, nur Info)

### Bulk-Actions (Multi-Select mit Checkboxen)
- **Priority setzen** (Hoch/Normal/Niedrig)
- **Validate** (✓ markieren)
- **NoGo** (⛔ markieren + Grund)
- **Dropped** (mit Grund)
- **Export** (Excel/CSV für internen Gebrauch)

### Filter-Bar
- Stage (Multi-Select Chips)
- Priority (Hoch/Normal/Niedrig)
- Validated / Not Validated
- NoGo / Not NoGo
- Letzter Kontakt (> X Tage)
- **Schutzfrist aktiv** (neu v0.2)
- Freitext-Suche (Name, Funktion)

### Listenansicht (Alternative zu Kanban)

Spalten: Name, Funktion, Arbeitgeber, Stage, Priority, Letzter Kontakt, Validated, NoGo, Schutzfrist-Ende, Notizen (truncated), Aktionen

Sortierbar pro Spalte. Default: Priority desc, dann Name asc.

---

## TEIL 4: TAB 3 — PROZESSE

Alle Prozesse die zu diesem Mandat gehören (`fact_process_core.mandate_id = X`).

### Ansicht
- **Liste als Default**, Kanban als Toggle (analog Kandidat/Account)
- Kanban: 9 Spalten (Exposé → Platzierung)

### Spalten (Liste)

| Spalte | Inhalt |
|--------|--------|
| Kandidat | Name + Foto-Thumbnail |
| Job | Position-Titel (bei Taskforce: welche der Positionen) |
| Stage | Exposé → ... → Platzierung |
| Status | Open / On Hold / Rejected / Placed etc. |
| Nächstes Interview | Datum + Typ |
| CM | Candidate Manager (Initialen) |
| Erstellt am | Datum |
| Aktionen | Drawer / Vollansicht |

### Klick-Verhalten
- Klick → Drawer (540px) mit Stage-Pipeline, Interview, Honorar, letzte Aktivität
- "Vollansicht öffnen →" → `/processes/[id]`

### Erstellen
- **Kein manuelles Erstellen** — Prozesse entstehen aus dem Jobbasket

### Filter
- Stage-Chips
- Status (Aktiv / Placed / Abgelehnt / Alle)

### Placement-Trigger (Event-relevant)

Wird ein Prozess auf Stage "Platzierung" gesetzt:
1. Schlusszahlung (Stage 3 Target) oder Success Fee (Taskforce) wird fällig → Billing-Update
2. Schutzfrist-Fenster wird **aufgehoben** (oder auf 12 Monate Garantie gesetzt) für diesen Kandidaten bei diesem Account
3. Referral-Check: Falls Kandidat referred wurde → `fact_referral.payout_due_at = placement_date + probezeit_ende`
4. Garantie-Timer startet: `garantie_start_date = placement_date`

---

## TEIL 5: TAB 4 — BILLING

Zahlungstracking basierend auf `fact_mandate_billing`.

### Billing-Zeilen-Typen (erweitert v0.2)

| Typ | Wann | Template |
|-----|------|----------|
| `stage_1` / `stage_2` / `stage_3` | Target: bei Trigger | `Vorlage_Rechnung Mandat X. Teilzahlung.docx` |
| `monthly_fee` | Taskforce: jeder Monat | Analog Taskforce-Rechnung |
| `success_fee` | Taskforce: pro Placement | Analog |
| `weekly_slot_fee` | Time: monatlich aggregiert | Time-Rechnung |
| `option` | Bei Optionaler Stage gebucht | `Vorlage_Rechnung_Mandat_Optionale Stage.docx` |
| `termination` | Bei Mandats-Kündigung | `Vorlage_Rechnung_Kündigung Mandat.docx` — siehe TEIL 9 |
| `refund` | Garantie-Rückvergütung (Best Effort) | `Vorlage_Rechnung Rückerstattung.docx` — nur wenn erfolgsbasis |

### Layout — typ-spezifisch

**Target:**
| # | Zahlung | Betrag | Trigger | Status | Rechnung |
|---|---------|--------|---------|--------|----------|
| 1 | Vertragsabschluss | CHF X | Mandatsofferte unterschrieben | ✅ Bezahlt / ⏳ Offen / 🔴 Überfällig | Nr. / Datum |
| 2 | Shortlist | CHF X | Shortlist-Trigger (X CVs) | Status | Nr. / Datum |
| 3 | Placement | CHF X | Kandidat platziert | Status | Nr. / Datum |

Plus separate Sektionen:
- **Optionale Stages** (wenn vorhanden) — Zeile pro Option VI–X
- **Kündigungs-Rechnung** (nur bei Status Abgebrochen)

Summen-Zeile unten: Total / Bezahlt / Offen.

**Taskforce:**
- **Monatsfee-Sektion:** Tabelle mit einer Zeile pro Monat (Monat, Betrag, Status, Rechnung)
- **Success-Fee-Sektion:** Tabelle mit einer Zeile pro Position (Position, Betrag, Status Placement, Rechnung)
- **Optionale Stages + Kündigung** analog Target
- Summen pro Sektion + Gesamtsumme

**Time:**
- Tabelle mit einer Zeile pro Abrechnungsmonat
- Spalten: Monat, Slots, Preis/Slot/Woche, Wochen im Monat, Betrag, Status, Rechnung
- Summen-Zeile

### Zahlungs-Status
- **Offen** (⏳ amber) — Rechnung noch nicht erstellt oder nicht bezahlt
- **Rechnungsstellung** (📄 blau) — Rechnung erstellt, noch nicht bezahlt
- **Bezahlt** (✅ grün) — Bezahlt
- **Überfällig** (🔴 rot) — Zahlungsziel überschritten

### Rechnungs-Erstellung
- Klick "Rechnung erstellen" pro Zeile → Drawer mit:
  - Rechnungsnummer (auto-generiert oder manuell)
  - Rechnungsdatum (Default: heute)
  - Fälligkeitsdatum (Default: heute + Zahlungsziel aus Konditionen)
  - PDF-Upload (optionale Kopie der externen Rechnung)
- Speichern → Status wechselt auf "Rechnungsstellung"
- "Als bezahlt markieren" → Status wechselt auf "Bezahlt" + paid_date

### Auto-Trigger

**Target:**
- Mandatsofferte hochgeladen → Zeile 1 (Vertragsabschluss) wird automatisch als "fällig" markiert
- Shortlist-Trigger erreicht → Zeile 2 wird "fällig" + AM-Notification
- Placement → Zeile 3 wird "fällig" + AM-Notification

**Optionale Stages:**
- Option gebucht (Status `accepted`) → Rechnungszeile automatisch erstellt

**Kündigung:**
- Status `Aktiv → Abgebrochen` → Kündigungs-Rechnung wird automatisch berechnet und als "fällig" markiert (siehe TEIL 9)

---

## TEIL 6: TAB 5 — HISTORY

History-Einträge aller Kandidaten in der Longlist dieses Mandats. Scope: `WHERE mandate_id = X` über die fact_mandate_research-Verknüpfung.

### Was ist identisch zu Kandidat/Account History
- Drawer mit ActivityType, Notiz, Verknüpfung
- 3CX-Integration, Email-Integration
- Transkript + AI-Summary
- Klassifizierung (confirmed / ai_suggested / pending / manual)

### Was ist anders (Mandat-Perspektive)

| Aspekt | Unterschied |
|--------|------------|
| **Scope** | Alle History-Einträge aller Longlist-Kandidaten für dieses Mandat |
| **Spalte "Kandidat"** | Wer wurde kontaktiert (Name + Foto) |
| **Filter** | Nach Kandidat, ActivityType, Stage, Zeitraum |
| **Gruppierung** | Optional nach Kandidat gruppierbar (alle Calls zu einem Kandidaten zusammen) |
| **KPI-Banner oben** | "Calls diese Woche: 8/20 Target" — Live-Fortschritt für Researcher |

### Call-Statistik (prominent oben)
- Calls heute / diese Woche / dieser Monat
- vs. Call Target (aus Mandat-KPIs)
- Erreicht vs. Nicht erreicht Ratio

### Vorstellungs-Events (schutzfrist-relevant, neu v0.2)

Spezieller ActivityType-Filter: **"Vorstellungen"** (`candidate_presented_email`, `candidate_presented_verbal`) — zeigt alle Präsentations-Events mit Schutzfrist-Folge. Klick auf Event → Navigation zu Schutzfrist-Fenster im Account-Detail (Tab "Schutzfristen").

---

## TEIL 7: TAB 6 — DOKUMENTE

### Dokumenttypen (Mandat-spezifisch, erweitert v0.2)
- Mandatsofferte unterschrieben (Trigger → Aktivierung)
- Mandat-Report (auto-generiert)
- Vertrag / Rahmenvertrag
- Briefing-Unterlage (Kundenseitig)
- **Auftragserteilung Optionale Stage** (VI–X — pro Option ein Dokument)
- **Kündigungs-Rechnung** (bei Abbruch)
- **Rückerstattungs-Gutschrift** (bei Garantie-Fall mit Best Effort)
- **Assessment-Dokumente** (bei Option IX — verlinkt zur Assessment-Detailseite)
- Sonstiges

### Mandat-Report Generator
- **"Report generieren"** Button → PDF mit:
  - Mandat-Zusammenfassung (Typ, Status, KPIs)
  - Longlist-Status (Kandidaten pro Stage)
  - Call-Statistik
  - Pipeline-Fortschritt (Prozesse pro Stage)
  - Timeline (Kickoff bis heute)
  - **Optionale Stages (neu v0.2)** — welche gebucht, Status
  - **Schutzfrist-Übersicht (neu v0.2)** — welche Kandidaten in Schutzfrist, bis wann
- Jeder generierte Report wird automatisch als Dokument gespeichert
- **Versionierung:** Jeder neue Report = neues Dokument, vorherige bleiben erhalten

### Upload & Trigger
- Upload "Mandatsofferte unterschrieben" → Trigger Mandats-Aktivierung (analog Account Tab 10)
- Upload "Auftragserteilung Optionale Stage" → setzt zugehörige Option auf Status `accepted`
- Bei Upload: Mandat-Verknüpfung automatisch gesetzt (wir sind ja bereits im Mandat)

### Rest
- Analog Kandidat/Account: Drag & Drop, Preview, Download, Versionierung

---

## TEIL 8: PHASE 1.5 / PHASE 2 VORMERKLISTE

| Feature | Phase | Beschreibung |
|---------|-------|-------------|
| KPI-Schwellwerte konfigurierbar | 1.5 | Ampel-Schwellwerte via `dim_automation_settings` statt hardcoded |
| Kanban-Ansicht Prozesse | 2 | Visuelle Pipeline für Tab 3, read-only (kein D&D) |
| Longlist-Export als PDF | 1.5 | Formatierter Export für Kundenpräsentation |
| Taskforce-Dashboard | 2 | Cross-Position-Übersicht mit Teamrad-Integration |
| Time Slot-Tausch | 1.5 | Drag & Drop zum Tauschen von Positionen zwischen Slots |
| Billing-Integration Buchhaltung | 2 | Export / API zu Buchhaltungssystem (Abacus, Bexio) |
| Automatische Rechnungserstellung | 2 | PDF-Generierung mit ARK CI |
| Exklusivitätsbruch-Detection | 2 | Scraper-basiert: wenn Stelle bei Konkurrenz-Plattform erscheint |

---

## TEIL 8b: MANDATS-VERLÄNGERUNG (NEU 14.04.2026)

Aktive Mandate können typ-spezifisch verlängert / erweitert werden, ohne als neues Mandat angelegt zu werden:

| Typ | Aktion | Auswirkung |
|-----|--------|-----------|
| **Time** | **+ Wochen verlängern** | Dauer (Wochen) im Konditionen-Block erhöhen → Wochen-Abrechnung läuft weiter, Endrechnung verschiebt sich |
| **Time** | **+ Slot hinzufügen** | Slots-Anzahl erhöhen → ab folgendem Monat höhere Wochenfee |
| **Taskforce** | **+ Position hinzufügen** | Sub-Tabelle "Positionen" um Eintrag erweitern (Titel, Function, Success Fee). Erzeugt neuen Job. Monatsfee bleibt unverändert |
| **Target** | (keine Erweiterung) | Target = 1 Position fix. Bei Bedarf einer 2. Position → neues Mandat |

**UI:** Im Mandat-Drawer (Tab Übersicht) Sektion "Mandats-Optionen" mit typ-spezifischen Buttons (nur die zum aktuellen Typ passenden sind aktiviert).

**Audit:** Jede Verlängerung erzeugt einen Eintrag in `fact_mandate_extensions` (mandate_id, change_type, old_value, new_value, extended_at, extended_by). Sichtbar in Mandats-History.

---

## TEIL 9: KÜNDIGUNG & EXIT OPTION (NEU v0.2)

Regelt den Wechsel `Aktiv → Abgebrochen` mit vollständigem Billing- und Dokumenten-Workflow.

### Zwei Fälle

| Fall | Wer kündigt | Typischer Grund |
|------|------------|----------------|
| **Fall A** | Arkadium | Markt gibt keine Kandidaten her, Search-Strategie erschöpft (selten, bisher nie eingetreten — Stand 2026-04) |
| **Fall B** | Auftraggeber | Anderweitige Besetzung, Direkteinstellung, Projekt-Storno |

### Kündigungs-Drawer (Header Quick-Action "🛑 Mandat kündigen")

Drawer öffnet sich mit Pflichtfeldern:

1. **`terminated_by`** (Radio): `arkadium` / `client`
2. **`terminated_reason`** (Dropdown, abhängig von terminated_by):
   - Arkadium: `no_candidates_available` / `scope_exhausted` / `mutual_agreement` / `other`
   - Client: `hired_elsewhere` / `direct_hire_from_longlist` / `project_cancelled` / `budget_freeze` / `restructuring` / `mutual_agreement` / `other`
3. **`terminated_note`** (Textarea, Pflicht) — freie Begründung
4. **`terminated_at`** (Date) — Default: heute
5. **Kündigungs-Rechnung Preview** (read-only, live berechnet):
   - Formel je Fall (siehe unten)
   - Aufgelistete Stages mit Status
   - Netto-Betrag + MwSt + Gesamt

### Berechnungs-Formel

**Fall A (Arkadium kündigt):**
```
Payout_Total_netto = Gesamtmandatssumme × 0.80
Rechnungsbetrag_netto = Payout_Total_netto − Σ(bereits bezahlte Stages)
```

**Fall B (Auftraggeber kündigt):**
```
Payout_Total_netto = max(Σ(Stages bis inkl. laufender), Gesamtmandatssumme × 0.80)
Rechnungsbetrag_netto = Payout_Total_netto − Σ(bereits bezahlte Stages)
```

**Erklärung Fall B:**
- Die laufende Stage wird fällig
- Mindestens aber 80% der Gesamtmandatssumme (Floor)
- Bei Kündigung in Stage 3: Σ(Stages) = 100% > 80% → Stage 3 regulär
- Bei Kündigung in Stage 1/2: Σ(Stages) < 80% → 80%-Floor greift

### Datenmodell-Updates (v0.3 erweitert)

```sql
fact_mandate:
  + terminated_by: ENUM('arkadium','client') nullable
  + terminated_reason: VARCHAR nullable
  + terminated_at: DATE nullable
  + terminated_note: TEXT nullable
  + termination_invoice_id: FK fact_mandate_billing nullable
  + exclusivity_end_date: DATE nullable
  + is_longlist_locked: BOOLEAN DEFAULT FALSE   -- NEU v0.3

fact_mandate_billing:
  + billing_type ENUM erweitert: 'termination' | 'option' | 'refund'
```

### Atomare Transaktion bei Kündigungs-Bestätigung — Saga TX3 (v0.3)

Entspricht Backend v2.5 § TX3. 6 Steps, alle atomar; bei Fehler Rollback + `mandate_termination_failed`-Event.

### Pre-Validierung (vor TX3)

| # | Check | Fehler-Code |
|---|-------|-------------|
| V1 | `mandate.status = 'Aktiv'` | `invalid_status` |
| V2 | Caller-Rolle = AM (Owner) — **kein Admin-Gate** (Entscheidung #4) | `unauthorized` |
| V3 | `terminated_by` ∈ {arkadium, client} | `invalid_terminated_by` |
| V4 | `terminated_reason` non-null (aus `dim_cancellation_reasons`) | `missing_reason` |
| V5 | `terminated_note` length ≥ 10 | `note_too_short` |
| V6 | Keine laufende Placement-Saga auf Prozessen dieses Mandats | `placement_in_progress` |

### Schutzfrist-Scope-Qualification (Step 5 pre-compute)

Bestimmt pro vorgestelltem Kandidat, ob Scope `account` oder `group`:

```
FOR EACH presentation IN fact_candidate_presentation WHERE mandat_id = :mid:
  IF mandate.account.group_id IS NOT NULL
     AND EXISTS mandate_link zu weiteren Accounts derselben group
     (fact_mandate_accounts.group_id = account.group_id)
  THEN scope := 'group'
  ELSE scope := 'account'
  END
```

Nur **konkret vorgestellte** Kandidaten bekommen ein Schutzfrist-Fenster (Entscheidung #14) — keine Longlist-Idents.

### TX3 — 6-Step Saga

```sql
BEGIN TRANSACTION

  -- 1. Mandat-Status setzen
  UPDATE fact_mandate
    SET status = 'Abgebrochen',
        terminated_by, terminated_reason, terminated_at, terminated_note,
        is_longlist_locked = TRUE,
        exclusivity_end_date = terminated_at   -- Exklusivität endet sofort
    WHERE id = mandate_id;

  -- 2. Rechnungsbetrag berechnen (je nach Fall A oder B)
  payout_total := CASE
    WHEN terminated_by = 'arkadium' THEN gesamtmandatssumme * 0.80
    WHEN terminated_by = 'client'   THEN GREATEST(sum_stages_bis_laufende, gesamtmandatssumme * 0.80)
  END;
  rechnung_netto := payout_total - sum_bereits_bezahlt;

  -- 3. Billing-Zeile erstellen
  INSERT INTO fact_mandate_billing (
    mandate_id, billing_type='termination',
    amount_chf = rechnung_netto,
    due_date = terminated_at + payment_terms_days,
    status = 'pending',
    created_at = now
  ) RETURNING id AS new_invoice_id;

  UPDATE fact_mandate SET termination_invoice_id = new_invoice_id WHERE id = mandate_id;

  -- 4. PDF-Rendering aus Template (async Job, nicht in TX)
  ENQUEUE generate_termination_invoice_pdf(mandate_id, new_invoice_id);

  -- 5. Schutzfrist-Fenster — Scope-qualifiziert je Kandidat (siehe Pre-compute oben)
  INSERT INTO fact_protection_window (
    presentation_id, candidate_id, scope,
    account_id,   -- NULL bei scope='group' (CHECK constraint)
    group_id,     -- NULL bei scope='account'
    starts_at = terminated_at,
    base_duration_months = 12,
    expires_at = terminated_at + INTERVAL '12 months',
    status = 'active'
  )
  SELECT p.id, p.candidate_id,
         qualify_scope(p.candidate_id, m.account_id) AS scope,
         CASE WHEN scope='account' THEN m.account_id END,
         CASE WHEN scope='group'   THEN m.account.group_id END,
         ...
  FROM fact_candidate_presentation p
  JOIN fact_mandate m ON p.mandat_id=m.id
  WHERE p.mandat_id = :mandate_id;
  -- Nur konkret vorgestellte (Entscheidung #14), KEINE Longlist-Idents.
  -- Scope per TX-Start Pre-compute bestimmt.

  -- 6. Events
  INSERT fact_history → 'mandate_terminated' (scope: Mandat + Account + Kandidaten-Liste)
  INSERT fact_history → 'termination_invoice_generated' (scope: Mandat + Account)
  INSERT fact_history → 'protection_window_opened' (pro Kandidat)

COMMIT
```

### Folge-UI-Änderungen (sofort nach Kündigung)

1. **Status-Badge:** rot `🛑 Abgebrochen`
2. **Full-Width-Banner unterhalb Header:**
   ```
   🛑 Mandat gekündigt am DD.MM.YYYY durch [Arkadium/Kunde]
   Grund: [reason]
   Kündigungs-Rechnung: CHF X (Status: [status]) → Tab Billing
   ```
3. **Tab 2 Longlist:** `is_longlist_locked = true` aktiviert — siehe TEIL 3 Longlist-Lock-Status
4. **Tab 3 Prozesse:** Banner oben *"Mandat gekündigt — bitte offene Prozesse abschliessen"*
   - Neue Bulk-Action: **"Alle offenen Prozesse als Rejected markieren"** (Confirm + Pflicht-Begründung)
   - Status-Dropdown für einzelne Prozesse weiterhin aktiv: `Rejected` (Standardweg bei Mandat-Ende) oder `Cancelled` (Rückzieher nach Zusage)
   - Prozesse bleiben technisch bestehen (kein Auto-Delete) — nur Status-Wechsel empfohlen
5. **Tab 4 Billing:** Kündigungs-Rechnungs-Zeile prominent oben
6. **Tab 6 Dokumente:** PDF der Kündigungs-Rechnung erscheint nach PDF-Worker-Completion
7. **Notification** an AM + Account-AM (falls anders)
8. **Audit-Log:** vollständiger Eintrag in `fact_audit_log`

### Offene Prozesse nach Kündigung (NEU v0.3)

**Problem:** Laufende Prozesse (CV Sent → Interview → Angebot) sind vor Placement-Stufe. Was passiert mit ihnen nach Mandat-Kündigung?

**Lösung (Peter-Entscheidung):**
- Prozesse **bleiben bestehen** (Audit-Trail, Interview-Historie erhalten)
- Aber: AM muss sie aktiv schliessen — via Status-Wechsel zu `Rejected` (Prozess beendet durch Mandats-Kündigung, Standard-Fall) oder `Cancelled` (nur bei Rückzieher nach Zusage)
- **Unterschied zu `Dropped`:** Dropped ist nur für Prozesse die **nie gestartet** sind (= nie einen CV-Versand hatten). Ein laufender Prozess kann nicht mehr Dropped werden.
- Bulk-Action im Prozess-Tab erleichtert: "Alle offenen als Rejected markieren" — Modal mit Begründungsfeld
- **Sonderfall Stage = Angebot/Platzierung:** Prozess kann normal zu Ende geführt werden (Placement möglich trotz Kündigung — dann wird Fall B aktiviert mit entsprechender Billing-Korrektur)

**UI-Flow Bulk-Close:**
1. Button "Alle offenen Prozesse als Rejected markieren" nur sichtbar wenn Mandat-Status = Abgebrochen UND es offene Prozesse gibt
2. Modal zeigt Liste aller Prozesse mit Status ∈ {Open, On Hold, Stale}
3. Pflicht-Felder im Modal:
   - `rejected_by` = `internal` (fest)
   - `rejection_reason_id` (Dropdown aus `dim_rejection_reasons_internal`, Default-Option: "Mandat gekündigt")
   - `rejection_note` (Textarea, optional)
4. Confirm → Alle Prozesse Status = `Rejected`, Felder gesetzt, Event `process_rejected_due_to_mandate_termination` pro Prozess

### Berechtigungen (v0.3, Entscheidung #4)

- **Mandat-Kündigung: AM alleine** (kein Admin-Gate)
- AM (Owner Account) + Admin/Admin = ✅ Mandat kündigen
- Andere AMs = ❌ (außer als Vertretung im AM-Pool)
- Audit-Log obligatorisch für Nachvollziehbarkeit

### UI im Status "Abgebrochen"

- Status-Badge rot: `🛑 Abgebrochen`
- Header zeigt Banner: *"Mandat gekündigt am DD.MM.YYYY durch [Arkadium/Kunde] — Grund: [reason]"*
- Sektion 9 (Status & Abschluss) voll sichtbar mit allen terminated-Feldern
- Kündigungs-Rechnung in Tab 4 prominent oben
- Tab 2 Longlist zeigt "Mandat gekündigt" Overlay mit nur-Lese-Zugriff
- Tab 3 Prozesse: offene Prozesse weiter sichtbar (aber mit Warnbanner)

### Entkündigung / Reaktivierung

Nicht vorgesehen in Phase 1. Falls gewünscht: neues Mandat erstellen mit Referenz zum gekündigten.

---

## TEIL 10: SCHUTZFRIST-INTEGRATION (NEU v0.2)

### Scope (aus [[direkteinstellung-schutzfrist]])

Nur **konkret vorgestellte Kandidaten** erzeugen Schutzfrist-Einträge. Vorstellung = Dossier per Email ODER mündliche Vorstellung (Telefon/Teams).

### Datenmodell

```sql
fact_candidate_presentation (
  id,
  candidate_id,           -- Standardisiert auf English (Entscheidung 2026-04-14 DB-W8)
  account_id,             -- immer gesetzt (Account des Mandats)
  mandate_id,             -- FK zum Mandat
  process_id,             -- optional: falls Prozess existiert
  presentation_type: 'email_dossier' | 'verbal_meeting' | 'upload_portal',  -- dim_presentation_types §10c
  presented_at TIMESTAMP,
  presented_by FK         -- user_id
)

fact_protection_window (
  id,
  presentation_id FK,     -- FK zu fact_candidate_presentation
  candidate_id FK,
  scope ENUM('account','group') DEFAULT 'account',   -- NEU v0.3 (aus Firmengruppen-Entscheidung)
  account_id FK NULL,     -- gesetzt wenn scope='account'
  group_id FK NULL,       -- gesetzt wenn scope='group'
  starts_at TIMESTAMP,    -- Default: presentation_at oder mandat_end_date
  base_duration_months INT DEFAULT 12,
  extended BOOLEAN DEFAULT FALSE,    -- Auto-Extension auf 16 Monate
  expires_at TIMESTAMP,
  info_requested_at TIMESTAMP NULL,
  info_received_at TIMESTAMP NULL,
  status ENUM('active','expired','honored','claim_pending','paid'),
  CHECK ((scope='account' AND account_id IS NOT NULL AND group_id IS NULL)
      OR (scope='group'   AND group_id   IS NOT NULL AND account_id IS NULL))
)
```

### Wann werden Einträge erzeugt?

**`fact_candidate_presentation`:**
- Manueller Button im Longlist-Tab bei Kandidat (Stage 5+): "📋 Als vorgestellt markieren" → Dropdown presentation_type + Timestamp
- Auto-Trigger: Email an Kunde versendet mit Dossier-Anhang (Email-Klassifizierung → `candidate_presented_email`)
- Auto-Trigger: Call-Transkript mit Kandidaten-Namensnennung durch AM → AI-Klassifizierung `candidate_presented_verbal` (AI-suggested, AM bestätigt)
- Auto-Trigger: CV-Versand-Gate-2 in Jobbasket → automatisch `presentation_type='email_dossier'`

**`fact_protection_window`** (NUR für konkret vorgestellte Kandidaten, Entscheidung 2026-04-14 #14):
- Bei Mandat-Abschluss (`Abgeschlossen` oder `Abgebrochen`): für jeden Eintrag in `fact_candidate_presentation` dieses Mandats wird ein Fenster mit `starts_at = terminated_at/closed_at` erstellt
- Bei Kandidaten-Absage im Prozess (Stage `Rejected`): Fenster mit `starts_at = rejection_date`
- **Longlist-Idents ohne `fact_candidate_presentation` Eintrag → KEIN Schutzfrist-Fenster** (auch nach Mandats-Kündigung)

**Gruppen-Scope (bei Account in Firmengruppe):**
Wenn `dim_accounts.group_id IS NOT NULL` → zwei Einträge werden erstellt:
- `scope='account'` mit account_id
- `scope='group'` mit group_id
Beide Einträge haben identisches `expires_at`. Scraper-Match prüft beide Scopes.

### UI im Mandat

**Tab 2 Longlist:**
- Nur Kandidaten mit **bestehendem** `fact_candidate_presentation`-Eintrag bekommen Badge 🛡 mit Hover-Tooltip "Schutzfrist aktiv bis DD.MM.YYYY"
- Bei Kündigung: **keine Auto-Erstellung** für Stage-5+-Kandidaten ohne explizite Vorstellung (Entscheidung 2026-04-14 #14)
- Manuelle Vorstellungs-Markierung bleibt via "📋 Als vorgestellt markieren" im Card-Menu (zur Korrektur)

**Tab 5 History:**
- Filter "Vorstellungs-Events" zeigt alle `candidate_presented_*`

### UI im Account (Referenz, Detail in Account-Spec)

- Tab "Schutzfrist-Matrix" — alle aktiven Schutzfristen aus allen Mandaten diesen Accounts
- Klick auf Eintrag → Mandats-Detailseite

### Auto-Extension auf 16 Monate

- Event: Kandidat wechselt Job (via [[scraper]] oder manueller Eintrag)
- Check: gibt es aktives `fact_protection_window` zu `candidate_id + new_account_id` (account-scope ODER group-scope via `group_id`)?
- Wenn ja: System sendet Info-Request an Kunde via Email-Template
- Nach 10 Tagen ohne Antwort: `extended = true`, `expires_at += 4 months`

### Claim-Billing-Logik (v0.3, präzisiert Entscheidung #7 + Peter-Klarstellung 14.04.)

**Kern-Prinzip:** Ein Mandat gilt immer **nur für die definierte Position**. Die Claim-Logik richtet sich danach, ob der Kandidat für genau diese Position eingestellt wurde oder für eine andere.

**Drei Fälle zu unterscheiden:**

#### Fall X — Mandats-Position identisch (= "Mandats-Claim")
Wenn der Kandidat bei der ursprünglich im Mandat definierten Position eingestellt wird (gleiche Firma, gleicher Job wie im Mandat spezifiziert):
- **Honorar-Basis:** **Restliche Summe des Mandats** fällig (Gesamtmandatssumme − bereits bezahlte Stages)
- Rationale: Das Mandat wird als "komplett gedeckt / abgeschlossen" behandelt — der Kunde hätte diesen Kandidaten sowieso über die letzte Stage platziert
- **Keine Staffel-Berechnung** notwendig
- Rechnung via Template `Vorlage_Rechnung_Mandat_Direkteinstellung-Claim.docx`

#### Fall Y — Andere Position bei gleicher Firma ODER in der Gruppe
Wenn der Kandidat für eine **andere Position** eingestellt wird (auch wenn gleiche Firma oder eine Schwestergesellschaft in der gleichen Firmengruppe — Gruppen-Scope-Schutz greift):
- **Honorar-Basis:** **Erfolgsbasis-Staffel** (21/23/25/27%) auf den **neuen tatsächlichen Jahreslohn** des Kandidaten in der neuen Position
- Rationale: Das ursprüngliche Mandat hat die definierte Position nicht vermittelt — der Kunde hätte ohne Arkadium-Vorstellung den Kandidaten nicht gefunden, aber für eine andere Rolle
- **Unabhängig davon, ob der Ursprungs-Prozess über Mandat oder Erfolgsbasis lief**
- Rechnung via Template `Vorlage_Rechnung_Erfolgsbasis-Direkteinstellung-Claim.docx`

#### Fall Z — Erfolgsbasis-Ursprung (kein Mandat), beliebige Position
Wenn der Ursprungs-Prozess ein Erfolgsbasis-Prozess war (kein Mandat) und der Kandidat später direkt eingestellt wird:
- **Honorar-Basis:** Erfolgsbasis-Staffel auf den neuen tatsächlichen Jahreslohn
- Gleich wie Fall Y nur ohne Mandats-Kontext-Hintergrund
- Gleiches Template wie Fall Y

### Kontext-Detection (automatisch)

Bei Claim-Anstoss prüft das System:
1. Existiert `fact_candidate_presentation.mandate_id IS NOT NULL` für diesen Kandidaten+Account?
2. Falls ja: Gleicht die neue Position (Job-Title aus Scraper-Fund) der ursprünglich im Mandat definierten Position?
   - **Job-Match-Check:** AI-basiert (Fuzzy-Match auf Job-Title + Function + ggf. BKP-Gewerk) — AM bestätigt im Drawer
   - Match → Fall X
   - Kein Match → Fall Y (trotz Mandats-Ursprung)
3. Falls `mandate_id IS NULL` → Fall Z

### Claim-Empfänger (immer die einstellende Firma)

**Wichtig (Peter-Klarstellung 14.04.):** Rechnungs-Empfänger ist **immer die Firma, die den Kandidaten tatsächlich eingestellt hat**, nicht die Holding bei Gruppen-Schutzfrist. Auch wenn der Schutzfrist-Eintrag auf Gruppen-Ebene (`scope='group'`) matched, geht die Rechnung an die konkrete Gesellschaft der Gruppe.

### Praxis-Flow

1. Scraper detektiert Job-Wechsel + Schutzfrist-Match → Critical Alert
2. AM öffnet Claim-Workflow (Account Tab 9 Schutzfristen)
3. **Position-Check-Drawer:** System zeigt vorher Ursprungs-Mandat-Position vs. neue Position + Confidence-Match. AM bestätigt welcher Fall zutrifft (X/Y/Z) — Override jederzeit möglich
4. Honorar-Vorschlag auto-berechnet je nach Fall
5. Claim-Rechnung via passendem Template generiert
6. Rechnungs-Empfänger: einstellende Firma (aus Scraper-Fund)
7. **Berechtigung:** AM alleine (Entscheidung #5)

---

## TEIL 11: VERKNÜPFUNGEN (NEU v0.2)

### Assessment-Verknüpfung

**Bei Option IX (Fundiertes Assessment):**
1. Option gebucht → `fact_mandate_option` Eintrag mit `option_type = 'IX_assessment'`
2. Parallel: `fact_assessment_order` wird erstellt mit:
   - `mandate_id` = aktuelles Mandat
   - `account_id` = aktueller Account
   - `candidate_id` = ausgewählter Kandidat (aus Multi-Select im Option-Drawer)
3. Assessment-Detailseite `/assessments/[id]` wird verlinkt:
   - In Tab 6 Dokumente als eigener Eintrag
   - In Tab 1 Sektion 6b (Optionale Stages) als Klick-Link

**Eigenständige Assessments (ohne Mandat):** siehe Assessment-Detailmaske Spec (separater Dokument-Typ), `fact_assessment_order.mandate_id = null`.

### Referral-Verknüpfung

**Referral-Typ 1: Kandidaten-Referral**
- Empfehler (Kandidat) nennt neuen Kandidaten, der in diesem Mandat platziert wird
- Trigger im Prozess: Placement → Check `fact_referral.referred_candidate_id = placed_candidate_id`
- Wenn Match: `payout_due_at = placement_date + probezeit_ende` (nach Rückvergütungsfrist)

**Referral-Typ 2: Kunden-Referral**
- Empfehler (Kandidat) nennt neues Unternehmen, das dieses Mandat vergibt
- Trigger bei Mandat-Abschluss (`Abgeschlossen`): Check `fact_referral.referred_account_id = mandate.account_id`
- Wenn Match: `payout_due_at = mandate_closed_at`

UI:
- Banner im Mandat-Header (nur bei Kunden-Referral): *"🎁 Dieses Mandat wurde durch Empfehlung von [Referrer-Name] vergeben. Prämie CHF 1'000 fällig bei Abschluss."*
- Kandidat-Detailseite zeigt ausgehende/eingehende Referrals in Tab "Empfehlungen" (separater Spec-Punkt)

### Mandat → Prozess → Placement → Schutzfrist-Ende

Kette bei erfolgreicher Platzierung:
1. Prozess Stage `Platzierung` → Placement-Event
2. `fact_protection_window.status` für diesen Kandidaten+Account = `honored`
3. Garantie-Timer startet → 3 (oder 4/5/6) Monate
4. Bei Garantie-Austritt: Ersatzbesetzung-Workflow (Phase 2)

### Mandat → Account (Account-Detail-Referenz)

- Account-Detailseite Tab "Mandate" zeigt alle Mandate dieses Accounts mit Status, Typ, KPIs, gekündigt-Flag
- Account-Detailseite Tab "Schutzfristen" (neu v0.2) zeigt aggregiert alle aktiven Schutzfristen
- Account-Detailseite Tab "Assessments" (neu v0.2) zeigt alle Assessment-Aufträge (mandatsbezogen + eigenständig)
- Account-Detailseite Tab "Referrals" (Phase 2) zeigt alle Referrals die dieses Account betreffen

---

## TEIL 12: EVENTS & AUDIT (NEU v0.2)

Alle relevanten Mandat-Events werden in `fact_history` und `fact_event_queue` geschrieben. Siehe [[event-system]].

### Events

| Event | Trigger | Verknüpfung |
|-------|---------|-------------|
| `mandate_created` | Entwurf erstellt | Mandat |
| `mandate_activated` | Status → Aktiv | Mandat + Account |
| `mandate_completed` | Status → Abgeschlossen | Mandat + Account |
| `mandate_terminated` | Status → Abgebrochen | Mandat + Account (+ Kündigungs-Details) |
| `mandate_option_ordered` | Optionale Stage gebucht | Mandat |
| `candidate_presented_email` | Dossier per Email versendet | Mandat + Kandidat + Account |
| `candidate_presented_verbal` | Mündliche Vorstellung | Mandat + Kandidat + Account |
| `shortlist_trigger_reached` | X CVs vorgestellt | Mandat |
| `protection_window_opened` | Mandat beendet (Abschluss/Kündigung) | Kandidat + Account |
| `protection_window_extended` | Auto-Extension auf 16 Monate | Kandidat + Account |
| `termination_invoice_generated` | Kündigungs-Rechnung erstellt | Mandat + Account |

### Audit-Regel

Alle Änderungen an `fact_mandate.status`, `terminated_*`, `final_outcome` gehen durch `fact_audit_log` (wer, wann, alter Wert, neuer Wert).

---

## Related Specs

- [[mandatsofferte-vorlage]] — Original-Vorlage (Klausel I–X)
- [[rpo-offerte]] — Alte RPO-Vorlage (inhaltlich = Taskforce)
- [[mandat-kuendigung]] — Exit Option Detail
- [[direkteinstellung-schutzfrist]] — Schutzfrist-Detail
- [[optionale-stages]] — VI–X Detail
- [[diagnostik-assessment]] — Assessment-Dienstleistung
- [[referral-programm]] — Empfehlungsprämie
- [[rechnungen-mandat]] — alle Mandats-Rechnungsvorlagen
- [[honorar-berechnung]] — Fee-Logik
- [[agb-arkadium]] — Rechtsbasis
