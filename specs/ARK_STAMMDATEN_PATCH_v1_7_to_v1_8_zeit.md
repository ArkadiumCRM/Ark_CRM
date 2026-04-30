---
title: "ARK Stammdaten-Patch v1.7 → v1.8 · Zeit-Modul"
type: spec
module: zeit
version: 1.8
created: 2026-04-30
updated: 2026-04-30
status: Erstentwurf · Phase-3-ERP Sync-Patch
sources: [
  "Grundlagen MD/ARK_STAMMDATEN_EXPORT_v1_7.md",
  "specs/ARK_ZEIT_SCHEMA_v0_1.md",
  "specs/ARK_ZEIT_INTERACTIONS_v0_1.md",
  "specs/ARK_DATABASE_SCHEMA_PATCH_v1_8_to_v1_9_zeit.md"
]
tags: [stammdaten, patch, zeit, seeds, absenzen, kategorien, feiertage, activity-types, arbeitszeit-modelle]
---

# ARK Stammdaten-Patch v1.7 → v1.8 · Zeit-Modul

**Stand:** 2026-04-30
**Status:** Erstentwurf · Phase-3-ERP Sync-Patch
**Quellen:**
- `Grundlagen MD/ARK_STAMMDATEN_EXPORT_v1_7.md` (Vorgänger · enthält bereits HR-Patch v1.6 → v1.7)
- `specs/ARK_ZEIT_SCHEMA_v0_1.md` §4 (Dim-Tables · Seeds-Tabellen) · §5 (firm_settings) · §9 (Seeds-Zusammenfassung)
- `specs/ARK_ZEIT_INTERACTIONS_v0_1.md` §6 (Rollen-Matrix für Activity-Type-Mapping)
- `specs/ARK_DATABASE_SCHEMA_PATCH_v1_8_to_v1_9_zeit.md` (FK-Targets)

**Vorrang:** Stammdaten > Schema > Patch > Mockups

---

## 0. ZIELBILD

Dieser Patch seeded alle Stammdaten-Inhalte für das Zeit-Modul:

- **§80 Zeit · Abwesenheits-Typen** (`dim_absence_type`) — 30 Default-Seeds (Reglement + EOG + OR + Extra-Guthaben)
- **§81 Zeit · Zeit-Kategorien** (`dim_time_category`) — 12 Seeds (Billable / ZEG-relevant / Pause)
- **§82 Zeit · Arbeitszeit-Modelle** (`dim_work_time_model`) — 5 Seeds (FLEX_CORE Default + 4 Sondermodelle)
- **§83 Zeit · Lohnfortzahlungs-Skalen** (`dim_salary_continuation_scale`) — 18 Seeds (9 ZH + 9 BE)
- **§84 Zeit · Feiertags-Kalender** (`fact_holiday_cantonal`) — 12 Seeds 2026 (ZH + Reglement-Sperrfristen)
- **§85 Zeit · Korrektur-Gründe** (`dim_time_correction_reason`) — 8 Seeds (Stempel-Antrag-Dropdown)
- **§86 Zeit · firm_settings-Keys** — 22 Konfig-Werte (Reglement + Peter-Decisions)
- **§14 Activity-Types-Erweiterung** — 5 neue Aktivitäten für Zeit-Touchpoints
- **§10a UI-Label-Vocabulary-Erweiterung** — Mapping Enum → User-Label

---

## 1. §80 Zeit · `dim_absence_type` Seeds (30 Rows)

| code | label_de | paid | category | 1DJ | 2DJ | 3+DJ | max_days/J | legal |
|------|----------|------|----------|-----|-----|------|------------|-------|
| `VACATION` | Ferien | ✓ | policy | – | – | – | 25 | OR 329a |
| `VACATION_HALF_AM` | Ferien-Halbtag Vormittag | ✓ | policy | – | – | – | – | OR 329a |
| `VACATION_HALF_PM` | Ferien-Halbtag Nachmittag | ✓ | policy | – | – | – | – | OR 329a |
| `SICK_PAID` | Krankheit (bezahlt) | ✓ | medical | 1 | 2 | 3 | – | OR 324a · Reglement §3.5.2 |
| `SICK_UNPAID` | Krankheit (unbezahlt) | ✗ | medical | 1 | 1 | 1 | – | OR 324a |
| `ACCIDENT_OCC` | Berufsunfall (UVG) | ✓ | medical | 1 | 1 | 1 | – | UVG |
| `ACCIDENT_NOCC` | Nichtberufsunfall (UVG) | ✓ | medical | 1 | 1 | 1 | – | UVG |
| `MILITARY` | Militärdienst | ✓ | civic | – | – | – | – | EOG · OR 324b |
| `CIVIL_SERVICE` | Zivildienst | ✓ | civic | – | – | – | – | EOG |
| `CIVIL_PROTECTION` | Zivilschutz | ✓ | civic | – | – | – | – | EOG |
| `FIREFIGHTER` | Feuerwehr-Einsatz | ✓ | civic | – | – | – | – | EOG |
| `REDCROSS` | Rotkreuz-Einsatz | ✓ | civic | – | – | – | – | EOG |
| `MATERNITY` | Mutterschaftsurlaub 16 Wo | ✓ | family | – | – | – | – | EOG 16b · Reglement §6.2.3 |
| `OTHER_PARENT` | Vaterschafts-/Elternteil (10 AT) | ✓ | family | – | – | – | 10 | EOG 16i |
| `ADOPTION` | Adoptionsurlaub (10 AT) | ✓ | family | – | – | – | 10 | EOG 16t |
| `CARE_RELATIVE` | Pflege Angehörige (3/Ereignis · 10/J) | ✓ | family | 4 | 4 | 4 | 10 | OR 329h |
| `CARE_CHILD_LONG` | Betreuung krankes Kind (98 AT/18 Mt) | ✓ | family | – | – | – | – | EOG 16n |
| `COMP_TIME` | Kompensation Überstunden/Überzeit | ✓ | policy | – | – | – | – | OR 321c · Reglement §2 |
| `UNPAID_LEAVE` | Unbezahlter Urlaub | ✗ | policy | – | – | – | – | vertraglich |
| `BEREAVEMENT` | Trauerfall | ✓ | policy | – | – | – | 3 | Firmen-Policy |
| `WEDDING` | Eigene Hochzeit/Partnerschaft | ✓ | policy | – | – | – | 1 | OR 329 Abs. 3 |
| `MOVE` | Umzug | ✓ | policy | – | – | – | 1 | Firmen-Policy |
| `OFFICIAL_DUTY` | Amtliche Vorladung/öffentliches Amt | ✓ | civic | – | – | – | – | OR 324a analog |
| `EDUCATION_PAID` | Weiterbildung (bezahlt) | ✓ | policy | – | – | – | – | Firmen-Policy |
| `EXTRA_BIRTHDAY_SELF` | Extra: Geburtstag MA (1 T/J) | ✓ | extra | – | – | – | 1 | Reglement §2 Extra-Guthaben |
| `EXTRA_BIRTHDAY_CLOSE` | Extra: Geburtstag Angehörige (1 T/J) | ✓ | extra | – | – | – | 1 | Reglement §2 |
| `EXTRA_JOKER` | Extra: Jokertag (Me Time) (1 T/J) | ✓ | extra | – | – | – | 1 | Reglement §2 |
| `EXTRA_ZEG` | Extra: ZEG-Zielerreichung (1 T/Halbjahr bei ≥100%) | ✓ | extra | – | – | – | 2 | Reglement §2 |
| `EXTRA_GL` | Extra: GL-Ermessen (bis 3 T) | ✓ | extra | – | – | – | 3 | Reglement §2 |
| `SABBATICAL` | Sabbatical | ✗ | policy | – | – | – | – | Firmen-Policy |

**Pflicht-Approval:** alle ausser `SICK_*` (sofort `active`, keine Approval-Schwelle).

**Kanonisches UI-Label-Vocabulary** (für `mockup-baseline.md` §16): keine Codes im UI, immer `label_de` aus dieser Tabelle.

---

## 2. §81 Zeit · `dim_time_category` Seeds (12 Rows)

| code | label_de | billable | project_required | counts_as_worktime | is_break | zeg_relevant | sort |
|------|----------|----------|------------------|--------------------|----------|--------------|------|
| `PROD_BILL` | Produktiv – verrechenbar | ✓ | ✓ | ✓ | ✗ | ✓ | 10 |
| `PROD_NONBILL` | Produktiv – nicht verrechenbar | ✗ | ✓ | ✓ | ✗ | ✓ | 20 |
| `CLIENT_MEETING` | Kunden-Termin | ✓ | ✓ | ✓ | ✗ | ✓ | 30 |
| `CANDIDATE_MEETING` | Kandidaten-Interview | ✗ | ✓ | ✓ | ✗ | ✓ | 40 |
| `RESEARCH` | Research / Sourcing / Mapping | ✗ | ✓ | ✓ | ✗ | ✓ | 50 |
| `BD_SALES` | Business Development | ✗ | ✓ | ✓ | ✗ | ✗ | 60 |
| `TEAM_DEV` | Team-/Persönlichkeitsentwicklung | ✗ | ✗ | ✓ | ✗ | ✗ | 70 |
| `ADMIN` | Administration | ✗ | ✗ | ✓ | ✗ | ✗ | 80 |
| `INTERNAL_MEETING` | Internes Meeting / Jour fixe | ✗ | ✗ | ✓ | ✗ | ✗ | 90 |
| `TRAINING` | Training / Weiterbildung | ✗ | ✗ | ✓ | ✗ | ✗ | 100 |
| `TRAVEL_WORK` | Reisezeit (geschäftlich) | ✗ | ✓ | ✓ | ✗ | ✗ | 110 |
| `BREAK` | Pause | ✗ | ✗ | ✗ | ✓ | ✗ | 999 |

**Mockup-Phase-Note:** UI-Tages-Eintrag-Drawer zeigt **keine** Kategorie-Zuordnung mehr (Delta v0.1 → v0.2 §12.4 in `ARK_ZEIT_INTERACTIONS_v0_1.md`). Worker `scan-event-processor` füllt Default `PROD_NONBILL`. Kategorie-Auswahl optional via Admin-Override. ZEG-Berechnung in Commission-Engine nutzt `v_time_per_mandate.zeg_relevant_min`.

---

## 3. §82 Zeit · `dim_work_time_model` Seeds (5 Rows)

| code | label_de | simplified_recording | subject_to_arg | requires_core_time | requires_scanner | legal |
|------|----------|---------------------|---------------|--------------------|------------------|-------|
| `FLEX_CORE` | Gleitzeit mit Kernzeit (Default) | ✗ | ✓ | ✓ | ✓ | ArG 9 |
| `FIXED` | Fix-Zeit | ✗ | ✓ | ✗ | ✓ | ArG 9 |
| `PARTTIME` | Teilzeit % | ✗ | ✓ | ✓ | ✓ | ArG/OR |
| `SIMPLIFIED_73B` | Vereinfachte Erfassung 73b | ✓ | ✓ | ✗ | ✗ | ArGV 1 Art. 73b |
| `EXEMPT_EXEC` | Höhere leitende Tätigkeit | ✓ | ✗ | ✗ | ✗ | Art. 3 lit. d ArG · enge Prüfung |

**Default-Zuweisung:** alle MA `FLEX_CORE`. Ausnahmen: PW (Managing Partner) optional `EXEMPT_EXEC` mit dokumentierter Entscheidung.

---

## 4. §83 Zeit · `dim_salary_continuation_scale` Seeds (18 Rows)

**Zürcher Skala** (Default lt. Reglement Generalis Provisio §6.2.1):

| scale | DJ_from | DJ_to | weeks |
|-------|---------|-------|-------|
| `ZURICH` | 1 | 1 | 3 |
| `ZURICH` | 2 | 2 | 8 |
| `ZURICH` | 3 | 3 | 9 |
| `ZURICH` | 4 | 4 | 10 |
| `ZURICH` | 5 | 9 | 11 |
| `ZURICH` | 10 | 14 | 16 |
| `ZURICH` | 15 | 19 | 21 |
| `ZURICH` | 20 | 24 | 26 |
| `ZURICH` | 25 | NULL | 31 |

**Berner Skala** (Alternative · für andere Tenants):

| scale | DJ_from | DJ_to | weeks |
|-------|---------|-------|-------|
| `BERN` | 1 | 1 | 3 |
| `BERN` | 2 | 2 | 4.33 |
| `BERN` | 3 | 4 | 8.67 |
| `BERN` | 5 | 9 | 13 |
| `BERN` | 10 | 14 | 17.33 |
| `BERN` | 15 | 19 | 21.67 |
| `BERN` | 20 | 24 | 26 |
| `BERN` | 25 | NULL | 30.33 |

**Gerichtspraxis-Referenz:** BGE 124 III 126 (Skalen zulässig als Konkretisierung von OR 324a).

---

## 5. §84 Zeit · `fact_holiday_cantonal` Seeds 2026 (12 Rows)

**Kanton Zürich + Reglement-Berchtoldstag + 2 Sperrfristen-Halbtage:**

| date | label | statutory | half_day | credit | note |
|------|-------|-----------|----------|--------|------|
| `2026-01-01` | Neujahr | ✓ | – | 1.000 | ArG 20a |
| `2026-01-02` | Berchtoldstag | ✗ | – | 1.000 | Tempus Passio (als bezahlt gewährt) |
| `2026-04-03` | Karfreitag | ✓ | – | 1.000 | – |
| `2026-04-06` | Ostermontag | ✓ | – | 1.000 | – |
| `2026-05-01` | Tag der Arbeit | ✓ | – | 1.000 | ZH-Sonderregelung |
| `2026-05-14` | Auffahrt | ✓ | – | 1.000 | – |
| `2026-05-25` | Pfingstmontag | ✓ | – | 1.000 | – |
| `2026-08-01` | Bundesfeier | ✓ | – | 1.000 | fällt auf Sa |
| `2026-12-25` | Weihnachten | ✓ | – | 1.000 | – |
| `2026-12-26` | Stephanstag | ✓ | – | 1.000 | fällt auf Sa |
| `2026-04-20` | Sechseläuten (Halbtag PM) | ✗ | ✓ | 0.500 | Reglement-Sperrfrist |
| `2026-09-14` | Knabenschiessen (Halbtag PM) | ✗ | ✓ | 0.500 | Reglement-Sperrfrist |

**Maintenance:** jährlicher Seed-Refresh (Worker `holidays-yearly-seed`) im Q4 für Folgejahr.

**Bridge-Days** (`fact_bridge_day`): GF-manuell pro Jahr in Admin-UI (F11-Decision · Tab "Feiertage-Editor" · siehe FE-Patch v1.16 §1).

---

## 6. §85 Zeit · `dim_time_correction_reason` Seeds (8 Rows)

Stempel-Antrag-Grund-Dropdown für manuelle Nachträge (Delta v0.1 → v0.2 §12.3 in `ARK_ZEIT_INTERACTIONS_v0_1.md`):

| code | label_de | sort | active |
|------|----------|------|--------|
| `home_office` | Home-Office | 10 | ✓ |
| `remote_work` | Remote-Arbeit | 20 | ✓ |
| `scanner_defect` | Scanner-Defekt | 30 | ✓ |
| `forgotten_scan` | Vergessen zu stempeln | 40 | ✓ |
| `external_appointment` | Termin extern | 50 | ✓ |
| `early_leave` | Früh weg | 60 | ✓ |
| `late_arrival` | Spät gekommen | 70 | ✓ |
| `other` | Sonstiges (Freitext-Pflicht) | 999 | ✓ |

**UI-Pattern:** Dropdown · `other` triggert Pflicht-Freitext-Feld. Kein Freitext für die anderen Codes (Strukturierung für Reporting).

---

## 7. §86 Zeit · `firm_settings` Seeds (22 Keys)

| key | value | description |
|-----|-------|-------------|
| `max_daily_hours` | `10.0` | Daily-Cap: Zeit >10h wird nicht weitergezählt (Firmenpolicy F2) |
| `normal_weekly_hours` | `45.0` | Normalarbeitszeit laut Tempus Passio §2 |
| `team_dev_weekly_hours` | `2.5` | Team-/Persönlichkeitsentwicklung (aggregierbar) |
| `default_break_threshold_5h` | `15` | Pause ab 5h in min (ArG 15) |
| `default_break_threshold_7h` | `30` | Pause ab 7h in min (ArG 15) |
| `default_break_threshold_9h` | `60` | Pause ab 9h in min (ArG 15) |
| `vacation_default_days` | `25` | Reglement Tempus Passio §2 |
| `vacation_carryover_deadline_rule` | `"14d_after_easter"` | Reglement |
| `doctor_cert_1dj` | `1` | Arztzeugnis 1. Dienstjahr ab Tag |
| `doctor_cert_2dj` | `2` | 2. Dienstjahr ab Tag |
| `doctor_cert_3dj_plus` | `3` | 3.+ Dienstjahr ab Tag |
| `salary_continuation_scale_default` | `"ZURICH"` | Reglement Generalis Provisio §6.2.1 |
| `salary_continuation_waiting_period_months` | `3` | Nach 3 Mt Dienstzeit (Reglement §6.2.1) |
| `monthly_payroll_cutoff_day` | `25` | Export-Termin für Treuhand Kunz |
| `extra_leave_birthday_days` | `1` | Geburtstag MA (Reglement §2) |
| `extra_leave_birthday_close_days` | `1` | Geburtstag nahestehende Person |
| `extra_leave_joker_days` | `1` | Jokertag Me Time |
| `extra_leave_zeg_days_per_halfyear` | `1` | ZEG-Zielerreichung ≥100% |
| `extra_leave_gl_max_days` | `3` | GL-Ermessen Maximum |
| `jahres_ueberzeit_cap` | `170` | ArG Art. 12 · Büropersonal bei 45h-Regime |
| `overtime_compensation_policy` | `"paid_with_salary"` | Arkadium-Vertragsklausel: keine Auszahlung, kein Zeitausgleich. Alternativen für andere Tenants: `time_off` / `pay_25pct` / `hybrid` |
| `auto_reply_enabled` | `false` | Arkadium-Policy: keine Outlook-Auto-Reply bei Abwesenheit |
| `ferien_stellvertreter_required_from_days` | `3` | Stellvertreter-Pflicht bei Ferien-Anträgen ab N Tagen |

---

## 8. §14 Activity-Types-Erweiterung (5 neue Rows)

Ergänzung zu §14 (`dim_activity_types`, bisher 64 Einträge in 11 Kategorien). 5 neue Aktivitäten in **Kategorie 12 "Zeit-Touchpoints"**:

| code | label_de | category | entity_relevance | sort |
|------|----------|----------|------------------|------|
| `time_correction_request` | Stempel-Antrag gestellt | Zeit-Touchpoints | mitarbeiter | 10 |
| `time_correction_approved` | Stempel-Antrag genehmigt | Zeit-Touchpoints | mitarbeiter | 20 |
| `time_correction_rejected` | Stempel-Antrag abgelehnt | Zeit-Touchpoints | mitarbeiter | 30 |
| `absence_submitted` | Abwesenheit eingereicht | Zeit-Touchpoints | mitarbeiter | 40 |
| `absence_approved` | Abwesenheit genehmigt | Zeit-Touchpoints | mitarbeiter | 50 |

**Pflicht:** Jede Stempel-Antrag-/Korrektur-Aktion in `fact_history` mit einem dieser Activity-Types. UI-Pattern Activity-Linking (Memory `project_activity_linking.md`): Click auf "✓ Korrektur 18.04." in History-Drawer öffnet `fact_time_correction`-Eintrag.

**Total `dim_activity_types`** nach Patch: 69 Einträge in 12 Kategorien.

---

## 9. §10a UI-Label-Vocabulary-Erweiterung (Mapping Enum → User-Label)

Ergänzung zu `wiki/meta/mockup-baseline.md` §16 — Pflicht für UI-konsistente Anzeige:

### 9.1 `time_entry_state`

| Enum | User-Label DE |
|------|---------------|
| `draft` | Entwurf |
| `submitted` | Eingereicht |
| `approved` | Genehmigt |
| `locked` | Gesperrt |
| `corrected` | Korrigiert |
| `rejected` | Abgelehnt |

### 9.2 `absence_state`

| Enum | User-Label DE |
|------|---------------|
| `draft` | Entwurf |
| `submitted` | Eingereicht |
| `approved` | Genehmigt |
| `active` | Aktiv |
| `completed` | Abgeschlossen |
| `rejected` | Abgelehnt |
| `cancelled` | Storniert |
| `corrected` | Korrigiert |

### 9.3 `correction_state`

| Enum | User-Label DE |
|------|---------------|
| `requested` | Beantragt |
| `tl_approved` | Head genehmigt |
| `gf_approved` | Admin genehmigt |
| `applied` | Angewendet |
| `rejected` | Abgelehnt |

### 9.4 `period_close_state`

| Enum | User-Label DE |
|------|---------------|
| `open` | Offen |
| `submitted` | Eingereicht |
| `tl_approved` | Head genehmigt |
| `gf_approved` | Admin genehmigt |
| `locked` | Gesperrt |
| `exported` | Exportiert |
| `reopened` | Wieder geöffnet |

### 9.5 `overtime_kind`

| Enum | User-Label DE |
|------|---------------|
| `regular` | Reguläre Zeit |
| `ueberstunden_or` | OR-Überstunden |
| `ueberzeit_arg` | ArG-Überzeit |
| `uncounted` | Nicht angerechnet |

### 9.6 `work_time_model`

| Enum | User-Label DE |
|------|---------------|
| `FLEX_CORE` | Gleitzeit mit Kernzeit |
| `FIXED` | Fix-Zeit |
| `PARTTIME` | Teilzeit |
| `SIMPLIFIED_73B` | Vereinfachte Erfassung |
| `EXEMPT_EXEC` | Höhere leitende Tätigkeit |

### 9.7 Rollen-Codes (Zeit-Modul-spezifisch)

| Enum | User-Label DE |
|------|---------------|
| `MA` | Mitarbeiter |
| `HEAD` | Head of |
| `BO` | Backoffice |
| `ADMIN` | Admin |

---

## 10. Anpassung bestehender Stammdaten

### 10.1 `dim_user.role_code` Erweiterung (parallel zu HR-Patch)

HR-Patch v1.6 → v1.7 hat bereits `role_code` Enum erweitert. Zeit-Modul-Migration:

```sql
-- Falls noch nicht durch HR-Patch erfolgt:
UPDATE ark.dim_user SET role_code = 'HEAD' WHERE role_code = 'TL';
UPDATE ark.dim_user SET role_code = 'ADMIN' WHERE role_code IN ('GF', 'FOUNDER');
```

(Idempotent · falls HR-Patch zuerst läuft, sind diese UPDATES No-Ops.)

### 10.2 `dim_user.direct_supervisor_id` (für RLS Head-of-Scope)

Bereits durch HR-Patch v1.6 → v1.7 hinzugefügt (Schema `fact_employment_contracts.supervisor_id`). Zeit-Modul nutzt diesen FK für RLS-Policy `zeit_entry_head_scope`. **Kein neuer Patch nötig.**

---

## 11. Migration-Reihenfolge (Stammdaten-Patch)

1. INSERT in `dim_absence_type` (30 Rows)
2. INSERT in `dim_time_category` (12 Rows)
3. INSERT in `dim_work_time_model` (5 Rows)
4. INSERT in `dim_salary_continuation_scale` (18 Rows)
5. INSERT in `fact_holiday_cantonal` (12 Rows · 2026)
6. INSERT in `dim_time_correction_reason` (8 Rows · falls eigene Tabelle, sonst Seed in `firm_settings.value_json`)
7. INSERT in `firm_settings` (22 Rows)
8. INSERT in `dim_activity_types` (5 Rows · Zeit-Touchpoints-Kategorie)
9. UPDATE `wiki/meta/mockup-baseline.md` §16 (Vocabulary-Mapping)
10. Verify: SELECT COUNT pro Tabelle vs. erwartete Werte (siehe §13)

---

## 12. Lint-Konformität

- **Stammdaten-Wording-Regel:** Alle `label_de`-Werte echte deutsche Begriffe (keine Anglizismen ausser etablierte Fachterme `OR-Überstunden`, `ArG-Überzeit`).
- **Umlaute-Regel:** Echte Umlaute in allen Labels (ä ö ü Ä Ö Ü ß).
- **DB-Tech-Details-Regel:** `code`-Spalten technisch (snake_case oder UPPER_SNAKE), `label_de` für UI immer sprechend.
- **Activity-Linking-Regel:** alle 5 neuen Activity-Types in §14 mit `entity_relevance = mitarbeiter` · in History-Drawer linkable.
- **Arkadium-Rolle-Regel:** Rollen-Codes konsistent (`HEAD` · nicht `TL`/`Vorgesetzter`/`Manager`).
- **Lateinische Eigennamen unverändert:** `Generalis Provisio`, `Tempus Passio` als Reglements-Referenzen (keine Umlaut-Substitute, sondern Latein-Corporate-Brand).

---

## 13. Validierung

```sql
-- Anzahl Seeds prüfen
SELECT COUNT(*) FROM ark.dim_absence_type;          -- Erwartet: 30
SELECT COUNT(*) FROM ark.dim_time_category;         -- 12
SELECT COUNT(*) FROM ark.dim_work_time_model;       -- 5
SELECT COUNT(*) FROM ark.dim_salary_continuation_scale; -- 18
SELECT COUNT(*) FROM ark.fact_holiday_cantonal WHERE EXTRACT(YEAR FROM date) = 2026; -- 12
SELECT COUNT(*) FROM ark.firm_settings;             -- 22 (mindestens · andere Tenant-Configs ergänzen)
SELECT COUNT(*) FROM ark.dim_activity_types
    WHERE category = 'Zeit-Touchpoints';            -- 5

-- Foreign-Key-Integrität
SELECT * FROM ark.fact_extra_leave_entitlement e
LEFT JOIN ark.dim_absence_type t ON e.absence_type_code = t.code
WHERE t.code IS NULL;                                -- Erwartet: 0

-- Category-Verteilung
SELECT category, COUNT(*) FROM ark.dim_absence_type GROUP BY category;
-- Erwartet: medical=4, family=5, civic=6, policy=10, extra=5

-- Vocabulary-Lookup-Test (Mockup-Baseline §16)
-- Manuelle Verifikation: alle Enum-Werte aus DB-Patch §2 haben User-Label
```

---

## 14. SYNC-IMPACT

| Grundlagen-Datei | Änderung |
|------------------|----------|
| `ARK_DATABASE_SCHEMA_v1_8.md` → v1.9 | bereits via DB-Patch v1.9 (P1) |
| `ARK_BACKEND_ARCHITECTURE_v2_6.md` | bereits committed (Backend-Patch existiert) |
| `ARK_FRONTEND_FREEZE_v1_15.md` → v1.16 | Stammdaten-Refs in UI-Vocabulary → **FE-Patch v1.16 (P3)** |
| `ARK_GESAMTSYSTEM_UEBERSICHT_v1_6.md` → v1.7 | Changelog + Cross-Module → **Gesamtsystem-Patch v1.7 (P4)** |
| `wiki/meta/mockup-baseline.md` §16 | Update: Zeit-Enum-Vocabulary-Mapping |
| `wiki/meta/spec-sync-regel.md` | Sync-Matrix-Eintrag Zeit 5/5 |

---

## 15. Acceptance Criteria

- [ ] 30 Absence-Types seeded · alle 5 Kategorien (medical/family/civic/policy/extra) vertreten
- [ ] 12 Time-Categories seeded · `zeg_relevant`-Flag korrekt für PROD_BILL/PROD_NONBILL/CLIENT_MEETING/CANDIDATE_MEETING/RESEARCH (5 ZEG-Kategorien)
- [ ] 5 Work-Time-Models seeded · Constraint-Test FLEX_CORE Default
- [ ] 18 Salary-Continuation-Skalen seeded · Zürcher Skala vollständig (9 Stufen)
- [ ] 12 Feiertage 2026 seeded · 10 statutory + 2 Halbtag-Sperrfristen
- [ ] 8 Korrektur-Gründe seeded · `other` mit Freitext-Pflicht
- [ ] 22 firm_settings-Keys seeded · `overtime_compensation_policy = 'paid_with_salary'`
- [ ] 5 neue Activity-Types in Kategorie "Zeit-Touchpoints" · alle mit `entity_relevance = mitarbeiter`
- [ ] UI-Label-Vocabulary §16 in `mockup-baseline.md` ergänzt (7 Mapping-Tabellen)
- [ ] Migration idempotent (re-runnable)
- [ ] Lint-Pass: keine Snake-Case-Codes in User-facing-Labels, alle Umlaute echt, keine `dim_*`/`fact_*`-Refs in UI-Texten

---

## 16. Memory-Verweise

- `project_activity_linking.md` — UI-Felder linken auf `fact_history`-Events; Zeit-Touchpoints-Activity-Types neu hier integriert
- `project_arkadium_role.md` — Arkadium-Rollen-Definition (Head/Admin statt TL/GF)
- `project_zeit_modul_architecture.md` — Scanner-First · Role-Rename · Lohn-abgegolten-Policy
- `feedback_zeit_stempel_modell.md` — Stempel-Antrag mit Grund-Dropdown (8 Codes)
- `reference_treuhand_kunz.md` — Treuhand-Export-Trigger via `monthly_payroll_cutoff_day = 25`

---

**Ende v1.8 · Zeit.** Apply-Reihenfolge: DB v1.9 (P1) → Stammdaten v1.8 (dieser Patch) → Backend v2.6 (bereits committed) → FE v1.16 (P3) → Gesamtsystem v1.7 (P4).
