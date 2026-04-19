---
title: "SwissDecTX · Technische Evaluation und ARK-Strategie-Fit"
type: evaluation
phase: 3
created: 2026-04-19
version: v0.1
sources: ["swissdectx.ch", "itserve.ch/steptx", "swissdec.ch/certified-erp"]
tags: [research, evaluation, vendor, swissdec, elm, payroll, infrastructure]
---

# SwissDecTX · Technische Evaluation und ARK-Strategie-Fit

> **Auftrag:** SwissDecTX als möglichen ELM-Transmitter evaluieren. Q2 der Research-Synthese hatte SwissDecTX als "dritten Weg" zwischen Eigen-Zertifizierung und Partner-Integration genannt. Dieses Dokument prüft faktisch, was SwissDecTX tatsächlich leistet — und liefert eine klare Entscheidung ob ARK es einsetzen soll.

---

## TL;DR

**SwissDecTX ist kein "dritter Weg".** Es ist eine hochspezialisierte Transmitter-Library die **einen Teilaspekt** der Swissdec-Zertifizierung (die Datenübertragung) abdeckt. Die Swissdec-Zertifizierung der **eigenen Geschäftslogik** (Lohnberechnung, QSt, BVG, ALV, UVG, Sozialversicherungen) muss ARK trotzdem selbst durchlaufen — das ist der aufwendige Teil.

**Strategische Einordnung:** SwissDecTX ist relevant **nur wenn ARK sich entscheidet, in Phase 3+ eine eigene Swissdec-zertifizierte Payroll zu bauen**. Für Phase 1 (intern) und Phase 2 (SaaS) ist es **nicht notwendig**. Q2's Einordnung war zu optimistisch.

**Zusätzlich:** Die Windows/.NET-Natur passt nicht zu ARKs Linux/Node.js-Stack. Integration würde einen separaten Windows-Microservice oder das Gateway-Add-In erfordern.

**Empfehlung:** Dokument ablegen, in 2–3 Jahren erneut prüfen wenn Payroll-Eigenbau auf der Roadmap steht. Jetzt nicht priorisieren.

---

## 1. Was ist SwissDecTX tatsächlich?

### 1.1 · Unternehmen

| Parameter | Wert |
|-----------|------|
| **Hersteller** | Axel Rietschin Software Developments |
| **Sitz** | Genf |
| **Unabhängigkeit** | Unabhängiger Softwarehersteller, **nicht** mit SUVA oder Swissdec-Organisation verbunden |
| **Neutralität** | Explizit: kein eigenes Payroll- oder Accounting-Produkt → kein Interessenskonflikt |
| **Produktion seit** | 2009 (Swissdec 2.2) |
| **Aktuelle Version** | 5.09 (Juli 2025, unterstützt ELM 5.5) |
| **Aktuelle Version lizenziert** | 30+ Software-Publisher in der Schweiz |
| **Volumen** | 6. grösster Swissdec-Transmitter nach transmittiertem Volumen |

### 1.2 · Was es technisch tut

SwissDecTX übernimmt **ausschliesslich** den Transmitter-Teil der Swissdec-Kette:

- ✅ Lokale XML-Validierung der Lohndaten (gegen offizielle XSD-Schemas)
- ✅ Digitale Signatur der XML-Deklarationen
- ✅ Verschlüsselung mit Swissdec-Zertifikaten
- ✅ HTTPS/TLS-Übertragung an Swissdec-Distributor
- ✅ Transmission Journal Archive (erfüllt Swissdec-Requirements)
- ✅ Retrieval + Entschlüsselung + XML-Parsing der Server-Antworten
- ✅ Optional: XML→HTML-Transformation mit XSLT für direkte Anzeige
- ✅ HTTP-Proxy-Support für Corporate Networks

### 1.3 · Was es NICHT tut (kritisch für ARK-Verständnis)

SwissDecTX macht **KEINES** von den folgenden Dingen, die ARK für eine eigene Swissdec-Zertifizierung bräuchte:

- ❌ Lohn-Grundberechnung (Brutto, Netto, Abzüge)
- ❌ Quellensteuer-Tarif-Management
- ❌ AHV/ALV/IV/EO-Berechnung
- ❌ BVG-Integration (Pensionskassen-Schnittstellen)
- ❌ UVG/KTG/FAK-Berechnung
- ❌ 13. Monatslohn, Ferien- und Feiertagsentgelt
- ❌ Lohnausweis (F11/Form 11a) Generierung
- ❌ GAV-Spezifik, Mutterschaft/Vaterschaft, Kurzarbeit
- ❌ Bewilligungs-Management (B, C, G, L, Ci)
- ❌ Grenzgänger-Sonderfälle

**Wichtig:** Der Text "SwissDecTX is fully certifiable as the transmission part of your application" sagt nur, dass der Transmitter für die Zertifizierung akzeptiert wird. Deine **Applikation selbst** muss durch den vollen Swissdec-Zertifizierungsprozess — inklusive aller fachlichen Business-Logik oben.

---

## 2. Die Kritische Klarstellung

### 2.1 · Q2's Behauptung vs. Realität

| Q2's Aussage in der Synthese | Tatsächlicher Stand |
|------------------------------|---------------------|
| "SwissDecTX als dritter Weg zwischen Eigen-Zertifizierung und Partner-Integration" | ❌ Ist kein dritter Weg — es löst nur den Transmitter-Teil |
| "~CHF 10k einmalig, ~CHF 2-3k jährlich Wartung" | ✅ Teilweise korrekt (CHF 5'500 + ~CHF 800 ab Jahr 2) |
| "Könnte Swissdec-Zertifizierung vereinfachen" | ⚠️ Nur den Transmitter-Teil, nicht die Business-Logik |

### 2.2 · Was Eigenentwicklung einer Swissdec-Payroll wirklich kostet

Unabhängig davon ob SwissDecTX verwendet wird, bleiben diese Kosten für eine eigene Swissdec-Zertifizierung bestehen:

| Kostenpunkt | Mit SwissDecTX | Ohne SwissDecTX |
|-------------|----------------|-----------------|
| Swissdec-Mitgliedschaft (jährlich) | CHF 11'000 | CHF 11'000 |
| Zertifizierungs-Audit (einmalig) | CHF 15–25'000 | CHF 15–25'000 |
| Transmitter-Entwicklung | **~0 Monate** | 6–12 Monate |
| Business-Logik-Entwicklung | **18–24 Monate** | **18–24 Monate** |
| Pflege bei ELM-Versionswechseln | ~2 Monate (Transmitter-Update) | 3–6 Monate (eigener Transmitter) |

**Kernpunkt:** SwissDecTX spart 6–12 Monate Transmitter-Entwicklung. Aber die **18–24 Monate Business-Logik-Entwicklung** bleiben. Das ist der eigentliche Kostentreiber.

---

## 3. Technische Details

### 3.1 · Implementierung

- **Sprache:** C# auf .NET 4.8
- **Paketgrösse:** 1.5–2.5 MB (sehr lightweight)
- **Installer:** Silent-Installer, kann in eigenen App-Installer eingebunden werden
- **APIs:** .NET, COM, "klassisches DLL"-Interface, Command-line
- **Plattform:** **Windows-native**

### 3.2 · Aufruf-Varianten

SwissDecTX kann aufgerufen werden aus:

- C# / VB.NET (native .NET)
- VB / VBA / Access / Delphi (via COM/ActiveX)
- C / C++ (via DLL)
- Jeder beliebige Sprache (via Command-line-Tool `SwissDecTX.exe`)
- Java, Ruby, PHP, Python (via Gateway Add-in, über File-based Protocol)

### 3.3 · Telemetrie

Explicit: **keine Telemetrie** — weder im Installer noch in den Komponenten. Begründung: Lohndaten sind vertraulich.

### 3.4 · Kompletter End-to-End-Flow

```
ARK Anwendung (Lohndaten generieren)
    ↓
ARK erzeugt Swissdec-konformes XML (= Business-Logik-Teil!)
    ↓
SwissDecTX validiert XML lokal
    ↓
SwissDecTX signiert + verschlüsselt mit Swissdec-Zertifikaten
    ↓
SwissDecTX sendet via HTTPS/TLS an Swissdec-Distributor
    ↓
SwissDecTX empfängt + entschlüsselt Antwort
    ↓
SwissDecTX übergibt XML-Antwort an ARK-Anwendung
    ↓
ARK Anwendung zeigt Resultat (oder SwissDecTX rendert HTML-Vorschau)
```

**Kritische Beobachtung:** Der komplexe Schritt (Erzeugen des korrekten Swissdec-XMLs aus Lohndaten) ist **vor** SwissDecTX. SwissDecTX hilft bei dem, was danach kommt — aber das ist der einfachere Teil.

---

## 4. Pricing

### 4.1 · Case 1: SwissDecTX-Transmitter alone (Windows-Deployment)

- **Einmalig:** **CHF 5'500** Flat-Fee (Stand 2017, evtl. heute höher)
- **Beinhaltet:** 1 Jahr Full Support, unlimited redistribution rights, alle Software-Updates
- **Wichtig:** **Royalty-frei** — keine Per-Customer-Kosten, keine Per-Employee-Kosten

Geeignet wenn: Anwendung läuft auf Windows, KMU-Kunden mit Internet-Connectivity.

### 4.2 · Case 2: SwissDecTX + Gateway Add-In (non-Windows)

- **Einmalig:** 1x SwissDecTX-Lizenz (CHF 5'500) + **Gateway-Lizenz pro Kundendeployment** (Preis auf Anfrage)
- Geeignet wenn: Anwendung läuft auf Linux/Mac, oder hohe Volumina mit asynchroner Übertragung

**Für ARK relevant weil:** ARK-CRM läuft auf Railway (Linux). Eine reine SwissDecTX-Integration würde einen separaten Windows-Microservice erfordern, **oder** Gateway-Add-In pro SaaS-Kunde kaufen (= Skalierungsproblem).

### 4.3 · Wartung ab Jahr 2

- Optionaler Maintenance-Plan (kleiner jährlicher Betrag, ~CHF 800–1'500 geschätzt)
- Gibt freien Zugang zu allen Minor- und Major-Updates (z.B. ELM 5.0 → 5.3 → 5.5)

---

## 5. Kunden-Basis (Vertrauensindikator)

30+ Software-Publisher in der Schweiz nutzen SwissDecTX in zertifizierten Payroll-Produkten:

- **ADP (Schweiz) AG** — Dietikon (globaler HR-Tech-Riese)
- **BE-terna Switzerland AG** — Root
- **Borema IT-Solutions AG** — Schwarzenbach SG
- **Comatic AG** — Sursee (Schweizer ERP)
- **DOP-GESTION SA** — Saint-Blaise
- **DOSIM SA** — Plan-les-Ouates
- **Etat de Vaud** — Département des Infrastructures
- **Hôpitaux Universitaires de Genève (HUG)**
- Plus ~25 weitere Schweizer Payroll-Publisher

### Was dieser Kunden-Mix sagt

- **ADP** als Kunde validiert die technische Qualität auf Enterprise-Niveau
- **Etat de Vaud + HUG** validiert Production-Stabilität für grosse Organisationen
- Alle CH-Regionen vertreten (Deutschschweiz + Romandie)
- 100% Erfolgsrate bei Swissdec-Zertifizierungen von Kunden mit SwissDecTX

**Einordnung:** Das Produkt ist solide, production-proven, kein Hobby-Projekt. Vertrauenswürdig für Enterprise-Use.

---

## 6. Technischer Fit mit ARK-Stack

### 6.1 · Stack-Inkompatibilität

| Dimension | ARK-Stack | SwissDecTX |
|-----------|-----------|------------|
| **Sprache** | TypeScript/JavaScript | C#/.NET |
| **Laufzeit** | Node.js | .NET 4.8 |
| **OS** | Linux (Railway) | Windows |
| **Architektur** | Cloud-native, serverless-friendly | Desktop/Server component |
| **Deployment** | Docker-Container | Windows-Installer |

**Konsequenz:** SwissDecTX ist **nicht direkt einbindbar** in ARKs Node.js-Backend auf Railway. Es gäbe zwei Wege:

**Option A: Windows-Microservice**
- Separater Windows-Server (Azure, AWS EC2 Windows, oder on-premise)
- HTTP-API-Layer um SwissDecTX command-line-tool
- Node.js-Backend macht REST-Calls
- **Nachteil:** Zusätzliche Infra-Komplexität, separates Deployment, zusätzliche Kosten

**Option B: Gateway Add-In**
- File-based Protocol zwischen ARK und SwissDecTX-Gateway
- Gateway läuft auf Windows-Server
- **Nachteil:** Per-Customer-Lizenz → bei SaaS-Skalierung teuer; File-System-basiert = nicht cloud-native

### 6.2 · Vergleich: Was der ELM-Standard heute bietet

ELM 5.0 (gültig seit 2024) bringt eine REST-API für den PIV-Modus. Das bedeutet:

- **Eine moderne Swissdec-Anwendung muss nicht mehr zwingend den klassischen (SOAP-ähnlichen) Transmitter-Weg nehmen**
- REST-basierte Transmission ist möglich — und deutlich einfacher von Node.js aus
- SwissDecTX ist ein **Wrapper um die Legacy-Transmission-Schicht**. Für eine grüne-Wiese-Node.js-App ist es möglicherweise gar nicht optimal

### 6.3 · Fazit technischer Fit

**SwissDecTX ist für ARK technisch suboptimal.** Der Stack-Mismatch würde entweder:
- einen separaten Windows-Dienst erfordern (Overhead), ODER
- das Gateway Add-In pro SaaS-Kunde (Skalierungskosten), ODER
- als Alternative direkte REST/SOAP-Integration gegen Swissdec (selbst implementiert)

---

## 7. Alternative: STEPtx von itServe AG

Eine wichtige Alternative aus dem Research: **STEPtx** von itServe AG (der offizielle Swissdec-Zertifizierungspartner!).

### Kurzvergleich

| Feature | SwissDecTX | STEPtx |
|---------|------------|--------|
| **Hersteller** | Axel Rietschin Software (unabhängig) | itServe AG (Swissdec-Zertifizierungskörper) |
| **Scope** | Nur ELM-Transmitter | ELM + KLE (Krankheit/Unfall) + SUA (Unternehmens-Auth) |
| **Tech-Stack** | Windows/.NET | Moderne Interfaces: REST, SOAP, gRPC, OpenAPI |
| **Abstraktion** | Low-level (XML-basiert) | "Smart Protocol Use" (abstrahiert, entschlackt) |
| **Dialog-Messages** | Kunde handhabt | STEPtx übernimmt (inkl. WebUI) |
| **Preis** | CHF 5'500 + Gateway-Lizenzen | Auf Anfrage (vermutlich höher, enterprise-pricing) |
| **Kunden** | 30+ Software-Publisher | Unbekannt (weniger öffentliche Info) |

### Einordnung

**STEPtx ist der modernere, breiter angelegte Konkurrent.** Für eine Greenfield-Node.js-SaaS-App wäre STEPtx möglicherweise der bessere Fit — REST/gRPC-Interfaces passen nativ zum ARK-Stack.

**Aber:** Keine öffentlich dokumentierte Kundenliste, kein öffentliches Pricing. Das macht die Evaluation schwieriger. Falls ARK ernsthaft eigene Swissdec-Payroll baut: **beide evaluieren**, nicht nur SwissDecTX.

---

## 8. Strategischer Fit mit ARKs 4 Optionen

Aus der Research-Synthese:

| Option | SwissDecTX relevant? | Warum |
|--------|---------------------|-------|
| **A: Full Custom Build** (Eigenbau Payroll + Swissdec-Zert) | ⚠️ Teilweise | Spart 6–12 Monate Transmitter-Entwicklung. Aber 18–24 Monate Business-Logik-Entwicklung bleiben. Und der Stack-Mismatch bleibt. |
| **B: Hybrid** (Lucca/Personio intern + externes Payroll) | ❌ Nein | Partner handhaben Transmitter selbst |
| **C: Wait + Abacus** (Später Abacus/Bexio kaufen) | ❌ Nein | Abacus/Bexio haben eigene Swissdec-Zertifizierung inkl. Transmitter |
| **D: Commission-First, HR-Lean** (Aktuelle Empfehlung) | ❌ Nein | Keine eigene Payroll geplant, Bexio/Treuhänder handhaben alles |

### Wann würde SwissDecTX doch relevant?

Nur in einem sehr spezifischen Szenario: **Phase 3 (Jahr 2028+), wenn ARK-SaaS 50+ Boutique-Kunden hat und entscheidet, eine eigene Swissdec-zertifizierte Payroll als Premium-Feature anzubieten.**

Und selbst dann:
- Die 18–24 Monate Business-Logik-Entwicklung sind der Hauptaufwand
- Stack-Inkompatibilität ist dann noch grösser (ELM 6.0 oder 7.0 zu der Zeit)
- STEPtx oder direkte REST-Integration wahrscheinlich moderner
- Grüne-Wiese-Entwicklung mit ELM 6+ REST-API könnte SwissDecTX obsolet machen

---

## 9. Empfehlung

### Kurz-Version

**Jetzt nicht einsetzen. Dokument in 2–3 Jahren erneut prüfen.**

### Begründung

1. **SwissDecTX löst nicht das Hauptproblem** der Swissdec-Zertifizierung (Business-Logik-Entwicklung = 18–24 Monate)
2. **ARK's aktuelle Empfehlung ist Option D** (Commission-First, HR-Lean) — SwissDecTX wäre irrelevant
3. **Stack-Mismatch** (Windows/.NET vs. Linux/Node.js) würde Infrastruktur-Overhead einführen
4. **Moderne ELM 5.0+ REST-API** macht den Transmitter-Wrapper langfristig weniger attraktiv
5. **STEPtx** als Alternative wäre ohnehin technisch der bessere Fit für ARK-Stack

### Konkrete nächste Schritte

**Kurzfristig (nichts tun):**
- Dokument ablegen unter `/research/vendor-evaluations/`
- Keine Demo, keine Kontaktaufnahme, keine Kosten

**Mittelfristig (12–18 Monate):**
- Wenn ARK-SaaS 20+ zahlende Kunden hat UND wenn Payroll-Eigenbau ernsthaft diskutiert wird:
  - Dieses Dokument aktualisieren (ELM-Version zu dem Zeitpunkt prüfen)
  - **Beide** evaluieren: SwissDecTX + STEPtx
  - Swissdec-Mitgliedschaft in Kostenplan einarbeiten (CHF 11'000/Jahr allein)

**Langfristig (3+ Jahre):**
- Entscheidung: Eigene Payroll als Premium-Feature oder nicht?
- Falls ja: technische Deep-Dive mit beiden Anbietern
- Falls nein: SwissDecTX-Dokument archivieren

---

## 10. Offene Fragen (falls doch Kontakt)

Falls Peter entgegen dieser Empfehlung SwissDecTX-Demo will:

1. **Linux-Fit:** "Hat sich in SwissDecTX 5.x die Abhängigkeit von Windows/.NET 4.8 geändert? .NET Core Support geplant?"
2. **SaaS-Pricing:** "Bei Multi-Tenant-SaaS — wird pro Tenant lizenziert oder pro ARK-Instanz?"
3. **Gateway Add-In Pricing:** "Konkreter CHF-Preis pro Customer-Deployment beim Gateway?"
4. **ELM 5.0 REST-API:** "Integriert ihr den neueren REST-Mode, oder bleibt ihr beim Legacy-SOAP-Mode?"
5. **Migration zu STEPtx:** "Gibt es Erfahrungen mit Kunden, die zu STEPtx migriert sind? Warum sie das getan haben?"
6. **Support-Sprachen:** "DE-Support verfügbar oder nur FR/EN?"
7. **Support SLA:** "Was ist die Reaktionszeit bei kritischen Issues (z.B. ELM-Versionswechsel mit Compliance-Deadline)?"

---

## 11. Anhang: Weiterführende Links

- **SwissDecTX Website:** https://www.swissdectx.ch/
- **Description / Technical Overview:** https://www.swissdectx.ch/description/
- **Downloads (inkl. Demo-License):** https://www.swissdectx.ch/downloads/
- **Gateway Add-In Details:** https://www.swissdectx.ch/gateway/
- **Kundenliste:** https://www.swissdectx.ch/customers/
- **STEPtx (Alternative):** https://www.itserve.ch/de/steptx
- **Swissdec-Zertifizierungsliste:** https://www.swissdec.ch/certified-erp/standard/elm-5-0-4
- **Kontakt SwissDecTX:** info@swissdectx.ch

---

## Related

- `ARK_HR_RESEARCH_SYNTHESE_v0_1.md` — Gesamt-Synthese (Q2 hatte SwissDecTX erwähnt)
- `ARK_LUCCA_EVALUATION_v0_1.md` — Parallele Vendor-Evaluation
- Künftig: `ARK_HR_TOOL_PLAN_v0_2.md` mit finaler Option-Entscheidung
- Künftig (bei Bedarf): `ARK_STEPTX_EVALUATION.md` als Alternative
