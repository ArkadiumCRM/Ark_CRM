---
title: "WebSocket-Channels"
type: concept
created: 2026-04-14
updated: 2026-04-14
sources: ["ARK_BACKEND_ARCHITECTURE_v2_5.md § A + websocket-publisher.worker.ts"]
tags: [websocket, realtime, channels, konvention]
---

# WebSocket-Channels — Namenskonvention

Alle Realtime-Channels folgen dem einheitlichen Schema:

```
<entity>:<scope>:<id>
```

**Tenant-Präfix:** Server prefix jedem Channel mit `tenant:{tenantId}:` vor Publish. Clients abonnieren ohne Tenant-Prefix (wird vom Gateway transparent injiziert).

## Entity-Channels

| Channel | Beispiel | Events |
|---------|----------|--------|
| `mandate:detail:{id}` | `mandate:detail:42` | stage_changed, option_added, terminated |
| `mandate:list` | (global) | created, status_changed |
| `account:detail:{id}` | `account:detail:17` | updated, protection_window_opened |
| `candidate:detail:{id}` | `candidate:detail:899` | assessment_added, presented |
| `process:detail:{id}` | `process:detail:1234` | stage_changed, placed |
| `process:pipeline:{mandateId}` | `process:pipeline:42` | pipeline-wide stage flows |
| `job:detail:{id}` | `job:detail:77` | filled, reopened |
| `assessment:order:{id}` | `assessment:order:9` | run_assigned, report_uploaded |
| `project:detail:{id}` | `project:detail:55` | participation_added, updated |
| `scraper:findings:live` | (global) | finding_detected, review_priority_set |
| `scraper:alerts:{severity}` | `scraper:alerts:critical` | alert_raised |

## Broadcast-Channels (ohne ID)

| Channel | Zweck |
|---------|-------|
| `user:{userId}:notifications` | Persönliche Reminders, Eskalationen |
| `tenant:dashboard` | Aggregierte KPIs, Temperatur-Änderungen |
| `tenant:audit:critical` | Kritische Audit-Events (Schutzfrist-Violation, Admin-Override) |

## Event-Payload-Struktur

```json
{
  "channel": "mandate:detail:42",
  "event": "stage_changed",
  "entity_id": 42,
  "actor_user_id": 7,
  "timestamp": "2026-04-14T10:23:45Z",
  "payload": { "from": "Aktiv", "to": "Abgebrochen", "...": "..." },
  "causation_id": "saga-tx3-abc123"
}
```

## Subscribe-Regeln

- Clients abonnieren nur Channels zu Entities, für die sie **Read-RBAC** haben ([[rbac-matrix]]).
- Server-seitige Authorization-Check pro Subscribe.
- Rate-Limit pro Client: 100 Events/Sekunde (Backpressure via Token-Bucket).

## Related

[[backend-architecture]], [[rbac-matrix]]
