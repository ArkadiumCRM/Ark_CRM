# ARK CRM — Scraper-Modul Patch v0.1 → v0.2

**Stand:** 17.04.2026
**Vorgänger:** `ARK_SCRAPER_MODUL_SCHEMA_v0_1.md` + `ARK_SCRAPER_MODUL_INTERACTIONS_v0_1.md`
**Auslöser:** Mockup-Umsetzung `mockups/scraper.html` (17.04.2026) — Mockup-First-Workflow
**Scope:** UI/UX-Präzisierungen · keine Änderungen an Datenbankschema, Events, Workers, Endpunkten
**Vorrang:** Stammdaten > dieses Patch > v0.1 Schema > v0.1 Interactions > Mockups

---

## 0. KURZÜBERSICHT

v0.1 bleibt Basis. v0.2 konsolidiert die UI-Entscheidungen, die bei der Mockup-Umsetzung getroffen wurden. **Keine Breaking Changes** für Backend/Datenbank/Stammdaten.

| # | Änderung | Scope |
|---|----------|-------|
| P1 | Single-File-Mockup statt 7 separater Files | UI-Architektur |
| P2 | Toggle Tabelle / Kanban in Review-Queue | Tab 2 |
| P3 | Phase-1.5-Features als Stubs im Mockup sichtbar | Tab 4 |
| P4 | Fully-replicated Accept-Drawers für alle 10 Finding-Typen | Tab 2 |
| P5 | Header-Button „Configs" entfernt (Redundanz mit Tab 4) | Header |
| P6 | Admin-Redundanzen aus Tab 4 Admin-Settings entfernt | Tab 4 |
| P7 | Critical-Flow `protection_violation_detected` im Accept-Drawer fully modelliert | Cross-Entity |
| P8 | AI-Prompt-Editor mit Test-Button im Config-Drawer | Tab 4 |

---

## P1 — Single-File-Mockup (überschreibt v0.1 § 1.3)

**v0.1:** 7 separate HTMLs geplant (`scraper_dashboard_v1.html` … `scraper_run_detail_v1.html`).

**v0.2:** **Ein Single-File-Mockup** `mockups/scraper.html` mit 6 internen Tabs.

**Begründung:**
- Konsistenz zu anderen Top-Level-Modulen (`dok-generator.html`, `email-kalender.html`, `reminders.html`)
- Tab-Switch ohne Page-Reload
- Einfacheres State-Handling für WebSocket-Live-Updates
- Snapshot-Bar über alle Tabs mit gemeinsamem State
- Drawer-Stack (Detail → Accept → Confirm) funktioniert nur innerhalb eines Mockups sauber

**Überschreibt v0.1 § 1.3 vollständig:**

| # | Tab | Datei |
|---|-----|-------|
| 1–6 | Alle Tabs | `mockups/scraper.html` (Single-File mit 6 internen Tabs, Routing via `switchTab()`) |
| — | Run-Detail | Inline Drawer `drawer-wide` (760px) · Vollansicht-Route `/scraper/runs/[id]` als separater Subpage folgt in P1.5 |

---

## P2 — View-Toggle Tabelle / Kanban (präzisiert v0.1 § 6.1)

**v0.1:** "Kanban mit 4 Spalten nach Confidence + Typ, oder Tabelle mit Filter."

**v0.2:** **Toggle-Pattern.** Default: Tabelle. Kanban als alternative View per User-Preference.

- Toggle-Button oben rechts in der Review-Queue-Toolbar
- `localStorage.scraper-rq-view` persistiert Auswahl
- Tabelle: Bulk-Select, dichte Darstellung, ARK-Listen-Standard
- Kanban: 4 Spalten `Needs AM Review` / `Standard 60–84%` / `High ≥85%` / `Kritisch` (Schutzfrist/Anomalie)

---

## P3 — Phase 1.5 als sichtbare Stubs (erweitert v0.1 § 6.7 + § 8.2)

**v0.1:** Auto-Accept-Schwelle und AI-Prompt-Editor als Phase 1.5 angekündigt.

**v0.2:** Im v1-Mockup sind Phase-1.5-Features **sichtbar ausgebaut** mit Phase-Badge `Phase 1.5`:

- Auto-Accept-Schwelle editierbar in Admin-Settings (NULL = Default)
- Confidence-Schwellen pro Finding-Typ editierbar im Config-Drawer
- AI-Prompt-Editor mit Test-Button im Config-Drawer

**Warum im v1:** Phase-1.5-Features visuell zeigen, um UI-Flow zu validieren, bevor Backend-Implementierung startet. Badge macht Phase-Zuordnung klar.

---

## P4 — Accept-Drawer pro Finding-Typ fully replicated (erweitert v0.1 Interactions § 3)

**v0.1 Interactions TEIL 3:** Beschreibt Accept-Flow pro Finding-Typ high-level.

**v0.2:** Alle 10 Finding-Typen haben **eigenen Accept-Drawer-Body** mit typ-spezifischen Feldern:

| Finding-Typ | Accept-Drawer-Inhalt |
|-------------|----------------------|
| `new_contact` | Kontakt-Erstellungs-Formular (Vorname/Nachname/Funktion/Email/Tel/Abteilung) + Kandidaten-Matching-Preview + Kontakt-Kandidat-Regel-Hinweis |
| `contact_changed` | Diff-Preview (alt → neu) + Update-Modus-Radio (Überschreiben / nur Notiz) |
| `contact_disappeared` | Confirm-Dialog + 3 Aktionen (Left Company / Inaktiv / Belassen) + Optional Candidate-Werdegang-Update |
| `new_vacancy` | Job-Erstellungs-Formular + Bestätigungs-Modus (Scraper-Vorschlag vs. Direkt-Vakanz) + Post-Accept-Flow-Liste |
| `vacancy_changed` | Diff-Preview + Merge-vs-Note-Radio |
| `vacancy_disappeared` | 3-Status-Vorschlag (Geschlossen / Besetzt / Belassen) |
| `person_job_change` | **Critical-Flow** · Schutzfrist-Match-Card + 3 Claim-Aktionen · siehe P7 |
| `group_suggestion` | Firmengruppen-Formular + Mitglieder-Checklist + Rückwirkende-Schutzfrist-Option |
| `stammdaten_drift` | Diff-Preview + 3 Aktionen (Update / Notiz / Alert raisen) |
| `anomaly_detected` | Anomalie-Details-Card + 3 Aktionen (Alert / Watch / Ignorieren) + Folge-Aktion-Empfehlung |

---

## P5 — Header-Button „Configs" entfernt

**v0.1 § 4.3:** Quick-Actions listeten „▶ Jetzt scrapen (Bulk) / ⚙ Configs / 📊 Report".

**v0.2:** `⚙ Configs` aus Header **entfernt** (Redundanz zu Tab 4). Header-Actions jetzt:
- `▶ Jetzt scrapen (Bulk)` (unverändert)
- `📊 Report` (unverändert)

---

## P6 — Admin-Redundanzen entfernt (Tab 4 Admin-Settings)

**Kontext:** `admin.html` Tab 6 Sub-6-4 "Global-Settings" hat bereits:
- User-Agent-Rotation
- Request-Timeout
- Retry-Policy (system-weit, 3 Retries / 2s · 4s · 8s)
- Circuit-Breaker-Schwelle
- Proxy-Pool

Plus `admin.html` Tab 1 Feature-Flag `scraper_max_concurrent`.

**Entfernt aus scraper.html Tab 4 Admin-Settings:**
- „Retry-Versuche (max)" — lebt in admin.html Tab 6-4 Retry-Policy
- „Parallele Runs system-weit" — lebt in admin.html Feature-Flag

**Belassen (scraper-business, nicht infrastrukturell):**
- Auto-Accept-Schwelle (Phase 1.5)
- N-Strike-Disable-Schwelle
- Raw-HTML-Retention Success (7 Tage Default)
- Raw-HTML-Retention Error (30 Tage Default)

**Info-Banner** in Admin-Settings mit Link zu `admin.html#tab-6`.

**Per-Typ-Retry im Config-Drawer bleibt** — andere Ebene (HTTP-Scraper-Level vs. Worker-Pool-Level).

### Single-Source-of-Truth-Aufteilung

| Feature | Lebt in |
|---------|---------|
| Scraper-Typen-Registry (7 Typen) | scraper.html Tab 4 |
| AI-Prompts pro Typ | scraper.html Tab 4 Config-Drawer |
| Confidence-Schwellen pro Typ | scraper.html Tab 4 Config-Drawer |
| Account-Overrides (read-only Liste) | scraper.html Tab 4 |
| Account-Overrides (bearbeiten) | Account-Detailseite Tab „Scraping-Config" |
| Run-Historie (inhaltlich) | scraper.html Tab 3 |
| Findings + Review-Queue | scraper.html Tab 2 |
| Business-Alerts (9 Typen) | scraper.html Tab 5 |
| Business-History (13 Events) | scraper.html Tab 6 |
| Circuit-Breaker-Infrastruktur (Worker-Pool-Level) | admin.html Tab 5 Automation |
| User-Agent / Proxy-Pool / Retry-Policy (system-weit) | admin.html Tab 6 Sub-6-4 |
| `scraper_max_concurrent` Feature-Flag | admin.html Tab 1 |
| Scraper-Alert-Notification-Template | admin.html Tab 7 Notifications |

**admin.html Tab 6 Sub-6-1/6-2/6-3** (Jobs/Run-History/Alerts) **sollten in einem Folge-Patch entfernt werden** (sind Duplikate zu scraper.html Tab 3/4/5). Scope dieses Patches: nur scraper.html aufgeräumt. admin.html-Cleanup: offen.

---

## P7 — Schutzfrist-Critical-Flow im Accept-Drawer (erweitert v0.1 Interactions TEIL 8c)

**v0.1 Interactions TEIL 8c:** Beschreibt den Saga-Flow high-level.

**v0.2:** Accept-Drawer für `person_job_change` zeigt:

1. **Critical-Bar** oben: „🚨 Schutzfrist aktiv — Kritischer Flow"
2. **Job-Wechsel-Details** (Kandidat, alter/neuer AG, Detection-Quelle)
3. **Schutzfrist-Match-Card** (roter Background, läuft-noch-Angabe)
4. **3 Claim-Aktionen** (Radio):
   - „Claim-Prozess öffnen" (Default)
   - „Kandidat kontaktieren" (Aktivität anlegen, noch kein Claim)
   - „Kein Claim, nur als verletzt markieren"
5. **Nach-Übernahme-Flow-Liste:**
   - Schutzfrist → Status: Claim-pending
   - Critical Alert `protection_violation_detected`
   - Push an Admin + Owner-AM
   - Kandidat-Werdegang-Update

---

## P8 — AI-Prompt-Editor mit Test-Button (präzisiert v0.1 § 8.2)

**v0.1 § 8.2:** "AI-Extraktions-Prompts (für LLM-basierte Scraper)".

**v0.2:** Config-Drawer pro Scraper-Typ enthält:
- **Prompt-Editor** (Textarea links, max 400 Zeilen, Syntax-Highlight optional in P2)
- **Test-Output-Panel** (rechts, Mock-Response bei Test-Run)
- **Test-Button** („🧪 Prompt testen") — Mock-Call, zeigt Tokens in/out + Latenz
- **Versionierung** — Speichern inkrementiert `current_version` (Minor-Bump `vX.Y` → `vX.Y+1`)
- **Version-Snapshot:** Running Runs nutzen Snapshot-Version, neue Runs die aktuelle
- **Prompt-Version-History-Link** (Phase 1.5+)

Pro Scraper-Typ-Template (Beispiele für v0.2-Mockup):
- `team_page` — Personen-Extraktion mit firstName/lastName/function/email/phone/department
- `career_page` — Vakanzen mit title/location/employmentType/startDate/workload/department
- `impressum` — management/hqAddress/uid/agbLastChanged
- `reports` — employeeCount-Delta + revenue-Delta + keyChanges (Sonnet 4.6 statt Haiku wegen PDF-Grösse)

---

## CROSS-REFERENCES (unverändert aus v0.1)

- Datenbank-Schema: v0.1 § 14 (6 fact_scraper_* + 2 dim_scraper_*)
- Events: v0.1 Interactions TEIL 13 (13 Events inkl. `finding_marked_low_confidence`)
- RBAC: v0.1 § 13
- Sagas: v0.1 Interactions TEIL 8 (Cross-Entity-Integrationen)
- Scheduling-Formel: v0.1 § 8.4 (`effective_interval = base_interval × temp_factor × class_factor`)

**Alle o.g. Sections bleiben in Kraft aus v0.1.**

---

## GRUNDLAGEN-SYNC-STATUS (17.04.2026)

| Datei | Status | Action |
|-------|--------|--------|
| `ARK_FRONTEND_FREEZE_v1_10.md` § 4d.8 | ⚠ Mockup-Reference | Update: „7 separate Files" → „`scraper.html` Single-File mit 6 Tabs" |
| `ARK_DATABASE_SCHEMA_v1_3.md` | ✅ konsistent | Keine Änderung (kein Schema-Drift) |
| `ARK_BACKEND_ARCHITECTURE_v2_5.md` | ✅ konsistent | Keine Änderung (kein Event/Worker/Endpoint-Drift) |
| `ARK_STAMMDATEN_EXPORT_v1_3.md` | ✅ konsistent | Keine Änderung (kein Enum/dim-Drift) |
| `ARK_GESAMTSYSTEM_UEBERSICHT_v1_3.md` | ✅ konsistent | Keine Änderung (Scraper-Status bleibt v0.2 ✅) |

**Wiki-Sync:**
- `wiki/sources/scraper-schema.md` → Patch-Link hinzufügen
- `wiki/sources/scraper-interactions.md` → Patch-Link hinzufügen
- `wiki/concepts/scraper.md` → Mockup-Reference updaten

---

## NÄCHSTE SCHRITTE (nach v0.2)

| # | Item | Phase |
|---|------|-------|
| 1 | admin.html Tab 6 Sub-6-1/6-2/6-3 entfernen (Duplikate zu scraper.html Tab 3/4/5) | P1.5 / separate PR |
| 2 | Vollansicht `/scraper/runs/[id]` als separater Subpage (Diff-View) | P1.5 |
| 3 | Bulk-Run-Drawer (Scope-Auswahl, Parallelisierung, Rate-Limit-Warn) | P1.5 |
| 4 | Anomalie-Radar mit echter AI-Anbindung (statt Mock-Anomalien) | P2 |
| 5 | LinkedIn-Scraper-Aktivierung | P2 |
| 6 | Cost-Tracking (AI-Tokens, API-Kosten) | P2 |
| 7 | Multi-Tenant-Rate-Limit-Strategie | P2 |

---

## RELATED

- `ARK_SCRAPER_MODUL_SCHEMA_v0_1.md` (Basis)
- `ARK_SCRAPER_MODUL_INTERACTIONS_v0_1.md` (Basis)
- `mockups/scraper.html` (v0.2-Umsetzung, 17.04.2026)
- `wiki/concepts/scraper.md`
- `wiki/meta/mockup-baseline.md`
