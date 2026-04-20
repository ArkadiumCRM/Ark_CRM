---
title: "Zeit-Research Overview · 3 AIs konsolidiert"
type: meta
created: 2026-04-19
updated: 2026-04-19
sources: [
  "zeit-research-ai1-structured.md",
  "zeit-research-ai2-compass.md",
  "zeit-research-ai3-deep-spec.md"
]
tags: [phase3, zeit, research, consolidation, legal, schema]
---

# Zeit-Research · Übersichtsplan · 3 AIs konsolidiert

**Datum:** 2026-04-19
**Stand:** 3 AI-Antworten auf Prompt `research-prompts-phase3.md · Prompt 1 Zeiterfassung` vorliegen. Overview + kritische Divergenzen + Konsolidierungs-Plan.

---

## 1. Quellen

| # | File | Charakter | Vermutliche Quelle | Size |
|---|------|-----------|-------------------|------|
| AI-1 | [zeit-research-ai1-structured.md](zeit-research-ai1-structured.md) | Strukturiert-kompakt · Section-by-Section · 8 URL-Zitate | Perplexity-artig | 22 KB |
| AI-2 | [zeit-research-ai2-compass.md](zeit-research-ai2-compass.md) | Detailliert · UUID-Schema · ELM 5.0 · 15 Open Questions · 12 Risiken | Claude-artig (compass_artifact-Prefix) | 50 KB |
| AI-3 | [zeit-research-ai3-deep-spec.md](zeit-research-ai3-deep-spec.md) | Prosa-lastig · 3-Konten-Modell · Rechts-kritisch · Entity-Annotations | GPT-Deep-Research-artig | 50 KB |

---

## 2. CRITICAL CORRECTIONS (AI-3 + AI-2 vs. AI-1 + Original-Prompt)

### 2.1 BGE 4A_295/2016 ist **nicht** Zeiterfassung

Mein Original-Prompt + AI-1 zitieren BGE 4A_295/2016 als Leitentscheid zur Zeiterfassungspflicht. **AI-3 widerspricht korrekt**: Das Urteil ist ein **mietrechtlicher Fall** zur Anfechtung des Anfangsmietzinses, **nicht** Arbeitsrecht.

**Richtige Leitentscheide zur Zeiterfassung:**

| Urteil | Kernaussage |
|--------|-------------|
| **BGE 4A_227/2017** | Leitentscheid: aus Art. 46 ArG + Art. 73 ArGV 1 ergibt sich **indirekt eine Pflicht zur Zeiterfassung**. Ohne Erfassung = Beweiserleichterung via Art. 42 Abs. 2 OR |
| **4A_482/2017 E. 3.2** | Bestätigt Schätzungsbefugnis (Art. 42 Abs. 2 OR analog) |
| **4A_29/2023** + **4A_59/2024** | MA-geführte Eigenkontrolle als Beweismittel zulässig bei fehlender AG-Erfassung |
| **4C.307/2006** + **4A_285/2019** | Beweislast bleibt grundsätzlich beim Arbeitnehmenden |
| **BGE 129 III 171** + **4A_38/2020** | Leitende Angestellte ohne explizite Arbeitszeitregelung = nur ausnahmsweise Überstunden-Anspruch |
| **BGE 124 III 126** | Bestätigt Berner/Zürcher/Basler Skala als zulässige Konkretisierung von Art. 324a Abs. 2 OR |

**Action:** Grundlagen + Specs NICHT mit 4A_295/2016 zitieren. Stattdessen 4A_227/2017 als Leitentscheid.

### 2.2 Berchtoldstag ist in ZH **nicht** gesetzlich

AI-1 listet Berchtoldstag 2.1. als gesetzlichen Feiertag → **FEHLER**. AI-2 + AI-3 korrekt: Nur **9** gesetzliche Feiertage in ZH (Neujahr, Karfreitag, Ostermontag, 1. Mai, Auffahrt, Pfingstmontag, Bundesfeier 1.8., Weihnachten, Stephanstag). Berchtoldstag / Sechseläuten / Knabenschiessen = **lokal/vertraglich**, nicht gesetzlich.

**Action:** `fact_holiday_cantonal.is_statutory` Flag zwingend + UI-Unterscheidung `gesetzlich` vs `lokal-firmenpolicy`.

### 2.3 Berner Skala ↔ Zürcher Sitz Konflikt

Original-Prompt nennt "Berner Skala", Firma sitzt in Zürich. **AI-3 warnt explizit**: SECO weist für Kanton ZH die **Zürcher Skala** als gerichtliche Referenz aus.

| Skala | 1. DJ | 2. DJ | 3.–4. DJ | 5.–9. DJ |
|-------|-------|-------|----------|----------|
| **Bern** (grosszügiger) | 3 Wo | 1 Mt | 2 Mt | 3 Mt |
| **Zürich** (lokal ZH) | 3 Wo | 8 Wo | 9–10 Wo | 11–15 Wo |
| **Basel** | 3 Wo | 9 Wo | 10–11 Wo | 12–16 Wo |

**Empfehlung AI-2 + AI-3:** Schema `salary_continuation_scale` mit Options `BERN|ZURICH|BASEL|INSURANCE_EQUIV`. Default = Zürich (rechtlich zwingend bei Gerichtsfall im Kanton), Bern optional als MA-freundliche Policy.

**Decision Peter:** Welche Skala als Default? → Open Question #13 unten.

### 2.4 "60h/Woche illegal" ist Policy, nicht Gesetz

AI-1 + AI-2 schreiben "60h/Woche = illegal". **AI-3 korrigiert**: Gesetzeswarnung ist **45h** (Art. 9 ArG Büropersonal) + Jahreslimit **170h Überzeit** (Art. 12 ArG). 60h/Woche = interner Policy-Alarm, nicht gesetzliche Grenze.

**Action:** UI-Wording klar trennen:
- `Gesetzeswarnung` (bezieht sich auf ArG Art. 9/12)
- `Firmenalarm` (bewusst interne Policy, z.B. 60h-Schwelle)

### 2.5 ELM 5.0 statt 4.0

AI-2 korrekt: **ELM 5.0** ist ab Abrechnungsjahr 2026 Pflicht, **ELM 4.0 Deadline 30.6.2026** (Phaseout). Namespace `dom-ch-salarydeclaration-5`. AI-1 erwähnt ELM allgemein ohne Version.

---

## 3. CONSENSUS (alle 3 AIs übereinstimmend)

| Thema | Konsens |
|-------|---------|
| **Art. 73a** (GAV-basierter Verzicht) | **N/A** — kein GAV in Headhunting-Boutique, strukturell ausgeschlossen |
| **Art. 73b** (vereinfachte Erfassung) | Einziger Weg für Autonomie-Rollen. Erfordert schriftliche Mehrheits-Vereinbarung (<50 MA) |
| **Höchstarbeitszeit Büro** | 45h/Woche (Art. 9 ArG) |
| **Jahres-Überzeit-Cap** | 170h (Art. 12 ArG bei 45h-Regime) |
| **Zuschlag Überzeit** | 25% (ArG Art. 13 / OR Art. 321c Abs. 3) |
| **Ferien-Mindestanspruch** | 4 Wochen (OR 329a), 5 bei <20 Jahre |
| **Ferien-Verjährung** | 5 Jahre (OR 128) |
| **Ruhezeiten** | 11h täglich, 35h wöchentlich (ArG Art. 15a/21) |
| **Pausen** | 15min ab 5.5h, 30min ab 7h, 60min ab 9h |
| **Audit-Trail-Aufbewahrung** | mind. 5 Jahre (ArGV 1 Art. 73 Abs. 2) |
| **Arztzeugnis-Schwelle** | ab Tag 3 Default, konfigurierbar (Firmenpolicy) |
| **State-Machine Time-Entry** | draft → submitted → approved → locked → corrected |
| **UI-Pattern** | 540px-Drawer, Editorial-Serif, Sidebar 56/240px, Dashboard+Meine-Zeit+Monat+Abwesenheiten+Team+Saldi+Admin |
| **Timer-Logik** | Timer-Start/Stop + manuelle Nachträge + Bulk-Copy-Funktion |
| **Feiertags-Teilzeit** | Anteilige Anrechnung nach `variant_percent` |
| **CRM-Integration** | Projekt-Dropdown aus `fact_process_core` (active filter) |
| **Commission-ZEG-Trigger** | Event `time_entry.approved` → Recalc-Queue |
| **Treuhand-Export** | Bexio-CSV (Phase 1) + ELM 5.0 (Phase 2) |

---

## 4. DIVERGENZEN · braucht Peter-Entscheidung

### 4.1 Schema-Stil

| | AI-1 | AI-2 | AI-3 |
|-|------|------|------|
| PK-Typ | `SERIAL INT` | `UUID DEFAULT gen_random_uuid()` | `BIGSERIAL` |
| Enums | `VARCHAR(50)` | `CREATE TYPE ... AS ENUM` | `CREATE TYPE ... AS ENUM` |
| Overlap-Prevention | keine | GIST EXCLUDE | `btree_gist` EXCLUDE |

**Empfehlung:** AI-2 Stil (UUID + ENUM + GIST). UUIDs sind in CRM-Welt sicherer (keine sequenzielle Leak, verteilbar), ENUMs erzwingen Integrität auf DB-Ebene, GIST verhindert Überlappungen atomar.

### 4.2 3-Konten-Modell (AI-3 unique)

AI-3 empfiehlt **strikte Trennung** in 3 Saldokonten:

1. **Sollzeitkonto** (Ist − Soll bei vertraglich 42.5h)
2. **OR-Mehrarbeits-Konto** (Ist > 42.5h bis ≤ 45h → Überstunden per OR 321c)
3. **ArG-Überzeit-Konto** (Ist > 45h → Überzeit per ArG 12, 170h Jahreslimit, 25% Zuschlag)

AI-2 trennt auch (`ueberstunden` vs `ueberzeit`), AI-1 nur ein Konto.

**Empfehlung:** AI-3 3-Konten-Modell umsetzen. Die 42.5h↔45h-Zone ist juristisch NICHT gleich der >45h-Zone. Sonst → falsche Payroll-Exports + unbrauchbare Gerichtsreports.

### 4.3 Abwesenheitstyp-Umfang

| AI | # Typen | Umfang |
|----|---------|--------|
| AI-1 | 13 | Basis: Ferien/Krank/Unfall/Militär/MAT/PAT/CARE/COMP/UNE/BER |
| AI-2 | 21 | + ADOPT/CARE_CHILD_LONG/WEDDING/MOVE/DOCTOR/AUTH (Behörden) |
| AI-3 | 25 | + VACATION_HALF_AM/PM/SABBATICAL/OFFICIAL_DUTY/EDUCATION_PAID/UNPAID |

**Empfehlung:** AI-2-Basis (21) + AI-3-Halbtag-Varianten. Sabbatical + Umzug-Tag als Firmenpolicy-Opt-in konfigurierbar.

### 4.4 Feiertags-Credit-Formel

- AI-1: einfach "anteilig"
- AI-2: `credit_h = (variant_percent/100) × (target_h_per_week/5) × is_workday(weekday, fixed_workdays_bitmap)` — berücksichtigt Teilzeit-Muster
- AI-3: `feiertagsgutschrift_min = tagessoll × credit_factor`, credit_factor als DB-Spalte

**Empfehlung:** AI-2 Formel + AI-3 `credit_factor` Spalte. Fixed-Workdays-Bitmap per MA (Mo-Fr vs. Mo-Di-Do-Fr) erforderlich.

### 4.5 Monats-Lock-Architektur

- AI-1: flat in `fact_time_entry.status = 'locked'`
- AI-2 + AI-3: separate `fact_time_period_close` / `fact_monthly_lock` Tabelle mit Approval-Chain + Export-Batch-Ref

**Empfehlung:** AI-2/AI-3 separate Tabelle. Ohne eigene Periodentabelle gibt es keine robuste Monatsabgabe, keine atomare Sperre und keinen belastbaren Export-Status.

### 4.6 Automatische Pausen-Validierung

- AI-1: einfach ">7h = 30min Pflicht"
- AI-2: Hard-Block ab 9h+<60min, Soft-Warning ab 5.5h+<15min
- AI-3: zweistufig Soft-Warning während Tag + Hard-Validation vor Monatsabgabe + Lage-Warnung (Pause in Mitte der Arbeitszeit)

**Empfehlung:** AI-3 zweistufig. Hard-Block direkt bei Submit statt bei täglicher Buchung (sonst genervte MA).

### 4.7 Rollen-Scope "Team-Zeit sehen" bei TL

- AI-1 + AI-2: TL sieht direct reports
- AI-3: TL sieht Team, aber Arztzeugnis standardmässig verborgen

**Empfehlung:** AI-3 Nuance. Arztzeugnis ist besondere Personendaten (Art. 5 lit. c Ziff. 2 revDSG) → encrypted storage + Zugriff nur bei fachlicher Notwendigkeit.

---

## 5. OPEN QUESTIONS für Peter (konsolidiert aus 3 AIs)

Konsolidierte Liste (15 Fragen, Merge aus AI-2 + AI-3, AI-1 ist Teilmenge):

### Organisatorisch

1. **Default-Arbeitszeit-Modell pro Rolle**
   - (a) Founder/Head-of = TRUST (Simplified Art. 73b), Senior/CM/AM = FLEX_CORE, Researcher/Assistenz = FIXED
   - (b) alle FLEX_CORE
   - (c) alle SIMPLIFIED mit Sozialpartner-Vereinbarung
   - **AI-2 empfiehlt (a)** · **AI-3 empfiehlt (c) mit Default FLEX_CORE pro neuer Person**

2. **Erfassungs-Granularität**
   - (a) Minute · (b) 15-min-Block · (c) Stunde
   - **AI-3 empfiehlt (a)** · **AI-2 empfiehlt (a) technisch + (b) UI-Anzeige**

3. **Kernzeit bei FLEX_CORE**
   - (a) 09:00–11:30 + 14:00–16:00 · (b) 10:00–15:00 durchgängig · (c) keine Kernzeit
   - **Keine Empfehlung**

4. **Pausen-Handling**
   - (a) automatisch abgezogen nach ArG-15 · (b) manuell Pflicht · (c) Default auto + Override
   - **AI-2 empfiehlt (c)**

### Lohnfortzahlung

5. **Bern-/Zürcher-/Basler-Skala**
   - (a) Bern (Briefing-Wunsch, grosszügigst) · (b) Zürich (lokal üblich ZH-Sitz) · (c) KTG-Versicherung mit 80% 720 Tagen
   - **AI-2 empfiehlt (a) als MA-freundliche Policy** · **AI-3 rät zu (b) als rechtlicher Default**
   - **Entscheidend: mit Treuhand Kunz absprechen**

6. **Arztzeugnis-Grenze**
   - (a) ab Tag 1 · (b) ab Tag 3 · (c) ab Tag 4
   - **AI-3 empfiehlt (b), aber im Vertrag verankern**

### Überzeit/Überstunden

7. **Überzeit-Cap-Policy**
   - (a) 45h/Woche strikt Hard-Block · (b) 50h mit TL-Signoff · (c) nur Jahres-Saldo 170h
   - **AI-2 empfiehlt (c) Wochen-Warning + Jahres-Hard-Block**

8. **Auszahlung Überstunden/Überzeit**
   - (a) immer Zeitausgleich · (b) TL bis Schwelle, GF darüber · (c) immer Auszahlung mit 25% Zuschlag
   - **AI-3 empfiehlt (b)**

### Ferien

9. **Ferien-Übertrag-Policy**
   - (a) max 5 Tage bis 31.3. Folgejahr · (b) unlimitiert bis 31.12. · (c) harter Verfall 31.3.
   - **AI-3 empfiehlt (a), aber als Eskalationsregel, nicht stiller Verfall** · **AI-2 empfiehlt (a)**

### Feiertage

10. **Lokale Feiertage in Zürich**
    - (a) nur gesetzliche 9 Tage · (b) + Berchtoldstag · (c) + Berchtoldstag + lokale Halbtage (Heiligabend/Silvester ab 12h)
    - **AI-3 empfiehlt (c) wenn gelebte Firmenpraxis** · **AI-2 dokumentiert (b) als Default**

11. **Bridge-Tage (Auffahrt-Freitag, Heiligabend-Nachmittag)**
    - (a) automatisch Halbtag · (b) manuelle Entscheidung pro Jahr durch GF · (c) voller Arbeitstag mit Kompensations-Option

### Correction + Approval

12. **Approval-Zyklus**
    - (a) wöchentlich · (b) monatlich · (c) hybrid Wochen-Check + Monatslock
    - **AI-3 empfiehlt (c)**

13. **Korrekturen nach Lock**
    - (a) nur GF · (b) GF + Backoffice · (c) TL mit Vier-Augen-Prinzip
    - **AI-3 empfiehlt (b)**

### Tech/Mobile

14. **Mobile-Strategie**
    - (a) Desktop only Phase 1 · (b) Responsive-Web · (c) PWA Phase 3.5 ohne GPS
    - **AI-3 empfiehlt (c) PWA ohne Standort-Tracking**

15. **Projektpflicht**
    - (a) jede produktive Minute braucht Projekt · (b) nur billable Kategorien · (c) Team frei wählen
    - **AI-3 empfiehlt (a), ausser klar definierte interne Kategorien**

---

## 6. KONSOLIDIERUNGS-PLAN · Nächste Schritte

### Phase A · User-Q&A (analog HR-Plan v0.2)

Peter beantwortet 15 Open Questions in 2-3 Sessions (je 5-6 Fragen). Default: AI-Empfehlung annehmen, wenn Peter keine andere Meinung hat.

### Phase B · Specs v0.1 (nach Q&A)

**B.1 — `specs/ARK_ZEIT_SCHEMA_v0_1.md`** (DDL-Spec)
- Basis: AI-2 Schema (UUID + ENUM + GIST)
- Ergänzungen aus AI-3: `fact_time_period_close`, `salary_continuation_scale`, `credit_factor` auf `fact_holiday_cantonal`, 3-Konten-Saldo-Views
- Alle Tabellen: `audit_trail_jsonb` + `retention_until` + 5-Jahre-Retention-Job

**B.2 — `specs/ARK_ZEIT_INTERACTIONS_v0_1.md`** (UI + Flow-Spec)
- 7 Screens + 5 Drawer + 1 Modal (AI-2 Layout)
- State-Machines Time-Entry + Absence (AI-2/AI-3 konsolidiert)
- Rollen-Matrix (AI-2 + AI-3 Merge mit Arztzeugnis-DSG-Nuance)
- Validation-Regeln (AI-3 zweistufig Soft/Hard)

### Phase C · Grundlagen-Sync

**C.1 — `ARK_STAMMDATEN_EXPORT_v1_4.md`**
- Add: `dim_absence_type` (21 Codes)
- Add: `dim_time_category` (12 Codes)
- Add: `dim_work_time_model` (5 Codes incl. SIMPLIFIED/EXEMPT_EXEC)
- Add: ZH-Feiertage 2026 (9 gesetzlich, 3 optional lokal)
- Update: Bern-Skala-Tabelle korrekt (vs ZH-Skala)

**C.2 — `ARK_DATABASE_SCHEMA_v1_4.md`**
- Add: 8 neue Tabellen (fact_time_entry / fact_absence / dim_absence_type / dim_time_category / dim_work_time_model / fact_workday_target / fact_holiday_cantonal / fact_time_correction / fact_time_period_close / fact_vacation_balance / fact_overtime_balance / fact_monthly_lock)
- Document: ENUM-Types + GIST Overlap-Constraints

**C.3 — `ARK_BACKEND_ARCHITECTURE_v2_6.md`**
- Add: Event `time_entry.approved.v1` (Commission-Trigger)
- Add: Event `time_entry.locked.v1` + `absence.approved.v1`
- Add: Worker `treuhand-export` (monatlich, ELM 5.0 + Bexio-CSV)
- Add: Worker `vacation-expiry-reminder` (60d vor Verfall)
- Add: Worker `doctor-cert-escalation` (ab Tag 3 Krank)

**C.4 — `ARK_FRONTEND_FREEZE_v1_11.md`**
- Add: Zeit-Modul UI-Pattern (7 Screens, 5 Drawer)
- Add: Timer-Widget-Komponente (global sichtbar)

### Phase D · Mockups

**D.1 — `mockups/ERP Tools/zeit-list.html`** → update mit 9-Stage-Pipeline-Projekt-Dropdown
**D.2 — `zeit-dashboard.html`** → update Hero-KPIs + Timer-Widget
**D.3 — `zeit-meine-zeit.html`** → neu (Wochen-View)
**D.4 — `zeit-monat.html`** → neu (Monats-Übersicht + Submit-Flow)
**D.5 — `zeit-abwesenheiten.html`** → neu (Monats-Grid + MA-Zeilen)
**D.6 — `zeit-saldi.html`** → neu (3 Karten: Ferien/OR-Überstunden/ArG-Überzeit)
**D.7 — `zeit-admin.html`** → neu (4 Sub-Module: Arbeitszeit-Modelle / Feiertage-Editor / MA-Verträge / Sozialpartner-Vereinbarung)

### Phase E · Legal Assets

**E.1 — Art. 73b Sozialpartner-Vereinbarung Template**
- PDF-Template im Admin-Modul
- Signatur via DocuSign QES (ZertES) oder handschriftlich + Scan
- Unterschriften-Tracking in `fact_workday_target.simplified_agreement_signed_at`

**E.2 — MA-Vertrag-Anhang "Arbeitszeit-Modell"**
- Pro MA: Zuordnung Modell + Bern/Zürich-Skala-Wahl
- Im Onboarding-Flow verlinken

---

## 7. QUICK-WIN-EMPFEHLUNGEN (unkontrovers)

Direkt in Specs übernehmen ohne weitere Diskussion:

1. **UUID + ENUM + GIST** (AI-2/AI-3 Konsens)
2. **9 gesetzliche ZH-Feiertage + 3 optional-lokale Halbtage** (alle 3 AIs stimmen)
3. **3-Konten-Saldo** (Soll / OR-Mehrarbeit / ArG-Überzeit) — juristisch zwingend getrennt
4. **540px-Drawer + 420px-Modal + Editorial-Style** (alle 3 AIs + CRM-Baseline)
5. **Timer global sichtbar** (AI-3)
6. **Arztzeugnis ab Tag 3 Default, konfigurierbar** (alle 3)
7. **Audit-Trail append-only JSONB + 5-Jahre-Retention** (alle 3 + Gesetz)
8. **Art. 73b = einziger Compliance-Weg** (alle 3 + kein GAV)
9. **BGE 4A_227/2017 als Leitentscheid** (nicht 4A_295/2016)
10. **ELM 5.0 statt 4.0** (AI-2 korrekt)
11. **`fact_time_period_close` als separate Tabelle** (AI-2/AI-3 Konsens)
12. **Fixed-Workdays-Bitmap per MA** (AI-2) für Feiertags-Teilzeit

---

## 8. STATUS + NEXT

**Aktuell:**
- [x] 3 AI-Antworten empfangen + abgelegt
- [x] Cross-Check durchgeführt (Divergenzen + Corrections dokumentiert)
- [x] Overview + Consolidation-Plan geschrieben
- [ ] Peter-Q&A 15 Open Questions
- [ ] Schema v0.1 + Interactions v0.1 generieren
- [ ] Grundlagen-Sync (4 Dateien)
- [ ] Mockups (7 Screens)

**Next-Action-Vorschlag:** Phase A starten (Peter-Q&A, 15 Fragen aufgeteilt auf 2-3 Sessions).
