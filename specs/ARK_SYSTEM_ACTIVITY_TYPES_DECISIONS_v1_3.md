# ARK CRM — System-Activity-Types Decisions v1.3

**Zweck:** Konsolidierte Antworten auf alle offenen Fragen aus Phase-A-Spec-Dokumenten.
**Nachfolge-Version:** v1.3 — ersetzt die unentschiedenen Punkte aus v1.2-Specs
**Stand:** 17.04.2026
**Status:** Entscheidungen durch PO/Backend-Lead ausstehend — dieses Dokument **schlägt vor**, Review entscheidet final

**Begleit-Dokumente (werden nach Review auf v1.3 gebumpt):**
- `specs/ARK_SYSTEM_ACTIVITY_TYPES_SCHEMA_v1.md` (aktuell v1.2)
- `specs/ARK_STAMMDATEN_PATCH_v1_3_to_v1_4_ACTIVITY_TYPES.md`
- `specs/ARK_DATABASE_SCHEMA_PATCH_v1_3_to_v1_4.md`
- `specs/ARK_BACKEND_ARCHITECTURE_PATCH_v2_5_to_v2_6.md`
- `specs/ARK_EVENT_TYPES_MAPPING_v1_4.md`

---

## Übersicht der Entscheidungen (28 Fragen konsolidiert)

| Quelle | # | Thema | Entscheidung | Folge-Aufwand |
|--------|---|-------|--------------|---------------|
| Spec v1.2 | Q1 | Saga-Sub-Step-Audit | Team-Task (Backend Sprint 1) | Audit-Report vor v2.6-Deploy |
| Spec v1.2 | Q2 | Integration-Actor optional User zeigen | **ja v1.3** — Mini-User-Chip neben 🤖 | Mockup-Update Timeline |
| Spec v1.2 | Q3 | `email.received` Fallback | **#120 + `categorization_status=pending` + is_notifiable=true** | bereits in Mapping-Doc |
| Spec v1.2 | Q4 | Saga-Failures in Timeline | **nein** — nur Admin-Debug + Notification | keine weitere Änderung |
| Spec v1.2 | Q5 | Scrape-Events Granularität | **pro Entity** (nicht Batch) | keine Änderung |
| Spec v1.2 | Q6 | Notification-Channel v1.4 | **In-App only** — Email-Digest v1.5 | Notification-Spec v1.5 |
| Spec v1.2 | Q7 | `deprecated_at` auf `dim_event_types` | **nein** — `is_automatable=false` reicht | keine Änderung |
| Spec v1.2 | Q8 | Duplicate Notifications Hook+Rule | **Redis-Lock pro (event_id, notification_key)**, 60s TTL | Backend-Implementierung |
| Spec v1.2 | Q9 | Numbering #70–#121 | **sequentiell** (nicht thematisch) | keine Änderung |
| Stammdaten-Patch | P1 | Numbering | siehe Q9 — sequentiell | — |
| Stammdaten-Patch | P2 | `entity_relevance=both` pauschal | **bestätigt** — Consultant-Ergonomie rechtfertigt Duplizität | keine Änderung |
| Stammdaten-Patch | P3 | `is_notifiable` Defaults | **Defaults lassen** — Pilot-Phase-Review nach 4 Wochen Prod | Feinjustierung v1.5 |
| Stammdaten-Patch | P4 | #102 AI-Vorschlag UI | **Overlay auf pending-Zeile**, nicht eigene Timeline-Row | Mockup-Anpassung |
| Stammdaten-Patch | P5 | Kategorie „Garantie & Schutzfrist" split? | **zusammen lassen** — Activity-Type-Prefix klärt | keine Änderung |
| DB-Patch | D1 | „System" → „System / Meta" Umbenennung | **ja** — `UPDATE dim_activity_types SET activity_category='System / Meta'` | bereits in Migration enthalten |
| DB-Patch | D2 | `emitter_component` text vs enum | **text** — flexibler, Lint-überwacht | keine Änderung |
| DB-Patch | D3 | ~24 Event-Mapping | **abgeschlossen** via Event-Mapping-Doc (28 Events) | Migration-Update |
| DB-Patch | D4 | `call.received`/`email.received` Actor-Override | **Default `integration`**, User-Override bei manueller CRM-UI-Erfassung per payload | Writer-Logik |
| Backend-Arch | B1 | Pre-Rule-Hook-Placement | **direkt in `event-processor.worker.ts`** | bereits in Patch |
| Backend-Arch | B2 | Saga-Emission-Audit | Team-Task (siehe Q1) | — |
| Backend-Arch | B3 | Event-Scope-Registry Ownership | **Backend-Lead zentral**, Feature-Teams per PR | Owner-Dokumentation |
| Backend-Arch | B4 | Notification-Duplikate | siehe Q8 (Redis-Lock) | — |
| Backend-Arch | B5 | Idempotency-Strategie | **UNIQUE-Constraint auf `fact_history.event_id`** — kein Zeitfenster | Migration-Update |
| Event-Mapping | M1 | `system.retention_action` Conditional | **2 separate Event-Names**: `system.retention_action.candidate` (history) + `system.retention_action.other` (queue) | Mapping-Update |
| Event-Mapping | M2 | `call.received`/`email.received` notifiable | **is_notifiable=true** für Fallback-Rows #118/#120 | Activity-Type-Flags |
| Event-Mapping | M3 | `placement_done` vs `placement_completed` | **`placement_completed` kanonisch**, `placement_done` als Alias bis Ende v2.6-Rollout | Backend-Rename |
| Event-Mapping | M4 | `candidate.merged` Entity-Mapping | **Target-Kandidat** (Source wird archiviert) | Writer-Logik |
| Event-Mapping | M5 | #111 vs #59–64 Abgrenzung | **OK** — #111 ist spezifischer Merge-Event | — |

---

## Detaillierte Begründungen (nur für kontroverse Entscheidungen)

### Q2 — Integration-Actor optional User zeigen

**Szenario:** Outlook-Kalender-Sync erstellt Event `interview.scheduled`. Der Outlook-Nutzer war Consultant PW. Im Timeline-Eintrag aktuell nur 🤖 + `outlook`-Badge. PW's Arbeit ist unsichtbar.

**Entscheidung:** Mini-User-Chip neben 🤖 bei `actor_type='integration'` UND wenn `payload.triggered_by_user_id` gesetzt ist.

**Rendering-Regel v1.3:**
```
[Avatar: 🤖 + src-badge] [optional: Mini-User-Chip „via PW"]  Activity-Type-Name
```

**Nicht bei `actor_type IN ('system','automation')`** — dort gibt's keinen initiierenden User (Nightly-Batch, Saga-Engine sind autonom).

**Implementation:** `writeAutoHistory` liest `event.triggered_by` aus `fact_event_queue` und schreibt in `fact_history.mitarbeiter_id` (bereits vorhandenes Feld). Frontend rendert Mini-Chip nur wenn `actor_type='integration' AND mitarbeiter_id IS NOT NULL`.

### Q8 — Duplicate Notifications Hook + Rule

**Szenario:** Pre-Rule-Hook fanoutet Notification für `guarantee.started` (is_notifiable=true). Zusätzlich existiert eine Automation-Rule mit `action_type='send_notification'` für dasselbe Event → 2 Notifications an AM.

**Entscheidung:** Redis-basierte Idempotency mit 60-Sekunden-TTL:

```typescript
const lockKey = `notif-dedup:${event_id}:${notification_recipient}:${notification_template}`
const acquired = await redis.set(lockKey, '1', { NX: true, EX: 60 })
if (!acquired) {
  logger.debug({ lockKey }, 'notification deduplicated, skipping')
  return
}
await sendNotification(...)
```

**Warum 60s TTL:** Events werden in < 1s verarbeitet; 60s deckt Worker-Retries + Rule-Execution-Verzögerung. Nach 60s ist Dedup nicht mehr nötig (Event wäre eh verarbeitet).

**Fallback:** Wenn Redis nicht verfügbar → beide Notifications feuern (besser zu viel als zu wenig).

### P4 — AI-Vorschlag UI Overlay

**Ursprünglicher Plan:** #102 „AI - Activity-Type-Vorschlag" als eigene Timeline-Zeile.

**Problem:** Jeder unklassifizierte Call/Email hätte dann **2 Zeilen**: die originale (pending) + die AI-Suggestion — verdoppelt Timeline-Noise.

**Entscheidung:** AI-Suggestion als **Overlay auf bestehender pending-Zeile** darstellen:

```
[⚠ pending] Emailverkehr - Eingang unklassifiziert
└─ 🤖 AI-Vorschlag: „Emailverkehr - Schriftliche GOs" (Confidence 87 %)
   [ ✓ Annehmen ]  [ Manuell wählen … ]
```

**Konsequenz:**
- `dim_activity_types` #102 bleibt (Activity-Type existiert im Katalog)
- `dim_event_types.history.classification_suggested` behält `create_history=false` ← **Änderung gegenüber Spec v1.2!**
- Stattdessen wird das Feld `fact_history.suggested_activity_type` + `fact_history.ai_summary` genutzt, die bereits existieren (v1.3-Schema)

**Migration-Anpassung:** Event `history.classification_suggested` updated bestehende `fact_history`-Row, erzeugt keine neue.

### D1 — „System" → „System / Meta" Umbenennung

**Grund:** Neue Kategorie „Saga-Events" ist technisch auch „System", aber konzeptionell anders. Umbenennung macht Abgrenzung klarer.

**Risiko:** Views/Queries mit Filter `activity_category='System'` bricht.

**Check-Liste vor Migration:**
- [ ] Frontend-Filter-Labels auf neuen Namen (bereits in Mockup-Update Phase B erledigt — 8 Masken)
- [ ] Backend-Queries grep `activity_category = 'System'` → alle Treffer auf neuen String
- [ ] Reports (falls vorhanden) Feld-Mapping aktualisieren
- [ ] Seed-Daten in Test/Staging-DB migrieren vor Prod-Deploy

**Rollback:** Simples `UPDATE dim_activity_types SET activity_category='System' WHERE activity_category='System / Meta'` möglich, additive Änderung.

### M3 — `placement_done` vs `placement_completed` Aliasing

**Befund:** Bestehender Code (v2.5) emittiert `process.placement_done` (siehe Architektur-Doc Zeile 1335). Neuer Saga-Code (v2.6) emittiert `process.placement_completed` (konsistent mit Saga-Naming).

**Entscheidung:** `placement_completed` als **kanonisch** festlegen. Übergangslösung:

1. In `dim_event_types`: beide Event-Namen seeden, beide mit `create_history=true` und gleichem `default_activity_type_id=#99`
2. Backend-Rename über 2 Sprints: alle Stellen die `placement_done` emittieren → auf `placement_completed` umstellen
3. Nach vollständigem Rename: `placement_done` deaktivieren via `is_automatable=false`
4. Nach 3 Monaten Prod-Grünphase: `placement_done` komplett aus Katalog löschen

**Parallel-Phase:** Identisches Activity-Type-Mapping → keine Timeline-Duplikate (eines der beiden Events feuert pro Placement, nicht beide).

### M4 — `candidate.merged` Entity-Mapping

**Kontext:** Zwei Kandidaten-Profile werden zu einem zusammengeführt (z.B. Duplikat-Bereinigung). Source-Kandidat wird archiviert, Target bleibt.

**Entscheidung:** `fact_history`-Row geht an **Target-Kandidat**. Source-Kandidat-History wird VOR Merge in Target-History migriert (inkl. aller bestehenden Rows).

**Payload-Enrichment:** `fact_history.comment` enthält „Zusammengeführt aus Kandidat [Source-Name, archiviert]" — macht Merge-History-Eintrag selbsterklärend ohne Klick auf Source.

**Edge-Case:** Wenn Source bereits anonymisiert (GDPR, #106) → nur Name-Hash in Kommentar, kein Voll-Name.

### B5 — Idempotency via UNIQUE-Constraint

**Ursprünglich:** 24h-Zeitfenster in Writer-Logik („wenn fact_history für event_id bereits existiert innerhalb 24h → skip").

**Problem:** Retries nach > 24h würden doppelte Rows erzeugen.

**Entscheidung:** Harte Garantie via DB-Constraint:

```sql
ALTER TABLE ark.fact_history ADD CONSTRAINT uniq_fact_history_event_id
  UNIQUE (event_id) WHERE event_id IS NOT NULL;
```

Writer-Code vereinfacht:

```typescript
try {
  await db.insertInto('fact_history').values({ event_id, ... }).execute()
} catch (e) {
  if (isUniqueViolation(e, 'uniq_fact_history_event_id')) {
    logger.debug({ event_id }, 'duplicate event, skipping')
    return
  }
  throw e
}
```

**Deterministischer, weniger Code, keine Zeitfenster-Edge-Cases.**

---

## Namensvereinheitlichungen (4 Dopplungen)

Entschieden auf **Variante B** für alle — konsistenter `domain.action`-Style:

| v2.5-Name | v2.6-Kanonisch | Migrations-Strategie |
|-----------|----------------|----------------------|
| `process.placement_done` | `process.placement_completed` | Parallel-Phase (siehe M3) |
| `system.circuit_breaker_tripped` | `circuit_breaker.tripped` | Hart umbenennen (low-traffic Event) |
| `system.dead_letter_alert` | `dead_letter.alert` | Hart umbenennen (low-traffic Event) |
| `jobbasket.stage_changed` | `jobbasket.stage_assigned` | Spezifischer — auch hart umbenennen bei Seed |

**Für circuit_breaker + dead_letter:** Events emittieren nur Admin-Workers, keine Legacy-Konsumenten. Safe zu brechen.

**Für jobbasket:** bereits im Spec-Patch als `stage_assigned` geseedet — v1.3-Code unterstützt nur neuen Namen.

---

## Zusammenfassung: Specs die ge-bumpt werden müssen

| Spec | Version-Bump | Betroffene Sektionen |
|------|--------------|----------------------|
| `ARK_SYSTEM_ACTIVITY_TYPES_SCHEMA_v1.md` | v1.2 → v1.3 | §7.1 Rendering-Regel (User-Chip bei integration) · §9 Q2/Q8 resolved · Changelog |
| `ARK_STAMMDATEN_PATCH_v1_3_to_v1_4_ACTIVITY_TYPES.md` | Amendment | Offene Punkte 4/5 resolved (AI-Overlay + Kategorie confirm) |
| `ARK_DATABASE_SCHEMA_PATCH_v1_3_to_v1_4.md` | Amendment | +`uniq_fact_history_event_id` Constraint (B5) |
| `ARK_BACKEND_ARCHITECTURE_PATCH_v2_5_to_v2_6.md` | Amendment | §I Q1/Q4/Q5 resolved (Redis-Lock + UNIQUE-Constraint + Registry-Ownership) |
| `ARK_EVENT_TYPES_MAPPING_v1_4.md` | Amendment | §Offene Punkte M1-M5 resolved (retention split + notifiable + aliasing + merge-entity) |
| `migrations/001_system_activity_types.sql` | Update | +UNIQUE Constraint + `retention_action` Split + Namensvereinheitlichungen + Dedup-Setup |

---

## Offene Team-Tasks (nicht durch dieses Dokument beantwortet)

- [ ] **Saga-Emission-Audit** (Spec v1.2 Q1 + Backend-Arch B2) — Backend-Team prüft alle 8 bestehenden Sagas ob sie `correlation_id` emittieren. Deadline: vor v2.6-Deploy.
- [ ] **Event-Scope-Registry 35 neue Resolver** — Backend-Lead erstellt Registry-Datei (siehe Backend-Arch §D), Feature-Teams ergänzen bei neuen Events via PR.
- [ ] **Redis-Lock-Infrastruktur** — falls aktuell kein Redis im Stack, Evaluation Redis-vs-DB-Locks. Alternative: DB-basiertes Lock via `pg_advisory_lock`.
- [ ] **Backend-Rename `placement_done` → `placement_completed`** — 2-Sprint-Plan, grep+replace+test, dokumentierter Deprecation-Path.

---

## Integrations-Path

1. **Review:** PO + Backend-Lead geht dieses Dokument durch, OK-Setzung oder Gegen-Entscheidung pro Q-Nummer
2. **Spec-Updates:** nach Approval werden die 5 Patch-Dokumente amendet (neue Sektion „Amendments v1.3") oder Version-Bump
3. **Migration-Script-Update:** `migrations/001_system_activity_types.sql` aktualisiert um:
   - UNIQUE-Constraint auf `fact_history.event_id`
   - `retention_action.candidate` / `retention_action.other` Split
   - `placement_done` als deprecated-Alias geseedet
   - Redis-Lock-Keys in `dim_automation_settings` als Konfig
4. **Mockup-Update:** Timeline-Rendering erweitert um optional Mini-User-Chip bei `actor_type='integration'` mit `mitarbeiter_id IS NOT NULL`

---

**Ende Decisions-Dokument v1.3.**
