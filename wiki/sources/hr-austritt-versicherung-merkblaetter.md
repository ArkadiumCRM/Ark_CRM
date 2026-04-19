---
title: "HR · Austritts-Merkblätter AXA (KKV + Abredeversicherung)"
type: source
created: 2026-04-19
updated: 2026-04-19
sources: [
  "raw/HR/2_HR On- Offboarding/13_Dokumente bei Austritt/14739DE_KKV_Merkbkatt_2024-07-1.pdf",
  "raw/HR/2_HR On- Offboarding/13_Dokumente bei Austritt/16747DE_FS-Abredeversicherung-1.pdf"
]
tags: [hr, phase-3, austritt, merkblatt, axa, krankentaggeld, abredeversicherung, uvg, offboarding-checkliste]
---

# HR · Austritts-Merkblätter (AXA)

Zwei Standard-AXA-Merkblätter, die bei jedem MA-Austritt schriftlich übergeben werden müssen (Nachweis durch MA-Unterschrift auf Rückläufer).

## §A KKV-Merkblatt (Kollektive Krankentaggeldversicherung)

**Dokument-ID:** `14739DE – 2024-07 D` · AXA

### Inhalt

- **Übertrittsrecht** in AXA-Einzelversicherung bei Ausscheiden (CH-Wohnsitz)
- Ohne Gesundheitsprüfung · bis Höhe bisher versicherter Leistungen
- Massgebend: Gesundheitszustand + Alter bei Eintritt in KTG-Kollektivvertrag

### Kein Übertrittsrecht bei

- Stellenwechsel mit neuem KTG-Anbieter
- Übergang kollektiver KTG-Vertrag auf anderen Versicherer (nahtlos)
- AHV-Rente / Referenzalter
- Wohnsitz Ausland

### Frist

- **3 Monate** nach Ausscheiden oder Vertragsaufhebung oder Erhalt Merkblatt

### Rückläufer

Unterschriftsfeld mit Name · Vorname · Datum · Name des Betriebs — Beleg für MA + Betrieb.

## §B Abredeversicherung-Merkblatt (AXA, UVG)

**Dokument-ID:** `16747DE – 2019-06 D` · AXA

### Inhalt

- **Nach Ende AV:** 31 Tage Schutz gegen Nichtberufsunfälle (wenn ≥ 8 h/Wo beim AG gearbeitet)
- **Abredeversicherung** verlängert Schutz um **max 6 Monate**
- Gleiche Leistungen wie obligatorische NBU-Versicherung nach UVG
- Abschluss vor Ende NBU-Versicherung nötig
- Online bei AXA: `AXA.ch/abredeversicherung`
- **Prämie: CHF 40/angebrochenen Monat**

### Beispiel-Rechnung

| Event | Datum |
|-------|-------|
| Ende Lohnanspruch | 14.9. |
| Ende NBU-Deckung (31 Tage) | 15.10. |
| Gewünschte Verlängerung bis | 30.11. |
| Abredeversicherung Dauer | 2 Monate |
| Prämie | CHF 80 |

### Pflichten bei KVG-Sistierung

- Wer KVG-Unfalldeckung sistiert hatte (wegen NBU-Doppel-Versicherung) → Krankenkasse **innerhalb 1 Monat** über Ende NBU informieren
- Je nach KK auch Sistierung bei Abredeversicherung

### Rückläufer

Unterschriftsfeld (Name · Vorname · Datum · Betrieb) — Bestätigung der Aufklärung.

## Key Takeaways für HR-Tool

### Offboarding-Checkliste · Pflicht-Items

Plan v0.1 §5.6 hat 15 Offboarding-Tasks. Hier die zwei konkreten Merkblatt-Pflichten:

1. **KKV-Merkblatt übergeben + Rückläufer** (Unterschrift MA)
2. **Abredeversicherungs-Merkblatt übergeben + Rückläufer** (Unterschrift MA)

Beide mit **Compliance-Audit-Trail** (wichtig bei SUVA/AXA-Nachfragen).

### Schema-Delta

```sql
ALTER TABLE fact_offboarding_tasks ADD COLUMN IF NOT EXISTS
  compliance_refs TEXT[];   -- ['UVG', 'KVG', 'KTG', 'AHV', 'BVG']

ALTER TABLE fact_offboarding_tasks ADD COLUMN IF NOT EXISTS
  external_document_url TEXT,
  acknowledgement_required BOOLEAN DEFAULT false,
  acknowledgement_url TEXT,
  acknowledgement_date DATE;
```

### Offboarding-Template Austritt (Seed-Tasks, Arkadium-spezifisch)

| # | Task | Pflicht | Dokument |
|---|------|--------|----------|
| 1 | IT-Deprovisioning (Accounts deaktiv, 2FA, VPN) | ✓ | intern |
| 2 | Geräte-Rückgabe (Laptop, Phone, Token) | ✓ | intern |
| 3 | KKV-Merkblatt übergeben + Rückläufer | ✓ | `14739DE_KKV_Merkbkatt_2024-07-1.pdf` |
| 4 | Abredeversicherungs-Merkblatt übergeben + Rückläufer | ✓ | `16747DE_FS-Abredeversicherung-1.pdf` |
| 5 | Arbeitszeugnis erstellen + übergeben | OR 330a | Template aus [[hr-arbeitszeugnisse]] |
| 6 | Pensionskasse-Austritt formular | ✓ | PK-Anbieter |
| 7 | Schlussabrechnung (inkl. Rest-Ferien · Rückzahlung Weiterbildung falls fällig) | ✓ | Backoffice |
| 8 | AHV-Austrittsmeldung | ✓ | Treuhand |
| 9 | BVG-Austrittsmeldung | ✓ | Pensionskasse |
| 10 | Akten-/Daten-Rückgabe (Notizen, USB, elektronisch) | ✓ | |
| 11 | Konkurrenzverbots-Erinnerung + Entschädigung-Check | ✓ | [[hr-konkurrenz-abwerbeverbot]] |
| 12 | Schlüssel/Badge/Parkplatz-Zugang deaktivieren | ✓ | Facility |
| 13 | Provisions-Endabrechnung + Prozess-Vergütung ([[hr-provisionsvertraege]] §6.2) | ✓ | Commission-Engine |
| 14 | Email-Auto-Reply einrichten (Übergabe-Kontakt) | ✓ | |
| 15 | Alumni-Status setzen (Retention-Clock startet) | Auto | Lifecycle |

## Related

- [[hr-kuendigung-aufhebung]] · [[hr-reglemente]] §6.2.2 (UVG-NBU im Hauptvertrag)
- [[hr-schema-deltas-2026-04-19]]
- Plan v0.1 §3.1 CH-Compliance + §5.6 Offboarding
