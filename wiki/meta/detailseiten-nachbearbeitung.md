---
title: "Detailseiten-Nachbearbeitungs-Notizen"
type: meta
created: 2026-04-13
updated: 2026-04-18
tags: [detailseiten, nachbearbeitung, todo, cross-reference]
---

# Detailseiten-Nachbearbeitungs-Notizen

Punkte, die erst bei der **Gesamtüberarbeitung am Schluss** (rückwärts durch alle Detailmasken) eingearbeitet werden. Ziel: Cross-References und aggregierte Sichten zwischen Detailseiten sauber verknüpfen, nachdem alle Einzel-Specs existieren.

## Zweck

Wenn wir alle Detailseiten einzeln bauen, entstehen natürlicherweise **Verknüpfungs-Lücken** — eine Detailseite referenziert eine andere, die zu dem Zeitpunkt noch nicht existiert oder noch anders strukturiert war. Nach der ersten Durchlaufsrunde (alle Detailseiten haben Schema + Interactions v0.1+) gehen wir systematisch rückwärts durch und schliessen diese Lücken.

---

## Offene Nachbearbeitungs-Punkte

### Account-Detailseite Tab 9 Schutzfristen — Gruppen-Scope (KRITISCH)

**Abgearbeitet 2026-04-18 via autorefine** — alle Sub-Punkte in `ARK_ACCOUNT_DETAILMASKE_INTERACTIONS_v0_3.md` + `ARK_MANDAT_DETAILMASKE_INTERACTIONS_v0_3.md` umgesetzt:

- Tab 9 zeigt `scope='group'` mit Label "🏛 Gruppen-Schutzfrist" (Account v0.3 L831, Info-Panel L843)
- Claim-Workflow Group-Level inkl. Rechnungs-Empfänger-Regel (einstellende Firma, nicht Holding) (Account v0.3 L892, L908)
- Bei Vorstellung: zwei `fact_protection_window`-Einträge (account+group) wenn `account.group_id IS NOT NULL` (Mandat v0.3 L703–715)
- Scraper-Match prüft beide Scopes (Mandat v0.3 L848)
- Datenmodell `fact_protection_window.scope` ENUM + `group_id` FK + CHECK-Constraint (L799–807)

**Erfasst:** 2026-04-13 · **Grund:** Entscheidung FG-10 (Firmengruppen-Schema), AGB-konform.

---

### Account-Detailseite Tab 8 (Assessments) — Credits-Übersicht

**Abgearbeitet 2026-04-18 via autorefine** — in beiden Layern implementiert + konsistent:

- **Interactions v0.3** L693–716: Zwei-Banner-Reihe (Teamrad + Credits-Typ-Breakdown), Total-Zeile, Filter-Chip "Typ (Multi-Select)", Tabelle-Spalte "Credits-Mix"
- **Schema v0.3** (`ARK_ACCOUNT_DETAILMASKE_SCHEMA_v0_3.md`) §12.1–12.4: Layout-Beschreibung, Spalte "Credits-Mix", §12.3 umbenannt zu "KPI-Banner" mit beiden Zeilen, Filter-Chip "Typ" dokumentiert
- **Bonus-Fix Interactions v0.3** §Status-Wechsel (L741–750): Stale Transition `completed → invoiced` entfernt, Order-Status auf 5 Grundlagen-konforme Werte angeglichen (offered / ordered / partially_used / fully_used / cancelled), Billing-Trigger korrekt auf `ordered` (Credits-Modell)

**Filename-Rename abgeschlossen 2026-04-18 (autorefine Run 16):** Git-mv v0_2 → v0_3 + 16 aktive Referenzen updated via `scripts/autorefine/rename-account-schema-refs.py`.

**Erfasst:** 2026-04-13 · **Grund:** Entscheidung 2026-04-13 — Credits-Modell beim Assessment.

---

### Kandidat-Assessment-Tab — Auftrags-Referenz in Versionen

**Abgearbeitet 2026-04-18 via autorefine** — Version-Navigation in allen Sub-Tabs zeigt Auftrags-Referenz:

- Schema v1.3 L67–84: Versionierungs-Label "Version N — via Auftrag AS-2026-XXX (Account, Assessment 'MDI Führungs-Check')"
- Schema v1.3 L82: Legacy-Fallback "Version N — Manuell erfasst / Legacy"
- Interactions v1.3 L202–222: Pfeil-Navigation inkl. Link `[→ Zum Assessment-Auftrag]`
- Interactions v1.3 T4-1 (L87): Version-Pill "v2 · 15.03.2026 · Auftrag AS-XXXX" + Button "Auftrag öffnen"

**Follow-up Phase 2:** Filter/Suche nach Auftrag (Dropdown-Variante neben Pfeilen, Volltext-Suche im Package-Name) — siehe Punkt unten.

**Erfasst:** 2026-04-13 · **Grund:** Assessment-Auftrags-Versionen tragen `assessment_order_id` FK.

---

### Kandidat-Assessment-Tab — Filter/Suche nach Auftrag (Phase 2)

**Abgearbeitet 2026-04-18 via autorefine (Run 19)** — Filter/Suche-Pattern in Kandidaten-Interactions v1.3 ergänzt:

- Dropdown + Suche-Panel neben Pfeil-Nav (Pill "▼ alle Versionen") mit Auftrag-Nummer + Datum + Package-Name + Account-Label
- 3 Filter-Optionen: Volltext-Suche (Fuzzy auf order_id/package/account), Account-Chip (Multi-Select), Zeitraum-Chip (Alle / Letzte 12 Mt / Jahr / Custom)
- Multi-Auftrag-Badge im Sub-Tab-Header: `[3 Versionen · 2 Aufträge · 2 Accounts]`
- Keyboard: `V` öffnet Dropdown, `←`/`→` bleibt Pfeil-Nav
- Server-seitig: bestehende API um Query-Params `q`, `account`, `date_from`, `date_to` erweitert (keine neue Endpoint)

**Erfasst:** 2026-04-18. **Priorität vorgezogen** da Pattern schnell spezifiziert werden konnte.

---

### Mandat-Detailseite Tab 1 Sektion 6b — Assessment-Details

**Abgearbeitet 2026-04-18 via autorefine** — Inline-Expand-Pattern spezifiziert:

- Schema v0.2 §Sektion 6b: Chevron-Spalte für Expand-Row, Expand-Inhalt pro Option-Typ (VI/VII/VIII/IX/X). Option-IX-Expand zeigt Credits-Summe aus `fact_assessment_order_credits`, Kandidat-Chips mit Einzelstatus aus `fact_candidate_assessment_version`, Link zu `/assessments/[id]`.
- Interactions v0.3 §"UI — Sektion 6b": Chevron-Toggle-Verhalten, Drawer-Default-Regel unverletzt (Inline-Expand = read-only Detail, Drawer via "Details"-Icon für Edit).

**Erfasst:** 2026-04-13.

---

### Mandat-Detailseite Tab 2 Longlist — Vorstellungs-Markierung UX

**Abgearbeitet 2026-04-18 via autorefine** — Drawer-Pattern spezifiziert (Drawer-Default-Regel CLAUDE.md):

- Interactions v0.3 TEIL 10 "Vorstellungs-Markierung UX-Pattern": Card-Menu → Drawer 540px mit Vorstellungs-Typ-Dropdown, datetime-local-Picker (Datum-Eingabe-Regel), Kanal-Chip bei verbal, Kontaktperson-Autocomplete, Notiz, Dokument-Upload. Save schreibt `fact_candidate_presentation` + History-Event.
- Bulk-Variante: Multi-Select Cards → Bulk-Drawer mit Kandidat-Checkbox-Liste.
- Korrektur-Flow: Edit-Modus mit Soft-Delete.

**Erfasst:** 2026-04-13.

---

### Account-Detailseite Tab 9 Schutzfristen — Claim-Rechnungs-Template

**Status 2026-04-18:** **Noch offen — Templates müssen von Peter manuell im Arkadium-Corporate-Design erstellt werden.**

Zu erstellen in `raw/General/`:
- `Vorlage_Rechnung_Mandat_Direkteinstellung-Claim.docx` (Fall X — Mandats-Direkteinstellung)
- `Vorlage_Rechnung_Erfolgsbasis-Direkteinstellung-Claim.docx` (Fall Y/Z — Staffel)

**Platzhalter-Contract:** `wiki/meta/claim-rechnung-template-spec.md` beschreibt alle `{{…}}`-Tokens, die in den finalen Templates vorhanden sein müssen, damit der Dok-Generator sie automatisch befüllen kann (Kopf, Empfänger, Sachverhalt, Honorar-Berechnung, Zahlungskonditionen).

**Verworfener Autorefine-Versuch (Run 15):** Claude generierte über ein Node-Script Skeleton-docx — das Layout entsprach nicht dem Arkadium-Design. Dateien + Script wieder entfernt. Erkenntnis: Corporate-Design-Templates brauchen Peter's manuelle Word-Arbeit (Logo, Farben, Font, Layout), nicht Auto-Generierung.

**Priorität:** P1 — wird beim ersten realen Claim-Fall dringend. Bis dahin UI-Placeholder in Claim-Drawer: *"[Rechnung wird nach Template-Erstellung verfügbar sein]"*.

**Erfasst:** 2026-04-13.

---

### Cross-Navigation Breadcrumbs — Konsistenz-Pass

**Abgearbeitet 2026-04-18 via autorefine** — Regel + Inventar in `wiki/meta/breadcrumbs-konsistenz.md`:

- Regel: Max 4 Ebenen, alle Stufen klickbar, Top-Level-Entities 2-stufig, Sub-Entities 4-stufig mit Parent-Context, Hubs funktional.
- Inventar: 9 Detailseiten-Breadcrumbs inventarisiert (Account/Kandidat/Projekt/Firmengruppe je 2-stufig; Mandat/Assessment/Job/Prozess je 4-stufig; Email/Kalender funktional).
- Konsistenz-Status: strukturell konform.

**Follow-up Phase 2 abgearbeitet 2026-04-18 (autorefine Run 18):** DE/EN-Sprachmix analysiert gegen Mockup-Baseline §16.10. Einzige echte Drift war Prozess-Spec-Pattern (Candidate-rooted EN statt Account-rooted DE per Mockup) — gefixt. "Jobs" bleibt (international-DE kanonisch).

**Erfasst:** 2026-04-13.

---

### Header-Snapshot-Bar — Einheitliche Slot-Anzahl?

**Abgearbeitet 2026-04-18 via autorefine** — **Peter-Entscheidung: Option B (variabel akzeptieren).**

Slot-Anzahl bleibt entity-spezifisch; keine Vereinheitlichung. Details: `wiki/meta/decision-draft-snapshot-bar-slots.md`.

**Erfasst:** 2026-04-13.

---

### Account-Detailseite — Neuer Tab "Projekte"

**Abgearbeitet 2026-04-18 via autorefine** — **Peter-Entscheidung: Variante C (bedingter Tab analog Firmengruppe).**

- Schema v0.2 §19 (neu): Layout · Filter-Chips (Rolle/Status/Zeitraum) · Tabelle mit Spalten Projekt/Bauherr/Rolle/Status/Zeitraum/Arkadium-Placements/BKP-Gewerk · Header-Quick-Action "🏗 Projekt verknüpfen" · Sichtbarkeit-Condition.
- Interactions v0.3 TEIL 14 (neu): SQL-Query-Logic (UNION Bauherr + Company-Participations), Row-Click-Drawer-Flow, "+ Neues Projekt anlegen"-Fallback, Cross-Nav zu Projekt-Detailseite §6, Edit-Logik read-mostly, Phase-1.5/2-Vormerkungen.
- TEIL 0 Tab-Struktur-Tabelle: zweite bedingt-Zeile für Projekte ergänzt; "13 fixe + 2 bedingt".

**Mockup-Integration abgeschlossen 2026-04-18 (autorefine Run 17):** `mockups/accounts.html` — neuer bedingter Tab `data-tab="15"` "🏗 Projekte" nach Firmengruppe-Tab, Tab-Panel `#tab-15` mit Info-Banner, 5-Card-KPI-Strip (Projekte total / Als Bauherr / Als Architekt-TU / Arkadium-Placements / Volumen gesamt), Filter-Chip-Row (Rolle × Zeitraum), 7-Zeilen-Projekt-Tabelle mit 8 Spalten (Projekt/Bauherr/Rolle/Status/Zeitraum/BKP-Gewerk/Placements/›), Header-Quick-Action "🏗 Projekt verknüpfen".

**Erfasst:** 2026-04-13.

---

### Kandidatenmaske — Werdegang/Briefing-Integration mit Projekt

**Abgearbeitet 2026-04-18 via autorefine** — bereits vollständig in Kandidaten-Specs v1.3 integriert:

- Schema v1.3 L13–14, L25–59: Hybrid-Autocomplete Tab 2 Briefing (Fuzzy-Match + Confidence-Schwellen ≥85/60-84/<60), Mini-Drawer "Neues Projekt anlegen" mit Pflichtfeldern, Werdegang-Projekt-FK pro Station.
- Interactions v1.3 L160–177, L200: Projekt-Autocomplete-Flow, Auto-Insert in `fact_project_candidate_participations`, Bidirektionaler BKP/SIA-Sync.
- Schema v1.3 L38, L139: `fact_candidate_werdegang.project_id` FK nullable.

**Erfasst:** 2026-04-13.

---

### Mandat + Job — Projekt-Verknüpfung (optional)

**Abgearbeitet 2026-04-18 via autorefine** — Schema-FK-Additions in beiden Spec-Dateien:

- Mandat Schema v0.2 §Sektion 1 Grunddaten: Feld "Verknüpftes Projekt" (`fact_mandate.linked_project_id` FK nullable) mit Autocomplete-Dropdown und Cross-Nav zu Projekt-Detailseite "Verwandte Mandate"-Sektion.
- Job Schema v0.1 §Sektion 2 Verknüpfungen: Feld "Verknüpftes Projekt" (`fact_jobs.linked_project_id` FK nullable) mit Use-Case-Beispiel "Bauleiter Überbauung XY".
- Grundlagen-Sync: `ARK_DATABASE_SCHEMA_v1_3.md` L63, L75 bereits `linked_project_id FK → fact_projects NULL` dokumentiert für Phase 1.5. Spec-Drift geschlossen.

**Priorität:** P1.

**Erfasst:** 2026-04-13.

---

### Mockup-HTMLs für alle neu erstellten Detailseiten

**Abgearbeitet 2026-04-18 via autorefine** — alle Mockup-HTMLs existieren in `mockups/`:

- `accounts.html` (323KB, 35 Tab-Markers — 13 Haupt-Tabs + Subtabs)
- `mandates.html` (138KB, 18 Tab-Markers — 6 Haupt-Tabs + Drawer-Tabs)
- `assessments.html` (80KB, 9 Tab-Markers — 5 Haupt-Tabs + Drawer-Tabs)
- Plus alle anderen Detailseiten (candidates, jobs, projects, processes, groups, email-kalender, scraper, admin, dashboard, dok-generator, reminders)

Mockups wurden zwischen 2026-04-13 (Punkt erfasst) und heute gebaut.

**Priorität:** P1 erledigt.

**Erfasst:** 2026-04-13.

---

## Workflow

1. Einzelne Detailseiten erstmal fertig bauen (Schema + Interactions v0.1/v0.2)
2. Am Ende: **Rückwärts** durch alle Detailseiten gehen (Projekte → Scraper → Firmengruppen → Jobs → Prozesse → Assessments → Mandate → Accounts → Kandidaten)
3. Pro Detailseite: diese Liste konsultieren + fehlende Cross-Refs ergänzen
4. Ergebnis: Version-Bumps (v0.2 → v0.3, v1.2 → v1.3 etc.)
5. Diese Liste als "Abgearbeitet" markieren pro Punkt

## Related

[[detailseiten-guideline]], [[detailseiten-inventar]]
