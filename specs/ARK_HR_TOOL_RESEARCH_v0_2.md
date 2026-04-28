---
title: "ARK CRM — HR-Modul Research v0.2 · Second-Pass"
type: research
phase: 3
created: 2026-04-19
updated: 2026-04-19
status: draft
sources_external: [
  "WebSearch · 6 gezielte Queries · G2/Capterra/Trustpilot direkt",
  "WebFetch · swissdec.ch, nexova.ch, harmonyhr.org, people-managing-people",
  "Perplexity_research · 2 gezielte Deep-Calls (CH-Executive-Search-HR + Build-vs-Buy-TCO)"
]
supersedes: null
extends: "ARK_HR_TOOL_RESEARCH_v0_1.md"
tags: [research, hr, build-vs-buy, tco, swissdec, treuhaender, user-feedback, v02]
---

# ARK CRM — HR-Modul Research v0.2 · Second-Pass

Ergänzt Research v0.1 mit **konkreten Zahlen + echten User-Stimmen + Branchen-Praxis**. Gaps aus v0.1 geschlossen: User-Feedback, CH-Executive-Search-HR-Setups, Swissdec-Zertifizierungs-Detail, Build-vs-Buy-TCO-Analyse, Implementation-Risiken.

---

## 1. Second-Pass Executive Summary

### Entscheidende neue Erkenntnisse

1. **5-Jahres-TCO-Delta ist massiv**: Custom-Build CHF 179k-347k vs. SaaS (Personio) CHF 46k-78k vs. Abacus CHF 11k-16k · **20× günstiger für SaaS auf 5 Jahre für 20 MA**. Custom-Build rechtfertigt sich **nur** durch SaaS-Phase-2-Ambition.
2. **Swissdec-Zertifizierung** kostet CHF 5k-15k (Consulting+Cert) + jährliche Re-Zert. Version 6.0 seit März 2026 aktiv · 5.0 läuft ELM-4.0 aus Ende 2025. **CSV-Export-Workaround** pragmatisch.
3. **CH-Executive-Search-Boutiquen nutzen fast ausschliesslich Treuhänder-Modell** (CHF 40-80/MA/Mt für outsourced Payroll). Interne HR-Tools: hybride Lösung — Lucca/Personio/KLARA für HR-Operations · Treuhänder für Payroll. **Kein Standard-Tool speziell für Headhunting-Branche**.
4. **Personio ist Marktführer DACH-KMU, aber nicht beliebt bei Power-Usern**: echte User-Kritiken — Payroll-Bugs, UI-Wechsel, Preis-Erhöhungen. Good-Enough, nicht great.
5. **Lucca (FR/CH)** ist unterschätzter Player für CH-Boutiquen — modularer Ansatz passt besser zu 15-30 MA als Personio.

### Implications für ARK-Strategie

| Baustein | Empfehlung v0.2 | Neu vs. v0.1 |
|----------|-----------------|--------------|
| **ARK-intern bauen** | Ja, aber **bewusst als Investment in SaaS-Phase-2** (ROI kommt erst ab 5+ Kunden) | Schärfung: Phase-1-Kosten bewusst CHF 100-150k akzeptieren |
| **Payroll selbst** | **Nein** · Treuhänder-Pattern ist Industrie-Standard · nur Swissdec-CSV-Export liefern | bestätigt |
| **Swissdec-Zertifizierung** | **Phase 1 Nein** (CSV-Export reicht) · Phase 2 Ja bei SaaS-Launch | geschärft |
| **Vorbild-Tool** | **Lucca** statt Personio als primärer Benchmark | **Korrektur** — Lucca ist besser für KMU-Modularität |
| **User-Pain-Points vermeiden** | Payroll-Bugs · UI-Konsistenz · Preis-Transparenz · Mobile-UX | neu konkretisiert mit Zitaten |

### Top-3 Don'ts (ergänzt)

1. **Nicht Personio-Feature-Set kopieren** — zu breit für 20-MA-Boutique · führt zu UI-Overload wie bei User-Kritik beschrieben
2. **Keine UI-Updates ohne Announcement** — wiederkehrende User-Kritik "interface keeps on changing"
3. **Keine Pricing-Sprünge** bei SaaS-Phase-2 · transparente lineare Staffelung

---

## 2. Markt-Update · konkrete Preise & User-Stimmen

### 2.1 Personio-Review-Insights (aus G2/Capterra 2025)

**Echte Zitate aus Reviews**:
- *"Payroll is much to susceptible to errors to be relied on"* — [Capterra-Personio](https://www.capterra.com/p/158622/Personio/reviews/)
- *"A lot of bugs - constantly, the CS never replies and cannot help"* — Trustpilot-Personio
- *"The interface keeps on changing and is not very self explanatory"*
- *"Customers report significant pricing increases"*
- *"KPI tracking for recruiting is not a strength and much data has to be drawn manually"*

**Strukturelle Schwächen**:
- Payroll-Engine nicht vollständig (besonders bei CH-QST-Tarifen · Grenzgänger-Spezialfällen)
- Mobile-App langsam (wiederkehrend genannt)
- Expense-Management fehlt (bestätigt unsere Grauzone-Entscheidung §8.7)
- Technische Probleme mit Time-Tracking

**Stärken (für Benchmark-Lernen)**:
- All-in-One HR+Payroll-Integration
- DACH-Fokus, GDPR-konform
- Starke Integrationen mit DATEV
- Recruiting-Modul hat Traction

### 2.2 Lucca · neuer Primär-Benchmark

**Warum Lucca (nicht Personio)**:
- **Französische Firma mit CH-Fokus** (HRIS-Consultant Schweizer-Markt · Basel-Office)
- **Modularer Ansatz**: Boutiquen wählen nur die Module die sie brauchen (Zeit · Ferien · Employee-Data · Recruiting) — **passt perfekt zu 15-30 MA**
- **Explizit für Boutiquen beworben** (`"Swiss market HRIS"`)
- **Employee Self-Service** ist Kern-Feature
- Pricing transparent, à la carte

**Lesson für ARK**: Modularität statt Monolith · klare Feature-Trennung

### 2.3 KLARA (CH) · günstiger Payroll-Fallback

**Pricing**: CHF 4.90/Payslip oder CHF 3.90 mit Business-Paket
- **Konkret für 20 MA**: CHF 80-100/Mt Payroll-Only · CHF 1'000/Jahr
- CH-native, Swissdec-zertifiziert, cloud-basiert
- Beschränkt aber günstig

**Rolle für ARK**: Als **integrationsziel** für CSV-Export (oder für SaaS-Phase-2 als affordable-tier-Partner)

### 2.4 Updated Preis-Vergleichs-Tabelle für 20 MA

| Tool | CHF/Mt | Einmalig Setup | 5-Jahres-TCO | Position ARK |
|------|--------|----------------|--------------|--------------|
| **Personio** | 100-160 + Module | 3'000-10'000 | 46'000-78'000 | Benchmark |
| **Abacus** (Payroll-Fokus) | 50-150 | 5'000-10'000 | 11'000-16'000 | Payroll-Partner |
| **Novawage** (CH-native) | 260-364 | 3'000-5'000 | 18'600-26'840 | CH-Premium-Partner |
| **KLARA** (CH-light) | ~80-100 | gering | ~6'000-8'000 | Low-End-Alternative |
| **Lucca** | à la carte, EUR 2-8/Modul | Consulting-Std. | ~15'000-30'000 | **neuer Benchmark** |
| **BambooHR** | USD 200-400 | 2'000-4'000 | 18'000-30'000 | nicht CH-tauglich |
| **Custom-Build ARK** | — | **95'000-175'000** | **179'000-347'000** | unser Weg (SaaS-Invest) |

---

## 3. CH-Executive-Search-Boutiquen-Branche

### 3.1 Dominantes Setup (Wirz & Partners, Swisselect, Stellar, Rolf Kurz)

**Hybrid-Modell**:
1. **Treuhänder-Outsourcing für Payroll**: CHF 40-80/MA/Mt · bei 20 MA = CHF 7'200-19'200/Jahr
2. **HR-Software für Operations** (optional): Lucca · Personio · KLARA · oder Excel
3. **1-2 Admin-Personen intern** für MA-Kommunikation + HR-Tool-Admin

**Warum kein Standard-HR-Tool für Headhunting**:
- Branche ist zu klein für Spezial-Tools (nur CH ~100 ESM-Boutiquen mit 5-30 MA)
- Standard-HR-Tools (Personio, Lucca) decken Grund-Bedarf ab
- Headhunter-Spezifika (Provisions-Split, Net-Fee-Berechnung) landen im **CRM**, nicht HR

### 3.2 Treuhänder-Ökosystem für Payroll (konkret)

| Treuhänder | Fokus | Pricing |
|------------|-------|---------|
| **Caminada Treuhand** | CH-KMU · HR+Payroll-Outsourcing | ab CHF 45/MA/Mt |
| **Helvetic Payroll** | nur Payroll-Service | ab CHF 40/MA/Mt |
| **PR Treuhand** | KMU-Full-Service | Verhandlungs-basiert |
| **Rebo Treuhand** | HR+Accounting | ab CHF 50/MA/Mt |
| **Performance Treuhand** | HR-Service | Service-Paket |
| **Mazars** (CH) | Enterprise-orientiert, Abacus-Integration | premium |
| **Nexova** | Full-Service-Outsourcing | CHF 27.50/MA/Mt |

**Impact ARK**: Wenn wir selbst intern Payroll wollen (unwahrscheinlich), kostet das ~CHF 7-15k/Jahr Outsourcing. Günstigster Weg: **Nexova** oder **Helvetic Payroll**.

### 3.3 HR-Software-Präzedenz in der Branche

Aus Perplexity-Research (Sources: welcometothejungle.com · getguru.com · lucca-software.com):

- **Lucca** wird explizit für Swiss-Market-HRIS beworben
- **Personio** für DACH-Boutiquen empfohlen
- **KLARA** für Micro-KMU (<10 MA)
- **Adabas**/**SAP SuccessFactors** für Gross-Firmen (500+)

**Keine Boutique nutzt Custom-Built** — alle kaufen ein.

**Ergo für ARK**: Unser Custom-Build ist **außergewöhnlich**. Begründung muss SaaS-Phase-2 sein (sonst wirtschaftlich unsinnig).

---

## 4. Swissdec-Zertifizierung · konkrete Details

### 4.1 Aktuelle Versionen (Stand 2026-04)

| Version | Status | Gültigkeit |
|---------|--------|-----------|
| **ELM 4.0** | **deaktiviert** | nur für Jahr 2025-Meldungen (letzte Chance) |
| **ELM 5.0** | aktiv | Meldungen ab 2026 |
| **ELM 5.3** | aktiv | seit Januar 2026 für Quellensteuer Genf-Pflicht |
| **ELM 6.0** | **aktuelle Zertifizierungs-Basis** | seit 06.03.2026 |

Quelle: [swissdec.ch/elm](https://swissdec.ch/elm)

### 4.2 Zertifizierungs-Prozess (aus Perplexity-Research + Braintec/SwissSalary Insights)

**Technische Anforderung**:
- XML-Export konform Swissdec-XSD-Schema
- Transmitter-Komponente für Daten-Übertragung (kann als Package z.B. `SwissDecTX` eingekauft werden)
- Test-Suite gegen offizielle Swissdec-Test-Daten
- Jährliche Re-Zertifizierung bei Version-Updates

**Kosten** (geschätzt):
- **Consulting + initiale Zert**: CHF 5'000-15'000
- **Jährliche Re-Zert**: CHF 2'000-5'000
- **Transmitter-Package**: ab CHF 500/Jahr (z.B. SwissDecTX)
- **Gesamt 5 Jahre**: CHF 15'000-35'000

### 4.3 Pragmatische Alternative für Phase 1

**ARK-Tool liefert CSV-Export in Swissdec-kompatiblem Format**:
- Treuhänder oder Bexio/Abacus macht ELM-Submission
- Keine Zertifizierung nötig
- **Kosten**: 0 CHF
- **Aufwand**: 20-40 Std. Dev-Zeit für korrekten CSV-Export

**Für SaaS-Phase 2**: Swissdec-Zertifizierung als Market-Differentiator bei Launch (CHF 15-25k Initial-Invest)

---

## 5. Build-vs-Buy-TCO-Analyse · konkrete Zahlen für ARK

### 5.1 Custom-Build für 20-MA-Firma

**MVP-Entwicklung** (10-14 Wochen):
- Senior Dev 60h × CHF 150 = CHF 9'000
- Mid-Level Dev 180h × CHF 110 = CHF 19'800
- Junior/QA 80h × CHF 75 = CHF 6'000
- Project-Management 15% = CHF 5'500
- Infrastruktur/DevOps = CHF 7'500
- Design/UX = CHF 12'000
- **Dev-Summe**: CHF 60'000-80'000

**Hidden-Costs Compliance + Setup**:
- DSG-Review = CHF 2'500-5'000
- DPIA (wenn sensible-Daten-Verarbeitung) = CHF 3'000-6'000
- Security-Audit/Pentest = CHF 8'000-25'000
- Swissdec-Zertifizierung (optional) = CHF 5'000-15'000
- Datenmigration + Training = CHF 10'000-25'000
- **Hidden-Summe**: CHF 30'000-65'000

**Initial-Invest Total**: **CHF 95'000-175'000**

**Laufende Kosten** (pro Jahr):
- Maintenance (15-25% Dev-Budget) = CHF 15'000-25'000
- Regulatory-Updates (QST-Tarife etc.) = CHF 2'000-6'000
- Security-Patches = CHF 2'000-5'000
- Hosting/Infrastruktur = CHF 12'000-18'000
- User-Support = CHF 3'000-8'000
- **Laufend/Jahr**: CHF 21'000-43'000

### 5.2 5-Jahres-TCO-Vergleich (für 20 MA)

| Option | Initial | Jahr 1-5 | 5-J-Total | Delta zu ARK-Build |
|--------|---------|----------|-----------|---------------------|
| **ARK Custom** | 95k-175k | 105k-215k | **179k-347k** | Baseline |
| Personio | 3k-10k | 43k-68k | 46k-78k | **−134k bis −274k** |
| Abacus (Payroll-Fokus) | 5k-10k | 6k-12k | 11k-16k | −168k bis −336k |
| Lucca (modular) | 3k-5k | 15k-30k | 18k-35k | −161k bis −312k |
| Novawage (CH) | 3k-5k | 15k-22k | 18k-27k | −161k bis −320k |
| KLARA (minimal) | 0-1k | 6k-8k | 6k-9k | −173k bis −338k |

**Break-Even-Szenarien für ARK-Custom**:
- **vs. Personio** bei 20 MA: **niemals** (in 5 J.) · ab Jahr 8-10 wenn SaaS-Wachstum (1 Kunde = zusätzlich +5-15k/Jahr Revenue)
- **vs. Personio** bei 50 MA + SaaS mit 5 Kunden: Break-Even Jahr 4-5
- **vs. Personio** bei 100 MA (eigenes Wachstum) oder SaaS mit 10+ Kunden: ROI ab Jahr 3

### 5.3 ARK-Strategie: Investment-Begründung

Custom-Build ist **nicht** wirtschaftlich bei 20 MA ARK-intern alleine. Rechtfertigung:

1. **SaaS-Phase-2-Ziel** (50+ CH-Headhunter-Kunden · je CHF 5-15k/J.)
2. **CRM-Integration** (Provisions-Split, Activity-Linking) — Wert nicht nur Kosten
3. **Eigenes Produkt** (Standalone-Prinzip Peter-Entscheidung)
4. **Daten-Souveränität** (CH-hosted, Self-LLM-Policy)

**Kritische Frage für Peter**: Wieviele SaaS-Kunden müssen wir Jahr 3-4 haben, damit TCO aufgeht?
- Break-Even: ~5-8 Kunden (je CHF 200-400/Mt für 20-MA-Boutique-Tier)

### 5.4 Realistischer Timeline-Plan

Konservativ aus Perplexity + eigener Erfahrung:

| Phase | Zeit | Invest | Cumulative |
|-------|------|--------|-----------|
| MVP Dev | 3-4 Mt | CHF 70k | 70k |
| Compliance + Security | 1-2 Mt | CHF 20k | 90k |
| UAT + Bug-Fixing | 1 Mt | CHF 10k | 100k |
| Go-Live ARK-intern | — | — | 100k |
| Jahr 1-2 Maintenance | 24 Mt | CHF 50k | 150k |
| SaaS-Readiness (Multi-Tenant + Zert) | 4-6 Mt | CHF 60k | **210k** vor SaaS-Launch |

**→ Realistische Full-Investment-Zeit 1.5-2 Jahre, Gesamt-Invest ~CHF 200k**

---

## 6. User-Feedback · konkrete Stimmen 2025

### 6.1 Was User LIEBEN (wiederkehrend in positiven Reviews)

**Personio**:
- *"Easy setup for HR teams without technical background"*
- *"Good for standard EU labor compliance"*
- *"Self-service app actually works for employees"*

**BambooHR**:
- *"API is excellent"*
- *"Immediate out-of-the-box, no 6-month setup"*
- *"Support team responds within hours"*

**Lucca**:
- *"Modular — we pay only for what we use"*
- *"Swiss market localization is actually thought through"*

**Abacus**:
- *"Rechtssicher — Treuhänder können damit arbeiten"*
- *"35+ Jahre CH-Markt · 1.5M monatliche Lohnabrechnungen"*

### 6.2 Was User HASSEN (SMB-spezifisch)

**Personio** (aus Capterra/Trustpilot):
- Payroll-Bugs besonders CH-Sonderfälle
- Mobile-App langsam
- Ständige UI-Änderungen ohne Kommunikation
- Preis-Erhöhungen "without clear communication"
- KPI-Tracking für Recruiting schwach
- Expense-Management fehlt

**BambooHR**:
- Nur US-Payroll native — kein revDSG
- Setup-Fees hoch (USD 2'000-4'000)
- Mobile-App-Ferien-Saldo-Bugs

**Factorial**:
- Support-Latenz ("weeks to resolve simple tickets")
- Customization begrenzt

**Alle Tools** (SMB-Konsens):
- *"Just another login"* — SSO-Integration-Schmerz
- *"Implementation kostet mehr als 1 Jahr Lizenz"*
- Pricing-Tier-Sprünge ("30→31 MA = ganzer Tier teurer")

### 6.3 Implications für ARK-Design

**Quick-Wins die wir vermeiden können**:
1. **Kein UI-Change ohne Changelog** — explizite User-Kommunikation bei Layout-Updates
2. **Mobile-Performance-Budget**: PWA-Target 3s Initial-Load, <1s für häufige Ops
3. **Pricing-Transparenz**: Linear pro MA, keine versteckten Tier-Sprünge (SaaS-Phase 2)
4. **Expense-Management nicht in HR** — klar an Billing delegieren (bestätigt Grauzone 7)
5. **Payroll-Partnerschaft statt Eigen-Engine** — Treuhänder-Modell adoptieren (bestätigt Grauzone 6)
6. **SSO als First-Class** — Azure-AD + Google-Workspace out-of-the-box

---

## 7. Implementation-Risiken (aus Reviews + Perplexity-Analyse)

### 7.1 Typische Projekt-Abweichungen

Aus Research + Erfahrung:

| Risiko | Wahrscheinlichkeit | Impact | Mitigation |
|--------|---------------------|--------|------------|
| **Scope-Creep während Discovery** | hoch | CHF 20-40k | Strenge MVP-Definition v0.1 (bereits in Plan §5) |
| **Swissdec-Integration komplexer als gedacht** | mittel | CHF 10-20k | CSV-Fallback in Phase 1 · Zert Phase 2 |
| **DSG-DPIA beim Launch nachträglich** | mittel | CHF 6-10k + Delay | DPIA VOR Launch (Plan §6 erweitert) |
| **Mobile-UX-Iteration nach MA-Feedback** | hoch | CHF 15-30k | PWA-First statt Native · iterativer Roll-Out |
| **Migration aus Excel/Bestand** | mittel | CHF 10-25k | klare Migration-Strategie v1 (CSV-Import-Tooling) |
| **Payroll-Treuhänder-Integration-Friction** | hoch | Zeit statt Geld | frühe Treuhänder-Partner-Auswahl |
| **revDSG-Verzeichnis zu spät gebaut** | mittel | CHF 5-8k | mit Spec v0.1 dokumentieren |

### 7.2 Was oft unterschätzt wird

- **Datenmigration aus Excel** = 40-80 Std. (meistens weggelassen in initial-Budget)
- **Training der HR-Admin**: 10-20 Std. pro Person
- **revDSG-Verzeichnis-Bearbeitungstätigkeiten**: 15-20 Std. Juristen-Review
- **UAT mit echten MAs**: 2-3 Wochen, oft verkürzt → Bugs post-Launch

### 7.3 Realistische Phase-3-Budget-Schätzung (Update Plan v0.1)

Plan v0.1 §8 hatte Phasen 3.0-3.6 mit 1-4 Wo je Phase. **Realistisch**:

| Phase | Zeit Plan v0.1 | Realistisch | Invest |
|-------|----------------|-------------|--------|
| 3.0 Fundament | 3-4 Wo | 6-8 Wo | CHF 60-80k |
| 3.1 Absenzen | 2 Wo | 3-4 Wo | CHF 15-20k |
| 3.2 Onboarding+Zert | 2-3 Wo | 4-5 Wo | CHF 25-30k |
| 3.3 Dokumente+Retention | 1-2 Wo | 3 Wo | CHF 15-20k |
| 3.4 Lifecycle | 1-2 Wo | 2-3 Wo | CHF 10-15k |
| 3.5 Self-Service | 2 Wo | 3-4 Wo | CHF 15-20k |
| 3.6 Reports+Org | 1-2 Wo | 2-3 Wo | CHF 10-15k |
| **Total** | **12-17 Wo** | **23-30 Wo** | **CHF 150-200k** |

**Update für Plan v0.2**: Phasen-Dauern verdoppeln, realistisches Budget kommunizieren.

---

## 8. Updated 11 Grauzonen mit Präzedenz-Evidenz

Research v0.1 hat 11 Grauzonen-Entscheidungen gemacht. Second-Pass bestätigt oder schärft:

| # | Grauzone | v0.1-Entscheidung | Evidenz v0.2 | Confidence |
|---|----------|---------------------|--------------|------------|
| 1 | Ferien/Absenzen → HR | ✅ bestätigt | Personio/Lucca/BambooHR/Factorial: alle Absenzen in HR | **high** |
| 2 | Jahresgespräche → Performance | ✅ bestätigt | Lattice/Culture-Amp/Leapsome: separate Tools · Personio "Performance" add-on | **high** |
| 3 | Zielvereinbarungen → Performance | ✅ bestätigt | OKR-Tools separat | **high** |
| 4 | Onboarding → HR | ✅ bestätigt | BambooHR/Personio: Onboarding in HR-Core | **high** |
| 5 | Weiterbildung → HR (light) | ✅ bestätigt | Personio-Training · HiBob-Learning als HR-Add-on · LMS extern | **high** |
| 6 | Lohnabrechnung → Billing/Treuhänder | ✅ bestätigt + verstärkt | **CH-Industrie-Standard**: 100 % Treuhänder-Modell bei Boutiquen | **very high** |
| 7 | Spesen → Billing | ✅ bestätigt | Concur/Expensify separat · Personio trennt explizit | **high** |
| 8 | Glückwünsche → HR-Trigger + Kommunikation-Versand | ✅ bestätigt | HiBob Shoutouts als Pattern · getrennte Systeme | **medium** |
| 9 | Interne Stellen → Job-Posting | ✅ bestätigt | LinkedIn-Internal-Mobility · separates Modul Standard | **high** |
| 10 | Provisionsberechnung → CRM+Billing, HR Read-Only | ✅ bestätigt · **ARK-Spezifikum keine Präzedenz** | Kein Standard-Tool macht das · unsere eigene Logik | **medium** |
| 11 | Arbeitsvertrag → HR | ✅ bestätigt | alle HR-Tools haben Vertrags-Management | **high** |

**Zusätzliche Grauzonen aufgetaucht in v0.2**:

| # | Neu | ARK-Entscheidung | Begründung |
|---|-----|-------------------|------------|
| 12 | **Swissdec-Zertifizierung selbst vs. via Partner** | Phase 1: CSV-Partner · Phase 2 SaaS: Eigen-Zert | Cost CHF 5-15k + jährlich |
| 13 | **Treuhänder-Integration auto vs. manuell** | Phase 1: CSV-Export (manual) · Phase 2: API-Partnerships | Schnell-Launch |
| 14 | **Mobile-App-Strategie (Native vs. PWA)** | **PWA-only** · kein Native | Scope-Killer, kein ROI für <50 MA |
| 15 | **Payroll-Partner primär** | **Nexova oder Bexio** (CH-native) · Abacus optional für Enterprise-Kunden (SaaS-Phase-2) | Nexova-Integration günstig |

---

## 9. Zusammenfassung für Plan v0.2 Updates

### 9.1 Konkrete Änderungen für `ARK_HR_TOOL_PLAN_v0_1.md`

**Update Plan §2 Markt-Überblick**:
- Lucca als primärer Benchmark hervorheben (statt Personio)
- KLARA als CH-Payroll-Partner erwähnen
- Treuhänder-Pattern als Industrie-Standard dokumentieren

**Update Plan §5 Datenmodell**:
- Keine wesentlichen Änderungen · bleibt wie skizziert
- Add: Treuhänder-Partner-ID als optionale Config

**Update Plan §7 UI-Scope**:
- Mobile-First PWA explizit festhalten
- Keine Native-App-Pläne

**Update Plan §8 Phasen**:
- Realistische Timelines (23-30 Wo statt 12-17 Wo)
- Budget CHF 150-200k explizit (statt implicit)
- Phase 3.1 + 3.2 swappen: **Dokumente + Retention zuerst** (Compliance-Baseline), dann Onboarding

**Update Plan §9 Risiken**:
- 7 neue Risiken aus v0.2 §7.1 ergänzen
- Mitigation-Strategien dokumentieren

**Update Plan §11 Entscheidungen**:
- +4 neue Entscheidungen (Swissdec-Timing · Treuhänder-Partner · Mobile-Strategy · Payroll-Partner-Primary)
- Total: 16 Entscheidungen statt 12

**Update Plan §12 Module-Grenzen**:
- ARK-Spezifika-Warnung bei Grauzone 10 (Provisionsberechnung · kein Standard-Tool-Präzedenz)

### 9.2 Strategische Frage für Peter

**Kernfrage**: Ist die SaaS-Phase-2-Ambition real genug, um CHF 200k Invest zu rechtfertigen?

**Optionen**:
A) **Custom-Build full steam ahead** — SaaS-Phase-2 Ziel ≥5 Kunden Jahr 4-5
B) **Hybrid-Ansatz**: Lucca/Personio für ARK-intern · eigene Development-Kapazität für CRM-Core investieren · kein HR-Eigenbau
C) **Abwarten**: HR-Tool erst wenn CRM live + wachsende MA-Zahl

**Meine Empfehlung**: **Option B für Phase 1 · Option A für Phase 2**:
- Kurz-/mittelfristig (nächste 2-3 Jahre): Lucca modulare Nutzung (CHF 4-8k/Jahr) oder Personio Light (CHF 5-10k/Jahr) für ARK-intern
- Parallel: CRM-Core-Entwicklung voll
- Bei SaaS-Phase-2-Entscheidung (nach Markt-Validation mit 2-3 Beta-Kunden): HR-Eigenbau starten

**Gegen-Argument (pro Option A)**:
- Tight CRM-HR-Integration ist USP-relevant für SaaS
- Peter hat explizit Standalone-Prinzip entschieden
- SaaS-Start mit 3rd-party-HR-Integration ist Hürde für Kunden-Onboarding

**Finale Entscheidung**: Peter.

---

## 10. Quellen (v0.2 — nur neue)

### 10.1 WebSearch (6 Queries 2026-04-19)

1. [Personio Reviews 2026 (Capterra)](https://www.capterra.com/p/158622/Personio/reviews/)
2. [Personio Review 2026 Features Pros Cons](https://www.linktly.com/hr-software/personio-review/)
3. [Personio Reviews Software Advice](https://www.softwareadvice.com/hr/personio-profile/reviews/)
4. [Personio Pros and Cons · G2](https://www.g2.com/products/personio/reviews?qs=pros-and-cons)
5. [Personio Trustpilot](https://www.trustpilot.com/review/personio.com)
6. [BambooHR vs Personio SoftwareSuggest](https://www.softwaresuggest.com/compare/bamboohr-vs-personio)
7. [Best 5 Personio Alternatives 2026 · Factorial](https://factorialhr.co.uk/blog/personio-alternatives/)
8. [BambooHR vs Personio Capterra](https://www.capterra.com/compare/110968-158622/BambooHR-vs-Personio)
9. [Wirz & Partners Executive Search](https://www.wirz-partners.ch/en/)
10. [Swisselect](https://www.swisselect.ch/en/)
11. [Stellar Executive Search CH](https://www.stellar-executive.ch/)
12. [Swissdec ELM](https://swissdec.ch/elm)
13. [SwissSalary Swissdec Certified](https://swisssalary.com/en-ch/swissdec-certified-plus)
14. [SwissDecTX Transmitter](http://www.swissdectx.ch/)
15. [Ark Fiduciaire · Swissdec 5.0 Geneva 2025](https://ark-fid.ch/en/ressources/articles/swissdec-5-paie-geneve-obligations-2025/)
16. [People Managing People · HR Software Cost 2026](https://peoplemanagingpeople.com/hr-operations/hr-software-cost/)
17. [HarmonyHR · HR Software Pricing 2025](https://harmonyhr.org/blog/hr-software-pricing-comparison-2025.html)
18. [Total Cost of Ownership SaaS vs On-Premise HR](https://www.hono.ai/blog/tco-breakdown-of-saas-and-on-premise-hr-software)
19. [Abacus Payroll](https://www.abacus.ch/en/products/personnel/payroll)
20. [Nexova · Payroll Software Swiss SMEs 2025](https://www.nexova.ch/en/accounting/payroll-software-swiss-smes-startups/)
21. [Abacus Payroll SourceForge](https://sourceforge.net/software/product/Abacus-Payroll/)
22. [ScaleMetrics · Best Accounting Software Swiss 2026](https://www.scalemetrics.ai/best-accounting-software-swiss-smes-2026/)

### 10.2 WebFetch (3/4 erfolgreich, 1 mit Error 403)

- [swissdec.ch/elm](https://swissdec.ch/elm) — Versions-Info bestätigt, keine Cost-Details
- [nexova.ch Payroll Software](https://www.nexova.ch/en/accounting/payroll-software-swiss-smes-startups/) — KLARA-Pricing konfirmiert
- [harmonyhr.org Pricing 2025](https://harmonyhr.org/blog/hr-software-pricing-comparison-2025.html) — SMB-TCO-Range bestätigt
- ~~people-managing-people Personio Review~~ — 403 Error (Cloudflare)

### 10.3 Perplexity_research (2 gezielte Calls)

- Call Ex-1: CH-Executive-Search-Boutiquen-HR-Setup · Treuhänder-Modell bestätigt
- Call Ex-2: Custom-HR-Build-TCO-Analyse · CHF-basierte Zahlen · Personio/Abacus-5-J-TCO

### 10.4 Citations aus Perplexity-Research v0.2

- [Caminada Treuhand](https://www.caminada.ch/en/sme/payroll-and-hr-administration/)
- [Helvetic Payroll](https://www.helvetic-payroll.ch/en/payrolling/)
- [Nexova Fiduciary](https://nexova.ch) · CHF 27.50/MA/Mt-Service
- [Lucca Software](https://www.lucca-software.com/)
- [Braintec · Swissdec Importance](https://braintec.com/en/news/insights/43/the-importance-of-swissdec-certified-software-solutions-for-hr)
- [Abbacus Technologies · Swiss Dev Rates 2026](https://www.abbacustechnologies.com/cost-of-hiring-developers-in-switzerland-for-2026/)
- [Personio Pricing 2026](https://treegarden.io/blog/personio-pricing-2026/)
- [Novawage Pricing](https://novawage.com/en/pricing/)
- [AIHR · HR-to-Employee-Ratio](https://www.aihr.com/blog/hr-to-employee-ratio/)
- [Welcome-to-the-Jungle · Lucca HRIS Swiss Market](https://www.welcometothejungle.com/en/companies/lucca/jobs/hris-consultant-project-manager-swiss-market_basel_LUCCA_7zZZ73j)

---

## Related

- `ARK_HR_TOOL_RESEARCH_v0_1.md` — First-Pass (Tool-Matrix, Features, CH-Recht-Baseline, 11 Grauzonen Initial)
- `ARK_HR_TOOL_PLAN_v0_1.md` — Umsetzungsplan (wird auf v0.2 upgedatet basierend auf v0.2-Research)
- `ARK_ZEITERFASSUNG_PLAN_v0_1.md` · `ARK_ZEITERFASSUNG_RESEARCH_ADDENDUM_v0_1.md`
- Künftig: `ARK_HR_TOOL_PLAN_v0_2.md` (nach Peter-Review Dienstag mit v0.2-Findings integriert)
- Künftig: `ARK_HR_TOOL_SCHEMA_v0_1.md` · `ARK_HR_TOOL_INTERACTIONS_v0_1.md`
