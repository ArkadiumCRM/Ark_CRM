---
title: "ARK HR-Strategie · Build/Buy-Entscheidung · FROZEN v1.0"
type: decision
phase: 3
created: 2026-04-19
version: v1.0
status: frozen
freezes: "ARK_HR_STRATEGY_DECISION_v0_1.md"
sources_in: [
  "ARK_HR_RESEARCH_SYNTHESE_v0_1.md",
  "ARK_LUCCA_EVALUATION_v0_1.md",
  "ARK_SWISSDECTX_EVALUATION_v0_1.md",
  "ARK_HR_TOOL_RESEARCH_v0_1.md (Claude Code Pass 1)",
  "ARK_HR_TOOL_RESEARCH_v0_2.md (Claude Code Pass 2)",
  "wiki/concepts/provisionierung.md (authoritativ)",
  "wiki/sources/provisionssheet-peter.md",
  "wiki/sources/provisionssheet-joaquin.md",
  "Peter-Handoff 2026-04-19 mit Korrekturen",
  "Peter-Rollen-Liste 2026-04-19"
]
tags: [decision, strategy, hr, commission-first, option-d, frozen]
---

# ARK HR-Strategie · Build/Buy-Entscheidung · FROZEN v1.0

> **Status: gefroren am 2026-04-19**
> Ersetzt den v0.1-Draft aus der Web-Session. Korrigiert 3 Peter-Feedbacks:
> 1. **40/30/30 CM/AM/Hunter** war Platzhalter · real: 3+1 Rollen mit unterschiedlichen Modellen
> 2. **Bexio-API-Integration Phase 1** gestrichen · CSV/Excel/XML-Export reicht Phase 1
> 3. **Phase-2-Timing** bewusst offen

---

## TL;DR (korrigiert)

**Entscheidung: Option D · Commission-First, HR-Lean.**

Commission-Engine ist **Phase 1 Kern-USP** des ARK-CRM. Überschreibt frühere "Provisions-Engine = CRM 2.0"-Regel. ARKs echte Marktlücke: CH-Boutique-Headhunter haben kein natives Commission-Split-Tool.

**Concrete (korrigiert):**
- **Phase 1 (jetzt – offen):** ARK-intern bleibt bei Treuhänder/Bexio für Payroll. ARK-CRM fokussiert auf **Commission-Engine** (3+1 Rollen) + minimales HR-Data-Layer.
- **Phase 2 (Timing offen):** ARK-CRM als SaaS für Boutique-Headhunter. USPs: Commission-Engine · Dark Mode · Keyboard-First · ES-spezifische Entitäten.
- **Phase 3 (30+ Monate):** Re-Evaluation auf Basis echter Kunden-Feedback.

**Was NICHT gebaut wird:**
- ❌ Eigene Swissdec-zertifizierte Payroll
- ❌ Eigene Zeiterfassung mit Fingerprint in Phase 1
- ❌ BVG/UVG/KTG-Integration
- ❌ Quellensteuer-Tarif-Engine
- ❌ **Aktiver Bexio-API-Call in Phase 1** (Peter-Korrektur Handoff §5.1)
- ❌ AHV/IV/EO/ALV-Berechnung

**Was gebaut wird (korrigiert gegen v0.1 · real ARK-Struktur):**
- **Commission-Engine mit 3+1 Rollen-Modellen**:
  - Researcher: Pauschale CHF 250-750 pro Placement
  - CM/AM: 50/50-Split mit ZEG-Staffel · 80/20 Abschlag/Rücklage · quartalsweise
  - Head of: Teambudget-Rollup über Sparten · gleiche ZEG-Staffel
  - Assessment Manager (NEU · Modell TBC): Severina-Rolle
- **Sonder-Flow Bonus-Ermessen**: Geschäftsführer self-approval · Backoffice GF-Approval
- **HR-Data-Layer minimal**: `dim_mitarbeiter`, `dim_employment`, `dim_assignment`, `bridge_mitarbeiter_roles`, `fact_goals`
- **CSV/Excel/XML-Export-Schicht** (provider-neutral, Treuhänder-kompatibel)
- **Später (Phase 2):** Partner-Integrationen mit API-Calls zu Bexio/Abacus/SwissSalary

---

## 1. Die vier Optionen · Summary

Detail siehe v0.1. Ergebnis: **Option D gewählt**.

| Option | TCO 5J | SaaS-Potenzial | Entscheidung |
|--------|--------|----------------|--------------|
| A · Full Custom Build | CHF 179-347k | Hoch | ❌ 24-36 Mt Ablenkung |
| B · Hybrid (Lucca intern + Partner SaaS) | CHF 7-12k | Hoch | ⚠️ Valide Backup |
| C · Wait + Abacus | CHF 11-16k | Keins | ❌ kein SaaS-Play |
| **D · Commission-First, HR-Lean** | **CHF 15-30k intern · SaaS-Revenue ab Jahr 4-5** | **Sehr hoch** | **✅ GEWÄHLT** |

---

## 2. Warum Option D · 3 Research-Konvergenz-Punkte

1. **Research-Synthese (8 Grauzonen einstimmig)**: Lohnabrechnung · Spesen · Weiterbildung · alle empfehlen Partner-Integration, nicht Eigenbau
2. **Lucca-Evaluation**: Partner-Integration-Architektur markterprobt · HR-SaaS-Markt gesättigt · Differenzierung schwierig
3. **SwissDecTX-Evaluation**: Eigene Swissdec-Zert = 18-24 Mt Business-Logik-Entwicklung · nicht lohnend

**Echte Marktlücke**: Bullhorn · Invenias · Salesforce haben keine native CM/AM-Commission-Logik · Bexio/Abacus kennen Headhunter-Commissions nicht · Lucca/Personio/BambooHR haben keine Commission-Engine.

---

## 3. Commission-Engine · echte ARK-Struktur (Peter-Input 2026-04-19)

### 3.1 Rollen-Modell · 3+1

| Rolle | Modell | Quellen-Dokument |
|-------|--------|---------------------|
| **Researcher** | CHF 250-750 Pauschale pro Placement · Owner = `dim_kandidat.created_by_user_id` | `provisionierung.md` §"Researcher" |
| **CM / AM** | Jahresbudget CHF 360k-700k · 50/50-Split pro Placement · ZEG-Staffel · 80/20 · quartalsweise | `provisionierung.md` §"CM/AM" + `anhang-provisionsstaffel-cm.md` |
| **Head of** | Teambudget (Sparten-Rollup) · CHF 1.0-1.5M+ · gleiche Staffel · volle Anteile (Pkt 2) | `provisionierung.md` §"Head of" |
| **Assessment Manager (NEU)** | Modell TBC · nach Peter-Klärung | Severina-Rolle · offen |

### 3.2 Sonder-Regelungen

**Geschäftsführer (Nenad Stoparanovic)**: nicht provisionsberechtigt · Bonus nach Ermessen (self-approval).

**Backoffice (Sabrina Tanner · Severina-BO-Teil)**: nicht provisionsberechtigt · Bonus nach GF-Ermessen.

### 3.3 ARK-Mitarbeiter-Matrix (12 MA · Stand 2026-04-19)

**Active (10)**:
PW Peter Wiederkehr (Head of CI+BT, CM, AM, Admin · Commission = Head-of-Teambudget) · YB Yavor Bojkov (Head of, CM, AM) · SP Stefano Papes (Head of) · NS Nenad Stoparanovic (GF, Admin · Bonus-Ermessen) · ST Sabrina Tanner (Backoffice · Bonus-Ermessen) · SN Severina Nolan (Assessment Manager, Backoffice · Modell TBC) · JV Joaquin Vega (CM, AM · 50/50+ZEG · Budget 440k) · NP Nina Petrusic (CM · 50/50+ZEG) · HvdB Hannah van den Bosch (Researcher · Pauschale) · LRR Luca Rochat Rammuno (Researcher · Pauschale).

**Ab 01.05.2026 (+2)**:
SBS Sonja Bee Spiess (CM · 50/50+ZEG · pro rata 8/12) · IV Iris Ventura (Researcher · Pauschale).

**Total 2026: 12 MA** (10 → 12 ab 01.05.) · **10 prov.-berechtigt** (+ Severina TBC) · **2 nicht prov.-berechtigt** (NS · ST).

Detail siehe Memory `project_arkadium_roles_2026.md` + Spec `ARK_COMMISSION_ENGINE_SPEC_v0_1.md`.

---

## 4. Was konkret gebaut wird (Phase 1)

### 4.1 Commission-Engine · Umfang

| Feature | Priorität | Wave | Quelle |
|---------|:-:|:-:|--------|
| Commission-Rules-Engine (3+1 Rollen-Modelle · **kein** 40/30/30) | P0 | 1 | `ARK_COMMISSION_ENGINE_SPEC_v0_1.md` §3 |
| Provisions-Override pro Mandat (split_am/cm_pct) | P0 | 1 | `fact_process_finance` existiert |
| Split-Simulation UI (was-wäre-wenn) | P0 | 1 | Spec §4.5 |
| **CSV/Excel/XML-Export (provider-neutral, KEIN Bexio-API)** | P0 | 2 | Peter-Korrektur Handoff §5.1 |
| Commission-Ledger (append-only, Audit) | P1 | 2 | Spec §2.2 · `fact_commission_ledger` |
| Commission-Reports (MA-Self · Head-of · Admin) | P1 | 3 | Spec §7 |
| Claw-back-Logik (Garantie-Breach) | P1 | 3 | Spec §3.5 |
| Quartals-/Jahres-Abschluss mit Snapshot | P2 | 4 | Spec §4.2 |
| Bonus-Ermessen-Flow (GF · BO) | P2 | 4 | Spec §4.4 |
| Dashboards + Power BI | P2 | 4 | Phase 2 |

### 4.2 HR-Data-Layer · Minimal-Scope

| Entität | Status | Notes |
|---------|:-:|------|
| `dim_mitarbeiter` | ✅ existiert | Basis-Stammdaten · wird erweitert um `commission_primary_role` + `head_of_sparten[]` |
| `dim_employment` | ⏳ neu | Vertragshistorie |
| `dim_assignment` | ⏳ neu | Desk-Zuordnung, Sparte, Team |
| `bridge_mitarbeiter_roles` | ✅ existiert | Multi-Role · wird erweitert um `assessment_manager` |
| `fact_goals` | ✅ existiert | Ziele, KPIs |
| `fact_commission_ledger` | ⏳ neu | Append-only |
| `dim_commission_year` | ⏳ neu | Budget+OTE je MA je Jahr |
| `dim_commission_staffel` | ⏳ neu | Versionierte ZEG-Mappings |
| `fact_researcher_fee` | ⏳ neu | Pauschalen |
| `fact_bonus_payment` | ⏳ neu | Ermessens-Boni |
| `fact_commission_batch` | ⏳ neu | Quartals-Batches |
| `fact_ruecklage_release` | ⏳ neu | Rücklage-Mechanik |
| `fact_absences` | 🔜 Phase 2 | — |
| `fact_timesheet` | 🔜 Phase 3 | Erst mit 3CX/Mobile |

### 4.3 Was explizit NICHT gebaut wird (Phase 1)

- ❌ Eigene Lohnberechnung (Brutto/Netto)
- ❌ AHV/ALV/BVG/UVG/KTG/FAK-Integration
- ❌ Quellensteuer-Tarif-Engine (26 Kantone)
- ❌ Lohnausweis-Formular 11 Generierung
- ❌ Swissdec-ELM-Transmitter
- ❌ **Aktiver Bexio-API-Call** (Peter-Korrektur · CSV-Export reicht)
- ❌ Zeiterfassung mit Fingerprint (Phase 3+)
- ❌ Performance-Reviews-Modul (nutzt Goals + Jahresgespräche ausserhalb)
- ❌ Weiterbildungs-Katalog

---

## 5. Was konkret gebaut wird (Phase 2 · Timing offen)

### 5.1 SaaS-USPs

1. Commission-Engine mit konfigurierbaren Split-Rules pro Kunde
2. Dark Mode + Keyboard-First (Rippling-ähnlich)
3. Command Palette (kein CH-HR-Tool hat das)
4. ES-spezifische Entitäten (Mandat · Placement · Desk)
5. Multi-Tenant RLS (Härtung)

### 5.2 Partner-Integrationen · korrigierte Prio

| Partner | Integration | Priorität (korrigiert) |
|---------|-------------|:-:|
| **Treuhänder-generic (CSV)** | CSV-Template | **P0 · Phase 2** (Primär) |
| **Bexio** | REST-API (bLink) | **P1 · Phase 2** (Peter-Korrektur: von P0 auf P1 gerückt) |
| **Abacus** | AbaConnect XML | P1 · Phase 2 |
| **SwissSalary** | Excel-Import-Format | P1 · Phase 2 |
| **KLARA** | CSV-Export | P2 · Phase 2 |
| **Lucca** | REST-API oder CSV | P2 · Phase 2 |

**Architektur-Prinzip**: ARK-CRM exportiert Commission-Daten in standardisiertem Format · Provider-spezifische Adapter transformieren. Keine direkte Kopplung.

---

## 6. Phase-3-Entscheidungspunkte (30+ Monate)

Nach echtem Kunden-Feedback. Details in v0.1 §6 (unverändert).

- **3A**: HR-Modul ausbauen (Leave, Documents, Reviews)
- **3B**: White-Label mit Lucca/Personio
- **3C**: Eigene Swissdec-Payroll als Premium-Feature

**Trigger**: Nicht vor Jahr 3.

---

## 7. Risiken · korrigiert

| Risiko | W | I | Mitigation |
|--------|:-:|:-:|-----------|
| Commission-Engine-Komplexität unterschätzt | Mittel | Hoch | Option-Präsentation-Pattern, externe Reviews |
| Migrations-Fehler aus Excel | Mittel | Hoch | 3-6 Mt Parallel-Betrieb |
| ZEG-Staffel-Bug | Niedrig | Sehr hoch | Unit-Tests gegen Peter + Joaquin Sheets |
| Boutique-Kunden wollen doch Full-Suite | Mittel | Mittel | Pfad 3A/3B hält Option offen |
| Wettbewerber baut Commission-Engine | Niedrig | Hoch | Domain-Expertise + ES-Netzwerk als Burggraben |
| Assessment-Manager-Modell unklar | Hoch | Niedrig | TBC flagen, P1.7 nach Klärung |
| Clawback bei Multi-Role-Wechsel | Niedrig | Mittel | Event-sourced, idempotent |

---

## 8. Konkrete nächste Schritte (v1.0 Post-Freeze)

### 8.1 Sofort (Peter + Claude Code)

1. ✅ Strategy v1.0 freezen (dieses Dokument)
2. ⏳ Commission-Engine-Spec v0.1 reviewen (bereits geschrieben: `ARK_COMMISSION_ENGINE_SPEC_v0_1.md`)
3. ⏳ Assessment-Manager-Modell klären (Peter-Rückfrage)
4. ⏳ Yavor/Stefano Head-of-Sparten-Scope klären
5. ⏳ Grundlagen-Sync starten (5 Files patchen)

### 8.2 Kurzfristig (1-3 Monate)

1. Schema v1.4 mit neuen Tabellen (siehe Spec §2)
2. 3-Layer-Audit nach Schema-Round
3. Commission-Engine-Mockups (4 HTML-Files)
4. Excel-Migration-Script
5. QA-Parallel-Lauf starten

### 8.3 Mittelfristig (3-12 Monate)

1. Commission-Engine Wave 1+2 Backend+Frontend
2. ARK-intern Go-Live (Alpha)
3. Ledger-Features (Wave 3)
4. Quartals-Abschluss automatisiert

### 8.4 Langfristig (12+ Monate)

1. SaaS-Beta mit 3-5 Pilot-Boutiquen
2. Partner-Integrationen (CSV first · Bexio-API second)
3. Pricing-Modell
4. Treuhänder-Partner-Programm
5. Phase-3-Entscheidung (3A · 3B · 3C)

---

## 9. Peter-Antworten zu v0.1 offenen Fragen

v0.1 §10 hatte 3 Fragen. Antworten:

1. **Bexio-Lohn-Modul**: *nicht geklärt · vermutlich noch nicht gebucht* · Peter-Korrektur: **kein aktiver Bexio-API-Call in Phase 1** · Bexio-Abo-Entscheidung erst bei Phase-2-API-Integration
2. **Commission-Rules heute**: Excel · Peter-Sheet + Joaquin-Sheet sind authoritativ · CC-Dokumente `wiki/concepts/provisionierung.md` + `anhang-provisionsstaffel-cm.md` validiert
3. **Phase-2-Timing**: bewusst offen · Qualität vor Geschwindigkeit

---

## 10. Neue offene Fragen (post-v1.0)

Aus Commission-Engine-Spec §12 (weitergeleitet für weitere Peter-Review):

1. Assessment-Manager-Modell (Pauschale · CM-50/50 · %-vom-Assessment-Honorar)
2. Yavor Bojkov Head-of-Sparten
3. Stefano Papes Head-of-Sparten
4. Researcher-Pauschale-Algorithmus (auto-500 · manuell Head-of-Approval)
5. Bonus-Ermessen-Limit pro Quartal für GF-Self-Approval
6. Migration-Startpunkt (nur 2026 · auch 2025)
7. Quartals-Abschluss-Freezing (nachträgliche Änderungen erlaubt?)

---

## 11. Freeze-Criteria · erfüllt

- [x] TL;DR und Empfehlung inhaltlich geprüft (Peter-Korrekturen eingearbeitet)
- [x] Vergleichsmatrix validiert (TCO aus Claude Pass 2)
- [x] Phase-1-Scope-Liste geprüft (gebaut · nicht gebaut)
- [x] Partner-Prio-Liste in Phase 2 validiert (Bexio von P0 auf P1 · Peter-Korrektur)
- [x] Phase-3-Pfade als valide bestätigt
- [x] Explizite Entscheidung: **"Option D ist die Strategie"** · Peter 2026-04-19
- [x] Rollen-Liste vervollständigt (12 MA · Peter-Input 2026-04-19)
- [x] Commission-Engine-Spec v0.1 abgeleitet

---

## Related

- `ARK_HR_RESEARCH_SYNTHESE_v0_1.md` — Research-Synthese
- `ARK_LUCCA_EVALUATION_v0_1.md` — Lucca Vendor-Eval
- `ARK_SWISSDECTX_EVALUATION_v0_1.md` — SwissDecTX Infrastruktur-Eval
- `ARK_HR_TOOL_RESEARCH_v0_1.md` + `v0_2.md` — Claude Code Pass 1+2
- `ARK_COMMISSION_ENGINE_SPEC_v0_1.md` — Detail-Spec (abgeleitet)
- `ARK_COMMISSION_ABGLEICH_HANDOFF_v0_1.md` — Abgleich CC-Docs vs Handoff
- `wiki/concepts/provisionierung.md` — authoritative Commission-Logik (Scope updated)
- `memory/project_commission_model.md` — Scope-Regel Update
- `memory/project_arkadium_roles_2026.md` — MA-Matrix
- Künftig: `ARK_HR_TOOL_PLAN_v0_2.md` — Kurz-Roadmap (optional)

---

**FROZEN 2026-04-19** · Updates nur via Versionssprung (v1.1 · v2.0).
