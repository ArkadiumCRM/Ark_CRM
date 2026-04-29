---
title: "PO-Review Agenda 2026-04-29"
type: meta
created: 2026-04-29
tags: [po-review, agenda, automated]
---

# PO-Review Agenda 2026-04-29

_Automatisch generiert · Mittwoch 09:00 CEST · Routine `ark-weekly-po-agenda`_

---

## 1. Seit letztem Review (ab 2026-04-22)

### Fertig geworden

| Modul | Was | Commits |
|-------|-----|---------|
| **Admin-Debug** | Schema v1.0 → v1.1 — Tab-Integration statt separater Single-Page-Route. Admin-Debug-Ansicht wird neu als Tab in bestehende Masken eingebettet, kein eigenständiger Route-Wechsel. | `e0a15a1` |
| **Specs-Konsolidierung** | 20 ERP-Specs aus `ERP Tools/specs/` → `specs/` verschoben (Billing, HR, Zeit, SWISS-DECTX). Pfad-Referenzen in 6 Specs aktualisiert. Kein inhaltlicher Drift. | `92acd16` `c12b983` |
| **Pfad-Konsolidierung** | Repo-Pfad `C:\ARK CRM` → `C:\Projects\Ark_CRM` — alle Tooling-Konfigurationen angepasst. Assessment-Detailmaske-Mockup-Impl-Spec mitgezogen. | `2e1e818` |
| **UMLAUT-Fixes Performance** | 9 Performance-Mockups bereinigt (`fuer` → `für` in CSS-Comments, durch Sub-Agent verursacht). Alle Performance-Mockups jetzt Umlaut-konform. | `eb8801f` |
| **Weekly Routinen** | Drift-Scan 2026-04-27: **PASS**. Visual-Regression 2026-04-27: **PASS** (89 Mockups). Model-Watch 2026-04-27: ausgeführt. | `8b7409c` `df00a05` `7c4c86e` |

### Neue Specs diese Woche

Keine genuinen Neu-Specs — die in `specs/` erscheinenden Billing/HR/Zeit-Dateien wurden aus `ERP Tools/specs/` verschoben, nicht neu erstellt. Letzte inhaltlich neue Specs (2026-04-25) waren die 5 Grundlagen-Patches für das Performance-Modul.

---

## 2. Offene Entscheidungen (brauchen Peter-Input)

### A · Publishing-Modul starten — wann? (P0)

**Quelle:** [[decisions]] · 2026-04-26 · Decision 2 (Performance-Backend aufgeschoben bis Mockup-Vollständigkeit)

**Kontext:** Decision 2026-04-26 besagt: Backend-Implementation startet erst nach Mockup-Vollständigkeit aller Phase-3-ERP-Module (Publishing, Messaging, ggf. E-Learning-Tiefe). Performance-Modul ist fertig (11/11 Mockups). Publishing + Messaging fehlen noch vollständig.

**Empfehlung:** Publishing-Modul als nächste Session starten (Research → Q&A → Spec v0.1 → Mockups). Geschätzt 2–3 Sessions bis zum Mockup-Skelett. Danach Messaging-Modul.

**Frage:** Gibst du grünes Licht für Publishing-Modul-Start nächste Session? Oder gibt es andere Prioritäten?

---

### B · Team-Wechsel-Commission-Regel Q11 — Vertrag ausstehend (P1)

**Quelle:** [[decisions]] · 2026-04-20 · Billing Batch 3 Q11

**Problem:** Die Commission-Regel bei AM-Wechsel mid-Mandat ist im Arbeits-/Provisionsvertrag (`Praemium Victoria` / `Generalis Provisio`) geregelt — aber dieser Vertrag ist **nicht im System** (kein PDF, kein MD im Worktree). Spec-Platzhalter `dim_commission_year.team_transition_rule` (Enum TBC) blockiert die Commission-Engine v0.1-Finalisierung.

**Empfehlung:** Peter lädt Vertrag als PDF in `raw/General/` oder gibt die Regel mündlich durch. Dann kann `team_transition_rule` mit echten Enum-Werten befüllt werden.

**Frage:** Kannst du die Commission-Regel für AM-Wechsel mid-Mandat kurz nennen (z.B. anteilig nach Wochen / letzter AM kriegt alles / Split 50/50)?

---

### C · 5 Grundlagen-Digests STALE — Regeneration beauftragen? (P1)

**Quelle:** [[grundlagen-changelog]] · 2026-04-25 Performance-Modul-Sync · Pending-Flag

**Problem:** Nach dem Performance-Modul-Grundlagen-Sync (2026-04-25) sind alle 5 Digests als STALE markiert:
- `stammdaten-digest.md`
- `database-schema-digest.md`
- `backend-architecture-digest.md`
- `frontend-freeze-digest.md`
- `gesamtsystem-digest.md`

Ohne aktuelle Digests lädt `/prime-ark` veraltete Daten (Performance-Enums/Endpoints fehlen im Context).

**Empfehlung:** Regeneration via 5 parallele Sub-Agents in einer Session. ~30 Minuten, reiner Housekeeping-Task.

**Frage:** Soll ich das in der nächsten Session als erstes erledigen, bevor wir mit Publishing starten?

---

### D · Sample-Data-Rollout — Session einplanen (P2)

**Quelle:** [[decisions]] · 2026-04-26 · Decision 3

**Kontext:** Decision 2026-04-26 besagt: `perf-sample-data.js`-Pattern (zentrale Demo-Daten in `window.ARK_PERF.*`) auf alle ERP-Module rückportieren (HR, Commission, Zeit, Billing). Dauer ~2–3h. Memory `project_sample_data_rollout_pending.md` angelegt.

**Empfehlung:** Nach Mockup-Vollständigkeit (Publishing + Messaging fertig) als dedizierte Housekeeping-Session einplanen — dann alle Module auf einmal migrieren.

**Frage:** Ist diese Reihenfolge (Mockups zuerst → dann Sample-Data-Rollout) für dich OK?

---

### E · Snapshot-Bar-Slots — Einheitliche Anzahl? (P2)

**Quelle:** [[detailseiten-nachbearbeitung]] · Erfasst 2026-04-13 · Review-Thema

**Problem:** Verschiedene Entity-Masken haben unterschiedlich viele Snapshot-Bar-Slots: Kandidat variabel, Mandat 6–7, Account 6, Assessment 5. Keine einheitliche Maximalzahl definiert.

**Optionen:**
1. **Einheitlich max. 6 Slots** — konsistenter Look, erzwingt Priorisierung pro Entity
2. **Variabel akzeptieren** — Flexibilität pro Entity-Typ

**Empfehlung:** Max. 6 Slots (Option 1). Heterogenität ist aktuell gering, Angleichung ohne grossen Aufwand möglich.

**Frage:** Entscheide hier — dann trage ich es als Grundlagen-Regel ein und passe die 2–3 abweichenden Mockups an.

---

## 3. Spec-Drift & Lint-Findings

### Grundlagen-Changelog Status

| Status | Details |
|--------|---------|
| **Alles resolved** | Alle Changelog-Einträge bis 2026-04-25 geschlossen. Session-Sammel-Resolutions vorhanden. |
| **Offen (tech debt)** | 5 Digests STALE (siehe §2C). Keine inhaltlichen Unresolved-Einträge. |

### Lint-Violations Übersicht (Stand 2026-04-29)

**Produktive Mockups:** Vollständig Lint-konform (7 Entity-Masken + 3 Tool-Masken). Keine offenen DB-TECH/SNAKE-CASE-Violations in User-facing Positionen.

**Offen (nieder-prioritär):**

| File | Violations | Typ | Priorität |
|------|-----------|-----|-----------|
| `admin-dashboard-templates.html` | 3 Modals für CRUD | DRAWER-DEFAULT | Mittel (Admin-Tool, kein Kunden-UI) |
| `log.md` | 4 UMLAUT | Hook-Pfad-Strings | Niedrig (nicht User-sichtbar) |
| `anti-patterns.md` | 4 UMLAUT | Meta-Doku | Niedrig (Erklär-Kontext) |

**Performance-Mockups** (9 Files): UMLAUT-Fixes 2026-04-26 abgeschlossen, clean.

**Top-3 Files nach historischer Violation-Dichte** (alle resolved):
1. `accounts.html` — 22 Violations (resolved 2026-04-17)
2. `processes.html` — 19 Violations (resolved 2026-04-17)
3. `projects.html` — 7 Violations (resolved 2026-04-17)

---

## 4. Empfehlung nächste 2 Wochen

**Priorität 1 — Publishing-Modul Mockups (Phase 3.2)**

Nächster strategischer Schritt gemäss Decision 2026-04-26. Research → PO-Q&A → Spec v0.1 → Mockup-Skelett. Ziel: bis Ende Mai alle 5 ERP-Modul-Mockups sichtbar, danach Backend-Implementation-Start.

**Priorität 2 — Grundlagen-Digests regenerieren (Housekeeping)**

30-Minuten-Task als Session-Einstieg. Verhindert Context-Drift bei `/prime-ark`. Sinnvoll vor Publishing-Research damit Performance-Stammdaten korrekt im Context sind.

---

## 5. Fragen an dich

1. **Publishing starten?** (§2A): Grünes Licht für Publishing-Modul als nächste Arbeits-Session?

2. **Team-Wechsel-Commission** (§2B): Wie lautet die Regel bei AM-Wechsel mid-Mandat — anteilig nach Wochen, letzter AM kriegt alles, oder 50/50-Split? (Damit Q11 aus Billing Batch 3 geschlossen werden kann.)

3. **Digests zuerst** (§2C): Soll ich die 5 STALE-Digests zu Beginn der nächsten Session regenerieren, bevor wir mit Publishing anfangen?

4. **Sample-Data-Reihenfolge** (§2D): Rollout nach Mockup-Vollständigkeit (Publishing + Messaging) — OK so?

5. **Snapshot-Bar max. 6 Slots** (§2E): Einverstanden mit einheitlich max. 6 Slots über alle Entity-Masken?

---

_Quellen: [[detailseiten-nachbearbeitung]] · [[decisions]] · [[grundlagen-changelog]] · [[lint-violations]] · `git log --since=2026-04-22`_
