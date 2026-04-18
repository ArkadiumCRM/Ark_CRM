---
title: "Backend-Architektur"
type: concept
created: 2026-04-08
updated: 2026-04-08
sources: ["ARK_BACKEND_ARCHITECTURE_v2_4.md"]
tags: [concept, architecture, backend, technical]
---

# Backend-Architektur

Modularer Monolith mit Event Spine. Node.js / Fastify / TypeScript auf Railway.

## 10 Absolute Regeln

1. `tenant_id` NUR aus JWT — nie aus Request Body/Query
2. Business Write + Event Insert = immer EINE Transaktion
3. AI schreibt nie direkt in operative Tabellen
4. Kein Hard Delete — immer Soft Delete
5. Nie interne Errors/Stack Traces/DB-Schema an Client
6. PII-Felder maskiert in Logs
7. Rate Limiting auf allen Endpoints
8. Audit Log bei jedem State Change, Login, Error
9. API Versioning `/api/v1/` von Tag 1
10. SELECT nur benötigte Felder — kein `SELECT *`

## 6-Layer-Architektur

| Layer | Aufgabe |
|-------|---------|
| **API Layer** | HTTP, Auth, Role Checks, Validation. KEINE Business Logic |
| **Application Services** | Use Cases, Transaktionen, Event-Emission, Policies |
| **Domain / Policy** | State Machines, Regeln, Matching, Visibility |
| **Repository** | DB-Zugriff, Tenant-Safe Queries, Field Selection |
| **Worker** | Async Processing, Event Queue, Retry, 3rd-Party Calls |
| **Integration Adapter** | 3CX, Outlook, LLM, Scraper, Notifications |

## Auth & Sessions

- JWT: Access Token (15-60 Min) + Refresh Token (7-30 Tage, Rotation)
- Refresh Token: httpOnly + Secure + SameSite=Strict Cookie
- Access Token: JS Memory only (nicht localStorage)
- Electron: `electron.safeStorage`
- Multi-Role: `requireAnyRole()` Enforcement
- 5 Login-Versuche / 15 Min pro IP, Account Lock nach 5 Failures

## Concurrency

Optimistic Locking via `row_version`. Jeder PATCH/PUT muss Version mitschicken. Mismatch → HTTP 409 VERSION_CONFLICT. Centralized `updateWithVersion()` Helper.

## Middleware-Stack

| Middleware | Zweck |
|-----------|-------|
| auth | JWT Verification, Token Blacklist |
| tenant | tenant_id aus JWT in Context |
| role | `requireAnyRole()` |
| requestId | UUID pro Request |
| rateLimit | Global 100/15min, Auth 5/15min, AI 20/min, Upload 10/min |
| piiMask | PII-Redaktion in Logs |
| audit | Automatisches Audit Logging |
| errorHandler | Global Error Handler |

## Workers (12 in Phase 1)

1. **event-processor** — Liest Event Queue, führt Automationen aus
2. **ai** — Klassifizierung, Summaries, CV Parsing, Dossier
3. **embedding** — Text Chunking + pgvector Embeddings
4. **document** — OCR → CV Parsing → Embedding Pipeline
5. **threecx** — Call Events, Phone Lookup, Auto-History
6. **outlook** — Mail Sync, Thread-Zuordnung
7. **scraper** — Change Detection
8. **email** — Email-Versand mit Retry
9. **notification** — Push/In-App/SMS
10. **reminder** — Fällige Reminders
11. **retention** — PII Retention, Anonymisierung
12. **analytics** — View Refresh, Snapshots

## Error Handling

Custom Hierarchy: `AppError` → ValidationError(400), UnauthorizedError(401), ForbiddenError(403), NotFoundError(404), ConflictError(409), UnprocessableError(422)

DB-Error-Mapper: 23505 → Conflict, 23503 → Validation, 40001 → Retry

## SLOs

- 99% API < 500ms, 95% < 200ms
- Search/RAG < 2s
- Call → History: < 30s
- Transcript → Summary: < 3 Min
- Document Upload → Embedded: < 5 Min

## Related

- [[event-system]] — Event Spine Details
- [[datenbank-schema]] — DB-Struktur
- [[frontend-architektur]] — Frontend-Gegenstück
- [[berechtigungen]] — RBAC im Detail
- [[ai-system]] — AI-Integration und Governance
