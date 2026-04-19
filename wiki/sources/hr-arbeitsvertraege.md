---
title: "HR · Arbeitsverträge (Consultant + Researcher)"
type: source
created: 2026-04-19
updated: 2026-04-19
sources: [
  "raw/HR/2_HR On- Offboarding/1_Arbeitsverträge/Vorlage_Arbeitsvertrag_neuer Consultant.docx",
  "raw/HR/2_HR On- Offboarding/1_Arbeitsverträge/Vorlage_Arbeitsvertrag_Researcher mit Provisionsregelung im Vertrag.docx",
  "raw/HR/2_HR On- Offboarding/1_Arbeitsverträge/Vorlage_Arbeitsvertrag_Researcher mit Verweis auf Provisionsvertrag.docx",
  "raw/HR/2_HR On- Offboarding/1_Arbeitsverträge/Vorlage ENTWURF_Arbeitsvertrag_neuer Consultant.docx"
]
tags: [hr, phase-3, arbeitsvertrag, consultant, researcher, vertragswerk, vorlage]
---

# HR · Arbeitsverträge — Vorlagen-Set

4 Arbeitsvertrags-Vorlagen für die beiden Haupt-MA-Funktionen (Consultant · Research Analyst & Junior Consultant). Alle Vorlagen referenzieren die drei Reglemente (Generalis Provisio · Tempus Passio 365 · Locus Extra), die Stellenbeschreibung "Progressus" und den Provisionsvertrag "Praemium Victoria" als integrale Vertragsbestandteile.

## Quellen + Varianten

| Datei | Funktion | Provisionsmodell | Karenzentschädigung |
|-------|----------|------------------|---------------------|
| `Vorlage_Arbeitsvertrag_neuer Consultant.docx` | Consultant | Verweis auf **Praemium Victoria** | CHF 500/Mt |
| `Vorlage ENTWURF_...neuer Consultant.docx` | Consultant (Entwurf/WIP) | — | — |
| `Vorlage_Arbeitsvertrag_Researcher mit Provisionsregelung im Vertrag.docx` | Research Analyst & Junior Consultant | **Inline** CHF 500/Vermittlung, quartalsweise | CHF 350/Mt |
| `Vorlage_Arbeitsvertrag_Researcher mit Verweis auf Provisionsvertrag.docx` | Research Analyst & Junior Consultant | Verweis auf Praemium Victoria | CHF 350/Mt |

**Template-Defaultwerte im Consultant-Vertrag:** Hauptsitz Maneggstrasse 45, 8041 Zürich · Bruttobasis CHF 5'000/Mt × 12 · Unterzeichner-Beispiel Nenad Stoparanovic (Partner & Founder).

## Vertragsstruktur (13 Ziffern)

1. **Funktion + Tätigkeiten** — Kandidatenansprache, Interviews, Eignungsabklärung, Active/Executive/Direct Search, Administration (Details in Progressus)
2. **Nebenbeschäftigung** — entgeltlich nur mit schriftlicher Zustimmung · unentgeltlich bei sachlichem Bezug zur Geschäftstätigkeit
3. **Pensum** — Default 100%
4. **Arbeitszeit** — Verweis auf [[hr-reglement-tempus-passio-365]]
5. **Arbeitsort + Home-Office** — Hauptsitz · Verweis auf [[hr-reglement-locus-extra]]
6. **Gehalt** — Bruttobasis × 12 + Karenzentschädigung monatlich (funktion-abhängig: CHF 500 Consultant / CHF 350 Researcher)
7. **Provisionen** — Consultant-Vertrag: separater [[hr-provisionsvertraege|Praemium Victoria]] · Researcher-Variante-1: CHF 500 pro Vermittlung brutto, quartalsweise, nach erfolgter Bezahlung+Probezeit+Garantiefrist
8. **Ferien** — Verweis auf Tempus Passio 365 §6 (25 Tage)
9. **Probezeit + Kündigung:**
   - Probezeit: **3 Monate**
   - Während Probezeit: Kündigungsfrist **3 Tage** jederzeit
   - 1. Dienstjahr: **1 Monat**
   - 2.–5. Dienstjahr: **2 Monate**
   - ab 6. Dienstjahr: **3 Monate**
10. **Konkurrenz- + Abwerbeverbot** — siehe [[hr-konkurrenz-abwerbeverbot]] (18 Mt Deutschschweiz)
11. **Treuepflicht + Disziplinarstrafen:**
   | Verletzung | Strafe pro Zuwiderhandlung |
   |------------|----------------------------|
   | Konkurrenzierung während AV | CHF 20'000 |
   | Abwerbung während AV | CHF 10'000 |
   | Nebentätigkeit ohne Zustimmung | CHF 3'000 |
   | Diffamierende Äusserung | CHF 5'000 |
   | Geschäftsgeheimnis-Verletzung | CHF 20'000 |
12. **Geschäftsgeheimnis** — Vertraulichkeit + Rückgabepflicht · nachvertragliche Konventionalstrafe CHF 20'000/Verletzung
13. **Integrale Vertragsbestandteile:**
   - Reglement "Generalis Provisio" (Allgemeine Anstellungsbedingungen)
   - Reglement "Tempus Passio 365" (Arbeitszeit)
   - Reglement "Locus Extra" (mobiles Arbeiten)
   - Beschreibungen "Progressus" (Stellen- + Kompetenzbeschreibung)
   - Vertrag "Praemium Victoria" (Provisionsvertrag)

   Widerspruchs-Regel: Arbeitsvertrag geht Reglementen vor.

## Zentrale Deltas Consultant vs. Researcher

| Element | Consultant | Researcher |
|---------|-----------|-----------|
| Funktionsbezeichnung | Consultant | Research Analyst & Junior Consultant |
| Karenzentschädigung/Mt | CHF 500 | CHF 350 |
| Loyalität-Klausel | "in leitender Funktion" | Standard |
| Anhang "Praemium Victoria" | Pflicht | Optional (je nach Variante) |
| Provisions-Modell | Praemium Victoria (ZEG-Staffel) | CHF 500/Vermittlung ODER Praemium Victoria |

## Key Quotes

> "Auf diesen Arbeitsvertrag ist schweizerisches Recht anwendbar. Zuständig ist das Gericht am Wohnsitz oder am Sitz der beklagten Partei oder an dem Ort, an dem der Mitarbeiter gewöhnlich seine Arbeit verrichtet hat." (Ziffer 12)

> "Die Arkadium besteht darauf ihren USP, ihre Methode und das vermittelte Fachwissen, ihre Marktposition und Firmenkunden zu schützen, weshalb ein Konkurrenzverbot und ein Abwerbeverbot für die Ausübung der Position zwingend ist." (Ziffer 9.1)

## Fragen für HR-Tool

1. **Vertragstyp-Enum:** `dim_contract_types` Seeds müssen mindestens `unbefristet_consultant`, `unbefristet_researcher` enthalten — aktuell im Plan v0.1 §6.2 nur generisch (`unbefristet`, `befristet`, ...).
2. **Karenzentschädigung:** Inline-Feld auf `fact_employment_contracts` — nicht mit Konkurrenzverbot-Feld vermischen (siehe [[hr-konkurrenz-abwerbeverbot]]).
3. **Disziplinarstrafen-Katalog:** fehlt in Plan v0.1 — neue `dim_disciplinary_penalties`-Tabelle notwendig.
4. **Kündigungsfrist-Staffelung:** Plan v0.1 hat `kuendigungsfrist_monate INT DEFAULT 3` — sollte durch JSONB oder berechnete Regel ersetzt werden (1/2/3 Mt je nach Dienstjahr).
5. **Integrale Vertragsbestandteile:** Neue `fact_contract_attachments`-Tabelle mit FK auf Reglemente + Provisionsvertrag + Stellenbeschreibung.

## Related

- [[hr-reglemente]] · [[hr-provisionsvertraege]] · [[hr-stellenbeschreibung-progressus]]
- [[hr-konkurrenz-abwerbeverbot]] · [[hr-vertragswerk]]
- [[hr-schema-deltas-2026-04-19]]
