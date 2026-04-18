---
title: "Template-Versionierung"
type: concept
created: 2026-04-17
updated: 2026-04-17
sources: ["ARK_DOK_GENERATOR_SCHEMA_v0_1.md §15", "ARK_DOK_GENERATOR_INTERACTIONS_v0_1.md TEIL 14"]
tags: [dok-generator, templates, versionierung, phase-2]
---

# Template-Versionierung

**Status:** Phase 2 — aktuell nicht implementiert. Dieses Dokument beschreibt das Zielbild für Semver-basierte Template-Versionen im [[dok-generator]].

## Problem

Im Launch-Zustand (Phase 1) sind Templates System-seeded mit `dim_document_templates.source_docx_version int DEFAULT 1`. Wenn ein Admin ein Template inhaltlich ändert (z.B. neue Klausel in Mandats-AGB, neue MwSt-Zeile), passiert dies **in-place** — bestehende generierte Dokumente (`fact_documents`) verlieren den Bezug zum damaligen Template-Stand.

Das ist problematisch wenn:
- Eine 2 Jahre alte Mandats-Offerte regeneriert werden soll (alte Klauseln müssen erhalten bleiben)
- Audit-Kontext gefordert: welche Template-Version wurde bei Generierung verwendet
- Rollback auf früheres Template nach fehlerhafter Änderung

## Zielbild (Phase 2)

### Semver pro Template

Jede Template-Änderung bekommt eine neue Version nach Semantic Versioning:

- **Major (X.0.0):** Inkompatible Änderung (neue Platzhalter, entfernte Sektionen, neue Pflicht-Parameter) → alte Dokumente nicht mehr regenerierbar ohne Migration
- **Minor (X.Y.0):** Neue optionale Sektion, neue optionale Platzhalter → alte Dokumente regenerierbar
- **Patch (X.Y.Z):** Textkorrektur, Layout-Fix, Rechtschreibung → alte Dokumente vollautomatisch regenerierbar

### Datenmodell-Erweiterung

```sql
-- Phase 2 Ergänzungen zu dim_document_templates
dim_document_templates
  + version_semver text DEFAULT '1.0.0'
  + version_history jsonb      -- [{ version: '1.0.0', changed_at, changed_by, changelog }, ...]
  + supersedes_template_id uuid FK NULL   -- bei Major-Bump: neuer Template-Key + Referenz auf alten

-- fact_documents bekommt bereits in v1 source_docx_version
-- Phase 2: zusätzlich Link zur konkreten Template-Version
fact_documents
  + generated_from_template_version text   -- z.B. '2.3.1'
```

### Admin-UI (Phase 2)

`/operations/dok-generator/admin` (Admin-only):
- Template-Editor mit Markdown + Platzhalter-Support
- Preview-Modus
- Version-Bump-Buttons (Major/Minor/Patch) mit Pflicht-Changelog
- Diff-Viewer zwischen Versionen
- Rollback zu früherer Version
- Test-Render gegen Dummy-Entity

### Regenerate-Flow

Bestehende `POST /api/v1/documents/:id/regenerate` wird erweitert:

```
POST /api/v1/documents/:id/regenerate
  body:
    target_template_version?: '2.3.1'  // Default: aktuelle Version
    params_overrides?: {...}
  response:
    { document_id, pdf_signed_url, version_used }
```

**Regeln:**
- Default: Regeneration nutzt **damalige Template-Version** (aus `fact_documents.generated_from_template_version`)
- Explizit angeforderte neue Version: Preview warnt bei Major-Diff ("Kann zu anderen Ergebnissen führen — bitte prüfen")
- Migration-Pfad: `POST /api/v1/document-templates/:key/migrate-documents?from_version=1.x.x&to_version=2.0.0` (Admin-only Bulk-Operation)

### Versions-Anzeige im Dok-Generator-UI

Step 1 Template-Card zeigt Badge mit aktueller Version. Tooltip mit Changelog-Excerpt.
Step 4 Preview-Canvas: Footer-Hinweis "Generiert mit Template-Version 2.3.1".
Success-Drawer: Version in Doc-Details.

## Migration-Strategien bei Major-Bump

### Soft-Break (Default)

- Alter Template-Key bleibt aktiv (`is_active=true`) bis alle Dokumente migriert
- Neue Version bekommt separaten Key (`mandat_offerte_target_v2`) oder gleichen Key mit neuer Major-Version
- User wählt beim Generate explizit Version

### Hard-Break

- Alter Template-Key wird deaktiviert (`is_active=false`)
- Bestehende Dokumente bleiben als PDF, aber nicht mehr regenerierbar
- Neue Dokumente zwangsweise auf neuer Version

### Deprecation-Warning

3 Monate vor Hard-Break: Banner in Template-Admin + Notification an Admin.

## Konflikt mit `document_label`-Enum

`document_label` ist enum auf `fact_documents` — bei Template-Key-Umbenennung bleibt `document_label` konstant (z.B. `'Mandat-Offerte'` unabhängig von `mandat_offerte_target_v1` vs `_v2`). Template-Version und Label sind orthogonal.

## Auditing

Alle Template-Version-Änderungen werden in `fact_audit_log` geloggt:
- `template_version_bumped` (mit old/new version + changelog)
- `template_rollback` (mit Ziel-Version + Begründung)
- `template_deactivated` / `_activated`

## Phase-Scope

**Phase 1 (aktuell):**
- Single-Version pro Template (`source_docx_version int DEFAULT 1`)
- Kein Admin-UI
- Template-Änderungen via SQL-Script oder direkt in DOCX-Blob
- Kein Rollback-Mechanismus
- Regenerate nutzt aktuelle Version

**Phase 2 (geplant):**
- Semver-Versionen
- Admin-UI mit Diff/Rollback
- Migration-Bulk-Operation
- Deprecation-Warnings

**Phase 3 (optional):**
- Collaborative Template-Editing
- Template-Marketplace (Share zwischen Tenants)
- AI-Assist für Template-Variationen

## Related

- [[dok-generator]] — Hauptkonzept
- `ARK_DOK_GENERATOR_SCHEMA_v0_1.md` §15 — Offene Spec-Punkte
- `ARK_DOK_GENERATOR_INTERACTIONS_v0_1.md` TEIL 14 — Phase 2 Vormerkliste
- [[datenbank-schema]] §14.2 — Tabelle `dim_document_templates`
- [[audit-log-retention]] — Audit-Log-Policy
