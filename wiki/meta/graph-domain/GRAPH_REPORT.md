# Graph Report - wiki  (2026-04-30)

## Corpus Check
- Large corpus: 236 files · ~797,718 words. Semantic extraction will be expensive (many Claude tokens). Consider running on a subfolder, or use --no-semantic to run AST-only.

## Summary
- 211 nodes · 531 edges · 13 communities detected
- Extraction: 97% EXTRACTED · 3% INFERRED · 0% AMBIGUOUS · INFERRED: 15 edges (avg confidence: 0.71)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- [[_COMMUNITY_Account & Kandidat-Beziehungen|Account & Kandidat-Beziehungen]]
- [[_COMMUNITY_Assessment & RAG-Backend|Assessment & RAG-Backend]]
- [[_COMMUNITY_Admin-System & AI-Governance|Admin-System & AI-Governance]]
- [[_COMMUNITY_Decisions, Action-Items & Lint|Decisions, Action-Items & Lint]]
- [[_COMMUNITY_Matching & Scoring-Algorithmen|Matching & Scoring-Algorithmen]]
- [[_COMMUNITY_Commission & Mandat-Billing|Commission & Mandat-Billing]]
- [[_COMMUNITY_System-Digests & Performance-Decisions|System-Digests & Performance-Decisions]]
- [[_COMMUNITY_HR-Tabellen (Academy, MA, Reglemente)|HR-Tabellen (Academy, MA, Reglemente)]]
- [[_COMMUNITY_Design-System & Dokumente-Profile|Design-System & Dokumente-Profile]]
- [[_COMMUNITY_SchutzfristGarantieAGB-ADRs|Schutzfrist/Garantie/AGB-ADRs]]
- [[_COMMUNITY_Performance-Tables (InsightsActions)|Performance-Tables (Insights/Actions)]]
- [[_COMMUNITY_Drawer-Pattern & Detailseiten-Guideline|Drawer-Pattern & Detailseiten-Guideline]]
- [[_COMMUNITY_Audit-Log, DSGVO & Retention|Audit-Log, DSGVO & Retention]]

## God Nodes (most connected - your core abstractions)
1. `ARK CRM — Gesamtübersicht` - 36 edges
2. `Kandidat` - 32 edges
3. `Mandat` - 31 edges
4. `Account` - 22 edges
5. `Prozess` - 21 edges
6. `Admin-System` - 19 edges
7. `Automationen` - 19 edges
8. `Direkteinstellung & 12/16-Monats-Schutzfrist` - 19 edges
9. `Dok-Generator` - 18 edges
10. `Job` - 18 edges

## Surprising Connections (you probably didn't know these)
- `Backend-Architektur` --conceptually_related_to--> `Backend Architecture Digest v2.8`  [INFERRED]
  wiki/concepts/backend-architektur.md → wiki/meta/digests/backend-architecture-digest.md
- `Datenbank-Schema` --conceptually_related_to--> `Database Schema Digest v1.6`  [INFERRED]
  wiki/concepts/datenbank-schema.md → wiki/meta/digests/database-schema-digest.md
- `E-Learning Modul — Handover` --references--> `Interaction Patterns`  [EXTRACTED]
  wiki/meta/elearn-handover.md → wiki/concepts/interaction-patterns.md
- `Account` --conceptually_related_to--> `Prozess`  [INFERRED]
  wiki/entities/account.md → wiki/entities/prozess.md
- `Firmengruppe` --conceptually_related_to--> `Mandat`  [INFERRED]
  wiki/entities/firmengruppe.md → wiki/entities/mandat.md

## Communities

### Community 0 - "Account & Kandidat-Beziehungen"
Cohesion: 0.13
Nodes (37): Diagnostik & Assessment (eigenständige Dienstleistung), Direkteinstellung & 12/16-Monats-Schutzfrist, Target Best Effort (Erfolgsbasis), Garantiefrist (Post-Placement), Honorar-Berechnung, Mandat-Kündigung (Exit Option), Optionale Stages (Mandats-Zusatzleistungen), Provisionierung (Mitarbeiter-Vergütung) (+29 more)

### Community 1 - "Assessment & RAG-Backend"
Cohesion: 0.08
Nodes (32): Reminders, audit-final-2026-04-14, autoresearch, frontend-freeze, reportings-am-cm-tl, ARK Anti-Patterns, ARK Decision Log, Guideline: Detailseiten-Spezifikation (+24 more)

### Community 2 - "Admin-System & AI-Governance"
Cohesion: 0.16
Nodes (32): Assessment, Berechtigungen, Design System — ARK CRM Mockups, Dokumente-Kategorien-Schema (Personal · Commercial · Group · Job · Projekt), Frontend-Architektur, Interaction Patterns, Jobbasket & GO-Flow, Kontakt = Kandidat Regel (+24 more)

### Community 3 - "Decisions, Action-Items & Lint"
Cohesion: 0.08
Nodes (28): Admin-System, Algorithmen, Audit-Log Retention, Design Tokens (Dark + Light Mode), Scraper & Market Intelligence, WebSocket-Channels, backend-architecture, dashboard (+20 more)

### Community 4 - "Matching & Scoring-Algorithmen"
Cohesion: 0.16
Nodes (27): AI-System, Automationen, Backend-Architektur, Briefing, Debuggability, Dokumente, Email-System, Event-System (+19 more)

### Community 5 - "Commission & Mandat-Billing"
Cohesion: 0.1
Nodes (21): Performance-Modul · Konzept, Status-Enum-Katalog, ARK_BACKEND_ARCHITECTURE_v2, ARK_FRONTEND_FREEZE_v1, ARK_GESAMTSYSTEM_UEBERSICHT_v1, ARK_STAMMDATEN_EXPORT_v1_3, audit-entscheidungen-2026-04-14, image.png (+13 more)

### Community 6 - "System-Digests & Performance-Decisions"
Cohesion: 0.26
Nodes (17): HR · Arkadium Academy (Ausbildungssystem), HR · Konkurrenz- + Abwerbeverbot + Karenzentschädigung, HR · MA-Rollen-Matrix (Arbeitsrecht-Lens), HR · Vertragswerk (Arkadium-Anstellungs-Stack), hr-arbeitsvertraege, hr-kuendigung-aufhebung, hr-provisionsvertraege, hr-reglemente (+9 more)

### Community 7 - "HR-Tabellen (Academy, MA, Reglemente)"
Cohesion: 0.23
Nodes (12): Datenbank-Schema, Dok-Generator, Executive Report, Template-Versionierung, kandidatenmaske-schema, operations, ARK_DOK_GENERATOR_INTERACTIONS_v0_1.md, ARK_DOK_GENERATOR_SCHEMA_v0_1.md (+4 more)

### Community 8 - "Design-System & Dokumente-Profile"
Cohesion: 1.0
Nodes (1): Stale

### Community 9 - "Schutzfrist/Garantie/AGB-ADRs"
Cohesion: 1.0
Nodes (1): Weekly Drift Log

### Community 10 - "Performance-Tables (Insights/Actions)"
Cohesion: 1.0
Nodes (1): Mcp Model Watch

### Community 11 - "Drawer-Pattern & Detailseiten-Guideline"
Cohesion: 1.0
Nodes (1): Research-Prompts Phase 3 ERP (Zeit/Billing/Performance)

### Community 12 - "Audit-Log, DSGVO & Retention"
Cohesion: 1.0
Nodes (1): Visual Regression Log

## Knowledge Gaps
- **7 isolated node(s):** `ARK Anti-Patterns`, `Stale`, `Stammdaten Digest v1.6`, `Weekly Drift Log`, `Mcp Model Watch` (+2 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **Thin community `Design-System & Dokumente-Profile`** (1 nodes): `Stale`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Schutzfrist/Garantie/AGB-ADRs`** (1 nodes): `Weekly Drift Log`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Performance-Tables (Insights/Actions)`** (1 nodes): `Mcp Model Watch`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Drawer-Pattern & Detailseiten-Guideline`** (1 nodes): `Research-Prompts Phase 3 ERP (Zeit/Billing/Performance)`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Audit-Log, DSGVO & Retention`** (1 nodes): `Visual Regression Log`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Direkteinstellung & 12/16-Monats-Schutzfrist` connect `Account & Kandidat-Beziehungen` to `Admin-System & AI-Governance`, `Decisions, Action-Items & Lint`, `Matching & Scoring-Algorithmen`, `System-Digests & Performance-Decisions`?**
  _High betweenness centrality (0.179) - this node is a cross-community bridge._
- **Why does `ARK CRM — Gesamtübersicht` connect `Matching & Scoring-Algorithmen` to `Account & Kandidat-Beziehungen`, `Assessment & RAG-Backend`, `Admin-System & AI-Governance`, `Decisions, Action-Items & Lint`, `Commission & Mandat-Billing`, `HR-Tabellen (Academy, MA, Reglemente)`?**
  _High betweenness centrality (0.150) - this node is a cross-community bridge._
- **Why does `HR · Konkurrenz- + Abwerbeverbot + Karenzentschädigung` connect `System-Digests & Performance-Decisions` to `Account & Kandidat-Beziehungen`?**
  _High betweenness centrality (0.139) - this node is a cross-community bridge._
- **Are the 2 inferred relationships involving `Kandidat` (e.g. with `Job` and `Mandat`) actually correct?**
  _`Kandidat` has 2 INFERRED edges - model-reasoned connections that need verification._
- **Are the 2 inferred relationships involving `Mandat` (e.g. with `Firmengruppe` and `Kandidat`) actually correct?**
  _`Mandat` has 2 INFERRED edges - model-reasoned connections that need verification._
- **Are the 2 inferred relationships involving `Prozess` (e.g. with `Account` and `Projekt`) actually correct?**
  _`Prozess` has 2 INFERRED edges - model-reasoned connections that need verification._
- **What connects `ARK Anti-Patterns`, `Stale`, `Stammdaten Digest v1.6` to the rest of the system?**
  _7 weakly-connected nodes found - possible documentation gaps or missing edges._