---
title: "ARK Frontend Freeze v1.10"
type: source
created: 2026-04-08
updated: 2026-04-14
sources: ["ARK_FRONTEND_FREEZE_v1_10.md", "ARK_FRONTEND_FREEZE_v1_9.md"]
tags: [source, frontend, ui, design]
---

# ARK Frontend Freeze v1.10

**Aktuelle Datei:** `raw/Ark_CRM_v2/ARK_FRONTEND_FREEZE_v1_10.md`
**Vorherige Version:** `raw/Ark_CRM_v2/ARK_FRONTEND_FREEZE_v1_9.md` (bleibt erhalten)

## v1.10 (14.04.2026) — Konsolidierung der Detailseiten-Specs

**Ergänzung** zu v1.9, keine Ersetzung. Design-System, Patterns, Shortcuts aus v1.9 bleiben gültig.

### Highlights

1. **Route-Standardisierung auf Englisch** (neu: `/company-groups`, `/projects`, `/assessments`)
2. **Account-Tabs 10 → 13 + 1 konditional** (+Assessments, +Schutzfristen, +Reminders)
3. **Prozess-Architektur Mischform** (Drawer-Primary, schlanke 3-Tab-Detailseite)
4. **5 neue Detailseiten-Kapitel** (4d.4–4d.8): Jobs, Firmengruppen, Assessments, Projekte, Scraper
5. **Status-Enum-Sprache** intentional gemischt (Mandat/Job deutsch, Prozess/Assessment englisch)
6. **Snapshot-Bar** max. 7 Slots
7. **Breadcrumb-Tiefe:** 2-stufig Default, 4-stufig bei Sub-Entitäten mit Parent-Kontext

### Neue Detailseiten-Kapitel

| Kapitel | Entity | Tabs |
|---------|--------|------|
| 4d.4 | Jobs | 6 |
| 4d.5 | Firmengruppen | 6 |
| 4d.6 | Assessments (typisierte Credits) | 5 |
| 4d.7 | Projekte (3-Tier BKP/SIA) | 6 |
| 4d.8 | Scraper-Control-Center | 6 |

### Neue Listen-Module

- `/assessments` — Liste aller Assessment-Aufträge
- `/company-groups` — Liste aller Firmengruppen
- `/projects` — Liste aller Projekte
- `/scraper` — Control-Center

### Design-System

Keine Token-Änderungen. Alle v1.9-Patterns gültig (Dark + Light Mode, Default Dark, ARK CI-Farben, shadcn/ui, TanStack Query + Zustand + React Hook Form).

## v1.9 (unverändert)

Vollständige Frontend-Spezifikation: alle Seiten/Routes, Component Hierarchy, Design System, Interaction Patterns, State Management, RBAC (4 Levels), Keyboard Shortcuts, Build Waves.

## Verlinkte Wiki-Seiten

[[frontend-architektur]], [[berechtigungen]], [[kandidat]], [[account]], [[status-enum-katalog]], [[detailseiten-inventar]]
