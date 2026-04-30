---
title: "ARK Stammdaten-Patch v1.6 → v1.7 · HR-Modul"
type: spec
module: hr
version: 1.7
created: 2026-04-30
updated: 2026-04-30
status: draft · HR-Sync-Patch
sources: [
  "Grundlagen MD/ARK_STAMMDATEN_EXPORT_v1_6.md",
  "specs/ARK_HR_TOOL_SCHEMA_v0_2.md",
  "specs/ARK_HR_TOOL_PLAN_v0_2.md",
  "specs/ARK_DATABASE_SCHEMA_PATCH_v1_7_to_v1_8_hr.md"
]
tags: [stammdaten, patch, hr, employment, onboarding, disciplinary, activity-types, seeds, enums]
---

# ARK Stammdaten-Patch v1.6 → v1.7 · HR-Modul

**Stand:** 2026-04-30
**Status:** Draft · HR-Sync-Patch
**Quellen:**
- `Grundlagen MD/ARK_STAMMDATEN_EXPORT_v1_6.md` (Vorgänger)
- `specs/ARK_HR_TOOL_SCHEMA_v0_2.md` §4 (Dimension-Tabellen + Seeds)
- `specs/ARK_HR_TOOL_PLAN_v0_2.md` §3 (CH-Arbeitsrecht-Bezüge)
- `specs/ARK_DATABASE_SCHEMA_PATCH_v1_7_to_v1_8_hr.md` (DB-Tabellen-Definitionen)

**Vorrang:** Stammdaten > Schema > Patch > Mockups

**Voraussetzungen:**
- Stammdaten-Patch v1.6 (Performance-Modul-Stammdaten, §80–§85) deployed
- DB-Patch v1.8 (HR-Dim-Tabellen existieren für FK-Referenzen) deployed

---

## 0. ZIELBILD (was ändert dieser Patch)

Dieser Patch ergänzt `ARK_STAMMDATEN_EXPORT_v1_6.md` um:

1. **Neue ENUM-Sektion §G** — HR-spezifische Enum-Types (10 neue Enums)
2. **Neue Stammdaten-Sektionen §86–§90** — 5 neue `dim_hr_*`-Kataloge mit Seed-Daten
3. **§14-Erweiterung** — 7 neue Activity-Types in Kategorie `hr` (§14 `dim_activity_types`)
4. **§8-Erweiterung** — UI-Label-Vocabulary-Mapping für HR-Felder

**Seed-Gesamtübersicht:**

| Sektion | Katalog | # Seeds |
|---------|---------|---------|
| §86 | dim_hr_document_type | 13 |
| §87 | dim_disciplinary_offense_type | 13 |
| §88 | dim_onboarding_task_template_type | 18 |
| §89 | dim_hr_employment_type (Lookup) | 4 |
| §90 | dim_hr_termination_reason (Lookup) | 7 |
| §14 Erw. | dim_activity_types (HR-Kategorie) | 7 |
| **Total** | | **62 neue Einträge** |

---

## 1. ENUM-Sektion §G — HR-Enums

Ergänzung zu `ARK_STAMMDATEN_EXPORT_v1_6.md` §F (bestehende Enums).

### §G.1 `contract_state`

| Wert | Label DE | Beschreibung |
|------|----------|-------------|
| `draft` | Entwurf | Vertrag erfasst, noch nicht unterschrieben |
| `pending_sig` | Unterschrift ausstehend | Wartet auf MA- oder Admin-Signatur |
| `active` | Aktiv | Vertrag gültig und in Kraft |
| `terminated` | Gekündigt | Kündigung erfasst (Frist läuft oder abgelaufen) |
| `expired` | Abgelaufen | Befristeter Vertrag ausgelaufen |
| `voided` | Ungültig | Vertrag widerrufen / Fehler |

### §G.2 `employment_type`

| Wert | Label DE | Beschreibung |
|------|----------|-------------|
| `permanent` | Unbefristet | Unbefristetes Arbeitsverhältnis |
| `fixed_term` | Befristet | Befristetes Arbeitsverhältnis mit Enddatum |
| `intern` | Praktikum | Praktikumsvertrag |
| `freelance` | Freie Mitarbeit | Ohne AHV-Pflicht über Arkadium |

### §G.3 `termination_reason`

| Wert | Label DE | OR-Referenz |
|------|----------|-------------|
| `resignation` | Kündigung durch Mitarbeiter | OR 335 |
| `dismissal` | Kündigung durch AG (ordentlich) | OR 335 |
| `dismissal_immediate` | Fristlose Entlassung | OR 337 |
| `mutual_agreement` | Gegenseitiges Einvernehmen | OR 115 |
| `end_fixed_term` | Befristung ausgelaufen | OR 334 |
| `retirement` | Pensionierung | — |
| `death` | Todesfall | OR 338 |

### §G.4 `hr_doc_state`

| Wert | Label DE | Beschreibung |
|------|----------|-------------|
| `pending` | Unterschrift ausstehend | Dokument generiert, Signatur fehlt |
| `signed` | Unterzeichnet | Beidseitig unterschrieben |
| `superseded` | Ersetzt | Von neuerer Version abgelöst |
| `revoked` | Widerrufen | Dokument ungültig erklärt |

### §G.5 `disciplinary_level`

| Wert | Label DE | Eskalationsstufe |
|------|----------|-----------------|
| `verbal_warning` | Mündliche Ermahnung | Stufe 1 |
| `written_warning` | Schriftliche Verwarnung | Stufe 2 |
| `formal_warning` | Förmliche Abmahnung | Stufe 3 |
| `final_warning` | Letzte Verwarnung | Stufe 4 |
| `suspension` | Freistellung | Stufe 5 |
| `dismissal_immediate` | Fristlose Entlassung | Stufe 6 (OR 337) |

### §G.6 `disciplinary_state`

| Wert | Label DE | Beschreibung |
|------|----------|-------------|
| `draft` | Entwurf | Erstellt, noch nicht zugestellt — nur Admin sieht |
| `issued` | Zugestellt | Formal kommuniziert |
| `acknowledged` | Zur Kenntnis genommen | MA hat unterschrieben |
| `disputed` | Bestritten | MA hat Einsprache erhoben |
| `resolved` | Erledigt | Ohne weitere Folgen abgeschlossen |
| `archived` | Archiviert | Nach Retention-Frist abgelegt |

### §G.7 `probation_milestone_type`

| Wert | Label DE | Zeitpunkt |
|------|----------|-----------|
| `month_1_review` | 1-Monats-Gespräch | ~30 Tage nach Eintritt |
| `month_2_review` | 2-Monats-Gespräch (optional) | ~60 Tage nach Eintritt |
| `probation_end` | Probezeit-Abschluss | ~90 Tage (Standard 3 Mt) |
| `probation_extended` | Probezeit verlängert | OR 335b Abs. 2: bis max 6 Mt total |
| `probation_failed` | Probezeit nicht bestanden | Kündigung in Probezeit |

### §G.8 `onboarding_state`

| Wert | Label DE | Beschreibung |
|------|----------|-------------|
| `draft` | In Vorbereitung | Template wird konfiguriert |
| `active` | Laufend | MA hat begonnen |
| `completed` | Abgeschlossen | Alle Pflicht-Tasks erledigt |
| `overdue` | Überfällig | Mindestens 1 Pflicht-Task überfällig |
| `cancelled` | Abgebrochen | z.B. Kündigung in Probezeit |

### §G.9 `onboarding_task_state`

| Wert | Label DE |
|------|----------|
| `pending` | Offen |
| `in_progress` | In Bearbeitung |
| `done` | Erledigt |
| `skipped` | Übersprungen (nur optionale Tasks) |
| `overdue` | Überfällig |

### §G.10 `onboarding_assignee_role`

| Wert | Label DE | Beschreibung |
|------|----------|-------------|
| `new_hire` | Neuer Mitarbeiter | MA erledigt selbst |
| `head_of` | Head of | Direktvorgesetzte/r |
| `admin` | Admin / HR | HR-Manager oder GF |
| `it` | IT | IT-Verantwortliche/r (Geräte, Zugänge) |
| `buddy` | Buddy | Paten-Mitarbeiter |

---

## 2. Neue Stammdaten-Sektion §86 — `dim_hr_document_type`

**Zweck:** Katalog aller HR-Dokument-Typen mit Signatur- und Retention-Anforderungen.

> **Umlaute-Regel und Eigennamen-Ausnahme:** Reglements-Eigennamen (Praemium Victoria, Generalis Provisio, Progressus, Tempus Passio 365, Locus Extra) sind lateinische Kunstnamen — Schreibweise beibehalten, keine Eindeutschung.

| code | label_de | requires_sig | requires_counter | category | retention_y | sort |
|------|----------|:---:|:---:|---------|:-----------:|:----:|
| `EMPLOYMENT_CONTRACT` | Arbeitsvertrag | ✓ | ✓ | vertrag | 10 | 10 |
| `GENERALIS_PROVISIO` | Generalis Provisio (Allg. Anstellungsbedingungen) | ✓ | ✓ | reglement | 10 | 20 |
| `PROGRESSUS` | Progressus (Stellenbeschreibung) | ✓ | ✓ | vertrag | 10 | 30 |
| `PRAEMIUM_VICTORIA` | Praemium Victoria (Provisionsvertrag) | ✓ | ✓ | vertrag | 10 | 40 |
| `TEMPUS_PASSIO_365` | Tempus Passio 365 (Arbeitszeitenreglement) | ✓ | ✓ | reglement | 10 | 50 |
| `LOCUS_EXTRA` | Locus Extra (Mobiles Arbeiten) | ✓ | ✓ | reglement | 10 | 60 |
| `DATENSCHUTZ_ERKLAERUNG` | Datenschutzerklärung (DSG-Einwilligung) | ✓ | ✓ | bescheinigung | 10 | 70 |
| `REFERENCE_LETTER` | Arbeitszeugnis | ✓ | ✓ | bescheinigung | 10 | 80 |
| `INTERIM_REFERENCE` | Zwischenzeugnis | ✓ | ✓ | bescheinigung | 10 | 90 |
| `SALARY_STATEMENT` | Lohnausweis | ✗ | ✗ | bescheinigung | 10 | 100 |
| `AHV_CONFIRMATION` | AHV-Bestätigung Anmeldung | ✗ | ✗ | bescheinigung | 5 | 110 |
| `PROBATION_EXTENSION` | Probezeit-Verlängerung (OR 335b Abs. 2) | ✓ | ✓ | vertrag | 10 | 120 |
| `OTHER` | Sonstiges Dokument | ✗ | ✗ | other | 10 | 999 |

**Kategorien (`category`-Werte):** `vertrag` · `reglement` · `bescheinigung` · `other`

---

## 3. Neue Stammdaten-Sektion §87 — `dim_disciplinary_offense_type`

**Zweck:** Delikt-Katalog für Verwarnungsgründe mit typischem Eskalations-Level und Legal-Referenz.

| code | label_de | category | typical_level | legal_ref |
|------|----------|----------|---------------|-----------|
| `REPEATED_LATENESS` | Wiederholte Unpünktlichkeit | attendance | written_warning | OR 321 |
| `UNEXCUSED_ABSENCE` | Unentschuldigtes Fernbleiben | attendance | written_warning | OR 321 |
| `INSUBORDINATION` | Nichtbefolgung von Weisungen | conduct | written_warning | OR 321a |
| `MISCONDUCT_COLLEAGUE` | Unangemessenes Verhalten gegenüber Kollegen | conduct | verbal_warning | OR 328 |
| `MISCONDUCT_CLIENT` | Unangemessenes Verhalten gegenüber Kunden/Kandidaten | conduct | written_warning | OR 328 |
| `PERFORMANCE_DEFICIENCY` | Wiederholte Leistungsmängel | performance | verbal_warning | OR 321a |
| `TARGET_MISS_REPEATED` | Wiederholtes Verfehlen vereinbarter Ziele | performance | written_warning | Progressus |
| `DATA_BREACH_INTERNAL` | Verletzung Datenschutz intern | compliance | formal_warning | revDSG + OR 321a |
| `CONFIDENTIALITY_BREACH` | Bruch der Schweigepflicht (Kunden/Kandidaten) | compliance | formal_warning | OR 321a + Generalis Provisio |
| `EXPENSE_FRAUD` | Manipulation Spesenabrechnung | integrity | final_warning | OR 321a |
| `COMPETITION_VIOLATION` | Verletzung Konkurrenzverbot | integrity | dismissal_immediate | OR 340 |
| `HARASSMENT` | Belästigung / Diskriminierung | conduct | dismissal_immediate | OR 328 + GlG |
| `OTHER` | Sonstiger Grund | conduct | verbal_warning | — |

**Kategorien (`category`-Werte):** `attendance` · `conduct` · `performance` · `compliance` · `integrity`

---

## 4. Neue Stammdaten-Sektion §88 — `dim_onboarding_task_template_type`

**Zweck:** Katalog wiederverwendbarer Onboarding-Aufgaben mit Verantwortlichkeit und Standard-Fälligkeit.

| code | label_de | assignee | offset_d | mandatory | category |
|------|----------|----------|:--------:|:---------:|---------|
| `WELCOME_MEETING` | Willkommensgespräch mit Head of | head_of | 1 | ✓ | social |
| `IT_EQUIPMENT_SETUP` | IT-Einrichtung (Laptop, Handy, Zugänge) | it | 1 | ✓ | it |
| `EMAIL_SETUP` | E-Mail + Kalender-Einrichtung (Outlook) | it | 1 | ✓ | it |
| `SIGN_GENERALIS_PROVISIO` | Generalis Provisio unterschreiben | new_hire | 1 | ✓ | compliance |
| `SIGN_PROGRESSUS` | Progressus (Stellenbeschreibung) unterschreiben | new_hire | 3 | ✓ | compliance |
| `SIGN_TEMPUS_PASSIO` | Tempus Passio 365 unterschreiben | new_hire | 3 | ✓ | compliance |
| `SIGN_LOCUS_EXTRA` | Locus Extra unterschreiben | new_hire | 3 | ✓ | compliance |
| `SIGN_PRAEMIUM_VICTORIA` | Praemium Victoria unterschreiben (Provisions-MA) | new_hire | 5 | ✗ | compliance |
| `SIGN_DATENSCHUTZ` | Datenschutzerklärung unterzeichnen | new_hire | 1 | ✓ | compliance |
| `AHV_REGISTRATION` | AHV-Anmeldung Treuhand | admin | 3 | ✓ | admin |
| `BADGE_KEY` | Büroschlüssel / Badge aushändigen | admin | 1 | ✓ | admin |
| `BANK_DETAILS` | Bankverbindung erfassen | new_hire | 3 | ✓ | admin |
| `CRM_INTRO` | CRM-Einführung (ARK CRM Demo) | head_of | 5 | ✓ | role |
| `TOOL_INTRO_ELEARN` | E-Learning Plattform Einführung | head_of | 7 | ✓ | role |
| `BUDDY_INTRO` | Vorstellung Buddy / Paten | buddy | 1 | ✗ | social |
| `TEAM_LUNCH` | Team-Mittagessen (erste Woche) | head_of | 5 | ✗ | social |
| `MONTH_1_REVIEW` | 1-Monats-Feedback-Gespräch | head_of | 30 | ✓ | role |
| `PROBATION_REVIEW` | Probezeit-Abschlussgespräch | head_of | 90 | ✓ | role |

**Kategorien (`category`-Werte):** `admin` · `it` · `compliance` · `social` · `role`

**Hinweis:** `SIGN_PRAEMIUM_VICTORIA` (not mandatory) wird bei Onboarding-Instanz-Erstellung nur für MA mit `has_provisions=true` als aktiver Task generiert.

---

## 5. Neue Stammdaten-Sektion §89 — `dim_hr_employment_type` (Lookup-Referenz)

**Zweck:** Textuelle Beschreibungen des `employment_type`-ENUMs für UI-Labels, Tooltips und Reports.

> Diese Sektion ist eine Lookup-Referenz — die authoritative Enum-Definition liegt in §G.2 und der DB-DDL (DB-Patch v1.8). Keine eigene DB-Tabelle nötig.

| code | label_de | ahv_pflicht | sozialleistungen | notice_months | beschreibung |
|------|----------|:-----------:|:----------------:|:-------------:|-------------|
| `permanent` | Unbefristetes Arbeitsverhältnis | ✓ | Voll | 1–3 (Staffel) | Standard-Anstellung; OR 335c (Kündigungsfristen) gilt |
| `fixed_term` | Befristetes Arbeitsverhältnis | ✓ | Voll | — (Automatisch) | Max-Laufzeit 1 J ohne Verlängerungsklausel |
| `intern` | Praktikum | ✓ (ab 1 J) | Teilweise | — | Praktikumsvertrag; OR 319 ff. gilt |
| `freelance` | Freie Mitarbeit | ✗ (eigen) | ✗ | — | OR 363 ff. (Werkvertrag); kein AV i.S. OR 319 |

---

## 6. Neue Stammdaten-Sektion §90 — `dim_hr_termination_reason` (Lookup-Referenz)

**Zweck:** Lookup-Katalog für `fact_employment_contracts.termination_reason` mit OR-Referenz und UI-Labels.

> Lookup-Referenz — authoritative Enum-Definition in §G.3 / DB-Patch v1.8.

| code | label_de | initiiert_von | or_referenz | notice_required | sofortiger_austritt |
|------|----------|--------------|-------------|:---------------:|:-------------------:|
| `resignation` | Kündigung durch Mitarbeiter | MA | OR 335 | ✓ | ✗ |
| `dismissal` | Kündigung durch Arkadium (ordentlich) | AG | OR 335 | ✓ | ✗ |
| `dismissal_immediate` | Fristlose Entlassung | AG | OR 337 | ✗ | ✓ |
| `mutual_agreement` | Auflösung im gegenseitigen Einvernehmen | Beide | OR 115 | ✗ | ✗ |
| `end_fixed_term` | Befristung ausgelaufen | — | OR 334 | ✗ | ✗ |
| `retirement` | Pensionierung | MA | — | ✓ | ✗ |
| `death` | Todesfall | — | OR 338 | ✗ | ✓ |

**UI-Hinweis (Keine-DB-Techdetails-im-UI-Regel):** In Dropdowns wird `label_de` angezeigt. `code`-Werte erscheinen nur in Spec-Dokumenten, Admin-Debug-Ansichten und Code-Kommentaren.

---

## 7. Erweiterung §14 `dim_activity_types` — neue Kategorie `hr`

**Zweck:** 7 neue Activity-Types für HR-Touchpoints, die in `fact_history` geloggt werden.

Diese ergänzen die bestehenden 64 Einträge in §14. Neue Kategorie-Nummer: **12 — hr (Interne HR-Aktivitäten)**.

| code | label_de | entity_relevance | beschreibung |
|------|----------|-----------------|-------------|
| `hr.onboarding.step` | Onboarding-Schritt abgeschlossen | Mitarbeiter | Einzelne Task-Completion in fact_history |
| `hr.probation.review` | Probezeit-Gespräch | Mitarbeiter | Probezeit-Milestone (Monat 1/2 oder Abschluss) |
| `hr.disciplinary.measure` | Disziplinarische Massnahme | Mitarbeiter | Verwarnung erfasst oder Status-Änderung |
| `hr.contract.change` | Vertragsanpassung | Mitarbeiter | Lohnerhöhung, Pensum-Änderung, Probezeit-Verlängerung |
| `hr.document.signed` | Dokument unterzeichnet | Mitarbeiter | Vollständige Signatur eines HR-Dokuments (MA + Admin) |
| `hr.offboarding.step` | Offboarding-Schritt | Mitarbeiter | Austritts-Checkliste (Phase-2-Scaffold) |
| `hr.training.completed` | Weiterbildung abgeschlossen | Mitarbeiter | Schulung / Zertifizierung (Academy-Bridge) |

**Konventionen HR-Activity-Types:**
- Alle haben `entity_relevance = 'Mitarbeiter'` (intern, nicht für Kandidaten- oder Account-Timeline)
- In MA-Self-Service-Ansicht (`hr-mitarbeiter-self.html`) zeigt History-Sektion nur `hr.*`-Events des eigenen `user_id`
- RLS auf `fact_history`: MA-Self sieht nur eigene `hr.*`-Events; HoD sieht Team; Admin sieht alles
- `hr.disciplinary.measure` wird in MA-Self-Ansicht erst ab `disciplinary_state = 'issued'` angezeigt

**Zählerstand §14 nach Patch:** 71 Activity-Types (64 bestehend + 7 HR-neu)

---

## 8. UI-Label-Vocabulary-Mapping (HR)

Ergänzung zu `wiki/meta/mockup-baseline.md` §16 — Kanonische Mappings für HR-Enum-Werte → deutsches UI-Label.

> Keine DB-Namen in User-facing-Texten (Keine-DB-Techdetails-im-UI-Regel).

| DB-Feld / ENUM-Wert | UI-Label (Mockup / Dropdown / Badge) |
|---------------------|--------------------------------------|
| `contract_state = 'active'` | Aktiv |
| `contract_state = 'terminated'` | Gekündigt |
| `contract_state = 'pending_sig'` | Unterschrift ausstehend |
| `contract_state = 'draft'` | Entwurf |
| `contract_state = 'expired'` | Abgelaufen |
| `employment_type = 'permanent'` | Unbefristet |
| `employment_type = 'fixed_term'` | Befristet |
| `employment_type = 'intern'` | Praktikum |
| `employment_type = 'freelance'` | Freie Mitarbeit |
| `disciplinary_level = 'verbal_warning'` | Mündliche Ermahnung |
| `disciplinary_level = 'written_warning'` | Schriftliche Verwarnung |
| `disciplinary_level = 'formal_warning'` | Förmliche Abmahnung |
| `disciplinary_level = 'final_warning'` | Letzte Verwarnung |
| `disciplinary_level = 'suspension'` | Freistellung |
| `disciplinary_level = 'dismissal_immediate'` | Fristlose Entlassung |
| `disciplinary_state = 'draft'` | Entwurf |
| `disciplinary_state = 'issued'` | Zugestellt |
| `disciplinary_state = 'acknowledged'` | Zur Kenntnis genommen |
| `disciplinary_state = 'disputed'` | Bestritten |
| `disciplinary_state = 'resolved'` | Erledigt |
| `onboarding_state = 'active'` | Laufend |
| `onboarding_state = 'overdue'` | Überfällig |
| `onboarding_state = 'completed'` | Abgeschlossen |
| `onboarding_state = 'cancelled'` | Abgebrochen |
| `in_probation = true` | In Probezeit |
| `has_provisions = true` | Provisions-berechtigt |
| `hr_doc_state = 'pending'` | Unterschrift ausstehend |
| `hr_doc_state = 'signed'` | Unterzeichnet |
| `hr_doc_state = 'superseded'` | Ersetzt |

---

## 9. Migration-Reihenfolge

1. Neue ENUMs §G.1–G.10 dokumentieren (ENUMs bereits in DB-Patch v1.8 als PostgreSQL-Types erstellt)
2. INSERT Seeds `dim_hr_document_type` (13 Einträge, §86 — Tabelle aus DB-Patch v1.8 §2.1)
3. INSERT Seeds `dim_disciplinary_offense_type` (13 Einträge, §87 — Tabelle aus DB-Patch v1.8 §2.2)
4. INSERT Seeds `dim_onboarding_task_template_type` (18 Einträge, §88 — Tabelle aus DB-Patch v1.8 §2.3)
5. §89 und §90 als Lookup-Referenz dokumentieren (keine eigene DB-Tabelle)
6. INSERT 7 neue `dim_activity_types`-Einträge (Kategorie `hr`, §7)
7. `wiki/meta/mockup-baseline.md` §16 um HR-Mapping (§8) ergänzen

---

## 10. SYNC-IMPACT

| Grundlagen-Datei | Änderung |
|------------------|----------|
| `ARK_DATABASE_SCHEMA_v1_7.md` | HR-Tabellen → DB-Patch v1.8 (bereits geschrieben) |
| `ARK_BACKEND_ARCHITECTURE_v2_9.md` | HR-Endpoints / Worker → Backend-Patch v2.10 (bereits geschrieben) |
| `ARK_FRONTEND_FREEZE_v1_14.md` | HR-Routes / Sidebar / Drawer → FE-Patch v1.15 (bereits geschrieben) |
| `ARK_GESAMTSYSTEM_UEBERSICHT_v1_5.md` | Changelog-Eintrag „Stammdaten v1.7 · HR" (Folge-Patch Gesamtsystem separat) |
| `wiki/meta/mockup-baseline.md` | §16-Erweiterung HR-UI-Labels (§8 dieses Patches) |

---

**Ende v1.7.** Apply-Reihenfolge: DB-Patch v1.8 → Backend-Patch v2.10 → Stammdaten-Patch v1.7 → FE-Patch v1.15.
