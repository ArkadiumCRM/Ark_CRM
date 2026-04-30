---
title: "ARK Gesamtsystem-Übersicht · Patch v1.7 → v1.8 · HR-Modul"
type: patch
phase: 3
created: 2026-04-30
updated: 2026-04-30
status: draft
sources: [
  "Grundlagen MD/ARK_GESAMTSYSTEM_UEBERSICHT_v1_5.md",
  "specs/ARK_DATABASE_SCHEMA_PATCH_v1_7_to_v1_8_hr.md",
  "specs/ARK_BACKEND_ARCHITECTURE_PATCH_v2_9_to_v2_10_hr.md",
  "specs/ARK_STAMMDATEN_PATCH_v1_6_to_v1_7_hr.md",
  "specs/ARK_FRONTEND_FREEZE_PATCH_v1_14_to_v1_15_hr.md",
  "specs/ARK_HR_TOOL_SCHEMA_PATCH_v0_1_to_v0_2.md",
  "wiki/meta/drift-log.md"
]
target: "Grundlagen MD/ARK_GESAMTSYSTEM_UEBERSICHT_v1_7.md → v1.8 (TEIL 29 + Changelog-Eintrag)"
tags: [gesamtsystem, patch, hr, phase-3, cross-modul, onboarding, disciplinary, probezeit, decisions]
---

# ARK Gesamtsystem-Patch v1.7 → v1.8 · HR-Modul

**Stand:** 2026-04-30
**Status:** Draft · schließt HR-Sync-Lücke (5/5 → 6/6 inkl. Gesamtsystem)
**Append-Ziel:** TEIL 29 in `Grundlagen MD/ARK_GESAMTSYSTEM_UEBERSICHT_v1_8.md`.

**Kontext:** Heute (2026-04-30) wurden 8 Grundlagen-Sync-Patches committed (HR + Zeit). Der Zeit-Modul-Patch v1.6 → v1.7 schrieb TEIL 28. Dieser Patch v1.7 → v1.8 ist der Gesamtsystem-Abschluss für das HR-Modul (TEIL 29). HR hatte vorher 0/5 Grundlagen-Sync; die 4 Sub-Patches (DB · Backend · Stammdaten · FE) plus dieser Patch schließen den Gap auf 5/5 (+ Gesamtsystem = 6/6).

---

## 0. ZIELBILD

Big-Picture-Sync für HR-Modul Phase-3 v0.2. Changelog-Eintrag „v1.8 (2026-04-30) · HR-Modul Phase-3 v0.2", Phase-3-ERP-Module-Liste-Update (HR als spec'd · ~85% Reife · 8 Mockups · 5/5 Sync), Cross-Module-Integration-Tabelle (6 Achsen), 5 strategische Entscheidungen, Phase-Roadmap-Update (3.HR.0 – 3.HR.4), Routing-Übersicht `/erp/hr/*`.

---

## 1. Changelog-Eintrag

```markdown
## v1.8 (2026-04-30) · HR-Modul Phase-3 v0.2

**Author:** PW
**Sources:**
- specs/ARK_HR_TOOL_SCHEMA_v0_2.md
- specs/ARK_HR_TOOL_INTERACTIONS_v0_1.md
- specs/ARK_HR_TOOL_PLAN_v0_2.md

**Grundlagen-Patches in diesem Set (5/5 komplett):**
- DB-Schema v1.7 → v1.8 (`ARK_DATABASE_SCHEMA_PATCH_v1_7_to_v1_8_hr.md`, commit 2026-04-30 · DIESER RUN)
- Backend-Architecture v2.9 → v2.10 (`ARK_BACKEND_ARCHITECTURE_PATCH_v2_9_to_v2_10_hr.md`, commit 2026-04-30 · DIESER RUN)
- Stammdaten v1.6 → v1.7 (`ARK_STAMMDATEN_PATCH_v1_6_to_v1_7_hr.md`, commit 2026-04-30 · DIESER RUN)
- Frontend-Freeze v1.14 → v1.15 (`ARK_FRONTEND_FREEZE_PATCH_v1_14_to_v1_15_hr.md`, commit 2026-04-30 · DIESER RUN)
- Gesamtsystem v1.7 → v1.8 (DIESER PATCH, commit 2026-04-30)

**Interner Spec-Patch:**
- `specs/ARK_HR_TOOL_SCHEMA_PATCH_v0_1_to_v0_2.md` (v0.1 → v0.2 Schema-Konsolidierung)

**Zentrale Deltas v0.1 → v0.2 (Spec-Iteration → Grundlagen-Sync 2026-04-30):**
- 10 neue ENUM-Types (contract_state · employment_type · termination_reason · hr_doc_state ·
  probation_milestone_type · disciplinary_level · disciplinary_state · onboarding_state ·
  onboarding_task_state · onboarding_assignee_role)
- 3 Dimension-Tabellen mit 44 Seeds (dim_hr_document_type · dim_disciplinary_offense_type ·
  dim_onboarding_task_template_type)
- 8 Fact-Tabellen (employment_contracts · employment_attachments · disciplinary_records ·
  probation_milestones · onboarding_templates · onboarding_template_tasks ·
  onboarding_instances · onboarding_instance_tasks)
- 29 REST-Endpoints in 6 Gruppen, 4 Worker, 16 Events
- 11 Drawer (540px), 10 Routen, 7-Eintrag-Sidebar „Personal"
- 62 neue Stammdaten-Einträge + 7 Activity-Types Kategorie 12 `hr`
- Performance-Reviews-Migration: Review-Zyklen vollständig ins HR-Modul migriert
  (Performance-Modul bleibt Cross-Modul-Analytics-Hub ohne eigene Review-CRUD-Flows)

**Audit-Befund 2026-04-30:** HR hatte 0/5 Sync-Patches (interne Spec vorhanden, kein Grundlagen-Sync).
→ Mit DB v1.8 + Backend v2.10 + Stammdaten v1.7 + FE v1.15 + Gesamtsystem v1.8 jetzt **5/5 komplett**.
```

---

## 2. Phase-3-ERP-Module-Liste-Update

Ergänzung zu `ARK_GESAMTSYSTEM_UEBERSICHT_v1_7.md` (Stand nach TEIL 28 Zeit-Patch) Phase-3-ERP-Übersicht.

### 2.1 Modul-Status (Stand 2026-04-30)

| Modul | Spec-Status | Mockup-Reife | Grundlagen-Sync | Phase |
|-------|-------------|--------------|-----------------|-------|
| **HR** | **spec'd v0.2** | **~85% (8 Mockups)** | **5/5 (NEU dieser Patch)** | **Phase 3 aktiv** |
| Zeit | spec'd v0.1 | ~85% (10 Mockups) | 5/5 (TEIL 28 v1.7) | Phase 3 aktiv |
| Performance | spec'd | ~75% | 5/5 (TEIL 26 v1.5) | Phase 3 aktiv |
| E-Learning | spec'd | ~70% | 5/5 | Phase 3 aktiv |
| Billing | spec'd v0.1 | ~80% | 5/5 (TEIL 27 v1.6) | Phase 3 aktiv |
| Commission-Engine | spec'd v0.1 | n/a (Engine, kein UI) | 4/5 (FE entfällt) | Phase 3 aktiv |
| Email & Kalender | spec'd v0.1 | ~85% | 5/5 | Phase 2/3 aktiv |
| Reminders-Vollansicht | spec'd v0.1 | ~80% | 5/5 | Phase 1-A aktiv |
| Stammdaten-Vollansicht | spec'd v0.1 | ~75% | 5/5 (Phase-1-A v1.14) | Phase 1-A aktiv |

**Hinweis Performance-Reviews:** Die ursprünglich im Performance-Modul geplanten HR-Review-Zyklen
(Jahresgespräch, Zielvereinbarung) wurden ins HR-Modul migriert. Performance bleibt
Cross-Modul-Analytics-Hub (KPIs, Utilization, ZEG-Auswertung). Details: §4.4.

### 2.2 HR-Modul-Inventar Phase 1

```
mockups/ERP Tools/hr/
  hr.html                          ← Hub (Sidebar-Tree „Personal")
  hr-dashboard.html                ← /erp/hr/dashboard (KPI-Strip · Alert-Banner · Team-Übersicht)
  hr-list.html                     ← /erp/hr/list (Mitarbeiterliste · Compliance-Matrix)
  hr-mitarbeiter-self.html         ← /erp/hr/self (Self-Service · eigenes Profil + Dokumente)
  hr-warnings-disciplinary.html    ← /erp/hr/disciplinary (Verwarnungen & Disziplinar)
  hr-onboarding-editor.html        ← /erp/hr/onboarding (Onboarding-Editor + Template-Verwaltung)
  hr-provisionsvertrag-editor.html ← /erp/hr/provisions (Praemium-Victoria-Editor · Admin-only)
  hr-academy-dashboard.html        ← /erp/hr/academy (E-Learning-Auswertung · Academy-Bridge)
```

**Inventar-Stand:** 8 Mockups (1 Hub + 7 Sub-Pages · ~85% Reife). Abwesenheits-Kalender
bewusst nicht im HR-Modul — gehört zu Zeit-Modul (`/erp/zeit/abwesenheiten`). HR zeigt nur
Absenz-Summary-KPIs via Zeit-API (Domain-Owner-Prinzip).

---

## 3. Cross-Module-Integration

HR ist zentrales Mitarbeiter-Stammdaten-Modul. Sechs Integrations-Achsen dokumentieren
Pattern, Domain-Owner und Event/Sync-Schnittstelle.

| Cross-Module | Pattern | Domain-Owner | Event/Sync-Schnittstelle |
|--------------|---------|--------------|--------------------------|
| **HR ↔ Zeit** | Pensum-Sync: `fact_workday_target.employment_contract_id` FK auf `fact_employment_contracts`. Direct-Supervisor-RLS: `dim_user.team_lead_id` (HR-gesetzt) steuert Head-of-Scope im Zeit-Modul. HR ist Vertrags-Owner, Zeit ist Soll-Stunden-Konsument. | HR (Owner Stammdaten + Pensum + Vertragsdaten), Zeit (Konsument) | Worker `pensum-sync` (nightly) synct Pensum-Änderungen aus HR → Zeit. Event `hr.contract.updated.v1` triggert Sync bei Lohnänderung oder Pensum-Update. HR-Dashboard aggregiert Absenz-KPIs via `GET /api/v1/zeit/absences/summary` (Micro-Service-Call, kein direkter DB-JOIN). |
| **HR ↔ Commission-Engine** | Provisions-Berechtigung (`has_provisions = TRUE`) aktiviert Commission-Berechnung ab Probezeit-Bestehen. Provisionsvertrag-Versionierung (Praemium Victoria) im HR-Modul verwaltet. Commission-Engine ist Domain-Owner für Berechnungslogik; HR liefert Eligibility-Signal. | Commission-Engine (Owner Berechnungslogik), HR (Owner Eligibility-Daten) | Event `commission.eligibility.changed.v1` (Payload: `{ user_id, eligible: true, effective_date, contract_id }`) emittiert von `hr-probation.worker.ts` nach Probezeit-Bestehen mit `has_provisions=true`. Commission-Engine reagiert und aktiviert Provisions-Tracking ab `effective_date`. Researcher-Pauschale-Lookup liest `employment_type` aus `fact_employment_contracts`. |
| **HR ↔ E-Learning** | Onboarding-Task `TOOL_INTRO_ELEARN` triggert E-Learning-Modul-Zuweisung. Compliance-Tracking: abgeschlossene Pflichtkurse (Generalis-Provisio-Einführung, DSG) erscheinen als `hr.training.completed`-Events in `fact_history`. Academy-Dashboard (`hr-academy-dashboard.html`) zeigt E-Learning-Auswertung pro MA. | E-Learning (Owner Kurs-Inhalte + Zertifizierungen), HR (Owner Onboarding-Curriculum-Trigger) | Event `hr.onboarding.task.done.v1` mit `task_type_code = 'TOOL_INTRO_ELEARN'` → E-Learning-Worker weist Pflicht-Kurs zu. Zertifizierungs-Abschluss schreibt Activity-Type `hr.training.completed` in `fact_history`. |
| **HR ↔ Performance** | HR-Modul ist Domain-Owner für Review-Zyklen (Jahresgespräch, Zielvereinbarung, Probezeit-Milestone). Performance-Modul ist Cross-Modul-Analytics-Hub und konsumiert HR-Daten (Probezeit-Status, Anstellungsdauer) für KPI-Berechnungen, führt aber keine eigene Review-CRUD durch. | HR (Owner Review-Lifecycle + Milestones), Performance (Owner KPI-Analyse + Dashboards) | Performance-Modul liest via `v_hr_active_employees`-View Probezeit-Status + Anstellungsdauer. `hr.probation.completed.v1`-Event dient als Signal für Performance-Ziel-Reset (Phase-3.HR.3 · TBC). |
| **HR ↔ Stammdaten** | HR konsumiert zentrale Kataloge: `dim_hr_document_type` (13 Einträge), `dim_disciplinary_offense_type` (13 Einträge), `dim_onboarding_task_template_type` (18 Einträge). 7 neue Activity-Types Kategorie `hr` in `dim_activity_types` ergänzen den bestehenden 64-Eintrags-Katalog auf 71. Rollen-Matrix (`dim_user.role_code`) und Mitarbeiter-Kürzel (2-Buchstaben-PW/JV/LR) sind Stammdaten-Owner. | Stammdaten (Owner Kataloge + Rollen-Definitionen), HR (Konsument + CRUD-Owner für eigene Dim-Tabellen) | Direct-FKs: `fact_employment_contracts.user_id` → `dim_user`. `dim_activity_types` erhält 7 neue `hr.*`-Einträge (Stammdaten-Patch v1.7 §7). UI-Label-Vocabulary-Mapping: 29 HR-Enum-Werte → deutsches Label in `wiki/meta/mockup-baseline.md` §16. |
| **HR ↔ Billing** | Onboarding-Kosten (IT-Setup, Badge, AHV-Anmeldung via Treuhand Kunz) werden im Billing-Modul als interne Kosten modelliert (Phase-3.HR.4 · TBC). Severance-Pay (fristlose Entlassung, OR 337) und Abgangsentschädigungen werden im Billing-Modul verbucht, sofern modelliert. HR liefert Trigger-Events; Billing ist Domain-Owner für Kostenbuchungen. | Billing (Owner Kostenverbuchung), HR (Owner Auslöse-Events) | Event `hr.contract.terminated.v1` (Payload: `termination_reason`) → Billing-Modul-Alert für manuelle Prüfung Severance-Kosten. Onboarding-Kostenverbuchung: Phase-3.HR.4 · TBC Scope. |

---

## 4. Strategische Entscheidungen

5 zentrale Architektur-Entscheidungen aus HR-Spec-Iteration v0.1 → v0.2 (2026-04-30).

### 4.1 Probezeit-Verlängerungs-Workflow (F1)

**Entscheidung:** Probezeit-Verlängerung ist ein kontrollierter 3-Schritt-Workflow mit Commission-Pause:

1. Head of erfasst Gesprächs-Protokoll (1-Monats- oder 2-Monats-Milestone via `drawer-probation-complete`)
2. Admin setzt `probation_months` auf max 6 Monate (PATCH `/api/v1/hr/contracts/:id`) → DB-Trigger `trg_employment_contract_termination` berechnet neues `probation_end`
3. Dokument `PROBATION_EXTENSION` (OR 335b Abs. 2) wird generiert und unterschrieben (`fact_employment_attachments`)

**Commission-Pause während Verlängerung:** `has_provisions = TRUE`-MA erhalten kein Provisions-Signal während verlängerter Probezeit. `commission.eligibility.changed.v1` mit `eligible: true` wird erst nach erfolgreichem `probation_end`-Milestone emittiert.

**Disciplinary-Trigger:** Wiederholte Leistungsmängel (`PERFORMANCE_DEFICIENCY` / `TARGET_MISS_REPEATED`) in `fact_disciplinary_records` können als Begründung für Probezeit-Verlängerung referenziert werden (via `previous_record_id`-Chain). Eskalations-Vorschlag-Trigger `fn_disciplinary_suggest_escalation()` berechnet `suggested_next_level` automatisch.

**Implementierung:** DB-Patch v1.8 §3.4 (`fact_probation_milestones`) · Backend-Patch v2.10 §1.5 (PATCH probation-complete) · `hr-probation.worker.ts` (14-Tage-Ablauf-Alert + Commission-Bridge) · FE-Patch v1.15 §4.3 (`drawer-probation-complete`).

### 4.2 Praemium-Victoria-Renewal-Cycle (F2)

**Entscheidung:** Provisionsvertrag (Praemium Victoria) wird im HR-Modul als versioniertes Dokument verwaltet. Jährliche Erneuerung ist ein formaler Workflow:

1. Admin öffnet `hr-provisionsvertrag-editor.html` (Route `/erp/hr/provisions`)
2. Neues Dokument wird generiert (POST `/api/v1/hr/documents` mit `doc_type_code = 'PRAEMIUM_VICTORIA'`)
3. Altes Dokument wird automatisch auf `doc_state = 'superseded'` gesetzt (DB-Constraint `supersedes_on_new = TRUE` in `dim_hr_document_type`)
4. MA-Unterschrift + Admin-Gegenzeichnung via `drawer-document-sign`
5. `signed_at`-Tracking: `fact_employment_attachments.signed_by_ma_at` + `signed_by_admin_at`

**Versions-Label:** `version_label VARCHAR(40)` in `fact_employment_attachments` (z.B. „v3 (2026-04)") sichert Nachvollziehbarkeit bei DSGVO-Audits.

**Commission-Engine-Abhängigkeit:** Commission-Engine liest `has_provisions`-Flag aus `fact_employment_contracts`. Praemium-Victoria-Dokument ist Nachweis-Layer; die Engine berechnet unabhängig davon (Eligibility via Event, nicht via Dokument-State).

**Implementierung:** DB-Patch v1.8 §2.1 (`dim_hr_document_type` PRAEMIUM_VICTORIA-Entry) · Backend-Patch v2.10 §1.3 (Dokument-Endpoints) · FE-Patch v1.15 §1.1 (`/erp/hr/provisions`-Route + Mockup `hr-provisionsvertrag-editor.html`).

### 4.3 Onboarding-Editor-Pattern (Curriculum-Driven · E-Learning-verknüpft) (F3)

**Entscheidung:** Onboarding ist curriculum-gesteuert (Templates → Instanzen → Tasks) mit automatischer E-Learning-Zuweisung. Drei Schichten:

- **Templates** (`fact_onboarding_templates`): Wiederverwendbare Checklisten nach Rollen-Typ (MA / HEAD / ADMIN). 3 Standard-Templates seeded; Admin kann eigene erstellen.
- **Instanzen** (`fact_onboarding_instances`): Mitarbeiter-spezifische Laufzeit-Kopie des Templates mit berechneten `due_date`-Werten (entry_date + offset_days).
- **Tasks** (`fact_onboarding_instance_tasks`): Einzelaufgaben mit Assignee-Rolle, Status-Tracking und DB-Trigger-gestütztem Fortschritts-Counter.

**Probezeit-Alignment:** `target_complete_date = entry_date + 90 Tage` (Standard 3-Mt-Probezeit OR 335b Abs. 1). `fact_onboarding_instances.probation_milestone_id` FK verknüpft Onboarding-Abschluss mit Probezeit-Milestone.

**E-Learning-Hook:** Task `TOOL_INTRO_ELEARN` (mandatory, due_offset_days=7) emittiert bei Completion `hr.onboarding.task.done.v1` → E-Learning-Worker startet automatisch Pflicht-Kurs-Zuweisung.

**Compliance-Tasks:** Alle 6 Reglements-Unterschriften (Generalis Provisio · Progressus · Tempus Passio 365 · Locus Extra · Datenschutzerklärung · Praemium Victoria optional) sind als Onboarding-Tasks typisiert und als `fact_employment_attachments` rückverfolgbar.

**Implementierung:** DB-Patch v1.8 §3.5–3.8 (Template/Instance/Task-Tabellen + Trigger) · Backend-Patch v2.10 §1.5 (8 Onboarding-Endpoints) · `hr-onboarding.worker.ts` (Overdue-Check + Completion-Auto) · FE-Patch v1.15 §4.3 (4 Onboarding-Drawer).

### 4.4 Disciplinary-Warnings-Pattern (3-Stage-Eskalation) (F4)

**Entscheidung:** Disziplinarmassnahmen folgen einem 6-stufigen Eskalations-Schema (verbal_warning → written_warning → formal_warning → final_warning → suspension → dismissal_immediate). DB-Trigger `fn_disciplinary_suggest_escalation()` berechnet `suggested_next_level` automatisch bei Insert.

**3-Stage-Probezeit-Verbindung:**
- Stufe 1–2 (verbal/written_warning): Coaching-Massnahme im HR-Drawer dokumentiert
- Stufe 3–4 (formal/final_warning): Probezeit-Verlängerungs-Antrag wird empfohlen
- Stufe 5–6 (suspension/dismissal_immediate): Kündigung-Drawer (`drawer-contract-terminate`) öffnet direkt aus Disciplinary-Drawer

**Audit-Trail:** Alle State-Transitions (draft → issued → acknowledged → disputed → resolved → archived) in `fact_disciplinary_records.audit_trail_jsonb` (JSONB-Append-Pattern via `fn_append_audit_trail()`). Retention: 2 J ohne Folgen / 10 J bei Kündigung (revDSG-konforme Archivierung via `hr-retention.worker.ts`).

**MA-Datenschutz (revDSG Art. 25):** MA sieht eigene Einträge erst ab `disciplinary_state = 'issued'` (RLS-Policy `pol_disciplinary_ma_read`). Draft-Phase bleibt Admin/HoD-exklusiv. `hr.disciplinary.measure`-Activity-Type in `fact_history` erscheint in MA-Self-Ansicht ebenfalls erst ab `issued`.

**Implementierung:** DB-Patch v1.8 §3.3 + §5.3 (Eskalations-Trigger) · Backend-Patch v2.10 §1.4 (5 Disziplinar-Endpoints) · `hr-disciplinary.worker.ts` (Admin-Benachrichtigung + Dispute-Alert + Archivierungs-Job) · FE-Patch v1.15 §4.2 (3 Disziplinar-Drawer).

### 4.5 Domain-Owner-Prinzip (Cross-Modul-Abgrenzung HR) (F5)

**Entscheidung:** Strikte Domain-Owner-Abgrenzung für alle Cross-Modul-Daten. HR ist Read-Layer für Domänen anderer Module; keine doppelte CRUD-Logik.

| Daten-Domäne | Domain-Owner (CRUD) | HR (Rolle) |
|-------------|---------------------|------------|
| Abwesenheiten | Zeit-Modul | Read-Only-KPIs via API |
| Arbeitsstunden / Soll-Zeit | Zeit-Modul | liefert Pensum-Stammdaten via FK |
| Rechnungen / Onboarding-Kosten | Billing-Modul | emittiert Trigger-Events |
| Kurs-Inhalte / Zertifikate | E-Learning-Modul | triggert Onboarding-Tasks; zeigt Academy-KPIs |
| Provisions-Berechnung | Commission-Engine | liefert Eligibility-Signal |
| KPI-Analyse / Utilization | Performance-Modul | liefert Review-Lifecycle-Events |

**Anti-Pattern:** HR-Modul baut keinen eigenen Absenz-Kalender (→ Zeit-Modul). HR-Modul berechnet keine Provision (→ Commission-Engine). HR-Modul zeigt keine Utilization-KPIs (→ Performance-Modul). Details: Memory `project_arkadium_roles_2026.md`.

**Implementierung:** `GET /api/v1/hr/dashboard` aggregiert Absenz-KPIs via externen API-Call (`/api/v1/zeit/absences/summary`) — kein direkter DB-JOIN. Alle Cross-Modul-Reads via dedizierte Service-Endpoints oder Read-Only-Views.

---

## 5. Statistik

```
HR ENUMs:                    10 neue PostgreSQL-Types
HR Dimension-Tabellen:        3 neue (dim_hr_document_type · dim_disciplinary_offense_type ·
                                       dim_onboarding_task_template_type)
HR Fact-Tabellen:             8 neue (employment_contracts · employment_attachments ·
                                       disciplinary_records · probation_milestones ·
                                       onboarding_templates · onboarding_template_tasks ·
                                       onboarding_instances · onboarding_instance_tasks)
HR Views:                     4 (v_hr_active_employees · v_onboarding_progress ·
                                  v_disciplinary_summary · v_pending_signatures)
Trigger-Funktionen:           4 + 8 Bindungen (audit_trail · onboarding_task_state ·
                                                disciplinary_escalation · contract_termination)
Seeds Total:                 44 Dim-Einträge + 3 Standard-Onboarding-Templates
                              (13 doc_types + 13 offense_types + 18 task_template_types)
Stammdaten (Stammdaten-Patch v1.7):
  ENUM-Sektionen:            10 neue (§G.1–G.10)
  Stammdaten-Sektionen:       5 neue (§86–§90)
  Seeds total Stammdaten-Patch: 62 neue Einträge
  Activity-Types:             7 neue (Kategorie 12 `hr`) → dim_activity_types total: 71
  UI-Label-Mappings:         29 HR-Enum-Werte → deutsches UI-Label (mockup-baseline §16)
Endpoints:                   29 REST-Endpoints in 6 Gruppen
  (Mitarbeiter ×4 · Verträge ×5 · Dokumente ×5 · Disziplinar ×5 · Onboarding ×8 · Dashboard ×2)
Worker:                       4 (hr-onboarding · hr-disciplinary · hr-probation · hr-retention)
Events:                      16 (hr.contract.* ×4 · hr.document.* ×3 · hr.disciplinary.* ×5 ·
                                  hr.onboarding.* ×3 · hr.probation.* ×1 +
                                  commission.eligibility.changed.v1)
Drawer:                      11 (540px) + keine separaten Modals (nur inline-Confirms)
  (Stammdaten ×4 · Disziplinar ×3 · Onboarding ×4)
Routen:                      10 Top-Level (1 Hub + 9 Sub-Pages)
Mockup-Pages:                 8 (1 Hub + 7 aktive Sub-Pages · ~85% Reife)
RLS-Policies:                22 auf 6 Fact-Tabellen (MA-Self · HoD-Team · Admin-All · BO-Read)
Tabellen-Total v1.8:        ~273 (~262 v1.7 + 11 HR-netto)
```

---

## 6. Phase-Roadmap-Update

### 6.1 Aktueller Stand (Phase 3 aktiv)

```
Phase 3.HR.0 — Fundament (HR-Modul · Kern-Tabellen + Vertrags-CRUD)
  └─ DB-Migration v1.8 · Stammdaten v1.7 · UI Phase-1 (8 Mockups · ~85%)
  └─ 10 ENUMs · 11 Tabellen · 4 Views · 22 RLS-Policies · 4 Worker

Phase 3.HR.1 — Onboarding-Editor (Curriculum-Driven · E-Learning-verknüpft)
  └─ Template-Verwaltung in Admin-Drawer · 18 Standard-Task-Types
  └─ Auto-Start-Onboarding bei Vertrag-Erfassung (Checkbox drawer-contract-new)
  └─ Probezeit-Alignment: target_complete_date = entry_date + 90 Tage

Phase 3.HR.2 — Disziplinar-Workflow (3-Stage-Eskalation · DSG-konforme Archivierung)
  └─ 6-stufiges Eskalations-Schema · Trigger-basierter Stufenvorschlag
  └─ 2-J / 10-J Retention via hr-retention.worker.ts
  └─ MA-Self-Service: Kenntnisnahme + Einsprache via drawer-disciplinary-acknowledge

Phase 3.HR.3 — Performance-Review-Integration (TBC Phase 3.HR.3)
  └─ Jahresgespräch-Workflow via fact_probation_milestones (Typ-Erweiterung oder neue Tabelle)
  └─ Zielvereinbarungs-CRUD (migriert aus Performance-Modul-Scope)
  └─ Performance-Modul-Signal: hr.probation.completed.v1 → Performance-Ziel-Reset

Phase 3.HR.4 — Offboarding + Billing-Integration (vertagt)
  └─ Offboarding-Checkliste (fact_offboarding_instances · analog Onboarding-Pattern)
  └─ Severance-Pay-Verbuchung via Billing-Modul-Event-Bridge
  └─ Onboarding-Kostenverbuchung (IT-Setup, AHV-Anmeldung via Treuhand Kunz)
```

### 6.2 Phase 4 (vertagt)

- **Elektronische Signatur (qualifizierte Signatur SwissID / DocuSign)**: Praemium Victoria + Arbeitsvertrag mit rechtsgültiger e-Signatur (Zeitersparnis Admin-Gegenzeichnung via Brief)
- **AHV-ELM-Direkt-Meldung** via Swissdec-ELM 5.0 (statt Treuhand Kunz Bexio-CSV-Export)
- **Multi-Standort-Rollen-Hierarchie** (Basel/Winterthur falls Remote-Office-Expansion → Head-of-Scope über Standort hinweg)

### 6.3 Phase 5 (vertagt)

- **KI-gestützter Onboarding-Assistent** (LLM-basierte Task-Vorschläge basierend auf Rollen-Profil + historischen Onboardings)
- **EU-Tenant-Variante** (deutsches Arbeitsrecht: andere Kündigungsfristen, Betriebsrat-Pflicht, DSGVO statt revDSG)
- **Whistleblower-Kanal** (anonymes Meldewesen, EU-Hinweisgeberschutzrichtlinie konform)

---

## 7. Routing-Übersicht

```
Topbar-Toggle: CRM ↔ ERP

ERP-Workspace:
  /erp/hr/*              → HR-Modul / Personal (NEU v1.8)
    ├── /                Hub (Redirect → /erp/hr/dashboard)
    ├── /dashboard       HR-Dashboard (KPI-Strip · Probezeit-Alerts · Team-Übersicht)
    ├── /list            Mitarbeiterliste (Compliance-Matrix · Vertrags-Status)
    ├── /list/:user_id   MA-Detail-Drawer-Flow (Vertrags-Tab · Dokumente · Verlauf)
    ├── /self            Self-Service (MA-Rolle · eigenes Profil + Dokumente + History)
    ├── /disciplinary    Verwarnungen & Disziplinar (6-Stufen-Matrix · offene Disputes)
    ├── /disciplinary/:id Disciplinary-Drawer-Flow (Detail · Verlauf · Eskalation)
    ├── /onboarding      Onboarding-Editor (aktive Instanzen · Template-Verwaltung)
    ├── /provisions      Provisionsvertrag-Editor (Praemium Victoria · Admin-only)
    └── /academy         Academy-Dashboard (E-Learning-Auswertung · Kurs-Status je MA)
  /erp/zeit/*            → Zeit-Modul
  /erp/billing/*         → Billing-Modul
  /erp/elearn/*          → E-Learning-Modul
  /erp/performance/*     → Performance-Modul
```

**ERP-Topbar-Tabs:**
```
[CRM] [Personal] [Zeit] [Billing] [Performance] [Publishing]
               ^
             aktiv bei /erp/hr/*
```

Hub-Pattern (analog Billing / Zeit / E-Learning / Performance): `mockups/ERP Tools/hr/hr.html`
lädt Sub-Pages via iframe; Sub-Pages haben keine eigene App-Bar (Memory `feedback_claude_design_no_app_bar.md`).

**Sidebar „Personal" (7 Einträge):**

```
Personal
├── Dashboard           → /erp/hr/dashboard
├── Mitarbeiter         → /erp/hr/list
├── Mein Profil         → /erp/hr/self        (nur MA-Rolle, versteckt für Admin)
├── Verwarnungen        → /erp/hr/disciplinary
├── Onboarding          → /erp/hr/onboarding
├── Provisionsvertrag   → /erp/hr/provisions  (nur Admin)
└── Academy             → /erp/hr/academy
```

---

## 8. Sync-Impact

| Grundlagen-Datei | Änderung | Quelle |
|------------------|----------|--------|
| `ARK_DATABASE_SCHEMA_v1_7.md` → v1.8 | NEU dieser Run (P1) | DB-Patch v1.8 HR |
| `ARK_BACKEND_ARCHITECTURE_v2_9.md` → v2.10 | NEU dieser Run (P2) | Backend-Patch v2.10 HR |
| `ARK_STAMMDATEN_EXPORT_v1_6.md` → v1.7 | NEU dieser Run (P3) | Stammdaten-Patch v1.7 HR |
| `ARK_FRONTEND_FREEZE_v1_14.md` → v1.15 | NEU dieser Run (P4) | FE-Patch v1.15 HR |
| `ARK_GESAMTSYSTEM_UEBERSICHT_v1_7.md` → v1.8 | NEU dieser Run (P5) | DIESER PATCH (TEIL 29) |
| `wiki/meta/spec-sync-regel.md` | Update Sync-Matrix | HR 5/5 ✓ |
| `wiki/meta/mockup-baseline.md` §16 | UI-Label-Vocabulary | 29 HR-Enum-Werte (Stammdaten-Patch v1.7 §8) |
| `wiki/meta/drift-log.md` | Eintrag [2026-04-30] | „HR-Gesamtsystem-Patch v1.7→v1.8 geschlossen" |
| `wiki/meta/decisions.md` §2026-04-30 | NEU Eintrag | „HR-Sync-Lücke geschlossen (0/5 → 5/5) · 5 strategische Entscheidungen dokumentiert" |

---

## 9. Memory-Verweise

- `project_commission_model.md` — Commission-Engine-Kern-USP · Praemium-Victoria-Eligibility-Signal
- `project_arkadium_roles_2026.md` — 12 ARK-MA-Rollen-Matrix · Primär-Rolle pro Person · Commission-Modell
- `project_activity_linking.md` — HR-Activity-Types linken auf `fact_history`-Events · Kategorie 12 `hr`
- `project_phase3_erp_standalone.md` — Phase-3-ERP-Module eigenständig · HR als Teil des ARK-ERP-Produkts
- `project_performance_modul_decisions.md` — Performance bleibt Analytics-Hub · HR-Reviews migriert ins HR-Modul
- `project_zeit_modul_architecture.md` — HR-Zeit-Trennung · Domain-Owner-Abgrenzung Pensum vs. Zeiterfassung
- `feedback_phase3_modules_separate.md` — HR-Hub-Page eigenständig, nicht in CRM-Sidebar
- `feedback_claude_design_no_app_bar.md` — Sub-Pages ohne App-Bar (Hub-Topbar liefert das)
- `reference_treuhand_kunz.md` — AHV-Anmeldung via Treuhand Kunz · Onboarding-Task AHV_REGISTRATION
- `project_guarantee_protection.md` — Trennung Schutzfrist vs. Garantiefrist (kein HR-Modul-Scope)

---

## 10. Acceptance Criteria

- [ ] TEIL 29 in `ARK_GESAMTSYSTEM_UEBERSICHT_v1_8.md` appendet
- [ ] Changelog-Eintrag „v1.8 (2026-04-30) · HR-Modul Phase-3 v0.2" sichtbar
- [ ] Phase-3-ERP-Module-Liste zeigt HR als „spec'd · 8 Mockups · 5/5 Sync"
- [ ] Performance-Reviews-Migration ins HR-Modul in Modul-Liste reflektiert
- [ ] Cross-Module-Integration-Tabelle 6 Achsen (Zeit / Commission / E-Learning / Performance / Stammdaten / Billing) dokumentiert
- [ ] 5 strategische Entscheidungen (Probezeit-Verlängerung · Praemium-Victoria-Renewal · Onboarding-Editor · Disciplinary-Warnings · Domain-Owner) referenziert
- [ ] Statistik-Block konsistent zu DB-Patch v1.8 (10 ENUMs · 11 Tabellen · 4 Views · 22 RLS-Policies · 29 Endpoints · 4 Worker · 16 Events · 11 Drawer)
- [ ] Phase-Roadmap (3.HR.0 – 3.HR.4 + Phase 4 + Phase 5) komplett
- [ ] Routing-Übersicht zeigt `/erp/hr/*` mit 9 Sub-Routes
- [ ] Sidebar „Personal" mit 7 Einträgen dokumentiert
- [ ] Sync-Impact-Tabelle dokumentiert alle 5 Patches dieses Runs + 4 Wiki-Updates
- [ ] Lateinische Eigennamen (Praemium Victoria · Generalis Provisio · Tempus Passio 365 · Locus Extra · Progressus) durchgängig korrekt
- [ ] `wiki/meta/spec-sync-regel.md` Sync-Matrix-Eintrag „HR 5/5"
- [ ] `wiki/meta/decisions.md` §2026-04-30 Eintrag „HR-Sync-Lücke geschlossen"

---

**Ende v1.8 · HR.** Apply-Reihenfolge: DB v1.8 → Backend v2.10 → Stammdaten v1.7 → FE v1.15 → Gesamtsystem v1.8 (dieser Patch).
Schließt HR-Sync-Lücke (ERP-Audit 2026-04-30): 0/5 → **5/5 Grundlagen-Patches komplett** (+ Gesamtsystem = 6/6 Chain geschlossen).
