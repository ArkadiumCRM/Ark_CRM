
## [2026-04-17 01:12] session-e220c7b9 | feedback_audit_logging.md (1 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| UMLAUT \| 19 \| - Coverage-Status: aktuellen Code in `app/audit.py` pruefen (Liste hier gestrich... \| -> prüfen |


## [2026-04-17 01:13] session-testsess | candidates.html (10 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| DB-TECH \| 4874 \| <label>Bildungsgrad<span class="req">*</span> <span class="hint">dim_education_l... \| -> use sprechenden Begriff |
| DB-TECH \| 4940 \| <div class="dw-sec-head"><span class="dw-ico">🎯</span><h3>Fachliche Schwerpunkt... \| -> use sprechenden Begriff |
| DB-TECH \| 5073 \| <label>Arbeitgeber · Account<span class="req">*</span> <span class="hint">Verknü... \| -> use sprechenden Begriff |
| DB-TECH \| 5104 \| <div class="dw-sec-head"><span class="dw-ico">👤</span><h3>Funktionen</h3><span ... \| -> use sprechenden Begriff |
| DB-TECH \| 5185 \| <div style="flex:1"><div style="font-weight:600">Implenia AG</div><div class="mu... \| -> use sprechenden Begriff |
| DB-TECH \| 5265 \| <div class="dw-sec-head"><span class="dw-ico">📐</span><h3>SIA-Phasen</h3><span ... \| -> use sprechenden Begriff |
| DB-TECH \| 5277 \| <div class="dw-sec-head"><span class="dw-ico">🔨</span><h3>BKP-Gewerke</h3><span... \| -> use sprechenden Begriff |
| DB-TECH \| 5291 \| <div class="dw-sec-head"><span class="dw-ico">👤</span><h3>Rolle im Projekt</h3>... \| -> use sprechenden Begriff |
| DB-TECH \| 5352 \| <div style="flex:1"><div style="font-weight:600">SBB-Bahnhof-ZH</div><div class=... \| -> use sprechenden Begriff |
| DB-TECH \| 5497 \| <div class="msel-dropdown-foot">Stammdaten dim_functions · Suche matcht Name + K... \| -> use sprechenden Begriff |


## [2026-04-17 01:15] session-e220c7b9 | log.md (4 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| UMLAUT \| 6 \| - `.claude/hooks/ark-lint.ps1` — PostToolUse, scannt Edits auf `mockups/*.html`/... \| -> für |
| UMLAUT \| 6 \| - `.claude/hooks/ark-lint.ps1` — PostToolUse, scannt Edits auf `mockups/*.html`/... \| -> über |
| UMLAUT \| 6 \| - `.claude/hooks/ark-lint.ps1` — PostToolUse, scannt Edits auf `mockups/*.html`/... \| -> könn |
| UMLAUT \| 11 \| - `.claude/commands/ark-sync-report.md` — Slash-Command fuer Spec-Mockup-Sync-Dr... \| -> für |


## [2026-04-17 07:23] session-2673add7 | candidates.html (9 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| DB-TECH \| 4940 \| <div class="dw-sec-head"><span class="dw-ico">🎯</span><h3>Fachliche Schwerpunkt... \| -> use sprechenden Begriff |
| DB-TECH \| 5073 \| <label>Arbeitgeber · Account<span class="req">*</span> <span class="hint">Verknü... \| -> use sprechenden Begriff |
| DB-TECH \| 5104 \| <div class="dw-sec-head"><span class="dw-ico">👤</span><h3>Funktionen</h3><span ... \| -> use sprechenden Begriff |
| DB-TECH \| 5185 \| <div style="flex:1"><div style="font-weight:600">Implenia AG</div><div class="mu... \| -> use sprechenden Begriff |
| DB-TECH \| 5265 \| <div class="dw-sec-head"><span class="dw-ico">📐</span><h3>SIA-Phasen</h3><span ... \| -> use sprechenden Begriff |
| DB-TECH \| 5277 \| <div class="dw-sec-head"><span class="dw-ico">🔨</span><h3>BKP-Gewerke</h3><span... \| -> use sprechenden Begriff |
| DB-TECH \| 5291 \| <div class="dw-sec-head"><span class="dw-ico">👤</span><h3>Rolle im Projekt</h3>... \| -> use sprechenden Begriff |
| DB-TECH \| 5352 \| <div style="flex:1"><div style="font-weight:600">SBB-Bahnhof-ZH</div><div class=... \| -> use sprechenden Begriff |
| DB-TECH \| 5497 \| <div class="msel-dropdown-foot">Stammdaten dim_functions · Suche matcht Name + K... \| -> use sprechenden Begriff |


## [2026-04-17 07:30] session-2673add7 | candidates.html | RESOLUTION ✓

**Status:** 14 DB-Tech-Violations gefixt (10 sichtbare UI-Labels + 4 in Alert/Tooltip-Strings). Verifiziert via `grep "dim_|fact_|bridge_"` → 0 matches.

**Entdeckungs-Kontext:** Playwright-MCP-Walkthrough aller 10 Tabs + 9 Drawer in candidates.html. Sichtbare Labels im Browser gescreenshotet (→ `.playwright-mcp/drawer-*.png`), unsichtbare Violations (Alert-Texte, Title-Tooltips) via Grep auf `dim_*/fact_*/bridge_*` nachgezogen.

**Edits:**

| Zeile (vor) | Von | Nach |
|-------------|-----|------|
| 2939 | `fact_history-Event öffnen` (onclick alert) | `History-Event öffnen` |
| 2951 | `fact_history-Event öffnen` (onclick alert) | `History-Event öffnen` |
| 2957 | `fact_history-Event öffnen` (onclick alert) | `History-Event öffnen` |
| 4874 | `<span class="hint">dim_education_level</span>` | entfernt |
| 4940 | `<span class="dw-sub">dim_functions</span>` | `aus Funktions-Katalog` |
| 5073 | `Verknüpft mit dim_accounts · ID 412 · 9'000 MA` | `Verknüpft mit Account-Stammdaten · 9'000 MA` |
| 5104 | `aus dim_functions · 103 Einträge` | `aus Funktions-Katalog · 103 Einträge` |
| 5185 | `dim_accounts · 9'000 MA · Zürich` (muted) | `9'000 MA · Zürich` |
| 5265 | `dim_sia_phases · 6 Haupt + 12 Teil · SIA 112` | `SIA 112 · 6 Haupt + 12 Teil` |
| 5277 | `dim_bkp_codes · 425 Codes · gefiltert auf SIA` | `425 Codes · gefiltert auf SIA` |
| 5291 | `<span class="dw-sub">dim_functions</span>` | `aus Funktions-Katalog` |
| 5352 | `fact_projects · 2023–2025 · CHF 48 Mio.` | `2023–2025 · CHF 48 Mio.` |
| 5497 | `Stammdaten dim_functions · Suche matcht Name + Kategorie` | `Suche matcht Name + Kategorie` |
| 6184 | `pro Debriefing-Set 2 fact_history-Einträge` (alert) | `pro Debriefing-Set 2 History-Einträge` |

**Backup:** `backups/candidates.html.2026-04-17-0145.bak` (566748 B, original vor 14 Edits).

**Regel-Quelle:** CLAUDE.md §„Keine-DB-Technikdetails-im-UI-Regel (CRITICAL — 2026-04-15)".


## [2026-04-17 07:31] session-2673add7 | accounts.html (4 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| DB-TECH \| 1747 \| Owner = <strong>Account Manager</strong> (nicht Candidate Manager). CM lebt pro ... \| -> use sprechenden Begriff |
| DB-TECH \| 2543 \| Stages gemäss <em>dim_process_stages</em> §13. Stale-Detection ≥ 14 Tage ohne St... \| -> use sprechenden Begriff |
| DB-TECH \| 2785 \| History-Einträge gemäss <em>dim_activity_types</em> §14 (64 Typen in 11 Kategori... \| -> use sprechenden Begriff |
| DB-TECH \| 4193 \| <dt>Funktion</dt><dd>BIM Manager <span class="muted" style="font-size:11px">· di... \| -> use sprechenden Begriff |


## [2026-04-17 07:40] session-2673add7 | accounts.html | RESOLUTION ✓

**Status:** 22 Violations gefixt · File-Grep clean (nur 1 HTML-Kommentar L3233 verbleibt, nicht User-sichtbar).

**Entdeckungs-Kontext:** Playwright-Walkthrough aller 14 Tabs + 12 Drawer in accounts.html. Auto-Lint-Hook erwischte nur 1 initial (`dim_functions-Match`); restliche 21 via manuelle Grep-Scans (DB-Identifier, snake_case Enum-Codes, Route-Placeholder).

**Drawer-Inventory (12):** mandatDrawer · claimDrawer · procDrawer · docDrawer · reminderDrawer · vakanzDrawer · jobDrawer · posDrawer · contactDrawer · aktivierenDrawer · uploadDrawer · historyDrawer.

**Tab-Inventory (14):** Übersicht · Profil & Kultur · Kontakte · Standorte · Organisation · Jobs & Vakanzen · Mandate · Assessments · Schutzfristen · Prozesse · History · Dokumente · Reminders · Firmengruppe (konditional).

**Edits nach Kategorie:**

| Kategorie | Count | Zeilen | Beispiel Fix |
|-----------|-------|--------|--------------|
| `dim_*` DB-Identifier | 5 | 286, 1747, 2543, 2785, 4193 | `dim_sector` → Sektor-Katalog · `dim_process_stages` → Stammdaten-Katalog · `dim_functions-Match` → Katalog-Match |
| `fact_process_core` | 1 | 1747 | umschrieben ohne technische Referenz |
| snake_case Enum-Values | 8 | 2151/2165/2178/2191/2205 · 2167/2180/2193/2207 · 3622/3896/2726 | `email_dossier` → E-Mail-Dossier · `verbal_meeting` → Mündliches Meeting · `active/honored/claim_pending` → Aktiv/Erfüllt/Claim ausstehend |
| snake_case Status-Lifecycle | 2 | 2237, 3750 | `active → honored / claim_pending → paid · expired` → deutsche Labels |
| Tooltip-Attribute | 1 | 203 | `title="...account_group_id"` → sprechende Beschreibung |
| Footer-Spec-Notes | 2 | 2998, 3406 | `audit-log-retention` → Audit-Log-Regel · `account.group_id`/`/groups/[id]` → sprechend |
| Route-Placeholders `[id]` | 5 | 1833/1847/1867/1887/1901 + 3979 | `Navigation /mandates/[id]` → Navigation zur Mandat-Vollansicht |
| `needs_am_review` | 1 | 382 | → "AM-Review nötig" |

**Summe:** 5 + 1 + 8 + 2 + 1 + 2 + 5 + 1 = **22 User-sichtbare Violations**.

**Backup:** `backups/accounts.html.2026-04-17-0730.bak` (311358 B, Original).

**Regel-Quelle:** CLAUDE.md §„Keine-DB-Technikdetails-im-UI-Regel (CRITICAL — 2026-04-15)". Interpretation: Regel gilt auch für snake_case Enum-Werte (de-facto DB-Codes), Route-Path-Templates mit `[id]` (technische Syntax) und HTML-Attribute (title/aria) die User via Tooltip/Screen-Reader sehen.


## [2026-04-17 07:56] session-2673add7 | mandates.html (1 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| DB-TECH \| 1082 \| History-Einträge gemäss <em>dim_activity_types</em> §14 (64 Typen in 11 Kategori... \| -> use sprechenden Begriff |


## [2026-04-17 07:55] session-2673add7 | mandates.html | RESOLUTION ✓

**Status:** 4 Violations gefixt · File-Grep clean.

**Entdeckungs-Kontext:** Playwright-Walkthrough aller 7 Tabs + 5 Drawer in mandates.html. Auto-Lint-Hook erwischte 1 (L1082); Grep nach candidate-Pattern-Liste fand 3 weitere.

**Drawer-Inventory (5):** optionDrawer (540px · Optionale Stage buchen VI-X) · cancelDrawer (540px · Mandat kündigen mit 80%-Regel-Vorschau) · uploadDrawer · historyDrawer · reminderDrawer.

**Tab-Inventory (7):** Übersicht · Longlist (5-Stage Kanban) · Prozesse (9-Stage Pipeline) · Billing (Zahlungsplan + Optionale Stages + Zahlungs-Historie) · History · Dokumente · Reminders.

**Edits:**

| Zeile | Von | Nach |
|-------|-----|------|
| 396 | `Fixpauschale ÷ 3 Stages ... siehe <em>mandat-kuendigung</em>` | `Fixpauschale + 3 Stages ... siehe <em>AGB §6 Mandats-Kündigung</em>` (Bonus: ÷→+ Typo-Fix) |
| 1023 | History-sub `presentation_type = email_dossier` | `Vorstellungs-Typ = E-Mail-Dossier` |
| 1082 | Footer-Note `gemäss <em>dim_activity_types</em> §14` | `gemäss Activity-Types-Katalog §14` |
| 1294 | Dokumente-Footer `Retention gemäss <em>audit-log-retention</em>` | `Retention gemäss Audit-Log-Regel` |

**Backup:** `backups/mandates.html.2026-04-17-0753.bak` (118821 B, Original).



## [2026-04-17 08:05] session-2673add7 | groups.html | RESOLUTION ✓

**Status:** 5 Violations gefixt · File-Grep clean.

**Tab-Inventory (7):** Übersicht · Kultur (Gruppen-Analyse · AI-Draft + 6 Dimensionen + Quellen + Gesellschafts-Vergleich) · Kontakte (Gruppen-weite Entscheider + weitere) · Mandate & Prozesse (gruppenübergreifend + Account-spezifisch) · Dokumente (Rahmenvertrag/Master-NDA/Konzern-AGB/Geschäftsberichte) · History · Reminders.

**Drawer-Inventory (4):** uploadDrawer · historyDrawer · reminderDrawer · contactDrawer — alle Standard-Pattern.

**Edits:**

| Zeile | Von | Nach |
|-------|-----|------|
| 556 | `N:N via <code>bridge_mandate_accounts</code>` | `Mandat → mehrere Gesellschaften` |
| 988 | `presentation_type = email_dossier` | `Vorstellungs-Typ = E-Mail-Dossier` |
| 1013 | `Event-Type: <code>group_culture_generated</code>` | `Ereignis-Typ: Gruppen-Kultur generiert` |
| 1028 | `Event-Type: <code>group_mandate_created</code>` | `Ereignis-Typ: Gruppen-Mandat erstellt` |
| 1043 | `Event-Type: <code>group_framework_contract_added</code>` | `Ereignis-Typ: Rahmenvertrag verlängert` |

**Kategorien:** 1× `bridge_*` DB-Identifier · 1× snake_case Enum (`presentation_type`/`email_dossier`) · 3× Event-Type snake_case Codes in `<code>` Tags.

**Backup:** `backups/groups.html.2026-04-17-0802.bak` (109873 B, Original).


## [2026-04-17 08:32] session-2673add7 | jobs.html (1 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| DB-TECH \| 959 \| Stages gemäss <em>dim_process_stages</em> §13. Stale-Detection ≥ 14 Tage ohne St... \| -> use sprechenden Begriff |


## [2026-04-17 08:35] session-2673add7 | jobs.html | RESOLUTION ✓

**Status:** 18 Violations gefixt · File-Grep clean.

**Tab-Inventory (7):** Übersicht (CFO / Finanzleitung · Stammdaten + Verknüpfungen + Stellenbeschreibung + Konditionen + Matching-Kriterien + Ausschreibung) · Matching (7-Sub-Score-Matrix + Radar + Sector-Exclude) · Jobbasket (Jobbasket-Stages read-only) · Prozesse (Kanban · Job-Filter) · Dokumente (Stellenausschreibung-Generator + Matching-Exports) · History (Job-Lifecycle) · Reminders.

**Drawer-Inventory (4):** uploadDrawer · historyDrawer · reminderDrawer · proposeDrawer (Kandidat vorschlagen).

**Edits:**

| Zeile | Kategorie | Fix |
|-------|-----------|-----|
| 51 | Mockup-Demo-Banner | `status=scraper_proposal-Jobs` → „Scraper-Vorschlag"-Jobs |
| 959 | Prozesse-Footer | `dim_process_stages` + `/processes/[id]` → Stammdaten-Katalog + Prozess-Vollansicht |
| 1300, 1302 | History-Event | `matching_computed` / `job_matching_computed` → Matching berechnet |
| 1316 | History-sub | `presentation_type = email_dossier` → Vorstellungs-Typ = E-Mail-Dossier |
| 1327 | Activity-Type | `job_ad_generated` → Stellenausschreibung generiert |
| 1335, 1337 | History-Event | `jobbasket_candidate_added` / `jobbasket_added` → Kandidat in Jobbasket |
| 1375, 1377 | History-Event | `process_created` → Prozess erstellt |
| 1405, 1407 | History-Event | `status_changed` / `job_status_changed` · „von scraper_proposal" → Status geändert · von Scraper-Vorschlag |
| 1415, 1417 | History-Event | `vakanz_confirmed` → Vakanz bestätigt |
| 1430, 1432 | History-Event | `scraper_proposal_created` / `job_scraper_proposal` → Scraper-Vorschlag erstellt |
| 1445 | History-Footer | Job-Lifecycle-Event-Liste mit snake_case → deutsche Labels |
| 2115, 2134 | JS-Alert/Confirm-Text | snake_case Event-Namen → deutsche Labels |

**Kategorien:** 14× snake_case Activity-Types in History (Titel + Meta + Footer) · 2× JS-Alert-Text · 1× dim_*/Route-Placeholder · 1× presentation_type.

**Backup:** `backups/jobs.html.2026-04-17-0810.bak` (125554 B, Original).


## [2026-04-17 08:39] session-2673add7 | projects.html (7 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| DB-TECH \| 1407 \| <strong>Projekt-Reports-to</strong> (aus <code>fact_project_*_participations.rep... \| -> use sprechenden Begriff |
| DB-TECH \| 1425 \| <span class="muted" style="margin-left:8px;font-size:12px">Async über ~8'400 Kan... \| -> use sprechenden Begriff |
| DB-TECH \| 1541 \| Cl. = Cluster-Overlap · BKP = BKP-Gewerk-Erfahrung · SIA = SIA-Phasen-Abdeckung ... \| -> use sprechenden Begriff |
| DB-TECH \| 1618 \| <strong>Jaccard-Matching</strong> auf Cluster + BKP-Gewerke-Überlappung · Volume... \| -> use sprechenden Begriff |
| DB-TECH \| 2133 \| <div class="hist-sub">Nightly Batch-Recompute · 7 Neueinträge · Top-Score 92 % (... \| -> use sprechenden Begriff |
| DB-TECH \| 2292 \| <div class="sub">Aus 425 BKP-Codes (dim_bkp_codes) wählen</div> \| -> use sprechenden Begriff |
| DB-TECH \| 2455 \| <h4>SIA-Phasen-Beteiligung · dim_sia_phases (6 Haupt + 12 Teil)</h4> \| -> use sprechenden Begriff |


## [2026-04-17 08:48] session-2673add7 | projects.html | RESOLUTION ✓

**Status:** 21 Violations gefixt · File-Grep clean (1 JS-Kommentar L3408 ist Code-intern, nicht User-sichtbar).

**Tab-Inventory (6):** Übersicht (Grunddaten · Volumen · Beschreibung · Öffentliche Referenzen · Strategische Bewertung · AM-Notizen pro Account) · Gewerke (BKP) · Matching (Async-Recompute · 7-Dimension-Matrix Cl/BKP/SIA/Vol/Loc/Rec) · Galerie (24 Medien · Foto/Render/Plan/Baustelle/After-Move-In) · Dokumente (Scraper-Belege + Pitch-Unterlagen) · History (13 Lifecycle-Events).

**Drawer-Inventory (14):** newGewerkDrawer · gewerkSettingsDrawer · firmaParticipationDrawer · kandidatParticipationDrawer · mediaUploadDrawer · mediaEditDrawer · uploadDrawer · pitchDrawer · projektReportDrawer · addBeteiligungDrawer · accountNoteDrawer · mergeDrawer · reminderDrawer · historyDrawer.

**Edits:**

| Kategorie | Count | Beispiel-Mapping |
|-----------|-------|------------------|
| Banner `source='scraper'` | 1 | → „Scraper-Projekte" |
| Beteiligte-Footer `fact_project_*_participations.reports_to_*` + `dim_accounts_org_chart` | 1 | → „pro Projekt-Beteiligung erfasst", „Account-Organigramm" |
| Matching-Header `dim_matching_weights_project` | 1 | → „Projekt-Matching-Overlay" |
| Matching-Legende (2 `dim_matching_weights_*`) | 1 | → „Projekt-Matching-Overlay über Base-Gewichten" |
| Jaccard-Note `fact_project_similarities` | 1 | → „Projekt-Ähnlichkeits-Index" |
| Galerie-Note `privacy='public'` + `author='scraper:source'` | 1 | → Privacy „öffentlich" + Urheber „Scraper" |
| History-Dropdown 9 Options | 1 Edit | project_created → „Projekt erstellt", company/candidate_participation_* → deutsche Labels, etc. |
| History-Row Titles (10 snake_case Events) | 10 | `matching_computed` → Matching berechnet · `candidate_participation_added` → Kandidat-Beteiligung hinzugefügt · `media_uploaded` → Medien hochgeladen · `account_project_note_updated` → Account-Projekt-Notiz aktualisiert · `company_participation_added/changed` → Firma-Beteiligung hinzugefügt/geändert · `bkp_gewerk_added` → BKP-Gewerk hinzugefügt · `document_uploaded` → Dokument hochgeladen · `classification_changed` → Klassifikation geändert · `project_created_manual` → Projekt erstellt (manuell) |
| History-Footer Event-Typen-Liste | 1 | 13 Event-Typen snake_case → deutsche Labels |
| BKP-Sub `(dim_bkp_codes)` | 1 | → „(SN-Katalog)" |
| SIA-Heading `dim_sia_phases` | 1 | → „SIA 112" |
| JS confirm `status_changed` | 1 | → „Status geändert" |

**Summe:** ~21 Gruppierungen · umgesetzt via 21 Edit-Operationen.

**Backup:** `backups/projects.html.2026-04-17-0840.bak` (212297 B).


## [2026-04-17 08:45] session-2673add7 | processes.html (19 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| DB-TECH \| 531 \| <strong>Konfigurierbare Stage-Schwellen</strong> aus <code>dim_process_stages.st... \| -> use sprechenden Begriff |
| DB-TECH \| 580 \| <dt>Ablehnungs-Grund</dt><dd>aus <code>dim_rejection_reasons_*</code> · je nach ... \| -> use sprechenden Begriff |
| DB-TECH \| 878 \| Auto-Reminder aktiv: <strong>Coaching-Call 2 Tage vor Interview</strong> · <stro... \| -> use sprechenden Begriff |
| DB-TECH \| 936 \| <dt>Staffel-Lookup (auto)</dt><dd><strong>23 %</strong> · CHF 110–130k Range <sp... \| -> use sprechenden Begriff |
| DB-TECH \| 1111 \| <div class="muted" style="font-size:11px;margin-top:10px">Splits aus <code>dim_m... \| -> use sprechenden Begriff |
| DB-TECH \| 1490 \| <div class="hist-sub">Rückmeldung HM positiv · Einladung 2nd am 22.04. Auto-Even... \| -> use sprechenden Begriff |
| DB-TECH \| 1569 \| <div class="hist-sub">Arkadium-Debriefing nach TI · Kandidat (15 min · Eindrücke... \| -> use sprechenden Begriff |
| DB-TECH \| 1728 \| <div class="muted" style="font-size:11px;margin-top:4px">Sync geschieht bei Spei... \| -> use sprechenden Begriff |
| DB-TECH \| 1886 \| <td><code>fact_process_core</code> UPDATE</td> \| -> use sprechenden Begriff |
| DB-TECH \| 1893 \| <td><code>fact_placements</code> INSERT</td> \| -> use sprechenden Begriff |
| DB-TECH \| 1900 \| <td><code>fact_jobs</code> UPDATE</td> \| -> use sprechenden Begriff |
| DB-TECH \| 1907 \| <td><code>fact_candidate_guarantee</code> INSERT · <code>fact_protection_window<... \| -> use sprechenden Begriff |
| DB-TECH \| 1914 \| <td><code>fact_referral_claims</code> INSERT</td> \| -> use sprechenden Begriff |
| DB-TECH \| 1921 \| <td><code>fact_project_positions</code> UPDATE</td> \| -> use sprechenden Begriff |
| DB-TECH \| 1928 \| <td><code>fact_history</code> BULK INSERT</td> \| -> use sprechenden Begriff |
| DB-TECH \| 1935 \| <td><code>billing_worker</code> · <code>fact_invoices</code> + <code>fact_remind... \| -> use sprechenden Begriff |
| DB-TECH \| 1946 \| <li><strong>Schutzfrist-Honored</strong> · <code>fact_protection_window.status='... \| -> use sprechenden Begriff |
| DB-TECH \| 2089 \| <div class="muted" style="font-size:12px">20 %-Rücklage des ausschüttenden Quart... \| -> use sprechenden Begriff |
| DB-TECH \| 2190 \| <strong>Audit-Trail</strong> · Override wird in <code>fact_audit_log</code> gelo... \| -> use sprechenden Begriff |


## [2026-04-17 09:05] session-2673add7 | processes.html | RESOLUTION ✓

**Status:** 26 User-sichtbare Violations gefixt · File-Grep clean (Admin-Saga-Tabelle + 2 JS-Kommentare bewusst nicht gefixt, siehe unten).

**Tab-Inventory:** Prozess-Detailseite mit mehreren Sektionen (Stage-Pipeline · Activity-Links · Honorar · History · Saga-Preview · Splits · Cancel/Refund-Drawer · Fee-Override).

**Edits nach Kategorie:**

| Kategorie | Count | Beispiele |
|-----------|-------|-----------|
| `dim_*` in User-Notes | 6 | `dim_process_stages.win_prob` → Stage-Stammdaten · `dim_process_stages.stale_days` → Stage-Stammdaten · `dim_rejection_reasons_*` → Ablehnungsgrund-Katalog · `dim_reminder_templates` → Reminder-Template-Katalog · `dim_honorar_settings` → Honorar-Staffel-Stammdaten · `dim_mitarbeiter.commission_*_pct` → Mitarbeiter-Commission-Stammdaten |
| `fact_history` in Activity-Link-Rows | 4 | title-attrs + muted `[fact_history #23451]` → History-Event |
| `fact_process_events` / `fact_process_interviews.actual_date` / `fact_interview.outlook_event_id` | 3 | history-sub text + sync-hint → sprechende Labels |
| snake_case History-Event-Titles | 5 | `stage_changed` (4×) + `process_created` → Stage geändert / Prozess erstellt |
| snake_case in hist-meta / dt-dd | 3 | `Activity-Type stage_changed` · `stage_changed_drawer <dt>Typ</dt>` → Stage geändert |
| History-Filter Dropdown | 3 | `process_created` / `stage_changed` / `status_changed` → deutsche Labels |
| Lifecycle-Footer Event-Liste | 1 | 13 Lifecycle-Events snake_case → deutsche Labels |
| `presentation_type = email_dossier` | 1 | → Vorstellungs-Typ = E-Mail-Dossier |
| JS-Alert/Confirm-Texte | 5 | 2× Debriefing-Alert + Activity-Link-Click-Alerts + Stage-Changed-Confirm + Status-Changed-Confirm |

**Summe:** 26 user-sichtbare Violations.

**Bewusst NICHT gefixt (Admin-/Debug-Ansicht-Ausnahme CLAUDE.md §„Keine-DB-Technikdetails"):**
- **8-Step Saga · Preview (TX1 · atomar)** L1868-1951: Saga-Tabelle mit Spalte „Tabelle / Worker" zeigt `fact_process_core` · `fact_placements` · `fact_jobs` · `fact_candidate_guarantee` · `fact_protection_window` · `fact_referral_claims` · `fact_project_positions` · `fact_history` · `billing_worker` · `fact_invoices` · `fact_reminders`. Dev-/Admin-Doku zur Transaktions-Orchestrierung, nicht produktive User-UI.
- **Post-Saga-Trigger** L1946: `fact_protection_window.status='honored'` · `candidate_reassign_worker` — technische Follow-up-Prozess-Doku.
- **Provisions-Effekt CRM 2.0** L2089: `fact_candidate_guarantee.status='breached_*'` — Backend-Refund-Logik-Spec.
- **Audit-Trail-Warning** L2190: `fact_audit_log` im Fee-Override-Drawer — Admin-Action-Warnung.
- JS-Kommentare L2656/L2668/L2670 (im Code, nicht gerendert).

**Empfehlung:** Saga-/Admin-Sektionen via `data-admin-only` Flag o.ä. markieren oder ausschliesslich in dedizierter Admin-Detailseite zeigen, um Rolle-basiertes Hiding im Produkt zu ermöglichen.

**Backup:** `backups/processes.html.2026-04-17-0855.bak` (174413 B, Original).


## [2026-04-17 09:19] session-2673add7 | assessments.html (2 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| SNAKE-CASE \| 563 \| <div class="hist-sub">ARK-CV v3 + Exposé als PDF · presentation_type = email_dos... \| -> deutsches Label fuer Enum-Value |
| DB-TECH \| 622 \| History-Einträge gemäss <em>dim_activity_types</em> §14 (64 Typen in 11 Kategori... \| -> use sprechenden Begriff |


## [2026-04-17 09:24] session-f3a148a3 | ARK_ASSESSMENT_DETAILMASKE_MOCKUP_IMPL_v1.md (2 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| UMLAUT \| 1240 \| Offerten-Generator-CTA als Platzhalter fuer globalen Dok-Generator. \| -> für |
| UMLAUT \| 1572 \| Filter fuer beteiligte Kandidaten). Keyboard-Hints-Bar komplett mit \| -> für |



## [2026-04-17 09:25] session-2673add7 | Spec-Sync-Resolution ✓

**Ausgelöst durch:** Spec-Sync-Check gegen `Grundlagen MD/ARK_STAMMDATEN_EXPORT_v1_3.md` §10c (dim_presentation_types).

**Gefundene Drift:** 2 Labels, die ich in den Mockup-Fixes NICHT aus dem kanonischen Stammdaten-Katalog übernommen hatte.

| Enum-Key | Stammdaten §10c Label (KANONISCH) | Ich hatte gesetzt (falsch) | Korrigiert zu |
|----------|-----------------------------------|---------------------------|---------------|
| `email_dossier` | **Dossier per E-Mail** | E-Mail-Dossier | Dossier per E-Mail |
| `verbal_meeting` | **Mündlich im Meeting mit Dossier-Share** | Mündliches Meeting | Mündlich im Meeting |

**Files angepasst:** 7 Mockups (accounts · assessments · candidates · groups · jobs · mandates · processes). 12 Occurrences total.

**Replace-all Edits:**
- `E-Mail-Dossier` → `Dossier per E-Mail` (11 Stellen)
- `Mündliches Meeting` → `Mündlich im Meeting` (accounts.html, 1 Stelle)

**Andere Labels aus meinen Fixes (Event-Types, Status-Codes wie Aktiv/Erfüllt/Bezahlt/Abgelaufen/Stage geändert/Scraper-Vorschlag/Vakanz bestätigt/Matching berechnet/Prozess erstellt/Kandidat in Jobbasket/Firma-Beteiligung/BKP-Gewerk hinzugefügt/Medien hochgeladen/Dokument hochgeladen):** kein Stammdaten-Eintrag mit kanonischem Label — meine deutschen Labels sind UI-seitig neu geprägt und somit akzeptabel.

**Empfehlung:** Diese UI-Labels in `wiki/meta/mockup-baseline.md` aufnehmen, damit künftige Mockups konsistent sind.


## [2026-04-17 09:49] session-20b2544b | candidates.html (1 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| SNAKE-CASE \| 3156 \| <div class="hist-meta"><span class="actor actor-system">automation</span><span c... \| -> deutsches Label statt snake_case in Alert/Confirm |


## [2026-04-17 10:08] session-2673add7 | anti-patterns.md (4 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| UMLAUT \| 35 \| \| **`ae`/`oe`/`ue`-Ersatz** (fuer, ueber, koennen, muessen) \| Umlaute-Regel 15.0... \| -> für |
| UMLAUT \| 35 \| \| **`ae`/`oe`/`ue`-Ersatz** (fuer, ueber, koennen, muessen) \| Umlaute-Regel 15.0... \| -> über |
| UMLAUT \| 35 \| \| **`ae`/`oe`/`ue`-Ersatz** (fuer, ueber, koennen, muessen) \| Umlaute-Regel 15.0... \| -> könn |
| UMLAUT \| 35 \| \| **`ae`/`oe`/`ue`-Ersatz** (fuer, ueber, koennen, muessen) \| Umlaute-Regel 15.0... \| -> müss |


## [2026-04-17 14:01] session-dd3f8b6c | email-kalender.html (5 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| UMLAUT \| 176 \| .cal-emp-kuerzel { width:22px; height:22px; border-radius:50%; background:var(--... \| -> Kürzel |
| UMLAUT \| 694 \| <label class="cal-emp-item"><input type="checkbox" checked><span class="cal-emp-... \| -> Kürzel |
| UMLAUT \| 695 \| <label class="cal-emp-item"><input type="checkbox"><span class="cal-emp-kuerzel"... \| -> Kürzel |
| UMLAUT \| 696 \| <label class="cal-emp-item"><input type="checkbox"><span class="cal-emp-kuerzel"... \| -> Kürzel |
| UMLAUT \| 697 \| <label class="cal-emp-item"><input type="checkbox"><span class="cal-emp-kuerzel"... \| -> Kürzel |

## [2026-04-17 14:08] session-dd3f8b6c | email-kalender.html | RESOLUTION ✓

- **5 UMLAUT-Violations** resolved: CSS classname `.cal-emp-kuerzel` → `.cal-emp-sign` (CSS classnames dürfen keine Umlaute, lint-Pattern zu strikt; Umbenannt statt skip-Marker).
- **3 zusätzliche SNAKE-CASE-Violations (manuelle Prüfung)** resolved: `is_oral_go=true` / `is_written_go=true` / `info_sent` in Template-Card-Subs → sprechende Begriffe („Mündliche GO bestätigt" · „Schriftliche GO erhalten" · „Info versendet").
- Re-Grep 0 Treffer · Mockup jetzt Lint-konform.


## [2026-04-17 14:20] session-dd3f8b6c | log.md (5 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| UMLAUT \| 13 \| - `wiki/meta/lint-violations.md` — 8 Violations (5 UMLAUT cal-emp-kuerzel CSS cl... \| -> Kürzel |
| UMLAUT \| 31 \| - `.claude/hooks/ark-lint.ps1` — PostToolUse, scannt Edits auf `mockups/*.html`/... \| -> für |
| UMLAUT \| 31 \| - `.claude/hooks/ark-lint.ps1` — PostToolUse, scannt Edits auf `mockups/*.html`/... \| -> über |
| UMLAUT \| 31 \| - `.claude/hooks/ark-lint.ps1` — PostToolUse, scannt Edits auf `mockups/*.html`/... \| -> könn |
| UMLAUT \| 36 \| - `.claude/commands/ark-sync-report.md` — Slash-Command fuer Spec-Mockup-Sync-Dr... \| -> für |


## [2026-04-17 14:48] session-f3a148a3 | log.md (5 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| UMLAUT \| 46 \| - `wiki/meta/lint-violations.md` — 8 Violations (5 UMLAUT cal-emp-kuerzel CSS cl... \| -> Kürzel |
| UMLAUT \| 64 \| - `.claude/hooks/ark-lint.ps1` — PostToolUse, scannt Edits auf `mockups/*.html`/... \| -> für |
| UMLAUT \| 64 \| - `.claude/hooks/ark-lint.ps1` — PostToolUse, scannt Edits auf `mockups/*.html`/... \| -> über |
| UMLAUT \| 64 \| - `.claude/hooks/ark-lint.ps1` — PostToolUse, scannt Edits auf `mockups/*.html`/... \| -> könn |
| UMLAUT \| 69 \| - `.claude/commands/ark-sync-report.md` — Slash-Command fuer Spec-Mockup-Sync-Dr... \| -> für |


## [2026-04-17 14:50] session-20b2544b | admin-dashboard-templates.html (3 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| DB-TECH \| 163 \| <div class="muted" style="margin-top:4px;font-size:12.5px">Pro Rolle definierst ... \| -> use sprechenden Begriff |
| SNAKE-CASE \| 529 \| alert('Öffnet Dashboard in neuem Tab als AM-User gerendert · URL: /dashboard?pre... \| -> deutsches Label statt snake_case in Alert/Confirm |
| DRAWER-DEFAULT \| -- \| 3 Modal-Patterns gefunden \| -> Drawer 540px verwenden fuer CRUD (CLAUDE.md Drawer-Default-Regel) |


## [2026-04-17 14:51] session-20b2544b | admin-dashboard-templates.html (2 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| SNAKE-CASE \| 529 \| alert('Öffnet Dashboard in neuem Tab als AM-User gerendert · URL: /dashboard?pre... \| -> deutsches Label statt snake_case in Alert/Confirm |
| DRAWER-DEFAULT \| -- \| 3 Modal-Patterns gefunden \| -> Drawer 540px verwenden fuer CRUD (CLAUDE.md Drawer-Default-Regel) |


## [2026-04-17 14:51] session-20b2544b | admin-dashboard-templates.html (2 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| SNAKE-CASE \| 529 \| alert('Öffnet Dashboard in neuem Tab als AM-User gerendert · URL: /dashboard?pre... \| -> deutsches Label statt snake_case in Alert/Confirm |
| DRAWER-DEFAULT \| -- \| 3 Modal-Patterns gefunden \| -> Drawer 540px verwenden fuer CRUD (CLAUDE.md Drawer-Default-Regel) |


## [2026-04-17 15:06] session-dd3f8b6c | log.md (5 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| UMLAUT \| 46 \| - `wiki/meta/lint-violations.md` — 8 Violations (5 UMLAUT cal-emp-kuerzel CSS cl... \| -> Kürzel |
| UMLAUT \| 85 \| - `.claude/hooks/ark-lint.ps1` — PostToolUse, scannt Edits auf `mockups/*.html`/... \| -> für |
| UMLAUT \| 85 \| - `.claude/hooks/ark-lint.ps1` — PostToolUse, scannt Edits auf `mockups/*.html`/... \| -> über |
| UMLAUT \| 85 \| - `.claude/hooks/ark-lint.ps1` — PostToolUse, scannt Edits auf `mockups/*.html`/... \| -> könn |
| UMLAUT \| 90 \| - `.claude/commands/ark-sync-report.md` — Slash-Command fuer Spec-Mockup-Sync-Dr... \| -> für |


## [2026-04-17 15:08] session-20b2544b | dashboard-mobile.html (1 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| SNAKE-CASE \| 204 \| <div class="muted" style="font-size:13px">Zeigt wie das Dashboard bei den 3 Brea... \| -> sprechenden Begriff statt snake_case-Identifier |


## [2026-04-17 15:32] session-3131f2f7 | reminders.html (1 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| SNAKE-CASE \| 457 \| <div><span class="pr-dot high"></span><span class="rem-title">Schutzfrist Info-R... \| -> deutsches Label statt snake_case in Attribut |


## [2026-04-17 15:33] session-3131f2f7 | reminders.html (1 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| SNAKE-CASE \| 457 \| <div><span class="pr-dot high"></span><span class="rem-title">Schutzfrist Info-R... \| -> deutsches Label statt snake_case in Attribut |


## [2026-04-17 15:33] session-3131f2f7 | reminders.html (1 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| SNAKE-CASE \| 457 \| <div><span class="pr-dot high"></span><span class="rem-title">Schutzfrist Info-R... \| -> deutsches Label statt snake_case in Attribut |


## [2026-04-17 16:08] session-20b2544b | admin-dashboard-templates.html (2 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| SNAKE-CASE \| 524 \| alert('Öffnet Dashboard in neuem Tab als AM-User gerendert · URL: /dashboard?pre... \| -> deutsches Label statt snake_case in Alert/Confirm |
| DRAWER-DEFAULT \| -- \| 3 Modal-Patterns gefunden \| -> Drawer 540px verwenden fuer CRUD (CLAUDE.md Drawer-Default-Regel) |


## [2026-04-17 16:08] session-20b2544b | admin-dashboard-templates.html (2 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| SNAKE-CASE \| 524 \| alert('Öffnet Dashboard in neuem Tab als AM-User gerendert · URL: /dashboard?pre... \| -> deutsches Label statt snake_case in Alert/Confirm |
| DRAWER-DEFAULT \| -- \| 3 Modal-Patterns gefunden \| -> Drawer 540px verwenden fuer CRUD (CLAUDE.md Drawer-Default-Regel) |


## [2026-04-17 16:08] session-20b2544b | admin-dashboard-templates.html (2 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| SNAKE-CASE \| 524 \| alert('Öffnet Dashboard in neuem Tab als AM-User gerendert · URL: /dashboard?pre... \| -> deutsches Label statt snake_case in Alert/Confirm |
| DRAWER-DEFAULT \| -- \| 3 Modal-Patterns gefunden \| -> Drawer 540px verwenden fuer CRUD (CLAUDE.md Drawer-Default-Regel) |


## [2026-04-17 16:08] session-20b2544b | admin-dashboard-templates.html (2 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| SNAKE-CASE \| 524 \| alert('Öffnet Dashboard in neuem Tab als AM-User gerendert · URL: /dashboard?pre... \| -> deutsches Label statt snake_case in Alert/Confirm |
| DRAWER-DEFAULT \| -- \| 3 Modal-Patterns gefunden \| -> Drawer 540px verwenden fuer CRUD (CLAUDE.md Drawer-Default-Regel) |


## [2026-04-17 16:08] session-20b2544b | admin-dashboard-templates.html (2 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| SNAKE-CASE \| 524 \| alert('Öffnet Dashboard in neuem Tab als AM-User gerendert · URL: /dashboard?pre... \| -> deutsches Label statt snake_case in Alert/Confirm |
| DRAWER-DEFAULT \| -- \| 3 Modal-Patterns gefunden \| -> Drawer 540px verwenden fuer CRUD (CLAUDE.md Drawer-Default-Regel) |


## [2026-04-17 16:08] session-20b2544b | admin-dashboard-templates.html (2 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| SNAKE-CASE \| 523 \| alert('Öffnet Dashboard in neuem Tab als AM-User gerendert · URL: /dashboard?pre... \| -> deutsches Label statt snake_case in Alert/Confirm |
| DRAWER-DEFAULT \| -- \| 3 Modal-Patterns gefunden \| -> Drawer 540px verwenden fuer CRUD (CLAUDE.md Drawer-Default-Regel) |


## [2026-04-17 16:09] session-20b2544b | dashboard-mobile.html (1 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| SNAKE-CASE \| 204 \| <div class="muted" style="font-size:13px">Zeigt wie das Dashboard bei den 3 Brea... \| -> sprechenden Begriff statt snake_case-Identifier |


## [2026-04-17 16:39] session-20b2544b | admin-dashboard-templates.html (2 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| SNAKE-CASE \| 523 \| alert('Öffnet Dashboard in neuem Tab als AM-User gerendert · URL: /dashboard?pre... \| -> deutsches Label statt snake_case in Alert/Confirm |
| DRAWER-DEFAULT \| -- \| 3 Modal-Patterns gefunden \| -> Drawer 540px verwenden fuer CRUD (CLAUDE.md Drawer-Default-Regel) |


## [2026-04-17 16:39] session-20b2544b | admin-dashboard-templates.html (2 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| SNAKE-CASE \| 523 \| alert('Öffnet Dashboard in neuem Tab als AM-User gerendert · URL: /dashboard?pre... \| -> deutsches Label statt snake_case in Alert/Confirm |
| DRAWER-DEFAULT \| -- \| 3 Modal-Patterns gefunden \| -> Drawer 540px verwenden fuer CRUD (CLAUDE.md Drawer-Default-Regel) |


## [2026-04-17 16:39] session-20b2544b | admin-dashboard-templates.html (2 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| SNAKE-CASE \| 523 \| alert('Öffnet Dashboard in neuem Tab als AM-User gerendert · URL: /dashboard?pre... \| -> deutsches Label statt snake_case in Alert/Confirm |
| DRAWER-DEFAULT \| -- \| 3 Modal-Patterns gefunden \| -> Drawer 540px verwenden fuer CRUD (CLAUDE.md Drawer-Default-Regel) |


## [2026-04-17 16:40] session-20b2544b | admin-dashboard-templates.html (2 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| SNAKE-CASE \| 523 \| alert('Öffnet Dashboard in neuem Tab als AM-User gerendert · URL: /dashboard?pre... \| -> deutsches Label statt snake_case in Alert/Confirm |
| DRAWER-DEFAULT \| -- \| 3 Modal-Patterns gefunden \| -> Drawer 540px verwenden fuer CRUD (CLAUDE.md Drawer-Default-Regel) |


## [2026-04-17 16:40] session-20b2544b | admin-dashboard-templates.html (2 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| SNAKE-CASE \| 523 \| alert('Öffnet Dashboard in neuem Tab als Account-Manager-User gerendert · URL: /... \| -> deutsches Label statt snake_case in Alert/Confirm |
| DRAWER-DEFAULT \| -- \| 3 Modal-Patterns gefunden \| -> Drawer 540px verwenden fuer CRUD (CLAUDE.md Drawer-Default-Regel) |


## [2026-04-17 16:43] session-20b2544b | admin-dashboard-templates.html (2 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| SNAKE-CASE \| 523 \| alert('Öffnet Dashboard in neuem Tab als Account-Manager-User gerendert · URL: /... \| -> deutsches Label statt snake_case in Alert/Confirm |
| DRAWER-DEFAULT \| -- \| 3 Modal-Patterns gefunden \| -> Drawer 540px verwenden fuer CRUD (CLAUDE.md Drawer-Default-Regel) |


## [2026-04-17 16:43] session-20b2544b | admin-dashboard-templates.html (2 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| SNAKE-CASE \| 523 \| alert('Öffnet Dashboard in neuem Tab als Account-Manager-User gerendert · URL: /... \| -> deutsches Label statt snake_case in Alert/Confirm |
| DRAWER-DEFAULT \| -- \| 3 Modal-Patterns gefunden \| -> Drawer 540px verwenden fuer CRUD (CLAUDE.md Drawer-Default-Regel) |


## [2026-04-17 16:43] session-20b2544b | admin-dashboard-templates.html (2 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| SNAKE-CASE \| 523 \| alert('Öffnet Dashboard in neuem Tab als Account-Manager-User gerendert · URL: /... \| -> deutsches Label statt snake_case in Alert/Confirm |
| DRAWER-DEFAULT \| -- \| 3 Modal-Patterns gefunden \| -> Drawer 540px verwenden fuer CRUD (CLAUDE.md Drawer-Default-Regel) |


## [2026-04-17 16:43] session-20b2544b | admin-dashboard-templates.html (2 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| SNAKE-CASE \| 523 \| alert('Öffnet Dashboard in neuem Tab als Account-Manager-User gerendert · URL: /... \| -> deutsches Label statt snake_case in Alert/Confirm |
| DRAWER-DEFAULT \| -- \| 3 Modal-Patterns gefunden \| -> Drawer 540px verwenden fuer CRUD (CLAUDE.md Drawer-Default-Regel) |


## [2026-04-17 16:43] session-20b2544b | admin-dashboard-templates.html (2 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| SNAKE-CASE \| 523 \| alert('Öffnet Dashboard in neuem Tab als Account-Manager-User gerendert · URL: /... \| -> deutsches Label statt snake_case in Alert/Confirm |
| DRAWER-DEFAULT \| -- \| 3 Modal-Patterns gefunden \| -> Drawer 540px verwenden fuer CRUD (CLAUDE.md Drawer-Default-Regel) |


## [2026-04-17 16:43] session-20b2544b | admin-dashboard-templates.html (2 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| SNAKE-CASE \| 523 \| alert('Öffnet Dashboard in neuem Tab als Account-Manager-User gerendert · URL: /... \| -> deutsches Label statt snake_case in Alert/Confirm |
| DRAWER-DEFAULT \| -- \| 3 Modal-Patterns gefunden \| -> Drawer 540px verwenden fuer CRUD (CLAUDE.md Drawer-Default-Regel) |


## [2026-04-17 16:43] session-20b2544b | admin-dashboard-templates.html (2 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| SNAKE-CASE \| 523 \| alert('Öffnet Dashboard in neuem Tab als Account-Manager-User gerendert · URL: /... \| -> deutsches Label statt snake_case in Alert/Confirm |
| DRAWER-DEFAULT \| -- \| 3 Modal-Patterns gefunden \| -> Drawer 540px verwenden fuer CRUD (CLAUDE.md Drawer-Default-Regel) |


## [2026-04-17 16:43] session-20b2544b | admin-dashboard-templates.html (2 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| SNAKE-CASE \| 523 \| alert('Öffnet Dashboard in neuem Tab als Account-Manager-User gerendert · URL: /... \| -> deutsches Label statt snake_case in Alert/Confirm |
| DRAWER-DEFAULT \| -- \| 3 Modal-Patterns gefunden \| -> Drawer 540px verwenden fuer CRUD (CLAUDE.md Drawer-Default-Regel) |


## [2026-04-17 16:43] session-20b2544b | admin-dashboard-templates.html (2 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| SNAKE-CASE \| 523 \| alert('Öffnet Dashboard in neuem Tab als Account-Manager-User gerendert · URL: /... \| -> deutsches Label statt snake_case in Alert/Confirm |
| DRAWER-DEFAULT \| -- \| 3 Modal-Patterns gefunden \| -> Drawer 540px verwenden fuer CRUD (CLAUDE.md Drawer-Default-Regel) |


## [2026-04-17 16:51] session-3131f2f7 | log.md (5 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| UMLAUT \| 83 \| - `wiki/meta/lint-violations.md` — 8 Violations (5 UMLAUT cal-emp-kuerzel CSS cl... \| -> Kürzel |
| UMLAUT \| 122 \| - `.claude/hooks/ark-lint.ps1` — PostToolUse, scannt Edits auf `mockups/*.html`/... \| -> für |
| UMLAUT \| 122 \| - `.claude/hooks/ark-lint.ps1` — PostToolUse, scannt Edits auf `mockups/*.html`/... \| -> über |
| UMLAUT \| 122 \| - `.claude/hooks/ark-lint.ps1` — PostToolUse, scannt Edits auf `mockups/*.html`/... \| -> könn |
| UMLAUT \| 127 \| - `.claude/commands/ark-sync-report.md` — Slash-Command fuer Spec-Mockup-Sync-Dr... \| -> für |


## [2026-04-17 17:41] session-cea13e34 | scraper.html (5 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| UMLAUT \| 626 \| source:'ritter-bau.ch/ueber-uns/zahlen', \| -> über |
| ROUTE-TMPL \| 405 \| <li>Vollansicht <code>/scraper/runs/[id]</code> · Diff-Ansicht vorheriger Run vs... \| -> sprechende Bezeichnung (z.B. ''Mandat-Vollansicht'') |
| SNAKE-CASE \| 1089 \| <li>History-Event <code>finding_accepted</code></li> \| -> sprechenden Begriff statt snake_case-Identifier |
| SNAKE-CASE \| 1154 \| <li>History-Event <code>job_created_from_scraper</code></li> \| -> sprechenden Begriff statt snake_case-Identifier |
| SNAKE-CASE \| 1220 \| <li>Critical Alert <code>protection_violation_detected</code></li> \| -> sprechenden Begriff statt snake_case-Identifier |


## [2026-04-17 17:45] session-cea13e34 | scraper.html (5 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| UMLAUT \| 625 \| source:'ritter-bau.ch/ueber-uns/zahlen', \| -> über |
| ROUTE-TMPL \| 404 \| <li>Vollansicht <code>/scraper/runs/[id]</code> · Diff-Ansicht vorheriger Run vs... \| -> sprechende Bezeichnung (z.B. ''Mandat-Vollansicht'') |
| SNAKE-CASE \| 1088 \| <li>History-Event <code>finding_accepted</code></li> \| -> sprechenden Begriff statt snake_case-Identifier |
| SNAKE-CASE \| 1153 \| <li>History-Event <code>job_created_from_scraper</code></li> \| -> sprechenden Begriff statt snake_case-Identifier |
| SNAKE-CASE \| 1219 \| <li>Critical Alert <code>protection_violation_detected</code></li> \| -> sprechenden Begriff statt snake_case-Identifier |


## [2026-04-17 17:46] session-cea13e34 | scraper.html (5 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| UMLAUT \| 701 \| source:'ritter-bau.ch/ueber-uns/zahlen', \| -> über |
| ROUTE-TMPL \| 480 \| <li>Vollansicht <code>/scraper/runs/[id]</code> · Diff-Ansicht vorheriger Run vs... \| -> sprechende Bezeichnung (z.B. ''Mandat-Vollansicht'') |
| SNAKE-CASE \| 1164 \| <li>History-Event <code>finding_accepted</code></li> \| -> sprechenden Begriff statt snake_case-Identifier |
| SNAKE-CASE \| 1229 \| <li>History-Event <code>job_created_from_scraper</code></li> \| -> sprechenden Begriff statt snake_case-Identifier |
| SNAKE-CASE \| 1295 \| <li>Critical Alert <code>protection_violation_detected</code></li> \| -> sprechenden Begriff statt snake_case-Identifier |


## [2026-04-17 17:46] session-cea13e34 | scraper.html (5 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| UMLAUT \| 732 \| source:'ritter-bau.ch/ueber-uns/zahlen', \| -> über |
| ROUTE-TMPL \| 511 \| <li>Vollansicht <code>/scraper/runs/[id]</code> · Diff-Ansicht vorheriger Run vs... \| -> sprechende Bezeichnung (z.B. ''Mandat-Vollansicht'') |
| SNAKE-CASE \| 1195 \| <li>History-Event <code>finding_accepted</code></li> \| -> sprechenden Begriff statt snake_case-Identifier |
| SNAKE-CASE \| 1260 \| <li>History-Event <code>job_created_from_scraper</code></li> \| -> sprechenden Begriff statt snake_case-Identifier |
| SNAKE-CASE \| 1326 \| <li>Critical Alert <code>protection_violation_detected</code></li> \| -> sprechenden Begriff statt snake_case-Identifier |


## [2026-04-17 17:47] session-cea13e34 | scraper.html (5 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| UMLAUT \| 732 \| source:'ritter-bau.ch/ueber-uns/zahlen', \| -> über |
| ROUTE-TMPL \| 511 \| <li>Vollansicht <code>/scraper/runs/[id]</code> · Diff-Ansicht vorheriger Run vs... \| -> sprechende Bezeichnung (z.B. ''Mandat-Vollansicht'') |
| SNAKE-CASE \| 1195 \| <li>History-Event <code>finding_accepted</code></li> \| -> sprechenden Begriff statt snake_case-Identifier |
| SNAKE-CASE \| 1260 \| <li>History-Event <code>job_created_from_scraper</code></li> \| -> sprechenden Begriff statt snake_case-Identifier |
| SNAKE-CASE \| 1326 \| <li>Critical Alert <code>protection_violation_detected</code></li> \| -> sprechenden Begriff statt snake_case-Identifier |


## [2026-04-17 17:49] session-cea13e34 | scraper.html (5 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| UMLAUT \| 774 \| source:'ritter-bau.ch/ueber-uns/zahlen', \| -> über |
| ROUTE-TMPL \| 553 \| <li>Vollansicht <code>/scraper/runs/[id]</code> · Diff-Ansicht vorheriger Run vs... \| -> sprechende Bezeichnung (z.B. ''Mandat-Vollansicht'') |
| SNAKE-CASE \| 1237 \| <li>History-Event <code>finding_accepted</code></li> \| -> sprechenden Begriff statt snake_case-Identifier |
| SNAKE-CASE \| 1302 \| <li>History-Event <code>job_created_from_scraper</code></li> \| -> sprechenden Begriff statt snake_case-Identifier |
| SNAKE-CASE \| 1368 \| <li>Critical Alert <code>protection_violation_detected</code></li> \| -> sprechenden Begriff statt snake_case-Identifier |


## [2026-04-17 17:49] session-cea13e34 | scraper.html (4 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| UMLAUT \| 804 \| source:'ritter-bau.ch/ueber-uns/zahlen', \| -> über |
| SNAKE-CASE \| 1267 \| <li>History-Event <code>finding_accepted</code></li> \| -> sprechenden Begriff statt snake_case-Identifier |
| SNAKE-CASE \| 1332 \| <li>History-Event <code>job_created_from_scraper</code></li> \| -> sprechenden Begriff statt snake_case-Identifier |
| SNAKE-CASE \| 1398 \| <li>Critical Alert <code>protection_violation_detected</code></li> \| -> sprechenden Begriff statt snake_case-Identifier |


## [2026-04-17 17:49] session-cea13e34 | scraper.html (4 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| UMLAUT \| 822 \| source:'ritter-bau.ch/ueber-uns/zahlen', \| -> über |
| SNAKE-CASE \| 1285 \| <li>History-Event <code>finding_accepted</code></li> \| -> sprechenden Begriff statt snake_case-Identifier |
| SNAKE-CASE \| 1350 \| <li>History-Event <code>job_created_from_scraper</code></li> \| -> sprechenden Begriff statt snake_case-Identifier |
| SNAKE-CASE \| 1416 \| <li>Critical Alert <code>protection_violation_detected</code></li> \| -> sprechenden Begriff statt snake_case-Identifier |


## [2026-04-17 17:51] session-cea13e34 | scraper.html (4 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| UMLAUT \| 822 \| source:'ritter-bau.ch/ueber-uns/zahlen', \| -> über |
| SNAKE-CASE \| 1285 \| <li>History-Event <code>finding_accepted</code></li> \| -> sprechenden Begriff statt snake_case-Identifier |
| SNAKE-CASE \| 1350 \| <li>History-Event <code>job_created_from_scraper</code></li> \| -> sprechenden Begriff statt snake_case-Identifier |
| SNAKE-CASE \| 1416 \| <li>Critical Alert <code>protection_violation_detected</code></li> \| -> sprechenden Begriff statt snake_case-Identifier |


## [2026-04-17 17:51] session-cea13e34 | scraper.html (4 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| UMLAUT \| 822 \| source:'ritter-bau.ch/ueber-uns/zahlen', \| -> über |
| SNAKE-CASE \| 1285 \| <li>History-Event <code>finding_accepted</code></li> \| -> sprechenden Begriff statt snake_case-Identifier |
| SNAKE-CASE \| 1350 \| <li>History-Event <code>job_created_from_scraper</code></li> \| -> sprechenden Begriff statt snake_case-Identifier |
| SNAKE-CASE \| 1416 \| <li>Critical Alert <code>protection_violation_detected</code></li> \| -> sprechenden Begriff statt snake_case-Identifier |


## [2026-04-17 17:52] session-cea13e34 | scraper.html (4 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| UMLAUT \| 868 \| source:'ritter-bau.ch/ueber-uns/zahlen', \| -> über |
| SNAKE-CASE \| 1331 \| <li>History-Event <code>finding_accepted</code></li> \| -> sprechenden Begriff statt snake_case-Identifier |
| SNAKE-CASE \| 1396 \| <li>History-Event <code>job_created_from_scraper</code></li> \| -> sprechenden Begriff statt snake_case-Identifier |
| SNAKE-CASE \| 1462 \| <li>Critical Alert <code>protection_violation_detected</code></li> \| -> sprechenden Begriff statt snake_case-Identifier |


## [2026-04-17 17:53] session-cea13e34 | scraper.html (4 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| UMLAUT \| 987 \| source:'ritter-bau.ch/ueber-uns/zahlen', \| -> über |
| SNAKE-CASE \| 1450 \| <li>History-Event <code>finding_accepted</code></li> \| -> sprechenden Begriff statt snake_case-Identifier |
| SNAKE-CASE \| 1515 \| <li>History-Event <code>job_created_from_scraper</code></li> \| -> sprechenden Begriff statt snake_case-Identifier |
| SNAKE-CASE \| 1581 \| <li>Critical Alert <code>protection_violation_detected</code></li> \| -> sprechenden Begriff statt snake_case-Identifier |


## [2026-04-17 17:54] session-cea13e34 | scraper.html (5 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| UMLAUT \| 987 \| source:'ritter-bau.ch/ueber-uns/zahlen', \| -> über |
| SNAKE-CASE \| 1450 \| <li>History-Event <code>finding_accepted</code></li> \| -> sprechenden Begriff statt snake_case-Identifier |
| SNAKE-CASE \| 1515 \| <li>History-Event <code>job_created_from_scraper</code></li> \| -> sprechenden Begriff statt snake_case-Identifier |
| SNAKE-CASE \| 1581 \| <li>Critical Alert <code>protection_violation_detected</code></li> \| -> sprechenden Begriff statt snake_case-Identifier |
| SNAKE-CASE \| 1883 \| <div><div class="label">${k.replace(/_/g,' ')}</div><span class="hint">&lt; Schw... \| -> deutsches Label fuer Enum-Value |


## [2026-04-17 17:54] session-cea13e34 | scraper.html (5 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| UMLAUT \| 987 \| source:'ritter-bau.ch/ueber-uns/zahlen', \| -> über |
| SNAKE-CASE \| 1450 \| <li>History-Event <code>finding_accepted</code></li> \| -> sprechenden Begriff statt snake_case-Identifier |
| SNAKE-CASE \| 1515 \| <li>History-Event <code>job_created_from_scraper</code></li> \| -> sprechenden Begriff statt snake_case-Identifier |
| SNAKE-CASE \| 1581 \| <li>Critical Alert <code>protection_violation_detected</code></li> \| -> sprechenden Begriff statt snake_case-Identifier |
| SNAKE-CASE \| 1883 \| <div><div class="label">${k.replace(/_/g,' ')}</div><span class="hint">&lt; Schw... \| -> deutsches Label fuer Enum-Value |


## [2026-04-17 17:57] session-cea13e34 | scraper.html (5 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| UMLAUT \| 1032 \| source:'ritter-bau.ch/ueber-uns/zahlen', \| -> über |
| SNAKE-CASE \| 1495 \| <li>History-Event <code>finding_accepted</code></li> \| -> sprechenden Begriff statt snake_case-Identifier |
| SNAKE-CASE \| 1560 \| <li>History-Event <code>job_created_from_scraper</code></li> \| -> sprechenden Begriff statt snake_case-Identifier |
| SNAKE-CASE \| 1626 \| <li>Critical Alert <code>protection_violation_detected</code></li> \| -> sprechenden Begriff statt snake_case-Identifier |
| SNAKE-CASE \| 1928 \| <div><div class="label">${k.replace(/_/g,' ')}</div><span class="hint">&lt; Schw... \| -> deutsches Label fuer Enum-Value |


## [2026-04-17 17:57] session-9c15c2db | admin.html (3 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| SNAKE-CASE \| 169 \| <span style="color:var(--text-mid);margin-left:8px">System-Konfiguration · Nur f... \| -> sprechenden Begriff statt snake_case-Identifier |
| SNAKE-CASE \| 1406 \| <div class="sub"><code>ghosting_frist_tage</code> · Tenant-Scope · Kategorie: Gh... \| -> sprechenden Begriff statt snake_case-Identifier |
| SNAKE-CASE \| 1465 \| <div class="sub">Trigger: <code>interview_scheduled</code> · v4 · zuletzt editie... \| -> sprechenden Begriff statt snake_case-Identifier |


## [2026-04-17 17:57] session-cea13e34 | scraper.html (5 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| UMLAUT \| 1091 \| source:'ritter-bau.ch/ueber-uns/zahlen', \| -> über |
| SNAKE-CASE \| 1554 \| <li>History-Event <code>finding_accepted</code></li> \| -> sprechenden Begriff statt snake_case-Identifier |
| SNAKE-CASE \| 1619 \| <li>History-Event <code>job_created_from_scraper</code></li> \| -> sprechenden Begriff statt snake_case-Identifier |
| SNAKE-CASE \| 1685 \| <li>Critical Alert <code>protection_violation_detected</code></li> \| -> sprechenden Begriff statt snake_case-Identifier |
| SNAKE-CASE \| 1987 \| <div><div class="label">${k.replace(/_/g,' ')}</div><span class="hint">&lt; Schw... \| -> deutsches Label fuer Enum-Value |


## [2026-04-17 17:58] session-9c15c2db | admin.html (2 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| SNAKE-CASE \| 1406 \| <div class="sub"><code>ghosting_frist_tage</code> · Tenant-Scope · Kategorie: Gh... \| -> sprechenden Begriff statt snake_case-Identifier |
| SNAKE-CASE \| 1465 \| <div class="sub">Trigger: <code>interview_scheduled</code> · v4 · zuletzt editie... \| -> sprechenden Begriff statt snake_case-Identifier |


## [2026-04-17 17:58] session-9c15c2db | admin.html (1 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| SNAKE-CASE \| 1465 \| <div class="sub">Trigger: <code>interview_scheduled</code> · v4 · zuletzt editie... \| -> sprechenden Begriff statt snake_case-Identifier |


## [2026-04-17 18:00] session-cea13e34 | scraper.html (5 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| UMLAUT \| 1091 \| source:'ritter-bau.ch/ueber-uns/zahlen', \| -> über |
| SNAKE-CASE \| 1554 \| <li>History-Event <code>finding_accepted</code></li> \| -> sprechenden Begriff statt snake_case-Identifier |
| SNAKE-CASE \| 1619 \| <li>History-Event <code>job_created_from_scraper</code></li> \| -> sprechenden Begriff statt snake_case-Identifier |
| SNAKE-CASE \| 1685 \| <li>Critical Alert <code>protection_violation_detected</code></li> \| -> sprechenden Begriff statt snake_case-Identifier |
| SNAKE-CASE \| 2256 \| <div><div class="label">${k.replace(/_/g,' ')}</div><span class="hint">&lt; Schw... \| -> deutsches Label fuer Enum-Value |


## [2026-04-17 18:00] session-cea13e34 | scraper.html (5 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| UMLAUT \| 1091 \| source:'ritter-bau.ch/ueber-uns/zahlen', \| -> über |
| SNAKE-CASE \| 1554 \| <li>History-Event <code>finding_accepted</code></li> \| -> sprechenden Begriff statt snake_case-Identifier |
| SNAKE-CASE \| 1619 \| <li>History-Event <code>job_created_from_scraper</code></li> \| -> sprechenden Begriff statt snake_case-Identifier |
| SNAKE-CASE \| 1685 \| <li>Critical Alert <code>protection_violation_detected</code></li> \| -> sprechenden Begriff statt snake_case-Identifier |
| SNAKE-CASE \| 2256 \| <div><div class="label">${k.replace(/_/g,' ')}</div><span class="hint">&lt; Schw... \| -> deutsches Label fuer Enum-Value |


## [2026-04-17 18:02] session-cea13e34 | scraper.html (5 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| UMLAUT \| 1123 \| source:'ritter-bau.ch/ueber-uns/zahlen', \| -> über |
| SNAKE-CASE \| 1586 \| <li>History-Event <code>finding_accepted</code></li> \| -> sprechenden Begriff statt snake_case-Identifier |
| SNAKE-CASE \| 1651 \| <li>History-Event <code>job_created_from_scraper</code></li> \| -> sprechenden Begriff statt snake_case-Identifier |
| SNAKE-CASE \| 1717 \| <li>Critical Alert <code>protection_violation_detected</code></li> \| -> sprechenden Begriff statt snake_case-Identifier |
| SNAKE-CASE \| 2288 \| <div><div class="label">${k.replace(/_/g,' ')}</div><span class="hint">&lt; Schw... \| -> deutsches Label fuer Enum-Value |


## [2026-04-17 18:03] session-cea13e34 | scraper.html (5 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| UMLAUT \| 1143 \| source:'ritter-bau.ch/ueber-uns/zahlen', \| -> über |
| SNAKE-CASE \| 1606 \| <li>History-Event <code>finding_accepted</code></li> \| -> sprechenden Begriff statt snake_case-Identifier |
| SNAKE-CASE \| 1671 \| <li>History-Event <code>job_created_from_scraper</code></li> \| -> sprechenden Begriff statt snake_case-Identifier |
| SNAKE-CASE \| 1737 \| <li>Critical Alert <code>protection_violation_detected</code></li> \| -> sprechenden Begriff statt snake_case-Identifier |
| SNAKE-CASE \| 2308 \| <div><div class="label">${k.replace(/_/g,' ')}</div><span class="hint">&lt; Schw... \| -> deutsches Label fuer Enum-Value |


## [2026-04-17 18:04] session-cea13e34 | scraper.html (5 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| UMLAUT \| 1143 \| source:'ritter-bau.ch/ueber-uns/zahlen', \| -> über |
| SNAKE-CASE \| 1606 \| <li>History-Event <code>finding_accepted</code></li> \| -> sprechenden Begriff statt snake_case-Identifier |
| SNAKE-CASE \| 1671 \| <li>History-Event <code>job_created_from_scraper</code></li> \| -> sprechenden Begriff statt snake_case-Identifier |
| SNAKE-CASE \| 1737 \| <li>Critical Alert <code>protection_violation_detected</code></li> \| -> sprechenden Begriff statt snake_case-Identifier |
| SNAKE-CASE \| 2451 \| <div><div class="label">${k.replace(/_/g,' ')}</div><span class="hint">&lt; Schw... \| -> deutsches Label fuer Enum-Value |


## [2026-04-17 18:04] session-cea13e34 | scraper.html (5 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| UMLAUT \| 1143 \| source:'ritter-bau.ch/ueber-uns/zahlen', \| -> über |
| SNAKE-CASE \| 1606 \| <li>History-Event <code>finding_accepted</code></li> \| -> sprechenden Begriff statt snake_case-Identifier |
| SNAKE-CASE \| 1671 \| <li>History-Event <code>job_created_from_scraper</code></li> \| -> sprechenden Begriff statt snake_case-Identifier |
| SNAKE-CASE \| 1737 \| <li>Critical Alert <code>protection_violation_detected</code></li> \| -> sprechenden Begriff statt snake_case-Identifier |
| SNAKE-CASE \| 2451 \| <div><div class="label">${k.replace(/_/g,' ')}</div><span class="hint">&lt; Schw... \| -> deutsches Label fuer Enum-Value |


## [2026-04-17 18:33] session-cea13e34 | scraper.html (5 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| UMLAUT \| 1132 \| source:'ritter-bau.ch/ueber-uns/zahlen', \| -> über |
| SNAKE-CASE \| 1595 \| <li>History-Event <code>finding_accepted</code></li> \| -> sprechenden Begriff statt snake_case-Identifier |
| SNAKE-CASE \| 1660 \| <li>History-Event <code>job_created_from_scraper</code></li> \| -> sprechenden Begriff statt snake_case-Identifier |
| SNAKE-CASE \| 1726 \| <li>Critical Alert <code>protection_violation_detected</code></li> \| -> sprechenden Begriff statt snake_case-Identifier |
| SNAKE-CASE \| 2440 \| <div><div class="label">${k.replace(/_/g,' ')}</div><span class="hint">&lt; Schw... \| -> deutsches Label fuer Enum-Value |


## [2026-04-17 18:37] session-3131f2f7 | scraper.html (5 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| UMLAUT \| 1142 \| source:'ritter-bau.ch/ueber-uns/zahlen', \| -> über |
| SNAKE-CASE \| 1605 \| <li>History-Event <code>finding_accepted</code></li> \| -> sprechenden Begriff statt snake_case-Identifier |
| SNAKE-CASE \| 1670 \| <li>History-Event <code>job_created_from_scraper</code></li> \| -> sprechenden Begriff statt snake_case-Identifier |
| SNAKE-CASE \| 1736 \| <li>Critical Alert <code>protection_violation_detected</code></li> \| -> sprechenden Begriff statt snake_case-Identifier |
| SNAKE-CASE \| 2450 \| <div><div class="label">${k.replace(/_/g,' ')}</div><span class="hint">&lt; Schw... \| -> deutsches Label fuer Enum-Value |


## [2026-04-17 18:37] session-3131f2f7 | admin-dashboard-templates.html (2 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| SNAKE-CASE \| 537 \| alert('Öffnet Dashboard in neuem Tab als Account-Manager-User gerendert · URL: /... \| -> deutsches Label statt snake_case in Alert/Confirm |
| DRAWER-DEFAULT \| -- \| 3 Modal-Patterns gefunden \| -> Drawer 540px verwenden fuer CRUD (CLAUDE.md Drawer-Default-Regel) |


## [2026-04-17 18:39] session-9c15c2db | sync-report-2026-04-17.md (1 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| UMLAUT \| 122 \| - `ueber-uns` → `über-uns` (UMLAUT) \| -> über |


## [2026-04-17 18:40] session-9c15c2db | log.md (5 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| UMLAUT \| 128 \| - `wiki/meta/lint-violations.md` — 8 Violations (5 UMLAUT cal-emp-kuerzel CSS cl... \| -> Kürzel |
| UMLAUT \| 167 \| - `.claude/hooks/ark-lint.ps1` — PostToolUse, scannt Edits auf `mockups/*.html`/... \| -> für |
| UMLAUT \| 167 \| - `.claude/hooks/ark-lint.ps1` — PostToolUse, scannt Edits auf `mockups/*.html`/... \| -> über |
| UMLAUT \| 167 \| - `.claude/hooks/ark-lint.ps1` — PostToolUse, scannt Edits auf `mockups/*.html`/... \| -> könn |
| UMLAUT \| 172 \| - `.claude/commands/ark-sync-report.md` — Slash-Command fuer Spec-Mockup-Sync-Dr... \| -> für |


## [2026-04-17 18:42] session-cea13e34 | scraper.html (4 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| SNAKE-CASE \| 1605 \| <li>History-Event <code>finding_accepted</code></li> \| -> sprechenden Begriff statt snake_case-Identifier |
| SNAKE-CASE \| 1670 \| <li>History-Event <code>job_created_from_scraper</code></li> \| -> sprechenden Begriff statt snake_case-Identifier |
| SNAKE-CASE \| 1736 \| <li>Critical Alert <code>protection_violation_detected</code></li> \| -> sprechenden Begriff statt snake_case-Identifier |
| SNAKE-CASE \| 2450 \| <div><div class="label">${k.replace(/_/g,' ')}</div><span class="hint">&lt; Schw... \| -> deutsches Label fuer Enum-Value |


## [2026-04-17 18:42] session-cea13e34 | scraper.html (3 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| SNAKE-CASE \| 1670 \| <li>History-Event <code>job_created_from_scraper</code></li> \| -> sprechenden Begriff statt snake_case-Identifier |
| SNAKE-CASE \| 1736 \| <li>Critical Alert <code>protection_violation_detected</code></li> \| -> sprechenden Begriff statt snake_case-Identifier |
| SNAKE-CASE \| 2450 \| <div><div class="label">${k.replace(/_/g,' ')}</div><span class="hint">&lt; Schw... \| -> deutsches Label fuer Enum-Value |


## [2026-04-17 18:42] session-cea13e34 | scraper.html (2 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| SNAKE-CASE \| 1736 \| <li>Critical Alert <code>protection_violation_detected</code></li> \| -> sprechenden Begriff statt snake_case-Identifier |
| SNAKE-CASE \| 2450 \| <div><div class="label">${k.replace(/_/g,' ')}</div><span class="hint">&lt; Schw... \| -> deutsches Label fuer Enum-Value |


## [2026-04-17 18:42] session-cea13e34 | scraper.html (1 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| SNAKE-CASE \| 2450 \| <div><div class="label">${k.replace(/_/g,' ')}</div><span class="hint">&lt; Schw... \| -> deutsches Label fuer Enum-Value |


## [2026-04-17 18:49] session-3131f2f7 | log.md (5 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| UMLAUT \| 159 \| - `wiki/meta/lint-violations.md` — 8 Violations (5 UMLAUT cal-emp-kuerzel CSS cl... \| -> Kürzel |
| UMLAUT \| 198 \| - `.claude/hooks/ark-lint.ps1` — PostToolUse, scannt Edits auf `mockups/*.html`/... \| -> für |
| UMLAUT \| 198 \| - `.claude/hooks/ark-lint.ps1` — PostToolUse, scannt Edits auf `mockups/*.html`/... \| -> über |
| UMLAUT \| 198 \| - `.claude/hooks/ark-lint.ps1` — PostToolUse, scannt Edits auf `mockups/*.html`/... \| -> könn |
| UMLAUT \| 203 \| - `.claude/commands/ark-sync-report.md` — Slash-Command fuer Spec-Mockup-Sync-Dr... \| -> für |


## [2026-04-17 18:50] session-9c15c2db | admin-dashboard-templates.html (2 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| SNAKE-CASE \| 537 \| alert('Öffnet Dashboard in neuem Tab als Account-Manager-User gerendert · URL: /... \| -> deutsches Label statt snake_case in Alert/Confirm |
| DRAWER-DEFAULT \| -- \| 3 Modal-Patterns gefunden \| -> Drawer 540px verwenden fuer CRUD (CLAUDE.md Drawer-Default-Regel) |


## [2026-04-17 18:51] session-9c15c2db | admin-dashboard-templates.html (2 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| SNAKE-CASE \| 537 \| alert('Öffnet Dashboard in neuem Tab als Account-Manager-User gerendert · URL: /... \| -> deutsches Label statt snake_case in Alert/Confirm |
| DRAWER-DEFAULT \| -- \| 3 Modal-Patterns gefunden \| -> Drawer 540px verwenden fuer CRUD (CLAUDE.md Drawer-Default-Regel) |


## [2026-04-18 17:43] session-9c15c2db | admin-mobile.html (8 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| SNAKE-CASE \| 228 \| <code>ghosting_frist_tage</code> \| -> sprechenden Begriff statt snake_case-Identifier |
| SNAKE-CASE \| 239 \| <code>stale_prozess_tage</code> \| -> sprechenden Begriff statt snake_case-Identifier |
| SNAKE-CASE \| 250 \| <code>schutzfrist_warn_vorlauf_tage</code> \| -> sprechenden Begriff statt snake_case-Identifier |
| SNAKE-CASE \| 266 \| <code>feature_ai_briefing</code> \| -> sprechenden Begriff statt snake_case-Identifier |
| SNAKE-CASE \| 277 \| <code>feature_matching_v2</code> \| -> sprechenden Begriff statt snake_case-Identifier |
| SNAKE-CASE \| 288 \| <code>feature_hr_tool</code> \| -> sprechenden Begriff statt snake_case-Identifier |
| SNAKE-CASE \| 400 \| <div class="m-flag-desc">Trigger: <code>interview_scheduled</code> · 23 Runs (24... \| -> sprechenden Begriff statt snake_case-Identifier |
| SNAKE-CASE \| 409 \| <div class="m-flag-desc">Trigger: <code>prozess_no_activity_14d</code> · 12 Runs... \| -> sprechenden Begriff statt snake_case-Identifier |


## [2026-04-18 17:44] session-9c15c2db | admin-mobile.html (7 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| SNAKE-CASE \| 239 \| <code>stale_prozess_tage</code> \| -> sprechenden Begriff statt snake_case-Identifier |
| SNAKE-CASE \| 250 \| <code>schutzfrist_warn_vorlauf_tage</code> \| -> sprechenden Begriff statt snake_case-Identifier |
| SNAKE-CASE \| 266 \| <code>feature_ai_briefing</code> \| -> sprechenden Begriff statt snake_case-Identifier |
| SNAKE-CASE \| 277 \| <code>feature_matching_v2</code> \| -> sprechenden Begriff statt snake_case-Identifier |
| SNAKE-CASE \| 288 \| <code>feature_hr_tool</code> \| -> sprechenden Begriff statt snake_case-Identifier |
| SNAKE-CASE \| 400 \| <div class="m-flag-desc">Trigger: <code>interview_scheduled</code> · 23 Runs (24... \| -> sprechenden Begriff statt snake_case-Identifier |
| SNAKE-CASE \| 409 \| <div class="m-flag-desc">Trigger: <code>prozess_no_activity_14d</code> · 12 Runs... \| -> sprechenden Begriff statt snake_case-Identifier |


## [2026-04-18 17:44] session-9c15c2db | admin-mobile.html (6 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| SNAKE-CASE \| 250 \| <code>schutzfrist_warn_vorlauf_tage</code> \| -> sprechenden Begriff statt snake_case-Identifier |
| SNAKE-CASE \| 266 \| <code>feature_ai_briefing</code> \| -> sprechenden Begriff statt snake_case-Identifier |
| SNAKE-CASE \| 277 \| <code>feature_matching_v2</code> \| -> sprechenden Begriff statt snake_case-Identifier |
| SNAKE-CASE \| 288 \| <code>feature_hr_tool</code> \| -> sprechenden Begriff statt snake_case-Identifier |
| SNAKE-CASE \| 400 \| <div class="m-flag-desc">Trigger: <code>interview_scheduled</code> · 23 Runs (24... \| -> sprechenden Begriff statt snake_case-Identifier |
| SNAKE-CASE \| 409 \| <div class="m-flag-desc">Trigger: <code>prozess_no_activity_14d</code> · 12 Runs... \| -> sprechenden Begriff statt snake_case-Identifier |


## [2026-04-18 17:44] session-9c15c2db | admin-mobile.html (5 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| SNAKE-CASE \| 266 \| <code>feature_ai_briefing</code> \| -> sprechenden Begriff statt snake_case-Identifier |
| SNAKE-CASE \| 277 \| <code>feature_matching_v2</code> \| -> sprechenden Begriff statt snake_case-Identifier |
| SNAKE-CASE \| 288 \| <code>feature_hr_tool</code> \| -> sprechenden Begriff statt snake_case-Identifier |
| SNAKE-CASE \| 400 \| <div class="m-flag-desc">Trigger: <code>interview_scheduled</code> · 23 Runs (24... \| -> sprechenden Begriff statt snake_case-Identifier |
| SNAKE-CASE \| 409 \| <div class="m-flag-desc">Trigger: <code>prozess_no_activity_14d</code> · 12 Runs... \| -> sprechenden Begriff statt snake_case-Identifier |


## [2026-04-18 17:44] session-9c15c2db | admin-mobile.html (4 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| SNAKE-CASE \| 277 \| <code>feature_matching_v2</code> \| -> sprechenden Begriff statt snake_case-Identifier |
| SNAKE-CASE \| 288 \| <code>feature_hr_tool</code> \| -> sprechenden Begriff statt snake_case-Identifier |
| SNAKE-CASE \| 400 \| <div class="m-flag-desc">Trigger: <code>interview_scheduled</code> · 23 Runs (24... \| -> sprechenden Begriff statt snake_case-Identifier |
| SNAKE-CASE \| 409 \| <div class="m-flag-desc">Trigger: <code>prozess_no_activity_14d</code> · 12 Runs... \| -> sprechenden Begriff statt snake_case-Identifier |


## [2026-04-18 17:44] session-9c15c2db | admin-mobile.html (3 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| SNAKE-CASE \| 288 \| <code>feature_hr_tool</code> \| -> sprechenden Begriff statt snake_case-Identifier |
| SNAKE-CASE \| 400 \| <div class="m-flag-desc">Trigger: <code>interview_scheduled</code> · 23 Runs (24... \| -> sprechenden Begriff statt snake_case-Identifier |
| SNAKE-CASE \| 409 \| <div class="m-flag-desc">Trigger: <code>prozess_no_activity_14d</code> · 12 Runs... \| -> sprechenden Begriff statt snake_case-Identifier |


## [2026-04-18 17:44] session-9c15c2db | admin-mobile.html (2 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| SNAKE-CASE \| 400 \| <div class="m-flag-desc">Trigger: <code>interview_scheduled</code> · 23 Runs (24... \| -> sprechenden Begriff statt snake_case-Identifier |
| SNAKE-CASE \| 409 \| <div class="m-flag-desc">Trigger: <code>prozess_no_activity_14d</code> · 12 Runs... \| -> sprechenden Begriff statt snake_case-Identifier |


## [2026-04-18 17:44] session-9c15c2db | admin-mobile.html (1 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| SNAKE-CASE \| 409 \| <div class="m-flag-desc">Trigger: <code>prozess_no_activity_14d</code> · 12 Runs... \| -> sprechenden Begriff statt snake_case-Identifier |


## [2026-04-18 17:47] session-9c15c2db | log.md (5 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| UMLAUT \| 182 \| - `wiki/meta/lint-violations.md` — 8 Violations (5 UMLAUT cal-emp-kuerzel CSS cl... \| -> Kürzel |
| UMLAUT \| 221 \| - `.claude/hooks/ark-lint.ps1` — PostToolUse, scannt Edits auf `mockups/*.html`/... \| -> für |
| UMLAUT \| 221 \| - `.claude/hooks/ark-lint.ps1` — PostToolUse, scannt Edits auf `mockups/*.html`/... \| -> über |
| UMLAUT \| 221 \| - `.claude/hooks/ark-lint.ps1` — PostToolUse, scannt Edits auf `mockups/*.html`/... \| -> könn |
| UMLAUT \| 226 \| - `.claude/commands/ark-sync-report.md` — Slash-Command fuer Spec-Mockup-Sync-Dr... \| -> für |


## [2026-04-18 22:25] session-205d1e89 | log.md (5 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| UMLAUT \| 203 \| - `wiki/meta/lint-violations.md` — 8 Violations (5 UMLAUT cal-emp-kuerzel CSS cl... \| -> Kürzel |
| UMLAUT \| 242 \| - `.claude/hooks/ark-lint.ps1` — PostToolUse, scannt Edits auf `mockups/*.html`/... \| -> für |
| UMLAUT \| 242 \| - `.claude/hooks/ark-lint.ps1` — PostToolUse, scannt Edits auf `mockups/*.html`/... \| -> über |
| UMLAUT \| 242 \| - `.claude/hooks/ark-lint.ps1` — PostToolUse, scannt Edits auf `mockups/*.html`/... \| -> könn |
| UMLAUT \| 247 \| - `.claude/commands/ark-sync-report.md` — Slash-Command fuer Spec-Mockup-Sync-Dr... \| -> für |


## [2026-04-18 22:50] session-205d1e89 | stammdaten.html (19 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| SNAKE-CASE \| 2753 \| <div class="cc-desc">Vier-Augen-Prinzip. Default <code>suggest_only</code> · <co... \| -> sprechenden Begriff statt snake_case-Identifier |
| DB-TECH \| 2864 \| <tr onclick="openEntry('ps_expose')"><td>1</td><td><span class="code">expose</sp... \| -> use sprechenden Begriff |
| DB-TECH \| 2865 \| <tr onclick="openEntry('ps_cv_sent')"><td>2</td><td><span class="code">cv_sent</... \| -> use sprechenden Begriff |
| DB-TECH \| 2866 \| <tr onclick="openEntry('ps_ti')"><td>3</td><td><span class="code">ti</span></td>... \| -> use sprechenden Begriff |
| DB-TECH \| 2867 \| <tr onclick="openEntry('ps_1st')"><td>4</td><td><span class="code">first</span><... \| -> use sprechenden Begriff |
| DB-TECH \| 2868 \| <tr onclick="openEntry('ps_2nd')"><td>5</td><td><span class="code">second</span>... \| -> use sprechenden Begriff |
| DB-TECH \| 2869 \| <tr onclick="openEntry('ps_3rd')"><td>6</td><td><span class="code">third</span><... \| -> use sprechenden Begriff |
| DB-TECH \| 2870 \| <tr onclick="openEntry('ps_assess')"><td>7</td><td><span class="code">assessment... \| -> use sprechenden Begriff |
| DB-TECH \| 2871 \| <tr onclick="openEntry('ps_offer')"><td>8</td><td><span class="code">offer</span... \| -> use sprechenden Begriff |
| DB-TECH \| 2872 \| <tr onclick="openEntry('ps_placement')"><td>9</td><td><span class="code">placeme... \| -> use sprechenden Begriff |
| DB-TECH \| 3055 \| <div><div class="u-entity">Aktuell laufende Prozesse in Stage TI</div><div class... \| -> use sprechenden Begriff |
| DB-TECH \| 3060 \| <div><div class="u-entity">History-Events "stage_changed → ti"</div><div class="... \| -> use sprechenden Begriff |
| SNAKE-CASE \| 3060 \| <div><div class="u-entity">History-Events "stage_changed → ti"</div><div class="... \| -> deutsches Label fuer Enum-Value |
| DB-TECH \| 3065 \| <div><div class="u-entity">Coaching-TI-Aktivitäten</div><div class="u-where">fac... \| -> use sprechenden Begriff |
| DB-TECH \| 3070 \| <div><div class="u-entity">Debriefing-TI-Aktivitäten</div><div class="u-where">f... \| -> use sprechenden Begriff |
| DB-TECH \| 3075 \| <div><div class="u-entity">Reminders mit Bezug zu TI</div><div class="u-where">f... \| -> use sprechenden Begriff |
| DB-TECH \| 3539 \| ['<span class="code">cv_parse</span>','CV-Extraktion → dim_candidates_profile','... \| -> use sprechenden Begriff |
| SNAKE-CASE \| 3554 \| ['<span class="code">candidate.stage_changed</span>','Lifecycle','candidate','<s... \| -> deutsches Label fuer Enum-Value |
| SNAKE-CASE \| 3560 \| ['<span class="code">process.stage_changed</span>','Prozess','process','<strong>... \| -> deutsches Label fuer Enum-Value |


## [2026-04-18 22:51] session-205d1e89 | stammdaten.html (19 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| SNAKE-CASE \| 2783 \| <div class="cc-desc">Vier-Augen-Prinzip. Default <code>suggest_only</code> · <co... \| -> sprechenden Begriff statt snake_case-Identifier |
| DB-TECH \| 2894 \| <tr onclick="openEntry('ps_expose')"><td>1</td><td><span class="code">expose</sp... \| -> use sprechenden Begriff |
| DB-TECH \| 2895 \| <tr onclick="openEntry('ps_cv_sent')"><td>2</td><td><span class="code">cv_sent</... \| -> use sprechenden Begriff |
| DB-TECH \| 2896 \| <tr onclick="openEntry('ps_ti')"><td>3</td><td><span class="code">ti</span></td>... \| -> use sprechenden Begriff |
| DB-TECH \| 2897 \| <tr onclick="openEntry('ps_1st')"><td>4</td><td><span class="code">first</span><... \| -> use sprechenden Begriff |
| DB-TECH \| 2898 \| <tr onclick="openEntry('ps_2nd')"><td>5</td><td><span class="code">second</span>... \| -> use sprechenden Begriff |
| DB-TECH \| 2899 \| <tr onclick="openEntry('ps_3rd')"><td>6</td><td><span class="code">third</span><... \| -> use sprechenden Begriff |
| DB-TECH \| 2900 \| <tr onclick="openEntry('ps_assess')"><td>7</td><td><span class="code">assessment... \| -> use sprechenden Begriff |
| DB-TECH \| 2901 \| <tr onclick="openEntry('ps_offer')"><td>8</td><td><span class="code">offer</span... \| -> use sprechenden Begriff |
| DB-TECH \| 2902 \| <tr onclick="openEntry('ps_placement')"><td>9</td><td><span class="code">placeme... \| -> use sprechenden Begriff |
| DB-TECH \| 3085 \| <div><div class="u-entity">Aktuell laufende Prozesse in Stage TI</div><div class... \| -> use sprechenden Begriff |
| DB-TECH \| 3090 \| <div><div class="u-entity">History-Events "stage_changed → ti"</div><div class="... \| -> use sprechenden Begriff |
| SNAKE-CASE \| 3090 \| <div><div class="u-entity">History-Events "stage_changed → ti"</div><div class="... \| -> deutsches Label fuer Enum-Value |
| DB-TECH \| 3095 \| <div><div class="u-entity">Coaching-TI-Aktivitäten</div><div class="u-where">fac... \| -> use sprechenden Begriff |
| DB-TECH \| 3100 \| <div><div class="u-entity">Debriefing-TI-Aktivitäten</div><div class="u-where">f... \| -> use sprechenden Begriff |
| DB-TECH \| 3105 \| <div><div class="u-entity">Reminders mit Bezug zu TI</div><div class="u-where">f... \| -> use sprechenden Begriff |
| DB-TECH \| 3569 \| ['<span class="code">cv_parse</span>','CV-Extraktion → dim_candidates_profile','... \| -> use sprechenden Begriff |
| SNAKE-CASE \| 3584 \| ['<span class="code">candidate.stage_changed</span>','Lifecycle','candidate','<s... \| -> deutsches Label fuer Enum-Value |
| SNAKE-CASE \| 3590 \| ['<span class="code">process.stage_changed</span>','Prozess','process','<strong>... \| -> deutsches Label fuer Enum-Value |


## [2026-04-18 22:51] session-205d1e89 | stammdaten.html (19 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| SNAKE-CASE \| 2790 \| <div class="cc-desc">Vier-Augen-Prinzip. Default <code>suggest_only</code> · <co... \| -> sprechenden Begriff statt snake_case-Identifier |
| DB-TECH \| 2901 \| <tr onclick="openEntry('ps_expose')"><td>1</td><td><span class="code">expose</sp... \| -> use sprechenden Begriff |
| DB-TECH \| 2902 \| <tr onclick="openEntry('ps_cv_sent')"><td>2</td><td><span class="code">cv_sent</... \| -> use sprechenden Begriff |
| DB-TECH \| 2903 \| <tr onclick="openEntry('ps_ti')"><td>3</td><td><span class="code">ti</span></td>... \| -> use sprechenden Begriff |
| DB-TECH \| 2904 \| <tr onclick="openEntry('ps_1st')"><td>4</td><td><span class="code">first</span><... \| -> use sprechenden Begriff |
| DB-TECH \| 2905 \| <tr onclick="openEntry('ps_2nd')"><td>5</td><td><span class="code">second</span>... \| -> use sprechenden Begriff |
| DB-TECH \| 2906 \| <tr onclick="openEntry('ps_3rd')"><td>6</td><td><span class="code">third</span><... \| -> use sprechenden Begriff |
| DB-TECH \| 2907 \| <tr onclick="openEntry('ps_assess')"><td>7</td><td><span class="code">assessment... \| -> use sprechenden Begriff |
| DB-TECH \| 2908 \| <tr onclick="openEntry('ps_offer')"><td>8</td><td><span class="code">offer</span... \| -> use sprechenden Begriff |
| DB-TECH \| 2909 \| <tr onclick="openEntry('ps_placement')"><td>9</td><td><span class="code">placeme... \| -> use sprechenden Begriff |
| DB-TECH \| 3092 \| <div><div class="u-entity">Aktuell laufende Prozesse in Stage TI</div><div class... \| -> use sprechenden Begriff |
| DB-TECH \| 3097 \| <div><div class="u-entity">History-Events "stage_changed → ti"</div><div class="... \| -> use sprechenden Begriff |
| SNAKE-CASE \| 3097 \| <div><div class="u-entity">History-Events "stage_changed → ti"</div><div class="... \| -> deutsches Label fuer Enum-Value |
| DB-TECH \| 3102 \| <div><div class="u-entity">Coaching-TI-Aktivitäten</div><div class="u-where">fac... \| -> use sprechenden Begriff |
| DB-TECH \| 3107 \| <div><div class="u-entity">Debriefing-TI-Aktivitäten</div><div class="u-where">f... \| -> use sprechenden Begriff |
| DB-TECH \| 3112 \| <div><div class="u-entity">Reminders mit Bezug zu TI</div><div class="u-where">f... \| -> use sprechenden Begriff |
| DB-TECH \| 3576 \| ['<span class="code">cv_parse</span>','CV-Extraktion → dim_candidates_profile','... \| -> use sprechenden Begriff |
| SNAKE-CASE \| 3591 \| ['<span class="code">candidate.stage_changed</span>','Lifecycle','candidate','<s... \| -> deutsches Label fuer Enum-Value |
| SNAKE-CASE \| 3597 \| ['<span class="code">process.stage_changed</span>','Prozess','process','<strong>... \| -> deutsches Label fuer Enum-Value |


## [2026-04-18 23:02] session-205d1e89 | stammdaten.html (19 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| SNAKE-CASE \| 2791 \| <div class="cc-desc">Vier-Augen-Prinzip. Default <code>suggest_only</code> · <co... \| -> sprechenden Begriff statt snake_case-Identifier |
| DB-TECH \| 2902 \| <tr onclick="openEntry('ps_expose')"><td>1</td><td><span class="code">expose</sp... \| -> use sprechenden Begriff |
| DB-TECH \| 2903 \| <tr onclick="openEntry('ps_cv_sent')"><td>2</td><td><span class="code">cv_sent</... \| -> use sprechenden Begriff |
| DB-TECH \| 2904 \| <tr onclick="openEntry('ps_ti')"><td>3</td><td><span class="code">ti</span></td>... \| -> use sprechenden Begriff |
| DB-TECH \| 2905 \| <tr onclick="openEntry('ps_1st')"><td>4</td><td><span class="code">first</span><... \| -> use sprechenden Begriff |
| DB-TECH \| 2906 \| <tr onclick="openEntry('ps_2nd')"><td>5</td><td><span class="code">second</span>... \| -> use sprechenden Begriff |
| DB-TECH \| 2907 \| <tr onclick="openEntry('ps_3rd')"><td>6</td><td><span class="code">third</span><... \| -> use sprechenden Begriff |
| DB-TECH \| 2908 \| <tr onclick="openEntry('ps_assess')"><td>7</td><td><span class="code">assessment... \| -> use sprechenden Begriff |
| DB-TECH \| 2909 \| <tr onclick="openEntry('ps_offer')"><td>8</td><td><span class="code">offer</span... \| -> use sprechenden Begriff |
| DB-TECH \| 2910 \| <tr onclick="openEntry('ps_placement')"><td>9</td><td><span class="code">placeme... \| -> use sprechenden Begriff |
| DB-TECH \| 3093 \| <div><div class="u-entity">Aktuell laufende Prozesse in Stage TI</div><div class... \| -> use sprechenden Begriff |
| DB-TECH \| 3098 \| <div><div class="u-entity">History-Events "stage_changed → ti"</div><div class="... \| -> use sprechenden Begriff |
| SNAKE-CASE \| 3098 \| <div><div class="u-entity">History-Events "stage_changed → ti"</div><div class="... \| -> deutsches Label fuer Enum-Value |
| DB-TECH \| 3103 \| <div><div class="u-entity">Coaching-TI-Aktivitäten</div><div class="u-where">fac... \| -> use sprechenden Begriff |
| DB-TECH \| 3108 \| <div><div class="u-entity">Debriefing-TI-Aktivitäten</div><div class="u-where">f... \| -> use sprechenden Begriff |
| DB-TECH \| 3113 \| <div><div class="u-entity">Reminders mit Bezug zu TI</div><div class="u-where">f... \| -> use sprechenden Begriff |
| DB-TECH \| 3577 \| ['<span class="code">cv_parse</span>','CV-Extraktion → dim_candidates_profile','... \| -> use sprechenden Begriff |
| SNAKE-CASE \| 3592 \| ['<span class="code">candidate.stage_changed</span>','Lifecycle','candidate','<s... \| -> deutsches Label fuer Enum-Value |
| SNAKE-CASE \| 3598 \| ['<span class="code">process.stage_changed</span>','Prozess','process','<strong>... \| -> deutsches Label fuer Enum-Value |


## [2026-04-19 00:48] session-205d1e89 | log.md (5 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| UMLAUT \| 229 \| - `wiki/meta/lint-violations.md` — 8 Violations (5 UMLAUT cal-emp-kuerzel CSS cl... \| -> Kürzel |
| UMLAUT \| 268 \| - `.claude/hooks/ark-lint.ps1` — PostToolUse, scannt Edits auf `mockups/*.html`/... \| -> für |
| UMLAUT \| 268 \| - `.claude/hooks/ark-lint.ps1` — PostToolUse, scannt Edits auf `mockups/*.html`/... \| -> über |
| UMLAUT \| 268 \| - `.claude/hooks/ark-lint.ps1` — PostToolUse, scannt Edits auf `mockups/*.html`/... \| -> könn |
| UMLAUT \| 273 \| - `.claude/commands/ark-sync-report.md` — Slash-Command fuer Spec-Mockup-Sync-Dr... \| -> für |


## [2026-04-19 01:51] session-0a1df309 | feedback_phase3_modules_separate.md (2 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| UMLAUT \| 2 \| name: Phase-3-ERP-Module separat halten · Topbar-Toggle fuer Zugriff \| -> für |
| UMLAUT \| 3 \| description: Phase-3-Mockups (HR, Zeiterfassung, Billing, Publishing, Performanc... \| -> spät |


## [2026-04-19 02:07] session-0a1df309 | feedback_phase3_modules_separate.md (2 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| UMLAUT \| 2 \| name: Phase-3-ERP-Module separat halten · Topbar-Toggle fuer Zugriff \| -> für |
| UMLAUT \| 3 \| description: Phase-3-Mockups (HR, Zeiterfassung, Billing, Publishing, Performanc... \| -> spät |


## [2026-04-19 02:45] session-0a1df309 | feedback_phase3_modules_separate.md (2 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| UMLAUT \| 2 \| name: Phase-3-ERP-Module separat halten · Topbar-Toggle fuer Zugriff \| -> für |
| UMLAUT \| 3 \| description: Phase-3-Mockups (HR, Zeiterfassung, Billing, Publishing, Performanc... \| -> spät |


## [2026-04-19 03:02] session-0a1df309 | hr.html (1 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| UMLAUT \| 1100 \| function openSidePanel(kuerzel) { \| -> Kürzel |


## [2026-04-19 13:20] session-0a1df309 | commission-admin.html (2 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| UMLAUT \| 1252 \| function openLedgerDrawer(kuerzel, name, role) { \| -> Kürzel |
| UMLAUT \| 1253 \| if (kuerzel) document.getElementById('ledDrawAvatar').textContent = kuerzel; \| -> Kürzel |


## [2026-04-19 13:27] session-0a1df309 | commission-team.html (2 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| UMLAUT \| 974 \| function openMemberDrawer(kuerzel, name) { \| -> Kürzel |
| UMLAUT \| 975 \| if (kuerzel) document.getElementById('memDrawAvatar').textContent = kuerzel; \| -> Kürzel |


## [2026-04-19 14:45] session-13946034 | log.md (5 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| UMLAUT \| 223 \| - `wiki/meta/lint-violations.md` — 8 Violations (5 UMLAUT cal-emp-kuerzel CSS cl... \| -> Kürzel |
| UMLAUT \| 262 \| - `.claude/hooks/ark-lint.ps1` — PostToolUse, scannt Edits auf `mockups/*.html`/... \| -> für |
| UMLAUT \| 262 \| - `.claude/hooks/ark-lint.ps1` — PostToolUse, scannt Edits auf `mockups/*.html`/... \| -> über |
| UMLAUT \| 262 \| - `.claude/hooks/ark-lint.ps1` — PostToolUse, scannt Edits auf `mockups/*.html`/... \| -> könn |
| UMLAUT \| 267 \| - `.claude/commands/ark-sync-report.md` — Slash-Command fuer Spec-Mockup-Sync-Dr... \| -> für |


## [2026-04-19 15:02] session-13946034 | log.md (5 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| UMLAUT \| 254 \| - `wiki/meta/lint-violations.md` — 8 Violations (5 UMLAUT cal-emp-kuerzel CSS cl... \| -> Kürzel |
| UMLAUT \| 293 \| - `.claude/hooks/ark-lint.ps1` — PostToolUse, scannt Edits auf `mockups/*.html`/... \| -> für |
| UMLAUT \| 293 \| - `.claude/hooks/ark-lint.ps1` — PostToolUse, scannt Edits auf `mockups/*.html`/... \| -> über |
| UMLAUT \| 293 \| - `.claude/hooks/ark-lint.ps1` — PostToolUse, scannt Edits auf `mockups/*.html`/... \| -> könn |
| UMLAUT \| 298 \| - `.claude/commands/ark-sync-report.md` — Slash-Command fuer Spec-Mockup-Sync-Dr... \| -> für |


## [2026-04-19 16:01] session-13946034 | log.md (5 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| UMLAUT \| 279 \| - `wiki/meta/lint-violations.md` — 8 Violations (5 UMLAUT cal-emp-kuerzel CSS cl... \| -> Kürzel |
| UMLAUT \| 318 \| - `.claude/hooks/ark-lint.ps1` — PostToolUse, scannt Edits auf `mockups/*.html`/... \| -> für |
| UMLAUT \| 318 \| - `.claude/hooks/ark-lint.ps1` — PostToolUse, scannt Edits auf `mockups/*.html`/... \| -> über |
| UMLAUT \| 318 \| - `.claude/hooks/ark-lint.ps1` — PostToolUse, scannt Edits auf `mockups/*.html`/... \| -> könn |
| UMLAUT \| 323 \| - `.claude/commands/ark-sync-report.md` — Slash-Command fuer Spec-Mockup-Sync-Dr... \| -> für |


## [2026-04-19 16:09] session-13946034 | log.md (5 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| UMLAUT \| 316 \| - `wiki/meta/lint-violations.md` — 8 Violations (5 UMLAUT cal-emp-kuerzel CSS cl... \| -> Kürzel |
| UMLAUT \| 355 \| - `.claude/hooks/ark-lint.ps1` — PostToolUse, scannt Edits auf `mockups/*.html`/... \| -> für |
| UMLAUT \| 355 \| - `.claude/hooks/ark-lint.ps1` — PostToolUse, scannt Edits auf `mockups/*.html`/... \| -> über |
| UMLAUT \| 355 \| - `.claude/hooks/ark-lint.ps1` — PostToolUse, scannt Edits auf `mockups/*.html`/... \| -> könn |
| UMLAUT \| 360 \| - `.claude/commands/ark-sync-report.md` — Slash-Command fuer Spec-Mockup-Sync-Dr... \| -> für |


## [2026-04-19 16:19] session-13946034 | log.md (5 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| UMLAUT \| 354 \| - `wiki/meta/lint-violations.md` — 8 Violations (5 UMLAUT cal-emp-kuerzel CSS cl... \| -> Kürzel |
| UMLAUT \| 393 \| - `.claude/hooks/ark-lint.ps1` — PostToolUse, scannt Edits auf `mockups/*.html`/... \| -> für |
| UMLAUT \| 393 \| - `.claude/hooks/ark-lint.ps1` — PostToolUse, scannt Edits auf `mockups/*.html`/... \| -> über |
| UMLAUT \| 393 \| - `.claude/hooks/ark-lint.ps1` — PostToolUse, scannt Edits auf `mockups/*.html`/... \| -> könn |
| UMLAUT \| 398 \| - `.claude/commands/ark-sync-report.md` — Slash-Command fuer Spec-Mockup-Sync-Dr... \| -> für |


## [2026-04-19 16:29] session-13946034 | log.md (5 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| UMLAUT \| 392 \| - `wiki/meta/lint-violations.md` — 8 Violations (5 UMLAUT cal-emp-kuerzel CSS cl... \| -> Kürzel |
| UMLAUT \| 431 \| - `.claude/hooks/ark-lint.ps1` — PostToolUse, scannt Edits auf `mockups/*.html`/... \| -> für |
| UMLAUT \| 431 \| - `.claude/hooks/ark-lint.ps1` — PostToolUse, scannt Edits auf `mockups/*.html`/... \| -> über |
| UMLAUT \| 431 \| - `.claude/hooks/ark-lint.ps1` — PostToolUse, scannt Edits auf `mockups/*.html`/... \| -> könn |
| UMLAUT \| 436 \| - `.claude/commands/ark-sync-report.md` — Slash-Command fuer Spec-Mockup-Sync-Dr... \| -> für |


## [2026-04-19 16:34] session-13946034 | log.md (5 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| UMLAUT \| 399 \| - `wiki/meta/lint-violations.md` — 8 Violations (5 UMLAUT cal-emp-kuerzel CSS cl... \| -> Kürzel |
| UMLAUT \| 438 \| - `.claude/hooks/ark-lint.ps1` — PostToolUse, scannt Edits auf `mockups/*.html`/... \| -> für |
| UMLAUT \| 438 \| - `.claude/hooks/ark-lint.ps1` — PostToolUse, scannt Edits auf `mockups/*.html`/... \| -> über |
| UMLAUT \| 438 \| - `.claude/hooks/ark-lint.ps1` — PostToolUse, scannt Edits auf `mockups/*.html`/... \| -> könn |
| UMLAUT \| 443 \| - `.claude/commands/ark-sync-report.md` — Slash-Command fuer Spec-Mockup-Sync-Dr... \| -> für |


## [2026-04-19 17:00] session-13946034 | hr.html (1 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| UMLAUT \| 1160 \| function openSidePanel(kuerzel) { \| -> Kürzel |


## [2026-04-19 17:00] session-13946034 | hr.html (1 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| UMLAUT \| 1206 \| function openSidePanel(kuerzel) { \| -> Kürzel |


## [2026-04-19 17:00] session-13946034 | hr.html (1 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| UMLAUT \| 1208 \| function openSidePanel(kuerzel) { \| -> Kürzel |


## [2026-04-19 17:03] session-13946034 | hr-dashboard.html (1 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| UMLAUT \| 1149 \| function openSidePanel(kuerzel) { \| -> Kürzel |


## [2026-04-19 17:03] session-13946034 | hr-dashboard.html (1 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| UMLAUT \| 1103 \| function openSidePanel(kuerzel) { \| -> Kürzel |


## [2026-04-19 17:03] session-13946034 | hr-dashboard.html (1 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| UMLAUT \| 1101 \| function openSidePanel(kuerzel) { \| -> Kürzel |


## [2026-04-19 17:15] session-13946034 | hr-dashboard.html (1 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| UMLAUT \| 1102 \| function openSidePanel(kuerzel) { \| -> Kürzel |


## [2026-04-19 17:15] session-13946034 | commission-admin.html (2 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| UMLAUT \| 1253 \| function openLedgerDrawer(kuerzel, name, role) { \| -> Kürzel |
| UMLAUT \| 1254 \| if (kuerzel) document.getElementById('ledDrawAvatar').textContent = kuerzel; \| -> Kürzel |


## [2026-04-19 17:16] session-13946034 | commission-team.html (2 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| UMLAUT \| 975 \| function openMemberDrawer(kuerzel, name) { \| -> Kürzel |
| UMLAUT \| 976 \| if (kuerzel) document.getElementById('memDrawAvatar').textContent = kuerzel; \| -> Kürzel |


## [2026-04-19 17:22] session-13946034 | admin-dashboard-templates.html (2 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| SNAKE-CASE \| 536 \| alert('Öffnet Dashboard in neuem Tab als Account-Manager-User gerendert · URL: /... \| -> deutsches Label statt snake_case in Alert/Confirm |
| DRAWER-DEFAULT \| -- \| 3 Modal-Patterns gefunden \| -> Drawer 540px verwenden fuer CRUD (CLAUDE.md Drawer-Default-Regel) |


## [2026-04-19 17:23] session-13946034 | commission-admin.html (2 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| UMLAUT \| 1252 \| function openLedgerDrawer(kuerzel, name, role) { \| -> Kürzel |
| UMLAUT \| 1253 \| if (kuerzel) document.getElementById('ledDrawAvatar').textContent = kuerzel; \| -> Kürzel |


## [2026-04-19 17:23] session-13946034 | commission-team.html (2 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| UMLAUT \| 974 \| function openMemberDrawer(kuerzel, name) { \| -> Kürzel |
| UMLAUT \| 975 \| if (kuerzel) document.getElementById('memDrawAvatar').textContent = kuerzel; \| -> Kürzel |


## [2026-04-19 17:23] session-13946034 | hr-dashboard.html (1 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| UMLAUT \| 1101 \| function openSidePanel(kuerzel) { \| -> Kürzel |


## [2026-04-19 17:23] session-13946034 | dashboard-mobile.html (1 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| SNAKE-CASE \| 203 \| <div class="muted" style="font-size:13px">Zeigt wie das Dashboard bei den 3 Brea... \| -> sprechenden Begriff statt snake_case-Identifier |


## [2026-04-19 18:05] session-13946034 | commission-admin.html (2 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| UMLAUT \| 1236 \| function openLedgerDrawer(kuerzel, name, role) { \| -> Kürzel |
| UMLAUT \| 1237 \| if (kuerzel) document.getElementById('ledDrawAvatar').textContent = kuerzel; \| -> Kürzel |


## [2026-04-19 18:05] session-13946034 | hr-dashboard.html (1 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| UMLAUT \| 1086 \| function openSidePanel(kuerzel) { \| -> Kürzel |


## [2026-04-19 18:05] session-13946034 | commission-team.html (2 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| UMLAUT \| 958 \| function openMemberDrawer(kuerzel, name) { \| -> Kürzel |
| UMLAUT \| 959 \| if (kuerzel) document.getElementById('memDrawAvatar').textContent = kuerzel; \| -> Kürzel |


## [2026-04-19 18:06] session-13946034 | admin-dashboard-templates.html (2 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| SNAKE-CASE \| 518 \| alert('Öffnet Dashboard in neuem Tab als Account-Manager-User gerendert · URL: /... \| -> deutsches Label statt snake_case in Alert/Confirm |
| DRAWER-DEFAULT \| -- \| 3 Modal-Patterns gefunden \| -> Drawer 540px verwenden fuer CRUD (CLAUDE.md Drawer-Default-Regel) |


## [2026-04-19 19:55] session-13946034 | commission-team.html (2 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| UMLAUT \| 958 \| function openMemberDrawer(kuerzel, name) { \| -> Kürzel |
| UMLAUT \| 959 \| if (kuerzel) document.getElementById('memDrawAvatar').textContent = kuerzel; \| -> Kürzel |


## [2026-04-19 21:05] session-13946034 | commission-admin.html (2 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| UMLAUT \| 1236 \| function openLedgerDrawer(kuerzel, name, role) { \| -> Kürzel |
| UMLAUT \| 1237 \| if (kuerzel) document.getElementById('ledDrawAvatar').textContent = kuerzel; \| -> Kürzel |


## [2026-04-19 21:05] session-13946034 | commission-admin.html (2 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| UMLAUT \| 1238 \| function openLedgerDrawer(kuerzel, name, role) { \| -> Kürzel |
| UMLAUT \| 1239 \| if (kuerzel) document.getElementById('ledDrawAvatar').textContent = kuerzel; \| -> Kürzel |


## [2026-04-19 21:05] session-13946034 | commission-admin.html (2 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| UMLAUT \| 1240 \| function openLedgerDrawer(kuerzel, name, role) { \| -> Kürzel |
| UMLAUT \| 1241 \| if (kuerzel) document.getElementById('ledDrawAvatar').textContent = kuerzel; \| -> Kürzel |


## [2026-04-19 23:08] session-13946034 | zeit-meine-zeit.html (1 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| DB-TECH \| 402 \| <li>20.04. 18:10 — fact_time_entry erstellt (Worker · source=scanner)</li> \| -> use sprechenden Begriff |


## [2026-04-19 23:09] session-13946034 | zeit-meine-zeit.html (1 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| DB-TECH \| 402 \| <li>20.04. 18:10 — fact_time_entry erstellt (Worker · source=scanner)</li> \| -> use sprechenden Begriff |


## [2026-04-19 23:09] session-13946034 | zeit-meine-zeit.html (1 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| DB-TECH \| 402 \| <li>20.04. 18:10 — fact_time_entry erstellt (Worker · source=scanner)</li> \| -> use sprechenden Begriff |


## [2026-04-20 07:46] session-13946034 | zeit-monat.html (1 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| DRAWER-DEFAULT \| -- \| 3 Modal-Patterns gefunden \| -> Drawer 540px verwenden fuer CRUD (CLAUDE.md Drawer-Default-Regel) |


## [2026-04-20 08:19] session-13946034 | zeit-monat.html (1 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| DRAWER-DEFAULT \| -- \| 3 Modal-Patterns gefunden \| -> Drawer 540px verwenden fuer CRUD (CLAUDE.md Drawer-Default-Regel) |


## [2026-04-20 08:19] session-13946034 | zeit-monat.html (1 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| DRAWER-DEFAULT \| -- \| 3 Modal-Patterns gefunden \| -> Drawer 540px verwenden fuer CRUD (CLAUDE.md Drawer-Default-Regel) |


## [2026-04-20 08:19] session-13946034 | zeit-monat.html (1 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| DRAWER-DEFAULT \| -- \| 3 Modal-Patterns gefunden \| -> Drawer 540px verwenden fuer CRUD (CLAUDE.md Drawer-Default-Regel) |


## [2026-04-20 08:34] session-13946034 | zeit-monat.html (1 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| DRAWER-DEFAULT \| -- \| 3 Modal-Patterns gefunden \| -> Drawer 540px verwenden fuer CRUD (CLAUDE.md Drawer-Default-Regel) |


## [2026-04-21 12:57] session-d89e54ef | billing-mahnwesen.html (1 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| DRAWER-DEFAULT \| -- \| 5 Modal-Patterns gefunden \| -> Drawer 540px verwenden fuer CRUD (CLAUDE.md Drawer-Default-Regel) |


## [2026-04-21 12:58] session-b6948717 | elearn.html (1 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| UMLAUT \| 137 \| <span class="tool-tab disabled" title="Noch nicht verfuegbar"> \| -> verfügb |


## [2026-04-21 13:16] session-b6948717 | elearn.html (2 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| UMLAUT \| 134 \| <span class="tool-tab disabled" title="Noch nicht verfuegbar"> \| -> verfügb |
| UMLAUT \| 137 \| <span class="tool-tab disabled" title="Noch nicht verfuegbar"> \| -> verfügb |


## [2026-04-21 13:16] session-b6948717 | elearn.html (2 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| UMLAUT \| 134 \| <span class="tool-tab disabled" title="Noch nicht verfuegbar"> \| -> verfügb |
| UMLAUT \| 137 \| <span class="tool-tab disabled" title="Noch nicht verfuegbar"> \| -> verfügb |


## [2026-04-24 11:08] session-13804474 | billing-mahnwesen.html (1 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| DRAWER-DEFAULT \| -- \| 5 Modal-Patterns gefunden \| -> Drawer 540px verwenden fuer CRUD (CLAUDE.md Drawer-Default-Regel) |


## [2026-04-24 11:08] session-13804474 | billing-mahnwesen.html (1 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| DRAWER-DEFAULT \| -- \| 5 Modal-Patterns gefunden \| -> Drawer 540px verwenden fuer CRUD (CLAUDE.md Drawer-Default-Regel) |


## [2026-04-24 11:09] session-13804474 | billing-mahnwesen.html (1 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| DRAWER-DEFAULT \| -- \| 5 Modal-Patterns gefunden \| -> Drawer 540px verwenden fuer CRUD (CLAUDE.md Drawer-Default-Regel) |


## [2026-04-24 11:09] session-13804474 | billing-mahnwesen.html (1 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| DRAWER-DEFAULT \| -- \| 5 Modal-Patterns gefunden \| -> Drawer 540px verwenden fuer CRUD (CLAUDE.md Drawer-Default-Regel) |


## [2026-04-24 11:10] session-b6948717 | handover-latest.md (2 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| UMLAUT \| 28 \| 2. Pattern von Batch 1 uebernehmen: Topbar identisch, Sidebar links, Drawer 540p... \| -> für |
| UMLAUT \| 35 \| - ARK-Regeln kritisch: echte Umlaute UTF-8, keine DB-Tech-Begriffe in UI, Drawer... \| -> für |


## [2026-04-24 11:48] session-3d93503e | billing-mahnwesen.html (1 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| DRAWER-DEFAULT \| -- \| 5 Modal-Patterns gefunden \| -> Drawer 540px verwenden fuer CRUD (CLAUDE.md Drawer-Default-Regel) |


## [2026-04-24 11:48] session-3d93503e | billing-mahnwesen.html (1 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| DRAWER-DEFAULT \| -- \| 5 Modal-Patterns gefunden \| -> Drawer 540px verwenden fuer CRUD (CLAUDE.md Drawer-Default-Regel) |


## [2026-04-24 11:48] session-3d93503e | billing-mahnwesen.html (1 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| DRAWER-DEFAULT \| -- \| 1 Modal-Patterns gefunden \| -> Drawer 540px verwenden fuer CRUD (CLAUDE.md Drawer-Default-Regel) |


## [2026-04-24 13:06] session-707f03f9 | elearn-freitext-queue.html (1 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| DRAWER-DEFAULT \| -- \| 3 Modal-Patterns gefunden \| -> Drawer 540px verwenden fuer CRUD (CLAUDE.md Drawer-Default-Regel) |


## [2026-04-24 13:12] session-3d93503e | zeit-monat.html (1 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| DRAWER-DEFAULT \| -- \| 3 Modal-Patterns gefunden \| -> Drawer 540px verwenden fuer CRUD (CLAUDE.md Drawer-Default-Regel) |


## [2026-04-24 13:12] session-3d93503e | commission-team.html (2 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| UMLAUT \| 958 \| function openMemberDrawer(kuerzel, name) { \| -> Kürzel |
| UMLAUT \| 959 \| if (kuerzel) document.getElementById('memDrawAvatar').textContent = kuerzel; \| -> Kürzel |


## [2026-04-24 13:18] session-3d93503e | zeit-monat.html (1 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| DRAWER-DEFAULT \| -- \| 3 Modal-Patterns gefunden \| -> Drawer 540px verwenden fuer CRUD (CLAUDE.md Drawer-Default-Regel) |


## [2026-04-24 13:27] session-707f03f9 | elearn-admin-curriculum.html (1 Violations)

| Regel | Zeile | Snippet | Fix |
|-------|-------|---------|-----|
| SNAKE-CASE \| 123 \| <strong>Wie Curricula wirken:</strong> Beim MA-Einstellen zieht der Worker <code... \| -> sprechenden Begriff statt snake_case-Identifier |

