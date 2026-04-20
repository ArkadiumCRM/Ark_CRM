---
title: "Zeit-Modul · Decisions Log (Phase A Q&A)"
type: meta
created: 2026-04-19
updated: 2026-04-19
sources: ["wiki/sources/hr-reglemente.md", "wiki/sources/phase3-research/zeit/zeit-research-overview.md"]
tags: [zeit, phase3, decisions, qa, arbeitszeit]
---

# Zeit-Modul · Decisions Log (Phase A Q&A)

Konsolidierte Antworten auf 15 Open Questions aus [zeit-research-overview.md](../sources/phase3-research/zeit/zeit-research-overview.md). Session 2026-04-19 mit Peter.

## Aus Reglement direkt übernommen (keine Q&A-Interaktion nötig)

Quelle: [hr-reglemente.md](../sources/hr-reglemente.md) (Tempus Passio 365 · Generalis Provisio · Locus Extra)

| F# | Thema | Wert |
|----|-------|------|
| F1 | Default-Arbeitszeit-Modell | **FLEX_CORE** (Peter-Bestätigung B) |
| F3 | Kernzeit | **Mo–Fr 08:45–12:00 · Mo–Do 13:30–17:45 · Fr 13:30–16:00** · +2.5h Fr 15:30–18:00 Team-Dev (aggregierbar) |
| F5 | Lohnfortzahlung-Skala | **Zürcher Skala** (Generalis Provisio §6.2.1 · nach 3 Mt DZ) |
| F6 | Arztzeugnis-Grenze | **Dienstjahr-gestaffelt** · 1.DJ→Tag 1 · 2.DJ→Tag 2 · 3+DJ→Tag 3 · AG kann jederzeit ab Tag 1 verlangen |
| F8 | Überzeit-Auszahlung | **Custom · Arkadium-Policy:** Mehrarbeit (OR + ArG) mit Grundlohn abgegolten · **KEINE Kompensation, KEINE Auszahlung** · Schema + UI nur als Tracking für Compliance (ArG Art. 12 Jahres-Cap 170h) |
| F9 | Ferien-Übertrag | **Bis 14 Tage nach Ostern** · jüngste Ansprüche zuerst |
| F10 | Lokale Feiertage | **9 bezahlte ZH-FT inkl. Berchtoldstag** · Sechseläuten/Knabenschiessen nur Sperrfrist für Extra-Guthaben |
| F15 | Projektpflicht | **Täglich im System** · nicht projektpflichtig erzwungen |

## Peter-Entscheidungen (Q&A)

| F# | Frage | Antwort | Notes |
|----|-------|---------|-------|
| F1 | Default-Arbeitszeit-Modell | **B** Alle FLEX_CORE | passt zu Reglement Kernzeit |
| F2 | Erfassungs-Granularität | **A** Minute | technisch präzise, konsistent mit Scanner |
| F4 | Pausen-Handling | **B** Manuell Pflicht (Fingerabdruckscanner) | Scanner scan-out/in pro Pause |
| F7 | Überzeit-Cap-Validation | **Custom: Daily-Cap 10h** | alles über 10h/Tag wird nicht weitergezählt |
| F11 | Bridge-Tage | **B** Manuelle Entscheidung pro Jahr durch Admin | Admin-UI: Brückentag-Editor |
| F13 | Korrekturen nach Lock | **Custom: nur Admin-Rolle** | (keine separate GF/Founder-Rolle in Arkadium — GF = Admin) |
| F14 | Mobile-Strategie | **B** Responsive Web | kein PWA, kein Native — Scanner deckt Kern-Attendance |
| F12 | Approval-Zyklus | **C** Hybrid | wöchentlicher Head-Check (Anomalien) + monatlicher Final-Lock |

## Status

✅ **Alle 15 Open Questions beantwortet.** Ready for Phase B (Specs v0.1).

## 🟠 Risks & Flags

### Risk-F1 · Scanner-Biometrie (DSG-Sensitivität)

**Kontext:** F4 = Fingerabdruckscanner für Zeiterfassung + Pausen.

**Risiko:** Biometrische Daten (Fingerabdruck-Template) = besondere Personendaten nach Art. 5 lit. c Ziff. 4 revDSG. Ohne proportionale Rechtfertigung + MA-Zustimmung rechtlich problematisch.

**Mitigation:**
- Zweckbindung dokumentiert (nur Zeiterfassung, keine Anwesenheitskontrolle)
- DSFA (Datenschutz-Folgenabschätzung) vor Go-Live
- Template nicht extrahierbar speichern (nur irreversible Hash)
- MA-Einwilligung schriftlich im Onboarding (Reglement-Anhang)
- Opt-out-Alternative (Badge/PIN) für MA mit Bedenken anbieten
- Audit-Log: wer/wann Scanner-Daten einsieht

**Status:** Offen · vor Phase-B-Spec zu adressieren

### Risk-F2 · Daily-Cap 10h = Firmen-Policy, nicht gesetzlich

**Kontext:** F7 = MA-Stunden über 10h/Tag werden nicht weitergezählt.

**Risiko:** Art. 9 ArG sagt 45h/Woche Höchstarbeitszeit, Tagesgrenze ist nicht starr bei 10h. Bei Gerichtsstreit kann MA die "gekappten" Stunden rückwirkend als Überzeit einklagen (BGE Art. 42 Abs. 2 OR Schätzung). Cut = weggeworfen ≠ Cut = bezahlte Überzeit.

**Mitigation:**
- 10h-Cap **explizit im Vertrag/Reglement** als Vereinbarung dokumentieren (sonst anfechtbar)
- Scanner-Roh-Zeiten (`raw_duration_min`) getrennt von gezählter Zeit (`counted_duration_min`) speichern → Audit-Trail
- Wenn MA konsistent >10h scannt → Alert an Head of + Admin (Policy-Review oder Arbeitszeit-Modell-Anpassung)
- In Saldo-UI dem MA sichtbar: "Heute 12h gescannt, 2h nicht angerechnet laut Firmenpolicy"
- Regel dokumentieren: nur angeordnete schriftliche Mehrarbeit wird bezahlt/kompensiert → unbezahlt-gescannter Overhead = nicht Arkadiums Haftung

**Status:** Offen · Policy in Vertragsanhang verankern vor Go-Live
