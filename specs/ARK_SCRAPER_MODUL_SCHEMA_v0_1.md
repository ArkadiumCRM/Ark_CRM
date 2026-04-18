# ARK CRM — Scraper-Modul Schema v0.1

**Stand:** 13.04.2026
**Status:** ⚠ Ergänzt durch Patch v0.1 → v0.2 (17.04.2026) · siehe `ARK_SCRAPER_MODUL_PATCH_v0_1_to_v0_2.md`
**Patch-Scope:** UI-Präzisierungen (Single-File-Mockup, Toggle-View, Phase-1.5-Stubs, Accept-Drawer-Details, Admin-Redundanz-Fix). Keine Breaking Changes für Datenbank/Events/Worker.
**Quellen:** ARK_FRONTEND_FREEZE_v1_10.md (4d. Scraper Top-Level), ARK_DATABASE_SCHEMA_v1_3.md, Wiki [[scraper]], ARK_ACCOUNT_DETAILMASKE_INTERACTIONS_v0_3.md Tab 7 (Scraping-Config), Entscheidungen 2026-04-13
**Begleitdokument:** `ARK_SCRAPER_MODUL_INTERACTIONS_v0_1.md`
**Vorrang:** Stammdaten > Patch v0.2 > dieses Schema > Frontend Freeze > Mockups

---

## 0. ZIELBILD & MISSION

**Mission:** Automatische Marktbeobachtung und Datenerfassung für das gesamte CRM. Accounts, Jobs, Kontakte und Kandidaten-Job-Wechsel werden **fast live** erkannt und als Vorschläge in ein Review-System gespeist. Ziel: Arkadium kennt den Markt in Echtzeit und kann schnell reagieren.

**Use Cases:**
- Neue Vakanzen auf Kunden-Websites → automatische Job-Erstellung mit Status `scraper_proposal`
- Team-Änderungen (Fluktuation) → Kontakt-Änderungen auf Account erkannt
- Job-Wechsel von Kandidaten (LinkedIn, Xing) → Schutzfrist-Match + Claim-Alerts
- Konzernstruktur-Änderungen (UID-Matches) → Firmengruppen-Vorschläge
- Stammdaten-Drift (Website-URL tot, AGB geändert) → Data-Quality-Alerts

**Primäre Nutzer:**
- **Admin (tech):** System-Gesundheit, Konfiguration, Fehler-Debugging
- **Admin:** Strategische Marktüberblick, Anomalie-Reviews
- **AM:** Review-Queue abarbeiten (neue Kontakte/Vakanzen bestätigen), Pro-Account-Triggern
- **Researcher/Hunter:** Passive Konsumenten der Schutzfrist-Alerts und Vakanz-Updates

---

## 1. DESIGNSYSTEM-REFERENZ

Erbt aus [[kandidatenmaske-schema]] § 0.

### Scraper-spezifische Tokens

| Token | Hex | Verwendung |
|-------|-----|-----------|
| Scraper-System | Purple `#a78bfa` | System-Akzent (analog AI) |
| Success | Green `#5DCAA5` | Run erfolgreich |
| Warning | Amber `#f59e0b` | Retry / Rate-Limited |
| Error | Red `#ef4444` | Run fehlgeschlagen |
| Review-pending | Gold `#dcb479` | Review-Queue Items |
| Confidence High | Green-hell | ≥ 85% |
| Confidence Medium | Amber-hell | 60–84% — AM-Review |
| Confidence Low | Red-hell | < 60% — **markiert für AM-Kontrolle** (NICHT auto-verworfen) |

**Confidence-Schwellen (v0.3 präzisiert):**
- ≥ 85%: Auto-Suggestion / Bulk-Accept möglich
- 60–84%: Standard-Review-Queue (Default-Workflow)
- < 60%: Review-Queue mit Flag `review_priority='needs_am_review'` — AM muss kontrollieren, aber **kein Auto-Reject** (Peter-Klarstellung 14.04.)

### Mockup-Dateien (zu erstellen)

| # | Tab | Datei (geplant) |
|---|-----|-----------------|
| 1 | Dashboard | `scraper_dashboard_v1.html` |
| 2 | Review-Queue | `scraper_review_queue_v1.html` |
| 3 | Runs | `scraper_runs_v1.html` |
| 4 | Configs | `scraper_configs_v1.html` |
| 5 | Alerts & Fehler | `scraper_alerts_v1.html` |
| 6 | History | `scraper_history_v1.html` |
| — | Run-Detail (Drawer + Subpage) | `scraper_run_detail_v1.html` |

---

## 2. ROUTING

```
/scraper                → Vollseite mit 6 Tabs (Haupt-Modul)
/scraper/runs/[id]      → Run-Detail (Full-Page Fallback wenn Drawer nicht reicht)
/scraper/configs/[type] → Config-Detail (für spezialisierte Scraper-Typen)
```

Default-Einstieg: `/scraper` Tab Dashboard.

---

## 3. GESAMT-LAYOUT

```
┌──────────────────────────────────────────────────────────────────┐
│ Breadcrumb: Scraper                                                │
├──────────────────────────────────────────────────────────────────┤
│ HEADER                                                             │
│ ┌──────────────────────────────────────────────────────────────┐ │
│ │ 🕸 Scraper Control Center                                      │ │
│ │                                                                  │ │
│ │ SNAPSHOT-BAR (sticky, 6 Slots, live-updating)                  │ │
│ │ ✅Runs24h  🔴Fehler  📋Review  🆕Findings  ⏱NextRun  🚨Alerts  │ │
│ │                                                                  │ │
│ │ [▶ Jetzt scrapen (Bulk)] [⚙ Configs] [📊 Report]              │ │
│ └──────────────────────────────────────────────────────────────┘ │
│ TAB-BAR: Dashboard │ Review-Queue │ Runs │ Configs │ Alerts │ Hist│
│                                                                    │
│ TAB-CONTENT                                                        │
│ KEYBOARD-HINTS-BAR                                                 │
└──────────────────────────────────────────────────────────────────┘
```

---

## 4. HEADER

### 4.1 Titel

Static: "🕸 Scraper Control Center"

### 4.2 Snapshot-Bar (sticky, 6 Slots, Live via Websocket)

| Slot | Inhalt | Source |
|------|--------|--------|
| 1 | ✅ Runs letzte 24h | `COUNT(fact_scraper_runs WHERE started_at > now-24h AND status='success')` |
| 2 | 🔴 Fehler (24h) | `COUNT(... status='error')` — klick → Tab Alerts |
| 3 | 📋 Review-Pending | `COUNT(fact_scraper_findings WHERE status='pending_review')` — klick → Tab Review-Queue |
| 4 | 🆕 Neue Findings (24h) | `COUNT(fact_scraper_findings WHERE detected_at > now-24h)` |
| 5 | ⏱ Next Scheduled Run | `MIN(fact_scraper_schedule.next_run_at)` + Account-Name |
| 6 | 🚨 Aktive Alerts | `COUNT(fact_scraper_alerts WHERE dismissed_at IS NULL)` — klick → Tab Alerts |

### 4.3 Quick Actions

| Button | Aktion |
|--------|--------|
| ▶ Jetzt scrapen (Bulk) | Drawer zur Auswahl von Accounts/Scraper-Typen → Batch-Trigger |
| ⚙ Configs | Springt zu Tab 4 |
| 📊 Report | PDF-Export Scraper-Performance-Report (Runs, Findings, Fehler, Top-Accounts) |

### 4.4 Tab-Bar

6 Tabs:

```
│ Dashboard │ Review-Queue │ Runs │ Configs │ Alerts │ History │
```

Keyboard: `1`–`6`.

---

## 5. TAB 1 — DASHBOARD

Übersicht system-weite Metriken und aktueller Gesundheitsstatus.

### 5.1 Sektionen

#### Sektion 1 — System-Gesundheit

Ampel-Status pro Scraper-Typ (7 Typen aus Entscheidung SC-2):

| Scraper-Typ | Status | Letzter Run | Success-Rate (7d) | Avg. Laufzeit |
|-------------|--------|-------------|-------------------|---------------|
| Team-Page (Kontakte) | 🟢 OK | vor 12 Min | 98% | 3.2s |
| Career-Page (Vakanzen) | 🟢 OK | vor 8 Min | 95% | 4.1s |
| Impressum / AGB | 🟡 Warning | vor 1 Std | 82% | 2.8s |
| LinkedIn Job-Wechsel | 🔵 Phase 2 | — | — | — |
| Externe Jobboards (jobs.ch, alpha.ch) | 🟢 OK | vor 15 Min | 91% | 5.5s |
| Geschäftsberichte / Presse | 🟢 OK | vor 3 Std | 88% | 8.2s |
| Handelsregister (UID-Check) | 🟢 OK | vor 2 Std | 99% | 1.4s |

#### Sektion 2 — Findings-Breakdown (letzte 7 Tage)

Balkendiagramm:
- Kontakte: neu, geändert, verschwunden
- Vakanzen: neu, geändert, verschwunden
- Job-Wechsel (Personen): entdeckt
- Firmengruppen-Vorschläge: entdeckt
- AGB-/Team-Changes: entdeckt

Klick auf Segment → Review-Queue gefiltert.

#### Sektion 3 — Top-Activity-Accounts

Welche Accounts hatten die meisten Findings? Top 10 als Liste:
- Account-Link
- Typ-Count (Kontakte: 3, Vakanzen: 2)
- Temperatur
- Scrape-Intervall

#### Sektion 4 — Error-Stream (Live)

Scroll-Feed letzter Fehler (letzte 20):
- Zeit
- Scraper-Typ
- Account
- Fehlermeldung (kurz)
- Klick → Fehler-Detail

#### Sektion 5 — Anomalie-Radar

AI-basierte Anomalie-Erkennung:
- "Plötzlich 50+ Vakanzen bei Account X detected — Restrukturierung?"
- "Team-Fluktuation bei Account Y in 3 Monaten: 8 Abgänge"
- "Konkurrenz-Analyse: Account Z hat neuen Dienstleister (Scraper sieht Posting auf fremder Plattform)"

---

## 6. TAB 2 — REVIEW-QUEUE (KERN-ARBEITSUMGEBUNG)

Staging-Area wo **alle Scraper-Findings** landen und Review abwarten (Entscheidung SC-7: Staging, SC-13: Review-Queue mit Confidence).

### 6.1 Layout

**Kanban mit 4 Spalten nach Confidence + Typ**, oder Tabelle mit Filter.

**Default-Sort:** `confidence_score DESC`, dann `detected_at ASC`.

### 6.2 Finding-Typen

| Typ | Beschreibung | Target-Entity |
|-----|--------------|--------------|
| `new_contact` | Neue Person auf Team-Page | Account (Kontakt-Vorschlag) |
| `contact_changed` | Existierender Kontakt hat neue Rolle/Titel | Account-Kontakt |
| `contact_disappeared` | Kontakt verschwunden (verlassen Firma?) | Account-Kontakt (Status → "Left Company"?) |
| `new_vacancy` | Neue Vakanz auf Career-Page | Account (Job mit `scraper_proposal`) |
| `vacancy_changed` | Vakanz geändert (Titel, Beschreibung) | Job |
| `vacancy_disappeared` | Vakanz nicht mehr ausgeschrieben | Job (Status → Geschlossen?) |
| `person_job_change` | Kandidat hat neuen Arbeitgeber (LinkedIn) | Kandidat + Schutzfrist-Match |
| `group_suggestion` | UID-Match weist auf Firmengruppe hin | Firmengruppe-Vorschlag |
| `stammdaten_drift` | Website-URL tot / AGB-Änderung / Mitarbeitendenzahl-Änderung | Account-Stammdaten |
| `anomaly_detected` | Unusual Pattern (Fluktuation-Spike, Vakanz-Explosion) | Alert |

### 6.3 Finding-Card

```
┌──────────────────────────────────────────┐
│ 🆕 Neue Vakanz · Confidence: 87% 🟢       │
│ Account: Volare Group AG                  │
│ Titel: Bauingenieur Tiefbau (m/w/d)       │
│ Quelle: https://volare.ch/karriere/...    │
│ Entdeckt: vor 12 Minuten                  │
│ Scraper-Run: #4721                        │
│ ─────────────────────────────────────── │
│ [✓ Übernehmen]  [✗ Verwerfen]  [🔍 Detail]│
└──────────────────────────────────────────┘
```

**Low-Confidence-Card (NEU v0.3):** Bei `confidence < 60%` bekommt Card einen zusätzlichen amber Warning-Bar oben:
```
┌──────────────────────────────────────────┐
│ ⚠ NEEDS AM REVIEW · Confidence: 52% 🔴   │
│ 🆕 Firmengruppe-Vorschlag                 │
│ UID-Match: Implenia AG ↔ Implenia Bau AG  │
│ Match-Begründung: Hauptsitz + Namens-Wz   │
│ ─────────────────────────────────────── │
│ [✓ Übernehmen]  [✗ Verwerfen]  [🔍 Detail]│
└──────────────────────────────────────────┘
```

**Kein Auto-Reject:** Findings mit Confidence < 60% bleiben in Review-Queue, werden aber mit `review_priority='needs_am_review'` gekennzeichnet — AM muss explizit entscheiden.

### 6.4 Spalten (falls Tabellen-View)

| Spalte | Inhalt |
|--------|--------|
| Typ | Icon + Label |
| Confidence | 0–100 Gauge mit Farb-Gradient |
| Account / Entity | Link |
| Summary | 1-Liner |
| Quelle | URL (truncated) |
| Entdeckt | Relative Zeit |
| Aktionen | ✓ Übernehmen / ✗ Verwerfen / 🔍 Detail-Drawer |

### 6.5 Filter-Bar

- Finding-Typ (Multi-Select)
- Confidence-Range (Slider)
- **Review-Priority** (neu v0.3): Standard / "Needs AM Review" / Alle
- Account (Autocomplete)
- Zeitraum (entdeckt)
- Status: pending / accepted / rejected / auto_accepted
- Scraper-Run (optional)

### 6.6 Bulk-Aktionen (Multi-Select)

- ✓ Alle ≥ 80% Confidence übernehmen
- ✗ Ausgewählte verwerfen
- 🔍 Als CSV exportieren

### 6.7 Auto-Accept-Schwelle

Admin-Setting: `auto_accept_confidence_threshold` (Default: **kein Auto-Accept** in v0.1, alles Review-pflichtig).
Phase 1.5: konfigurierbar pro Finding-Typ (z.B. Vakanzen-Changes auto-accept ≥ 90%).

### 6.8 Empty-State

> "Keine offenen Findings. Scraper läuft im Hintergrund — neue Funde erscheinen hier automatisch."

---

## 7. TAB 3 — RUNS

Historie aller Scrape-Durchläufe.

### 7.1 Layout

Tabelle mit Filter. Default-Sort: `started_at DESC`.

### 7.2 Spalten

| Spalte | Inhalt |
|--------|--------|
| Run-ID | z.B. `SCR-2026-04721` |
| Zeit | `started_at` formatiert |
| Dauer | `finished_at - started_at` |
| Scraper-Typ | Badge |
| Account / Scope | Link falls account-spezifisch; "Global" bei System-Run |
| Status | 🟢 success / 🟡 partial / 🔴 error |
| Findings | Count (neu/geändert/verschwunden) |
| Trigger | Scheduled / Manual / API |
| User | wer hat manuell getriggert (falls) |
| Aktionen | 🔍 Detail (Drawer) / Rerun |

### 7.3 Filter

- Scraper-Typ
- Account
- Status (Success / Error / Partial)
- Trigger
- Zeitraum
- Mit Findings / Ohne Findings

### 7.4 Run-Detail-Drawer (540px)

Klick auf Row:
- Run-Metadata (Run-ID, Zeiten, Config-Version)
- Request/Response-Summary (HTTP-Status, Response-Size)
- Findings-Liste (aus diesem Run)
- Fehler-Log (falls partial/error)
- AI-Extraktions-Log (was die AI aus dem HTML gelesen hat)
- Raw HTML-Snapshot-Link (falls noch gespeichert innerhalb Retention, SC-9)
- Rerun-Button

"→ Vollansicht" → `/scraper/runs/[id]` mit erweiterten Diff-Ansichten.

### 7.5 Retention

Nur **Diff-Änderungen + Metadata dauerhaft** (Entscheidung SC-9: Option B). Raw-HTML nur für 7 Tage, danach gelöscht außer bei Fehler-Runs (30 Tage).

---

## 8. TAB 4 — CONFIGS (SCRAPER-REGISTRY)

### 8.1 Scraper-Typen-Registry

Tabelle aller verfügbaren Scraper-Typen mit globalen Defaults:

| Scraper-Typ | Implementation | Default-Intervall | Rate-Limit | Aktiv | Letzte Version |
|-------------|----------------|-------------------|------------|-------|----------------|
| Team-Page | Spezialisiert (per Account) | 24h | 10/h | ✅ | v1.2 |
| Career-Page | Spezialisiert | 12h | 15/h | ✅ | v1.1 |
| Impressum | Generisch | 7d | 5/h | ✅ | v1.0 |
| LinkedIn Job-Wechsel | Spezialisiert | 24h | API-Limit | ⏸ Phase 2 | — |
| Jobboards (jobs.ch, alpha.ch) | Spezialisiert | 6h | 30/h | ✅ | v1.0 |
| Geschäftsberichte | Generisch + AI-Klassifikation | 90d | 2/h | ✅ | v1.0 |
| Handelsregister | Spezialisiert (Zefix-API) | 30d | 50/d | ✅ | v1.0 |

(Hybrid-Ansatz SC-10: spezialisiert für wichtige Sources, generisch für Rest.)

### 8.2 Config-Detail-Drawer

Pro Scraper-Typ:
- Aktivieren/Deaktivieren
- Default-Scheduling
- Rate-Limits
- Auth-Credentials (masked)
- AI-Extraktions-Prompts (für LLM-basierte Scraper)
- Confidence-Schwellen

### 8.3 Account-Overrides

Liste aller Accounts mit abweichenden Scraping-Konfigurationen (pro Account-Tab 7). Hier read-only ersichtlich; Änderung passiert im Account-Tab.

### 8.4 Scheduling-Strategie (SC-3 Kombination)

Prioritäts-basiert auf Account-Temperatur + Customer Class + Base-Interval:

```
effective_interval = base_interval × temperature_factor × class_factor
  temperature_factor: Hot=0.5 · Warm=1.0 · Cold=2.0
  class_factor:       A=0.75 · B=1.0 · C=1.25
```

Admin-Settings in `dim_scraper_global_settings` (JSONB).

---

## 9. TAB 5 — ALERTS & FEHLER

### 9.1 Alert-Typen

Alle Alerting-Typen aus SC-14:

| Typ | Trigger | Severity |
|-----|---------|----------|
| `run_failed` | Scraper-Run fehlgeschlagen | Warning |
| `n_strike_disable` | N Fehler in Folge → Disabled | Error |
| `new_findings_high_confidence` | > 5 Findings mit Conf. ≥ 80% in einem Run | Info |
| `protection_violation_detected` | Kandidat hat neuen Arbeitgeber + aktive Schutzfrist | **Critical** |
| `anomaly_fluktuation` | Ungewöhnliche Team-Fluktuation bei einem Account | Warning |
| `anomaly_vacancy_spike` | Plötzlich viele neue Vakanzen (Restrukturierung-Signal) | Info |
| `stammdaten_drift` | Website-URL tot, Mitarbeitendenzahl stark geändert | Warning |
| `rate_limit_reached` | Source-Rate-Limit erreicht | Warning |
| `auth_failed` | Auth-Credentials abgelaufen | Error |

### 9.2 Layout

Tabelle + Filter. Default-Sort: `severity DESC, created_at DESC`.

### 9.3 Spalten

| Spalte | Inhalt |
|--------|--------|
| Severity | 🔴 Critical / 🟡 Warning / 🔵 Info |
| Typ | Badge |
| Account / Entity | Link (falls spezifisch) |
| Message | Kurz-Text |
| Entdeckt | Zeit |
| Status | Pending / Acknowledged / Dismissed |
| Aktionen | ✓ Acknowledge / ✗ Dismiss / 🔍 Detail |

### 9.4 Notifications

Alerts triggern Notifications:
- **Critical** → Push an Admin + Admin + Owner-AM
- **Warning** → In-App-Notification
- **Info** → Nur im Dashboard, keine Notification

### 9.5 Auto-Dismiss

Info-Alerts werden nach 30 Tagen automatisch archiviert (nicht gelöscht, in History sichtbar).

---

## 10. TAB 6 — HISTORY

System-weites Event-Log aller Scraper-Aktivitäten.

### 10.1 Event-Typen

| Event | Scope |
|-------|-------|
| `scraper_run_started` | Run |
| `scraper_run_finished` | Run |
| `scraper_run_failed` | Run |
| `finding_detected` | Finding + Run |
| `finding_accepted` / `finding_rejected` | Finding |
| `config_changed` | Config |
| `alert_raised` | Alert |
| `alert_dismissed` | Alert |
| `auto_disable_triggered` | Scraper-Typ |

### 10.2 Filter

Wie andere History-Tabs. Zusätzlich: Scope (System / Account / Run).

---

## 11. KEYBOARD-HINTS-BAR

**Global:** `1`–`6` Tab · `Ctrl+K` Suche · `Esc`

**Tab 1 Dashboard:** `R` Refresh · `P` Report

**Tab 2 Review-Queue:** `↑`/`↓` Navigation · `A` Accept · `X` Reject · `Shift+A` Bulk-Accept (≥ Schwelle)

**Tab 3 Runs:** `F` Filter · `R` Rerun (aktiver Run)

**Tab 4 Configs:** `E` Edit

**Tab 5 Alerts:** `A` Acknowledge · `D` Dismiss

---

## 12. RESPONSIVE

**Desktop (≥ 1280px):** Volle Darstellung, Kanban Tab 2.
**Tablet (768–1279px):** Kanban → Tabelle.
**Mobile (< 768px):** Phase 2 (Read-only).

---

## 13. BERECHTIGUNGEN (RBAC)

| Aktion | Admin | Admin | AM (Owner Account) | AM (andere) | Researcher |
|--------|-------|---------|-------------------|-------------|-----------|
| Dashboard lesen | ✅ | ✅ | ✅ | ✅ | ✅ |
| Review-Queue: Accept/Reject für eigene Accounts | ✅ | ✅ | ✅ | ❌ | ❌ |
| Review-Queue: Accept/Reject global | ✅ | ✅ | ❌ | ❌ | ❌ |
| Run manuell triggern (eigener Account) | ✅ | ✅ | ✅ | ❌ | ❌ |
| Bulk-Run triggern | ✅ | ✅ | ❌ | ❌ | ❌ |
| Configs bearbeiten | ✅ | ⚠ | ❌ | ❌ | ❌ |
| Alerts acknowledgen | ✅ | ✅ | ⚠ (eigene) | ❌ | ❌ |
| Scraper-Typ aktivieren/deaktivieren | ✅ | ❌ | ❌ | ❌ | ❌ |

---

## 14. DATENBANK-REFERENZ

### Neue Tabellen

```sql
dim_scraper_types (
  id uuid PK,
  type_key VARCHAR UNIQUE,     -- 'team_page', 'career_page', 'linkedin', etc.
  display_name VARCHAR,
  implementation ENUM('specialized','generic','ai_assisted'),
  is_active BOOLEAN DEFAULT TRUE,
  default_interval_hours INT,
  rate_limit_per_hour INT,
  config_json JSONB,
  current_version VARCHAR
)

dim_scraper_global_settings (
  id uuid PK, tenant_id FK,
  auto_accept_confidence_threshold DECIMAL NULL,  -- NULL = manual review
  error_retry_max INT DEFAULT 3,
  n_strike_disable_threshold INT DEFAULT 5,
  hot_account_factor DECIMAL DEFAULT 0.5,
  cold_account_factor DECIMAL DEFAULT 2.0,
  class_a_factor DECIMAL DEFAULT 0.75,
  class_c_factor DECIMAL DEFAULT 1.25,
  updated_at, updated_by
)

fact_scraper_schedule (
  id uuid PK, tenant_id FK,
  scraper_type_id FK,
  account_id FK NULL,           -- NULL = global scraper (e.g. handelsregister)
  next_run_at TIMESTAMP,
  effective_interval_hours INT,
  priority INT,
  UNIQUE(scraper_type_id, account_id)
)

fact_scraper_runs (
  id uuid PK, tenant_id FK,
  scraper_type_id FK,
  account_id FK NULL,
  trigger ENUM('scheduled','manual','api','bulk'),
  triggered_by FK NULL,
  started_at, finished_at,
  status ENUM('running','success','partial','error'),
  http_status INT NULL,
  response_size_bytes INT NULL,
  findings_count INT,
  error_message TEXT NULL,
  raw_html_ref VARCHAR NULL,    -- S3/Blob-Ref, 7 Tage Retention (30 bei Error)
  config_version_snapshot JSONB
)

fact_scraper_findings (
  id uuid PK, tenant_id FK,
  scraper_run_id FK,
  finding_type ENUM('new_contact','contact_changed','contact_disappeared',
                    'new_vacancy','vacancy_changed','vacancy_disappeared',
                    'person_job_change','group_suggestion',
                    'stammdaten_drift','anomaly_detected'),
  target_entity_type ENUM('account','contact','job','candidate','group'),
  target_entity_id FK NULL,     -- NULL wenn noch nicht im CRM
  confidence_score DECIMAL,     -- 0.00–1.00
  review_priority ENUM('standard','needs_am_review') DEFAULT 'standard',  -- NEU v0.3 (Peter 14.04.)
  source_url VARCHAR,
  summary TEXT,
  raw_data_json JSONB,          -- Extrahierte Daten
  detected_at TIMESTAMP,
  status ENUM('pending_review','accepted','rejected','auto_accepted'),
  reviewed_by FK NULL,
  reviewed_at TIMESTAMP NULL,
  rejection_reason VARCHAR NULL,
  resulting_entity_id FK NULL   -- bei Accept: FK auf neu erstellte Entity
)

fact_scraper_alerts (
  id uuid PK, tenant_id FK,
  alert_type ENUM(...),         -- siehe Tab 5
  severity ENUM('info','warning','error','critical'),
  account_id FK NULL,
  scraper_run_id FK NULL,
  message TEXT,
  created_at TIMESTAMP,
  acknowledged_by FK NULL,
  acknowledged_at TIMESTAMP NULL,
  dismissed_at TIMESTAMP NULL
)
```

### Erweiterte bestehende Tabellen

```sql
dim_accounts:
  + scraping_enabled (bestehend)
  + scrape_interval_hours (bestehend, wird als Override genutzt)
  + last_scraped_at (bestehend)
  + last_scraped_types JSONB   -- welche Typen bei letztem Run gelaufen sind

fact_history:
  -- Scraper-Events werden auch in fact_history geloggt (scope='system' oder 'account')
```

---

## 15. OFFENE SPEC-PUNKTE

| # | Punkt | Priorität |
|---|-------|-----------|
| 1 | Interactions-Spec v0.1 (direkt folgend) | P0 |
| 2 | Mockup-HTMLs für 6 Tabs + Run-Detail | P1 |
| 3 | LinkedIn-Scraper-Evaluation (API-Zugang, legal, Cost) | Phase 2 |
| 4 | AI-Extraktions-Prompts pro Scraper-Typ (Prompt-Library) | P1 |
| 5 | Admin-UI für Confidence-Schwelle pro Finding-Typ | Phase 1.5 |
| 6 | Cost-Tracking (AI-Tokens, API-Kosten) | Phase 2 |
| 7 | Rate-Limit-Strategie bei N parallelen Tenants (falls Multi-Tenant) | Phase 2 |
| 8 | Failover-Strategie bei Source-Änderungen (HTML-Struktur ändert sich) | Phase 1.5 |

---

## 16. RELATED SPECS / WIKI

- `ARK_SCRAPER_MODUL_INTERACTIONS_v0_1.md`
- `ARK_ACCOUNT_DETAILMASKE_INTERACTIONS_v0_3.md` Tab 7 Scraping-Config + Tab 3 Kontakt-Vorschläge aus Scraper
- `ARK_JOB_DETAILMASKE_INTERACTIONS_v0_1.md` (Scraper-Proposal-Confirmation)
- `ARK_FIRMENGRUPPE_DETAILMASKE_INTERACTIONS_v0_1.md` (Group-Suggestion)
- `ARK_MANDAT_DETAILMASKE_INTERACTIONS_v0_3.md` TEIL 10 (Schutzfrist-Match durch Scraper)
- [[scraper]], [[direkteinstellung-schutzfrist]]
- [[detailseiten-guideline]]
