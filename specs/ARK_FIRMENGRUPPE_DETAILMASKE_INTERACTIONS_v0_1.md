# ARK CRM — Firmengruppe-Detailmaske Interactions Spec v0.1

**Stand:** 13.04.2026
**Status:** Erstentwurf — Review ausstehend
**Kontext:** Verhalten, Flows der Firmengruppe-Detailseite `/company-groups/[id]`. 2-stufig flach, 6 Tabs, gruppenübergreifende Mandate möglich.
**Begleitdokument:** `ARK_FIRMENGRUPPE_DETAILMASKE_SCHEMA_v0_1.md`
**Vorrang:** Stammdaten > dieses Dokument > Schema > Mockups

---

## TEIL 0: STRUKTURELLE GRUNDENTSCHEIDUNGEN

### Tab-Struktur (6 + 0 konditional)

| # | Tab | Inhalt |
|---|-----|--------|
| 1 | Übersicht | Gruppen-Stammdaten, Gesellschaften-Liste, Aggregierte KPIs |
| 2 | Kultur | Holding-weite Kultur-Analyse (AI-Hybrid) |
| 3 | Kontakte | Alle Kontakte aller Gesellschaften aggregiert |
| 4 | Mandate & Prozesse | Gruppenübergreifende Taskforces + Account-spezifische Mandate + Prozesse |
| 5 | Dokumente | Rahmenverträge, Master-NDAs, Konzern-AGB |
| 6 | History | Gruppen-Events + aggregierte wichtige Account-Events |

### Erstellungs-Wege

| Weg | Trigger |
|-----|---------|
| **Scraper-Vorschlag** | Scraper erkennt via Handelsregister-UID-Match / Hauptsitz-Match / Web-Crawl dass mehrere Accounts zusammengehören → `suggested_by_scraper = true`, amber Banner zur Confirmation |
| **Manuell (AM confirmt Vorschlag)** | AM bestätigt Scraper-Vorschlag → `confirmed_by`, `confirmed_at` gesetzt |
| **Manuell (AM erstellt ad-hoc)** | AM erstellt neue Gruppe ohne Scraper, fügt Gesellschaften zu |

### Ownership

**Kein eigener Group-AM** (entschieden 2026-04-13 FG-5). Group-Level-Aktionen sind Admin-only. Lesezugriff und KPI-Dashboards für alle AMs der Gesellschaften. AMs einzelner Gesellschaften können Daten ihres Accounts editieren (über das jeweilige Account-Detail, nicht hier).

---

## TEIL 1: HEADER & STATUS

### Stammdaten-Edit

Inline-Edit durch Admin oder — eingeschränkt — AM einer Haupt-Gesellschaft (z.B. Holding-Account in der Gruppe).

### Snapshot-Bar Live-Update

Alle 6 Slots werden via Websocket aktualisiert, wenn:
- Gesellschaft hinzugefügt/entfernt
- Mandat-Status an einer Gesellschaft ändert
- Placement an einer Gesellschaft

### Gruppen-Report-Generator

Quick-Action "📄 Gruppen-Report":
1. PDF-Template rendert:
   - Gruppen-Übersicht (Name, Gesellschaften, Sitz)
   - Aggregierte KPIs (Mandate/Prozesse/Placements, Umsatz, Mitarbeitende)
   - Kulturprofil-Summary
   - Top-Decision-Maker
   - Laufende Mandate (Kurzform)
2. Landet in Tab 5 Dokumente unter Kategorie "Gruppen-Präsentationen" (Versionierung pro Generation)

---

## TEIL 2: TAB 1 — ÜBERSICHT

### Gesellschaft hinzufügen

**"+ Gesellschaft hinzufügen" Button in Sektion 2:**
1. Drawer mit Account-Autocomplete (alle Accounts des Tenants)
2. Filter-Vorschläge: "Account mit gleicher UID-Root / ähnlichem Namen / gleichem Sitz" (Scraper-basiert, Hint)
3. Bestätigen → `dim_accounts.group_id = X` gesetzt
4. Events:
   - `group_member_added` im Gruppen-History
   - `account_joined_group` im Account-History
5. **Auto-Folge-Aktion (KRITISCH, FG-10):** Alle bestehenden `fact_candidate_presentation` zu diesem Account bekommen einen zusätzlichen `fact_protection_window` Eintrag mit `scope='group'` und `group_id=X` — damit bestehende Vorstellungen rückwirkend gruppenweit geschützt sind

### Gesellschaft entfernen

"− Entfernen" pro Zeile:
1. Confirm-Dialog: *"Account aus Gruppe entfernen? Account bleibt bestehen, Gruppen-Zuordnung wird aufgehoben."*
2. Optionale Pflicht: Begründung
3. `dim_accounts.group_id = NULL`
4. `fact_protection_window` Einträge mit `scope='group'` für diesen Account werden NICHT automatisch gelöscht (Audit bleibt), aber **Schutzfrist gilt ab Entfernung nicht mehr gruppenweit** für zukünftige Vorstellungen
5. Events: `group_member_removed`

### Scraper-Vorschlag bestätigen

Bei `suggested_by_scraper = true`:
- Prominent amber Banner im Header: *"Scraper-Vorschlag — bestätigen?"*
- Klick → Drawer zeigt vorgeschlagene Zusammengehörigkeit mit Begründung (UID-Root, Hauptsitz, Web-Hinweis)
- AM bestätigt → `confirmed_by`, `confirmed_at` gesetzt → Banner verschwindet
- Ablehnung → Gruppe wird gelöscht, alle `group_id` Zuordnungen zurückgesetzt

---

## TEIL 3: TAB 2 — KULTUR

### AI-Workflow

Analog Account-Kultur Tab 2 (siehe Account-Interactions v0.2). Unterschiede:

**Datenquellen-Priorisierung:**
1. Holding-Website
2. Konzern-Geschäftsberichte
3. Presse-Mitteilungen der Holding
4. Aggregierte Kultur-Scores der Gesellschaften (als Orientierung, nicht Durchschnitt)
5. Web-Recherche zu "Konzern-Kultur" / "Gruppen-Strategie"

**Sektion 6 (Gesellschafts-Kultur-Vergleich):**
- Read-only Tabelle mit allen Gesellschaften und deren 6 Kultur-Scores nebeneinander
- Divergenzen werden hervorgehoben (z.B. "Innovation: Implenia Bau 80, Implenia Engineering 45 → Divergenz")

### Berechtigung

Nur **Admin** kann Gruppen-Kultur generieren (FG-7 + FG-Berechtigungsmatrix).

---

## TEIL 4: TAB 3 — KONTAKTE (READ-ONLY AGGREGIERT)

### Kein CRUD hier

Alle Änderungen an Kontakten passieren in der jeweiligen Account-Detailmaske Tab 3. Tab hier zeigt nur aggregierten View.

### Filter-Interaktion

Filter-State wird im URL persistiert (Deep-Linking). Standard: Active contacts only, gruppiert nach Decision Level DESC.

### Quick-Action pro Kontakt

- Klick → **öffnet Account-Kontakt-Drawer in neuem Tab** (nicht in dieser Page)
- Click-to-Call funktioniert direkt in der Tabelle

---

## TEIL 5: TAB 4 — MANDATE & PROZESSE

### Gruppenübergreifendes Mandat erstellen (Taskforce)

Button "+ Gruppen-Taskforce" (Admin-only):

1. Drawer mit Standard-Mandat-Felder + Ergänzung:
   - Typ ist fix `Taskforce` (gruppenübergreifende Mandate sind nur Taskforce)
   - **Beteiligte Gesellschaften** (Multi-Select aus `group.members`) — mindestens 2
   - **Führende Gesellschaft** (Radio) — eine davon ist `is_primary = true`
2. Bestätigen:
   - `fact_mandate` wird erstellt mit `group_id = X`, `account_id = primary_account`
   - `bridge_mandate_accounts` bekommt N Einträge (einer pro beteiligter Gesellschaft)
3. Events: `group_mandate_created` im Gruppen-History + `mandate_created` in jedem beteiligten Account-History

### Auswirkungen gruppenübergreifendes Mandat

- Mandat erscheint in Mandate-Tab der Firmengruppe als "Gruppenübergreifend"
- Erscheint auch in jedem beteiligten Account-Tab 7 mit Badge "🔗 Gruppen-Taskforce"
- Longlist wird geteilt über alle Gesellschaften (1 gemeinsame Longlist)
- Placements können auf jeder der beteiligten Gesellschaften erfolgen
- Billing: Monatsfee + Success Fee pro Position, Aufteilung auf Gesellschaften konfigurierbar (z.B. nach Placement-Ziel-Gesellschaft)

### Account-spezifische Mandate

Zeigt alle `fact_mandate WHERE account_id IN (group.members) AND group_id IS NULL` — keine Editier-Funktion hier, Drill-Down auf Mandat.

### Prozesse-Liste

Alle `fact_process_core WHERE account_id IN (group.members)`. Klick → Prozess-Detailseite / Slide-in.

---

## TEIL 6: TAB 5 — DOKUMENTE

### Gültigkeitsbereich

Jedes Dokument hat beim Upload-Drawer ein Feld:
- **"Gilt für ganze Gruppe"** (Default) — alle Gesellschaften
- **"Gilt nur für X, Y, Z"** (Multi-Select Subset) — nur einzelne Gesellschaften

Gespeichert in `fact_documents.applies_to_account_ids JSONB` (NULL = alle).

### Aktivierungs-Trigger

- Upload "Rahmenvertrag" → Info-Event `group_framework_contract_added` im Gruppen-History + Notification an alle AMs der Gesellschaften
- Upload "Master-NDA" → Jedem Account in der Gruppe wird `nda_on_file = true` gesetzt (bzw. bei Subset nur den gewählten)

### Ablauf-Management

Bei Dokumenten mit `valid_until` (Ablauf):
- 60 Tage vor Ablauf: Reminder an Admin + AMs
- Bei Ablauf: Badge "⚠ Abgelaufen" + Event `document_expired`

---

## TEIL 7: TAB 6 — HISTORY

### Aggregations-Logik

Scope ist **Mix** (FG-12):
- Alle Gruppen-Level Events unfiltered
- Wichtige Account-Events gefiltert nach `is_significant = true` (Flag auf Event-Typ)

**Standard-signifikante Events:**
- Placement (alle)
- Mandats-Erstellung / -Abschluss / -Kündigung
- Kultur-Analyse einer Gesellschaft abgeschlossen
- Blacklisting / Re-Aktivierung einer Gesellschaft
- AGB-Bestätigung einer Gesellschaft
- Account-Umbenennung

### UI

- Event zeigt immer `scope` Badge: "Gruppe" oder "Gesellschaft: [Name]"
- Default-Sort: newest first
- Filter: Scope, Event-Typ, Gesellschaft, User, Zeitraum

---

## TEIL 8: SCHUTZFRIST-INTEGRATION (FG-10, KRITISCH)

Gemäss Entscheidung 2026-04-13: Schutzfrist gilt **gruppenweit**, nicht nur pro Account.

### Beim Anlegen einer Vorstellung

Wenn `fact_candidate_presentation.account_id` auf einen Account verweist, der Teil einer Gruppe ist (`dim_accounts.group_id NOT NULL`):
- **Zusätzlicher** `fact_protection_window` Eintrag mit `scope='group'`, `group_id=account.group_id`
- Der Account-Level-Eintrag bleibt bestehen (für AM-Sicht), der Group-Level-Eintrag ist der rechtlich relevante
- Beide Einträge haben dieselbe `expires_at` (12 Monate ab Vorstellung)

### Scraper-Match bei Job-Wechsel

Wenn Scraper erkennt, dass Kandidat X bei Account Y angestellt ist:
1. Query: `fact_protection_window WHERE status='active' AND (account_id=Y OR group_id=Y.group_id)`
2. Wenn Treffer auf Group-Level: Claim-Banner in Firmengruppe-Tab 4 + im betroffenen Account-Tab 9 mit Label "Gruppen-Schutzfrist"
3. Info-Request / Claim-Workflow analog Account-Level (siehe Account-Interactions v0.2 TEIL 8c)

### Gesellschaft tritt Gruppe bei

Alle bestehenden Vorstellungen an diesem Account werden rückwirkend gruppenweit geschützt (siehe TEIL 2 "Gesellschaft hinzufügen").

### Gesellschaft verlässt Gruppe

Bestehende `scope='group'` Einträge bleiben aktiv bis Ablauf. Neue Vorstellungen bekommen **keine** Group-Level-Einträge mehr. Keine rückwirkende Entkopplung (Audit-Integrität).

---

## TEIL 9: EVENTS

| Event | Scope |
|-------|-------|
| `group_created_manual` | Gruppe |
| `group_suggested_by_scraper` | Gruppe |
| `group_confirmed` | Gruppe |
| `group_rejected` | Gruppe (Scraper-Vorschlag abgelehnt) |
| `group_member_added` | Gruppe + Account |
| `group_member_removed` | Gruppe + Account |
| `group_culture_generated` | Gruppe |
| `group_mandate_created` | Gruppe + beteiligte Accounts |
| `group_framework_contract_added` | Gruppe + alle Accounts |
| `group_report_generated` | Gruppe |
| `group_protection_window_opened` | Gruppe (bei Vorstellung an Gruppen-Gesellschaft) |

---

## TEIL 10: PHASE 1.5 / PHASE 2

| Feature | Phase |
|---------|-------|
| Scraper-Vorschlag-Algorithmus (UID-Matching) | 1.5 |
| Automatische Erkennung Konzern-Zugehörigkeit aus News/LinkedIn | 2 |
| Gruppen-Kultur-Divergenz-Alerts (wenn Gesellschaft stark abweicht) | 2 |
| Billing-Aufteilung gruppenübergreifender Taskforces automatisch nach Placement-Ziel | 2 |
| Multi-Level Hierarchie (Sub-Gruppen) — aktuell bewusst verneint, nur für künftige Entscheidung | 2+ |

---

## TEIL 11: VERKNÜPFUNGEN

### Zu Accounts
- N:1 via `dim_accounts.group_id`
- Account-Tab "Firmengruppe" (konditional) zeigt Gruppe
- Account-Tab 9 Schutzfristen zeigt auch Group-Level-Einträge

### Zu Mandaten
- N:N via `bridge_mandate_accounts` (für gruppenübergreifende)
- 1:N via `fact_mandate.group_id` (Mandat hat Gruppe-FK)

### Zu Kandidaten / Schutzfristen
- Indirekt via `fact_protection_window.group_id`
- Teamrad nicht vorhanden (FG-8 verneint)

### Zu Dokumenten
- 1:N via `fact_documents.group_id` + optional `applies_to_account_ids` für Subset-Gültigkeit

---

## TEIL 12: METHODIK-REFERENZ

Erbt alle Methodiken von Account-Interactions. Keine Abweichungen.

---

## Related Specs / Wiki

- `ARK_FIRMENGRUPPE_DETAILMASKE_SCHEMA_v0_1.md`
- `ARK_ACCOUNT_DETAILMASKE_INTERACTIONS_v0_3.md` (konditionaler Tab Firmengruppe)
- `ARK_MANDAT_DETAILMASKE_INTERACTIONS_v0_3.md` (gruppenübergreifende Mandate)
- [[firmengruppe]], [[account]], [[direkteinstellung-schutzfrist]]
- [[detailseiten-nachbearbeitung]] (Account-Spec v0.3 nötig für Schutzfrist-Gruppen-Scope)
