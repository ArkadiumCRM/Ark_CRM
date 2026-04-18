---
description: Preload ARK Grundlagen + Meta (~225k tokens) for lookup-heavy sessions. Files in ASC edit-frequency order for cache-stability.
---

# ARK Prime — Session Reference Layer

Lade die stabile Referenz-Schicht für lookup-heavy Sessions. Reihenfolge ist nach Edit-Frequenz sortiert (stabil zuerst) damit Prompt-Cache nach einem Grundlagen-Edit nur Trailing-Blocks invalidiert.

## Stable Core

@CLAUDE.md

## Stammdaten & Changelog (rarely edited)

@raw/Ark_CRM_v2/ARK_STAMMDATEN_EXPORT_v1_3.md

@raw/Ark_CRM_v2/ARK_GESAMTSYSTEM_UEBERSICHT_v1_3.md

## Wiki-Meta (sync-rules + index)

@wiki/meta/spec-sync-regel.md

@wiki/index.md

## Schema & Backend (occasionally edited)

@raw/Ark_CRM_v2/ARK_DATABASE_SCHEMA_v1_3.md

@raw/Ark_CRM_v2/ARK_BACKEND_ARCHITECTURE_v2_5.md

## Frontend-Freeze (most edited, placed last)

@raw/Ark_CRM_v2/ARK_FRONTEND_FREEZE_v1_10.md

## Grundlagen-Changelog (pending sync-check)

@wiki/meta/grundlagen-changelog.md

---

## Prime-Check

Schritt 1 — Bestätige Prime mit kompakter Tabelle:

| File | Version | ~Tokens | Zuletzt erwähnt (falls erkennbar) |
|------|---------|---------|-----------------------------------|

Schritt 2 — **Changelog-Review**:

Parse `grundlagen-changelog.md` oben. Zähle Einträge mit `Status: unresolved`.

- **Wenn 0 unresolved**: Zeile "Changelog: 0 offen. ✓"
- **Wenn 1+ unresolved**: Tabelle ausgeben:

| # | Datum | File | Session | Sync-Check |
|---|-------|------|---------|------------|

Danach pro Eintrag fragen (einer nach dem anderen, kompakt):

```
Eintrag 1: <File> @ <Datum>
  → In Specs/Mockups nachgezogen?
    (a) ja, alles resolved — Status auf 'resolved' setzen
    (b) teilweise — Status auf 'in-progress', fehlende Specs in Resolved-In notieren
    (c) nein, noch pending — bleibt unresolved
    (d) skippen — diese Session nicht behandeln
```

User-Antwort (a/b/c/d) → wenn a oder b: Edit-Tool auf `grundlagen-changelog.md` mit Status-Update und Timestamp-Notiz (`- **Resolved:** YYYY-MM-DD HH:MM`).

Schritt 3 — Abschluss:

Eine Zeile: `Ready. Kontext-Budget: <verbleibend>/1M. Changelog: <resolved>/<total> resolved this session. Next?`
