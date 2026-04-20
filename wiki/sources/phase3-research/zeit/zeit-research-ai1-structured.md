## 1. LEGAL-FRAMEWORK

Die Zeiterfassung in der Schweiz unterliegt strengen gesetzlichen Bestimmungen, die primär im Arbeitsgesetz (ArG), der Verordnung 1 zum Arbeitsgesetz (ArGV 1) und dem Obligationenrecht (OR) verankert sind. Für eine Headhunting-Boutique im Kanton Zürich sind insbesondere folgende Punkte relevant:

### Zeiterfassungspflicht (ArG Art. 46, ArGV 1 Art. 73)

Arbeitgeber sind gemäss Art. 46 ArG und Art. 73 ArGV 1 verpflichtet, Verzeichnisse oder andere Unterlagen zu führen, aus denen die für den Vollzug des Gesetzes und seiner Verordnungen notwendigen Angaben hervorgehen [1]. Dies umfasst insbesondere die geleistete tägliche und wöchentliche Arbeitszeit, einschliesslich Ausgleichs- und Überzeitarbeit, sowie die Lage und Dauer der Ruhepausen von einer halben Stunde und mehr [4]. Die Aufbewahrungsdauer dieser Unterlagen beträgt 5 Jahre [2].

### Ausnahmen und vereinfachte Erfassung (ArGV 1 Art. 73a/b)

Für bestimmte Arbeitnehmergruppen sind Ausnahmen oder vereinfachte Formen der Zeiterfassung zulässig. Gemäss Art. 73a ArGV 1 kann auf die detaillierte Arbeitszeiterfassung verzichtet werden, wenn Arbeitnehmer über eine grosse Autonomie in der Gestaltung ihrer Arbeitszeit verfügen und ein Bruttojahreslohn von über CHF 120'000 erzielen. Dies bedarf einer schriftlichen Vereinbarung zwischen Arbeitgeber und Arbeitnehmer [6]. Art. 73b ArGV 1 ermöglicht eine vereinfachte Erfassung, bei der lediglich die tägliche Arbeitszeit erfasst wird, sofern eine schriftliche Vereinbarung vorliegt [6].

### Ruhezeiten (ArG Art. 15-22)

Das ArG schreibt Mindestruhezeiten vor:

*   **Tägliche Ruhezeit:** Nach Beendigung der täglichen Arbeit muss dem Arbeitnehmer eine ununterbrochene Ruhezeit von mindestens 11 Stunden gewährt werden (Art. 15 ArG).
*   **Wöchentliche Ruhezeit:** Zusätzlich zur täglichen Ruhezeit muss pro Woche ein freier Halbtag oder ein ganzer Ruhetag gewährt werden, der in der Regel auf einen Sonntag fällt (Art. 20a ArG). Die wöchentliche Ruhezeit beträgt mindestens 35 Stunden (11 Stunden tägliche Ruhezeit + 24 Stunden Sonntag) [4].
*   **Pausen:** Bei einer täglichen Arbeitszeit von mehr als 5.5 Stunden ist eine Pause von mindestens 15 Minuten, bei mehr als 7 Stunden eine Pause von 30 Minuten und bei mehr als 9 Stunden eine Pause von 1 Stunde zu gewähren (Art. 15 ArG). Pausen von mehr als einer halben Stunde dürfen aufgeteilt werden [4].

### Höchstarbeitszeit (ArG Art. 9-12, OR Art. 321c)

Die Höchstarbeitszeit ist gesetzlich begrenzt. Für Arbeitnehmer in industriellen Betrieben sowie für Büropersonal, technische und andere Angestellte, einschliesslich des Verkaufspersonals in Grossbetrieben des Detailhandels, beträgt sie 45 Stunden pro Woche (Art. 9 ArG). Für alle anderen Arbeitnehmer beträgt sie 50 Stunden pro Woche. Überzeit ist die Arbeitszeit, welche die vertraglich vereinbarte Arbeitszeit überschreitet, aber innerhalb der gesetzlichen Höchstarbeitszeit liegt. Überstunden sind die Arbeitszeit, welche die gesetzliche Höchstarbeitszeit überschreitet. Überzeitarbeit ist gemäss Art. 321c OR mit einem Zuschlag von mindestens 25% zu entschädigen oder durch Freizeit von gleicher Dauer zu kompensieren, wenn nichts anderes schriftlich vereinbart wurde [4].

### Ferienanspruch (OR Art. 329a), Kompensation Überzeit (OR Art. 321c Abs. 3)

Der Ferienanspruch beträgt gemäss Art. 329a OR mindestens vier Wochen pro Dienstjahr, für Arbeitnehmer bis zum vollendeten 20. Altersjahr fünf Wochen. Die Kompensation von Überzeit kann durch Freizeit von gleicher Dauer erfolgen, wenn dies mit dem Arbeitnehmer vereinbart wird [4].

### Nacht- und Sonntagsarbeit (ArG Art. 16-20)

Nacht- und Sonntagsarbeit ist grundsätzlich verboten und nur mit Bewilligung der Behörden zulässig. In der Headhunting-Branche ist dies in der Regel nicht relevant.

### Krank/Unfall/Militär (OR Art. 324a, Berner Skala)

Bei unverschuldeter Arbeitsverhinderung, z.B. durch Krankheit, Unfall oder Militärdienst, hat der Arbeitnehmer Anspruch auf Lohnfortzahlung gemäss Art. 324a OR. Die Dauer der Lohnfortzahlung richtet sich nach der Dauer des Arbeitsverhältnisses und wird oft anhand von Skalen wie der Berner Skala bestimmt [7].

| Dienstjahr | Dauer der Lohnfortzahlung (Berner Skala) |
| :--------- | :--------------------------------------- |
| 1.         | 3 Wochen                                 |
| 2.         | 1 Monat                                  |
| 3.-4.      | 2 Monate                                 |
| 5.-9.      | 3 Monate                                 |
| 10.-14.    | 4 Monate                                 |
| 15.-19.    | 5 Monate                                 |
| ab 20.     | 6 Monate                                 |

*Hinweis: Die Berner Skala ist eine Richtlinie; kantonale oder vertragliche Regelungen können abweichen [7].*

### Bundesgerichts-Urteile zu Zeiterfassungspflicht (BGE 4A_295/2016)

Das Bundesgericht hat in verschiedenen Urteilen die Bedeutung der Zeiterfassungspflicht unterstrichen. Das Urteil BGE 4A_295/2016 bekräftigt die Pflicht des Arbeitgebers zur Arbeitszeiterfassung und die Notwendigkeit, die Einhaltung der Arbeits- und Ruhezeiten zu dokumentieren. Es betont, dass die Zeiterfassung ein wesentliches Instrument zum Schutz der Arbeitnehmer ist [3].

## 2. STAMMDATEN-DELTAS

Für das Zeiterfassungs-Modul sind folgende Stammdaten und Enumerationen (Enums) erforderlich:

### Abwesenheits-Typen

*   Ferien
*   Krank-bezahlt
*   Krank-unbezahlt
*   Unfall
*   Militär
*   Zivildienst
*   Schule/Weiterbildung
*   Mutterschaft
*   Vaterschaft
*   Pflege-Angehörige
*   Kompensation
*   Unbezahlter Urlaub
*   Trauerfall

### Zeit-Kategorien

*   Productive-billable
*   Productive-nonbillable
*   Admin
*   Training
*   Internal-Meeting
*   Client-Meeting
*   Travel
*   Break

### Arbeitszeit-Modelle

*   Vertrauensarbeitszeit
*   Gleitzeit mit Kernzeit
*   Fix-Zeit
*   Teilzeit-%

### Feiertage Kanton ZH

Im Kanton Zürich gelten neun gesetzliche Feiertage, die den Sonntagen gleichgestellt sind [5]. Zusätzlich gibt es weitere Feiertage, die je nach Gemeinde oder Unternehmen als arbeitsfrei gelten können. Für das Jahr 2026 sind dies:

*   1. Januar (Neujahr)
*   2. Januar (Berchtoldstag)
*   Karfreitag
*   Ostermontag
*   1. Mai (Tag der Arbeit)
*   Auffahrt
*   Pfingstmontag
*   1. August (Nationalfeiertag)
*   25. Dezember (Weihnachten)
*   26. Dezember (Stefanstag)

Zusätzlich sind halbe Tage wie Heiligabend (24.12. Nachmittag) und Knabenschiessen (14.09. Nachmittag) zu berücksichtigen [8].

### Pausen-Regeln

*   30 Minuten Pause ab 7 Stunden täglicher Arbeitszeit
*   60 Minuten Pause ab 9 Stunden täglicher Arbeitszeit

## 3. SCHEMA-DELTAS

Die Datenbankstruktur für das Zeiterfassungs-Modul erfordert folgende Tabellen mit den entsprechenden Feldern, Indizes und Constraints:

### `fact_time_entry`

```sql
CREATE TABLE fact_time_entry (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES users(id),
    entry_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    duration_min INT NOT NULL,
    project_id INT REFERENCES projects(id) NULL,
    category VARCHAR(50) NOT NULL,
    billable BOOLEAN NOT NULL,
    approved_by INT REFERENCES users(id) NULL,
    approved_at TIMESTAMP NULL,
    comment TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    audit_trail_jsonb JSONB
);
CREATE INDEX idx_time_entry_user_date ON fact_time_entry (user_id, entry_date);
CREATE INDEX idx_time_entry_project ON fact_time_entry (project_id);
```

### `fact_absence`

```sql
CREATE TABLE fact_absence (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES users(id),
    absence_type_code VARCHAR(50) NOT NULL REFERENCES dim_absence_type(code),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    paid BOOLEAN NOT NULL,
    approved_by INT REFERENCES users(id) NULL,
    doctor_cert_file VARCHAR(255) NULL,
    doctor_cert_uploaded_at TIMESTAMP NULL,
    status VARCHAR(50) NOT NULL, -- e.g., 'pending', 'approved', 'rejected'
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_absence_user_dates ON fact_absence (user_id, start_date, end_date);
```

### `dim_absence_type`

```sql
CREATE TABLE dim_absence_type (
    code VARCHAR(50) PRIMARY KEY,
    label_de VARCHAR(100) NOT NULL,
    paid_default BOOLEAN NOT NULL,
    max_days_per_year INT NULL,
    requires_cert_from_day INT NULL,
    requires_approval BOOLEAN NOT NULL
);
```

### `fact_workday_target`

```sql
CREATE TABLE fact_workday_target (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES users(id),
    year INT NOT NULL,
    target_hours_per_week DECIMAL(4,2) NOT NULL,
    default_break_min INT NOT NULL,
    variant_percent DECIMAL(5,2) NULL, -- e.g., for part-time
    contract_start DATE NOT NULL,
    contract_end DATE NULL,
    UNIQUE (user_id, year)
);
```

### `fact_holiday_cantonal`

```sql
CREATE TABLE fact_holiday_cantonal (
    id SERIAL PRIMARY KEY,
    canton_code VARCHAR(10) NOT NULL, -- e.g., 'ZH'
    holiday_date DATE NOT NULL,
    label_de VARCHAR(100) NOT NULL,
    half_day BOOLEAN NOT NULL DEFAULT FALSE,
    UNIQUE (canton_code, holiday_date)
);
```

### `fact_time_correction`

```sql
CREATE TABLE fact_time_correction (
    id SERIAL PRIMARY KEY,
    original_entry_id INT NOT NULL REFERENCES fact_time_entry(id),
    corrected_by INT NOT NULL REFERENCES users(id),
    reason TEXT NOT NULL,
    old_values_jsonb JSONB NOT NULL,
    new_values_jsonb JSONB NOT NULL,
    approved_by INT REFERENCES users(id) NULL,
    approved_at TIMESTAMP NULL,
    audit_trail_jsonb JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_time_correction_original_entry ON fact_time_correction (original_entry_id);
```

## 4. PROZESS-FLOWS

### Tages-Erfassung

*   **Timer-Start/Stop:** Benutzer kann einen Timer für die aktuelle Tätigkeit starten und stoppen. Die Dauer wird automatisch berechnet.
*   **Nachträgliche manuelle Eintragung:** Manuelle Eingabe von Start- und Endzeiten für vergangene Tätigkeiten.
*   **Projekt-Auswahl:** Auswahl des zugehörigen Projekts aus einer Dropdown-Liste (gespeist aus CRM).
*   **Kategorie:** Auswahl der Zeit-Kategorie (z.B. Productive-billable, Admin).

### Monats-Abschluss

1.  **Mitarbeiter-Submit:** Mitarbeiter reicht seine monatliche Zeiterfassung zur Genehmigung ein.
2.  **Supervisor-Approval:** Vorgesetzter prüft und genehmigt die Zeiterfassung des Mitarbeiters.
3.  **Finale Sperre:** Nach Genehmigung wird der Monat für weitere Änderungen gesperrt.
4.  **Treuhand-Export:** Export der Daten für die Lohnbuchhaltung (Bexio-CSV + Swissdec-ELM-Format).

### Korrektur nach Approval

1.  **Antrag Mitarbeiter:** Mitarbeiter stellt einen Antrag auf Korrektur einer bereits genehmigten und gesperrten Zeiterfassung.
2.  **Re-Approval Teamleiter:** Der Teamleiter prüft den Korrekturantrag und genehmigt oder lehnt ihn ab.
3.  **Audit-Entry:** Alle Korrekturen werden mit einem Audit-Eintrag in `fact_time_correction` protokolliert.

### Urlaubs-Antrag

1.  **Einreichen:** Mitarbeiter reicht einen Urlaubsantrag mit Typ, Zeitraum und Grund ein.
2.  **Approval Teamleiter:** Vorgesetzter prüft und genehmigt den Urlaubsantrag.
3.  **Kalender-Sync:** Genehmigte Abwesenheit wird automatisch in den Team-Kalender eingetragen.

### Krankmeldung

*   **Selbst-Meldung (bis 3 Tage):** Mitarbeiter meldet sich selbst krank für bis zu 3 Tage.
*   **Arztzeugnis (ab 3. Tag):** Ab dem 3. Krankheitstag ist ein Arztzeugnis erforderlich, das hochgeladen werden kann.

### Überzeit-Kompensation

*   **Auszahlung:** Antrag auf Auszahlung von Überzeit durch Teamleiter und Geschäftsführung.
*   **Zeit-Ausgleich (Self-Service):** Mitarbeiter kann Überzeit selbstständig durch Freizeit kompensieren, wenn weniger als 10 Stunden Überzeit bestehen.

### Feiertags-Behandlung

*   **Anteilige Anrechnung bei Teilzeit:** Bei Teilzeitmitarbeitern werden Feiertage anteilig an die Sollarbeitszeit angerechnet.

## 5. BUSINESS-LOGIC

### Stunden-Saldo-Berechnung

*   **Soll-Stunden:** Basierend auf `fact_workday_target` (Wochenarbeitszeit, Jahresarbeitszeit, Teilzeit-%).
*   **Ist-Stunden:** Summe der `duration_min` aus `fact_time_entry`.
*   **Abwesenheiten:** Berücksichtigung von Abwesenheiten (Ferien, Krankheit etc.) aus `fact_absence`.
*   **Feiertage:** Anrechnung von Feiertagen aus `fact_holiday_cantonal`.

### Überzeit-Schwelle

*   **>45h/Woche:** Arbeitszeit über 45 Stunden pro Woche gilt als Überzeit (ArG Art. 9) und ist entsprechend zu entschädigen oder zu kompensieren.
*   **>60h/Woche:** Arbeitszeit über 60 Stunden pro Woche ist illegal und löst einen Alert aus.

### Pflicht-Pausen-Validierung

*   Automatische Validierung der Einhaltung der gesetzlichen Pausenregelungen (30 Minuten ab 7 Stunden, 60 Minuten ab 9 Stunden täglicher Arbeitszeit).

### Ferien-Verjährung (OR Art. 329a)

*   Ferienansprüche verjähren in der Regel nach fünf Jahren.

### Ferien-Übertrag

*   Maximal 5 Tage Ferienübertrag ins Folgejahr (konfigurierbare Firmenregel).

### Krank-Anspruch Bern-Skala

*   Lohnfortzahlung bei Krankheit gemäss Berner Skala (siehe Section 1).

### State-Machine Time-Entry

*   **draft:** Initialer Zustand, Eintrag kann bearbeitet werden.
*   **submitted:** Eintrag zur Genehmigung eingereicht, kann nicht mehr vom Mitarbeiter bearbeitet werden.
*   **approved:** Eintrag vom Vorgesetzten genehmigt.
*   **locked:** Monatlich gesperrt, keine weiteren Änderungen möglich.
*   **corrected:** Nach Korrekturantrag und Genehmigung, mit Audit-Historie.

## 6. UI-ARCHITEKTUR

Die Benutzeroberfläche des Zeiterfassungs-Moduls wird sich an den bestehenden CRM-Mockups orientieren (540px-Drawer als Default, Editorial-Serif-Style mit Libre Baskerville + DM Sans, 9-Stage-Prozess-Pipeline).

### Screen-Inventory

*   **Dashboard:**
    *   Hero-KPIs: Wochen-Saldo, Monats-Soll/Ist, Ferien-Rest, Abwesenheiten Team.
    *   Timer-Widget: Start/Stop-Funktion für die Zeiterfassung.
    *   Nächster Feiertag.
*   **Tages-Erfassung:**
    *   Aktive Woche und Kalender-Navigation.
    *   Projekt-Dropdown, Inline-Edit für Einträge.
    *   Bulk-Copy-Funktion für den gestrigen Tag.
*   **Monats-Übersicht:**
    *   Tabelle mit Tag/Soll/Ist/Diff/Status.
    *   Export-Funktion.
*   **Abwesenheits-Kalender:**
    *   Monats-Grid-Ansicht mit Mitarbeiter-Zeilen.
    *   Abwesenheitstypen farblich markiert.
    *   Klick auf Eintrag öffnet Drawer mit Details.
*   **Antrags-Liste:**
    *   Übersicht über offene Genehmigungsanträge für Teamleiter und Geschäftsführung.
*   **Saldi-Ansicht:**
    *   Übersicht über Ferien-Konto, Überzeit-Konto, Krank-Konto.
*   **Admin-Module:**
    *   Verwaltung von Arbeitszeit-Modellen.
    *   Feiertage-Editor.
    *   Mitarbeiter-Verträge.

### Drawer-Inventory (540px Default)

*   **Tages-Eintrag-Edit:** Felder für Datum, Start, Ende, Pause, Projekt, Kategorie, Billable, Kommentar.
*   **Urlaubs-Antrag:** Felder für Typ, Von, Bis, Halbtag, Grund. Automatische Berechnung der Arbeitstage.
*   **Krank-Meldung:** Felder für Von, Bis, Arztzeugnis-Upload, Bemerkung.
*   **Korrektur-Antrag:** Formular mit Diff-Preview der Änderungen.
*   **Monats-Abschluss-Confirm:** Modal (420px) zur atomaren Sperre des Monats.

### Navigation

*   **Sidebar-Module:** Gleiches 56/240px-Pattern wie CRM.
    *   Dashboard
    *   Meine Zeit
    *   Abwesenheiten
    *   Team
    *   Saldi
    *   Admin

## 7. ROLLEN-MATRIX

| Feature                   | Mitarbeiter (MA) | Teamleiter (TL) | Geschäftsführung (GF) | Backoffice | Admin |
| :------------------------ | :--------------- | :-------------- | :-------------------- | :--------- | :---- |
| Eigene Zeit erfassen      | ✓                | ✓               | ✓                     | ✓          | ✓     |
| Eigene Abwesenheit        | ✓                | ✓               | ✓                     | ✓          | ✓     |
| Team-Zeit sehen           | –                | ✓               | ✓                     | ✓          | ✓     |
| Team-Zeit approven        | –                | ✓               | ✓                     | –          | –     |
| Monats-Abschluss auslösen | –                | –               | ✓                     | ✓          | –     |
| Treuhand-Export           | –                | –               | ✓                     | ✓          | –     |
| Arbeitszeit-Modell ändern | –                | –               | ✓                     | –          | ✓     |
| Feiertage editieren       | –                | –               | –                     | –          | ✓     |
| Korrektur nach Lock       | –                | –               | ✓                     | –          | –     |

*Hinweis: Die Matrix kann je nach spezifischen Anforderungen und Unternehmensstruktur erweitert werden.*

## 8. INTEGRATIONEN

### CRM-Integration

*   **Projekt-Dropdown:** Das Projekt-Dropdown in der Zeiterfassung speist sich aus der `fact_process_core` des bestehenden CRM-Systems. Es werden nur aktive Projekte angezeigt.
*   **`time_entry.project_id` FK:** Die `project_id` in `fact_time_entry` ist ein Fremdschlüssel zur Projekt-Tabelle im CRM.

### Commission-Engine

*   **ZEG-Staffel-Berechnung:** Die Commission-Engine nutzt aggregierte Daten aus `fact_time_entry` pro Mandat für die Berechnung der ZEG-Staffel (Zeit-Einsatz-Grad). Ein Aufruf-Trigger für die Commission-Recalculation wird implementiert.

### Email/Kalender

*   **Urlaubs-Approval:** Bei Genehmigung eines Urlaubsantrags wird eine E-Mail an den Mitarbeiter und das Team gesendet.
*   **Abwesenheit im Team-Kalender:** Genehmigte Abwesenheiten werden als ganztägige Ereignisse in den Team-Kalender eingetragen.

### Treuhand Kunz

*   **CSV-Export Monats-Ende:** Export der monatlichen Stunden- und Abwesenheitsdaten in einem spezifischen CSV-Format für Treuhand Kunz. Das Schema umfasst: Mitarbeiter-Nr, Monat, Soll, Ist, Ferien, Krank, Unfall, Überzeit.
*   **Swissdec-ELM-Format:** Bei zukünftiger direkter Lohnbuchhaltung wird ein Export im Swissdec-ELM-Format unterstützt.

### Bexio

*   **Optionaler Stunden-Sync:** Optionaler Synchronisation der erfassten Stunden für die Projekt-Abrechnung in Bexio.

### Mobile/PWA

*   **Timer + schnelle Eintragung:** In einer späteren Phase (Phase 3.5) ist die Entwicklung einer Mobile/PWA-Anwendung für Timer-Funktionalität und schnelle Zeiteinträge geplant.

## 9. OPEN QUESTIONS

Zur Klärung und weiteren Detaillierung des Zeiterfassungs-Moduls sind folgende offene Fragen zu beantworten:

1.  **Arbeitszeit-Modell Default:**
    *   (a) Vertrauensarbeitszeit
    *   (b) Gleitzeit mit Kernzeit 09:00-15:00
    *   (c) Mix je Rolle?
2.  **Soll-Ist-Auflösung:**
    *   (a) Minute
    *   (b) 15-Minuten-Block
    *   (c) Stunde?
3.  **Überzeit-Cap:**
    *   (a) 45h/Woche strikt
    *   (b) 50h mit Signoff Teamleiter
    *   (c) Jahres-Saldo prüfen?
4.  **Ferien-Übertrag:**
    *   (a) max. 5 Tage
    *   (b) unlimitiert bis Dezember
    *   (c) Verfall 31.3.?
5.  **Approval-Zyklus:**
    *   (a) wöchentlich
    *   (b) monatlich
    *   (c) ad-hoc?

## 10. RISIKEN & GRAUZONEN

### Vertrauensarbeitszeit-Grauzone

Obwohl die vereinfachte Erfassung gemäss Art. 73a ArGV 1 für Positionen ab CHF 120'000 zulässig ist, wird eine Dokumentation der Arbeitszeiten weiterhin empfohlen, um im Streitfall Nachweise erbringen zu können.

### Art. 73b ArGV 1 vereinfachte Erfassung

Die vereinfachte Erfassung erfordert eine schriftliche Vereinbarung zwischen Mitarbeiter und Arbeitgeber. Es muss sichergestellt werden, dass diese Vereinbarungen korrekt und rechtskonform vorliegen.

### Teilzeit-Aufrechnung bei Kündigungsschutz (OR Art. 324a)

Bei Teilzeitmitarbeitern und Schwankungen im Beschäftigungsgrad muss die korrekte Berechnung der Lohnfortzahlung im Krankheitsfall und des Kündigungsschutzes gemäss OR Art. 324a sichergestellt werden.

### Ferien bei Rechtszeit-Schwankungen

Die anteilige Berechnung des Ferienanspruchs bei Dienstjahr-Schwankungen oder Änderungen des Beschäftigungsgrades muss präzise erfolgen.

### Datenschutz: Standort-Daten (Mobile-Timer)?

Bei der Implementierung eines Mobile-Timers muss der Umgang mit Standortdaten (falls erhoben) datenschutzkonform erfolgen und die Zustimmung der Mitarbeiter eingeholt werden.

### Audit-Trail-Aufbewahrung (ArG Art. 73 Abs. 2)

Der Audit-Trail für Zeiterfassungsdaten muss gemäss ArG Art. 73 Abs. 2 für mindestens 5 Jahre aufbewahrt werden, um die gesetzlichen Anforderungen zu erfüllen.

## References

[1] Arbeitszeiterfassung - SECO - Der Bundesrat. [https://www.seco.admin.ch/seco/de/home/Arbeit/Arbeitsbedingungen/Arbeitnehmerschutz/Arbeits-und-Ruhezeiten/Arbeitszeiterfassung.html](https://www.seco.admin.ch/seco/de/home/Arbeit/Arbeitsbedingungen/Arbeitnehmerschutz/Arbeits-und-Ruhezeiten/Arbeitszeiterfassung.html)
[2] ArGV 1 Artikel 73: Verzeichnisse und andere Unterlagen. [https://www.seco.admin.ch/dam/seco/de/dokumente/Arbeit/Arbeitsbedingungen/Arbeitsgesetz%20und%20Verordnungen/Wegleitungen/Wegleitungen%201/ArGV1_art73.pdf.download.pdf/ArGV1_art73_de.pdf](https://www.seco.admin.ch/dam/seco/de/dokumente/Arbeit/Arbeitsbedingungen/Arbeitnehmerschutz/Arbeits-und-Ruhezeiten/ArGV1_art73_de.pdf)
[3] Die Neuregelung der Arbeitszeiterfassungspflicht. [https://www.trex.ch/die-neuregelung-der-arbeitszeiterfassungspflicht/](https://www.trex.ch/die-neuregelung-der-arbeitszeiterfassungspflicht/)
[4] Arbeitszeiterfassung Schweiz: Gesetz, Pflicht und. [https://timestatement.com/schweiz/arbeitszeiterfassung-gesetzliche-vorgaben](https://timestatement.com/schweiz/arbeitszeiterfassung-gesetzliche-vorgaben)
[5] Feiertage | Kanton Zürich. [https://www.zh.ch/de/wirtschaft-arbeit/arbeitsbedingungen/arbeitsssicherheit-gesundheitsschutz/arbeits-ruhezeiten/feiertage.html](https://www.zh.ch/de/wirtschaft-arbeit/arbeitsbedingungen/arbeitsssicherheit-gesundheitsschutz/arbeits-ruhezeiten/feiertage.html)
[6] Was Sie über Artikel 46 des Arbeitsgesetzes wissen müssen. [https://www.kelio.ch/de/support/blog/389-arbeitszeiterfassung-recht-arg-artikel-46.html](https://www.kelio.ch/de/support/blog/389-arbeitszeiterfassung-recht-arg-artikel-46.html)
[7] Berner Skala Schweiz 2026: Lohnfortzahlung & Versicherung. [https://magicheidi.ch/de/bernese-scale](https://magicheidi.ch/de/bernese-scale)
[8] Feiertage und Betriebsferientage. [https://www.stadt-zuerich.ch/de/politik-und-verwaltung/arbeiten-bei-der-stadt/gut-zu-wissen/ferien-urlaub/feiertage-betriebsferientage-bft.html](https://www.stadt-zuerich.ch/de/politik-und-verwaltung/arbeiten-bei-der-stadt/gut-zu-wissen/ferien-urlaub/feiertage-betriebsferientage-bft.html)
