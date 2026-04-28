# Graph Report - Ark_CRM  (2026-04-27)

## Corpus Check
- 21 files · ~5,281,420 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 54 nodes · 58 edges · 4 communities detected
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- [[_COMMUNITY_Community 0|Community 0]]
- [[_COMMUNITY_Community 3|Community 3]]
- [[_COMMUNITY_Community 4|Community 4]]
- [[_COMMUNITY_Community 9|Community 9]]

## God Nodes (most connected - your core abstractions)
1. `openDrawer()` - 3 edges
2. `drawerTab()` - 3 edges
3. `toggleTag()` - 3 edges
4. `syncSparteHeader()` - 3 edges
5. `saveEdit()` - 3 edges
6. `cancelEdit()` - 3 edges
7. `switchTab()` - 2 edges
8. `toggleTheme()` - 2 edges
9. `toggleCollapse()` - 2 edges
10. `toggleSection()` - 2 edges

## Surprising Connections (you probably didn't know these)
- None detected - all connections are within the same source files.

## Communities

### Community 0 - "Community 0"
Cohesion: 0.21
Nodes (16): closeDrawer(), closeModal(), enterEdit(), filterDocCat(), filterRemStatus(), openModal(), statusMenu(), switchDocView() (+8 more)

### Community 3 - "Community 3"
Cohesion: 1.0
Nodes (2): drawerTab(), openDrawer()

### Community 4 - "Community 4"
Cohesion: 1.0
Nodes (2): cancelEdit(), saveEdit()

### Community 9 - "Community 9"
Cohesion: 1.0
Nodes (2): syncSparteHeader(), toggleTag()

## Knowledge Gaps
- **Thin community `Community 3`** (2 nodes): `drawerTab()`, `openDrawer()`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 4`** (2 nodes): `cancelEdit()`, `saveEdit()`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 9`** (2 nodes): `syncSparteHeader()`, `toggleTag()`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.

## Suggested Questions
_Not enough signal to generate questions. This usually means the corpus has no AMBIGUOUS edges, no bridge nodes, no INFERRED relationships, and all communities are tightly cohesive. Add more files or run with --mode deep to extract richer edges._