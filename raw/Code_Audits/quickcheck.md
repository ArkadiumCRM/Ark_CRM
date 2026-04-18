---
description: Quick PR check — 3 experts, max 5 findings each, <5 min
model: claude-sonnet-4-6
---

Schneller Code-Check auf die letzten Änderungen. 3 Experten, max 5 Findings.

```bash
echo "=== Geänderte Dateien ==="
CHANGED=$(git diff --name-only HEAD~1 2>/dev/null || git diff --name-only main 2>/dev/null || git status --short 2>/dev/null | awk '{print $2}')

if [ -z "$CHANGED" ]; then
  echo "⚠️ Kein git diff → Fallback: alle src/*.ts"
  CHANGED=$(find ./src -name "*.ts")
fi
echo "$CHANGED"

echo ""
echo "=== Risiko-Einschätzung ==="
HIGH_RISK=$(echo "$CHANGED" | grep -E "(auth|policy|worker|migration|shared|middleware|repository\.base|errorHandler|env\.ts)" || true)
if [ -n "$HIGH_RISK" ]; then
  echo "🔴 HIGH-RISK Dateien geändert:"
  echo "$HIGH_RISK"
  echo ""
  echo "EMPFEHLUNG: Statt Quickcheck → /project:audit für tiefere Analyse"
else
  echo "🟢 Standard-Risiko"
fi
```

Prüfe NUR die geänderten Dateien. Wenn HIGH-RISK erkannt, weise darauf hin aber prüfe trotzdem.

**1. SECURITY (max 5 Findings):**
- SQL Injection? String-Interpolation in Queries?
- Auth/AuthZ Lücke? Fehlender Role-Check? tenant_id aus Body statt JWT?
- PII in Response oder Logs? SSRF bei URLs?

**2. CORRECTNESS (max 5 Findings):**
- TypeScript Fehler? Falsche Types?
- Business Rule Verletzung? Stage Machine inkorrekt?
- DB Schema Mismatch? Fehlende Spaltennamen?
- Fehlende Zod-Validierung? Fehlender Event-Emit?
- Performance-Killer? (N+1, kein LIMIT, Full Table Scan)

**3. RELIABILITY (max 5 Findings):**
- Fehlende Error-Behandlung? Unhandled Promise?
- Fehlende Transaktion bei Multi-Write?
- Fehlende Logs? Fehlende Audit-Einträge?

Format:
```
[SEVERITY-NNN] Titel
Datei: path:zeile
Code: `betroffener Code`
Fix: `korrigierter Code`
```

Ende: Kurzes Urteil (1-2 Sätze) ob die Änderung safe ist.
Falls HIGH-RISK: explizite Empfehlung ob Full Audit nötig.
