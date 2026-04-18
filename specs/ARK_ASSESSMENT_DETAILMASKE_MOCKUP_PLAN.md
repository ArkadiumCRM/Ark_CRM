# ARK CRM — Assessment-Detailmaske Mockup-Ausbau Plan

**Stand:** 2026-04-17
**Status:** Review ausstehend (User)
**Arbeitsdatei:** `mockups/assessments.html` (aktuell 638 Zeilen — Stub)
**Zielumfang:** ~2'100–2'800 Zeilen nach allen Phasen
**Quell-Specs:**
- `specs/ARK_ASSESSMENT_DETAILMASKE_SCHEMA_v0_2.md`
- `specs/ARK_ASSESSMENT_DETAILMASKE_INTERACTIONS_v0_2.md`
**Stammdaten-Source:** `Grundlagen MD/ARK_STAMMDATEN_EXPORT_v1_3.md` §51 `dim_assessment_types`
**Drift-Referenzen:** `mockups/candidates.html`, `mockups/processes.html`, `mockups/mandates.html` (Header/Drawer/Tab-Pattern)

---

## 0. Ziel

Bestehende `assessments.html` von 638 Zeilen Stub auf v0.2-Parität bringen. **Inkrementell**, in 3 Phasen, mit Drift-Check + Lint + Backup pro Phase.

Detailseite beschreibt einen **Assessment-Auftrag** (gekauftes Paket mit typisierten Credits). Ein Auftrag enthält 1..n Credits unterschiedlichen Typs; jeder Credit wird per Run einem Kandidaten zugewiesen und bei Completion verbraucht. Umwidmung nur innerhalb gleichen Typs. Credits verfallen nicht.

---

## 1. Scope-Entscheidungen (durch User bestätigt 2026-04-17)

### 1.1 Status-Flow (Spec-Sync-Delta zu v0.2!)

Order-Status kennt **kein `invoiced`**. Rechnungs-State lebt auf `fact_assessment_billing.status`, nicht Order-Level.

| Order-Status | Bedeutung |
|--------------|-----------|
| `offered` | Offerte erstellt, noch nicht unterschrieben |
| `ordered` | Unterschrieben, Credits aktiv, Rechnung fällig |
| `partially_used` | Erster Credit completed, weitere offen |
| `fully_used` | Alle Credits completed |
| `cancelled` | Manueller Storno durch AM/Admin |

**Spec v0.2 §TEIL 1 (Interactions) + §4.1 (Schema) müssen korrigiert werden:** Status `invoiced` entfernen aus State-Machine.

### 1.2 Typen-Katalog Phase 1

Mockup nutzt in Phase 1 nur **4 Typen** (alle SCHEELEN bzw. SCHEELEN-nahe):

| ID | Type-Key | Display-Name | Partner |
|----|----------|--------------|---------|
| at_001 | `mdi` | Management-Dimensions-Inventory (MDI) | SCHEELEN |
| at_002 | `relief` | Relief | SCHEELEN |
| at_003 | `assess_5_0` | ASSESS 5.0 | ASSESS 5.0 |
| at_005 | `eq` | EQ Test | SCHEELEN |

DISC, Scheelen 6HM, Driving Forces, Human Needs/BIP, Ikigai, AI-Analyse, Teamrad-Session → Phase 2+. `dim_assessment_types`-Katalog bleibt unverändert (alle 11 `is_active=true`), Mockup filtert im UI.

### 1.3 Offerten-Generator → globaler Dok-Generator (Out-of-Scope)

Globaler Dok-Generator als eigenständige Detailmaske unter Sidebar-Bereich Workflow/Operations — **NACH** Assessment-Mockup-Fertigstellung als separater Plan-Zyklus. Aktuell in Tab 4 Platzhalter-Button "📄 Offerte generieren" mit Future-State-Hinweis "→ Dok-Generator" (nicht blockierend).

---

## 2. Gap-Analyse Stub → v0.2

| Bereich | Stub-Status | Ziel v0.2 | Phase |
|---------|-------------|-----------|-------|
| Header Snapshot-Bar | 5 KPI-Slots | **7 Slots** (Preis · Credits-Mix · Verbraucht · Ausstehend · Package-Name · Partner · Bestellt am) | P1 |
| Credit-Progress-Bar pro Typ | fehlt | Multi-stacked `MDI [██████░░░░] 1/2` je Typ-Zeile | P1 |
| Breadcrumb konditional | statisch | Zeile "(aus Mandat: X)" wenn `mandate_id` | P1 |
| Status-Dropdown-Flow | Badge only | Dropdown mit Confirm-Dialog für manuelle Übergänge (→ cancelled) | P1 |
| Quick-Actions | 4 Buttons | 5 mit Sichtbarkeits-Regeln (§Interactions TEIL 1) | P1 |
| Tab 1 Credits-Tabelle | 2 Typen gezeigt | 4 Phase-1-Typen + "+ Weiteren Typ hinzufügen"-Button | P1 |
| Tab 1 Status & Abschluss | fehlt | Sektion mit `credits_expiry_date` + `notes` | P1 |
| Tab 1 Verknüpfungen | Teil da | Sektion mit Kandidaten · Mandat · History-Kurz (letzte 5) | P1 |
| Tab 2 Filter Typ | Single-Select | **Multi-Select** aus im Order vorhandenen Typen | P1 |
| Tab 2 Empty-State | fehlt | Platzhalter wenn 0 Runs | P1 |
| **Credit-Zuweisungs-Drawer** | fehlt | 540px Drawer, Typ-Pflicht zuerst, Kandidat-Autocomplete, Duplikat-Check, optional Termin | P1 |
| **Run-Drawer** | fehlt | Mini-Card · Timeline · scheduled_at-Editor · Actions (ersetzen/Termin/completed/cancel) | P1 |
| **Kandidat-Ersetzen-Drawer** | fehlt | Aus Run-Drawer, "Typ bleibt erhalten"-Confirm, `reassigned_from`-Log | P1 |
| Tab 3 Billing Zeilen-Typen | 1 Rechnung | `full` + `expense` pro Spesenbeleg, Auto-Trigger-Hinweis | P2 |
| Tab 3 Empty-State | fehlt | Platzhalter | P2 |
| **Tab 4 Dokumente-Scope** | Account-weit (falsch!) | **Order-scoped** (nur Offerte, Exec-Summary, Detail-Report, Rechnung, Spesenbeleg, Korrespondenz, Sonstiges) | P2 |
| Offerten-Generator-CTA | fehlt | Platzhalter-Button (→ Dok-Generator-Future-State) | P2 |
| **Report-Upload-Drawer** | fehlt | 540px: Run wählen, Exec-Summary (Pflicht) + Detail-Report (optional) → Run completed + used_count++ | P2 |
| Tab 5 History-Scope | Account-weit (falsch) | **Order-scoped** — nur Auftrag/Run/Billing/Doc-Events | P3 |
| Tab 5 Filter | generisch | Activity-Typ · Kandidat (beteiligte) · Zeitraum | P3 |
| Keyboard-Hints-Bar | 4 Einträge | Vollständig: 1–5 Tabs · Z Credit · R Report · G Offerte · E Edit · Esc Drawer | P3 |
| Cancellation-Flow | fehlt | Dialog mit Begründungs-Pflicht | P3 |

---

## 3. Phase 1 — Kern-Workflow

**Zielumfang:** +800–1'100 Zeilen. Liefert User-testbar den Haupt-Flow Credit zuweisen → Kandidat wählen → Termin → Durchführung → Ersetzen/Abbrechen.

### 3.1 Header-Ausbau

- **Snapshot-Bar** auf 7 Slots umbauen (CSS-Grid `repeat(7,1fr)`, gap 12px)
- **Credit-Progress-Bar** unter Banner, stacked pro Typ:
  - Zeile je aktiver Typ mit `quantity > 0`
  - Bar: 3 Segmente (verbraucht · zugewiesen · frei) in `--gold`, `--amber`, `--border-soft`
  - Rechts Text: `MDI 1/2 verbraucht · 1 scheduled`
- **Quick-Actions** mit Sichtbarkeits-Regeln:
  - 📞 Anrufen · ✉ Email · 📄 Offerte · 📤 Report übertragen · ➕ Credit zuweisen
  - Sichtbarkeit laut Interactions §TEIL 1
- **Breadcrumb-Konditional:** Bei Mandat-Verknüpfung `<div class="breadcrumb-sub muted">aus Mandat: <a>CFO-Suche</a></div>` unter Haupt-Breadcrumb
- **Status-Dropdown:** Bei manuellem Wechsel → Cancelled Confirm-Dialog (Begründungs-Textarea Pflicht)

### 3.2 Tab 1 Übersicht — Vervollständigung

- **Credits-Tabelle** umbauen auf 4 Phase-1-Typen:
  - Seed-Daten: 2× MDI (1 completed, 1 assigned), 1× Relief (scheduled), 1× ASSESS 5.0 (frei), 1× EQ (frei)
  - Footer-Zeile Summen behalten
  - "+ Weiteren Typ hinzufügen"-Button (nur Pre-Ordered bzw. Admin-Override) → Mini-Drawer mit Typ-Dropdown + Quantity + Einzelpreis
- **Sektion 4 — Status & Abschluss** (neu):
  - `credits_expiry_date` (nullable, Datum-Picker nativ `<input type=date>`)
  - `notes` Textarea
- **Sektion 5 — Verknüpfungen** (neu):
  - Kandidaten mit Credit (mit Fortschritts-Badges)
  - Mandat-Link + Option-IX-Badge (wenn `mandate_id`)
  - History-Kurzübersicht letzte 5 Events → Link Tab 5

### 3.3 Tab 2 Durchführungen — Kern

- **Filter-Bar:** Typ Multi-Select (Chip-Picker), Status Multi-Select, Search
- **Tabelle:** Spalten laut Spec §6.2 (Typ · Kandidat · Status · Zugewiesen · Termin · Durchgeführt · Partner · Report · Aktionen)
- **Empty-State:** "Noch kein Credit zugewiesen. [credits_total] Credits verfügbar. [➕ Credit zuweisen]"

### 3.4 Drawer 1 — Credit-Zuweisung (NEU)

- **Trigger:** Header Quick-Action · Tab-1-Credits-Tabellen-Zeile · Tab-2-Button
- **Breite:** 540px slide-in (Drawer-Default-Regel)
- **Steps:**
  1. **Typ-Pflicht** — Dropdown aus Typen mit `frei > 0` (Label z.B. "MDI (1 frei)"). Wenn aus Tab-1-Zeile: vorausgewählt + gelockt
  2. **Kandidat-Autocomplete** — Pool: alle Kandidaten, Account-Kontakte zuerst
  3. **Kein Match:** Hard-Stop "→ Als Kandidat anlegen" (Link)
  4. **Duplikat-Check:** Warnung wenn aktiver Run gleichen Typs existiert (nicht blockierend, Confirm)
  5. **Optional:** Termin (DateTime-Picker nativ)
- **Bestätigen:** `INSERT fact_assessment_run` + `fact_history` Event `assessment_credit_assigned`

### 3.5 Drawer 2 — Run-Detail (NEU)

- **Trigger:** Klick auf Durchführungs-Zeile
- **Breite:** 540px
- **Inhalt:**
  - Kandidat-Mini-Card (Foto, Name, Funktion, Link)
  - Status-Timeline: assigned → scheduled → in_progress → completed
  - Felder: `scheduled_at` (editierbar bis completed), `completed_at`, Notizen, Link zu `fact_candidate_assessment_version` (bei completed)
- **Actions:**
  - "Kandidat ersetzen" (nur Status ≤ scheduled) → öffnet Drawer 3
  - "Termin setzen/ändern"
  - "Als durchgeführt markieren" → öffnet Report-Upload-Drawer (Phase 2, erstmal Platzhalter)
  - "Abbrechen & Credit freigeben" (→ `cancelled_reassignable`)

### 3.6 Drawer 3 — Kandidat-Ersetzen (NEU)

- **Trigger:** Aus Run-Drawer Action
- **Breite:** 540px
- **Steps:**
  1. Confirm "Person X durch neuen Kandidaten ersetzen? Der [Typ]-Credit bleibt erhalten."
  2. Kandidaten-Suche (wie Zuweisungs-Drawer)
  3. Bestätigen → `UPDATE fact_assessment_run SET candidate_id=neu, reassigned_at=now, reassigned_from_candidate_id=alt`
- **Lock:** `assessment_type_id` darf nicht ändern

### 3.7 Drift-Checks vor P1-Commit

- `mockup-drift-check`: Header-Pattern, Drawer-Width (540px), KPI-Strip, Tab-Struktur vs candidates/processes/mandates
- `stammdaten-lint`: Typen-Namen exakt wie §51, Activity-Types (gibt's Category "Assessment"? → check)
- `umlaute-lint`
- `db-techdetails-lint`: keine `fact_*`/`dim_*` in UI
- `drawer-default-guard`: alle 3 neuen Drawers 540px

---

## 4. Phase 2 — Billing + Dokumente + Report-Upload

**Zielumfang:** +600–900 Zeilen.

### 4.1 Tab 3 Billing

- **Zeilen-Typen** `full` + `expense` (pro Spesenbeleg separat)
- **Status-Badges:** ⏳ offen · 📄 Rechnungsstellung · ✅ bezahlt · 🔴 überfällig
- **Auto-Trigger-Hinweis:** "Hauptrechnung wird automatisch erstellt beim Status-Wechsel Offered → Ordered"
- **Empty-State:** "Noch keine Rechnungen. Hauptrechnung wird automatisch erstellt sobald die Offerte unterschrieben hochgeladen wird."

### 4.2 Tab 4 Dokumente — Umbau auf Order-Scope

**Wichtig:** Bestehende Account-weite Doc-Liste (inkl. Scraper-Belege, Stellenbriefings anderer Mandate) komplett entfernen. Backup vor Umbau zwingend.

- **Kategorien (Order-spezifisch):** Offerte · Executive Summary · Detail-Report · Rechnung · Spesenbeleg · Korrespondenz · Sonstiges
- **Filter:** Kategorie · Jahr · Urheber · Search
- **Offerten-Generator-CTA:** "📄 Offerte generieren" (nur Status=Offered, keine signierte Offerte) — öffnet Platzhalter-Drawer mit "→ Dok-Generator-Future-State" Hinweis
- **Report-Upload-CTA:** "📤 Report übertragen" (nur wenn ≥1 Run `scheduled`/`in_progress`) → öffnet Drawer 4

### 4.3 Drawer 4 — Report-Upload (NEU)

- **Breite:** 540px
- **Steps:**
  1. Run-Auswahl (Dropdown aller `scheduled`/`in_progress` Runs)
  2. Executive Summary PDF Upload (Pflicht)
  3. Detail-Report PDF Upload (optional)
  4. Bestätigen → Auto-Aktionen:
     - `fact_assessment_run.status → completed`, `completed_at = now`
     - `fact_assessment_order_credits.used_count += 1`
     - `fact_candidate_assessment_version` Eintrag
     - `fact_history` Event `assessment_run_completed`
     - Wenn letzter Credit: Order-Status → `fully_used`

### 4.4 Drift-Checks vor P2-Commit

- `saga-trace`: Report-Upload-Flow ist Multi-Step-Saga — Timeline-Darstellung im Run-Drawer korrekt?
- `spec-sync-check` nach Invoiced-Status-Korrektur in Spec v0.2

---

## 5. Phase 3 — History + Polish

**Zielumfang:** +200–400 Zeilen.

### 5.1 Tab 5 History — Umbau auf Order-Scope

- Nur Events zu diesem Order + dessen Runs + dessen Billing + dessen Docs
- **Filter:** Activity-Typ · Kandidat (Dropdown über beteiligte Personen) · Zeitraum
- **Kategorie-Chips:** reduziert auf Order-relevante (Assessment, Emailverkehr, System, Kontaktberührung)
- **Events-Katalog** laut Spec §9.1:
  - Auftrag erstellt/unterschrieben/storniert
  - Credit zugewiesen/ersetzt/freigegeben
  - Termin vereinbart/verschoben
  - Durchführung abgeschlossen
  - Report hochgeladen
  - Rechnung erstellt/bezahlt

### 5.2 Polish

- **Keyboard-Hints-Bar** komplett: `1`–`5` Tabs · `Z` Credit zuweisen · `R` Report übertragen · `G` Offerte generieren · `E` Edit-Mode · `Esc` Drawer
- **Alle Empty-States** (Tab 2, 3, 4)
- **Cancellation-Flow-Dialog** mit Begründungs-Textarea (Pflicht)

### 5.3 Drift-Checks vor P3-Commit

- Vollständiger `ark-lint` Lauf
- `mockup-drift-check` abschliessend gegen alle anderen Detailmasken

---

## 6. Datei-Schutz & Backup

Pro Phasen-Commit **vor Edit** Backup:
```
backups/assessments.html.2026-04-17-<HHMM>-p1.bak
backups/assessments.html.2026-04-17-<HHMM>-p2.bak
backups/assessments.html.2026-04-17-<HHMM>-p3.bak
```

Edits ausschliesslich via `Edit`/`Write`-Tool. Keine Python-Patch-Scripts mit direktem Overwrite. Surrogate-Pair-Hack verboten.

---

## 7. Spec-Sync-Deltas (aus diesem Plan ableitbar)

Nach Mockup-Fertigstellung müssen Specs v0.2 gesynct werden:

| Delta | Betrifft | Aktion |
|-------|----------|--------|
| Status `invoiced` entfernen | `SCHEMA_v0_2.md` §4.1 + `INTERACTIONS_v0_2.md` §TEIL 1 | Spec-Update v0.3 |
| Typen-Katalog Phase-1-Subset | `SCHEMA_v0_2.md` §0 | Kommentar ergänzen: "Phase 1 nur at_001/at_002/at_003/at_005" |
| Globaler Dok-Generator statt Offerten-CTA | `SCHEMA_v0_2.md` §8.3 | Hinweis: Offerten-Gen migriert in globalen Dok-Generator |

`spec-sync-check` Skill nach jeder Phase auf geänderten Specs.

---

## 8. Akzeptanzkriterien

Plan gilt als erfüllt wenn nach P3:

- [ ] 3 Commits (P1/P2/P3), je mit Backup
- [ ] Alle 4 Drawers funktional (Credit-Zuweisung, Run-Detail, Kandidat-Ersetzen, Report-Upload)
- [ ] Snapshot-Bar 7 Slots + multi-stacked Progress-Bar pro Typ
- [ ] Tab 4 + Tab 5 Order-scoped
- [ ] Status-Dropdown ohne `invoiced`
- [ ] Alle Lint-Skills grün (stammdaten, umlaute, db-techdetails, drawer-default, mockup-drift)
- [ ] Mockup lädt mit allen Seed-Daten, alle Tabs/Drawers visuell testbar
- [ ] Spec-Sync-Deltas dokumentiert (v0.3 als Folge-Task gelistet)

---

## 9. Offene Punkte (vor P1-Start)

| # | Punkt | Status |
|---|-------|--------|
| 1 | `dim_activity_types`: gibt es Category "Assessment" mit sub-Events assigned/reassigned/completed? | Check beim P1-Impl via Grep in STAMMDATEN §14 |
| 2 | Status-Wechsel auf `cancelled`: welche Begründungs-Enums? | Aktuell freitext, Enum-Vorschlag als Phase-2-Task |
| 3 | Report-Upload mit mehreren Runs gleichzeitig (Bulk)? | v0.2 nicht vorgesehen, erstmal 1 Run pro Upload |

---

## 10. Nach Plan-Freigabe

1. User reviewed diesen Plan
2. Bei Freigabe → `writing-plans` Skill → detailliertes Implementation-Plan-Doc
3. Implementierung phasenweise mit Review-Checkpoints pro Phase
