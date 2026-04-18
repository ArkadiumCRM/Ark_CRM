---
name: ark-autorefine
description: Use for iterative Phase-1 cleanup loop. Picks open nachbearbeitung-punkt, identifies affected files, runs baseline lint, drafts patch proposal with rationale, waits for Peter-OK before applying. Karpathy-autoresearch-pattern adapted for spec/mockup-refinement. Trigger when Peter says "autorefine", "next cleanup", or when running orchestrator script.
---

# ARK Autorefine Loop

Iterativer Cleanup-Loop für Phase-1-Abschluss. Adaptiert Karpathy's autoresearch-Pattern (agent iterates → validator checks → keep/discard) für ARK-Specs/Mockups.

## Safety: Human-in-the-Loop (MVP)

**Assistant applied NIE automatisch Patches ohne Peter-OK.** Autoresearch-Pattern wird defensive ausgelegt:
1. Agent schlägt Patch vor mit Begründung
2. Peter approves/rejects/refines
3. Dann Edit

Später (v2) kann auto-apply für SAFE-Kategorien (Umlaute-fixes, Stammdaten-Synonyme) aktiviert werden.

## Loop-Struktur

### Phase 1 — Target-Auswahl
Read `wiki/meta/detailseiten-nachbearbeitung.md`. Pick den **ersten noch offenen** Punkt (nicht gestrichen, nicht als "Abgearbeitet" markiert). Falls Peter einen spezifischen Punkt nennt, den nehmen.

### Phase 2 — Baseline messen
Vor jeder Änderung:
1. Identifiziere betroffene Files aus Nachbearbeitungs-Punkt ("Betroffene Specs: ...")
2. Run `ark-lint.ps1` auf jede Datei → Violations-Count-Baseline
3. Run `ark-drift-scan.ps1 L2` → Drift-Baseline (spec-mockup-sync)
4. Log Baseline in `wiki/meta/autorefine-log.md`

### Phase 3 — Patch-Draft
Präsentiere Peter:

```
## Autorefine · [Punkt-Name]

**Scope:** [Kurzbeschreibung aus nachbearbeitung.md]
**Betroffene Files:** [Liste]
**Baseline-Violations:** N (Details: ...)
**Baseline-Drift:** M (Details: ...)

**Vorschlag:**
1. [Change A in File X, Zeile Y]  → Reason: [warum]
2. [Change B in File Z, Zeile W]  → Reason: [warum]
…

**Risiko:** [Cross-module impact? Breaking changes?]
**Expected Post-Change:** Violations ≤ K, Drift ≤ L

OK zu applyen? (y/n/refine)
```

### Phase 4 — Apply (nur bei y)
Nach Peter-OK:
1. Backup affected files (per `backup-before-bulk` skill)
2. Apply Edits via Edit-Tool
3. Re-run `ark-lint` + `ark-drift-scan`
4. Compare: Violations decrease? Drift decrease? Keine neuen regressions?
5. Falls Verbesserung → log "kept" in autorefine-log.md
6. Falls Regression → rollback via Backup, log "reverted"

### Phase 5 — Punkt abhaken
In `wiki/meta/detailseiten-nachbearbeitung.md` den Punkt als **"Abgearbeitet 2026-XX-XX via autorefine"** markieren. Falls noch nicht vollständig: "Teilweise abgearbeitet" + offene Sub-Punkte.

### Phase 6 — Loop?
Frage Peter: "Weiter zum nächsten Punkt, oder Pause?" Bei y → Phase 1 neu. Bei n → stop + Summary.

## Orchestrator-Script

Manuelle Invocation:
```bash
python scripts/autorefine/run.py
```
Script führt den kompletten Loop durch, aber alle Patch-Proposals gehen über den Assistant an Peter (nicht script-direkt-apply).

## Auto-Apply SAFE-Categories (v2, später)

Diese Pattern-Types dürfen ohne Peter-OK gefixt werden (später ausrollen):
- Umlaute: `ae`→`ä`, `oe`→`ö`, `ue`→`ü`, `Ae`→`Ä`, `Oe`→`Ö`, `Ue`→`Ü`, `ss`→`ß` (nur in Wörtern die im Duden mit ß stehen — sensitive!)
- Stammdaten-Synonyme mit 1:1-Mapping aus `mockup-baseline.md §16`: "Retainer"→"Target", "Board"→"vr_board", etc.
- DB-Tech in User-facing Position mit bekanntem Alias aus Baseline

UNSAFE (immer Peter-OK):
- Struktur-Änderungen (Tab-Reordering, Section-Merge)
- Neue Enums / neue Stammdaten-Einträge
- Cross-File-Refactorings
- Anything that touches `Grundlagen MD/*.md`

## Integration mit existierenden Skills

- Vor Edit: `backup-before-bulk`
- Validator: `ark-lint` (orchestriert stammdaten/umlaute/db-techdetails/mockup-drift/drawer-default)
- Sync-Check: `spec-sync-check` nach Edit
- Saga-Check: `saga-trace` falls Saga-relevante Files geändert

## Log-Format `wiki/meta/autorefine-log.md`

Append-only, newest on top:
```
## [YYYY-MM-DD HH:MM] <Punkt-Name>
- **Files:** [Liste]
- **Violations Before/After:** N → K
- **Drift Before/After:** M → L
- **Outcome:** kept | reverted | partial
- **Peter-Feedback:** [falls refinement vorgeschlagen]
```

## Warum kein vollautonomer Overnight-Loop (yet)

Karpathy's Autoresearch läuft overnight weil:
- Validator ist quantitativ (val_bpb, eine Zahl)
- Experiment-Space ist eng (nur train.py)
- False-Positives sind billig (nächstes Experiment)

Bei ARK:
- Validator ist semantic (Spec-Konsistenz, nicht nur Count)
- False-Positive-Cost hoch (Peter muss Changes reviewen bei Drift)
- Business-Context oft nicht im Lint (Arkadium-Rolle, Schutzfrist-Semantik)

→ **Human-in-Loop ist richtig für ARK.** Vollautomation erst nach 20+ erfolgreich-iterierten Zyklen, wenn Patterns gefestigt sind.

## Related

- [[detailseiten-nachbearbeitung]] — Quelle der Cleanup-Punkte
- [[autorefine-log]] — Log aller Runs
- [[decisions]] — Autoresearch-Entscheidung dokumentiert
