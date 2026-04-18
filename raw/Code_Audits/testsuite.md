---
description: Automated test generation, execution and fix suggestions for ARK CRM — Backend + Frontend + E2E
model: claude-opus-4-6
---

Lies docs/TESTSUITE_PROMPT.md und führe die Automatisierte Testsuite v1.2 FINAL aus.

Phasenweise: Tests generieren → ausführen → Failures analysieren → Fixes vorschlagen.

Phase 0:  Inventory + Setup (Framework, Dependencies, Module, RLS-Status)
Phase 1:  Unit Tests (Zod-Schemas, State Machines, Policies + Feldlevel-Rechte + AI-Governance, Utils)
Phase 2:  Security Tests (RLS-Bypass mit getrennten DB-Rollen, Cross-Tenant inkl. Events/Jobs/Cache, JWT, SQL Injection, Input-Grenzen)
Phase 3:  Integration Tests (Services, Audit-Log-Integrität, Transaktionen, Concurrency, Soft-Delete-Kaskade + Unique Constraints)
Phase 4:  API Tests (Auth, Endpunkte, Fehlerformate, Webhooks inkl. Out-of-Order + Provider-Idempotenz)
Phase 5:  Worker Tests (Idempotenz, Retry, PgBoss: Singleton/Expiration/DLQ/Poison/Stuck, Tenant-Isolation in Jobs)
Phase 6:  Migration & Schema Smoke (From-Scratch, Inkrementell, Schema-Validierung, Stammdaten)
Phase 7:  DSGVO/nDSG Compliance (Anonymisierung inkl. JOINs, Datenexport, Retention, Testdaten-Sicherheit)
Phase 8:  Bulk/Edge/Performance Smoke (Bulk-Ops, Cache, Unicode, P95-Baseline, Noisy Neighbor, N+1)
Phase 9:  Frontend Tests (Stores, Hooks, Komponenten, Optimistic UI Rollback) — ⏭️ SKIP wenn kein Frontend
Phase 10: E2E Tests (Playwright User-Flows) — ⏭️ SKIP wenn nicht konfiguriert
Phase 11: Report + Deployment-Readiness + priorisierte Fix-Vorschläge

ARK-Pflichtprüfungen in JEDER Phase:
- tenant_id aus JWT, nie aus Body
- row_version bei Updates (Optimistic Locking)
- Soft Delete (deleted_at), kein Hard Delete
- Event-Emit bei jeder Mutation
- Audit-Log vollständig (actor, tenant, requestId, entity, action, alte/neue Werte)
- RLS-Policies auf DB-Ebene aktiv (getrennte Rollen: App-User vs. Owner)
- Feldlevel-Rechte pro Rolle

DB-Isolation (Regel 11, gestaffelt):
- Unit: kein DB | Integration Standard: Transaction Rollback (SET vor BEGIN!) |
  COMMIT/Lock/Worker/Migration: Testcontainers oder Schema-per-Worker |
  RLS-Rollen: getrennte DB-User | DELETE-Cleanup: nur letzter Fallback

Regel 12: Fastify inject() statt Supertest.
Regel 7:  Falls Kontext-Limit droht → stoppe nach aktueller Phase und melde.
Regel 8:  Bestehende Tests NICHT überschreiben.

Gib Report als EINEN kopierbaren Text. Keine Rückfragen.
