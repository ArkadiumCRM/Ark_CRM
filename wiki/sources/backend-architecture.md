---
title: "ARK Backend Architecture v2.5"
type: source
created: 2026-04-08
updated: 2026-04-14
sources: ["ARK_BACKEND_ARCHITECTURE_v2_5.md", "ARK_BACKEND_ARCHITECTURE_v2_4.md"]
tags: [source, backend, architecture, technical]
---

# ARK Backend Architecture v2.5

**Aktuelle Datei:** `raw/Ark_CRM_v2/ARK_BACKEND_ARCHITECTURE_v2_5.md`
**Vorherige Version:** `raw/Ark_CRM_v2/ARK_BACKEND_ARCHITECTURE_v2_4.md` (bleibt erhalten)

## v2.5 (14.04.2026) — Konsolidierung der Detailseiten-Specs

**Ergänzung** zu v2.4, **nicht Ersetzung**. Bestehende Endpunkte/Events/Worker aus v2.4 bleiben gültig.

### Zusammenfassung

| Bereich | Neu in v2.5 |
|---------|-------------|
| Events | 30+ neue Event-Typen |
| Worker | 18 neue Async-Worker |
| Endpunkte | 46 neue REST-Endpunkte |
| Transaktionen | 8 atomare Multi-Step-Sagas |
| WebSocket | Neue Infrastruktur für Live-Updates |
| Rate-Limiting | Token-Bucket pro Scraper-Source + Concurrent-Limits |
| Settings | 12+ neue Keys in dim_automation_settings |
| Event-Scope-Registry | Multi-Entity-Events |

### Event-Kategorien (30+)

- Mandat: 9 (mandate_terminated, option_ordered, longlist_locked, group_mandate_created, ...)
- Schutzfrist & Claim: 7 (candidate_presented_*, protection_window_*, claim_*)
- Assessment: 13 (order_*, credit_*, run_*, version_created, order_credits_rebalanced_by_admin)
- Prozess: 11 (process_created, stale_detected, placed inkl. 5 Entities, early_exit_*, ...)
- Job: 8 (scraper_proposal_*, job_filled/closed, matching_recomputed)
- Scraper: 12 (run_*, finding_*, alert_*, auto_disable_triggered, anomaly_detected)
- Firmengruppe: 6 (group_created_*, member_added/removed, group_culture_generated)
- Projekt: 8 (project_created_*, bkp_gewerk_*, participation_*, media_uploaded, ...)

### Worker (18)

**Nightly-Batch (7):** stale-detection, assessment-billing-overdue, process-guarantee-closer, protection-window-auto-extend, candidate-temperature-scorer, account-temperature-scorer, matching-daily-batch.

**Event-getrieben (6):** process-auto-reminder, matching-recompute, referral-payout-trigger, interview-coaching/debriefing-reminder, scraper-finding-processor.

**Scraper (3):** scraper-batch-job, scraper-auto-disable, scraper-antiduplicate.

**System (2):** stammdaten-drift-detection, websocket-publisher.

### Endpunkte (46)

- Mandat: 2 (terminate, complete)
- Prozess: 13 (Placement-TX, on-hold/reopen, interviews, stage-change, bulk-reject, ...)
- Assessment: 11 (assign-credit, reassign, complete-TX, generate-quote, billing, credits-rebalance, ...)
- Account-Schutzfristen: 3 (file-claim, extend)
- Firmengruppe: 2 (mandate-for-group, group-assign)
- Scraper: 14 (bulk-run, finding-accept/reject/bulk-accept, config, alerts, report, WebSocket)
- Kandidat: 1 (presentations)

### Atomare Transaktionen (8)

TX1 Placement (8 Steps), TX2 Assessment-Report-Upload, TX3 Mandat-Kündigung, TX4 Scraper-Finding-Accept, TX5 Gruppen-Mandat-Create, TX6 Gruppen-Member-Add (Batch), TX7 Bulk-Reject-by-Mandate-Termination, TX8 Early-Exit + Refund.

### WebSocket-Infrastruktur

Neuer Endpoint `WSS /ws/tenant/:tenantId/live` mit Topic-Subscriptions. Phase 1 In-Memory Pub/Sub, Phase 2 Redis. Ziel-Latenz < 2s für Scraper, < 1s für Assessment.

### Scraper-Rate-Limiting

Token-Bucket pro (scraper_type, target_domain) + global Concurrent-Run-Limit + Soft-/Hard-Alerts.

### Event-Scope-Registry

Für Multi-Entity-Events wie `placed` (5 Entities). Registry-Pattern in `/src/events/scope-registry.ts`.

## v2.4 (unverändert)

Vollständige Backend-Spezifikation: 6-Layer-Architektur, alle Endpunkte, Auth, Event-System, State Machines, 12 Worker, Integrationen (3CX, Outlook, AI, Scraper).

## Schlüssel-Erkenntnisse (v2.4 Basis)

- Modularer Monolith mit Event Spine (kein Microservices in Phase 1)
- 10 absolute Regeln (tenant_id aus JWT, keine Hard Deletes, etc.)
- Dual 3CX-Integration: CRM Template + Webhook
- AI Governance mit 4 Policy-Stufen
- Backpressure: Hard Limits pro Tenant für AI/Embedding/Scraper Jobs
- SLOs definiert (99% API < 500ms, Call→History < 30s)

## Verlinkte Wiki-Seiten

[[backend-architektur]], [[event-system]], [[automationen]], [[berechtigungen]], [[ai-system]], [[telefonie-3cx]], [[email-system]], [[audit-2026-04-13-komplett]], [[audit-entscheidungen-2026-04-14]], [[status-enum-katalog]], [[datenbank-schema]]
