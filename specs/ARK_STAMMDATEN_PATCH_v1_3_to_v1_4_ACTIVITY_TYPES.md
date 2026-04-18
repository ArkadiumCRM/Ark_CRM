# ARK CRM — Stammdaten-Patch-Vorschlag v1.3 → v1.4

**Scope:** §14 `dim_activity_types` erweitern für System-Activity-Types
**Zielversion:** `ARK_STAMMDATEN_EXPORT_v1_4.md`
**Basis-Spec:** `specs/ARK_SYSTEM_ACTIVITY_TYPES_SCHEMA_v1.md`
**Stand:** 17.04.2026
**Status:** Review ausstehend — nicht in Grundlagen gemergt

> **Anwendung:** Dieser Patch wird nach Review in `Grundlagen MD/ARK_STAMMDATEN_EXPORT_v1_3.md` eingearbeitet → neue Datei `ARK_STAMMDATEN_EXPORT_v1_4.md`. Dabei:
> - §14 Intro-Block um neue Kategorien-Gruppe (12–18) ergänzen
> - 7 neue Unter-Sektionen einfügen
> - 4 Rows in bestehenden Sektionen ergänzen
> - §14 Statistik-Block aktualisieren
> - Neue §14c „Event-Types-Katalog" und §14d „System-Log-Events" anlegen (nur Verweis auf SQL-Schema-Doku)

---

## Changelog v1.3 → v1.4

| # | Änderung | Sektion |
|---|----------|---------|
| 1 | Activity-Kategorien 11 → 18 (7 neue) | §14 Intro |
| 2 | +37 neue Activity-Type-Rows (#70–#106) | §14 neue + ergänzte Sektionen |
| 3 | `dim_activity_types` erhält 3 neue Spalten: `actor_type`, `source_system`, `is_notifiable` | §14 Intro + alle Tabellen |
| 4 | Neue §14c `dim_event_types` Event-Katalog (~50 Rows) | §14c (neu) |
| 5 | Neue §14d `fact_system_log` Ops-only Events (15 Rows) | §14d (neu) |
| 6 | §14 Statistik aktualisiert: 69 → 106 Rows, 11 → 18 Kategorien, is_auto_logged 6 → 38 | §14 Statistik |

---

## §14 Intro — zu ergänzen nach bestehendem Scope-Block

**Neue Einleitung hinter Zeile 1540 (nach Kanal-Mapping):**

```
actor_type: wer hat Row erzeugt — user | system | automation | integration
  user        = Consultant manuelle Erfassung (Default)
  system      = Scheduled-Batch / Regel (z.B. Inactive-Detection)
  automation  = Eventgetriebene Saga / Worker (z.B. Placement-Saga)
  integration = Externes System (3CX, Outlook, LinkedIn-Scraper)

source_system: technische Herkunft bei actor_type <> 'user'
  threecx | outlook | gmail | scraper | llm | saga-engine |
  nightly-batch | event-worker | manual-upload | calendar-integration

is_notifiable: steuert Notification-Fanout bei Auto-Events
  true  = generiert In-App-Notification beim Process-Owner
  false = stumm (Ops-Event, nur Timeline-Sichtbarkeit)
```

**Neue Kategorien-Liste (ersetzt „11 Kategorien" im Header):**

```
18 Kategorien:
 1 Kontaktberührung       2 Erreicht             3 Emailverkehr
 4 Messaging              5 Interviewprozess     6 Placementprozess
 7 Refresh Kandidatenpflege  8 Mandatsakquise   9 Erfolgsbasis
10 Assessment            11 System / Meta       12 Kalender & Planung (NEU)
13 Dokumenten-Pipeline (NEU)  14 Garantie & Schutzfrist (NEU)
15 Scraper & Intelligence (NEU)  16 Pipeline-Transitions (NEU)
17 Saga-Events (NEU)     18 AI & LLM (NEU)
```

---

## Bestehende Sektionen — 4 Row-Ergänzungen

### Emailverkehr — +1 Row (nach #32)

| # | Activity Type | Kategorie | Kanal | is_auto | entity_relevance | actor_type | source_system | is_notifiable | Beschreibung |
|---|---|---|---|---|---|---|---|---|---|
| 103 | Emailverkehr - Bounce | Emailverkehr | Email | ✓ | both | integration | outlook | false | Email konnte nicht zugestellt werden — Mail-Provider-Bounce automatisch erkannt |

### Assessment — +1 Row (nach #58)

| # | Activity Type | Kategorie | Kanal | is_auto | entity_relevance | actor_type | source_system | is_notifiable | Beschreibung |
|---|---|---|---|---|---|---|---|---|---|
| 104 | Assessment - Credit verbraucht | Assessment | System | ✓ | account | automation | event-worker | false | Credit-Verbrauch nach Durchführung automatisch gebucht |

### Placementprozess — +1 Row (nach #69)

| # | Activity Type | Kategorie | Kanal | is_auto | entity_relevance | actor_type | source_system | is_notifiable | Beschreibung |
|---|---|---|---|---|---|---|---|---|---|
| 105 | Placementprozess - Referral ausgelöst | Placementprozess | System | ✓ | candidate | automation | saga-engine | true | Saga V5 — Referral-Chain beim Placement automatisch getriggert |

### System / Meta — +1 Row (nach #64)

| # | Activity Type | Kategorie | Kanal | is_auto | entity_relevance | actor_type | source_system | is_notifiable | Beschreibung |
|---|---|---|---|---|---|---|---|---|---|
| 106 | System - Kandidat anonymisiert (GDPR) | System / Meta | System | ✓ | candidate | automation | nightly-batch | false | Persönliche Daten nach 1 Jahr Inaktivität automatisch anonymisiert |

---

## Neue Sektionen — 7 Blöcke

### Kalender & Planung (3 Einträge) — NEU v1.4

| # | Activity Type | Kategorie | Kanal | is_auto | entity_relevance | actor_type | source_system | is_notifiable | Beschreibung |
|---|---|---|---|---|---|---|---|---|---|
| 70 | Kalender - Interview geplant | Kalender & Planung | System | ✓ | both | integration | calendar-integration | true | Interview-Termin via Kalender-Integration eingetragen (Kandidat × Kunde direkt) |
| 71 | Reminder - Interview steht bevor | Kalender & Planung | System | ✓ | candidate | automation | event-worker | true | Auto-Reminder 7 Tage vor Interview-Termin (Default konfigurierbar) |
| 72 | Reminder - Interview-Datum fehlt | Kalender & Planung | System | ✓ | candidate | automation | nightly-batch | true | Stage-Wechsel zu Interview ohne Datum — 2 Tage später Reminder |

### Dokumenten-Pipeline (5 Einträge) — NEU v1.4

| # | Activity Type | Kategorie | Kanal | is_auto | entity_relevance | actor_type | source_system | is_notifiable | Beschreibung |
|---|---|---|---|---|---|---|---|---|---|
| 73 | Dokument - Hochgeladen | Dokumenten-Pipeline | System | - | both | user | manual-upload | false | Dokument-Upload durch Consultant oder Kandidat |
| 74 | Dokument - CV automatisch geparst | Dokumenten-Pipeline | System | ✓ | candidate | automation | llm | false | AI-Extraktion nach Upload (Name, Erfahrung, Kompetenzen) |
| 75 | Dokument - OCR abgeschlossen | Dokumenten-Pipeline | System | ✓ | candidate | automation | event-worker | false | Text-Erkennung bei Scan-PDFs durchgelaufen |
| 76 | Dokument - Vektorindex aufgenommen | Dokumenten-Pipeline | System | ✓ | both | automation | event-worker | false | Dokument-Chunks für semantische Suche indiziert |
| 77 | Dokument - Neu geparst | Dokumenten-Pipeline | System | - | both | user | manual-upload | false | Manueller Re-Parse durch Consultant |

### Garantie & Schutzfrist (7 Einträge) — NEU v1.4

| # | Activity Type | Kategorie | Kanal | is_auto | entity_relevance | actor_type | source_system | is_notifiable | Beschreibung |
|---|---|---|---|---|---|---|---|---|---|
| 78 | Garantiefrist - Gestartet | Garantie & Schutzfrist | System | ✓ | candidate | automation | saga-engine | true | Saga V4 — 3-Mt-Garantiefrist nach Placement eröffnet (dazukaufbar bis 6 Mt) |
| 79 | Garantiefrist - Erfüllt | Garantie & Schutzfrist | System | ✓ | candidate | automation | nightly-batch | true | Kandidat hat Garantiefrist-Zeitraum vollständig durchlaufen |
| 80 | Garantiefrist - Gebrochen | Garantie & Schutzfrist | System | ✓ | candidate | automation | event-worker | true | Austritt innerhalb Garantiefrist — Rückvergütung/Ersatz-Auslösung |
| 81 | Reminder - Garantie läuft ab | Garantie & Schutzfrist | System | ✓ | candidate | automation | nightly-batch | true | Auto-Reminder 14 Tage vor Garantie-Ablauf |
| 82 | Schutzfrist - Gestartet | Garantie & Schutzfrist | System | ✓ | both | automation | event-worker | false | Direkteinstellungs-Schutzfrist bei Nicht-Placement aktiv (Default 12 Mt) |
| 83 | Schutzfrist - Auf 16 Mt verlängert | Garantie & Schutzfrist | System | ✓ | account | automation | nightly-batch | false | Auto-Verlängerung wenn Kunde Info nicht innerhalb 10 Tagen sendet |
| 84 | Schutzfrist - Claim eröffnet | Garantie & Schutzfrist | System | ✓ | both | integration | scraper | true | Scraper erkennt Direkteinstellung innerhalb Schutzfrist — Claim-Workflow |

Hinweis: Bestehender Eintrag #64 „Schutzfrist - Status-Änderung" bleibt als Sammel-Row; #78–84 sind granulare Lifecycle-Events.

### Scraper & Intelligence (6 Einträge) — NEU v1.4

| # | Activity Type | Kategorie | Kanal | is_auto | entity_relevance | actor_type | source_system | is_notifiable | Beschreibung |
|---|---|---|---|---|---|---|---|---|---|
| 85 | Scraper - Neue Person bei Account | Scraper & Intelligence | System | ✓ | account | integration | scraper | true | LinkedIn-Scraper erkennt neuen Mitarbeiter beim Zielkunden |
| 86 | Scraper - Person hat Account verlassen | Scraper & Intelligence | System | ✓ | account | integration | scraper | true | Abgang eines Mitarbeiters automatisch detektiert |
| 87 | Scraper - Neue Job-Stelle erkannt | Scraper & Intelligence | System | ✓ | account | integration | scraper | true | Neue offene Stelle beim Zielkunden entdeckt |
| 88 | Scraper - Rollenänderung erkannt | Scraper & Intelligence | System | ✓ | both | integration | scraper | true | Person wechselt intern die Rolle (z.B. Beförderung) |
| 89 | Scraper - Eintrag importiert | Scraper & Intelligence | System | - | both | user | scraper | false | Scraper-Ergebnis nach Review in Kontakt/Job übernommen |
| 90 | Scraper - Schutzfrist-Match erkannt | Scraper & Intelligence | System | ✓ | both | integration | scraper | true | Direkteinstellung innerhalb aktiver Schutzfrist durch Scraper identifiziert |

### Pipeline-Transitions (Auto) (8 Einträge) — NEU v1.4

| # | Activity Type | Kategorie | Kanal | is_auto | entity_relevance | actor_type | source_system | is_notifiable | Beschreibung |
|---|---|---|---|---|---|---|---|---|---|
| 91 | Jobbasket - Mündliches GO erhalten | Pipeline-Transitions | System | ✓ | candidate | automation | event-worker | false | Jobbasket-Stage automatisch auf „oral_go" gesetzt |
| 92 | Jobbasket - Schriftliches GO erhalten | Pipeline-Transitions | System | ✓ | candidate | automation | event-worker | false | Schriftliche Bestätigung erhalten — Stage „written_go" |
| 93 | Jobbasket - Zuweisung abgeschlossen | Pipeline-Transitions | System | ✓ | candidate | automation | event-worker | false | Gate 1 — alle 4 Pflicht-Dokumente vorhanden (CV · Diplom · Zeugnis · Briefing) |
| 94 | Jobbasket - Versandbereit | Pipeline-Transitions | System | ✓ | candidate | automation | event-worker | false | Gate 2 — ARK-CV plus Abstract oder Exposé vorhanden |
| 95 | Jobbasket - CV an Kunde versendet | Pipeline-Transitions | System | ✓ | both | automation | event-worker | true | Versand via Dashboard To-Send-Inbox — Prozess automatisch erstellt |
| 96 | Prozess - Stage automatisch gewechselt | Pipeline-Transitions | System | ✓ | both | automation | event-worker | false | Prozess-Stage durch Auto-Rule gewechselt (keine manuelle Aktion) |
| 97 | Prozess - Stale erkannt | Pipeline-Transitions | System | ✓ | both | automation | nightly-batch | true | Stage-spezifische Alter-Schwelle überschritten (Exposé 14d / CV-Sent 10d / TI 7d / 1st-3rd 14d / Assessment 21d / Angebot 10d) |
| 98 | Prozess - Automatisch abgelehnt | Pipeline-Transitions | System | ✓ | candidate | automation | saga-engine | false | Andere offene Prozesse des Kandidaten nach Placement automatisch geschlossen |

### Saga-Events (1 Eintrag) — NEU v1.4

| # | Activity Type | Kategorie | Kanal | is_auto | entity_relevance | actor_type | source_system | is_notifiable | Beschreibung |
|---|---|---|---|---|---|---|---|---|---|
| 99 | Placement - Vollständig abgeschlossen | Saga-Events | System | ✓ | both | automation | saga-engine | true | Saga V7 erfolgreich — öffnet Sub-Drawer mit allen 6 Substeps (V1–V6) aus `fact_system_log` |

Hinweis: V1–V6 Substeps landen ausschliesslich in `fact_system_log` (Admin-Debug). Nur V7 erhält User-Timeline-Row. Correlation-ID bindet alle 7 Steps.

### AI & LLM (3 Einträge) — NEU v1.4

| # | Activity Type | Kategorie | Kanal | is_auto | entity_relevance | actor_type | source_system | is_notifiable | Beschreibung |
|---|---|---|---|---|---|---|---|---|---|
| 100 | AI - Briefing aus Transkript befüllt | AI & LLM | System | ✓ | candidate | automation | llm | true | LLM-Extraktor hat Briefing-Maske aus Call-Transkript befüllt — Consultant muss bestätigen (Status pending_confirmation) |
| 101 | AI - Call-Transkription fertig | AI & LLM | System | ✓ | both | automation | llm | false | Audio-Transkription durch Provider (Whisper/Claude) abgeschlossen |
| 102 | AI - Activity-Type-Vorschlag | AI & LLM | System | ✓ | both | automation | llm | false | Unklassifizierte History-Zeile erhält AI-Vorschlag für Activity-Type-Zuordnung |

---

## Statistik-Block — neu berechnet

Ersetzt bestehenden Statistik-Block (Zeilen 1670–1679):

```
Total Activity-Types:           106  (+37 v1.4: System-Activities 7 neue Kategorien + 4 Ergänzungen)
  davon is_auto_logged = true:   38  (6 v1.3 + 32 neue automatische System-Events)
  davon is_auto_logged = false:  68  (manuelle Erfassung durch Consultant)
Kategorien:                      18  (11 v1.3 + 7 neue: Kalender / Dokumente / Garantie-Schutzfrist / Scraper / Pipeline-Transitions / Saga / AI)

actor_type-Verteilung:
  user          ~68  (alle manuellen Einträge)
  automation    ~24  (Saga-getriebene, nightly-batch, event-worker)
  integration   ~10  (threecx, outlook, scraper, calendar)
  system         ~4  (klassische Nightly-Detection — Inactive, GO Ghosting, etc.)

entity_relevance-Verteilung:
  candidate-only: ~52
  account-only:   ~22
  both:           ~32  (deutlich mehr durch System-Events, die Kandidat+Account parallel betreffen)

source_system-Verteilung (nur actor_type <> 'user'):
  event-worker         ~13
  nightly-batch        ~8
  saga-engine          ~5
  scraper              ~6
  llm                  ~4
  outlook              ~1
  calendar-integration ~1
```

---

## §14c (NEU) — Event-Types-Katalog (`dim_event_types`)

Mapping Event-Name → Activity-Type (oder `fact_system_log`). Technisches Backing für system-activity-writer. Vollständige Seed-Liste (~50 Rows) im DB-Schema-Dokument `ARK_DATABASE_SCHEMA_v1_3.md` unter §`dim_event_types`. Hier nur Übersicht der Domänen:

| event_domain | Anzahl Events | Beispiel |
|--------------|---------------|----------|
| candidate | 2 | `candidate.stage_changed` |
| process | 4 | `process.stage_changed`, `process.stale_detected`, `process.auto_rejected`, `process.placement_completed` |
| jobbasket | 5 | `jobbasket.go_oral`, `jobbasket.cv_sent` |
| guarantee | 4 | `guarantee.started`, `guarantee.breached` |
| protection_window | 3 | `protection_window.started`, `direct_hire_claim.opened` |
| scrape | 6 | `scrape.new_person`, `scrape.role_changed` |
| document | 5 | `document.uploaded`, `document.cv_parsed` |
| email | 3 | `email.sent`, `email.received`, `email.bounced` |
| call | 2 | `call.transcript_ready`, `call.missed` |
| assessment | 3 | `assessment.link_sent`, `assessment.credit_consumed` |
| ai | 3 | `briefing.auto_filled`, `history.classification_suggested` |
| saga | 8 | `saga.v1_stage_placement` … `saga.failure` |
| system | 7 | `temperature.updated`, `circuit_breaker.tripped` |
| reminder | 3 | `reminder.interview_upcoming`, `reminder.guarantee_expiring` |
| finance | 2 | `finance.calculation_triggered`, `finance.refund_calculated` |
| referral | 1 | `referral.triggered` |

**Total ~61 Event-Types** — 46 davon → `fact_history` (über Activity-Type-Mapping), 15 davon → `fact_system_log` (Ops-only).

---

## §14d (NEU) — System-Log-Events (`fact_system_log`)

Events die **nicht** in User-Timeline erscheinen — ausschliesslich Admin-Debug-Tab (`/admin/system-log`). Keine Activity-Type-Row in `dim_activity_types` — nur Event-Type in `dim_event_types` mit `target_table='fact_system_log'`.

| event_name | severity | emitter | Zweck |
|-----------|----------|---------|-------|
| `saga.v1_stage_placement` | info | saga-engine | Step-Trace Placement-Saga |
| `saga.v2_finance_calculated` | info | saga-engine | Step-Trace |
| `saga.v3_job_filled` | info | saga-engine | Step-Trace |
| `saga.v4_guarantee_opened` | info | saga-engine | Step-Trace (feuert zusätzlich #78 in history) |
| `saga.v5_referral_triggered` | info | saga-engine | Step-Trace (feuert zusätzlich #105) |
| `saga.v6_staffing_plan_updated` | info | saga-engine | Step-Trace |
| `saga.failure` | error | saga-engine | Rollback-Alarm mit Notification |
| `temperature.updated` | debug | nightly-scoring-batch | Score-Drift-Log (Kandidat × Account) |
| `matching.scores_recomputed` | debug | matching-recompute-worker | Match-Score-Recalc nach Job-Edit |
| `staffing_plan.updated` | info | project-staffing-worker | Projekt-Stellenplan-Änderung |
| `webhook.triggered` | info | webhook-dispatcher | Ausgehende Webhook-Events |
| `dead_letter.alert` | error | event-queue-monitor | Failed-Events > 5 in 15 Min |
| `process.duplicate_detected` | warn | process-creation-guard | Duplikat-Verhinderung |
| `circuit_breaker.tripped` | critical | automation-engine | Automation-Regel-Limit erreicht |
| `retention.warning` | warn | gdpr-retention-batch | 30 Tage vor Aufbewahrungs-Ende |

**Retention `fact_system_log`:** 180 Tage (Prod) / 30 Tage (Test) / 7 Tage (Dev). Konfigurierbar über `dim_automation_settings.system_log_retention_days`.

---

## Technische Migration (Referenz)

SQL-Migration gehört **nicht** in Stammdaten-Dokument, sondern in `ARK_DATABASE_SCHEMA_v1_3.md` (folgt als Phase A Schritt 3). Reihenfolge:

1. `ALTER TABLE dim_activity_types` — 3 neue Spalten (`actor_type`, `source_system`, `is_notifiable`)
2. `CREATE TABLE dim_event_types`
3. `CREATE TABLE fact_system_log`
4. Seed `dim_activity_types` — 37 neue Rows (#70–#106)
5. Seed `dim_event_types` — ~61 Rows
6. Update bestehende Rows: `actor_type='automation'` für #60–64, #56

---

## Sync-Check-Bedarf nach Merge

Nach Einarbeitung in `ARK_STAMMDATEN_EXPORT_v1_4.md` folgende Dateien synchronisieren:

| Grundlagen-Datei | Neuer Version-Bump | Betroffene Sektionen |
|------------------|--------------------|-----------------------|
| `ARK_DATABASE_SCHEMA_v1_2.md` → v1_3 | +ALTER + 2 neue Tabellen | §dim_activity_types, §dim_event_types (neu), §fact_system_log (neu) |
| `ARK_BACKEND_ARCHITECTURE_v2_5.md` → v2_6 | Worker + Event-Scope-Registry | Sektion B (Worker-Liste), Sektion D (Saga-Correlation), Sektion G (Event-Registry) |
| `ARK_FRONTEND_FREEZE_v1_*.md` → neue Version | Timeline-Komponente + Admin-Route | UI-Komponenten, Routing |
| `ARK_GESAMTSYSTEM_UEBERSICHT_v1_*.md` → neue Version | Changelog-Eintrag v1.4 | Changelog |

Detailmasken-Specs (9) — keine Version-Bumps nötig, Timeline-Tab erbt aus zentraler Komponente.

---

## Offene Punkte — resolved v1.3 (17.04.2026)

Alle 5 Fragen sind durch `specs/ARK_SYSTEM_ACTIVITY_TYPES_DECISIONS_v1_3.md` entschieden:

| # | Frage | Entscheidung | Doc-Ref |
|---|-------|--------------|---------|
| P1 | Numbering sequentiell vs thematisch | **Sequentiell** #70–#121 bestätigt (Konsistenz mit bestehenden #1–69) | Decisions §P1/Q9 |
| P2 | `entity_relevance=both` pauschal | **Bestätigt** — Consultant-Ergonomie rechtfertigt Duplizität bei Debriefings/Interviews | Decisions §P2 |
| P3 | `is_notifiable` Defaults | **Defaults belassen** — Pilot-Phase-Review nach 4 Wochen Prod, Feinjustierung v1.5 | Decisions §P3 |
| P4 | #102 AI-Vorschlag UI-Form | **Overlay auf pending-Zeile**, nicht eigene Row. Event `history.classification_suggested` → `create_history=false`, nutzt bestehende `fact_history.suggested_activity_type` + `ai_summary` | Decisions §P4 |
| P5 | Kategorie „Garantie & Schutzfrist" split? | **Zusammen lassen** — Activity-Type-Prefix klärt (Garantiefrist - … / Schutzfrist - …) | Decisions §P5 |

### Amendment-Konsequenzen für diesen Patch

- **Row #102 bleibt** im Katalog als Activity-Type (für bestehende Rows die umklassifiziert werden). Aber Event-Type-Mapping wird im Migration-Script geändert: `history.classification_suggested` schreibt **nicht** neue `fact_history`-Row, sondern updated bestehende.
- **Statistik-Block** bleibt bei 106/117 Rows — Row #102 ist weiterhin Teil des Katalogs.
- **Kategorie-Benennung** bleibt „Garantie & Schutzfrist" — kein Split.

### Zusätzliche Amendments v1.3

Beim Decisions-Review zusätzlich entschieden (nicht in v1.2-Open-Points gelistet, aber relevant für Stammdaten-Seed):

- **Neue Activity-Types #111–#121** (11 Rows) aus `ARK_EVENT_TYPES_MAPPING_v1_4.md` — Total wird 117 statt 106
- **Namensvereinheitlichungen** (4 Events): Activity-Type-Labels bleiben unverändert, nur Event-Namen in `dim_event_types` werden kanonisiert (siehe Decisions §Namensvereinheitlichungen)
- **`system.retention_action` Split** in zwei Events: Activity-Type #106 bleibt für Kandidat-Anonymisierung; für andere Retention-Actions kein fact_history-Write (siehe Event-Mapping M1)

---

**Ende Patch v1.3 → v1.4.** Nach PO-Freigabe: Einarbeitung in `Grundlagen MD/ARK_STAMMDATEN_EXPORT_v1_4.md`, Changelog-Eintrag in `wiki/meta/grundlagen-changelog.md`.
