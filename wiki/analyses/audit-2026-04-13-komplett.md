---
title: "Komplett-Audit ARK CRM Specs + Grundlagen (2026-04-13)"
type: analysis
created: 2026-04-13
updated: 2026-04-13
tags: [audit, konsistenz, roadmap, db-schema, backend, frontend, stammdaten, cross-spec, e2e-workflows]
---

# Komplett-Audit ARK CRM (2026-04-13)

**Scope:** Alle 5 Grundlagen-Dokumente (DB v1.2, Backend v2.4, Frontend Freeze v1.9, Stammdaten v1.2, Gesamtsystem v1.2) + alle 18 Detailseiten-Specs (Schema + Interactions).
**Volumen:** ~22'700 Zeilen.
**Methodik:** 6 parallele Agenten-Audits (DB-Schema, Frontend-Konsistenz, Backend-Events/Workers, Stammdaten-Abdeckung, Cross-Spec-Widersprüche, End-to-End-Workflows) + manuelle Synthese.

---

## 0. EXECUTIVE SUMMARY

**Gesamtbefund:** Specs sind funktional zu ~85% konsistent, aber es bestehen **gravierende Lücken zwischen Specs und Grundlagen** (DB, Backend, Frontend Freeze). Die Detailseiten-Arbeit hat das Datenmodell massiv erweitert; die zugehörigen Infrastruktur-Dokumente sind nicht nachgezogen worden.

**Kritische Blockaden für Implementierung:**
1. **DB v1.2 ist unvollständig** — 45 neue Tabellen + 30+ Feld-Erweiterungen nötig für v1.3
2. **Backend v2.4 ist unvollständig** — 30 fehlende Events, 18 Workers, 46 Endpunkte
3. **Frontend Freeze v1.9 ist veraltet** — 5 komplette Detailseiten fehlen, Account-Tab-Count inkonsistent, Prozess-Architektur-Widerspruch
4. **Stammdaten v1.2 unvollständig** — 12 dim_*-Tabellen fehlen, SIA-Phasen-Widerspruch
5. **Cross-Spec-Widersprüche** — Status-Enums deutsch/englisch-Mix, Tab-Nummerierung inkonsistent, Schutzfrist-Gruppen-Scope nicht durchgezogen

**Zahlen:**
- **P0-Punkte:** 27 (Blocker für Implementierung)
- **P1-Punkte:** 42 (Wichtig, verursachen Implementierungs-Aufwand)
- **P2-Punkte:** 28 (Polish/Phase 2)
- **Klärungs-Fragen an Peter:** 14

**Zeithorizont zur Behebung (grob):**
- DB v1.3 + Backend v2.5: 4-6 Wochen
- Frontend Freeze v1.10: 1-2 Wochen
- Stammdaten v1.3: 1 Woche
- Cross-Spec-Harmonisierung (Status-Enums, Tab-Nummerierung, Schutzfrist): 1 Woche

---

## 1. TEIL I — DATENBANK-SCHEMA-AUDIT (v1.2 → v1.3)

### 1.1 Neue Tabellen nach Modul

| Modul | Anzahl | P0 | P1 | P2 |
|-------|--------|----|----|-----|
| Mandat (Kündigung + Optionen + Schutzfrist + Referral) | 4 | 4 | 0 | 0 |
| Assessment (Credits-Modell) | 3 | 3 | 0 | 0 |
| Prozess & Matching | 2 | 2 | 0 | 0 |
| Firmengruppen | 3 | 2 | 1 | 0 |
| Scraper | 6 | 6 | 0 | 0 |
| Projekt | 10 | 6 | 3 | 1 |
| Account-Kultur-Erweiterung | 3 | 0 | 3 | 0 |
| Kandidaten-Erweiterung | 4 | 0 | 4 | 0 |
| Stammdaten (dim_*) | 18 | 3 | 6 | 9 |
| **TOTAL** | **53** | **26** | **17** | **10** |

### 1.2 Felderweiterungen bestehende Tabellen

**fact_mandate (8 Felder P0):**
- `terminated_by`, `terminated_reason`, `terminated_at`, `terminated_note`, `termination_invoice_id`, `exclusivity_end_date`, `final_outcome`, `group_id`

**fact_jobs (MASSIV — 28 neue Felder):** description_md, salary_min/max_chf, pensum_min/max, contract_type, target_start_date, remote_pct, benefits (JSONB), required_skills/preferred_skills (JSONB), min_years_experience, required_software_ids, nogo_employer_ids, location_radius_km, is_public_posting, publication_channels, is_confidential, filled_at/filled_by_candidate_id, closed_at, confirmation_status, language, vacation_days, responsibilities_md, requirements_md, nice_to_have_md, notes

**fact_process_core (4 Felder):** `on_hold_reason`, `stale_detected_at`, `cancellation_reason`, `cancelled_by`

**fact_mandate_billing.billing_type ENUM:** + `termination`, `option`, `refund`

**dim_accounts:** + `group_id` FK, + `growth_rate_3y_pct`, + `revenue_last_year_chf`

**dim_automation_settings:** + `process_stale_thresholds` JSONB

### 1.3 Kritische Widersprüche in DB-Design

| # | Widerspruch | Empfehlung | Klärung? |
|---|-------------|-----------|----------|
| DB-W1 | `fact_candidate_jobbasket` — neu oder existierend? | Klärung: DB v1.2 listet `fact_jobbasket`. Spec-Referenz prüfen | ❓ Peter |
| DB-W2 | `dim_jobs` vs. `fact_jobs` | Festlegung: nur `fact_jobs` (operative Ausschreibungen), kein Stammdaten-Katalog nötig | ❓ Peter |
| DB-W3 | `dim_candidates` vs. `dim_candidates_profile` | Typo in Specs — nur `dim_candidates_profile` korrekt | Fix in Specs |
| DB-W4 | `dim_projects` vs. `fact_projects` | `fact_projects` ist korrekt (operative Daten) | Fix in Specs |
| DB-W5 | `fact_interviews` vs. `fact_process_interviews` | Duplicate — nur `fact_process_interviews` | Fix in Specs |
| DB-W6 | Protection-Window `account_id` + `group_id` | **CHECK Constraint nötig:** ONE-OF (nur einer darf gesetzt sein) | Neu in v1.3 |
| DB-W7 | Scraper-Findings polymorphe FK | Strict Validation: `CHECK (target_entity_type IS NOT NULL ↔ target_entity_id IS NOT NULL)` | Neu in v1.3 |
| DB-W8 | `candidate_id` (DE: `kandidat_id`) Sprachmix | **Standard Englisch:** alle zu `candidate_id` | Global-Fix |
| DB-W9 | BKP-Katalog-Hierarchie-Validierung | Constraint: `parent_code.ebene = this.ebene - 1` | Neu in v1.3 |
| DB-W10 | `fact_assessment_run.result_version_id` Ziel unklar | Klärung: neue Tabelle `fact_candidate_assessment_version` vs. Feld-Versionierung | ❓ Peter |
| DB-W11 | `fact_projects.volume_chf_exact` vs. `volume_range` | Redundanz — Auto-Compute von Range oder entweder/oder? | ❓ Peter |
| DB-W12 | `cluster_ids` JSONB vs. `bridge_project_clusters` | Normalisierung: Bridge-Tabelle cleaner, aber N:M JSONB ist pragmatischer | ❓ Peter |

### 1.4 Abhängigkeits-Roadmap für v1.3

**Wave 1 (parallel, P0-Blocker):**
- Assessment-Modul (3 Tabellen) ⟷ Mandat-Optionen (4 Tabellen) — **gegenseitige FKs**
- Firmengruppen (3 Tabellen) + `dim_accounts.group_id` + Schutzfrist-Scope-Erweiterung
- Scraper-Modul (6 Tabellen) — standalone

**Wave 2 (abhängig Wave 1):**
- Projekt-Modul (10 Tabellen) — braucht dim_cluster, dim_functions, dim_sia_phases
- Matching (fact_candidate_matches)
- Prozess-Interviews (fact_process_interviews)

**Wave 3 (Polish):**
- Stammdaten-Kataloge (18 dim_* Tabellen)
- Kultur-Analysen
- Kandidaten-Erweiterungen

---

## 2. TEIL II — BACKEND-ARCHITEKTUR-AUDIT (v2.4 → v2.5)

### 2.1 Fehlende Events (30 total)

**P0 (10 Events):**
- `mandate_terminated` (Mandat-Kündigung)
- `assessment_run_completed` + `assessment_credit_assigned` + `assessment_run_scheduled` + `assessment_run_cancelled` + `assessment_order_created` + `assessment_order_signed`
- `stale_detected` (Prozess)
- `guarantee_refund_issued` (Early Exit)
- `protection_window_opened`
- `group_protection_window_opened`

**P1 (14 Events):** `interview_scheduled/rescheduled`, `assessment_version_created`, `assessment_invoice_generated/paid`, `scraper_run_started/finished/failed`, `finding_detected/accepted/rejected`, `protection_window_extended`, `anomaly_detected`, `early_exit_recorded`, `run_reassigned`, `group_mandate_created`, `process_created`

**P2 (6 Events):** `scraper_run_retried`, `auto_disable_triggered`, `protection_violation_detected` (Detail-Level)

### 2.2 Fehlende Worker (18 total)

**P0 (7 Workers):**
| Worker | Trigger | Zweck |
|--------|---------|-------|
| `stale-detection.worker.ts` | Nightly 03:00 | Prozess-Status `Open → Stale` bei Schwellwert-Überschreitung |
| `assessment-billing-overdue.worker.ts` | Nightly 02:00 | Rechnungen → `overdue` bei Zahlungsziel-Überschreitung |
| `process-guarantee-closer.worker.ts` | Nightly 01:00 | Prozesse auto-closen nach Garantiefrist |
| `process-auto-reminder.worker.ts` | Placement-Event | Erstelle 5 Post-Placement-Reminders |
| `protection-window-auto-extend.worker.ts` | Nightly 02:00 | Auto-Extension auf 16 Monate nach 10-Tage-Frist |
| `scraper-batch-job.worker.ts` | Scheduled + Bulk-Trigger | Priority-Queue für Scraper-Runs |
| `scraper-finding-processor.worker.ts` | Event `finding_detected` | Duplicate-Check + Confidence-Score + Staging |

**P1 (10 Workers):** Temperature-Scorer (Kandidat + Account), Matching-Recompute, Scraper-Auto-Disable, Interview-Coaching/Debriefing-Reminder, Referral-Payout-Trigger, Scraper-Antiduplicate, Stammdaten-Drift-Detection

**P2 (1):** Assessment-Credits-Verfall (nicht aktiv, da Verfall verneint)

### 2.3 Fehlende Endpunkte (46 total)

**Nach Entity:**

| Entity | P0 | P1 | P2 | Total |
|--------|----|----|----|-------|
| Prozess | 9 | 4 | 0 | 13 |
| Assessment | 8 | 2 | 0 | 10 |
| Scraper | 5 | 6 | 1 | 12 |
| Mandat | 2 | 0 | 0 | 2 |
| Account-Schutzfristen | 1 | 1 | 1 | 3 |
| Firmengruppe | 0 | 2 | 0 | 2 |
| Kandidat | 0 | 1 | 0 | 1 |
| Jobs | 0 | 2 | 1 | 3 |
| **TOTAL** | **25** | **18** | **3** | **46** |

**Kritischste P0-Endpunkte (Auswahl):**
- `POST /api/v1/processes/:id/place` — **Placement-Transaktion** (8 Sub-Steps)
- `POST /api/v1/assessments/:id/runs/:runId/complete` — **Report-Upload-Transaktion**
- `POST /api/v1/mandates/:id/terminate` — **Kündigungs-Transaktion** (inkl. Schutzfrist-Opening)
- `POST /api/v1/scraper/findings/:id/accept` — **Finding-Typ-spezifische Entity-Creation**
- `POST /api/v1/accounts/:id/protection-windows/:windowId/file-claim` — **Schutzfrist-Claim**

### 2.4 Atomare Transaktionen / Sagas (8 identifiziert)

Alle benötigen ACID-Transaktionen im Backend:

| # | Transaktion | Sub-Steps | Risk wenn nicht atomar |
|---|-------------|-----------|----------------------|
| TX1 | Placement | 8 (Prozess + Finance + Mandat-Billing + Job-Filled + Schutzfrist + Referral + Reminders + Events) | Inconsistent State (Job filled aber Mandat nicht billed) |
| TX2 | Assessment-Report-Upload | 4 (Run + Kandidat-Version + credits_used + Events) | Credits doppelt verbraucht |
| TX3 | Mandat-Kündigung | 4 (Mandat-Status + Billing + Schutzfrist-Fenster + Events) | Schutzfrist fehlt → Claim später unmöglich |
| TX4 | Scraper-Finding-Accept | 4 (Finding + neue Entity + History + Duplicate-Check) | Dupes in Live-Daten |
| TX5 | Assessment-Credit-Assign | 3 (Run + History + Notification) | Run ohne Kandidat-Audit |
| TX6 | Early Exit + Rückvergütung | 2 Transaktionen (Exit-Record → Refund-Create) | Doppel-Rückvergütung möglich |
| TX7 | Gruppe-Member-Add | Batch: N Protection-Window-Inserts für bestehende Presentations | Half-protected Zustand |
| TX8 | Bulk-Scraper-Run | Batch-Insert von N Runs + PgBoss-Jobs | Inkonsistente Scheduling-Tabelle |

### 2.5 WebSocket / Live-Update-Anforderungen

**Backend v2.4 hat kein WebSocket-System dokumentiert.** Specs fordern:

| Endpunkt | Ziel-Latenz | P |
|----------|-------------|---|
| Scraper-Dashboard (6 Slots live) | < 2 Sek | P0 |
| Scraper Review-Queue (Finding-Fade-In) | < 2 Sek | P0 |
| Scraper Error-Stream | < 2 Sek | P1 |
| Assessment Snapshot-Bar (Credit-Progress) | < 1 Sek | P1 |
| Job-Matching-Recompute-Status | < 5 Sek | P1 |
| Job-Detailseite Prozess-Liste | < 2 Sek | P1 |

### 2.6 Rate-Limiting

Backend v2.4 nur global (100 Req/15min IP). Specs fordern:
- Token-Bucket pro Scraper-Typ + Source-Domain (P1)
- Concurrent-Limit: 10 parallele Scraper-Runs (P0)
- Alert `rate_limit_reached` bei > 50% Token-Verbrauch/h (P1)

### 2.7 Event-Scope-Inkonsistenzen (Multi-Entity Events)

Mehrere Events erreichen laut Spec mehrere Entities, Backend-Implementierung unklar:

- `placed` → Kandidat + Account + Mandat + Job + Prozess (**5 Entities!**)
- `assessment_run_completed` → Kandidat + Account + Order + Mandat (4)
- `protection_window_opened` → Kandidat + Account + (optional) Gruppe (2-3)

**Empfehlung:** Event-Scope-Registry im Backend-Code mit Regel-basiertem Multi-Entity-Audit-Log-Schreiben.

### 2.8 Konfigurierbare Setting-Keys (12 fehlen)

Alle in `dim_automation_settings`:
- `candidate_temperature_hot/warm_threshold` (P1)
- `account_temperature_hot/warm_threshold` (P1)
- `protection_window_auto_extend_days` (P1)
- `protection_window_extend_duration_months` (P1)
- `scraper_bulk_parallelism_default` (P1)
- `scraper_concurrent_run_limit` (P1)
- `scraper_rate_limit_alert_threshold` (P1)
- `scraper_confidence_auto_accept_threshold` (P2)
- `assessment_billing_overdue_check_hour` (P1)
- `process_guarantee_closer_check_hour` (P1)
- `process_stale_detection_hour` (P1)

---

## 3. TEIL III — FRONTEND-FREEZE-AUDIT (v1.9 → v1.10)

### 3.1 Route-Konflikte

| Entity | Freeze v1.9 | Spec v0.1 | Entscheidung nötig |
|--------|-------------|-----------|---------------------|
| Firmengruppen | `/company-groups/[id]` | `/company-groups/[id]` | **❓ Peter: Englisch oder Deutsch?** |
| Projekte | `/projects/[id]` | `/projects/[id]` | **❓ Peter: Englisch oder Deutsch?** |
| Assessments | nicht vorhanden | `/assessments/[id]` | Freeze ergänzen |

**Andere Routen:** ✅ konsistent (candidates, accounts, mandates, jobs, processes, scraper).

**Meine Empfehlung:** Englisch durchziehen (konsistent zu candidates/accounts/mandates/jobs/processes).

### 3.2 Tab-Count-Inkonsistenzen

| Detailseite | Freeze v1.9 | Schema v0.1 | Delta |
|-------------|-------------|-------------|-------|
| Kandidaten | 10 | 10 | ✅ OK |
| Accounts | **10** | **13 + 1 konditional** | **⚠ +3 Tabs** (Assessments, Schutzfristen, Reminders) |
| Mandate | 6 | 6 | ✅ OK |
| Prozesse | Vollseite impliziert | 3 Tabs + Drawer-primär | **⚠ Architektur-Widerspruch** |
| Jobs | nicht dokumentiert | 6 | **⚠ Freeze fehlt** |
| Firmengruppen | nicht dokumentiert | 6 | **⚠ Freeze fehlt** |
| Assessments | nicht dokumentiert | 5 | **⚠ Freeze fehlt** |
| Projekte | nicht dokumentiert | 6 | **⚠ Freeze fehlt** |
| Scraper | nur `/scraper` erwähnt | 6 | **⚠ Freeze detailliert fehlt** |

### 3.3 Fehlende Freeze-Kapitel für v1.10

**5 komplette Detailseiten fehlen in Section 4d:**
- 4d.4a Jobs-Detailmaske (6 Tabs)
- 4d.4b Firmengruppen-Detailmaske (6 Tabs)
- 4d.5 Assessment-Detailmaske (5 Tabs)
- 4d.6 Projekt-Detailmaske (6 Tabs)
- 4d.7 Scraper-Control-Center (6 Tabs)

**2 bestehende Kapitel überarbeiten:**
- 4d.2 Account-Detailmaske: 10 → 13 Tabs
- 4c Processes: Vollseite → Mischform (Drawer-primär)

### 3.4 Design-System-Konsistenz

✅ **Konsistent:** Alle Farb-Tokens (Gold, Teal, Dunkelblau, Green, Red, Amber, Blue, Purple), Backgrounds, Dark Mode only, CSS-Prefix `ark-*`, Drawer-Breite 540px, Keyboard-Bar-Klasse `kb-hint-item`.

✅ **Keine Konflikte** bei Keyboard-Shortcuts.

### 3.5 Prozess-Architektur-Widerspruch (P0)

**Freeze v1.9 Section 4c:** *"Prozesse → Vollseite `/processes/[id]`"*
**Schema v0.1 § 0:** *"Mischform — 80% Drawer (540px), 20% Vollseite (nur für Deep-Linking + komplexe Fälle)"*
**Entscheidung 2026-04-13 (nach v1.9):** Mischform bestätigt.

→ Freeze v1.10 muss Section 4c für Prozesse klarstellen.

---

## 4. TEIL IV — STAMMDATEN-AUDIT (v1.2 → v1.3)

### 4.1 Fehlende dim_*-Tabellen (12)

**TIER 1 — P0 (sofort, ~8h):**
- `dim_rejection_reasons_internal` (Prozess interne Ablehnungsgründe)
- `dim_honorar_settings` (21/23/25/27% Staffel — existiert in DB aber nicht in Stammdaten-Export dokumentiert)
- `dim_culture_dimensions` (6 Dimensionen der Kultur-Analyse)
- `dim_sia_phases` (Klärung nötig, siehe 4.2)

**TIER 2 — P1 (Phase 1.5, ~12h):**
- `dim_scraper_types` + `dim_scraper_global_settings`
- `dim_matching_weights` + `dim_matching_weights_project`
- `dim_vacancy_rejection_reasons`
- `dim_firmengruppen` (bestehend? oder neu?)

**TIER 3 — P2 (Phase 2, ~6h):**
- `dim_reminder_templates`
- `dim_time_packages`
- `dim_dokument_categories` (aktuell inline-Enums pro Detailseite)
- `dim_user_preferences` (pro-User-Einstellungen wie Matching-Schwelle)

### 4.2 SIA-Phasen-Widerspruch (P0)

- **Projekt-Spec § 6.5:** "11 SIA-Phasen" (Multi-Select)
- **ARK_BKP_CODES_STAMMDATEN.md:** "6 Phasen + 12 Teilphasen" (hierarchisch, total 18)
- **Stammdaten-Export v1.2:** SIA nur fragmentarisch erwähnt, keine klare Tabelle

**Klärung:** ❓ Peter — welche Zählung ist richtig? 6 Haupt-Phasen (SIA 112) oder 11 (mit Teilphasen zusammengefasst) oder 18 (voll ausdifferenziert)?

**Empfehlung:** 6 Haupt-Phasen als `dim_sia_phases` + 12 Teilphasen als optionale Sub-Hierarchie via `parent_phase_id`. Projekt-Spec anpassen auf "6 Haupt-Phasen + optional Teilphasen".

### 4.3 Enum-Abdeckung

| Enum-Feld | Status |
|-----------|--------|
| `dim_rejection_reasons_candidate` | ✅ 13 Gründe dokumentiert |
| `dim_rejection_reasons_client` | ✅ 16 Gründe dokumentiert |
| `dim_rejection_reasons_internal` | ❌ **FEHLT** |
| `dim_vacancy_rejection_reasons` | ❌ **FEHLT** |
| `dim_jobbasket_rejection_types` | ✅ 2 Typen |
| `process_status` Enum | ✅ 8 Status dokumentiert |
| `project_status` Enum | ✅ 6 Status dokumentiert |
| `account_status` Enum | ⚠ Definiert in Specs (Active/Prospect/Inactive/Blacklisted), aber nicht in Stammdaten als Katalog |
| `finding_type` Enum | ❌ 10 Finding-Typen nur in Scraper-Spec |

### 4.4 Sparten / Cluster / Functions / Focus

✅ Vollständig und konsistent in Stammdaten v1.2. Hierarchie (Cluster → Subcluster) korrekt abgebildet.

### 4.5 BKP-Katalog

✅ Vollständig dokumentiert (~425 Codes, 4 Ebenen, 1465 SIA-Verknüpfungen, Blue/White-Collar-Kategorisierung).

### 4.6 Abdeckung-Summary

- **31 Sektionen in v1.2** ✓
- **12 dim_*-Tabellen fehlen**
- **1 Widerspruch (SIA-Phasen-Zählung)**
- **Gesamtabdeckung: ~77% der Spec-Anforderungen**

---

## 5. TEIL V — CROSS-SPEC-KONSISTENZ-AUDIT

### 5.1 P0 Kritische Widersprüche

**P0.1 — Status-Enum-Mischung Deutsch/Englisch:**
- Mandat-Status: `Entwurf / Aktiv / Abgeschlossen / Abgebrochen / Abgelehnt` (Deutsch)
- Prozess-Status: `Open / On Hold / Rejected / Placed / Stale / Closed / Cancelled / Dropped` (Englisch)
- Job-Status: `scraper_proposal / vakanz / aktiv / besetzt / geschlossen / abgelehnt` (Deutsch)
- Assessment-Status: `offered / ordered / partially_used / fully_used / invoiced / cancelled` (Englisch)

**Klärung:** ❓ Peter — Sprache-Standard für DB-Enums?
**Meine Empfehlung:** **Englisch durchziehen** (internationale Standard, cleaner Code).

**P0.2 — Schutzfrist-Gruppen-Scope nicht in Account Tab 9 angezeigt:**
- Firmengruppe-Interactions TEIL 8 sagt: bei Vorstellung entstehen 2 Einträge (`scope=account` + `scope=group`)
- Account-Schema v0.1 § 13 zeigt nur `scope=account` im Tab 9
- **→ AM übersieht gruppenweit geltende Fristen**

**Action:** Account-Schema v0.2 + Interactions v0.3 müssen `scope=group`-Einträge mit Label "Gruppen-Schutzfrist" zeigen.

**P0.3 — Account-Interactions-Tab-Nummerierung (TEIL 8/8b/8c):**
- Statt sequenzieller TEIL 8→9→10 hat v0.2 `TEIL 8 / TEIL 8b / TEIL 8c / TEIL 9` → Cross-References verwirrend
- **Fix:** Umbenennen zu `TEIL 8a/8b/8c/9` oder `TEIL 8/9/10/11`

**P0.4 — Prozess-Stage-Name "expose" vs. "Exposé":**
- DB-Enum: `expose` (ASCII)
- UI-Label: `Exposé` (UTF-8)
- **Risiko:** Rendering-Fehler oder Doppel-Definition

**Standard festlegen:** Enum in backticks (`'expose'`), Label normal ("Exposé"). In allen Specs harmonisieren.

### 5.2 P1 Wichtige Inkonsistenzen

**P1.1 — Snapshot-Bar-Slot-Anzahl variiert 5-7:**
| Detailseite | Slots |
|-------------|-------|
| Prozess, Assessment | 5 |
| Account, Firmengruppe, Job, Projekt, Scraper | 6 |
| Mandat | **7** (Outlier) |

**Design-Regel fehlt.** Bei Tablet/Mobile-Responsive wird 7 Slots eng.
**Empfehlung:** Max 6 Slots festlegen; Mandat reduzieren (z.B. Shortlist + Longlist-Count zusammenfassen).

**P1.2 — Breadcrumb-Tiefe variiert 2-4-stufig:**
| Detailseite | Tiefe |
|-------------|-------|
| Kandidat, Account, Mandat, Firmengruppe, Projekt | 2 |
| Scraper | 1 |
| Job, Prozess, Assessment | 4 (Account/Mandat/Kandidat → X → Detail) |

**Konsistenz-Pass nötig:** einheitliche Regel für alle Detailseiten.

**P1.3 — Header-Option-B-Referenz nicht überall:**
Kandidat, Account, Mandat erwähnen explizit "Header Variante B (voller Header scrollt mit Content)". Prozess, Job, Assessment, Projekt, Firmengruppe, Scraper nicht.
**Fix:** alle Schema-§-1 Design-System-Sektion angleichen.

**P1.4 — Fehlende RBAC-Konsistenz:**
- Mandat-Kündigung-Freigabe: AM oder Admin-only? Widerspricht in Mandat-Interactions (AM) vs. impliziter Account-Kultur (Admin)
- Claim stellen: AM (Owner) in Account v0.2, aber Admin-only im Firmengruppen-Kontext?

**Action:** Master-RBAC-Matrix als eigenes Dokument in `/wiki/concepts/berechtigungen-matrix.md`.

### 5.3 Dead-Links

| # | Referenz in | Ziel | Status |
|---|-------------|------|--------|
| DL1 | Firmengruppe-Schema § 14 + Interactions-Ende | `detailseiten-nachbearbeitung.md` in `/specs/` | ❌ Datei nicht dort, sondern in `/wiki/meta/` — Pfad korrigieren |
| DL2 | Account-Schema § 23 | Interactions v0.2 Tab 8/9 | ✅ OK (v0.2 existiert) |
| DL3 | Account-Interactions v0.2 TEIL 8b | "Mandat-Detailseite Tab 1 Sektion 6b" | ✅ OK |
| DL4 | Diverse Specs | Wiki `[[referral-programm]]` | ✅ Wiki-File existiert |

### 5.4 Tab-Count-Inventar (final)

| Detailseite | Tabs | Snapshot-Slots | Breadcrumb-Tiefe | Architektur |
|-------------|------|----------------|-------------------|-------------|
| Kandidat | 10 | ? | 2 | Vollseite |
| Account | 13 + 1 cond. | 6 | 2 | Vollseite |
| Firmengruppe | 6 | 6 | 2 | Vollseite |
| Mandat | 6 | 7 ⚠ | 2 | Vollseite |
| Job | 6 | 6 | 4 ⚠ | Vollseite |
| Prozess | 3 | 5 | 4 ⚠ | **Mischform** |
| Assessment | 5 | 5 | 4 ⚠ | Vollseite |
| Projekt | 6 | 6 | 2 | Vollseite |
| Scraper | 6 | 6 | 1 | Vollseite |

---

## 6. TEIL VI — END-TO-END-WORKFLOW-AUDIT

### 6.1 Workflow A — Placement-Chain (75% complete)

**Gaps:**
- **A-1 (P1):** Referral-Payout-Trigger nur Pseudo-Code, keine präzise Spezifikation für Condition/Billing-Integration
- **A-2 (P1):** Placement-Transaktion Rollback-Semantik fehlt (was passiert wenn Mandat-Billing-Insert fehlschlägt?)
- **A-3 (P2):** Garantiefrist-Auto-Close-Batch nicht durchdacht (Timeout bei Kunderückmeldung?)
- **A-4 (P1):** `fact_candidate_presentation`-Insert-Timing ambiguitär — gehört in Gate-2-Completion (CV-Versand)

### 6.2 Workflow B — Mandats-Kündigung (60% complete)

**Gaps:**
- **B-1 (P0):** Kündigungs-Rechnung-Logik (80%-Formel) ist im Konzept, aber nicht in Mandat-Interactions spezifiziert
- **B-2 (P1):** Longlist-Locking erwähnt, aber nicht implementiert (Feld/Action?)
- **B-3 (P2):** Schutzfrist-Opening bei Kündigung vs. Prozess-Absage — Unterscheidung klar?
- **B-4 (P2):** Exklusivitätsbruch-Enforcement fehlt (3-Wochen-Frist-Check)

### 6.3 Workflow C — Scraper-Finding-Chain (85% complete)

**Gaps:**
- **C-1 (P1):** `stammdaten_drift` und `anomaly_detected` sind Alerts, kein Cross-Entity-Create — klar?
- **C-2 (P2):** Duplicate-Detection-Algorithmus unter-spezifiziert (String-Similarity-Schwellwert?)
- **C-3 (P2):** Scraper-Run-State bei Fehler unklar (Findings `pending_review` oder `error_transient`?)

### 6.4 Workflow D — Schutzfrist-Claim-Chain (50% complete)

**Gaps:**
- **D-1 (P1):** Presentation-Insert-Timing (= A-4) — wann exakt?
- **D-2 (P1):** Rückwirkende Gruppen-Schutzfrist-Inserts bei Member-Add — Batch-Job-Pattern fehlt
- **D-3 (P1):** Info-Request-Flow Detail fehlt (wer setzt `info_requested_at`? Email-Template?)
- **D-4 (P0):** Claim-Billing-Template fehlt (Vorlage_Rechnung_Direkteinstellung.docx?)
- **D-5 (P0):** Claim-Billing-Logik: Target-Mandat-Konditionen vs. Erfolgsbasis-Staffel — welcher Pfad?

### 6.5 Workflow E — Assessment-Auftrag-Chain (95% complete)

**Keine Major Gaps.** Minor:
- **E-1 (P2):** Credits-Verfall entfernt aber UI-Hinweis "Verfallen nicht" fehlt in Schema
- **E-2 (P2):** Multi-Mandat-Zuordnung als offen markiert (aktuell default: 1:1)

### 6.6 Workflow F — Job-Lifecycle (85% complete)

**Gaps:**
- **F-1 (P2):** `vacancy_changed`-Finding-Accept — welche Job-Felder werden auto-gesynct?
- **F-2 (P2):** Scraper-Proposal-Rejection — Soft-Delete oder Hard-Delete?

### 6.7 Workflow G — Firmengruppe-Bildung (70% complete)

**Gaps:**
- **G-1 (P1):** Scraper-UID-Matching-Algorithmus unspezifiziert (Zefix API? Threshold?)
- **G-2 (P2):** Manuelle Firmengruppe-Erstellung — UI-Button/Drawer-Spec fehlt
- **G-3 (P1):** Gruppenübergreifendes Mandat-Billing-Split-Logik unklar

### 6.8 Workflow H — Kandidat-Werdegang ↔ Projekt-Integration (60% complete)

**Gaps:**
- **H-1 (P1):** Kandidaten-Schema v1.2 Briefing-Tab hat noch **keine Projekt-Integration-Spec** — muss in Nachbearbeitung v1.3
- **H-2 (P1):** Autocomplete-Confidence-Flow nur in Projekt-Spec beschrieben, nicht in Kandidat-Spec

### 6.9 Übergreifende Muster

1. **Transactional Atomicity Gaps:** 8 Multi-Step-Kaskaden ohne Rollback-Semantik
2. **Missing Event Definitions:** 50+ Events in Specs, Event-System-Konzept unvollständig
3. **Race Conditions:** Simultaner Scraper + AM-Action auf gleichem Kandidat
4. **Timestamp Ambiguity:** Schutzfrist-`starts_at` Definition unpräzise
5. **External Integration underspecified:** SCHEELEN, Zefix, Email-Templates, 3CX — keine Fallback-Patterns
6. **Permission Matrix Inconsistencies:** Mehrere Specs widersprechen sich bei RBAC

---

## 7. KONSOLIDIERTE ACTION-ROADMAP

### 7.1 P0 — Blocker (Woche 1-6)

**DB-Schema v1.3 (parallel, 4-6 Wochen):**
- [ ] Wave 1: Assessment + Mandat-Optionen + Schutzfrist + Firmengruppen + Scraper (17 Tabellen)
- [ ] Wave 2: Projekt-Modul (10 Tabellen) + Matching + Prozess-Interviews
- [ ] 12 Widersprüche auflösen (siehe 1.3)

**Backend v2.5 (parallel, 3-4 Wochen):**
- [ ] 10 P0-Events registrieren
- [ ] 7 P0-Worker implementieren
- [ ] 25 P0-Endpunkte implementieren
- [ ] 8 Atomic Transactions designen + testen
- [ ] WebSocket-Infrastruktur (Scraper-Dashboard + Review-Queue)
- [ ] Rate-Limiting für Scraper (Token-Bucket + Concurrent-Limit)

**Frontend Freeze v1.10 (1-2 Wochen):**
- [ ] Route-Entscheidung Englisch vs. Deutsch (Firmengruppen, Projekte)
- [ ] 5 neue Kapitel (Jobs, Firmengruppen, Assessments, Projekte, Scraper)
- [ ] Account-Tab-Count 10 → 13 aktualisieren
- [ ] Prozess-Architektur Mischform klarstellen

**Stammdaten v1.3 (1 Woche):**
- [ ] TIER 1 dim_*-Tabellen (4 Stück)
- [ ] SIA-Phasen-Zählung klären + dokumentieren
- [ ] account_status-Enum-Katalog

**Cross-Spec-Harmonisierung (1 Woche):**
- [ ] Status-Enum-Sprache festlegen + alle Specs harmonisieren (P0.1)
- [ ] Account-Tab 9 Schutzfristen-Gruppen-Scope einbauen (P0.2 → Account v0.3)
- [ ] Account-Interactions TEIL-Nummerierung umbenennen (P0.3)
- [ ] Expose vs. Exposé Convention festlegen (P0.4)

**Workflow-Lücken schliessen:**
- [ ] Mandat-Interactions v0.3: Kündigungs-Flow komplett (B-1)
- [ ] Claim-Billing-Template + Workflow-Spec (D-4, D-5)

### 7.2 P1 — Wichtig (Woche 4-12)

**DB:**
- [ ] Wave 3 Stammdaten-Kataloge + Kultur-Erweiterungen + Kandidat-Erweiterungen

**Backend:**
- [ ] 14 P1-Events + 10 P1-Workers + 18 P1-Endpunkte
- [ ] Event-Scope-Registry für Multi-Entity-Events
- [ ] 12 Setting-Keys in dim_automation_settings

**Frontend Freeze:**
- [ ] Breadcrumb-Konsistenz-Pass (2-stufig standardisieren)
- [ ] Snapshot-Bar max. 6 Slots

**Workflow:**
- [ ] Placement-Transaktion Rollback-Semantik (A-2)
- [ ] Presentation-Insert-Timing festlegen (A-4, D-1)
- [ ] Info-Request-Flow Detail (D-3)
- [ ] Longlist-Locking (B-2)
- [ ] Scraper-UID-Matching-Algorithmus (G-1)
- [ ] Gruppen-Mandat-Billing-Split (G-3)

### 7.3 P2 — Polish (Phase 1.5+)

- [ ] Mockup-HTMLs für alle neuen Detailseiten
- [ ] Admin-UIs für konfigurierbare Settings
- [ ] External-Integration-Specs (SCHEELEN, Zefix, Email-Templates, 3CX)
- [ ] AI-Prompts pro Scraper-Typ (Prompt-Library)
- [ ] Duplicate-Detection-Algorithmus-Details (C-2)

---

## 8. OFFENE KLÄRUNGSFRAGEN AN PETER

1. **Route-Sprache:** Englisch (`/company-groups`, `/projects`) oder Deutsch (`/firmengruppen`, `/projekte`) durchziehen?
2. **Status-Enum-Sprache:** Deutsch oder Englisch? (Aktuell Mix)
3. **SIA-Phasen-Zählung:** 6 Haupt + 12 Teil (= 18 total) vs. 11 (aus Projekt-Spec) — welche Struktur?
4. **Mandat-Kündigungs-Freigabe:** AM alleine oder Admin-only?
5. **Claim stellen (Schutzfrist):** AM (Owner) oder Admin-only?
6. **`dim_jobs` vs. `fact_jobs`:** Nur `fact_jobs` operativ, oder auch ein Stammdaten-Katalog?
7. **`fact_assessment_run.result_version_id`:** Neue Tabelle `fact_candidate_assessment_version` oder Feld-Versionierung?
8. **`fact_projects.volume_chf_exact` vs. `volume_range`:** Redundanz — beide behalten mit Auto-Compute, oder nur eins?
9. **`fact_projects.cluster_ids` JSONB vs. `bridge_project_clusters`:** JSONB pragmatisch oder normalisierte Bridge?
10. **Claim-Billing-Logik:** Bei Mandats-Prozess → Target-Stage-3-Betrag? Bei Erfolgsbasis → Staffel (21-27%)?
11. **Schutzfrist-Scope bei Mandat-Kündigung:** Nur konkret vorgestellte Kandidaten oder auch Longlist-Idents?
12. **Longlist-Locking bei Mandat-Kündigung:** Explizites Requirement oder optional?
13. **Scraper-UID-Matching:** Welche Quelle? Zefix-API? Welche Confidence-Schwelle?
14. **Assessment-Multi-Mandat-Zuordnung:** Bei 1:N bleiben oder N:N einführen?

---

## 9. NEUE/ERWEITERTE DOKUMENTE NÖTIG

### Muss neu erstellt werden:
- `ARK_DATABASE_SCHEMA_v1_3.md` (grosse Erweiterung)
- `ARK_BACKEND_ARCHITECTURE_v2_5.md` (Events + Workers + Endpunkte)
- `ARK_FRONTEND_FREEZE_v1_10.md` (5 neue Kapitel + Updates)
- `ARK_STAMMDATEN_EXPORT_v1_3.md` (12 dim_* hinzufügen)
- `wiki/concepts/berechtigungen-matrix.md` (Master-RBAC)
- `wiki/concepts/transactional-patterns.md` (Atomare Operationen)
- `wiki/concepts/event-scope-registry.md` (Multi-Entity-Events)
- `wiki/concepts/external-integrations.md` (SCHEELEN, Zefix, 3CX, Email)
- `Vorlage_Rechnung_Kündigung_Mandat.docx` (fehlt aktuell, nur erwähnt)
- `Vorlage_Rechnung_Direkteinstellung-Claim.docx` (neu für Schutzfrist-Claim)

### Muss aktualisiert werden:
- `ARK_ACCOUNT_DETAILMASKE_INTERACTIONS_v0_3.md` (Schutzfrist-Gruppen-Scope, TEIL-Nummerierung)
- `ARK_ACCOUNT_DETAILMASKE_SCHEMA_v0_2.md` (Tab 9 Gruppen-Einträge, Credits-Übersicht Tab 8)
- `ARK_MANDAT_DETAILMASKE_INTERACTIONS_v0_3.md` (Kündigungs-Flow, Longlist-Locking)
- `ARK_KANDIDATENMASKE_v1_3.md` (Schema + Interactions — Projekt-Autocomplete, Assessment-Auftrags-Referenz)
- `ARK_MANDAT_DETAILMASKE_SCHEMA_v0_2.md` (`linked_project_id` optional)
- `ARK_JOB_DETAILMASKE_SCHEMA_v0_2.md` (`linked_project_id` optional)

---

## 10. SCHLUSS-BEWERTUNG

**Die Detailseiten-Specs sind inhaltlich stark**, aber zwischen **Specs und Grundlagen-Infrastruktur gibt es massive Dokumentations-Lücken**, die vor einer Implementierung geschlossen werden müssen.

**Funktions-Kritische P0-Blocker:**
1. DB-Schema-Integration (26 neue P0-Tabellen)
2. Backend-Events + Workers + Endpunkte (25 P0-Endpunkte, 7 P0-Worker, 10 P0-Events)
3. Mandat-Kündigungs-Flow komplett spezifizieren
4. Schutzfrist-Claim-Billing-Workflow + Template
5. Schutzfrist-Gruppen-Scope durchziehen in Account-Spec

**Best-Case Zeithorizont zur Implementierungs-Readiness:** 6-8 Wochen parallel-Spec-Work + 10-12 Wochen Implementierung.

---

## Related

[[detailseiten-guideline]], [[detailseiten-inventar]], [[detailseiten-nachbearbeitung]], [[mandat-lifecycle-gaps]]
