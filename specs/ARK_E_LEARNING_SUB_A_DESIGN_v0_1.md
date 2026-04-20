---
title: "ARK E-Learning Sub A (Kurs-Katalog) — Design v0.1"
type: spec
created: 2026-04-20
updated: 2026-04-20
sources: []
tags: [elearning, erp, phase3, sub-a, design]
status: draft
author: Peter Wiederkehr + Claude (Brainstorming-Session 2026-04-20)
---

# ARK E-Learning Sub A · Kurs-Katalog · Design v0.1

## 0. Kontext und Abgrenzung

Das E-Learning-Tool ist ein neues **Phase-3-ERP-Modul**, eigenständig vom CRM, später via Topbar-Toggle CRM↔ERP erreichbar. Es adressiert Ausbildung neuer und bestehender Mitarbeiter in neun Kurs-Bereichen (Marktwissen Sparten, Technik, Projekthierarchien, Machtverhältnisse, Kommunikation, Verhaltenspsychologie, HR, Recruiting, Konkurrenten).

Das Gesamtmodul ist in vier Sub-Systeme zerlegt; jedes bekommt eine eigene Spec:

| Sub | Fokus | Status |
|-----|-------|--------|
| **A** | Kurs-Katalog: Content-Import, DB-Schema, Lesson-Viewer, Quiz-Engine, Progress-Tracking, Zertifikate | **dieses Doc** |
| B | Content-Generator: PDF-/Buch-/News-Scraper → LLM → Kurse und Fragen-Pools | späterer Entwurf (Basis: bestehender LinkedIn-Scraper in `C:\Linkedin_Automatisierung`) |
| C | Wochen-Newsletter: pro Sparte, Pflicht-Quiz, zieht aus CRM-Gesprächen der Vorwoche + Externen | späterer Entwurf |
| D | Progress-Gate: Enforcement-Logik (Dashboard-Warnung / Feature-Sperre / Head-Report), Reports, Cert-Lifecycle | späterer Entwurf |

Die Reihenfolge ist A → Review → B → C → D. Sub A bildet das Fundament (Content-Modell, Viewer, Quiz-Engine); B/C/D hängen daran.

## 1. Guiding Principles

1. **Content-Autoring ausserhalb des Systems.** Kurse, Module, Lessons und Fragen werden als Markdown + YAML in einem separaten Git-Repo gepflegt (Obsidian-Vault-kompatibel). Import via Git-Webhook. Kein WYSIWYG-Editor im ERP-UI.
2. **Markdown + Embed-Blocks statt Rich-Editor.** Lesson-Body ist Markdown; Bilder, PDFs, YouTube als Embed-Shortcodes. Spart ~40-50 % Frontend-Aufwand gegenüber einem eigenen Editor.
3. **Multi-Tenant from day one.** Alle Tabellen haben `tenant_id`, Queries sind tenant-scoped, RLS wird in der Backend-Architektur-Spec definiert.
4. **Neue MA: linearer Pflichtpfad. Bestehende: freie Wahl.** Status-Switch erfolgt manuell durch Head.
5. **Quiz-Hybrid.** MC/Multi/True-False/Zuordnung/Reihenfolge werden automatisch gescort; Freitext wird vom LLM vorgeschlagen und zwingend vom Head bestätigt.
6. **ARK-Design-Konsistenz.** Baseline = CRM (Snapshot-Bar, 540 px Slide-in-Drawer, Card-Pattern, echte Umlaute, keine DB-Tech-Begriffe in User-facing-Texten).

## 2. Entscheidungs-Log (aus Brainstorming 2026-04-20)

| # | Entscheidung | Gewählt |
|---|--------------|---------|
| 1 | Scope-Reihenfolge | A zuerst, dann B, C, D |
| 2 | Content-Quelle | Hybrid (Upload + Editor), Autoring aber ausserhalb des Systems via Obsidian/MD-Files |
| 3 | Hierarchie | Kurs → (Modul optional) → Lesson; Modul ist technisch immer da (Phantom-Modul bei flachen Kursen) |
| 4 | Sichtbarkeit | Sparte + Rolle als Default, Head-Override pro MA möglich |
| 5 | Curriculum-Definition | Template pro (Rolle, Sparte); Head-Override bei Einstellung |
| 5b | Status-Switch Neu → Bestehend | Manuell durch Head |
| 6 | Quiz-Fragen-Typen | MC, Multi-Select, Freitext, True/False, Zuordnung, Reihenfolge |
| 7 | Freitext-Bewertung | LLM-Vorschlag + Head-Bestätigung (Hybrid) |
| 8 | Pass-Threshold | 80 % |
| 8b | Retry-Policy | Unbegrenzt, Fragen werden pro Versuch neu aus Pool gezogen, Head sieht Stats |
| 9 | Pflicht für Bestehende | Ad-hoc Deadline + periodischer Refresher + Rollen-/Sparten-Wechsel-Trigger (Mix) |
| 10 | Lesson-Complete | Scroll ≥ 90 % plus `min_read_seconds` plus expliziter „Erledigt"-Klick |
| 10b | Modul-Complete | Alle Lessons abgeschlossen plus Quiz bestanden; Pre-Test-Skip möglich (höhere Hürde, 1 Versuch) |
| 11 | Abschluss | PDF-Zertifikat plus interne Badges; kein Leaderboard |
| 11b | Einsicht | Head sieht eigenes Team, Backoffice/Admin sehen tenant-weit |
| 12 | Architektur-Ansatz | Ansatz 3: Custom UI plus LLM-Backend plus Minimal-DB (kein Rich-Editor, kein eingebettetes LMS) |
| 13 | Content-Repo | Separater Git-Repo (z. B. `arkadium/ark-elearning-content`) |
| 14 | Import | Git-Webhook (Push nach `main` → `POST /api/elearn/admin/import`) |
| 15 | Multi-Tenant | Ab Tag 1 integriert |
| 16 | Soft-Delete | Ja (Kurs-Status `archived`, Attempts bleiben) |
| 17 | Freitext-Encryption on disk | Nicht nötig |

## 3. Content-Format und Import-Pipeline

### 3.1 Repo-Struktur (extern, z. B. `arkadium/ark-elearning-content`)

```
elearning-content/
  courses/
    arc-marktwissen/
      course.yml
      modules/
        01-hauptakteure/
          module.yml
          lessons/
            01-grosse-planer.md
            02-bauherren.md
            03-regulatoren.md
          quiz.yml
        02-preise-trends/
          ...
    hr-onboarding/
      course.yml
      modules/
        ...
  assets/
    hauptakteure-map.png
    sia-leitfaden.pdf
```

### 3.2 `course.yml` Schema

```yaml
slug: arc-marktwissen              # UNIQUE pro Tenant
title: Marktwissen ARC
description: Hauptakteure, Preise, Regulatoren der Sparte ARC
sparten: [ARC]                     # leer = alle Sparten
rollen: [researcher, am, cm]       # leer = alle Rollen
duration_min: 180
refresher_months: 12               # null = kein Refresher
pretest_enabled: true
pretest_pass_threshold: 90         # nur bei pretest_enabled
pass_threshold: 80
version: 1.2
```

### 3.3 `module.yml` Schema

```yaml
slug: hauptakteure
order: 1
title: Hauptakteure der Schweizer Planerszene
description: Generalplaner, Ingenieurbüros, TU, Bauherren
```

### 3.4 Lesson-File Schema (`*.md`)

```markdown
---
slug: grosse-planer
title: Grosse Planer der Schweiz
order: 1
min_read_seconds: 60
---

# Grosse Planer der Schweiz

Markdown-Body mit Embeds:

![[hauptakteure-map.png]]
{% embed pdf="sia-leitfaden.pdf" page=12 %}
{% embed youtube="xyz123" %}
```

### 3.5 `quiz.yml` Schema (Fragen-Pool pro Modul)

```yaml
questions:
  - type: mc
    question: Welcher Generalplaner ist mit über 5000 MA der grösste der Schweiz?
    options: [Basler & Hofmann, Itten+Brechbühl, Burckhardt+Partner, HRS]
    correct: 1
    explanation: Itten+Brechbühl (Ref. SIA-Jahresbericht 2025)

  - type: multi
    question: Welche SIA-Normen regeln Honorare?
    options: [102, 103, 108, 110, 112]
    correct: [0, 1, 2]

  - type: freitext
    question: Beschreibe den Unterschied zwischen GP und TU in 2 Sätzen.
    musterloesung: GP plant, koordiniert und überwacht. TU baut eigenverantwortlich mit Pauschalpreis.
    keywords: [planen, überwachen, pauschalpreis, eigenverantwortlich]
    max_score: 10

  - type: truefalse
    question: Die SIA 103 regelt Ingenieur-Honorare.
    correct: false

  - type: zuordnung
    question: Ordne Büro → Schwerpunkt zu.
    pairs:
      - [Basler & Hofmann, Gesamtplanung]
      - [Dr. Lüchinger, Tragwerk]
      - [Amstein+Walthert, Gebäudetechnik]

  - type: reihenfolge
    question: Sortiere die SIA-Projektphasen.
    items: [Vorprojekt, Bauprojekt, Ausführungsplanung, Realisierung]
```

### 3.6 Import-Pipeline (Git-Webhook)

**Trigger:** Push auf `main` des Content-Repos.

**Endpoint:** `POST /api/elearn/admin/import`
Header: `X-Git-Signature` (HMAC-SHA256, tenant-spezifisches Secret).
Body: GitHub-Webhook-Payload (`repo`, `ref`, `commits[]`, `head_commit`).

**Worker-Flow:**

1. HMAC verifizieren; bei Fehlschlag `401`.
2. Repo in temporärem Ordner clonen/pullen (`@<head_commit.id>`).
3. Verzeichnis `courses/` rekursiv walken.
4. Pro Entity (Course/Module/Lesson/Question-Pool): YAML/Frontmatter gegen Zod-Schema validieren; bei Fehler sammeln und Import abbrechen mit Error-Report.
5. `content_hash` pro Entity berechnen (SHA-256 über normalisierten Content).
6. DB-Diff: Vergleich `(tenant_id, slug)` → neu / geändert / gelöscht.
7. Upsert, bei Content-Änderung Version inkrementieren (alte Version bleibt für bestehende `enrollment.course_version`-Referenzen).
8. Event `elearn_content_imported` mit `commit_sha`, Counts, Error-Liste.
9. Response: `{ imported, updated, archived, errors }`.

**Audit:** Jeder Import als `fact_elearn_import_log`-Row (Commit-SHA, Trigger, Zeit, Counts, Errors).

### 3.7 Versionierung

- `dim_elearn_course.version` (int, inkrementell).
- `dim_elearn_course.content_hash` (SHA der aggregierten Sub-Entities).
- `fact_elearn_enrollment.course_version` pinnt MA auf die Version, die er bearbeitet.
- Neue MA starten mit der jeweils aktuellen publishten Version.
- Alte Versionen bleiben in der DB erhalten (für Audit, Historie, offene Enrollments).

## 4. DB-Schema

Alle Tabellen liegen im `public`-Schema und beginnen mit `dim_elearn_*` bzw. `fact_elearn_*`. Alle Tabellen tragen `tenant_id UUID NOT NULL` mit Index; RLS-Policies werden in der Backend-Architektur-Spec definiert.

### 4.1 Tenant

```sql
dim_elearn_tenant (
  tenant_id UUID PK,
  name TEXT NOT NULL,
  settings JSONB NOT NULL DEFAULT '{}',   -- SLA-Tage, Auto-Confirm-Schwelle, LLM-Modell-Override etc.
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
)
```

### 4.2 Content-Tabellen

```sql
dim_elearn_course (
  course_id UUID PK,
  tenant_id UUID NOT NULL,
  slug TEXT NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  sparten TEXT[] NOT NULL DEFAULT '{}',
  rollen TEXT[] NOT NULL DEFAULT '{}',
  duration_min INT,
  refresher_months INT,                  -- null = kein Refresher
  pretest_enabled BOOLEAN NOT NULL DEFAULT false,
  pretest_pass_threshold INT,
  pass_threshold INT NOT NULL DEFAULT 80,
  version INT NOT NULL DEFAULT 1,
  content_hash TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'draft',  -- draft | published | archived
  published_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (tenant_id, slug)
)

dim_elearn_module (
  module_id UUID PK,
  tenant_id UUID NOT NULL,
  course_id UUID NOT NULL REFERENCES dim_elearn_course,
  slug TEXT NOT NULL,
  order_idx INT NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  content_hash TEXT NOT NULL,
  UNIQUE (tenant_id, course_id, slug),
  UNIQUE (tenant_id, course_id, order_idx)
)

dim_elearn_lesson (
  lesson_id UUID PK,
  tenant_id UUID NOT NULL,
  module_id UUID NOT NULL REFERENCES dim_elearn_module,
  slug TEXT NOT NULL,
  order_idx INT NOT NULL,
  title TEXT NOT NULL,
  content_md TEXT NOT NULL,
  min_read_seconds INT NOT NULL DEFAULT 60,
  content_hash TEXT NOT NULL,
  UNIQUE (tenant_id, module_id, slug),
  UNIQUE (tenant_id, module_id, order_idx)
)

dim_elearn_question (
  question_id UUID PK,
  tenant_id UUID NOT NULL,
  module_id UUID NOT NULL REFERENCES dim_elearn_module,
  type TEXT NOT NULL,                    -- mc | multi | freitext | truefalse | zuordnung | reihenfolge
  payload JSONB NOT NULL,
  version INT NOT NULL DEFAULT 1,
  content_hash TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
)
```

### 4.3 Zuweisung / Onboarding

```sql
dim_elearn_curriculum_template (
  template_id UUID PK,
  tenant_id UUID NOT NULL,
  sparte TEXT,                           -- null = alle Sparten
  rolle TEXT NOT NULL,
  course_ids UUID[] NOT NULL DEFAULT '{}',   -- geordnet
  created_by UUID,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (tenant_id, sparte, rolle)
)

fact_elearn_curriculum_override (
  override_id UUID PK,
  tenant_id UUID NOT NULL,
  ma_id UUID NOT NULL,
  course_ids UUID[] NOT NULL,
  reason TEXT,
  overridden_by UUID NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (tenant_id, ma_id)
)

fact_elearn_assignment (
  assignment_id UUID PK,
  tenant_id UUID NOT NULL,
  ma_id UUID NOT NULL,
  course_id UUID NOT NULL REFERENCES dim_elearn_course,
  reason TEXT NOT NULL,                  -- onboarding | adhoc | refresher | role_change | sparten_change
  deadline DATE,
  assigned_by UUID,
  assigned_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  status TEXT NOT NULL DEFAULT 'active'  -- active | completed | expired | cancelled
)

-- User-Flag (Erweiterung bestehender Tabelle)
ALTER TABLE dim_user ADD COLUMN elearn_onboarding_active BOOLEAN NOT NULL DEFAULT false;
```

### 4.4 Progress / Quiz

```sql
fact_elearn_enrollment (
  enrollment_id UUID PK,
  tenant_id UUID NOT NULL,
  ma_id UUID NOT NULL,
  course_id UUID NOT NULL REFERENCES dim_elearn_course,
  course_version INT NOT NULL,
  status TEXT NOT NULL DEFAULT 'active', -- active | completed | expired
  started_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  completed_at TIMESTAMPTZ,
  UNIQUE (tenant_id, ma_id, course_id)
)

fact_elearn_progress (
  progress_id UUID PK,
  tenant_id UUID NOT NULL,
  enrollment_id UUID NOT NULL REFERENCES fact_elearn_enrollment,
  lesson_id UUID NOT NULL REFERENCES dim_elearn_lesson,
  scroll_reached_pct INT NOT NULL DEFAULT 0,
  time_spent_sec INT NOT NULL DEFAULT 0,
  completed_at TIMESTAMPTZ,
  UNIQUE (tenant_id, enrollment_id, lesson_id)
)

fact_elearn_quiz_attempt (
  attempt_id UUID PK,
  tenant_id UUID NOT NULL,
  enrollment_id UUID NOT NULL REFERENCES fact_elearn_enrollment,
  module_id UUID NOT NULL REFERENCES dim_elearn_module,
  attempt_kind TEXT NOT NULL DEFAULT 'module', -- module | pretest | newsletter (Sub C)
  score_pct NUMERIC(5,2),
  passed BOOLEAN,
  status TEXT NOT NULL DEFAULT 'in_progress',  -- in_progress | pending_review | finalized
  attempted_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  finalized_at TIMESTAMPTZ,
  answers JSONB NOT NULL DEFAULT '{}'    -- {question_id: answer}
)

fact_elearn_freitext_review (
  review_id UUID PK,
  tenant_id UUID NOT NULL,
  attempt_id UUID NOT NULL REFERENCES fact_elearn_quiz_attempt,
  question_id UUID NOT NULL REFERENCES dim_elearn_question,
  ma_answer TEXT NOT NULL,
  llm_score NUMERIC(5,2),
  llm_feedback TEXT,
  llm_model TEXT,                        -- z. B. claude-haiku-4-5
  head_score NUMERIC(5,2),
  head_feedback TEXT,
  reviewed_by UUID,
  reviewed_at TIMESTAMPTZ,
  status TEXT NOT NULL DEFAULT 'pending' -- pending | confirmed | overridden | confirmed_auto
)
```

### 4.5 Abschluss / Cert / Badges

```sql
dim_elearn_certificate (
  cert_id UUID PK,
  tenant_id UUID NOT NULL,
  ma_id UUID NOT NULL,
  course_id UUID NOT NULL REFERENCES dim_elearn_course,
  course_version INT NOT NULL,
  pdf_url TEXT NOT NULL,                 -- S3/Blob
  issued_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (tenant_id, ma_id, course_id, course_version)
)

dim_elearn_badge (
  badge_id UUID PK,
  tenant_id UUID NOT NULL,
  ma_id UUID NOT NULL,
  badge_type TEXT NOT NULL,              -- first_course | all_onboarding | sparte_expert | streak_7 | …
  course_id UUID,
  earned_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
)

fact_elearn_import_log (
  log_id UUID PK,
  tenant_id UUID NOT NULL,
  commit_sha TEXT NOT NULL,
  trigger TEXT NOT NULL,                 -- webhook | manual
  imported INT NOT NULL DEFAULT 0,
  updated INT NOT NULL DEFAULT 0,
  archived INT NOT NULL DEFAULT 0,
  errors JSONB NOT NULL DEFAULT '[]',
  started_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  finished_at TIMESTAMPTZ
)
```

### 4.6 Indexe (wichtigste)

```sql
CREATE INDEX ON fact_elearn_progress (tenant_id, enrollment_id, lesson_id);
CREATE INDEX ON fact_elearn_quiz_attempt (tenant_id, enrollment_id, module_id);
CREATE INDEX ON fact_elearn_freitext_review (tenant_id, status) WHERE status = 'pending';
CREATE INDEX ON fact_elearn_assignment (tenant_id, ma_id, status) WHERE status = 'active';
CREATE INDEX ON dim_elearn_course (tenant_id, status, slug);
```

## 5. Events (fact_history-Integration)

Konsistent mit ARK-Backend-Pattern: jede relevante Aktion als Event in `fact_history`.

- `elearn_course_assigned` (ma, course, reason, deadline)
- `elearn_course_started` (ma, course, enrollment)
- `elearn_course_completed` (ma, course, enrollment, duration_sec)
- `elearn_lesson_completed` (ma, lesson, time_spent_sec)
- `elearn_quiz_attempted` (ma, module, attempt, is_pretest)
- `elearn_quiz_passed` (ma, module, attempt, score_pct)
- `elearn_quiz_failed` (ma, module, attempt, score_pct)
- `elearn_freitext_submitted` (review, ma_answer_snippet)
- `elearn_freitext_reviewed` (review, head, status, head_score)
- `elearn_certificate_issued` (ma, course, cert, pdf_url)
- `elearn_badge_earned` (ma, badge_type)
- `elearn_refresher_triggered` (ma, course, new_assignment)
- `elearn_role_change_triggered` (ma, diff_courses)
- `elearn_assignment_expired` (ma, course, assignment)
- `elearn_onboarding_finalized` (ma, finalized_by)
- `elearn_content_imported` (commit_sha, counts)

## 6. API-Endpoints

Namespace: `/api/elearn/*`. Drei Ebenen. Alle Endpoints sind JWT-geschützt, Middleware extrahiert `tenant_id` und `role` aus dem Token und enforct Scoping über RLS und Route-Guards.

### 6.1 MA-Endpoints

| Methode | Pfad | Zweck |
|---------|------|-------|
| GET  | `/api/elearn/my/courses` | Pflicht + Freiwillig + Onboarding-Pfad mit Unlock-State |
| GET  | `/api/elearn/my/courses/:id` | Kurs-Detail, Module, Progress, Enrollment-Status |
| GET  | `/api/elearn/my/courses/:id/modules/:mid/lessons/:lid` | Lesson-Content |
| POST | `/api/elearn/my/lessons/:lid/progress` | Scroll/Time heartbeat + Completion-Flag |
| GET  | `/api/elearn/my/courses/:id/modules/:mid/quiz` | Neuen Quiz-Attempt starten; zieht zufälliges Subset aus Fragen-Pool |
| POST | `/api/elearn/my/quiz/:attempt_id/submit` | Antworten übergeben; MC/Multi/TF/Zuordnung/Reihenfolge sofort gescort, Freitext als `pending_review` |
| GET  | `/api/elearn/my/quiz/:attempt_id` | Attempt-Details inkl. Review-Status |
| POST | `/api/elearn/my/courses/:id/pretest` | Pre-Test-Attempt starten (1 Versuch, höhere Schwelle) |
| GET  | `/api/elearn/my/certificates` | Eigene Zertifikate |
| GET  | `/api/elearn/my/badges` | Eigene Badges |

### 6.2 Head-Endpoints

| Methode | Pfad | Zweck |
|---------|------|-------|
| GET  | `/api/elearn/team/members` | Team-MA (gescoped auf eigene Sparte und Reports) |
| GET  | `/api/elearn/team/members/:id/progress` | Kurs-Status des MA |
| GET  | `/api/elearn/team/freitext-queue` | Pending Freitext-Reviews für Team |
| POST | `/api/elearn/team/freitext/:review_id` | Review bestätigen oder überschreiben |
| POST | `/api/elearn/team/members/:id/onboarding/complete` | Status-Switch `onboarding_active=false` |
| POST | `/api/elearn/team/members/:id/assign` | Ad-hoc-Kurs-Zuweisung |
| POST | `/api/elearn/team/members/:id/curriculum/override` | Override-Sequenz bei Einstellung |

### 6.3 Admin/Backoffice-Endpoints

| Methode | Pfad | Zweck |
|---------|------|-------|
| GET  | `/api/elearn/admin/courses` | Alle Kurse tenant-weit |
| POST | `/api/elearn/admin/courses/:id/publish` | Publish-Toggle |
| POST | `/api/elearn/admin/courses/:id/archive` | Archivieren |
| GET  | `/api/elearn/admin/members/progress` | Tenant-weite MA-Übersicht |
| GET  | `/api/elearn/admin/freitext-queue` | Alle pending Reviews |
| POST | `/api/elearn/admin/freitext/:review_id/revise` | Nachträgliche Korrektur nach Finalisierung (Audit-Log) |
| GET  | `/api/elearn/admin/curriculum-templates` | Template-Matrix |
| POST | `/api/elearn/admin/curriculum-templates` | Template anlegen/ändern |
| POST | `/api/elearn/admin/import` | Git-Webhook-Handler |
| POST | `/api/elearn/admin/import/manual` | Manueller Import-Trigger |
| POST | `/api/elearn/admin/assign-bulk` | Massen-Zuweisung |
| GET  | `/api/elearn/admin/refresher/due` | Worker-Input für Refresher-Trigger |
| GET  | `/api/elearn/admin/analytics` | KPIs + Heatmaps |

### 6.4 Worker / Cron

| Worker | Schedule / Trigger | Zweck |
|--------|--------------------|-------|
| `elearn_onboarding_initializer` | Event `user_created` | Setzt `elearn_onboarding_active=true`, erzeugt Assignments aus Template |
| `elearn_role_change_watcher` | Event `user_role_changed` / `user_sparte_changed` | Diff-basierte neue Assignments |
| `elearn_refresher_trigger` | Cron `0 2 * * *` | Erzeugt Refresher-Assignments für überfällige Kurse |
| `elearn_deadline_expiry` | Cron `0 6 * * *` | Setzt `assignment.status=expired`, Event |
| `elearn_cert_generator` | Event `elearn_course_completed` (letztes Modul) | PDF erzeugen, S3-Upload, `dim_elearn_certificate` anlegen |
| `elearn_badge_engine` | Events `elearn_course_completed` / `elearn_quiz_passed` | Badge-Regeln prüfen, Badges vergeben |
| `elearn_freitext_llm_scorer` | Event `elearn_freitext_submitted` (Queue, Concurrency 5) | LLM-Call (Claude Haiku 4.5), `llm_score` und `llm_feedback` füllen |
| `elearn_attempt_finalizer` | Event `elearn_freitext_reviewed` (wenn letzte Review im Attempt) | Final-Score, `attempt.status=finalized`, Event `passed`/`failed` |
| `elearn_sla_reminder` | Cron stündlich | Reminder Tag 3, Escalation Tag 7, Auto-Confirm Tag 14 (konfigurierbar per Tenant) |

## 7. UI-Seiten

Neuer Workspace `erp/elearn/*`, Topbar-Toggle CRM↔ERP. Styling-Baseline = CRM (Snapshot-Bar, Card-Pattern, 540 px Drawer, Datum-Picker nativ, echte Umlaute, keine DB-Tech-Begriffe in User-facing-Texten).

### 7.1 MA-Seiten

- `erp/elearn/dashboard.html`
  - Wenn `onboarding_active=true`: Linear-Progress-Balken „Onboarding X/Y", nur aktueller und abgeschlossene Kurse sichtbar, nächste Kurse gelockt-gestylt.
  - Sonst drei Tabs: Pflicht · Empfohlen · Entdecken.
  - Widgets: Mein Fortschritt, nächster Refresher.

- `erp/elearn/course.html?id=<course_id>`
  - Header: Titel, Sparte/Rolle-Chips, Dauer, Refresher-Interval, Version.
  - Vertikale Modul-Liste mit Progress-Ring pro Modul.
  - Pre-Test-Button (falls aktiviert und noch nicht verbraucht).
  - Side-Panel: Lern-Stats.

- `erp/elearn/lesson.html?id=<lesson_id>`
  - Markdown-Renderer mit Custom-Embed-Blocks (PDF-Viewer, YouTube, Bild).
  - Scroll-Tracker im Hintergrund (Heartbeat alle 15 s an `POST /progress`).
  - Sticky-Footer: `← Vorherige` · **`Erledigt ✓`** (aktiv nur bei `scroll_pct ≥ 90` und `time_sec ≥ min_read_seconds`) · `Nächste →`.

- `erp/elearn/quiz.html?attempt_id=<id>`
  - Fragen sequenziell, Progress-Bar oben.
  - Component pro Fragen-Typ (Radio, Checkbox, Buttons, Drag-Drop, Textarea).
  - Keine Zwischenspeicherung; erst „Abschicken" am Ende.

- `erp/elearn/quiz-result.html?attempt_id=<id>`
  - Final-Score, bestanden/nicht bestanden.
  - Pro Frage: eigene Antwort, korrekte Antwort, Erklärung.
  - Freitext-Fragen: Hinweis „wird von [Head-Name] geprüft".
  - Button „Nochmal" (Fail) oder „Weiter zum nächsten Modul" (Pass).

- `erp/elearn/certificates.html`
  - Zertifikate-Grid (Thumbnail, Download, Datum).
  - Badge-Wall (earned farbig, locked ausgegraut mit Hint).

### 7.2 Gemeinsame Seiten (Head + Admin, Scope via Rolle)

- `erp/elearn/team.html` — Team-Übersicht. Head: eigene Sparte. Admin: tenant-weit, Sparte filterbar.
  - Tabelle: MA · Rolle · Sparte · Onboarding-Status · Aktive Kurse · Offene Pflicht · Letzte Aktivität.
  - Zeile → 540 px Drawer mit MA-Detail, Enrollments, Attempts, Aktionen („Ad-hoc zuweisen", „Onboarding abschliessen", „Curriculum-Override").

- `erp/elearn/freitext-queue.html` — Review-Queue. Head: Team-Reviews. Admin: alle.
  - Table: MA · Kurs · Modul · Frage-Snippet · Wartezeit · LLM-Score (farbkodiert) · Action.
  - Zeile → 540 px Review-Drawer mit Frage, Musterlösung, Keywords, MA-Antwort, LLM-Vorschlag (Score-Slider + Feedback-Textarea vorgefüllt), Buttons `LLM bestätigen` und `Überschreiben + speichern`.
  - Keyboard-Shortcuts: `J`/`K` next/prev, `Enter` bestätigen, `Esc` Drawer schliessen.
  - Batch-Modus: Multi-Select + „Alle mit LLM ≥ 80 bestätigen".

- `erp/elearn/assignments.html` — Massen-Zuweisung. Head: eigenes Team. Admin: tenant-weit.

### 7.3 Admin-only Seiten

- `erp/elearn/admin/courses.html` — Kurs-Katalog. Zeile → Drawer mit Metadaten (readonly), Publish-Toggle, Zielgruppen-Override, Refresher-Override, Version-Historie.
- `erp/elearn/admin/curriculum.html` — Template-Matrix (Rollen × Sparten). Zelle → Drawer mit Drag-Drop-Kursliste.
- `erp/elearn/admin/imports.html` — Import-Timeline, Commit-SHAs, Counts, Errors, Retry-Button.
- `erp/elearn/admin/analytics.html` — Tenant-KPIs: aktive Lerner, Completion-Rate, Ø Score, Queue-Depth, Refresher-due-Count, Problem-Kurse (Pass-Rate < 50 %).

### 7.4 Sidebar-Struktur (ERP-Workspace)

| Position | Head | Admin/Backoffice |
|----------|------|-----------------|
| 1 | Meine Kurse | Meine Kurse |
| 2 | Team-Übersicht | Team-Übersicht (tenant-weit) |
| 3 | Freitext-Queue | Freitext-Queue (tenant-weit) |
| 4 | Zuweisungen | Zuweisungen (tenant-weit) |
| — | — | — Trenner — |
| 5 | — | Kurs-Katalog |
| 6 | — | Curriculum-Templates |
| 7 | — | Import-Dashboard |
| 8 | — | Analytics |

### 7.5 Design-System-Konformität

- Echte Umlaute UTF-8; niemals `ae`/`oe`/`ue`/`ss` als Ersatz.
- Keine `dim_*`/`fact_*`/Spalten-Namen in User-facing-Texten (Lint-Hook `ark-lint` greift).
- Drawer 540 px für CRUD/Zuweisung/Override; Modale nur für Confirms/Blocker.
- Datum-Picker nativ (`<input type="date">`), Tastatur-Eingabe immer möglich.
- Sparten/Rollen-Vocabulary exakt aus `ARK_STAMMDATEN_EXPORT_v1_3.md` (ARC, GT, ING, PUR, REM; researcher, am, cm, head_of, backoffice, admin).

## 8. Onboarding und Lifecycle

### 8.1 Neue-MA-Einstellung

1. Backoffice legt User in `dim_user` mit `role`, `sparte`, `start_date` an.
2. System setzt `dim_user.elearn_onboarding_active=true`.
3. Worker `elearn_onboarding_initializer` erzeugt `fact_elearn_assignment`-Rows aus Curriculum-Template `(role, sparte)`. Fallback: Template `(role, null)`. `reason='onboarding'`, Default-Deadline 90 Tage (tenant-konfigurierbar).
4. Backoffice erhält Drawer „Curriculum anpassen?" — Template übernehmen oder Override bearbeiten.
5. Bei Override: `fact_elearn_curriculum_override` angelegt, Assignments entsprechend angepasst.

### 8.2 Step-by-Step-Unlock-Regel

- MA sieht alle zugewiesenen Onboarding-Kurse.
- Nur der erste noch nicht abgeschlossene Kurs (in Curriculum-Reihenfolge) ist startbar. Rest gesperrt mit Schloss-Icon und Tooltip „Nach Abschluss von [vorherigem Kurs] verfügbar".
- Unlock-Trigger: letztes Modul `status='finalized'` und `passed=true` → Event `elearn_course_completed` → nächster Kurs UI-seitig entsperrt. UI berechnet aus Enrollment-Historie (kein zusätzliches Flag-Feld).

### 8.3 Pre-Test (Skip-Ahead)

- Pro Kurs eine einzige Pre-Test-Attempt (`attempt_kind='pretest'`).
- Höhere Hürde: `course.pretest_pass_threshold` (Default 90 %).
- Zieht Fragen aus allen Modulen des Kurses (Pool-Union).
- Bestanden → alle Enrollment-Module als `completed` markieren, Kurs `completed`, Cert ausgestellt, nächster Onboarding-Kurs entsperrt.
- Nicht bestanden → normale Lesson-/Modul-Sequenz startet.

### 8.4 Status-Switch Neu → Bestehend

- Manuell durch Head aus `team.html` Drawer.
- Confirm-Modal mit Hinweis „freie Kurs-Wahl, Onboarding-Lock entfällt, Fortschritte bleiben".
- `dim_user.elearn_onboarding_active=false`, Event `elearn_onboarding_finalized`.
- Nicht abgeschlossene Onboarding-Assignments bleiben als Pflicht ohne Step-Lock; Head kann einzelne cancelen.

### 8.5 Refresher-Zyklus

Worker `elearn_refresher_trigger` täglich 02:00:

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

Pro Treffer neue Assignment `reason='refresher'`, Deadline = `NOW() + 30 days`. Notification an MA + Kopie an Head. Event `elearn_refresher_triggered`. Alte Enrollment bleibt Historie; neue wird bei Kurs-Start angelegt.

### 8.6 Rollen-/Sparten-Wechsel

Worker `elearn_role_change_watcher` reagiert auf Events `user_role_changed` / `user_sparte_changed`:

1. Altes Template `(old_role, old_sparte)` → Kurs-Set A.
2. Neues Template `(new_role, new_sparte)` → Kurs-Set B.
3. Diff `B \ A` = neue Pflicht-Kurse. MA mit existierendem `completed` Enrollment überspringen.
4. Pro Kurs: Assignment `reason='role_change'` oder `'sparten_change'`, Deadline = `NOW() + 60 days`. Notification an MA + Head.

### 8.7 Deadline-Expiry

Worker `elearn_deadline_expiry` täglich 06:00. `fact_elearn_assignment.status='active' AND deadline < NOW()` → `status='expired'`, Event `elearn_assignment_expired`. Gate-Logik (was passiert im CRM) gehört in Sub D.

### 8.8 Multi-Tenant-Transfer (Edge-Case, MVP später)

Bei Tenant-Wechsel: Enrollments beim alten Tenant bleiben Audit. Neuer Tenant startet mit leerem Slate. Cert/Badge-Portierung ist Admin-Decision, Phase-2.

## 9. Freitext-Review-Engine

### 9.1 Submit-Flow

**Synchron (MA submittet Quiz):**
- Auto-scorbare Fragen (MC, Multi, TF, Zuordnung, Reihenfolge) werden sofort bewertet und fliessen in `fact_elearn_quiz_attempt.answers` + Partial-Score ein.
- Pro Freitext-Frage wird `fact_elearn_freitext_review` mit `status='pending'` angelegt.
- Attempt-Status: `pending_review` (falls Freitext vorhanden), sonst direkt `finalized`.
- Response an MA: Partial-Score plus Hinweis „X Freitext-Antworten werden geprüft".

**Asynchron (LLM-Scorer-Worker):**
- Event `elearn_freitext_submitted` triggert Worker (Concurrency 5).
- Prompt-Template (siehe 9.6).
- Fehler: 3× Retry mit Exponential-Backoff, danach `llm_score=NULL`, `llm_feedback='LLM-Fehler, bitte manuell bewerten'`.
- Review bleibt `status='pending'` — Head muss bestätigen.

### 9.2 Head-Review

- `freitext-queue.html` zeigt Reviews mit LLM-Vorschlag vorgefüllt.
- Aktion: `POST /api/elearn/team/freitext/:review_id` mit Body `{ action: 'confirm' | 'override', head_score?, head_feedback? }`.
- `confirm`: `head_score = llm_score`, `head_feedback = llm_feedback`, `status='confirmed'`.
- `override`: explizit gesetzte Werte, `status='overridden'`.

### 9.3 Attempt-Finalisierung

Worker `elearn_attempt_finalizer` wird bei jedem `elearn_freitext_reviewed`-Event angetriggert. Logik: prüfe, ob in diesem Attempt noch `fact_elearn_freitext_review.status='pending'` existiert. Falls nein:
- Aggregiere: auto-Scores + alle `head_score` pro Frage → `score_pct`.
- `passed = score_pct >= course.pass_threshold`.
- `fact_elearn_quiz_attempt.status='finalized'`, `finalized_at=NOW()`.
- Event `elearn_quiz_passed` oder `elearn_quiz_failed`.
- Notification an MA.

### 9.4 SLA und Escalation

Tenant-konfigurierbar in `dim_elearn_tenant.settings`. Defaults:

| Tag nach Submit | Aktion |
|-----------------|--------|
| 3 | Reminder-Notification an Head |
| 7 | Escalation-Notification an Admin/Backoffice plus Head |
| 14 | Auto-Confirm via LLM-Score, **sofern `llm_score IS NOT NULL`**. `status='confirmed_auto'`, audit-gelogged. MA bekommt Ergebnis. Head-Last-Escape. Bei LLM-Fehler (`llm_score IS NULL`) **kein Auto-Confirm**, Admin-Escalation bleibt offen bis manueller Review. |

Worker `elearn_sla_reminder` läuft stündlich.

### 9.5 Impact auf Modul-/Kurs-Completion

- Solange Attempt `status='pending_review'`: Modul nicht abgeschlossen.
- Step-by-Step-Logik bei neuen MA: nächstes Modul blockiert.
- MA kann in anderen Kursen parallel arbeiten (wenn bestehender MA).
- MA-Dashboard zeigt Badge „Quiz in Prüfung".

### 9.6 LLM-Prompt-Template

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

Modell-Default: `claude-haiku-4-5`. Override pro Tenant in `dim_elearn_tenant.settings.llm_model`. Bei `confidence < 60` optional Retry mit `claude-sonnet-4-6`.

### 9.7 Re-Review nach Finalisierung

Einmal `status='confirmed'`/`'overridden'`/`'confirmed_auto'`: unveränderlich. Korrektur via Admin-Endpoint `POST /api/elearn/admin/freitext/:id/revise` mit Audit-Eintrag; nur Admin/Backoffice, Begründungspflicht.

## 10. Offene Punkte (für v0.2 oder spätere Subs)

- **Assets-Handling:** Bilder/PDFs aus `assets/` im Content-Repo — Pre-Upload zu S3 beim Import? Oder Serve-on-demand via Proxy? (MVP-Vorschlag: Pre-Upload beim Import, public-read URLs.)
- **Lesson-Notiz-Feld (persönlich) für MA:** nice-to-have, nicht MVP.
- **Quiz-Timer** pro Modul konfigurierbar in `quiz.yml`: `timer_minutes: 20` (optional, MVP skippable).
- **Offline-Modus:** nicht MVP.
- **Export-APIs** für externe Reporting-Tools (CSV/JSON): Phase-2.
- **Mobile-App:** nicht MVP. Responsive Web reicht.
- **A11y-Audit:** vor Go-Live (Sub D/Release).

## 11. Abhängigkeiten zu Sub B/C/D

| Sub | Abhängigkeit zu Sub A |
|-----|------------------------|
| B (Content-Generator) | Nutzt `fact_elearn_import_log`-Pipeline und generiert `course.yml`/`module.yml`/`*.md`/`quiz.yml`-Artefakte in den Content-Repo. |
| C (Wochen-Newsletter) | Nutzt `dim_elearn_question`-Schema für Newsletter-Fragen; Newsletter-Attempt ist eine Spezialform von `fact_elearn_quiz_attempt` (Flag `is_newsletter`). Schema in A vorbereiten. |
| D (Gate) | Liest `fact_elearn_assignment.status='expired'` und entscheidet Enforcement (Banner, Feature-Sperre). Nichts in A ändert sich. |

**Schema-Vorbereitung für C:** `fact_elearn_quiz_attempt.attempt_kind` ist bereits in Sub A eingeführt (siehe Abschnitt 4.4) und akzeptiert `'module' | 'pretest' | 'newsletter'`. In Sub A sind nur `'module'` und `'pretest'` aktiv; Sub C aktiviert `'newsletter'` ohne Migration.

## 12. Grundlagen-Sync-Notiz

Dieses Modul ist **nicht** in den aktuellen Grundlagen-Dateien abgebildet. Vor Implementation sind Patches nötig:

- `ARK_DATABASE_SCHEMA_v1_4.md` → Abschnitt „E-Learning-Tabellen" (alle `dim_elearn_*`/`fact_elearn_*`).
- `ARK_BACKEND_ARCHITECTURE_v2_6.md` → Worker-Liste + Event-Typen + Saga-Trigger.
- `ARK_STAMMDATEN_EXPORT_v1_3.md` → neue Enums: `elearn_assignment_reason`, `elearn_attempt_status`, `elearn_review_status`, `elearn_badge_type`.
- `ARK_FRONTEND_FREEZE_v1_10.md` → ERP-Workspace, Topbar-Toggle, ERP-Sidebar-Pattern.
- `ARK_GESAMTSYSTEM_UEBERSICHT_v1_x.md` → Phase-3-ERP-Übersicht.

Diese Grundlagen-Patches werden **nach** Peter-Review dieser Spec und **vor** Implementation Plan erstellt.

## 13. Nächste Schritte

1. Peter reviewt dieses Dokument.
2. Spec-Doc freigegeben → Implementation Plan via `superpowers:writing-plans` erstellen (Task-Breakdown, Task-Dependencies, Testing-Strategie).
3. Optional: Mockup-Skizzen für MA-Dashboard / Lesson-Viewer / Freitext-Queue-Drawer (Claude Design → Claude Code Handoff).
4. Grundlagen-Sync-Patches schreiben.
5. Sub B Brainstorming starten, sobald Sub A implementiert und validiert ist.
