---
title: "Projekt-Datenmodell"
type: concept
created: 2026-04-08
updated: 2026-04-08
sources: ["ARK_KANDIDATENMASKE_INTERACTIONS_v1_2.md", "ARK_BKP_CODES_STAMMDATEN.md"]
tags: [concept, projekte, bkp, sia, baubranche]
---

# Projekt-Datenmodell

3-Tier-Struktur für Bauprojekte — verbindet Kandidaten mit konkreten Projekterfahrungen inkl. BKP-Codes und SIA-Phasen.

## 3 Ebenen

```
dim_projects (Gesamtprojekt)
  └── fact_project_gewerke (Gewerk/BKP-Code Level)
       └── bridge_candidate_project_gewerk (Kandidaten-Beteiligung)
```

### 1. dim_projects — Gesamtprojekt

Bauherr, Titel, Standort, Budget, Timeline, Team-Grösse.

### 2. fact_project_gewerke — Gewerke

Pro Projekt mehrere Gewerke, verknüpft mit `dim_bkp_codes`:
- BKP-Code (z.B. 211 = Baumeisterarbeiten, 244 = Lüftungsanlagen)
- Volumen pro Gewerk

### 3. bridge_candidate_project_gewerk — Kandidaten-Beteiligung

Pro Kandidat pro Gewerk:
- SIA-Phasen (aus `dim_sia_phases`) in denen der Kandidat beteiligt war
- Rolle im Gewerk
- Volumen/Umfang

## BKP-Codes (Baukostenplan)

425 Einträge, hierarchisch (4 Ebenen). Schweizer Standard SN 506 500.

**10 Hauptgruppen:**

| Code | Bezeichnung | Beispiel |
|------|------------|---------|
| 0 | Grundstück | Vorstudien, Erschliessung |
| 1 | Vorbereitungsarbeiten | Abbruch, Sicherungen, Fundation |
| 2 | Gebäude | Rohbau, Fassade, HLK, Sanitär, Ausbau |
| 3 | Betriebseinrichtungen | Industrie-/Gewerbebauten |
| 4 | Umgebung + Tiefbau | Strassen, Brücken, Tunnel |
| 5 | Baunebenkosten | Bewilligungen, Versicherungen |
| 9 | Ausstattung | Möblierung |

**ARK-spezifische Flags pro Code:**
- `is_blue_collar` — Handwerker/Monteure relevant
- `is_white_collar` — Ingenieure/Planer relevant
- `is_relevant` — Für ARK-Recruiting relevant (filtert reine Kostenpositionen)

## SIA-Phasen

18 Einträge (6 Haupt + 12 Sub), SIA 112:

1. Strategische Planung
2. Vorstudien (Machbarkeit)
3. Projektierung (Vorprojekt, Bauprojekt, Bewilligung)
4. Ausschreibung
5. Realisierung (Ausführungsprojekt, Ausführung, Inbetriebnahme)
6. Bewirtschaftung

**Bridge-Tabelle `bridge_bkp_sia_phases`:** ~1465 Cross-Referenzen. Beispiel: Baumeisterarbeiten (BKP 211) relevant in Phasen 41/51/52; Architekten-Honorare (BKP 291) von Phase 21-53.

## Nutzen für Recruiting

- Kandidaten-Matching: "Suche Kandidat mit Erfahrung in BKP 24 (HLK) in SIA-Phase 5 (Realisierung)"
- Kompetenz-Nachweis: Konkretes Volumen und Phasen-Erfahrung pro Gewerk
- Blue/White Collar Filterung

## Related

- [[kandidat]] — Werdegang → Projekte pro Station
- [[stammdaten]] — BKP und SIA als Master Data
- [[matching]] — Projekt-basiertes Matching
