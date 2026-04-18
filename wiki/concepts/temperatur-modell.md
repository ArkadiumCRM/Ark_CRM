---
title: "Temperatur-Modell"
type: concept
created: 2026-04-08
updated: 2026-04-08
sources: ["ARK_KANDIDATENMASKE_INTERACTIONS_v1_2.md", "ARK_ACCOUNT_DETAILMASKE_INTERACTIONS_v0_1.md"]
tags: [concept, temperatur, automation, scoring]
---

# Temperatur-Modell

Vollautomatisch berechnet — **kein manueller Override**. Zwei Batch-Jobs täglich (00:00 + 12:00).

## Kandidaten-Temperatur

### Layer 1: Hard Rules (überschreiben alles)

| Regel | Ergebnis |
|-------|---------|
| Placement < 6 Monate | Cold |
| NIC < 60 Tage | Cold |
| DO-NOT-CONTACT | Cold |
| Aktiver Prozess ≥ Interview | Hot |
| Self-Applied < 14 Tage | Hot |

**Hot-Regeln überschreiben Cold-Regeln.**

### Layer 2: Punkte-basiert (wenn keine Hard Rule greift)

| Signal | Punkte |
|--------|--------|
| Wechselmotivation 7-8 (will nicht wechseln / kein ARK) | +3 |
| Erfolgreicher Call < 14 Tage | +2 |
| Aktiver Prozess < Interview | +2 |
| Briefing < 30 Tage | +1 |
| Kein Call 90+ Tage | -3 |
| Kein Call 30-89 Tage | -1 |
| Wechselmotivation 1-2 (arbeitslos / will wechseln) | -2 |

**Schwellwerte:** ≥5 = Hot, 1-4 = Warm, ≤0 = Cold

## Account-Temperatur

Analoges Modell mit anderen Signalen:

| Signal | Ergebnis/Punkte |
|--------|----------------|
| Blacklisted/Inactive | Always Cold |
| Aktives Mandat/Prozess | Hot |
| AGB bestätigt | +2 |
| Kundenklasse A | +2 |
| Penetration Score ≥ 70 | +2 |
| Nie Prozess + Alter > 90 Tage | -2 |

## Related

- [[kandidat]] — Temperatur im Profil
- [[account]] — Account-Temperatur
- [[automationen]] — Batch-Job-Trigger
