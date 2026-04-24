# ARK CRM — Gesamtsystem-Übersicht-Patch · E-Learning · v0.1

**Scope:** High-Level-Eintrag für das Phase-3-ERP-Modul E-Learning in der ARK-Gesamtsystem-Übersicht.
**Zielversion:** `ARK_GESAMTSYSTEM_UEBERSICHT_v1_4.md` (Bump von v1.3).
**Basis-Specs:** `specs/ARK_E_LEARNING_SUB_A_SCHEMA_v0_1.md`, `specs/ARK_E_LEARNING_SUB_A_INTERACTIONS_v0_1.md`.
**Zugehörige Patches:**
- `specs/ARK_DATABASE_SCHEMA_PATCH_ELEARNING_v0_1.md`
- `specs/ARK_BACKEND_ARCHITECTURE_PATCH_ELEARNING_v0_1.md`
- `specs/ARK_STAMMDATEN_PATCH_ELEARNING_v0_1.md`
- `specs/ARK_FRONTEND_FREEZE_PATCH_ELEARNING_v0_1.md`

**Stand:** 2026-04-20
**Status:** Review ausstehend (Peter)

---

## Changelog

| # | Bereich | Änderung |
|---|---------|----------|
| 1 | Modul-Landkarte | +1 neues Phase-3-ERP-Modul (E-Learning) mit Sub-Systemen A/B/C/D |
| 2 | Workspace-Struktur | Topbar-Toggle CRM ↔ ERP dokumentiert |
| 3 | Phasen-Plan | E-Learning in Phase-3-Roadmap eingeordnet |
| 4 | Multi-Tenant-Aspekt | Erste konsequent Multi-Tenant-fähige Komponente (Referenz für spätere Module) |
| 5 | Daten-Flüsse | Neue externe Integration: Git-Webhook (Content-Repo) + LLM (Anthropic) |

---

## 1. Modul-Landkarte (Ergänzung)

### 1.1 Neuer Eintrag: E-Learning

```
Phase 3 · ERP-Ergänzungen
  ├── HR-Tool                 (laufend)
  ├── Zeiterfassung           (laufend)
  ├── Commission-Engine       (laufend, CRM-integriert)
  ├── E-Learning              ← NEU
  │   ├── Sub A: Kurs-Katalog        (Specs v0.1 abgeschlossen, Implementation ausstehend)
  │   ├── Sub B: Content-Generator   (Entwurf offen, nutzt LinkedIn-Scraper-Basis)
  │   ├── Sub C: Wochen-Newsletter   (Entwurf offen)
  │   └── Sub D: Progress-Gate       (Entwurf offen)
  └── Doc-Generator           (Mockup komplett, Specs v0.1)
```

### 1.2 Eigenständigkeit

E-Learning ist **eigenständiges ERP-Modul** mit eigenem Workspace (`/erp/elearn/*`), eigener DB-Namespace-Gruppe (`dim_elearn_*` / `fact_elearn_*`), eigenen Workern und eigenen API-Endpoints unter `/api/elearn/*`. Keine CRUD-Durchgriff vom CRM — nur Events fliessen in gemeinsame `fact_history`-Timeline für MA-Gesamtsicht.

## 2. Workspace-Struktur

### 2.1 Topbar-Toggle CRM ↔ ERP

Neuer globaler Toggle in der Topbar (siehe Frontend-Freeze-Patch §1). Wechselt den gesamten Workspace-Kontext:

- **CRM-Modus:** Sidebar zeigt CRM-Module (Kandidaten, Accounts, Mandate, Jobs, Prozesse, Assessments, Aktivitäten, Admin).
- **ERP-Modus:** Sidebar zeigt ERP-Module (E-Learning, HR, Zeiterfassung, Commission, Doc-Generator).

### 2.2 Gemeinsame Infrastruktur

Beide Workspaces teilen:
- Authentifizierung (JWT, SSO).
- User-Base (`dim_user`).
- Event-Pipeline (`fact_event_queue`, `fact_history`, Event-Processor).
- Notification-System.
- Audit-Logging.
- Design-System (Tokens, Components, Drawer-Pattern).

Getrennt sind:
- DB-Namespaces (CRM: `dim_*`/`fact_*` für Recruiting-Domain; ERP: modulspezifische Namespaces wie `dim_elearn_*`, `dim_hr_*`).
- URL-Routing (`/crm/*` vs. `/erp/<modul>/*`).
- Sidebar-Items.

## 3. Phasen-Plan (Ergänzung)

### 3.1 Einordnung

| Phase | Fokus | E-Learning-Stand |
|-------|-------|------------------|
| 1 | CRM-Core (9 Detailmasken) | — (nicht betroffen) |
| 2 | ERP-Light (HR, Zeiterfassung, Commission) | — |
| 3 | ERP-Vollausbau | **Sub A Katalog** |
| 4 | Automatisierung + AI | **Sub B Content-Gen + Sub C Newsletter** (ab Sub-A-Abschluss) |
| 5 | Enforcement + Gamification | **Sub D Gate** |

### 3.2 Sub A · Meilensteine

1. Spec-Freigabe (SCHEMA + INTERACTIONS + 5 Grundlagen-Patches) — **aktueller Stand**.
2. Implementation-Plan via `superpowers:writing-plans`.
3. Mockup-Skizzen (Claude Design → Claude Code Handoff) optional.
4. DB-Migration + Backend-Scaffold + Content-Repo-Setup.
5. MA-Flows implementiert (Dashboard, Lesson-Viewer, Quiz-Runner).
6. Head-/Admin-Flows implementiert (Team, Freitext-Queue, Curriculum-Templates).
7. Import-Pipeline (Git-Webhook + Worker) + Seed-Content (erste 2-3 Kurse).
8. LLM-Freitext-Scorer + Head-Review-Workflow.
9. Cert-Generator + Badge-Engine.
10. Pilot mit 1-2 neuen MA (Onboarding-Curriculum).
11. Roll-out an bestehende MA.

## 4. Multi-Tenant-Aspekt

E-Learning ist das **erste ARK-Modul mit konsequenter Multi-Tenant-Architektur** (Peter-Entscheid aus Brainstorming 2026-04-20): alle 15 neuen Tabellen tragen `tenant_id`, RLS-Policies von Tag 1 an.

**Begründung:** zukünftige Option, E-Learning Arkadium-extern zu betreiben (White-Label für Kunden oder andere Recruiting-Boutiquen). Schema-Vorbereitung jetzt ist günstiger als spätere Migration.

**Konsequenz für andere Module:** bei künftigen ERP-Modulen Multi-Tenant-Pattern übernehmen (Pattern-Dokumentation aus diesem Patch).

## 5. Datenflüsse (Integration mit bestehendem System)

### 5.1 Eingehende Events (E-Learning reagiert auf CRM-Events)

| Event (CRM/System) | E-Learning-Reaktion |
|--------------------|---------------------|
| `user_created` | `elearn-onboarding-initializer` erzeugt Curriculum |
| `user_role_changed` | `elearn-role-change-watcher` erzeugt Diff-Assignments |
| `user_sparte_changed` | dito |

### 5.2 Ausgehende Events (E-Learning schreibt nach `fact_history`)

Siehe Backend-Architektur-Patch §1 (16 neue `elearn_*`-Events). Diese erscheinen in der `fact_history`-Timeline eines MA und sind dort filterbar unter der neuen Activity-Category `elearning`.

### 5.3 Externe Integrationen

| Integration | Zweck | Richtung |
|-------------|-------|----------|
| Git (Content-Repo) | Kurs-Content via Webhook importieren | Eingehend (Webhook) + Ausgehend (git clone) |
| Anthropic-API (Claude Haiku/Sonnet) | Freitext-Scoring | Ausgehend (HTTPS) |
| S3/Blob | Zertifikat-PDFs speichern | Ausgehend (Upload) + Eingehend (Download via Link) |

## 6. Sicherheit & Compliance

- **Tenant-Isolation:** RLS auf DB-Ebene, App-Layer-Guards, Route-Scoping.
- **Audit:** alle Zuweisungen, Completions, Reviews, Revisions in `fact_history` + `fact_elearn_import_log`.
- **Datenschutz:** Freitext-Antworten sind private; Head sieht nur Team. Admin kann tenant-weit einsehen (operative Notwendigkeit).
- **DSGVO-Löschung:** bei MA-Löschung kaskadiert Enrollments/Attempts; Certs bleiben als Audit bis Tenant-spezifische Aufbewahrungsfrist abläuft (Default: 10 Jahre).

## 7. Team-Ownership & Verantwortlichkeiten

| Rolle | Verantwortung |
|-------|---------------|
| Peter | Produkt-Owner, Content-Definition, Final-Review |
| Admin/Backoffice | Kurs-Publishen, Curriculum-Templates, Massen-Zuweisungen, Import-Monitoring, Analytics |
| Head-of (pro Sparte) | Team-Onboarding-Kontrolle, Freitext-Review, Ad-hoc-Zuweisungen, Status-Switch Neu→Bestehend |
| MA | Kurse bearbeiten, Quizzes absolvieren, Certs erhalten |

## 8. Referenz-Dokumente

- **SCHEMA:** `specs/ARK_E_LEARNING_SUB_A_SCHEMA_v0_1.md`
- **INTERACTIONS:** `specs/ARK_E_LEARNING_SUB_A_INTERACTIONS_v0_1.md`
- **DB-Patch:** `specs/ARK_DATABASE_SCHEMA_PATCH_ELEARNING_v0_1.md`
- **Backend-Patch:** `specs/ARK_BACKEND_ARCHITECTURE_PATCH_ELEARNING_v0_1.md`
- **Stammdaten-Patch:** `specs/ARK_STAMMDATEN_PATCH_ELEARNING_v0_1.md`
- **Frontend-Patch:** `specs/ARK_FRONTEND_FREEZE_PATCH_ELEARNING_v0_1.md`

## 9. Offene Punkte / Follow-ups

- Sub B (Content-Generator): Brainstorming nach Sub-A-Implementation-Start. Basis: bestehender Scraper in `C:\Linkedin_Automatisierung`.
- Sub C (Wochen-Newsletter): abhängig von Sub A + Sub B. Schema-Vorbereitung (`attempt_kind='newsletter'`) bereits in Sub A.
- Sub D (Progress-Gate): UX-Entscheidung für Enforcement-Stärke (Dashboard-Warnung vs. Feature-Sperre) offen — Peter-Entscheidung vor Sub-D-Brainstorming.
- Grundlagen-Version-Bumps: Peter entscheidet beim Merge, ob E-Learning-Patches mit laufenden Activity-Types-Patches zu einer Version gebündelt werden oder separate Version-Bumps.
