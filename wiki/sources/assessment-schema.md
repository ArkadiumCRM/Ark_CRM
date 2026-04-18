---
title: "ARK Assessment Detailmaske Schema v0.2"
type: source
created: 2026-04-13
updated: 2026-04-17
sources: ["ARK_ASSESSMENT_DETAILMASKE_SCHEMA_v0_2.md", "ARK_ASSESSMENT_DETAILMASKE_SCHEMA_v0_1.md"]
tags: [source, assessment, schema, credits-typisiert, layout, detailseite]
---

# ARK Assessment Detailmaske Schema v0.2

**Datei:** `specs/ARK_ASSESSMENT_DETAILMASKE_SCHEMA_v0_2.md`
**Vorherige Version:** `specs/alt/ARK_ASSESSMENT_DETAILMASKE_SCHEMA_v0_1.md`
**Status:** v0.2 = Typisiertes Credits-Modell (Entscheidung 2026-04-14)
**Begleitdokument:** [[assessment-interactions]] v0.2

## Credits-Modell (v0.2 TYPISIERT)

Ein Assessment-Auftrag ist ein **gekauftes Paket mit typisierten Credits** (MDI / Relief / ASSESS 5.0 / DISC / EQ / Scheelen 6HM / Driving Forces / Human Needs / Ikigai / AI-Analyse / Teamrad-Session). Ein Paket kann gemischte Typen enthalten (z.B. "1× MDI + 1× Relief + 1× ASSESS 5.0").

Credits werden pro Typ an Personen zugewiesen und bei Durchführung verbraucht. Umwidmung nur **innerhalb gleichen Typs** möglich. Gesamtpreis sofort bei Unterschrift fällig. Kein Credits-Verfall.

## 5 Tabs

1. Übersicht — Auftragsdaten, Credits-Overview, Preis, Status
2. Durchführungen — `fact_assessment_run` Liste mit Kandidat-Zuweisungen
3. Billing — Pauschal-Rechnung + Spesen
4. Dokumente — Offerte, Executive Summaries, Detail-Reports
5. History — Event-Stream

## Schlüssel-Elemente

- **Snapshot-Bar** 5 Slots: Preis / Credits total / Verbraucht / Ausstehend / Partner
- **Credit-Progress-Bar** unter Header (visuell)
- **Quick-Actions:** Anrufen, Email, Offerte, Report übertragen, Credit zuweisen
- **Tab 2 Durchführungen:** Run-Status (assigned/scheduled/in_progress/completed/cancelled_reassignable), Credit-Zuweisungs-Drawer, Kandidat-Ersetzen-Flow, Report-Upload-Flow
- **Tab 3 Billing:** Standard = Komplette Summe bei Unterschrift (`billing_type='full'`), optional Spesen separat
- **Verknüpfungen:** bidirektional zu Account, Kandidat, optional Mandat (Option IX)
- **Kandidaten-Assessment-Versionen** werden verknüpft mit `assessment_order_id` (Ergebnisse bleiben im Kandidaten-Tab, Auftrag koordiniert Versionierung)

## Neue Datenbank-Tabellen (v0.2)

- `dim_assessment_types` — Typ-Katalog (11 Einträge, siehe unten)
- `fact_assessment_order` — Auftrag (ohne `credits_total`, mit `package_name` optional)
- `fact_assessment_order_credits` — Bridge: order_id + type_id + quantity + used_count (UNIQUE auf order+type, CHECK used ≤ quantity)
- `fact_assessment_run` — inkl. `assessment_type_id` (welcher Typ)
- `fact_assessment_billing` — unverändert
- `fact_candidate_assessment_version` — zentrale Versionierungs-Tabelle für Test-Ergebnisse pro Kandidat+Typ

## `dim_assessment_types` Katalog (11 Einträge)

| # | type_key | display_name | Partner | Quelle/Musterbericht |
|---|---|---|---|---|
| 1 | `mdi` | MDI | TTI / INSIGHTS MDI | [[musterbericht-trimetrix-eq]] |
| 2 | `relief` | Relief | SCHEELEN | [[musterbericht-relief]] |
| 3 | `outmatch` | ASSESS 5.0 | SCHEELEN | [[assessment-beispiel-bewertungsergebnisse]] + 2 weitere |
| 4 | `disc` | DISC | SCHEELEN | Teil von TriMetrix |
| 5 | `eq` | EQ Test | SCHEELEN | Teil von TriMetrix |
| 6 | `scheelen_6hm` | Scheelen 6HM | SCHEELEN | — |
| 7 | `driving_forces` | Driving Forces | TTI | Teil von TriMetrix (12 Driving Forces) |
| 8 | `human_needs` | Human Needs / BIP | — | — |
| 9 | `ikigai` | Ikigai | internal | — |
| 10 | `ai_analyse` | AI-Analyse | internal | — |
| 11 | `teamrad` | Teamrad-Session | internal | — |

**Schema pro Eintrag:**
- `type_key` (unique) · `display_name` · `description_md` · `default_duration_minutes` · `partner` (SCHEELEN/TTI/internal) · `is_active` · `sort_order`

**Partner-Logik:** Partner lebt auf `dim_assessment_types` (nicht auf `fact_assessment_order`). Feld `fact_assessment_order.partner` ist **DEPRECATED** seit v0.2, bleibt für Legacy.

## Umwidmungs-Regel (v0.2)

- Credit-Umwidmung **nur innerhalb gleichen Typs** (MDI→MDI ✓, MDI→Relief ✗)
- Nur solange Run-Status ≤ `scheduled`
- Wechselt nur den Kandidaten, nicht den Typ

## Offene Punkte

- Interactions v0.1 ergänzend (direkt erstellt)
- Mockup-HTMLs für 5 Tabs (P1)
- Credits-Verfall (wann/ob?) — Frage an Peter (P1)
- Multi-Mandat-Zuordnung — aktuell verneint, Klärung ausstehend

## Verlinkte Wiki-Seiten

[[assessment-interactions]], [[diagnostik-assessment]], [[offerte-diagnostik]], [[assessment]], [[mandat]], [[account]], [[kandidat]], [[detailseiten-guideline]]
