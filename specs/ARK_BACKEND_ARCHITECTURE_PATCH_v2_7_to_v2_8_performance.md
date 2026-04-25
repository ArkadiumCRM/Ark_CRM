---
title: "ARK Backend Architecture Patch v2.7 → v2.8 · Performance-Modul"
type: spec
module: performance
version: 2.8
created: 2026-04-25
updated: 2026-04-25
status: draft
sources: [
  "Grundlagen MD/ARK_BACKEND_ARCHITECTURE_v2_7.md",
  "specs/ARK_PERFORMANCE_TOOL_SCHEMA_v0_1.md",
  "specs/ARK_PERFORMANCE_TOOL_INTERACTIONS_v0_1.md",
  "specs/ARK_DATABASE_SCHEMA_PATCH_v1_5_to_v1_6_performance.md",
  "specs/ARK_HR_TOOL_SCHEMA_PATCH_v0_1_to_v0_2.md",
  "specs/ARK_BACKEND_ARCHITECTURE_PATCH_v2_6_to_v2_7_billing.md",
  "memory/project_performance_modul_decisions.md"
]
tags: [backend, patch, performance, hr-reviews, endpoints, workers, sagas, events, ws-channels, powerbi]
---

# ARK Backend Architecture Patch v2.7 → v2.8

**Scope:**
1. Aktivierung der `/api/v1/performance/*`- und `/api/v1/development/*`-Namespaces (waren 501-Stubs in v2.7 §11)
2. Hinzufügen ~50 Endpoints (Performance + HR-Reviews-Erweiterung)
3. Hinzufügen 12 Worker für Performance-Modul + 1 Worker für HR-Cycle-Lifecycle
4. Hinzufügen 10 Events (perf_*) + 5 Events (hr_review_*)
5. Hinzufügen 5 WS-Channels (perf:*) + 2 WS-Channels (hr:*)
6. Hinzufügen 3 Sagas (Closed-Loop, Pre-Built-Report, Review-Cycle-Lifecycle)

---

## 1. Endpoint-Inventar (Aktivierung + Detail)

### 1.1 Performance-Modul `/api/v1/performance/*`

#### Dashboard + Tiles

```
GET    /api/v1/performance/dashboard/:page_code
       ← Layout für aktuellen User (Rollen-Default + User-Override merged)
       Response: { tiles: [{tile_id, tile_type, metric_code, position, config, is_locked, data: {...}}], layout_meta: {...} }

PATCH  /api/v1/performance/dashboard/:page_code
       Body: { tiles: [{...}] }                                          ← User-Custom-Layout speichern
       UPSERT in dim_dashboard_layout WHERE scope='user_custom' AND user_id = current_user

POST   /api/v1/performance/dashboard/:page_code/reset
       ← User-Custom-Layout löschen → Fallback zu Rollen-Default
       DELETE FROM dim_dashboard_layout WHERE scope='user_custom' AND user_id = current_user AND page_code = :page_code

GET    /api/v1/performance/tiles/library
       ← verfügbare Tile-Typen (gefiltert nach visibility_roles)
       Response: { tile_types: [{code, label_de, min_w/h, default_w/h, requires_metric, config_schema_jsonb}] }

GET    /api/v1/performance/tiles/:tile_id/data?period=this_month&sparte=ARC
       ← Live-Data für eine Tile (mit Filter)
       Response: dynamisch je tile_type
       Cache: 60s pro tile_id × filter_hash
```

#### Metrics

```
GET    /api/v1/performance/metrics?category=pipeline&role_visible=ma
       ← Liste verfügbarer Metriken (gefiltert)
       Response: { metrics: [{code, label_de, category, unit, target_default, target_direction}] }

GET    /api/v1/performance/metrics/:code/snapshot?period_start=...&period_end=...&scope=sparte/ARC
       ← Aktueller Wert + Historie aus fact_metric_snapshot_*
       Response: { current: {value, target, achievement_pct}, history: [{date, value, target}] }

GET    /api/v1/performance/metrics/:code/drill-down?scope=sparte/ARC
       ← Drill-Down zu Underlying-Entities
       Response: { entities: [{entity_type, entity_id, label, contribution}] }
```

#### Goals (Q2=C operative Performance-Goals)

```
GET    /api/v1/performance/goals/me
       ← eigene aktive + abgelaufene Goals
       Response: { goals: [{id, metric_code, period_start, period_end, target_value, current_value, achievement_pct, drift_pct, state}] }

GET    /api/v1/performance/goals/team
       ← Team-Goals (Head, RBAC reports_to)
       Query: ?user_id=<spezifischer MA> | ?period=current_quarter

POST   /api/v1/performance/goals
       Body: { user_id, metric_code, period_start, period_end, target_value, target_direction, weight, description }
       INSERT fact_perf_goal mit set_by_user_id=current_user

PATCH  /api/v1/performance/goals/:id
       Body: { target_value?, period_end?, description? }
       UPDATE fact_perf_goal mit Audit-Trail-Append

DELETE /api/v1/performance/goals/:id
       Body: { cancellation_reason }
       UPDATE fact_perf_goal SET cancelled_at=NOW(), cancellation_reason
```

#### Insights (Q6=D Closed-Loop)

```
GET    /api/v1/performance/insights?severity=critical,blocker&state=open&scope_type=sparte
       ← Liste mit Filter
       Response: { insights: [{id, metric_code, severity, state, scope, snapshot_value, threshold_breached, title, description, recommended_action, related_entities, detected_at, age_days}] }

GET    /api/v1/performance/insights/:id
       ← Volldetail
       Response: { ...insight, related_actions: [{action_id, state, owner, due_date, outcome}] }

PATCH  /api/v1/performance/insights/:id/acknowledge
       UPDATE state='acknowledged', acknowledged_by_user_id, acknowledged_at

PATCH  /api/v1/performance/insights/:id/dismiss
       Body: { reason }
       UPDATE state='false_positive' mit Audit

POST   /api/v1/performance/insights/:id/actions
       Body: { title, description, hypothesis, planned_intervention, owner_user_id, due_date }
       SAGA-Trigger (siehe §6.1):
         1. INSERT fact_action_item
         2. UPDATE fact_insight SET state='action_planned'
         3. INSERT fact_reminder mit Cross-Link
         4. UPDATE fact_action_item SET reminder_id
       Response: { action_id, reminder_id }
```

#### Action-Items

```
GET    /api/v1/performance/actions?state=pending,in_progress&owner=me|team
       ← Liste mit Filter

PATCH  /api/v1/performance/actions/:id
       Body: { state?, hypothesis?, planned_intervention?, owner_user_id?, due_date?, notes? }
       State-Transition-Validierung:
         - pending → in_progress, cancelled
         - in_progress → done, cancelled
         - done → done (kein Re-Open)
       Bei state→'done': Trigger action-outcome-measurer mit measure_after_days=7

GET    /api/v1/performance/actions/:id/outcome
       ← Wirkungsmessung
       Response: { measured_at, baseline_value, after_value, delta_pct, effect, confirmed_by, follow_up_action_id }

POST   /api/v1/performance/actions/:id/confirm-outcome
       Body: { effect_confirmed: bool, follow_up_action?: {...} }
       UPDATE fact_action_outcome SET confirmed_at, confirmed_by_user_id
       Bei effect=improved + confirmed: UPDATE fact_insight SET state='resolved'
       Bei follow_up_action: SAGA wie /insights/:id/actions
```

#### Reports

```
GET    /api/v1/performance/reports/templates
       ← verfügbare Templates (gefiltert nach RBAC)
       Response: { templates: [{code, label_de, cadence, target_audience, cron_active, cron_expression, last_run_at, next_run_at}] }

POST   /api/v1/performance/reports/generate
       Body: { template_code, period_start?, period_end?, recipient_override?: [user_id, ...] }
       SAGA-Trigger (siehe §6.2):
         1. INSERT fact_report_run (state='queued')
         2. Emit perf:cron:<template_code>
       Response: { report_run_id }

GET    /api/v1/performance/reports/runs?template=...&state=...&period_start=...
       ← Audit-Liste mit Filter

GET    /api/v1/performance/reports/runs/:id
       ← Detail
       Response: { ...run, pdf_download_url }

POST   /api/v1/performance/reports/runs/:id/retry
       Bei state='failed' → state='queued' + Saga-Restart
```

#### Forecast (Q8=E Markov)

```
GET    /api/v1/performance/forecast/pipeline?period=q3_2026&scope=user/me|sparte/ARC
       ← Aggregat-Forecast
       Response: { total_expected_revenue_chf, total_expected_placements, confidence_interval: {low, high}, top_contributors: [{process_id, expected_revenue, probability}] }

GET    /api/v1/performance/forecast/process/:process_id
       ← Per-Prozess Markov-Decomposition
       Response: { process_id, current_stage, remaining_stages, conversion_rates: [{from, to, rate, sample_size}], time_decay, expected_revenue, placement_probability, expected_close_date, computation_inputs }

GET    /api/v1/performance/forecast/conversion-rates?sparte=ARC&business_model=mandat_target
       ← Markov-Conversion-Raten Audit
       Response: { rates: [{from_stage, to_stage, conversion_rate, avg_days_in_stage, sample_size, lookback_window_days, computed_at}] }

POST   /api/v1/performance/forecast/process/:process_id/override
       Body: { method='manual', placement_probability, expected_revenue_chf, expected_close_date, reason }
       INSERT fact_forecast_snapshot mit method='manual' (überstimmt automatischen Markov-Wert)
```

#### Admin

```
GET    /api/v1/performance/admin/metric-definitions
POST   /api/v1/performance/admin/metric-definitions
PATCH  /api/v1/performance/admin/metric-definitions/:code
DELETE /api/v1/performance/admin/metric-definitions/:code (Soft-Delete via active=FALSE)

GET    /api/v1/performance/admin/anomaly-thresholds
POST   /api/v1/performance/admin/anomaly-thresholds
PATCH  /api/v1/performance/admin/anomaly-thresholds/:id
DELETE /api/v1/performance/admin/anomaly-thresholds/:id

GET    /api/v1/performance/admin/powerbi-views
       Response: { views: [{code, label_de, refresh_cadence, last_refresh_at, last_refresh_state, last_refresh_duration_ms, row_count_estimate}] }
POST   /api/v1/performance/admin/powerbi-views/:code/refresh
       ← Manuelle Refresh-Trigger (synchron oder asynchron)
PATCH  /api/v1/performance/admin/powerbi-views/:code
       Body: { refresh_cron?, is_critical?, sql_definition?, active? }

GET    /api/v1/performance/admin/snapshot-lag
       Response: { workers: [{name, last_run_at, lag_minutes, last_run_state, failure_rate_24h}] }

GET    /api/v1/performance/admin/dashboard-defaults?role=head&page=team
PATCH  /api/v1/performance/admin/dashboard-defaults/:role/:page
       Body: { tiles: [{...}], locked_tile_ids: [tile_id, ...] }

GET    /api/v1/performance/admin/forecast-config
PATCH  /api/v1/performance/admin/forecast-config
       Body: { method?, lookback_window_days?, min_sample_size? }
POST   /api/v1/performance/admin/forecast/recompute
       ← Manueller Trigger für forecast-recompute.worker
```

### 1.2 Power-BI-Bridge `/api/powerbi/*` (X-API-Key Auth)

```
GET    /api/powerbi/views
       ← für Power-BI-Service-Account (nicht JWT, X-API-Key)
       Auth: API-Key in dim_powerbi_api_key (separate Tabelle, nicht im Spec — Standard-Pattern)
       Response: { views: [{code, label_de, last_refresh_at, sql_definition}] }

GET    /api/powerbi/refresh-status
       Response: { views: [{code, state, last_refresh_at}] }
```

### 1.3 HR-Reviews-Erweiterung `/api/v1/hr/*` (siehe HR-Patch §13 für Detail)

Cycles, Reviews, 360°, Question-Bank, Competency, Development-Plans, Review-Summary — vollständig im HR-Patch dokumentiert.

---

## 2. Worker-Architektur

### 2.1 Performance-Modul-Worker

#### `metric-snapshot-hourly.worker.ts`

```typescript
// Cron: 15 * * * * (jede Stunde :15)
// Nur kritische Metriken (cadence='hourly' in dim_metric_definition)

export async function metricSnapshotHourlyWorker() {
  const tenants = await getTenants();
  for (const tenant of tenants) {
    setTenantContext(tenant.id);
    const metrics = await db.query(`
      SELECT * FROM ark_perf.dim_metric_definition
      WHERE active = TRUE AND cadence_default = 'hourly'
    `);
    for (const metric of metrics) {
      const value = await computeMetric(metric, { snapshot_at: roundToHour(new Date()) });
      await db.query(`
        INSERT INTO ark_perf.fact_metric_snapshot_hourly
          (tenant_id, metric_code, snapshot_at, scope_type, scope_value, metric_value, ...)
        VALUES (...)
        ON CONFLICT DO NOTHING
      `);
    }
  }
  // Emit perf_snapshot_lag_critical wenn Worker > 30min hinterm Schedule
}
```

#### `metric-snapshot-daily.worker.ts`

```typescript
// Cron: 0 2 * * * (täglich 02:00)
// Vollschnitt aller aktiven Metriken
// Plus: berechnet delta_vs_yesterday, delta_vs_last_week, delta_vs_last_month
// Plus: aktualisiert target_achievement_pct für aktive fact_perf_goal
// Lauf-Erwartung: ~30 Metriken × ~500 Scopes = ~15k Rows/Tag/Tenant
```

#### `metric-snapshot-weekly/monthly/quarterly/yearly.worker.ts`

```typescript
// Aggregiert aus fact_metric_snapshot_daily (nicht aus Live-Views — Konsistenz!)
// Berechnet zusätzliche delta-Felder spezifisch zur Periode
```

#### `anomaly-detector.worker.ts`

```typescript
// Cron: 0 6 * * * (täglich 06:00)

export async function anomalyDetectorWorker() {
  const tenants = await getTenants();
  for (const tenant of tenants) {
    setTenantContext(tenant.id);
    const thresholds = await db.query(`SELECT * FROM ark_perf.dim_anomaly_threshold WHERE active = TRUE`);

    for (const threshold of thresholds) {
      // Lade aktuellsten Snapshot für (metric_code, scope)
      const snapshot = await getLatestSnapshot(threshold);
      if (!snapshot) continue;
      if (snapshot.metric_count < threshold.min_sample_size) continue;

      // Cooldown-Check: gibt es einen offenen Insight in cooldown_hours?
      const recentInsight = await db.query(`
        SELECT * FROM ark_perf.fact_insight
        WHERE metric_code = $1 AND scope_type = $2 AND scope_value = $3
          AND state IN ('open','acknowledged','action_planned')
          AND detected_at > NOW() - INTERVAL '${threshold.cooldown_hours} hours'
      `);
      if (recentInsight.length > 0) continue;  // Skip, im Cooldown

      // Severity bestimmen
      const severity = determineSeverity(snapshot.metric_value, threshold);
      if (!severity) continue;  // im OK-Bereich

      // Insight erstellen
      const insight = await db.query(`
        INSERT INTO ark_perf.fact_insight (...)
        VALUES (...)
        RETURNING *
      `);

      // Bei critical/blocker: Reminder erzeugen
      if (severity === 'critical' || severity === 'blocker') {
        await createReminder(insight);
      }

      // Event emit
      await emitEvent('perf_insight_detected', { insight_id: insight.id, severity, metric_code, scope });
    }
  }
}

function determineSeverity(value, threshold) {
  if (threshold.direction === 'above') {
    if (threshold.blocker_threshold && value >= threshold.blocker_threshold) return 'blocker';
    if (threshold.critical_threshold && value >= threshold.critical_threshold) return 'critical';
    if (threshold.warn_threshold && value >= threshold.warn_threshold) return 'warn';
    if (threshold.info_threshold && value >= threshold.info_threshold) return 'info';
  } else {
    if (threshold.blocker_threshold && value <= threshold.blocker_threshold) return 'blocker';
    // ... analog
  }
  return null;
}
```

#### `action-outcome-measurer.worker.ts`

```typescript
// Event-getriggert via perf_action_item_completed
// Verzögert um measure_after_days (Default 7d)

export async function actionOutcomeMeasurerWorker(event) {
  const action = await db.query(`SELECT * FROM ark_perf.fact_action_item WHERE id = $1`, [event.action_item_id]);
  const insight = await db.query(`SELECT * FROM ark_perf.fact_insight WHERE id = $1`, [action.insight_id]);

  // Aktueller Wert für gleiche metric+scope wie Insight
  const current = await getLatestSnapshot({ metric_code: insight.metric_code, scope_type: insight.scope_type, scope_value: insight.scope_value });

  if (!current) {
    // Inconclusive
    await db.query(`INSERT INTO fact_action_outcome (..., effect='inconclusive')`);
    return;
  }

  const delta_absolute = current.metric_value - insight.snapshot_value;
  const delta_percentage = (delta_absolute / Math.abs(insight.snapshot_value)) * 100;

  let effect;
  // Direction beachten (higher_better vs lower_better)
  const target = insight.snapshot_target;
  if (current.metric_value >= target) effect = 'improved';
  else if (delta_percentage > 5) effect = 'partially_improved';
  else if (Math.abs(delta_percentage) < 5) effect = 'no_change';
  else effect = 'worsened';

  await db.query(`
    INSERT INTO ark_perf.fact_action_outcome
      (tenant_id, action_item_id, metric_value_baseline, metric_value_after, delta_absolute, delta_percentage, effect)
    VALUES (...)
  `);

  await emitEvent('perf_action_outcome_measured', { action_item_id: action.id, effect, delta_pct: delta_percentage });
}
```

#### `report-generator.worker.ts`

```typescript
// Event-getriggert via perf_report_generate

export async function reportGeneratorWorker(event) {
  const run = await db.query(`UPDATE fact_report_run SET state='rendering' WHERE id = $1 RETURNING *`, [event.report_run_id]);
  const template = await db.query(`SELECT * FROM dim_report_template WHERE code = $1`, [run.template_code]);

  // Bundle aggregieren
  const bundle = await aggregateBundle(template.data_bundle_spec_jsonb, run.period_start, run.period_end, run.tenant_id);
  await db.query(`UPDATE fact_report_run SET data_bundle_jsonb = $1 WHERE id = $2`, [bundle, run.id]);

  // Dok-Generator-Service aufrufen
  const pdfPath = await dokGeneratorService.render(template.dok_generator_template, bundle);
  await db.query(`UPDATE fact_report_run SET pdf_file_path = $1, pdf_size_bytes = $2 WHERE id = $3`, [pdfPath, await fileSize(pdfPath), run.id]);

  // Email-Versand via individuelles Outlook-Token
  const recipients = await resolveRecipients(template.target_audience, run.tenant_id);
  const senderToken = await getOutlookToken(template.sender_user_id);
  for (const recipient of recipients) {
    await emailService.send({
      from: senderToken.user_email,
      to: recipient.email,
      subject: renderTemplate(template.email_template_code, 'subject', bundle),
      body: renderTemplate(template.email_template_code, 'body', bundle),
      attachments: [{ filename: `${template.code}.pdf`, path: pdfPath }],
      authToken: senderToken.access_token
    });
  }

  await db.query(`UPDATE fact_report_run SET state='sent', sent_at=NOW(), sent_to_emails=$1 WHERE id=$2`, [recipients.map(r => r.email), run.id]);
  await emitEvent('perf_report_generated', { report_run_id: run.id, template_code: run.template_code });
}
```

#### `forecast-recompute.worker.ts`

```typescript
// Cron: 0 5 * * * (täglich 05:00)
// 1. Berechne Conversion-Raten neu (12 Mt Lookback)
// 2. Berechne Forecast pro aktivem Prozess (Markov v0.1)
// 3. Berechne Aggregate (User, Sparte, Global)

export async function forecastRecomputeWorker() {
  const tenants = await getTenants();
  for (const tenant of tenants) {
    setTenantContext(tenant.id);

    // 1. Conversion-Raten
    const sparten = ['ARC', 'GT', 'ING', 'PUR', 'REM', 'ALL'];
    const businessModels = ['mandat_target', 'mandat_taskforce', 'mandat_time', 'erfolgsbasis', 'ALL'];
    for (const sparte of sparten) {
      for (const bm of businessModels) {
        const rates = await computeConversionRates(sparte, bm, 365);  // 12 Mt
        for (const rate of rates) {
          await db.query(`
            INSERT INTO dim_forecast_conversion_rate (...)
            VALUES (...)
            ON CONFLICT (tenant_id, sparte, business_model, from_stage, to_stage)
            DO UPDATE SET conversion_rate = EXCLUDED.conversion_rate, avg_days_in_stage = EXCLUDED.avg_days_in_stage, sample_size = EXCLUDED.sample_size, computed_at = NOW()
          `);
        }
      }
    }

    // 2. Forecast pro Prozess
    const activeProcesses = await db.query(`SELECT * FROM fact_process WHERE archived_at IS NULL AND current_stage NOT IN ('placement', 'rejected', 'closed')`);
    for (const proc of activeProcesses) {
      const forecast = computeMarkovForecast(proc);
      await db.query(`
        INSERT INTO fact_forecast_snapshot
          (tenant_id, snapshot_date, method, process_id, placement_probability, expected_revenue_chf, expected_close_date, confidence_interval_low, confidence_interval_high, computation_inputs_jsonb)
        VALUES (...)
      `);
    }

    // 3. Aggregate (User, Sparte, Global)
    await db.query(`
      INSERT INTO fact_forecast_snapshot (tenant_id, snapshot_date, method, aggregate_scope_type, aggregate_scope_value, placement_probability, expected_revenue_chf)
      SELECT tenant_id, CURRENT_DATE, 'markov_stage', 'user', cm_user_id::text, AVG(placement_probability), SUM(expected_revenue_chf)
      FROM fact_forecast_snapshot WHERE snapshot_date = CURRENT_DATE AND process_id IS NOT NULL
      GROUP BY tenant_id, cm_user_id
    `);
    // analog für sparte, global
  }
}

function computeMarkovForecast(process) {
  const remainingStages = getRemainingStages(process.current_stage);
  let probability = 1.0;
  let totalDays = 0;
  const trace = [];

  for (let i = 0; i < remainingStages.length - 1; i++) {
    const rate = getConversionRate(remainingStages[i], remainingStages[i+1], process.sparte, process.business_model);
    probability *= rate.conversion_rate;
    totalDays += rate.avg_days_in_stage;
    trace.push(rate);
  }

  // Time-Decay: alte Prozesse weniger wahrscheinlich
  const daysInStage = (Date.now() - new Date(process.last_stage_change_at).getTime()) / 86400000;
  const avgDaysCurrentStage = getAvgDaysInStage(process.current_stage, process.sparte);
  const timeDecay = Math.exp(-daysInStage / avgDaysCurrentStage);
  probability *= timeDecay;

  // Honorar
  const honorar = computeHonorar(process.expected_salary_chf);
  const expectedRevenue = honorar * probability;

  // Konfidenz-Intervall via Bootstrap (vereinfacht: ±25% des expectedRevenue)
  return {
    placement_probability: probability,
    expected_revenue_chf: expectedRevenue,
    expected_close_date: new Date(Date.now() + totalDays * 86400000),
    confidence_interval_low: expectedRevenue * 0.75,
    confidence_interval_high: expectedRevenue * 1.25,
    computation_inputs_jsonb: { remaining_stages: remainingStages, conversion_trace: trace, time_decay: timeDecay, honorar }
  };
}
```

#### `powerbi-view-refresh.worker.ts`

```typescript
// Per-View-Cron aus dim_powerbi_view.refresh_cron
// Nutzt Bull/BullMQ-Queue mit dynamischen Cron-Triggern

export async function powerbiViewRefreshWorker(viewCode) {
  const view = await db.query(`SELECT * FROM dim_powerbi_view WHERE code = $1`, [viewCode]);

  await db.query(`UPDATE dim_powerbi_view SET last_refresh_state='refreshing' WHERE code=$1`, [viewCode]);
  const start = Date.now();

  try {
    await db.query(`REFRESH MATERIALIZED VIEW CONCURRENTLY ark_perf.${viewCode}`);
    const duration = Date.now() - start;
    const rowCount = (await db.query(`SELECT COUNT(*) FROM ark_perf.${viewCode}`)).rows[0].count;
    await db.query(`
      UPDATE dim_powerbi_view
      SET last_refresh_state='fresh', last_refresh_at=NOW(), last_refresh_duration_ms=$1, row_count_estimate=$2, last_refresh_error=NULL
      WHERE code=$3
    `, [duration, rowCount, viewCode]);
  } catch (e) {
    await db.query(`
      UPDATE dim_powerbi_view
      SET last_refresh_state='failed', last_refresh_error=$1
      WHERE code=$2
    `, [e.message, viewCode]);
    await emitEvent('perf_powerbi_view_refresh_failed', { view_code: viewCode, error: e.message });
  }
}
```

#### `snapshot-retention-cleaner.worker.ts`

```typescript
// Cron: 0 3 * * 0 (Sonntag 03:00)
// Löscht abgelaufene Snapshots gemäss retention_until

export async function snapshotRetentionCleaner() {
  for (const cadence of ['hourly', 'daily', 'weekly', 'monthly', 'quarterly', 'yearly']) {
    const result = await db.query(`
      DELETE FROM ark_perf.fact_metric_snapshot_${cadence}
      WHERE retention_until < CURRENT_DATE
    `);
    log.info(`Cleaned ${result.rowCount} ${cadence}-snapshots`);
  }
  // Telemetrie analog
  await db.query(`DELETE FROM ark_perf.fact_dashboard_view_log WHERE retention_until < CURRENT_DATE`);
}
```

#### `partition-creator.worker.ts`

```typescript
// Cron: 0 0 1 * * (1. jeden Monats)
// Erstellt Snapshot-Partitionen für die nächsten 3 Monate

export async function partitionCreatorWorker() {
  for (let i = 0; i < 3; i++) {
    const month = new Date();
    month.setMonth(month.getMonth() + i);
    const start = formatDate(startOfMonth(month));
    const end = formatDate(startOfMonth(addMonths(month, 1)));
    const partitionName = `fact_metric_snapshot_hourly_${formatYearMonth(month)}`;

    await db.query(`
      CREATE TABLE IF NOT EXISTS ark_perf.${partitionName}
        PARTITION OF ark_perf.fact_metric_snapshot_hourly
        FOR VALUES FROM ('${start}') TO ('${end}')
    `);
  }
}
```

#### `dashboard-telemetry-rollup.worker.ts`

```typescript
// Cron: 0 4 * * 0 (Sonntag 04:00)
// Aggregiert Tile-Usage in fact_metric_snapshot_weekly für Self-Optimierung
```

### 2.2 HR-Modul-Worker (Erweiterung aus HR-Patch)

#### `review-cycle-lifecycle.worker.ts`

```typescript
// Event-getriggert (review_cycle_activated) + Cron (0 8 * * * für Reminder-Eskalation)

export async function reviewCycleLifecycleWorker(event) {
  if (event.type === 'review_cycle_activated') {
    // Saga Step 1: für jeden Target-MA Reviews erstellen
    const cycle = await db.query(`SELECT * FROM dim_feedback_cycles WHERE id = $1`, [event.cycle_id]);
    const targetUsers = await resolveTargetUsers(cycle);
    for (const user of targetUsers) {
      const manager = await getManager(user.id);
      await db.query(`
        INSERT INTO fact_performance_reviews (tenant_id, cycle_id, user_id, manager_user_id, state)
        VALUES (...)
      `);
      await createReminder({
        user_id: user.id,
        title: `Self-Assessment für ${cycle.label_de}`,
        due_date: cycle.self_assessment_due,
        source_type: 'hr_review',
        source_id: cycle.id
      });
    }
    await emitEvent('hr_review_cycle_started', { cycle_id: cycle.id, review_count: targetUsers.length });
  }

  // Cron-Eskalation: prüfe überfällige Reviews
  if (event.type === 'cron') {
    const overdueReviews = await db.query(`
      SELECT r.*, c.* FROM fact_performance_reviews r
      JOIN dim_feedback_cycles c ON r.cycle_id = c.id
      WHERE r.state = 'self_pending' AND c.self_assessment_due < CURRENT_DATE
    `);
    for (const review of overdueReviews) {
      // Eskalation: Reminder an Head + Notification
      await escalateOverdueReview(review);
    }
  }
}
```

---

## 3. Events (Event-Bus)

### 3.1 Performance-Modul-Events (10 Events)

| Event | Trigger | Payload | Konsumenten |
|-------|---------|---------|-------------|
| `perf_insight_detected` | `anomaly-detector.worker` neue Row in `fact_insight` | `{insight_id, severity, metric_code, scope}` | Reminders-Worker (critical+), WS `perf:insights` |
| `perf_insight_acknowledged` | UI-Action | `{insight_id, user_id}` | WS |
| `perf_action_item_created` | UI / Insight-Convert | `{action_item_id, owner_id, due_date, insight_id}` | Reminders-Worker (Auto-Reminder), WS `perf:actions` |
| `perf_action_item_completed` | UI-Action | `{action_item_id}` | `action-outcome-measurer.worker` (queued) |
| `perf_action_outcome_measured` | `action-outcome-measurer.worker` | `{action_item_id, effect, delta_pct}` | WS `perf:actions` |
| `perf_goal_drift_detected` | `anomaly-detector.worker` für `goal_drift`-Metric | `{goal_id, drift_pct, severity}` | Reminders bei warn+ |
| `perf_report_generate` | UI / Cron | `{report_run_id, template_code, period}` | `report-generator.worker` |
| `perf_report_generated` | `report-generator.worker` finished | `{report_run_id, template_code}` | WS `perf:reports`, Email-Service |
| `perf_report_failed` | `report-generator.worker` errored | `{report_run_id, failure_reason}` | Reminders an Admin |
| `perf_powerbi_view_refresh_failed` | `powerbi-view-refresh.worker` errored | `{view_code, error}` | Reminders an Admin (blocker) |
| `perf_snapshot_lag_critical` | Snapshot-Worker > 30min hinter Schedule | `{worker_name, lag_minutes}` | Reminders an Admin (blocker) |

### 3.2 HR-Reviews-Events (5 Events)

| Event | Trigger | Payload | Konsumenten |
|-------|---------|---------|-------------|
| `hr_review_cycle_activated` | Admin aktiviert Cycle | `{cycle_id}` | `review-cycle-lifecycle.worker` |
| `hr_review_cycle_started` | Worker hat alle Reviews erstellt | `{cycle_id, review_count}` | WS `hr:reviews` |
| `hr_review_self_assessment_completed` | MA submittet Self | `{review_id, user_id}` | WS, Reminder an Head |
| `hr_review_signed` | Beide haben unterschrieben | `{review_id, signed_pdf_path}` | Performance-Modul (`v_hr_review_summary`-Refresh-Hint), WS |
| `hr_probation_review_auto_triggered` | `fact_probation_milestones.milestone_type='probation_end'` | `{user_id, cycle_id}` | WS |

---

## 4. WebSocket-Channels

### 4.1 Performance-Modul (5 Channels)

| Channel | Inhalt | Visibility |
|---------|--------|------------|
| `perf:insights` | Live-Insight-Stream | tenant-weit, gefiltert per RBAC |
| `perf:actions` | Action-Item-Updates + Outcomes | wie oben |
| `perf:reports` | Report-Run-Status | tenant-weit |
| `perf:goals:{user_id}` | Goal-Updates | nur Self + Head + Admin |
| `perf:dashboard:{user_id}` | Tile-Refresh nach Snapshot-Lauf | nur Self |

### 4.2 HR-Reviews (2 Channels)

| Channel | Inhalt | Visibility |
|---------|--------|------------|
| `hr:reviews` | Review-Cycle-Status, Review-State-Changes | gefiltert per RBAC (Self/Manager/Admin) |
| `hr:dev-plans:{user_id}` | Development-Plan-Updates | Self + Mentor + Manager + Admin |

---

## 5. Sagas

### 5.1 Saga: Performance-Insight → Action → Outcome (Closed-Loop)

Vollständig dokumentiert in `ARK_PERFORMANCE_TOOL_SCHEMA_v0_1.md` §16.1 + `ARK_PERFORMANCE_TOOL_INTERACTIONS_v0_1.md` §5.2. Hier nur Implementation-Hints.

**Step-Mapping:**
- Step 1: `anomaly-detector.worker` → INSERT fact_insight + emit perf_insight_detected
- Step 2: API `POST /api/v1/performance/insights/:id/actions` → atomare TX:
  ```sql
  BEGIN;
    INSERT INTO fact_action_item (...) RETURNING id;
    UPDATE fact_insight SET state='action_planned' WHERE id=$1;
    INSERT INTO fact_reminder (source_type='performance_action_item', source_id=:action_id, ...) RETURNING id;
    UPDATE fact_action_item SET reminder_id=$reminder_id WHERE id=$action_id;
  COMMIT;
  ```
- Step 3: API `PATCH /api/v1/performance/actions/:id` mit state='done' → emit `perf_action_item_completed` mit measure_after_days
- Step 4: `action-outcome-measurer.worker` (verzögert) → INSERT fact_action_outcome
- Step 5: API `POST /api/v1/performance/actions/:id/confirm-outcome` → UPDATE outcome + ggf. resolve insight oder neue Folge-Action

**Failure-Handling:**
- Step 2 TX fehlschlägt (z.B. Reminder-Service down) → Rollback komplett, action_item NICHT erstellt, Insight bleibt acknowledged
- Step 4 worker findet keinen Snapshot → effect='inconclusive', Owner sieht "Daten nicht verfügbar — manuell bewerten"

### 5.2 Saga: Pre-Built-Report-Generation

Vollständig in `ARK_PERFORMANCE_TOOL_SCHEMA_v0_1.md` §16.2.

**Implementation:**
- Cron-Trigger via BullMQ Repeating-Job per Template
- TX-Boundaries: jeder Step in eigener TX (idempotent via state-machine)
- Failure-Recovery: state='failed' → Admin-Reminder → Retry-Endpoint manuell

### 5.3 Saga: HR-Review-Cycle-Lifecycle

In `ARK_HR_TOOL_SCHEMA_PATCH_v0_1_to_v0_2.md` §12.1.

**Step-Mapping:**
- Step 1 (Admin aktiviert): API `POST /api/v1/hr/review-cycles/:id/activate` → emit `hr_review_cycle_activated` → `review-cycle-lifecycle.worker`
- Step 2-4 (Self / Manager / 360°): API-Calls via Drawer
- Step 5 (Meeting): API `POST /api/v1/hr/reviews/:id/meeting-notes`
- Step 6 (Signoff): API `POST /api/v1/hr/reviews/:id/sign` (zweimal: Self + Manager) → bei beiden signed: Dok-Generator-Trigger
- Step 7 (Cycle-Close): Cron prüft täglich, schliesst Cycle wenn alle Reviews signed

---

## 6. Anpassung BACKEND v2.7 §11 (Endpoint-Aktivierung)

### 6.1 Streichung aus `### Phase 2 (reserviert – 501 Not Implemented)`

```diff
-/api/v1/performance/...   ← 360-Grad, Reviews
-/api/v1/development/...   ← E-Learning, Entwicklungspläne
```

### 6.2 Neue Sektion `### Performance` (analog `### Analytics`)

```
GET    /api/v1/performance/dashboard/:page_code
PATCH  /api/v1/performance/dashboard/:page_code
POST   /api/v1/performance/dashboard/:page_code/reset
GET    /api/v1/performance/tiles/library
GET    /api/v1/performance/tiles/:tile_id/data
GET    /api/v1/performance/metrics
GET    /api/v1/performance/metrics/:code/snapshot
GET    /api/v1/performance/metrics/:code/drill-down
GET    /api/v1/performance/goals/me
GET    /api/v1/performance/goals/team
POST   /api/v1/performance/goals
PATCH  /api/v1/performance/goals/:id
DELETE /api/v1/performance/goals/:id
GET    /api/v1/performance/insights
GET    /api/v1/performance/insights/:id
PATCH  /api/v1/performance/insights/:id/acknowledge
PATCH  /api/v1/performance/insights/:id/dismiss
POST   /api/v1/performance/insights/:id/actions
GET    /api/v1/performance/actions
PATCH  /api/v1/performance/actions/:id
GET    /api/v1/performance/actions/:id/outcome
POST   /api/v1/performance/actions/:id/confirm-outcome
GET    /api/v1/performance/reports/templates
POST   /api/v1/performance/reports/generate
GET    /api/v1/performance/reports/runs
GET    /api/v1/performance/reports/runs/:id
POST   /api/v1/performance/reports/runs/:id/retry
GET    /api/v1/performance/forecast/pipeline
GET    /api/v1/performance/forecast/process/:process_id
GET    /api/v1/performance/forecast/conversion-rates
POST   /api/v1/performance/forecast/process/:process_id/override
GET    /api/v1/performance/admin/metric-definitions
POST   /api/v1/performance/admin/metric-definitions
PATCH  /api/v1/performance/admin/metric-definitions/:code
DELETE /api/v1/performance/admin/metric-definitions/:code
GET    /api/v1/performance/admin/anomaly-thresholds
POST   /api/v1/performance/admin/anomaly-thresholds
PATCH  /api/v1/performance/admin/anomaly-thresholds/:id
DELETE /api/v1/performance/admin/anomaly-thresholds/:id
GET    /api/v1/performance/admin/powerbi-views
POST   /api/v1/performance/admin/powerbi-views/:code/refresh
PATCH  /api/v1/performance/admin/powerbi-views/:code
GET    /api/v1/performance/admin/snapshot-lag
GET    /api/v1/performance/admin/dashboard-defaults
PATCH  /api/v1/performance/admin/dashboard-defaults/:role/:page
GET    /api/v1/performance/admin/forecast-config
PATCH  /api/v1/performance/admin/forecast-config
POST   /api/v1/performance/admin/forecast/recompute
```

### 6.3 Neue Sektion `### Power-BI Bridge` (X-API-Key Auth)

```
GET    /api/powerbi/views                   ← X-API-Key, separater Auth
GET    /api/powerbi/refresh-status
```

### 6.4 Neue Sektion `### HR Reviews` (Erweiterung der HR-Sektion)

Siehe HR-Patch §13 für vollständige Liste (~30 Endpoints).

---

## 7. RBAC-Endpoints-Mapping

| Endpoint-Pattern | RBAC |
|-------------------|------|
| `GET /performance/dashboard/*` | alle Rollen (gefiltert) |
| `GET /performance/goals/me`, `/insights`, `/actions` | alle Rollen (Self + Team-Visibility) |
| `GET /performance/goals/team`, `/team/...` | head, admin |
| `POST /performance/goals` | head, admin (kann Goals für andere setzen) |
| `GET /performance/forecast/...` | head, admin (für Aggregate); MA für eigene Prozesse |
| `POST /performance/forecast/.../override` | head, admin |
| `GET/POST/PATCH/DELETE /performance/admin/*` | admin only |
| `GET /api/powerbi/*` | service-account (X-API-Key) |
| `POST /hr/reviews/:id/sign` | Self oder Manager (je nach signing-step) |
| `POST /hr/feedback-questions`, `/competency-framework` | admin only |
| `POST /hr/development-plans` | head, admin (gemeinsam mit MA) |

---

## 8. Caching-Strategie

| Endpoint | Cache-Type | TTL | Invalidierung |
|----------|------------|-----|---------------|
| `GET /performance/tiles/:id/data` | Redis | 60s | Cron-Snapshot-Lauf |
| `GET /performance/metrics` | Redis | 30min | Admin-CRUD auf metric-definitions |
| `GET /performance/forecast/conversion-rates` | Redis | 24h | `forecast-recompute.worker` |
| `GET /performance/reports/templates` | Redis | 30min | Admin-CRUD |
| `GET /performance/admin/snapshot-lag` | none | live | live (für Monitoring) |

---

## 9. Failure-Handling + Circuit-Breaker

- **Worker-Failures:** automatic retry × 3 mit exponential backoff. Bei 3 Fails: Dead-Letter-Queue + Reminder an Admin (`perf_snapshot_lag_critical` oder `perf_powerbi_view_refresh_failed`).
- **Materialized-View-Lock:** CONCURRENT REFRESH benötigt UNIQUE-Index — wenn Index fehlt, Fallback zu non-concurrent (mit Lock-Warning).
- **Email-Versand-Fehler:** report_run.state='sent' nur wenn alle Recipients erfolgreich; bei partial failure: state='partial', Liste erfolgreicher recipients in sent_to_emails, fehlgeschlagene in failure_reason.
- **Forecast-Datenmenge zu klein:** wenn `sample_size < min_sample_size` (Default 5) → Fallback zu `forecast_method='linear_trend'` oder `'manual'` mit Warning.

---

## 10. Migration-Reihenfolge (Backend-Deploy)

1. DB-Schema-Patch (siehe `ARK_DATABASE_SCHEMA_PATCH_v1_5_to_v1_6_performance.md`) deployed
2. Stammdaten-Patch (Seeds) deployed
3. Backend-Code-Deploy:
   - Endpoint-Handler implementiert
   - Worker-Code deployed
   - BullMQ-Queues konfiguriert
   - Cron-Trigger registriert
4. Initial-Snapshot-Lauf manuell triggern (für Backfill bestehender Daten)
5. Materialized-Views Initial-Refresh
6. Power-BI-Service-Account API-Key generiert + an Nenad
7. WS-Channels aktiviert
8. Frontend-Deploy mit neuen Pages

---

## 11. Acceptance Criteria

- [ ] ~50 Endpoints implementiert + Integration-Tests
- [ ] 12 Performance-Worker laufen + monitoring (Lag-Detection)
- [ ] 1 HR-Review-Cycle-Lifecycle-Worker funktional
- [ ] 10 Performance-Events emittiert + im Event-Bus registriert
- [ ] 5 HR-Review-Events emittiert
- [ ] 5 Performance-WS-Channels live
- [ ] 2 HR-WS-Channels live
- [ ] 3 Sagas end-to-end getestet (Closed-Loop, Report-Pipeline, Review-Cycle)
- [ ] BACKEND v2.7 §11-Update: Performance + Development-Stub-Listings entfernt + neue Sektionen
- [ ] Power-BI-Bridge mit X-API-Key Auth funktional
- [ ] Caching-Strategie implementiert
- [ ] Failure-Handling + Dead-Letter-Queue + Admin-Reminders
- [ ] Test-Coverage > 80% für Worker + > 90% für Endpoints
