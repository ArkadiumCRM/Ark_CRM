---
title: "Rechnungen Best Effort + Diagnostik"
type: source
created: 2026-04-12
updated: 2026-04-12
sources: ["General/1_ Rechnungen & -sheets/Best Effort/*.docx", "General/1_ Rechnungen & -sheets/Diagnostic & Assessment/*.docx"]
tags: [source, rechnung, best-effort, erfolgsbasis, diagnostik, mahnung]
---

# Rechnungen Best Effort + Diagnostik

**Verzeichnis:** `raw/General/1_ Rechnungen & -sheets/Best Effort/` + `/Diagnostic & Assessment/`

## Best Effort Rechnungen

| Template | Verwendung |
|----------|-----------|
| `Vorlage_Rechnung Best Effort.docx` | Standard bei Placement |
| `Vorlage_Rechnung Best Effort mit Rabatt.docx` | Mit Rabatt-Position |
| `Du-Vorlage_Rechnung Best Effort*.docx` | Informelle Kunden-Ansprache |

Honorarbasis: [[erfolgsbasis]]-Staffel (21/23/25/27%) oder pro Prozess überschreibbar.

## Mahnungen Best Effort

In `Mahnungen/`:
- `Vorlage_Mahnung Best Effort.docx` / `_mit Rabatt.docx`
- `Du Vorlage_Mahnung Best Effort*.docx`

## Honorarrechnungen (Beispiele)

`Best Effort/Honorarrechnungen/` — ausgefertigte Rechnungen (z.B. Emch+Berger Gruppe).

## Diagnostik & Assessment Rechnung

`Diagnostic & Assessment/Vorlage_Rechnung_Diagnostics & Assessment.docx` — pauschaler Rechnungstyp. Siehe [[offerte-diagnostik]].

## CRM-Implikationen

- Rabatt-Variante = optionales Feld in Rechnungserstellung
- Du-Varianten = Template-Flag `tonality: 'formal' | 'informal'` pro Account
- Mahnwesen bereits in `fact_audit_log` / Reminders vorgesehen

## Related

[[erfolgsbasis]], [[honorar-berechnung]], [[dokumente]], [[agb-arkadium]]
