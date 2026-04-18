# ARK CRM — PO-Review-Session v1.4

**Stand:** 17.04.2026
**Session-Zweck:** Review aller Artefakte aus 2 Feature-Zyklen v1.4 mit PO + Backend-Lead + mind. 2 Rollen-Vertretern (Candidate Manager + Account Manager)
**Empfohlene Dauer:** 90 Min
**Materialien bereit:** 12 Spec-Docs · 2 SQL-Migrations · 11 Mockups

---

## 1. WAS WURDE GEBAUT (Übersicht)

### Feature-Zyklus A — System-Activity-Types

**Problem gelöst:** Activity-Type-Katalog (69 Typen) nur für User-Aktionen. System-Events (Saga-Steps · AI-Auto-Fills · Scraper-Findings · Auto-Stage-Transitions) nicht einheitlich geloggt.

**Lösung:**
- Katalog-Expansion 69 → **117 Typen** in 18 Kategorien
- `dim_activity_types` +3 Spalten: `actor_type` · `source_system` · `is_notifiable`
- `dim_event_types` +5 Spalten: `create_history` · `default_activity_type_id` · etc.
- Event-Processor-Hook: automatisches `fact_history`-Schreiben bei `create_history=true`
- UNIQUE-Constraint auf `fact_history.event_id` (Idempotenz)
- Notification-Dedup via Redis-Lock (60s TTL)

### Feature-Zyklus B — Dashboard-Customization

**Problem gelöst:** Dashboard war statisch für alle gleich. 14 User · 7 Rollen mit unterschiedlichen Bedürfnissen.

**Lösung:**
- 3-Ebenen-Model: Rolle-Defaults → User-Override → Viewport-Adaptation
- 27 Widgets in 6 Kategorien
- 6 Rollen-Default-Layouts (Role-Default-Rows total)
- Edit-Modus mit Drag-Reorder · Resize · ✕-Entfernen · ⚙-Config
- Widget-Katalog-Drawer (540px, Rollen-gefiltert)
- Admin-Template-Editor (nur Admin)
- Mobile-Responsive (3 Breakpoints · `mobile_mode` pro Widget)
- Doppelrollen-Toggle (Admin + Account Manager → Combined-View)

### Feature-Zyklus C — Option-B History-Drawer-Erweiterung

**Problem gelöst:** Dashboard-Triage-Widgets hatten eigene Drawer (Duplikat zu History-Drawer in Detailmasken).

**Lösung:**
- History-Drawer in 7 Detailmasken erweitert um 3 bedingte Tabs: **Klassifizierung** (bei pending) · **Verlauf** · **AI-Summary enhanced**
- Dashboard-eigene Call-/Email-Drawer entfernt (525 Zeilen bereinigt)
- Triage-Flow jetzt aus jeder Maske verfügbar

---

## 2. ARTEFAKT-CHECKLIST (für Review)

### Spec-Dokumente (12)

| # | Datei | Zweck | Zeilen |
|---|-------|-------|-------:|
| 1 | [ARK_SYSTEM_ACTIVITY_TYPES_SCHEMA_v1.md](ARK_SYSTEM_ACTIVITY_TYPES_SCHEMA_v1.md) | Haupt-Spec System-Events (v1.3) | 500 |
| 2 | [ARK_STAMMDATEN_PATCH_v1_3_to_v1_4_ACTIVITY_TYPES.md](ARK_STAMMDATEN_PATCH_v1_3_to_v1_4_ACTIVITY_TYPES.md) | §14-Katalog-Erweiterung | 250 |
| 3 | [ARK_DATABASE_SCHEMA_PATCH_v1_3_to_v1_4.md](ARK_DATABASE_SCHEMA_PATCH_v1_3_to_v1_4.md) | DB-Änderungen | 280 |
| 4 | [ARK_BACKEND_ARCHITECTURE_PATCH_v2_5_to_v2_6.md](ARK_BACKEND_ARCHITECTURE_PATCH_v2_5_to_v2_6.md) | Event-Processor-Erweiterung | 380 |
| 5 | [ARK_EVENT_TYPES_MAPPING_v1_4.md](ARK_EVENT_TYPES_MAPPING_v1_4.md) | 55 Events · create_history-Mapping | 300 |
| 6 | [ARK_SYSTEM_ACTIVITY_TYPES_DECISIONS_v1_3.md](ARK_SYSTEM_ACTIVITY_TYPES_DECISIONS_v1_3.md) | 28 Q&A konsolidiert | 320 |
| 7 | [ARK_ADMIN_DEBUG_SCHEMA_v1_0.md](ARK_ADMIN_DEBUG_SCHEMA_v1_0.md) | `/admin/event-log`-Tab | 340 |
| 8 | [ARK_DASHBOARD_CUSTOMIZATION_SCHEMA_v1.md](ARK_DASHBOARD_CUSTOMIZATION_SCHEMA_v1.md) | Haupt-Spec Customization | 540 |
| 9 | [ARK_GRUNDLAGEN_SYNC_v1_4.md](ARK_GRUNDLAGEN_SYNC_v1_4.md) | Deploy-Roadmap 5 Grundlagen | 400 |
| 10 | PO_REVIEW_SESSION_v1_4.md | **dieses Doc** | 300 |

### SQL-Migrations (2)

| # | Datei | Scope | Zeilen |
|---|-------|-------|-------:|
| 1 | [001_system_activity_types.sql](../migrations/001_system_activity_types.sql) | 48 Activity-Types + Event-Type-Mappings + UNIQUE-Constraint | 824 |
| 2 | [002_dashboard_customization.sql](../migrations/002_dashboard_customization.sql) | 27 Widgets + 87 Role-Defaults + Settings | 470 |

### Mockups (11)

| # | Datei | Demo-Fokus |
|---|-------|-----------|
| 1 | [dashboard.html](../mockups/dashboard.html) | **Haupt-Demo** · 27 Widgets · Role-Toggle · Edit-Modus · Katalog-Drawer |
| 2 | [admin-dashboard-templates.html](../mockups/admin-dashboard-templates.html) | Admin-Template-Editor (7 Rollen) |
| 3 | [dashboard-mobile.html](../mockups/dashboard-mobile.html) | 3-Breakpoint-Device-Showcase |
| 4 | [candidates.html](../mockups/candidates.html) Tab 7 | Option-B History-Drawer mit pending-Row |
| 5–11 | 6 weitere Detailmasken | Option-B-Pattern portiert |

---

## 3. DEMO-WALKTHROUGH (empfohlene Reihenfolge für Session)

**Phase 1 — Dashboard-Customization (30 Min)**

1. `dashboard.html` öffnen — PO sieht Admin-View (Default)
2. **Rolle-Toggle** oben rechts → wechsel auf Account-Manager-View → Layout ändert sich
3. **„✎ anpassen"-Button** → Edit-Modus-Banner + Drag-Handles auf Widgets
4. **✕ Close** auf einem Widget → Widget verschwindet
5. **↔ Resize** zyklt Grössen (quarter → third → half → full)
6. **„+ Widget hinzufügen"** → Katalog-Drawer öffnet (27 Widgets kategorisiert)
7. Klick „+ Hinzufügen" auf z.B. „Time-to-Fill-Trend" → Widget wird sichtbar mit Scroll + Flash
8. **„💾 Speichern"** → Banner „Layout gespeichert · Multi-Device-Sync aktiv"
9. **„↺ Auf Default zurücksetzen"** → Confirm → alles wieder default

**Phase 2 — Admin-Template-Editor (15 Min)**

1. `admin-dashboard-templates.html` öffnen
2. Sidebar-Rollen-Wechsel (Candidate Manager / Account Manager / Admin / Research Analyst / Backoffice / Head of)
3. Widget-Row-Controls: Drag · Size-Select · Pin-Toggle · Remove
4. „+ Widget zum Account-Manager-Template hinzufügen" → Katalog-Drawer
5. **„💾 Als neue Version speichern"** → Confirm-Modal mit Diff-Preview
6. Affected-Users-Block: zeigt 3 betroffene Account-Manager-User + Benachrichtigungs-Info

**Phase 3 — Mobile-Responsive (10 Min)**

1. `dashboard-mobile.html` öffnen
2. Tab „📱 Mobile" → iPhone-14-Frame zeigt Mobile-Layout (2-Spalten-KPI · stacked Cards · Hamburger)
3. Annotations-Panel erklärt: Role-Toggle versteckt · mode-Varianten · Performance-Ersparnis
4. Tab „📱 Tablet" · „💻 Desktop" · „🔀 Vergleich"

**Phase 4 — History-Drawer Option B (15 Min)**

1. `candidates.html` öffnen · Tab 7 „History"
2. Goldgelb umrandete Zeile „Anruf von Hans Müller · 07:58" klicken
3. Drawer hat **6 Tabs**: Übersicht · Transkript · AI-Summary · **🏷 Klassifizierung** · 📜 Verlauf · Reminders
4. Klassifizierungs-Tab: AI-Vorschlag-Radio + Manual-Picker + Verknüpfungen-Bestätigen
5. AI-Summary: Action-Items als list-item · Signale als field-grid · Schlagwörter-Chips
6. Verlauf-Tab: Timeline vorheriger Interaktionen + Rhythmus-Stats

**Phase 5 — Spec-Walkthrough (20 Min)**

- Spec v1.3 kurz skimmen (Haupt-Design-Decisions)
- Decisions-Doc 28 Q&A durchgehen
- Grundlagen-Sync-Roadmap §8 Deploy-Reihenfolge

---

## 4. ENTSCHEIDUNGEN — vom PO gebraucht

### Kritisch (blockt Deploy)

| # | Frage | Kontext | Empfehlung |
|---|-------|---------|------------|
| D1 | Feature-Flag-Strategie: beide Features gleichzeitig ausrollen oder sequenziell? | System-Activity-Types zuerst sicherer (mehr Validierung), Dashboard danach | **Sequenziell** · Phase 1 → 2 Wochen Grünphase → Phase 2 |
| D2 | Redis-Infrastruktur beim Kunden vorhanden? Sonst `pg_advisory_lock` als Fallback | Notification-Dedup benötigt Lock-Mechanismus | **pg_advisory_lock als Default** (lower operational cost) |
| D3 | Doppelrollen-Zuordnung finalisiert? | PW = Admin + Account Manager, andere? | Liste von HR bekommen vor Migration |
| D4 | Rolle-Default-Templates abnahmefähig? | 6 Rollen × ~10 Widgets | Reviewer: mind. 1 Candidate Manager + 1 Account Manager + 1 Admin |

### Empfohlen (verbessert Qualität)

| # | Frage | Kontext | Empfehlung |
|---|-------|---------|------------|
| D5 | Mobile-Rollout in Phase 1 oder nachträglich? | `mobile_mode=full/compact/hidden/link-only` getestet | **Phase 1 inkl. Mobile** · Consultants nutzen iPad unterwegs |
| D6 | Admin-Template-Editor wer darf? | Aktuell nur Admin · soll Head of auch? | **v1.0 nein** · Head of soll User-Layouts nicht für andere ändern können |
| D7 | Widget-Sharing zwischen Usern? („Copy from Colleague") | v1.0 out-of-scope | **v1.2 evaluieren** basierend auf Nutzer-Feedback |
| D8 | Migration-Reihenfolge vs Code-Release | Additiv · Code-Deploy vor DB oder umgekehrt? | **DB zuerst** (Schema additive, alte App weiterlauffähig) |

### Nice-to-have (v1.5-Backlog)

- Email-Digest-Notifications (statt nur In-App)
- AI-Auto-Accept-Threshold-Config (aktuell hart 90 %)
- Dashboard-Drag-Reorder auf Tablet (Touch-optimiert)
- Research-Analyst-spezifische Widgets (Longlist-Research-Backlog v1 gebaut, evtl. mehr)

---

## 5. DEPLOY-PLAN (Empfehlung)

```
Woche 1-2: Staging · Migration 001 (System-Activity-Types)
  ├── SQL in Staging-DB
  ├── event-processor.worker.ts v2.6 Deploy (Flag off)
  ├── Smoke-Test: 1 Event pro Domain
  └── Flag on · 48h Monitoring Dead-Letter

Woche 3: Prod · Migration 001 Rollout
  ├── 50 % Traffic
  ├── 48h Grünphase
  └── 100 %

Woche 4: Team-Audit-Tasks
  ├── Saga-Emission-Check (alle 8 Sagas)
  ├── Event-Scope-Registry (35 neue Resolver)
  └── Legacy-Event-Mapping (24 bestehende Events)

Woche 5-6: Staging · Migration 002 (Dashboard-Customization)
  ├── SQL in Staging-DB
  ├── Frontend-Deploy Customization (Flag off)
  ├── UAT mit 1 Vertreter pro Rolle (Admin · Candidate Manager · Account Manager)
  ├── Admin-Template-Editor-Test
  └── Mobile-Test auf iPhone + iPad

Woche 7: Prod · Migration 002 Rollout
  ├── Admin zuerst (2 User)
  ├── 2 Tage Feedback
  ├── Candidate Manager + Account Manager Rollout
  └── Research Analyst + Backoffice Rollout

Woche 8: Grundlagen-Updates
  ├── STAMMDATEN v1.3 → v1.5
  ├── DATABASE_SCHEMA v1.3 → v1.5
  ├── BACKEND_ARCH v2.5 → v2.7
  ├── FRONTEND_FREEZE neue Version
  └── GESAMTSYSTEM v1.4 Changelog

Woche 9+: v1.5-Backlog starten
  ├── Admin-Debug-Tab bauen (Spec bereits fertig)
  ├── Email-Digest-Notifications
  ├── Weitere Research-Analyst-Spezial-Widgets
  └── Mobile-Touch-optimierungen
```

---

## 6. RISIKEN & MITIGATIONEN

| Risiko | Wahrscheinlichkeit | Impact | Mitigation |
|--------|:---:|:---:|------------|
| Redis-Unavailable → doppelte Notifications | mittel | niedrig | `pg_advisory_lock`-Fallback dokumentiert |
| Consultant überwältigt von 27 Widgets | mittel | mittel | Rolle-Defaults zeigen nur relevante Subset (8–16 Widgets) |
| Doppelrollen-Toggle verwirrt User | niedrig | niedrig | Nur wenige User haben mehrere Rollen (primär PW · andere einstellig) |
| Mobile-Layout-Bugs auf älteren iOS | niedrig | niedrig | Breakpoints-CSS getestet · Fallback auf compact |
| Migration lange (Seeds + Validation) | niedrig | niedrig | Migrations laufen < 30s in Staging-Tests |
| Event-Processor-Performance (Pre-Rule-Hook) | mittel | mittel | Redis-Cache + Lazy-Load · Monitoring via Grafana |
| UNIQUE-Constraint bricht Legacy-Retry-Flow | niedrig | hoch | Rollback-Plan · idempotent-by-construction Code |

---

## 7. FEEDBACK-FRAGEN FÜR PO

1. **Passt die Priorisierung der Widget-Defaults pro Rolle?** Was fehlt in Candidate-Manager-Default, was ist zu viel in Account-Manager-Default?
2. **Akzeptabler Deploy-Zeitrahmen (9 Wochen)?** Falls nicht: welche Phasen können komprimiert werden?
3. **Mobile-Priorität?** Reicht Read-Only-Mobile oder Customization auch auf Tablet nötig?
4. **Namensgebung Widgets?** „Meine überfälligen Reminders" zu lang? „Pipeline-Snapshot" klar genug?
5. **Admin-Template-Editor UX?** Clear enough? Oder eher separate Admin-Maske mit Tabs?
6. **Saga-Drawer V7 nur für Candidate Manager relevant oder auch Account Manager?** Aktuell in candidates.html + processes.html + mandates.html (TX3 cancellation)
7. **Activity-Type-Katalog erweiterung:** Sollen Research-Analyst-spezifische Types (z.B. Longlist-Sourcing-Action) auch rein?
8. **Feature-Flag-Defaults in Prod:** sofort `dashboard_customization_enabled=true` oder stufenweise pro User einschalten?

---

## 8. POST-REVIEW TO-DOs

Falls PO alles approved:

- [ ] `wiki/meta/grundlagen-changelog.md` Eintrag v1.4 erstellen
- [ ] `log.md` Projekt-Eintrag „PO-Approval v1.4 · Deploy-Start"
- [ ] Backend-Team briefing scheduled (Saga-Audit-Task + Event-Registry-Pflege)
- [ ] HR-Liste für Doppelrollen anfragen
- [ ] Staging-Test-Tenant mit Dummy-Usern aufsetzen
- [ ] Grafana-Dashboards für Monitoring vorbereiten
- [ ] Rollback-Playbooks in Ops-Wiki

---

## 9. ANHANG — Zahlen-Zusammenfassung

**Umfang gesamt:**
- 12 Spec-Dokumente · ~4.500 Zeilen
- 2 SQL-Migrationen · ~1.300 Zeilen
- 11 Mockup-Dateien · ~12.000 Zeilen neu/aktualisiert
- 35+ Backups

**Infrastruktur-Änderungen:**
- +2 neue Tabellen (dim_dashboard_widgets · dim_dashboard_role_defaults)
- +3 dim_crm_users-Spalten (additional_roles · dashboard_layout_json · active_dashboard_view)
- +3 dim_activity_types-Spalten (actor_type · source_system · is_notifiable)
- +5 dim_event_types-Spalten (default_*/create_history)
- +1 UNIQUE-Index (fact_history.event_id)
- +9 Automation-Settings-Keys

**Katalog-Erweiterungen:**
- Activity-Types: 69 → 117 Rows
- Event-Types: ~30 bestehend + ~45 neue → ~75 gesamt
- Dashboard-Widgets: 0 → 27
- Role-Default-Rows: 0 → 87

**Neue API-Endpoints:** 13 (8 Dashboard + 5 Admin-Debug)

**Neue WebSocket-Topics:** ~5 (dashboard.widget.* + admin.event_queue)

---

**Ende PO-Review-Session v1.4.** Session-Empfehlung: nach Review direkt Phase 1 Deploy-Go/No-Go entscheiden.
