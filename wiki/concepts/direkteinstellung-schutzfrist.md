---
title: "Direkteinstellung & 12/16-Monats-Schutzfrist"
type: concept
created: 2026-04-12
updated: 2026-04-16
sources: ["Arkadium_AGB_FEB_2023.pdf", "General/4_Account Management/Mandatsofferte/Vorlage_Mandatsofferte.docx"]
tags: [concept, schutzfrist, direkteinstellung, agb, honorar, crm-gap]
---

# Direkteinstellung & Schutzfrist

Behandelt den Fall: **Kunde stellt einen von Arkadium identifizierten Kandidaten selbst ein** — mit oder ohne Mandat, während oder nach der Zusammenarbeit.

## Rechtsbasis (AGB + Mandatsofferte)

### AGB — 12-Monats-Schutzfrist
Aus [[agb-arkadium]]:
- Honoraranspruch besteht **auch bei späterer Kontaktaufnahme innerhalb 12 Monaten** nach Beendigung des Vermittlungsversuchs
- Fristbeginn: Datum Absage oder letzter Kontakt
- **Informationspflicht:** Kunde muss Arkadium **vor** erneuter Kontaktaufnahme mit Kandidat informieren
- **Automatische Verlängerung auf 16 Monate:** wenn Kunde relevante Info nicht innerhalb 10 Tagen nach Aufforderung übermittelt
- **Weitere Verlängerung:** wenn Kandidaten-Info länger als 12 Monate beim Kunden gespeichert bleibt

### Mandatsofferte — Exklusivität (Klausel I)
3 Wochen ab Versand exklusiv. Während Mandatslaufzeit gilt Exklusivität für Kompetenzbereich. Bewerbungen von anderen Dienstleistern müssen abgelehnt / an Arkadium rerouted werden.

## Die drei Szenarien

### 1. Direkteinstellung während aktivem Mandat
Fällt unter [[mandat-kuendigung]] Fall B: Auftraggeber besetzt anderweitig → 80% der Gesamtmandatssumme fällig.

### 2. Direkteinstellung nach Mandats-/Prozess-Ende (innerhalb Schutzfrist)
Volle Honorarforderung nach:
- Mandat-Konditionen (falls ursprünglich Mandat): Schlusszahlung (Stage 3) wird fällig
- Erfolgsbasis-Staffel (falls Best Effort): 21/23/25/27% je Gehalt

### 3. Direkteinstellung ohne vorherigen Vorstellungs-Versuch
Kein Honoraranspruch (Kandidat wurde nie "vorgestellt").

## Scope der Schutzfrist (geklärt 2026-04-12)

**Variante A — Pro vorgestellter Kandidat:** Die Schutzfrist gilt **nur für Kandidaten, die Arkadium dem Kunden konkret vorgestellt hat**.

**Was zählt als "vorgestellt" (geklärt 2026-04-13):**
- **Mündlich** am Telefon oder im Teams-Meeting (Dossier/Kandidat präsentiert)
- **Per E-Mail** (Dossier als Anhang versendet)

Nicht vom Schutz erfasst:
- Longlist-Idents, die wir nur recherchiert aber nie vorgestellt haben
- Kandidaten im Kompetenzbereich, die wir nie kontaktiert haben
- Allgemeines Briefing ohne Namensnennung

Juristisch saubere Auslegung — deckt sich mit AGB-Formulierung *"Beendigung des Vermittlungsversuchs"*.

## Detection — wann wird die Schutzfrist ausgelöst?

**Aktuell im CRM:** Keine automatische Detection. Alles manuell via AM-Beobachtung.

**Soll im CRM:**
- `fact_candidate_presentation` — **jede konkrete Vorstellung** (CV-Versand / Dossier / Pitch) loggt Kandidat + Account + Timestamp + Trigger-Typ
- Nur diese Einträge erzeugen Schutzfrist-Fenster — Longlist-Research allein reicht **nicht**
- Schutzfrist-Berechnung: `protection_until = last_presentation + 12 months`
- Auto-Extension auf 16 Monate wenn `info_request_sent_at + 10 days < info_received_at` oder `null`
- **Event:** LinkedIn-Scraper detektiert neuen Job bei Kandidat → Match gegen `fact_candidate_presentation`-Tabelle (nicht gegen ganze Longlist)
- **Alert:** "Kandidat X ist bei Kunde Y angestellt — innerhalb Schutzfrist von Vorstellung am Z → Honoraranspruch prüfen"

## Datenmodell (Soll)

```sql
fact_candidate_presentation (
  id,
  kandidat_id,
  account_id,
  presentation_type: 'email_dossier' | 'verbal_meeting' | 'upload_portal',  -- dim_presentation_types §10c
  mandat_id,               -- optional
  prozess_id,              -- optional
  presented_at,
  presented_by              -- user_id
)

fact_protection_window (
  id,
  presentation_id,           -- FK zu fact_candidate_presentation (Scope A!)
  kandidat_id,
  account_id,
  starts_at,                 -- Datum Absage / letzter Kontakt / Vorstellungs-Ende
  base_duration_months: 12,
  extended: boolean,         -- wurde auf 16 verlängert?
  expires_at,                -- berechnet
  info_requested_at,
  info_received_at,
  status: 'active' | 'expired' | 'honored' | 'claim_pending' | 'paid'
)
```

**Wichtig:** Jede Schutzfrist hat einen FK zu genau einer Präsentation. Keine Schutzfrist ohne dokumentierte Vorstellung.

## Auto-Aktionen (Soll)

1. **Prozess endet (Absage/Abbruch)** → Schutzfrist-Eintrag erstellt, `expires_at = now + 12 months`
2. **Scraper erkennt Job-Wechsel** → Match-Check gegen `fact_protection_window WHERE account_id = new_employer AND status = 'active'`
3. **Match gefunden** → Case in Tab "Claims" / Alert an AM + Admin
4. **Info-Request versandt** → `info_requested_at` gesetzt; nach 10 Tagen ohne Response: `extended = true`, `expires_at += 4 months`
5. **Honorar-Forderung** → Rechnung nach Mandats- oder Erfolgsbasis-Konditionen

## Claim-Workflow (Kandidat wurde hintenrum eingestellt)

Sonderfall: Detection erfolgt erst **nachdem** der Kandidat bereits beim Kunden angefangen hat zu arbeiten (z.B. 3 Mt später per Scraper erkannt). Relevante Aspekte:

### Rechtsanspruch-Basis
- AGB-Klausel bindet an den **Vertragsabschluss-Zeitpunkt** (bzw. Einstellung), nicht an die Arbeits-Dauer. Solange Einstellung innerhalb Schutzfrist erfolgte, entsteht der Anspruch — auch wenn der Kandidat schon lange arbeitet, bevor wir es merken.
- Fristberechnung: `hire_date ∈ [presentation_end, expires_at]`

### Greift Arkadiums 3-Mt-[[garantiefrist]]?
**Nein.** Die Garantiefrist setzt einen durch Arkadium dokumentierten Placement voraus. Ein Claim-Fall erzeugt **keine** nachträgliche Garantie — wir kassieren Honorar für die Vermittlungsleistung, aber haften nicht für Verbleib des Kandidaten beim Kunden.

Konsequenz: Wenn der Kandidat **nach** der Claim-Rechnungsstellung austritt, gibt es **keine** Rückvergütungspflicht. Der Kunde trägt das Austritts-Risiko allein.

### Der Arbeitsvertrag bleibt unberührt
Die Claim-Forderung richtet sich ausschliesslich an den **Kunden** (Auftraggeber). Vertragsverhältnis zwischen Kunde und Kandidat wird **nicht rückabgewickelt**. Der Kandidat ist nicht Teil des Rechtsverhältnisses.

### Prozess-Record-Hygiene
Der ursprüngliche Prozess wird **nicht wieder-geöffnet** und auch **nicht** als nachträglicher Placement markiert. Stattdessen separater Claim-Record:

```sql
fact_direct_hire_claim (
  id,
  protection_window_id,            -- FK fact_protection_window
  original_prozess_id,             -- FK zum alten Prozess (Referenz)
  detected_at,
  detection_source: 'scraper' | 'manual' | 'referral' | 'self_disclosure',
  hire_date_suspected,
  info_requested_at,
  info_received_at,
  hire_date_confirmed,
  salary_confirmed_chf,
  billing_basis: 'mandate_stage_3' | 'erfolgsbasis_staffel' | 'negotiated',
  claim_amount_chf,
  status: 'open' | 'negotiating' | 'billed' | 'paid' | 'waived' | 'disputed',
  resolution_note,
  closed_at
)
```

### Abrechnungsbasis
- Ursprünglich **Mandat** → Stage-3-Zahlung der Mandatsofferte fällig (= Rest-Honorar bis 100 %)
- Ursprünglich **Erfolgsbasis** → Staffel 21/23/25/27 % auf bestätigtes Gehalt
- Ursprünglich **Longlist-Only** (nie vorgestellt) → kein Anspruch

### UI-Implikation
- Tab „Claims" (Home-Modul oder Account-Detail)
- Drawer: Claim-Eröffnung mit Detection-Source, Auto-Vorberechnung des Claim-Betrags
- Status-Timeline Claim-Case (open → billed → paid)
- **Kein** Rückschluss auf Garantie oder Placement-Provision — das ist ein separater Billing-Flow

## UI-Implikationen

- Tab "Schutzfrist-Matrix" auf [[account]] — alle aktiven Kandidaten-Schutzfristen
- Warnbanner auf [[kandidat]] wenn Schutzfrist aktiv
- Info-Request-Template im [[email-system]]
- Dashboard-Widget "Offene Claim-Fälle" für AM/Admin

## Unscharfe Punkte

- **Geklärt 2026-04-12:** Scope = nur konkret vorgestellte Kandidaten (Variante A)
- **Geklärt 2026-04-13:** Vorstellung = mündlich (Telefon/Teams) oder per E-Mail (Dossier-Versand)
- 12-Monats-Speicher-Frist bei Kunde: wie detektieren, dass Info noch gespeichert ist?

## History-Integration

Jeder State-Change im Claim-Workflow (Claim eröffnet / Fall X/Y/Z klassifiziert / Rechnung erstellt / Kulanz-Abschluss) sowie Auto-Extension der Schutzfrist (12 → 16 Mt) schreibt automatisch einen Eintrag mit Activity-Type **#64 „Schutzfrist - Status-Änderung"** (System-Kategorie, auto). Die reine Scraper-Detection gehört **nicht** in die History — sie bleibt im Scraper-Audit-Log + Tab 9 Claim-Banner.

## Related

[[mandat-kuendigung]], [[agb-arkadium]], [[erfolgsbasis]], [[mandat]], [[scraper]], [[mandat-lifecycle-gaps]], [[history-system]], [[garantiefrist]] (3-Mt-Post-Placement — separates Konzept)
