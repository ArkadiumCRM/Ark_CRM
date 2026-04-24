# ARK CRM — Gesamtsystem-Übersicht-Patch · E-Learning Sub D · v0.1

**Scope:** High-Level-Eintrag zur Gesamtsystem-Übersicht für den Progress-Gate (Sub D).
**Zielversion:** Gesamtsystem v1.4 (gemeinsam mit Sub A/B/C).
**Basis-Specs:** `specs/ARK_E_LEARNING_SUB_D_SCHEMA_v0_1.md`, `specs/ARK_E_LEARNING_SUB_D_INTERACTIONS_v0_1.md`.
**Vorherige Patches:** Sub A/B/C Gesamtsystem-Patches.
**Stand:** 2026-04-20
**Status:** Review ausstehend (Peter)

---

## Changelog

| # | Bereich | Änderung |
|---|---------|----------|
| 1 | Modul-Landkarte | Sub D Status: Spec v0.1 abgeschlossen — **E-Learning-Modul komplett specct (A–D)** |
| 2 | Enforcement-Konzept | Feature-granulares Gate dokumentiert |
| 3 | CRM-Integration | Gate-Middleware auf allen CRM-API-Routes |
| 4 | Compliance-Konzept | Simpel-Formel + Snapshot-Tagesbasis |
| 5 | Cert-Lifecycle | Auto-Revoke bei Kurs-Major-Version |

---

## 1. Modul-Landkarte (final für E-Learning)

```
Phase 3 · ERP-Ergänzungen
  ├── HR-Tool
  ├── Zeiterfassung
  ├── Commission-Engine
  ├── E-Learning                                ← KOMPLETT SPECCT
  │   ├── Sub A: Kurs-Katalog         (Specs v0.1 ✓, Patches v0.1 ✓)
  │   ├── Sub B: Content-Generator    (Specs v0.1 ✓, Patches v0.1 ✓)
  │   ├── Sub C: Wochen-Newsletter    (Specs v0.1 ✓, Patches v0.1 ✓)
  │   └── Sub D: Progress-Gate        (Specs v0.1 ✓, Patches v0.1 ✓)
  └── Doc-Generator
```

**Nächster Schritt:** konsolidierter Implementation-Plan via `superpowers:writing-plans` über alle 4 Subs.

## 2. Sub-D-Kern-Idee

**Enforcement-Engine für E-Learning-Compliance.** Feature-granulare Rules, die bei bestimmten Triggers (Newsletter überfällig, Onboarding abgelaufen, Cert expired) konfigurierbar bestimmte CRM-Features blockieren. Override-System für berechtigte Ausnahmen (Urlaub, Elternzeit, medizinisch). Compliance-Dashboards für Transparenz + Führung.

**Kernprinzipien:**
- Feature-based (nicht binär)
- Regel-getrieben (Admin konfiguriert, nicht hardcoded)
- Audit-lastig (jeder Block + Override + Revoke geloggt)
- Override unbegrenzt mit Audit-Zwang
- Cert-Lifecycle automatisch (Expire + Major-Version-Revoke)

## 3. Sub-D-Meilensteine

1. Spec-Freigabe — **aktueller Stand**.
2. Feature-Catalog-Discovery-Script erstellen (Scan von `@gate_feature`-Decorators).
3. DB-Migration (4 neue Tabellen + Cert-Status-Erweiterung + Default-Rules-Seed).
4. Gate-Middleware in CRM-API implementieren (einheitlich via Decorator).
5. Cache-Layer (Redis oder In-Memory).
6. Cron-Worker (Compliance-Snapshot, Cert-Expiry, Override-Ender).
7. Event-Driven-Worker (Cert-Revoker, Cache-Invalidator, Deadline-Rescheduler).
8. Admin-UI (Gate-Rules, Overrides, Audit, Compliance-Dashboard).
9. Head-UI (Team-Compliance).
10. MA-UI (Gate-Page, Login-Popup, Topbar-Badge, Dashboard-Banner, My-Compliance).
11. HTTP-Interceptor im Frontend (403-Catch + Redirect).
12. Pilot: Soft-Enforcement aktiv, Hard als Admin-Option.
13. Rollout-Phase: Default-Rules aktivieren pro Tenant.

## 4. Integration mit CRM

### 4.1 API-Layer

Jeder CRM-API-Endpoint bekommt `@gate_feature(<key>)`-Decorator. CI-Check verhindert Deploys ohne Decorator (oder `@gate_exempt`).

### 4.2 Gate-Hot-Path-Performance

Cache-Layer mit 60 s TTL hält p99-Latenz < 5 ms. Invalidation sofort bei State-Change (Assignment-Complete, Override-Set, Rule-Change).

### 4.3 Event-Bus

Sub D produziert 12 neue Event-Typen und konsumiert Events aus Sub A (Course-Complete, Major-Version), Sub C (Newsletter-Passed), User-Admin (Role-Change).

## 5. Enforcement-Modell (zusammengefasst)

```
Trigger (z.B. "Newsletter KW17 nicht bestanden")
        │
        ▼
Rule wird geprüft (priority-sortiert)
        │
   ┌────┴────┐
   ▼         ▼
Override   Kein Override
aktiv?         │
   │           ▼
   ▼      Feature in blocked_features?
allowed        │
+ Audit    ┌───┴───┐
           ▼       ▼
         ja      nein
           │       │
           ▼       ▼
       blocked   allowed
       + Audit   + Audit
       → 403
       → Gate-Page
```

## 6. Compliance-Formel

**Simpel:**

```
score = (courses_completed + newsletters_passed + certs_active)
        / NULLIF(courses_total + newsletters_total + (certs_active + certs_expired), 0)
        * 100
```

**Interpretation:**
- 100 %: alles erledigt, alle Certs gültig.
- 80–99 %: sehr gut, leichte Überfälligkeiten.
- 50–79 %: Handlungsbedarf.
- < 50 %: kritisch, Head-Alarm.

Tagesbasis-Snapshots in `fact_elearn_compliance_snapshot` ermöglichen Trend-Charts.

## 7. Cert-Lifecycle (automatisch)

```
Course complete + passed → Cert issued (status='active')
                                │
                  (nach refresher_months)
                                │
                                ▼
                         status='expired'
                                │
               Automatisch neuer Refresher-Assignment (Sub A)
                                │
               ─────────────────────────────────
               Alternativ: course version bump (major)
                                │
                                ▼
                         status='revoked'
                                │
               Automatischer Re-Cert-Assignment
```

## 8. Sicherheit & Compliance

- **RLS:** alle Sub-D-Tabellen tenant-scoped.
- **Rule-Engine:** keine freie SQL-Eingabe, nur fest-codierte Trigger-Evaluatoren → SQL-Injection-sicher.
- **Override-Audit:** jede Override-Creation/End geloggt mit `created_by` + `reason`.
- **Bypass-Events:** audit-protokolliert, Admin-only.
- **DSGVO:** Compliance-Daten sind personenbezogen (Score pro MA). Retention konfigurierbar per Tenant.

## 9. Team-Verantwortlichkeiten

| Rolle | Sub-D-Verantwortung |
|-------|---------------------|
| Peter | Default-Rules-Policy (welche Trigger-Types, welche Features geblockt), Soft→Hard-Transition-Entscheid |
| Admin/Backoffice | Rules-Verwaltung, Override-Requests bearbeiten, Audit-Log-Monitoring, Cert-Manual-Revokes |
| Head-of | Team-Compliance-Dashboard, Override-Setting für eigenes Team, Manual-Reminder |
| MA | Compliance-Status-Self-View, Pflicht-Items erledigen |

## 10. Metriken & Alarms

**Admin-Dashboard:**
- Tenant-Avg Compliance-Score (Trend).
- Top-10 MA mit niedrigstem Score.
- Gate-Block-Events pro Woche (Volumen-Indikator).
- Override-Quote (aktive / gesamt MA).

**Alerts:**
- MA mit Score < 50 % → Head-Notification.
- Tenant-Avg sinkt > 10 % in 30 Tagen → Admin-Alert.
- Rule ohne Hits in 90 Tagen → Admin-Hinweis „Rule obsolet?".

## 11. Sub-Interop-Matrix

| Sub | Rolle |
|-----|-------|
| **Sub A (Kurs-Katalog)** | Liefert: Assignments, Enrollments, Certs. Sub D liest diese State. Event `elearn_course_major_version_bumped` muss Sub-A-Import-Worker neu emittieren. |
| **Sub B (Content-Generator)** | Keine direkte Sub-D-Interaktion. |
| **Sub C (Newsletter)** | Liefert: `fact_elearn_newsletter_assignment.enforcement_mode_applied`. Sub D Rule `Hard-Newsletter-Block` wirkt darauf. |

## 12. Referenz-Dokumente

- **SCHEMA Sub D:** `specs/ARK_E_LEARNING_SUB_D_SCHEMA_v0_1.md`
- **INTERACTIONS Sub D:** `specs/ARK_E_LEARNING_SUB_D_INTERACTIONS_v0_1.md`
- **DB-Patch:** `specs/ARK_DATABASE_SCHEMA_PATCH_ELEARNING_SUB_D_v0_1.md`
- **Backend-Patch:** `specs/ARK_BACKEND_ARCHITECTURE_PATCH_ELEARNING_SUB_D_v0_1.md`
- **Stammdaten-Patch:** `specs/ARK_STAMMDATEN_PATCH_ELEARNING_SUB_D_v0_1.md`
- **Frontend-Patch:** `specs/ARK_FRONTEND_FREEZE_PATCH_ELEARNING_SUB_D_v0_1.md`

## 13. Nächste Schritte

Mit Sub D sind **alle 4 Subs des E-Learning-Moduls specct** (A Kurs-Katalog, B Content-Generator, C Newsletter, D Progress-Gate). Jeweils 7 Dateien (SCHEMA + INTERACTIONS + 5 Grundlagen-Patches) = **insgesamt 28 Spec-Dateien**.

**Nächster Schritt:**
1. Peter reviewt alle 4 Sub-D-Dateien.
2. `superpowers:writing-plans` invoken: **konsolidierter Implementation-Plan A+B+C+D** — Task-Breakdown, Dependencies, Test-Strategie, Pilot-Phasen.
3. Grundlagen-Patches in einem konsolidierten Version-Bump in die 5 Grundlagen-MDs einarbeiten.
4. Implementation-Start.

## 14. Offene Punkte / Follow-ups

- **Sub A-INTERACTIONS-Erweiterung:** Event `elearn_course_major_version_bumped` muss in Sub A Import-Worker emittiert werden (kleiner Patch in Sub A bei Implementation).
- **CRM-API-Refactor:** Gate-Middleware in ALLE bestehenden API-Routes einhängen — einmaliger Refactor-Effort.
- **CI-Check:** Jede neue Route muss `@gate_feature` oder `@gate_exempt` haben — Linting-Regel.
- **Pilot-Strategie:** Soft-Enforcement erst 4-6 Wochen laufen lassen, Daten beobachten, dann selektiv Hard aktivieren.
