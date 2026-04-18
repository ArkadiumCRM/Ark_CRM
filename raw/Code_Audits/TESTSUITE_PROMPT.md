# ARK CRM — Automatisierte Testsuite v1.2 FINAL
# Verwendung: /project:testsuite
# Kontext: Claude Code — Agent mit Shell-Zugriff (bash wird TATSÄCHLICH ausgeführt)
# Scope: Backend + Frontend + E2E, phasenweise
# Changelog:
#   v1.0 — Initialer Entwurf
#   v1.1 — Feedback ChatGPT + Perplexity: RLS, Concurrency, DSGVO, Webhooks, PgBoss, inject()
#   v1.2 FINAL — Zweiter Review-Roundtrip: Migrations-Phase, Audit-Integrität,
#                Feldlevel-Rechte, Soft-Delete-Kaskade, AI-Governance, Tenant-Isolation
#                in Events/Jobs/Cache, Testcontainers-Empfehlung, Performance-Smoke

---

## METHODIK

Phasenweise Test-Generierung, Ausführung und Fix-Vorschläge.
Jede Phase: Tests schreiben → ausführen → Failures analysieren → Fixes vorschlagen.

### Regeln

1. **Ausführungspflicht:** Jeder generierte Test MUSS ausgeführt werden.
   Kein "sollte funktionieren" — nur grün oder rot zählt.

2. **Ergebnis-Notation:**
   - ✅ PASS — Test besteht
   - ❌ FAIL — Test schlägt fehl (mit Error-Output)
   - ⏭️ SKIP — Voraussetzung fehlt (z.B. keine Test-DB, kein Frontend)
   - 💀 ERROR — Test selbst hat Fehler (nicht der getestete Code)

3. **Fix-Vorschläge bei FAIL:**
   ```
   [FAIL-NNN] Test-Titel
   Datei: src/path/file.ts:42
   Erwartung: tenant_id wird aus JWT extrahiert
   Tatsächlich: tenant_id wird aus Request Body gelesen
   Fix:
     // VORHER
     const tenantId = req.body.tenant_id
     // NACHHER
     const tenantId = req.tenantContext.tenantId
   Impact: CRITICAL — Cross-Tenant Data Leak
   ```

4. **Test-Qualitätskriterien:**
   - Jeder Test testet EINE Sache (Single Assertion Principle)
   - Test-Name beschreibt das erwartete Verhalten auf Deutsch
   - Keine Abhängigkeiten zwischen Tests (isoliert, idempotent)
   - Cleanup nach jedem Test (DB-State, Mocks)
   - Keine Hardcoded IDs, Ports oder Timestamps

5. **ARK-spezifische Test-Patterns (IMMER prüfen):**
   - `tenant_id` aus JWT-Context, nie aus Body/Params
   - `row_version` bei jedem UPDATE (Optimistic Locking)
   - Soft Delete: `deleted_at IS NULL` in allen Queries
   - Stage-Machine: nur erlaubte Übergänge
   - Audit-Log: jede Mutation erzeugt einen vollständigen Eintrag
   - Event-Emit: jede Business-Aktion emittiert Event
   - RLS-Policies auf DB-Ebene aktiv (nicht nur Application-Level)
   - Feldlevel-Rechte: nicht jede Rolle sieht jedes Feld

6. **Priorisierung:** Sicherheitskritische Tests zuerst.
   Reihenfolge: Auth → Tenant-Isolation (inkl. RLS) → Business-Logic → Validierung → Edge Cases
   Phasenreihenfolge spiegelt diese Priorität: Security kommt VOR Integration.

7. **Output-Qualitäts-Guard:** Falls Kontext-Limit droht (>20'000 Tokens generiert),
   stoppe nach der aktuellen Phase und melde:
   "⚠️ Kontext-Limit — Phase X-Y ausstehend, bitte `/project:testsuite` erneut ausführen."

8. **Kein Überschreiben:** Bestehende Tests in `src/**/*.test.ts` oder `tests/**` werden
   NICHT überschrieben. Neue Tests werden ergänzt (Suffix `_generated.test.ts` wenn nötig).

9. **Realistische Testdaten:** Schweizer Kontext verwenden:
   - Namen: "Hans Muster", "Anna Beispiel" (keine englischen Dummy-Namen)
   - Adressen: "Bahnhofstrasse 1, 8001 Zürich"
   - Währung: CHF mit Apostrophe (z.B. `120'000`)
   - Datum: dd.MM.yyyy / ISO für DB
   - Telefon: +41 Format
   - **KEINE echten Produktionsdaten in die Test-DB** (nDSG/DSGVO Art. 6(4)(e))

10. **Abhängigkeiten prüfen:** Vor Phase 1, prüfe ob die nötigen Test-Dependencies
    installiert sind. Falls nicht → installiere sie automatisch.

11. **DB-Isolation (Staffelung):**
    - **Unit Tests:** Keine DB.
    - **Integration/API Standard:** Transaction Rollback pro Test auf dediziertem Client.
    - **COMMIT/Lock/Worker/PgBoss/Migrations/RLS-Rollen:** Testcontainers (ephemere Postgres)
      oder Schema-per-Worker. DELETE-Cleanup nur als letzter Fallback.
    - **RLS-Tests:** Getrennte DB-Rollen (App-User vs. Owner-User), nicht nur App Pool.

12. **Fastify inject() statt Supertest.** Kein Port-Binding nötig, keine Port-Konflikte,
    schneller als echte HTTP-Requests. Supertest nur als Fallback wenn inject() nicht möglich.

---

## PHASE 0: INVENTORY & SETUP

```bash
echo "========================================="
echo "  TESTSUITE INVENTORY — $(date -I)"
echo "========================================="

# 1. Bestehende Tests zählen
echo ""
echo "=== Bestehende Tests ==="
EXISTING_TESTS=$(find ./src ./tests -name "*.test.ts" -o -name "*.spec.ts" 2>/dev/null | wc -l)
echo "Test-Dateien: $EXISTING_TESTS"
find ./src ./tests -name "*.test.ts" -o -name "*.spec.ts" 2>/dev/null | head -20

# 2. Test-Framework erkennen
echo ""
echo "=== Test-Framework ==="
if npm ls vitest 2>/dev/null | grep -q "vitest"; then
  echo "✅ Vitest installiert"
  RUNNER="vitest"
elif npm ls jest 2>/dev/null | grep -q "jest"; then
  echo "✅ Jest installiert"
  RUNNER="jest"
else
  echo "❌ Kein Test-Framework — wird installiert (Vitest)"
  RUNNER="none"
fi

# 3. Test-Config prüfen
echo ""
echo "=== Test-Config ==="
[ -f vitest.config.ts ] && echo "✅ vitest.config.ts" || echo "➖ vitest.config.ts fehlt"
[ -f jest.config.ts ]   && echo "✅ jest.config.ts"   || echo "➖ jest.config.ts fehlt"
[ -f playwright.config.ts ] && echo "✅ playwright.config.ts" || echo "➖ playwright.config.ts fehlt"

# 4. Testbare Module identifizieren
echo ""
echo "=== Testbare Module ==="
echo "Zod Schemas:";     grep -rl 'z\.object\|z\.string\|z\.enum' src/ --include="*.ts" 2>/dev/null | grep -v node_modules | grep -v '.test.' | wc -l
echo "Services:";        find src/ -name "*.service.ts" 2>/dev/null | wc -l
echo "Repositories:";    find src/ -name "*.repository.ts" -o -name "*.repo.ts" 2>/dev/null | wc -l
echo "Routes:";          find src/ -name "*.routes.ts" -o -name "*.route.ts" 2>/dev/null | wc -l
echo "Workers:";         find src/ -name "*.worker.ts" 2>/dev/null | wc -l
echo "Policies:";        find src/ -name "*.policy.ts" 2>/dev/null | wc -l
echo "State Machines:";  grep -rl 'ALLOWED_TRANSITIONS\|StateMachine\|validTransition' src/ --include="*.ts" 2>/dev/null | wc -l
echo "Middleware:";       find src/ -name "*.middleware.ts" -o -path "*/middleware/*.ts" 2>/dev/null | wc -l
echo "Webhooks:";        find src/ -path "*webhook*" -o -path "*3cx*" -o -path "*outlook*" 2>/dev/null | wc -l
echo "Migrations:";      find src/ -path "*migration*" -o -path "*migrate*" 2>/dev/null | wc -l; ls migrations/*.sql 2>/dev/null | wc -l

# 5. Frontend prüfen
echo ""
echo "=== Frontend ==="
if [ -d "../frontend/src" ] || [ -d "./frontend/src" ]; then
  FRONTEND_PATH=$([ -d "../frontend/src" ] && echo "../frontend" || echo "./frontend")
  echo "✅ Frontend gefunden: $FRONTEND_PATH"
  echo "Components:"; find "$FRONTEND_PATH/src" -name "*.tsx" 2>/dev/null | wc -l
  echo "Stores:";     find "$FRONTEND_PATH/src" -name "*.store.ts" -o -name "*.store.tsx" 2>/dev/null | wc -l
  echo "Hooks:";      find "$FRONTEND_PATH/src" -name "use*.ts" -o -name "use*.tsx" 2>/dev/null | wc -l
else
  echo "⏭️ Kein Frontend-Verzeichnis gefunden — Frontend-Tests werden übersprungen"
fi

# 6. DB-Verbindung prüfen
echo ""
echo "=== Test-DB ==="
if [ -n "$TEST_DATABASE_URL" ]; then
  echo "✅ TEST_DATABASE_URL gesetzt"
elif [ -n "$DATABASE_URL" ]; then
  echo "⚠️ Nur DATABASE_URL gesetzt — ACHTUNG: Tests laufen gegen Haupt-DB!"
  echo "   Empfehlung: Setze separate TEST_DATABASE_URL"
else
  echo "⚠️ Keine DATABASE_URL — Integration/API Tests brauchen DB-Zugang"
fi

# 7. RLS-Status prüfen
echo ""
echo "=== RLS-Status ==="
DB_URL="${TEST_DATABASE_URL:-$DATABASE_URL}"
if [ -n "$DB_URL" ]; then
  RLS_DISABLED=$(psql "$DB_URL" -t -c "
    SELECT string_agg(c.relname::text, ', ')
    FROM pg_class c
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE n.nspname = 'ark'
      AND c.relkind = 'r'
      AND NOT c.relrowsecurity
  " 2>/dev/null || echo "N/A")
  if [ -n "$RLS_DISABLED" ] && [ "$RLS_DISABLED" != "N/A" ]; then
    echo "❌ Tabellen OHNE RLS: $RLS_DISABLED"
  else
    echo "✅ Alle ark-Tabellen haben RLS aktiviert (oder DB nicht erreichbar)"
  fi
else
  echo "⏭️ Keine DB-URL — RLS-Check übersprungen"
fi

# 8. Package.json Scripts
echo ""
echo "=== npm Scripts ==="
grep -E '"test|"vitest|"jest|"playwright' package.json 2>/dev/null || echo "Keine Test-Scripts definiert"
```

### SETUP (falls nötig)

```bash
# Vitest (NICHT Supertest — wir nutzen Fastify inject())
npm install -D vitest @vitest/coverage-v8
```

Erstelle `vitest.config.ts` falls nicht vorhanden (Projekt-basierte Trennung):

```typescript
import { defineConfig } from 'vitest/config'
import path from 'path'

export default defineConfig({
  test: {
    globals: true,
    environment: 'node',
    coverage: {
      provider: 'v8',
      reporter: ['text', 'text-summary'],
      include: ['src/**/*.ts'],
      exclude: ['src/**/*.test.ts', 'src/**/*.d.ts', 'src/**/index.ts']
    },
    testTimeout: 10000,
    hookTimeout: 10000,
    projects: [
      {
        test: {
          name: 'unit',
          include: ['src/**/*.unit.test.ts', 'tests/unit/**/*.test.ts'],
          pool: 'threads',
          isolate: true,
        }
      },
      {
        test: {
          name: 'security',
          include: ['src/**/*.security.test.ts', 'tests/security/**/*.test.ts'],
          pool: 'forks',
          poolOptions: { forks: { singleFork: true } },
          setupFiles: ['tests/helpers/db-setup.ts'],
        }
      },
      {
        test: {
          name: 'integration',
          include: ['src/**/*.integration.test.ts', 'tests/integration/**/*.test.ts'],
          pool: 'forks',
          poolOptions: { forks: { singleFork: true } },
          setupFiles: ['tests/helpers/db-setup.ts'],
        }
      },
      {
        test: {
          name: 'api',
          include: ['src/**/*.api.test.ts', 'tests/api/**/*.test.ts'],
          pool: 'forks',
          poolOptions: { forks: { singleFork: true } },
          setupFiles: ['tests/helpers/server-setup.ts'],
        }
      },
      {
        test: {
          name: 'worker',
          include: ['src/**/*.worker.test.ts', 'tests/workers/**/*.test.ts'],
          pool: 'forks',
          poolOptions: { forks: { singleFork: true } },
        }
      },
      {
        test: {
          name: 'migration',
          include: ['tests/migration/**/*.test.ts'],
          pool: 'forks',
          poolOptions: { forks: { singleFork: true } },
        }
      },
      {
        test: {
          name: 'compliance',
          include: ['src/**/*.compliance.test.ts', 'tests/compliance/**/*.test.ts'],
          pool: 'forks',
          poolOptions: { forks: { singleFork: true } },
          setupFiles: ['tests/helpers/db-setup.ts'],
        }
      },
      {
        test: {
          name: 'edge',
          include: ['src/**/*.edge.test.ts', 'tests/edge/**/*.test.ts'],
          pool: 'forks',
          poolOptions: { forks: { singleFork: true } },
          setupFiles: ['tests/helpers/db-setup.ts'],
        }
      }
    ]
  },
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src')
    }
  }
})
```

---

## PHASE 1: UNIT TESTS

*Ziel: Alle reinen Logik-Einheiten testen — ohne DB, ohne Netzwerk, ohne externe Services.*
*Pool: threads (vollständig parallel)*

### 1A. Zod-Schema-Validierung

Für JEDES Zod-Schema in der Codebase:

```
Suche: grep -rl 'z\.object\|z\.enum\|z\.union' src/ --include="*.ts" | grep -v test
```

Pro Schema teste:
- ✅ Valider Input wird akzeptiert (Happy Path)
- ❌ Fehlender Pflichtfeld wird rejected
- ❌ Falscher Typ wird rejected (string statt number, etc.)
- ❌ Zu langer String wird rejected (falls maxLength definiert)
- ❌ UUID-Format wird validiert (keine beliebigen Strings)
- ❌ Enum-Werte: ungültiger Wert wird rejected
- 🔒 Extra-Felder werden gestripped (kein `.passthrough()` auf User-Input)

**ARK-spezifisch:**
- `tenant_id` darf NIE im Create/Update-Schema sein (kommt aus JWT)
- `row_version` muss im Update-Schema PFLICHT sein
- `deleted_at` darf NIE im Create-Schema sein

### 1B. Statusmaschinen

```
Suche: grep -rl 'ALLOWED_TRANSITIONS\|StateMachine\|validTransition\|STAGES' src/ --include="*.ts"
```

Pro State Machine teste:
- ✅ Jeder erlaubte Übergang funktioniert
- ❌ Jeder verbotene Übergang wirft Fehler
- ❌ Ungültiger Status-Wert wirft Fehler
- ✅ Initialstatus ist definiert
- ✅ Endstatus hat keine ausgehenden Übergänge

**ARK State Machines (aus Architecture v2.5):**
- Candidate Stage: NEW → IDENTIFIED → CONTACTED → INTERESTED → INTERVIEW → SHORTLIST → PRESENTED → PLACED / REJECTED / WITHDRAWN
- Mandate Stage: DRAFT → ACTIVE → ON_HOLD → FILLED → CANCELLED
- Process Stage: LONGLIST → SHORTLIST → INTERVIEW → OFFER → PLACED / REJECTED / WITHDRAWN

### 1C. Policies & Feldlevel-Rechte

```
Suche: find src/ -name "*.policy.ts"
```

**Basis-Rollen-Tests:**
- ✅ Erlaubte Rolle + Aktion → genehmigt
- ❌ Verbotene Rolle + Aktion → verweigert
- ❌ Fehlende Rolle → verweigert

**AI-Governance / AI-Write-Policy:**
- ❌ AI-Service versucht in Core-Feld (`first_name`, `stage`) zu schreiben → rejected
- ✅ AI-Service schreibt in AI-Feld (`ai_summary`, `ai_matching_score`) → erlaubt
- ❌ AI-Service versucht Stage zu ändern → rejected (nur über Stage-Machine)
- ❌ AI-Folgejob Rate-Limit: >X AI-Jobs pro Tenant/Minute → gedrosselt

**Feldlevel-Rechte (rollenbasiert):**
- ❌ RESEARCHER sieht Kandidat-Grunddaten, aber NICHT Gehalt oder vertrauliche PII
- ❌ CANDIDATE_MANAGER sieht Gehalt, aber NICHT Admin-Felder
- ❌ Schreibrechte nach Workflow-Status: z.B. Offer-Details nur bei Stage ≥ OFFER bearbeitbar
- ❌ Export-Recht: nur bestimmte Rollen dürfen Datenexport auslösen
- ❌ Bulk-Update-Recht: nur bestimmte Rollen dürfen Bulk-Operationen ausführen
- ❌ Anonymisierungs-Recht: nur ADMIN darf anonymisieren
- ❌ Restore-Recht: nur ADMIN darf Soft-Deleted Einträge wiederherstellen

### 1D. Utility-Funktionen

```
Suche: find src/ -name "*.util.ts" -o -name "*.helper.ts" -o -name "utils" -type d
```

Pro Utility teste:
- Edge Cases: leere Strings, null, undefined, Extremwerte
- Schweizer Formate: CHF-Formatierung, Telefonnummern, PLZ
- Collation: `ä` sortiert korrekt nach `a` (nicht nach `z`) bei `de_CH` Locale

### Phase 1 Ausführung

```bash
echo "🧪 Phase 1: Unit Tests"
npx vitest run --project unit --reporter=verbose 2>&1
```

---

## PHASE 2: SECURITY TESTS

*Ziel: Aktive Sicherheitstests — RLS, Cross-Tenant, Injection, Token-Manipulation.*
*VORGEZOGEN: Wenn Tenant-Isolation kaputt ist, sind alle nachfolgenden Tests irrelevant.*
*Pool: forks, seriell (singleFork)*

### 2A. RLS-Bypass-Tests (HÖCHSTE PRIORITÄT)

Supabase RLS ist die letzte Verteidigungslinie. Prüfe auf DB-Ebene.
**WICHTIG:** RLS-Tests brauchen GETRENNTE DB-Rollen — App-User UND Owner-User separat testen.

- ✅ RLS ist auf ALLEN Tabellen mit `tenant_id` aktiviert
- ❌ Direkter SQL-Query mit App-User-Rolle ohne gesetzten `app.current_tenant` → gibt 0 Rows zurück
- ❌ RLS-Policy greift auch bei JOINs über mehrere Tabellen
- ❌ `BYPASSRLS`-Rechte existieren NUR auf dem Owner-User, NICHT auf dem App-User
- ❌ Subquery in WHERE-Klausel umgeht RLS nicht
- ❌ App-User kann NICHT `SET ROLE` zu Owner-User wechseln

```typescript
// Test-Pattern: getrennte DB-Rollen
describe('RLS Bypass Prevention', () => {
  // appUserPool: Pool mit eingeschränkten Rechten (wie Production)
  // ownerPool: Pool mit vollen Rechten (nur für Setup/Teardown)

  it('sollte ohne app.current_tenant keine Daten zurückgeben', async () => {
    // Setup: Daten mit Owner-Rolle einfügen
    await ownerPool.query('INSERT INTO ark.dim_candidates_profile ...')
    // Test: App-User ohne Tenant-Context
    const result = await appUserPool.query('SELECT * FROM ark.dim_candidates_profile')
    expect(result.rows).toHaveLength(0)
  })

  it('sollte bei JOINs über Tabellen keine fremden Daten leaken', async () => {
    await appUserPool.query("SET app.current_tenant = $1", [tenantB])
    const result = await appUserPool.query(`
      SELECT c.* FROM ark.dim_candidates_profile c
      JOIN ark.fact_processes p ON p.candidate_id = c.id
      WHERE p.id = $1
    `, [processOfTenantA])
    expect(result.rows).toHaveLength(0)
  })
})
```

### 2B. Cross-Tenant Isolation (Application-Level)

Pro Entität (Kandidaten, Accounts, Contacts, Mandate, Prozesse):
- ❌ GET /entity/:id mit fremder Tenant-ID → 404 (NICHT 403! — kein Information Leak)
- ❌ GET /entities (List) → zeigt NUR eigene Daten
- ❌ PUT /entity/:id mit fremder Tenant-ID → 404
- ❌ DELETE /entity/:id mit fremder Tenant-ID → 404

**Subtile Varianten:**
- ❌ Body enthält `tenant_id` von Tenant B, Token ist Tenant A → `tenant_id` aus JWT gewinnt
- ❌ Query-Parameter `?tenant_id=B` → wird ignoriert
- ❌ Nested Resource: `/accounts/:accountId/contacts` mit Account von anderem Tenant → 404

**Tenant-Isolation in Events, Jobs und Cache:**
- ❌ Event-Payload (Outbox) enthält NIE Daten eines anderen Tenants
- ❌ Background-Jobs tragen `tenant_id` zwingend im Job-Payload/Context
- ❌ Webhook-Verarbeitung ordnet eingehende Events nicht tenantübergreifend zu
- ❌ Backend-Cache-Keys sind tenantgebunden (nicht nur Frontend Query Keys)
- ❌ Search/Fulltext-Indizes liefern keine tenantübergreifenden Resultsets

### 2C. SQL-Injection-Tests

```
Suche: grep -rn 'query.*`.*\${' src/ --include="*.ts"
```

- ❌ Input: `'; DROP TABLE ark.dim_candidates_profile; --` → kein Effekt
- ❌ Input: `' OR '1'='1` → gibt nicht alle Datensätze zurück
- ❌ Input in ORDER BY: `name; DROP TABLE` → kein Effekt
- ❌ Input in LIKE: `%` → gibt nicht alle Datensätze zurück (oder bewusst erlaubt)

### 2D. JWT-Manipulation

- ❌ Token mit geändertem `role` Claim → wird rejected (Signatur ungültig)
- ❌ Token mit geändertem `tenant_id` → wird rejected
- ❌ Token mit `alg: none` → wird rejected
- ❌ Abgelaufener Token → 401
- ❌ Token mit unbekanntem Issuer → 401
- ❌ Leerer Bearer Header → 401

### 2E. Input-Grenzen

- ❌ 10 MB Body → 413 Payload Too Large (nicht OOM!)
- ❌ 10'000 Zeichen im Namensfeld → rejected (Zod maxLength)
- ❌ Deeply Nested JSON (100 Ebenen) → rejected
- ❌ Unicode-Tricks: `\u0000` Null-Bytes → sanitized
- ❌ File Upload mit `.exe` Extension → rejected
- ❌ File Upload mit falscher MIME (z.B. `.jpg` mit `application/x-executable`) → rejected
- ❌ Path-Traversal in Dateinamen: `../../etc/passwd` → sanitized

### Phase 2 Ausführung

```bash
echo "🧪 Phase 2: Security Tests"
npx vitest run --project security --reporter=verbose 2>&1
```

---

## PHASE 3: INTEGRATION TESTS

*Ziel: Service-Layer gegen echte DB testen — Transaktionen, Events, Audit-Logs, Concurrency.*
*Pool: forks, seriell (singleFork)*

### Voraussetzung

```bash
if [ -z "$TEST_DATABASE_URL" ] && [ -z "$DATABASE_URL" ]; then
  echo "⏭️ Phase 3 übersprungen — keine Test-DB konfiguriert"
fi
```

### DB-Isolation: Transaction Rollback (Default-Pattern)

```typescript
// tests/helpers/test-transaction.ts
import { Pool, PoolClient } from 'pg'

export function withTestTransaction(pool: Pool, ctx: { tenantId: string }) {
  let client: PoolClient

  beforeEach(async () => {
    client = await pool.connect()
    // WICHTIG: RLS-Context MUSS vor BEGIN gesetzt werden (Session-Level),
    // damit RLS auch innerhalb des Test-Rollback-Patterns funktioniert.
    // SET LOCAL würde nur innerhalb der inneren Transaktion gelten.
    await client.query('SET app.current_tenant = $1', [ctx.tenantId])
    await client.query('BEGIN')
    await client.query('SAVEPOINT test_start')
  })

  afterEach(async () => {
    await client.query('ROLLBACK')
    // RLS-Context zurücksetzen
    await client.query('RESET app.current_tenant')
    client.release()
  })

  return () => client
}
```

**Für Tests die COMMIT brauchen** (Transaktions-Tests, Locking, PgBoss):
Schema-per-Worker oder Testcontainers (siehe Anhang E).

### 3A. Service-Layer Tests

Pro Service teste:
- ✅ Create → Datensatz in DB + Event emittiert + Audit-Log geschrieben
- ✅ Update → `row_version` inkrementiert + Event emittiert
- ❌ Update mit falschem `row_version` → 409 Conflict
- ✅ Soft Delete → `deleted_at` gesetzt, Datensatz nicht mehr in List-Queries
- ❌ Cross-Tenant → Service mit Tenant A kann Daten von Tenant B NICHT lesen
- ✅ Restore nach Soft Delete → `deleted_at` zurückgesetzt

**Event-Emit verifizieren mit Event-Spy:**

```typescript
// tests/helpers/event-spy.ts
export function createEventSpy(eventService: EventService) {
  const events: Array<{ name: string; payload: any; timestamp: Date }> = []

  const originalEmit = eventService.emit.bind(eventService)
  eventService.emit = async (name: string, payload: any, ctx: any, trx?: any) => {
    events.push({ name, payload, timestamp: new Date() })
    return originalEmit(name, payload, ctx, trx)
  }

  return {
    events,
    expectEvent: (name: string) => {
      const found = events.find(e => e.name === name)
      expect(found, `Event "${name}" wurde nicht emittiert`).toBeDefined()
      return found!.payload
    },
    expectNoEvent: (name: string) => {
      expect(events.find(e => e.name === name),
        `Event "${name}" wurde unerwartet emittiert`).toBeUndefined()
    },
    reset: () => { events.length = 0 }
  }
}
```

### 3B. Audit-Log-Integrität

- ✅ Jeder Audit-Eintrag enthält: `actor`, `tenant_id`, `request_id`, `entity_type`, `entity_id`, `action`
- ✅ Bei UPDATE: alte und neue Werte werden gespeichert (wo erlaubt)
- ❌ Sensitive Felder (Passwort-Hash) erscheinen NICHT im Audit-Log Klartext
- ❌ Bei Rollback: KEIN Audit-Eintrag (Audit + Business-Write in gleicher Transaktion)
- ✅ Reihenfolge konsistent: Business-Write → Audit-Write → Event-Emit (alles in einer Transaktion)
- ✅ Bulk-Operationen erzeugen vollständige Audit-Trails (ein Eintrag pro betroffener Entität)
- ❌ Audit-Log ist append-only: kein UPDATE oder DELETE auf `fact_audit_log` möglich

### 3C. Transaktions-Tests (Schema-per-Worker oder Testcontainers, kein Rollback)

- ✅ Erfolgreicher Multi-Write: Business-Write + Event + Audit in EINER Transaktion
- ❌ Fehler in der Mitte → ALLES wird zurückgerollt (kein Partial Write)
- ❌ DB-Connection-Fehler → sauberer Rollback, kein hängender Lock

### 3D. Concurrency / Race Conditions

- ❌ Zwei parallele UPDATEs auf denselben Datensatz → genau einer gewinnt, 409 für den anderen
- ❌ Gleichzeitiger Stage-Change auf denselben Kandidaten → nur einer durchkommt
- ❌ Deadlock-Erkennung: Zwei Transaktionen locken sich gegenseitig → sauberer Retry
- ❌ Parallel Create mit identischem Unique-Constraint → genau einer gewinnt, 409 für den anderen

```typescript
it('sollte bei parallelen Updates nur einen durchlassen', async () => {
  const candidate = await createTestCandidate(ctx)
  const [result1, result2] = await Promise.allSettled([
    candidateService.update(candidate.id, { current_position: 'Bauleiter' }, ctx, candidate.row_version),
    candidateService.update(candidate.id, { current_position: 'Projektleiter' }, ctx, candidate.row_version),
  ])
  const fulfilled = [result1, result2].filter(r => r.status === 'fulfilled')
  const rejected = [result1, result2].filter(r => r.status === 'rejected')
  expect(fulfilled).toHaveLength(1)
  expect(rejected).toHaveLength(1)
  expect((rejected[0] as PromiseRejectedResult).reason.statusCode).toBe(409)
})
```

### 3E. Soft-Delete Kaskade & Randfälle

- ❌ Soft Delete Account → was passiert mit zugehörigen Contacts + Mandates? (kaskadiert ODER verhindert — definiertes Verhalten)
- ❌ Restore Account → werden abhängige Entities auch restored?
- ❌ Soft Delete Kandidat mit laufendem Prozess → definiertes Verhalten
- ❌ Unique Constraint nach Soft Delete: z.B. Email-1 wird frei → neuer Kandidat mit gleicher Email → kein Constraint-Fehler
- ❌ Unique Constraint nach Restore: Restore eines Kandidaten dessen Email inzwischen von neuem Kandidaten belegt wird → Fehler
- ❌ JOINs auf soft-deleted Eltern/Kinder → korrekt gehandhabt
- ❌ Aggregationen (COUNT, SUM) ignorieren soft-deleted Datensätze konsistent
- ❌ Background-Jobs dürfen soft-deleted Entitäten nicht mehr verarbeiten

### 3F. Repository-Tests

- ✅ Pagination: `limit` + `offset` korrekt, Gesamtzahl stimmt
- ✅ Filter: Jeder Filter-Parameter filtert korrekt
- ❌ List-Query ohne Tenant-Filter → darf NICHT alle Tenants zurückgeben
- ✅ Sort: Sortierung funktioniert, Collation `de_CH` (ä sortiert nach a, nicht nach z)

### Phase 3 Ausführung

```bash
echo "🧪 Phase 3: Integration Tests"
npx vitest run --project integration --reporter=verbose 2>&1
```

---

## PHASE 4: API TESTS

*Ziel: HTTP-Endpunkte testen — Auth, Validierung, Fehlerformate, Webhooks.*
*Nutze fastify.inject() — KEIN Supertest, kein Port-Binding.*

### Fastify Test-Server Setup

```typescript
// tests/helpers/test-server.ts
import { buildApp } from '@/app'

let app: FastifyInstance

export async function getTestServer(): Promise<FastifyInstance> {
  if (!app) {
    app = await buildApp({ logger: false })
    await app.ready()
  }
  return app
}

export async function closeTestServer() {
  if (app) {
    await app.close()
    app = null!
  }
}
```

### 4A. Auth-Tests (HÖCHSTE PRIORITÄT)

- ✅ Login mit gültigen Credentials → 200 + JWT
- ❌ Login mit falschem Passwort → 401, KEIN Hinweis ob User existiert
- ❌ Login mit nicht-existentem User → 401, GLEICHE Fehlermeldung
- ✅ Token Refresh → neues Access Token, altes wird invalidiert
- ❌ Refresh mit abgelaufenem Token → 401
- ❌ Refresh mit manipuliertem Token → 401
- ❌ Zugriff ohne Token → 401 auf allen geschützten Routen
- ❌ Zugriff mit Token von gelöschtem User → 401/403
- ❌ Rate Limiting: 10x falscher Login → 429 Too Many Requests
- ❌ Replay Attack: Token nach Logout wiederverwenden → 401

### 4B. Endpunkt-Tests (pro Modul, via fastify.inject())

- ✅ Happy Path: gültiger Request → erwarteter Statuscode + Response-Format
- ❌ Fehlender Pflichtfeld → 422 mit Feldname im Error
- ❌ Ungültiger UUID-Parameter → 422 (nicht 500!)
- ❌ Nicht-existente Ressource → 404
- ❌ Falsche Rolle → 403
- ❌ Falscher Tenant → 404 (KEIN Unterschied ob Ressource existiert!)
- ❌ Doppelter Unique-Wert → 409 Conflict
- ✅ Response enthält KEINE Felder die der User laut Feldlevel-Rechten nicht sehen darf

**ARK-spezifisch:**
- Response-Format: `{ data, meta, pagination? }` konsistent
- Pagination: `page`, `pageSize`, `totalCount`, `totalPages`
- Request-ID in Response-Header

### 4C. Error-Response-Format

JEDER Fehler muss dieses Format haben:
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Menschenlesbare Nachricht",
    "details": [...],
    "requestId": "uuid"
  }
}
```

Teste: KEIN Stack Trace in Production-Responses (NODE_ENV=production)

### 4D. Webhook-/Integrations-Endpunkte (3CX, Outlook)

- ✅ Gültige Webhook-Signatur → 200, Payload wird verarbeitet
- ❌ Ungültige Signatur → 401/403
- ❌ Replay-Schutz: gleicher Webhook mit identischem Timestamp/Nonce 2× → idempotent
- ❌ Malformed Payload: ungültiges JSON → 400
- ❌ Fehlende Pflichtfelder im Payload → 422
- ✅ Verarbeitung >5s → sofort 200, async weiterverarbeiten
- ❌ Out-of-Order Events: Event B kommt vor Event A → System verarbeitet korrekt oder queued
- ❌ Doppelte Events mit abweichendem Payload → Provider-Event-ID als Idempotency Key
- ❌ Clock Skew bei Timestamp-Validierung: ±5min Toleranz
- ❌ Externe IDs unbekannt oder mehrfach → saubere Fehlerbehandlung

### Phase 4 Ausführung

```bash
echo "🧪 Phase 4: API Tests"
npx vitest run --project api --reporter=verbose 2>&1
```

---

## PHASE 5: WORKER TESTS

*Ziel: Asynchrone Job-Verarbeitung — Idempotenz, Retry, PgBoss-spezifisch.*
*Pool: forks, seriell*

### 5A. Idempotenz

- ✅ Gleicher Event 2× verarbeitet → keine doppelte Aktion
- ✅ Worker prüft ob Aktion bereits durchgeführt wurde

### 5B. Retry & Error-Handling

- ✅ Transienter Fehler (DB-Timeout) → automatischer Retry mit Backoff
- ✅ Permanenter Fehler (ungültige Daten) → nach X Retries in Dead Letter Queue
- ❌ Worker-Crash → Job bleibt in Queue, wird von neuem Worker aufgenommen
- ✅ Circuit Breaker: externer Service dauerhaft down → Breaker öffnet

### 5C. PgBoss-spezifisch

- ✅ Job-Expiration: Job läuft über `expireInMinutes` hinaus → `failed`
- ❌ Singleton-Jobs: gleicher Job-Name wird nicht doppelt eingefügt
- ✅ Dead Letter Queue: fehlgeschlagene Jobs landen in DLQ mit Error-Details
- ✅ Graceful Shutdown: `boss.stop()` wartet auf laufende Jobs
- ❌ Queue-Monitoring: DLQ hat Einträge → Monitoring-Event/Alert
- ❌ Duplicate Assignment: gleicher Job nicht an 2 Worker gleichzeitig
- ❌ Poison Job: Job der immer fehlschlägt → landet nach max Retries in DLQ, blockiert Queue nicht
- ❌ Stuck Job: Job der weder succeeded noch failed → Expiration greift

### 5D. Timeouts

- ❌ LLM-Request dauert >30s → Timeout, Job wird retried
- ❌ DB-Query dauert >10s → Timeout
- ✅ Heartbeat: langläufiger Job meldet sich regelmässig

### 5E. Tenant-Isolation in Jobs

- ❌ Job-Payload enthält immer `tenant_id`
- ❌ Worker setzt Tenant-Context vor Verarbeitung
- ❌ Job-Failure eines Tenants beeinflusst nicht die Queue anderer Tenants

### Phase 5 Ausführung

```bash
echo "🧪 Phase 5: Worker Tests"
npx vitest run --project worker --reporter=verbose 2>&1
```

---

## PHASE 6: MIGRATION & SCHEMA SMOKE

*Ziel: Datenbankmigrationen und Schema-Integrität testen.*
*Empfohlen: Testcontainers oder Template-DB (nicht Schema im gleichen Cluster).*

### 6A. Migration-Integrität

- ✅ Migration from scratch auf leerer DB → alle Tabellen, Indizes, RLS, Trigger vorhanden
- ✅ Migration von N-1 auf aktuell → kein Fehler
- ❌ Migration ist idempotent (falls wiederholbar konzipiert): 2× ausführen → kein Fehler
- ❌ Rollback/Failure: fehlschlagende Migration hinterlässt keine halben Zustände

### 6B. Schema-Validierung nach Migration

- ✅ Alle Tabellen im `ark` Schema existieren
- ✅ RLS ist auf allen relevanten Tabellen aktiviert (nach Migration!)
- ✅ Alle erwarteten Indizes existieren (inkl. pg_trgm für Suche)
- ✅ Alle erwarteten Trigger existieren
- ✅ Alle Constraints (FK, Unique, Check) sind vorhanden
- ✅ Extensions (uuid-ossp, pg_trgm, etc.) sind installiert

### 6C. Seed-Daten / Stammdaten

- ✅ Stammdaten (dim_focus, dim_functions, etc.) sind nach Migration vorhanden und vollständig
- ✅ Stammdaten stimmen mit Stammdaten-Dokument überein
- ❌ Stammdaten-Duplikate werden verhindert (Unique Constraints)

### Phase 6 Ausführung

```bash
echo "🧪 Phase 6: Migration & Schema Smoke"
npx vitest run --project migration --reporter=verbose 2>&1
```

---

## PHASE 7: DSGVO / nDSG COMPLIANCE TESTS

*Ziel: Datenschutz-relevante Funktionen — Anonymisierung, Export, Retention, Consent.*

### 7A. Anonymisierung

- ✅ Nach `POST /candidates/:id/anonymize`: alle PII-Felder genullt
- ✅ `anonymized_at` ist gesetzt
- ❌ Anonymisierte Daten sind auch über JOINs nicht mehr rekonstruierbar
  (Audit-Log, History, Prozess-Zuordnungen)
- ✅ Audit-Log enthält `action: 'ANONYMIZE'`
- ✅ Event `candidate.anonymized` wurde emittiert
- ❌ Anonymisierter Kandidat taucht nicht mehr in Search-Resultaten auf

### 7B. Datenexport (Art. 15 DSGVO / Art. 25 nDSG)

- ✅ Export enthält ALLE Daten eines Kandidaten
- ❌ Export enthält KEINE Daten anderer Kandidaten
- ✅ Export-Format ist maschinenlesbar (JSON)
- ✅ Audit-Log enthält `action: 'DATA_EXPORT'`

### 7C. Automatische Retention

- ✅ Worker: `data_retention_date < today()` UND `anonymized_at IS NULL` → anonymisiert
- ❌ Kandidaten MIT Consent-Verlängerung werden NICHT anonymisiert
- ✅ Retention-Worker ist idempotent

### 7D. Testdaten-Sicherheit

- ❌ KEINE echten Produktionsdaten in Test-DB
- ✅ Test-Factories verwenden ausschliesslich Dummy-Daten

### Phase 7 Ausführung

```bash
echo "🧪 Phase 7: DSGVO/nDSG Compliance Tests"
npx vitest run --project compliance --reporter=verbose 2>&1
```

---

## PHASE 8: BULK, EDGE CASES & PERFORMANCE SMOKE

*Ziel: Bulk-Ops, Grenzfälle und grundlegende Performance-Baseline.*

### 8A. Bulk-Operations

- ✅ Bulk Create/Update mit 100+ Einträgen → kein Timeout, korrekte `row_version`
- ❌ Partial Failure: 100 Updates, 1 mit falschem `row_version` → definiertes Verhalten
- ❌ Bulk-Request mit IDs von zwei Tenants → nur eigene werden verarbeitet

### 8B. Edge Cases

- ❌ Leere Datenbank: List-Queries geben leeres Array zurück, nicht Error
- ❌ Maximale Feldlängen: alle Felder können max-Länge speichern und korrekt zurückgeben
- ❌ Unicode: Umlaute (ä, ö, ü), Emoji, CJK-Zeichen in Textfeldern
- ❌ Gleichzeitiges Soft Delete und Update → definiertes Verhalten

### 8C. Cache-Invalidation (falls implementiert)

- ✅ Nach UPDATE: nächster GET zeigt neue Daten
- ❌ Tenant A's Cache nicht von Tenant B lesbar
- ✅ Cache-TTL wird respektiert
- ✅ Stammdaten-Cache wird bei Änderung invalidiert

### 8D. Performance Smoke (Baseline)

*Kein vollständiger Lasttest — nur Baseline-Werte für kritische Pfade.*

- ✅ Kandidaten-List (1'000 Einträge): P95 < 200ms
- ✅ Kandidaten-List (10'000 Einträge): P95 < 500ms
- ✅ Kandidaten-Detail (inkl. JOINs): P95 < 100ms
- ✅ Search mit ILIKE (10'000 Einträge): P95 < 300ms
- ❌ Noisy Neighbor: Parallele Last von Tenant A → Tenant B P95 bleibt stabil
- ❌ Connection Pool unter Last: keine `too many connections` bei 50 parallelen Requests
- ✅ N+1 Erkennung: Kandidaten-Detail löst max. X Queries aus (kein linearer Anstieg mit Daten)

```typescript
// Performance-Baseline Pattern
it('sollte Kandidaten-Liste unter 500ms liefern (10k Einträge)', async () => {
  // Setup: 10'000 Kandidaten einfügen (einmalig, nicht pro Test)
  const start = performance.now()
  const response = await app.inject({
    method: 'GET',
    url: '/api/v1/candidates?pageSize=50',
    headers: { authorization: `Bearer ${token}` }
  })
  const duration = performance.now() - start
  expect(response.statusCode).toBe(200)
  expect(duration).toBeLessThan(500) // P95-Ziel
})
```

### Phase 8 Ausführung

```bash
echo "🧪 Phase 8: Bulk, Edge Cases & Performance Smoke"
npx vitest run --project edge --reporter=verbose 2>&1
```

---

## PHASE 9: FRONTEND TESTS

*⏭️ SKIP wenn kein Frontend-Verzeichnis gefunden in Phase 0.*

### 9A. Store-Tests (Zustand)

- ✅ Initialzustand ist korrekt
- ✅ Actions verändern State korrekt
- ❌ Ungültige Actions werfen Fehler oder werden ignoriert
- 🔒 PII wird NICHT in localStorage persistiert
- ✅ Logout → alle Stores werden zurückgesetzt (kein State-Leak)

### 9B. Hook-Tests

- ✅ TanStack Query Keys enthalten `tenantId`
- ✅ Error-Handling: API-Fehler werden korrekt weitergereicht
- ✅ Loading-States korrekt
- ❌ Stale Cache nach Rollenwechsel: Query Keys werden invalidiert

### 9C. Komponenten-Tests

- Candidate Detail Form: Validierung vor Submit
- Stage-Change: Nur erlaubte Übergänge klickbar
- DataTable: Pagination, Sort, Filter
- PermissionGate: Komponenten ausgeblendet bei fehlender Rolle
- Dirty State Guard: ungespeicherte Änderungen → Warnung bei Navigation
- Optimistic UI Rollback: nach fehlgeschlagenem Update wird alter State wiederhergestellt

### Phase 9 Ausführung

```bash
echo "🧪 Phase 9: Frontend Tests"
if [ -d "$FRONTEND_PATH" ]; then
  cd "$FRONTEND_PATH" && npx vitest run --reporter=verbose 2>&1 && cd -
else
  echo "⏭️ Frontend nicht gefunden — Phase übersprungen"
fi
```

---

## PHASE 10: E2E TESTS

*⏭️ SKIP wenn Playwright nicht installiert oder kein Frontend.*

### 10A. Kritische User-Flows

1. **Login-Flow:** Login → Dashboard → Logout → Login-Seite
2. **Kandidat CRUD:** Erstellen → Bearbeiten → Briefing → Stage-Change → Soft Delete
3. **Suche:** Kandidat suchen → Ergebnis klicken → Detail-View
4. **Prozess-Flow:** Mandat erstellen → Kandidat zuordnen → Stage-Pipeline
5. **Dokument-Upload:** Hochladen → Dokumenten-Tab → Herunterladen
6. **Anonymisierung:** Anonymisieren → PII nicht sichtbar → Export clean

### Phase 10 Ausführung

```bash
echo "🧪 Phase 10: E2E Tests"
if [ -f playwright.config.ts ]; then
  npx playwright test --reporter=list 2>&1
else
  echo "⏭️ Playwright nicht konfiguriert — Phase übersprungen"
fi
```

---

## PHASE 11: REPORT & FIX-VORSCHLÄGE

### 11A. Zusammenfassung

```
╔════════════════════════════════════════════════════════════════╗
║  ARK CRM TESTSUITE REPORT — [DATUM]                          ║
╠════════════════════════════════════════════════════════════════╣
║                                                                ║
║  Phase 1  — Unit Tests:             XX/YY ✅  ZZ ❌  WW ⏭️   ║
║  Phase 2  — Security Tests:         XX/YY ✅  ZZ ❌  WW ⏭️   ║
║  Phase 3  — Integration Tests:      XX/YY ✅  ZZ ❌  WW ⏭️   ║
║  Phase 4  — API Tests:              XX/YY ✅  ZZ ❌  WW ⏭️   ║
║  Phase 5  — Worker Tests:           XX/YY ✅  ZZ ❌  WW ⏭️   ║
║  Phase 6  — Migration & Schema:     XX/YY ✅  ZZ ❌  WW ⏭️   ║
║  Phase 7  — DSGVO/nDSG Compliance:  XX/YY ✅  ZZ ❌  WW ⏭️   ║
║  Phase 8  — Bulk/Edge/Performance:  XX/YY ✅  ZZ ❌  WW ⏭️   ║
║  Phase 9  — Frontend Tests:         XX/YY ✅  ZZ ❌  WW ⏭️   ║
║  Phase 10 — E2E Tests:              XX/YY ✅  ZZ ❌  WW ⏭️   ║
║                                                                ║
║  GESAMT:  XXX/YYY ✅  (XX.X%)                                 ║
║  Coverage: XX.X% Statements | XX.X% Branches                  ║
║                                                                ║
║  DEPLOYMENT-READINESS:                                         ║
║  🟢 READY | 🟡 CONDITIONAL | 🔴 NOT READY                     ║
╚════════════════════════════════════════════════════════════════╝
```

### 11B. Deployment-Readiness Kriterien

- 🟢 READY: 0 Security/RLS/DSGVO/Migration FAIL, >80% Pass-Rate
- 🟡 CONDITIONAL: 0 Security/RLS/DSGVO FAIL, >60% Pass-Rate, CRITICAL Fixes dokumentiert
- 🔴 NOT READY: Security, RLS, DSGVO oder Migration FAIL vorhanden

### 11C. Fix-Vorschläge (priorisiert)

```
🔴 CRITICAL FIXES (vor Go-Live PFLICHT):
[FAIL-NNN] Titel
  Datei: ...
  Fix: ...
  Impact: ...

🟡 HIGH FIXES (sollten behoben werden):
...

🔵 MEDIUM FIXES (empfohlen):
...
```

### 11D. Empfohlene nächste Schritte

1. CRITICAL Fixes sofort beheben
2. Testsuite erneut laufen lassen (`/project:testsuite`)
3. Tests in CI/CD einbinden (siehe Anhang D)
4. Coverage-Ziele prüfen (siehe Anhang C)
5. Pentest-Vorbereitung: Security-Test-Report als Input für externen Pentester

---

## ANHANG A: DATEISTRUKTUR

```
tests/
├── helpers/
│   ├── test-transaction.ts   # Transaction Rollback (Default)
│   ├── test-schema.ts        # Schema-per-Worker (COMMIT-Tests)
│   ├── test-auth.ts          # JWT-Token-Generator
│   ├── test-factories.ts     # Testdaten-Factories (alle Entitäten)
│   ├── test-server.ts        # Fastify Test-Server mit inject()
│   ├── event-spy.ts          # Event-Emit Verifikation
│   ├── db-setup.ts           # DB-Connection Setup
│   └── server-setup.ts       # Server-Lifecycle
├── unit/
│   ├── schemas/              # Zod-Schema Tests
│   ├── state-machines/       # Stage-Machine Tests
│   ├── policies/             # Policy + Feldlevel-Rechte + AI-Governance
│   └── utils/                # Utility Tests
├── security/
│   ├── rls-bypass.security.test.ts
│   ├── cross-tenant.security.test.ts
│   ├── tenant-events-jobs.security.test.ts   # NEU: Events/Jobs/Cache Isolation
│   ├── injection.security.test.ts
│   ├── jwt.security.test.ts
│   └── input-limits.security.test.ts
├── integration/
│   ├── services/             # Service-Layer Tests
│   ├── repositories/         # Repository Tests
│   ├── concurrency/          # Race Condition Tests
│   ├── audit-log/            # NEU: Audit-Log Integrität
│   └── soft-delete/          # NEU: Kaskade + Unique Constraints
├── api/
│   ├── auth.api.test.ts
│   ├── candidates.api.test.ts
│   ├── accounts.api.test.ts
│   ├── webhooks.api.test.ts  # 3CX, Outlook inkl. Out-of-Order
│   └── ...
├── workers/
│   ├── *.worker.test.ts
│   └── poison-stuck.worker.test.ts  # NEU
├── migration/                        # NEU
│   ├── from-scratch.migration.test.ts
│   ├── incremental.migration.test.ts
│   └── schema-validation.migration.test.ts
├── compliance/
│   ├── anonymization.compliance.test.ts
│   ├── data-export.compliance.test.ts
│   └── retention.compliance.test.ts
├── edge/
│   ├── bulk.edge.test.ts
│   ├── cache.edge.test.ts
│   ├── unicode.edge.test.ts
│   └── performance-smoke.edge.test.ts  # NEU
└── e2e/
    └── *.e2e.test.ts
```

## ANHANG B: TEST-HELPERS

### B1. JWT-Token-Generator

```typescript
// tests/helpers/test-auth.ts
import jwt from 'jsonwebtoken'

// KEIN Fallback — Tests MÜSSEN mit konfiguriertem Secret laufen
const TEST_SECRET = process.env.JWT_SECRET
if (!TEST_SECRET) throw new Error('JWT_SECRET nicht gesetzt — .env.test erforderlich')

export function createTestToken(overrides: Partial<JWTPayload> = {}) {
  return jwt.sign({
    sub: crypto.randomUUID(),
    tenant_id: crypto.randomUUID(),
    role: 'ADMIN',
    iat: Math.floor(Date.now() / 1000),
    exp: Math.floor(Date.now() / 1000) + 3600,
    ...overrides
  }, TEST_SECRET)
}

export function createTenantPair() {
  const tenantA = crypto.randomUUID()
  const tenantB = crypto.randomUUID()
  return {
    tokenA: createTestToken({ tenant_id: tenantA }),
    tokenB: createTestToken({ tenant_id: tenantB }),
    tenantA,
    tenantB
  }
}

export function createExpiredToken(tenantId: string) {
  return jwt.sign({
    sub: crypto.randomUUID(), tenant_id: tenantId, role: 'ADMIN',
    iat: Math.floor(Date.now() / 1000) - 7200,
    exp: Math.floor(Date.now() / 1000) - 3600,
  }, TEST_SECRET)
}

export function createTokenWithWrongSecret(tenantId: string) {
  return jwt.sign({
    sub: crypto.randomUUID(), tenant_id: tenantId, role: 'ADMIN',
  }, 'wrong-secret-for-testing')
}
```

### B2. Test-Factories

```typescript
// tests/helpers/test-factories.ts

export const TestCandidate = {
  valid: () => ({
    first_name: 'Hans', last_name: 'Muster',
    email_1: 'hans.muster@example.ch', phone_mobile: '+41 79 123 45 67',
    current_position: 'Projektleiter Hochbau', current_company: 'Implenia AG',
    plz: '8001', ort: 'Zürich', birth_date: '1985-03-15',
    nationality: 'CH', permit: 'C', source: 'DIRECT'
  }),
  minimal: () => ({ first_name: 'Anna', last_name: 'Beispiel' }),
  invalid: {
    missingName: () => ({ email_1: 'test@example.ch' }),
    invalidEmail: () => ({ first_name: 'Test', last_name: 'User', email_1: 'not-an-email' }),
    invalidUUID: () => ({ id: 'not-a-uuid' }),
    sqlInjection: () => ({ first_name: "'; DROP TABLE ark.dim_candidates_profile; --" }),
    xss: () => ({ first_name: '<script>alert("xss")</script>' }),
    oversizedField: () => ({ first_name: 'A'.repeat(10000) }),
    nullBytes: () => ({ first_name: 'Hans\u0000Muster' }),
    pathTraversal: () => ({ photo_url: '../../etc/passwd' }),
  }
}

export const TestAccount = {
  valid: () => ({
    name: 'Implenia AG', type: 'CLIENT', industry: 'HOCHBAU',
    street: 'Industriestrasse 24', plz: '8305', ort: 'Dietlikon',
    website: 'https://www.implenia.com'
  })
}

export const TestContact = {
  valid: (accountId: string) => ({
    account_id: accountId, first_name: 'Maria', last_name: 'Bernasconi',
    position: 'HR Leiterin', email: 'maria.bernasconi@example.ch',
    phone: '+41 44 234 56 78'
  })
}

export const TestMandate = {
  valid: (accountId: string) => ({
    title: 'Gesamtprojektleiter Hochbau', account_id: accountId,
    function: 'PROJEKTLEITUNG', focus: 'HOCHBAU',
    pensum_von: 80, pensum_bis: 100,
    salary_from: 140000, salary_to: 180000,
    location_plz: '8001', location_ort: 'Zürich'
  })
}

export const TestProcess = {
  valid: (mandateId: string, candidateId: string) => ({
    mandate_id: mandateId, candidate_id: candidateId,
    stage: 'LONGLIST', notes: 'Erstgespräch positiv verlaufen'
  })
}

export const TestUser = {
  admin: () => ({ email: 'admin@example.ch', role: 'ADMIN', first_name: 'Peter', last_name: 'Administrator' }),
  researcher: () => ({ email: 'research@example.ch', role: 'RESEARCHER', first_name: 'Hanna', last_name: 'Forscherin' }),
  candidateManager: () => ({ email: 'cm@example.ch', role: 'CANDIDATE_MANAGER', first_name: 'Nina', last_name: 'Betreuerin' }),
  headOf: () => ({ email: 'head@example.ch', role: 'HEAD_OF', first_name: 'Stefano', last_name: 'Leiter' }),
}
```

## ANHANG C: COVERAGE-ZIELE

| Bereich | Ziel | Begründung |
|---|---|---|
| Policies + Feldlevel-Rechte | >95% | Sicherheitskritisch |
| AI-Write-Policy | >95% | AI darf nie in Core-Felder schreiben |
| Zod Schemas | >95% | Erste Verteidigungslinie |
| State Machines | 100% | Jeder Übergang muss getestet sein |
| RLS Policies | 100% | Letzte Verteidigungslinie |
| DSGVO-Funktionen | 100% | Rechtlich kritisch |
| Audit-Log-Schreiber | 100% | Compliance-Nachweis |
| Services | >80% | Business-Logik Kern |
| Repositories | >70% | Durch Integration Tests abgedeckt |
| Routes | >60% | Durch API Tests abgedeckt |
| Workers | >70% | Async-Logik |
| Migrations | 100% | Schema-Integrität |
| Frontend Stores | >80% | State Management |
| Frontend Components | >50% | Fokus Business-kritisch |

## ANHANG D: CI/CD-INTEGRATION

### Phasen-Trigger-Matrix

| Phase | Trigger | Voraussetzung |
|---|---|---|
| 1 Unit | Jeder Push / PR | Keine |
| 2 Security | Jeder Push / PR | Test-DB |
| 3 Integration | Push auf `main`/`develop` | Test-DB |
| 4 API | Push auf `main`/`develop` | Test-DB + Server |
| 5 Worker | Push auf `main`/`develop` | Test-DB + PgBoss |
| 6 Migration | Push auf `main` | Frische DB (Testcontainers) |
| 7 DSGVO | Push auf `main` | Test-DB |
| 8 Bulk/Edge/Perf | Push auf `main` | Test-DB + Testdaten |
| 9 Frontend | Jeder Push / PR (Frontend) | Keine |
| 10 E2E | Pre-Release / Nightly | Full Stack |

### Test-DB in CI (GitHub Actions)

```yaml
services:
  postgres:
    image: postgres:16
    env:
      POSTGRES_USER: test
      POSTGRES_PASSWORD: test
      POSTGRES_DB: ark_test
    ports:
      - 5432:5432
    options: >-
      --health-cmd pg_isready
      --health-interval 10s
      --health-timeout 5s
      --health-retries 5
```

### Flaky-Test-Handling

- Max 2 Reruns pro fehlgeschlagenem Test (`--retry=2`)
- Test nach 2 Reruns immer noch rot → echter Fehler
- Quarantäne-Datei (`tests/quarantine.ts`) mit Ablaufdatum
- Wöchentlicher Quarantäne-Review

## ANHANG E: DB-ISOLATION-STRATEGIE (DETAILLIERT)

| Test-Typ | Isolation-Pattern | Parallelisierung | Begründung |
|---|---|---|---|
| Unit (Schemas, Policies) | Kein DB | Vollständig parallel | Reine Logik |
| Integration Standard | Transaction Rollback | Seriell pro Datei | Schnell, automatisch vollständig |
| COMMIT/Lock-Tests | Schema-per-Worker | Begrenzt parallel | COMMIT muss getestet werden |
| RLS-Rollen-Tests | Getrennte DB-Rollen (App + Owner) | Seriell | `BYPASSRLS` testen |
| Worker/PgBoss | Testcontainers oder Schema | Seriell | Advisory Locks, PgBoss-Tabellen |
| Migration | Testcontainers (frische DB) | Isoliert | Extensions, Roles, Policies |
| Performance Smoke | Dedizierte Test-DB mit Seed | Seriell | Stabile Baseline |

**Transaction Rollback: SET-Timing beachten!**
`SET app.current_tenant` MUSS vor `BEGIN` gesetzt werden (Session-Level),
nicht mit `SET LOCAL` (Transaction-Level). Sonst greift RLS nicht korrekt
bei verschachtelten Transaktionen im Service-Code.

**Testcontainers (empfohlen für Migration + RLS-Rollen):**
```bash
npm install -D testcontainers @testcontainers/postgresql
```
```typescript
import { PostgreSqlContainer } from '@testcontainers/postgresql'

let container: StartedPostgreSqlContainer
beforeAll(async () => {
  container = await new PostgreSqlContainer('postgres:16').start()
  process.env.TEST_DATABASE_URL = container.getConnectionUri()
}, 30000) // Container-Start braucht Zeit

afterAll(async () => {
  await container.stop()
})
```
