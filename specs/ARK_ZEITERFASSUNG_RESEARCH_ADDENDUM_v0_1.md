---
title: "ARK Zeiterfassung · Research-Addendum zu Plan v0.1"
type: research
phase: 3
created: 2026-04-19
updated: 2026-04-19
supersedes: null
updates: "ARK_ZEITERFASSUNG_PLAN_v0_1.md"
sources_external: ["Perplexity Deep-Research · 4 Fach-Calls"]
tags: [research, addendum, hardware, bexio, ux, dsg, fadp, postfinance, proportionalität]
---

# Research-Addendum zu Plan v0.1 · Deep-Research-Ergebnisse (4 Calls)

Ergebnisse aus 4 Perplexity-Deep-Research-Calls. Dieses Dokument **updated den Plan v0.1** — identifiziert Fehler, ergänzt Details, schärft rechtliche Baseline. Plan v0.2 (ausstehend) wird diese Erkenntnisse einarbeiten.

---

## 🔴 KRITISCHE KORREKTUREN ZU PLAN v0.1

### K1 · Mobatime macht KEINE Biometrie-Scanner

**Befund**: Mobatime (Dübendorf, CH) ist Spezialist für Zeit-Synchronisation (Time-Server, Analog-/Digital-Uhren-Distribution). Bietet **keine Fingerprint-Terminals** für Mitarbeiter-Zeiterfassung.

**Konsequenz**: In Plan v0.1 §4.1 war Mobatime AMG als Hardware-Option gelistet — **falsch**. Zu streichen und zu ersetzen.

**Korrigierte Hardware-Liste:**

| Hersteller | Modell | Swiss-Support | Preis CHF | API | Empfehlung |
|------------|--------|---------------|-----------|-----|------------|
| **Dormakaba** | Terminal 97-00 | ✅ direkt (CH-HQ) | 1'500-1'800 | REST + B-COMM (OAuth v2 + API-Key) | **TOP-Wahl für CH** — direkter Support + enterprise-grade |
| **ZKTeco** | iClock 560 | ❌ intl. Distrib. | 450-550 | ZKBio Time API + BioTime 8.5 API (JSON/REST) · kein Webhook | günstigste Option, China-OEM (DSG-Prüfung nötig) |
| **Suprema** | BioStation 3 | ⚠ CH-Distrib. | 1'000-1'400 | **Webhook-Support** via CLUe-Portal | beste API-Architektur · kleinste Bauform |
| **Dormakaba** | B-Web 97-10 | ✅ direkt | 800-1'200 | B-COMM | Mittelklasse-Alternative zu 97-00 |
| ~~Mobatime AMG~~ | ~~—~~ | — | — | — | **streichen** · kein Biometrie-Produkt |

### K2 · Proportionalitäts-Test zeigt: Fingerabdruck für Standard-Office-Zeiterfassung ist rechtlich grenzwertig

**Befund (FADP + Proportionalitäts-Jurisprudenz):**

> "Das Verarbeiten biometrischer Daten für Zeiterfassung ist nur zulässig, wenn **kein milderes Mittel** den Zweck gleichwertig erreicht. In Standard-Office-Umgebungen (Banken, Versicherungen, Dienstleister, Beratung) sind Karten/PIN/Mobile-App milder und ausreichend."

**Präzedenzfälle:**
- **PostFinance-Urteil FDPIC Mai 2025**: Voiceprint-Authentifizierung musste komplett umgebaut werden · Opt-In + explizite schriftliche Einwilligung + Löschung bestehender Voiceprints ohne Zustimmung. Appeal hängig, aber Grundrichtung eindeutig.
- **EU LitChamber Jurisprudenz (indirekt auf CH anwendbar)**: "Weniger einschneidende Alternativen müssen zuerst versucht werden."
- **FADP Art. 5 + Art. 22**: Biometrie = sensible Daten · DSFA VOR Einführung Pflicht (nicht nachträglich).

**Konsequenz für ARK:**
Für eine Headhunting-Boutique mit ~20 MA im normalen Büro-Setting ist die **rechtliche Baseline gegen Fingerprint-Only**. Wir bauen in **Phase 3.3 zuerst eine mildere Alternative** (PIN/Karte/Mobile-App) als default. Biometrie nur für MA die **explizit opt-in** und nur wenn wir klar begründen können warum milder Mittel nicht reichen (was in unserem Setting **schwer** zu begründen ist).

**Empfehlung v0.2:**
- **Phase 3.3a** · PIN- oder RFID-Karten-basierte Stempel (Standard-Option) · Dormakaba B-Web 97-10
- **Phase 3.3b** · Fingerabdruck nur als zusätzliche Opt-In-Option mit DSFA + vollständiger Einwilligungs-Dokumentation · **nur wenn PO es weiter verfolgt**
- **Alternative ganz ohne Terminal**: Mobile-App-Stempeln (BYOD) · geringste DSG-Risiken, keine Hardware, nutzt OAuth-Accounts aus CRM

### K3 · Bexio hat bereits Time-Modul mit API + Ökosystem

**Befund**:
- **Bexio Pro-Paket (CHF 45/User/Mt)** bietet vollständiges Zeiterfassungs-Modul mit Projekt-Zentrierung, Rate-Matrix (MA × Mandat × Activity), Invoice-Automation aus Timesheets, mobile `bexioGo`-App.
- **Bexio REST API** (OAuth 2 + JSON) + **Webhook-Support** + Rate-Limit 429.
- **Integrations-Ökosystem existiert**: TimeStatement (tiefe Bexio-Integration, Auto-Invoice-Draft), Memtime (passive Activity-Tracking → Bexio-Entries), Clockify (via Zapier).
- Bexio adressiert SECO-Compliance nativ (ArG Art. 73).

**Konsequenz für ARK-Architektur**:

3 Optionen für Bexio-Anbindung (Peter-Entscheidung Dienstag):

| Option | Was | Vor/Nachteile |
|--------|-----|---------------|
| **A · ARK-eigenes Time-Tool + Push zu Bexio** | Wir erfassen in ARK (zeit.html), pushen approved-Wochen als Invoice-Drafts zu Bexio | **PRO**: volle Kontrolle, tiefe CRM-Integration (Mandate, Prozesse, Activities), keine MA-Lizenzkosten Bexio-Time. **CON**: mehr Dev-Aufwand |
| **B · Bexio-Time-Modul nativ nutzen + Pull ins CRM** | Bexio ist Source-of-Truth für Zeit, ARK zeigt Read-Only-Mirror | **PRO**: weniger Dev, SECO-Compliance mitgeliefert. **CON**: Lizenzkosten CHF 45/User/Mt = ~CHF 900/Mt für 20 MA, kein custom UX, schwache CRM-Integration |
| **C · TimeStatement als Middleware** | TimeStatement für Zeit, sync zu beidem (Bexio + ARK) | **PRO**: etablierte Bexio-Integration, weniger Risiko. **CON**: dritter Vendor, CHF-Kosten, doppelte Datenhaltung |

**Empfehlung**: Option A (ARK-eigenes Tool mit Bexio-Push) — wir haben die CRM-Daten, tiefe Mandat-Integration ist Key-Value, Dev-Aufwand ist nur einmalig. Bexio-Integration via `POST /api/v4/invoices` mit Bexio-Item-IDs.

---

## ✅ BESTÄTIGUNGEN aus Research zu Plan v0.1

### B1 · Swiss Arbeitsrecht-Setup in Plan v0.1 korrekt

Plan v0.1 §2 beschreibt ArG Art. 73/73a/73b richtig:
- Pflicht-Tracking Basis (Art. 73): ✅ richtig
- Simplified Procedure ab 25 % Autonomie (Art. 73b): ✅ richtig
- Waiver ab 50 % Autonomie + CHF 120k (Art. 73a): ✅ richtig
- 5-J. Aufbewahrung: ✅ richtig

**Ergänzung v0.2**: Jedes Waiver braucht **GAV oder schriftl. Einzel-Vereinbarung** + kann jährlich widerrufen werden. In Plan v0.1 nicht explizit erwähnt.

**Neuer Hinweis für ARK**: PW (Managing Partner) mit hohem Autonomie-Grad + Salary wahrscheinlich über CHF 120k = Waiver möglich. Für alle anderen MA: Simplified Procedure sinnvoll (25 % Autonomie trifft auf Consultant-Rollen zu).

### B2 · 0.5-h Granularität + Vertrauensarbeit-Default korrekt

Plan v0.1 §6 · 0.5-h-Granularität ist Markt-Standard für Beratungs-Zeiterfassung (Harvest, Clockodo, Zep). Minuten-Tracking nur in High-Volume-Agenturen.

### B3 · Gap-Analyse Datenmodell korrekt

`fact_time_entries`, `fact_time_weeks`, `fact_time_budgets`, `fact_overtime_snapshots` sind Standard-Schema-Patterns für Beratungs-Zeiterfassung.

---

## 🆕 NEUE ERKENNTNISSE aus Research

### N1 · UX-Patterns Top-5 (für v0.2 Mockup-Update)

**Aus Clockodo/Zep/Harvest/Productive Best-Practices:**

1. **Copy-Day / Copy-Week-Template**
   - Clockodo: „Copy Day" 3-dot-menu · kopiert alle Einträge eines Tages auf andere Tage/Wochen
   - **Impact für uns**: zeit.html sollte Button „Woche kopieren von KW X" haben → spart Zeit für MA mit konstanten Wochen-Rhythmen
   - Implementation: `POST /time-entries/copy-week` mit Source-Week + Target-Week

2. **Calendar-Sync (Outlook/Google)**
   - Clockodo + Productive: Calendar-Events werden direkt als Buchungs-Vorschläge angezeigt · 1-Klick-Konvertierung
   - **Impact für uns**: Outlook-Tokens haben wir bereits (Email-Tool) · können wir wiederverwenden
   - Implementation: Worker pullt Outlook-Events, matcht gegen Mandate/Activities → Buchungs-Vorschläge in zeit.html

3. **Inline-Editing im Grid (ohne Modal)**
   - Harvest Week-View: Klick direkt in Zelle → Auto-Save in Sekunden
   - **Impact für uns**: zeit.html aktuelle Version öffnet Drawer für jeden Eintrag — das ist Friction. Inline-Edit wäre besser.
   - Implementation v0.2: zeit.html Grid-Cells direkt editable (contenteditable oder input inline)

4. **Keyboard-Shortcuts**
   - Harvest Windows-App: `Ctrl+Alt+N` startet Timer · `Ctrl+Alt+F` zeigt Favoriten · `Ctrl+T` zu heute
   - **Impact für uns**: Power-User-Feature, reduziert Friction für Senior-Consultants
   - Implementation v0.2: `Ctrl+S` Save · `Ctrl+D` duplicate row · `Ctrl+C/V` copy-paste-row · `Escape` close Drawer

5. **Memtime-Style Passive Activity-Tracking (optional Phase 3.4)**
   - Memtime-Desktop-App loggt aktive Apps/Windows → Buchungs-Vorschläge
   - **Impact für uns**: wäre nice-to-have, aber DSG-heikel (implizite Überwachung) · **Phase 3.4+ oder später**

### N2 · Senior-Consultant-Resistance-Factors

**Aus Research (ebillity, Deltek, Coretime-Studien):**

Senior Consultants resist Zeiterfassung nicht wegen Faulheit sondern weil:
1. **Surveillance-Perception**: Sie fürchten ihre Zeit wird gegen sie verwendet (Layoffs, Performance-Reviews)
2. **Admin-Burden-Opportunity-Cost**: Ihre Zeit ist CHF 200+/h wert — 5 min/Tag × 220 AT = ~18 h/Jahr in Admin
3. **Reductive-Metrics**: Strategische Arbeit (Mentoring, Relationship-Building, Thought-Leadership) passt schlecht in billable/non-billable-Dichotomie
4. **Loss-of-Autonomy**: Strikte Kategorien fühlen sich wie Mikro-Management an
5. **Memory-Decay**: Nach 24h sind Einträge 25-40 % ungenau — führt zu Frustration

**Implikation für ARK**:
- **Nicht** Senior-Partner PW zum Stempeln zwingen (Waiver Art. 73a)
- **Transparente Kommunikation** was Zeit-Daten verwendet wird (Mandate-Profitability, NICHT Performance-Monitoring)
- **Selbst-Analyse-Dashboard** für MA (eigene Utilization sehen, Vergleich freiwillig)
- **Keine Screenshots / Keystroke-Logging / Screen-Tracking** — verboten per Policy

### N3 · Bundle-Referenzen für Time-Packages

**Bexio/TimeStatement Pricing-Modelle** für konkrete `dim_time_packages`-Inhalte:

| Paket | Slots/Wo | CHF/Slot/Wo | CHF/Mt pauschal | Notiz |
|-------|----------|-------------|------------------|-------|
| Entry 2-Slot | 2 | 1'950 | ~17'000 | 2 × 10 h Research/Wo |
| Medium 3-Slot | 3 | 1'650 | ~22'000 | 3 × 10 h (degressiv) |
| Professional 4-Slot | 4 | 1'250 | ~22'500 | 4 × 10 h (volles Team) |

Pausch-Annahmen (nicht empirisch, nur Skeleton):
- 1 Slot = 10 h Research / Wo (nicht zu verwechseln mit Time-Mandat-Stunden)
- Cancellation: 3 Wochen Kündigungsfrist

PO-Review-Punkt: Slot-Definition + Preise müssen durch Peter + Backoffice geprüft werden.

### N4 · DSFA-Template-Struktur (neue Dokumente-Pflicht)

Falls Biometrie doch eingeführt wird, DSFA (Datenschutz-Folgeabschätzung) Pflicht. Struktur:

```
DSFA · Biometrie-Zeiterfassung ARK Arkadium
1. Planned Processing Description
   - Was: Fingerprint-Templates für Zeiterfassungs-Stempeln
   - Wer: alle MA (opt-in), HR-Manager, Admin
   - Wo: Dormakaba-Terminal Zürich-HQ
   - Wie lange: Template-Hash solange MA aktiv · Löschung 3 Mt nach Austritt
2. Necessity & Proportionality Analysis
   - Warum NICHT Karte/PIN (gleicher Zweck mit milderem Mittel)?
   - [hier muss PW konkrete Begründung liefern — z.B. Karte geht verloren, PIN wird geteilt]
3. Risk Assessment
   - Risiko: Template-Diebstahl → reverse-engineering (sehr niedrig, AES-256)
   - Risiko: Zweckentfremdung (Profiling) → Policy + Audit-Log
   - Risiko: Zwang zur Einwilligung → Opt-Out jederzeit mit PIN-Fallback
4. Mitigating Measures
   - Template gehashed, lokal auf Device + verschlüsselt im ERP
   - Einwilligungs-Formular pro MA, widerrufbar
   - Alternative Auth-Methode immer verfügbar
   - Audit-Log aller Zugriffe
   - FDPIC-Konsultation falls Residual-Risk hoch
5. Documentation + Review-Zyklus
```

**Aufwand DSFA**: ~20-40 Std. Rechts-Review + interne Analyse. **Kosten**: CHF 5k-10k (externer Datenschutz-Berater) falls wir das machen.

### N5 · Bexio API-Endpoints für Integration

**Relevante Endpoints** aus Bexio-Docs (für Phase 3.1 Billing-Integration):

| Endpoint | Zweck |
|----------|-------|
| `GET /3.0/contacts` | Kunden-Stamm holen (Mandats-Bezug) |
| `POST /3.0/kb_offer` | Offerte erstellen |
| `POST /3.0/kb_invoice` | Rechnung erstellen (aus Timesheet-Summe) |
| `POST /3.0/kb_invoice/{id}/issue` | Rechnung finalisieren |
| `GET /2.0/timesheet` | Bexio-Timesheets lesen (falls wir Dual-Tracking haben) |
| `POST /2.0/timesheet` | Bexio-Timesheet-Eintrag erstellen |

**OAuth-Flow**: Backoffice authorisiert ARK als App in Bexio · ARK erhält Refresh-Token · 429 Rate-Limit bei Bulk-Sync beachten.

---

## 📋 ACTIONS für Plan v0.2

Diese Liste sollte Peter am Dienstag freigeben, bevor v0.2 geschrieben wird:

1. [ ] **Hardware-Liste korrigieren**: Mobatime raus, Dormakaba als TOP-Wahl für CH
2. [ ] **Phase 3.3 splitten**: 3.3a = PIN/Karte-Terminal (default) · 3.3b = Biometrie (nur wenn PO greenlight + DSFA)
3. [ ] **Bexio-Integration**: Option A (ARK-eigenes Time-Tool mit Push zu Bexio) empfehlen · konkrete Endpoints in §5
4. [ ] **UX-Patterns einbauen**: Copy-Day-Template, Calendar-Sync (Outlook aus Email-Tool), Inline-Editing Grid, Keyboard-Shortcuts
5. [ ] **DSFA-Template** anhängen als Annex D (falls Biometrie)
6. [ ] **Consultant-Resistance-Mitigation-Sektion** ergänzen: keine Surveillance, transparente Zweckbindung, Self-Analytics
7. [ ] **Mobile-App-Stempeln als Biometrie-Alternative** evaluieren (Phase 3.3a-alt)
8. [ ] **PW-Waiver + GAV-Template** für Art. 73a-Mitarbeiter dokumentieren

---

## Related

- `ARK_ZEITERFASSUNG_PLAN_v0_1.md` — Original-Plan (wird durch dieses Addendum updated)
- Künftig: `ARK_ZEITERFASSUNG_PLAN_v0_2.md` (nach Peter-Review Dienstag)
- Künftig: `ARK_ZEITERFASSUNG_DSFA_v0_1.md` (falls Biometrie)
- `ERP Tools/zeit.html` — Aktuelles Mockup (UX-Patterns aus N1 einbauen)
