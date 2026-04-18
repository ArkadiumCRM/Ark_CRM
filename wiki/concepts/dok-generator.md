---
title: "Dok-Generator"
type: concept
created: 2026-04-17
updated: 2026-04-17
sources: ["ARK_DOK_GENERATOR_SCHEMA_v0_1.md", "ARK_DOK_GENERATOR_INTERACTIONS_v0_1.md", "mockups/dok-generator.html"]
tags: [dok-generator, operations, templates, workflow]
---

# Dok-Generator

Zentrales Tool zur Generierung aller Arkadium-Dokumente (Offerten, Rechnungen, CVs, Reports, Factsheets). Ersetzt verstreute CTAs in Entity-Detailmasken durch einen einheitlichen 5-Step-Workflow unter [[operations]] → `/operations/dok-generator`.

## Kernprinzipien

### 1 Template pro Dokument-Variante

Keine Parameter für strukturell unterschiedliche Varianten. Beispiele:
- **Du/Sie** = separate Templates (ganzer Text unterscheidet sich, nicht nur Anrede)
- **Mit/ohne Rabatt** (Best-Effort) = separate Templates
- **Mandat-Typ Target/Taskforce/Time** = 3 separate Mandat-Offerten-Templates

Parameter nur für kosmetische Varianten: `sprache` (de/en), `empfaenger_anrede` (Herr/Frau/Team), `rechnung_zahlungsfrist_tage` (14/30).

### Auto-Pull aus Entity-Vollansichten

Kein manuelles Abtippen. Backend löst `{{entity.feld}}`-Platzhalter live aus [[datenbank-schema]]:
- Kandidat-Docs (ARK CV, Abstract, Exposé): aus [[kandidat]]-Vollansicht
- Mandat-Docs (Offerte, Rechnungen, Mahnungen, Reports): aus [[mandat]]-Vollansicht
- Assessment-Docs (Offerte, Rechnung, Executive Report): aus [[diagnostik-assessment]]
- Best-Effort-Rechnungen: aus [[prozess]] mit Placement + [[honorar-berechnung]]
- Reportings: Aggregationen über `fact_mandate`/`fact_history`/`fact_process_core`

### Multi-Entity nur bei Exposé

Kandidat + Mandat-Kontext als 2-Entity-Kombination. Alle anderen Templates = 1 Entity.

### Bulk-Mode bei Rechnungs-/Mahnungs-Templates

N Entities auf einmal (z.B. 5 Erfolgsbasis-Rechnungen für 5 Placements gleichzeitig). Auto-Bulk-Detection via Regex `/^(rechnung|mahnung)_/`.

## Architektur

### 5-Step-Workflow

```
Template → Entity → Ausfüllen → Preview → Ablage/Delivery
```

| Step | State | UX |
|------|-------|-----|
| 1 | `currentTemplate` | Template-Grid (38 Cards, 7 Kategorien, Favoriten-Star) |
| 2 | `entityList[]` | Entity-Picker (9 Kinds, dynamisch gefiltert nach Template-Kinds) |
| 3 | Editor-Content + Params | WYSIWYG mit 260px Sidebar + A4-Canvas |
| 4 | — | Read-only Preview mit Live-Zoom |
| 5 | `deliveryMode` | Ablage-Ziel + Delivery-Optionen + History-Preview-Drawer |

### Template-Katalog (38 + 1 ausstehend)

Siehe [[stammdaten]] §56 `dim_document_templates`. 7 Kategorien:
- **Mandat-Offerten** (4): Target · Taskforce · Time (ausstehend) · Auftragserteilung Optionale Stage
- **Mandat-Rechnungen** (10): Teilzahlung 1/2/3 × Du/Sie · Opt. Stage · Kündigung · Mahnung × Du/Sie
- **Best-Effort** (8): Rechnung/Mahnung × mit/ohne Rabatt × Du/Sie
- **Assessment** (3): Offerte · Rechnung · [[executive-report]] (NEU)
- **Rückerstattung** (1): Rechnung Rückerstattung
- **Kandidat** (5): ARK CV · Abstract · Exposé · Referenzauskunft · Referral
- **Reportings** (7): AM · CM · Monatsreporting CM · Hunt · Team Leader · Mandat-Report · Factsheet

### Deep-Link-Integration

Entity-CTAs in Detailmasken öffnen Dok-Generator vorbefüllt:
```
/operations/dok-generator?template=mandat_offerte_target&entity=mandate:uuid
```

Bestehende Mockups migriert (2026-04-17):
- `mandates.html` → 📄 Mandat-Report
- `assessments.html` Tab 4 → 📄 Offerte generieren
- `candidates.html` Tab 9 → Redirect-Banner

Weitere Deep-Links Phase 1.5: Accounts (Factsheet), Mandate (Rechnung-Stage-N), Prozesse (Best-Effort-Rechnung).

### Editor-Pattern

Generalisiert aus [[kandidatenmaske-schema]] Tab 9:
- Sidebar 260px: Sektionen-Liste (drag&drop), Parameter-Panel, Anonymisierungs-Panel (nur `expose`)
- Main: Toolbar (Bold/Italic/H1-H2/Listen/Zoom) + A4-Canvas (210mm, ARKADIUM-Branding navy/gold)
- Platzhalter `{{mandat.honorar_pauschale}}` → gold-highlighted `<span class="ph">` → live via Backend-Resolve aufgelöst
- Page-Break-Visualisierung bei Multi-Seiten (z.B. Executive Report)

### Success-Feedback

Nach „Generieren & Versenden":
- Success-Drawer (540px, Gold-Akzent) mit Doc-ID · Template · Entity · Ablage-Pfad · Timestamp
- Email-Status (bei `save_and_email`)
- History-Event-Preview
- 4 Nachfolge-Aktionen: Zum Entity · Weiteres Dokument · PDF Download · Email-Kopie

## Datenbank

- **Neue Tabelle** [[datenbank-schema]] §14.2: `dim_document_templates`
- **Erweiterung** [[datenbank-schema]] §14: `fact_documents` um `generated_from_template_id`, `generated_by_doc_gen`, `params_jsonb`, `entity_refs_jsonb`, `delivery_mode`, `email_recipient_contact_id`
- **Enum-Erweiterung** `document_label`: +12 Labels (Mandat-Offerte, Mandat-Rechnung, Executive-Report etc.)

## Backend-Endpoints

Siehe [[backend-architektur]] §L. 9 neue Endpoints:
- Registry: `GET /api/v1/document-templates`, `:key`
- Master-Generate: `POST /api/v1/documents/generate`
- Resolve: `POST /api/v1/documents/resolve-placeholders` (Live-Canvas)
- Regenerate: `POST /api/v1/documents/:id/regenerate`
- Email: `POST /api/v1/documents/:id/email`
- Sidebar: `GET /api/v1/document-generator/recent`, `/drafts`

Bestehende punktuelle Endpoints (`POST /api/v1/assessments/:id/generate-quote`, `POST /api/v1/ai/generate-dossier`) werden backward-compatible Wrapper über den Master-Endpoint.

## Kandidat-Tab-9 Migration

Bestehender Tab 9 „Dok-Generator" ([[kandidat]]-Detail) wird in 3 Phasen abgelöst:
- **Phase 1** (aktuell): Redirect-Banner oben im Tab, Deep-Link zum globalen Tool
- **Phase 2**: Tab-Layout wird zu Inline-Shortcut
- **Phase 3** (React-Port): Tab entfernt, nur noch globaler Dok-Generator

## Permissions / RBAC

| Rolle | Template-Zugriff |
|-------|------------------|
| AM | Mandat-Offerten/Rechnungen · Assessment · Reportings · Factsheet |
| CM | Kandidat-Docs · Executive Report · CM-Reporting |
| Backoffice | Mandat/Assessment-Rechnungen · Mahnungen |
| Admin | Alles + Template-Admin-UI (Phase 2) |

Details: [[berechtigungen]] + `ARK_DOK_GENERATOR_INTERACTIONS_v0_1.md` TEIL 12.

## Phase-Scope

**Phase 1 (Mockup + Initial Build):**
- 38 Templates aktiv, 1 ausstehend (`mandat_offerte_time`)
- 5 Templates mit vollem Canvas-Content (Mandat-Offerte Target, Rechnung Mandat T1, Assessment-Offerte, ARK CV, Executive Report)
- Kein Admin-UI
- Keine Drafts
- Nur Deutsch

**Phase 1.5:**
- Draft-Auto-Save
- Multi-Entity-Bulk-Generation (N-Rechnungen-auf-einmal UI)
- Template-Favoriten pro User persistent
- DOCX-Parser für neue Template-Aufnahme

**Phase 2:**
- Template-Admin-UI (CRUD `dim_document_templates`)
- EN-Sprach-Support via LLM
- Template-Version-Management (Semver + Rollback)
- Collaborative Editing

## Related

- [[stammdaten]] §56 — Template-Katalog
- [[datenbank-schema]] §14 — `fact_documents` + `dim_document_templates`
- [[backend-architektur]] §L — Endpoints
- [[executive-report]] — Arkadium-Assessment-Zusammenfassung
- [[template-versionierung]] — Phase 2 Semver-Pattern
- [[detailseiten-guideline]]
- Mockup: `mockups/dok-generator.html` (1'321 Zeilen)
- Specs: `ARK_DOK_GENERATOR_SCHEMA_v0_1.md` + `INTERACTIONS_v0_1.md`
