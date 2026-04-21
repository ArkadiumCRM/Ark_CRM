# ARK CRM — Gesamtsystem-Übersicht-Patch · E-Learning Sub C · v0.1

**Scope:** High-Level-Eintrag zur Gesamtsystem-Übersicht für den Wochen-Newsletter (Sub C).
**Zielversion:** Gesamtsystem v1.4 (gemeinsam mit Sub A/B).
**Basis-Specs:** `specs/ARK_E_LEARNING_SUB_C_SCHEMA_v0_1.md`, `specs/ARK_E_LEARNING_SUB_C_INTERACTIONS_v0_1.md`.
**Vorherige Patches:** Sub A + Sub B Gesamtsystem-Patches.
**Stand:** 2026-04-20
**Status:** Review ausstehend (Peter)

---

## Changelog

| # | Bereich | Änderung |
|---|---------|----------|
| 1 | Modul-Landkarte | Sub C Status: Spec v0.1 abgeschlossen |
| 2 | Daten-Flüsse | Sub B → Sub C Pipeline-Reuse (R1–R4b) dokumentiert |
| 3 | Phasen-Plan | Sub C Meilensteine ergänzt |
| 4 | Enforcement-Konzept | Soft- vs. Hard-Enforcement dokumentiert |
| 5 | Sub-Interaktionen | Sub A (Quiz) + Sub B (Pipeline) + Sub D (Gate) Abhängigkeiten |

---

## 1. Modul-Landkarte (aktualisiert)

```
Phase 3 · ERP-Ergänzungen
  ├── HR-Tool
  ├── Zeiterfassung
  ├── Commission-Engine
  ├── E-Learning
  │   ├── Sub A: Kurs-Katalog         (Specs v0.1 ✓, Patches v0.1 ✓)
  │   ├── Sub B: Content-Generator    (Specs v0.1 ✓, Patches v0.1 ✓)
  │   ├── Sub C: Wochen-Newsletter    (Specs v0.1 ✓, Patches v0.1 ✓)
  │   └── Sub D: Progress-Gate        (offen)
  └── Doc-Generator
```

## 2. Sub-C-Kern-Idee

**Arkadium-spezifisches Weiterbildungs-Pattern:** jeder MA erhält **wöchentlich einen Newsletter pro Sparte**, der aus CRM-Gesprächen der Vorwoche plus externen Markt-Quellen zusammengestellt wird. Pflicht-Quiz am Ende verhindert Durchklick-Verhalten. Soft-Enforcement mit Head-Escalation; Hard-Enforcement (CRM-Feature-Lock durch Sub D) als optionale Eskalationsstufe.

**Kosten-Nutzen:** Peter stellt sicher, dass aktuelles Markt-/CRM-Wissen kontinuierlich im Team verankert bleibt, ohne regelmässige Präsenz-Schulung. LLM-basierte Generation macht es skalierbar.

## 3. Sub-C-Meilensteine

1. Spec-Freigabe — **aktueller Stand**.
2. R4b-Runner implementieren (Port aus `C:\Linkedin_Automatisierung\lib\newsletter_generator.py`).
3. DB-Migration (4 neue Tabellen + `dim_user`-Column + Tenant-Settings).
4. Backend-API + Worker (Generator, Publisher, Reminder, Assignment-Creator).
5. MA-Frontend (`newsletter.html`, `newsletter-issue.html`).
6. Admin-Frontend (Config, Archive, Queue).
7. Pilot: 1 Sparte (ARC), 2 Wochen, Soft-Enforcement.
8. Erfahrungs-Review: wie hoch ist Read-Rate, wie viele Escalations, Quiz-Pass-Rate?
9. Roll-out: alle Sparten + Sparte-übergreifend.
10. Sub D Feature-Lock-Integration (falls Hard-Enforcement nötig).

## 4. Daten-Flüsse Sub B → Sub C

```
Sub B · R1 Ingest (Web-Scrape + CRM-Query der Vorwoche)
      │
      ▼
Sub B · R2 Chunk+Embed → dim_elearn_chunk
      │
      ▼
Sub B · R3 Cluster (Topic-Grouping)
      │
      ▼
Sub C · R4b Newsletter-Generate (neuer Runner, LLM-Prompt `newsletter_structure`)
      │
      ├── Section-Auswahl (3-6 Sections)
      ├── Section-Bodies (LLM-Prompt `newsletter_section_body` pro Section)
      └── Quiz-Pool (LLM-Prompt `newsletter_quiz_generation`)
      │
      ▼
dim_elearn_newsletter_issue (status='draft')
      │
      ▼
Sub C · Publisher (Cron stündlich, ab publish_at)
      │
      ▼
status='published' → Assignment-Creator
      │
      ▼
fact_elearn_newsletter_assignment pro abonniertem MA
      │
      ▼
MA liest im ERP-Frontend → Quiz durchläuft Sub-A-Engine
```

## 5. Enforcement-Konzept (neu dokumentiert)

### Soft (Default)

```
T0:   Assignment erstellt
T+48h: Reminder-Notification an MA
T+7d:  Head-Escalation (Team-Liste)
T+14d: Expired (Quiz-Chance verfallen)
```

Kein CRM-Feature-Lock. Banner auf Dashboard (Sub A).

### Hard

- Schreibt `enforcement_mode_applied='hard'` in Assignment.
- Sub D liest State und zeigt Gate-Page. MA hat keinen CRM-Zugriff bis Quiz-Pass.

**Per-MA-Override:** Admin kann einzelne MA auf `hard` setzen (z. B. säumige MA), auch wenn Tenant auf `soft` steht.

## 6. Interop mit bestehenden Modulen

| Modul | Berührungspunkt |
|-------|------------------|
| **Sub A (Kurs-Katalog)** | Quiz-Engine (identische `fact_elearn_quiz_attempt`-Logik mit `attempt_kind='newsletter'`) |
| **Sub B (Content-Gen)** | Pipeline-Reuse R1–R3 + eigener R4b-Runner |
| **Sub D (Progress-Gate)** | liest `fact_elearn_newsletter_assignment.enforcement_mode_applied` für Feature-Lock |
| **CRM (Kandidaten-, Account-, Prozess-Detailmasken)** | liefert via Sub B CRM-Query-Sources anonymisierte Daten für `crm_insights`-Sections |
| **User-Admin** | `user_sparte_changed`-Event triggert Subscription-Sync |

## 7. Kosten-Aspekt

Newsletter-Generation zählt gegen Sub-B-LLM-Cost-Cap (`elearn_b.llm_cost_cap_monthly_eur`). Pro Ausgabe ca. 0.3–1.5 €. Bei 5 Sparten × 4 Ausgaben/Monat → ~6–30 €/Monat LLM-Cost für Newsletter allein.

Admin-Dashboard zeigt separat: „Newsletter-Cost diesen Monat".

## 8. Sicherheit

- CRM-Daten in Newsletter-Content **strikt anonymisiert** (identisch Sub B).
- Keine direkten Kandidaten-/Kunden-Namen in Newslettern.
- Newsletter-Inhalte sind tenant-gescopt (kein Cross-Tenant-Leak via RAG).
- `newsletter_enforcement_override`-Änderungen sind audit-loggt (Event `elearn_newsletter_enforcement_override_set`).

## 9. Team-Verantwortlichkeiten

| Rolle | Sub-C-Verantwortung |
|-------|---------------------|
| Peter | Enforcement-Policy-Entscheid (Soft→Hard-Transition), Content-Review bei Bedarf |
| Head-of | Queue-Bearbeitung für eigene Team (überfällige Assignments, Manual-Reminder) |
| Admin/Backoffice | Tenant-Config, Schedule, Per-MA-Overrides, Archiv-Pflege |
| MA | Newsletter lesen + Quiz bestehen (wöchentliche Pflicht) |

## 10. Metriken

Neue KPIs auf `admin/newsletter-archive.html`:
- **Read-Rate:** `COUNT(assignments WHERE read_completed_at) / COUNT(assignments)`.
- **Quiz-Pass-Rate:** `COUNT(status='quiz_passed') / COUNT(assignments)`.
- **Time-to-Quiz:** durchschnittliches Delta `publish_at → quiz_passed`.
- **Escalation-Quote:** `COUNT(escalated_to_head_at IS NOT NULL) / COUNT(assignments)`.
- **Expiry-Rate:** `COUNT(status='expired') / COUNT(assignments)` (Kern-Indikator für Enforcement-Wirksamkeit).

## 11. Referenz-Dokumente

- **SCHEMA Sub C:** `specs/ARK_E_LEARNING_SUB_C_SCHEMA_v0_1.md`
- **INTERACTIONS Sub C:** `specs/ARK_E_LEARNING_SUB_C_INTERACTIONS_v0_1.md`
- **DB-Patch Sub C:** `specs/ARK_DATABASE_SCHEMA_PATCH_ELEARNING_SUB_C_v0_1.md`
- **Backend-Patch Sub C:** `specs/ARK_BACKEND_ARCHITECTURE_PATCH_ELEARNING_SUB_C_v0_1.md`
- **Stammdaten-Patch Sub C:** `specs/ARK_STAMMDATEN_PATCH_ELEARNING_SUB_C_v0_1.md`
- **Frontend-Patch Sub C:** `specs/ARK_FRONTEND_FREEZE_PATCH_ELEARNING_SUB_C_v0_1.md`

## 12. Offene Punkte / Follow-ups

- **Sub D** liest `enforcement_mode_applied='hard'` und implementiert Gate-UI. Nächste Brainstorming-Runde.
- **Email-Fallback:** falls MA tagelang nicht im CRM ist, könnte Email ein Reminder-Kanal werden. Phase-2.
- **Ad-hoc-Newsletter:** Admin triggert Sonder-Ausgabe bei relevantem externen Ereignis (z. B. Gesetzesänderung). Endpoint existiert, UI-Flow ist Phase-2.
- **Mobile-Responsive-Priorität:** ERP ist Desktop-first, aber Newsletter-Lesen wäre mobile sinnvoll. Phase-2-Feature.
