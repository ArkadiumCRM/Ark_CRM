---
title: "HR · Kündigung + Aufhebung + Verwarnung — Vorlagen-Set"
type: source
created: 2026-04-19
updated: 2026-04-19
sources: [
  "raw/HR/2_HR On- Offboarding/9_Verwarnung, Kündigung & Aufhebungen/VORLAGE_Annulierung der Kündigung seitens Arbeitgeber.docx",
  "raw/HR/2_HR On- Offboarding/9_Verwarnung, Kündigung & Aufhebungen/VORLAGE_Aufhebungsvereinbarung Freistellung.docx",
  "raw/HR/2_HR On- Offboarding/9_Verwarnung, Kündigung & Aufhebungen/VORLAGE_Aufhebungsvereinbarung nach Kündigung.docx",
  "raw/HR/2_HR On- Offboarding/9_Verwarnung, Kündigung & Aufhebungen/VORLAGE_Letzte Verwarnung.docx"
]
tags: [hr, phase-3, kuendigung, aufhebung, verwarnung, offboarding, freistellung, eskalation]
---

# HR · Kündigung / Aufhebung / Verwarnung

4 Vorlagen für schwierige Offboarding-/Konflikt-Szenarien. Kein Standard-Kündigungsbrief — nur Eskalations- und Aufhebungs-Modelle.

## §A Letzte Verwarnung (Eskalation)

**Voraussetzung:** Erste schriftliche Verwarnung liegt bereits vor.

### Aufbau (Standard-Textbausteine)

1. **Bezug auf erste Verwarnung** — Datum + Vorgeschichte
2. **Feststellung** — konkrete Vorfälle (Beispiel: "abwertende und rufschädigende Aussagen")
3. **Rechtliche Einordnung:**
   - Art. 321a OR (Treue- + Loyalitätspflicht)
   - Art. 28 ZGB (Persönlichkeitsverletzung)
   - Art. 173 ff. StGB (üble Nachrede/Verleumdung — zivil- + strafrechtlich)
4. **Formale Verwarnung** + Unterlassungs-Aufforderung
5. **Eskalations-Drohung:** fristlose Kündigung gem. Art. 337 OR · Strafanzeige möglich
6. **Alternative:** Aufhebungsvertrag angeboten
7. **Verwarnung zu Personalakten**
8. Unterschrift + Rückläufer (MA bestätigt Erhalt)

## §B Aufhebungsvereinbarung (2 Varianten)

### Variante 1: Mit Freistellung

### Variante 2: Nach Kündigung

**Inhalt beider Varianten (Text identisch außer Bezug):**

1. **Einvernehmliche Beendigung** — ersetzt ordentliche Kündigung
2. **Eigentumsrecht an Daten** — alle in Arkadium-Infrastruktur erstellten Daten (auch Mails, Videos, Bilder) = Arkadium-Eigentum · Urheberrechte gehen an AG
3. **Keine lokalen Ablagen** — AG darf archivierte Daten durchsuchen + wiederverwenden
4. **Nachvertragliche Geheimhaltungspflicht + Treuepflicht** — keine üble Nachrede/Verleumdung
5. **Konkurrenzverbot** — Dauer = `XXX` (Platzhalter, siehe Arbeitsvertrag = 18 Mt Deutschschweiz)
6. **Rückgabepflicht** — alle IT/Telco-Devices + Unterlagen (Notizen, Ideen, Entwürfe, elektronische Daten inkl. Videos)
7. **Per-Saldo-Klausel** — alle gegenseitigen Ansprüche aus dem Arbeitsverhältnis damit erledigt

## §C Annullierung der Kündigung (seitens AG)

**Use-Case:** AG hat gekündigt, findet aber nach Gesprächen einen Weg zur Fortsetzung.

### Inhalt

1. Bezug auf ausgesprochene Kündigung (Datum + Kündigungsfrist)
2. **Annullierung** — nach intensiven Gesprächen Entwicklungsplan erstellt
3. AV bleibt **unverändert** gemäss ursprünglichem Arbeitsvertrag
4. Lohnzahlung nahtlos fortgesetzt
5. **Keine erneute Probezeit** (nahtlos)
6. Beidseitige Unterschrift bestätigt Einverständnis

## Key Takeaways für HR-Tool

Plan v0.1 §6.2 hat Offboarding-Template (`dim_onboarding_templates` Analog). Die 4 hier genannten Vorlagen sind **Sonderfälle** und sollten in eigener Struktur abgebildet werden.

### 1. Warning/Eskalations-Tracker

```sql
CREATE TABLE fact_warnings (
  id UUID PRIMARY KEY,
  mitarbeiter_id UUID REFERENCES dim_mitarbeiter(id),
  warning_type TEXT CHECK (warning_type IN (
    'verbal',           -- informelle mündliche Ermahnung
    'first_written',    -- erste schriftliche Verwarnung
    'final_written',    -- letzte schriftliche Verwarnung
    'notice_fristlos'   -- fristlose Kündigung Art. 337 OR
  )),
  issued_at DATE NOT NULL,
  issued_by UUID REFERENCES dim_mitarbeiter(id),
  reason TEXT NOT NULL,
  legal_refs TEXT[],                     -- ['OR 321a', 'ZGB 28', 'StGB 173']
  document_url TEXT,
  acknowledged_at TIMESTAMPTZ,
  acknowledged_by_signature BOOLEAN DEFAULT false,
  alternative_offered TEXT,              -- z.B. 'Aufhebungsvertrag'
  follow_up_deadline DATE,
  resolution TEXT                        -- 'compliance', 'termination', 'mutual_agreement', 'escalation'
);
```

### 2. Aufhebungs-/Freistellungs-Vertrag

Passt in `fact_hr_documents` (Plan §6.2) mit neuem `document_type`:
- `aufhebungsvereinbarung_mit_freistellung`
- `aufhebungsvereinbarung_nach_kuendigung`
- `kuendigung_annullierung`
- `verwarnung_erste`
- `verwarnung_letzte`

### 3. Offboarding-Saga (Plan §8.3.4)

**Trigger-Events:** 
- Drag-to-Offboarding im Kanban
- Kündigungs-Drawer geöffnet + speichern
- **Warning → final_written** → Follow-up-Deadline (30 Tage)

**State-Machine:**

```
ACTIVE
 ├─ warning_verbal → ACTIVE (documented)
 ├─ warning_first_written → UNDER_WATCH (with deadline)
 │   ├─ compliance → ACTIVE
 │   └─ warning_final_written → FINAL_WATCH
 │       ├─ mutual_agreement → OFFBOARDING_AMICABLE (Aufhebungsvertrag-Flow)
 │       ├─ fristlose_kuendigung → OFFBOARDING_IMMEDIATE (Art. 337 OR)
 │       └─ ordentliche_kuendigung → OFFBOARDING_NOTICE (Kündigungsfrist läuft)
 └─ resignation → OFFBOARDING_NOTICE
     └─ annullierung → ACTIVE (Annullierung-Flow) — nahtlos, keine neue Probezeit
```

### 4. Key Legal-Refs für UI (Info-Tooltips)

- Art. 321a OR — Treue-/Sorgfaltspflicht
- Art. 325 OR — Lohnabtretungsverbot
- Art. 335 OR — Ordentliche Kündigung
- Art. 337 OR — Fristlose Kündigung aus wichtigem Grund
- Art. 340 OR — Konkurrenzverbot (nachvertraglich)
- Art. 330a OR — Arbeitszeugnis-Pflicht
- Art. 28 ZGB — Persönlichkeitsschutz
- Art. 173–176 StGB — Ehrverletzungen

## Related

- [[hr-arbeitsvertraege]] · [[hr-konkurrenz-abwerbeverbot]]
- [[hr-austritt-versicherung-merkblaetter]]
- [[hr-schema-deltas-2026-04-19]]
- Plan v0.1 §5.6 Lifecycle Offboarding
