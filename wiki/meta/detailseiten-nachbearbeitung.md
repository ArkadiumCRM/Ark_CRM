---
title: "Detailseiten-Nachbearbeitungs-Notizen"
type: meta
created: 2026-04-13
updated: 2026-04-13
tags: [detailseiten, nachbearbeitung, todo, cross-reference]
---

# Detailseiten-Nachbearbeitungs-Notizen

Punkte, die erst bei der **Gesamtüberarbeitung am Schluss** (rückwärts durch alle Detailmasken) eingearbeitet werden. Ziel: Cross-References und aggregierte Sichten zwischen Detailseiten sauber verknüpfen, nachdem alle Einzel-Specs existieren.

## Zweck

Wenn wir alle Detailseiten einzeln bauen, entstehen natürlicherweise **Verknüpfungs-Lücken** — eine Detailseite referenziert eine andere, die zu dem Zeitpunkt noch nicht existiert oder noch anders strukturiert war. Nach der ersten Durchlaufsrunde (alle Detailseiten haben Schema + Interactions v0.1+) gehen wir systematisch rückwärts durch und schliessen diese Lücken.

---

## Offene Nachbearbeitungs-Punkte

### Account-Detailseite Tab 9 Schutzfristen — Gruppen-Scope (KRITISCH)

**Erfasst:** 2026-04-13
**Grund:** Entscheidung FG-10 (Firmengruppen-Schema) — Schutzfrist gilt gruppenweit, nicht nur pro Account. AGB-konform ("Rechtsnachfolger, Konzerngesellschaften und nahestehende Personen").
**Was fehlt:** Account-Interactions v0.2 → v0.3 muss erweitert werden:
- Tab 9 Schutzfristen zeigt zusätzlich `scope='group'` Einträge mit Label "Gruppen-Schutzfrist" (bei Accounts die einer Gruppe angehören)
- Claim-Workflow berücksichtigt Group-Level-Treffer
- Bei Vorstellung: zwei `fact_protection_window` Einträge (`account` + `group`) werden erstellt wenn `account.group_id IS NOT NULL`
- Scraper-Match-Logik prüft beide Scopes
- Datenmodell-Update: `fact_protection_window.scope` + `group_id` (siehe Firmengruppe-Schema § 14)

**Betroffene Specs:**
- `ARK_ACCOUNT_DETAILMASKE_INTERACTIONS_v0_2.md` → v0.3
- `ARK_MANDAT_DETAILMASKE_INTERACTIONS_v0_2.md` TEIL 10 Schutzfrist-Integration

**Priorität:** P0 beim Gesamt-Review-Durchlauf.

---

### Account-Detailseite Tab 8 (Assessments) — Credits-Übersicht

**Erfasst:** 2026-04-13
**Grund:** Entscheidung 2026-04-13 — Credits-Modell beim Assessment.
**Was fehlt:** In der Account-Detailseite Tab 8 "Assessments" sollte eine aggregierte **Credits-Übersicht pro Account** sichtbar sein:
- Credits gekauft (Summe über alle `fact_assessment_order.credits_total`)
- Credits verbraucht (Summe über `credits_used`)
- Credits offen (zugewiesen aber noch nicht durchgeführt)
- Credits frei (noch nicht zugewiesen)
- Durchschnittspreis pro Credit
- Evtl. Kosten-Total pro Jahr

**Umsetzung-Idee:** KPI-Banner-Zeile oben in Tab 8, neben dem bestehenden Teamrad-Abdeckungs-KPI:

```
📊 Teamrad-Abdeckung: 12 von 47    |    🎯 Credits: 15 gekauft · 12 verbraucht · 2 zugewiesen · 1 frei
```

**Betroffene Specs:** `ARK_ACCOUNT_DETAILMASKE_SCHEMA_v0_2.md` § 12, `ARK_ACCOUNT_DETAILMASKE_INTERACTIONS_v0_2.md` TEIL 8b.

---

### Kandidat-Assessment-Tab — Auftrags-Referenz in Versionen

**Erfasst:** 2026-04-13
**Grund:** Assessment-Auftrags-Versionen tragen `assessment_order_id` FK, aber Kandidaten-Schema v1.2 zeigt das noch nicht in der Versions-Navigation.
**Was fehlt:** In den Sub-Tabs DISC / EQ / Scheelen 6HM / ASSESS 5.0 der Kandidatenmaske sollte pro Version sichtbar sein:
- "Version 2 — via Auftrag AS-2026-042 (Volare Group AG)" mit Link zur Assessment-Detailseite
- Filter/Suche nach Auftrag

**Betroffene Specs:** `ARK_KANDIDATENMASKE_SCHEMA_v1_2.md` (Tab 4 Assessment-Subtabs), `ARK_KANDIDATENMASKE_INTERACTIONS_v1_2.md`.

---

### Mandat-Detailseite Tab 1 Sektion 6b — Assessment-Details

**Erfasst:** 2026-04-13
**Was fehlt:** Die Optionale-Stages-Section zeigt Option IX nur als Zeile mit Status. Besser: Inline-Expand mit
- Anzahl Credits (bei Option IX)
- Wer wurde getestet
- Link zur Assessment-Detailseite (ist bereits geplant, aber UI-Detail fehlt)

**Betroffene Spec:** `ARK_MANDAT_DETAILMASKE_SCHEMA_v0_2.md` § 5 Sektion 6b.

---

### Mandat-Detailseite Tab 2 Longlist — Vorstellungs-Markierung UX

**Erfasst:** 2026-04-13
**Was fehlt:** Der manuelle Button "📋 Als vorgestellt markieren" auf Kandidat-Cards ab Stage 5+ braucht ein sauberes UX-Pattern (Modal vs. Inline-Dropdown vs. Card-Rückseite). Derzeit nur textlich beschrieben.

**Betroffene Spec:** `ARK_MANDAT_DETAILMASKE_INTERACTIONS_v0_2.md` TEIL 10.

---

### Account-Detailseite Tab 9 Schutzfristen — Claim-Rechnungs-Template

**Erfasst:** 2026-04-13
**Was fehlt:** Claim-Rechnung-PDF-Template existiert noch nicht im Template-Ordner. Referenziert aus Interactions v0.2 TEIL 8c.

**Betroffene Spec:** `ARK_ACCOUNT_DETAILMASKE_INTERACTIONS_v0_2.md` TEIL 8c "Claim stellen Flow". Template zu erstellen: `Vorlage_Rechnung_Schutzfrist-Claim.docx`.

---

### Cross-Navigation Breadcrumbs — Konsistenz-Pass

**Erfasst:** 2026-04-13
**Grund:** Jede Detailseite hat Breadcrumbs, aber die Ebenen-Tiefe variiert (Kandidat 2-stufig, Mandat 4-stufig, Assessment 4-stufig).
**Was fehlt:** Konsistenz-Review aller Breadcrumb-Definitionen nach Fertigstellung aller Detailseiten. Einheitliche Regel: max. 4 Ebenen, Stufen klickbar zurück.

**Betroffene Specs:** alle Schema-Dokumente § 3.

---

### Header-Snapshot-Bar — Einheitliche Slot-Anzahl?

**Erfasst:** 2026-04-13
**Grund:** Kandidat hat N Slots (variabel), Mandat hat 6–7, Account hat 6, Assessment hat 5.
**Frage:** Sollen wir eine einheitliche Max-Anzahl definieren (z.B. immer 6), oder variabel akzeptieren?

**Entscheidung ausstehend, Review-Thema.**

---

### Account-Detailseite — Neuer Tab "Projekte"

**Erfasst:** 2026-04-13
**Grund:** Projekt-Spec bringt neues Datenmodell. Account braucht Sicht auf alle Projekte an denen er beteiligt war (als Bauherr ODER via Firmen-Beteiligung).
**Was fehlt:** Account-Schema v0.1 → v0.2: neuer Tab zwischen Tab 6 Jobs & Vakanzen und Tab 7 Mandate (oder als eigener, z.B. Tab 7 Projekte, verschiebt alles nachfolgende).
**Inhalt des Tabs:**
- Liste aller `fact_projects` wo `bauherr_account_id = this.id` ODER `this.id IN fact_project_company_participations.account_id`
- Filter: Rolle (Bauherr / Architekt / TU / ...), Status, Zeitraum
- Klick → Projekt-Detailseite
- Cross-Link zu AM-Notizen (Tab 1 Sektion 6 im Projekt)

**Betroffene Specs:** `ARK_ACCOUNT_DETAILMASKE_SCHEMA_v0_2.md` → v0.2, Interactions v0.2 → v0.3.

---

### Kandidatenmaske — Werdegang/Briefing-Integration mit Projekt

**Erfasst:** 2026-04-13
**Grund:** Projekt-Spec PR-12 Hybrid-Autocomplete — Werdegang-Einträge sollen auf Projekt-DB verlinken.
**Was fehlt:** Kandidatenmaske-Spec-Update (Tab 2 Briefing + Tab 3 Werdegang):
- Autocomplete-Feld "Projekt" mit Fuzzy-Match gegen `fact_projects`
- Confidence-basierter Flow (≥85% Auto-Match, 50-84% Review, <50% Neues Projekt anlegen)
- Mini-Drawer "Neues Projekt anlegen" (Name, Bauherr, Zeitraum)
- Kurzübersicht im Werdegang mit Link zur Projekt-Detailseite
- Auto-Insert in `fact_project_candidate_participations` beim Verknüpfen

**Betroffene Specs:** `ARK_KANDIDATENMASKE_SCHEMA_v1_2.md` → v1.3, Interactions v1.2 → v1.3.

---

### Mandat + Job — Projekt-Verknüpfung (optional)

**Erfasst:** 2026-04-13
**Grund:** Mandate/Jobs können sich auf ein spezifisches Projekt beziehen (z.B. "Suche Bauleiter für Überbauung XY").
**Was fehlt:**
- `fact_mandate.linked_project_id` FK
- `fact_jobs.linked_project_id` FK
- UI: Dropdown in Mandat/Job Tab 1 Sektion "Verknüpfungen" mit Projekt-Autocomplete
- Im Projekt: Sektion "Verwandte Mandate" zeigt alle verknüpften Mandate

**Betroffene Specs:** Mandat-Schema v0.1 → v0.2, Job-Schema v0.1 → v0.2.

**Priorität:** P1 (nützlich, nicht kritisch).

---

### Mockup-HTMLs für alle neu erstellten Detailseiten

**Erfasst:** 2026-04-13
**Grund:** Mandat (6 Tabs), Account (13 Tabs), Assessment (5 Tabs) haben noch keine Mockup-HTMLs — nur Referenzen in den Schemas.
**Was fehlt:** Mockup-HTMLs in `raw/Ark_CRM_v2/` nach gleicher Methodik wie Kandidatenmaske v2 HTMLs.

**Priorität:** P1 nach Abschluss aller Schemas/Interactions.

---

## Workflow

1. Einzelne Detailseiten erstmal fertig bauen (Schema + Interactions v0.1/v0.2)
2. Am Ende: **Rückwärts** durch alle Detailseiten gehen (Projekte → Scraper → Firmengruppen → Jobs → Prozesse → Assessments → Mandate → Accounts → Kandidaten)
3. Pro Detailseite: diese Liste konsultieren + fehlende Cross-Refs ergänzen
4. Ergebnis: Version-Bumps (v0.2 → v0.3, v1.2 → v1.3 etc.)
5. Diese Liste als "Abgearbeitet" markieren pro Punkt

## Related

[[detailseiten-guideline]], [[detailseiten-inventar]]
