---
description: Evidence-based 10-expert deep code review with cross-impact, ARK-specific checks, deployment-readiness
model: claude-opus-4-6
---

Lies docs/AUDIT_PROMPT.md und führe das Evidence-Based Code Review v3.2 FINAL aus.

10 Experten mit Evidenzpflicht, Reifegradmodell (✅/⚠️/❌/➖/🔄), Confidence, nummerierte Findings [SEV-NNN] mit Code-Fixes, positive Befunde pro Experte.

Phase 0: Inventory + Scope (Focus-Mode bei >15k LoC)
Phase 1: 10 Experten (max 10 Findings + 2-3 positive pro Experte)
Phase 1.5: Cross-Impact (Best-Effort, mit Confidence)
Phase 2: Statische Analyse + ARK-spezifische Checks (tenant_id, Hard Delete, Auth, row_version)
Phase 3: Executive Summary + gewichteter Score + Deployment-Readiness + Baseline-Tracking

Regel 11: Falls Analyse-Tiefe abnimmt → stoppe und melde statt oberflächlich weiterzumachen.
Regel 12: Bei Focus-Mode → Security/DB/Datenschutz volle Tiefe, Performance/Quality/API reduziert.

Gib Report als EINEN kopierbaren Text. Keine Rückfragen.
