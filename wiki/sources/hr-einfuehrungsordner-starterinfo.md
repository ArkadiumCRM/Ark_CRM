---
title: "HR · Einführungsordner (Starterinfos + Arkadium am Markt + Glossary)"
type: source
created: 2026-04-19
updated: 2026-04-19
sources: [
  "raw/HR/2_HR On- Offboarding/10_Schulungsunterlagen/Einführungsordner/A Starterinfos und Hausordnung ZH Tödistrasse.docx",
  "raw/HR/2_HR On- Offboarding/10_Schulungsunterlagen/Einführungsordner/A Starterinfos und Hausordnung ZH Maneggstrasse.pdf",
  "raw/HR/2_HR On- Offboarding/10_Schulungsunterlagen/Einführungsordner/Arkadium am Markt.docx",
  "raw/HR/2_HR On- Offboarding/10_Schulungsunterlagen/Einführungsordner/Glossary.docx"
]
tags: [hr, phase-3, einfuehrungsordner, starterinfo, hausordnung, dresscode, reporting, onboarding-content]
---

# HR · Einführungsordner — Starterinfos + Hausordnung + Markt + Glossary

Operative Onboarding-Dokumente für neue MA · Pflichtlektüre in Woche 1 · Inhalte speisen Onboarding-Template-Tasks.

## Starterinfos + Hausordnung (ZH Tödistrasse + Maneggstrasse)

### Sektionen (30 Themen)

| § | Thema | Key-Regel |
|---|-------|-----------|
| Kultureller Umgang | Tägliches Lernen · "keine dummen Fragen" | — |
| Urlaubsantrag | 2 aufeinanderfolgende Wochen/Jahr · Team-Abstimmung · Weihnachten-Anfang-Jan-Zeit gut für Reisen · **kein Urlaub in Probezeit oder > 2 Wochen im 1. DJ** | ergänzt Tempus Passio §6 |
| Arbeitszeiten | Arbeitsbeginn **spätestens 08:45 Uhr** · **17:00 Feiertags-Vorabend** · Mittag 12:00–14:00 (1 h) | ergänzt Tempus Passio §3.1 |
| Krankheit | **Rechtzeitig telefonisch** · "Anruf um 08:45 dass man krank ist — nicht gern gesehen" · **ab 3. Tag Arztzeugnis** | Generalis Provisio §3.5.2 (Variante für 3. DJ) |
| Firmenhandy | Schweizer-Netz private Nutzung OK · Ausland auf MA-Kosten · **eingeschaltet tragen auch nach Feierabend** (Kandidaten erreichen uns oft abends) | neu |
| Empfang Kandidaten | Ins Sitzungszimmer/Lounge · Kaffee/Wasser anbieten · Dresscode stimmen · Kollegen informieren vor Getränken-Servieren | neu |
| Meetingpoint-Nutzung | Sitzungszimmer für Kandidaten/Kunden · Aussprache-Meetings · **Kandidatengespräche bewusst im Grossraum** (damit Vorgesetzte mithören für Training) | Academy-Relevanz |
| Reportingwoche | **Di morgens → Mo abends** (weil Kandidaten-Feedback oft über Wochenende kommt) | neu |
| KPI-Reporting | Rolle-abhängig · Head kommuniziert | verknüpft mit `dim_mitarbeiter.target_*` |
| Teammeeting | Wöchentlich | neu |
| CRM-Datenpflege | Pflicht · jeder Kontakt = Kandidat (matcht Memory `project_arkadium_role.md` + Memory `feedback_ui_performance.md`) | — |
| Systemsupport "Lenny" | Name des IT-Helpdesk-Systems | — |
| Softphone (3CX) | Telefon-System-Integration | Memory `project_unified_communication.md` |
| Dresscode | Business-Casual intern · **Suit up bei Kundenterminen** · Polo-Shirts nur Freitag · no Sneakers · Kurzarmhemden "etwas für Busfahrer" | Generalis Provisio §7 |
| Diskretion am Telefon | — | — |
| PC Nutzung + Datenschutz | Reisswolf-Box für vertrauliche Daten | DSG-Compliance |
| Drucker | — | — |
| Raucherpausen | Separat von Pausen geführt (wie Private-Messaging am Arbeitsplatz) | Tempus Passio §3.2 |

**Zwei Standorte Dokumentiert:**
- Maneggstrasse 45 · 8041 Zürich (aktueller HQ)
- Tödistrasse · Zürich (älterer Standort · Dokument noch im Einführungsordner)

## Arkadium am Markt

**Inhalt:** Firmen-Story · Positionierung im Headhunting-Markt · USP-Narrative (High-End Executive Search · Bau/Immobilien-Spezialisierung). Text-Baustein für Arbeitszeugnis-Templates (in §Firmenbeschreibung).

## Glossary

**Inhalt:** Arkadium-Vokabular-Liste · Fachbegriffe + interne Bezeichnungen (Method-4-Modell, Ident/Hunt/Briefing/Placement, ZEG, KPIs, Praemium Victoria, Progressus, Generalis Provisio, Tempus Passio 365, Locus Extra).

Dient als Onboarding-Glossar + Referenz für Academy-Module. Enthält Definitionen, die bei Neueintritt helfen.

## Key Takeaways für HR-Tool

### Onboarding-Template-Tasks (Konkretisierung Plan §5.5 + §14.5)

```json
{
  "consultant_14_wochen": {
    "pre_arrival": [
      "Arbeitsvertrag + 5 Anhänge signiert erhalten",
      "Personalstammdaten-Formular an Treuhand Kunz senden",
      "IT-Zugang beantragen (Lenny-Ticket)"
    ],
    "day_1": [
      "Starterinfo + Hausordnung lesen + Quiz bestanden",
      "Arkadium am Markt lesen",
      "Glossary lesen",
      "Einführung CRM-System",
      "Einführung Softphone (3CX) + Telefonliste erhalten",
      "Schlüsselquittung signiert",
      "Dresscode-Briefing"
    ],
    "woche_1": [
      "Communication Edge Part I starten",
      "M4 Modell Überblick",
      "Kollegiales Mittagessen mit Team",
      "Erstes Koordinationsgespräch mit Vorgesetztem"
    ],
    "woche_2_4": [
      "Communication Edge Part I abgeschlossen",
      "M 1.1 Ident + M 1.2 Hunt trainieren (pair-work mit Buddy)",
      "Erstes eigenes Hunt-Telefonat (beobachtet)",
      "Wöchentliches Koordinationsgespräch"
    ],
    "monat_2": [
      "Communication Edge Part II + Anhang",
      "M 1.3 CV Chase + M 1.4 Briefing",
      "M 2 Serie (Doc Chase, PreLeading, Presentation, GO's Fishing)",
      "Erstes eigenes Briefing-Gespräch"
    ],
    "monat_3": [
      "M 3 Serie (Docs Generating, Abstract, Akquise, CV sent)",
      "M 4 Serie (TIVT Orga, 2nd Orga, Offer, Placement)",
      "Erste eigene Kundenvorstellung",
      "Scheelen MDI-Zertifizierung beginnen",
      "Probezeit-Feedback-Gespräch"
    ]
  }
}
```

### Hausordnung-relevante Config-Keys (Ergänzung zu Schema §13)

```sql
-- Zusätzliche Config-Keys (v0.2):
INSERT INTO dim_automation_settings (key, value, description, data_type) VALUES
  ('arbeitsbeginn_spaetestens_uhrzeit', '08:45', 'Arbeitsbeginn-Richtzeit aus Hausordnung', 'string'),
  ('feiertags_vorabend_arbeitsschluss_uhrzeit', '17:00', 'Arbeitsschluss vor Feiertagen', 'string'),
  ('mittagspause_von_bis', '12:00-14:00', 'Mittagspausen-Fenster', 'string'),
  ('mittagspause_dauer_minuten', '60', 'Mittagspausen-Dauer in Minuten', 'integer'),
  ('reportingwoche_start_dow', '2', 'Start Reportingwoche (Tag-of-Week, 2=Di)', 'integer'),
  ('reportingwoche_end_dow', '1', 'Ende Reportingwoche (Tag-of-Week, 1=Mo)', 'integer'),
  ('dresscode_client_default', 'suit_up', 'Dresscode bei Kundenterminen', 'string'),
  ('dresscode_office_default', 'business_casual', 'Dresscode im Office', 'string')
ON CONFLICT (key) DO NOTHING;
```

### Dokument-Typ-Erweiterung

```sql
-- Neue Document-Types in fact_hr_documents (ergänzt Schema §11.1):
-- 'hausordnung_akzeptiert_signatur' — MA-Signatur nach Lektüre
-- 'schluesselquittung' — Schlüssel-Übergabe-Beleg
-- 'glossary_acknowledged' — Glossary gelesen-Bestätigung (evtl. mit Quiz-Score)
```

## Related

- [[hr-academy]] · [[hr-academy-communication-edge]] · [[hr-academy-m4-modell]] · [[hr-mitarbeiterordner-tools]]
- Memory `reference_treuhand_kunz.md`
- [[hr-reglemente]] (Generalis Provisio §4 Academy-Verweis)
