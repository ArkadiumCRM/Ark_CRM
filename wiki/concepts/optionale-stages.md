---
title: "Optionale Stages (Mandats-Zusatzleistungen)"
type: concept
created: 2026-04-12
updated: 2026-04-12
sources: ["General/4_Account Management/Mandatsofferte/Vorlage_Mandatsofferte.docx", "General/4_Account Management/Auftragserteilung optionale Stages/"]
tags: [concept, mandat, optionale-stages, zusatzleistungen, crm-gap]
---

# Optionale Stages

In der [[mandatsofferte-vorlage]] als Abschnitt **"Optionales VI–X"** enthalten — nachträglich buchbare Zusatzleistungen zu einem aktiven Mandat. Siehe [[auftrag-optionale-stage]].

## Die 5 Optionen

| # | Name | Beschreibung | Preis |
|---|------|-------------|-------|
| **VI** | Grössere Auswahl durch mehr Idents | Zusätzliche Idents über Mandats-Scope; Weiterverwendung für spätere Positionen zum Best-Effort-Preis | Case-by-case |
| **VII** | Grössere Auswahl durch mehr Dossiers | Zusätzliche Dossiers über Shortlist-Limit (ohne Erweiterung der Stage-1-Idents) | Case-by-case |
| **VIII** | Marketing-Massnahmen für mehr Sichtbarkeit | Premium-Plattformen (jobs.ch, alpha.ch, Fachzeitungen), Fachblog, Social Media (LinkedIn) | Case-by-case (Beispiel: CHF 3'000) |
| **IX** | Fundiertes Assessment | DISG + Assessment Center via externe Partner (SCHEELEN®) | Case-by-case |
| **X** | Fakultative Garantiefrist | +1 / +2 / +3 Monate (max. 6 Monate total, AGB-Standard ist 3) | Case-by-case |

**Preislogik (geklärt 2026-04-13):** Alle Optionen VI–X werden **individuell pro Fall** kalkuliert. Keine festen Preislisten, keine Formel — AM/Admin entscheiden pro Anfrage. Im CRM als freies Preisfeld, nicht als Berechnung.

## Aktivierungs-Flow

1. Kunde zeigt Interesse während laufendem Mandat
2. AM erstellt **Auftragserteilung Optionale Stage** (Kurz-Vertrag, 1 Seite, siehe [[auftrag-optionale-stage]])
3. Kunde unterzeichnet → Option ist gebucht
4. Rechnung via `Vorlage_Rechnung_Mandat_Optionale Stage.docx` (siehe [[rechnungen-mandat]])
5. Leistung wird erbracht + gegebenenfalls im Mandat-Scope aufgenommen (z.B. Ident-Liste erweitert)

## CRM-Datenmodell (Soll)

```sql
fact_mandate_option (
  id,
  mandat_id,
  option_type: 'VI_more_idents' | 'VII_more_dossiers' | 'VIII_marketing' | 'IX_assessment' | 'X_garantie_extension',
  price_chf,
  extension_value,          -- z.B. Anzahl extra Idents, extra Monate Garantie
  status: 'offered' | 'accepted' | 'in_progress' | 'delivered' | 'invoiced',
  ordered_at,
  signed_document_id,
  invoice_id
)
```

## Auswirkungen auf andere Felder

- **Option VI/VII:** erweitert `target_idents` / `target_dossiers` auf `fact_mandate`
- **Option IX:** erzeugt [[assessment]]-Eintrag verknüpft mit Kandidat
- **Option X:** verlängert `garantie_months` auf 4/5/6

## UI-Implikationen

- In Mandat-Tab "Übersicht" oder "Billing": Section "Optionale Stages"
- Vor Mandats-Abschluss: Check "gibt es offene Optionen, die noch abzurechnen sind?"

## Aktuell im CRM (Gap)

- [[mandat]]-Entity hat "Zusatzleistungen (Target)" erwähnt (Ident-/Dossier-Zusatzpreis) — aber **nicht** als strukturiertes Option-Modell
- **Templates fehlen** für Options VI, VII, IX, X (nur VIII Marketing als Vorlage vorhanden)

## Related

[[mandat]], [[mandatsofferte-vorlage]], [[auftrag-optionale-stage]], [[rechnungen-mandat]], [[assessment]], [[diagnostik-assessment]], [[mandat-lifecycle-gaps]]
