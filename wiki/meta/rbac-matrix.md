---
title: "RBAC-Matrix"
type: meta
created: 2026-04-14
updated: 2026-04-14
sources: ["specs/ARK_MANDAT_DETAILMASKE_SCHEMA_v0_2.md", "specs/ARK_ACCOUNT_DETAILMASKE_SCHEMA_v0_3.md", "specs/ARK_KANDIDATENMASKE_SCHEMA_v1_3.md", "ARK_BACKEND_ARCHITECTURE_v2_5.md"]
tags: [rbac, berechtigungen, rollen, matrix]
---

# RBAC-Matrix

Single-Source-of-Truth für Rollen-basierte Berechtigungen. Ersetzt verstreute RBAC-Tabellen in den Detailseiten-Specs (die weiterhin aktionsspezifisch bleiben). Bei Widerspruch: diese Matrix > Spec-RBAC-Tabellen.

## Rollen (5-Level)

| Rolle | Beschreibung |
|-------|--------------|
| **AM (Owner)** | Account Manager, der die Entity "besitzt" (Mandat-AM, Account-AM) |
| **AM (andere)** | Anderer AM — Read, in Ausnahmen Stellvertretung |
| **CM** | Candidate Manager — Prozess-/Interview-Fokus |
| **Researcher** | Longlist-Aufbau, Durchcall |
| **Admin** | System-Weit Read + Freigaben (ersetzt frühere "Founder"-Rolle) |
| **Backoffice** | Billing, Rechnungswesen |

## Globale Regeln

- **Admin-Override:** Admins können in Ausnahmefällen jede Aktion ausführen (Audit-Log zwingend).
- **Read-Default:** Alle authentifizierten User lesen alle Entities, ausser explizit eingeschränkt.
- **Audit-Pflicht:** Jede schreibende Aktion → `fact_audit_log` Eintrag mit `actor_user_id`, `actor_role`, `action`, `target_entity`, `before`, `after`.

## Matrix nach Entity

### Mandat

| Aktion | AM-Owner | AM-andere | Researcher | CM | Admin | Backoffice |
|--------|----------|-----------|------------|----|----|------------|
| Lesen | ✅ | ✅ | ✅ | ✅ | ✅ | Billing+Doc |
| Übersicht editieren | ✅ | ⚠ | ❌ | ❌ | ✅ | ❌ |
| Longlist editieren | ✅ | ⚠ | ✅ | ❌ | ✅ | ❌ |
| Option buchen | ✅ | ❌ | ❌ | ❌ | ✅ | ❌ |
| **Mandat kündigen** | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Billing-Rechnung | ✅ | ❌ | ❌ | ❌ | ✅ | ✅ |
| Als bezahlt markieren | ⚠ | ❌ | ❌ | ❌ | ✅ | ✅ |

**Hinweis Kündigung:** Per Entscheidung 2026-04-14 #4 — **AM alleine**, kein Admin-Gate.

### Account

| Aktion | AM-Owner | AM-andere | CM | Admin | Backoffice |
|--------|----------|-----------|----|----|------------|
| Stammdaten editieren | ✅ | ⚠ | ❌ | ✅ | ❌ |
| Kontakte CRUD | ✅ | ⚠ | ✅ | ✅ | ❌ |
| Schutzfrist Info-Request | ✅ | ❌ | ❌ | ✅ | ❌ |
| **Schutzfrist-Claim** | ✅ | ❌ | ❌ | ✅ | ❌ |

### Kandidat

| Aktion | AM | CM (Owner) | Researcher | Admin |
|--------|----|-----------|------------|----|
| Stammdaten editieren | ⚠ | ✅ | ✅ | ✅ |
| Assessment beauftragen | ⚠ | ✅ | ❌ | ✅ |
| Prozess starten | ✅ | ✅ | ❌ | ✅ |
| Direkteinstellung loggen | ✅ | ✅ | ❌ | ✅ |

### Assessment

| Aktion | AM | CM | Admin |
|--------|----|----|----|
| Order anlegen | ✅ | ⚠ | ✅ |
| Run zuweisen | ⚠ | ✅ | ✅ |
| Report Upload | ⚠ | ✅ | ✅ |
| Credit-Typ-Wechsel | ❌ | ❌ | ✅ (Override) |

### Prozess

| Aktion | AM | CM | Admin |
|--------|----|----|----|
| Stage ändern | ✅ | ✅ | ✅ |
| **Placement (TX1)** | ✅ | ⚠ | ✅ |
| Admin-Approval Erfolgsbasis > Schwelle | ❌ | ❌ | ✅ |
| Cancel-Placement (Rückzieher) | ✅ | ❌ | ✅ |

### Scraper

| Aktion | AM | Admin |
|--------|----|----|
| Review-Queue bearbeiten | ✅ | ✅ |
| Scraper-Typ aktivieren/deaktivieren | ❌ | ✅ |
| Alert dismissen | ✅ | ✅ |

### Projekt

| Aktion | AM | CM | Researcher | Admin |
|--------|----|----|------|----|
| Stammdaten editieren | ✅ | ⚠ | ✅ | ✅ |
| Beteiligung CRUD | ✅ | ✅ | ✅ | ✅ |
| Quick-Create (Mini-Drawer) | ✅ | ✅ | ✅ | ✅ |

### Admin-Vollansicht `/admin` (Design-Entscheidung 2026-04-17)

**Zugriff ausschließlich Rolle `admin`.** Head of Department (`head_of_department`) hat **keinen** Admin-Zugriff — HoD nutzt Dashboard mit erweitertem Team-Scope + `/team` Read-only.

| Tab | AM | CM | Researcher | Head of | Admin | Backoffice |
|-----|----|----|------------|---------|-------|------------|
| Tab 1 Feature-Flags | ❌ | ❌ | ❌ | ❌ | ✅ | ❌ |
| Tab 2 Automation-Regeln | ❌ | ❌ | ❌ | ❌ | ✅ | ❌ |
| Tab 3 Reminder-Templates | ❌ | ❌ | ❌ | ❌ | ✅ | ❌ |
| Tab 4 Email-Admin | ❌ | ❌ | ❌ | ❌ | ✅ | ❌ |
| Tab 5 Telefonie 3CX | ❌ | ❌ | ❌ | ❌ | ✅ | ❌ |
| Tab 6 Scraper-Admin | ❌ | ❌ | ❌ | ❌ | ✅ | ❌ |
| Tab 7 Notifications | ❌ | ❌ | ❌ | ❌ | ✅ | ❌ |
| Tab 8 Dashboard-Templates | ❌ | ❌ | ❌ | ❌ | ✅ | ❌ |
| Tab 9 Debug | ❌ | ❌ | ❌ | ❌ | ✅ | ❌ |
| Tab 10 Audit &amp; Retention | ❌ | ❌ | ❌ | ❌ | ✅ | ❌ |

**Ausnahme Retention-Policy (Tab 10 Sub-Tab 10.3):** Vier-Augen-Prinzip · Änderung erfordert zwei Admin-Signaturen · Proposal + Approval-Saga.

**Admin-Fallback:** Letzter aktiver Admin-User kann nicht deaktiviert werden (DB-Constraint `COUNT(admins active) ≥ 1`).

**Middleware:** `requireRole('admin')` auf allen `/api/admin/*` · HTTP 403 für alle anderen Rollen · Redirect `/dashboard` mit Toast „Keine Berechtigung".

## Legende

- ✅ **Voll**
- ⚠ **Read-Only oder nur in Ausnahmen** (z.B. Stellvertretung, tenant-weit)
- ❌ **Kein Zugriff**

## Related

[[berechtigungen]], [[status-enum-katalog]], [[detailseiten-guideline]]
