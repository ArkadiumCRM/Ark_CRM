---
title: "Referral-Prämienvergütung"
type: source
created: 2026-04-12
updated: 2026-04-12
sources: ["General/3_Candidate Management/Refferalschreiben/Vorlage_Refferal.docx"]
tags: [source, referral, praemie, empfehlung]
---

# Referral-Prämienvergütung

**Datei:** `raw/General/3_Candidate Management/Refferalschreiben/Vorlage_Refferal.docx` (Schreibfehler "Refferal" in Ordnername)

## Programm

- **Prämie:** CHF 1'000.00 bei erfolgreicher Weiterempfehlung
- **Auszahlung:** Gutschrift auf angegebenes Konto mit Datums-Vermerk

### Zwei Referral-Typen (geklärt 2026-04-13)

| Typ | Empfehlung | Fälligkeits-Trigger |
|-----|-----------|---------------------|
| **Kandidaten-Referral** | Empfehler nennt Kandidat, der später platziert wird | Erstes Placement **+ nach Ablauf der Rückvergütungsfrist** (Probezeit bestanden, keine Rückerstattung mehr möglich) |
| **Kunden-Referral** | Empfehler nennt Unternehmen, das ein Mandat vergibt | Erstes Placement aus diesem Mandat **+ Mandat komplett (gedeckt / abgeschlossen)** |

In beiden Fällen: **pro Empfehlung einmalig**, gezahlt beim ersten erfolgreichen Placement.

## Dokument

Dankesschreiben/Gutschrift-Bestätigung an den Empfehler mit Signaturen (Founding Partner + Head of [Bereich]).

## CRM-Implikationen

- **Nicht im Datenmodell** abgebildet — neue Entity nötig

**Datenmodell-Vorschlag:**
```sql
fact_referral (
  id,
  referral_type: 'candidate' | 'client',
  referrer_kandidat_id,           -- wer empfohlen hat (immer Kandidat-Entity, auch für Kunden-Empfehlungen)
  referred_kandidat_id,           -- bei Kandidat-Referral: empfohlener Kandidat
  referred_account_id,            -- bei Kunden-Referral: empfohlenes Unternehmen
  linked_prozess_id,              -- FK zum auslösenden Placement
  linked_mandat_id,               -- bei Kunden-Referral: das neu vergebene Mandat
  payout_amount: 1000,
  payout_due_at,                  -- berechnet aus Trigger-Logik
  payout_date,
  status: 'pending' | 'eligible' | 'paid' | 'cancelled'
)
```

**Auto-Trigger:**
- **Kandidat-Referral:** Placement erfolgt → `payout_due_at = placement_date + probezeit_ende` (abhängig von Rückvergütungs-Staffel-Ende)
- **Kunden-Referral:** Erstes Mandat-Placement erfolgt **UND** Mandat-Status = `Abgeschlossen` → `payout_due_at = mandat_closed_at`

**Alerts:** AM-Notification "Referral CHF 1'000 fällig — Gutschrift versenden"
**Template:** Gutschrift-Schreiben aus `Vorlage_Refferal.docx`

## Related

[[kandidat]], [[mandat-lifecycle-gaps]]
