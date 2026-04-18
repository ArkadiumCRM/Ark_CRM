---
title: "Decision — Account neuer Tab 'Projekte'"
type: meta
created: 2026-04-18
updated: 2026-04-18
tags: [decision, account, projekte, tab-struktur]
---

# Decision · Account neuer Tab "Projekte"

**Entscheidung 2026-04-18 (Peter):** **Variante C — bedingter Tab (analog Firmengruppe).**

Tab "Projekte" ist sichtbar nur wenn Account als Bauherr (`fact_projects.bauherr_account_id`) oder via `fact_project_company_participations` mit mindestens einem Projekt verknüpft ist. Kein Tab-Renumbering nötig (additiv, zero Cross-Ref-Updates). Macht dann auch logisch Sinn warum Projekte "nach" Reminders erscheint: weil bedingt, nicht fix positioniert.

**Implementiert 2026-04-18 in:**
- `specs/ARK_ACCOUNT_DETAILMASKE_SCHEMA_v0_3.md` §19 (neue Sektion analog §18 Firmengruppe)
- `specs/ARK_ACCOUNT_DETAILMASKE_INTERACTIONS_v0_3.md` TEIL 14 (neu, analog TEIL 13 Firmengruppe) + TEIL 0 Tab-Struktur-Tabelle um zweite bedingt-Zeile ergänzt
- Mockup-Integration (accounts.html): Follow-up — analog Firmengruppe-conditional-tab-Pattern (ausgeblendet per Default, sichtbar wenn EXISTS-Condition erfüllt)

## Scope (aus detailseiten-nachbearbeitung.md)

Account-Detailseite braucht Sicht auf alle Projekte, in denen der Account beteiligt ist — als Bauherr ODER via Firmen-Beteiligung.

**Content:**
- Liste aller `fact_projects` WHERE `bauherr_account_id = this.id` OR `this.id IN (SELECT account_id FROM fact_project_company_participations WHERE project_id = …)`
- Filter: Rolle (Bauherr / Architekt / TU / Spezialist / …), Status, Zeitraum
- Klick → Projekt-Detailseite
- Cross-Link zu AM-Notizen (Projekt §6)

## Positions-Varianten

### Variante A (aus Nachbearbeitungs-Punkt): zwischen Tab 6 Jobs & Tab 7 Mandate

- Impact: **Cross-File-Refactor** — alle Tab-7–13-Referenzen in Schema + Interactions (~50 Stellen) verschieben sich +1
- Pro: Logische Gruppierung (Aktivitäten vor operativem Geschäft)
- Contra: Hohes Änderungs-Volumen, Risiko für Stale-Refs

### Variante B (Empfehlung): als letzter Tab (14 Projekte)

- Nach Tab 13 Reminders als Tab 14
- Impact: **Zero Cross-Reference-Updates** — nur additive Änderung
- Pro: Geringes Risiko, keine Umnummerierung
- Contra: Gruppierung weniger logisch (Reminders als Sub-Tool gegenüber Projekte-Sachinhalt)

### Variante C: als bedingter Tab (analog Firmengruppe)

- Sichtbar nur wenn `EXISTS(fact_projects WHERE bauherr_account_id = this.id) OR EXISTS(fact_project_company_participations WHERE account_id = this.id)`
- Positionsoption: nach Tab 5 Organisation oder als zusätzlicher bedingter Tab neben Firmengruppe
- Pro: Entlastet UI bei Accounts ohne Projekt-Verknüpfung
- Contra: Bedingte Tabs sind Ausnahme — Vermehrung verwässert Konzept

## Empfehlung: **Variante B**

Minimales Risiko, genug logische Nähe zu Operations-Tabs (Prozesse/History/Dokumente/Reminders/Projekte). Variante A könnte in Phase 2 nachgezogen werden, wenn alle Detailmasken-Specs einen grossen Cross-Refactor-Durchgang bekommen.

## Outline für Schema-Ergänzung (Variante B, bei Approval)

**§16. TAB 14 — PROJEKTE (neu v0.3)**

- Layout: Filter-Chips (Rolle · Status · Zeitraum) + Tabelle
- Spalten: Projekt-Name · Bauherr (falls nicht this.account) · Rolle (Bauherr/Architekt/TU/…) · Status · Zeitraum · Arkadium-Beteiligung (# Placements)
- Empty-State: "Noch keine Projekte mit diesem Account verknüpft. [+ Projekt anlegen]"
- Cross-Nav: Klick auf Zeile → `/projects/[id]`

**Interactions-Ergänzung TEIL 14:**
- Query-Logic: UNION aus `fact_projects.bauherr_account_id = X` + `fact_project_company_participations WHERE account_id = X`
- Dedup via `UNIQUE project_id`; pro Projekt aktuellste Rolle-Zeile
- Filter-Chips reagieren clientseitig auf `role` / `status` / `date_range`
- Quick-Action Header: "🏗 Projekt verknüpfen" (öffnet Drawer → Projekt-Autocomplete + Rolle-Dropdown → Insert in `fact_project_company_participations`)

## Impact-Analyse

- Schema v0.2 → v0.3-Delta mit §16 ergänzen
- Interactions v0.3 Update mit TEIL 14
- Keine DB-Changes (fact_projects + fact_project_company_participations existieren bereits laut Projekt-Spec)
- Kein Enum-Change
- Mockup: neue Tab-Zeile in mockups-HTML (separater Mockup-Punkt #11)

## Related

- [[detailseiten-nachbearbeitung]]
- [[autorefine-log]] Run 9
- `specs/ARK_PROJEKT_DETAILMASKE_SCHEMA_v0_2.md`
- `specs/ARK_ACCOUNT_DETAILMASKE_SCHEMA_v0_3.md`
- `specs/ARK_ACCOUNT_DETAILMASKE_INTERACTIONS_v0_3.md` TEIL 0 Tab-Struktur
