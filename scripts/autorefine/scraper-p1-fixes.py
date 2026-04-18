#!/usr/bin/env python3
"""
Scraper P1 Harmonisierungs-Fixes (aus harmonization-audit-2026-04-19):
1. .tab-pane → .tab-panel (CSS + HTML + JS)
2. toggleTheme() inline → <script src="../_shared/layout.js"></script>

Atomic pattern: temp-file + os.replace.
Beide Repos (main + worktree).
"""
import os
import re
from pathlib import Path

FILES = [
    Path(r"C:\ARK CRM\mockups\Vollansichten\scraper.html"),
    Path(r"C:\ARK CRM\.claude\worktrees\nice-turing-f27c27\mockups\Vollansichten\scraper.html"),
]

def atomic_write(path, content):
    tmp = str(path) + '.tmp'
    with open(tmp, 'w', encoding='utf-8') as f:
        f.write(content)
    os.replace(tmp, path)

def process(path):
    if not path.exists():
        print(f"SKIP {path} (not found)")
        return
    content = path.read_text(encoding='utf-8')
    original = content

    # 1) Rename .tab-pane → .tab-panel (CSS + HTML class attr + JS selector)
    # CSS: .tab-pane { … } / .tab-pane.active { … }
    content = re.sub(r'\.tab-pane\b', '.tab-panel', content)
    # HTML: class="tab-pane active" / class="tab-pane"
    content = re.sub(r'class="tab-pane\b', 'class="tab-panel', content)
    # JS: querySelectorAll('.tab-pane') — already covered by CSS rule above

    # 2) Replace inline toggleTheme + applyTheme + localStorage block with layout.js import
    inline_theme_block = re.compile(
        r'function applyTheme\(t\) \{[^}]+\}\s*'
        r'function toggleTheme\(\) \{[^}]+\}[^)]*\}[^(]*\(function\(\)\{[^}]+\}\)\(\);\s*'
        r'// Cross-frame sync[^}]+\}\);\s*',
        re.DOTALL
    )
    new_theme = '// Theme-Toggle handled by _shared/layout.js (siehe body-end <script src>)\n'
    content, replaced = inline_theme_block.subn(new_theme, content)
    print(f"  inline-theme-block replaced: {replaced}")

    # 3) Add <script src="../_shared/layout.js"></script> before </body> if not present
    if '_shared/layout.js' not in content:
        content = content.replace('</body>', '<script src="../_shared/layout.js"></script>\n</body>')
        print(f"  layout.js script-tag added")
    else:
        print(f"  layout.js already present")

    if content != original:
        atomic_write(path, content)
        print(f"OK {path.name}")
    else:
        print(f"NOCHANGE {path.name}")

for f in FILES:
    print(f"\n=== {f} ===")
    process(f)
print("\ndone.")
