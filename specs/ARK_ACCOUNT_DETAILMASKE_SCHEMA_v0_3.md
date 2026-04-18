# ARK CRM — Account-Detailmaske Schema v0.3

**Stand:** 18.04.2026
**Status:** Tab-8-Sync zu Interactions v0.3 (autorefine Run 2 · 2026-04-18)
**Quellen:** ARK_ACCOUNT_DETAILMASKE_INTERACTIONS_v0_3.md, ARK_DATABASE_SCHEMA_v1_3.md, ARK_FRONTEND_FREEZE_v1_10.md (Section 4d.2), ARK_KANDIDATENMASKE_SCHEMA_v1_3.md (Style-Referenz), ARK_MANDAT_DETAILMASKE_SCHEMA_v0_2.md (Konsistenz)
**Vorrang:** Bei Widerspruch gilt: Stammdaten > dieses Schema > Frontend Freeze > Mockups
**Begleitdokument:** `ARK_ACCOUNT_DETAILMASKE_INTERACTIONS_v0_3.md` (Verhalten, Flows, Events)
**Hinweis:** Dateiname noch `_v0_2.md` — Rename auf `_v0_3.md` als Follow-up offen (vgl. nachbearbeitung.md).

**Änderungen v0.2 → v0.3 (2026-04-18, via autorefine):**
- **Tab 8 Assessments — Credits-Übersicht-Banner** ergänzt (§12.1, §12.3): zweite KPI-Banner-Zeile mit typisiertem Breakdown (MDI/Relief/ASSESS/DISC), Total-Zeile mit Gesamtpreis. Source: `fact_assessment_order_credits` aggregiert über `order.account_id`.
- **Tab 8 Spalten** (§12.2): neue Spalte **Credits-Mix**; Status-Wert `invoiced` entfernt (Rechnungs-State lebt auf `fact_assessment_billing`, nicht auf `fact_assessment_order` — vgl. Memory `feedback_assessment_order_status.md`).
- **Tab 8 Filter** (§12.1): Chip "Typ (Multi-Select)" ergänzt neben Mandatsbezogen/Eigenständig/Status-Chips.
- **Neuer konditionaler Tab Projekte (§19)**: analog zum Firmengruppe-Pattern, sichtbar wenn Account als Bauherr oder via `fact_project_company_participations` mit Projekten verknüpft ist. Filter-Chips (Rolle/Status/Zeitraum) + Aggregations-Tabelle + Header-Quick-Action "🏗 Projekt verknüpfen". Details TEIL 14 Interactions v0.3.

**Änderungen v0.1 → v0.2:**
- RBAC-Rolle `Founder` → `Admin` (global, per Entscheidung 2026-04-14)
- Stale "v0.2-Update ausstehend"-Note entfernt (Interactions v0.3 deckt Tab 8/9 ab)
- Typisierte Credits-Referenz in Tab 8 klargestellt (FK `fact_assessment_order_credits`)
- **Snapshot-Bar Slots 5+6:** Offene Mandate / Aktive Prozesse → Gegründet / Standorte (reine Firmografik, Entscheidung 14.04.2026)
- **Tab 1 Arkadium-Relation KPI-Bar** (4 KPIs: Umsatz YTD, Placements, Ø Time-to-Hire, Conversion) ergänzt
- **Kontakt-Drawer (Tab 3)** erweitert um 4-Tab-Struktur: Stammdaten / Kommunikation / Prozesse / Notizen — Kommunikations-Verlauf-Tab mit Filter-Chips + Kennzahlen (Details siehe Interactions v0.3 TEIL 4)
- **Kontakt-Rollen-Refactor:** Subjektive Flags (`is_decision_maker`/`is_key_contact`/`is_champion`/`is_blocker`) und redundante `decision_level`-Spalte **entfernt** — ersetzt durch objektive `org_function` ENUM (7 Codes aus `dim_org_functions`)

---

## 0. ZIELBILD

Vollseite `/accounts/[id]` — zentrale Kunden-Detailsicht für **Account Manager** (AM). Umfasst Stammdaten, Kultur-Analyse, Organisations-Struktur, Mandate/Assessments/Prozesse-Übersicht sowie alle Beziehungs-Artefakte (Kontakte, Standorte, History, Dokumente, Schutzfristen).

**Primäre Nutzer:**
- AM: Vollbearbeitung aller Tabs, Mandats-/Assessment-Start, Kulturanalyse, Kontakt-Management
- Researcher: Lesezugriff für Kontext (Briefing, Kulturprofil)
- Admin: Read-Only + Strategie-Entscheidungen (Blacklisting, AGB-Freigabe, Kündigung)
- Backoffice: Billing-relevante Sektionen, Rechnungsadressen
- CM: Kontext für Kandidaten-Platzierung (Kultur, Kontakte, Arbeitgeber-Infos)

---

## 1. DESIGNSYSTEM-REFERENZ

Erbt aus [[kandidatenmaske-schema]] § 0. Account-spezifische Ergänzungen:

### Account-spezifische Farb-Tokens

| Token | Hex | Verwendung |
|-------|-----|-----------|
| Status Active | Green `#5DCAA5` | Status-Pill aktiver Kunde |
| Status Prospect | Gold `#dcb479` | Status-Pill Akquise |
| Status Inactive | Grau `#9a968e` | Status-Pill inaktiv |
| Status Blacklisted | Red `#ef4444` | Status-Pill Negativliste |
| AGB bestätigt | Green | AGB-Badge positiv |
| AGB offen | Amber | AGB-Badge ausstehend |
| Hot | Red `#ef4444` | 🔥 Account Temperature |
| Warm | Amber `#f59e0b` | 🟡 Account Temperature |
| Cold | Blue `#60a5fa` | 🔵 Account Temperature |
| Customer Class A | Gold | A-Kunde-Pill |
| Customer Class B | Silber/Teal | B-Kunde-Pill |
| Customer Class C | Grau | C-Kunde-Pill |

### Mockup-Dateien (zu erstellen)

| # | Tab | Datei (geplant) |
|---|-----|-----------------|
| 1 | Übersicht | `account_uebersicht_v1.html` |
| 2 | Profil & Kultur | `account_kultur_v1.html` |
| 3 | Kontakte | `account_kontakte_v1.html` |
| 4 | Standorte | `account_standorte_v1.html` |
| 5 | Organisation | `account_organisation_v1.html` (Stellenplan + Teamrad) |
| 6 | Jobs & Vakanzen | `account_jobs_v1.html` |
| 7 | Mandate | `account_mandate_v1.html` |
| 8 | Assessments | `account_assessments_v1.html` (neu) |
| 9 | Schutzfristen | `account_schutzfristen_v1.html` (neu) |
| 10 | Prozesse | `account_prozesse_v1.html` |
| 11 | History | `account_history_v1.html` |
| 12 | Dokumente | `account_dokumente_v1.html` |
| 13 | Reminders | `account_reminders_v1.html` |
| + | Firmengruppe | `account_gruppe_v1.html` (konditional) |

---

## 2. GESAMT-LAYOUT

```
┌──────────────────────────────────────────────────────────────────┐
│ Breadcrumb-Topbar: Accounts / Volare Group AG                    │
├──────────────────────────────────────────────────────────────────┤
│ HEADER                                                             │
│ ┌──────────────────────────────────────────────────────────────┐ │
│ │ [Logo]  Volare Group AG  [Sparte]  [Status ▼]  [A]           │ │
│ │         Einkaufspotenzial ★★★   [AGB ✓ 12.03.2025]  [🔥 Hot] │ │
│ │         Auch bekannt als: Volare, Volare AG                    │ │
│ │                                                                  │ │
│ │ SNAPSHOT-BAR (sticky, 6 KPI-Slots)                             │ │
│ │ 👥Mitarb  📈Wachstum  💰Umsatz  ⭐Kulturfit  📋Mandate  ⚙Pro │ │
│ │                                                                  │ │
│ │ [📞 Anrufen] [✉ Email] [🔔 Reminder]                           │ │
│ └──────────────────────────────────────────────────────────────┘ │
│ TAB-BAR: 13 Tabs horizontal (+ 1 konditional)                     │
│                                                                    │
│ TAB-CONTENT                                                        │
│ KEYBOARD-HINTS-BAR                                                 │
└──────────────────────────────────────────────────────────────────┘
```

**Layout-Patterns:**
- Header-Variante **B**: voller Header in jedem Tab, scrollt mit Content
- Snapshot-Bar sticky innerhalb Header
- Tab-Bar sticky beim Scrollen

---

## 3. BREADCRUMB-TOPBAR

```
Accounts / [Account-Name]          🔍 Ctrl+K  [Avatar]
```

2-stufig. Klick auf "Accounts" → Liste mit erhaltenem Filter/Scroll.

---

## 4. HEADER

### 4.1 Logo-Bereich (links, 120×120)

- **Quelle:** Scraper-Auto-Fetch (bei `scraping_enabled = true`)
- **Fallback:** Farbige Initialen-Kreis (z.B. "VG" für Volare Group)
- **Manueller Upload:** Gold "+"-Button → Datei-Dialog
- **Klick:** öffnet `website_url` in neuem Tab

### 4.2 Titel-Zeile

| Element | Inhalt | Interaktion |
|---------|--------|-------------|
| Account-Name | `dim_accounts.account_name` (32px, fett) | Inline-Edit |
| Sparte-Badge | `sparte_id` → Label | Read-only (Änderung in Tab 1) |
| Status-Dropdown | Active/Prospect/Inactive/Blacklisted | Dropdown + Confirm-Dialog |
| Customer Class Pill | A/B/C | Inline-Edit |
| Einkaufspotenzial Pill | ★/★★/★★★ | Inline-Edit |
| AGB-Badge | ✓ grün mit Datum oder ⏳ amber "ausstehend" | Klick → Tab 1 Sektion 6 |
| Temperature Badge | 🔥 Hot / 🟡 Warm / 🔵 Cold | Tooltip: Hard-Rule oder Score |

### 4.3 Aliases-Zeile (konditional)

Versteckt wenn keine Aliases. Sonst graue Zeile: *"Auch bekannt als: Volare, Volare AG, Volare Group"*. Klick → Edit-Drawer in Tab 1 Sektion 1.

### 4.4 Snapshot-Bar (sticky `top:0, z-index:50`, über Tabbar) — **Reine Firmografik (Entscheidung 14.04.2026)**

Bewusst **keine Arkadium-Beziehungs-Metriken** in der Snapshot-Bar. Beziehungs-KPIs leben in der Tab-1-KPI-Bar (siehe §5).

Canonical: `.snapshot-bar` + `.snapshot-item` (lbl/val/delta) — siehe `wiki/concepts/design-system.md` §3.2b. Keine Dupes zum Header (banner-meta/banner-chips/Status-Dropdown).

| Slot | KPI | Source |
|------|-----|--------|
| 1 | 👥 Mitarbeitende CH-weit | `dim_accounts.employee_count` |
| 2 | 📈 Wachstum 3 Jahre | `dim_accounts.growth_rate_3y_pct` |
| 3 | 💰 Umsatz letztes GJ | `dim_accounts.revenue_last_year_chf` |
| 4 | 🏛 Gegründet | `dim_accounts.founded_year` (mit Alters-Berechnung) |
| 5 | 📍 Standorte | `COUNT(dim_account_locations WHERE account_id)` |
| 6 | ⭐ Kulturfit-Score | aus Tab 2 berechnet |

Slot 6 zeigt "—" wenn keine Kultur-Analyse vorliegt. Klick auf Slot 5 → wechselt zu Tab 4 Standorte.

### 4.5 Quick Actions

| Button | Wann | Aktion |
|--------|------|--------|
| 📞 Anrufen | immer | Popover aller Kontakt-Telefonnummern (Decision Maker oben), Click-to-Call via 3CX |
| ✉ Email | immer | Popover: "📧 Neue Email (CRM)" + "📨 In Outlook öffnen" |
| 🔔 Reminder | immer | Quick-Popover Minimalfelder + "Erweitert →" Drawer |

### 4.6 Tab-Bar (13 Tabs + 1 konditional)

```
Übersicht · Profil&Kultur · Kontakte · Standorte · Organisation · Jobs · Mandate · Assessments · Schutzfristen · Prozesse · History · Dokumente · Reminders  [· Firmengruppe]  [· Projekte]
```

Aktiver Tab mit Gold-Underline. Keyboard: `1`–`9` springt zu Tab 1–9, `0` zu Tab 10, höhere Tabs per Klick.

### 4.7 Soft-Block-Banner (konditional)

| Flag | Banner (Full-Width, amber/rot) |
|------|-------------------------------|
| `account_status = 'Blacklisted'` | 🚫 **BLACKLISTED** — Aktionen erfordern Bestätigung + Audit-Log |
| `is_no_hunt = true` | 🚷 **No-Hunt-Account** — Kandidaten-Abwerbung bei diesem Kunden untersagt |

---

## 5. TAB 1 — ÜBERSICHT (STAMMDATEN + ARKADIUM-RELATION-KPIs)

### 5.0 Arkadium-Relation KPI-Bar (NEU 14.04.2026)

Vier KPI-Kacheln über den 10 Sektionen — komplementär zur Snapshot-Bar (Firmografik). Visuell wie Snapshot-Bar (Serif-Zahl + Uppercase-Label).

| KPI | Berechnung |
|-----|-----------|
| 💰 Umsatz mit Arkadium YTD | `SUM(fact_mandate_billing.amount WHERE account_id AND year=current AND status='paid')` + Erfolgsbasis |
| 🏆 Placements total | `COUNT(fact_process_core WHERE account_id AND status='Placed')` |
| ⏱ Ø Time-to-Hire | Mittel `(placed_at - opened_at)` letzte 12 Mt |
| 📈 Conversion CV→Placement | `Placed / CV Sent` letzte 12 Mt |


### 5.1 Layout

2-col Grid, 10 Sektionen (collapsible, default offen).

### 5.2 Sektionen

| # | Sektion | Key-Felder |
|---|---------|-----------|
| 1 | **Identität** | account_name, account_legal_name, handelsregister_uid, account_aliases (Drawer), founded_year, account_status, customer_class, purchase_potential, sparte_id, owner_team |
| 2 | **Web & Kontakt** | website_url, domain_normalized (read-only), career_page_url, team_page_url, linkedin_url, country, account_manager_id |
| 3 | **Unternehmensgrösse** | employee_count, growth_rate_3y_pct, revenue_last_year_chf, revenue_estimate_chf, founded_year |
| 4 | **Klassifikation & Verknüpfungen** | industry, taetigkeitsfelder, usp + Sparte/Sector/Cluster/Functions/Focus |
| 5 | **Intelligence** | penetration_score, hiring_potential_ranking, hiring_season, job_posting_frequency, fluktuation_rate, competitor_headhunters, dossier_send_preference |
| 6 | **Flags & Regeln** | is_no_hunt, has_had_process, AGB-Block (agb_confirmed_at, agb_version) |
| 7 | **Scraping** | scraping_enabled (Toggle), scrape_interval_hours, last_scraped_at, "Jetzt scrapen" Button (rate-limited) |
| 8 | **Notizen** | comment_short, comment_internal |
| 9 | **Zugehörigkeit** | account_group_id (Link zur Firmengruppe oder Button zum Hinzufügen) |
| 10 | **Audit** | created_at, updated_at, created_by, updated_by (read-only) |

### 5.3 Verknüpfungs-Sub-Sektion (in Sektion 4)

| Feld | Pflege-Pattern |
|------|---------------|
| Sparte | Multi-Toggle (5 Tags ING/GT/ARC/REM/PUR), mind. 1 aktiv |
| Sector | Inline Autocomplete (~50), Multi-Select |
| Cluster | Inline Autocomplete hierarchisch → Subcluster |
| Functions | **Auto-aggregiert** read-only: "🏗 Functions die wir kennen: Polier (12), Bauführer (8)…" |
| Focus | **Auto-aggregiert** analog Functions |

### 5.4 Pflichtfelder

- **Hart:** account_name, country, sparte_id, account_manager_id
- **Weich (erwartet):** website_url, employee_count, AGB bei A-Kunden

---

## 6. TAB 2 — PROFIL & KULTUR

### 6.1 Sektionen (5)

| # | Sektion | Inhalt |
|---|---------|--------|
| 1 | Vision · Mission · Purpose | Vision (Textarea), Mission (Textarea), Purpose (Textarea), Kernwerte (Tag-Liste) |
| 2 | Führung & Strategie | Führungsstil, Entscheidungskultur, Transformationsreife, Wachstumsstrategie, Differenzierung, Nachfolgeregelung |
| 3 | Kulturprofil — Arkadium Analyse | 6 Score-Dimensionen mit Balken: Leistungsorientierung, Innovationskultur, Autonomiespielraum, Feedbackkultur, Hierarchieflachheit, Transformationsreife |
| 4 | Kulturfit-Score | Gesamt-Score 0–100 mit Methodik-Tooltip |
| 5 | Quellen & Vertrauen | Datenquellen der AI-Generierung, Konfidenz pro Sektion |

### 6.2 AI-Workflow

CTA-Button "Analyse generieren" → AI-Vorschläge mit gelber Umrandung + "AI"-Badge. AM bestätigt sektionsweise ("✓ Sektion bestätigen") oder korrigiert.

### 6.3 Versionierung

Jede Generierung = neue Version, Pfeil-Navigation, Diff-Ansicht (Phase 2).

### 6.4 Berechtigung

Nur Admin + Mitarbeiter mit Rolle `Account_Manager`.

---

## 7. TAB 3 — KONTAKTE

### 7.1 Zwei Sektionen

1. **Aktive Kontakte** (`contact_status = 'Active'`) — Tabelle, default expanded
2. **Inaktive Kontakte (X)** — collapsible, default collapsed

### 7.2 Tabellen-Spalten (aktive Kontakte)

| Spalte | Inhalt | Source |
|--------|--------|--------|
| Name | Nachname, Vorname + Org-Funktions-Pill (L/H/M/B/E/A/F) | `dim_candidates_profile` via `dim_account_contacts.candidate_id` |
| Position | Titel | `dim_candidates_profile.function_id` |
| Department | Abteilung | `dim_account_contacts.department` |
| Org-Funktion | Enum (linie/hr/management/board/einkauf/assistenz/fachspezialist) | `dim_account_contacts.org_function` |
| Telefon | Click-to-Call | `dim_candidates_profile.phone_*` |
| Email | Mailto-Link | `dim_candidates_profile.email_*` |
| Letzter Kontakt | Datum | `dim_account_contacts.last_reached_date` |
| Status | Active/Inactive/Left Company | `contact_status` |
| Aktionen | Drawer / Vollansicht Kandidat | — |

### 7.3 Neuen Kontakt anlegen

Drawer → Auto-Match-Suche → Match: FK setzen / Kein Match: **Hard Stop** "→ Als Kandidat anlegen".

### 7.4 Do-Not-Contact

Roter Badge + Soft-Block auf 📞/✉ (Warn-Dialog + Audit).

### 7.5 Kontakt ↔ Standort

Dropdown im Kontakt-Drawer: "An welchem Standort?" (optional).

---

## 8. TAB 4 — STANDORTE

### 8.1 Layout

Container/Cards pro Standort — kein Drawer, kein Tabellen-Layout. HQ gold-gerahmt mit "HQ"-Badge. "+ Neuer Standort" Button.

### 8.2 Felder pro Card

| Feld | Typ |
|------|-----|
| Bezeichnung | Text |
| Standort-Typ | Badge HQ / Niederlassung |
| Adresse | Strasse / PLZ / Ort / Kanton |
| Telefonnummer | Text |
| Email | Text |
| Pin-Icon | → Google Maps |

### 8.3 HQ-Logik

Hart erzwungen: max. 1 HQ pro Account. Auto-Switch beim Neusetzen + Toast-Feedback.

### 8.4 Edit-Pattern

Inline-Edit pro Feld (Klick → Input → Blur/Enter speichert).

---

## 9. TAB 5 — ORGANISATION

Zwei Subtabs in Lila `#a78bfa`:

### 9.1 Subtab 5a: Stellenplan

**Datenquelle:** `fact_account_org_positions` mit Self-FK `reports_to_position_id`.

**Felder pro Position:**
- position_title, function_id, location_id, department_name
- status: besetzt / vakant / geplant
- candidate_id (NULL bei vakant/geplant)
- linked_job_id (FK zu Tab 6)
- vacant_since, planned_for

**Visualisierung:** Indented List (Default) + optional Org-Chart-Ansicht.

### 9.2 Subtab 5b: Teamrad

Read-only Visualisierung der Persönlichkeitsprofile aller Kandidaten die im Account arbeiten (via Kontakte + Stellenplan).

Aggregiert DISC, EQ-Scores, Motivatoren über alle aktiven Kontakte + Kandidaten mit `worked_at = account_id`.

---

## 10. TAB 6 — JOBS & VAKANZEN

### 10.1 Einheitstabelle

`fact_jobs` — Lifecycle Vakanz → Job → Geschlossen.

### 10.2 Spalten

| Spalte | Source |
|--------|--------|
| Titel | `fact_jobs.title` |
| Function | `function_id` |
| Location | `location_id` |
| Status | Vakanz / Aktiv / Besetzt / Geschlossen |
| Mandat | FK wenn Arkadium-Mandat |
| Erstellt | `created_at` |

### 10.3 Entwürfe-Banner

Scraper-Fund-Vakanzen erscheinen als **amber Banner/Cards** über der Tabelle. AM muss aktivieren.

---

## 11. TAB 7 — MANDATE

### 11.1 Layout

- **Entwürfe als amber Banner** über der Tabelle (Action-Items)
- Tabelle mit Filter-Chips (Aktiv / Abgeschlossen / Abgebrochen / Alle)

### 11.2 Tabelle — Spalten

| Spalte | Source |
|--------|--------|
| Mandat-Name | `fact_mandate.mandate_name` → Link `/mandates/[id]` |
| Typ | Badge Target/Taskforce/Time |
| Status | Entwurf/Aktiv/Abgeschlossen/Abgebrochen/Abgelehnt |
| Owner AM | `mandate_owner_id` |
| Progress | typ-spezifische KPI-Kurzanzeige |
| Kickoff | `kickoff_date` |
| Pauschale / Fee | Betrag |
| Aktionen | Drawer / Vollansicht |

### 11.3 Row-Click

Klick → Drawer mit Mandats-Übersicht, Pipeline-Kacheln. "Vollansicht öffnen →" → `/mandates/[id]`.

### 11.4 Kündigungs-Flag

Gekündigte Mandate haben `🛑` Icon + Tooltip mit terminated_by + terminated_reason.

---

## 12. TAB 8 — ASSESSMENTS (NEU v0.1, erweitert v0.3)

Alle Assessment-Aufträge dieses Accounts — mandatsbezogen (via Option IX) und mandatsunabhängig.

### 12.1 Layout

**Kopfbereich:** Zwei KPI-Banner nebeneinander (Teamrad-Abdeckung + Credits-Übersicht, siehe §12.3).

**Filter-Chips unter den Bannern (v0.3):** Alle / Mandatsbezogen / Eigenständig / In Progress / Completed / **Typ (Multi-Select über `dim_assessment_types`)**.

**Tabelle:** Alle Assessment-Aufträge dieses Accounts (Spalten siehe §12.2).

### 12.2 Spalten

| Spalte | Source |
|--------|--------|
| Assessment-Name / Auftrag-ID | `fact_assessment_order.id` → Link `/assessments/[id]` |
| Kandidat(en) | Multi via `fact_assessment_order.candidate_id` (+ ggf. Multi-Person) |
| Package | `package_type` (Diagnostik / Full / Executive Summary) |
| **Credits-Mix (v0.3)** | `fact_assessment_order_credits` grouped by type (z.B. "1× MDI · 1× Relief · 1× ASSESS 5.0") |
| Mandat (wenn vorhanden) | FK Link oder "Eigenständig" |
| Status | offered / ordered / scheduled / completed (Rechnungs-State auf `fact_assessment_billing`, nicht hier) |
| Preis | `price_chf` |
| Partner | SCHEELEN / intern |
| Bestellt am | `ordered_at` |
| Aktionen | Drawer / Vollansicht |

### 12.3 KPI-Banner (v0.3)

Zweizeilige KPI-Reihe im Tab-Kopf:

**Zeile 1 — Teamrad-Abdeckung:**
> *"📊 Teamrad-Abdeckung: 12 von 47 Mitarbeitenden haben ein Assessment. [→ Teamrad ansehen]"*

Link → Tab 5 Subtab Teamrad.

**Zeile 2 — Credits-Übersicht (v0.3):**

Aggregation über alle Assessment-Aufträge dieses Accounts (Source: `fact_assessment_order_credits` WHERE `order.account_id = this.id`). Typ-Breakdown pro `dim_assessment_types`-Eintrag (MDI / Relief / ASSESS 5.0 / DISC / …) mit Progress-Bar verbraucht/offen. Total-Zeile: Gesamt-Credits · Gesamtpreis CHF · verbraucht · offen.

Beispiel (Mockup-Text):

```
🎯 Credits: MDI 3/4 · Relief 2/2 · ASSESS 5.0 1/3 · DISC 0/1
   Total: 10 Credits (CHF 24'500) · 6 verbraucht · 4 offen
```

Layout-Details (Bar-Rendering, Text-Varianten, Empty-State) siehe Interactions v0.3 TEIL 8b.

### 12.4 Empty-State

> "Noch keine Assessments für diesen Account. [+ Assessment beauftragen]"

---

## 13. TAB 9 — SCHUTZFRISTEN (NEU v0.1)

Aggregierte Übersicht aller aktiven `fact_protection_window`-Einträge zu diesem Account.

### 13.1 Matrix-Layout

| Kandidat | Vorgestellt am | Vorstellungs-Typ | Mandat | Status | Ablauf | Extended? | Aktionen |
|----------|---------------|------------------|--------|--------|--------|-----------|----------|

### 13.2 Filter

- Status: Active / Expired / Honored / Claim Pending / Paid / Alle
- Zeitraum (Ablauf)
- Extended (Ja/Nein)

### 13.3 Claim-Workflow

Wenn Scraper einen Kandidaten beim Account detektiert, der eine aktive Schutzfrist hat:
- Banner am Tab-Kopf: ⚠️ **2 Claim-Fälle ausstehend** — Kandidaten bei diesem Account angestellt, Honoraranspruch prüfen
- Klick → Liste der Cases
- Pro Case: "Info-Request senden" (Email-Template) / "Claim stellen" (→ Rechnungs-Flow) / "Abschliessen ohne Claim"

### 13.4 Auto-Extension-Timer

Cases mit `info_requested_at` gesetzt aber `info_received_at` NULL:
- Countdown-Anzeige: "Noch X Tage bis Auto-Extension auf 16 Monate"
- Nach 10 Tagen: `extended = true`, Banner "Schutzfrist verlängert"

### 13.5 Empty-State

> "Keine aktiven Schutzfristen für diesen Account."

---

## 14. TAB 10 — PROZESSE

Alle Prozesse `fact_process_core.account_id = X`.

### 14.1 Liste-Spalten

| Spalte |
|--------|
| Kandidat (Foto + Name) |
| Job / Position |
| Stage (Exposé → Platzierung) |
| Status |
| Mandat (wenn via Mandat) |
| Nächstes Interview |
| CM |
| Erstellt |

### 14.2 Filter

- Stage-Chips
- Status (Aktiv/Placed/Abgelehnt/Alle)
- Mandat-Dropdown (bei Klick aus Tab 7 → Auto-Filter auf dieses Mandat)

### 14.3 Cross-Navigation Tab 7 → Tab 10

Klick auf Stage-Kachel im Mandate-Drawer (Tab 7) → wechselt zu Tab 10 mit Filter Mandat + Stage.

---

## 15. TAB 11 — HISTORY

Analog Kandidat-History, account-spezifischer Scope `WHERE account_id = X OR kontakt.account_id = X`.

### 15.1 Unterschiede zu Kandidat-History

| Aspekt | Unterschied |
|--------|-------------|
| Scope | Alle History-Einträge zum Account + zu dessen Kontakten |
| Spalte "Kandidat" | Wer wurde kontaktiert (Name + Foto) |
| Filter | Zusätzlich "Mandat-spezifisch" und "Pre-Sales" Quick-Filter |
| Vorstellungs-Events | Prominenter Filter, Link zu Tab 9 Schutzfristen |

---

## 16. TAB 12 — DOKUMENTE

### 16.1 Kategorien (account-spezifisch)

| Kategorie | Trigger |
|-----------|---------|
| AGB | Upload triggert `agb_confirmed_at` |
| NDA | Manuell |
| Rahmenvertrag | Manuell |
| Mandatsofferte-Korrespondenz | aus Mandaten aggregiert |
| Präsentationen / Pitches | Manuell |
| Reportings (Quarterly/Yearly) | Auto-Generator |
| Assessment-Reports | aus Tab 8 aggregiert |
| Sonstiges | Manuell |

### 16.2 Layout

Analog Kandidat-Dokumente (Kategorien-Sidebar + Card-Grid).

---

## 17. TAB 13 — REMINDERS

Analog Kandidat-Reminders. Account-spezifische Verknüpfungen (zusätzlich Mandat/Kontakt optional).

### 17.1 Filter

- Status: Offen / Erledigt / Überfällig
- Typ: Account / Mandat / Kontakt / Prozess
- Mitarbeiter

---

## 18. KONDITIONALER TAB — FIRMENGRUPPE

**Nur sichtbar wenn** `account_group_id IS NOT NULL`.

### 18.1 Inhalt

- Gruppe-Name + Link zur Firmengruppen-Detailseite
- Schwestergesellschaften-Liste
- Aggregierte KPIs (Mandate gruppenweit, Umsatz, etc.)

Detail: siehe Firmengruppen-Detailmaske Schema (zu erstellen).

---

## 19. KONDITIONALER TAB — PROJEKTE (neu v0.3)

**Nur sichtbar wenn** `EXISTS(fact_projects WHERE bauherr_account_id = this.id) OR EXISTS(fact_project_company_participations WHERE account_id = this.id)`.

### 19.1 Inhalt

Aggregations-Tabelle aller Projekte, in denen der Account beteiligt ist — als Bauherr ODER via `fact_project_company_participations` (Architekt / Generalplaner / TU / GU / Fachplaner / …).

### 19.2 Filter-Chips

- Rolle: Alle / Bauherr / Architekt / Generalplaner / TU / GU / Fachplaner / Weitere (aus `fact_project_company_participations.role` Enum, kanonisch laut Projekt-Schema §13 L600)
- Status: Alle / Planung / Ausschreibung / Ausführung / Abgenommen / Abgeschlossen / Gestoppt (aus `fact_projects.status` Enum, kanonisch laut Projekt-Schema §13 L535)
- Zeitraum: Alle / Aktuell (ongoing) / Letzte 12M / Historisch

### 19.3 Tabelle — Spalten

| Spalte | Source |
|--------|--------|
| Projekt-Name | `fact_projects.project_name` → Link `/projects/[id]` |
| Bauherr (wenn nicht this.account) | `fact_projects.bauherr_account_id → dim_accounts.name` — bei Eigen-Bauherrschaft: Gold-Badge "Bauherr (wir)" |
| Rolle | abgeleitet (bauherr bei `bauherr_account_id = this.id`, sonst `fact_project_company_participations.role`) |
| Status | `fact_projects.status` — Badge |
| Zeitraum | `project_start` – `project_end` |
| Arkadium-Placements | Count aus `fact_placements.project_id` — Chip mit #Anzahl |
| BKP-Gewerk (optional) | `fact_project_company_participations.bkp_gewerk` (nur bei Nicht-Bauherr-Rollen) |
| Aktionen | Row-Click = Drawer |

### 19.4 Header Quick-Action

"🏗 Projekt verknüpfen" (Drawer 540px, nur sichtbar wenn Tab sichtbar oder via "+ Beteiligung" im Tab-Body).

Detail siehe Interactions v0.3 TEIL 14.

Analog Firmengruppe: Tab ist **read-mostly** — Aggregation, nicht primäres Projekt-Editing. Edits am Projekt über Projekt-Detailseite.

---

## 19. KEYBOARD-HINTS-BAR

**Global:**
- `1`–`9`, `0`: Tab wechseln (1–10)
- `Ctrl+K`: Suche
- `Esc`: Drawer schliessen

**Tab 1 Übersicht:** `E` Edit-Mode, `S` Save
**Tab 2 Kultur:** `G` Analyse generieren
**Tab 3 Kontakte:** `+` Kontakt hinzufügen, `F` Filter
**Tab 4 Standorte:** `+` Standort hinzufügen
**Tab 7 Mandate:** `M` neues Mandat starten
**Tab 8 Assessments:** `A` neues Assessment beauftragen
**Tab 9 Schutzfristen:** `I` Info-Request senden (bei ausgewähltem Case)
**Tab 12 Dokumente:** `U` Upload

---

## 20. RESPONSIVE-VERHALTEN

**Desktop (≥ 1280px):** Volle Darstellung, 2-col in Tab 1.

**Tablet (768–1279px):** Snapshot-Bar 2-zeilig, Sektionen 1-col.

**Mobile (< 768px):** Phase 2. Tab-Bar wird zu Dropdown.

---

## 21. BERECHTIGUNGEN (RBAC)

| Aktion | AM (Owner) | AM (andere) | Researcher | CM | Admin | Backoffice |
|--------|-----------|-------------|------------|-----|---------|-----------|
| Lesen (Übersicht, Kultur, Organisation) | ✅ | ✅ | ✅ | ✅ | ✅ | ⚠ |
| Übersicht editieren | ✅ | ⚠ | ❌ | ❌ | ✅ | ❌ |
| Kultur-Analyse generieren | ✅ | ❌ | ❌ | ❌ | ✅ | ❌ |
| Kontakte verwalten | ✅ | ⚠ | ❌ | ⚠ (Lesen) | ✅ | ❌ |
| Mandat starten | ✅ | ❌ | ❌ | ❌ | ✅ | ❌ |
| Assessment beauftragen | ✅ | ❌ | ❌ | ❌ | ✅ | ❌ |
| Schutzfrist — Info-Request / Claim | ✅ | ❌ | ❌ | ❌ | ✅ | ❌ |
| AGB bestätigen | ⚠ | ❌ | ❌ | ❌ | ✅ | ✅ |
| Blacklisten | ❌ | ❌ | ❌ | ❌ | ✅ | ❌ |
| Dokument hochladen | ✅ | ⚠ | ✅ | ⚠ | ✅ | ✅ |

---

## 22. DATENBANK-REFERENZ

### Bestehende Tabellen (bereits in v1.2 Schema)

- `dim_accounts` (Stammdaten + Flags + Scraping-Config)
- `dim_account_contacts` (Bridge zu `dim_candidates_profile`, nur account-spezifische Felder)
- `fact_account_locations` (Standorte)
- `fact_account_org_positions` (Stellenplan)
- `fact_account_culture_scores` (Kultur-Dimensionen mit AI/Manual-Flag)
- `fact_jobs` (Lifecycle Vakanz → Job)
- `fact_mandate` (siehe Mandat-Schema)
- `fact_process_core` (Prozesse)
- `fact_history` (Event-Stream)
- `fact_documents`, `fact_reminders`

### Neue Tabellen (v0.1 Schema)

```sql
-- Schutzfristen (siehe Mandat-Schema v0.1 § 14)
fact_candidate_presentation (...)
fact_protection_window (...)

-- Assessment-Aufträge (siehe Diagnostik-Konzept)
fact_assessment_order (id, account_id, candidate_id, mandate_id, package_type, price_chf, status, signed_document_id, invoice_id, partner)
fact_assessment_billing (id, assessment_order_id, billing_type, amount_chf, due_date, invoice_id, paid_at, status)
```

Vollständige Migration: `ARK_DATABASE_SCHEMA_v1_3.md` (ausstehend).

---

## 23. OFFENE SPEC-PUNKTE

| # | Punkt | Priorität |
|---|-------|-----------|
| 1 | **Interactions v0.2** mit Tab 8 Assessments + Tab 9 Schutzfristen + Claim-Workflow | P0 (unmittelbar) |
| 2 | Mockup-HTMLs für alle 13 Tabs | P1 |
| 3 | Firmengruppen-Detailmaske Schema (konditionaler Tab referenziert) | P1 |
| 4 | Teamrad-Visualisierung Details (Subtab 5b) | P1 |
| 5 | Auto-Match-Algorithmus Kontakte → Kandidat dokumentieren | P1 |
| 6 | Scraper-Integration Stellenplan (Phase 2) | P2 |
| 7 | Geocoding-Strategie Standorte (Phase 1.5) | P2 |
| 8 | Diff-Ansicht Kultur-Analyse-Versionen | Phase 2 |

---

## 24. RELATED SPECS / WIKI

- `ARK_ACCOUNT_DETAILMASKE_INTERACTIONS_v0_3.md` — Verhalten, Flows (v0.2 ausstehend)
- `ARK_MANDAT_DETAILMASKE_SCHEMA_v0_2.md` — Konsistenz-Referenz
- `ARK_KANDIDATENMASKE_SCHEMA_v1_3.md` — Style-Referenz
- [[account]], [[kontakt-kandidat-regel]], [[temperatur-modell]]
- [[mandat]], [[diagnostik-assessment]], [[direkteinstellung-schutzfrist]]
- [[detailseiten-guideline]]
