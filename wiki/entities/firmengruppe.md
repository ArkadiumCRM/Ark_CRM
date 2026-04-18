---
title: "Firmengruppe"
type: entity
created: 2026-04-08
updated: 2026-04-16
sources: ["ARK_FIRMENGRUPPE_DETAILMASKE_SCHEMA_v0_1.md", "ARK_FIRMENGRUPPE_DETAILMASKE_INTERACTIONS_v0_1.md", "ARK_GESAMTSYSTEM_UEBERSICHT_v1_2.md", "ARK_DATABASE_SCHEMA_v1_2.md"]
tags: [entity, firmengruppe, account, konzern, taskforce, gruppen-schutzfrist]
---

# Firmengruppe

Konzernstrukturen — Zusammenfassung mehrerer [[account|Accounts]] unter einem Holding-Dach.

**Hierarchie-Tiefe**: 2-stufig flach (Gruppe → Gesellschaften). Keine Sub-Gruppen / Zwischenholdings (Entscheid 2026-04-13).

---

## Tabellen (DB)

```sql
dim_firmengruppen
  id uuid PK
  tenant_id FK
  group_name VARCHAR NOT NULL
  group_legal_name VARCHAR
  website_url VARCHAR
  holding_uid VARCHAR            -- CH-Handelsregister-Nr
  headquarters_city VARCHAR
  headquarters_canton VARCHAR
  founded_year INT
  strategic_notes TEXT
  structure_notes TEXT
  primary_lead_candidate_id FK
  customer_class ENUM('A','B','C')  -- gruppenweit aggregiert
  suggested_by_scraper BOOLEAN
  confirmed_by FK NULL
  confirmed_at TIMESTAMP NULL

dim_accounts.group_id FK NULL → dim_firmengruppen

bridge_mandate_accounts            -- für gruppenübergreifende Taskforces
  mandate_id FK NOT NULL
  account_id FK NOT NULL
  is_primary BOOLEAN               -- führende Gesellschaft
  UNIQUE(mandate_id, account_id)

fact_mandate.group_id FK NULL       -- bei Taskforce gesetzt + bridge-Einträge
fact_protection_window.scope ENUM('account','group') + group_id FK NULL
fact_account_culture_scores.target_type ENUM('account','group') + group_id FK
```

---

## Frontend · Detailmaske

**Route**: `/company-groups/[id]` · Mockup: `mockups/groups.html`

**7 Tabs** (v0.1 Spec-Basis + Parity-Erweiterung):

1. **Übersicht** — Gruppen-Stammdaten, Gesellschaften-Liste (+/− Actions), Aggregierte Verteilung (Sparten-Bars), Metadaten
2. **Kultur (Gruppen-Analyse)** — 6 Sektionen (Vision/Mission, Führung & Strategie, Kulturprofil 6-Dim, Fit-Score Holding, **Quellen & Vertrauen**, Gesellschafts-Kultur-Vergleich)
3. **Kontakte** — Top-Sektion „Gruppen-weite Entscheider" (VR-Board + Executive) + Full-Tabelle aller Kontakte mit **Gesellschafts-Spalte** (read-only, Pflege auf Account-Ebene)
4. **Mandate & Prozesse** — Filter-Bar · **Gruppenübergreifende Taskforces** (via bridge_mandate_accounts) · Account-spezifische Mandate · Prozesse gruppenweit
5. **Dokumente** — 6 **Group-Profile-Kategorien** (Rahmenvertrag, Master-NDA, Konzern-AGB, Gruppen-Präsentation, Holdings-Geschäftsbericht, Sonstiges) mit **Gültigkeitsbereich** (ganze Gruppe vs. Subset)
6. **History** — Mix-Strategie: Gruppen-Events (🏛 gold-Border) + aggregierte Account-Events · Scope-Filter · Gesellschafts-Multi-Select
7. **Reminders** — Gruppen-spezifische Typen (Rahmenvertrag-Review, Jahres-Report, Gruppen-Mandats-Opportunity, Scraper-Group-Match, Kultur-Update)

---

## Header-Spezialitäten

- **🏛 Holding-Badge** direkt neben Gruppen-Namen
- **Aggregierte Customer-Class-Pill** (A/B/C auf Gruppen-Ebene)
- **Snapshot-Bar sticky** (6 Slots, dupe-frei zum Header): Gesellschaften · Mitarbeitende · Umsatz · Aktive Prozesse · Placements YTD · Arkadium-Umsatz YTD
- **Scraper-Vorschlag-Banner** (amber, konditional, dismissible) bei `suggested_by_scraper=true`
- **Quick-Action „📄 Gruppen-Report"** (PDF mit aggregierten KPIs)
- **Audit-Trail-Footer** („bestätigt durch PW · 12.03.2024")

---

## Erstellung (2 Flows)

### 1. Scraper-Vorschlag

1. Scraper erkennt Konzernstruktur via CH-Handelsregister-UID-Match
2. `dim_firmengruppen` wird mit `suggested_by_scraper=true` angelegt
3. Amber-Banner in der Detailmaske
4. AM/Admin bestätigt (`confirmed_by`, `confirmed_at`) oder lehnt ab
5. Bei Bestätigung: Accounts bekommen `group_id`, bestehende Vorstellungen rückwirkend mit `scope='group'`-Schutzfristen versehen

### 2. Manuell

1. Admin legt Gruppe an
2. "+ Gesellschaft hinzufügen" → Account-Autocomplete → `dim_accounts.group_id = <id>`
3. Rückwirkung: Bestehende Vorstellungen ergänzen gruppenweite Schutzfrist-Einträge

---

## Gruppenübergreifende Taskforces

**Nur Taskforce-Typ** kann mehrere Gesellschaften abdecken (entschieden 2026-04-13).

Struktur:
- `fact_mandate.group_id` gesetzt
- N Einträge in `bridge_mandate_accounts`
- `is_primary=true` für genau eine Gesellschaft (führend)
- Stellenbriefings pro Gesellschaft möglich

Beispiel: „Taskforce PL Hochbau" — führend Bauherr Muster AG, beteiligt Muster Immobilien AG, 3 Positionen.

---

## Schutzfrist gruppenweit (KRITISCH · FG-10)

Jede Vorstellung an einen Account in einer Gruppe erzeugt **zwei** `fact_protection_window`-Einträge:

| Scope | Zweck |
|---|---|
| `account` | AM-Sicht, traditionelles Schutzfrist-Tracking |
| `group` + `group_id` | **Rechtlich relevant** — gilt für Vorstellung an ANY Gesellschaft der Gruppe |

Scraper-Match bei Job-Wechsel prüft BEIDE Scopes. Group-Level-Treffer zeigt Claim in Firmengruppe-Tab 4 + Account-Tab 9 mit Label „Gruppen-Schutzfrist".

**Impact**: Account-Interactions v0.3 muss dies berücksichtigen (siehe [[detailseiten-nachbearbeitung]]).

---

## Gruppen-Events (11 Typen)

Alle in `fact_history` mit `scope='group'`:

- `group_created_manual` · `group_suggested_by_scraper` · `group_confirmed` · `group_rejected`
- `group_member_added` · `group_member_removed`
- `group_culture_generated` · `group_framework_contract_added` · `group_report_generated`
- `group_mandate_created` (Taskforce) · `group_protection_window_opened`

---

## Dokumente-Kategorien (Group-Profile)

Siehe [[dokumente-kategorien]] §3. 6 Kategorien: Rahmenvertrag · Master-NDA · Konzern-AGB · Gruppen-Präsentation · Holdings-Geschäftsbericht · Sonstiges. Plus **Gültigkeitsbereich** (ganze Gruppe vs. Subset).

---

## Reminder-Typen (Gruppen-spezifisch)

- **Rahmenvertrag-Review** (jährlich wiederkehrend)
- **Jahres-Report** (Q2-finalisierung)
- **Gruppen-Mandats-Opportunity** (Follow-up mit CEO Holding)
- **Scraper-Group-Match** (Nachprüfung nach Scraper-Run)
- **Kultur-Update** (nach Geschäftsbericht-Publikation)
- **Follow-up** (generisch)
- **Custom**

---

## Berechtigungen (RBAC)

| Aktion | AM (Gruppen-Mitglied) | AM (andere) | Admin | Researcher |
|---|---|---|---|---|
| Lesen | ✅ | ✅ | ✅ | ✅ |
| Stammdaten editieren | ⚠ (nur Hauptmitglied) | ❌ | ✅ | ❌ |
| Gesellschaft +/− | ⚠ | ❌ | ✅ | ❌ |
| Kultur generieren | ❌ | ❌ | ✅ | ❌ |
| Taskforce-Mandat starten | ❌ | ❌ | ✅ | ❌ |
| Gruppen-Report generieren | ✅ | ✅ | ✅ | ❌ |

---

## Status Mockup (2026-04-16)

✅ **Komplett** — alle Phasen A–D abgeschlossen:
- Phase A: Parity (drawer-backdrop, uploadDrawer, historyDrawer, reminderDrawer, Tab 7 Reminders)
- Phase B: Design-System-Cleanup (kpi-strip canonical, chip-classes)
- Phase C: Spec-Features (Tab 2 Quellen, Tab 4 Filter, Tab 5 Group-Profile-Kategorien, Tab 6 Mix-Strategie + Scope-Filter)
- Phase D: Header-Specials (Snapshot-Bar, Scraper-Banner, Holding-Badge, Gruppen-Report-Button, Audit-Trail)

---

## Related

- [[account]] · [[mandat]]
- [[direkteinstellung-schutzfrist]] — Gruppen-Scope-Regeln
- [[dokumente-kategorien]] — Group-Profile
- [[design-system]] — Canonical UI-Conventions
- `specs/ARK_FIRMENGRUPPE_DETAILMASKE_SCHEMA_v0_1.md`
- `specs/ARK_FIRMENGRUPPE_DETAILMASKE_INTERACTIONS_v0_1.md`
- `mockups/groups.html`
