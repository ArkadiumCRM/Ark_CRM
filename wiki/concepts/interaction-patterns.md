---
title: "Interaction Patterns"
type: concept
created: 2026-04-08
updated: 2026-04-08
sources: ["ARK_KANDIDATENMASKE_INTERACTIONS_v1_2.md"]
tags: [concept, ui, patterns, interaction]
---

# Interaction Patterns

11 globale Patterns die über alle Tabs konsistent angewendet werden.

## 1. Inline-Edit

Hybrid-Ansatz:
- **Quick-Edit** für einfache Felder: Blur/Enter speichert sofort
- **Section-Edit-Button** für komplexe Blöcke: Explizites Speichern

## 2. Tag-CRUD

- **Einfache Tags:** Inline Autocomplete
- **Komplexe Tags** (Functions/Focus mit Rating + Primary): Drawer (540px)
- Entfernen: X-on-Hover mit 6s Undo-Toast

## 3. Dropdowns

shadcn/ui Custom:
- < 7 Optionen = Simple Select
- 7+ Optionen = Combobox mit Suche
- Clearable für optionale Felder

## 4. Drawer

540px breit, locked Background. Confirm-Dialog bei Dirty State ("Ungespeicherte Änderungen").

**Drawer als Default-Pattern (Konvention 14.04.2026):** Für **alle CRUD-Aktionen, Bestätigungs-Flows und Mehrschritt-Eingaben** ist der Drawer das Default-UI-Pattern. Modale Dialoge sind die **Ausnahme** und nur erlaubt für: kurze Confirm-Dialoge ("Wirklich löschen?"), echte Blocker-Warnungen, oder System-Notifications. **Faustregel:** Wenn der Inhalt mehr als einen Satz und einen Button hat → Drawer. Bei Unsicherheit immer beim PO nachfragen, bevor ein Modal verwendet wird.

## 12. Personen-Darstellung (Konvention 14.04.2026)

Strikte Trennung zwischen **internen Mitarbeitern** (Arkadium AG) und **externen Personen** (Kandidaten, Kontakte am Account, Ansprechpersonen, VR-Mitglieder).

| Personen-Typ | Darstellung | Beispiel |
|--------------|-------------|----------|
| **Interne Arkadium-Mitarbeiter** (AM, CM, Researcher, Admin, Backoffice) | **2-Buchstaben-Kürzel** | `PW`, `JV`, `LR`, `MF`, `NP`, `NS` |
| **Kandidaten** | Vor- und Nachname **voll** | "Tim Furrer", "Maximilian Stucki" |
| **Account-Kontakte / Ansprechpersonen** | Vor- und Nachname **voll** + Funktion in Klammern | "Hans Müller (CEO)", "Andreas Keller (CFO ausscheidend)" |
| **VR-Mitglieder, Externe** | Vor- und Nachname **voll** | "Dr. Urs Gerber" |

**Begründung:** Interne MA sieht man täglich → Kürzel reichen, sparen Platz. Externe muss man wiedererkennen und (bei Kunden) auch im Mund mit Vollnamen führen.

- Mitarbeiter-Initialen aus `dim_mitarbeiter.initials` (NOT NULL, UNIQUE pro Tenant)
- Bei Initial-Kollision: drittes Zeichen ergänzen (z.B. `PWi`/`PWa`)
- Hover/Tooltip auf Initial-Pill zeigt den Vollnamen des Mitarbeiters
- **Nie vermischen:** Vor allem in Listen mit gemischten Personen (z.B. Kontakte-Tabelle, Prozess-Beteiligte) konsequent die jeweilige Konvention anwenden.

## 13. Job-Default-Owner (14.04.2026)

Neue Vakanzen (Scraper-Funde) und neu angelegte Jobs bekommen beim Erstellen **automatisch den Account-AM als Owner vorgeschlagen** (Default-Wert). Der AM kann im Bestätigungs-/Erstellungs-Drawer übersteuern.

## 14a. Terminologie Briefing vs. Stellenbriefing (14.04.2026)

Zwei getrennte Konzepte mit zwei getrennten Begriffen:

| Begriff | Seite | Bedeutung |
|---------|-------|-----------|
| **Briefing** | Kandidaten-Seite | Briefing mit dem Kandidaten über eine offene Stelle (Jobbasket-Flow, vor CV Sent). Siehe Kandidaten-Tab 2 Briefing + Prozess-Stage. |
| **Stellenbriefing** | Account- / Job-Seite | Briefing mit dem Kunden / Ansprechperson über eine konkrete Stelle (Job). Erfasst Anforderungen, Target Compensation, Ansprechperson, kulturelle Passung. |

**Regel:** Niemals vermischen. UI-Labels, Buttons, Drawer-Titel, Reminder-Texte, Dokumenten-Typen müssen die richtige Seite benennen:

- Auf **Kandidaten-Detailseite** (Tab 2): "**Briefing**" · "Briefing erstellen" · "Briefing-Termin"
- Auf **Account-Detailseite** / **Job-Drawer** / **Mandat-Spec**: "**Stellenbriefing**" · "Stellenbriefing erstellen" · "Stellenbriefing-Termin" · "Stellenbriefing-Protokoll.pdf"

**DB / Stammdaten:** Zwei separate Reminder-Typen und Dokument-Labels in `dim_reminder_templates` und `dim_document_labels`:
- `briefing_candidate` · "Briefing mit Kandidat"
- `stellenbriefing_client` · "Stellenbriefing mit Kunde"

## 14. Datum-/Zeit-Eingaben (14.04.2026)

**Jedes Datum- oder Zeit-Eingabefeld muss sowohl Kalender-Picker als auch manuelle Tastatur-Eingabe unterstützen.** Nutzer sollen wählen können, ob sie das Datum klicken oder direkt tippen (`14.04.2026`, `2026-04-14`, `14.4.26`).

**Implementierung:**
- Primär: natives `<input type="date">` / `<input type="datetime-local">` / `<input type="time">` — diese erlauben per Default beides (Tab-Navigation zwischen Tag/Monat/Jahr mit Pfeiltasten oder Eintippen, plus Calendar-Picker über das Kalender-Icon)
- **Nicht** verwenden: Drittanbieter-Picker, die nur Click-Auswahl erlauben (z.B. simple `onClick`-Modals ohne Input-Field)
- Akzeptierte Eingabe-Formate: `TT.MM.JJJJ`, `JJJJ-MM-TT`, `TT.MM.JJ` (Auto-Parse mit `Intl.DateTimeFormat`)
- Invalid-State: roter Border + Tooltip mit erwartetem Format
- Leere Eingabe erlaubt (wenn optional) — Placeholder zeigt Format-Hinweis `TT.MM.JJJJ`

**Dark-Mode:** Calendar-Icon muss invertiert werden (CSS: `filter:invert(0.85)` für `::-webkit-calendar-picker-indicator`). Siehe `mockups/_shared/editorial.css`.

## 5. Save Strategy

- **Autosave:** Quick-Edits (optimistisch, Rollback bei Error)
- **Explicit Save:** Komplexe Blöcke (pessimistisch)

## 6. Navigation Guard

Dirty State bleibt bei Tab-Wechsel innerhalb Kandidat. Warn-Dialog NUR beim Wegnavigieren.

## 7. Optimistic Updates

| Typ | Strategie |
|-----|-----------|
| Quick-Edits | Optimistisch (Rollback) |
| Business-Critical (Stage, CV Send) | Pessimistisch (warten auf Response) |

## 8. Toast Feedback

| Level | Dauer |
|-------|-------|
| Success | 3 Sekunden |
| Warning | 6 Sekunden |
| Error | Bleibt bis dismissed |
| Undo | 6 Sekunden |

## 9. Confirm Dialogs

Nur für destruktive + business-critical Actions. Action-Button wiederholt den Aktionstext.

## 10. List Strategy

| Kontext | Strategie |
|---------|-----------|
| Die meisten Tabs (< 30 Items) | Load All |
| History | Infinite Scroll (TanStack Virtual) |
| Kandidaten-Liste | Cursor-based Pagination |

## 11. Datepicker

Immer dual: Kalender-Klick + manuelle Eingabe (dd.MM.yyyy).

## 12. Read-only-Visualisierungstabs (15.04.2026)

Bestimmte Detailmasken-Tabs sind **strikt read-only** — sie zeigen aggregierte Daten, deren Erfassung an einer anderen Stelle (typischerweise einer Auftrags-/Order-Detailseite) erfolgt. Begründung: jede Wert-Erfassung ist an eine Geschäftstransaktion (Billing, Owner, Versionierung, Multi-Entity-Aufträge) gebunden und muss dort ihre Single Source of Truth haben.

**Aktuell betroffene Tabs:**
- **Kandidat · Tab 4 Assessment** → Eingabe via `assessments.html` (Auftrag = `fact_assessment_order`)

**Pattern für solche Tabs:**
1. Persistenter **Read-only-Banner** oben: 🔒 mit Hinweis-Text + Primary-CTA „+ Neuer Auftrag" → Order-Wizard mit vorausgewählten Entities
2. Alle Action-CTAs im Tab routen zu Order-Detailseite (kein Inline-Edit)
3. Empty-State-Cards haben CTAs „+ Auftrag anlegen" (kein „Einladung senden" o.ä. ohne Order-Kontext)
4. Version-Nav zeigt alle Aufträge des Kandidaten chronologisch, „→ Aktiven Auftrag öffnen"
5. Edge-Case extern eingebrachte Daten: Order-Typ „Extern eingebracht" mit Kosten 0 — bleibt im Modell, aber ohne Billing

## Related

- [[frontend-architektur]] — Technische Umsetzung
- [[kandidat]] — Anwendung auf Kandidaten-Tabs
- [[account]] — Anwendung auf Account-Tabs
