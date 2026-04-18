---
name: stammdaten-lint
description: Use BEFORE writing any UI text, mockup label, filter option, dropdown value, chip label, timeline event, or enum-like value for the ARK CRM project. Validates terms against raw/Ark_CRM_v2/ARK_STAMMDATEN_EXPORT_v1_3.md. Trigger when editing mockups/*.html, specs/*.md, or wiki/ content involving enums, stages, mandate types, activity types, EQ dimensions, motivators, Sparten, or employee displays.
---

# Stammdaten-Lint für ARK CRM

Pflicht-Check bevor UI-Text oder Enum-Wert geschrieben wird. Verhindert Freitext-Drift.

## Workflow

1. **Identifiziere den Stammdaten-Typ** im Text/Edit (Stage, Mandat-Typ, Activity, Sparte, etc.)
2. **Lese** `raw/Ark_CRM_v2/ARK_STAMMDATEN_EXPORT_v1_3.md` — gesamter Abschnitt zum Typ
3. **Vergleiche** jeden geplanten Wert 1:1 mit Katalog
4. **Bei Abweichung STOP** — User fragen, nicht erfinden

## Kritische Kataloge (häufig falsch verwendet)

### Prozess-Stages (§13 `dim_process_stages`)
Erlaubt: `Expose · CV Sent · TI · 1st · 2nd · 3rd · Assessment · Offer · Placement`
Falsch: Identified, Briefing, Interview, Angebot, Shortlist

### Mandat-Typen
Erlaubt: `Target · Taskforce · Time`
Falsch: Retainer, Einzelmandat, RPO, Contingency

### Org-Funktion (§10a)
Erlaubt: `vr_board · executive · hr · einkauf · assistenz`
Falsch: Board, Linie, Management, Leitung

### EQ-Dimensionen (§67a)
Erlaubt: `Selbstwahrnehmung · Selbstregulierung · Motivation · Soziale Wahrnehmung · Soziale Regulierung`
Falsch: Stress-Management, Anpassungsfähigkeit (= EQ-i 2.0, andere Methodik)

### Motivatoren (§67b)
Erlaubt: `Theoretisch · Ökonomisch · Ästhetisch · Sozial · Individualistisch · Traditionell` (je 2 Pole)
Falsch: Leistung, Stabilität, Autonomie (Freitext)

### Sparten (§8)
Erlaubt: `ARC · GT · ING · PUR · REM`
Falsch: Hochbau, Tiefbau (= Cluster, andere Ebene)

### Mitarbeiter-Darstellung
Erlaubt: 2-Buchstaben-Kürzel `PW · JV · LR`
Falsch: Volle Namen "Peter Wiederkehr"

### Activity-Types (§14, 64 Einträge, 11 Kategorien)
Kategorien: `Kontaktberührung · Erreicht · Emailverkehr · Messaging · Interviewprozess · Placementprozess · Refresh Kandidatenpflege · Mandatsakquise · Erfolgsbasis · Assessment · System`
**Jede History-/Timeline-Zeile muss aus diesen 64 Einträgen stammen.** Nie Freitext.

## Regel bei Neu-Enum-Bedarf

Neue Enum-Werte dürfen nur **ergänzend** nach Freigabe hinzugefügt werden. Bestehende Einträge nie überschreiben/umbenennen. Freitext-Notizen/Kommentare sind Ausnahme.

## Output-Format bei Violation

```
STAMMDATEN-VIOLATION
Typ: <z.B. Prozess-Stage>
Gefunden: "<eingegebener Wert>"
Katalog (§<ref>): <erlaubte Werte>
Aktion: Mit Katalog-Wert ersetzen oder User-Freigabe einholen
```
