#!/usr/bin/env python3
"""
Harmonisierungs-Audit über alle Mockups.
Prüft Detailseiten gegen Admin/Stammdaten-Pattern:
- Standard ARK-Header
- Shared CSS/JS Refs (editorial.css + layout.js)
- Warn-Banner (analog .admin-warn)
- Page-Banner mit H1
- KPI-Strip (6 Cards)
- Tabbar (.tabbar + .tab + .num)

Output: Markdown-Report nach stdout.
"""
import os
import re
from pathlib import Path

REPO = Path(r"C:\ARK CRM\mockups")

# Reference files (already-harmonized)
REFERENCE = {'admin.html', 'stammdaten.html', 'scraper.html'}

# Documented exceptions (brauchen keine Admin-Pattern-Konformität)
EXCEPTIONS = {
    'dok-generator.html':  'Tool-Maske · andere UX (Template-Editor · kein KPI-Strip nötig)',
    'email-kalender.html': 'Tool-Maske · andere UX (Inbox-Split-Layout · kein KPI-Strip nötig)',
}

CHECKS = [
    ('header',      r'<header class="header">',                  'Standard ARK-Header'),
    ('editorial',   r'href="\.\./_shared/editorial\.css"',       'Shared editorial.css'),
    ('layout_js',   r'src="\.\./_shared/layout\.js"',            'Shared layout.js'),
    ('warn_banner', r'admin-warn|stammdaten-warn|scraper-warn|Bereich</strong>', 'Warn-Banner analog .admin-warn'),
    ('page_banner', r'page-banner|banner-title',                 'Page-Banner mit H1'),
    ('kpi_strip',   r'kpi-strip|kpi-val|\.kpi\b',                'KPI-Strip (Admin-Pattern)'),
    ('tabbar',      r'class="tabbar"|class="tab active"|class="tab" data-tab', 'Standard .tabbar + .tab'),
]

def check_file(path):
    content = path.read_text(encoding='utf-8', errors='ignore')
    results = {}
    for key, pattern, label in CHECKS:
        results[key] = bool(re.search(pattern, content))
    # Quick size
    results['size_kb'] = round(len(content) / 1024, 1)
    return results

def fmt_check(ok):
    return '✅' if ok else '❌'

def categorize(folder, name):
    if name in REFERENCE:
        return 'reference'
    if name in EXCEPTIONS:
        return 'exception'
    return 'target'

def audit(folder):
    d = REPO / folder
    if not d.exists():
        return []
    results = []
    for f in sorted(d.iterdir()):
        if f.suffix != '.html':
            continue
        results.append((f.name, categorize(folder, f.name), check_file(f)))
    return results

def report():
    print(f"# Harmonisierungs-Audit Mockups · {os.environ.get('DATE', '2026-04-19')}\n")
    print(f"Prüfkriterien gegen Admin/Stammdaten-Pattern (`header` + `editorial.css` + `layout.js` + Warn-Banner + Page-Banner + KPI-Strip + Tabbar).\n")
    print(f"**Legende:** ✅ vorhanden · ❌ fehlt · 📘 Referenz (schon harmonisiert) · ⚠ Ausnahme (Tool-Maske, andere UX)\n")
    for folder in ['Vollansichten', 'Listen']:
        print(f"\n## {folder}/\n")
        rows = audit(folder)
        if not rows:
            print("*(leer)*")
            continue
        # Header row
        print(f"| File | Typ | Header | CSS | JS | Warn | Banner | KPI | Tabbar | Size |")
        print(f"|------|-----|--------|-----|-----|------|--------|-----|--------|------|")
        for name, cat, r in rows:
            cat_tag = {'reference':'📘 Ref', 'exception':'⚠ Except', 'target':'Target'}[cat]
            print(f"| `{name}` | {cat_tag} | {fmt_check(r['header'])} | {fmt_check(r['editorial'])} | {fmt_check(r['layout_js'])} | {fmt_check(r['warn_banner'])} | {fmt_check(r['page_banner'])} | {fmt_check(r['kpi_strip'])} | {fmt_check(r['tabbar'])} | {r['size_kb']}k |")

    # Drift summary
    print(f"\n## Drift-Summary pro Target\n")
    for folder in ['Vollansichten', 'Listen']:
        print(f"\n### {folder}\n")
        rows = audit(folder)
        for name, cat, r in rows:
            if cat != 'target':
                continue
            missing = []
            if not r['header']: missing.append('Header')
            if not r['editorial']: missing.append('editorial.css')
            if not r['layout_js']: missing.append('layout.js')
            if not r['warn_banner']: missing.append('Warn-Banner')
            if not r['page_banner']: missing.append('Page-Banner')
            if not r['kpi_strip']: missing.append('KPI-Strip')
            if not r['tabbar']: missing.append('Tabbar')
            if missing:
                print(f"- **{name}** ({r['size_kb']} KB): fehlt {' · '.join(missing)}")
            else:
                print(f"- **{name}** ✓ konform")
    print(f"\n## Ausnahmen-Rationale\n")
    for name, reason in EXCEPTIONS.items():
        print(f"- **{name}** — {reason}")

if __name__ == '__main__':
    report()
