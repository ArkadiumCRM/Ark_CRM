---
title: "Lucca Software · Produkt-Steckbrief und ARK-Fit-Check"
type: evaluation
phase: 3
created: 2026-04-19
version: v0.1
sources: ["lucca-software.ch", "Capterra", "Software Advice", "GetApp", "GGBA.swiss", "Welcometothejungle", "Swissdec-Zertifizierungsliste"]
tags: [research, evaluation, vendor, lucca, saas-benchmark]
---

# Lucca Software · Produkt-Steckbrief und ARK-Fit-Check

> **Auftrag:** Lucca als potenzielle CH-KMU-HRIS-Alternative zu Personio evaluieren. Q3 der Research-Synthese hatte Lucca als besseren CH-Benchmark genannt (Basel-Office, modulares Pricing, CH-Fokus). Dieses Dokument prüft die Behauptung faktisch und liefert Fit-Check für ARK (intern + SaaS-Phase-2-Referenz).

---

## 1. Unternehmens-Basisfakten

| Parameter | Wert |
|-----------|------|
| **Gründung** | 2002 in Paris |
| **Eigentümer / Finanzierung** | 20 Jahre selbstfinanziert; 2022 Series A über **EUR 65 Mio** |
| **Mitarbeiter** | 700+ (Ziel 900 bis Ende 2025, EUR 100 Mio Umsatz) |
| **Wachstum** | **>40% pro Jahr** |
| **Kunden weltweit** | **7'800+ Kunden** in 130+ Ländern, **1.5 Mio aktive User** |
| **Subsidiaries** | Frankreich (HQ), Barcelona (2020), **Genf (2022)**, Basel, München, Zürich (geplant 2024) |
| **Ziel CH** | "Major player in the Swiss market by 2025" (laut eigener Job-Ausschreibung) |

### Relevante Einordnung für CH

- **CH ist Luccas zweitgrösster Markt nach Frankreich** — explizit vom Swiss-Subsidiary-Head Régis de Germay bestätigt
- **100+ lokale CH-Kunden** (Stand Juli 2023, vermutlich heute 200–300)
- CH-Referenzkunden: **Columbia Sportswear, L'Occitane, Novo Nordisk, Kepler Cheuvreux, Nexthink, Debiopharm, DNDi, UNIL, EHC, FISU, FIM, ISO, Eurovision (EBU), Asendia, Edigroup, Cellularline, Softcom, WILPF, Imad, Servier, Bolloré**

**Einordnung:** Das ist keine "Interesse, aber klein"-Präsenz wie viele internationale HR-Tools, sondern eine substanzielle DACH/CH-Fokus-Strategie mit Investment. Die Klientel ist breit — von internationalen Grosskonzernen bis zu Schweizer Stiftungen.

### Aber: CH-Kundengewichtung

Die CH-Referenzen sind stark **Romandie-lastig** (Genf-Office war zuerst) und enthalten viele **internationale Firmen mit CH-Tochter** (Columbia, L'Occitane, Novo Nordisk). Reine Schweizer KMU aus der Deutschschweiz mit 10–50 MA sind in den Referenzen nicht prominent. Das ist relevant für ARK — Peter muss prüfen, ob Lucca Deutschschweiz-KMU wirklich so gut bedient wie die Marketing-Claims suggerieren.

---

## 2. CH-Präsenz im Detail

| Aspekt | Status |
|--------|--------|
| **Office Genf** | Aktiv seit 2022; Leitung: Régis de Germay; Adresse Chemin du Pavillon 2, Le Grand-Saconnex |
| **Office Basel** | Aktiv (Team + Beratung dort) |
| **Office Zürich** | Geplant 2024 für Deutschschweiz-Expansion |
| **Telefonnummer CH** | +41 22 596 74 71 (Genf) |
| **Data-Hosting CH** | **Microsoft Azure Server in der Schweiz (Zürich + Genf)** — explizit für CH-Kunden |
| **Customer-Success-Team CH** | 7 Personen (Stand Mai 2025) |
| **Sprachen im Produkt** | Französisch, Deutsch, Englisch, Spanisch, Chinesisch |
| **FADP/nDSG-Compliance** | Explizit dokumentiert — eigene FADP/GDPR-Seite |

**Einordnung:** Die CH-Infrastruktur ist **real und substanziell**, nicht nur eine Verkaufsadresse. Azure-Hosting in CH ist für nDSG-Compliance ein wichtiges Kriterium — Lucca macht das richtig.

---

## 3. Produkt-Architektur: 12 Module à la carte

Lucca ist **modular à la carte** — nicht monolithisch. Kunde wählt nur, was er braucht. Module-Preise pro User pro Monat.

### Core-HR-Ebene
- **Core HR** — Employee Data Management (Stammdaten, Verträge, Onboarding)

### Time & Activities
- **Leave & Absences** (ehemals **Figgo**) — Ferien und Abwesenheiten
- **Timesheet** (ehemals **Timmi**) — Zeiterfassung und Überstunden
- **Office** — Remote Work und Hybrid Office

### Talent
- **Performance** (ehemals **Poplee Perf**) — Reviews, Ziele, Skills
- **Engagement** — Anonymous Surveys
- **Training** — Kurs-Katalog, Anträge, Budgets
- **Recruitment** — ATS (intern)

### Remuneration & Benefits
- **Payslip** (ehemals **Pagga**) — Online-Payslip-Verteilung
- **Compensation** — Payroll-Budget, variable Pay, Comp-Changes
- **Payroll Assistant** — **Daten-Sammlung und -Übertragung an externes Payroll-System**

### Business Expenses
- **Expenses** (ehemals **Cleemy**) — Spesen-Erfassung und -Management

### Einordnung der Architektur für ARK

Das Modul-Mapping passt **1:1 zu ARKs Grauzonen-Matrix**:

| ARK-Grauzone | Lucca-Lösung |
|--------------|--------------|
| Ferien/Absenzen → HR | ✅ Leave & Absences (Figgo) |
| Jahresgespräche → Performance | ✅ Separates Performance-Modul |
| Zielvereinbarungen → Performance | ✅ Performance-Modul (Goals) |
| Onboarding → HR | ✅ Core-HR |
| Weiterbildung → Performance | ✅ Training-Modul (separat) |
| **Lohnabrechnung → Extern** | ✅ **Payroll Assistant = bewusst kein Lohnlauf, nur Daten-Übergabe** |
| Spesen → Billing | ⚠️ Expenses-Modul im HR, nicht in Billing |
| Geburtstage → HR + Kommunikation | — (keine explizite Lösung) |
| Interne Stellen → Job-Posting | ✅ Recruitment-Modul (ATS) |
| Provisionsberechnung → CRM | ❌ Lucca kennt keine Headhunter-Commission-Splits |
| Arbeitsverträge → HR | ✅ Core-HR mit Versionierung |

**Starke Bestätigung der Research-Synthese:** Lucca verfolgt dieselbe Modul-Philosophie, die wir aus dem Research als Best Practice destilliert haben — separate Module mit klaren Grenzen, Payroll ausgelagert.

---

## 4. Schweiz-Compliance

### Swissdec-Status — **kritischer Punkt**

**Lucca ist NICHT Swissdec-zertifiziert.** Keine Nennung in der offiziellen Swissdec-Zertifizierungsliste (ELM 5.0 / ELM 6.0).

Lucca's Ansatz: **Payroll Assistant = Daten-Hub**, der gesammelte Lohndaten (Stammdaten, Absenzen, variable Pay, Benefits) **an einen externen Payroll-Provider übergibt** (Treuhänder, Abacus, SwissSalary, Bexio, Payroo etc.).

Von der Lucca-Website:
> *"This data can also be sent directly to your fiduciary for processing (personal and professional data of employees, salary data…)"*

**Einordnung:** Das ist **exakt die Strategie, die unsere Research-Synthese für ARK empfohlen hat** (Partner-Integration, nicht Eigenbau). Lucca validiert diese Architektur-Entscheidung.

### Was Lucca für CH-Compliance tut

- ✅ Azure-Hosting CH (Zürich + Genf)
- ✅ FADP/nDSG-Privacy-Policy
- ✅ Mehrsprachige Oberfläche (DE/FR/EN)
- ✅ Bewilligungs-Tracking (laut Feature-Seiten)
- ✅ Treuhänder-Programm für CH (eigene Seite `/fiduciary/`)
- ⚠️ Keine explizite GAV-Spezifik (wichtig für SaaS-Kunden aus Bau/Gastro)
- ⚠️ Keine explizite 13. Monatslohn-Logik in Dokumentation gefunden (wahrscheinlich über Payroll-Partner)
- ⚠️ Keine explizite Quellensteuer-Berechnung (wird via Payroll-Partner delegiert)

---

## 5. Pricing

### Die Preis-Fakten die ich finden konnte

- **Basic Plan:** ca. **EUR 9.82 / User / Monat** (~CHF 9.50)
- **Modulares Pricing:** jedes Modul separat, pro User pro Monat
- **Custom-Quote** für grössere Installationen via Sales-Team
- **Keine öffentliche CH-Preisliste** — Lucca publiziert Preise nicht transparent

### Schätzung für ARK (10 MA intern)

Bei typischem Lucca-Modul-Mix (Core HR + Leave + Timesheet + Performance + Payroll Assistant):

- **Minimum:** 4–5 Module × ~CHF 2–4/User = **CHF 12–20 / User / Monat**
- **Für 10 MA:** **CHF 120–200 / Monat** = **CHF 1'440–2'400 / Jahr**
- **Plus:** Implementation-Fee (meist 1x Projekt-Setup, oft 20–30% des Jahresbetrags)

Das ist konsistent mit Q3 der Research-Synthese: **~CHF 4–10k / Jahr** für ARK-intern mit 10 MA bei Vollausbau.

### Wichtiger Nutzer-Kritikpunkt

> *"The undesirable thing about Lucca is the cost price or to be more precise the package system that Lucca propose"* (Capterra)

> *"What the client pays is the number of people who processed expense reports during the month instead of the number of expense reports."* (Software Advice)

→ Das Preis-Paket-System ist **intransparent und nicht linear**. Peter muss bei einer Demo konkrete Zahlen verlangen und idealerweise mit zwei anderen Anbietern vergleichen.

---

## 6. Nutzer-Reviews — was real ist

### Was gelobt wird (echte Zitate)

> *"Lucca est la plus facile d'utilisation [de tous les SIRH]. La navigation est claire et fluide, le design est simple, coloré et dynamique."* (Capterra FR)

> *"Just like in my title, I see Lucca as a one-stop tool for everything related to HR, Admin and Finance. As a HR Manager, it's easy to use: to keep track of all the information about employee, to manage expenses notes, generate contracts and other documents quickly."* (Capterra)

> *"We use it mostly for HR management. It's perfect how I can see the rest of my team when it comes to home office, days off and school."* (GetApp)

> *"Le rapport qualité prix de la solution est vraiment au top !"* (Capterra)

### Was kritisiert wird (echte Zitate)

> *"When the account executive at Lucca presented Figgo, I was told it was fully integrated with my payroll software. We had eventually a hard time integrate it, and at first, we charged .csv files into our payroll software."* (Capterra)

**Dies ist der wichtigste rote Punkt** — Sales-Versprechen zur Payroll-Integration wurden nicht eingehalten. Für ARK direkt relevant.

> *"I can't upload documents such as Birth Certificate and/or visa, my HR supervisor has to do it."* (GetApp)

→ Self-Service für Mitarbeitende hat Limitationen.

> *"There are some reports features I wish were added to Lucca but are not for now. All the data is on Lucca but the report feature only allows you to create that much graphs."* (Software Advice)

→ Reporting ist schwach; für ARK mit Power BI separate Integration nötig.

> *"La lisibilité de la donnée n'est pas toujours évidente et demande des vérifications supplémentaires notamment en période de paies."* (Capterra)

→ Datenqualität-Checks manuell nötig bei Lohnlauf.

### Einordnung

Die Reviews sind **überwiegend positiv** und betonen durchgehend UX und Einfachheit. Die Kritikpunkte sind klassisch für modulare SaaS: Integration-Versprechen, schwaches Reporting, Self-Service-Limits. Nichts davon ist ein Dealbreaker, aber alle drei sind **direkt relevant für ARK** und müssen in einer Demo geprüft werden.

---

## 7. Vergleich Lucca vs. alternativ

| Kriterium | Lucca | Personio | Bexio | Abacus |
|-----------|-------|----------|-------|--------|
| **CH-Präsenz** | **✅ Real** (Genf + Basel + Zürich, 7-Personen-Team, 100+ CH-Kunden) | ⚠️ DE-basiert, CH indirekt via HR Campus | **✅ Schweizer Unternehmen** (Luzern) | **✅ Schweizer Marktführer** (Wittenbach SG) |
| **Swissdec-Zertifiziert** | ❌ | ❌ (nutzt Partner) | **✅ ELM 5.3** | **✅ ELM 5.0** |
| **Modularität** | **✅ 12 Module à la carte** | ⚠️ Bundle-basiert | ⚠️ Paket-basiert | ✅ Module-basiert, aber komplex |
| **Preis / User / Monat** | ~CHF 9–20 | ~CHF 15–25 | pauschal CHF 35–115/Mt gesamt | ~CHF 20–80 (je Modul) |
| **UX / Design** | **✅ Sehr modern, benutzerfreundlich** | ✅ Modern | ⚠️ Konservativ | ❌ Veraltet, Berater-abhängig |
| **Mobile App** | ✅ iOS + Android | ✅ iOS + Android | ✅ bexioGo-App | ⚠️ AbaClik |
| **API / Integration** | ✅ REST-API, 150+ Integrationen | ✅ 800+ Integrationen | ✅ bLink REST | ✅ AbaConnect XML |
| **Zielgrösse** | KMU 5–2'000 MA (laut eigenen Claims) | KMU 10–2'000 | Mikro 1–25 MA | KMU 50+ |
| **Payroll-Strategie** | Daten-Übergabe an externen Provider | Preliminary Payroll + Partner | **Eigene Lohnbuchhaltung** (Swissdec) | **Eigene Lohnbuchhaltung** (Swissdec) |
| **Commission/Headhunter-Spezifik** | ❌ | ❌ | ❌ | ⚠️ via ERP-Module denkbar |
| **Transparenz Pricing** | ⚠️ intransparent | ⚠️ intransparent (Q3 Kritik) | ✅ transparent | ❌ Beratern-basiert |

### Kurz-Einordnung

- **Lucca** ist stärker bei UX, Modularität und CH-Präsenz als Personio
- **Lucca** ist **schwächer bei Payroll-Autonomie** als Bexio/Abacus (kann den Lohnlauf nicht selbst)
- **Lucca** passt am besten zu **modernen, UX-sensitiven KMU die extern Payroll-Provider haben** (z.B. Treuhänder) — genau ARKs Zielszenario

---

## 8. ARK-Fit-Check

### 8.1 · Lucca für ARK-intern (Phase 1, 10 MA)

**Pro:**
- CH-Hosting (Azure Zürich) = nDSG-konform
- Modulares Pricing = kein "alles-oder-nichts"
- Gute UX, Dark Mode fehlt aber (⚠️)
- Payroll-Assistant-Konzept = passt zu ARKs "Partner-Integration statt Eigenbau"-Strategie
- DE-Sprache verfügbar
- Sofort einsetzbar (wenige Wochen Setup vs. Monate bei Eigenbau)

**Contra:**
- Kein Dark Mode — konfligiert mit ARK-Design-Prinzip
- Kein Power-User-Keyboard-First-UI (Command Palette nicht dokumentiert)
- Keine Commission-Engine — ARK's Haupt-Pain-Point nicht gelöst
- Kein "Executive Search"-Kontext — generisches KMU-Tool
- Pricing intransparent, Paket-System komplex
- Reporting schwach (für Power BI-Nutzer wie ARK zusätzliche Integration nötig)
- **Vendor-Risiko:** Was passiert bei M&A? (Pento→HiBob-Muster aus Research-Synthese)

**Fazit für intern:** Lucca wäre eine **valide Zwischenlösung** wenn ARK Option B der Research-Synthese fährt (Hybrid: externes HR-Tool intern, Eigenbau erst später). Aber das ARK-spezifische Problem (Provisionsberechnung) löst Lucca nicht — das muss so oder so ins ARK-CRM.

### 8.2 · Lucca als SaaS-Benchmark (Phase 2, Referenz für eigenen Bau)

**Was ARK von Lucca lernen sollte:**

1. **Modulare Architektur à la carte** — jedes Modul kann separat gebucht werden, nicht "alles oder nichts"
2. **Payroll-Assistant als Architektur-Pattern** — Daten sammeln, an externen Provider übergeben, nicht selbst rechnen
3. **Mehrsprachigkeit von Anfang an** — CH-SaaS muss DE/FR/IT minimum
4. **CH-Hosting als Marketing-Feature** — Lucca kommuniziert das prominent
5. **Treuhänder-Programm** — Luccas `/fiduciary/`-Seite ist ein explizites Partner-Ökosystem. Für ARK-SaaS wichtig: Treuhänder als Multiplikator

**Wo ARK gegen Lucca differenzieren kann:**

1. **Commission-Engine** für Headhunter — Lucca hat das nicht
2. **Dark-Mode + Command Palette** — Lucca hat das nicht
3. **Tiefere CRM-Integration** (ARK baut es in einem Produkt, Lucca muss integrieren)
4. **Executive-Search-spezifische Entitäten** (Mandate, Placements, Desks)
5. **Bessere Transparenz beim Pricing**

### 8.3 · Entscheidungs-Matrix

Für die Frage "Lucca statt Personio als CH-KMU-Benchmark evaluieren?":

| Aspekt | Bewertung |
|--------|-----------|
| Q3's Behauptung "Lucca hat Basel-Office" | **✅ Bestätigt** |
| Q3's Behauptung "modulares Pricing" | **✅ Bestätigt** — stärker modular als Personio |
| Q3's Behauptung "CH-Fokus" | **✅ Bestätigt** — substanzielle Investition, aber Romandie-lastig |
| Q3's Behauptung "passt besser zu 15–30 MA" | ⚠️ **Teilweise** — passt auch für 5–50, aber Lucca richtet sich eigentlich an 50–500, nicht Kleinst-KMU |
| **Wert als Benchmark für ARK** | **Hoch** — UX-Vorbild, Architektur-Inspiration, realistischer CH-Mitbewerber für Phase 2 SaaS |
| **Wert als interne Lösung** | **Mittel** — ja möglich für Option B, aber löst ARKs Kernproblem (Provisionen) nicht |

---

## 9. Empfehlung

### Kurz-Version

**Lucca ist ein relevanter Benchmark — aber kein Ersatz für den Eigenbau des Commission-Kerns.** Die Lucca-Architektur bestätigt viele Thesen unserer Research-Synthese (Partner-Integration statt Eigenbau, modulare Struktur, Payroll-Assistant-Pattern). Für Phase 2 SaaS ist Lucca ein konkreter Konkurrent, den ARK ernstnehmen sollte.

### Konkrete nächste Schritte

1. **Demo buchen** bei Lucca CH (contact.luccasoftware.com) — Peter sollte:
   - Nach **DE-Sprach-Qualität** im Produkt fragen (Romandie-Lastigkeit war Kritikpunkt)
   - **Konkrete CHF-Preise** für 10 MA + gewünschten Modul-Mix verlangen
   - **Swissdec-Partner-Integration** konkret zeigen lassen (Abacus? SwissSalary? Bexio?)
   - **Payroll-Assistant live** demonstrieren lassen (war Kritikpunkt)
   - **Reporting-Fähigkeiten** prüfen (Power BI-Integration?)
   - **API / Webhook-Doku** einsehen (für künftige Integrationen)

2. **Zwei-drei Lucca-CH-Kunden kontaktieren** für Referenz (nicht via Lucca vermittelt, sondern direkt):
   - Kepler Cheuvreux (Finanz, ähnliche Grösse wie ARK)
   - UNIL (Bildung, grösser, aber CH-Admin-Fokus)
   - Debiopharm (Life Sciences, Lausanne)

3. **Demo-Resultat dokumentieren** in einem separaten Dokument (`ARK_LUCCA_DEMO_NOTES.md`) mit:
   - Konkrete Preisofferte
   - Screenshot-Vergleich zu ARK-Mockups
   - Integrations-Pfad zu ARK-CRM
   - Showstopper (falls ja, welche)

### Strategische Implikation für ARK

Wenn Lucca in der Demo überzeugt, wird **Option B der Research-Synthese attraktiver**:
- ARK-intern: Lucca für HR-Operations (CHF 2–4k/Jahr)
- ARK-CRM: Kernfokus Commission-Engine + Executive-Search-Features
- SaaS-Phase 2: ARKs Differenzierung gegen Lucca = Commission-Engine + Dark-Mode + Keyboard-First

Wenn Lucca **nicht** überzeugt (z.B. zu teuer, zu französisch-zentriert, Payroll-Integration nicht sauber): Zurück zu Bexio für ARK-intern.

---

## 10. Offene Fragen für die Demo

Konkret in Reihenfolge zu stellen:

1. **Swissdec:** "Welche Swissdec-zertifizierten Partner integriert ihr nativ? Abacus, SwissSalary, Bexio? Kann ich den Export live sehen?"

2. **Pricing:** "Für 10 MA mit Core HR + Leave + Timesheet + Performance + Payroll Assistant — was kostet das in CHF/Monat, inkl. Setup?"

3. **DE-Schweiz:** "Wie viele Deutschschweiz-Kunden habt ihr? Welche KMU unter 30 MA in der Deutschschweiz?"

4. **Commission / variable Pay:** "Könnt ihr Split-Provisionen (40/30/30 CM/AM/Hunter) abbilden, oder müsste das extern laufen?"

5. **API:** "Habt ihr eine offene REST-API mit Webhooks? Dokumentation?"

6. **Customization:** "Kann ich Custom Fields für Branchen-Spezifika (z.B. 'Desk', 'Sparte') anlegen?"

7. **Power BI:** "Gibt es einen Read-Only-DB-Zugang oder eine OData-API für Power BI-Reporting?"

8. **Dark Mode:** "Gibt es einen Dark Mode? Wenn nein, auf der Roadmap?"

9. **Kündigung:** "Was ist die Kündigungsfrist, und wie läuft der Datenexport bei Kündigung?" (wegen Bexio-Abo-Falle-Pattern)

10. **M&A-Stabilität:** "Lucca hat 2022 Series A genommen — wie ist eure Roadmap-Stabilität? Plant ihr weiteres Funding oder Exit?" (wegen Pento→HiBob-Muster)

---

## 11. Anhang: Lucca-Kontakt-Infos

- **Website CH:** https://www.lucca-software.ch/en
- **Demo buchen:** https://contact.luccasoftware.com/ch/request/en-demo
- **Telefon CH:** +41 22 596 74 71
- **Support Center:** https://support.luccasoftware.com/s/?language=en_US
- **Marketplace / Integrations:** https://marketplace.luccasoftware.com/en-ch/
- **Swiss-Subsidiary-Head:** Régis de Germay (LinkedIn)
- **Trustpilot-Profil:** https://fr.trustpilot.com/review/lucca.fr (nur FR-Instanz)

---

## Related

- `ARK_HR_RESEARCH_SYNTHESE_v0_1.md` — Gesamt-Synthese der HR-Recherche
- `ARK_HR_TOOL_RESEARCH_v0_1.md` — Research Pass 1 (Claude Code)
- `ARK_HR_TOOL_RESEARCH_v0_2.md` — Research Pass 2 (TCO-Vergleich)
- Künftig: `ARK_LUCCA_DEMO_NOTES.md` nach erfolgter Demo
- Künftig: `ARK_HR_TOOL_PLAN_v0_2.md` mit Option-B-oder-A-Entscheidung
