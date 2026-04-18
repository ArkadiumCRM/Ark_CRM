---
title: "ARK Pipeline Component — Shared Spec"
version: 1.0
created: 2026-04-16
status: active
type: design-system-component
tags: [pipeline, shared-component, design-system, process-stages]
---

# ARK Pipeline Component

Shared visual component für Prozess-Stage-Visualisierung. Ersetzt Design-Drift zwischen `processes.html` (Kachel-Grid) und `candidates.html` Tab 6 (SVG-Linie). Design-System-Referenz für alle Pipeline-Darstellungen: Prozess-Detailmaske, Kandidat-Tab-6, Job-Detailmaske, Account-Prozess-Tab, Mandat-Kandidaten-Liste, Projekt-Stellen-Detail.

## Grundregeln (cross-cutting)

1. **Arkadium-Rolle (CLAUDE.md §Arkadium-Rolle-Regel):** Arkadium nimmt an keinem Interview (TI / 1st / 2nd / 3rd / Assessment) teil — alle Interviews sind direkt Kunde ↔ Kandidat. Arkadium-Touchpoints sind Coaching (vor), Debriefing beidseitig (nach) und Referenzauskunft.
2. **Activity-Linking (CLAUDE.md §Activity-Linking-Regel):** Jedes Pipeline-Dot / Debriefing-Dot / Stage-Event ist Projektion auf `fact_history`-Events. Click-Through obligatorisch.
3. **Skip-Logik:** Forward bis inkl. `angebot` erlaubt mit Pflicht-Grund. Placement ausschliesslich via Placement-Drawer (V1-Saga 8-Step).

---

## 1. Varianten

### 1.1 `detailed` — Detail-Masken, grosse Ansicht

- **Verwendung:** `processes.html` Detail-Maske (Header-Bereich nach Banner)
- **Darstellung:** SVG-Linie horizontal, ca. 70% Content-Breite
- **Ergänzung:** WinProb-Panel rechts 280 px vertikal (siehe §4)
- **Interaktion:** Stage-Popover mit Pflicht-Textarea für Grund (siehe §5)

### 1.2 `compact` — Listen-Karten, Tab-Cards

- **Verwendung:** `candidates.html` Tab 6, `jobs.html` Pipeline-Übersicht, `accounts.html` Prozess-Tab, `mandates.html` Kandidaten-Liste, `projects.html` Stellen-Detail
- **Darstellung:** SVG-Linie oder CSS-only-Fallback (flex + `::before` Dots) bei > 50 Karten pro View
- **Keine** WinProb-Panel-Pflicht — WinProb als Info-Row unter SVG (inline Chip)
- **Interaktion:** Hover-Tooltip (kein Popover)

---

## 2. Stage-Set (9 Stages, Stammdaten §13)

```
Exposé · CV Sent · TI · 1st · 2nd · 3rd · Assessment · Offer · Placement
```

Keine abweichenden Stage-Namen im UI. Quelle: `dim_process_stages` (siehe `ARK_STAMMDATEN_EXPORT §13`).

---

## 3. Visuelle Definition

### 3.1 Dot-States

| State | Visual | Trigger |
|-------|--------|---------|
| current | Gefüllter Kreis, Gold-Ring, pulsing-Animation | `fact_process_core.current_stage = stage_id` |
| passed | Gefüllter Kreis, Green-Fill | Stage in History vor current |
| future | Leerer Kreis, grauer Rand | Stage nach current |
| skipped | Hohlring, gestrichelt | Stage ausgelassen (nicht durchlaufen) |
| rejected | Roter Dot | `fact_process_core.status = rejected` + `rejected_at_stage_id` |
| ghost | Grauer Ring 3 px, kein Fill | Stages nach rejected-Stage |
| placement (Ziel-Stage) | **Immer Diamant** (Zielstage-Marker · Option A · unabhängig vom Status). Gold-Fill bei `status=placed`, Surface-Fill mit Gold-Stroke wenn pending/future, kleiner Diamant mit Border-Stroke wenn nach Rejection. | Letzte Stage (9/9) |

### 3.2 Verbindungslinie

- Gradient von passed (grün) zu future (grau), current als Stop-Point
- Rejected: alle folgenden Stages + Linie grau

### 3.3 Datum-Label

- Unter jedem passed-Dot: `TT.MM.` (kurz)
- Assessment: **kein Datum** — wird im Assessment-Tab getrackt
- Placement: Hire-Date (aus `fact_placements.hire_date`)

### 3.4 Debriefing-Dots (beidseitig · Arkadium-Rolle)

Kleine Dots auf der Linie zwischen Interview-Stages (TI↔1st, 1st↔2nd, 2nd↔3rd):

> **Kontext (CLAUDE.md §Arkadium-Rolle-Regel):** Arkadium nimmt NICHT an Interviews teil. Debriefings sind Arkadium-Feedback-Gespräche NACH dem Kunde↔Kandidat-Interview. **Beidseitig** — pro Interview 2 separate Gespräche:
> - `debriefing_{stage}_kandidat` — Arkadium ↔ Kandidat
> - `debriefing_{stage}_kunde` — Arkadium ↔ Kunde

**Dot-Status (aggregiert aus 2 Events):**

| Visual | Bedeutung |
|--------|-----------|
| **Lila 📝 (voll)** | Beide Debriefings vorhanden (Kandidat + Kunde) |
| **Lila 📝 (halbvoll / diagonal)** | Nur einseitig — Warnung-Hover „Debriefing mit {Kandidat|Kunde} fehlt" |
| **Grau —** | Keine Debriefings vorhanden → Klick öffnet Erfass-Drawer |

**Click-Verhalten:**
- Lila voll/halb: Popover mit beiden Events (Tabs: Kandidat · Kunde) aus `fact_history`
- Grau: History-Drawer im Erfass-Modus, Activity-Type vorausgewählt (beide Varianten einzeln erfassbar)

**Quelle:** `fact_history` WHERE `type IN (
  'Erreicht - Debriefing TI',
  'Erreicht - Debriefing 1st Interview',
  'Erreicht - Debriefing 2nd Interview',
  'Erreicht - Debriefing 3rd Interview'
)` GROUP BY `process_id, stage-slot` — COUNT(*) = 2 wenn beidseitig (1× Kandidat-History + 1× Account-History), COUNT(*) = 1 wenn nur einseitig, COUNT(*) = 0 wenn fehlt.

**Debriefing-Logik:** Ein Debriefing-Set erzeugt **zwei** `fact_history`-Einträge mit identischem Activity-Type — Entity-Zuordnung ergibt sich aus der History-Location (`entity_type = 'candidate'` vs `'account'`). Siehe `ARK_STAMMDATEN_EXPORT_v1_3` §14 · entity_relevance=both.

---

## 4. WinProb-Panel (detailed-Mode, rechts 280 px)

5 Blöcke vertikal gestapelt:

| Block | Inhalt | Source |
|-------|--------|--------|
| Current Stage | Stage-Name + Icon, Tage-in-Stage | `fact_process_core.current_stage`, `stage_changed_at` |
| Win-Probability | % + Ampel (grün ≥ 60, gelb 30–59, rot < 30) | `dim_process_stages.win_prob` JOIN current Stage |
| Tage in Stage | `now − stage_changed_at` + Ampel bei Stale-Frist (`dim_process_stages.stale_after_days`) | `fact_process_core.stage_changed_at` |
| Next Stage | Name + "Forecast: TT.MM.JJJJ" (avg duration je Stage aus `fact_process_stage_history`) | Berechnet |
| Footer | "Zuletzt geändert von {Kürzel} am TT.MM.JJJJ" | `fact_process_core.updated_at`, `updated_by_user_id` |

Mobile-Fallback (< 1024 px): Panel unter Pipeline horizontal als 4-Chip-Strip.

---

## 5. Stage-Popover (detailed-Mode, Klick auf Dot)

Pflicht-Felder:

- **Grund-Textarea** — min. 10 Zeichen, required bei jedem Stage-Wechsel (auch Forward)
- **Datum-Picker** — native `<input type="date">` (Picker + Tastatur per CLAUDE.md Datum-Eingabe-Regel)
- **Debriefing-Check** — bei Forward-Sprung aus Interview-Stage (TI/1st/2nd/3rd) Pflicht-Warn wenn kein Debriefing in History
- **AGB-Warn** — bei Skip, wenn Account ohne bestätigte AGB

Buttons:

- **Skip-Forward-Chip** — nur bis inkl. Angebot. Placement niemals via Stage-Klick (siehe §6)
- **Back-Chip** — mit Confirm + Grund-Textarea
- **Abbrechen** — schliesst Popover ohne Änderung

---

## 6. Skip-Regeln (V1-Saga-konform)

| Aktion | Erlaubt? | Bedingung |
|--------|----------|-----------|
| Forward 1 Stage | ✓ | Mit Grund |
| Forward > 1 Stage bis inkl. Angebot | ✓ | Mit Grund + ggf. Debriefing-Override |
| Forward zu Placement via Stage-Klick | ✗ | Placement **nur** über Placement-Drawer (V1-Saga 8-Step) |
| Back-Sprung | ✓ | Mit Confirm + Grund, loggt System-Event `stage_rollback` |
| Stage-Wechsel bei Status ∈ {rejected, placed, closed} | ✗ | Locked, Popover disabled |

---

## 7. Accessibility

- `role="list"` auf SVG-Wrapper
- Pro Dot: `role="listitem"` + `aria-label="Stage {n} von 9: {name} · {state} · {datum|currentSince}"`
- Keyboard: Tab durch Dots, Enter öffnet Popover (detailed) oder Tooltip (compact)
- Pulsing-Animation nur bei `prefers-reduced-motion: no-preference`

---

## 8. Performance

| Kontext | Implementation |
|---------|---------------|
| `detailed` | SVG inline, ~2 KB pro Instanz |
| `compact` < 50 Karten pro View | SVG inline |
| `compact` ≥ 50 Karten pro View | CSS-only-Fallback (flex-row + `::before` Pseudo-Elements) |

Pulsing-Animation ausschliesslich im `detailed`-Mode.

---

## 9. Technisches

- **Komponente:** `<ark-pipeline mode="detailed|compact" data-process-id="...">`
- **Data-Contract:** JSON mit `stages[], current_stage, rejected_at_stage, placed_at, skip_reasons[], debriefing_flags[]`
- **CSS-Prefix:** `.ark-pl-` (shared, ersetzt `.pst-step` aus `processes.html` und `.pr-stage-*` aus `candidates.html`)
- **Events:** `ark-pipeline:stage-click`, `ark-pipeline:stage-change`, `ark-pipeline:debriefing-click`

---

## 10. Migration (Mockup-Rollout · reduziert 2026-04-16)

> **Scope-Klarstellung:** Nur 2 Masken zeigen die 9-Stage-Pipeline. Die anderen Masken (jobs / mandates / projects) nutzen Kanban-Views oder Listen-Darstellungen ohne Pipeline-SVG.

| Mockup | Vorher | Nachher | Priorität |
|--------|--------|---------|-----------|
| `processes.html` | Kachel-Grid `.pst-step` | `detailed`-Mode SVG + WinProb-Panel + Stage-Popover | P0 ✓ |
| `candidates.html` Tab 6 | SVG + Garantie-Widget | `compact`-Mode SVG pro Prozess-Card + Activity-Linking + Debriefing-Dots beidseitig | P0 ✓ |
| `accounts.html` procDrawer (Stage-Verlauf) | Kachel-Grid `.pst-step` (Legacy) | `compact`-Mode SVG im Quick-Drawer + Link zur Prozess-Detailmaske | P1 ✓ |
| `jobs.html` | Kanban-View für Prozesse pro Job | **Kein SVG-Pipeline** — Kanban bleibt (keine 9-Stage-Detail-Darstellung gewünscht) | — entfällt |
| `mandates.html` | Kanban Longlist | **Kein SVG-Pipeline** — Kanban bleibt | — entfällt |
| `projects.html` | Stellenplan-Tabelle | **Kein SVG-Pipeline** — keine Prozess-Darstellung auf Stellen-Ebene | — entfällt |

**Grund für Scope-Reduktion:** Pipeline-SVG-Visualisierung ist nur in „zentrierten" Detail-Views sinnvoll (Kandidat-Sicht im Kandidaten-Tab-6, Prozess-Sicht in processes.html). Bei Jobs / Mandaten / Projekten ist die relevante Darstellung eine Kanban- oder Listen-View über mehrere Prozesse — dort würde 9-Stage-SVG pro Row zu viel Raum nehmen und keinen zusätzlichen Wert liefern.

Deprecated-Klassen `.pst-step`, `.pr-stage-pop`, `.pr-stage-track` werden in Component-v1.1 entfernt.

---

## 11. Cross-References

- `ARK_PROZESS_DETAILMASKE_SCHEMA_v0_1` §4.2 → verweist auf diese Spec
- `ARK_KANDIDATENMASKE_SCHEMA_v1_3` §7 Tab 6 → verweist auf diese Spec
- `ARK_FRONTEND_FREEZE_v1_10` §17d → Design-System-Pointer
- `ARK_STAMMDATEN_EXPORT_v1_3` §13 (dim_process_stages)
- `ARK_BACKEND_ARCHITECTURE_v2_5` V1-Saga (Placement-8-Step)

---

## 12. Changelog

| Version | Datum | Änderung |
|---------|-------|----------|
| 1.0 | 2026-04-16 | Initial konsolidiert aus `processes.html` + `candidates.html` Tab-6 Drift |
