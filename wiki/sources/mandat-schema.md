---
title: "ARK Mandat Detailmaske Schema v0.2"
type: source
created: 2026-04-13
updated: 2026-04-17
sources: ["ARK_MANDAT_DETAILMASKE_SCHEMA_v0_2.md"]
tags: [source, mandat, schema, layout, kuendigung, longlist-lock, claim-faelle]
---

# ARK Mandat Detailmaske Schema v0.2

**Datei:** `specs/ARK_MANDAT_DETAILMASKE_SCHEMA_v0_2.md`
**Status:** v0.2 = Konsistenz-Update nach Audit 14.04.2026
**Begleitdokument:** [[mandat-interactions]] v0.3

## Änderungen v0.1 → v0.2

- **RBAC Kündigung**: Mandat-Kündigung durch **AM alleine** (Admin-Gate entfernt, Entscheidung 14.04.2026). Admin bleibt Read-Only.
- **Neues Feld** `fact_mandate.is_longlist_locked BOOLEAN` — wird bei Kündigung TRUE, sperrt Longlist-Editierung
- **Neues Feld** `fact_mandate.is_exclusive BOOLEAN DEFAULT TRUE` — Exklusivität hat kein Ablaufdatum, gilt solange Mandat offen
- **Neue Sektion 14.1** — Claim-Fälle X/Y/Z (Mandat-Claim-Billing-Logik bei Post-Kündigung-Einstellungen)
- Snapshot-Bar: 7 → 6 Slots harmonisiert (Garantie/Exklusivität als banner-chips statt Snapshot-Items)

## Schlüssel-Elemente

- **6 Tabs:** Übersicht · Longlist · Prozesse · Billing · History · Dokumente
- **Header mit 6-Slot Snapshot-Bar** (einheitlich über Target/Taskforce/Time, typ-spezifischer Slot-Content)
- **Quick Actions:** Anrufen · Email · Report · Reminder · Option buchen · **Mandat kündigen (AM)**
- **Tab 1 Übersicht** mit 9+1 Sektionen (inkl. Sektion 6b Optionale Stages, Sektion 9 konditional bei Abschluss/Kündigung)
- **Tab 2 Longlist:** 10-Spalten Kanban (4 Locked-Stages 5-8) + Listen-Toggle + Durchcall-Panel
- **Tab 4 Billing:** Typ-spezifische Zahlungspläne + Optionale-Stages + Kündigung/Rückerstattung + **Claim-Billing**
- **Tab 6 Dokumente:** 9 Kategorien inkl. Auto-Trigger-Dokumente (Kündigungs-Rechnung, Rückerstattungs-Gutschrift)
- **Terminated-Banner** Full-Width bei Status = Abgebrochen
- **Berechtigungs-Matrix** für 6 Rollen

## Claim-Fälle X/Y/Z (neu v0.2)

Wenn Mandat gekündigt UND später ein Longlist-Kandidat vom Kunden eingestellt wird:

| Fall | Konstellation | Billing-Logik |
|------|---------------|---------------|
| **X** | Ursprüngliche Position | **Restliche Mandats-Summe** fällig (Stage-Rest via `dim_honorar_settings`) |
| **Y** | Andere Position beim selben Kunden | **Erfolgsbasis-Deal** — neue Honorar-Berechnung auf Basis TC, Mandats-Rest entfällt |
| **Z** | Verbundene Gesellschaft (Firmengruppe) | Wie X/Y je nach Position, nur wenn Schutzfrist-Scope `group` greift |

**Technisch:**
- `fact_protection_window.claim_case ENUM('X','Y','Z')` nullable
- `fact_mandate_billing.billing_type = 'claim'` neu
- **Auslöser**: Scraper-Match oder manuelle Claim-Anlage durch AM

## Longlist-Lock bei Kündigung

`fact_mandate.is_longlist_locked`:
- Default FALSE während aktiver Mandat
- **Wird TRUE bei Kündigung** → Longlist-Editierung gesperrt (Read-Only)
- Zweck: Kandidaten-Daten einfrieren für spätere Claim-Prüfung (X/Y/Z)

## Snapshot-Bar-Slots (6, einheitlich über alle 3 Typen)

| Slot | Label (fix) | Value (typ-abhängig) |
|------|-------------|---------------------|
| 1 | 📊 Idents: X/Y | `research_count / target_idents` |
| 2 | 📞 Calls: X/Y | `call_count / target_calls` |
| 3 | 📋 Shortlist: X/Y CV Sent | `cv_sent_count / shortlist_trigger` |
| 4 | 💰 Pauschale/Monatsfee/Wochenfee | typ-spezifisch |
| 5 | ⏱ Time-to-fill: Woche X/Y | `current_week / expected_weeks` |
| 6 | 🏆 Placements: X/Y | `placement_count / target_positions` |

Garantie-Chip + Exklusivitäts-Chip jetzt als **banner-chips oberhalb Snapshot-Bar** (harmonisiert 2026-04-16).

## Mandat-Typen (3)

- **Target** (🎯 Gold) — Exklusiv-Einzelsuche, 3-Zahlungen-Plan (Vertrag/Shortlist/Placement)
- **Taskforce** (⚡ Teal) — Team-/Standortaufbau (ehemals RPO), Monatsfee + Success-Fee pro Position
- **Time** (⏱ Dunkelblau) — Slot-basierte Rekrutierungskapazität (Entry/Medium/Professional), Wochenfee pro Slot

## Offene Punkte

- Mockup-HTMLs für alle 6 Tabs (P1)
- Referral-Banner im Header (Kunden-Referral, P1)
- Exklusivitätsbruch-Detection-Flow (Scraper-basiert, Phase 2)
- Garantie-Case-Workflow (Ersatzbesetzung als Child-Mandat?, Phase 2)

## Verlinkte Wiki-Seiten

[[mandat]], [[mandat-interactions]], [[mandat-kuendigung]], [[optionale-stages]], [[direkteinstellung-schutzfrist]], [[diagnostik-assessment]], [[referral-programm]], [[detailseiten-guideline]]
