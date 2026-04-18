---
title: "ARK Assessment Detailmaske Interactions v0.2"
type: source
created: 2026-04-13
updated: 2026-04-14
sources: ["ARK_ASSESSMENT_DETAILMASKE_INTERACTIONS_v0_2.md", "ARK_ASSESSMENT_DETAILMASKE_INTERACTIONS_v0_1.md"]
tags: [source, assessment, interactions, credits-typisiert, umwidmung, workflow]
---

# ARK Assessment Detailmaske Interactions v0.2

**Datei:** `specs/ARK_ASSESSMENT_DETAILMASKE_INTERACTIONS_v0_2.md`
**Vorherige Version:** `specs/alt/ARK_ASSESSMENT_DETAILMASKE_INTERACTIONS_v0_1.md`
**Status:** v0.2 = Typisiertes Credits-Modell (Entscheidung 2026-04-14)
**Begleitdokument:** [[assessment-schema]] v0.2

## Zusammenfassung

Behavioral Spec für die Assessment-Detailseite mit 5 Tabs und Credits-basiertem Auftragsmodell.

## Schlüssel-Flows

- **Erstellung** nur über Account-Detailseite Tab 8 (eigenständig) oder Mandat-Option IX
- **Credit-Zuweisungs-Drawer:** Kandidat-Autocomplete mit Hard-Stop "Als Kandidat anlegen", Duplikat-Check, optional Termin
- **Umwidmungs-Flow:** Kandidat ersetzen nur bei Status ≤ `scheduled`, Run-ID bleibt erhalten, Audit via `reassigned_from_kandidat_id`
- **Report-Upload-Flow:** Executive Summary + Detail-Report + Typ-Auswahl → Transaktion updated Run + erzeugt Kandidaten-Assessment-Version + inkrementiert `credits_used`
- **Auto-Status-Übergänge:** offered → ordered (Signatur) → partially_used (1. completed) → fully_used (letzter completed)
- **Rechnung:** Bei Unterschrift automatisch erstellt (`full`, fällig nach Zahlungsziel)

## Event-Katalog (12 Events)

assessment_order_created, assessment_order_signed, assessment_credit_assigned, assessment_credit_reassigned_away, assessment_credit_reassigned_to, assessment_run_scheduled, assessment_run_completed, assessment_run_cancelled, assessment_version_created, assessment_order_cancelled, assessment_invoice_generated, assessment_invoice_paid.

## Edge Cases

- **Überschiessende Zuweisungen:** Button disabled bei erschöpften Credits
- **Credit-Tausch** innerhalb gleichem Auftrag: Umwidmung (kandidat_id ändern), kein Freigeben+Neu
- **Credits verfallen** in Phase 1 nicht; Phase 2: optional `credits_expiry_date`
- **Upgrade/Downgrade** Phase 2
- **Multi-Mandat**: 1 Auftrag = 1 Mandat (oder eigenständig), keine Multi-Verteilung
- **Stornierung** bezahlter Aufträge: kein Auto-Refund, Kulanz durch Admin

## Berechtigungs-Spezialfälle

- **Admin-Override:** kann Preis/Credits nachträglich ändern (mit Audit-Log)
- **CM Read-only:** sieht Tab 1+2+5, Preise maskiert
- **Kandidat-Daten:** nicht editierbar aus Assessment heraus (bleibt im Kandidaten-Profil)

## Verlinkte Wiki-Seiten

[[assessment-schema]], [[diagnostik-assessment]], [[assessment]], [[mandat]], [[account]], [[kandidat]], [[detailseiten-guideline]], [[event-system]], [[berechtigungen]]
