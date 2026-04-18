---
name: saga-trace
description: Use when editing Placement-, Process-, Job-Filled-, or Mandate-Stage-Drawer mockups in the ARK CRM project. Verifies UI shows all TX-saga steps from raw/Ark_CRM_v2/ARK_BACKEND_ARCHITECTURE_v2_*.md (V1-V7 saga flows). Trigger when editing drawer preview sections or history timelines for cross-entity workflows.
---

# Saga-Trace für ARK CRM

UI muss alle TX-Saga-Steps zeigen, damit User versteht welche Seiten-Effekte passieren. Häufige Drift: Drawer-Preview zeigt nur 3 von 8 Steps.

## Referenz-Saga V1 (Placement, 8 Steps)

Laut `raw/Ark_CRM_v2/ARK_BACKEND_ARCHITECTURE_v2_*.md`:

| Step | Effekt | UI-Preview muss zeigen |
|------|--------|------------------------|
| 1 | Process `stage='placement'` setzen | Stage-Badge updated |
| 2 | `fact_placement` Row einfügen | Platzierungs-Card erstellt |
| 3 | Job `status='filled'` setzen | Job-Status-Badge updated |
| 4 | Honorar-Invoice-Trigger | Rechnung generiert (wenn Mandat Stage 3) |
| 5 | Referral-Trigger / `payout_due_at` | Referral-Payout fällig |
| 6 | Stellenplan-Update `filled_count++` | Projekt-Stellenplan aktualisiert (bei Projekt-Mandat) |
| 7 | Guarantee-Fristen starten (3-Mt-Garantie) | Garantie-Zähler aktiv |
| 8 | History cross-entity log | Event in Process + Candidate + Account + Job + Mandate + (Projekt) |

## Weitere Sagas (V2–V7) — aus BACKEND_ARCHITECTURE lesen

| Saga | Trigger | Prüfen in Mockup |
|------|---------|------------------|
| V2 | Reject-Candidate | Schutzfrist 12/16 Mt Zähler starten |
| V3 | Mandat Stage 3 | Honorar-Invoice generieren |
| V4 | Guarantee-Breach | Refund-Trigger (je business_model) |
| V5 | Direct-Hire-Claim | `fact_direct_hire_claim` Record |
| V6 | Job-Filled | Stellenplan aktualisieren |
| V7 | Early-Exit | Refund-Routing (Erfolgsbasis=Staffel, Mandat=Ersatz, Time=keine) |

## Workflow

1. **Bei Edit eines Drawer-Preview** (Placement, Reject, Mandat-Stage-Change, Guarantee-Event):
2. **Lese `raw/Ark_CRM_v2/ARK_BACKEND_ARCHITECTURE_v2_*.md`** — relevante Saga finden
3. **Count Steps**: Wie viele hat Saga? Wie viele zeigt Mockup?
4. **Gap-Report**:
   ```
   SAGA-TRACE-GAP
   Drawer: placementDrawer
   Saga: V1 (8 Steps)
   UI zeigt: 5 Steps
   Fehlend:
     - Step 3: Job status='filled' (kein History-Event)
     - Step 5: Referral-Trigger (kein Hinweis)
     - Step 6: Stellenplan-Update (bei Projekt-Mandat)
   Priorität:
     - Step 3 = P1 (debugging-relevant)
     - Step 5 = P0 wenn Referral-Programm live
     - Step 6 = P1 bei Projekt-Workflow
   ```
5. **User fragen**: Welche Steps in Preview ergänzen?

## Preview-Section-Anforderung

In jedem Drawer der eine Saga triggert muss eine **8-Step-Preview-Section** existieren:

```html
<div class="saga-preview">
  <h4>Was passiert beim Speichern</h4>
  <ol>
    <li><span class="saga-step-icon">✓</span> Prozess-Stage → Placement</li>
    <li><span class="saga-step-icon">✓</span> Platzierung angelegt</li>
    <li><span class="saga-step-icon">✓</span> Job → Filled</li>
    <li><span class="saga-step-icon">✓</span> Honorar-Rechnung generiert</li>
    <li><span class="saga-step-icon">✓</span> Referral-Payout fällig gesetzt</li>
    <li><span class="saga-step-icon">✓</span> Stellenplan aktualisiert</li>
    <li><span class="saga-step-icon">✓</span> 3-Mt-Garantie gestartet</li>
    <li><span class="saga-step-icon">✓</span> History-Events in 5 Entities</li>
  </ol>
</div>
```

## History-Tab Cross-Entity

History-Tab im Prozess-Detailmaske muss zeigen: Events dieses Prozesses **plus** cross-entity Events die durch Sagas getriggert wurden. Nicht nur Process-Events.

## Anti-Pattern

- Drawer zeigt nur "happy path" ohne Seiten-Effekte
- Saga-Steps im Backend dokumentiert aber UI schweigt
- History-Tab zeigt nur Process-Events (Step 8 verletzt)
- Stage-Skip-Regel missachten (V1: Placement braucht `stage='angebot'`)
