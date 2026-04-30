---
title: "ARK Gesamtsystem-Übersicht · Patch v1.5 → v1.6 · Billing-Modul"
type: patch
phase: 3
created: 2026-04-30
updated: 2026-04-30
status: draft
sources: [
  "Grundlagen MD/ARK_GESAMTSYSTEM_UEBERSICHT_v1_5.md",
  "specs/ARK_BILLING_PLAN_v0_1.md",
  "specs/ARK_BILLING_SCHEMA_v0_1.md",
  "specs/ARK_BILLING_INTERACTIONS_v0_1.md",
  "specs/ARK_DATABASE_SCHEMA_PATCH_v1_4_to_v1_5_billing.md",
  "specs/ARK_BACKEND_ARCHITECTURE_PATCH_v2_6_to_v2_7_billing.md",
  "specs/ARK_STAMMDATEN_PATCH_v1_4_to_v1_5_billing.md",
  "specs/ARK_FRONTEND_FREEZE_PATCH_v1_13_to_v1_14_billing.md",
  "memory/project_phase3_erp_standalone.md",
  "memory/project_commission_model.md",
  "memory/project_guarantee_protection.md",
  "memory/project_refund_model_routing.md",
  "memory/reference_treuhand_kunz.md"
]
target: "Grundlagen MD/ARK_GESAMTSYSTEM_UEBERSICHT_v1_5.md → v1.6 (TEIL 27 + Changelog-Eintrag)"
tags: [gesamtsystem, patch, billing, phase-3, cross-modul, treuhand, six-qr, decisions]
---

# ARK Gesamtsystem-Patch v1.5 → v1.6 · Billing-Modul

**Stand:** 2026-04-30
**Status:** Draft · ergänzend zu Performance-Modul-Patch v1.4 → v1.5 (TEIL 26)
**Append-Ziel:** TEIL 27 in `Grundlagen MD/ARK_GESAMTSYSTEM_UEBERSICHT_v1_6.md`.

---

## 0. ZIELBILD

Big-Picture-Sync für Billing-Modul Phase-3 v0.1. Changelog-Eintrag „v1.6 Billing-Modul v0.1", Phase-3-ERP-Module-Liste-Update (Billing als spec'd · Mockup-Reife ~80 %), Cross-Module-Integration-Tabelle (7 Achsen), 5 strategische Entscheidungen, Phase-Roadmap-Update.

---

## 1. Changelog-Eintrag

```markdown
## v1.6 (2026-04-30) · Billing-Modul Phase-3 v0.1

**Author:** PW
**Sources:**
- specs/ARK_BILLING_PLAN_v0_1.md
- specs/ARK_BILLING_SCHEMA_v0_1.md
- specs/ARK_BILLING_INTERACTIONS_v0_1.md

**Grundlagen-Patches in diesem Set (5/5 komplett):**
- DB-Schema v1.4 → v1.5 (`ARK_DATABASE_SCHEMA_PATCH_v1_4_to_v1_5_billing.md`, commit 2026-04-20)
- Backend-Architecture v2.6 → v2.7 (`ARK_BACKEND_ARCHITECTURE_PATCH_v2_6_to_v2_7_billing.md`, commit 2026-04-20)
- Stammdaten v1.4 → v1.5 (`ARK_STAMMDATEN_PATCH_v1_4_to_v1_5_billing.md`, commit 2026-04-20)
- Frontend-Freeze v1.13 → v1.14 (`ARK_FRONTEND_FREEZE_PATCH_v1_13_to_v1_14_billing.md`, commit 2026-04-30 · DIESER RUN)
- Gesamtsystem v1.5 → v1.6 (DIESER PATCH, commit 2026-04-30)

**Audit-Befund 2026-04-30:** Billing hatte 3/5 Sync-Patches → mit FE v1.14 + Gesamtsystem v1.6 jetzt **5/5 komplett**.
```

---

## 2. Phase-3-ERP-Module-Liste-Update

Ergänzung zu `ARK_GESAMTSYSTEM_UEBERSICHT_v1_5.md` Phase-3-ERP-Übersicht.

### 2.1 Modul-Status (Stand 2026-04-30)

| Modul | Spec-Status | Mockup-Reife | Grundlagen-Sync | Phase |
|-------|-------------|--------------|-----------------|-------|
| Zeit | spec'd | ~85 % | 5/5 | Phase 3 aktiv |
| HR | spec'd | ~80 % | 5/5 | Phase 3 aktiv |
| Performance | spec'd | ~75 % | 5/5 (TEIL 26 v1.5) | Phase 3 aktiv |
| E-Learning | spec'd | ~70 % | 5/5 | Phase 3 aktiv |
| **Billing** | **spec'd v0.1** | **~80 % (9 Mockups)** | **5/5 (NEU dieser Patch)** | **Phase 3 aktiv** |
| Commission-Engine | spec'd v0.1 | n/a (Engine, kein UI) | 4/5 (FE entfällt) | Phase 3 aktiv |
| Email & Kalender | spec'd v0.1 | ~85 % | 5/5 | Phase 2/3 aktiv |
| Reminders-Vollansicht | spec'd v0.1 | ~80 % | 5/5 | Phase 1-A aktiv |
| Stammdaten-Vollansicht | spec'd v0.1 | ~75 % | 5/5 (Phase-1-A v1.14) | Phase 1-A aktiv |

### 2.2 Billing-Modul-Inventar Phase 1

```
mockups/ERP Tools/billing/
  billing.html                  ← Hub (Snapshot-Bar + Sidebar-Tree „Finanzen")
  billing-dashboard.html        ← /billing (4-Spalten-KPI + 3 Widgets)
  billing-rechnungen.html       ← /billing/rechnungen + :id Drawer
  billing-mahnwesen.html        ← /billing/mahnwesen (4-Spalten-Cockpit)
  billing-debitoren.html        ← /billing/debitoren + :id Ledger
  billing-zahlungen.html        ← /billing/zahlungen (Match-Queue)
  billing-refunds.html          ← /billing/refunds (Garantie-Cockpit)
  billing-mwst.html             ← /billing/mwst (Quartals-Abrechnung)
  billing-inkasso.html          ← /billing/inkasso (SchKG-States)
```

**Inventar-Stand:** 9 Mockups (Hub + 8 Sub-Pages). Treuhand-Export-Sub-Page als Sub-Tab in `billing-rechnungen.html` prototypisch · eigenes Mockup in Phase 2.

---

## 3. Cross-Module-Integration

Billing ist zentrales Geld-Modul und integriert mit 7 anderen Modulen. Tabelle dokumentiert Pattern + Domain-Owner.

| Cross-Module | Pattern | Domain-Owner | Event-Schnittstelle |
|--------------|---------|--------------|--------------------|
| **Billing ↔ Mandate** | Erfolgsbasis-Staffel · 3-Stage-Akonto/Zwischen/Schluss · Shortlist-Trigger 2. Zahlung | Billing (Owner Rechnungs-Logik), Mandate (Owner Vertrag) | `mandate_signed` → `akonto_invoice_triggered` · `shortlist_reached` → `zwischen_invoice_triggered` · `placement_confirmed` → `schluss_invoice_triggered` |
| **Billing ↔ Time-Mandate** | Zeit-Modul liefert Wochen-Aggregat → `billing-rechnungen.html` (Cross-Modul-Pattern · Billing ist Domain-Owner für Rechnungs-Erstellung) | Billing (Owner), Zeit (Datenlieferant) | Cron `time-mandate-monthly-invoice` · Worker liest `fact_zeit_summary`, schreibt Rechnung |
| **Billing ↔ Commission-Engine** | Provisions-Trigger bei Zahlungseingang · 80/20 Abschlag/Rücklage · Clawback bei Refund | Commission-Engine (Owner Berechnung), Billing (Owner Trigger) | `payment_received` → `commission_calculation_triggered` · `refund_issued` → `commission_clawback_triggered` |
| **Billing ↔ Treuhand-Kunz** | Monats-Export · Bexio-CSV + Swissdec-ELM-Format · office@treuhand-kunz.ch | Billing (Owner), Treuhand-Kunz (Konsument extern) | Cron `treuhand-export-monthly` · Email-Notification + CSV-Attachment |
| **Billing ↔ Garantie-Schutzfrist** | Refund-Cockpit für Probezeit-Exits (Garantie 3 Mt) · Schutzfrist 12/16 Mt nicht im Billing-Scope | Billing (Owner Refund-Berechnung), CRM (Owner Schutzfrist-UI) | `fact_history: candidate_resigned/dismissed` → `refund_eligibility_check` |
| **Billing ↔ HR-Tool** | Praemium-Victoria-Provisions → Commission-Engine → Billing-Refund-Loop | HR (Owner Mitarbeiter-Vertrag), Billing (Owner Auszahlung-Trigger) | indirekt via Commission-Engine (siehe oben) |
| **Billing ↔ Performance-Modul** | Revenue-Forecast (Markov) → Billing-Aging-Reality (Closed-Loop) · `v_revenue_attribution` liest `fact_invoice` + `fact_payment` | Performance (Owner Forecast), Billing (Owner Realität) | Read-Only-View `ark_perf.v_revenue_attribution` und `mv_perf_revenue_monthly` (Performance-Patch v1.5) |

---

## 4. Strategische Entscheidungen

5 zentrale Architektur-Entscheidungen aus PO-Review-Batches 1–4 (siehe `wiki/meta/decisions.md` §2026-04-20).

### 4.1 Periodenabschluss-Lock zuerst (P0)

**Entscheidung:** Vor allen anderen Phase-3.B-Sub-Phasen wird MwSt-Quartals-Lock-Mechanismus implementiert.

**Begründung:**
- Revisionssicherheit (OR 958f, 10-Jahres-Aufbewahrung) erfordert manipulationssichere Periodenabschlüsse
- Buchhaltungs-Korrektheit gegenüber Treuhand-Kunz (kein nachträgliches Ändern fakturierter Beträge in geschlossener Periode)
- ESTV-MwSt-Quartalsabrechnung (60d nach Quartalsende, MWSTG Art. 35) erfordert eingefrorenen Datenbestand
- GF-Override-Pflicht bei Re-Open mit Audit-Log

**Implementierung:** `dim_invoice_status` zusätzliche Sub-States `period_locked` · GF-Approval für Re-Open · Audit-Trail in `fact_invoice_audit`.

### 4.2 Mahnwesen 4-Stufen-Konzept (segmentiert)

**Entscheidung:** 4 Eskalationsstufen — Soft-Reminder T+5 (optional), Mahnung 1, Mahnung 2, Mahnung 3 (mit Inkasso-Androhung). Nach Mahnung 3 + 5d → Inkasso-Eskalation (GF-Pflicht).

**Segmentierung:**
- **Standard-Kunden:** Mahnung 1/2/3 bei T+15 / T+30 / T+45
- **Key-Account-Kunden:** Mahnung 1/2/3 bei T+30 / T+45 / T+60

**Begründung:**
- AGB FEB 2023 §7 hat keine Verzugszins-/Mahngebühr-Klausel → MVP `interest_amount = 0`, `fee = 0`, vorbereitet für AGB-Revision
- OR Art. 102–109 erfordert Mahnung als konstitutiv für Verzug (5 % Zins greift erst nach Mahnung)
- Key-Account-Kadenz schützt langjährige Kunden-Beziehungen (Reputations-Risiko)

### 4.3 SIX-Konformität (QR-Rechnung IG v2.4)

**Entscheidung:** Billing-Go-Live nach 14.11.2026 (IG v2.4 Pflicht-Datum) → direkt v2.4-Format ohne Migration v2.3 → v2.4.

**Type-S-Adress-Compliance:** `dim_accounts.legal_street_name` / `legal_house_number` / `legal_post_code` / `legal_town_name` / `iso_country_code` separat NOT NULL. Kombinierte Free-Text-Adressen werden via Regex-Parser migriert.

**Begründung:**
- IG v2.3 ab 22.11.2025, IG v2.4 ab 14.11.2026 → Phase-3-Go-Live ohnehin nach v2.4-Datum
- Bank-Reject bei Type-S-Verletzung → Pre-Issue-Validator blockt Issue
- swissqrbill (schoero, NPM) v2.4-Support per GitHub-Release-Check vor Phase-3.B.1

### 4.4 AGB-Version-Tracking pro Rechnung

**Entscheidung:** Jede Rechnung hält ihre `template_version` (z.B. `agb-feb-2023`). Bei AGB-Revision → neue Template-Version, alte Rechnungen bleiben mit historischer AGB-Referenz reproduzierbar.

**Begründung:**
- Honorar-Staffel kann sich AGB-Revision-bedingt ändern (21/23/25/27 % AGB FEB 2023 vs. zukünftige Staffel)
- AGB-Referenz im Anschreiben-Text („gemäss AGB Ziffer 8") muss zur Rechnungs-Zeit gültiger AGB-Stand sein
- Verjährung 5J/10J → 10-Jahres-Reproduzierbarkeit der Rechnungen mit historischen Konditionen

**Implementierung:** `fact_template_versions` (Admin-Vollansicht v0.1 Tab 3) · `fact_invoice.template_version` Pflichtfeld · alte Versionen bleiben als `is_archived` aktiv.

### 4.5 AM-RLS-Sicht (eigene Mandate-Rechnungen, nicht Cross-Tenant)

**Entscheidung:** Account-Manager sieht im Billing nur eigene Mandate-Rechnungen via PostgreSQL-Row-Level-Security. Cross-AM-Sicht nur für GF / Backoffice.

**Begründung:**
- Commission-Transparenz: AM muss eigene Zahlungseingänge sehen (Provisions-Trigger), aber keine Konkurrenz-Daten
- Datenschutz: Kunden-Daten anderer AMs sind nicht für Account-Manager zugänglich
- RLS server-side (nicht App-Layer-Filter) → keine Bypass-Möglichkeit über direkte API-Calls

**Implementierung:** PostgreSQL-RLS-Policies auf `fact_invoice` / `fact_mandate` / `dim_accounts` · Frontend-RLS-Indikator-Chip in Liste-Header · siehe FE-Patch v1.14 §3.6.

---

## 5. Statistik

```
Billing ENUMs:               14 neue Dim-Tabellen (§91 Stammdaten)
Billing Tabellen:             8 neue Fact-Tabellen
Erweiterte Tabellen:          5 (dim_accounts, fact_mandate, fact_candidate_placement, dim_mitarbeiter, fact_template_versions)
Live-Views:                   5 (v_invoice_open · v_invoice_dunning_queue · v_mwst_quarter · v_customer_ledger · v_refund_clawback)
Default-Seeds:              ~120 Rows (alle dim_*-Kataloge)
Endpoints:                   ~50 (/api/v1/billing/*)
Worker:                      11 (6 event-driven + 5 cron)
Events:                      26 (M.1 Backend-Patch v2.7)
Sagas:                        1 (Refund-Issuance + Commission-Clawback, atomar)
Email-Templates:             16 (alle mit Sie/Du-Variante)
Drawer:                      10 (540px) + 1 Modal (420px)
Routes:                      11 Top-Level + 2 Sub-Routes
Mockup-Pages:                 9 (1 Hub + 8 Sub-Pages, ~80 % Reife)
Tabellen total v1.6:       ~248 (~225 v1.5 + 14 dim + 8 fact + Erweiterungen)
```

---

## 6. Phase-Roadmap-Update

### 6.1 Aktueller Stand (Phase 3 aktiv)

```
Phase 3.B.1 — Core · Best-Effort · MVP (P0)
  └─ Tabellen-Migration · Honorar-Staffel-Engine · QR-Bill-Library · Pre-Issue-Validator
Phase 3.B.2 — Mandat-Flow (3-Stage)
Phase 3.B.3 — Mahnwesen (segmentiert)
Phase 3.B.4 — Refund-Cockpit (Garantie-Staffel)
Phase 3.B.5 — Bank-Reconciliation (CAMT.054)
Phase 3.B.6 — MwSt + Treuhand-Export (Periodenabschluss-Lock-Pflicht in 3.B.1 → vorgezogen!)
Phase 3.B.7 — Gutschrift / Storno / Dispute
Phase 3.B.8 — Inkasso-Übergabe (SchKG-Ready)
Phase 3.B.9 — Schutzfrist-Bonus (selten · ad-hoc)
```

### 6.2 Phase 4 (vertagt)

- **Bexio-API-Integration** (bidirektionale Sync statt CSV-Export-only)
- **Treuhand-Anbindung erweitert** (Swissdec-ELM-Direkt-Integration über Datenfile-Push)
- **EBICS-API-Integration** (statt manueller CAMT.054-Upload · Trigger > 500 Rechnungen/Mt)

### 6.3 Phase 5 (vertagt)

- **Auto-MwSt-Quartalsabschluss** (statt manuelle ESTV-Einreichung)
- **Verzugszins-/Mahngebühr-Engine** (nach AGB-Revision FEB 2027 oder später)
- **EU-Kunden-Fakturierung** (Reverse-Charge · Feature-Flag `feature_eu_invoicing`)
- **Multi-Währung** (EUR / USD)
- **TWINT Business / Stripe-Integration**

---

## 7. Routing-Übersicht

```
Topbar-Toggle: CRM ↔ ERP

ERP-Workspace:
  /erp/zeit/*            → Zeit-Modul
  /erp/billing/*         → Billing-Modul (NEU v1.6)
    ├── /                Dashboard (KPIs + Aging)
    ├── /rechnungen      Rechnungs-Liste + :invoice_id Drawer
    ├── /mahnwesen       Mahnwesen-Cockpit (4-Spalten)
    ├── /debitoren       Debitoren-Liste + :customer_id Ledger
    ├── /zahlungen       Zahlungseingang (Match-Queue)
    ├── /refunds         Refund-Cockpit (Garantie)
    ├── /mwst            MwSt-Quartals-Abrechnung
    ├── /inkasso         Inkasso-Liste (SchKG)
    └── /export/treuhand Treuhand-Export (RO für externe Treuhand)
  /erp/elearn/*          → E-Learning-Modul
  /erp/hr/*              → HR-Modul
  /erp/performance/*     → Performance-Modul
```

Hub-Pattern (analog HR / Zeit / E-Learning / Performance): `mockups/ERP Tools/billing/billing.html` lädt Sub-Pages via iframe; Sub-Pages haben keine App-Bar.

---

## 8. Sync-Impact

| Grundlagen-Datei | Änderung | Quelle |
|------------------|----------|--------|
| `ARK_DATABASE_SCHEMA_v1_4.md` → v1.5 | bereits gemerged 2026-04-20 | DB-Patch v1.5 |
| `ARK_BACKEND_ARCHITECTURE_v2_6.md` → v2.7 | bereits gemerged 2026-04-20 | Backend-Patch v2.7 |
| `ARK_STAMMDATEN_EXPORT_v1_4.md` → v1.5 | bereits gemerged 2026-04-20 | Stammdaten-Patch v1.5 |
| `ARK_FRONTEND_FREEZE_v1_13.md` → v1.14 | NEU dieser Run (P1) | FE-Patch v1.14 Billing |
| `ARK_GESAMTSYSTEM_UEBERSICHT_v1_5.md` → v1.6 | NEU dieser Run (P2) | DIESER PATCH (TEIL 27) |
| `wiki/meta/spec-sync-regel.md` | Update Sync-Matrix | Billing 5/5 ✓ |
| `wiki/meta/mockup-baseline.md` §16 | UI-Label-Vocabulary | Billing-Status/Typ-Badges aus Interactions §11 |
| `wiki/meta/decisions.md` §2026-04-30 | NEU Eintrag | „Billing-Sync-Lücke geschlossen (3/5 → 5/5) · Audit-Befund 2026-04-30" |

---

## 9. Memory-Verweise

- `project_phase3_erp_standalone.md` — Billing als Phase-3-ERP-Modul (eigenständiges ARK-Produkt, Bexio nur Export-Ziel)
- `project_commission_model.md` — 80/20 Abschlag/Rücklage · Quartals-Payout · Clawback-Logik
- `project_guarantee_protection.md` — Garantie 3 Mt (Refund-Cockpit) vs. Schutzfrist 12/16 Mt (separates UI)
- `project_refund_model_routing.md` — Erfolgsbasis=Staffel · Mandat=Ersatz · Time=keine
- `reference_treuhand_kunz.md` — office@treuhand-kunz.ch · Bexio-CSV + Swissdec-ELM
- `feedback_phase3_modules_separate.md` — Billing-Hub-Page, kein CRM-Sidebar-Eintrag
- `feedback_claude_design_no_app_bar.md` — Sub-Pages haben keine App-Bar
- `feedback_peter_explanations_not_renames.md` — Sidebar „Finanzen" beibehalten

---

## 10. Acceptance Criteria

- [ ] TEIL 27 in `ARK_GESAMTSYSTEM_UEBERSICHT_v1_6.md` appendet
- [ ] Changelog-Eintrag „v1.6 (2026-04-30) · Billing-Modul Phase-3 v0.1" sichtbar
- [ ] Phase-3-ERP-Module-Liste zeigt Billing als „spec'd · ~80 % Mockup · 5/5 Sync"
- [ ] Cross-Module-Integration-Tabelle 7 Achsen dokumentiert
- [ ] 5 strategische Entscheidungen (Periodenabschluss-Lock · Mahnwesen 4-Stufen · SIX v2.4 · AGB-Tracking · AM-RLS) referenziert
- [ ] Statistik-Block (Tabellen / Endpoints / Worker / Events / Mockups) konsistent zu Plan + Schema + Interactions
- [ ] Phase-Roadmap (3.B.1–3.B.9 + Phase 4 + Phase 5) komplett
- [ ] Routing-Übersicht zeigt `/erp/billing/*` mit 9 Sub-Routes
- [ ] Sync-Impact-Tabelle dokumentiert alle 5 Patches (3 commited + 2 dieser Run)
- [ ] `wiki/meta/spec-sync-regel.md` Sync-Matrix Eintrag „Billing 5/5"
- [ ] `wiki/meta/decisions.md` §2026-04-30 Eintrag „Billing-Sync-Lücke geschlossen"

---

**Ende v1.6 · Billing.** Apply-Reihenfolge: DB v1.5 → Stammdaten v1.5 → Backend v2.7 → FE v1.14 → Gesamtsystem v1.6 (dieser Patch).
Schließt Billing-Sync-Lücke (ERP-Audit 2026-04-30): 3/5 → **5/5 Grundlagen-Patches komplett**.
