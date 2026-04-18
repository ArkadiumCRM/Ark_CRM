---
title: "Decision — Header-Snapshot-Bar Slot-Anzahl"
type: meta
created: 2026-04-18
updated: 2026-04-18
tags: [decision, snapshot-bar, header, konsistenz]
---

# Decision · Header-Snapshot-Bar Slot-Anzahl

**Entscheidung 2026-04-18 (Peter):** **Option B — variabel akzeptieren (Status quo).**

Slot-Anzahl bleibt entity-spezifisch: Kandidat 4–8 · Mandat 6–7 · Account 6 · Assessment 5 · Firmengruppe/Projekt variabel. Jede Detailseite zeigt was semantisch relevant ist. Keine Pflicht-Vereinheitlichung, keine Slot-Truncation, keine Füll-Slots.

Keine Spec-Edits nötig. Kein Mockup-Refactor.

## Frage

Sollen alle Detailseiten eine einheitliche Max-Slot-Anzahl im Header-Snapshot haben, oder bleibt es variabel?

## Ist-Zustand (Stand 2026-04-18)

| Entity | Slots | Beispiel-Inhalte |
|--------|-------|------------------|
| Kandidat | **variabel (4–8)** | Profilvollständigkeit · WM · Call-Window · Active-Sourcing · Hot · ggf. weitere Hunt-KPIs |
| Mandat | **6–7** | Typ · Stage · Longlist · Prozesse · Garantie · Zeitraum · (optional Billing-Status) |
| Account | **6** | Kundenklasse · Status · AM · Gegründet · Standorte · Sparten (fix seit Entscheidung 14.04.) |
| Assessment | **5** | Typ · Status · Kandidat(en) · Deadline · Preis |

## Optionen

### Option A — Fix 6 Slots überall

- Pro: UI-Konsistenz, Layout-Predictability, gleicher Header-Footprint auf allen Seiten
- Contra: Kandidat erzwingt Slot-Abbau (Hunt-Kontext verloren); Assessment/Firmengruppe erzwingt Slot-Aufblähung mit irrelevanten Feldern

### Option B — Variabel akzeptieren (Ist-Zustand)

- Pro: Semantische Freiheit; jede Entity zeigt was relevant ist
- Contra: Leichte visuelle Inkonsistenz zwischen Seiten

### Option C — **Empfehlung: Max 6 Slots, minimum 4 — Kandidat als dokumentierte Ausnahme (bis 8)**

- Alle Detailseiten: 4–6 Slots
- Kandidat: bis zu 8 Slots, dokumentiert als "Info-dichte Entity mit erweitertem Hunt-Kontext"
- Fix-Slot-Grid im CSS (`minmax(120px, 1fr)` * max-6, mit `gap:16px`), Kandidat nutzt alternatives Grid mit mehr Slots
- In Mockup-Baseline §16 verankern
- Alle Specs: §Snapshot-Bar auf Max-6 prüfen und ggf. reduzieren (Mandat → 6 statt 7, durch Zusammenfassen von "Garantie" + "Zeitraum" zu "Laufzeit+Garantie"-Slot)

## Empfehlung: **Option C**

**Begründung:**
- 4–6 abgedeckt sowohl kleine (Assessment, Firmengruppe) als auch größere Entities (Mandat, Account)
- Kandidat ist natürliche Ausnahme (Sourcing-Tool mit viel Hunt-Kontext)
- Kein rigoroses Slot-Truncation
- Mockup-Baseline-Disziplin bleibt (§16 kanonische Slot-Auswahl pro Entity)

## Impact-Analyse bei Approval

1. Mandat-Spec: Slots 6+7 zusammenfassen → v0.3-Bump
2. Kandidat-Spec: Dokumentieren "bis zu 8 Slots, erweiterte Grid-Variante"
3. Mockup-Baseline §16: neue Sektion "Snapshot-Bar Slot-Regeln"
4. CSS-Tokens: ggf. neue Grid-Klasse `snapshot-wide` für Kandidat

## Related

- [[mockup-baseline]] §16
- [[detailseiten-nachbearbeitung]]
- [[autorefine-log]] Run 8
