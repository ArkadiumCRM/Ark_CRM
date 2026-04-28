---
title: "Spec-Sync-Regel"
type: meta
created: 2026-04-14
updated: 2026-04-14
sources: ["ARK_GESAMTSYSTEM_UEBERSICHT_v1_3.md TEIL 21"]
tags: [governance, spec-sync, regel, konsistenz]
---

# Spec-Sync-Regel — Grundlagen ↔ Detailmasken

**Grundsatz:** Änderungen an einer der 5 Grundlagendateien *UND* den Detailmasken-Specs müssen **immer bidirektional** synchronisiert werden. Keine Grundlagen-Datei darf stale bleiben während Detail-Specs weiterentwickelt werden — und umgekehrt.

## 5 Grundlagendateien (Single-Source-of-Truth je Ebene)

| # | Datei | Verantwortet |
|---|-------|--------------|
| 1 | `raw/Ark_CRM_v2/ARK_STAMMDATEN_EXPORT_v1_x.md` | Stammdaten, Enums, `dim_*`-Tabellen-Inhalte |
| 2 | `raw/Ark_CRM_v2/ARK_DATABASE_SCHEMA_v1_x.md` | Tabellen, Spalten, Constraints, Views, Migrations |
| 3 | `raw/Ark_CRM_v2/ARK_BACKEND_ARCHITECTURE_v2_x.md` | Endpunkte, Events, Worker, Sagas, Token-Auth |
| 4 | `raw/Ark_CRM_v2/ARK_FRONTEND_FREEZE_v1_x.md` | UI-Patterns, Design-System, Routing, Komponenten-Inventar |
| 5 | `raw/Ark_CRM_v2/ARK_GESAMTSYSTEM_UEBERSICHT_v1_x.md` | Gesamtbild, strukturelle Entscheidungen, Changelog |

## 9 Entity-Detailmasken + 4 Tool-Masken + 1 Admin-Vollansicht

**Entity-Detailmasken (9):** Je Entity eine Schema- + eine Interactions-Datei in `specs/`:
Kandidat · Account · Firmengruppe · Mandat · Job · Prozess · Assessment · Scraper · Projekt

**Tool-Masken (5):** Operative Tools ohne Entity-Bindung, mit Schema + Interactions:
- **Dok-Generator** (`/operations/dok-generator`) — `specs/ARK_DOK_GENERATOR_SCHEMA_v0_1.md` + `_INTERACTIONS_v0_1.md` (+ Plan/IMPL)
- **Email & Kalender** (`/operations/email-kalender`) — `specs/ARK_EMAIL_KALENDER_DETAILMASKE_SCHEMA_v0_1.md` + `_INTERACTIONS_v0_1.md`
- **Reminders** (`/reminders`) — `specs/ARK_REMINDERS_VOLLANSICHT_SCHEMA_v0_1.md` + `_INTERACTIONS_v0_1.md` (+ Plan) — neu 2026-04-17
- **Dashboard-Templates-Editor** (`/admin/dashboards`) — siehe Admin-Vollansicht Tab 8 + `specs/ARK_DASHBOARD_CUSTOMIZATION_SCHEMA_v1.md`
- **Performance-Tool** (`/operations/performance`) — `specs/ARK_PERFORMANCE_TOOL_SCHEMA_v0_1.md` + `_INTERACTIONS_v0_1.md` + `_MOCKUP_PLAN.md` — neu 2026-04-25

**System-Vollansichten (1 Admin + zukünftig HR):**
- **Admin-Vollansicht** (`/admin`) — `specs/ARK_ADMIN_VOLLANSICHT_SCHEMA_v0_1.md` + `_INTERACTIONS_v0_1.md` + `specs/ARK_ADMIN_DEBUG_SCHEMA_v1_0.md` (als Tab 9 eingebunden) — neu 2026-04-17
- **HR-Tool** (Phase 3) — **Plan v0.2 (po-reviewed)** + **Schema v0.1 (draft)** + **Interactions v0.1 (draft)** in `specs/ARK_HR_TOOL_*` (2026-04-19) · 28 Tabellen · 4 Views · 19 Drawer · 13 Worker · 29 Event-Codes · 5 Lifecycle-Sagas · Feature-Flag `feature_hr_tool` locked bis Go-Live · **Mockup-Build ausstehend**

**Sonder-Specs (nicht Entity, nicht Tool):**
- `ARK_PIPELINE_COMPONENT_v1_0.md` — Shared UI-Komponente (9-Dot-Pipeline), referenziert von mehreren Detailmasken
- `ARK_SYSTEM_ACTIVITY_TYPES_SCHEMA_v1.md` + `_DECISIONS_v1_3.md` — Activity-Type-Katalog-Erweiterung (v1.4)
- `ARK_EVENT_TYPES_MAPPING_v1_4.md` — Event-Katalog mit Mapping Events ↔ Activity-Types
- `ARK_DATABASE_SCHEMA_PATCH_v1_3_to_v1_4.md` + `ARK_BACKEND_ARCHITECTURE_PATCH_v2_5_to_v2_6.md` — Patch-Deltas bis Grundlagen-Rebase

## Sync-Matrix

| Änderungstyp in Detail-Spec | Trigger-Update in Grundlagendatei(en) |
|-----------------------------|----------------------------------------|
| Neues Feld in UI | DB-Schema (Spalte/CHECK) + Backend (ggf. Endpunkt/Event) |
| Neue ENUM-Werte | Stammdaten (dim_*) + DB-Schema (CHECK-Constraint) |
| Neuer Event | Backend-Architecture § Event-Katalog |
| Neuer Worker | Backend-Architecture § Worker |
| Neue Route / neuer Endpunkt | Backend-Architecture § Endpunkte + Frontend-Freeze § Routing |
| UI-Pattern (Drawer, Tab-Struktur, Inline-Edit) | Frontend-Freeze + Gesamtsystem Changelog |
| Neue Rolle / RBAC-Änderung | Frontend-Freeze + Backend-Architecture + [[rbac-matrix]] |
| Architektur-Entscheidung | Gesamtsystem Changelog + betroffene Grundlagendatei(en) |
| Algorithmus-Änderung (Scoring, Matching, Fuzzy) | [[algorithms]] + ggf. Backend |
| **Feature-Flag / Settings-Key** (v1.4+) | **Admin-Vollansicht Tab 1 + DB-Schema `dim_automation_settings`** |
| **Automation-Regel / Circuit-Breaker** (v1.4+) | **Admin-Vollansicht Tab 2 + DB-Schema + Backend Worker** |
| **Template-Änderung** (Reminder/Email/Notification) | **Admin-Vollansicht Tab 3/4/7 + `fact_template_versions` + Automation-Referenz-Check** |
| **Legal-Hold / Retention-Policy / DSG-Request** (v1.4+) | **Admin-Vollansicht Tab 10 + DB-Schema + Saga-Engine** |
| **Saga-Neu/Kompensation** (v1.4+) | **Backend-Architecture §Sagas + Admin-Vollansicht §K.3 + ggf. Debug-Spec §Saga-Traces** |

## Und umgekehrt

Änderungen in Grundlagendateien → **alle betroffenen Detail-Specs prüfen und synchronisieren**. Beispiel: neuer Pflicht-Feld in `dim_accounts` → Account-Schema v0.x + Account-Interactions v0.x aktualisieren, Frontend-Mockups anpassen.

## Admin-Vollansicht als Sync-Knotenpunkt (2026-04-17)

Die Admin-Vollansicht ist **sowohl Detail-Spec als auch Meta-Spec**: sie ist UI-Oberfläche (Detail-Spec-Ebene) und gleichzeitig die einzige UI, welche die Grundlagen direkt mutiert (z.B. Settings-Keys, Automation-Regeln, Templates, Retention-Policies).

**Zweifachpflicht bei Änderungen an:**

| Änderung in | Sync-Pflicht |
|-------------|--------------|
| Neue Settings-Keys | `dim_automation_settings` seeden (Migration-SQL) + Admin-Vollansicht Tab 1 UI + Admin-Spec §4 |
| Neue Event-Typen | `dim_event_types` seeden + Backend-Arch §A + Admin-Vollansicht §K.1 + `ARK_EVENT_TYPES_MAPPING_v1_4.md` |
| Neue Saga | Backend-Arch §Sagas + Admin-Vollansicht §K.3 + `ARK_ADMIN_DEBUG_SCHEMA_v1_0.md §Saga-Traces` |
| Neue Worker | Backend-Arch §B + Admin-Vollansicht §K.2 |
| Neue Rolle | RBAC-Matrix + Admin-Vollansicht §14 + Backend-Arch §K.5 + Frontend-Freeze Routing |
| Template-Änderung | Admin-Vollansicht §6-§7 + `fact_template_versions` + FK-Checks auf aktive Automation-Regeln |

**Kern-Regel:** Wer Grundlage X editiert, MUSS die Admin-Vollansicht-Spec gegenlesen und umgekehrt. Kein anderer Spec-Typ darf Grundlagen direkt mutieren (Dok-Generator generiert Dokumente, Email verwendet Templates — aber ändert sie nicht zur Laufzeit). **Admin ist Single-Write-Entry-Point für Config.**

## Verantwortung

Wer Änderungen einpflegt, **muss den Sync-Lauf ebenfalls ausführen**. Keine Teilmigrationen auf halbem Weg. Bei Unsicherheit: Audit-Durchlauf aller 5 Grundlagen + 9 Detail-Specs (vgl. [[audit-final-2026-04-14]]).

## Governance-Checkbox bei PR-Freigabe

Vor Merge muss explizit bestätigt werden:

- [ ] Grundlagendateien synchron mit Spec-Änderungen?
- [ ] Mockups aktualisiert (falls UI-relevant)?
- [ ] Wiki-Sources (Zusammenfassungen) aktualisiert?
- [ ] Log-Eintrag ergänzt?

## Stammdaten-Wording-Validierung (14.04.2026)

**Jede neue UI-Text-Erstellung muss zuerst gegen Stammdaten geprüft werden.** Labels, Filter-Optionen, Dropdown-Werte, Chip-Beschriftungen und Timeline-Events dürfen **nur** die in `ARK_STAMMDATEN_EXPORT_v1_3.md` definierten Begriffe verwenden.

**Kritische Kataloge:**
- Prozess-Stages §13: Expose · CV Sent · TI · 1st · 2nd · 3rd · Assessment · Offer · Placement
- Mandat-Typen: Target · Taskforce · Time
- Org-Funktion §10a: vr_board · executive · hr · einkauf · assistenz
- EQ-Dimensionen §67a: Selbstwahrnehmung · Selbstregulierung · Motivation · Soziale Wahrnehmung · Soziale Regulierung
- Motivatoren §67b: Theoretisch · Ökonomisch · Ästhetisch · Sozial · Individualistisch · Traditionell
- Sparten §8: ARC · GT · ING · PUR · REM
- Mitarbeiter-Darstellung: 2-Buchstaben-Kürzel (PW, JV, LR, MF…)
- **Activity-Types §14**: 64 Einträge in 11 Kategorien (Kontaktberührung · Erreicht · Emailverkehr · Messaging · Interviewprozess · Placementprozess · Refresh Kandidatenpflege · Mandatsakquise · Erfolgsbasis · Assessment · System). **Jede History-/Timeline-Zeile** muss aus diesem Katalog stammen — niemals freitext-Bezeichnungen erfinden. Format: `<Kategorie> — <Activity-Type-Name> · <Detail>`.

## Related

[[detailseiten-guideline]], [[detailseiten-inventar]], [[audit-final-2026-04-14]], [[rbac-matrix]], [[algorithms]]
