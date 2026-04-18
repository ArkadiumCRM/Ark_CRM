---
title: "Audit Final — Konsolidiert 2026-04-14"
type: analysis
created: 2026-04-14
updated: 2026-04-14
sources: ["audit-2026-04-13-komplett.md", "audit-entscheidungen-2026-04-14.md", "7-agent-review"]
tags: [audit, final, konsistenz, gaps, roadmap]
---

# Audit Final — Konsolidiert 2026-04-14

Synthese der 7 parallelen Audit-Agenten (Datenmodell, Backend, Frontend, Cross-Spec, E2E-Workflows, Automation, Zwänge/RBAC) nach Abschluss von Schritt 4 (Kandidaten v1.3).

## Executive Summary

Das ARK-CRM-System ist nach 9 Detailseiten + Stammdaten v1.3 + DB v1.3 + Backend v2.5 + Frontend v1.10 **strukturell komplett**. Die verbleibenden Gaps sind **Konsistenz- und Cleanup-Arbeiten**, keine fundamentalen Modelllücken mehr. Drei Kategorien:

- **P0 Blocker** (6 Punkte): Inkonsistenzen, die aktiv widersprechen — müssen gefixt werden, bevor Implementation startet.
- **P1 Important** (8 Punkte): Fehlende Spezifikationen, die beim Implementieren auftauchen würden.
- **P2 Polish** (5 Punkte): Verbesserungen, die die Qualität heben, aber Implementation nicht blockieren.

---

## P0 — Blocker (müssen vor Implementation gefixt werden)

### P0.1 — `kandidat_id` → `candidate_id` in 15 Specs

**Status:** 15 Dateien enthalten noch `kandidat_id` (inkl. 3 in `/specs/alt/` — die dürfen bleiben).
**Aktiv zu fixen:** 12 Dateien in `/specs/` (nicht `/alt/`).
**Warum:** Sprachstandard laut Entscheidung #6 → alle FKs/Spalten englisch.
**Action:** Batch find-replace `kandidat_id` → `candidate_id` in allen 12 aktiven Specs.

### P0.2 — Account-Schema v0.1 → v0.2 mit Tab 8/9

**Warum:** Interactions v0.3 referenziert Tab 8 Assessments + Tab 9 Schutzfristen, Schema v0.1 dokumentiert nur 7 Tabs → Widerspruch.
**Action:** Account-Schema v0.2 erstellen mit Tabs 8 (Assessments, typisierte Credits-Übersicht) + 9 (Schutzfristen, Scope-Badge 🏢/🏛, AM-Claim).

### P0.3 — Mandat-Schema v0.1 → v0.2

**Gaps:**
- `is_longlist_locked BOOLEAN` fehlt (Kündigungs-Flow benötigt)
- RBAC für Kündigung sagt noch "AM + Admin" → laut Entscheidung #4 ist es **AM alleine**
- 3-Fälle-Claim-Definitionen (X/Y/Z) nicht explizit dokumentiert

**Action:** Schema v0.2 mit longlist_locked, RBAC-Fix, Claim-Fälle-Sektion.

### P0.4 — Version-Cross-References in 7 Specs veraltet

**Problem:** 7 Specs verlinken noch auf v0.2-Dateien, obwohl v0.3 aktuell ist (Mandat-Interactions, Account-Interactions).
**Action:** Grep-Pass über alle Specs, alle Versionsreferenzen auf neuesten Stand bringen.

### P0.5 — Placement-TX 8-Step Validierungen

**Problem:** Backend v2.5 listet Saga TX1 (Placement 8-Step), aber Prozess-Interactions v0.1 dokumentiert die Validierungen nicht (z.B. Schutzfrist-Check, Credit-Decrement, Payment-Trigger).
**Action:** TX1-Steps explizit in Prozess-Interactions ergänzen.

### P0.6 — TX3 (Mandat-Kündigung) unvollständig

**Gaps:** Longlist-Locking-Step + Schutzfrist-Scope-Qualification-Step in Saga-Definition fehlen.
**Action:** Backend v2.5 TX3 um beide Steps erweitern, mit Mandat-Interactions v0.3 abgleichen.

---

## P1 — Important (vor Go-Live nötig)

### P1.1 — Fehlende Workers in Backend v2.5

- `shortlist-trigger-payment-worker` (Shortlist-Stage → Zahlungs-Auslösung Stage 1)
- `outlook-calendar-sync-worker` (bidirektional)
- `stale-notification-worker` (Reminder 48h/7d)
- `process-closed-archiving-worker` (Prozess-Archiv nach Abschluss)
- `protection-window-auto-extension-worker` (10-Tage-Scheduler)

### P1.2 — Fehlende Endpunkte

- `POST /api/v1/projects/link` (Werdegang → Projekt)
- `POST /api/v1/projects/quick-create` (Mini-Drawer)
- `GET/POST/PATCH /api/v1/projects/:id/participations` (CRUD)
- `POST /api/v1/media/upload` (unified)

### P1.3 — Algorithmische Spezifikationen

- **Fuzzy-Match-Algorithmus** Projekt-Autocomplete: Schwellwerte dokumentiert (85/60), aber Metrik (Trigram? Levenshtein? pg_trgm?) nicht.
- **UID-Root-Matching** Firmengruppen: Logik nicht spezifiziert.
- **Honorar-Staffel** für Claim-Billing: dim_honorar_settings existiert, aber Berechnungslogik fehlt.

### P1.4 — Matching-Weights Projekt-Overlay

Stammdaten v1.3 listet `dim_matching_weights_project`, aber keine Spec beschreibt, wie Overlay zu Base-Weights berechnet wird.

### P1.5 — Scraper needs_am_review Eskalation

Scraper-Interactions v0.1 definiert 60-84% → `needs_am_review`, aber SLA/Eskalation (nach X Tagen → Admin?) fehlt.

### P1.6 — Assessment Order Umwidmung — UI-Flow

Schema v0.2 Constraint: Umwidmung nur innerhalb desselben assessment_type. UI-Flow in Interactions v0.2 fehlt (wie wählt User Ziel-Kandidat/Job?).

### P1.7 — Projekt SIA hierarchische Validation

Schema v0.2 hat 6 Haupt + 12 Teilphasen. Validierung "Teilphase braucht Hauptphase-Kontext" fehlt in Interactions.

### P1.8 — Kandidaten-Jobbasket Protection-Window-Badge Query

Interactions v1.3 beschreibt Badge, aber exakte SQL-Query (UNION account + group scope) fehlt.

---

## P2 — Polish

### P2.1 — Event-Katalog in Backend v2.5 vs. Interactions abgleichen
Einige Events sind in Specs referenziert, aber nicht im zentralen Katalog.

### P2.2 — WebSocket-Channel-Namenskonvention
Channels ad-hoc benannt (`mandate:{id}`, `project-list`). Einheitliche Konvention `<entity>:<scope>:<id>` wäre sauberer.

### P2.3 — RBAC-Matrix als eigene Seite
Aktuell verteilt über 9 Specs — zentrale Matrix `wiki/meta/rbac-matrix.md` wäre Single-Source-of-Truth.

### P2.4 — Dark-Mode Farb-Tokens
Frontend v1.10 erwähnt Dark Mode, aber Token-Liste (Semantic Colors) fehlt.

### P2.5 — Audit-Log-Retention
Policy (Retention-Zeit, Archivierung) nicht definiert.

---

## Action Plan (Empfehlung)

**Phase A — Cleanup (geschätzt 1 Session):**
1. P0.1 Batch-Rename `kandidat_id` → `candidate_id`
2. P0.4 Version-Cross-References fixen
3. P0.3 Mandat-Schema v0.2
4. P0.2 Account-Schema v0.2

**Phase B — Konsistenz (1 Session):**
5. P0.5 TX1 Placement-Validierungen
6. P0.6 TX3 Kündigungs-Saga komplettieren
7. P1.1 Worker-Specs
8. P1.2 Endpunkte

**Phase C — Algorithmen (1 Session):**
9. P1.3 Fuzzy/UID/Honorar
10. P1.4–P1.8 Detail-Gaps

**Phase D — Polish (optional):**
11. P2.*

---

## Related

[[detailseiten-inventar]], [[audit-2026-04-13-komplett]], [[audit-entscheidungen-2026-04-14]], [[status-enum-katalog]]
