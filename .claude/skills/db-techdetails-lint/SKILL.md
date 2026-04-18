---
name: db-techdetails-lint
description: Use when writing user-facing UI text in ARK CRM mockups (mockups/*.html), Card titles, subtitles, tooltips, hints, empty-states, breadcrumbs, labels. Enforces CRITICAL rule - niemals DB-Tabellen-/Spalten-Namen (dim_*, fact_*, bridge_*, _fk, candidate_id, stage) in User-facing Texten zeigen. Ausnahmen - Spec-Dokumente, Code-Kommentare, Admin/Debug-Ansichten.
---

# DB-Tech-Details-Lint (CRITICAL Rule, 2026-04-15)

**Niemals** DB-Tabellen- oder Spalten-Namen in User-facing-UI zeigen. User sieht sprechende Benutzer-Begriffe.

## Verbotene Patterns in UI-Text

| Pattern | Beispiel | Ersatz |
|---------|----------|--------|
| `dim_*` | `dim_process_stages` | "Prozess-Phasen" / "Stammdaten" |
| `fact_*` | `fact_placement` | "Platzierung" |
| `bridge_*` | `bridge_candidate_tag` | "Zuordnung" / "Verknüpfung" |
| `_fk` Suffix | `candidate_id_fk` | "Kandidat" |
| `_id` Spalten-Name roh | `candidate_id` | "Kandidat" |
| Stage-Code-Name | `stage='expose'` | "Expose" (Label aus Stammdaten) |
| Status-Boolean | `is_active=true` | "Aktiv" |
| Join-Spalten | `account_id, mandate_id` | Namen der Entities |
| Schema-Präfix | `ark.dim_employees` | "Mitarbeiter" |

## Wo erlaubt (Ausnahmen)

- `specs/*.md` — Schema-Dokumentation
- Code-Kommentare in `.py`, `.js`, `.ts`
- Admin-/Debug-Views (explizit so gekennzeichnet)
- Backend-API-Dokumentation
- DB-Migrations-Scripts

## Wo verboten (UI)

- Card-Titel, Subtitel
- Tooltips, Popovers
- Hinweise, Empty-States
- Breadcrumbs
- Labels, Form-Field-Namen
- Toast-Messages
- Dialog-Titel
- Filter-Dropdown-Einträge
- Chip-Beschriftungen

## Sprechende Benutzer-Begriffe (Standard-Mapping)

| DB-Begriff | UI-Begriff |
|-----------|-----------|
| `dim_*` | "Stammdaten" / "Liste" / "Katalog" / "Auswahl" |
| `fact_processes` | "Prozesse" |
| `fact_placements` | "Platzierungen" |
| `fact_candidates` | "Kandidaten" |
| `fact_accounts` | "Accounts" / "Kunden" |
| `fact_mandates` | "Mandate" / "Aufträge" |
| `fact_projects` | "Projekte" |
| `fact_activities` | "Aktivitäten" |
| `bridge_*` | "Zuordnung" / "Verknüpfung" |

## Workflow

1. Bei Edit/Write auf `mockups/*.html`, `wiki/**/*.md` (non-spec), User-facing-Texte:
2. Scan für Verbot-Patterns (regex: `\b(dim|fact|bridge)_\w+\b`, `\w+_fk\b`, `\w+_id\b` in Prose-Kontexten)
3. Bei Fund: Vorschlag mit sprechendem Ersatz
4. Begründung-Refresh: **User braucht technische Details nicht, sie verursachen Verwirrung und wirken unprofessionell.**

## Output-Format bei Violation

```
DB-TECHDETAIL-VIOLATION
Datei: <path>
Zeile: <n>
Gefunden: "<rohes DB-Token>"
Kontext: <UI-Element: Card-Titel / Tooltip / ...>
Ersatz: "<sprechender Begriff>"
```
