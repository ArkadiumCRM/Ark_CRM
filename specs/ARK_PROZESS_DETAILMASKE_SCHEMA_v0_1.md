# ARK CRM — Prozess-Detailmaske Schema v0.1

**Stand:** 13.04.2026
**Status:** Erstentwurf — Review ausstehend
**Quellen:** ARK_FRONTEND_FREEZE_v1_10.md (Section 4d.3/Processes), ARK_DATABASE_SCHEMA_v1_3.md, Wiki [[prozess]], [[honorar-berechnung]], [[jobbasket]], Entscheidungen 2026-04-13 (Mischform)
**Begleitdokument:** `ARK_PROZESS_DETAILMASKE_INTERACTIONS_v0_1.md`
**Vorrang:** Stammdaten > dieses Schema > Frontend Freeze > Mockups

---

## 0. ZIELBILD & ARCHITEKTUR-ENTSCHEIDUNG

**Ein Prozess** = ein Kandidat bei einem Account/Job in einer Stage. Kann mit oder ohne Mandat existieren (Erfolgsbasis).

### Mischform (entschieden 2026-04-13)

Der Prozess ist primär eine **Pipeline-Entity** und wird in 80% der Fälle über das **Pipeline-Modul `/processes`** (Liste + Slide-in-Drawer 540px) bearbeitet. Diese Detailseite `/processes/[id]` ist eine **schlanke Ergänzung** für:
- Erfolgsbasis-Prozesse mit Honorar-Staffel-Berechnung und Provisionen
- Post-Placement-Phase (Check-ins, Garantie, Rückvergütung)
- Dokumenten-Historie und History-Deep-Dive
- URL-basiertes Deep-Linking (Teilen, Bookmarking)

**3 Tabs statt 5+.** Kein eigener Longlist-/Research-Bereich (der lebt im Mandat).

### Primäre Nutzer

- **Candidate Manager (CM):** Hauptnutzer — Stage-Führung, Interview-Termine, Coaching/Debriefing-Notizen
- **Account Manager (AM):** Read + Kontakt-Trigger, Fee-Oversight bei Erfolgsbasis
- **Admin:** Placement-Freigabe, Rückvergütungs-Entscheidungen
- **Backoffice:** Rechnungsstellung bei Erfolgsbasis-Placement

---

## 1. DESIGNSYSTEM-REFERENZ

Erbt aus [[kandidatenmaske-schema]] § 0. Prozess-spezifisch:

### Farb-Tokens

| Token | Hex | Verwendung |
|-------|-----|-----------|
| Stage Exposé | grau | Stage-Pill |
| Stage CV Sent | blau `#60a5fa` | Stage-Pill |
| Stage TI | blau-dim | Stage-Pill (Telefoninterview/Teams) |
| Stage Interview | teal `#196774` | Stage-Pill (1./2./3.) |
| Stage Assessment | lila `#a78bfa` | Stage-Pill |
| Stage Angebot | gold `#dcb479` | Stage-Pill |
| Stage Platzierung | green `#5DCAA5` | Stage-Pill |
| Status Open | green | Aktiv |
| Status On Hold | amber | Pausiert |
| Status Rejected | red | Abgelehnt |
| Status Placed | gold | Platziert |
| Status Stale | amber-dim | Zu lange in Stage |
| Status Cancelled | red-dim | Nach Placement zurückgezogen |

### Mockup-Dateien (zu erstellen)

| # | Tab / View | Datei (geplant) |
|---|-----------|-----------------|
| — | Pipeline-Listen-Modul | `processes_pipeline_v1.html` |
| — | Slide-in-Drawer (540px) | `processes_drawer_v1.html` |
| 1 | Detailseite Übersicht | `process_uebersicht_v1.html` |
| 2 | Interviews & Honorar | `process_interviews_honorar_v1.html` |
| 3 | Dokumente & History | `process_dokumente_history_v1.html` |

---

## 2. GESAMT-LAYOUT DETAILSEITE

```
┌──────────────────────────────────────────────────────────────────┐
│ Breadcrumb: Candidates / Max Muster / Processes / P-2026-318     │
├──────────────────────────────────────────────────────────────────┤
│ HEADER                                                             │
│ ┌──────────────────────────────────────────────────────────────┐ │
│ │ Max Muster → Volare Group AG · Bauführer Tiefbau             │ │
│ │ [Stage: TI ▼]  [Status: Open ▼]  [🎯 Target Mandat] / [💼 Erfolgsbasis] │ │
│ │                                                                  │ │
│ │ PIPELINE-VISUALIZATION (9 Stages, aktueller Stage hervorgehoben)│ │
│ │ ○ Exposé ─ ● CV Sent ─ ◉ TI ─ ○ 1.IV ─ ○ 2.IV ─ ○ Ang ─ ○ Pl    │ │
│ │                                                                  │ │
│ │ SNAPSHOT-BAR (sticky, 5 Slots)                                 │ │
│ │ ⏱StageAlter  📅Nächstes  💰Fee  👥CM/AM  🛡Garantie             │ │
│ │                                                                  │ │
│ │ [📞 Anrufen] [✉ Email] [❌ Ablehnen] [⏸ On Hold] [🏆 Platzieren]│ │
│ └──────────────────────────────────────────────────────────────┘ │
│ TAB-BAR: Übersicht │ Interviews & Honorar │ Dokumente & History  │
│                                                                    │
│ TAB-CONTENT                                                        │
│ KEYBOARD-HINTS-BAR                                                 │
└──────────────────────────────────────────────────────────────────┘
```

---

## 3. BREADCRUMB

```
Candidates / [Kandidat-Name] / Processes / [Prozess-ID]     🔍  [Avatar]
```

4-stufig. Alternative Einstiegspunkte (je nach Navigation):
- `Accounts / [Account] / Processes / [Prozess-ID]`
- `Mandate / [Mandat] / Processes / [Prozess-ID]`

Breadcrumb passt sich **kontextabhängig** an Einstiegsort an (Referrer-basiert).

---

## 4. HEADER

### 4.1 Titel-Zeile

| Element | Inhalt | Interaktion |
|---------|--------|-------------|
| Identitäts-String | `[Kandidat] → [Account] · [Job]` | Kandidat/Account/Job sind Links |
| Stage-Dropdown | Aktuelle Stage, Dropdown-Wechsel | Optimistic Update, gelockte Stages siehe Interactions |
| Status-Dropdown | Open/On Hold/Rejected/Placed/Stale/Closed/Cancelled/Dropped | Confirm + ggf. Modal mit Pflichtfeldern |
| Mandat-Badge | `🎯 Target` / `⚡ Taskforce` / `⏱ Time` + Mandat-Name als Link | Read-only |
| Oder Erfolgsbasis-Badge | `💼 Erfolgsbasis` | Read-only |

### 4.2 Pipeline-Visualisierung (9 Stages)

> Shared-Component: Details in `ARK_PIPELINE_COMPONENT_v1_0.md` (Single Source of Truth). Hier nur Prozess-spezifische Abweichungen.

Prozess-Detailmaske verwendet `detailed`-Mode:
- SVG-Linie horizontal, ca. 70% Content-Breite
- WinProb-Panel rechts 280 px (Current Stage · Win-Probability · Tage in Stage · Next Stage Forecast · Audit-Footer)
- Stage-Popover mit Pflicht-Grund-Textarea (min. 10 Zeichen) + Debriefing-Check bei Interview-Stages + AGB-Warn
- Skip-Forward nur bis inkl. Angebot erlaubt. Platzierung **ausschliesslich** über Placement-Drawer (V1-Saga, 8 Steps). Kein Direkt-Sprung via Stage-Klick.
- Debriefing-Dots auf der Linie zwischen TI↔1st, 1st↔2nd, 2nd↔3rd (lila/grau, siehe Component-Spec §3.4)

Siehe `ARK_PIPELINE_COMPONENT_v1_0.md` §§3–7 für Dot-States, Popover-Verhalten, Accessibility-Anforderungen.

### 4.3 Snapshot-Bar (sticky, 5 Slots)

| Slot | Inhalt | Source |
|------|--------|--------|
| 1 | ⏱ Stage-Alter | `now − stage_changed_at` (Tage), Ampel bei Überschreitung Stale-Frist |
| 2 | 📅 Nächstes Interview | `MIN(interview_date WHERE interview_date > now)` oder "—" |
| 3 | 💰 Fee | Erfolgsbasis: berechnet aus Gehalt × Staffel. Mandat: Read-only Verweis "via [Mandat]" |
| 4 | 👥 CM / AM | Initialen-Pair |
| 5 | 🛡 Garantie | Nur bei Status Placed: Restdauer in Tagen |

### 4.4 Quick Actions

| Button | Wann | Aktion |
|--------|------|--------|
| 📞 Anrufen | immer | Click-to-Call Kandidat |
| ✉ Email | immer | Email-Composer zu Kandidat |
| ❌ Ablehnen | Status = Open / On Hold | Rejection-Modal (siehe Interactions) |
| ⏸ On Hold | Status = Open | Confirm + optional Grund |
| 🏆 Platzieren | Stage = Angebot + Status = Open | Placement-Modal (siehe Interactions) |

### 4.5 Tab-Bar

3 Tabs:
```
│ Übersicht │ Interviews & Honorar │ Dokumente & History │
```

Keyboard: `1`–`3`.

---

## 5. TAB 1 — ÜBERSICHT

### 5.1 Layout

2-col Grid, Sektionen collapsible.

### 5.2 Sektionen

#### Sektion 1 — Verknüpfungen

| Feld | Source |
|------|--------|
| Kandidat | `fact_process_core.candidate_id` → Card mit Foto + Name + Funktion + Link |
| Account | `account_id` → Card mit Logo + Name + Link |
| Job / Position | `job_id` → Name + Link |
| Mandat | `mandate_id` (optional) → Name + Typ-Badge + Link |
| Erfolgsbasis-Flag | wenn `mandate_id IS NULL` → Badge "💼 Erfolgsbasis" |
| Account-Manager (AM) | `account_id.owner` |
| Candidate-Manager (CM) | `cm_user_id` (editierbar bis Placement) |
| Hunter (falls verschieden) | `hunter_user_id` |

#### Sektion 2 — Pipeline & Timing

| Feld | Source |
|------|--------|
| Aktuelle Stage | `stage` |
| Stage-Gewechselt-am | `stage_changed_at` |
| Stage-Alter | Compute |
| Stale-Schwellwert für Stage | Aus `dim_automation_settings.process_stale_thresholds` (pro Stage konfigurierbar) |
| Prozess-Dauer | `created_at → now` oder `closed_at` |
| Erwartete Restdauer | AI-Estimate (Phase 1.5) |

#### Sektion 3 — Status-Details

| Feld | Source | Sichtbar wenn |
|------|--------|---------------|
| Status | `status` | immer |
| Rejection: rejected_by, rejection_reason, rejection_note | `rejected_by`, `rejection_reason_id`, `rejection_note` | Status = Rejected |
| On Hold: Grund | `on_hold_reason` | Status = On Hold |
| Placement-Datum | `placed_at` | Status = Placed |
| Cancellation: cancelled_by, cancellation_reason | — | Status = Cancelled |
| Closed-Datum (Garantie durch) | `closed_at` | Status = Closed |

#### Sektion 4 — Post-Placement (nur bei Status = Placed / Closed)

> **Scope-Abgrenzung (CLAUDE.md Schutzfrist-Regel):** Hier wird **ausschliesslich** die 3-Mt-Post-Placement-Garantiefrist (AGB §5) dargestellt. Die 12/16-Mt-Direkteinstellungs-Schutzfrist (AGB §6) gehört NICHT in diese Sektion — sie läuft ab Kandidaten-Vorstellung und ist bei Placement `honored` (Status), nicht mehr aktiv. Schutzfrist-Übersicht: Account-Tab „Schutzfristen" oder Kandidat-Tab „Offene Schutzfristen".

**Garantie-Widget (SVG-Zeitachse, 4 Meilensteine):**
1. PLACEMENT (Diamant, Hire-Date)
2. 1-Mt-Check (Arkadium-Call mit Kandidat)
3. 2-Mt-Check (Arkadium-Call mit Kandidat)
4. 3-Mt-Check = Garantiefrist-Ende (AGB §5 · Staffel 100/50/25/10/0 % endet)

**Nach 3. Monat:** Keine weiteren Post-Placement-Checks. Rückvergütungsfrist abgelaufen, Prozess geht auf Status=Closed. 6-Mt / 12-Mt / 2-Jahres-Checks existieren nicht.

**Feld-Grid:**

| Feld | Inhalt / Source |
|------|----------------|
| Startdatum beim Kunden | `fact_placements.hire_date` |
| Garantiefrist-Ende (AGB §5) | `hire_date + 90 d` (3 Mt, seriell) |
| Restdauer Garantie | Compute: `garantie_ende − now()` |
| Schutzfrist-Status | `fact_protection_window.status` (erwartet: `honored` nach Placement-Saga) |
| Post-Placement-Checks (Onboarding pre-start + 1./2./3. Mt) | Activity-Links zu `fact_history` — Click öffnet History-Event (Activity-Linking-Regel). Nur 4 Einträge total (Onboarding-Call vor Start · 1-Mt-Check · 2-Mt-Check · 3-Mt-Check=Garantie-Ende). Keine weiteren nach 3. Mt. |
| Austritts-Flag | `early_exit_flag` (nur bei Early-Exit) |
| Austritts-Monat (1/2/3/nach Probezeit) | für Rückvergütungs-Staffel |

**Activity-Linking-Regel (CLAUDE.md):** Alle Check-In-Zeilen (Onboarding pre-start + 1./2./3. Mt) sind Projektionen auf `fact_history` mit Activity-Types `Erreicht - Onboarding Call` (#45), `Erreicht - 1-Mt-Check` (#67), `Erreicht - 2-Mt-Check` (#68), `Erreicht - 3-Mt-Check` (#69). Kein Feld ohne Activity-Row.

#### Sektion 5 — Notizen & Kontext

- Freitext-Notizen (`notes`)
- Letzte 3 History-Einträge (Quick-Preview, Link zu Tab 3)

---

## 6. TAB 2 — INTERVIEWS & HONORAR

### 6.0 Grundregel: Arkadium-Rolle (Headhunting-Boutique · nicht-teilnehmend)

> Siehe `CLAUDE.md` §Arkadium-Rolle-Regel + Memory `project_arkadium_role.md`.

**Interviews (TI / 1./2./3. / Assessment) laufen direkt Kandidat ↔ Kunde. Arkadium nicht dabei.** Termine werden meist direkt zwischen Kandidat und Kunde vereinbart. Arkadium-Touchpoints rund um jedes Interview:

| Begriff | Teilnehmer | Wann |
|---------|-----------|------|
| **Briefing** | Arkadium ↔ Kandidat | Einmalig nach Hunt/Research — siehe Kandidatenmaske |
| **Coaching** | Arkadium ↔ Kandidat | VOR jedem Interview (TI/1st/2nd/3rd) |
| **Debriefing beidseitig** | Arkadium ↔ Kandidat UND Arkadium ↔ Kunde (separat) | NACH jedem Interview |
| **Referenzauskunft** | Arkadium ↔ Referenzperson | Im Kunden-Auftrag, vor Placement |

Im CRM sind diese 4 Activity-Kategorien `fact_history`-Events mit verschiedenen Activity-Types. Interview-Events (`ti_durchgefuehrt`, `interview_1st_durchgefuehrt`, etc.) sind Kunde+Kandidat-Ereignisse — der CM erfasst sie im CRM, nimmt aber nicht teil.

### 6.1 Sub-Section: Interview-Timeline

Eine Zeile **pro Interview-Stage** (TI, 1./2./3. Interview, Assessment, Angebot). Stage = 1 Termin zwischen Kunde und Kandidat.

| Spalte | Inhalt |
|--------|--------|
| Stage | z.B. "TI" (Kunde ↔ Kandidat), "1. Interview" |
| Termin | DateTime-Picker |
| Typ | Telefon / Teams / Vor-Ort / Hybrid |
| Teilnehmer (Kundenseite) | Multi-Select aus `dim_account_contacts` — **NICHT** Arkadium-Mitarbeiter |
| Coaching (vor Interview) | Chip mit Aktivitäts-Link → `fact_history` `coaching_vor_{stage}` · ✓ vorhanden / + erfassen |
| Debriefing beidseitig (nach Interview) | 2 Chips: `debriefing_{stage}_kandidat` + `debriefing_{stage}_kunde` — beide sollten vorhanden sein |
| Outcome | Weiter / Abgelehnt / Offen (von CM eingetragen nach Debriefing-Aggregation) |
| Kalender-Sync | ✅ wenn in Outlook/Teams eingetragen (CM hat Read-Only-View, kein Teilnehmer) |

**Activity-Linking-Regel:** Jede Coaching- und Debriefing-Chip-Zelle ist Link zu konkretem `fact_history`-Event. Kein Feld „Coaching-Notiz" als Boolean-Flag — immer auf Activity-Row projizieren (CLAUDE.md Activity-Linking-Regel).

**Auto-Reminder:** Bei Stage-Wechsel zu Interview-Stage ohne `interview_date` → Reminder "Interview-Datum fehlt" (2 Tage nach Stage-Wechsel). Siehe [[reminders]].

**Outlook-Integration:** DateTime setzen → automatischer Kalender-Eintrag für CM via CalendarReadWrite Scope — **nur als Referenz**, CM nimmt nicht am Interview teil.

### 6.2 Sub-Section: Honorar

**Bei Mandats-Prozessen (mandate_id IS NOT NULL):**

Read-only Info-Panel:
```
Fee wird über das Mandat abgerechnet.
→ [Mandat-Name] Tab Billing ansehen
```
Keine inline-Editierbarkeit. Platzierungs-Event triggert Mandat-Stage-3-Zahlung (bei Target) oder Success Fee (bei Taskforce).

**Bei Erfolgsbasis-Prozessen (mandate_id IS NULL):**

Voller Fee-Tab mit:

| Feld | Typ | Quelle |
|------|-----|--------|
| Kandidaten-Zielgehalt | CHF | `fact_process_finance.salary_candidate_target` |
| Staffel-Prozentsatz | % (aus `dim_honorar_settings` basierend auf Gehalt) | Compute |
| Überschreibbarer Prozentsatz | % (falls individuell vereinbart) | `honorar_override_pct` |
| Fee netto | CHF (Compute) | — |
| MwSt (8.1%) | CHF | — |
| Fee brutto | CHF | — |
| Zahlungsziel | Int (Tage) | aus AGB |
| Rechnung | PDF-Link wenn erstellt | `invoice_document_id` |

**Provisions-Splits (sichtbar nur für AM + Admin):**

| Rolle | % | Betrag |
|-------|---|--------|
| CM | aus `dim_mitarbeiter.commission_cm_pct` | Compute |
| AM | aus `dim_mitarbeiter.commission_am_pct` | Compute |
| Hunter | aus `dim_mitarbeiter.commission_hunter_pct` | Compute (falls Hunter ≠ CM) |

### 6.3 Sub-Section: Rückvergütung (nur nach Placement + Early Exit)

Sichtbar wenn `early_exit_flag = true`:

| Austritts-Zeitpunkt | Rückvergütung |
|---------------------|--------------|
| Stelle nicht angetreten | 100% |
| Austritt Monat 1 | 50% |
| Austritt Monat 2 | 25% |
| Austritt Monat 3 | 10% |
| Nach Probezeit | 0% |

Auto-Berechnung basierend auf `exit_date − start_date`. Button "Rückvergütung erstellen" → Drawer mit `Vorlage_Rechnung Rückerstattung.docx`.

**Ausnahmeregel:** Keine Rückvergütung wenn Austritt durch Gründe beim Kunden verursacht (`fault_side = 'client'`). Manuelle Entscheidung, Admin-Freigabe.

---

## 7. TAB 3 — DOKUMENTE & HISTORY

### 7.1 Sub-Section: Dokumente

Prozess-spezifische Kategorien:
- ARK CV (beim Versand erstellt, versioniert)
- Abstract (beim Versand)
- Exposé (beim Versand)
- Anschreiben / Motivationsschreiben
- Coaching-Unterlagen
- Interview-Notizen (formelle Protokolle)
- Angebots-Dokumente (vom Kunden)
- Arbeitsvertrag
- Rechnung (nur Erfolgsbasis)
- Rückerstattungs-Gutschrift (falls Rückvergütung)
- Referenzauskünfte (verlinkt zu Kandidat-Tab)
- Sonstiges

Layout: Card-Grid mit Kategorie-Filter (analog Mandat Tab 6).

### 7.2 Sub-Section: History

Event-Stream analog Kandidat/Mandat. Scope: `WHERE process_id = X`.

Event-Typen (prozess-spezifisch):
- `process_created` (aus Jobbasket oder manuell)
- `stage_changed` (mit alter → neuer Stage)
- `status_changed`
- `interview_scheduled` / `interview_rescheduled` / `interview_completed`
- `coaching_added` / `debriefing_added`
- `document_uploaded`
- `placed`
- `rejected`
- `placement_cancelled` (Rückzieher nach Placement)
- `early_exit_recorded`
- `guarantee_refund_issued`

Filter + Gruppierung wie andere History-Tabs.

---

## 8. KEYBOARD-HINTS-BAR

**Global:** `1`–`3` Tab · `Ctrl+K` Suche · `Esc`

**Tab 1 Übersicht:** `S` Stage ändern · `R` Ablehnen · `H` On Hold · `P` Platzieren

**Tab 2 Interviews & Honorar:** `I` Interview hinzufügen · `C` Coaching-Notiz · `D` Debriefing · `F` Fee neu berechnen (Erfolgsbasis)

**Tab 3 Dokumente & History:** `U` Upload · `F` Filter

---

## 9. RESPONSIVE

**Desktop (≥ 1280px):** 2-col Sektionen-Grid Tab 1.
**Tablet (768–1279px):** Snapshot-Bar 2-zeilig, 1-col.
**Mobile (< 768px):** Phase 2.

---

## 10. BERECHTIGUNGEN (RBAC)

| Aktion | CM (Owner) | CM (andere) | AM (Account) | Hunter | Admin | Backoffice |
|--------|-----------|-------------|--------------|--------|---------|-----------|
| Lesen (alle Tabs) | ✅ | ✅ | ✅ | ✅ | ✅ | Tab 2 (Honorar) |
| Stage ändern | ✅ | ⚠ | ⚠ | ❌ | ✅ | ❌ |
| Status ändern | ✅ | ⚠ | ⚠ | ❌ | ✅ | ❌ |
| Interview-Termin setzen | ✅ | ❌ | ⚠ | ❌ | ✅ | ❌ |
| Coaching/Debriefing | ✅ | ⚠ | ❌ | ❌ | ✅ | ❌ |
| Rejection-Flow | ✅ | ⚠ | ⚠ | ❌ | ✅ | ❌ |
| Placement setzen | ⚠ | ❌ | ⚠ | ❌ | ✅ | ❌ |
| Honorar bearbeiten (Erfolgsbasis) | ⚠ | ❌ | ✅ | ❌ | ✅ | ❌ |
| Rechnung erstellen (Erfolgsbasis) | ❌ | ❌ | ✅ | ❌ | ✅ | ✅ |
| Rückvergütung erstellen | ❌ | ❌ | ⚠ | ❌ | ✅ | ✅ |
| Provisions-Splits sehen | ❌ | ❌ | ✅ | ❌ | ✅ | ✅ |

---

## 11. DATENBANK-REFERENZ

Bestehende Tabellen (siehe [[datenbank-schema]]):
- `fact_process_core` — Haupttabelle
- `fact_process_events` — Event-Zeitstempel (created, stage_changed_at, placed_at, closed_at, ...)
- `fact_process_finance` — Gehalt, Fees, Rechnungen, Provisionen
- `fact_process_interviews` — 1 Row pro Interview-Stage (NEU v0.1 falls nicht vorhanden)

**Neue Felder (v0.1 Schema):**

```sql
fact_process_core:
  + on_hold_reason TEXT NULL
  + stale_detected_at TIMESTAMP NULL
  + cancellation_reason VARCHAR NULL
  + cancelled_by ENUM('candidate','client','internal') NULL

fact_process_interviews (falls nicht vorhanden):
  id, process_id FK, stage ENUM('ti','interview_1','interview_2','interview_3','assessment','angebot'),
  interview_date TIMESTAMP, interview_type ENUM('phone','teams','onsite','hybrid'),
  participants_account_contact_ids JSONB,
  coaching_note TEXT, debriefing_note TEXT,
  outcome ENUM('continue','rejected','open'),
  calendar_event_id VARCHAR NULL,  -- Outlook Event ID
  created_at, updated_at

dim_automation_settings:
  + process_stale_thresholds JSONB
    -- z.B. {"expose": 21, "cv_sent": 14, "ti": 7, "interview_1": 14, ...}
```

---

## 12. PIPELINE-MODUL (Referenz)

Das Listen-Modul `/processes` hat eigene UI-Patterns (nicht Teil dieser Spec, aber referenziert):

**Pipeline-Modul-Features:**
- Liste (Default, Sort stage_changed_at DESC)
- Kanban-Toggle (9 Spalten)
- Filter-Bar: Stage, Status, Mandat, AM, CM, Kandidat (Freitext), Zeitraum
- Row-Click → Slide-in-Drawer (540px) mit Pipeline-Visualisierung + Quick-Actions + letzte Aktivitäten
- Im Drawer: "→ Vollansicht öffnen" → `/processes/[id]` (diese Detailseite)
- Bulk-Actions in Liste (Multi-Select): Status → On Hold, Bulk-Ablehnen, CM ändern

Pipeline-Modul-Spec wird separat im `ARK_FRONTEND_FREEZE` behandelt — dieses Schema deckt nur die Detailseite.

---

## 13. OFFENE SPEC-PUNKTE

| # | Punkt | Priorität |
|---|-------|-----------|
| 1 | Interactions v0.1 (direkt folgend) | P0 |
| 2 | Pipeline-Modul-Spec (Liste + Drawer) — separates Dokument | P1 |
| 3 | Mockup-HTMLs (Pipeline + Drawer + 3 Detail-Tabs) | P1 |
| 4 | `fact_process_interviews` Tabelle ggf. neu — mit Schema-Audit prüfen | P1 |
| 5 | Stale-Settings-UI (Admin-Einstellungen) | P1 |
| 6 | AI-Estimate "erwartete Restdauer" | Phase 1.5 |
| 7 | Referral-Auszahlung-Trigger: Kandidaten-Referral bei Placement + Rückvergütungsfrist bestanden | Cross-Ref Referral-Programm |

---

## 14. RELATED SPECS / WIKI

- `ARK_PROZESS_DETAILMASKE_INTERACTIONS_v0_1.md`
- `ARK_MANDAT_DETAILMASKE_SCHEMA_v0_2.md` — Kreuzreferenz (Placement triggert Mandat-Billing)
- `ARK_KANDIDATENMASKE_SCHEMA_v1_3.md` — Kandidat zeigt aktive Prozesse (Tab 6)
- `ARK_ACCOUNT_DETAILMASKE_SCHEMA_v0_2.md` — Account zeigt alle Prozesse (Tab 10)
- [[prozess]], [[jobbasket]], [[honorar-berechnung]], [[erfolgsbasis]]
- [[direkteinstellung-schutzfrist]] (Rejection öffnet Schutzfrist-Fenster)
- [[referral-programm]] (Placement triggert Payout-Check)
- [[detailseiten-guideline]]
