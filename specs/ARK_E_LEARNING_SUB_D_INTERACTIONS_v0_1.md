---
title: "ARK E-Learning Sub D (Progress-Gate) — Interactions v0.1"
type: spec
created: 2026-04-20
updated: 2026-04-20
sources: []
tags: [elearning, erp, phase3, sub-d, interactions, gate, enforcement]
status: draft
author: Peter Wiederkehr + Claude (Brainstorming-Session 2026-04-20)
companion: ARK_E_LEARNING_SUB_D_SCHEMA_v0_1.md
---

# ARK E-Learning Sub D · Progress-Gate · Interactions v0.1

> **Companion:** [`ARK_E_LEARNING_SUB_D_SCHEMA_v0_1.md`](ARK_E_LEARNING_SUB_D_SCHEMA_v0_1.md)

## 0. Scope

Flows: Gate-Evaluation-Engine (Request-Time-Middleware), Rule-Trigger-Matching, Override-Anwendung, Login-Popup, Compliance-Snapshot-Worker, Cert-Lifecycle (Expiry + Revocation bei Major-Version).

## 1. Event-Typen

| Event | Payload |
|-------|---------|
| `elearn_gate_rule_created` | `rule_id, name, trigger_type` |
| `elearn_gate_rule_updated` | `rule_id, changes` |
| `elearn_gate_rule_disabled` | `rule_id, disabled_by` |
| `elearn_gate_blocked` | `ma_id, rule_id, feature_key, request_path` |
| `elearn_gate_overridden` | `ma_id, override_id, rule_id, feature_key` |
| `elearn_gate_override_created` | `override_id, ma_id, override_type, created_by, valid_until` |
| `elearn_gate_override_ended` | `override_id, ma_id, ended_by, end_reason` |
| `elearn_cert_expired` | `cert_id, ma_id, course_id` |
| `elearn_cert_revoked` | `cert_id, ma_id, course_id, reason` |
| `elearn_course_major_version_bumped` | `course_id, old_version, new_version` |
| `elearn_compliance_snapshot_created` | `snapshot_date, ma_count, avg_score` |
| `elearn_login_popup_shown` | `ma_id, pending_items_count` |

## 2. Worker / Cron / Middleware

### 2.1 Middleware (Request-Time)

`gate-middleware` in jedem geschützten API-Route eingehängt (via Decorator `@gate_feature('create_process')`).

**Flow pro Request:**

1. Extrahiere `tenant_id` + `ma_id` + `feature_key` aus JWT + Route-Decorator.
2. Cache-Lookup (`Redis` oder In-Memory): `gate:{tenant_id}:{ma_id}` — TTL aus `settings.elearn_d.gate_cache_ttl_seconds` (Default 60 s).
3. Falls Cache-Miss:
   - Lade aktive Rules für Tenant (sortiert nach `priority DESC`, `enabled=true`).
   - Lade aktive Overrides für MA (`valid_from <= NOW() AND (valid_until IS NULL OR valid_until > NOW()) AND ended_at IS NULL`).
   - Lade triggers-state: offene Assignments, expired Certs, etc. (aus Sub A/C Tabellen).
   - Evaluiere jede Rule: trigger matched?
   - Cache das Ergebnis-Set (aktive Rules + Override-Set) für MA.
4. Pro Rule im Cache:
   - Wenn `feature_key IN allowed_features` → **allowed** (short-circuit).
   - Wenn `feature_key IN blocked_features` **UND** kein Override greift → **blocked** + Audit-Event + HTTP 403.
5. Keine Rule matched → **allowed**.
6. Schreibe `fact_elearn_gate_event` (action, rule_id falls getriggert, override_id falls Override griff).

**Request-Response-Format bei Block:**

```json
HTTP 403 Forbidden
{
  "error": "GATE_BLOCKED",
  "rule_id": "...",
  "rule_name": "Hard-Newsletter-Block",
  "message": "Newsletter KW17 noch nicht abgeschlossen",
  "redirect_to": "/erp/elearn/gate.html?rule=<id>"
}
```

Frontend fängt `403 GATE_BLOCKED` ab und leitet weiter.

### 2.2 Cron-Worker

| Worker | Schedule | Zweck |
|--------|----------|-------|
| `elearn-compliance-snapshot` | täglich `0 3 * * *` | Pro MA Compliance-Score berechnen, in `fact_elearn_compliance_snapshot` schreiben |
| `elearn-cert-expiry-monitor` | täglich `0 4 * * *` | Certs mit `issued_at + refresher_months < NOW()` → `status='expired'`, Event |
| `elearn-override-ender` | stündlich | Overrides mit `valid_until < NOW()` → `ended_at=NOW()`, Event |
| `elearn-deadline-rescheduler` | bei Override-Ende | Pausierte Deadlines um Pause-Dauer verschieben |

### 2.3 Event-driven Worker

| Worker | Trigger-Event | Zweck |
|--------|---------------|-------|
| `elearn-cert-revoker` | `elearn_course_major_version_bumped` (aus Sub A) | Alle aktiven Certs für diesen Kurs: `status='revoked'`, `revoked_reason='course_major_version_bump'` |
| `elearn-gate-cache-invalidator` | `elearn_gate_rule_*` / `elearn_gate_override_*` | Cache-Keys invalidieren (Pattern: `gate:{tenant_id}:*`) |
| `elearn-assignment-state-listener` | `elearn_quiz_passed`, `elearn_newsletter_quiz_passed`, `elearn_course_completed` | MA-Cache für diesen MA invalidieren |

## 3. Gate-Evaluation-Engine

### 3.1 Trigger-Expression-Evaluator

Jeder Trigger-Typ hat eine fest codierte Eval-Funktion (sichere Engine, keine freie SQL-Injection):

```python
def eval_newsletter_overdue(tenant_id, ma_id, params) -> bool:
    q = """
      SELECT 1 FROM fact_elearn_newsletter_assignment
      WHERE tenant_id = $1 AND ma_id = $2
        AND status NOT IN ('quiz_passed','expired')
        AND enforcement_mode_applied = $3
      LIMIT 1
    """
    return db.fetch_one(q, tenant_id, ma_id, params['enforcement_mode']).exists

def eval_onboarding_overdue(tenant_id, ma_id, params) -> bool:
    days = params.get('days_past_deadline', 0)
    q = """
      SELECT 1 FROM fact_elearn_assignment
      WHERE tenant_id = $1 AND ma_id = $2 AND reason = 'onboarding'
        AND status = 'active' AND deadline < NOW() - make_interval(days => $3)
      LIMIT 1
    """
    return db.fetch_one(q, tenant_id, ma_id, days).exists

# analog für refresher_due, cert_expired, assignment_expired
```

### 3.2 Override-Prüfung

```python
def active_override(tenant_id, ma_id) -> Optional[Override]:
    q = """
      SELECT * FROM dim_elearn_gate_override
      WHERE tenant_id = $1 AND ma_id = $2
        AND valid_from <= NOW()
        AND (valid_until IS NULL OR valid_until > NOW())
        AND ended_at IS NULL
      ORDER BY created_at DESC
      LIMIT 1
    """
    return db.fetch_one(q, tenant_id, ma_id)
```

Override greift über **alle** Rules (global per MA). Kein selektiver Override pro Rule (MVP; Phase-2 denkbar).

### 3.3 Rule-Auflösung (Priorität)

```
Request mit feature=X kommt rein.
1. Overrides geprüft → aktiv? → allow + Audit-Event `overridden`. Done.
2. Rules sorted by priority DESC, enabled=true.
3. Für jede Rule:
     a. Trigger-Eval: greift?
     b. Wenn ja:
        - feature IN rule.allowed_features? → allow + Audit. Done.
        - feature IN rule.blocked_features? → block + Audit. HTTP 403.
     c. Wenn nein: nächste Rule.
4. Keine Rule blockiert → allow + Audit.
```

### 3.4 Cache-Strategie

- Key: `gate:{tenant_id}:{ma_id}` → JSON `{active_rules: [rule_id, ...], active_override_id, computed_at}`
- TTL: 60 s (tenant-konfigurierbar).
- Invalidation-Trigger:
  - Rule CRUD (Cache-Key-Pattern: `gate:{tenant_id}:*` löschen).
  - Override CRUD für spezifischen MA (`gate:{tenant_id}:{ma_id}` löschen).
  - Assignment-Status-Änderung (Quiz-Pass, Newsletter-Pass, Course-Complete): MA-spezifischen Key löschen.
- Fallback bei Cache-Outage: direkte DB-Evaluation (langsamer, aber funktional).

## 4. Deadline-Pause bei Override

### 4.1 Trigger

Override wird angelegt mit `pause_deadlines=true` (Default).

**Sofort:**
- Alle offenen Assignments des MA bekommen ein „pause-Marker" (via neuer Spalte oder separate Tabelle). Einfacher Ansatz: beim Override-Create wird die **Pause-Dauer dokumentiert**; beim Override-Ende werden Deadlines verschoben.

**Während Pause:**
- Deadline-Expiry-Worker (`elearn-deadline-expiry` aus Sub A, `newsletter-reminder` aus Sub C) prüft vor Expiry: aktiver Override mit `pause_deadlines=true`? → Skip.
- Reminder-Worker: gleicher Check, keine Reminder-Sends während Pause.

### 4.2 Bei Override-Ende

Worker `elearn-deadline-rescheduler` (event-driven auf `elearn_gate_override_ended`):

1. Berechne Pause-Dauer: `pause_duration = ended_at - valid_from`.
2. Für alle Assignments des MA mit `status IN ('active','pending','reading','quiz_in_progress','quiz_failed')` und `deadline IS NOT NULL` und `deadline > valid_from`:
   - `deadline = deadline + pause_duration`
3. Event `elearn_deadlines_rescheduled` pro Assignment (Audit).

## 5. Cert-Lifecycle

### 5.1 Expiry

**Worker `elearn-cert-expiry-monitor` täglich:**

```sql
UPDATE dim_elearn_certificate SET
  status = 'expired',
  expired_at = NOW()
WHERE status = 'active'
  AND issued_at + (SELECT refresher_months FROM dim_elearn_course c WHERE c.course_id = dim_elearn_certificate.course_id) * INTERVAL '1 month' < NOW()
  AND (SELECT refresher_months FROM dim_elearn_course c WHERE c.course_id = dim_elearn_certificate.course_id) IS NOT NULL;
```

Pro betroffenem Cert: Event `elearn_cert_expired`.

### 5.2 Revocation bei Major-Version-Bump

**Sub-A-Content-Import-Worker erkennt Major-Version:**
- Wenn `dim_elearn_course.version` inkrementiert um ≥ 1 (Breaking Change) UND `content_hash` sich um > 30 % unterscheidet (Threshold-Default) → emittiere `elearn_course_major_version_bumped`.
- Alternative: Admin kann im Publish-Flow explizit „Major-Version" checkboxen.

**Sub-D-Worker `elearn-cert-revoker` reagiert:**

```sql
UPDATE dim_elearn_certificate SET
  status = 'revoked',
  revoked_at = NOW(),
  revoked_reason = 'course_major_version_bump'
WHERE course_id = $1 AND status = 'active' AND course_version < $new_version;
```

Pro revokten Cert: Event `elearn_cert_revoked` + Notification an MA + automatische Refresher-Assignment (via Sub A Refresher-Logik).

### 5.3 Manueller Revoke

Admin-Endpoint `POST /api/elearn/admin/certs/:id/revoke` mit `{reason}`:
- Cert → `status='revoked'`, `revoked_reason=<reason>`, `revoked_at=NOW()`.
- Event, Notification an MA.
- Assignment für Kurs wird **nicht** automatisch neu erzeugt (Admin-Entscheidung ob Re-Cert nötig).

## 6. Login-Popup

### 6.1 Trigger

Nach Login-Flow (erste Page nach Auth): Frontend-Hook prüft:

```
GET /api/elearn/my/gate-status
→ {
    pending_items: 3,
    blocks_active: true,
    rules_triggered: [{name, blocked_features[]}],
    override_active: null
  }
```

Wenn `pending_items >= settings.elearn_d.login_popup_min_items` (Default 1): **modaler Dialog**.

### 6.2 Popup-Layout

```
┌─────────────────────────────────────┐
│    📋 Offene Pflicht-Aufgaben       │
│                                     │
│  • Newsletter KW17 (noch 2 Tage)    │
│  • Onboarding-Kurs "Marktwissen ARC"│
│  • Refresher "SIA-Normen"           │
│                                     │
│  Du hast 3 offene Pflicht-Items.    │
│  Bitte erledige sie zeitnah, um     │
│  Feature-Sperren zu vermeiden.      │
│                                     │
│  [Zu meinen Aufgaben]  [Später]     │
└─────────────────────────────────────┘
```

- `Später`: schliesst Popup, erscheint beim nächsten Login wieder.
- `Zu meinen Aufgaben`: Redirect zu `/erp/elearn/dashboard.html`.
- Bei Hard-Enforcement (`blocks_active=true`): Button „Später" **disabled** → zwingt zur Action.

### 6.3 Popup-Suppression

- Nur 1× pro Session (nach Reload erneut).
- Admin kann Popup für einzelne MA deaktivieren (Override-Typ `emergency_bypass`).

## 7. Compliance-Snapshot-Worker

**`elearn-compliance-snapshot` täglich 03:00:**

```sql
INSERT INTO fact_elearn_compliance_snapshot (tenant_id, ma_id, snapshot_date,
    courses_total, courses_completed,
    newsletters_total, newsletters_passed,
    certs_active, certs_expired,
    overdue_items, compliance_score)
SELECT
    u.tenant_id,
    u.user_id AS ma_id,
    CURRENT_DATE,
    -- courses
    (SELECT COUNT(*) FROM fact_elearn_assignment a WHERE a.ma_id = u.user_id AND a.reason != 'newsletter'),
    (SELECT COUNT(*) FROM fact_elearn_assignment a WHERE a.ma_id = u.user_id AND a.status = 'completed'),
    -- newsletters
    (SELECT COUNT(*) FROM fact_elearn_newsletter_assignment n WHERE n.ma_id = u.user_id),
    (SELECT COUNT(*) FROM fact_elearn_newsletter_assignment n WHERE n.ma_id = u.user_id AND n.status = 'quiz_passed'),
    -- certs
    (SELECT COUNT(*) FROM dim_elearn_certificate c WHERE c.ma_id = u.user_id AND c.status = 'active'),
    (SELECT COUNT(*) FROM dim_elearn_certificate c WHERE c.ma_id = u.user_id AND c.status = 'expired'),
    -- overdue
    (SELECT COUNT(*) FROM fact_elearn_assignment a WHERE a.ma_id = u.user_id AND a.status = 'expired'
      UNION ALL SELECT COUNT(*) FROM fact_elearn_newsletter_assignment n WHERE n.ma_id = u.user_id AND n.status = 'expired'),
    -- compliance_score (simpel):
    ((courses_completed + newsletters_passed + certs_active) * 100.0) /
      NULLIF(courses_total + newsletters_total + certs_active + certs_expired, 0)
FROM dim_user u
WHERE u.tenant_id = $1 AND u.status = 'active'
ON CONFLICT (tenant_id, ma_id, snapshot_date) DO UPDATE SET ...;
```

Event `elearn_compliance_snapshot_created` pro Tenant-Run.

## 8. UI-Flows

### 8.1 `erp/elearn/gate.html` (Full-Screen Gate)

**Route-Parameter:** `?rule=<rule_id>` (oder mehrere).

**Layout:**

```
┌─────────────────────────────────────────────┐
│  🔒 Zugriff gesperrt                        │
│                                             │
│  Du hast offene Pflicht-Aufgaben, die       │
│  du erledigen musst, bevor du weiter-       │
│  arbeiten kannst.                           │
│                                             │
│  Offene Items:                              │
│  • Newsletter KW17 — Quiz noch offen        │
│    [Jetzt bearbeiten]                       │
│                                             │
│  • Onboarding-Kurs "Marktwissen ARC"        │
│    [Weiterlernen]                           │
│                                             │
│  Falls du dich ungerecht behandelt fühlst,  │
│  wende dich an deinen Head-of (Name).       │
└─────────────────────────────────────────────┘
```

- Arbeit im CRM ist blockiert bis alle Pflicht-Items resolved.
- E-Learning-Zugriff + Read-Routes funktionieren normal.

### 8.2 `erp/elearn/admin/compliance.html` (Admin)

**Widgets:**

- **Top-Row KPIs:** Tenant-Average Compliance-Score, % MA über 80 %, % MA unter 50 %, Total überfällige Items.
- **Team-Tabelle:** Compliance-Score pro Team/Sparte, sortierbar, drilldown.
- **MA-Tabelle:** detailliert pro MA (Score, Overdue-Count, Active-Overrides), sortiert nach Score asc.
- **Trend-Chart:** Compliance-Score-Entwicklung letzte 6 Monate (aus `fact_elearn_compliance_snapshot`).
- **Problem-List:** Top-10 MA mit niedrigstem Score.

**Aktionen pro MA:**
- Klick → Drawer mit Detail + Override-Set-Button + Direct-Link zu MA-Profil.

### 8.3 `erp/elearn/team/compliance.html` (Head)

Gleich wie Admin, aber gescoped auf eigenes Team (Sparte + Reports).

### 8.4 `erp/elearn/admin/gate-rules.html` (Rules-Editor)

- Tabelle aller Rules mit Enable-Toggle.
- `+ Neue Rule`-Drawer:
  - Name + Description
  - Trigger-Type-Dropdown (aus `elearn_gate_trigger_type`)
  - Trigger-Params (form je nach Type)
  - Blocked-Features (Multi-Select aus Feature-Catalog)
  - Allowed-Features (Multi-Select)
  - Priority (Number)
  - Enabled-Toggle
  - Preview: „Bei diesem Trigger werden X MA geblockt" (Dry-Run Preview).

### 8.5 `erp/elearn/admin/gate-overrides.html` (Override-Verwaltung)

- Tabelle aller aktiven + historischen Overrides.
- Filter: MA, Type, Aktiv/Beendet.
- `+ Neuer Override`-Drawer:
  - MA-Auswahl (Autocomplete)
  - Typ-Dropdown (vacation, parental_leave, medical, emergency_bypass, other)
  - Grund (Pflicht-Textarea)
  - Valid-From (Default NOW)
  - Valid-Until (Optional, offen = null)
  - Pause-Deadlines-Toggle (Default true)

### 8.6 `erp/elearn/admin/gate-audit.html` (Audit-Log)

- Tabelle aller `fact_elearn_gate_event`-Rows.
- Filter: MA, Feature, Action, Zeitraum, Rule.
- Drilldown auf Event-Detail mit `request_meta`.
- Export CSV/XLSX.

## 9. Dashboard-Banner (MA-Dashboard in Sub A)

```
┌───────────────────────────────────────────────────┐
│  ⚠ 2 offene Pflicht-Aufgaben                     │
│  Newsletter KW17 · Onboarding "Marktwissen ARC"  │
│  [Details]                                        │
└───────────────────────────────────────────────────┘
```

- Farbcodiert: gelb bei Soft, rot bei Hard.
- Nur sichtbar wenn `pending_items > 0`.
- Link öffnet Newsletter-Page bzw. Kurs-Page.

## 10. Topbar-Badge

- Icon (Glocke oder Checkliste) mit Count.
- Hover → Mini-Liste der pending Items.
- Klick → Navigation zu `dashboard.html` (MA) oder `compliance.html` (Admin/Head).

## 11. Fehler-Szenarien

| Szenario | Verhalten |
|----------|-----------|
| Cache-Outage | Direkt-DB-Eval, langsamer aber funktional |
| Rule-Expression-Fehler (z. B. DB-Schema-Change) | Rule wird als `disabled` markiert mit Error-Log; Admin-Alert |
| Override ohne `reason` (sollte via CHECK verhindert werden) | HTTP 400 |
| Compliance-Snapshot-Worker-Fehler (Tenant-spezifisch) | Fehler isoliert; andere Tenants unberührt; Admin-Alert |
| Circular-Gate (Feature für Gate-Unblock selbst gelockt) | Endpoints `/api/auth/*`, `/api/elearn/*`, `/api/elearn/gate/*` sind **hardcoded allowed** (keine Gate-Middleware) |

## 12. State-Diagramme

### 12.1 `dim_elearn_gate_override`

```
created (valid_from=NOW) → active (if valid_until > NOW) → ended (valid_until exceeded or manual)
                                                              ↑
                                                           ended_by
```

### 12.2 `dim_elearn_certificate.status`

```
active → expired (refresher_months passed)
       → revoked (course major version or admin manual)

expired → (new cert issued on refresher-pass) → active (neuer Cert, alter bleibt Audit)
```

## 13. Migration-Hinweise für Implementation

- **Default-Gate-Rules seeden** beim Tenant-Create.
- **Gate-Middleware in allen CRM-API-Routes einhängen** (backend-weiter Refactor; via Decorator einheitlich).
- **Hardcoded-Allowed-Routes-Liste** explizit pflegen (Auth + E-Learning + Base).
- **Cache-Layer** (Redis empfohlen für Production, In-Memory für Dev).

## 14. Nächste Schritte

1. Peter reviewt SCHEMA + INTERACTIONS.
2. Sub-D-Patches (5) folgen.
3. Konsolidierter Implementation-Plan A+B+C+D via `superpowers:writing-plans`.
