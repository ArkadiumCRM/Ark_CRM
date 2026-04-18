---
description: Run all 4 CRITICAL ARK lint skills (stammdaten, umlaute, db-techdetails, mockup-drift) on a file
argument-hint: <file-path>
---

# ARK-Lint: `$ARGUMENTS`

Fuehre alle 4 CRITICAL-Lint-Skills auf die angegebene Datei aus. Falls kein Argument: frage User welche Datei.

## Arbeitsschritte

1. **Read** `$ARGUMENTS` (ganze Datei, absolute oder relative Pfade OK)
2. **Stammdaten-Lint** (Skill `stammdaten-lint`):
   - Vergleiche gegen `raw/Ark_CRM_v2/ARK_STAMMDATEN_EXPORT_v1_3.md`
   - Pruefe Stages, Mandat-Typen, Org-Funktion, EQ-Dimensionen, Motivatoren, Sparten, Mitarbeiter-Kuerzel, Activity-Types
3. **Umlaute-Lint** (Skill `umlaute-lint`):
   - Scan fuer ae/oe/ue-Substitutionen (fuer, ueber, koennen, muessen, etc.)
   - Schweizer-ss beachten (nicht auto-ersetzen zu ß)
4. **DB-Tech-Details-Lint** (Skill `db-techdetails-lint`):
   - Scan fuer `dim_*`, `fact_*`, `bridge_*`, `_fk`, rohe `_id`-Spalten in User-facing-UI
   - Nur in UI-Kontexten, nicht in Spec-Dokumenten/Code-Kommentaren
5. **Mockup-Drift-Check** (Skill `mockup-drift-check`):
   - Nur wenn `$ARGUMENTS` eine `.html`-Datei unter `mockups/` ist
   - Vergleiche shared Components (Stage-Pipeline, Drawer-Width, Cards) gegen Reference-Files

## Output-Format

```markdown
## Lint-Report: <file>

### Stammdaten (<count>)
- Zeile <n>: "<gefundener Wert>" → <erwarteter Katalog-Wert>
  (§<ref> aus STAMMDATEN_EXPORT)

### Umlaute (<count>)
- Zeile <n>: "<falscher Text>" → "<korrekter Text>"

### DB-Tech-Details (<count>)
- Zeile <n>: "<DB-Token>" in <UI-Kontext> → "<sprechender Begriff>"

### Mockup-Drift (<count>)
- Component: <name>
  Reference: <file>
  Abweichung: <beschreibung>
  Empfehlung: <fix>

### Summary
Gesamt: <total> Violations
Priorität: P0 <x> | P1 <y> | P2 <z>
```

Falls 0 Violations in einer Kategorie: Zeile `- keine` statt leere Sektion.

Falls Datei nicht existiert: Fehlermeldung + Vorschlag "meintest du `<suggestion>`?"

Falls Datei eine Spec (`specs/*.md`) ist: DB-Tech-Details-Lint ueberspringen (Specs duerfen DB-Begriffe enthalten).
