---
title: "ARK E-Learning Sub C (Wochen-Newsletter) — Interactions v0.1"
type: spec
created: 2026-04-20
updated: 2026-04-20
sources: []
tags: [elearning, erp, phase3, sub-c, interactions, newsletter]
status: draft
author: Peter Wiederkehr + Claude (Brainstorming-Session 2026-04-20)
companion: ARK_E_LEARNING_SUB_C_SCHEMA_v0_1.md
depends_on: ARK_E_LEARNING_SUB_A_INTERACTIONS_v0_1.md, ARK_E_LEARNING_SUB_B_INTERACTIONS_v0_1.md
---

# ARK E-Learning Sub C · Wochen-Newsletter · Interactions v0.1

> **Companion:** DB, API, UI, Enums in [`ARK_E_LEARNING_SUB_C_SCHEMA_v0_1.md`](ARK_E_LEARNING_SUB_C_SCHEMA_v0_1.md)

## 0. Scope

Flows für Newsletter-Generation, Publish, Read-Tracking, Quiz-Run, Soft-Enforcement (Reminder + Head-Escalation). State-Transitions und UI-Interactions.

## 1. Event-Typen

| Event | Payload (Auszug) |
|-------|-------------------|
| `elearn_newsletter_issue_drafted` | `issue_id, sparte, issue_week, generation_job_id` |
| `elearn_newsletter_issue_published` | `issue_id, sparte, assignments_count` |
| `elearn_newsletter_assigned` | `assignment_id, ma_id, issue_id, enforcement_mode_applied, deadline` |
| `elearn_newsletter_read_started` | `assignment_id, ma_id` |
| `elearn_newsletter_read_completed` | `assignment_id, ma_id, sections_count` |
| `elearn_newsletter_quiz_passed` | `assignment_id, ma_id, attempt_id, score_pct` |
| `elearn_newsletter_quiz_failed` | `assignment_id, ma_id, attempt_id, score_pct` |
| `elearn_newsletter_reminder_sent` | `assignment_id, ma_id, reminder_number` |
| `elearn_newsletter_escalated_to_head` | `assignment_id, ma_id, head_id, age_days` |
| `elearn_newsletter_expired` | `assignment_id, ma_id, issue_id` |
| `elearn_newsletter_subscription_added` | `sub_id, ma_id, sparte, mode` |
| `elearn_newsletter_enforcement_override_set` | `ma_id, mode, set_by` |

## 2. Worker / Cron

### 2.1 Cron-Worker

| Worker | Schedule | Zweck |
|--------|----------|-------|
| `elearn-newsletter-generator` | `settings.elearn_c.publish_day_cron` (Default Mo 06:00) | Pro Tenant, pro Sparte: R1–R4b-Pipeline triggern, erzeugt Draft-Issue |
| `elearn-newsletter-publisher` | stündlich | Draft-Issues im Review-Zustand ab `publish_at` auf `published` setzen, Assignments erzeugen |
| `elearn-newsletter-reminder` | stündlich | Soft-Enforcement: Reminder nach `reminder_hours`, Head-Escalation nach `escalation_days`, Expiry nach `expiry_days` |

### 2.2 Event-driven Worker

| Worker | Trigger-Event | Zweck |
|--------|---------------|-------|
| `elearn-newsletter-subscription-initializer` | `user_created` | Auto-Sub für `dim_user.sparte` + übergreifend falls enabled |
| `elearn-newsletter-subscription-syncer` | `user_sparte_changed` | Alte Sparte: Sub beenden; neue: Sub aktivieren |
| `elearn-newsletter-assignment-creator` | `elearn_newsletter_issue_published` | Pro Abonnent: `fact_elearn_newsletter_assignment` anlegen, Enforcement-Mode-Snapshot aus Tenant-Setting + MA-Override |

## 3. Generation-Flow (R4b Newsletter-Runner)

### 3.1 Trigger

- **Scheduled:** `elearn-newsletter-generator` läuft nach Cron. Für jede Tenant × `sparten_enabled`-Kombi ein Job.
- **Manual:** Admin-Endpoint `POST /api/elearn/admin/newsletter/generate` mit `{sparte, issue_week}`.

### 3.2 R4b-Runner Ablauf

1. **Content-Fundus sammeln:** Chunks aus `dim_elearn_chunk` der letzten 7 Tage, gefiltert nach `source.sparten ∋ sparte` oder `sparten=[]` (übergreifend).
2. **Clustering (R3-Reuse):** Chunks nach Themen gruppiert; pro Thema Similarity-Score + Chunk-Count.
3. **Section-Entscheidung (LLM):** Prompt `newsletter-structure-prompt`:
   ```
   Basierend auf diesen Themen-Clustern aus der Vorwoche für Sparte {sparte}:
   {cluster_summaries}

   Wähle 3-6 Section-Typen aus [market_news, crm_insights, deep_dive, spotlight, trend_watch, ma_highlight]
   und ordne sie in eine Leseflow-Reihenfolge. Gib JSON zurück:
   {"title": "<Wochen-Titel>", "sections": [{"type": ..., "title": ..., "cluster_ids": [...]}, ...]}
   ```
4. **Pro Section:** LLM-Call mit `newsletter-section-prompt`, zieht konkrete Chunks als RAG-Kontext:
   ```
   Schreibe den Section-Body "{section_title}" ({section_type}) für den Wochen-Newsletter.
   Kontext-Chunks:
   {chunks_text}

   Format: Markdown, 200-600 Wörter. Aktiv, professionell, knapp.
   Keine Meta-Kommentare ("In dieser Woche..."), direkt einsteigen.
   ```
5. **Quiz-Generation:** LLM-Call `newsletter-quiz-prompt`:
   ```
   Basierend auf den Newsletter-Sections:
   {sections_markdown_concat}

   Generiere zwischen {min_q} und {max_q} Quiz-Fragen (gemischte Typen: mc, multi, truefalse, freitext).
   Fragen sollen Lese-Aufmerksamkeit prüfen, keine Trivia. Gib YAML zurück im Schema aus Sub A.
   ```
6. **DB-Write:**
   - Synthetischer `dim_elearn_module` angelegt (verknüpft mit verstecktem Newsletter-Kurs).
   - `dim_elearn_question`-Rows für Quiz-Pool.
   - `dim_elearn_newsletter_issue` mit `sections JSONB`, `quiz_module_id`, `status='draft'`, `publish_at` aus Tenant-Setting.
7. **Event:** `elearn_newsletter_issue_drafted`.

### 3.3 Admin-Review (optional, Tenant-Setting)

Default: Drafts gehen direkt auf `status='review'` und werden ab `publish_at` automatisch published. Tenant-Setting `require_admin_review` kann Zwischenschritt einbauen (Phase-2).

## 4. Publish-Flow

**Worker:** `elearn-newsletter-publisher` (stündlich).

1. Finde Issues mit `status='review'` und `publish_at <= NOW()`.
2. Setze `status='published'`, `published_at=NOW()`.
3. Event `elearn_newsletter_issue_published`.
4. `elearn-newsletter-assignment-creator` reagiert → pro Abonnent:
   - Lade Subscriptions: `dim_elearn_newsletter_subscription` WHERE `mode IN ('auto', 'opt_in') AND sparte = issue.sparte`.
   - Für jeden Abonnent: `fact_elearn_newsletter_assignment` mit:
     - `deadline = publish_at + expiry_days`
     - `enforcement_mode_applied` = MA-Override falls gesetzt, sonst Tenant-Setting.
     - `status='pending'`.
   - Event `elearn_newsletter_assigned` pro Assignment.
5. In-App-Benachrichtigung pro MA: „Neuer Newsletter KW17 — jetzt lesen".

## 5. Read-Flow (MA-Sicht)

### 5.1 Newsletter öffnen

1. MA öffnet `erp/elearn/newsletter.html` → Tab „Aktuell" zeigt alle Assignments mit `status IN ('pending','reading','quiz_in_progress')`.
2. Klick auf Assignment → `erp/elearn/newsletter-issue.html?id=<issue_id>`.
3. Beim ersten Öffnen: `POST /read-start` → `status='reading'`, `read_started_at=NOW()`, Event.

### 5.2 Section-Lesen

1. UI rendert Sections sequentiell (scrollable single-page).
2. Pro Section läuft Scroll-Tracker (analog Sub A Lesson-Viewer):
   - Scroll-Pct und Time-Spent-Sec.
   - Heartbeat alle 10 s: `POST /sections/:idx/progress`.
3. Section gilt „gelesen" bei `scroll_pct >= 90` AND `time_spent_sec >= 20` (Default, pro Section-Typ anpassbar über `section.min_read_seconds` in JSONB).

### 5.3 Quiz-Start

1. Wenn alle Sections `read_at IS NOT NULL` → Quiz-Button aktivierbar.
2. Button „Quiz starten" → `POST /quiz/start` → erzeugt `fact_elearn_quiz_attempt` mit `attempt_kind='newsletter'` und `module_id=issue.quiz_module_id`.
3. UI leitet weiter zu `erp/elearn/quiz.html?attempt_id=<id>` (Sub-A-Quiz-Runner).
4. Status → `quiz_in_progress`.

### 5.4 Quiz-Submit

- Quiz-Submit-Flow identisch Sub A (Sektion 9 in Sub-A-INTERACTIONS).
- Nach Finalisierung (inkl. Freitext-Review falls vorhanden):
  - `passed=true` → Assignment `status='quiz_passed'`, Event, Feature-Lock (Sub D) gehoben falls hard-Mode.
  - `passed=false` → Assignment `status='quiz_failed'`. Retry möglich; nach Retry wieder `quiz_in_progress`.

## 6. Enforcement-Flow

Worker `elearn-newsletter-reminder` läuft stündlich und scannt `fact_elearn_newsletter_assignment` mit `status NOT IN ('quiz_passed','expired')`.

### 6.1 Soft-Enforcement-Flow

**Default (`enforcement_mode_applied='soft'`):**

```
T0  = publish_at  → Assignment erstellt, Banner im Dashboard
T+reminder_hours (48h default):
    - Falls status still 'pending': Reminder-Notification an MA
    - `reminder_sent_at = NOW()`, Event `elearn_newsletter_reminder_sent`
T+escalation_days (7d default):
    - Falls status NOT IN ('quiz_passed','expired'):
        - Notification an Head-of (Team) mit MA-Liste
        - `escalated_to_head_at = NOW()`, Event `elearn_newsletter_escalated_to_head`
T+expiry_days (14d default):
    - Falls status NOT IN ('quiz_passed'):
        - `status = 'expired'`, Event `elearn_newsletter_expired`
        - Assignment-Chance vorbei, aber Newsletter bleibt im Archiv lesbar
```

**Edge-Cases:**
- Zweiter Reminder nach `reminder_hours * 2` optional (Tenant-Setting).
- Head-Escalation erfolgt nur einmal; weitere Überfälligkeit via Queue-Page `erp/elearn/admin/newsletter-queue.html`.

### 6.2 Hard-Enforcement-Flow

**Tenant- oder MA-konfiguriert (`enforcement_mode_applied='hard'`):**

- Assignments-State wird von Sub D gelesen.
- Sub D blockiert CRM-Zugriff für MA, sobald ein Hard-Assignment `status IN ('pending','reading','quiz_in_progress','quiz_failed','expired')` existiert.
- MA sieht Full-Screen-Gate-Page „Newsletter KW17 bearbeiten" mit Direct-Link zum Newsletter.
- Zugriff entsperrt sich erst bei `status='quiz_passed'`.

**Wichtig:** Enforcement-Mode wird **zum Assignment-Zeitpunkt gesnapshotet** (`enforcement_mode_applied`-Spalte). Änderung im Tenant-Setting wirkt nur auf zukünftige Assignments.

### 6.3 Mode-Switching

**Tenant-Default ändern:**
- Admin setzt `settings.elearn_c.enforcement_mode='hard'` via Config-Page.
- Event `elearn_newsletter_enforcement_default_changed`.
- Gilt für neue Assignments ab sofort.

**MA-Override:**
- Admin/Head setzt `dim_user.newsletter_enforcement_override='hard'` für spezifischen MA (z. B. wiederholt säumig).
- Endpoint `POST /api/elearn/admin/newsletter/enforcement-override`.
- Gilt für neue Assignments dieses MA ab sofort.
- UI zeigt MA im Admin-Bereich das Override-Flag an.

## 7. Subscription-Management

### 7.1 Auto-Subscription

Event `user_created` triggert `elearn-newsletter-subscription-initializer`:
- Für `dim_user.sparte`: `dim_elearn_newsletter_subscription (mode='auto')`.
- Falls `settings.elearn_c.sparte_uebergreifend_enabled=true`: zusätzlich für „uebergreifend".

### 7.2 Sparten-Wechsel

Event `user_sparte_changed`:
- Alte Sparte: Subscription `mode='auto'` → `status` wird zu inactive gesetzt (Flag), oder Row behalten und `mode='opt_out'` (falls Tenant erlaubt), sonst gelöscht.
- Neue Sparte: neue Auto-Sub.

### 7.3 Manuelle Opt-ins

MA kann im Profil oder in Newsletter-Page zusätzliche Sparten abonnieren:
- `POST /api/elearn/my/newsletter/subscriptions` mit `{sparte}` → `mode='opt_in'`.
- Kein Enforcement für Opt-in-Subs (nur Default-Sparte ist Pflicht).

### 7.4 Opt-out

- Default: `mode='auto'`-Subs können **nicht** abbestellt werden (Kern-Pflicht).
- Tenant-Setting `allow_auto_opt_out=true` macht es möglich → `mode='opt_out'`, keine weiteren Assignments.
- Opt-in-Subs jederzeit abbestellbar.

## 8. Archive-Flow

**Retention:** `settings.elearn_c.archive_retention_months` (Default 24).

**Worker-Job (Cron monatlich):**
- Issues älter als Retention → `status='archived'` (verschwinden aus MA-Archive-Tab; bleiben DB-seitig für Audit).
- Assignments bleiben als Audit bestehen.

**MA-Archive-Sicht:**
- `erp/elearn/newsletter.html` Tab „Archiv" zeigt alle Issues mit `status='published'` oder `'archived'` (Archiv-Issues grau).
- Filter nach Sparte, Jahr, Quiz-Status.

## 9. UI-Interactions

### 9.1 `erp/elearn/newsletter.html` (MA)

**Tabs:**
- **Aktuell:** Cards mit Assignments `status IN ('pending','reading','quiz_in_progress','quiz_failed')`. Jede Card zeigt: Sparte-Chip, Titel, Deadline-Countdown, Status-Badge, Pflicht-Banner bei hard-Enforcement.
- **Archiv:** Scroll-Liste aller vergangenen Ausgaben des MA (gelesen + ungelesen expired). Filter nach Sparte, Jahr.

### 9.2 `erp/elearn/newsletter-issue.html` (MA)

**Layout (single-page scroll):**
- Hero: Titel + Woche + Sparte + Lese-Fortschritt (X/Y Sections).
- Section-Blöcke sequentiell, jeder mit Scroll-Anchor.
- Sticky-Footer: „Quiz starten" (disabled bis alle Sections gelesen).
- Read-Progress-Indikator links als Vertical-Timeline.

### 9.3 `erp/elearn/admin/newsletter-config.html`

Tenant-Settings-Form:
- Publish-Schedule (Cron-Picker oder Wochentag+Uhrzeit-Picker).
- Sparten-Enable-Toggles.
- Enforcement-Mode (Radio: soft/hard), Reminder/Escalation/Expiry-Tage-Inputs.
- Archiv-Retention.
- Min/Max Sections + Fragen.

### 9.4 `erp/elearn/admin/newsletter-archive.html`

- Tabelle aller Issues mit Sparte, Woche, Publish-Datum, Assignments-Count, Read-Rate, Quiz-Pass-Rate.
- Zeile klicken → Drawer mit Preview + Metriken.

### 9.5 `erp/elearn/admin/newsletter-queue.html`

- Liste überfälliger Assignments, gruppiert nach Team.
- Pro Zeile: Head-Badge, Manual-Reminder-Button, Override-Mode-Button.

### 9.6 Keyboard-Shortcuts (Reading-Page)

- `PageDown` / Space → scroll to next section
- `PageUp` → previous section
- `Q` → Quiz starten (wenn eligible)

## 10. Fehler-Szenarien

| Szenario | Verhalten |
|----------|-----------|
| Generator-Fehler (LLM-Timeout) | Job `status='failed'`; Admin-Alert; keine Publish bis manueller Re-Run |
| Zu wenig Content (< 3 Cluster) | Generator skippt Ausgabe für diese Sparte + Woche; Event `elearn_newsletter_skipped_insufficient_content` |
| Quiz-Freitext-Review-Stau | Assignment bleibt `quiz_in_progress` bis Head reviewt (SLA analog Sub A) |
| MA inaktiv (`dim_user.status='inactive'`) | Assignment wird beim Create übersprungen |
| Sparten-Wechsel mitten in offenem Assignment | Alte Sparten-Assignments bleiben; MA muss fertig lesen (Historie) |

## 11. State-Diagramme

### 11.1 `fact_elearn_newsletter_assignment.status`

```
pending → reading → quiz_in_progress → quiz_passed
                         ↓                  (Sub-D-Lock gehoben)
                     quiz_failed → (Retry) → quiz_in_progress → quiz_passed
pending/reading/quiz_in_progress/quiz_failed → (deadline exceeded) → expired
```

### 11.2 `dim_elearn_newsletter_issue.status`

```
draft → review → published → archived
```

## 12. Metriken

Admin-Dashboard-Widgets (`newsletter-archive.html`):
- Read-Rate (% MA mit `read_completed_at`)
- Quiz-Pass-Rate (% MA mit `status='quiz_passed'`)
- Durchschnittliche Time-to-Quiz (publish_at → quiz_passed)
- Escalation-Quote (% Assignments mit Head-Escalation)
- Top-Sparten nach Engagement

## 13. Nächste Schritte

1. Peter reviewt SCHEMA + INTERACTIONS.
2. Sub-C-Patches (5) folgen.
3. Nach Sub-D-Specs: konsolidierter Implementation-Plan A+B+C+D.
