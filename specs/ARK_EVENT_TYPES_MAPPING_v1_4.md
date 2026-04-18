# ARK CRM — `dim_event_types` Mapping-Entscheidungen v1.4

**Scope:** Mapping aller bestehenden v1.3 Event-Namen auf `create_history` + `default_activity_type_id`
**Zielversion:** Integration in `migrations/001_system_activity_types.sql` Schritt 7 (bisher TODO)
**Basis:** `ARK_BACKEND_ARCHITECTURE_v2_5.md` §Vollständige Event-Liste Phase 1 (Zeilen 1329–1354) + Nachtrag v2.5.1 (6 zusätzliche Events)
**Stand:** 17.04.2026
**Status:** Review ausstehend

---

## Kontext

Migration `001_system_activity_types.sql` Schritt 7 enthält nur Platzhalter-Mapping für 3 bestehende Events. Vor Produktions-Deploy müssen **alle ~55 bestehenden Events** explizit zugeordnet werden. Sonst:
- `create_history=false` (Default) → keine automatische Timeline-Row, obwohl User erwartet eine → Datenverlust aus Consultant-Sicht
- `create_history=true` ohne `default_activity_type_id` → Migration schlägt an DB-Constraint fehl

Dieses Dokument trifft die Entscheidungen pro Event.

---

## Entscheidungs-Regeln

Ein Event bekommt `create_history=true` wenn **alle** drei Kriterien erfüllt sind:

1. **User-sichtbarer Trigger:** Consultant erwartet Timeline-Eintrag für dieses Geschehen
2. **Klare Activity-Type-Zuordnung:** Es gibt genau einen passenden Typ aus `dim_activity_types`
3. **Keine Duplikation:** Kein anderer UI-Flow schreibt bereits eine Row für denselben Vorgang

Ein Event bekommt `create_history=false` wenn:

- Es sich um pure Infrastruktur-/Audit-Events handelt (→ `fact_audit_log` oder Queue-only reicht)
- Ein User-Flow bereits eine spezifische Row schreibt (Duplikat-Gefahr)
- Das Event zu unspezifisch ist (z.B. `candidate.updated` — welcher Feld-Change genau?)
- Es reine Dead-Letter/Circuit-Breaker/Retention-Ops-Signalisierung ist

---

## Mapping-Tabelle (komplett)

Legende: **#** = Activity-Type-Nummer aus `dim_activity_types` (bestehend oder neu v1.4). **neu?** = Activity-Type-Row fehlt, muss erstellt werden.

### Domäne KANDIDAT (9 Events)

| event_name | create_history | → Activity-Type | Kommentar |
|-----------|:---:|-----|-----------|
| `candidate.created` | false | — | User-Formular-Flow, eigene UI-Side-Effects |
| `candidate.stage_changed` | false | — | Zu generisch. Jeder Stage-Trigger hat spezifischen User-Flow (Briefing speichern → #62, Ghosting-Detection → #61) der eigene Row schreibt. Event selbst nur für Automation-Rules. |
| `candidate.updated` | false | — | Audit-Log via `fact_audit_log` + field-diff reicht |
| `candidate.deleted` | false | — | GDPR-Flow hat eigenen Row (#106), reine Deletion hier = audit-log |
| `candidate.merged` | true | **#111 (neu)** „System - Kandidat zusammengeführt" | User muss sehen dass Merge passierte. **Neue Row #111 erforderlich** (Kategorie System / Meta, actor_type=automation, source_system=event-worker). |
| `candidate.briefing_created` | true | #62 Briefing (bestehend) | Ersetzt bisherige ad-hoc `fact_history.insert` bei Briefing-Save |
| `candidate.document_uploaded` | true | #73 Dokument - Hochgeladen (v1.4) | Übernimmt Mapping von generischem `document.uploaded` für Kandidaten-Scope |
| `candidate.assessment_completed` | true | #56 Assessment - Ergebnisse erfasst (bestehend) | Bereits `is_auto=true` |
| `candidate.anonymized` | true | #106 System - Kandidat anonymisiert (GDPR) (v1.4) | Direktes Mapping |

### Domäne PROZESS (7 Events + Nachtrag)

| event_name | create_history | → Activity-Type | Kommentar |
|-----------|:---:|-----|-----------|
| `process.created` | false | — | User-Formular-Flow |
| `process.stage_changed` | false | — | Generisch. Spezifische Flows (Platzierung, Rejection, Hold) schreiben eigene Rows. Auto-Transitions über spezifischere Events (`process.auto_rejected`, `jobbasket.*`) |
| `process.placement_done` | true | #99 Placement - Vollständig abgeschlossen (v1.4) | Aliasing: `process.placement_done` === `process.placement_completed`. **Reviewer-Task:** Namensvereinheitlichung beschliessen (Empfehlung `process.placement_completed`) |
| `process.closed` | false | — | Rejection-UI-Flow hat eigene Row |
| `process.reopened` | true | **#112 (neu)** „Placementprozess - Wiedereröffnet" | User-relevant. **Neue Row #112.** |
| `process.on_hold` | true | **#113 (neu)** „Placementprozess - Pausiert" | Mit Wiederaufnahme-Datum aus Payload. **Neue Row #113.** |
| `process.rejected` | false | — | Rejection-Drawer-Flow schreibt passende `rejection_reason_*`-Row |
| `placement_failed` (v2.5.1) | false | — | Saga-Rollback = queue-only, Admin-Alert via Notification |

### Domäne JOB (6 Events)

| event_name | create_history | → Activity-Type | Kommentar |
|-----------|:---:|-----|-----------|
| `job.created` | false | — | User-Formular |
| `job.stage_changed` | false | — | Generisch |
| `job.filled` | false | — | Wird ohnehin als Saga-Substep V3 emittiert (queue-only). User sieht Placement über #99 |
| `job.cancelled` | true | **#114 (neu)** „Job - Abgesagt" | User-Entscheidung, aber auch via Mandat-Termination-Saga → User-Timeline relevant. **Neue Row #114.** |
| `job.vacancy_detected` | false | — | Interner Scraper-Vorfilter. Falls user-relevant → wird über `scrape.new_job_detected` (→ #87) dupliziert |
| `job.published` | false | — | Marketing-Aktion, eigener User-Flow falls vorhanden |

### Domäne MANDAT (4 Events + Nachtrag)

| event_name | create_history | → Activity-Type | Kommentar |
|-----------|:---:|-----|-----------|
| `mandate.created` | false | — | User-Formular |
| `mandate.stage_changed` | false | — | Research-Stage-UI hat eigene Logik (`mandate.research_stage_changed`) |
| `mandate.completed` | true | **#115 (neu)** „Mandat - Abgeschlossen" | User-Milestone. **Neue Row #115.** |
| `mandate.cancelled` | true | **#116 (neu)** „Mandat - Gekündigt" | Saga TX3 finalisiert. **Neue Row #116.** |
| `mandate.activated` | true | **#117 (neu)** „Mandat - Aktiviert" | Nach Unterzeichnung. **Neue Row #117.** |
| `mandate.research_stage_changed` | false | — | Research-UI schreibt spezifische Rows |
| `mandate_termination_failed` (v2.5.1) | false | — | Saga-Rollback = queue-only |

### Domäne CALL (3 Events)

| event_name | create_history | → Activity-Type | Kommentar |
|-----------|:---:|-----|-----------|
| `call.received` | true | **#118 (neu)** „Kommunikation - Eingehender Anruf (unklassifiziert)" | 3CX-Auto-Import. `categorization_status='pending'` gesetzt, User/AI klassifiziert später um auf passende Kontaktberührung-/Erreicht-Row. **Neue Row #118.** |
| `call.transcript_ready` | true | #101 AI - Call-Transkription fertig (v1.4) | Direktes Mapping |
| `call.missed` | true | **#119 (neu)** „Kommunikation - Anruf verpasst" | 3CX Missed-Call. **Neue Row #119.** |

### Domäne EMAIL (3 Events)

| event_name | create_history | → Activity-Type | Kommentar |
|-----------|:---:|-----|-----------|
| `email.received` | true | **#120 (neu)** „Kommunikation - Eingehende Email (unklassifiziert)" | Wenn kein Template-Match → Fallback-Row mit `categorization_status='pending'`. **Neue Row #120.** |
| `email.sent` | false | — | Template-Layer schreibt via `dim_email_templates.linked_activity_type_id` spezifische Rows (#22–32). Generisches `email.sent` ohne Template → kein Timeline-Eintrag |
| `email.bounced` | true | #103 Emailverkehr - Bounce (v1.4) | Direktes Mapping |

### Domäne DOKUMENT (5 Events)

| event_name | create_history | → Activity-Type | Kommentar |
|-----------|:---:|-----|-----------|
| `document.uploaded` | true | #73 Dokument - Hochgeladen (v1.4) | Direktes Mapping |
| `document.cv_parsed` | true | #74 Dokument - CV automatisch geparst (v1.4) | |
| `document.ocr_done` | true | #75 Dokument - OCR abgeschlossen (v1.4) | |
| `document.embedded` | true | #76 Dokument - Vektorindex aufgenommen (v1.4) | |
| `document.reparsed` | true | #77 Dokument - Neu geparst (v1.4) | |

### Domäne HISTORY (2 Events)

| event_name | create_history | → Activity-Type | Kommentar |
|-----------|:---:|-----|-----------|
| `history.created` | false | — | **Kritisch:** niemals true — rekursive Endlos-Events. Ist das Trigger-Event für Downstream (nicht selbst-erzeugend) |
| `history.ai_summary_ready` | false | — | Updated bestehende Row (AI-Summary-Feld), erzeugt keine neue Row |

### Domäne SCRAPER (5 Events)

| event_name | create_history | → Activity-Type | Kommentar |
|-----------|:---:|-----|-----------|
| `scrape.change_detected` | false | — | Umbrella-Event, wird zerlegt in spezifischere (`scrape.new_person` etc.) |
| `scrape.new_job_detected` | true | #87 Scraper - Neue Job-Stelle erkannt (v1.4) | |
| `scrape.person_left` | true | #86 Scraper - Person hat Account verlassen (v1.4) | |
| `scrape.new_person` | true | #85 Scraper - Neue Person bei Account (v1.4) | |
| `scrape.role_changed` | true | #88 Scraper - Rollenänderung erkannt (v1.4) | |

### Domäne MATCH (2 Events)

| event_name | create_history | → Activity-Type | Kommentar |
|-----------|:---:|-----|-----------|
| `match.score_updated` | false | — | Queue-only. Pendant zu `matching.scores_recomputed` (v1.4 queue-only) |
| `match.suggestion_ready` | false | — | UI-Event, triggert Notification/Banner, keine Timeline-Row |

### Domäne ASSESSMENT (3 Events)

| event_name | create_history | → Activity-Type | Kommentar |
|-----------|:---:|-----|-----------|
| `assessment.completed` | true | #56 Assessment - Ergebnisse erfasst (bestehend) | Direktes Mapping |
| `assessment.invite_sent` | true | #55 Assessment - Link versendet (bestehend) | Direktes Mapping |
| `assessment.expired` | true | **#121 (neu)** „Assessment - Abgelaufen" | Invitation expired ohne completion. **Neue Row #121.** |

### Domäne SYSTEM (4 Events)

| event_name | create_history | → Activity-Type | Kommentar |
|-----------|:---:|-----|-----------|
| `system.data_quality_issue` | false | — | Admin-Alert (z.B. fehlende Pflichtfelder), kein User-Timeline-Eintrag |
| `system.circuit_breaker_tripped` | false | — | Identisch mit `circuit_breaker.tripped` (v1.4 queue-only). Namensvereinheitlichung nötig. |
| `system.dead_letter_alert` | false | — | Identisch mit `dead_letter.alert` (v1.4 queue-only) |
| `system.retention_action` | true | #106 System - Kandidat anonymisiert (v1.4) | Wenn Entity=candidate. Sonst: create_history=false. **Reviewer-Task:** conditional mapping per entity-type. |

### Domäne JOBBASKET (5 Events)

| event_name | create_history | → Activity-Type | Kommentar |
|-----------|:---:|-----|-----------|
| `jobbasket.candidate_added` | false | — | Interner Zwischenschritt, User sieht den Jobbasket selbst als UI |
| `jobbasket.go_oral` | true | #91 Jobbasket - Mündliches GO erhalten (v1.4) | Direktes Mapping |
| `jobbasket.go_written` | true | #92 Jobbasket - Schriftliches GO erhalten (v1.4) | |
| `jobbasket.stage_assigned` | true | #93 Jobbasket - Zuweisung abgeschlossen (v1.4) | Bisher als `jobbasket.stage_changed` bezeichnet, Namensvereinheitlichung empfohlen |
| `jobbasket.cv_sent` | true | #95 Jobbasket - CV an Kunde versendet (v1.4) | |

### Domäne REMINDER (4 Events + v1.4)

| event_name | create_history | → Activity-Type | Kommentar |
|-----------|:---:|-----|-----------|
| `reminder.overdue` | false | — | Reminder-Inbox ist eigenes UI-Layer, keine Timeline-Zeile nötig |
| `reminder.interview_upcoming` | true | #71 Reminder - Interview steht bevor (v1.4) | |
| `reminder.interview_date_missing` | true | #72 Reminder - Interview-Datum fehlt (v1.4) | |
| `reminder.guarantee_expiring` | true | #81 Reminder - Garantie läuft ab (v1.4) | |

### Domäne ACCOUNT (2 Events)

| event_name | create_history | → Activity-Type | Kommentar |
|-----------|:---:|-----|-----------|
| `account.contact_left` | false | — | Dupliziert mit `scrape.person_left`. Falls manuell (AM markiert Kontakt als inaktiv) → eigener UI-Flow schreibt Row |

### Domäne CANDIDATE-extras (2)

| event_name | create_history | → Activity-Type | Kommentar |
|-----------|:---:|-----|-----------|
| `candidate.temperature_changed` | false | — | Identisch mit `temperature.updated` (v1.4 queue-only). Pure Metrik-Drift |
| `candidate.wechselmotivation_changed` | false | — | Audit-Log + Kandidatenprofil-UI |

### Nachtrag v2.5.1 — restliche 4 Events

| event_name | create_history | → Activity-Type | Kommentar |
|-----------|:---:|-----|-----------|
| `reminder_batch_created` | false | — | 5 Reminders werden einzeln in `fact_reminders` angelegt, Reminder-UI reicht |
| `interview_completed` | false | — | Technischer Flag nach Debriefing. Debriefing-UI schreibt die User-Row (#37/39/41/66) |
| `finding_expired_unreviewed` | false | — | Scraper-Queue-Housekeeping, Admin-Dashboard |
| `legal_hold_toggled` | false | — | Audit-Log only |

---

## Zusammenfassung

**create_history=true:** 28 Events (→ 28 Activity-Type-Mappings)

- Davon bestehende Activity-Types (v1.3 + v1.4): 17
- Davon **neue Activity-Types erforderlich** (#111–#121): 11

**create_history=false:** 32 Events

**Gesamt bestehend v1.3 gemappt:** ~55 Events (plus v1.4-Seeds = ~90 Events total)

---

## Neue Activity-Types #111–#121 (erforderlich)

Diese Rows ergänzen Stammdaten-Patch §Neue Sektionen. Erfordern zusätzliches Update in Migration-Script.

| # | Activity Type | Kategorie | Kanal | is_auto | entity_relevance | actor_type | source_system | is_notifiable | Beschreibung |
|---|---|---|---|---|---|---|---|---|---|
| 111 | System - Kandidat zusammengeführt | System / Meta | System | ✓ | candidate | automation | event-worker | false | Zwei Kandidaten-Profile via Merge zusammengeführt |
| 112 | Placementprozess - Wiedereröffnet | Placementprozess | System | ✓ | both | user | event-worker | true | Geschlossener Prozess wurde reaktiviert |
| 113 | Placementprozess - Pausiert | Placementprozess | System | ✓ | both | user | event-worker | true | Prozess mit Wiederaufnahmedatum on hold gesetzt |
| 114 | Job - Abgesagt | Placementprozess | System | ✓ | both | user | event-worker | true | Offene Stelle abgesagt (manuell oder durch Mandat-Kündigung) |
| 115 | Mandat - Abgeschlossen | Mandatsakquise | System | ✓ | account | user | event-worker | true | Mandat erfolgreich beendet |
| 116 | Mandat - Gekündigt | Mandatsakquise | System | ✓ | account | user | event-worker | true | Mandat vorzeitig gekündigt (Saga TX3) |
| 117 | Mandat - Aktiviert | Mandatsakquise | System | ✓ | account | automation | event-worker | true | Nach Unterzeichnung — erste Stage-Zahlung fällig |
| 118 | Kommunikation - Eingehender Anruf (unklassifiziert) | Kontaktberührung | Phone | ✓ | both | integration | threecx | false | 3CX-Auto-Import, `categorization_status=pending` — User/AI klassifiziert später |
| 119 | Kommunikation - Anruf verpasst | Kontaktberührung | Phone | ✓ | both | integration | threecx | false | 3CX Missed-Call |
| 120 | Kommunikation - Eingehende Email (unklassifiziert) | Emailverkehr | Email | ✓ | both | integration | outlook | false | Kein Template-Match, `categorization_status=pending` |
| 121 | Assessment - Abgelaufen | Assessment | System | ✓ | candidate | automation | nightly-batch | false | Assessment-Invite expired ohne Completion |

**Summe Activity-Types nach Mapping:**
- v1.3 Basis: 69
- v1.4 ersten Patch: +37 (#70–#106)
- v1.4 Mapping-Zusatz: +11 (#111–#121)
- **Neu-Total: 117 Rows**

---

## Implementierungs-Aufgaben

### Migration-Script-Update

`migrations/001_system_activity_types.sql` braucht:

- [ ] Zusätzlichen Seed-Block nach Schritt 4: 11 neue Activity-Types #111–#121
- [ ] Zusätzliche UPDATE-Statements in Schritt 7: vollständiges Mapping aller 28 `create_history=true`-Events (statt nur 3 Platzhalter)
- [ ] Validierungs-DO-Block erweitern: expected 48 neue Activity-Types (37+11)

### Stammdaten-Patch-Update

`specs/ARK_STAMMDATEN_PATCH_v1_3_to_v1_4_ACTIVITY_TYPES.md` braucht:

- [ ] Neuer Abschnitt „Mapping-Ergänzung: #111–#121" mit den 11 Rows
- [ ] Statistik-Block: Total 117 statt 106
- [ ] §14c Event-Katalog: Total 55 statt ~50 Event-Type-Mappings

### Spec-Update

`specs/ARK_SYSTEM_ACTIVITY_TYPES_SCHEMA_v1.md` braucht:

- [ ] §4.1 „Weitere user-sichtbare Events" erweitert um #111–#121
- [ ] §3 Kategorien-Rows-Counts aktualisieren

### Namensvereinheitlichung (Reviewer-Task)

Folgende Doppelnamen existieren — eine kanonische Version wählen:

| Variante A | Variante B | Empfehlung |
|------------|------------|------------|
| `process.placement_done` | `process.placement_completed` | **B** (konsistenter mit Saga-Naming) |
| `system.circuit_breaker_tripped` | `circuit_breaker.tripped` | **B** (kürzer, domain-konsistent mit Namespace-Style) |
| `system.dead_letter_alert` | `dead_letter.alert` | **B** |
| `jobbasket.stage_changed` | `jobbasket.stage_assigned` | **B** (spezifischer) |

Nach Freigabe: alte Namen als Alias in `dim_event_types` behalten (dep­recated_at setzen) oder hart umbenennen.

---

## Offene Punkte — resolved v1.3 (17.04.2026)

| # | Frage | Entscheidung | Doc-Ref |
|---|-------|--------------|---------|
| M1 | `system.retention_action` conditional | **2 separate Event-Types**: `system.retention_action.candidate` (→ history via #106) und `system.retention_action.other` (→ queue-only, `create_history=false`) | Decisions §M1 |
| M2 | `call.received`/`email.received` notifiable | **`is_notifiable=true`** für Fallback-Rows #118/#120 + Dashboard-Badge für AM zur Klassifizierung | Decisions §M2 |
| M3 | `placement_done` vs `placement_completed` | **`placement_completed` kanonisch**, Parallel-Phase über 2 Sprints mit identischem Mapping auf #99. Nach Rename: `placement_done.is_automatable=false`. Nach 3 Mt Grünphase: löschen | Decisions §M3 |
| M4 | `candidate.merged` Entity-Mapping | **Target-Kandidat** erhält Row. Source-History wird vor Merge in Target-History migriert. Bei anonymisiertem Source: nur Hash in Comment | Decisions §M4 |
| M5 | #111 vs #59–64 Abgrenzung | **Klar** — #111 ist spezifischer Merge-Event, #59–64 sind andere System-Events. Kein Konflikt. | Decisions §M5 |

### Amendment v1.3 — Konsequente Seed-Änderungen für Migration

**Zusätzliche `dim_event_types`-Seed-Zeilen statt des ursprünglichen `system.retention_action`:**

```sql
-- Alte (v1.2) Empfehlung: ein Event — ENTFERNT
-- Neue (v1.3): zwei separate Events

INSERT INTO ark.dim_event_types
  (event_name, event_category, entity_type, create_history,
   default_activity_type_id, default_actor_type, default_source_system, emitter_component)
VALUES
  ('system.retention_action.candidate', 'system', 'candidate', true,
   (SELECT id FROM ark.dim_activity_types WHERE activity_type_name = 'System - Kandidat anonymisiert (GDPR)'),
   'automation', 'nightly-batch', 'gdpr-retention-batch'),
  ('system.retention_action.other', 'system', 'system', false,
   NULL, 'automation', 'nightly-batch', 'gdpr-retention-batch');
```

**Parallel-Phase für `placement_done` Aliasing:**

```sql
-- Beide seeden, identisches Mapping
INSERT INTO ark.dim_event_types (event_name, ..., default_activity_type_id, create_history) VALUES
  ('process.placement_completed', ..., <id-activity-99>, true),
  ('process.placement_done', ..., <id-activity-99>, true);

-- Nach Backend-Rename (Ende Sprint-3):
UPDATE ark.dim_event_types SET is_automatable = false
  WHERE event_name = 'process.placement_done';
```

**Hart-Rename für 3 Events (keine Parallel-Phase, Cutover sauber weil low-traffic):**

| Alter Name | Neuer Name |
|-----------|------------|
| `system.circuit_breaker_tripped` | `circuit_breaker.tripped` |
| `system.dead_letter_alert` | `dead_letter.alert` |
| `jobbasket.stage_changed` | `jobbasket.stage_assigned` |

Alte Namen werden **nicht** geseedet — Emitter-Code wird in Sprint 1 umbenannt, Deploy atomar mit v2.6.

**`candidate.merged` Writer-Enrichment:**

Writer-Service implementiert für dieses Event Sonder-Logik:

```typescript
if (event.event_name === 'candidate.merged') {
  // fact_history-Migration: alle Rows von Source → Target
  await migrateHistoryRows(event.payload.source_id, event.payload.target_id)

  // Dann Merge-Row für Target schreiben (normaler Flow):
  await writeAutoHistory({
    ...,
    entity_id: event.payload.target_id,  // Target, nicht event.entity_id
    comment: `Zusammengeführt aus Kandidat ${sanitizeSourceName(event.payload.source_name)}`,
  })
}
```

Sonderfall: Wenn Source bereits via #106 anonymisiert → `sanitizeSourceName` liefert `[archiviert ####]`-Hash statt Name.

---

**Ende Mapping-Entscheidungs-Dokument v1.4.** Nach PO+Backend-Lead-Review: Migration-Script-Update + Stammdaten-Patch-Amendment.
