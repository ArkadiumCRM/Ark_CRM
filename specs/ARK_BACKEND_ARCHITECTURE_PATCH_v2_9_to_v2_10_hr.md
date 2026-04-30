---
title: "ARK Backend Architecture · Patch v2.9 → v2.10 · HR-Modul"
type: spec
module: hr
version: 2.10
created: 2026-04-30
updated: 2026-04-30
status: draft · HR-Sync-Patch
sources: [
  "Grundlagen MD/ARK_BACKEND_ARCHITECTURE_v2_9.md",
  "specs/ARK_HR_TOOL_INTERACTIONS_v0_1.md",
  "specs/ARK_HR_TOOL_SCHEMA_v0_2.md",
  "specs/ARK_HR_TOOL_PLAN_v0_2.md",
  "specs/ARK_DATABASE_SCHEMA_PATCH_v1_7_to_v1_8_hr.md"
]
tags: [backend, patch, hr, endpoints, workers, events, rbac, onboarding, disciplinary, probezeit, phase-3]
---

# ARK Backend Architecture · Patch v2.9 → v2.10 · HR-Modul

**Stand:** 2026-04-30
**Status:** Draft · HR-Sync-Patch
**Quellen:**
- `Grundlagen MD/ARK_BACKEND_ARCHITECTURE_v2_9.md` (Vorgänger)
- `specs/ARK_HR_TOOL_INTERACTIONS_v0_1.md` §5 (API-Endpunkte-Stub, 17 Endpoints erweitert)
- `specs/ARK_HR_TOOL_SCHEMA_v0_2.md` §9 (Integration-Hooks: Events)
- `specs/ARK_HR_TOOL_PLAN_v0_2.md` §1 (Scope · Worker-Mapping)
- `specs/ARK_DATABASE_SCHEMA_PATCH_v1_7_to_v1_8_hr.md` (DB-Voraussetzung)

**Vorrang:** Stammdaten > Schema > Patch > Mockups

**Voraussetzungen:**
- DB-Patch v1.8 (alle HR-Tabellen + RLS-Policies) deployed
- Backend-Patch v2.9 (Email-Send-Queue-Worker + Stammdaten-Endpoints) deployed
- `dim_user` mit `role_code` (MA / HEAD / ADMIN / BO) in DB vorhanden

---

## 0. ZIELBILD (was ändert dieser Patch)

Dieser Patch aktiviert das vollständige HR-Backend:

1. **29 REST-Endpoints** unter `/api/v1/hr/*` (Mitarbeiter · Verträge · Dokumente · Disziplinar · Onboarding · Dashboard)
2. **4 HR-Worker** (`hr-onboarding.worker.ts`, `hr-disciplinary.worker.ts`, `hr-probation.worker.ts`, `hr-retention.worker.ts`)
3. **16 HR-Events** (`hr.contract.*`, `hr.document.*`, `hr.disciplinary.*`, `hr.onboarding.*`, `hr.probation.*`, `commission.eligibility.changed.v1`)
4. **RBAC-Matrix** (HR-Admin · HoD · MA-Self · BO · Worker-Bypass) pro Endpoint

---

## 1. HR-Endpoints (29)

Namespace: `/api/v1/hr/`
Auth: JWT mit `role_code`-Check (RLS zusätzlich DB-seitig via §6 DB-Patch v1.8)
Implementierungs-Referenz: `specs/ARK_HR_TOOL_INTERACTIONS_v0_1.md` §5 (Basis-Stub)

### 1.1 Mitarbeiter-Endpoints (4)

```
GET    /api/v1/hr/employees
       Zweck: Liste aller Mitarbeiter (inkl. Vertragsdaten, RLS-gefiltert)
       Auth: JWT · Admin / HoD / BO
       Query-Params: role_code · employment_type · contract_state · sparte · q (Suche) · limit · offset
       Response: { employees: [{user_id, name, role_code, contract_id, contract_state,
                   employment_type, has_provisions, in_probation, probation_end}], total: N }
       Cache: none (Live-Daten)

POST   /api/v1/hr/employees
       Zweck: Neuen Mitarbeiter anlegen (dim_user + fact_employment_contracts in 1 Transaktion)
       Auth: JWT · Admin only
       Body: { name, role_code, employment_type, contract_start, probation_months,
               salary_monthly_chf, has_provisions, notice_period_months }
       Response: { user_id, contract_id }
       Events: hr.contract.created.v1 · (optional) hr.onboarding.triggered.v1
       Note: Onboarding-Auto-Start via hr-onboarding.worker.ts wenn auto_onboard=true im Body

GET    /api/v1/hr/employees/:user_id
       Zweck: Mitarbeiter-Detail mit aktivem Vertrag + Onboarding-Status + Disziplinar-Summary
       Auth: JWT · Admin / HoD (eigenes Team) / MA-Self
       Response: vollständiger Employee-Record + aktiver Vertrag + v_onboarding_progress + v_disciplinary_summary

PATCH  /api/v1/hr/employees/:user_id
       Zweck: MA-Stammdaten aktualisieren (role_code, Sparte, Kürzel)
       Auth: JWT · Admin only
       Body: Partial<dim_user> (nur zulässige Felder)
       Events: hr.employee.updated.v1
```

### 1.2 Vertrags-Endpoints (5)

```
GET    /api/v1/hr/contracts/:id
       Zweck: Vertrags-Detail (Laufzeit, Lohn, Probezeit, Kündigung)
       Auth: JWT · Admin / HoD (eigenes Team) / MA-Self (eigener Vertrag)
       Response: vollständiger fact_employment_contracts-Record + Dokument-Liste

PATCH  /api/v1/hr/contracts/:id
       Zweck: Vertrag bearbeiten (Lohn, Pensum, Probezeit-Verlängerung)
       Auth: JWT · Admin only
       Body: Partial<fact_employment_contracts>
       Events: hr.contract.updated.v1
       Note: probation_months-Änderung triggert hr.probation.extended.v1 wenn > vorheriger Wert

POST   /api/v1/hr/contracts/:id/terminate
       Zweck: Kündigung erfassen (ordentlich oder fristlos)
       Auth: JWT · Admin only
       Body: { termination_reason, terminated_at, termination_notice_given_at, termination_note }
       Events: hr.contract.terminated.v1
       Side-Effects: retention_until = terminated_at + 10J (via DB-Trigger trg_employment_contract_termination)

GET    /api/v1/hr/contracts/:id/timeline
       Zweck: Vertrags-History aus audit_trail_jsonb (für Drawer-Tab "Verlauf")
       Auth: JWT · Admin / HoD
       Response: { entries: [{at, by, op, diff}] }

POST   /api/v1/hr/contracts
       Zweck: Neuen Vertrag für bestehenden MA (Vertragswechsel / Verlängerung befristet)
       Auth: JWT · Admin only
       Body: { user_id, employment_type, contract_start, ... }
       Pre-Check: existing active contract → auto-set previous to 'expired' or require explicit terminate
       Events: hr.contract.created.v1
```

### 1.3 Dokument-Endpoints (5)

```
GET    /api/v1/hr/documents/:user_id
       Zweck: Dokument-Liste pro MA (alle Dokument-Typen + Signatur-Status)
       Auth: JWT · Admin / HoD / MA-Self
       Response: { documents: [{id, doc_type_code, doc_label, doc_state, version_label,
                   signed_by_ma_at, signed_by_admin_at, days_pending}] }

POST   /api/v1/hr/documents
       Zweck: Dokument anfordern (triggert hr-document-generator.worker.ts)
       Auth: JWT · Admin only
       Body: { user_id, contract_id, doc_type_code, version_label }
       Response: { attachment_id, doc_state: 'pending' }
       Events: hr.document.requested.v1 → Worker generiert PDF → hr.document.ready.v1

PATCH  /api/v1/hr/documents/:id/sign
       Zweck: Unterschrift erfassen (MA-Seite oder Admin-Gegenzeichnung)
       Auth: JWT · Admin (für admin_sig) / MA-Self (für ma_sig)
       Body: { signed_by: 'ma' | 'admin' }
       Events: hr.document.signed.v1 (bei vollständiger Signatur: doc_state → 'signed')

GET    /api/v1/hr/documents/:id
       Zweck: Dokument-Detail + Signatur-Status + PDF-Pfad
       Auth: JWT · Admin / HoD / MA-Self

GET    /api/v1/hr/documents/:id/download
       Zweck: Signed-URL für PDF-Download (1h TTL)
       Auth: JWT · Admin / MA-Self
       Response: { url: 'https://...', expires_at: ISO }
```

### 1.4 Disziplinar-Endpoints (5)

```
GET    /api/v1/hr/disciplinary
       Zweck: Alle Disziplinar-Einträge (RLS-gefiltert: Admin=alle, HoD=Team, MA=eigene issued)
       Auth: JWT · Admin / HoD / MA-Self
       Query-Params: user_id · disciplinary_state · disciplinary_level · date_from · date_to
       Response: { records: [{id, user_id, employee_name, offense_type_code, offense_label,
                   disciplinary_level, disciplinary_state, incident_date, issued_at}], total: N }

POST   /api/v1/hr/disciplinary
       Zweck: Neue Verwarnung erstellen (state: 'draft')
       Auth: JWT · Admin / HoD (eigenes Team)
       Body: { user_id, offense_type_code, disciplinary_level, incident_date,
               incident_description, file_path? }
       Response: { record_id, suggested_next_level } (suggested_next_level via DB-Trigger)
       Events: hr.disciplinary.created.v1
       Note: state = 'draft' — Admin muss explizit aktivieren (PATCH .../issue)

PATCH  /api/v1/hr/disciplinary/:id
       Zweck: Status-Update (draft → issued · issued → acknowledged · disputed → resolved)
       Auth: JWT · Admin (für issue/resolve) / MA-Self (für acknowledge)
       Body: { disciplinary_state, acknowledged_note?, resolved_note? }
       Events: hr.disciplinary.issued.v1 | hr.disciplinary.acknowledged.v1 |
               hr.disciplinary.resolved.v1 | hr.disciplinary.disputed.v1

GET    /api/v1/hr/disciplinary/:id
       Zweck: Eintrag-Detail + Eskalations-Verlauf
       Auth: JWT · Admin / HoD (eigenes Team) / MA-Self (nur state >= 'issued')

GET    /api/v1/hr/disciplinary/summary/:user_id
       Zweck: Aggregierter Disziplinar-Status pro MA (aus v_disciplinary_summary)
       Auth: JWT · Admin / HoD
       Response: { total_records, open_records, highest_level, last_incident_date, has_dispute }
```

### 1.5 Onboarding-Endpoints (8)

```
GET    /api/v1/hr/onboarding
       Zweck: Onboarding-Instanzen (alle aktiven + neulich abgeschlossenen)
       Auth: JWT · Admin / HoD (eigenes Team)
       Query-Params: onboarding_state · user_id · overdue_only
       Response: { instances: v_onboarding_progress[], total: N }

POST   /api/v1/hr/onboarding
       Zweck: Neues Onboarding starten (aus Template)
       Auth: JWT · Admin only
       Body: { user_id, contract_id, template_id?, entry_date }
       Response: { instance_id, total_tasks, entry_date, target_complete_date }
       Events: hr.onboarding.started.v1
       Side-Effects: fact_onboarding_instance_tasks werden aus Template instantiiert

GET    /api/v1/hr/onboarding/:id
       Zweck: Onboarding-Instanz-Detail + Task-Liste
       Auth: JWT · Admin / HoD / MA-Self

PATCH  /api/v1/hr/onboarding/:id/probation-complete
       Zweck: Probezeit abschliessen (HEAD-Aktion)
       Auth: JWT · HoD / Admin
       Body: { passed: boolean, outcome_note, outcome_doc_path? }
       Response: { milestone_id, onboarding_state }
       Events: hr.probation.completed.v1
       Side-Effects (bei passed=true): onboarding_state → 'completed'
                                       commission.eligibility.changed.v1 wenn has_provisions=true
       Side-Effects (bei passed=false): onboarding_state → 'cancelled'
                                        Empfehlung drawer-contract-terminate öffnet im FE

PATCH  /api/v1/hr/onboarding/tasks/:id
       Zweck: Task-Status setzen (pending → in_progress → done | skipped | overdue)
       Auth: JWT · Admin / HoD / zugewiesener MA (eigene Tasks)
       Body: { task_state, completion_note? }
       Events: hr.onboarding.task.done.v1 (nur bei task_state='done')
       Side-Effects: DB-Trigger trg_onboarding_task_state_changed aktualisiert Instanz-Counter

GET    /api/v1/hr/onboarding/templates
       Zweck: Template-Liste (für drawer-onboarding-start Template-Auswahl)
       Auth: JWT · Admin / HoD
       Response: { templates: [{id, name, target_role_code, total_tasks, is_default}] }

POST   /api/v1/hr/onboarding/templates
       Zweck: Neues Template erstellen
       Auth: JWT · Admin only
       Body: { name, description, target_role_code?, is_default }
       Response: { template_id }
       Events: hr.onboarding.template.created.v1

PATCH  /api/v1/hr/onboarding/templates/:id
       Zweck: Template bearbeiten (Name, Aufgaben hinzufügen/entfernen/sortieren)
       Auth: JWT · Admin only
       Body: { name?, tasks?: [{task_type_code, custom_label, assignee_role,
               due_offset_days, is_mandatory, sort_order}] }
       Events: hr.onboarding.template.updated.v1
```

### 1.6 Dashboard-Endpoint (2)

```
GET    /api/v1/hr/dashboard
       Zweck: KPIs + Alerts für hr-dashboard.html
       Auth: JWT · Admin / HoD (nur eigenes Team) / BO
       Response:
       {
         kpis: {
           active_employees: N,
           in_probation: N,
           pending_signatures: N,
           open_disciplinary: N,
           overdue_onboardings: N,
           contracts_expiring_30d: N
         },
         alerts: [
           { type: 'probation_expiring', user_id, name, probation_end, days_remaining },
           { type: 'signature_pending', attachment_id, employee_name, doc_label, days_pending },
           { type: 'disciplinary_dispute', record_id, employee_name, incident_date },
           { type: 'onboarding_overdue', instance_id, employee_name, overdue_tasks },
           { type: 'contract_expiring', contract_id, employee_name, contract_end }
         ]
       }
       Cache: 2 min Backend-Memory (Invalidation bei hr.* Event)

GET    /api/v1/hr/dashboard/pending-signatures
       Zweck: Vollständige Liste ausstehender Unterschriften (aus v_pending_signatures)
       Auth: JWT · Admin / HoD
       Response: { signatures: v_pending_signatures[], total: N }
```

---

## 2. HR-Worker (4)

### 2.1 `hr-onboarding.worker.ts`

**Trigger:** Event `hr.onboarding.started.v1` | Cron: täglich 06:00 (Overdue-Check)

**Aufgaben:**
1. **Instanz-Instantiierung** (bei `hr.onboarding.started.v1`): Template-Tasks → `fact_onboarding_instance_tasks` mit berechneten `due_date` (entry_date + offset_days)
2. **Overdue-Check** (Cron): Tasks mit `due_date < TODAY` und `task_state IN ('pending','in_progress')` → `task_state = 'overdue'` (DB-Trigger übernimmt Instanz-Counter-Update)
3. **Completion-Check** (Cron): Instanzen mit `onboarding_state = 'overdue'` aber alle Tasks done → `onboarding_state = 'completed'`

```typescript
// Pseudo-Code Worker-Struktur
export async function hrOnboardingWorker(event?: HrOnboardingStartedEvent) {
  if (event) {
    await instantiateOnboardingTasks(event.instance_id, event.template_id, event.entry_date);
    return;
  }
  // Cron-Modus
  await markOverdueTasks();
  await resolveStaleCompletions();
}
```

**Events emittiert:**
- `hr.onboarding.task.overdue.v1` (bei Overdue-Markierung, Pflicht-Task)
- `hr.onboarding.completed.v1` (bei Auto-Completion)

### 2.2 `hr-disciplinary.worker.ts`

**Trigger:** Event `hr.disciplinary.created.v1` | Cron: täglich 07:00

**Aufgaben:**
1. **Admin-Benachrichtigung** (bei `hr.disciplinary.created.v1`): In-App-Notification an Admin(s) zur Freigabe (state = 'draft' → Admin muss `PATCH .../issue` aufrufen)
2. **Dispute-Alert** (Cron): Einträge mit `disciplinary_state = 'disputed'` seit > 7 Tage → Escalation-Alert an Admin
3. **Archivierungs-Job** (Cron, monatlich): `disciplinary_state = 'resolved'` + `incident_date < NOW() - 2 YEARS` → `disciplinary_state = 'archived'` + `archived_at = NOW()` + `retention_until = NOW() + 2 J`

```typescript
export async function hrDisciplinaryWorker(event?: HrDisciplinaryCreatedEvent) {
  if (event) {
    await notifyAdminsForApproval(event.record_id);
    return;
  }
  // Cron-Modus
  await alertLongstandingDisputes();
  await archiveResolvedRecords();
}
```

**Events emittiert:**
- `hr.disciplinary.admin.notified.v1`
- `hr.disciplinary.archived.v1`

### 2.3 `hr-probation.worker.ts`

**Trigger:** Cron täglich 08:00

**Aufgaben:**
1. **Ablauf-Alerts** (14 Tage vor `probation_end`): In-App-Alert + `hr-dashboard` Cache-Invalidierung
2. **Überfälligkeits-Check**: `probation_end < TODAY` und kein `fact_probation_milestones` mit `milestone_type = 'probation_end'` → Alert-Level 'red' im Dashboard
3. **Commission-Eligibility-Bridge**: Nach `hr.probation.completed.v1` mit `passed=true` → prüfe `has_provisions` → wenn true: emittiere `commission.eligibility.changed.v1`

```typescript
export async function hrProbationWorker() {
  await sendProbationExpiryAlerts();  // ≤ 14 Tage
  await flagOverdueProbations();       // probation_end < TODAY, kein Milestone
  await bridgeCommissionEligibility(); // passed + has_provisions
}
```

**Events emittiert:**
- `hr.probation.expiry.alert.v1` (14-Tage-Warnung)
- `commission.eligibility.changed.v1` (nach Probezeit-Bestehen mit has_provisions=true)

### 2.4 `hr-retention.worker.ts`

**Trigger:** Cron wöchentlich Sonntag 02:00

**Aufgaben:**
1. **Disziplinar-Archivierung**: `resolved` + `incident_date < NOW() - 2J` → `archived`
2. **Onboarding-Cleanup**: `onboarding_state = 'completed'` + `entry_date < NOW() - 5J` → soft-archive (audit_trail_jsonb Entry)
3. **Dokument-Retention-Report**: Anstehende Dokument-Löschjobs (nächste 30 Tage) → Bericht in Admin-Dashboard
4. **fact_employment_contracts**: Bestätige `retention_until` gesetzt bei allen terminated Verträgen (Sanity-Check)

```typescript
export async function hrRetentionWorker() {
  await archiveDisciplinaryRecords();
  await cleanupOldOnboardings();
  await generateRetentionReport();
  await verifyContractRetentionDates();
}
```

**Events emittiert:**
- `hr.retention.report.generated.v1`

---

## 3. HR-Events (16)

### 3.1 Vertrags-Events

| Event | Trigger | Payload |
|-------|---------|---------|
| `hr.contract.created.v1` | POST /employees oder POST /contracts | `{ contract_id, user_id, employment_type, contract_start, has_provisions }` |
| `hr.contract.updated.v1` | PATCH /contracts/:id | `{ contract_id, user_id, changed_fields: [] }` |
| `hr.contract.terminated.v1` | POST /contracts/:id/terminate | `{ contract_id, user_id, termination_reason, terminated_at, retention_until }` |
| `hr.employee.updated.v1` | PATCH /employees/:user_id | `{ user_id, changed_fields: [] }` |

### 3.2 Dokument-Events

| Event | Trigger | Payload |
|-------|---------|---------|
| `hr.document.requested.v1` | POST /documents | `{ attachment_id, user_id, doc_type_code, contract_id, template_file }` |
| `hr.document.ready.v1` | hr-document-generator → file_path gesetzt | `{ attachment_id, user_id, doc_type_code, file_path }` |
| `hr.document.signed.v1` | PATCH /documents/:id/sign (vollständig) | `{ attachment_id, user_id, doc_type_code, signed_by_ma_at, signed_by_admin_at }` |

### 3.3 Disziplinar-Events

| Event | Trigger | Payload |
|-------|---------|---------|
| `hr.disciplinary.created.v1` | POST /disciplinary | `{ record_id, user_id, disciplinary_level, offense_type_code, incident_date }` |
| `hr.disciplinary.issued.v1` | PATCH /disciplinary/:id (state→issued) | `{ record_id, user_id, issued_at, issued_by }` |
| `hr.disciplinary.acknowledged.v1` | PATCH /disciplinary/:id (state→acknowledged) | `{ record_id, user_id, acknowledged_at, acknowledged_note }` |
| `hr.disciplinary.disputed.v1` | PATCH /disciplinary/:id (state→disputed) | `{ record_id, user_id }` |
| `hr.disciplinary.resolved.v1` | PATCH /disciplinary/:id (state→resolved) | `{ record_id, user_id, resolved_at, resolved_by, resolved_note }` |

### 3.4 Onboarding-Events

| Event | Trigger | Payload |
|-------|---------|---------|
| `hr.onboarding.started.v1` | POST /onboarding | `{ instance_id, user_id, template_id, entry_date, target_complete_date }` |
| `hr.onboarding.task.done.v1` | PATCH /onboarding/tasks/:id (state→done) | `{ task_id, instance_id, user_id, task_type_code, completed_by }` |
| `hr.onboarding.completed.v1` | Worker / PATCH probation-complete (passed=true) | `{ instance_id, user_id, completed_at }` |

### 3.5 Probezeit-Events

| Event | Trigger | Payload |
|-------|---------|---------|
| `hr.probation.completed.v1` | PATCH /onboarding/:id/probation-complete | `{ milestone_id, user_id, contract_id, passed, conducted_at }` |
| `commission.eligibility.changed.v1` | hr-probation.worker (bei passed=true + has_provisions) | `{ user_id, eligible: true, effective_date, contract_id }` |

---

## 4. RBAC-Matrix pro Endpoint

| Endpoint-Gruppe | Admin (GF/HR-Mgr) | HoD | MA-Self | BO |
|----------------|-------------------|-----|---------|-----|
| GET /employees | ✓ alle | ✓ eigenes Team | ✗ | ✓ Read |
| POST /employees | ✓ | ✗ | ✗ | ✗ |
| GET /employees/:id | ✓ | ✓ eigenes Team | ✓ eigener | ✗ |
| PATCH /employees/:id | ✓ | ✗ | ✗ | ✗ |
| GET /contracts/:id | ✓ | ✓ Team | ✓ eigener | ✗ |
| PATCH /contracts/:id | ✓ | ✗ | ✗ | ✗ |
| POST /contracts/:id/terminate | ✓ | ✗ | ✗ | ✗ |
| GET /documents/:user_id | ✓ | ✓ Team | ✓ eigene | ✗ |
| POST /documents | ✓ | ✗ | ✗ | ✗ |
| PATCH /documents/:id/sign | ✓ (admin-sig) | ✗ | ✓ (ma-sig) | ✗ |
| GET /disciplinary | ✓ alle | ✓ Team | ✓ issued/ack/disp | ✗ |
| POST /disciplinary | ✓ | ✓ Team | ✗ | ✗ |
| PATCH /disciplinary/:id (issue/resolve) | ✓ | ✗ | ✗ | ✗ |
| PATCH /disciplinary/:id (acknowledge) | ✓ | ✗ | ✓ eigene | ✗ |
| GET /onboarding | ✓ | ✓ Team | ✗ | ✓ Read |
| POST /onboarding | ✓ | ✗ | ✗ | ✗ |
| GET /onboarding/:id | ✓ | ✓ Team | ✓ eigenes | ✗ |
| PATCH /onboarding/:id/probation-complete | ✓ | ✓ (eigenes Team) | ✗ | ✗ |
| PATCH /onboarding/tasks/:id | ✓ | ✓ Team | ✓ zugewiesene Tasks | ✗ |
| GET /onboarding/templates | ✓ | ✓ | ✗ | ✗ |
| POST/PATCH /onboarding/templates | ✓ | ✗ | ✗ | ✗ |
| GET /dashboard | ✓ | ✓ Team-gefiltert | ✗ | ✓ Read |
| GET /dashboard/pending-signatures | ✓ | ✓ Team | ✗ | ✗ |

**Worker-Bypass:** alle 4 HR-Worker verwenden `ark_worker_service`-DB-Rolle (RLS-Bypass, analog bisherige Worker).

---

## 5. Integration-Hooks

### 5.1 → Dokument-Generator

Event `hr.document.requested.v1` → `hr-document-generator.worker.ts` (existierend im Dok-Generator-Modul):
- Liest `template_file` aus `dim_hr_document_type`
- Rendert PDF mit MA-Stammdaten (Name, Rolle, Eintrittsdatum, Lohn)
- Upload → Storage
- PATCH `fact_employment_attachments.file_path` + `doc_state = 'pending'`
- Emittiert `hr.document.ready.v1`

### 5.2 → E-Learning-Modul

Event `hr.onboarding.task.done.v1` mit `task_type_code = 'TOOL_INTRO_ELEARN'` → E-Learning-Worker weist Pflicht-Kurs zu.

### 5.3 → Commission-Engine

Event `commission.eligibility.changed.v1` (payload: `{ user_id, eligible: true, effective_date }`) → Commission-Engine aktiviert Provisions-Berechnung für MA ab `effective_date`.

### 5.4 → Zeit-Modul

`GET /api/v1/hr/dashboard` aggregiert Absenz-KPIs via `GET /api/v1/zeit/absences/summary?user_ids=[...]` (Micro-Service-Call) — kein direktes JOIN auf `fact_absence` aus HR-Layer.

---

## 6. Endpunkt-Zusammenfassung

| Gruppe | Endpunkte | Methoden |
|--------|-----------|----------|
| Mitarbeiter | 4 | GET × 2, POST, PATCH |
| Verträge | 5 | GET × 2, POST × 2, PATCH |
| Dokumente | 5 | GET × 3, POST, PATCH |
| Disziplinar | 5 | GET × 3, POST, PATCH |
| Onboarding | 8 | GET × 3, POST × 2, PATCH × 3 |
| Dashboard | 2 | GET × 2 |
| **Total** | **29** | |

---

## 7. SYNC-IMPACT

| Grundlagen-Datei | Änderung |
|------------------|----------|
| `ARK_DATABASE_SCHEMA_v1_7.md` | HR-Tabellen + ENUMs + RLS → **DB-Patch v1.8** (bereits geschrieben) |
| `ARK_STAMMDATEN_EXPORT_v1_6.md` | HR-Stammdaten-Kataloge → **Stammdaten-Patch v1.7** |
| `ARK_FRONTEND_FREEZE_v1_14.md` | HR-Routing + Sidebar + Drawer → **FE-Patch v1.15** |
| `ARK_GESAMTSYSTEM_UEBERSICHT_v1_5.md` | Changelog-Eintrag „HR-Modul Backend v2.10" (Folge-Patch) |

---

**Ende v2.10.** Apply-Reihenfolge: DB-Patch v1.8 → Backend-Patch v2.10 → Stammdaten-Patch v1.7 → FE-Patch v1.15.
