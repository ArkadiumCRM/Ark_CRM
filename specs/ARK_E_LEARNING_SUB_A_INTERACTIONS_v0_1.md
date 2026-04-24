---
title: "ARK E-Learning Sub A (Kurs-Katalog) — Interactions v0.1"
type: spec
created: 2026-04-20
updated: 2026-04-20
sources: []
tags: [elearning, erp, phase3, sub-a, interactions]
status: draft
author: Peter Wiederkehr + Claude (Brainstorming-Session 2026-04-20)
companion: ARK_E_LEARNING_SUB_A_SCHEMA_v0_1.md
---

# ARK E-Learning Sub A · Kurs-Katalog · Interactions v0.1

> **Companion:** DB-Schema, YAML-Formate, API-Endpoint-Contracts, UI-Seiten-Struktur und Enums in [`ARK_E_LEARNING_SUB_A_SCHEMA_v0_1.md`](ARK_E_LEARNING_SUB_A_SCHEMA_v0_1.md).

## 0. Scope

Dieses Dokument beschreibt das **Verhalten** von Sub A: Flows, Events, Worker-Trigger, State-Transitions und UI-Interactions. Struktur-Definitionen (Tabellen, Endpoints, YAML-Formate) liegen im SCHEMA-Begleitdokument.

## 1. Event-Typen (fact_history-Integration)

Konsistent mit ARK-Backend-Pattern: jede relevante Aktion als Event in `fact_history`. Neue Typen für Stammdaten-Patch `ARK_EVENT_TYPES_MAPPING_v1_4.md`.

| Event | Payload (Auszug) |
|-------|-------------------|
| `elearn_course_assigned` | `ma_id, course_id, reason, deadline, assigned_by` |
| `elearn_course_started` | `ma_id, course_id, enrollment_id` |
| `elearn_course_completed` | `ma_id, course_id, enrollment_id, duration_sec` |
| `elearn_lesson_completed` | `ma_id, lesson_id, time_spent_sec` |
| `elearn_quiz_attempted` | `ma_id, module_id, attempt_id, attempt_kind` |
| `elearn_quiz_passed` | `ma_id, module_id, attempt_id, score_pct` |
| `elearn_quiz_failed` | `ma_id, module_id, attempt_id, score_pct` |
| `elearn_freitext_submitted` | `review_id, ma_id, ma_answer_snippet` |
| `elearn_freitext_reviewed` | `review_id, reviewed_by, status, head_score` |
| `elearn_certificate_issued` | `ma_id, course_id, cert_id, pdf_url` |
| `elearn_badge_earned` | `ma_id, badge_type, course_id?` |
| `elearn_refresher_triggered` | `ma_id, course_id, new_assignment_id` |
| `elearn_role_change_triggered` | `ma_id, diff_course_ids[]` |
| `elearn_assignment_expired` | `ma_id, course_id, assignment_id` |
| `elearn_onboarding_finalized` | `ma_id, finalized_by` |
| `elearn_content_imported` | `commit_sha, counts, errors_count` |

## 2. Worker / Cron

| Worker | Trigger | Schedule | Zweck |
|--------|---------|----------|-------|
| `elearn_onboarding_initializer` | Event `user_created` | event-driven | Setzt `elearn_onboarding_active=true`, erzeugt Assignments aus Curriculum-Template |
| `elearn_role_change_watcher` | Event `user_role_changed` / `user_sparte_changed` | event-driven | Diff-basierte neue Assignments |
| `elearn_refresher_trigger` | Cron | `0 2 * * *` | Erzeugt Refresher-Assignments für überfällige Kurse |
| `elearn_deadline_expiry` | Cron | `0 6 * * *` | Setzt `fact_elearn_assignment.status=expired`, Event |
| `elearn_cert_generator` | Event `elearn_course_completed` (letztes Modul des Kurses) | event-driven | PDF erzeugen, S3-Upload, `dim_elearn_certificate` anlegen |
| `elearn_badge_engine` | Events `elearn_course_completed` / `elearn_quiz_passed` | event-driven | Badge-Regeln prüfen, Badges vergeben |
| `elearn_freitext_llm_scorer` | Event `elearn_freitext_submitted` (Queue, Concurrency 5) | event-driven | LLM-Call (Claude Haiku 4.5), `llm_score` und `llm_feedback` füllen |
| `elearn_attempt_finalizer` | Event `elearn_freitext_reviewed` (wenn letzte Review im Attempt) | event-driven | Final-Score, `attempt.status=finalized`, Event `passed`/`failed` |
| `elearn_sla_reminder` | Cron | `0 * * * *` (stündlich) | Reminder Tag 3, Escalation Tag 7, Auto-Confirm Tag 14 |

## 3. Import-Pipeline-Flow

**Trigger:** Push auf `main` des Content-Repos (z. B. `arkadium/ark-elearning-content`).

**Endpoint:** `POST /api/elearn/admin/import`
Header: `X-Git-Signature` (HMAC-SHA256, tenant-spezifisches Secret).
Body: GitHub-Webhook-Payload (`repo`, `ref`, `commits[]`, `head_commit`).

**Worker-Flow:**

1. HMAC verifizieren; bei Fehlschlag `401`, kein Import.
2. Repo in temporärem Ordner clonen/pullen (`@<head_commit.id>`).
3. Verzeichnis `courses/` rekursiv walken.
4. Pro Entity (Course/Module/Lesson/Question-Pool): YAML/Frontmatter gegen Zod-Schema validieren.
   - Fehler sammeln → Import mit Error-Report abbrechen (keine partiellen Upserts).
5. `content_hash` pro Entity berechnen (SHA-256 über normalisierten Content).
6. DB-Diff: Vergleich `(tenant_id, slug)` → neu / geändert / gelöscht.
7. Upsert, bei Content-Änderung Version inkrementieren. Alte Version bleibt für bestehende `fact_elearn_enrollment.course_version`-Referenzen.
8. Im Repo nicht mehr vorhandene Kurse → `dim_elearn_course.status='archived'`. MA-Enrollments bleiben unberührt, Kurs ist in neuen Zuweisungen nicht mehr wählbar.
9. Event `elearn_content_imported` mit `commit_sha`, Counts (imported/updated/archived/errors).
10. Response: `{ imported, updated, archived, errors }`.

**Audit:** Jeder Import als `fact_elearn_import_log`-Row (Commit-SHA, Trigger, Zeit, Counts, Errors). Sichtbar in `erp/elearn/admin/imports.html`.

**Manueller Re-Trigger:** `POST /api/elearn/admin/import/manual` mit `{ commit_sha? }`. Default: HEAD des Content-Repos. Admin-only.

## 4. Onboarding-Flow (neue MA)

### 4.1 Einstellung und Template-Zuweisung

1. Backoffice legt User in `dim_user` mit `role`, `sparte`, `start_date` an.
2. System setzt `dim_user.elearn_onboarding_active=true`.
3. Worker `elearn_onboarding_initializer` (Event `user_created`):
   - Lese Curriculum-Template für `(role, sparte)`. Fallback: `(role, null)` falls keines für Sparte definiert.
   - Erzeuge `fact_elearn_assignment` pro Kurs im Template mit `reason='onboarding'`, Default-Deadline 90 Tage (tenant-konfigurierbar via `dim_elearn_tenant.settings.onboarding_deadline_days`).
4. Backoffice erhält Drawer „Curriculum anpassen?" in `erp/elearn/team.html` MA-Detail.
   - Button „Template übernehmen" (Default) oder „Override bearbeiten".
5. Bei Override: `fact_elearn_curriculum_override` angelegt; Assignments entsprechend angepasst (removed → `status='cancelled'`, added → neue `fact_elearn_assignment`).

### 4.2 Step-by-Step-Unlock-Logik

- MA sieht alle zugewiesenen Onboarding-Kurse auf `erp/elearn/dashboard.html`.
- Startbar ist nur der **erste noch nicht abgeschlossene** Kurs in Curriculum-Reihenfolge (aus `fact_elearn_curriculum_override.course_ids` bzw. `dim_elearn_curriculum_template.course_ids`).
- Weitere Kurse sind UI-seitig gelockt (Schloss-Icon, Tooltip „Nach Abschluss von [vorherigem Kurs] verfügbar").
- **Unlock-Trigger:** letztes Modul des aktuellen Kurses `fact_elearn_quiz_attempt.status='finalized'` + `passed=true` → `fact_elearn_enrollment.status='completed'` → Event `elearn_course_completed` → UI-Computing entsperrt nächsten Kurs (kein zusätzliches Flag-Feld in DB nötig; UI berechnet aus Enrollment-Historie).

### 4.3 Pre-Test (Skip-Ahead)

- Voraussetzung: `dim_elearn_course.pretest_enabled=true`.
- Endpoint `POST /api/elearn/my/courses/:id/pretest` → erzeugt `fact_elearn_quiz_attempt` mit `attempt_kind='pretest'`.
- **Max 1 Versuch pro Kurs**: Backend lehnt zweiten Request mit `409 Conflict` ab, falls bereits ein Pre-Test-Attempt existiert.
- Fragen-Ziehung: Pool-Union aller Module-Fragen des Kurses, zufälliges Subset (konfigurierbar, Default 20 Fragen).
- Höhere Hürde: `dim_elearn_course.pretest_pass_threshold` (Default 90).
- **Bestanden:** alle Enrollment-Module als `fact_elearn_enrollment.status='completed'` markieren, Kurs-Enrollment `completed_at=NOW()`. Cert wird ausgestellt (Sektion 9), nächster Onboarding-Kurs entsperrt.
- **Nicht bestanden:** normaler Lesson-/Modul-Durchlauf startet. Pretest-Attempt bleibt in History.

## 5. Status-Switch: Onboarding → Bestehend

**Manuell durch Head aus `erp/elearn/team.html` MA-Detail-Drawer.**

1. Head klickt „Onboarding abschliessen".
2. Confirm-Modal: „[MA-Name] wird zu bestehendem MA — freie Kurs-Auswahl, Onboarding-Lock entfällt, Fortschritte bleiben."
3. Bei Bestätigung: `dim_user.elearn_onboarding_active=false`, Event `elearn_onboarding_finalized`.

**Behandlung nicht abgeschlossener Onboarding-Assignments:**
- Bleiben als `fact_elearn_assignment.reason='onboarding'` aktiv.
- Erscheinen bei MA unter Tab „Pflicht" (weil Assignment existiert) **ohne** Step-Lock.
- MA kann sie in beliebiger Reihenfolge abschliessen.
- Head kann einzelne cancelen (`status='cancelled'` per `POST /api/elearn/team/members/:id/assign` mit `action='cancel'`).

## 6. Refresher-Zyklus

**Worker:** `elearn_refresher_trigger`, Cron `0 2 * * *`.

**Logik:**

```sql
SELECT e.tenant_id, e.ma_id, e.course_id
FROM fact_elearn_enrollment e
JOIN dim_elearn_course c USING (tenant_id, course_id)
WHERE e.status = 'completed'
  AND c.refresher_months IS NOT NULL
  AND e.completed_at < NOW() - (c.refresher_months || ' months')::INTERVAL
  AND NOT EXISTS (
    SELECT 1 FROM fact_elearn_assignment a
    WHERE (a.tenant_id, a.ma_id, a.course_id) = (e.tenant_id, e.ma_id, e.course_id)
      AND a.reason = 'refresher' AND a.status = 'active'
  );
```

**Pro Treffer:**
- Neue `fact_elearn_assignment` mit `reason='refresher'`, `deadline=NOW() + 30 days` (tenant-konfigurierbar).
- Notification an MA + Kopie an Head.
- Event `elearn_refresher_triggered`.
- Alte `fact_elearn_enrollment` bleibt als Historie. Neue Enrollment wird beim Start des Refresher-Kurses angelegt (auf aktuelle Course-Version gepinnt).

## 7. Rollen-/Sparten-Wechsel

**Worker:** `elearn_role_change_watcher` reagiert auf Events `user_role_changed` / `user_sparte_changed`.

**Logik:**

1. Lade altes Curriculum-Template für `(old_role, old_sparte)` → Kurs-Set A.
2. Lade neues Template für `(new_role, new_sparte)` → Kurs-Set B.
3. Diff `B \ A` = neue Pflicht-Kurse.
4. Pro Kurs in Diff:
   - Falls MA bereits `fact_elearn_enrollment.status='completed'` für diesen Kurs → skip.
   - Sonst: `fact_elearn_assignment` mit `reason='role_change'` oder `'sparten_change'`, `deadline=NOW() + 60 days`.
5. Notification an MA + Head.
6. Event `elearn_role_change_triggered` mit Diff-Kurs-Liste.

## 8. Deadline-Expiry

**Worker:** `elearn_deadline_expiry`, Cron `0 6 * * *`.

- `SELECT ... FROM fact_elearn_assignment WHERE status='active' AND deadline < NOW()` → `status='expired'`.
- Pro Treffer: Event `elearn_assignment_expired`.
- Gate-Logik (was passiert im CRM — Dashboard-Warnung, Feature-Sperre, Head-Report) gehört in Sub D. In Sub A nur Flag + Event.

## 9. Freitext-Review-Engine

### 9.1 Submit-Flow (MA)

**Synchron bei `POST /api/elearn/my/quiz/:attempt_id/submit`:**

1. Antworten validieren gegen bekannte Fragen-IDs aus `fact_elearn_quiz_attempt.answers`-Spec.
2. Pro Frage nach Typ scoren:
   - `mc`: match `correct`-Index.
   - `multi`: Jaccard-Match gegen `correct`-Array (Default: full-match = korrekt, Teil-Match = 0).
   - `truefalse`: match `correct` Boolean.
   - `zuordnung`: Anzahl korrekter Pairs / Total.
   - `reihenfolge`: Kendall-Tau oder strict-match (Default strict-match).
   - `freitext`: `fact_elearn_freitext_review`-Row anlegen mit `status='pending'`, **kein sofortiger Score**.
3. Partial-Score aus auto-scorbaren Fragen berechnen.
4. `fact_elearn_quiz_attempt.status`:
   - Falls ≥1 Freitext-Frage → `pending_review`.
   - Sonst → `finalized`, `score_pct` und `passed` direkt gesetzt.
5. Response: `{ partial_score_pct, pending_freitext_count, status }` plus Hinweis „X Freitext-Antworten werden geprüft".

### 9.2 LLM-Scorer-Worker

**Trigger:** Event `elearn_freitext_submitted` pro Review.

**Queue-Konfiguration:** Concurrency 5, Retry 3× mit Exponential-Backoff (2s → 8s → 30s).

**Prompt-Template (Default):**

```
System:
Du bewertest eine Freitext-Antwort eines Mitarbeiters in einem E-Learning-Kurs.
Gib einen Score von 0-100 und konstruktives Feedback in 1-3 Sätzen auf Deutsch.

Frage: {frage}
Musterlösung: {musterloesung}
Keywords (sollten vorkommen, direkt oder sinngemäss): {keywords}

MA-Antwort: {ma_answer}

Antworte ausschliesslich als JSON:
{"score": <0-100>, "feedback": "<text>", "confidence": <0-100>}
```

**Modell-Auswahl:**
- Default: `claude-haiku-4-5`.
- Override pro Tenant: `dim_elearn_tenant.settings.llm_model`.
- Optional Retry mit `claude-sonnet-4-6` falls `confidence < 60` (konfigurierbar).

**Fehler-Behandlung:**
- Nach 3 Retry-Fehlschlägen: `fact_elearn_freitext_review.llm_score=NULL`, `llm_feedback='LLM-Fehler, bitte manuell bewerten'`.
- Review bleibt `status='pending'` → Head muss manuell bewerten.

### 9.3 Head-Review

**UI:** `erp/elearn/freitext-queue.html` Review-Drawer (siehe §13.2).

**Endpoint:** `POST /api/elearn/team/freitext/:review_id` Body:
```json
{ "action": "confirm" | "override", "head_score"?: number, "head_feedback"?: string }
```

**Aktion `confirm`:**
- `head_score = llm_score`, `head_feedback = llm_feedback`, `status='confirmed'`.
- `reviewed_by = JWT.user_id`, `reviewed_at = NOW()`.

**Aktion `override`:**
- Explizite `head_score`, `head_feedback` gesetzt (beide Pflicht bei `override`).
- `status='overridden'`.

**Pro erfolgreicher Review:** Event `elearn_freitext_reviewed`.

### 9.4 Attempt-Finalizer

**Worker:** `elearn_attempt_finalizer`, getriggert durch Event `elearn_freitext_reviewed`.

**Logik pro Event:**

1. Prüfe, ob im zugehörigen Attempt noch `fact_elearn_freitext_review.status='pending'` existiert.
2. Falls **ja**: skip (nächste Review wird später triggern).
3. Falls **nein**:
   - Aggregiere Scores: auto-gescorte Fragen + `head_score` pro Freitext-Frage.
   - Gewichtung: jede Frage gleichgewichtet, sofern nicht `payload.weight` gesetzt. Freitext-Score wird auf Frage-Max-Score normiert.
   - `fact_elearn_quiz_attempt.score_pct = (sum(scores) / max_total) * 100`.
   - `passed = score_pct >= dim_elearn_course.pass_threshold` (via Join).
   - `status='finalized'`, `finalized_at=NOW()`.
   - Event `elearn_quiz_passed` oder `elearn_quiz_failed`.
   - Notification an MA: „Quiz ausgewertet — [bestanden | nicht bestanden], Feedback ansehen".

### 9.5 SLA + Escalation

**Worker:** `elearn_sla_reminder`, Cron stündlich.

Defaults (tenant-konfigurierbar in `dim_elearn_tenant.settings.sla`):

| Alter der Review | Aktion |
|------------------|--------|
| 3 Tage | Reminder-Notification an Head |
| 7 Tage | Escalation-Notification an Admin/Backoffice + Head |
| 14 Tage | Auto-Confirm via LLM-Score, **sofern `llm_score IS NOT NULL`**: `head_score=llm_score`, `head_feedback=llm_feedback`, `reviewed_by=<system-user-id>`, `status='confirmed_auto'`. Event `elearn_freitext_reviewed` wird emittiert → triggert Finalizer. Falls `llm_score IS NULL` (LLM-Fehler): **kein Auto-Confirm**; Review bleibt pending, weiter eskaliert. |

### 9.6 Impact auf Modul-/Kurs-Completion

- Solange `fact_elearn_quiz_attempt.status='pending_review'`: Modul nicht abgeschlossen.
- Step-by-Step-Logik (neue MA): nächstes Modul blockiert bis Review durch.
- Bestehende MA können in anderen Kursen parallel arbeiten.
- MA-Dashboard zeigt Badge „Quiz in Prüfung" bei Kurs-Card.

### 9.7 Re-Review nach Finalisierung

Einmal `status='confirmed' | 'overridden' | 'confirmed_auto'`: unveränderlich.

Korrektur nur via Admin-Endpoint `POST /api/elearn/admin/freitext/:id/revise`:
- Body: `{ new_score, new_feedback, reason }` (alle Pflicht).
- Admin/Backoffice-only.
- Schreibt neuen Audit-Eintrag in `fact_history` (Event `elearn_freitext_revised` mit before/after).
- Re-triggert Finalizer → `fact_elearn_quiz_attempt.score_pct` und `passed` werden neu berechnet → ggf. weiterer Event `elearn_quiz_passed`/`elearn_quiz_failed`.

## 10. Zertifikat-Ausstellung

**Worker:** `elearn_cert_generator`, getriggert durch Event `elearn_course_completed`.

**Logik:**

1. Prüfe, ob letztes Modul des Kurses `status='finalized'` + `passed=true` → Kurs gilt abgeschlossen.
2. Bei Pretest-Skip: Kurs direkt abgeschlossen, Cert analog.
3. Lade MA-Name, Kurs-Titel, Datum, Arkadium-Logo.
4. Generiere PDF via Template (Puppeteer oder PDFKit).
5. Upload nach S3/Blob-Storage, public-read URL.
6. Insert `dim_elearn_certificate (ma_id, course_id, course_version, pdf_url, issued_at)`.
7. Event `elearn_certificate_issued`.
8. Notification + Email (optional) an MA mit Download-Link.

## 11. Badge-Engine

**Worker:** `elearn_badge_engine`, getriggert durch Events `elearn_course_completed` / `elearn_quiz_passed`.

**Regeln (erweiterbar):**

| Badge | Trigger-Bedingung |
|-------|-------------------|
| `first_course` | Erstes `elearn_course_completed` des MA |
| `all_onboarding` | Alle Onboarding-Assignments `completed` |
| `sparte_expert` | Alle Kurse der eigenen Sparte `completed` |
| `streak_7` | 7 Tage in Folge mindestens 1 `elearn_lesson_completed` |

Pro Badge-Vergabe: Insert in `dim_elearn_badge`, Event `elearn_badge_earned`, Notification.

**Idempotenz:** Pro `(tenant_id, ma_id, badge_type, course_id?)` nur einmal vergeben. UNIQUE-Constraint + `ON CONFLICT DO NOTHING`.

## 12. Multi-Tenant-Transfer (Edge-Case, MVP-Deferral)

Bei Tenant-Wechsel eines MA:
- Enrollments, Attempts, Certs beim alten Tenant bleiben Audit.
- Neuer Tenant startet mit leerem Slate.
- Cert/Badge-Portierung ist Admin-Decision, Phase-2.

Kein Code in Sub A; hier nur dokumentiert, damit Schema-Design konsistent bleibt.

## 13. UI-Interactions

### 13.1 Lesson-Viewer (`erp/elearn/lesson.html`)

**Scroll-Tracker (Heartbeat-Pattern):**
- Client misst `scroll_pct` (max erreichter Scroll) und `time_sec` (aktive Lesezeit, pausiert bei Tab-Unfocus).
- Heartbeat alle 15 s: `POST /api/elearn/my/lessons/:lid/progress` mit `{ scroll_pct, time_sec, completed: false }`.
- Sticky-Footer-Button **„Erledigt ✓"** aktiv, wenn `scroll_pct ≥ 90` UND `time_sec ≥ dim_elearn_lesson.min_read_seconds`.
- Klick „Erledigt" → finaler `POST /progress` mit `completed: true`, `completed_at=NOW()` → Event `elearn_lesson_completed` → Navigation zur nächsten Lesson oder Quiz.
- Footer-Navigation: `← Vorherige` (frei zugänglich) · `Erledigt ✓` · `Nächste →` (ausgegraut bis Erledigt).

**Embed-Handling:**
- `![[image.png]]` → `<img src="/assets/{tenant}/{image}">` aus Content-Repo-Assets.
- `{% embed pdf="file.pdf" page=N %}` → embedded PDF-Viewer (PDF.js) mit Deep-Link auf Seite N.
- `{% embed youtube="ID" %}` → YouTube-iframe mit `enablejsapi=1` für Analytics (optional).

### 13.2 Quiz-Runner (`erp/elearn/quiz.html`)

- Fragen sequenziell, Progress-Bar oben „Frage 4/10".
- Pro Fragen-Typ separates React/Vue-Component:
  - `mc`: Radio-Buttons.
  - `multi`: Checkboxes.
  - `truefalse`: zwei grosse Buttons.
  - `zuordnung`: Drag-Drop (left-col → right-col, HTML5 DnD).
  - `reihenfolge`: Drag-Drop vertikal zum Sortieren.
  - `freitext`: Textarea mit Char-Counter, optional Speech-to-Text (Phase-2).
- **Keine Zwischenspeicherung** — Antworten nur im Client-State. Verhindert Copy-Paste aus Retry-Versuchen.
- **Back-Navigation** nach Submit blockiert (Warnung „Abbruch verwirft Antworten").
- „Abschicken" nur am Ende verfügbar; sendet alle Antworten in einem `POST /submit`.

### 13.3 Freitext-Queue-Drawer (`erp/elearn/freitext-queue.html`)

**Layout (540 px Slide-in-Drawer):**

```
┌ Frage
│ Beschreibe den Unterschied zwischen GP und TU in 2 Sätzen.
│
├ Musterlösung
│ GP plant, koordiniert und überwacht. TU baut eigenverantwortlich mit Pauschalpreis.
│
├ Keywords
│ [planen] [überwachen] [pauschalpreis] [eigenverantwortlich]
│
├ MA-Antwort (Marc Müller)
│ "Der Generalplaner macht alle Pläne und schaut dass alles stimmt.
│  Der Totalunternehmer baut dann für einen fixen Preis alles fertig."
│
├ LLM-Vorschlag (Claude Haiku)
│ Score: ████████░░ 85 %
│ Feedback: "Alle Keywords getroffen, Kernaussage korrekt. Minor:
│           'koordiniert' nicht explizit, aber 'alles stimmt' deckt
│           Überwachung ab. Volle Punktzahl möglich."
│
├ [Head-Override]
│ Score: ████████░░ 85  [Slider 0-100]
│ Feedback: [Textarea vorgefüllt mit LLM-Text, editierbar]
│
└ [LLM bestätigen]   [Überschreiben + speichern]
```

**Keyboard-Shortcuts:**
- `J` / `K` → next / prev Review in Queue.
- `Enter` → „LLM bestätigen".
- `O` → Fokus auf Override-Slider.
- `Esc` → Drawer schliessen.

**Batch-Modus:**
- Multi-Select-Checkbox in Queue-Table.
- Action-Button „Alle mit LLM ≥ 80 bestätigen" (Confirm-Modal mit Anzahl).
- Einzelne Reviews können aus Batch-Auswahl ausgeschlossen werden.

**Farb-Codierung LLM-Score in Queue:**
- rot < 50
- gelb 50–79
- grün ≥ 80

### 13.4 Team-Detail-Drawer (`erp/elearn/team.html`)

**Trigger:** Klick auf MA-Zeile in Team-Tabelle.

**Inhalt (540 px Drawer):**
- Header: MA-Name, Rolle, Sparte, Onboarding-Status (Badge).
- Sektion „Aktive Kurse": Liste mit Progress-Balken.
- Sektion „Offene Pflicht": Assignments mit Deadline.
- Sektion „Historie": abgeschlossene Kurse mit Datum, Score, Cert-Download.
- Sektion „Attempts": alle Quiz-Attempts inkl. Retries, Head kann Details einsehen.
- Aktionen (Buttons):
  - „Ad-hoc Kurs zuweisen" → Sub-Drawer mit Kurs-Picker + Deadline-Picker + Reason-Freitext.
  - „Onboarding abschliessen" (nur sichtbar wenn `elearn_onboarding_active=true`) → Confirm-Modal → Status-Switch.
  - „Curriculum-Override bearbeiten" → Sub-Drawer mit Drag-Drop-Kursliste.

### 13.5 Dashboard-Card-States (MA)

Auf `erp/elearn/dashboard.html` pro Kurs-Card sichtbarer Status:

| State | Visual |
|-------|--------|
| Gesperrt (Step-Lock) | Schloss-Icon, ausgegraut, Tooltip mit vorherigem Kurs |
| Nicht gestartet | „Jetzt starten" Button, Progress-Ring 0 % |
| In Arbeit | Progress-Ring X %, Modul-Stand angezeigt |
| Quiz in Prüfung | Badge „In Prüfung", Progress-Ring bei Stand eingefroren |
| Abgeschlossen | Checkmark + „Erneut anschauen"-Button |
| Refresher fällig | Gelbes Badge „Refresher fällig", Deadline angezeigt |
| Deadline überschritten | Rotes Badge „Überfällig" |

### 13.6 Admin-Import-Retry (`erp/elearn/admin/imports.html`)

**Trigger:** Klick „Retry" in Import-Timeline-Row.

- Öffnet Confirm-Modal mit Commit-SHA-Bestätigung.
- `POST /api/elearn/admin/import/manual` mit `{ commit_sha }`.
- Neue Zeile in Timeline wird angelegt (`trigger='manual'`), alte bleibt mit ihren Errors als Historie.

## 14. State-Diagramme (Summary)

### 14.1 `fact_elearn_assignment.status`

```
  (init) --> active
  active --> completed   (via fact_elearn_enrollment.status='completed')
  active --> expired     (via elearn_deadline_expiry Worker)
  active --> cancelled   (via Head/Admin-Action)
  completed/expired/cancelled  --> [terminal]
```

### 14.2 `fact_elearn_quiz_attempt.status`

```
  (init) --> in_progress
  in_progress --> pending_review   (submit mit Freitext-Fragen)
  in_progress --> finalized        (submit ohne Freitext → direkt final)
  pending_review --> finalized     (via elearn_attempt_finalizer nach letzter Review)
  finalized --> [terminal]
```

### 14.3 `fact_elearn_freitext_review.status`

```
  (init) --> pending
  pending --> confirmed        (Head: action=confirm)
  pending --> overridden       (Head: action=override)
  pending --> confirmed_auto   (SLA-Tag 14, nur wenn llm_score IS NOT NULL)
  confirmed/overridden/confirmed_auto --> [terminal, ausser Admin-Revise]
```

### 14.4 `dim_elearn_course.status`

```
  (init) --> draft
  draft --> published     (Admin-Action POST /publish)
  published --> archived  (Admin-Action POST /archive oder Import-Walk findet Kurs nicht mehr)
  archived --> published  (Admin-Action, reaktivieren)
```

## 15. Nächste Schritte

1. Peter reviewt SCHEMA + INTERACTIONS.
2. Freigabe → Implementation Plan via `superpowers:writing-plans`.
3. Optional: Mockup-Skizzen (Claude Design → Claude Code Handoff) für MA-Dashboard, Lesson-Viewer, Freitext-Queue-Drawer.
4. Grundlagen-Patches schreiben (siehe SCHEMA §10).
5. Sub B Brainstorming starten, sobald Sub A implementiert und validiert ist.
