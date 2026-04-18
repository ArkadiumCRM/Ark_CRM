#!/usr/bin/env python3
"""
Fix parent-relative href/src refs in moved mockup files.

Files in Listen/ and Vollansichten/ reference crm.html with href="crm.html",
which resolves to Listen/crm.html or Vollansichten/crm.html (404).
Fix: href="crm.html" -> href="../crm.html".

Same for other root-level files (dashboard-mobile.html, crm-mobile.html).
"""
import os
from pathlib import Path

REPOS = [
    Path(r"C:\ARK CRM\mockups"),
    Path(r"C:\ARK CRM\.claude\worktrees\nice-turing-f27c27\mockups"),
]

ROOT_FILES = ['crm.html', 'crm-mobile.html', 'dashboard-mobile.html']

def atomic_write(path, content):
    tmp = str(path) + '.tmp'
    with open(tmp, 'w', encoding='utf-8') as f:
        f.write(content)
    os.replace(tmp, path)

def fix_file(path):
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
    original = content
    for root_file in ROOT_FILES:
        # href="X.html" -> href="../X.html"  (only when not already prefixed)
        for quote in ['"', "'"]:
            old = f'href={quote}{root_file}'
            new = f'href={quote}../{root_file}'
            # Avoid double prefix
            if f'../{root_file}' not in content:
                content = content.replace(old, new)
            else:
                # Already correctly prefixed in some spots; still replace bare ones
                # But this is tricky. Split on '../' to find only bare refs.
                # Simpler: do regex-like careful replacement
                pass
    # More robust: use regex to match href="X" not preceded by ../ or /
    import re
    for root_file in ROOT_FILES:
        # Match href="crm.html" (or 'crm.html') NOT preceded by /
        pattern = re.compile(r'(href\s*=\s*["\'])(?!\.\./|/)(' + re.escape(root_file) + r')(["\'])')
        content = pattern.sub(r'\1../\2\3', content)
    if content != original:
        atomic_write(path, content)
        return True
    return False

def process_repo(root):
    print(f"\n=== {root} ===")
    if not root.exists():
        return
    fixed = 0
    for sub in ['Listen', 'Vollansichten']:
        d = root / sub
        if not d.exists():
            continue
        for f in d.iterdir():
            if f.suffix == '.html' and fix_file(f):
                fixed += 1
                print(f"  FIX {sub}/{f.name}")
    print(f"  -> {fixed} files fixed")

if __name__ == '__main__':
    for repo in REPOS:
        process_repo(repo)
    print("\ndone.")
