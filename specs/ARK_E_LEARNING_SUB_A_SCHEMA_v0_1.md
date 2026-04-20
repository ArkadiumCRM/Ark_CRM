---
title: "ARK E-Learning Sub A (Kurs-Katalog) — Schema v0.1"
type: spec
created: 2026-04-20
updated: 2026-04-20
sources: []
tags: [elearning, erp, phase3, sub-a, schema]
status: draft
author: Peter Wiederkehr + Claude (Brainstorming-Session 2026-04-20)
companion: ARK_E_LEARNING_SUB_A_INTERACTIONS_v0_1.md
---

# ARK E-Learning Sub A · Kurs-Katalog · Schema v0.1

> **Companion:** Flows, Events, Worker-Logik und UI-Interactions in [`ARK_E_LEARNING_SUB_A_INTERACTIONS_v0_1.md`](ARK_E_LEARNING_SUB_A_INTERACTIONS_v0_1.md).

## 0. Kontext und Abgrenzung

Das E-Learning-Tool ist ein neues **Phase-3-ERP-Modul**, eigenständig vom CRM, später via Topbar-Toggle CRM↔ERP erreichbar. Es adressiert Ausbildung neuer und bestehender Mitarbeiter in neun Kurs-Bereichen (Marktwissen Sparten, Technik, Projekthierarchien, Machtverhältnisse, Kommunikation, Verhaltenspsychologie, HR, Recruiting, Konkurrenten).

Das Gesamtmodul ist in vier Sub-Systeme zerlegt; jedes bekommt eigene Spec-Paare (SCHEMA + INTERACTIONS):

| Sub | Fokus | Status |
|-----|-------|--------|
| **A** | Kurs-Katalog: Content-Import, DB-Schema, Lesson-Viewer, Quiz-Engine, Progress-Tracking, Zertifikate | **dieses Doc-Paar** |
| B | Content-Generator: PDF-/Buch-/News-Scraper → LLM → Kurse und Fragen-Pools | späterer Entwurf (Basis: bestehender Scraper in `C:\Linkedin_Automatisierung`) |
| C | Wochen-Newsletter: pro Sparte, Pflicht-Quiz, zieht aus CRM-Gesprächen der Vorwoche + Externen | späterer Entwurf |
| D | Progress-Gate: Enforcement-Logik (Dashboard-Warnung / Feature-Sperre / Head-Report), Reports, Cert-Lifecycle | späterer Entwurf |

Reihenfolge: A → Review → B → C → D. Sub A ist das Fundament (Content-Modell, Viewer, Quiz-Engine); B/C/D hängen daran.

## 1. Guiding Principles

1. **Content-Autoring ausserhalb des Systems.** Kurse, Module, Lessons und Fragen werden als Markdown + YAML in einem separaten Git-Repo gepflegt (Obsidian-Vault-kompatibel). Import via Git-Webhook. Kein WYSIWYG-Editor im ERP-UI.
2. **Markdown + Embed-Blocks statt Rich-Editor.** Lesson-Body ist Markdown; Bilder, PDFs, YouTube als Embed-Shortcodes.
3. **Multi-Tenant from day one.** Alle Tabellen haben `tenant_id`, Queries sind tenant-scoped, RLS wird in der Backend-Architektur-Spec definiert.
4. **Neue MA: linearer Pflichtpfad. Bestehende: freie Wahl.** Status-Switch erfolgt manuell durch Head.
5. **Quiz-Hybrid.** MC/Multi/True-False/Zuordnung/Reihenfolge werden automatisch gescort; Freitext wird vom LLM vorgeschlagen und zwingend vom Head bestätigt.
6. **ARK-Design-Konsistenz.** Baseline = CRM (Snapshot-Bar, 540 px Slide-in-Drawer, Card-Pattern, echte Umlaute, keine DB-Tech-Begriffe in User-facing-Texten).

## 2. Entscheidungs-Log (aus Brainstorming 2026-04-20)

| # | Entscheidung | Gewählt |
|---|--------------|---------|
| 1 | Scope-Reihenfolge | A zuerst, dann B, C, D |
| 2 | Content-Quelle | Hybrid, Autoring ausserhalb des Systems via Obsidian/MD-Files |
| 3 | Hierarchie | Kurs → (Modul optional) → Lesson; Modul ist technisch immer da (Phantom-Modul bei flachen Kursen) |
| 4 | Sichtbarkeit | Sparte + Rolle als Default, Head-Override pro MA möglich |
| 5 | Curriculum-Definition | Template pro (Rolle, Sparte); Head-Override bei Einstellung |
| 5b | Status-Switch Neu → Bestehend | Manuell durch Head |
| 6 | Quiz-Fragen-Typen | MC, Multi-Select, Freitext, True/False, Zuordnung, Reihenfolge |
| 7 | Freitext-Bewertung | LLM-Vorschlag + Head-Bestätigung (Hybrid) |
| 8 | Pass-Threshold | 80 % |
| 8b | Retry-Policy | Unbegrenzt, Fragen werden pro Versuch neu aus Pool gezogen, Head sieht Stats |
| 9 | Pflicht für Bestehende | Ad-hoc Deadline + periodischer Refresher + Rollen-/Sparten-Wechsel-Trigger (Mix) |
| 10 | Lesson-Complete | Scroll ≥ 90 % + `min_read_seconds` + expliziter „Erledigt"-Klick |
| 10b | Modul-Complete | Alle Lessons abgeschlossen + Quiz bestanden; Pre-Test-Skip möglich (höhere Hürde, 1 Versuch) |
| 11 | Abschluss | PDF-Zertifikat + interne Badges; kein Leaderboard |
| 11b | Einsicht | Head sieht eigenes Team, Backoffice/Admin sehen tenant-weit |
| 12 | Architektur-Ansatz | Ansatz 3: Custom UI + LLM-Backend + Minimal-DB (kein Rich-Editor, kein eingebettetes LMS) |
| 13 | Content-Repo | Separater Git-Repo (z. B. `arkadium/ark-elearning-content`) |
| 14 | Import | Git-Webhook (Push nach `main` → `POST /api/elearn/admin/import`) |
| 15 | Multi-Tenant | Ab Tag 1 integriert |
| 16 | Soft-Delete | Ja (Kurs-Status `archived`, Attempts bleiben) |
| 17 | Freitext-Encryption on disk | Nicht nötig |

## 3. Content-Repo-Struktur

Extern gepflegter Git-Repo, z. B. `arkadium/ark-elearning-content`.

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

### 3.1 `course.yml`

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

### 3.2 `module.yml`

```yaml
slug: hauptakteure
order: 1
title: Hauptakteure der Schweizer Planerszene
description: Generalplaner, Ingenieurbüros, TU, Bauherren
```

### 3.3 Lesson-File (`*.md`)

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

### 3.4 `quiz.yml` (Fragen-Pool pro Modul)

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

### 4.2 Content-Tabellen (Import-Target)

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
  attempt_kind TEXT NOT NULL DEFAULT 'module',  -- module | pretest | newsletter (Sub C)
  score_pct NUMERIC(5,2),
  passed BOOLEAN,
  status TEXT NOT NULL DEFAULT 'in_progress',   -- in_progress | pending_review | finalized
  attempted_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  finalized_at TIMESTAMPTZ,
  answers JSONB NOT NULL DEFAULT '{}'           -- {question_id: answer}
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

### 4.5 Abschluss / Cert / Badges / Audit

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

### 4.7 Versionierung-Regel

- `dim_elearn_course.version` inkrementell (int).
- `content_hash` = SHA-256 über normalisierten Content pro Entity.
- `fact_elearn_enrollment.course_version` pinnt MA auf die Version, die er bearbeitet.
- Neue MA starten mit der jeweils aktuellen **publishten** Version.
- Alte Versionen bleiben für Audit und offene Enrollments in der DB.

## 5. API-Endpoints (Contracts)

Namespace: `/api/elearn/*`. Drei Ebenen. Alle Endpoints sind JWT-geschützt, Middleware extrahiert `tenant_id` und `role` aus dem Token und enforct Scoping über RLS und Route-Guards. Flow-Details pro Endpoint in `INTERACTIONS §*`.

### 5.1 MA-Endpoints

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

### 5.2 Head-Endpoints

| Methode | Pfad | Zweck |
|---------|------|-------|
| GET  | `/api/elearn/team/members` | Team-MA (gescoped auf eigene Sparte und Reports) |
| GET  | `/api/elearn/team/members/:id/progress` | Kurs-Status des MA |
| GET  | `/api/elearn/team/freitext-queue` | Pending Freitext-Reviews für Team |
| POST | `/api/elearn/team/freitext/:review_id` | Review bestätigen oder überschreiben |
| POST | `/api/elearn/team/members/:id/onboarding/complete` | Status-Switch `onboarding_active=false` |
| POST | `/api/elearn/team/members/:id/assign` | Ad-hoc-Kurs-Zuweisung |
| POST | `/api/elearn/team/members/:id/curriculum/override` | Override-Sequenz bei Einstellung |

### 5.3 Admin/Backoffice-Endpoints

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

### 5.4 Request-/Response-Shapes

Payload-Details pro Endpoint werden in der Implementations-Phase (OpenAPI-Spec) ausgearbeitet. Kritische Contracts:

- `POST /my/lessons/:lid/progress` Body: `{ scroll_pct: int, time_sec: int, completed: bool }`
- `POST /my/quiz/:attempt_id/submit` Body: `{ answers: { question_id: answer } }`, Response: `{ partial_score_pct, pending_freitext_count, status }`
- `POST /team/freitext/:review_id` Body: `{ action: 'confirm' | 'override', head_score?, head_feedback? }`
- `POST /admin/import` Header: `X-Git-Signature` (HMAC-SHA256), Body: GitHub-Webhook-Payload

## 6. UI-Seiten-Struktur

Neuer Workspace `erp/elearn/*`, Topbar-Toggle CRM↔ERP. Styling-Baseline = CRM. Interaction-Details (Scroll-Tracker, Keyboard-Shortcuts, Drawer-Aktionen) in `INTERACTIONS §13`.

### 6.1 MA-Seiten

| Page | Zweck |
|------|-------|
| `erp/elearn/dashboard.html` | Einstieg: Onboarding-Progress (neue MA) oder Tabs Pflicht/Empfohlen/Entdecken (bestehende) |
| `erp/elearn/course.html?id=<course_id>` | Kurs-Übersicht mit Modulen, Progress-Ringen, Pre-Test-Button |
| `erp/elearn/lesson.html?id=<lesson_id>` | Markdown-Viewer mit Embeds + Scroll-Tracker + Sticky-Footer-Navigation |
| `erp/elearn/quiz.html?attempt_id=<id>` | Quiz-Runner mit Fragen-Components pro Typ |
| `erp/elearn/quiz-result.html?attempt_id=<id>` | Ergebnis mit Feedback und Retry/Weiter-Buttons |
| `erp/elearn/certificates.html` | Eigene Zertifikate + Badge-Wall |

### 6.2 Gemeinsame Seiten (Head + Admin, Scope via Rolle)

| Page | Head-Sicht | Admin/Backoffice-Sicht |
|------|-----------|------------------------|
| `erp/elearn/team.html` | eigenes Team (Sparte-Filter gelocked) | alle MA, alle Sparten filterbar |
| `erp/elearn/freitext-queue.html` | Reviews nur für Team-Members | alle pending Reviews |
| `erp/elearn/assignments.html` | Massen-Zuweisung nur eigenes Team | Massen-Zuweisung global |

### 6.3 Admin-only Seiten

| Page | Zweck |
|------|-------|
| `erp/elearn/admin/courses.html` | Kurs publishen/archivieren, Version-Historie |
| `erp/elearn/admin/curriculum.html` | Default-Curriculum-Template-Matrix (Rolle × Sparte) |
| `erp/elearn/admin/imports.html` | Git-Webhook-Status + Commit-Timeline + Retry |
| `erp/elearn/admin/analytics.html` | Tenant-KPIs + Heatmaps + Problem-Kurse |

### 6.4 Sidebar-Struktur

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

### 6.5 Design-System-Konformität

- Echte Umlaute UTF-8; niemals `ae`/`oe`/`ue`/`ss` als Ersatz.
- Keine `dim_*`/`fact_*`/Spalten-Namen in User-facing-Texten (Lint-Hook `ark-lint` greift).
- Drawer 540 px für CRUD/Zuweisung/Override; Modale nur für Confirms/Blocker.
- Datum-Picker nativ (`<input type="date">`), Tastatur-Eingabe immer möglich.
- Sparten/Rollen-Vocabulary exakt aus `ARK_STAMMDATEN_EXPORT_v1_3.md` (ARC, GT, ING, PUR, REM; researcher, am, cm, head_of, backoffice, admin).

## 7. Enums (neue Stammdaten)

Für Patch in `ARK_STAMMDATEN_EXPORT_v1_3.md` vorzubereiten.

### 7.1 `elearn_assignment_reason`

| Wert | Bedeutung |
|------|-----------|
| onboarding | Automatisch bei neuer MA aus Curriculum-Template |
| adhoc | Ad-hoc vom Head oder Admin zugewiesen |
| refresher | Periodisch neu ausgelöst nach `refresher_months` |
| role_change | Nach Rollen-Wechsel aus Template-Diff |
| sparten_change | Nach Sparten-Wechsel aus Template-Diff |

### 7.2 `elearn_assignment_status`

| Wert | Bedeutung |
|------|-----------|
| active | Offen, MA soll bearbeiten |
| completed | Kurs abgeschlossen (`fact_elearn_enrollment.status=completed`) |
| expired | Deadline überschritten ohne Abschluss |
| cancelled | Head/Admin hat Assignment zurückgezogen |

### 7.3 `elearn_attempt_kind`

| Wert | Bedeutung |
|------|-----------|
| module | Regulärer Modul-Quiz |
| pretest | Skip-Ahead-Versuch (1× pro Kurs, höhere Schwelle) |
| newsletter | Sub C: Wochen-Newsletter-Quiz (ab Sub C aktiv) |

### 7.4 `elearn_attempt_status`

| Wert | Bedeutung |
|------|-----------|
| in_progress | Fragen-Ziehung erfolgt, submit noch offen |
| pending_review | Freitext-Fragen warten auf Head-Review |
| finalized | Ergebnis endgültig, `score_pct`/`passed` gesetzt |

### 7.5 `elearn_review_status`

| Wert | Bedeutung |
|------|-----------|
| pending | LLM-Vorschlag ggf. vorhanden, Head-Review offen |
| confirmed | Head hat LLM-Vorschlag bestätigt |
| overridden | Head hat explizite eigene Werte gesetzt |
| confirmed_auto | Nach SLA-Eskalation automatisch auf LLM-Score finalisiert (Audit-Marker) |

### 7.6 `elearn_question_type`

| Wert | Bedeutung |
|------|-----------|
| mc | Single-Choice |
| multi | Multi-Select |
| freitext | Freitext, LLM-gescort + Head-Review |
| truefalse | Ja/Nein |
| zuordnung | Paar-Zuordnung (Drag-Drop) |
| reihenfolge | Sortieren (Drag-Drop) |

### 7.7 `elearn_badge_type` (Auszug, erweiterbar)

| Wert | Bedeutung |
|------|-----------|
| first_course | Erster Kurs abgeschlossen |
| all_onboarding | Gesamtes Onboarding-Curriculum abgeschlossen |
| sparte_expert | Alle Kurse der eigenen Sparte abgeschlossen |
| streak_7 | 7 Tage in Folge mind. 1 Lesson abgeschlossen |

## 8. Offene Punkte (für v0.2 oder spätere Subs)

- **Assets-Handling:** Bilder/PDFs aus `assets/` im Content-Repo — Pre-Upload zu S3 beim Import? Oder Serve-on-demand via Proxy? (MVP-Vorschlag: Pre-Upload beim Import, public-read URLs.)
- **Lesson-Notiz-Feld (persönlich) für MA:** nice-to-have, nicht MVP.
- **Quiz-Timer** pro Modul konfigurierbar in `quiz.yml`: `timer_minutes: 20` (optional, MVP skippable).
- **Offline-Modus:** nicht MVP.
- **Export-APIs** für externe Reporting-Tools (CSV/JSON): Phase-2.
- **Mobile-App:** nicht MVP. Responsive Web reicht.
- **A11y-Audit:** vor Go-Live (Sub D/Release).

## 9. Abhängigkeiten zu Sub B/C/D

| Sub | Abhängigkeit zu Sub A |
|-----|------------------------|
| B (Content-Generator) | Nutzt `fact_elearn_import_log`-Pipeline und generiert `course.yml`/`module.yml`/`*.md`/`quiz.yml`-Artefakte in den Content-Repo. |
| C (Wochen-Newsletter) | `fact_elearn_quiz_attempt.attempt_kind='newsletter'` — Schema ab Sub A vorhanden. Newsletter-spezifische Fragen-Herleitung in C-Spec. |
| D (Gate) | Liest `fact_elearn_assignment.status='expired'` und entscheidet Enforcement (Banner, Feature-Sperre). Nichts in A ändert sich. |

## 10. Grundlagen-Sync-Notiz

Vor Implementation sind Patches nötig (werden nach Peter-Review dieser Spec und vor Implementation-Plan erstellt):

| Grundlagen-Datei | Zu ergänzen |
|------------------|-------------|
| `ARK_DATABASE_SCHEMA_v1_4.md` | Neuer Abschnitt „E-Learning-Tabellen" (alle `dim_elearn_*`/`fact_elearn_*`) |
| `ARK_BACKEND_ARCHITECTURE_v2_6.md` | Worker-Liste + Event-Typen + ggf. Saga-Trigger |
| `ARK_STAMMDATEN_EXPORT_v1_3.md` | Neue Enums (Abschnitt 7 dieses Docs) |
| `ARK_FRONTEND_FREEZE_v1_10.md` | ERP-Workspace, Topbar-Toggle CRM↔ERP, ERP-Sidebar-Pattern |
| `ARK_GESAMTSYSTEM_UEBERSICHT_v1_x.md` | Phase-3-ERP-Übersicht, Modul-Liste aktualisieren |

## 11. Nächste Schritte

1. Peter reviewt SCHEMA + INTERACTIONS.
2. Freigabe → Implementation Plan via `superpowers:writing-plans`.
3. Optional: Mockup-Skizzen (Claude Design → Claude Code Handoff) für MA-Dashboard, Lesson-Viewer, Freitext-Queue-Drawer.
4. Grundlagen-Patches schreiben.
5. Sub B Brainstorming starten, sobald Sub A implementiert und validiert ist.
