---
title: "Guideline: Detailseiten-Spezifikation"
type: meta
created: 2026-04-13
updated: 2026-04-13
tags: [guideline, detailseiten, schema, interactions, spec]
---

# Guideline: Detailseiten-Spezifikation

**Regel:** Jede Detailseite im ARK CRM **muss** aus zwei spezifizierten Dokumenten bestehen:

1. **Schema** — Was enthält die Seite, wie ist sie aufgebaut, wie ist das Design?
2. **Interactions** — Wie funktioniert sie, welche Verknüpfungen, Automationen, Zwänge, Events?

## Schema-Dokument

**Dateiname:** `ARK_<ENTITY>_SCHEMA_vX_Y.md` (z.B. `ARK_KANDIDATENMASKE_SCHEMA_v1_2.md`)

**Pflicht-Inhalt:**
- **Zielbild** — Zweck der Seite in 1–2 Sätzen, Hauptnutzer-Rollen
- **Layout** — Gesamt-Struktur (Header, Tabs, Sections, Sidebar, Footer)
- **Header-Bereich** — Felder und Aktionen, die immer sichtbar sind
- **Tabs / Sections** — pro Tab:
  - Name + Zweck
  - Feld-Inventar (Feldname, Typ, Pflicht/Optional, Quelle im DB-Schema, Validierung)
  - Sub-Sections / Card-Layout
  - Empty States
- **Mockups / Visuelle Referenz** — Screenshots, Wireframes oder Links
- **Responsive-Verhalten** — Desktop / Mobile-Unterschiede (wenn relevant)
- **Design-Tokens** — Farben, Badges, Status-Pills, Icons (Referenz auf Design System)
- **Berechtigungs-Differenzierung** — welche Sektionen/Felder sind rollen-abhängig sichtbar
- **Verweise auf verwandte Specs** — Schema-übergreifende Abhängigkeiten

## Interactions-Dokument

**Dateiname:** `ARK_<ENTITY>_DETAILMASKE_INTERACTIONS_vX_Y.md` (z.B. `ARK_MANDAT_DETAILMASKE_INTERACTIONS_v0_1.md`)

**Pflicht-Inhalt:**
- **Funktionen pro Tab** — welche Aktionen der Nutzer ausführen kann
- **CRUD-Flows** — Erstellen, Lesen, Aktualisieren, Löschen (inkl. Soft-Delete)
- **Save-Strategie** — Inline-Edit, Explicit Save, Optimistic Update, Navigation Guard
- **Validierung** — Client-side + Server-side Regeln, Fehlermeldungen
- **Verknüpfungen** — welche anderen Entitäten sind verlinkt, Navigations-Flows (bidirektional)
- **Automationen** — welche Trigger werden ausgelöst, welche Auto-Fills, welche Berechnungen
- **Zwänge / Constraints** — Locking, Sperr-Regeln, Pflicht-Reihenfolgen (z.B. "Status kann nur vorwärts geändert werden")
- **Events** — welche `fact_history`- / `fact_event_queue`-Einträge werden geschrieben
- **State Management** — Tab-State, URL-State, Optimistic Locking
- **Permissions** — welche Rolle darf was (Lesen/Ändern/Löschen, pro Tab oder Feld)
- **Drawers / Modals** — welche Overlays, wann, Zweck
- **Empty States + Fehler-States** — was zeigt die Seite bei leeren Daten / API-Fehlern
- **Keyboard-Shortcuts** (optional) — Navigation und Aktionen

## Global Patterns

Alle Detailseiten folgen den gemeinsamen Patterns aus [[interaction-patterns]] (11 globale UI-Patterns: Inline-Edit, Tag-CRUD, Drawers, Save Strategy, Navigation Guard, etc.). Diese müssen **nicht** pro Detailseite wiederholt werden, nur Abweichungen/Spezial-Fälle.

## Versionierung

- Start mit `v0.1` (Erstentwurf, Review ausstehend)
- Nach Review und Freigabe: `v1.0`
- Inkrementelle Updates: `v1.1`, `v1.2` …
- Breaking Changes: Major-Bump `v2.0`

## Liste der spezifizierten Detailseiten

Siehe [[detailseiten-inventar]] (Status-Übersicht aller Seiten).

## Related

[[interaction-patterns]], [[frontend-architektur]], [[frontend-freeze]], [[detailseiten-inventar]]
