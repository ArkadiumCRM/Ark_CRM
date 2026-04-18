---
title: "Mandat"
type: entity
created: 2026-04-08
updated: 2026-04-12
sources: ["ARK_GESAMTSYSTEM_UEBERSICHT_v1_2.md", "ARK_DATABASE_SCHEMA_v1_2.md", "ARK_Factsheet Personalgewinnung.pdf", "General/4_Account Management/Mandatsofferte/"]
tags: [entity, mandat, core, target, taskforce, time, rpo, kuendigung]
---

# Mandat

Formeller Auftrag eines Kunden ([[account]]) an ARK. Nicht alle Rekrutierungen laufen über ein Mandat — die Alternative ist [[erfolgsbasis]] (Target Best Effort).

## Mandatsarten

| Typ | Factsheet-Name | Beschreibung | Preislogik |
|-----|---------------|-------------|-----------|
| **Target** | Target Exklusivmandat | Exklusive, verdeckte Suche für eine Schlüsselposition | Fixpauschale ÷ 3 Stage-Zahlungen |
| **Taskforce** | Taskforce (ehemals "RPO") | Aufbau Standort/Abteilung/Team, mind. 3 Positionen parallel | Monatsfee + Success Fee pro Position (individuell) |
| **Time** | Time | Feste Rekrutierungskapazitäten in Slots | Wochenfee pro Slot (degressiv), monatlich abgerechnet |

> [!note] Taskforce = umbenanntes RPO (2026-04-12)
> **Taskforce** ist der neue Name für das, was früher "RPO" (Recruitment Process Outsourcing) hiess — **gleiches Produkt, neuer Name**. Die alte `Vorlage_RPO-Offerte.docx` ([[rpo-offerte]]) beschreibt inhaltlich dasselbe wie die heutige Taskforce-Offerte, nur unter altem Titel.

## Konditionen nach Typ

### Target (Exklusivmandat)

- **Honorar:** Fixpauschale als CHF-Betrag vereinbart (35-40% vom Jahresgehalt als Richtwert)
- **Zahlungsmodell:** Pauschale ÷ 3 = 3 gleiche Stage-Zahlungen
  1. Zahlung bei Vertragsabschluss (Mandatsofferte unterschrieben)
  2. Zahlung bei Shortlist-Trigger (konfigurierbare CV-Anzahl, z.B. 2-3 CVs)
  3. Zahlung bei Placement
- **Garantiezeit:** 3 Monate (Standard), dazukaufbar bis 6 Monate
- **Garantieleistung:** Ersatzbesetzung geschuldet (NICHT Rückvergütung)
- **No-Hunt-Status** auf den Account
- **Time-to-fill:** In der Regel 12-18 Wochen
- **Zahlungsziel:** 10 Tage (Default)

### Taskforce (Team-/Standortaufbau)

- **Monatsfee:** Fix-Betrag pro Monat für die Recherche-Kapazität
- **Success Fee pro Position:** Individuell je Position (z.B. Abteilungsleiter > Projektleiter)
- **Mind. 3 Positionen** (sonst Target Exklusivmandat)
- **Garantiezeit:** 3 Monate (Standard), dazukaufbar bis 6 Monate
- **Garantieleistung:** Ersatzbesetzung geschuldet
- **Zahlungsziel:** 10 Tage (Default)

### Time (Slot-basiert)

- **Wochenfee pro Slot** (degressiv nach Anzahl Slots):

| Paket | Slots | Preis/Slot/Woche | Listenpreis |
|-------|-------|-----------------|-------------|
| Entry | 2 | CHF 1'950.- | ~~CHF 2'250.-~~ |
| Medium | 3 | CHF 1'650.- | ~~CHF 1'950.-~~ |
| Professional | 4 | CHF 1'250.- | ~~CHF 1'650.-~~ |

- **Mindestens 2 Slots** erforderlich
- **Dauer:** In Wochen definiert, monatlich abgerechnet
- **Kündigungsfrist:** 3 Wochen schriftlich
- **Keine Mindestlaufzeit**
- **Kein Stundensatz** — reine Wochenfee
- **Jeder Slot = 1 Position**, flexibel austauschbar ohne Mindestlaufzeit
- **Zahlungsziel:** 10 Tage (Default)
- **Keine Garantie/Ersatzbesetzung** (Arkadium liefert Kandidaten, Kunde führt Prozess selbst)

## Zusatzleistungen / Optionale Stages

Die Mandatsofferte enthält **5 Optionen VI–X**: siehe [[optionale-stages]].
- VI Mehr Idents · VII Mehr Dossiers · VIII Marketing · IX Assessment · X Garantie-Extension
- Aktivierung via separaten Kurz-Vertrag ([[auftrag-optionale-stage]])
- Eigener Rechnungstyp ([[rechnungen-mandat]])
- **Gap:** Nur VIII als Template vorhanden, `fact_mandate_option` fehlt

## Datenbank

- `fact_mandate` — Haupttabelle mit Typ, Status, Targets, Garantie
- `fact_mandate_billing` — Zahlungsplan (Retainer/Success/Milestone)
- `fact_mandate_research` — Longlist/Research-Pipeline pro Mandat

**DB mandate_type:** `'Target'` | `'Taskforce'` | `'Time'`

## Status-Flow

```
Entwurf → Aktiv → Abgeschlossen
                 → Abgebrochen   ← siehe [[mandat-kuendigung]]
         → Abgelehnt (terminal)
```

**Aktivierung:** Automatisch wenn Dokument "Mandatsofferte unterschrieben" hochgeladen wird.

**Kündigung (Exit Option, Klausel II der Offerte):**
- Arkadium kündigt (keine Kandidaten findbar) → 80% Gesamtmandatssumme fällig, keine Rückvergütung
- Auftraggeber kündigt / besetzt anderweitig → laufende Stage **oder** min. 80% Gesamtmandatssumme
- Detail-Konzept: [[mandat-kuendigung]] · Rechnungs-Template: [[rechnungen-mandat]]
- Spezialfall Direkteinstellung: [[direkteinstellung-schutzfrist]]

**KPI:** Offerten-Conversion-Rate = Entwurf→Aktiv vs. Entwurf→Abgelehnt

## Shortlist-Trigger (nur Target)

Im Mandat wird eine Anzahl "CV Sent" definiert (z.B. 2 oder 3) die die 2. Zahlung auslöst:
1. Anzahl erreicht → `fact_mandate_billing` erstellt 2. Zahlungs-Eintrag
2. Notification an AM: "Shortlist erreicht — 2. Zahlung fällig"
3. Bei Überschreitung: "Zusatzleistung fällig?" — AM entscheidet

## Longlist / Research

Siehe [[longlist-research]].

Research-Flow: Research → Nicht erreicht → CV Expected → CV IN → Briefing → GO mündlich → GO schriftlich

Ab "CV IN" sind Stages gesperrt (nur Automationen).

## Frontend — 7 Tabs

1. **Übersicht** — Typ-Badge, Status-Flow, KPIs, Shortlist-Trigger, Zusatzleistungen
2. **Longlist** — Kanban (10 Spalten) oder Liste, Drag & Drop, "Durchcall-Funktion"
3. **Prozesse** — Alle Mandate-Prozesse, Interview-Dates
4. **Billing** — Zahlungstracking pro Mandatstyp
5. **History** — History-Einträge der Longlist-Kandidaten
6. **Dokumente** — Reports, Verträge
7. **Reminders** — Stage-Deadlines, Kündigungs-Checks

## Header-Spezialitäten (Mockup)

- **Owner AM + Lead Research** in banner-meta
- **Kickoff-Datum + Zielplatzierung** in banner-meta
- **Typ-Chip** (🎯 Target / 🔄 Taskforce / ⏱ Time)
- **Status-Dropdown** (Aktiv/On-Hold/Gekündigt/Abgeschlossen)
- **Stage-Chip** (z.B. Stage 2/3)
- **Exklusiv-Chip** (läuft mit Mandat)
- **Garantie-Chip** (3 Mt ab Arbeitsantritt)
- **Briefing-Version** als Meta-Zeile
- **Snapshot-Bar sticky** (6 Slots, operativ mit Progress-Bars · dupe-frei zum Header): Idents · Calls · Shortlist · Pauschale · Time-to-Fill · Placements

## Related

- [[account]] — Mandat gehört zu einem Account
- [[job]] — Jede Position = ein Job (Taskforce: mehrere Jobs)
- [[longlist-research]] — Kandidaten-Research im Mandat
- [[prozess]] — Prozesse können mit oder ohne Mandat existieren
- [[erfolgsbasis]] — Target Best Effort (ohne formelles Mandat)
- [[honorar-berechnung]] — Fee-Berechnung und Provisionen
- [[factsheet-personalgewinnung]] — Offizielles Factsheet mit Preisen
- [[mandatsofferte-vorlage]] — Original-Vorlage (Exklusivmandat)
- [[rpo-offerte]] — Alte RPO-Offerten-Vorlage (inhaltlich = heutige Taskforce)
- [[mandat-kuendigung]] — Exit Option + 80%-Regel
- [[direkteinstellung-schutzfrist]] — 12/16-Monats-Schutzfrist
- [[optionale-stages]] — VI–X Zusatzleistungen
- [[mandat-lifecycle-gaps]] — Was im CRM noch fehlt
