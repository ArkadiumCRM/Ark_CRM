---
title: "ARK Scraper Modul Schema v0.1 (+ Patch v0.2)"
type: source
created: 2026-04-13
updated: 2026-04-17
sources: ["ARK_SCRAPER_MODUL_SCHEMA_v0_1.md", "ARK_SCRAPER_MODUL_PATCH_v0_1_to_v0_2.md"]
tags: [source, scraper, monitoring, marktbeobachtung, ai-extraction]
---

# ARK Scraper Modul Schema v0.1 (+ Patch v0.2)

**Datei:** `specs/ARK_SCRAPER_MODUL_SCHEMA_v0_1.md`
**Patch (17.04.2026):** `specs/ARK_SCRAPER_MODUL_PATCH_v0_1_to_v0_2.md` — UI-Präzisierungen nach Mockup-Umsetzung (`mockups/scraper.html`). Keine Breaking Changes für DB/Events/Worker.
**Status:** v0.1 = Erstentwurf · v0.2 = UI-Konsolidierung
**Begleitdokument:** [[scraper-interactions]] v0.1 (+Patch v0.2)

## Mission

Automatische Marktbeobachtung mit Near-Live-Reactions. Accounts / Jobs / Kandidaten werden automatisch ins CRM eingetragen, Team-/Vakanz-/Personen-Änderungen erkannt, Schutzfrist-Verletzungen detektiert.

## 6 Tabs

1. Dashboard — System-Gesundheit, Findings-Breakdown, Top-Activity, Errors, Anomalie-Radar
2. Review-Queue — Pending Findings (Staging-Area mit Confidence-Sortierung)
3. Runs — Alle Scrape-Durchläufe mit Drilldown
4. Configs — Scraper-Typen-Registry + globale Settings
5. Alerts & Fehler — 9 Alert-Typen inkl. Critical `protection_violation_detected`
6. History — System-weites Event-Log

## 7 Scraper-Typen (Phase 1)

1. Team-Page → Kontakte
2. Career-Page → Vakanzen
3. Impressum / AGB → Stammdaten-Check
4. LinkedIn → **Phase 2** (Komplexität)
5. Externe Jobboards (jobs.ch, alpha.ch)
6. Geschäftsberichte / Presse (AI-klassifiziert)
7. Handelsregister → UID-Match für Firmengruppen

## Schlüssel-Konzepte

- **Staging-Flow:** Alles landet in `fact_scraper_findings.status = 'pending_review'`, AM/Admin bestätigt manuell
- **Confidence-Score** 0–100 pro Finding, Auto-Accept-Schwelle konfigurierbar (Default v0.1: kein Auto-Accept)
- **Priority-Scheduling:** `effective_interval = base × temperature_factor × class_factor` (Hot-Account 0.5, Cold 2.0)
- **N-Strike-Disable:** Nach 5 aufeinanderfolgenden Fehlern auto-deaktiviert + Critical Alert
- **Retention:** Diff-Änderungen + Metadata dauerhaft, Raw-HTML nur 7 Tage (30 bei Fehler)
- **Cross-Entity-Trigger:** Kontakt-Vorschlag, Vakanz-Proposal, Schutzfrist-Match, Firmengruppen-Vorschlag

## Neue DB-Tabellen

- `dim_scraper_types` — Registry der Scraper-Implementierungen
- `dim_scraper_global_settings` — Schwellen, Faktoren, Limits
- `fact_scraper_schedule` — Next-Run-Zeiten
- `fact_scraper_runs` — jeder Durchlauf
- `fact_scraper_findings` — jedes detektierte Item (Review-Queue-Backend)
- `fact_scraper_alerts` — Alerts mit Severity

## Verlinkte Wiki-Seiten

[[scraper]], [[scraper-interactions]], [[account]], [[job]], [[firmengruppe]], [[direkteinstellung-schutzfrist]], [[ai-system]], [[detailseiten-guideline]]
