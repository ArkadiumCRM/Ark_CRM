---
title: "ARK Mandat Detailmaske Interactions v0.3"
type: source
created: 2026-04-12
updated: 2026-04-14
sources: ["ARK_MANDAT_DETAILMASKE_INTERACTIONS_v0_3.md", "ARK_MANDAT_DETAILMASKE_INTERACTIONS_v0_2.md", "ARK_MANDAT_DETAILMASKE_INTERACTIONS_v0_1.md"]
tags: [source, mandat, interactions, behavior, target, taskforce, time, kuendigung, schutzfrist, optionale-stages, longlist-lock]
---

# ARK Mandat Detailmaske Interactions v0.3

**Aktuelle Datei:** `specs/ARK_MANDAT_DETAILMASKE_INTERACTIONS_v0_3.md`
**Vorherige Versionen:** `specs/alt/ARK_MANDAT_DETAILMASKE_INTERACTIONS_v0_2.md` und `v0_1.md` (archiviert)
**Status:** v0.3 = Kündigungs-Flow ausgearbeitet + Longlist-Lock + Schutzfrist-Scope-Entscheidung (14.04.2026)

## Zusammenfassung

Behavioral Spec für die Mandate-Detailseite (`/mandates/[id]`). Vollseite mit 6 Tabs — die primäre Arbeitsumgebung für Account Manager und Researcher während eines aktiven Mandats.

## Schlüssel-Erkenntnisse

- **Typ-spezifische Darstellung:** Nahezu jede Sektion passt sich an den Mandatstyp an (Target / Taskforce / Time). Taskforce = umbenanntes RPO.
- **Longlist als Herzstück:** Tab 2 (Longlist) mit Kanban (10 Spalten) ist der Hauptarbeitsort für Researcher. Durchcall-Funktion mit automatischer Queue nach Priority
- **Locking:** Ab "CV IN" sind Longlist-Stages gesperrt — nur Automationen können ändern
- **Billing:** Vollständiges Zahlungstracking mit Auto-Triggern (Mandatsofferte → Zahlung 1, Shortlist → Zahlung 2, Placement → Zahlung 3) + Kündigungs-/Options-Rechnungen
- **KPI-Hard-Pflicht:** Ident Target, Call Target und Shortlist-Trigger müssen bei Aktivierung gesetzt sein (nur Target)
- **Time hat keine Longlist** — Kandidaten werden direkt geliefert, Kunde führt Prozess selbst

## Neu in v0.3

- **Kündigungs-Flow vollständig:** Atomare Transaktion mit Rechnungs-Auto-Generierung, PDF-Template-Trigger, Schutzfrist-Eröffnung (nur vorgestellte Kandidaten)
- **Longlist-Locking** via `is_longlist_locked` Feld: UI-Badge, keine neuen Stage-Wechsel, Durchcall-Queue leer
- **Offene Prozesse trotz Lock schliessbar:** Bulk-Action "Alle als Dropped markieren" + einzelne Status-Wechsel erlaubt
- **Kündigungs-Freigabe: AM alleine** (kein Admin-Gate)
- **Claim-Billing-Kontext-Logik:** Mandats-Konditionen vs. Erfolgsbasis-Staffel je nach Ursprungs-Prozess
- **Schutzfrist-Scope-Klarstellung:** nur konkret vorgestellte Kandidaten, keine Longlist-Idents
- **Schutzfrist-Gruppen-Integration:** `scope` Enum + `group_id` für Firmengruppen-Schutz
- Sprachstandard: `candidate_id` statt `kandidat_id`

## Alt v0.2

- **TEIL 9 Kündigung & Exit Option:** Fall A (Arkadium) / Fall B (Kunde) mit Formeln, Kündigungs-Drawer, Auto-Rechnungs-Generierung
- **TEIL 2b Optionale Stages VI–X:** Buchbare Zusatzleistungen mit `fact_mandate_option`, Auftragserteilung-PDF, Auto-Billing
- **TEIL 10 Schutzfrist-Integration:** `fact_candidate_presentation` + `fact_protection_window`, nur vorgestellte Kandidaten, Auto-Extension auf 16 Monate
- **TEIL 11 Verknüpfungen:** Assessment (Option IX + eigenständig), Referral (Kandidaten- + Kunden-Referral), Account-Detail-Referenzen
- **TEIL 12 Events & Audit:** 11 Mandat-Events für `fact_history`
- Header Quick-Actions: "⚡ Option buchen" + "🛑 Mandat kündigen"
- Snapshot-Bar Slot 7: Exklusivitäts-Badge

## Verlinkte Wiki-Seiten

[[mandat]], [[mandat-kuendigung]], [[direkteinstellung-schutzfrist]], [[optionale-stages]], [[diagnostik-assessment]], [[referral-programm]], [[longlist-research]], [[honorar-berechnung]], [[prozess]], [[factsheet-personalgewinnung]], [[mandatsofferte-vorlage]]
