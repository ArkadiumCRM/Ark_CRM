# ARK CRM — Assessment-Detailmaske Interactions Spec v0.1

**Stand:** 13.04.2026
**Status:** Erstentwurf — Review ausstehend
**Kontext:** Definiert Verhalten, CRUD-Flows, State-Machine, Automationen und Events für die Assessment-Detailseite (`/assessments/[id]`). Credits-basiertes Auftragsmodell gemäss Entscheidung 2026-04-13.
**Begleitdokument:** `ARK_ASSESSMENT_DETAILMASKE_SCHEMA_v0_1.md` (Layout, Felder, Design)
**Vorrang:** Stammdaten > dieses Dokument > Schema > Mockups
**Globale Patterns:** 11 Global Patterns aus Kandidaten-Interactions v1.2

---

## TEIL 0: STRUKTURELLE GRUNDENTSCHEIDUNGEN

### Tab-Struktur

| # | Tab | Inhalt |
|---|-----|--------|
| 1 | Übersicht | Auftragsdaten, Credits, Preis, Status, Verknüpfungen |
| 2 | Durchführungen | `fact_assessment_run` — Liste mit Kandidat-Zuweisungen |
| 3 | Billing | `fact_assessment_billing` — meist 1 Zeile + Spesen |
| 4 | Dokumente | Offerte, Executive Summaries, Detail-Reports, Rechnungen |
| 5 | History | Event-Stream |

5 Tabs, keine konditionalen.

### Credits-Prinzip

- **Auftrag = gekauftes Paket mit N Credits** (analog Gutschein)
- Credits werden durch **Zuweisung an Kandidaten** (Runs) verwendet
- Solange ein Credit noch nicht `completed` ist, kann der Kandidat **umgewidmet** werden (Tausch)
- Pauschalpreis sofort bei Unterschrift fällig — unabhängig davon wann Credits eingelöst werden
- Credits können theoretisch beliebig lange liegen bleiben (Phase 1: kein Verfall; Phase 2: optional `credits_expiry_date`)

### Erstellungs-Orte

Ein Assessment-Auftrag wird erstellt **nur** über zwei Wege:
1. **Account-Detailseite Tab 8 "Assessments"** → Button "+ Neues Assessment" / "🧭 Assessment beauftragen" (Header Quick-Action) — eigenständig
2. **Mandat-Detailseite Tab 1 "Übersicht"** → Sektion 6b Optionale Stages → Option IX buchen — mandatsbezogen

Nicht direkt aus `/assessments`-Liste erstellbar (die Liste ist nur Übersicht über alle).

---

## TEIL 1: HEADER & GLOBALE ACTIONS

### Status-Dropdown (Titel-Zeile)

| Von | Nach | Trigger | Validierung |
|-----|------|---------|-------------|
| Offered | Ordered | Upload unterschriebene Offerte (Tab 4) | Pflicht: `signed_document_id` gesetzt |
| Ordered | Partially Used | Erster Credit → `completed` | Auto |
| Partially Used | Fully Used | Letzter Credit → `completed` | Auto |
| Fully Used | Invoiced | Alle Billing-Zeilen bezahlt | Auto + manueller Confirm |
| Ordered / Partially Used | Cancelled | Manuell (AM/Admin) mit Confirm-Dialog | Pflicht: Begründung |

**Manuelle Status-Änderungen auf Invoiced und Cancelled** öffnen Confirm-Dialog. Alle anderen sind Auto.

### Quick-Action-Regeln

| Action | Sichtbar wenn |
|--------|---------------|
| 📄 Offerte generieren | Status = Offered UND keine Offerte existiert |
| 📄 Offerte ansehen | Unterschriebene Offerte existiert |
| 📤 Report übertragen | Mind. 1 Run mit Status `scheduled` oder `in_progress` |
| ➕ Credit zuweisen | `credits_frei > 0` UND Status ∈ {Ordered, Partially Used} |

### Snapshot-Bar (Live-Update)

Werte werden via Websocket/Server-Push aktualisiert wenn sich `fact_assessment_run`-Status ändert. Progress-Bar animiert beim Verbrauch eines Credits.

### Cancellation

Wenn Auftrag storniert wird (selten):
1. Alle noch nicht durchgeführten Runs werden automatisch auf `cancelled_reassignable` gesetzt (eigentlich: `cancelled` für den Order-Scope)
2. Bezahlter Betrag: **kein automatischer Refund** — Kulanz-Entscheidung by Admin
3. Credits-Modell bedeutet: Stornierung ist für Kunden unattraktiv, weil der Betrag sowieso bezahlt wurde. Normalerweise erfolgt Umwidmung statt Storno.
4. Event `assessment_order_cancelled` im History

---

## TEIL 2: TAB 1 — ÜBERSICHT

### Edit-Verhalten

**Vor Status `Ordered`:**
- `credits_total`, `price_chf`, `package_type`, `partner`, `notes` sind inline-editierbar
- Änderungen sofort in DB (auto-save pro Feld)

**Ab Status `Ordered`:**
- Edit gesperrt für `credits_total`, `price_chf`, `package_type` — Read-only mit Lock-Icon 🔒
- Warum: Rechnung ist raus, Credits-Kontingent ist fix
- Weiterhin editierbar: `notes`, `partner`, `credits_expiry_date`

**Ausnahme:** Admin kann auch nach `Ordered` alles editieren (für Korrektur-Fälle) — mit Audit-Log-Eintrag.

### Mandat-Verknüpfung ändern

- Verknüpfung zu Mandat kann **nicht** nachträglich gesetzt/entfernt werden nach `Ordered` — zu viele Folgewirkungen (Option IX in Mandat, Rechnungs-Zuordnung)
- Korrektur nur via Admin-Override

### Preis-Berechnung "pro Credit"

Info-only: `price_chf / credits_total` wird angezeigt, aber **nicht gespeichert**. Reines Display für Transparenz.

---

## TEIL 3: TAB 2 — DURCHFÜHRUNGEN (KERN)

### Run-Erstellung (Credit zuweisen)

1. Button "➕ Credit zuweisen" → Drawer
2. Kandidat-Autocomplete:
   - Pool: alle Kandidaten im CRM (nicht nur Kontakte des Accounts — Assessments können auch für bereichsfremde Personen bestellt werden)
   - Default-Sortierung: Kontakte dieses Accounts zuerst
3. **Kein Match:** Hard-Stop → "Als Kandidat anlegen" (Link zum Kandidaten-Erstellungs-Flow, nach Speichern Rückkehr zum Drawer mit vorbefülltem Match)
4. **Duplikat-Check:** Query `fact_assessment_run WHERE assessment_order_id = X AND kandidat_id = Y AND status != 'cancelled_reassignable'`
   - Wenn Eintrag existiert: Warnung (nicht-blockierend) *"Diese Person hat bereits einen aktiven Credit in diesem Auftrag"*
5. Optional: Termin setzen im gleichen Drawer (DateTime-Picker)
6. "Zuweisen" → `INSERT fact_assessment_run (...)` mit `status='assigned'` (oder `scheduled` falls Termin gesetzt)
7. Auto-Aktionen:
   - `fact_history` Event `assessment_credit_assigned` — am Kandidaten, am Account, am Auftrag
   - Wenn `mandate_id` am Auftrag: auch am Mandat
   - Notification an Kandidat-Manager (CM) des Accounts

### Kandidat ersetzen (Umwidmung)

Nur wenn Run-Status ∈ {`assigned`, `scheduled`}.

1. Im Run-Drawer: "Kandidat ersetzen" → Confirm-Dialog
2. Neue Kandidaten-Suche (wie bei Zuweisung)
3. Bestätigen:
   - `reassigned_from_kandidat_id = current kandidat_id`
   - `kandidat_id = new`
   - `reassigned_at = now`, `reassigned_by = current_user`
4. Events:
   - Am alten Kandidaten: `assessment_credit_reassigned_away`
   - Am neuen Kandidaten: `assessment_credit_reassigned_to`
   - Am Auftrag: `run_reassigned`

**Wichtig:** Run-ID bleibt erhalten — keine neue Row. Audit-Trail über `reassigned_from_*` Felder.

### Termin setzen / ändern

- Inline-DateTime-Picker im Run-Drawer
- Setzen: Status → `scheduled`, `scheduled_at = value`
- Ändern: `scheduled_at = new_value`, Event `run_rescheduled`
- Wenn Termin entfernt (null): Status zurück auf `assigned`

### Report übertragen (Completion)

Trigger: Header-Button "📤 Report übertragen" ODER Run-Drawer "Als durchgeführt markieren".

**Drawer:**
1. Run wählen (Dropdown, bereits vorausgewählt wenn aus Run-Drawer aufgerufen)
2. `completed_at` DateTime-Picker (Default: heute)
3. Upload **Executive Summary** (Pflicht, PDF)
4. Upload **Detail-Report** (optional, SCHEELEN-Anhang ~100 Seiten PDF)
5. Auswahl der Assessment-Typen die beim Kandidaten aktualisiert werden (Checkboxen: DISC / EQ / Scheelen 6HM / Outmatch / Driving Forces)
6. Bestätigen → Auto-Aktionen:

```
BEGIN TRANSACTION
  UPDATE fact_assessment_run
    SET status = 'completed', completed_at = ..., result_version_id = NEW_VERSION_ID
    WHERE id = run_id;

  INSERT fact_candidate_assessment_version (
    kandidat_id = run.kandidat_id,
    assessment_order_id = run.assessment_order_id,
    version_number = MAX(version)+1,
    disc_data, eq_data, scheelen_data, outmatch_data, driving_forces_data,
    executive_summary_doc_id, detail_report_doc_id,
    created_at = now, created_by = current_user
  );

  UPDATE fact_assessment_order
    SET credits_used = credits_used + 1,
        status = CASE WHEN credits_used+1 = credits_total THEN 'fully_used' ELSE 'partially_used' END;

  INSERT fact_history events:
    - 'assessment_run_completed' (am Kandidaten + Account + Auftrag + Mandat if linked)
    - 'assessment_version_created' (am Kandidaten)
COMMIT
```

Versioning im Kandidaten bleibt kompatibel mit bestehendem Assessment-Tab-Schema — jede Durchführung erzeugt eigene Version, Pfeil-Navigation möglich.

### Credit freigeben (Abbruch ohne Tausch)

Run-Drawer "Abbrechen & Credit freigeben":
1. Confirm mit Begründungs-Pflichtfeld
2. `status = 'cancelled_reassignable'`, `cancelled_at`, `cancellation_reason`
3. Credit wird wieder "frei" — kann neu zugewiesen werden
4. `credits_total` bleibt unverändert; `credits_cancelled_reassignable` Zähler erhöht
5. Event `assessment_run_cancelled`

### Validierungs-Regeln

| Regel | Enforcement |
|-------|------------|
| `credits_used + active_runs <= credits_total` | Hard, bei Zuweisung geprüft |
| Kandidat zuweisen erfordert `kandidat_id` existiert | Hard |
| `scheduled_at` nicht in Vergangenheit setzbar | Soft (Warn, nicht Block — Legacy-Daten OK) |
| `completed_at >= scheduled_at` falls beide gesetzt | Hard |
| Report-Upload bei `completed` erfordert Executive Summary | Hard |

---

## TEIL 4: TAB 3 — BILLING

### Auto-Trigger bei Status-Wechsel

**Offered → Ordered:**
1. `INSERT fact_assessment_billing` mit:
   - `billing_type = 'full'`
   - `amount_chf = fact_assessment_order.price_chf`
   - `due_date = ordered_at + payment_terms_days` (Default 10)
   - `status = 'pending'`
2. Event `invoice_generated` am Auftrag + Account

### Rechnungs-Erstellung (manuell via Drawer)

1. Klick auf Zeile "Rechnung erstellen"
2. Drawer:
   - Rechnungsnummer (auto-generiert: `FN[YYYY].[MM].[NNNN]` oder manuell)
   - Rechnungsdatum (Default: heute)
   - Fälligkeitsdatum (Default: heute + Zahlungsziel)
   - PDF-Upload (oder "Template rendern" → Auto-PDF aus `Vorlage_Rechnung_Diagnostics & Assessment.docx`)
3. Speichern → `status = 'invoiced'`, `invoice_number`, `invoice_date` gesetzt, `pdf_document_id` wenn Upload/Render
4. Dokument landet im Tab 4 unter Kategorie "Rechnung"

### Als bezahlt markieren

Zeile → "Als bezahlt markieren" → Confirm → `paid_at = now`, `status = 'paid'`.

### Spesen hinzufügen

Button "+ Spesen-Position":
1. Drawer: Betrag, Beleg-Datum, Beschreibung, Beleg-PDF-Upload
2. `INSERT fact_assessment_billing (billing_type = 'expense', ...)`
3. Dokument landet im Tab 4 unter Kategorie "Spesenbelege"

### Überfällig-Logik

Nightly Batch-Job: `status = 'invoiced' AND due_date < today AND paid_at IS NULL` → `status = 'overdue'` + Notification an AM + Admin.

---

## TEIL 5: TAB 4 — DOKUMENTE

### Offerten-Generator

Button "📄 Offerte generieren" (nur Status = Offered + keine Offerte existiert):
1. Template `Vorlage_Offerte Diagnostik & Assessment.docx` wird gerendert
2. Felder auto-befüllt: Account, Package, Credits, Preis, Partner, Datum
3. Vorschau-Drawer mit Edit-Möglichkeit (Textarea für freie Passagen)
4. "PDF erstellen" → PDF im Tab 4 unter Kategorie "Offerte" (Version 1)

### Unterschriebene Offerte Upload

Upload unter Kategorie "Offerte" mit Flag "unterschrieben":
1. Validierung: ist es eine PDF?
2. Auto-Trigger: Status `Offered → Ordered` mit Confirm-Dialog (um nicht versehentlich zu aktivieren)
3. `signed_document_id` am Auftrag gesetzt
4. Billing-Zeile `full` wird erstellt (siehe TEIL 4)

### Executive Summary Upload (pro Run)

Aus Report-Upload-Flow (siehe TEIL 3). Dokument automatisch verknüpft zu `fact_assessment_run.result_version_id`.

### Dokument-Versionierung

- Offerte: V1 (generiert) + V2 (unterschrieben) — beide bleiben
- Executive Summary pro Run: V1, bei Re-Upload V2 (mit Begründung im Drawer)
- Rechnung: V1, bei Storno/Korrektur V2 (Phase 1.5)

---

## TEIL 6: TAB 5 — HISTORY

### Event-Typen (assessment-spezifisch)

| Event | Trigger | Scope |
|-------|---------|-------|
| `assessment_order_created` | Order erstellt (Status = Offered) | Account + Order |
| `assessment_order_signed` | Offerte unterschrieben hochgeladen | Account + Order (+ Mandat) |
| `assessment_credit_assigned` | Run erstellt | Kandidat + Account + Order |
| `assessment_credit_reassigned_away` | Umwidmung | Alter Kandidat |
| `assessment_credit_reassigned_to` | Umwidmung | Neuer Kandidat |
| `assessment_run_scheduled` | Termin gesetzt | Kandidat + Account + Order |
| `assessment_run_completed` | Report hochgeladen | Kandidat + Account + Order (+ Mandat) |
| `assessment_run_cancelled` | Credit freigegeben | Kandidat + Account + Order |
| `assessment_version_created` | Kandidat-Assessment-Version erstellt | Kandidat |
| `assessment_order_cancelled` | Auftrag storniert | Account + Order |
| `assessment_invoice_generated` | Rechnung erstellt | Account + Order |
| `assessment_invoice_paid` | Rechnung bezahlt | Account + Order |

### Doppelspur-Regel

Jedes Run-Event wird **am Kandidaten UND am Account** geloggt. Der Account sieht *"Assessment für Max Muster abgeschlossen"*, der Kandidat sieht *"Assessment im Auftrag von Volare Group durchgeführt"*.

---

## TEIL 7: VERKNÜPFUNGEN

### Zum Account

- Auftrag ist immer an genau **einen Account** gebunden (`account_id` NOT NULL)
- Account kann N Aufträge haben (siehe Account-Detailseite Tab 8)
- Teamrad (Account Tab 5 Subtab) aggregiert alle `completed` Runs dieses Accounts

### Zum Kandidaten

- Auftrag kann **N Kandidaten** haben (via `fact_assessment_run`)
- Kandidat kann **N Aufträge** haben (Wiederholungs-Assessments, verschiedene Kunden)
- Im Kandidaten-Assessment-Tab: Versionen werden verknüpft mit `assessment_order_id` — Nutzer sieht *"Version 2 — via Auftrag AS-2026-042 (Volare Group)"*

### Zum Mandat

- Optional: `mandate_id` NOT NULL nur wenn Option IX gebucht
- Wenn gesetzt: erscheint in Mandat Tab 1 Sektion 6b Optionale Stages + Tab 6 Dokumente
- Mandat-Kündigung → offene Assessment-Runs bleiben bestehen (nicht auto-cancelled), aber Banner "Zugehöriges Mandat wurde gekündigt — mit Kunde klären"

---

## TEIL 8: CREDITS-ÖKONOMIE (EDGE CASES)

### Überschiessende Zuweisungen

Wenn AM versucht einen Credit zu vergeben obwohl `credits_total == credits_used + active_runs`:
- Button "+ Credit zuweisen" ist disabled
- Tooltip: *"Keine freien Credits mehr. Upgrade auf grösseren Auftrag oder neuer Auftrag erforderlich."*

### Credit-Tausch innerhalb desselben Auftrags

Szenario: Credit war an Person A zugewiesen (scheduled), wird dann an Person B umgewidmet → A ist wieder "frei" für andere Anwendung, aber **im Rahmen des gleichen Credits**, nicht als neuer Credit.

**Umsetzung:** "Umwidmung" ändert `kandidat_id` am Run direkt — kein Freigeben + Neu-Zuweisen nötig.

### Nicht genutzte Credits

- **Credits verfallen nicht** (Entscheidung 2026-04-13, Peter)
- Kein Verfalls-Datum, keine Warn-Notifications, keine Kulanz-Verlängerung nötig
- Gilt dauerhaft (weder Phase 1 noch spätere Phasen)

### Upgrade / Downgrade eines Auftrags

Nicht in Phase 1. Wenn Kunde mehr Credits braucht: neuer Auftrag. Wenn weniger: Kulanz-Teil-Refund durch Admin (manueller Prozess).

### Multi-Mandat-Zuordnung

**Offen (Klärung mit Peter):** Aktuell `mandate_id` als Single-FK. Theoretisch könnten Credits eines Auftrags auf mehrere Mandate verteilt werden. Meine Neigung: Nein — 1 Auftrag = 1 Mandat oder eigenständig. Bei Multi-Mandat → separate Aufträge.

---

## TEIL 9: BERECHTIGUNGEN (Spezialfälle)

Ergänzend zur Matrix in Schema § 12:

### Admin-Override

Admin kann ausnahmsweise:
- `price_chf` nach `Ordered` ändern (Korrektur-Fälle)
- `credits_total` erhöhen (freier Kulanz-Bonus)
- Abweichende Befugnisse loggen sich mit `fact_audit_log.override_reason = 'admin_override'`

### Read-only für CM

CM sieht Tab 1 + 2 + 5, aber keine Billing-Details (Preise in Snapshot-Bar werden für CM maskiert: "— CHF").

### Kandidat-Daten

Innerhalb des Assessment-Auftrags werden **keine Kandidaten-Stammdaten editiert** — das bleibt strikt im Kandidaten-Profil. Hier nur Zuweisung/Umwidmung.

---

## TEIL 10: PHASE 1.5 / PHASE 2 VORMERKLISTE

| Feature | Phase |
|---------|-------|
| Anzahlungs-Modell (`deposit` + `final`) | 1.5 |
| ~~Credits-Verfall~~ | — (entfernt, Entscheidung 2026-04-13) |
| Multi-Kandidat-Batch-Zuweisung (z.B. 5 Credits auf einmal) | 1.5 |
| SCHEELEN-API-Integration (Auto-Report-Import) | 2 |
| Kalender-Sync Outlook/Google für `scheduled_at` | 2 |
| Vergleichs-View zwischen Runs eines Kandidaten (Re-Tests) | 2 |
| Bulk-Import Assessment-Rohdaten (Excel) | 2 |
| Upgrade/Downgrade Auftrag (Credits mid-flight anpassen) | 2 |

---

## TEIL 11: METHODIK-REFERENZ

Dieses Dokument folgt den gleichen Methodik-Prinzipien wie Kandidat-/Mandat-/Account-Interactions:
- Globale Patterns aus Kandidaten-Interactions v1.2 TEIL 0 gelten
- Event-System wie in [[event-system]]
- Berechtigungen wie in [[berechtigungen]]

---

## Related Specs / Wiki

- `ARK_ASSESSMENT_DETAILMASKE_SCHEMA_v0_1.md` (Begleitdokument)
- `ARK_ACCOUNT_DETAILMASKE_INTERACTIONS_v0_2.md` TEIL 8b (Assessment-Beauftragung am Account)
- `ARK_MANDAT_DETAILMASKE_INTERACTIONS_v0_2.md` TEIL 2b (Option IX am Mandat)
- `ARK_KANDIDATENMASKE_INTERACTIONS_v1_2.md` (Assessment-Tab Versionierung)
- [[diagnostik-assessment]], [[offerte-diagnostik]]
- [[detailseiten-guideline]]
