---
title: "Grundlagen-Changelog"
type: meta
created: 2026-04-16
updated: 2026-04-16
tags: [meta, sync, changelog]
---

# Grundlagen-Changelog

Automatisch befüllt durch `PostToolUse`-Hook bei Edit/Write auf `raw/Ark_CRM_v2/ARK_*.md`.

## Zweck

Jede Änderung an einer der 5 Grundlagen-Dateien wird hier mit Timestamp + Session-ID + Datei geloggt. Beim nächsten `/prime-ark` werden `Status: unresolved`-Einträge aufgegriffen und auf Sync-Fortschritt geprüft.

## Status-Werte

- `unresolved` — Änderung passiert, noch nicht in Specs/Mockups nachgezogen
- `in-progress` — Sync läuft, teilweise gemacht
- `resolved` — Alle betroffenen Specs/Mockups aktualisiert

## Hook-Source

`.claude/hooks/grundlagen-changelog.ps1` + Eintrag in `.claude/settings.json` → `hooks.PostToolUse`

## Einträge

<!-- Neue Einträge werden nach diesem Kommentar appended. Älteste oben (chronologisch). -->

### 2026-04-19 · Zeit-Modul v0.1 Grundlagen-Sync

- **File:** `ARK_STAMMDATEN_EXPORT_v1_3.md` → v1.4 (append §90 Zeit-Modul-Stammdaten)
- **File:** `ARK_DATABASE_SCHEMA_v1_3.md` → v1.4 (append 15 Tabellen + 4 Views + 9 Enums + btree_gist)
- **File:** `ARK_BACKEND_ARCHITECTURE_v2_5.md` → v2.6 (append M. Zeit-Modul · 21 Endpoints · 12 Events · 9 Workers · 4 Sagas)
- **File:** `ARK_FRONTEND_FREEZE_v1_10.md` → v1.11 (append Zeit-Modul UI-Pattern · 7 Screens + 5 Drawer + 2 Modals)
- **Status:** resolved (Specs v0.1 + Decisions-Log + Grundlagen-Sync alle fertig)
- **Resolved-In:** `specs/ARK_ZEIT_SCHEMA_v0_1.md` + `specs/ARK_ZEIT_INTERACTIONS_v0_1.md` + `wiki/meta/zeit-decisions-2026-04-19.md`
- **Session:** Phase 3 ERP Zeit-Modul · Phase A (Q&A) + B (Specs) + C (Grundlagen-Sync)
- **Digest-Status:** STALE · nach Commit regenerieren
- **Sync-Kaskade zu Detailmasken:** N/A — Zeit-Modul ist NEUES Modul, tangiert keine der 9 existierenden Detailmasken (Kandidat/Account/Job/Mandat/Prozess/Firmengruppe/Projekt/Assessment/Dokgenerator)
- **Next:** Phase D · 7 Mockups (zeit-meine-zeit · zeit-monat · zeit-abwesenheiten · zeit-team · zeit-saldi · zeit-export · zeit-admin)

## [2026-04-16 22:05] session-340bf0c3
- **File:** ARK_STAMMDATEN_EXPORT_v1_3.md
- **Tool:** Edit
- **Status:** resolved
- **Resolved:** 2026-04-16 23:05
- **Sync-Check:** Drift-Scan Specs + Mockups via Explore-Agent. Mandat-Typen-Drift (Retainer/RPO/Einzelmandat) gefixt.
- **Resolved-In:** specs/ARK_ACCOUNT_DETAILMASKE_INTERACTIONS_v0_3.md · specs/ARK_KANDIDATENMASKE_SCHEMA_v1_3.md · mockups/candidates.html · mockups/processes.html

## [2026-04-16 22:09] session-340bf0c3
- **File:** ARK_GESAMTSYSTEM_UEBERSICHT_v1_3.md
- **Tool:** Edit
- **Status:** resolved
- **Resolved:** 2026-04-16 23:05
- **Sync-Check:** overview.md + index.md Versions-/Content-Drift gefixt (v1.2→v1.3, v1.9→v1.10, v2.4→v2.5, Projekt-Entity ergänzt, TEIL 20/20b/20c-Nachträge, Duplikat entfernt).
- **Resolved-In:** wiki/meta/overview.md · index.md

## [2026-04-16 22:09] session-340bf0c3
- **File:** ARK_GESAMTSYSTEM_UEBERSICHT_v1_3.md
- **Tool:** Edit
- **Status:** resolved
- **Resolved:** 2026-04-16 23:05
- **Sync-Check:** Gemeinsam mit 22:09-Eintrag 1 resolved (identischer Scope).
- **Resolved-In:** wiki/meta/overview.md · index.md

## [2026-04-16 22:09] session-340bf0c3
- **File:** ARK_FRONTEND_FREEZE_v1_10.md
- **Tool:** Edit
- **Status:** resolved
- **Resolved:** 2026-04-16 23:05
- **Sync-Check:** Mockup-Drift-Scan via Explore-Agent. 1 CRITICAL (mandates.html z-index:10 → :50) gefixt. 5 andere Masken (accounts/candidates/jobs/projects/groups) Snapshot-Konvention clean.
- **Resolved-In:** mockups/mandates.html

## [2026-04-16 22:28] session-340bf0c3
- **File:** ARK_STAMMDATEN_EXPORT_v1_3.md
- **Tool:** Edit
- **Status:** resolved
- **Resolved:** 2026-04-16 23:05
- **Sync-Check:** Gemeinsam mit 22:05-Eintrag resolved (identischer Scope, iterativer Edit).
- **Resolved-In:** siehe 22:05

## [2026-04-16 22:28] session-340bf0c3
- **File:** ARK_STAMMDATEN_EXPORT_v1_3.md
- **Tool:** Edit
- **Status:** resolved
- **Resolved:** 2026-04-16 23:05
- **Sync-Check:** Gemeinsam mit 22:05-Eintrag resolved (identischer Scope, iterativer Edit).
- **Resolved-In:** siehe 22:05

## [2026-04-16 22:44] session-340bf0c3
- **File:** ARK_STAMMDATEN_EXPORT_v1_3.md
- **Tool:** Edit
- **Status:** resolved
- **Resolved:** 2026-04-16 23:05
- **Sync-Check:** Gemeinsam mit 22:05-Eintrag resolved (identischer Scope, iterativer Edit).
- **Resolved-In:** siehe 22:05

## [2026-04-16 22:44] session-340bf0c3
- **File:** ARK_GESAMTSYSTEM_UEBERSICHT_v1_3.md
- **Tool:** Edit
- **Status:** resolved
- **Resolved:** 2026-04-16 23:05
- **Sync-Check:** Gemeinsam mit 22:09-Eintrag resolved (identischer Scope, iterativer Edit).
- **Resolved-In:** siehe 22:09

## [2026-04-16 22:45] session-340bf0c3
- **File:** ARK_GESAMTSYSTEM_UEBERSICHT_v1_3.md
- **Tool:** Edit
- **Status:** resolved
- **Resolved:** 2026-04-16 23:05
- **Sync-Check:** Gemeinsam mit 22:09-Eintrag resolved (identischer Scope, iterativer Edit).
- **Resolved-In:** siehe 22:09

## [2026-04-16 22:45] session-340bf0c3
- **File:** ARK_FRONTEND_FREEZE_v1_10.md
- **Tool:** Edit
- **Status:** resolved
- **Resolved:** 2026-04-16 23:05
- **Sync-Check:** Gemeinsam mit 22:09-Eintrag resolved (identischer Scope, iterativer Edit).
- **Resolved-In:** siehe 22:09 FRONTEND-Eintrag

## [2026-04-16 22:45] session-340bf0c3
- **File:** ARK_FRONTEND_FREEZE_v1_10.md
- **Tool:** Edit
- **Status:** resolved
- **Resolved:** 2026-04-16 23:05
- **Sync-Check:** Gemeinsam mit 22:09-Eintrag resolved (identischer Scope, iterativer Edit).
- **Resolved-In:** siehe 22:09 FRONTEND-Eintrag

## [2026-04-16 23:05] Session-Sync-Zusammenfassung

Alle 11 Einträge aus Session 340bf0c3 in einem Sync-Pass resolved. Drift-Scan via 2 Explore-Agents (STAMMDATEN · FRONTEND_FREEZE) + direkte GESAMTSYSTEM-Analyse. Fixes:

- **STAMMDATEN-Drift:** 2 Specs + 2 Mockups (Mandat-Typen-Umbenennung v1.3: Retainer/RPO/Einzelmandat → Target/Taskforce/Time; Prozess-Stage "Angebot" → "Offer")
- **GESAMTSYSTEM-Drift:** wiki/meta/overview.md (Sources auf v1.3/v1.10/v2.5 aktualisiert, Projekt/Firmengruppe/Assessment/Scraper in Kernmodule-Tabelle ergänzt, Duplikat-Zeile entfernt, v1.3.x-Nachträge dokumentiert) + index.md (5 Versions-Strings)
- **FRONTEND-Drift:** mockups/mandates.html (`.mandat-snapshot` z-index:10 → :50 für Stacking-Konvention §6)
- **MEDIUM-Drifts gefixt (23:12):** processes.html Prozess-Snapshot jetzt in Freeze §6 dokumentiert (Zeile ergänzt); mandates.html `.mandat-snapshot` Legacy-CSS entfernt, 72px-Tabbar-Offset mit Inline-Kommentar begründet (Progress-Bar-Höhen-Kompensation).

## [2026-04-16 23:12] session-00e0438d
- **File:** ARK_FRONTEND_FREEZE_v1_10.md
- **Tool:** Edit
- **Status:** resolved
- **Resolved:** 2026-04-16 23:13
- **Sync-Check:** Selber Edit ist die Resolution — Prozess-Zeile in §6 Slot-Allokations-Tabelle ergänzt (Stage-Alter · Nächstes Interview · Win-Probability · Pipeline-Wert · CM/AM · Garantie), um bestehendes Mockup `processes.html:444` zu dokumentieren.
- **Resolved-In:** raw/Ark_CRM_v2/ARK_FRONTEND_FREEZE_v1_10.md §6 + mockups/processes.html (bereits konform)

## [2026-04-17 01:13] session-test
- **File:** ARK_STAMMDATEN_EXPORT_v1_3.md
- **Tool:** Edit
- **Status:** resolved
- **Sync-Check:** Synthetic hook-pipe-test (no real edit) — discarded.
- **Resolved-In:** Test-Eintrag, keine Aktion erforderlich.

## [2026-04-17 14:08] session-f3a148a3
- **File:** ARK_STAMMDATEN_EXPORT_v1_3.md
- **Tool:** Edit
- **Status:** resolved
- **Resolved:** 2026-04-17 (backfill) — absorbiert durch Session dd3f8b6c Email-Kalender-Arbeit
- **Sync-Check:** Session f3a148a3 (14:08–14:11) war Preparatory-Edit-Pass über alle 5 Grundlagen-Dateien vor dem Email-Kalender-Build. Drift-Check §14 Emailverkehr / §14a Templates: Specs `ARK_EMAIL_KALENDER_DETAILMASKE_SCHEMA_v0_1.md` referenzieren 11 Einträge + 38 Templates sauber, `mockups/email-kalender.html` konform. Kein zusätzlicher Drift gegenüber der 15:00-Resolution.
- **Resolved-In:** siehe 15:00-Block (Email-Kalender-Aufnahme in FRONTEND_FREEZE)
- **Digest-Stale:** stammdaten-digest.md weiterhin ok (§64 passt lt. 16:35-STALE-Log)

## [2026-04-17 14:08] session-f3a148a3
- **File:** ARK_DATABASE_SCHEMA_v1_3.md
- **Tool:** Edit
- **Status:** resolved
- **Resolved:** 2026-04-17 (backfill) — absorbiert durch Session dd3f8b6c Email-Kalender-Arbeit
- **Sync-Check:** DB-Schema-Edit bereitete `dim_integration_tokens` · `dim_email_templates` · `fact_email_drafts` für Email-Kalender vor. Entity-Specs (Kandidat v1.3, Account v0.2) zeigen keinen Drift. Spec `ARK_EMAIL_KALENDER_DETAILMASKE_SCHEMA_v0_1.md` nutzt die Tabellen korrekt.
- **Resolved-In:** siehe 15:00-Block
- **Digest-Stale:** database-schema-digest.md aktuell (Regeneriert 16:35)

## [2026-04-17 14:09] session-f3a148a3
- **File:** ARK_BACKEND_ARCHITECTURE_v2_5.md
- **Tool:** Edit
- **Status:** resolved
- **Resolved:** 2026-04-17 (backfill) — identischer Scope zur 14:18-Shared-Mailbox-Umstellung
- **Sync-Check:** 14:09-Edit war iterativer Vorläufer der 14:18-Architektur-Umstellung (Shared-Mailbox → User-Tokens). Bereits in 14:22-Resolution dokumentiert und in `wiki/concepts/email-system.md` + `mockups/email-kalender.html` nachgezogen.
- **Resolved-In:** siehe 14:22-Resolution (Architektur-Umstellung Shared-Mailbox → User-Tokens)
- **Digest-Stale:** backend-architecture-digest.md Regeneriert 16:35

## [2026-04-17 14:10] session-f3a148a3
- **File:** ARK_FRONTEND_FREEZE_v1_10.md
- **Tool:** Edit
- **Status:** resolved
- **Resolved:** 2026-04-17 (backfill) — identischer Scope zur 14:50/14:51-§4f-Aufnahme
- **Sync-Check:** 14:10-Edit war iterativer Vorläufer der 14:51-§4f-Email-Kalender-Aufnahme in FRONTEND_FREEZE. Grep-Scan: Keine Restverweise auf „Email-Inbox" (alle auf „Email & Kalender" umgestellt), Sibling-Liste sauber.
- **Resolved-In:** siehe 15:00-Block (§4f Operations · Email & Kalender)
- **Digest-Stale:** frontend-freeze-digest.md Regeneriert 18:43

## [2026-04-17 14:11] session-f3a148a3
- **File:** ARK_GESAMTSYSTEM_UEBERSICHT_v1_3.md
- **Tool:** Edit
- **Status:** resolved
- **Resolved:** 2026-04-17 (backfill) — absorbiert durch 15:00-Email-Kalender-Block
- **Sync-Check:** Drift-Scan `wiki/meta/overview.md` Zeile 56: Email & Kalender-Eintrag mit Route `/operations/email-kalender`, MS Graph, CodeTwo, 38 Templates korrekt integriert. `index.md`-Versions-Strings konsistent.
- **Resolved-In:** wiki/meta/overview.md · index.md (bereits nachgezogen in 15:00-Block)
- **Digest-Stale:** gesamtsystem-digest.md Regeneriert 18:05

## [2026-04-17 14:11] session-f3a148a3 | RESOLUTION ✓ (Backfill — f3a148a3 als Preparatory-Pass für Email-Kalender)

Alle 5 Einträge aus Session f3a148a3 (14:08–14:11) nachträglich als `resolved` markiert. Kontextuelle Analyse:

- **Session-Sequenz:** f3a148a3 (14:08–14:11) → dd3f8b6c (14:18–15:00) — dd3f8b6c-Edits bauen direkt auf f3a148a3 auf (Shared-Mailbox-Removal, §4f-Aufnahme, Spec-Erstellung Email-Kalender).
- **Drift-Check durchgeführt:** STAMMDATEN §14/§14a (11 Activity-Types + 38 Templates) — keine Restverweise auf alte Begriffe. DB-Tabellen (`dim_integration_tokens`, `dim_email_templates`, `fact_email_drafts`) in `email-kalender.html` + Spec korrekt. BACKEND-Umstellung User-Tokens + Ordner-Modell in Wiki + Mockup konsistent. FRONTEND §4f vollständig. GESAMTSYSTEM overview.md Zeile 56 aktuell.
- **Annahme:** Die 5 Edits waren iterative Vorbereitung auf die Email-Kalender-Architektur — kein eigenständiger Scope, daher Gesamtauflösung via 14:22-/15:00-Resolutionen ausreichend.

**Kein eigenständiger Drift gefunden.**

## [2026-04-17 14:18] session-dd3f8b6c
- **File:** ARK_BACKEND_ARCHITECTURE_v2_5.md
- **Tool:** Edit
- **Status:** resolved
- **Resolved:** 2026-04-17 14:22
- **Sync-Check:** Architektur-Umstellung Shared-Mailbox → Individuelle User-Tokens. 3 iterative Edits (Outlook-Config-Block · Shared-Mailbox-Ansatz-Block · ENV-Var OUTLOOK_SHARED_ACCOUNT). Grund: PO-Entscheidung — kein Shared-Mailbox-Zwischenschritt, Mitarbeiter OAuth-verbinden persönliche Postfächer direkt.
- **Resolved-In:** wiki/concepts/email-system.md (v1.3 refresh · Individuelle User-Tokens dokumentiert · Ordner-Modell Klassifiziert/Unbekannt/Inbox/Ignoriert ergänzt) · mockups/email-kalender.html (Konten-Drawer: einzelne Personal-Mailbox-Card statt 2 Phase-Cards · Compose-Drawer Absender-Select und Sub-Text bereinigt)
- **Digest-Stale:** ja → Backend-Architecture-Digest neu generieren

## [2026-04-17 14:18] session-dd3f8b6c | RESOLUTION ✓ (Zusammenfassung)

Alle 3 Einträge in einem Sync-Pass resolved. Architektur-Änderung dokumentiert in:
- `Grundlagen MD/ARK_BACKEND_ARCHITECTURE_v2_5.md` §Outlook/Microsoft Graph (3 Blöcke)
- `wiki/concepts/email-system.md` (Outlook-Integration-Sektion + neue Sektion „Ordner-Modell")
- `mockups/email-kalender.html` (Konten-Drawer + Compose-Drawer)

**Offen:** Backend-Architecture-Digest stale-Flag (siehe `wiki/meta/digests/STALE.md`) — Digest regenerieren via Agent nach nächstem Commit.

## [2026-04-17 14:50] session-dd3f8b6c
- **File:** ARK_FRONTEND_FREEZE_v1_10.md
- **Tool:** Edit
- **Status:** resolved
- **Resolved:** 2026-04-17 15:00
- **Sync-Check:** Sibling-Text in §4e Dok-Generator von „Email-Inbox" auf „Email & Kalender" aktualisiert (Konsistenz zum umbenannten Modul).
- **Resolved-In:** Wording-Update in bestehender §4e · keine weitere Spec-/Mockup-Auswirkung
- **Digest-Stale:** frontend-freeze-digest regenerieren

## [2026-04-17 14:51] session-dd3f8b6c
- **File:** ARK_FRONTEND_FREEZE_v1_10.md
- **Tool:** Edit
- **Status:** resolved
- **Resolved:** 2026-04-17 15:00
- **Sync-Check:** Neue Sektion §4f Operations · Email & Kalender (NEU 2026-04-17) ergänzt. Dokumentiert: Location `/operations/email-kalender` · Architektur-Entscheidungen · Layout · 8 Drawer-Inventar · Ordner-Modell · Activity-Type-Katalog-Referenz · MS-Graph-Integration · RBAC · Design-System-Konformität.
- **Resolved-In:** `specs/ARK_EMAIL_KALENDER_DETAILMASKE_SCHEMA_v0_1.md` (neu) · `specs/ARK_EMAIL_KALENDER_DETAILMASKE_INTERACTIONS_v0_1.md` (neu) · `mockups/email-kalender.html` · `mockups/crm.html:141` · `wiki/concepts/email-system.md` · `wiki/meta/overview.md` · `index.md` · `wiki/meta/spec-sync-regel.md`
- **Digest-Stale:** frontend-freeze-digest regenerieren

## [2026-04-17 15:00] session-dd3f8b6c | RESOLUTION ✓ (Email-Kalender-Aufnahme in FRONTEND_FREEZE)

Beide FRONTEND_FREEZE-Einträge resolved. Email & Kalender als 10. Detail-/Tool-Maske ins FRONTEND_FREEZE §4f aufgenommen. Sync-Kaskade über Specs · Mockup · Wiki · Meta abgeschlossen.

**Digest-Stale-Status (offen, via Agent zu regenerieren):**
- `wiki/meta/digests/backend-architecture-digest.md` (aus 14:18-Edits · Shared-Mailbox-Removal)
- `wiki/meta/digests/frontend-freeze-digest.md` (aus 14:50/14:51-Edits · §4f Email-Kalender)

## [2026-04-17 16:16] session-3131f2f7
- **File:** ARK_DATABASE_SCHEMA_v1_3.md
- **Tool:** Edit
- **Status:** resolved
- **Resolved:** 2026-04-17 18:15
- **Sync-Check:** Siehe Session-Sync-Zusammenfassung(en) unten (16:32 Reminders + 18:12 Mobile-Support).
- **Resolved-In:** siehe Zusammenfassungs-Blöcke.

## [2026-04-17 16:17] session-3131f2f7
- **File:** ARK_DATABASE_SCHEMA_v1_3.md
- **Tool:** Edit
- **Status:** resolved
- **Resolved:** 2026-04-17 18:15
- **Sync-Check:** Siehe Session-Sync-Zusammenfassung(en) unten (16:32 Reminders + 18:12 Mobile-Support).
- **Resolved-In:** siehe Zusammenfassungs-Blöcke.

## [2026-04-17 16:17] session-3131f2f7
- **File:** ARK_BACKEND_ARCHITECTURE_v2_5.md
- **Tool:** Edit
- **Status:** resolved
- **Resolved:** 2026-04-17 18:15
- **Sync-Check:** Siehe Session-Sync-Zusammenfassung(en) unten (16:32 Reminders + 18:12 Mobile-Support).
- **Resolved-In:** siehe Zusammenfassungs-Blöcke.

## [2026-04-17 16:17] session-3131f2f7
- **File:** ARK_BACKEND_ARCHITECTURE_v2_5.md
- **Tool:** Edit
- **Status:** resolved
- **Resolved:** 2026-04-17 18:15
- **Sync-Check:** Siehe Session-Sync-Zusammenfassung(en) unten (16:32 Reminders + 18:12 Mobile-Support).
- **Resolved-In:** siehe Zusammenfassungs-Blöcke.

## [2026-04-17 16:18] session-3131f2f7
- **File:** ARK_BACKEND_ARCHITECTURE_v2_5.md
- **Tool:** Edit
- **Status:** resolved
- **Resolved:** 2026-04-17 18:15
- **Sync-Check:** Siehe Session-Sync-Zusammenfassung(en) unten (16:32 Reminders + 18:12 Mobile-Support).
- **Resolved-In:** siehe Zusammenfassungs-Blöcke.

## [2026-04-17 16:18] session-3131f2f7
- **File:** ARK_BACKEND_ARCHITECTURE_v2_5.md
- **Tool:** Edit
- **Status:** resolved
- **Resolved:** 2026-04-17 18:15
- **Sync-Check:** Siehe Session-Sync-Zusammenfassung(en) unten (16:32 Reminders + 18:12 Mobile-Support).
- **Resolved-In:** siehe Zusammenfassungs-Blöcke.

## [2026-04-17 16:18] session-3131f2f7
- **File:** ARK_DATABASE_SCHEMA_v1_3.md
- **Tool:** Edit
- **Status:** resolved
- **Resolved:** 2026-04-17 18:15
- **Sync-Check:** Siehe Session-Sync-Zusammenfassung(en) unten (16:32 Reminders + 18:12 Mobile-Support).
- **Resolved-In:** siehe Zusammenfassungs-Blöcke.

## [2026-04-17 16:19] session-3131f2f7
- **File:** ARK_FRONTEND_FREEZE_v1_10.md
- **Tool:** Edit
- **Status:** resolved
- **Resolved:** 2026-04-17 18:15
- **Sync-Check:** Siehe Session-Sync-Zusammenfassung(en) unten (16:32 Reminders + 18:12 Mobile-Support).
- **Resolved-In:** siehe Zusammenfassungs-Blöcke.

## [2026-04-17 16:19] session-3131f2f7
- **File:** ARK_GESAMTSYSTEM_UEBERSICHT_v1_3.md
- **Tool:** Edit
- **Status:** resolved
- **Resolved:** 2026-04-17 18:15
- **Sync-Check:** Siehe Session-Sync-Zusammenfassung(en) unten (16:32 Reminders + 18:12 Mobile-Support).
- **Resolved-In:** siehe Zusammenfassungs-Blöcke.

## [2026-04-17 16:20] session-3131f2f7
- **File:** ARK_GESAMTSYSTEM_UEBERSICHT_v1_3.md
- **Tool:** Edit
- **Status:** resolved
- **Resolved:** 2026-04-17 16:32
- **Sync-Check:** Siehe Session-Sync-Zusammenfassung unten.
- **Resolved-In:** siehe Block unten.

## [2026-04-17 16:32] session-3131f2f7 | RESOLUTION ✓ (Zusammenfassung Reminders-Vollansicht)

Alle 10 Einträge aus Session 3131f2f7 (16:16–16:20) in einem Sync-Pass resolved im Rahmen der **Reminders-Vollansicht-Implementierung (Phase 0–5)**. Alle betroffenen Grundlagen-Edits waren Teil eines kohärenten Feature-Scopes und wurden durchgängig in Specs + Mockups + Wiki synchronisiert.

**Scope:** Neue Tool-Maske `/reminders` (3. neben Dok-Gen + Email-Kalender).

**Grundlagen-Edits (stale-flagged → Digests regenerieren):**
- `ARK_DATABASE_SCHEMA_v1_3.md` v1.3.4 → v1.3.5: `fact_reminders.template_id FK` + `escalation_sent_at` · `dim_mitarbeiter.dashboard_config` JSONB-Doku für Saved-Views
- `ARK_BACKEND_ARCHITECTURE_v2_5.md` v2.5.4 → v2.5.5: 2 Events (`reminder_reassigned`, `reminder_overdue_escalation`) · 1 Worker (`reminder-overdue-escalation.worker.ts`, hourly 08–20h) · 3 Endpoints (`reassign`, `GET/PATCH user-preferences/reminders`). Lifecycle-Events (create/complete/snooze/update) via `fact_audit_log` `entity_updated`-Pattern
- `ARK_FRONTEND_FREEZE_v1_10.md` v1.10.4 → v1.10.5: §Reminders komplett erweitert
- `ARK_GESAMTSYSTEM_UEBERSICHT_v1_3.md` v1.3.4 → v1.3.5: TEIL 23 Nachtrag
- `ARK_STAMMDATEN_EXPORT_v1_3.md` **unverändert** (§64 passt 1:1)

**Resolved-In:**
- `specs/ARK_REMINDERS_VOLLANSICHT_PLAN_v0_1.md` (neu)
- `specs/ARK_REMINDERS_VOLLANSICHT_SCHEMA_v0_1.md` (neu, 16 §)
- `specs/ARK_REMINDERS_VOLLANSICHT_INTERACTIONS_v0_1.md` (neu, 14 §)
- `mockups/reminders.html` (neu, Liste + Kalender + Drag + 2 Drawer)
- `mockups/candidates.html` (Tab 10 Footer: Deep-Link)
- `mockups/accounts.html` (Tab 13 Footer: Deep-Link)
- `mockups/dashboard.html` (Reminder-Widget-Link)
- `mockups/crm.html` (Sidebar-Nav: Reminders-Link aktiviert)
- `wiki/concepts/reminders.md` · `wiki/meta/detailseiten-inventar.md` · `wiki/meta/spec-sync-regel.md` · `wiki/meta/mockup-baseline.md` §16.12
- `index.md` + `log.md`

**Digest-Stale:** ja → 4 Digests regenerieren (database-schema · backend-architecture · frontend-freeze · gesamtsystem).

**Detail-Masken-Spec-Prüfung:** Kandidat-Schema v1.3 + Account-Schema v0.2 haben Reminder-Tab-Sektionen, die mit neuer Vollansicht verträglich bleiben (Entity-Tab-Scope unverändert, Deep-Link zur Vollansicht zusätzlich). Keine Breaking Changes.

**Hinweis:** Die 10 einzelnen Einträge oben bleiben als Audit-Trail sichtbar; Status ist auf `resolved` über diese Zusammenfassung gesetzt.

## [2026-04-17 18:03] session-3131f2f7
- **File:** ARK_FRONTEND_FREEZE_v1_10.md
- **Tool:** Edit
- **Status:** resolved
- **Resolved:** 2026-04-17 18:15
- **Sync-Check:** Siehe Session-Sync-Zusammenfassung(en) unten (16:32 Reminders + 18:12 Mobile-Support).
- **Resolved-In:** siehe Zusammenfassungs-Blöcke.

## [2026-04-17 18:03] session-3131f2f7
- **File:** ARK_FRONTEND_FREEZE_v1_10.md
- **Tool:** Edit
- **Status:** resolved
- **Resolved:** 2026-04-17 18:15
- **Sync-Check:** Siehe Session-Sync-Zusammenfassung(en) unten (16:32 Reminders + 18:12 Mobile-Support).
- **Resolved-In:** siehe Zusammenfassungs-Blöcke.

## [2026-04-17 18:04] session-3131f2f7
- **File:** ARK_GESAMTSYSTEM_UEBERSICHT_v1_3.md
- **Tool:** Edit
- **Status:** resolved
- **Resolved:** 2026-04-17 18:12
- **Sync-Check:** Siehe Zusammenfassung unten.
- **Resolved-In:** siehe Block unten.

## [2026-04-17 18:12] session-3131f2f7 | RESOLUTION ✓ (Mobile/Tablet-Support v1.3.6)

Alle 3 Einträge aus Session 3131f2f7 (18:03–18:04) resolved im Rahmen der **Mobile/Tablet-Support-Implementierung (Phase 1–3)**.

**Scope:** Frontend-Rewrite von „Tablet Read-Only + Mobile Blocker" zu vollem Mobile-/Tablet-Support. Keine DB-/Backend-Änderungen.

**Grundlagen-Edits:**
- `ARK_FRONTEND_FREEZE_v1_10.md` v1.10.5 → v1.11: §24b Responsive Policy komplett rewrite · Prinzip 6 umformuliert („Desktop-First App mit vollem Mobile-/Tablet-Support")
- `ARK_GESAMTSYSTEM_UEBERSICHT_v1_3.md` v1.3.5 → v1.3.6: TEIL 24 Nachtrag + Changelog-Block
- `ARK_DATABASE_SCHEMA_v1_3.md` · `ARK_BACKEND_ARCHITECTURE_v2_5.md` · `ARK_STAMMDATEN_EXPORT_v1_3.md` **unverändert**

**Resolved-In (Mockup-Layer):**
- `mockups/crm.html` (responsive App-Shell — Top-Bar + Slide-Out-Sidebar + Safe-Area-Inset, Breakpoints > 960 / 641–960 / ≤ 640)
- `mockups/crm-mobile.html` (neu: 3-iframe-Device-Frames-Demo)
- `mockups/_shared/editorial.css` (globale Mobile-Rules: KPI 2-col, DataTable → Card-Stack, Drawer → Full-Screen-Sheet, Filter-Bar/Tabs horizontal scroll, Snapshot-Bar stack)
- `mockups/dashboard.html` (Mobile-Media-Queries, data-mobile-Flags aktiv)
- `mockups/reminders.html` (Kalender-Grid horizontal scroll, Drawer-Tabs scroll)
- `mockups/email-kalender.html` (3-Pane → Pane-Toggle, Cal-Sidebar → Drawer, JS-Verdrahtung)
- `mockups/dok-generator.html` (Sidebar → Slide-in-Drawer, Template-Grid 1-col, A4-Canvas scale(0.55), JS-Toggle)
- `mockups/processes.html` (Pipeline-Popover full-width)
- Viewport-Meta in 22 Mockup-HTMLs (21 via sed-Rollout + admin.html manuell)

**Resolved-In (Wiki):**
- `wiki/meta/digests/frontend-freeze-digest.md` (§24b Responsive-Policy aktualisiert)
- `wiki/meta/digests/gesamtsystem-digest.md` (TOC + Changelog für v1.3.6, TEIL 24)

**Digest-Stale:** 2 Digests aktualisiert (frontend-freeze, gesamtsystem). Andere Digests unverändert für diese Session.

**Detail-Masken-Spec-Prüfung:** Keine Detail-Masken-Spec-Änderung nötig — Mobile-Support ist CSS-only + App-Shell + Pattern-Anwendung. Bestehende Specs (9 Entity + 3 Tool-Masken) bleiben gültig.

**Technical-Debt (Phase 3.5 offen):**
- Touch-Gesten (Swipe-to-Complete, Swipe-Back)
- Accessibility-Audit (Focus-Trap, Screen-Reader)
- Performance-Review (TanStack Virtual Mobile-Scroll)
- Deep-Tests Entity-Detailmasken im echten Mobile-Viewport

**Hinweis:** Die 3 einzelnen Einträge oben bleiben als Audit-Trail sichtbar; Status über diese Zusammenfassung auf `resolved` gesetzt.

## [2026-04-17 18:37] session-cea13e34
- **File:** ARK_FRONTEND_FREEZE_v1_10.md
- **Tool:** Edit
- **Status:** resolved
- **Resolved:** 2026-04-17 18:45
- **Sync-Check:** Datei-mtime 18:37:21 matcht Eintrag exakt. Drift-Scan §24b Responsive Policy zeigt Phase-3-Status „in Arbeit" dokumentiert. Kontext: parallele Arbeit an Admin-Vollansicht (`specs/ARK_ADMIN_VOLLANSICHT_SCHEMA_v0_1.md` 18:25 · `INTERACTIONS_v0_1.md` 18:28 · `mockups/admin.html` 18:37 · `mockups/admin-dashboard-templates.html` 18:37). Grep-Check: `/admin` als Route + Tool-Maske-Sidebar-Einträge konsistent; noch keine §4g-Admin-Sektion in FRONTEND_FREEZE (Admin-Vollansicht-Spec-Status: „Erstentwurf — Review ausstehend"). Kein konkreter Drift — Aufnahme in §4g erfolgt nach PO-Review der Admin-Vollansicht.
- **Resolved-In:** Kein Drift in bestehenden Mockups/Specs. Offen: §4g-Admin-Aufnahme als Follow-Up nach Admin-Vollansicht-Review (separater Workflow, nicht Teil dieser Resolution).
- **Digest-Stale:** frontend-freeze-digest.md wurde 18:43 regeneriert (post-edit) → aktuell.

## [2026-04-19 22:59] session-13946034
- **File:** ARK_STAMMDATEN_EXPORT_v1_3.md
- **Tool:** Edit
- **Status:** resolved
- **Sync-Check:** Siehe Zusammenfassung 2026-04-20 (Zeit-Modul PR #2).
- **Resolved-In:** siehe 2026-04-20-Resolution-Block.
- **Digest-Stale:** ja (siehe wiki/meta/digests/STALE.md)

## [2026-04-19 23:00] session-13946034
- **File:** ARK_DATABASE_SCHEMA_v1_3.md
- **Tool:** Edit
- **Status:** resolved
- **Sync-Check:** Siehe Zusammenfassung 2026-04-20 (Zeit-Modul PR #2).
- **Resolved-In:** siehe 2026-04-20-Resolution-Block.
- **Digest-Stale:** ja (siehe wiki/meta/digests/STALE.md)

## [2026-04-19 23:01] session-13946034
- **File:** ARK_BACKEND_ARCHITECTURE_v2_5.md
- **Tool:** Edit
- **Status:** resolved
- **Sync-Check:** Siehe Zusammenfassung 2026-04-20 (Zeit-Modul PR #2).
- **Resolved-In:** siehe 2026-04-20-Resolution-Block.
- **Digest-Stale:** ja (siehe wiki/meta/digests/STALE.md)

## [2026-04-19 23:01] session-13946034
- **File:** ARK_FRONTEND_FREEZE_v1_10.md
- **Tool:** Edit
- **Status:** resolved
- **Sync-Check:** Siehe Zusammenfassung 2026-04-20 (Zeit-Modul PR #2).
- **Resolved-In:** siehe 2026-04-20-Resolution-Block.
- **Digest-Stale:** ja (siehe wiki/meta/digests/STALE.md)

## [2026-04-19 23:37] session-13946034
- **File:** ARK_STAMMDATEN_EXPORT_v1_3.md
- **Tool:** Edit
- **Status:** resolved
- **Sync-Check:** Siehe Zusammenfassung 2026-04-20 (Zeit-Modul PR #2).
- **Resolved-In:** siehe 2026-04-20-Resolution-Block.
- **Digest-Stale:** ja (siehe wiki/meta/digests/STALE.md)

## [2026-04-19 23:45] session-13946034
- **File:** ARK_BACKEND_ARCHITECTURE_v2_5.md
- **Tool:** Edit
- **Status:** resolved
- **Sync-Check:** Siehe Zusammenfassung 2026-04-20 (Zeit-Modul PR #2).
- **Resolved-In:** siehe 2026-04-20-Resolution-Block.
- **Digest-Stale:** ja (siehe wiki/meta/digests/STALE.md)

## [2026-04-19 23:45] session-13946034
- **File:** ARK_BACKEND_ARCHITECTURE_v2_5.md
- **Tool:** Edit
- **Status:** resolved
- **Sync-Check:** Siehe Zusammenfassung 2026-04-20 (Zeit-Modul PR #2).
- **Resolved-In:** siehe 2026-04-20-Resolution-Block.
- **Digest-Stale:** ja (siehe wiki/meta/digests/STALE.md)

## [2026-04-19 23:45] session-13946034
- **File:** ARK_BACKEND_ARCHITECTURE_v2_5.md
- **Tool:** Edit
- **Status:** resolved
- **Sync-Check:** Siehe Zusammenfassung 2026-04-20 (Zeit-Modul PR #2).
- **Resolved-In:** siehe 2026-04-20-Resolution-Block.
- **Digest-Stale:** ja (siehe wiki/meta/digests/STALE.md)

## [2026-04-19 23:46] session-13946034
- **File:** ARK_BACKEND_ARCHITECTURE_v2_5.md
- **Tool:** Edit
- **Status:** resolved
- **Sync-Check:** Siehe Zusammenfassung 2026-04-20 (Zeit-Modul PR #2).
- **Resolved-In:** siehe 2026-04-20-Resolution-Block.
- **Digest-Stale:** ja (siehe wiki/meta/digests/STALE.md)

## [2026-04-19 23:46] session-13946034
- **File:** ARK_BACKEND_ARCHITECTURE_v2_5.md
- **Tool:** Edit
- **Status:** resolved
- **Sync-Check:** Siehe Zusammenfassung 2026-04-20 (Zeit-Modul PR #2).
- **Resolved-In:** siehe 2026-04-20-Resolution-Block.
- **Digest-Stale:** ja (siehe wiki/meta/digests/STALE.md)

## [2026-04-19 23:46] session-13946034
- **File:** ARK_BACKEND_ARCHITECTURE_v2_5.md
- **Tool:** Edit
- **Status:** resolved
- **Sync-Check:** Siehe Zusammenfassung 2026-04-20 (Zeit-Modul PR #2).
- **Resolved-In:** siehe 2026-04-20-Resolution-Block.
- **Digest-Stale:** ja (siehe wiki/meta/digests/STALE.md)

## [2026-04-19 23:46] session-13946034
- **File:** ARK_BACKEND_ARCHITECTURE_v2_5.md
- **Tool:** Edit
- **Status:** resolved
- **Sync-Check:** Siehe Zusammenfassung 2026-04-20 (Zeit-Modul PR #2).
- **Resolved-In:** siehe 2026-04-20-Resolution-Block.
- **Digest-Stale:** ja (siehe wiki/meta/digests/STALE.md)

## [2026-04-19 23:46] session-13946034
- **File:** ARK_BACKEND_ARCHITECTURE_v2_5.md
- **Tool:** Edit
- **Status:** resolved
- **Sync-Check:** Siehe Zusammenfassung 2026-04-20 (Zeit-Modul PR #2).
- **Resolved-In:** siehe 2026-04-20-Resolution-Block.
- **Digest-Stale:** ja (siehe wiki/meta/digests/STALE.md)

## [2026-04-19 23:46] session-13946034
- **File:** ARK_BACKEND_ARCHITECTURE_v2_5.md
- **Tool:** Edit
- **Status:** resolved
- **Sync-Check:** Siehe Zusammenfassung 2026-04-20 (Zeit-Modul PR #2).
- **Resolved-In:** siehe 2026-04-20-Resolution-Block.
- **Digest-Stale:** ja (siehe wiki/meta/digests/STALE.md)

## [2026-04-19 23:46] session-13946034
- **File:** ARK_BACKEND_ARCHITECTURE_v2_5.md
- **Tool:** Edit
- **Status:** resolved
- **Sync-Check:** Siehe Zusammenfassung 2026-04-20 (Zeit-Modul PR #2).
- **Resolved-In:** siehe 2026-04-20-Resolution-Block.
- **Digest-Stale:** ja (siehe wiki/meta/digests/STALE.md)

## [2026-04-19 23:46] session-13946034
- **File:** ARK_BACKEND_ARCHITECTURE_v2_5.md
- **Tool:** Edit
- **Status:** resolved
- **Sync-Check:** Siehe Zusammenfassung 2026-04-20 (Zeit-Modul PR #2).
- **Resolved-In:** siehe 2026-04-20-Resolution-Block.
- **Digest-Stale:** ja (siehe wiki/meta/digests/STALE.md)

## [2026-04-19 23:46] session-13946034
- **File:** ARK_BACKEND_ARCHITECTURE_v2_5.md
- **Tool:** Edit
- **Status:** resolved
- **Sync-Check:** Siehe Zusammenfassung 2026-04-20 (Zeit-Modul PR #2).
- **Resolved-In:** siehe 2026-04-20-Resolution-Block.
- **Digest-Stale:** ja (siehe wiki/meta/digests/STALE.md)

## [2026-04-19 23:46] session-13946034
- **File:** ARK_BACKEND_ARCHITECTURE_v2_5.md
- **Tool:** Edit
- **Status:** resolved
- **Sync-Check:** Siehe Zusammenfassung 2026-04-20 (Zeit-Modul PR #2).
- **Resolved-In:** siehe 2026-04-20-Resolution-Block.
- **Digest-Stale:** ja (siehe wiki/meta/digests/STALE.md)

## [2026-04-20] session-prime-ark | RESOLUTION ✓ (Sammel-Resolution Zeit-Modul Grundlagen-Sync)

Alle 18 Einträge aus Session 13946034 (2026-04-19 22:59–23:46) in Sammel-Pass resolved. Kontext: Hook-Log-Artefakte der iterativen Grundlagen-Edits während Zeit-Modul-Build. Eigentlicher Sammel-Resolution-Block steht bereits oben (2026-04-19 · "Zeit-Modul v0.1 Grundlagen-Sync").

**Scope:** Phase-3 ERP Zeit-Modul v0.1 · komplett (Research → Specs → Mockups · Phase A–D).

**Grundlagen-Edits (resolved via PR #2 / commit d0828ba):**
- `ARK_STAMMDATEN_EXPORT_v1_3.md` → v1.4 (§90 Zeit-Modul-Stammdaten)
- `ARK_DATABASE_SCHEMA_v1_3.md` → v1.4 (15 Tabellen · 4 Views · 9 Enums · btree_gist)
- `ARK_BACKEND_ARCHITECTURE_v2_5.md` → v2.6 (M. Zeit-Modul · 21 Endpoints · 12 Events · 9 Workers · 4 Sagas)
- `ARK_FRONTEND_FREEZE_v1_10.md` → v1.11 (Zeit-Modul UI-Pattern · 7 Screens + 5 Drawer + 2 Modals)

**Resolved-In (PR #2 merged in main):**
- `specs/ARK_ZEIT_SCHEMA_v0_1.md` + `_INTERACTIONS_v0_1.md`
- `wiki/meta/zeit-decisions-2026-04-19.md`
- `mockups/zeit-*.html` (7 Mockups)

**Sync-Kaskade zu Detailmasken:** N/A — Zeit-Modul ist neues Modul, tangiert keine der 9 existierenden Entity-Detailmasken.

**Digest-Stale:** alle 4 Digests regenerieren nach nächstem Commit.

**Hinweis:** Die 18 Einzel-Einträge bleiben als Audit-Trail sichtbar; Status über diese Zusammenfassung auf `resolved` gesetzt.

## [2026-04-24 15:59] session-63ae8c3a
- **File:** ARK_STAMMDATEN_EXPORT_v1_5.md
- **Tool:** Edit
- **Status:** unresolved
- **Sync-Check:** -- pending --
- **Resolved-In:** -- (fill when specs/mockups nachgezogen) --
- **Digest-Stale:** ja (siehe wiki/meta/digests/STALE.md)

## [2026-04-24 16:02] session-63ae8c3a
- **File:** ARK_STAMMDATEN_EXPORT_v1_5.md
- **Tool:** Edit
- **Status:** unresolved
- **Sync-Check:** -- pending --
- **Resolved-In:** -- (fill when specs/mockups nachgezogen) --
- **Digest-Stale:** ja (siehe wiki/meta/digests/STALE.md)

## [2026-04-24 16:02] session-63ae8c3a
- **File:** ARK_DATABASE_SCHEMA_v1_5.md
- **Tool:** Edit
- **Status:** unresolved
- **Sync-Check:** -- pending --
- **Resolved-In:** -- (fill when specs/mockups nachgezogen) --
- **Digest-Stale:** ja (siehe wiki/meta/digests/STALE.md)

## [2026-04-24 16:04] session-63ae8c3a
- **File:** ARK_DATABASE_SCHEMA_v1_5.md
- **Tool:** Edit
- **Status:** unresolved
- **Sync-Check:** -- pending --
- **Resolved-In:** -- (fill when specs/mockups nachgezogen) --
- **Digest-Stale:** ja (siehe wiki/meta/digests/STALE.md)

## [2026-04-24 16:04] session-63ae8c3a
- **File:** ARK_BACKEND_ARCHITECTURE_v2_7.md
- **Tool:** Edit
- **Status:** unresolved
- **Sync-Check:** -- pending --
- **Resolved-In:** -- (fill when specs/mockups nachgezogen) --
- **Digest-Stale:** ja (siehe wiki/meta/digests/STALE.md)

## [2026-04-24 16:06] session-63ae8c3a
- **File:** ARK_BACKEND_ARCHITECTURE_v2_7.md
- **Tool:** Edit
- **Status:** unresolved
- **Sync-Check:** -- pending --
- **Resolved-In:** -- (fill when specs/mockups nachgezogen) --
- **Digest-Stale:** ja (siehe wiki/meta/digests/STALE.md)

## [2026-04-24 16:07] session-63ae8c3a
- **File:** ARK_FRONTEND_FREEZE_v1_12.md
- **Tool:** Edit
- **Status:** unresolved
- **Sync-Check:** -- pending --
- **Resolved-In:** -- (fill when specs/mockups nachgezogen) --
- **Digest-Stale:** ja (siehe wiki/meta/digests/STALE.md)

## [2026-04-24 16:09] session-63ae8c3a
- **File:** ARK_FRONTEND_FREEZE_v1_12.md
- **Tool:** Edit
- **Status:** unresolved
- **Sync-Check:** -- pending --
- **Resolved-In:** -- (fill when specs/mockups nachgezogen) --
- **Digest-Stale:** ja (siehe wiki/meta/digests/STALE.md)

## [2026-04-24 16:09] session-63ae8c3a
- **File:** ARK_GESAMTSYSTEM_UEBERSICHT_v1_4.md
- **Tool:** Edit
- **Status:** unresolved
- **Sync-Check:** -- pending --
- **Resolved-In:** -- (fill when specs/mockups nachgezogen) --
- **Digest-Stale:** ja (siehe wiki/meta/digests/STALE.md)

## [2026-04-24 16:11] session-63ae8c3a
- **File:** ARK_GESAMTSYSTEM_UEBERSICHT_v1_4.md
- **Tool:** Edit
- **Status:** unresolved
- **Sync-Check:** -- pending --
- **Resolved-In:** -- (fill when specs/mockups nachgezogen) --
- **Digest-Stale:** ja (siehe wiki/meta/digests/STALE.md)
