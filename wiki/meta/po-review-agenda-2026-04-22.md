---
title: "PO-Review Agenda 2026-04-22"
type: meta
created: 2026-04-22
tags: [po-review, agenda, automated]
---

# PO-Review Agenda 2026-04-22

_Automatisch generiert · Mittwoch 09:00 CEST · Routine `ark-weekly-po-agenda`_

---

## 1. Seit letztem Review (ab 2026-04-15)

### Fertig geworden

| Modul | Was | Commits |
|-------|-----|---------|
| **ERP · Zeit-Modul** | Phase 3 komplett: Research-Ingest (4 Quellen), 15 Q&A mit Peter, 2 Specs (`ARK_ZEIT_SCHEMA_v0_1.md` · `ARK_ZEIT_INTERACTIONS_v0_1.md`), 7 Mockups (`zeit-meine-zeit` · `zeit-monat` · `zeit-abwesenheiten` · `zeit-team` · `zeit-saldi` · `zeit-export` · `zeit-admin`). Grundlagen-Sync auf alle 5 Grundlagen-Dateien abgeschlossen. | `d0828ba` |
| **ERP · HR / Commission** | Shell-Mockups erstellt (13 Files in `mockups/ERP Tools/`). HR-Strategie-Spec-Triade (`ARK_HR_RESEARCH_SYNTHESE_v0_1.md` · `ARK_HR_STRATEGY_DECISION_v0_1.md` · `ARK_COMMISSION_ENGINE_SPEC_v0_1.md`). HR-Spec v0.2 + Commission-Abgleich-Handoff. | `89b367b` |
| **Harness v2** | Karpathy-Skill, Claude Design Workflow, 3 Cloud-Routines (Drift/PO-Agenda/Staleness), Autorefine-Skill, Bypass-Permissions, MCP-Setup-Guide. | `3c311d2` |
| **Drift-Scan** | Weekly-Scan 2026-04-20 ausgeführt, `drift-log.md` aktualisiert, ERP-Tools-Findings korrigiert. | `197a2ca` `eaf3ef4` |

### Neue Specs diese Woche

- `specs/ARK_ZEIT_SCHEMA_v0_1.md` — 32 KB · 15 Tabellen · 9 Enums · 4 Views
- `specs/ARK_ZEIT_INTERACTIONS_v0_1.md` — 43 KB · 7 Screens · 5 Drawer · 2 Modals

---

## 2. Offene Entscheidungen (brauchen Peter-Input)

### A · Schutzfrist Gruppen-Scope (P0 — KRITISCH)

**Quelle:** [[detailseiten-nachbearbeitung]] · Erfasst 2026-04-13

**Problem:** Entscheidung FG-10 (Firmengruppen-Schema) legt fest: Schutzfrist gilt gruppenweit. Account-Interactions `v0.2` zeigt das noch nicht — Tab 9 fehlen `scope='group'`-Einträge, der Claim-Workflow prüft nur Account-Level.

**Konkrete Lücke:** Bei Vorstellung eines Kandidaten müssen 2 `fact_protection_window`-Einträge erstellt werden (`scope=account` + `scope=group`) wenn `account.group_id IS NOT NULL`. Scraper-Match-Logik und UI müssen beide Scopes prüfen.

**Empfehlung:** `ARK_ACCOUNT_DETAILMASKE_INTERACTIONS_v0_2.md` → v0.3 + Mandat-Interactions `TEIL 10` updaten. 1 Session, ~2–3 Stunden.

**Frage:** Soll der Gruppen-Scope auch im Kandidaten-Tab "Offene Schutzfristen" sichtbar sein, oder nur im Account-Tab?

---

### B · Vorstellungs-Markierung UX (Mandat Longlist)

**Quelle:** [[detailseiten-nachbearbeitung]] · Erfasst 2026-04-13

**Problem:** Der Button „📋 Als vorgestellt markieren" auf Kandidat-Cards ab Stage 5+ ist nur textlich beschrieben, kein konkretes UX-Pattern festgelegt.

**Optionen:**
1. **Drawer (540px)** — konsistent mit Drawer-Default-Regel, aber schwer für schnelle Batch-Markierungen
2. **Inline-Dropdown** — schnell, aber keine Bestätigung / kein Kommentarfeld
3. **Card-Rückseite (Flip)** — elegant, aber pattern-fremd im aktuellen Design-System

**Empfehlung:** Option 2 (Inline-Dropdown) mit kurzem Bestätigungs-Toast. Bei komplexen Fällen (mehrere Accounts, Gruppen-Scope) → Drawer als Fallback. Kein neues Pattern nötig.

**Frage:** OK so, oder willst du ein Drawer-First-Flow?

---

### C · Grundlagen-Changelog: 18 unresolved Einträge bereinigen

**Quelle:** [[grundlagen-changelog]] · session-13946034 · 2026-04-19

**Problem:** Der Auto-Lint-Hook hat beim Zeit-Modul-Grundlagen-Sync 18 individuelle Einträge generiert (alle `Status: unresolved`). Die Resolution ist inhaltlich dokumentiert im manuellen Header-Block „2026-04-19 · Zeit-Modul v0.1 Grundlagen-Sync" (`Status: resolved`). Die 18 Hook-Einträge wurden aber nie mit einem `RESOLUTION ✓`-Block geschlossen — sieht schlimmer aus als es ist.

**Empfehlung:** Einen RESOLUTION-Block für session-13946034 einfügen. ~15 Minuten. Kein inhaltlicher Handlungsbedarf — die Sync-Arbeit ist erledigt.

**Frage:** Soll ich das direkt bereinigen (autorisiert du den Edit)?

---

### D · Header-Snapshot-Bar — einheitliche Slot-Anzahl?

**Quelle:** [[detailseiten-nachbearbeitung]] · Erfasst 2026-04-13

**Problem:** Kandidat hat variable Slots, Mandat hat 6–7, Account hat 6, Assessment hat 5. Kein einheitliches Maximum definiert.

**Optionen:**
1. **Einheitlich max. 6 Slots** — konsistenter Look, erzwingt Priorisierung
2. **Variabel akzeptieren** — mehr Flexibilität pro Entity-Typ, weniger Zwang

**Empfehlung:** Option 1 (max. 6). Jede Entity wählt ihre 6 wichtigsten KPIs. Die Heterogenität der aktuellen Mockups ist gering, das lässt sich ohne grossen Aufwand angleichen.

**Frage:** Entscheidest du das hier, oder ist das PO-nebensächlich?

---

### E · Admin-Vollansicht — FRONTEND_FREEZE §4g Aufnahme ausstehend

**Quelle:** [[grundlagen-changelog]] · 2026-04-17 18:37 · session-cea13e34

**Problem:** `specs/ARK_ADMIN_VOLLANSICHT_SCHEMA_v0_1.md` und `INTERACTIONS_v0_1.md` sind erstellt, `mockups/admin.html` + `admin-dashboard-templates.html` existieren — aber die Admin-Vollansicht fehlt noch in `ARK_FRONTEND_FREEZE_v1_10.md §4g`. Zudem zeigt `admin-dashboard-templates.html` 3 Drawer-Default-Violations (Modals für CRUD statt Drawer 540px).

**Empfehlung:**
1. §4g in FRONTEND_FREEZE ergänzen (Admin-Vollansicht dokumentieren)
2. 3 Modal→Drawer-Fixes in `admin-dashboard-templates.html`

**Frage:** Ist Admin-Vollansicht „Erstentwurf — Review ausstehend" — soll ich jetzt den Review-Pass machen und dann §4g eintragen?

---

## 3. Spec-Drift & Lint-Findings

### Grundlagen-Changelog Status

| Status | Anzahl Einträge | Details |
|--------|----------------|---------|
| `resolved` | ~45 | Alle Sessions bis 2026-04-18 vollständig |
| `unresolved` | **18** | Session-13946034 (2026-04-19) — Zeit-Modul-Sync, inhaltlich erledigt, formal offen (siehe §2C) |

### Lint-Violations Übersicht

**Resolviert diese Woche (Phase-1-Cleanup):**
| File | Violations | Status |
|------|-----------|--------|
| `candidates.html` | 14 DB-TECH | ✓ resolved |
| `accounts.html` | 22 (DB-TECH + SNAKE-CASE + ROUTE-TMPL) | ✓ resolved |
| `processes.html` | 26 DB-TECH | ✓ resolved (Admin-Saga-Sektion bewusst beibehalten) |
| `projects.html` | 21 DB-TECH | ✓ resolved |
| `jobs.html` | 18 DB-TECH | ✓ resolved |
| `mandates.html` | 4 DB-TECH | ✓ resolved |
| `groups.html` | 5 DB-TECH | ✓ resolved |
| `email-kalender.html` | 5 UMLAUT + 3 SNAKE-CASE | ✓ resolved |

**Noch offen (aktiv):**

| File | Violations | Typ | Priorität |
|------|-----------|-----|-----------|
| `admin-dashboard-templates.html` | 3 Modals für CRUD | DRAWER-DEFAULT | Mittel (Admin-Tool, kein Kunde) |
| `log.md` | 4–5 UMLAUT | Strukturell (Hook-Pfade) | Niedrig (systemisch, kein User-sichtbar) |
| `anti-patterns.md` | 4 UMLAUT | Meta-Datei erklärt falsche Umlaute | Niedrig (Doku-Kontext) |
| `feedback_audit_logging.md` | 1 UMLAUT | `pruefen` → `prüfen` | Niedrig |

**Fazit:** Alle produktiven Mockups (7 Entity-Masken + 3 Tool-Masken) sind jetzt Lint-konform. Offene Violations betreffen nur Admin/Meta-Dateien.

---

## 4. Empfehlung nächste 2 Wochen

**Priorität 1 — Phase-1-Cleanup abschliessen**
Nachbearbeitungs-Punkte A + B (Gruppen-Schutzfrist + Vorstellungs-Markierung UX) umsetzen. Spec-Bumps: Account-Interactions v0.2 → v0.3, Mandat-Interactions TEIL 10. Danach ist Phase-1 (alle 9 Entity-Masken vollständig spezifiziert) formal abgeschlossen. Geschätzt 1–2 Sessions.

**Priorität 2 — ERP Phase 3 · Zeit-Modul Mockup-Feinschliff**
Die 7 Zeit-Modul-Mockups sind Shells (HTML-Struktur vorhanden). Interaktions-Spec v0.1 ist fertig — jetzt braucht es den Mockup-Feinschliff nach dem gleichen Muster wie die Phase-1-Masken (Drawer-Inhalte, History-Events, Lint-Pass). 1 Session pro 2–3 Screens.

---

## 5. Fragen an dich

1. **Gruppen-Schutzfrist** (§2A): Soll die Gruppen-Schutzfrist auch im Kandidaten-Tab sichtbar sein, oder nur im Account-Tab 9?

2. **Changelog-Bereinigung** (§2C): Darf ich die 18 formell-offenen Changelog-Einträge von session-13946034 mit einem RESOLUTION-Block schliessen? Es handelt sich um die Zeit-Modul-Sync die inhaltlich abgeschlossen ist.

3. **Admin-Review** (§2E): Soll ich die Admin-Vollansicht jetzt reviewen und FRONTEND_FREEZE §4g nachtragen? Oder ist Admin erst Phase-4-Scope?

4. **Snapshot-Bar-Slots** (§2D): Maximal 6 Slots pro Entity-Typ — OK so?

5. **Nächstes ERP-Modul**: Nachdem Zeit-Modul Mockups fertig sind — welches ERP-Modul als nächstes? HR-Tool, Commission-Engine, oder Messaging?

---

_Quellen: [[detailseiten-nachbearbeitung]] · [[decisions]] · [[grundlagen-changelog]] · [[lint-violations]] · `git log --since=2026-04-15`_
