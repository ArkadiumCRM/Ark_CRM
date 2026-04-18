---
title: "RPO-Offerte Vorlage (heute: Taskforce)"
type: source
created: 2026-04-12
updated: 2026-04-13
sources: ["General/4_Account Management/Mandatsofferte/Vorlage_RPO-Offerte.docx"]
tags: [source, rpo, taskforce, mandat, offerte]
---

# RPO-Offerte Vorlage (= Taskforce)

> [!note] Nur umbenannt (2026-04-12)
> **RPO = Taskforce** — gleiches Produkt, neuer Name. Diese Vorlage ist inhaltlich weiterhin gültig, nur der Titel "RPO" entspricht nicht mehr der aktuellen Namensgebung. Ein Umbenennen der Vorlage auf "Taskforce-Offerte" steht an.

**Datei:** `raw/General/4_Account Management/Mandatsofferte/Vorlage_RPO-Offerte.docx`
**Form:** Taskforce (ehemals "RPO — Recruitment Process Outsourcing") — im [[mandat]] Datenmodell unter `mandate_type = 'Taskforce'`

## Unterschiede zu Exklusivmandat

| Aspekt | Exklusivmandat | RPO |
|--------|---------------|-----|
| Stages | 3 getrennte Teilzahlungen | 2 Stages: Research+Selection monatlich + Abschluss pro Platzierung |
| Stage 1 Fälligkeit | Bei Vertragsunterzeichnung | **Jeweils am Ende des Kalendermonats** |
| Longlist-Umfang | 70–100 Idents | **960–1100 Kandidaten** (ca. 1900–2600 Anrufversuche) |
| Fokus | 1 Position | Mehrere Positionen gleichzeitig (Longlist für Bereich) |
| Shortlist | 2–3 Anwärter | max. 40 Kandidaten als Shortlist |

## Stages (RPO)

1. **Suchstrategie, Identifikation + Ansprache, Selektion, Briefing, Dossier** (zusammengefasst)
   - **Monatliche Zahlung** am Kalendermonatsende
2. **Vertragswesen, Abschluss, Off-/Onboarding**
   - **Schlusszahlung pro Platzierung** bei beidseitiger Vertragsunterzeichnung

## Abweichende AGB

Identisch zu [[mandatsofferte-vorlage]]: Exklusivität (3 Wochen), Exit Option (80%-Regel), Pricing, Publikationen. Optionales VI–X identisch.

## CRM-Implikationen

**Entscheidung 2026-04-12/13 (Peter):** RPO ist **umbenannt** in Taskforce — gleiches Produkt, gleiche Offerten-Struktur, neuer Name.

- Kein Datenmodell-Gap — `mandate_type = 'Taskforce'` deckt alles ab
- Vorlage beibehalten, nur **Titel/Bezeichnung "RPO"** im Dokument zu "Taskforce" anpassen
- Alt-Mandate, die noch als "RPO" abgeschlossen wurden, laufen unter demselben `mandate_type = 'Taskforce'`

## Related

[[mandat]], [[mandatsofferte-vorlage]], [[mandat-lifecycle-gaps]], [[honorar-berechnung]]
