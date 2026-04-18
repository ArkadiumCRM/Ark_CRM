---
title: "Breadcrumb-Konsistenz-Regel & Inventar"
type: meta
created: 2026-04-18
updated: 2026-04-18
tags: [breadcrumbs, konsistenz, detailseiten, navigation]
---

# Breadcrumb-Konsistenz-Regel

Einheitliche Regel für Breadcrumb-Darstellung in allen Detailseiten (autorefine Run 7 · 2026-04-18).

## Regel

1. **Max 4 Ebenen** — tiefer geht's nicht (Assessment/Mandat mit Account-Parent-Context sind 4-stufig, alles darüber hinaus wäre unübersichtlich).
2. **Alle Stufen klickbar** — rückwärts-Navigation auf jede Parent-Ebene möglich.
3. **Top-Level-Entity = 2-stufig**: `[Entity-Plural] / [Entity-Name]`. Klick auf "[Entity-Plural]" → Listen-Ansicht mit erhaltenem Filter/Scroll.
4. **Sub-Entity = 4-stufig mit Parent-Context**: `[Parent-Entity-Plural] / [Parent-Name] / [Sub-Entity-Plural] / [Sub-Name]`. Parent-Ebene wird vom FK (`account_id`, `candidate_id`) abgeleitet.
5. **Unabhängige Hubs** (Reminders, Dashboard, Operations) bekommen kein Entity-Breadcrumb, sondern ein funktionales (`Home / Operations / [Hub]`).

## Inventar (Stand 2026-04-18)

| Entity | Stufen | Pattern | Rolle | Spec-Ref |
|--------|--------|---------|-------|----------|
| Account | 2 | `Accounts / [Name]` | Top-Level | `ARK_ACCOUNT_DETAILMASKE_SCHEMA_v0_3.md` §3 |
| Kandidat | 2 | `Kandidaten / [Name]` | Top-Level | `ARK_KANDIDATENMASKE_SCHEMA_v1_3.md` Breadcrumb-Topbar |
| Projekt | 2 | `Projekte / [Name]` | Top-Level | `ARK_PROJEKT_DETAILMASKE_SCHEMA_v0_2.md` §3 |
| Firmengruppe | 2 | `Firmengruppen / [Name]` | Top-Level | `ARK_FIRMENGRUPPE_DETAILMASKE_SCHEMA_v0_1.md` §3 |
| Mandat | 4 | `Accounts / [A] / Mandate / [M]` | Sub (Account) | `ARK_MANDAT_DETAILMASKE_SCHEMA_v0_2.md` §3 |
| Assessment | 4 | `Accounts / [A] / Assessments / [ID]` | Sub (Account) | `ARK_ASSESSMENT_DETAILMASKE_SCHEMA_v0_3.md` §3 |
| Job | 4 | `Accounts / [A] / Jobs / [Titel]` | Sub (Account) | `ARK_JOB_DETAILMASKE_SCHEMA_v0_1.md` §3 |
| Prozess | 4 | `Kandidaten / [K] / Prozesse / [ID]` | Sub (Kandidat) | `ARK_PROZESS_DETAILMASKE_SCHEMA_v0_1.md` §3 — **DE-Umbenennung pending** (siehe unten) |
| Email/Kalender | funktional | `Home / Operations / Email & Kalender` | Hub | `ARK_EMAIL_KALENDER_DETAILMASKE_SCHEMA_v0_1.md` §3 |

## Sub-Punkt (offen): DE/EN-Sprachmischung

**Erfasst:** 2026-04-18

**Drift:** Zwei Specs zeigen englische Breadcrumb-Labels, alle anderen deutsch:
- `ARK_PROZESS_DETAILMASKE_SCHEMA_v0_1.md` §3: `Candidates / Max Muster / Processes / P-2026-318`
- `ARK_JOB_DETAILMASKE_SCHEMA_v0_1.md` §3: `Accounts / [Account] / Jobs / [Job-Titel]` — "Accounts" ist grenzwertig (wird in Account-Spec auch englisch genutzt), aber "Jobs" sollte "Stellen" oder "Vakanzen" sein (siehe Mockup-Baseline §16 Kanonische Labels).

**Fix-Vorschlag (zu Mockup-Baseline-Vocabulary-Punkt):**
- `Candidates` → `Kandidaten`
- `Processes` → `Prozesse`
- `Jobs` → `Stellen` (oder in §16 Baseline hinterlegen, welches kanonisch ist)
- "Accounts" vs "Kunden": in Mockup-Baseline §16 festlegen.

**Betroffene Specs:** Prozess-Schema v0.1, Job-Schema v0.1. Fix in nachfolgendem v0.2-Bump.

**Priorität:** P2 (kosmetisch, nicht strukturell).

## Related

- [[mockup-baseline]] §16 Kanonische UI-Label-Mappings
- [[detailseiten-nachbearbeitung]] Punkt "Cross-Navigation Breadcrumbs — Konsistenz-Pass"
- [[autorefine-log]] Run 7
