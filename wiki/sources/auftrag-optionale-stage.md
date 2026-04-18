---
title: "Auftragserteilung Optionale Stage"
type: source
created: 2026-04-12
updated: 2026-04-12
sources: ["General/4_Account Management/Auftragserteilung optionale Stages/Vorlage_Auftragserteilung Optionale Stage_VIII_Marketing-Massnahmen für mehr Sichtbarkeit.docx"]
tags: [source, mandat, optionale-stages, marketing]
---

# Auftragserteilung Optionale Stage

**Datei:** `raw/General/4_Account Management/Auftragserteilung optionale Stages/Vorlage_Auftragserteilung Optionale Stage_VIII_Marketing-Massnahmen für mehr Sichtbarkeit.docx`
**Form:** Kurz-Auftrag (1 Seite), separater Vertrag für **nachträglich bestellte Optionale Stage** zu einem laufenden Mandat

## Aufbau

| Feld | Beispiel |
|------|----------|
| Dazugehöriges Mandat | "Baukostenplaner XYT" |
| Zusätzliche Dienstleistung | "Marketing-Massnahme" (VIII) |
| Ansprechperson Kunde | Name |
| Preis | z.B. CHF 3'000 |

## Kontext

Die Mandatsofferte enthält Optionen VI–X "Preis auf Anfrage". Diese Vorlage operationalisiert das: Kunde bestellt nachträglich Option VIII (oder VI/VII/IX/X) → separater Kurz-Auftrag mit Preis + Signaturen.

Nur eine Vorlage (VIII Marketing) liegt vor — analoge Vorlagen für andere Optionen müssten erstellt werden oder diese wird generisch verwendet.

## CRM-Implikationen

- Neues Datenmodell: `fact_mandate_option` mit FK zu Mandat, Typ-Enum (VI–X), Preis, Status, Signatur-Dokument
- Trigger: Optionale Stage → eigene Rechnung via `Vorlage_Rechnung_Mandat_Optionale Stage.docx`
- UI: Tab "Billing" oder Tab "Übersicht" sollte Optionale-Stages-Section haben

## Related

[[optionale-stages]], [[mandatsofferte-vorlage]], [[mandat]], [[mandat-lifecycle-gaps]]
