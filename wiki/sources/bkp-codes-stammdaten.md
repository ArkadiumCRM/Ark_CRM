---
title: "ARK BKP-Codes Stammdaten"
type: source
created: 2026-04-08
updated: 2026-04-08
sources: ["ARK_BKP_CODES_STAMMDATEN.md", "ARK_BKP_CODES_STAMMDATEN_v2.xlsx"]
tags: [source, bkp, sia, baubranche, stammdaten]
---

# ARK BKP-Codes Stammdaten

**Dateien:** `raw/Ark_CRM_v2/ARK_BKP_CODES_STAMMDATEN.md` + `ARK_BKP_CODES_STAMMDATEN_v2.xlsx`

## Zusammenfassung

Schweizer Baukostenplan-Codierung (SN 506 500) mit SIA-Phasen-Mapping. 3 Datenbank-Tabellen.

## Umfang

- **dim_sia_phases:** 18 Einträge (6 Hauptphasen + 12 Sub-Phasen)
- **dim_bkp_codes:** 425 Einträge, 4 Ebenen hierarchisch
- **bridge_bkp_sia_phases:** ~1465 Cross-Referenzen

Jeder BKP-Code mit `is_blue_collar`, `is_white_collar`, `is_relevant` Flags für Recruiting-Filterung.

## Verlinkte Wiki-Seiten

[[stammdaten]], [[projekt-datenmodell]]
