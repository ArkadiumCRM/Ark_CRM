---
title: "Billing-Modul Research · Gemini narrativ · v0.1"
type: source
created: 2026-04-20
updated: 2026-04-20
sources: ["Externe AI-Antwort · Gemini-artig · narrative Langform"]
tags: [research, billing, phase3-erp, external-ai]
---

# Strategische Analyse und System-Spezifikation für das Billing-Modul der Arkadium AG

**Quelle:** Externe AI-Antwort · Gemini-artig · narrative Langform mit LaTeX-Formeln und Fokus auf QR-Type-S / AHV-21 / ISO 20022

## 1. LEGAL-FRAMEWORK

Die rechtliche Architektur des Billing-Moduls der Arkadium AG muss auf einem soliden Fundament schweizerischer Gesetzgebung ruhen, wobei das Obligationenrecht (OR), das Mehrwertsteuergesetz (MWSTG) sowie das revidierte Datenschutzgesetz (revDSG) die primären Säulen bilden. Im Zentrum der geschäftlichen Tätigkeit steht der Personalvermittlungsvertrag, der rechtlich als einfacher Auftrag gemäss Art. 394 ff. OR qualifiziert wird. Diese Einordnung hat weitreichende Konsequenzen für die Rechnungsstellung: Während im klassischen Auftragsrecht lediglich das sorgfältige Tätigwerden geschuldet ist, erlaubt die Vertragsfreiheit in der Schweiz die Vereinbarung von Erfolgshonoraren, wie sie im Modell „Best Effort" praktiziert werden. Hierbei entsteht der Honoraranspruch erst mit dem Abschluss des Arbeitsvertrages zwischen dem Kunden und dem vermittelten Kandidaten. Das System muss daher in der Lage sein, den Zeitpunkt der Vertragsschlusses als rechtlichen Trigger für die Fakturierung zu erfassen, wobei die Sorgfaltshaftung des Vermittlers gemäss Art. 398 OR stets gewahrt bleiben muss.

Ein kritischer Bereich des Legal-Frameworks betrifft den Schuldnerverzug und das Mahnwesen, geregelt in den Art. 102 bis 109 OR. Da Arkadium AG mit festen Zahlungsfristen operiert – 30 Tage für „Best Effort" und 10 Tage für „Mandat" – ist die präzise Definition dieser Fristen im ERP-System essentiell. Nach Ablauf dieser Fristen gerät der Kunde in Verzug, was gemäss Art. 104 OR einen Verzugszinssatz von 5 % p.a. auslösen kann, sofern in den AGB nichts Abweichendes vereinbart wurde. Die Systemlogik muss hierbei die kaufmännische Zinsmethode (30 Tage pro Monat, 360 Tage pro Jahr) strikt anwenden, wobei das Verbot von Zinseszinsen gemäss Art. 105 Abs. 3 OR programmtechnisch sichergestellt sein muss. Ergänzend dazu erlaubt Art. 106 OR die Geltendmachung eines Verzugsschadens, der über den Zins hinausgeht. Hierbei orientiert sich die schweizerische Praxis oft an den Empfehlungen von Inkasso Suisse, deren Verzugsschadentabelle maximale Entschädigungssätze basierend auf der Forderungshöhe definiert. Das Billing-Modul sollte diese Sätze als Referenz hinterlegen, um im Bedarfsfall rechtssichere Mahngebühren auszuweisen, auch wenn Arkadium aktuell auf separate Gebühren verzichtet.

| Gesetzliche Grundlage | Relevanz für das Billing-System | Strategische Implikation |
|---|---|---|
| Art. 394 ff. OR | Definition des Auftragsverhältnisses | Honoraranspruch bei Placement oder Mandat-Stage. |
| Art. 102 Abs. 1 OR | Verzug durch Mahnung | Automatisierter Workflow für Zahlungserinnerungen. |
| Art. 104 Abs. 1 OR | Verzugszins von 5% | Berechnungsgrundlage bei langfristigem Zahlungsverzug. |
| Art. 106 OR | Schadenersatz wegen Verzug | Rechtliche Basis für administrative Mahnspesen. |
| Art. 108 OR | Verzug ohne Mahnung | Anwendung bei fixen Verfalltagen in Mandatsverträgen. |

Die steuerrechtliche Komponente wird massgeblich durch die AHV-21-Reform beeinflusst, die per 1. Januar 2024 eine Erhöhung des Normalsatzes der Mehrwertsteuer von 7,7 % auf 8,1 % mit sich brachte. Das Billing-Modul muss diesen Satz als Default führen, jedoch eine zeitliche Logik besitzen, falls Leistungen aus dem Jahr 2023 nachberechnet werden. Die formellen Anforderungen an eine MwSt-konforme Rechnung nach Art. 26 MWSTG und Art. 57 MWSTV sind strikt einzuhalten. Dies umfasst neben dem Namen und Ort des Leistungserbringers zwingend die UID-Nummer mit dem Zusatz „MWST" (CHE-463.920.799 MWST) sowie detaillierte Angaben über Art, Gegenstand und Umfang der erbrachten Dienstleistung. Ein Versäumnis dieser Angaben kann beim Kunden zur Verweigerung des Vorsteuerabzugs führen und damit die Reputation der Arkadium AG als Premium-Boutique schädigen.

Besondere Komplexität entsteht bei grenzüberschreitenden Dienstleistungen. Gemäss dem Empfängerortsprinzip nach Art. 8 Abs. 1 MWSTG gilt der Ort der Dienstleistung als dort gelegen, wo der Empfänger seinen Sitz hat. Für das Billing-Modul bedeutet dies eine automatisierte Erkennung: Handelt es sich um einen Kunden mit Sitz im Ausland (z.B. Deutschland oder Österreich), muss die Rechnung ohne schweizerische MwSt ausgestellt werden, versehen mit dem Hinweis auf das Reverse-Charge-Verfahren („Steuerschuldnerschaft des Leistungsempfängers"). Hierbei ist zu beachten, dass bei Beratungsleistungen im Ausland zwar keine Inlandsteuer anfällt, der Umsatz jedoch gemäss Art. 23 MWSTG als steuerbefreit zu deklarieren ist. Das System muss diese Fälle separat für den Bexio-Export kennzeichnen, um die korrekte Deklaration in der MwSt-Abrechnung (Ziffer 200 und 221) zu ermöglichen.

Ein weiterer wesentlicher Aspekt des rechtlichen Rahmens ist das neue Datenschutzgesetz (revDSG), das seit dem 1. September 2023 in Kraft ist. Da Arkadium AG hochsensible Personendaten von Kandidaten verarbeitet, muss das Billing-Modul dem Prinzip „Privacy by Design" folgen. Die Praxis der „Blind Copy" auf Seite 3 der Rechnung ist hierbei nicht nur ein Akt der Diskretion, sondern eine direkte Umsetzung des Verhältnismässigkeitsprinzips nach Art. 6 Abs. 2 revDSG. Buchhaltungsabteilungen der Kunden benötigen für die Zahlungsfreigabe lediglich den Nachweis der Forderungshöhe und den Bezug zum Mandat, nicht jedoch den vollen Klarnamen oder sensible Profildaten des Kandidaten. Die technische Trennung der Datenströme bei der PDF-Generierung stellt sicher, dass nur notwendige Informationen an die Kreditorenbuchhaltung des Kunden gelangen, während die detaillierten Informationen dem Personalentscheider auf Seite 1 und 2 vorbehalten bleiben.

Zusammenfassend lässt sich festhalten, dass das Billing-Modul weit mehr als eine reine Rechenmaschine sein muss. Es ist ein Compliance-Instrument, das die Einhaltung des schweizerischen Vertrags- und Steuerrechts sowie des Datenschutzes automatisiert und damit das operative Risiko für die Arkadium AG minimiert. Die enge Verzahnung von OR-Bestimmungen zum Verzug, MWSTG-Vorgaben zur Fakturierung und revDSG-Prinzipien zur Datensparsamkeit bildet das rechtliche Rückgrat für die nachfolgenden technischen Spezifikationen.

## 2. STAMMDATEN-DELTAS

Die Transformation des bestehenden CRM hin zu einem integrierten ERP-System für die Arkadium AG erfordert eine signifikante Erweiterung der Stammdatenfelder. Während die bisherige Datenbank primär auf die Verwaltung von Kandidatenprofilen und Akquisitionsnotizen ausgelegt war, verlangt das Billing-Modul eine hohe Granularität im Bereich der Finanz- und Adressdaten. Insbesondere die Anforderungen der SIX Group für die Swiss QR-Bill (Version 2.3/2.4) erzwingen einen Wechsel von Freitext-Adressen hin zu vollstrukturierten Datensätzen.

Das wichtigste Delta betrifft die Adressstruktur der Kunden. Ab November 2025 sind im QR-Zahlteil ausschliesslich strukturierte Adressen des Typs S zulässig. Das bedeutet, dass das System keine kombinierten Adresszeilen mehr akzeptieren darf. In der Datenbank müssen die Felder für Strasse und Hausnummer zwingend getrennt werden. Da viele Bestandsdaten in einer Zeile vorliegen könnten, ist ein Migrationsskript erforderlich, das mithilfe von Regex-Patterns oder spezialisierten Parsing-Diensten eine saubere Trennung vornimmt. Zudem muss für jeden Debitor ein valider ISO-Landcode (z.B. „CH" für Schweiz, „LI" für Liechtenstein) hinterlegt sein, da dieser ein Pflichtbestandteil der QR-Code-Generierung ist.

| Stammdaten-Objekt | Feldname (Vorschlag) | Spezifikation / Validierung | Quelle / Grund |
|---|---|---|---|
| Kunde | `legal_street_name` | String, nur Strassenname ohne Nr. | QR-Type S Standard. |
| Kunde | `legal_house_number` | String, inkl. Suffixe (z.B. 45a) | QR-Type S Standard. |
| Kunde | `iso_country_code` | CHAR(2), nach ISO 3166-1 | Zwingend für QR-Bill. |
| Kunde | `billing_contact_email` | Validierte Email-Adresse | Automatisierter Rechnungsversand. |
| Kunde | `salutation_type` | Enum (Sie, Du) | Editorial-Style Textbausteine. |
| Kunde | `vat_exemption_reason` | String / Enum | Grund für 0% MwSt (z.B. Ausland). |
| Mitarbeiter | `digital_signature_img` | Blob / Dateipfad (PNG/SVG) | Dynamische Signatur auf PDFs. |
| Mitarbeiter | `department_code` | Enum (CE&BT, ARCH, REM) | Zuweisung des Zweitsignierers. |
| Mandat | `billing_model` | Enum (Best Effort, Mandat) | Prozess-Flow Steuerung. |

Ein weiteres kritisches Delta liegt in der Mitarbeiterverwaltung. Da Rechnungen bei Arkadium AG durch Nenad Stoparanovic und einen zweiten bereichsspezifischen Leiter unterzeichnet werden, muss das System eine dynamische Signaturlogik abbilden. Hierfür ist es notwendig, die Rollen der Mitarbeiter um Signatur-Attribute zu erweitern. Jedem Mandat muss ein „Primary Account Manager" (AM) und ein „Candidate Manager" (CM) fest zugeordnet sein, wobei deren Abteilungscodes (z.B. „CE&BT" für Peter Wiederkehr) bestimmen, welche Signatur-Assets auf das PDF-Template geladen werden. Diese Verknüpfung ist auch für die Commission-Engine von Bedeutung, da die Provisionsberechnung direkt an die am Mandat hinterlegten Rollen anknüpft.

Im Bereich der MwSt-Logik muss für jeden Kunden ein Statusfeld für die Steuerpflicht geführt werden. Dies ist insbesondere für Bauprojekte im grenznahen Ausland relevant, wo Arkadium Dienstleistungen für deutsche oder österreichische Architekturbüros erbringt. Das System muss unterscheiden können, ob ein Kunde eine gültige ausländische USt-ID besitzt, was die Voraussetzung für die Netto-Fakturierung unter dem Reverse-Charge-Regime ist. Fehlt diese ID, muss das System trotz Auslandsdomizil die schweizerische MwSt berechnen oder den User zur Klärung zwingen, um Steuerrisiken zu vermeiden.

Für den Export an Bexio und die Zusammenarbeit mit Treuhand Kunz müssen die Stammdaten zudem die Bexio-Kontaktnummern spiegeln. Eine automatische Synchronisation zwischen dem CRM und Bexio ist empfehlenswert, um Duplikate zu vermeiden. Beim Import der Rechnungen in Bexio ist das Feld „Land" zwingend erforderlich, damit der QR-Einzahlungsschein dort korrekt generiert werden kann. Das CRM muss also sicherstellen, dass dieses Feld niemals leer bleibt, bevor eine Rechnung finalisiert wird.

Zuletzt müssen die Sparten-Codes (z.B. ARCH, REM, CE, BT) als konsistente Stammdatenliste hinterlegt werden. Diese Codes erscheinen auf Seite 2 der Rechnungstabelle und dienen der internen Erfolgskontrolle pro Geschäftsbereich. Da diese Codes auch in den Provisionssheets der Mitarbeiter verwendet werden, führt eine Inkonsistenz in den Stammdaten zu Fehlern in der monatlichen Abrechnung. Das Billing-Modul muss daher eine strenge Validierung gegen diese Liste durchführen, bevor ein Placement-Prozess in den Billing-Workflow überführt werden kann.

## 3. SCHEMA-DELTAS

Die Datenbank-Architektur muss von einer rein dokumentenzentrierten Sichtweise zu einem relationalen Transaktionsmodell weiterentwickelt werden. Das Kernproblem vieler CRM-Systeme ist die statische Speicherung von Rechnungsdaten, was spätestens bei Rückerstattungen oder Teilzahlungen zu Inkonsistenzen führt. Das neue Schema muss die Arkadium-spezifischen Abläufe wie Mandats-Stages und Provisions-Clawbacks nativ unterstützen.

### 3.1 Entität: Invoice (Rechnung)

Die zentrale Tabelle Invoices muss als Header-Tabelle fungieren, die alle Rechnungs-Metadaten speichert. Ein wesentliches Schema-Delta ist hierbei das Feld `Invoice_No`, das dem Format `FN{YYYY}.{MM}.{####}` entsprechen muss. Um die Revisionssicherheit zu gewährleisten, darf dieses Feld nach der Finalisierung nicht mehr änderbar sein.

| Attribut | Datentyp | Relevanz |
|---|---|---|
| id | UUID | Eindeutiger technischer Primärschlüssel. |
| invoice_no | String(20) | Geschäftsnummer für den Kunden. |
| type | Enum | RECHNUNG, MAHNUNG, RÜCKERSTATTUNG. |
| status | Enum | DRAFT, FINALIZED, PAID, OVERDUE, REFUNDED. |
| total_net | Decimal(15,2) | Summe aller Positionen vor MwSt. |
| total_vat | Decimal(15,2) | Berechneter MwSt-Betrag (8.1% oder 0%). |
| total_gross | Decimal(15,2) | Endbetrag für den QR-Code. |
| qr_ref | String(27) | Strukturierte Referenz für CAMT-Abgleich. |

### 3.2 Entität: InvoicePosition (Rechnungspositionen)

Für das Mandats-Modell (Flow 2) ist eine hochflexible Positionsverwaltung notwendig. Jede Stage-Rechnung muss theoretisch alle drei Stages enthalten, wobei nur die aktuell fällige einen Betrag ausweist, während die anderen den Status „OFFENER POSTEN" tragen. Dies erfordert ein Flag `is_due` pro Position. Wenn eine Rechnung gedruckt wird, muss der PDF-Generator die Positionen so filtern, dass bei `is_due = false` der Text „OFFENER POSTEN" anstelle des Preises erscheint. Dies ist eine Abweichung von Standard-Systemen und stellt ein signifikantes Schema-Delta dar.

### 3.3 Entität: Placement & Compensation

Um die Honorarberechnung für „Best Effort" (Flow 1) abzubilden, müssen die Details des Arbeitsvertrages strukturiert gespeichert werden. Das Schema muss Felder für `base_salary`, `bonus_fixed`, `bonus_target` und `other_benefits` enthalten. Die Summe dieser Felder ergibt die `total_compensation`, welche die Basis für den hinterlegten `fee_percentage` bildet. Diese Daten müssen historisiert werden, damit eine spätere Gehaltserhöhung des Kandidaten die bereits gestellte Rechnung nicht korrumpiert.

### 3.4 Entität: Commission & Clawback

Die Kopplung von Billing und Commission erfordert eine eigene Tabelle `Commission_Entries`. Ein Eintrag wird generiert, sobald eine Rechnung finalisiert wird, bleibt aber im Status `pending_payment`. Erst wenn der Bankabgleich via CAMT.054 den Status der Rechnung auf `paid` setzt, wird der Provisionsanteil (z.B. 50/50 AM/CM Split) zur Auszahlung an Treuhand Kunz via Swissdec-ELM Export freigegeben. Im Falle einer Refund-Rechnung muss das System einen negativen Eintrag (Clawback) erzeugen, der die ursprüngliche ID referenziert und die Provision im nächsten Monatssheet neutralisiert.

### 3.5 Entität: ReminderHistory (Mahnwesen)

Zur Steuerung der Mahnstufen (1 bis 3) ist eine Historien-Tabelle notwendig, die pro Rechnung speichert, wann welche Mahnung versendet wurde. Dies ist rechtlich relevant für den Nachweis der In-Verzug-Setzung gemäss Art. 102 OR. Zudem muss das Schema ein Feld `reminder_block` enthalten, um Mahnungen für Key-Accounts manuell zu stoppen, falls Nenad Stoparanovic dies vorgibt.

## 4. PROZESS-FLOWS

Die Gestaltung der Prozess-Flows im Billing-Modul muss die boutique-spezifische Arbeitsweise der Arkadium AG widerspiegeln, die durch hohe Individualität bei gleichzeitigem Wunsch nach Automatisierung geprägt ist. Die Unterscheidung zwischen den beiden Haupt-Geschäftsmodellen ist hierbei die strukturbestimmende Komponente.

### 4.1 Flow 1: Best Effort (Erfolgshonorar)

Der „Best Effort"-Flow ist die häufigste Form der Rechnungsstellung und beginnt mit dem erfolgreichen Placement eines Kandidaten.

1. **Placement-Status:** Sobald ein Berater im CRM den Kandidaten auf „Vertrag unterzeichnet" setzt, öffnet sich automatisch der Billing-Drawer.
2. **Datenerfassung:** Der User erfasst die Gehaltsbestandteile des unterzeichneten Vertrages. Das System berechnet sofort die „Total Compensation" und wendet den Standard-Honorarsatz (z.B. 25 %) oder einen projektspezifischen Rabatt-Satz an.
3. **Backoffice-Review:** Die erstellte Rechnung landet im Workspace von S. Burri. Sie prüft die Adress-Vollständigkeit gegen die QR-SIX-Richtlinien (Strukturierung Type S).
4. **Generierung & Versand:** Nach Freigabe wird das 3-seitige PDF generiert. Seite 1 erhält die dynamischen Signaturen von Nenad Stoparanovic und dem jeweiligen Head of Department (z.B. Peter Wiederkehr für den Bereich Civil Engineering). Der Versand erfolgt als PDF-Anhang per E-Mail aus dem System.
5. **Monitoring:** Das System setzt ein Fälligkeitsdatum von T+30 Tagen. Täglich erfolgt ein automatisierter Import der CAMT.054-Dateien der Kantonalbank zur Abstimmung der offenen Posten.

### 4.2 Flow 2: Mandat (Phasen-Modell)

Der Mandats-Flow ist komplexer, da er über einen längeren Zeitraum mehrere Teilrechnungen erzeugt.

1. **Stage 1 (Akonto):** Bei Auftragserteilung wird die erste Rechnung über das Drittelshonorar („Suchstrategie, Identifikation und Pooling") fällig. Das System muss hierbei ein spezielles Template wählen, das Stage 2 und 3 bereits als „OFFENER POSTEN" aufführt, um dem Kunden die Gesamtkalkulation vor Augen zu führen.
2. **Stage 2 (Zwischenrechnung):** Wird der Meilenstein „Shortlist-Start" erreicht, triggert der Account Manager die zweite Rechnung. Das System erkennt die bereits fakturierte Stage 1 und setzt nur Stage 2 auf fällig.
3. **Stage 3 (Abschluss):** Nach erfolgreichem Placement erfolgt die Endabrechnung. Hierbei wird das Gesamthonorar basierend auf dem tatsächlichen Salär des Kandidaten berechnet und die bereits geleisteten Anzahlungen aus Stage 1 und 2 abgezogen.
4. **Verkürzte Frist:** Im Gegensatz zu Flow 1 setzt das System hier ein Zahlungsziel von nur 10 Tagen, um die laufenden Kosten der Mandatsbearbeitung zeitnah zu decken.

### 4.3 Refund-Workflow (Garantiefall)

Tritt der Garantiefall nach AGB §8 ein (Kündigung innerhalb der ersten 3 Monate), wird ein Reverse-Flow eingeleitet.

1. **Trigger:** Der AM meldet die Kündigung im System.
2. **Validierung:** Die Logik prüft das Startdatum des Kandidaten gegen das Kündigungsdatum. Liegt der Zeitraum unter 3 Monaten, wird der Prozess „Rückerstattung" freigeschaltet.
3. **Dokument:** Es wird ein Dokument mit dem Titel „RÜCKERSTATTUNG" erstellt, das die Originalrechnungsnummer (FN...) referenziert.
4. **Finanz-Transfer:** Da Arkadium das Geld zurückzahlt, wird kein QR-Einzahlungsschein gedruckt. Stattdessen wird die Bankverbindung des Kunden prominent ausgewiesen, damit das Backoffice die Überweisung manuell tätigen oder einen Pain.001-Export generieren kann.

### 4.4 Mahnwesen-Workflow

Das Mahnwesen folgt einer dreistufigen Eskalation, wobei der Tonfall im editorialen Stil der Arkadium AG angepasst ist.

1. **Erinnerung (T+5 nach Fälligkeit):** Höfliches Anschreiben („sicherlich in der Hektik untergegangen"). Das System generiert eine neue Frist von 5 Tagen.
2. **Zweite Mahnung (T+10):** Bestimmterer Tonfall. Verweis auf drohende Verzugszinsen gemäss Art. 104 OR.
3. **Letzte Mahnung (T+15):** Scharfer Ton, Androhung der Inkasso-Übergabe. Nach Ablauf dieser Frist wird ein Export-File für den externen Inkasso-Partner generiert, inklusive aller relevanten Vertrags- und Kommunikationsprotokolle.

## 5. BUSINESS-LOGIC

Die Business-Logic transformiert die reinen Prozessdaten in kalkulatorische Werte und stellt sicher, dass die finanzielle Integrität der Arkadium AG gewahrt bleibt. Sie bildet das Gehirn des Moduls und verknüpft Honorarberechnung, Provisionslogik und steuerliche Validierung.

### 5.1 Kalkulations-Engine für „Best Effort"

Das Honorar berechnet sich gemäss der Formel:

$$H_{net} = TC \times HR$$

Wobei $TC$ die „Total Compensation" (Jahressalär inkl. 13. ML, Boni, Autopauschale) und $HR$ der Honorarsatz ist.

**Beispiel:** Ein Kandidat im Bereich Building Technology (BT) startet mit 140'000 CHF Basisgehalt und einem garantierten Bonus von 10'000 CHF. Die Autopauschale beträgt 5'000 CHF. Die $TC$ liegt somit bei 155'000 CHF. Bei einem $HR$ von 25 % generiert die Engine ein Honorar von 38'750 CHF exkl. MwSt.

- **MwSt-Aufschlag:** Die Engine schlägt automatisch 8,1 % MwSt auf den Netto-Betrag auf, sofern der Kunde in der Schweiz ansässig ist. Bei Auslandskunden erfolgt ein automatischer „Zero-Tax"-Match mit entsprechendem Hinweistext.
- **Rundung:** Gemäss schweizerischer Marktusanz muss das System auf 5 Rappen genau runden, um Differenzen im QR-Zahlteil zu vermeiden.

### 5.2 Provisions-Engine (Account- & Candidate-Split)

Die Verteilung der Honorare auf die Mitarbeiter folgt einer strengen 50/50-Logik, die jedoch durch Researcher-Pauschalen modifiziert wird.

1. **Eingang:** Das System empfängt das Signal `Payment_Confirmed` vom CAMT-Importer.
2. **Researcher-Abzug:** Zuerst wird die Researcher-Pauschale vom Brutto-Honorar abgezogen.
3. **AM/CM Split:** Der verbleibende Betrag wird zu gleichen Teilen dem Account Manager (Akquise) und dem Candidate Manager (Matching) gutgeschrieben.
4. **Interne Sheets:** Diese Daten fliessen monatlich in die personalisierten Excel-Provisionssheets (z.B. „Joaquin Vega.xlsx"), die als Basis für den Swissdec-ELM Export dienen.
5. **Clawback-Logik:** Im Falle eines Refunds wird die Provision retroaktiv invalidiert. Das System muss den Betrag im laufenden Monatssheet als Negativposten ausweisen, um Überzahlungen zu vermeiden.

### 5.3 Mandat-Cancellation-Logik

Wird ein Mandat vom Kunden vorzeitig abgebrochen, greift die Kündigungslogik. Das System berechnet die Abschlusszahlung basierend auf dem „bereits geleisteten Aufwand".

- Die Engine prüft, welche Stages (1 oder 2) bereits fakturiert wurden.
- Wurde das Mandat nach der Shortlist-Präsentation, aber vor dem Placement abgebrochen, wird eine anteilige Gebühr fällig, während die Stage 3 („Schluss-Rechnung") automatisch auf den Status `cancelled` gesetzt wird.
- Das Dokument „Vorlage_Rechnung_Kündigung Mandat.pdf" wird generiert, um diesen Vorgang rechtssicher abzuschliessen.

### 5.4 QR-Bill Validierung (Vermeidung von Reject-Zahlungen)

Bevor eine Rechnung finalisiert werden kann, prüft eine Validierungs-Schicht die Datenintegrität für den QR-Zahlteil:

- **Struktur-Check:** Sind alle Adressfelder (Strasse, Nr, PLZ, Ort) gemäss Type S vorhanden?
- **IBAN-Check:** Handelt es sich um die korrekte IBAN der Kantonalbank (CH07 0077...)?
- **Betrags-Check:** Entspricht der im QR-Code encodierte Betrag exakt dem Rechnungsbetrag auf Seite 2? Diskrepanzen führen oft zu Fehlern beim Scanning in Banking-Apps.

## 6. UI-ARCHITEKTUR

Das visuelle Erscheinungsbild des Billing-Moduls muss die Markenwerte der Arkadium AG – Exklusivität, Präzision und Boutique-Charakter – in den digitalen Raum übertragen. Der „Editorial Style" mit den Schriftarten Libre Baskerville (Serife für Eleganz) und DM Sans (Grotesk für Funktionalität) ist konsequent anzuwenden.

### 6.1 Der globale Billing-Workspace

In der Hauptnavigation wird der Bereich „Finanzen" eingeführt, der eine Dashboard-Übersicht über alle Debitoren bietet.

- **Status-Cards:** Große Metriken am oberen Rand zeigen „Fakturiert im lfd. Monat", „Offene Posten" und „Überfällig (Mahnwesen)".
- **Smart-Filtering:** User können die Liste nach AM/CM, Sparte (Architecture, Civil Engineering) oder Rechnungs-Typ (Mandat vs. Best Effort) filtern.
- **Visual Indicators:** Überfällige Rechnungen werden mit einem roten Badge markiert, der bei Hover die aktuelle Mahnstufe (1, 2 oder 3) anzeigt.

### 6.2 Der 540px Billing-Drawer (Editorial-Style)

Alle Aktionen zur Rechnungserstellung finden in einem 540px breiten Side-Drawer statt, um die Kontext-Kohärenz zum Rekrutierungsprozess zu wahren.

- **Header:** Titel der Aktion (z.B. „Rechnung erstellen") in Libre Baskerville. Darunter eine Breadcrumb-Struktur, die anzeigt, in welchem Schritt (Datenprüfung → Kalkulation → Preview) man sich befindet.
- **Input-Sektionen:** Die Eingabefelder sind in thematischen Gruppen angeordnet:
  - **Kundeninfo:** Anzeige der strukturierten Adresse mit direktem Link zur Korrektur in den Stammdaten (QR-Compliance).
  - **Kandidat & Honorar:** Schieberegler für den Honorarsatz (25 % Default), Eingabemasken für das Gehalt. Die Engine berechnet in Echtzeit den Honorarbetrag.
  - **Optionen:** Auswahl „Sie" vs. „Du" für das Anschreiben-Template.
- **Live-Preview-Widget:** Am unteren Rand des Drawers wird eine Miniatur-Vorschau von Seite 2 der Rechnung eingeblendet. Jede Gehaltsänderung aktualisiert sofort die Summen in der Vorschau, was Fehler minimiert.

### 6.3 PDF-Template-Visualisierung

Die Generierung der 3-seitigen PDFs folgt einem strengen Layout-Raster:

- **Seite 1 (Das Anschreiben):** Die Typografie folgt dem Briefkopf-Standard der Arkadium AG. Die Signaturen sind als transparente PNGs in Originalgrösse eingebunden, um einen authentischen Eindruck zu hinterlassen.
- **Seite 2 (Die Tabelle):** Fokus auf Klarheit. Die Tabelle nutzt DM Sans für maximale Lesbarkeit. Rabatte werden prominent als Negativ-Position ausgewiesen, um die Kulanz gegenüber dem Kunden zu betonen. Das Zahlungsziel wird fett gedruckt.
- **Seite 3 (Blind Copy & QR):** Die „Blind Copy"-Logic ersetzt den Kandidatennamen durch den Platzhalter `Kandidat (Diskretions-Kopie)`. Der QR-Zahlteil ist gemäss den SIX-Spezifikationen exakt 210 x 105 mm gross und befindet sich am Fuss der A4-Seite.

## 7. ROLLEN-MATRIX

Die Sicherheit und Integrität finanzieller Daten erfordert ein differenziertes Berechtigungskonzept. In einer 10-köpfigen Boutique wie Arkadium ist die Rollentrennung (Segregation of Duties) entscheidend, um Fehlbuchungen zu vermeiden und den Datenschutz (revDSG) zu gewährleisten.

| Rolle | Profil | Billing-Berechtigungen | CRM-Einschränkungen |
|---|---|---|---|
| Founder / Admin | Nenad Stoparanovic | Voller Zugriff auf alle Rechnungen & Provisionssheets. Löschrecht für Fehlbuchungen. | Keine Einschränkungen. |
| Backoffice | S. Burri | Erstellung aller Rechnungstypen, Import von CAMT-Files, Export an Bexio/Swissdec. | Kein Einblick in AM-interne Akquisitions-Notizen. |
| Account Manager (AM) | P. Wiederkehr / J. Vega | Triggern von Rechnungen aus Placements. Einsehen der eigenen Provisionen. | Kein Zugriff auf Rechnungen anderer AMs oder Researcher-Sheets. |
| Candidate Manager (CM) | Fachrekrutierer | Einsehen des Zahlungsstatus „ihrer" Placements zur Provisionskontrolle. | Kein Schreibzugriff auf Rechnungsdaten oder Adressen. |
| Treuhand Partner | Kunz (Extern) | Lesezugriff auf Rechnungslisten und Generierung von CSV-Exports. | Kein Zugriff auf Kandidaten-Dossiers oder CRM-Notizen. |

Ein wesentliches Sicherheitsmerkmal ist das „Vier-Augen-Prinzip". Während der AM die Rechnung triggert und die Gehaltsdaten erfasst, erfolgt die finale Freigabe zur PDF-Generierung durch das Backoffice (S. Burri). Dies stellt sicher, dass sowohl die kommerziellen Parameter (vom AM) als auch die formellen/steuerrechtlichen Parameter (vom Backoffice) geprüft wurden, bevor das Dokument das Unternehmen verlässt.

## 8. INTEGRATIONEN

Das Billing-Modul fungiert als zentrale Schaltstelle zwischen dem CRM, der Buchhaltung des Treuhänders, der Lohnbuchhaltung und dem Bankwesen.

### 8.1 Bexio-Integration (Accounting Export)

Der Datentransfer an Treuhand Kunz erfolgt primär via CSV-Schnittstelle. Da Bexio sehr strikte Vorgaben für den Rechnungsimport hat, muss das Billing-Modul einen spezialisierten Export-Treiber besitzen.

- **Mapping:** Das System mappt die Arkadium-Datenfelder auf die Bexio-Spalten (z.B. `Name_1` = Kundenname, `Einzelpreis` = Honorar netto, `Steuersatz` = MwSt-Code).
- **Kontierung:** Jede Rechnungsposition wird automatisch dem Ertragskonto 3400 (Dienstleistungserlöse) zugeordnet, während Rückerstattungen auf ein Aufwandskonto gebucht werden.
- **Massendaten:** Der Export ist für Batch-Processing optimiert (bis zu 200 Rechnungen pro File), um dem Treuhänder monatlich einen effizienten Import zu ermöglichen.

### 8.2 ISO 20022 & CAMT.054 (Banking Reconciliation)

Zur Automatisierung des Zahlungseingangs wird ein Parser für CAMT-Meldungen der Kantonalbank implementiert.

- **Funktionsweise:** Das Backoffice lädt täglich die CAMT.054-Datei (Debit/Credit Notification) hoch. Das System extrahiert die 27-stellige Referenznummer aus dem Tag `<Ref>` und gleicht diese mit den offenen Rechnungen ab.
- **Vorteil:** Durch die Strukturierung der QR-Referenz ist eine Matching-Quote von nahezu 100 % erreichbar, was den manuellen Aufwand für S. Burri drastisch reduziert.
- **Provisions-Trigger:** Nur bei Status `confirmed_payment` in der CAMT-Datei wird die Provisionsberechnung für AM/CM in den Status `ready_for_payout` überführt.

### 8.3 Swissdec-ELM (Payroll Integration)

Die Provisionsauszahlungen an die 10 Mitarbeiter müssen revisionssicher an die Lohnbuchhaltung übermittelt werden. Das System generiert hierfür einen Export nach dem Swissdec-ELM-Standard.

- **Inhalt:** Übertragung der variablen Lohnbestandteile (Provisionen) pro Mitarbeiter.
- **Sicherheit:** Die Daten werden gemäss Swissdec-Vorgaben verschlüsselt und enthalten alle für die Sozialversicherungen (AHV/FAK) notwendigen Informationen.
- **Vorteil:** Reduktion von Übertragungsfehlern zwischen CRM-Excel-Listen und der tatsächlichen Lohnabrechnung durch Treuhand Kunz.

## 9. OPEN QUESTIONS

Trotz der detaillierten Planung bleiben operative Grenzfälle offen, die im Zuge der UI-Prototyping-Phase mit Nenad Stoparanovic geklärt werden müssen:

1. **Staffelung von Refunds:** Die AGB Ziffer 8 sieht eine Garantie von 3 Monaten vor. Soll das System eine degressive Staffel unterstützen (z.B. Rückzahlung 100 % im 1. Monat, 50 % im 2. Monat)? Bisherige Vorlagen deuten auf 100 % hin, aber die Marktusanz in der Schweiz erlaubt oft prozentuale Kürzungen je nach Verbleib des MA.
2. **Splitting bei Team-Wechsel:** Was passiert, wenn ein Mandat von AM-1 begonnen wurde, dieser das Unternehmen verlässt, und AM-2 den Abschluss macht? Das System muss eine zeitanteilige Provisionsaufteilung oder eine manuelle Override-Funktion in der Commission-Engine besitzen.
3. **Währungsvarianten:** Wird Arkadium zukünftig Mandate im EU-Raum (z.B. für deutsche Architekturbüros) in EUR fakturieren? Der QR-Standard unterstützt EUR, verlangt dann aber zwingend die Kombination IBAN/SCOR anstelle von QR-IBAN/QRR.
4. **Mahngebühren-Skalierung:** Soll das System technisch die Möglichkeit bieten, Mahngebühren ab Stufe 2 automatisch aufzuschlagen (z.B. CHF 30.00 gemäss Inkasso Suisse Empfehlung), falls die AGB dies zukünftig vorsehen? Aktuell ist dies nicht Teil der PDF-Templates.

## 10. RISIKEN & GRAUZONEN

### 10.1 Technisches Compliance-Risiko (QR-Address-Validation)

Die Umstellung auf strukturierte Adressen (Type S) birgt das Risiko von Reject-Zahlungen. Wenn CRM-User Adressen unsauber pflegen (z.B. „Maneggstrasse 45" in einem Feld statt Trennung von Strasse und Nummer), wird der QR-Generator ungültige Codes erzeugen. Ein integrierter Adress-Validator im Billing-Drawer ist zwingend erforderlich, um dieses operative Risiko zu minimieren.

### 10.2 Rechtliche Grauzone (DSG vs. GeBüV)

Es besteht ein latenter Konflikt zwischen dem Löschgebot des revDSG (Kandidatendaten nach Abschluss löschen) und der 10-jährigen Aufbewahrungspflicht der Buchhaltungsbelege gemäss GeBüV. Die Lösung muss darin bestehen, die Rechnungs-PDFs als unveränderbare Snapshots im Archiv zu belassen (inkl. Kandidatenname), während die aktiven Datensätze im CRM nach der Garantiezeit anonymisiert werden.

### 10.3 Wirtschaftliches Risiko (Provisions-Clawbacks)

Bei hohen Honorarsummen (z.B. 40'000 CHF) führt eine Rückerstattung im 3. Monat zu massiven Provisions-Clawbacks für die Mitarbeiter. Dies kann zu Liquiditätsproblemen bei den MA führen, wenn die Provisionen bereits ausgegeben wurden. Die Arkadium AG sollte überlegen, ob ein Teil der Provision („Retention") bis zum Ablauf der 3-monatigen Garantiefrist im System zurückgehalten wird, anstatt die volle Auszahlung sofort nach Zahlungseingang zu triggern.

### 10.4 Durchsetzbarkeit von Schutzfristen (AGB §6)

Die Überwachung der Schutzfristen (12 bis 16 Monate) bei Direkteinstellungen ist systemseitig schwer abzubilden. Das CRM kann zwar Warnmeldungen ausgeben, wenn ein früherer Kandidat beim Kunden „erscheint", die faktische Beweisführung für den Billing-Anspruch bleibt jedoch ein administratives Wagnis und erfordert eine enge manuelle Überwachung durch die AMs.

Dieses Billing-Modul stellt somit nicht nur eine funktionale Erweiterung dar, sondern ist eine strategische Neuausrichtung der Arkadium AG hin zu einem digitalisierten, rechtssicheren und skalierbaren Premium-Dienstleister im Schweizer Immobilien- und Bausektor.
