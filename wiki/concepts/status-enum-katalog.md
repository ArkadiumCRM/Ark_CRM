---
title: "Status-Enum-Katalog"
type: concept
created: 2026-04-14
updated: 2026-04-14
tags: [concept, enums, status, conventions, glossary, reference]
---

# Status-Enum-Katalog

Zentrale Referenz aller Status-, Stage- und Typ-Enums im ARK CRM. Dokumentiert die **intentional gemischte Sprachkonvention** (Entscheidung 2026-04-14 #2) und listet alle Werte pro Entity.

## Sprachkonvention (intentional)

| Sprache | Anwendungsbereich | Beispiele |
|---------|-------------------|-----------|
| **Deutsch** | Business-Domain-Sprache (Arkadium-Kunden-facing) | Mandat-Status, Job-Status, Projekt-Status, Kandidat-Stages, Wechselmotivation |
| **Englisch** | Technische Workflows (Entwickler-facing) | Prozess-Status, Assessment-Status, Scraper-Status, Temperature, Longlist-Stages |

**Rationale:** Mandat/Job/Projekt werden in Kundendokumenten genannt → deutsch. Prozess/Assessment/Scraper sind interne Pipeline-Begriffe → englisch. Gesamtsystem v1.2 bestätigt die Mischung als gewollt.

---

## 1. Mandat

### Mandat-Typ (`fact_mandate.mandate_type`, deutsch)

| Wert | Beschreibung |
|------|-------------|
| `Target` | Exklusive Einzelsuche, Pauschale ÷ 3 Stages |
| `Taskforce` | Team-/Standortaufbau (ehemals "RPO"), Monatsfee + Success Fee |
| `Time` | Slot-basierte Rekrutierungskapazität, Wochenfee |

### Mandat-Status (`fact_mandate.status`, deutsch)

| Wert | Beschreibung |
|------|-------------|
| `Entwurf` | Offerte in Erstellung, nicht aktiv |
| `Aktiv` | Unterschriebene Mandatsofferte hochgeladen |
| `Abgeschlossen` | Regulär beendet (Placement erfolgt / Laufzeit durch) |
| `Abgebrochen` | Exit Option / Kündigung (80%-Formel) |
| `Abgelehnt` | Kunde hat Offerte nicht akzeptiert (terminal) |

### Kündigungs-Seite (`fact_mandate.terminated_by`, englisch)

| Wert | Beschreibung |
|------|-------------|
| `arkadium` | Arkadium hat Mandat gekündigt (keine Kandidaten findbar) |
| `client` | Auftraggeber hat Mandat gekündigt / anderweitig besetzt |

### Billing-Type (`fact_mandate_billing.billing_type`, englisch)

`stage_1` · `stage_2` · `stage_3` · `monthly_fee` · `success_fee` · `weekly_slot_fee` · `option` · `termination` · `refund`

---

## 2. Prozess

### Prozess-Status (`fact_process_core.status`, englisch)

| Wert | Beschreibung |
|------|-------------|
| `Open` | Aktiv in der Pipeline |
| `On Hold` | Pausiert mit Grund |
| `Stale` | Auto-Status bei Stage-Alter > Schwellwert |
| `Rejected` | Aktiv beendet (mit rejection_reason) |
| `Placed` | Erfolgreich platziert |
| `Closed` | Nach Garantiefrist regulär abgeschlossen |
| `Cancelled` | Rückzieher nach Placement (100% Rückvergütung) |
| `Dropped` | Prozess kam **nie zustande** (kein CV-Versand) — ≠ `Rejected` |

### Prozess-Stage (`fact_process_core.stage`, englisch Enum, UI-Label deutsch)

| Enum | UI-Label |
|------|---------|
| `expose` | Exposé |
| `cv_sent` | CV Sent |
| `ti` | TI (Telefon-/Teams-Interview) |
| `interview_1` | 1. Interview |
| `interview_2` | 2. Interview |
| `interview_3` | 3. Interview |
| `assessment` | Assessment |
| `angebot` | Angebot |
| `platzierung` | Platzierung |

### Rejected-By (`fact_process_core.rejected_by`, englisch)

| Wert | Beschreibung |
|------|-------------|
| `candidate` | Kandidat hat abgelehnt |
| `client` | Kunde hat abgelehnt |
| `internal` | Arkadium-intern entschieden (z.B. Mandat-Kündigung) |

### Fault-Side (Early Exit, `fact_process_core.fault_side`, englisch)

`candidate` · `client` · `unclear`

---

## 3. Job

### Job-Status (`fact_jobs.status`, deutsch)

| Wert | Beschreibung |
|------|-------------|
| `scraper_proposal` | Vom Scraper erkannte Vakanz, nicht bestätigt |
| `vakanz` | Bestätigt, aber nicht mandatiert |
| `aktiv` | Mandatiert ODER Erfolgsbasis in Bearbeitung |
| `besetzt` | Placement erfolgt |
| `geschlossen` | Nach Garantiefrist |
| `abgelehnt` | Scraper-Vorschlag verworfen / nach Vakanz aufgegeben |

### Confirmation-Status (`fact_jobs.confirmation_status`, englisch)

`scraper_proposal` · `confirmed` · `rejected`

### Contract-Type (`fact_jobs.contract_type`, englisch)

`permanent` · `fixed_term` · `part_time` · `seasonal` · `apprenticeship` · `contractor`

---

## 4. Assessment

### Assessment-Order-Status (`fact_assessment_order.status`, englisch)

| Wert | Beschreibung |
|------|-------------|
| `offered` | Offerte erstellt, nicht unterschrieben |
| `ordered` | Offerte unterschrieben, Credits aktiv |
| `partially_used` | Mindestens ein Credit verbraucht, nicht alle |
| `fully_used` | Alle Credits verbraucht |
| `invoiced` | Rechnung gestellt + bezahlt |
| `cancelled` | Auftrag storniert (selten, Kulanz-Entscheidung) |

### Assessment-Run-Status (`fact_assessment_run.status`, englisch)

| Wert | Beschreibung |
|------|-------------|
| `assigned` | Credit zugewiesen, kein Termin |
| `scheduled` | Termin gesetzt |
| `in_progress` | Durchführung läuft |
| `completed` | Report hochgeladen, Version erstellt |
| `cancelled_reassignable` | Abgebrochen, Credit wieder frei |

### Billing-Type (`fact_assessment_billing.billing_type`, englisch)

`full` · `deposit` · `final` · `expense`

### Package-Type (`fact_assessment_order.package_type` — deprecated v0.2, jetzt via `fact_assessment_order_credits`)

### Assessment-Typ (`dim_assessment_types.type_key`, englisch)

`mdi` · `relief` · `outmatch` · `disc` · `eq` · `scheelen_6hm` · `driving_forces` · `human_needs` · `ikigai` · `ai_analyse` · `teamrad_session`

---

## 5. Projekt

### Projekt-Status (`fact_projects.status`, deutsch)

| Wert | Beschreibung |
|------|-------------|
| `planung` | Planungsphase |
| `ausschreibung` | Ausschreibungsphase |
| `ausfuehrung` | In Ausführung |
| `abgenommen` | Bauabnahme erfolgt |
| `abgeschlossen` | Projekt komplett abgeschlossen |
| `gestoppt` | Vorzeitig gestoppt |

### Strategic-Rating (`fact_projects.strategic_rating`, englisch)

`top` · `standard` · `niche` · `low`

### Involvement-Level (`fact_projects.involvement_level`, englisch)

`active` · `observed` · `none`

### Media-Type (`fact_project_media.media_type`, englisch)

`photo` · `rendering` · `plan` · `construction_site` · `after_move_in`

### Project-Company-Role (`fact_project_company_participations.role`, englisch)

`bauherr` · `architekt` · `generalplaner` · `tu` · `gu` · `fachplaner` · `subunternehmer` · `bauleitung` · `handwerker` · `lieferant` · `andere`

### Responsibility-Level (`fact_project_candidate_participations.responsibility_level`, englisch)

`leading` · `contributing` · `advisory`

---

## 6. Kandidat

### Kandidat-Stage (`dim_candidates_profile.stage`, deutsch)

| Wert | Auto/Manuell |
|------|-------------|
| `Check` | Auto bei Erstellung |
| `Refresh` | Auto bei Ghosting/NIC/Dropped/nach 1 Jahr Datenschutz |
| `Premarket` | Auto bei Briefing-Save |
| `Active Sourcing` | Auto bei CV + Diplom + Zeugnis + Briefing |
| `Market Now` | Auto bei Prozess-Erstellung |
| `Inactive` | Auto bei Alter >60 oder Cold >6 Monate, oder manuell |
| `Blind` | Nur manuell |
| `Datenschutz` | Terminal-Status, Anonymisierung |

### Temperature (`candidate_temperature`, englisch)

`Hot` · `Warm` · `Cold` — vollautomatisch, kein manueller Override

### Wechselmotivation (`dim_candidates_profile.wechselmotivation`, deutsch, 8 Stufen)

1. Arbeitslos
2. Will / muss wechseln
3. Will / muss wahrscheinlich wechseln
4. Wechselt bei gutem Angebot
5. Spekulativ
6. Wechselt intern und wartet ab
7. Will absolut nicht wechseln
8. Will nicht mit uns zusammenarbeiten

---

## 7. Account

### Account-Status (`dim_accounts.account_status`, englisch)

| Wert | Beschreibung |
|------|-------------|
| `Active` | Normaler Kunde |
| `Prospect` | Akquise-Phase, noch kein Mandat |
| `Inactive` | Ehemaliger Kunde, schläft |
| `Blacklisted` | Negativ-Liste (rechtlich/geschäftlich) |

### Customer-Class (`dim_accounts.customer_class`, englisch)

`A` · `B` · `C`

### Account-Temperature (`account_temperature`, englisch)

`Hot` · `Warm` · `Cold` — vollautomatisch via 2-Layer-Modell (Hard-Rules + Points)

### Purchase-Potential (`dim_accounts.purchase_potential`, int)

`1` (★) · `2` (★★) · `3` (★★★) — entsprechend 0-1 / 2-3 / 3+ Positionen/Jahr

---

## 8. Firmengruppe

### Group-Customer-Class (`dim_firmengruppen.customer_class`, englisch)

`A` · `B` · `C` · `NULL` — höchste Klasse der Mitglieder oder manuell

---

## 9. Schutzfrist

### Protection-Window-Status (`fact_protection_window.status`, englisch)

| Wert | Beschreibung |
|------|-------------|
| `active` | Fenster läuft |
| `expired` | Abgelaufen |
| `honored` | Placement erfolgt, Schutz erfüllt |
| `claim_pending` | Verletzung detektiert, Claim vorbereitet |
| `paid` | Claim bezahlt |

### Protection-Window-Scope (`fact_protection_window.scope`, englisch)

`account` · `group`

### Presentation-Type (`fact_candidate_presentation.presentation_type`, englisch)

`email_dossier` · `verbal_meeting` · `upload_portal` (dim_presentation_types §10c — 14.04.2026: `verbal_phone`/`verbal_teams` konsolidiert, reine Telefonerwähnung löst keine Schutzfrist aus)

---

## 10. Scraper

### Finding-Type (`fact_scraper_findings.finding_type`, englisch)

`new_contact` · `contact_changed` · `contact_disappeared` · `new_vacancy` · `vacancy_changed` · `vacancy_disappeared` · `person_job_change` · `group_suggestion` · `stammdaten_drift` · `anomaly_detected`

### Finding-Status (`fact_scraper_findings.status`, englisch)

`pending_review` · `accepted` · `rejected` · `auto_accepted`

### Review-Priority (`fact_scraper_findings.review_priority`, englisch) — NEU v0.3

`standard` · `needs_am_review`

### Run-Status (`fact_scraper_runs.status`, englisch)

`running` · `success` · `partial` · `error`

### Trigger-Type (`fact_scraper_runs.trigger`, englisch)

`scheduled` · `manual` · `api` · `bulk`

### Alert-Severity (`fact_scraper_alerts.severity`, englisch)

`info` · `warning` · `error` · `critical`

### Implementation-Typ (`dim_scraper_types.implementation`, englisch)

`specialized` · `generic` · `ai_assisted`

---

## 11. Longlist (innerhalb Mandat Tab 2)

### Longlist-Stage (englisch Enum)

| Enum | UI-Label | Locked? |
|------|---------|---------|
| `research` | Research | ❌ |
| `nicht_erreichbar` | Nicht erreicht | ❌ |
| `nicht_interessiert` | NIC | ❌ |
| `cv_expected` | CV Expected | ❌ |
| `cv_in` | CV IN | 🔒 |
| `briefing` | Briefing | 🔒 |
| `go_muendlich` | GO mündlich | 🔒 |
| `go_schriftlich` | GO schriftlich | 🔒 |
| `dropped` | Dropped | ❌ |
| `ghosted` | Ghosted | ❌ |

Ab Stage 5 (`cv_in`) gesperrt — nur Automationen ändern.

---

## 12. Jobbasket (innerhalb Kandidat Tab 5)

### Jobbasket-Stage (englisch Enum)

`prelead` → `oral_go` → `written_go` → `assigned` → `to_send` → `cv_sent` / `expose_sent`

### Jobbasket-Rejection-Type (`dim_jobbasket_rejection_types`, englisch)

`candidate` · `cm` · `am`

---

## 13. Referral

### Referral-Type (`fact_referral.referral_type`, englisch)

`candidate` · `client`

### Referral-Status (`fact_referral.status`, englisch)

`pending` · `eligible` · `paid` · `cancelled`

---

## 14. Mandat-Optionen

### Option-Type (`fact_mandate_option.option_type`, englisch)

`VI_more_idents` · `VII_more_dossiers` · `VIII_marketing` · `IX_assessment` · `X_garantie_extension`

### Option-Status (`fact_mandate_option.status`, englisch)

`offered` · `accepted` · `in_progress` · `delivered` · `invoiced`

---

## 15. Rechnung (Billing)

### Invoice-Status (allgemein, englisch)

`pending` · `invoiced` · `paid` · `overdue`

---

## 16. Gemeinsame Konventionen

### Billing-Status (global)

`pending` → `invoiced` → `paid` ODER `overdue`

### Confidence-Klassen (nicht DB-Enum, nur UI)

- **High:** ≥ 85%
- **Medium:** 60–84%
- **Low:** < 60% — triggert `review_priority = 'needs_am_review'`

### Activity-Type-Klassifizierung (`fact_history.categorization_status`, englisch)

`confirmed` · `ai_suggested` · `pending` · `manual`

---

## 17. Felder-Konventionen

### Sprach-Standard für Feldnamen (englisch)

- `candidate_id`, `account_id`, `mandate_id`, `process_id`, `job_id`, `group_id`
- `created_at`, `updated_at`, `deleted_at`
- `valid_from`, `valid_to`, `is_current`
- `created_by`, `updated_by` (user_id FKs)

### Deutsche Legacy-Felder (werden in Migration auf Englisch umgestellt)

- `kandidat_id` → `candidate_id` (v1.3)
- `firmen_id` → `account_id` (schon in v1.2)

---

## Related

- [[audit-entscheidungen-2026-04-14]] — Entscheidungsgrundlage für Sprach-Mix (#2)
- [[namenskonventionen]] — Terminologie-Konventionen
- [[stammdaten]] — Stammdaten-Überblick
- `ARK_STAMMDATEN_EXPORT_v1_3.md` — Tabellen-Details aller dim_*-Katalog-Tabellen
- `ARK_DATABASE_SCHEMA_v1_2.md` / v1.3 (in Arbeit) — DB-Tabellen mit Enum-Constraints
