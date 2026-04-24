---
title: "E-Learning Modul — Handover"
type: meta
created: 2026-04-24
updated: 2026-04-24
sources: []
tags: [elearning, erp, phase3, handover, status]
---

# E-Learning Modul — Handover

Stand: 2026-04-24. Pickup-Doc für neue Sessions.

## Kontext

Eigenständiges **Phase-3-ERP-Modul** — kein CRM-Code anfassen. Zugang via Topbar-Toggle.
Workflow: **Spec-First** (nicht Mockup-First wie CRM Phase 1).
Specs liegen unter `specs/ARK_E_LEARNING_SUB_*_v0_1.md`.

---

## Sub-System-Überblick

| Sub | Name | Scope | Mockup-Status |
|-----|------|-------|---------------|
| **A** | Kurs-Katalog | Content-Modell, Lesson-Viewer, Quiz-Engine, Progress, Zertifikate | **Kern fertig, Head/Admin-Views fehlen** |
| **B** | Content-Generator | PDF/Web/CRM-Scraper → LLM → Content-Repo | nur Admin-Shell-Link vorhanden |
| **C** | Wochen-Newsletter | Pro Sparte, Pflicht-Quiz, aus CRM-Daten | 0 Mockups |
| **D** | Progress-Gate | Enforcement-Logik, Reports, Cert-Lifecycle | 0 Mockups |

Reihenfolge: A → B → C → D (A ist Fundament).

---

## Bestehende Mockup-Files (6 Dateien)

| Datei | Inhalt | Qualität |
|-------|--------|----------|
| [`elearn.html`](../../mockups/ERP%20Tools/elearn/elearn.html) | Hauptseite "Meine Kurse" · Onboarding-Mode + Bestehend-Mode · Newsletter-Banner | ✅ Fertig |
| [`elearn-course.html`](../../mockups/ERP%20Tools/elearn/elearn-course.html) | Kurs-Detail · Modul-Liste · Lektion-TOC · Fortschritt-Ring | ✅ Fertig |
| [`elearn-lesson.html`](../../mockups/ERP%20Tools/elearn/elearn-lesson.html) | Lesson-Viewer · 2-Spalten (Nav + Reading-Col) · Markdown-Render · Erledigt-CTA | ✅ Fertig |
| [`elearn-quiz.html`](../../mockups/ERP%20Tools/elearn/elearn-quiz.html) | Quiz-Engine · MC, Multi-Select, True/False, Freitext | ✅ Fertig |
| [`elearn-quiz-result.html`](../../mockups/ERP%20Tools/elearn/elearn-quiz-result.html) | Ergebnisseite · Score · Pass/Fail · Retry-Button | ✅ Fertig |
| [`elearn-certificates.html`](../../mockups/ERP%20Tools/elearn/elearn-certificates.html) | Zertifikat-Liste · Download-Button · Badge-Display | ✅ Fertig |

**Kernnukleus-Flow funktioniert:** `elearn.html` → `elearn-course.html` → `elearn-lesson.html` → `elearn-quiz.html` → `elearn-quiz-result.html` → `elearn-certificates.html`

---

## Fehlende Mockup-Pages (alle im Sidebar verlinkt, aber nicht existent)

### Sub A — Mein Bereich
| Datei | Beschreibung | Prio |
|-------|--------------|------|
| `elearn-my-compliance.html` | Persönlicher Compliance-Status: offene Pflichten, Überfällige, Deadlines | A4 |

### Sub A — Team (Head-Only)
| Datei | Beschreibung | Prio |
|-------|--------------|------|
| `elearn-team.html` | Team-Übersicht: Progress pro MA, offene Assignments, Badges | **A1** |
| `elearn-freitext-queue.html` | Freitext-Antworten zur Bewertung: LLM-Vorschlag + Head-Bestätigung | **A2** |
| `elearn-assignments.html` | Zuweisung von Kursen an MAs, Deadline-Setzen, Curriculum-Override | **A3** |
| `elearn-team-compliance.html` | Team-Compliance-Report (Sub D Enforcement-Dashboard) | D1 |

### Sub A — Admin
| Datei | Beschreibung | Prio |
|-------|--------------|------|
| `elearn-admin-courses.html` | Kurs-Katalog-Verwaltung: alle Kurse/Status, Sichtbarkeit | **A5** |
| `elearn-admin-curriculum.html` | Curriculum-Templates pro (Rolle, Sparte) | **A6** |
| `elearn-admin-imports.html` | Git-Webhook Import-Log: Commit-SHA, Counts, Errors | **A7** |

### Sub C — Newsletter
| Datei | Beschreibung | Prio |
|-------|--------------|------|
| `elearn-newsletter.html` | Newsletter-Archiv: alle Issues, Pflicht-Status pro MA | C1 |
| `elearn-newsletter-issue.html` | Einzelner Newsletter: Artikel + eingebettetes Pflicht-Quiz | C2 |

### Sub B — Content-Generator
| Datei | Beschreibung | Prio |
|-------|--------------|------|
| `elearn-admin-content-gen.html` | Scraper-Pipeline, LLM-Generation, Review-Queue, Repo-Push | B1 |

### Sub D — Analytics
| Datei | Beschreibung | Prio |
|-------|--------------|------|
| `elearn-admin-analytics.html` | Tenant-weite Nutzungsstatistiken, Completion-Rates, Quiz-Scores | D2 |

---

## Spec-Referenzen

| Spec | Datei | Fokus |
|------|-------|-------|
| Sub A Schema | [`ARK_E_LEARNING_SUB_A_SCHEMA_v0_1.md`](../../specs/ARK_E_LEARNING_SUB_A_SCHEMA_v0_1.md) | DB-Tabellen, YAML-Formate, API-Endpoints, Enums |
| Sub A Interactions | [`ARK_E_LEARNING_SUB_A_INTERACTIONS_v0_1.md`](../../specs/ARK_E_LEARNING_SUB_A_INTERACTIONS_v0_1.md) | Events, Worker, Import-Pipeline, UI-Flows |
| Sub B Schema | [`ARK_E_LEARNING_SUB_B_SCHEMA_v0_1.md`](../../specs/ARK_E_LEARNING_SUB_B_SCHEMA_v0_1.md) | RAG-Architektur, Content-Pipeline-DB |
| Sub B Interactions | [`ARK_E_LEARNING_SUB_B_INTERACTIONS_v0_1.md`](../../specs/ARK_E_LEARNING_SUB_B_INTERACTIONS_v0_1.md) | Scraper-Flow, LLM-Generation, Review-Workflow |
| Sub C Schema | [`ARK_E_LEARNING_SUB_C_SCHEMA_v0_1.md`](../../specs/ARK_E_LEARNING_SUB_C_SCHEMA_v0_1.md) | Newsletter-DB-Schema |
| Sub C Interactions | [`ARK_E_LEARNING_SUB_C_INTERACTIONS_v0_1.md`](../../specs/ARK_E_LEARNING_SUB_C_INTERACTIONS_v0_1.md) | Newsletter-Flow, Pflicht-Quiz-Enforcement |
| Sub D Schema | [`ARK_E_LEARNING_SUB_D_SCHEMA_v0_1.md`](../../specs/ARK_E_LEARNING_SUB_D_SCHEMA_v0_1.md) | Progress-Gate-DB |
| Sub D Interactions | [`ARK_E_LEARNING_SUB_D_INTERACTIONS_v0_1.md`](../../specs/ARK_E_LEARNING_SUB_D_INTERACTIONS_v0_1.md) | Enforcement-Logic, Dashboard-Warning, Feature-Sperre |

**Grundlagen-Patches** (alle Sub A–D parallel): 20 Patch-Dateien in `specs/ARK_*_PATCH_ELEARNING*.md` (DB-Schema, Backend-Architektur, Frontend-Freeze, Stammdaten, Gesamtsystem).

---

## Kritische Design-Entscheidungen (aus Sub A Spec)

| # | Entscheidung |
|---|--------------|
| Kurs-Hierarchie | Kurs → Modul (immer, auch als Phantom) → Lesson |
| Pass-Threshold | 80 % |
| Retry-Policy | Unbegrenzt; Fragen aus Pool neu gezogen |
| Lesson-Complete | Scroll ≥ 90 % + `min_read_seconds` + expliziter „Erledigt"-Klick |
| Freitext-Scoring | LLM-Vorschlag (Haiku 4.5) + **Head-Bestätigung zwingend** |
| Content-Authoring | Extern via Obsidian/MD-Git-Repo (kein WYSIWYG im ERP) |
| Import | Git-Webhook → `POST /api/elearn/admin/import` |
| Onboarding vs. Bestehend | Manueller Switch durch Head (nicht automatisch) |
| Zertifikate | PDF + interne Badges; kein Leaderboard |

---

## Bekannte Konsistenz-Regeln (immer einhalten)

- **Sidebar-Struktur** identisch in allen elearn-Files halten: Mein Bereich / Team (Head) / Admin
- **Topbar-Tool-Tabs** gleich wie in `elearn.html` — aktiver Tab je nach Seite anpassen
- **Keine DB-Technik-Begriffe** im User-facing-Text (keine `dim_elearn_*`, `fact_elearn_*`)
- **Echte Umlaute** (ä/ö/ü/ß, niemals ae/oe/ue/ss)
- **Drawer-Default-Regel**: CRUD → 540px Slide-in, kein Modal
- **Datum-Eingabe**: immer Kalender-Picker + manuelle Tastatur-Eingabe
- **Kein Mitarbeiter-Vollname**: Kürzel PW/JV/LR, nie "Peter Wiederkehr"
- **Sparten-Chips**: Farben konsistent (ARC=#FCE4E4/#B42525, GT=#E3F0FF/#1E5A9E, etc.)

---

## Empfohlene Session-Reihenfolge (Sub A fertigstellen)

1. `elearn-team.html` — Head-Übersicht (einfachste Head-View, guter Einstieg)
2. `elearn-freitext-queue.html` — kritischster Flow (LLM-Vorschlag + Head-Confirm)
3. `elearn-assignments.html` — Kurs-Zuweisung-Drawer
4. `elearn-my-compliance.html` — persönlicher Compliance-Status
5. `elearn-admin-courses.html` + `elearn-admin-curriculum.html` — Admin-Pair
6. `elearn-admin-imports.html` — Import-Log (relativ einfach, tabellarisch)
7. Sub C Newsletter-Pair (eigene Session)
8. Sub B Content-Generator (komplexeste View, eigene Session)

---

## Related
- [[mockup-baseline]] §16 — UI-Label-Vocabulary
- [[interaction-patterns]] §4 Drawer-Default, §14 Datum-Picker, §14a Briefing/Stellenbriefing
