---
title: "Commission-Engine · Abgleich Handoff ↔ CC-Dokument"
type: abgleich
created: 2026-04-19
updated: 2026-04-19
status: awaiting-peter-decision
sources_handoff: [
  "ARK_HR_STRATEGY_DECISION_v0_1.md (Handoff-Dokument Web-Session)"
]
sources_cc_authoritative: [
  "wiki/concepts/provisionierung.md",
  "wiki/sources/anhang-provisionsstaffel-cm.md",
  "wiki/sources/provisionssheet-joaquin.md",
  "wiki/sources/provisionssheet-peter.md",
  "memory/project_commission_model.md"
]
tags: [abgleich, commission, handoff, inkonsistenzen, peter-decision]
---

# Commission-Engine · Abgleich Handoff ↔ CC-Dokument

Handoff aus Web-Session (Option D: Commission-First, HR-Lean) vs. authoritative CC-Dokumente. **Drei fundamentale Inkonsistenzen**, eine davon scope-relevant. Peter-Entscheidung erforderlich bevor Spec-Arbeit beginnt.

---

## 1. CC-Authoritative Commission-Struktur (zusammengefasst)

### 1.1 Rollen (3, nicht 3-Wege-Split wie im Handoff impliziert)

| Rolle | Vergütungs-Modell | Beispiel |
|-------|---------------------|----------|
| **Researcher** | CHF 250–750 **Pauschale** pro Placement · Owner = CV-Upload-Owner · fällig bei erfolgreicher Platzierung (nicht bei Garantie-Breach) | z.B. Hanna/Luca · Namen nicht im CC-Dokument |
| **CM / AM** | Jahresbudget CHF 360k–700k · **50/50-Deal-Split** · ZEG-Staffel · 80/20 Abschlag/Rücklage · quartalsweise | Joaquin Vega (CM CI) · Jahresbudget 440k · OTE 40k |
| **Head of** | **Teambudget** (Summe aller Sparten-Umsätze) · CHF 1.0M–1.5M+ Jahresziel · gleiche ZEG-Staffel wie CM/AM · OTE höher (z.B. 90k bei 100 % ZEG) | Peter Wiederkehr (Head of CI & BT) · Teambudget 1.5M · OTE 90k |

### 1.2 Split-Mechanik pro Placement

- Jeder Placement wird **50/50 zwischen AM und CM** aufgeteilt
- Wenn derselbe MA AM **UND** CM → voller Anteil (100 %)
- **Punkte-System** (in Excel-Sheets):
  - `1` = 50 %-Anteil (Split, nur eine der zwei Rollen)
  - `2` = 100 %-Anteil (AM+CM oder Head-of-Teambudget-Rollup)
- Net-Fee-Zuteilung = `Net Fee × (Punkte / 2)`

### 1.3 ZEG-Staffel (aus PDF-Anhang, detailliert)

```
ZEG-Bereich    → Provisionssatz
< 50 %         → 0 %                          (kein Anspruch)
50–59 %        → 10–28 %  (+2 %/1 % ZEG)     (Einstieg)
60–69 %        → 30–39 %  (+1 %/1 % ZEG)     (Dämpfungs-Zone)
70–99 %        → 40–98 %  (+2 %/1 % ZEG)     (Leistungs-Korridor)
100 %          → 100 %                        (Zielpunkt)
101–150 %      → 102–160 % (+2 %/1 % ZEG)    (Bonus-Korridor)
> 150 %        → +1 %/1 % ZEG                 (Degression, vermeidet Runaway)
```

### 1.4 Quartals-Auszahlung

- **80 % Abschlag** im Folge-Monat (Q1→Apr · Q2→Jul · Q3→Okt · Q4→Jan)
- **20 % Rücklage** bleibt 3 Monate (Garantiefrist · `fact_candidate_guarantee.end_at`)
- Bei Austritt des Kandidaten in Garantie → Rücklage gegengerechnet
- **Kumulativ** über Quartale: Q1, Q1+Q2, Q1+Q2+Q3, Jahr
- `ZEG = Σ(zugeteilte Net Fees im Zeitraum) / Σ(Budget im Zeitraum)`

### 1.5 Konkrete Beispiele aus den Sheets

**Joaquin Q1 2026** (CM CI):
- Budget Q1: 110'000 · OTE/Q: 10'000
- Erzielte Net Fees (mit Punkten): 129'945 kumulativ
- ZEG: **118 %** → Provisionssatz 128 % (aus Staffel)
- Provision brutto: 10'000 × 128 % = **12'800**
- 80 % Abschlag: 10'240 · 20 % Rücklage: 2'560

**Peter Q1 2026** (Head of CI & BT):
- Teambudget Q1: 375'000 · OTE/Q: 22'500
- Net Fees: 295'614 kumulativ (alle Pkt 2 = voller Anteil)
- ZEG: **79 %** → Satz 58 %
- Provision brutto: 22'500 × 58 % = **13'050**
- 80 %: 10'440 · 20 %: 2'610

### 1.6 Sonderfall Time-Mandat

- `dim_mandate.business_model = 'time'` zählt **NICHT** ins Teambudget-ZEG
- Wird "ausserordentlich abgerechnet"
- **Mechanik in CRM 2.0 noch offen** (CC-Dokument-Originalton)

---

## 2. Drei fundamentale Inkonsistenzen Handoff ↔ CC

### 🔴 Inkonsistenz 1 · Rollen-Modell

| Aspekt | Handoff behauptet | CC-Dokument sagt |
|--------|---------------------|-------------------|
| Rollen-Anzahl | 3 (CM · AM · Hunter) | **3 + 1** (Researcher · CM · AM · Head of) |
| Hunter-Namenskonvention | "Hunter" | **"Researcher"** (CV-Upload-Owner) |
| Head-of-Rolle | **nicht erwähnt** | **eigene Rolle** mit Teambudget-Logik |
| Split-Struktur | "CM/AM/Hunter-Split" (impliziert 3-Wege) | **2-Wege 50/50 AM/CM** + Pauschale Researcher + Teambudget Head-of |

**Konsequenz für Spec**: Wenn wir CC folgen, ist Commission-Engine kein 3-Wege-Split-Calculator, sondern ein **Multi-Model-System**:
- Researcher-Modul (Pauschale-Lookup pro Placement)
- CM/AM-Modul (50/50-Split + ZEG-Staffel + Quartals-Kumulation)
- Head-of-Modul (Teambudget-Rollup über Sparten + ZEG-Staffel)

### 🔴 Inkonsistenz 2 · Split-Granularität

| Aspekt | Handoff | CC-Dokument |
|--------|---------|-------------|
| Konfigurations-Ebene | "pro Mandat überschreibbar" | **Default 50/50 AM/CM · selten individuell** |
| Daten-Modell | `fact_commission` per-Placement mit freien Splits | **`fact_process_finance.am_user_id`/`cm_user_id`/`split_am_pct`/`split_cm_pct`** (Input-Felder) |
| Berechnungs-Basis | Per-Placement | **Per-Mitarbeiter per Quartal (kumulativ)** |

**Konsequenz**: CC-Modell ist **zeitraumbasiert** (quartalsweise ZEG), nicht placement-basiert. Die Engine muss aggregieren über Zeiträume, nicht nur pro Deal abrechnen.

### 🔴 Inkonsistenz 3 · Scope CRM-1.0 vs. CRM-2.0 (strategisch wichtigste)

| Aspekt | Handoff (Option D, Web-Session heute) | CC-Dokument + Memory (2 Tage alt) |
|--------|---------------------------------------|-------------------------------------|
| Commission-Engine | **Phase 1 Kern-USP** — jetzt bauen | **"CRM 2.0, nicht 1.0"** — Excel bleibt bis 2.0 |
| Scope CRM 1.0 | inkl. Commission-Engine | nur **Eingangs-Felder** · keine Engine-UI |
| `fact_commission`-Tabelle | neu in Phase 1 | nicht erwähnt, impliziert später |
| Auszahlungs-UI | Phase 1 | "explizit NICHT in Mockups" |

**Kritische Frage**: Hat die Web-Session diese alte CRM-2.0-Scope-Regel bewusst aufgehoben, oder war sie nicht bewusst?

**Hinweise im Handoff**:
- Section 3.1: "Option D: Commission-First, HR-Lean" — **bewusst** Commission-Engine als Kern
- Section 3.3: "Phase 1 (jetzt – 12 Monate) · ARK-intern" — bewusst in Phase 1
- Section 4.1: "Commission-Rules-Engine" als P0 Wave 1

→ Web-Session hat die Scope-Grenze **bewusst neu gesetzt**. Die alte Memory (`project_commission_model.md`) und der Scope-Absatz in `wiki/concepts/provisionierung.md` sind damit **überholt**.

**Peter muss das explizit bestätigen**, weil:
- Memory-Disclaimer sagt "verify against current code" · Memory ist 2 Tage alt
- `wiki/concepts/provisionierung.md` hat eine harte `> [!warning] Nicht in UI einbauen`-Notiz
- Es gibt existing Mockups die dieser Regel folgen

---

## 3. Antworten aus CC zu Handoff §6.4-Fragen

Peter hat im Handoff (§6.4) Rollen-Fragen gestellt. Antworten aus CC:

### a) Rollen bei ARK

| Frage | Antwort aus CC-Dokumenten |
|-------|----------------------------|
| CM = Joaquin, Nina? | **Joaquin Vega** ist CM CI bestätigt (Sheet) · Nina nicht in CC-Dokumenten |
| AM = wer? | Rolle existiert (`am_user_id`) · **keine Beispiel-Namen** in Sheets |
| Hunter = Researcher (Hanna, Luca)? | Rolle heisst **"Researcher"**, nicht Hunter · Selektor = `dim_kandidat.created_by_user_id` (CV-Upload-Owner) · Namen nicht in CC |
| Head of (Stefano, Yavor) + Peter? | **Peter bestätigt** als Head of CI & BT · Stefano/Yavor nicht erwähnt · Rolle existiert (`dim_mitarbeiter.role = 'head_of'`) |
| Severina (Recruiter) Commission? | **nicht erwähnt** in CC |
| Nenad? | **nicht erwähnt** in CC |
| Sabrina (Backoffice) keine Commission? | **nicht erwähnt** (plausibel: keine Commission für Backoffice) |

### b) Berechnung heute

| Frage | Antwort |
|-------|---------|
| Excel / Manuell / Altes CRM? | **Excel** bestätigt (2 Beispiel-Sheets Joaquin + Peter existieren) |
| Wer pflegt Formel? | **nicht spezifiziert** im CC |
| Einmalig pro Placement oder laufend? | **Gemischt**: Success Fee einmalig · **Mandats-Stages einzeln** (Peter-Sheet zeigt Stage 1/2/3 als separate Deal-Zeilen) |

### c) Struktur der Splits

| Frage | Antwort |
|-------|---------|
| Fixe % pro Rolle oder pro Mandat verhandelt? | **Default 50/50 AM/CM fix** · Abweichungen selten ("wenn != 50/50") |
| Retainer vs. Success Fee? | Retainer-Stages erscheinen als **separate Deal-Zeilen** (z.B. "Stage 1 Projektleiter HKK" · "Stage 2 Senior PL" · "Stage 3 Michael Vidal"), nicht gebündelt |
| Zusatz-Boni? | **nicht im CC** dokumentiert |
| Claw-back? | **20 %-Rücklage** wird 3 Mt zurückgehalten · bei Austritt gegengerechnet |

### d) Beteiligte pro Placement

| Frage | Antwort |
|-------|---------|
| Typische Konstellation | **2-4 Personen**: 1 CM + 1 AM (kann selbe Person sein) + 1 Researcher (implizit) + evtl. Head of (Rollup) |
| Mehrere Hunter / Split innerhalb | **nicht im CC** (wahrscheinlich 1 Researcher = 1 CV-Upload-Owner) |

### e) Sonderfälle

| Frage | Antwort aus CC |
|-------|------------------|
| MA scheidet während Garantie aus | **20 %-Rücklage** gegengerechnet |
| Kandidat wird in Garantie ersetzt | Garantie-Regel greift (siehe `wiki/concepts/garantiefrist.md`) · Rücklage-Freigabe nicht ausgelöst |

### Offen (nicht im CC beantwortet)

- Zusatz-Boni?
- Wer pflegt Formel heute?
- Namen aller MA in CM/AM/Researcher-Rollen?
- Severina / Nenad / Sabrina Commission-berechtigt?

---

## 4. CRM-Eingangsfelder (bereits spec'd, existieren oder geplant)

Aus CC `wiki/concepts/provisionierung.md` §"CRM-Felder":

| Feld | Tabelle | Status | Zweck |
|------|---------|--------|-------|
| `am_user_id` | `fact_process_finance` | im Schema v1.3 | AM-Zuteilung |
| `cm_user_id` | `fact_process_finance` | im Schema v1.3 | CM-Zuteilung |
| `split_am_pct` + `split_cm_pct` | `fact_process_finance` | im Schema v1.3 | Split-Override |
| `created_by_user_id` | `dim_kandidat` | im Schema v1.3 | Researcher = CV-Uploader |
| `net_fee_chf` | `fact_process_finance` | im Schema v1.3 | Basis |
| `placement_date` | `fact_process_finance` | im Schema v1.3 | Quartals-Zuordnung |
| `sparten_id` | `dim_jobs` | im Schema v1.3 | Head-of-Teambudget-Rollup |
| `guarantee_end_at` | `fact_candidate_guarantee` | im Schema v1.3 | Rücklage-Freigabe |
| `salary_candidate_target_chf` | `fact_process_finance` | im Schema v1.3 | Basis Erfolgsbasis-Staffel |
| `business_model` | `dim_mandate` / `fact_process_finance` | im Schema v1.3 | Time-Ausschluss |

**Status**: Die Eingangs-Seite ist bereits in CRM-1.0-Schema fertig. Die Berechnungs-Engine fehlt — genau der Scope des Handoff-Option-D.

---

## 5. Empfehlung · Wie weiter?

### 5.1 Erforderliche Peter-Entscheidungen VOR Commission-Engine-Spec

**A. Scope-Konflikt auflösen:**
Peter, bitte explizit bestätigen:

> "Ja, die Web-Session (Option D) überschreibt die bisherige Regel 'Provisions-Engine = CRM 2.0'. Commission-Engine wird Phase 1 Kern-USP. Die alte Scope-Warnung in `wiki/concepts/provisionierung.md` §'Out-of-Scope CRM 1.0' gilt nicht mehr. Memory `project_commission_model.md` ist überholt und wird auf den neuen Scope angepasst."

**B. Rollen-Klarheit ("Hunter" vs. "Researcher"):**
Web-Session-Handoff verwendet "Hunter", CC verwendet "Researcher". Welche Bezeichnung soll die Spec verwenden?
- Option 1: **"Researcher"** (CC-konsistent, `dim_kandidat.created_by_user_id` bleibt)
- Option 2: **"Hunter"** (Web-Session-konsistent, Rename in Schema nötig)

**C. Head-of-Rolle im Handoff integrieren:**
Handoff erwähnt Head-of nicht. Die Spec muss trotzdem Head-of-Teambudget-Rollup unterstützen (Peter ist selber Head of). Bestätigen?

**D. Offene Rollen-Fragen (Handoff §6.4):**
- Bekommen Severina (Recruiter) und Nenad Commission?
- Sabrina (Backoffice) definitiv nicht?
- Stefano und Yavor als Head of bestätigt?

### 5.2 Sobald Peter bestätigt: Spec-Struktur

Ich würde `ARK_COMMISSION_ENGINE_SPEC_v0_1.md` wie folgt aufbauen:

1. **Scope + Rollen** (basierend auf Peter-Antworten A-D)
2. **Datenmodell**:
   - Neue Tabellen: `fact_commission_ledger` (append-only), `dim_commission_year` (Jahres-Budgets + OTE je MA), `dim_commission_staffel` (ZEG-Mapping)
   - Erweiterungen: Keine (Input-Felder sind bereits da)
3. **Berechnungs-Engine**:
   - **Researcher-Pauschale**: Lookup-Regel pro Placement
   - **CM/AM-ZEG-Engine**: Quartalsweise Kumulation + Staffel-Lookup + 80/20-Split
   - **Head-of-Teambudget-Engine**: Sparten-Rollup + ZEG-Staffel
   - **Time-Sonderregel**: Ausschluss von Teambudget-ZEG
4. **UI-Scope**:
   - Mitarbeiter-View: eigene Commission (Quartals-Saldo, Auszahlungs-Prognose, Rücklage-Counter)
   - Head-of-View: Team-Aggregation + ZEG
   - Admin/Backoffice-View: Auszahlungs-Workflow + CSV/Excel-Export
   - Simulations-UI: "was-wäre-wenn-Deal X noch in Q hinzukäme"
5. **Export-Schicht (provider-neutral)**:
   - CSV / Excel / XML
   - **KEIN Bexio-API-Call** (Peter-Korrektur §5.1 Handoff)
6. **Event-Modell**:
   - `commission_calculated`, `commission_approved`, `commission_paid`, `reserve_released`, `reserve_clawed_back`
7. **RBAC**:
   - MA-Self: eigene Commission
   - Head of: Team-Commission
   - Backoffice: alle + Export
   - Admin: alle + Staffel-Config-Edit

### 5.3 Alternative · Light-Weg falls Peter Scope-Konflikt anders löst

Falls Peter die **alte** Regel (CRM 1.0 = nur Eingangsfelder) beibehalten will:
- Commission-Engine-Spec wird Phase-2-Dokument
- Für Phase 1: nur Input-Felder-Verfeinerung + Export-CSV in Excel-kompatiblem Format (sodass Peter weiter Excel-Sheets nutzt)
- Option D bleibt strategisches Ziel, aber gestaffelt

Meine **Empfehlung**: Option D wie im Handoff · alte Regel bewusst aufheben · Full-Engine in Phase 1 · Memory `project_commission_model.md` entsprechend updaten.

---

## 6. Concrete Action Items

### Von Peter erwartet (heute/morgen)

1. ✅ **Scope-Bestätigung** (5.1 A)
2. ✅ **Rollen-Namenskonvention** (5.1 B)
3. ✅ **Head-of-Rolle bestätigt** (5.1 C)
4. ✅ **Rollen-Liste** (5.1 D)
5. ⚠ Optional: fehlende CC-Fragen beantworten (Zusatz-Boni, etc.)

### Von mir (Claude Code) nach Peter-Freigabe

1. Memory `project_commission_model.md` updaten (neue Scope-Grenze)
2. `wiki/concepts/provisionierung.md` updaten (Out-of-Scope-Absatz neu)
3. `ARK_COMMISSION_ENGINE_SPEC_v0_1.md` schreiben (800-1200 Zeilen)
4. `ARK_DATABASE_SCHEMA_PATCH_v1_3_to_v1_4.md` updaten (oder v1_4_to_v1_5) mit `fact_commission_ledger` etc.
5. `ARK_HR_STRATEGY_DECISION_v0_1.md` → v1.0 Freeze mit Peter-Korrekturen (Handoff §5)
6. Nach Spec-v0.1: Mockup für Commission-Views (analog Dashboard-First-Stil wie HR)

---

## 7. Zusätzliche Fragen aus CC-Lektüre

Nicht im Handoff §6.4 aufgeführt, aber aus CC-Analyse entstanden:

**Q7.1** — `dim_commission_year` pro MA pro Jahr: **Budget + OTE** sind gesetzt oder kommen aus Vertrag?
→ Aus Vertrag: Wenn ja, fehlt das Feld in `fact_employment_contracts` (siehe HR-Plan v0.1) oder wird separater Commission-Contract?

**Q7.2** — **Pro-Rata** bei Untermonats-Anstellung (Provisionierung.md Section 2): wie wird das berechnet? Tage oder Monate?

**Q7.3** — **Rücklage-Mechanik**: Wenn MA im Q2 startet, Placement in Q3, Garantie-Ende in Q4 → wann wird Rücklage frei?

**Q7.4** — **Claw-back-Granularität**: Voll-Rückzahlung bei Kandidat-Austritt am Tag 89 vs. 91?

**Q7.5** — **Mehrere AM/CM pro Placement** (theoretisch): Aktuell `am_user_id` + `cm_user_id` sind **Single-FKs**. Brauchen wir `bridge_process_commission_roles` für Multi-Assignee?

**Q7.6** — **Staffel-Versionierung**: Bleibt die Staffel statisch oder ändert sich pro Jahr?

**Q7.7** — **Retainer/Mandats-Stage-Zahlungen**: Wie werden diese im CRM 1.0 als Deal-Zeilen erfasst? Gibt es `fact_mandate_stage_payment` oder werden sie als separate Placements modelliert?

**Q7.8** — **Time-Sonderfall**: Peter-Sheet sagt "ausserordentlich abgerechnet" aber "Mechanik in CRM 2.0 noch offen" → soll Commission-Engine v0.1 das schon abdecken oder v0.2?

---

## 8. Status

**Ich warte auf Peter-Antworten zu 5.1 A-D** bevor ich die Commission-Engine-Spec schreibe. Ohne Scope-Klarheit und Rollen-Präzision würde die Spec auf Sand gebaut — genau die Situation, die die Web-Session mit "schiessen ins Blinde" beschrieben hat.

Alternativ: Peter entscheidet für Fast-Track und ich schreibe Spec v0.1 auf Basis der **CC-Dokumente-Wahrheit** (Memory-überholt-Annahme) und markiert **alle Annahmen explizit** als "TBC-Peter".

---

## Related

- `wiki/concepts/provisionierung.md` — authoritativer Commission-Scope
- `wiki/sources/anhang-provisionsstaffel-cm.md` — ZEG-Staffel
- `wiki/sources/provisionssheet-joaquin.md` — CM-Beispiel
- `wiki/sources/provisionssheet-peter.md` — Head-of-Beispiel
- `memory/project_commission_model.md` — Memory (überholt wenn Option D bestätigt)
- Künftig: `ARK_COMMISSION_ENGINE_SPEC_v0_1.md` (nach Peter-Freigabe)
- Künftig: `ARK_HR_STRATEGY_DECISION_v1_0.md` (Freeze mit Peter-Korrekturen)
