# ARK CRM — Stammdaten-Patch · E-Learning Sub D · v0.1

**Scope:** Neue Enums, Activity-Types, UI-Label-Vocabulary für den Progress-Gate.
**Zielversion:** gemeinsam mit Sub A/B/C.
**Basis-Specs:** `specs/ARK_E_LEARNING_SUB_D_SCHEMA_v0_1.md`, `specs/ARK_E_LEARNING_SUB_D_INTERACTIONS_v0_1.md`.
**Vorherige Patches:** Sub A + B + C Stammdaten-Patches.
**Stand:** 2026-04-20
**Status:** Review ausstehend (Peter)

---

## Changelog

| # | Katalog | Änderung |
|---|---------|----------|
| 1 | `elearn_gate_trigger_type` | NEU (5 Werte) |
| 2 | `elearn_gate_event_action` | NEU (4 Werte) |
| 3 | `elearn_gate_override_type` | NEU (5 Werte) |
| 4 | `elearn_cert_status` | NEU (3 Werte) |
| 5 | `elearn_feature_catalog` | NEU (~40 Feature-Keys) |
| 6 | `dim_activity_types` | +8 Seed-Rows |
| 7 | `dim_event_types` | +12 Seed-Rows |

---

## 1. Neue Enums

### 1.1 `elearn_gate_trigger_type`

| Wert | Bedeutung |
|------|-----------|
| `newsletter_overdue` | Newsletter-Assignment nicht abgeschlossen |
| `onboarding_overdue` | Onboarding-Kurs-Assignment überfällig |
| `refresher_due` | Refresher-Assignment überfällig |
| `cert_expired` | Cert abgelaufen |
| `assignment_expired` | Generisches Assignment-Expired |

### 1.2 `elearn_gate_event_action`

| Wert | Bedeutung |
|------|-----------|
| `blocked` | Request blockiert |
| `allowed` | Request erlaubt (Rule griff nicht oder Whitelist) |
| `overridden` | Request erlaubt wegen aktiver Override |
| `bypassed` | Admin-Emergency-Bypass |

### 1.3 `elearn_gate_override_type`

| Wert | Bedeutung |
|------|-----------|
| `vacation` | Urlaub |
| `parental_leave` | Elternzeit |
| `medical` | Krankheit / medizinisch |
| `emergency_bypass` | Notfall-Bypass (Admin-only, kurzfristig) |
| `other` | Sonstiges (Reason-Pflicht) |

### 1.4 `elearn_cert_status`

| Wert | Bedeutung |
|------|-----------|
| `active` | Gültig |
| `expired` | Abgelaufen (refresher_months) |
| `revoked` | Zurückgenommen (Major-Version oder Admin-Manual) |

### 1.5 `elearn_feature_catalog` (Auszug)

Feature-Keys als Text, frei erweiterbar per Code-Deployment. Kategorisiert:

| Kategorie | Beispiele |
|-----------|-----------|
| write-candidate | `create_candidate`, `update_candidate`, `delete_candidate` |
| write-account | `create_account`, `update_account`, `delete_account` |
| write-mandate | `create_mandate`, `update_mandate`, `delete_mandate` |
| write-job | `create_job`, `update_job`, `delete_job` |
| write-process | `create_process`, `update_process`, `progress_process_stage` |
| write-project | `create_project`, `update_project` |
| write-activity | `create_activity` |
| write-placement | `create_placement` |
| write-email | `send_email` |
| read | `read_candidate`, `read_account`, `read_mandate`, `read_job`, `read_process`, `read_activity`, `read_placement`, `read_admin_*` |
| elearning | `elearning_*` |
| dashboard | `dashboard_full` |
| export | `export_data` |
| admin | `admin_*` |

**Wildcard-Match erlaubt:** `read_*` matcht alle `read_*`-Keys. Gate-Middleware unterstützt Prefix-Matching.

## 2. Erweiterung bestehender Kataloge

### 2.1 `dim_activity_types` — 8 neue Seed-Rows

| activity_type_name | activity_category | activity_channel | is_auto_loggable | description |
|--------------------|--------------------|------------------|------------------|-------------|
| elearn_gate_blocked | elearning | System | true | E-Learning: Feature-Zugriff blockiert |
| elearn_gate_overridden | elearning | System | true | E-Learning: Feature-Zugriff via Override erlaubt |
| elearn_gate_override_created | elearning | CRM | true | E-Learning: Gate-Override angelegt |
| elearn_gate_override_ended | elearning | CRM | true | E-Learning: Gate-Override beendet |
| elearn_cert_expired | elearning | System | true | E-Learning: Zertifikat abgelaufen |
| elearn_cert_revoked | elearning | System | true | E-Learning: Zertifikat zurückgenommen |
| elearn_course_major_version | elearning | System | true | E-Learning: Kurs-Major-Version publiziert |
| elearn_compliance_low | elearning | System | true | E-Learning: Compliance-Score-Warnung |

### 2.2 `dim_event_types` — 12 neue Seed-Rows

Siehe Backend-Patch `ARK_BACKEND_ARCHITECTURE_PATCH_ELEARNING_SUB_D_v0_1.md §2`.

## 3. UI-Label-Vocabulary (für `wiki/meta/mockup-baseline.md §16`)

| Enum-Wert | UI-Label (DE) |
|-----------|---------------|
| `gate_trigger_type=newsletter_overdue` | Newsletter offen |
| `gate_trigger_type=onboarding_overdue` | Onboarding überfällig |
| `gate_trigger_type=refresher_due` | Refresher fällig |
| `gate_trigger_type=cert_expired` | Zertifikat abgelaufen |
| `gate_trigger_type=assignment_expired` | Pflicht-Aufgabe abgelaufen |
| `gate_event_action=blocked` | Blockiert |
| `gate_event_action=allowed` | Erlaubt |
| `gate_event_action=overridden` | Ausnahme aktiv |
| `gate_event_action=bypassed` | Notfall-Bypass |
| `override_type=vacation` | Urlaub |
| `override_type=parental_leave` | Elternzeit |
| `override_type=medical` | Krankheit |
| `override_type=emergency_bypass` | Notfall-Bypass |
| `override_type=other` | Sonstiges |
| `cert_status=active` | Gültig |
| `cert_status=expired` | Abgelaufen |
| `cert_status=revoked` | Zurückgenommen |

## 4. Wiki-Sync

Nach Merge zu aktualisieren:

- `wiki/meta/mockup-baseline.md §16` — Sub-D-Label-Block + Feature-Catalog-Liste.
- `wiki/concepts/elearning-module.md` — Sub-D-Abschnitt „Progress-Gate".
- `wiki/concepts/gate-enforcement.md` — **neue Seite** mit Policy-Doku (Soft vs. Hard, Override-Verfahren, Compliance-Formel).
- `wiki/meta/spec-sync-regel.md` — Sub-D-Specs in Matrix.

## 5. Offene Punkte

- **Feature-Catalog-Auto-Discovery:** bei jedem Deploy scant ein Script alle `@gate_feature`-Decorators und synct `FEATURE_CATALOG.ts`. Stammdaten-Tabelle ist dann informativ; die Source-of-Truth lebt im Code.
- **Sparte-übergreifende Gate-Rules:** z. B. Admin will Rule nur für bestimmte Sparte → Trigger-Params um `sparten_filter` erweitern. Phase-2 falls benötigt.
- **Severity-Level:** pro Gate-Rule `severity ∈ {info, warning, critical}` für UI-Farbe? Phase-2.
