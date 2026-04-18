---
title: "Arkadium AGB (Feb 2023)"
type: source
created: 2026-04-08
updated: 2026-04-08
sources: ["Arkadium_AGB_FEB_2023.pdf"]
tags: [source, agb, legal, honorar, rueckverguetung]
---

# Arkadium AGB (Februar 2023)

**Datei:** `raw/Ark_CRM_v2/Arkadium_AGB_FEB_2023.pdf` (1 Seite)
**Stand:** 1. Februar 2023, Zürich

## Begriffe

- **Arkadium AG** = Erbringer der Dienstleistung
- **Kunde** = Bezüger der Dienstleistung
- **Kandidaten** = Zu vermittelnde Spezialisten
- **Beschäftigungsverhältnis** = Jede Form von Anstellung (direkt/indirekt, abhängig/unabhängig)

## Geltungsbereich

Gilt ab Vorlage beim Kunden für alle Personalvermittlungen in **Bau, Immobilien und Technik**. Gilt für unbeschränkte Anzahl Kandidaten und uneingeschränkt zwischen Arkadium und Kunde. Gilt auch für Rechtsnachfolger, Konzerngesellschaften und nahestehende Personen.

## Honorarordnung Best Effort

| Jahresgehalt (CHF) | Honorar |
|---------------------|---------|
| < 90'000 | 21% |
| < 110'000 | 23% |
| < 130'000 | 25% |
| ≥ 130'000 | 27% |

**Berechnungsbasis:** Erster Jahreslohn bei 100% Zielerreichung und Vollpensum. Inkl. 13./14. Monat, variable Bestandteile, Fringe Benefits, Dienstwagen. **Exkl. MwSt.**

**Honoraranspruch entsteht bei:**
- Zustandekommen eines Beschäftigungsverhältnisses mit einem vorgestellten Kandidaten
- Unabhängig von abweichenden Rahmenbedingungen (Pensum, Dauer, Ort, Konzerngesellschaft)

## 12-Monats-Schutzfrist

Honoraranspruch besteht auch bei späterer Kontaktaufnahme **innerhalb 12 Monaten** nach Beendigung des Vermittlungsversuchs. Fristbeginn: Datum der Absage oder letzter Kontakt.

**Informationspflicht:** Kunde muss Arkadium informieren vor erneuter Kontaktaufnahme mit Kandidat.

**Fristverlängerung auf 16 Monate:** Automatisch wenn Kunde die relevanten Informationen nicht innerhalb 10 Tagen nach Aufforderung übermittelt.

**Weitere Verlängerung:** Wenn Kandidaten-Informationen länger als 12 Monate beim Kunden gespeichert bleiben.

## Mandate

Mandats-Konditionen werden **separat vereinbart** und sind nicht Teil dieser AGB.

## Zahlungskonditionen

- Fremdkosten: sofort zahlbar
- Honorare: **30 Tage netto** ab Zustandekommen des Arbeitsvertrags

## Kulanz-Rückvergütung

> [!important] CRM-Relevanz
> Diese Staffel ist im CRM als `dim_honorar_settings` abgebildet und wird bei Placement automatisch berechnet.

| Situation | Rückvergütung |
|-----------|--------------|
| Kandidat tritt Stelle nicht an | 100% |
| Austritt Monat 1 | 50% |
| Austritt Monat 2 | 25% |
| Austritt Monat 3 | 10% |
| Nach Probezeit | 0% |

**Keine Rückvergütung** wenn Austritt durch Gründe beim Kunden verursacht.

**Pflicht:** Kunde muss Arkadium VOR Kündigung informieren, spätestens 3 Tage nach Kündigung durch Kandidaten.

## Datenschutz & Löschpflicht

Kunde verpflichtet sich zur **vollständigen Löschung** aller Kandidaten-Unterlagen bis spätestens 12 Monate nach Erhalt bei erfolgloser Vermittlung.

## Weitergabe-Verbot

Weitergabe von Kandidaten-Informationen an Dritte ist **ausdrücklich untersagt**. Bindet auch den Dritten gegenüber Arkadium.

## Gerichtsstand

Zürich (Hauptsitz Arkadium AG).

## CRM-Verknüpfungen

Diese AGB definieren die rechtliche Basis für:
- [[honorar-berechnung]] — Die Best-Effort-Staffel ist 1:1 in `dim_honorar_settings`
- [[account]] — AGB-Tracking (`agb_confirmed_at`, `agb_version`) + Gate-Check bei Versand
- [[prozess]] — Rückvergütung bei Cancellation/Austritt
- [[rekrutierungsprozess]] — 12-Monats-Schutzfrist als Business Rule

## Related

- [[honorar-berechnung]]
- [[account]]
- [[prozess]]
