---
title: "ARK Gesamtsystem-Übersicht · Patch v1.6 → v1.7 · Zeit-Modul"
type: patch
phase: 3
created: 2026-04-30
updated: 2026-04-30
status: draft
sources: [
  "Grundlagen MD/ARK_GESAMTSYSTEM_UEBERSICHT_v1_6.md",
  "specs/ARK_ZEIT_SCHEMA_v0_1.md",
  "specs/ARK_ZEIT_INTERACTIONS_v0_1.md",
  "specs/ARK_ZEITERFASSUNG_PLAN_v0_1.md",
  "specs/ARK_DATABASE_SCHEMA_PATCH_v1_8_to_v1_9_zeit.md",
  "specs/ARK_STAMMDATEN_PATCH_v1_7_to_v1_8_zeit.md",
  "specs/ARK_FRONTEND_FREEZE_PATCH_v1_15_to_v1_16_zeit.md",
  "memory/project_zeit_modul_architecture.md",
  "memory/feedback_zeit_stempel_modell.md",
  "memory/project_activity_linking.md",
  "wiki/meta/zeit-decisions-2026-04-19.md"
]
target: "Grundlagen MD/ARK_GESAMTSYSTEM_UEBERSICHT_v1_6.md → v1.7 (TEIL 28 + Changelog-Eintrag)"
tags: [gesamtsystem, patch, zeit, phase-3, cross-modul, scanner-first, dsg, arg, decisions]
---

# ARK Gesamtsystem-Patch v1.6 → v1.7 · Zeit-Modul

**Stand:** 2026-04-30
**Status:** Draft · ergänzend zu Billing-Modul-Patch v1.5 → v1.6 (TEIL 27)
**Append-Ziel:** TEIL 28 in `Grundlagen MD/ARK_GESAMTSYSTEM_UEBERSICHT_v1_7.md`.

**Note:** HR-Patch wird heute parallel committed, hat aber **keinen** eigenen Gesamtsystem-Patch (HR-Module-Übersicht bleibt in TEIL 25 dokumentiert). Daher ist v1.7 **dedicated für Zeit-Modul**.

---

## 0. ZIELBILD

Big-Picture-Sync für Zeit-Modul Phase-3 v0.1. Changelog-Eintrag „v1.7 Zeit-Modul Phase-3 v0.1", Phase-3-ERP-Module-Liste-Update (Zeit als spec'd · 10 Mockups · 5/5 Sync), Cross-Module-Integration-Tabelle (4 Achsen), 4 strategische Entscheidungen, Phase-Roadmap-Update.

---

## 1. Changelog-Eintrag

```markdown
## v1.7 (2026-04-30) · Zeit-Modul Phase-3 v0.1

**Author:** PW
**Sources:**
- specs/ARK_ZEIT_SCHEMA_v0_1.md
- specs/ARK_ZEIT_INTERACTIONS_v0_1.md
- specs/ARK_ZEITERFASSUNG_PLAN_v0_1.md

**Grundlagen-Patches in diesem Set (5/5 komplett):**
- DB-Schema v1.8 → v1.9 (`ARK_DATABASE_SCHEMA_PATCH_v1_8_to_v1_9_zeit.md`, commit 2026-04-30 · DIESER RUN)
- Stammdaten v1.7 → v1.8 (`ARK_STAMMDATEN_PATCH_v1_7_to_v1_8_zeit.md`, commit 2026-04-30 · DIESER RUN)
- Backend-Architecture v2.5 → v2.6 (committed 2026-04-19 · `ARK_BACKEND_ARCHITECTURE_v2_6.md` enthält bereits Scanner-Endpoints + Worker · keine separate Backend-Sync nötig)
- Frontend-Freeze v1.15 → v1.16 (`ARK_FRONTEND_FREEZE_PATCH_v1_15_to_v1_16_zeit.md`, commit 2026-04-30 · DIESER RUN)
- Gesamtsystem v1.6 → v1.7 (DIESER PATCH, commit 2026-04-30)

**Zentrale Deltas v0.1 → v0.2 (Mockup-Iteration 2026-04-19 → 2026-04-30):**
- Rollen-Rename TL → Head of · GF/Founder → Admin (4 Rollen statt 5)
- Stempel-Antrag-Modell radikal simplifiziert: Single-Event statt Zeit-Block (8 Grund-Codes)
- Kategorie-Zuordnung aus Tages-Eintrag-Drawer entfernt (ZEG via v_time_per_mandate)
- Lohn-abgegolten-Policy für OR-Überstunden + ArG-Überzeit (Arkadium-Vertragsklausel)
- Stellvertreter-Pflicht bei Ferien ≥3 Tagen (Reglement Tempus Passio §2)
- Wochen-Check-Tab entfernt · Team-Approvals-Tabs reduziert von 4 auf 3
- MA-Verträge komplett in HR (Zeit-Admin reduziert auf Modelle/FT/73b/Korrekturen)

**Audit-Befund 2026-04-30:** Zeit hatte 0/5 Sync-Patches (Spec ohne Grundlagen-Sync) → mit DB v1.9 + Stammdaten v1.8 + FE v1.16 + Gesamtsystem v1.7 jetzt **5/5 komplett** (Backend bereits in v2.6 committed).
```

---

## 2. Phase-3-ERP-Module-Liste-Update

Ergänzung zu `ARK_GESAMTSYSTEM_UEBERSICHT_v1_6.md` Phase-3-ERP-Übersicht.

### 2.1 Modul-Status (Stand 2026-04-30)

| Modul | Spec-Status | Mockup-Reife | Grundlagen-Sync | Phase |
|-------|-------------|--------------|-----------------|-------|
| **Zeit** | **spec'd v0.1** | **~85% (10 Mockups)** | **5/5 (NEU dieser Patch)** | **Phase 3 aktiv** |
| HR | spec'd | ~85% | 5/5 (Patches heute parallel) | Phase 3 aktiv |
| Performance | spec'd | ~75% | 5/5 (TEIL 26 v1.5) | Phase 3 aktiv |
| E-Learning | spec'd | ~70% | 5/5 | Phase 3 aktiv |
| Billing | spec'd v0.1 | ~80% | 5/5 (TEIL 27 v1.6) | Phase 3 aktiv |
| Commission-Engine | spec'd v0.1 | n/a (Engine, kein UI) | 4/5 (FE entfällt) | Phase 3 aktiv |
| Email & Kalender | spec'd v0.1 | ~85% | 5/5 | Phase 2/3 aktiv |
| Reminders-Vollansicht | spec'd v0.1 | ~80% | 5/5 | Phase 1-A aktiv |
| Stammdaten-Vollansicht | spec'd v0.1 | ~75% | 5/5 (Phase-1-A v1.14) | Phase 1-A aktiv |

### 2.2 Zeit-Modul-Inventar Phase 1

```
mockups/ERP Tools/zeit/
  zeit.html                ← Hub (Snapshot-Bar + Sidebar-Tree „Zeiterfassung")
  zeit-dashboard.html      ← /zeit/dashboard (Hero-KPIs · Wochen-Grid · Alerts)
  zeit-meine-zeit.html     ← /zeit/meine-zeit (Wochen-Raster · Tages-Karten)
  zeit-monat.html          ← /zeit/monat/:period (Tabelle Tag/Soll/Ist · Submit-Modal)
  zeit-abwesenheiten.html  ← /zeit/abwesenheiten (Heatmap-Calendar Team-Grid)
  zeit-team.html           ← /zeit/team (3 Tabs · Stempel-Anträge · Monats · Saldi)
  zeit-saldi.html          ← /zeit/saldi (4 Karten · Ferien · OR · ArG · Extra)
  zeit-export.html         ← /zeit/export (Treuhand-Export-Generator)
  zeit-admin.html          ← /zeit/admin (4 Sub-Tabs · Modelle · FT · 73b · Korrekturen)
  zeit-list.html           ← Legacy Phase-1 Fallback (nicht aktiv in Sidebar)
```

**Inventar-Stand:** 10 Mockups (1 Hub + 8 aktive Sub-Pages + 1 Legacy-Fallback). Mockup-Realisierungs-Status per Plan §6.3:
- Cross-Modul-Funktionen integriert: Approvals → `zeit-team.html`, Time-Mandat-Billing → `billing/billing-rechnungen.html` (Domain-Owner Billing), Biometrie-Admin → `zeit-admin.html`
- Mobile-Responsive direkt in existierenden Mockups (kein separates `zeit-mobile.html`)
- ggf. dediziertes `zeit-reports.html` für Profit-per-Mandate-Analytics — überlappt mit Performance-Modul → Phase-3.2-Entscheidung offen

---

## 3. Cross-Module-Integration

Zeit ist zentrales Operations-Modul und integriert mit 4 anderen Modulen. Tabelle dokumentiert Pattern + Domain-Owner.

| Cross-Module | Pattern | Domain-Owner | Event/Sync-Schnittstelle |
|--------------|---------|--------------|--------------------------|
| **Zeit ↔ HR** | Mitarbeiter-Stammdaten · Pensum · Vertragsdaten · Direct-Supervisor (für RLS Head-of-Scope) | HR (Owner Stammdaten + Pensum), Zeit (Konsument für Soll-Stunden) | `fact_workday_target.employment_contract_id` FK auf `fact_employment_contracts` · Worker `pensum-sync` synct Pensum-Änderungen nightly |
| **Zeit ↔ Billing** | Time-Mandat-Rechnungs-Trigger · Wochen-Aggregat → Monats-Rechnung · Cross-Modul-Pattern (Billing ist Domain-Owner für Rechnungs-Erstellung) | Billing (Owner Rechnungs-Logik), Zeit (Datenlieferant) | Cron `time-mandate-monthly-invoice` · Worker liest `v_time_per_mandate WHERE category='mandate_time' AND week_status='locked'`, schreibt Rechnung in Billing-Modul |
| **Zeit ↔ Performance** | Utilization-KPIs · `time_utilization_pct` (Performance-Metric `time_utilization_pct`, Stammdaten-Patch v1.5 §2.5) liest aus `v_zeit_utilization` (Performance-Modul-Synonym für `v_monthly_saldo`) | Performance (Owner KPI-Berechnung), Zeit (Datenlieferant) | Read-Only-View `ark_perf.v_zeit_utilization` (Performance-Patch v1.5 §6) · Refresh daily 02:00 UTC |
| **Zeit ↔ Stammdaten** | Abwesenheits-Typen · Zeit-Kategorien · Korrektur-Gründe · Activity-Types-Erweiterung (5 neue „Zeit-Touchpoints") | Stammdaten (Owner Kataloge), Zeit (Konsument) | Direct-FKs: `dim_absence_type` · `dim_time_category` · `dim_work_time_model` · `dim_time_correction_reason` · `dim_activity_types` |

**Indirect-Achse Zeit ↔ Commission-Engine:** Über `v_time_per_mandate.zeg_relevant_min` füttert Zeit-Modul die ZEG-Staffel-Berechnung in Commission-Engine. Commission-Engine ist Domain-Owner für ZEG-Logic; Zeit liefert nur Aggregat-Daten. Trigger: Event `time_entry.locked.v1` bei `entry_state → locked` UND `project_id IS NOT NULL` (DB-Patch v1.9 §8.1).

---

## 4. Strategische Entscheidungen

4 zentrale Architektur-Entscheidungen aus PO-Review-Iteration 2026-04-19 + 2026-04-30 (siehe `wiki/meta/zeit-decisions-2026-04-19.md`).

### 4.1 Scanner-First-Pattern (F1)

**Entscheidung:** Primäre Erfassungsmethode ist Fingerabdruck-Scanner (Mobatime AMG / ZKTeco IClock evaluiert · Hardware-Auswahl Phase 3.3). Manuelle Erfassung nur Edge-Case (Home-Office, Scanner-Defekt, vergessene Scans).

**Begründung:**
- ArG Art. 46 + ArGV 1 Art. 73 erfordern lückenlose Arbeitszeit-Dokumentation (nicht Vertrauensarbeit-only)
- Manuelle Erfassung skaliert nicht über 10+ MA · Friction in Daily-Workflow
- Scanner-Aggregator-Worker generiert `fact_time_entry` automatisch nightly · MA muss nur Submit klicken
- Scanner-Roh-Daten getrennt von Aggregat (`fact_time_scan_event` vs. `fact_time_entry`) für DSG-Audit

**Implementierung:** Worker `scan-event-processor` (Backend-Patch v2.6 committed) · DB-Schema mit `time_entry_source` Enum · UI mit Scanner-Events read-only in Tages-Eintrag-Drawer.

### 4.2 Stempel-Antrag-Workflow (Single-Event-Modell · Delta v0.2)

**Entscheidung:** Manueller Zeit-Eintrag radikal simplifiziert von Block-Erfassung (Datum + Von/Bis + Pause + Kategorie + Projekt + Verrechenbar + Grund) auf Single-Scanner-Stempel-Event (Datum + Uhrzeit + Auto-Detect-Typ + Grund-Dropdown).

**Begründung:**
- Friction-Reduction: 7 Felder → 3 Felder · 70% schneller
- Konsistenz mit Scanner-Modell (alle Events sind Scanner-äquivalent)
- Grund als 8-Code-Dropdown (`home_office` · `remote_work` · `scanner_defect` · `forgotten_scan` · `external_appointment` · `early_leave` · `late_arrival` · `other`) statt freitext → strukturierte Reports
- Kategorie-Zuordnung entfällt im UI (ZEG via `v_time_per_mandate` direkt aus Aggregator-Default)

**Implementierung:** Stempel-Antrag-Drawer mit auto-detect Typ-Logic basierend auf Tages-Scan-Folge. Manueller Override-Toggle für Edge-Cases. Memory `feedback_zeit_stempel_modell.md`.

### 4.3 73b-DSG-Compliance (DSG-besondere-PD + ArGV 1 Art. 73b)

**Entscheidung:** Drei DSG-/ArG-Compliance-Layer parallel:

1. **revDSG Art. 5 Ziff. 4 (biometrische Daten):** Template-Hash NIE in DB · nur abgeleitete `fact_time_scan_event` · separate Audit-Tabelle `fact_scanner_access_audit` mit 10J Retention · Banner in Admin/Team-UI bei jedem Scanner-Daten-Read.
2. **ArGV 1 Art. 73b (vereinfachte Erfassung):** Eigenes Work-Time-Model `SIMPLIFIED_73B` · `fact_simplified_agreement` mit kollektiver/individueller Vereinbarung · jährliches Endgespräch · PDF-Pflicht.
3. **revDSG Art. 5 Ziff. 2 (medizinische Daten):** Arztzeugnis-Files separate Aufbewahrung · 5J Retention post Abwesenheits-Ende · nur in Detail-Drawer für Berechtigte sichtbar (eigene + Direct-Supervisor) · NICHT im Heatmap-Calendar-Grid.

**Begründung:**
- Datenschutz-Folgeabschätzung (DSFA) Pflicht bei Biometrie-System (revDSG Art. 22)
- Nachweispflicht gegenüber Datenschutzbeauftragten + Seco-Kontrolle
- Beweislast-Mitigation bei DSG-Klagen (10J append-only audit_trail_jsonb)

**Implementierung:** DB-Patch v1.9 §10 Retention-Tabelle · FE-Patch v1.16 §3.5 Scanner-Audit-Banner · Worker `retention.worker.ts` (bestehend) erweitert um Zeit-Cleanup.

### 4.4 Lohn-abgegolten-Policy + Multi-Tenant-Variation

**Entscheidung:** Bei Arkadium sind OR-Überstunden + ArG-Überzeit mit Grundlohn abgegolten (Vertragsklausel). **Keine** Auszahlung. **Keine** Kompensation. `fact_overtime_balance` bleibt als reines Tracking für ArG-Compliance (170h-Jahres-Cap-Warning).

**Multi-Tenant-Konfiguration:** `firm_settings.overtime_compensation_policy` mit 4 Werten:

| Tenant | Policy | Verhalten |
|--------|--------|-----------|
| Arkadium | `paid_with_salary` | Tracking only · UI-Info-Chip „Lohn-abgegolten" · keine Action-Buttons |
| Standard-KMU | `time_off` | Klassischer Zeitausgleich · Action-Button „Kompensation beantragen" |
| Beratung-Time-based | `pay_25pct` | 125%-Auszahlung über 50h-Schwelle |
| Hybrid | `hybrid` | Mix aus Time-off + Auszahlung · konfigurierbar pro MA |

**Begründung:**
- Arkadium-Vertragsklausel rechtskonform (BGE 4A_227/2017 · OR Art. 321c Abs. 2)
- ArG-Compliance bleibt erhalten (Jahres-Cap-Tracking pflicht trotz Lohn-Abgeltung)
- Schema multi-tenant-fähig für spätere Vermarktung an andere Headhunting/Beratungs-Firmen

**Implementierung:** Saldi-OR-Karte zeigt Info-Chip statt Action-Buttons (FE-Patch §3.3) · ArG-Karte mit 90%-Cap-Warning · Worker `overtime-cap-monitor` daily.

---

## 5. Statistik

```
Zeit ENUMs:                   9 neue PostgreSQL-Types
Zeit Tabellen:               14 neue (3 dim_* + 11 fact_*) + firm_settings
Erweiterte Tabellen:          1 (dim_user via HR-Patch · direct_supervisor_id)
Live-Views:                   4 (v_daily_saldo · v_monthly_saldo · v_time_per_mandate · v_weekly_approval_queue)
GIST-Constraints:             2 (Time-Entry-Overlap + Absence-Overlap)
Default-Seeds:               87 Rows (30 Absence-Types + 12 Categories + 5 Models + 18 Skalen + 12 Feiertage + 8 Korrektur-Gründe + 22 firm_settings + 5 Activity-Types)
Endpoints:                   ~12 (/api/zeit/* · in v2.6 committed)
Worker:                       3 (scan-event-processor · doctor-cert-reminder · overtime-cap-monitor)
Events:                       6 (time_entry.locked.v1 · absence_approved.v1 · period_close_locked.v1 · correction_requested.v1 · scan_event_processed.v1 · biometric_revoked.v1)
Drawer:                       5 (540px) + 2 Modals (420px)
Routes:                      10 Top-Level (1 Hub + 9 Sub-Pages)
Mockup-Pages:                10 (1 Hub + 8 active + 1 Legacy-Fallback · ~85% Reife)
Tabellen total v1.7:        ~262 (~248 v1.6 + 14 Zeit)
RLS-Policies:                36 (4 pro RLS-aktivierter Tabelle × 9 Tabellen)
```

---

## 6. Phase-Roadmap-Update

### 6.1 Aktueller Stand (Phase 3 aktiv)

```
Phase 3.0 — Fundament (Zeit-Modul · Kern-Tabellen + manuelle Erfassung)
  └─ DB-Migration v1.9 · Stammdaten v1.8 · UI Phase-1 (10 Mockups · ~85%)

Phase 3.1 — Billing-Integration (Time-Mandat-Rechnungs-Trigger)
  └─ Cross-Modul: Billing-Modul (TEIL 27 v1.6 · `billing-rechnungen.html`)

Phase 3.2 — Überstunden + Reports
  └─ `fact_overtime_balance` Snapshots monatlich · Lohn-abgegolten-Pattern · ZEG-Feed via v_time_per_mandate
  └─ ggf. dediziertes `zeit-reports.html` für Profit-per-Mandate (überlappt Performance-Modul · Entscheidung offen)

Phase 3.3 — Biometrie (Scanner-Hardware)
  └─ Mobatime AMG vs. ZKTeco IClock vs. Suprema BioStation (3-Weg-Evaluation)
  └─ DSFA-Dokument · DSG-Rechts-Review · Enrollment-Termine HR

Phase 3.4 — Kalender-Sync + UX-Polish (optional)
  └─ Outlook-Events → Buchungs-Vorschläge (nutzt OAuth-Token aus Email-Modul)
  └─ Template-Woche-Kopieren · Inline-Edit im Grid
```

### 6.2 Phase 4 (vertagt)

- **ELM 5.0 XML-Direkt-Push** (statt Bexio-CSV-Export) · Swissdec-ELM-Direkt-Integration über Datenfile-Push
- **Auto-Pensum-Sync HR↔Zeit** (statt nightly Worker · Real-Time via Event-Stream)
- **Multi-Standort-Scanner** (Basel/Winterthur · falls Remote-Office expansion)

### 6.3 Phase 5 (vertagt)

- **Mobile-PWA-Stempel-Funktion** (separate Mobile-App für Field-Worker · Geofencing-optional)
- **AI-basierte Zeit-Vorschläge** (basierend auf Outlook + CRM-History · Auto-Vorschlag pro Tag)
- **EU-Tenant-Variante** (deutsches Arbeitszeitgesetz · andere Pausen-/Ruhezeit-Regeln)

---

## 7. Routing-Übersicht

```
Topbar-Toggle: CRM ↔ ERP

ERP-Workspace:
  /erp/zeit/*            → Zeit-Modul (NEU v1.7)
    ├── /                Hub (Sidebar-Tree „Zeiterfassung")
    ├── /dashboard       Dashboard (Hero-KPIs · Wochen-Grid · Alerts)
    ├── /meine-zeit      Wochen-Raster (Tages-Karten · inline-Edit)
    ├── /monat/:period   Monats-Übersicht (Tabelle · Submit-Modal)
    ├── /abwesenheiten   Heatmap-Calendar (Team-Grid · DSG-gefiltert)
    ├── /team            Team-Approvals (3 Tabs · Stempel · Monats · Saldi)
    ├── /saldi           4 Karten (Ferien · OR · ArG · Extra)
    ├── /export          Treuhand-Export-Generator (Bexio-CSV)
    └── /admin           4 Sub-Tabs (Modelle · FT · 73b · Korrekturen)
  /erp/billing/*         → Billing-Modul
  /erp/elearn/*          → E-Learning-Modul
  /erp/hr/*              → HR-Modul
  /erp/performance/*     → Performance-Modul
```

Hub-Pattern (analog HR / Billing / E-Learning / Performance): `mockups/ERP Tools/zeit/zeit.html` lädt Sub-Pages via iframe; Sub-Pages haben keine App-Bar (Memory `feedback_claude_design_no_app_bar.md`).

---

## 8. Sync-Impact

| Grundlagen-Datei | Änderung | Quelle |
|------------------|----------|--------|
| `ARK_DATABASE_SCHEMA_v1_8.md` → v1.9 | NEU dieser Run (P1) | DB-Patch v1.9 Zeit |
| `ARK_BACKEND_ARCHITECTURE_v2_5.md` → v2.6 | bereits committed 2026-04-19 | Backend v2.6 Z. (Scanner-Endpoints + Worker) |
| `ARK_STAMMDATEN_EXPORT_v1_7.md` → v1.8 | NEU dieser Run (P2) | Stammdaten-Patch v1.8 Zeit |
| `ARK_FRONTEND_FREEZE_v1_15.md` → v1.16 | NEU dieser Run (P3) | FE-Patch v1.16 Zeit |
| `ARK_GESAMTSYSTEM_UEBERSICHT_v1_6.md` → v1.7 | NEU dieser Run (P4) | DIESER PATCH (TEIL 28) |
| `wiki/meta/spec-sync-regel.md` | Update Sync-Matrix | Zeit 5/5 ✓ |
| `wiki/meta/mockup-baseline.md` §16 | UI-Label-Vocabulary | Zeit-Status/Typ-Badges aus Stammdaten-Patch §9 |
| `wiki/meta/decisions.md` §2026-04-30 | NEU Eintrag | „Zeit-Sync-Lücke geschlossen (0/5 → 5/5) · 4 strategische Entscheidungen dokumentiert" |

---

## 9. Memory-Verweise

- `project_zeit_modul_architecture.md` — Scanner-First · Role-Rename TL→Head/GF→Admin · Lohn-abgegolten-Policy · HR-Zeit-Trennung · PR #2
- `feedback_zeit_stempel_modell.md` — Single-Event-Modell · Stempel-Antrag mit 8 Grund-Codes · Friction-Reduction
- `project_activity_linking.md` — UI-Felder linken auf `fact_history`-Events · 5 neue Zeit-Touchpoints-Activity-Types
- `feedback_phase3_modules_separate.md` — Zeit-Hub-Page eigenständig, nicht in CRM-Sidebar
- `feedback_claude_design_no_app_bar.md` — Sub-Pages ohne App-Bar (Hub-Topbar liefert das)
- `reference_treuhand_kunz.md` — `office@treuhand-kunz.ch` · Bexio-CSV + Swissdec-ELM · Export-Cutoff Tag 25
- `project_phase3_erp_standalone.md` — Zeit als Phase-3-ERP-Modul (eigenständiges ARK-Produkt, Bexio nur Export-Ziel)
- `feedback_worktree_sync_main.md` — jeden Edit parallel nach `C:\Projects\Ark_CRM\` syncen
- `project_arkadium_role.md` — Arkadium = Headhunting-Boutique · Rollen-Definition

---

## 10. Acceptance Criteria

- [ ] TEIL 28 in `ARK_GESAMTSYSTEM_UEBERSICHT_v1_7.md` appendet
- [ ] Changelog-Eintrag „v1.7 (2026-04-30) · Zeit-Modul Phase-3 v0.1" sichtbar
- [ ] Phase-3-ERP-Module-Liste zeigt Zeit als „spec'd · 10 Mockups · 5/5 Sync"
- [ ] Cross-Module-Integration-Tabelle 4 Achsen (HR / Billing / Performance / Stammdaten) dokumentiert
- [ ] 4 strategische Entscheidungen (Scanner-First · Stempel-Antrag · 73b-DSG · Lohn-abgegolten) referenziert
- [ ] Statistik-Block (Tabellen / Endpoints / Worker / Events / Mockups / RLS) konsistent zu DB v1.9 + FE v1.16
- [ ] Phase-Roadmap (3.0–3.4 + Phase 4 + Phase 5) komplett
- [ ] Routing-Übersicht zeigt `/erp/zeit/*` mit 9 Sub-Routes
- [ ] Sync-Impact-Tabelle dokumentiert alle 5 Patches (4 dieser Run + 1 vorhin committed)
- [ ] `wiki/meta/spec-sync-regel.md` Sync-Matrix-Eintrag „Zeit 5/5"
- [ ] `wiki/meta/decisions.md` §2026-04-30 Eintrag „Zeit-Sync-Lücke geschlossen"
- [ ] Indirect-Achse Zeit ↔ Commission-Engine via `v_time_per_mandate.zeg_relevant_min` dokumentiert

---

**Ende v1.7 · Zeit.** Apply-Reihenfolge: DB v1.9 → Stammdaten v1.8 → Backend v2.6 (bereits committed) → FE v1.16 → Gesamtsystem v1.7 (dieser Patch).
Schließt Zeit-Sync-Lücke (ERP-Audit 2026-04-30): 0/5 → **5/5 Grundlagen-Patches komplett**.
