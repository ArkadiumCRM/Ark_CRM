---
title: "Frontend-Architektur"
type: concept
created: 2026-04-08
updated: 2026-04-08
sources: ["ARK_FRONTEND_FREEZE_v1_9.md"]
tags: [concept, architecture, frontend, technical]
---

# Frontend-Architektur

Next.js / React / TypeScript auf Vercel. **Theme: Dark (Default) + Light (user-umschaltbar via `/settings/appearance`)**. Electron Desktop-App.

## Tech Stack

- **Framework:** Next.js App Router
- **UI Library:** shadcn/ui (sole component basis)
- **Icons:** Lucide React (sole icon library)
- **State:** TanStack Query (Server) + Zustand (UI)
- **Forms:** React Hook Form + Zod
- **Tables:** TanStack Table + TanStack Virtual
- **Charts:** Recharts (bar, spider, line) + D3/Custom SVG (ring, Venn, gauges, Teamrad)
- **Command Palette:** cmdk
- **Styling:** Tailwind CSS mit Custom Colors (HSL für shadcn)
- **Testing:** Storybook + Chromatic für Visual Regression

## Design System — Dark + Light Mode

Theme via `data-theme="dark|light"` auf `<html>`. User-Preference-Feld `dim_crm_users.theme_preference ENUM('dark','light','system') DEFAULT 'dark'`. Umschalten in `/settings/appearance`. Vollständige Token-Palette (Dark + Light) in [[design-tokens]].

| Token (Dark) | Hex | Verwendung |
|-------|-----|-----------|
| ark-black | #262626 | Sidebar, Cards |
| ark-gold | #dcb479 | Primary Accent, CTAs, Focus Rings |
| ark-teal-dark | #1b3051 | Secondary Accent |
| ark-teal | #196774 | Links, Hover |
| ark-light | #eeeeee | Primary Text |
| Content BG | #1e1e1e | Hintergrund |
| Borders | #333333 | Rahmen |

Light-Mode-Pendants sind kontrast-optimiert (WCAG AA Pflicht). Komponenten nutzen ausschliesslich CSS-Variablen `var(--token-name)`, nie Hex direkt.

## Navigation

### Product Navigation (Top Bar)
`CRM | Zeiterfassung | Billing | Analysen & Reporting | HR & Entwicklung`
Nur CRM aktiv in Phase 1. Andere ausgegraut.

### Sidebar (3 Gruppen)
1. Dashboard, Kandidaten, Accounts, Firmengruppen, Jobs, Mandate, Prozesse, Projekte, Scraper
2. Market Intelligence
3. Admin, Settings

### Zugänglich via Routes (nicht in Sidebar)
Documents, Search, Matching, Reminders, Notifications

## Seiten-Pattern

- **Vollseite:** Kandidat, Account, Job, Mandat, Prozess — IMMER Vollseite, nie Drawer
- **Drawer (Slide-In rechts):** Nur Sub-Entities (Kontakte, History), Quick-Edits (1-5 Felder), Reminder-Erstellung. Tabs innerhalb erlaubt. Keine verschachtelten Drawers.
- **Modal:** Nur kurze Bestätigungen (Rejection, CV-Versand)

## State Management

| Typ | Tool | Details |
|-----|------|---------|
| Server State | TanStack Query | Tenant-aware Keys, TTL Groups |
| UI State | Zustand | Sidebar, Drawers, Selection, Density |
| Forms | React Hook Form + Zod | `onBlur` Validation, `row_version` |
| URL State | Erlaubte Keys nur | Keine PII in URL |

### Cache TTL

| Gruppe | Stale | GC |
|--------|-------|-----|
| Stammdaten | 30 Min | 60 Min |
| Entity Details | 5 Min | 15 Min |
| Listen/Suche | 2 Min | 10 Min |
| Dashboard KPIs | 2 Min | 5 Min |
| Notifications | Always fresh | 5 Min |

## Density Modes

3 Modi: **kompakt / normal (Default) / komfort**. Tenant-aware, Backend-persisted.

## Responsive Policy

| Grösse | Support |
|--------|---------|
| Desktop ≥1280px | Voll |
| Laptop 1024-1279px | Voll, Sidebar auto-collapsed |
| Tablet 768-1023px | Read-only |
| Mobile <768px | Blocker Screen |

## Keyboard Shortcuts

- **Global:** Cmd+K (Palette), Cmd+/ (Cheatsheet), Escape (Close)
- **Listen:** Arrow ↑↓, Enter (Open), Space (Select), R (Reload), N (New)
- **Detail:** Cmd+Enter (Save), Cmd+E (Edit), Cmd+← (Back), ←→ (Prev/Next)

## Optimistic Updates

**Erlaubt für:** Stage Changes, Reminder Resolve/Snooze, Status Toggles
**Verboten für:** AI Actions, Merges, Bulk Ops, Uploads

## Build Waves

1. **Foundation:** Shell, Auth, API Client, PermissionGate, DataTable, Kandidat
2. **Core CRM:** Accounts, Mandate, Prozesse, History, Notifications, Dashboard
3. **Extended:** Documents, Search/RAG, Matching, AI Review, Bulk/Export
4. **Polish:** Admin, Electron, Error Boundaries, Storybook, CI/CD

## Related

- [[backend-architektur]] — Backend-Gegenstück
- [[berechtigungen]] — PermissionGate, FieldStates
- Design System — Farben, Typography, Density (in dieser Seite dokumentiert)
- [[kandidat]] — 10 Tabs im Detail
- [[account]] — 10 Tabs im Detail
