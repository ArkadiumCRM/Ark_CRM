## [2026-04-30] feat | B4 Phase-3-Patches (DB v1.7 · Backend v2.9 · FE v1.14)

- created: `specs/ARK_DATABASE_SCHEMA_PATCH_v1_6_to_v1_7_email_queue.md` (~5.8 KB)
  - `fact_email_send_queue` (20 Spalten · 3 Indizes · RLS · `worker_service` BYPASS)
  - 2 neue Enums: `email_send_status` · `email_error_class` (9 Klassen)
- created: `specs/ARK_BACKEND_ARCHITECTURE_PATCH_v2_8_to_v2_9_phase1a.md` (~14.5 KB)
  - 22 Stammdaten-Vollansicht-Endpoints (13 Read · 9 Mutation · Konsistenz 22/22)
  - `email-send.worker.ts` + `email-send-drain.worker.ts` (BullMQ · FOR UPDATE SKIP LOCKED · Batch-20)
  - 8 Failure-Klassen mit Backoff-Schedules + 4 neue Events
  - Power-BI-Embed-Token-Endpoint mit Service-Principal-Auth
- created: `specs/ARK_FRONTEND_FREEZE_PATCH_v1_13_to_v1_14_phase1a.md` (~11.0 KB)
  - Route `/stammdaten` + 4 Sub-Patterns + 8 Kategorie-Slugs + Sidebar Group 3 „System"
  - Outbox-Indicator + Mini-Drawer (540px) + Dead-Letter-Banner + TanStack-Polling 30s
  - Power-BI-Iframe-Tile-Pattern + Token-Lifecycle (60 min TTL · 50 min Refresh) + 4 States
- approach: Subagent (general-purpose mit Sonnet) für 3-Patch-Run · single commit
- commit: `355155a` · 1470 Insertions
- NEEDS-USER-INPUT (2): Azure-AD-App für Power-BI (Nenad) · Polling-vs-WS-Decision (PW)

---

## [2026-04-30] fix | ERP-Tools-Lint-Pass · 51 Files audited

- audited: 51 Mockup-Files in `mockups/ERP Tools/{billing,commission,elearn,hr,zeit}/`
  - billing/: 9 Files (alle clean)
  - commission/: 6 Files (1 Fix)
  - elearn/: 20 Files (1 Wrap)
  - hr/: 7 Files (2 Wraps)
  - zeit/: 10 Files (2 Wraps)
- pre-lint: 0 Umlaute-Violations · 4 DB-Tech-Hits · 21 Snake-Case-Hits
- fixes:
  - commission-admin.html: `paid_abschlag` → `Ausgezahlt · Rücklage` (SAFE-FIX User-Label)
  - 4× ark-lint-skip-Wraps für legitimate Admin/Spec-Ref-Content
- approach: Subagent (general-purpose mit Sonnet)
- commit: `e86c806` (5 Mockups + lint-violations.md)
- 🎯 **drift-log Action Item #2 [2026-04-20] RESOLVED**
- 🎯 **drift-log [2026-04-20] vollständig closed** — alle 5 Action Items resolved heute

---

## [2026-04-30] chore | Performance Tier-2/3 Pattern-Konsistenz + OS-Theme

- Task A: Drawer-Pattern-Konsistenz · 4 Files (revenue · team · business · reports) · 12 Drawer mit `data-drawer-key=` additiv ergänzt
- Task B: `data-open-drawer` Standardisierung · funnel.html · 5 HTML-Trigger entfernt, JS-Delegation behalten (sibling-conform)
- Task C: `prefers-color-scheme` Media-Query · alle 11 Files · `:root:not([data-theme="light"])` Override-Pattern
- approach: Subagent (general-purpose mit Sonnet) für Diversity-Rotation
- lint: 0 Umlaute · 0 neue DB-Tech-Violations
- commit: `6568897` · 11 Files · +287/-17 Zeilen
- Phase-3-B1a komplett: 19 Drawer (P0+P1) + Tier-2/3-Polish abgeschlossen

---

## [2026-04-30] fix | Performance-Mockup P0-Lint-Fixes (Tier-3)

- updated: `mockups/ERP Tools/performance/performance-dashboard.html`
- fix: 3× Umlaute-Substitut `ueber` → `über` (Z. 1376 Tile-Type-Desc, Z. 1531 Anomaly-Hint, Z. 1620 Forecast-Formel)
- audit: Sonnet-Subagent über 11 Perf-Files
- audit-Korrektur: 2 vermutete DB-Tech-Violations (reports.html L878/884, admin.html L514) waren bereits in `ark-lint-skip`-Blöcken — Audit-Miscount
- defer Tier-2: Drawer-Pattern-Konsistenz (4 Files mit `id=drawer-...` vs `data-drawer-key=`), data-open-drawer-Standardisierung, prefers-color-scheme, Mobile-Breakpoints — eigene Folge-Session

---

## [2026-04-30] update | Performance-Mockup P1-Drawers (Phase-3-B1a Continuation)

- updated: 6 Performance-Sub-Page-Mockups · +1050 Zeilen total
  - performance-funnel.html (1087 → 1177)
  - performance-coverage.html (1385 → 1507)
  - performance-revenue.html (1742 → 1917)
  - performance-mitarbeiter.html (1527 → 1621)
  - performance-reports.html (1133 → 1363)
  - performance-admin.html (1118 → 1457)
- added: 11 P1-Drawer per Spec §4.2-§4.8
  - funnel-process (Funnel · §4.2)
  - coverage-account (Coverage · §4.3)
  - revenue-attribution + forecast-override (Revenue · §4.4 · Duplicate-Pattern statt Extract)
  - goal-edit (Mitarbeiter · §4.5)
  - template-config + template-new (Reports · §4.7)
  - metric-new + anomaly-threshold + dashboard-default + snapshot-lag (Admin · §4.8)
- approach: Continuation-Subagent (general-purpose) nach Codex-Gate-Release
- backups: `backups/performance-*.html.2026-04-30-<HHMM>.bak`
- lint: 0 Umlaute · 0 DB-Tech · 540px Drawer-Width konsistent
- spec-compliance: 59% → 91% (31/34 Drawer MATCH)
- commit: `f9e9b93`
- Phase-3.1-Verdict: **GO** — P0+P1 alle abgeschlossen, alle 4 Flow-Specs (§5.1-§5.5) unblocked

---

## [2026-04-30] update | Performance-Mockup P0-Drawers (Phase-3-B1a)

- updated: `mockups/ERP Tools/performance/performance-dashboard.html` (1297 → 2075 Zeilen, +778)
- updated: `mockups/ERP Tools/performance/performance-insights.html` (1675 → 2077 Zeilen, +402)
- added: 8 P0-Drawer per Spec §4.1 + §4.6
  - Dashboard: tile-add · tile-edit · tile-explain · tile-drill (Customize-Flow §5.1)
  - Insights: action-create · action-detail · action-update · action-followup (Closed-Loop §5.2)
- approach: Subagent (general-purpose) — Audit-Driven, additive-only, kein Codex (Encoding-Regression-History)
- backups: `backups/performance-{dashboard,insights}.html.2026-04-30-1545.bak`
- lint: 0 Umlaute-Violations · 0 DB-Tech in User-Text · 540px Drawer-Width konsistent
- spec-compliance: 38% → 59% (20/34 Drawer MATCH)
- commit: `7903d68`
- offen: P1-High (10 Drawer) + Tier-2 (Konsistenz, Responsive) + Tier-3 (Lint-all-Files, Test-Daten) → Folge-Session

---

## [2026-04-30] create | Power-BI-Integration Plan v0.1

- created: `specs/ARK_POWER_BI_INTEGRATION_PLAN_v0_1.md` (~25 KB · 14 Sections)
- updated: `wiki/meta/overview.md` — Open Questions Power-BI + Outlook strikethrough mit Spec-Refs
- updated: `wiki/meta/drift-log.md` — Resolution-Block + Phase-1-A-Closing-Note
- approach: Konsolidierung 70% (Performance-Modul-Merge 2026-04-25) + 30% Greenfield-Identifikation
- Quellen-Inventar: 4 Layer (DB/Backend/Stammdaten/Frontend) mit File+Line-Refs
- Greenfield-Areas: Workspace-Setup · RLS-DAX-Mapping · Gateway · Embed-Token-Flow · Governance · Monitoring
- Phasen-Plan: 5 Phasen, Phase-0+1 ~3h Specs, Phase-2-3 ~8h Implementation
- offene Fragen: 10 für PW + Nenad-Stakeholder-Review

**Phase-1-A Closing — alle 6 Items abgeschlossen heute:**
- A5 ERP-Specs Directory ✅
- A2 Admin-Debug Spec ↔ Mockup-Alignment ✅
- A1 Stammdaten-Vollansicht Schema + Interactions ✅
- A3 Outlook-Failsafe-Konzept ✅
- A6 Detached-HEAD-Hook ✅
- A4 Power-BI-Integration Plan ✅

---

## [2026-04-30] update | SessionStart-Hook · Detached-HEAD-Detection

- updated: `.claude/hooks/session-overview.ps1` (+~50 Zeilen)
- new: `git rev-parse`-Branch-Check + 4-fach-Klassifizierung (main/HEAD/?/other)
- new: Branch-Status-Zeile in Session-Overview (`**Git-Branch:** ...`)
- new: prominenter DETACHED-HEAD-Warnungs-Block mit Recovery-Anleitung
- new: leichtgewichtiger Branch-Hinweis bei Non-Main-Branch (kein Hard-Block)
- verifiziert: Hook-Run auf main produziert `main OK` im Output
- drift-log: Action Item #1 [2026-04-20] RESOLVED
- Variante H1 (SessionStart-Warning) gewählt statt H2 (PreToolUse-Block) wegen Edit-Performance

---

## [2026-04-30] create | Outlook-Failsafe-Konzept + Send-Queue-Retry-Policy

- created: `wiki/concepts/outlook-failsafe.md` (~10.5 KB · 7 Sections)
- approach: Index + Konsolidierung existierender Specs + neue Send-Queue-Retry-Policy
- coverage:
  - Token-Lifecycle (bereits spec'd in Email-Spec §Token-Erneuern + Backend-v2.8 §42)
  - Admin-Surface-Mapping (Email-Modul · Admin Tab 1 · Admin Tab 9 Sub-Tabs 9-1/9-2/9-3)
  - **Send-Queue-Retry-Policy NEU** — Failure-Klassifizierung (8 Error-Klassen), Backoff-Schedules, `fact_email_send_queue`-Tabelle, `email.send.worker.ts`
  - Send-Queue-Drain bei Token-Reauth
  - User-Surface (Compose-Toast · Outbox-Indicator · Dead-Letter-Drawer)
  - MS-Graph Komplett-Outage-Verhalten (verlinkt zu Runbook 4)
- Findings: 80% bereits spec'd, eigentliche Lücke war Send-Queue-Retry beim Email-Send (5xx/429/Timeout)
- offene Fragen: 5 (Queue-Tabelle vs fact_event_queue, Webhook-Verlust-Watchdog, Slack-Notification, Banner-Scope, Retention)
- pending Patches (Folge-Session): DB v1.6 → v1.7 (email_send_queue), Backend v2.8 → v2.9 (Failsafe), Frontend v1.13 → v1.14 (Outbox)

---

## [2026-04-30] create | Stammdaten-Vollansicht Schema + Interactions v0.1

- created: `specs/ARK_STAMMDATEN_VOLLANSICHT_SCHEMA_v0_1.md` (~34 KB · 15 Sections)
- created: `specs/ARK_STAMMDATEN_VOLLANSICHT_INTERACTIONS_v0_1.md` (~32 KB · 13 Sections)
- updated: `wiki/meta/spec-sync-regel.md` — System-Vollansichten 1 → 2 (Admin + Stammdaten)
- updated: `wiki/meta/drift-log.md` — Action Item #4 [2026-04-20] Stammdaten-Vollansicht-Spec RESOLVED
- approach: Reverse-Engineering aus Plan v0.1 + Mockup (3955 Zeilen) — analog Admin-Debug-Resolution 2026-04-28
- scope: 8 Tabs · 67 Kataloge · ~5 365 Einträge · Browse-Modus (alle Rollen) + Edit-Modus (admin · audit-pflichtig) · ~22 Endpoints
- key features: Single-Truth-Pflege (`→ Admin`-Tag für Templates) · Locked/External-Catalogs · Multi-Lang DE/EN/FR · Konflikt-Resolution · Batch-Import-CSV · FK-Schutz · Optimistic-Update
- pending: 3 Grundlagen-Patches (Backend v2.9, Frontend v1.14, Gesamt v1.6) — Folge-Session
- offene Fragen Schema: 8 · Interactions: 8

---

## [2026-04-28] update | Admin-Debug-Schema v1.0 → v1.1 (Tab-Integration)

- updated: `specs/ARK_ADMIN_DEBUG_SCHEMA_v1_0.md` (in-place, Filename behalten — 8 Cross-Refs würden brechen)
- patches: §0 ZIELBILD (Single-Page-Route → Tab 9), §2 ROUTING (Hash-Routes), §15 Sync-Plan, §16 Fertigstellungs-Kriterium
- Header: v1.1 + Update-Note erklärt Migration
- Realität: Tab 9 „Debug" mit Sub-Tabs (Event-Log, Saga-Traces, Dead-Letter, Circuit-Breaker, Rules) seit längerem in `mockups/Vollansichten/admin.html` (Z. 2026+) implementiert
- Drift-log: Action Item #5 [2026-04-20] Admin-Debug-Mockup-Klärung RESOLVED

---

## [2026-04-28] update | ERP-Specs-Verzeichnis migriert nach specs/

- moved: 19 Spec-Files von `ERP Tools/specs/` → `specs/` (`git mv`)
  - Billing (×6): SCHEMA, INTERACTIONS, PLAN, RESEARCH_CLAUDE/GEMINI/GPT
  - HR (×8): PLAN_v0_1/v0_2, RESEARCH_v0_1/v0_2, STRATEGY_DECISION_v0_1/v1_0, RESEARCH_SYNTHESE, COMMISSION_ABGLEICH_HANDOFF
  - Zeiterfassung (×2): PLAN, RESEARCH_ADDENDUM
  - Eval (×2): LUCCA, SWISSDECTX
  - Commission (×1): ENGINE_SPEC_v0_1
- removed: `ERP Tools/specs/ARK_HR_TOOL_INTERACTIONS_v0_1.md` (Legacy, ersetzt durch `specs/`-Version 2026-04-25)
- removed: `ERP Tools/specs/ARK_HR_TOOL_SCHEMA_v0_1.md` (durch `ARK_HR_TOOL_SCHEMA_PATCH_v0_1_to_v0_2.md` + `_SCHEMA_v0_2.md` ersetzt)
- removed: `ERP Tools/specs/` (leeres Verzeichnis)
- updated path refs: log.md (this), wiki/meta/spec-sync-regel.md, wiki/meta/decisions.md, wiki/meta/drift-log.md, wiki/concepts/provisionierung.md, wiki/analyses/hr-schema-deltas-2026-04-19.md, specs/ARK_COMMISSION_ENGINE_SPEC_v0_1.md, specs/ARK_BILLING_*.md (×3), specs/ARK_BACKEND_ARCHITECTURE_PATCH_v2_6_to_v2_7_billing.md, specs/ARK_STAMMDATEN_PATCH_v1_4_to_v1_5_billing.md, specs/ARK_DATABASE_SCHEMA_PATCH_v1_4_to_v1_5_billing.md, specs/ARK_HR_TOOL_PLAN_v0_1/v0_2.md
- backup: `backups/erp-tools-specs.2026-04-28-1858/` (21 Files)
- resolution: drift-log.md Action Item #3 [2026-04-20] RESOLVED

---

## [2026-04-25] create | Performance-Modul Wiki-Konzept

- created: wiki/concepts/performance-modul.md
- updated: index.md (neue Sektion "Phase-3 ERP" unter Concepts)

Stakeholder-Doku für Performance-Modul (Cross-Modul-Analytics-Hub):
- Was/Warum/Wer
- 8 Architektur-Decisions (Q1-Q8 vom 2026-04-25)
- Datenquellen + Datenmodell-Highlights (TEIL Q v1.6)
- Backend-Architektur (TEIL R v2.8) + Closed-Loop-Saga
- Frontend-Pattern (11 Mockups Inventar, TEIL Q Frontend-Freeze v1.13)
- Closed-Loop-Narrativ (Coverage-ARC-Beispiel)
- Forecast-Methodik (Markov-Stage v0.1)
- Stammdaten-Statistik
- Cross-Links zu Specs/Patches/Memory/Wiki
- Roadmap Phase 3.1 → 3.4

Stil analog wiki/concepts/interaction-patterns.md.

## [2026-04-25] sync-report | Spec-Mockup-Sync-Report

- created: wiki/analyses/sync-report-2026-04-25.md
- updated: index.md
- Hauptbefund: 4 Performance-Patches (STAMMDATEN/DB/BACKEND/HR-Patch v1.5→v1.6 etc.) NICHT in Grundlagen gemerged. 5 Digests stale. 9 Entity-Detail-Specs mit Stale-Source-Frontmatter. 4 Performance-Mockup-Drifts (UMLAUT-Substitute + Sub-Page-App-Bar).

## [2026-04-19] ingest | HR-Tier-2 (Einführungsordner + Academy-Module + Mitarbeiter-Tools)

**Kontext:** Nach Spec-Triade Plan-v0.2 + Schema-v0.1 + Interactions-v0.1 Tier-2-Ingest zur Content-Erweiterung.

**Ingestiert (~9'500 Zeilen):**
- Einführungsordner: Hausordnung ZH Tödistrasse (DOCX) + Maneggstrasse (PDF) · Arkadium am Markt · Glossary · Communication Edge I/II/Anhang (DOCX) · M4 Modell + 16 M-Module (PDFs)
- Mitarbeiter-Ordner: Personalstammdaten-Formular · Smarttime-Anleitung · Abwesenheitsantrag · Spesen-Vorlage

**Key-Fund — Treuhand Kunz:**
Aus `Personalstammdaten_Arkadium.docx` identifiziert: Arkadium-Payroll-Treuhänder = **Treuhand Kunz** · Email `office@treuhand-kunz.ch` · Memory `reference_treuhand_kunz.md` geschrieben · Plan-§11B-2-Entscheidung (Bexio-CSV + Swissdec-ELM) bleibt kompatibel.

**Pages created (sources, 4):**
- `wiki/sources/hr-einfuehrungsordner-starterinfo.md` — 30 operative Themen (Arbeitszeit · Krankheit · Dresscode · Reporting-Di-Mo · Kandidaten-Empfang · etc.)
- `wiki/sources/hr-academy-communication-edge.md` — CE Part I + II + Anhang (Hamburger · 7 Grundsätze · VAKOG · Pacing/Leading · 20 Einwandbehandlungs-Techniken · Nutzenargumentation)
- `wiki/sources/hr-academy-m4-modell.md` — M4-Modell · 4 Hauptprozesse (MEET/MATCH/MARKET/MONEY) · 16 Teilprozesse mit Rolle-Zuordnung CM/AM/Research · Mapping zu CRM-Prozess-Stages + Praemium-Victoria §6.2
- `wiki/sources/hr-mitarbeiterordner-tools.md` — Personalstammdaten-Formular-Felder mit HR-Tool-Mapping · Smarttime-Kontext (wird durch Phase-3-Zeiterfassung abgelöst) · Abwesenheits-Flow · Spesen-Pauschale vs Extra-Spesen (separates Modul)

**Pages created (memory, 1):**
- `memory/reference_treuhand_kunz.md`
- `memory/MEMORY.md` Index erweitert

**Schema-Deltas für v0.2** (noch nicht eingebaut):
- `dim_mitarbeiter` Erweiterungen: `email_private` · `heirat_datum` · `partner_erwerbstaetig` · `kinder JSONB` · `konfession` · `quellensteuer_pflichtig` · `quellensteuer_kanton`
- `fact_hr_documents.document_type` Erweiterung: `personalstammdaten_formular` · `spesenabrechnung_monat` · `smarttime_export` · `hausordnung_akzeptiert_signatur` · `schluesselquittung` · `glossary_acknowledged`
- Zusätzliche Config-Keys in `dim_automation_settings`: `arbeitsbeginn_spaetestens_uhrzeit` · `feiertags_vorabend_arbeitsschluss` · `mittagspause_von_bis` · `reportingwoche_start_dow` · `dresscode_client_default`

**Key Onboarding-Template-Konkretisierung:**
Consultant-14-Wochen-Template aus Starterinfo + M-Module + Communication Edge rekonstruiert (siehe `hr-einfuehrungsordner-starterinfo.md` §Onboarding-Template-Tasks). Researcher-8-Wochen reduziert.

**Nicht eingebaut (Tier-3+ · andere Session):**
- Schulungen-Alt-Ordner (40+ PDFs historische Schulungen + GoPro-Videos · Tier 5)
- 3_Assessements (Leitfaden Hunt · Mental Health · Senior Consultant · Speed Recruiting · Tier 4)
- 5_Ausbildungsplan · Severina-Ordner (Tier 2+)

**Schema-Updates eingebaut 2026-04-19 (in-place):**
- §2 `dim_mitarbeiter` +7 Felder (email_private · heirat_datum · partner_erwerbstaetig · kinder JSONB · konfession · quellensteuer_pflichtig · quellensteuer_kanton)
- §11.1 `fact_hr_documents.document_type` +6 Enum-Werte (personalstammdaten_formular · spesenabrechnung_monat · smarttime_export · hausordnung_akzeptiert_signatur · schluesselquittung · glossary_acknowledged)
- §13 Config-Keys +10 (Arbeitsbeginn-Uhrzeit · Mittagspausen · Reportingwoche-DOW · Dresscode-Defaults · Treuhand-Kunz-Email · Payroll-Export-Formats)
- §14.7b neu: Onboarding-Template-Seeds für Consultant-14-Wochen (6 Phasen · 35+ Tasks mit Academy-Module-Codes) + Researcher-8-Wochen (5 Phasen · 20+ Tasks)
- Changelog §18 ergänzt · keine Breaking Changes · nur ADD-Operationen

**Next:** Mockup-Iteration · Commit aller HR-Arbeit · oder Tier-3/4-Ingest (Assessments-Leitfäden · Schulungen-Alt).

---

## [2026-04-19] create | HR-Tool-Interactions v0.1 (UI-Flows + Saga + Events)

**Kontext:** Nach Schema v0.1 → Interactions v0.1 als UI-Definitions-Spec.

**Pages created:**
- `ERP Tools/specs/ARK_HR_TOOL_INTERACTIONS_v0_1.md` — 10 Sections · 19 Drawer-Defs · 5 Lifecycle-Saga-Flows · 13 Worker · 29 Event-Codes mit Subscriber-Matrix · RBAC-UI-Gates

**Scope:**
- **§1 Global Patterns:** Drawer-Breiten (540/760/Sheet) · Sensible-Daten-Masking-Flow mit `reveal_sensitive`-Audit · Optimistic-Update · kein Drag-Rückwärts (Annullierung via Kontext-Menü)
- **§2 Dashboard:** Header · Alert-Cards (8 aus `v_hr_alerts`) · Action-Queue · Team-Matrix 18 MA × 7 Tage · Kanban 7 Spalten · MA-Liste
- **§3 MA-Side-Panel:** 8 Accordion-Sektionen (Stammdaten · Vertrag · Absenzen · Academy · Zertifikate · Dokumente · Warnings · Provisionsvertrag)
- **§4 Drawer-Inventar (19):** Neuer MA 4-Tab · Vertrag-Edit · Ferienantrag (mit Extra-Guthaben-Saldo-Sidebar) · Krankmeldung (Arzt-Staffel-Anzeige) · HO-Antrag (48h + Quota + Team-Coverage) · Schulung · Zertifikat · Weiterbildungsvereinbarung · Dokument · Probezeit-Abschluss · Verwarnung · Disziplinar (mit GL-Gate + MA-Notification-Constraint) · Provisionsvertrag-Renewal · Kündigung · Annullierung · Aufhebungsvereinbarung · Reglement-Signatur · Extra-Guthaben-Bezug · Arbeitszeugnis via Dok-Generator
- **§5 Lifecycle-Saga:** Happy-Path · Verwarnungs-Eskalation · Offboarding-Branches · Role-Transition (Grace-Period) · Annullierung
- **§6 Worker + Events:** 13 Worker + 29 Event-Codes mit Subscriber-Matrix
- **§7 Self-Service-UI:** `/hr/me` · erlaubte vs nicht-erlaubte Actions · DSG-Auskunft-Export
- **§8 Mobile-Support:** P0/P1/P2-Priorisierung · Full-Screen-Sheet-Pattern · Desktop-Only für CRUD-heavy
- **§9 RBAC-UI-Gates:** Tabellarische Berechtigungs-Matrix pro UI-Element

**Key-Interaction-Features:**
- Ferienantrag-Drawer zeigt Saldo-Sidebar mit allen 5 Extra-Guthaben-Kategorien inkl. Verfügbarkeits-Constraints (Geburtstagswoche, ZEG-Sperrfristen)
- Disziplinar-Drawer enforcet §11C-4-Constraint UI-seitig: Offset-Toggle nur wenn `gl_approved_at` + `ma_notified_at + 1 Mt` vorhanden
- Neuer-MA-Drawer (4 Tabs) schließt mit Bündel-PDF-Generate + Signatur-Flow (MA + Head + Founder)
- Kündigungs-Drawer enthält §11C-11-Override-Toggle "Extra-Guthaben trotz Kündigung gewähren"
- Arbeitszeugnis-Generator ist Link zu `/operations/dok-generator` (nicht eigenes Drawer)

**Offene Punkte für Interactions v0.2:**
- UI-Wireframes einbinden (derzeit nur Text-Struktur)
- WebSocket-Channel-Definition
- Validation-Rules Zod/Yup-Schemas
- Accessibility-Audit WCAG AA
- Performance-Targets

**Sync-Scope:** keine Grundlagen-Änderung · HR-Tool bleibt Phase-3-ERP-standalone.

**Next:** Mockup-Iteration (hr.html + neue: hr-warnings-disciplinary.html, hr-provisionsvertrag-editor.html, hr-academy-dashboard.html, hr-mitarbeiter-self.html) · oder Commit aller HR-Arbeit heute.

---

## [2026-04-19] create | HR-Tool-Schema v0.1 (DDL)

**Kontext:** Nach PO-Review-Abschluss Plan v0.2 → Schema v0.1 als komplettes DDL.

**Pages created:**
- `ERP Tools/specs/ARK_HR_TOOL_SCHEMA_v0_1.md` — 18 Sections · alle 18 PO-Entscheidungen eingearbeitet

**Scope:**
- **28 Tabellen:** 12 dim · 15 fact · 1 audit (`audit_hr_access`)
- **4 Views:** `v_hr_alerts` (8 Alert-Typen inkl. Jubiläums-Alert · Scheelen-Cert-Missing) · `v_next_lohn_payment_date` · `v_training_repayment_obligations` · (erweiterbar)
- **11 Config-Keys** in `dim_automation_settings` (Lohnlauf-Kalender · HO-Coverage · Scheelen-Threshold etc.)
- **7 Seed-Blöcke:** Scheelen-Zertifikate (alle 4 Pflicht) · Reglemente (3 Themen 2024-01-01) · Job-Descriptions (11 Rollen) · Academy-Module (21 Module M/Comm-Edge/Lernkarteien) · Absence-Types (17 inkl. Extra-Guthaben) · Feiertage ZH 2026 · Disziplinar-Typen (8 während + post-AV)
- **29-Schritt-Migration** mit Rollback-Pfad
- **RBAC-Matrix** HR-Erweiterung (HR_Manager · Team_Lead · Employee_Self · Academy_Trainer)

**Key Schema-Features:**
- `dim_mitarbeiter.commission_rate` als DEPRECATED kommentiert (ersetzt durch `fact_provisionsvertrag_versions`) · kein DROP in v0.1 für Rückwärtskompatibilität
- `fact_employment_contracts.kuendigungsfristen_jsonb` als JSONB statt fixem INT (Dienstjahr-Staffelung)
- `dim_absence_types.certificate_rule_type = 'staffelung_by_dienstjahr'` + `certificate_staffelung_jsonb` für Krankheits-Staffelung
- `fact_vacation_balances` mit 5 Extra-Guthaben-Kategorien (Geburtstag-Self · Geburtstag-Close · Joker · ZEG-H1 · ZEG-H2) + GL-Discretionary + Override-Felder für §11C-11-Kulanzregel
- `fact_disciplinary_incidents` CHECK-Constraint erzwingt GL-Approval + 1 Mt MA-Vorankündigung vor Payroll-Offset
- `fact_provisionsvertrag_versions.is_active` GENERATED erfordert alle 3 Signaturen (MA + Head + Founder)
- `fact_role_transitions.grace_period_ends_at` GENERATED für §5.3-Praemium-Victoria-3-Mt-Clock

**Offene Punkte für Schema v0.2:**
- Trigger-Definitionen für `fact_absences.certificate_required` (computed)
- Ostern-Worker für jährliche `carry_deadline_date`
- Partitioning-Strategie bei Wachstum (>100k Rows)
- RLS-Policies ausformulieren
- Test-Data-Fixtures

**Sync-Scope:** HR-Tool bleibt Phase-3-ERP-standalone (Memory `project_phase3_erp_standalone.md`) · keine direkten Grundlagen-Änderungen (STAMMDATEN/DB-SCHEMA/BACKEND/FRONTEND/GESAMTSYSTEM). Nach Go-Live werden relevante Teile in Grundlagen zurückgeführt (dann Spec-Sync mit 5 CRM-Grundlagen).

**Next:** `ARK_HR_TOOL_INTERACTIONS_v0_1.md` (UI-Flows · Drawer-Interaktionen · Use-Case-Workflows aus Plan §5 + §7).

---

## [2026-04-19] update | HR-Tool-Plan v0.2 · PO-Review abgeschlossen (18/18 Fragen beantwortet)

**Kontext:** 1-to-1-Review mit Peter direkt nach Plan-v0.2-Create. Alle 18 offene Fragen aus §11B (6) + §11C (12) beantwortet.

**Key-Entscheidungen (Abweichungen vom Plan-v0.2-Vorschlag):**
- Arbeitszeugnis-Generator ist **kein eigenes HR-Feature** → läuft über globalen Dok-Generator (analog ARK CV/Abstract/Exposé)
- Scheelen-Zertifikate: **alle 4 (MDI · Relief · ASSESS · EQ) Pflicht für alle Rollen** (nicht rollen-selektives Mapping)
- Praemium-Victoria-Zyklus **Kalenderjahr fix** (nicht Geschäftsjahr · Vorlagen-Beispiel 01.04.–31.12. war Übergangs-Fall)
- Disziplinar-Lohn-Verrechnung: **GL-Approval + 1 Mt MA-Vorankündigung** (strenger als 2-Augen-Prinzip)
- Extra-Guthaben-Verfall: Default **ab Kündigungs-Einreichung** mit **HR-Override-Toggle** für Kulanzfälle
- Academy-Trainer: **Multiple Trainer je Modul** (keine eigene RBAC-Rolle `Academy_Lead`)
- Alumni-Konkurrenzverbot-Monitor: **GF-Ermessen**, kein automatisierter Flow
- Reglement-Versionierung: **Fall-zu-Fall-HR-Entscheidung** (nicht semver-Automatik)
- Honorarstreitigkeit: **manuell durch Backoffice** (keine dedizierte Tabelle)
- Annullierung der Kündigung: **Kontext-Menü + Drawer** (kein Kanban-Drag-Rückwärts)

**Vorschläge bestätigt (10/18):** Payroll-Formate · Lohnausweis-Auto-Import · Notfallkontakt max 2 · Dienstjubiläum-Alert · Geburtstag Opt-in · Annullierung-UI · Scheelen-Alle-Pflicht · Lohnkalender-Config · Head-Signatur-Pflicht · Provisionsvertrag-Kalenderjahr.

**Pages updated:**
- `ERP Tools/specs/ARK_HR_TOOL_PLAN_v0_2.md` Status `draft` → `po-reviewed` · §11 komplett überschrieben mit Entscheidungen + Schema-Impact pro Frage · Next-Steps aktualisiert · PO-Review-Log ergänzt

**Next:** `ARK_HR_TOOL_SCHEMA_v0_1.md` + `ARK_HR_TOOL_INTERACTIONS_v0_1.md` schreiben mit allen finalisierten Entscheidungen. Parallel Mockup-Iteration (hr.html · neue: hr-warnings-disciplinary.html · hr-provisionsvertrag-editor.html · hr-academy-dashboard.html).

---

## [2026-04-19] create | HR-Tool-Plan v0.2 (supersedes v0.1)

**Kontext:** Peter-Antwort "A" zu Next-Step-Frage nach Ingest. Konsolidierung Plan v0.1 + Schema-Deltas + Sprach-Policy-Klarstellung.

**Peter-Feedback:**
- Sprachen: **DE only** · EN-Anforderung im Progressus-Template ist Legacy, real kaum gebraucht · Memory `project_sprache_policy.md` geschrieben
- Option A gewählt (Plan v0.2 konsolidieren) statt B/C/D

**Pages created:**
- `ERP Tools/specs/ARK_HR_TOOL_PLAN_v0_2.md` — 14 Sections · v0.1 supersedet · 6/12 v0.1-Fragen beantwortet · 8 neue Entitäten integriert · 2 neue Phasen (3.7 Disziplinar · 3.8 Praemium-Renewal) · 12 neue offene Fragen

**Pages updated:**
- `C:\Users\PeterWiederkehr\.claude\projects\C--ARK-CRM\memory\project_sprache_policy.md` (neu)
- `C:\Users\PeterWiederkehr\.claude\projects\C--ARK-CRM\memory\MEMORY.md` (+1 Eintrag)
- `wiki/analyses/hr-schema-deltas-2026-04-19.md` (§1 Frage 7 DE-only-Antwort)
- `wiki/sources/hr-stellenbeschreibung-progressus.md` (Template-Drift-Hinweis)

**Plan-v0.2-Key-Deltas vs v0.1:**
- `dim_mitarbeiter.commission_rate` **deprecated** → ersetzt durch `fact_provisionsvertrag_versions`
- `fact_employment_contracts` erweitert: Karenzentschädigung · Kündigungsfristen-JSONB · Konkurrenzverbot-Region statt km-Radius · Disziplinarstrafen-Referenz
- Neue Tabellen: `dim_reglemente` · `fact_contract_attachments` · `dim_job_descriptions` · `fact_provisionsvertrag_versions` · `fact_role_transitions` · `dim_academy_modules` · `fact_academy_progress` · `fact_training_agreements` · `fact_warnings` · `dim_disciplinary_penalty_types` · `fact_disciplinary_incidents` · `fact_homeoffice_requests` · `fact_homeoffice_quota_usage`
- `dim_absence_types` Seeds erweitert: Arztzeugnis-Dienstjahr-Staffelung · CH-spezifische Dienste (Zivilschutz/Rotkreuz/Feuerwehr) · 5 Extra-Guthaben-Kategorien (Geburtstag/nahestehend/Joker/ZEG/GL-Ermessen)
- `fact_vacation_balances` erweitert: 5 Extra-Kategorien + Ostern+14-Deadline
- Lifecycle-Stages erweitert: Bewerber raus · 3 Offboarding-Branches · Under-Watch + Final-Watch
- Events +18 neue Codes · `v_hr_alerts`-View erweitert
- UI-Scope: 3 neue Mockups + 7 neue Drawer

**Next:** PO-Review mit Peter → §11B (6 v0.1-offen) + §11C (12 neu) beantworten → dann `ARK_HR_TOOL_SCHEMA_v0_1.md` + `_INTERACTIONS_v0_1.md` schreiben.

---

## [2026-04-19] ingest | HR-Vertragswerk Tier-1 (Arbeitsverträge · Reglemente · Provisionsverträge · Zeugnisse · Weiterbildung · Stellenbeschreibung · Kündigung · Austritts-Merkblätter)

**Kontext:** Peter hat HR-Ordner in `raw/HR/` abgelegt. Tier-1 (schema-relevant) ingestiert: 26 DOCX + 2 AXA-PDFs. Tier 2–5 (Mitarbeiter-Ordner, Methodik-Schulungen, Assessments, Historisch) ausgelassen für spätere Session.

**Pages created (sources, 8):**
- `wiki/sources/hr-arbeitsvertraege.md` — 4 Arbeitsvertrags-Vorlagen (2 Consultant · 2 Researcher-Varianten), 13 Ziffern, Konkurrenzverbot 18 Mt, Kündigungs-Staffelung (3 Tage Probezeit · 1/2/3 Mt ab Dienstjahr)
- `wiki/sources/hr-reglemente.md` — DRUCK-Varianten der 3 Reglemente: Generalis Provisio (Allg. Anstellung, §4 Academy) · Tempus Passio 365 (45h/Wo · 25 Ferientage · Extra-Guthaben Geburtstag/Joker/ZEG) · Locus Extra (HO 20 + Remote 10 Tage/Jahr)
- `wiki/sources/hr-provisionsvertraege.md` — "Praemium Victoria" (CM + Team Leader + Entwurf), ZEG-Staffel 30–150%+, 80/20-Vorschuss-Split, Halbpunkt-System (CM · AM), §5.3 Rollenwechsel-Regel 3 Mt
- `wiki/sources/hr-arbeitszeugnisse.md` — 3 Templates (Arbeitsbestätigung + Consultant + Researcher) mit Academy-Intro-Boilerplate + Checkliste-PDF (leer extrahiert, OCR nötig)
- `wiki/sources/hr-weiterbildungsvereinbarung.md` — Pensum-Reduktion + CHF 2'500/Semester Arbeitgeber-Anteil + Rückzahlungs-Staffel 100/50/25% bei Austritt 12/18/24 Mt nach Abschluss
- `wiki/sources/hr-stellenbeschreibung-progressus.md` — 2 Progressus-Vorlagen Consultant + Research Analyst, 9-Feld-Header, Tätigkeits-Deltas (Debitoren/Onboarding-Kunden nur Consultant)
- `wiki/sources/hr-kuendigung-aufhebung.md` — 4 Sonderfall-Vorlagen: Annullierung seitens AG · Aufhebungsvereinbarung Freistellung · Aufhebung nach Kündigung · Letzte Verwarnung
- `wiki/sources/hr-austritt-versicherung-merkblaetter.md` — AXA-KKV (14739DE) + AXA-Abredeversicherung (16747DE) Pflicht-Merkblätter mit Unterschriften-Rückläufer

**Pages created (concepts, 4):**
- `wiki/concepts/hr-vertragswerk.md` — 5-Schicht-Modell (Arbeitsvertrag + 3 Reglemente + Progressus + Praemium Victoria) mit lateinischen Eigennamen, Widerspruchs-Regel
- `wiki/concepts/hr-academy.md` — Ausbildungssystem: 3 Fachgebiete (A/B/C), 3 Teile, Communication Edge 1-3, M4 Modell, M 1-4 Module, Geschäftsgeheimnis-Schutz nach Art. 321a OR
- `wiki/concepts/hr-konkurrenz-abwerbeverbot.md` — 18 Mt Deutschschweiz · Karenzentschädigung CHF 500/350 als Kompensation · Konventionalstrafen CHF 80k min / CHF 20k Disziplinar / CHF 20k Geheimhaltung
- `wiki/concepts/hr-ma-rollen-matrix.md` — MA-Rollen aus Arbeitsrecht-Sicht (Researcher · Consultant · CM · AM · Team Leader · Head · Founder), Delta-Analyse Consultant vs Researcher, Organigramm-Seeds

**Pages created (analyses, 1):**
- `wiki/analyses/hr-schema-deltas-2026-04-19.md` — Plan-v0.1-Erweiterungen: 12 Plan-§11-Fragen beantwortet · 8 neue Entitäten (`dim_reglemente`, `dim_academy_modules`, `dim_disciplinary_penalty_types`, `fact_warnings`, `fact_provisionsvertrag_versions`, `fact_training_agreements`, `dim_job_descriptions`, `fact_role_transitions`) · 2 neue Phasen (3.7 Disziplinar + 3.8 Provisionsvertrag-Renewal) · 12 neue offene Fragen

**Pages updated:**
- `index.md` — Neue Sources-Sektion "HR & Vertragswerk" (+8), Concepts-Sektion "HR & Anstellung" (+4), Analyses +1 · Counts 50→58 / 41→45 / 7→8
- `log.md` — diese Entry

**Key Findings (Plan-kritisch):**
- Arztzeugnis-Pflicht: Dienstjahr-Staffelung (1 DJ → Tag 1, 2 DJ → Tag 2, 3+ DJ → Tag 3), nicht fester Threshold
- Ferien: 25 Tage + 5+ Extra-Guthaben-Kategorien (nicht als eine `allocated_days`-Zahl modellierbar)
- Kündigungsfristen als JSONB statt einzelner INT (Dienstjahr-Staffelung)
- Karenzentschädigung = monatliches Gehalt-Addon (CHF 500/350), nicht nachvertragliche Zahlung
- Reglemente + Provisionsvertrag brauchen eigene versionierte Tabellen (jährliche Erneuerung Praemium Victoria)
- Disziplinar-Katalog (6 während AV + 3 post-AV) fehlt komplett in Plan v0.1

**Sync-Scope:** Keine Grundlagen-Änderung · keine Spec-Änderung. `ARK_HR_TOOL_PLAN_v0_1.md` als Nächstes zu v0.2 weiter­entwickeln (Optional — Peter entscheidet).

**Tier-2+ offen (nicht diese Session):** Einführungsordner (22 Schulungs-PDFs · M 1-4 Module · Communication Edge · Glossary) · Mitarbeiter-Ordner-Struktur · Assessments-Leitfaden · Smarttimes.

---

## [2026-04-18] update | Admin-Vollansicht Komplettisierung (P3-Restpunkte)

**Kontext:** Restpunkte aus Sync-Report abgearbeitet (Inventar-Eintrag, Konzept-Doku, Wiederverwendungs-Patterns, Mobile-Edge-Case).

**Pages updated:**
- `wiki/meta/detailseiten-inventar.md` — neue Sektion „System-Vollansichten": S1 Admin · S2 HR-Tool (Phase 2)
- `wiki/meta/mockup-baseline.md` — §17 „Admin-Vollansicht-Patterns" mit 12 Snippets (Admin-Warn · Flag-Row · Matrix-Editor · Builder · Sub-Tabs · Health-Dot · CB-Card · Queue-Meter · Variable-Chips · Priority-Seg · Channel-Chips · Drawer-Wide)
- `wiki/meta/spec-sync-regel.md` — Admin als Single-Write-Entry-Point kodifiziert
- `index.md` — Concepts 40→41

**Pages created:**
- `wiki/concepts/admin-system.md` — Konzept-Übersicht mit 10-Tab-Struktur, Architektur-Konzepten (Single-Write · CB · Vier-Augen · Legal-Hold · DSG · Template-Versionierung · Settings-Change-Events), Tabellen, Worker, Sagas
- `mockups/admin-mobile.html` — Mobile-Demo mit 2 iPhone-Frames + Annotation-Sidebars

**Mobile-Strategie pro Tab:**
- Voll mobile-tauglich: Tab 1 · 5 · 9 (Live-Status) · 10 (Read-Only)
- Read-Only mobile: Tab 2 · 6 · 7
- Desktop-Only: Tab 3 · 4 · 8 (CRUD-heavy → Disabled-Hinweis + Deep-Link an Outlook)

**Lint:** Alle Admin-Mockups clean (admin.html · admin-mobile.html · admin-dashboard-templates.html · scraper.html). Admin-Context-Codes via `ark-lint-skip reason=admin-config-key` / `admin-event-type` gewrapped.

---

## [2026-04-17] create | Mobile-/Tablet-Support komplett (v1.3.6) — Phasen 1–3.5

**Kontext:** Frontend-Rewrite von „Tablet Read-Only + Mobile Blocker" zu vollem Mobile-+-Tablet-Support. Breakpoints Desktop > 960 / Tablet 641–960 / Mobile ≤ 640.

**Phase 1 App-Shell + Demo:**
- `mockups/crm.html` responsive (Top-Bar + Slide-Out-Sidebar + Tablet-Pin-Toggle + Safe-Area-Inset)
- `mockups/crm-mobile.html` (neu) — 3 Device-Frames (iPhone 375×740 · iPad 820×620 · Desktop 1100×680) mit iframe-Embed + Sub-Page-Wähler

**Phase 2 Content-Responsive:**
- `mockups/_shared/editorial.css` — globale Mobile-Rules (KPI 2-col, DataTable → Card-Stack, Drawer → Sheet, Filter-Bar/Tabs scroll, Touch-Targets)
- Pro-Mockup @media-Blocks: dashboard · reminders (Kalender scroll) · email-kalender (3-Pane → Toggle) · dok-generator (Sidebar → Drawer) · processes (Pipeline-Popover) · candidates · accounts · mandates · projects (Gewerke-3-Tier) · scraper · admin · admin-dashboard-templates
- jobs/groups/assessments nur via editorial.css-Erbe

**Phase 3 Viewport + Grundlagen v1.11:**
- Viewport-Meta in 22 Mockup-HTMLs (21 via sed + admin.html manuell)
- `ARK_FRONTEND_FREEZE_v1_10.md` v1.10.5 → v1.11: §24b Responsive-Policy rewrite, Prinzip 6 umformuliert
- `ARK_GESAMTSYSTEM_UEBERSICHT_v1_3.md` v1.3.5 → v1.3.6: TEIL 24 Nachtrag

**Phase 3.5 Touch-Gesten + A11y:**
- `mockups/reminders.html` — Swipe-to-Complete (80 px threshold, grün-Feedback)
- `mockups/email-kalender.html` — Pane-Swipe-Back (right/left Navigation)
- `mockups/crm.html` — Focus-Trap Mobile-Sidebar (aria-modal, Tab-Cycle, Last-Focus-Restore)
- `mockups/_shared/layout.js` — Drawer-Focus-Trap global für alle `.drawer.open`

**Digests (alle regeneriert):** frontend-freeze · gesamtsystem · backend-architecture · database-schema
**STALE-Log:** clean-marker 2026-04-17 18:18

**Offen (Blocker):** Device-QA-Pass · Screen-Reader-Audit · Performance-Messung — braucht echtes Device/AT, nicht Code-machbar

---

## [2026-04-17] analysis | Spec-Mockup-Sync-Report nach Admin-Vollansicht

**Kontext:** Drift-Scan nach Abschluss Admin-Vollansicht-Mockup (`mockups/admin.html`) und Begleit-Specs (`ARK_ADMIN_VOLLANSICHT_SCHEMA_v0_1.md` + `ARK_ADMIN_VOLLANSICHT_INTERACTIONS_v0_1.md`). 3 Datenquellen gelesen: `grundlagen-changelog.md` · `digests/STALE.md` · `lint-violations.md`.

**Ergebnis:** 9 unresolved Changelog-Einträge · 2 stale Digests · 10 neue Admin-Artefakte (Tabellen/Events/Sagas) noch nicht in Grundlagen.

**Top-3-Critical (P0):**
1. DB-Schema-Patch erweitern um 4 neue Admin-Tabellen
2. Backend-Arch-Patch erweitern um 12 Events + 3 Sagas
3. scraper.html Lint-Fix (5 persistente SNAKE-CASE/UMLAUT Violations)

**Pages created:**
- `wiki/analyses/sync-report-2026-04-17.md` — Full-Report mit Coverage-Matrix + priorisierten Empfehlungen

**Pages updated:**
- `index.md` — Analyses-Count 6→7

**Offen:** Grundlagen-Patches (P0), RBAC-Matrix-Update für `head_of_department`-Regel (P1), Digest-Regen (P1).

---

## [2026-04-17] create | Admin Vollansicht — Mockup + 2 Specs (Mockup-First-Workflow)

**Kontext:** 4. Tool-Maske `/admin` ergänzt Settings/Team/Stammdaten. 10 Tabs in 1 Vollansicht (Feature-Flags · Automation-Regeln · Reminder-Templates · Email · Telefonie · Scraper · Notifications · Dashboard-Templates · Debug · Audit/Retention). Zielgruppe: ausschließlich Rolle `admin` (HoD entfernt).

**Neue Mockup-Datei:**
- `mockups/admin.html` — 2 225 Zeilen · 10 Tabs · 8 Drawer (Flag · Rule-Builder mit 6 Trigger-Modi · Fee-Staffel-Matrix · Refund-4-Blöcke · Reminder/Email/Notification-Template · Event-Detail)

**Crm.html Sidebar:** neues Entry 🔧 Admin mit Badge `red 3`

**Neue Spec-Dateien:**
- `specs/ARK_ADMIN_VOLLANSICHT_SCHEMA_v0_1.md` — 18 Sektionen (Tab-Struktur · Daten-Invarianten · Routing · Berechtigungen)
- `specs/ARK_ADMIN_VOLLANSICHT_INTERACTIONS_v0_1.md` — 20 Sektionen (Flows pro Tab · API-Endpoints · Events · Sagas · Error-Handling · Deep-Links)

**Entscheidungen:**
- Settings-Hub-Variante A (ursprünglich) → umgestellt auf neue Top-Level `Admin` mit Tabs
- Dashboard-Templates bleiben in beiden Oberflächen (User-Dashboard + Admin-Defaults, verschiedene Scopes)
- Honorar-Staffel jetzt voll editierbares TC-Band×Fee% Matrix
- Refund-Staffel 4 Blöcke (Vor Start 100 % · 1. Mt 50 % · 2. Mt 25 % · 3. Mt 10 %)
- Rule-Builder flexibel statt Dropdown (6 Trigger-Modi · 12 Aktion-Typen · Condition-Builder · Custom-Events)

**Offen:** Grundlagen-Sync (siehe Sync-Report dieser Session)

---

## [2026-04-17] create | Reminders Vollansicht — 3 Specs + Mockup + Grundlagen-Sync v1.3.5

**Kontext:** Neue Tool-Maske `/reminders` als 3. Tool-Maske (neben Dok-Generator + Email-Kalender). Ergänzt — ersetzt nicht — Dashboard-Widget + Entity-Reminder-Tabs. Phase 0 Entscheidungen (7 Punkte) geklärt 2026-04-17. Phase 1–4 abgeschlossen, Phase 5 (Entity-Tab-Deep-Link-Harmonisierung) offen.

**Neue Spec-Dateien:**
- `specs/ARK_REMINDERS_VOLLANSICHT_PLAN_v0_1.md` — Ausarbeitungsplan Phase 0–5
- `specs/ARK_REMINDERS_VOLLANSICHT_SCHEMA_v0_1.md` — Layout, Design-Tokens, Permissions, Empty-States (16 §)
- `specs/ARK_REMINDERS_VOLLANSICHT_INTERACTIONS_v0_1.md` — Flows, Events, Permissions-Matrix, Keyboard (14 §)

**Neuer Mockup:**
- `mockups/reminders.html` — Liste + Kalender (Monat + Woche), Drag-to-Reschedule live, 2 Drawer (Detail 5-Tab, Neu), Keyboard-Shortcuts

**Grundlagen-Updates (stale-flagged → Digests regenerieren):**
- `ARK_DATABASE_SCHEMA_v1_3.md` v1.3.4 → v1.3.5: `fact_reminders.template_id FK` + `escalation_sent_at` · `dim_mitarbeiter.dashboard_config` JSONB-Doku für Saved-Views
- `ARK_BACKEND_ARCHITECTURE_v2_5.md` v2.5.4 → v2.5.5: 2 Events (`reminder_reassigned`, `reminder_overdue_escalation`) · 1 Worker (`reminder-overdue-escalation.worker.ts`) · 3 Endpoints (`reassign`, `GET/PATCH user-preferences/reminders`)
- `ARK_FRONTEND_FREEZE_v1_10.md` v1.10.4 → v1.10.5: §Reminders komplett erweitert
- `ARK_GESAMTSYSTEM_UEBERSICHT_v1_3.md` v1.3.4 → v1.3.5: TEIL 23 Nachtrag
- `ARK_STAMMDATEN_EXPORT_v1_3.md` unverändert (§64 passt 1:1)

**Wiki-Updates:**
- `wiki/concepts/reminders.md` — Vollansicht-Section + Eskalations-Logik + Event-Pattern
- `wiki/meta/detailseiten-inventar.md` — Tool-Masken-Sektion (3 Einträge)
- `wiki/meta/spec-sync-regel.md` — „2 Tool-Masken" → „3 Tool-Masken"
- `wiki/meta/mockup-baseline.md` — §16.12 Reminder-Typ-Labels (13 kanonische UI-Labels + Auto-Badge + Scope-Labels)
- `index.md` — `[[reminders]]`-Eintrag erweitert

**Phase 0 Entscheidungen (PO 2026-04-17):**
1. Scope — Admin/HoD: eigene+Team Default; AM/CM/RA/BO: nur eigene
2. View — Liste + Kalender-Toggle (kein Kanban)
3. Bulk-Actions — keine (Sales würde durch-snoozen)
4. Saved Views — rollen-spezifisch
5. Kalender CRM-intern (kein Outlook-Sync, Email-Kalender bleibt getrennt)
6. Auto-Regeln Admin-separat (`/admin/reminder-rules`)
7. Archiv-Cut — Erledigte > 30 d ausblenden

**Offen (Phase 5):** Entity-Tab-Footer-Links (Kandidat §10, Account §13) auf `/reminders?entity=<type>&id=<uuid>` harmonisieren.

## [2026-04-17] create | 3 Wiki-Konzepte zu Dok-Generator (v1.3.4 Spec-Sync)

**Kontext:** Abschluss Grundlagen-Sync v1.3.4 → Wiki-Konzept-Einträge gemäss Gesamtsystem-Changelog §22.5.

**Erstellt:**
- `wiki/concepts/dok-generator.md` — Haupt-Konzept Architektur, 5-Step-Workflow, Template-Katalog, Deep-Link-Integration, Kandidat-Tab-9-Migration
- `wiki/concepts/executive-report.md` — Arkadium-Assessment-Zusammenfassung (ergänzt SCHEELEN-Detail-Reports), 9-Sektionen-Struktur, Auto-Pull + manuelle Felder
- `wiki/concepts/template-versionierung.md` — Phase-2-Konzept: Semver + Admin-UI + Rollback für `dim_document_templates`

**Updates:**
- `index.md` — 3 neue Concepts unter Features-Sektion verlinkt

## [2026-04-17] sync | Grundlagen v1.3.4 + Assessment v0.3

**Kontext:** Nach Dok-Generator-Mockup + Spec-Docs wurde das Gesamtsystem durchsynchronisiert.

**Neue Spec-Dateien:**
- `specs/ARK_DOK_GENERATOR_SCHEMA_v0_1.md` (16 Sektionen, Datenmodell, RBAC, Open Points)
- `specs/ARK_DOK_GENERATOR_INTERACTIONS_v0_1.md` (16 Teile, Workflow-State-Machine, 9 Endpoints, Auto-Pull, Deep-Link)

**Umbenannt (Sync-Patch v0.2 → v0.3):**
- `ARK_ASSESSMENT_DETAILMASKE_SCHEMA_v0_2.md` → `_v0_3.md` (invoiced raus, Phase-1-Typen-Kommentar)
- `ARK_ASSESSMENT_DETAILMASKE_INTERACTIONS_v0_2.md` → `_v0_3.md` (invoiced aus State-Machine)

**Grundlagen-Updates (stale-flagged):**
- `ARK_STAMMDATEN_EXPORT_v1_3.md` §56 `dim_document_templates` (38+1 Templates)
- `ARK_DATABASE_SCHEMA_v1_3.md` §14.1-14.3 (document_label-Erweiterung · neue Tabelle · fact_documents-Erweiterung · assessment-status-fix)
- `ARK_BACKEND_ARCHITECTURE_v2_5.md` §L (9 neue Endpoints + Wrapper-Mapping + Events)
- `ARK_FRONTEND_FREEZE_v1_10.md` §4e (Dok-Generator-Detailmaske)
- `ARK_GESAMTSYSTEM_UEBERSICHT_v1_3.md` §22 v1.3.4 Changelog

**Digest-Status:** alle 5 Grundlagen-Digests stale-flagged. Agent-Regeneration läuft parallel.

## [2026-04-17] create | Email & Kalender Detailmaske v1 + Shared-Mailbox-Removal

**Kontext:** User möchte Email-Inbox zu „Email & Kalender" umbauen mit Outlook-ähnlichem Kalender in derselben Maske. Entscheidung Layout A (Segment-Toggle Email ↔ Kalender). Zusätzlich PO-Entscheidung: Architektur wechselt auf individuelle User-Tokens — kein Shared-Mailbox-Zwischenschritt mehr.

**Erstellt:**
- `mockups/email-kalender.html` (~1500 Zeilen, 97 KB) — Variante A mit Segment-Toggle · 3-Pane Email-Mode (Folders/Liste/Reader) · Kalender-Mode mit Tag/Woche/Monat-Views · 7 Drawer (Compose-Wide · Event-Wide mit Coaching-Notizen · Create-Kandidat · Create-Account · Template-Picker · Konten · Entity-Match) · Inline-Quick-Reply · Auto-Klassifikation · Team-Overlay frei/busy DSG · Full-Scope Features

**Updates:**
- `mockups/crm.html:141` Sidebar-Link „Email-Inbox" → „Email & Kalender" → `email-kalender.html`
- `Grundlagen MD/ARK_BACKEND_ARCHITECTURE_v2_5.md` — Shared-Mailbox entfernt (3 Blöcke: Outlook-Config · Phase-1/2-Ansatz · ENV-Var `OUTLOOK_SHARED_ACCOUNT`), ersetzt durch „Individuelle User-Tokens" Architektur
- `wiki/concepts/email-system.md` — v1.2-Refs → v1.3/v2.5 · neue Sektion „Ordner-Modell" (Klassifiziert/Unbekannt/Inbox/Ignoriert) · Detailmaske-Link · Individuelle-Tokens-Doku
- `wiki/meta/grundlagen-changelog.md` — 3 Backend-Edits der Session als resolved markiert + Digest-Stale-Flag dokumentiert
- `wiki/meta/lint-violations.md` — 8 Violations (5 UMLAUT cal-emp-kuerzel CSS classname · 3 SNAKE-CASE in Template-Subs) als resolved markiert

**UX-Fixes nach erstem Review:**
- Event-Drawer Tab „Coaching-Notizen" Textarea zu schmal → defensive CSS `.drawer-body textarea { width:100% }`
- 2× „+ Neuer Termin" Button → Toolbar-Duplikat entfernt (nur Banner-CTA bleibt)
- „+ Neuer Termin" ausgefleischt → `openNewEventDrawer()` resetet Formular, default auf nächste Stunde, leert Teilnehmer-Liste auf Organisator, blendet Delete + Coaching-Tab aus

**Lint-Status:** 0 Violations nach Re-Grep
**Backups:** 6+ Backup-Files (`crm.html.*.bak`, 4× `email-kalender.html.*.bak` snapshots, `ARK_BACKEND_ARCHITECTURE_v2_5.md.*.bak`, `email-system.md.*.bak`)

**Post-Review-Iterationen (Mockup):**
- Event-Drawer „Offene Punkte"-Textarea voll breit (220px Höhe) + defensive CSS `.drawer-body textarea/input { width:100% }` für alle 8 Drawer
- Toolbar-Duplikat „+ Neuer Termin" raus (nur Banner-CTA bleibt)
- `openNewEventDrawer()` ausgefleischt: leeres Formular · Start = nächste volle Stunde · Teilnehmer nur Organisator · Coaching-Tab + Delete-Button conditional ausgeblendet
- Activity-Type-Select Compose-Drawer: **11 Stammdaten-Einträge** aus v1.3 §14 (Freitext-Verstöße „Antwort Feedback Interview"/„Terminabsprache"/„Sonstiges" entfernt)
- **Datei-Picker neu:** 8. Drawer `fileAttachDrawer` (760px · 3 Tabs: Aus Kontext/Alle Dokumente/Zuletzt verwendet) · Compose-Buttons „📁 Aus CRM anhängen" + „💻 Lokale Datei" + Drag-Zone
- **CodeTwo-Integration:** Signatur-Checkbox raus, Info-Card in Compose Optionen-Tab + eigene CodeTwo-Sektion in Konten-Drawer (Status · Admin-Panel-Link · Template-Wechsel)

**Spec-Writing:**
- `specs/ARK_EMAIL_KALENDER_DETAILMASKE_SCHEMA_v0_1.md` (neu · 20 Sektionen · Layout · 8 Drawer · Activity-Type-Katalog · Backend-Referenzen · Routing · RBAC · Mockup-Referenz)
- `specs/ARK_EMAIL_KALENDER_DETAILMASKE_INTERACTIONS_v0_1.md` (neu · 17 TEILe · Architektur-Entscheidungen · Mode-Switch · Drawer-Flows · OAuth-Connect · Fuzzy-Match · Error-Handling · Globale Patterns)

**Grundlagen-Sync:**
- `Grundlagen MD/ARK_FRONTEND_FREEZE_v1_10.md` §4e Sibling-Wording · neue §4f Operations · Email & Kalender dokumentiert (Location · Architektur · Layout · Drawer-Inventar · Ordner-Modell · RBAC · Design-System-Konformität)
- `wiki/concepts/email-system.md` neue Sektion „Signatur-Management · CodeTwo"
- `wiki/meta/overview.md` Kernmodule-Tabelle: email-system auf Single-Page-Maske mit User-Tokens + CodeTwo + 38 Templates
- `index.md` email-system-Beschreibung erweitert
- `wiki/meta/spec-sync-regel.md` Tool-Masken-Kategorie neu (Dok-Generator + Email-Kalender)
- `wiki/meta/grundlagen-changelog.md` 5 unresolved Einträge (3 Backend · 2 Frontend) als resolved markiert

**Offen:** `backend-architecture-digest.md` + `frontend-freeze-digest.md` regenerieren (via Agent)

---

## [2026-04-17] create | Auto-Lint + Digest-Staleness + Anti-Patterns + Decisions + Baseline + Sync-Report

**Kontext:** Nach Digest-Umbau (erster Eintrag unten) wollte User weitere Garantien dass Assistant immer genug Context hat und nicht vom definierten Stand abweicht. Gebaut: alles ausser Current-Work-Context (User pflegt nicht manuell).

**Updates:**
- `.claude/hooks/ark-lint.ps1` — PostToolUse, scannt Edits auf `mockups/*.html`/`specs/*.md`/`wiki/*.md` nach Umlaut-Ersatz (fuer/ueber/koenn/...), DB-Tech-Details (dim_/fact_/bridge_/_id/_fk in UI), Modal-for-CRUD → schreibt nach `wiki/meta/lint-violations.md`
- `.claude/hooks/pre-edit-hint.ps1` — PreToolUse, Skill-Reminder pro Pfad-Typ (Mockup/Spec/Grundlage/Wiki/Memory) + Backup-Warning bei >5KB
- `.claude/hooks/grundlagen-changelog.ps1` — erweitert: flaggt zugehoerigen Digest als stale in `wiki/meta/digests/STALE.md` + fix stale path reference (`raw/Ark_CRM_v2/` → `Grundlagen MD/`)
- `.claude/hooks/load-grundlagen.ps1` — erweitert: auto-loaded Anti-Patterns + Decisions + Mockup-Baseline + Stale-Warning + Recent-Lint-Violations
- `.claude/hooks/session-overview.ps1` — Pfade aktualisiert (Grundlagen MD statt raw/Ark_CRM_v2)
- `.claude/commands/ark-sync-report.md` — Slash-Command fuer Spec-Mockup-Sync-Drift-Report
- `.claude/settings.json` — PreToolUse + 2. PostToolUse-Hook verdrahtet
- `wiki/meta/anti-patterns.md` — kompakte Liste "niemals tun" (UI/Sprache/Terminologie/Architektur/Datei-Ops)
- `wiki/meta/decisions.md` — append-only Decision-Log, 5 initiale Entscheidungen (Digest-Setup, Arkadium-Rolle, Schutzfrist, Drawer-Default, Briefing-Terminologie)
- `wiki/meta/mockup-baseline.md` — 1045 Zeilen, 14 copy-paste-ready Komponenten (Drawer 540/760, Stage-Pipeline 9 Dots, Snapshot-Bar, Activity-Timeline, Post-Placement-Widget, Stage-Popover, Refund-Card, ...)
- Memory: `feedback_ask_before_full_grundlagen.md` + `feedback_audit_logging.md` konsolidiert (Coverage-Liste gestrichen)
- `index.md` — 4 neue Meta-Eintraege

**Hook-Tests:** alle 3 Hooks pipe-getestet mit synthetischem stdin, JSON-Output valide, STALE.md + changelog-Eintrag erzeugt (Test-Entries als resolved markiert).

**Context-Kosten pro Session neu:** ~55k Token (42k Digests + 8k Anti-Patterns/Decisions + 12k Baseline = Summe).

---

## [2026-04-17] create | Grundlagen-Digests + Hook-Umbau (lossy-aber-auto-loaded)

**Kontext:** SessionStart-Hook `load-grundlagen.ps1` lieferte vorher ~200k Token Volltext → sprengte Inline-Output-Limit, wurde nach File persisted statt in Context geladen → Grundlagen praktisch unwirksam. User wollte Enums/Stages/Flows/Automationen ohne Re-Erklärung verfügbar haben.

**Updates:**
- `wiki/meta/digests/stammdaten-digest.md` — ~12k Token, alle Enums lossless (Activity-Types 69, Stages, Motivatoren, EQ, Sparten, Mitarbeiter-Kürzel)
- `wiki/meta/digests/database-schema-digest.md` — ~7k Token, ~160 Tabellen + Core-Relationships lossless
- `wiki/meta/digests/backend-architecture-digest.md` — ~10k Token, ~90 Events + 30 Worker + ~220 Endpoints + 8 Sagas lossless
- `wiki/meta/digests/frontend-freeze-digest.md` — ~8k Token, Routing-Map + 9 Detailmasken + Design-System-Regeln lossless
- `wiki/meta/digests/gesamtsystem-digest.md` — ~5k Token, Big Picture + Changelog v1.2→v1.3 lossless
- `.claude/hooks/load-grundlagen.ps1` — auf Digests umgebogen, Output 161KB (unter 759KB-Inline-Limit)
- `index.md` — 5 Digest-Einträge unter Meta
- `MEMORY.md` + `feedback_ask_before_full_grundlagen.md` — Regel: Assistant fragt vor Volltext-Read für Präzisions-Arbeit (exakte Spalten/Endpoints)

**Total Context-Kosten:** ~42k Token pro Session (vorher 0 weil persisted, alternativ 200k wenn Limit erhöht würde).

**Lossy weggefallen:** exakte Spalten-Types/FK-Constraints, Request/Response-Body-Schemas, CSS-Pixel-Werte, Prosa-Erklärungen, Beispiele. Pointer-Tabelle in jedem Digest verweist auf Volltext-§ in `Grundlagen MD/ARK_*.md`.

---

## [2026-04-17] update | P2 Wiki-Sync: assessment-schema `dim_assessment_types` Katalog ergänzt

**Kontext:** Letzter P2-Fix — Assessment-Wiki v0.2 war strukturell korrekt, aber der 11-Einträge-Katalog fehlte.

**Updates:**
- `wiki/sources/assessment-schema.md` — neuer Abschnitt "`dim_assessment_types` Katalog (11 Einträge)" mit type_key + display_name + partner + Musterberichts-Link
- 11 Einträge: mdi · relief · outmatch(ASSESS 5.0) · disc · eq · scheelen_6hm · driving_forces · human_needs · ikigai · ai_analyse · teamrad
- Cross-Reference zu ingesteten SCHEELEN-Musterberichten ([[musterbericht-trimetrix-eq]], [[musterbericht-relief]], [[assessment-beispiel-bewertungsergebnisse]])
- Partner-Deprecation-Note: `fact_assessment_order.partner` DEPRECATED seit v0.2, lebt jetzt auf `dim_assessment_types`
- Umwidmungs-Regel klargestellt (nur innerhalb gleichen Typs, nur bei Run-Status ≤ scheduled)

**Status:** Alle Wiki-Drift-Findings aus Scan 2026-04-17 abgearbeitet (P0: 2, P1: 1, P2: 1).

## [2026-04-17] update | P1 Wiki-Sync: mandat-schema v0.1 → v0.2

**Kontext:** Nach P0-Block (projekt/account) jetzt mandat-schema nachgezogen. v0.2 ist Audit-Konsistenz-Update vom 14.04.2026.

**Updates:**
- `wiki/sources/mandat-schema.md` v0.1 → v0.2
- **Kündigung durch AM** (Admin-Gate entfernt, Entscheidung 14.04.2026)
- **`is_longlist_locked` BOOLEAN** (sperrt Longlist bei Kündigung, verhindert Daten-Änderung vor Claim-Prüfung)
- **`is_exclusive` BOOLEAN** (Exklusivität hat kein Ablaufdatum — gilt solange Mandat offen)
- **Claim-Fälle X/Y/Z** (§14.1): X=ursprüngliche Position (Stage-Rest) · Y=andere Position (Erfolgsbasis-Deal) · Z=Firmengruppe (scope-abhängig)
- **Snapshot-Bar** 7 → 6 Slots harmonisiert (Garantie/Exklusivität als banner-chips ausgelagert)
- `index.md` — Entry-Beschreibung aktualisiert

**Offen P2:** assessment-schema `dim_assessment_types`-Katalog (11 Einträge auflisten)

## [2026-04-17] update | 2× P0 Wiki-Sync (projekt-schema v0.3 + account-schema v0.2)

**Kontext:** Drift-Scan Wiki↔Specs fand 4 veraltete Wiki-Pages (2×P0, 1×P1, 1×P2). User-Freigabe für P0-Block. Grundlagen-Wiki (L1) zero drift.

**Updates:**
- `wiki/sources/projekt-schema.md` v0.2 → v0.3 (16.04.2026-Changes): Projekt-Reports-To (firmen-übergreifend, XOR-Constraint, Cycle-Check) · Referenz-Eignung (5 Felder) · Vertragsart (pauschal/einheitspreis/globalpreis/cost_plus) + `called_volume_chf` · neue Tabelle `fact_project_company_contacts` · Team-Kontext-Felder (team_size/stakeholder_namedropping/challenges/highlights)
- `wiki/sources/account-schema.md` v0.1 → v0.2: Snapshot-Bar Slots 5+6 firmografisch (Gegründet/Standorte, nicht Mandate/Prozesse) · Arkadium-Relation-KPI-Bar (4 KPIs Umsatz YTD/Placements/Time-to-Hire/Conversion) · Kontakt-Rollen-Refactor (subjektive Flags raus, `org_function` ENUM rein, 7 Codes) · 4-Tab-Kontakt-Drawer · RBAC Founder→Admin
- `index.md` — beide Entries-Beschreibungen aktualisiert

**Offen P1/P2:** mandat-schema v0.1→v0.2 (Kündigung/Longlist-Lock/Claim) · assessment-schema dim_assessment_types-Katalog

## [2026-04-17] ingest+lint | Wiki-Lint komplett: 7 neue Sources · Index-Fix · Grundlagen-Archiv · Overview-Update

**Kontext:** User-Lint-Request "schau ob alle raw-dokumente ingested sind". Audit ergab 10+ nicht-ingestete Files, stale Index-Counts, veraltete Grundlagen-Versionen in raw/.

**Fixes:**
- `index.md` — Header-Counts korrigiert: Entities 6→7, Concepts 33→40, Analyses 4→6
- `raw/Ark_CRM_v2/archive/` angelegt, 5 alte Grundlagen-Versionen archiviert: STAMMDATEN_v1_2 · DATABASE_SCHEMA_v1_2 · BACKEND_ARCHITECTURE_v2_4 · FRONTEND_FREEZE_v1_9 · GESAMTSYSTEM_UEBERSICHT_v1_2
- **Neue Sources** (7, +1 Vision + 3 SCHEELEN-Produkte + 3 ASSESS-Trilogie anonymisiert):
  - [[vision-ark-app]] — Heritage-App Vision (separates Produkt)
  - [[assess-jobprofile]] — ASSESS Standard Job-Profile (10 Rollen · 26 Kompetenzen)
  - [[musterbericht-trimetrix-eq]] — TriMetrix EQ Sample (DISC + 12 Driving Forces + 5 EQ)
  - [[musterbericht-relief]] — RELIEF Stressprävention Sample (Grundbedürfnisse + Antreiber + Coping)
  - [[assessment-beispiel-bewertungsergebnisse]] — ASSESS 5.0 Matching (38 S., anonymisiert)
  - [[assessment-beispiel-entwicklungsbericht]] — ASSESS 5.0 Coaching (13 S., anonymisiert)
  - [[assessment-beispiel-selektionsbericht]] — ASSESS 5.0 Interview-Leitfaden (8 S., anonymisiert)
- `index.md` Sources 43 → 50
- `wiki/meta/overview.md` — Timestamp aktualisiert, Duplikat-[[scraper]]-Row entfernt, Heritage-App-Referenz + Assessment-Referenzmaterial-Sektion ergänzt

**Anonymisierung:** Sonja-Bee-Spiess-Dokumente (3× ASSESS 5.0 Consultant-Report) wurden strukturell dokumentiert ohne Personendaten. Original-PDFs bleiben in `raw/` unverändert (immutability-Regel), DSGVO-Hinweis in jeder Wiki-Page.

**Nicht ingested (bewusst):** 6_Aufnahmen (audio/video) · Code_Audits (dev-tooling) · Vorlage_postaler_Brief (low-value) · arkadium-diagnostik_2.html (prüfen ob Duplikat von offerte-diagnostik)

## [2026-04-16] update | Post-Placement-Widget · 5 Meilensteine + Placement-Diamant-Konsistenz (Option A)

**Kontext:** Zwei User-Klarstellungen:
1. Pre-Start-Onboarding-Check (1 Woche vor Arbeitsbeginn) ergänzt → 4 Post-Placement-Checks total: Onboarding (−7d) · 1-Mt · 2-Mt · 3-Mt=Garantie-Ende
2. Placement-Dot-Konsistenz: **Option A** gewählt — Placement ist **immer** Diamant (Zielstage-Marker, unabhängig vom Status). Vorherige Inkonsistenz (processes.html Diamant, candidates.html Circle wenn pending) aufgelöst.

**Fixes:**
- `mockups/processes.html` Garantie-Widget: 4 → 5 Meilensteine (Onboarding-Call als erster Meilenstein ergänzt). ViewBox 760×90 → 760×110. Positionen 36/208/380/552/724 (172px-spacing). Progress-Linie bis 466 (Demo-Zeit 15.07.2026).
- `mockups/candidates.html` Tab 6 Garantie-Widget: Analog 5 Meilensteine (Onboarding 07.08.2024 · PLACEMENT 14.08.2024 · 1-Mt 14.09. · 2-Mt 14.10. · 3-Mt 14.11. = Garantie-Ende). Alle in demo passed.
- `mockups/candidates.html` Tab 6 Prozess-Cards 9-Stage-SVG: Stage-9 Placement in allen 4 Cards von Circle → Diamant (Option A · 2 Pending-Pattern + 2 Ghost-Pattern nach Rejection)
- `mockups/processes.html` 9-Stage-Pipeline Stage-9: Diamant bleibt (bereits Option A)
- `mockups/accounts.html` procDrawer Stage-9: Diamant bleibt
- `specs/ARK_PIPELINE_COMPONENT_v1_0.md` §3.1 Dot-States: Placement-Zeile präzisiert — **immer Diamant**, Varianten (Gold-Fill bei placed · Surface-Fill pending · klein nach Rejection)

## [2026-04-16] update | Post-Placement-Checks reduziert auf 1./2./3. Monat (Garantiefrist-Scope)

**Kontext:** User klarstellte: Post-Placement-Checks gibt es nur 1./2./3. Monat, deckungsgleich mit Garantiefrist (AGB §5). Nach 3. Monat: keine Checks mehr (Rückvergütungsfrist abgelaufen, Prozess auf Status=Closed). 6-Mt / 12-Mt / 2-Jahres-Checks gibt es nicht.

**Fixes:**
- `mockups/processes.html` — Garantie-Widget: 6-Mt + 12-Mt-Marker entfernt. Jetzt 4 Meilensteine (PLACEMENT · 1-Mt ✓ · 2-Mt pulsing · 3-Mt = Garantie-Ende). Field-grid: „30/60/90-Tage Check" → „1./2./3.-Mt-Check" + Hinweis „Nach 3. Mt keine Checks". Abgrenzungs-Text umformuliert.
- `mockups/candidates.html` Tab 6 Garantie-Widget: 6-Mt / 12-Mt / 2-Jahres-Check raus. Neu: 1-Mt ✓ · 2-Mt ✓ · 3-Mt = Garantie-Ende ✓ · Textblock „danach keine Checks mehr". Kennzahl-Panel: „Tage bis Garantie-Ende" → „Garantiefrist: erfolgreich durch", „Status: In Garantie" → „Status: Closed". Action-Button „2-Jahres-Check dokumentieren" entfernt.
- `specs/ARK_PROZESS_DETAILMASKE_SCHEMA_v0_1.md` §Sektion 4 — Widget-Meilenstein-Liste reduziert auf 4 Einträge, Nach-3-Mt-Klausel ergänzt
- `specs/ARK_PROZESS_DETAILMASKE_INTERACTIONS_v0_1.md` §Teil 7 Auto-Reminders — Tabelle reduziert auf 4 Einträge (Onboarding + 1/2/3-Mt). V1-Saga Step 7 SQL-Snippet entsprechend angepasst.
- `raw/Ark_CRM_v2/ARK_STAMMDATEN_EXPORT_v1_3.md` §14 Placementprozess — 3 neue Activity-Types: #67 `Erreicht - 1-Mt-Check` · #68 `Erreicht - 2-Mt-Check` · #69 `Erreicht - 3-Mt-Check`. Total 66 → 69, Placementprozess-Kategorie 3 → 6.
- Memory `project_guarantee_protection.md` — Abschnitt „Post-Placement-Checks nur 1./2./3. Monat" ergänzt mit Activity-Type-Liste.
- Memory `project_activity_linking.md` — UI-Mapping-Tabelle: `checkin_30d/60d/90d` → `checkin_1m/2m/3m`, Hinweis „nur 4 Einträge" ergänzt.

## [2026-04-16] update | Arkadium-Rolle + Schutzfrist-Scope + Activity-Linking (globale Korrekturen)

**Kontext:** User (Peter) klarstellte zwei fundamentale Regeln, die quer durch alle Mockups/Specs/Grundlagen laufen:

1. **Schutzfrist ≠ Post-Placement:** 12/16-Mt-Direkteinstellungs-Schutzfrist läuft ab Kandidaten-Vorstellung und greift **nur bei NICHT-Placement**. Bei Placement → `fact_protection_window.status='honored'`. Nicht im Post-Placement-Widget darstellen.
2. **Arkadium nicht-teilnehmend bei Interviews:** TI/1st/2nd/3rd/Assessment laufen Kunde↔Kandidat direkt. Arkadium-Touchpoints: Briefing · Coaching · Debriefing (beidseitig, 2 fact_history-Einträge mit identischem Activity-Type) · Referenzauskunft.
3. **Activity-Types = nur Arkadium-Aktivitäten.** Interview-Durchführungen sind Stage-Daten (`fact_process_interviews.actual_date`), keine Activities.

**Fixes (Fix-Korrektur-Serie 10b-10e):**

**Memory (3 Files):**
- Update `project_guarantee_protection.md` — Schutzfrist nur bei NICHT-Placement, `honored`-Status bei Placement
- Neu `project_arkadium_role.md` — Nicht-Teilnehmer-Rolle, 4 Touchpoints, Katalog-Labels (Einträge #20, #36-42, #62-63, #65-66)
- Neu `project_activity_linking.md` — UI-Felder = Projektionen von fact_history, Click-Through Pflicht
- `MEMORY.md` · 3 Einträge (1 Update + 2 Neu)

**CLAUDE.md:** 3 neue CRITICAL-Regeln (Arkadium-Rolle · Activity-Linking · Schutzfrist) vor Stammdaten-Wording-Regel

**Mockup `processes.html`:**
- Garantie-Widget: SCHUTZFRIST-Milestone entfernt, Reduktion auf 4 Meilensteine (PLACEMENT · 3-Mt · 6-Mt · 12-Mt). Abgrenzungs-Hinweis umformuliert.
- Field-grid: Schutzfrist-Ende-Zeile raus, neu „Schutzfrist-Status: honored". Check-Ins mit `.activity-link-row` und `onclick="onActivityLinkClick(...)"`.
- Timeline (Tab 1 Sektion 5): falsche Zeilen `ti_durchgefuehrt` / `1st Interview durchgeführt` entfernt — sind Stage-Daten, keine Activities. Ersetzt durch `Erreicht - Coaching 1st Interview` + `Erreicht - Debriefing 1st Interview (beidseitig)`.
- History-Drawer 05.04.: Umgestellt auf `Erreicht - Debriefing TI` (Activity-Type #66, entity_relevance=both).
- Interview-Tabelle Tab 2 III: „TI Arkadium" → „III · TI · Kunde↔Kandidat" · Teilnehmer Eva Studer (CFO) statt „intern JV". Chip „Debrief (bds)" + Hover-Titles erklären Beidseitig.
- Dokument-Title „Interview-Protokoll TI Arkadium" → „TI Debriefing-Notizen".
- Pipeline Stage 3 aria-label klargestellt.
- `onDebriefingClick` Handler-Text: Beidseitig-Logik, Arkadium ruft Kandidat + Kunde je separat.
- `onActivityLinkClick` Stub neu (History-Drawer-Opener, Erfass-Drawer-Opener).
- `.activity-link-row:hover` CSS.
- Saga-TX1 Step 4: `fact_protection_window.status='honored'` ergänzt, Post-Saga-Trigger-Box umformuliert.

**Specs (4 Files):**
- `ARK_PROZESS_DETAILMASKE_SCHEMA_v0_1.md` — neue §6.0 Arkadium-Rolle, §6.1 Interview-Timeline Activity-Linking, §Sektion 4 Post-Placement mit Scope-Abgrenzung
- `ARK_PROZESS_DETAILMASKE_INTERACTIONS_v0_1.md` — §Teil 5 komplett umgeschrieben (Coaching/Debriefing beidseitig mit Katalog-Labels), V1-Saga Step 4 korrigiert (kein neues Schutzfrist-Window, nur honored), §Schutzfrist-Abgrenzung klargestellt
- `ARK_KANDIDATENMASKE_SCHEMA_v1_3.md` — §3 Tab 2 Briefing Terminologie-Sektion
- `ARK_PIPELINE_COMPONENT_v1_0.md` — neue §Grundregeln, §3.4 Debriefing-Dots beidseitig (voll/halbvoll/grau), echte Activity-Type-Labels

**Grundlagen (3 Files):**
- `ARK_STAMMDATEN_EXPORT_v1_3.md` §14 — neue Spalte `entity_relevance` für alle 11 Kategorien (66 Einträge), 2 neue Interviewprozess-Einträge (#65 Coaching TI + #66 Debriefing TI), Terminologie-Box, Stage-Daten-Abgrenzung. Total 64 → 66.
- `ARK_GESAMTSYSTEM_UEBERSICHT_v1_3.md` — §2.6 Prozess um Arkadium-Rolle-Abschnitt mit 4-Touchpoints-Tabelle + Activity-Type-Mapping ergänzt. §System-Events Count aktualisiert (Interviewprozess 7 → 9, System 5 → 6).
- `ARK_FRONTEND_FREEZE_v1_10.md` — neue §9.9 Activity-Linking-Pattern (Click-Through-Verhalten, data-activity-type Attribute, Debriefing-Aggregation)

**Backups:** `backups/*.2026-04-16-2050-*.bak` für 6 Mockups + 5 Specs/Grundlagen

## [2026-04-16] create | ARK Pipeline Component v1.0 (Shared Spec)

**Task 2 von 11 · Pipeline-Refactor-Serie (B.2 Cockpit-Layout):**
- Neu: `specs/ARK_PIPELINE_COMPONENT_v1_0.md` — konsolidiert Design-Drift zwischen processes.html (Kachel-Grid) und candidates.html Tab 6 (SVG-Linie). 2 Modi: `detailed` (Detail-Maske, 280 px WinProb-Panel) + `compact` (Listen-Karten, CSS-Fallback ab 50 Items). Skip-Regeln V1-Saga-konform: kein Direkt-Sprung zu Platzierung via Stage-Klick.
- Cross-Link-Updates:
  - `specs/ARK_PROZESS_DETAILMASKE_SCHEMA_v0_1.md` §4.2 → zeigt auf Component-Spec, behält nur Prozess-spezifische Abweichungen
  - `specs/ARK_KANDIDATENMASKE_SCHEMA_v1_3.md` §7 Tab 6 → zeigt auf Component-Spec, compact-Mode
  - `raw/Ark_CRM_v2/ARK_FRONTEND_FREEZE_v1_10.md` neue §9.8 Pipeline-Component-Pointer
- Backups: 6 Mockups + 3 Specs unter `backups/*.2026-04-16-2050-*.bak`

## [2026-04-16] update | Prozess-Detailmaske Phases F+G+H komplett

**Phase F · 11 Drawers** (mockups/processes.html): interview · rejection (3 Reason-Tabs) · placement (V1–V7 UI-Readiness + 8-Step-Saga-Preview) · onHold · refund (modell-aware Router) · invoice · feeOverride · history · reminder · upload · doc. Plus drawerBackdrop + Wiring per delegated History-Row-Click + Reminder-Button in Banner.

**Phase G · Stale + Quick-Actions:**
- Sektion 2b „Stale-Überwachung" in Tab 1 mit Per-Stage-Schwellen-Tabelle (Exposé 14 / CV Sent 10 / TI 7 / 1st-3rd 14 / Assessment 21 / Angebot 10)
- Live-Progress-Bar aktuelle Stage + Health-Chip
- Stale-Simulation (3 Buttons: 3 / 6 / 14 d) zeigt Farb-Reaktion
- Keyboard-Shortcuts gewired: 1–3 Tabs, I Interview, H On-Hold, R Reject, P Place, T Theme, Esc Close

**Phase H · Spec + Wiki Sync:**
- `specs/ARK_PROZESS_DETAILMASKE_INTERACTIONS_v0_1.md`:
  - Stage-Forward-Skip klarer spezifiziert (1st→Angebot erlaubt; Angebot→Platzierung weiterhin Pflicht-Weg)
  - Neue Sub-Sektion „Placement-Drawer · UI-seitige Readiness-Checks" — Abgrenzung UI-Matrix vs Saga-V1–V7
  - Early-Exit-Sektion komplett überarbeitet: Modell-spezifisch (Erfolgsbasis-Staffel vs Target-Ersatzbesetzung vs Time-keine-Garantie)
  - Neue Sektion „Direkteinstellungs-Schutzfrist — Abgrenzung" (3-Mt-Garantie vs 12/16-Mt-Schutzfrist)
- `wiki/entities/prozess.md` komplett neu geschrieben: Stage-Flow-Regeln, Status-Machine 8, 3-Mt-Garantiefrist seriell, Claim-Workflow, Mockup-Status A–H
- `wiki/meta/detailseiten-inventar.md`: Prozess-Zeile aktualisiert mit Mockup-Phases A–H + Refund-Modell-Router-Note

**Sanity:** mockups/processes.html 2086 Zeilen · div-bal 0 · script-bal 0 · 11/11 Drawers wired · Backup phaseF.bak

---

## [2026-04-16] ingest | Provisionssystem + Garantiefrist-Abgrenzung

User lieferte globale Klarstellungen nach Prozessflow-Analyse:

**Garantiefrist-Klärung:**
- **3 Monate** (nicht 12/16 Mt — das ist die separate Direkteinstellungs-Schutzfrist)
- **Seriell pro Kandidat**: keine parallelen Garantien — neue Garantie erst bei nächstem Placement
- Austritt innerhalb → Rückvergütung (Erfolgsbasis) bzw. Ersatzbesetzung (Mandat)

**Provisionierungs-Modell (Ingest der 3 Quellen):**
- **Researcher**: CHF 250–750 Pauschale pro Placement (CV-Upload-Owner)
- **CM/AM**: Jahresziel 360k–700k, Budget quartalisiert, 50/50-Deal-Split, ZEG-basierte Staffel
- **Head of**: Teambudget (Sparten-Rollup), alle Umsatz-Typen ausser Time
- **Staffel**: <50 %=0, 50–60 %=10–28 %, 60–70 %=30–39 %, 70–150 %=40–160 %, >150 %=+1 %/%
- **Quartals-Abrechnung**: Q1→April, Q2→Juli, Q3→Okt, Q4→Jan, 80 % Abschlag + 20 % Rücklage bis Garantie-Ablauf
- **Scope**: CRM 1.0 erfasst nur Eingangsfelder (Net Fee, Zuteilung), **keine Payroll-UI** — Provisions-Engine kommt mit CRM 2.0

**V1–V7-Korrektur:**
- Pre-Validations sind **Daten-Vollständigkeits-Checks**, nicht Stage-Durchlauf-Pflicht
- Prozess kann direkt von 1st/2nd/3rd/Assessment/Angebot nach Platzierung springen

**Claim-Workflow ergänzt (Direkteinstellung während Schutzfrist):**
- AGB-Anspruch bindet an Vertragsabschluss, nicht an Arbeits-Dauer
- **Keine** nachträgliche 3-Mt-Garantie bei Claim-Fällen
- Separater `fact_direct_hire_claim`-Record, kein Prozess-Reopen
- Arbeitsvertrag Kunde↔Kandidat nicht tangiert

**Pages:**
- Neu: `wiki/concepts/garantiefrist.md` · `wiki/concepts/provisionierung.md`
- Neu: `wiki/sources/anhang-provisionsstaffel-cm.md` · `provisionssheet-joaquin.md` · `provisionssheet-peter.md`
- Update: `wiki/concepts/direkteinstellung-schutzfrist.md` (Claim-Workflow-Sektion, Garantiefrist-Abgrenzung)
- Update: `wiki/concepts/honorar-berechnung.md` (Cross-Ref Garantiefrist+Provisionierung, Scope-Abgrenzung 1.0/2.0)
- Update: `index.md` (Sources 40→43, Concepts 31→33)

---

## [2026-04-16] update | Konsistenz-Fixes · 5 Mockups harmonisiert

Audit der 6 Detailmasken nach Projekt-Fertigstellung ergab 5 echte Issues (Agent-Audit hatte 50 % false-positives — korrigiert via eigene grep-Verifikation).

**Fixes:**
1. **jobs.html**: 4× `var(--ink)` → `var(--text)` (Dark-Mode-Bug in Jobbasket-KPIs + Matching-Banner, `--ink` existiert nicht in editorial.css)
2. **groups.html**: Status-Dropdown im Banner hinzugefügt (`<select class="status-dropdown" onchange="onGroupStatusChange">`) mit 4 Werten (aktiv · in_review · archiviert · merger) + Confirm-Dialog
3. **projects.html**: `historyDrawer` hinzugefügt (drawer-wide, kontextabhängige Tabs via HIST_CHAN_MAP) + Row-Click-Wiring auf Tab 6 · Komplette JS-Logik (openHistDrawer, histSwitchTab, histRenderPane, escapeHtml) portiert aus jobs.html · Tabs: Übersicht · Email-Thread · Transkript · AI-Summary · Verknüpfungen (kontextabhängig gerendert)
4. **accounts.html**: Scraper-Source-Banner (conditional) hinzugefügt — Account-Scraper-Use-Cases: Website-Monitor, Team-Page-Scraper, Stellenplan-Scraper. Actions: ✓ Alle übernehmen · 🔎 Review · ✕ Ablehnen · Später. Demo-Toggle für Mockup-Visibility
5. **candidates.html**: Scraper-Source-Banner hinzugefügt — LinkedIn-Scraper-Use-Case: Werdegang-Update / Job-Wechsel-Detection. Actions: ✓ Werdegang aktualisieren · 🔎 Diff-View · ✕ Ignorieren · Später

**Zusätzlicher Bug gefixt**: accounts.html hatte nach meinem Scraper-Edit eine doppelte `<div class="banner-top">` Zeile (Edit-Artefakt). Manuell bereinigt.

**Final-Check:** alle 6 Mockups div/script balance 0 (candidates s-bal=+1 ist false-positive aus template-literal `<\/script>`-escape in Print-Handler)

**Feature-Parität erreicht:**
- Snapshot-Bar · historyDrawer · reminderDrawer · status-dropdown: 6/6
- scraperBanner: 5/6 (mandates fehlt korrekt — Mandate werden nicht gescrapt, sind Verträge)
- `var(--ink)`-Reste: 0/6

**Backups:** `backups/*.2026-04-16-1734-consistency.bak`

---

## [2026-04-16] update | Projekt-Detailmaske · Phase L+ · Netzwerk-View Design-Polish

- **Deselect-on-Canvas**: `<rect class="netz-bg-click" onclick="netzReset()">` als Background-Layer · Cluster-Bands haben `pointer-events:none` damit Click durchkommt
- **Radial-Gradients** für Node-Fills: `gradAccount` (navy), `gradKandidat` (white → green-tint), `gradLead` (green-bright → green), `gradExternal` (white → gold-soft)
- **Drop-Shadow-Filter** pro Node (`filter:drop-shadow(...)`)
- **Hover-Scale** auf Nodes (transform:scale(1.06))
- **Pulse-Animation** auf Selected-State (`@keyframes netzPulse` 1.8s gold-glow)
- **Crown-Badge** (♛) über Lead-Kandidaten (Furrer + Hofer)
- **Cluster-Bands** im Hintergrund gruppieren nach Strang (Planung · Baumeister/GU · Elektro · HLK) mit soft-tinted background + Kategorie-Label
- **Curved Edges** via SVG-Path (C/Q-Bezier) statt Lines — organischer Fluss
- **Text-Outline** (paint-order:stroke) auf Node-Labels für Lesbarkeit über Grid-Hintergrund
- **Refined Legend** als Card mit besserer Typography
- **Initials serif** (Libre Baskerville) für Node-Mitten
- **Side-Panel** Header mit Gold-Gradient + Lead-Section-Header-Accents
- **viewBox** von 700 auf 780 erhöht für mehr Atemraum unten + Wasserzeichen + Hint-Text

Sanity: div/script/svg/g balance 0 · 13 Nodes · 17 Edges · 4 Cluster-Bands · 2 Crowns · Pulse-Animation · alle 4 Gradients definiert · bg-click-rect präsent.

---

## [2026-04-16] update | Projekt-Detailmaske · Phase L · Netzwerk-View

**Ziel:** Visualisierung der **firmen-übergreifenden Projekt-Reports-to-Beziehungen** als 3. View im Tab 2 Gewerke.

**Umsetzung:**
- View-Switch erweitert: `[📋 Akkordeon] [📊 Gantt] [🕸 Netzwerk]`
- Neuer `#gw-view-netzwerk` mit SVG-Graph + Side-Panel (CSS-Grid 1fr × 340px)
- **SVG-Graph** 1200×700 viewBox, grid-background, 5 Ebenen:
  - Ebene 0: Bauherr (Account) — top-center
  - Ebene 1: Hans Müller (Bauherr-Vertretung, Account-Kontakt)
  - Ebene 2: Meili Peter (Gesamtplaner) · Implenia (GU) · BKW (Elektro-Lead) · Hälg (HLK-GU)
  - Ebene 3: Lead-Kandidaten (Nicolas Meili · **T. Furrer** · Anna Klein · **P. Hofer**)
  - Ebene 4: Sub-Kandidaten firmen-übergreifend (Max Muster · ZETT-Polier · Eldas-Monteur)
- **13 Nodes** (6 Accounts/Kontakte + 7 Kandidaten) · **17 Edges** davon **7 firmen-übergreifend** (rote Linien)

**Edge-Typen:**
- `edge-reports` (accent, solid, arrow): Reports-to intern innerhalb Firma oder Firma→Firma
- `edge-reports-cross` (**rot**, solid, arrow): **Firmen-übergreifend** (der Kern des Features — Sub→GU, Fachplaner→Gesamtplaner, Kandidat→Kandidat andere Firmen)
- `edge-peer` (dashed, muted): Fachliche Zusammenarbeit auf gleicher Ebene

**Konkrete firmen-übergreifende Reports-to-Edges im Mockup:**
- T. Furrer (Implenia) → Hans Müller (Bauherr-Kontakt)
- Max Muster (Muster Bau) → T. Furrer (Implenia)
- P. Hofer (BKW) → T. Furrer (Implenia)
- ZETT-Polier (ZETT Bau) → Max Muster (Muster Bau)
- Eldas-Monteur (Eldas) → P. Hofer (BKW)
- + Firma-zu-Firma-Cross

**Side-Panel (aside, 340px, sticky):**
- Empty-State bei kein Node ausgewählt
- Bei Node-Klick: 5 Sektionen — SIA-Phasen · 🔼 Rapportiert an (inkl. Cross-Company-Warnung) · 🔽 Direkte Reports (mit „⚠ andere Firma"-Chip) · ⇄ Peers · 🔗 Kennt-sich von (Cross-Projekt-Lookup)

**JS:**
- `NETZ_DATA` Object mit 13 Einträgen (type, name, sub, role, sia, reportsToId, reportsToNote, directReports, directReportsCrossCompany, peers, crossProjects)
- `netzSelect(id)`: aktiviert Node + füllt Side-Panel + highlighted connected nodes
- `netzHighlightConnected(id)`: alle anderen dimmen
- `netzReset()`: zurück zum Empty-State
- `netzEdgeMode(chip, mode)`: Filter-Toggle „Alle Edges" · „Nur Reports-to" · „Nur Peers"
- `gwViewSwitch` erweitert auf 3 Views

**Filter-Bar Netzwerk:**
- SIA-Phase-Select · BKP-Gewerk-Select · Kandidat-Fokus-Select · Edge-Mode-Chip-Group · Reset-Button

**Legende** oben: Node-Typen (Account / Lead-Kandidat / Kandidat / externer Kontakt) + Edge-Typen inkl. Hervorhebung „firmen-übergreifend" in rot.

**Wiki-Sync:** `wiki/entities/projekt.md` Tab-2-Beschreibung erweitert auf 3 View-Modi inkl. Netzwerk.

**Sanity-Check:** div/script/svg/g balance 0 · 13 Nodes · 17 Edges · 7 cross-company · 5 JS-Funktionen definiert + aufgerufen · alle 13 NETZ_DATA-Einträge haben passende SVG-Nodes.

**Backups:** `backups/projects.html.2026-04-16-phaseL-start.bak`

**Offen:** Phase L+1 (optional): Quick-Edit inline im Akkordeon (aus früherer Hybrid-Empfehlung), Netzwerk-SVG in echter App auf Cytoscape.js umstellen (force-layout, dynamisch).

---

## [2026-04-16] update | Projekt-Detailmaske · Phase J + K (SIA-Akkordeon + Gantt + Drawer-Ausbau)

### Phase J · Tab 2 Struktur-Umbau
- Akkordeon-Hierarchie **invertiert**: SIA-Phasen primär · BKP-Gewerke sekundär (innerhalb SIA-Teilphasen)
- View-Switch `[📋 Akkordeon] [📊 Gantt]` in Tab 2 Filter-Bar
- **Gantt-View** neu: 36-Monats-Zeitachse 2026–2028 · Swimlanes pro BKP-Gewerk · 11 Balken · Farbkodierung nach Rolle (GU/Sub/Planer/Bauleitung/Kandidat)
- JS-Handler: `siaToggle` (neu), `gwViewSwitch` (neu), `gwExpandAll` erweitert für alle 3 Ebenen
- Alte flache BKP-Akkordeon-Struktur entfernt via awk+mv (~260 Zeilen)

### Phase K · Drawer-Ausbau (schrittweise)

**Schritt 1 · DB-Schema erweitert** (`specs/ARK_PROJEKT_DETAILMASKE_SCHEMA_v0_2.md` Changelog v0.2→v0.3):
- `fact_project_company_participations`: + `contract_type` (4 Enum-Werte) · `called_volume_chf` · **`reports_to_company_participation_id`** (FK self, firmen-übergreifende Projekt-Hierarchie) · `can_be_referenced` + Referenz-Approval-Felder
- `fact_project_candidate_participations`: + `team_size` · `stakeholder_namedropping` · `challenges` · `highlights` · **`reports_to_candidate_participation_id`** XOR **`reports_to_company_participation_id`** (firmen-übergreifend, projekt-spezifisch) · `can_be_referenced` · `reference_only_internal` · `reference_copyright_claim` + Approval-Felder
- **Neue Tabelle** `fact_project_company_contacts`: Account-Kontakte pro Firmen-Beteiligung (Multi, mit `is_primary`)
- Constraints: XOR-Check · Cycle-Check via rekursive CTE · FK muss selbes `project_id` sein

**Wichtige Design-Entscheidung:** Projekt-Reports-to ist **firmen-übergreifend und nur in diesem Projekt gültig** — unabhängig vom Firmen-Organigramm (`dim_accounts_org_chart`). Sub-Bauleiter rapportiert GU-Gesamt-PL (andere Firma), nicht eigenem Firmen-CEO.

**Schritt 2 · firmaParticipationDrawer 3→5 Tabs:**
1. Basis (+ Vertragsart-Select + Auftragssumme/Abgerufen mit Progress-Bar)
2. SIA-Phasen (bestehend)
3. **Kontakte** NEU · Multi-Ansprechpersonen aus `fact_accounts_contacts` · Primary-Radio · Quick-Call/Mail
4. **Verträge + Dokumente** NEU · Offerte + signierter Vertrag (PDF-Slots) · Nachträge + Stage-Rechnungen (Tabelle)
5. **Kontext + Referenz** NEU · Arkadium-Kommentar · Reports-to-Firma-Select · Cross-Refs (andere Projekte dieser Firma) · Referenz-Eignung (3-Stufen-Chip-Group + Zustimmung+Bemerkung)

**Schritt 3 · kandidatParticipationDrawer 4→6 Tabs:**
1. Basis (bestehend)
2. SIA-Phasen (bestehend)
3. Rolle (bestehend)
4. **Team-Kontext** NEU · **Reports-to-Kandidat** XOR **Reports-to-Firma** · Direct Reports (Multi-Chip) · Fachliche Peers · Stakeholder-Namedropping (Textarea)
5. **Evidence + Referenz** NEU · Highlights · Herausforderungen · Evidence-Dokumente (Werkzeugnis + Referenz-Schreiben, Link zu Kandidat-Doks) · Referenz-Eignung inkl. Copyright-Claim
6. **Kontext + Werdegang-Sync** · Tratsch/Interna · Werdegang-Sync-Status-Badge (✓ synchron / ⚠ abweichend) · AI-Match-Info (Score + Quelle + Bestätigt-von)

**Schritt 4 · Wiki-Sync:**
- `wiki/entities/projekt.md` Sub-Strukturen um v0.3-Felder erweitert · neue Sektion **„Projekt-Reports-to (Hierarchie-Besonderheit)"** · Drawer-Inventar aktualisiert (3→5 / 4→6 Tabs)

**Schritt 5 · Sanity-Check bestanden:**
- 3005 Zeilen (vorher 2689) · div/script balance 0
- firmaParticipationDrawer: 5 Tabs · 5 Panes
- kandidatParticipationDrawer: 6 Tabs · 6 Panes
- Alle neuen Features verifizierbar (Vertragsart, Abgerufen, Kontakte-Tab, Verträge-Tab, Cross-Refs, Referenz-Eignung, Reports-to-Firma/Kandidat, Stakeholder-Namedropping, Evidence-Dokumente, Copyright-Claim, Werdegang-Sync)

**Backups:** `backups/projects.html.2026-04-16-phaseJ-start.bak` · `.phaseK-start.bak` · SCHEMA-Backup

**Ausstehend (Phase L):** Netzwerk-View als 3. View-Switch im Tab 2 (nutzt die neuen Reports-to-Felder)

---

## [2026-04-16] update | Projekt-Detailmaske · Phase A–I komplett

**Ausgangszustand:** 676 Zeilen Skelett mit nur Tab 1 Inhalt, Tab 2 simplistisch, Tab 3 Platzhalter, Tab 4 simpel, Tab 5+6 aus Account kopiert. `wiki/entities/projekt.md` existierte nicht.

**Neuer Zustand:** 2395 Zeilen, 6 Tabs voll ausgebaut, 14 Drawers, komplette Wiki/Spec-Dokumentation.

**Phasen:**
- **A · Basis-Skelett**: Header mit Hero-Bild (60×60 → Galerie-Link), Status-Dropdown 6 Werte, Scraper-Source-Banner (conditional + Demo-Toggle), Snapshot-Bar sticky 6 Slots (projekttyp-agnostisch: Volumen/Zeitraum/BKP-Gewerke/Firmen/Kandidaten/Medien — keine Hochbau-Spezifika wie BGF), Tabbar sticky
- **B · Tab 1 Übersicht**: KPI-Strip canonical, Öffentlich/Intern-Divider, AM-Notizen pro Account via `accountNoteDrawer` (Bridge `fact_account_project_notes` UNIQUE(project_id, account_id))
- **C · Tab 2 Gewerke (KERN)**: 3-Tier-Akkordeon Projekt→Gewerk→Beteiligungen. Inline-Kommentar-Edit, Sub-Tabellen Firmen + Kandidaten, `gwToggle`/`gwExpandAll`-JS. 4 neue Drawer: `newGewerkDrawer` (BKP-Suche 425 Codes), `gewerkSettingsDrawer` (Edit/Delete mit Cascade-Warnung), `firmaParticipationDrawer` (wide, 3 Tabs), `kandidatParticipationDrawer` (wide, 4 Tabs analog werdegangProjektDrawer)
- **D · Tab 3 Matching**: 2 Sub-Sections mit Chip-Switcher. Sub-A: Kandidaten-Tabelle mit 6 Score-Dimensionen (Cluster/BKP/SIA/Volumen/Geo/Recency). Sub-B: Ähnliche Projekte via Jaccard. Score-Slider, Recompute-Banner, `pitchDrawer`
- **E · Tab 4 Galerie**: Masonry-Grid mit 5 Medien-Typen (Foto/Render/Plan/Baustelle/After-Move-In). CSS-Gradient-Tiles typ-spezifisch (Blueprint-Pattern für Pläne, Foto-Gradient, Render-Gold, Site-Braun) statt Emojis. Lightbox-Overlay mit ←→ Esc. `mediaUploadDrawer`, `mediaEditDrawer`
- **F · Tab 5 Dokumente**: Neues **Profile „Projekt"** mit 6 Kategorien (projekt-beschreibung/pressemeldungen/baublatt-simap/pitch-unterlagen/referenz-schreiben/sonstiges). AI-Auto-Enrichment-Banner. Quellen-Tagging (Manuell/AI/Scraper/Kunden-Email/Doc-Gen)
- **G · Tab 6 History**: 13 Projekt-Lifecycle-Events laut Spec §10 (project_created_*, status/bauherr/classification_changed, bkp_gewerk_*, company/candidate_participation_*, media/document_uploaded, internal_notes_updated, account_project_note_*)
- **H · Drawers + Quick-Actions**: 14 Drawers total inkl. `addBeteiligungDrawer` (Quick-Action „Gewerk? Firma oder Kandidat?"-Routing), `projektReportDrawer` (PDF intern/extern + Sprache), `mergeDrawer` (wide, 3-Tab Duplikat-Merge mit Feld-Kollision — direkt in P0, nicht Phase 2)
- **I · Wiki + Spec Sync**:
  - `wiki/entities/projekt.md` **NEU** mit vollständigem Profil (DB, Status, Erstellungs-Wege, Tab-Struktur, Header-Specials, Drawer-Inventar, Cross-Entity, Matching-Algo)
  - `wiki/concepts/dokumente-kategorien.md` §5 **Projekt-Profile** (6 Kategorien + Spezial-Features) + Titel auf 5 Profile
  - `wiki/concepts/design-system.md` §3.2b Slot-Tabelle um Projekt erweitert
  - `specs/ARK_PROJEKT_DETAILMASKE_SCHEMA_v0_2.md` §4.4 canonical + dupe-Regel + projekttyp-agnostisch dokumentiert
  - `raw/Ark_CRM_v2/ARK_FRONTEND_FREEZE_v1_10.md` §6 Slot-Allokations-Tabelle + Projekt-Header-Zeile
  - `raw/Ark_CRM_v2/ARK_GESAMTSYSTEM_UEBERSICHT_v1_3.md` **TEIL 20c** Changelog
  - `index.md`: neue Entity-Zeile `[[projekt]]`

**Sanity-Check bestanden:** div balance 0 · script balance 0 · 6 tab-panels · 14 drawers · 13 JS-Funktionen definiert + aufgerufen · 8 gw-accordion-rows · 12+1 gal-tiles.

**Sync-Scope nicht betroffen:** STAMMDATEN (keine neuen Enums), DATABASE_SCHEMA (Spec v0.2 bereits dokumentiert), BACKEND_ARCHITECTURE (kein neuer Endpunkt).

**Backup:** `backups/projects.html.2026-04-16-phaseA-start.bak`

---

## [2026-04-16] update | Snapshot-Bar-Harmonisierung · alle 5 Mockups + Wiki + 5 Specs

**Audit-Ergebnis (5 Detailmasken):**
- mandates: custom `.mandat-snapshot` (7 Slots, eigene CSS-Klasse)
- candidates: keine Snapshot-Bar
- accounts: `.snapshot-bar` nicht sticky
- groups: Snapshot unter Tabbar (`top:49`)
- jobs: Snapshot über Tabbar, aber 3 Dupes zum Header (Status/Mandat/Offen-seit)

**Harmonisierung:**
1. Alle 5 Masken nutzen jetzt canonical `.snapshot-bar` + `.snapshot-item` (6 Slots)
2. Stacking: Snapshot `top:0, z-index:50` über Tabbar `top:64-72px, z-index:49` ("Identität vor Navigation")
3. **Dupe-Regel** etabliert: Snapshot-Slots dürfen nicht Header-Info duplizieren
4. Slot-Belegung pro Entity:
   - accounts: Firmografisch (bleibt) — Mitarbeitende · Wachstum 3J · Umsatz · Gegründet · Standorte · Kulturfit
   - candidates: NEU — Ø Match-Score · Jobbasket · Prozesse · Refresh-Due · Placements hist. · Assessments
   - mandates: 7→6 Slots, Garantie + Exklusivität raus (sind banner-chips), Placements rein
   - groups: Offene Mandate raus (ist banner-chip), Arkadium-Umsatz YTD rein
   - jobs: 3 Dupes raus, Matches ≥ 70 · Jobbasket · Prozesse · Standort · TC-Range · Ø Match-Score

**Dokumentation synchronisiert:**
- `wiki/concepts/design-system.md` §3.2b neu (Snapshot-Pattern + Slot-Tabelle + Dupe-Regel)
- `wiki/entities/account.md` · `kandidat.md` · `mandat.md` · `firmengruppe.md` · `job.md`: Header-Spezialitäten + Snapshot-Slots
- `raw/Ark_CRM_v2/ARK_FRONTEND_FREEZE_v1_10.md` §6 Snapshot-Konvention vollständig überarbeitet + per-Entity-Header-Zeilen
- `raw/Ark_CRM_v2/ARK_GESAMTSYSTEM_UEBERSICHT_v1_3.md` TEIL 20b neu (v1.3.2 Changelog)
- `specs/ARK_ACCOUNT_DETAILMASKE_SCHEMA_v0_2.md` §4.4 + `_MANDAT_SCHEMA_v0_2` §4.3 + `_FIRMENGRUPPE_SCHEMA_v0_1` §4.3 + `_JOB_SCHEMA_v0_1` §4.3 + `_KANDIDATENMASKE_SCHEMA_v1_3` NEU §1b

**Sync-Scope (nicht betroffen):** STAMMDATEN, DATABASE_SCHEMA, BACKEND_ARCHITECTURE — keine Enums/Spalten/Endpunkte.

**Sanity-Check bestanden:** alle 5 Mockups `snapshot-bar=1, snapshot-items=6, tab-sticky=true, snap-sticky=true, div-bal=0`.

**Backups:** `backups/*.html.2026-04-16-1421-snapshot.bak`

---

## [2026-04-16] update | Jobs Phase E · Wiki-Sync

- `wiki/concepts/dokumente-kategorien.md`: Titel & Einleitung auf 4 Profile · neue Sektion **4. Job-Profile** mit 5 Kategorien (stellenausschreibung · briefing · matching-export · organigramm · sonstiges) · Spezial-Features (Generator, Versionierung, Matching-Export-Snapshots) · „Warum nicht vereinheitlichen" auf 4 Profile + 28 Kategorien aktualisiert
- `wiki/entities/job.md`: sources-frontmatter um `ARK_JOB_DETAILMASKE_SCHEMA_v0_1` + `_INTERACTIONS_v0_1` erweitert · neue Sektion **Mockup-Status** mit Tab-Tabelle (7 Tabs), Header-Specials (Phase D), Design-System-Konformität · Related-Links erweitert um dokumente-kategorien, design-system, interaction-patterns
- `index.md`: `[[job]]` Hinweis auf „7-Tab-Detailmaske Phase A–E komplett" · `[[dokumente-kategorien]]` auf „4-Profile-Schema" · updated-Datum 2026-04-16

Phase A–E der Jobs-Detailmaske damit abgeschlossen. Jobs hat jetzt Feature-Parität mit accounts/candidates/mandates/groups und voll dokumentierten Wiki-Sync.

---

## [2026-04-16] update | Jobs Phase D · Header-Specials

- `mockups/jobs.html` Header komplett ausgebaut:
  - **Scraper-Proposal-Banner** (`#scraperBanner`, rot, oben): Conditional UI für `status=scraper_proposal`-Jobs · Actions „✓ Vakanz bestätigen" (`confirmScraper`) / „✕ Ablehnen" (`rejectScraper` mit Reason-Prompt) / „Später"
  - Mockup-Demo-Toggle zeigt Banner on-demand (dieser Job ist „Aktiv", Banner verdeckt)
  - **Snapshot-Bar sticky** (`.snapshot-bar`, 6 Slots): Status · Mandat · Sparte · Standort · TC-Range · Offen seit — sticky top:0, z-index 50
  - **Tabbar sticky** darunter (top:60px, z-index 49)
  - **Status-Dropdown** (`<select class="status-dropdown">`): 6 Status-Werte (scraper_proposal · aktiv · on_hold · besetzt · geschlossen · abgelehnt) mit Icon-Präfix + Confirm-Dialog (`onStatusChange`)
  - **Mandat-Badge** jetzt `<a href="mandates.html">` klickbar
  - **Stellenplan-Referenz** neuer Chip `📋 Stellenplan #PLN-2026-01`
  - **Quick-Action „📤 Kandidat vorschlagen"** als erste btn-primary in banner-actions → öffnet neuen `proposeDrawer`
  - **proposeDrawer** (540px, 3 Sektionen): Kandidat-Auswahl (datalist-Suche) + Source (AM-Empfehlung/Referral/Ex-Kandidat) + Start-Stage + Begründung + Info-Banner „Stage-Management in Kandidat Tab 5"
  - Banner-Actions erweitert: `📄 Stellenausschreibung` (ruft `genJobAd`) · `🔁 Matching neu` (switcht Tab 2 + `runRecompute`)
- Sanity: div/script balance 0 · 4 neue Funktionen + proposeDrawer/scraperBanner/snapshot-bar alle präsent
- Backup: `backups/jobs.html.2026-04-16-phaseC.bak` (unverändert für D, da Phase C/D fliessend)

---

## [2026-04-16] update | Jobs Phase C · Tab 2-6 Spec-Features

- `mockups/jobs.html`:
  - **Tab 2 Matching** (Spec §7 — grösstes Feature):
    - Recompute-Banner mit Last-computed-Timestamp + `runRecompute()` Loading-State
    - KPI-Strip cols-5: Matches ≥ Schwelle · Top · Ø · Neu 7d · Sector-Exclude
    - Score-Schwelle-Slider 50–95 % (`onScoreSlider` filtert `.mt-row[data-score]`)
    - Filter: Sparte · Availability · Basket-State · Sector-Exclude-Toggle
    - Tabelle mit 7 Sub-Scores (Sp./Fkt./Geh./Loc./Skl./Verf./Sen.) + SVG-Radar-Mini (44×44) pro Kandidat
    - Bulk-Multi-Select + "+ In Jobbasket"-Button (`toggleAllMatches`, `updateBulkBtn`, `bulkToJobbasket`)
    - Sector-Exclude-Zeile demonstriert (Lukas Müller bei Implenia)
  - **Tab 3 Jobbasket** (Spec §8):
    - Info-Banner „Read-mostly · Verwaltung in Kandidat Tab 5"
    - KPI-Strip cols-5 · Pipeline-Stages-Bar (5 Stages) · Filter Stage/Gate/AM
    - Liste-View (Default) + Kanban-View mit `switchJbView()`
    - Gate-Status-Chips (Gate OK · CV ≥ 60d · Assessment ≥ 9 Mon.)
  - **Tab 4 Prozesse** (Spec §9):
    - Job-Kontext-Banner („WHERE job_id = ...") + Link auf processes.html
    - KPI-Leiste job-scoped (6 Open statt 16)
  - **Tab 5 Dokumente** (Spec §10 — Profile „Job"):
    - Kategorien-Swap Commercial→Job: Stellenausschreibung · Briefing · Matching-Export · Organigramm-Position · Sonstiges
    - Stellenausschreibung-Generator-Banner (Sprache DE/FR/IT/EN, Logo-Toggle, Verdeckt-Toggle, `genJobAd()`)
    - 14 Beispielzeilen (4 Ausschreibungen, 2 Briefings, 3 Matching-Exports, 1 Organigramm, 4 Sonstiges)
    - Kacheln-View entsprechend angepasst
  - **Tab 6 History** (Spec §11 — Job-Lifecycle-Events):
    - 8 Job-Lifecycle-Einträge: `scraper_proposal_created` (15.01.) · `vakanz_confirmed`/`status_changed` (02.04.) · `job_ad_generated` (15.04.) · `matching_computed` (16.04.) · `jobbasket_added` (15.04.) · `process_created` (10.04.) · Exposé versandt (15.04.)
    - Kategorie-Chip-Counts job-realistisch (51 total)
- JS: alle neuen Funktionen inline am Ende des Blocks (`onScoreSlider/toggleAllMatches/updateBulkBtn/bulkToJobbasket/runRecompute/switchJbView/genJobAd`)
- Sanity-Check: div-balance 0 · 7 tab-panels · alle Funktionen definiert + aufgerufen
- Backup: `backups/jobs.html.2026-04-16-phaseC.bak`

---

## [2026-04-16] update | Jobs Phase B · Design-System-Cleanup

- `mockups/jobs.html`:
  - 4 KPI-Strips (Tab 1, 2 Matching, 4 Prozesse, 5 Dokumente) von inline-grid auf canonical `.kpi-strip cols-5`/`cols-4`
  - Alle `kpi-card` mit `style="color:var(--red|gold|amber)"` auf Modifier-Klassen (`.red`/`.gold`/`.amber`)
  - Alle `kpi-value` mit `style="color:var(--X)"` entfernt (Farbe vom Parent-Modifier)
- Verbleibende `style="color:var(--red)"` sind legitime Meta-Accents: Process-Card Stale-Hints (Zeile 306/357), Table-Cell Stale-Days (434/444), Chip-Filter-Dot (1022), Section-Head H3 (1032), Form-Required-*

Jobs damit P1-canonical-konform.

## [2026-04-16] update | Jobs Phase A · Tab-Swap + Parity-Infrastruktur

**Tab-Reihenfolge umgestellt** nach User-Wunsch (Matching vor Jobbasket):
- Tab 2 = Matching (vorher Jobbasket) — Panel-ID + Label getauscht
- Tab 3 = Jobbasket (vorher Matching) — Panel-ID + Label getauscht

**Phase A · Parity mit accounts/candidates/mandates/groups:**
- **Tab 7 Reminders neu**: Job-spezifische Typen (Stage-Deadline, Vakanz-Bestätigung, Matching-Refresh, Schließungs-Check, Stellenausschreibung-Update, Follow-up, Custom). 5 Demo-Reminders in 4 Status-Sektionen + 8 erledigt
- **drawer-backdrop** ergänzt
- **uploadDrawer** neu mit **Job-Profile** 5 Kategorien (Stellenausschreibung · Briefing · Matching-Export · Organigramm-Position · Sonstiges) + Sprach-Dropdown (DE/FR/IT/EN) + Auto-Urheber
- **historyDrawer** (drawer-wide) mit kontextabhängigen Tabs
- **reminderDrawer** neu
- Upload-Button Tab 5 wire · Row-Click Tab 6 hist-rows wire · kb-bar auf 1–7

**Design-System-Cleanup (early B-Prep):**
- Header „✕ Schliessen"-Button von `style="color:var(--red)"` auf `.btn-danger`-Klasse

**jobs-list.html** Auto-Row-Wiring ergänzt (analog zu accounts-list/candidates-list/mandates-list/groups-list).

Backup: backups/jobs.html.2026-04-16-pre-phase-a.bak
Verifiziert via JSDOM: 7 Tabs, Tab-Swap korrekt (Matching/Jobbasket), alle 3 Drawer + Handler funktional.

## [2026-04-16] update | Firmengruppen Tab 3 Kontakte · Account-Parity + contactDrawer

- `mockups/groups.html` Tab 3 Kontakte komplett überarbeitet:
  - **Gruppen-weite Entscheider**-Sektion: list-item-Format durch **data-table** ersetzt (identisch zu Account Tab 3 Layout)
  - Neue Spalten: Name (mit org-pill + Kandidatenprofil-Link) · Position+Department · **Gesellschaft** (neu gegenüber Account) · Org-Funktion · Phone · Email · Letzter Kontakt · Status · Aktionen (📞 ✉ 🕒 ›)
  - 5 Entscheider: Dr. Thomas Muster (VR-Präsident Holding) · Peter Keller (VR) · Hans Müller (CEO) · Regina Weber (COO) · Claudia Widmer (CEO Immobilien)
  - Zweite Sektion „Weitere Kontakte" (HR · Einkauf · Assistenz) mit 4 Beispielzeilen + „10 weitere"-Row
  - Collapsible-Sections via `.section-head`
  - Hint-Banner oben (Grundprinzip · read-only Gruppen-Aggregat)
  - Filter-Bar mit Gesellschaft-Select · Org-Funktion · Status
- **contactDrawer** (drawer-wide, 4 Tabs: Stammdaten · Kommunikation · Prozesse · Notizen) 1:1 aus accounts.html nach groups.html kopiert
  - Pane 1 Stammdaten: Personen-Read-only + Gesellschafts-Beziehung + Onboarding-Notizen
  - Pane 2 Kommunikation: 5 Comm-Items mit Filter-Chips
  - Pane 3 Prozesse: 3 Items inkl. Taskforce-Markierung „🏛 Gruppen-Mandat"
  - Pane 4 Notizen
  - Footer-Button „Bearbeiten (→ Account)" verweist auf Pflege-Ort
- 17 Click-Handler in Tab 3 öffnen `contactDrawer` (Entscheider + weitere Kontakte · je › für Details, 🕒 für Verlauf)
- Reminder-Button im Drawer-Foot wired auf `openReminderNew()`

Tab 3 Kontakte jetzt vollständig konsistent mit accounts.html Pattern.

## [2026-04-16] update | crm.html Sidebar zurück auf List-Views · Row-Click-Navigation

User-Entscheid: Standard-Flow wiederherstellen · Sidebar → List-View → Row-Klick → Detail-Maske.

- `mockups/crm.html`: Sidebar-Items für Kandidaten/Accounts/Firmengruppen/Mandate zurück auf `-list.html`-Pfade. Default-iframe-src auf `candidates-list.html`.
- Alle 4 List-Views bekommen DOMContentLoaded-Wiring-Script am Ende:
  - `candidates-list.html` (7 pointer-rows) → candidates.html
  - `accounts-list.html` (10 pointer-rows) → accounts.html
  - `mandates-list.html` (7 pointer-rows) → mandates.html
  - `groups-list.html` (4 pointer-rows) → groups.html
  - Script: `document.querySelectorAll('tr[style*="cursor:pointer"]').forEach(tr => { if (!tr.hasAttribute('onclick')) tr.addEventListener('click', () => location.href = 'DETAIL.html'); });`
  - Rows mit bereits inline-onclick werden NICHT überschrieben

Flow jetzt: Sidebar klicken → Liste lädt → Row klicken → Detail-Maske lädt im gleichen iframe.

## [2026-04-16] update | Accounts +Reminder-Parity mit anderen 3 Masken

Finaler Konsistenz-Fix aus 4-Masken-Audit:

- `mockups/accounts.html` `+ Reminder`-Button umgestellt von `openDrawer('reminderDrawer',0)` auf `openReminderNew()` (parity mit candidates/mandates/groups)
- `openReminderNew()` Function inline ergänzt: Reset von remTitle/remContext/remDue · Default-Due = morgen 10:00 · Header-Text/Chips auf „Neuer Reminder"
- reminderDrawer form-fields + header bekommen IDs (remTitle, remType, remDue, remOwner, remContext, remDrawTitle, remDrawSub, remDrawChips, remLinkDisplay) damit openReminderNew() greift

Alle 4 Masken jetzt pixel-identisch im Reminder-Pattern: Klick auf `+ Reminder` → openReminderNew() → Drawer öffnet mit leeren Feldern + „Neuer Reminder"-Titel + morgen-10:00-Default-Due.

**4-Masken-Konsistenz final: 10/10 Dimensions bestanden, keine Inkonsistenzen mehr.**

## [2026-04-16] update | Firmengruppen Phase E · Wiki-Sync

- `wiki/entities/firmengruppe.md`: von 33 Zeilen (dünn) auf 170 Zeilen komplett überarbeitet. Inhalt:
  - DB-Schema (dim_firmengruppen, bridge_mandate_accounts, fact_protection_window scope)
  - Frontend-Route + Mockup-Referenz
  - 7 Tabs-Übersicht mit den wichtigsten Features
  - Header-Spezialitäten (Holding-Badge, Snapshot-Bar, Scraper-Banner, Gruppen-Report)
  - 2 Erstellungs-Flows (Scraper-Vorschlag vs. manuell)
  - Gruppenübergreifende Taskforces (nur Taskforce-Typ darf Gruppe-übergreifen)
  - Schutzfrist gruppenweit (KRITISCH · FG-10 · 2 fact_protection_window-Einträge)
  - 11 Gruppen-Event-Typen (group_created_manual, group_mandate_created, etc.)
  - Dokumente-Kategorien (Group-Profile-Referenz)
  - 7 Reminder-Typen Gruppen-spezifisch
  - RBAC-Tabelle
  - Mockup-Status (Phase A–D ✅)
  - Related-Links
- `index.md` Entity-Entry „[[firmengruppe]]" erweitert mit aktuellem Feature-Umfang

Firmengruppen-Mockup damit komplett spec-konform, design-system-konform und wiki-dokumentiert. Alle 5 Phasen A–E abgeschlossen.

## [2026-04-16] update | Firmengruppen Phase D · Header-Specials

- **🏛 Holding-Badge** direkt hinter h1-Titel + Klasse-A-Chip (aggregiert) in Banner-Title
- **Banner-Meta erweitert**: Gruppen-Manager · Sitz + UID (CHE-123.456.789) · Website · Gründungsjahr (mit Holding-seit-Jahr)
- **"📄 Gruppen-Report" Quick-Action** ergänzt (btn-primary für Sichtbarkeit) plus "🔔 Reminder"-Button wired auf `openReminderNew()`
- **Scraper-Vorschlag-Banner** (amber, dismissible) als Feature-Demo oben: UID-Match-Hinweis, Bestätigen/Ablehnen-Buttons + ✕-Schliessen
- **Snapshot-Bar (sticky, 6 Slots)** nach Banner, vor Tab-Bar: Gesellschaften · Mitarbeitende · Umsatz · Offene Mandate · Aktive Prozesse · Placements. Libre-Baskerville-Zahlen, Icons 18px, letter-spaced Caps-Labels. Placements in gold hervorgehoben.
- **Tab 1 KPI-Strip umfokussiert** auf Arkadium-Relation (nicht Firmografik-Duplikation): Umsatz Arkadium YTD · Placements total · Ø Time-to-Hire · Conversion CV→Placement · Ø Penetration. Entspricht dem Accounts-Tab-1-Pattern.
- **Meta-Zeile**: „bestätigt durch PW · 12.03.2024" unter den Chips (Audit-Trail sichtbar)

Header jetzt vollständig spec-§4-konform.

## [2026-04-16] update | Firmengruppen Phase C · Spec-Features komplett

Alle 6 Tabs spec-konform ausgebaut:

- **Tab 1 Übersicht**: Sparten-Verteilung visuell als Progress-Bars (kpi-progress mit accent/green/amber); Customer-Class als Chips; Penetration-Score kontextualisiert
- **Tab 2 Kultur**: Neue Card „5 · Quellen &amp; Vertrauen" mit 6 Quellen-Einträgen (Holding-Website · Geschäftsberichte · Aggregated News · Gesellschafts-Kultur-Scores · Manuelle Notizen · Generierungs-Meta) + Confidence-Badges (high/medium/confirmed)
- **Tab 3 Kontakte**: keine Änderung (war bereits gut — Gruppen-weite Entscheider oben + Full-Tabelle mit Gesellschafts-Spalte)
- **Tab 4 Mandate &amp; Prozesse**: Filter-Bar ergänzt (Gesellschaft-Select + Status + Typ + Zeitraum + Export); Gruppenübergreifende-Mandate-Tabelle mit beispielhaft 1 Taskforce-Mandat (führende Gesellschaft + beteiligt)
- **Tab 5 Dokumente**: **KOMPLETT NEU** mit Group-Profile-Kategorien:
  - 6 Kategorien: Rahmenvertrag · Master-NDA · Konzern-AGB · Gruppen-Präsentation · Holdings-Geschäftsbericht · Sonstiges
  - 11 realistische Demo-Rows (Rahmenvertrag 2025–2028, 2× NDA, Konzern-AGB, 2× Präsentationen, 3× Geschäftsberichte 2023–2025, 2× Sonstiges)
  - **Gültigkeitsbereich-Spalte** (🏛 Ganze Gruppe vs Subset) als neue Tabellen-Spalte
  - KPI-Strip korrigiert (11 Total, nicht 77)
- **Tab 6 History**: Mix-Strategie implementiert
  - **Neue Scope-Filter**: „Alle Scopes / 🏛 Nur Gruppen-Events / 🏢 Nur Gesellschafts-Events"
  - **Gesellschafts-Filter**: Multi-Select (Bauherr Muster AG / Muster Immobilien AG)
  - **Chip-Legende**: „🏛 Gruppen-Events 11" als dedizierter Chip
  - 4 Gruppen-Events als goldene border-left-Marker:
    - `group_document_uploaded` (Geschäftsbericht 2025)
    - `group_culture_generated` (Kultur-Analyse v2)
    - `group_mandate_created` (Taskforce PL Hochbau)
    - `group_framework_contract_added` (Rahmenvertrag bis 2028)
  - Account-Events mit Gesellschafts-Link versehen (vorher anonym)

`wiki/concepts/dokumente-kategorien.md` aktualisiert mit 3. Profile „Group-Profile" (Firmengruppe) inkl. 6-Kategorien-Tabelle + Gültigkeitsbereich-Regel.

## [2026-04-16] update | Firmengruppen Phase B · Design-System-Cleanup

- `mockups/groups.html`:
  - 3 KPI-Strips (Tab 1, 4, 5) von inline `style="display:grid;grid-template-columns:repeat(N,1fr);gap:12px;margin-bottom:16px"` auf canonical `.kpi-strip cols-N` umgestellt
  - Alle `kpi-card` mit `style="color:var(--gold)"` auf `.kpi-card.gold` Modifier-Klasse
  - Alle `kpi-value` mit `style="color:var(--gold)"` entfernt (Farbe kommt jetzt vom Parent-Modifier)
  - Verbleibende `style="color:var(--red)"` sind legitim: Chip-Filter-Dot (●), Section-Head-Heading, Form-Required-Asterisks (*)
- Tab 6 History: 8 verschiedene `cat-XXX` Kategorien korrekt im Einsatz (cat-erreicht, kontakt, email, interview, placement, mandat, assessment, system) — alle Stammdaten-konform

Groups jetzt konform mit P1-Canonical-Schema.

## [2026-04-16] update | Firmengruppen Phase A · Parity mit accounts/candidates/mandates

- `mockups/groups.html`:
  - **Tab 7 Reminders** neu (Gruppen-spezifische Typen: Rahmenvertrag-Review, Jahres-Report, Gruppen-Mandats-Opportunity, Scraper-Group-Match, Kultur-Update, Follow-up, Custom). 6 Demo-Reminders in 4 Status-Sektionen + 9 erledigt collapsed. Filter-Bar mit Gesellschafts-Select.
  - **drawer-backdrop** ergänzt (war Pflicht-Element, fehlte)
  - **uploadDrawer** neu mit 6 **Group-Profile-Kategorien**: Rahmenvertrag · Master-NDA · Konzern-AGB · Gruppen-Präsentation · Holdings-Geschäftsbericht · Sonstiges + **Gültigkeitsbereich-Toggle** (ganze Gruppe / Subset)
  - **historyDrawer** (drawer-wide) neu mit kontextabhängigen Tabs
  - **reminderDrawer** neu
  - Upload-Button Tab 5 wire auf `openDrawer('uploadDrawer',0)`
  - +Reminder-Button Tab 7 wire auf `openReminderNew()`
  - Row-Click-Handler auf 12 hist-rows in Tab 6
  - kb-bar von `1-6 Tabs` auf `1-7 Tabs`
- `mockups/crm.html` Sidebar: Firmengruppen zeigt jetzt auf `groups.html` statt `groups-list.html`

Verifiziert via JSDOM: 7 Tabs · 6 Reminder-Rows · 3 Drawers · Hist-Click öffnet Drawer mit 4 Tabs.

Backup: backups/groups.html.2026-04-16-pre-phase-a.bak

## [2026-04-16] update | Accounts History-Drawer eingebaut (Parity mit candidates/mandates)

User-Report: Klick auf History-Eintrag in accounts.html öffnete keinen Drawer.

- `mockups/accounts.html`: `historyDrawer` (drawer-wide) + JS-Block hinzugefügt (identisch zu mandates/candidates):
  - `HIST_CHAN_MAP` für Kanal-Erkennung (cat-erreicht/email/interview/placement/mandat/assessment/system → Phone/Email/System)
  - `openHistDrawer(rowEl)` parst Row-Content, baut kontextabhängige Tabs
  - `histSwitchTab()` + `histRenderPane()` für 6 mögliche Panes (Übersicht · Email-Thread · Transkript · AI-Summary · AI→Briefing · Reminders)
  - DOMContentLoaded-Listener wire 12 hist-rows in Tab 11 klickbar
- crm.html unverändert: lädt accounts.html via iframe → Änderung greift automatisch

**Getestet via JSDOM**: Click auf erste History-Zeile (Update-Call) → Drawer öffnet mit 4 Tabs „Übersicht · Transkript · AI-Summary · Reminders".

## [2026-04-16] update | crm.html Sidebar auf Detailmasken umgestellt

User-Entscheid: Sidebar zeigt direkt auf Detailmasken statt Listen-Views, damit die harmonisierten Mockups sofort demonstriert werden können.

- `mockups/crm.html` Sidebar-Items:
  - Kandidaten: `candidates-list.html` → `candidates.html`
  - Accounts: `accounts-list.html` → `accounts.html`
  - Mandate: `mandates-list.html` → `mandates.html`
- Default-iframe-src: `candidates-list.html` → `candidates.html` (Kandidat-Detailmaske lädt initial)
- List-Views der 3 Entities (`candidates-list.html`, `accounts-list.html`, `mandates-list.html`) bleiben unverändert verfügbar via Direkt-URL, nur aus der Sidebar nicht mehr verlinkt
- Andere Entities (Firmengruppen, Jobs, Projekte, Prozesse, Assessments) zeigen weiterhin auf die List-Views
- Theme-Sync + Hash-Routing funktionieren weiterhin (generisch via data-src-Attribut)

## [2026-04-16] update | Design-System-Dokumentation + finaler Consistency-Check

Nach P0-P4 systematischer Consistency-Check der 3 Detailmasken via Explore-Agent. **Ergebnis: alle harmonisiert, keine Inkonsistenzen mehr.**

**Verifizierte Konsistenz:**
- Tab-Struktur · Entity-Header · Drawer-Backdrop · Drawer-Head-Pattern
- KPI-Strip (canonical `.kpi-strip.cols-N` mit Farb-Modifier)
- Chip-Filter (filter-bar → chip-group → chip-tab)
- data-table mit Row-Click → Drawer
- History-Timeline (hist-cat-chip Kategorien)
- Reminder-Sections (data-rem-group)
- Upload/History/Reminder-Drawer in allen 3 Masken
- Keine JS-Duplikate
- Keine inline-Color-Overrides auf Komponenten mit dedizierten Klassen

**Neues Design-System-Dokument**: `wiki/concepts/design-system.md` — vollständige Referenz mit 10 Sektionen:
1. Farb-Palette (semantische Farbzuweisung + Soft-Varianten)
2. Typografie (Libre Baskerville vs. DM Sans, Grössen-Hierarchie, Letter-Spacing)
3. Komponenten (Tabs, KPI-Strip, Drawer, Buttons, Chip-Filter, Data-Tables, History, Reminder, Upload, Form-Grid)
4. Layout & Spacing (Padding-Conventions)
5. Icon-Konventionen (Inline-Emojis, Category-Icons)
6. Shared JavaScript (`layout.js`-Funktionen)
7. Drawer-Infrastruktur-Pflicht (Backdrop + Scripts)
8. Stammdaten-Regeln (Activity-Types, Stages, Sparten, Umlaute)
9. Weitere Conventions (Drawer-Default, Datum-Eingabe, Urheber, Dokumente-Kategorien, DB-Technikdetails)
10. **Quick-Start-Checkliste** für neue Tabs

Ergänzt zu `index.md` unter Concepts → Referenz & Modelle.

**Purpose**: Künftige Detailmasken-Tabs haben jetzt eine **Single Source of Truth** für alle Design-Entscheidungen. Vor jedem neuen Tab: Checkliste abarbeiten.

## [2026-04-16] update | P4 · Dokumente-Kategorien-Schema konsolidiert (2 Profile)

Audit hat 3 Findings geliefert:

1. **Accounts hatte keinen Upload-Drawer** — nur einen toten +Upload-Button (kein onclick) → Gap geschlossen
2. **Mandates Chip-Filter-Counts waren aus Accounts copy-paste**: „77 Alle, 38 Rechnungen, 12 Offerten" — für ein einzelnes Mandat implausibel
3. **Kategorien-Divergenz zwischen Accounts/Candidates war semantisch korrekt**, nicht inkonsistent

**Canonical Schema (2 Profile) dokumentiert in `wiki/concepts/dokumente-kategorien.md`:**

- **Personal-Profile** (Kandidaten, 11 Kategorien): Original CV · Arbeitszeugnisse · Diplome · Projektliste · Arbeitsvertrag · ARK CV · Abstract · Exposé · Assessment · Referenz · Sonstiges
- **Commercial-Profile** (Accounts + Mandate, 6 Kategorien): Offerten & Verträge · Rechnungen · Stellenbriefing · Assessment-Order · Scraper-Beleg · Sonstiges

Account und Mandat teilen das Commercial-Profile identisch, unterscheiden sich nur in Scope (aggregiert vs. einzelnes Mandat) → Counts skalieren entsprechend.

**Änderungen:**

- **accounts.html**: +Upload-Button wired auf `openDrawer('uploadDrawer',0)`, neuer `<div id="uploadDrawer">` mit 6 Commercial-Kategorien, Dropzone, Auto-Urheber, komplette `doUpload()`-Logic inline (parity mit candidates/mandates)
- **mandates.html**: Chip-Filter-Counts auf Mandat-Scope korrigiert (77→11, 38→3, 12→2, 14→2, 6→1, 3→0, 4→3). KPI-Strip-Counts in Tab 6 gleichermassen korrigiert (Total 77→11, Rechnungen 38→3, Offerten 12→2, Assessment 14→2).

**Parity-Status P4 abgeschlossen:**

| | Accounts | Candidates | Mandates |
|---|---|---|---|
| Chip-Filter | ✓ 6 (Commercial) | ✓ 11 (Personal) | ✓ 6 (Commercial) |
| Upload-Drawer | ✓ neu | ✓ 11 Kategorien | ✓ 6 Kategorien |
| Count-Plausibilität | ✓ | ✓ | ✓ korrigiert |

Neue Wiki-Seite: `wiki/concepts/dokumente-kategorien.md` mit Schema-Convention + Implementierungs-Pattern.

Backup: backups/accounts.html.2026-04-16-pre-p4.bak

## [2026-04-16] update | P3 · JS-Duplikate bereinigt (Funktionen zentral in layout.js)

Audit: 3 Funktionen in candidates.html + 1 in mandates.html waren sowohl inline als auch in layout.js definiert → stille Überschreibung, Maintenance-Risiko.

**Duplikate entfernt:**
- `filterDocCat` (candidates inline) → layout.js-Version nutzen (kompatibel mit `#doc-view-list tbody tr[data-cat]` Struktur)
- `switchDocView` (candidates inline) → layout.js-Version (identisch, reiner Dup)
- `filterRemStatus` (candidates inline + mandates inline) → layout.js-Version erweitert

**layout.js filterRemStatus enhanced**: statt globalem `document.querySelectorAll('[data-rem-group]')` jetzt scoped zu nächstem `.tab-panel` Ancestor + done-section Toggle (collapsed `.section-head` + `.section-body`). Funktioniert jetzt für alle 3 Masken aus shared Code.

**Ergebnis:**
- candidates.html: ✓ keine Duplikate mehr
- mandates.html: ✓ keine Duplikate mehr
- accounts.html: ✓ bereits clean

**Verified via JSDOM:**
- Candidates Tab 10 · filterRemStatus('today') → nur Today-Section sichtbar
- Mandates Tab 7 · filterRemStatus('overdue') → nur Überfällig-Section sichtbar
- Candidates Tab 8 · filterDocCat('arbeitszeugnis') → 3/22 Rows sichtbar (korrekte Filterung)

22 Funktionen in layout.js, 59 unique inline in candidates, 0 Überschneidung.

## [2026-04-16] update | P2 · Wide-Drawer-Pattern auf alle 3 Masken ausgeweitet

**CSS-Migration**: `.drawer-wide` (760 px max-width, Gradient-Head, mehr Padding) von inline in candidates.html nach editorial.css gezogen. Jetzt shared und in allen Mockups nutzbar.

**Drawer-wide Anwendungsregel**: Multi-Tab-Detail-Drawer mit komplexen Edit-Forms oder langen Text-Panes.

Angewandt:

| Mask | Wide-Drawer | Warum |
|---|---|---|
| accounts | 7: mandatDrawer (5 Tabs), claimDrawer (3), procDrawer (3), vakanzDrawer (2), jobDrawer (4), posDrawer (3), contactDrawer (4) | komplexe Multi-Tab-Edits |
| candidates | 4: educationDrawer (4), stationDrawer (4), werdegangProjektDrawer (5), historyDrawer (dynamisch 2–6) | unverändert + historyDrawer neu für Transkript/Email-Lesbarkeit |
| mandates | 1: historyDrawer (dynamisch 2–6) | Transkript-Lesbarkeit |

**Konsistenz-Win**: Accounts-Kontakt-Edit (contactDrawer, 4 Tabs) hatte bisher nur 540 px — User hatte wenig Raum für Kommunikations-History + Stammdaten-Edit gleichzeitig. Jetzt 760 px.

**Nicht-Wide (bleiben 540)**: Simple Form-Drawer (uploadDrawer, reminderDrawer, docDrawer, aktivierenDrawer, optionDrawer, cancelDrawer) — sinnvoll kompakt.

Backup: backups/accounts.html.2026-04-16-pre-p2.bak

## [2026-04-16] update | P1 · KPI-Strip vereinheitlicht (alle 3 Detailmasken)

Canonical KPI-Strip-Schema in editorial.css etabliert:

```css
.kpi-strip { display:grid; gap:12px; margin-bottom:16px; }
.kpi-strip.cols-{2|3|4|5|6} { grid-template-columns:repeat(N,1fr); }
.kpi-strip .kpi-card { ... + ::before 3px Color-Accent-Strip oben }
.kpi-strip .kpi-card.{red|gold|green|amber|blue|purple|muted} { color-variant }
```

HTML-Pattern (einheitlich in allen 3 Masken):
```html
<div class="kpi-strip cols-5">
  <div class="kpi-card red"><div class="kpi-label">Überfällig</div><div class="kpi-value">2</div><div class="kpi-sub muted">sofort</div></div>
</div>
```

Refactored:
- **accounts.html**: 6 KPI-Strips, 28 Cards. Alte `.kpi k-gold/k-green/k-blue/k-amber` + `.kpi-val` auf canonical `.kpi-card gold/green/blue/amber` + `.kpi-value` gemappt. Tab-1 + Drawer-Pane-Longlist.
- **candidates.html**: 3 KPI-Strips, 16 Cards. Inline `style="color:var(--red|gold)"` auf Modifier-Klassen. Tab 1 (cols-6), Tab 8 Dokumente (cols-5), Tab 10 Reminders (cols-5).
- **mandates.html**: 6 KPI-Strips, 30 Cards. Alle inline-Color-Styles (red/gold/amber) auf Modifier-Klassen. Tab 1/2/3/4/7.

Ergebnis: **Keine inline `style="display:grid;..."` oder `style="color:var(--X)"` mehr in KPI-Strips der 3 Detailmasken.** Alle nutzen identische Klassen-Nomenklatur.

Deprecated-Aliase (für Rückwärts-Kompat): `.kpi` + `.kpi-val` in editorial.css zeigen auf canonical-Styles.

Noch ausstehend (nicht im P1-Scope): Liste-Views (accounts-list, candidates-list, mandates-list, jobs-list, etc.) + weitere Detailmasken (jobs, projects, groups, assessments, dashboard) nutzen noch alten Inline-Style-Pattern. Können separat auf canonical gezogen werden.

## [2026-04-16] update | Mandates auf Candidates-Parity (P0)

Audit der 3 Detailmasken hat ergeben: Mandates war massiv underdeveloped (84 KB vs 561 KB Candidates). P0-Lücken geschlossen:

- **Tab 7 Reminders** neu hinzugefügt: 5-Col KPI-Strip (Offen/Überfällig/Heute/Woche/Erledigt) · Filter-Bar mit Mandat-spezifischen Typen (Mandat-Review, Stage-Deadline, Kandidat-Nachfassen, Abschluss-Rechnung, Debriefing, Follow-up, Schutzfrist, Garantie) · Status-Chip-Tabs · 4 Status-Sektionen (Überfällig · Heute · Woche · Später) mit je Demo-Zeilen · collapsed „Erledigt"-Sektion
- **uploadDrawer** neu: Drop-Zone + Datei-Picker · Kategorie-Select Mandat-spezifisch (Offerte/Vertrag, Rechnung, Stellenbriefing, Assessment, Scraper, Sonstiges) · Titel/Notiz/Verknüpfung · Auto-Urheber (aktueller User, read-only) · doUpload() fügt Row live in Tab 6 Dokumente-Tabelle ein
- **historyDrawer** neu mit kontextabhängigen Tabs: Übersicht (immer) · Email-Thread (cat-email) · Transkript (Phone-answered) · AI-Summary (answered && !briefing) · AI→Briefing (briefingCall) · Reminders (immer). Row-Click auf Tab 5 hist-row öffnet Drawer.
- **reminderDrawer** neu: Titel · Typ · Fällig · Zuständig · Kontext · Verknüpfung · Wiederholen · Vorlaufzeit · openReminderNew() reset + Default-Due morgen 10:00 · saveReminder() sortiert in Sektionen (overdue/today/week/later) per dayDiff
- **drawer-backdrop** fehlte komplett in mandates → ergänzt. Alle openDrawer-Calls funktionieren jetzt ohne TypeError.
- **Upload-Button in Tab 6** wire: `onclick="openDrawer('uploadDrawer',0)"` 
- **+Reminder-Button** in Tab 7: `onclick="openReminderNew()"`

Inline-Red-Styles Cleanup:
- Header „Mandat kündigen"-Button: `style="color:var(--red)"` → neue Klasse `.btn-danger`
- CancelDrawer Submit: `style="color:var(--red)"` → `.btn-danger.btn-primary` (filled red)
- Neue CSS-Klassen in editorial.css: `.btn-danger` + `.btn-danger:hover` + `.btn-danger.btn-primary` (jetzt global verfügbar für alle 3 Masken)

Datei: 1410 → 2034 Zeilen (+44 % durch Tab 7 + 3 Drawer + JS).

Backup: backups/mandates.html.2026-04-16-pre-p0.bak

## [2026-04-16] update | Dok-Generator · CSS-Bug-Fix Type-Switching + Deckblatt zu ARK CV

**Bug-Fix (kritisch)**: `.gl-expose { display:flex }` Regel überschrieb `.gen-layout-block { display:none }`-Default → alle Layouts waren gleichzeitig sichtbar. User sah beim ARK CV Abstract + Exposé hintereinander. Fix: `display:flex` von `.gl-expose` entfernt, nur noch in type-spezifischer Regel.

**ARK CV jetzt 3 Seiten**:
- Seite 1 / 3 · Deckblatt (Arkadium-Logo + KANDIDATENDOSSIER + Kandidatenname)
- Seite 2 / 3 · Dossier (Überblick + Werdegang + Ausbildung + optional Gehalt)
- Seite 3 / 3 · Projektauszug (4 Referenzprojekte)

**Page-Break Dashes**: Flex-Zentrierung ersetzt inline-block, perfekt zentrierte Dashes um Label herum.

Abstract (1/1) + Exposé (1/5-5/5) unverändert.

Footer/Header-Audit:
- ARK CV: Arkadium-Contact im Navy-Sidebar (kombiniert Header+Footer)
- Abstract: Fusszeile_Externe.jpg (gray footer mit Logo + 3-Col-Contact + Social-Icons)
- Exposé: banner-top.png Top-Bar (Navy mit gold A-Badge) + „www.arkadium.ch N" Page-Num

## [2026-04-16] update | Dok-Generator · Layout-Cleanup (Anschreiben raus, Projektauszug rein)

User-Feedback: Anschreiben gehört nicht zu Abstract, nur das Abstract. ARK CV braucht zusätzlich Projektauszug-Seite.

- **Abstract-Layout**: Anschreiben-Seite (Seite 1/2 Dossiervorstellung) komplett entfernt. Nur noch die Abstract-Seite mit Navy-Hero + GOOD TO KNOW + EDV-KENNTNISSE + WARUM/MOTIVATION/KOMPETENZEN/REFERENZEN + CTA. Label: „Seite 1 / 1 · Abstract"
- **ARK CV-Layout**: In 2 Seiten gesplittet.
  - Seite 1: Überblick · Berufliche Tätigkeit · Aus- und Weiterbildung · (optional Gehalt)
  - Seite 2: Projektauszug mit 4 Projekten (Gubrist Tunnel, Limmattalbahn Los 4, Hardbrücke Zürich, Limmattalbahn Los 2) · je mit Bauherr · Architekt · Beschrieb · Bausumme · Kompetenz
- **Exposé-Layout**: Unverändert (5 Seiten: Deckblatt, Titelseite, Pitch&Werdegang, Referenzen&Entscheidung, AGB-Hinweis)

Neue CSS-Klassen `.cv-project-item`, `.cv-project-title`, `.cv-project-meta`, `.cv-project-body` für Projektauszug-Layout (Navy-Titel, Gold-Meta, Gold-Trennlinie zwischen Projekten).

Backup: backups/candidates.html.2026-04-16-pre-restructure.bak

## [2026-04-16] update | Dok-Generator · Original-Assets integriert + Seiten-Pagination

**Asset-Integration** (raw/assets/ gesichtet, 11 relevante kopiert nach mockups/assets/):
- `logo.png` / `logo-plain.png` / `logo-white.png` — Arkadium-Logo-Varianten
- `a-badge-gold.png` — Gold-A.-Badge (Outline)
- `banner-divider.png` — Exposé P2 Divider-Banner (Navy-Band + Gold-A.-Overlap)
- `banner-top.png` — Exposé P3+ Top-Bar (Navy mit A.-Badge zentriert)
- `banner-disclaimer.png` — Exposé P5 AGB-Hinweis (A.-Badge + Gray-Band mit Disclaimer-Text)
- `cover.png` — Deckblatt (nicht genutzt, stattdessen logo.png)
- `future-built.png` — Anschreiben Claim-Element
- `sparten.png` — Anschreiben Sparten-Liste (ARCHITECTURE · REAL ESTATE · CIVIL · BUILDING TECH)
- `footer-external.jpg` — Gray-Footer-Band mit Logo + 3-Col-Kontakt + Social-Icons

**Mockup-Updates (mockups/candidates.html Tab 9):**
- Anschreiben: CSS-Text-Rendering ersetzt durch 3 `<img>` Tags (future-built + logo-plain + sparten)
- Footer: Manuelles HTML (ark-footer-band + SVG-Icons) durch `<img src="footer-external.jpg">` ersetzt
- Exposé P2 Divider: Manuelle CSS-Konstruktion durch `<img src="banner-divider.png">` mit Text-Overlay
- Exposé P3/P4 Top-Bar: `.exp-top-bar` ersetzt durch `<img src="banner-top.png">`
- Exposé P5 Disclaimer: Body durch `<img src="banner-disclaimer.png">` (Originaltext als Bild)

**Pagination · Visuelle Seitenumbrüche:**
- Neue `.page`-Klasse mit 210×297mm white Box + Box-Shadow (jede logische Seite ist visuell distinct)
- `.page-start` / `.page-break` Labels zwischen Seiten mit gepunkteter Linie und "Seite X / Y · Label"
- Jeder Typ hat klare Seiten-Struktur:
  - ARK CV: 1/1 Dossier
  - Abstract: 1/2 Anschreiben · 2/2 Abstract
  - Exposé: 1/5 Deckblatt · 2/5 Titelseite · 3/5 Pitch&Werdegang · 4/5 Referenzen&Entscheidung · 5/5 AGB-Hinweis

**Exposé-Content-Split**: Lange P3 in P3+P4 aufgeteilt (Job Letzter + Referenzen + Persönliches + CTA auf P4)

**Bug-Fix**: `.anon-able-city` → `.exp-job-city` für Job-Standorte im Exposé (THUN/DIETLIKON/BERN bleiben erhalten, nicht mehr bei Location-Anonymisierung überschrieben)

Backup: backups/candidates.html.2026-04-16-pre-assets-integration.bak

## [2026-04-16] update | Dok-Generator 1:1-Refinement (alle Originaldokument-Details)

10 gezielte Abweichungen zur Brand-PDF-Vorlage behoben:
- **"WER POTENZIALE ERKENNT" CTA-Titel**: Farbe gold → navy (wie Original), letter-spacing 0.25em
- **EDV-Balken**: 2px thin → 3mm height mit Gold-Gradient-Fill (Original-Look)
- **Exposé-Divider Seite 2**: A-Badge überlappt jetzt Navy-Kante via margin-bottom:-11mm + box-shadow:0 0 0 6px #fff (half-white, half-navy wie Original)
- **Exposé Seite 5 Disclaimer**: Komplett neu hinzugefügt (Navy-Top-Bar + Arkadium-Introduction + zentraler A-Badge + anonymisiert-Hinweis + AGB-Klausel + www.arkadium.ch 5)
- **Social-Icons**: Platzhalter → echte SVG-Icons (LinkedIn "in", Instagram Camera-SVG, WhatsApp Phone-SVG) in gefüllten Navy-Kreisen
- **Footer-Band Placement**: Nur auf Anschreiben + Abstract (wie Original). ARK CV nutzt Sidebar-Kontakt. Exposé nutzt nur "www.arkadium.ch N"
- **Pull-Quotes**: font-size 11pt → 12pt · letter-spacing verstärkt · ::first-letter gold-Akzent
- **Chair-Image**: Pseudo-Element-Rechteck → inline SVG mit Barcelona-Chair-Look (X-Frame, Tufting-Pattern, dunkles Leder)
- **Abstract-Hero**: min-height 60mm → 90mm, Titel 20pt → 22pt, letter-spacing 0.5em → 0.6em (Original-Proportionen)
- **Gold-Line**: default 12mm → 22mm (prominent wie Original)

Backup: backups/candidates.html.2026-04-16-pre-1to1-refinement.bak

## [2026-04-16] update | Dok-Generator in ARK-Brand-Design (Navy + Gold, A.-Badge, Footer-Band)

- 3 Original-Dokumente ingested (raw/Ark Dokumente/): Ark_CV_PL_Arkadium_Arkadium.docx, Ark_Anschreiben_Abstract_Peter_Wiederkehr.pdf, Kandidatenexpose.pdf
- wiki/sources/dokument-templates.md: komplett überarbeitet mit Design-Spec (Farben, Typografie, Layout-Details pro Typ, Anonymisierungs-Wording)
- mockups/candidates.html Tab 9:
  - CSS komplett ersetzt: Arkadium-Brand-Variables (Navy #1a2540, Gold #b99a5a, Beige, Gray-Footer), Layout-Klassen für Anschreiben (ans-*), Abstract (abs-*), Exposé (exp-*), ARK CV (cv-*)
  - Canvas rendert 3 distinct Layouts via data-type: ARK CV (Sidebar navy + Main), Abstract (Seite 1 Anschreiben + Seite 2 Navy-Hero), Exposé (Cover + Navy-Divider + Content mit Pull-Quotes + „aspirierende Person"-Wording)
  - A.-Gold-Badge im Abstract-Hero + Exposé-Divider
  - Navy-Top-Bar auf jeder Exposé-Content-Seite („KANDIDATENEXPOSÉ")
  - Stuhl-Bild (CSS-pure via pseudo-elements) im Exposé „Darum passt der Aspirant"
  - Gold-CTA-Button „Das komplette Profil erhalten." am Ende Exposé
  - Footer-Band mit Arkadium-Kontaktdaten + Social-Icons
  - Anonymisierungs-Logik erweitert: ref-name Spans auto-update auf „der Aspirant" / „DEN ASPIRANT", anon-able-city auf „Raum Zürich", anon-able-company auf „—", Photo auf „?"
  - Name-Sync-Listener: Bearbeiten von genName propagiert zu allen ref-name Spans + Initials im Photo-Badge
- Backup: backups/candidates.html.2026-04-16-pre-ark-brand.bak

## [2026-04-16] update | Tab 9 WYSIWYG-Dok-Generator

- mockups/candidates.html: Tab 9 komplett ersetzt. WYSIWYG-Editor mit contenteditable-Sektionen auf A4-Canvas.
- Doc-Types: ARK CV (vollständig) · Abstract (mit Anschreiben) · Exposé (anonymisiert, Watermark)
- Templates: Classic · Modern · Minimal (Font/Spacing-Varianten via data-tpl)
- Sidebar (280px): 14 Section-Toggles mit Drag-Reorder (HTML5 DnD), Anonymisierungs-Panel (nur Exposé: Name/Foto/Firmen/Kontakt/Geburtsdatum/Wohnort), Datenquellen-Legende
- Toolbar: B/I/U, Headings, Listen, Alignment, Undo/Redo, Foto-Tausch, Zoom 50–150 %
- Auto-Sektionen per Doc-Type: Gehalt nur ARK CV (rote "nur intern"-Warnung), Anschreiben nur Abstract, Anonymisierung nur Exposé
- Actions: AI-Text · Speichern (Toast) · PDF-Export via Print-Dialog · Neue Version · Reset
- Cross-Tab-Completeness-Strip (Stammdaten/Briefing/Werdegang/Projekte/Dokumente/Assessment) mit Deeplinks
- Spec-Hinweis: Phase 2 des Specs (WYSIWYG) statt Phase 1 (Template-Fill) auf User-Wunsch umgesetzt
- Backup: backups/candidates.html.2026-04-16-pre-dokgen.bak

## [2026-04-16] update | History-Drawer v2-aligned + Upload-Urheber auto

- mockups/candidates.html:
  - History-Drawer komplett neu mit kontextabhängigen Tabs (v2-Spec): Übersicht (immer) · Email-Thread (cat-email) · Transkript (Phone-answered) · AI-Summary (Phone-answered, !briefingCall) · AI→Briefing (Phone-answered briefingCall) · Reminders (immer). Tab-Entscheidung per cat-class + Title-Pattern (NE/Briefing-Detection).
  - Übersicht-Pane mit allen v2-Feldern (Kategorie, Activity-Type, Kanal, Datum, Dauer, Richtung, Sentiment, Status, Quelle, Notizen, Verknüpfungen)
  - Email-Thread-Pane mit Antworten/Weiterleiten · Transkript-Pane als Whisper-Placeholder · AI-Summary mit Actions/Insights/Flags · AI→Briefing mit Feld-Mapping zur Briefing-Maske
  - Upload-Drawer: Urheber-Select entfernt → nur Display des aktuellen Users (data-value, muted "automatisch"-Hinweis)
- Backup: backups/candidates.html.2026-04-16-pre-hist-v2-tabs.bak

## [2026-04-16] update | Tab 8/10 funktional: Upload-Drawer, History-Drawer, Reminder-Drawer

- mockups/candidates.html:
  - Tab 8 Dokumente: 11 Kategorien (Original CV · Arbeitszeugnis · Diplom · Projektliste · Arbeitsvertrag · ARK CV · Abstract · Exposé · Assessment · Referenz · Sonstiges). Chip-Filter mit Live-Counts, 22 Demo-Zeilen. Upload-Button öffnet uploadDrawer mit Dropzone + Kategorie-Select + Metadaten + Verknüpfung. doUpload() fügt Row live in Tabelle, Flash-Highlight, KPI-Update, Count-Reset.
  - Tab 7 History: historyDrawer neu (war in accounts nicht vorhanden). Click auf hist-row öffnet Drawer mit Detail-Feldern (Typ, Datum, Akteur, Dauer, Inhalt, Verknüpfungen). Icon-Mapping per Kategorie (📞 ✉ 👔 🏆 📋 📊 ⚙).
  - Tab 10 Reminders: + Reminder-Button funktional via openReminderNew() (Felder-Reset, Default-Due +1 Tag 10:00). saveReminder() sortiert in Überfällig/Heute/Woche/Später-Sektion ein, Count-Bumps in KPI + Chip.
- Backup: backups/candidates.html.2026-04-16-pre-drawers.bak

## [2026-04-16] update | Tabs 7/8/10 Kandidatenmaske (History · Dokumente · Reminders) 1:1 von accounts.html übernommen

- mockups/candidates.html: Tab 7 History (10 hist-day, 10 Kategorien, Chip-Filter, Drill-down-Links), Tab 8 Dokumente (KPI-Strip, Liste/Kacheln-Toggle, 8 Kategorien, Doc-Gen/Upload-Attribution), Tab 10 Reminders (KPI-Strip, Status-Chips, Überfällig/Heute/Woche/Später/Erledigt-Sektionen, Auto-Trigger-Types)
- Struktur 1:1 vom Account-Mockup (Tab 11/12/13 → 7/8/10), Inhalte auf Kandidaten-Kontext übertragen (Referenzen, Zeugnisse, Interview-Coaching, Kandidaten-Refresh statt Rechnungen/Mandate/Stellenbriefings)
- Backup: backups/candidates.html.2026-04-16-copy-hist-dok-rem.bak

## [2026-04-15] update | Jobbasket-Logik überarbeitet

- specs/ARK_KANDIDATENMASKE_INTERACTIONS_v1_3.md: T5-14 bis T5-22 ergänzt (CV/Exposé-Flow, zentrale To-Send-Inbox, Auto-Stages, Oral GO Wording, Rejected↔History, Absagegrund stage-sensitiv, Suche funktional, AI collapsed)
- wiki/concepts/jobbasket.md: 6 neue Sektionen (Versand-Flow, To-Send-Inbox, Auto-Transitions, Oral-GO-Wording, History-Kopplung, Absagegrund-Katalog)
- mockups/candidates.html: Versand-Buttons entfernt, Auto-Stage-Hinweise ersetzt Buttons, Card-12 Rejection korrigiert (Account kann bei Written GO nicht ablehnen → intern zurückgezogen), Card-7 Rejection klargestellt (Kandidat abgesagt, erfasst durch PW), Ghosting-Text auf schriftliches GO, Info-Banner CV/Exposé, funktionale Suche mit JB_ACCOUNTS-Daten

## [2026-04-15] update | Tab 4 Assessment Read-only-Architektur

- specs/ARK_KANDIDATENMASKE_INTERACTIONS_v1_3.md: T4-28 bis T4-31 ergaenzt
- wiki/concepts/interaction-patterns.md: §12 Read-only-Visualisierungstabs ergaenzt
- mockups/candidates.html: Tab 4 Action-Buttons routen zu assessments.html, Read-only-Banner oben

---
title: "Wiki Log"
type: meta
created: 2026-04-08
updated: 2026-04-13
---

# Wiki Log

Chronological record of all wiki operations. Newest first.

## [2026-04-14] update | Activity-Types §14: #64 Schutzfrist Status-Änderung + Vorstellungs-Typ §10c

**Geändert:**
- `raw/Ark_CRM_v2/ARK_STAMMDATEN_EXPORT_v1_3.md` — §10c `dim_presentation_types` neu (email_dossier / verbal_meeting / upload_portal); §14 Activity-Types #64 „Schutzfrist - Status-Änderung" hinzugefügt (System/auto), Total 63 → 64, auto-logged 5 → 6
- `CLAUDE.md` — Activity-Types-Regel auf 64 aktualisiert
- `wiki/meta/spec-sync-regel.md`, `wiki/meta/overview.md`, `wiki/sources/stammdaten-export.md`, `wiki/concepts/history-system.md`, `index.md` — Count 63 → 64
- `wiki/concepts/direkteinstellung-schutzfrist.md` — History-Integration-Abschnitt: Claim-State-Changes nutzen Activity-Type #64, Scraper-Detection bleibt draussen
- `wiki/concepts/status-enum-katalog.md` — Presentation-Type auf neue 3 Codes konsolidiert (verbal_phone/verbal_teams entfernt)
- `specs/ARK_ACCOUNT_DETAILMASKE_INTERACTIONS_v0_3.md`, `specs/ARK_MANDAT_DETAILMASKE_INTERACTIONS_v0_3.md` — Presentation-Type-Enum angepasst
- `mockups/accounts.html` — Tab 10 (Placement gold, Stale rot, Erfolgsbasis-Prozesse, Quellen-Dropdown mit optgroup), Tab 11 History (neu aufgebaut, Claim-Eröffnung statt Scraper-Verletzung, Activity-Type #64 referenziert)

**Begründung:** Claim-Workflow braucht History-Spur für Audit-Trail, aber ohne Mitarbeiter-Klick-Burden — deshalb 1 generischer auto-log-Typ statt 8 manueller. Scraper-Detection selbst ist kein History-Eintrag, sondern Scraper-Audit.

## [2026-04-14] update | Kandidaten-Spec v1.3 — Integration aller neuen Detailseiten

**Neu erstellt:**
- `specs/ARK_KANDIDATENMASKE_SCHEMA_v1_3.md` (~870 Zeilen, +144 vs v1.2)
- `specs/ARK_KANDIDATENMASKE_INTERACTIONS_v1_3.md` (~1050 Zeilen, +123 vs v1.2)

**Archiviert:** v1.2 beide nach `/specs/alt/`

**9 Änderungsbereiche v1.2 → v1.3:**
1. Tab 2 Briefing: Projekt-Autocomplete (Hybrid-Flow ≥85%/60-84%/<60%)
2. Tab 3 Werdegang: Projekt-FK + Inline-Drawer für BKP/SIA/Rolle
3. Tab 4 Assessment: Versionierung via `fact_candidate_assessment_version` + Link zur Assessment-Detailseite
4. Tab 5 Jobbasket: Schutzfrist-Awareness-Badge (account + group Scope Query)
5. Tab 6 Prozesse: Slide-in-Drawer 540px (Mischform-Konsistenz)
6. Tab 7 History: Neue Filter-Kategorien (Schutzfrist-Events, Assessment-Events, Referral-Events, Projekt-Events)
7. Tab 8 Dokumente: Scraper-Source-Flag 🕸
8. Tab 10 Reminders: Assessment-Coaching/Debriefing + Schutzfrist-Info-Request-Tracking
9. Sprachstandard `candidate_id` konsistent

**Datenmodell-Ergänzung:**
- `fact_candidate_werdegang.project_id FK → fact_projects` NULL (Verknüpfung zu Projekt-Entity)
- Assessment-Detail-Tabellen (DISC, EQ, etc.): `version_id FK → fact_candidate_assessment_version` NOT NULL ab v1.3

**Aktualisiert:**
- `wiki/sources/kandidatenmaske-schema.md` — v1.3
- `wiki/sources/kandidatenmaske-interactions.md` — v1.3
- `wiki/meta/detailseiten-inventar.md` — Kandidaten v1.3

---

## [2026-04-14] create | Frontend v1.10 + Gesamtsystem v1.3 (P1 Schritt 6+7) — P1 KOMPLETT

### Frontend-Architecture v1.10

**Neu erstellt:** `raw/Ark_CRM_v2/ARK_FRONTEND_FREEZE_v1_10.md`

**Hauptänderungen:**
- Route-Standardisierung auf Englisch (inkl. `/company-groups`, `/projects`, `/assessments`)
- **Account-Tabs 10 → 13 + 1 konditional** (+Tab 8 Assessments, +Tab 9 Schutzfristen, +Tab 13 Reminders, Tabs 10-12 verschoben)
- **Prozess-Mischform** klargestellt (Drawer-Primary + schlanke 3-Tab-Detailseite)
- **5 neue Detailseiten-Kapitel** (4d.4 Jobs, 4d.5 Firmengruppen, 4d.6 Assessments mit typisierten Credits, 4d.7 Projekte mit 3-Tier BKP/SIA, 4d.8 Scraper-Control-Center)
- 4 neue Listen-Module (`/assessments`, `/company-groups`, `/projects`, `/scraper`)
- Status-Enum-Sprache intentional gemischt dokumentiert
- Keyboard-Shortcuts-Ergänzungen (ohne Konflikte mit v1.9)
- Design-System unverändert (Tokens, Patterns, CSS-Prefix aus v1.9)

### Gesamtsystem-Übersicht v1.3

**Neu erstellt:** `raw/Ark_CRM_v2/ARK_GESAMTSYSTEM_UEBERSICHT_v1_3.md`

**11 Änderungsbereiche:** Mandatsarten umbenannt, Prozess-Mischform, Firmengruppen vollwertig, Assessments Credits-Modell, Scraper Control-Center, Projekte 3-Tier, Schutzfrist-System, Mandats-Kündigung Exit Option, Sprachstandard, Detailseiten-Inventar, Referenz-Updates.

**Aktualisiert:**
- `wiki/sources/frontend-freeze.md` — zeigt v1.10
- `wiki/sources/gesamtsystem-uebersicht.md` — zeigt v1.3

---

## 🎯 MEILENSTEIN: P1 komplett abgeschlossen (14.04.2026)

Alle 7 Infrastructure-Dokumente nach Komplett-Audit aktualisiert:

| # | Dokument | Version | Änderung |
|---|----------|---------|----------|
| 1 | Stammdaten-Export | v1.3 | +15 dim_* Tabellen, +20 Settings-Keys |
| 2 | Projekt-Schema | v0.2 | Bridge-Tabellen + SIA 6+12 + Generated Column |
| 3 | Status-Enum-Katalog | Wiki-Konzept neu | 17 Enum-Bereiche dokumentiert |
| 4 | Database-Schema | v1.3 | 28 neue Tabellen, 30+ Feld-Erweiterungen, 14 Widersprüche gelöst, 3 neue Views |
| 5 | Backend-Architecture | v2.5 | 30+ Events, 18 Worker, 46 Endpunkte, 8 atomare Sagas, WebSocket, Rate-Limiting |
| 6 | Frontend-Freeze | v1.10 | 5 neue Detailseiten-Kapitel, Account-Tabs 10→13, Prozess-Mischform, Route-Standardisierung |
| 7 | Gesamtsystem-Übersicht | v1.3 | 11 Änderungsbereiche konsolidiert |

**Alle 18 Detailseiten-Specs + 7 Infrastructure-Dokumente + 15 Wiki-Konzepte sind jetzt konsistent.**

---

## [2026-04-14] create | Backend-Architecture v2.5 (P1 Schritt 5)

**Neu erstellt:** `raw/Ark_CRM_v2/ARK_BACKEND_ARCHITECTURE_v2_5.md`
**Methodik:** v2.4 als Referenz erhalten, umfassende Konsolidierungs-Sektion vorangestellt.

**Konsolidiert:**
- **30+ neue Event-Typen** (Mandat 9, Schutzfrist 7, Assessment 13, Prozess 11, Job 8, Scraper 12, Firmengruppe 6, Projekt 8)
- **18 neue Worker** (7 Nightly-Batch, 6 Event-getrieben, 3 Scraper, 2 System)
- **46 neue REST-Endpunkte** (2 Mandat, 13 Prozess, 11 Assessment, 3 Account-Schutzfrist, 2 Firmengruppe, 14 Scraper, 1 Kandidat)
- **8 atomare Sagas** (Placement 8-Step, Assessment-Report-Upload 4-Step, Mandat-Kündigung 6-Step, Scraper-Finding-Accept, Gruppen-Mandat-Create, Gruppen-Member-Add Batch, Bulk-Reject-by-Mandate-Termination, Early-Exit+Refund)
- **WebSocket-Infrastruktur** (WSS-Endpoint + Topic-Subscriptions, In-Memory → Redis Phase 2, Latenz-Ziele <2s Scraper, <1s Assessment)
- **Scraper-Rate-Limiting** (Token-Bucket pro scraper_type+domain + Concurrent-Limit + Soft/Hard-Alerts)
- **Event-Scope-Registry** für Multi-Entity-Events (placed → 5 Entities)
- **12+ neue Setting-Keys** in `dim_automation_settings`

**Priority-Roadmap:**
- P0 (3-4 Wochen parallel): 10 P0-Events + 7 Workers + 24 Endpunkte + 8 TXs + WebSocket + Rate-Limiting
- P1 (1-2 Wochen): 14 Events + 10 Workers + 18 Endpunkte + Event-Scope-Registry + Admin-UI
- P2 (Phase 1.5): Auto-Accept-Thresholds, Prompt-Tuning, Kalender-Sync, Stammdaten-Drift

**Aktualisiert:**
- `wiki/sources/backend-architecture.md` — zeigt v2.5

**P1 Fortschritt:** 5/7 Schritte fertig (nur noch Frontend v1.10 + Gesamtsystem v1.3 offen).

---

## [2026-04-14] create | Status-Enum-Katalog + DB-Schema v1.3 (P1 Schritt 3+4)

### Status-Enum-Katalog (Wiki-Konzept)

**Neu erstellt:** `wiki/concepts/status-enum-katalog.md`
Zentrale Referenz aller Status/Stage/Typ-Enums im ARK CRM mit der intentional gemischten Sprachkonvention (Entscheidung 2026-04-14 #2).

**17 Enum-Bereiche dokumentiert:** Mandat, Prozess, Job, Assessment, Projekt, Kandidat, Account, Firmengruppe, Schutzfrist, Scraper, Longlist, Jobbasket, Referral, Mandat-Optionen, Rechnung, gemeinsame Konventionen, Felder-Konventionen.

### DB-Schema v1.3

**Neu erstellt:** `raw/Ark_CRM_v2/ARK_DATABASE_SCHEMA_v1_3.md`
**Methodik:** v1.2 als Referenz unverändert übernommen, neuer Header mit Konsolidierung aller Audit-Erkenntnisse.

**28 neue Fact-/Bridge-Tabellen:**
- Mandat-Lifecycle (4): fact_mandate_option, fact_candidate_presentation, fact_protection_window, fact_referral
- Assessment-Modul (5): fact_assessment_order, fact_assessment_order_credits, fact_assessment_run, fact_assessment_billing, fact_candidate_assessment_version
- Prozess + Matching (2): fact_process_interviews, fact_candidate_matches
- Firmengruppen (2): dim_firmengruppen, bridge_mandate_accounts
- Scraper (6): fact_scraper_schedule + fact_scraper_runs + fact_scraper_findings + fact_scraper_alerts + dim_scraper_types + dim_scraper_global_settings
- Projekte (9): fact_projects, fact_project_bkp_gewerke, fact_project_company_participations, fact_project_candidate_participations, fact_project_media, fact_account_project_notes, bridge_project_clusters, bridge_project_spartens, fact_project_similarities

**15 neue dim_* Stammdaten:** siehe Stammdaten v1.3 Sektionen 51-65.

**30+ Feld-Erweiterungen** in bestehenden Tabellen (fact_mandate +10, fact_jobs +29, fact_process_core +4, dim_accounts +3, dim_automation_settings +20 Keys, etc.).

**14 aufgelöste Widersprüche** dokumentiert (Sprachstandard, ONE-OF-Constraints, Polymorphe FK, Volume-Range Generated Column, Bridge-Tabellen, typisierte Credits, ...).

**3 neue Views:** v_protection_window_claims, v_assessment_credits_account_summary, v_assessment_credits_order_summary.

**Migrations-Roadmap:** 3 Waves (P0 parallel 6-8 Wochen, Wave 2 abhängig 4-6 Wochen, Wave 3 Polish 2 Wochen).

**Aktualisiert:**
- `wiki/sources/database-schema.md` — zeigt v1.3
- `index.md` — Status-Enum-Katalog unter Concepts

**P1 Fortschritt:** 4/5 Schritte fertig (nur noch Backend v2.5 + Frontend v1.10 + Gesamtsystem v1.3 offen).

---

## [2026-04-14] update | Projekt-Schema v0.2 (P1 Schritt 2)

**Neu erstellt:** `specs/ARK_PROJEKT_DETAILMASKE_SCHEMA_v0_2.md`
**Archiviert:** v0.1 nach `/specs/alt/`

**Änderungen v0.1 → v0.2:**
1. **Bridge-Tabellen statt JSONB** — `bridge_project_clusters(project_id, cluster_id, is_primary)` + `bridge_project_spartens` (Entscheidung #13). Bessere Query-Performance + FK-Integrität.
2. **SIA 6+12 hierarchisch** via neue `dim_sia_phases` aus Stammdaten v1.3. Multi-Select primär Haupt-Phasen, optional Drilldown Teilphasen (Entscheidung #3).
3. **`volume_range` als Generated Column STORED** aus `volume_chf_exact`. Fallback-Feld `volume_range_manual` wenn `volume_chf_exact` NULL (Entscheidung #12).
4. **Route `/projects/[id]`** (bereits in Bulk-Replace erfolgt).
5. **Sprachstandard `candidate_id`** bestätigt.
6. DB-Referenz-Sektion erweitert um Stammdaten-Referenzen (dim_clusters, dim_sparte, dim_sia_phases, dim_bkp_codes).

**Projekt-Interactions v0.1 bleibt unverändert** (keine Flow-Änderungen, nur Datenmodell-Refactor).

**Aktualisiert:**
- `wiki/sources/projekt-schema.md` — v0.2
- `wiki/meta/detailseiten-inventar.md` — Schema v0.2

**P1 Fortschritt:** 2/5 Schritte fertig.

---

## [2026-04-14] create | Stammdaten-Export v1.3 (P1 Schritt 1)

**Neu erstellt:** `raw/Ark_CRM_v2/ARK_STAMMDATEN_EXPORT_v1_3.md` (2368 Zeilen, +395 vs. v1.2)
**Methodik:** v1.2 als TEIL A unverändert übernommen, 16 neue Sektionen als TEIL B ergänzt.

**15 neue dim_*-Tabellen (Sektionen 51–65):**
- P0: dim_assessment_types (11 Typen: MDI/Relief/Outmatch/DISC/EQ/Scheelen 6HM/Driving Forces/Human Needs/Ikigai/AI-Analyse/Teamrad)
- P0: dim_rejection_reasons_internal (11 Gründe), dim_honorar_settings (21-27% Staffel, +2027 Ausblick), dim_culture_dimensions (6 Dim.), dim_sia_phases (6+12 hierarchisch)
- P0: dim_dropped_reasons (6), dim_cancellation_reasons (9), dim_offer_refused_reasons (10)
- P1: dim_vacancy_rejection_reasons (8), dim_scraper_types (7), dim_scraper_global_settings (14 Keys), dim_matching_weights (7), dim_matching_weights_project (6)
- P2: dim_reminder_templates (10), dim_time_packages (3)

**Sektion 66:** Erweiterungen `dim_automation_settings` (~20 neue Keys für Stale-Detection, Temperature-Schwellen, Schutzfrist, Billing-Batch-Hours, Referral, Matching).

**Konventionen v1.3 bestätigt:**
- `candidate_id` englisch (nicht `kandidat_id`)
- Routen englisch (inkl. `/company-groups`, `/projects`)
- Status-Enum-Sprache gemischt intentional (Mandat+Job deutsch, Prozess+Assessment englisch)
- Nur `fact_jobs`, kein `dim_jobs`
- SIA 6+12 hierarchisch

**Kreuzreferenz-Anhang:** Welche Stammdaten von welchen Detailseiten-Specs verwendet werden.

**Aktualisiert:** `wiki/sources/stammdaten-export.md` — zeigt v1.3, vollständige Änderungs-Liste.

**P1 Fortschritt:** 1/5 Schritte fertig.

---

## [2026-04-14] update | Route-Updates auf Englisch (Entscheidung #1) — P0 ABGESCHLOSSEN

**Route-Umbenennungen durchgeführt:**
- `/firmengruppen/[id]` → `/company-groups/[id]`
- `/projekte/[id]` → `/projects/[id]`

**Betroffen:**
- `ARK_FIRMENGRUPPE_DETAILMASKE_SCHEMA_v0_1.md` + Interactions v0.1
- `ARK_PROJEKT_DETAILMASKE_SCHEMA_v0_1.md` + Interactions v0.1
- `wiki/meta/detailseiten-inventar.md`
- `wiki/analyses/audit-2026-04-13-komplett.md`
- `wiki/sources/firmengruppe-schema.md` + `-interactions.md`
- `wiki/sources/projekt-schema.md` + `-interactions.md`

**Alle anderen Routen bleiben (bereits englisch):** `/candidates`, `/accounts`, `/mandates`, `/jobs`, `/processes`, `/assessments`, `/scraper`.

---

## 🎯 MEILENSTEIN: Alle 5 P0-Aufgaben der Audit-Nachbearbeitung abgeschlossen (14.04.2026)

1. ✅ Assessment Schema + Interactions v0.2 — Typisierte Credits (MDI/Relief/Outmatch/DISC/EQ/...)
2. ✅ Mandat-Interactions v0.3 — Kündigungs-Flow + Longlist-Lock + 3-Fälle-Claim-Logik
3. ✅ Account-Interactions v0.3 — Gruppen-Schutzfrist-Scope + AM-Claim + Credits-Typen-Übersicht
4. ✅ Scraper-Spec Update — Review-Priority (<60% markieren statt verwerfen)
5. ✅ Route-Updates — Firmengruppen + Projekte auf Englisch

**Offen (P1):**
- Projekt-Spec v0.2 (SIA 6+12 hierarchisch, Generated Column volume_range, Bridge-Tabellen)
- Stammdaten-Export v1.3 (12+ fehlende dim_*-Tabellen)
- Gesamtsystem v1.3 (Mandats-Typen-Umbenennung, Prozess-Mischform)
- Status-Enum-Katalog Wiki
- DB-Schema v1.3 mit allen neuen Tabellen (26 P0)
- Backend v2.5 mit Events/Workers/Endpunkten
- Frontend Freeze v1.10

---

## [2026-04-14] update | Scraper-Spec Review-Priority (Entscheidung #9)

**Peter-Klarstellung 14.04.:** Low-Confidence-Findings (< 60%) werden NICHT auto-verworfen, sondern markiert für AM-Kontrolle.

**Änderungen:**
- `specs/ARK_SCRAPER_MODUL_SCHEMA_v0_1.md`:
  - Confidence-Token-Tabelle: Schwellen auf ≥85% / 60-84% / <60% aktualisiert
  - `fact_scraper_findings.review_priority ENUM('standard','needs_am_review')` Feld hinzugefügt
  - Low-Confidence-Card mit amber Warning-Bar beschrieben
  - Filter "Review-Priority" neu in Review-Queue-Filter-Bar
- `specs/ARK_SCRAPER_MODUL_INTERACTIONS_v0_1.md`:
  - Review-Priority-Assignment-Logik beim Finding-Insert
  - Klarstellung: Kein Auto-Reject, alle Findings landen in Queue
  - Firmengruppen-UID-Matching-Schwellen explizit
  - Neues Event `finding_marked_low_confidence`

---

## [2026-04-14] refine | Claim-Billing-Logik präzisiert (3 Fälle X/Y/Z)

**Peter-Klarstellung zur Claim-Billing-Logik:**
Das ursprüngliche "Mandats-Kontext" vs. "Erfolgsbasis-Kontext"-Modell war zu simpel. Korrekte Drei-Fälle-Logik:

- **Fall X (Mandats-Position identisch):** Mandat-Ursprung + Kandidat für die **definierte Mandats-Position** eingestellt → **Rest-Mandatssumme** fällig (Gesamt − bezahlte Stages). Mandat gilt als komplett gedeckt.
- **Fall Y (Andere Position, gleiche Firma/Gruppe):** Mandat-Ursprung + Kandidat für **andere Position** eingestellt (auch bei gleicher Firma oder Schwester in Firmengruppe) → **Erfolgsbasis-Staffel** auf neuen Jahreslohn. Mandat gilt nur für die definierte Position.
- **Fall Z (Erfolgsbasis-Ursprung):** Erfolgsbasis-Prozess, keine Mandat-Historie → Erfolgsbasis-Staffel.

**Rechnungs-Empfänger:** **Immer die einstellende Firma** (nicht Holding), auch bei Gruppen-Schutzfrist.

**Position-Match-Detection:** AI-basierter Fuzzy-Match (Job-Title + Function + BKP-Gewerk) im Position-Check-Drawer, AM bestätigt/overriden.

**Aktualisiert:**
- `specs/ARK_MANDAT_DETAILMASKE_INTERACTIONS_v0_3.md` TEIL 10 Claim-Billing-Logik
- `specs/ARK_ACCOUNT_DETAILMASKE_INTERACTIONS_v0_3.md` TEIL 8c Claim-Flow mit Position-Check-Drawer
- Event `claim_context_determined` mit `context_case` ∈ {X, Y, Z}

---

## [2026-04-14] update | Account-Interactions v0.3 — Gruppen-Schutzfrist + AM-Claim + Credits-Typen

**Neu erstellt:** `specs/ARK_ACCOUNT_DETAILMASKE_INTERACTIONS_v0_3.md`
**Archiviert:** v0.2 nach `/specs/alt/`

**Änderungen v0.2 → v0.3:**
- **TEIL 8c Tab 9 Schutzfristen:**
  - Gruppen-Scope-Einträge sichtbar mit Badge "🏛 Gruppen-Schutzfrist" (behebt P0.2-Audit-Gap)
  - Info-Panel über Tabelle bei Accounts in Firmengruppe
  - Neuer Filter "Scope" (Alle / Account-Level / Gruppen-Level)
  - DB-Schema `fact_protection_window` mit `scope` ENUM + `group_id` + CHECK-Constraint
- **Claim-Flow aktualisiert:**
  - AM alleine (kein Admin-Gate, Entscheidung #5)
  - Kontextabhängige Billing-Logik: auto Mandats-Konditionen vs. Erfolgsbasis-Staffel
  - Zwei separate Rechnungs-Templates (zu erstellen)
  - Scope-Kontext: Gruppen-Schutzfrist-Claim geht an ursprünglichen Account (nicht Holding)
- **TEIL 8b Tab 8 Assessments (Credits-Typen-Update):**
  - Top-Banner mit aggregierter Credits-Übersicht pro Typ (MDI/Relief/Outmatch/DISC/...)
  - Auftragsdrawer: Multi-Row-Editor mit Typ + Quantity + Einzelpreis
  - Neue Spalte "Credits-Mix" in Tabelle
  - Filter Multi-Select "Typ"
- **TEIL-Nummerierung:** 8/8b/8c → 8a/8b/8c
- **Firmengruppe-Route:** `/company-groups/[id]` (englisch)
- Sprachstandard: `candidate_id`

**Aktualisiert:**
- `wiki/sources/account-interactions.md` — v0.3 + Highlights
- `wiki/meta/detailseiten-inventar.md` — Interactions v0.3

---

## [2026-04-14] update | Mandat-Interactions v0.3 — Kündigungs-Flow + Longlist-Lock

**Neu erstellt:** `specs/ARK_MANDAT_DETAILMASKE_INTERACTIONS_v0_3.md`
**Archiviert:** v0.2 nach `/specs/alt/`
**Global replace:** "Admin-Override" → "Admin-/Admin-Override" über alle Specs (Peter-Klarstellung)

**Änderungen v0.2 → v0.3:**
- **TEIL 9 Kündigungs-Flow vollständig ausgearbeitet:**
  - Atomare Transaktion (6 Steps: Mandat-Status + Rechnungsbetrag + Billing-Insert + PDF-Async + Schutzfrist + Events)
  - Exklusivität endet sofort mit Kündigung
  - AM-alleine (kein Admin-Gate, Entscheidung #4)
- **TEIL 3 Longlist: `is_longlist_locked` Feld** mit Sticky Banner, Durchcall disabled, Kanban read-mostly
- **Offene Prozesse schliessbar** trotz Lock: Bulk-Action "Alle als Rejected markieren" (via `rejected_by='internal'` + `dim_rejection_reasons_internal`), einzelne Status-Wechsel erlaubt. `Dropped` nur für nie-gestartete Prozesse.
- **Placement trotz Kündigung möglich** (Stage Angebot → Placement triggert Fall B mit Billing-Korrektur)
- **TEIL 10 Schutzfrist-Scope:** Nur konkret vorgestellte Kandidaten (Entscheidung #14), keine Longlist-Idents
- **Schutzfrist-Gruppen-Integration:** `scope` Enum + `group_id` + CHECK-Constraint
- **Claim-Billing-Kontext-Logik (Entscheidung #7):** Mandats-Stage-3 bei Target, Staffel bei Erfolgsbasis
- Sprachstandard: `candidate_id` statt `kandidat_id` im Datenmodell

**Event-Trigger bei Kündigung:**
- `mandate_terminated` (Mandat + Account)
- `termination_invoice_generated` (Mandat + Account)
- `protection_window_opened` (pro vorgestellter Kandidat)
- `process_rejected_due_to_mandate_termination` (pro bulk-geschlossenem Prozess)

**Aktualisiert:**
- `wiki/sources/mandat-interactions.md` — v0.3 + Highlights
- `wiki/meta/detailseiten-inventar.md` — Interactions v0.3

---

## [2026-04-14] update | Assessment Schema + Interactions v0.2 — Typisierte Credits

**Neu erstellt:**
- `specs/ARK_ASSESSMENT_DETAILMASKE_SCHEMA_v0_2.md` (~570 Zeilen)
- `specs/ARK_ASSESSMENT_DETAILMASKE_INTERACTIONS_v0_2.md` (~440 Zeilen)

**Archiviert:** v0.1 beide in `/specs/alt/`

**Fundamentale Datenmodell-Änderung:**
- Credits sind nun **typisiert** (MDI/Relief/Outmatch/DISC/EQ/Scheelen 6HM/Driving Forces/Human Needs/Ikigai/AI-Analyse/Teamrad)
- Neue Bridge `fact_assessment_order_credits(order_id, type_id, quantity, used_count)`
- `fact_assessment_run.assessment_type_id` FK
- `fact_candidate_assessment_version` als zentrale Versionierungs-Tabelle (Entscheidung #11)
- Neue Stammdaten `dim_assessment_types`

**UI-Änderungen:**
- Snapshot-Bar 5 → 7 Slots (Credits-Mix + Package-Name + Bestell-Datum)
- Tab 1 Credits wird Tabelle pro Typ (statt Einzel-Felder)
- Tab 2 Durchführungen: neue Spalte "Typ" + Filter
- Zuweisungs-Drawer: Typ-Pflichtfeld (Dropdown nur mit freien Credits pro Typ)
- Umwidmung: nur **innerhalb gleichen Typs**
- Report-Upload: Typ ist aus Run fest (kein Multi-Select mehr)

**Neuer Event:** `order_credits_rebalanced_by_admin` (für Admin-Override-Typumbuchung)

**Aktualisiert:**
- `wiki/sources/assessment-schema.md` + `assessment-interactions.md` (v0.2)
- `wiki/meta/detailseiten-inventar.md` — Assessment v0.2

---

## [2026-04-14] decisions | 14 Klärungs-Fragen beantwortet + Gesamtsystem-Audit

**Gesamtsystem v1.2 zusätzlich auditiert** — 7 neue Findings:
- G1 (P0): Mandats-Typen-Naming — Gesamtsystem v1.2 nutzt noch `Einzelmandat/RPO/Time`, Specs `Target/Taskforce/Time`
- G2: Status-Enum-Sprache-Mischung ist intentional bestätigt
- G3 (P1): Prozess-Architektur "Vollseite" vs. Mischform-Entscheidung — Widerspruch
- G4 (P1): "Gruppen-Manager"-Feld im Gesamtsystem vs. FG-5 (kein eigener Group-AM)
- G5 (P2): Mandate-Report-Generator Phase-Einstufung unklar
- G6 (P1): Scheelen-CSV-Import vs. Report-Upload Abgrenzung
- G7: event-chain Endpoint bereits dokumentiert

**14 Klärungs-Fragen beantwortet** (siehe `audit-entscheidungen-2026-04-14.md`):
1. Route-Sprache → Englisch durchziehen (`/company-groups`, `/projects`)
2. Status-Enum → Mischung behalten
3. SIA-Phasen → 6 + 12 hierarchisch
4. Mandat-Kündigung → AM alleine (ohne Admin-Gate)
5. Claim stellen → AM alleine
6. Nur `fact_jobs`
7. Claim-Billing → kontextabhängig (Mandat vs. Erfolgsbasis)
8. Longlist-Locking ja + **offene Prozesse müssen schliessbar sein**
9. Scraper-UID: ≥85% auto, 60-84% review, **<60% markieren (nicht verwerfen)**
10. **Credits-Modell FUNDAMENTAL GEÄNDERT:** Typisierte Credits (MDI/Relief/Outmatch/...) via Bridge `fact_assessment_order_credits`, neue `dim_assessment_types`
11. Neue Tabelle `fact_candidate_assessment_version`
12. volume_chf_exact + volume_range als Generated Column
13. `bridge_project_clusters` + `bridge_project_spartens`
14. Schutzfrist nur vorgestellte Kandidaten

**Prioritäten-Update für Specs-Nachbearbeitung:**
- P0: Assessment v0.2 (Credits-Typen-Umbau), Mandat v0.3, Account v0.3, Scraper-Updates, Route-Rename
- P1: Projekt v0.2, Stammdaten v1.3, Gesamtsystem v1.3
- P2: Status-Enum-Katalog Wiki, Mockups etc.

---

## [2026-04-13] audit | Komplett-Audit aller 5 Grundlagen + 18 Specs

**Scope:** 22'700 Zeilen (DB v1.2, Backend v2.4, Frontend Freeze v1.9, Stammdaten v1.2, Gesamtsystem v1.2 + alle 18 Detailseiten-Specs)

**Methodik:** 6 parallele Agenten-Audits + manuelle Synthese

**Neues Dokument:** `wiki/analyses/audit-2026-04-13-komplett.md` (~800 Zeilen)

**Gesamtbefund:**
- **27 P0-Punkte** (Blocker für Implementierung)
- **42 P1-Punkte** (Wichtig)
- **28 P2-Punkte** (Phase 1.5+)
- **14 Klärungs-Fragen** an Peter

**Kritische Funde:**

1. **DB v1.2 ist unvollständig** — 53 neue Tabellen (26 P0) + 30+ Feld-Erweiterungen nötig
2. **Backend v2.4 unvollständig** — 30 Events, 18 Worker, 46 Endpunkte fehlen
3. **Frontend Freeze v1.9 veraltet** — 5 komplette Detailseiten fehlen (Jobs, Firmengruppen, Assessments, Projekte, Scraper), Account-Tab 10→13, Prozess-Architektur-Widerspruch
4. **Stammdaten v1.2 unvollständig** — 12 dim_*-Tabellen fehlen, SIA-Phasen-Widerspruch (6 vs 11 vs 18)
5. **Cross-Spec:** Status-Enum-Sprachmix (DE/EN), TEIL-Nummerierung, Schutzfrist-Gruppen-Scope nicht durchgezogen
6. **E2E-Workflows:** 8 atomare Transaktionen ohne Rollback-Semantik, Claim-Billing-Template fehlt, Presentation-Insert-Timing ambiguitär

**Roadmap zur Implementierungs-Readiness:** 6-8 Wochen parallele Spec-Arbeit, dann 10-12 Wochen Implementierung.

---

## [2026-04-13] create | Projekt Schema + Interactions v0.1 (P2 Schritt 3) — ALLE 9 DETAILSEITEN FERTIG

**15 Klärungsfragen beantwortet** + Follow-up zu Projekt-Typ-Klassifikation:
- Primäre Use Cases: Matching-Basis + Marktkenntnis (PR-1 A+D)
- Drei Erstellungs-Wege: manuell, Kandidat-Werdegang, Scraper (alle Quellen Phase 1)
- 3-Tier-Struktur bestätigt (Projekt → Gewerk → Beteiligungen breit+tief)
- 6 Tabs (nach Iteration): Übersicht / Gewerke / Matching / Galerie / Dokumente / History
- **Klassifikation über bestehende Cluster** (keine neue Typen-Tabelle, vermeidet Verwirrung)
- Beteiligte Firmen + Kandidaten gehen in BKP-Zuteilung (nicht separater Tab)
- Foto-Galerie als eigener Tab (breit+tief Anspruch)
- Matching-Tab: passende Kandidaten + ähnliche Projekte
- AM-Notizen pro Account-Kontext (via `fact_account_project_notes` Bridge)
- Öffentlich/Intern-Trennung in Übersicht
- Werdegang-Integration: Hybrid-Autocomplete bei Briefing
- Duplikat-Erkennung: String + AI + Manual (alle Methoden)

**Neu erstellt:**
- `specs/ARK_PROJEKT_DETAILMASKE_SCHEMA_v0_1.md` (~530 Zeilen)
- `specs/ARK_PROJEKT_DETAILMASKE_INTERACTIONS_v0_1.md` (~385 Zeilen)

**Neue DB-Tabellen (7):**
- `fact_projects`, `fact_project_bkp_gewerke`, `fact_project_company_participations`, `fact_project_candidate_participations`, `fact_project_media`, `fact_account_project_notes`, `fact_project_similarities`

**Kritische Features:**
- Akkordeon-Gewerke-Tab mit Inline-Firmen-/Kandidaten-Beteiligungen pro BKP-Code
- Matching gegen Projekt-Erfahrung (Cluster + BKP + SIA + Volumen + Geografie + Recency)
- Werdegang-/Briefing-Autocomplete mit Confidence-Schwellen
- Duplikat-Merge-Flow mit Kollisions-Handling
- Foto-Galerie mit Privacy-Flag + Copyright-Info
- Öffentlich/Intern-Sektionen in Übersicht

**Nachbearbeitungs-Items ergänzt:**
- Account-Schema v0.2: neuer Tab "Projekte" (Rolle-gefiltert)
- Kandidatenmaske v1.3: Werdegang/Briefing Projekt-Autocomplete-Integration
- Mandat/Job v0.2: optionales `linked_project_id`

**Aktualisiert:**
- `wiki/sources/projekt-schema.md` + `projekt-interactions.md` (neu)
- `wiki/meta/detailseiten-inventar.md` — Projekte ✅ + Gesamt-Status-Sektion
- `wiki/meta/detailseiten-nachbearbeitung.md` — 3 neue Nachbearbeitungs-Items
- `index.md` — Sources auf 40

---

## 🎯 MEILENSTEIN: Alle 9 Detailseiten v0.1 Erstentwurf fertig (13.04.2026)

**Kandidaten (v1.2), Accounts (v0.1/v0.2), Mandate (v0.1/v0.2), Prozesse (v0.1), Assessments (v0.1), Jobs (v0.1), Firmengruppen (v0.1), Scraper (v0.1), Projekte (v0.1).**

~50 neue DB-Tabellen/Felder über alle Specs. ~12 Nachbearbeitungs-Items für finale Integrations-Runde.

---

## [2026-04-13] create | Scraper-Modul Schema + Interactions v0.1 (P2 Schritt 2)

**15 Klärungsfragen beantwortet** — Scraper als strategisches Marktbeobachtungs-Tool mit Near-Live-Reactions:
1. Global Dashboard + Run-Detail + Config-Registry (alles drei)
2. 7 Scraper-Typen Phase 1 (LinkedIn Phase 2 wegen Komplexität)
3. Scheduling: Priority-basiert (temperature_factor + class_factor)
4. UI: Vollseite mit 6 Tabs
5. Retry: exp. backoff + N-Strike-Disable
6. AI: Extraktion + Klassifizierung
7. Output: Staging-Area mit Review (kein direkter Live-Write)
8. Trigger: Admin + AM + Priorisierungs-Queue
9. Retention: nur Diff + Metadata dauerhaft
10. Implementation: Hybrid generisch + spezialisiert
11. Cross-Entity: alle 5 Integrations (Kontakt, Vakanz, Schutzfrist, Gruppe, Stammdaten)
12. Kosten: erstmal ohne Framework
13. Data Quality: Review-Queue mit Confidence
14. Alerts: alle Typen (Fehler, Findings, Schutzfrist, Anomalien)
15. Stammdaten-Check: ja

**Neu erstellt:**
- `specs/ARK_SCRAPER_MODUL_SCHEMA_v0_1.md` (~530 Zeilen)
- `specs/ARK_SCRAPER_MODUL_INTERACTIONS_v0_1.md` (~420 Zeilen)

**6 Tabs:** Dashboard / Review-Queue / Runs / Configs / Alerts & Fehler / History

**Neue DB-Tabellen:** `dim_scraper_types`, `dim_scraper_global_settings`, `fact_scraper_schedule`, `fact_scraper_runs`, `fact_scraper_findings`, `fact_scraper_alerts`

**Kritische Features:**
- Staging-Review-Flow mit 10 Finding-Typen
- Confidence-Score + Bulk-Accept-Schwelle
- Priority-Scheduling (Temperature × Customer Class)
- N-Strike-Disable + Auto-Retry mit Exponential Backoff
- AI-Extraktion mit Prompts in Config + Versionierung
- 5 Cross-Entity-Flows dokumentiert inkl. Schutzfrist-Claim-Trigger (Critical Alert)
- Anomalie-Radar (Fluktuation, Vakanz-Spike, Dienstleister-Detection)

**Aktualisiert:**
- `wiki/sources/scraper-schema.md` + `scraper-interactions.md` (neu)
- `wiki/meta/detailseiten-inventar.md` — Scraper ✅
- `index.md` — Sources auf 38

---

## [2026-04-13] create | Firmengruppe Schema + Interactions v0.1 (P2 Schritt 1)

**14 Klärungsfragen beantwortet:**
1. Hierarchie: 2-stufig flach (keine Sub-Gruppen)
2. Tabs: 6 (4+2 wegen Kontakte/Kultur/Dokumente eigene Tabs)
3. Holding mit eigenen Stammdaten + gruppenübergreifende Taskforces möglich
4. Erstellung: Scraper-Vorschlag (UID-Match) + AM-Bestätigung
5. Kein eigener Group-AM, Admin-Level für Gruppen-Aktionen
6. Kontakte aggregiert in eigenem Tab mit Gesellschaft-Spalte
7. Eigene Kultur-Analyse auf Holding-Ebene (AI-Hybrid)
8. Kein Teamrad auf Gruppen-Ebene
9. Gruppen-Dokumente mit Subset-Gültigkeit
10. **Schutzfrist gruppenweit** (FG-10 KRITISCH, AGB-konform)
11. Mandate N:N via `bridge_mandate_accounts`
12. History: Mix (Gruppen-Events + signifikante Account-Events)
13. Snapshot-Bar: Summen
14. Stammdaten-Set passt

**Neu erstellt:**
- `specs/ARK_FIRMENGRUPPE_DETAILMASKE_SCHEMA_v0_1.md` (~470 Zeilen)
- `specs/ARK_FIRMENGRUPPE_DETAILMASKE_INTERACTIONS_v0_1.md` (~345 Zeilen)

**Neue DB-Tabellen/Felder:**
- `dim_firmengruppen` (falls nicht existiert)
- `bridge_mandate_accounts` (N:N für gruppenübergreifende Mandate)
- `fact_mandate.group_id` (neu)
- `fact_protection_window.scope` + `group_id` (KRITISCH)
- `fact_account_culture_scores.target_type` + `group_id`

**Nachbearbeitungs-Eintrag kritisch:**
Account-Interactions v0.2 → v0.3 braucht Schutzfrist-Gruppen-Scope-Unterstützung (dokumentiert in `detailseiten-nachbearbeitung.md` als erster P0-Punkt).

**Aktualisiert:**
- `wiki/sources/firmengruppe-schema.md` + `firmengruppe-interactions.md` (neu)
- `wiki/meta/detailseiten-inventar.md` — Firmengruppen ✅
- `wiki/meta/detailseiten-nachbearbeitung.md` — Schutzfrist-Gruppen-Scope als P0
- `index.md` — Sources auf 36

---

## [2026-04-13] create | Job Schema v0.1 + Interactions v0.1 (P1 Schritt 3) — P1 abgeschlossen

**Entscheidungen:**
1. Volle Detailseite (nicht Mischform) — Job hat substanziellen eigenen Content
2. Jobbasket-Tab als Read-mostly Pipeline-Übersicht (operative Verwaltung in Kandidat Tab 5)
3. Matching als eigener Tab mit Score-basierter Sortierung
4. Stellenplan-Integration bidirektional (`fact_account_org_positions.linked_job_id`)

**Neu erstellt:**
- `specs/ARK_JOB_DETAILMASKE_SCHEMA_v0_1.md` (~445 Zeilen) — 6 Tabs, Lifecycle, ~30 neue DB-Felder
- `specs/ARK_JOB_DETAILMASKE_INTERACTIONS_v0_1.md` (~360 Zeilen) — Scraper-Proposal-Flow, Status-Pipeline, Matching-Recompute, 15 Events, 4 Erstellungs-Wege

**6 Tabs:** Übersicht / Jobbasket / Matching / Prozesse / Dokumente / History

**Kritische Features:**
- Scraper-Proposal-Confirmation Drawer
- Matching mit 7 Sub-Scores (Sparte/Function/Salary/Location/Skills/Availability/Experience), Radar-Chart-Slide-in, Bulk-Action "+ In Jobbasket"
- Async Matching-Recompute bei Kriterien-Änderung
- Stellenausschreibung-Generator (PDF, Mehrsprachig)
- Auto-Job-Fill bei Prozess-Placement → Stellenplan-Position aktualisiert
- Scraper detected `job_disappeared_from_source`

**Aktualisiert:**
- `wiki/sources/job-schema.md` (neu)
- `wiki/sources/job-interactions.md` (neu)
- `wiki/meta/detailseiten-inventar.md` — Jobs ✅
- `index.md` — Sources auf 34, 2 neue Einträge

**P1 abgeschlossen:**
- ✅ Assessments (mit Credits-Modell)
- ✅ Prozesse (Mischform)
- ✅ Jobs (volle Detailseite)

**Nächste Phase: P2** — Firmengruppen, Scraper, Projekte (3 verbleibende Detailseiten).

---

## [2026-04-13] create | Prozess Schema v0.1 + Interactions v0.1 (P1 Schritt 2)

**Entscheidung Mischform:** Nicht eine ausführliche Detailseite wie Mandat/Account, sondern **Pipeline-Modul `/processes` als Hauptarbeitsort (Liste + Filter + Slide-in-Drawer 540px) + schlanke Detailseite `/processes/[id]` mit nur 3 Tabs**. Deckt 80% Fälle über Drawer ab, 20% komplexe Fälle (Erfolgsbasis-Billing, Post-Placement) über Detailseite.

**Zusätzliche Klärungen (13.04.2026):**
- Stage = 1 Termin (1:1), keine n:1-Entity
- Honorar-Anzeige: Read-only Verweis bei Mandats-Prozessen, voller Tab bei Erfolgsbasis
- Stale-Schwellwerte pro Stage, admin-konfigurierbar (`dim_automation_settings.process_stale_thresholds`)
- TI = Telefon- oder Teams-Gespräch

**Neu erstellt:**
- `specs/ARK_PROZESS_DETAILMASKE_SCHEMA_v0_1.md` (~425 Zeilen) — 3 Tabs, Header mit Pipeline-Viz, RBAC-Matrix
- `specs/ARK_PROZESS_DETAILMASKE_INTERACTIONS_v0_1.md` (~375 Zeilen) — Stage-Pipeline, Rejection-Flow (Modal mit Pflichtfeldern), Placement-Flow (atomare Transaktion), Stale-Detection, Interview-Flow mit Outlook-Sync, Honorar-Berechnung, Post-Placement-Reminders, Rückvergütungs-Staffel

**Kritische Verknüpfungen dokumentiert:**
- Placement → Mandat-Billing (Stage 3 / Success Fee)
- Placement → Schutzfrist auf `honored`
- Placement → Referral-Payout-Trigger
- Placement → Job auf `filled`
- Rejection → Neues 12-Monats-Schutzfrist-Fenster

**Aktualisiert:**
- `wiki/sources/prozess-schema.md` (neu)
- `wiki/sources/prozess-interactions.md` (neu)
- `wiki/meta/detailseiten-inventar.md` — Prozesse ✅
- `index.md` — Sources auf 32, 2 neue Einträge

---

## [2026-04-13] update | Credits-Verfall endgültig verneint + Nachbearbeitungs-Liste

**Entscheidung Peter:** Credits verfallen nie — weder Phase 1 noch Phase 2. Feld `credits_expiry_date` komplett aus Schema und Interactions entfernt.

**Neu erstellt:** `wiki/meta/detailseiten-nachbearbeitung.md` — sammelt Punkte für die finale Überarbeitungsrunde (rückwärts durch alle Detailseiten), wenn alle Einzel-Specs existieren. Aktuell 8 Punkte:
1. Account Tab 8 — Credits-Übersicht pro Account (KPI-Banner)
2. Kandidat-Assessment-Tab — Auftrags-Referenz in Versionen
3. Mandat Tab 1 Sektion 6b — Assessment-Inline-Details
4. Mandat Tab 2 — Vorstellungs-Markierung UX-Pattern
5. Account Tab 9 — Claim-Rechnungs-Template fehlt
6. Breadcrumb-Konsistenz-Pass
7. Snapshot-Bar Slot-Anzahl einheitlich?
8. Mockup-HTMLs für Mandat/Account/Assessment

**Aktualisiert:** `index.md` — Nachbearbeitungs-Liste unter Meta.

---

## [2026-04-13] create | Assessment Schema v0.1 + Interactions v0.1 (P1 Schritt 1)

**Neu erstellt:**
- `specs/ARK_ASSESSMENT_DETAILMASKE_SCHEMA_v0_1.md` (~395 Zeilen)
- `specs/ARK_ASSESSMENT_DETAILMASKE_INTERACTIONS_v0_1.md` (~355 Zeilen)

**Kernentscheidung — Credits-Modell:**
Nach 7 Klärungsfragen an Peter (13.04.2026):
1. Multi-Kandidat-Aufträge: 1 Auftrag = n Kandidaten via `fact_assessment_run` Bridge
2. Billing: Sofort bei Unterschrift fällig (`full`, Pauschale)
3. Fremdkandidaten: Hard-Stop-Flow, Kontakt=Kandidat-Regel gilt
4. Partner: nur SCHEELEN, Freitext-Feld reicht (keine Entity)
5. **Credits-Modell** (KERN): Kunde kauft N Credits als Paket, Credits können umgewidmet werden solange noch nicht durchgeführt — wie Gutschein-System
6. Wiederholungs-Assessments: erlaubt, Versionierung im Kandidaten-Tab
7. Verknüpfung zu DISC/EQ/Outmatch: neue Versions-Einträge verknüpft mit `assessment_order_id`

**Struktur:**
- 5 Tabs: Übersicht, Durchführungen, Billing, Dokumente, History
- Snapshot-Bar: Preis/Credits-Total/Verbraucht/Ausstehend/Partner + Credit-Progress-Bar
- Kern-Flows: Credit-Zuweisungs-Drawer, Umwidmungs-Flow (Kandidat ersetzen), Report-Upload-Flow mit Transaktion (Run + Kandidaten-Version + credits_used Increment)

**Neue DB-Tabellen:**
- `fact_assessment_order` (package, credits_total, price_chf, partner, status)
- `fact_assessment_run` (kandidat_id, scheduled_at, completed_at, result_version_id, reassigned_from_kandidat_id für Audit)
- `fact_assessment_billing` (billing_type: full/deposit/final/expense)

**Aktualisiert:**
- `wiki/sources/assessment-schema.md` (neu)
- `wiki/sources/assessment-interactions.md` (neu)
- `wiki/meta/detailseiten-inventar.md` — Assessments ✅
- `index.md` — Sources-Count auf 30, 2 neue Einträge

---

## [2026-04-13] create | Account-Interactions v0.2 — Tab 8 Assessments + Tab 9 Schutzfristen

**Neu erstellt:** `specs/ARK_ACCOUNT_DETAILMASKE_INTERACTIONS_v0_2.md`
**Archiviert:** v0.1 nach `specs/alt/`

**Neue Sektionen:**
- **TEIL 8b — Tab 8 Assessments:** Datenmodell (`fact_assessment_order` + `fact_assessment_billing`), Layout mit Teamrad-KPI-Banner, 7-Schritt-Beauftragungs-Flow mit Kandidat-Wahl/Mandats-Verknüpfung/Package-Typ/Preis/Offerte/Upload/Auto-Aktionen, Status-Pipeline (offered→ordered→scheduled→completed→invoiced), Cross-Navigation (Mandat-Option IX, Kandidaten-Assessment-Tab), Berechtigungsmatrix, Empty-State, Phase 1.5/2
- **TEIL 8c — Tab 9 Schutzfristen:** Matrix-Layout, Filter-Bar, Spalten inkl. Vorstellungs-Typ und extended-Flag, **Claim-Workflow** (Info-Request mit 10-Tage-Auto-Extension → 16 Monate, Claim stellen mit Honorar-Berechnung aus Staffel, Abschliessen ohne Claim mit Begründung), manueller Eintrag, Berechtigungsmatrix, Empty-State, Phase 1.5/2

**Header-Updates:**
- Quick-Action "🧭 Assessment beauftragen" für eigenständige Assessment-Aufträge
- Claim-Banner (Full-Width, amber) bei offenen Schutzfrist-Verletzungen → springt zu Tab 9

**Restrukturierung:** Tab 8 (Prozesse) → Tab 10, Tab 9 (History) → Tab 11, Tab 10 (Dokumente) → Tab 12, Tab 11 (Reminders) → Tab 13.

**Aktualisiert:**
- `wiki/sources/account-interactions.md` — zeigt v0.2
- `wiki/meta/detailseiten-inventar.md` — Accounts Interactions ✅
- `index.md`

**P0 vollständig abgeschlossen:**
1. ✅ Mandat Interactions v0.2 (12.04/13.04.2026)
2. ✅ Mandat Schema v0.1 (13.04.2026)
3. ✅ Account Schema v0.1 (13.04.2026)
4. ✅ Account Interactions v0.2 (13.04.2026)

---

## [2026-04-13] create | Account-Schema v0.1 (P0 Schritt 3/3) — P0 abgeschlossen

**Neu erstellt:** `specs/ARK_ACCOUNT_DETAILMASKE_SCHEMA_v0_2.md`

24 Sektionen: Zielbild, Designsystem mit Status-Farben, Gesamt-Layout, Header (Logo + Titel + Aliases + 6-Slot Snapshot-Bar + Quick Actions + Tab-Bar + Soft-Block-Banner), **13 Tab-Schemas**, Keyboard-Hints, Responsive, RBAC-Matrix, DB-Referenz, Offene Punkte, Related Specs.

**Neue Tabs gegenüber Interactions v0.1:**
- **Tab 8 Assessments** — Alle Assessment-Aufträge (mandatsbezogen + eigenständig), Teamrad-Abdeckungs-KPI
- **Tab 9 Schutzfristen** — Matrix + Claim-Workflow + Auto-Extension-Timer

**Aktualisiert:**
- `wiki/sources/account-schema.md` (neu)
- `wiki/meta/detailseiten-inventar.md` — Accounts Schema ✅, Interactions v0.2 als Folgeaufgabe markiert
- `index.md` — Account-Schema Eintrag

**P0 abgeschlossen:** Alle 3 P0-Schritte fertig (Mandat Interactions v0.2, Mandat Schema v0.1, Account Schema v0.1). **Neuer P0 entstanden:** Account Interactions v0.2 um Tab 8 + Tab 9 Flows zu ergänzen.

---

## [2026-04-13] create | Mandat-Schema v0.1 (P0 Schritt 2/3)

**Neu erstellt:** `specs/ARK_MANDAT_DETAILMASKE_SCHEMA_v0_2.md`

16 Sektionen: Zielbild, Designsystem, Gesamt-Layout, Breadcrumb, Header (Titel/Meta/Snapshot-Bar/Quick Actions/Tab-Bar/Terminated-Banner), 6 Tab-Schemas (Feld-Inventar + DB-Quellen + Empty States), Keyboard-Hints, Responsive, Berechtigungen (RBAC-Matrix 6 Rollen), Datenbank-Referenz neue Tabellen, Offene Spec-Punkte.

**Aktualisiert:**
- `wiki/sources/mandat-schema.md` (neu)
- `wiki/meta/detailseiten-inventar.md` — Mandate Schema ✅
- `index.md` — Mandat-Schema hinzugefügt, Mandat-Interactions auf v0.2

**P0 Fortschritt:** 2/3 Schritte fertig (Mandat Interactions v0.2 ✅, Mandat Schema v0.1 ✅). Nächster Schritt: Accounts-Schema v0.1.

---

## [2026-04-13] create | Specs-Ordner + Mandat-Interactions v0.2

**Neuer Ordner:** `/specs/` für Detailseiten-Schema- und Interactions-Dokumente (getrennt von `/raw/` für externe Quellen).

**Verschoben nach `/specs/`:**
- ARK_ACCOUNT_DETAILMASKE_INTERACTIONS_v0_1.md
- ARK_KANDIDATENMASKE_INTERACTIONS_v1_2.md
- ARK_KANDIDATENMASKE_SCHEMA_v1_2.md
- ARK_MANDAT_DETAILMASKE_INTERACTIONS_v0_1.md

**Wiki-Pfade aktualisiert** in 4 Source-Pages.

**Neu erstellt:**
- `specs/ARK_MANDAT_DETAILMASKE_INTERACTIONS_v0_2.md` — Update von v0.1 mit:
  - TEIL 9: Kündigung & Exit Option (Fall A/B Formeln, Kündigungs-Drawer, Auto-Rechnungs-Generierung)
  - TEIL 2b: Optionale Stages VI–X (fact_mandate_option, Auftragserteilung-PDF, Auto-Billing)
  - TEIL 10: Schutzfrist-Integration (fact_candidate_presentation + fact_protection_window, nur vorgestellte Kandidaten, 16-Monats-Extension)
  - TEIL 11: Verknüpfungen (Assessment Option IX + eigenständig, Referral Kandidat/Kunde)
  - TEIL 12: Events & Audit (11 Mandat-Events)
  - Header: Quick-Actions "Option buchen" + "Mandat kündigen", Snapshot-Bar Exklusivitäts-Badge
  - TEIL 0: Taskforce = umbenanntes RPO

**Aktualisiert:**
- `wiki/sources/mandat-interactions.md` — zeigt jetzt v0.2
- `wiki/meta/detailseiten-inventar.md` — Mandate Interactions Status ✅ v0.2

---

## [2026-04-13] create | Detailseiten-Guideline + Inventar

**Neue Meta-Pages:**
- `wiki/meta/detailseiten-guideline.md` — Pflicht-Inhalt für jede Detailseite: Schema (Layout, Felder, Tabs, Design) + Interactions (Funktionen, Verknüpfungen, Automationen, Zwänge, Events)
- `wiki/meta/detailseiten-inventar.md` — Status-Übersicht aller 9 Detailseiten

**9 Detailseiten im CRM festgelegt:**
1. Kandidaten (v1.2 ✅)
2. Accounts (Interactions v0.1, Schema fehlt)
3. Firmengruppen (fehlt)
4. Mandate (Interactions v0.1 outdated, Schema fehlt)
5. Jobs (fehlt)
6. Prozesse (fehlt, nur Frontend-Freeze-Erwähnung)
7. Assessments (neu, fehlt komplett)
8. Scraper (fehlt)
9. Projekte (fehlt, 3-Tier-Datenmodell)

**Nicht im CRM:** Mitarbeiter und Reporting/Performance kommen ins ERP (HR + Performance-Tool). Im CRM nur das Dashboard als Übersicht.

`index.md` updated mit Guideline + Inventar Links.

---

## [2026-04-13] update | Assessment bekommt eigene Detailseite

**Entscheidung:** Assessment-Aufträge bekommen eigene Detailseite `/assessments/[id]` (5 Tabs analog Mandat), bidirektional verknüpft mit Account, Kandidat und optional Mandat.

**Verknüpfungs-Details in [[diagnostik-assessment]]:**
- Account-Detailseite: eigene Section "Assessments" neben "Mandate", Teamrad aggregiert automatisch
- Kandidat Assessment-Tab: Link "Teil von Auftrag XYZ" → Navigation
- Mandat: `fact_assessment_order.mandat_id` bei mandatsbezogener Durchführung, erscheint im Mandat-Tab Dokumente/Übersicht
- Navigations-Flow bidirektional zwischen allen Entitäten

---

## [2026-04-13] update | RPO-Präzisierung + Assessment-Billing-Struktur

**Präzisierungen:**
- **RPO = Taskforce (Umbenennung, nicht Einstellung):** Gleiches Produkt, nur neuer Name. `Vorlage_RPO-Offerte.docx` ist inhaltlich weiterhin gültig, nur der Titel sollte zu "Taskforce-Offerte" umbenannt werden.
- **Assessment-Auftragsvertrag + Billing:** Jeder Assessment-Auftrag hat eigenen Vertrag (Offerte → Unterschrift → `fact_assessment_order`) und eigene Billing-Spur (`fact_assessment_billing` analog zu `fact_mandate_billing`, inkl. Spesen-Typ). UI-Pattern: 5-Tab-Detailseite am Account analog zu Mandat.

**Aktualisiert:** `mandat.md`, `rpo-offerte.md`, `honorar-berechnung.md`, `diagnostik-assessment.md` (Auftragsvertrag + Billing-Section + UI-Pattern), `mandat-lifecycle-gaps.md`.

---

## [2026-04-13] update | Mandats-Lifecycle-Fragen 4–8 geklärt + Kündigungs-Formel korrigiert

**Kündigungs-Formel Fall B nochmal korrigiert:**
- Fall B: `Payout_Total = max(Σ Stages bis inkl. laufender, 80%)` — 80% sind ein **Floor** auf Gesamt-Payout
- Bei Kündigung in Stage 3 zahlt Kunde 100% (= Stage 3 regulär, da Stages > 80%)
- Bei Kündigung in Stage 1/2 greifen die 80%-Floor

**5 offene Fragen geklärt:**
4. **Referral:** Zwei Typen (Kandidat/Kunde). Kandidaten-Referral fällig bei Placement + Rückvergütungsfrist bestanden. Kunden-Referral fällig bei erstem Placement + Mandat komplett abgeschlossen.
5. **Optionale Stages Preise:** Case-by-case, keine Formeln.
6. **Diagnostik/Assessment Datenfluss:** Person als Kandidat erfassen, Account zuweisen, Assessment-Tab, History bei beiden. Empfehlung: eigene Entity `fact_assessment_order`, nicht als Mandat (Mandat-Datenmodell ist Longlist/Research/Placement-spezifisch).
7. **Fall A Kündigung:** Bisher nie passiert, Kulanz-Fortsetzung statt Kündigung.
8. **Schutzfrist-Vorstellung:** Mündlich (Telefon/Teams) oder per E-Mail-Dossier.

**Aktualisiert:** `mandat-kuendigung.md`, `direkteinstellung-schutzfrist.md`, `referral-programm.md`, `optionale-stages.md`, `diagnostik-assessment.md`, `honorar-berechnung.md`, `mandat-lifecycle-gaps.md`.

---

## [2026-04-12] update | 3 Mandats-Lifecycle-Entscheidungen von Peter

**Klarstellungen:**
1. **Kündigungs-Formel:** Fall A: fix 80% − bezahlte Stages. Fall B: `Payout = max(Σ Stages bis inkl. laufender, 80%)` — die 80% sind Floor auf Gesamt-Payout; bei Kündigung in Stage 3 zahlt Kunde 100% (Stage 3 regulär), in Stage 1/2 greifen die 80%.
2. **RPO ist eingestellt:** Umbenannt in Taskforce, keine eigene Produktlinie mehr. Alte Offerte historisch.
3. **Schutzfrist-Scope = Variante A:** Nur konkret vorgestellte Kandidaten (CV/Dossier/Pitch), nicht ganze Longlist, nicht Kompetenzbereich.

**Aktualisiert:** `mandat-kuendigung.md`, `direkteinstellung-schutzfrist.md` (inkl. `fact_candidate_presentation`-Tabelle), `mandat.md`, `honorar-berechnung.md`, `rpo-offerte.md` (als historisch markiert), `mandat-lifecycle-gaps.md` (Fragen 1/2/3 geschlossen).

---

## [2026-04-12] ingest | General-Ordner (Toolbox) + Mandats-Lifecycle-Gap-Analyse

**Quelle:** `raw/General/` — kompletter Vorlagen-Korpus (Rechnungen, Offerten, Reportings, Candidate Management)

**Neue Source-Pages (10):**
- `wiki/sources/mandatsofferte-vorlage.md` — Exklusivmandat mit Exit Option II + Optionales VI–X
- `wiki/sources/rpo-offerte.md` — RPO als eigene Mandatsform (Monatsfee + Platzierungs-Fee)
- `wiki/sources/offerte-diagnostik.md` — Diagnostik & Assessment Pauschalpreis
- `wiki/sources/rechnungen-mandat.md` — 7 Rechnungstypen inkl. **Kündigungs-Rechnung** (80%-Formel) + Rückerstattung + Opt Stage
- `wiki/sources/rechnungen-best-effort.md` — Best Effort + Diagnostik + Mahnungen
- `wiki/sources/auftrag-optionale-stage.md` — Nachträgliche Option-Bestellung (VIII Marketing als Beispiel)
- `wiki/sources/reportings-am-cm-tl.md` — AM/CM/TL-Reporting-Matrizen
- `wiki/sources/interviewguide-kandidat.md` — Kandidaten-Vorbereitungs-Guide
- `wiki/sources/referenzauskunft.md` — 5-Kompetenzbereiche-Leitfaden
- `wiki/sources/referral-programm.md` — CHF 1'000 Empfehlungs-Prämie

**Neue Concept-Pages (4):**
- `wiki/concepts/mandat-kuendigung.md` — Exit Option, 80%-Regel, Kündigungs-Rechnung-Auto-Trigger
- `wiki/concepts/direkteinstellung-schutzfrist.md` — 12/16-Monats-Schutzfrist-Datenmodell + Detection
- `wiki/concepts/optionale-stages.md` — VI–X strukturiert, `fact_mandate_option` vorgeschlagen
- `wiki/concepts/diagnostik-assessment.md` — Eigenständige Dienstleistungs-Linie

**Neue Analysis-Page:**
- `wiki/analyses/mandat-lifecycle-gaps.md` — 10 Gaps mit P0/P1/P2/P3-Priorisierung + offene Fragen an Peter

**Updates:**
- `wiki/entities/mandat.md` — RPO-Zeile, Optionale-Stages-Section, Kündigungs-Block im Status-Flow, neue Related-Links
- `wiki/concepts/honorar-berechnung.md` — Kündigungs-Szenario (80%-Regel), RPO-Abschnitt, Diagnostik-Abschnitt
- `index.md` — 10 Sources + 4 Concepts + 1 Analysis ergänzt, Counter aktualisiert

**Wichtigste Erkenntnisse:**
1. **Exit Option (80%-Regel)** aus Mandatsofferte Klausel II: vertraglich verbindlich, im CRM nicht abgebildet
2. **Schutzfrist 12/16 Monate** aus AGB: braucht Tracking-Matrix + Scraper-Match, aktuell manuell
3. **Optionale Stages VI–X**: Klauseln existieren, aber nur Template für VIII (Marketing)
4. **RPO**: eigene Mandatsform, fehlt im `mandate_type` Enum (`Target/Taskforce/Time`)
5. **Diagnostik & Assessment**: technisch in `fact_assessment` abgebildet, Billing-Pfad fehlt

---

## [2026-04-12] create | Mandat-Detailmaske Interactions Spec v0.1

**Neues Spec-Dokument:** `raw/Ark_CRM_v2/ARK_MANDAT_DETAILMASKE_INTERACTIONS_v0_1.md`
**Source page:** wiki/sources/mandat-interactions.md

**6 Tabs vollständig spezifiziert:**
1. Übersicht: Typ-spezifische Konditionen + KPIs + Status-Wechsel-Logik
2. Longlist: Kanban (10 Spalten), Locking ab CV IN, Durchcall-Funktion mit Priority-Queue, Bulk-Actions
3. Prozesse: Alle Mandate-Prozesse, Liste/Kanban
4. Billing: Typ-spezifisches Zahlungstracking, Auto-Trigger, Rechnungserstellung
5. History: Longlist-Kandidaten-History, Call-Statistik als KPI-Banner
6. Dokumente: Mandat-Report Generator, Mandatsofferte-Trigger

**Status: Erster Entwurf, Review durch Peter ausstehend.**

---

## [2026-04-12] ingest | Factsheet Personalgewinnung + Mandatstypen-Umbenennung

**Source ingested:** ARK_Factsheet Personalgewinnung.pdf
**Source page created:** wiki/sources/factsheet-personalgewinnung.md

**Naming-Korrektur (BREAKING):** Mandatstypen umbenannt gemäss offiziellem Factsheet:
- Einzelmandat → **Target** (Exklusivmandat)
- RPO → **Taskforce**
- Time → Time (unverändert)
- Best Effort = Target Best Effort (kein Mandat)

**Korrekturen an Konditionen:**
- Target: Fixpauschale ÷ 3 (nicht %-basiert), Garantiezeit 3 Monate (nicht 12!), Ersatzbesetzung statt Rückvergütung
- Taskforce: Success Fee individuell pro Position
- Time: Wochenfee pro Slot (degressiv), min. 2 Slots, Dauer in Wochen, monatlich abgerechnet
- Zahlungsziel Default 10 Tage (nicht 30)

**Pages updated:** mandat.md, honorar-berechnung.md, erfolgsbasis.md, overview.md, job.md, prozess.md, automationen.md, rekrutierungsprozess.md, index.md
**Interactions Spec:** TEIL 8 (Tab 7 Mandate) — Fragen 8.1-8.3 beantwortet

---

## [2026-04-12] update | Account Interactions Spec — Tab 7 Mandate (Fragen 8.1–8.3)

**Entscheidungen:**
- 8.1 Layout: Hybrid — Entwürfe als amber Banner über der Tabelle, darunter Filter-Chips
- 8.2 Entwurf erstellen: Drawer mit dynamischen Sektionen nach Mandats-Typ
- 8.3 Konditionen: Strukturiert + Freitext, typ-spezifische Felder (Target: Pauschale÷3, Taskforce: Monatsfee + individuelle Success Fees, Time: Paket/Slots/Wochenfee)

**Fragen 8.4–8.6 ebenfalls beantwortet:**
- 8.4 KPI-Targets: Hard-Pflicht bei Aktivierung (Ident, Call, Shortlist — alle drei blockierend), nur Target-Mandate
- 8.5 KPI-Tracking: Mini-Ampel (🟢🟡🔴) in Tabelle + Detail-Bars im Drawer
- 8.6 Drawer-Tabs: 5 Tabs (Übersicht / Jobs / Pipeline / Billing / Dokumente)

**Tab 7 Mandate ist damit vollständig spezifiziert.**

## [2026-04-12] update | Account Interactions Spec — Tabs 8-11 + Firmengruppe

**Alle verbleibenden Tabs spezifiziert:**
- Tab 8 Prozesse: Analog Kandidat + Kandidaten-/CM-Spalte, Mandat-Filter, Cross-Nav Tab7→Tab8
- Tab 9 History: Analog Kandidat + Kontaktperson-Spalte/-Verknüpfung, Account-spezifische ActivityTypes
- Tab 10 Dokumente: Analog Kandidat + Account-Dokumenttypen, Mandats-Verknüpfung bei Upload, "Mandatsofferte unterschrieben" → Aktivierungs-Trigger
- Tab 11 Reminders: Analog Kandidat + Mandat/Job/Kontakt-Verknüpfung, 5 account-spezifische Auto-Reminders
- Firmengruppe (konditional): Read-only Aggregations-Dashboard

**Account-Detailmaske Interactions Spec ist damit KOMPLETT.** Alle 11 Tabs + Header + Firmengruppe spezifiziert.

**Pages updated:** account.md, account-interactions.md

---

## [2026-04-08] analysis | Naming-Audit — Vollständiger Konsistenz-Check

**Alle Werte über alle 8 Quelldokumente geprüft:**
Kandidaten-Stages, Prozess-Stages, Prozess-Status, Mandat-Status, Activity-Kategorien, Dokument-Labels, Standort-Typen, Rollen, Wechselmotivation, Rejection-Types, Jobbasket-Stages

**7 echte Inkonsistenzen gefunden:**
1. Expose vs. Exposé (Akzent-Diskrepanz DB vs. Display)
2. 3 Dokument-Labels fehlen im DB CHECK (Schriftliche GO, Foto, Vertrag)
3. Location Types: 4 in DB vs. 2 in Account Interactions, Branch vs. Niederlassung
4. Mandat Report vs. Mandat-Report (Space vs. Hyphen)
5. Assessment-Dokument vs. Assessment (Kurzform)
6. Refresh Kandidatenpflege vs. Refresh (Kurzform)
7. Mandat-Status Mixed Language nicht als Mapping dokumentiert

**Page updated:** namenskonventionen.md (komplett überarbeitet mit allen Findings + offenen Korrekturen)

**Deine Entscheidung nötig bei:** Expose/Exposé, Location Types, fehlende Dokument-Labels

---

## [2026-04-08] analysis | Ungereimtheiten Runde 2 — Business Rules + Naming

**4 weitere Bereiche geprüft:** Prozess-Stages, Kandidaten-Stages, Honorar/Rückvergütung, Rollen/Mandate
**Konsistent:** Honorar (4/4), Prozess-Stages (5/5), Prozess-Status (5/5), Mandat-Typen (4/4), Job-Status (3/3)

**Korrekturen (3 Business-Entscheidungen):**
1. Inactive-Trigger: NUR Alter >60 (Cold >6M entfernt — war falsch in Gesamtsystem + Stammdaten)
2. Refresh-Trigger: Nur nach CV Expected (nicht generell bei NIC/Dropped)
3. Rebriefing: Löst KEIN Premarket aus wenn Kandidat schon weiter ist

**Kosmetik-Fixes:**
- Namenskonventionen-Seite erstellt (kanonische Benennungen)
- Rollen: DB-Keys + Anzeige-Namen + Kürzel einheitlich dokumentiert
- rolle_type deprecated markiert → dim_roles + bridge_mitarbeiter_roles

**Offene Entscheidung:** Mandat-Status Mixed Language (DE/EN) bereinigen

**Pages updated:** kandidat.md, automationen.md, rekrutierungsprozess.md, briefing.md, overview.md, berechtigungen.md, ungereimtheiten-report.md
**Pages created:** namenskonventionen.md

---

## [2026-04-08] analysis | Ungereimtheiten-Report

**4 Ungereimtheiten geprüft gegen Originalquellen:**
1. fact_vacancies: WIDERSPRUCH → Entscheidung: deprecated (Account Interactions massgebend)
2. Account Tabs: EVOLUTION → Entscheidung: 11 + 1 konditional
3. Wechselmotivation: KOSMETISCH → DB CHECK Constraint ist kanonisch
4. Account Interactions v0.1: OFFENE PUNKTE dokumentiert (Tabs 7-11, Schema-Deltas)

**Analyse-Seite erstellt:** wiki/analyses/ungereimtheiten-report.md
**Pages updated:** account.md (Tab-Status), job.md (Vacancies deprecated), kandidat.md (WM-Wording), temperatur-modell.md (WM-Wording), index.md

**Grundsatz-Entscheidung:** Bei Widerspruch Interactions-Spec > DB Schema. Schema wird nachgezogen.

---

## [2026-04-08] lint | Wiki Health-Check + Fixes

**Broken Links gefixt:** 9 (kontakt, vakanz, erfolgsbasis, briefing, kompetenzen, matching, design-system, eskalation, bkp-codes)
**Neue Seiten erstellt:** 3 (matching.md, briefing.md, erfolgsbasis.md)
**Inkonsistenzen behoben:** 2 (Account Tabs 10→11, Activity Types 61+→63)
**Gelöschte Seiten:** 2 (kontakt.md, vakanz.md — waren keine eigenständigen Entities)
**Verbleibende broken Links:** 0

---

## [2026-04-08] ingest | Arkadium AGB Feb 2023

**Source ingested:** Arkadium_AGB_FEB_2023.pdf
**Source page created:** wiki/sources/agb-arkadium.md
**Pages updated:** account.md (AGB-Verweis), honorar-berechnung.md

---

## [2026-04-08] ingest | Batch Ingest — Alle restlichen Quellen (Phase 2)

**Sources ingested:**
5. ARK_KANDIDATENMASKE_SCHEMA_v1_2.md
6. ARK_KANDIDATENMASKE_INTERACTIONS_v1_2.md
7. ARK_ACCOUNT_DETAILMASKE_INTERACTIONS_v0_1.md
8. ARK_STAMMDATEN_EXPORT_v1_2.md
9. ARK_BKP_CODES_STAMMDATEN.md + .xlsx
10. ARK_CRM_Projektguideline.pdf
11. Ideen CRM.pdf
12. Leitfaden Mandatsablauf Executive Search.pdf
13. Ark_CV_PL_Arkadium_Arkadium.pdf + Ark_Anschreiben_Abstract.pdf + Kandidatenexpose.pdf
14. 14 HTML UI-Mockups (Kandidaten-Tabs)

**Nicht CRM-relevant (separates Projekt):**
- Vision Ark_App.pdf — Heritage App Konzept, nicht für CRM-Wiki

**Source pages created:** 9
- wiki/sources/kandidatenmaske-schema.md
- wiki/sources/kandidatenmaske-interactions.md
- wiki/sources/account-interactions.md
- wiki/sources/stammdaten-export.md
- wiki/sources/bkp-codes-stammdaten.md
- wiki/sources/projektguideline.md
- wiki/sources/ideen-crm.md
- wiki/sources/mandatsablauf-leitfaden.md
- wiki/sources/dokument-templates.md

**Concept pages created:** 4
- wiki/concepts/temperatur-modell.md
- wiki/concepts/interaction-patterns.md
- wiki/concepts/projekt-datenmodell.md
- wiki/concepts/kontakt-kandidat-regel.md

**Pages updated:** index.md, log.md

**Total wiki pages: 43**

---

## [2026-04-08] ingest | Batch Ingest — 4 Kerndokumente (Phase 1)

**Sources ingested:**
1. ARK_GESAMTSYSTEM_UEBERSICHT_v1_2.md
2. ARK_DATABASE_SCHEMA_v1_2.md
3. ARK_BACKEND_ARCHITECTURE_v2_4.md
4. ARK_FRONTEND_FREEZE_v1_9.md

**Source pages created:** 4
**Entity pages created:** 8
**Concept pages created:** 20
**Meta pages updated:** 2

---

## [2026-04-08] create | Wiki Initialized

- Created directory structure
- Created CLAUDE.md, index.md, log.md, wiki/meta/overview.md

## [2026-04-14] update | Phase A+B — Konsistenz-Updates
- P0.1: kandidat_id → candidate_id in 11 aktiven Specs (27 Ersetzungen)
- P0.4: Version-Cross-References (ACCOUNT v0.2→v0.3, MANDAT v0.2→v0.3, KANDIDATEN v1.2→v1.3, DB v1.2→v1.3, FREEZE v1.9→v1.10)
- P0.3: Mandat-Schema v0.1 → v0.2 (umbenannt, Admin-RBAC-Fix, is_longlist_locked, Claim-Fälle X/Y/Z Sektion 14.1)
- Founder → Admin global (125 Replacements, 41 Dateien, raw/ unverändert)
- P0.2: Account-Schema v0.1 → v0.2 (umbenannt, Stale-Note entfernt, Changelog)
- P0.5: Prozess-Interactions TEIL 4 — TX1 Placement 8-Step Saga mit 7 Pre-Validierungen, Rollback-Verhalten
- P0.6: Mandat-Interactions TEIL 9 — TX3 Kündigung 6-Step Saga mit 6 Pre-Validierungen + Schutzfrist-Scope-Qualification (account/group)
- Erstellt: wiki/analyses/audit-final-2026-04-14.md

## [2026-04-14] create/update | Phase C — Algorithmen + Worker + Endpunkte
- P1.3: wiki/concepts/algorithms.md erstellt (Fuzzy-Match pg_trgm, UID-Root-Matching, Honorar-Staffel, Matching-Score mit Projekt-Overlay, Temperatur-Scoring)
- P1.1: Backend v2.5 Nachtrag v2.5.1 — 4 Workflow-Worker (shortlist-trigger-payment, outlook-calendar-sync, stale-notification, process-closed-archiving)
- P1.2: Backend v2.5 Nachtrag v2.5.1 — 6 Projekt/Media-Endpunkte (projects/search, /link, /quick-create, /participations CRUD, /media/upload)

## [2026-04-14] update | Phase D — P1.4-P1.8 Detail-Gaps
- P1.4: Projekt-Interactions — Matching-Weights Overlay-Logik (Partial-Override) + Algorithms-Verweis
- P1.5: Scraper-Interactions — SLA-Tabelle (3d/4d/7d/14d) für needs_am_review mit expired_unreviewed-Status
- P1.6: Assessment-Interactions — Umwidmung UI bereits vollständig dokumentiert (check)
- P1.7: Projekt-Interactions — SIA-Phasen hierarchisch (6 Haupt + 12 Teil) mit Auto-Select-Validation
- P1.8: Kandidaten-Interactions Jobbasket Schutzfrist-SQL bereits vollständig (UNION account+group)

## [2026-04-14] create | Phase E — P2 Polish
- P2.3: wiki/meta/rbac-matrix.md — Zentrale 5-Rollen-Matrix für alle 7 Entities
- P2.4: wiki/concepts/design-tokens.md — Dark-Mode Semantic Colors, Spacing, Typography, Drawer-Breiten
- P2.2: wiki/concepts/websocket-channels.md — Channel-Konvention <entity>:<scope>:<id>, Event-Payload, Auth-Regeln
- P2.5: wiki/concepts/audit-log-retention.md — Retention 7/3/1 Jahre + Legal Hold + DSGVO-Hashing
- index.md erweitert: algorithms, design-tokens, websocket-channels, audit-log-retention, rbac-matrix, audit-final-2026-04-14

## [2026-04-14] update | P2.1 — Event-Katalog-Abgleich
- Backend v2.5.1 Event-Katalog erweitert um 6 Events: placement_failed, mandate_termination_failed, reminder_batch_created, interview_completed, finding_expired_unreviewed, legal_hold_toggled
- CRUD-Generics (description_updated, contact_changed etc.) als durch fact_audit_log abgedeckt dokumentiert

## [2026-04-14] update | Light-Mode Einführung
- Entscheidung: ARK CRM bekommt Light Mode (user-umschaltbar, Dark bleibt Default)
- wiki/concepts/design-tokens.md: komplette Light-Palette ergänzt, Theme-Umschaltungs-Logik (data-theme, localStorage), User-Feld dim_crm_users.theme_preference
- wiki/concepts/frontend-architektur.md: "Dark Mode only" → "Dark + Light Mode" + Token-Verweis
- wiki/meta/overview.md, index.md, wiki/sources/frontend-freeze.md: gesamte Dark-only-Erwähnungen angepasst
- specs/ARK_KANDIDATENMASKE_SCHEMA_v1_3.md: Farbsektion + Phase 1 Text angepasst
- raw/Ark_CRM_v2/ARK_FRONTEND_FREEZE_v1_10.md § 8c: Überschrift + Intro umgeschrieben
- raw/Ark_CRM_v2/ARK_GESAMTSYSTEM_UEBERSICHT_v1_3.md: Architektur-Absatz angepasst
- raw/Ark_CRM_v2/ARK_BACKEND_ARCHITECTURE_v2_5.md: Nachtrag v2.5.2 — GET/PATCH /api/v1/me/preferences + dim_crm_users.theme_preference ENUM

## [2026-04-14] update | Account Mockup + Spec Sync
- Mockup accounts.html: Logo klickbar, Header-Chips reorganisiert (Sparte/Status-Dropdown/Hot/Klasse/★/AGB/Schutzfristen/Gruppe), Reminder-Quick-Action ergänzt, Claim-Banner conditional über Snapshot, Sparte als Multi-Toggle (5 Sparten), Funktionen+Fokus auto-aggregiert mit Counts, alle Tab-1-Cards collapsible, Sektion 9 Empty-State
- Spec ACCOUNT_INTERACTIONS_v0_3 + ACCOUNT_SCHEMA_v0_2: Snapshot-Bar Slots 5+6 → Gegründet/Standorte (Firmografik), Tab-1 Arkadium-Relation-KPI-Bar (4 KPIs) ergänzt
- editorial.css: claim-banner, status-dropdown, toggle-group/tag, auto-chip, collapsible card patterns
- layout.js: toggleCollapse, toggleTag, statusMenu helpers

## [2026-04-14] update | Account Stammdaten-Sync
- Mockup: Claim-Banner als Chip rechts unten statt Full-Width, Sparte-Header-Pill zeigt Code "ING" + sync mit Tab-1-Toggle-Group, Team "Team ING & BT", Dossier-Präferenz "Per E-Mail an HR-Leitung", Edit-Mode komplett implementiert für Sektion 4 (Klassifikation): Click "Bearbeiten" → editing-State (gold border, gradient bg), Multi-Select-Inputs mit Tag-Pills + ×-Remove, Hint-Texte zur Pflege-Logik, Speichern/Abbrechen-Buttons
- editorial.css: .card.editing, .edit-input, .edit-multi, .edit-hint patterns
- layout.js: enterEdit/saveEdit/cancelEdit + syncSparteHeader für Header-Tab1-Sync
- ARK_STAMMDATEN_EXPORT_v1_3 §10: Owner-Teams konsolidiert "ARC & REM" + "ING & BT" (CI→ING konsistent zu Sparte-Codes), §10b NEU dim_dossier_preferences mit 7 Codes

## [2026-04-14] update | Tab 2 Profil & Kultur — Interactions-Spec-Sync
- Mockup accounts.html Tab 2: Refresh-Hint-Banner (veraltete Analyse), collapsible+edit auf allen 5 Sektionen, AI-Draft-State-Demo auf Sektion 2 (gold-border + "✓ Sektion bestätigen"-Bar), Score-Slider mit AI-Range-Visualisierung für Dimension 1+2, Versionierung mit Navigation ◀▶ + Diff-Link
- editorial.css: .card.ai-draft, .ai-confirm-bar, .refresh-hint, .score-slider-*, .version-nav patterns

## [2026-04-14] update | Kontakt-Drawer 4-Tab-Struktur in Spec
- ACCOUNT_INTERACTIONS_v0_3 TEIL 4: Kontakt-Drawer definiert mit 4 Tabs (Stammdaten/Kommunikation/Prozesse/Notizen), Filter-Chips, Kennzahlen, Zugriff via 🕒 History-Icon + › Details-Icon, Abgrenzung zu Tab 11 Account-History
- ACCOUNT_SCHEMA_v0_2 Changelog-Eintrag ergänzt
- Mockup accounts.html: Drawer bereits implementiert (4 Tabs, Timeline, Filter-Chips, 7+ Beispiel-Einträge, Kennzahlen-Sektion)
- editorial.css: .drawer, .drawer-backdrop, .drawer-head/tabs/body/foot, .comm-item, .comm-filter
- layout.js: openDrawer/closeDrawer/drawerTab helpers

## [2026-04-14] update | Grundlagen-Sync + Spec-Sync-Regel
- DB_SCHEMA v1.3 §23 Nachtrag: dim_crm_users.theme_preference ENUM + dim_dossier_preferences Referenz + Account-UI-Notiz (kein neues Schema) + Kontakt-Drawer-Notiz
- GESAMTSYSTEM v1.3 TEIL 20: Account-UI-Konsolidierung (Snapshot-Bar, KPI-Bar, Kontakt-Drawer, Theme, Stammdaten) dokumentiert
- GESAMTSYSTEM v1.3 TEIL 21: Spec-Sync-Regel definiert (5 Grundlagen × 9 Detail-Specs bidirektional, Trigger-Matrix)
- NEU: wiki/meta/spec-sync-regel.md mit vollständiger Sync-Matrix + Governance-Checkliste
- CLAUDE.md: Spec-Sync-Regel als CRITICAL-Sektion ergänzt
- index.md: [[spec-sync-regel]] verlinkt unter Meta

## [2026-04-14] update | Kontakt-Flags durch Org-Funktion ersetzt
- Stammdaten §10a NEU: dim_org_functions (7 Codes — linie/hr/management/board/einkauf/assistenz/fachspezialist)
- DB-Schema v1.3.1: dim_account_contacts DROP is_decision_maker/is_key_contact/is_champion/is_blocker + ADD org_function TEXT CHECK + Index
- ACCOUNT_INTERACTIONS_v0_3 TEIL 4: Flag-Liste ersetzt durch org_function, neue Filter-Chip-Gruppe + Sort-Optionen dokumentiert, Tabellen-Spalte "Org-Funktion" ergänzt
- Mockup Tab 3: Pills DM/KC/Champion/Blocker → L/H/M/B/E/A/F mit farbkodierten Org-Pills, neue Spalte "Org-Funktion", Filter-Select angepasst, Drawer zeigt Org-Funktion statt Flags, Legende aktualisiert
- editorial.css: .role-pill entfernt, .org-pill mit 7 Varianten (Serif-Buchstaben im 22px-Square, farbkodiert)

## [2026-04-14] update | Decision Level entfernt (redundant)
- DB-Schema §23: ALTER TABLE + DROP COLUMN decision_level
- ACCOUNT_INTERACTIONS_v0_3 TEIL 4: decision_level aus Felder-Liste entfernt, Spalte + Filter + Sort-Option entfernt, Grund dokumentiert (redundant mit Position + Org-Funktion + Organigramm)
- Mockup accounts.html: Decision-Level-Filter-Select, Tabellen-Spalte + alle TD-Werte, Drawer-Field entfernt

## [2026-04-14] update | Org-Funktion konsolidiert auf 5 Codes
- Entscheidung: VR-Board + Executive + HR + Einkauf + Assistenz (statt 7 Codes). Linie+Management zu Executive gemergt, Fachspezialist entfernt, Board → VR-Board, Kurz-Buchstabe Einkauf: E → K (Konflikt mit Executive)
- Stammdaten §10a: 5 Codes dokumentiert
- DB-Schema §23: CHECK constraint angepasst
- ACCOUNT_INTERACTIONS_v0_3 TEIL 4: 5 Codes + neue Pill-Buchstaben V/E/H/K/A + Filter-Liste
- ACCOUNT_SCHEMA_v0_2: Spalten-Tabelle aktualisiert (Department als eigene Spalte, Decision Level raus)
- FIRMENGRUPPE_SCHEMA_v0_1: Gruppen-Entscheider-Query auf org_function umgestellt
- Mockup accounts.html: Pills neu gemappt (linie→executive, board→vr_board, einkauf-letter E→K), Legende mit 5 Codes, Filter-Select 5 Optionen
- editorial.css: .org-pill-Klassen reduziert auf 5 (vr_board/executive/hr/einkauf/assistenz)

## [2026-04-14] update | Tab 5 Teamrad — Terminologie korrigiert
- EQ: Stress-Management/Anpassungsfähigkeit (EQ-i) → 5 Goleman-Dimensionen (Selbstwahrnehmung/Selbstregulation/Soziale Wahrnehmung/Soziale Regulierung/Motivation)
- Motivatoren: Phantasie-Begriffe → 6 Scheelen-Polaritäten (Theoretisch/Ökonomisch/Ästhetisch/Sozial/Individualistisch/Traditionell mit L-Pol ↔ R-Pol)
- Outmatch: 8 generische Kompetenzen → ASSESS 5.0 Kompetenzen-Katalog mit 11 Standard-Profilen (Executive/HR/Sales/Leading-*) + Custom-Option
- Stammdaten §67: dim_eq_dimensions, dim_motivator_dimensions, dim_assess_competencies (26), dim_assess_standard_profiles (11) neu dokumentiert
- ACCOUNT_INTERACTIONS v0.3 TEIL 6: Teamrad-Struktur präzisiert (I AI zuoberst → VII Fit), Terminologie-Lock dokumentiert, "+ Kandidat"-Button-Flow + "💾 Team speichern"-Button spezifiziert
- Mockup: "+ Kandidat"-Button im Control-Bar, T. Furrer als Chip mit ×-Remove, "💾 Team speichern"-Button

## [2026-04-14] update | Assessment-Terminologie präzisiert per Musterberichte
- Input: raw/Musterbericht_TriMetrix_EQ_Driving_Forces_de.pdf + raw/ASSESS Standard Jobprofile.pdf + raw/Kompetenzen Assess.png
- Global: "Selbstregulation" → "Selbstregulierung" (Scheelen-Schreibweise), "Effizienz-getrieben"/"Macht-orientiert" zusammengezogen
- Stammdaten §67a EQ: Scheelen/Insights MDI Modell (5 Dim., Intrapersonal 1-3 vs. Interpersonal 4-5), Gesamt-EQ-Quotient + 2 Sub-Quotienten
- Stammdaten §67b Motivatoren: TTI 12 Driving Forces basierend auf Spranger-6, Gruppe Primär/Situativ/Indifferent (je 4 Forces)
- Betroffene Dateien: mockups/accounts.html, 2 Specs, 1 Stammdaten-Datei

## [2026-04-14] update | Tab 6 Wording-Korrekturen + Drawers-Polish
- Stage-Wording korrigiert gem. dim_process_stages: Angebot→Offer, Briefing→TI, Identified→Expose (überall in accounts.html)
- Kanban-Spalten + Pipeline-Funnel umbenannt
- Job-Drawer Footer: "AM anrufen" → "Ansprechperson anrufen" (Hiring-Manager am Account)
- Row-Click auf Job-Zeile → öffnet Job-Drawer; ›-Pfeil → navigiert zu /jobs/[id] Vollansicht
- Dark-mode Fix: datetime-local/date/time mit color-scheme:light dark + inverted calendar-icon
- CLAUDE.md: Stammdaten-Wording-Regel (CRITICAL) mit 7 häufig falsch verwendeten Katalogen
- wiki/meta/spec-sync-regel.md: Stammdaten-Wording-Validierung ergänzt

## [2026-04-14] update | Datum-Eingabe-Regel
- wiki/concepts/interaction-patterns.md §14: Datum-/Zeit-Felder müssen Kalender-Picker UND manuelle Tastatur-Eingabe unterstützen (Formats: TT.MM.JJJJ / JJJJ-MM-TT / TT.MM.JJ)
- CLAUDE.md: Regel als CRITICAL ergänzt
- mockups/accounts.html: Briefing-Termin-Input mit placeholder + Format-Hinweis
- editorial.css hat bereits color-scheme:light dark + dark-mode calendar-icon-invert

## [2026-04-14] update | Terminologie Briefing vs. Stellenbriefing
- interaction-patterns.md §14a: klare Unterscheidung dokumentiert — Briefing=Kandidatenseite, Stellenbriefing=Account/Job/Mandatsseite
- CLAUDE.md: Kurz-Regel ergänzt
- Mockup accounts.html: "Briefing-Termin" → "Stellenbriefing-Termin" (Vakanz-Drawer), "aus Briefing" → "aus Stellenbriefing" (Job-Stammdaten), "CFO-Briefing" → "CFO-Stellenbriefing" (Kontakt-Kommunikation), Dokument-Label "Briefing-Protokoll" → "Stellenbriefing-Protokoll", "Briefing-Gespräch" → "Stellenbriefing"
- Reminder-Typen (dim_reminder_templates): briefing_candidate vs. stellenbriefing_client

## [2026-04-14] update | Activity-Type-Wording-Regel + Mockup-Cleanup
- Tab 6 Job-Drawer Stellenausschreibung: Button "An Kandidaten-Briefing übertragen" entfernt (war funktionslos)
- History-Events in accounts.html auf echte Activity-Types (dim_activity_types §14) korrigiert: "Call mit H. Müller" → "Erreicht — Update Call", "CV Sent" → "Emailverkehr — CV Sent", "Briefing-Termin angesetzt" → "Erreicht — Appointment", "platziert" → "Erreicht — Placement Call"
- CLAUDE.md + spec-sync-regel.md: Activity-Type-Regel ergänzt — 63 Einträge in 11 Kategorien, niemals freitext erfinden, Format <Kategorie> — <Activity-Type-Name>

## [2026-04-14] update | Drawer-Default-Regel + Mandat-Verlängerung
- Drawer-Default-Konvention dokumentiert: interaction-patterns.md §4 + CLAUDE.md (CRUD/Confirm/Multi-Step → Drawer, Modal nur Ausnahme)
- Aktivierungs-Modal → Aktivierungs-Drawer umgebaut (gleicher Pattern wie Vakanz/Job/Mandat-Drawer)
- Mandat-Drawer: Sektion "Mandats-Optionen" mit typ-spezifischen Aktionen (+ Position Taskforce, + Wochen/Slot Time, Garantie/Stornierung global)
- specs/ARK_MANDAT_DETAILMASKE_INTERACTIONS_v0_3.md TEIL 8b NEU: Mandats-Verlängerung dokumentiert (Time = Wochen+Slots, Taskforce = Positionen, Target = nicht erweiterbar) + fact_mandate_extensions Audit-Tabelle

## [2026-04-14] update | Outmatch → ASSESS 5.0 global rename
- Display "Outmatch" → "ASSESS 5.0" in 19 aktiven Files: index.md, mockups/accounts.html, 4 raw/Ark_CRM_v2/* (DB-Schema v1.3, Frontend-Freeze v1.10, Gesamtsystem v1.3, Stammdaten v1.3), 5 Specs, 6 Wiki-Seiten
- Stammdaten/DB-Schema: type-key Pipe-Tabellen-Wert 'outmatch' → 'assess_5_0' (Soft-Migration vorgemerkt für DB)
- Skipped: /alt/-Archiv, .superpowers/-Temp, log.md, ältere Versions (v1_2, v1_9), Kandidaten-Sample-HTMLs in raw/Ark_CRM_v2/

## [2026-04-14] update | Assessment-Lifecycle korrigiert
- Account-Spec TEIL 8b: status-Enum von 5 auf 4 reduziert (offered/ordered/scheduled/completed). 'invoiced' war fälschlich Auftrag-Status, gehört aber zu fact_assessment_billing.status (parallel)
- Mockup Tab 8 Footer-Note: zwei getrennte Lifecycles dokumentiert (Auftrag vs. Billing). Klargestellt dass Rechnung sofort bei 'ordered' fällig wird
- Assessment-Detailmaske-Spec v0.2 (eigenständige Spec) bleibt unverändert mit 6-State-Enum (offered/ordered/partially_used/fully_used/invoiced/cancelled) — andere Semantik (invoiced = fully closed)

## [2026-04-24] sync-report | ARK Drift-Scan — found 41 drift items (4 stale digests + 18 spec-drift + 19 mockup-drift) · 525 lint-violations 7d
