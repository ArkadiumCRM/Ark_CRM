---
title: "ARK Scraper Modul Interactions v0.1 (+ Patch v0.2)"
type: source
created: 2026-04-13
updated: 2026-04-17
sources: ["ARK_SCRAPER_MODUL_INTERACTIONS_v0_1.md", "ARK_SCRAPER_MODUL_PATCH_v0_1_to_v0_2.md"]
tags: [source, scraper, interactions, review-workflow, claim-alert, anomalie]
---

# ARK Scraper Modul Interactions v0.1 (+ Patch v0.2)

**Datei:** `specs/ARK_SCRAPER_MODUL_INTERACTIONS_v0_1.md`
**Patch (17.04.2026):** `specs/ARK_SCRAPER_MODUL_PATCH_v0_1_to_v0_2.md` — Accept-Drawer fully replicated pro Finding-Typ (P4), Schutzfrist-Critical-Flow präzisiert (P7), AI-Prompt-Editor mit Test-Button (P8).
**Status:** v0.1 = Erstentwurf · v0.2 = UI-Konsolidierung
**Begleitdokument:** [[scraper-schema]] v0.1 (+Patch v0.2)

## Kern-Flows

- **Review-Queue als Staging:** Alle Findings landen in `pending_review` mit Confidence. Accept öffnet Finding-Typ-spezifischen Drawer (Kontakt/Vakanz/Kandidat/Gruppe/Stammdaten)
- **Bulk-Accept ≥ 80% Confidence:** Einfache Typen auto-execute, komplexe Typen (new_contact/new_vacancy/person_job_change) nacheinander via Drawer
- **Duplicate-Detection** vor Queue-Insert (Email-Match, Title+Account-Match, bekannte Wechsel)
- **Priority-Scheduling** basierend auf Account-Temperatur + Customer Class + Base-Interval
- **N-Strike-Disable** nach 5 aufeinanderfolgenden Fehlern + Critical Alert
- **Retry** exp. Backoff (1min, 5min), 3 Versuche vor Error
- **Live-Update** via Websocket (Runs-Status, Findings, Alerts Near-Live)

## 5 Cross-Entity-Flows

1. **new_contact** → Kontakt-Erstellungs-Drawer mit Kandidat-Auto-Match (Kontakt=Kandidat-Regel)
2. **new_vacancy** → Job mit `status='scraper_proposal'`, Confirmation in Job-Detailseite
3. **person_job_change** → Schutzfrist-Query (account + group), bei Treffer Critical Alert + Claim-Workflow
4. **group_suggestion** → Firmengruppe-Erstellungs-Drawer, rückwirkende Schutzfrist-Gruppen-Einträge
5. **stammdaten_drift** → Warning-Alert, AM aktualisiert Account-Tab 1

## Alert-Severity

- **Critical:** protection_violation_detected → Push an Admin+Admin+AM
- **Error:** run_failed, auth_failed, n_strike_disable
- **Warning:** anomaly_fluktuation, stammdaten_drift, rate_limit_reached
- **Info:** high_confidence_findings, vacancy_spike

## AI-Integration

- Extraktion (HTML → JSON) via LLM
- Klassifizierung Relevance
- Confidence-Berechnung (regelbasiert + AI + Source-Vertrauen gewichtet)

## 13 Events dokumentiert

Inkl. `protection_violation_detected` (kritisch für Schutzfrist-Tab) und `anomaly_detected` (für Market-Intelligence).

## Verlinkte Wiki-Seiten

[[scraper-schema]], [[scraper]], [[account]], [[job]], [[firmengruppe]], [[direkteinstellung-schutzfrist]], [[ai-system]], [[event-system]], [[berechtigungen]], [[detailseiten-guideline]]
