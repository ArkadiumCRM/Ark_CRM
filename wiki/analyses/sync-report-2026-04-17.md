---
title: "Spec-Mockup-Sync-Report · 2026-04-17"
type: analysis
created: 2026-04-17
updated: 2026-04-17
sources: ["grundlagen-changelog.md", "lint-violations.md", "spec-sync-regel.md", "STALE.md", "specs/ARK_*", "mockups/*"]
tags: [sync, drift, analysis, admin-vollansicht]
---

# Spec-Mockup-Sync-Report — 17.04.2026

Durchgeführt nach Abschluss Admin-Vollansicht-Mockup + Specs v0.1 (session-9c15c2db).

## Executive Summary

- 🔴 **2 Digests stale** · frontend-freeze + gesamtsystem (seit 18:03/18:04) — unregeneriert seit Admin-Specs
- 🔴 **9 unresolved Changelog-Einträge** · 5 aus 14:08–14:11 + 4 aus 16:16–16:20 (Reminders-Arbeit, teilweise resolved in 16:32)
- ⚠ **Admin-Vollansicht führt neue Artefakte ein** · 4 Tabellen (`dim_retention_change_proposals`, `fact_retention_change_approvals`, `fact_template_versions`, `dim_dsg_requests`) · 12+ neue Events · 3 neue Sagas · noch nicht in Grundlagen
- ⚠ **Rollen-Semantik-Korrektur** · `head_of_department` hat keinen Admin-Zugriff → muss in RBAC-Matrix + FRONTEND_FREEZE Routing-Sektion
- 🟢 **Lint-Stand admin.html clean** · letzter Wrap-Fix bei 17:58. Scraper.html dauerhaft 5 Violations (siehe §5)

---

## Unresolved Changelog-Einträge (9)

| # | Datum | Grundlage | Sync-Target | Alter | Status |
|---|-------|-----------|-------------|-------|--------|
| 1 | 17.04. 14:08 | ARK_STAMMDATEN_EXPORT_v1_3 | 9 Detailmasken-Specs + Mockups Dropdowns | ~4h | 🔴 unresolved |
| 2 | 17.04. 14:08 | ARK_DATABASE_SCHEMA_v1_3 | Entity-Schema-Specs | ~4h | 🔴 unresolved |
| 3 | 17.04. 14:09 | ARK_BACKEND_ARCHITECTURE_v2_5 | Interactions-Specs + Drawer-Previews | ~4h | 🔴 unresolved |
| 4 | 17.04. 14:10 | ARK_FRONTEND_FREEZE_v1_10 | alle Mockups | ~4h | 🔴 unresolved |
| 5 | 17.04. 14:11 | ARK_GESAMTSYSTEM_UEBERSICHT_v1_3 | wiki/index + overview | ~4h | 🔴 unresolved |
| 6 | 17.04. 16:16 | ARK_DATABASE_SCHEMA_v1_3 | (später resolved 16:32 Reminders) | ~2h | ⚠ teilweise |
| 7 | 17.04. 16:17 | ARK_BACKEND_ARCHITECTURE_v2_5 | Reminders-Spec | ~2h | 🟢 resolved |
| 8 | 17.04. 16:18 | ARK_DATABASE_SCHEMA_v1_3 | Reminders-Spec | ~2h | 🟢 resolved |
| 9 | 17.04. 16:19 | ARK_FRONTEND_FREEZE_v1_10 | Mockups Reminders | ~2h | 🟢 resolved |

**Neu hinzu (durch heutige Arbeit, noch nicht im Changelog flagged):** Admin-Vollansicht-Specs wurden gemäß `feedback_mockup_first_workflow.md` nachgelagert erstellt — Grundlagen selbst unverändert, aber **Sync-Schulden neu** (siehe §3).

---

## Stale Digests (2)

Aus `wiki/meta/digests/STALE.md` ab 18:03:

| Digest | Source-Grundlage | Edited | Grund |
|--------|------------------|--------|-------|
| 🔴 frontend-freeze-digest.md | ARK_FRONTEND_FREEZE_v1_10.md | 17.04. 18:03 | session-3131f2f7 Reminders-Mobile (v1.3.6) |
| 🔴 gesamtsystem-digest.md | ARK_GESAMTSYSTEM_UEBERSICHT_v1_3.md | 17.04. 18:04 | session-3131f2f7 Changelog-Block |

**Vorherige Regeneration:** 16:35 (Reminders v1.3.5 — backend + db + frontend + gesamtsystem Digests neu).

**Empfohlen:** Targeted-Update (beide Digests) vor nächster Session, sonst stale-Kaskade.

---

## Spec ↔ Grundlagen Drift

### 3.1 Bestehende Detailmasken-Specs — kein neuer Drift durch heutige Arbeit

Die 9 Entity-Specs + 3 Tool-Specs wurden heute nicht editiert. Drift = gleicher Stand wie 16:32 (Reminders-Resolution).

### 3.2 🆕 Admin-Vollansicht-Specs (v0.1 · heute erstellt) · 10 Abweichungen

Neue Artefakte nur in Specs, nicht in Grundlagen:

| # | Typ | Element | Fehlt in Grundlage |
|---|-----|---------|-------------------|
| 1 | Tabelle | `dim_retention_change_proposals` | DATABASE_SCHEMA §retention |
| 2 | Tabelle | `fact_retention_change_approvals` | DATABASE_SCHEMA §retention |
| 3 | Tabelle | `fact_template_versions` | DATABASE_SCHEMA §templates |
| 4 | Tabelle | `dim_dsg_requests` | DATABASE_SCHEMA §audit |
| 5 | Settings-Key-Struktur | `fee_staffel_erfolgsbasis` (matrix statt scalar) | DATABASE_SCHEMA §H + STAMMDATEN |
| 6 | Settings-Key-Struktur | `refund_staffel_erfolgsbasis` (4 Blöcke statt 3-csv) | DATABASE_SCHEMA §H |
| 7 | Event | `retention_policy.changed` | BACKEND_ARCH §A |
| 8 | Event | `legal_hold.set` / `.release` | BACKEND_ARCH §A |
| 9 | Saga | `candidate_data_erasure` (DSG Art. 25) | BACKEND_ARCH §Sagas |
| 10 | Saga | `retention_enforce` + `codetwo_sync` | BACKEND_ARCH §Sagas + §Worker |

### 3.3 RBAC-Semantik-Änderung ⚠

**Design-Entscheidung 2026-04-17:** `head_of_department` → **kein Admin-Zugriff** (nur Rolle `admin`).

Zu syncen:
- `wiki/meta/rbac-matrix.md` — Zeile für `/admin`-Route updaten
- `ARK_FRONTEND_FREEZE_v1_10.md §Routing` — Admin-Route-Permissions
- `ARK_BACKEND_ARCHITECTURE_v2_5.md §RBAC` — API-Endpoint-Gates

---

## Mockup Drift (gering)

Scan auf Shared-Components gegen `mockup-baseline.md`:

| Check | Befund |
|-------|--------|
| Drawer-Width | admin.html nutzt konsistent `.drawer-wide` (760px für Builder) · Standard 540px via editorial.css `--drawer-width` · ✅ |
| Stage-Pipeline 9-Dots | admin.html verwendet keine Stage-Pipeline (nicht-prozess-lastig) · ✅ n/a |
| Tabbar sticky top:0 | admin.html `.tabbar` sticky implementiert · ✅ |
| KPI-Strip 6 cols | admin.html `grid-template-columns:repeat(6,1fr)` · ✅ |
| Snapshot-Bar | admin.html hat keine (korrekt, kein Entity) · ✅ n/a |
| Sidebar Admin-Entry | crm.html · Icon 🔧 · Badge `red 3` · ✅ |

**Drawer-Width-Ausnahme:** Admin-Builder-Drawer (Rule-Builder, Fee-Staffel) nutzen `.drawer-wide` (760px) — **bewusst**, da Matrix/Multi-Step. Konform mit Drawer-Default-Regel (Drawer ≠ Modal).

**Eine Drift-Meldung aus älterem Scan (`scraper.html`):** 5 Violations persistent — siehe §5.

---

## Lint-Violations letzte 24 h (nach Datei)

Aus `wiki/meta/lint-violations.md` (letzte 120 Zeilen):

| Datei | Violations | Hauptregeln | Status |
|-------|------------|-------------|--------|
| 🟢 admin.html | 0 (von 3 → alle wrapped) | SNAKE-CASE admin-skip markers | ✅ clean 17:58 |
| 🟢 crm.html | 0 | — | ✅ clean |
| 🔴 scraper.html | 5× persistent | UMLAUT (1) · SNAKE-CASE (4) | ⚠ unresolved seit 18:00 |
| 🟡 admin-dashboard-templates.html | 2 | SNAKE-CASE | ⚠ 18:37 neu |

**scraper.html Befund (Zeilen 1143/1606/1671/1737/2451):**
- `ueber-uns` → `über-uns` (UMLAUT)
- `finding_accepted` · `job_created_from_scraper` · `protection_violation_detected` → History-Events in Mockup-Texten (benötigen skip-marker oder deutsche Labels)
- Zeile 2451: JS-String mit Enum-Placeholder `${k.replace(/_/g,' ')}` → code-Template, skip oder deutsches-Mapping

---

## Empfehlungen (priorisiert)

| # | Aktion | Priorität | Aufwand |
|---|--------|-----------|---------|
| 1 | **Admin-Vollansicht-Artefakte in Grundlagen** · Patch `ARK_DATABASE_SCHEMA_PATCH_v1_3_to_v1_4.md` erweitern um 4 neue Tabellen + Settings-Key-Strukturen | 🔴 P0 | 1h |
| 2 | **Event/Saga-Katalog ergänzen** · Patch `ARK_BACKEND_ARCHITECTURE_PATCH_v2_5_to_v2_6.md` erweitern um 12 Events + 3 Sagas | 🔴 P0 | 1h |
| 3 | **scraper.html Lint-Fix** · skip-markers setzen oder deutsche Labels (Scraper-History-Events dim_*-Skip analog admin.html) | 🔴 P0 | 20 min |
| 4 | **RBAC-Matrix updaten** · `head_of_department` ohne Admin-Zugriff in `wiki/meta/rbac-matrix.md` + FRONTEND_FREEZE §Routing | 🟡 P1 | 15 min |
| 5 | **Digest-Regeneration** · frontend-freeze + gesamtsystem (targeted update, ~5 min jeweils) | 🟡 P1 | 10 min |
| 6 | **Changelog-Einträge 1-5 resolven** · `/prime-ark` durchlaufen, unresolved→resolved markieren nach Specs-Sync | 🟡 P1 | 30 min |
| 7 | **admin-dashboard-templates.html** prüfen · 2 neue SNAKE-CASE Violations vom 18:37 | 🟡 P1 | 10 min |
| 8 | **Spec-Sync-Regel um Admin erweitern** · `wiki/meta/spec-sync-regel.md` um 10. Spec-Typ (Admin-Vollansicht) ergänzen | 🟢 P2 | 15 min |

---

## Anhang · Coverage-Matrix Admin-Specs ↔ Grundlagen

| Artefakt in Admin-Spec | STAMMDATEN | DB-SCHEMA | BACKEND | FRONTEND | GESAMTSYS |
|-----------------------|:----------:|:---------:|:-------:|:--------:|:---------:|
| Fee-Staffel-Matrix | ⚠ Struktur-Change | ⚠ neu | — | — | ⚠ Entscheidung |
| Refund-Staffel 4-Blöcke | ⚠ Struktur-Change | ⚠ neu | — | — | ⚠ Entscheidung |
| `dim_retention_change_proposals` | — | ⚠ neu | — | — | — |
| `fact_retention_change_approvals` | — | ⚠ neu | — | — | — |
| `fact_template_versions` | — | ⚠ neu | — | — | — |
| `dim_dsg_requests` | — | ⚠ neu | — | — | — |
| Events `retention_policy.*` | — | — | ⚠ neu | — | — |
| Events `legal_hold.*` | — | — | ⚠ neu | — | — |
| Saga `candidate_data_erasure` | — | — | ⚠ neu | — | — |
| Saga `retention_enforce` | — | — | ⚠ neu | — | — |
| Saga `codetwo_sync` | — | — | ⚠ neu | — | — |
| Rolle `head_of_department` kein Admin | ⚠ Regel | — | ⚠ RBAC-Gate | ⚠ Routing | ⚠ Changelog |
| Route `/admin/:tab/:subtab` | — | — | — | ⚠ neu | — |
| Admin-Only Sidebar-Entry 🔧 | — | — | — | ✅ FRONTEND_FREEZE-sync erforderlich | — |

**Legende:** ⚠ = Sync fehlt · ✅ = erledigt · — = n/a

---

## Related

- [[spec-sync-regel]]
- [[grundlagen-changelog]]
- [[lint-violations]]
- [[audit-final-2026-04-14]]
