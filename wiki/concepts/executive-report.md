---
title: "Executive Report"
type: concept
created: 2026-04-17
updated: 2026-04-17
sources: ["ARK_DOK_GENERATOR_SCHEMA_v0_1.md §1.4", "raw/Assessments/Reporting_Curdin Cathomen.pdf", "raw/Assessments/Reporting_Michael Vidal.pdf", "raw/Assessments/Selektionsbericht_Sonja_Bee_Spiess.pdf"]
tags: [assessment, executive-report, diagnostik, scheelen]
---

# Executive Report

Arkadium-eigene Zusammenfassung der Assessment-Ergebnisse mit strategischer Bewertung und Placement-Empfehlung. **Ergänzt** — ersetzt nicht — die SCHEELEN-Detail-Reports pro Assessment-Run.

## Zweck

SCHEELEN liefert pro Assessment-Typ (MDI, Relief, EQ, ASSESS 5.0) einen umfangreichen Detail-Report (~100 Seiten pro Run). Diese Reports sind:
- Psychometrisch fundiert
- Aber unstrukturiert im Arkadium-Kontext (keine Kandidaten-Historie, keine Placement-Empfehlung, keine Red Flags aus Mandats-Sicht)

Der **Executive Report** ist eine 2-3-seitige Arkadium-Interpretation:
- Zusammenfassung SCHEELEN-Ergebnisse in Plain Language
- Eigene Arkadium-Bewertung (manuell von AM/CM ausgefüllt)
- Integration mit [[mandat]]-Kontext und [[kandidat]]-Bewertung (Grade A/B/C)
- Konkrete Empfehlung: Proceed to Offer / Reject / Weitere Evaluation

## Template-Integration

**Template-Key:** `executive_report`
**Kategorie:** `assessment`
**Target-Entity:** `assessment_run` + `candidate` (bezieht beide via FK-Chain)
**Generiert via:** [[dok-generator]] `/operations/dok-generator?template=executive_report&entity=assessment_run:uuid`

## Struktur (9 Sektionen)

Pro Sektion: Auto-Pull aus DB (`entity`) oder manuell vom CM/AM ausgefüllt (`manuell`) oder System-generiert (`auto`).

| # | Sektion | Source | Inhalt |
|---|---------|--------|--------|
| 1 | Header Kandidat | entity | Name, aktuelle Funktion, Arbeitgeber, Assessment-Order-Referenz |
| 2 | Zusammenfassung | manuell | 3-5 Zeilen Gesamteindruck |
| 3 | Assessment-Ergebnisse | entity | Tabelle: Typ · Durchgeführt · Kernaussage (aus Detail-Report-Extraktion) |
| 4 | Arkadium-Bewertung | manuell | Empfehlung (Proceed to Offer / Reject / Weitere Evaluation) |
| 5 | Pro-Argumente | manuell | Bullet-Liste: was spricht für diesen Kandidaten |
| 6 | Red Flags | manuell | Bullet-Liste: was spricht dagegen / Entwicklungsfelder |
| 7 | Entwicklungsfelder | manuell | Coaching-Empfehlungen erstes Halbjahr |
| 8 | Referenzen | entity | Zusammenfassung eingeholter Referenzauskünfte |
| 9 | Disclaimer | auto | Hinweis dass dies Arkadium-Interpretation ist, SCHEELEN-Detail-Reports als Anhang |

## Datenquellen (Auto-Pull)

- **Kandidat**: aus `dim_candidates_profile` (Vorname/Nachname/Funktion/Arbeitgeber) + `fact_candidate_briefing.kurzprofil_text`
- **Assessment-Run**: aus `fact_assessment_run` (Typ, Termin, Completion-Datum, verknüpfte `result_version_id`)
- **Assessment-Versionen**: aus `fact_candidate_assessment_version` pro (Kandidat, Typ) → `result_data JSONB` für Kernaussagen
- **Referenzen**: aus `fact_history` WHERE `activity_type='Referenzauskunft' AND candidate_id=X`
- **Mandats-Kontext** (falls Assessment mandatsbezogen): aus `fact_mandate` via `fact_assessment_order.mandate_id` → Mandat-Name, Funktion-Anforderung

## Manuelle Felder (Arkadium-Inputs)

Diese Felder sind **Freitext** im Editor, keine DB-Referenzen:
- `zusammenfassung_text`
- `empfehlung_text` (Proceed / Reject / Weitere Evaluation + Begründung)
- `pro_argumente_list` (Multi-Line-Textarea mit Bullets)
- `red_flags_list`
- `entwicklungsfelder_list`

Gespeichert als Overrides in `fact_documents.params_jsonb.manual_fields`.

## Unterschied zu anderen Assessment-Docs

| Doc | Audience | Inhalt | Source |
|-----|----------|--------|--------|
| SCHEELEN Detail-Report (pro Run) | Fachlich fundiert, ~100 Seiten | Rohdaten + psychologische Interpretation | SCHEELEN extern |
| SCHEELEN Executive Summary (pro Run) | Management-Zusammenfassung, 2 Seiten | Kurzfassung Detail-Report | SCHEELEN extern |
| **Arkadium Executive Report** (pro Run + Kandidat) | **Arkadium-Sicht + Mandat-Kontext** | Arkadium-Interpretation + Placement-Empfehlung | Arkadium intern |
| [[diagnostik-assessment]] Offerte | Kunde-Angebot | Preise + Leistungsumfang | Arkadium intern |

## Wann wird Executive Report generiert?

**Trigger:** Manuell durch CM/AM nach:
1. Mindestens 1 Assessment-Run mit Status `completed` und vorhandener `fact_candidate_assessment_version`
2. Optional: Referenzauskünfte eingeholt
3. Optional: Coaching-Gespräche dokumentiert

**Typischer Workflow:**
1. CM öffnet Kandidat-Detail → Assessment-Tab → prüft Detail-Reports
2. CM öffnet `/operations/dok-generator?template=executive_report&entity=assessment_run:uuid`
3. Editor zieht SCHEELEN-Kernaussagen automatisch, CM ergänzt manuelle Felder
4. Preview → Download als PDF
5. PDF geht als Anhang zum Kunden-Debriefing oder in Kandidaten-Akte

## Beispiele (raw/)

Historische Executive-Reports in `raw/Assessments/`:
- `Reporting_Curdin Cathomen.pdf`
- `Reporting_Michael Vidal.pdf`
- `Selektionsbericht_Sonja_Bee_Spiess.pdf`
- `Entwicklungsbericht_Sonja_Bee_Spiess.pdf`

Diese wurden bisher manuell als Word-Dokumente erstellt. Der globale [[dok-generator]] automatisiert das jetzt mit strukturiertem Auto-Pull + Template-Konsistenz.

## Ablage

- **`fact_documents.document_label = 'Executive-Report'`** (NEU 2026-04-17)
- **Folder:** `Account/Assessment/Reports/`
- **Retention:** Standard (5 Jahre)
- **Verknüpfung:** `fact_documents.entity_refs_jsonb = [{type:'assessment_run', id}, {type:'candidate', id}]`

## Permissions

- **Generieren:** CM (primär), AM (Review), Admin
- **Lesen:** CM (alle Accounts), AM (Owner-Account), Admin
- **Kunde bekommt den Report:** in der Regel NEIN — Executive Report ist Arkadium-intern. Für Kunden gibt es den SCHEELEN Executive Summary.

## Related

- [[dok-generator]] — generiert Executive Reports
- [[diagnostik-assessment]] — SCHEELEN-basierte Assessment-Aufträge
- [[assessment]] — Kandidat-Assessment-Ergebnisse
- [[kandidat]] — Kandidaten-Profile inkl. Assessment-Tab
- [[mandat]] — Mandats-Kontext für Placement-Empfehlung
- `ARK_DOK_GENERATOR_SCHEMA_v0_1.md` §1.4 — Template-Definition
- `ARK_ASSESSMENT_DETAILMASKE_SCHEMA_v0_3.md` — Assessment-Detailmaske
