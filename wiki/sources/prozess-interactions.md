---
title: "ARK Prozess Detailmaske Interactions v0.1"
type: source
created: 2026-04-13
updated: 2026-04-13
sources: ["ARK_PROZESS_DETAILMASKE_INTERACTIONS_v0_1.md"]
tags: [source, prozess, interactions, pipeline, placement, rejection, stale]
---

# ARK Prozess Detailmaske Interactions v0.1

**Datei:** `specs/ARK_PROZESS_DETAILMASKE_INTERACTIONS_v0_1.md`
**Status:** v0.1 = Erstentwurf, Review ausstehend
**Begleitdokument:** [[prozess-schema]] v0.1

## Zusammenfassung

Behavioral Spec für Mischform Pipeline-Modul + schlanke Detailseite (3 Tabs).

## Kern-Flows

- **Stage-Pipeline 9 Stages:** Exposé → CV Sent → TI → 1./2./3. Interview → Assessment → Angebot → Platzierung
- **Erstellung:** nur automatisch aus Jobbasket (Gate 2) oder manuell für Erfolgsbasis. Hard-Stop-Duplikatschutz (1 offener Prozess pro Kandidat+Job)
- **Rejection-Flow:** Modal mit Pflicht-Feldern (rejected_by, rejection_reason aus passender dim-Tabelle, optional Note), kein Optimistic Update. Öffnet Schutzfrist-Fenster für diesen Kandidaten+Account
- **Placement-Flow:** Modal mit start_date, Gehalt, Garantie, Notizen → atomare Transaktion (Status+Events+Mandat-Billing-Trigger+Schutzfrist-Honor+Referral-Check+Job-Fill+Auto-Reminders)
- **Stale-Detection:** Pro Stage konfigurierbare Schwellwerte, Nightly-Job setzt Status auf Stale, bei Stage-Wechsel zurück auf Open
- **Interviews:** Stage = 1 Termin, Outlook-Kalender-Sync, Coaching (-2d) + Debriefing (Abend) Reminders auto
- **Honorar bei Erfolgsbasis:** Auto-Staffel-Berechnung + Override-Option (Audit-Log), Provisions-Splits sichtbar nur AM/Admin/Backoffice
- **Post-Placement:** 30/60/90-Tage Check-ins + Garantie-Ende-Auto-Reminder, Early-Exit mit Rückvergütungs-Staffel (100/50/25/10%)

## Event-Katalog (15 Events)

process_created, stage_changed, status_changed, on_hold_set, on_hold_removed, stale_detected, interview_scheduled, interview_rescheduled, coaching_added, debriefing_added, rejected, placed, placement_cancelled, early_exit_recorded, guarantee_refund_issued, process_closed.

## Kritische Verknüpfungen

- **Placement → Mandat-Billing:** Target → Stage-3-Zahlung fällig; Taskforce → Success Fee für Position
- **Placement → Schutzfrist:** Fenster auf `honored` gesetzt
- **Placement → Referral:** `fact_referral.payout_due_at = placed_at + garantie_months_days`
- **Placement → Job:** `fact_jobs.status = 'filled'`
- **Rejection → Schutzfrist:** Neues 12-Monats-Fenster geöffnet

## Slide-in-Drawer (Pipeline-Modul)

Deckt 80% der Arbeit ab: Kandidat-Mini-Card, Pipeline-Viz, Stage-Dropdown, Quick-Actions (Ablehnen/On Hold/Platzieren), "→ Vollansicht" Link zur Detailseite.

## Verlinkte Wiki-Seiten

[[prozess-schema]], [[prozess]], [[jobbasket]], [[honorar-berechnung]], [[erfolgsbasis]], [[direkteinstellung-schutzfrist]], [[referral-programm]], [[event-system]], [[berechtigungen]], [[detailseiten-guideline]]
