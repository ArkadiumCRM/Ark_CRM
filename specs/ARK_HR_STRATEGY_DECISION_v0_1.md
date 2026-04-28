---
title: "ARK HR-Strategie · Build/Buy-Entscheidung"
type: decision
phase: 3
created: 2026-04-19
version: v0.1
status: draft-for-peter-review
sources_in: ["ARK_HR_RESEARCH_SYNTHESE_v0_1", "ARK_LUCCA_EVALUATION_v0_1", "ARK_SWISSDECTX_EVALUATION_v0_1"]
tags: [decision, strategy, hr, build-vs-buy, roadmap]
---

# ARK HR-Strategie · Build/Buy-Entscheidung

> **Zweck:** Nach Abschluss von Research-Synthese + Lucca-Eval + SwissDecTX-Eval wird hier eine finale Richtungsentscheidung formuliert. Das Dokument ist als Vor-Freeze-Dokument gedacht — Peter reviewt, korrigiert, dann Freeze als `v1.0`.

---

## TL;DR

**Empfehlung: Option D — Commission-First, HR-Lean.**

Alle drei Rechercheartefakte (Research-Synthese + Lucca-Eval + SwissDecTX-Eval) konvergieren auf dieselbe Antwort: **ARKs USP ist die Commission-Engine für Executive Search, nicht eine neue HR-Plattform.** Der CH-HR-Markt ist gesättigt mit guten Tools (Bexio, Abacus, Lucca, Personio, SwissSalary). Eine neue HR-Plattform zu bauen ist ein 2–3-Jahres-Ablenkungs-Projekt von der eigentlichen Marktlücke.

**Konkret:**
- **Phase 1 (jetzt – 12 Monate):** ARK-intern bleibt bei Bexio für HR/Payroll. ARK-CRM fokussiert auf **Commission-Engine** + minimales HR-Data-Layer (Stammdaten, Employments, Assignments).
- **Phase 2 (12 – 30 Monate):** ARK-CRM als SaaS für Boutique-Headhunter launchen. USPs: Commission-Engine, Dark Mode, Keyboard-First, ES-spezifische Entitäten. HR-Tooling bleibt Delegation an Partner.
- **Phase 3 (30+ Monate):** Re-Evaluation auf Basis echter Kunden-Feedback. Drei Pfade möglich (siehe Abschnitt 6).

**Was NICHT gebaut wird:**
- Keine eigene Swissdec-zertifizierte Payroll (18–24 Monate Ablenkung)
- Keine eigene Zeiterfassung mit Fingerprint in Phase 1 (später, via 3CX/Mobile)
- Keine BVG/UVG/KTG-Integration
- Keine Quellensteuer-Tarif-Engine

**Was gebaut wird:**
- Commission-Engine mit 40/30/30-Splits (CM/AM/Hunter) und flexiblen Rules
- HR-Data-Layer: `dim_mitarbeiter`, `dim_employment`, `dim_assignment`, `bridge_mitarbeiter_roles`, `fact_goals`
- Bexio-Export-Interface (Commission-Daten → Bexio-Lohnlauf)
- Später: Abstraktionsschicht für weitere Payroll-Provider (Abacus, SwissSalary, Lucca, KLARA)

---

## 1. Die vier Optionen im Überblick

### Option A · Full Custom Build
**Was:** Eigene HR-Plattform inkl. Swissdec-zertifizierter Payroll, Zeiterfassung, Performance, alles.

| Kriterium | Wert |
|-----------|------|
| Entwicklungszeit | 24–36 Monate bis Produktionsreife |
| TCO (5 Jahre) | CHF 179'000 – 347'000 |
| Swissdec-Mitgliedschaft | CHF 11'000 / Jahr fix |
| Zertifizierungs-Audit | CHF 15–25'000 einmalig |
| Differenzierungspotenzial | Hoch (volle Kontrolle) |
| SaaS-Marktrisiko | Sehr hoch — ARK konkurriert mit Bexio, Abacus, Lucca, Personio |

**Pro:**
- Volle Kontrolle über UX, Integration, Commission-Logik
- Keine Partner-Abhängigkeiten
- Potenziell höhere Marge in SaaS Phase 2

**Contra:**
- 24–36 Monate ohne Umsatz aus neuem Modul
- Ablenkung vom eigentlichen USP (Commission-Engine)
- HR-Markt ist **hart umkämpft** — Differenzierung schwer
- nDSG/Swissdec-Compliance = Vollzeit-Engineering-Aufwand
- SwissDecTX hilft nur beim Transmitter, nicht bei der Business-Logik (= 18–24 Monate)

**Wer das wählt:** Bau- und HR-Tech-Unternehmen mit existierendem HR-Markt-Know-how. **Nicht ARK.**

---

### Option B · Hybrid (Externes HR intern + Partner-Integration SaaS)
**Was:** Lucca (oder Personio) für ARK-intern. ARK-CRM konzentriert sich auf Commission + Executive-Search-Features. Bei SaaS-Phase: Partner-Integrationen zu diversen HR-Tools.

| Kriterium | Wert |
|-----------|------|
| Entwicklungszeit | 0 Monate für HR (Lucca direkt einsatzbereit) |
| TCO (5 Jahre) intern | CHF 7'200 – 12'000 (Lucca 10 MA à ~CHF 120–200/Mt) |
| ARK-CRM-Investment | Unverändert |
| Differenzierungspotenzial | Hoch (Commission + ES-Features) |
| SaaS-Marktrisiko | Niedrig — keine direkte Konkurrenz zu HR-Tools |

**Pro:**
- Sofort einsetzbar für ARK-intern (~4–8 Wochen Setup)
- Lucca-Eval hat bestätigt: CH-Hosting, gute UX, modular
- ARK kann sich voll auf Commission-Engine + ES-Features konzentrieren
- Geringe Wechselkosten bei Vendor-Problemen

**Contra:**
- **Vendor-Risiko** (M&A, Preiserhöhungen, Pento→HiBob-Muster)
- Lucca's Payroll-Integration-Qualität ist laut Reviews holprig
- Doppelte Datenhaltung (ARK-CRM + Lucca)
- Paket-Pricing intransparent
- Dark Mode fehlt bei Lucca → Bruch im ARK-UX

**Wer das wählt:** Boutique mit schneller Zeit-bis-Wert-Anforderung, akzeptiert Vendor-Abhängigkeit. **Valide für ARK**, aber Option D ist strategischer.

---

### Option C · Wait + Abacus
**Was:** Bexio für ARK-intern behalten. Bei 20+ MA oder SaaS-Traction zu Abacus migrieren (Deutschschweiz-Marktführer).

| Kriterium | Wert |
|-----------|------|
| Entwicklungszeit | 0 Monate |
| TCO (5 Jahre) | CHF 11'000 – 16'000 (Bexio heute, Abacus ab Jahr 3) |
| ARK-CRM-Investment | Minimal |
| Differenzierungspotenzial | **Sehr niedrig** |
| SaaS-Marktrisiko | N/A (kein SaaS-Play) |

**Pro:**
- Billigste Option
- Bexio läuft bereits, kein Umstellungsrisiko
- Abacus ist Deutschschweiz-KMU-Standard (bekannt, zertifiziert)

**Contra:**
- **Kein SaaS-Play** — Option C bedeutet implizit: ARK-CRM bleibt intern
- Keine Differenzierung gegenüber Wettbewerb
- Phase-2-Potenzial wird aufgegeben

**Wer das wählt:** ARK als reiner Headhunter-Boutique ohne SaaS-Ambition. **Nicht Peters Vision.**

---

### Option D · Commission-First, HR-Lean (Empfohlen)
**Was:** ARK-CRM baut Commission-Engine als Kern-USP. HR bleibt Data-Layer (ohne Payroll-Logik). ARK-intern nutzt Bexio. SaaS-Phase 2 mit Fokus auf Commission + ES-Features. Phase 3 offen für HR-Ausbau.

| Kriterium | Wert |
|-----------|------|
| Entwicklungszeit Phase 1 | 3–6 Monate (Commission-Engine + HR-Data-Layer) |
| TCO Phase 1 (ARK-intern) | ~CHF 600/Jahr Bexio + ARK-CRM-Entwicklung |
| TCO Phase 2 (SaaS-Kunden) | N/A (Umsatzseite) |
| Differenzierungspotenzial | **Sehr hoch** (Commission-Engine = Marktlücke) |
| SaaS-Marktrisiko | Niedrig (klare USP-Kante) |

**Pro:**
- **Fokus auf echte Marktlücke** (Commission-Splits für ES-Boutiquen)
- Phase 1 schnell umsetzbar (3–6 Monate)
- Bewahrt Flexibilität für Phase 3 (alle Pfade bleiben offen)
- HR-Markt wird nicht angegriffen (= weniger Konkurrenten, weniger Compliance)
- Treuhänder-Ökosystem wird nicht bedroht → potenzielle Partner statt Konkurrenten

**Contra:**
- Boutique-Kunden müssen selbst HR-Tooling haben (Bexio, Abacus oder Treuhänder)
- Kein One-Stop-Shop — setzt Partner-Integrationen voraus
- Phase-2-Umsatz niedriger pro Kunde als bei Full-Suite

**Wer das wählt:** ARK. Es ist die einzige Option, die den tatsächlichen USP (Commission-Engine + ES-Domain-Expertise) in den Mittelpunkt stellt, ohne in den gesättigten HR-Markt zu laufen.

---

## 2. Vergleichsmatrix

| Kriterium | A: Full Build | B: Hybrid | C: Wait+Abacus | **D: Commission-First** |
|-----------|:-:|:-:|:-:|:-:|
| Time-to-Value intern | 24–36 Mt | 1–2 Mt | Sofort | **3–6 Mt** |
| TCO 5 Jahre (ARK-intern) | CHF 179–347k | CHF 7–12k | CHF 11–16k | **CHF 15–30k** |
| SaaS-Potenzial | Hoch | Hoch | Keins | **Hoch** |
| Differenzierung SaaS | Mittel | Hoch | N/A | **Sehr hoch** |
| Vendor-Risiko | — | Hoch (Lucca) | Mittel (Abacus) | **Niedrig** |
| Swissdec-Zertifizierung nötig? | Ja | Nein | Nein | **Nein** |
| ARK-Fokus gewahrt? | ❌ | ✅ | ✅ | **✅✅** |
| nDSG/Compliance-Burden | Hoch | Mittel | Niedrig | **Niedrig** |
| Flexibilität Phase 3 | Niedrig (gebunden) | Mittel | Niedrig | **Hoch** |
| **Passt zu ARK?** | Nein | Ja (konditional) | Nein | **Ja (optimal)** |

---

## 3. Warum Option D?

### 3.1 · Drei Researchartefakte — dieselbe Antwort

1. **Research-Synthese (8 Grauzonen unanimously decided):** Lohnabrechnung, Spesen, Weiterbildung — alle Researches empfehlen **Partner-Integration**, nicht Eigenbau.

2. **Lucca-Evaluation:** Lucca validiert die Partner-Integration-Architektur ("Payroll Assistant") und beweist, dass es am Markt funktioniert. Gleichzeitig zeigt Lucca, dass **HR-SaaS hart umkämpft** ist — Differenzierung schwierig.

3. **SwissDecTX-Evaluation:** Eigene Swissdec-Zertifizierung wäre 18–24 Monate Business-Logik-Entwicklung + CHF 11k/Jahr Mitgliedschaft. SwissDecTX ersetzt nur den Transmitter-Teil, nicht die Logik. **Kein sinnvoller Shortcut.**

### 3.2 · Die echte Marktlücke ist nicht HR

CH-Boutique-Headhunter (5–50 MA) haben **keine** guten Commission-Engine-Tools:
- **Bullhorn, Invenias, Salesforce:** Keine native CM/AM/Hunter-Split-Logik
- **Bexio, Abacus:** Keine Headhunter-Commission-Tabellen
- **Lucca, Personio, BambooHR:** Keine Commission-Engine

Das ist ARKs echte Marktlücke. Die HR-Seite ist längst von etablierten Anbietern besetzt.

### 3.3 · Strategische Eleganz

Option D **bewahrt alle Optionen** für Phase 3:
- Kunden-Feedback könnte zeigen, dass HR-Integration gewünscht ist → Option B kann später aktiviert werden
- Kunden-Feedback könnte zeigen, dass Payroll gewünscht ist → Option A kann als Premium-Feature später gebaut werden
- Kunden-Feedback könnte zeigen, dass reine Commission-Engine reicht → aktuelle Strategie bleibt

Option A, B, C sind dagegen **committed** — Wechsel kostet.

---

## 4. Was konkret gebaut wird (Phase 1)

### 4.1 · Commission-Engine · Kernumfang

| Feature | Priorität | Wave |
|---------|:-:|:-:|
| Commission-Rules-Engine (CM 40% / AM 30% / Hunter 30% als Default) | P0 | 1 |
| Provisions-Override pro Mandat / Fee-Tier / Bonus | P0 | 1 |
| Split-Simulation UI (was wäre wenn…) | P0 | 1 |
| Bexio-Export (CSV + XML je nach Bexio-API-Option) | P0 | 2 |
| Commission-Ledger (History, Audit, Unveränderbarkeit) | P1 | 2 |
| Commission-Reports (Mitarbeiter-View, Desk-View, Jahres-View) | P1 | 3 |
| Claw-back-Logik (bei vorzeitigem Austritt des Kandidaten) | P1 | 3 |
| Quartals-/Jahres-Abschluss mit Snapshot | P2 | 4 |
| Dashboards + Power BI-Integration | P2 | 4 |

### 4.2 · HR-Data-Layer · Minimal-Scope

| Entität | Status | Notes |
|---------|:-:|------|
| `dim_mitarbeiter` | ✅ existiert | Basis-Stammdaten |
| `dim_employment` | ⏳ neu | Vertragshistorie (Pensum, Rolle, Start/Ende) |
| `dim_assignment` | ⏳ neu | Desk-Zuordnung, Sparte, Team |
| `bridge_mitarbeiter_roles` | ✅ existiert | Multi-Role-Support |
| `fact_goals` | ✅ existiert | Ziele, KPIs |
| `fact_commission` | ⏳ neu | Commission-Berechnung-Ledger |
| `fact_absences` | 🔜 Phase 2 | Nice-to-have, kein Blocker |
| `fact_timesheet` | 🔜 Phase 3 | Erst mit 3CX/Mobile-Integration |

### 4.3 · Was explizit NICHT gebaut wird

- ❌ Eigene Lohnberechnung (Bexio macht das)
- ❌ AHV/ALV/BVG/UVG/KTG/FAK-Integration
- ❌ Quellensteuer-Tarif-Engine
- ❌ Lohnausweis-Generierung
- ❌ Swissdec-ELM-Transmitter
- ❌ Zeiterfassung mit Fingerprint (Phase 3+)
- ❌ Performance-Reviews-Modul (nutzt Goals + Jahresgespräche ausserhalb)
- ❌ Weiterbildungs-Katalog

---

## 5. Was konkret gebaut wird (Phase 2, SaaS)

### 5.1 · SaaS-USPs (Differenzierungs-Features)

1. **Commission-Engine** mit konfigurierbaren Split-Rules pro Kundensegment
2. **Dark Mode** + Keyboard-First-Navigation (Rippling ist heute fast alleine auf diesem Pfad)
3. **Command Palette** (kein Wettbewerber im CH-HR-Markt hat das)
4. **ES-spezifische Entitäten** (Mandat, Placement, Desk, Hunter-Rollen, Retainer-vs-Success)
5. **Multi-Tenant mit RLS** (bewiesene Architektur aus ARK-CRM)

### 5.2 · Partner-Integrationen (nicht eigene Module)

Phase-2-Launch-Plan mit Payroll-Providern:

| Partner | Integration | Priorität |
|---------|-------------|:-:|
| **Bexio** | REST-API (bLink) | P0 |
| **Abacus** | AbaConnect XML | P1 |
| **SwissSalary** | Excel-Import-Format | P1 |
| **KLARA** | CSV-Export | P2 |
| **Lucca** | REST-API oder CSV | P2 |
| **Treuhänder-generic** | CSV-Template | P0 (Backup) |

**Architektur-Prinzip:** ARK-CRM exportiert Commission-Daten in standardisiertem Format → Provider-spezifische Adapter transformieren. Keine direkte Kopplung an einen Provider.

---

## 6. Phase-3-Entscheidungspunkte (30+ Monate)

Nach Phase-2-Launch und 6–12 Monate echten Kundenfeedbacks:

### Pfad 3A · HR-Modul ausbauen
**Wann:** Kunden verlangen konkret integriertes Absenzen-Management oder Performance-Reviews
**Was:** Schrittweiser HR-Modul-Aufbau innerhalb ARK-CRM (Leave, Documents, Reviews)
**Ausschliessen:** Payroll-Logik (bleibt Partner-Sache)
**Kosten:** CHF 50–100k Entwicklung

### Pfad 3B · White-Label mit einem HR-Partner
**Wann:** Kunden verlangen One-Stop-Shop, ARK möchte nicht selbst bauen
**Was:** White-Label-Integration mit Lucca oder Personio — ARK verkauft HR als Add-on
**Ausschliessen:** Eigenentwicklung
**Kosten:** Vertragsverhandlung + ~3 Monate Integration

### Pfad 3C · Eigene Payroll als Premium-Feature
**Wann:** 50+ zahlende Kunden UND starkes Feedback für integrierten Lohnlauf
**Was:** Eigene Swissdec-Zertifizierung + SwissDecTX/STEPtx
**Ausschliessen:** Falls nicht klares Kundensignal
**Kosten:** CHF 200–350k + 18–24 Monate

**Entscheidungs-Trigger:** Nicht vor Jahr 3. Basis: **echtes Kunden-Feedback**, nicht Marktspekulation.

---

## 7. Risiken und Mitigation

| Risiko | Wahrscheinlichkeit | Impact | Mitigation |
|--------|:-:|:-:|-----------|
| Commission-Engine-Komplexität unterschätzt | Mittel | Hoch | Option-Präsentation-Pattern, Freeze-First, externe Reviews (ChatGPT/Perplexity/Manus) |
| Bexio-API-Änderungen | Niedrig | Mittel | Abstraktionsschicht ab Tag 1, nicht direkt gegen Bexio coden |
| Boutique-Kunden wollen doch Full-Suite | Mittel | Mittel | Pfad 3A/3B hält Option offen |
| Wettbewerber baut Commission-Engine | Niedrig | Hoch | Domain-Expertise + ES-Netzwerk als Burggraben |
| Peter wird überarbeitet durch Fokus-Verengung | Niedrig | Niedrig | Fokus-Verengung ist Entlastung, nicht Belastung |
| nDSG-Änderungen machen Partner-Integration teurer | Niedrig | Mittel | Self-hosted LLM bereits in Planung, Infra CH-based |

---

## 8. Konkrete nächste Schritte (nach Freeze dieser Entscheidung)

### 8.1 · Sofort (1–2 Wochen)

1. Dieses Dokument reviewen, korrigieren, als `v1.0` freezen
2. `ARK_HR_TOOL_PLAN_v0_2.md` aus diesem Dokument ableiten (kurze Roadmap-Version)
3. Action Item 5 starten: **Commission-Engine-Spec v0.1**
4. 2–3 CH-Boutique-Kontakte anrufen (Action Item 3) für Commission-Feedback
5. Bexio-Lohn-Modul-Vertrag prüfen (Features, Limits, API-Zugang)

### 8.2 · Kurzfristig (1–3 Monate)

1. Commission-Engine-Spec → Interactions v1.1 → DB-Schema → Backend-Architektur (Freeze-First-Pattern)
2. `dim_employment` + `dim_assignment` + `fact_commission` in Schema v1.4 integrieren
3. 3-Layer-Audit nach Spec-Round
4. Commission-Engine-Mockups (Interactive HTML) für externe Reviews
5. Bexio-Export-Prototype (CSV-Format definieren)

### 8.3 · Mittelfristig (3–12 Monate)

1. Commission-Engine Wave 1 + 2 (Backend + Frontend)
2. ARK-intern-Nutzung startet (Alpha, nur intern)
3. Ledger + Audit-Features (Wave 3)
4. Power BI-Reports für Commission-Analytics
5. Vorbereitung SaaS-Readiness (Multi-Tenant-Härtung)

### 8.4 · Langfristig (12–30 Monate)

1. SaaS-Beta mit 3–5 Pilot-Boutiquen
2. Partner-Integrationen (Bexio, dann Abacus, dann SwissSalary)
3. Pricing-Modell finalisieren (Per-User? Per-Placement? Hybrid?)
4. Treuhänder-Partner-Programm (wie Luccas `/fiduciary/`-Seite)
5. Phase 3 Entscheidung (3A / 3B / 3C)

---

## 9. Freeze-Kriterium

Dieses Dokument ist **v0.1 Draft**. Bevor es zu `v1.0` gefreezt wird, muss Peter:

- [ ] TL;DR und Empfehlung inhaltlich prüfen
- [ ] Vergleichsmatrix validieren (insbesondere TCO-Zahlen)
- [ ] Phase-1-Scope-Liste prüfen (was gebaut / was nicht gebaut)
- [ ] Partner-Prio-Liste in Phase 2 validieren (ist Bexio wirklich P0?)
- [ ] Phase-3-Pfade als valide bestätigen
- [ ] Explizit entscheiden: "Option D ist die Strategie"

Nach Freeze wird das Dokument unveränderlich — Updates erfolgen nur via Versionssprung (`v1.1`, `v2.0`). Alle abgeleiteten Dokumente (`ARK_HR_TOOL_PLAN`, `ARK_COMMISSION_ENGINE_SPEC`) referenzieren diese v1.0 als Single Source of Truth.

---

## 10. Offene Fragen an Peter

Bevor Freeze, drei konkrete Fragen:

1. **Bexio-Lohn-Modul:** Wurde das Bexio-Lohn-Modul (CHF 6/Mt pro MA ab 11. MA) bereits gebucht? Wenn nein: wann / durch wen?

2. **Commission-Rules heute:** Wie berechnet ARK heute die 40/30/30-Splits? Manuell in Excel? Im bisherigen CRM? Wer pflegt die Rules? **Das ist die Basis für die Spec.**

3. **Phase-2-Timing:** Ist 12–18 Monate realistisch für den SaaS-Launch? Oder lieber 18–24 Monate mit ruhigerer Gangart?

---

## Related

- `ARK_HR_RESEARCH_SYNTHESE_v0_1.md` — Research-Synthese aus 5 externen AI-Outputs
- `ARK_LUCCA_EVALUATION_v0_1.md` — Lucca Vendor-Eval
- `ARK_SWISSDECTX_EVALUATION_v0_1.md` — SwissDecTX Infrastruktur-Eval
- Nächstes: `ARK_COMMISSION_ENGINE_SPEC_v0_1.md` — Action Item 5
- Nächstes: `ARK_HR_TOOL_PLAN_v0_2.md` — Kurz-Roadmap basierend auf dieser Entscheidung
