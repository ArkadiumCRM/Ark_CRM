---
name: backup-before-bulk
description: Use BEFORE any Edit or Write operation that modifies more than 100 lines or files larger than 5KB in the ARK CRM project, especially mockups/*.html, specs/*.md, and wiki/* files. Enforces CRITICAL file-protection rule - auto-backup to backups/<file>.<YYYY-MM-DD-HHMM>.bak before bulk changes. Trigger when planning multi-line rewrites, Python patch scripts, or big refactors.
---

# Backup-Before-Bulk (CRITICAL Rule, 2026-04-15)

Schützt vor Truncate-Bug durch Python `open('w')` / Bash-Heredoc-Fails. Bei Bulk-Edit verpflichtend.

## Trigger

Vor Edit/Write wenn **eins** zutrifft:
- Datei > 5 KB UND Änderung > 100 Zeilen Diff
- Neue Struktur-Umstellung (Drawer-Wechsel, Pipeline-Migration, Schema-Refactor)
- Bulk-Replace per Script geplant
- Erste Bearbeitung einer Datei in der Session

## Workflow

1. **Vor Edit/Write:**
   ```bash
   mkdir -p "C:/Projects/Ark_CRM/backups"
   cp "<original-path>" "C:/Projects/Ark_CRM/backups/<filename>.<YYYY-MM-DD-HHMM>.bak"
   ```
   Timestamp-Format: `2026-04-16-1453`

2. **Edit ausführen** — nur via `Edit`- oder `Write`-Tool (atomar). **Niemals** `python -c "open('f','w')"` oder Bash-Heredoc-Patch-Scripts mit Write-Access auf existierende Datei.

3. **Falls Bulk-Replace per Script zwingend nötig:**
   - Script schreibt in `<original>.tmp`
   - Erfolgreich abschliessen
   - Atomar `mv <original>.tmp <original>`
   - Niemals direkt überschreiben

4. **Nach Verifikation:** Backup bleibt, rolling max 10 pro Datei.

## Verbotene Patterns

```python
# FALSCH — truncated sofort bei open()
with open('candidates.html', 'w') as f:
    f.write(content)  # bei UnicodeError → Datei leer
```

```bash
# FALSCH — Heredoc-Encoding kann fail
cat > candidates.html <<'EOF'
...
EOF
```

## Erlaubte Patterns

```python
# OK — tmp-Datei + atomic rename
with open('candidates.html.tmp', 'w', encoding='utf-8') as f:
    f.write(content)
os.replace('candidates.html.tmp', 'candidates.html')
```

```
# OK — Edit/Write-Tool (atomar, mit Read-Gate)
Edit(file_path="candidates.html", old_string=..., new_string=...)
Write(file_path="candidates.html", content=...)
```

## Backup-Ordner-Struktur

```
C:/Projects/Ark_CRM/backups/
  candidates.html.2026-04-15-1352.bak
  candidates.html.2026-04-16-0912.bak
  mandates.html.2026-04-15-0930.bak
  processes.html.2026-04-16-1430.bak
```

**Rolling Retention:** max 10 pro Datei. Älteste löschen wenn 11. hinzugefügt wird:

```bash
ls -t "C:/Projects/Ark_CRM/backups/<filename>".*.bak | tail -n +11 | xargs rm -f
```

## Recovery

Bei korrupter Datei:
```bash
cp "C:/Projects/Ark_CRM/backups/<filename>.<latest-ts>.bak" "<original-path>"
```
