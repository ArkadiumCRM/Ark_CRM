---
name: umlaute-lint
description: Use when writing or editing any file in the ARK CRM project (mockups, specs, wiki, code comments, HTML strings, JS strings, Python strings). Enforces CRITICAL rule - immer echte Umlaute (ä ö ü Ä Ö Ü ß UTF-8), niemals ae/oe/ue/ss als Ersatz. Trigger before Edit/Write operations on .md, .html, .js, .py, .json files.
---

# Umlaute-Lint (CRITICAL Rule, 2026-04-15)

**Immer echte Umlaute verwenden.** Niemals `ae` `oe` `ue` `ss` als Ersatz.

## Gültige Zeichen

`ä ö ü Ä Ö Ü ß` — UTF-8 encoded.

## Verboten (Umlaut-Ersatz)

Häufige falsche Ersetzungen (kontext-abhängig — manche Wörter haben legitim `ae/oe/ue`):

| Falsch | Richtig | Häufigkeit |
|--------|---------|-----------|
| `fuer` | `für` | sehr hoch |
| `ueber` | `über` | sehr hoch |
| `koennen` | `können` | hoch |
| `muessen` | `müssen` | hoch |
| `waehren` | `während` | hoch |
| `waehrung` | `Währung` | mittel |
| `groesse` | `Größe` | mittel |
| `naechste` | `nächste` | mittel |
| `laenge` | `Länge` | mittel |
| `kuerzel` | `Kürzel` | mittel |
| `geloescht` | `gelöscht` | mittel |
| `fruehe` | `frühe` | mittel |
| `spaet` | `spät` | mittel |
| `schliessen` | `schließen` | mittel |
| `muss` | `muss` (OK, kein ß nach kurzem Vokal) | – |
| `spass` | `Spaß` | niedrig |
| `strasse` | `Straße` | mittel |
| `gross` | `groß` | mittel |
| `dass` | `dass` (OK nach Rechtschreibreform) | – |

## Legitime Ausnahmen (nicht ersetzen)

Wörter mit echtem `ae/oe/ue`:
- Namen: `Baer`, `Maerki`, `Voegeli`, `Mueller` (wenn so geschrieben)
- Fachbegriffe: `Aerosol`, `Coeur`, `Boeing`
- Anglizismen: `Queue`, `Tuesday`

**Im Zweifel**: User fragen.

## Legitime `ss` (nicht zu `ß` ändern)

Nach kurzem Vokal: `muss`, `dass`, `Fluss`, `Stress`, `Pass`, `kurz`, `Pass`

`ß` nur nach langem Vokal/Diphthong: `Straße`, `Fuß`, `heiß`, `groß`, `Spaß`

(Hinweis: Schweiz verwendet `ss` statt `ß` — bei Swiss-German-Content `ss` immer OK!)

## Workflow

1. Vor Write/Edit: Scan Text auf oben gelistete Fehler-Patterns
2. Bei Match: Mit UTF-8 Umlaut ersetzen
3. Bei Encoding-Problem (Bash-Heredoc, Python-String): **direkt mit Edit/Write-Tool** schreiben, nicht via Bash-Pipe
4. Surrogate-Pair-Hack (`\ud83c\udfd7`) **verboten** — echte Unicode-Zeichen

## Sonderfall Schweiz

ARK ist Schweizer Firma. User schreibt oft Schweizer Hochdeutsch — `ss` statt `ß` ist OK und erwünscht. Nur `ae/oe/ue` sind immer falsch, `ss` bleibt in CH-Texten.
