import re
from pathlib import Path
from collections import defaultdict

files_map = {
    "1. kandidat_uebersicht_v8.html": "Übersicht",
    "2. kandidat_briefing_v3.html": "Briefing",
    "3. kandidat_werdegang_v2.html": "Werdegang",
    "5. kandidat_jobbasket_v2.html": "JobBasket",
    "6. kandidat_prozesse_v2.html": "Prozesse",
    "7. kandidat_history_v2.html": "History",
    "8. kandidat_dokumente_v2.html": "Dokumente",
    "9. kandidat_dokgenerator_v2.html": "Dok-Generator",
    "10. kandidat_reminders_v2.html": "Reminders",
    "kandidat_ai_analyse_v2.html": "AI-Analyse",
    "kandidat_assessment_Gesamtüberblick_v2.html": "Assessment",
    "kandidat_scheelen_6_HM_v2.html": "Scheelen HM",
    "kandidat_teamrad_v2.html": "Teamrad",
    "kandidat_vergleich_v2.html": "Vergleich",
}

for fname, label in files_map.items():
    fpath = Path(fname)
    if not fpath.exists():
        continue
    
    try:
        content = fpath.read_text(encoding='utf-8', errors='ignore')
    except:
        continue
    
    # Extract key patterns
    print(f"\n## {label}")
    
    # Find commented sections
    comments = re.findall(r'/\*\s*===\s*([^=]+)\s*===\s*\*/', content)
    if comments:
        print(f"**Sections**: {' | '.join(comments[:5])}")
    
    # Look for specific features
    has_spider = 'spider' in content.lower() or 'chart' in content.lower() or 'svg' in content
    has_timeline = 'timeline' in content or 'tl-' in content
    has_banner = 'banner' in content
    has_modal = 'modal' in content or 'drawer' in content or 'popup' in content
    has_filter = 'filter' in content or 'chip' in content
    has_grid = 'grid' in content or '.grid' in content
    
    features = []
    if has_spider:
        features.append('Spider/Chart/Gauge')
    if has_timeline:
        features.append('Timeline')
    if has_banner:
        features.append('AI-Banner/Alert-Box')
    if has_modal:
        features.append('Modal/Drawer/Popup')
    if has_filter:
        features.append('Filter/Chips/Tags')
    if has_grid:
        features.append('Grid-Layout')
    
    # Extract visible content sections
    texts = re.findall(r'>([^<>{]{5,100})<', content)
    texts = [t.strip() for t in texts if t.strip() and len(t) > 4]
    
    # Identify cards/sections from text
    sections_found = []
    for t in texts:
        if len(t) < 60 and t[0].isupper():
            # Skip nav items and common headers
            if not any(x in t for x in ['bersicht', 'Briefing', 'Werdegang', 'Assessment', 'Basket', 
                                         'Prozesse', 'History', 'Dokumente', 'Reminders', 'Active', 
                                         'Max Muster', 'Kandidaten', 'Ctrl+K']):
                if t not in sections_found and len(t) > 2:
                    sections_found.append(t)
    
    if features:
        print(f"**Features**: {' | '.join(features)}")
    
    if sections_found:
        print(f"**Content Areas**: {' | '.join(sections_found[:8])}")

