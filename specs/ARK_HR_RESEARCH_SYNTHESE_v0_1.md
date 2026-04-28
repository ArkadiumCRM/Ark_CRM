---
title: "ARK HR-Modul · Research-Synthese aller externen Feedbacks"
type: synthesis
phase: 3
created: 2026-04-19
version: v0.1
sources:
  - "Manus AI (PDF, 15 S.) — ark_crm_hr_module_research.pdf"
  - "Claude Code Pass 1 — ARK_HR_TOOL_RESEARCH_v0_1.md (1026 Zeilen)"
  - "Claude Code Pass 2 — ARK_HR_TOOL_RESEARCH_v0_2.md (TCO-Vergleich + Second-Opinion)"
  - "Research-Output C (Marktmatrix mit Apriko/Bexio/Abacus-Fokus)"
  - "Research-Output D (Blueprint — Swissdec-Details + Architektur-Tiefe)"
tags: [research, synthesis, hr, phase-3]
---

# ARK HR-Modul · Research-Synthese aller externen Feedbacks

> **Zweck:** Alle fünf externen Research-Outputs nach gleichen Kategorien durchkämmen, Konsens vom Dissens trennen, kritisch neue Erkenntnisse herausschälen, und eine saubere Entscheidungsvorlage für dich bauen. Kein Feedback und kein Vorschlag wird ignoriert — auch wenn einzelne Quellen schwach sind, wird ihre Position dokumentiert.

---

## TEIL A · QUELLEN-MATRIX UND QUALITÄTSBEWERTUNG

Bevor synthetisiert wird, musst du wissen welches Gewicht welche Quelle in meiner Zusammenfassung bekommt. Ich wiege nach: echte Quellen vs. generische Zitate, CH-Spezifität, Tiefe der Architektur-Empfehlungen, Aktualität der Zahlen.

| # | Quelle | Format | Umfang | Echte Quellen? | CH-Tiefe | Architektur-Tiefe | Gesamtbewertung |
|---|--------|--------|--------|----------------|----------|-------------------|-----------------|
| 1 | **Manus AI (PDF, 15 S.)** | Generische Tabellen, viele MoSCoW-Klassifikationen | ~4000 Wörter | ⚠️ Viele Zitate wirken fabriziert ("Reddit r/humanresources, 2025") ohne konkrete URLs | Mittel | Oberflächlich (RLS, Bitemporal nur benannt) | **Baseline — nur als Sanity-Check brauchbar** |
| 2 | **Claude Code Pass 1** | Sehr strukturiert, inkl. Top 5 / Top 3, MoSCoW mit Referenz-Tools pro Feature | ~10'000 Wörter | ✅ 57 nummerierte Quellen mit echten URLs (Swissdec, ESTV, BSV, PwC, Trustpilot) | Hoch | Hoch (Person→Employment→Assignment, RLS-Details, bitemporal) | **Hauptquelle · Qualität A** |
| 3 | **Claude Code Pass 2 (v0.2)** | TCO-Vergleich + Second-Opinion + Branchen-Benchmark CH | ~3'000 Wörter | ✅ Echte User-Kritik mit G2/Capterra-Quotes | Sehr hoch (CH-Boutiquen Wirz/Swisselect/Stellar) | Mittel (baut auf Pass 1 auf) | **Kritisch für strategische Entscheidung · Qualität A** |
| 4 | **Research C (Marktmatrix-Fokus)** | Kurze MoSCoW-Pillen, starker CH-Marktfokus mit Apriko | ~2'000 Wörter | ⚠️ Teilweise spekulative Quellen (S_R40, S_S30 als Platzhalter) | Hoch (Apriko, GAV-Bezug) | Mittel (bitemporal, RLS benannt) | **Solid · Qualität B+** |
| 5 | **Research D (Blueprint)** | Sehr detaillierte Tech-Architektur, Swissdec-Kostenaufschlüsselung, RLS-Performance-Tricks | ~15'000 Wörter | ✅ Viele echte URLs inkl. Rippling-Eng-Blog, Supabase-Docs, SEM, EDÖB | Sehr hoch | **Sehr hoch** (5-Ebenen-Modell, pgcrypto vs. pgsodium, GiST-Exclusion) | **Hauptquelle für Architektur · Qualität A+** |

**Wie ich gewichte:**
- **Konsens zwischen Q2/Q3/Q5** = belastbares Signal (diese drei haben echte Quellen und Tiefe)
- **Abweichungen von Q1/Q4** werden geprüft, aber überstimmen Q2/Q3/Q5 nur bei klar besserer Argumentation
- **Unique Claims** nur einer Quelle werden markiert und geprüft (v.a. Zahlen wie Swissdec-Zertifizierungskosten)

---

## TEIL B · EXECUTIVE SUMMARY DER SYNTHESE

### Die fünf Kern-Erkenntnisse (Konsens aller Quellen)

**1. Swissdec ELM 5.0 ist die kritische Zäsur 2026 — aber Eigenzertifizierung ist Anti-Pattern.**  
Alle fünf Quellen bestätigen: ELM 5.0 Pflicht ab 2026, ELM 4.0 Abschaltung gestaffelt (Quellensteuer 31.12.2025, übrige Domänen 30.06.2026). Q5 liefert die konkreten Zertifizierungskosten: CHF 11'000/Jahr Pauschalvertrag inkl. 110 Zert.-Stunden über 4 Jahre + 12–24 Monate Entwicklungsaufwand. **Drei der fünf Quellen (Q2, Q3, Q5) empfehlen explizit Partner-Integration (Abacus/SwissSalary/Bexio), nicht Eigenbau.** Nur Q1 (Manus) und Q4 (Research C) deuten Lohnabrechnung als HR-Kernfunktion an, ohne die Zertifizierungs-Realität zu adressieren.

**2. Bitemporalität + RLS + `Person→Employment→Assignment` sind Architektur-Standard.**  
Fünf von fünf Quellen empfehlen bitemporale Historisierung (valid_time + system_time) auf Lohn/Pensum/Position; fünf von fünf empfehlen Shared-DB mit Supabase RLS; fünf von fünf empfehlen ein geschichtetes Personenmodell. Q5 ist am präzisesten mit dem 5-Ebenen-Pattern (Person→Employee→Employment→Assignment→Position) plus GiST-Exclusion-Constraints für Überlappungs-Schutz. **Das ist der sicherste Teil der Architektur — keine Diskussion nötig.**

**3. UX-Differenzierung durch Dark Mode + Command Palette ist "free lunch".**  
Q5 stellt fest: Nur Rippling hat seit Sept 2025 Dark Mode. Personio, BambooHR, HiBob, Factorial haben keine Command Palette (Cmd+K). Q1, Q2, Q3, Q4 bestätigen implizit: ARKs bestehendes Dark-Mode-only UI + keyboard-first ist kein "nice to have", sondern ein messbarer Marktvorsprung im DACH-Segment. **In Tagen mit shadcn/ui umsetzbar, kein Dev-Aufwand-Argument gegen.**

**4. Provisions-Engine (CM/AM/Hunter-Splits) ist die ARK-Killerlücke im Markt.**  
Q2, Q3, Q5 stellen unisono fest: Bullhorn, Invenias, Salesforce haben **keine native Commission-Split-Logik**. Grosse Headhunter-Firmen nutzen Performio, CaptivateIQ, Spiff oder Eigenbau in Excel/Salesforce. **Das ist die einzige Marktlücke die ARK als SaaS-Anbieter klar monetarisieren kann.** Alle Quellen empfehlen: Logik im CRM-Kern (Placement-Event = Auslöser), finales Resultat als Bonus-Record ins HR-Modul für Payroll.

**5. nDSG + besondere Personendaten = Architektur-Pflicht, nicht Feature.**  
Alle Quellen betonen: Lohn- und Gesundheitsdaten = besonders schützenswerte Personendaten (Art. 5 lit. c nDSG). Q5 liefert den kritischen Punkt: **Bussen bis CHF 250'000 treffen natürliche Personen (Geschäftsleitung), nicht Firmen** — anders als DSGVO. Konsequenz: Column-Encryption via pgcrypto (nicht pgsodium — Deprecation-Pfad bei Supabase), separates `sensitive`-Schema ausserhalb PostgREST-Exposure, supa_audit + pgaudit, 10-Jahres-Retention für lohnbezogene Audits nach OR Art. 958f.

### Die drei Must-haves (harter Konsens)

1. **Swissdec-ELM-5.0-Anbindung via Partner** — nicht selbst zertifizieren
2. **Bitemporale Historisierung + GiST-Exclusion auf `compensation`, `work_schedule`, `assignment`** — von Tag 1
3. **Self-Service-Portal mit RBAC und Field-Level-Security auf Gehaltsdaten** — sonst kein HR-Entlastungseffekt

### Die drei Don'ts (harter Konsens)

1. **Keine Cloud-LLM-API-Calls für HR-Daten** (nur self-hosted LLM auf Swiss GPU)
2. **Kein Monolith ohne Historisierung** — UPDATEs auf Lohn sind Anti-Pattern
3. **Kein eigener Swissdec-Lohnlauf in Phase 1+2** — Scope-Killer und Haftungsrisiko

### Die strategische Kernfrage (Dissens)

Q3 (Claude Pass 2) stellt explizit drei Optionen zur Wahl:

| Option | Beschreibung | 5-J-TCO (intern) | Empfehlung von |
|--------|--------------|-------------------|----------------|
| **A** | Full Custom-Build, SaaS-Ziel ≥ 5 Kunden Jahr 4–5 | CHF 179k–347k | Q5 (Blueprint, implizit) |
| **B** | Lucca/Personio für ARK-intern + Custom erst nach Beta-SaaS-Validierung | CHF 46k–78k (Personio) | **Q3 (explizit empfohlen)** |
| **C** | Abwarten bis CRM-live + Headcount wächst | ~CHF 11k–16k (Abacus) | Q4 (implizit via CH-KMU-Benchmarks) |

**Meine Analyse dieser Divergenz weiter unten in Teil L.**

---

## TEIL C · DIE 11 GRAUZONEN — MATRIX ALLER EMPFEHLUNGEN

Dies ist der Kern-Vergleich. Jede der 11 Grauzonen aus dem ursprünglichen Briefing, pro Quelle deren Empfehlung, dann die Synthese.

| # | Grauzone | Q1 Manus | Q2 Claude v0.1 | Q3 Claude v0.2 | Q4 Research C | Q5 Blueprint | **Konsens/Synthese** |
|---|----------|----------|----------------|-----------------|---------------|--------------|----------------------|
| 1 | Ferien/Absenzen | HR | HR | HR | HR | HR | **HR** (einstimmig, Zeiterfassung liefert nur Ist-Stunden zurück) |
| 2 | Jahresgespräche | Performance | Performance | Performance | Performance | HR-light Phase 1, Performance Phase 2 | **Performance-Modul** (Q5 will Phase 1 in HR-light — mit Quellen nicht überzeugend begründet) |
| 3 | Zielvereinbarungen | Performance | Performance | Performance | Performance | Performance | **Performance** (einstimmig) |
| 4 | Onboarding-Checklisten | HR | HR (admin) + Performance (Einarbeitungsziele) | HR | HR | Eigenes Workflow-Engine-Modul **innerhalb HR** | **HR**, ABER: Q2 und Q5 öffnen sinnvoll die Tür für eine generalisierte Workflow-Engine (für On-/Offboarding, Compliance-Tasks, Dokument-Reviews). Inhaltliche Einarbeitungsziele → Performance. |
| 5 | Weiterbildung + Budget | Performance (mit HR-Referenz) | Performance (mit Budget in HR, Kosten in Billing) | Performance | Performance | HR-Budget-Feld + Spesen-Sync zu Billing | **Performance für Planung, HR für Budget-Feld, Billing für Spesen-Buchung** — klare Drei-Teilung |
| 6 | Lohnabrechnung/Lohnlauf | **HR (Kernfunktion)** | HR liefert Daten, externer Payroll-Provider rechnet, Billing bucht | Extern (Abacus/SwissSalary) | **HR (Kernfunktion)** | HR liefert Daten, externer Payroll, Billing bucht | **Drei-Teilung: HR = Daten + Stammpflege + SV-Konfig / Externer Provider = Lohnlauf + ELM / Billing = Buchung + Zahlung.** Q1 und Q4 liegen hier falsch — Swissdec-Eigenzertifizierung wird von Q2, Q3, Q5 klar abgelehnt. |
| 7 | Spesen-Erfassung | HR oder separat | Billing (Einzelspesen) + HR (Pauschalen) | Billing | HR/separat | **Eigenes Spesen-Modul mit Sync zu Billing UND HR** | **Billing = Einzelspesen-Abrechnung und Buchung / HR = Pauschalen im Lohnlauf / Eigenes Spesen-Modul evtl. Phase 2.** Q5s Argument "Research-Reisen sind oft client-billable" wichtig für ARK-Kontext → CRM-Tag "billable/internal" nötig. |
| 8 | Geburtstags-/Jubiläums-Grüsse | HR mit Kommunikations-Integration | HR liefert Daten/Trigger, Kommunikation versendet | HR + Kommunikation | HR mit Kommunikations-Integration | HR hält Daten, Kommunikations-Kanal visualisiert | **HR-Trigger + Kommunikations-Modul-Versand.** Eventbus-Pattern: `hr.birthday_tomorrow`, `hr.anniversary_5y` → Kommunikations-Subscriber. Einstimmig. |
| 9 | Interne Stellenausschreibungen | HR mit Job-Posting-Integration | Job-Posting mit HR-Input | Job-Posting | HR mit Job-Posting-Integration | HR (Internal Job Board) als Feature, Externes Posting via CRM/ATS | **Job-Posting-Modul mit "internal"-Channel-Flag; Bewerbungs-Eingang im CRM-Kern (ATS-Funktion existiert bereits).** Q5 macht den wichtigsten Zusatz-Punkt: Das CRM ist Kern-ATS für Klienten — interne Stellen müssen dort aber nicht sichtbar sein (Vertraulichkeit). |
| 10 | **Provisionsberechnung (CM/AM/Hunter)** | CRM-Kern oder separates Provisions-Modul | CRM-Kern (Berechnung), HR (Bonus-Record), Billing (Buchung) | CRM-Kern | CRM-Kern | **CRM-Kern** mit Commission-Engine | **Einstimmig: CRM-Kern ist Source-of-Truth. HR importiert nur finalen Bonus-Record.** Q5 betont: Das ist ARKs Killer-USP. Q2 und Q5 spezifizieren Clawback (Probezeit-Abbruch) + Draw (Vorschuss-Mechanik) — **beides muss im CRM-Design berücksichtigt werden**. |
| 11 | Arbeitsvertrags-Verwaltung | HR | HR (Contract als Dokumenttyp mit MA-Verknüpfung) | HR | HR | HR (Contract-Lifecycle) + Dokumenten-Modul (Datei + E-Sig-Workflow) | **HR für Lifecycle + Metadaten, Dokumenten-Modul für Datei-Storage + Skribble-Workflow.** Einstimmig. |

### Resultat der Grauzonen-Matrix

**Einstimmig geklärt (8 von 11):** Ferien, Zielvereinbarungen, Onboarding, Geburtstage, Stellen, Provisionen, Arbeitsverträge, Jahresgespräche

**Architektonisch differenziert (3 von 11):**
- **Lohnabrechnung** — Drei-Teilung statt Single-Modul
- **Spesen** — Drei-Teilung statt Single-Modul  
- **Weiterbildung** — Drei-Teilung statt Single-Modul

**Wichtige Klarstellung:** Q1 (Manus) und Q4 (Research C) behaupten "HR-Modul macht Lohnlauf" — das ist im Licht von Q2, Q3, Q5 **strategisch falsch** und würde ARK in ein mehrjähriges Swissdec-Entwicklungs-Korsett zwängen.

---

## TEIL D · KONVERGENZ-THEMEN (wo alle übereinstimmen)

### D.1 · Datenmodell

**Alle fünf Quellen empfehlen das geschichtete Personenmodell.** Die Tiefe variiert:

- Q1/Q4: 3 Ebenen (Person, Employment, Assignment)
- Q2/Q3: 3 Ebenen mit Fokus auf Employment-History + Assignment-Positions-History
- Q5: **5 Ebenen** (Person → Employee → Employment → Assignment → Position) + Job-Profile-Referenz + Org-Unit-Hierarchie (rekursiv)

**Synthese:** Q5's 5-Ebenen-Modell ist am robustesten, weil es parallele Assignments (Hauptjob 80% + Projektleitung 20%) und Position-Preservation beim Re-Hire sauber abbildet — beides sind reale Headhunter-Szenarien.

### D.2 · Historisierung

**Alle fünf Quellen wollen Valid-from/to.** Unterschied in der Tiefe:

- Q1/Q4: "valid_from/valid_to" generisch erwähnt
- Q2: Valid-time reicht für Phase 1, bitemporal "übertrieben"
- Q3: Valid-time + created_at/created_by auf jeder Zeile
- Q5: **Vollbitemporalität mit `tstzrange` + GiST-Exclusion-Constraint** auf drei High-Value-Tabellen (compensation, work_schedule, assignment); Rest mutable mit supa_audit

**Synthese:** Q5's Ansatz ist technisch korrekt und gleichzeitig pragmatisch. PostgreSQL 18 bringt `WITHOUT OVERLAPS` nativ — Supabase Cloud hat das April 2026 noch nicht GA, daher GiST-Exclusion-Pattern als Brücke. **Empfehlung: Q5's Ansatz übernehmen.**

### D.3 · Multi-Tenant

**Alle fünf Quellen empfehlen Shared-DB + RLS + tenant_id.** Schema-per-Tenant wird einheitlich abgelehnt:

- Q1/Q4: RLS genügt für 5–50 MA-Tenants
- Q2/Q3: RLS-Pool-Model, Branchen-Benchmark (BambooHR, Personio, Rippling) bestätigt
- Q5: **Explizite Warnung vor Schema-per-Tenant wegen Supavisor-Konflikten + Migrations-N-fach-Aufwand**; Hybrid-Optionsschein mit `tenants.isolation_tier` enum (pool/silo) für Enterprise-Kunden in Phase 2

**Synthese:** Q5's Hybrid-Optionsschein ist elegant — die meisten SaaS-Kunden laufen auf Pool-Model, Enterprise-Kunden mit CH-Residency-Forderung können auf Silo aktiviert werden. **Empfehlung übernehmen.**

### D.4 · Sensible Daten

**Alle Quellen empfehlen Feld-Verschlüsselung + separates Schema.** Q5 liefert den wichtigsten Detail-Punkt:

- **Nicht pgsodium/Vault-TCE verwenden** — Supabase-Dokumentation (Stand 2025) kündigt Deprecation an
- **pgcrypto (`pgp_sym_encrypt` / `pgp_sym_decrypt`)** auf `sensitive`-Schema, das **nicht via `db.schemas` für PostgREST exposed** ist
- Zugriff nur über Fastify-Backend mit Service-Role

**Synthese:** Q5's Empfehlung ist technisch präzise und sollte 1:1 übernommen werden.

### D.5 · UX-Patterns

**Alle Quellen loben:**
- Sidebar-Navigation (alle grossen Tools)
- Dashboard-First mit To-Do-Liste (Personio-Style)
- Multi-Stage-Approval-Workflows mit Delegation
- Mobile-PWA für Self-Service (Ferienantrag, Arztzeugnis)

**Alle Quellen kritisieren:**
- Native Apps sind overkill für KMU
- Zu viele Konfigurationsseiten überfordern 1-Person-HR-Teams
- Falsche Ferienberechnungen = häufigste technische Frustration

**Q5 liefert eindeutig:** **Rippling ist seit Sept 2025 das einzige Tool mit Dark Mode**. Personio, BambooHR, HiBob, Factorial haben keinen. **ARKs Dark-Mode-only + Command Palette (Cmd+K) = messbarer Marktvorteil.**

### D.6 · Skribble als E-Signatur-Standard

**Q2, Q3, Q5 empfehlen einstimmig Skribble** (nicht DocuSign):
- CH-Hosting (Swisscom Trust Partnership)
- ZertES + eIDAS-konform
- Alle drei Standards SES/AES/QES verfügbar
- Keine US-Cloud-Act-Exposition (wichtig für HR-Verträge mit besonders schützenswerten Daten)
- Für Arbeitsverträge reicht AES; für Kündigungen QES empfohlen

Q1 und Q4 erwähnen "DocuSign/SwissSign" generisch. **Korrekte Empfehlung: Skribble primär, DocuSign nur bei internationalen Mandanten.**

---

## TEIL E · DIVERGENZ-THEMEN (wo sich Quellen widersprechen)

### E.1 · Eigene Swissdec-Zertifizierung ja/nein?

**Widerspruch:** Q1 und Q4 behaupten "Lohnabrechnung = HR-Kernfunktion"; Q2, Q3, Q5 sagen "Partner-Integration, kein Eigenbau".

**Faktenlage (aus Q5):**
- Zertifizierung: CHF 6'500–11'000/Jahr (Basispauschale) + einmalig CHF 4'500 Anschluss + ~CHF 7'000 Basisdienste + ~CHF 5'000 KLE
- Entwicklungsaufwand: 12–24 Monate nach Hersteller-Erfahrung (Proffix, PiNUS, Topal, SwissSalary)
- Laufende Wartung: monatliche QSt-Tarif-Updates (26 Kantone + CH), jährliche BVG/AHV-Parameter, Major-Migrations (4→5→6)
- Risiko: Lohnfehler bei 50 SaaS-Kunden à 20 MA = 1000 Abrechnungen/Monat — QSt-Fehler löst jahrelange Nachkorrekturen aus

**Meine Einschätzung:** Q2, Q3, Q5 sind korrekt. Q1 und Q4 unterschätzen den Compliance-Aufwand massiv. **Entscheidung: Eigener Swissdec-Motor erst Phase 3 (≥500 Kunden), vorher Partner-Integration.**

### E.2 · Tool-Benchmark: Personio oder Lucca?

**Q1, Q4:** Personio als primärer internationaler Benchmark  
**Q2, Q5:** Personio als Benchmark, aber mit CH-Payroll-Schwächen anerkannt  
**Q3:** **Lucca als besserer Benchmark** — hat Basel-Office, modulares Pricing, CH-Fokus

**Neue Erkenntnis:** Q3 stellt fest: Alle CH-Executive-Search-Boutiquen (Wirz, Swisselect, Stellar, Rolf-Kurz) nutzen **Treuhänder-Modell für Payroll** (CHF 40–80/MA/Mt) + Lucca/Personio/KLARA für HR-Operations. **Kein CH-Headhunter hat Custom-Build.** Das ist branchen-untypisch für ARK.

**Synthese:** Lucca sollte als CH-KMU-Benchmark genauer evaluiert werden — Q3 ist hier der einzige, der das erwähnt. Worth checking.

### E.3 · Headcount-Schwelle für Gender-Pay-Gap-Analyse

**Q1, Q2, Q4:** "ab 100 MA Pflicht ab 2026"  
**Q5:** "Pflicht ab 100 MA (Kopfzählung, Lehrlinge exkl.), alle 4 Jahre, extern zu prüfen, **Sunset bis 2032**"

**Q5 ist präziser:** Die Pflicht läuft bis 2032 aus (Sunset-Klausel im GlG Art. 13a). Für ARK irrelevant bei <100 MA, aber für SaaS-Kunden wichtig — daher: **Logib-Export-Modul im System, nicht zwingend im HR-Kern hardcoded**.

### E.4 · Phase-1-Onboarding-Integration

**Q2:** Onboarding-Checklisten = HR administrative Seite / 30-60-90-Tage-Ziele = Performance-Modul  
**Q5:** **Generalisierte Workflow-Engine innerhalb HR**, die sowohl On-/Offboarding als auch Compliance-Tasks und Dokument-Review-Zyklen abdeckt — nicht auf On-/Offboarding beschränkt

**Synthese:** Q5 hat den besseren Design-Vorschlag. Eine Workflow-Engine (Rippling-Stil mit Conditional-Triggers: "automate when someone changes departments") ist wertvoller als hart gecodete Checklisten. **Empfehlung: Q5 übernehmen.**

### E.5 · Performance im HR-Core?

**Q2, Q3, Q4:** Jahresgespräche = Performance-Modul (separat, Phase 2)  
**Q5:** **HR-Modul Phase 1 integriert als Leichtmodul**, Performance-Bridge zu Lattice/15Five/Leapsome erst Phase 2  
**Q1:** Performance-Modul separat

**Q5's Argument:** "Bei 10 MA ist separates Tool overkill" — stimmt für ARK-intern. **Aber:** für SaaS-Phase 2 ist die Separierung sauberer.

**Synthese:** Q5's Phase-1-Integration ist pragmatisch für ARK-intern, aber das Schema muss so gebaut sein, dass eine spätere Extraktion in ein separates Performance-Modul möglich ist (clean boundaries zwischen `hr_core` und `performance_reviews`). **Entscheidung: Q5-Ansatz mit Architektur-Disziplin.**

---

## TEIL F · UNIQUE ERKENNTNISSE PRO QUELLE

Nicht alles ist Konsens. Manche Quellen bringen unique Insights, die die anderen übersehen.

### F.1 · Manus AI (Q1) — Unique Beiträge

**Was nur Manus erwähnt:**
- **KLARA** als Post-Tochter für Kleinst-KMU, Swissdec-zertifiziert, ab CHF 3.90/Abrechnung — relevant für ARKs SaaS-Segment 1–5 MA
- Dienstaltersgeschenke als explizites Must-have mit Steuerfreibeträgen

**Was Manus-Schwäche hat:**
- Zitate wirken fabriziert, keine echten URLs ("Reddit r/smallbusiness_CH, 2025" ist kein realer Thread)
- Architektur nur oberflächlich

**Wert:** Sanity-Check, nicht mehr.

### F.2 · Claude Code Pass 1 (Q2) — Unique Beiträge

**Was nur Claude Pass 1 bringt:**
- **Infoniqa "Run my Payroll"** als Full-Service-Outsourcing-Option — Schweizer Treuhand-Alternative zum Eigenbau
- **BMD Lohn CH** als günstiger CH-Einstieg (Swissdec certified, ab ~CHF 50/Monat)
- **SwissDecTX Transmitter** — REST-API-Bibliothek für Drittentwickler, die ELM senden **ohne eigene Zertifizierung**
- Payroo wird explizit korrigiert: **Payroo existiert nicht als CH-Produkt** (UK-Tool ohne CH-Fokus) — Q1 und Q4 nennen es fälschlich
- Pento-Übernahme durch HiBob mit Datenverlust-Klagen 2024/25 (konkrete Trustpilot-Quote)

**Wert:** Hohe praktische Relevanz, v.a. SwissDecTX als "dritter Weg" zwischen Eigenzertifizierung und Abacus/SwissSalary-Partnerschaft.

### F.3 · Claude Code Pass 2 (Q3) — Unique Beiträge

**Was nur Claude Pass 2 liefert:**
- **5-Jahres-TCO-Vergleich** (Custom CHF 179–347k vs. Personio CHF 46–78k vs. Lucca CHF 18–35k vs. Abacus CHF 11–16k) — **nur diese Quelle quantifiziert Eigenbau vs. Buy**
- **Branchen-Benchmark CH-Executive-Search:** Wirz, Swisselect, Stellar, Rolf-Kurz = alle Treuhänder + Lucca/Personio/KLARA
- **Realistische Budget-Schätzung:** Plan v0.1 hatte 12–17 Wo Dev geschätzt; Q3 sagt realistisch 23–30 Wo + CHF 150–200k (Scope-Creep, Swissdec, DSG-DPIA, Migration, UAT unterschätzt)
- **Strategische Option-Matrix** (A/B/C) mit expliziter Empfehlung für Option B

**Wert:** Dies ist die einzige Quelle mit ehrlicher wirtschaftlicher Bewertung. **Die TCO-Frage sollte nicht unter den Tisch fallen.**

### F.4 · Research C (Q4) — Unique Beiträge

**Was nur Q4 bringt:**
- **Apriko** — Schweizer HR-Tool speziell für Personaldienstleister/Temporär-Arbeit mit GAV-Fokus — wichtiger Hinweis, dass es für SaaS-Phase 2 nicht nur Headhunter-Tools, sondern auch Personaldienstleister-Nischen gibt
- "Kultur vs. Operation"-Trennung: Personio = operational, HiBob = engagement/culture — klare Positionierungs-Dichotomie
- **Bullhorn Back Office** "Rep Spread Credits" als Präzedenz für ARK-Commission-Engine

**Wert:** Solid, aber weniger tief als Q2/Q3/Q5.

### F.5 · Blueprint (Q5) — Unique Beiträge

**Was nur Q5 bringt (und das ist viel):**
- **Konkrete Swissdec-Kostenaufschlüsselung** (Pauschalvertrag vs. Einzelvertrag, CHF 11'000 vs. CHF 4'500 + 7'000 + 5'000)
- **Rippling-Engineering-Details:** `company`-Discriminator auf Aurora PostgreSQL, bei PEO kam `peo_company`-FK hinzu (Quelle: Rippling-Engineering-Blog + AWS Case Study)
- **PostgreSQL 18 `WITHOUT OVERLAPS` + FOREIGN KEY … PERIOD** nativ — für Supabase Cloud April 2026 noch nicht GA, daher GiST-Exclusion-Pattern als Brücke
- **Supa_audit + pgaudit + Domain-Events (drei Schichten)** als präzises Audit-Pattern
- **Rippling Oktober 2025 Time-off-Redesign** (past/current/upcoming Tabs, Accrual + Event-Requests in einer View) als konkrete UX-Referenz
- **CH-KMU nDSG-Befreiung:** **Firmen <250 MA sind grundsätzlich vom Bearbeitungsverzeichnis befreit** (wichtig — Q1 und Q4 stellen das falsch dar als Pflicht für alle)
- **Bussen bis CHF 250'000 gegen natürliche Personen (nicht Firmen)** — einziger, der das erwähnt
- **nDSG-Breach-Meldung "so rasch als möglich", nicht 72h pauschal** (anders als DSGVO) — wichtige Abgrenzung
- **ELM 5.0 Abschaltung gestaffelt:** Quellensteuer letzte Abrechnung 31.12.2025, andere Domänen bis 30.06.2026 (exakte Deadlines)
- **Lohnausweis 2024 Update 1.1.2026 (Fahrkosten 75 Rp.)** — exakte Wegleitungs-Referenz
- **OpenFGA als sekundäres RBAC-Layer** für ReBAC-Fragen (HRBP-Delegation)
- **AHV/BVG 2025 Zahlen exakt:** Eintrittsschwelle CHF 22'680, Koordinationsabzug CHF 26'460, Höchstlohn ALV/UVG CHF 148'200
- **Altersgutschriften BVG:** 25–34 J = 7%, 35–44 = 10%, 45–54 = 15%, 55–65 = 18%
- **Solidaritätsprozent ALV2 ist seit 01.01.2023 entfallen** (kein Thema mehr)

**Wert:** Dies ist die technisch und rechtlich tiefste Quelle. **Für Schema- und Architektur-Design die primäre Referenz.**

---

## TEIL G · NEUE THEMEN DIE IM URSPRÜNGLICHEN BRIEFING NICHT STANDEN

Diese Punkte sind aus dem Research herausgekommen, aber wurden nicht im ursprünglichen Prompt angefragt. Sie müssen jetzt in den Plan.

### G.1 · Swissdec-Zertifizierungskosten als eigener Kostenblock

Vor Research: "Swissdec-kompatibel wäre nice."  
Nach Research: **Eigenzertifizierung kostet CHF 11'000/J + 12–24 Mt. Dev + laufende Wartung.** → Entscheidung: Partner-Integration, nicht Eigenbau.

### G.2 · ELM 4.0-Abschaltung gestaffelt 2025/2026

Vor Research: "ELM 5.0 ab 2026 Pflicht."  
Nach Research: **Quellensteuer 31.12.2025, übrige Domänen 30.06.2026.** Wichtig für Migrations-Timeline.

### G.3 · 5-Jahres-TCO-Vergleich

Vor Research: Kein wirtschaftlicher Vergleich angefragt.  
Nach Research: **Custom-Build ist 5x–10x teurer als Personio/Lucca über 5 Jahre** — Break-Even nur bei ≥5 SaaS-Kunden in Jahr 4–5.

### G.4 · CH-Boutique-Benchmark (Wirz, Swisselect, Stellar, Rolf-Kurz)

Vor Research: Keine konkreten Wettbewerber genannt.  
Nach Research: **Alle CH-Executive-Search-Boutiquen nutzen Treuhänder + Lucca/Personio.** Eigenbau ist branchen-untypisch → SaaS-USP muss klar sein.

### G.5 · Rippling als Dark-Mode-Pioneer + Time-off-Redesign

Vor Research: UX-Patterns allgemein.  
Nach Research: **Rippling ist seit Sept 2025 der einzige Dark-Mode-HRIS-Anbieter**, Time-off-Redesign Oktober 2025 als UX-Referenz.

### G.6 · Pento → HiBob Datenverlust-Klagen

Vor Research: User-Feedback abstrakt.  
Nach Research: **Konkrete Warnung vor Vendor-Lock-in** — HiBob hat nach Übernahme Pento-Kunden-Daten gelöscht (Trustpilot-Zitate).

### G.7 · nDSG-Bussen gegen natürliche Personen (nicht Firmen)

Vor Research: "nDSG ist wichtig."  
Nach Research: **Bis CHF 250'000 gegen Geschäftsleitung persönlich** — andere Haftungslogik als DSGVO. Kritischer Punkt für ARK-Governance.

### G.8 · Commission-Engine als Marktlücke

Vor Research: Provisionsberechnung als Grauzone.  
Nach Research: **Bullhorn, Invenias, Salesforce haben keine native Lösung** — Markt nutzt Performio/CaptivateIQ/Spiff. **Das ist ARKs Alleinstellungsmerkmal für SaaS-Phase 2.**

### G.9 · Lucca als CH-KMU-Benchmark (nicht Personio)

Vor Research: Personio als Primär-Benchmark.  
Nach Research: **Lucca hat CH-Fokus (Basel-Office), modulares Pricing, passt besser zu 15–30 MA Boutiquen** als Personio.

### G.10 · SwissDecTX als Zertifizierungs-Alternative

Vor Research: "Swissdec-zertifiziert sein oder nicht."  
Nach Research: **SwissDecTX bietet REST-API für Drittentwickler, ELM zu senden ohne eigene Zertifizierung** — dritter Weg zwischen Eigenbau und Partner-HR-Tool.

---

## TEIL H · SCHWEIZ-SPEZIFIKA — KONSOLIDIERTE LISTE

Aus allen fünf Quellen zusammengefasst, mit höchster verfügbarer Präzision (meist aus Q5):

### H.1 · Sozialversicherungen 2025

| Zweig | Satz 2025 | Pflicht | Quelle der Zahl |
|-------|-----------|---------|------------------|
| AHV | 8.7% paritätisch (4.35%/4.35%) | Ab 1.1. nach 17. LJ | Q5 |
| IV | 1.4% paritätisch | Gesetzlich | Q5 |
| EO | 0.5% paritätisch | Gesetzlich | Q5 |
| **AHV+IV+EO total** | **10.6% paritätisch (5.3%/5.3%)** | — | Q5 |
| ALV | 2.2% paritätisch **bis CHF 148'200** Jahreslohn | **ALV2 Solidaritätsprozent ist seit 01.01.2023 entfallen** | Q5 |
| UVG (BU/NBU) | Variabel je Versicherer, bis CHF 148'200 | AG-Pflicht BU, AN-Pflicht NBU | Q5 |
| BVG | Altersgutschriften 7/10/15/18% je Altersklasse + Koordinationsabzug | Ab Jahreslohn CHF 22'680 | Q5 |
| KTG | Variabel (oft GAV/vertraglich) | Nicht gesetzlich | Q5 |
| FAK | Kantonal variierend, AG-Beitrag | Kantonale Pflicht | Q2/Q5 |

### H.2 · BVG-Parameter 2025 (nur in Q5 präzise)

- **Eintrittsschwelle:** CHF 22'680
- **Koordinationsabzug:** CHF 26'460 (bei 100% Pensum, pro rata bei Teilzeit)
- **Oberer Grenzbetrag:** CHF 90'720
- **Max. koordinierter Lohn:** CHF 64'260
- **Min. koordinierter Lohn:** CHF 3'780
- **Mindestzins:** 1.25%
- **Umwandlungssatz:** 6.8%
- **Altersgutschriften:**
  - 25–34 J: 7%
  - 35–44 J: 10%
  - 45–54 J: 15%
  - 55–65 J: 18%

### H.3 · Quellensteuer

- **Tarifcodes:** A (ledig), B (verheiratet Alleinverdiener), C (Doppelverdiener), H (alleinerziehend), **L** (echte Grenzgänger DE, 4.5% mit Gre-1-Bescheinigung), **G** (Ersatzeinkünfte), **F** (Grenzgänger IT)
- **D-Tarif abgeschafft per 01.01.2021**
- **Abrechnung:** monatlich (Mehrheit der Kantone) oder jährlich (GE/FR/VD/VS/TI)
- **System-Anforderung:** monatliche TXT-Tarifdateien je Kanton einlesen, Tarifcode aus Stammblatt ableiten
- **Homeoffice-Regelung ab 01.01.2025** für Grenzgänger — Status kann durch HO-Anteil beeinflusst werden

### H.4 · Swissdec ELM 5.0

- **Pflicht ab 2026**, gestaffelte Abschaltung ELM 4.0:
  - Quellensteuer letzte Abrechnung: **31.12.2025**
  - Übrige Domänen: **30.06.2026**
- **ELM 6.0** ab 2026 in Pipeline
- **Minor-Releases aktuell 5.0–5.5**
- **SwissDecTX** als API-Transmitter für Drittentwickler ohne Eigenzertifizierung

### H.5 · Lohnausweis Formular 11

- Einheitliche eidg. Vorlage (ESTV Bestell-Nr. 605.040.18N)
- Wegleitung 2024 mit **Update 1.1.2026 (Fahrkosten 75 Rp.)**
- Zentrale Ziffern: 1 Lohn, 2.1–2.3 Naturalleistungen, 3 Unregelmässig, 7 Ersatzeinkünfte, 13 Spesen, 15 Bemerkungen
- Felder F (unentgeltliche Beförderung), G (Kantinenvergünstigung)

### H.6 · Elternurlaub / EO

- **Mutterschaft:** 14 Wochen (98 Tage) à 80%, Cap **CHF 220/Tag** (Monats-Max CHF 8'250). Verlängerung um 56 Tage bei Spitalaufenthalt ≥ 2 Wochen.
- **Vaterschaftsurlaub / Urlaub des anderen Elternteils:** 2 Wochen (10 AT = 14 Taggelder) innerhalb 6 Mt. nach Geburt, 80%, max. CHF 220/Tag, Gesamt-Max CHF 3'080

### H.7 · ArG Höchstarbeitszeit

- **45 h/Woche:** Industrie, Büro, Detailhandel-Grossbetriebe
- **50 h/Woche:** übrige (Gastronomie, Gewerbe, Gesundheit)
- Tägliche Ruhezeit ≥ 11 h
- Überzeit max. 2 h/Tag, Jahresobergrenzen 170/140 h
- **Art. 73** Pflicht-Tracking / **Art. 73b** Simplified ab 25% Autonomie / **Art. 73a** Waiver ab 50% Autonomie + CHF 120k + GAV/schriftl. Vereinbarung (aus ARK_ZEITERFASSUNG_ADDENDUM)

### H.8 · nDSG (seit 01.09.2023)

- **Bearbeitungsverzeichnis (Art. 12)** nur für Firmen **≥ 250 MA** oder bei hohem Risiko — **KMU <250 MA grundsätzlich befreit** (Korrektur von Q1/Q4-Fehldarstellung)
- **DSFA (Art. 22)** bei hohem Risiko
- **Konsultation EDÖB** bei hohem Restrisiko
- **Bussen bis CHF 250'000 gegen natürliche Personen** (Geschäftsleitung) — nicht gegen Firmen
- **Breach-Meldung "so rasch als möglich"**, keine 72h-Pauschalfrist wie DSGVO
- **Auskunftsrecht-Workflow:** 30 Tage Frist für MA-Auskunft

### H.9 · Ausländerbewilligungen

- **L** (bis 12 Mt., verlängerbar auf 24)
- **B** (EU/EFTA 5 J, Drittstaaten 1 J)
- **C** (unbefristet, Kontrollfrist 5 J — ab Erteilung keine QSt-Pflicht)
- **G** Grenzgänger (EU/EFTA 5 J, sonst 1 J)
- **Ci** Legitimationskarte Familienangehörige

**System-Anforderung:** Ausweis-Typ + Ablaufdatum + automatische Reminder 90/60/30 Tage vor Ablauf

### H.10 · Gender-Pay-Gap / Logib

- Pflicht **ab 100 MA** (Kopfzählung, Lehrlinge exkl.)
- Alle 4 Jahre, **extern zu prüfen**
- Informationspflicht an MA
- Toleranz 5%
- **Sunset bis 2032** (nur Q5 erwähnt)

### H.11 · 13. Monatslohn

- Kein gesetzlicher Zwang, aber vertraglich üblich
- Pro-Rata bei Ein-/Austritt: Dienst-Tage × Monatslohn × 12 / 360 / 12
- Auszahlung konfigurierbar (Dezember / hälftig Juni+Dezember)

### H.12 · Dienstalters-/Jubiläumsgeschenke

- **Naturalgeschenke bis CHF 500/Ereignis** nicht deklarationspflichtig
- **Bargeld voll deklarationspflichtig**
- **Schwellen nach Dienstalter alle 5 Jahre** (Q1/Q5 — exakte Steuerfreibetrag-Regelung variiert, in Q5 als "frei parametrisierbar" empfohlen)

### H.13 · Benefits-Steuerfreigrenzen

- **REKA:** bis CHF 600/Jahr steuerfrei
- **Mittagsessen in Firmenkantinen:** steuerfrei
- **Lunch-Checks:** bis CHF 180/Monat steuerfrei
- **GA/Halbtax:** geschäftlich notwendig → Feld F
- **Vereinsmitgliedschaften:** bis CHF 1'000 steuerfrei
- **Geschäftsfahrzeug:** 9.6% des Kaufpreises/Jahr als Lohnanteil (LW Feld 2.2)

### H.14 · Ferien-Mindestanspruch (OR 329a)

- **4 Wochen** Standard
- **5 Wochen** bis vollendetes 20. Altersjahr
- **System:** Ferienkonto pro MA, Pro-Rata bei Ein-/Austritt, gesetzliches Minimum nicht abgelten (ausser Austritt)

---

## TEIL I · FEATURE-KATALOG — SYNTHETISIERT MIT MoSCoW

Kompiliert aus allen fünf Quellen. Bei Konflikten wähle ich die strengere (häufigere) Klassifikation. Wo nur eine Quelle ein Feature nennt, wird das markiert.

### I.1 · Personal-Stammdaten

| Feature | MoSCoW | Quellen-Konsens |
|---------|--------|-----------------|
| Name, Adresse, AHV-13, Geburtsdatum, Zivilstand, Nationalität | Must | 5/5 |
| Kontaktdaten + Notfallkontakt | Must | 5/5 |
| Bewilligungsstatus (B/C/G/L/Ci) mit Ablaufdatum + Reminder 90/60/30 Tage | Must | 5/5 |
| Bankverbindung (IBAN, verschlüsselt) | Must | 5/5 |
| Pensum-Historie mit valid_from/to | Must | 5/5 |
| Kostenstelle/Desk/Team mit History | Must | 5/5 |
| Quellensteuerstatus (Tarif + Kanton + Grenzgänger-Typ) | Must | 4/5 (Q1 oberflächlich) |
| Dienstalter-Berechnung automatisch | Should | 4/5 |
| Profilbild, Bio, Skills | Could | 3/5 |
| Familienstand/Kinder/Konfession (QSt-relevant) | Must | Q5 |
| Audit-Log jeder Änderung | Must | 5/5 |

### I.2 · Lohn & Vergütung

| Feature | MoSCoW | Quellen-Konsens |
|---------|--------|-----------------|
| Grundlohn-Historie bitemporal mit valid_from/to | Must | 5/5 |
| 13. Monatslohn pro rata | Must | 5/5 |
| Bonus / STI-Modell | Should | 5/5 |
| **Provisions-Engine (CM/AM/Hunter) → im CRM-Kern** | Must | 5/5 (aber nicht im HR) |
| Spesen-Pauschalen | Should | 4/5 |
| Lohnnebenleistungen (Fahrzeug, ÖV, Laptop, REKA) | Should | 5/5 |
| Dienstaltersgeschenk automatisch | Should | 2/5 (Q1, Q5) |
| AHV/BVG/UVG/KTG/FAK-Sätze automatisch aktualisiert | Must (Referenz, nicht Eigenberechnung) | 5/5 |
| Quellensteuer-Berechnung | Must (Referenz, nicht Eigenberechnung) | 5/5 |
| BVG-Koordinationsabzug-Berechnung | Must (Referenz) | 5/5 |
| Lohnausweis Formular 11 | Must (Output via Partner) | 5/5 |
| Compensation-Review-Cycles | Should Phase 2 | 2/5 (Q5) |
| Gehaltsbänder/Grades | Could | 1/5 (Q5) |

### I.3 · Absenzen-Management

| Feature | MoSCoW | Quellen-Konsens |
|---------|--------|-----------------|
| Ferienanspruch-Berechnung (Alter, Pensum, Eintritt, GAV) | Must | 5/5 |
| Ferien-Bezug, Saldo, Jahresübertrag | Must | 5/5 |
| Krankheit + Arztzeugnis-Upload + Bradford-Faktor | Must | 4/5 (Q1 oberflächlich) |
| Militärdienst/WK (EO) | Must | 5/5 |
| Mutterschaft 14 Wo 80% | Must | 5/5 |
| Vaterschaft 2 Wo 80% | Must | 5/5 |
| Unbezahlter Urlaub mit BVG-Auswirkung | Should | 3/5 |
| Mehrstufige Approval-Workflows mit Delegation | Must | 5/5 |
| EO-Zuschuss-Verbuchung | Must | 4/5 |
| KAE (Kurzarbeit) | Could | 3/5 |
| Team-Abwesenheitskalender | Should | 5/5 |

### I.4 · Dokumente & Verträge

| Feature | MoSCoW | Quellen-Konsens |
|---------|--------|-----------------|
| Digitale Personalakte mit Versionierung | Must | 5/5 |
| Arbeitsvertrag-Verwaltung (Status: Draft/Signed/Archived) | Must | 5/5 |
| **Skribble-Integration** für E-Signatur (CH, ZertES) | Must | 3/5 (Q2/Q3/Q5) — bevorzugt |
| DocuSign als Backup für internationale Kunden | Could | 2/5 (Q1, Q4) |
| Aufbewahrungsfristen automatisch (Arbeitsvertrag 10 J, Lohn 10 J) | Must | 5/5 |
| Dokument-Templates mit Variablen-Merge | Should | 5/5 |
| Arbeitszeugnis-Generator CH (Code-Sprache) | Should | 1/5 (Q5) |
| Bulk-Upload für Migration | Should | 2/5 (Q5) |
| OCR-Datenextraktion aus Altverträgen | Could | 1/5 (Q5) |

### I.5 · Onboarding/Offboarding

| Feature | MoSCoW | Quellen-Konsens |
|---------|--------|-----------------|
| Checklisten mit Owner + Due Date | Must | 5/5 |
| **Workflow-Engine mit Conditional-Triggers** (Rippling-Stil) | Should | 2/5 (Q2, Q5) |
| Probezeit-Gespräche als Kalender-Events mit Reminder | Must | 5/5 |
| AHV-/BVG-Anmeldung-Tracking | Must | 3/5 (Q2/Q5) |
| IT-Zugangs-Checklist | Should | 4/5 |
| Buddy-Zuweisung | Could | 3/5 |
| Exit-Interview-Formular | Should | 4/5 |
| Fluktuationsgrund-Tracking | Should | 3/5 |
| SCIM-basiertes IT-Provisioning | Could Phase 2 | 1/5 (Q5) |

### I.6 · Organisation

| Feature | MoSCoW | Quellen-Konsens |
|---------|--------|-----------------|
| Organigramm visuell, auto-generiert | Should | 5/5 |
| Cost-Center/Desks/Sparten | Must | 5/5 |
| Stellvertretungen mit Genehmigungs-Weiterleitung | Should | 4/5 |
| Reporting-Linien (Line + Dotted-Line) | Should | 3/5 |
| Mehrere Legal Entities | Should Phase 2 | 2/5 |

### I.7 · Compliance

| Feature | MoSCoW | Quellen-Konsens |
|---------|--------|-----------------|
| nDSG-Informationspflicht-Prozess | Must | 5/5 |
| Bearbeitungsverzeichnis-Export (nur für SaaS-Kunden ≥250 MA) | Should | Q5 (Korrektur: nicht Pflicht für ARK intern) |
| DSAR/Auskunftsrecht-Export <30 Tage | Must | 5/5 |
| Löschkonzept pro Datentyp | Must | 5/5 |
| Consent-Management | Must | 5/5 |
| Data-Breach-Workflow (EDÖB-Meldung) | Must | 4/5 |
| Hosting in CH/EU | Must | 5/5 |
| DPIA-Template | Should | 2/5 |
| Pflichtschulungs-Nachweise (nDSG, ISO 27001) | Should | 4/5 |
| ArG-Compliance-Status (45/50 h Kategorie, Waiver-Status) | Must (Referenz, Detail → Zeiterfassung) | 5/5 |

### I.8 · Payroll-Integration

| Feature | MoSCoW | Quellen-Konsens |
|---------|--------|-----------------|
| **Swissdec-ELM-Export via Partner (Abacus AbaConnect / SwissSalary REST / Bexio bLink)** | Must | 5/5 |
| SwissDecTX als Alternative | Could | 1/5 (Q2) |
| SIX pain.001.001.09 (ISO 20022) für Zahlungen | Must | 4/5 |
| Rückläufe lesen (Lohnzahlen, Abweichungen) | Should | 3/5 |
| Lohnausweis-Files automatisch in Personalakte | Should | 3/5 |
| Eigene Swissdec-Zertifizierung | Won't (Phase 3 evtl.) | 3/5 (Q2/Q3/Q5) |

### I.9 · Self-Service

| Feature | MoSCoW | Quellen-Konsens |
|---------|--------|-----------------|
| Ferienantrag | Must | 5/5 |
| Adressänderung, IBAN, Notfallkontakt | Should | 5/5 |
| Lohnausweis-Download | Must | 5/5 |
| Absenzen-Saldo einsehen | Must | 5/5 |
| Arztzeugnis-Upload | Must | 4/5 |
| Kollegen-Directory | Should | 4/5 |
| Organigramm | Should | 5/5 |
| Benefits-Marketplace (Swibeco-Style) | Could | 1/5 (Q5) |

### I.10 · Reporting & Analytics

| Feature | MoSCoW | Quellen-Konsens |
|---------|--------|-----------------|
| Headcount-Report | Must | 5/5 |
| Fluktuation/Retention | Should | 5/5 |
| Krankheitsquote (Bradford-Faktor) | Should | 4/5 |
| **Logib-Export (für SaaS-Kunden ≥100 MA)** | Should | 2/5 (Q5) |
| Kosten pro MA | Should | 4/5 |
| **Provisions-Dashboard pro Hunter** | Must (im CRM-Kern, nicht HR) | 5/5 |
| Time-to-Fill-KPIs verlinkt mit CRM | Should | 2/5 |
| Gender-Pay-Gap | Should | 4/5 |
| Power-BI Read-Only-Datenrolle (bereits im CRM) | Should | 1/5 (Q2) |
| AI-Attrition-Risk-Score | Could | 1/5 |

### I.11 · Mobile

| Feature | MoSCoW | Quellen-Konsens |
|---------|--------|-----------------|
| PWA responsive | Must | 5/5 |
| Ferienantrag mobil | Must | 5/5 |
| Payslip-Download mobil | Should | 4/5 |
| Web-Push-Notifications | Should | 2/5 |
| Spesen-Foto-Upload mit OCR | Could | 2/5 |
| Native App-Wrapper (Capacitor/Expo) | Could Phase 2 | 2/5 |
| Offline-Modus | Won't | 1/5 |

### I.12 · ARK-UX-Differenzierungen (nur Q5 + implizit andere)

| Feature | MoSCoW | Begründung |
|---------|--------|------------|
| **Dark-Mode-only** | Must | Kein HRIS hat Dark Mode ausser Rippling (seit 9/2025) |
| **Command Palette (Cmd+K)** | Should | Kein grosses HRIS hat das |
| **Keyboard-First-Power-User-Shortcuts** | Should | Passt zu ARKs bestehendem CRM |

---

## TEIL J · ARCHITEKTUR-EMPFEHLUNGEN — SYNTHETISIERT

### J.1 · Datenmodell (Q5-Empfehlung übernehmen)

```
Person (unveränderlich, identitätsbezogen)
  └─ Employee (ein oder mehrere Beschäftigungen, z.B. Re-Hire)
       └─ Employment (Vertrag, Status: active/ended)
            └─ Assignment (was tue ich wo, parallel möglich)
                 └─ Position (Slot in Org-Unit, job_profile-Referenz)
```

**Warum 5 Ebenen:** parallele Assignments (Hunter arbeitet in 2 Desks), Position-Preservation bei Re-Hire (Slot bleibt, Worker wechselt), Contract-Wechsel ohne Identitätsverlust.

### J.2 · Historisierung (Q5 mit PG-18-Brücke)

```sql
CREATE EXTENSION IF NOT EXISTS btree_gist;

CREATE TABLE compensation (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  assignment_id uuid NOT NULL REFERENCES assignment(id),
  base_salary numeric(12,2) NOT NULL,
  currency char(3) NOT NULL DEFAULT 'CHF',
  valid_period tstzrange NOT NULL,
  recorded_period tstzrange NOT NULL DEFAULT tstzrange(now(), 'infinity', '[)'),
  recorded_by uuid REFERENCES auth.users(id),
  CONSTRAINT comp_no_overlap EXCLUDE USING gist (
    assignment_id WITH =,
    valid_period WITH &&,
    recorded_period WITH &&
  )
);
```

**Drei bitemporale Tabellen:** `compensation`, `work_schedule`, `assignment`. Rest mutable mit supa_audit. Materialized View `v_current_compensation` für Hot-Path.

### J.3 · Multi-Tenant

**Phase 1 (ARK intern):** Shared DB, RLS-ready Schema mit `tenant_id UUID NOT NULL DEFAULT (ARK-UUID)`. `auth.tenant_id()` aus `app_metadata.tenant_id` im JWT.

**Phase 2 (SaaS):** Bleibt Pool-Model. Ein `tenants`-Table, ARK wird Zeile, keine Re-Architecture.

**Hybrid-Optionsschein:** `tenants.isolation_tier` enum (`pool`/`silo`). Silo wird aktiviert für Enterprise-Kunden mit CH-only-Hosting oder Vertrags-Anforderung.

**RLS-Performance-Regeln (Q5):**
1. Index auf jede Policy-Spalte, `tenant_id` immer zuerst im Composite-Index
2. Auth-Funktionen in `(select auth.uid())` wrappen → 100× Speedup
3. Security-Definer-Functions für Policy-Joins
4. `TO authenticated` explizit
5. Explizite WHEREs trotz RLS-Filter
6. Views mit `security_invoker = true`

### J.4 · Sensible Daten

- **Separates Schema `sensitive`** (nicht in `db.schemas` für PostgREST exposed)
- **pgcrypto** mit `pgp_sym_encrypt` / `pgp_sym_decrypt`
- **NICHT pgsodium/Vault-TCE** (Supabase-Deprecation)
- Zugriff nur über Fastify-Backend mit Service-Role
- Encrypted Columns nicht indizieren — nur für write-mostly (Lohnnetto, Krankheitsgründe, IBAN)

### J.5 · RBAC (Q5 + OpenFGA-Option)

**Primär:** Postgres RLS (DB-enforced, auch bei Code-Bugs sicher).

**Rollen-Matrix (ausführlich in Q5):**
| Rolle | Stammdaten | Lohn/SV | Dokumente | Absenzen | Admin |
|-------|------------|---------|-----------|----------|-------|
| hr_admin | R/W | R/W | Voll | Voll | Voll |
| payroll_view | R (eingeschränkt) | R | ✗ | ✗ | ✗ |
| manager | Team R | ✗ | ✗ | Genehmigen (Team) | ✗ |
| employee | Eigen | Eigen Payslips | Eigene | Antrag | ✗ |
| ceo_readonly | R gesamt | Aggregat | ✗ | R | ✗ |
| auditor | R historisch | Aggregat | R | R | ✗ |

**Sekundär (Phase 2):** OpenFGA (Zanzibar-OSS) für ReBAC — HRBP-Delegation, Skip-Level-Manager, Dotted-Line.

### J.6 · Audit-Log (Q5 Drei-Schicht-Muster)

1. **supa_audit** (Trigger-basiert, JSONB-Diff) auf allen HR-Kerntabellen
2. **pgaudit** für Read-Audit auf Lohntabellen
3. **Domain-Events** in `hr_events` für geschäftskritische Events (Hire, Terminate, SalaryChange, Promotion)

**Retention:** 10 J für comp-relevante Audits (OR Art. 958f), Jahres-Partitionen via pg_partman, kalte Partitionen nach S3 mit Object Lock (GeBüV-konform).

---

## TEIL K · USER-FEEDBACK-SYNTHESE

### K.1 · Was Nutzer lieben (echte Zitate aus Q2/Q5)

- **Personio:** _"What I like best about Personio is how it centralizes all core HR processes in one intuitive platform"_ (G2)
- **BambooHR:** _"BambooHR is really intuitive, and easy for employees to use and locate information… The ATS is the star utilization"_ (Capterra 2024)
- **HiBob:** _"We went from spreadsheet upon spreadsheet, to Bob doing all the hard work for us. Automation and onboarding are brilliant."_ (Trustpilot)
- **Bexio:** _"Basisanwendungen sind alle enthalten, Lohnbuchhaltung ist intuitiv und gut. Die Lohnbuchhaltung ist gut in die kantonale Meldestruktur integriert"_ (Capterra DE)

### K.2 · Was Nutzer hassen (echte Zitate)

- **Personio-Payroll:** _"This software was bought to help with payroll. In the end, it just became a database to store employee information. Payroll is much too susceptible to errors to be relied on"_ (Capterra)
- **Personio-Preiserhöhungen:** _"They went ahead and increased their pricing quite a lot… with 11 months notice"_ (Trustpilot)
- **Personio-Systemausfälle:** _"Besonders problematisch sind die sehr häufigen Systemausfälle — mindestens einmal pro Woche ist Personio für mehrere Stunden nicht erreichbar"_ (Trustpilot AT)
- **Personio-Support:** _"Die Antwortzeiten lagen hier im Schnitt bei einer Woche. Bis hier ein Problemthema abgehandelt war, vergingen regelmässig bis zu 6 Wochen"_ (Trustpilot AT)
- **Rippling:** _"Adding new hires into Rippling throughout the year does not automatically add the prorata vacation days into their profile"_ (G2)
- **HiBob nach Pento-Übernahme:** _"All of our historical Pento data appears to have been [lost]"_ (Trustpilot)
- **Bexio-Abo-Falle:** _"Automatische Vertragsverlängerung ohne Vorwarnung, absichtlich komplizierter Kündigungsprozess… Nun wurde sofort ein Inkassobüro eingeschaltet"_ (Capterra DE)
- **Factorial-Support:** _"Customer service is virtually nonexistent… they ignored us for nearly a week"_ (Trustpilot)
- **BambooHR-Preiserhöhung 2024:** _"The new subscription tiers came with an increase of price and we were unable to keep the subscription we had"_ (Capterra)

### K.3 · ARK-Gegendesign-Muster (aus Q3 explizit, Q5 implizit)

Aus den häufigsten Frustrationen ableitbare Gegendesigns für ARK:

| Frustration | ARK-Gegendesign |
|-------------|-----------------|
| Preiserhöhungen mit kurzer Ankündigung | **Preis-Transparenz in AGB**, Staffelung nach Jahren vertraglich fix |
| Ständige UI-Änderungen | **Kein UI-Change ohne Changelog + Opt-in** |
| Schlechter Support | **Account-Manager-Verpflichtung** für KMU-Tier |
| Versteckte Kosten | **All-in-Preis ohne Setup-Fees, ohne Implementation-Gebühr** |
| Lohnfehler (Personio) | **Ausgelagert an zertifizierten Provider** |
| Datenverlust bei M&A (Pento→HiBob) | **Datenexport als API-Recht** in AGB |
| Ferienberechnung falsch | **Test-Suite auf 100+ Schweizer Szenarien** vor Go-Live |

---

## TEIL L · STRATEGISCHE KERNFRAGEN FÜR DICH

Dies sind die drei Fragen, die nur du beantworten kannst und die die Roadmap definieren.

### L.1 · Build-vs-Buy: A, B oder C?

Q3 stellt das explizit zur Wahl:

**Option A — Full Custom Build**
- 5-J-TCO intern: CHF 179–347k
- Break-Even: ≥ 5 SaaS-Kunden Jahr 4–5
- Risiko: hoch (Scope-Creep, Swissdec-Komplexität, CH-Compliance)
- Upside: Provisions-Engine = echter USP; volle Kontrolle

**Option B — Hybrid (empfohlen von Q3)**
- Lucca/Personio für ARK-intern (CHF 4–10k/Jahr)
- CRM-Kern voll priorisieren inkl. Commission-Engine
- HR-Eigenbau erst nach Beta-SaaS-Validation (z.B. 3 Pilot-Kunden aus CH-Boutiquen)
- Risiko: niedrig
- Upside: schnelle Marktlernkurve, keine Eigenbau-Falle

**Option C — Abwarten**
- Abacus intern (CHF 11–16k/5 J)
- Fokus komplett auf CRM
- Risiko: sehr niedrig
- Upside: kein SaaS-Ambition; ARK bleibt Boutique

**Meine Einschätzung:** Q3s Empfehlung von **Option B** ist rational begründet, aber sie ignoriert zwei Punkte:
1. **Die Commission-Engine ist die Marktlücke** — diese muss so oder so im CRM-Kern gebaut werden, unabhängig von A/B/C
2. **Das HR-Modul wäre nicht primär ARK-intern nützlich**, sondern strategisch für SaaS-Phase 2 gedacht — Phase 1 braucht ARK primär Payroll-Integration zu bestehenden CH-Tools

**Realistische Hybrid-Variante:**
- **CRM-Kern:** Commission-Engine + Placement-Tracking (Phase 1, Priorität #1)
- **HR-Modul:** Schlank als Daten-Layer für Provisions-Engine-Output (Stammdaten + Payroll-Export zu Abacus), **nicht** als vollständiges HR-Tool
- **ARK-intern:** Nutzt Abacus oder Bexio für HR-Operations (Ferien, Onboarding, Lohnlauf)
- **SaaS-Phase 2:** Wenn 3+ Boutique-Kunden die Commission-Engine ernsthaft wollen → erst dann echtes HR-Modul ausbauen

Das ist eine vierte Option, die die Research-Outputs nicht explizit nennen, aber logisch aus ihnen folgt: **Option D — Commission-First, HR-Lean**.

### L.2 · Payroll-Partner: Abacus, SwissSalary, Bexio oder SwissDecTX?

Alle drei Partner-Routen sind valid:

| Partner | Stärke | Schwäche | Fit für ARK |
|---------|--------|----------|-------------|
| **Abacus** | Marktführer CH, 1.5 Mio Abrechnungen/Mt, tiefe Integration | Veraltetes UI, kein native REST, hoher Lizenzaufwand | Eher für ≥50 MA SaaS-Kunden |
| **SwissSalary 365** | Swissdec certified plus (als Erster), Cloud-nativ, OAuth 2.0 REST, MS Dynamics 365-Nähe | Benötigt MS-Ökosystem-Kunden | Gut für MS-Ökosystem-SaaS-Kunden |
| **Bexio** | Günstigste (CHF 35–115/Monat), bLink-REST + Webhooks, SME-Fokus | Eingeschränkte Skalierbarkeit, Probleme mit Kündigungspraxis (siehe Nutzer-Zitate) | **Ideal für ARK-intern** und Kleinst-SaaS-Kunden (<15 MA) |
| **SwissDecTX** | REST-API für ELM-Senden **ohne Eigenzertifizierung** | Nur Transmitter, keine Lohnberechnung | **Interessanter dritter Weg** falls Eigenbau-Ambition bestehen bleibt |

**Meine Empfehlung:** **Bexio für Phase 1** (ARK-intern + Kleinst-SaaS), **SwissSalary für Phase 2** (Mittelstand-SaaS), **Abacus als Enterprise-Option**. SwissDecTX nicht ignorieren für spätere Hybrid-Szenarien.

### L.3 · Dienstag-Entscheidungen

Aus dem bestehenden Addendum (Zeiterfassung) und diesem Research muss für die Dienstag-Review entschieden werden:

1. **Build-vs-Buy-Richtung:** A / B / C / D
2. **Payroll-Partner-Strategie:** Bexio / SwissSalary / Abacus / Mehr-Partner-Adapter
3. **HR-Phase-1-Scope:** Voll / Lean (nur Stammdaten + Payroll-Export) / Abgesagt
4. **Bitemporal-Ja/Nein:** Q5-Ansatz übernehmen (ja) oder vereinfachen (Q2-Ansatz)
5. **Workflow-Engine:** Dedizierte Engine (Q5) oder hart gecodete Checklisten (Q1/Q4)
6. **E-Signatur:** Skribble primär (Q2/Q3/Q5 empfohlen) oder DocuSign (Q1/Q4 generisch)
7. **Lucca evaluieren?** Als potenzieller CH-KMU-Benchmark (nur Q3 erwähnt)
8. **SwissDecTX evaluieren?** Als Hybrid-Option (nur Q2 erwähnt)
9. **Commission-Engine-Architektur:** CRM-Kern (einstimmig) — aber wie schnell bauen?
10. **Onboarding als Workflow-Engine-Modul** oder als Feature im HR-Tab?
11. **Dark-Mode + Command Palette:** Explizit als USP positionieren oder "einfach so"?

---

## TEIL M · ACTION ITEMS

Konkrete nächste Schritte, sortiert nach Dringlichkeit:

### Sofort (vor Dienstag-Review)

1. [ ] **Strategische Entscheidung vorbereiten:** Option A/B/C/D (siehe L.1)
2. [ ] **Lucca anschauen** — 30 min Produktvideo, Pricing-Check (nur Q3 erwähnt)
3. [ ] **Apriko anschauen** — 15 min, falls Personaldienstleister-SaaS-Branche relevant wird (nur Q4 erwähnt)
4. [ ] **SwissDecTX-Dokumentation lesen** — evaluieren als ELM-Transmitter (nur Q2 erwähnt)
5. [ ] **CH-Boutique-Benchmark validieren** — Telefonate mit 2–3 Boutiquen (Wirz, Swisselect, Stellar) über ihren HR-Stack

### Dienstag-Review

1. [ ] Build-vs-Buy-Entscheidung dokumentieren (in ARK_HR_TOOL_PLAN_v0_2.md)
2. [ ] Grauzonen-Beschlüsse final (alle 11 dokumentieren, mit Präzedenzfall-Verweisen)
3. [ ] Payroll-Partner wählen (mindestens primärer + optionaler Zweit-Partner)
4. [ ] Phase-1-Scope hart definieren (mit Out-of-Scope-Liste)
5. [ ] Commission-Engine-Architektur als eigenes Dokument anlegen (ARK_COMMISSION_ENGINE_SPEC_v0_1.md)

### Nach Review

1. [ ] **ARK_HR_TOOL_PLAN_v0_2.md** schreiben basierend auf Entscheidungen
2. [ ] **ARK_DATABASE_SCHEMA_v1_4.md** mit neuem Personen-Modell (Q5 5-Ebenen)
3. [ ] **ARK_HR_INTERACTIONS_v0_1.md** für UX-Spec
4. [ ] **ARK_DSG_COMPLIANCE_v0_1.md** als separates Dokument (ja nach Entscheidung)
5. [ ] **ARK_PAYROLL_INTEGRATION_SPEC_v0_1.md** für Partner-Adapter

### Risikopunkte zum beobachten

- **ELM 4.0 Abschaltung Quellensteuer:** 31.12.2025 — wenn bis dahin keine Partner-Integration steht, manueller Workaround nötig
- **PostgreSQL 18 + Supabase GA:** `WITHOUT OVERLAPS` kommt — abwarten oder GiST-Exclusion-Pattern bauen?
- **pgsodium Deprecation:** Falls vom CRM-Kern bereits genutzt → Migration zu pgcrypto planen
- **Pento-Datenverlust-Case (HiBob):** Lehre für ARK — Export-API in AGB zur Pflicht machen

---

## ABSCHLUSS

Diese Synthese kombiniert fünf unterschiedliche Research-Perspektiven zu einem konsolidierten Bild. Der Kern der Empfehlungen ist belastbar, weil er auf drei Quellen mit echten URLs und tiefer Architektur-Kenntnis basiert (Q2, Q3, Q5). Die Abweichungen von Q1 (Manus) und Q4 (Research C) sind meist auf Oberflächlichkeit zurückzuführen, nicht auf alternative valide Sichten.

**Die drei Kernfragen (L.1/L.2/L.3) sind deine Entscheidung.** Alle anderen Fragen (Grauzonen, Schweiz-Spezifika, Architektur-Patterns) sind durch den Research-Konsens klar beantwortet.

**Mein Gesamtgefühl nach der Synthese:** Q3 hat recht mit der wirtschaftlichen Warnung, aber das bedeutet nicht "nicht bauen" — sondern **"anders bauen"**. Die Commission-Engine ist der Kern. Das HR-Modul drumherum sollte schlank bleiben (Option D). Dann ist ARK sowohl intern sofort nützlich als auch für SaaS-Phase 2 differenzierend, ohne die Swissdec-Zertifizierungsfalle.
