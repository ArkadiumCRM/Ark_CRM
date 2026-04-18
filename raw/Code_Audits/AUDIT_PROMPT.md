# ARK Backend — Evidence-Based Code Review & Audit v3.2 FINAL
# Verwendung: /project:audit
# Kontext: Claude Code — Agent mit Shell-Zugriff (bash wird TATSÄCHLICH ausgeführt)

---

## METHODIK

10 Experten reviewen den Codebase nacheinander. Evidenzbasiert, risikogewichtet.

### Regeln

1. **Evidenzpflicht:** Jedes Finding MUSS belegt sein: Datei, Zeile, Code-Ausschnitt.
   Kein Finding ohne Beweis. Bei Unsicherheit → HYPOTHESE markieren.

2. **Reifegradmodell:**
   - ✅ ERFÜLLT — vollständig und korrekt
   - ⚠️ TEILWEISE — vorhanden, aber lückenhaft
   - ❌ VERLETZT — nicht umgesetzt oder fehlerhaft
   - ➖ NICHT PRÜFBAR — aus Code nicht beurteilbar (kein Raten!)
   - 🔄 BEWUSSTE AUSNAHME — dokumentiert abweichend

3. **Confidence:** HIGH (belegbar) / MEDIUM (Indiz) / LOW (Hypothese)

4. **Finding-Format:**
   ```
   [SEV-NNN] Finding-Titel
   Confidence: HIGH/MEDIUM/LOW
   Datei: src/path/file.ts:42
   Code: `betroffener Code`
   Risiko: Was kann passieren?
   Empfehlung: Was soll geändert werden?
   Code-Fix:
     // VORHER
     const result = await trx.query(`SELECT * FROM ark.${table}`)
     // NACHHER
     const ALLOWED = ['dim_candidates_profile','dim_accounts'] as const
     if (!ALLOWED.includes(table)) throw new Error('Invalid table')
   ```

5. **Severity (Domain-gewichtet für Executive Search CRM):**
   - CRITICAL (×4): Sicherheitslücke (IDOR, SQLi), PII-Exposure (DSGVO Meldepflicht), Datenverlust
   - HIGH (×3): Business-Logic-Fehler, Performance-Killer bei 100k, fehlende Audit-Trails
   - MEDIUM (×2): Inkonsistenz, fehlende Validierung, Code-Smell
   - LOW (×1): Kosmetik, Naming, fehlende Doku

6. **Keine Überbehauptungen:** "NICHT PRÜFBAR — Grund: [...]" > falsche Sicherheit.

7. **Signal über Noise:** Max 10 Findings pro Experte, priorisiert nach Risiko.
   Bei Patterns: erstes Beispiel + "Tritt X weitere Male auf in: [Dateien]".

8. **Iteratives Lesen:** Nutze Such-Werkzeuge (grep, glob, cat) gezielt.
   Suche nach Risiko-Patterns statt blind alles zu laden.

9. **Positive Befunde:** Pro Experte AUCH 2-3 Dinge nennen die sauber umgesetzt sind
   (mit Evidenz). Zeigt was beibehalten werden soll.

10. **Finding-Nummerierung:** [CRITICAL-001], [HIGH-001], [MEDIUM-001] etc.
    Ermöglicht Cross-Referenzen in Phase 1.5.

11. **Output-Qualitäts-Guard:** Falls du merkst dass deine Analyse-Tiefe abnimmt
    (nach >15'000 generierten Tokens), stoppe und melde:
    "⚠️ Kontext-Limit — Experte X-Y ausstehend, bitte `/project:audit` erneut ausführen."
    Ein ehrlicher Abbruch ist besser als oberflächliche Findings.

12. **Focus-Mode Priorisierung (bei >15k LoC):**
    - VOLLE TIEFE: Experte 2 (Security), 7 (DB), 8 (Datenschutz)
    - STANDARD: Experte 1 (Architekt), 3 (Reliability), 5 (Domain)
    - REDUZIERT (max 5 Findings): Experte 4 (Performance), 6 (Quality), 9 (API), 10 (Test)

---

## PHASE 0: CODEBASE INVENTORY & SCOPE

```bash
echo "========================================="
echo "  CODEBASE INVENTORY — $(date -I)"
echo "========================================="

TOTAL_LINES=$(find ./src -name "*.ts" 2>/dev/null | xargs wc -l 2>/dev/null | tail -1 | awk '{print $1}')
TOTAL_FILES=$(find ./src -name "*.ts" 2>/dev/null | wc -l)
echo "TypeScript: ${TOTAL_FILES:-0} Files, ${TOTAL_LINES:-0} Lines"

if [ "${TOTAL_LINES:-0}" -gt 15000 ]; then
  echo ""
  echo "⚠️ FOCUS MODE (>15k LoC):"
  echo "   Vollständig: auth.*, repository.base.ts, workers/*, policies/*, middleware/*"
  echo "   Sampling: Restliche Module nach Risikoklasse"
fi

if [ "${TOTAL_LINES:-0}" -gt 30000 ]; then
  echo ""
  echo "🔴 LARGE CODEBASE (>30k LoC):"
  echo "   Empfehlung: Audit pro Welle/Modul separat ausführen"
  echo "   z.B. /project:audit --focus=auth,candidates,processes"
fi

echo ""
echo "=== Module ==="
echo "API:";      ls -d src/api/v1/*/     2>/dev/null || echo "  (keine)"
echo "Modules:";  ls -d src/modules/*/    2>/dev/null || echo "  (keine)"
echo "Workers:";  ls src/workers/*.ts     2>/dev/null || echo "  (keine)"
echo "Adapters:"; ls -d src/adapters/*/   2>/dev/null || echo "  (keine)"
echo "Policies:"; ls src/policies/*.ts    2>/dev/null || echo "  (keine)"

echo ""
echo "=== Architektur-Docs ==="
[ -f docs/ARK_BACKEND_ARCHITECTURE_v2_3.md ] && echo "✅ Backend Architecture" || echo "❌ FEHLT"
[ -f docs/ARK_DATABASE_SCHEMA_v1_1.md ]      && echo "✅ DB Schema"            || echo "❌ FEHLT"

echo ""
echo "=== Dateistruktur ==="
find . -type f \( -name "*.ts" -o -name "*.json" -o -name "*.sql" -o -name "*.toml" -o -name "*.yml" \) | grep -v node_modules | grep -v dist | sort
```

Zeige: package.json (deps + scripts), tsconfig.json, .env.example

---

## PHASE 1: EXPERTEN-REVIEWS

### EXPERTE 1: ARCHITEKT
*"Ist die Architektur sauber, konsistent und erweiterbar?"*

Untersuche iterativ: src/app/*, Middleware, Module (routes + service + repository).
Referenz: docs/ARK_BACKEND_ARCHITECTURE_v2_3.md

- Schichtenmodell: API → Service → Policy → Repository → Worker → Adapter
  - API: Keine Business Logic? / Repository: Keine Business-Entscheidungen?
  - Service: Orchestriert Transaktion + Event + Audit?
  - Begründete Ausnahmen akzeptabel (🔄)
- Konventionen: PKs uuid / tenant_id aus JWT / operative Queries filtern tenant_id /
  updateWithVersion() / Soft Delete / Kein SELECT * / Response-Format konsistent
- Modularität: Zirkuläre Deps? Cross-Modul nur via shared? Feature Flags?
- Erweiterbarkeit: Neues Modul ohne Bestandsänderung? Stage-Machines konfigurierbar?

Output: Top 10 Findings + 2-3 positive Befunde + Reifegrad pro Bereich

---

### EXPERTE 2: SECURITY ENGINEER
*"Wie würde ich dieses System kompromittieren?"*

Untersuche gezielt: Middleware, auth.*, repository.base.ts, Routes, Webhooks, Scraper.

- SQL Injection: Interpolation in .query()? `ark.${table}` Whitelist? User-Input in ORDER BY?
- Auth: Endpunkte ohne authMiddleware? JWT Algorithm? Refresh Rotation? Lockout? Rate Limit?
- AuthZ: Endpunkte ohne Role-Check? IDOR? tenant_id aus Body statt JWT?
- Input: Ohne Zod? UUID validiert? File Upload? ReDoS?
- Data Exposure: PII in Responses? Stack Traces? X-Forwarded-For Spoofing?
- Infra: CORS Wildcard? Helmet? Secrets im Code? .env in .gitignore? npm audit?
- **SSRF: Webhook-Empfänger/Scraper mit User-kontrollierten URLs ohne Allowlist?**

Output: Top 10 Findings + Exploit-Szenario + 2-3 positive Befunde

---

### EXPERTE 3: RELIABILITY ENGINEER
*"Was passiert wenn um 3 Uhr nachts etwas schiefgeht?"*

Untersuche: errorHandler, server.ts, workers, transaction.ts, pg.ts.

- Error Handling: Globaler Handler? Unhandled Rejections? Stack Traces verborgen?
- Transaktionen: withTransaction()? Rollback? Atomar? Race Conditions? Deadlocks?
- Shutdown: SIGTERM/SIGINT? boss.stop() + pool.end() + app.close()? isShuttingDown?
- Worker: Idempotent? Retry+Backoff? DLQ? Circuit Breaker? Timeouts? Heartbeat?
- Memory: Event Listener Accumulation? Unbegrenzte Queues? Grosse Datasets in Memory?
- DB: Pool Config? Statement/Lock/Idle Timeout? Pool Error Handler?

Output: Top 10 Findings + Was-passiert-wenn Szenario + 2-3 positive Befunde

---

### EXPERTE 4: PERFORMANCE ENGINEER
*"Wo bricht das System bei 100k Kandidaten, 50k Accounts, 200k History zusammen?"*

Untersuche: Repository-Dateien, search.*, matching.*.

- N+1? ILIKE ohne pg_trgm bei 100k? COUNT(*) statt Estimation? Fehlende Indexes?
- Full Table Scans? Grosse JOINs? Cursor-Pagination korrekt? Max page size?
- Stammdaten gecached? Cache Invalidation? Redundante DB-Calls?
- Connection Pool? PgBoss Concurrency? Hot Spots?

Output: Top 10 Findings + geschätzter Impact bei 100k + 2-3 positive Befunde

---

### EXPERTE 5: DOMAIN EXPERT
*"Bildet der Code die Geschäftslogik eines Executive Search CRM korrekt ab?"*

Untersuche: Policies, stageMachines.ts, Services.
Referenz: docs/ARK_BACKEND_ARCHITECTURE_v2_3.md

- Stage Machines: Candidate, Process, Mandate, Research, Job, Jobbasket — alle korrekt?
- Datenschutz = Endstation? Placement → is_placed? Rejection mit Pflicht-Begründung?
- Events: Jede Mutation → korrektes Event? Seeds vollständig?
- AI Governance: Nie direkt Core → immer fact_ai_suggestions?

Output: Top 10 Findings + Business-Impact + 2-3 positive Befunde

---

### EXPERTE 6: CODE QUALITY ENGINEER
*"Kann ein neuer Entwickler den Code in einem Tag verstehen?"*

Untersuche: Querschnitt (Pattern erkennen).

- strict: true? Keine `any`? Keine @ts-ignore?
- DRY? Funktionen <50 Zeilen? Dateien <300 Zeilen? Cyclomatic Complexity?
- Alle Module gleiches Pattern? Fehler-Codes aus Katalog?
- CLAUDE.md aktuell? .env.example vollständig?

Output: Top 10 Findings + 2-3 positive Befunde

---

### EXPERTE 7: DATABASE ENGINEER
*"Passen die Queries zur Datenbankstruktur?"*

Untersuche: Repository-Dateien + migrations/*.sql
Referenz: docs/ARK_DATABASE_SCHEMA_v1_1.md

- Schema-Alignment: Spaltennamen, Typen, Tabellennamen korrekt?
  GENERATED ALWAYS nie in INSERT? NOT NULL befüllt? CHECK/UNIQUE respektiert?
- Queries: JOINs korrekt? NULL-Handling? Timezone-aware? RETURNING?
- Migrations: Backwards-compatible? Destructive markiert? Long-Lock Risiken?
  Event-Seeds stimmen? Verwaiste/Fehlende Tabellen?

Output: Top 10 Findings + konkretes Query-Beispiel + 2-3 positive Befunde

---

### EXPERTE 8: DATENSCHUTZ-ENGINEER (TOMs gem. Art. 32 DSGVO)
*"Sind technische Voraussetzungen für datenschutzkonforme Verarbeitung implementiert?"*

DISCLAIMER: Prüft Code-Evidenz — KEINE rechtliche Compliance-Feststellung.
Output-Format: "Technisch implementiert ✅ / Lücke erkannt ❌ / Nicht im Code prüfbar ➖"

Untersuche: retention.worker.ts, piiMask.*, audit.*, Kandidaten-Repository.

- PII: Pino Redaction? PII in Responses/Events/Logs?
- Retention: data_retention_date geprüft? Worker anonymisiert? Dokumente/Embeddings?
- Löschung: Alle Daten eines Kandidaten entfernbar? Alle verknüpften Tabellen?
- Export: Pro Kandidat möglich?
- Audit-Trail: Jede Änderung geloggt? REVOKE auf Audit-Tabellen? Login-Versuche?
- Consent: is_do_not_contact in Queries respektiert?

Output: Top 10 Findings + 2-3 positive Befunde

---

### EXPERTE 9: API DESIGN REVIEWER
*"Ist die API vorhersagbar und konsistent?"*

Untersuche: Alle Routes + Schemas + Controller.

- REST: HTTP-Methoden? URL-Struktur? Keine Verben in URLs?
- Response: { success, data, meta, error } überall? Status Codes korrekt?
- Pagination: Cursor-basiert? Default + Max limit? Sort konsistent?
- Contract: Swagger generiert? Zod Input + Response? Versioning /api/v1/?
  Contract-Tests (Pact/Postman)? Breaking-Change-Erkennung?
- Idempotency-Key auf POST?

Output: Top 10 Findings + 2-3 positive Befunde

---

### EXPERTE 10: TEST & OBSERVABILITY ENGINEER
*"Können wir sicher deployen und Incidents schnell lösen?"*

Untersuche: tests/*, package.json, logger.ts, sentry.ts, CI.

- Tests: Gibt es welche? Unit/Integration/API? Negative? Permission? Concurrency? Contract?
- Observability: Strukturierte Logs? Request ID? Log Levels? Metriken? Sentry? Worker-Health?
- Deployment: CI/CD? Type-Check in CI? Build? Health-Checks? Rollback?

Output: Top 10 Findings + 2-3 positive Befunde

---

## PHASE 1.5: CROSS-IMPACT-ANALYSE

Direkt nach den Experten-Reviews, BEVOR statische Analyse läuft.

HINWEIS: Cross-Impact ist eine Best-Effort-Einschätzung, keine definitive Analyse.
Markiere Confidence (HIGH/MEDIUM/LOW) pro Cross-Impact.

Gehe alle CRITICAL + HIGH Findings durch. Nutze diese Heuristiken:

| Primär-Finding | Prüfe IMMER auf Impact bei |
|---|---|
| SQL Injection / Auth-Bypass | → Compliance (PII-Leak → DSGVO Art. 33) + Reliability (Service Down) |
| Fehlende tenant_id | → Security (Cross-Tenant) + Compliance (Datentrennung) + Domain (falsche Daten) |
| N+1 / Full Table Scan | → Reliability (Timeout → 503 für alle User) |
| Fehlende Audit-Logs | → Compliance (Nachweispflicht) |
| Layer-Verletzung | → Security (Auth-Bypass möglich) + Domain (Business Rule umgangen) |
| SSRF in Scraper/Webhook | → Security (Internal Network Scan) + Reliability (IP-Ban) |

Dokumentiere als Tabelle:

| Finding-ID | Primär | Betroffene | Confidence | Begründung |
|---|---|---|---|---|
| CRITICAL-001 | Security | +Compliance +Reliability | HIGH | SQLi → PII-Leak → Meldepflicht |

---

## PHASE 2: STATISCHE ANALYSE (echte Ausführung)

```bash
echo "========================================="
echo "  STATISCHE ANALYSE — $(date -I)"
echo "========================================="

echo ""
echo "=== 1. TypeScript ==="
if [ -f tsconfig.json ] && command -v npx &> /dev/null; then
  npx tsc --noEmit 2>&1 | tail -20
else
  echo "⚠️ tsc nicht verfügbar"
fi

echo ""
echo "=== 2. any Types ==="
ANY_COUNT=$(grep -rn ': any' src/ --include="*.ts" 2>/dev/null | grep -v node_modules | grep -v '.d.ts' | wc -l)
echo "Gefunden: $ANY_COUNT"
grep -rn ': any' src/ --include="*.ts" 2>/dev/null | grep -v node_modules | grep -v '.d.ts' | head -10

echo ""
echo "=== 3. @ts-ignore ==="
grep -rn '@ts-ignore\|@ts-expect-error' src/ --include="*.ts" 2>/dev/null | head -10

echo ""
echo "=== 4. SELECT * ==="
grep -rn 'SELECT \*' src/ --include="*.ts" 2>/dev/null | head -10

echo ""
echo "=== 5. SQL Interpolation ==="
grep -rn 'query.*`.*\${' src/ --include="*.ts" 2>/dev/null | head -20

echo ""
echo "=== 6. console.log ==="
grep -rn 'console\.\(log\|warn\|error\)' src/ --include="*.ts" 2>/dev/null | grep -v node_modules | head -10

echo ""
echo "=== 7. process.env direkt ==="
grep -rn 'process\.env\.' src/ --include="*.ts" 2>/dev/null | grep -v 'config/env.ts' | grep -v node_modules | grep -v 'tests/' | grep -v '.config.' | head -10

echo ""
echo "=== 8. Hardcoded Secrets ==="
grep -rn "password.*=.*['\"]" src/ --include="*.ts" 2>/dev/null | grep -v password_hash | grep -v Schema | grep -v interface | grep -v type | head -10

echo ""
echo "=== 9. npm audit ==="
if command -v npm &> /dev/null; then
  npm audit --production 2>&1 | tail -15
else
  echo "⚠️ npm nicht verfügbar"
fi

echo ""
echo "=== 10. Stage Machines ==="
grep -rn "TRANSITIONS\|STAGES" src/config/ --include="*.ts" 2>/dev/null | head -20

echo ""
echo "=== 11. Metrics ==="
echo "TS files: $(find ./src -name '*.ts' 2>/dev/null | wc -l)"
echo "TS lines: $(find ./src -name '*.ts' 2>/dev/null | xargs wc -l 2>/dev/null | tail -1)"
echo "Test files: $(find ./tests -name '*.ts' 2>/dev/null | wc -l)"
echo "Migrations: $(find ./migrations -name '*.sql' 2>/dev/null | wc -l)"

echo ""
echo "=== 12. ARK-SPEZIFISCH: Queries OHNE tenant_id ==="
grep -rn 'FROM ark\.' src/ --include="*.ts" 2>/dev/null | grep -v 'tenant_id' | grep -v 'dim_' | grep -v 'RETURNING' | grep -v '--' | head -15

echo ""
echo "=== 13. ARK-SPEZIFISCH: DELETE FROM (Hard Delete) ==="
grep -rn 'DELETE FROM' src/ --include="*.ts" 2>/dev/null | grep -v '-- ' | head -10

echo ""
echo "=== 14. ARK-SPEZIFISCH: Routes ohne authMiddleware ==="
grep -rn 'app\.\(get\|post\|patch\|put\|delete\)' src/api/ --include="*.ts" 2>/dev/null | grep -v 'auth' | grep -v 'health' | grep -v 'webhook' | head -15

echo ""
echo "=== 15. ARK-SPEZIFISCH: PATCH/PUT ohne row_version ==="
grep -rn 'PATCH\|\.patch\|\.put' src/api/ --include="*.ts" 2>/dev/null | head -10
echo "--- updateWithVersion Nutzung: ---"
grep -rn 'updateWithVersion' src/ --include="*.ts" 2>/dev/null | wc -l
```

---

## PHASE 3: EXECUTIVE SUMMARY

### Implementierungsstand
| Welle | Status | Module |
|-------|--------|--------|
| 1 — Foundation | | Config, Auth, Middleware, Health |
| 2 — Core CRM | | Candidates, Accounts, Jobs, Mandate, Processes, History, Documents |
| 3 — Event Spine | | Events, Automations, Notifications, Workers |
| 4 — AI/RAG | | AI, Search, Matching, RAG, Embeddings |
| 5 — Integrationen | | 3CX, Outlook, Scraper, Webhooks |
| 6 — Analytics | | Analytics, Market Intelligence, Admin, Data Quality |
| 7 — Phase 2 | | Settings, Briefings, Projects, Assessments, LinkedIn |

### Gewichteter Score

Zeige den Rechenweg nachvollziehbar, dann fülle die Tabelle:

| # | Experte | Score | × | = Gewichtet | Begründung (1 Satz) |
|---|---------|-------|---|-------------|---------------------|
| 1 | Architekt | /10 | 3 | | |
| 2 | Security | /10 | 4 | | |
| 3 | Reliability | /10 | 3 | | |
| 4 | Performance | /10 | 2 | | |
| 5 | Domain | /10 | 3 | | |
| 6 | Code Quality | /10 | 1 | | |
| 7 | DB Alignment | /10 | 3 | | |
| 8 | Datenschutz | /10 | 3 | | |
| 9 | API Design | /10 | 2 | | |
| 10 | Test/Observ. | /10 | 2 | | |
| | **GESAMT** | | 26 | **/260** | |

VALIDIERUNG: Addiere alle Gewichtet-Werte. Vergleiche mit GESAMT.
Falls Differenz → 🔴 RECHENFEHLER, korrigiere.

### Deployment-Readiness

| Score | CRITICAL | Status | Empfehlung |
|-------|----------|--------|------------|
| >220 | 0 | 🟢 PRODUCTION-READY | Deploy mit Change Management |
| 180-220 | 0 | 🟡 DEPLOY MIT VORBEHALT | Fix HIGH in 1. Sprint |
| 180-220 | >0 | 🟠 KRITISCHE LÜCKEN | Fix CRITICAL sofort |
| <180 | any | 🔴 NICHT DEPLOY-FÄHIG | Min. 2 Wochen Nacharbeit |

### Statische Analyse
| Check | Ergebnis | Status |
|-------|----------|--------|
| tsc Errors | | |
| any Types | | |
| SELECT * | | |
| SQL Interpolation | | |
| console.log | | |
| process.env direkt | | |
| npm audit | | |
| Queries ohne tenant_id | | |
| DELETE FROM (Hard Delete) | | |
| Routes ohne Auth | | |

### ARK-Spezifisch
| Check | Ergebnis | Status |
|-------|----------|--------|
| tenant_id in allen operativen Queries | | |
| Kein Hard Delete | | |
| Alle Routes auth-geschützt | | |
| updateWithVersion bei PATCH/PUT | | |

### Cross-Impact Findings
(Findings die mehrere Experten betreffen — Best-Effort, mit Confidence)

### Alle Findings (nummeriert, nach Severity)
- 🔴 CRITICAL: [CRITICAL-001] ... [CRITICAL-00N]
- 🟠 HIGH: [HIGH-001] ...
- 🟡 MEDIUM: [MEDIUM-001] ...
- 🔵 LOW: [LOW-001] ...

### Handlungsempfehlungen

**Sofort (Quick Wins — hoher Impact, geringer Aufwand):**
1. ...

**Kurzfristig (hoher Impact, moderater Aufwand):**
1. ...

**Mittelfristig (strukturell):**
1. ...

**Nice-to-have:**
1. ...

### Baseline-Tracking
Schreibe am Ende diesen Eintrag (für Trend-Analyse über Zeit):
```bash
echo "$(date -I),GESAMT_SCORE,CRITICAL_COUNT,HIGH_COUNT,MEDIUM_COUNT,LOW_COUNT" >> audit-history.csv
```

---

FORMAT: EINEN kopierbaren Text. Bei Unsicherheit: NICHT PRÜFBAR.
