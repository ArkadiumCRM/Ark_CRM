---
title: "Reminders"
type: concept
created: 2026-04-08
updated: 2026-04-17
sources: ["ARK_GESAMTSYSTEM_UEBERSICHT_v1_3.md TEIL 23", "ARK_DATABASE_SCHEMA_v1_3.md §fact_reminders", "ARK_BACKEND_ARCHITECTURE_v2_5.md §Reminders + v2.5.5", "ARK_FRONTEND_FREEZE_v1_10.md §Reminders (v1.10.5)", "ARK_STAMMDATEN_EXPORT_v1_3.md §64", "specs/ARK_REMINDERS_VOLLANSICHT_*"]
tags: [concept, reminders, notifications, vollansicht, tool-maske]
---

# Reminders

Auto-generierte und manuelle Erinnerungen. Tabelle: `fact_reminders`. Vorlagen-Katalog: `dim_reminder_templates` (10 Einträge, Stammdaten §64).

## Drei Oberflächen (komplementär)

| Oberfläche | Scope | Zweck | Quelle |
|------------|-------|-------|--------|
| Dashboard-Widget „Meine überfälligen Reminders" | User · Überfällig/Heute Top 5–8 | Morgen-Trigger | `mockups/dashboard.html` |
| Entity-Reminder-Tab | 1 Entity | „Was steht bei dieser Entität an?" | Kandidat §10, Account §13 |
| **Vollansicht `/reminders`** (Tool-Maske) | **Cross-Entity · User oder Team · alle Filter** | **„Was muss ich/mein Team tun?"** | siehe §Vollansicht unten |

## Auto-generierte Reminders

| Trigger | Reminder | Frist | Template (§64) |
|---------|----------|-------|----------------|
| Kandidat ohne Briefing | „Briefing fehlt" | 7 Tage | rt_09 |
| Onboarding Call | „Onboarding-Call" | Start − 7 Tage | rt_01 |
| Post-Placement | 1/2/3-Monats-Check | Nach Placement | rt_02/03/04 |
| Stale Prozess | „Prozess stagniert" | >14 Tage in gleicher Stage | — (Worker) |
| Data Retention | „Datenschutz-Warnung" | 30 Tage vor Frist | — |
| Ghosting | „Kandidat antwortet nicht" | Konfigurierbar | — |
| Datenschutz-Reset | „1 Jahr erreicht" | 1 Jahr nach Datenschutz | — |
| Interview-Coaching | „Coaching-Call vor Interview" | Termin − 2 Tage | rt_06 |
| Interview-Debriefing | „Debriefing nach Interview" | Termin (Abend) | rt_07 |
| Interview-Datum fehlt | „Datum fehlt" | 2 Tage nach Stage-Wechsel | rt_08 |
| Garantiefrist-Ende | „Garantie läuft aus" | placed_at + garantie_months | rt_05 |
| Schutzfrist-Info-Request | „Info-Request tracking" | täglich bei offener Anfrage | rt_10 |

## Funktionen

- **Priorität:** Urgent/High/Medium/Low (Dot-Farben)
- **Snooze:** +1h / +1d / +1w / Custom-Datum (Optimistic)
- **Recurring:** None/Daily/Weekly/Monthly
- **Direct Resolve:** „Erledigen" Optimistic Update
- **Reassign:** HoD+/Admin (Event `reminder_reassigned`)
- **Auto-Badge:** `is_auto_generated=true` → `⚙ Auto`-Chip mit Trigger-Tooltip
- **Drag-to-Reschedule:** Kalender-View, Chip auf anderen Tag → PATCH `due_date`

## Dashboard-Block

Block 1 auf dem Dashboard zeigt:
1. Überfällige (rot)
2. Heute (gelb)
3. Nächste 7 Tage

Footer-Link „Alle Reminders (N offen)" → `/reminders`.

## Vollansicht `/reminders` (Tool-Maske · neu 2026-04-17)

Dritte Tool-Maske neben `/operations/dok-generator` und `/operations/email-kalender`. Specs: [[../specs/ARK_REMINDERS_VOLLANSICHT_SCHEMA_v0_1]] + [[../specs/ARK_REMINDERS_VOLLANSICHT_INTERACTIONS_v0_1]] + [[../specs/ARK_REMINDERS_VOLLANSICHT_PLAN_v0_1]]. Mockup: `mockups/reminders.html`.

**Layout:** Page-Banner · KPI-Strip (6 Cards) · Saved-Views-Chips · View-Toggle (Liste/Kalender) · Filter-Bar · Status-Chip-Tabs (Liste-only) · Main · 2 Drawer (Detail 5-Tab · Neu).

**View-Modi:**
- **Liste** — Section-Groups Überfällig/Heute/Woche/Später/Erledigt (letzter collapsed)
- **Kalender** — Monat + Woche, CRM-intern (kein Outlook-Sync), Drag-to-Reschedule live

**Scope-Logik (lt. Interactions §9b):**
- `self` — `mitarbeiter_id = current_user_id`
- `team` — direkte Reports via `dim_mitarbeiter.vorgesetzter_id` (HoD-Perspektive)
- `all` — Tenant-weit (nur Admin)

Scope-Switcher nur für Admin/HoD sichtbar. AM/CM/RA/BO: fix `self`, kein Switcher.

**Saved Views:** rollen-spezifisch (System-Default je `rolle_type`) + max 10 User-defined. Storage: `dim_mitarbeiter.dashboard_config.reminders.saved_views[]` (JSONB) — keine separate Tabelle.

**Keine Bulk-Actions** (PO-Entscheidung — Sales würde unüberprüft durch-snoozen).

**Auto-Regeln** sind **nicht** hier — separate Admin-Maske `/admin/reminder-rules`.

## Eskalations-Logik

Worker `reminder-overdue-escalation.worker.ts` (Backend v2.5.5, hourly 08–20h):

| Schwelle | Aktion |
|----------|--------|
| `due_date < today` seit 24 h | Push-Notification an Zuständigen (In-App + Email) |
| `due_date < today` seit 48 h | Event `reminder_overdue_escalation` + Notification an Head of (`vorgesetzter_id`). Idempotent via `fact_reminders.escalation_sent_at` |
| Wöchentlich | KPI-Report an Admin (überfällige Reminders pro Mitarbeiter) |

## Events

- **Dediziert:** `reminder_batch_created` (Placement-Saga Step 7), `reminder_reassigned` (v2.5.5), `reminder_overdue_escalation` (v2.5.5)
- **Nicht dediziert (via `fact_audit_log` `entity_updated`):** Create/Complete/Snooze/Update — lt. BACKEND-Pattern (Z. 91)

## Related

- [[prozess]] — Post-Placement Reminders, Interview-Reminders
- [[kandidat]] — Tab 10: Reminders (Entity-Scope)
- [[account]] — Tab 13: Reminders (Entity-Scope, NEU v1.10)
- [[automationen]] — Auto-Generierung + Eskalationslogik
- [[interaction-patterns]] — Drawer-Default-Regel, Datum-Eingabe-Regel, Optimistic-Update
