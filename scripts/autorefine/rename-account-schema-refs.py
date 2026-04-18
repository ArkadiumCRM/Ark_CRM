#!/usr/bin/env python3
"""
Bulk-Rename: ARK_ACCOUNT_DETAILMASKE_SCHEMA_v0_2 -> v0_3
Follow-up zum git-mv des Schema-Files (autorefine Run 16).

Atomic pattern per CLAUDE.md Datei-Schutz-Regel §3:
write to tmp -> os.replace -> atomic mv.

Usage: python scripts/autorefine/rename-account-schema-refs.py
"""
import os
import sys

OLD = 'ARK_ACCOUNT_DETAILMASKE_SCHEMA_v0_2'
NEW = 'ARK_ACCOUNT_DETAILMASKE_SCHEMA_v0_3'

# Active references — needs update after git-mv
FILES = [
    '.claude/commands/ark-drift-scan.md',
    'wiki/sources/account-schema.md',
    'wiki/meta/rbac-matrix.md',
    'wiki/meta/detailseiten-nachbearbeitung.md',
    'wiki/meta/detailseiten-inventar.md',
    'wiki/meta/decision-draft-account-tab-projekte.md',
    'wiki/meta/breadcrumbs-konsistenz.md',
    'wiki/meta/autorefine-log.md',
    'specs/ARK_PROZESS_DETAILMASKE_SCHEMA_v0_1.md',
    'specs/ARK_PROJEKT_DETAILMASKE_SCHEMA_v0_2.md',
    'specs/ARK_JOB_DETAILMASKE_SCHEMA_v0_1.md',
    'specs/ARK_GRUNDLAGEN_SYNC_v1_4.md',
    'specs/ARK_FIRMENGRUPPE_DETAILMASKE_SCHEMA_v0_1.md',
    'specs/ARK_DOK_GENERATOR_SCHEMA_v0_1.md',
    'specs/ARK_ASSESSMENT_DETAILMASKE_SCHEMA_v0_3.md',
    'specs/ARK_ACCOUNT_DETAILMASKE_INTERACTIONS_v0_3.md',
]

# Historic records — leave untouched (snapshot at time of writing)
LEAVE_ALONE = [
    'log.md',
    'wiki/analyses/audit-2026-04-13-komplett.md',
]

def process(path):
    try:
        with open(path, 'r', encoding='utf-8') as f:
            content = f.read()
    except FileNotFoundError:
        return f'MISS {path}'
    if OLD not in content:
        return f'SKIP {path} (no match)'
    count = content.count(OLD)
    new_content = content.replace(OLD, NEW)
    tmp = path + '.tmp'
    with open(tmp, 'w', encoding='utf-8') as f:
        f.write(new_content)
    # Atomic mv per CLAUDE.md Datei-Schutz-Regel
    os.replace(tmp, path)
    return f'OK   {path} ({count} replacement{"s" if count != 1 else ""})'

def main():
    results = []
    for p in FILES:
        results.append(process(p))
    print('\n'.join(results))
    print(f'\n--- Left untouched (historic): ---')
    for p in LEAVE_ALONE:
        print(f'     {p}')

if __name__ == '__main__':
    main()
