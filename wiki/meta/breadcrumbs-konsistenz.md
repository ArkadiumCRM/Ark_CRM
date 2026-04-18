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
| Prozess | 4 | `Accounts / [A] / Mandat · [M] / [K] · [Stage]` (Account-rooted, kanonisch per Mockup) · Alternative bei Kandidat-Referrer: `Kandidaten / [K] / Prozesse / [ID]` | Sub (Mandat ∩ Kandidat) | `ARK_PROZESS_DETAILMASKE_SCHEMA_v0_1.md` §3 |
| Email/Kalender | funktional | `Home / Operations / Email & Kalender` | Hub | `ARK_EMAIL_KALENDER_DETAILMASKE_SCHEMA_v0_1.md` §3 |

## Sub-Punkt DE/EN-Sprachmischung (abgearbeitet 2026-04-18 via autorefine Run 18)

**Ergebnis per Mockup-Baseline §16.10:** Kanonische UI-Labels sind ein Mix aus DE + international-DE:

- **Germanisiert:** `Kandidat/Kandidaten`, `Prozess/Prozesse`, `Mandat/Mandate`, `Projekt/Projekte`, `Firmengruppe/Firmengruppen`
- **International-DE (bleibt):** `Account/Accounts`, `Job/Jobs`, `Assessment/Assessments`

**Fix angewendet:**
- `ARK_PROZESS_DETAILMASKE_SCHEMA_v0_1.md` §3: EN → DE + Pattern-Korrektur auf Mockup-konformes Account-rooted (Mockup `processes.html:164-168` zeigt `Accounts / Bauherr Muster AG / Mandat · CFO-Suche / Tobias Furrer · Stage V · 2nd` als kanonisch).
- `ARK_JOB_DETAILMASKE_SCHEMA_v0_1.md` §3: Keine Änderung — "Jobs" ist kanonisch per Mockup-Baseline §16.10 (international-DE Begriff, wie `/jobs/[id]` → "Job-Vollansicht").

**Beobachtung:** Die "Sprachmix" war tatsächlich Design-Policy, nicht Inkonsistenz. Einzige echte Drift war das Prozess-Spec-Pattern (Candidate-rooted EN statt Account-rooted DE per Mockup).

## Related

- [[mockup-baseline]] §16 Kanonische UI-Label-Mappings
- [[detailseiten-nachbearbeitung]] Punkt "Cross-Navigation Breadcrumbs — Konsistenz-Pass"
- [[autorefine-log]] Run 7
