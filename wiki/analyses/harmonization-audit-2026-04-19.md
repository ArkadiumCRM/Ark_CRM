---
title: "Harmonisierungs-Audit Mockups · 2026-04-19"
type: analysis
created: 2026-04-19
updated: 2026-04-19
sources: ["scripts/autorefine/harmonization-audit.py"]
tags: [audit, harmonization, mockups, lint]
---

# Harmonisierungs-Audit Mockups · 2026-04-19

Scan über alle 25 Mockup-Files in `mockups/Vollansichten/` + `mockups/Listen/`. Prüfung gegen Admin/Stammdaten/Scraper als Referenz-Pattern.

## Pattern-Klassen

Drei Kategorien mit eigenen Anforderungen:

### A — Detail-Vollansichten (Entity-Masken)
**Files:** accounts, candidates, mandates, jobs, projects, processes, assessments, groups, admin, stammdaten, scraper

**Soll-Pattern:**
- Standard ARK-Header (`.header` · Logo · Breadcrumb · ⌘K · Theme)
- Shared CSS + JS (`_shared/editorial.css` + `_shared/layout.js`)
- Page-Banner mit H1 (Entity-Name · Meta · Action-Buttons)
- KPI-Strip mit 6 Cards (oder Snapshot-Bar mit 6 Slots)
- Tabbar (`.tabbar` + `.tab` + `.num`)
- Warn-Banner **optional** (nur bei System-Admin-Kontext wie `admin.html` / `stammdaten.html`)

### B — Dashboard / System-Views
**Files:** dashboard, admin-dashboard-templates, reminders

**Soll-Pattern:**
- Header · CSS · JS · Page-Banner · KPI-Strip
- Tabbar **optional** — je nach UX (reminders hat filter-chips, dashboard hat widget-grid)
- Warn-Banner **optional**

### C — Listen-Ansichten
**Files:** *-list.html + admin-mobile

**Soll-Pattern:**
- Header · CSS · JS · Page-Banner
- Toolbar mit Filter + Suche
- Tabelle (data-table)
- KPI-Strip **nicht nötig** (Listen zeigen Einträge, keine Aggregate)
- Tabbar **nicht nötig** (Listen sind Single-View)

### D — Tool-Masken (Exceptions)
**Files:** dok-generator, email-kalender

**Soll-Pattern:**
- Header · CSS · JS · Page-Banner
- Andere UX frei (Split-View · Template-Editor · Mail-Composer)

---

## Scan-Resultate

### Vollansichten/ (16 Files)

| File | Typ | Header | CSS | JS | Warn | Banner | KPI | Tabbar | Size | Drift |
|------|-----|--------|-----|-----|------|--------|-----|--------|------|-------|
| `admin.html` | 📘 Ref | ✅ | (inline) | ✅ | ✅ | ✅ | ✅ | ✅ | 253k | konform |
| `stammdaten.html` | 📘 Ref | ✅ | (inline) | ✅ | ✅ | ✅ | ✅ | ✅ | 226k | konform |
| `scraper.html` | 📘 Ref | ✅ | ✅ | (inline `toggleTheme`) | ✅ | ✅ | ✅ | ✅ | 182k | konform (mit Minor-Drift) |
| `accounts.html` | A | ✅ | ✅ | ✅ | — | ✅ | ✅ | ✅ | 315k | **konform** |
| `candidates.html` | A | ✅ | ✅ | ✅ | — | ✅ | ✅ | ✅ | 570k | **konform** |
| `mandates.html` | A | ✅ | ✅ | ✅ | — | ✅ | ✅ | ✅ | 132k | **konform** |
| `jobs.html` | A | ✅ | ✅ | ✅ | — | ✅ | ✅ | ✅ | 129k | **konform** |
| `projects.html` | A | ✅ | ✅ | ✅ | — | ✅ | ✅ | ✅ | 215k | **konform** |
| `processes.html` | A | ✅ | ✅ | ✅ | — | ✅ | ✅ | ✅ | 177k | **konform** |
| `assessments.html` | A | ✅ | ✅ | ✅ | — | ✅ | ✅ | ✅ | 76k | **konform** |
| `groups.html` | A | ✅ | ✅ | ✅ | — | ✅ | ✅ | ✅ | 114k | **konform** |
| `dashboard.html` | B | ✅ | ✅ | ✅ | — | ✅ | ✅ | — | 114k | **konform** (Dashboard = keine Tabs) |
| `reminders.html` | B | ✅ | ✅ | ✅ | — | ✅ | ✅ | — | 72k | **konform** (Reminders = filter-chips) |
| `admin-dashboard-templates.html` | B | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | — | 27k | **konform** (Template-Editor) |
| `dok-generator.html` | ⚠ D | ✅ | ✅ | ✅ | — | ✅ | — | — | 89k | **konform** (Tool-Maske) |
| `email-kalender.html` | ⚠ D | ✅ | ✅ | (inline) | — | ✅ | — | — | 120k | **konform** (Tool-Maske) |

### Listen/ (9 Files)

| File | Header | CSS | JS | Banner | Toolbar | Size | Drift |
|------|--------|-----|-----|--------|---------|------|-------|
| `accounts-list.html` | ✅ | ✅ | ✅ | ✅ | ✅ | 12k | **konform** |
| `candidates-list.html` | ✅ | ✅ | ✅ | ✅ | ✅ | 12k | **konform** |
| `mandates-list.html` | ✅ | ✅ | ✅ | ✅ | ✅ | 9k | **konform** |
| `jobs-list.html` | ✅ | ✅ | ✅ | ✅ | ✅ | 8k | **konform** |
| `projects-list.html` | ✅ | ✅ | ✅ | ✅ | ✅ | 7k | **konform** |
| `processes-list.html` | ✅ | ✅ | ✅ | ✅ | ✅ | 9k | **konform** |
| `assessments-list.html` | ✅ | ✅ | ✅ | ✅ | ✅ | 6k | **konform** |
| `groups-list.html` | ✅ | ✅ | ✅ | ✅ | ✅ | 6k | **konform** |
| `admin-mobile.html` | ✅ | ✅ | ✅ | — | — | 25k | **Tech-Demo** (Mobile-Showcase, nicht Content-List — gehört evtl. in eigenen Ordner) |

---

## Drift-Summary

**Alle 25 Files strukturell konform** nach Pattern-Klasse.

Echte Drift-Punkte (Minor):

1. `scraper.html` · Class-Name `.tab-pane` statt `.tab-panel` (alle anderen nutzen `.tab-panel`)
2. `scraper.html` · `toggleTheme()` inline-JS statt `_shared/layout.js`-Import (funktional identisch, Code-Duplikat)

---

## Farbschema-Check

Alle Detail-Vollansichten prüfen auf konsistenten `--accent`-Navy:

| File | Primary-Accent | Sekundär-Accents | Bewertung |
|------|---------------|------------------|-----------|
| `accounts.html` | `--accent` Navy | `--gold` · k-* KPIs | ✅ |
| `candidates.html` | `--accent` Navy | `--purple` Assessment · `--gold` | ✅ |
| `mandates.html` | `--accent` Navy | `--gold` Target · `--amber` Taskforce | ✅ |
| `jobs.html` | `--accent` Navy | `--amber` Vakanz · `--gold` | ✅ |
| `projects.html` | `--accent` Navy | `--gold` Bauherr | ✅ |
| `processes.html` | `--accent` Navy | Stage-Pipeline-Colors | ✅ |
| `assessments.html` | `--accent` Navy + `--purple` Assessment | Credits-Strip | ✅ |
| `groups.html` | `--accent` Navy | `--gold` Holding | ✅ |
| `admin.html` | `--accent` Navy | k-* KPIs | ✅ |
| `stammdaten.html` | `--accent` Navy | k-* KPIs | ✅ |
| `scraper.html` | `--accent` Navy | `--purple` Review-KPIs · `--red` Alerts | ✅ (seit commit `e7260d0`) |
| `dashboard.html` | `--accent` Navy | Widget-Color-Tokens | ✅ |
| `reminders.html` | `--accent` Navy | `--red` Überfällig · `--amber` Heute | ✅ |

---

## Tab-Navigation-Check (Detail-Vollansichten)

| File | Tab-Count | Tab-Klasse | Tab-Panel-Klasse | switchTab-Impl |
|------|-----------|-----------|-------------------|-----------------|
| `admin.html` | 10 | `.tab` | `.tab-panel` | `_shared/layout.js` |
| `stammdaten.html` | 10 | `.tab` | `.tab-panel` | local `switchTab` (string-ID) |
| `scraper.html` | 6 | `.tab` | **`.tab-pane` ⚠** | local `switchTab` (string-ID) |
| `accounts.html` | 13+2 bedingt | `.tab` | `.tab-panel` | `_shared/layout.js` |
| `candidates.html` | 10 | `.tab` | `.tab-panel` | `_shared/layout.js` |
| `mandates.html` | 6 | `.tab` | `.tab-panel` | `_shared/layout.js` |
| `jobs.html` | 6 | `.tab` | `.tab-panel` | `_shared/layout.js` |
| `projects.html` | 8 | `.tab` | `.tab-panel` | `_shared/layout.js` |
| `processes.html` | 3 | `.tab` | `.tab-panel` | `_shared/layout.js` |
| `assessments.html` | 5 | `.tab` | `.tab-panel` | `_shared/layout.js` |
| `groups.html` | 5 | `.tab` | `.tab-panel` | `_shared/layout.js` |

---

## Empfehlungen

### P0 — keine (alles strukturell konform)

### P1 — Mini-Harmonisierungen (Cosmetic · ~15 min total)

1. **scraper.html** · Class-Rename `.tab-pane` → `.tab-panel` + switchTab-Selector nachziehen (analog Stammdaten-Fix aus commit `ffdde8d`)
2. **scraper.html** · `toggleTheme()` inline raus + `_shared/layout.js`-Script-Tag ergänzen

### P2 — Optional (Polish · ~30 min)

3. **KPI-Color-Convention** kodifizieren in Baseline §16 (z.B.):
   - `k-gold` = Geld / Umsatz
   - `k-green` = Erfolg / Aktiv
   - `k-red` = Fehler / Überfällig / Critical
   - `k-amber` = Warning / Stale
   - `k-blue` = Info / Meta
   - `k-purple` = AI / Assessment / Review
4. **Icon-Prefix im Page-Banner-H1** einheitlich durchziehen (aktuell: 🔧 Admin · 📚 Stammdaten · 🕸 Scraper haben, andere nicht). Entscheidung: Pflicht ja/nein?

### P3 — Struktur-Polish (~15 min)

5. **admin-mobile.html** aus `Listen/` verschieben (ist Mobile-Viewport-Demo, keine Liste). Ziel: `mockups/Showcases/admin-mobile.html` oder zurück in Root. Navigation in crm.html / crm-mobile.html entsprechend anpassen.

---

## Fazit

**Mockups sind strukturell konsistent.** Alle 25 Files folgen dem jeweiligen Pattern ihrer Klasse (Detail-View · Dashboard · Liste · Tool-Maske).

Die 2 echten Drift-Punkte sind Minor-Cosmetics (~15 min Fix). Restliche Empfehlungen sind optional Polish — kein struktureller Fehler.

**Empfehlung zum Vorgehen:**
1. P1 fixen (scraper.html: 2 Mini-Änderungen)
2. Peter entscheidet ob P2/P3 Teil dieser Session oder Deferred

## Related

- [[sync-report-2026-04-18]] — vorheriger Drift-Scan (Post-autorefine)
- [[autorefine-log]] — Run 18 (scraper-deploy) · Run 17 (bedingter Tab Projekte)
- [[mockup-baseline]] — §16 Color-Convention Phase 2
