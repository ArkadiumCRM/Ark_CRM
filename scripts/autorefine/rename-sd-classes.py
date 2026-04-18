#!/usr/bin/env python3
"""
Rename Stammdaten-scoped CSS classes to canonical ARK classes in HTML body.

Only renames `class="..."` attributes in HTML body (not inside CSS <style> blocks).
Keeps .sd-* CSS definitions intact (unused but harmless).

Rename map (longest first to avoid prefix-collisions):
  sd-tabbar → tabbar
  sd-content → content
  sd-pane → tab-panel
  sd-tab → tab
  tnum → num
"""
import os
import re
import sys

PATH = 'mockups/stammdaten.html'

# Read
with open(PATH, 'r', encoding='utf-8') as f:
    content = f.read()

# Split at </style> — edit only post-style body
parts = content.split('</style>', 1)
if len(parts) != 2:
    print('ERROR: </style> not found')
    sys.exit(1)
head, body = parts

# Order matters: longer prefixes first
renames = [
    ('sd-tabbar',  'tabbar'),
    ('sd-content', 'content'),
    ('sd-pane',    'tab-panel'),
    ('sd-tab',     'tab'),  # after sd-tabbar
    ('tnum',       'num'),
    ('tcount',     'tcount'),  # kept unchanged (Stammdaten-unique)
]

count = 0
for old, new in renames:
    if old == new:
        continue
    # Match class attribute values precisely: class="..." or class='...'
    # Use word-boundary-like matching within class lists
    pattern = re.compile(r'(\bclass\s*=\s*["\'][^"\']*)\b' + re.escape(old) + r'\b')
    before = body.count(old)
    new_body = pattern.sub(r'\1' + new, body)
    # Iterate to handle multi-occurrence in same class attr
    while new_body != body:
        body = new_body
        new_body = pattern.sub(r'\1' + new, body)
    after = body.count(old)
    renamed = before - after
    count += renamed
    print(f'{old:12s} -> {new:10s} : {renamed} renamed')

# Write to temp + atomic mv
out = head + '</style>' + body
tmp = PATH + '.tmp'
with open(tmp, 'w', encoding='utf-8') as f:
    f.write(out)
os.replace(tmp, PATH)
print(f'\nTotal: {count} HTML class attributes renamed.')
