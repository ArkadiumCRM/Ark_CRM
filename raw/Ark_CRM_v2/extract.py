import re
from pathlib import Path

files = [
    "1. kandidat_uebersicht_v8.html",
    "2. kandidat_briefing_v3.html",
    "3. kandidat_werdegang_v2.html",
    "5. kandidat_jobbasket_v2.html",
    "6. kandidat_prozesse_v2.html",
    "7. kandidat_history_v2.html",
    "8. kandidat_dokumente_v2.html",
    "9. kandidat_dokgenerator_v2.html",
    "10. kandidat_reminders_v2.html",
    "kandidat_ai_analyse_v2.html",
    "kandidat_assessment_Gesamtüberblick_v2.html",
    "kandidat_scheelen_6_HM_v2.html",
    "kandidat_teamrad_v2.html",
    "kandidat_vergleich_v2.html",
]

for fname in files:
    fpath = Path(fname)
    if not fpath.exists():
        continue
    
    try:
        content = fpath.read_text(encoding='utf-8', errors='ignore')
    except:
        continue
    
    # Find class names
    classes = re.findall(r'class="([^"]+)"', content)
    
    # Extract visible text  
    texts = re.findall(r'>([^<>{]{3,100})<', content)
    texts = [t.strip() for t in texts if t.strip()]
    
    # Identify key features from classes
    features = set()
    for cls in classes:
        if 'spider' in cls or 'chart' in cls or 'svg' in cls:
            features.add('Spider/Chart')
        if 'timeline' in cls or 'tl-' in cls:
            features.add('Timeline')
        if 'grid' in cls or 'card' in cls:
            features.add('Card/Grid')
        if 'toggle' in cls or 'switch' in cls:
            features.add('Toggle/Switch')
        if 'drawer' in cls or 'modal' in cls or 'popup' in cls:
            features.add('Drawer/Modal')
        if 'filter' in cls or 'chip' in cls:
            features.add('Filter/Chips')
        if 'banner' in cls:
            features.add('Banner')
        if 'tab' in cls:
            features.add('Tabs')
        if 'progress' in cls or 'bar' in cls:
            features.add('Progress Bar')
    
    print(f"\n## {fname.replace('kandidat_', '').replace('.html', '')}")
    print(f"**Features**: {', '.join(sorted(features)) if features else 'Basic'}")
    print(f"**Classes**: {', '.join(set(c.split()[0] for c in classes if c))[:200]}")
    
    # Extract section titles
    sections = []
    for t in texts:
        if len(t) < 50 and t[0].isupper():
            if any(x in t for x in ['bersicht', 'Briefing', 'Werdegang', 'Assessment', 'Jobbasket', 'Prozesse', 'History', 'Dokumente', 'Reminders', 'Analyse', 'Vergleich', 'Teamrad']):
                continue
            sections.append(t)
    
    if sections:
        print(f"**Sections**: {', '.join(sections[:10])}")

