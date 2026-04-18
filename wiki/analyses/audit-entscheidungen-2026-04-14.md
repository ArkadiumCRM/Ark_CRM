---
title: "Audit-Entscheidungen 14 Fragen (2026-04-14)"
type: analysis
created: 2026-04-14
updated: 2026-04-14
tags: [audit, entscheidungen, klarstellungen, roadmap]
---

# Audit-Entscheidungen — 14 Klärungs-Fragen (2026-04-14)

Antworten von Peter zu allen 14 offenen Klärungs-Fragen aus `audit-2026-04-13-komplett.md`. Dieses Dokument dient als **Single Source of Truth** für die Nachbearbeitungs-Runde aller Specs.

---

## 1. Route-Sprache ✅ ENGLISCH

Alle Detailseiten-Routen einheitlich englisch:
- `/candidates/[id]`, `/accounts/[id]`, `/mandates/[id]`, `/jobs/[id]`, `/processes/[id]`, `/assessments/[id]`
- **NEU:** `/company-groups/[id]` (statt `/firmengruppen`)
- **NEU:** `/projects/[id]` (statt `/projekte`)
- `/scraper` bleibt

**Folge-Updates:**
- `ARK_FIRMENGRUPPE_DETAILMASKE_SCHEMA_v0_1.md` — Route-Referenzen umbenennen
- `ARK_PROJEKT_DETAILMASKE_SCHEMA_v0_1.md` — Route-Referenzen umbenennen
- Wiki-Source-Pages aktualisieren

---

## 2. Status-Enum-Sprache ✅ MISCHUNG BEHALTEN

Aus Gesamtsystem v1.2 bestätigt als intentional:
- **Business-Domain-Sprache Deutsch:** Mandat (`Entwurf/Aktiv/Abgeschlossen/Abgebrochen/Abgelehnt`), Job (`scraper_proposal/vakanz/aktiv/besetzt/geschlossen/abgelehnt`)
- **Technischer-Workflow-Sprache Englisch:** Prozess (`Open/On Hold/Rejected/Placed/...`), Assessment (`offered/ordered/...`)

**Folge-Updates:**
- Neues Wiki-Dokument `wiki/concepts/status-enum-katalog.md` als Glossary
- Cross-Spec-Nachbearbeitung: sicherstellen dass alle Specs konsistent deutsch/englisch je nach Entity verwenden

---

## 3. SIA-Phasen ✅ 6 + 12 HIERARCHISCH

Schweizer SIA 112 Norm:
- 6 Haupt-Phasen (Strategische Planung / Vorstudien / Projektierung / Ausschreibung / Realisierung / Bewirtschaftung)
- 12 Teilphasen hierarchisch unter den Haupt-Phasen

**Folge-Updates:**
- `dim_sia_phases` neue Tabelle mit `parent_phase_id`
- Projekt-Spec anpassen: "11 SIA-Phasen" → "6 Haupt- + 12 Teilphasen"
- Multi-Select UI: Haupt-Phasen primär, optional Drilldown auf Teilphasen
- Stammdaten-Export v1.3 ergänzen

---

## 4. Mandat-Kündigungs-Freigabe ✅ AM ALLEINE

Kein Admin-Gate-Check bei Mandats-Kündigung. AM kann Drawer direkt öffnen und Kündigung durchführen.

**Folge-Updates:**
- `ARK_MANDAT_DETAILMASKE_INTERACTIONS_v0_2.md` TEIL 9 — Berechtigungs-Matrix: AM (Owner) = ✅ Kündigung, Admin = ✅
- Audit-Log (`fact_audit_log`) bleibt obligatorisch für Nachvollziehbarkeit

---

## 5. Claim stellen (Schutzfrist) ✅ AM ALLEINE

Analog zu #4 — AM kann Claims ohne Admin-Gate stellen.

**Folge-Updates:**
- `ARK_ACCOUNT_DETAILMASKE_INTERACTIONS_v0_2.md` TEIL 8c — Berechtigungs-Matrix: AM (Owner) = ✅ Claim, Admin = ✅
- Audit-Log obligatorisch

---

## 6. `dim_jobs` vs. `fact_jobs` ✅ NUR `fact_jobs`

Keine separate Stammdaten-Tabelle für Jobs. Alle Jobs sind operative account-spezifische Ausschreibungen.

**Folge-Updates:**
- Scraper-Spec prüfen auf falsche `dim_jobs`-Referenzen → zu `fact_jobs` ändern
- DB v1.3 entfernt `dim_jobs` falls erwähnt

---

## 7. Claim-Billing-Logik ✅ KONTEXTABHÄNGIG

- **Mandats-Prozess:** Claim-Rechnung basiert auf Mandats-Konditionen (Target-Stage-3-Betrag)
- **Erfolgsbasis-Prozess:** Claim-Rechnung basiert auf Staffel (21/23/25/27%) angewendet auf den neuen tatsächlichen Jahreslohn

**Folge-Updates:**
- Claim-Workflow-Spec in Account-Interactions TEIL 8c — Logik explizit
- Neues Rechnungs-Template `Vorlage_Rechnung_Direkteinstellung-Claim.docx` erforderlich (mit beiden Pfaden)

---

## 8. Longlist-Locking bei Mandat-Kündigung ✅ JA + PROZESSE SCHLIESSBAR

Bei Mandats-Kündigung:
- `fact_mandate.is_longlist_locked = true`
- Longlist: keine neuen Stage-Wechsel, kein Durchcall, Badge "🔒 Longlist gesperrt"
- **NEU (Peter):** Offene Prozesse müssen **schliessbar** sein (Status-Wechsel zu `Dropped` oder `Cancelled` erlaubt)

**Folge-Updates:**
- `ARK_MANDAT_DETAILMASKE_INTERACTIONS_v0_2.md` TEIL 9 — bei Kündigung:
  - Banner auf Prozess-Tab: "Mandat gekündigt — offene Prozesse bitte abschliessen"
  - Prozess-Detailseite Status-Dropdown: `Dropped` und `Cancelled` weiterhin wählbar
  - Bulk-Action in Mandat-Prozesse-Tab: "Alle offenen Prozesse als Dropped markieren" (Confirm + Begründung)

---

## 9. Scraper-UID-Matching ✅ ZEFIX + 85/60 SCHWELLEN mit MARKIERUNG

- Zefix-API als primäre Quelle
- **≥ 85% Confidence:** Auto-Suggestion (Firmengruppen-Vorschlag)
- **60-84% Confidence:** AM-Review notwendig
- **NEU (Peter):** **< 60% nicht verwerfen**, sondern **markieren + AM-Kontrolle**

**Folge-Updates:**
- Scraper-Spec Finding-Processing: Confidence < 60% landet als "low_confidence" Flag in Review-Queue (statt auto-reject)
- UI: Orange/rot hinterlegt, "AM-Kontrolle nötig" Label
- `fact_scraper_findings.review_priority ENUM('standard','needs_am_review')`

---

## 10. Assessment Credits-Modell ⚠️ FUNDAMENTALE ÄNDERUNG

**Ursprüngliche Annahme:** Ein Auftrag = N Credits (gleicher Typ).

**Korrektur (Peter 2026-04-14):** Credits sind **typisiert**. Ein Kunde kauft z.B.:
- 1× MDI (Management-Dimensions-Inventory)
- 1× Relief
- 1× ASSESS 5.0

Diese Credits können beliebig auf verschiedene Kandidaten angewendet werden (Umwidmung innerhalb Typ möglich, zwischen Typen nicht — ein MDI-Credit kann nicht zu Relief werden).

### Datenmodell-Revision

**Bestehend (war):**
```
fact_assessment_order.credits_total = 5
fact_assessment_run.assessment_order_id → FK
```

**Neu (ab 2026-04-14):**
```sql
dim_assessment_types (neu, Stammdaten):
  id, type_key VARCHAR UNIQUE,   -- 'mdi', 'relief', 'outmatch', 'disc', 'eq', 'scheelen_6hm', 'driving_forces', 'human_needs', 'ikigai', 'ai_analyse'
  display_name VARCHAR,
  default_duration_minutes INT,
  partner VARCHAR,                -- z.B. 'SCHEELEN', 'TTI', 'intern'
  is_active BOOLEAN

fact_assessment_order_credits (neu, Bridge zwischen Order und Typ):
  id, order_id FK, assessment_type_id FK,
  quantity INT,                   -- z.B. 1 MDI, 2 Relief
  price_chf DECIMAL,              -- Einzelpreis je Typ (optional, sonst Gesamtpreis am Order)
  used_count INT DEFAULT 0,       -- Live-Zähler
  UNIQUE(order_id, assessment_type_id)

fact_assessment_run:
  + assessment_type_id FK NOT NULL  -- welcher Typ wird durchgeführt
  -- credits_order Relation über order_id + assessment_type_id (nicht nur order)
```

### UI-Änderungen Assessment-Detailseite

**Snapshot-Bar neu (7 Slots statt 5):**
| Slot | Inhalt |
|------|--------|
| 1 | 💰 Preis (gesamt) |
| 2 | 🎯 Credits-Mix (z.B. "1 MDI · 1 Relief · 1 ASSESS 5.0") |
| 3 | ✅ Verbraucht (pro Typ) |
| 4 | ⏳ Ausstehend (pro Typ) |
| 5 | 📦 Package-Name (falls benannt) |
| 6 | 🤝 Partner(s) |
| 7 | 📅 Bestell-Datum |

**Tab 1 Übersicht Sektion 2 "Credits" wird Tabelle:**
| Typ | Gekauft | Verbraucht | Ausstehend | Einzelpreis |
|-----|---------|-----------|-----------|-------------|
| MDI | 1 | 0 | 1 | CHF 2'500 |
| Relief | 1 | 1 | 0 | CHF 1'800 |
| ASSESS 5.0 | 1 | 0 | 1 | CHF 3'200 |

**Tab 2 Durchführungen:** Neue Spalte "Typ" (MDI/Relief/...). Filter: Multi-Select Typ.

**Credit-Zuweisungs-Drawer:** Pflichtfeld "Welchen Typ verbrauchen?" (Dropdown, nur Typen mit `ausstehend > 0`).

**Umwidmung:** Nur **innerhalb gleichen Typs** möglich (MDI-Credit kann Kandidat A → Kandidat B, aber nicht Typ MDI → Typ Relief).

**Report-Upload-Flow:** Typ wird beim Run automatisch gesetzt, nicht mehr aus Multi-Select wählbar.

### Abwärts-Kompatibilität

Bestehende Aufträge (keine) — nicht relevant, da noch keine Live-Daten.

### Impact auf Stammdaten

- **`dim_assessment_types`** neu anlegen, Start mit Katalog:
  - MDI, Relief, ASSESS 5.0, DISC, EQ Test, Scheelen 6HM, Driving Forces, Human Needs / BIP, Ikigai, AI-Analyse, Teamrad-Session
- In Stammdaten-Export v1.3 ergänzen

### Folge-Updates

- `ARK_ASSESSMENT_DETAILMASKE_SCHEMA_v0_1.md` → **v0.2** mit Credits-Typen-Umbau
- `ARK_ASSESSMENT_DETAILMASKE_INTERACTIONS_v0_1.md` → **v0.2** mit Typ-Zuweisungs-Logik
- Wiki-Konzept [[diagnostik-assessment]] aktualisieren
- `dim_assessment_types` in Stammdaten-Export v1.3

---

## 11. `fact_assessment_run.result_version_id` ✅ NEUE TABELLE

Neue zentrale Tabelle `fact_candidate_assessment_version` als Parent für alle Test-Ergebnis-Versionen eines Kandidaten.

**Datenmodell:**
```sql
fact_candidate_assessment_version (
  id uuid PK,
  candidate_id FK NOT NULL,
  assessment_order_id FK NULL,     -- NULL wenn Legacy/Manual
  assessment_type_id FK NOT NULL,  -- welcher Typ
  version_number INT,               -- pro Typ+Kandidat aufsteigend
  version_date TIMESTAMP,
  executive_summary_doc_id FK NULL,
  detail_report_doc_id FK NULL,
  result_data JSONB,                -- Test-spezifische Rohdaten
  created_at, created_by
)
```

Sub-Tabellen (DISC-Details, EQ-Details etc.) bekommen `version_id` FK.

---

## 12. `fact_projects.volume_chf_exact` vs. `volume_range` ✅ BEIDE MIT GENERATED COLUMN

`volume_range` wird als Postgres Generated Column aus `volume_chf_exact` berechnet:
```sql
volume_range ENUM GENERATED ALWAYS AS (
  CASE
    WHEN volume_chf_exact < 5000000 THEN '<5M'
    WHEN volume_chf_exact < 20000000 THEN '5-20M'
    WHEN volume_chf_exact < 50000000 THEN '20-50M'
    ELSE '>50M'
  END
) STORED
```

Falls `volume_chf_exact` NULL → manueller `volume_range` erlaubt.

**Folge-Updates:** Projekt-Schema v0.2 — DB-Definition ergänzen.

---

## 13. `cluster_ids` Multi-Cluster ✅ BRIDGE-TABELLE

`bridge_project_clusters(project_id, cluster_id, is_primary)` statt JSONB.

**Folge-Updates:**
- Projekt-Schema v0.2 — Datenmodell-Anpassung
- Analog für `sparte_ids`: `bridge_project_spartens`

---

## 14. Schutzfrist bei Mandat-Kündigung ✅ NUR VORGESTELLTE

Konsistent zu Variante A vom 13.04.2026:
- Longlist-Idents ohne dokumentierte Vorstellung → keine Schutzfrist
- Nur `fact_candidate_presentation`-Einträge erzeugen `fact_protection_window`

---

## Implementierungs-Priorisierung der Updates

### P0 (Sofort)
1. **Assessment-Spec v0.2** — Credits-Typen-Umbau (grösste Änderung)
2. **Mandat-Interactions v0.3** — Longlist-Locking + offene Prozesse schliessen
3. **Account-Interactions v0.3** — Schutzfrist-Gruppen-Scope (aus Audit) + Claim AM-allein
4. **Scraper-Spec** — <60% Confidence markieren statt verwerfen
5. **Route-Updates** — Firmengruppe + Projekt auf Englisch

### P1 (nächste Welle)
6. **Projekt-Spec v0.2** — SIA 6+12 hierarchisch, Generated Column volume_range, Bridge-Tabellen
7. **Stammdaten-Export v1.3** — `dim_assessment_types`, `dim_sia_phases`, `dim_rejection_reasons_internal`, alle weiteren fehlenden
8. **Gesamtsystem v1.3** — Mandats-Typen umbenennen (Einzelmandat → Target, RPO → Taskforce), Prozess-Mischform dokumentieren
9. **Status-Enum-Katalog** Wiki-Dokument

### P2 (Phase 1.5)
10. Alle anderen Nachbearbeitungs-Punkte aus `detailseiten-nachbearbeitung.md`

---

## Related

[[audit-2026-04-13-komplett]], [[detailseiten-nachbearbeitung]], [[detailseiten-inventar]]
