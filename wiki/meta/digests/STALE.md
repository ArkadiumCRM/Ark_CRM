# Digest Stale-Log

**Letzter Clean:** 2026-04-25 (Performance-Modul-Sync v1.6/v1.6/v2.8/v1.13/v1.5 komplett regeneriert · alle 5 Digests)

## Regeneriert (alle current) — Stand 2026-04-25

- `stammdaten-digest.md` — v1.6: Performance §97 (11 ENUMs · 33 Metric-Defs · 15 Anomaly-Thresholds · 15 Tile-Types · 5 Report-Templates · 8 PowerBI-Views) + HR-Reviews §98 (7 ENUMs · 7 Tabellen migriert). Sources → v1.6. Regeneriert 2026-04-25.
- `database-schema-digest.md` — v1.6: TEIL Q Performance (14 ark_perf-Tabellen · 7 ark_hr-Tabellen · 10 Live-Views · 8 Materialized Views · RLS · 3 Rollen · Tabellen-Count ~225). Sources → v1.6. Regeneriert 2026-04-25.
- `backend-architecture-digest.md` — v2.8: TEIL R Performance (~50 Endpoints · 12 Worker + 1 HR-Cycle · 10 Performance-Events + 5 HR-Review-Events · 5 Perf-WS + 2 HR-WS · 3 Sagas). Sources → v2.8. Regeneriert 2026-04-25.
- `frontend-freeze-digest.md` — v1.13: TEIL Q Performance (10 Routes /performance/* · Hub-Pattern iframe · 6-Slot-Snapshot-Bar · 8 Drawer · TopoJSON-CDN swiss-maps@4 · 6-Sub-Tab-Admin · RBAC · Theme-Tokens). Sources → v1.13. Regeneriert 2026-04-25.
- `gesamtsystem-digest.md` — v1.5: TEIL 26 Performance (Cross-Modul-Analytics-Hub · 8 Architektur-Entscheidungen Q1-Q8 · Markov-Forecast v0.1 · Closed-Loop-Saga · PowerBI-ETL). Sources → v1.5. Regeneriert 2026-04-25.

## Hinweis

Für volle Regeneration (statt targeted Updates) Agent mit Task: „Regenerate digest X from `Grundlagen MD/ARK_<FILE>_v<VERSION>.md` · verlustfrei alle Enums/Kataloge · lossy Prosa". Targeted Updates sind schneller, aber bei grösseren Grundlagen-Refactors volle Regeneration bevorzugen.

## Stale-History

- [2026-04-25 13:36] `database-schema-digest.md` stale — source `ARK_DATABASE_SCHEMA_v1_5.md` edited (session-7da21068) → **aufgehoben 2026-04-25** (Regen nach Performance-Sync)
- [2026-04-25 13:36] `backend-architecture-digest.md` stale — source `ARK_BACKEND_ARCHITECTURE_v2_7.md` edited (session-7da21068) → **aufgehoben 2026-04-25**
- [2026-04-25 13:37] `stammdaten-digest.md` stale — source `ARK_STAMMDATEN_EXPORT_v1_5.md` edited (session-7da21068) → **aufgehoben 2026-04-25**
- [2026-04-25 13:38] `frontend-freeze-digest.md` stale — source `ARK_FRONTEND_FREEZE_v1_12.md` edited (session-7da21068) → **aufgehoben 2026-04-25**
- [2026-04-25 13:38] `gesamtsystem-digest.md` stale — source `ARK_GESAMTSYSTEM_UEBERSICHT_v1_4.md` edited (session-7da21068) → **aufgehoben 2026-04-25**
- [2026-04-25 21:15] Performance-Patches gemerged (TEIL §97/§98/Q/R/26) → **aufgehoben 2026-04-25** (alle 5 Digests regeneriert nach Commit 6eb5ea5)
