---
title: "ARK Kandidatenmaske Interactions v1.3"
type: source
created: 2026-04-08
updated: 2026-04-14
sources: ["ARK_KANDIDATENMASKE_INTERACTIONS_v1_3.md", "ARK_KANDIDATENMASKE_INTERACTIONS_v1_2.md"]
tags: [source, kandidat, interactions, behavior]
---

# ARK Kandidatenmaske Interactions v1.3

**Aktuelle Datei:** `specs/ARK_KANDIDATENMASKE_INTERACTIONS_v1_3.md`
**Vorherige Version:** `specs/alt/ARK_KANDIDATENMASKE_INTERACTIONS_v1_2.md`

## Neu in v1.3 (14.04.2026)

Cross-Entity-Integration mit neuen Detailseiten:
- **Projekt-Autocomplete-Flow** (Tab 2 Briefing): ≥85% Auto / 60-84% Review / <60% "Neues Projekt anlegen"
- **Werdegang Projekt-Drawer** (Tab 3): Inline-Edit für BKP/SIA/Rolle, Auto-Insert in `fact_project_candidate_participations`
- **Assessment-Versionierung-Navigation** (Tab 4): Via `fact_candidate_assessment_version`, Link zur Assessment-Detailseite
- **Schutzfrist-Check im Jobbasket** (Tab 5): Query prüft beide Scopes (account + group), zeigt Info-Badge
- **Prozess-Drawer** (Tab 6): Slide-in-Drawer 540px statt Direkt-Navigation
- **History-Event-Erweiterung** (Tab 7): Schutzfrist-/Assessment-/Referral-/Projekt-Events integriert
- **Reminder-Auto-Typen** (Tab 10): Assessment-Coaching/Debriefing, Schutzfrist-Info-Request-Tracking

## v1.2 (unverändert)

- 11 Global Patterns (Inline-Edit, Tag-CRUD, Drawers, Save Strategy, Navigation Guard, ...)
- Temperatur-Modell: vollautomatisch, 2-Layer
- Profil-Vollständigkeit: gewichtet
- Jobbasket-Stages: reine Status-Anzeige
- Projekt-Datenmodell: 3-Tier BKP/SIA

## Verlinkte Wiki-Seiten

[[kandidat]], [[temperatur-modell]], [[interaction-patterns]], [[projekt-datenmodell]], [[diagnostik-assessment]], [[direkteinstellung-schutzfrist]], [[status-enum-katalog]]
