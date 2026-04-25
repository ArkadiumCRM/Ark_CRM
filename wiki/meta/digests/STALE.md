# Digest Stale-Log

**Letzter Clean:** 2026-04-24 16:35 (E-Learning-Merge v1.4/v1.5/v2.7/v1.12 komplett regeneriert · alle 5 Digests)

## Regeneriert (alle current)

- `stammdaten-digest.md` — v1.5: Activity-Types-Patch (§91 · 37 neue Rows #70-#106 · 7 neue Kategorien · 15 fact_system_log-Events) + E-Learning Sub A/B/C/D (§92-§95 · 40 Activity-Types #107-#146 · 25 Enums · 52 Event-Types · UI-Label-Vocabulary) + Zeit-Modul v1.4 · 1579 Zeilen (2026-04-24 16:24)
- `database-schema-digest.md` — v1.5: E-Learning-Modul (28 neue Tabellen · pgvector · ALTER dim_user +2 · ALTER dim_elearn_certificate +4 · 30+ Indizes inkl. IVFFLAT · 20+ CHECK-Constraints · RLS-Policies · Multi-Tenant) · Tabellen-Count ~204 · 726 Zeilen (2026-04-24 16:26)
- `backend-architecture-digest.md` — v2.7: E-Learning TEIL N (52 Events · 25 Worker · 80+ Endpoints · Gate-Middleware `@gate_feature` · Feature-Catalog · Cache-Layer · Python-Worker-Service · Cross-Sub-Integration A↔C/D · B→A · C→D) + Zeit-Modul v2.6 · 1822 Zeilen (2026-04-24 16:29)
- `frontend-freeze-digest.md` — v1.12: E-Learning TEIL O (Topbar-Toggle CRM↔ERP · ERP-Sidebar mit 4 Sub-Blöcken · 25+ Page-Templates `mockups/erp/elearn/*` · Markdown-Renderer · 6 Quiz-Components · Freitext/Review/Newsletter-Drawer · Gate-Page-Globals · HTTP-Interceptor 403 GATE_BLOCKED · 8 Shortcut-Tabellen · Sparte-Chip-Farben) · 790 Zeilen (2026-04-24 16:31)
- `gesamtsystem-digest.md` — v1.4: E-Learning TEIL 24 (Modul-Landkarte Sub A/B/C/D · Workspace-Struktur CRM↔ERP · Multi-Tenant-Pattern · 5 Inter-Sub-Datenflüsse · Externe Integrationen 8 Einträge · Compliance-Formel · Cert-Lifecycle · Sub-Interop-Matrix · Statistik ~204 Tabellen/52 Events/25 Worker/80+ Endpoints/25+ Pages/25 Enums/40 Activity-Types/19 Kategorien) · 522 Zeilen (2026-04-24 16:29)

## Hinweis

Für volle Regeneration (statt targeted Updates) Agent mit Task: „Regenerate digest X from `Grundlagen MD/ARK_<FILE>_v<VERSION>.md` · verlustfrei alle Enums/Kataloge · lossy Prosa". Targeted Updates sind schneller, aber bei grösseren Grundlagen-Refactors volle Regeneration bevorzugen.
- [2026-04-25 2026-04-25 13:36] `database-schema-digest.md` stale -- source `ARK_DATABASE_SCHEMA_v1_5.md` edited (session-7da21068)
- [2026-04-25 2026-04-25 13:36] `backend-architecture-digest.md` stale -- source `ARK_BACKEND_ARCHITECTURE_v2_7.md` edited (session-7da21068)
- [2026-04-25 2026-04-25 13:37] `stammdaten-digest.md` stale -- source `ARK_STAMMDATEN_EXPORT_v1_5.md` edited (session-7da21068)
- [2026-04-25 2026-04-25 13:38] `frontend-freeze-digest.md` stale -- source `ARK_FRONTEND_FREEZE_v1_12.md` edited (session-7da21068)
- [2026-04-25 2026-04-25 13:38] `gesamtsystem-digest.md` stale -- source `ARK_GESAMTSYSTEM_UEBERSICHT_v1_4.md` edited (session-7da21068)

## [2026-04-25 21:15] Performance-Patches gemerged — Digest-Regen nötig

- Performance-Modul Patches in alle 5 Grundlagen gemerged (TEIL §97, §98, Q, R, 26)
- Grundlagen versions: v1.6 / v1.6 / v2.8 / v1.13 / v1.5 (Stammdaten/DB/Backend/Frontend/Gesamtsystem)
- HR-Tool: v0.1 → v0.2 (Performance-Reviews-Migration)
- Alle 5 Digests stale → vollständige Regeneration empfohlen (nicht targeted Update — Performance-Modul ist grosser Block, ~225 neue Tabellen total / 33 Metriken / 12 Worker / 50 Endpoints)
- Source-Files (neue Pfade nach git mv):
  - `Grundlagen MD/ARK_STAMMDATEN_EXPORT_v1_6.md` (~3500 Zeilen)
  - `Grundlagen MD/ARK_DATABASE_SCHEMA_v1_6.md` (~3300 Zeilen)
  - `Grundlagen MD/ARK_BACKEND_ARCHITECTURE_v2_8.md` (~4600 Zeilen)
  - `Grundlagen MD/ARK_FRONTEND_FREEZE_v1_13.md` (~4700 Zeilen)
  - `Grundlagen MD/ARK_GESAMTSYSTEM_UEBERSICHT_v1_5.md` (~1200 Zeilen)
