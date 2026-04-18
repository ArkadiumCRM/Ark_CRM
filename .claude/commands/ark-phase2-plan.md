---
description: Plant ein Phase-2/3-Modul (ERP-Module). Scoping, Schema-Entwurf, Mockup-Prompt für Claude Design
---

Du planst ein neues ARK-Modul aus der Phase-2/3-Liste (Zeiterfassung · Buchhaltung · Payroll · Messaging · Publishing · RAG · Matching · Dok-Generator-Detail · Kanban · Report-Generator · oder User-defined).

## Workflow

### 1. Modul-Wahl klären
Falls User kein Modul genannt: Frage welches aus obiger Liste. Falls User custom nennt: in Gesamt-Plan einordnen (Phase 2 vs 3).

### 2. Kontext sammeln (Grundlagen-Digests nutzen, nicht Volltext)
- `wiki/meta/digests/gesamtsystem-digest.md` — wo das Modul im System sitzt
- `wiki/meta/digests/database-schema-digest.md` — welche Tabellen relevant/neu nötig
- `wiki/meta/digests/backend-architecture-digest.md` — welche Events/Worker/Sagas touched
- `wiki/meta/digests/stammdaten-digest.md` — welche Enums brauchbar/neu nötig

### 3. Scoping-Draft schreiben
Output an Peter:
```
## Modul [Name] · Phase [2/3] · Scoping-Draft

### Ziel
[1 Satz: was macht das Modul]

### Tabs (UI-Grobstruktur)
- Tab 1: [Name]
- Tab 2: [Name]
…

### DB-Impact
- Neue Tabellen: [Liste mit Name + Zweck]
- Änderungen an bestehenden: [Liste]
- Neue Enums: [Liste]

### Backend-Impact
- Neue Events: [Liste]
- Neue Worker: [Liste]
- Neue Endpunkte: [Grobe Zahl + Kategorien]

### Cross-Module-Dependencies
- Hängt ab von: [Module]
- Wird genutzt von: [Module]

### Offene Fragen (brauchen Peter-Input)
1. ...
2. ...

### Nächster Schritt
(a) Claude-Design-Prompt generieren für Mockup
(b) Oder direkt HTML-Mockup + Spec schreiben
```

### 4. Auf Peter warten
Peter entscheidet (a) oder (b) oder "erst Fragen klären". NICHT proaktiv weitermachen ohne Peter-OK.

### 5a. Claude-Design-Prompt (wenn Peter (a) wählt)
Generiere copy-paste-ready Prompt für claude.ai/design:
- ARK-Styling-Referenz: `mockups/candidates.html` als Baseline
- 540px slide-from-right Drawer für CRUD
- Snapshot-Bar sticky oben
- Dark-Default, Light-Mode-toggleable
- Tab-Navigation unter Snapshot-Bar
- Konkreter Feature-Scope aus Scoping-Draft

Peter geht dann claude.ai/design → iteriert → kommt mit Handoff-Bundle zurück.

### 5b. Direkter Mockup-Build (wenn Peter (b) wählt)
Skills aktivieren: `backup-before-bulk`, `stammdaten-lint`, `umlaute-lint`, `db-techdetails-lint`, `drawer-default-guard`, `mockup-drift-check`. Dann HTML-Mockup analog candidates.html-Pattern bauen. Danach Spec-Entwurf in `specs/ARK_[MODUL]_DETAILMASKE_SCHEMA_v0_1.md`.

## Regeln
- Kein Phase-2-Modul ohne Phase-1-Cleanup-Abschluss (`wiki/meta/detailseiten-nachbearbeitung.md`). Bei Verstoß: warnen + Peter-Confirm einholen.
- Grundlagen-Digests reichen, Volltext nur bei Peter-Freigabe.
- Neue Entscheidungen → `wiki/meta/decisions.md` eintragen.
