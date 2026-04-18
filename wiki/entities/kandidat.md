---
title: "Kandidat"
type: entity
created: 2026-04-08
updated: 2026-04-08
sources: ["ARK_GESAMTSYSTEM_UEBERSICHT_v1_2.md", "ARK_DATABASE_SCHEMA_v1_2.md", "ARK_KANDIDATENMASKE_SCHEMA_v1_2.md", "ARK_FRONTEND_FREEZE_v1_9.md"]
tags: [entity, kandidat, core]
---

# Kandidat

Die zentrale Entität im CRM. Jeder Kandidat durchläuft einen Lebenszyklus von der Ersterfassung bis zur Platzierung (oder Datenschutz-Anonymisierung).

## Datenbank

**Haupttabelle:** `dim_candidates_profile` (operativ, tenant-isoliert)

**Bridge-Tabellen** (alle historisiert mit `valid_from`/`valid_to`/`is_current`):
- `bridge_candidate_cluster` — Fachliche Cluster-Zuordnung
- `bridge_candidate_functions` — Berufsfunktionen (Rating 1-10, Primary-Flag)
- `bridge_candidate_focus` — Fachliche Skills/Fokus (Rating 1-10, Primary-Flag)
- `bridge_candidate_edv` — Software-Kenntnisse (Grundkenntnisse/Anwender/Experte)
- `bridge_candidate_education` — Ausbildungen
- `bridge_candidate_languages` — Sprachen (CEFR A1-C2 + Muttersprache)
- `bridge_candidate_sector` — Branchen
- `bridge_candidate_sparte` — Sparten (ING/GT/ARC/REM/PUR)

**Verknüpfte Fact-Tabellen:**
- `fact_candidate_briefing` — Unbegrenzt versionierte Briefings
- `fact_candidate_employment` — Werdegang (Arbeit/Ausbildung/Lücke)
- `fact_candidate_projects` — Projekte pro Arbeitsstelle
- `fact_history` — Alle Aktivitäten/Kontakte
- `fact_jobbasket` — Zuordnung zu Jobs/Preleads
- `fact_process_core` — Rekrutierungsprozesse
- `fact_documents` — Dokumente (CV, Diplom, Zeugnis etc.)
- `fact_reminders` — Erinnerungen
- `fact_assessment_*` — Assessment-Ergebnisse (DISC, EQ, Motivatoren etc.)

## Stages (Lebenszyklus)

| Stage | Trigger | Beschreibung |
|-------|---------|-------------|
| **Check** | Automatisch bei Erstellung | Neue Kandidaten, noch nicht qualifiziert |
| **Refresh** | Bei NIC/Dropped/Ghosting **nach CV Expected**; nach 1 Jahr in Datenschutz | War im Austausch, hat nach CV Expected abgesagt |
| **Premarket** | Auto wenn Briefing gespeichert | Briefing vorhanden, noch nicht aktiv vermittelbar |
| **Active Sourcing** | Auto wenn CV + Diplom + Zeugnis + Briefing vorhanden | Vollständiges Dossier, aktiv vermittelbar |
| **Market Now** | Auto wenn Prozess erstellt | In aktivem Rekrutierungsprozess |
| **Inactive** | Auto: Alter >60. Oder manuell | Nicht mehr vermittelbar — wird nie mehr kontaktiert |
| **Blind** | Nur manuell | Potenziell interessant in Zukunft |
| **Datenschutz** | Manuell oder Anfrage | Terminal-Status, löst Anonymisierung aus |

**Datenschutz-Sonderregel:** Nach 1 Jahr automatische Rückkehr zu Refresh via `system_override` — überschreibt den Terminal-Status explizit. Eigene Berechtigung, eigener Audit-Log-Eintrag.

## Wechselmotivation (8 Stufen)

1. Arbeitslos
2. Will/muss wechseln
3. Will/muss wahrscheinlich wechseln
4. Wechselt bei gutem Angebot
5. Wechselmotivation spekulativ
6. Wechselt gerade intern & will abwarten
7. Will absolut nicht wechseln
8. Will nicht mit uns zusammenarbeiten

## Temperatur

- **Hot** — Jetzt angehen (rot)
- **Warm** — Beobachten (amber)
- **Cold** — Nicht priorisiert (blau)

Kombination gibt Priorität: "Wechselt bei gutem Angebot + Hot" = sofort vorstellen.

## Kompetenzen (5 Dimensionen)

| Dimension | Tabelle | Anzahl | Details |
|-----------|---------|--------|---------|
| Cluster/Subcluster | `dim_cluster` | ~15 + 66 | Fachliche Kompetenz-Cluster |
| Functions | `dim_functions` | 190+ | Berufsfunktionen |
| Focus | `dim_focus` | 160+ | Fachliche Skills (ersetzt dim_skills) |
| EDV | `dim_edv` | 120+ | Software-Kenntnisse |
| Sector/Branche | `dim_sector` | variabel | Branchen-Zuordnung |

## Frontend — 10 Tabs

1. **Übersicht/Stammdaten** — Personalien, Kontakt, Flags, Kompetenzen
2. **Briefing** — Versioniert, AI-Auto-Fill aus Transkripten
3. **Werdegang** — Timeline: Arbeit, Ausbildung, Lücken, Projekte
4. **Assessment** — 6 Sub-Tabs (Gesamtüberblick, Scheelen, App, AI-Analyse, Vergleich, Teamrad)
5. **Jobbasket** — Preleads und GO-Flow
6. **Prozesse** — Aktive Rekrutierungsprozesse
7. **History** — Chronologische Timeline aller Aktivitäten
8. **Dokumente** — Upload, Labels, Seitenbearbeitung
9. **Dok.-Generator** — WYSIWYG für ARK CV, Abstract, Exposé
10. **Reminders** — Offene Erinnerungen

## API-Endpunkte

`/api/v1/candidates` — Full CRUD + Soft Delete/Restore
- Stage-Changes, Briefings, Employment, Projects, Functions, Focus
- Assessments, Documents, History, Match Scores
- Merge, Anonymize (GDPR), Export, LinkedIn Import

## Automationen

- Briefing gespeichert → Stage: Premarket + Mandate Research: briefing
- CV + Diplom + Zeugnis + Briefing vorhanden → Stage: Active Sourcing
- Prozess erstellt → Stage: Market Now
- NIC/Dropped → Stage: Refresh + Mandate Research: rejected/dropped
- Cold >6 Monate → Stage: Inactive
- Datenschutz → Anonymisierung; nach 1 Jahr → Refresh (Sonder-Automation)

## Header-Spezialitäten (Mockup)

- **Name + Alter + Wohnort** in H1
- **Kontakt-Meta**: Email / Tel / LinkedIn / aktueller Arbeitgeber
- **Temperatur-Chip** (🔥 Hot / 🟡 Warm / 🔵 Cold)
- **Sourcing-Chip** (Active Sourcing / Passive)
- **Grade-Chip** (A/B/C)
- **Wechselmotivation-Chip** (WM 4/8)
- **Stage-Dropdown** (8 Stages: Expose → Placement)
- **CM/Researcher-Chip** + **Team-Chip**
- **Prozess-Link-Chip** (in Prozess · CFO-Suche Stage V)
- **Schutzfrist-Count-Chip** + **Jobbasket-Count-Chip**
- **Profilvollständigkeits-Progress-Bar** (72 %)
- **Snapshot-Bar sticky** (6 Slots, operativ · dupe-frei zum Header): Ø Match-Score · Im Jobbasket · Aktive Prozesse · Refresh-Due · Placements historisch · Assessments

## Duplikat-Erkennung

View `v_candidate_duplicates` — Fuzzy-Matching auf Name, Email, Telefon, LinkedIn-URL.

## Related

- [[rekrutierungsprozess]] — Der Weg vom Kandidat zum Placement
- [[briefing]] — 9 Sektionen, AI Auto-Fill, Versionierung
- [[assessment]] — Assessment-Typen und Visualisierungen
- [[jobbasket]] — GO-Flow und Versand
- [[prozess]] — Interview-Pipeline
- [[account]] — Verknüpfung Kandidat ↔ Account (Kontakt kann gleichzeitig Kandidat sein)
- [[stammdaten]] — Kompetenzen: Cluster, Functions, Focus, EDV
