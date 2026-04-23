# ARK CRM — Stammdaten-Patch · E-Learning · v0.1

**Scope:** Neue Enums, Activity-Types und Katalog-Werte für das Phase-3-ERP-Modul E-Learning (Sub A · Kurs-Katalog).
**Zielversion:** `ARK_STAMMDATEN_EXPORT_v1_4.md` bzw. `v1_5.md` (finale Version beim Merge festzulegen; baut auf Activity-Types-Patch `v1_3_to_v1_4_ACTIVITY_TYPES` auf).
**Basis-Specs:** `specs/ARK_E_LEARNING_SUB_A_SCHEMA_v0_1.md`, `specs/ARK_E_LEARNING_SUB_A_INTERACTIONS_v0_1.md`.
**Vorheriger Patch:** `specs/ARK_STAMMDATEN_PATCH_v1_3_to_v1_4_ACTIVITY_TYPES.md`.
**Stand:** 2026-04-20
**Status:** Review ausstehend (Peter)

---

## Changelog

| # | Katalog | Änderung |
|---|---------|----------|
| 1 | `elearn_assignment_reason` | NEU (5 Werte) |
| 2 | `elearn_assignment_status` | NEU (4 Werte) |
| 3 | `elearn_attempt_kind` | NEU (3 Werte, `newsletter` erst ab Sub C aktiv) |
| 4 | `elearn_attempt_status` | NEU (3 Werte) |
| 5 | `elearn_review_status` | NEU (4 Werte) |
| 6 | `elearn_question_type` | NEU (6 Werte) |
| 7 | `elearn_course_status` | NEU (3 Werte) |
| 8 | `elearn_badge_type` | NEU (4 Werte Initial-Katalog, erweiterbar) |
| 9 | `dim_activity_types.activity_category` | CHECK erweitert um `'elearning'` |
| 10 | `dim_activity_types` | +11 Seed-Rows (`elearn_*` Activity-Types) |
| 11 | `dim_event_types.event_category` | CHECK erweitert um `'elearning'` |
| 12 | `dim_event_types` | +16 Seed-Rows (`elearn_*` Events) |

**Nicht Teil dieses Patches:**
- Newsletter-spezifische Activity-Types (kommen in Sub C).
- Gate-/Enforcement-Typen (kommen in Sub D).

---

## 1. Neue Enums

### 1.1 `elearn_assignment_reason`

| Wert | Bedeutung |
|------|-----------|
| `onboarding` | Automatisch bei neuer MA aus Curriculum-Template erzeugt |
| `adhoc` | Ad-hoc vom Head oder Admin zugewiesen (z. B. neuer Pflicht-Kurs für alle ARC) |
| `refresher` | Periodisch neu ausgelöst nach `dim_elearn_course.refresher_months` |
| `role_change` | Nach Rollen-Wechsel aus Curriculum-Template-Diff |
| `sparten_change` | Nach Sparten-Wechsel aus Curriculum-Template-Diff |

### 1.2 `elearn_assignment_status`

| Wert | Bedeutung |
|------|-----------|
| `active` | Offen, MA soll bearbeiten |
| `completed` | Kurs abgeschlossen (`fact_elearn_enrollment.status=completed`) |
| `expired` | Deadline überschritten ohne Abschluss |
| `cancelled` | Head oder Admin hat Assignment zurückgezogen |

### 1.3 `elearn_attempt_kind`

| Wert | Bedeutung |
|------|-----------|
| `module` | Regulärer Modul-Quiz |
| `pretest` | Skip-Ahead-Versuch (1× pro Kurs, höhere Schwelle) |
| `newsletter` | Sub C: Wochen-Newsletter-Quiz (reserviert, Sub A noch inaktiv) |

### 1.4 `elearn_attempt_status`

| Wert | Bedeutung |
|------|-----------|
| `in_progress` | Fragen-Ziehung erfolgt, submit noch offen |
| `pending_review` | Freitext-Fragen warten auf Head-Review |
| `finalized` | Ergebnis endgültig, `score_pct` und `passed` gesetzt |

### 1.5 `elearn_review_status`

| Wert | Bedeutung |
|------|-----------|
| `pending` | LLM-Vorschlag ggf. vorhanden, Head-Review offen |
| `confirmed` | Head hat LLM-Vorschlag bestätigt |
| `overridden` | Head hat explizite eigene Werte gesetzt |
| `confirmed_auto` | Nach SLA-Eskalation automatisch auf LLM-Score finalisiert (nur wenn `llm_score IS NOT NULL`) |

### 1.6 `elearn_question_type`

| Wert | Bedeutung |
|------|-----------|
| `mc` | Single-Choice (Radio) |
| `multi` | Multi-Select (Checkbox) |
| `freitext` | Freitext, LLM-gescort + Head-Review |
| `truefalse` | Ja/Nein |
| `zuordnung` | Paar-Zuordnung (Drag-Drop) |
| `reihenfolge` | Sortieren (Drag-Drop) |

### 1.7 `elearn_course_status`

| Wert | Bedeutung |
|------|-----------|
| `draft` | Importiert, aber nicht für MA sichtbar |
| `published` | Für Zielgruppe sichtbar und zuweisbar |
| `archived` | Nicht mehr zuweisbar; bestehende Enrollments laufen auf gepinnter Version weiter |

### 1.8 `elearn_badge_type` (Initial-Katalog, erweiterbar)

| Wert | Bedeutung |
|------|-----------|
| `first_course` | Erster Kurs abgeschlossen |
| `all_onboarding` | Gesamtes Onboarding-Curriculum abgeschlossen |
| `sparte_expert` | Alle Kurse der eigenen Sparte abgeschlossen |
| `streak_7` | 7 Tage in Folge mindestens 1 Lesson abgeschlossen |

Neue Badge-Types können ohne DB-Migration ergänzt werden (Text-Feld; Dokumentation hier zu pflegen).

## 2. Erweiterungen bestehender Kataloge

### 2.1 `dim_activity_types.activity_category`

**CHECK erweitern:**

```sql
ALTER TABLE dim_activity_types DROP CONSTRAINT IF EXISTS dim_activity_types_activity_category_check;
ALTER TABLE dim_activity_types ADD CONSTRAINT dim_activity_types_activity_category_check
  CHECK (activity_category IN (
    'Kontaktberührung','Erreicht','Emailverkehr','Messaging',
    'Interviewprozess','Placementprozess','Refresh Kandidatenpflege',
    'Mandatsakquise','Erfolgsbasis','Assessment','System',
    -- neu aus Activity-Types-Patch v1_3_to_v1_4:
    'guarantee','protection_window','saga','ai','finance','referral','assessment',
    -- neu aus diesem Patch:
    'elearning'
  ));
```

### 2.2 `dim_activity_types` — Seed-Rows (11 neu)

| activity_type_name | activity_category | activity_channel | is_auto_loggable | description |
|--------------------|--------------------|------------------|------------------|-------------|
| elearn_assigned | elearning | CRM | true | E-Learning: Kurs zugewiesen |
| elearn_started | elearning | CRM | true | E-Learning: Kurs gestartet |
| elearn_completed | elearning | CRM | true | E-Learning: Kurs abgeschlossen |
| elearn_quiz_passed | elearning | CRM | true | E-Learning: Quiz bestanden |
| elearn_quiz_failed | elearning | CRM | true | E-Learning: Quiz nicht bestanden |
| elearn_cert | elearning | System | true | E-Learning: Zertifikat ausgestellt |
| elearn_badge | elearning | System | true | E-Learning: Badge vergeben |
| elearn_refresher | elearning | System | true | E-Learning: Refresher ausgelöst |
| elearn_role_change | elearning | System | true | E-Learning: Rollen-/Sparten-Wechsel-Curriculum |
| elearn_expired | elearning | System | true | E-Learning: Assignment abgelaufen |
| elearn_onboarding_done | elearning | CRM | true | E-Learning: Onboarding abgeschlossen |

### 2.3 `dim_event_types.event_category`

**CHECK erweitern:** `event_category IN (..., 'elearning')`.

### 2.4 `dim_event_types` — Seed-Rows (16 neu)

Siehe Backend-Architektur-Patch `ARK_BACKEND_ARCHITECTURE_PATCH_ELEARNING_v0_1.md §1`.

## 3. UI-Label-Vocabulary

Kanonische deutsche Labels für User-facing Texte (für `wiki/meta/mockup-baseline.md §16` zu ergänzen):

| Enum-Wert | UI-Label (DE) |
|-----------|---------------|
| `assignment_reason=onboarding` | Onboarding |
| `assignment_reason=adhoc` | Einmalige Zuweisung |
| `assignment_reason=refresher` | Refresher |
| `assignment_reason=role_change` | Rollen-Wechsel |
| `assignment_reason=sparten_change` | Sparten-Wechsel |
| `assignment_status=active` | Aktiv |
| `assignment_status=completed` | Abgeschlossen |
| `assignment_status=expired` | Überfällig |
| `assignment_status=cancelled` | Zurückgezogen |
| `attempt_kind=module` | Modul-Quiz |
| `attempt_kind=pretest` | Pre-Test |
| `attempt_kind=newsletter` | Newsletter-Quiz |
| `attempt_status=in_progress` | In Bearbeitung |
| `attempt_status=pending_review` | In Prüfung |
| `attempt_status=finalized` | Ausgewertet |
| `review_status=pending` | Offen |
| `review_status=confirmed` | Bestätigt |
| `review_status=overridden` | Überschrieben |
| `review_status=confirmed_auto` | Automatisch bestätigt |
| `course_status=draft` | Entwurf |
| `course_status=published` | Veröffentlicht |
| `course_status=archived` | Archiviert |
| `badge_type=first_course` | Erster Kurs |
| `badge_type=all_onboarding` | Onboarding-Champion |
| `badge_type=sparte_expert` | Sparten-Experte |
| `badge_type=streak_7` | Lern-Streak (7 Tage) |

**Regel:** Niemals Enum-Werte (snake_case, englisch) direkt im UI anzeigen. Immer über dieses Vocabulary-Mapping rendern.

## 4. Wiki-Sync

Folgende Wiki-Seiten sind nach Merge dieses Patches zu aktualisieren:

- `wiki/meta/mockup-baseline.md §16` — UI-Label-Vocabulary um E-Learning-Block ergänzen.
- `wiki/concepts/` — neue Seite `elearning-module.md` mit Modul-Übersicht (Sub A/B/C/D).
- `wiki/meta/spec-sync-regel.md` — E-Learning-Specs in Sync-Matrix aufnehmen.

## 5. Offene Punkte

- **Refresher-Intervall-Presets:** Soll es vordefinierte Werte (6/12/24 Monate) als Enum geben, oder bleibt `refresher_months` freies `INT`? MVP: frei, Enum-Vorschlag in Phase-2 falls Pflege-Aufwand hoch.
- **Badge-Kriterien-Formalisierung:** Aktuell im Badge-Engine-Code hart verdrahtet. Phase-2: Regel-Tabelle `dim_elearn_badge_rule` mit JSON-Kriterien, falls Peter/Head eigene Badges definieren will.
