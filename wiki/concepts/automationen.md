---
title: "Automationen"
type: concept
created: 2026-04-08
updated: 2026-04-08
sources: ["ARK_GESAMTSYSTEM_UEBERSICHT_v1_2.md", "ARK_BACKEND_ARCHITECTURE_v2_4.md"]
tags: [concept, automation, triggers, business-logic]
---

# Automationen

Alle automatischen Aktionen die durch Events getriggert werden. Definiert in `dim_automation_rules`, ausgeführt vom Event Processor Worker.

## Trigger-Matrix

| Trigger | Aktion |
|---------|--------|
| Briefing gespeichert | Kandidat → Premarket + Mandate Research → briefing |
| CV + Diplom + Zeugnis + Briefing vorhanden | Kandidat → Active Sourcing |
| Prozess erstellt | Kandidat → Market Now |
| Email "Mündliche GOs" versendet | Jobbasket → oral_go + Mandate Research → go_muendlich |
| Schriftlicher GO eingegangen | Jobbasket → written_go + Mandate Research → go_schriftlich |
| NIC / Dropped / Ghosting **nach CV Expected** | Kandidat → Refresh + Mandate Research → rejected/dropped |
| CV hochgeladen | Mandate Research → cv_in |
| Placement | Job → Filled + Onboarding/Check-in Reminders + Provisions-Berechnung |
| Datenschutz | Anonymisierung + nach 1 Jahr → Refresh (Sonder-Automation) |
| Alter >60 (täglicher Batch-Job) | Kandidat → Inactive |
| Template-Email versendet | Auto-Klassifizierung des Activity-Types |
| Shortlist-Trigger erreicht (Target-Mandat) | 2. Zahlung fällig + AM-Notification |
| CV-Versand an Account ohne AGB | Warnung (kein Block) |
| Interview-Termin eingetragen | Outlook-Kalendereintrag + Reminder für CM |
| Interview-Stage ohne Datum | Reminder "Datum fehlt" (Default: 2 Tage) |
| Dokument "Mandatsofferte unterschrieben" | Mandats-Status → Aktiv |
| Stale Prozess (>14d in gleicher Stage) | Reminder + KPI-Flag |

## Übergreifende Synchronisierung

Alle Automationen greifen übergreifend: Kandidaten-Stage UND alle aktiven Longlists werden synchron aktualisiert.

Beispiel: NIC bei einem Kandidaten → Stage: Refresh → **alle aktiven Mandate-Research-Einträge** dieses Kandidaten → rejected.

## Eskalation

| Stufe | Zeitpunkt | Aktion |
|-------|-----------|--------|
| 1 | Sofort | Badge auf Dashboard |
| 2 | 24h | Reminder an CM |
| 3 | 48h | Notification an Head_of |
| 4 | Wöchentlich | KPI-Report |

Gilt für: Unklassifizierte History-Einträge, offene AI-Empfehlungen, Ghosting.

**Alle Fristen konfigurierbar** in Admin → Automation-Settings (`dim_automation_settings`).

## Circuit Breaker

Schutz vor Event-Stürmen. Pro Automation-Regel:
- `max_triggers_per_hour`
- `max_triggers_per_day`

Bei Überschreitung: Automation gestoppt + Admin-Alert.

## Related

- [[event-system]] — Die Event-Infrastruktur
- [[kandidat]] — Stage-Automationen
- [[prozess]] — Pipeline-Automationen
- [[mandat]] — Mandats-Automationen
- [[jobbasket]] — GO-Flow-Automationen
- [[reminders]] — Auto-generierte Reminders
