---
title: "ARK Prozess Detailmaske Schema v0.1"
type: source
created: 2026-04-13
updated: 2026-04-13
sources: ["ARK_PROZESS_DETAILMASKE_SCHEMA_v0_1.md"]
tags: [source, prozess, schema, pipeline, mischform, detailseite]
---

# ARK Prozess Detailmaske Schema v0.1

**Datei:** `specs/ARK_PROZESS_DETAILMASKE_SCHEMA_v0_1.md`
**Status:** v0.1 = Erstentwurf, Review ausstehend
**Begleitdokument:** [[prozess-interactions]] v0.1

## Architektur-Entscheidung (Mischform, 2026-04-13)

- **Pipeline-Modul `/processes`** ist Hauptarbeitsort (Liste + Filter + Slide-in-Drawer 540px) — deckt 80% der Fälle ab
- **Detailseite `/processes/[id]` schlank (3 Tabs)** für komplexere Fälle: Erfolgsbasis-Billing, Post-Placement, Dokumenten-Historie

## 3 Tabs

1. Übersicht — Verknüpfungen, Pipeline & Timing, Status, Post-Placement, Notizen
2. Interviews & Honorar — Interview-Timeline, Honorar (Mandat: Read-only Verweis, Erfolgsbasis: voll), Provisions-Splits, Rückvergütung
3. Dokumente & History — Prozess-spezifische Dokumente + Event-Stream

## Schlüssel-Elemente

- Header mit **Pipeline-Visualisierung** (9 Stages als Punkt-Sequenz)
- Snapshot-Bar 5 Slots: Stage-Alter / Nächstes Interview / Fee / CM+AM / Garantie
- Quick-Actions: Anrufen, Email, Ablehnen, On Hold, Platzieren
- **Stage = Termin 1:1** (entschieden) — `fact_process_interviews` 1 Row pro Interview-Stage
- **Honorar-Anzeige:** Read-only bei Mandats-Prozessen (Verweis aufs Mandat), voller Tab bei Erfolgsbasis
- **Stale-Schwellwerte pro Stage** admin-konfigurierbar in `dim_automation_settings.process_stale_thresholds`
- **Rückvergütungs-Staffel** bei Early Exit (100/50/25/10%), keine Rückvergütung bei `fault_side = client`

## Neue DB-Felder / Tabellen

- `fact_process_core`: + on_hold_reason, stale_detected_at, cancellation_reason, cancelled_by
- `fact_process_interviews`: neu (1 Row pro Interview-Stage, mit Outlook calendar_event_id)
- `dim_automation_settings.process_stale_thresholds`: JSONB

## Verlinkte Wiki-Seiten

[[prozess]], [[prozess-interactions]], [[jobbasket]], [[honorar-berechnung]], [[erfolgsbasis]], [[direkteinstellung-schutzfrist]], [[referral-programm]], [[detailseiten-guideline]]
