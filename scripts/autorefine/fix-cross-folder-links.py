#!/usr/bin/env python3
"""
Fix cross-folder href-Links in Listen/ + Vollansichten/ Files.

Listen/*.html  href="accounts.html"  → ../Vollansichten/accounts.html
Listen/*.html  href="foo-list.html"  → foo-list.html  (same folder, no change)
Vollansichten/*.html  href="foo-list.html"  → ../Listen/foo-list.html
Vollansichten/*.html  href="admin.html"  → admin.html (same folder, no change)

Unchanged: href="../crm.html", href="#...", href="http...", href="mailto:"
"""
import os
import re
from pathlib import Path

REPOS = [
    Path(r"C:\ARK CRM\mockups"),
    Path(r"C:\ARK CRM\.claude\worktrees\nice-turing-f27c27\mockups"),
]

# Files classification (matches earlier restructure script)
LISTEN = {
    'accounts-list.html', 'assessments-list.html', 'candidates-list.html',
    'groups-list.html', 'jobs-list.html', 'mandates-list.html',
    'processes-list.html', 'projects-list.html', 'admin-mobile.html',
}

VOLL = {
    'accounts.html', 'admin.html', 'admin-dashboard-templates.html',
    'assessments.html', 'candidates.html', 'dashboard.html',
    'dok-generator.html', 'email-kalender.html', 'groups.html',
    'jobs.html', 'mandates.html', 'processes.html', 'projects.html',
    'reminders.html', 'scraper.html', 'stammdaten.html',
}

def atomic_write(path, content):
    tmp = str(path) + '.tmp'
    with open(tmp, 'w', encoding='utf-8') as f:
        f.write(content)
    os.replace(tmp, path)

def fix_file(path, my_folder):
    """
    my_folder: 'Listen' or 'Vollansichten'
    """
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
    original = content

    # Determine needed cross-folder prefix
    if my_folder == 'Listen':
        other_folder = 'Vollansichten'
        cross_files = VOLL
    else:
        other_folder = 'Listen'
        cross_files = LISTEN

    # Regex: match href="X.html" OR href="X.html?..." OR href="X.html#..."
    # NOT preceded by / or . (so no "../foo.html" false positive)
    for fname in cross_files:
        # Careful: build regex that captures href="fname..." where fname followed by " or ? or #
        pattern = re.compile(
            r'(href\s*=\s*["\'])(?<![./])(' + re.escape(fname) + r')(\b[^"\']*)(["\'])'
        )
        def replacer(m):
            return f'{m.group(1)}../{other_folder}/{m.group(2)}{m.group(3)}{m.group(4)}'
        content = pattern.sub(replacer, content)

    # Safety: avoid double-prefix
    content = content.replace(f'{other_folder}/{other_folder}/', f'{other_folder}/')

    if content != original:
        atomic_write(path, content)
        return True
    return False

def process_repo(root):
    print(f"\n=== {root} ===")
    if not root.exists():
        return
    fixed = 0
    for folder in ['Listen', 'Vollansichten']:
        d = root / folder
        if not d.exists():
            continue
        for f in d.iterdir():
            if f.suffix == '.html' and fix_file(f, folder):
                fixed += 1
                print(f"  FIX {folder}/{f.name}")
    print(f"  -> {fixed} files fixed")

if __name__ == '__main__':
    for repo in REPOS:
        process_repo(repo)
    print("\ndone.")
