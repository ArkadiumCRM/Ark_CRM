---
title: "ARK Kandidatenmaske Schema v1.3"
type: source
created: 2026-04-08
updated: 2026-04-14
sources: ["ARK_KANDIDATENMASKE_SCHEMA_v1_3.md", "ARK_KANDIDATENMASKE_SCHEMA_v1_2.md"]
tags: [source, kandidat, ui, schema]
---

# ARK Kandidatenmaske Schema v1.3

**Aktuelle Datei:** `specs/ARK_KANDIDATENMASKE_SCHEMA_v1_3.md`
**Vorherige Version:** `specs/alt/ARK_KANDIDATENMASKE_SCHEMA_v1_2.md` (archiviert)

## Neu in v1.3 (14.04.2026)

- **Tab 2 Briefing:** Projekt-Autocomplete mit Fuzzy-Match + Hybrid-Flow
- **Tab 3 Werdegang:** Projekt-Verknüpfung via FK zu `fact_projects`, Inline-Drawer für BKP/SIA/Rolle
- **Tab 4 Assessment:** Versionierung via `fact_candidate_assessment_version`, Link zur Assessment-Detailseite
- **Tab 5 Jobbasket:** Schutzfrist-Awareness-Badge
- **Tab 6 Prozesse:** Slide-in-Drawer 540px (Mischform-Konsistenz)
- **Tab 7 History:** 3 neue Filter-Kategorien (Schutzfrist, Assessment, Referral, Projekt-Events)
- **Tab 8 Dokumente:** Scraper-Source-Flag
- **Tab 10 Reminders:** Assessment- und Schutzfrist-Reminder-Typen
- Sprachstandard `candidate_id`

## v1.2 (unverändert)

Komplettes visuelles Layout, Feld-Inventar und UI-Struktur (10 Tabs, 14 HTML-Mockups). Header Option B, Profil-Vollständigkeit gewichtet, 3-Review-Validierung (8.25 / 8.2 / 7.6).

## Verlinkte Wiki-Seiten

[[kandidat]], [[frontend-architektur]], [[projekt-datenmodell]], [[diagnostik-assessment]], [[direkteinstellung-schutzfrist]], [[status-enum-katalog]]
