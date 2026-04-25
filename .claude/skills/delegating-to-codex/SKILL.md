---
name: delegating-to-codex
description: Use BEFORE invoking Codex CLI (`codex exec`) for any non-trivial coding task. Enforces procedural prompt template that prevents misclassification, encoding regressions, and unverified diffs. Critical for ARK CRM mockups where Codex has previously broken @font-face fonts (mistaken for images), introduced UTF-8 BOM, and double-encoded umlauts. Trigger when about to spawn Codex via Bash.
---

# Delegating to Codex CLI — Safe-Spawn Protocol

Codex follows instructions literally. If your prompt assumes the wrong type, scope, or constraint, Codex will dutifully implement the wrong thing. Use this protocol every time you call `codex exec`.

## Pre-flight Checklist

Before writing the prompt:

1. **Use the wrapper, not raw codex.** Always invoke via `bash ~/.claude/cli/codex-safe.sh` (auto-validates BOM + mojibake + reverts on fail).
2. **Scope explicitly.** Pass `--scope <pathspec>` to limit which files Codex can touch. Default `.` is too broad.
3. **No assumptions in the prompt.** Replace "X is a Y" with "first identify whether X is Y or Z by checking the surrounding context".

## Prompt Template

```
TASK: <one sentence: what to fix>

INVESTIGATE FIRST (do not assume):
- For each <thing>, check <how to identify type/category> before editing.
- If unclear, leave a comment and skip rather than guess.

CONSTRAINTS (must hold for every changed file):
- UTF-8 encoding, no BOM (no 0xEF 0xBB 0xBF prefix).
- Preserve umlauts exactly: ä ö ü ß Ä Ö Ü — must roundtrip via grep.
- Do not reformat unrelated whitespace/quotes/indentation.
- Do not add new dependencies without listing them in your reply.

FILES IN SCOPE: <list>
FILES OUT OF SCOPE: <list — Codex must NOT touch>

VERIFY each fix:
- Run: <specific test command per file>
- Expected: <exact pass condition>
- If your fix doesn't make the test pass, do NOT mark it done.

REPORT FORMAT:
- For each file: 1-line summary of what changed + 1-line test result.
- No code blocks unless I asked for them.
```

## Anti-Patterns (Have Burned Us Before)

| Wrong prompt | Result | Right prompt |
|---|---|---|
| "These UUID files are drag-drop image artifacts, replace with PNG" | Codex replaced woff2 fonts with PNG → font system silently broken | "Each UUID URL — check `format(...)` clause: woff2=font (use `local()` fallback), image=PNG. If unclear, skip." |
| "Make the page work" | Codex reformats 1000 lines, breaks encoding | "Find the JS line where `X` errors. Add null-check. Touch nothing else." |
| "Fix all bugs" | Aggressive multi-file refactor, hard to review | One bug per `codex exec` invocation. Sequential, not bundled. |

## Post-flight (codex-safe.sh handles this automatically)

The wrapper auto-runs:

1. **BOM check** on every changed text file.
2. **Mojibake check** (`â€[œ"™–]|Ã[¤¶¼Ÿœ"]|Â[·°§¶]` regex) — catches cp1252-as-UTF8 double-encoding.
3. **Diff-stat sanity** — alert if a small-fix prompt produced a huge diff.
4. **Auto-revert on fail** via `git checkout HEAD -- <scope>` + remove untracked files Codex created.

If wrapper passes, **still review `git diff <scope>` manually** before committing. Validators catch encoding regressions but not semantic regressions.

## When NOT to Use Codex

- **Recursive self-modification** — never have Codex edit Codex's own validator/wrapper (encoding bug we're protecting against could re-corrupt the protector).
- **Critical infrastructure files** — hooks, settings.json, secrets-bearing configs. Manual edits with full session context are safer than blind delegation.
- **Tasks requiring conversation context** — Codex has no memory of this thread. If the fix depends on prior turns, you'll need to over-describe → defeats the token-saving point.

## Quick-Reference

```bash
# Bad: raw codex with vague prompt
codex exec "fix the mockup bugs"

# Good: scoped + explicit + wrapped
bash ~/.claude/cli/codex-safe.sh --scope mockups/Vollansichten/admin.html '
TASK: Replace @font-face blocks that reference UUID files with system-font fallback.
INVESTIGATE FIRST: each @font-face — confirm src is UUID (no extension), keep blocks
that reference real .woff2 files.
CONSTRAINTS: UTF-8 no BOM, preserve umlauts, do not touch other CSS.
SCOPE: only mockups/Vollansichten/admin.html
VERIFY: npx playwright test tests/mockups-smoke.spec.ts -g "admin.html" — must pass.
REPORT: lines removed/added per @font-face block.
'
```
