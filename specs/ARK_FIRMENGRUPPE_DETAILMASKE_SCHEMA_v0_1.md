# ARK CRM — Firmengruppe-Detailmaske Schema v0.1

**Stand:** 13.04.2026
**Status:** Erstentwurf — Review ausstehend
**Quellen:** ARK_DATABASE_SCHEMA_v1_3.md, ARK_ACCOUNT_DETAILMASKE_INTERACTIONS_v0_3.md (konditionaler Tab Firmengruppe), ARK_MANDAT_DETAILMASKE_SCHEMA_v0_2.md, Wiki [[firmengruppe]], Entscheidungen 2026-04-13
**Begleitdokument:** `ARK_FIRMENGRUPPE_DETAILMASKE_INTERACTIONS_v0_1.md`
**Vorrang:** Stammdaten > dieses Schema > Frontend Freeze > Mockups

---

## 0. ZIELBILD

Vollseite `/company-groups/[id]` — Aggregations-Dashboard für Konzernstrukturen und Holdings. Bindet mehrere [[account]]s einer Gruppe zusammen und ermöglicht gruppenübergreifende Mandate (Taskforce-Ebene).

**Hierarchie-Tiefe:** 2-stufig flach — Gruppe → Gesellschaften. Keine Sub-Gruppen / Zwischenholdings (entschieden 2026-04-13). Sichtbar wird lediglich welche Firmen zusammengehören.

**Primäre Nutzer:**
- AM (aller beteiligten Gesellschaften): Lesen + strategisches Oversight
- Admin: Gruppen-Strategie, gruppenübergreifende Mandate, Konzern-Kultur-Analyse
- Researcher: Schutzfrist-Matrix gruppenweit bei Sourcing

---

## 1. DESIGNSYSTEM-REFERENZ

Erbt aus [[kandidatenmaske-schema]] § 0. Firmengruppen-spezifisch:

### Farb-Tokens

| Token | Hex | Verwendung |
|-------|-----|-----------|
| Gruppe-Primär | Gold `#dcb479` | Gruppen-Badge |
| Gruppe-Sekundär | Dunkelblau `#1b3051` | Aggregations-Panels |
| Holding-Banner | Teal-dim | Header-Highlight |

### Mockup-Dateien (zu erstellen)

| # | Tab | Datei (geplant) |
|---|-----|-----------------|
| 1 | Übersicht | `firmengruppe_uebersicht_v1.html` |
| 2 | Kultur | `firmengruppe_kultur_v1.html` |
| 3 | Kontakte | `firmengruppe_kontakte_v1.html` |
| 4 | Mandate & Prozesse | `firmengruppe_mandate_v1.html` |
| 5 | Dokumente | `firmengruppe_dokumente_v1.html` |
| 6 | History | `firmengruppe_history_v1.html` |

---

## 2. GESAMT-LAYOUT

```
┌──────────────────────────────────────────────────────────────────┐
│ Breadcrumb: Firmengruppen / Implenia Gruppe                       │
├──────────────────────────────────────────────────────────────────┤
│ HEADER                                                             │
│ ┌──────────────────────────────────────────────────────────────┐ │
│ │ [Logo] Implenia Gruppe   🏛 Holding   [A]                     │ │
│ │         Gruppen-Website · Sitz Zürich                          │ │
│ │                                                                  │ │
│ │ SNAPSHOT-BAR (sticky, 6 Slots)                                 │ │
│ │ 🏢Ges  👥Mitarb  💰Umsatz  📋Mandate  ⚙Prozesse  🏆Placements │ │
│ │                                                                  │ │
│ │ [📞 Anrufen] [✉ Email] [📄 Gruppen-Report] [🔔 Reminder]      │ │
│ └──────────────────────────────────────────────────────────────┘ │
│ TAB-BAR: Übersicht │ Kultur │ Kontakte │ Mandate&Proz │ Dok │ Hist│
│                                                                    │
│ TAB-CONTENT                                                        │
│ KEYBOARD-HINTS-BAR                                                 │
└──────────────────────────────────────────────────────────────────┘
```

---

## 3. BREADCRUMB

```
Firmengruppen / [Gruppen-Name]        🔍 Ctrl+K  [Avatar]
```

2-stufig. Alternative Einstiege (Referrer-basiert):
- `Accounts / [Account] / Firmengruppe` (vom konditionalen Tab)

---

## 4. HEADER

### 4.1 Titel-Zeile

| Element | Inhalt | Interaktion |
|---------|--------|-------------|
| Logo | Holding-Logo (Scraper-Auto oder manueller Upload) | Klick → Gruppen-Website |
| Gruppen-Name | `dim_firmengruppen.group_name` (32px, fett) | Inline-Edit |
| Holding-Badge | `🏛 Holding` | Read-only |
| Aggregiertes Customer Class Pill | A/B/C (höchste Klasse der Mitglieder, oder manuell setzbar) | Inline-Edit |

### 4.2 Meta-Zeile

| Element | Inhalt |
|---------|--------|
| Gruppen-Website | URL (Holding-Website) |
| Sitz | Hauptsitz der Holding |
| Anzahl Gesellschaften | Compute |
| Primärer Ansprechpartner (Group-Lead) | Kandidat-Link |

### 4.3 Snapshot-Bar (sticky `top:0, z-index:50`, 6 Slots, **harmonisiert 2026-04-16**)

Canonical: `.snapshot-bar` + `.snapshot-item` — siehe `wiki/concepts/design-system.md` §3.2b. Keine Dupes zum Header (Rahmenvertrag-Chip, Offene-Mandate-Chip, Schutzfrist-Chip stehen oben als banner-chips).

| Slot | Inhalt | Source |
|------|--------|--------|
| 1 | 🏢 Gesellschaften | `COUNT(dim_accounts WHERE group_id = X)` |
| 2 | 👥 Mitarbeitende (Total) | `SUM(dim_accounts.employee_count WHERE group_id = X)` |
| 3 | 💰 Umsatz (Total) | `SUM(revenue_last_year_chf WHERE group_id = X)` |
| 4 | ⚙ Aktive Prozesse | `COUNT(fact_process_core WHERE any_account_of_group AND status='Open')` |
| 5 | 🏆 Placements YTD | `COUNT(fact_process_core WHERE any_account_of_group AND status='Placed' AND placement_year = CURRENT_YEAR)` |
| 6 | 💰 Arkadium-Umsatz YTD | `SUM(fact_invoice.amount WHERE group_id = X AND year = CURRENT_YEAR)` |

**Dropped** (war Slot 4 in v0.1, jetzt als Chip im banner-chips): ~~📋 Offene Mandate~~ → Chip „N offene Mandate".

### 4.4 Quick Actions

| Button | Aktion |
|--------|--------|
| 📞 Anrufen | Popover mit allen Decision Makern der ganzen Gruppe (gruppiert nach Gesellschaft) |
| ✉ Email | Email-Composer mit Gruppen-Kontext |
| 📄 Gruppen-Report | PDF mit aggregierten KPIs, Mandaten, Placements, Kulturübersicht |
| 🔔 Reminder | Quick-Popover |

### 4.5 Tab-Bar

6 Tabs:
```
│ Übersicht │ Kultur │ Kontakte │ Mandate & Prozesse │ Dokumente │ History │
```

Keyboard: `1`–`6`.

---

## 5. TAB 1 — ÜBERSICHT

### 5.1 Sektionen

#### Sektion 1 — Gruppen-Stammdaten

| Feld | Typ | DB |
|------|-----|-----|
| `group_name` | Text | `dim_firmengruppen.group_name` |
| `group_legal_name` | Text | `group_legal_name` |
| `group_website_url` | URL | `website_url` |
| `holding_uid` | Text (CH-Handelsregister-Nr. Holding) | `holding_uid` |
| `holding_sitz` | Text (Stadt, Kanton) | `headquarters_city`, `headquarters_canton` |
| `founded_year` | Int | `founded_year` |
| Strategie-Notizen | Textarea | `strategic_notes` |
| Konzern-Struktur-Notizen | Textarea | `structure_notes` |
| Primärer Group-Lead | Kandidat-FK (Decision Maker der Holding) | `primary_lead_candidate_id` |

#### Sektion 2 — Gesellschaften-Liste

**Tabelle** mit allen `dim_accounts.group_id = X`:

| Spalte | Inhalt |
|--------|--------|
| Logo + Name | Link zu `/accounts/[id]` |
| Customer Class | A/B/C |
| Status | Active / Prospect / Inactive / Blacklisted |
| AM | Owner-AM Initialen |
| Mitarbeitende | `employee_count` |
| Umsatz | `revenue_last_year_chf` |
| Offene Mandate | Count |
| Aktive Prozesse | Count |
| Aktionen | Drawer-Preview / Vollansicht |

**Actions:**
- **"+ Gesellschaft hinzufügen"** → Account-Suche → Account bekommt `group_id = X`
- **"− Entfernen"** pro Zeile → Confirm "Account aus Gruppe entfernen?" (Account bleibt, nur Group-Assignment weg)

#### Sektion 3 — Aggregierte KPIs

Dashboard-Sektion mit:
- Sparte-Verteilung (Pie-Chart über alle Gesellschaften)
- Customer-Class-Verteilung (A/B/C Breakdown)
- Temperatur-Verteilung (Hot/Warm/Cold)
- Penetration-Score (Durchschnitt)

#### Sektion 4 — Zugehörigkeits-Metadaten

| Feld | Typ |
|------|-----|
| Erstellt am | `created_at` |
| Erstellt durch | `created_by` |
| Scraper-vorgeschlagen? | Badge falls `suggested_by_scraper = true` |
| Bestätigt durch AM | `confirmed_by`, `confirmed_at` |

---

## 6. TAB 2 — KULTUR (GRUPPEN-ANALYSE)

Eigene Kultur-Analyse auf Holding-Ebene (analog Account-Kultur Tab 2). AI-generiert aus aggregierten Quellen.

### 6.1 Sektionen

Struktur identisch zu Account-Tab 2:

| # | Sektion | Inhalt |
|---|---------|--------|
| 1 | Vision · Mission · Purpose | Holding-Werte |
| 2 | Führung & Strategie | Konzernstrategie, Transformationsreife |
| 3 | Kulturprofil — Arkadium Analyse | 6 Score-Dimensionen (analog Account) |
| 4 | Kulturfit-Score | Gesamt-Score 0–100 auf Konzern-Ebene |
| 5 | Quellen & Vertrauen | Datenquellen (Geschäftsberichte, Holding-News, aggregierte Gesellschafts-Analysen) |
| 6 | Gesellschafts-Kultur-Vergleich | Read-only Tabelle: Gesellschaft vs. 6 Scores nebeneinander |

### 6.2 Workflow

Analog Account — AI-Draft mit Sektions-Bestätigung. Quellen spezifisch:
- Holding-Website
- Geschäftsberichte der Holding
- Aggregierte News-Recherche
- Kultur-Scores aller Gesellschaften (als Referenz, nicht Durchschnitt)

---

## 7. TAB 3 — KONTAKTE (GRUPPEN-AGGREGIERT)

Alle Kontakte aller Gesellschaften der Gruppe in einer Tabelle.

### 7.1 Layout

**Tabelle** mit Filter-Bar.

### 7.2 Spalten

| Spalte | Inhalt |
|--------|--------|
| Name | Nachname, Vorname + Pills (Champion/Blocker/DM/KC) |
| **Gesellschaft** | Link zum Account (NEU Spalte gegenüber Account-Kontakte) |
| Position | Department / Titel |
| Decision Level | Enum |
| Telefon | Click-to-Call |
| Email | Mailto |
| Status | Active / Inactive / Left Company |

### 7.3 Filter

- Gesellschaft (Multi-Select Chips)
- Decision Level
- Role-Pills (Decision Maker / Key Contact / Champion / Blocker)
- Status
- Freitext

### 7.4 Gruppen-weite Decision Maker

**Top-Sektion** oben: "Gruppen-weite Entscheider" — alle Kontakte mit `org_function IN ('vr_board','executive')`, sortiert: VR-Board vor Executive.

### 7.5 Read-Only

Kontakt-Pflege geschieht auf **Account-Ebene** (Account Tab 3). Hier nur Übersicht. Klick auf Kontakt → Account-Kontakt-Drawer in neuem Tab.

---

## 8. TAB 4 — MANDATE & PROZESSE

Aggregierte Pipeline über alle Gesellschaften + gruppenübergreifende Taskforces.

### 8.1 Sub-Section: Gruppenübergreifende Mandate

**Separater Bereich oben** für Mandate die via `bridge_mandate_accounts` mit mehreren Accounts der Gruppe verknüpft sind (siehe FG-11, N:N).

| Spalte | Inhalt |
|--------|--------|
| Mandat-Name | Link |
| Typ | Taskforce (nur dieser Typ kann gruppenübergreifend sein) |
| Beteiligte Gesellschaften | Multi-Chips |
| Status | Aktiv/Abgeschlossen/Abgebrochen |
| Owner AM | Initialen |
| KPIs | Compact |

### 8.2 Sub-Section: Account-spezifische Mandate

Alle Mandate `WHERE account_id IN (gruppe.gesellschaften)`:

| Spalte | Inhalt |
|--------|--------|
| Gesellschaft | Account-Link |
| Mandat | Link |
| Typ | Badge |
| Status | |
| Owner AM | |
| KPIs | |

### 8.3 Sub-Section: Prozesse

Alle Prozesse `WHERE account_id IN (gruppe.gesellschaften)`:

| Spalte | Inhalt |
|--------|--------|
| Kandidat | |
| Gesellschaft | Account-Link |
| Stage | |
| Status | |
| CM | |

### 8.4 Aggregierte Placement-Statistik

KPI-Banner oben:
```
Gruppenweit: 12 Placements (2026) · 3 offene Mandate · 8 aktive Prozesse · Durchschn. TTF: 14 Wochen
```

### 8.5 Filter

- Gesellschaft
- Status
- Zeitraum
- Mandat-Typ

---

## 9. TAB 5 — DOKUMENTE (GRUPPEN-EBENE)

Gruppen-weite Verträge und Master-Dokumente.

### 9.1 Kategorien

| Kategorie | Zweck |
|-----------|-------|
| Rahmenvertrag | Konzern-weiter Vermittlungsvertrag |
| Master-NDA | Gruppen-weite Geheimhaltung |
| Konzern-AGB | Abweichende AGB auf Gruppen-Ebene |
| Gruppen-Präsentationen | Strategische Unterlagen |
| Holdings-Geschäftsberichte | PDFs der Holding |
| Sonstiges | Manuell |

### 9.2 Layout

Card-Grid analog andere Dokumente-Tabs.

### 9.3 Gültigkeit

Dokumente können einen **Gültigkeitsbereich** haben:
- "Gilt für ganze Gruppe" (Default)
- "Gilt nur für X, Y, Z der Gruppe" (Multi-Select Subset)

---

## 10. TAB 6 — HISTORY

### 10.1 Scope (Mix-Strategie)

- **Gruppen-Level Events** (immer):
  - `group_created`, `group_suggested_by_scraper`, `group_confirmed`
  - Gesellschaft hinzugefügt / entfernt
  - Gruppen-Kultur-Analyse generiert
  - Gruppen-Dokument hochgeladen
  - Gruppenübergreifendes Mandat erstellt
- **Wichtige aggregierte Account-Events** (automatisch gefiltert als "relevant"):
  - Placements (alle Gesellschaften)
  - Mandats-Abschlüsse
  - Mandats-Kündigungen
  - Kultur-Update einer Gesellschaft
  - Kritische Status-Wechsel (z.B. Blacklisting)

### 10.2 Filter

- Event-Scope (Gruppe vs. Gesellschaft)
- Gesellschaft (Multi-Select)
- Event-Typ
- Zeitraum

---

## 11. KEYBOARD-HINTS-BAR

**Global:** `1`–`6` Tab · `Ctrl+K` Suche · `Esc`

**Tab 1 Übersicht:** `E` Edit · `+` Gesellschaft hinzufügen

**Tab 2 Kultur:** `G` Analyse generieren

**Tab 3 Kontakte:** `F` Filter

**Tab 4 Mandate & Prozesse:** `M` Neues Gruppen-Mandat (Taskforce)

**Tab 5 Dokumente:** `U` Upload

---

## 12. RESPONSIVE

**Desktop (≥ 1280px):** 2-col Tab 1, Dashboard-Sektionen.
**Tablet (768–1279px):** Snapshot-Bar 2-zeilig.
**Mobile (< 768px):** Phase 2.

---

## 13. BERECHTIGUNGEN (RBAC)

| Aktion | AM (einer der Gesellschaften) | AM (andere) | Admin | Researcher | Backoffice |
|--------|--------------------------------|-------------|---------|-----------|-----------|
| Lesen (alle Tabs) | ✅ | ✅ | ✅ | ✅ | Tab 4 + 5 |
| Gruppen-Stammdaten editieren | ⚠ (nur wenn eigene Gesellschaft Hauptmitglied) | ❌ | ✅ | ❌ | ❌ |
| Gesellschaft hinzufügen / entfernen | ⚠ | ❌ | ✅ | ❌ | ❌ |
| Gruppen-Kultur generieren | ❌ | ❌ | ✅ | ❌ | ❌ |
| Gruppen-Dokument hochladen | ⚠ | ❌ | ✅ | ❌ | ✅ |
| Gruppenübergreifendes Mandat starten | ❌ | ❌ | ✅ | ❌ | ❌ |
| Gruppen-Report generieren | ✅ | ✅ | ✅ | ❌ | ✅ |

---

## 14. DATENBANK-REFERENZ

### Bestehende / erweiterte Tabellen

```sql
dim_firmengruppen (neu, falls noch nicht existiert):
  id uuid PK,
  tenant_id FK,
  group_name VARCHAR NOT NULL,
  group_legal_name VARCHAR,
  website_url VARCHAR,
  holding_uid VARCHAR,
  headquarters_city VARCHAR,
  headquarters_canton VARCHAR,
  founded_year INT,
  strategic_notes TEXT,
  structure_notes TEXT,
  primary_lead_candidate_id FK NULL,
  customer_class ENUM('A','B','C') NULL,   -- Gruppen-weit
  suggested_by_scraper BOOLEAN DEFAULT FALSE,
  confirmed_by FK NULL,
  confirmed_at TIMESTAMP NULL,
  created_at, updated_at

dim_accounts:
  + group_id FK NULL -> dim_firmengruppen  (bestehend, bleibt)

fact_account_culture_scores (erweitert):
  + target_type ENUM('account','group') DEFAULT 'account'
  + group_id FK NULL  (alternativ zu account_id)

bridge_mandate_accounts (neu, für gruppenübergreifende Mandate):
  id uuid PK,
  mandate_id FK NOT NULL,
  account_id FK NOT NULL,
  is_primary BOOLEAN DEFAULT FALSE,  -- welche Gesellschaft "führt"
  UNIQUE(mandate_id, account_id)

-- fact_mandate bekommt optional group_id:
fact_mandate:
  + group_id FK NULL -> dim_firmengruppen
  -- Verwendung: wenn gruppenübergreifend → group_id gesetzt + bridge_mandate_accounts Einträge
  -- Account-spezifisch → group_id NULL, account_id gesetzt wie bisher

fact_protection_window:
  + scope ENUM('account','group') DEFAULT 'account'
  + group_id FK NULL  (alternativ zu account_id)
  -- KRITISCH (FG-10): Schutzfrist gilt gruppenweit → starts_at gilt
  -- für Vorstellung an IRGEND eine Gesellschaft der Gruppe

fact_group_events (oder fact_history mit scope):
  -- Events auf Gruppen-Ebene wie auf Account-Ebene
```

### Impact auf bestehende Logik

**Schutzfrist-Matching (FG-10, kritisch):**
- Bei Insert eines `fact_candidate_presentation`: wenn `dim_accounts.group_id` gesetzt → zusätzlich `fact_protection_window` mit `scope='group'` und `group_id` erstellen
- Bei Scraper-Detection "Kandidat bei neuem Account" → Match-Query prüft BEIDE Scopes (account + group)
- Account-Tab 9 Schutzfristen zeigt auch die `scope='group'` Einträge, die über diesen Account laufen

**Diese Änderung ist Nachbearbeitungs-Punkt** für Account-Interactions v0.3 (siehe `detailseiten-nachbearbeitung.md`).

---

## 15. OFFENE SPEC-PUNKTE

| # | Punkt | Priorität |
|---|-------|-----------|
| 1 | Interactions-Spec v0.1 (direkt folgend) | P0 |
| 2 | Mockup-HTMLs für 6 Tabs | P1 |
| 3 | Scraper-Vorschlag-Algorithmus für Gruppen (UID-Basiert) | P1 |
| 4 | Nachbearbeitung: Schutzfrist gruppenweit in Account-Spec v0.3 | P1 |
| 5 | Gruppen-Report PDF-Template | P1 |

---

## 16. RELATED SPECS / WIKI

- `ARK_FIRMENGRUPPE_DETAILMASKE_INTERACTIONS_v0_1.md`
- `ARK_ACCOUNT_DETAILMASKE_SCHEMA_v0_2.md` (konditionaler Tab Firmengruppe)
- `ARK_MANDAT_DETAILMASKE_SCHEMA_v0_2.md` (gruppenübergreifende Taskforce-Mandate)
- [[firmengruppe]], [[account]], [[direkteinstellung-schutzfrist]]
- [[detailseiten-guideline]], [[detailseiten-nachbearbeitung]]
