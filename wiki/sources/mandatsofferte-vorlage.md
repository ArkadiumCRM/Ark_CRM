---
title: "Mandatsofferte Vorlage (Exklusivmandat)"
type: source
created: 2026-04-12
updated: 2026-04-12
sources: ["General/4_Account Management/Mandatsofferte/Vorlage_Mandatsofferte.docx", "General/4_Account Management/Mandatsofferte/Mandatsofferte_Beispiel.docx"]
tags: [source, mandat, offerte, exklusivmandat, exit-option, garantie]
---

# Mandatsofferte Vorlage (Exklusivmandat)

**Datei:** `raw/General/4_Account Management/Mandatsofferte/Vorlage_Mandatsofferte.docx` (+ `_Beispiel.docx/.pdf`)
**Typ:** 4-seitige Vorlage für Exklusiv-Mandatsauftrag

## Struktur

- **Seite 1:** Kopfdaten (Position, Gehaltsrahmen TC, Bereich, Form = Exklusivmandat)
- **Seite 2:** 3 Stages (Phase + Beschreibung + Preis + Fälligkeit)
- **Seite 3:** Abweichende AGB-Bestimmungen I–V
- **Seite 4:** Optionales VI–X + Signaturen

## 3 Stages (Zahlungsplan)

| # | Phase | Fälligkeit |
|---|-------|-----------|
| 1 | Suchstrategie, Identifikation, Pooling | Bei Vertragsunterzeichnung (Anzahlung) |
| 2 | Ansprache, Selektion, Briefing, Dossier | Bei 2 vorgelegten Kandidatendossiers |
| 3 | Vertragswesen, Abschluss, Off-/Onboarding | Bei beidseitiger Vertragsunterzeichnung (Platzierung) |

Stage-Inhalte detailliert: 70–100 Idents, ~260 Anrufversuche, Shortlist 2–3 Anwärter, Referenzen, Vertragsbegleitung, Onboarding.

## Abweichende AGB (kritisch für CRM)

- **I. Exklusivität:** 3 Wochen ab Versand exklusive Kandidaten-Vorstellung; andere Dienstleister werden an Arkadium rerouted
- **II. Exit Option:** siehe [[mandat-kuendigung]] — 80%-Regel für beide Seiten
- **III. Pricing:** Pauschalbetrag abweichend von AGB
- **IV. AGB:** Restliche AGB-Bestimmungen gelten subsidiär
- **V. Publikationen:** Arkadium als Kontakt, Bewerbungen weiterleiten, verdeckt für Führungskräfte

## Optionales (VI–X)

Siehe [[optionale-stages]]. VI Mehr Idents · VII Mehr Dossiers · VIII Marketing-Massnahmen · IX Assessment · X Fakultative Garantiefrist (bis 6 Monate).

## CRM-Implikationen

- Exit-Option-Klausel muss bei Mandatserstellung mitgegeben werden (Template-Text in `dim_dokument_templates`)
- Exklusivitätsfrist 3 Wochen = automatische Deadline im Mandat
- Optionale Stages als nachträglich aktivierbare Zusatzleistungen (`fact_mandate_option`?)

## Related

[[mandat]], [[mandat-kuendigung]], [[optionale-stages]], [[agb-arkadium]], [[honorar-berechnung]]
