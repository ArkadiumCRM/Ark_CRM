#!/usr/bin/env python3
"""
Stammdaten KPI-Fixes:
1. Main KPI-Strip: cols-4 → 6-col grid wie Admin (gleiche Card-Dimensionen)
   + 2 zusätzliche KPIs (Status-Verteilung + Recent Changes)
2. Alle .stat-strip innerhalb Tab-Panels entfernen (Admin hat keine)
"""
import os
import re
from pathlib import Path

FILES = [
    Path(r"C:\ARK CRM\mockups\Vollansichten\stammdaten.html"),
    Path(r"C:\ARK CRM\.claude\worktrees\nice-turing-f27c27\mockups\Vollansichten\stammdaten.html"),
]

def atomic_write(path, content):
    tmp = str(path) + '.tmp'
    with open(tmp, 'w', encoding='utf-8') as f:
        f.write(content)
    os.replace(tmp, path)

def process(path):
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
    original = content

    # 1) Remove all .stat-strip blocks (greedy balanced)
    # Pattern: <div class="stat-strip"> ... </div>  (up to matching close)
    pattern = re.compile(
        r'    <div class="stat-strip">\s*(?:<div class="s">.*?</div>\s*)+</div>\s*\n\s*\n',
        re.DOTALL
    )
    content, removed = pattern.subn('', content)
    print(f"  stat-strips removed: {removed}")

    # 2) Replace main KPI-Strip (cols-4) with 6-col inline-grid + 2 extra KPIs
    old_kpi = '''  <div class="kpi-strip cols-4" style="gap:10px;margin-bottom:0">
    <div class="kpi">
      <div class="kpi-label"><span class="h-dot ok"></span>Kataloge</div>
      <div class="kpi-val">67</div>
      <div class="kpi-sub muted">13 Workflow · 6 Comm · 4 Skills · 7 Geo · 8 Orga · 10 Mandat · 5 System · 5 Gov</div>
    </div>
    <div class="kpi">
      <div class="kpi-label"><span class="h-dot ok"></span>Einträge total</div>
      <div class="kpi-val">5 247</div>
      <div class="kpi-sub muted">dominiert von Geo (3 500) · Skills (1 000) · Workflow (140)</div>
    </div>
    <div class="kpi k-blue">
      <div class="kpi-label"><span class="h-dot ok"></span>Letztes Update</div>
      <div class="kpi-val">12.04.</div>
      <div class="kpi-sub muted">PW · Activity-Type „Erreicht — Referenzauskunft" erweitert</div>
    </div>
    <div class="kpi k-amber">
      <div class="kpi-label"><span class="h-dot warn"></span>Gesperrt / extern</div>
      <div class="kpi-val">7</div>
      <div class="kpi-sub muted">Naming · AI-Policies · ISO-Länder · ISO-Sprachen · PII · Honorar-Staffel</div>
    </div>
  </div>'''

    new_kpi = '''  <div class="kpi-strip" style="display:grid;grid-template-columns:repeat(6,1fr);gap:10px;margin-bottom:0">
    <div class="kpi">
      <div class="kpi-label"><span class="h-dot ok"></span>Kataloge</div>
      <div class="kpi-val">67</div>
      <div class="kpi-sub muted">13 Workflow · 6 Comm · 4 Skills · 7 Geo · 8 Orga · 10 Mandat · 5 System · 5 Gov</div>
    </div>
    <div class="kpi">
      <div class="kpi-label"><span class="h-dot ok"></span>Einträge total</div>
      <div class="kpi-val">5 247</div>
      <div class="kpi-sub muted">dominiert von Geo (3 500) · Skills (1 000) · Workflow (140)</div>
    </div>
    <div class="kpi k-green">
      <div class="kpi-label"><span class="h-dot ok"></span>Aktiv</div>
      <div class="kpi-val">64</div>
      <div class="kpi-sub muted">3 inaktiv · 5 gesperrt · 2 extern</div>
    </div>
    <div class="kpi k-purple">
      <div class="kpi-label"><span class="h-dot ok"></span>Letzte 7 Tage</div>
      <div class="kpi-val">4</div>
      <div class="kpi-sub muted">Einträge geändert · Top Katalog „Activity-Types"</div>
    </div>
    <div class="kpi k-blue">
      <div class="kpi-label"><span class="h-dot ok"></span>Letztes Update</div>
      <div class="kpi-val">12.04.</div>
      <div class="kpi-sub muted">PW · Activity-Type „Erreicht — Referenzauskunft" erweitert</div>
    </div>
    <div class="kpi k-amber">
      <div class="kpi-label"><span class="h-dot warn"></span>Gesperrt / extern</div>
      <div class="kpi-val">7</div>
      <div class="kpi-sub muted">Naming · AI-Policies · ISO-Länder · ISO-Sprachen · PII · Honorar-Staffel</div>
    </div>
  </div>'''

    if old_kpi in content:
        content = content.replace(old_kpi, new_kpi)
        print(f"  main KPI-strip: replaced (cols-4 -> 6-col inline grid + 2 new KPIs)")
    else:
        print(f"  main KPI-strip: pattern NOT found (already updated?)")

    if content != original:
        atomic_write(path, content)
        return True
    return False

for path in FILES:
    print(f"\n=== {path.name} ({path.parent.parent.name}) ===")
    process(path)
print("\ndone.")
