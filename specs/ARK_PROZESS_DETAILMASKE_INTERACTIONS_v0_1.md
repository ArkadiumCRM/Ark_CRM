# ARK CRM — Prozess-Detailmaske Interactions Spec v0.1

**Stand:** 13.04.2026
**Status:** Erstentwurf — Review ausstehend
**Kontext:** Definiert Verhalten, State-Machine, CRUD-Flows, Events für Prozess-Detailseite `/processes/[id]` (Mischform: Pipeline-Modul als Hauptarbeitsort + Slide-in-Drawer + schlanke 3-Tab-Detailseite).
**Begleitdokument:** `ARK_PROZESS_DETAILMASKE_SCHEMA_v0_1.md`
**Vorrang:** Stammdaten > dieses Dokument > Schema > Mockups
**Globale Patterns:** 11 Global Patterns aus Kandidaten-Interactions v1.2

---

## TEIL 0: STRUKTURELLE GRUNDENTSCHEIDUNGEN

### Mischform

- **Primär-Arbeitsort:** Pipeline-Modul `/processes` (Liste + Slide-in-Drawer 540px)
- **Detailseite `/processes/[id]`:** 3 Tabs (Übersicht / Interviews & Honorar / Dokumente & History) für tiefere Analyse

### Erstellungs-Wege

| Weg | Trigger |
|-----|---------|
| **Automatisch aus Jobbasket** | CV/Exposé-Versand (Gate 2) → `fact_process_core` Insert mit Stage `expose` oder `cv_sent` |
| **Manuell (Erfolgsbasis)** | AM/CM erstellt Prozess ohne Mandat — nur für Fälle wo Mandat nicht existiert |
| **Nicht erlaubt** | Manuelle Erstellung innerhalb eines aktiven Target-Mandats (muss über Jobbasket) |

### Duplikatschutz

**Hard:** Max 1 offener Prozess pro `(candidate_id, job_id)`. "Offen" = Status ∈ {Open, On Hold, Stale}. Bei Erstellungs-Versuch → Hard-Stop "Kandidat ist bereits in einem offenen Prozess für diesen Job (Prozess P-XYZ)".

---

## TEIL 1: STAGE-PIPELINE

### Stage-Sequenz (9)

```
Exposé → CV Sent → TI → 1. Interview → 2. Interview → 3. Interview → Assessment → Angebot → Platzierung
```

`Stage = Termin (1:1)` (entschieden 2026-04-13): jede Interview-Stage entspricht genau einem Termin.

### Stage-Wechsel

| Übergang | Trigger |
|----------|---------|
| Jobbasket → Exposé / CV Sent | Automatisch bei Versand (Gate 2) |
| Exposé → CV Sent | Manuell: "CV nachreichen" (Upgrade) |
| CV Sent → TI | Manuell durch CM |
| TI → 1. Interview | Manuell durch CM (nach erfolgreichem TI) |
| 1./2. Interview → nächste Stage | Manuell durch CM |
| 3. Interview / Assessment → Angebot | Manuell durch CM |
| Angebot → Platzierung | Placement-Modal (siehe TEIL 4) |

**Rückwärts-Sprünge:**
- Erlaubt (mit Confirm-Dialog + Pflicht-Grund)
- Historie bleibt in `fact_process_events` (Audit)

**Überspringen (Stage-Forward-Skip) — Klarstellung 2026-04-16:**
- Stages sind **keine strikte Kette** — Kunden machen manchmal nur 1 Interview statt 3.
- Erlaubte Skips: `CV Sent → 2nd`, `TI → 3rd`, `1st → Angebot`, `2nd → Angebot`, `3rd → Angebot`, `Assessment → Angebot`
- **Nicht** erlaubt: Skip über `Angebot` hinaus (d.h. `1st → Platzierung` direkt) — Placement setzt `stage='angebot'` voraus (V1 Saga-Pre-Check)
- `stage_order` im DB-Model als Int nur für Darstellungs-Reihenfolge, **nicht** für Validierung der Kette

### Optimistic Update

- Stage-Wechsel via Dropdown → sofortige UI-Änderung
- Server-Confirm; bei Fehler → Rollback + Toast "Stage-Wechsel fehlgeschlagen"
- **Ausnahme:** Stage-Wechsel zu `Platzierung` → **kein Optimistic** (öffnet Modal, Server-Confirm Pflicht)

### Stale-Detection

**Pro Stage konfigurierbare Schwellwerte** via `dim_automation_settings.process_stale_thresholds`:
```json
{
  "expose": 14,
  "cv_sent": 14,
  "ti": 7,
  "interview_1": 14,
  "interview_2": 14,
  "interview_3": 14,
  "assessment": 21,
  "angebot": 10
}
```

Werte in Tagen. Admin kann Werte in Settings editieren.

**Nightly-Job:** `WHERE status = 'Open' AND (now - stage_changed_at) > threshold_for_stage` → `status = 'Stale'` + Notification an CM.

Bei Stage-Wechsel: `status = 'Stale' → 'Open'` zurück.

---

## TEIL 2: STATUS-MASCHINE

### Status-Übergänge

```
Open ⇄ On Hold
Open → Rejected
Open → Stale (auto) → Open (bei Stage-Wechsel)
Open (Stage = Angebot) → Placed
Placed → Cancelled (Rückzieher nach Placement)
Placed → Closed (Garantiezeit durch)
```

### Status-Details

**Open:** Default. Prozess aktiv in Pipeline.

**On Hold:**
- Pflicht: `on_hold_reason` (Freitext)
- Stale-Timer pausiert
- Sichtbarkeit bleibt in Pipeline (mit Amber-Badge)
- Re-Aktivierung: Dropdown zurück auf "Open"

**Rejected:** siehe TEIL 3 (dedizierter Flow)

**Stale:** Auto-gesetzt (siehe TEIL 1). Manuelles Setzen nicht vorgesehen.

**Placed:** siehe TEIL 4 (Placement-Flow)

**Cancelled:** Rückzieher nach Placement (Kandidat sagt doch ab vor Arbeitsantritt):
- Confirm-Dialog mit Grund
- **100% Rückvergütung** wird automatisch als Gutschrift erstellt ([[rechnungen-mandat]] Rückerstattung bei Erfolgsbasis, Mandat-Kündigungs-Logik bei Mandat)
- Honorar bei Mandat: Mandat wird nicht als "Abgebrochen" gesetzt (Mandat läuft weiter, nur dieser Prozess ist cancelled)

**Closed:** Nach erfolgreicher Garantiefrist (3 Monate, oder Option X verlängert). Auto-Übergang am `placed_at + garantie_months`. Prozess wird archiviert, nicht mehr in aktiven Listen.

**Dropped:** Prozess kam gar nicht erst zustande (z.B. CV versendet aber Kunde hat nie reagiert und gibt Prozess auf). Manueller Status, mit Grund.

---

## TEIL 3: REJECTION-FLOW

### Modal (kein Optimistic Update)

Klick "❌ Ablehnen":

1. Modal öffnet sich mit Pflicht-Feldern:
   - **`rejected_by`** (Radio, Pflicht): `candidate` / `client` / `internal`
   - **`rejection_reason_id`** (Dropdown, Pflicht): aus passender Reason-Tabelle:
     - Bei `candidate` → `dim_rejection_reasons_candidate`
     - Bei `client` → `dim_rejection_reasons_client`
     - Bei `internal` → `dim_rejection_reasons_internal`
   - **`rejection_note`** (Textarea, optional): freier Kommentar

2. "Ablehnen" → Server-Call (kein Optimistic)
3. Bei Erfolg: `status = 'Rejected'`, Felder gesetzt, Event `rejected` im History
4. UI-Änderung: Status-Badge rot, Sektion 3 zeigt Rejection-Details

### Folge-Aktionen bei Rejection

- **Schutzfrist-Fenster wird eröffnet** (siehe [[direkteinstellung-schutzfrist]]):
  - Wenn Kandidat jemals als `candidate_presented_*` im Prozess erscheint
  - `fact_protection_window` Insert mit `starts_at = rejected_at`, `expires_at = rejected_at + 12 months`
- Re-Aktivierung: Rejection rückgängig machen ist **möglich** durch Admin (mit Audit-Log), öffnet Status wieder auf `Open`

---

## TEIL 4: PLACEMENT-FLOW

### Modal (kein Optimistic Update)

Button "🏆 Platzieren" sichtbar wenn Stage = Angebot + Status = Open.

Modal-Felder:
1. **`start_date`** (Date, Pflicht): Arbeitsantritt beim Kunden
2. **`salary_candidate_actual`** (CHF, Pflicht): Tatsächlicher Jahreslohn (kann von `target` abweichen)
3. **`garantie_months`** (Int, Default 3): Garantiefrist, kann durch Mandat-Option X verlängert sein
4. **Placement-Notizen** (Textarea, optional)
5. **Admin-Freigabe** (Checkbox, Pflicht bei Erfolgsbasis > CHF X)

"Platzieren" → Server-Call löst **Saga TX1 (Placement 8-Step)** aus. Entspricht Backend v2.5 § TX1. Alle 8 Schritte laufen in einer DB-Transaktion; bei Fehler Rollback + `placement_failed`-Event.

### Pre-Validierung (vor TX)

Werden alle verletzt → Modal-Error, keine TX:

| # | Check | Fehler-Code |
|---|-------|-------------|
| V1 | `stage = 'angebot'` UND `status = 'Open'` | `invalid_stage` |
| V2 | Caller-Rolle = AM (Owner) ODER Admin | `unauthorized` |
| V3 | `start_date >= today` | `invalid_start_date` |
| V4 | `salary_candidate_actual > 0` | `invalid_salary` |
| V5 | Bei Erfolgsbasis > CHF-Schwelle: `admin_approval_checked = TRUE` | `admin_approval_required` |
| V6 | Schutzfrist-Scope-Check: Kein aktives `fact_protection_window` eines **anderen** AM auf diesem `candidate_id` + `account_id` (bzw. `group_id` bei Scope=group) blockiert | `protection_window_conflict` (→ Claim-Flow statt Placement) |
| V7 | Mandat-Prozess: `fact_mandate.is_longlist_locked = FALSE` (Mandat nicht gekündigt) | `mandate_locked` |

### Placement-Drawer · UI-seitige Readiness-Checks (Phase F)

Zusätzlich zu den serverseitigen Saga-Pre-Checks V1–V7 zeigt der Placement-Drawer eine UI-seitige **Datenvollständigkeits-Matrix** an (zur proaktiven Vermeidung von Modal-Errors):

| UI-Check | Feld | Zweck |
|----------|------|-------|
| Angebot-Datum | `fact_process_events.offer_date` | Timestamp Angebots-Schreiben an Kandidat |
| TC-Salär | `salary_candidate_actual` | V4-Mapping |
| Start-Datum | `start_date` | V3-Mapping |
| Honorar-Modell | `business_model` | Determines Billing-Type in Step 2 |
| Rechnungs-Adresse | `fact_accounts.billing_address` | Blocker für Rechnungsstellung |
| Splits Σ=100 % | `split_am_pct + split_cm_pct` | Provisions-Input-Vollständigkeit |
| Jobs.filled_count | `fact_jobs.filled_count < target` | Vermeidung Overfill |

**Beziehung zu Saga-V1–V7:** Das UI-Matrix überlappt sich mit Saga-V-Checks, ersetzt sie aber **nicht**. Fehlt ein UI-Check → Button „🏆 Platzierung auslösen" ist `disabled`. Alle UI-Checks grün → Button aktiv, TX1 wird angestossen, Saga-V-Checks laufen serverseitig als Transaktions-Grenze.

### TX1 — 8-Step Saga

```
BEGIN TRANSACTION

-- Step 1: Prozess-Update
UPDATE fact_process_core
  SET stage='platzierung', status='Placed', placed_at=now(),
      start_date=:start_date, salary_candidate_actual=:salary, garantie_months=:garantie
  WHERE id=:process_id;
INSERT INTO fact_process_events (process_id, event='placed', payload=...);

-- Step 2: Finance (Erfolgsbasis ODER Mandat-Billing)
IF process.mandate_id IS NULL THEN
  INSERT INTO fact_process_finance (process_id, fee_net, fee_pct, staffel_pct)
    VALUES (:pid, calc_fee(salary, honorar_override_pct), ...);
ELSE
  -- Target: stage_3, Taskforce: success_fee, Time: slot_consumed
  INSERT INTO fact_mandate_billing (mandate_id, billing_type, amount, due_date, source_process_id)
    VALUES (process.mandate_id, :billing_type, :amount, placed_at+30d, :pid);
END IF;

-- Step 3: Job-Filled
IF process.job_id IS NOT NULL THEN
  UPDATE fact_jobs SET status='filled', filled_at=now(), filled_by_process_id=:pid
    WHERE id=process.job_id;
END IF;

-- Step 4: Garantiefrist starten + offene Schutzfrist honorieren
--   Garantiefrist (AGB §5, 3 Mt) ist ERSTER Start ab Placement
--   Schutzfrist (AGB §6, 12/16 Mt) lief bereits ab Kandidaten-Vorstellung —
--   durch Placement wird Geschäft abgeschlossen → alle offenen Schutzfristen
--   dieses Kandidat × Kunde-Paares werden 'honored' gesetzt.
--   KEIN neues Schutzfrist-Fenster nach Placement (Schutzfrist ist NICHT-Placement-Schutz).
INSERT INTO fact_candidate_guarantee (candidate_id, process_id, placement_id,
  guarantee_start=hire_date, guarantee_end=hire_date + interval '3 months',
  status='active', scale=dim_guarantee_scale);

UPDATE fact_protection_window SET status='honored', honored_at=now(), honored_by_placement_id=:placement_id
  WHERE candidate_id=process.candidate_id
    AND (account_id=process.account_id OR group_id=process.account.group_id)
    AND status='active';

INSERT INTO fact_candidate_presentation (candidate_id, account_id, mandat_id, prozess_id,
  presentation_type='placement', presented_at=now(), presented_by=:user_id);

-- Step 5: Referral-Auslösung (falls vorhanden)
UPDATE fact_referral SET payout_due_at = placed_at + (garantie_months * interval '1 month'),
                         status='pending_payout'
  WHERE referred_candidate_id=process.candidate_id AND status='pending';

-- Step 6: Stellenplan-Update (falls Mandat mit Projekt-Bezug)
IF process.mandate.project_id IS NOT NULL THEN
  UPDATE fact_project_positions SET filled_count = filled_count + 1
    WHERE project_id=process.mandate.project_id AND position_code=process.mandate.position_code;
END IF;

-- Step 7: Auto-Reminders (4 Stück aus dim_reminder_templates · nur während Garantiefrist)
INSERT INTO fact_reminders (candidate_id, account_id, due_at, reminder_type, template_id) VALUES
  (:cid, :aid, :start_date - 7d,           'onboarding_call', tpl_onboarding),
  (:cid, :aid, :start_date + '1 month',    'check_in_1m',     tpl_1m),
  (:cid, :aid, :start_date + '2 months',   'check_in_2m',     tpl_2m),
  (:cid, :aid, :start_date + '3 months',   'check_in_3m',     tpl_3m_garantie_end);
-- Nach 3. Mt: keine weiteren Reminder — Garantiefrist abgelaufen, Prozess → Closed

-- Step 8: History-Events (5 Entities)
INSERT INTO fact_history (entity, entity_id, event, ...) VALUES
  ('candidate', process.candidate_id, 'placed', ...),
  ('account',   process.account_id,   'placed', ...),
  ('mandate',   process.mandate_id,   'placed', ...),  -- nur falls mandate
  ('job',       process.job_id,       'filled', ...),
  ('process',   :pid,                 'placed', ...);

COMMIT;
-- Post-Commit (async): Outbox-Events → Workers
--   process.placement_done, mandate.billing_triggered, job.filled, protection_window.opened,
--   referral.payout_scheduled (falls referral), reminder.batch_created
```

**Rollback-Verhalten:** Jeder Step-Fail rollt alle 8 zurück. Saga-ID wird in `fact_saga_log` gespeichert mit Step-Index + Fehler; UI zeigt Retry-Option.

---

## TEIL 5: INTERVIEWS (TAB 2 SUB-SECTION)

### Grundregel: Arkadium-Rolle (CLAUDE.md §Arkadium-Rolle-Regel)

**Interviews (TI / 1. / 2. / 3. / Assessment) laufen direkt zwischen Kunde und Kandidat. Arkadium nimmt nicht teil.** Termine werden meist direkt zwischen Kunde und Kandidat vereinbart. CM-Rolle im CRM:

- **Erfasst** Interview-Termine im CRM (aus direkter Absprache Kunde↔Kandidat)
- **Führt** Coaching mit Kandidat VOR dem Interview
- **Führt** Debriefing beidseitig NACH dem Interview (2 separate Gespräche: mit Kandidat und mit Kunde)
- **Nimmt NICHT teil** am Interview selbst
- Outlook-Kalendereintrag ist **Referenz-Sync**, kein Teilnahme-Signal

### Interview-Termin erfassen

Button "+ Interview-Termin erfassen" im Tab 2 oder Inline pro Stage.

**Drawer:**
1. Stage auswählen (Default: aktuelle Stage falls Interview-Stage; sonst Dropdown)
2. DateTime-Picker für Termin (direkt zwischen Kunde und Kandidat vereinbart)
3. Typ: Telefon / Teams / Vor-Ort / Hybrid
4. Teilnehmer Kundenseite: Multi-Select aus `dim_account_contacts` — **KEINE** Arkadium-Mitarbeiter
5. Ort / Meeting-Link (falls Teams/vor Ort)

"Speichern" → `fact_process_interviews` Insert ODER Update (wenn Stage bereits Interview hat) + `fact_history` Event `{stage}_termin_erfasst`.

**Auto-Aktionen:**
- Outlook-Kalendereintrag via MS Graph API für CM als **Read-Only-Referenz** (nicht als Organizer — CM ist nicht Teilnehmer)
- Auto-Reminder für CM: **Coaching-Call mit Kandidat** 2 Tage vor Interview (Template `dim_reminder_templates` · Activity-Type `coaching_vor_{stage}`)
- Auto-Reminder für CM: **Debriefing-Calls beidseitig** am Termin-Tag Abend (je ein Slot für Kandidat + für Kunde · Activity-Types `debriefing_{stage}_kandidat` + `debriefing_{stage}_kunde`)

### Coaching-Gespräch erfassen (VOR Interview)

Arkadium ↔ Kandidat, Kandidat-Vorbereitung. Inline-Chip pro Interview-Row oder via History-Drawer.

- Activity-Types (aus `ARK_STAMMDATEN_EXPORT_v1_3` §14): `Erreicht - Coaching TI` (#65) / `Erreicht - Coaching 1st Interview` (#36) / `Erreicht - Coaching 2nd Interview` (#38) / `Erreicht - Coaching 3rd Interview` (#40)
- entity_relevance: `candidate` (in Kandidat-History)
- `fact_history.type` = Single Source of Truth — UI-Chip-Status ist Projektion (Activity-Linking-Regel)
- Inhalt (Freitext + strukturierte Felder): Unternehmens-Insights, Gesprächspartner, Do's / Don'ts, strategische Positionierung

### Debriefing-Gespräch erfassen (NACH Interview · beidseitig)

**2 separate History-Einträge pro Debriefing-Set** mit identischem Activity-Type — Entity-Zuordnung ergibt sich aus der History-Location:

| Activity-Type (aus Katalog) | Entity-Verknüpfung | Teilnehmer | Ziel |
|-----------|-------------------|-----------|------|
| `Erreicht - Debriefing TI` (#66) · `Erreicht - Debriefing 1st Interview` (#37) · `Erreicht - Debriefing 2nd Interview` (#39) · `Erreicht - Debriefing 3rd Interview` (#41) | Kandidat-History (`entity_type='candidate'`) | Arkadium ↔ Kandidat | Eindrücke, Passung Kultur, Red Flags Kunde-Seite, Motivation, weiteres Interesse |
| Gleiche Activity-Types | Account-History (`entity_type='account'`) | Arkadium ↔ Kunde | Feedback, Red Flags Kandidat-Seite, Passung, Entscheidungspräferenz, weiteres Vorgehen |

entity_relevance in Katalog: `both` — Activity wird in zwei Entity-Histories aufgezeichnet.

**Beide History-Einträge sollten vorhanden sein.** UI-Warnung wenn nur einseitig debrieft (`COUNT(fact_history WHERE type='Erreicht - Debriefing {stage} Interview' AND process_id=:pid) < 2`). `fact_process_interviews.debriefing_status` = computed aus diesem COUNT.

**Stage-Weitergang-Gate:** Weich — Warnung wenn Debriefings fehlen, nicht blockierend (Override mit Grund „Ghosting / Kunden-Info"). Pipeline-Stage-Popover zeigt Warnung aus §Pipeline-Component.

### Termin verschieben

Edit `interview_date` → Outlook-Event wird aktualisiert, Reminder werden entsprechend verschoben. Event `interview_rescheduled` im History.

### Outcome setzen

Dropdown pro Interview: **Continue** / **Rejected** / **Open** (basierend auf Debriefing-Aggregation).
- "Rejected" öffnet den globalen Rejection-Flow (TEIL 3)
- "Continue" enabled Stage-Weiter-Navigation

### Referenzauskunft (vor Placement)

Arkadium holt Referenz bei Referenzperson (ehem. Vorgesetzter, Kollege) im Auftrag des Kunden ein.

- Activity-Type: `referenzauskunft`
- `fact_history` Event mit Referenzperson-Kontakt, Notizen, Einschätzung
- Wird als separate Row in Tab 2 angezeigt (nicht als Interview-Stage)

---

## TEIL 6: HONORAR (TAB 2 SUB-SECTION)

### Mandats-Prozess

Info-Panel, keine Edit-Möglichkeit. Klick "→ Mandat-Billing" → Navigation zu Mandat Tab 4.

### Erfolgsbasis-Prozess

**Auto-Berechnung:**

```
staffel_pct = lookup_in_dim_honorar_settings(salary_candidate_target)
  -- < 90k → 21%, < 110k → 23%, < 130k → 25%, ≥ 130k → 27%
fee_net = salary_candidate_target * (honorar_override_pct OR staffel_pct) / 100
fee_vat = fee_net * 0.081
fee_gross = fee_net + fee_vat
```

**Override:** AM/Admin kann `honorar_override_pct` setzen (mit Audit-Log). Bei Override zeigt UI "Override aktiv" + ursprünglichen Staffel-Wert daneben.

**Rechnung erstellen:**

Button "📄 Rechnung erstellen" nur sichtbar bei Status = Placed + Erfolgsbasis + Rechnung noch nicht erstellt. Drawer:
- Rechnungsnummer (auto-generiert)
- Rechnungsdatum (Default: placed_at oder heute)
- Fälligkeitsdatum (Default: Rechnungsdatum + 30 Tage)
- Template-Auswahl: Standard / Mit Rabatt / Du-Variante (nach `dim_accounts.tonality`)
- PDF-Render ODER manueller Upload

`fact_process_finance.invoice_document_id` und `invoice_number` gesetzt.

### Provisions-Splits

Berechnung bei Placement basierend auf `dim_mitarbeiter.commission_*_pct`:
```
commission_cm = fee_net * cm.commission_cm_pct / 100
commission_am = fee_net * am.commission_am_pct / 100
commission_hunter = fee_net * hunter.commission_hunter_pct / 100  -- falls Hunter ≠ CM
```

Sichtbar nur für AM + Admin + Backoffice (nicht CM). Speicherung: `fact_process_finance.commission_*_amount`.

---

## TEIL 7: POST-PLACEMENT (TAB 1 SEKTION 4)

### Auto-Reminders (bei Placement erstellt)

| Reminder | Trigger-Datum | Empfänger | Aktion |
|----------|--------------|-----------|--------|
| Onboarding-Call | `start_date − 7` | CM | Call-Template im Email-System |
| 1-Mt-Check | `start_date + 1 Monat` | CM | Call-Template |
| 2-Mt-Check | `start_date + 2 Monate` | CM | Call-Template |
| 3-Mt-Check = Garantiefrist-Ende | `start_date + 3 Monate` (= `start_date + garantie_months`) | AM + CM | Call-Template · Status auf `Closed` setzen |

**Keine weiteren Reminder nach dem 3. Monat.** Rückvergütungsfrist ist mit dem 3-Mt-Check abgelaufen, Geschäft abgeschlossen. Prozess geht auf Status=Closed. 6-Mt / 12-Mt / 2-Jahres-Checks werden nicht automatisch erstellt.

### Early Exit · Modell-spezifisch (Klarstellung 2026-04-16)

Wenn Kandidat vor Garantiefrist-Ende ([[garantiefrist]], **3 Monate** seriell, siehe Concept-Page) austritt, unterscheidet sich die Folgeaktion nach `business_model`:

1. CM setzt `early_exit_flag = true`, `exit_date`, `fault_side` (Kandidat / Kunde / Unklar)
2. **Wenn `fault_side = 'client'`:** Keine Rückvergütung / keine Ersatzbesetzungs-Pflicht — Admin-Override dokumentiert Ausnahme
3. **Sonst — Routing per Business-Modell:**

| `business_model`           | Folgeaktion                                                    | Details |
|----------------------------|----------------------------------------------------------------|---------|
| `erfolgsbasis` (Target Best Effort) | **Rückvergütungs-Staffel 50/25/10/0 %** (Monat 1/2/3/>3) · Cancellation pre-Antritt = 100 % | Gutschrift erstellen |
| `target_exklusiv` (Mandat) | **Ersatzbesetzung** (neue Suche) · keine Geld-Rückzahlung      | Neuer Prozess auf selbem Mandat |
| `taskforce` (Mandat)       | **Ersatzbesetzung** · bei Mandats-Kündigung: [[mandat-kuendigung]] 80 %-Floor | — |
| `time`                     | Keine Garantieleistung (Kunde führt Prozess selbst)            | — |

4. **Refund-Drawer** (Phase F): zeigt modell-spezifische Sektion via `procVarSwitch`-Router
   - Erfolgsbasis-Pfad (`#refundPathErfolgsbasis`): Staffel-Tabelle + Gutschrift-Button (Template `Vorlage_Rechnung Rückerstattung.docx`)
   - Mandat-Pfad (`#refundPathMandat`): Ersatzbesetzungs-Hinweis + „Ersatzbesetzungs-Prozess starten"-Button
5. **Provisions-Effekt (CRM 2.0):** `fact_candidate_guarantee.status = 'breached_refund' | 'breached_replacement'` → 20 %-Rücklage-Gegenrechnung + Net-Fee-Storno (Details: [[provisionierung]])

### Direkteinstellungs-Schutzfrist — Abgrenzung (CLAUDE.md §Schutzfrist-Regel)

Die **Garantiefrist** (AGB §5, 3 Mt, seriell pro Placement) ist **klar getrennt** von der **Direkteinstellungs-Schutzfrist** (AGB §6, 12 Mt default / 16 Mt bei Kunde-Nicht-Kooperation). Beide greifen in unterschiedlichen Situationen und sind **nicht vermischbar**:

| Konzept | Dauer | Startpunkt | Aktiv wenn | Rechtsfolge |
|---------|-------|-----------|-----------|-------------|
| **Garantiefrist** (AGB §5) | 3 Mt (optional verlängert bis 6) | Hire-Date (Placement-Start) | Nach Placement | Rückvergütung ODER Ersatzbesetzung bei Early-Exit |
| **Schutzfrist** (AGB §6) | 12 Mt default / 16 Mt Verlängerung | **Kandidaten-Vorstellung beim Kunden** (nicht Placement) | NUR bei NICHT-Placement (Prozess endete Rejection/Stale/Closed) | Honorar-Anspruch bei Direkteinstellung hintenrum |

**Kritische Nicht-Mischung:**
- Schutzfrist startet mit Vorstellung (Vermittlungsversuch), **nicht mit Placement**
- Schutzfrist greift **nur bei NICHT-Placement**. Bei Placement → `fact_protection_window.status='honored'` für dieses Kandidat × Kunde-Paar, Schutzfrist nicht mehr aktiv (Geschäft abgeschlossen, Fee verdient)
- UI: Schutzfrist-Übersicht gehört **nicht** in Post-Placement-Widget. Separater Ort: Account-Tab „Schutzfristen" / Kandidat-Tab „Offene Schutzfristen"

**Claim-Workflow** (Detection hintenrum-Einstellung während aktiver Schutzfrist): separater `fact_direct_hire_claim`-Record — erzeugt **keine** nachträgliche Garantiefrist. Details: [[direkteinstellung-schutzfrist]] §Claim-Workflow.

### Status → Closed

Auto beim Erreichen von `start_date + garantie_months` (Nightly Batch). Bei Early Exit: Status bleibt bei Placed mit `early_exit_flag` bis Rückvergütung abgeschlossen, dann → Closed.

---

## TEIL 8: SLIDE-IN-DRAWER (im Pipeline-Modul)

Obwohl Teil des Pipeline-Moduls (separates Spec-Dokument), hier kurz dokumentiert für Konsistenz:

**Inhalt des 540px-Drawers:**

- Kandidat-Mini-Card (Foto, Name, Funktion, Link)
- Pipeline-Visualisierung (9 Stages kompakt)
- Stage-Dropdown + Optimistic Update
- Nächstes Interview (Datum + Typ)
- Letzte 3 Aktivitäten aus History
- Verknüpfungs-Chips: Account, Job, Mandat (falls vorhanden)
- Quick-Actions: Ablehnen / On Hold / Platzieren / Interview setzen
- "→ Vollansicht öffnen" Header-Link (→ `/processes/[id]`)

**Drawer vs. Detailseite — Entscheidungs-Regel:**
- Drawer öffnet bei Row-Click in Pipeline
- Detailseite über `→ Vollansicht` oder direkte URL
- Drawer-Edits werden 1:1 in DB gespeichert — beide Views zeigen gleiche Quelle

---

## TEIL 9: EVENTS & AUDIT

| Event | Scope |
|-------|-------|
| `process_created` | Kandidat + Account + Job + Prozess (+ Mandat if linked) |
| `stage_changed` | Prozess + Kandidat |
| `status_changed` | Prozess + Kandidat |
| `on_hold_set` / `on_hold_removed` | Prozess |
| `stale_detected` | Prozess + CM-Notification |
| `interview_scheduled` | Prozess + Kandidat + Account |
| `interview_rescheduled` | Prozess |
| `coaching_added` | Prozess |
| `debriefing_added` | Prozess |
| `rejected` | Prozess + Kandidat + Account (+ Mandat if linked) |
| `placed` | Prozess + Kandidat + Account + Mandat + Job |
| `placement_cancelled` | Prozess + Kandidat + Account |
| `early_exit_recorded` | Prozess + Kandidat + Account |
| `guarantee_refund_issued` | Prozess + Account |
| `process_closed` | Prozess (auto nach Garantie) |

**Audit:** Alle Status- und Stage-Änderungen gehen durch `fact_audit_log`.

---

## TEIL 10: VERKNÜPFUNGEN

### Zum Kandidaten
- Prozess erscheint in Kandidat-Tab 6 (Prozesse) als Zeile
- Kandidat-Assessment-Tab zeigt verknüpfte Assessments wenn Mandat Option IX
- Kandidat-History zeigt alle Prozess-Events (via Event-Log)

### Zum Account
- Prozess erscheint in Account-Tab 10 (Prozesse)
- Mandat-Filter ermöglicht Drill-Down (siehe Account-Interactions v0.2 TEIL 9)

### Zum Mandat
- Mandat-Tab 3 (Prozesse) zeigt alle Prozesse dieses Mandats
- Placement triggert Mandat-Billing (siehe TEIL 4)
- Mandat-Kündigung → Prozesse laufen weiter mit Banner "Zugehöriges Mandat wurde gekündigt"

### Zum Job
- Job-Detailseite Tab Jobbasket zeigt Prozesse
- Placement setzt `fact_jobs.status = 'filled'` + `filled_at`

---

## TEIL 11: PHASE 1.5 / PHASE 2 VORMERKLISTE

| Feature | Phase |
|---------|-------|
| AI-Estimate "erwartete Restdauer pro Stage" | 1.5 |
| Stale-Settings-UI (Admin-Einstellungen pro Stage) | 1.5 |
| Bulk-Actions in Pipeline (Multi-Select) | 1.5 |
| Outlook-Kalender-Integration tiefer (Raum-Buchung, Teilnehmer-Antworten lesen) | 2 |
| Automatische Interview-Slot-Vorschläge basierend auf Kalender | 2 |
| Candidate-facing Interview-Timeline (Portal) | 2 |
| AI-Coaching-Empfehlungen basierend auf Job + Kandidat-Profil | 2 |

---

## TEIL 12: METHODIK-REFERENZ

Erbt Event-System, RBAC, Patterns aus Kandidat/Mandat/Account-Interactions. Keine Abweichungen.

---

## Related Specs / Wiki

- `ARK_PROZESS_DETAILMASKE_SCHEMA_v0_1.md`
- Pipeline-Modul-Spec: separates Dokument (in `ARK_FRONTEND_FREEZE`)
- `ARK_MANDAT_DETAILMASKE_INTERACTIONS_v0_3.md` (Placement-Trigger → Mandat-Billing)
- `ARK_KANDIDATENMASKE_INTERACTIONS_v1_3.md` (Kandidat Tab 6 Prozesse)
- `ARK_ACCOUNT_DETAILMASKE_INTERACTIONS_v0_3.md` (Account Tab 10 Prozesse)
- [[prozess]], [[honorar-berechnung]], [[erfolgsbasis]], [[jobbasket]]
- [[referral-programm]], [[direkteinstellung-schutzfrist]]
- [[detailseiten-guideline]]
