---
name: spec-sync-check
description: Use AFTER editing any file in specs/ARK_*.md or raw/Ark_CRM_v2/ARK_*.md for the ARK CRM project. Enforces Spec-Sync-Regel - 5 Grundlagen-Dateien (STAMMDATEN, DATABASE_SCHEMA, BACKEND_ARCHITECTURE, FRONTEND_FREEZE, GESAMTSYSTEM) must stay in sync with 9 Detailmasken-Specs and mockups/*.html. Trigger after any schema, enum, endpoint, routing, UI-pattern change.
---

# Spec-Sync-Check für ARK CRM

Bei Änderung an Spec-/Grundlagen-Datei prüfen welche anderen Dateien nachgezogen werden müssen.

## Die 5 Grundlagen-Dateien (`raw/Ark_CRM_v2/`)

1. `ARK_STAMMDATEN_EXPORT_v1_*.md` — Enums, `dim_*`-Inhalte
2. `ARK_DATABASE_SCHEMA_v1_*.md` — Tabellen, Spalten, Constraints
3. `ARK_BACKEND_ARCHITECTURE_v2_*.md` — Endpunkte, Events, Worker, Sagas
4. `ARK_FRONTEND_FREEZE_v1_*.md` — UI-Patterns, Routing, Design-System
5. `ARK_GESAMTSYSTEM_UEBERSICHT_v1_*.md` — Gesamtbild, Changelog

## Die 9 Detailmasken-Specs (`specs/`)

Pattern: `ARK_<ENTITY>_SCHEMA_v*.md` + `ARK_<ENTITY>_INTERACTIONS_v*.md`

Entities: `ACCOUNTS`, `CANDIDATES`, `JOBS`, `MANDATES`, `PROJECTS`, `PROCESSES`, `PLACEMENTS`, `ACTIVITIES`, `TAGS` (exakte Liste in `wiki/meta/spec-sync-regel.md` prüfen)

## Sync-Matrix (read from `wiki/meta/spec-sync-regel.md` authoritativ)

### Bei Edit Grundlagen → prüfe Specs + Mockups

| Geändert in Grundlage | Prüfen in |
|----------------------|-----------|
| STAMMDATEN: neuer Enum-Wert | alle 9 Specs (Schema + Interactions), alle Mockups mit Dropdown/Filter |
| DATABASE_SCHEMA: neue Spalte/Tabelle | entsprechende Entity-Spec, Backend-Datei, relevante Mockups |
| BACKEND_ARCHITECTURE: neuer Endpoint/Event | Interactions-Spec + Mockup-Drawer |
| FRONTEND_FREEZE: UI-Pattern-Change | alle Mockups |
| GESAMTSYSTEM: Changelog | keine direkte Prüfung, aber Wiki-Index updaten |

### Bei Edit Spec → prüfe Grundlagen

| Geändert in Spec | Prüfen in |
|------------------|-----------|
| Schema-Spec: neue Spalte | DATABASE_SCHEMA |
| Interactions-Spec: neuer Event/Endpoint | BACKEND_ARCHITECTURE |
| Interactions-Spec: neues UI-Pattern | FRONTEND_FREEZE |
| Beide: neuer Enum | STAMMDATEN_EXPORT |

## Workflow

1. **Nach Edit**: Identifiziere Datei-Typ (Grundlage vs Spec vs Mockup)
2. **Matrix konsultieren**: Welche Nachbarn kippen?
3. **Read `wiki/meta/spec-sync-regel.md`** für detaillierte/aktuelle Mappings
4. **Report**:
   ```
   SPEC-SYNC-REQUIRED
   Geändert: <file>
   Betroffen:
     - <file-1> — <Grund>
     - <file-2> — <Grund>
   ```
5. **User fragen**: Sync jetzt oder deferred? Nie silently skippen.

## Mockups-Sync

`mockups/*.html` müssen mit FRONTEND_FREEZE und relevanten Interaction-Specs im Gleichschritt bleiben. Bei UI-Pattern-Change (z.B. Drawer-Width, Pipeline-Component) **alle** Mockups scannen.

## Anti-Pattern

- Schema in einer Datei ändern, andere vergessen
- Enum in STAMMDATEN hinzufügen aber Dropdown in Mockup fehlt
- Saga-Step in BACKEND dokumentiert aber Drawer-Preview zeigt ihn nicht
- Neue Detailmaske in Spec, aber Routing-Tabelle in FRONTEND_FREEZE nicht erweitert
