---
title: "E-Learning PO-Review-Prep · 2026-04-30"
type: meta
created: 2026-04-30
updated: 2026-04-30
sources: []
tags: [elearning, po-review, phase3, erp, sub-a, sub-b, sub-c, sub-d]
---

# E-Learning PO-Review-Prep · 2026-04-30

**Zweck:** PW-Review von 16 E-Learning-Specs in strukturierter Form. Pro Sub: Scope-Summary, Key-Decisions, Open-Questions, Empfehlung. ERP-Audit-Gap schliessen (alle 16 Specs `status: draft`, kein PO-Review-Stempel).

---

## Übersicht

| Sub | Schema | Interactions | Tabellen (ca.) | Events | Workers/Cron | Status |
|-----|--------|--------------|----------------|--------|--------------|--------|
| A — Kurs-Katalog | v0.1 draft | v0.1 draft | ~12 | 15 | 9 | needs-review |
| B — Content-Generator | v0.1 draft | v0.1 draft | ~7 | 12 | 6 | needs-review |
| C — Wochen-Newsletter | v0.1 draft | v0.1 draft | ~4 | 12 | 5 | needs-review |
| D — Progress-Gate | v0.1 draft | v0.1 draft | ~5 | 12 | 4 | needs-review |

**Gesamtumfang:** ~28 Tabellen, ~51 Events, ~24 Worker/Cron-Jobs. Multi-Tenant ab Tag 1 (alle Tabellen `tenant_id UUID NOT NULL`).

---

## Sub A — Kurs-Katalog

### Scope-Summary

Sub A ist das **Fundament des gesamten E-Learning-Moduls**. Es definiert das Content-Modell (Kurs → Modul → Lesson-Hierarchie), den Lesson-Viewer, die Quiz-Engine (6 Fragen-Typen inkl. Freitext-LLM-Scoring), das Progress-Tracking und die Zertifikat-Ausstellung. Kurse werden extern in einem Git-Repo (Obsidian/Markdown) gepflegt und via Git-Webhook importiert — kein WYSIWYG im ERP. Pflichtpfad für neue MA, freie Wahl für bestehende. Sub B/C/D bauen alle auf Sub A auf; nichts davon funktioniert ohne Sub A.

### Key-Decisions

1. **Content ausserhalb ERP (Git-Repo)** — Autoring via Obsidian/Markdown in separatem Repo `arkadium/ark-elearning-content`. → *uncontroversial*
2. **Phantom-Modul-Pattern** — flache Kurse (ohne Modul-Ebene) bekommen technisch immer ein Phantom-Modul. → *uncontroversial*
3. **Neue MA = linearer Pflichtpfad, bestehende MA = freie Kurs-Wahl** — Status-Switch manuell durch Head. → *uncontroversial*
4. **Quiz-Hybrid: Freitext = LLM-Vorschlag + Head-Bestätigung** — LLM (Claude Haiku 4.5) schlägt Score vor, Head muss bestätigen. SLA: 14 Tage, dann Auto-Confirm. → *needs-discussion: SLA-Länge (14 Tage) und Auto-Confirm-Verhalten OK?*
5. **Pass-Threshold 80 %** — global, überschreibbar per Kurs. → *uncontroversial*
6. **Retry unbegrenzt** — bei Quiz-Fail darf MA beliebig oft wiederholen, Fragen werden neu gezogen. → *uncontroversial*
7. **Lesson-Complete: Scroll ≥ 90 % + min_read_seconds + expliziter Klick** — triple-gated. → *uncontroversial*
8. **Pre-Test-Skip** möglich für bestehende MA (höhere Hürde: 90 %, 1 Versuch). → *uncontroversial*
9. **Zertifikate als PDF** + interne Badges, kein Leaderboard. → *uncontroversial*
10. **Partial-Import abgebrochen** — bei Validierungsfehlern kein partieller Upsert, komplett-Abbruch mit Error-Report. → *uncontroversial, defensiv korrekt*

### Open-Questions

1. **Wer pflegt das Content-Repo (`arkadium/ark-elearning-content`)?** RA/HoD oder PW direkt? Reviewer-Rolle für Content-Commits noch nicht spezifiziert.
2. **Refresher-Intervall pro Kurs** (in `course.yml`: `refresher_months: 12`) — Wer setzt den Wert? Admin oder Head?
3. **Freitext-SLA 14 Tage Auto-Confirm** — welcher Score wird auto-vergeben? LLM-Score oder 0? Spec sagt nur „Auto-Confirm", Score-Vergabe offen.

### Cross-Module-Berührungen

- **HR-Modul** — `hr-academy-dashboard.html`: liest `fact_elearn_enrollment` + `dim_elearn_certificate` für Compliance-Übersicht pro MA
- **Sub B/C/D** — direktes Fundament; alle Events `elearn_*` aus Sub A werden von B/C/D konsumiert
- **`fact_history`** — alle 15 Event-Typen landen in der globalen History-Tabelle (ARK-Backend-Pattern)
- **Stammdaten:** `dim_user.sparte`, Rollen (am/cm/ra/bo/hod/admin) bestimmen Kurs-Sichtbarkeit

### Empfehlung

🟡 **APPROVE-MIT-NOTE** — Fundament ist solide und durchdacht. Einzige offene Frage vor Approval: Freitext-Auto-Confirm-Score (OQ3). Kann als Anmerkung ins Spec, kein Blocker.

---

## Sub B — Content-Generator (LLM + RAG)

### Scope-Summary

Sub B ist die **Content-Fabrik**: er ingested externe Quellen (PDFs, Bücher mit Peters Notizen, Web-Scraper, anonymisierte CRM-Daten aus `fact_history`), chunked und embeddet via pgvector, clustert thematisch, generiert via LLM Lesson-Markdown und Quiz-Fragen-Pools, und legt Drafts zur Human-Review vor. Nach Approve werden Artefakte in das externe Content-Repo commited — Sub A importiert sie dann via Git-Webhook. Basis: selektiver Port des bestehenden LinkedIn-Scrapers aus `C:\Linkedin_Automatisierung` nach `Ark_CRM/tools/elearn-content-gen/`.

### Key-Decisions

1. **4 Content-Quellen-Typen** (PDF/Docx, Bücher+Notizen, Web, CRM-Queries) — klare Abgrenzung. → *uncontroversial*
2. **Human-in-the-Loop zwingend** — nichts publisht ohne Review-Approval. → *uncontroversial*
3. **LinkedIn-Scraper wird portiert nach ARK-Repo** (`Ark_CRM/tools/elearn-content-gen/`) — Libs selektiv übernommen. → *needs-discussion: Scope der Port-Arbeit unklar (Effort?)*
4. **LLM-Modell-Split:** Claude Sonnet 4.6 für Content-Generation, Haiku 4.5 nur für Tagging/Zuordnung. → *uncontroversial*
5. **Publish-Mode konfigurierbar** (Direct-Commit vs. Auto-PR) pro Tenant. → *uncontroversial*
6. **LLM-Cost-Cap** (Monats + Job, Tenant-konfigurierbar), Disable bei ≥ 100 %. → *uncontroversial*
7. **Embedding-Dimension VECTOR(1536)** — passt zu OpenAI `text-embedding-ada-002` / `text-embedding-3-small`. → *needs-discussion: Embedding-Provider OpenAI? Anthropic hat kein Embedding-Modell. Expliciter Provider-Entscheid fehlt im Spec.*
8. **CRM-Daten anonymisiert** — Namen → Rollen-Platzhalter vor LLM-Call. → *uncontroversial*
9. **Draft-Expiry 30 Tage** — unreviewed Artefakte werden auto-archiviert. → *uncontroversial*

### Open-Questions

1. **LinkedIn-Scraper-Port-Scope:** Welche Module von `C:\Linkedin_Automatisierung` werden übernommen? Gibt es IP/Lizenz-Bedenken (eigen entwickelt → unkritisch, aber klären)?
2. **Embedding-Provider:** pgvector VECTOR(1536) deutet auf OpenAI Embeddings hin. Explizit bestätigen oder Alternative wählen (z.B. Cohere, local model)?
3. **Content-Review-UI:** Wer macht den Approve/Reject von LLM-generierten Kursdrafts? HoD? PW? Beliebiger Admin?

### Cross-Module-Berührungen

- **Sub A** — Output-Format exakt Sub-A-kompatibel (course.yml / lesson.md / quiz.yml)
- **Sub C** — R1–R4 Pipeline wird direkt wiederverwendet durch Sub C (R4b als Extension)
- **`fact_history`** (CRM-Daten als Quelle, anonymisiert) — Lesezugriff auf CRM-Core-Tabellen
- **`C:\Linkedin_Automatisierung`** — Quell-Codebase für Python-Runner-Pattern

### Empfehlung

🔴 **NEEDS-DISCUSSION** — Zwei konkrete Decisions vor Approval: (1) Embedding-Provider explizit festlegen, (2) Scope des LinkedIn-Scraper-Ports einschätzen (Effort-Abschätzung fehlt).

---

## Sub C — Wochen-Newsletter

### Scope-Summary

Sub C erzeugt jeden Montag automatisch pro MA und pro Sparte eine personalisierte Newsletter-Ausgabe mit 3–6 variablen Sections (Markt-News, CRM-Insights, Deep-Dive, Spotlight, Trend-Watch, MA-Highlight) plus einem Pflicht-Quiz. Die Sub-B-Pipeline (R1–R4) wird direkt wiederverwendet; Sub C fügt nur den R4b-Newsletter-Runner hinzu (portiert aus `newsletter_generator.py` in `C:\Linkedin_Automatisierung`). Default ist Soft-Enforcement (Reminder + Head-Escalation), Hard-Enforcement (Feature-Sperre via Sub D) ist Tenant-konfigurierbar. Newsletter lebt in der ARK-DB — kein Git-Commit wie bei Sub A.

### Key-Decisions

1. **Pro Sparte eine Ausgabe** — MA mit 2 Sparten bekommt 2 Newsletter. → *needs-discussion: Overhead für MA mit ARC + ING — OK?*
2. **Soft-Enforcement als Default** — Reminder nach konfig. Stunden, Escalation nach konfig. Tagen, kein Hard-Block default. → *uncontroversial*
3. **In-App-only (kein Email)** — Email/Push in Phase 2. → *uncontroversial*
4. **Unbegrenztes Archiv** für MA, Retention via Tenant-Settings. → *uncontroversial*
5. **Quiz nutzt Sub-A-Engine** (`attempt_kind='newsletter'`) — kein separates Quiz-System. → *uncontroversial, elegant*
6. **Newsletter lebt in ARK-DB** (nicht im Content-Repo) — DB-First statt Git-First wie Sub A. → *uncontroversial, korrekte Abgrenzung*
7. **Section-Count variabel** (3–6) per LLM-Entscheidung je nach verfügbarem Content-Fundus. → *uncontroversial*
8. **Fragen-Count per Quiz variabel** — LLM entscheidet basierend auf Content-Tiefe. → *uncontroversial*

### Open-Questions

1. **Review-Schritt für Newsletter-Ausgabe:** Hat der Newsletter einen Human-Review-Schritt (wie Sub B) vor dem Publish, oder geht er direkt nach Draft auf `published`? Spec zeigt `status: draft | review | published | archived` aber der Review-Flow ist in den gelesenen Abschnitten unklar.
2. **Overgreifende Sparte (`uebergreifend`):** Wer bekommt den übergreifenden Newsletter? Alle MA, oder nur HoD/Admin?
3. **CRM-Insights Datenschutz:** Anonymisierung von `fact_history` für `crm_insights`-Sections — gleiche Logik wie Sub B (Namen → Rollen-Platzhalter)? Explizit bestätigen.

### Cross-Module-Berührungen

- **Sub A** — Quiz-Engine (`attempt_kind='newsletter'`), Progress-Tracking
- **Sub B** — R1–R4 Pipeline vollständig wiederverwendet
- **Sub D** — Newsletter-Quiz-Status (`quiz_passed` / `expired`) ist Trigger für Gate-Rules
- **HR-Modul** — Newsletter-Compliance sichtbar im HR-Academy-Dashboard

### Empfehlung

🟡 **APPROVE-MIT-NOTE** — Architektur klar und gut abgegrenzt. OQ1 (Review-Schritt) als Anmerkung im Spec klären; kein Blocker für Approval.

---

## Sub D — Progress-Gate / Compliance

### Scope-Summary

Sub D ist die **Enforcement-Schicht**: er liest States aus Sub A (Kurs-Assignments, Zertifikate) und Sub C (Newsletter-Assignments) und evaluiert Gate-Rules zur Request-Zeit via Middleware-Decorator (`@gate_feature('create_process')`). Ergebnis: Soft-Enforcement (Dashboard-Banner, Topbar-Badge, Login-Popup bei Overdue) oder Hard-Enforcement (HTTP 403 + Redirect bei Feature-Sperre). Feature-Keys sind granular definiert (Write-Features blockierbar, Read-Features und `elearning_*` immer erlaubt). Override-System für Urlaub/Elternzeit/Notfall unbegrenzt mit Audit-Zwang. Compliance-Score = einfache Prozentzahl (erledigt / total Pflicht-Items).

### Key-Decisions

1. **Feature-granulare Gate-Regeln** (nicht binär alles/nichts) — Ausdruck pro Rule definiert welche Feature-Keys geblockt werden. → *uncontroversial, richtig*
2. **Gate-Cache 60 s TTL** — Redis/In-Memory, verhindert DB-Hammering bei jedem Request. → *uncontroversial*
3. **Override unbegrenzt** (Urlaub/Elternzeit/Notfall/Other) mit Pflicht-Audit-Log. → *uncontroversial*
4. **Login-Popup modal** bei ≥ 1 überfälligem Pflicht-Item. → *needs-discussion: wird das als zu aggressiv empfunden? Frequenz pro Login-Session oder täglich?*
5. **Cert-Auto-Revocation bei Kurs-Major-Version-Bump** — MA muss Kurs erneut machen. → *needs-discussion: Definition Major-Version-Bump (semver oder manuell?), Vorab-Ankündigung für MA?*
6. **Compliance-Score simpel** (`% erledigt / total`). → *uncontroversial*
7. **`elearning_*`-Routes immer erlaubt** — verhindert Gate-Lock-Catch-22. → *uncontroversial, kritisch korrekt*
8. **Read-Features immer erlaubt** — nur Write-Features sind blockierbar. → *uncontroversial*
9. **Feature-Katalog auto-discovered** aus Backend-Decorators (`FEATURE_CATALOG`). → *uncontroversial, elegant*

### Open-Questions

1. **Cert-Revocation-Warnung:** Wie lange vor Major-Version-Bump werden MA informiert? Spec erwähnt kein Advance-Warning-System.
2. **HR-Tool-Integration:** Wie genau übernimmt `hr-academy-dashboard.html` die Compliance-Daten aus Sub D? Direkter DB-Read oder dedizierter API-Endpoint?
3. **Gate-Cache-Invalidation:** Wenn Head ein Override einrichtet oder eine Rule deaktiviert — wird der Cache pro MA sofort invalidiert oder erst nach 60 s TTL?

### Cross-Module-Berührungen

- **Sub A** — liest `fact_elearn_enrollment`, `dim_elearn_certificate`, `fact_elearn_assignment`
- **Sub C** — liest `fact_elearn_newsletter_assignment` für Newsletter-Gate-Trigger
- **HR-Modul** (`hr-academy-dashboard.html`) — Compliance-Reports Drilldown pro MA (heute neu erstellt)
- **CRM-Frontend** — alle Write-Route-Endpoints erhalten `@gate_feature(...)` Decorator
- **Redis** — Gate-Cache-Dependency (falls noch nicht im ARK-Stack: neue Infra-Dependency!)

---

## Cross-Cutting Themes (Subs übergreifend)

### pgvector-RAG-Architektur

Sub B und Sub C nutzen pgvector. Chunks aus Sub B werden in `dim_elearn_chunk` mit `VECTOR(1536)` gespeichert. Sub C (R4b) nutzt dieselbe Chunk-Tabelle. Sub A und Sub D greifen nicht direkt auf pgvector zu. **Embedding-Dimension 1536 deutet auf OpenAI** — Provider-Entscheid muss explizit im Spec stehen (OQ in Sub B). RLS-Strategy: alle Tabellen `tenant_id`-scoped, pgvector-Queries immer mit `WHERE tenant_id = $1`. Multi-Tenant korrekt isoliert.

### Multi-Tenant-RLS (28 Tabellen)

E-Learning ist laut Audit-Erwähnung das **erste konsequent Multi-Tenant-fähige Modul** in ARK. Alle ~28 Tabellen haben `tenant_id UUID NOT NULL`. RLS-Policies sollen in der Backend-Architecture-Spec definiert werden (Spec verweist darauf, Details nicht in den E-Learning-Specs selbst). **Konsequenz:** vor Go-Live muss `ARK_BACKEND_ARCHITECTURE_v2_*.md` um E-Learning-RLS-Policies ergänzt werden (Spec-Sync-Schritt).

### Python-Worker-Service (extern)

Sub B und Sub C implementieren Runner (R1–R5, R4b) als Python-Module in `tools/elearn-content-gen/`. CLI-Entry: `python -m elearn_content_gen`. **Unklar: gehört dieser Python-Service ins `Ark_CRM`-Repo (als `tools/`-Subfolder) oder separates Repo?** Aktuell zeigt Spec `tools/elearn-content-gen/` innerhalb Ark_CRM, aber Basis-Code kommt aus `C:\Linkedin_Automatisierung`. Decision offen — beeinflusst CI/CD-Setup und Deployment.

### LLM-Provider-Choice

| Sub | Modell | Aufgabe |
|-----|--------|---------|
| A | Claude Haiku 4.5 | Freitext-Quiz-Scoring |
| B | Claude Sonnet 4.6 | Content-Generation (Lessons, Quiz-Pools) |
| B | Claude Haiku 4.5 | Tagging / Zuordnung |
| C | Claude Sonnet 4.6 (implizit R4b) | Newsletter-Section-Generation |
| Embedding | ? (VECTOR(1536)) | Wahrscheinlich OpenAI, ungeklärt |

**Anthropic-Only-Strategie für Text-Generation** ist klar und konsistent. Embedding-Provider ist der einzige offene Punkt — muss vor Implementierungsstart festgelegt werden.

---

## Empfehlung-Gesamt für PW-Review

### Approve-as-is (~65 % der Decisions = 23 von 35)

- Sub A komplett ausser Freitext-SLA-Auto-Confirm-Score
- Sub C komplett ausser Newsletter-Review-Step-Klärung
- Sub D Punkte 1, 3, 4 (granulares Gating, unbegrenzte Overrides, Read-always-allowed, elearning-always-allowed, Feature-Katalog-Discovery)
- Sub B Punkte 1, 2, 4, 5, 6, 8, 9 (Content-Quellen, Human-Loop, Modell-Split, Publish-Mode, Cost-Cap, CRM-Anonymisierung, Draft-Expiry)

### Needs-Discussion (~25 % = ~9 Decisions)

1. **Sub B: Embedding-Provider** — VECTOR(1536) impliziert OpenAI. Offizieller Entscheid: OpenAI `text-embedding-3-small` oder Alternative? Kostenfaktor?
2. **Sub B: LinkedIn-Scraper-Port-Scope** — Effort-Abschätzung für den Port nach `tools/elearn-content-gen/`. PW kennt den Code — 1h oder 2 Wochen?
3. **Sub D: Login-Popup-Frequenz** — Modal bei jedem Login oder einmal pro Tag? Aggressivität vs. Compliance-Zweck.
4. **Sub D: Cert-Major-Version-Definition** — Wer triggert einen Major-Version-Bump? Manuell im Content-Repo (Versionsnummer in `course.yml`)? Advance-Warning fehlt.
5. **Python-Worker-Service-Repo** — `tools/elearn-content-gen/` im Ark_CRM-Repo oder separates Repo? Deployment-Entscheid.

### Defer (~10 % = ~3 Punkte)

1. **Email/Push für Newsletter (Sub C)** — explizit Phase 2, kein Action-Item heute.
2. **Leaderboard / Gamification** — explizit abgelehnt (kein Leaderboard), kann in Phase 3.2 neu diskutiert werden.
3. **Multi-Tenant-Onboarding für weitere Tenants** — Sub A hat die Architektur, konkrete Tenant-Onboarding-UX ist Phase 3.2.

---

## Review-Workflow-Vorschlag

1. **PW liest „Übersicht" + „Cross-Cutting Themes"** (10 min) — Gesamtbild, offene Provider-Fragen
2. **PW geht durch 4 Sub-Sektionen** (je 8–12 min) — markiert ✅ / 🟡 / 🔴 pro Sub
3. **Bei 🔴 (Sub B):** 15-min-Decision-Session mit Claude für Embedding-Provider + Scraper-Scope
4. **Nach Approval:** alle 16 Specs `status: draft` → `status: po-reviewed` setzen

```bash
# Nach PO-Approval (1 Sed-Run über alle 16 Specs):
for f in C:/Projects/Ark_CRM/specs/ARK_E_LEARNING_SUB_*.md; do
  sed -i 's/^status: draft$/status: po-reviewed/' "$f"
done
```

5. **Spec-Sync-Check** auslösen: Backend-Architecture-Spec um RLS-Policies für ~28 neue Tabellen ergänzen.
6. **Commit + Push:** `docs(elearn): 16 Specs status draft → po-reviewed`
