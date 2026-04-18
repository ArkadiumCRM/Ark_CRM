# ARK CRM — Assessment-Detailmaske Interactions Spec v0.3

**Stand:** 17.04.2026 (Sync-Update von v0.2)
**Status:** Sync-Patch v0.2 → v0.3 — Review ausstehend
**Kontext:** Verhalten, CRUD-Flows, State-Machine, Automationen und Events für Assessment-Detailseite (`/assessments/[id]`). Typisiertes Credits-Modell gemäss Entscheidung 2026-04-14.
**Begleitdokument:** `ARK_ASSESSMENT_DETAILMASKE_SCHEMA_v0_2.md` → v0.3 (Begleit-Sync)
**Vorrang:** Stammdaten > dieses Dokument > Schema > Mockups
**Globale Patterns:** 11 Global Patterns aus Kandidaten-Interactions v1.2

## Changelog v0.2 → v0.3 (17.04.2026)

| # | Änderung | Sektion | Grund |
|---|----------|---------|-------|
| 1 | **Order-Status-Übergang `Fully Used → Invoiced` entfernt** | TEIL 1 Status-Dropdown-Tabelle | Order kennt kein `invoiced` mehr (siehe Schema v0.3 Changelog). Rechnungs-State lebt auf `fact_assessment_billing.status`. |
| 2 | **"Manuelle Status-Änderungen auf Invoiced und Cancelled"** → "Manuelle Status-Änderungen auf Cancelled" | TEIL 1 nach Status-Tabelle | Konsistenz mit Schema v0.3. |

**Hinweis:** Billing-spezifische `invoiced`-Referenzen in TEIL 4 (`fact_assessment_billing.status = 'invoiced'`) **bleiben unverändert** — Billing-Level-Status (pending/invoiced/paid/overdue) ist korrekt und nicht Teil des Sync-Patches.

## Changelog v0.1 → v0.2

| # | Änderung | Sektion |
|---|----------|---------|
| 1 | **Typisierte Credits** (MDI/Relief/ASSESS 5.0/DISC/EQ/...) via `fact_assessment_order_credits` Bridge | TEIL 0, TEIL 3, TEIL 5 |
| 2 | Credit-Zuweisungs-Drawer: Typ-Pflichtfeld zuerst | TEIL 3 |
| 3 | Umwidmung nur **innerhalb gleichen Typs** (kein MDI → Relief Wechsel) | TEIL 3 |
| 4 | Report-Upload: Typ auto aus Run, keine Typ-Auswahl mehr im Drawer | TEIL 5 |
| 5 | `dim_assessment_types` Stammdaten-Tabelle (Katalog) | TEIL 0, TEIL 11 |
| 6 | `used_count` wird pro Typ-Zeile in `fact_assessment_order_credits` getrackt | TEIL 3, TEIL 5 |
| 7 | Versionierungs-Tabelle `fact_candidate_assessment_version` als zentrale Parent-Entity | TEIL 5, TEIL 11 |
| 8 | "+ Weiteren Typ hinzufügen" Button (vor Ordered, oder Admin-/Admin-Override danach) | TEIL 2 |

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

### Credits-Prinzip (v0.2 typisiert)

- **Auftrag = gekauftes Paket mit typisierten Credits** (z.B. "1× MDI + 1× Relief + 1× ASSESS 5.0")
- Jeder Credit hat einen **Assessment-Typ** (aus `dim_assessment_types`): MDI, Relief, ASSESS 5.0, DISC, EQ, Scheelen 6HM, Driving Forces, Human Needs/BIP, Ikigai, AI-Analyse, Teamrad-Session
- Credits werden durch **Zuweisung an Kandidaten** (Runs) verwendet
- Solange ein Credit noch nicht `completed` ist, kann der Kandidat **umgewidmet** werden (Tausch) — **nur innerhalb gleichen Typs**
- Typ-Wechsel (MDI → Relief) ist **nicht möglich** — Credit freigeben + neu kaufen
- Gesamtpreis sofort bei Unterschrift fällig — unabhängig davon wann Credits eingelöst werden
- **Credits verfallen nicht** (Entscheidung 2026-04-13)
- `fact_assessment_order_credits.used_count` wird **bei Run-Completion** inkrementiert, nicht bei Zuweisung

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
| Ordered / Partially Used | Cancelled | Manuell (AM/Admin) mit Confirm-Dialog | Pflicht: Begründung |

**Manuelle Status-Änderungen auf Cancelled** öffnen Confirm-Dialog. Alle anderen sind Auto. (v0.3: Invoiced-Zeile entfernt — Billing-State lebt auf `fact_assessment_billing.status`.)

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
- Korrektur nur via Admin-/Admin-Override

### Preis-Berechnung "pro Credit"

Info-only: `price_chf / credits_total` wird angezeigt, aber **nicht gespeichert**. Reines Display für Transparenz.

---

## TEIL 3: TAB 2 — DURCHFÜHRUNGEN (KERN)

### Run-Erstellung (Credit zuweisen, v0.2)

1. Button "➕ Credit zuweisen" → Drawer
2. **Assessment-Typ wählen (PFLICHT, zuerst)** — Dropdown aus Typen mit `frei > 0` an diesem Auftrag:
   - Pool: `fact_assessment_order_credits WHERE order_id = X AND (quantity - used_count - aktive_runs) > 0`
   - Jede Option zeigt: Typ-Name + Anzahl frei (z.B. "MDI (1 frei)")
   - Wenn Drawer aus Tab-1-Credit-Tabellen-Zeile geöffnet: Typ vorausgewählt und gelockt
   - Wenn keine freien Credits in keinem Typ: Drawer öffnet nicht (Button disabled)
3. **Kandidat-Autocomplete:**
   - Pool: alle Kandidaten im CRM (nicht nur Kontakte des Accounts)
   - Default-Sortierung: Kontakte dieses Accounts zuerst
4. **Kein Match:** Hard-Stop → "Als Kandidat anlegen" (Link zum Kandidaten-Erstellungs-Flow, nach Speichern Rückkehr zum Drawer mit vorbefülltem Match)
5. **Duplikat-Check (typ-spezifisch):** Query `fact_assessment_run WHERE assessment_order_id = X AND assessment_type_id = T AND candidate_id = Y AND status != 'cancelled_reassignable'`
   - Wenn Eintrag existiert: Warnung (nicht-blockierend) *"Max Muster hat bereits einen aktiven [Typ]-Credit in diesem Auftrag"*
   - **Nicht blockierend:** ein Kandidat kann theoretisch zwei Runs gleichen Typs haben (z.B. Wiederholungs-Test)
6. Optional: Termin setzen im gleichen Drawer (DateTime-Picker)
7. "Zuweisen" → `INSERT fact_assessment_run (assessment_type_id, ...)` mit `status='assigned'` (oder `scheduled` falls Termin)
8. Auto-Aktionen:
   - `fact_history` Event `assessment_credit_assigned` (mit Typ-Info) — am Kandidaten, Account, Auftrag
   - Wenn `mandate_id` am Auftrag: auch am Mandat
   - Notification an CM des Accounts

**Wichtig:** `fact_assessment_order_credits.used_count` wird **NICHT** bei Zuweisung erhöht — erst bei Completion. Zugewiesene aber nicht durchgeführte Runs werden über `COUNT(fact_assessment_run WHERE status IN ('assigned','scheduled','in_progress'))` live gezählt.

### Kandidat ersetzen (Umwidmung, v0.2)

Nur wenn Run-Status ∈ {`assigned`, `scheduled`}. **Typ bleibt unverändert** — Umwidmung ist nur Personen-Tausch innerhalb des gleichen Credits.

1. Im Run-Drawer: "Kandidat ersetzen" → Confirm-Dialog: *"Person [X] durch neuen Kandidaten ersetzen? Der [Typ]-Credit bleibt erhalten."*
2. Neue Kandidaten-Suche (wie bei Zuweisung). **Keine Typ-Wahl** — Typ bleibt.
3. Bestätigen:
   - `reassigned_from_candidate_id = current candidate_id`
   - `candidate_id = new`
   - `assessment_type_id` UNVERÄNDERT (Trigger-validiert)
   - `reassigned_at = now`, `reassigned_by = current_user`
4. Events:
   - Am alten Kandidaten: `assessment_credit_reassigned_away`
   - Am neuen Kandidaten: `assessment_credit_reassigned_to`
   - Am Auftrag: `run_reassigned`

**Wichtig:** Run-ID bleibt erhalten — keine neue Row. Audit-Trail über `reassigned_from_*` Felder.

**Typ-Wechsel explizit nicht möglich:** Wenn Kunde anderen Typ einlösen will, muss der aktuelle Credit freigegeben werden (Status → `cancelled_reassignable`), der Typ-Slot wird damit wieder "frei", und dann kann ein neuer Run anderen Typs angelegt werden. **Aber:** Die ursprünglich gekauften Credits sind fix pro Typ — Kunde kann nicht "1× MDI storniert, dafür 1× Relief" umbuchen ohne zusätzliche Kosten (Admin-/Admin-Override nötig).

### Termin setzen / ändern

- Inline-DateTime-Picker im Run-Drawer
- Setzen: Status → `scheduled`, `scheduled_at = value`
- Ändern: `scheduled_at = new_value`, Event `run_rescheduled`
- Wenn Termin entfernt (null): Status zurück auf `assigned`

### Report übertragen (Completion, v0.2 typisiert)

Trigger: Header-Button "📤 Report übertragen" ODER Run-Drawer "Als durchgeführt markieren".

**Drawer:**
1. Run wählen (Dropdown, zeigt Typ pro Run). Vorausgewählt + gelockt wenn aus Run-Drawer aufgerufen.
2. **Typ NICHT wählbar** — kommt aus `fact_assessment_run.assessment_type_id` (Badge sichtbar).
3. `completed_at` DateTime-Picker (Default: heute).
4. Upload **Executive Summary** (Pflicht, PDF).
5. Upload **Detail-Report** (optional, Partner-Anhang PDF).
6. Typ-spezifische Rohdaten (Phase 1: freies JSONB; Phase 1.5: typ-spezifische Formulare).
7. Bestätigen → atomare Transaktion:

```sql
BEGIN TRANSACTION

  -- 1. Version anlegen
  INSERT INTO fact_candidate_assessment_version (
    candidate_id        = run.candidate_id,
    assessment_order_id = run.assessment_order_id,
    assessment_type_id  = run.assessment_type_id,
    version_number      = (SELECT COALESCE(MAX(version_number),0)+1
                           FROM fact_candidate_assessment_version
                           WHERE candidate_id = run.candidate_id
                             AND assessment_type_id = run.assessment_type_id),
    version_date        = NOW(),
    executive_summary_doc_id = uploaded_exec_summary_id,
    detail_report_doc_id     = uploaded_detail_id,
    result_data              = uploaded_json_data
  ) RETURNING id AS new_version_id;

  -- 2. Run auf completed
  UPDATE fact_assessment_run
    SET status            = 'completed',
        completed_at      = input_completed_at,
        result_version_id = new_version_id
    WHERE id = run_id;

  -- 3. Typ-spezifischen used_count erhöhen
  UPDATE fact_assessment_order_credits
    SET used_count = used_count + 1
    WHERE assessment_order_id = run.assessment_order_id
      AND assessment_type_id  = run.assessment_type_id;

  -- 4. Order-Status aktualisieren
  UPDATE fact_assessment_order
    SET status = CASE
      WHEN (SELECT SUM(used_count) = SUM(quantity)
            FROM fact_assessment_order_credits
            WHERE assessment_order_id = run.assessment_order_id)
      THEN 'fully_used'
      ELSE 'partially_used'
    END
    WHERE id = run.assessment_order_id;

  -- 5. Events
  INSERT fact_history → 'assessment_run_completed' (scope: Kandidat + Account + Order + [Mandat falls linked])
  INSERT fact_history → 'assessment_version_created' (scope: Kandidat)

COMMIT
```

**Versionierung zentral:** `fact_candidate_assessment_version` ist Parent-Entity. Pro (Kandidat, Typ) aufsteigende `version_number`. Pfeil-Navigation im Kandidaten-Assessment-Tab funktioniert über diese Tabelle. Sub-Tabellen (DISC-Details, EQ-Details) bekommen FK `version_id`.

### Credit freigeben (Abbruch ohne Tausch)

Run-Drawer "Abbrechen & Credit freigeben":
1. Confirm mit Begründungs-Pflichtfeld
2. `status = 'cancelled_reassignable'`, `cancelled_at`, `cancellation_reason`
3. Credit wird wieder "frei" — kann neu zugewiesen werden
4. `credits_total` bleibt unverändert; `credits_cancelled_reassignable` Zähler erhöht
5. Event `assessment_run_cancelled`

### Validierungs-Regeln (v0.2)

| Regel | Enforcement |
|-------|------------|
| **Pro Typ:** `used_count + active_runs <= quantity` in `fact_assessment_order_credits` | Hard, bei Zuweisung geprüft |
| `fact_assessment_run.assessment_type_id` muss in `fact_assessment_order_credits` dieses Orders existieren | Hard (FK + Query-Check) |
| Bei Umwidmung: `assessment_type_id` darf nicht ändern | Hard (Trigger) |
| Kandidat zuweisen erfordert `candidate_id` existiert | Hard |
| `scheduled_at` nicht in Vergangenheit setzbar | Soft (Warn) |
| `completed_at >= scheduled_at` falls beide gesetzt | Hard |
| Report-Upload bei `completed` erfordert Executive Summary | Hard |
| `used_count` nur inkrementiert bei Completion, niemals bei Assign | Hard (Transaktions-Invariante) |

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
| `assessment_credit_assigned` | Run erstellt (inkl. Typ im Payload) | Kandidat + Account + Order |
| `assessment_credit_reassigned_away` | Umwidmung (Typ unverändert) | Alter Kandidat |
| `assessment_credit_reassigned_to` | Umwidmung (Typ unverändert) | Neuer Kandidat |
| `assessment_run_scheduled` | Termin gesetzt | Kandidat + Account + Order |
| `assessment_run_completed` | Report hochgeladen (inkl. Typ + Version-Ref im Payload) | Kandidat + Account + Order (+ Mandat) |
| `assessment_run_cancelled` | Credit freigegeben (Typ wieder frei) | Kandidat + Account + Order |
| `assessment_version_created` | Neue `fact_candidate_assessment_version` erstellt (inkl. Typ + Version-Nr.) | Kandidat |
| `assessment_order_cancelled` | Auftrag storniert | Account + Order |
| `assessment_invoice_generated` | Rechnung erstellt | Account + Order |
| `assessment_invoice_paid` | Rechnung bezahlt | Account + Order |
| **`order_credits_rebalanced_by_admin`** *(NEU v0.2)* | Admin-/Admin-Override: Credits-Typen-Umbuchung | Account + Order (Audit) |

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

### Überschiessende Zuweisungen (v0.2 pro Typ)

Pro Typ: wenn AM versucht Credit zu vergeben obwohl `quantity == used_count + active_runs` für diesen Typ:
- Typ im Dropdown "Typ wählen" nicht verfügbar (ausgegraut: "MDI — 0 frei")
- Wenn **alle** Typen erschöpft: "+ Credit zuweisen" Button disabled mit Tooltip *"Keine freien Credits mehr. Neuer Auftrag oder Admin-/Admin-Override erforderlich."*

### Credit-Tausch innerhalb desselben Auftrags (v0.2 typisiert)

Szenario: MDI-Credit war an Person A zugewiesen (scheduled), wird dann an Person B umgewidmet → Typ MDI bleibt, nur Kandidat-Wechsel.

**Nicht möglich:** Typ-Wechsel (z.B. MDI → Relief am selben Run). Workflow dafür: aktuellen Run freigeben (Status `cancelled_reassignable`) + neuen Run mit anderem Typ anlegen — aber nur wenn dieser Typ noch freie Credits hat.

### Admin-/Admin-Override für Typ-Umbuchung

Sonderfall: Kunde will nachträglich 1× MDI stornieren und dafür 1× Relief bekommen (gleicher Gesamtpreis). Kein regulärer Self-Service-Flow:
- Admin öffnet Auftrag
- Sektion 2 Credits editierbar (auch bei `ordered` Status, via Admin-/Admin-Override)
- MDI `quantity` auf 0 setzen, Relief `quantity` hinzufügen oder erhöhen
- Audit-Log `fact_audit_log.override_reason = 'admin_credit_rebalance'` mit Begründung
- Event `order_credits_rebalanced_by_admin`

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

### Admin-/Admin-Override

Admin kann ausnahmsweise:
- `price_chf` nach `Ordered` ändern (Korrektur-Fälle)
- `credits_total` erhöhen (freier Kulanz-Bonus)
- Abweichende Befugnisse loggen sich mit `fact_audit_log.override_reason = 'admin_admin_override'`

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

- `ARK_ASSESSMENT_DETAILMASKE_SCHEMA_v0_2.md` (Begleitdokument)
- `ARK_ACCOUNT_DETAILMASKE_INTERACTIONS_v0_3.md` TEIL 8b (Assessment-Beauftragung am Account)
- `ARK_MANDAT_DETAILMASKE_INTERACTIONS_v0_3.md` TEIL 2b (Option IX am Mandat)
- `ARK_KANDIDATENMASKE_INTERACTIONS_v1_3.md` (Assessment-Tab Versionierung via `fact_candidate_assessment_version`)
- `ARK_STAMMDATEN_EXPORT_v1_3.md` (ausstehend) — `dim_assessment_types` Katalog
- [[audit-entscheidungen-2026-04-14]] — Entscheidung Typisierte Credits
- [[diagnostik-assessment]], [[offerte-diagnostik]]
- [[detailseiten-guideline]]
