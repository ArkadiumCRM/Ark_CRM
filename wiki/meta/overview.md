---
title: "ARK CRM — Gesamtübersicht"
type: meta
created: 2026-04-08
updated: 2026-04-25
sources: ["ARK_GESAMTSYSTEM_UEBERSICHT_v1_4.md", "ARK_DATABASE_SCHEMA_v1_5.md", "ARK_BACKEND_ARCHITECTURE_v2_7.md", "ARK_FRONTEND_FREEZE_v1_12.md", "ARK_STAMMDATEN_EXPORT_v1_5.md"]
tags: [overview, architecture, crm]
---

# ARK CRM — Gesamtübersicht

## Was ist ARK?

ARK Executive Search (Arkadium AG) ist eine Schweizer Personalberatung spezialisiert auf die **Baubranche**. Das CRM wird von Grund auf als massgeschneidertes System entwickelt — kein Standardprodukt, sondern ein vollständig eigenes System das exakt auf die Arbeitsprozesse von ARK zugeschnitten ist.

**Kernprinzip:** "Nie das CRM verlassen" — der Consultant arbeitet den ganzen Tag ausschliesslich im CRM. Kein separates Outlook, kein Browser für LinkedIn.

## Die fünf Sparten

| Kürzel | Name | Bereich |
|--------|------|---------|
| ING | Civil Engineering | Ingenieurwesen, Umwelt, Geotechnik |
| GT | Building Technology | Gebäudetechnik, Energie |
| ARC | Architecture | Architektur, Innenarchitektur |
| REM | Real Estate Management | Immobilien, Asset Management |
| PUR | Procurement | Einkauf, Supply Chain |

## Technische Architektur

- **Backend:** Node.js / Fastify / TypeScript auf Railway
- **Frontend:** Next.js / React auf Vercel, Dark (Default) + Light Mode (user-umschaltbar)
- **Datenbank:** Supabase PostgreSQL (~204 Tabellen, `ark` Schema)
- **Pattern:** Modularer Monolith mit Event Spine
- **Desktop:** Electron App
- **AI:** Schreibt nie direkt — immer Vorschlag → Mensch bestätigt

Siehe: [[backend-architektur]], [[frontend-architektur]], [[datenbank-schema]]

## Kernmodule

| Modul | Beschreibung | Seite |
|-------|-------------|-------|
| [[kandidat]] | Profil, Briefing, Werdegang, Assessment, Kompetenzen | 10 Tabs |
| [[account]] | Firmen, Kontakte, Standorte, Kultur, Organigramm | 11 Tabs |
| [[job]] | Offene Stellen, Jobbasket, Matching | |
| [[mandat]] | Target, Taskforce, Time — formelle Aufträge | |
| [[prozess]] | Interview-Pipeline: Exposé → Placement | Mischform (Liste + 3-Tab) |
| [[firmengruppe]] | Konzernstrukturen, gruppenweite Schutzfrist | 7 Tabs |
| [[projekt]] | Bauprojekte, 3-Tier Gewerk/Beteiligungen | 6 Tabs (Phase A–I) |
| [[assessment]] | Credits-basierte Diagnostik, 11 Typen | 5 Tabs |
| [[scraper]] | Control-Center, 7 Typen, Review-Queue | 6 Tabs |
| [[history-system]] | 146 Activity Types in 19 Kategorien (§91 v1.4-Patch + §92-§95 E-Learning) | |
| [[event-system]] | Event-Driven Architecture mit Automationen | |
| [[dokumente]] | Upload, OCR, Generator (ARK CV, Exposé, Abstract) | |
| [[reminders]] | Auto-generiert + manuell, Eskalation | |
| [[email-system]] | Email & Kalender `/operations/email-kalender` · MS Graph User-Tokens · CodeTwo-Signatur · 38 Templates · Kalender Tag/Woche/Monat | Single-Page-Maske |
| [[telefonie-3cx]] | Click-to-Call, Transkription, AI-Summary | |
| [[ai-system]] | RAG, Matching, Klassifizierung, Governance | |

## Geschäftsmodelle

1. **Mit Mandat** (Target, Taskforce, Time) — formeller Auftrag
2. **Auf Erfolgsbasis** (Best Effort) — kein Mandat, gestaffelte Honorartabelle

Prozessablauf ist bei beiden identisch. Siehe [[rekrutierungsprozess]].

## Rollen

| DB-Key | Anzeige | Kürzel | Aufgabe |
|--------|---------|--------|---------|
| `Head_of` | Head of Department | HoD | Spartenleitung, Eskalation |
| `Account_Manager` | Account Manager | AM | Kundenbetreuung, Mandatsakquise |
| `Candidate_Manager` | Candidate Manager | CM | Kandidatenbetreuung, Briefings, GO-Prozess |
| `Researcher` | Research Analyst | RA | Longlist, Erstansprache, Kaltakquise |
| `Backoffice` | Backoffice | BO | Administration, Assessment-Management |
| `Assessment_Manager` | Assessment Manager | — | Assessment-Verwaltung |
| `Admin` | Admin | Admin | Systemadministration |
| `ReadOnly` | Read Only | RO | Nur Leserechte |

Eine Person kann mehrere Rollen gleichzeitig haben. Siehe [[namenskonventionen]].

## Phasen-Plan

| Phase | Inhalt | Status |
|-------|--------|--------|
| **Phase 1** | Kern-CRM: Kandidaten, Accounts, Jobs, Mandate, Prozesse, History, Reminders, Dokumente, Dashboard | Launch-Blocker |
| **Phase 1.5** | AI Activity-Types, Transkript-Summaries, Email-System, 3CX, Assessment-Import | Erste 4 Wochen |
| **Phase 2** | RAG, Matching, Dok-Generator, Assessment-Charts, Kanban, Report-Generator | 3-6 Monate |
| **Phase 3** | ERP-Tools (eigenständige Produkte): Zeiterfassung ✓ · Billing ✓ · E-Learning ✓ · HR ✓ · Provisionen ✓ · Performance / Publishing (ausstehend) | In Arbeit |

## Separate Projekte

- **ARK App** — Separate mobile/web App für Kandidaten (eigenes Projekt, nicht Teil dieses CRM-Wikis)
- **Heritage-App** (Vision) — Intergenerationale Potenzial-Diagnostik-Plattform, separates Produkt. Siehe [[vision-ark-app]]

## Assessment-Referenz-Material

Ingested 2026-04-17 als Struktur-Referenz für Assessment-Modul:

- **SCHEELEN-Produktfamilie** (3 Produkte):
  - [[assess-jobprofile]] — 10 Standard-Profile · 26 Kompetenzen · Leading-Model (Leaders/Others/Yourself)
  - [[musterbericht-trimetrix-eq]] — DISC + 12 Driving Forces + 5 EQ-Dimensionen (57 S.)
  - [[musterbericht-relief]] — Stressprävention: 4 Grundbedürfnisse + 5 Antreiber + Coping + Resilienz (24 S.)
- **ASSESS 5.0 Trilogie** (1 Test → 3 Reports, anonymisiert):
  - [[assessment-beispiel-bewertungsergebnisse]] — Matching (38 S.)
  - [[assessment-beispiel-entwicklungsbericht]] — Coaching (13 S.)
  - [[assessment-beispiel-selektionsbericht]] — Interview-Leitfaden (8 S.)

## ERP-Tools (Phase 3, eigenständig)

| Tool | Route | Status | Grundlagen |
|------|-------|--------|------------|
| Zeiterfassung | `/erp/zeit` | Specs v0.1 + 7 Mockups ✓ | DB v1.4 · Backend v2.6 · Freeze v1.11 |
| Billing | `/erp/billing` | Specs v0.1 + 4 Mockups ✓ | DB v1.5 · Backend v2.7 |
| E-Learning | `/erp/elearn` | Specs + 6 Mockups ✓ · Sub A/B/C/D | DB v1.5 (28 Tabellen) · Backend v2.7 (80+ Endpoints) |
| HR | `/erp/hr` | Specs v0.1 + 7 Mockups ✓ | DB v1.5 · Backend v2.7 |
| Provisionen | `/erp/commission` | Specs + 4 Mockups ✓ | |

Zugang via **Topbar-Toggle CRM ↔ ERP** (Frontend-Freeze v1.12 TEIL O). Feature-Flag `feature_hr_tool` locked bis Go-Live.

## Nachträge v1.3.x (2026-04-14 bis 2026-04-16)

- **v1.3.1** — Account-UI-Konsolidierung: Snapshot-Slots 5+6 auf Firmografik, Arkadium-Relation-KPI-Bar in Tab 1, 4-Tab-Kontakt-Drawer, Theme-Preference (Dark/Light umschaltbar)
- **v1.3.2** — Snapshot-Bar-Harmonisierung aller 5 Detailmasken: `.snapshot-bar` uniform, sticky ÜBER Tabbar (`top:0, z-index:50`), dupe-freie Slot-Belegung
- **v1.3.3** — Projekt-Detailmaske komplett ausgebaut (Phase A–I, 6 Tabs, 3-Tier BKP/SIA, Matching, Galerie)
- **TEIL 21** — Spec-Sync-Regel: 5 Grundlagen ↔ 9 Detail-Specs bidirektional synchron halten. Siehe [[spec-sync-regel]]

## Nachträge v1.4 (2026-04-24)

- **v1.4 / v1.5 / v2.7 / v1.12** — E-Learning-Merge: 28 neue Tabellen (elearn_*), 52 Events, 25 Worker, 80+ Endpoints, Activity-Types-Patch v1.4 (+37 Rows #70–#106, 18 Kategorien), E-Learning §92–§95 (+40 Rows #107–#146, 19. Kategorie). Workspace-Struktur CRM↔ERP, Multi-Tenant-RLS, pgvector-RAG, Python-Worker-Service.
- **HR-Modul v0.1** (2026-04-25) — Phase-3 HR komplett: 7 Mockups + Specs Schema/Interactions v0.1

## Open Questions

- ~~Power BI Integration: Views stehen bereit, Dashboards werden manuell in Production erstellt~~ → **Plan v0.1** (`specs/ARK_POWER_BI_INTEGRATION_PLAN_v0_1.md`, 2026-04-30) — 70% via Performance-Modul-Merge spec'd, 30% Greenfield (Workspace, RLS-DAX, Embed, Governance) für Stakeholder-Brainstorm
- ~~Outlook-Ausfallsicherheit: Health-Check Worker alle 5 Min, Fallback auf temporäres Outlook~~ → **Konzept** (`wiki/concepts/outlook-failsafe.md`, 2026-04-30) — Send-Queue-Retry-Policy + Admin-Surface-Mapping

## Related

- [[rekrutierungsprozess]]
- [[datenbank-schema]]
- [[backend-architektur]]
- [[frontend-architektur]]
- [[automationen]]
- [[berechtigungen]]
