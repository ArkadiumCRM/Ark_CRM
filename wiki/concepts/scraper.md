---
title: "Scraper & Market Intelligence"
type: concept
created: 2026-04-08
updated: 2026-04-17
sources: ["ARK_GESAMTSYSTEM_UEBERSICHT_v1_3.md", "ARK_BACKEND_ARCHITECTURE_v2_5.md", "ARK_SCRAPER_MODUL_SCHEMA_v0_1.md", "ARK_SCRAPER_MODUL_PATCH_v0_1_to_v0_2.md"]
tags: [concept, scraper, intelligence, linkedin, mockup-v0.2]
---

# Scraper & Market Intelligence

Automatisches Monitoring von Account-Websites und LinkedIn.

**Mockup:** `mockups/scraper.html` (Stand 17.04.2026, Single-File mit 6 internen Tabs).
**Spec:** [[scraper-schema]] v0.1 + [[scraper-interactions]] v0.1 + Patch v0.2 (UI-Konsolidierung).

## Funktionen

- **Account-Website-Monitoring** — Erkennt Personaländerungen, neue Stellen
- **LinkedIn Social Tracking** — Likes, Comments, Shares, Activity Score
- **Approve/Reject Workflow** — Mensch bestätigt Scraper-Ergebnisse
- **Auto-Erstellung** — Nach Bestätigung: Kontakte, Vakanzen, Organigramm-Updates

## Change Detection

| Change Type | Beschreibung |
|-------------|-------------|
| new_person | Neue Person bei Account |
| person_left | Person hat Account verlassen |
| new_job | Neue Stelle erkannt |
| role_changed | Rollenänderung einer Person |

## Tabellen

- `fact_scraped_items` — Gescrapte Items pending Review
- `fact_scrape_snapshots` — Point-in-Time Ergebnisse
- `fact_scrape_changes` — Erkannte Änderungen
- `fact_job_platforms` — Job-Plattform-Tracking mit Laufzeit

## Scheduling

Mo-Fr 8:00 (konfigurierbar). Pro Account: Scraping Toggle + Intervall.

## Backpressure

Max 3 Scraper-Jobs concurrent pro Tenant.

## Related

- [[account]] — Scraping-Konfiguration pro Account, auto-erstellte Kontakte
- [[job]] — Aus Scraper erkannte Vakanzen (als unbestätigte Jobs)
- [[event-system]] — Scraper-Events
