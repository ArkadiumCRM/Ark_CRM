---
title: "HR · Vertragswerk (Arkadium-Anstellungs-Stack)"
type: concept
created: 2026-04-19
updated: 2026-04-19
sources: [
  "hr-arbeitsvertraege.md",
  "hr-reglemente.md",
  "hr-provisionsvertraege.md",
  "hr-stellenbeschreibung-progressus.md"
]
tags: [hr, phase-3, vertragswerk, meta-concept, lateinische-marken, vertragsbestandteile]
---

# HR · Arkadium-Vertragswerk — Das Anstellungs-Stack

Arkadium nutzt ein mehrschichtiges Vertragswerk mit lateinischen Eigennamen. Der Arbeitsvertrag ist **Hauptvertrag**, alle anderen Dokumente sind **integrale Vertragsbestandteile** und werden jedem MA einzeln übergeben + signiert.

## Das 5-Schicht-Modell

```
┌─────────────────────────────────────────────────────────────┐
│  ARBEITSVERTRAG (Hauptvertrag, jahresunabhängig stabil)     │
│  → Widerspruchs-Regel: geht allen Reglementen vor           │
└─────────────────────────────────────────────────────────────┘
         │
         ├──► Reglement "Generalis Provisio"
         │        → Allgemeine Anstellungsbedingungen (DSG, Lohn, Krankheit, Academy)
         │
         ├──► Reglement "Tempus Passio 365"
         │        → Arbeitszeit, Ferien, Feiertage, Extra-Guthaben
         │
         ├──► Reglement "Locus Extra"
         │        → Mobiles Arbeiten (Home-Office + Remote Work)
         │
         ├──► Beschreibungen "Progressus"
         │        → Stellen- + Kompetenzbeschreibung pro MA-Typ
         │
         └──► Vertrag "Praemium Victoria"
                  → Provisionsvertrag (jährlich neu · ZEG-Staffel · Budget-Ziel)
```

## Warum lateinische Marken?

Arkadium-Corporate-Style — Reglemente haben merkfähige Eigennamen statt technischer Bezeichnungen. Übersetzung:

| Lateinischer Name | Bedeutung | Zweck |
|-------------------|-----------|-------|
| **Generalis Provisio** | "Allgemeine Vorsorge" | Allgemeine Anstellungsbedingungen |
| **Tempus Passio 365** | "Zeit-Hingabe 365" | Arbeitszeitreglement (365-Tage-Ansatz) |
| **Locus Extra** | "Ort ausserhalb" | Mobiles Arbeiten |
| **Progressus** | "Fortschritt" | Stellen-/Kompetenzbeschreibung (Karriere-Pfad) |
| **Praemium Victoria** | "Preis des Sieges" | Provisionsvertrag (erfolgsabhängig) |

## Vertrags-Hierarchie + Konfliktregeln

1. **Arbeitsvertrag ist oberste Instanz** — bei Widerspruch gewinnt Arbeitsvertrag gegen jedes Reglement
2. **Reglemente sind gleichrangig** untereinander
3. **OR ist Fallback** — was keine explizite Regelung hat, folgt OR
4. **Zwingendes Recht** überschreibt alles (Art. 328 OR Persönlichkeitsschutz, Arbeitsgesetz, DSG, Art. 340 OR Konkurrenzverbot-Maxima)

## Zeitliche Ebenen

| Schicht | Gültigkeit | Änderungsrhythmus |
|---------|------------|-------------------|
| Arbeitsvertrag | Unbefristet (oder Termin) | Nur bei Rollenwechsel / Beförderung / Pensum |
| Generalis Provisio | ab 1.1.2024 | Jährlich prüfen · Änderung mit 1-Mt-Ankündigung |
| Tempus Passio 365 | ab 1.1.2024 | Jährlich (Feiertage, Extra-Guthaben) |
| Locus Extra | ab 1.1.2024 | Ad-hoc (nach HR-Bedarf) |
| Progressus | Stand-Datum | Pro MA-Typ · bei Rollen-Redesign |
| Praemium Victoria | **Jährlich** (Kalenderjahr oder Geschäftsjahr) | Jährlich neu · Budget-Ziel-abhängig |

## Tech-Mapping für HR-Tool

Plan v0.1 §6.2 hat `fact_employment_contracts` als zentrale Tabelle. Das Vertragswerk verlangt **mehrere gekoppelte Tabellen**:

```sql
-- 1. Hauptvertrag (Plan §6.2, minimale Erweiterung):
--    Bereits: id, mitarbeiter_id, contract_type, valid_from/until, pensum,
--             hours_per_week, jobtitel, probezeit, kuendigungsfrist
--    NEU (aus Arkadium-Analyse):
ALTER TABLE fact_employment_contracts ADD COLUMN IF NOT EXISTS
  karenzentschaedigung_chf_mt NUMERIC(8,2),
  job_description_id UUID REFERENCES dim_job_descriptions(id),    -- Progressus-Link
  konkurrenzverbot_konventionalstrafe_chf NUMERIC(10,2) DEFAULT 80000,
  abwerbeverbot_konventionalstrafe_chf NUMERIC(10,2) DEFAULT 80000,
  konkurrenzverbot_region TEXT DEFAULT 'Deutschschweiz';

-- 2. Vertrags-Anhänge (neue Tabelle):
CREATE TABLE fact_contract_attachments (
  id UUID PRIMARY KEY,
  contract_id UUID REFERENCES fact_employment_contracts(id),
  attachment_type TEXT CHECK (attachment_type IN (
    'reglement_generalis_provisio',
    'reglement_tempus_passio',
    'reglement_locus_extra',
    'stellenbeschreibung_progressus',
    'provisionsvertrag_praemium_victoria',
    'weiterbildungsvereinbarung',
    'other'
  )),
  reglement_version TEXT,                  -- z.B. '2024-01-01'
  document_url TEXT,
  signed_at TIMESTAMPTZ,
  signed_by_mitarbeiter BOOLEAN DEFAULT false
);

-- 3. Reglemente als versionierte Stamm-Tabelle:
CREATE TABLE dim_reglemente (
  id UUID PRIMARY KEY,
  latin_name TEXT UNIQUE NOT NULL,            -- 'generalis_provisio', ...
  name_de TEXT NOT NULL,
  version TEXT NOT NULL,                      -- '2024-01-01'
  valid_from DATE NOT NULL,
  valid_until DATE,
  document_draft_url TEXT,                    -- ENTWURF-Variante
  document_digital_url TEXT,                  -- DIGITAL-Variante (Online-Anzeige)
  document_print_url TEXT,                    -- DRUCK-Variante (Signatur-Version, kanonisch)
  superseded_by UUID REFERENCES dim_reglemente(id),
  changelog JSONB
);

-- 4. Provisionsvertrag jährlich (neue Tabelle):
CREATE TABLE fact_provisionsvertrag_versions (
  id UUID PRIMARY KEY,
  mitarbeiter_id UUID REFERENCES dim_mitarbeiter(id),
  fiscal_year INT NOT NULL,
  valid_from DATE NOT NULL,
  valid_until DATE NOT NULL,
  role_at_contract TEXT CHECK (role_at_contract IN (
    'consultant','researcher','candidate_manager','account_manager','team_leader'
  )),
  budget_goal_chf NUMERIC(12,2) NOT NULL,
  fix_salary_year_chf NUMERIC(10,2) NOT NULL,
  variable_100pct_chf NUMERIC(10,2) NOT NULL,
  spesenpauschale_chf_mt NUMERIC(8,2) DEFAULT 300,
  zeg_staffel_id UUID REFERENCES dim_zeg_staffel(id),
  payout_advance_pct NUMERIC(5,2) DEFAULT 80.0,            -- 80/20-Split
  document_url TEXT,
  signed_at TIMESTAMPTZ,
  UNIQUE (mitarbeiter_id, fiscal_year)
);
```

## Signatur-Flow

Bei Neueintritt muss jeder Anhang einzeln signiert werden. UI-Flow:

```
Drawer: Neuer MA anlegen (760px, wide-tabs)
 ├─ Tab 1: Basis-Daten
 ├─ Tab 2: Vertrag (Hauptvertrag Felder)
 ├─ Tab 3: Anhänge-Liste (5 Reglemente/Vorlagen mit Version + Signatur-Status)
 └─ Tab 4: Review + PDF-Bundle generieren
```

Bei Signatur-Anforderung: MA bekommt E-Mail mit Link · signiert digital oder druckt/signiert physisch · Upload des signierten PDFs → `fact_contract_attachments.signed_at` gesetzt.

## Academy + Progressus — Bindegewebe

- **Progressus** definiert Funktion + Pensum + Vorgesetzter (Head-of-Department)
- **Generalis Provisio §4** verweist auf Academy-Module (Communication Edge 1-3 · M4 Modell · Lernkarteien 1&2)
- **Onboarding-Template** (Plan §5.5) sollte aus Progressus-Funktion die passenden Academy-Module ziehen

## Related

- [[hr-arbeitsvertraege]] · [[hr-reglemente]] · [[hr-provisionsvertraege]] · [[hr-stellenbeschreibung-progressus]]
- [[hr-academy]] · [[hr-ma-rollen-matrix]]
- [[hr-konkurrenz-abwerbeverbot]] · [[hr-schema-deltas-2026-04-19]]
