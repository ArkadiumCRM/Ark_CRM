---
title: "AI-System"
type: concept
created: 2026-04-08
updated: 2026-04-08
sources: ["ARK_GESAMTSYSTEM_UEBERSICHT_v1_2.md", "ARK_BACKEND_ARCHITECTURE_v2_4.md"]
tags: [concept, ai, matching, rag, governance]
---

# AI-System

Grundprinzip: **AI schreibt nie direkt.** Immer Vorschlag → Mensch bestätigt.

## AI Governance

Gesteuert durch `dim_ai_write_policies` — 4 Policy-Typen:

| Policy | Beschreibung | Beispiel |
|--------|-------------|---------|
| `suggest_only` | Nur Vorschlag, Mensch muss bestätigen | Activity-Type-Vorschlag |
| `auto_after_review` | Auto nach Review | Duplikat-Erkennung |
| `auto_allowed` | Vollautomatisch | `ai_summary` Felder |
| `forbidden` | AI darf nicht schreiben | `candidate_stage`, `is_do_not_contact` |

**KPI:** AI-Bestätigungsrate wird getrackt (wie oft bestätigt vs. abgelehnt).

## AI-Funktionen

### Klassifizierung
- Activity-Type-Vorschlag (1-Klick Bestätigung)
- Email-Klassifizierung (Template-basiert auto, unbekannt via AI)
- Kandidaten-Klassifizierung (Generalist/Specialist, Seniority, Culture Fit)

### Transkription & Summary
- Call-Transkription via [[telefonie-3cx]]
- AI-Summary von Anrufen
- Action Items aus Gesprächen
- Red Flags erkennen

### Briefing Auto-Fill
- Aus Call-Transkripten → Briefing-Felder vorausfüllen
- Aus LinkedIn-Profil → Stammdaten

### RAG (Retrieval Augmented Generation)
- Text Chunking → pgvector Embeddings (1536d)
- Cosine Similarity Search
- Tenant-gefiltert
- Chunks in `dim_embedding_chunks`, Embeddings in `fact_embeddings`

### Matching
7 Sub-Scores (0-100):
1. Sparte
2. Function
3. Salary
4. Location
5. Skills (Focus)
6. Availability
7. Experience

Scores historisiert in `fact_match_scores`. Explainbar via `match_breakdown_json` — **kein Blackbox**.

### Duplikat-Erkennung
- Kandidaten: `v_candidate_duplicates` (Name, Email, Telefon, LinkedIn)
- Accounts: `v_account_duplicates` (Firmenname, Domain, Handelsregister-UID)

### Dokumenten-Pipeline
Upload → OCR → CV Parsing → Embedding → AI-Vorschläge

## AI-Suggestions Workflow

`fact_ai_suggestions` — Queue mit Lifecycle:
1. AI erstellt Suggestion (add function, update stage, match candidate, merge)
2. Erscheint im AI Review Inbox + Dashboard Badge
3. User: Accept / Reject / Modify
4. Bei Accept: Suggestion wird ausgeführt
5. Eskalation: 24h → 48h → Head_of

### Confidence Thresholds (Frontend)

| Score | Darstellung |
|-------|-------------|
| ≥ 0.8 | Prominenter Accept-Button |
| 0.5-0.8 | Normal |
| < 0.5 | Warning + Secondary Button |

Kein Auto-Accept unter 0.5.

## Backpressure

- Max 5 AI Jobs concurrent pro Tenant
- Max 100 AI Jobs/Stunde pro Tenant
- LLM Follow-up Jobs rate-limited (30/min)

## Provider

Provider-abstrakt via Adapters (OpenAI + Anthropic). Prompt Templates versioniert in `dim_prompt_templates`. PII reduziert vor LLM-Calls.

## Related

- [[event-system]] — AI-Events (match.suggestion_ready, history.ai_summary_ready)
- [[automationen]] — AI-getriggerte Automationen
- [[matching]] — 7 Sub-Scores, Explainability
- [[briefing]] — Auto-Fill aus Transkripten
