---
title: "Claim-Rechnung Template-Spec (Placeholder-Struktur)"
type: meta
created: 2026-04-18
updated: 2026-04-18
tags: [template, claim, rechnung, schutzfrist, doc-generator]
---

# Claim-Rechnung Template-Spec

Platzhalter-Struktur und Content-Outline für die zwei Claim-Rechnungs-Vorlagen (referenziert aus `ARK_ACCOUNT_DETAILMASKE_INTERACTIONS_v0_3.md` TEIL 8c).

**Status 2026-04-18:** Templates **noch zu erstellen**. Automatischer Skeleton-Generator-Versuch (autorefine Run 15) wurde verworfen — das generierte Layout entsprach nicht dem Arkadium-Design. Templates müssen **von Peter manuell im Arkadium-Corporate-Design** angelegt werden (Logo, echte Arkadium-Farben, Font, Signatur-Block, Zahlungskonditionen, Layout).

Diese Spec hier dient weiterhin als **Platzhalter-Contract für den Dok-Generator** — d.h. welche `{{…}}`-Tokens in den finalen Templates vorkommen müssen, damit die automatische Befüllung beim Claim-Flow funktioniert.

## Zu erstellende Dateien

| Dateiname | Fall | Wann |
|-----------|------|------|
| `Vorlage_Rechnung_Mandat_Direkteinstellung-Claim.docx` | **Fall X** — Mandats-Ursprung + identische Position | Ablageort: `raw/General/` |
| `Vorlage_Rechnung_Erfolgsbasis-Direkteinstellung-Claim.docx` | **Fall Y/Z** — andere Position ODER Erfolgsbasis-Ursprung | Ablageort: `raw/General/` |

## Gemeinsame Platzhalter (beide Varianten)

### Kopf
- `{{invoice_number}}` — z.B. "CL-2026-007"
- `{{invoice_date}}` — DD.MM.YYYY
- `{{due_date}}` — DD.MM.YYYY (default +30 Tage)

### Rechnungs-Empfänger (einstellende Firma, NICHT Holding bei Gruppen-Schutzfrist)
- `{{recipient_company_name}}`
- `{{recipient_address_line1}}`
- `{{recipient_address_line2}}`
- `{{recipient_zip_city}}`
- `{{recipient_country}}`
- `{{recipient_vat_id}}` (optional)

### Absender (Arkadium AG — fix in Template, nicht Platzhalter)
- Firma / Adresse / PLZ Ort / IBAN / BIC / MwSt-Nr. / Kontakt

### Sachverhalt (AGB-Klausel-Referenz)
- `{{agb_reference_section}}` — z.B. "§ 6 AGB vom 01.01.2026, Direkteinstellung trotz Schutzfrist"
- `{{candidate_name}}` — Vollständiger Name
- `{{original_mandate_or_presentation_context}}` — "Vermittelt im Rahmen Mandat MN-2026-018 / Vorstellung am 12.03.2025"
- `{{hire_date_at_client}}` — DD.MM.YYYY (Scraper-Fund oder manuell)
- `{{new_position_title}}` — Job-Titel beim Kunden

### Honorar-Berechnung

| Platzhalter | Inhalt |
|-------------|--------|
| `{{case_letter}}` | X / Y / Z |
| `{{honorar_basis_label}}` | "Rest-Mandatssumme" / "Staffel auf neuen Jahreslohn" |
| `{{jahres_lohn_chf}}` | (nur Y/Z) Neuer Jahresbrutto-Lohn |
| `{{staffel_percent}}` | (nur Y/Z) 21 / 23 / 25 / 27 % |
| `{{mandate_total_chf}}` | (nur X) Mandats-Gesamtsumme |
| `{{mandate_paid_chf}}` | (nur X) Bereits bezahlte Stages |
| `{{honorar_netto_chf}}` | Berechneter Nettobetrag |
| `{{mwst_percent}}` | 8.1 (CH Standard 2026) |
| `{{mwst_chf}}` | Berechnete MwSt |
| `{{honorar_brutto_chf}}` | Bruttobetrag |

### Zahlungskonditionen (fix im Template)
- Zahlungsziel 30 Tage netto
- IBAN / BIC Arkadium AG
- Zahlungsreferenz: `{{invoice_number}}`

### Fussnoten / Rechtliches (fix)
- Hinweis auf AGB (Link)
- Gerichtsstand Zürich
- Datenschutz-Hinweis

## Varianten-Unterschiede

### Fall X (Mandats-Direkteinstellung)
- Titel: "Rechnung — Direkteinstellung aus bestehendem Mandat"
- Sachverhalt-Text betont: identische Position, Rest-Honorar fällig gemäss Mandat-Vertrag
- Honorar-Zeile einzelnd: "Rest-Mandats-Honorar: {{mandate_total_chf}} − {{mandate_paid_chf}} = {{honorar_netto_chf}}"

### Fall Y/Z (Staffel-Direkteinstellung)
- Titel: "Rechnung — Direkteinstellung (Staffel-Honorar)"
- Sachverhalt-Text betont: neue/andere Position oder Erfolgsbasis-Ursprung, Staffel-Anwendung gemäss AGB
- Honorar-Zeile: "{{staffel_percent}} % von CHF {{jahres_lohn_chf}} Jahresbrutto-Lohn = CHF {{honorar_netto_chf}}"

## Dok-Generator Integration (Phase 1)

Template wird vom globalen Dok-Generator gerendert (siehe `project_doc_generator_idea.md` Memory, Phase 1 komplett). Input:
- `{fact_protection_window.id}` — liefert candidate_id, account_id, mandate_id (optional), case_letter, presentation-Daten
- `{fact_assessment_billing.amount_chf}` — nein, NOT this (Assessment). Claim-spezifisch: berechneter Honorar-Betrag aus Position-Check-Drawer (v0.3 Interactions L894-906)

## Priorität

**P1** — erst relevant wenn erster Claim-Fall real auftritt. Bis dahin Platzhalter in UI zeigen `[Rechnung wird nach Template-Erstellung verfügbar sein]`.

## Related

- [[detailseiten-nachbearbeitung]]
- [[autorefine-log]]
- `specs/ARK_ACCOUNT_DETAILMASKE_INTERACTIONS_v0_3.md` TEIL 8c
- `specs/ARK_MANDAT_DETAILMASKE_INTERACTIONS_v0_3.md` TEIL 10
- `raw/General/` (Ablageort der `.docx`)
