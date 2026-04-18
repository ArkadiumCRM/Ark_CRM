#!/usr/bin/env python3
"""
Fix mockups nach Peter's Umstrukturierung in Listen/ und Vollansichten/.

Tasks:
1. Für beide Repos (main + worktree): Files in Listen/ und Vollansichten/ verschieben (idempotent)
2. In verschobenen Files: _shared/ → ../_shared/
3. In crm.html + crm-mobile.html: Pfade updaten (Listen/ oder Vollansichten/ prefix)

Atomic pattern per CLAUDE.md §Datei-Schutz-Regel: temp-file + os.replace.
"""
import os
import sys
import shutil
from pathlib import Path

REPOS = [
    Path(r"C:\ARK CRM\mockups"),
    Path(r"C:\ARK CRM\.claude\worktrees\nice-turing-f27c27\mockups"),
]

# Files die in Listen/ kommen
LISTEN = {
    'accounts-list.html', 'assessments-list.html', 'candidates-list.html',
    'groups-list.html', 'jobs-list.html', 'mandates-list.html',
    'processes-list.html', 'projects-list.html', 'admin-mobile.html',
}

# Files die in Vollansichten/ kommen
VOLL = {
    'accounts.html', 'admin.html', 'admin-dashboard-templates.html',
    'assessments.html', 'candidates.html', 'dashboard.html',
    'dok-generator.html', 'email-kalender.html', 'groups.html',
    'jobs.html', 'mandates.html', 'processes.html', 'projects.html',
    'reminders.html', 'scraper.html', 'stammdaten.html',
}

# Root-only (bleiben im Wurzel)
ROOT = {'crm.html', 'crm-mobile.html', 'dashboard-mobile.html'}


def atomic_write(path, content):
    tmp = str(path) + '.tmp'
    with open(tmp, 'w', encoding='utf-8') as f:
        f.write(content)
    os.replace(tmp, path)


def move_file(src, dst_dir):
    """Move src into dst_dir (atomic). Returns True if moved, False if already there."""
    dst = dst_dir / src.name
    if dst.exists() and not src.exists():
        return False  # Already moved
    if src.exists() and dst.exists():
        # Both exist — dst is newer Peter-placed; remove src
        print(f"  DROP {src.name} (already in {dst_dir.name}/)")
        src.unlink()
        return False
    if src.exists():
        dst_dir.mkdir(exist_ok=True)
        shutil.move(str(src), str(dst))
        return True
    return False


def fix_shared_refs(path):
    """Replace _shared/ with ../_shared/ in a file (1 level deep)."""
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
    original = content
    # Replace only in src/href attribute values (quoted strings)
    for pattern in ['"_shared/', "'_shared/"]:
        replacement = pattern[0] + '../_shared/'
        content = content.replace(pattern, replacement)
    if content != original:
        atomic_write(path, content)
        return True
    return False


def fix_crm_paths(crm_path):
    """In crm.html: data-src="X.html" → data-src="Listen/X.html" or "Vollansichten/X.html"."""
    with open(crm_path, 'r', encoding='utf-8') as f:
        content = f.read()
    original = content
    # Files in Listen/ — data-src and data-page
    for fname in LISTEN:
        for pfx in [f'data-src="{fname}"', f'data-src="Listen/{fname}"']:
            pass
        content = content.replace(f'data-src="{fname}"', f'data-src="Listen/{fname}"')
    # Files in Vollansichten/
    for fname in VOLL:
        content = content.replace(f'data-src="{fname}"', f'data-src="Vollansichten/{fname}"')
    # Avoid double-prefix (Listen/Listen/... or Vollansichten/Vollansichten/...)
    content = content.replace('Listen/Listen/', 'Listen/')
    content = content.replace('Vollansichten/Vollansichten/', 'Vollansichten/')
    if content != original:
        atomic_write(crm_path, content)
        return True
    return False


def fix_crm_mobile_paths(path):
    """In crm-mobile.html: setPage(this,'X.html') → 'Listen/X.html' or 'Vollansichten/X.html'."""
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
    original = content
    for fname in LISTEN:
        content = content.replace(f"'{fname}'", f"'Listen/{fname}'")
    for fname in VOLL:
        content = content.replace(f"'{fname}'", f"'Vollansichten/{fname}'")
    content = content.replace('Listen/Listen/', 'Listen/')
    content = content.replace('Vollansichten/Vollansichten/', 'Vollansichten/')
    if content != original:
        atomic_write(path, content)
        return True
    return False


def process_repo(root):
    print(f"\n=== {root} ===")
    if not root.exists():
        print(f"  SKIP (not exist)")
        return
    listen_dir = root / 'Listen'
    voll_dir = root / 'Vollansichten'
    moved = 0
    # 1) Move files
    for fname in LISTEN:
        src = root / fname
        if move_file(src, listen_dir):
            print(f"  MOVE {fname} -> Listen/")
            moved += 1
    for fname in VOLL:
        src = root / fname
        if move_file(src, voll_dir):
            print(f"  MOVE {fname} -> Vollansichten/")
            moved += 1
    # 2) Fix _shared refs in moved files
    fixed_shared = 0
    for d in [listen_dir, voll_dir]:
        if not d.exists():
            continue
        for f in d.iterdir():
            if f.suffix == '.html' and fix_shared_refs(f):
                fixed_shared += 1
    # 3) Fix crm paths
    crm = root / 'crm.html'
    crmm = root / 'crm-mobile.html'
    crm_fixed = fix_crm_paths(crm) if crm.exists() else False
    crmm_fixed = fix_crm_mobile_paths(crmm) if crmm.exists() else False
    print(f"  -> moved={moved}, _shared-fixed={fixed_shared}, crm.html={crm_fixed}, crm-mobile.html={crmm_fixed}")


if __name__ == '__main__':
    for repo in REPOS:
        process_repo(repo)
    print("\ndone.")
