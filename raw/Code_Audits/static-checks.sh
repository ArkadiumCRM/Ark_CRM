#!/bin/bash
# scripts/static-checks.sh v3.2
# Pre-Commit / CI Static Analysis — ARK Backend
# Exit: 0 = ✅ Green | 1 = ❌ Blocked | Warnings printed but non-blocking
# Usage: bash scripts/static-checks.sh

set -euo pipefail
ERRORS=0
WARNINGS=0

echo "🔍 ARK Backend — Static Checks v3.2"
echo "====================================="

# 1. TypeScript Compilation
echo ""
echo "1. TypeScript Compilation..."
if [ -f tsconfig.json ] && command -v npx &> /dev/null; then
  if npx tsc --noEmit 2>&1; then
    echo "   ✅ Keine TypeScript-Fehler"
  else
    echo "   ❌ TypeScript-Fehler gefunden"
    ERRORS=$((ERRORS + 1))
  fi
else
  echo "   ⚠️ Übersprungen (npx oder tsconfig.json fehlt)"
fi

# 2. any Types
echo ""
echo "2. any Types..."
ANY_COUNT=$(grep -rn ': any' src/ --include="*.ts" 2>/dev/null | grep -v node_modules | grep -v '.d.ts' | wc -l)
if [ "$ANY_COUNT" -gt 0 ]; then
  echo "   ❌ $ANY_COUNT any-Types gefunden:"
  grep -rn ': any' src/ --include="*.ts" 2>/dev/null | grep -v node_modules | grep -v '.d.ts' | head -5
  ERRORS=$((ERRORS + 1))
else
  echo "   ✅ Keine any-Types"
fi

# 3. @ts-ignore
echo ""
echo "3. @ts-ignore / @ts-expect-error..."
IGNORE_COUNT=$(grep -rn '@ts-ignore\|@ts-expect-error' src/ --include="*.ts" 2>/dev/null | wc -l)
if [ "$IGNORE_COUNT" -gt 0 ]; then
  echo "   ❌ $IGNORE_COUNT @ts-ignore gefunden:"
  grep -rn '@ts-ignore\|@ts-expect-error' src/ --include="*.ts" 2>/dev/null | head -5
  ERRORS=$((ERRORS + 1))
else
  echo "   ✅ Keine @ts-ignore"
fi

# 4. SELECT *
echo ""
echo "4. SELECT *..."
SELECT_COUNT=$(grep -rn 'SELECT \*' src/ --include="*.ts" 2>/dev/null | wc -l)
if [ "$SELECT_COUNT" -gt 0 ]; then
  echo "   ⚠️ $SELECT_COUNT SELECT * gefunden:"
  grep -rn 'SELECT \*' src/ --include="*.ts" 2>/dev/null | head -5
  WARNINGS=$((WARNINGS + 1))
else
  echo "   ✅ Kein SELECT *"
fi

# 5. console.log (sollte Pino nutzen)
echo ""
echo "5. console.log..."
CONSOLE_COUNT=$(grep -rn 'console\.\(log\|warn\|error\)' src/ --include="*.ts" 2>/dev/null | grep -v node_modules | wc -l)
if [ "$CONSOLE_COUNT" -gt 0 ]; then
  echo "   ⚠️ $CONSOLE_COUNT console.log gefunden (sollte Pino nutzen):"
  grep -rn 'console\.\(log\|warn\|error\)' src/ --include="*.ts" 2>/dev/null | grep -v node_modules | head -5
  WARNINGS=$((WARNINGS + 1))
else
  echo "   ✅ Kein console.log"
fi

# 6. process.env direkt
echo ""
echo "6. process.env direkt..."
ENV_COUNT=$(grep -rn 'process\.env\.' src/ --include="*.ts" 2>/dev/null | grep -v 'config/env.ts' | grep -v node_modules | grep -v 'tests/' | grep -v '.config.' | wc -l)
if [ "$ENV_COUNT" -gt 0 ]; then
  echo "   ❌ $ENV_COUNT direkte process.env Zugriffe:"
  grep -rn 'process\.env\.' src/ --include="*.ts" 2>/dev/null | grep -v 'config/env.ts' | grep -v node_modules | grep -v 'tests/' | grep -v '.config.' | head -5
  ERRORS=$((ERRORS + 1))
else
  echo "   ✅ Alle ENV über env.ts"
fi

# 7. SQL String Interpolation
echo ""
echo "7. SQL String Interpolation..."
SQL_INTERP=$(grep -rn 'query.*`.*\${' src/ --include="*.ts" 2>/dev/null | wc -l)
if [ "$SQL_INTERP" -gt 0 ]; then
  echo "   ⚠️ $SQL_INTERP SQL-Interpolationen gefunden (prüfe auf Whitelist):"
  grep -rn 'query.*`.*\${' src/ --include="*.ts" 2>/dev/null | head -5
  WARNINGS=$((WARNINGS + 1))
else
  echo "   ✅ Keine SQL-Interpolation"
fi

# 8. DELETE FROM (Hard Delete)
echo ""
echo "8. DELETE FROM (Hard Delete)..."
DELETE_COUNT=$(grep -rn 'DELETE FROM' src/ --include="*.ts" 2>/dev/null | grep -v '-- ' | wc -l)
if [ "$DELETE_COUNT" -gt 0 ]; then
  echo "   ❌ $DELETE_COUNT DELETE FROM gefunden (nur Soft Delete erlaubt):"
  grep -rn 'DELETE FROM' src/ --include="*.ts" 2>/dev/null | grep -v '-- ' | head -5
  ERRORS=$((ERRORS + 1))
else
  echo "   ✅ Kein Hard Delete"
fi

# 9. Hardcoded Secrets
echo ""
echo "9. Hardcoded Secrets..."
SECRET_COUNT=$(grep -rn "password.*=.*['\"]" src/ --include="*.ts" 2>/dev/null | grep -v password_hash | grep -v Schema | grep -v interface | grep -v type | grep -v test | wc -l)
if [ "$SECRET_COUNT" -gt 0 ]; then
  echo "   ❌ $SECRET_COUNT potenzielle hardcoded Secrets:"
  grep -rn "password.*=.*['\"]" src/ --include="*.ts" 2>/dev/null | grep -v password_hash | grep -v Schema | grep -v interface | grep -v type | grep -v test | head -5
  ERRORS=$((ERRORS + 1))
else
  echo "   ✅ Keine hardcoded Secrets"
fi

# 10. npm audit
echo ""
echo "10. npm audit (production)..."
if command -v npm &> /dev/null; then
  if npm audit --production --audit-level=high 2>&1 | grep -q "found 0 vulnerabilities"; then
    echo "   ✅ Keine HIGH/CRITICAL Vulnerabilities"
  else
    echo "   ⚠️ Vulnerabilities gefunden:"
    npm audit --production 2>&1 | tail -5
    WARNINGS=$((WARNINGS + 1))
  fi
else
  echo "   ⚠️ npm nicht verfügbar"
fi

# 11. .env in .gitignore
echo ""
echo "11. .env in .gitignore..."
if grep -q "^\.env$" .gitignore 2>/dev/null; then
  echo "   ✅ .env in .gitignore"
else
  echo "   ❌ .env NICHT in .gitignore"
  ERRORS=$((ERRORS + 1))
fi

# 12. Fehlende LIMIT in List-Queries
echo ""
echo "12. List-Queries ohne LIMIT..."
NO_LIMIT=$(grep -rn 'SELECT.*FROM ark\.' src/ --include="*.ts" 2>/dev/null | grep -v 'LIMIT' | grep -v 'WHERE.*id' | grep -v 'COUNT' | wc -l)
if [ "$NO_LIMIT" -gt 0 ]; then
  echo "   ⚠️ $NO_LIMIT Queries ohne LIMIT (potenzielle Full Table Scans):"
  grep -rn 'SELECT.*FROM ark\.' src/ --include="*.ts" 2>/dev/null | grep -v 'LIMIT' | grep -v 'WHERE.*id' | grep -v 'COUNT' | head -5
  WARNINGS=$((WARNINGS + 1))
else
  echo "   ✅ Alle List-Queries haben LIMIT"
fi

# === ARK-SPEZIFISCHE CHECKS ===

# 13. Operative Queries ohne tenant_id (CRITICAL für Multi-Tenant)
echo ""
echo "13. [ARK] Queries ohne tenant_id..."
# Suche nach FROM ark.fact_/ark.bridge_ Queries ohne tenant_id (dim_ sind Stammdaten = ok)
NO_TENANT=$(grep -rn 'FROM ark\.\(fact_\|bridge_\)' src/ --include="*.ts" 2>/dev/null | grep -v 'tenant_id' | grep -v 'RETURNING' | grep -v '-- ' | wc -l)
if [ "$NO_TENANT" -gt 0 ]; then
  echo "   ❌ $NO_TENANT operative Queries OHNE tenant_id Filter:"
  grep -rn 'FROM ark\.\(fact_\|bridge_\)' src/ --include="*.ts" 2>/dev/null | grep -v 'tenant_id' | grep -v 'RETURNING' | grep -v '-- ' | head -5
  ERRORS=$((ERRORS + 1))
else
  echo "   ✅ Alle operativen Queries filtern tenant_id"
fi

# 14. DELETE FROM (nur Soft Delete erlaubt)
echo ""
echo "14. [ARK] DELETE FROM (Hard Delete)..."
HARD_DELETE=$(grep -rn 'DELETE FROM' src/ --include="*.ts" 2>/dev/null | grep -v '-- ' | grep -v test | wc -l)
if [ "$HARD_DELETE" -gt 0 ]; then
  echo "   ❌ $HARD_DELETE Hard Deletes gefunden (nur Soft Delete erlaubt):"
  grep -rn 'DELETE FROM' src/ --include="*.ts" 2>/dev/null | grep -v '-- ' | grep -v test | head -5
  ERRORS=$((ERRORS + 1))
else
  echo "   ✅ Kein Hard Delete"
fi

# 15. updateWithVersion Nutzung
echo ""
echo "15. [ARK] Optimistic Locking..."
UWV_COUNT=$(grep -rn 'updateWithVersion' src/ --include="*.ts" 2>/dev/null | grep -v 'import\|export\|from' | wc -l)
PATCH_COUNT=$(grep -rn '\.patch\b\|PATCH' src/api/ --include="*.ts" 2>/dev/null | wc -l)
echo "   PATCH Endpunkte: ~$PATCH_COUNT, updateWithVersion Aufrufe: $UWV_COUNT"
if [ "$UWV_COUNT" -lt 1 ]; then
  echo "   ⚠️ updateWithVersion wird nicht verwendet"
  WARNINGS=$((WARNINGS + 1))
else
  echo "   ✅ Optimistic Locking aktiv ($UWV_COUNT Aufrufe)"
fi

# Summary
echo ""
echo "====================================="
if [ "$ERRORS" -gt 0 ]; then
  echo "❌ $ERRORS BLOCKING Issues + $WARNINGS Warnings"
  exit 1
elif [ "$WARNINGS" -gt 0 ]; then
  echo "⚠️ $WARNINGS Warnings (nicht blockierend, Review empfohlen)"
  exit 0
else
  echo "✅ Alle Static Checks bestanden"
  exit 0
fi
