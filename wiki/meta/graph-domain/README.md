---
title: "Graph Domain — ARK Wiki Knowledge-Graph"
type: meta
created: 2026-04-30
updated: 2026-04-30
sources: ["wiki/concepts/", "wiki/entities/", "wiki/meta/"]
tags: [graph, knowledge-graph, graphify, domain]
---

# Graph Domain — ARK Wiki Knowledge-Graph

Persistente Domain-Wissens-Graph-Snapshots aus `wiki/concepts/` + `wiki/entities/` + `wiki/meta/`. Generiert **2026-04-30** mit deterministischer Markdown-Extraction (Frontmatter + Wikilinks + `## Related` + `sources:`-Refs + Tag-Overlap-Inferenz). Kein LLM-Call, vollständig reproduzierbar.

## Warum hier statt `graphify-out/`?

`/graphify-out/` lebt im Project-Root und wird automatisch vom Scheduled-Task `run_graphify_all.ps1` (Code-Graph aller Repos) **überschrieben** — der schaut nur AST-basiert auf Mockup-JS und produziert ~54 Code-Nodes. Damit der Domain-Graph nicht verloren geht, leben die persistenten Outputs hier:

| File | Zweck |
|------|-------|
| `graph.html` | Interaktive Visualisierung (Browser) |
| `graph.json` | Graphdaten (NetworkX node_link_data) |
| `GRAPH_REPORT.md` | Audit-Report mit God-Nodes, Communities, Surprises, Suggested Questions |
| `extraction.json` | Roher Extraction-Output (Re-Cluster ohne Re-Extraction) |

## Stand 2026-04-30

- **211 Nodes** · **531 Edges** · **13 Communities**
- **97 % EXTRACTED** · 3 % INFERRED · 0 % AMBIGUOUS
- **Token-Reduktion:** 53.9× ggü. naivem Volltext-Read pro Query (5.3k Tokens statt 286k)

### Top God-Nodes (Bridge-Konzepte)

1. ARK CRM — Gesamtübersicht (36 edges)
2. Kandidat (32)
3. Mandat (31)
4. Account (22)
5. Prozess (21)
6. Admin-System (19)
7. Automationen (19)
8. Direkteinstellung & 12/16-Monats-Schutzfrist (19)
9. Dok-Generator (18)
10. Job (18)

### 13 Communities

1. Account & Kandidat-Beziehungen (37 Nodes)
2. Assessment & RAG-Backend (32)
3. Admin-System & AI-Governance (32)
4. Decisions, Action-Items & Lint (28)
5. Matching & Scoring-Algorithmen (27)
6. Commission & Mandat-Billing (21)
7. System-Digests & Performance-Decisions
8. HR-Tabellen (Academy, MA, Reglemente)
9. Design-System & Dokumente-Profile
10. Schutzfrist/Garantie/AGB-ADRs
11. Performance-Tables (Insights/Actions)
12. Drawer-Pattern & Detailseiten-Guideline
13. Audit-Log, DSGVO & Retention

### Surprising Connections

- `Backend-Architektur` ↔ `Backend Architecture Digest v2.8` (Tag-Overlap-Inferenz)
- `Datenbank-Schema` ↔ `Database Schema Digest v1.6`
- `Account` ↔ `Prozess` (Cross-Entity-Beziehung)
- `Firmengruppe` ↔ `Mandat` (Mandate können firmengruppen-weit sein)
- `E-Learning Modul Handover` → `Interaction Patterns` (UI-Konsistenz)

## Re-Generation

Bei Markdown-Edits in `wiki/concepts/`, `wiki/entities/`, `wiki/meta/` re-extracten — Graph bleibt deterministisch. Pipeline-Skripte werden bei Bedarf neu erstellt aus diesem Snapshot (siehe `extraction.json` als Referenz-Schema).

## Brain-Ingest (offen)

Community-Summaries werden **NICHT** automatisch ins Brain ingestiert — Ollama-Embedding ~9 sek auf CPU, Beelink+RTX-5090 effizienter. Brain-Ingest läuft später auf Beelink+5090 wenn angeschlossen:

```
cd C:/Projects/Work_Brain
python scripts/ingest_graphify_to_brain.py
```

## Cross-Project

Der ARK-Domain-Graph ist Teil des Cross-Repo-Merge-Graphs in [[Repos/_Repos Index|Repos Index]] (Vault). Topic-Cluster mit anderen Projekten (RAG_FHNW Matching, Reporting_Projekt KPIs) dort dokumentiert.

## Related

- [[../decisions]] — ARK ADR-Log
- [[../anti-patterns]] — Anti-Pattern-Catalog (eigene Community)
- [[../mockup-baseline]] — UI-Pattern-Baseline (Drawer-Default-Community)
- [[../spec-sync-regel]] — Spec-Sync-Governance (eigene Community)
