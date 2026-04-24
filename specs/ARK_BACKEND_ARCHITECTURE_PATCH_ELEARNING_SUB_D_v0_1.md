# ARK CRM — Backend-Architektur-Patch · E-Learning Sub D · v0.1

**Scope:** Backend-Erweiterung für den Progress-Gate (Sub D): Gate-Middleware, Events, Worker, API-Endpoints, RLS, Cert-Lifecycle, Feature-Catalog.
**Zielversion:** gemeinsam mit Sub A/B/C.
**Basis-Specs:** `specs/ARK_E_LEARNING_SUB_D_SCHEMA_v0_1.md`, `specs/ARK_E_LEARNING_SUB_D_INTERACTIONS_v0_1.md`.
**Vorherige Patches:** Sub A+B+C Backend-Patches.
**Stand:** 2026-04-20
**Status:** Review ausstehend (Peter)

---

## Changelog

| # | Bereich | Änderung |
|---|---------|----------|
| 1 | Gate-Middleware | NEU: `@gate_feature(<key>)`-Decorator auf allen CRM-API-Routes |
| 2 | Event-Typen | +12 neue `elearn_gate_*` / `elearn_cert_*` |
| 3 | Worker | +4 Cron-Worker + 3 event-driven |
| 4 | API-Endpoints | +12 Endpoints (MA / Team / Admin) + 1 interner `/gate/check` |
| 5 | RLS-Policies | +4 Policies für neue Tabellen |
| 6 | Feature-Catalog | Neue Konstante `FEATURE_CATALOG` mit ~40 Feature-Keys |
| 7 | Cache-Layer | Redis (Prod) oder In-Memory (Dev) für Gate-Evaluation-Cache |
| 8 | Sub-A-Integration | Event `elearn_course_major_version_bumped` (neu aus Sub A Import-Worker) |

---

## 1. Gate-Middleware

Neuer Decorator `@gate_feature(<feature_key>)` für jeden geschützten API-Endpoint:

```ts
// Beispiel (TypeScript):
@gate_feature('create_candidate')
async createCandidate(req, res) { ... }

@gate_feature('read_candidate')  // wird immer allowed (hardcoded Whitelist), aber für Audit trotzdem decorateable
async readCandidate(req, res) { ... }
```

Middleware-Flow siehe `INTERACTIONS §2.1`. Bei Block: HTTP 403 mit JSON-Body (Frontend-Hook fängt ab → Redirect zu Gate-Page).

**Hardcoded-Allowed-Paths (kein Gate-Check):**
- `/api/auth/*` (Login, Logout, Refresh, Password-Reset)
- `/api/elearn/*` (E-Learning selbst, sonst Catch-22)
- `/api/health`, `/api/version`
- `/api/elearn/gate/check` (interner Middleware-Fallback)

**Decorator-Discovery:**
- Statisches Script scannt alle Routes und generiert `FEATURE_CATALOG.ts` → Admin-UI kennt alle Keys.
- CI-Check: jede neue Route **muss** einen `@gate_feature`-Decorator haben (oder explizit `@gate_exempt`).

## 2. Event-Typen

| event_name | emitter | create_history |
|------------|---------|----------------|
| `elearn_gate_rule_created` | rules-api | true |
| `elearn_gate_rule_updated` | rules-api | true |
| `elearn_gate_rule_disabled` | rules-api | true |
| `elearn_gate_blocked` | gate-middleware | false (nur in fact_elearn_gate_event) |
| `elearn_gate_overridden` | gate-middleware | false |
| `elearn_gate_override_created` | override-api | true |
| `elearn_gate_override_ended` | override-ender / manual | true |
| `elearn_cert_expired` | cert-expiry-monitor | true |
| `elearn_cert_revoked` | cert-revoker | true |
| `elearn_course_major_version_bumped` | sub-a-import-worker (neue Emission) | true |
| `elearn_compliance_snapshot_created` | compliance-snapshot-worker | false |
| `elearn_login_popup_shown` | frontend (POST zurück-Call) | false |

**Activity-Types:** 8 neue in `dim_activity_types` (siehe Stammdaten-Patch).

## 3. Worker

### 3.1 Cron

| Worker | Schedule | Zweck |
|--------|----------|-------|
| `elearn-compliance-snapshot` | `{tenant}.settings.elearn_d.compliance_snapshot_cron` (Default `0 3 * * *`) | Pro aktivem MA Compliance-Score berechnen |
| `elearn-cert-expiry-monitor` | täglich `0 4 * * *` | Certs mit `issued_at + refresher_months < NOW()` → `status='expired'` |
| `elearn-override-ender` | stündlich | Overrides mit `valid_until < NOW()` beenden |
| `elearn-snapshot-pruner` | monatlich `0 2 2 * *` | Snapshots älter `compliance_report_retention_months` löschen |

### 3.2 Event-driven

| Worker | Trigger | Zweck |
|--------|---------|-------|
| `elearn-cert-revoker` | `elearn_course_major_version_bumped` | Alle aktiven Certs dieses Kurses `status='revoked'` |
| `elearn-gate-cache-invalidator` | `elearn_gate_rule_*` / `elearn_gate_override_*` | Cache-Pattern invalidieren |
| `elearn-deadline-rescheduler` | `elearn_gate_override_ended` | Pausierte Deadlines verschieben |
| `elearn-ma-cache-invalidator` | `elearn_quiz_passed`, `elearn_newsletter_quiz_passed`, `elearn_course_completed` | MA-spezifischen Cache-Key löschen |

## 4. API-Endpoints

### 4.1 MA

| Methode | Pfad | Zweck |
|---------|------|-------|
| GET | `/api/elearn/my/gate-status` | Pending-Items, aktive Rules, aktiver Override |
| GET | `/api/elearn/my/compliance` | Eigener Compliance-Score + History |

### 4.2 Team

| Methode | Pfad | Zweck |
|---------|------|-------|
| GET | `/api/elearn/team/compliance` | Team-Compliance-Dashboard |
| GET | `/api/elearn/team/compliance/:ma_id` | MA-Detail |
| POST | `/api/elearn/team/overrides` | Override für Team-MA |
| POST | `/api/elearn/team/overrides/:id/end` | Override beenden |

### 4.3 Admin

| Methode | Pfad | Zweck |
|---------|------|-------|
| GET | `/api/elearn/admin/gate/rules` | Rules-Liste |
| POST | `/api/elearn/admin/gate/rules` | Rule anlegen |
| PUT | `/api/elearn/admin/gate/rules/:id` | Rule ändern |
| POST | `/api/elearn/admin/gate/rules/:id/disable` | Rule deaktivieren |
| GET | `/api/elearn/admin/gate/events` | Audit-Log filterbar |
| GET | `/api/elearn/admin/gate/overrides` | Alle Overrides |
| POST | `/api/elearn/admin/gate/overrides` | Override tenant-weit |
| GET | `/api/elearn/admin/compliance/metrics` | Tenant-KPIs |
| GET | `/api/elearn/admin/compliance/report` | CSV/XLSX-Export |
| POST | `/api/elearn/admin/certs/:id/revoke` | Manueller Cert-Revoke |
| GET | `/api/elearn/admin/feature-catalog` | Liste aller bekannten Feature-Keys |

### 4.4 Intern

| Methode | Pfad | Zweck |
|---------|------|-------|
| GET | `/api/elearn/gate/check?feature=<key>` | Middleware-Fallback (hardcoded allowed) |

## 5. RLS-Policies

```sql
ALTER TABLE dim_elearn_gate_rule ENABLE ROW LEVEL SECURITY;
CREATE POLICY gate_rule_tenant_iso ON dim_elearn_gate_rule
  USING (tenant_id = current_setting('app.current_tenant_id')::uuid)
  WITH CHECK (tenant_id = current_setting('app.current_tenant_id')::uuid);

-- Analog für fact_elearn_gate_event, dim_elearn_gate_override,
--              fact_elearn_compliance_snapshot.
```

**MA-Scoping zusätzlich:**
- `fact_elearn_compliance_snapshot` für MA-Endpoints zusätzlich per `ma_id`-Filter.
- Head sieht Team-Snapshots via `dim_user.reports_to`-Join.

## 6. Cache-Layer

**Prod:** Redis mit Key-Pattern `gate:{tenant_id}:{ma_id}`, TTL aus `settings.elearn_d.gate_cache_ttl_seconds`.

**Dev/Test:** In-Memory LRU-Cache (max 10k Keys).

**Invalidation:**
- Rule-CRUD: `DEL gate:{tenant_id}:*` (Pattern-Delete).
- Override-CRUD: `DEL gate:{tenant_id}:{ma_id}`.
- Assignment-State-Change: `DEL gate:{tenant_id}:{ma_id}`.

## 7. Feature-Catalog

Konstante in `lib/gate/feature_catalog.ts` (Backend) + `lib/gate/feature_catalog.py` (Python-Worker):

```ts
export const FEATURE_CATALOG = [
  // Write-Features
  { key: 'create_candidate', category: 'write', entity: 'candidate' },
  { key: 'update_candidate', category: 'write', entity: 'candidate' },
  { key: 'delete_candidate', category: 'write', entity: 'candidate' },
  { key: 'create_account', category: 'write', entity: 'account' },
  // ... (~30 Write-Features)

  // Read-Features (always allowed by default)
  { key: 'read_candidate', category: 'read', entity: 'candidate' },
  // ... (~10 Read-Features)

  // E-Learning (hardcoded allowed)
  { key: 'elearning_*', category: 'elearning', entity: null },
] as const;
```

Admin-UI zeigt diese Liste im Rules-Editor als Multi-Select.

## 8. Sub-A-Integration: Major-Version-Event

**Erweiterung in Sub-A-Import-Worker:**

Beim Import eines geänderten Kurses wird zusätzlich ein Event `elearn_course_major_version_bumped` emittiert, wenn:
- `dim_elearn_course.version` wurde inkrementiert (aus YAML-Frontmatter `version`).
- UND `content_hash` unterscheidet sich um ≥ 30 % vom Vor-Version-Hash (Threshold konfigurierbar).
- ODER YAML-Frontmatter enthält explizites Flag `major_version: true`.

Event-Payload: `{course_id, old_version, new_version, hash_diff_pct}`.

**Dokumentation in Sub-A-INTERACTIONS-Spec als Nachtrag** (bei Implementation).

## 9. Notifications

| Template | Empfänger | Trigger |
|----------|-----------|---------|
| `elearn-gate-blocked` | MA | `elearn_gate_blocked` (nur erster Block pro Session; debounced) |
| `elearn-cert-expired` | MA + Head | `elearn_cert_expired` |
| `elearn-cert-revoked` | MA + Head | `elearn_cert_revoked` |
| `elearn-override-created` | MA | `elearn_gate_override_created` |
| `elearn-override-ended` | MA + Head | `elearn_gate_override_ended` |
| `elearn-compliance-low` | Head | Compliance-Score < 50 % |
| `elearn-team-compliance-report` | Admin | wöchentlich, Zusammenfassung |

## 10. Performance-Annahmen

- **Gate-Middleware-Overhead mit Cache-Hit:** < 1 ms.
- **Cache-Miss-Rate:** ~5 % bei 60 s TTL und moderatem Verkehr.
- **Compliance-Snapshot pro MA:** ~50 ms Multi-JOIN.
- **Audit-Log-Volumen:** ~500 Events/Tag/MA bei aktivem CRM-Nutzer → ~150k Events/Monat/MA — Partition oder Archive nach 12 Monaten.

## 11. Security

- **Trigger-Params als JSONB:** nicht freie SQL-Eingabe; Trigger-Type-Evaluator hat fest codierte SQL-Queries (siehe INTERACTIONS §3.1). Verhindert SQL-Injection.
- **Override-Creation:** nur Admin/Head (Team-scoped für Head).
- **Rule-Disable:** nur Admin/Backoffice (Head kann keine Rules deaktivieren — würde Enforcement umgehen).
- **Audit-Log unveränderlich:** keine UPDATE/DELETE auf `fact_elearn_gate_event` (nur INSERT).

## 12. Offene Punkte

- **WebSocket-Gate-Status-Push:** bei Override-Set während aktiver MA-Session live aktualisieren? MVP: nicht, Cache-TTL regelt Verzögerung.
- **Rule-Priority-Konflikte:** wenn 2 Rules denselben Feature-Key betreffen, gewinnt höhere Priority. Dokumentation + UI-Warnung im Rules-Editor.
- **Backfill bei Einführung:** bestehende MA müssen einmalig `elearn_onboarding_active=false` gesetzt bekommen (sonst Default-Rules greifen nicht sinnvoll).
- **Emergency-Bypass-SLA:** Admin setzt Bypass → wie schnell wirksam? Cache-Invalidation sofort → wirksam mit nächstem Request.
