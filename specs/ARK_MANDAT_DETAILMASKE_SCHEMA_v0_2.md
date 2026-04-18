# ARK CRM — Mandat-Detailmaske Schema v0.2

**Stand:** 14.04.2026
**Status:** Konsistenz-Update nach Audit 2026-04-14

**Änderungen v0.1 → v0.2:**
- RBAC: Mandat-Kündigung **AM alleine** (Admin-Gate entfernt, per Entscheidung #4 2026-04-14)
- Neues Feld `fact_mandate.is_longlist_locked BOOLEAN` für Kündigungs-Lock
- Neue Sektion 14.1: **Claim-Fälle X/Y/Z** (Mandat-Claim-Billing-Logik)
- Rollen-Beschreibung Admin: Kündigungs-Freigabe entfernt (Read-Only bleibt)
**Quellen:** ARK_MANDAT_DETAILMASKE_INTERACTIONS_v0_3.md, ARK_DATABASE_SCHEMA_v1_3.md, ARK_FRONTEND_FREEZE_v1_10.md (Section 4d.3), ARK_KANDIDATENMASKE_SCHEMA_v1_3.md (Style-Referenz)
**Vorrang:** Bei Widerspruch gilt: Stammdaten > dieses Schema > Frontend Freeze > Mockups
**Begleitdokument:** `ARK_MANDAT_DETAILMASKE_INTERACTIONS_v0_3.md` (Verhalten, Flows, Events)

---

## 0. ZIELBILD

Vollseite `/mandates/[id]` — zentrale Arbeitsumgebung für **Account Manager** (AM) und **Researcher** (Lead Researcher + Team) während der gesamten Mandats-Laufzeit. Unterstützt drei Mandatstypen mit typ-spezifischer Darstellung: **Target** (Exklusiv-Einzelsuche), **Taskforce** (Team-/Standortaufbau, ehemals RPO), **Time** (Slot-basierte Rekrutierungskapazität).

**Primäre Nutzer:**
- AM: Mandats-Steuerung, Kunde, Billing, Reporting, Kündigung
- Lead Researcher: Longlist-Aufbau, Durchcall-Queue, KPI-Fortschritt
- Researcher-Team: Longlist-Bearbeitung, Vorstellungen loggen
- Admin: Read-Only Überblick, Referral-Check (Kündigung: **kein Admin-Gate** — AM entscheidet alleine)

**Sekundäre Nutzer:**
- Candidate Manager (CM): wird **nicht** pro Mandat definiert — ergibt sich aus den Prozessen (wer Kandidat einbringt, wird CM des Prozesses). Sichtbarkeit der Prozesse aus Tab 3.
- Backoffice: Billing-Tab für Rechnungserstellung + Mahnwesen

---

## 1. DESIGNSYSTEM-REFERENZ

Erbt komplett aus [[kandidatenmaske-schema]] § 0. Nur Mandat-spezifische Abweichungen/Ergänzungen sind hier aufgeführt.

### Mandat-spezifische Farb-Tokens (zusätzlich)

| Token | Hex | Verwendung |
|-------|-----|-----------|
| Target-Badge | Gold `#dcb479` | `🎯 Target`-Chip |
| Taskforce-Badge | Teal `#196774` | `⚡ Taskforce`-Chip |
| Time-Badge | Dunkelblau `#1b3051` | `⏱ Time`-Chip |
| Terminated | Red `#ef4444` | `🛑 Abgebrochen`-Banner |
| Exclusivity | Green `#5DCAA5` | Exklusivitäts-Badge aktiv |
| Locked-Stage | Green-dim | Longlist Kanban Spalten 5–8 |

### Status-Pills

| Status | Farbe | Icon |
|--------|-------|------|
| Entwurf | grau `#9a968e` | ✏️ |
| Aktiv | green `#5DCAA5` | ✓ |
| Abgeschlossen | teal `#196774` | 🏆 |
| Abgebrochen | red `#ef4444` | 🛑 |
| Abgelehnt | grau-dim | ⊘ |

### Mockup-Dateien (zu erstellen)

| # | Tab | Mockup-Datei (geplant) | Status |
|---|-----|------------------------|--------|
| 1 | Übersicht | `mandat_uebersicht_v1.html` | noch zu bauen |
| 2 | Longlist | `mandat_longlist_v1.html` (Kanban + Liste) | noch zu bauen |
| 3 | Prozesse | `mandat_prozesse_v1.html` | Referenz: `kandidat_prozesse_v2.html` |
| 4 | Billing | `mandat_billing_v1.html` | noch zu bauen |
| 5 | History | `mandat_history_v1.html` | Referenz: `kandidat_history_v2.html` |
| 6 | Dokumente | `mandat_dokumente_v1.html` | Referenz: `kandidat_dokumente_v2.html` |

---

## 2. GESAMT-LAYOUT

```
┌──────────────────────────────────────────────────────────────────┐
│ Breadcrumb-Topbar                                                │
│ Accounts / Volare Group AG / Mandate / Bauführer Tiefbau        │
├──────────────────────────────────────────────────────────────────┤
│ HEADER (scrollt mit Content)                                     │
│ ┌────────────────────────────────────────────────────────────┐   │
│ │ Mandat-Name    [🎯 Target]  [Status ▼]                     │   │
│ │ Account-Link · Owner AM · Lead Researcher                  │   │
│ │                                                              │   │
│ │ SNAPSHOT-BAR (sticky, 7 Slots)                              │   │
│ │ 📊Idents  📞Calls  📋Short  💰Pauschale  ⏱TTF  🛡Gar  🔐Exk │   │
│ │                                                              │   │
│ │ QUICK ACTIONS                                                │   │
│ │ [📞 Anrufen] [✉ Email] [📄 Report] [🔔 Reminder]            │   │
│ │ [⚡ Option buchen] [🛑 Mandat kündigen]                     │   │
│ ├────────────────────────────────────────────────────────────┤   │
│ │ TAB-BAR: Übersicht │ Longlist │ Prozesse │ Billing │ Hist. │ Dok │
│ └────────────────────────────────────────────────────────────┘   │
│ TAB-CONTENT (scrollbar, je Tab spezifisch)                       │
│                                                                    │
│ KEYBOARD-HINTS-BAR (unten, tab-spezifisch)                        │
└──────────────────────────────────────────────────────────────────┘
```

**Layout-Patterns:**
- Header-Variante **B**: voller Header in jedem Tab, scrollt mit Content (wie Kandidatenmaske)
- Snapshot-Bar ist sticky innerhalb des Headers
- Tab-Bar sticky beim Scrollen innerhalb eines Tabs

---

## 3. BREADCRUMB-TOPBAR

```
Accounts / [Account-Name] / Mandate / [Mandat-Name]   🔍 Ctrl+K  [Avatar]
```

- **Links:** 4-stufige Navigation, jede Stufe klickbar
  - `Accounts` → `/accounts`
  - `[Account-Name]` → `/accounts/[id]`
  - `Mandate` → `/accounts/[id]?tab=mandate`
  - `[Mandat-Name]` (aktuell, nicht klickbar)
- **Rechts:** Globale Suche (Command Palette) + User-Avatar

---

## 4. HEADER

### 4.1 Titel-Zeile (immer sichtbar)

| Element | Inhalt | Interaktion |
|---------|--------|-------------|
| Mandat-Name | `mandate_name` (32px, fett) | Inline-Edit (Klick) |
| Typ-Badge | 🎯 Target / ⚡ Taskforce / ⏱ Time | Read-only nach Erstellung |
| Status-Dropdown | Entwurf/Aktiv/Abgeschlossen/Abgebrochen/Abgelehnt | Dropdown mit Confirm-Dialog |

### 4.2 Meta-Zeile

| Element | Inhalt |
|---------|--------|
| Account-Link | `[Account-Name]` → `/accounts/[id]` |
| Owner AM | Initialen-Avatar + Name → `/users/[id]` (Phase 2) |
| Lead Researcher | Initialen-Avatar + Name (nur Target/Taskforce) |
| Kickoff-Datum | `kickoff_date` formatiert |
| Zielplatzierungs-Datum | `target_placement_date` (optional) |

### 4.3 Snapshot-Bar (sticky `top:0, z-index:50`, **6 Slots harmonisiert 2026-04-16**)

Canonical: `.snapshot-bar` + `.snapshot-item` (lbl/val/delta, progress-bar optional) — siehe `wiki/concepts/design-system.md` §3.2b. Keine Dupes zum Header (Typ-Chip, Status-Dropdown, Stage-Chip, Exklusiv-Chip, Garantie-Chip stehen oben als banner-chips).

**Slot-Belegung einheitlich über alle 3 Mandatstypen (Target · Taskforce · Time):**

| Slot | Inhalt | Source | Progress |
|------|--------|--------|----------|
| 1 | 📊 Idents: X/Y | `research_count / target_idents` | ✅ |
| 2 | 📞 Calls: X/Y | `call_count / target_calls` | ✅ |
| 3 | 📋 Shortlist: X/Y CV Sent | `cv_sent_count / shortlist_trigger` | ✅ |
| 4 | 💰 Pauschale / Monatsfee / Wochenfee | `honorar_pauschale` (typ-abhängig) | — |
| 5 | ⏱ Time-to-fill: Woche X/Y | `current_week / expected_weeks` | ✅ |
| 6 | 🏆 Placements: X/Y | `placement_count / target_positions` | — |

**Typ-Variation im Slot-Content (Label bleibt gleich, Value typ-spezifisch):**
- **Target**: Slot 4 = „Pauschale CHF X", Slot 6 = „0/1"
- **Taskforce**: Slot 4 = „Monatsfee CHF X", Slot 6 = „X/Y Positionen"
- **Time**: Slot 4 = „Wochenfee CHF X/Slot", Slot 6 = „ausgegraut" oder „Kandidaten geliefert"

**Ampel-Logik (Slots 1–3, 5 mit Progress):**
- 🟢 Grün: Actual ≥ 80 % Target
- 🟡 Amber: 40–79 %
- 🔴 Rot: < 40 %

**Dropped (waren in v0.1 enthalten, jetzt als banner-chips oben):**
- ~~🛡 Garantie~~ → Chip „🛡 3 Mt Garantie" im banner-chips
- ~~🔐 Exklusivität~~ → Chip „Exklusiv (läuft mit Mandat)" im banner-chips

### 4.4 Quick Actions

| Button | Icon | Wann sichtbar | Aktion |
|--------|------|--------------|--------|
| Anrufen | 📞 | immer | Popover mit Account Decision Makers |
| Email | ✉ | immer | Email-Composer mit Mandat als Verknüpfung |
| Mandat-Report | 📄 | immer | PDF-Generierung + Download |
| Reminder | 🔔 | immer | Quick-Popover mit Mandat verknüpft |
| Option buchen | ⚡ | Status = Aktiv | Drawer (siehe Tab 1 / TEIL 2b Interactions) |
| Mandat kündigen | 🛑 | Status = Aktiv | Kündigungs-Drawer (siehe TEIL 9 Interactions) |

### 4.5 Tab-Bar

6 Tabs, horizontal. Aktiver Tab mit Gold-Underline. Keyboard: `1`–`6` springt zu Tab n.

```
│ Übersicht │ Longlist │ Prozesse │ Billing │ History │ Dokumente │
```

### 4.6 Terminated-Banner (nur bei Status = Abgebrochen)

Sticky unterhalb des Headers, Full-Width, rot:
```
🛑 Mandat gekündigt am 13.04.2026 durch Kunde — Grund: Anderweitige Besetzung
   Kündigungs-Rechnung: CHF 17'220.00 (Status: Rechnungsstellung) → Tab Billing
```

---

## 5. TAB 1 — ÜBERSICHT

### 5.1 Sektions-Layout

Zweispaltiges Grid (2-col), auf Mobile 1-col.

### 5.2 Sektionen (9+1)

#### Sektion 1 — Grunddaten

| Feld | Typ | DB-Quelle | Validierung |
|------|-----|-----------|-------------|
| `mandate_name` | Text | `fact_mandate.mandate_name` | Pflicht, max 255 |
| `mandate_type` | Enum-Badge | `fact_mandate.mandate_type` | Read-only nach Erstellung |
| Account | Link-Chip | `fact_mandate.account_id → dim_accounts.name` | Read-only |
| Job(s) | Multi-Link-Chips | `fact_mandate_jobs.job_id` | Taskforce: mehrere |
| **Verknüpftes Projekt** (optional, v0.3) | Autocomplete-Dropdown aus `fact_projects` (Fuzzy-Match wie Kandidat-Werdegang) | `fact_mandate.linked_project_id` FK nullable | Wenn gesetzt: Snapshot-Bar zeigt Projekt-Chip; Projekt-Detailseite zeigt Mandat in "Verwandte Mandate"-Sektion |
| `kickoff_date` | Date | `fact_mandate.kickoff_date` | ≤ heute |
| `target_placement_date` | Date | `fact_mandate.target_placement_date` | optional, ≥ kickoff |

#### Sektion 2 — Team

| Feld | Typ | DB-Quelle |
|------|-----|-----------|
| Owner AM | Single-Select | `fact_mandate.mandate_owner_id` |
| Lead Researcher | Single-Select (Target/Taskforce) | `fact_mandate.lead_researcher_id` |
| Weitere Researcher | Multi-Select | `fact_mandate_researchers.user_id` |

#### Sektion 3 — Konditionen (typ-spezifisch)

**Target:**
| Feld | Typ | DB |
|------|-----|-----|
| Pauschale | CHF | `fact_mandate.honorar_pauschale` |
| Zahlung 1 / 2 / 3 | CHF (Pauschale ÷ 3, read-only Compute) + Status-Badge | berechnet + `fact_mandate_billing` |
| Zahlungsziel (Tage) | Int | `fact_mandate.payment_terms_days` |
| Spesen-Pauschale | CHF | `fact_mandate.expenses_flat` |
| Bemerkungen | Textarea | `fact_mandate.conditions_notes` |

**Taskforce:**
| Feld | Typ | DB |
|------|-----|-----|
| Monatsfee | CHF/Monat | `fact_mandate.monthly_fee` |
| Positionen-Tabelle | Inline-CRUD | `fact_mandate_positions` (Position-Titel, Function-FK, Success-Fee, Status) |
| Zahlungsziel | Int | `payment_terms_days` |
| Spesen-Pauschale | CHF | `expenses_flat` |
| Bemerkungen | Textarea | `conditions_notes` |

**Time:**
| Feld | Typ | DB |
|------|-----|-----|
| Paket | Enum (Entry/Medium/Professional) | `fact_mandate.time_package` |
| Preis/Slot/Woche | CHF (read-only, aus Paket) | `dim_time_packages.price_per_slot_week` |
| Dauer | Wochen (Int) oder "unbefristet" | `fact_mandate.duration_weeks` |
| Monatlicher Betrag | CHF (read-only, berechnet) | Compute |
| Kündigungsfrist | Read-only "3 Wochen schriftlich" | Konstante |
| Zahlungsziel | Int | `payment_terms_days` |
| Bemerkungen | Textarea | `conditions_notes` |

#### Sektion 4 — KPI-Targets & Fortschritt (typ-spezifisch)

**Target:**
| KPI | Target | Actual | Anzeige |
|-----|--------|--------|---------|
| Idents | `target_idents` (Edit) | `COUNT(longlist)` | Progress-Bar + Ampel |
| Calls | `target_calls` (Edit) | `COUNT(fact_history WHERE type=call AND mandate_id=X)` | Progress-Bar + Ampel |
| Shortlist | `shortlist_trigger` (Edit) | `COUNT(longlist WHERE stage IN (cv_in, briefing, go_*))` | Progress-Bar + Banner bei Erreichung |

**Taskforce:**
- Positionen besetzt/offen/geplant — gestapelter Balken
- Aktive Prozesse pro Position — Inline-Liste

**Time:**
- Slots aktiv/pausiert
- Kandidaten geliefert (Summe)
- Durchschnittliche Lieferzeit pro Slot (Tage)

#### Sektion 5 — Shortlist & Extras (nur Target)

| Feld | Typ | DB |
|------|-----|-----|
| Shortlist-Trigger | Int (3 default) | `fact_mandate.shortlist_trigger` |
| Ident-Zusatzpreis | CHF pro zusätzlichem Ident | `fact_mandate.extra_ident_price` |
| Dossier-Zusatzpreis | CHF pro zusätzlichem Dossier | `fact_mandate.extra_dossier_price` |

#### Sektion 6 — Garantie

| Feld | Typ | DB |
|------|-----|-----|
| Garantiezeit | Int (Monate, 3–6) | `fact_mandate.garantie_months` |
| Garantieleistung | Read-only Text "Ersatzbesetzung" | Konstante |
| Garantie-Ablaufdatum | Date (read-only, berechnet aus placement_date) | Compute |

#### Sektion 6b — Optionale Stages (neu v0.2, erweitert v0.3)

Liste aller gebuchten `fact_mandate_option`-Einträge. Empty: *"Noch keine Optionalen Stages gebucht. [⚡ Option buchen]"*

| ▸ | Option | Beschreibung | Preis | Status | Auftrag | Rechnung |
|---|--------|-------------|-------|--------|---------|----------|
| Chevron | (dynamisch aus fact_mandate_option) | … | CHF | Badge | 📄-Link | 📄-Link |

**Inline-Expand (v0.3):** Klick auf Chevron ▸ klappt Detail-Row unterhalb aus (Drawer-Default-Regel unverletzt — read-only Detail, keine Edits).

Expand-Inhalt je nach Option-Typ:

| Typ | Expand-Inhalt |
|-----|--------------|
| **VI Mehr Idents** | `extension_value` ("+10 Idents") · neuer `target_idents`-Wert |
| **VII Mehr Dossiers** | `extension_value` · neuer `target_dossiers`-Wert |
| **VIII Marketing** | Kanal-Chip-Liste (jobs.ch, LinkedIn, …) · Laufzeit |
| **IX Assessment** | **Credits-Anzahl** (aggregiert aus `fact_assessment_order_credits WHERE order_id = fact_mandate_option.assessment_order_id`, gruppiert nach Typ) · **getestete Kandidaten** (Avatar + Name + Einzelstatus Scheduled/Completed aus `fact_candidate_assessment_version`) · Link "→ Assessment-Auftrag AS-2026-XXX öffnen" routet zu `/assessments/[id]` |
| **X Garantie-Extension** | `extension_value` (Monate) · neuer `garantie_months`-Wert · neues Ablaufdatum |

**Detail-Drawer** (separater Trigger): Über Icon "Details" in der Aktionen-Spalte (oder Doppelklick auf Zeile) — für Edit/Audit-Trail/Vollansicht.

#### Sektion 7 — Marktanalyse

| Feld | Typ | DB |
|------|-----|-----|
| Marktkapazität | Int (geschätzte Ident-Population) | `fact_mandate.market_capacity` |
| Markt-Notizen | Textarea | `fact_mandate.market_notes` |

#### Sektion 8 — Notizen

Freitext `fact_mandate.notes`. Markdown-Support (Phase 1.5).

#### Sektion 9 — Status & Abschluss (nur bei Abgeschlossen/Abgebrochen sichtbar)

| Feld | Typ | Wann |
|------|-----|------|
| `final_outcome` | Enum: `successful` / `failed_market` / `failed_client` / `other` | Abgeschlossen/Abgebrochen |
| `terminated_by` | Enum: `arkadium` / `client` | nur Abgebrochen |
| `terminated_reason` | Enum (siehe Interactions TEIL 9) | nur Abgebrochen |
| `terminated_at` | Date | nur Abgebrochen |
| `terminated_note` | Textarea | nur Abgebrochen |
| `closing_report_notes` | Textarea | Abgeschlossen |
| `is_guarantee_refund` | Boolean | Abgeschlossen |

---

## 6. TAB 2 — LONGLIST

### 6.1 Header-Controls

```
[+ Kandidat hinzufügen]  [Filter ▼]  [🔍 Suche]          [Kanban | Liste]  [📞 Nächsten anrufen (12)]
```

### 6.2 Kanban-Ansicht (Default)

10 Spalten horizontal, fixe Breite 280px, horizontal scrollbar.

| # | Spalte | Hintergrund | Locked |
|---|--------|-------------|--------|
| 1 | Research | grau | ❌ |
| 2 | Nicht erreicht | amber | ❌ |
| 3 | NIC | rot-dim | ❌ |
| 4 | CV Expected | blau | ❌ |
| 5 | CV IN | green | 🔒 |
| 6 | Briefing | green | 🔒 |
| 7 | GO mündlich | green | 🔒 |
| 8 | GO schriftlich | green | 🔒 |
| 9 | Dropped | rot | ❌ |
| 10 | Ghosted | grau-dim | ❌ |

**Spalten-Header:** Name + Count-Badge.

**Kanban-Card (Beispiel):**
```
┌────────────────────────────────┐
│ 📷  Max Muster                  │
│     Bauingenieur · Implenia     │
│     📞 03.04.2026               │
│     ⭐ Hoch · ✓ Validated       │
│     🛡 Schutz bis 12.04.2027    │  (nur Stage 5+)
└────────────────────────────────┘
```

Card-Höhe: Auto. Border: gold-dünn bei Priority Hoch, rot-umrandet bei NoGo.

### 6.3 Listen-Ansicht (Toggle)

Spalten: Foto | Name | Funktion | Arbeitgeber | Stage | Priority | Letzter Kontakt | Validated | NoGo | Schutz | Notizen | Actions

Sortierbar. Default: Priority desc, Name asc.

### 6.4 Filter-Bar

| Filter | Typ |
|--------|-----|
| Stage | Multi-Select Chips |
| Priority | Radio (Hoch/Normal/Niedrig/Alle) |
| Validated | Radio (Ja/Nein/Alle) |
| NoGo | Radio (Ja/Nein/Alle) |
| Letzter Kontakt | Date-Range oder "> X Tage" |
| Schutzfrist aktiv | Toggle |
| Freitext | Input (Name, Funktion) |

### 6.5 Durchcall-Panel (rechts oder Drawer)

Öffnet sich bei Klick "📞 Nächsten anrufen":

```
┌────────────────────────────────┐
│ Max Muster — Bauingenieur       │
│ Implenia AG · Zürich            │
│ ─────────────────────────────── │
│ Briefing-Key-Points:             │
│ • ...                            │
│ • ...                            │
│ ─────────────────────────────── │
│ [📞 Click-to-Call] (3CX)        │
│ ─────────────────────────────── │
│ Nach Call:                       │
│ [Erreicht] [Nicht erreicht]      │
│ [NIC] [Dropped] [Nummer falsch] │
└────────────────────────────────┘
```

### 6.6 Time-Mandate

Tab zeigt Empty-State:
> "Time-Mandate haben keine Longlist. Kandidaten werden direkt an den Kunden übergeben. → Tab Prozesse"

### 6.7 Empty-State (keine Longlist-Kandidaten)

> "Noch keine Kandidaten in der Longlist. [+ Kandidat hinzufügen]"

---

## 7. TAB 3 — PROZESSE

### 7.1 Ansicht

**Liste als Default** (Kanban als Toggle, Phase 2).

### 7.2 Spalten (Liste)

| Spalte | DB-Quelle |
|--------|-----------|
| Kandidat | `fact_process_core.candidate_id → dim_candidates.name` + Foto |
| Job | `fact_process_core.job_id → dim_jobs.title` (bei Taskforce: welche Position) |
| Stage | `fact_process_core.stage` (Enum Exposé → Platzierung) |
| Status | `fact_process_core.status` (Open/On Hold/Rejected/Placed) |
| Nächstes Interview | MAX(`fact_interviews.interview_date WHERE date > now`) |
| CM | `fact_process_core.cm_user_id` (Initialen) |
| Erstellt | `fact_process_core.created_at` |
| Actions | Drawer / Vollansicht |

### 7.3 Row-Click-Verhalten

Klick → Drawer (540px):
- Stage-Pipeline (visuell)
- Nächstes Interview + Typ
- Honorar-Preview
- Letzte 3 Aktivitäten
- **"Vollansicht öffnen →"** → `/processes/[id]`

### 7.4 Filter

- Stage-Chips (Multi-Select)
- Status (Radio: Aktiv/Placed/Abgelehnt/Alle)
- Kandidat-Suche (Freitext)

### 7.5 Empty-State

> "Noch keine Prozesse in diesem Mandat. Prozesse entstehen automatisch aus dem Jobbasket des Kandidaten."

---

## 8. TAB 4 — BILLING

### 8.1 Layout

Oben: Summen-Zeile (Gesamt / Bezahlt / Offen / Überfällig als farb-Badges).

Darunter typ-spezifische Sektionen + gemeinsame Sektionen "Optionale Stages" und "Kündigung/Rückerstattung" (konditional).

### 8.2 Target — Zahlungsplan

| # | Zahlung | Betrag | Trigger | Status | Rechnung |
|---|---------|--------|---------|--------|----------|
| 1 | Vertragsabschluss | CHF X | Mandatsofferte unterschrieben | Badge | Nr./Datum/PDF |
| 2 | Shortlist | CHF X | Shortlist-Trigger erreicht | Badge | Nr./Datum/PDF |
| 3 | Placement | CHF X | Kandidat platziert | Badge | Nr./Datum/PDF |

**Actions pro Zeile:**
- "Rechnung erstellen" (wenn Status = Offen + fällig)
- "Als bezahlt markieren" (wenn Status = Rechnungsstellung)
- "PDF ansehen" (wenn Rechnung existiert)

### 8.3 Taskforce — Monatsfee + Success Fee

Zwei Sub-Sektionen:

**Monatsfee-Tabelle:**
| Monat | Betrag | Status | Rechnung |

**Success-Fee-Tabelle:**
| Position | Kandidat | Success Fee | Status Placement | Rechnung |

### 8.4 Time — Wochenfee

| Monat | Slots aktiv | Preis/Slot/Woche | Wochen im Monat | Betrag | Status | Rechnung |

### 8.5 Optionale Stages (dynamisch)

Nur sichtbar wenn `fact_mandate_option` Einträge existieren.

| Option | Beschreibung | Preis | Status | Auftrag | Rechnung |

### 8.6 Kündigung / Rückerstattung (konditional)

Nur sichtbar bei Status = Abgebrochen oder bei Garantie-Refund.

| Typ | Betrag | Grund | Datum | Rechnung |
|-----|--------|-------|-------|----------|
| Kündigungs-Rechnung | CHF X | (Formel-Anzeige) | terminated_at | PDF |
| Rückerstattung | CHF X | Austritt in Monat X | refund_date | Gutschrift-PDF |

### 8.7 Status-Badges

- ⏳ Offen (amber)
- 📄 Rechnungsstellung (blau)
- ✅ Bezahlt (green)
- 🔴 Überfällig (rot)

---

## 9. TAB 5 — HISTORY

### 9.1 KPI-Banner (oben, Researcher-Fokus)

```
Calls diese Woche: 8/20 Target  🟡   Erreicht: 5  Nicht erreicht: 3  Ratio: 62%
```

### 9.2 Filter-Bar

Analog Kandidaten-History + zusätzlich:
- Kandidat (Dropdown)
- Stage (Longlist-Stage)
- Activity-Typ (Multi-Select)
- Zeitraum
- **"Vorstellungs-Events"** (Quick-Filter neu v0.2)

### 9.3 Einträge (Liste)

| Spalte |
|--------|
| Datum + Uhrzeit |
| Kandidat (Foto + Name) |
| ActivityType-Icon + Label |
| Notiz (truncated) |
| User (Initialen) |
| AI-Klassifizierung-Badge |
| Drawer-Icon |

### 9.4 Gruppierung (Toggle)

Option "Nach Kandidat gruppieren" — faltbar pro Kandidat, zeigt alle Events chronologisch.

### 9.5 Empty-State

> "Noch keine History-Einträge. Aktivitäten werden automatisch geloggt, sobald Research oder Kontakte stattfinden."

---

## 10. TAB 6 — DOKUMENTE

### 10.1 Layout

Ähnlich Kandidaten-Dokumente:
- Linke Spalte: Kategorien-Filter
- Rechte Spalte: Kartenraster oder Listenansicht

### 10.2 Kategorien (Mandat-spezifisch)

| Kategorie | Trigger |
|-----------|---------|
| Mandatsofferte | Upload unterschriebener PDF → Mandats-Aktivierung |
| Mandat-Report | Auto-Generator (siehe 10.4) |
| Vertrag/Rahmenvertrag | Manuell |
| Briefing-Unterlage | Kundenseitig, manuell |
| Auftragserteilung Optionale Stage | Beim Buchen von Option VI–X |
| Kündigungs-Rechnung | Auto bei Abbruch |
| Rückerstattungs-Gutschrift | Auto bei Garantie-Refund (Best Effort) |
| Assessment-Dokumente | Bei Option IX — verlinkt zu Assessment-Detailseite |
| Sonstiges | Manuell |

### 10.3 Dokument-Card

```
┌────────────────────────────┐
│ 📄 Mandatsofferte_unt.pdf  │
│ Kategorie: Mandatsofferte   │
│ Upload: 01.04.2026, PW      │
│ 2.4 MB · v1                 │
│ [Preview] [Download] [⋯]    │
└────────────────────────────┘
```

### 10.4 Mandat-Report Generator (CTA-Button oben)

```
[📄 Report generieren]
```

Output-PDF beinhaltet:
- Mandat-Zusammenfassung (Typ, Status, KPIs)
- Longlist-Status (Kandidaten pro Stage)
- Call-Statistik
- Pipeline-Fortschritt
- Timeline
- Optionale Stages Übersicht
- Schutzfrist-Kandidaten-Liste

Versionierung: Jede Generation = neues Dokument, alte bleiben.

### 10.5 Upload

Drag & Drop + File-Picker. Beim Upload:
- Kategorie-Dropdown (siehe 10.2)
- Kommentar (optional)
- Mandats-Verknüpfung automatisch

### 10.6 Empty-State

> "Noch keine Dokumente. Lade die Mandatsofferte hoch, um das Mandat zu aktivieren. [📤 Upload]"

---

## 11. KEYBOARD-HINTS-BAR (unten, tab-spezifisch)

Einheitlich unten sticky, tab-spezifische Shortcuts.

**Global:**
- `1`–`6`: Tab wechseln
- `Ctrl+K`: Suche
- `Esc`: Drawer schliessen

**Tab 1 Übersicht:**
- `E`: Edit-Mode aktivieren
- `S`: Save

**Tab 2 Longlist:**
- `K`: Kanban-Ansicht
- `L`: Listen-Ansicht
- `N`: Nächsten anrufen (Durchcall)
- `+`: Kandidat hinzufügen

**Tab 3 Prozesse:**
- `L`: Liste
- `K`: Kanban (Phase 2)

**Tab 4 Billing:**
- `R`: Rechnung erstellen (bei aktiver Zeile)
- `P`: Als bezahlt markieren

**Tab 5 History:**
- `F`: Filter öffnen
- `G`: Gruppierung togglen

**Tab 6 Dokumente:**
- `U`: Upload
- `G`: Report generieren

---

## 12. RESPONSIVE-VERHALTEN

**Desktop (≥ 1280px):** Volle Darstellung, 2-col Sektionen-Grid in Tab 1.

**Tablet (768–1279px):** Snapshot-Bar wird auf 2 Zeilen umgebrochen, Sektionen 1-col.

**Mobile (< 768px):** Phase 2. Tab 2 Kanban → Listenansicht erzwungen.

---

## 13. BERECHTIGUNGEN (RBAC)

Siehe [[berechtigungen]] für Details zu 4-Level-Modell.

| Aktion | AM (Owner) | AM (andere) | Researcher | CM | Admin | Backoffice |
|--------|-----------|-------------|------------|-----|---------|-----------|
| Lesen (alle Tabs) | ✅ | ✅ | ✅ | ✅ | ✅ | Tab 4, 6 |
| Übersicht editieren | ✅ | ⚠ (Read) | ❌ | ❌ | ✅ | ❌ |
| Longlist editieren | ✅ | ⚠ | ✅ | ❌ | ✅ | ❌ |
| Option buchen | ✅ | ❌ | ❌ | ❌ | ✅ | ❌ |
| Mandat kündigen | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Billing-Rechnung erstellen | ✅ | ❌ | ❌ | ❌ | ✅ | ✅ |
| Billing als bezahlt markieren | ⚠ | ❌ | ❌ | ❌ | ✅ | ✅ |
| Dokument hochladen | ✅ | ⚠ | ✅ | ❌ | ✅ | ✅ |
| Dokument löschen | ✅ | ❌ | ❌ | ❌ | ✅ | ❌ |

**⚠ = Read-only oder nur in Ausnahmen (z.B. AM-Stellvertretung).**

---

## 14. DATENBANK-REFERENZ (Neue/Erweiterte Tabellen v0.2)

```sql
-- Bestehende Tabelle mit neuen Feldern
fact_mandate
  + terminated_by: enum('arkadium','client') nullable
  + terminated_reason: varchar nullable
  + terminated_at: date nullable
  + terminated_note: text nullable
  + termination_invoice_id: FK nullable
  + is_exclusive: BOOLEAN DEFAULT TRUE  -- v0.3: Exklusivität hat kein Ablaufdatum — gilt solange Mandat offen (14.04.2026)
  + final_outcome: enum(...) nullable
  + is_longlist_locked: BOOLEAN DEFAULT FALSE  -- v0.2: wird bei Kündigung TRUE, sperrt Longlist-Editierung

-- Neue Tabelle
fact_mandate_option (id, mandate_id, option_type, price_chf, extension_value, status, ordered_at, signed_document_id, invoice_id, assessment_order_id)

-- Neue Tabellen (Schutzfrist)
fact_candidate_presentation (id, candidate_id, account_id, mandat_id, prozess_id, presentation_type, presented_at, presented_by)
fact_protection_window (id, presentation_id, candidate_id, account_id, starts_at, base_duration_months, extended, expires_at, info_requested_at, info_received_at, status)

-- Erweiterte Tabelle
fact_mandate_billing
  + billing_type ENUM erweitert: 'termination' | 'option' | 'refund' zusätzlich zu bestehenden stage/monthly/success/weekly

-- Neue Tabelle (Referral)
fact_referral (id, referral_type, referrer_candidate_id, referred_candidate_id, referred_account_id, linked_prozess_id, linked_mandat_id, payout_amount, payout_due_at, payout_date, status)
```

Vollständige Migration: siehe `ARK_DATABASE_SCHEMA_v1_3.md` (ausstehend, nach Spec-Review).

---

## 14.1 CLAIM-FÄLLE X/Y/Z (Mandat-Claim-Billing-Logik)

Wenn ein Mandat gekündigt wird und später ein Longlist-Kandidat (der durch Arkadium identifiziert wurde) vom Auftraggeber (oder einer Konzerngesellschaft) eingestellt wird, entsteht ein **Claim**. Das Mandat giltet **immer nur auf die definierte Position**. Drei Fälle:

| Fall | Konstellation | Billing-Logik |
|------|---------------|---------------|
| **X** | Kandidat wird für die **ursprünglich definierte Position** eingestellt | **Restliche Mandats-Summe** wird fällig (Stage-Rest), gemäss Honorar-Staffel `dim_honorar_settings` |
| **Y** | Kandidat wird für eine **andere Position** beim selben Auftraggeber eingestellt | **Erfolgsbasis-Deal** — neue Honorar-Berechnung auf Basis TC der tatsächlich angetretenen Position, Mandats-Rest entfällt |
| **Z** | Kandidat wird bei **verbundener Gesellschaft** (Firmengruppe) eingestellt — Scope-Abhängigkeit | Wie Fall X/Y je nach Position, aber nur wenn Schutzfrist-Scope `group` greift (siehe [[direkteinstellung-schutzfrist]]) |

**Technische Repräsentation:**
- `fact_protection_window.claim_case ENUM('X','Y','Z')` nullable (gesetzt bei Claim-Auslösung)
- `fact_mandate_billing.billing_type = 'claim'` neu (zusätzlich zu 'termination'/'option'/'refund')
- Berechnung via `dim_honorar_settings` Staffel anhand Claim-Fall + tatsächlichem TC

**Auslöser:** Scraper-Match (Kandidat auf neuer Stelle bei Kunde) oder manuelle Claim-Anlage durch AM. Siehe Interactions v0.3 TEIL 10.

---

## 15. OFFENE SPEC-PUNKTE

| # | Punkt | Priorität |
|---|-------|-----------|
| 1 | Mockup-HTMLs für alle 6 Tabs erstellen | P1 |
| 2 | Referral-Banner UI im Header (nur Kunden-Referral) | P1 |
| 3 | Exklusivitätsbruch-Detection-Flow (Scraper-basiert) | Phase 2 |
| 4 | Garantie-Case-Workflow (Ersatzbesetzung als Child-Mandat?) | Phase 2 |
| 5 | Entkündigung/Reaktivierung | Phase 2, falls gewünscht |
| 6 | Mobile-Layout Tab 2 Longlist | Phase 2 |

---

## 16. RELATED SPECS / WIKI

- `ARK_MANDAT_DETAILMASKE_INTERACTIONS_v0_3.md` — Verhalten, Flows
- `ARK_ACCOUNT_DETAILMASKE_INTERACTIONS_v0_3.md` + Schema v0.1 (ausstehend)
- `ARK_KANDIDATENMASKE_SCHEMA_v1_3.md` — Style-Referenz
- [[mandat]], [[mandat-kuendigung]], [[optionale-stages]], [[direkteinstellung-schutzfrist]]
- [[diagnostik-assessment]] (Assessment-Verknüpfung)
- [[referral-programm]]
- [[detailseiten-guideline]]
