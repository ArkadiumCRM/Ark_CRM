---
title: "Algorithmen"
type: concept
created: 2026-04-14
updated: 2026-04-14
sources: ["ARK_BACKEND_ARCHITECTURE_v2_5.md", "ARK_KANDIDATENMASKE_INTERACTIONS_v1_3.md", "ARK_MANDAT_DETAILMASKE_SCHEMA_v0_2.md", "audit-final-2026-04-14.md"]
tags: [algorithmus, matching, fuzzy, honorar, claim, spec]
---

# Algorithmen

Zentrale Algorithmus-Spezifikationen, die in mehreren Specs referenziert werden. Single-Source-of-Truth für Matching, Fuzzy-Search, UID-Logik und Honorar-Berechnung.

## 1. Projekt-Fuzzy-Match (Autocomplete Briefing/Werdegang)

**Input:** Freitext-Query `q` (min 3 Zeichen), optional `bauherr_hint`.
**Output:** Top-3 Kandidaten mit `similarity ∈ [0,1]`.

**Metrik:** PostgreSQL `pg_trgm` (`similarity()` + GIST-Index auf `fact_projects.name || ' ' || coalesce(bauherr,'')`).

**Query:**
```sql
SELECT id, name, bauherr, from_year, to_year,
       similarity(name || ' ' || coalesce(bauherr,''), :q) AS score
FROM fact_projects
WHERE name || ' ' || coalesce(bauherr,'') % :q  -- trigram operator, uses GIST
ORDER BY score DESC
LIMIT 3;
```

**Schwellwerte (Kandidaten-Interactions v1.3):**
- `score ≥ 0.85` → Auto-Suggestion-Card (1 Treffer)
- `0.60 ≤ score < 0.85` → Dropdown Top-3 + "Neues Projekt anlegen"
- `score < 0.60` → Mini-Drawer (Quick-Create)

**Debounce:** 300ms auf Input-Event.
**Index:** `CREATE INDEX idx_projects_trgm ON fact_projects USING gist ((name || ' ' || coalesce(bauherr,'')) gist_trgm_ops);`

---

## 2. UID-Root-Matching (Firmengruppen-Suggestion)

**Ziel:** Automatisch erkennen, dass zwei Accounts zur selben Firmengruppe gehören.

**Input:** Zwei CHE-UIDs `uid_a`, `uid_b` (Format `CHE-XXX.XXX.XXX`).

**Algorithmus:**
1. **Normalisierung:** Punkte + Bindestriche entfernen → `CHEXXXXXXXXX` (12 Zeichen).
2. **Exact-Match:** Gleiche UID = derselbe Account (nicht Gruppe) — return.
3. **Root-Präfix:** Erste 9 Ziffern (Enterprise-ID-Teil) vergleichen. Match → **Gruppen-Vorschlag** (confidence 0.9).
4. **Handelsregister-Cross-Check (optional, batch):** ZEFIX-API (`https://www.zefix.ch/ZefixREST/api/v1/company/uid/:uid`) → `parentCompany`-Feld. Match → confidence 1.0.

**Persistenz:**
- `fact_group_suggestion (id, account_a_id, account_b_id, confidence, source, created_at, reviewed_by, reviewed_at, accepted)`
- UI in Scraper-Modul Review-Queue

**Schwellwerte:**
- `confidence ≥ 0.95` → Auto-Link (mit Audit-Event)
- `0.80–0.94` → Review-Queue (AM)
- `< 0.80` → verworfen

---

## 3. Honorar-Staffel (Erfolgsbasis + Claim-Billing)

**Stammdaten:** `dim_honorar_settings (min_tc, max_tc, pct)`.

**Standard-Staffel (Beispiel, konfigurierbar):**

| TC-Range (CHF) | % |
|----------------|---|
| 0 – 89'999 | 21 |
| 90'000 – 109'999 | 23 |
| 110'000 – 129'999 | 25 |
| ≥ 130'000 | 27 |

**Formel:**
```
pct := lookup_staffel(salary_candidate_target)
fee_net := salary_candidate_target × (honorar_override_pct OR pct) / 100
```

**Claim-Billing (Mandat-Schema v0.2 § 14.1):**

| Fall | Berechnungsbasis |
|------|------------------|
| **X** (ursprüngliche Position) | `sum(stages_remaining)` gemäss Mandats-Originalvertrag (Stage 2/3 je nach Kündigungs-Zeitpunkt) |
| **Y** (andere Position beim Kunden) | `calc_fee(tc_actual_other_position)` — Erfolgsbasis neu |
| **Z** (Firmengruppe) | Wie X/Y je nach Position, nur wenn `fact_protection_window.scope='group'` |

---

## 4. Matching-Score (Kandidat × Job / Kandidat × Projekt)

**Dimensionen (gewichtet via `dim_matching_weights`):**
- Skills-Overlap (Cosine-Similarity auf pgvector-Embeddings)
- BKP/SIA-Bezug (Projekte)
- Seniorität (Jahre Erfahrung)
- Regional-Präferenz
- Sprachen
- Temperatur-Boost (Hot +10%, Warm +0%, Cold −10%)

**Base-Formel:**
```
score := Σ (weight_i × normalize(dim_i))
         for dim_i in enabled_dimensions
```

**Projekt-Overlay (`dim_matching_weights_project`):**
Overlay überschreibt Base-Weights **nur für definierte Dimensionen** (Partial-Override, nicht Replace). Falls Dimension im Overlay fehlt → Base-Weight gilt.

```
effective_weight(dim) := project_overlay.weight(dim)
                     ?? base.weight(dim)
```

Recompute-Trigger: Skill-Change, Doc-Upload, Stage-Change (alle async via `matching-recompute.worker.ts`).

---

## 5. Temperatur-Scoring (Kandidat + Account)

**Input:** Letzte Kontakt-Events, Prozess-Aktivität, Reminder-Rückläufe.

**Kandidat (vollautomatisch, 2-Layer):**

| Layer | Zeitfenster | Boost |
|-------|-------------|-------|
| L1 (Hot) | Interaktion ≤ 14 Tage | +2 |
| L2 (Warm) | Interaktion 15–90 Tage | +1 |
| Cold | > 90 Tage ohne Interaktion | 0 |

Worker: `candidate-temperature-scorer.worker.ts` 2×/Tag (00:00 + 12:00).

**Account:** Analoge Logik auf Account-Events, `account-temperature-scorer.worker.ts`.

---

## Related

[[projekt-datenmodell]], [[matching]], [[direkteinstellung-schutzfrist]], [[mandat-kuendigung]], [[temperatur-modell]], [[firmengruppe]]
