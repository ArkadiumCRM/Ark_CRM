---
name: mockup-drift-check
description: Use when editing any file in mockups/*.html for the ARK CRM project, or when creating a new detailmaske. Detects design-drift across mockups (candidates.html, accounts.html, jobs.html, mandates.html, projects.html, processes.html, placements.html, activities.html) by comparing shared components - Pipeline-Component, Drawer-Width (540px), Card-Patterns, Tab-Structure, Header-Layout.
---

# Mockup-Drift-Check für ARK CRM

Verhindert divergierende Designs über die 9+ Detailmasken. Beispiel der heute gefunden wurde: `processes.html` 9-Kachel-Grid vs `candidates.html` Tab-6 SVG-Linie — beide Stage-Pipeline, inkonsistent gerendert.

## Trigger

Bei Edit/Write auf `mockups/*.html` prüfen:
- Ist die Änderung ein shared-Component-Kandidat?
- Gibt es vergleichbare Komponenten in anderen Mockups?

## Shared-Components (müssen konsistent sein)

| Component | Reference-File | Drift-Risiko |
|-----------|----------------|--------------|
| Stage-Pipeline | candidates.html Tab 6 SVG-Linie (9 Dots, Gradient, Diamant) | sehr hoch |
| Drawer-Width | alle: 540px slide-in | hoch |
| Card-Header | candidates.html | mittel |
| Tab-Navigation | candidates.html | mittel |
| Header-Row (Breadcrumb + Actions) | candidates.html | hoch |
| Snapshot-Bar | jobs.html / mandates.html | mittel |
| Timeline/History-View | activities.html | mittel |
| Post-Placement-Garantie-Widget | candidates.html Tab 6 (3-Mt/6-Mt/12-Mt-Dots) | hoch |
| Stage-Popover (Skip/Back + Grund) | candidates.html Tab 6 | hoch |
| Refund-Card | processes.html Tab 2 | mittel |

## Check-Punkte

### Drawer
- Width: **immer 540px** slide-in, niemals Modal für CRUD
- Close-Handler: Escape + Backdrop-Click
- Animation: slide-from-right

### Stage-Pipeline
- Dot-Count: 9 (Expose · CV Sent · TI · 1st · 2nd · 3rd · Assessment · Offer · Placement)
- Rejected-Darstellung: roter Dot + graue Ghost-Dots danach
- Current: pulsing-Ring
- Placement: Diamant-Icon

### Cards
- Header-Layout: Titel + Subtitel + Action-Icons rechts
- Padding: konsistent
- Border-Radius: konsistent
- Shadow: konsistent

### Tabs
- Tab-Bar-Struktur gleich (Icons + Text)
- Active-State: Underline + Farbe
- Badge-Positionierung

## Workflow

1. **Bei Edit eines Mockups** mit shared-Component:
2. **Identifiziere Reference-File** (Spalte oben)
3. **Vergleiche Struktur** via Grep/Read
4. **Report Drift**:
   ```
   DRIFT-DETECTED
   Datei: <edited.html>
   Component: <Stage-Pipeline>
   Reference: candidates.html Tab 6
   Abweichung:
     - <edited> uses 9-Kachel-Grid
     - <reference> uses SVG-Linie + Dots
   Empfehlung: Shared Component mit 2 Modi (compact/detailed) ODER
               <edited> auf Reference-Design umstellen
   ```
5. **User entscheidet**: Migration jetzt oder später

## Priorität

- P0: Stage-Pipeline, Drawer-Width, Post-Placement-Garantie
- P1: Header-Row, Tab-Navigation, Snapshot-Bar
- P2: Cards-Padding, Border-Radius, Icon-Choice

## Anti-Pattern

- Neue Mockup-Seite ohne Blick auf candidates.html
- Stage-Rendering lokal erfinden statt Shared-Component
- Modal für CRUD (Drawer-Regel 14.04.2026)
- Drawer-Width ≠ 540px
