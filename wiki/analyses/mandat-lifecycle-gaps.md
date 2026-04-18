---
title: "Mandat-Lifecycle-Gaps — was im CRM fehlt"
type: analysis
created: 2026-04-12
updated: 2026-04-12
sources: ["General/", "Arkadium_AGB_FEB_2023.pdf", "ARK_MANDAT_DETAILMASKE_INTERACTIONS_v0_1.md"]
tags: [analysis, mandat, gaps, kuendigung, schutzfrist, roadmap]
---

# Mandat-Lifecycle-Gaps

Systematische Analyse der **im aktuellen CRM-Spec nicht abgedeckten** Mandats-Szenarien, basierend auf dem Vergleich mit den tatsächlich gelebten Vorlagen aus `raw/General/` (AGB, Mandatsofferte, Kündigungs-Rechnung, Rückerstattung, Optionale Stages, Diagnostik).

## Zusammenfassung (Top-5 Gaps)

1. **Mandats-Kündigung** (Exit Option 80%-Regel) — keine Status-Handling, keine Rechnungs-Automatik
2. **Direkteinstellung durch Kunde + Schutzfrist-Tracking** (12/16 Monate) — kein Datenmodell, kein Detection
3. **Optionale Stages** (VI–X) — kein strukturiertes Option-Modell, Templates fehlen
4. **RPO** als eigenständige Mandatsform — im `mandate_type` Enum fehlt
5. **Diagnostik & Assessment** als eigenständige Billing-Linie — technisch abgebildet, geschäftlich nicht

## 1. Mandats-Kündigung

Detaildoku: [[mandat-kuendigung]]

| Fehlt | Auswirkung |
|-------|-----------|
| Felder `terminated_by`, `terminated_reason`, `terminated_at`, `terminated_note` auf `fact_mandate` | Kündigung kann nicht dokumentiert werden |
| `fact_mandate_billing.type = 'termination'` | Abschluss-Rechnung nach 80%-Formel nicht erstellbar |
| Status-Wechsel `Aktiv → Abgebrochen` ohne Drawer | Kündigungsgrund nicht erfasst |
| Auto-Trigger für Kündigungs-Rechnung | Manuelle Erstellung, Fehlerquelle |
| Template-Link zu `Vorlage_Rechnung_Kündigung Mandat.docx` | Not registered |
| Longlist-Locking bei Kündigung | Research läuft weiter ohne Scope |

## 2. Direkteinstellung & Schutzfrist

Detaildoku: [[direkteinstellung-schutzfrist]]

| Fehlt | Auswirkung |
|-------|-----------|
| `fact_protection_window` Tabelle | Keine Schutzfrist-Matrix |
| Scraper-Match Kandidat-neuer-Arbeitgeber gegen aktive Schutzfristen | Umgehung unentdeckt |
| Info-Request-Template + 10-Tage-Timer | 16-Monats-Verlängerung nicht automatisch |
| Tab "Schutzfrist-Matrix" auf Account | Überblick fehlt |
| Alert bei Verletzung | AM erfährt zu spät |
| Claim-Workflow (Forderung, Eskalation) | Nur ad-hoc via E-Mail |

## 3. Optionale Stages

Detaildoku: [[optionale-stages]]

| Fehlt | Auswirkung |
|-------|-----------|
| `fact_mandate_option` Tabelle | Optionen nicht strukturiert buchbar |
| Templates für VI/VII/IX/X (nur VIII existiert) | Manuelle Dokument-Erstellung |
| Rechnung via `Vorlage_Rechnung_Mandat_Optionale Stage.docx` als Auto-Trigger | Vergessen möglich |
| UI-Section im Mandat-Tab | Versteckte Features |
| Option X (Garantie-Extension) muss `garantie_months` updaten | Inkonsistenz zwischen Option und Hauptfeld |

## 4. ~~RPO~~ — Umbenannt in Taskforce (2026-04-12)

RPO und Taskforce sind **dasselbe Produkt** — nur der Name hat gewechselt. Daher kein eigener Enum-Wert nötig, alles läuft unter `mandate_type = 'Taskforce'`. Die [[rpo-offerte]]-Vorlage ist inhaltlich weiterhin gültig, nur der Titel sollte zu "Taskforce-Offerte" umbenannt werden. **Kein CRM-Gap.**

## 5. Diagnostik & Assessment

Detaildoku: [[diagnostik-assessment]]

| Fehlt | Auswirkung |
|-------|-----------|
| `fact_assessment_order` Tabelle | Separate Offerten/Rechnungen nicht verknüpft |
| Offerten-Template `Vorlage_Offerte Diagnostik & Assessment.docx` | Manuell |
| Rechnungs-Template `Vorlage_Rechnung_Diagnostics & Assessment.docx` | Manuell |
| Pauschalpreis-Billing-Pfad | Nur Erfolgsbasis / Mandat gedacht |

## 6. Rückerstattung / Gutschrift (Best Effort)

Detaildoku: Siehe [[rechnungen-mandat]], [[agb-arkadium]]

| Fehlt | Auswirkung |
|-------|-----------|
| Gutschriftbelg-Template (`Vorlage_Rechnung Rückerstattung.docx`) | Manuelle Erstellung bei Austritt |
| Auto-Berechnung nach Austritts-Monat (100/50/25/10%) | Fehlerquelle bei Fälligkeit |
| Valuta-Datum ≠ Rechnungsdatum | Buchhaltungs-Feld fehlt |
| Referenz auf Original-Rechnung | Audit-Trail unvollständig |

## 7. Referral-Programm

Detaildoku: [[referral-programm]]

| Fehlt | Auswirkung |
|-------|-----------|
| `fact_referral` Entity | Empfehlungen nicht dokumentiert |
| Trigger "langfristige Geschäftsbeziehung" unscharf | Prämien-Fälligkeit unklar |
| Gutschrift-Template (CHF 1'000) | Manuell |

## 8. Exklusivitätsbruch-Detection

Mandatsofferte Klausel I: 3 Wochen Exklusivität ab Versand. Während Mandatslaufzeit gesamte Exklusivität für Kompetenzbereich.

| Fehlt | Auswirkung |
|-------|-----------|
| `exclusivity_end_date` auf `fact_mandate` | Frist nicht überwachbar |
| Bewerbungs-Rerouting-Workflow (andere Dienstleister zu Arkadium) | Keine Reaktions-Kette |

## 9. Reportings als Dashboards

Detaildoku: [[reportings-am-cm-tl]]

Die AM/CM/TL-Reporting-Vorlagen existieren als **PDF-/Word-Dokumente**, die manuell ausgefüllt werden. Im CRM:

| Fehlt | Auswirkung |
|-------|-----------|
| Wöchentliche AM-Matrix (Einkauf / Verkauf) als Dashboard | Manuelles Ausfüllen |
| Hunt-Statistik (CV IN, OI, Priorisierung A/B/C) automatisch | Aus `fact_history` aggregierbar, aber nicht aufbereitet |
| Monats-PDF-Export (Team Leader Reporting) | Manuelle InDesign-Arbeit |

## 10. Garantiefall-Workflow (Ersatzbesetzung)

Bei Mandat gilt **Ersatzbesetzung**, nicht Rückvergütung.

| Fehlt | Auswirkung |
|-------|-----------|
| `fact_guarantee_case` Tabelle | Garantiefälle nicht getrackt |
| Auto-Detection Kandidat-Austritt innerhalb Garantiefrist | Alerting fehlt |
| Workflow "Ersatzbesetzung" als Child-Mandat ohne zusätzliches Honorar | Datenmodell-Beziehung fehlt |

## Priorisierungs-Vorschlag

**P0 (rechtlich kritisch):**
- Mandat-Kündigung (#1)
- Direkteinstellung & Schutzfrist (#2)

**P1 (Billing-Integrität):**
- Optionale Stages (#3)
- Rückerstattung (#6)
- Garantiefall-Workflow (#10)

**P2 (Produktlinien-Vollständigkeit):**
- RPO (#4)
- Diagnostik & Assessment (#5)

**P3 (Nice-to-have / Automatisierung):**
- Referral (#7)
- Exklusivitätsbruch (#8)
- Reportings als Dashboards (#9)

## Offene Fragen

### Geklärt 2026-04-12
1. ~~**80%-Regel bei Fall B**~~ → Fall A: fix 80% − bezahlte Stages. Fall B: `Payout = max(Σ Stages bis inkl. laufender, 80%)`, 80% wirken als Floor → bei Kündigung in Stage 3 zahlt Kunde 100% (= Stage 3), in Stage 1/2 mindestens 80%.
2. ~~**RPO-Typisierung**~~ → **RPO existiert nicht mehr** als Produktlinie, ist in Taskforce umbenannt worden. Alte Offerte ([[rpo-offerte]]) ist historisch.
3. ~~**Schutzfrist-Scope**~~ → **Variante A:** nur konkret vorgestellte Kandidaten (CV/Dossier/Pitch), nicht ganze Longlist, nicht Kompetenzbereich.

### Geklärt 2026-04-13
4. ~~**Referral-Trigger**~~ → Zwei Typen (Kandidat / Kunde). Kandidaten-Referral: Placement + nach Rückvergütungsfrist. Kunden-Referral: Erstes Placement + Mandat komplett abgeschlossen. Siehe [[referral-programm]].
5. ~~**Optionale Stages Preis**~~ → **Case-by-case**, keine Formeln oder Preislisten.
6. ~~**Diagnostik-Erfassung**~~ → Eigene Entity `fact_assessment_order` + **eigene Detailseite** `/assessments/[id]` mit 5 Tabs (analog Mandat), bidirektional verknüpft mit Kandidat + Account (+ optional Mandat). Inkl. eigenem Auftragsvertrag und Billing-Spur (`fact_assessment_billing`). Siehe [[diagnostik-assessment]].
7. ~~**Fall A**~~ → Bisher nie eingetreten, Kulanz-Fortsetzung oder Erweiterung. Kein vordefinierter Schwellenwert — Admin-Entscheidung im Einzelfall.
8. ~~**Vorstellungs-Definition**~~ → Mündlich am Telefon/Teams ODER per E-Mail-Dossier.

### Alle Kern-Fragen geklärt. Verbleibende offene Punkte:
- 12-Monats-Speicherfrist-Detection beim Kunden (siehe [[direkteinstellung-schutzfrist]])
- Langfristig: gemeinsame `fact_engagement` Parent-Entity für Mandat + Assessment + zukünftige Typen?

## Related

[[mandat]], [[mandat-kuendigung]], [[direkteinstellung-schutzfrist]], [[optionale-stages]], [[diagnostik-assessment]], [[rpo-offerte]], [[honorar-berechnung]], [[agb-arkadium]], [[mandatsofferte-vorlage]], [[rechnungen-mandat]], [[ungereimtheiten-report]]
