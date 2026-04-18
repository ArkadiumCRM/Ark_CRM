---
title: "ARK Gesamtsystem-Übersicht v1.3"
type: source
created: 2026-04-08
updated: 2026-04-14
sources: ["ARK_GESAMTSYSTEM_UEBERSICHT_v1_3.md", "ARK_GESAMTSYSTEM_UEBERSICHT_v1_2.md"]
tags: [source, overview, specification]
---

# ARK Gesamtsystem-Übersicht v1.3

**Aktuelle Datei:** `raw/Ark_CRM_v2/ARK_GESAMTSYSTEM_UEBERSICHT_v1_3.md`
**Vorherige Version:** v1.2 (bleibt erhalten)

## v1.3 (14.04.2026)

**Ergänzung** zu v1.2. Highlights:

1. **Mandatsarten umbenannt:** Einzelmandat → Target, RPO → Taskforce (Time unverändert)
2. **Prozess-Architektur Mischform** (Drawer-Primary + schlanke 3-Tab-Detailseite)
3. **Firmengruppen** als vollwertige Entity mit eigener Detailseite, 2-stufig flach
4. **Assessments** als typisierte Credits-basiertes Auftragsmodell mit eigener Detailseite
5. **Scraper** als vollwertiges Control-Center mit Review-Queue
6. **Projekte** als Matching-Basis, 3-Tier-Struktur (Projekt → Gewerk → Beteiligungen)
7. **Schutzfrist-System** konkretisiert (Scope account/group, 3-Fälle-Claim-Logik)
8. **Mandats-Kündigung** mit 80%-Formel + Longlist-Lock
9. **Sprachstandard**: DB-Felder englisch, Status-Enums intentional gemischt, Routen englisch
10. **Detailseiten-Inventar** (9 Entitäten) dokumentiert
11. **Referenz-Update**: DB v1.3, Backend v2.5, Frontend v1.10, Stammdaten v1.3

## v1.2 (unverändert)

Das Kernspezifikationsdokument in 19 Teilen: Unternehmen, Sparten, Rollen, Rekrutierungsprozess, Kandidaten (Profil/Stages/Kompetenzen/Briefing/Werdegang/Assessment), Accounts, Jobs, Mandate, Vakanzen, History, Automationen, Email, Telefonie, Dokumente, Reminders, Scraper, AI, Debuggability, Phasen-Plan, Stammdaten, Technische Architektur.

## Schlüssel-Erkenntnisse

- "Nie das CRM verlassen" — zentrales Designprinzip
- Zwei Geschäftsmodelle: Mandat vs. Erfolgsbasis, gleicher Prozessablauf
- AI schreibt nie direkt — immer Vorschlag → Bestätigung
- Datenschutz als Terminal-Status mit Sonder-Automation für 1-Jahr-Reset
- Event-Driven Architecture mit drei parallelen Systemen (History, Events, Audit)

## Verlinkte Wiki-Seiten

[[overview]], [[kandidat]], [[account]], [[job]], [[mandat]], [[prozess]], [[rekrutierungsprozess]], [[automationen]], [[event-system]], [[stammdaten]], [[status-enum-katalog]], [[detailseiten-inventar]]
