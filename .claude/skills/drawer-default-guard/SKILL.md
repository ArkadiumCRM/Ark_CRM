---
name: drawer-default-guard
description: Use when designing or editing CRUD-flows, confirmation dialogs, or multi-step inputs in the ARK CRM project mockups. Enforces Drawer-Default-Regel (14.04.2026) - CRUD, Bestätigungen, Mehrschritt-Eingaben immer als Drawer (540px slide-in). Modal nur für kurze Confirms, Blocker, System-Notifications. Flag Modal-für-CRUD violations.
---

# Drawer-Default-Guard für ARK CRM

**Drawer-Regel (14.04.2026):** CRUD, Bestätigungen, Mehrschritt-Eingaben **immer Drawer** (540px slide-in). Modal nur für kurze Confirms / Blocker / System-Notifications.

## Entscheidungsmatrix

| UI-Zweck | Richtiges Pattern |
|----------|-------------------|
| Neuen Kandidaten anlegen | **Drawer** (540px) |
| Prozess-Details editieren | **Drawer** |
| Stage-Wechsel mit Grund | **Drawer** oder Popover (wenn kurz) |
| Platzierung erfassen | **Drawer** |
| Tag zuweisen | **Drawer** (wenn mehrere Felder) oder Popover |
| Löschen-Bestätigung ("Sicher?") | **Modal** (kurz, blockierend) |
| Session-Timeout-Warnung | **Modal** |
| Netzwerk-Fehler-Blocker | **Modal** |
| System-Notification | **Modal** oder Toast |
| Kurze "OK"-Info | **Modal** oder Toast |

## Drawer-Spezifikation

- **Width:** 540px (exakt, nie abweichen)
- **Slide-Richtung:** von rechts
- **Backdrop:** dunkel, klickbar zum Schliessen
- **Escape-Key:** schliesst Drawer
- **Footer:** sticky, mit Cancel + Primary-Action
- **Header:** Titel + Close-X rechts
- **Scrollbar:** nur Body-Bereich
- **Animation:** `transform: translateX(0)` mit 200ms ease

## Modal-Spezifikation

- **Width:** max 480px, content-based
- **Center-Aligned** im Viewport
- **Backdrop:** dunkel
- **Escape-Key:** schliesst
- **Nur** für: Confirms, Blocker, System-Notifications
- **Nie:** Formular mit >3 Feldern

## Workflow

1. **Bei UI-Design-Entscheidung** (neues Flow-Element):
2. **Check gegen Matrix** oben
3. **Wenn CRUD / Mehrschritt / Edit** → Drawer
4. **Wenn nur Confirm/Blocker** → Modal OK
5. **Bei Unklarheit**: User fragen (PO-Regel)

## Violation-Report

```
DRAWER-VIOLATION
Datei: <mockup.html>
Element: <id>
Gefunden: Modal für <Zweck>
Erwartet: Drawer (540px)
Grund: <CRUD / Mehrschritt / Edit>
Fix: Modal → Drawer umbauen, Width auf 540px, slide-from-right
```

## Popover-Sonderfall

Für **inline-Interaktionen** auf einem Element (z.B. Stage-Dot klicken → Grund-Eingabe) ist Popover OK statt Drawer, wenn:
- Nur 1-2 Felder
- Kontext bleibt sichtbar (User sieht weiter die Pipeline)
- Kein Speichern mit Seiten-Effekten (Saga → Drawer besser)

Beispiel: candidates.html Tab 6 Stage-Popover `.pr-stage-pop` — Skip/Back-Chip + Pflicht-Textarea. **OK als Popover.**

## Anti-Pattern

- Modal für "Neuer Kandidat" (6 Felder) → **Drawer**
- Modal für "Prozess bearbeiten" → **Drawer**
- Drawer für "Sicher löschen?" (overkill) → **Modal**
- Drawer Width ≠ 540px
- Drawer öffnet von links/unten (muss rechts sein)
