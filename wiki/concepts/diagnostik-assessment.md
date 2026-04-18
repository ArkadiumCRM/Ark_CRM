---
title: "Diagnostik & Assessment (eigenständige Dienstleistung)"
type: concept
created: 2026-04-12
updated: 2026-04-12
sources: ["General/4_Account Management/Offerte Diagnostik/Vorlage_Offerte Diagnostik & Assessment.docx"]
tags: [concept, diagnostik, assessment, dienstleistung, scheelen]
---

# Diagnostik & Assessment

Eigenständige **Dienstleistungs-Linie** neben Mandat / Best Effort / Time / Taskforce. Kann mandatsbezogen oder mandatsunabhängig gebucht werden. Siehe [[offerte-diagnostik]].

## Abgrenzung

| Kontext | Wann |
|---------|------|
| **Mandatsbezogen** | Integriert in Mandats-Stage (üblicherweise Stage 3) oder als [[optionale-stages]] IX |
| **Mandatsunabhängig** | Externe Beauftragung — Kunde will Persönlichkeits-Analyse eines bestehenden Mitarbeiters / externen Kandidaten ohne Vermittlung |

## Datenfluss (geklärt 2026-04-13)

Unabhängig davon, ob mandatsbezogen oder mandatsunabhängig:

1. **Person als [[kandidat]] erfassen** (falls noch nicht vorhanden) — jede getestete Person wird im CRM als Kandidat angelegt
2. **Account zuweisen** → der Kunde, der die Analyse bezahlt
3. **Assessment im Assessment-Tab** des Kandidaten anlegen (bestehende Struktur, siehe [[assessment]])
4. Durch Account-Zuweisung erscheint das Assessment automatisch:
   - Im **Teamrad** des Accounts (aggregierte Team-Persönlichkeitsansicht)
   - In Account-Statistiken / Reports
5. **History-Einträge** werden parallel geschrieben:
   - Beim Kandidaten: "Assessment durchgeführt für Account X"
   - Beim Account: "Assessment durchgeführt für Kandidat Y"

## Frage: Assessments als Mandat tracken?

**Empfehlung: Nein — eigene Entity, aber UI-Pattern analog.**

Gründe dagegen (Tracking als Mandat):
- Mandat-Datenmodell ist auf **Longlist + Research + Placement** ausgelegt — Assessments haben keine dieser Dimensionen
- `mandate_type` Enum würde aufgeblasen (analog zum RPO-Problem — siehe [[rpo-offerte]])
- Stages-Billing (3 Teilzahlungen bei Exklusivmandat, Monatsfee bei Taskforce) passt nicht zum Pauschalpreis
- Verwirrt Reporting: "Mandat abgeschlossen" hat andere Semantik als "Assessment ausgeliefert"

Empfohlen: **eigene Entity `fact_assessment_order`** (siehe unten), aber **UI-Pattern analog zu Mandat** — eigene Detailseite am Account mit Tabs (Übersicht, Kandidaten, Billing, Dokumente). So bekommst du gefühlte Gleichwertigkeit ohne Datenmodell-Verbiegung.

Alternative (falls du Einheitlichkeit bevorzugst): **gemeinsame Parent-Entity `fact_engagement`** mit Subtypen `Mandat` und `Assessment`. Grosser Refactor, aber sauberer langfristig. Würde ich aber erst machen wenn ein dritter Typ dazukommt (z.B. Beratungs-Mandate).

## Leistungspakete (3)

1. **Diagnostik- & Assessmentanalyse** — SCHEELEN® x Arkadium, Big Five, EQ Tests, Driving Forces, ASSESS 5.0ing
2. **Auswertung + Handlungsempfehlungen** — inkl. Dismatch-Faktoren, Coping-Analyse
3. **Relief Analyse / Executive Summary** — managementtaugliche Entscheidungsgrundlage, ~100 Seiten Detail-Anhang

## Preislogik

**Pauschalpreis** — einfaches Modell, kein Stage-System.
Beispiel: CHF 10'000 für 2 Assessments zweier Positionen.

## Technische Verbindung zum CRM

Bereits in [[assessment]] technisch abgebildet (DISC, EQ, Motivatoren, ASSESS 5.0, 18 Chart-Typen, Teamrad). **Geschäftslogisch** aber noch nicht als eigene Billing-Linie:

## CRM-Datenmodell (Soll)

```sql
fact_assessment_order (
  id,
  account_id,            -- immer gesetzt (Kunde, der bezahlt)
  kandidat_id,           -- immer gesetzt (getestete Person, ggf. vorher neu angelegt)
  mandat_id,             -- nullable (nur bei mandatsbezogener Durchführung)
  package_type: 'diagnostik_only' | 'full_package' | 'executive_summary_only',
  price_chf,             -- case-by-case pauschal
  status: 'offered' | 'ordered' | 'scheduled' | 'completed' | 'invoiced',
  signed_document_id,
  invoice_id,
  partner: 'SCHEELEN' | 'internal' | ...
)
```

**History-Doppelschreibung (geklärt 2026-04-13):**
- `fact_history` Eintrag am Kandidaten (Typ: `assessment_conducted`, ref: assessment_order_id, context: account_name)
- `fact_history` Eintrag am Account (Typ: `assessment_ordered`, ref: assessment_order_id, context: kandidat_name)

**Teamrad-Integration:** Alle Assessments mit `account_id = X` werden automatisch ins Teamrad des Accounts aggregiert, auch die mandatsunabhängigen.

## Auftragsvertrag + Billing (geklärt 2026-04-13)

Jeder Assessment-Auftrag hat **eigenen Auftragsvertrag** und **eigene Billing-Spur** — wie ein Mandat, nur mit schlankerem Datenmodell.

### Auftragsvertrag
- Offerte via `Vorlage_Offerte Diagnostik & Assessment.docx` ([[offerte-diagnostik]])
- Kunde unterschreibt → `fact_assessment_order.status = 'ordered'` + `signed_document_id` gesetzt
- Trigger: Assessment-Durchführung kann starten

### Billing
- **Pauschalpreis** pro Auftrag (case-by-case, siehe [[honorar-berechnung]] Abschnitt 5)
- Rechnung via `Vorlage_Rechnung_Diagnostics & Assessment.docx`
- **Typischer Flow:** Einmalige Schlussrechnung nach Auslieferung der Executive Summary (`status = 'completed'` → Rechnungs-Trigger)
- Optional: Teilzahlung-Modell bei grösseren Paketen (z.B. mehrere Assessments) — dann analog zu `fact_mandate_billing` ein `fact_assessment_billing` mit mehreren Einträgen

**Zusätzliches Billing-Datenmodell:**
```sql
fact_assessment_billing (
  id,
  assessment_order_id,
  billing_type: 'full' | 'deposit' | 'final' | 'expense',
  amount_chf,
  due_date,
  invoice_id,            -- FK auf generierte Rechnung
  paid_at,
  status: 'pending' | 'invoiced' | 'paid' | 'overdue'
)
```

### Spesen (aus Offerte Abschnitt III)
*"Zusätzlich anfallende individuellen Spesen, wie Fahrkosten, Übernachtungen, Verpflegungen oder andere reisebedingte Auslagen, werden nach effektivem Aufwand und gegen Beleg separat in Rechnung gestellt."*

→ Spesen als separater `fact_assessment_billing.billing_type = 'expense'`-Eintrag pro Beleg.

## Eigene Detailseite (entschieden 2026-04-13)

**Route:** `/assessments/[id]` — eigene Detailseite, bidirektional verknüpft mit Kandidaten und Kunden.

### 5 Tabs analog zu [[mandat]]
1. **Übersicht** — Status, Package, Preis, Kandidat(en), Partner (SCHEELEN® / intern)
2. **Kandidaten** — Liste der zu testenden Personen (Multi-Person-Assessments möglich)
3. **Billing** — Auftragswert, Rechnungen, Spesen, Zahlungsstatus
4. **Dokumente** — Offerte, unterschriebener Vertrag, Executive Summary, Detail-Reports
5. **History** — Assessment-Termine, Auswertungs-Sessions (doppelt geschrieben: auch in Kandidaten- und Account-History sichtbar)

### Verknüpfungen

**Zum [[account]]:**
- Auf der Account-Detailseite erscheint eine eigene Section "Assessments" (neben "Mandate")
- Jedes Assessment zeigt: Status, Kandidat(en), Preis, fällige/bezahlte Rechnungen
- Klick → Navigation zur Assessment-Detailseite
- Teamrad aggregiert alle Assessments mit `account_id = X` automatisch

**Zum [[kandidat]]:**
- Im Assessment-Tab des Kandidaten erscheint Link "Teil von Auftrag XYZ" mit Navigation zur Assessment-Detailseite
- Auftrags-Metadaten (Auftraggeber, Zeitpunkt, Partner) sichtbar
- Die eigentlichen Test-Ergebnisse (DISC, EQ, ASSESS 5.0-Charts) bleiben im Kandidaten-Assessment-Tab (bestehende [[assessment]]-Struktur)

**Zum [[mandat]] (optional):**
- Bei mandatsbezogener Durchführung: `fact_assessment_order.mandat_id` gesetzt
- Im Mandat-Tab "Dokumente" oder "Übersicht" taucht das zugehörige Assessment auf
- Mandats-Kündigung → offene Assessments werden geflagged (noch abzuschliessen?)

### Navigations-Flow (Beispiele)
- Account → Section "Assessments" → Assessment-Detailseite → Kandidaten-Tab → Kandidaten-Detailseite
- Kandidat → Assessment-Tab → Link "Auftrag XYZ" → Assessment-Detailseite → Account-Link
- Mandat → Übersicht → verknüpftes Assessment → Assessment-Detailseite

## Workflow

1. Offerte via `Vorlage_Offerte Diagnostik & Assessment.docx`
2. Unterschrift → Auftrag
3. Durchführung (online Tests + Validierungsgespräch)
4. Bericht + Executive Summary an Kunde
5. Rechnung via `Vorlage_Rechnung_Diagnostics & Assessment.docx`
6. Ergebnisse in [[assessment]]-Tab am Kandidaten

## Haftungsausschluss (aus Offerte)

- Arkadium haftet **nicht** für personelle/strukturelle Entscheidungen, die der Kunde aufgrund Assessment-Ergebnissen trifft
- Spesen separat nach Aufwand

## Related

[[assessment]], [[offerte-diagnostik]], [[optionale-stages]], [[honorar-berechnung]], [[kandidat]], [[account]], [[mandat]], [[mandat-lifecycle-gaps]]
