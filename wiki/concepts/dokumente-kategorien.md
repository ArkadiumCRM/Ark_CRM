---
title: "Dokumente-Kategorien-Schema (Personal · Commercial · Group · Job · Projekt)"
type: concept
created: 2026-04-16
updated: 2026-04-16
tags: [documents, categories, schema, ui-patterns]
---

# Dokumente-Kategorien-Schema

## Fünf Profile, fünf Kategorie-Sätze

Das CRM speichert Dokumente an sechs Entity-Typen: **Kandidat**, **Account**, **Mandat**, **Firmengruppe**, **Job**, **Projekt**. Die Kategorien unterscheiden sich semantisch nach *Personal* vs. *Commercial* vs. *Group* vs. *Job* vs. *Projekt* — das ist bewusst, nicht inkonsistent.

## 1. Personal-Profile (Kandidat)

Kandidaten-Dokumente sind **personenbezogen** — Lebenslauf, Zeugnisse, Referenzen. 11 Kategorien:

| Key | Label | Beschreibung |
|---|---|---|
| `original-cv` | Original CV | Vom Kandidaten geliefertes CV |
| `arbeitszeugnis` | Arbeitszeugnisse | Ein Dokument pro Station |
| `diplom` | Diplome | Hochschulabschlüsse, Weiterbildungen |
| `projektliste` | Projektliste | Referenzprojekte-Übersicht |
| `arbeitsvertrag` | Arbeitsvertrag | Vertraulich, nur AM + Zuständiger |
| `ark-cv` | ARK CV | Generiert via Dok-Generator Tab 9 |
| `abstract` | Abstract | Generiert via Dok-Generator Tab 9 |
| `expose` | Exposé | Generiert via Dok-Generator Tab 9 (anonymisiert) |
| `assessment` | Assessment | ASSESS 5.0, Scheelen, TriMetrix, RELIEF |
| `referenz` | Referenz | Letters, Protokolle von Ref-Gesprächen |
| `sonstiges` | Sonstiges | Briefing-Protokolle, Notizen |

**Scope**: Dokumente folgen dem Kandidaten über alle Prozesse hinweg. Nicht mandat-spezifisch.

**Verwendet in**: `mockups/candidates.html` Tab 8 Dokumente (Chip-Filter + Upload-Drawer).

## 2. Commercial-Profile (Account · Mandat)

Account- und Mandat-Dokumente sind **geschäftsbezogen** — Offerten, Verträge, Rechnungen. 6 Kategorien:

| Key | Label | Beschreibung |
|---|---|---|
| `offerte-vertrag` | Offerten & Verträge | Mandats-Offerten, signierte Verträge, Assessment-Orders |
| `rechnung` | Rechnungen | Stage-Rechnungen, Mahnungen, Finalrechnung |
| `stellenbriefing` | Stellenbriefing | Briefing-Doc mit dem Kunden über eine Stelle |
| `assessment` | Assessment-Order | Order-Dokumente (nicht Reports — die sind in Kandidat) |
| `scraper` | Scraper-Beleg | Evidenz für Schutzfrist-Verletzung (Screenshots) |
| `sonstiges` | Sonstiges | KPI-Reports, Workshop-Protokolle |

**Verwendet in**:
- `mockups/accounts.html` Tab 12 Dokumente (Scope: alle Mandate eines Accounts aggregiert)
- `mockups/mandates.html` Tab 6 Dokumente (Scope: nur dieses eine Mandat)

**Counts-Skalierung**:
- Account aggregiert über alle Mandate → grössere Zahlen (z.B. „77 Alle, 38 Rechnungen")
- Mandat isoliert → kleinere Zahlen (z.B. „11 Alle, 3 Rechnungen für 3 Stages")

## 3. Group-Profile (Firmengruppe)

Firmengruppen-Dokumente sind **gruppenweit-strategisch** — Rahmenverträge, Holding-Unterlagen. 6 Kategorien:

| Key | Label | Beschreibung |
|---|---|---|
| `rahmenvertrag` | Rahmenvertrag | Konzern-weiter Vermittlungsvertrag mit Sonder-Konditionen |
| `master-nda` | Master-NDA | Gruppen-weite Geheimhaltung (auch Subset-Variante pro Gesellschaft) |
| `konzern-agb` | Konzern-AGB | Abweichende AGB auf Gruppen-Ebene |
| `gruppen-praesentation` | Gruppen-Präsentation | Strategische Unterlagen, Konzern-Strategie, DACH-Expansion |
| `holdings-geschaeftsbericht` | Holdings-Geschäftsbericht | Jährliche PDFs der Holding |
| `sonstiges` | Sonstiges | Gruppen-KPI-Reports, Organigramm |

**Gültigkeitsbereich** (zusätzliches Feld): „🏛 Ganze Gruppe" (Default) vs. „Subset: ausgewählte Gesellschaften".

**Verwendet in**: `mockups/groups.html` Tab 5 Dokumente.

## 4. Job-Profile (Job)

Job-Dokumente sind **vakanz-bezogen** — Stellenausschreibungen, Briefings, Matching-Exports. 5 Kategorien:

| Key | Label | Beschreibung |
|---|---|---|
| `stellenausschreibung` | Stellenausschreibung | Generierte Ausschreibung (Doc-Generator) · PDF · mehrsprachig DE/FR/IT/EN · versioniert |
| `briefing` | Briefing | Stellenbriefing-Doc (Kunden-Briefing, 9 Sektionen, versioniert) — auch Kultur-/Account-Briefings wenn job-relevant |
| `matching-export` | Matching-Export | Snapshots aus Tab 2 (CSV/XLSX mit 7 Sub-Scores, Longlist-PDF Top-N anonymisiert) |
| `organigramm` | Organigramm-Position | Snapshot aus Account Tab 8 — wo sitzt die Rolle im Konzern-Org? |
| `sonstiges` | Sonstiges | Interview-Leitfaden, Vergütungs-Benchmark, Anforderungsprofil-Drafts, Arbeitgeber-Portrait |

**Scope**: Dokumente sind job-spezifisch. Kandidat-Dossiers (ARK-CV/Exposé) liegen am Kandidaten, Mandat-Kommerz-Docs (Offerte/Rechnung) am Mandat. Nicht dupliziert.

**Spezial-Features**:
- **Stellenausschreibung-Generator** (Banner oben in Tab 5): Sprache-Dropdown (DE/FR/IT/EN), Logo-Toggle, Verdeckt-Toggle (ohne AG-Name), generiert PDF + legt als `v<n>`-Version in Kategorie „Stellenausschreibung" ab.
- **Matching-Export** wird jedes Mal beim Tab-2-Recompute als Snapshot-Zeile angelegt (read-only, historisch nachvollziehbar).
- **Versionierung**: Stellenausschreibung und Briefing sind versioniert. Historische Versionen werden mit `opacity:.7` + Chip „historisch" markiert, aktuelle Version als Standard-Row.

**Verwendet in**: `mockups/jobs.html` Tab 5 Dokumente.

## 5. Projekt-Profile (Projekt / Bauprojekt)

Projekt-Dokumente sind **bauprojekt-bezogen** — Projekt-Beschreibungen, Pressemeldungen, Pitch-Unterlagen. 6 Kategorien:

| Key | Label | Beschreibung |
|---|---|---|
| `projekt-beschreibung` | Projekt-Beschreibung | Offizielle Unterlagen vom Bauherr · Anforderungsprofile · intern-Drafts |
| `pressemeldungen` | Pressemeldungen | NZZ / Hochparterre / TEC21 / Baublatt-Artikel (auto-extrahiert via Scraper möglich) |
| `baublatt-simap` | Baublatt / simap | Automatisierte Extracts aus Scraper oder manuell erfasste Ausschreibungs-Publikationen |
| `pitch-unterlagen` | Pitch-Unterlagen | Arkadium-eigene Präsentationen · Projekt-Report-Exports (extern/intern) · für Folgemandat-Akquise |
| `referenz-schreiben` | Referenz-Schreiben | Kunden-Referenzen zum Projekt · positive Zeugnisse für Arkadium-Leistung |
| `sonstiges` | Sonstiges | BKP-Volumina-Kalkulationen, Interview-Leitfäden, Sonder-Dokumente |

**Scope**: Projekt-spezifisch. **Explizit NICHT hier**: AM-Notizen (→ Tab 1 §6 `fact_account_project_notes`) · Kandidat-Dossiers (→ Kandidatenmaske) · Mandats-Kommerz-Docs (Offerte/Rechnung, → Mandatsmaske).

**Spezial-Features**:
- **AI-Auto-Enrichment** bei Upload: Kategorie-Vorschlag + Datum-Extraktion + PDF-Text-Indexing für Matching-Suche
- **Quellen-Tagging**: 📝 Manuell · 🤖 AI-auto-kategorisiert · 🕸 Scraper · 📧 Kunden-Email · 📄 Doc-Generator
- **Projekt-Report-Generator** (Quick-Action im Header) legt PDF automatisch in Kategorie „Pitch-Unterlagen" ab

**Verwendet in**: `mockups/projects.html` Tab 5 Dokumente.

## Warum nicht vereinheitlichen?

Die fünf Profile könnten technisch in EIN gemeinsames 33-Kategorien-Schema gelegt werden, aber:

1. **Semantik**: „Arbeitsvertrag" auf einem Account macht keinen Sinn (Account ≠ Person) · „Stellenausschreibung" auf einem Kandidaten noch weniger · „Baublatt-Extract" passt nur zu Bauprojekten
2. **UX**: Ein Kandidaten-Upload-Drawer mit „Rechnung" als Option verwirrt User
3. **Audit-Trail**: Personal-Docs (vertraulich, EU DSGVO) vs. Commercial-Docs (standard Retention) vs. Job-Docs (offen, teilweise publiziert) vs. Projekt-Docs (hybrid, teils öffentlich publiziert via Portal) haben unterschiedliche Compliance-Regeln

**Entscheidung**: 5 Profile bleiben getrennt, `sonstiges` ist der einzige geteilte Key über alle Profile.

## Implementierungs-Convention

```html
<!-- Chip-Filter (Tab-Body) -->
<div class="chip-group">
  <div class="chip-tab active" onclick="filterDocCat(this,'all')">Alle <span class="count">N</span></div>
  <div class="chip-tab" onclick="filterDocCat(this,'<key>')">Label <span class="count">n</span></div>
  …
</div>

<!-- Upload-Drawer Select -->
<select id="uploadCat" required>
  <option value="">— wählen —</option>
  <option value="<key>">Label</option>
  …
</select>

<!-- Row markup -->
<tr data-cat="<key>">…</tr>
```

Chip-Filter-Keys, Upload-Drawer-Optionen und Row-`data-cat`-Werte **müssen identisch** sein. Sonst greift `filterDocCat()` nicht.

## Shared Funktion

`filterDocCat(chipEl, cat)` in `mockups/_shared/layout.js` — target `#doc-view-list tbody tr[data-cat]`, generisch für alle Profile.

## Verwandte Seiten

- [[kandidat]] · [[accounts]] · [[mandate]]
- [[dokument-templates]] — Physische Templates (ARK CV, Abstract, Exposé)
- [[anonymisierung-schutzfrist]] — Für Personal-Profile Compliance
