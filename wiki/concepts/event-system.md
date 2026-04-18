---
title: "Event-System"
type: concept
created: 2026-04-08
updated: 2026-04-08
sources: ["ARK_DATABASE_SCHEMA_v1_2.md", "ARK_BACKEND_ARCHITECTURE_v2_4.md"]
tags: [concept, event, automation, architecture]
---

# Event-System

Das Herzstück der ARK-Architektur. Jede Zustandsänderung erzeugt ein Event, Events triggern Automationen.

## Drei Systeme

| System | Zweck | Tabelle |
|--------|-------|---------|
| **fact_history** | Was hat ein Mensch getan? | Anrufe, Emails, Meetings |
| **fact_event_queue** | Was hat das System ausgelöst? | Stage-Changes, Automationen |
| **fact_audit_log** | Was wurde konkret geändert? | Feld-Level Änderungen (INSERT only) |

## Outbox Pattern

**Absolute Regel:** Business Write + Event Insert = **immer eine Transaktion**.

```
BEGIN;
  UPDATE dim_candidates_profile SET stage = 'premarket' ...;
  INSERT INTO fact_event_queue (event_name, ...) VALUES ('candidate.stage_changed', ...);
COMMIT;
```

Events werden erst nach COMMIT konsumiert.

## Event-Kategorien (13)

candidate, process, job, mandate, call, email, document, scrape, system, match, jobbasket, reminder, account

## Idempotenz

- **Interne Events:** SHA-256 Hash `(event_name:entity_id:payload_hash)`
- **Externe Events:** `(tenant_id, source_system, source_event_id)` mit ON CONFLICT DO NOTHING

## Event Processor Worker

1. Pollt `fact_event_queue` (status=pending)
2. Lädt passende `dim_automation_rules`
3. Prüft Circuit Breaker (`max_triggers_per_hour/day`)
4. Führt Aktionen aus
5. Erstellt Follow-up PgBoss Jobs
6. Schreibt `fact_event_log` (immutabel)

## Circuit Breaker

Automation-Regeln haben `max_triggers_per_hour` und `max_triggers_per_day`. Verhindert Event-Stürme. Bei Auslösung: `system.circuit_breaker_tripped` Event + Admin-Alert.

## Event-Ketten-Nachverfolgung

Jedes Event hat:
- `causation_event_id` — Was hat dieses Event direkt ausgelöst?
- `correlation_id` — Zu welcher Gesamt-Kette gehört es?
- `parent_event_id` — Eltern-Event

**Frontend:** Event-Chain-Explorer pro Entity — kombinierte Timeline aus History + Events + Audit.
**Backend:** `GET /api/v1/entities/:type/:id/event-chain`

## Dead Letter Queue

Fehlgeschlagene Events landen in `*__dlq`. Monitoring: Alert wenn >5 in 15 Min. Admin kann retry/discard.

## Scheduled Jobs

| Job | Intervall | Zweck |
|-----|-----------|-------|
| cleanup-pii | Daily 2:00 | GDPR-Retention |
| refresh-powerbi | Alle 4h | Views aktualisieren |
| scrape-accounts | Mo-Fr 8:00 | Account-Monitoring |
| worker-heartbeat | Alle 5 Min | Health-Check |

## Complete Event List (Phase 1)

**Kandidat:** created, stage_changed, updated, deleted, merged, briefing_created, document_uploaded, assessment_completed, anonymized
**Prozess:** created, stage_changed, placement_done, closed, reopened, on_hold, rejected
**Job:** created, stage_changed, filled, cancelled, vacancy_detected, published
**Mandat:** created, stage_changed, completed, cancelled, activated
**Call:** received, transcript_ready, missed
**Email:** received, sent, bounced
**Dokument:** uploaded, cv_parsed, ocr_done, embedded, reparsed
**History:** created, ai_summary_ready
**Scraper:** change_detected, new_job_detected, person_left, new_person, role_changed
**Match:** score_updated, suggestion_ready
**Assessment:** completed, invite_sent, expired
**System:** data_quality_issue, circuit_breaker_tripped, dead_letter_alert, retention_action

## Related

- [[automationen]] — Die konkreten Trigger-Aktions-Paare
- [[history-system]] — Menschliche Aktivitäten
- [[debuggability]] — "Warum ist das passiert?"
- [[backend-architektur]] — Worker-Layer Details
