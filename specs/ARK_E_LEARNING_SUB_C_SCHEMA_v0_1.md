---
title: "ARK E-Learning Sub C (Wochen-Newsletter) — Schema v0.1"
type: spec
created: 2026-04-20
updated: 2026-04-20
sources: []
tags: [elearning, erp, phase3, sub-c, schema, newsletter]
status: draft
author: Peter Wiederkehr + Claude (Brainstorming-Session 2026-04-20)
companion: ARK_E_LEARNING_SUB_C_INTERACTIONS_v0_1.md
depends_on: ARK_E_LEARNING_SUB_A_SCHEMA_v0_1.md, ARK_E_LEARNING_SUB_B_SCHEMA_v0_1.md
---

# ARK E-Learning Sub C · Wochen-Newsletter · Schema v0.1

> **Companion:** [`ARK_E_LEARNING_SUB_C_INTERACTIONS_v0_1.md`](ARK_E_LEARNING_SUB_C_INTERACTIONS_v0_1.md)
> **Depends on:** Sub A (Quiz-Engine + `attempt_kind='newsletter'`), Sub B (R1–R4 Pipeline + `newsletter_generator.py`)

## 0. Kontext

Sub C ist der **Wochen-Newsletter** des E-Learning-Moduls. Jeden Montag (Tenant-konfigurierbar) erhält jeder MA automatisch eine Newsletter-Ausgabe pro relevanter Sparte. Jede Ausgabe hat 3-5 variable Sections plus einen Pflicht-Quiz. Quiz-Status gatet (Sub D) den weiteren CRM-Zugriff.

**Basis-Pipeline:** Reuse R1–R4 aus Sub B plus neuer R4b-Runner `r4b_newsletter.py` (portiert aus `newsletter_generator.py` in `C:\Linkedin_Automatisierung`).

## 1. Guiding Principles

1. **Pro Sparte eine Ausgabe.** MA mit mehreren Sparten bekommt mehrere Ausgaben.
2. **Variable Struktur.** Anzahl Sections und Fragen pro Ausgabe je nach Wochen-Content-Fundus flexibel.
3. **Soft-Enforcement default.** Tenant-konfigurierbar zu Hard-Enforcement, per-MA-Override möglich.
4. **In-App-only.** Email/Push Phase-2.
5. **Archiv für MA sichtbar.** Vergangene Ausgaben jederzeit abrufbar (Referenz-Wert).
6. **Quiz nutzt Sub-A-Engine** mit `attempt_kind='newsletter'` (Schema bereits vorbereitet).

## 2. Entscheidungs-Log (Brainstorming 2026-04-20)

| # | Entscheidung | Gewählt |
|---|--------------|---------|
| 1 | Enforcement-Modus | Soft-Default + Reminder + Head-Escalation; Tenant-Toggle auf Hard; per-MA-Override |
| 2 | Zustellung | In-App (Email intern redundant, Phase-2 optional) |
| 3 | Section-Count pro Ausgabe | Variabel (abhängig von Content-Fundus der Vorwoche) |
| 4 | Fragen-Count pro Quiz | Individuell pro Ausgabe (LLM entscheidet basierend auf Content-Tiefe) |
| 5 | Archiv-Sichtbarkeit für MA | Ja, unbegrenzt (Retention in Tenant-Settings) |
| 6 | Pipeline | R1–R4 aus Sub B + neuer R4b-Runner |
| 7 | Quiz-Engine | Sub-A-Engine mit `attempt_kind='newsletter'` |
| 8 | Publish-Ziel | DB-Tabellen (kein Git-Commit, Newsletter lebt in der ARK-DB) |

## 3. Section-Typen (flexibel kombinierbar pro Ausgabe)

| Section-Typ | Content-Quelle | Zweck |
|-------------|----------------|-------|
| `market_news` | Web-Scraper-Chunks der Vorwoche (SIA/Baublatt/etc.) | Markt-News für die Sparte |
| `crm_insights` | Anonymisierte `fact_history`-Aggregate | „Was im Team passiert ist" |
| `deep_dive` | Kurs-Content + Buch-Chunks | 1 Thema vertieft |
| `spotlight` | Kombination Quellen | Person/Firma/Konzept der Woche |
| `trend_watch` | Multi-Source-Aggregat | Was sich abzeichnet |
| `ma_highlight` | CRM-Daten (anonymisiert) | Team-Erfolg der Woche (z. B. Placements) |

LLM-Entscheider (R4b) wählt 3–6 Section-Typen basierend auf verfügbarem Content.

## 4. DB-Schema

Alle Tabellen `tenant_id UUID NOT NULL`, RLS-Policy analog Sub A/B.

### 4.1 `dim_elearn_newsletter_issue`

```sql
dim_elearn_newsletter_issue (
  issue_id UUID PK,
  tenant_id UUID NOT NULL,
  sparte TEXT NOT NULL,                  -- ARC, GT, ING, PUR, REM oder 'uebergreifend'
  issue_week TEXT NOT NULL,              -- ISO-Week "2026-W17"
  publish_at TIMESTAMPTZ NOT NULL,
  title TEXT NOT NULL,
  sections JSONB NOT NULL DEFAULT '[]',  -- Array: {type, title, content_md, order_idx}
  quiz_module_id UUID,                   -- synthetischer dim_elearn_module für Newsletter-Quiz
  quiz_pass_threshold INT NOT NULL DEFAULT 80,
  enforcement_mode TEXT NOT NULL DEFAULT 'soft',  -- soft | hard (overschrieben von MA-Setting)
  generation_job_id UUID REFERENCES dim_elearn_generation_job,
  status TEXT NOT NULL DEFAULT 'draft',  -- draft | review | published | archived
  published_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (tenant_id, sparte, issue_week)
)
```

Der Newsletter-Quiz wird als **synthetisches Modul** in `dim_elearn_module` angelegt (Owner-Course: ein pro Tenant + Sparte erzeugter „Newsletter"-Kurs mit `status='archived'` für Admin-Sicht). Fragen landen in `dim_elearn_question` mit Verknüpfung zu diesem Modul. So nutzt der Newsletter-Quiz die komplette Sub-A-Quiz-Engine inkl. Freitext-Review.

### 4.2 `dim_elearn_newsletter_subscription`

```sql
dim_elearn_newsletter_subscription (
  sub_id UUID PK,
  tenant_id UUID NOT NULL,
  ma_id UUID NOT NULL,
  sparte TEXT NOT NULL,
  mode TEXT NOT NULL DEFAULT 'auto',     -- auto | opt_in | opt_out
  enforcement_override TEXT,             -- null = tenant default, sonst 'soft'|'hard'
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (tenant_id, ma_id, sparte)
)
```

**Auto-Subscriptions:** beim MA-Create (via `elearn-onboarding-initializer` oder separater Worker) wird pro `dim_user.sparte` eine Row mit `mode='auto'` angelegt.

**Opt-in:** MA meldet sich freiwillig für weitere Sparten an (eigenes UI).

**Opt-out:** Default nicht möglich für `mode='auto'`. Tenant-Setting `allow_auto_opt_out=true` schaltet es frei (Peter-Entscheid: nicht für Arkadium; Hook für spätere White-Label-Kunden).

### 4.3 `fact_elearn_newsletter_assignment`

```sql
fact_elearn_newsletter_assignment (
  assignment_id UUID PK,
  tenant_id UUID NOT NULL,
  ma_id UUID NOT NULL,
  issue_id UUID NOT NULL REFERENCES dim_elearn_newsletter_issue,
  assigned_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  deadline TIMESTAMPTZ,                  -- default: publish_at + 7 days
  read_started_at TIMESTAMPTZ,
  read_completed_at TIMESTAMPTZ,         -- alle Sections gelesen
  quiz_attempt_id UUID REFERENCES fact_elearn_quiz_attempt,
  status TEXT NOT NULL DEFAULT 'pending',
                                          -- pending | reading | quiz_in_progress |
                                          -- quiz_passed | quiz_failed | expired
  reminder_sent_at TIMESTAMPTZ,
  escalated_to_head_at TIMESTAMPTZ,
  enforcement_mode_applied TEXT NOT NULL, -- soft | hard (Snapshot at publish)
  UNIQUE (tenant_id, ma_id, issue_id)
)
```

### 4.4 `fact_elearn_newsletter_section_read`

```sql
fact_elearn_newsletter_section_read (
  read_id UUID PK,
  tenant_id UUID NOT NULL,
  assignment_id UUID NOT NULL REFERENCES fact_elearn_newsletter_assignment,
  section_idx INT NOT NULL,
  scroll_pct INT NOT NULL DEFAULT 0,
  time_spent_sec INT NOT NULL DEFAULT 0,
  read_at TIMESTAMPTZ,
  UNIQUE (tenant_id, assignment_id, section_idx)
)
```

### 4.5 Indizes

```sql
CREATE INDEX ON dim_elearn_newsletter_issue (tenant_id, sparte, issue_week);
CREATE INDEX ON dim_elearn_newsletter_issue (tenant_id, status, publish_at);
CREATE INDEX ON dim_elearn_newsletter_subscription (tenant_id, ma_id);
CREATE INDEX ON fact_elearn_newsletter_assignment (tenant_id, ma_id, status) WHERE status IN ('pending','reading','quiz_in_progress');
CREATE INDEX ON fact_elearn_newsletter_assignment (tenant_id, deadline) WHERE status NOT IN ('quiz_passed','expired');
CREATE INDEX ON fact_elearn_newsletter_section_read (tenant_id, assignment_id, section_idx);
```

### 4.6 MA-Override (Erweiterung `dim_user`)

```sql
ALTER TABLE dim_user ADD COLUMN newsletter_enforcement_override TEXT;
-- NULL = tenant default; 'soft' | 'hard' für explizite Überschreibung
```

## 5. Tenant-Settings (JSONB `dim_elearn_tenant.settings.elearn_c`)

```yaml
elearn_c:
  enforcement_mode: "soft"              # soft | hard (tenant-weit; MA kann via Override setzen)
  publish_day_cron: "0 6 * * 1"         # jeden Montag 06:00
  reminder_hours: 48                    # Soft-Mode: Reminder nach 48h
  escalation_days: 7                    # Soft-Mode: Head-Escalation nach 7 Tagen
  expiry_days: 14                       # nach 14 Tagen: status='expired', Quiz-Chance vorbei
  sparten_enabled: ["ARC", "GT", "ING", "PUR", "REM"]
  sparte_uebergreifend_enabled: true    # zusätzlicher Newsletter für alle
  archive_retention_months: 24
  max_sections_per_issue: 6
  max_questions_per_quiz: 10
  min_sections_per_issue: 3
  min_questions_per_quiz: 3
  allow_auto_opt_out: false             # default: nein; true für White-Label
```

## 6. API-Endpoints

### 6.1 MA-Endpoints

| Methode | Pfad | Zweck |
|---------|------|-------|
| GET  | `/api/elearn/my/newsletter` | Aktuelle + vergangene Ausgaben (Archive) |
| GET  | `/api/elearn/my/newsletter/:issue_id` | Ausgabe-Inhalt inkl. Quiz-Status |
| POST | `/api/elearn/my/newsletter/:issue_id/read-start` | Read-Flow starten, `status='reading'` |
| POST | `/api/elearn/my/newsletter/:issue_id/sections/:idx/progress` | Heartbeat Scroll/Time |
| POST | `/api/elearn/my/newsletter/:issue_id/quiz/start` | Quiz-Attempt starten (nutzt Sub-A-Quiz-Engine) |
| GET  | `/api/elearn/my/newsletter/subscriptions` | Eigene Abos |
| POST | `/api/elearn/my/newsletter/subscriptions` | Opt-in zu weiterer Sparte |
| DELETE | `/api/elearn/my/newsletter/subscriptions/:id` | Opt-out (nur wenn `allow_auto_opt_out=true` oder `mode!='auto'`) |

### 6.2 Head-Endpoints

| Methode | Pfad | Zweck |
|---------|------|-------|
| GET | `/api/elearn/team/newsletter/queue` | Überfällige Assignments im Team (soft-Mode-Escalations) |
| POST | `/api/elearn/team/newsletter/:assignment_id/remind` | Manueller Reminder-Push |

### 6.3 Admin/Backoffice-Endpoints

| Methode | Pfad | Zweck |
|---------|------|-------|
| GET  | `/api/elearn/admin/newsletter/issues` | Alle Ausgaben filterbar |
| GET  | `/api/elearn/admin/newsletter/issues/:id` | Preview + Stats |
| POST | `/api/elearn/admin/newsletter/issues/:id/publish` | Manuelles Publish eines Draft-Issues |
| POST | `/api/elearn/admin/newsletter/issues/:id/archive` | Archivieren (Ausgabe für MA-Archive unsichtbar) |
| POST | `/api/elearn/admin/newsletter/generate` | Manuellen Generation-Run triggern für `{sparte, week}` |
| GET  | `/api/elearn/admin/newsletter/config` | Tenant-Settings lesen |
| POST | `/api/elearn/admin/newsletter/config` | Tenant-Settings speichern |
| GET  | `/api/elearn/admin/newsletter/metrics` | KPIs: Lese-Rate, Quiz-Pass-Rate, Escalation-Count |
| POST | `/api/elearn/admin/newsletter/enforcement-override` | Per-MA-Override setzen: `{ma_id, mode}` |

## 7. UI-Seiten

| Page | Sichtbarkeit | Zweck |
|------|--------------|-------|
| `erp/elearn/newsletter.html` | MA | Tabs „Aktuell" + „Archiv" |
| `erp/elearn/newsletter-issue.html?id=<id>` | MA | Lese-Ansicht mit Section-Navigation + Quiz-Start-Button |
| `erp/elearn/admin/newsletter-config.html` | Admin | Tenant-Settings: Schedule, Sparten, Enforcement-Default, Archive-Retention |
| `erp/elearn/admin/newsletter-archive.html` | Admin/Head | Alle Ausgaben + KPI-Dashboard |
| `erp/elearn/admin/newsletter-queue.html` | Head/Admin | Überfällige Assignments, Team-View |

**Sidebar-Erweiterung** (nach Review-Queue aus Sub B):
- Newsletter (MA-sichtbar: „Mein Newsletter" einfach in Sidebar)
- Admin-Block: Newsletter-Konfiguration, Newsletter-Archiv, Newsletter-Queue

## 8. Enums (neue Stammdaten)

### 8.1 `elearn_newsletter_section_type`

| Wert | Label DE |
|------|----------|
| `market_news` | Markt-News |
| `crm_insights` | Team-Einblicke |
| `deep_dive` | Vertiefung |
| `spotlight` | Im Fokus |
| `trend_watch` | Trends |
| `ma_highlight` | Team-Highlight |

### 8.2 `elearn_newsletter_status`

| Wert | Bedeutung |
|------|-----------|
| `draft` | Generiert, Admin-Review offen |
| `review` | Admin reviewt, noch nicht publisht |
| `published` | Live, Assignments erzeugt |
| `archived` | Rausgenommen aus MA-Sicht |

### 8.3 `elearn_newsletter_assignment_status`

| Wert | Bedeutung |
|------|-----------|
| `pending` | Zugewiesen, noch nicht gelesen |
| `reading` | Lese-Flow gestartet, Sections nicht alle durch |
| `quiz_in_progress` | Alle Sections gelesen, Quiz läuft |
| `quiz_passed` | Quiz bestanden (≥ `quiz_pass_threshold`) |
| `quiz_failed` | Quiz nicht bestanden (Retry möglich) |
| `expired` | Deadline überschritten; bei hard-Enforcement: Feature-Sperre (Sub D) |

### 8.4 `elearn_newsletter_subscription_mode`

| Wert | Bedeutung |
|------|-----------|
| `auto` | Auto-abonniert via `dim_user.sparte` |
| `opt_in` | Freiwillig abonniert |
| `opt_out` | Explizit abbestellt (nur wenn Tenant-Setting erlaubt) |

### 8.5 `elearn_newsletter_enforcement_mode`

| Wert | Bedeutung |
|------|-----------|
| `soft` | Reminder + Head-Escalation; kein Feature-Lock |
| `hard` | Feature-Lock durch Sub D (CRM-Nutzung blockiert bis Quiz passed) |

## 9. Sub-A-Interop

Der Newsletter-Quiz nutzt:
- `fact_elearn_quiz_attempt` mit `attempt_kind='newsletter'`.
- `fact_elearn_freitext_review` für Freitext-Fragen (identisch Sub A).
- `dim_elearn_question` mit `payload JSONB`.

**Synthetischer Kurs/Modul pro Newsletter-Ausgabe:**
- Beim Publish wird ein `dim_elearn_module` pro Issue angelegt (Owner: ein versteckter Tenant-weiter „Newsletter"-Kurs in `dim_elearn_course`).
- Quiz-Fragen-Pool ist das Issue-spezifische Fragen-Set.
- `module_id` in `issue.quiz_module_id` referenziert.
- Admin/MA sieht diese Kurse nicht in normalen Kurs-Listen (UI-Filter per `course.slug LIKE '_newsletter_%'` oder separater Flag).

## 10. Offene Punkte

- **Email-Fallback:** für MA ohne CRM-Login-Gewohnheit relevant? Phase-2 optional dokumentieren.
- **Newsletter-Kommentare/Reactions:** MA kann auf Section reagieren (Like/Kommentar)? Phase-2.
- **Personalisierung:** Newsletter-Content pro MA zusätzlich zu Sparte? Nicht MVP — zu komplex zum Reviewen.
- **Quiz-Retry-Limit:** aktuell unbegrenzt (wie Sub A). Bei `hard`-Enforcement evtl. Limit auf 3 Versuche mit Head-Gespräch? Später.

## 11. Abhängigkeiten

| Komponente | Abhängigkeit |
|------------|--------------|
| Sub A | Quiz-Engine (Attempt, Freitext-Review, Scoring) |
| Sub B | R1–R4-Pipeline für Content-Sourcing; R4b neu für Newsletter-Prompt |
| Sub D | Liest `fact_elearn_newsletter_assignment.status` + `enforcement_mode_applied` für Feature-Lock-Entscheidung |

## 12. Nächste Schritte

1. Peter reviewt SCHEMA + INTERACTIONS.
2. Sub-C-Patches (5) folgen parallel.
3. Konsolidierter Implementation-Plan A+B+C+D via `superpowers:writing-plans` nach allen Sub-Specs.
