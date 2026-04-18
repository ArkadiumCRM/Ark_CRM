# ARK CRM — Scraper-Modul Interactions Spec v0.1

**Stand:** 13.04.2026
**Status:** ⚠ Ergänzt durch Patch v0.1 → v0.2 (17.04.2026) · siehe `ARK_SCRAPER_MODUL_PATCH_v0_1_to_v0_2.md`
**Patch-Scope:** Accept-Drawer fully replicated (P4), Schutzfrist-Critical-Flow präzisiert (P7), AI-Prompt-Editor mit Test-Button (P8). Keine Änderung an Events, Sagas, Workern.
**Kontext:** Verhalten, Lifecycle, Flows, Automationen des Scraper-Kontrollzentrums `/scraper`. Mission: automatische Marktüberwachung mit Near-Live-Reactions.
**Begleitdokument:** `ARK_SCRAPER_MODUL_SCHEMA_v0_1.md`
**Vorrang:** Stammdaten > Patch v0.2 > dieses Dokument > Schema > Mockups

---

## TEIL 0: STRUKTURELLE GRUNDENTSCHEIDUNGEN

### 6-Tab-Struktur

| # | Tab | Inhalt |
|---|-----|--------|
| 1 | Dashboard | System-Gesundheit, Findings-Breakdown, Top-Activity, Errors, Anomalien |
| 2 | Review-Queue | Pending Findings zu bestätigen/verwerfen |
| 3 | Runs | Alle Scrape-Durchläufe mit Drilldown |
| 4 | Configs | Scraper-Typen-Registry + globale Settings |
| 5 | Alerts & Fehler | 9 Alert-Typen mit Severity-basierten Notifications |
| 6 | History | System-weites Event-Log |

### 7 Scraper-Typen (Phase 1)

1. Team-Page (Kontakte)
2. Career-Page (Vakanzen)
3. Impressum / AGB (Stammdaten-Check)
4. LinkedIn Job-Wechsel **(Phase 2)** — komplex, API-Zugang
5. Externe Jobboards (jobs.ch, alpha.ch)
6. Geschäftsberichte / Presse (AI-Klassifizierung)
7. Handelsregister (UID-Check → Firmengruppen-Match)

### Implementation-Hybrid

Spezialisierte Scraper für wichtige Sources (Team-Page, Career-Page, LinkedIn, Jobboards, Handelsregister), generische AI-basierte für Rest (Impressum, Geschäftsberichte).

### Output-Flow: Staging + Review

**Alles landet zuerst in `fact_scraper_findings.status = 'pending_review'`.** Kein direkter Write in Live-Daten. AM/Admin reviewen und akzeptieren/verwerfen. (Auto-Accept-Schwelle konfigurierbar, Default in v0.1: manual review always.)

---

## TEIL 1: HEADER & SNAPSHOT-BAR

### Live-Update

Alle 6 Snapshot-Slots aktualisieren sich **via Websocket** — Ziel: Near-Live-Reactions. Runs-Status, neue Findings, Alerts erscheinen mit < 2 Sek Delay.

### Quick-Action "▶ Jetzt scrapen (Bulk)"

Drawer:
1. Scope-Auswahl: Alle Accounts / Subset (Multi-Select) / Pro Scraper-Typ
2. Parallelisierungs-Grad (Default: 5 parallel)
3. Rate-Limit-Warnung bei ausgewählten Sources
4. Bestätigung → Batch-Jobs erstellt, Runs in Tab 3 erscheinen live

### "📊 Report" Generator

PDF-Export mit:
- Performance-KPIs (7d / 30d / all-time)
- Top-10-Accounts nach Findings
- Fehler-Summary
- Confidence-Verteilung
- Anomalie-Logs

---

## TEIL 2: TAB 1 — DASHBOARD

### System-Gesundheit (Sektion 1)

**Ampel-Logik pro Scraper-Typ:**
- 🟢 OK: Success-Rate (7d) ≥ 90% UND letzter Run < 2× Default-Intervall
- 🟡 Warning: Success-Rate 70–89% ODER letzter Run überfällig
- 🔴 Error: Success-Rate < 70% ODER disabled durch N-Strike

Klick auf Ampel → Drill-Down zu Runs gefiltert.

### Findings-Breakdown (Sektion 2)

Interaktives Balkendiagramm, Zeitraum-Slider (24h / 7d / 30d). Klick auf Segment → Review-Queue gefiltert auf Typ + Zeitraum.

### Top-Activity-Accounts (Sektion 3)

Top 10 Accounts mit meisten Findings in gewähltem Zeitraum. Klick → Account-Detailseite.

### Error-Stream (Sektion 4)

Live-Feed via Websocket. Letzte 20 Fehler. Neue Fehler erscheinen oben mit Fade-In-Animation.

### Anomalie-Radar (Sektion 5)

AI-basierte Erkennung:
- **Fluktuations-Anomalie:** > X Team-Änderungen in Zeitraum Y bei einem Account
- **Vakanz-Spike:** plötzlich viele neue Vakanzen (Restrukturierungs-Signal)
- **Dienstleister-Erkenntnis:** Kunde hat Konkurrenz-Plakat aufgeschaltet
- **Domain-Änderung:** Website-URL umgeleitet

Jeder Anomalie-Eintrag hat:
- Kurz-Summary
- Button "In Alert umwandeln" (für Tab 5)
- Button "Ignorieren"

---

## TEIL 3: TAB 2 — REVIEW-QUEUE (KERN)

### Finding-Card-Interaktion

**Accept-Flow (✓ Übernehmen):**
1. Confirm-Dialog bei Findings < Konfidenz 50% (sonst Quick-Accept)
2. Finding-Typ-spezifische Action:
   - `new_contact` → Öffnet Kontakt-Erstellungs-Drawer (analog Account Tab 3) mit vorbefüllten Feldern. AM reviewed und bestätigt. Kontakt-Kandidat-Matching wird ausgelöst.
   - `new_vacancy` → Öffnet Job-Erstellungs-Drawer mit `status='vakanz'`, vorbefüllt aus Scraper-Daten. AM reviewed und bestätigt (oder direkt akzeptieren).
   - `contact_changed` → Update-Preview mit Diff, AM bestätigt Änderungen.
   - `contact_disappeared` → Confirm "Kontakt auf 'Left Company' setzen?"
   - `vacancy_changed` / `vacancy_disappeared` → analog.
   - `person_job_change` → **KRITISCH**: Schutzfrist-Match-Check → bei Treffer Claim-Workflow (siehe Account-Interactions v0.2 TEIL 8c)
   - `group_suggestion` → Öffnet Firmengruppe-Erstellungs-Drawer mit Scraper-Vorschlag-Flag
   - `stammdaten_drift` → AM kann Stammdaten im Account-Tab 1 aktualisieren
3. Nach Accept: `fact_scraper_findings.status = 'accepted'`, `resulting_entity_id` gesetzt auf FK der (neu) erstellten Entity
4. Event `finding_accepted` im History

**Reject-Flow (✗ Verwerfen):**
1. Pflicht-Grund (Dropdown): Falsche Extraktion / Duplikat / Bereits bekannt / Nicht relevant / Spam
2. `status = 'rejected'`, `rejection_reason` gesetzt
3. **Learning:** Admin-UI zeigt häufige Rejection-Gründe pro Scraper-Typ — hilft bei Prompt-Tuning

**Detail-Drawer (🔍):**
- Volle Raw-Daten (JSON)
- Source-URL + Preview (iframe falls möglich)
- AI-Extraktions-Prompt + Response
- Scraper-Run-Metadata
- Confidence-Breakdown (was hat zu Confidence beigetragen)
- Ähnliche Findings (Duplikat-Check)

### Bulk-Accept

"✓ Alle ≥ 80% Confidence übernehmen":
1. Confirm-Dialog mit Count + Typ-Breakdown
2. Für **einfache Typen** (Vakanz-Changes, Contact-Changes ohne Konflikt): Auto-Execute
3. Für **komplexe Typen** (new_contact, new_vacancy, person_job_change): jeweils Drawer → nacheinander abarbeiten

### Filter-State

Wird im URL persistiert (Deep-Linking). Default-Filter: `status = 'pending_review'`, sort by `confidence DESC, detected_at ASC`.

### Live-Updates

Neue Findings erscheinen live (Websocket) mit Fade-In. Counter in Snapshot-Bar inkrementiert.

---

## TEIL 4: TAB 3 — RUNS

### Run-Row-Interaktion

Klick → Drawer mit Run-Details. "Rerun"-Button: repeats den Run mit aktueller Config (nicht config_version_snapshot).

### Run-Status-Badges

- 🟢 Success: kein Fehler, mind. 1 Finding oder ok-no-change
- 🟡 Partial: manche Steps ok, manche Fehler
- 🔴 Error: Run komplett fehlgeschlagen
- 🔵 Running: aktuell laufend (live)

### Raw-HTML-Snapshots

Retention-Regel (SC-9):
- Success + Findings: 7 Tage
- Error: 30 Tage (für Debugging)
- Nach Retention: Raw gelöscht, aber Metadata + Findings bleiben dauerhaft

### Diff-Ansicht `/scraper/runs/[id]`

Full-Page-View mit:
- Vorheriger Run vs. aktueller Run
- Diff-Highlighting auf HTML-Ebene (falls Raw noch da)
- Extrahierte Daten-Vergleich
- Findings-Diff (was ist neu, was ist entfernt, was hat sich geändert)

---

## TEIL 5: TAB 4 — CONFIGS

### Scraper-Typ aktivieren / deaktivieren

Toggle pro Typ:
- Bei Deaktivierung: alle Scheduled Runs cancelled
- Bestehende pending Findings bleiben in Review-Queue
- Event `scraper_type_disabled` / `_enabled`

### Config-Edit-Drawer

Pro Typ:
- Intervall-Default (h)
- Rate-Limit (requests/h)
- Auth-Credentials (OAuth, API-Key — masked + rotating)
- AI-Prompts (für AI-assisted Scrapers, mit Test-Button)
- Confidence-Schwellen (pro Finding-Typ)
- Retry-Strategie (max attempts, backoff)

**Validierung:** Änderungen werden versioniert (`current_version` inkrementiert). Running Runs nutzen alten Snapshot.

### Scheduling-Priorität

Formel wie in Schema § 8.4. UI zeigt Vorschau:
- "Volare Group (Hot, Class A): Team-Page alle 9h, Career-Page alle 4.5h"

Admin kann Faktoren editieren in globalen Settings.

### Manuelle Trigger aus Configs

"▶ Einmal-Run"-Button pro Typ + Account-Auswahl (Admin-Only).

---

## TEIL 6: TAB 5 — ALERTS

### Critical-Alert-Flow

**`protection_violation_detected`** (KRITISCH):
1. Trigger: Scraper findet `person_job_change` UND aktive Schutzfrist (account OR group-level) existiert für Kandidat+Account
2. Alert wird **sofort** erstellt mit `severity='critical'`
3. Push-Notification an Admin + Admin + Owner-AM
4. Alert-Row hat Action-Button: "→ Zu Claim-Workflow" (führt zu Account-Tab 9 Schutzfristen mit gefiltertem Case)

### Acknowledge vs. Dismiss

- **Acknowledge:** "Ich habe es gesehen" — Alert bleibt in Liste aber wird grau
- **Dismiss:** "Erledigt / nicht relevant" — Alert verschwindet aus aktiver Liste, landet in History

### N-Strike-Disable

Wenn Scraper-Typ N-mal in Folge fehlschlägt:
1. Auto-Disable (toggle in Config)
2. Critical Alert an Admin
3. Event `auto_disable_triggered`
4. Admin muss manuell re-aktivieren nach Fehlerbehebung

---

## TEIL 7: TAB 6 — HISTORY

Standard-History-Pattern. Scope-Filter: System / Account / Scraper-Typ.

---

## TEIL 8: CROSS-ENTITY-INTEGRATIONEN

Alle Integrationen aus SC-11:

### (a) Kontakt-Vorschlag am Account

- Scraper-Finding `new_contact` → Review-Queue
- Accept → Kontakt-Erstellungs-Drawer (analog Account Tab 3) mit vorbefüllten Feldern
- Auto-Match gegen `dim_candidates_profile`: Email exakt / Name+Function
- Bei Match: Kontakt mit bestehendem Kandidaten-FK angelegt
- Bei Kein-Match: Hard-Stop "→ Als Kandidat anlegen" (Kontakt-Kandidat-Regel)

### (b) Vakanz-Vorschlag als Job

- Finding `new_vacancy` → Job mit `status='scraper_proposal'`, `confirmation_status='scraper_proposal'`
- Banner im Account-Tab 6 + Job-Detailseite Header
- Accept via Confirmation-Drawer (Job-Interactions v0.1 TEIL 1)

### (c) Personen-Job-Wechsel → Schutzfrist-Match

- Finding `person_job_change` mit `target_entity_type='candidate'`
- Query: `fact_protection_window WHERE candidate_id = finding.candidate_id AND (account_id = finding.new_employer_account_id OR group_id = finding.new_employer_group_id) AND status='active'`
- Bei Treffer:
  - Critical Alert `protection_violation_detected`
  - `fact_protection_window.status = 'claim_pending'`
  - Banner in Account-Tab 9 (oder Firmengruppe-Tab 4 bei Group-Scope)
- Kein Treffer: nur Kandidat-History-Update (Neuer Arbeitgeber detected)

### (d) Firmengruppe-Vorschlag via UID-Match

- Finding `group_suggestion` bei UID-Root-Match mehrerer Accounts
- Öffnet Firmengruppen-Erstellungs-Drawer mit vorgeschlagener Mitglieder-Liste
- Accept → `dim_firmengruppen` Insert, `dim_accounts.group_id` gesetzt, rückwirkende Schutzfrist-Gruppen-Einträge (siehe Firmengruppe-Interactions TEIL 2)

### (e) AGB-/Team-Change-Alert

- Finding `stammdaten_drift` → Alert-Typ Warning
- AM navigiert zu Account Tab 1 und aktualisiert

---

## TEIL 9: SCHEDULING & RATE-LIMITING

### Priority-Queue

Beim Scheduling werden Runs nach `priority` gereiht:
- Hot Account: Priority 1
- Active Mandate: Priority 1
- Warm Account: Priority 2
- Cold Account: Priority 3
- System-Runs (Handelsregister, etc.): Priority 4

### Rate-Limit-Enforcement

Pro Scraper-Typ + pro Source-Domain:
- Token-Bucket-Algorithmus
- Bei Exhaustion: Run wird auf `status='partial'` mit `error='rate_limited'`
- Alert `rate_limit_reached` wenn > 50% der Token in 1h verbraucht

### Concurrent-Run-Limit

Max 10 parallele Scraper-Runs system-weit (konfigurierbar via `dim_scraper_global_settings`).

---

## TEIL 10: ERROR-HANDLING & RETRY

### Retry-Logik (Exponential Backoff)

1. 1. Versuch: sofort
2. 2. Versuch: nach 1 min
3. 3. Versuch: nach 5 min
4. Nach 3 Retries ohne Erfolg: Run `status='error'` markieren, Alert raisen
5. Bei **N-Strike-Disable** (SC-5, default N=5): Scraper-Typ auto-deaktiviert, Critical Alert

### Fehler-Typen

| Typ | Behandlung |
|-----|-----------|
| `network_timeout` | Retry |
| `http_4xx` | Einmaliger Retry, dann Error (außer 429 → Rate-Limit-Handling) |
| `http_5xx` | Retry |
| `parse_error` | Einmaliger Retry mit alternativer Parsing-Strategie, dann Error |
| `auth_failed` | Kein Retry, sofort Alert `auth_failed` |
| `ai_extraction_failed` | Retry ohne AI-Extraktion (Fallback auf Raw) |

---

## TEIL 11: AI-INTEGRATION

### Extraktion

- LLM-basierte Extraktion aus HTML → strukturierte Daten (JSON)
- Prompts sind in `dim_scraper_types.config_json.extraction_prompt` gespeichert
- Admin kann Prompts editieren (Versionierung)
- Output-Schema wird pro Finding-Typ enforced (JSON-Schema-Validierung)

### Klassifizierung

- Für generische Scraper (Geschäftsberichte, Presse): AI klassifiziert ob Inhalt relevant
- Label: `relevance_score` + `topics` (Tags)
- Nur relevante Findings landen in Review-Queue

### Confidence-Berechnung

Pro Finding wird `confidence_score` berechnet:
- Regel-basierte Signale: HTML-Struktur-Match, Feld-Vollständigkeit (z.B. Email + Telefon vorhanden)
- AI-Confidence: LLM-Output-Probability
- Source-Vertrauen: Handelsregister = 0.95, LinkedIn-Scrape = 0.70, generischer Web-Scrape = 0.60
- Kombiniert als gewichtete Summe

### Review-Priority-Assignment (NEU v0.3, Peter-Klarstellung 14.04.)

Beim Insert in `fact_scraper_findings` wird zusätzlich zum `confidence_score` das Feld `review_priority` gesetzt:

```
IF confidence_score >= 0.60:
  review_priority = 'standard'
ELSE:
  review_priority = 'needs_am_review'  -- Low Confidence, aber NICHT auto-verworfen
END
```

**Wichtig:** Low-Confidence-Findings (< 60%) werden **nicht automatisch verworfen**. Sie landen mit `review_priority='needs_am_review'` in der Queue und werden visuell markiert (amber Warning-Bar in Card, rote/orange Confidence-Badge). AM muss explizit entscheiden.

**Gegensatz zu früherer Variante:** Ursprünglich war im Audit ein "< 60% auto-reject" diskutiert worden. Peter-Entscheidung 14.04.: **alle Findings im Review-Flow halten, nichts automatisch verwerfen.**

**SLA & Eskalation (needs_am_review-Queue):**

| Alter | Aktion | Responsible |
|-------|--------|-------------|
| 0–3 Tage | Queue-Standard, keine Notif | AM |
| 4 Tage | Reminder an Account-AM (Dashboard-Badge + Email-Daily-Digest) | `stale-notification.worker.ts` |
| 7 Tage | Eskalation an Admin (Notification + Review-Queue-Filter) | Admin |
| 14 Tage | Auto-Archivierung mit Status `expired_unreviewed`, weiterhin in History sichtbar | Cron `scraper-finding-archiver.worker.ts` |

Implementierung: `fact_scraper_findings.review_priority_escalated_at` + `review_status` ENUM erweitern um `expired_unreviewed`.

### Firmengruppen-UID-Matching-Schwellen (NEU v0.3)

Für Finding-Typ `group_suggestion`:
- ≥ 85%: Auto-Suggestion (standard Review-Queue)
- 60-84%: Standard-Review-Queue
- < 60%: `review_priority='needs_am_review'` — Confidence aus Name-Ähnlichkeit + Hauptsitz-Match ohne UID-Root-Exakt-Match

---

## TEIL 12: DATA-QUALITY-REVIEW

### Duplicate-Detection

Vor Insert in Review-Queue:
- `new_contact`: Check gegen `dim_candidates_profile.email` + Name+Function
- `new_vacancy`: Check gegen `fact_jobs.title` + `account_id` + `location_id`
- `person_job_change`: Check ob bereits bekannter Wechsel (nicht nochmal fleggen)

### Stammdaten-Check (SC-15)

Periodischer Check:
- `website_url` erreichbar? (HTTP HEAD)
- `employee_count` — Abweichung > 20% vom letzten Scrape → Finding `stammdaten_drift`
- `founded_year` — Korrektur aus Handelsregister

---

## TEIL 13: EVENTS

Vollständige Event-Liste (13):

| Event | Scope |
|-------|-------|
| `scraper_run_started` | Run |
| `scraper_run_finished` | Run |
| `scraper_run_failed` | Run |
| `scraper_run_retried` | Run |
| `finding_detected` | Finding + Run |
| `finding_accepted` | Finding + resulting Entity (Account/Kontakt/Job/Kandidat) |
| `finding_rejected` | Finding |
| `finding_marked_low_confidence` *(NEU v0.3)* | Finding (wenn `review_priority='needs_am_review'` gesetzt) |
| `config_changed` | Scraper-Typ-Config |
| `alert_raised` | Alert |
| `alert_acknowledged` / `alert_dismissed` | Alert |
| `auto_disable_triggered` | Scraper-Typ |
| `protection_violation_detected` | Alert + Kandidat + Account/Gruppe |
| `anomaly_detected` | Alert + Account |

---

## TEIL 14: VERKNÜPFUNGEN

### Zu Accounts
- Scraper-Config in Account-Tab 7
- Findings (Kontakt, Vakanz, Stammdaten) landen am Account
- Account-History bekommt `finding_accepted`-Events

### Zu Jobs
- Scraper-Proposal als Job mit `status='scraper_proposal'`

### Zu Kandidaten
- Job-Wechsel-Detection → Kandidat-History-Update
- Schutzfrist-Match-Trigger

### Zu Firmengruppen
- UID-Match-Basierter Vorschlag

### Zu Mandaten
- Indirekt über Schutzfrist-Match bei Vorstellungen aus aktiven Mandaten

---

## TEIL 15: PHASE 1.5 / PHASE 2

| Feature | Phase |
|---------|-------|
| LinkedIn-Scraper (legal, API-Access, Cost) | 2 |
| Auto-Accept-Schwelle konfigurierbar pro Finding-Typ | 1.5 |
| AI-Prompt-Tuning basierend auf Rejection-Gründen | 1.5 |
| Failover bei HTML-Struktur-Änderungen (selbstheilend) | 1.5 |
| Multi-Tenant-Rate-Limit-Strategie | 2 |
| Cost-Tracking (AI-Tokens, API-Kosten pro Tenant) | 2 |
| Market-Intelligence-Dashboard (aggregierte Branchen-Trends) | 2 |
| Konkurrenz-Monitoring (automatische Erkennung von Konkurrenz-Dienstleistern bei Kunden) | 2 |

---

## TEIL 16: METHODIK-REFERENZ

- Event-System wie in [[event-system]]
- Berechtigungen wie in [[berechtigungen]]
- Audit-Logging für alle Config-Änderungen und Acceptances

---

## Related Specs / Wiki

- `ARK_SCRAPER_MODUL_SCHEMA_v0_1.md`
- `ARK_ACCOUNT_DETAILMASKE_INTERACTIONS_v0_3.md` Tab 7, Tab 3, Tab 9
- `ARK_JOB_DETAILMASKE_INTERACTIONS_v0_1.md` (Scraper-Proposal-Confirmation)
- `ARK_FIRMENGRUPPE_DETAILMASKE_INTERACTIONS_v0_1.md`
- `ARK_MANDAT_DETAILMASKE_INTERACTIONS_v0_3.md` TEIL 10
- [[scraper]], [[direkteinstellung-schutzfrist]], [[event-system]], [[ai-system]]
- [[detailseiten-guideline]], [[detailseiten-nachbearbeitung]]
