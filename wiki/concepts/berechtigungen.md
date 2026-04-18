---
title: "Berechtigungen"
type: concept
created: 2026-04-08
updated: 2026-04-08
sources: ["ARK_BACKEND_ARCHITECTURE_v2_4.md", "ARK_FRONTEND_FREEZE_v1_9.md"]
tags: [concept, rbac, permissions, security]
---

# Berechtigungen

RBAC (Role-Based Access Control) mit Multi-Role-Support und 4 Permission Levels.

## Rollen

| DB-Key | Anzeige | Kürzel | Beschreibung |
|--------|---------|--------|-------------|
| `Admin` | Admin | Admin | Systemadministration, Benutzerverwaltung |
| `Candidate_Manager` | Candidate Manager | CM | Kandidatenbetreuung, Briefings, GO-Prozess |
| `Account_Manager` | Account Manager | AM | Kundenbetreuung, Mandatsakquise |
| `Researcher` | Research Analyst | RA | Longlist-Recherche, Erstansprache |
| `Head_of` | Head of Department | HoD | Spartenleitung, Eskalation |
| `Backoffice` | Backoffice | BO | Administration, Assessment-Management |
| `Assessment_Manager` | Assessment Manager | — | Assessment-Verwaltung |
| `ReadOnly` | Read Only | RO | Nur Leserechte |

**Multi-Role:** Ein User kann mehrere Rollen haben via `bridge_mitarbeiter_roles`. Enforcement via `requireAnyRole()`.

> [!warning] Deprecated
> `dim_mitarbeiter.rolle_type` ist deprecated. Neue Wahrheit: `dim_roles` + `bridge_mitarbeiter_roles`.

Siehe [[namenskonventionen]] für einheitliche Benennung.

## 4 Permission Levels (Frontend)

### 1. Page Guard
Edge Middleware + Client Layout. Unauthorized → /login oder 403.

### 2. Section Guard
Ganze Sektionen versteckt wenn keine Permission. Kein leerer Container, kein Layout Shift.

### 3. Field Guard (PermissionGate)
Per-Feld via `resolveFieldRenderState()`:

| State | Darstellung |
|-------|-------------|
| NICHT_VORHANDEN | Dash (—) |
| KEINE_PERMISSION | Punkte (•••) + Lock Icon |
| MASKIERT | Teilwert (z.B. "079 ***") |
| READ_ONLY | Normal, nicht editierbar |
| NICHT_GELADEN | Skeleton |

### 4. Action Guard
Buttons disabled mit erklärendem Tooltip, oder komplett versteckt.

## Backend Contract: `_fieldStates`

Jede API-Response enthält `_fieldStates` — die einzige Wahrheit ob `null` = "keine Daten" vs. "keine Berechtigung".

```json
{
  "salary": null,
  "_fieldStates": {
    "salary": "KEINE_PERMISSION"
  }
}
```

## Field-Level Filtering

`filterFieldsByRole()` — mandatory auf jeder Response-Serialisierung. Sensitive Felder (Gehalt, AI Red Flags, Fee-Beträge) nach Rolle eingeschränkt.

Beispiel: RA sieht keine Gehaltsdaten, BO kann keine Stages ändern.

## Feature Flags vs. Permissions

| Mechanismus | Steuert | Komponente | Effekt |
|-------------|---------|------------|--------|
| Feature Flag | VERFÜGBARKEIT | `FeatureFlagGate` | Feature komplett unsichtbar |
| Permission | ZUGANG | `PermissionGate` | Lock Icon, Disabled, Tooltip |

**Nie gemischt.** Unterschiedliche Komponenten.

## Related

- [[backend-architektur]] — Middleware-Stack, Auth
- [[frontend-architektur]] — PermissionGate, FieldStates
- [[kandidat]] — Feld-Sichtbarkeit pro Rolle
