---
title: "ARK CRM — HR-Modul Research v0.1"
type: research
phase: 3
created: 2026-04-19
updated: 2026-04-19
status: draft
sources_external: [
  "Perplexity Deep-Research · 4 Split-Calls (Markt · CH-Compliance · Architektur · User-Feedback)",
  "Training-Wissen über HR-Tool-Reputation (transparente Quellen-Angabe bei Opinions)"
]
companions: [
  "ARK_HR_TOOL_PLAN_v0_1.md",
  "ARK_ZEITERFASSUNG_PLAN_v0_1.md",
  "ARK_ZEITERFASSUNG_RESEARCH_ADDENDUM_v0_1.md"
]
tags: [research, hr, markt, schweiz, compliance, architektur, ux, moduletrennung]
---

# ARK CRM — HR-Modul Research

Deep-Research als Grundlage für HR-Schema v0.1 + Interactions v0.1. Kombiniert externe Marktanalyse (4 Perplexity-Split-Calls) mit ARK-internem Kontext (HR-Plan v0.1, Zeiterfassung-Plan v0.1, Phase-3-ERP-Standalone-Prinzip).

---

## 1. Executive Summary

### Top-5 Erkenntnisse

1. **Swissdec-Zertifizierung ist faktisches CH-KMU-Must für Payroll-Anbindung** — ohne ELM-Standard-Export keine elektronische Lohnmeldung an AHV/BVG/SUVA/QST/ESTV. Selbst-Build braucht entweder eigene Swissdec-Zertifizierung (aufwändig) oder Partnerschaft mit Treuhänder/Bexio/Abacus (praktikabler).
2. **Konsolidierungs-Trend: HR + Payroll + IT als Single-Platform** — Personio/Rippling/Factorial fressen Einzel-Tool-Landschaft. Für ARK-Standalone-Strategie: Option als Full-Stack oder klare API-Strategie für Payroll-Partner.
3. **revDSG seit 09/2023 zwingt zu Verzeichnis der Bearbeitungstätigkeiten + DSFA für sensible Felder (Gehalt, Gesundheit, AHV-Nr)** — unabhängig von Biometrie. DSG-Layer ist Pflicht, nicht Nice-to-have.
4. **Architektur-Best-Practice: Person → Employment → Assignment → Position-Historisierung** mit bitemporalen Valid-from/Valid-to-Intervallen verhindert Daten-Explosion (40-60 Records/MA/Dekade statt 500). Workday-Komplexität vermeiden.
5. **SMB-Pain-Points (Reviews-Tenor G2/Capterra)**: Payroll-Bugs, falsche Ferien-Saldi, schlechte Mobile-Apps, Setup-Kosten > Lizenz-Kosten 1. Jahr, "noch ein Login". Treffen uns direkt — wir bauen gegen diese Probleme.

### Top-3 Must-haves

1. **Swissdec-ELM-Export** (AHV/IV/ALV/QST/UVG/KTG) in Swissdec-5.0-Format — sonst Treuhänder-kompatibilität fehlt
2. **Employee Self-Service mit DSG-konformem Auskunftsrecht-Export** (PDF + strukturierter JSON-Export der eigenen Daten nach Art. 25 revDSG)
3. **Absenzen-Workflow mit Team-Konflikt-Check + kantonalen Feiertagen** (26 Kantone, jährliches Seeding zwingend)

### Top-3 Don'ts

1. **Keine Cloud-LLMs für HR-Daten** — Gehälter, Arztzeugnisse, Background-Checks niemals zu OpenAI/Anthropic. Self-hosted LLM (ARK-Policy) konsequent durchziehen
2. **Keine Monolith-Update-Tabelle** — mutable `dim_mitarbeiter.salary` ohne Historisierung killt Audit-Trail und macht Back-Pay-Szenarien unmöglich
3. **Kein "Mobile-App-Zwang"** — responsive Web (PWA) reicht für <50 MA. Native-App-Wartung ist Scope-Killer für SaaS-Phase 2

---

## 2. Marktübersicht · HR-Tools für KMU (5-200 MA)

### 2.1 Tool-Matrix

| Tool | Zielgruppe | Region | Preis | Swissdec | USP | Relevanz ARK |
|------|-----------|--------|-------|----------|-----|--------------|
| **Personio** | 20-500 MA | DACH | EUR 9-25/MA/Mt | ✅ zertifiziert | All-in-One HR+Payroll, deutscher Marktführer KMU | Feature-Benchmark Nr.1 |
| **BambooHR** | 5-500 MA | US (EU begrenzt) | USD 4-13/MA/Mt | ❌ | Starker Self-Service, intuitive UX | UX-Inspiration Self-Service |
| **Factorial** | 5-500 MA | EU | EUR 4-12/MA/Mt | ❌ (CH-Payroll-Modul ja) | Günstig, modulares Pricing | Preis-Referenz Low-End |
| **HiBob** | 20-500 MA | UK/FR | GBP 6-15/MA/Mt | ❌ | Culture-Fokus, modern UX, Pulse-Surveys | UX-Inspiration Culture |
| **Rippling** | 5-500+ MA | US/UK | USD 8-15+/MA/Mt | ❌ (CH-Expansion) | HR+IT+Payroll Bundle, Device-Mgmt | Architektur-Referenz |
| **Gusto** | 5-100 MA | **US only** | USD 39/Mt + 6-12/MA | ❌ | Payroll-First, exzellente UX | nicht relevant für CH |
| **Workday** | 500+ MA | Global | USD 75-150/MA/Mt | ✅ | Enterprise-Standard | **Over-Scope** für uns |
| **SAP SuccessFactors** | 500+ MA | Global | Enterprise | ✅ | HR-Suite für Konzerne | Over-Scope |
| **Deel** | 5-200 MA | Global | Tiered + USD 15-50/Mt | ❌ | Global Payroll 150+ Länder, Contractor-Fokus | nur bei Remote-Workforce |
| **Remote.com** | 5-100 MA | Global | ähnlich Deel | ❌ | EOR-Service | nicht relevant |
| **Humaans** | 5-100 MA | UK | GBP 3-8/MA/Mt | ❌ | Lightweight, minimal | UX-Inspiration Minimalismus |
| **Zoho People** | 5-500 MA | Global | USD 1-4/MA/Mt | ❌ (CH-Payroll begrenzt) | Extremst günstig, Zoho-Ökosystem | Preis-Referenz |
| **Sage HR** | 5-200 MA | UK/EU | ab GBP 5/MA/Mt | ❌ (CH via Sage-Payroll) | Solide, Sage-Bundle | Mittelklasse-Referenz |
| **HRworks** | 20-500 MA | DACH | EUR 7/MA/Mt | ❌ | DACH-Fokus, solide Compliance | DACH-Referenz |

### 2.2 Schweiz-spezifische Tools

| Tool | Zielgruppe | Swissdec | Preis | USP | Relevanz ARK |
|------|-----------|----------|-------|-----|--------------|
| **Abacus HR** | 5-500 MA | ✅ Gold-Standard CH | CHF 4-8/MA/Mt | Treuhand-Integration, CH-Enterprise-Ready | **Payroll-Partner-Option** |
| **SwissSalary** | 5-100 MA | ✅ | CHF 3-7/MA/Mt | MS-Dynamics-basiert, Payroll-First | Alternative Payroll-Partner |
| **Bexio HR-Modul** | 5-50 MA | ✅ (Payroll) | CHF 14-99/Mt Bundle | Accounting + HR kombiniert | Billing-Partner (separates Phase-3-Modul) |
| **Swibeco** | 5-200 MA | ❌ (Benefits-Fokus) | Benefit-Basis | Mitarbeiter-Benefits-Plattform CH | Optional für Kartensystem |
| **Payroo** | Klein-KMU | ✅ Full-Service | Service-Basis | Full-Service-Treuhänder + Tool | Outsource-Option |
| **Eversports-HR** | Fitness-KMU | ❌ | branchenspezifisch | Nische | nicht relevant |

### 2.3 Open-Source

| Tool | Lizenz | Swissdec | Reife | Relevanz ARK |
|------|--------|----------|-------|--------------|
| **OrangeHRM** | AGPL + kommerzielle Version | ❌ | Mittel | Architektur-Referenz (Daten-Modell) |
| **Sentrifugo** | GPL | ❌ | Low, Community stagniert | nicht relevant |
| **IceHRM** | Kommerziell + Free-Tier | ❌ | Mittel | nicht relevant |
| **Odoo HR** | LGPL + Enterprise | ❌ (CH-Payroll-Partner-Module) | Hoch | Alternative für selbst-hosting Option (unwahrscheinlich) |

### 2.4 Markt-Trends 2024-2026

1. **All-in-One-Konsolidierung** — Personio + Rippling + Factorial erobern Einzeltool-Segment
2. **Payroll-Integration Default** — getrennte Payroll-Abwicklung verschwindet
3. **AI-Features** — Scheduling-Automation, Performance-Predictions, Chat-Bots (HiBob, BambooHR)
4. **DACH-Compliance als USP** — Swissdec-Zertifizierung + revDSG-Konformität zunehmend verlangt
5. **Culture-Analytics** — Pulse-Surveys, eNPS, Engagement-Scores als Feature-Erweiterung

### 2.5 Empfehlung Strategie ARK

**Standalone bauen (per Peter-Entscheidung)**, aber:
- **Payroll NICHT selbst abwickeln** — ARK liefert Daten-Lieferant für Treuhänder (Swissdec-ELM-Export) oder Bexio-Integration
- **Benchmarks**: Personio (Feature-Kanon), HiBob (UX-Inspiration), Factorial (Self-Service-Prägnanz)
- **Vermeiden**: Workday-Komplexität, Deel-Global-Focus, Gusto-US-Only-Features

---

## 3. Feature-Katalog · MoSCoW

Alle Features mit Priorisierung. **M**=Must-have · **S**=Should-have · **C**=Could-have · **W**=Won't-have.

### 3.1 Personal-Stammdaten

| Feature | MoSCoW | Quell-Tools | ARK-Notiz |
|---------|--------|-------------|-----------|
| Basis-Person (Name, Email, Handy, Geb.datum, Nationalität) | **M** | alle | erweitern `dim_mitarbeiter` |
| Adresse mit Kanton | **M** | alle CH-Tools | für QST-Tarif-Routing |
| Zivilstand, Sprachen, Muttersprache | **S** | Personio, Abacus | Infos für Team-Zuordnung |
| Notfallkontakte (1-2 Personen) | **M** | BambooHR, Personio | Sicherheitspflicht |
| Persönliche Dokumente-Ablage | **M** | alle | Vertrag, Zeugnisse, Policy-Signings |
| Passfoto, Portrait | **S** | alle | Identifikation + Org-Chart |
| Bank-Verbindung IBAN | **W** für HR | Payroll-only | lebt im Payroll-System, HR hat Ref |
| Familienstand-Historie | **S** | Personio | für Familienzulagen-Tracking |
| Hobbys, Interessen | **C** | HiBob (Culture) | optional, Team-Building |
| Driver-License, Car-Info | **C** | nur Fleet-Management-KMU | nicht für Headhunting |
| Medizinische Infos (Allergien, etc.) | **W** | — | DSG-heikel, nur in Notfall-Akte |

### 3.2 Arbeitsvertrag & Anstellung

| Feature | MoSCoW | Quell-Tools | ARK-Notiz |
|---------|--------|-------------|-----------|
| Vertragsart (unbefristet/befristet/Praktikum/Lehre) | **M** | alle | `fact_employment_contracts.contract_type` |
| Pensum % + Stunden/Wo | **M** | alle | mit Historisierung (Teilzeit-Änderung) |
| Eintritt/Austritt/Probezeit | **M** | alle | Auto-Alerts vor Probezeit-Ende |
| Arbeitsort, Home-Office-Regel | **S** | Personio, HiBob | Remote-Policy-Tracking |
| Kündigungsfrist (vor/nach Probezeit) | **M** | alle | Standard OR + Vertrag-Override |
| Konkurrenzverbot (Monate, Radius, Entschädigung) | **S** | Personio, Abacus | bei Senior-Vertrag wichtig |
| Ferien-Anspruch/Jahr | **M** | alle | Basis für Saldo-Berechnung |
| Überstunden-Regel (abgegolten/pauschal/mit-Lohn) | **S** | Personio | Cross-Ref zu Zeiterfassung |
| Vertrags-Dokument-Upload + Versionierung | **M** | alle | Vertrag-Nachträge, Lohnerhöhungen |
| Digitale Signatur (Skribble/DocuSign/SwissSign) | **S** | Personio, HiBob | CH: SwissSign/Skribble bevorzugt |
| Mehrfach-Verträge (Freelance parallel) | **C** | Deel | selten bei Headhunting |

### 3.3 Lohn & Vergütung

| Feature | MoSCoW | Quell-Tools | ARK-Notiz |
|---------|--------|-------------|-----------|
| Basislohn-Historie (bitemporal) | **M** | alle | valid_from/to, corrected_by |
| 13. Monatslohn (optional, pro rata) | **M** | alle CH-Tools | bei Ein-/Austritt mittelschwer |
| Bonus (pauschal/Ziel-basiert) | **S** | Personio, HiBob | einfach, Performance-Tool macht Ziel-Logik |
| **Provision (Split CM/AM/Hunter)** | **M** | **keine Standard-Lösung** | **ARK-Spezifikum · eigenes Modell** |
| Lohnnebenleistungen (Auto, ÖV, Laptop, Handy) | **S** | Personio, Abacus | Fringe-Benefit-Ausweis für QST |
| REKA-Lunch-Karte (bis CHF 180/Mt) | **S** | CH-Tools | tax-free-Benefit |
| Fitness-Beitrag, Jobticket, SBB-GA | **S** | Abacus | aus `fact_compensation_history.benefits` JSONB |
| Spesen-Erfassung (Belege + Reisekosten) | **C** für HR | Billing | **lebt in Billing** (Grauzone 7) |
| Lohnausweis Formular 11 | **M** | alle CH-Tools | Swissdec-Export Pflicht |
| Pro-rata bei Ein-/Austritt | **M** | alle | Standard CH |
| Kurzarbeit (KAE) Berechnung | **S** | Abacus, SwissSalary | Krisen-Feature, 24 Mt Ceiling bis 2026 |

### 3.4 Absenzen-Management

| Feature | MoSCoW | Quell-Tools | ARK-Notiz |
|---------|--------|-------------|-----------|
| Ferien-Anspruch (nach Alter/Pensum/Eintritt) | **M** | alle | CH-Gesetz 4 Wo (20 d), ab 20 J = 5 Wo (25 d) |
| Antrag-/Genehmigungs-Workflow | **M** | alle | Team-Konflikt-Check |
| Saldo-Tracking (Rest, Bezogen, Geplant, Übertrag) | **M** | alle | `fact_vacation_balances` |
| Übertrag ins Folgejahr + Verfall-Datum | **S** | alle | idR 30.06. / 31.12. |
| Krankheit (mit Arztzeugnis-Upload ab 3/5/7 Tage) | **M** | alle | keine Genehmigung, aber Cert-Pflicht |
| Mutterschaft 14 Wo (80 %, CHF 196/Tag max) | **M** | alle CH | EO-Automation |
| Vaterschaft 2 Wo (seit 2021) | **M** | alle CH | EO-Automation |
| Unbezahlter Urlaub | **M** | alle | separate Approval, GK-Impact |
| Militär/Zivildienst (EO 80 %) | **S** | CH-Tools | EO-Formular-Generator |
| Pflege-Urlaub 14 Wo krankes Kind | **S** | neu 2021 | Compliance |
| Kalender-Integration (Outlook/Google) | **S** | alle | Auto-Blockierung im Team-Kalender |
| Team-Kalender-View | **M** | alle | ARK Dashboard-Matrix ✓ |
| Outlook-Auto-Reply-Toggle | **S** | Personio, Factorial | beim Ferienantrag-Flow |
| Feiertags-Kalender (26 Kantone) | **M** | alle CH | jährliches Seeding |
| Half-Day-Booking | **M** | alle | UX-Anforderung |

### 3.5 Dokumente & Compliance

| Feature | MoSCoW | Quell-Tools | ARK-Notiz |
|---------|--------|-------------|-----------|
| Vertrag mit Versionen | **M** | alle | s.o. §3.2 |
| Arbeitszeugnis-Generator (Template-basiert) | **S** | Personio, Abacus | **CH-Rechts-Compliance-Nuancen** |
| Zwischenzeugnis | **S** | alle | auf MA-Wunsch |
| Policy-Akzeptanz (DSG-Policy, NDA, IT-Policy) | **M** | alle | elektronische Signatur |
| Hintergrund-Check-Report | **S** | BambooHR, Personio | sensibel, besondere ACL |
| Lohnausweis-Ablage (Self-Service-Zugriff) | **M** | alle | jährlich, 7 J. Retention |
| Pensionskasse-Unterlagen | **S** | Abacus | PK-Ausweis jährlich |
| DSG-Verzeichnis-Bearbeitungstätigkeiten | **M** | revDSG 2023 | Pflicht-Dokumentation |
| Einwilligungen (AI-Nutzung, Biometrie) | **S** | Personio | widerrufbar |
| nDSG-Schulungs-Nachweis | **S** | revDSG neu | jährliche Pflicht bei 250+ MA, kleiner empfohlen |

### 3.6 Onboarding / Offboarding

| Feature | MoSCoW | Quell-Tools | ARK-Notiz |
|---------|--------|-------------|-----------|
| Onboarding-Template (pro Rolle) | **M** | alle | Pre-Arrival/Day-1/Wo-1/Mt-1-3 |
| Task-Checklisten mit Owner + Deadline | **M** | alle | Buddy/Mentor-Zuweisung |
| IT-Zugangs-Provisioning (Email, CRM, VPN) | **S** | Rippling (Gold-Std) | für ARK: simpler, als externe Tool-Trigger |
| Probezeit-Ende-Reminder | **M** | alle | 30 Tage vor Ablauf |
| 30-/60-/90-Tage-Feedback-Gespräche | **M** | Personio, BambooHR | kalender-geführt |
| Offboarding-Checkliste (IT-Deprov., Geräte, Zeugnis) | **M** | alle | Kanban-Drag-trigger |
| Exit-Interview-Formular | **S** | Personio, HiBob | Fluktuations-Analyse |
| Alumni-Archivierung | **S** | Personio | Datenschutz-Retention |
| **Fingerprint-Terminal-Enrollment** | **W** für HR | Zeiterfassung | **lebt in Zeiterfassung** |

### 3.7 Organisation

| Feature | MoSCoW | Quell-Tools | ARK-Notiz |
|---------|--------|-------------|-----------|
| Organigramm (auto aus Hierarchie) | **M** | alle | interaktiv, Zoom/Pan |
| Teams/Abteilungen (cross-sparte möglich) | **M** | alle | `team` + `sparte_id` |
| Stellvertretungen | **S** | Personio | pro MA · für Ferien + Absenzen |
| Funktionsbeschreibungen | **C** | Workday | über-engineert für <50 MA |
| Dienstalter + Dienstjubiläum-Tracker | **S** | alle | Auto-Event bei 5/10/15/20/25 J. |
| Kompetenz-Matrix (Skills) | **C** | Workday, HiBob | besser im Performance-Tool |

### 3.8 Self-Service

| Feature | MoSCoW | Quell-Tools | ARK-Notiz |
|---------|--------|-------------|-----------|
| MA sieht eigenes Profil Read-Only | **M** | alle | Basis |
| Adress-Änderung durch MA | **S** | alle | mit HR-Bestätigung optional |
| Ferienantrag + Saldo | **M** | alle | primärer MA-Touchpoint |
| Lohnausweis-Download | **M** | alle | Self-Service |
| Zertifikat-Upload | **S** | alle | nach Schulung |
| Schulungs-Anforderung | **S** | Personio, HiBob | Budget-Check |
| **Auskunftsrecht-Export (DSG Art. 25)** | **M** | revDSG neu | PDF + JSON aller eigenen Daten |
| Notfallkontakt-Self-Edit | **S** | alle | mit Audit |
| Pay-Stub-Download (falls Payroll integriert) | **S** | alle | oder Ref zu externem Payroll |

### 3.9 Reporting / Analytics

| Feature | MoSCoW | Quell-Tools | ARK-Notiz |
|---------|--------|-------------|-----------|
| Headcount aktuell + Trend | **M** | alle | simpler Counter |
| Fluktuations-Rate (annual/quarterly) | **M** | alle | aus `fact_lifecycle_transitions` |
| Retention (Dienstalter-Cohorts) | **S** | Personio | für Senior-Fluktuations-Analyse |
| Kosten pro MA (inkl. Nebenleistungen) | **S** | Abacus | aus `fact_compensation_history` |
| Krankheits-Quote (Bradford-Faktor) | **S** | Personio | Bradford = S² × D |
| **Gender-Pay-Gap-Analyse** | **M** ab 100 MA | alle CH-Tools | Pflicht seit GlG 2020, 4-Jahres-Zyklus (ARK noch nicht Pflicht aber gut für SaaS-Phase 2) |
| Absenz-Trends | **S** | alle | heatmap-view |
| Onboarding-Dauer-Report | **C** | Personio | Optimierungs-Insight |
| Schulungs-Budget-Verbrauch | **S** | alle | Budget-Tracking |
| Kompensations-Benchmarking | **W** | extern | besser extern (Willis Towers Watson) |

### 3.10 Mobile

| Feature | MoSCoW | Strategie |
|---------|--------|-----------|
| Responsive Web (PWA) | **M** | alles · kein Native-App |
| Ferienantrag auf Mobile | **M** | mobile-optimiert |
| Krankmeldung auf Mobile | **M** | schnell, 3 Taps |
| Lohnausweis-Download | **S** | PDF-Viewer |
| Profil-View | **S** | Read-Only mobile |
| Native-App (iOS/Android) | **W** | Scope-Killer · später optional |

---

## 4. Schweiz-Spezifika

### 4.1 Sozialversicherungs-System (Pillar 1)

**AHV/IV/EO + ALV** (10.6 % AHV+IV+EO, 2.2 % ALV, split 50/50):
- AHV: 8.7 % (4.35 % AN + 4.35 % AG)
- IV: 1.4 % (0.7 % + 0.7 %)
- EO: 0.5 % (0.25 % + 0.25 %)
- ALV: 2.2 % bis CHF 148'200 (1.1 % + 1.1 %) · +1 % Solidaritäts-Beitrag darüber

**Kontribution-Obligation**: ab 1. Januar nach 17. Geburtstag · bis Referenzalter 65 (M) / 64 (F, wird 2028 auf 65 angehoben)

**Beitrags-Abrechnungs-Frequenz**: quartalsweise bei Jahreslohn <CHF 200k, monatlich darüber · Ausgleichskasse-Deadline: 10. Tag nach Quartals-/Monats-Ende

**Impact HR-Tool**: Kein eigenes AHV-Berechnung — das macht Payroll (Treuhänder/Bexio/Abacus). HR liefert nur korrekten Stamm (Eintritts-/Austritts-Datum, Pensum).

### 4.2 BVG / Pensionskasse (Pillar 2)

- **Koordinationsabzug 2025**: CHF 26'460 (unverändert wegen BVG-Reform-Ablehnung Herbst 2024)
- Min. koordinierter Lohn: CHF 3'780
- Max. koordinierter Lohn: CHF 64'260
- Mindest-Umwandlungssatz: 6.8 % (unverändert)
- Beitragssätze altersabhängig (25-34: 7 % · 35-44: 10 % · 45-54: 15 % · 55-65: 18 %)

**Impact HR-Tool**: `pensionskasse_name` + `pensionskasse_nr` + `pensum_percent` reichen. Berechnung im Payroll-System.

### 4.3 Unfallversicherung UVG

- **BU** (Berufsunfall): vom AG allein getragen, je nach Risikoklasse
- **NBU** (Nichtberufsunfall): vom AN getragen (ab 8 h/Wo)
- Höchstlohn CHF 148'200 (= ALV-Höchstlohn)

**Impact HR-Tool**: UVG-Anbieter pro MA erfassen (SUVA default, sonst Privat-Versicherer)

### 4.4 Quellensteuer (Grenzgänger + Ausländer ohne C-Ausweis)

**Tarife 2026** (monatliche Progression, 26 Kantone unterschiedlich):
- **A** = alleinstehend
- **B** = verheiratet, 1 Erwerb
- **C** = verheiratet, beide erwerbstätig
- **D** = Nebenerwerb
- **H** = alleinstehend + Kind
- Kanton-Tarife: z.B. ZH 2026 A0N @ CHF 500k = 20.85 % · ZG 16.72 % · BE 30.77 %

**Grenzgänger-Flat-Rate 4.5 %**: Frankreich/DE/IT/AT/LI mit Ansässigkeitsbescheinigung (FR) · sonst regulärer Tarif. Neu 2026: 40 % Teleworking zulässig ohne Verlust des G-Status.

**Impact HR-Tool**: `adresse_kanton`, `arbeitsbewilligung_typ`, `grenzgaenger BOOLEAN`, `quellensteuer_pflichtig BOOLEAN` erfassen. Tarif-Berechnung im Payroll.

### 4.5 Lohnausweis + Swissdec ELM

**Lohnausweis Formular 11 · Pflicht bis 31.01. Folgejahr**:
- Digitale Übermittlung via **Swissdec-ELM-Standard** (XML-basiert, Version 5.0 aktuell)
- 2026 NEU: Zusätzliche Felder für Firmenwagen, Geschenke, Teilzeit-Flag
- **eLohnausweis-SSK.ch**: kostenlose CH-Alternative für KMU ohne eigene Payroll

**ELM-Export-Felder**:
- Personal-Daten: AHV-Nr (13-stellig), Name, Geb., Adresse, Sprache
- Arbeitgeber-Daten: UID, Sitzkanton, BUR-Nr
- Lohn-Positionen: nach Swissdec-Codierung (Rubrik 1-15 im Lohnausweis)
- Kassen-Referenzen: AHV-Ausgleichskasse-Nr, PK-Nr, UVG-Anbieter

**Impact HR-Tool**:
- **Swissdec-Zertifizierung für ARK selbst = aufwändig** (Testing-Suite, jährliche Re-Zertifizierung)
- **Alternative**: CSV-Export in Swissdec-Format → Treuhänder/Bexio/Abacus macht ELM-Submission
- **Empfehlung**: Phase 3.0 CSV-Export · Phase 3.1+ ggf. ELM-Direkt-Anbindung

### 4.6 revDSG (seit 01.09.2023)

**Neue Pflichten**:
- **Verzeichnis der Bearbeitungstätigkeiten** (Art. 12) — wer verarbeitet was, wofür, wie lange (exempt unter 250 MA + Low-Risk, aber bei HR-Daten ohnehin angeraten)
- **DSFA** (Art. 22) bei hohem Risiko (Biometrie, umfangreiche sensible Daten)
- **Auftragsbearbeiter-Vertrag** mit SaaS-Vendoren
- **Informationspflicht** (Art. 19) bei Beschaffung — was, wofür, Empfänger, Speicherdauer
- **Auskunftsrecht** (Art. 25) — Export eigener Daten innert 30 Tagen
- **Berichtigungs- + Löschungs-Antrag** (Art. 32)

**Impact HR-Tool**:
- Self-Service-Export-Feature (DSG-Auskunft) als Must
- Retention-Policies pro Dokument-Typ (5/10 J.)
- Audit-Log bei sensible-Daten-Zugriffen (AHV aufdecken etc.)
- Einwilligungs-Modul für AI-Analyse-Features

### 4.7 Arbeitsbewilligungen

| Typ | Dauer | Impact |
|-----|-------|--------|
| **B** (Aufenthalt EU/EFTA) | 5 J. renewable | Expiry-Alert 3 Mt vorher |
| **C** (Niederlassung) | unbefristet | ok |
| **G** (Grenzgänger) | 5 J. bei >1 J. Anstellung, sonst = Vertrag | Expiry-Alert |
| **L** (Kurzaufenthalt <1 J.) | Vertrags-Dauer | Expiry-Alert + Reminder vor Neu-Antrag |
| **Ci** (Spezial, Diplomaten) | individuell | Expiry-Alert |

**Meldeverfahren** für EU/EFTA <90 Tage: keine Bewilligung, Online-Meldung am Vortag

**Impact HR-Tool**: `arbeitsbewilligung_typ` + `gueltig_bis` + Auto-Alert 90/30 Tage vor Expiry

### 4.8 Ferien/Mutterschaft/Vaterschaft/EO

**Ferien-Anspruch CH** (OR Art. 329a):
- 4 Wo = 20 Werktage (Minimum gesetzlich)
- ab 20. Altersjahr: 5 Wo = 25 Werktage (üblich)
- ARK-Default laut Mockup: 25 Tage (konform)

**Mutterschaft** (Art. 329f OR + MuschG):
- 14 Wochen bezahlt · 80 % AHV-Basis · max. CHF 196/Tag
- Verlängerung bei Spital-Aufenthalt des Kindes ≥2 Wo (max. +56 Tage)
- Stillzeit-Reduktion während 1. Lebensjahr

**Vaterschaft** (seit 2021):
- 2 Wochen bezahlt · 80 % · max. CHF 196/Tag
- Flexibel (Tage/Wochen) innert 6 Mt nach Geburt

**Pflege-Urlaub** (seit 2021): 14 Wo bei schwer krankem Kind, zwischen beiden Eltern teilbar, innert 18 Mt

**Militär-/Zivildienst-EO**: 80 % Lohn · Ersatzpflicht AG bei Unterschied

**Impact HR-Tool**: Absenz-Typen mit `counts_towards_vacation_balance=false` für diese, separate Berechnung

### 4.9 Kurzarbeit (KAE)

- **Max. 24 Mt seit 01.11.2025** (vorher 18 Mt, Erhöhung wegen Export-Krise)
- 80 % des Verdienstausfalls · finanziert durch ALV
- Monatliches Formular "Abrechnung KAE" (PDF + Online-Portal der Kantonalen Arbeitsämter)

**Impact HR-Tool**: Low-Priority (Krisen-Feature) · bei Einführung: Formular-Generator

### 4.10 Arbeitsgesetz ArG

- **Max 45 h/Wo** (Büro) · 50 h (andere)
- **Tägliche Ruhezeit 11 h**
- **Wochen-Ruhezeit 35 h inkl. Sa 23:00 - So 23:00**
- **Pausen**: 15 min (>5.5 h) · 30 min (>7 h) · 60 min (>9 h)
- **Nachtarbeit 23-06 Uhr**: +25 % Zuschlag (vorübergehend) oder 10 % Zeit-Ausgleich (permanent)
- **Sonntags-Arbeit**: +50 % Zuschlag (vorübergehend) oder Kompensations-Ruhezeit innert 4 Wo (permanent)

**Impact HR-Tool**: Für reine HR niedrig (lebt im Zeiterfassung-Tool). HR trackt nur Vertrags-Regeln (Pensum, Arbeitsort).

### 4.11 Schweiz-typische Benefits

| Benefit | Tax-Free-Limit | Impact HR-Tool |
|---------|----------------|----------------|
| **REKA-Lunch** | CHF 180/Mt (CHF 2'160/J) | Flag in `benefits` JSONB |
| **REKA-Money** | CHF 600/J (Rabatt-Anteil) | Flag |
| **Jobticket / SBB-GA** | CHF 800 effektiver Arbeitsweg steuerfrei | Flag |
| **Firmenwagen-Privatnutzung** | 0.9 % Katalogpreis/Mt als Einkommen | Swissdec Code 2.1 |
| **Dienstjubiläums-Geschenk** | CHF 500 (10 J.) · CHF 1'000 (25 J.) | Auto-Trigger bei Jubiläum |
| **Kinder-Geburts-Geschenk** | CHF 500 | ok |
| **Verlobungs-/Heirats-Geschenk** | CHF 300 | ok |
| **Weihnachts-Geschenk** | CHF 500 | ok |

**Impact HR-Tool**: `fact_compensation_history.benefits JSONB` + Dienstjubiläums-Alert

---

## 5. UX-Patterns & User-Feedback

### 5.1 Navigation-Patterns (aus Perplexity-Call + Training-Wissen)

**Sidebar-Navigation dominiert HR-Tools** (Personio · BambooHR · HiBob · Rippling · Factorial):
```
Dashboard (rollen-adaptiv)
├── People Directory (Search/Filter/Bulk)
├── Leave (Approvals Manager-Sicht · My Requests MA-Sicht)
├── Payroll (Payroll-only-Role)
├── Performance (separates Tool)
├── Documents (Self-Service)
├── Reports (Compliance/Turnover)
└── Settings (Admin)
```

**Top-Menü**: Nur bei Enterprise-Tools (Workday) · verwirrt SMB-User

### 5.2 Dashboard-per-Role

| Rolle | Dashboard-Content |
|-------|-------------------|
| **HR-Admin** | KPIs (Headcount · Fluktuation · offene Tasks) · Alert-Stream · Quick-Actions (Hire · Offboard · Announcement) |
| **Manager** | Direct Reports · Pending Approvals · Team-Kalender · Performance-Due-Dates |
| **Employee** | Eigenes Profil · Time-Off-Balance · Pay-Stubs · Org-Chart · Benefits-Link |

**ARK-Decision**: Dashboard-First für HR-Admin (Mockup bereits so gebaut ✓)

### 5.3 Approval-Workflow-UX

**Standard** (Personio, BambooHR):
1. Manager sieht "Requests"-Section mit Badge-Count
2. Click öffnet Detail-Card: Zeitraum · Grund · Coverage-Plan (Stellvertretung)
3. Approve/Reject/Comment-Buttons inline
4. Toast-Confirmation + Notification an MA
5. MA sieht Status-Change via WebSocket (real-time)

**ARK-Implementation**: analog, plus Team-Konflikt-Check (Banner zeigt "5/6 Team verfügbar" · rot bei <50 %)

### 5.4 Notification-Strategie

| Channel | Events |
|---------|--------|
| **Push** (mobile + desktop) | Ferienantrag rejected · Manager-Approval due · Probezeit-Ende-Alert · Zertifikat läuft ab |
| **Email** | Monatlicher Digest · neue Policy · Jahresgespräch-Termin |
| **In-App-Bell** | alle Events · Badge-Count · Click-to-Action |

**MA-Präferenz-Center**: opt-in/out pro Event-Typ

### 5.5 Mobile-Strategie

**Konsens aus Recherche**: PWA > Native-App für HR-SMB

**Begründung**:
- HR-Nutzung ist nicht high-frequency (im Schnitt 2-3× Woche)
- Approvals von MA-Seite: 1-2 min → responsive Web reicht
- Native-App-Wartung ≈ CHF 50k/J (2 Plattformen)
- **Ausnahme**: BambooHR/HiBob haben native Apps weil primary-driver

**ARK-Decision**: PWA · mobile-first responsive · **kein Native-App Phase 3**

### 5.6 Bulk-Operations

**Checkbox-Selection in Directory** mit Bulk-Action-Menü:
- Email-Broadcast
- Export CSV
- Department-Transfer
- Bulk-Approve-Ferien

**Command-Palette** (Cmd+K · Power-User-Feature):
- "transfer Anna Meyer zu Team ARC"
- "export Lohnausweise 2025"
- "zeige alle Probezeit-MA"
- "finde MA mit Scheelen-Zertifikat"

**ARK-Decision**: Cmd+K ist CRM-Baseline bereits (`.cmd-hint` in Header) — extend auf HR-Tool

### 5.7 Tabellen-Rendering

**Konsens**: Virtual-Scrolling > Paging bei HR (Directory mit 200+ MA)
- TanStack Virtual (React) oder Native CSS-Content-Visibility
- Paging nur bei Reports/Historie-Tabellen

### 5.8 Dark-Mode

**ARK-Policy**: Dark-Mode-only (aus CLAUDE.md)
- Tools mit gutem Dark-Mode: HiBob (excellent), Rippling (excellent), Personio (gut), Factorial (mittel)
- Tools ohne Dark-Mode: ältere ABACUS-Versionen, einige Bexio-Module

### 5.9 User-Feedback (aus Training-Wissen · Quellen nicht live verifizierbar)

**Achtung**: Perplexity-Call-C ist durchgefallen (keine Live-Quellen). Folgende Patterns basieren auf Training-Wissen bis April 2026 · Detail-Quellen-Verifikation via direkter G2/Capterra/Reddit-Zugriff empfohlen (Framework: siehe §9 Quellen).

**Was Nutzer LIEBEN (wiederkehrende Themen in Reviews 2023-2025)**:
- Personio: intuitive UX für HR-Admins · schneller Onboarding-Setup · gute Self-Service-App
- BambooHR: excellentes API · sofort-einsatzbereit · Support-Qualität
- HiBob: modern UI · Culture-Features (Shoutouts · Pulse-Surveys) · Dark-Mode
- Rippling: IT-Provisioning in HR-Workflow integriert ("one tool to rule them all")
- Abacus: CH-Treuhand-Standard · rechtssicher

**Was Nutzer HASSEN**:
- Personio: Payroll-Bugs bei DE-Sondersteuerfällen · langsame Mobile-App · Preis-Erhöhungen ohne klare Kommunikation
- BambooHR: Payroll nur US · kein revDSG-native · Setup-Fees hoch
- Rippling: Pricing-Komplexität ("6 Module hinzugefügt und plötzlich teurer als Personio") · Sales-Drück
- Gusto: nur US · gar nicht nützlich für CH
- Deel: Contractor-Pay fine · Employee-Teil schwach · Compliance-Fehler berichtet (Urlaubs-Berechnung falsch)
- Workday: "over-engineered für unser 50-MA-Team" · 6-12 Mt Implementation
- Alle: "Noch ein Login" (SSO-Integration Schmerzpunkt)
- Alle: Mobile-App-Flaws bei Ferien-Saldi (off-by-one-errors)

**SMB-spezifische Frustrationen** (5-50 MA):
1. **Setup-Kosten > Jahres-Lizenz** — Personio CHF 3-5k One-Time, BambooHR USD 2-4k
2. **Migration-Aufwand**: MA-Daten aus Excel/Personio/BambooHR migrieren = 40-80 Std.
3. **Training für HR-Admin**: 10-20 Std. Einarbeitung für volle Feature-Nutzung
4. **Pricing-Sprunghaftigkeit**: "Haben 30 MA, jetzt 31 → ganzes Tier teurer"
5. **Fehlende CH-Compliance-Tiefe** bei US-Tools (BambooHR, Rippling, Gusto)

**Enterprise-Frustrationen (für uns irrelevant)**:
- Workday: Kalibrierungs-Runden-UX
- SAP SuccessFactors: Custom-Reporting sehr komplex
- Oracle HCM: Datenmodell-Rigidität

**Was typischerweise abgelöst wird**:
- Excel + Email → Personio (häufigster DACH-KMU-Sprung)
- Sage HR → Personio / Factorial (Modernisierung)
- BambooHR US → Personio EU (Compliance-Migration)
- Personio → Workday (bei Wachstum 500+ MA)
- Custom-built → Factorial/Humaans (Wartungs-Kosten)

**HR-Admin vs. MA vs. Manager sagen unterschiedlich**:
- **HR-Admin**: "Reports sind nie granular genug" · "Integrationen zu Payroll immer wackelig"
- **MA**: "Ich will nur meinen Lohnausweis downloaden, warum dauert das 4 Klicks" · "App ist zu langsam"
- **Manager**: "Ich will keine 10 Emails pro Tag über Mini-Events" · "Team-Kalender ist Pflicht"

### 5.10 Versteckte Kosten (Reviews-Konsens)

- **Implementation-Fees**: oft 2-5× Monats-Lizenz
- **Data-Migration**: meist zusätzlich
- **Training**: selten inklusive
- **Annual-Review-Price-Hike**: 10-15 %/J. nicht unüblich
- **Integration-Fees** zu Payroll: CHF 500-2'000 einmalig, 50-200/Mt laufend

**ARK-Chance**: Standalone-Bau umgeht diese Kosten-Struktur · für SaaS-Phase-2 transparente Pricing-Kommunikation

---

## 6. Integrationen

### 6.1 Payroll-Anbindung Schweiz (Kritisch)

**Schnittstellen-Optionen**:
1. **Swissdec-ELM-Direkt-Anbindung** — ARK-Tool selbst Swissdec-zertifiziert. **Aufwand**: hoch (Test-Suite, jährliche Re-Zert, CHF 10-30k)
2. **CSV-Export Swissdec-Format** — Treuhänder macht Import. **Aufwand**: niedrig
3. **Bexio-API-Push** — Bexio macht Payroll + Lohnausweis. **Aufwand**: mittel (OAuth + JSON)
4. **Abacus-API-Push** — Abacus Payroll-Modul. **Aufwand**: mittel-hoch (proprietäres Format)
5. **SwissSalary-Integration** (MS-Dynamics-basiert) — selten bei CH-SMB

**Empfehlung Phase 3.0**: CSV-Export Swissdec-Format (universell) + Bexio-API-Push (für Bexio-Kunden)

### 6.2 CRM-Anbindung

**Bereits im ARK-CRM**: `dim_mitarbeiter` als zentrale Entity · HR-Tool erweitert dieselbe Tabelle · kein API-Layer nötig intern

**Für SaaS-Phase 2**: REST-API für Drittanbieter (LinkedIn-Recruiter-Sync, ATS-Systeme, etc.)

### 6.3 Kalender-Integration

- **Outlook / M365** — wir haben OAuth-Tokens aus Email-Tool · wiederverwenden
- **Google Workspace** — zusätzliche OAuth-Strategy · Phase 3.2 optional
- **CalDAV** (Apple/generisch) — Phase 3.3+ optional

**Use-Case**: Ferien-Eintrag auto als Kalender-Event · Auto-Reply-Aktivierung

### 6.4 Zeiterfassung

Cross-Dependency zu Phase-3-Zeiterfassung-Modul:
- HR-Tool = Source-of-Truth für Mitarbeiter-Stammdaten
- Zeiterfassung pullt Pensum, Feiertage-Kalender, Absenzen
- Zeiterfassung pusht Wochen-Abschluss-Events zurück (für Überstunden-Saldo)

### 6.5 Performance-Tool (Phase-3-separat)

- HR-Tool liefert MA-Stamm + Vorgesetzter-Hierarchie
- Performance pullt diese Daten
- Performance pusht Review-Ergebnisse zurück (in `fact_performance_reviews` — eigene Tabelle im Performance-Tool)

### 6.6 SSO

**Identity-Provider**:
- **Azure AD** (Microsoft 365) — primärer Partner für CH-KMU
- **Google Workspace** — sekundär
- **Okta** — Enterprise-SaaS-Phase-2

**Integration**: OAuth 2.0 + OpenID Connect · SAML fallback

### 6.7 E-Signatur

- **Skribble** (CH) — QES-konform, Schweizer Lösung, 200/J./MA
- **DocuSign** — global, teurer
- **SwissSign** — hart QES-konform für Behörden

**Empfehlung**: Skribble als Default für Phase 3.0 · DocuSign optional

### 6.8 Full-Service-Payroll-Provider

Alternative zu Integration: Kunden **nutzen ARK-HR + externer Payroll-Anbieter als Service**:
- **Payroo** (CH) — Full-Service-Treuhänder · ARK liefert Stamm-Daten
- **Rise Up** — Cloud-Payroll als Service
- **Loanwire** (CH) — Treuhand-Software mit HR-Modul-Import

---

## 7. Architektur-Empfehlungen

### 7.1 Daten-Modell

**Pattern: Person → Employment → Assignment → Position-History**

```
dim_mitarbeiter (= Person · immutable Identity)
  ├── ahv_nr_hash, ahv_nr_encrypted
  ├── vorname, nachname, email (mutable)
  ├── lifecycle_stage (Kanban-Status)
  └── 1:N → fact_employment_contracts (= Employment)
       ├── contract_type, pensum, eintritt, austritt
       ├── probezeit_ende, kuendigungsfrist
       └── N:N → bridge_mitarbeiter_roles (= Assignment)
            ├── rolle_id, valid_from, valid_to
            └── is_primary
       └── N:1 → sparte_id + team
       └── N:1 → vorgesetzter_id (self-ref)

fact_compensation_history (= Position)
  ├── valid_from, valid_until (bitemporal)
  ├── base_salary, commission_rate, benefits_jsonb
  └── sensitiver Scope · separate ACL
```

**Warum**: Jede Komponente evolviert unabhängig. MA wechselt Rolle ohne neuen Contract. Pensum-Änderung = neuer Contract ohne Identity-Duplicate.

### 7.2 Bitemporale Historisierung

**Für Salary + Contract**:
```sql
CREATE TABLE fact_compensation_history (
  id UUID PRIMARY KEY,
  mitarbeiter_id UUID,
  -- Valid-time (business)
  valid_from DATE NOT NULL,
  valid_until DATE,
  -- Transaction-time (audit)
  created_at TIMESTAMPTZ DEFAULT now(),
  created_by UUID,
  corrected_record_id UUID REFERENCES fact_compensation_history(id),
  base_salary_chf NUMERIC(10,2),
  -- ...
  EXCLUDE USING gist (mitarbeiter_id WITH =, daterange(valid_from, valid_until) WITH &&)
);
```

**Query "Was war Gehalt am 15.06.2025?"**:
```sql
SELECT base_salary_chf
FROM fact_compensation_history
WHERE mitarbeiter_id = $1
  AND valid_from <= '2025-06-15'
  AND (valid_until IS NULL OR valid_until > '2025-06-15')
  AND corrected_record_id IS NULL;
```

**Korrektur-Handling**: Never mutate — neuer Record mit `corrected_record_id` auf alten Row zeigend. Voller Audit-Trail.

**Storage**: 40-60 Records/MA über 20 J. (nicht 500) — Closed-Open-Intervals.

### 7.3 Multi-Tenant für SaaS (Phase 2)

**Tiered-Approach je KMU-Größe**:

| Tier | Pattern | Grund |
|------|---------|-------|
| **Tier 1** (5-30 MA) | **Shared Schema + RLS mit `tenant_id`** | niedrigste Latenz, simpel |
| **Tier 2** (30-200 MA) | **Schema-per-Tenant** (shared DB-Cluster) | stärkere Isolation, migrations isolated |
| **Tier 3** (200+ MA) | **Database-per-Tenant** | Enterprise-SLA, dedicated Resources |

**RLS-Implementation (Supabase-konform)**:
```sql
ALTER TABLE dim_mitarbeiter ENABLE ROW LEVEL SECURITY;

CREATE POLICY tenant_isolation ON dim_mitarbeiter
USING (tenant_id = current_setting('app.tenant_id')::UUID);
```

**ARK-Phase 1** (intern, 1 Tenant): kein RLS nötig. Phase 2 SaaS: RLS einführen.

### 7.4 RBAC-Granularität

**ABAC statt reinem RBAC** (Attribute-Based Access Control):
```
ALLOW IF role='HR_Manager' AND resource='mitarbeiter' AND action='*'
ALLOW IF role='Team_Lead' AND resource='mitarbeiter' AND relationship='direct_report' AND action='view'
DENY  IF resource='ahv_nr' AND role NOT IN ('HR_Manager','Admin') AND context != 'self'
ALLOW IF role='Employee_Self' AND resource='mitarbeiter' AND context='self' AND action IN ('view','edit_limited')
```

**Neue ARK-Rollen für HR-Tool**:
- `HR_Manager` — volle HR-Rechte, Audit-pflicht bei sensiblen Feldern
- `Team_Lead` — Team-Scope (via `vorgesetzter_id`-Kette)
- `Employee_Self` — eigene Daten only
- `Backoffice_Payroll` — Kompensations-Read + Lohn-Export

**Bestehende ARK-Rollen bleiben**: Admin, AM, CM, Researcher, Backoffice

### 7.5 Sensible-Daten-Trennung

**Multi-Layer-Ansatz**:

1. **Column-level Encryption** für AHV-Nr, Pass-Nr, Bank-IBAN:
```sql
ahv_nr_encrypted BYTEA,  -- pgcrypto AES-256
ahv_nr_hash TEXT         -- für Unique-Check ohne Decrypt
```

2. **Schema-Trennung** für Compensation + Medical:
```
public.dim_mitarbeiter                (basis, breiter Zugriff)
hr_sensitive.fact_compensation_history (separate Schema ACL)
hr_sensitive.fact_medical_records     (DSG-kritisch, nur HR+Admin)
```

3. **Immutable Audit-Schema**:
```
audit.hr_access_log (append-only, 7+ J. Retention, eigener Encryption-Key)
```

**Key-Management**: HashiCorp Vault oder Supabase Vault (Kanton-CH-hosted)

### 7.6 Event-Sourcing für Audit

**Für HR-Mutations**:
```sql
CREATE TABLE hr_events (
  event_id UUID PRIMARY KEY,
  event_type TEXT,
  aggregate_id UUID,                -- mitarbeiter_id
  data JSONB,                        -- {old_salary, new_salary, reason, by_whom}
  timestamp TIMESTAMPTZ,
  version INT
);

-- Materialized-View für aktueller State:
CREATE MATERIALIZED VIEW employee_current_state AS
SELECT DISTINCT ON (aggregate_id) ... ORDER BY aggregate_id, version DESC;
```

**Impact**: Vollständiger Audit-Trail, Instant-Rollback möglich, "What-If-Salary-Restatement"-Queries

**ARK-Decision**: Event-Sourcing selectively — nur für sensible Mutations (Kompensation, Rolle, Vertrag) · nicht für alle CRUD-Ops (Overhead zu hoch für <30 MA)

### 7.7 UX-Architektur

**Role-Adaptive Dashboard**:
- URL `/hr` → je nach Login-Rolle anderer Default-View
- HR-Admin → Dashboard-First (aktueller Mockup ✓)
- Manager → Team-Dashboard (eigenes Team)
- Employee → Self-Service-Profile

**Approval-Workflow**:
- WebSocket (Supabase Realtime) für Live-Status-Updates
- Toast-Confirmations
- Email-Digest als Backup (falls MA nicht online)

**Bulk-Operations**:
- Checkbox-Selection + Bulk-Action-Menu
- Command-Palette (⌘K) für Power-User

**Mobile-PWA**:
- Next.js + next-pwa
- Service-Worker für Offline-Read (Ferien-Saldo, Profil)
- Write-Operations require online (Verhinderung Sync-Konflikte)

---

## 8. Modul-Abgrenzung · die 11 Grauzonen

### 8.1 Ferien / Absenzen-Management → **HR**

**Empfehlung**: HR ist Source-of-Truth.

**Begründung**:
- Absenzen sind HR-Compliance-Pflicht (Lohnfortzahlung, EO, Mutterschaft) — HR muss es können
- Zeiterfassung ist täglicher Stunden-Track · konsumiert Absenzen als Mirror
- Personio/BambooHR/Factorial: alle haben Absenzen in HR-Core
- **Präzedenz**: Personio, HiBob, BambooHR — Absenz-Modul in HR

**Cross-Ref**: HR-Tool `fact_absences` · Zeiterfassung liest als Read-Only-Mirror

### 8.2 Mitarbeiter-Jahresgespräche → **Performance**

**Empfehlung**: Performance-Tool (Phase-3-separat)

**Begründung**:
- Jahresgespräch-Fragen + 360°-Feedback + Kompetenz-Matrix = eigene Logik
- HR-Tool: nur Terminierung + Ergebnis-Archiv (abgespeichert als PDF in `fact_hr_documents`)
- **Präzedenz**: Lattice, 15Five, Culture Amp = separate Tools · Personio hat "Performance-Modul" getrennt

**Cross-Ref**: Performance-Tool pullt MA-Stamm · pusht Review-Ergebnis (PDF) zurück

### 8.3 Zielvereinbarungen → **Performance**

**Empfehlung**: Performance-Tool

**Begründung**:
- OKR/MBO-Framework, Goal-Tree, Cascading = Performance-Domain
- HR: nur Placements/Umsatz-Ziele als KPI-Referenz
- **Präzedenz**: Workday unterteilt HCM vs. Performance; Personio "Performance" Add-on

### 8.4 Onboarding-Checklisten → **HR**

**Empfehlung**: HR-Tool (nicht separates Modul, nicht Performance)

**Begründung**:
- Onboarding ist Lifecycle-Prozess (neuer MA) — kein eigenes Tool wert
- Template-basiert: 20-30 Tasks pro Rolle
- **Präzedenz**: BambooHR, Personio, Factorial — alle Onboarding in HR-Core

### 8.5 Weiterbildungsplanung + Budget → **HR**

**Empfehlung**: HR-Tool (light) — kein eigenes LMS

**Begründung**:
- Budget-Tracking + Anträge + Zertifikat-Upload = HR
- LMS mit Kurs-Delivery = **externe Tools** (LinkedIn-Learning, Udemy Business) — nicht selbst bauen
- **Präzedenz**: Personio "Training" Add-on · HiBob hat Learning-Modul

**Cross-Ref**: Training-Teilnahme-Daten aus externen LMS importieren (optional Phase 3.6)

### 8.6 Lohnabrechnung / Lohnlauf → **Billing (getrennt vom HR)**

**Empfehlung**: Billing-Modul (= Phase-3-separat) oder externer Treuhänder

**Begründung**:
- Payroll = hochspezialisiert (AHV-Berechnung, QST-Tarif-Tabellen, Swissdec-Zertifizierung) — **NICHT in HR**
- HR liefert Daten (Pensum, Eintritt/Austritt, Bank-Ref) an Payroll
- Payroll schreibt Lohnausweis + Pay-Stub zurück in HR-Documents-Ablage
- **Präzedenz**: Selbst Personio trennt HR-Core von Personio-Payroll (separates Modul)

**Cross-Ref**: HR-Tool sendet monatlichen Delta-Export (CSV Swissdec-Format) an Treuhänder oder Billing-Modul

### 8.7 Spesen-Erfassung + Abrechnung → **Billing**

**Empfehlung**: Billing-Modul

**Begründung**:
- Spesen = Rechnungs-/Buchungs-Logik (Debitor-MA/Kreditor-AG, MWST-Behandlung)
- HR kennt Spesen-Pauschalen (als Vertrags-Feld), aber Erfassung + Genehmigung = Billing
- **Präzedenz**: SAP Concur, Expensify — separate Tools · Personio hat Spesen als Add-on (getrennt von HR-Core)

**Cross-Ref**: HR liefert MA-Stamm an Billing · Billing approved Spesen · pusht Monats-Summe an Payroll-Export

### 8.8 Geburtstags-/Jubiläums-Glückwünsche intern → **HR**

**Empfehlung**: HR-Tool (Trigger) + Kommunikations-Modul (Versand)

**Begründung**:
- HR kennt Geb.datum + Eintritts-Datum
- HR triggert Event: "Anna hat heute Geburtstag" / "Max hat 10-J-Dienstjubiläum"
- Kommunikations-Modul sendet Slack/Email/Karte
- **Präzedenz**: HiBob "Shoutouts" · integriert in Culture-Section

**Cross-Ref**: HR-Event → Kommunikations-Worker → Slack-Post oder Email-Template

### 8.9 Interne Stellenausschreibungen → **Job-Posting**

**Empfehlung**: Job-Posting-Modul (Phase-3-separat)

**Begründung**:
- Intern-Post = gleicher Mechanismus wie Extern-Post (Syndikation) · nur Filter "internal_only"
- HR-Tool: Link zu Job-Posting · Empfehlungs-Boni-Tracking (wenn MA neue MA wirbt)
- **Präzedenz**: LinkedIn Recruiter: Internal-Mobility-Modul · BambooHR: Hiring-Modul separat von HR

### 8.10 Provisionsberechnung (Split CM/AM/Hunter) → **CRM-Kern + Billing**

**Empfehlung**: **Geteilte Verantwortung**:
- **CRM-Kern**: erfasst Split-Prozent pro Prozess/Placement (Memory `project_commission_model.md`)
- **Billing**: berechnet Provisions-Auszahlung aus CRM-Splits + Lohn-Perioden
- **HR**: Read-Only-Anzeige aktuelles Provisions-Modell als Vertrags-Ref

**Begründung**:
- Fee-Split ist CRM-Daten (am Placement gehängt)
- Auszahlungs-Timing ist Billing-Logik (Q-Auszahlung + Garantiefrist)
- HR ist Konsument, nicht Author
- **ARK-Spezifikum**: kein Standard-Tool hat das native — eigene Logik

**Cross-Ref**: `fact_placement_commissions` (CRM) · `fact_payroll_commissions` (Billing) · `fact_compensation_history.commission_rate` (HR · nur Standard-Rate für Vertrag)

### 8.11 Arbeitsvertrags-Verwaltung → **HR**

**Empfehlung**: HR-Tool

**Begründung**:
- Vertrag = HR-Domain (Pensum, Kündigungsfrist, Ferien-Anspruch)
- Versionierung + Nachträge + digitale Signatur = HR-Feature
- Allgemeines Dok-Modul für unstrukturierte Dokumente · Vertrag ist strukturiert
- **Präzedenz**: alle HR-Tools haben Vertrag in Core

### 8.12 Summary-Tabelle Grauzonen

| # | Grauzone | Modul | Präzedenz-Standard |
|---|----------|-------|--------------------|
| 1 | Ferien/Absenzen | **HR** | Personio, BambooHR, Factorial |
| 2 | Jahresgespräche | **Performance** | Lattice, Personio-Add-on |
| 3 | Zielvereinbarungen | **Performance** | Workday, Personio-Add-on |
| 4 | Onboarding-Checklisten | **HR** | BambooHR, Personio |
| 5 | Weiterbildungsplanung | **HR (light)** | Personio-Training, HiBob-Learning |
| 6 | Lohnabrechnung | **Billing/Treuhänder** | Personio-Payroll separat, Bexio, Abacus |
| 7 | Spesen-Abrechnung | **Billing** | Concur, Expensify |
| 8 | Geburtstags-Glückwünsche | **HR-Trigger + Kommunikation-Versand** | HiBob Shoutouts |
| 9 | Interne Stellen | **Job-Posting** | LinkedIn-Internal-Mobility, BambooHR-Hiring |
| 10 | Provisionsberechnung | **CRM + Billing, HR nur Read-Only** | ARK-Spezifikum (kein Standard) |
| 11 | Arbeitsvertrags-Verwaltung | **HR** | alle HR-Tools |

---

## 9. Quellen

### 9.1 Direkt zitiert (Perplexity-Research 2026-04-19)

**Call A · Marktübersicht** (medium reasoning):
- [1] G2 Reviews · personio.de, bamboohr.com, factorial.io, hibob.com, rippling.com, gusto.com
- [2] Capterra Ratings 2024-2025
- [3] Vendor-Websites · Pricing-Seiten

**Call B · CH-Compliance** (high reasoning):
- [1] BSV · bsv.admin.ch · Swiss Social Insurance Pocket Stats 2025
- [2] Taxolution CH · Withholding-Tax-Guide
- [3] eLohnausweis-SSK.ch · Free-Tool
- [4] LE Global Law · Kurzarbeit-Extension-24-Mt (Oct 2025)
- [5] LeaveNetwork Switzerland 2024
- [6] Leglobal · Employment-Law-Switzerland
- [7] Datenschutzkanzlei · revDSG 2023-Guide
- [8] SMZH BVG 2024
- [9] SEM · Cross-Border FAQ
- [10] Schwiizerfranke · 13. Monatslohn-Rechner
- [11] Reka · Medienmitteilung Reka-Rail+
- [12] ESTV · Lohnausweis-Rentenbescheinigung
- [16] AHV-IV · Merkblatt 2.01.e Beiträge
- [21] SAP-Docs Swissdec-ELM-Integration
- [25] Ibani Work Permits Guide
- [28] Applic8 Swiss Working Hours
- [31] ESTV Salary-Certificate-Pension-Statement
- [39] RTA · Vaterschaftsurlaub-ab-2021
- [41] Moneyland · Taxes-Employee-Benefits
- [45] Reka · Reka-Lunch-Employer-Info
- [48] Global-Compliance-News · revDSG-Employer-Action
- [49] VisaHQ 2025-11-01 · 24-Month-Short-Time-Work

**Call C · User-Feedback** (fehlgeschlagen):
- Perplexity konnte keine Live-Quellen ziehen → Training-Wissen genutzt mit expliziter Markierung · Verifikations-Framework in §5.9

**Call D · Architektur** (high reasoning):
- [1] OrangeHRM-Docs · Employee-Data-Model
- [2] Personio Engineering Blog · Schema-Design-Hinweise
- [3] Workday Engineering (indirekt)
- [4] PostgreSQL-Docs · pgcrypto, RLS
- [5] Rippling Tech-Talks · Event-Sourcing
- [6] Standard-Literatur · Bitemporal-Patterns (Fowler)
- [7] PostgreSQL RLS-Patterns

### 9.2 ARK-intern

- `ARK_HR_TOOL_PLAN_v0_1.md` (heute)
- `ARK_ZEITERFASSUNG_PLAN_v0_1.md` (heute)
- `ARK_ZEITERFASSUNG_RESEARCH_ADDENDUM_v0_1.md` (heute)
- Memory: `project_arkadium_role.md`, `project_commission_model.md`, `project_phase3_erp_standalone.md`, `feedback_worktree_sync_main.md`, `feedback_mockup_first_workflow.md`
- `raw/Ark_CRM_v2/ARK_DATABASE_SCHEMA_v1_3.md` · `ARK_BACKEND_ARCHITECTURE_v2_5.md` · `ARK_STAMMDATEN_EXPORT_v1_3.md`

### 9.3 Empfehlung für weitere Verifikation

Da Call C (User-Feedback) fehlgeschlagen ist, für Dienstag-PO-Review zusätzlich prüfen:
- **G2.com/categories/hr** · Filter "Europe" + "500 or less employees"
- **Capterra.ch** (CH-spezifisch)
- **Reddit r/humanresources** · Search "Swiss" + "Schweizerdeutsch"
- **Reddit r/Switzerland** · Search "Personio", "Abacus", "Bexio HR"
- **LinkedIn-Groups** · "Swiss HR Community", "HR Switzerland"
- **Swissdec-Zertifizierungsliste** · swissdec.ch für Vendor-Validation
- **FINMA-Anforderungen** falls Finanz-Kunden · eigene HR-Specs

---

## 10. Next Steps für Plan v0.2 + Schema v0.1

Basierend auf diesem Research Updates für `ARK_HR_TOOL_PLAN_v0_1.md`:

1. **Plan §2 Markt-Überblick** erweitern mit Tool-Matrix aus §2.1+2.2
2. **Plan §3 CH-Recht** erweitern mit konkreten Werten (Koordinationsabzug CHF 26'460, QST-Tarife pro Kanton, ArG-Pausen-Regeln)
3. **Plan §6 Datenmodell** ergänzen mit Encryption-Layer (`ahv_nr_encrypted BYTEA`) + Multi-Tenant-RLS-Skizze für Phase 2
4. **Plan §7 UI-Scope** — Command-Palette-Feature einbauen
5. **Plan §8 Phasen** — Swissdec-CSV-Export in Phase 3.0, Bexio-Push in Phase 3.1
6. **Plan §11 Offene Entscheidungen** — erweitern um: Swissdec-Direkt-Anbindung vs. CSV-Export, E-Signatur-Partner (Skribble/DocuSign/SwissSign), Full-Service-Payroll-Option (Payroo)
7. **Grauzonen-Entscheidungen** aus §8 als Architektur-Baseline fixieren

Nach Peter-Review Dienstag → Plan v0.2 + Schema v0.1 + Interactions v0.1 schreiben.

---

## Related

- `ARK_HR_TOOL_PLAN_v0_1.md` — Umsetzungsplan · Grundlage
- `ARK_ZEITERFASSUNG_PLAN_v0_1.md` · `ARK_ZEITERFASSUNG_RESEARCH_ADDENDUM_v0_1.md` — Parallele Phase-3-Planung
- Künftig: `ARK_HR_TOOL_SCHEMA_v0_1.md` · `ARK_HR_TOOL_INTERACTIONS_v0_1.md`
- Künftig: `ARK_BILLING_PLAN_v0_1.md` · `ARK_PERFORMANCE_PLAN_v0_1.md` · `ARK_PUBLISHING_PLAN_v0_1.md` · `ARK_KOMMUNIKATION_PLAN_v0_1.md`
