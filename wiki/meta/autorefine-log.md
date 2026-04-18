---
title: "Autorefine Loop — Run-Log"
type: meta
created: 2026-04-18
updated: 2026-04-18
tags: [autorefine, log, nachbearbeitung]
---

# Autorefine Log

Append-only, newest on top. Jeder Eintrag dokumentiert einen Loop-Durchgang des `ark-autorefine`-Skills.

Format:
```
## [YYYY-MM-DD HH:MM] <Punkt-Name>
- **Files:** [Liste]
- **Violations Before/After:** N → K
- **Drift Before/After:** M → L
- **Outcome:** kept | reverted | partial
- **Peter-Feedback:** [falls refinement]
```

---

## [2026-04-18 · Run 15 REVERTED] Decision 3 — Claim-Rechnung Skeleton-docx

- **Entscheidung:** Peter wählte initial Option B (Claude generiert Skeleton).
- **Versuch:** Node `docx`-Paket, Script `scripts/autorefine/generate-claim-templates.js`, generierte 2× `.docx` in `raw/General/` mit allen Platzhaltern, A4, Arial, Gold-Placeholder-Farbe.
- **Peter-Reaction:** "Nicht annähernd unser Design, bitte löschen und Notiz schreiben dass diese noch erstellt werden muss."
- **Outcome:** reverted — beide `.docx` + Script gelöscht, leere `scripts/`-Ordner entfernt. `template-spec.md` und `nachbearbeitung.md` auf "zu erstellen von Peter" umgestellt.
- **Learning:** Corporate-Design-Templates brauchen manuelle Word-Arbeit (Logo, Farben, Font, Layout). Autorefine-Skill-Scope respektieren — Platzhalter-Contract OK, visuelle Corporate Identity nicht.

## [2026-04-18 · Run 14] Decision 2 — Account Projekte als bedingter Tab (Variante C)

- **Entscheidung:** Peter wechselt von A zu C nach Scope-Reality-Check (~100 Substitutionen bei A inkl. Mockup). Variante C ist additiv analog Firmengruppe.
- **Files:** `specs/ARK_ACCOUNT_DETAILMASKE_INTERACTIONS_v0_3.md` (TEIL 0 Tab-Struktur zweite bedingt-Zeile, TEIL 14 neu), `specs/ARK_ACCOUNT_DETAILMASKE_SCHEMA_v0_2.md` (§19 neu, Header Tabbar-Text + Changelog-Eintrag), `wiki/meta/decision-draft-account-tab-projekte.md` (Decision finalisiert), `wiki/meta/detailseiten-nachbearbeitung.md`
- **Content TEIL 14:** Sichtbarkeit-Condition (EXISTS Bauherr OR Participation), Query-Logic (UNION), Filter-Chips (Rolle/Status/Zeitraum), Tabelle mit 8 Spalten, Header-Quick-Action Drawer-Flow "🏗 Projekt verknüpfen" inkl. Fuzzy-Match-Autocomplete + "+ Neues Projekt anlegen" Fallback, Row-Click-Drawer, Cross-Nav zu Projekt-§6, Edit-Logik read-mostly.
- **Zero Tab-Renumbering** — additive Änderung, kein Risk.
- **Follow-up:** Mockup accounts.html — bedingter Tab-Pattern analog Firmengruppe (separater Arbeitsschritt).
- **Outcome:** kept.

## [2026-04-18 · Run 13] Decision 1 — Snapshot-Slots Status quo (Option B)

- **Entscheidung:** Peter wählt Option B (variabel, Status quo).
- **Files:** `wiki/meta/decision-draft-snapshot-bar-slots.md`, `wiki/meta/detailseiten-nachbearbeitung.md`
- **Changes:** Decision-Draft in Decision-Doc umgewandelt. Keine Spec-Edits nötig.
- **Outcome:** kept — Bookkeeping.

## [2026-04-18 · Run 12] Mockup-HTMLs Mandat/Account/Assessment (P1)

- **Files:** `wiki/meta/detailseiten-nachbearbeitung.md`
- **Baseline:** Mockups existieren bereits — `accounts.html` (323KB), `mandates.html` (138KB), `assessments.html` (80KB), plus alle anderen.
- **Outcome:** kept — Bookkeeping. Punkt zwischen Erfassung (2026-04-13) und heute erledigt.

## [2026-04-18 · Run 11] Mandat + Job — Projekt-Verknüpfung (P1)

- **Files:** `specs/ARK_MANDAT_DETAILMASKE_SCHEMA_v0_2.md`, `specs/ARK_JOB_DETAILMASKE_SCHEMA_v0_1.md`
- **Baseline:** FK `linked_project_id` in Grundlagen-DB v1.3 bereits dokumentiert (L63, L75), aber in Mandat-/Job-Spec-Files nicht. Spec-Drift.
- **Changes:** Feld "Verknüpftes Projekt" (Autocomplete) in Mandat §Sektion 1 Grunddaten + Job §Sektion 2 Verknüpfungen hinzugefügt mit FK-Referenz und Cross-Nav-Hinweis.
- **Sync-Check:** DB-Schema v1.3 stimmt.
- **Outcome:** kept.

## [2026-04-18 · Run 10] Kandidatenmaske — Werdegang/Briefing Projekt-Integration

- **Files:** `wiki/meta/detailseiten-nachbearbeitung.md`
- **Baseline:** Kandidaten-Specs v1.3 haben alle 5 Sub-Requirements implementiert (Fuzzy-Match-Autocomplete, Confidence-Flow, Mini-Drawer, Werdegang-FK, Auto-Insert).
- **Outcome:** kept — Bookkeeping.

## [2026-04-18 · Run 9] Account neuer Tab "Projekte" — Decision-Draft

- **Files:** `wiki/meta/decision-draft-account-tab-projekte.md` (neu)
- **Baseline:** Variante A (Tab-Insertion zwischen 6 & 7) wäre Cross-File-Refactor ~50 Tab-Referenzen. Zu riskant für Batch.
- **Changes:** Decision-Draft mit 3 Positions-Varianten, Empfehlung **Variante B** (als Tab 14 am Ende — additiv).
- **Outcome:** deferred — wartet auf Peter-Entscheidung. Bei Approval Implementation-Outline bereits vorbereitet.

## [2026-04-18 · Run 8] Header-Snapshot-Bar Slot-Anzahl — Decision-Draft

- **Files:** `wiki/meta/decision-draft-snapshot-bar-slots.md` (neu)
- **Baseline:** Ist-Zustand variabel (Kandidat 4–8, Mandat 6–7, Account 6, Assessment 5).
- **Changes:** Decision-Draft mit 3 Optionen, Empfehlung **Option C** (Max 6, minimum 4, Kandidat als dokumentierte Ausnahme bis 8).
- **Outcome:** deferred — Peter-Entscheidung ausstehend.

## [2026-04-18 · Run 7] Cross-Navigation Breadcrumbs — Konsistenz-Pass

- **Files:** `wiki/meta/breadcrumbs-konsistenz.md` (neu)
- **Baseline:** 9 Detailseiten-Breadcrumbs inventarisiert. Strukturell konform (Top-Level 2-stufig, Sub-Entity 4-stufig, Hubs funktional). Regel "max 4 Ebenen, alle klickbar" erfüllt.
- **Changes:** Regel-Dokumentation + Inventar angelegt. Sub-Punkt DE/EN-Sprachmischung (Prozess-Spec/Job-Spec) als P2 dokumentiert.
- **Outcome:** kept — strukturell abgearbeitet, Sprach-Sub als Phase 2 offen.

## [2026-04-18 · Run 6] Claim-Rechnungs-Template — Platzhalter-Spec

- **Files:** `wiki/meta/claim-rechnung-template-spec.md` (neu)
- **Baseline:** Zwei `.docx` referenziert in Account-Interactions v0.3 TEIL 8c, aber in `raw/General/` nicht vorhanden.
- **Changes:** Vollständige Platzhalter-Struktur + Content-Outline für Fall X (Mandats-Direkteinstellung) und Fall Y/Z (Staffel) angelegt. Contract für Dok-Generator.
- **Outcome:** deferred — Peter muss Word-Design erstellen (Branding/IBAN/Signatur). P1 — erst bei erstem realen Claim relevant.

## [2026-04-18 · Run 5] Mandat-Tab 2 Longlist — Vorstellungs-Markierung UX

- **Files:** `specs/ARK_MANDAT_DETAILMASKE_INTERACTIONS_v0_3.md`
- **Baseline:** "Als vorgestellt markieren" nur textlich beschrieben, kein UX-Pattern.
- **Changes:** TEIL 10 §"UI im Mandat" ergänzt um "Vorstellungs-Markierung UX-Pattern (v0.3)": Drawer 540px (Drawer-Default-Regel) mit Vorstellungs-Typ / datetime-local-Picker / Kanal-Chip / Kontaktperson / Notiz / Doc-Upload. Bulk-Variante für Multi-Select. Korrektur-Flow mit Soft-Delete.
- **Outcome:** kept.

## [2026-04-18 · Run 4] Mandat-Tab 1 §6b Assessment-Details Inline-Expand

- **Files:** `specs/ARK_MANDAT_DETAILMASKE_SCHEMA_v0_2.md`, `specs/ARK_MANDAT_DETAILMASKE_INTERACTIONS_v0_3.md`
- **Baseline:** Option IX nur als Tabellen-Zeile mit Status + Drawer. Inline-Detail fehlt.
- **Changes:** Chevron-Spalte + Expand-Row pro Option-Typ. IX-Expand zeigt Credits-Aggregation + Kandidat-Chips + Assessment-Order-Link. Drawer-Default-Regel unverletzt (Inline = read, Drawer = edit via "Details"-Icon).
- **Outcome:** kept.

## [2026-04-18 · Run 3] Kandidat-Assessment-Tab — Auftrags-Referenz in Versionen

- **Files:** `wiki/meta/detailseiten-nachbearbeitung.md`
- **Baseline:** 4 von 5 Sub-Requirements bereits in Kandidaten-Specs v1.3 implementiert (Version-Label mit Auftrag+Account, Detailseiten-Link, Version-Pill+Button, Legacy-Fallback). Filter/Suche-nach-Auftrag als UI fehlt.
- **Changes:**
  1. Hauptpunkt als abgearbeitet markiert mit Fundstellen-Nachweis (Schema v1.3 L67–84, Interactions v1.3 L202–222, T4-1 L87).
  2. Restlicher Sub-Punkt "Filter/Suche nach Auftrag" als eigener **Phase-2-Punkt** (P2) neu angelegt — Trigger-Bedingung: erstes Multi-Auftrag-Mehrversionierungs-Szenario.
- **Outcome:** kept — Bookkeeping + Scope-Split. Kein Spec-Edit.
- **Violations Before/After:** n/a
- **Drift Before/After:** n/a
- **Peter-Feedback:** y

## [2026-04-18 · Run 2] Account-Tab 8 Assessments — Credits-Übersicht

- **Files:**
  - `specs/ARK_ACCOUNT_DETAILMASKE_SCHEMA_v0_2.md` (bumped to v0.3 content, Dateiname pending rename)
  - `specs/ARK_ACCOUNT_DETAILMASKE_INTERACTIONS_v0_3.md` (Status-Wechsel-Fix)
  - `wiki/meta/detailseiten-nachbearbeitung.md`
- **Baseline:** Interactions v0.3 hatte Credits-Übersicht-Banner komplett, Schema v0.2 lag hinterher (Drift). Zusätzlich stale `invoiced`-Transition in Interactions L748 (Grundlagen-Konflikt).
- **Changes:**
  1. Schema §12.1 Layout-Beschreibung auf 2-Banner-Reihe + Filter-Chips inkl. Typ-Multi-Select.
  2. Schema §12.2 neue Spalte "Credits-Mix"; Status-Wert `invoiced` gestrichen (Billing-State → `fact_assessment_billing`).
  3. Schema §12.3 umbenannt zu "KPI-Banner (v0.3)"; Credits-Banner-Zeile ergänzt mit Source-Referenz `fact_assessment_order_credits` grouped by type.
  4. Schema-Header: Title v0.2 → v0.3, Änderungen-v0.2→v0.3-Block.
  5. Interactions §Status-Wechsel: Zeile `completed → invoiced` entfernt; 5 Grundlagen-konforme Transitions dokumentiert (offered/ordered/partially_used/fully_used/cancelled); Billing-Trigger auf `ordered` (Credits-Modell).
- **Sync-Check:** Grundlagen (DATABASE_SCHEMA §14.3, GESAMTSYSTEM v1.3) + Assessment-Specs v0.3 bereits konform. Mandat v0.3 L211 `fact_mandate.status='invoiced'` ist **anderer** Enum (Mandat-Level, nicht Order-Level), bleibt korrekt.
- **Outcome:** kept
- **Follow-up:** Filename-Rename `SCHEMA_v0_2.md` → `_v0_3.md` als separater destruktiver Op (Peter-OK nötig).
- **Peter-Feedback:** ok

## [2026-04-18 · Run 1] Account-Tab 9 Schutzfristen — Gruppen-Scope (P0)

- **Files:** `specs/ARK_ACCOUNT_DETAILMASKE_INTERACTIONS_v0_3.md`, `specs/ARK_MANDAT_DETAILMASKE_INTERACTIONS_v0_3.md`, `wiki/meta/detailseiten-nachbearbeitung.md`
- **Baseline-Check:** Beide Specs bereits auf v0.3 gebumped. Alle 5 Sub-Punkte inhaltlich implementiert (Label, Claim-Workflow, Dual-Insert bei Vorstellung, Scraper-Dual-Scope, Datenmodell scope+group_id+CHECK).
- **Outcome:** kept — Bookkeeping-Only. Kein Spec-Edit nötig, Punkt in `detailseiten-nachbearbeitung.md` als "Abgearbeitet 2026-04-18 via autorefine" markiert mit Fundstellen-Nachweis (Zeilenreferenzen auf v0.3).
- **Violations Before/After:** n/a (kein Content-Edit)
- **Drift Before/After:** n/a (Bookkeeping)
- **Peter-Feedback:** y

## Related

- [[detailseiten-nachbearbeitung]]
- [[decisions]]
