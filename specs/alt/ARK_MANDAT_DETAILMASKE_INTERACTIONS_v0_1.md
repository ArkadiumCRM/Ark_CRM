# ARK CRM — Mandat-Detailmaske Interactions Spec v0.1

**Stand:** 12.04.2026
**Status:** Arbeitsdokument — Spec-in-Progress
**Kontext:** Definiert Verhalten, Interaktionslogik, CRUD-Flows und Speicher-Strategien für alle Tabs der Mandate-Detailseite (`/mandates/[id]`). Gleicher Methodik-Rahmen wie die Kandidaten- und Account-Interactions-Specs.
**Vorrang:** Stammdaten > dieses Dokument > Schema > Mockups
**Globale Patterns:** Es gelten alle 11 globalen Patterns aus TEIL 0 der Kandidaten-Interactions v1.2.

---

## TEIL 0: STRUKTURELLE GRUNDENTSCHEIDUNGEN

### Tab-Struktur (aus Frontend Freeze + Entity-Definition)

| # | Tab | Inhalt |
|---|-----|--------|
| 1 | Übersicht | Typ, Status, Konditionen, KPIs, Garantie, Owner, Researcher |
| 2 | Longlist | Kanban (10 Spalten) oder Liste, Drag & Drop, Durchcall-Funktion |
| 3 | Prozesse | Alle Mandate-Prozesse, Interview-Termine |
| 4 | Billing | Zahlungstracking pro Mandatstyp |
| 5 | History | History-Einträge der Longlist-Kandidaten |
| 6 | Dokumente | Reports, Mandatsofferte, Verträge |

6 Tabs. Kein konditionaler Tab.

### Mandatstypen — Kontext für alle Tabs

| Typ | Wesen | Longlist | KPIs | Billing |
|-----|-------|---------|------|---------|
| **Target** | Exklusive Suche für 1 Position | Ja, vollwertig | Ident/Call/Shortlist | Pauschale ÷ 3 |
| **Taskforce** | Team-/Standortaufbau, ≥3 Positionen | Ja, pro Position | Positionen besetzt/offen | Monatsfee + Success/Position |
| **Time** | Feste Rekrutierungskapazität in Slots | Nein (ARK liefert, Kunde führt Prozess) | Slots aktiv/pausiert | Wochenfee × Slots |

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

### Quick Actions
- **📞 Anrufen:** Öffnet Kontakt-Popover des verknüpften Accounts (Decision Makers oben)
- **✉ Email:** Analog Account
- **📄 Mandat-Report:** Quick-Generate → PDF-Report mit aktuellem Longlist-Stand, KPIs, Pipeline
- **🔔 Reminder:** Quick-Popover mit Mandat als Default-Verknüpfung

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
| 7 | **Marktanalyse** | market_capacity, market_notes | Inline-Edit |
| 8 | **Notizen** | Freitext-Notizen zum Mandat | Inline-Edit |
| 9 | **Status & Abschluss** | final_outcome, cancellation_reason, closing_report_notes, is_guarantee_refund | Nur bei Abgeschlossen/Abgebrochen sichtbar |

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
| Aktiv | Abgebrochen | Manuell (AM) | Confirm-Dialog + cancellation_reason Pflicht |

---

## TEIL 3: TAB 2 — LONGLIST

**Nur bei Target und Taskforce.** Bei Time: Tab zeigt "Time-Mandate haben keine Longlist. Kandidaten werden direkt an den Kunden übergeben." mit Link zum Prozesse-Tab.

### Ansicht
- **Kanban als Default** (umgekehrt zu Prozessen — hier ist Kanban der Hauptarbeitsort)
- Toggle auf Liste
- Keyboard-Shortcut: `K` = Kanban, `L` = Liste

### Kanban-Spalten (10)

| # | Spalte | Stage | Farbe |
|---|--------|-------|-------|
| 1 | Research | `research` | Grau |
| 2 | Nicht erreicht | `nicht_erreichbar` | Amber |
| 3 | NIC | `nicht_interessiert` | Rot (gedimmt) |
| 4 | CV Expected | `cv_expected` | Blau |
| 5 | CV IN | `cv_in` | Grün (locked 🔒) |
| 6 | Briefing | `briefing` | Grün (locked 🔒) |
| 7 | GO mündlich | `go_muendlich` | Grün (locked 🔒) |
| 8 | GO schriftlich | `go_schriftlich` | Grün (locked 🔒) |
| 9 | Dropped | `dropped` | Rot |
| 10 | Ghosted | `ghosted` | Grau (gedimmt) |

**Locking:** Ab "CV IN" (Spalte 5) sind Stages gesperrt — Cards haben 🔒 Icon, kein D&D möglich. Nur Automationen können diese Stages ändern (CV-Upload → cv_in, Briefing-Save → briefing, etc.)

### Kandidaten-Card (Kanban)

```
┌────────────────────────────┐
│ 📷 Foto  Max Muster         │
│ Bauingenieur · Implenia     │
│ 📞 Letzter Kontakt: 03.04. │
│ ⭐ Priority: Hoch           │
│ ✓ Validated                 │
└────────────────────────────┘
```

- **Foto** (Thumbnail aus `dim_candidates_profile`)
- **Name** (Klick → `/candidates/[id]` in neuem Tab)
- **Aktuelle Funktion + Arbeitgeber** (aus Werdegang)
- **Letzter Kontakt** (Datum, aus History)
- **Priority** (Hoch/Normal/Niedrig — manuell setzbar, beeinflusst Durchcall-Reihenfolge)
- **Validated-Badge** (✓ wenn `is_validated = true`)
- **NoGo-Badge** (⛔ wenn `is_nogo = true`, Card rot umrandet)

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
- Freitext-Suche (Name, Funktion)

### Listenansicht (Alternative zu Kanban)

Spalten: Name, Funktion, Arbeitgeber, Stage, Priority, Letzter Kontakt, Validated, NoGo, Notizen (truncated), Aktionen

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

---

## TEIL 5: TAB 4 — BILLING

Zahlungstracking basierend auf `fact_mandate_billing`.

### Layout — typ-spezifisch

**Target:**
| # | Zahlung | Betrag | Trigger | Status | Rechnung |
|---|---------|--------|---------|--------|----------|
| 1 | Vertragsabschluss | CHF X | Mandatsofferte unterschrieben | ✅ Bezahlt / ⏳ Offen / 🔴 Überfällig | Nr. / Datum |
| 2 | Shortlist | CHF X | Shortlist-Trigger (X CVs) | Status | Nr. / Datum |
| 3 | Placement | CHF X | Kandidat platziert | Status | Nr. / Datum |

Plus: Zusatzleistungen (Ident-Extras, Dossier-Extras) als separate Zeilen wenn vorhanden.

Summen-Zeile unten: Total / Bezahlt / Offen.

**Taskforce:**
- **Monatsfee-Sektion:** Tabelle mit einer Zeile pro Monat (Monat, Betrag, Status, Rechnung)
- **Success-Fee-Sektion:** Tabelle mit einer Zeile pro Position (Position, Betrag, Status Placement, Rechnung)
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

### Auto-Trigger (Target)
- Mandatsofferte hochgeladen → Zeile 1 (Vertragsabschluss) wird automatisch als "fällig" markiert
- Shortlist-Trigger erreicht → Zeile 2 wird "fällig" + AM-Notification
- Placement → Zeile 3 wird "fällig" + AM-Notification

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

---

## TEIL 7: TAB 6 — DOKUMENTE

### Dokumenttypen (Mandat-spezifisch)
- Mandatsofferte unterschrieben (Trigger → Aktivierung)
- Mandat-Report (auto-generiert)
- Vertrag / Rahmenvertrag
- Briefing-Unterlage (Kundenseitig)
- Sonstiges

### Mandat-Report Generator
- **"Report generieren"** Button → PDF mit:
  - Mandat-Zusammenfassung (Typ, Status, KPIs)
  - Longlist-Status (Kandidaten pro Stage)
  - Call-Statistik
  - Pipeline-Fortschritt (Prozesse pro Stage)
  - Timeline (Kickoff bis heute)
- Jeder generierte Report wird automatisch als Dokument gespeichert
- **Versionierung:** Jeder neue Report = neues Dokument, vorherige bleiben erhalten

### Upload & Trigger
- Upload "Mandatsofferte unterschrieben" → Trigger Mandats-Aktivierung (analog Account Tab 10)
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
