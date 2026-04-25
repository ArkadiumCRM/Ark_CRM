---
title: "ARK HR-Modul · Interactions v0.1"
type: spec
module: hr
version: 0.1
created: 2026-04-25
updated: 2026-04-25
status: stub
sources: [
  "mockups/ERP Tools/hr/hr.html",
  "mockups/ERP Tools/hr/hr-dashboard.html",
  "mockups/ERP Tools/hr/hr-list.html",
  "mockups/ERP Tools/hr/hr-mitarbeiter-self.html",
  "mockups/ERP Tools/hr/hr-warnings-disciplinary.html",
  "mockups/ERP Tools/hr/hr-onboarding-editor.html",
  "mockups/ERP Tools/hr/hr-provisionsvertrag-editor.html",
  "specs/ARK_HR_TOOL_SCHEMA_v0_1.md"
]
tags: [spec, interactions, hr, onboarding, disciplinary, probezeit, drawers]
---

# ARK HR-Modul · Interactions v0.1

**Status: STUB** — Vollständige Ausarbeitung Phase-2. Enthält Drawer-Inventar + Kern-Flows.

**Schema-Referenz:** [ARK_HR_TOOL_SCHEMA_v0_1.md](ARK_HR_TOOL_SCHEMA_v0_1.md)

---

## 1. Seitenstruktur

| Seite | Datei | Beschreibung |
|-------|-------|-------------|
| HR Hub | hr.html | Sidebar-Navigation, Tool-Tab-Router |
| Dashboard | hr-dashboard.html | KPIs, Alerts, Quick-Actions |
| Mitarbeiterliste | hr-list.html | Tabelle aller MA mit Filter |
| Mitarbeiter-Self-Service | hr-mitarbeiter-self.html | MA-Eigensicht (Vertrag, Dokumente, Onboarding) |
| Verwarnungen & Disziplinar | hr-warnings-disciplinary.html | Disziplinar-Verwaltung |
| Onboarding-Editor | hr-onboarding-editor.html | Templates + aktive Onboardings |
| Provisionsvertrag-Editor | hr-provisionsvertrag-editor.html | Praemium Victoria Konfiguration |

> **Archiviert (nicht HR):** `hr-absence-calendar.html` → Zeit-Modul · `hr-academy-dashboard.html` → E-Learning-Modul

---

## 2. Drawer-Inventar (540px, slide-in rechts)

### 2.1 HR-Stammdaten-Bereich

| Drawer-ID | Trigger | Inhalt | Schema-Entität |
|-----------|---------|--------|----------------|
| `drawer-contract-new` | „+ Vertrag erfassen" | Formular: Anstellungsart, Start, Pensum, Lohn, Probezeit | `fact_employment_contracts` |
| `drawer-contract-view` | Klick auf Vertrag in Liste | Vertrags-Detail + Dokumenten-Status + Aktions-Buttons | `fact_employment_contracts` |
| `drawer-contract-terminate` | „Kündigung erfassen" | Termin, Grund, Freistellung | `fact_employment_contracts` |
| `drawer-document-sign` | „Dokument anfordern" | Dokument-Typ wählen, Template, Unterschriften-Status | `fact_employment_attachments` |

### 2.2 Disziplinar-Bereich

| Drawer-ID | Trigger | Inhalt | Schema-Entität |
|-----------|---------|--------|----------------|
| `drawer-disciplinary-new` | „+ Verwarnung erfassen" | Delikt-Typ, Datum, Eskalations-Level, Beschreibung | `fact_disciplinary_records` |
| `drawer-disciplinary-view` | Klick auf Eintrag | Detail + Verlauf + nächste Schritte | `fact_disciplinary_records` |
| `drawer-disciplinary-acknowledge` | „Kenntnisnahme erfassen" | MA-Bestätigung + Stellungnahme | `fact_disciplinary_records` |

### 2.3 Onboarding-Bereich

| Drawer-ID | Trigger | Inhalt | Schema-Entität |
|-----------|---------|--------|----------------|
| `drawer-onboarding-start` | „Onboarding starten" | MA wählen, Template wählen, Eintrittsdatum | `fact_onboarding_instances` |
| `drawer-onboarding-task-edit` | Klick auf Task | Task-Details, Status setzen, Notiz | `fact_onboarding_instance_tasks` |
| `drawer-onboarding-template-edit` | „Template bearbeiten" | Aufgaben hinzufügen/entfernen/sortieren | `fact_onboarding_templates` |
| `drawer-probation-complete` | „Probezeit abschliessen" (HEAD) | Outcome-Notiz, Passed/Failed, Dokument | `fact_probation_milestones` |

### 2.4 ~~Absenz-Kalender-Bereich~~ (entfernt)

> Absenz-Kalender gehört ins **Zeit-Modul** — HR zeigt nur Summary-KPIs (Anzahl Abwesende) via Zeit-API. Keine eigenen Drawers für Absenzen in HR.

---

## 3. Kern-Flows (Phase-1)

### F1 — Neuen Mitarbeiter anlegen

```
Admin öffnet hr-list.html
→ „+ Mitarbeiter" Button
→ drawer-contract-new (540px)
  Felder: Name / Rolle / Anstellungsart / Start / Pensum / Lohn / Probezeit / Provisions-Flag
  → Submit → POST /api/hr/employees + POST /api/hr/contracts
  → Onboarding automatisch erstellen? Dialog (Ja/Nein)
  → Bei Ja: drawer-onboarding-start öffnet (vorausgefüllt)
```

### F2 — Verwarnung erfassen (HEAD)

```
Head öffnet hr-warnings-disciplinary.html
→ „+ Verwarnung" Button
→ drawer-disciplinary-new
  Felder: MA / Delikt-Typ / Datum / Level (vorgeschlagen) / Beschreibung / Datei
  → Trigger fn_disciplinary_suggest_escalation() → suggested_next_level anzeigen
  → Submit → POST /api/hr/disciplinary
  → State: draft → (Admin aktiviert) → issued
  → Benachrichtigung an Admin zur Freigabe
```

### F3 — Probezeit-Abschluss (HEAD)

```
Head öffnet hr-onboarding-editor.html → Tab "Aktive Onboardings"
→ Instanz-Card → Button "Probezeit abschliessen" (nur wenn probation_end >= TODAY - 7d)
→ drawer-probation-complete (540px)
  Felder: Outcome-Notiz / Passed (Ja/Nein) / Dokument-Upload
  → Submit → PATCH /api/hr/onboarding/{id}/probation-complete
  → Bei Passed: onboarding_state → completed + Commission-Eligibility-Check
  → Bei Not Passed: onboarding_state → cancelled + drawer-contract-terminate öffnet
```

### F4 — Dokument-Signatur-Workflow

```
Admin öffnet hr-list.html → MA-Row → „Dokumente" (In-Row-Action)
→ Dokument-Typ wählen: dropdown (aus dim_hr_document_type)
→ Dok-Generator-Worker erstellt PDF
→ fact_employment_attachments.doc_state = 'pending'
→ MA sieht in hr-mitarbeiter-self.html: „Dokument unterschreiben" Button
→ MA unterschreibt (physisch oder digital) → Admin bestätigt Gegenzeichnung
→ doc_state → 'signed'
```

---

## 4. Alert-Logik (HR-Dashboard)

| Alert | Quelle | Schwelle | Farbe |
|-------|--------|----------|-------|
| Probezeit endet bald | `v_hr_active_employees.probation_end` | ≤ 14 Tage | amber |
| Ausstehende Unterschriften | `v_pending_signatures.days_pending` | ≥ 5 Tage | amber |
| Offene Verwarnungen (Dispute) | `v_disciplinary_summary.has_dispute` | > 0 | red |
| Onboarding überfällig | `v_onboarding_progress.overdue_tasks` | > 0 | red |
| Vertrag läuft aus (befristet) | `fact_employment_contracts.contract_end` | ≤ 30 Tage | amber |

---

## 5. API-Endpunkte (Phase-1 Stub)

| Method | Endpoint | Action |
|--------|----------|--------|
| GET | `/api/hr/employees` | Liste MA (mit Vertragsdaten, RLS-gefiltert) |
| POST | `/api/hr/employees` | Neuer MA (dim_user + fact_employment_contracts) |
| GET | `/api/hr/contracts/{id}` | Vertrags-Detail |
| PATCH | `/api/hr/contracts/{id}` | Vertrag bearbeiten |
| POST | `/api/hr/contracts/{id}/terminate` | Kündigung erfassen |
| GET | `/api/hr/documents/{user_id}` | Dokument-Liste pro MA |
| POST | `/api/hr/documents` | Dokument anfordern (triggert Dok-Generator) |
| PATCH | `/api/hr/documents/{id}/sign` | Unterschrift erfassen |
| GET | `/api/hr/disciplinary` | Alle Disziplinar-Einträge (gefiltert nach Rolle) |
| POST | `/api/hr/disciplinary` | Neue Verwarnung |
| PATCH | `/api/hr/disciplinary/{id}` | Status-Update |
| GET | `/api/hr/onboarding` | Onboarding-Instanzen |
| POST | `/api/hr/onboarding` | Neues Onboarding starten |
| PATCH | `/api/hr/onboarding/{id}/probation-complete` | Probezeit abschliessen |
| GET | `/api/hr/onboarding/templates` | Template-Liste |
| POST | `/api/hr/onboarding/templates` | Template erstellen |
| PATCH | `/api/hr/onboarding/tasks/{id}` | Task-Status setzen |
| GET | `/api/hr/dashboard` | KPIs + Alerts |

---

## 6. Offen für Ausarbeitung (Phase-2)

- Vollständige Drawer-Formulare (Feldreihenfolge, Validierung, Fehlermeldungen)
- Approval-Workflows (Admin muss Verwarnung freigeben bevor issued)
- Notification-Spec (wer bekommt welche E-Mail / In-App-Alert)
- Provisionsvertrag-Editor-Flows (Praemium Victoria Konfiguration)
- Academy-Dashboard-Interactions (E-Learning-Auswertung HR-Sicht)
- Mobile-Ansicht (hr-mitarbeiter-self als primäre Mobile-Page)

---

## 7. Changelog

| Version | Datum | Änderung |
|---------|-------|----------|
| 0.1 | 2026-04-25 | Stub · Drawer-Inventar + Kern-Flows F1–F4 + Alert-Logik + API-Endpunkte |
