# ARK CRM — DB-Schema-Patch · E-Learning Sub D · v0.1

**Scope:** Datenmodell-Erweiterung für den Progress-Gate (Sub D).
**Zielversion:** gemeinsam mit Sub A/B/C in konsolidiertem Version-Bump.
**Basis-Specs:** `specs/ARK_E_LEARNING_SUB_D_SCHEMA_v0_1.md`, `specs/ARK_E_LEARNING_SUB_D_INTERACTIONS_v0_1.md`.
**Vorherige Patches:** Sub A + B + C DB-Patches.
**Stand:** 2026-04-20
**Status:** Review ausstehend (Peter)

---

## Changelog

| # | Tabelle | Änderung | Typ |
|---|---------|----------|-----|
| 1 | `dim_elearn_gate_rule` | NEU | CREATE |
| 2 | `fact_elearn_gate_event` | NEU | CREATE |
| 3 | `dim_elearn_gate_override` | NEU | CREATE |
| 4 | `fact_elearn_compliance_snapshot` | NEU | CREATE |
| 5 | `dim_elearn_certificate` | +4 Spalten (`status`, `expired_at`, `revoked_at`, `revoked_reason`) | ALTER |
| 6 | Indizes | 7 neue | INDEX |
| 7 | CHECK-Constraints | 4 neue | ALTER CHECK |
| 8 | Tenant-Settings `elearn_d.*` | Seed | DATA |
| 9 | Default-Gate-Rules-Seed | 4 Default-Rules pro Tenant | DATA |

---

## 1. Neue Tabellen

Vollständige DDL in `ARK_E_LEARNING_SUB_D_SCHEMA_v0_1.md §4`. Kurzform:

```sql
dim_elearn_gate_rule (rule_id PK, tenant_id, name, description, trigger_type,
                      trigger_params JSONB, blocked_features TEXT[], allowed_features TEXT[],
                      priority, enabled, created_by, created_at, updated_at,
                      UNIQUE(tenant_id, name))

fact_elearn_gate_event (event_id PK, tenant_id, ma_id, rule_id, feature_key, action,
                        override_id, request_meta JSONB, occurred_at)

dim_elearn_gate_override (override_id PK, tenant_id, ma_id, override_type, reason,
                          valid_from, valid_until, pause_deadlines, created_by,
                          created_at, ended_at, ended_by)

fact_elearn_compliance_snapshot (snapshot_id PK, tenant_id, ma_id, snapshot_date,
                                 courses_total, courses_completed,
                                 newsletters_total, newsletters_passed,
                                 certs_active, certs_expired, overdue_items,
                                 compliance_score,
                                 UNIQUE(tenant_id, ma_id, snapshot_date))
```

## 2. ALTER `dim_elearn_certificate` (Sub-A-Tabelle)

```sql
ALTER TABLE dim_elearn_certificate
  ADD COLUMN status TEXT NOT NULL DEFAULT 'active',
  ADD COLUMN expired_at TIMESTAMPTZ,
  ADD COLUMN revoked_at TIMESTAMPTZ,
  ADD COLUMN revoked_reason TEXT;

ALTER TABLE dim_elearn_certificate ADD CONSTRAINT ck_cert_status
  CHECK (status IN ('active','expired','revoked'));

CREATE INDEX ON dim_elearn_certificate (tenant_id, ma_id, status) WHERE status = 'active';
```

## 3. Indizes

```sql
CREATE INDEX ON dim_elearn_gate_rule (tenant_id, enabled, priority DESC) WHERE enabled = true;
CREATE INDEX ON fact_elearn_gate_event (tenant_id, ma_id, occurred_at DESC);
CREATE INDEX ON fact_elearn_gate_event (tenant_id, feature_key, occurred_at DESC);
CREATE INDEX ON fact_elearn_gate_event (tenant_id, rule_id, occurred_at DESC) WHERE rule_id IS NOT NULL;
CREATE INDEX ON dim_elearn_gate_override (tenant_id, ma_id, valid_from, valid_until)
  WHERE ended_at IS NULL;
CREATE INDEX ON fact_elearn_compliance_snapshot (tenant_id, ma_id, snapshot_date DESC);
CREATE INDEX ON fact_elearn_compliance_snapshot (tenant_id, snapshot_date, compliance_score);
```

## 4. CHECK-Constraints

```sql
ALTER TABLE dim_elearn_gate_rule ADD CONSTRAINT ck_gate_rule_trigger_type
  CHECK (trigger_type IN ('newsletter_overdue','onboarding_overdue','refresher_due',
                           'cert_expired','assignment_expired'));

ALTER TABLE fact_elearn_gate_event ADD CONSTRAINT ck_gate_event_action
  CHECK (action IN ('blocked','allowed','overridden','bypassed'));

ALTER TABLE dim_elearn_gate_override ADD CONSTRAINT ck_gate_override_type
  CHECK (override_type IN ('vacation','parental_leave','medical','emergency_bypass','other'));

ALTER TABLE dim_elearn_gate_override ADD CONSTRAINT ck_gate_override_dates
  CHECK (valid_until IS NULL OR valid_until > valid_from);
```

## 5. Tenant-Settings (Seed)

```sql
UPDATE dim_elearn_tenant SET settings = settings || '{
  "elearn_d": {
    "login_popup_enabled": true,
    "login_popup_min_items": 1,
    "gate_cache_ttl_seconds": 60,
    "compliance_snapshot_cron": "0 3 * * *",
    "compliance_report_retention_months": 36,
    "cert_auto_revoke_on_major_version": true,
    "dashboard_banner_position": "top",
    "default_gate_rules_seed": true
  }
}'::jsonb;
```

## 6. Default-Gate-Rules-Seed

Bei Tenant-Create (via Setup-Script oder Migration):

```sql
INSERT INTO dim_elearn_gate_rule (tenant_id, name, description, trigger_type, trigger_params, blocked_features, allowed_features, priority, enabled) VALUES
  ($tenant_id, 'Hard-Newsletter-Block',
   'Feature-Sperre bei nicht abgeschlossenem Newsletter mit hard-Enforcement',
   'newsletter_overdue',
   '{"enforcement_mode": "hard"}',
   ARRAY['create_candidate','update_candidate','create_account','update_account',
         'create_mandate','update_mandate','create_job','update_job',
         'create_process','update_process','progress_process_stage',
         'create_placement','send_email','export_data'],
   ARRAY['read_*','elearning_*','dashboard_full'],
   100, true),

  ($tenant_id, 'Onboarding-Expired-Block',
   'Onboarding-Kurs seit > 14 Tagen überfällig',
   'onboarding_overdue',
   '{"days_past_deadline": 14}',
   ARRAY['create_candidate','create_process','create_mandate'],
   ARRAY['read_*','elearning_*'],
   90, true),

  ($tenant_id, 'Cert-Expired-Readonly',
   'Compliance-Basics-Cert abgelaufen',
   'cert_expired',
   '{"course_slugs": ["compliance-basics"]}',
   ARRAY['create_candidate','update_candidate','create_process','update_process'],
   ARRAY['read_*','elearning_*'],
   80, true),

  ($tenant_id, 'Soft-Newsletter-Warning',
   'Newsletter mit soft-Enforcement offen (kein Block, nur Banner-Trigger)',
   'newsletter_overdue',
   '{"enforcement_mode": "soft"}',
   ARRAY[]::TEXT[],
   ARRAY[]::TEXT[],
   50, true);
```

## 7. Migration-Script

`migrations/NNN_elearn_sub_d_gate.sql`:

1. `CREATE TABLE` für 4 neue Tabellen.
2. `ALTER TABLE dim_elearn_certificate` (Status-Erweiterung).
3. `CREATE INDEX` (7 neue).
4. `ALTER TABLE … ADD CONSTRAINT`.
5. `UPDATE dim_elearn_tenant SET settings` (JSONB-Merge).
6. Seed: Default-Gate-Rules pro existierendem Tenant (idempotent mit `ON CONFLICT DO NOTHING`).

Rollback via `DROP TABLE … CASCADE` + Cert-Spalten-Drop + Settings-Cleanup.

## 8. Performance

- **Hot-Path:** Gate-Middleware evaluiert Rules pro Request. Cache-Layer (Redis/In-Memory) mit 60 s TTL.
- **Ohne Cache:** ~5-15 ms (mehrere Index-Lookups), akzeptabel bei niedrigem Volumen.
- **Mit Cache:** < 1 ms (Hash-Lookup).
- **Compliance-Snapshot-Worker:** pro MA ~50 ms (Multi-JOIN), 30 MA Tenant → 1.5 s/Run.

## 9. Offene Punkte

- **Cert-Status-Backfill:** beim initialen Deploy alle bestehenden Certs explizit `status='active'` setzen (via Migration Default).
- **Overrides-Rescheduler:** Deadline-Pause-Verschiebung muss über mehrere Tabellen (Sub-A-Assignments + Sub-C-Assignments) konsistent funktionieren.
