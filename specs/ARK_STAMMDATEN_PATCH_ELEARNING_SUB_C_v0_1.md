# ARK CRM — Stammdaten-Patch · E-Learning Sub C · v0.1

**Scope:** Neue Enums, Activity-Types und UI-Label-Vocabulary für den Wochen-Newsletter (Sub C).
**Zielversion:** gemeinsam mit Sub-A/B-Patches.
**Basis-Specs:** `specs/ARK_E_LEARNING_SUB_C_SCHEMA_v0_1.md`, `specs/ARK_E_LEARNING_SUB_C_INTERACTIONS_v0_1.md`.
**Vorherige Patches:** Sub A + Sub B Stammdaten-Patches.
**Stand:** 2026-04-20
**Status:** Review ausstehend (Peter)

---

## Changelog

| # | Katalog | Änderung |
|---|---------|----------|
| 1 | `elearn_newsletter_section_type` | NEU (6 Werte) |
| 2 | `elearn_newsletter_status` | NEU (4 Werte) |
| 3 | `elearn_newsletter_assignment_status` | NEU (6 Werte) |
| 4 | `elearn_newsletter_subscription_mode` | NEU (3 Werte) |
| 5 | `elearn_newsletter_enforcement_mode` | NEU (2 Werte: soft/hard) |
| 6 | `elearn_attempt_kind` | Wert `newsletter` aktiviert (in Sub A bereits reserviert) |
| 7 | `dim_activity_types` | +9 Seed-Rows (`elearn_nl_*`) |
| 8 | `dim_event_types` | +12 Seed-Rows (`elearn_newsletter_*`) |

---

## 1. Neue Enums

### 1.1 `elearn_newsletter_section_type`

| Wert | Bedeutung |
|------|-----------|
| `market_news` | Markt-News aus Web-Scrape der Vorwoche |
| `crm_insights` | Anonymisierte CRM-Aggregate („Was im Team passiert ist") |
| `deep_dive` | 1 Thema vertieft (aus Kurs-Content oder Bücher) |
| `spotlight` | Person/Firma/Konzept der Woche |
| `trend_watch` | Multi-Source-Trend-Analyse |
| `ma_highlight` | Team-Erfolg der Woche (z. B. Placements) |

### 1.2 `elearn_newsletter_status`

| Wert | Bedeutung |
|------|-----------|
| `draft` | Generiert, Review ausstehend |
| `review` | Admin reviewt aktiv |
| `published` | Live, Assignments erzeugt |
| `archived` | Aus MA-Archive ausgeblendet |

### 1.3 `elearn_newsletter_assignment_status`

| Wert | Bedeutung |
|------|-----------|
| `pending` | Zugewiesen, nicht gestartet |
| `reading` | Read-Flow aktiv |
| `quiz_in_progress` | Alle Sections gelesen, Quiz läuft |
| `quiz_passed` | Quiz bestanden (≥ `quiz_pass_threshold`) |
| `quiz_failed` | Quiz nicht bestanden (Retry möglich) |
| `expired` | Deadline überschritten |

### 1.4 `elearn_newsletter_subscription_mode`

| Wert | Bedeutung |
|------|-----------|
| `auto` | Automatisch aus `dim_user.sparte` |
| `opt_in` | Freiwillig abonniert |
| `opt_out` | Abbestellt (nur wenn Tenant-Setting erlaubt) |

### 1.5 `elearn_newsletter_enforcement_mode`

| Wert | Bedeutung |
|------|-----------|
| `soft` | Reminder + Head-Escalation, kein Feature-Lock |
| `hard` | Feature-Lock durch Sub D bei Nicht-Bearbeitung |

## 2. `elearn_attempt_kind` — Wert `newsletter` aktivieren

Aus Sub-A-Patch reserviert (`attempt_kind='newsletter'`). Ab Sub C wird dieser Wert produktiv:

| Wert | Bedeutung |
|------|-----------|
| `module` | Regulärer Modul-Quiz |
| `pretest` | Skip-Ahead |
| `newsletter` | Newsletter-Pflicht-Quiz (**Sub C, jetzt aktiv**) |

Kein DB-Migrations-Change nötig (CHECK bereits vorhanden).

## 3. Erweiterung bestehender Kataloge

### 3.1 `dim_activity_types` — Seed-Rows (9 neu)

| activity_type_name | activity_category | activity_channel | is_auto_loggable | description |
|--------------------|--------------------|------------------|------------------|-------------|
| elearn_nl_published | elearning | System | true | E-Learning: Newsletter publiziert |
| elearn_nl_assigned | elearning | System | true | E-Learning: Newsletter zugewiesen |
| elearn_nl_quiz_passed | elearning | CRM | true | E-Learning: Newsletter-Quiz bestanden |
| elearn_nl_quiz_failed | elearning | CRM | true | E-Learning: Newsletter-Quiz nicht bestanden |
| elearn_nl_reminder | elearning | System | true | E-Learning: Newsletter-Reminder gesendet |
| elearn_nl_escalated | elearning | System | true | E-Learning: Head-Escalation |
| elearn_nl_expired | elearning | System | true | E-Learning: Newsletter-Assignment abgelaufen |
| elearn_nl_override | elearning | CRM | true | E-Learning: Enforcement-Override gesetzt |
| elearn_nl_skipped | elearning | System | true | E-Learning: Newsletter-Generation übersprungen (zu wenig Content) |

(Kategorie `elearning` existiert bereits.)

### 3.2 `dim_event_types` — Seed-Rows (12 neu)

Siehe Backend-Patch `ARK_BACKEND_ARCHITECTURE_PATCH_ELEARNING_SUB_C_v0_1.md §1`.

## 4. UI-Label-Vocabulary (für `wiki/meta/mockup-baseline.md §16`)

| Enum-Wert | UI-Label (DE) |
|-----------|---------------|
| `section_type=market_news` | Markt-News |
| `section_type=crm_insights` | Team-Einblicke |
| `section_type=deep_dive` | Vertiefung |
| `section_type=spotlight` | Im Fokus |
| `section_type=trend_watch` | Trends |
| `section_type=ma_highlight` | Team-Highlight |
| `newsletter_status=draft` | Entwurf |
| `newsletter_status=review` | In Prüfung |
| `newsletter_status=published` | Veröffentlicht |
| `newsletter_status=archived` | Archiviert |
| `nl_assignment_status=pending` | Offen |
| `nl_assignment_status=reading` | Beim Lesen |
| `nl_assignment_status=quiz_in_progress` | Quiz läuft |
| `nl_assignment_status=quiz_passed` | Bestanden |
| `nl_assignment_status=quiz_failed` | Nicht bestanden |
| `nl_assignment_status=expired` | Abgelaufen |
| `subscription_mode=auto` | Automatisch (Pflicht) |
| `subscription_mode=opt_in` | Freiwillig |
| `subscription_mode=opt_out` | Abbestellt |
| `enforcement_mode=soft` | Erinnerungen |
| `enforcement_mode=hard` | Pflicht-Lock |
| `attempt_kind=newsletter` | Newsletter-Quiz |

## 5. Wiki-Sync

- `wiki/meta/mockup-baseline.md §16` — Sub-C-Label-Block ergänzen.
- `wiki/concepts/elearning-module.md` — Sub-C-Abschnitt.
- `wiki/meta/spec-sync-regel.md` — Sub-C-Specs in Matrix aufnehmen.

## 6. Offene Punkte

- **Sparte-Wert `'uebergreifend'`:** nicht offiziell in Stammdaten-Sparten-Katalog; als Sonder-Wert im Newsletter-Kontext dokumentiert. Falls langfristig cross-cutting Themen in anderen Modulen auftauchen, Sparten-Katalog um diesen Wert erweitern.
- **Enforcement-Mode als eigener Katalog:** ggf. erweitern (z. B. `warn_only`, `delay_lock`) — Phase-2, wenn Erfahrung mit Soft/Hard reicht nicht.
