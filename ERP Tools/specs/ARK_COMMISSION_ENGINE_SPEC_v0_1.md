---
title: "ARK Commission-Engine · Schema & Interactions v0.1"
type: spec
phase: 1
created: 2026-04-19
updated: 2026-04-19
status: draft
supersedes_scope: "wiki/concepts/provisionierung.md §Out-of-Scope (aufgehoben 2026-04-19)"
authoritative_source: "wiki/concepts/provisionierung.md + Provisionssheets Peter/Joaquin"
grundlagen_sync_required: [
  "raw/Ark_CRM_v2/ARK_STAMMDATEN_EXPORT_v1_3.md (neue Rolle assessment_manager)",
  "raw/Ark_CRM_v2/ARK_DATABASE_SCHEMA_v1_3.md (neue Tabellen + Felder)",
  "raw/Ark_CRM_v2/ARK_BACKEND_ARCHITECTURE_v2_5.md (neue Events + Worker)",
  "raw/Ark_CRM_v2/ARK_FRONTEND_FREEZE_v1_10.md (neue Routen + UI-Pattern)",
  "raw/Ark_CRM_v2/ARK_GESAMTSYSTEM_UEBERSICHT_v1_3.md (Changelog)"
]
tags: [spec, commission, provisionierung, kern-usp, phase-1, option-d]
---

# ARK Commission-Engine · Schema & Interactions v0.1

**ARK-Killer-USP für SaaS-Phase-2.** Commission-Berechnungs-Engine als Phase-1-Kern-Modul. Deckt 3+1 Rollen (Researcher · CM · AM · Head of · Assessment Manager TBC) plus Sonder-Regelungen (Geschäftsführer · Backoffice-Bonus-Ermessen).

---

## 1. Scope & Nicht-Scope

### 1.1 In-Scope Phase 1

- **Commission-Berechnung** (ZEG-Staffel, Quartals-Kumulation, 80/20-Split)
- **3 Haupt-Modelle** (Researcher-Pauschale · CM/AM-50/50-Split · Head-of-Teambudget-Rollup)
- **Commission-Ledger** (append-only, Audit-Trail)
- **Simulations-UI** (Was-wäre-wenn · Placement hinzufügen)
- **Rücklage-Management** (20 %-Freigabe nach Garantiefrist · Claw-back bei Austritt)
- **Bonus-Ermessens-Flow** (Nicht-Prov.-Berechtigte · GF-Approval)
- **CSV/Excel/XML-Export** (provider-neutral · Treuhänder · Bexio · Abacus-kompatibel)
- **Dashboards + Reports** (MA-Self · Head-of · Backoffice-Auszahlungs-Queue)
- **Multi-Role-Priorisierung** (MA mit mehreren Rollen)

### 1.2 Out-of-Scope Phase 1

- Eigene Swissdec-Payroll (Brutto/Netto-Lohn-Berechnung)
- AHV/IV/EO/ALV/BVG/UVG-Integration
- Quellensteuer-Tarif-Engine
- Lohnausweis-Formular 11 Generierung
- Active Bexio-API-Call (CSV-Export reicht Phase 1)
- Time-Mandat-Sonderabrechnung (Business-Model `time` wird ausgeschlossen · Mechanik Phase 3)
- Multi-Tenant-Härtung (SaaS-Phase 2)

### 1.3 Peter-Klärung 2026-04-19 · 5 von 7 geklärt

| # | Frage | Antwort Peter 2026-04-19 |
|---|-------|---------------------------|
| 1 | Assessment-Manager-Modell | **Jahresziel für Assessments** · definierter Bonus-Betrag · quartalsweise Auszahlung wie CM/AM · Staffel-Detail TBC (ZEG vs. linear?) |
| 2 | Yavor Head-of-Sparten | **ARC + REM** (Architecture & Real Estate Management) |
| 3 | Stefano Head-of-Sparten | **"Market Strategy & Client Solutions"** — KEINE Sparte in STAMMDATEN · **TBC**: Teambudget-Scope muss Peter klären (Cross-Sparten · Mandats-Akquise · spezielle Kategorie) |
| 4 | Researcher-Pauschale-Algo | **CHF 500 default** · frei umstellbar 250-750 · kein Auto-Algo nach Fee |
| 5 | Bonus-Ermessen-Limit | **Kein festes Limit** · GF entscheidet · für Nicht-GF-Boni Head-of-Absprache Pflicht · GF kann sich self-approval ohne Absprache |
| 6 | Migration-Startpunkt | **TBC** — Peter klären: Excel-Daten 2025/Q1-2026 als Initial-Import ODER Start bei null? |
| 7 | Quartals-Abschluss-Freeze | **Nachträgliche Änderungen erlaubt** · mit Audit-Log · Vor-Quartals-Entries als `superseded` markieren |

**Noch offen (2 TBC)**:
- **Stefano-Teambudget-Scope** (keine Sparte · wie rollen?)
- **Migration-Rückfrage** (Excel-Import ja/nein)
- **Assessment-Manager-Staffel-Detail** (gleiche ZEG-Staffel wie CM/AM · oder eigenes lineares/binäres Modell?)

---

## 2. Datenmodell

### 2.1 Erweiterung `dim_mitarbeiter`

```sql
ALTER TABLE dim_mitarbeiter ADD COLUMN IF NOT EXISTS
  commission_primary_role TEXT CHECK (commission_primary_role IN (
    'head_of',
    'cm_am',
    'researcher',
    'assessment_manager',
    'geschaeftsfuehrer',
    'backoffice',
    'none'
  )),
  head_of_scope_type TEXT CHECK (head_of_scope_type IN (
    'sparten',                 -- Peter (CI+BT) · Yavor (ARC+REM)
    'custom_metric',           -- Stefano · Metrik-Definition ausstehend
    'cross_sparten',           -- falls später gebraucht (alle Sparten)
    'none'
  )),
  head_of_sparten TEXT[],       -- ['CI','BT'] wenn scope_type='sparten'
  head_of_scope_definition JSONB, -- z.B. {metric:'new_mandates_acquired', target:50, ...} für 'custom_metric'
  bonus_ermessen_eligible BOOLEAN DEFAULT false,
  bonus_ermessen_approver_id UUID REFERENCES dim_mitarbeiter(id);  -- GF für Sabrina/Severina-BO-Teil
```

**Beispiel-Werte**:
- Peter: `scope_type='sparten'`, `head_of_sparten=['CI','BT']`, `scope_definition=NULL`
- Yavor: `scope_type='sparten'`, `head_of_sparten=['ARC','REM']`, `scope_definition=NULL`
- Stefano: `scope_type='custom_metric'`, `head_of_sparten=NULL`, `scope_definition={"status":"pending_definition","role_title":"Market Strategy & Client Solutions"}`

### 2.2 Neue Tabellen

```sql
-- Jahres-Budget + OTE pro MA pro Jahr
CREATE TABLE dim_commission_year (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  mitarbeiter_id UUID NOT NULL REFERENCES dim_mitarbeiter(id),
  year INT NOT NULL,
  commission_role TEXT NOT NULL CHECK (commission_role IN (
    'head_of', 'cm_am', 'researcher', 'assessment_manager'
  )),
  annual_budget_chf NUMERIC(10,2),                -- Jahresziel Net-Fees · NULL für Researcher
  annual_ote_chf NUMERIC(10,2),                   -- Variables Gehalt bei 100% ZEG · NULL für Researcher
  researcher_rate_min_chf NUMERIC(8,2) DEFAULT 250,  -- Researcher-Pauschale Untergrenze
  researcher_rate_max_chf NUMERIC(8,2) DEFAULT 750,
  pro_rata_start_month INT CHECK (pro_rata_start_month BETWEEN 1 AND 12),  -- bei Eintritt
  pro_rata_end_month INT CHECK (pro_rata_end_month BETWEEN 1 AND 12),     -- bei Austritt
  effective_budget_chf NUMERIC(10,2) GENERATED ALWAYS AS (
    CASE
      WHEN pro_rata_start_month IS NULL THEN annual_budget_chf
      ELSE annual_budget_chf * (13 - pro_rata_start_month)::NUMERIC / 12
    END
  ) STORED,
  created_at TIMESTAMPTZ DEFAULT now(),
  created_by UUID REFERENCES dim_mitarbeiter(id),
  UNIQUE (mitarbeiter_id, year)
);

-- ZEG-Staffel (versionierbar, falls Regel ändert)
CREATE TABLE dim_commission_staffel (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  staffel_version TEXT NOT NULL,                   -- '2026-default'
  valid_from DATE NOT NULL,
  valid_until DATE,                                -- NULL = aktiv
  zeg_from_pct NUMERIC(5,1) NOT NULL,              -- 50.0
  zeg_to_pct NUMERIC(5,1) NOT NULL,                -- 59.0
  base_rate_pct NUMERIC(5,1) NOT NULL,             -- 10.0 bei 50% ZEG
  step_per_pct NUMERIC(5,2) NOT NULL,              -- +2.0 pro +1% ZEG
  notes TEXT,
  CHECK (zeg_from_pct <= zeg_to_pct)
);

-- Seed-Werte für 2026-default:
-- (0,49.9, 0, 0, 'unter 50% = 0')
-- (50, 59.9, 10, 2, 'Einstieg +2%/%')
-- (60, 69.9, 30, 1, 'Dämpfungs-Zone +1%/%')
-- (70, 99.9, 40, 2, 'Leistungs-Korridor +2%/%')
-- (100, 100, 100, 0, 'Zielpunkt')
-- (101, 150, 102, 2, 'Bonus-Korridor +2%/%')
-- (150.1, 999, 160, 1, 'Degression +1%/%')

-- Commission-Ledger · append-only (no UPDATEs!)
CREATE TABLE fact_commission_ledger (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  mitarbeiter_id UUID NOT NULL REFERENCES dim_mitarbeiter(id),
  period_year INT NOT NULL,
  period_quarter INT CHECK (period_quarter BETWEEN 1 AND 4),
  period_month INT CHECK (period_month BETWEEN 1 AND 12),
  calc_as_of DATE NOT NULL,                        -- Stichtag der Berechnung
  commission_role TEXT NOT NULL,
  model TEXT NOT NULL CHECK (model IN (
    'researcher_fee',      -- Pauschale pro Placement
    'cm_am_zeg',           -- CM/AM 50/50 mit ZEG-Staffel
    'head_of_teambudget',  -- Head-of-Teambudget-Rollup
    'assessment_manager',  -- TBC
    'bonus_ermessen'       -- Ermessens-Bonus (Nicht-Prov.-Berechtigte)
  )),

  -- Eingangs-Werte
  net_fees_cumulated_chf NUMERIC(10,2),            -- Σ zugeteilte Net Fees (bei CM/AM/HeadOf)
  budget_cumulated_chf NUMERIC(10,2),              -- Σ Budget kumuliert
  zeg_pct NUMERIC(6,2),                            -- Zielerreichungs-Grad
  staffel_version TEXT REFERENCES dim_commission_staffel(staffel_version),
  staffel_rate_pct NUMERIC(6,2),                   -- Provisions-Satz laut Staffel

  -- Berechnung
  commission_gross_chf NUMERIC(10,2) NOT NULL,     -- Brutto-Provision
  abschlag_chf NUMERIC(10,2),                      -- 80% Abschlag
  ruecklage_chf NUMERIC(10,2),                     -- 20% Rücklage
  ruecklage_frei_chf NUMERIC(10,2) DEFAULT 0,      -- Rücklage schon freigegeben
  ruecklage_clawback_chf NUMERIC(10,2) DEFAULT 0,  -- bei Austritt-Kandidat in Garantie

  -- Referenzen (für Audit)
  placements_included UUID[],                       -- Array of fact_process_finance.id
  guarantees_linked UUID[],                         -- Array of fact_candidate_guarantee.id
  source_snapshot JSONB,                            -- Snapshot der Input-Daten zum Berechnungs-Zeitpunkt

  -- Metadaten
  calculated_at TIMESTAMPTZ DEFAULT now(),
  calculated_by UUID REFERENCES dim_mitarbeiter(id),
  status TEXT DEFAULT 'calculated' CHECK (status IN (
    'calculated',      -- Berechnet, nicht finalisiert
    'approved',        -- Von Backoffice/GF genehmigt
    'paid_abschlag',   -- 80% ausgezahlt
    'paid_ruecklage',  -- 20% ausgezahlt (nach Garantie)
    'clawed_back',     -- Storniert wegen Kandidat-Austritt
    'superseded'       -- Durch neuere Berechnung ersetzt (Draft-Szenario)
  )),
  superseded_by_id UUID REFERENCES fact_commission_ledger(id),
  notes TEXT
);

-- Pauschale-Zuordnung Researcher (pro Placement)
CREATE TABLE fact_researcher_fee (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  researcher_id UUID NOT NULL REFERENCES dim_mitarbeiter(id),
  candidate_id UUID NOT NULL REFERENCES dim_kandidat(id),
  process_id UUID NOT NULL REFERENCES fact_process_finance(id),
  placement_date DATE NOT NULL,
  rate_chf NUMERIC(8,2) NOT NULL CHECK (rate_chf BETWEEN 250 AND 750),
  rationale TEXT,                                   -- warum 300 statt 500? z.B. "Standard-Platzierung"
  approved_by UUID REFERENCES dim_mitarbeiter(id),  -- Head of oder GF genehmigt Höhe
  approved_at TIMESTAMPTZ,
  ledger_entry_id UUID REFERENCES fact_commission_ledger(id),
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending','approved','paid','clawed_back')),
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Bonus-Ermessen (Nicht-Prov.-Berechtigte · GF-Bonus · Ermessens-Ausnahmen)
CREATE TABLE fact_bonus_payment (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  mitarbeiter_id UUID NOT NULL REFERENCES dim_mitarbeiter(id),
  amount_chf NUMERIC(10,2) NOT NULL,
  payment_period_year INT NOT NULL,
  payment_period_quarter INT CHECK (payment_period_quarter BETWEEN 1 AND 4),
  rationale TEXT NOT NULL,                          -- Begründung Pflicht
  approver_id UUID NOT NULL REFERENCES dim_mitarbeiter(id),
  approved_at TIMESTAMPTZ,
  ledger_entry_id UUID REFERENCES fact_commission_ledger(id),
  status TEXT DEFAULT 'approved' CHECK (status IN ('proposed','approved','paid','rejected')),
  notes TEXT,
  -- Self-approval für GF allowed (approver_id = mitarbeiter_id)
  -- Für andere: GF muss approven
  CHECK (approver_id = mitarbeiter_id OR approver_id IN (
    SELECT id FROM dim_mitarbeiter WHERE commission_primary_role = 'geschaeftsfuehrer'
  ))
);

-- Quartals-Abrechnungs-Batch (Quartalsabschluss)
CREATE TABLE fact_commission_batch (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  period_year INT NOT NULL,
  period_quarter INT NOT NULL CHECK (period_quarter BETWEEN 1 AND 4),
  close_date DATE,                                  -- Q-Ende
  payout_date DATE,                                 -- Folgemonat: Apr/Jul/Okt/Jan
  total_gross_chf NUMERIC(10,2),
  total_abschlag_chf NUMERIC(10,2),
  total_ruecklage_chf NUMERIC(10,2),
  total_ruecklage_frei_chf NUMERIC(10,2),          -- Freigegebene Rücklagen Vor-Quartale
  total_clawback_chf NUMERIC(10,2),
  total_bonus_ermessen_chf NUMERIC(10,2),
  total_net_payout_chf NUMERIC(10,2),               -- = abschlag + ruecklage_frei - clawback + bonus
  ledger_entries UUID[],
  export_file_url TEXT,                             -- CSV/Excel/XML Path
  exported_at TIMESTAMPTZ,
  approved_by UUID REFERENCES dim_mitarbeiter(id),
  approved_at TIMESTAMPTZ,
  status TEXT DEFAULT 'draft' CHECK (status IN (
    'draft', 'ready_for_approval', 'approved', 'exported', 'paid'
  )),
  UNIQUE (period_year, period_quarter)
);

-- Rücklage-Freigabe-Events (nach Garantie-Ablauf 3 Mt)
CREATE TABLE fact_ruecklage_release (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  ledger_entry_id UUID NOT NULL REFERENCES fact_commission_ledger(id),
  guarantee_id UUID NOT NULL REFERENCES fact_candidate_guarantee(id),
  release_date DATE NOT NULL,
  amount_chf NUMERIC(10,2) NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('release', 'clawback')),
  reason TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);
```

### 2.3 Erweiterung bestehender Tabellen

```sql
-- fact_process_finance · Kommission-Tracking
ALTER TABLE fact_process_finance ADD COLUMN IF NOT EXISTS
  commission_calc_status TEXT DEFAULT 'pending' CHECK (commission_calc_status IN (
    'pending','calculated','included','excluded_time_mandat'
  )),
  commission_ledger_ids UUID[];                     -- Ledger-Einträge die diesen Deal verwenden

-- bridge_mitarbeiter_roles · Rolle 'assessment_manager' ergänzen
-- Seed:
INSERT INTO dim_roles (code, name) VALUES ('assessment_manager', 'Assessment Manager')
ON CONFLICT DO NOTHING;
```

### 2.4 Views für Reports + UI

```sql
-- MA-Self-View (eigene Commission)
CREATE VIEW v_commission_self AS
SELECT
  cl.mitarbeiter_id,
  cl.period_year,
  cl.period_quarter,
  cl.model,
  cl.zeg_pct,
  cl.commission_gross_chf,
  cl.abschlag_chf,
  cl.ruecklage_chf,
  cl.ruecklage_frei_chf,
  cl.status
FROM fact_commission_ledger cl
WHERE cl.status != 'superseded';

-- Head-of-Teambudget-View (Sparten-Rollup)
CREATE VIEW v_head_of_teambudget AS
SELECT
  m.id AS head_of_id,
  dy.year,
  UNNEST(m.head_of_sparten) AS sparte,
  SUM(CASE WHEN mand.business_model != 'time' THEN fpf.net_fee_chf * 2.0 ELSE 0 END) AS teambudget_net_fees_chf,
  -- Head-of sieht jeden Deal Pkt 2 (voller Anteil)
  COUNT(fpf.id) AS placements_count
FROM dim_mitarbeiter m
JOIN dim_commission_year dy ON dy.mitarbeiter_id = m.id
JOIN dim_jobs j ON j.sparten_id = ANY(m.head_of_sparten)
JOIN fact_process_finance fpf ON fpf.job_id = j.id AND fpf.placement_date IS NOT NULL
LEFT JOIN dim_mandate mand ON mand.id = fpf.mandate_id
WHERE m.commission_primary_role = 'head_of'
GROUP BY m.id, dy.year, sparte;

-- Backoffice-Auszahlungs-Queue
CREATE VIEW v_commission_payout_queue AS
SELECT
  cb.id AS batch_id,
  cb.period_year,
  cb.period_quarter,
  cb.payout_date,
  cb.total_net_payout_chf,
  cb.status,
  COUNT(cl.id) AS entries_count,
  SUM(cl.commission_gross_chf) AS sum_gross
FROM fact_commission_batch cb
LEFT JOIN fact_commission_ledger cl ON cl.id = ANY(cb.ledger_entries)
WHERE cb.status IN ('draft','ready_for_approval','approved')
GROUP BY cb.id;
```

---

## 3. Berechnungs-Engine · Kern-Logik

### 3.1 Researcher-Pauschale · Peter-bestätigt 2026-04-19

**Input**: Placement (Stage `placement` erreicht) · `dim_kandidat.created_by_user_id` = Researcher
**Output**: `fact_researcher_fee` mit CHF 500 default · frei umstellbar 250-750

**Algorithmus (simplifiziert · kein Auto-Staffel)**:
```
wenn placement.stage == 'placement'
  und candidate.created_by_user_id ist Researcher-Rolle:

  INSERT fact_researcher_fee(
    researcher_id,
    candidate_id,
    process_id,
    placement_date,
    rate_chf = 500,        -- DEFAULT (Peter 2026-04-19)
    status = 'pending'     -- kann manuell auf 250-750 gesetzt werden vor Approval
  )

  Notification an Head-of oder GF für Rate-Review
  wenn manueller Override (z.B. 750 bei Top-Executive-Placement oder 250 bei minimalem Aufwand):
    Update rate_chf + rationale-Feld Pflicht
    approved_by = Head-of (normal) oder GF (Ausnahme)
```

**Rationale-Feld**: Pflicht bei Override · Beispiele: "Top-Executive-Placement + schnelle Closing" (→750) · "Minimaler Research-Aufwand · Kandidat war Walk-In" (→250)

**Claw-back**: wenn Garantie-Breach → `fact_researcher_fee.status = 'clawed_back'`

### 3.2 CM/AM-50/50-Split + ZEG-Staffel

**Input**: Alle Placements eines MA in einem Quartal · `am_user_id` / `cm_user_id` / `split_am_pct` / `split_cm_pct`
**Output**: `fact_commission_ledger` mit `model='cm_am_zeg'`

**Algorithmus** (kumulativ quartalsweise):
```
function calc_cm_am(ma_id, year, quarter):
  # 1. Budget kumuliert bis zum Quartals-Ende
  jahres_budget = dim_commission_year.annual_budget_chf WHERE mitarbeiter_id = ma_id AND year = year
  quartals_budget = jahres_budget / 4
  budget_kumuliert = quartals_budget * quarter

  # 2. Net Fees kumuliert (über alle Quartale Q1 bis current Q)
  net_fees_kumuliert = 0
  FOR placement IN placements WHERE placement_date <= quarter_end AND placement_date.year = year:
    wenn placement.business_model == 'time': CONTINUE  # Time ausgeschlossen
    wenn placement.am_user_id == ma_id AND placement.cm_user_id == ma_id:
      # beide Rollen = voller Anteil (Pkt 2 = 100%)
      net_fees_kumuliert += placement.net_fee_chf
    elif placement.am_user_id == ma_id:
      net_fees_kumuliert += placement.net_fee_chf * (placement.split_am_pct / 100)
    elif placement.cm_user_id == ma_id:
      net_fees_kumuliert += placement.net_fee_chf * (placement.split_cm_pct / 100)

  # 3. ZEG berechnen
  zeg_pct = (net_fees_kumuliert / budget_kumuliert) * 100

  # 4. Staffel-Lookup → Provisions-Satz
  staffel_rate = SELECT base_rate_pct + step_per_pct * (zeg_pct - zeg_from_pct)
                 FROM dim_commission_staffel
                 WHERE zeg_from_pct <= zeg_pct AND zeg_to_pct >= zeg_pct
                 AND valid_from <= current_date AND (valid_until IS NULL OR valid_until >= current_date)

  # 5. Commission brutto
  quartals_ote = jahres_ote / 4
  commission_gross_kumuliert = quartals_ote * quarter * (staffel_rate / 100)
  commission_gross_quarter = commission_gross_kumuliert - SUM(previous_quarters_gross)

  # 6. 80/20-Split
  abschlag = commission_gross_quarter * 0.80
  ruecklage = commission_gross_quarter * 0.20

  INSERT fact_commission_ledger(mitarbeiter_id, period_year=year, period_quarter=quarter,
                                model='cm_am_zeg', net_fees_cumulated_chf=net_fees_kumuliert,
                                budget_cumulated_chf=budget_kumuliert, zeg_pct=zeg_pct,
                                staffel_rate_pct=staffel_rate, commission_gross_chf=commission_gross_quarter,
                                abschlag_chf=abschlag, ruecklage_chf=ruecklage, status='calculated')
```

### 3.3 Head-of-Teambudget-Rollup

**Input**: Alle Placements in den Sparten des Head-of (`dim_mitarbeiter.head_of_sparten[]`)
**Output**: `fact_commission_ledger` mit `model='head_of_teambudget'`

**Algorithmus**:
```
function calc_head_of(head_of_id, year, quarter):
  sparten = dim_mitarbeiter.head_of_sparten[] WHERE id = head_of_id
  jahres_budget = dim_commission_year.annual_budget_chf  -- z.B. 1.5M für Peter CI+BT

  quartals_budget = jahres_budget / 4
  budget_kumuliert = quartals_budget * quarter

  # Teambudget = alle Placements in Sparten · Pkt 2 (voller Anteil)
  net_fees_kumuliert = 0
  FOR placement IN placements JOIN jobs JOIN sparten:
    wenn placement.business_model == 'time': CONTINUE  # Time ausgeschlossen
    wenn placement.sparten_id IN sparten AND placement.placement_date <= quarter_end:
      net_fees_kumuliert += placement.net_fee_chf  # Pkt 2 = 100%

  # Mandats-Stages einzeln (aus Peter-Sheet): Stage 1/2/3/4-Zahlungen separat
  # werden bereits als separate fact_process_finance-Zeilen erfasst
  # → keine zusätzliche Logik, bereits in obigem SUM enthalten

  # Rest analog CM/AM:
  zeg_pct, staffel_rate, commission_gross, abschlag, ruecklage = ... (same as §3.2)

  INSERT fact_commission_ledger(..., model='head_of_teambudget', ...)
```

### 3.4 Multi-Role-Priorisierung

**Wenn MA mehrere Rollen hat**, greift `commission_primary_role`:

```
function get_commission_model(mitarbeiter_id):
  primary = dim_mitarbeiter.commission_primary_role

  switch primary:
    case 'head_of': return 'head_of_teambudget'
    case 'cm_am': return 'cm_am_zeg'
    case 'researcher': return 'researcher_fee'
    case 'assessment_manager': return 'assessment_manager'  # TBC
    case 'geschaeftsfuehrer': return NULL  # nur Bonus-Ermessen
    case 'backoffice': return NULL  # nur Bonus-Ermessen
    default: return NULL
```

**Beispiel Peter**:
- Rollen: Head of · CM · AM · Admin
- `commission_primary_role = 'head_of'`
- Commission = Head-of-Teambudget-Rollup (1.5M · OTE 90k)
- Auch wenn Peter als CM/AM bei einem Placement steht, zählt für seine Commission nur der Head-of-Teambudget-Eintrag (das Placement fliesst über die Sparten-Aggregation ohnehin ein)

### 3.5 Rücklage-Mechanik

**Freigabe**: Wenn `fact_candidate_guarantee.end_at <= current_date`:
```
FOR ledger_entry IN fact_commission_ledger
  WHERE guarantees_linked CONTAINS guarantee.id:

  wenn candidate noch beim Kunden (kein Austritt in Garantie):
    INSERT fact_ruecklage_release(ledger_entry_id, guarantee_id, type='release',
                                  amount_chf=ruecklage_anteil_fuer_diesen_deal)
    UPDATE fact_commission_ledger.ruecklage_frei_chf += amount_chf

  sonst (candidate ausgetreten in Garantie):
    INSERT fact_ruecklage_release(ledger_entry_id, guarantee_id, type='clawback',
                                  amount_chf=ruecklage_anteil_fuer_diesen_deal,
                                  reason='Kandidat-Austritt in Garantie')
    UPDATE fact_commission_ledger.ruecklage_clawback_chf += amount_chf
```

### 3.6 Time-Mandat-Ausschluss

Alle Berechnungen ausschliessen:
```
WHERE dim_mandate.business_model != 'time'
```

Time-Deals werden aktuell "ausserordentlich abgerechnet" (Excel). Phase 3 kommt eigene Logik.

---

## 4. Flows · Workflows

### 4.1 Placement-Trigger → automatische Ledger-Erzeugung

```
EVENT placement_confirmed (fact_process_finance.placement_date SET)
  ↓
WORKER commission-calc.worker.ts
  ↓
1. Researcher-Fee erzeugen (aus dim_kandidat.created_by_user_id)
  INSERT fact_researcher_fee(...) status='pending'
  ↓
2. Aktuellen Quartals-Commission-Snapshot neu berechnen
  für AM · CM · Head-of beteiligte
  DELETE fact_commission_ledger WHERE period == current_quarter AND status='calculated'
  INSERT fact_commission_ledger(...) neu
  ↓
3. Notifications senden
  MA: "Commission-Update wegen neuem Placement"
  Backoffice: "Neue Commission-Berechnung zur Genehmigung"
```

### 4.2 Quartals-Abschluss

```
EVENT quarter_end_reached (trigger: erster Werktag des Folgemonats)
  ↓
WORKER commission-quarter-close.worker.ts
  ↓
1. Snapshot aller aktuellen Commission-Ledger-Einträge
  UPDATE fact_commission_ledger SET status='approved' WHERE period = closing_quarter
  ↓
2. Batch erstellen
  INSERT fact_commission_batch(period_year, period_quarter, close_date, status='ready_for_approval')
  ↓
3. Backoffice-Notification
  "Q1-Commission ready for approval · total CHF X · Auszahlung fällig TT.MM"
  ↓
4. Nach Backoffice-Approval:
  UPDATE fact_commission_batch.status = 'approved'
  Generate CSV/Excel/XML Export
  UPDATE fact_commission_batch.status = 'exported', export_file_url = ...
```

### 4.3 Rücklage-Freigabe (Cron täglich)

```
CRON daily-guarantee-check.worker.ts (täglich 02:00)
  ↓
FOR guarantee IN fact_candidate_guarantee WHERE end_at = today:
  Check: Candidate noch angestellt? (dim_kandidat.current_employer match)
  ↓
  Wenn ja: fact_ruecklage_release type='release' · total Rücklage freigegeben
  Wenn Austritt: fact_ruecklage_release type='clawback' · Gegen-Buchung
```

### 4.4 Bonus-Ermessen-Flow · Peter-Update 2026-04-19

**Zwei Sub-Flows**:

**Sub-Flow A · GF-Self-Bonus** (Nenad für sich selber):
```
UI · Nenad öffnet /commission/bonus · Tab "Mein Bonus"
  ↓
Drawer: Betrag · Periode · Begründung
  ↓
INSERT fact_bonus_payment
  mitarbeiter_id = NS, approver_id = NS (self)
  status = 'approved' auto (self-approval)
  head_of_consensus_required = false
  ↓
Bonus im nächsten Quartals-Batch
```

**Sub-Flow B · GF-Bonus-für-andere-MA** (Nenad schüttet Bonus für ST, SN, oder jeden anderen):
```
UI · Nenad öffnet /commission/bonus · Tab "Bonus vorschlagen"
  ↓
Drawer: Zielperson · Betrag · Periode · Begründung
  ↓
INSERT fact_bonus_payment
  mitarbeiter_id = <Ziel>
  approver_id = NS
  head_of_consensus_required = true (Pflicht bei Nicht-GF)
  status = 'proposed'
  ↓
Notification an relevante Head-ofs (nach Sparten-Zuordnung des Ziel-MA):
  - z.B. für Joaquin (CI) → Peter benachrichtigt
  - z.B. für Anna (ARC) → Yavor benachrichtigt
  - Severina/Sabrina · Cross-Head-Konsens (alle 3 Head-ofs)
  ↓
Head-ofs bestätigen oder widersprechen (in-app)
  ↓
wenn alle relevanten Head-ofs bestätigt → UPDATE status = 'approved'
wenn mindestens 1 Head-of widerspricht → Review-Meeting · manuelle Klärung
  ↓
Nach Approval: Bonus im nächsten Quartals-Batch
```

**Schema-Erweiterung `fact_bonus_payment`**:
```sql
ALTER TABLE fact_bonus_payment ADD COLUMN IF NOT EXISTS
  head_of_consensus_required BOOLEAN DEFAULT true,
  head_of_approvals JSONB,  -- [{head_of_id, approved_at, approved: true/false, comment}, ...]
  consensus_status TEXT DEFAULT 'pending' CHECK (consensus_status IN (
    'pending', 'consensus_reached', 'disputed', 'not_required'
  ));
```

**Approval-Regel**:
- GF-Self-Bonus: `head_of_consensus_required = false` · instant approval
- Bonus für andere: `head_of_consensus_required = true` · alle relevanten Head-ofs müssen bestätigen
- Kein festes CHF-Limit (GF entscheidet im Rahmen seines Ermessens)

### 4.5 Simulations-Flow (Was-wäre-wenn)

```
UI · MA öffnet /commission/my · Tab "Simulation"
  ↓
"Was-wäre-wenn-Placement"-Form:
  - Neue Net Fee CHF: [input]
  - Split AM/CM: [toggle]
  - Sparte: [select]
  - Datum: [date, default=today]
  ↓
Endpoint POST /api/commission/simulate
  ↓
Clone aktuelle Commission-Calculation
  Füge Pseudo-Placement hinzu
  Berechne neue ZEG + Staffel + Commission
  Return Delta: "Dein Commission würde um CHF X steigen"
  ↓
Simulation wird NICHT gespeichert · nur Preview
  (kein Ledger-Insert, temporäre Berechnung)
```

---

## 5. Events

| Event-Code | Trigger | Subscriber | Aktion |
|------------|---------|------------|--------|
| `commission_calculated` | Neue Ledger-Row | MA-Notification-Worker | In-App + Email-Digest |
| `commission_quarter_ready` | Quartals-Close | Backoffice-Notification | Approval-Queue |
| `commission_approved` | Backoffice approved Batch | Export-Worker | CSV/Excel generieren |
| `commission_exported` | File generiert | Backoffice | Download-Link |
| `ruecklage_released` | Garantie abgelaufen, Candidate noch da | MA-Notification | "Deine Rücklage vom Q1 wurde freigegeben" |
| `ruecklage_clawback` | Garantie-Breach | MA + Head-of | "Rücklage wurde gegengerechnet" |
| `bonus_proposed` | GF schlägt Bonus vor | Empfänger + GF | Notification |
| `bonus_approved` | Approval durch GF | Empfänger | Notification + Nächste Batch-Inclusion |
| `commission_staffel_updated` | Neue Staffel-Version (jährlich) | alle MA + Admin | Info-Broadcast |

---

## 6. RBAC

### 6.1 Rollen-Berechtigungen

| Rolle | Own-Commission | Team-Commission | All-Commission | Batch-Approve | Export | Staffel-Config |
|-------|----------------|-----------------|----------------|---------------|--------|----------------|
| MA (normal) | ✓ read | — | — | — | — | — |
| Head of | ✓ read | ✓ read (Sparten-Scope) | — | — | — | — |
| Backoffice | ✓ read | — | ✓ read | ✓ | ✓ | — |
| Geschäftsführer | ✓ self-approve | — | ✓ read | ✓ | ✓ | ✓ |
| Admin | ✓ read | ✓ read | ✓ read+write | ✓ | ✓ | ✓ |

### 6.2 Spezial-Rechte

**Geschäftsführer (Nenad)**:
- Self-approval für eigene Boni
- Approval für Sabrina/Severina-BO-Teil
- Full visibility alle MA

**Head of**:
- Read-only auf Commission aller MA in eigenen Sparten
- Keine Approval-Rechte (das macht Backoffice)

---

## 7. UI-Scope

### 7.1 Neue Routen

| Route | Zweck | RBAC |
|-------|-------|------|
| `/commission/my` | Eigene Commission-Übersicht | MA-Self |
| `/commission/team` | Team-Übersicht (Sparten-Scope) | Head of |
| `/commission/admin` | Backoffice-Dashboard · Approval-Queue · Export | Backoffice · Admin |
| `/commission/batch/:id` | Batch-Detail (Backoffice) | Backoffice · Admin |
| `/commission/staffel` | Staffel-Editor | Admin |
| `/commission/bonus` | Ermessens-Bonus-Flow | GF · Admin |
| `/commission/simulate` | Was-wäre-wenn | MA-Self · Head of |

### 7.2 Mockup-Scope (nach Peter-Freigabe)

| Mockup | Primär-User | Scope |
|--------|------------|-------|
| `mockups/ERP Tools/commission-my.html` | MA (Joaquin, Nina, etc.) | Eigene Ledger-Einträge, ZEG-Meter, Quartals-Verlauf, Simulation |
| `mockups/ERP Tools/commission-team.html` | Head of (Peter) | Team-Matrix Sparten × MA, Teambudget-Fortschritt |
| `mockups/ERP Tools/commission-admin.html` | Backoffice (Sabrina) | Queue, Approval, Export, Batch-History |
| `mockups/ERP Tools/commission-bonus.html` | GF (Nenad) | Bonus-Vorschlag, Approval-Übersicht |

### 7.3 Widget-Integration in bestehende Mockups

- `candidates.html` · beim Placement-Event: "Provisions-Trigger" Info-Box
- `processes.html` · Prozess-Detail: "Commission-Status" Chip bei Placements
- `accounts.html` · History: Provisions-relevante Activities

---

## 8. Export-Formate (Phase 1 · kein Bexio-API)

### 8.1 CSV (Treuhänder-Import)

```csv
Mitarbeiter-Kürzel;Name;Periode;Modell;ZEG %;Brutto CHF;Abschlag 80% CHF;Rücklage 20% CHF;Rücklage frei CHF;Clawback CHF;Bonus CHF;Netto Auszahlung CHF
PW;Peter Wiederkehr;Q1-2026;head_of;79;13050;10440;2610;0;0;0;10440
JV;Joaquin Vega;Q1-2026;cm_am;118;12800;10240;2560;0;0;0;10240
HvdB;Hannah van den Bosch;Q1-2026;researcher;—;1500;1500;0;0;0;0;1500
NS;Nenad Stoparanovic;Q1-2026;bonus_ermessen;—;0;0;0;0;0;5000;5000
```

### 8.2 Excel (.xlsx, mit Formatierung)

- Tab 1: Summary
- Tab 2: Detail pro MA
- Tab 3: Staffel-Referenz
- Tab 4: Audit-Trail

### 8.3 XML (Bexio-kompatibel, für Phase-2-Migration)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<BexioPayroll>
  <Period year="2026" quarter="1"/>
  <Employee>
    <Kuerzel>PW</Kuerzel>
    <Name>Peter Wiederkehr</Name>
    <CommissionGross>13050</CommissionGross>
    <Abschlag>10440</Abschlag>
    <Ruecklage>2610</Ruecklage>
    <NetPayout>10440</NetPayout>
  </Employee>
  ...
</BexioPayroll>
```

---

## 9. Migrations-Strategie · Historische Daten (Peter 2026-04-19)

### 9.1 Historie-Anforderung

Peter-Input 2026-04-19: **Möglichkeit muss vorhanden sein vergangene Umsätze einzutragen auch bei langjährigen MA**. Beispiel Peter selbst (6 Jahre):
- Jahre 1-2: Researcher (Pauschale pro Placement)
- Jahre 3-4: CM (CM/AM 50/50 mit ZEG-Staffel)
- Jahre 4-5: CM + AM (voller Anteil 100 %)
- Jahre 5-6: Head of CI & BT (Teambudget-Rollup)

**Konsequenz**: Migration ist nicht nur "initial Import", sondern **dauerhafte Fähigkeit** historische Daten einzutragen. `dim_commission_year` speichert pro MA · pro Jahr · pro Rolle:

```sql
-- Beispiel Peter 2021-2026 (6 Rollen-Jahre)
INSERT INTO dim_commission_year (mitarbeiter_id, year, commission_role, annual_budget_chf, annual_ote_chf) VALUES
  ('uuid-peter', 2021, 'researcher', NULL, NULL),  -- Pauschale, kein Budget
  ('uuid-peter', 2022, 'researcher', NULL, NULL),
  ('uuid-peter', 2023, 'cm_am', 360000, 30000),
  ('uuid-peter', 2024, 'cm_am', 440000, 40000),
  ('uuid-peter', 2025, 'cm_am', 500000, 50000),    -- mit Split-Rollen AM+CM mal
  ('uuid-peter', 2026, 'head_of', 1500000, 90000); -- seit Beförderung
```

### 9.2 Historische Placements & Researcher-Fees

```sql
-- Historische Placements eintragen (ggf. ohne existierende process_id)
INSERT INTO fact_commission_ledger (
  mitarbeiter_id, period_year, period_quarter,
  commission_role, model,
  net_fees_cumulated_chf, budget_cumulated_chf, zeg_pct,
  staffel_rate_pct, commission_gross_chf, abschlag_chf, ruecklage_chf,
  source_snapshot,
  status = 'paid_ruecklage',  -- historisch: voll bezahlt
  calculated_at = <historisches_datum>,
  calculated_by = <admin-user>,
  notes = 'Migration-Eintrag · Excel-Quelle · Periode vor CRM-Einführung'
);

-- Historische Researcher-Pauschalen
INSERT INTO fact_researcher_fee (
  researcher_id, placement_date, rate_chf,
  status = 'paid',
  rationale = 'Historisch · ohne Process-Referenz',
  notes = 'Migration aus Excel'
);
```

**Wichtige Felder für historische Imports**:
- `notes` Pflicht mit "Migration"-Prefix für Audit-Trail-Klarheit
- `source_snapshot` JSONB speichert Original-Excel-Daten als Backup
- `calculated_at` kann rückdatiert werden (Historie-Rekonstruktion)
- `calculated_by` = Admin-User (system-account) für Migrations-Batch

### 9.3 Rollen-Historie-View

```sql
-- Übersicht für MA-Self: "Meine Rollen-Historie"
CREATE VIEW v_my_role_history AS
SELECT
  mitarbeiter_id,
  year,
  commission_role,
  annual_budget_chf,
  annual_ote_chf,
  (SELECT SUM(commission_gross_chf) FROM fact_commission_ledger fcl
    WHERE fcl.mitarbeiter_id = dcy.mitarbeiter_id
    AND fcl.period_year = dcy.year
    AND fcl.status != 'superseded') AS total_commission_year
FROM dim_commission_year dcy
ORDER BY mitarbeiter_id, year DESC;
```

UI · Mitarbeiter-Profil-Tab "Karriere-Verlauf" zeigt Peter: "2021-2022 Researcher (CHF 8'400) → 2023 CM (CHF 24'500) → 2024 CM/AM (CHF 38'200) → 2025 CM (CHF 52'800) → 2026 Head of (CHF X YTD)".

### 9.4 Parallelbetrieb + Switch-over

- Phase 1 · 3-6 Monate: ARK-Engine läuft parallel · Excel-Abgleich pro Quartal
- Validation: Unit-Tests gegen Peter-Q1-2026-Sheet + Joaquin-Q1-2026-Sheet (beide Resultate müssen matchen)
- Switch-over: Nach 3-6 Monaten Clean-Lauf · Excel wird Archiv · ARK-Engine primär

### 9.5 Rollen-Wechsel innerhalb Jahr

Möglich: `dim_commission_year` erlaubt mehrere Einträge pro MA pro Jahr wenn Rolle wechselt:

```sql
-- Beispiel: MA wird mitten Jahr befördert von CM zu Head of
UPDATE dim_commission_year SET pro_rata_end_month = 6 WHERE id = 'alte-rolle-cm';
INSERT INTO dim_commission_year (year, commission_role='head_of', pro_rata_start_month=7, ...);
```

Commission-Berechnung berücksichtigt aktive Rolle pro Quartal (Q1-Q2 als CM · Q3-Q4 als Head of).

---

## 10. Phasen & Timeline

| Phase | Scope | Aufwand |
|-------|-------|---------|
| **P1.0** | Schema + Migration + Basis-Berechnung (Researcher · CM/AM · Head-of) | 3-4 Wo |
| **P1.1** | Quartals-Abschluss-Worker + Export-CSV | 2 Wo |
| **P1.2** | UI · /commission/my + /commission/admin | 3-4 Wo |
| **P1.3** | Rücklage-Management + Claw-back + Garantie-Integration | 2-3 Wo |
| **P1.4** | Simulations-UI + Head-of-Team-View | 2 Wo |
| **P1.5** | Bonus-Ermessen-Flow + GF-UI | 1-2 Wo |
| **P1.6** | Excel-Migration + QA-Parallel-Lauf (3-6 Mt) | 3-6 Mt parallel |
| **P1.7** | Assessment-Manager-Modell (TBC nach Peter-Klärung) | 1-2 Wo |

**Total P1.0-P1.7**: ~15-20 Wochen Development + 3-6 Mt QA-Parallel

---

## 11. Risiken

| Risiko | W | I | Mitigation |
|--------|---|---|------------|
| Migration-Fehler (Excel → DB) | mittel | hoch | 3-6 Mt Parallel-Betrieb mit Excel |
| Staffel-Berechnungs-Bug | niedrig | sehr hoch | Unit-Tests gegen Peter-Joaquin-Sheets (alle 4 Quartale müssen matchen) |
| Time-Mandat-Edge-Cases | mittel | mittel | Explizit ausschliessen, Phase-3-TODO |
| Head-of-Sparten-Rollup-Drift | niedrig | mittel | Automated Reconciliation-Reports |
| Assessment-Manager-Modell unklar | hoch | niedrig | TBC flagen, P1.7 nach Klärung |
| Clawback-Race-Condition | niedrig | hoch | Event-sourced append-only, Idempotenz |
| Multi-Role-Primary-Ambiguität | niedrig | mittel | `commission_primary_role` als Pflichtfeld validiert |
| Performance bei Simulations | niedrig | niedrig | Read-only Pseudo-Query, kein Insert |

---

## 12. Entscheidungs-Status (Peter 2026-04-19)

**5 geklärt**:
1. ✅ Assessment-Manager · Jahresziel + quartalsweise Bonus wie CM/AM (Staffel-Detail TBC)
2. ✅ Yavor = Head of **ARC + REM**
4. ✅ Researcher-Pauschale: **CHF 500 default · frei umstellbar** (250-750)
5. ✅ Bonus-Ermessen: **kein CHF-Limit** · GF entscheidet · Head-of-Absprache bei Nicht-GF-Boni Pflicht · GF-Self-Approval ohne Absprache
7. ✅ Quartals-Abschluss **nachträglich änderbar** mit Audit-Log (via `superseded`-Marker)

**Peter-Antworten 2026-04-19 (Runde 2)**:
3. ✅ **Stefano Option D** · eigenes Metrik-System · Metrik-Definition "noch zu definieren" · Platzhalter bis Definition (keine ZEG-Rollup aktiv)
6. ✅ **Migration mit Rollen-Historie** · MA haben über Jahre verschiedene Rollen durchlaufen (Peter 6J: Researcher → CM → CM/AM → Head of) · System muss vergangene Umsätze eintragen lassen + historische Rollen-Zuordnung abbilden
1b. ✅ **Severina Jahresziel 2026: CHF 300k Assessment-Umsatz** · Staffel-Detail ebenfalls "noch zu definieren" · Vorschlag: ZEG-Staffel wie CM/AM + 100 %-Zuteilung (kein Split)

**Noch offen (2 TBC)**:
- Stefanos Metrik-System · konkrete Definition (Neu-Akquise · Pipeline-Aufbau · Client-Retention · ?)
- Assessment-Staffel · ZEG wie CM/AM oder linear/binär · OTE-Betrag

---

## 13. Cross-Dependencies

- **HR-Modul** (Phase 1 parallel): liefert `dim_mitarbeiter.commission_primary_role` + `head_of_sparten[]` + Onboarding/Offboarding-Events
- **CRM-Kern** (existiert): `fact_process_finance` · `dim_kandidat` · `fact_candidate_guarantee` · `dim_mandate`
- **Payroll (extern)**: Treuhänder / Bexio via CSV-Import nimmt Export-File und verarbeitet Lohnlauf
- **Reporting** (Phase 2): Power BI pullt aus `fact_commission_ledger` + `v_commission_self`

---

## 14. Next Actions (nach Peter-Freigabe dieser Spec)

1. Grundlagen-Sync (5 Files patchen, `ARK_DATABASE_SCHEMA_PATCH_v1_3_to_v1_4.md` erweitern um neue Tabellen)
2. Stammdaten-Erweiterung: Rolle `assessment_manager`
3. Mockup-Runde: 4 neue Files in `mockups/ERP Tools/`
4. Backend-Architektur-Update: 3 neue Worker · 9 neue Events
5. Migration-Skript schreiben (Excel-Import)
6. Strategy-Decision `v1.0` freezen (mit Peter-Korrekturen Handoff §5.1)
7. Alte Memory `project_commission_model.md` → aktualisiert ✓ (bereits gemacht)

---

## Related

- `wiki/concepts/provisionierung.md` (authoritativ · Scope updated 2026-04-19)
- `wiki/sources/anhang-provisionsstaffel-cm.md`
- `wiki/sources/provisionssheet-joaquin.md`
- `wiki/sources/provisionssheet-peter.md`
- `memory/project_commission_model.md` (Scope-Update)
- `memory/project_arkadium_roles_2026.md` (MA-Matrix)
- `ERP Tools/specs/ARK_COMMISSION_ABGLEICH_HANDOFF_v0_1.md` (Abgleich)
- `ERP Tools/specs/ARK_HR_STRATEGY_DECISION_v0_1.md` (Option D · Draft)
- Künftig: `ARK_COMMISSION_ENGINE_SCHEMA_v0_1.md` (DB-Migration)
- Künftig: `ARK_COMMISSION_ENGINE_INTERACTIONS_v0_1.md` (detaillierte Flow-Specs)
- Künftig: Mockups `commission-my.html` · `commission-team.html` · `commission-admin.html` · `commission-bonus.html`
