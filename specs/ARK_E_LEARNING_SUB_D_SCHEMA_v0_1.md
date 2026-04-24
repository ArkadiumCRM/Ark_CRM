---
title: "ARK E-Learning Sub D (Progress-Gate) — Schema v0.1"
type: spec
created: 2026-04-20
updated: 2026-04-20
sources: []
tags: [elearning, erp, phase3, sub-d, schema, gate, enforcement, compliance]
status: draft
author: Peter Wiederkehr + Claude (Brainstorming-Session 2026-04-20)
companion: ARK_E_LEARNING_SUB_D_INTERACTIONS_v0_1.md
depends_on: ARK_E_LEARNING_SUB_A_SCHEMA_v0_1.md, ARK_E_LEARNING_SUB_C_SCHEMA_v0_1.md
---

# ARK E-Learning Sub D · Progress-Gate · Schema v0.1

> **Companion:** [`ARK_E_LEARNING_SUB_D_INTERACTIONS_v0_1.md`](ARK_E_LEARNING_SUB_D_INTERACTIONS_v0_1.md)

## 0. Kontext

Sub D ist der **Progress-Gate** des E-Learning-Moduls. Er liest States aus Sub A (Kurs-Assignments, Certs) und Sub C (Newsletter-Assignments) und setzt Enforcement-Regeln durch:

- **Soft-Enforcement:** Dashboard-Banner, Topbar-Badge, Login-Popup.
- **Hard-Enforcement:** Feature-granulare Sperre via Middleware (HTTP 403 + Redirect zur Gate-Page).
- **Compliance-Reports:** Admin/Head-Dashboards mit Drilldown.
- **Cert-Lifecycle:** Auto-Revocation bei Kurs-Major-Version, Expiry-Trigger (aus Sub A bereits).
- **Override-System:** temporäre Pausen für Urlaub/Elternzeit/Notfall (unbegrenzt, audit-geloggt).

## 1. Guiding Principles

1. **Feature-granulare Gate-Regeln:** Admin definiert welche Features bei welchem Trigger gesperrt werden. Nicht binär „alles oder nichts".
2. **Trigger = Expression über Assignment/Cert-State.** SQL-ähnliche Expression, Engine evaluiert zur Request-Time.
3. **Audit-lastig:** jeder Gate-Block + Override + Cert-Revoke wird als Event geloggt.
4. **Compliance-Score simpel:** `% erledigte Pflicht-Items / total Pflicht-Items` pro MA.
5. **Override unbegrenzt** mit Audit-Zwang.
6. **Login-Popup aktiv:** bei ≥ 1 überfälligem Pflicht-Item modaler Dialog bei Login.
7. **Multi-Tenant:** alle Tabellen `tenant_id`.

## 2. Entscheidungs-Log (Brainstorming 2026-04-20)

| # | Entscheidung | Gewählt |
|---|--------------|---------|
| 1 | Gate-Granularität | Feature-based, konfigurierbar pro Rule |
| 2 | Cert-Revocation bei Kurs-Update | Automatisch bei Major-Version-Bump |
| 3 | Override-Max-Dauer | Unbegrenzt (Audit als Safeguard) |
| 4 | Compliance-Score-Formel | Simpel `% erledigt / total` |
| 5 | Login-Popup | Ja, modal bei Pending-Pflicht-Items |

## 3. Feature-Katalog (blockierbar/erlaubt)

**Feature-Keys** werden im Backend-Code als Decorator/Middleware-Tag pro Route gesetzt. Liste der initial definierten Keys:

### 3.1 Write-Features (typischerweise Kandidaten für Blocking)

- `create_candidate` · `update_candidate` · `delete_candidate`
- `create_account` · `update_account` · `delete_account`
- `create_mandate` · `update_mandate` · `delete_mandate`
- `create_job` · `update_job` · `delete_job`
- `create_process` · `update_process` · `progress_process_stage`
- `create_project` · `update_project`
- `create_activity`
- `create_placement`
- `send_email`

### 3.2 Read-Features (typischerweise immer erlaubt)

- `read_candidate` · `read_account` · `read_mandate` · `read_job` · `read_process` · `read_activity` · `read_placement`
- `read_admin_*`

### 3.3 E-Learning-Features (immer erlaubt, sonst Gate-Lock-Catch-22)

- `elearning_*` (alle `/api/elearn/*`-Endpoints)

### 3.4 Spezielle Features

- `dashboard_full` (vollständiger Dashboard-Zugriff)
- `export_data` (alle Export-Funktionen)
- `admin_*`

**Katalog-Verwaltung:**
- Admin sieht Liste aller Feature-Keys im Gate-Rules-Editor (Auto-Discovered aus Backend-Decorators).
- Konstante im Code-Base `FEATURE_CATALOG` (`lib/gate/feature_catalog.ts`).

## 4. DB-Schema

### 4.1 `dim_elearn_gate_rule`

```sql
dim_elearn_gate_rule (
  rule_id UUID PK,
  tenant_id UUID NOT NULL,
  name TEXT NOT NULL,
  description TEXT,
  trigger_type TEXT NOT NULL,              -- newsletter_overdue | onboarding_overdue | refresher_due | cert_expired | assignment_expired
  trigger_params JSONB NOT NULL DEFAULT '{}',  -- typ-spezifische Params, z.B. {course_slugs: [...], enforcement_mode: 'hard'}
  blocked_features TEXT[] NOT NULL DEFAULT '{}',
  allowed_features TEXT[] NOT NULL DEFAULT '{}',  -- Whitelist bei Konflikt (allowed gewinnt)
  priority INT NOT NULL DEFAULT 100,
  enabled BOOLEAN NOT NULL DEFAULT true,
  created_by UUID,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (tenant_id, name)
)
```

**Trigger-Types (vordefiniert, nicht frei-formulierbar für Sicherheit):**

| trigger_type | Params | Beschreibung |
|--------------|--------|--------------|
| `newsletter_overdue` | `{enforcement_mode: 'soft'|'hard'}` | Aktiviert wenn MA ≥ 1 Newsletter-Assignment mit `status NOT IN ('quiz_passed','expired')` und Mode matcht |
| `onboarding_overdue` | `{days_past_deadline: 0}` | Aktiviert bei Onboarding-Assignments `status='expired'` oder `deadline < NOW() - X days` |
| `refresher_due` | `{course_slugs?: []}` | Aktiviert bei Refresher-Assignments `status='active'` mit überfälligem Deadline |
| `cert_expired` | `{course_slugs?: []}` | Aktiviert bei `dim_elearn_certificate` mit `status='expired'` (bzw. über Refresher-Logik abgeleitet) |
| `assignment_expired` | `{reason?: [...]}` | Generischer Trigger für beliebige abgelaufene Assignments |

### 4.2 `fact_elearn_gate_event` (Audit)

```sql
fact_elearn_gate_event (
  event_id UUID PK,
  tenant_id UUID NOT NULL,
  ma_id UUID NOT NULL,
  rule_id UUID REFERENCES dim_elearn_gate_rule,
  feature_key TEXT NOT NULL,
  action TEXT NOT NULL,                    -- blocked | allowed | overridden | bypassed
  override_id UUID REFERENCES dim_elearn_gate_override,
  request_meta JSONB,                      -- z.B. {path, method, user_agent}
  occurred_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
)
```

### 4.3 `dim_elearn_gate_override`

```sql
dim_elearn_gate_override (
  override_id UUID PK,
  tenant_id UUID NOT NULL,
  ma_id UUID NOT NULL,
  override_type TEXT NOT NULL,             -- vacation | parental_leave | medical | emergency_bypass | other
  reason TEXT NOT NULL,
  valid_from TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  valid_until TIMESTAMPTZ,                 -- null = offen bis manuell beendet
  pause_deadlines BOOLEAN NOT NULL DEFAULT true, -- werden Pflicht-Deadlines pausiert?
  created_by UUID NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  ended_at TIMESTAMPTZ,
  ended_by UUID
)
```

### 4.4 `fact_elearn_compliance_snapshot` (Tages-Aggregat)

```sql
fact_elearn_compliance_snapshot (
  snapshot_id UUID PK,
  tenant_id UUID NOT NULL,
  ma_id UUID NOT NULL,
  snapshot_date DATE NOT NULL,
  courses_total INT NOT NULL DEFAULT 0,
  courses_completed INT NOT NULL DEFAULT 0,
  newsletters_total INT NOT NULL DEFAULT 0,
  newsletters_passed INT NOT NULL DEFAULT 0,
  certs_active INT NOT NULL DEFAULT 0,
  certs_expired INT NOT NULL DEFAULT 0,
  overdue_items INT NOT NULL DEFAULT 0,
  compliance_score NUMERIC(5,2),           -- 0-100, simpel: (completed+passed+certs_active) / total
  UNIQUE (tenant_id, ma_id, snapshot_date)
)
```

**Zweck:** schnelle Trend-Queries für Compliance-Dashboard ohne Live-Aggregation. Worker füllt täglich.

### 4.5 Indizes

```sql
CREATE INDEX ON dim_elearn_gate_rule (tenant_id, enabled, priority DESC) WHERE enabled = true;
CREATE INDEX ON fact_elearn_gate_event (tenant_id, ma_id, occurred_at DESC);
CREATE INDEX ON fact_elearn_gate_event (tenant_id, feature_key, occurred_at DESC);
CREATE INDEX ON dim_elearn_gate_override (tenant_id, ma_id, valid_from, valid_until) WHERE ended_at IS NULL;
CREATE INDEX ON fact_elearn_compliance_snapshot (tenant_id, ma_id, snapshot_date DESC);
CREATE INDEX ON fact_elearn_compliance_snapshot (tenant_id, snapshot_date, compliance_score);
```

### 4.6 Cert-Status-Erweiterung (ALTER Sub-A-Tabelle)

```sql
ALTER TABLE dim_elearn_certificate
  ADD COLUMN status TEXT NOT NULL DEFAULT 'active'  -- active | expired | revoked
  ADD COLUMN expired_at TIMESTAMPTZ
  ADD COLUMN revoked_at TIMESTAMPTZ
  ADD COLUMN revoked_reason TEXT;

ALTER TABLE dim_elearn_certificate ADD CONSTRAINT ck_cert_status
  CHECK (status IN ('active','expired','revoked'));
```

**Status-Flow:**
- `active` (Default) bei Issue.
- `expired` wenn `issued_at + refresher_months < NOW()` ODER Event `elearn_cert_expired`.
- `revoked` wenn Kurs-Major-Version-Bump → Worker markiert alle alten Certs als `revoked` mit `revoked_reason='course_major_version_bump'`.

## 5. Tenant-Settings (JSONB `elearn_d`)

```yaml
elearn_d:
  login_popup_enabled: true
  login_popup_min_items: 1            # zeige Popup ab X pending Items
  gate_cache_ttl_seconds: 60
  compliance_snapshot_cron: "0 3 * * *"   # täglich 03:00
  compliance_report_retention_months: 36
  cert_auto_revoke_on_major_version: true
  dashboard_banner_position: "top"    # top | bottom
  default_gate_rules_seed: true       # seed Default-Rules bei Tenant-Create
```

## 6. API-Endpoints

### 6.1 MA-Endpoints

| Methode | Pfad | Zweck |
|---------|------|-------|
| GET | `/api/elearn/my/gate-status` | Eigener Status: Pending-Items, aktive Blocks, aktive Overrides |
| GET | `/api/elearn/my/compliance` | Eigener Compliance-Score + History |

### 6.2 Head-Endpoints

| Methode | Pfad | Zweck |
|---------|------|-------|
| GET | `/api/elearn/team/compliance` | Team-Dashboard (Compliance-Score pro MA) |
| GET | `/api/elearn/team/compliance/:ma_id` | MA-Detail: Pending-Items, History |
| POST | `/api/elearn/team/overrides` | Override für Team-MA setzen |
| POST | `/api/elearn/team/overrides/:id/end` | Override vorzeitig beenden |

### 6.3 Admin-Endpoints

| Methode | Pfad | Zweck |
|---------|------|-------|
| GET | `/api/elearn/admin/gate/rules` | Alle Gate-Rules |
| POST | `/api/elearn/admin/gate/rules` | Rule anlegen |
| PUT | `/api/elearn/admin/gate/rules/:id` | Rule ändern |
| POST | `/api/elearn/admin/gate/rules/:id/disable` | Rule deaktivieren |
| GET | `/api/elearn/admin/gate/events` | Audit-Log filterbar |
| GET | `/api/elearn/admin/gate/overrides` | Alle Overrides |
| POST | `/api/elearn/admin/gate/overrides` | Override tenant-weit setzen |
| GET | `/api/elearn/admin/compliance/metrics` | Tenant-KPIs |
| GET | `/api/elearn/admin/compliance/report` | Export CSV/XLSX |
| POST | `/api/elearn/admin/certs/:id/revoke` | Manueller Cert-Revoke |

### 6.4 Gate-Check-Endpoint (intern, für Middleware)

```
GET /api/elearn/gate/check?feature=<key>
→ 200 OK { allowed: true }
  OR
→ 403 Forbidden { allowed: false, rule_id, redirect_to: "/erp/elearn/gate.html?rule=<id>" }
```

Wird nicht direkt aufgerufen, sondern intern von Gate-Middleware in anderen Routen (siehe INTERACTIONS).

## 7. UI-Seiten

| Page | Sichtbarkeit | Zweck |
|------|--------------|-------|
| `erp/elearn/gate.html` | MA | Full-Screen-Gate bei Hard-Enforcement-Block |
| `erp/elearn/admin/compliance.html` | Admin/Backoffice | Tenant-Compliance-Dashboard |
| `erp/elearn/team/compliance.html` | Head | Team-Compliance-View |
| `erp/elearn/admin/gate-rules.html` | Admin | Rules-Editor |
| `erp/elearn/admin/gate-overrides.html` | Admin | Override-Verwaltung tenant-weit |
| `erp/elearn/admin/gate-audit.html` | Admin | Audit-Log-Browser |

**Embedded Components (injected in existing pages):**

- **Login-Popup** in Auth-Flow (modal overlay auf erster Page nach Login).
- **Dashboard-Banner** im Sub-A-Dashboard (für Soft-Enforcement-Reminders).
- **Topbar-Badge** global (Icon mit Count der pending Pflicht-Items).

**Sidebar-Erweiterung:**
- MA: „Mein Compliance-Status" (Link zu `/api/elearn/my/compliance` rendered page)
- Admin-Block: „Compliance-Dashboard", „Gate-Rules", „Override-Verwaltung", „Audit-Log"
- Head-Block: „Team-Compliance"

## 8. Enums

### 8.1 `elearn_gate_trigger_type`

| Wert | Bedeutung |
|------|-----------|
| `newsletter_overdue` | Newsletter-Assignment nicht bestanden |
| `onboarding_overdue` | Onboarding-Kurs-Assignment überfällig |
| `refresher_due` | Refresher-Assignment aktiv und überfällig |
| `cert_expired` | Cert abgelaufen |
| `assignment_expired` | Generisches Assignment-Expired |

### 8.2 `elearn_gate_event_action`

| Wert | Bedeutung |
|------|-----------|
| `blocked` | Request blockiert |
| `allowed` | Request erlaubt (Rule griff nicht) |
| `overridden` | Request erlaubt wegen aktiver Override |
| `bypassed` | Admin-Bypass-Event |

### 8.3 `elearn_gate_override_type`

| Wert | Bedeutung |
|------|-----------|
| `vacation` | Urlaub |
| `parental_leave` | Elternzeit |
| `medical` | Krankheit / medizinisch |
| `emergency_bypass` | Notfall-Bypass (kurzfristig, Admin-only) |
| `other` | Sonstiges (Pflicht-Reason-Begründung) |

### 8.4 `elearn_cert_status`

| Wert | Bedeutung |
|------|-----------|
| `active` | Gültig |
| `expired` | Abgelaufen (refresher_months) |
| `revoked` | Zurückgenommen (Major-Version-Bump oder Admin-Manual) |

## 9. Seed: Default-Gate-Rules

Beim Tenant-Create (oder manuell via Migration-Seed) werden Default-Rules angelegt:

| Rule-Name | Trigger | Blocked-Features |
|-----------|---------|------------------|
| `Hard-Newsletter-Block` | `newsletter_overdue {enforcement_mode: 'hard'}` | alle `create_*`, `update_*` (Write-Features), `export_data` |
| `Soft-Newsletter-Warning` | `newsletter_overdue {enforcement_mode: 'soft'}` | — (nur Banner-Trigger, kein Block) |
| `Onboarding-Expired-Block` | `onboarding_overdue {days_past_deadline: 14}` | `create_candidate`, `create_process`, `create_mandate` |
| `Cert-Expired-Readonly` | `cert_expired {course_slugs: ['compliance-basics']}` | `create_*`, `update_*` |

**Allowed-Features in allen:** `read_*`, `elearning_*`, `dashboard_full`.

Admin kann Rules deaktivieren/anpassen/löschen.

## 10. Offene Punkte

- **Real-time Update bei Override:** wenn Admin Override setzt während MA im CRM, soll Session live aktualisiert werden (WebSocket-Push) oder wartet bis nächster Request? MVP: wartet bis nächster Request, Cache-TTL regelt Verzögerung.
- **Gate-Lock-Catch-22:** MA kann via `elearning_*` Newsletter lesen und Quiz machen, aber wenn auch `/api/auth/refresh` gelockt wäre → Deadlock. → Auth/Base-Routes immer `allowed`.
- **Override-Löschung vs End:** `ended_at` vs DELETE. Decision: UPDATE `ended_at=NOW()`, nie physisches Delete (Audit).
- **Cert-Revocation-Trigger:** per Event `elearn_course_major_version_bumped` (aus Sub A). Muss in Sub-A-Spec ergänzt werden: bei `dim_elearn_course.version` inkrementiert (Major) → Event emittieren.

## 11. Abhängigkeiten

| Komponente | Abhängigkeit |
|------------|--------------|
| Sub A | Liest `fact_elearn_assignment`, `fact_elearn_enrollment`, `dim_elearn_certificate` |
| Sub B | keine direkte |
| Sub C | Liest `fact_elearn_newsletter_assignment.enforcement_mode_applied` |
| CRM | Gate-Middleware in allen CRM-API-Routes integriert |
| Auth | Login-Popup-Trigger via Auth-Flow |

## 12. Nächste Schritte

1. Peter reviewt SCHEMA + INTERACTIONS.
2. Sub-D-Patches (5) folgen.
3. Konsolidierter Implementation-Plan A+B+C+D via `superpowers:writing-plans`.
